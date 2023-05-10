/*/
*==========================================================================\
|Programa  | DIPR054 | Autor | Rafael de Campos Falco  | Data | 09/10/2003  |
|===========================================================================|
|Desc.     | RELATÓRIO DE SALDOS INCIAIS                                    |
|===========================================================================|
|Sintaxe   | DIPR054                                                        |
|===========================================================================|
|Uso       | Especifico DIPROMED                                            |
|===========================================================================|
|Histórico | DD/MM/AA - Descrição da alteração                              |
==========================================================================
/*/

#INCLUDE "RWMAKE.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "FILEIO.CH"

User Function DIPR054()

Local _xArea    := GetArea()
Local titulo     := OemTOAnsi("Relação de saldos iniciais - analítico - Por periodo e filial",72)
Local cDesc1     := (OemToAnsi("Este programa tem como objetivo emitir um relat¢rio",72))
Local cDesc2     := (OemToAnsi("com a relação dos saldos iniciais.",72))
Local cDesc3     := (OemToAnsi("Conforme parametros definidos pelo o usuario.",72))
Private aPar2		:= ""
Private aReturn    := {"Bco A4", 1,"Administracao", 1, 2, 1,"",1}
Private li         := 67
Private tamanho    := "P"
Private limite     := 80
Private nomeprog   := "DIPR054"

//Private cPerg      := "DIPR54"
// FPADR(cPerg, cArq, cCampo, cTipo)  - Para ajustar o tamanho das perguntas no SX1- uso generico
PRIVATE cPerg  	:= U_FPADR( "DIPR54","SX1","SX1->X1_GRUPO"," " ) //Função criada por Sandro em 19/11/09.

Private nLastKey   := 0
Private lEnd       := .F.
Private wnrel      := "DIPR054"
Private cString    := "SB9"
Private m_pag      := 1
Private cWorkFlow	:= ""
Private aTot_SB9	:= {}
Private aTot_SBK	:= {}
Private aTot_SBJ	:= {}

U_DIPPROC(ProcName(0),U_DipUsr()) // JBS 05/10/2005 - Gravando o nome do Programa no SZU

AjustaSX1(cPerg)             // Verifica perguntas. Se nao existe INCLUI

If !Pergunte(cPerg,.T.)    // Solicita parametros
	Return
EndIf

wnrel := SetPrint(cString,wnrel,cPerg,Titulo,cDesc1,cDesc2,cDesc3,.T.)

If nLastKey == 27
	Return
Endif

SetDefault(aReturn,cString)

Processa({|lEnd| Proc054()},"Totalizando Saldos...")

RptStatus({|lEnd| Rel054()},"Imprimindo Saldos...")

Set device to Screen

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se em disco, desvia para Spool                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If aReturn[5] == 1    // Se Saida para disco, ativa SPOOL
	Set Printer TO
	Commit
	ourspool(wnrel)
Endif

RestArea(_xArea)

Return

//////////////////////////////////////////////////////////////////////
Static Function Proc054()
Local cVar_COD		:= ""
Local cVar_FIL		:= ""
Local cVar_DAT		:= ""
Local cVar_LOC		:= ""
Local nVar_QIN		:= 0
Local cVar_Localiz:= ''
Local cVar_Rastro := ''

/* Seleciona os clientes do vendedor(es) informado(s)

////////// SALDOS INICIAIS POR ENDEREÇO
SELECT BK_COD, BK_FILIAL, BK_DATA, BK_LOCAL, SUM(BK_QINI) BK_QINI
FROM SBK010
WHERE BK_FILIAL = '04'
AND BK_DATA = '20041130'
AND SBK010.D_E_L_E_T_ = ''
GROUP BY BK_COD, BK_FILIAL, BK_DATA, BK_LOCAL
ORDER BY BK_COD, BK_FILIAL, BK_DATA, BK_LOCAL

////////// SALDOS INICIAIS POR LOTE
SELECT BJ_COD, BJ_FILIAL, BJ_DATA, BJ_LOCAL, SUM(BJ_QINI) BJ_QINI
FROM SBJ010
WHERE BJ_FILIAL = '04'
AND BJ_DATA = '20041130'
AND SBJ010.D_E_L_E_T_ = ''
GROUP BY BJ_COD, BJ_FILIAL, BJ_DATA, BJ_LOCAL
ORDER BY BJ_COD, BJ_FILIAL, BJ_DATA, BJ_LOCAL
////////// SALDOS INICIAIS
SELECT B9_COD, B9_FILIAL, B9_DATA, B9_QINI, B9_LOCAL, B1_RASTRO, B1_LOCALIZ
FROM SB9010, SB1010
WHERE B9_FILIAL = '01'
AND B9_DATA = '20041130'
AND B9_COD = B1_COD
AND B1_LOCALIZ = 'S'
AND SB9010.D_E_L_E_T_ = ''
AND SB1010.D_E_L_E_T_ = ''
ORDER BY B9_COD, B9_FILIAL, B9_DATA, B9_QINI, B9_LOCAL
*/

QRY1 := " SELECT B9_COD, B9_FILIAL, B9_DATA, B9_QINI, B9_LOCAL, B1_RASTRO, B1_LOCALIZ"
QRY1 += " FROM " + RetSQLName("SB9") + "," + RetSQLName("SB1")
QRY1 += " WHERE B9_FILIAL = '" + Iif(MV_PAR01 == 1,'01','04') + "'"
QRY1 += " AND B9_DATA = '" + DtoS(MV_PAR02) + "' "
QRY1 += " AND B9_COD = B1_COD "
QRY1 += " AND " + RetSQLName("SB9")+".D_E_L_E_T_ <> '*'"
QRY1 += " AND " + RetSQLName("SB1")+".D_E_L_E_T_ <> '*'"
QRY1 += " ORDER BY B9_COD, B9_FILIAL, B9_DATA, B9_QINI, B9_LOCAL"

#xcommand TCQUERY <sql_expr>                          ;
[ALIAS <a>]                                           ;
[<new: NEW>]                                          ;
[SERVER <(server)>]                                   ;
[ENVIRONMENT <(environment)>]                         ;
=> dbUseArea(                                         ;
<.new.>,                                              ;
"TOPCONN",                                            ;
TCGENQRY(<(server)>,<(environment)>,<sql_expr>),      ;
<(a)>, .F., .T.)

// Processa Query SQL
TcQuery QRY1 NEW ALIAS "QRY1"         // Abre uma workarea com o resultado da query

DbSelectArea("QRY1")
QRY1->(dbGotop())

cVar_COD	:= QRY1->B9_COD
cVar_FIL	:= QRY1->B9_FILIAL
cVar_DAT	:= QRY1->B9_DATA
cVar_LOC	:= QRY1->B9_LOCAL
nVar_QIN	:= 0
cVar_Localiz := QRY1->B1_LOCALIZ
cVar_Rastro  := QRY1->B1_RASTRO


// ACUMULA SALDOS INICIAIS DO 
ProcRegua(10000)
While QRY1->(!Eof())
	IncProc( "Processando... Saldos SB9 - " + cVar_COD)
	If	cVar_COD	!= QRY1->B9_COD
		Aadd(aTot_SB9,{cVar_COD, cVar_FIL, cVar_DAT, cVar_LOC, nVar_QIN,cVar_Localiz,cVar_Rastro})
		cVar_COD	:= QRY1->B9_COD
		cVar_FIL	:= QRY1->B9_FILIAL
		cVar_DAT	:= QRY1->B9_DATA
		cVar_LOC	:= QRY1->B9_LOCAL
		nVar_QIN	:= QRY1->B9_QINI
		cVar_Localiz := QRY1->B1_LOCALIZ
		cVar_Rastro  := QRY1->B1_RASTRO
	Else
		nVar_QIN	+= QRY1->B9_QINI
	EndIf
		
	QRY1->(DbSkip())
	
EndDo

If	cVar_COD	!= aTot_SB9[Len(aTot_SB9),1]
	Aadd(aTot_SB9,{cVar_COD, cVar_FIL, cVar_DAT, cVar_LOC, nVar_QIN,cVar_Localiz,cVar_Rastro})
Else
	aTot_SB9[Len(aTot_SB9),5] := aTot_SB9[Len(aTot_SB9),5] + nVar_QIN
EndIf	

QRY2 := " SELECT BK_COD, BK_FILIAL, BK_DATA, BK_LOCAL, SUM(BK_QINI) BK_QINI"
QRY2 += " FROM " + RetSQLName("SBK")
QRY2 += " WHERE BK_FILIAL = '" + Iif(MV_PAR01 == 1,'01','04') + "'"
QRY2 += " AND BK_DATA = '" + DtoS(MV_PAR02) + "'"
QRY2 += " AND " + RetSQLName("SBK")+".D_E_L_E_T_ <> '*'"
QRY2 += " GROUP BY BK_COD, BK_FILIAL, BK_DATA, BK_LOCAL"
QRY2 += " ORDER BY BK_COD, BK_FILIAL, BK_DATA, BK_LOCAL"

#xcommand TCQUERY <sql_expr>                          ;
[ALIAS <a>]                                           ;
[<new: NEW>]                                          ;
[SERVER <(server)>]                                   ;
[ENVIRONMENT <(environment)>]                         ;
=> dbUseArea(                                         ;
<.new.>,                                              ;
"TOPCONN",                                            ;
TCGENQRY(<(server)>,<(environment)>,<sql_expr>),      ;
<(a)>, .F., .T.)

// Processa Query SQL
TcQuery QRY2 NEW ALIAS "QRY2"         // Abre uma workarea com o resultado da query

DbSelectArea("QRY2")
QRY2->(dbGotop())

cVar_COD	:= QRY2->BK_COD
cVar_FIL	:= QRY2->BK_FILIAL
cVar_DAT	:= QRY2->BK_DATA
cVar_LOC	:= QRY2->BK_LOCAL
nVar_QIN	:= 0
ProcRegua(10000)
While QRY2->(!Eof())
	IncProc( "Processando... Saldos SBK - " + cVar_COD)	
	If	cVar_COD	!= QRY2->BK_COD
		Aadd(aTot_SBK,{cVar_COD, cVar_FIL, cVar_DAT, cVar_LOC, nVar_QIN})
		cVar_COD	:= QRY2->BK_COD
		cVar_FIL	:= QRY2->BK_FILIAL
		cVar_DAT	:= QRY2->BK_DATA
		cVar_LOC	:= QRY2->BK_LOCAL
		nVar_QIN	:= QRY2->BK_QINI
	Else
		nVar_QIN	+= QRY2->BK_QINI
	EndIf
		
	QRY2->(DbSkip())
	
EndDo

If	cVar_COD	!= aTot_SBK[Len(aTot_SBK),1]
	Aadd(aTot_SBK,{cVar_COD, cVar_FIL, cVar_DAT, cVar_LOC, nVar_QIN})
Else
	aTot_SBK[Len(aTot_SBK),5] := aTot_SBK[Len(aTot_SBK),5] + nVar_QIN
EndIf


QRY3 := " SELECT BJ_COD, BJ_FILIAL, BJ_DATA, BJ_LOCAL, SUM(BJ_QINI) BJ_QINI"
QRY3 += " FROM " + RetSQLName("SBJ")
QRY3 += " WHERE BJ_FILIAL = '" + Iif(MV_PAR01 == 1,'01','04') + "'"
QRY3 += " AND BJ_DATA = '" + DtoS(MV_PAR02) + "'"
QRY3 += " AND " + RetSQLName("SBJ")+".D_E_L_E_T_ <> '*' "
QRY3 += " GROUP BY BJ_COD, BJ_FILIAL, BJ_DATA, BJ_LOCAL"
QRY3 += " ORDER BY BJ_COD, BJ_FILIAL, BJ_DATA, BJ_LOCAL"

#xcommand TCQUERY <sql_expr>                          ;
[ALIAS <a>]                                           ;
[<new: NEW>]                                          ;
[SERVER <(server)>]                                   ;
[ENVIRONMENT <(environment)>]                         ;
=> dbUseArea(                                         ;
<.new.>,                                              ;
"TOPCONN",                                            ;
TCGENQRY(<(server)>,<(environment)>,<sql_expr>),      ;
<(a)>, .F., .T.)

// Processa Query SQL
TcQuery QRY3 NEW ALIAS "QRY3"         // Abre uma workarea com o resultado da query

DbSelectArea("QRY3")
QRY3->(dbGotop())

cVar_COD	:= QRY3->BJ_COD
cVar_FIL	:= QRY3->BJ_FILIAL
cVar_DAT	:= QRY3->BJ_DATA
cVar_LOC	:= QRY3->BJ_LOCAL
nVar_QIN	:= 0
ProcRegua(10000)
While QRY3->(!Eof())
	IncProc( "Processando... Saldos SBJ - " + cVar_COD)
	If	cVar_COD	!= QRY3->BJ_COD
		Aadd(aTot_SBJ,{cVar_COD, cVar_FIL, cVar_DAT, cVar_LOC, nVar_QIN})
		cVar_COD	:= QRY3->BJ_COD
		cVar_FIL	:= QRY3->BJ_FILIAL
		cVar_DAT	:= QRY3->BJ_DATA
		cVar_LOC	:= QRY3->BJ_LOCAL
		nVar_QIN	:= QRY3->BJ_QINI
	Else
		nVar_QIN	+= QRY3->BJ_QINI
	EndIf
		
	QRY3->(DbSkip())
	
EndDo

If	cVar_COD	!= aTot_SBJ[Len(aTot_SBJ),1]
	Aadd(aTot_SBJ,{cVar_COD, cVar_FIL, cVar_DAT, cVar_LOC, nVar_QIN})
Else
	aTot_SB9[Len(aTot_SBJ),5] := aTot_SBJ[Len(aTot_SBJ),5] + nVar_QIN
EndIf


Return



//////////////////////////////////////////////////////////////////////
Static Function Rel054()

Local _cTitulo := "Relatório de Saldos Iniciais"
Local _cDesc1  := " Filial: " + Iif(mv_par01 == 1,"01-Matriz","04-CLD" ) + " - Data: " + dtoc(mv_par02) 
Local _cDesc2  := " Codigo | Local |    Inicial B9   |    Inicial BK   |    Inicial BJ"
Local nPos_SBK  := 0
Local nPos_SBJ  := 0

*          1         2         3         4         5         6         7         8         9         0         1         2         3         4         5         6         7         8         9         0
*0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901
* Codigo | Local |    Inicial B9   |    Inicial BK   |    Inicial BJ
* 999999 | 12345 |  9.999.999,99   |  9.999.999,99   |  9.999.999,99

SetRegua(Len(aTot_SB9))

For xi:=1 to Len(aTot_SB9)

	If li > 65
		li := Cabec(_cTitulo,_cDesc1,_cDesc2,nomeprog,tamanho) + 1
	EndIf
	
	IncRegua( "Imprimindo: " + aTot_SB9[xi,1] )

	If Alltrim(aTot_SB9[xi,6]) == 'S'
		nPos_SBK := aScan(aTot_SBK, { |x| Alltrim(x[1]) == Alltrim(aTot_SB9[xi,1])})
		lImp_SBK := Iif(nPos_SBK == 0, .F., aTot_SBK[nPos_SBK,5] <> aTot_SB9[xi,5])
	Else
		lImp_SBK := .F.
	EndIf

	If Alltrim(aTot_SB9[xi,7]) == 'L'
		nPos_SBJ := aScan(aTot_SBJ, { |x| Alltrim(x[1]) == Alltrim(aTot_SB9[xi,1])})
		lImp_SBJ := Iif(nPos_SBJ == 0, .F., aTot_SBJ[nPos_SBJ,5] <> aTot_SB9[xi,5])
	Else
		lImp_SBJ := .F.
	EndIf	

	If lImp_SBK .OR. lImp_SBJ
		@ li,001 PSay AllTrim(aTot_SB9[xi,1])
		@ li,008 PSay '|'
		@ li,013 PSay Iif(Empty(AllTrim(aTot_SB9[xi,4])),'XX',AllTrim(aTot_SB9[xi,4]))
		@ li,016 PSay '|'
		@ li,019 PSay aTot_SB9[xi,5] PICTURE '@E 9,999,999.99'
		@ li,034 PSay '|'
		@ li,037 PSay Iif(nPos_SBJ == 0, 0, aTot_SBJ[nPos_SBJ,5]) PICTURE '@E 9,999,999.99'
		@ li,052 PSay '|'
		@ li,055 PSay Iif(nPos_SBK == 0, 0, aTot_SBK[nPos_SBK,5]) PICTURE '@E 9,999,999.99'
		li++
	EndIf
Next

QRY1->(dbCloseArea())
QRY2->(dbCloseArea())
QRY3->(dbCloseArea())

Return(.T.)

/*==========================================================================\
|Programa  |VALIDPERG| Autor | Rafael de Campos Falco  | Data ³ 04/06/2004  |
|===========================================================================|
|Desc.     | Inclui as perguntas caso nao existam                           |
|===========================================================================|
|Sintaxe   | VALIDPERG                                                      |
|===========================================================================|
|Uso       | Especifico DIPROMED                                            |
|===========================================================================|
|Histórico | DD/MM/AA - Descrição da alteração                              |
\==========================================================================*/

Static Function AjustaSX1(cPerg)
_sAlias := Alias()
dbSelectArea("SX1")
dbSetOrder(1)                                                                    

aRegs:={}

//------------ Grupo/Ordem/Pergunta/PERGING/PERGESP/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05/F3

//AADD(aRegs,{cPerg,"01","Informe a filial   ?","","","mv_ch1","C",6,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","",'SA1'})
aAdd(aRegs,{cPerg,"01","Informe a filial   ?","","","mv_ch1","N",1,0,0,"C","","mv_par01","01-Matriz","","","","","04-CLD","","","","","","","",""})
aAdd(aRegs,{cPerg,"02","Da Data            ?","","","mv_ch2","D",8,0,0,"G","","mv_par02","","","","","","","","","","","","","",""})
For i:=1 to Len(aRegs)
	If !dbSeek(cPerg+aRegs[i,2])
		RecLock("SX1",.T.)
		For j:=1 to FCount()
			If j <= Len(aRegs[i])
				FieldPut(j,aRegs[i,j])
			Endif
		Next
		MsUnlock()
	Endif
Next

dbSelectArea(_sAlias)
Return
/*====================================================================================\
|Programa  | DIPR052       | Autor | Rafael de Campos Falco     | Data | 02/08/2004   |
|=====================================================================================|
|Descrição | Descrição da aplicação da função dentro do sistema                       |
|=====================================================================================|
|Sintaxe   | DIPR052                                                                  |
|=====================================================================================|
|Uso       | Especifico DIPROMED                                                      |
|=====================================================================================|
|........................................Histórico....................................|
|Rafael    | DD/MM/AA - Descrição                                                     |
|Eriberto  | DD/MM/AA - Descrição                                                     |
\====================================================================================*/   

#include "rwmake.ch"
#INCLUDE "TBICONN.CH"
#INCLUDE "FILEIO.CH"

User Function DIPR052()
Local	_dDatIni		:= ""
Local	_dDatFim		:= ""
Local _xArea		:= GetArea()
Local titulo		:= OemTOAnsi("Relação de Notas Cancelas - Por Período",72)
Local cDesc1		:= (OemToAnsi("Este programa tem como objetivo emitir um relat¢rio",72))
Local cDesc2		:= (OemToAnsi("com a relação de n otas canceladas dentro do período informado.",72))
Local cDesc3		:= (OemToAnsi("Conforme parametros definidos pelo o usuario.",72))
Private m_pag		:= 1
Private nLastKey	:= 0
Private aPar2		:= ""
Private cWorkFlow	:= ""
Private li			:= 99
Private tamanho	:= "G"
Private limite		:= 220
Private lEnd		:= .F.
Private cString	:= "SZD"
Private wnrel		:= "DIPR052"
Private nomeprog	:= "DIPR052"

//Private cPerg		:= "DIPR52"
// FPADR(cPerg, cArq, cCampo, cTipo)  - Para ajustar o tamanho das perguntas no SX1- uso generico
PRIVATE cPerg  	:= U_FPADR( "DIPR52","SX1","SX1->X1_GRUPO"," " ) //Função criada por Sandro em 19/11/09.

Private aReturn	:= {"Bco A4", 1,"Administracao", 1, 2, 1,"",1}

U_DIPPROC(ProcName(0),U_DipUsr()) // JBS 05/10/2005 - Gravando o nome do Programa no SZU

AjustaSX1(cPerg)                // Verifica perguntas. Se nao existe INCLUI.

If !Pergunte(cPerg,.T.)    // Solicita parametros
	Return
EndIf                      

wnrel := SetPrint(cString,wnrel,cPerg,Titulo,cDesc1,cDesc2,cDesc3,.f.,,.f.,tamanho,,.f.,,,,,)

If nLastKey == 27
	Return
Endif
	
SetDefault(aReturn,cString)

Processa({|lEnd| RunProc52()},"Relação de Notas Canceladas...")

RptStatus({|lEnd| RodaRel52()},"Imprimindo Relação de Notas Canceladas...")

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
Static Function RunProc52()

ProcRegua(150)
For _x := 1 to 50
	IncProc( "Processando dados do banco... ")
Next

/*
SELECT ZD_EMISSAO, ZD_DATAEXC, ZD_NOTA, ZD_SERIE, ZD_CLIENTE, ZD_TES, ZD_ATUEST, ZD_ATUFIN, ZD_ESTEXCL, ZD_EXPLIC
FROM SZD010
WHERE ZD_EMISSAO BETWEEN '20040705' AND '20040705'
ORDER BY ZD_EMISSAO, ZD_NOTA, ZD_TES
*/

QRY1 := " SELECT ZD_EMISSAO, ZD_DATAEXC, ZD_NOTA, ZD_SERIE, ZD_CLIENTE, ZD_TES, ZD_ATUEST, ZD_ATUFIN, ZD_ESTEXCL, ZD_EXPLIC"
QRY1 += " FROM " + RetSQLName("SZD")
QRY1 += " WHERE ZD_EMISSAO BETWEEN '" + DTOS(MV_PAR01) + "' AND '" + DTOS(MV_PAR02) + "'"
QRY1 += " AND " + RetSQLName("SZD") + ".D_E_L_E_T_ = ''"
QRY1 += " ORDER BY ZD_EMISSAO, ZD_NOTA, ZD_TES"	

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

ProcRegua(150)
For _x := 1 to 150
	IncProc( "Fim do Processando... ")
Next

Return(.T.)

//////////////////////////////////////////////////////////////////////
Static Function RodaRel52()
Local cCod_Pro := ""
Local cWorkFlow:= "N"
Local _cTitulo	:= "Relação de Notas Canceladas do Período - " + Substr(DtoS(MV_PAR01),7,2)+"/"+Substr(DtoS(MV_PAR01),5,2)+"/"+Substr(DtoS(MV_PAR01),1,4) + " até " + Substr(DtoS(MV_PAR02),7,2)+"/"+Substr(DtoS(MV_PAR02),5,2)+"/"+Substr(DtoS(MV_PAR02),1,4)
Local _cDesc1	:= "Dt Emissão       Dt Exclusão       Número       Série       Código-Nome Cliente                                                 TES        Atual. Estoque     Atual. Financ   Estorna Exclusao"
Local _cDesc2	:= "Explicação"
Local cNum_Not := ""
Local cNum_Tes := ""
Local nTot_Not := 0

*0                                                                                                   1                                                                                                   2
*0         1         2         3         4         5         6         7         8         9         0         1         2         3         4         5         6         7         8         9         0         1         2
*01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
*-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*Dt Emissão       Dt Exclusão       Número       Série       Código-Nome Cliente                                                 TES        Atual. Estoque     Atual. Financ   Estorna Exclusao 
*Explicação
*-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*DD/MM/AAAA       DD/MM/AAAA        999999       999         999999-XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX       999              X                 X                  X
*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
*-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

DbSelectArea("QRY1")
Do While QRY1->(!Eof())
	If lAbortPrint
		@ li+1,00 PSAY "*** CANCELADO PELO OPERADOR ***"
		Exit
	Endif
	
	If li > 66
		li := Cabec(_cTitulo,_cDesc1,_cDesc2,nomeprog,tamanho) + 1
	EndIf

	If QRY1->ZD_NOTA != cNum_Not .and. QRY1->ZD_TES != cNum_Tes
		@ li,000 PSay SubStr(QRY1->ZD_EMISSAO,7,2) + "/" + SubStr(QRY1->ZD_EMISSAO,5,2) + "/" + SubStr(QRY1->ZD_EMISSAO,1,4)
		@ li,017 PSay SubStr(QRY1->ZD_DATAEXC,7,2) + "/" + SubStr(QRY1->ZD_DATAEXC,5,2) + "/" + SubStr(QRY1->ZD_DATAEXC,1,4)
		@ li,035 PSay AllTrim(QRY1->ZD_NOTA)
		@ li,048 PSay AllTrim(QRY1->ZD_SERIE)
		@ li,060 PSay AllTrim(QRY1->ZD_CLIENTE) + "-" + AllTrim(Posicione("SA1",1,xFilial("SA1")+QRY1->ZD_CLIENTE,"A1_NOME"))
		@ li,128 PSay AllTrim(QRY1->ZD_TES)
		@ li,145 PSay AllTrim(QRY1->ZD_ATUEST)
		@ li,163 PSay AllTrim(QRY1->ZD_ATUFIN)
		@ li,182 PSay AllTrim(QRY1->ZD_ESTEXCL)
		li++
		cNum_Not := QRY1->ZD_NOTA 
		cNum_Tes := QRY1->ZD_TES
		nTot_Not++
		cExplic  := QRY1->ZD_EXPLIC
	ElseIf QRY1->ZD_NOTA == cNum_Not .and. QRY1->ZD_TES != cNum_Tes
		@ li,128 PSay AllTrim(QRY1->ZD_TES)
		@ li,145 PSay AllTrim(QRY1->ZD_ATUEST)
		@ li,163 PSay AllTrim(QRY1->ZD_ATUFIN)
		@ li,182 PSay AllTrim(QRY1->ZD_ESTEXCL)
		li++
		cNum_Tes := QRY1->ZD_TES
	EndIf
	QRY1->(DbSkip())
	If QRY1->ZD_NOTA != cNum_Not .OR. QRY1->(EOF())
		@ li,000 PSay AllTrim(cEXPLIC)
		li++
		@ li,000 PSay Replic("-",Limite)
		li++
		cNum_Tes := ''
	EndIf
EndDo	

QRY1->(dbCloseArea())

li++
@ li,000 PSay AllTrim(Str(nTot_Not,7,0))+" Notas canceladas no periodo"
li++
@ li,000 PSay Replic("-",Limite)

Return(.T.)

/////////////////////////////////////////////////////////////////////////////
Static Function AjustaSX1(cPerg)
_sAlias := Alias()
dbSelectArea("SX1")
dbSetOrder(1)                                                                    

aRegs:={}

//------------ Grupo/Ordem/Pergunta/PERGING/PERGESP/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05/F3

aAdd(aRegs,{cPerg,"01","Período de         ?","","","mv_ch1","D",8,0,0,"G","","MV_PAR01","","","","","","","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"02","Período ate        ?","","","mv_ch2","D",8,0,0,"G","","MV_PAR02","","","","","","","","","","","","","","","","","","","","","","","","","",""})

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
///////////////////////////////////////////////////////////////////////////
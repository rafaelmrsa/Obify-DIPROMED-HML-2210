/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Funcao   ³ DIPR041 ³ Autor ³ Rafael de Campos Falco ³ Data ³ 11/09/2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Relatório contas as pagar e receber Sintético              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ DIPR041                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Especifico DIPROMED                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

#include "rwmake.ch"
#IFNDEF WINDOWS
	#DEFINE PSay Say
#ENDIF

User Function DIPR041()

Local _xArea	:= GetArea()
Local titulo	:= OemTOAnsi("Posição dos Títulos a Receber e Pagar - Sintético",72)
Local cDesc1	:= OemToAnsi("Este programa tem como objetivo emitir um relat¢rio",72)
Local cDesc2	:= OemToAnsi("da posição dos títulos a Receber e Pagar.",72)
Local cDesc3	:= OemToAnsi("Conforme parametros definidos pelo o usuario.",72)

Private aReturn    := {"Bco A4", 1,"Financeiro", 1, 2, 1,"",1}
Private li         := 67
Private tamanho    := "P"
Private limite     := 80
Private nomeprog   := "DIPR041"

// Private cPerg      := "DIPR41"
// FPADR(cPerg, cArq, cCampo, cTipo)  - Para ajustar o tamanho das perguntas no SX1- uso generico
PRIVATE cPerg  	:= U_FPADR( "DIPR41","SX1","SX1->X1_GRUPO"," " ) //Função criada por Sandro em 19/11/09.

Private nLastKey   := 0
Private lEnd       := .F.
Private lContinua  := .T.
Private wnrel      := "DIPR041"
Private cString    := "SE1"
Private m_pag      := 1
Private _aRecPag   := {}
Private _aFeriad	 := {}   

U_DIPPROC(ProcName(0),U_DipUsr()) // JBS 05/10/2005 - Gravando o nome do Programa no SZU

AjustaSX1(cPerg)             // Verifica perguntas. Se nao existe INCLUI

If !Pergunte(cPerg,.T.)    // Solicita parametros
	Return
EndIf                      

wnrel := SetPrint(cString,wnrel,cPerg,Titulo,cDesc1,cDesc2,cDesc3,.f.,,.f.,tamanho,,.f.,,,,,)

If nLastKey == 27
	Return
Endif

SetDefault(aReturn,cString)

Processa({|lEnd| RunProc()},"Selecionando dados...")

RptStatus({|lEnd| RptDetail()},"Imprimindo...")

RestArea(_xArea)

Return

//////////////////////////////////////////////////////////////////////
Static Function RunProc()

ProcRegua(100)
For _x := 1 to 35
	IncProc( "Processando... ")
Next

/*
SELECT E1_VENCTO, SUM(E1_SALDO) E1_SALDO 
FROM SE1010
WHERE SE1010.D_E_L_E_T_ <> '*'
  AND E1_VENCTO >= '20030101'
  AND E1_VENCTO <= '20030131'
GROUP BY E1_VENCTO
ORDER BY E1_VENCTO
*/
//	query dos títulos a receber
QRY1 := "SELECT E1_VENCTO, SUM(E1_SALDO) E1_SALDO"
QRY1 += " FROM " +  RetSQLName('SE1')  
QRY1 += " WHERE " + RetSQLName('SE1') + ".D_E_L_E_T_ <> '*' AND "
QRY1 += RetSQLName('SE1') + ".E1_VENCTO >= '" + Dtos(mv_par01) + "' AND "
QRY1 += RetSQLName('SE1') + ".E1_VENCTO <= '" + Dtos(mv_par02) + "'"
QRY1 += "GROUP BY E1_VENCTO "
QRY1 += "ORDER BY E1_VENCTO"

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

/*
SELECT E2_VENCTO, SUM(E2_SALDO) E2_SALDO 
FROM SE2010
WHERE SE2010.D_E_L_E_T_ <> '*'
  AND E2_VENCTO >= '20030101'
  AND E2_VENCTO <= '20030102'
GROUP BY E2_VENCTO
ORDER BY E2_VENCTO
*/
//	query dos títulos à pagar
QRY2 := "SELECT E2_VENCTO, SUM(E2_SALDO) E2_SALDO"
QRY2 += " FROM " +  RetSQLName('SE2')  
QRY2 += " WHERE " + RetSQLName('SE2') + ".D_E_L_E_T_ <> '*' AND "
QRY2 += RetSQLName('SE2') + ".E2_VENCTO >= '" + Dtos(mv_par01) + "' AND "
QRY2 += RetSQLName('SE2') + ".E2_VENCTO <= '" + Dtos(mv_par02) + "'"
QRY2 += "GROUP BY E2_VENCTO "
QRY2 += "ORDER BY E2_VENCTO"

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

// Posicionando no primeiro registro
DbSelectArea("QRY2")
DbGoTop()

// Posicionando no primeiro registro
DbSelectArea("QRY1")
DbGoTop()

// Filtro para montagem do relatório em um Array
Do While QRY1->(!Eof()) .and. QRY2->(!Eof())
	IncProc( "Processando... "+QRY1->(E1_VENCTO))
	If QRY1->(E1_VENCTO) == QRY2->(E2_VENCTO)
		Aadd(_aRecPag,{cDow(ctod(Substr(QRY1->(E1_VENCTO),7,2)+"/"+Substr(QRY1->(E1_VENCTO),5,2)+"/"+Substr(QRY1->(E1_VENCTO),1,4))),QRY1->(E1_VENCTO),QRY1->(E1_SALDO),QRY2->(E2_SALDO)})
		QRY1->(DbSkip())
		QRY2->(DbSkip())
	ElseIf QRY1->(E1_VENCTO) >= QRY2->(E2_VENCTO)
		Aadd(_aRecPag,{cDow(ctod(Substr(QRY1->(E1_VENCTO),7,2)+"/"+Substr(QRY1->(E1_VENCTO),5,2)+"/"+Substr(QRY1->(E1_VENCTO),1,4))),QRY1->(E1_VENCTO),0,QRY2->(E2_SALDO)})
		QRY2->(DbSkip())
	ElseIf QRY1->(E1_VENCTO) <= QRY2->(E2_VENCTO)
		Aadd(_aRecPag,{cDow(ctod(Substr(QRY1->(E1_VENCTO),7,2)+"/"+Substr(QRY1->(E1_VENCTO),5,2)+"/"+Substr(QRY1->(E1_VENCTO),1,4))),QRY1->(E1_VENCTO),QRY1->(E1_SALDO),0})
		QRY1->(DbSkip())
	EndIF
EndDo

// Montagem do array com feriados
dbSelectArea("SX5")
dbSetOrder(1)
dbSeek(xFilial("SX5")+"63")
While X5_TABELA == "63"
	If SubStr(X5_DESCRI,1,1) != "*" .and. Val(SubStr(X5_DESCRI,7,2)) < 80 // Condição para pegar campos somente com datas e com ano de 2000 em diante
      // Monta data extraída do campo X5_DESCRI
		cTemp := Iif(Empty(SubStr(X5_DESCRI,7,2)),Str(Year(Date())),("20"+SubStr(X5_DESCRI,7,2)))+SubStr(X5_DESCRI,4,2) + SubStr(X5_DESCRI,1,2)
		Aadd(_aFeriad,{AllTrim(cTemp)})
	EndIf
	SX5->(DbSkip())
EndDo
Return

///////////////////////////
Static Function RptDetail()

// inicialização das variáveis
nPos1 := ""
nPos2 := ""
_cTitulo := "Posicao a Receber/Pagar - por data"
_cDesc1  := "Dia Semana" + Space(3) + "Vencimento" + Space(12) + "Títulos a Receber" + Space(12) + "Títulos à Pagar"
_cDesc2  := ""
_aSemExt := {{"Monday","Segunda"},{"Tuesday","Terça"},{"Wednesday","Quarta"},{"Thursday","Quinta"},{"Friday","Sexta"}}

SetRegua(Len(_aRecPag))

// Inicializa variáveis de totalização
_nSomRec := 0
_nSomPag := 0
_nFimRec := 0
_nFimPag := 0

// Impressão do relatório
For xi:=1 to Len(_aRecPag)
	IncRegua( "Imprimindo: "+Substr(_aRecPag[xi,2],7,2)+"/"+Substr(_aRecPag[xi,2],5,2)+"/"+Substr(_aRecPag[xi,2],1,4))
	If li > 65
		li := Cabec(_cTitulo,_cDesc1,_cDesc2,nomeprog,tamanho) + 1
	EndIf	
	*                                                                                                   1                                                                                                   2                                                                                                   3
	*         1         2         3         4         5         6         7         8         9         0         1         2         3         4         5         6         7         8         9         0         1         2         3         4         5         6         7         8         9         0         1         2         3         4         5         6
	*1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
	*Dia Semana   Vencimento            Títulos a Receber            Títulos à Pagar
	*Sáb/Dom/Seg  DD/MM/AAAA                99.999.999,99              99.999.999,99

	// Impressão do fornecedor	
	nPos1 := Ascan(_aFeriad,{|y|AllTrim(y[1]) == AllTrim(_aRecPag[xi,2])}) // Verifica se data é um Feriado
	
	If (AllTrim(_aRecPag[xi,1])=="Saturday") .or. (AllTrim(_aRecPag[xi,1])=="Sunday") // Acumula qdo. for Sábado e Domingo, imprime junto com a Segunda
		_nFimRec += _aRecPag[xi,3]
		_nFimPag += _aRecPag[xi,4]	
	ElseIf !Empty(nPos1) // Se a data for um feriado acumula para o próximo dia 
		_nFimRec += _aRecPag[xi,3]
		_nFimPag += _aRecPag[xi,4]	
	Else // Imprime o dia e mais acumuladores
		nPos2 := Ascan(_aSemExt,{|x|AllTrim(x[1]) == AllTrim(_aRecPag[xi,1])})
		@ li,001 PSay AllTrim(_aSemExt[nPos2,2])
		@ li,013 PSay Substr(_aRecPag[xi,2],7,2)+"/"+Substr(_aRecPag[xi,2],5,2)+"/"+Substr(_aRecPag[xi,2],1,4)
		@ li,039 PSay (_nFimRec + _aRecPag[xi,3]) Picture "@E 99,999,999.99"
		@ li,066 PSay (_nFimPag + _aRecPag[xi,4]) Picture "@E 99,999,999.99"
		_nFimRec := 0
		_nFimPag := 0	
		li++  
	EndIf	
	_nSomRec += _aRecPag[xi,3]
	_nSomPag += _aRecPag[xi,4]
 
Next

// Impressão da linha de totais
li += 2
@ li,000 psay Replicate("-",80)
li += 1
@ li,014 PSay "Total"
@ li,039 PSay _nSomRec Picture "@E 99,999,999.99"	
@ li,066 PSay _nSomPag Picture "@E 99,999,999.99"	
li += 1	
@ li,000 psay Replicate("-",80)

DbSelectArea("QRY1")
QRY1->(DbCloseArea())

DbSelectArea("QRY2")
QRY2->(DbCloseArea())

Set device to Screen

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se em disco, desvia para Spool                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If aReturn[5] == 1    // Se Saida para disco, ativa SPOOL
	Set Printer TO
	Commit
	ourspool(wnrel)
Endif

Return(.T.)

/////////////////////////////////////////////////////////////////////////////
//
Static Function AjustaSX1(cPerg)
_sAlias := Alias()
dbSelectArea("SX1")
dbSetOrder(1)                                                                    

aRegs:={}

//------------ Grupo/Ordem/Pergunta/PERGING/PERGESP/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05/F3
AADD(aRegs,{cPerg,"01","Data Inicial  ?","","","mv_ch1","D",08,0,0,"G","","mv_par01","","","","","","","","","","","","","",""})
AADD(aRegs,{cPerg,"02","Data Final    ?","","","mv_ch2","D",08,0,0,"G","","mv_par02","","","","","","","","","","","","","",""})

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

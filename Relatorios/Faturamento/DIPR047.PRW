/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Funcao    ³ DIPR047  ³ Autor ³ RAFAEL DE CAMPOS FALCO³ Data ³ 23/03/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Posicao de Vendas por operador(a) por período                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ DIPR047                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Especifico DIPROMED                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
#include "rwmake.ch"
#INCLUDE "TBICONN.CH"
#INCLUDE "FILEIO.CH"

User Function DIPR047()
Local _xArea		:= GetArea()
Local titulo		:= OemTOAnsi("Posicao de Vendas por operador(a) por período",72)
Local cDesc1		:= (OemToAnsi("Este programa tem como objetivo emitir um relat¢rio",72))
Local cDesc2		:= (OemToAnsi("com a posicao de vendas de cada operador(a).",72))
Local cDesc3		:= (OemToAnsi("Conforme parametros definidos pelo o usuario.",72))
Local	_dDatIni	:= ""
Local	_dDatFi		:= ""

Private li			:= 67
Private 	QRY1	:= ""
Private 	QRY2	:= ""
Private 	QRY3	:= ""
Private 	QRY4	:= ""
Private aPar2		:= ""
Private aReturn		:= {"Bco A4", 1,"Administracao", 1, 2, 1,"",1}
Private tamanho		:= "P"
Private limite		:= 80
Private nomeprog	:= "DIPR047"

// Private cPerg		:= "DIPR47"
// FPADR(cPerg, cArq, cCampo, cTipo)  - Para ajustar o tamanho das perguntas no SX1- uso generico
PRIVATE cPerg  	:= U_FPADR( "DIPR47","SX1","SX1->X1_GRUPO"," " ) //Função criada por Sandro em 19/11/09.

Private nLastKey	:= 0
Private lEnd		:= .F.
Private wnrel		:= "DIPR047"
Private cString	:= "SC5"
Private m_pag		:= 1
Private cWorkFlow	:= ""

U_DIPPROC(ProcName(0),U_DipUsr()) // JBS 05/10/2005 - Gravando o nome do Programa no SZU

/*If AllTrim(Upper(U_DipUsr())) <> 'ERIBERTO'
	If AllTrim(Upper(U_DipUsr())) <> 'FALCO'
		MSGSTOP("Voce nao é o Eriberto","Usuario sem autorizacao!")
		Return
	EndIf
EndIf*/


AjustaSX1(cPerg)                // Verifica perguntas. Se nao existe INCLUI.

If !Pergunte(cPerg,.T.)    // Solicita parametros
	Return
EndIf                      

wnrel := SetPrint(cString,wnrel,cPerg,Titulo,cDesc1,cDesc2,cDesc3,.f.,,.f.,tamanho,,.f.,,,,,)

If nLastKey == 27
	Return
Endif
	
SetDefault(aReturn,cString)

Processa({|lEnd| RunProc47()},"Totalizando pedidos por operador(a)...")

RptStatus({|lEnd| RodaRel47()},"Imprimindo volume de pedidos por operador(a)...")

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
Static Function RunProc47()

ProcRegua(350)
For _x := 1 to 50
	IncProc( "Processando valores do Call Center... ")
Next

/*
SELECT C5_EMISSAO, U7_COD, U7_NOME, SUM(C6_VALOR) VALOR
FROM SU7010, SC5010, SC6010
WHERE C5_EMISSAO BETWEEN '20030601' AND '20040331'
	AND C5_TIPO = 'N'
	AND C5_VEND1 = U7_CODVEN
	AND U7_CODVEN <> '000204'
	AND C5_NUM = C6_NUM
	AND SC6010.D_E_L_E_T_ <> '*'
	AND SC5010.D_E_L_E_T_ <> '*'
	AND SU7010.D_E_L_E_T_ <> '*'
GROUP BY C5_EMISSAO, U7_COD, U7_NOME 
ORDER BY C5_EMISSAO, U7_COD
*/

/* PROCESSA VALORES DO CALL CENTER */
QRY1 := " SELECT C5_EMISSAO, U7_COD, U7_NOME, SUM(C6_VALOR) VALOR"
QRY1 += " FROM " + RetSQLName("SC5") + ", " + RetSQLName("SC6") + ", " + RetSQLName("SU7")
QRY1 += " WHERE C5_EMISSAO BETWEEN '" + DTOS(MV_PAR01) + "' AND '" + DTOS(MV_PAR02) + "'"
QRY1 += " AND C5_TIPO = 'N'"
QRY1 += " AND C5_VEND1 = U7_CODVEN"
QRY1 += " AND U7_CODVEN <> '000204'"
QRY1 += " AND C5_NUM = C6_NUM"
QRY1 += " AND " + RetSQLName("SC5") + ".D_E_L_E_T_ = ''"
QRY1 += " AND " + RetSQLName("SC6") + ".D_E_L_E_T_ = ''"
QRY1 += " AND " + RetSQLName("SU7") + ".D_E_L_E_T_ = ''"
QRY1 += " GROUP BY C5_EMISSAO, U7_COD, U7_NOME"
QRY1 += " ORDER BY C5_EMISSAO, U7_COD"

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

ProcRegua(350)
For _x := 1 to 100
	IncProc( "Processando quantidades do Call Center... ")
Next


/*
SELECT C5_EMISSAO, U7_COD, U7_NOME, COUNT(C5_NUM) QUANTIDADE
FROM SU7010, SC5010
WHERE C5_EMISSAO BETWEEN '20030601' AND '20040331'
	AND C5_TIPO = 'N'
	AND C5_VEND1 = U7_CODVEN
	AND U7_CODVEN <> '000204'
	AND SC5010.D_E_L_E_T_ <> '*'
	AND SU7010.D_E_L_E_T_ <> '*'
GROUP BY C5_EMISSAO, U7_COD, U7_NOME 
ORDER BY C5_EMISSAO, U7_COD
*/

/* PROCESSA QUANTIDADE DO CALL CENTER */
QRY2 := " SELECT C5_EMISSAO, U7_COD, U7_NOME, COUNT(C5_NUM) QUANTIDADE"
QRY2 += " FROM " + RetSQLName("SC5") + ", " + RetSQLName("SU7")
QRY2 += " WHERE C5_EMISSAO BETWEEN '" + DTOS(MV_PAR01) + "' AND '" + DTOS(MV_PAR02) + "'"
QRY2 += " AND C5_TIPO = 'N'"
QRY2 += " AND C5_VEND1 = U7_CODVEN"
QRY2 += " AND U7_CODVEN <> '000204'"
QRY2 += " AND " + RetSQLName("SC5") + ".D_E_L_E_T_ = ''"
QRY2 += " AND " + RetSQLName("SU7") + ".D_E_L_E_T_ = ''"
QRY2 += " GROUP BY C5_EMISSAO, U7_COD, U7_NOME"
QRY2 += " ORDER BY C5_EMISSAO, U7_COD"

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

ProcRegua(350)
For _x := 1 to 150
	IncProc( "Processando valores do Apoio... ")
Next


/*
SELECT C5_EMISSAO, U7_COD, U7_NOME, SUM(C6_VALOR) VALOR
FROM SU7010, SC5010, SC6010
WHERE C5_EMISSAO BETWEEN '20030601' AND '20040331'
	AND C5_TIPO = 'N'
	AND C5_OPERADO = U7_COD
	AND U7_CODVEN = ''
	AND C5_NUM = C6_NUM
	AND SC6010.D_E_L_E_T_ <> '*'
	AND SC5010.D_E_L_E_T_ <> '*'
	AND SU7010.D_E_L_E_T_ <> '*'
GROUP BY C5_EMISSAO, U7_COD, U7_NOME 
ORDER BY C5_EMISSAO, U7_COD
*/

/* PROCESSA VALORES DO APOIO */
QRY3 := " SELECT C5_EMISSAO, U7_COD, U7_NOME, SUM(C6_VALOR) VALOR"
QRY3 += " FROM " + RetSQLName("SC5") + ", " + RetSQLName("SU7") + ", " + RetSQLName("SC6")
QRY3 += " WHERE C5_EMISSAO BETWEEN '" + DTOS(MV_PAR01) + "' AND '" + DTOS(MV_PAR02) + "'"
QRY3 += " AND C5_TIPO = 'N'"
QRY3 += " AND C5_OPERADO = U7_COD"
QRY3 += " AND U7_CODVEN = ''"
QRY3 += " AND C5_NUM = C6_NUM"
QRY3 += " AND " + RetSQLName("SC5") + ".D_E_L_E_T_ = ''"
QRY3 += " AND " + RetSQLName("SU7") + ".D_E_L_E_T_ = ''"
QRY3 += " AND " + RetSQLName("SC6") + ".D_E_L_E_T_ = ''"
QRY3 += " GROUP BY C5_EMISSAO, U7_COD, U7_NOME"
QRY3 += " ORDER BY C5_EMISSAO, U7_COD"

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

ProcRegua(350)
For _x := 1 to 200
	IncProc( "Processando quantidades do Apoio... ")
Next


/*
SELECT C5_EMISSAO, U7_COD, U7_NOME, COUNT(C5_NUM) QUANTIDADE
FROM SU7010, SC5010
WHERE C5_EMISSAO BETWEEN '20030601' AND '20040331'
	AND C5_TIPO = 'N'
	AND C5_OPERADO = U7_COD
	AND U7_CODVEN = '' 
	AND SC5010.D_E_L_E_T_ <> '*'
	AND SU7010.D_E_L_E_T_ <> '*'
GROUP BY C5_EMISSAO, U7_COD, U7_NOME 
ORDER BY C5_EMISSAO, U7_COD
*/

/* PROCESSA QUANTIDADE DO APOIO */
QRY4 := " SELECT C5_EMISSAO, U7_COD, U7_NOME, COUNT(C5_NUM) QUANTIDADE"
QRY4 += " FROM " + RetSQLName("SC5") + ", " + RetSQLName("SU7")
QRY4 += " WHERE C5_EMISSAO BETWEEN '" + DTOS(MV_PAR01) + "' AND '" + DTOS(MV_PAR02) + "'"
QRY4 += " AND C5_TIPO = 'N'"
QRY4 += " AND C5_OPERADO = U7_COD"
QRY4 += " AND U7_CODVEN = ''"
QRY4 += " AND " + RetSQLName("SC5") + ".D_E_L_E_T_ = ''"
QRY4 += " AND " + RetSQLName("SU7") + ".D_E_L_E_T_ = ''"
QRY4 += " GROUP BY C5_EMISSAO, U7_COD, U7_NOME"
QRY4 += " ORDER BY C5_EMISSAO, U7_COD"

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
TcQuery QRY4 NEW ALIAS "QRY4"         // Abre uma workarea com o resultado da query
DbSelectArea("QRY4")
QRY4->(dbGotop())

ProcRegua(350)
For _x := 1 to 250
	IncProc( "Processando valores da Cristina Urias... ")
Next


/*
SELECT C5_EMISSAO, U7_COD, U7_NOME, SUM(C6_VALOR) VALOR
FROM SU7010, SC5010, SC6010
WHERE C5_EMISSAO BETWEEN '20030601' AND '20040331'
	AND C5_TIPO = 'N'
	AND C5_OPERADO = U7_COD
	AND U7_COD = '000015'
	AND C5_NUM = C6_NUM
	AND SC6010.D_E_L_E_T_ <> '*'
	AND SC5010.D_E_L_E_T_ <> '*'
	AND SU7010.D_E_L_E_T_ <> '*'
GROUP BY C5_EMISSAO, U7_COD, U7_NOME 
ORDER BY C5_EMISSAO, U7_COD
*/

/* PROCESSA VALORES DO CRISTINA */
QRY5 := " SELECT C5_EMISSAO, U7_COD, U7_NOME, SUM(C6_VALOR) VALOR"
QRY5 += " FROM " + RetSQLName("SC5") + ", " + RetSQLName("SU7") + ", " + RetSQLName("SC6")
QRY5 += " WHERE C5_EMISSAO BETWEEN '" + DTOS(MV_PAR01) + "' AND '" + DTOS(MV_PAR02) + "'"
QRY5 += " AND C5_TIPO = 'N'"
QRY5 += " AND C5_OPERADO = U7_COD"
QRY5 += " AND U7_COD = '000015'"
QRY5 += " AND C5_NUM = C6_NUM"
QRY5 += " AND " + RetSQLName("SC5") + ".D_E_L_E_T_ = ''"
QRY5 += " AND " + RetSQLName("SC6") + ".D_E_L_E_T_ = ''"
QRY5 += " AND " + RetSQLName("SU7") + ".D_E_L_E_T_ = ''"
QRY5 += " GROUP BY C5_EMISSAO, U7_COD, U7_NOME"
QRY5 += " ORDER BY C5_EMISSAO, U7_COD"

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
TcQuery QRY5 NEW ALIAS "QRY5"         // Abre uma workarea com o resultado da query
DbSelectArea("QRY5")
QRY5->(dbGotop())

ProcRegua(350)
For _x := 1 to 300
	IncProc( "Processando quantidades da Cristina Urias... ")
Next

/*
SELECT C5_EMISSAO, U7_COD, U7_NOME, COUNT(C5_NUM) QUANTIDADE
FROM SU7010, SC5010
WHERE C5_EMISSAO BETWEEN '20030601' AND '20040331'
	AND C5_TIPO = 'N'
	AND C5_OPERADO = U7_COD
	AND U7_COD = '000015'
	AND SC5010.D_E_L_E_T_ <> '*'
	AND SU7010.D_E_L_E_T_ <> '*'
GROUP BY C5_EMISSAO, U7_COD, U7_NOME 
*/

/* PROCESSA QUANTIDADE DO CRISTINA */
QRY6 := " SELECT C5_EMISSAO, U7_COD, U7_NOME, COUNT(C5_NUM) QUANTIDADE"
QRY6 += " FROM " + RetSQLName("SC5") + ", " + RetSQLName("SU7")
QRY6 += " WHERE C5_EMISSAO BETWEEN '" + DTOS(MV_PAR01) + "' AND '" + DTOS(MV_PAR02) + "'"
QRY6 += " AND C5_TIPO = 'N'"
QRY6 += " AND C5_OPERADO = U7_COD"
QRY6 += " AND U7_COD = '000015'"
QRY6 += " AND " + RetSQLName("SC5") + ".D_E_L_E_T_ = ''"
QRY6 += " AND " + RetSQLName("SU7") + ".D_E_L_E_T_ = ''"
QRY6 += " GROUP BY C5_EMISSAO, U7_COD, U7_NOME"
QRY6 += " ORDER BY C5_EMISSAO, U7_COD"

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
TcQuery QRY6 NEW ALIAS "QRY6"         // Abre uma workarea com o resultado da query
DbSelectArea("QRY6")
QRY6->(dbGotop())

ProcRegua(350)
For _x := 1 to 350
	IncProc( "Fim do Processando... ")
Next
Return(.T.)



//////////////////////////////////////////////////////////////////////
Static Function RodaRel47()
Local cArq		:= ""
Local cCampos	:= ""
Local nHandle	:= ""
Local cWorkFlow:= "N"
Local nTamMes	:= 0
Local _cTitulo	:= "Posição de Pedidos por Operador(a)"
Local _cDesc1	:= "              ( Call Center período de " + Substr(DtoS(MV_PAR01),7,2) + "/" + Substr(DtoS(MV_PAR01),5,2) + "/" + Substr(DtoS(MV_PAR01),1,4) +" até " + Substr(DtoS(MV_PAR02),7,2)+ "/" + Substr(DtoS(MV_PAR02),5,2) + "/" + Substr(DtoS(MV_PAR02),1,4) + " )"
Local _cDesc2	:= "      Emissão       Código-Operador(a)                      Valor  Quantidade"

*         1         2         3         4         5         6         7         8         9         0         1         2         3         4         5         6         7         8         9         0
*0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901
*              ( Call Center período de DD/MM/AAAA até DD/MM/AAAA )
*                 ( Apoio período de DD/MM/AAAA até DD/MM/AAAA )
*      Emissão       Código-Operador(a)                      Valor  Quantidade
*--------------------------------------------------------------------------------
*      DD/MM/AAAA    999999-XXXXXXXXXXXXXXXXXXXX        999.999,99        9999
*--------------------------------------------------------------------------------

DbSelectArea("QRY2")
QRY2->(DbGoTop())
DbSelectArea("QRY1")
QRY1->(DbGoTop())

SetRegua(1000)

Do While QRY1->(!Eof())

	IncRegua( "Imprimindo operador(a) Call Center: " + QRY1->U7_COD + "-" + AllTrim(QRY1->U7_NOME) )

	If lAbortPrint
		@ li+1,00 PSAY "*** CANCELADO PELO OPERADOR ***"
		Exit
	Endif
	
	If li > 56
		li := u_MYCabec(_cTitulo,_cDesc1,_cDesc2,nHandle,cWorkFlow)
	EndIf

	@ li,006 PSay SubStr(QRY1->C5_EMISSAO,7,2) + "/" + SubStr(QRY1->C5_EMISSAO,5,2) + "/" + SubStr(QRY1->C5_EMISSAO,1,4)
	@ li,020 PSay QRY1->U7_COD + "-" + AllTrim(QRY1->U7_NOME)
	@ li,055 PSay Transform(QRY1->VALOR, "@E 999,999.99")
	@ li,073 PSay Transform(QRY2->QUANTIDADE, "@E 99")
	li++                    
	
	QRY1->(DbSkip())
	QRY2->(DbSkip())
EndDo

DbSelectArea("QRY6")
QRY6->(DbGoTop())
DbSelectArea("QRY5")
QRY5->(DbGoTop())
DbSelectArea("QRY4")
QRY4->(DbGoTop())
DbSelectArea("QRY3")
QRY3->(DbGoTop())

SetRegua(1000)
li := 80
_cDesc1	:= "                 ( Apoio período de  " + Substr(DtoS(MV_PAR01),7,2) + "/" + Substr(DtoS(MV_PAR01),5,2) + "/" + Substr(DtoS(MV_PAR01),1,4) + " até " + Substr(DtoS(MV_PAR02),7,2)+ "/" + Substr(DtoS(MV_PAR02),5,2) + "/" + Substr(DtoS(MV_PAR02),1,4) + " )"

Do While QRY3->(!Eof())

	IncRegua( "Imprimindo operador(a) Apoio: " + QRY3->U7_COD + "-" + AllTrim(QRY3->U7_NOME) )

	If lAbortPrint
		@ li+1,00 PSAY "*** CANCELADO PELO OPERADOR ***"
		Exit
	Endif
	
	If li > 56
		li := u_MYCabec(_cTitulo,_cDesc1,_cDesc2,nHandle,cWorkFlow)
	EndIf

	@ li,006 PSay SubStr(QRY3->C5_EMISSAO,7,2) + "/" + SubStr(QRY3->C5_EMISSAO,5,2) + "/" + SubStr(QRY3->C5_EMISSAO,1,4)
	@ li,020 PSay QRY3->U7_COD + "-" + AllTrim(QRY3->U7_NOME)
	@ li,055 PSay Transform(QRY3->VALOR, "@E 999,999.99")
	@ li,073 PSay Transform(QRY4->QUANTIDADE, "@E 99")
	li++

	If QRY5->C5_EMISSAO == QRY3->C5_EMISSAO
		If li > 56
			li := u_MYCabec(_cTitulo,_cDesc1,_cDesc2,nHandle,cWorkFlow)
		EndIf
		@ li,006 PSay SubStr(QRY5->C5_EMISSAO,7,2) + "/" + SubStr(QRY5->C5_EMISSAO,5,2) + "/" + SubStr(QRY5->C5_EMISSAO,1,4)
		@ li,020 PSay QRY5->U7_COD + "-" + AllTRim(QRY5->U7_NOME)
		@ li,055 PSay Transform(QRY5->VALOR, "@E 999,999.99")
		@ li,073 PSay Transform(QRY6->QUANTIDADE, "@E 99")
		li++     
		QRY5->(DbSkip())
		QRY6->(DbSkip())
	EndIf

	QRY3->(DbSkip())
	QRY4->(DbSkip())
EndDo

dbSelectArea("QRY1")
QRY1->(dbCloseArea())
dbSelectArea("QRY2")
QRY2->(dbCloseArea())
dbSelectArea("QRY3")
QRY3->(dbCloseArea())
dbSelectArea("QRY4")
QRY4->(dbCloseArea())
dbSelectArea("QRY5")
QRY5->(dbCloseArea())
dbSelectArea("QRY6")
QRY6->(dbCloseArea())
Return(.T.)


/////////////////////////////////////////////////////////////////////////////
Static Function AjustaSX1(cPerg)
_sAlias := Alias()
dbSelectArea("SX1")
dbSetOrder(1)

aRegs:={}

//------------ Grupo/Ordem/Pergunta/PERGING/PERGESP/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05/F3

aAdd(aRegs,{cPerg,"01","Data de         ?","","","mv_ch1","D",8,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"02","Data ate        ?","","","mv_ch2","D",8,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","",""})

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
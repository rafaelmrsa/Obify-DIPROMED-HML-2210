/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Funcao    ³ DIPA024 ³ Autor ³ Rafael de Campos Falco  ³ Data ³ 14/04/2004 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Digita dados para compor NF de Amostra                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Especifico DIPROMED                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/                  

#include "rwmake.ch"
#Include "colors.ch"
#INCLUDE "TBICONN.CH"
#INCLUDE "FILEIO.CH"

User Function DIPA024()
Local _xAlias  := GetArea()
Local _aCpos	:= {}

Local cArqInd
Local cChave := ""
Local cFiltro := ""
Local nIndex

Private QRY1 		:= ""
Private cCadastro := "Digitacao da NF de Amostra"

PRIVATE aRotina := { ;
{"Pesquisar"  ,"AxPesqui"  , 0 , 1},;
{"Visualiza"  ,"AxVisual"  , 0 , 2},;
{"Alteração"  ,"U_RemAlt"  , 0 , 3},;
{"Lista Prod" ,"U_RemLis"  , 0 , 4}}

Private bFiltraBrw := {|| Nil}
U_DIPPROC(ProcName(0),U_DipUsr()) // JBS 05/10/2005 - Gravando o nome do Programa no SZU
If AllTrim(Upper(U_DipUsr())) <> 'FALCO'
	MSGSTOP("Voce nao é o Falco","Usuario sem autorizacao!")
	Return
EndIf

/*
SELECT F2_DOC, F2_EMISSAO, F2_DATREM, F2_EXPREM, D2_TES, F4_TEXTO
FROM SF2010, SD2010, SF4010
WHERE F2_EMISSAO BETWEEN '20040101' AND '20040401'
AND F2_TIPO = 'N'
AND F2_EXPREM = ''
AND F2_DOC = D2_DOC
AND D2_TES = F4_CODIGO
AND LEFT(F4_TEXTO,7) = 'AMOSTRA'
AND SF2010.D_E_L_E_T_ <> '*'
AND SD2010.D_E_L_E_T_ <> '*'
AND SF4010.D_E_L_E_T_ <> '*'
ORDER BY F2_EMISSAO


QRY1 := " SELECT F2_DOC, F2_SERIE, F2_EMISSAO, F2_DATREM, F2_EXPREM, D2_TES, F4_TEXTO"
QRY1 += " FROM " + RetSQLName("SF2") + ", " + RetSQLName("SD2") + ", " + RetSQLName("SF4")
QRY1 += " WHERE F2_EMISSAO BETWEEN '20040101' AND '20040401'"
QRY1 += " AND F2_TIPO = 'N'"
QRY1 += " AND F2_EXPREM = ''"
QRY1 += " AND F2_DOC = D2_DOC"
QRY1 += " AND D2_TES = F4_CODIGO"
QRY1 += " AND LEFT(F4_TEXTO,7) = 'AMOSTRA'"
QRY1 += " AND SF2010.D_E_L_E_T_ <> '*'"
QRY1 += " AND SD2010.D_E_L_E_T_ <> '*'"
QRY1 += " AND SF4010.D_E_L_E_T_ <> '*'"
QRY1 += " ORDER BY F2_EMISSAO"

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
DbCommitAll()
TcQuery QRY1 NEW ALIAS "QRY1"         // Abre uma workarea com o resultado da query


DbSelectArea("QRY1")
QRY1->(dbGotop())

aadd(_aCpos,{"Nota Fiscal"   ,"F2_DOC"    })
aadd(_aCpos,{"Emissao"       ,"F2_EMISSAO"})
aadd(_aCpos,{"TES"           ,"D2_TES"    })
aadd(_aCpos,{"Descricao TES" ,"F4_TEXTO"  })
aadd(_aCpos,{"Data Reembolso","F2_DATREM" })
aadd(_aCpos,{"Explica Reemb.","F2_EXPREM" })*/

//MBrowse(nLinha1,nColuna1,nLinha2,ncoluna2,cAlias,aFixe,cCpo,nPar,cCor,nOpc)
cArqInd := CriaTrab(,.F.)
cChave  := "F2_DOC+F2_SERIE+dtos(F2_EMISSAO)+dtos(F2_DATREM)+F2_EXPREM+D2_TES+F4_TEXTO"
cFiltro := "F2_EMISSAO >= '20040101' .AND. F2_EMISSAO <= '20040401'"
cFiltro += "F2_TIPO = 'N'"
cFiltro += "F2_EXPREM = ''"
cFiltro += "F2_DOC = D2_DOC"
cFiltro += "D2_TES = F4_CODIGO"
cFiltro += "LEFT(F4_TEXTO,7) = 'AMOSTRA'"

IndRegua("SF2",cArqInd,cChave,,cFiltro,"Selecionando Registros...")
nIndex  := RetIndex("SF2")
MBrowse(06,01,22,75,"SF2",,,,,)
dbSelectArea("SF2")
dbSetIndex(cArqInd+OrdBagExt())
dbSetOrder(nIndex+1)
dbGoTop()

RestArea(_xAlias)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Funcao    ³ RemAlt ³ Autor ³ Rafael de Campos Falco ³ Data ³ 14/04/2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Alteração do reembolso                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ RemAlt                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Especifico DIPROMED                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function RemAlt(cAlias,nReg)
Local dDat_Rem := dDataBase
Local cExp_Rem := Space(256)

Begin Transaction
Dbselectarea("SF2")
DbGoTo(nReg)

@ 126,000 To 395,280 DIALOG oDlg TITLE OemToAnsi("      NF - " + SF2->F2_DOC)
@ 008,010 Say "N.Fiscal-Série: " + SF2->F2_DOC + "-" + SF2->F2_SERIE
@ 020,010 Say "Emissão: " + SubStr(SF2->F2_EMISSAO,7,2) + "/" + SubStr(SF2->F2_EMISSAO,5,2) + "/" + SubStr(SF2->F2_EMISSAO,1,4)
@ 035,010 Say "Dt. Reembolso: "
@ 035,055 Get dDat_Rem Size 33,20 Picture "@!" Valid !Empty(dDat_Rem)
@ 050,010 Say "Explic. Reemb.: "
@ 050,055 Get cExp_Rem Size 80,20 Picture "@!" Valid !Empty(cExp_Rem)
@ 065,070 BmpButton Type 1 Action (Ok(dDat_Rem, cExp_Rem),Close(oDlg))
@ 065,100 BmpButton Type 2 Action Close(oDlg)
ACTIVATE DIALOG oDlg Centered
End Transaction
Return

Static Function Ok(dDat_Rem, cExp_Rem)
RecLock("SF2",.F.)
SF2->F2_DATREM := dDat_Rem
SF2->F2_EXPREM := cExp_Rem
MsUnlock()
// Eriberto 13/02/2006 Close(oDlg)
Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Funcao    ³ RemLis ³ Autor ³ Rafael de Campos Falco ³ Data ³ 14/04/2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Listagem das NF de Amostra                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ RemLis                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Especifico DIPROMED                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function RemLis() 

Local _xArea		:= GetArea()
Local titulo		:=  OemTOAnsi("Listagem das NF de Amostra",72)
Local cDesc1		:= (OemToAnsi("Este programa tem como objetivo emitir um relat¢rio",72))
Local cDesc2		:= (OemToAnsi("informando as NF de Amostra.",72))
Local cDesc3		:= (OemToAnsi("Conforme parâmetros.",72))

Private aReturn	:= {"Bco A4", 1,"Administracao", 1, 2, 1,"",1}
Private nomeprog	:= "REMLIS"
Private cPerg		:= "REMLIS"
Private wnrel		:= "REMLIS"
Private cString	:= "SF2"
Private tamanho	:= "G"
Private limite		:= 220
Private lEnd		:= .F.
Private nLastKey	:= 0
Private li			:= 67
Private m_pag		:= 1

AjustaSX1(cPerg)    //PergFre()             // Verifica perguntas. Se nao existe INCLUI

If !Pergunte(cPerg,.T.)    // Solicita parametros
	Return
EndIf

wnrel := SetPrint(cString,wnrel,cPerg,Titulo,cDesc1,cDesc2,cDesc3,.f.,,.f.,tamanho,,.f.,,,,,)

If nLastKey == 27
	Return
Endif

SetDefault(aReturn,cString)

RptStatus({|lEnd| RodaFre()},Titulo)

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
Static Function RodaFre()

Local nTotFre	:= 0
Local nTotDip	:= 0
Local nTotDif	:= 0
Local cNomFor  := ""
Local nHandle	:= ""
Local cWorkFlow:= "N"


/*
SELECT F2_FILIAL, F2_DOC, F2_SERIE, F2_EMISSAO, F2_FRETE, F2_TRANSP, F2_VEND1, F2_TPFRETE, F2_NROCON, F2_FRTDIP, F2_VALBRUT, F2_VALMERC, A4_COD, A4_NREDUZ
FROM SF2010, SA4010
WHERE F2_NROCON <> ''
AND F2_FRTDIP <> 0
AND F2_EMISSAO BETWEEN '20040301' AND '20040316'
AND F2_TRANSP = '000150'
AND F2_TRANSP = A4_COD
AND SF2010.D_E_L_E_T_ <> '*'
AND SA4010.D_E_L_E_T_ <> '*'
ORDER BY F2_DOC, F2_EMISSAO
*/

QRY1 := " SELECT F2_FILIAL, F2_DOC, F2_SERIE, F2_EMISSAO, F2_FRETE, F2_TRANSP, F2_VEND1, F2_TPFRETE, F2_NROCON, F2_FRTDIP, F2_VALBRUT, F2_VALMERC, A4_COD, A4_NOME "
QRY1 += " FROM " + RetSQLName("SF2")+', '+ RetSQLName("SA4")
QRY1 += " WHERE F2_EMISSAO BETWEEN '"+ DTOS(MV_PAR02) +"' AND '"+ DTOS(MV_PAR03) +"'"
If !Empty(MV_PAR01)
	QRY1 += " AND F2_TRANSP = '"+ MV_PAR01 +"'"
EndIf	
QRY1 += " AND F2_NROCON <> ''"
QRY1 += " AND F2_TRANSP = A4_COD"
QRY1 += " AND " + RetSQLName("SF2")+".D_E_L_E_T_ <> '*'"
QRY1 += " AND " + RetSQLName("SA4")+".D_E_L_E_T_ <> '*'"
QRY1 += " ORDER BY F2_DOC, F2_EMISSAO"

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
DbCommitAll()
TcQuery QRY1 NEW ALIAS "QRY1"         // Abre uma workarea com o resultado da query

DbSelectArea("QRY1")

_cTitulo := "Listagem de Frete" 
_cDesc1  := "Transportadora: " + QRY1->A4_COD + "-" +AllTrim(QRY1->A4_NOME)
_cDesc2  := "           N.Fiscal-Série         Emissão             Conhecimento     Frete NF (A)         Frt.Dipromed (B)         Diferença (A-B)         Valor Bruto         Vlr.Mercadoria     Tipo Frete"

SetRegua(70)
For _x := 1 to 10
	IncRegua( "Imprimindo... " + QRY1->F2_DOC )
Next
*                                                                                                    1                                                                                                   2
*          1         2         3         4         5         6         7         8         9         0         1         2         3         4         5         6         7         8         9         0
*012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
*dipr028/v.AP6 6.09 Listagem de Fretes ( 999999-XXXXXXXXXXXXXXXXXXXX )
*---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*           N.Fiscal-Série         Emissão             Conhecimento     Frete NF (A)         Frt.Dipromed (B)         Diferença (A-B)         Valor Bruto         Vlr.Mercadoria     Tipo Frete
*           999999  -XXX           DD/MM/AAAA          999999             999.999,99               999.999,99              999.999,99          999.999,99             999.999,99     Incluso
*---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*Total Geral...........................................................:  999.999,99               999.999,99              999.999,99                                                FOB/CIF
*---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

Do While QRY1->(!Eof())
	If lAbortPrint
		@ li+1,00 PSAY "*** CANCELADO PELO OPERADOR ***"
		Exit
	Endif
	
	IncRegua( "Imprimindo... " + QRY1->F2_DOC )
	
	If li > 56
		li := u_MYCabec(_cTitulo,_cDesc1,_cDesc2,nHandle,cWorkFlow)
//		@ li,000 Psay Replicate('-',limite)
	EndIf
	@ li,011 PSay QRY1->F2_DOC+"  -"+QRY1->F2_SERIE 
	@ li,034 PSay SubStr(QRY1->F2_EMISSAO,7,2)+"/"+SubStr(QRY1->F2_EMISSAO,5,2)+"/"+SubStr(QRY1->F2_EMISSAO,1,4)
	@ li,054 PSay QRY1->F2_NROCON
	@ li,073 PSay QRY1->F2_FRETE PICTURE "@E 999,999.99"
	@ li,098 PSay QRY1->F2_FRTDIP PICTURE "@E 999,999.99"
	@ li,122 PSay (QRY1->F2_FRETE - QRY1->F2_FRTDIP) PICTURE "@E 999,999.99"
	@ li,142 PSay QRY1->F2_VALBRUT PICTURE "@E 999,999.99"
	@ li,165 PSay QRY1->F2_VALMERC PICTURE "@E 999,999.99"
	
	If QRY1->F2_TPFRETE == "I"
		cTip_Fre := "Incluso"
	ElseIf QRY1->F2_TPFRETE == "C"	
		cTip_Fre := "CIF"
	ElseIf QRY1->F2_TPFRETE == "F"
		cTip_Fre := "FOB"	
	Else
		cTip_Fre := "EM BRANCO"	
	EndIf	
	
	@ li,180 PSay cTip_Fre 
	nTotFre += QRY1->F2_FRETE
	nTotDip += QRY1->F2_FRTDIP
	nTotDif += (QRY1->F2_FRETE - QRY1->F2_FRTDIP)
	li++
	QRY1->(DbSkip())
EndDo

If li > 56
	li := u_MYCabec(_cTitulo,_cDesc1,_cDesc2,nHandle,cWorkFlow)
	li+=5
EndIf

@ li,000 Psay Replicate('*',limite)
li++
@ li,000 PSay "Total Geral...........................................................:  " + Transform(nTotFre,"@E 999,999.99") +Space(15)+ Transform(nTotDip,"@E 999,999.99") +Space(14)+ Transform(nTotDif,"@E 999,999.99")
li++
@ li,000 Psay Replicate('*',limite)
li+=2

dbSelectArea("QRY1")
QRY1->(dbCloseArea())

Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Funcao    ³PergFre  ³ Autor ³Rafael de Campos Falco ³ Data ³ 16/03/2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Validação das pergunta da emissão do relatório de fretes   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ PergFre                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Especifico DIPROMED                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function AjustaSX1(cPerg)   //PergFre()
_sAlias := Alias()
dbSelectArea("SX1")
dbSetOrder(1)                                                                    

cPerg := PADR(cPerg, Len(SX1->X1_GRUPO)," " ) // Incluido por Sandro em 18/11/09.

aRegs:={}

//------------ Grupo/Ordem/Pergunta/PERGING/PERGESP/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05/F3

AADD(aRegs,{cPerg,"01","Inf. Data Inicial  ","","","mv_ch1","D",8,0,1,"G","","MV_PAR01","","","","","","","","","","","","","",""})
AADD(aRegs,{cPerg,"02","Inf. Data Final    ","","","mv_ch2","D",8,0,1,"G","","MV_PAR02","","","","","","","","","","","","","",""})

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


////////////fim do programa

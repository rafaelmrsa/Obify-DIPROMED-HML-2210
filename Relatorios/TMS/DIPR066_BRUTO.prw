#INCLUDE "PROTHEUS.CH"
/*/
+---------------------------------------------------------------------------+
|  Programa  | DIPR066 |Autor  |Maximo Canuto          | Data |  13/01/09   |
+---------------------------------------------------------------------------+
|  Descricao | Emissão de fatura de Frete baseado no DT6                    |
+---------------------------------------------------------------------------+
|  Uso       | TMS / Financeiro                                             |
+---------------------------------------------------------------------------+
/*/

#include "rwmake.ch"
User Function DIPR066TST()

Local nTPag     := SE1->(FCount())
Local nLin      := 0
Local cQuery    := ""
Local cAliasQry := ""
Local cCodUsr   := RetCodUsr()

/*If cCodUsr != "000022" .And. cCodUsr != "000038" .And. cCodUsr != "000001"
	MsgAlert("Usuario nao autorizado")
	Return
EndIf*/

SetPrvt("DV_NNUM,DV_BARRA,CBARRA,LINEDIG,NFI,NFF")
SetPrvt("SERIE,BANCO,NUMBOLETA,NDIGITO,PEDACO,CHAVE")
SetPrvt("FATORVCTO,B_CAMPO,CHAVE,NCONT,CCAMPO,I")
SetPrvt("NVAL,DEZENA,RESTO,NCONT,CPESO,RESULT")
SetPrvt("ARQ,CGRUPO,PERG")
SetPrvt("TIT,DESC1,DESC2,DESC3,ORDEM")
SetPrvt("TAMANHO,FILTIMP,ARETURN,AINFO,NLASTKEY,CSTRING")
SetPrvt("WNREL,TELA,BANCO,SERIE,NFI,NFF")
SetPrvt("CSAVSCR1,CSAVCUR1,CSAVROW1,CSAVCOL1,CCAMPO,NDIGITO")
SetPrvt("NCONT,XI,NVAL,CPESO,RESTO,APERGUNTAS")
SetPrvt("NXZ,NXY,cgrupo,xrow,Nvia,Nnumero")

Private cObs1 := ""
Private cObs2 := ""
Private cVenc := ""

U_DIPPROC(ProcName(0),U_DipUsr()) // MCVN - 22/01/2009

M->DV_NNUM   := SPACE(1)
M->DV_BARRA  := SPACE(1)
M->cBARRA    := ""
M->LineDig   := ""
M->NumBoleta := ""
M->nDigito   := ""
M->Pedaco    := ""

//Paramentros de Impressao
M->NFi       := Space(6)
M->NFf       := Space(6)
M->Serie     := Space(3)
M->Banco     := Space(3)
M->Ag        := Space(5)
M->CC        := Space(10)

//Cadastro de Clientes
DbSelectArea("SA1")
DbSetOrder(1)

@ 00,00 TO 250,380 DIALOG oDlgX TITLE "Impressão Fatura de Frete"
@ 05,05 TO 120,185 TITLE " Parametros "

@ 20,008 SAY "Prefixo do Título"
@ 35,008 SAY "Título Inicial"
@ 50,008 SAY "Título Final"


@ 20,090 GET M->Serie  PICTURE "@!"         //VALID !Empty(M->Serie)
@ 35,090 GET M->NFi    PICTURE "@E 999999"  //VALID !Empty(M->NFi)
@ 50,090 GET M->NFf    PICTURE "@E 999999"  //VALID !Empty(M->NFf)


@ 100,100 BMPBUTTON TYPE 01 ACTION BoletaOK()
@ 100,140 BMPBUTTON TYPE 02 ACTION Close(oDlgX)

ACTIVATE  DIALOG oDlgX CENTER

Return


Static Function BoletaOK()

Local aDoc     := {}
Local aDocF    := {}
Local aDocDR   := {}
Local nCont    := 0
Local aDig     := {}
Local nSoma    := 0
Local nResto   := 0
Local nDigNum  := 0
Local nDig2    := 0
Local cLogoFAT := "emovere.bmp"
Local nCol     := "A"
Local nCnt2    := 0  
Local nBoxVIni := 1150
Local nBoxVFim := 1200
Local nConV    := 1100    
//Local nLimite  := 133//Giovani Zago 11/11/11
//Local nLimite  := 43//Andre Mendes - Obify 26/01/22
Local nLimite	:= 55//Rafael Rosa Obify - 08/06/22
Local nPag     := 1
Local nValICM	:= 0//Rafael Rosa Obify - 09/06/22
Local nAliqICM	:= 0//Rafael Rosa Obify - 22/06/22
Local CIFMerc	:= 0//Rafael Rosa Obify - 22/06/22
Local CIFBC		:= 0//Rafael Rosa Obify - 22/06/22
Local CIFICMS	:= 0//Rafael Rosa Obify - 22/06/22
Local CIFFRETE	:= 0//Rafael Rosa Obify - 22/06/22
Local FOBMerc	:= 0//Rafael Rosa Obify - 22/06/22
Local FOBBC		:= 0//Rafael Rosa Obify - 22/06/22
Local FOBICMS	:= 0//Rafael Rosa Obify - 22/06/22
Local FOBFRETE	:= 0//Rafael Rosa Obify - 22/06/22
Local DRMerc	:= 0//Rafael Rosa Obify - 06/07/22
Local DRBC		:= 0//Rafael Rosa Obify - 06/07/22
Local DRICMS	:= 0//Rafael Rosa Obify - 06/07/22
Local DRFRETE	:= 0//Rafael Rosa Obify - 06/07/22
Local nTotICM7	:= 0
Local nTotICM12	:= 0
Local nTotICM18	:= 0
Local nTotICMCIF:= 0
Local nTotICMFOB:= 0
Local nTotICMDR:= 0

Local nTotNotas := 0 // Andre Mendes - Obify 02/02/22


Close(oDlgX)

//Titulos dos Campos
oFont1 :=     TFont():New("Arial"      		,09,08,,.F.,,,,,.F.)
//Conteudo dos Campos
oFont2 :=     TFont():New("Arial"      		,09,10,,.F.,,,,,.F.)
//Nome do Banco
oFont3Bold := TFont():New("Arial Black"		,09,16,,.T.,,,,,.F.)
//Dados do Recibo de Entrega
oFont4 := 	  TFont():New("Arial"      		,09,12,,.T.,,,,,.F.)
//Codigo de Compensação do Banco
oFont5 := 	  TFont():New("Arial"      		,09,18,,.T.,,,,,.F.)
//Codigo de Compensação do Banco
oFont6 := 	  TFont():New("Arial"      	    ,09,14,,.T.,,,,,.F.)
//Conteudo dos Campos em Negrito
oFont7 := 	  TFont():New("Arial"           ,09,10,,.T.,,,,,.F.)
//Dados do Cliente
oFont8 := 	  TFont():New("Arial"           ,09,09,,.F.,,,,,.F.)
//Linha Digitavel
oFont9 := 	  TFont():New("Times New Roman" ,09,14,,.T.,,,,,.F.)

//Rafael Rosa Obify - 02/06/22
oFont10 := 	  TFont():New("Arial"      		,09,09,,.F.,,,,,.F.)
oFont11 := 	  TFont():New("Arial"      		,09,08,,.F.,,,,,.F.)
oFont12 :=    TFont():New("Arial"       	,09,10,,.T.,,,,,.F.)
oFont13 := 	  TFont():New("Arial"      		,09,07,,.F.,,,,,.F.)
oFont14 := 	  TFont():New("Arial"      		,09,06,,.F.,,,,,.F.)

oPrn:=TAvPrinter():New()

//Cadastro de Contas a Receber
//Posicionar no titulo Incial do Paramentro
DbSelectArea("SE1")
DbSetOrder(1)
DbGoTop()
DbSeek(xFilial("SE1")+ M->Serie + M->NFi)

//--Verifica todos os CTRCs perterncentes a esta fatura
cAliasQry := GetNextAlias()
//cQuery := "SELECT DT6_DATEMI, DT6_DOC, DT6_VALTOT * DTC_PESO/ DT6_PESO AS DT6_VALTOT, DT6_DECRES, DTC_NUMNFC, DTC_VALOR, ROUND(DT6_VALTOT * DTC_PESO/ DT6_PESO / DTC_VALOR*100,2) AS PERC  "

cQuery := "SELECT DT6_DATEMI, DT6_DOC, DT6_VALTOT * DTC_VALOR/ (SELECT "
cQuery += "			SUM(DTC_02.DTC_VALOR)  "
cQuery += "	FROM  "
cQuery += "		"+RetSqlName("DTC")+ " DTC_02 "
cQuery += "	WHERE "
cQuery += "		DTC_02.DTC_FILIAL	= DT6.DT6_FILIAL	AND "
cQuery += "		DTC_02.DTC_FILORI	= DT6.DT6_FILORI	AND "
cQuery += "		DTC_02.DTC_LOTNFC	= DT6.DT6_LOTNFC	AND "
cQuery += "		DTC_02.DTC_FILDOC	= DT6.DT6_FILDOC	AND "
cQuery += "		DTC_02.DTC_DOC		= DT6.DT6_DOC		AND "
cQuery += "		DTC_02.DTC_SERIE	= DT6.DT6_SERIE		AND "
//Rafael Rosa Obify - 02/06/22 - Linha comentada
//cQuery += "		DTC_02.D_E_L_E_T_	= '') AS DT6_VALTOT, DT6_DECRES, DTC_NUMNFC, DTC_VALOR, ROUND(DT6_VALTOT * DTC_VALOR/ (SELECT  "
//Rafael Rosa Obify - 02/06/22 - Linha criada (adicionado os campos DT6_VALTOT, DT6_VALIMP, A1_NOME, A1_CGC, DTC_PESO e F3_ALIQICM)
cQuery += "		DTC_02.D_E_L_E_T_	= '') AS DT6_VALTOT, DT6_DECRES, DT6_PESO, DT6_VALTOT, DT6_VALIMP, A1_NOME, A1_CGC, F3_ALIQICM, DTC_PESO, DTC_NUMNFC, DTC_VALOR, ROUND(DT6_VALTOT * DTC_VALOR/ (SELECT  "
cQuery += "			SUM(DTC_02.DTC_VALOR)  "
cQuery += "	FROM  "
cQuery += "		"+RetSqlName("DTC")+ " DTC_02 "
cQuery += "	WHERE "
cQuery += "		DTC_02.DTC_FILIAL	= DT6.DT6_FILIAL	AND "
cQuery += "		DTC_02.DTC_FILORI	= DT6.DT6_FILORI	AND "
cQuery += "		DTC_02.DTC_LOTNFC	= DT6.DT6_LOTNFC	AND "
cQuery += "		DTC_02.DTC_FILDOC	= DT6.DT6_FILDOC	AND "
cQuery += "		DTC_02.DTC_DOC		= DT6.DT6_DOC		AND "
cQuery += "		DTC_02.DTC_SERIE	= DT6.DT6_SERIE		AND "
cQuery += "		DTC_02.D_E_L_E_T_	= '') / DTC_VALOR*100,2) AS PERC , "
cQuery += "	(SELECT  "
cQuery += "			SUM(DTC_02.DTC_VALOR)  "
cQuery += "	FROM  "
cQuery += "		"+RetSqlName("DTC")+ " DTC_02 "
cQuery += "	WHERE "
cQuery += "		DTC_02.DTC_FILIAL	= DT6.DT6_FILIAL	AND "
cQuery += "		DTC_02.DTC_FILORI	= DT6.DT6_FILORI	AND "
cQuery += "		DTC_02.DTC_LOTNFC	= DT6.DT6_LOTNFC	AND "
cQuery += "		DTC_02.DTC_FILDOC	= DT6.DT6_FILDOC	AND "
cQuery += "		DTC_02.DTC_DOC		= DT6.DT6_DOC		AND "
cQuery += "		DTC_02.DTC_SERIE	= DT6.DT6_SERIE		AND "
cQuery += "		DTC_02.D_E_L_E_T_	= '') AS TOTAL "

cQuery += " FROM "+RetSqlName("DT6")+ " DT6 "
cQuery += "INNER JOIN "
cQuery += " "+RetSqlName("DTC")+ " DTC ON "
cQuery += "		DTC.DTC_FILIAL	= DT6.DT6_FILIAL	AND "
cQuery += "		DTC.DTC_FILORI	= DT6.DT6_FILORI	AND "
cQuery += "		DTC.DTC_LOTNFC	= DT6.DT6_LOTNFC	AND "
cQuery += "		DTC.DTC_FILDOC	= DT6.DT6_FILDOC	AND "
cQuery += "		DTC.DTC_DOC		= DT6.DT6_DOC		AND "
cQuery += "		DTC.DTC_SERIE	= DT6.DT6_SERIE		AND "
cQuery += "		DTC.D_E_L_E_T_	= '' "
//Rafael Rosa Obify - 02/06/22 - Linhas adicionada - INICIO
cQuery += "INNER JOIN "
cQuery += " "+RetSqlName("SA1")+ " SA1 ON "
cQuery += "		SA1.A1_FILIAL	= DT6.DT6_FILIAL	AND "
cQuery += "		SA1.A1_COD		= DT6.DT6_CLIDES	AND "
cQuery += "		SA1.A1_LOJA		= DT6.DT6_LOJDES	AND "
cQuery += "		SA1.D_E_L_E_T_	= '' "
//Rafael Rosa Obify - 02/06/22 - Linhas adicionads - FIM
//Rafael Rosa Obify - 09/06/22 - Linhas adicionada - INICIO
cQuery += "INNER JOIN "
cQuery += " "+RetSqlName("SF3")+ " SF3 ON "
 //Rafael Rosa Obify - 09/06/22 - Linha comentada
 //Verificar com Maximo pois a tabela SF3 trabalha em modo exclusivo, ja a DT6 nao
 //Passivo de perda na integridade do relacionamento entre as tabelas
//cQuery += "		SF3.F3_FILIAL	= DT6.DT6_FILIAL	AND "
cQuery += "		SF3.F3_NFISCAL	= DT6.DT6_DOC		AND "
cQuery += "		SF3.F3_SERIE	= DT6.DT6_SERIE		AND "
cQuery += "		SF3.F3_CLIEFOR	= DT6.DT6_CLIREM	AND "
cQuery += "		SF3.F3_LOJA		= DT6.DT6_LOJREM	AND "
cQuery += "		SF3.F3_EMISSAO	= DT6.DT6_DATEMI	AND "
cQuery += "		SF3.D_E_L_E_T_	= '' "
//Rafael Rosa Obify - 09/06/22 - Linhas adicionads - FIM
cQuery += " WHERE DT6.DT6_FILIAL = '" +xFilial("DT6")+ "'"
cQuery += "  AND DT6.DT6_PREFIX  = '" +SE1->E1_PREFIXO+ "'"
cQuery += "  AND DT6.DT6_TIPO    = '" +SE1->E1_TIPO+ "'"
cQuery += "  AND DT6.DT6_NUM     = '" +SE1->E1_NUM+ "'"
cQuery += "  AND DT6.DT6_TIPFRE  = '1'"
cQuery += "  AND DT6.D_E_L_E_T_  = ' '"
cQuery += "  ORDER BY  DT6_DATEMI, DT6_DOC"	//Ordenando por emissão + doc MCVN - 18/06/10
cQuery := ChangeQuery(cQuery)
	
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry)

TcSetField(cAliasQry,"DT6_DATEMI","D",8,0)

While (cAliasQry)->(!Eof())
	//Rafael Rosa Obify - 02/06/22 - Linha comentada
	//Aadd(aDoc,{(cAliasQry)->DT6_DATEMI, (cAliasQry)->DT6_DOC, (cAliasQry)->DT6_VALTOT, (cAliasQry)->DT6_DECRES, (cAliasQry)->DTC_NUMNFC, (cAliasQry)->DTC_VALOR, (cAliasQry)->PERC  })
	//Rafael Rosa Obify - 02/06/22 - Linha adicionada
	Aadd(aDoc,{(cAliasQry)->DT6_DATEMI, (cAliasQry)->DT6_DOC, (cAliasQry)->DT6_VALTOT, (cAliasQry)->DT6_DECRES, (cAliasQry)->DTC_NUMNFC, (cAliasQry)->DTC_VALOR, (cAliasQry)->PERC, (cAliasQry)->DT6_PESO, (cAliasQry)->DT6_VALTOT, (cAliasQry)->DT6_VALIMP, (cAliasQry)->A1_CGC + " - " + ALLTRIM((cAliasQry)->A1_NOME), (cAliasQry)->F3_ALIQICM })
	(cAliasQry)->(dbSkip())
EndDo
(cAliasQry)->(dbCloseArea())


//Rafael Rosa Obify - 22/06/22 - Linhas adicionadas - INICIO (EM TESTE)
cQuery    := ""
//--Verifica todos os CTRCs perterncentes a esta fatura
cAliasQry := GetNextAlias()
//cQuery := "SELECT DT6_DATEMI, DT6_DOC, DT6_VALTOT * DTC_PESO/ DT6_PESO AS DT6_VALTOT, DT6_DECRES, DTC_NUMNFC, DTC_VALOR, ROUND(DT6_VALTOT * DTC_PESO/ DT6_PESO / DTC_VALOR*100,2) AS PERC  "

cQuery := "SELECT DT6_DATEMI, DT6_DOC, DT6_VALTOT * DTC_VALOR/ (SELECT "
cQuery += "			SUM(DTC_02.DTC_VALOR)  "
cQuery += "	FROM  "
cQuery += "		"+RetSqlName("DTC")+ " DTC_02 "
cQuery += "	WHERE "
cQuery += "		DTC_02.DTC_FILIAL	= DT6.DT6_FILIAL	AND "
cQuery += "		DTC_02.DTC_FILORI	= DT6.DT6_FILORI	AND "
cQuery += "		DTC_02.DTC_LOTNFC	= DT6.DT6_LOTNFC	AND "
cQuery += "		DTC_02.DTC_FILDOC	= DT6.DT6_FILDOC	AND "
cQuery += "		DTC_02.DTC_DOC		= DT6.DT6_DOC		AND "
cQuery += "		DTC_02.DTC_SERIE	= DT6.DT6_SERIE		AND "
//Rafael Rosa Obify - 02/06/22 - Linha comentada
//cQuery += "		DTC_02.D_E_L_E_T_	= '') AS DT6_VALTOT, DT6_DECRES, DTC_NUMNFC, DTC_VALOR, ROUND(DT6_VALTOT * DTC_VALOR/ (SELECT  "
//Rafael Rosa Obify - 02/06/22 - Linha criada (adicionado os campos DT6_VALTOT, DT6_VALIMP, A1_NOME, A1_CGC, DTC_PESO e F3_ALIQICM)
cQuery += "		DTC_02.D_E_L_E_T_	= '') AS DT6_VALTOT, DT6_DECRES, DT6_PESO, DT6_VALTOT, DT6_VALIMP, A1_NOME, A1_CGC, F3_ALIQICM, DTC_PESO, DTC_NUMNFC, DTC_VALOR, ROUND(DT6_VALTOT * DTC_VALOR/ (SELECT  "
cQuery += "			SUM(DTC_02.DTC_VALOR)  "
cQuery += "	FROM  "
cQuery += "		"+RetSqlName("DTC")+ " DTC_02 "
cQuery += "	WHERE "
cQuery += "		DTC_02.DTC_FILIAL	= DT6.DT6_FILIAL	AND "
cQuery += "		DTC_02.DTC_FILORI	= DT6.DT6_FILORI	AND "
cQuery += "		DTC_02.DTC_LOTNFC	= DT6.DT6_LOTNFC	AND "
cQuery += "		DTC_02.DTC_FILDOC	= DT6.DT6_FILDOC	AND "
cQuery += "		DTC_02.DTC_DOC		= DT6.DT6_DOC		AND "
cQuery += "		DTC_02.DTC_SERIE	= DT6.DT6_SERIE		AND "
cQuery += "		DTC_02.D_E_L_E_T_	= '') / DTC_VALOR*100,2) AS PERC , "
cQuery += "	(SELECT  "
cQuery += "			SUM(DTC_02.DTC_VALOR)  "
cQuery += "	FROM  "
cQuery += "		"+RetSqlName("DTC")+ " DTC_02 "
cQuery += "	WHERE "
cQuery += "		DTC_02.DTC_FILIAL	= DT6.DT6_FILIAL	AND "
cQuery += "		DTC_02.DTC_FILORI	= DT6.DT6_FILORI	AND "
cQuery += "		DTC_02.DTC_LOTNFC	= DT6.DT6_LOTNFC	AND "
cQuery += "		DTC_02.DTC_FILDOC	= DT6.DT6_FILDOC	AND "
cQuery += "		DTC_02.DTC_DOC		= DT6.DT6_DOC		AND "
cQuery += "		DTC_02.DTC_SERIE	= DT6.DT6_SERIE		AND "
cQuery += "		DTC_02.D_E_L_E_T_	= '') AS TOTAL "

cQuery += " FROM "+RetSqlName("DT6")+ " DT6 "
cQuery += "INNER JOIN "
cQuery += " "+RetSqlName("DTC")+ " DTC ON "
cQuery += "		DTC.DTC_FILIAL	= DT6.DT6_FILIAL	AND "
cQuery += "		DTC.DTC_FILORI	= DT6.DT6_FILORI	AND "
cQuery += "		DTC.DTC_LOTNFC	= DT6.DT6_LOTNFC	AND "
cQuery += "		DTC.DTC_FILDOC	= DT6.DT6_FILDOC	AND "
cQuery += "		DTC.DTC_DOC		= DT6.DT6_DOC		AND "
cQuery += "		DTC.DTC_SERIE	= DT6.DT6_SERIE		AND "
cQuery += "		DTC.D_E_L_E_T_	= '' "
//Rafael Rosa Obify - 02/06/22 - Linhas adicionada - INICIO
cQuery += "INNER JOIN "
cQuery += " "+RetSqlName("SA1")+ " SA1 ON "
cQuery += "		SA1.A1_FILIAL	= DT6.DT6_FILIAL	AND "
cQuery += "		SA1.A1_COD		= DT6.DT6_CLIDES	AND "
cQuery += "		SA1.A1_LOJA		= DT6.DT6_LOJDES	AND "
cQuery += "		SA1.D_E_L_E_T_	= '' "
//Rafael Rosa Obify - 02/06/22 - Linhas adicionads - FIM
//Rafael Rosa Obify - 09/06/22 - Linhas adicionada - INICIO
cQuery += "INNER JOIN "
cQuery += " "+RetSqlName("SF3")+ " SF3 ON "
 //Rafael Rosa Obify - 09/06/22 - Linha comentada
 //Verificar com Maximo pois a tabela SF3 trabalha em modo exclusivo, ja a DT6 nao
 //Passivo de perda na integridade do relacionamento entre as tabelas
//cQuery += "		SF3.F3_FILIAL	= DT6.DT6_FILIAL	AND "
cQuery += "		SF3.F3_NFISCAL	= DT6.DT6_DOC		AND "
cQuery += "		SF3.F3_SERIE	= DT6.DT6_SERIE		AND "
cQuery += "		SF3.F3_CLIEFOR	= DT6.DT6_CLIREM	AND "
cQuery += "		SF3.F3_LOJA		= DT6.DT6_LOJREM	AND "
cQuery += "		SF3.F3_EMISSAO	= DT6.DT6_DATEMI	AND "
cQuery += "		SF3.D_E_L_E_T_	= '' "
//Rafael Rosa Obify - 09/06/22 - Linhas adicionads - FIM
cQuery += " WHERE DT6.DT6_FILIAL = '" +xFilial("DT6")+ "'"
cQuery += "  AND DT6.DT6_PREFIX  = '" +SE1->E1_PREFIXO+ "'"
cQuery += "  AND DT6.DT6_TIPO    = '" +SE1->E1_TIPO+ "'"
cQuery += "  AND DT6.DT6_NUM     = '" +SE1->E1_NUM+ "'"
cQuery += "  AND DT6.DT6_TIPFRE  = '2'"
cQuery += "  AND DT6.D_E_L_E_T_  = ' '"
cQuery += "  ORDER BY  DT6_DATEMI, DT6_DOC"	//Ordenando por emissão + doc MCVN - 18/06/10
cQuery := ChangeQuery(cQuery)
	
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry)

TcSetField(cAliasQry,"DT6_DATEMI","D",8,0)

While (cAliasQry)->(!Eof())
	//Rafael Rosa Obify - 02/06/22 - Linha comentada
	//Aadd(aDoc,{(cAliasQry)->DT6_DATEMI, (cAliasQry)->DT6_DOC, (cAliasQry)->DT6_VALTOT, (cAliasQry)->DT6_DECRES, (cAliasQry)->DTC_NUMNFC, (cAliasQry)->DTC_VALOR, (cAliasQry)->PERC  })
	//Rafael Rosa Obify - 02/06/22 - Linha adicionada
	Aadd(aDocF,{(cAliasQry)->DT6_DATEMI, (cAliasQry)->DT6_DOC, (cAliasQry)->DT6_VALTOT, (cAliasQry)->DT6_DECRES, (cAliasQry)->DTC_NUMNFC, (cAliasQry)->DTC_VALOR, (cAliasQry)->PERC, (cAliasQry)->DT6_PESO, (cAliasQry)->DT6_VALTOT, (cAliasQry)->DT6_VALIMP, (cAliasQry)->A1_CGC + " - " + ALLTRIM((cAliasQry)->A1_NOME), (cAliasQry)->F3_ALIQICM })
	(cAliasQry)->(dbSkip())
EndDo
(cAliasQry)->(dbCloseArea())

//Rafael Rosa Obify - 22/06/22 - Linhas adicionadas - FIM (EM TESTE)


//Rafael Rosa Obify - 22/06/22 - Linhas adicionadas - INICIO (EM TESTE)
cQuery    := ""
//--Verifica todos os CTRCs perterncentes a esta fatura
cAliasQry := GetNextAlias()
//cQuery := "SELECT DT6_DATEMI, DT6_DOC, DT6_VALTOT * DTC_PESO/ DT6_PESO AS DT6_VALTOT, DT6_DECRES, DTC_NUMNFC, DTC_VALOR, ROUND(DT6_VALTOT * DTC_PESO/ DT6_PESO / DTC_VALOR*100,2) AS PERC  "

cQuery := "SELECT DT6_1.DT6_FILDOC, DT6_1.DT6_DOC, DT6_1.DT6_SERIE, DT6_1.DT6_DATEMI,DTC_1.DTC_NUMNFC, DTC_1.DTC_SERNFC,"
cQuery += "DT6_2.DT6_PESO,SA1.A1_NOME, SA1.A1_CGC,DT6_2.DT6_DOC AS DOC_2, DT6_2.DT6_VALMER,SF3.F3_ALIQICM,"

cQuery += "DT6_1.DT6_VALTOT * DTC_1.DTC_VALOR / (SELECT SUM(DTC_2.DTC_VALOR)	FROM  "+RetSqlName("DTC")+ " DTC_2 "
cQuery += "WHERE DTC_2.DTC_FILIAL	= DT6_2.DT6_FILIAL	AND "
cQuery += "DTC_2.DTC_FILORI	= DT6_2.DT6_FILORI	AND "
cQuery += "DTC_2.DTC_LOTNFC	= DT6_2.DT6_LOTNFC	AND "
cQuery += "DTC_2.DTC_FILDOC	= DT6_2.DT6_FILDOC	AND "
cQuery += "DTC_2.DTC_DOC		= DT6_2.DT6_DOC		AND "
cQuery += "DTC_2.DTC_SERIE		= DT6_2.DT6_SERIE	AND "
cQuery += "DTC_2.D_E_L_E_T_	= '') AS DT6_VALTOT, "

cQuery += " ROUND(DT6_1.DT6_VALTOT * DTC_1.DTC_VALOR / (SELECT SUM(DTC_3.DTC_VALOR) FROM  DTC030 DTC_3 "
cQuery += "WHERE	DTC_3.DTC_FILIAL	= DT6_2.DT6_FILIAL AND "
cQuery += "DTC_3.DTC_FILORI	= DT6_2.DT6_FILORI AND "
cQuery += "DTC_3.DTC_LOTNFC	= DT6_2.DT6_LOTNFC AND "
cQuery += "DTC_3.DTC_FILDOC	= DT6_2.DT6_FILDOC AND "
cQuery += "DTC_3.DTC_DOC		= DT6_2.DT6_DOC AND "
cQuery += "DTC_3.DTC_SERIE		= DT6_1.DT6_SERIE AND "
cQuery += "DTC_3.D_E_L_E_T_	= '') / DTC_1.DTC_VALOR*100,2) AS PERC "

cQuery += "	FROM  "
cQuery += "		"+RetSqlName("DT6")+ " DT6_1 "

cQuery += "INNER JOIN "
cQuery += " "+RetSqlName("DTC")+ " DTC_1 ON "
cQuery += "		DTC_1.DTC_FILIAL		= DT6_1.DT6_FILIAL	AND "
cQuery += "		DTC_1.DTC_FILORI		= DT6_1.DT6_FILORI	AND "
cQuery += "		DTC_1.DTC_FILDOC		= DT6_1.DT6_FILDCO	AND "
cQuery += "		DTC_1.DTC_DOC			= DT6_1.DT6_DOCDCO	AND "
cQuery += "		DTC_1.DTC_SERIE			= DT6_1.DT6_SERDCO	AND "
cQuery += "		DTC_1.D_E_L_E_T_		= '' "

cQuery += "INNER JOIN "
cQuery += " "+RetSqlName("SA1")+ " SA1 ON "
cQuery += "		SA1.A1_FILIAL	= DT6_1.DT6_FILIAL	AND "
cQuery += "		SA1.A1_COD		= DT6_1.DT6_CLIDES	AND "
cQuery += "		SA1.A1_LOJA		= DT6_1.DT6_LOJDES	AND "
cQuery += "		SA1.D_E_L_E_T_	= '' "

cQuery += "INNER JOIN "
cQuery += " "+RetSqlName("SF3")+ " SF3 ON "
 //Verificar com Maximo pois a tabela SF3 trabalha em modo exclusivo, ja a DT6 nao
 //Passivo de perda na integridade do relacionamento entre as tabelas
//cQuery += "		SF3.F3_FILIAL	= DT6.DT6_FILIAL	AND "
cQuery += "		SF3.F3_NFISCAL	= DT6_1.DT6_DOC		AND "
cQuery += "		SF3.F3_SERIE	= DT6_1.DT6_SERIE	AND "
cQuery += "		SF3.F3_CLIEFOR	= DT6_1.DT6_CLIREM	AND "
cQuery += "		SF3.F3_LOJA		= DT6_1.DT6_LOJREM	AND "
cQuery += "		SF3.F3_EMISSAO	= DT6_1.DT6_DATEMI	AND "
cQuery += "		SF3.D_E_L_E_T_	= '' "

cQuery += "INNER JOIN "
cQuery += " "+RetSqlName("DT6")+ " DT6_2 ON "
cQuery += "		DT6_2.DT6_FILDOC	= DT6_1.DT6_FILDCO	AND "
cQuery += "		DT6_2.DT6_DOC		= DT6_1.DT6_DOCDCO	AND "
cQuery += "		DT6_2.DT6_SERIE 	= DT6_1.DT6_SERDCO	AND "
cQuery += "		DT6_2.D_E_L_E_T_	= '' 

cQuery += " WHERE DT6_1.DT6_FILIAL	= '" +xFilial("DT6")+ "'"
cQuery += "  AND DT6_1.DT6_PREFIX	= '" +SE1->E1_PREFIXO+ "'"
cQuery += "  AND DT6_1.DT6_TIPO		= '" +SE1->E1_TIPO+ "'"
cQuery += "  AND DT6_1.DT6_NUM		= '" +SE1->E1_NUM+ "'"
cQuery += "  AND DT6_1.DT6_DOCDCO	<> ''"
cQuery += "  AND DT6_1.D_E_L_E_T_	= ' '"
cQuery += "  ORDER BY  DT6_DATEMI, DT6_DOC"	//Ordenando por emissão + doc MCVN - 18/06/10
cQuery := ChangeQuery(cQuery)
	
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry)

TcSetField(cAliasQry,"DT6_DATEMI","D",8,0)


While (cAliasQry)->(!Eof())
	//Rafael Rosa Obify - 02/06/22 - Linha comentada
	//Aadd(aDoc,{(cAliasQry)->DT6_DATEMI, (cAliasQry)->DT6_DOC, (cAliasQry)->DT6_VALTOT, (cAliasQry)->DT6_DECRES, (cAliasQry)->DTC_NUMNFC, (cAliasQry)->DTC_VALOR, (cAliasQry)->PERC  })
	//Rafael Rosa Obify - 02/06/22 - Linha adicionada
	Aadd(aDocDR,{(cAliasQry)->DT6_FILDOC, (cAliasQry)->DT6_DOC, (cAliasQry)->DT6_SERIE, (cAliasQry)->DT6_DATEMI, (cAliasQry)->DTC_NUMNFC, (cAliasQry)->DTC_SERNFC, (cAliasQry)->DOC_2, (cAliasQry)->DT6_VALMER, (cAliasQry)->F3_ALIQICM, (cAliasQry)->DT6_VALTOT, (cAliasQry)->A1_CGC + " - " + ALLTRIM((cAliasQry)->A1_NOME), (cAliasQry)->DT6_PESO, (cAliasQry)->PERC })
	(cAliasQry)->(dbSkip())
EndDo
(cAliasQry)->(dbCloseArea())

//RAFAEL 30/06/2022 - FIM



//--Volta o Ponteiro para o Contas a Receber
dbSelectArea("SE1")

If !Found()
	MsgBox("Titulo não Encontrado, verifique os paramentros digitados!!")
	Return
Endif

oprn:Setup() //--Exibe Configuracoes da Impressao

While !Eof()
	
	If Val(SE1->E1_NUM) > Val(M->NFf) .or. SE1->E1_PREFIXO != M->Serie
		Exit
	Endif
	
   cVenc := Substr(DTOS(SE1->E1_VENCTO), 7, 2) + "/" + Substring(DTOS(SE1->E1_VENCTO), 5, 2) + "/" + Substring(DTOS(SE1->E1_VENCTO), 1, 4)
   cEmis := Substr(DTOS(SE1->E1_EMISSAO), 7, 2) + "/" + Substring(DTOS(SE1->E1_EMISSAO), 5, 2) + "/" + Substring(DTOS(SE1->E1_EMISSAO), 1, 4)	

	//Incrementar o Numero da Boleta(1a. Impressão) ou buscar no arquivo(reimpressão)
	M->RegSE1 := Recno()
	
	//Posicionar no Cliente
	DbSelectArea("SA1")
	DbSetOrder(1)
	DbGoTop()
	DbSeek(xFilial("SA1") + SE1->E1_CLIENTE + SE1->E1_LOJA)
	
	DbSelectArea("SE1")
	DbGoto(M->RegSE1)
	
	oprn:StartPage() //--Inicio da Impressao
	oPrn:SetPortrait() //--Retrato
	
	//CaDD
  
	//--Boleta
	Do Case		
		Case M->Banco == "341"
			M->Nome_Bco := "Banco Itau"
			M->Cod_Comp := "|341-7|"
			M->Ag_Conta := "0070-X / 72100-6"
			M->Carteira := "109"
			M->Aceite   := "N"
	EndCase

	//Rafael Rosa Obify - 09/06/22 - Linha comentada (EM MANUTENCAO)
	oprn:Say(010,2200," Pag: "+Transform(nPag,"@E 99"),oFont1,100)

	//--Cabecalho da Fatura
	
	//Rafael Rosa Obify - 11/05/22 - Linhas comentadas
	//oPrn:Box(050,0100,0300,0500)
	//oPrn:Box(050,0500,0300,1600)
	//oPrn:Box(050,1600,0300,2300)

	//--Primeiro Box
	//Rafael Rosa Obify - 11/05/22 - Linhas comentadas
	//oPrn:SayBitmap( 0120, 0150, cLogoFAT, 250, 100 )
	oPrn:SayBitmap( 050, 0100, cLogoFAT, 290, 140 )
	
	//--Segundo Box
	oprn:Say(050,0440,"EMOVERE LOGÍSTICA LTDA.",oFont12,100)
	oprn:say(090,0440,"AV. DR. MAURO LINDEMBERG MONTEIRO, 185, JD. SANTA FÉ - OSASCO - SP",oFont13,100)
	oprn:say(130,0440,"GALPÃO 10 - MEZANINO - BLOCO 1 - CEP: 06278-010",oFont13,100)
	oprn:say(170,0440,"C.N.P.J.:  10.245.270/0001-16    IE: 492.539.225.119",oFont13,100)
	oprn:say(210,0440,"Fone:(11)3658-8892 Fax:(11)3658-8893 Email: emovere@emovere.com.br",oFont13,100)

	//labes
	oPrn:Say(090,1600,"Fatura Nº: ",oFont10,100)
	oPrn:Say(090,1800,SE1->E1_NUM,oFont10,100)
	oPrn:Say(090,1950,"Dt. Emissao: ",oFont10,100)
	oPrn:Say(090,2180,Dtoc(SE1->E1_EMISSAO),oFont10,100)

	//box
	oPrn:Box(130,1600,210,1950) //--Vencimento
	oPrn:Box(130,1950,210,2300) //--Valor Pagamento

	//variaveis vencimento + valor a pagar
	oPrn:Say(133,1662,"Vencimento",oFont11,100)
	oPrn:Say(166,1662,Dtoc(SE1->E1_VENCTO),oFont2,100)
	oPrn:Say(133,2000,"Valor a Pagar",oFont11,100)
	oPrn:Say(166,1990,"R$" + Transform(SE1->E1_VALOR,"@E 999,999,999.99"),oFont12,100)

/*
Exemplos
oPrint:Box( 130,10,600,900 );

Nome	Tipo	Descrição	Obrigatório	Referência
nRow	Numérico	Indica a coordenada vertical em pixels.	
nCol	Numérico	Indica a coordenada horizontal em pixels.	
nBottom	Numérico	Indica a posição do objeto em relação ao rodapé.	
nRight	Numérico	Indica a posição do objeto à direita.	
uParam5	Qualquer	Compatibilidade.	
*/

	//--Terceiro Box
	//oPrn:Say(050,1610,"",oFont4,100)
	//oPrn:Say(100,1610,"Fone:(11)3658-8892 Fax:(11)3658-8893",oFont4,100)
	//oPrn:Say(150,1610,"C.N.P.J.:  10.245.270/0001-16",oFont4,100)
	//oPrn:Say(200,1610,"IE: 492.539.225.119",oFont4,100)
	//oPrn:Say(250,1610,"Email: emovere@emovere.com.br",oFont4,100)
	
	
	 
	 //Rafael Rosa Obify - 02/06/22 - Linhas comentadas - INICIO
	/*
	//--(Linha,Coluna Inicial,Linha Final, Coluna Final)
	oPrn:Box(350,0100,0400,1150)
	oPrn:Box(350,1150,0400,2300)	
	
	oPrn:Say(350,0550,"FATURA",oFont2,100)
	oPrn:Say(350,1700,"DUPLICATA",oFont2,100)
	
	oPrn:Box(400,0100,0450,0400) //--Numero
	oPrn:Box(400,0400,0450,0700) //--Valor
	oPrn:Box(400,0700,0450,1150) //--Data Emissao
	oPrn:Box(400,1150,0450,1450) //--Numero
	oPrn:Box(400,1450,0450,1750) //--Parcela
	oPrn:Box(400,1750,0450,2050) //--Valor
	oPrn:Box(400,2050,0450,2300) //--Vencimento
	
	oPrn:Say(400,0110,"Numero",oFont2,100)
	oPrn:Say(400,0410,"Valor R$",oFont2,100)
	oPrn:Say(400,0710,"Data da Emissão",oFont2,100)
	oPrn:Say(400,1160,"Número",oFont2,100)
	oPrn:Say(400,1460,"Parcela",oFont2,100)
	oPrn:Say(400,1760,"Valor R$",oFont2,100)
	oPrn:Say(400,2060,"Vencimento",oFont2,100)

	oPrn:Box(450,0100,0500,0400) //--Numero
	oPrn:Box(450,0400,0500,0700) //--Valor
	oPrn:Box(450,0700,0500,1150) //--Data Emissao
	oPrn:Box(450,1150,0500,1450) //--Numero
	oPrn:Box(450,1450,0500,1750) //--Parcela
	oPrn:Box(450,1750,0500,2050) //--Valor
	oPrn:Box(450,2050,0500,2300) //--Vencimento

	//--Valores, pesquisar no banco de dados
	oPrn:Say(450,0110,SE1->E1_NUM,oFont2,100)
	oPrn:Say(450,0410,Transform(SE1->E1_VALOR,"@E 999,999,999.99"),oFont2,100)
	oPrn:Say(450,0710,Dtoc(SE1->E1_EMISSAO),oFont2,100)
	oPrn:Say(450,1160,SE1->E1_NUM,oFont2,100)
	oPrn:Say(450,1460,SE1->E1_PARCELA,oFont2,100)
	oPrn:Say(450,1760,Transform(SE1->E1_VALOR,"@E 999,999,999.99"),oFont2,100)
	oPrn:Say(450,2060,Dtoc(SE1->E1_VENCTO),oFont2,100)
	*/
	//Rafael Rosa Obify - 02/06/22 - Linhas comentadas - FIM
   
	//--Detalhes do Cliente
	//Rafael Rosa Obify - 02/06/22 - Linha comentada
	//oPrn:Box(500,0100,830,2300)

	//Rafael Rosa Obify - 02/06/22 - Linha comentada
	//oPrn:Say(510,0110,"Sacado: " + SA1->A1_NOME ,oFont2,100)
	//Rafael Rosa Obify - 02/06/22 - Linha adicionada
	oPrn:Say(300,0100,"Pagador:",oFont2,100)
	oPrn:Say(300,0250,SA1->A1_NOME ,oFont12,100)

	//Rafael Rosa Obify - 02/06/22 - Linhas comentadas - INICIO
	/*
	oPrn:Say(510,1500,"Código: " + SA1->A1_COD + "-" + SA1->A1_LOJA ,oFont2,100)
	oPrn:Say(560,0110,"Endereço: " + AllTrim(SA1->A1_END) ,oFont2,100)
	oPrn:Say(560,1500,"CEP: " + Substr(SA1->A1_CEP,1,5) + "-" + Substr(SA1->A1_CEP,5,3) ,oFont2,100)
	oPrn:Say(610,0110,"Bairro: " + AllTrim(SA1->A1_BAIRRO) ,oFont2,100)
	oPrn:Say(610,0700,"Municipio: " + AllTrim(SA1->A1_MUN) ,oFont2,100)
	oPrn:Say(610,1500,"Estado: " + SA1->A1_EST ,oFont2,100)
	*/
	//Rafael Rosa Obify - 02/06/22 - Linhas comentadas - FIM

	If SA1->A1_PESSOA == "J" //--Juridica
		//Rafael Rosa Obify - 02/06/22 - Linha comentada
		//oprn:Say(670,0110,'CNPJ: ' + Transform(SA1->A1_CGC,"@R 99.999.999/9999-99"),oFont2,100)
		//Rafael Rosa Obify - 02/06/22 - Linha adicionada
		oprn:Say(0340,0250,'CNPJ: ' + Transform(SA1->A1_CGC,"@R 99.999.999/9999-99"),oFont13,100)
	ElseIf SA1->A1_PESSOA == "F" //--Fisica
		//Rafael Rosa Obify - 02/06/22 - Linha comentada
		//oprn:Say(670,0110,'CPF: ' + Transform(SA1->A1_CGC,"@R 999.999.999-99"),oFont2,100)
		//Rafael Rosa Obify - 02/06/22 - Linha adicionada
		oprn:Say(0340,0250,'CPF: ' + Transform(SA1->A1_CGC,"@R 999.999.999-99"),oFont13,100)
	EndIf

	//Rafael Rosa Obify - 02/06/22 - Linha comentada
	//oPrn:Say(670,1500,"Insc Estadual: " + SA1->A1_INSCR ,oFont2,100)
	//Rafael Rosa Obify - 02/06/22 - Linha adicionada
	oPrn:Say(0340,0630,"Insc Estadual: " + SA1->A1_INSCR ,oFont13,100)

	//Rafael Rosa Obify - 02/06/22 - Linha adicionada
	oPrn:Say(0340,01150,"FONE: (" + SA1->A1_DDD + ") " + SA1->A1_TELDIP ,oFont13,100)


	//Rafael Rosa Obify - 02/06/22 - Linhas Comentadas - INICIO
	/*
	If !Empty(SA1->A1_ENDCOB)
		oPrn:Say(720,0110,"End Cobrança: " + Substr(SA1->A1_ENDCOB,1,32) ,oFont2,100)
	Else
		oPrn:Say(720,0110,"End Cobrança: " + Substr(SA1->A1_END,1,32) ,oFont2,100)
	EndIf
	
	oPrn:Say(720,1000,"CEP: " + Substr(SA1->A1_CEP,1,5) + "-" + Substr(SA1->A1_CEP,5,3) ,oFont2,100)
	oPrn:Say(720,1500,"Estado: " + SA1->A1_EST ,oFont2,100)
	oPrn:Say(770,0110,"Municipio: " + AllTrim(SA1->A1_MUN) ,oFont2,100)
	
	//--Valor por Extenso
	oPrn:Box(850,0100,1000,2300)
	oPrn:Say(860,0110," Valor"  + "    " + AllTrim(Extenso(SE1->E1_VALOR,.F.,1)) ,oFont2,100)
	oPrn:Say(910,0110,"  por"   + Replicate('.',200) ,oFont2,100)
	oPrn:Say(960,0110,"Extenso" + Replicate('.',200) ,oFont2,100)
	*/
	//Rafael Rosa Obify - 02/06/22 - Linhas Comentadas - FIM

//Rafael Rosa Obify - 22/06/22 - Linhas adicionadas - INICIO (EM TESTE)
//CARGA DADOS CIF
IF Len(aDoc) > 0


	//Rafael Rosa Obify - 02/06/22 - Linha adicionada
	oPrn:Box(0395,0100,0397,2296)
	oPrn:Say(0458,0100,"FRETE CIF",oFont12,100)

	//Rafael Rosa Obify - 02/06/22 - Linhas Comentadas - INICIO
	/*
	//--Conhecimentos a Faturar
	oPrn:Box(1050,0100,1150,0344)
	oPrn:Box(1050,0344,1150,0588)
	oPrn:Box(1050,0588,1150,0832)
	oPrn:Box(1050,0832,1150,1076)
	oPrn:Box(1050,1076,1150,1320)
	oPrn:Box(1050,1320,1150,2296)
	*/
	//Rafael Rosa Obify - 02/06/22 - Linhas Comentadas - FIM

	//Rafael Rosa Obify - 02/06/22 - Linhas adicionadas - INICIO
	//--Grade Cabecalho dos Itens da fatura
	oPrn:Box(0500,0100,0580,0275)//Numero CTR
	oPrn:Box(0500,0275,0580,0435)//Emissao
	oPrn:Box(0500,0435,0580,1135)//Destinatario
	oPrn:Box(0500,1135,0580,1310)//N.Fiscal
	oPrn:Box(0500,1310,0580,1410)//Peso
	oPrn:Box(0500,1410,0580,1585)//Val.Merc
	oPrn:Box(0500,1585,0580,1760)//B.Calc
	oPrn:Box(0500,1760,0580,1935)//ICMS / ISS
	oPrn:Box(0500,1935,0580,2110)//% Frete/Valor (rateio)
	oPrn:Box(0500,2110,0580,2285)//Valor Frete???????? CONFIRMAR COM MAXIMO
	//encerrar no maximo em 2296
	//Rafael Rosa Obify - 02/06/22 - Linhas adicionadas - FIM
	
	/*
	oPrn:Box(1050,1564,1150,1808)
	oPrn:Box(1050,1808,1150,2052)
	oPrn:Box(1050,2052,1150,2296)
	*/
	
	//Rafael Rosa Obify - 02/06/22 - Linhas Comentadas - INICIO
	/*
	//--Cabecalho dos Itens da fatura
	oPrn:Say(1050,0150,"Data",oFont2,100)
	oPrn:Say(1050,0384,"Numero",oFont2,100)
	oPrn:Say(1100,0390,"CTRC",oFont2,100)
	oPrn:Say(1050,0598,"Frete",oFont2,100)
	oPrn:Say(1100,0598,"(R$)",oFont2,100)


	oPrn:Say(1050,0842,"Nota Cliente",oFont2,100)
	oPrn:Say(1050,1086,"Valor Nota",oFont2,100)
	oPrn:Say(1050,1830,"% Frete/Valor",oFont2,100)
	*/
	//Rafael Rosa Obify - 02/06/22 - Linhas Comentadas - FIM

	//Rafael Rosa Obify - 02/06/22 - Linhas adicionadas - INICIO
	//--Cabecalho dos Itens da fatura
	oPrn:Say(0510,0110,"Numero",oFont11,100)
	oPrn:Say(0540,0110,"CTRC",oFont11,100)
	oPrn:Say(0510,0285,"Data",oFont11,100)
	oPrn:Say(0540,0285,"Emissao",oFont11,100)
	oPrn:Say(0525,0445,"Destinatario",oFont11,100)
	oPrn:Say(0525,1145,"N.Fiscal",oFont11,100)
	oPrn:Say(0525,1320,"Peso",oFont11,100)
	oPrn:Say(0510,1420,"Valor",oFont11,100)
	oPrn:Say(0540,1420,"Mercadoria",oFont11,100)
	oPrn:Say(0525,1595,"B.Calc.",oFont11,100)
	oPrn:Say(0525,1770,"ICMS",oFont11,100)
	oPrn:Say(0510,1945,"Frete/Valor",oFont11,100)
	oPrn:Say(0540,1945,"%",oFont11,100)
	oPrn:Say(0525,2120,"Valor Frete",oFont11,100)
	//Rafael Rosa Obify - 02/06/22 - Linhas adicionadas - FIM

	/*
	oPrn:Say(1050,0842,"Data",oFont2,100)
	oPrn:Say(1050,1086,"Numero",oFont2,100)
	oPrn:Say(1100,1086,"CTRC",oFont2,100)
	oPrn:Say(1050,1330,"Frete",oFont2,100)
	oPrn:Say(1100,1330,"(R$)",oFont2,100)
	oPrn:Say(1050,1574,"Data",oFont2,100)
	oPrn:Say(1050,1818,"Numero",oFont2,100)
	oPrn:Say(1100,1818,"CTRC",oFont2,100)
	oPrn:Say(1050,2062,"Frete",oFont2,100)
	oPrn:Say(1100,2062,"(R$)",oFont2,100)       
	*/
		
	//--Verifica o numero de CTRCs, para jogar nas linhas
	nCol		:= "A"                   
	nBoxVIni	:= 1150
	nBoxVFim	:= 1200
	//Rafael Rosa Obify - 09/06/22 - Linha comentada
	//nConV    := 1100
	//Rafael Rosa Obify - 09/06/22 - Linha adicionada
	nConV		:= 0550

	For nCont := 1 To Len(aDoc)

	  	If nCont == nLimite

			//Rafael Rosa Obify - 09/06/22 - Linhas adicionadas - INICIO
			//Montagem da grade da pagina anterior
			oPrn:Box(0580,0100,3290,0275)
			oPrn:Box(0580,0275,3290,0435)
			oPrn:Box(0580,0435,3290,1135)
			oPrn:Box(0580,1135,3290,1310)
			oPrn:Box(0580,1310,3290,1410)
			oPrn:Box(0580,1410,3290,1585)
			oPrn:Box(0580,1585,3290,1760)
			oPrn:Box(0580,1760,3290,1935)
			oPrn:Box(0580,1935,3290,2110)
			oPrn:Box(0580,2110,3290,2285)
			//Rafael Rosa Obify - 09/06/22 - Linhas adicionadas - FIM

			nPag += 1

			//nLimite := nLimite+183//Giovani Zago 11/11/11
			//nLimite := nLimite+60//Giovani Zago 11/11/11
			nLimite := nLimite+54//Rafael Rosa Obify - 09/06/22

			oprn:EndPage()
			oprn:StartPage() //--Inicio da Impressao
 			oPrn:SetPortrait() //--Retrato	
 			nCol  := "A"           
			nCnt2 := 0  
			//Rafael Rosa Obify - 08/06/22 - Linhas comentadas
			//nBoxVIni := 0100
			//nBoxVFim := 0150
			//Rafael Rosa Obify - 08/06/22 - Linhas adicionadas
			nBoxVIni := 1150
			nBoxVFim := 1200
			//Rafael Rosa Obify - 09/06/22 - Linha comentada
			//nConV    := 0050
			//Rafael Rosa Obify - 09/06/22 - Linha adicionada
			nConV		:= 0450
            
			//-- Página
			//Rafael Rosa Obify - 09/06/22 - Linha comentada
			oprn:Say(010,2200," Pag: "+Transform(nPag,"@E 99"),oFont1,100)
			
			//Rafael Rosa Obify - 08/06/22 - Linhas adicionadas - INICIO
			//--Primeiro Box
    		oPrn:SayBitmap( 050, 0100, cLogoFAT, 290, 140 )

    		//--Segundo Box
			oprn:Say(050,0440,"EMOVERE LOGÍSTICA LTDA.",oFont12,100)
			oprn:say(090,0440,"AV. DR. MAURO LINDEMBERG MONTEIRO, 185, JD. SANTA FÉ - OSASCO - SP",oFont13,100)
			oprn:say(130,0440,"GALPÃO 10 - MEZANINO - BLOCO 1 - CEP: 06278-010",oFont13,100)
			oprn:say(170,0440,"C.N.P.J.:  10.245.270/0001-16    IE: 492.539.225.119",oFont13,100)
			oprn:say(210,0440,"Fone:(11)3658-8892 Fax:(11)3658-8893 Email: emovere@emovere.com.br",oFont13,100)

    		//labes
			oPrn:Say(090,1600,"Fatura Nº: ",oFont10,100)
			oPrn:Say(090,1800,SE1->E1_NUM,oFont10,100)
			oPrn:Say(090,1950,"Dt. Emissao: ",oFont10,100)
			oPrn:Say(090,2180,Dtoc(SE1->E1_EMISSAO),oFont10,100)

			//box
			oPrn:Box(130,1600,210,1950) //--Vencimento
			oPrn:Box(130,1950,210,2300) //--Valor Pagamento

			//variaveis vencimento + valor a pagar
			oPrn:Say(133,1662,"Vencimento",oFont11,100)
			oPrn:Say(166,1662,Dtoc(SE1->E1_VENCTO),oFont2,100)
			oPrn:Say(133,2000,"Valor a Pagar",oFont11,100)
			oPrn:Say(166,1990,"R$" + Transform(SE1->E1_VALOR,"@E 999,999,999.99"),oFont12,100)

    		oPrn:Say(300,0100,"Pagador:",oFont2,100)
			oPrn:Say(300,0250,SA1->A1_NOME ,oFont12,100)

   			If SA1->A1_PESSOA == "J" //--Juridica
				oprn:Say(0340,0250,'CNPJ: ' + Transform(SA1->A1_CGC,"@R 99.999.999/9999-99"),oFont13,100)
			ElseIf SA1->A1_PESSOA == "F" //--Fisica
				oprn:Say(0340,0250,'CPF: ' + Transform(SA1->A1_CGC,"@R 999.999.999-99"),oFont13,100)
			EndIf

			oPrn:Say(0340,0630,"Insc Estadual: " + SA1->A1_INSCR ,oFont13,100)

			oPrn:Say(0340,01150,"FONE: (" + SA1->A1_DDD + ") " + SA1->A1_TELDIP ,oFont13,100)

    		oPrn:Box(0395,0100,0397,2296)
			oPrn:Say(0458,0100,"FRETE CIF",oFont12,100)
			//Rafael Rosa Obify - 08/06/22 - Linhas adicionadas - FIM


			//Rafael Rosa Obify - 08/06/22 - linhas comentadas - INICIO
			/*
			//--Conhecimentos a Faturar
			oPrn:Box(nBoxVIni,0100,nBoxVFim+50,0344)
			oPrn:Box(nBoxVIni,0344,nBoxVFim+50,0588)
			oPrn:Box(nBoxVIni,0588,nBoxVFim+50,0832)
			oPrn:Box(nBoxVIni,0832,nBoxVFim+50,1076)
			oPrn:Box(nBoxVIni,1076,nBoxVFim+50,1320)
			oPrn:Box(nBoxVIni,1320,nBoxVFim+50,2296)
			*/
			//Rafael Rosa Obify - 08/06/22 - linhas comentadas - FIM
			
			//Rafael Rosa Obify - 09/06/22 - Linhas adicionadas - INICIO
			//--Grade Cabecalho dos Itens da fatura
			oPrn:Box(0500,0100,0580,0275)//Numero CTR
			oPrn:Box(0500,0275,0580,0435)//Emissao
			oPrn:Box(0500,0435,0580,1135)//Destinatario
			oPrn:Box(0500,1135,0580,1310)//N.Fiscal
			oPrn:Box(0500,1310,0580,1410)//Peso
			oPrn:Box(0500,1410,0580,1585)//Val.Merc
			oPrn:Box(0500,1585,0580,1760)//B.Calc
			oPrn:Box(0500,1760,0580,1935)//ICMS / ISS
			oPrn:Box(0500,1935,0580,2110)//% Frete/Valor (rateio)
			oPrn:Box(0500,2110,0580,2285)//Valor Frete???????? CONFIRMAR COM MAXIMO
			//encerrar no maximo em 2296
			//Rafael Rosa Obify - 09/06/22 - Linhas adicionadas - FIM

			
			
			/*
			oPrn:Box(nBoxVIni,1564,nBoxVFim+50,1808)
			oPrn:Box(nBoxVIni,1808,nBoxVFim+50,2052)
			oPrn:Box(nBoxVIni,2052,nBoxVFim+50,2296)
	*/		

			//Rafael Rosa Obify - 08/06/22 - linhas comentadas - INICIO
			/*  
			//--Cabecalho dos Itens da fatura
			oPrn:Say(nBoxVIni,0150,"Data",oFont2,100)
			oPrn:Say(nBoxVIni,0384,"Numero",oFont2,100)
			oPrn:Say(nBoxVFim,0390,"CTRC",oFont2,100)
			oPrn:Say(nBoxVIni,0598,"Frete",oFont2,100)
			oPrn:Say(nBoxVFim,0598,"(R$)",oFont2,100)

			oPrn:Say(nBoxVIni,0842,"Nota Cliente",oFont2,100)
			oPrn:Say(nBoxVIni,1086,"Valor Nota",oFont2,100)
			oPrn:Say(nBoxVIni,1830,"% Frete/Valor",oFont2,100)
			*/
			//Rafael Rosa Obify - 08/06/22 - linhas comentadas - FIM

			//Rafael Rosa Obify - 08/06/22 - Linhas adicionadas - INICIO
			//--Cabecalho dos Itens da fatura
			oPrn:Say(0510,0110,"Numero",oFont11,100)
			oPrn:Say(0540,0110,"CTRC",oFont11,100)
			oPrn:Say(0510,0285,"Data",oFont11,100)
			oPrn:Say(0540,0285,"Emissao",oFont11,100)
			oPrn:Say(0525,0445,"Destinatario",oFont11,100)
			oPrn:Say(0525,1145,"N.Fiscal",oFont11,100)
			oPrn:Say(0525,1320,"Peso",oFont11,100)
			oPrn:Say(0510,1420,"Valor",oFont11,100)
			oPrn:Say(0540,1420,"Mercadoria",oFont11,100)
			oPrn:Say(0525,1595,"B.Calc.",oFont11,100)
			oPrn:Say(0525,1770,"ICMS",oFont11,100)
			oPrn:Say(0510,1945,"Frete/Valor",oFont11,100)
			oPrn:Say(0540,1945,"%",oFont11,100)
			oPrn:Say(0525,2120,"Valor Frete",oFont11,100)
			//Rafael Rosa Obify - 08/06/22 - Linhas adicionadas - FIM


			/*
			oPrn:Say(nBoxVIni,0842,"Data",oFont2,100)
			oPrn:Say(nBoxVIni,1086,"Numero",oFont2,100)
			oPrn:Say(nBoxVFim,1086,"CTRC",oFont2,100)
			oPrn:Say(nBoxVIni,1330,"Frete",oFont2,100)
			oPrn:Say(nBoxVFim,1330,"(R$)",oFont2,100)
			oPrn:Say(nBoxVIni,1574,"Data",oFont2,100)
			oPrn:Say(nBoxVIni,1818,"Numero",oFont2,100)
			oPrn:Say(nBoxVFim,1818,"CTRC",oFont2,100)
			oPrn:Say(nBoxVIni,2062,"Frete",oFont2,100)
			oPrn:Say(nBoxVFim,2062,"(R$)",oFont2,100) 
			*/
			nCnt2 += 100
		Endif      
		
		If 	nCol == "A"
			                 			
			// Linha ctrc,s
			//Rafael Rosa Obify - 08/06/22 - linhas comentadas - INICIO
			/*  
			oPrn:Box(nBoxVIni+nCnt2,0100,nBoxVFim+nCnt2,0344)
			oPrn:Box(nBoxVIni+nCnt2,0344,nBoxVFim+nCnt2,0588)
			oPrn:Box(nBoxVIni+nCnt2,0588,nBoxVFim+nCnt2,0832)
			oPrn:Box(nBoxVIni+nCnt2,0832,nBoxVFim+nCnt2,1076)
			oPrn:Box(nBoxVIni+nCnt2,1076,nBoxVFim+nCnt2,1320)
			oPrn:Box(nBoxVIni+nCnt2,1320,nBoxVFim+nCnt2,2296)
			*/
			//Rafael Rosa Obify - 08/06/22 - linhas comentadas - FIM (Funcao substituida pelas linhas 544->553 e 783->792)


			/*
			oPrn:Box(nBoxVIni+nCnt2,1564,nBoxVFim+nCnt2,1808)
			oPrn:Box(nBoxVIni+nCnt2,1808,nBoxVFim+nCnt2,2052)
			oPrn:Box(nBoxVIni+nCnt2,2052,nBoxVFim+nCnt2,2296)
			*/
			
			nCnt2 += 50
			
			//Rafael Rosa Obify - 08/06/22 - Linhas comentadas - INICIO
			/*
			oPrn:Say(nConV+(nCnt2),0110,Dtoc(aDoc[nCont][01]),oFont2,100)
			oPrn:Say(nConV+(nCnt2),0354,aDoc[nCont][02],oFont2,100)
			oPrn:Say(nConV+(nCnt2),0598,Transform(aDoc[nCont][03],"@E 999,999,999.99"),oFont2,100)

			oPrn:Say(nConV+(nCnt2),0842,aDoc[nCont][05],oFont2,100)
			oPrn:Say(nConV+(nCnt2),1086,Transform(aDoc[nCont][06],"@E 999,999,999.99"),oFont2,100)
			oPrn:Say(nConV+(nCnt2),1830,Transform(aDoc[nCont][07],"@E 999.99"),oFont2,100)
			*/
			//Rafael Rosa Obify - 08/06/22 - Linhas comentadas - FIM
			
			//Rafael Rosa Obify - 08/06/22 - Linhas adicionadas - INICIO
			oPrn:Say(nConV+(nCnt2),0285,Dtoc(aDoc[nCont][01]),oFont14,100) //DATA EMISSAO
			oPrn:Say(nConV+(nCnt2),0110,aDoc[nCont][02],oFont14,100) //NUMERO CTRC
			oPrn:Say(nConV+(nCnt2),2120,Transform(aDoc[nCont][03],"@E 999,999,999.99"),oFont14,100) //VALOR FRETE
			
			oPrn:Say(nConV+(nCnt2),1145,aDoc[nCont][05],oFont14,100) //N.FISCAL
			oPrn:Say(nConV+(nCnt2),1420,Transform(aDoc[nCont][06],"@E 999,999,999.99"),oFont14,100) //VALOR MERCADORIA
			oPrn:Say(nConV+(nCnt2),1945,Transform(aDoc[nCont][07],"@E 999.99"),oFont14,100) //VALOR FRETE %

			//Rafael Rosa Obify - 22/06/22 - Linhas adicionadas - INICIO
			nAliqICM	:= VAL("0."+ cValToChar(aDoc[nCont][12]))
			nValICM	:= aDoc[nCont][09] * nAliqICM
			//Rafael Rosa Obify - 22/06/22 - Linhas adicionadas - FIM

			IF nAliqICM = 0.7
				nTotICM7	+= nValICM
			ELSEIF nAliqICM	= 0.12
				nTotICM12	+= nValICM
			ELSEIF nAliqICM	= 0.18
				nTotICM18	+= nValICM
			ENDIF

			nTotICMCIF	+= nValICM
			

			//NOVOS CAMPOS
			oPrn:Say(nConV+(nCnt2),0445,SUBSTRING(aDoc[nCont][11],1,55),oFont14,100) //CNPJ + RAZAO SOCIAL	
			oPrn:Say(nConV+(nCnt2),1320,Transform(aDoc[nCont][08],"@E 999.99"),oFont14,100) //PESO
			oPrn:Say(nConV+(nCnt2),1595,Transform(aDoc[nCont][09],"@E 999,999,999.99"),oFont14,100) //BC IMPOSTO
			//Rafael Rosa Obify - 22/06/22 - Linhaa comentada
			//oPrn:Say(nConV+(nCnt2),1770,Transform(aDoc[nCont][10],"@E 999,999,999.99"),oFont14,100) //VALOR IMPOSTO
			//Rafael Rosa Obify - 22/06/22 - Linhaa adicionada
			oPrn:Say(nConV+(nCnt2),1770,Transform(nValICM,"@E 999,999,999.99"),oFont14,100) //VALOR IMPOSTO
			//Rafael Rosa Obify - 08/06/22 - Linhas adicionadas - FIM
				

/*			nCol  := "B"
			
		ElseIf 	nCol == "B"
			oPrn:Say(nConV+(nCnt2),0842,Dtoc(aDoc[nCont][01]),oFont2,100)
			oPrn:Say(nConV+(nCnt2),1086,aDoc[nCont][02],oFont2,100)
			oPrn:Say(nConV+(nCnt2),1330,Transform(aDoc[nCont][03],"@E 999,999,999.99"),oFont2,100)
			nCol  := "C"
		ElseIf nCol == "C"
			oPrn:Say(nConV+(nCnt2),1574,Dtoc(aDoc[nCont][01]),oFont2,100)
			oPrn:Say(nConV+(nCnt2),1818,aDoc[nCont][02],oFont2,100)
			oPrn:Say(nConV+(nCnt2),2062,Transform(aDoc[nCont][03],"@E 999,999,999.99"),oFont2,100)*/
			nCol  := "A"
		EndIf		

	Next nCont
	
	//Rafael Rosa Obify - 09/06/22 - Linhas adicionadas - INICIO
	//Ajuste de encerrameto da linha na grade da ultima pagina impressa
	oPrn:Box(0580,0100,nConV+(nCnt2)+50,0275)
	oPrn:Box(0580,0275,nConV+(nCnt2)+50,0435)
	oPrn:Box(0580,0435,nConV+(nCnt2)+50,1135)
	oPrn:Box(0580,1135,nConV+(nCnt2)+50,1310)
	oPrn:Box(0580,1310,nConV+(nCnt2)+50,1410)
	oPrn:Box(0580,1410,nConV+(nCnt2)+50,1585)
	oPrn:Box(0580,1585,nConV+(nCnt2)+50,1760)
	oPrn:Box(0580,1760,nConV+(nCnt2)+50,1935)
	oPrn:Box(0580,1935,nConV+(nCnt2)+50,2110)
	oPrn:Box(0580,2110,nConV+(nCnt2)+50,2285)
	//Rafael Rosa Obify - 09/06/22 - Linhas adicionadas - FIM

ENDIF
//Rafael Rosa Obify - 22/06/22 - Linhas adicionadas - FIM (EM TESTE)

	CIFMerc		:= 0//Rafael Rosa Obify - 23/06/22
	CIFBC		:= 0//Rafael Rosa Obify - 23/06/22
	CIFICMS		:= 0//Rafael Rosa Obify - 23/06/22
	CIFFRETE	:= 0//Rafael Rosa Obify - 23/06/22

	aEval(aDoc,{ |x| CIFMerc	+= x[06] })
	aEval(aDoc,{ |x| CIFBC		+= x[09] })
	//aEval(aDoc,{ |x| CIFICMS	+= x[06] })
	aEval(aDoc,{ |x| CIFFRETE	+= x[03] })

	//--Total Liquido
	//Rafael Rosa Obify - 09/06/22 - Linhas comentadas - INICIO (EM TESTE)
	oPrn:Box(nConV+(nCnt2)+65,0100,nConV+(nCnt2)+100,2285)
	oPrn:Say(nConV+(nCnt2)+65,0110,"Quantidade de CTRC'S CIF : "+Transform(Len(aDoc),"@E 999999"),oFont14,100)
	//Rafael Rosa Obify - 09/06/22 - Linhas comentadas - FIM (EM TESTE)

	oPrn:Say(nConV+(nCnt2)+65,1420,Transform(CIFMerc,"@E 999,999,999.99"),oFont14,100)
	oPrn:Say(nConV+(nCnt2)+65,1595,Transform(CIFBC,"@E 999,999,999.99"),oFont14,100)
	oPrn:Say(nConV+(nCnt2)+65,1770,Transform(nTotICMCIF,"@E 999,999,999.99"),oFont14,100)
	oPrn:Say(nConV+(nCnt2)+65,2120,Transform(CIFFRETE,"@E 999,999,999.99"),oFont14,100)

/*
	CIFMerc	:= 0//Rafael Rosa Obify - 23/06/22
	CIFBC		:= 0//Rafael Rosa Obify - 23/06/22
	CIFICMS	:= 0//Rafael Rosa Obify - 23/06/22
	CIFFRETE	:= 0//Rafael Rosa Obify - 23/06/22

	aEval(aDocF,{ |x| CIFMerc	+= x[6] })
	aEval(aDocF,{ |x| CIFBC		+= x[9] })
	//aEval(aDocF,{ |x| CIFICMS	+= x[6] })
	aEval(aDocF,{ |x| CIFFRETE	+= x[3] })

	//--Total Liquido
	//Rafael Rosa Obify - 09/06/22 - Linhas comentadas - INICIO (EM TESTE)
	oPrn:Box(nConV+(nCnt2)+50,0100,nConV+(nCnt2)+100,2000)
	oPrn:Box(nBoxVIni+nCnt2,2000,nBoxVIni+100+nCnt2,2300)
	oPrn:Say(nBoxVIni+(nCnt2),2010,"Total Liquido",oFont2,100)
	oPrn:Say(nConV+(nCnt2)+75,0110,"Quantidade de CTRC'S CIF : "+Transform(Len(aDoc),"@E 999999"),oFont2,100)
	oPrn:Say(nBoxVFim+(nCnt2),2010,Transform(SE1->E1_VALOR,"@E 999,999,999.99"),oFont2,100)
	//Rafael Rosa Obify - 09/06/22 - Linhas comentadas - FIM (EM TESTE)

*/

//Rafael Rosa Obify - 22/06/22 - Linhas adicionadas - INICIO (EM TESTE)
//CARGA DADOS FOB
IF Len(aDocF) > 0

	oprn:EndPage()
	oprn:StartPage() //--Inicio da Impressao
 	oPrn:SetPortrait() //--Retrato

	nCnt2 := 0

	nPag += 1

	//Rafael Rosa Obify - 09/06/22 - Linha comentada (EM MANUTENCAO)
	oprn:Say(010,2200," Pag: "+Transform(nPag,"@E 99"),oFont1,100)

	//--Cabecalho da Fatura

	//--Primeiro Box
	oPrn:SayBitmap( 050, 0100, cLogoFAT, 290, 140 )
	
	//--Segundo Box
	oprn:Say(050,0440,"EMOVERE LOGÍSTICA LTDA.",oFont12,100)
	oprn:say(090,0440,"AV. DR. MAURO LINDEMBERG MONTEIRO, 185, JD. SANTA FÉ - OSASCO - SP",oFont13,100)
	oprn:say(130,0440,"GALPÃO 10 - MEZANINO - BLOCO 1 - CEP: 06278-010",oFont13,100)
	oprn:say(170,0440,"C.N.P.J.:  10.245.270/0001-16    IE: 492.539.225.119",oFont13,100)
	oprn:say(210,0440,"Fone:(11)3658-8892 Fax:(11)3658-8893 Email: emovere@emovere.com.br",oFont13,100)

	//labes
	oPrn:Say(090,1600,"Fatura Nº: ",oFont10,100)
	oPrn:Say(090,1800,SE1->E1_NUM,oFont10,100)
	oPrn:Say(090,1950,"Dt. Emissao: ",oFont10,100)
	oPrn:Say(090,2180,Dtoc(SE1->E1_EMISSAO),oFont10,100)

	//box
	oPrn:Box(130,1600,210,1950) //--Vencimento
	oPrn:Box(130,1950,210,2300) //--Valor Pagamento

	//variaveis vencimento + valor a pagar
	oPrn:Say(133,1662,"Vencimento",oFont11,100)
	oPrn:Say(166,1662,Dtoc(SE1->E1_VENCTO),oFont2,100)
	oPrn:Say(133,2000,"Valor a Pagar",oFont11,100)
	oPrn:Say(166,1990,"R$" + Transform(SE1->E1_VALOR,"@E 999,999,999.99"),oFont12,100)

	oPrn:Say(300,0100,"Pagador:",oFont2,100)
	oPrn:Say(300,0250,SA1->A1_NOME ,oFont12,100)

	If SA1->A1_PESSOA == "J" //--Juridica
		oprn:Say(0340,0250,'CNPJ: ' + Transform(SA1->A1_CGC,"@R 99.999.999/9999-99"),oFont13,100)
	ElseIf SA1->A1_PESSOA == "F" //--Fisica
		oprn:Say(0340,0250,'CPF: ' + Transform(SA1->A1_CGC,"@R 999.999.999-99"),oFont13,100)
	EndIf

	oPrn:Say(0340,0630,"Insc Estadual: " + SA1->A1_INSCR ,oFont13,100)
	oPrn:Say(0340,01150,"FONE: (" + SA1->A1_DDD + ") " + SA1->A1_TELDIP ,oFont13,100)

 
	oPrn:Box(0395,0100,0397,2296)
	oPrn:Say(0458,0100,"FRETE FOB",oFont12,100)

	//--Grade Cabecalho dos Itens da fatura
	oPrn:Box(0500,0100,0580,0275)//Numero CTR
	oPrn:Box(0500,0275,0580,0435)//Emissao
	oPrn:Box(0500,0435,0580,1135)//Destinatario
	oPrn:Box(0500,1135,0580,1310)//N.Fiscal
	oPrn:Box(0500,1310,0580,1410)//Peso
	oPrn:Box(0500,1410,0580,1585)//Val.Merc
	oPrn:Box(0500,1585,0580,1760)//B.Calc
	oPrn:Box(0500,1760,0580,1935)//ICMS / ISS
	oPrn:Box(0500,1935,0580,2110)//% Frete/Valor (rateio)
	oPrn:Box(0500,2110,0580,2285)//Valor Frete???????? CONFIRMAR COM MAXIMO
	//encerrar no maximo em 2296

	//--Cabecalho dos Itens da fatura
	oPrn:Say(0510,0110,"Numero",oFont11,100)
	oPrn:Say(0540,0110,"CTRC",oFont11,100)
	oPrn:Say(0510,0285,"Data",oFont11,100)
	oPrn:Say(0540,0285,"Emissao",oFont11,100)
	oPrn:Say(0525,0445,"Destinatario",oFont11,100)
	oPrn:Say(0525,1145,"N.Fiscal",oFont11,100)
	oPrn:Say(0525,1320,"Peso",oFont11,100)
	oPrn:Say(0510,1420,"Valor",oFont11,100)
	oPrn:Say(0540,1420,"Mercadoria",oFont11,100)
	oPrn:Say(0525,1595,"B.Calc.",oFont11,100)
	oPrn:Say(0525,1770,"ICMS",oFont11,100)
	oPrn:Say(0510,1945,"Frete/Valor",oFont11,100)
	oPrn:Say(0540,1945,"%",oFont11,100)
	oPrn:Say(0525,2120,"Valor Frete",oFont11,100)
		
	//--Verifica o numero de CTRCs, para jogar nas linhas
	nCol		:= "A"                   
	nBoxVIni	:= 1150
	nBoxVFim	:= 1200
	nConV		:= 0550
	nLimite		:= 55

	For nCont := 1 To Len(aDocF)

	  	If nCont == nLimite

			//Montagem da grade da pagina anterior
			oPrn:Box(0580,0100,3290,0275)
			oPrn:Box(0580,0275,3290,0435)
			oPrn:Box(0580,0435,3290,1135)
			oPrn:Box(0580,1135,3290,1310)
			oPrn:Box(0580,1310,3290,1410)
			oPrn:Box(0580,1410,3290,1585)
			oPrn:Box(0580,1585,3290,1760)
			oPrn:Box(0580,1760,3290,1935)
			oPrn:Box(0580,1935,3290,2110)
			oPrn:Box(0580,2110,3290,2285)

			nPag += 1

			nLimite := nLimite+54//Rafael Rosa Obify - 09/06/22

			oprn:EndPage()
			oprn:StartPage() //--Inicio da Impressao
 			oPrn:SetPortrait() //--Retrato	
 			nCol  := "A"           
			nCnt2 := 0
			nBoxVIni := 1150
			nBoxVFim := 1200
			nConV		:= 0450
            
			//-- Página
			oprn:Say(020,2150," Pag: "+Transform(nPag,"@E 99"),oFont1,100)
			
			//--Primeiro Box
    		oPrn:SayBitmap( 050, 0100, cLogoFAT, 290, 140 )

    		//--Segundo Box
			oprn:Say(050,0440,"EMOVERE LOGÍSTICA LTDA.",oFont12,100)
			oprn:say(090,0440,"AV. DR. MAURO LINDEMBERG MONTEIRO, 185, JD. SANTA FÉ - OSASCO - SP",oFont13,100)
			oprn:say(130,0440,"GALPÃO 10 - MEZANINO - BLOCO 1 - CEP: 06278-010",oFont13,100)
			oprn:say(170,0440,"C.N.P.J.:  10.245.270/0001-16    IE: 492.539.225.119",oFont13,100)
			oprn:say(210,0440,"Fone:(11)3658-8892 Fax:(11)3658-8893 Email: emovere@emovere.com.br",oFont13,100)

    		//labes
			oPrn:Say(090,1600,"Fatura Nº: ",oFont10,100)
			oPrn:Say(090,1800,SE1->E1_NUM,oFont10,100)
			oPrn:Say(090,1950,"Dt. Emissao: ",oFont10,100)
			oPrn:Say(090,2180,Dtoc(SE1->E1_EMISSAO),oFont10,100)

			//box
			oPrn:Box(130,1600,210,1950) //--Vencimento
			oPrn:Box(130,1950,210,2300) //--Valor Pagamento

			//variaveis vencimento + valor a pagar
			oPrn:Say(133,1662,"Vencimento",oFont11,100)
			oPrn:Say(166,1662,Dtoc(SE1->E1_VENCTO),oFont2,100)
			oPrn:Say(133,2000,"Valor a Pagar",oFont11,100)
			oPrn:Say(166,1990,"R$" + Transform(SE1->E1_VALOR,"@E 999,999,999.99"),oFont12,100)

    		oPrn:Say(300,0100,"Pagador:",oFont2,100)
			oPrn:Say(300,0250,SA1->A1_NOME ,oFont12,100)

   			If SA1->A1_PESSOA == "J" //--Juridica
				oprn:Say(0340,0250,'CNPJ: ' + Transform(SA1->A1_CGC,"@R 99.999.999/9999-99"),oFont13,100)
			ElseIf SA1->A1_PESSOA == "F" //--Fisica
				oprn:Say(0340,0250,'CPF: ' + Transform(SA1->A1_CGC,"@R 999.999.999-99"),oFont13,100)
			EndIf

			oPrn:Say(0340,0630,"Insc Estadual: " + SA1->A1_INSCR ,oFont13,100)

			oPrn:Say(0340,01150,"FONE: (" + SA1->A1_DDD + ") " + SA1->A1_TELDIP ,oFont13,100)

    		oPrn:Box(0395,0100,0397,2296)
			oPrn:Say(0458,0100,"FRETE FOB",oFont12,100)
			
			//--Grade Cabecalho dos Itens da fatura
			oPrn:Box(0500,0100,0580,0275)//Numero CTR
			oPrn:Box(0500,0275,0580,0435)//Emissao
			oPrn:Box(0500,0435,0580,1135)//Destinatario
			oPrn:Box(0500,1135,0580,1310)//N.Fiscal
			oPrn:Box(0500,1310,0580,1410)//Peso
			oPrn:Box(0500,1410,0580,1585)//Val.Merc
			oPrn:Box(0500,1585,0580,1760)//B.Calc
			oPrn:Box(0500,1760,0580,1935)//ICMS / ISS
			oPrn:Box(0500,1935,0580,2110)//% Frete/Valor (rateio)
			oPrn:Box(0500,2110,0580,2285)//Valor Frete???????? CONFIRMAR COM MAXIMO
			//encerrar no maximo em 2296
			
			//--Cabecalho dos Itens da fatura
			oPrn:Say(0510,0110,"Numero",oFont11,100)
			oPrn:Say(0540,0110,"CTRC",oFont11,100)
			oPrn:Say(0510,0285,"Data",oFont11,100)
			oPrn:Say(0540,0285,"Emissao",oFont11,100)
			oPrn:Say(0525,0445,"Destinatario",oFont11,100)
			oPrn:Say(0525,1145,"N.Fiscal",oFont11,100)
			oPrn:Say(0525,1320,"Peso",oFont11,100)
			oPrn:Say(0510,1420,"Valor",oFont11,100)
			oPrn:Say(0540,1420,"Mercadoria",oFont11,100)
			oPrn:Say(0525,1595,"B.Calc.",oFont11,100)
			oPrn:Say(0525,1770,"ICMS",oFont11,100)
			oPrn:Say(0510,1945,"Frete/Valor",oFont11,100)
			oPrn:Say(0540,1945,"%",oFont11,100)
			oPrn:Say(0525,2120,"Valor Frete",oFont11,100)

			nCnt2 += 100
		Endif      
		
		If 	nCol == "A"
			                 			
			
			nCnt2 += 50
		
			oPrn:Say(nConV+(nCnt2),0285,Dtoc(aDocF[nCont][01]),oFont14,100) //DATA EMISSAO
			oPrn:Say(nConV+(nCnt2),0110,aDocF[nCont][02],oFont14,100) //NUMERO CTRC
			oPrn:Say(nConV+(nCnt2),2120,Transform(aDocF[nCont][03],"@E 999,999,999.99"),oFont14,100) //VALOR FRETE
			
			oPrn:Say(nConV+(nCnt2),1145,aDocF[nCont][05],oFont14,100) //N.FISCAL
			oPrn:Say(nConV+(nCnt2),1420,Transform(aDocF[nCont][06],"@E 999,999,999.99"),oFont14,100) //VALOR MERCADORIA
			oPrn:Say(nConV+(nCnt2),1945,Transform(aDocF[nCont][07],"@E 999.99"),oFont14,100) //VALOR FRETE %

			nAliqICM	:= VAL("0."+ cValToChar(aDocF[nCont][12]))
			nValICM	:= aDocF[nCont][09] * nAliqICM

			IF nAliqICM = 0.7
				nTotICM7	+= nValICM
			ELSEIF nAliqICM	= 0.12
				nTotICM12	+= nValICM
			ELSEIF nAliqICM	= 0.18
				nTotICM18	+= nValICM
			ENDIF

			nTotICMFOB	+= nValICM

			//NOVOS CAMPOS
			oPrn:Say(nConV+(nCnt2),0445,SUBSTRING(aDocF[nCont][11],1,55),oFont14,100) //CNPJ + RAZAO SOCIAL	
			oPrn:Say(nConV+(nCnt2),1320,Transform(aDocF[nCont][08],"@E 999.99"),oFont14,100) //PESO
			oPrn:Say(nConV+(nCnt2),1595,Transform(aDocF[nCont][09],"@E 999,999,999.99"),oFont14,100) //BC IMPOSTO
			oPrn:Say(nConV+(nCnt2),1770,Transform(nValICM,"@E 999,999,999.99"),oFont14,100) //VALOR IMPOSTO

			nCol  := "A"
		EndIf		

	Next nCont
	
	//Ajuste de encerrameto da linha na grade da ultima pagina impressa
	oPrn:Box(0580,0100,nConV+(nCnt2)+50,0275)
	oPrn:Box(0580,0275,nConV+(nCnt2)+50,0435)
	oPrn:Box(0580,0435,nConV+(nCnt2)+50,1135)
	oPrn:Box(0580,1135,nConV+(nCnt2)+50,1310)
	oPrn:Box(0580,1310,nConV+(nCnt2)+50,1410)
	oPrn:Box(0580,1410,nConV+(nCnt2)+50,1585)
	oPrn:Box(0580,1585,nConV+(nCnt2)+50,1760)
	oPrn:Box(0580,1760,nConV+(nCnt2)+50,1935)
	oPrn:Box(0580,1935,nConV+(nCnt2)+50,2110)
	oPrn:Box(0580,2110,nConV+(nCnt2)+50,2285)

	FOBMerc		:= 0//Rafael Rosa Obify - 23/06/22
	FOBBC		:= 0//Rafael Rosa Obify - 23/06/22
	FOBICMS		:= 0//Rafael Rosa Obify - 23/06/22
	FOBFRETE	:= 0//Rafael Rosa Obify - 23/06/22

	aEval(aDocF,{ |x| FOBMerc	+= x[06] })
	aEval(aDocF,{ |x| FOBBC		+= x[09] })
	//aEval(aDocF,{ |x| CIFICMS	+= x[06] })
	aEval(aDocF,{ |x| FOBFRETE	+= x[03] })

	//--Total Liquido
	//Rafael Rosa Obify - 09/06/22 - Linhas comentadas - INICIO (EM TESTE)
	oPrn:Box(nConV+(nCnt2)+65,0100,nConV+(nCnt2)+100,2285)
	oPrn:Say(nConV+(nCnt2)+65,0110,"Quantidade de CTRC'S FOB : "+Transform(Len(aDocF),"@E 999999"),oFont14,100)
	//Rafael Rosa Obify - 09/06/22 - Linhas comentadas - FIM (EM TESTE)

	oPrn:Say(nConV+(nCnt2)+65,1420,Transform(FOBMerc,"@E 999,999,999.99"),oFont14,100)
	oPrn:Say(nConV+(nCnt2)+65,1595,Transform(FOBBC,"@E 999,999,999.99"),oFont14,100)
	oPrn:Say(nConV+(nCnt2)+65,1770,Transform(nTotICMFOB,"@E 999,999,999.99"),oFont14,100)
	oPrn:Say(nConV+(nCnt2)+65,2120,Transform(FOBFRETE,"@E 999,999,999.99"),oFont14,100)


ENDIF
//Rafael Rosa Obify - 22/06/22 - Linhas adicionadas - FIM (EM TESTE)

//RAFAEL 223/06/2022 - TOTAIS


IF Len(aDocDR) > 0

	oprn:EndPage()
	oprn:StartPage() //--Inicio da Impressao
 	oPrn:SetPortrait() //--Retrato

	nCnt2 := 0

	nPag += 1

	//Rafael Rosa Obify - 09/06/22 - Linha comentada (EM MANUTENCAO)
	oprn:Say(010,2200," Pag: "+Transform(nPag,"@E 99"),oFont1,100)

	//--Cabecalho da Fatura

	//--Primeiro Box
	oPrn:SayBitmap( 050, 0100, cLogoFAT, 290, 140 )
	
	//--Segundo Box
	oprn:Say(050,0440,"EMOVERE LOGÍSTICA LTDA.",oFont12,100)
	oprn:say(090,0440,"AV. DR. MAURO LINDEMBERG MONTEIRO, 185, JD. SANTA FÉ - OSASCO - SP",oFont13,100)
	oprn:say(130,0440,"GALPÃO 10 - MEZANINO - BLOCO 1 - CEP: 06278-010",oFont13,100)
	oprn:say(170,0440,"C.N.P.J.:  10.245.270/0001-16    IE: 492.539.225.119",oFont13,100)
	oprn:say(210,0440,"Fone:(11)3658-8892 Fax:(11)3658-8893 Email: emovere@emovere.com.br",oFont13,100)

	//labes
	oPrn:Say(090,1600,"Fatura Nº: ",oFont10,100)
	oPrn:Say(090,1800,SE1->E1_NUM,oFont10,100)
	oPrn:Say(090,1950,"Dt. Emissao: ",oFont10,100)
	oPrn:Say(090,2180,Dtoc(SE1->E1_EMISSAO),oFont10,100)

	//box
	oPrn:Box(130,1600,210,1950) //--Vencimento
	oPrn:Box(130,1950,210,2300) //--Valor Pagamento

	//variaveis vencimento + valor a pagar
	oPrn:Say(133,1662,"Vencimento",oFont11,100)
	oPrn:Say(166,1662,Dtoc(SE1->E1_VENCTO),oFont2,100)
	oPrn:Say(133,2000,"Valor a Pagar",oFont11,100)
	oPrn:Say(166,1990,"R$" + Transform(SE1->E1_VALOR,"@E 999,999,999.99"),oFont12,100)

	oPrn:Say(300,0100,"Pagador:",oFont2,100)
	oPrn:Say(300,0250,SA1->A1_NOME ,oFont12,100)

	If SA1->A1_PESSOA == "J" //--Juridica
		oprn:Say(0340,0250,'CNPJ: ' + Transform(SA1->A1_CGC,"@R 99.999.999/9999-99"),oFont13,100)
	ElseIf SA1->A1_PESSOA == "F" //--Fisica
		oprn:Say(0340,0250,'CPF: ' + Transform(SA1->A1_CGC,"@R 999.999.999-99"),oFont13,100)
	EndIf

	oPrn:Say(0340,0630,"Insc Estadual: " + SA1->A1_INSCR ,oFont13,100)
	oPrn:Say(0340,01150,"FONE: (" + SA1->A1_DDD + ") " + SA1->A1_TELDIP ,oFont13,100)

 
	oPrn:Box(0395,0100,0397,2296)
	oPrn:Say(0458,0100,"DEVOLUCOES",oFont12,100)

	//--Grade Cabecalho dos Itens da fatura
	oPrn:Box(0500,0100,0580,0275)//Numero CTR
	oPrn:Box(0500,0275,0580,0435)//Emissao
	oPrn:Box(0500,0435,0580,1135)//Destinatario
	oPrn:Box(0500,1135,0580,1310)//N.Fiscal
	oPrn:Box(0500,1310,0580,1410)//Peso
	oPrn:Box(0500,1410,0580,1585)//Val.Merc
	oPrn:Box(0500,1585,0580,1760)//B.Calc
	oPrn:Box(0500,1760,0580,1935)//ICMS / ISS
	oPrn:Box(0500,1935,0580,2110)//% Frete/Valor (rateio)
	oPrn:Box(0500,2110,0580,2285)//Valor Frete???????? CONFIRMAR COM MAXIMO
	//encerrar no maximo em 2296

	//--Cabecalho dos Itens da fatura
	oPrn:Say(0510,0110,"Numero",oFont11,100)
	oPrn:Say(0540,0110,"CTRC",oFont11,100)
	oPrn:Say(0510,0285,"Data",oFont11,100)
	oPrn:Say(0540,0285,"Emissao",oFont11,100)
	oPrn:Say(0525,0445,"Destinatario",oFont11,100)
	oPrn:Say(0525,1145,"N.Fiscal",oFont11,100)
	oPrn:Say(0525,1320,"Peso",oFont11,100)
	oPrn:Say(0510,1420,"Valor",oFont11,100)
	oPrn:Say(0540,1420,"Mercadoria",oFont11,100)
	oPrn:Say(0525,1595,"B.Calc.",oFont11,100)
	oPrn:Say(0525,1770,"ICMS",oFont11,100)
	oPrn:Say(0510,1945,"Frete/Valor",oFont11,100)
	oPrn:Say(0540,1945,"%",oFont11,100)
	oPrn:Say(0525,2120,"Valor Frete",oFont11,100)
		
	//--Verifica o numero de CTRCs, para jogar nas linhas
	nCol		:= "A"                   
	nBoxVIni	:= 1150
	nBoxVFim	:= 1200
	nConV		:= 0550
	nLimite		:= 55

	For nCont := 1 To Len(aDocDR)

	  	If nCont == nLimite

			//Montagem da grade da pagina anterior
			oPrn:Box(0580,0100,3290,0275)
			oPrn:Box(0580,0275,3290,0435)
			oPrn:Box(0580,0435,3290,1135)
			oPrn:Box(0580,1135,3290,1310)
			oPrn:Box(0580,1310,3290,1410)
			oPrn:Box(0580,1410,3290,1585)
			oPrn:Box(0580,1585,3290,1760)
			oPrn:Box(0580,1760,3290,1935)
			oPrn:Box(0580,1935,3290,2110)
			oPrn:Box(0580,2110,3290,2285)

			nPag += 1

			nLimite := nLimite+54//Rafael Rosa Obify - 09/06/22

			oprn:EndPage()
			oprn:StartPage() //--Inicio da Impressao
 			oPrn:SetPortrait() //--Retrato	
 			nCol  := "A"           
			nCnt2 := 0
			nBoxVIni := 1150
			nBoxVFim := 1200
			nConV		:= 0450

			//--Primeiro Box
    		oPrn:SayBitmap( 050, 0100, cLogoFAT, 290, 140 )

    		//--Segundo Box
			oprn:Say(050,0440,"EMOVERE LOGÍSTICA LTDA.",oFont12,100)
			oprn:say(090,0440,"AV. DR. MAURO LINDEMBERG MONTEIRO, 185, JD. SANTA FÉ - OSASCO - SP",oFont13,100)
			oprn:say(130,0440,"GALPÃO 10 - MEZANINO - BLOCO 1 - CEP: 06278-010",oFont13,100)
			oprn:say(170,0440,"C.N.P.J.:  10.245.270/0001-16    IE: 492.539.225.119",oFont13,100)
			oprn:say(210,0440,"Fone:(11)3658-8892 Fax:(11)3658-8893 Email: emovere@emovere.com.br",oFont13,100)

    		//labes
			oPrn:Say(090,1600,"Fatura Nº: ",oFont10,100)
			oPrn:Say(090,1800,SE1->E1_NUM,oFont10,100)
			oPrn:Say(090,1950,"Dt. Emissao: ",oFont10,100)
			oPrn:Say(090,2180,Dtoc(SE1->E1_EMISSAO),oFont10,100)

			//box
			oPrn:Box(130,1600,210,1950) //--Vencimento
			oPrn:Box(130,1950,210,2300) //--Valor Pagamento

			//variaveis vencimento + valor a pagar
			oPrn:Say(133,1662,"Vencimento",oFont11,100)
			oPrn:Say(166,1662,Dtoc(SE1->E1_VENCTO),oFont2,100)
			oPrn:Say(133,2000,"Valor a Pagar",oFont11,100)
			oPrn:Say(166,1990,"R$" + Transform(SE1->E1_VALOR,"@E 999,999,999.99"),oFont12,100)

    		oPrn:Say(300,0100,"Pagador:",oFont2,100)
			oPrn:Say(300,0250,SA1->A1_NOME ,oFont12,100)

   			If SA1->A1_PESSOA == "J" //--Juridica
				oprn:Say(0340,0250,'CNPJ: ' + Transform(SA1->A1_CGC,"@R 99.999.999/9999-99"),oFont13,100)
			ElseIf SA1->A1_PESSOA == "F" //--Fisica
				oprn:Say(0340,0250,'CPF: ' + Transform(SA1->A1_CGC,"@R 999.999.999-99"),oFont13,100)
			EndIf

			oPrn:Say(0340,0630,"Insc Estadual: " + SA1->A1_INSCR ,oFont13,100)

			oPrn:Say(0340,01150,"FONE: (" + SA1->A1_DDD + ") " + SA1->A1_TELDIP ,oFont13,100)

    		oPrn:Box(0395,0100,0397,2296)
			oPrn:Say(0458,0100,"DEVOLUCOES",oFont12,100)
			
			//--Grade Cabecalho dos Itens da fatura
			oPrn:Box(0500,0100,0580,0275)//Numero CTR
			oPrn:Box(0500,0275,0580,0435)//Emissao
			oPrn:Box(0500,0435,0580,1135)//Destinatario
			oPrn:Box(0500,1135,0580,1310)//N.Fiscal
			oPrn:Box(0500,1310,0580,1410)//Peso
			oPrn:Box(0500,1410,0580,1585)//Val.Merc
			oPrn:Box(0500,1585,0580,1760)//B.Calc
			oPrn:Box(0500,1760,0580,1935)//ICMS / ISS
			oPrn:Box(0500,1935,0580,2110)//% Frete/Valor (rateio)
			oPrn:Box(0500,2110,0580,2285)//Valor Frete???????? CONFIRMAR COM MAXIMO
			//encerrar no maximo em 2296
			
			//--Cabecalho dos Itens da fatura
			oPrn:Say(0510,0110,"Numero",oFont11,100)
			oPrn:Say(0540,0110,"CTRC",oFont11,100)
			oPrn:Say(0510,0285,"Data",oFont11,100)
			oPrn:Say(0540,0285,"Emissao",oFont11,100)
			oPrn:Say(0525,0445,"Destinatario",oFont11,100)
			oPrn:Say(0525,1145,"N.Fiscal",oFont11,100)
			oPrn:Say(0525,1320,"Peso",oFont11,100)
			oPrn:Say(0510,1420,"Valor",oFont11,100)
			oPrn:Say(0540,1420,"Mercadoria",oFont11,100)
			oPrn:Say(0525,1595,"B.Calc.",oFont11,100)
			oPrn:Say(0525,1770,"ICMS",oFont11,100)
			oPrn:Say(0510,1945,"Frete/Valor",oFont11,100)
			oPrn:Say(0540,1945,"%",oFont11,100)
			oPrn:Say(0525,2120,"Valor Frete",oFont11,100)

			nCnt2 += 100
		Endif      
		
		If 	nCol == "A"
			                 			
			
			nCnt2 += 50
		
			oPrn:Say(nConV+(nCnt2),0285,Dtoc(aDocDR[nCont][04]),oFont14,100) //DATA EMISSAO
			oPrn:Say(nConV+(nCnt2),0110,aDocDR[nCont][02],oFont14,100) //NUMERO CTRC
			oPrn:Say(nConV+(nCnt2),2120,Transform(aDocDR[nCont][10],"@E 999,999,999.99"),oFont14,100) //VALOR FRETE
			
			oPrn:Say(nConV+(nCnt2),1145,aDocDR[nCont][05],oFont14,100) //N.FISCAL
			oPrn:Say(nConV+(nCnt2),1420,Transform(aDocDR[nCont][08],"@E 999,999,999.99"),oFont14,100) //VALOR MERCADORIA
			oPrn:Say(nConV+(nCnt2),1945,Transform(aDocDR[nCont][13],"@E 999.99"),oFont14,100) //VALOR FRETE %

			nAliqICM	:= VAL("0."+ cValToChar(aDocDR[nCont][09]))
			nValICM	:= aDocDR[nCont][10] * nAliqICM

			IF nAliqICM = 0.7
				nTotICM7	+= nValICM
			ELSEIF nAliqICM	= 0.12
				nTotICM12	+= nValICM
			ELSEIF nAliqICM	= 0.18
				nTotICM18	+= nValICM
			ENDIF

			nTotICMDR	+= nValICM

			//NOVOS CAMPOS
			oPrn:Say(nConV+(nCnt2),0445,SUBSTRING(aDocDR[nCont][11],1,55),oFont14,100) //CNPJ + RAZAO SOCIAL	
			oPrn:Say(nConV+(nCnt2),1320,Transform(aDocDR[nCont][12],"@E 999.99"),oFont14,100) //PESO
			oPrn:Say(nConV+(nCnt2),1595,Transform(aDocDR[nCont][10],"@E 999,999,999.99"),oFont14,100) //BC IMPOSTO
			oPrn:Say(nConV+(nCnt2),1770,Transform(nValICM,"@E 999,999,999.99"),oFont14,100) //VALOR IMPOSTO

			nCol  := "A"
		EndIf		

	Next nCont
	
	//Ajuste de encerrameto da linha na grade da ultima pagina impressa
	oPrn:Box(0580,0100,nConV+(nCnt2)+50,0275)
	oPrn:Box(0580,0275,nConV+(nCnt2)+50,0435)
	oPrn:Box(0580,0435,nConV+(nCnt2)+50,1135)
	oPrn:Box(0580,1135,nConV+(nCnt2)+50,1310)
	oPrn:Box(0580,1310,nConV+(nCnt2)+50,1410)
	oPrn:Box(0580,1410,nConV+(nCnt2)+50,1585)
	oPrn:Box(0580,1585,nConV+(nCnt2)+50,1760)
	oPrn:Box(0580,1760,nConV+(nCnt2)+50,1935)
	oPrn:Box(0580,1935,nConV+(nCnt2)+50,2110)
	oPrn:Box(0580,2110,nConV+(nCnt2)+50,2285)

	DRMerc		:= 0//Rafael Rosa Obify - 06/07/22
	DRBC		:= 0//Rafael Rosa Obify - 06/07/22
	DRICMS		:= 0//Rafael Rosa Obify - 06/07/22
	DRFRETE		:= 0//Rafael Rosa Obify - 06/07/22

	aEval(aDocDR,{ |x| DRMerc	+= x[08] })
	aEval(aDocDR,{ |x| DRBC		+= x[10] })
	//aEval(aDocDR,{ |x| CIFICMS	+= x[6] })
	aEval(aDocDR,{ |x| DRFRETE	+= x[10] })

	//--Total Liquido
	//Rafael Rosa Obify - 09/06/22 - Linhas comentadas - INICIO (EM TESTE)
	oPrn:Box(nConV+(nCnt2)+65,0100,nConV+(nCnt2)+100,2285)
	oPrn:Say(nConV+(nCnt2)+65,0110,"Quantidade de CTRC'S Dev/Ret : "+Transform(Len(aDocDR),"@E 999999"),oFont14,100)
	//Rafael Rosa Obify - 09/06/22 - Linhas comentadas - FIM (EM TESTE)

	oPrn:Say(nConV+(nCnt2)+65,1420,Transform(DRMerc,"@E 999,999,999.99"),oFont14,100)
	oPrn:Say(nConV+(nCnt2)+65,1595,Transform(DRBC,"@E 999,999,999.99"),oFont14,100)
	oPrn:Say(nConV+(nCnt2)+65,1770,Transform(nTotICMDR,"@E 999,999,999.99"),oFont14,100)
	oPrn:Say(nConV+(nCnt2)+65,2120,Transform(DRFRETE,"@E 999,999,999.99"),oFont14,100)


ENDIF
//Rafael Rosa Obify - 22/06/22 - Linhas adicionadas - FIM (EM TESTE)


//RAFAEL 223/06/2022 - TOTAIS

	IF (nConV+(nCnt2)+250 >= 3200)

			oprn:EndPage()
			oprn:StartPage() //--Inicio da Impressao
 			oPrn:SetPortrait() //--Retrato

			nCnt2 := 0

			nPag += 1

	//Rafael Rosa Obify - 09/06/22 - Linha comentada (EM MANUTENCAO)
	oprn:Say(010,2200," Pag: "+Transform(nPag,"@E 99"),oFont1,100)

	//--Cabecalho da Fatura

	//--Primeiro Box
	oPrn:SayBitmap( 050, 0100, cLogoFAT, 290, 140 )
	
	//--Segundo Box
	oprn:Say(050,0440,"EMOVERE LOGÍSTICA LTDA.",oFont12,100)
	oprn:say(090,0440,"AV. DR. MAURO LINDEMBERG MONTEIRO, 185, JD. SANTA FÉ - OSASCO - SP",oFont13,100)
	oprn:say(130,0440,"GALPÃO 10 - MEZANINO - BLOCO 1 - CEP: 06278-010",oFont13,100)
	oprn:say(170,0440,"C.N.P.J.:  10.245.270/0001-16    IE: 492.539.225.119",oFont13,100)
	oprn:say(210,0440,"Fone:(11)3658-8892 Fax:(11)3658-8893 Email: emovere@emovere.com.br",oFont13,100)

	//labes
	oPrn:Say(090,1600,"Fatura Nº: ",oFont10,100)
	oPrn:Say(090,1800,SE1->E1_NUM,oFont10,100)
	oPrn:Say(090,1950,"Dt. Emissao: ",oFont10,100)
	oPrn:Say(090,2180,Dtoc(SE1->E1_EMISSAO),oFont10,100)

	//box
	oPrn:Box(130,1600,210,1950) //--Vencimento
	oPrn:Box(130,1950,210,2300) //--Valor Pagamento

	//variaveis vencimento + valor a pagar
	oPrn:Say(133,1662,"Vencimento",oFont11,100)
	oPrn:Say(166,1662,Dtoc(SE1->E1_VENCTO),oFont2,100)
	oPrn:Say(133,2000,"Valor a Pagar",oFont11,100)
	oPrn:Say(166,1990,"R$" + Transform(SE1->E1_VALOR,"@E 999,999,999.99"),oFont12,100)

	oPrn:Say(300,0100,"Pagador:",oFont2,100)
	oPrn:Say(300,0250,SA1->A1_NOME ,oFont12,100)

	If SA1->A1_PESSOA == "J" //--Juridica
		oprn:Say(0340,0250,'CNPJ: ' + Transform(SA1->A1_CGC,"@R 99.999.999/9999-99"),oFont13,100)
	ElseIf SA1->A1_PESSOA == "F" //--Fisica
		oprn:Say(0340,0250,'CPF: ' + Transform(SA1->A1_CGC,"@R 999.999.999-99"),oFont13,100)
	EndIf

	oPrn:Say(0340,0630,"Insc Estadual: " + SA1->A1_INSCR ,oFont13,100)
	oPrn:Say(0340,01150,"FONE: (" + SA1->A1_DDD + ") " + SA1->A1_TELDIP ,oFont13,100)

  		oPrn:Box(0395,0100,0397,2296)
		oPrn:Say(0458,0100,"RESUMO",oFont12,100)

		oPrn:Box(0500,0100,0540,0500)
		oPrn:Box(0540,0100,0580,0500)
		oPrn:Box(0580,0100,0620,0500)
		oPrn:Box(0620,0100,0660,0500)
		oPrn:Box(0660,0100,0700,0500)

		oPrn:Say(0500,0110,"Quantidade de documentos",oFont11,100)
		oPrn:Say(0540,0110,"Total frete / Servico CIF",oFont11,100)
		oPrn:Say(0580,0110,"Total frete / Servico FOB",oFont11,100)
		oPrn:Say(0620,0110,"Total frete devolucao",oFont11,100)
		oPrn:Say(0660,0110,"Valor total da fatura",oFont11,100)

		oPrn:Box(0500,0500,0540,0750)
		oPrn:Box(0540,0500,0580,0750)
		oPrn:Box(0580,0500,0620,0750)
		oPrn:Box(0620,0500,0660,0750)
		oPrn:Box(0660,0500,0700,0750)

		oPrn:Say(0500,0510,Transform(Len(aDoc) + Len(aDocF),"@E 999999"),oFont11,100)
		oPrn:Say(0540,0510,"R$" + Transform(CIFFRETE,"@E 999,999,999.99"),oFont11,100)
		oPrn:Say(0580,0510,"R$" + Transform(FOBFRETE,"@E 999,999,999.99"),oFont11,100)
		oPrn:Say(0620,0510,"R$" + Transform(DRFRETE,"@E 999,999,999.99"),oFont11,100)
		oPrn:Say(0660,0510,"R$" + Transform(SE1->E1_VALOR,"@E 999,999,999.99"),oFont11,100)

		oPrn:Box(0500,1000,0540,1600)
		oPrn:Box(0540,1000,0580,1600)
		oPrn:Box(0580,1000,0620,1600)
		oPrn:Box(0620,1000,0660,1600)

		oPrn:Say(0500,1010,"Valor frete/servico CIF (Aliq. 7.00%)",oFont11,100)
		oPrn:Say(0540,1010,"Valor frete/servico CIF (Aliq. 12.00%)",oFont11,100)
		oPrn:Say(0580,1010,"Valor frete/servico CIF (Aliq. 18.00%)",oFont11,100)
		oPrn:Say(0620,1010,"Valor pedagio CTRC",oFont11,100)


		oPrn:Box(0500,1600,0540,1850)
		oPrn:Box(0540,1600,0580,1850)
		oPrn:Box(0580,1600,0620,1850)
		oPrn:Box(0620,1600,0660,1850)

		oPrn:Say(0500,1610,"R$" + Transform(nTotICM7,"@E 999,999,999.99"),oFont11,100)
		oPrn:Say(0540,1610,"R$" + Transform(nTotICM12,"@E 999,999,999.99"),oFont11,100)
		oPrn:Say(0580,1610,"R$" + Transform(nTotICM18,"@E 999,999,999.99"),oFont11,100)
		oPrn:Say(0620,1610,"EM ANALISE",oFont11,100)

	ELSE

		oPrn:Say(nConV+(nCnt2)+200,0110,"RESUMO",oFont12,100)

		oPrn:Box(nConV+(nCnt2)+250,0100,nConV+(nCnt2)+290,0500)
		oPrn:Box(nConV+(nCnt2)+290,0100,nConV+(nCnt2)+330,0500)
		oPrn:Box(nConV+(nCnt2)+330,0100,nConV+(nCnt2)+370,0500)
		oPrn:Box(nConV+(nCnt2)+370,0100,nConV+(nCnt2)+410,0500)
		oPrn:Box(nConV+(nCnt2)+410,0100,nConV+(nCnt2)+450,0500)

		oPrn:Say(nConV+(nCnt2)+250,0110,"Quantidade de documentos",oFont11,100)
		oPrn:Say(nConV+(nCnt2)+290,0110,"Total frete / Servico CIF",oFont11,100)
		oPrn:Say(nConV+(nCnt2)+330,0110,"Total frete / Servico FOB",oFont11,100)
		oPrn:Say(nConV+(nCnt2)+370,0110,"Total frete devolucao",oFont11,100)
		oPrn:Say(nConV+(nCnt2)+410,0110,"Valor total da fatura",oFont11,100)

		oPrn:Box(nConV+(nCnt2)+250,0500,nConV+(nCnt2)+290,0750)
		oPrn:Box(nConV+(nCnt2)+290,0500,nConV+(nCnt2)+330,0750)
		oPrn:Box(nConV+(nCnt2)+330,0500,nConV+(nCnt2)+370,0750)
		oPrn:Box(nConV+(nCnt2)+370,0500,nConV+(nCnt2)+410,0750)
		oPrn:Box(nConV+(nCnt2)+410,0500,nConV+(nCnt2)+450,0750)

		oPrn:Say(nConV+(nCnt2)+250,0510,Transform(Len(aDoc) + Len(aDocF),"@E 999999"),oFont11,100)
		oPrn:Say(nConV+(nCnt2)+290,0510,"R$" + Transform(CIFFRETE,"@E 999,999,999.99"),oFont11,100)
		oPrn:Say(nConV+(nCnt2)+330,0510,"R$" + Transform(FOBFRETE,"@E 999,999,999.99"),oFont11,100)
		oPrn:Say(nConV+(nCnt2)+370,0510,"R$" + Transform(DRFRETE,"@E 999,999,999.99"),oFont11,100)
		oPrn:Say(nConV+(nCnt2)+410,0510,"R$" + Transform(SE1->E1_VALOR,"@E 999,999,999.99"),oFont11,100)

		oPrn:Box(nConV+(nCnt2)+250,1000,nConV+(nCnt2)+290,1600)
		oPrn:Box(nConV+(nCnt2)+290,1000,nConV+(nCnt2)+330,1600)
		oPrn:Box(nConV+(nCnt2)+330,1000,nConV+(nCnt2)+370,1600)
		oPrn:Box(nConV+(nCnt2)+370,1000,nConV+(nCnt2)+410,1600)

		oPrn:Say(nConV+(nCnt2)+250,1010,"Valor frete/servico CIF (Aliq. 7.00%)",oFont11,100)
		oPrn:Say(nConV+(nCnt2)+290,1010,"Valor frete/servico CIF (Aliq. 12.00%)",oFont11,100)
		oPrn:Say(nConV+(nCnt2)+330,1010,"Valor frete/servico CIF (Aliq. 18.00%)",oFont11,100)
		oPrn:Say(nConV+(nCnt2)+370,1010,"Valor pedagio CTRC",oFont11,100)

		oPrn:Box(nConV+(nCnt2)+250,1600,nConV+(nCnt2)+290,1850)
		oPrn:Box(nConV+(nCnt2)+290,1600,nConV+(nCnt2)+330,1850)
		oPrn:Box(nConV+(nCnt2)+330,1600,nConV+(nCnt2)+370,1850)
		oPrn:Box(nConV+(nCnt2)+370,1600,nConV+(nCnt2)+410,1850)

		oPrn:Say(nConV+(nCnt2)+250,1610,"R$" + Transform(nTotICM7,"@E 999,999,999.99"),oFont11,100)
		oPrn:Say(nConV+(nCnt2)+290,1610,"R$" + Transform(nTotICM12,"@E 999,999,999.99"),oFont11,100)
		oPrn:Say(nConV+(nCnt2)+330,1610,"R$" + Transform(nTotICM18,"@E 999,999,999.99"),oFont11,100)
		oPrn:Say(nConV+(nCnt2)+370,1610,"EM ANALISE",oFont11,100)

	ENDIF

	nTotNotas	:= 0
	aEval(aDoc,{ |x| nTotNotas += x[6] })

	//RAFAEL CONTINUAR (09/06)
	//Rafael Rosa Obify - 09/06/22 - Linha comentada
	//nCnt2 += 50

	//--Total Notas
	//oPrn:Box(nBoxVIni+nCnt2,0100,nBoxVIni+100+nCnt2,2000)
	//oPrn:Box(nBoxVIni+nCnt2,2000,nBoxVIni+100+nCnt2,2300)
	
	//Rafael Rosa Obify - 09/06/22 - Linhas comentadas - INICIO
	//oPrn:Say(nBoxVIni+(nCnt2),1086,"Valor total das notas transportadas",oFont2,100)
	//oPrn:Say(nBoxVFim+(nCnt2),1086,Transform(nTotNotas,"@E 999,999,999.99"),oFont2,100)
	//Rafael Rosa Obify - 09/06/22 - Linhas comentadas - FIM



	//--Total Bruto
	//RAFAEL 23/06 COMENTADO
	/*
	oPrn:Box(nBoxVIni+nCnt2,0100,nBoxVIni+100+nCnt2,2000)
	oPrn:Box(nBoxVIni+nCnt2,2000,nBoxVIni+100+nCnt2,2300)
	oPrn:Say(nBoxVIni+(nCnt2),2010,"Total Bruto",oFont2,100)
	oPrn:Say(nBoxVFim+(nCnt2),2010,Transform(SE1->E1_VALOR,"@E 999,999,999.99"),oFont2,100)
	*/
	
	//Rafael Rosa Obify - 09/06/22 - Linha comentada
	//nCnt2 += 100

	//--Total Liquido
	//Rafael Rosa Obify - 09/06/22 - Linhas comentadas - INICIO
	/*
	oPrn:Box(nBoxVIni+nCnt2,0100,nBoxVIni+100+nCnt2,2000)
	oPrn:Box(nBoxVIni+nCnt2,2000,nBoxVIni+100+nCnt2,2300)
	oPrn:Say(nBoxVIni+(nCnt2),2010,"Total Liquido",oFont2,100)
	oPrn:Say(nBoxVFim+(nCnt2),0110,"Quantidade de CTRC'S CIF : "+Transform(Len(aDoc),"@E 999999"),oFont2,100)
	oPrn:Say(nBoxVFim+(nCnt2),2010,Transform(SE1->E1_VALOR,"@E 999,999,999.99"),oFont2,100)
	*/
	//Rafael Rosa Obify - 09/06/22 - Linhas comentadas - FIM

	//RAFAEL CONTINUAR (09/06)
	//Rafael Rosa Obify - 09/06/22 - Linhas adicionadas - INICIO
	//oPrn:Box(nBoxVIni+nCnt2,0100,nBoxVIni+100+nCnt2,2000)
	//oPrn:Box(nBoxVIni+nCnt2,2000,nBoxVIni+100+nCnt2,2300)
	//oPrn:Say(nBoxVIni+(nCnt2),2010,"Total Liquido",oFont2,100)
	
	//Rafael Rosa Obify - 22/06/22 - Linhas comentadas - INICIO (EM TESTE)
	/*
	oPrn:Box(nConV+(nCnt2)+50,0100,nConV+(nCnt2)+100,1310)
	oPrn:Say(nConV+(nCnt2)+50,0100,"Quantidade de CTRC'S : "+Transform(Len(aDoc),"@E 999999"),oFont10,100)
	oPrn:Say(nConV+(nCnt2)+50,2010,Transform(SE1->E1_VALOR,"@E 999,999,999.99"),oFont10,100)
	*/
	//Rafael Rosa Obify - 22/06/22 - Linhas comentadas - INICIO (EM TESTE)

	//Rafael Rosa Obify - 09/06/22 - Linhas adicionadas - FIM	
	
	Eject
	DbSkip()
	
	oprn:EndPage()
	
EndDo

//--Preview em tela da impressao
oprn:Preview()

//--Enviar a Impressora
//oPrn:Print()

oprn:End()

Ms_Flush()

Return

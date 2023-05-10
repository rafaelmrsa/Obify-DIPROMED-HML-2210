/*====================================================================================\
|Programa  | DIPR009       | Autor | Rodrigo Franco             | Data | 25/01/2002   |
|=====================================================================================|
|Descrição | Inicia o processo de impressao de Orçamento                              |
|          |                                                                          |
|          |                                                                          |
|=====================================================================================|
|Sintaxe   | DIPR009                                                                  |
|=====================================================================================|
|Uso       | Especifico DIPROMED                                                      |
|=====================================================================================|
|........................................Histórico....................................|
|Rafael    | DD/MM/AA - Descrição                                                     |
|Eriberto  | DD/MM/AA - Descrição                                                     |
\====================================================================================*/

#include "rwmake.ch"
User Function DIPR009()
U_DIPPROC(ProcName(0),U_DipUsr()) // JBS 05/10/2005 - Gravando o nome do Programa no SZU
_areaSCJ := SCJ->(getarea())
_areaSCK := SCK->(getarea())
_areaSE4 := SE4->(getarea())
_areaSA1 := SA1->(getarea())
_areaSUB := SUB->(getarea())
_areaSB1 := SB1->(getarea())

aRadio := {"Orçamento de Venda","Orçamento para Licitação"}
nRadio := 1
@ 100,150 To 250,530 Dialog oDlg Title OemToAnsi("Impressao de Orcamento")
@ 010,020 say "Escolha o Tipo de Orcamento"
@ 023,050 RADIO aRadio VAR nRadio
@ 055,100 BmpButton Type 1 Action (Ok(nRadio),Close(oDlg))
@ 055,130 BmpButton Type 2 Action Close(oDlg)
Activate Dialog oDlg Centered

RestArea(_areaSCJ)
RestArea(_areaSCK)
RestArea(_areaSE4)
RestArea(_areaSA1)
RestArea(_areaSUB)
RestArea(_areaSB1)

Return

/*********************************
Ok
*********************************/
Static Function Ok(nRadio)

If nRadio == 1
	oArqMala := "Orcam1.dot"
Else
	oArqMala := "Licita1.dot"
Endif

// Eriberto 13/02/2006 Close(oDlg)

cPathCli := "C:\wordtmp\"
CpyS2T("\DOT\"+oArqMala,cPathCli,.T.) // Copia do Server para o Remote

nTamDet  := 20    //34            // Tamanho da Area de Detalhe
_cTotG   := nVez := 0

//Gerando novo documento
hWord    := OLE_CreateLink()
OLE_NewFile( hWord, cPathCli + oArqMala)

DbSelectArea("SCJ")
_nOrc    := SCJ->CJ_NUM
_cCodCli := SCJ->CJ_CLIENTE
_cCodPag := SCJ->CJ_CONDPAG
_cPraEnt := SCJ->CJ_PRAENTR
_cDtVali := SCJ->CJ_VALIDA
_cFatMin := SCJ->CJ_FATMIN
_cTipFre := SCJ->CJ_TPFRETE
_cAc     := SCJ->CJ_AC
_cObs    := SCJ->CJ_OBS
_cEmi    := DtoC(SCJ->CJ_EMISSAO)
nVal_Fre := SCJ->CJ_FRETE  /// valor do Frete
nVal_Des := SCJ->CJ_DESPESA  /// valor das Despesas
_cCont := 'Produtos:'
_cGera := 'TOTAL (produto + frete + despesa)'

If _cTipFre == "F"
	_cTipFre := "FOB"
ELSEIF _cTipFre == "I"
	_cTipFre := "INCLUSO NA NOTA"
ELSEIF _cTipFre == "C"
	_cTipFre := "CIF"
ELSEIF _cTipFre == "N"
	_cTipFre := "NOSSO CARRO"
ELSEIF _cTipFre == "R"
	_cTipFre := "RETIRA"
ENDIF
DbSelectArea("SE4")
DbSetOrder(1)
IF DbSeek(xFilial("SE4")+_cCodPag)
	_cNomPag := SE4->E4_DESCRI
ENDIF
DbSelectArea("SA1")
DbSetOrder(1)
IF DbSeek(xFilial("SA1")+_cCodCli)
	_cNomCli :=  SA1->A1_NOME
	_cEndCli :=  SUBSTR(SA1->A1_END,1,32)
	_cBaiCli :=  SUBSTR(SA1->A1_BAIRRO,1,12)
	_cMunCli :=  SA1->A1_MUN
	_cEstCli :=  SA1->A1_EST
	_cCepCli :=  SA1->A1_CEP
	_cCgcCli :=  SA1->A1_CGC
	_cInsCli :=  SA1->A1_INSCR
ENDIF
dbSelectArea("SCK")                   // * Itens de Venda da N.F.
dbSetOrder(1)
IF DbSeek(xFilial("SCK")+SCJ->CJ_NUM)
	xITEM_ORC :={}                         // Numero do Item do Pedido de Venda
	xCOD_PRO  :={}                         // Codigo  do Produto
	xQTD_PRO  :={}                         // Peso/Quantidade do Produto
	xUM_PRO   :={}                         // Peso/Quantidade do Produto
	xDESC_PRO :={}                         // Peso/Quantidade do Produto
	xPRE_UNI  :={}                         // Preco Unitario de Venda
	xVAL_MERC :={}                         // Valor da Mercadoria
	While !Eof() .AND. xFilial("SCK") == SCK->CK_FILIAL .AND. SCJ->CJ_NUM == SCK->CK_NUM
		AADD(xITEM_ORC ,ALLTRIM(SCK->CK_ITEM2))
		AADD(xCOD_PRO  ,ALLTRIM(SCK->CK_PRODUTO))
		AADD(xQTD_PRO  ,SCK->CK_QTDVEN)
		AADD(xUM_PRO   ,ALLTRIM(SCK->CK_UM))
		dbSelectArea("SB1")                   // * Itens de Venda da N.F.
		dbSetOrder(1)
		IF DbSeek(xFilial("SB1")+SCK->CK_PRODUTO)
			AADD(xDESC_PRO ,ALLTRIM(SB1->B1_DESC))
		ENDIF
		AADD(xPRE_UNI  ,SCK->CK_PRCVEN)
		AADD(xVAL_MERC ,SCK->CK_VALOR)
		_cTotG := _cTotG + SCK->CK_VALOR
		DbSelectArea("SCK")
		Dbskip()
	End
Endif
While Len(xCOD_PRO) < nTamDet
	AADD(xITEM_ORC ," ")
	AADD(xCOD_PRO  ," ")
	AADD(xQTD_PRO  ," ")
	AADD(xUM_PRO   ," ")
	AADD(xDESC_PRO ," ")
	AADD(xPRE_UNI  ," ")
	AADD(xVAL_MERC ," ")
End
nIt := 1
nPagatu := 1
While nIt <= (Len(xCOD_PRO))
	For I:=1 to nTamDet
		If nIt <= Len(xCOD_PRO)
			OLE_SetDocumentVar(hWord, "_CIT"+alltrim(str(I))  ,xITEM_ORC[nIt])
			OLE_SetDocumentVar(hWord, "_CCOD"+alltrim(str(I)) ,xCOD_PRO[nIt])
			OLE_SetDocumentVar(hWord, "_CQTD"+alltrim(str(I)) ,xQTD_PRO[nIt])
			OLE_SetDocumentVar(hWord, "_CUM"+alltrim(str(I))  ,xUM_PRO[nIt])
			OLE_SetDocumentVar(hWord, "_CDES"+alltrim(str(I)) ,xDESC_PRO[nIt])
			IF EMPTY(xPRE_UNI[nIt])
				OLE_SetDocumentVar(hWord, "_CPRV"+alltrim(str(I)) ,xPRE_UNI[nIt])
				OLE_SetDocumentVar(hWord, "_CTOT"+alltrim(str(I)) ,xVAL_MERC[nIt])
			ELSE
				OLE_SetDocumentVar(hWord, "_CPRV"+alltrim(str(I)) ,Transform(xPRE_UNI[nIt],"@E 99,999.9999"))
				OLE_SetDocumentVar(hWord, "_CTOT"+alltrim(str(I)) ,Transform(xVAL_MERC[nIt],"@E 999,999.99"))
			ENDIF
			nIt := nIt + 1
		Endif
	Next
	nPagatu := nPagatu + 1
	If nIt > Len(xCOD_PRO)
		exit
	Else
		RODAPE()
		CABECA(nRadio)
	Endif
	dbskip()
End

//³ Atualizando as variaveis do documento do Word
OLE_SetDocumentVar(hWord, "_NORC" ,_nOrc)
OLE_SetDocumentVar(hWord, "_CCODCLI" ,_cCodCli)
OLE_SetDocumentVar(hWord, "_CCODPAG" ,_cCodPag)
OLE_SetDocumentVar(hWord, "_CPRAENT" ,_cPraEnt)
OLE_SetDocumentVar(hWord, "_CDTVALI" ,_cDtVali)
OLE_SetDocumentVar(hWord, "_CFATMIN" ,Transform(_cFatMin,"@E 9,999,999.99"))
OLE_SetDocumentVar(hWord, "_CTIPFRE" ,_cTipFre)
OLE_SetDocumentVar(hWord, "_CAC" ,_cAc)
OLE_SetDocumentVar(hWord, "_COBS" ,_cObs)
OLE_SetDocumentVar(hWord, "_CCONT" ,_cCont)
OLE_SetDocumentVar(hWord, "_CGERA" ,_cGera)
OLE_SetDocumentVar(hWord, "_CEMI" ,_cEmi)
OLE_SetDocumentVar(hWord, "_CNOMPag" ,_cNomPag)
OLE_SetDocumentVar(hWord, "_CNOMCLI" ,_cNomCli)
OLE_SetDocumentVar(hWord, "_CENDCLI" ,_cEndCli)
OLE_SetDocumentVar(hWord, "_CBAICLI" ,_cBaiCli)
OLE_SetDocumentVar(hWord, "_CMUNCLI" ,_cMunCli)
OLE_SetDocumentVar(hWord, "_CESTCLI" ,_cEstCli)
OLE_SetDocumentVar(hWord, "_CCEPCLI" ,_cCepCli)
OLE_SetDocumentVar(hWord, "_CCGCCLI" ,_cCgcCli)
OLE_SetDocumentVar(hWord, "_CINSCLI" ,_cInsCli)
OLE_SetDocumentVar(hWord, "_CTOTG" ,Transform(_cTotG,"@E 9,999,999.99"))
OLE_SetDocumentVar(hWord, "_CTOTF" ,Transform(_cTotG + nVal_Fre + nVal_Des,"@E 9,999,999.99"))
OLE_SetDocumentVar(hWord, "_CFRET" ,"Frete: " + AllTrim(Transform(nVal_Fre,"@E 9,999,999.99")))
OLE_SetDocumentVar(hWord, "_CDESP" ,"Despesa: " + AllTrim(Transform(nVal_Des,"@E 9,999,999.99")))
OLE_Updatefields(hWord)
Ole_PrintFile(hWord,"ALL",,,1) // Imprime a Proposta
inkey(6)

Ole_CloseFile(hWord)
Ole_CloseLink(hWord)

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Funcao    ³  RODAPE     ³Autor ³  Rodrigo Franco     ³Data ³  25/01/2002     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³  Inicia o processo de impressao do Rodape do Orçamento           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³  DIPROMED                                                        ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function RODAPE()

OLE_SetDocumentVar(hWord, "_NORC" ,_nOrc)
OLE_SetDocumentVar(hWord, "_CCODCLI" ,_cCodCli)
OLE_SetDocumentVar(hWord, "_CCODPAG" ,_cCodPag)
OLE_SetDocumentVar(hWord, "_CPRAENT" ,_cPraEnt)
OLE_SetDocumentVar(hWord, "_CDTVALI" ,_cDtVali)
OLE_SetDocumentVar(hWord, "_CFATMIN" ,Transform(_cFatMin,"@E 9,999,999.99"))
OLE_SetDocumentVar(hWord, "_CTIPFRE" ,_cTipFre)
OLE_SetDocumentVar(hWord, "_CAC" ,_cAc)
//OLE_SetDocumentVar(hWord, "_COBS" ,"Continua na Proxima Página...")
OLE_SetDocumentVar(hWord, "_COBS" ,_cObs)
OLE_SetDocumentVar(hWord, "_cCont" , "Continua na Proxima Página...")
OLE_SetDocumentVar(hWord, "_CGERA" , "Continua na Proxima Página...")
OLE_SetDocumentVar(hWord, "_CEMI" ,_cEmi)
OLE_SetDocumentVar(hWord, "_CNOMPag" ,_cNomPag)
OLE_SetDocumentVar(hWord, "_CNOMCLI" ,_cNomCli)
OLE_SetDocumentVar(hWord, "_CENDCLI" ,_cEndCli)
OLE_SetDocumentVar(hWord, "_CBAICLI" ,_cBaiCli)
OLE_SetDocumentVar(hWord, "_CMUNCLI" ,_cMunCli)
OLE_SetDocumentVar(hWord, "_CESTCLI" ,_cEstCli)
OLE_SetDocumentVar(hWord, "_CCEPCLI" ,_cCepCli)
OLE_SetDocumentVar(hWord, "_CCGCCLI" ,_cCgcCli)
OLE_SetDocumentVar(hWord, "_CINSCLI" ,_cInsCli)
OLE_SetDocumentVar(hWord, "_CTOTG" ," ")
OLE_SetDocumentVar(hWord, "_CTOTF" ," ")
OLE_SetDocumentVar(hWord, "_CFRET" ," ")
OLE_SetDocumentVar(hWord, "_CDESP" ," ")
OLE_Updatefields(hWord)
Ole_PrintFile(hWord,"ALL",,,1) // Imprime a Proposta
inkey(6)

Ole_CloseFile(hWord)
Ole_CloseLink(hWord)

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Funcao    ³  CABECA     ³Autor ³  Rodrigo Franco     ³Data ³  25/01/2002     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³  Inicia o processo de impressao do Cabecalho do Orçamento        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³  DIPROMED                                                        ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function CABECA(nRadio)

If nRadio == 1
	oArqMala := "Orcam1.dot"
Else
	oArqMala := "Licita1.dot"
Endif
cPathCli := "C:\wordtmp\"

//Gerando novo documento
hWord := OLE_CreateLink()
OLE_NewFile( hWord, cPathCli + oArqMala)

nVez := nPagatu * nTamDet
While Len(xCOD_PRO) < nVez
	AADD(xITEM_ORC ," ")
	AADD(xCOD_PRO  ," ")
	AADD(xQTD_PRO  ," ")
	AADD(xUM_PRO   ," ")
	AADD(xDESC_PRO ," ")
	AADD(xPRE_UNI  ," ")
	AADD(xVAL_MERC ," ")
End

Return
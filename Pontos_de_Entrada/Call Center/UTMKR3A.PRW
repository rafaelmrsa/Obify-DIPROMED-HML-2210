/*====================================================================================\
|Programa  | UTMKR3A        | Autor | Rodrigo Franco             | Data | 25/01/2002   |
|=====================================================================================|
|Descrição | Inicia o processo de impressao de Orçamento                              |
|          |                                                                          |
|          |                                                                          |
|=====================================================================================|
|Sintaxe   | UTMKR3A                                                                   |
|=====================================================================================|
|Uso       | Especifico DIPROMED                                                      |
|=====================================================================================|
|........................................Histórico....................................|
|Maximo    | 25/06/07 - Alterando rotina para ser usada pelo Modulo de licitação      |
|Maximo    | 13/08/07 - Incluindo novas Inf. de clientes, operadores e transportadoras|
|Eriberto  | DD/MM/AA - Descrição                                                     |
\====================================================================================*/

#include "Protheus.ch"
#include "rwmake.ch"
#include "Dialog.ch"
#INCLUDE "COLORS.CH"
#INCLUDE "MSOLE.CH"
*----------------------------------------*
User Function UTMKR3A_Menu()
*----------------------------------------*

Ok(nRadio-3)
Return

*----------------------------------------*
User Function UTMKR3A()
*----------------------------------------*
Local oDlg
Private _lCartaVale  := .F.
Private _lComDir     := .F.//Giovani Zago 13/03/2012
Private lArquivo     := .F.

_areaSCJ := SCJ->(getarea())
_areaSCK := SCK->(getarea())
_areaUA1 := UA1->(getarea())
_areaUA4 := UA4->(getarea())
_areaSE4 := SE4->(getarea())
_areaSA1 := SA1->(getarea())
_areaSUB := SUB->(getarea())
_areaSB1 := SB1->(getarea())

U_DIPPROC(ProcName(0),U_DipUsr()) //MCVN - 22/01/2009

aRadio := {"Orçamento de Venda","Orçamento para Licitação","Orçamento sem ICMS","Programação"}
If ("MATA410"$FUNNAME())
	nRadio := If(SC5->C5_TIPODIP = '2',1,4)
Else
	nRadio := 1
Endif

_lObsProd  := .F.
_lRascunho := .F.
_lFax      := .F.

@ 100,150 To 330,530 Dialog oDlg Title OemToAnsi("Impressao de Orcamento")
@ 010,020 say "Escolha o Tipo de Orcamento"
@ 100,120 BmpButton Type 1 Action (IIf(U_VldPDF(),U_Ok2_PDF(nRadio),Ok(nRadio)), Close(oDlg))
@ 100,150 BmpButton Type 2 Action Close(oDlg)
@ 023,050 RADIO aRadio VAR nRadio
@ 060,020 CheckBox "Imprime Observação do Produto" Var _lObsProd
@ 070,020 CheckBox "Imprime como Rascunho" Var _lRascunho
@ 080,020 CheckBox "Imprime para FAX" Var _lFax // Não imprime o cinza nas linhas - MCVN 10/09/09
If ("MATA410"$FUNNAME())//Giovani Zago 13/03/2012
	@ 090,020 CheckBox "Compra Direta" Var _lComDir
EndIf
//@ 100,100 BmpButton Type 1 Action (IIf(U_VldPDF(),U_Ok2_PDF(nRadio),Ok(nRadio)), Close(oDlg))
//@ 100,130 BmpButton Type 2 Action Close(oDlg)
Activate Dialog oDlg Centered

RestArea(_areaSCJ)
RestArea(_areaSCK)
RestArea(_areaUA1)
RestArea(_areaUA4)
RestArea(_areaSE4)
RestArea(_areaSA1)
RestArea(_areaSUB)
RestArea(_areaSB1)

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³UTMKR3A    ºAutor  ³Microsiga           º Data ³  03/25/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Ok(nRadio)
Local _oDlg
Local _aMsg         := {}
Local _cAssunto     := ""
Local _cEmail       := ""
Local _cDestCli  	:= ""
Local _cFrom     	:= ""
Local _cFuncSent 	:= "UTMKR3A.PRX
Local oDlg2
Local _lSaidaP      := .F.
Local _cExplWor     := Space(100)
Local _Retorno 		:= .F.  

Private lErroval    := .f.
Private nValIpi     := 0
Private cCliST      := ""
Private _lDipImpST  := .F.
Public nValST      := 0


If   ("MATA410"$FUNNAME())
If _lComDir //Giovani Zago 13/03/2012
	AltC6Edit()
EndIf
EndIf

If nRadio == 1
	oArqMala := "OrcamNew.dot"
ElseIf nRadio == 2
	oArqMala := "Licita1.dot"
Else
	oArqMala := "liciticm1.dot"
Endif

//_aRadio1 := {"Imprimir","Imprimir e Salvar","Salvar"}
_nRadio1 := 4
@ 050,110 To 250,380 Dialog _oDlg Title OemToAnsi("O que fazer? ")
//@ 010,010 RADIO _aRadio1 VAR _nRadio1
@ 010,010 RADIO _oRadio1 VAR _nRadio1 3D Items "Word - Imprimir","Word - Imprimir e Salvar","Word - Salvar","Impressão","Impressão c/ Envio de Email" of _oDLG SIZE 75,10
@ 070,050 BmpButton Type 1 Action Close(_oDlg)

Activate MsDialog _oDlg Centered Valid _nRadio1 > 0  //.and. If(_nRadio1 >= 4,.T.,U_SENHA("PED",0,0,0) ) Desabilitada a solicitação de senha para imprimir no word MCVN - 09/04/2008

_lTmsPrinter:= (_nRadio1 >= 4)


// Opção para escolher a tipo de frete a ser impresso no Orçamento(Apenas Informativo e Somente para BECS)  MCVN - 25/06/07
If "DIPAL10" $ FunName() .And. UA1->UA1_TIPO $ "6/2"
	
	_aFreteRadio := {"CIF","NOSSO CARRO"}
	_nFreteRadio := 1
	@ 050,110 To 150,280 Dialog _oDlg Title OemToAnsi("Frete do Orçamento! ")
	@ 010,010 RADIO _aFreteRadio VAR _nFreteRadio
	
	@ 035,050 BmpButton Type 1 Action Close(_oDlg)
	
	Activate MsDialog _oDlg Centered Valid _nFreteRadio > 0
	
EndIf

nTamDet  := 20                // Tamanho da Area de Detalhe
_cTotG   := _cTotI := nVez := 0

If !_lTmsPrinter
	cPathCli := "C:\wordtmp\"
	CpyS2T("\DOT\"+oArqMala,cPathCli,.T.) // Copia do Server para o Remote
	
	//Gerando novo documento
	hWord := OLE_CreateLink()
	OLE_NewFile( hWord, cPathCli + oArqMala)
EndIf

_cIA := "0,00"
_cIL := "0,00"
If "TMK" $ FunName() .or. (Type("lMenu") <> "U" .and. lMenu .and. (!"DIPAL10" $ FunName() .and. !"MATA410" $ FunName()))
	
	DbSelectArea("SUA")
	_nOrc    := SUA->UA_NUM
	_cCodCli := SUA->UA_CLIENTE
	_cCodPag := SUA->UA_CONDPG
	_cPraEnt := SUA->UA_PRAENT
	_cDtVali := SUA->UA_DTLIM
	_cFatMin := SUA->UA_FATMIN
	_cTipFre := SUA->UA_TPFRETE
	_cDestFre:= SUA->UA_DESTFRE //MCVN - 14/05/09
	_cAc     := SUA->UA_AC
	_cObs    := SUA->UA_MENNOTA
	_cEmi    := DtoC(SUA->UA_EMISSAO)
	nVal_Fre := SUA->UA_FRETE  /// valor do Frete
	nVal_Des := SUA->UA_DESPESA  /// valor das Despesas
	_cOperado:= SUA->UA_OPERADO
	_cNomeOpe:= Alltrim(Posicione("SU7",1,xFilial("SU7")+SUA->UA_OPERADO,"U7_NREDUZ"))
	_cMailOpe:= Alltrim(Posicione("SU7",1,xFilial("SU7")+SUA->UA_OPERADO,"U7_EMAIL"))
	_cPosto  := Posicione("SU7",1,xFilial("SU7")+SUA->UA_OPERADO,"U7_POSTO")
	_cVend   := SUA->UA_VEND
	_cNomeVen:= Alltrim(Posicione("SA3",1,xFilial("SA3")+SUA->UA_VEND,"A3_NOME"))
	_cMailVen:= Alltrim(Posicione("SA3",1,xFilial("SA3")+SUA->UA_VEND,"A3_EMAIL"))
	_cTipoVen:= Posicione("SA3",1,xFilial("SA3")+SUA->UA_VEND,"A3_TIPO")
	_cTransp := SUA->UA_TRANSP
	_cNomeTra:= Posicione("SA4",1,xFilial("SA4")+SUA->UA_TRANSP,"A4_NOME")
	If "TMK" $ FunName() // MCVN - 13/08/2007
		_cEndCli := SUBSTR(SUA->UA_ENDENT,1,60)    // End de entrega
		_cBaiCli := SUBSTR(SUA->UA_BAIRROE,1,30)
		_cMunCli := SUA->UA_MUNE
		_cEstCli := SUA->UA_ESTE
		_cCepCli := SUA->UA_CEPE
	Endif
	_cIA	 := SUA->UA_MARGATU
	_cIL	 := SUA->UA_MARGLIB
	_cCont := 'Produtos:'
	_cGera := 'TOTAL (produto + frete + despesa)'
	
ELSEIF "DIPAL10" $ FunName() // Quando a Rotina chamada de dentro do Módulo de Licitação MCVN - 25/06/07
	
	DbSelectArea("UA1")
	_nOrc    := UA1->UA1_CODIGO
	_cCodCli := UA1->UA1_CODCLI
	_cCodPag := UA1->UA1_CONDPA
	_cPraEnt := UA1->UA1_DENTRE
	_cDtVali := ""//SUA->UA_DTLIM
	_cFatMin := 0 //SUA->UA_FATMIN
	_cTipFre := Iif(UA1->UA1_TIPO $ "6/2",Iif (_nFreteRadio == 1,"CIF","NOSSO CARRO"),"")
	_cDestFre:= ""
	_cAc     := ""//SUA->UA_AC
	_cObs    := ""
	_cEmi    := DtoC(UA1->UA1_EMISSA)
	nVal_Fre := 0 //SUA->UA_FRETE  /// valor do Frete
	nVal_Des := 0 //SUA->UA_DESPESA  /// valor das Despesas
	_cOperado:= "" // Operador
	_cNomeOpe:= Alltrim(Posicione("SU7",3,xFilial("SU7")+UA1->UA1_USUDIG,"U7_NREDUZ"))
	_cMailOpe:= Alltrim(Posicione("SU7",3,xFilial("SU7")+UA1->UA1_USUDIG,"U7_EMAIL"))
	_cTipoVen:= Posicione("SA3",1,xFilial("SA3")+UA1->UA1_VEND,"A3_TIPO")
	_cPosto  := "03" // Posto do Operador
	_cTransp := "" // Transportadora
	_cNomeTra:= "" // Nome da transportadora
	_cVend   := "" // Vendedor
	_cNomeVen:= "" // Nome do Vendedor
	_cMailVen:= "" // E-mail do Vendedor
	_cCont   := 'Produtos:'
	_cGera   := 'TOTAL (produto + frete + despesa)'
	_cIA	 := UA1->UA1_MARGAT
	_cIL     := UA1->UA1_MARGLI
	
	
ELSEIF "MATA410" $ FunName() // Quando a Rotina chamada de dentro do Módulo de Licitação MCVN - 25/06/07
	
	DbSelectArea("SC5")
	
	_nOrc    := SC5->C5_NUM
	_cCodCli := SC5->C5_CLIENTE
	_cCodPag := SC5->C5_CONDPAG
	_cPraEnt := SC5->C5_PRAENT
	_cDtVali := SC5->C5_DTLIM
	_cFatMin := SC5->C5_FATMIN
	_cTipFre := SC5->C5_TPFRETE
	_cDestFre:= SC5->C5_DESTFRE //MCVN - 14/05/09
	_cAc     := SC5->C5_AC
	_cObs    := SC5->C5_MENNOTA
	_cEmi    := DtoC(SC5->C5_EMISSAO)
	nVal_Fre := SC5->C5_FRETE  /// valor do Frete
	nVal_Des := SC5->C5_DESPESA  /// valor das Despesas
	_cOperado:= SC5->C5_OPERADO
	_cNomeOpe:= Alltrim(Posicione("SU7",1,xFilial("SU7")+SC5->C5_OPERADO,"U7_NREDUZ"))
	_cMailOpe:= Alltrim(Posicione("SU7",1,xFilial("SU7")+SC5->C5_OPERADO,"U7_EMAIL"))
	_cPosto  := Posicione("SU7",1,xFilial("SU7")+SC5->C5_OPERADO,"U7_POSTO")
	_cTransp := SC5->C5_TRANSP
	_cNomeTra:= Posicione("SA4",1,xFilial("SA4")+SC5->C5_TRANSP,"A4_NOME")
	_cVend   := SC5->C5_VEND1
	_cNomeVen:= Alltrim(Posicione("SA3",1,xFilial("SA3")+SC5->C5_VEND1,"A3_NOME"))
	_cMailVen:= Alltrim(Posicione("SA3",1,xFilial("SA3")+SC5->C5_VEND1,"A3_EMAIL"))
	_cTipoVen:= Posicione("SA3",1,xFilial("SA3")+SC5->C5_VEND1,"A3_TIPO")
	_cCont   := 'Produtos:'
	_cGera   := 'TOTAL (produto + frete + despesa)'
	_cIA	 := SC5->C5_MARGATU
	_cIL	 := SC5->C5_MARGLIB
	_cEndCli := SUBSTR(SC5->C5_ENDENT,1,60)  // End de entrega
	_cBaiCli := SUBSTR(SC5->C5_BAIRROE,1,30)
	_cMunCli := SC5->C5_MUNE
	_cEstCli := SC5->C5_ESTE
	_cCepCli := SC5->C5_CEPE
	
ELSE
	
	DbSelectArea("SCJ")
	_nOrc    := SCJ->CJ_NUM   //////  UA_NUM
	_cCodCli := SCJ->CJ_CLIENTE       ///// UA_CLIENTE
	_cCodPag := SCJ->CJ_CONDPAG      ////// UA_CONDPG
	_cPraEnt := SCJ->CJ_PRAENTR       ////
	_cDtVali := SCJ->CJ_VALIDA       /////   UA_DTLIM
	_cFatMin := SCJ->CJ_FATMIN      //////
	_cTipFre := SCJ->CJ_TPFRETE     ///////   UA_TPFRETE
	_cDestFre:= ""
	_cAc     := SCJ->CJ_AC          //////
	_cObs    := SCJ->CJ_OBS           //////  UA_OBS
	_cEmi    := DtoC(SCJ->CJ_EMISSAO)
	nVal_Fre := SCJ->CJ_FRETE  /// valor do Frete
	nVal_Des := SCJ->CJ_DESPESA  /// valor das Despesas
	_cOperado:= "" // Operador
	_cNomeOpe:= ""
	_cMailOpe:= ""
	_cPosto  := "" // Posto do Operador
	_cTransp := "" // Transportadora
	_cNomeTra:= "" // Nome da transportadora
	_cVend   := "" // Vendedor
	_cNomeVen:= "" // Nome do Vendedor
	_cMailVen:= "" // E-mail do Vendedor
	_cCont := 'Produtos:'
	_cGera := 'TOTAL (produto + frete + despesa)'
	
ENDIF

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
_cNomPag := ""
IF DbSeek(xFilial("SE4")+_cCodPag)
	_cNomPag := SE4->E4_DESCRI
ENDIF


If SC5->C5_TIPO $ "BD"
	DbSelectArea("SA2")
	DbSetOrder(1)
	IF DbSeek(xFilial("SA2")+_cCodCli)
		
		_cNomCli :=  SA2->A2_NOME
		If !("TMK" $ FunName()) .And. !("MATA410" $ FunName())// MCVN - 13/08/2007
			_cEndCli :=  SUBSTR(SA2->A2_END,1,60)
			_cBaiCli :=  SUBSTR(SA2->A2_BAIRRO,1,30)
			_cMunCli :=  SA2->A2_MUN
			_cEstCli :=  SA2->A2_EST
			_cCepCli :=  SA2->A2_CEP
		Endif
		_cCgcCli :=  SA2->A2_CGC
		_cInsCli :=  SA2->A2_INSCR
		_cTelCli :=  SA2->A2_TEL
		_cFaxCli :=  SA2->A2_FAX
		_cSuframa := ""//SA2->A2_SUFRAMA
		_cCalcSuf := ""//SA2->A2_CALCSUF
	ENDIF
Else
	DbSelectArea("SA1")
	DbSetOrder(1)
	IF DbSeek(xFilial("SA1")+_cCodCli)
		
		_cNomCli :=  SA1->A1_NOME
		If !("TMK" $ FunName()) .And. !("MATA410" $ FunName())// MCVN - 13/08/2007
			_cEndCli :=  SUBSTR(SA1->A1_END,1,60)
			_cBaiCli :=  SUBSTR(SA1->A1_BAIRRO,1,30)
			_cMunCli :=  SA1->A1_MUN
			_cEstCli :=  SA1->A1_EST
			_cCepCli :=  SA1->A1_CEP
		Endif
		_cCgcCli :=  SA1->A1_CGC
		_cInsCli :=  SA1->A1_INSCR
		_cTelCli :=  If(Empty(SA1->A1_DDD),ALLTRIM(SA1->A1_TEL),"("+SA1->A1_DDD+")"+ALLTRIM(SA1->A1_TEL))
		_cFaxCli :=  SA1->A1_FAX
		_cSuframa:=  SA1->A1_SUFRAMA
		_cCalcSuf :=  SA1->A1_CALCSUF
		cCliST:= SA1->A1_TIPO
		
		If !(SA1->A1_EST$'SP/DF/AM/CE/GO/RN') .And. !Empty(SA1->A1_INSCR) .And. SC5->C5_TIPO=='N' .And. SA1->A1_TIPO=="R"  .And. SA1->A1_CONTRIB <> '2' .And. Empty(AllTrim(SA1->A1_DREGESP)) 
			_lDipImpST := .T.
		EndIf
	ENDIF
EndIf

xITEM_ORC :={}                         // Numero do Item do Pedido de Venda
xCOD_PRO  :={}                         // Codigo  do Produto
xQTD_PRO  :={}                         // Peso/Quantidade do Produto
xUM_PRO   :={}                         // Peso/Quantidade do Produto
xDESC_PRO :={}                         // Peso/Quantidade do Produto
xREG_ANVI :={}                         // Registro Anvisa do Produto
xPRE_UNI  :={}                         // Preco Unitario de Venda
xVAL_MERC :={}                         // Valor da Mercadoria
xAliq_Pro :={}                         // aliquota icms
xVal_cICM :={}                         // preco com ICMS incluso
xAli_IPI  :={}
xVal_IPI  :={}
xVal_ST	  :={}
xIA		  :={}
xIL		  :={}

If "TMK" $ FunName().or.(Type("lMenu") <> "U" .and. lMenu .and. (!"DIPAL10" $ FunName() .And. "MATA410" $ FunName()))
	dbSelectArea("SUB")                   // * Itens de Venda da N.F.
	dbSetOrder(1)
	IF DbSeek(xFilial("SUB")+SUA->UA_NUM)
		While SUB->(!Eof()) .AND. xFilial("SUB") == SUB->UB_FILIAL .AND. SUA->UA_NUM == SUB->UB_NUM
			AADD(xITEM_ORC ,ALLTRIM(SUB->UB_ITEM))     // UB_ITEM
			AADD(xCOD_PRO  ,ALLTRIM(SUB->UB_PRODUTO))  // UB_PRODUTO
			
			AADD(xIA  	   ,SUB->UB_MARGATU)
			AADD(xIL       ,SUB->UB_MARGITE)
			
			AADD(xQTD_PRO  ,SUB->UB_QUANT)             // UB QUANT
			AADD(xUM_PRO   ,ALLTRIM(SUB->UB_UM))       // UB_UM
			AADD(xDESC_PRO ,ALLTRIM(Posicione("SB1",1,xFilial("SB1")+SUB->UB_PRODUTO,"B1_DESC"))) // B1_DESC
			AADD(xALIQ_PRO ,Posicione("SB1",1,xFilial("SB1")+SUB->UB_PRODUTO,"B1_PICM")) // B1_PICM
			AADD(xPRE_UNI  ,Iif(nRadio==3,Round(SUB->UB_VRUNIT / ((100-Posicione("SB1",1,xFilial("SB1")+SUB->UB_PRODUTO,"B1_PICM"))/100),3),SUB->UB_VRUNIT))  //  UB_VRUNIT
			AADD(xVAL_MERC ,SUB->UB_VLRITEM)           //  UB_VLRITEM
			AADD(xVAL_cICM ,Round(SUB->UB_VRUNIT / ((100-Posicione("SB1",1,xFilial("SB1")+SUB->UB_PRODUTO,"B1_PICM"))/100),3) * SUB->UB_QUANT) //  VALOR COM ICMS INCLUSO
			_cTotG := _cTotG + SUB->UB_VLRITEM         // TOTAL GERAL
			_cTotI += Round(SUB->UB_VRUNIT / ((100-Posicione("SB1",1,xFilial("SB1")+SUB->UB_PRODUTO,"B1_PICM"))/100),3) * SUB->UB_QUANT // TOTAL GERAL COM ICMS
			
			If !lErroVal  // MCVN - 20/10/2008
				If POSICIONE("SE4", 1, XFilial("SE4")+SUA->UA_CONDPG, "E4_USERDES") > 0 //11/11/2008
					If Round((SUB->UB_USERPRC * SUB->UB_QUANT)-SUB->UB_USERDES,2) <> SUB->UB_VLRITEM .And. (Empty(_cSuframa) .Or. _cCalcSuf = 'N')
						lErroVal := .T.
					Endif
				Else
					If Round((SUB->UB_VRUNIT * SUB->UB_QUANT),2) <> SUB->UB_VLRITEM .And. (Empty(_cSuframa) .Or. _cCalcSuf = 'N')
						lErroVal := .T.
					Endif
				Endif
			Endif
			SUB->(Dbskip())
		End
	ELSE
		dbSelectArea("SCK")                   // * Itens de Venda da N.F.
		dbSetOrder(1)
		IF DbSeek(xFilial("SCK")+SCJ->CJ_NUM)
			While !Eof() .AND. xFilial("SCK") == SCK->CK_FILIAL .AND. SCJ->CJ_NUM == SCK->CK_NUM
				AADD(xITEM_ORC ,ALLTRIM(SCK->CK_ITEM2))    ///// UB_ITEM
				AADD(xCOD_PRO  ,ALLTRIM(SCK->CK_PRODUTO))  ///// UB_PRODUTO
				AADD(xQTD_PRO  ,SCK->CK_QTDVEN)            ////// UB QUANT
				AADD(xUM_PRO   ,ALLTRIM(SCK->CK_UM))       ////// UB_UM
				AADD(xIA  	   ,0)
				AADD(xIL       ,0)
				dbSelectArea("SB1")                   // * Itens de Venda da N.F.
				dbSetOrder(1)
				IF DbSeek(xFilial("SB1")+SCK->CK_PRODUTO)
					AADD(xDESC_PRO ,ALLTRIM(SB1->B1_DESC))
				ENDIF
				AADD(xPRE_UNI  ,SCK->CK_PRCVEN)  ////  UB_VRUNIT
				AADD(xVAL_MERC ,SCK->CK_VALOR)   ////  UB_VLRITEM
				_cTotG := _cTotG + SCK->CK_VALOR
				
				If !lErroVal   // MCVN - 20/10/2008
					If Round((SCK->CK_PRCVEN * SCK->CK_QTDVEN),2) <> SCK->CK_VALOR .And. (Empty(_cSuframa) .Or. _cCalcSuf = 'N')
						lErroVal := .T.
					Endif
				Endif
				DbSelectArea("SCK")
				Dbskip()
			End
		ENDIF
	Endif
ElseIf "MATA410" $ FunName() // MCVN - 18/06/09
	dbSelectArea("SC6")                   // * ITENS DO PEDIDO DE VENDA
	dbSetOrder(1)
	IF DbSeek(xFilial("SC6")+SC5->C5_NUM)
		While SC6->(!Eof()) .AND. xFilial("SC6") == SC6->C6_FILIAL .AND. SC5->C5_NUM == SC6->C6_NUM
		
			If ("MATA410"$FUNNAME())//Giovani Zago 13/03/2012
				AADD(xITEM_ORC ,Iif(Empty(C6_LICITA),ALLTRIM(SC6->C6_ITEM),alltrim(SC6->C6_LICITA))) // Giovani Zago 09/03/2012
			Else
				AADD(xITEM_ORC ,ALLTRIM(SC6->C6_ITEM))
			EndIf
			AADD(xCOD_PRO  ,ALLTRIM(SC6->C6_PRODUTO))
			AADD(xQTD_PRO  ,SC6->C6_QTDVEN)
			
			AADD(xIA  	   ,SC6->C6_MARGATU)
			AADD(xIL       ,SC6->C6_MARGITE)
			
			AADD(xUM_PRO   ,ALLTRIM(SC6->C6_UM))
			AADD(xDESC_PRO ,ALLTRIM(SC6->C6_DESCRI))
			//			AADD(xPRE_UNI  ,SC6->C6_PRCVEN)
			//			AADD(xVAL_MERC ,SC6->C6_VALOR)
			AADD(xREG_ANVI ,Posicione("SB1",1,xFilial("SB1")+SC6->C6_PRODUTO,"B1_REG_ANV")) // B1_REG_ANV							
			AADD(xALIQ_PRO ,Posicione("SB1",1,xFilial("SB1")+SC6->C6_PRODUTO,"B1_PICM")) // B1_PICM
			AADD(xPRE_UNI  ,Iif(nRadio==3 ,Round(SC6->C6_PRCVEN / ((100-SB1->B1_PICM)/100),3),SC6->C6_PRCVEN))
			AADD(xVAL_MERC ,SC6->C6_VALOR)
			AADD(xAli_IPI ,Posicione("SB1",1,xFilial("SB1")+SC6->C6_PRODUTO,"B1_IPI")) // B1_IPI 
			AADD(xVAL_IPI  ,Round(U_CALCIPI(SC6->C6_NUM,SC6->C6_PRODUTO, SC6->C6_ITEM),2)) 

			If _lDipImpST    			
				aAdd(xVal_ST ,Round(CalcSTItem(SC6->C6_PRODUTO,SC6->C6_VALOR),2))
			Else
			  	If cEmpAnt == "04"
			  		impostos(SC6->C6_NUM,SC6->C6_ITEM,SC6->C6_PRODUTO,@nValST)
			  		aAdd(xVal_ST ,nValST) 				
			  		nValST := 0
				Else
					aAdd(xVal_ST,0)
				EndIF
			EndIf
						
			AADD(xVAL_cICM ,Round(SC6->C6_PRCVEN / ((100-SB1->B1_PICM)/100),3) * SC6->C6_QTDVEN) //  VALOR COM ICMS INCLUSO
			
			_cTotG := _cTotG + SC6->C6_VALOR
			_cTotI += Round(SC6->C6_PRCVEN / ((100-SB1->B1_PICM)/100),3) * SC6->C6_QTDVEN
			
			
			If !lErroVal  // MCVN - 20/10/2008
				If POSICIONE("SE4", 1, XFilial("SE4")+SUA->UA_CONDPG, "E4_USERDES") > 0 //11/11/2008
					If Round((SC6->C6_USERPRC * SC6->C6_QTDVEN)-SC6->C6_USERDES,2) <> SC6->C6_VALOR .And. (Empty(_cSuframa) .Or. _cCalcSuf = 'N')
						lErroVal := .T.
					Endif
				Else
					If Round((SC6->C6_PRCVEN  * SC6->C6_QTDVEN),2) <> SC6->C6_VALOR .And. (Empty(_cSuframa) .Or. _cCalcSuf = 'N')
						lErroVal := .T.
					Endif
				Endif
			Endif
			
			
			DbSelectArea("SC6")
			Dbskip()
		End
	Endif
	
ElseIf "DIPAL10" $ FunName() //MCVN - 25/06/07
	_nDescICMS := 0
	dbSelectArea("UA4")                   // * Itens Edital
	dbSetOrder(1)
	IF DbSeek(xFilial("UA4")+UA1->UA1_CODIGO)
		While UA4->(!Eof()) .AND. xFilial("UA4") == UA4->UA4_FILIAL .AND. UA1->UA1_CODIGO == UA4->UA4_EDITAL
			AADD(xITEM_ORC ,Iif(!Empty(UA4->UA4_LOTE),ALLTRIM(UA4->UA4_LOTE)+"."+ALLTRIM(UA4->UA4_ITEMLT),UA4->UA4_ITEMAM))//ALLTRIM(UA4->UA4_ITEM))
			AADD(xCOD_PRO  ,ALLTRIM(UA4->UA4_PRODUT))
			AADD(xQTD_PRO  ,UA4->UA4_QUANT)
			AADD(xIA  	   ,UA4->UA4_MARGAT)
			AADD(xIL       ,UA4->UA4_MARGIT)
			AADD(xUM_PRO   ,ALLTRIM(UA4->UA4_UM))
			AADD(xDESC_PRO ,ALLTRIM(Posicione("SB1",1,xFilial("SB1")+UA4->UA4_PRODUT,"B1_DESC"))) // B1_DESC
			AADD(xREG_ANVI ,Posicione("SB1",1,xFilial("SB1")+UA4->UA4_PRODUT,"B1_REG_ANV")) // B1_REG_ANV							
			AADD(xALIQ_PRO ,Posicione("SB1",1,xFilial("SB1")+UA4->UA4_PRODUT,"B1_PICM")) // B1_PICM
			AADD(xPRE_UNI  ,Iif(nRadio==3 ,Round(UA4->UA4_PRCMIN / ((100-Posicione("SB1",1,xFilial("SB1")+UA4->UA4_PRODUT,"B1_PICM"))/100),3),UA4->UA4_PRCMIN))
			AADD(xVAL_MERC ,UA4->UA4_PRCMIN*UA4->UA4_QUANT)
			AADD(xVAL_cICM ,Round(UA4->UA4_PRCMIN / ((100-Posicione("SB1",1,xFilial("SB1")+UA4->UA4_PRODUT,"B1_PICM"))/100),3) * UA4->UA4_QUANT) //  VALOR COM ICMS INCLUSO
			
			_cTotG := _cTotG + (UA4->UA4_PRCMIN*UA4->UA4_QUANT)         // TOTAL GERAL
			_cTotI += Round(UA4->UA4_PRCMIN / ((100-Posicione("SB1",1,xFilial("SB1")+UA4->UA4_PRODUT,"B1_PICM"))/100),2) * UA4->UA4_QUANT // TOTAL GERAL COM ICMS
			
			If !lErroVal   // MCVN - 20/10/2008
				If Round((UA4->UA4_PRCMIN * UA4->UA4_QUANT),2) <> UA4->UA4_TOTAL .And. (Empty(_cSuframa) .Or. _cCalcSuf = 'N')
					lErroVal := .T.
				Endif
			Endif
			
			UA4->(Dbskip())
		End
		_nDescICMS := (_cTotI-_cTotG)
		If UA1->UA1_TIPO $ "6/2"  //MCVN - 05/10/2007
			_cObs      := "Desc.ICMS R$ "+Alltrim(Str(_nDescICMS,10,2))+" - "+Alltrim(UA1->UA1_PROCES)+" - "+Alltrim(UA1->UA1_NRCONC)
		Endif
	Else
	ENDIF
	
	
EndIf

While Len(xCOD_PRO) < nTamDet
	AADD(xITEM_ORC ," ")
	AADD(xCOD_PRO  ," ")
	AADD(xQTD_PRO  ," ")
	AADD(xUM_PRO   ," ")
	AADD(xDESC_PRO ," ")
    AADD(xREG_ANVI ," ")
	AADD(xPRE_UNI  ," ")
	AADD(xVAL_MERC ," ")
	AADD(xAliq_Pro ," ")
	AADD(xVal_cICM ," ")
	AADD(xVal_IPI  ," ")
	AADD(xVal_ST   ," ")
	AADD(xIA  	   ," ")
	AADD(xIL       ," ")
End

nIt := 1
nPagatu := 1

If lErroVal
	MsgAlert("Existe(m) erro(s) nos valores unitários e totais, FAVOR CONFERIR VALORES ANTES DE ENVIAR O ORÇAMENTO AO CLIENTE!","Atenção")
	_cFrom   := Lower(Alltrim(_cMailOpe))
	_cEmail  := SUPERGETMV("MV_#EMLTI",.F.,"ti@dipromed.com.br")+";"+Lower(Alltrim(_cMailOpe))
	_cAssunto:= EncodeUTF8("Problema nos valores unitários - Orçamento  "+_nOrc+" não impresso!  CONFERIR OS VALORES DO ORÇAMENTO","cp1252")
	Aadd( _aMsg , { "Operador: "            , _cOperado +" - "+ _cNomeOpe } )
	Aadd( _aMsg , { "Cliente:  "            , _cCodCli  +" - "+ _cNomCli  } )
	Aadd( _aMsg , { "Explicação: "          , _cExplWor } )
	U_UEnvMail(_cEmail,_cAssunto,_aMsg,"",_cFrom,_cFuncSent)
Endif


If _lTmsPrinter
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Impressao do relatorio                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Private nlin    	 := 50
	Private ArialN6      := TFont():New("Arial"	,,6	,,.F.,,,,,.F.)
	Private ArialN6B     := TFont():New("Arial"	,,6	,,.T.,,,,,.F.)
	Private ArialN8      := TFont():New("Arial"	,,8	,,.F.,,,,,.F.)
	Private ArialN8B     := TFont():New("Arial"	,,8	,,.T.,,,,,.F.)
	Private ArialN9      := TFont():New("Arial"	,,9	,,.F.,,,,,.F.)
	Private ArialN9B     := TFont():New("Arial"	,,9	,,.T.,,,,,.F.)
	Private ArialN10     := TFont():New("Arial"	,,10,,.F.,,,,,.F.)
	Private ArialN10B    := TFont():New("Arial"	,,10,,.T.,,,,,.F.)
	Private ArialN10C    := TFont():New("Arial"	,,10,,.T.,,,,,.F.,.T.)
	Private ArialN12     := TFont():New("Arial"	,,12,,.F.,,,,,.F.)
	Private ArialN12B    := TFont():New("Arial"	,,12,,.T.,,,,,.F.)
	Private ArialN14     := TFont():New("Arial"	,,14,,.F.,,,,,.F.)
	Private ArialN14B    := TFont():New("Arial"	,,14,,.T.,,,,,.F.)
	Private ArialN16     := TFont():New("Arial"	,,16,,.F.,,,,,.F.)
	Private ArialN16B    := TFont():New("Arial"	,,16,,.T.,,,,,.F.)
	Private ArialN18     := TFont():New("Arial"	,,18,,.F.,,,,,.F.)
	Private ArialN18B    := TFont():New("Arial"	,,18,,.T.,,,,,.F.)
	Private ArialN20     := TFont():New("Arial"	,,20,,.F.,,,,,.F.)
	Private ArialN20B    := TFont():New("Arial"	,,20,,.T.,,,,,.F.)
	Private Times14	     := TFont():New("Times New Roman",,14,,.T.,,,,,.F. )
	Private Times20      := TFont():New("Times New Roman",,20,,.T.,,,,,.F. )
	Private CourN10      := TFont():New("Courier New",,10,,.F.,,,,.T.,.F.)
	Private CourN10B     := TFont():New("Courier New",,10,,.T.,,,,.T.,.F.)
	Private _lICM 		 := (nRadio == 3)
	Private _cNomTel     := ""
	
	oPrint:= TMSPrinter():New()
	
	//oPrint:SetPortrait()
	oPrint:SetLandScape() //- retrato ou paisagem
	//oPrint:Setup()
	
	If nRadio == 1
		//		_cTelefon 	:= If(_cPosto == '01',"APOIO:  0800-7700217","TELEVENDAS: 0800-0114066")
		//		_cFax		:= "FAX: 0800-0144997"
		_cTelefon	:= If(cEmpAnt+cFilAnt == '0401',"(11) 2398-1888",If(_cPosto == '01',"APOIO:  0800-7700217","TELEVENDAS: 0800-0114066"))
		_cFax		:= If(cEmpAnt+cFilAnt == '0401',"FAX: (11) 2398-1888","FAX: 0800-0144997")
	Else
		If cEmpAnt+cFilAnt == '0401
			_cTelefon 	:= "TELEFONE: (11) 2398-1888"
			_cFax		:= "FAX: (11) 2398-1888"
		Else 
			_cTelefon 	:= "TELEFONE: (11) 3646-0192"
			_cFax		:= "FAX: (11) 3646-0193"		
		EndIf
	EndIf
	_cTitulo	:= If(nRadio = 4,"PROGRAMACAO","ORCAMENTO")
	_cTitulo2	:= If(nRadio != 1 .And. nRadio != 4,"LICITAÇÕES","")
	_cDipMail	:= If(nRadio != 1 .And. nRadio != 4,"publico",If(_cPosto == '01',"dipromed","televendas"))+"@dipromed.com.br"
	_cDipMail   := If(cEmpAnt+cFilAnt == '0401',"www.healthquality.ind.br   -   vendas@healthquality.ind.br","www.dipromed.com.br  -  "+_cDipMail)
	nPagina 	:= 0
	
	If Alltrim(_cTelCli) == Alltrim(_cFaxCli) // Tratando telefone  MCVN - 10/08/07
		_cNomTel := "Fone/Fax:"
	Else
		_cNomTel := "Fone:"
		_CTELCLI := _cTelCli+If(!Empty(Alltrim(_cFaxCli))," - Fax: "+_cFaxCli,"")
	Endif
	
	U_CabecPV(@nlin)
	U_CorpoPV(@nlin)
	U_FinalPV()
	U_RodapePV()
	If !_lRascunho .And. _nRadio1 == 5
		_cTo		:= Alltrim(SA1->A1_EMAILD)+If(_cPosto $ '01/03',";"+_cMailVen,Space(1))+Space(60)
		_cBodyPrvt 	:= U_RetBody(@_cTo)
		If !Empty(_cTo)
			U_JpegMail(_cMailOpe,_cTo,_cTipoVen)
		EndIf
		
	ElseIf _lRascunho .And. _nRadio1 == 5
		MsgAlert("O e-mail não será enviado, pois foi selecionada a opção de Rascunho!","Atenção")
	Else
		U_PvCpFile() // CRIAR ARQUIVO NA MÁQUINA DO USUÁRIO - MCVN - 05/03/2008
	EndIf
	
	oPrint:Preview()
Else
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
					OLE_SetDocumentVar(hWord, "_CICM"+alltrim(str(I)) ,xVAL_CICM[nIt])
					OLE_SetDocumentVar(hWord, "_CALI"+alltrim(str(I)) ,xALIQ_PRO[nIt])
					OLE_SetDocumentVar(hWord, "_CTOT"+alltrim(str(I)) ,xVAL_MERC[nIt])
				ELSE
					OLE_SetDocumentVar(hWord, "_CPRV"+alltrim(str(I)) ,Transform(xPRE_UNI[nIt],"@E 99,999.9999"))
					OLE_SetDocumentVar(hWord, "_CICM"+alltrim(str(I)) ,Transform(xVAL_CICM[nIt],"@E 99,999.99"))
					OLE_SetDocumentVar(hWord, "_CALI"+alltrim(str(I)) ,Transform(xALIQ_PRO[nIt],"@E 99"))
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
	End
	
	//³ Atualizando as variaveis do documento do Word
	OLE_SetDocumentVar(hWord, "_NORC" ,_nOrc)
	OLE_SetDocumentVar(hWord, "_CCODCLI" ,_cCodCli)
	OLE_SetDocumentVar(hWord, "_CCODPAG" ,_cCodPag)
	OLE_SetDocumentVar(hWord, "_CPRAENT" ,If(_cPosto == '01','Prazo de entrega:  '+_cPraEnt,If(_cPosto == '03',_cPraEnt+"  Dia(s)","")))
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
	If Alltrim(_cTelCli) == Alltrim(_cFaxCli) // Tratando telefone  MCVN - 10/08/07
		OLE_SetDocumentVar(hWord, "_CTELCLI" ,"Fone/Fax: "+_cTelCli)
	Else
		OLE_SetDocumentVar(hWord, "_CTELCLI" ,"Fone: "+_cTelCli+If(!Empty(Alltrim(_cFaxCli))," - Fax: "+_cFaxCli,""))
	Endif
	OLE_SetDocumentVar(hWord, "_COPERADO" ,_cOperado)
	OLE_SetDocumentVar(hWord, "_CNOMEOPE" ,_cNomeOpe)
	OLE_SetDocumentVar(hWord, "_CMAILOPE" ,_cMailOpe)
	OLE_SetDocumentVar(hWord, "_CTRANSP" ,_cTransp)
	OLE_SetDocumentVar(hWord, "_CNOMETRA" ,_cNomeTra)
	OLE_SetDocumentVar(hWord, "_CVEND" ,_cVend)
	OLE_SetDocumentVar(hWord, "_CNOMEVEN" ,If(_cPosto == '01/03',_cNomeVen+' / Operador(a):  '+_cNomeOpe,_cNomeVen))
	OLE_SetDocumentVar(hWord, "_CMAILOPE" ,If(_cPosto == '01/03',_cMailOpe,_cMailVen))
	OLE_SetDocumentVar(hWord, "_CMAILVEN" ,If(_cPosto == '01',"dipromed@dipromed.com.br",_cMailVen))
	OLE_SetDocumentVar(hWord, "_CTELEFON" ,If(_cPosto == '01',"APOIO:  0800-7700217","TELEVENDAS: 0800-0114066"))
	OLE_SetDocumentVar(hWord, "_CTOTI" ,Transform(_cTotI,"@E 9,999,999.99"))
	OLE_SetDocumentVar(hWord, "_CTOTG" ,Transform(_cTotG,"@E 9,999,999.99"))
	OLE_SetDocumentVar(hWord, "_CTOTF" ,Transform(_cTotG + nVal_Fre + nVal_Des,"@E 9,999,999.99"))
	OLE_SetDocumentVar(hWord, "_CFRET" ,"Frete: " + AllTrim(Transform(nVal_Fre,"@E 9,999,999.99")))
	OLE_SetDocumentVar(hWord, "_CDESP" ,"Despesa: " + AllTrim(Transform(nVal_Des,"@E 9,999,999.99")))
	OLE_Updatefields(hWord)
	
	If _nRadio1 == 1 .or. _nRadio1 == 2
		Ole_PrintFile(hWord,"ALL",,,1) // Imprime a Proposta
		inkey(6)
	EndIf
	If _nRadio1 == 1
		Ole_CloseFile(hWord)
		Ole_CloseLink(hWord)
	EndIf
	
	While !_lSaidaP
		@ 100,150 To 200,530 Dialog oDlg2 Title OemToAnsi(_cNomeOpe+", Porque imprimir em Word? O que será alterado?")
		@ 010,010 Get _cExplWor Valid !Empty(_cExplWor) .And. Len(_cExplWor) > 10 SIZE 170,10
		@ 030,150 BmpButton Type 1 Action (_lSaidaP := .T., Close(oDlg2) )
		Activate Dialog oDlg2 Centered
	EndDo
	
	_cFrom   := Lower(Alltrim(_cMailOpe))
	_cEmail  := SUPERGETMV("MV_#EMLTI",.F.,"ti@dipromed.com.br")
	_cAssunto:= EncodeUTF8("Orçamento  "+_nOrc+" foi impresso no Word!","cp1252")
	Aadd( _aMsg , { "Numero Pedido: "       , _nOrc } )
	Aadd( _aMsg , { "Operador: "            , _cOperado +" - "+ _cNomeOpe } )
	Aadd( _aMsg , { "Cliente:  "            , _cCodCli  +" - "+ _cNomCli  } )
	Aadd( _aMsg , { "Explicação: "          , _cExplWor } )
	U_UEnvMail(_cEmail,_cAssunto,_aMsg,"",_cFrom,_cFuncSent)	
Endif

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
OLE_SetDocumentVar(hWord, "_CPRAENT" ,If(_cPosto $ '01/03','Prazo de entrega:  '+_cPraEnt,""))
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
If Alltrim(_cTelCli) == Alltrim(_cFaxCli) // Tratando telefone  MCVN - 10/08/07
	OLE_SetDocumentVar(hWord, "_CTELCLI" ,"Fone/Fax: "+_cTelCli)
Else
	OLE_SetDocumentVar(hWord, "_CTELCLI" ,"Fone: "+_cTelCli+If(!Empty(Alltrim(_cFaxCli))," - Fax: "+_cFaxCli,""))
Endif
OLE_SetDocumentVar(hWord, "_COPERADO" ,_cOperado)
OLE_SetDocumentVar(hWord, "_CNOMEOPE" ,_cNomeOpe)
OLE_SetDocumentVar(hWord, "_CMAILOPE" ,_cMailOpe)
OLE_SetDocumentVar(hWord, "_CTRANSP" ,_cTransp)
OLE_SetDocumentVar(hWord, "_CNOMETRA" ,_cNomeTra)
OLE_SetDocumentVar(hWord, "_CVEND" ,_cVend)
OLE_SetDocumentVar(hWord, "_CNOMEVEN" ,If(_cPosto $ '01/03',_cNomeVen+' / Operador(a):  '+_cNomeOpe,_cNomeVen))
OLE_SetDocumentVar(hWord, "_CMAILOPE" ,If(_cPosto $ '01/03',_cMailOpe,_cMailVen))
OLE_SetDocumentVar(hWord, "_CMAILVEN" ,If(_cPosto == '01',"dipromed@dipromed.com.br",_cMailVen))
OLE_SetDocumentVar(hWord, "_CTELEFON" ,If(_cPosto == '01',"APOIO:  0800-7700217","TELEVENDAS: 0800-0114066"))
OLE_SetDocumentVar(hWord, "_CTOTI" ," ")
OLE_SetDocumentVar(hWord, "_CTOTG" ," ")
OLE_SetDocumentVar(hWord, "_CTOTF" ," ")
OLE_SetDocumentVar(hWord, "_CFRET" ," ")
OLE_SetDocumentVar(hWord, "_CDESP" ," ")
OLE_Updatefields(hWord)

If _nRadio1 == 1 .or. _nRadio1 == 2
	Ole_PrintFile(hWord,"ALL",,,1) // Imprime a Proposta
	inkey(6)
EndIf
If _nRadio1 == 1
	Ole_CloseFile(hWord)
	Ole_CloseLink(hWord)
EndIf

Return
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Funcao    ³  CABECA     ³Autor ³  Rodrigo Franco     ³Data ³  25/01/2002     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³  Inicia o processo de impressao do Cabecalho do Orçamento        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³  DIPROMED                                                        ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function CABECA(nRadio)

If nRadio == 1
	oArqMala := "OrcamNew.dot"
ElseIf nRadio == 2
	oArqMala := "Licita1.dot"
Else
	oArqMala := "liciticm1.dot"
Endif

cPathCli := "C:\wordtmp\"

//Gerando novo documento
hWord    := OLE_CreateLink()
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
	AADD(xAliq_Pro ," ")
	AADD(xVal_cICM ," ")
End

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³UTMKR3A    ºAutor  ³Microsiga           º Data ³  03/25/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function AltC6Edit()
Local aArea 	:= GetArea()
Local oDlg
Local cCadastro := "Itens Do Edital"
Local aCpoEnch	:= {}
Local aPos	  	:= {010,000,600,600}
Local aButtons 	:= {}
Local nOpcA		:= 0
Local oOk		:= LoadBitmap( GetResources(), "LBOK" )
Local oNo		:= LoadBitmap( GetResources(), "LBNO" )
Local oChk
Local lMark		:= .F.
Local lRetorno   := .F.

Private lChk	 := .F.
Private aVetor	 := {}
Private oLbx
Private lInverte := .F.
Private nContLin := 0
Private lLote    := .F.

RegToMemory("SC6",.F.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Montagem dos campos da Enchoice 		   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

dbSelectArea("SC6")
SC6->(dbSetOrder(1))
If SC6->(dbSeek(xFilial("SC6") + SC5->C5_NUM))

	While !SC6->(Eof()) .And. SC6->C6_FILIAL == xFilial("SC6") .And. SC6->C6_NUM == SC5->C5_NUM

		aAdd(aVetor,{SC6->C6_ITEM,SubStr(alltrim(SC6->C6_LICITA ),1,3), SC6->C6_PRODUTO, SC6->C6_DESCRI, SC6->C6_QTDVEN, SC6->C6_PRCVEN })

		SC6->(dbSkip())
	EndDo

	Define msDialog odlg title ccadastro from 000,000 to 300,850 pixel
	
	//Cria Enchoice
	//EnChoice( cAlias ,nReg, nOpcx, , , , aCpoEnch, aPos, {}, 3 )
	
	//Cria a listbox com os produtos do edital
	@ 010,000 listbox oLbx fields header "Item", "Item Edital", "Produto", "Descricao", "Quantidade", "Vlr. Unitario"  size 800,150 of oDlg pixel on dbLclick(u_EdLisC6(oLbx:nat))
	
	oLbx:SetArray( aVetor )
	oLbx:bLine := {|| {	aVetor[oLbx:nAt,1],;
	aVetor[oLbx:nAt,2],;
	aVetor[oLbx:nAt,3],;
	aVetor[oLbx:nAt,4],;
	aVetor[oLbx:nAt,5],;
	TransForm(aVetor[oLbx:nAt,6], "@E 999,999,999.99")}}
	
	Activate msDialog oDlg centered on init ;
	EnchoiceBar(oDlg, {|| nOpca := 1,oDlg:End()},{|| nOpca := 0,oDlg:End()},,aButtons)
	
EndIf

RestArea(aArea)

Return()
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³UTMKR3A    ºAutor  ³Microsiga           º Data ³  03/25/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function EdLisC6(nPos)
Local cKey 		:= ""
Local oDlg
Local nOpca		:= 0
Local cCodPro	:= ""
Local cDProdu	:= ""
Local nQtd		:= 0
Local nPrcVen	:= 0
Local nPrcMin	:= 0
Local aButtons	:= {}
Local cCadastro := "Item do Pedido"
Local nQtdTot   := 0

cKey := aVetor[nPos,1] //ITEM

dbSelectArea("SC6")
dbSetOrder(1)
SC6->(dbSeek(xFilial("SC6") +SC5->C5_NUM + cKey))

cCodPro := space(3)//SC6->C6_LICITA


Define msDialog oDlg title cCadastro from 0,0 to 100,350 pixel

@ 020, 010 say "Item Edital"                size 070,08 pixel of odlg
@ 019, 080 get ccodpro                      size 030,10 pixel of odlg

Activate msDialog odlg Center on Init;
Enchoicebar(oDlg, {|| nopca := 1,oDlg:end()},{|| nopca := 0,oDlg:end()},,abuttons)

If nOpca = 1
	
	Begin Transaction
	
	dbSelectArea("SC6")
	dbSetOrder(1)
	SC6->(dbSeek(xFilial("SC6") +SC5->C5_NUM + cKey))
	
	RecLock("SC6", .F.)
	
	SC6->C6_LICITA   := cCodPro
	
	MsUnLock()
	
	End Transaction
	
	If __lSX8
		ConfirmSX8()
	EndIf
	aVetor[nPos][1]		:= SC6->C6_ITEM
	aVetor[nPos][2]		:= SC6->C6_LICITA
	aVetor[nPos][3]		:= SC6->C6_PRODUTO
	aVetor[nPos][4]		:= SC6->C6_DESCRI
	aVetor[nPos][5]		:= SC6->C6_QTDVEN
	aVetor[nPos][6]		:= SC6->C6_PRCVEN
EndIf

oLbx:Refresh()
Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³UTMKR3A    ºAutor  ³Microsiga           º Data ³  10/02/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function CalcSTItem(cProduto,nValor)   
Local aAreaSB1 	  := SB1->(GetArea())
Local _nPRedICMS  := 0
Local _nVRedICMS  := 0
Local _nPICMSE    := 0
Local _nVICMSE    := 0
Local _nPIPI      := 0
Local _nVIPI      := 0
Local _nPIVA      := 0
Local _nVIVA      := 0
Local _nVICMSS    := 0
Local _nVST       := 0

DEFAULT cProduto  := ""
DEFAULT nValor 	  := 0

SB1->(dbSetOrder(1))
If SB1->(dbSeek(xFilial("SB1")+AllTrim(cProduto)))
	_nPRedICMS  := Posicione("SF4",1,xFilial('SF4')+SB1->B1_TE,"F4_BASEICM")
	_nVRedICMS  := _nPRedICMS/100 *(nValor)
	_nPICMSE    := Iif(Posicione("SA2",1,xFilial('SA2')+SB1->B1_PROC+SB1->B1_LOJPROC,"A2_OPTSIMP")='2',0,Iif(SA2->A2_EST='SP',SB1->B1_PICM,12))
	_nVICMSE    := _nPICMSE/100 * Iif(_nVRedICMS<>0,_nVRedICMS,nValor)
	_nPIPI      := SB1->B1_IPI
	_nVIPI      := _nPIPI/100 * nValor
	_nPIVA      := SB1->B1_PICMRET
	_nVIVA      := Iif(_nPIVA=0,0,(1+_nPIVA/100)*(Iif(_nPRedICMS=38.89,nValor*_nPRedICMS/100,nValor)+_nVIPI))
	_nVICMSS    := SB1->B1_PICM/100 * _nVIVA
	_nVST       := Iif(_nPIVA<>0,_nVICMSS - _nVICMSE,0)    
EndIf
	
RestArea(aAreaSB1)                               

Return(_nVST)


Static Function Impostos(_cPedido,_cItem,_cProd,nValST)

	dbSelectArea("SC6")    
	dbSetOrder(01)
	dbSeek(xFilial("SC6")+_cPedido+_cItem+_cProd)
	        
	//nTotSol := nTotIcm := nBasIcm := nSubTot := nTotIPI := nVlrIPI := nICMS := nTotICMS := nTotalGeral := nPesoItem := nTotalItem := nTotalNota := 0
	 MaFisIni(SC5->C5_CLIENTE,SC5->C5_LOJACLI,"C","N",SC5->C5_TIPOCLI,MaFisRelImp("TMKR3A",{"SC5","SC6"}),,,"SB1","TMKR3A")
	 MaFisAdd(SC6->C6_PRODUTO,;
	          SC6->C6_TES,;
	          SC6->C6_QTDVEN,;
	          SC6->C6_PRUNIT,;
	          SC6->C6_VALDESC,;
	          "",;
	          "",;
	          0,;
	          0,;
	          0,;
	          0,;
	          0,;
	          (SC6->C6_QTDVEN*SC6->C6_PRUNIT),;
	          0,;
	          0,;
	          0)
	          //_nAliqIcm :=        MaFisRet(1,"IT_ALIQICM")
	          //_nValIcm  := MaFisRet(1,"IT_VALICM" )
	          //_nBaseIcm := MaFisRet(1,"IT_BASEICM")
	          //_nValIpi  := MaFisRet(1,"IT_VALIPI" )
	          //_nBaseIpi := MaFisRet(1,"IT_BASEICM")
	          //_nValMerc := MaFisRet(1,"IT_VALMERC")
	          nValST      := MaFisRet(1,"IT_VALSOL" )
	                         
	 MaFisEnd()

Return(nValST) 

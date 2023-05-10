/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TMKR03    ºAutor  ³Microsiga           º Data ³  08/15/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/                                                                           
#include "Protheus.ch"
#include "rwmake.ch"
#include "Dialog.ch"
#INCLUDE "AP5MAIL.CH"
#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPrintSetup.ch"
User Function Ok_PDF(nRadio)
Local _oDlg
Local _aMsg         := {}
Local _cAssunto     := ""
Local _cEmail       := ""
Local _cDestCli  	:= ""
Local _cFrom     	:= ""
Local _cFuncSent 	:= "UTMKR03.PRX
Local oDlg2
Local _lSaidaP      := .F.
Local _cExplWor     := Space(100)
Local cArquivo      := ""
Local _lFlagMsg	    := .F.

Private lErroval    := .f.
Private nValIpi     := 0
Private cCliST      := ""
Private cContrib    := ""
Private cRegEsp		:= ""
Private _nTotST		:= 0              
Private _nPICMS		:= 0
Private _cMVista1	:= ""
Private _cMVista2	:= ""
Private _cMVista3	:= ""
//variaveis para calculo imposto MATXFIS
Private _nTtoPed	:= 0
Private _nValItem	:= 0
Private _nValPis	:= 0
Private _nValCof	:= 0
Private	_nValICM	:= 0
Private	_nValIPI	:= 0
Private	_nValISS	:= 0
Private	_nValIST	:= 0

If nRadio == 4
	_lCartaVale  := .T.
Endif

_nRadio1 := 1
@ 050,110 To 150,310 Dialog _oDlg Title OemToAnsi("Escolha a opção")
@ 010,010 RADIO _oRadio1 VAR _nRadio1 3D Items "Impressão","Impressão c/ Envio de Email" of _oDLG SIZE 80,10
@ 035,040 BmpButton Type 1 Action Close(_oDlg)

Activate MsDialog _oDlg Centered Valid _nRadio1 > 0  //.and. If(_nRadio1 >= 4,.T.,U_SENHA("PED",0,0,0) )

nTamDet  	:= 20     // 34            // Tamanho da Area de Detalhe
_cTotG  	:= _cTotI := nVez := 0


_cIA := "0,00"
_cIL := "0,00"
If "TMK" $ FunName() .or.(Type("lMenu") <> "U" .and. lMenu .and. (!"DIPAL10" $ FunName()) .and. (!"MATA410" $ FunName()))
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
		_cEndCli := SUBSTR(SUA->UA_ENDENT,1,60)  // End de entrega
		_cBaiCli := SUBSTR(SUA->UA_BAIRROE,1,30)
		_cMunCli := SUA->UA_MUNE
		_cEstCli := SUA->UA_ESTE
		_cCepCli := SUA->UA_CEPE
	Endif
	_cIA	 := SUA->UA_MARGATU
	_cIL	 := SUA->UA_MARGLIB
	_cCont   := 'Produtos:'
	_cGera   := 'TOTAL (produto + frete + despesa)'
	
ELSEIF "DIPAL10" $ FunName() // Quando a Rotina chamada de dentro do Módulo de Licitação MCVN - 25/06/07
	
	dbSelectArea("SC5")                   // * Itens de Venda da N.F.
	_nOrc    := SC5->C5_NUM
	_cCodCli := SC5->C5_CLIENTE
	_cCodPag := SC5->C5_CONDPAG
	_cPraEnt := ""//SUA->UA_PRAENT
	_cDtVali := ""//SUA->UA_DTLIM
	_cFatMin := 0
	_cTipFre := SC5->C5_TPFRETE
	_cDestFre:= SC5->C5_DESTFRE //MCVN - 14/05/09
	_cAc     := ""//SUA->UA_AC
	_cObs    := SC5->C5_MENNOTA + "Edital nº.: "+SC5->C5_EDITAL+ "  Empenho nº:." +SC5->C5_EMPENHO
	_cEmi    := DtoC(SC5->C5_EMISSAO)
	nVal_Fre := SC5->C5_FRETE  /// valor do Frete
	nVal_Des := SC5->C5_DESPESA  /// valor das Despesas
	_cOperado:= "" // Operador
	_cNomeOpe:= Alltrim(Posicione("SU7",1,xFilial("SU7")+SC5->C5_OPERADO,"U7_NREDUZ"))
	_cMailOpe:= Alltrim(Posicione("SU7",1,xFilial("SU7")+SC5->C5_OPERADO,"U7_EMAIL"))
	_cPosto  := "" // Posto do Operador
	_cTransp := "" // Transportadora
	_cNomeTra:= "" // Nome da transportadora
	_cVend   := "" // Vendedor
	_cNomeVen:= Alltrim(Posicione("SA3",1,xFilial("SA3")+SC5->C5_VEND1,"A3_NOME"))
	_cMailVen:= Alltrim(Posicione("SA3",1,xFilial("SA3")+SC5->C5_VEND1,"A3_EMAIL"))
	_cTipoVen:= Posicione("SA3",1,xFilial("SA3")+SC5->C5_VEND1,"A3_TIPO")
	_cCont   := ""
	_cGera   := ""
	_cIA	 := SC5->C5_MARGATU
	_cIL	 := SC5->C5_MARGLIB
	
ELSEIF "MATA410" $ FunName() //Para impressão de pedido emitido pelo MATA410 MCVN - 25/06/07
	
	dbSelectArea("SC5")                   // * Itens de Venda da N.F.
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
	_cCodCli := SCJ->CJ_CLIENTE      ///// UA_CLIENTE
	_cCodPag := SCJ->CJ_CONDPAG      ////// UA_CONDPG
	_cPraEnt := SCJ->CJ_PRAENTR      ////
	_cDtVali := SCJ->CJ_VALIDA       /////   UA_DTLIM
	_cFatMin := SCJ->CJ_FATMIN      //////
	_cTipFre := SCJ->CJ_TPFRETE     //////   UA_TPFRETE
	_cDestFre:= ""
	_cAc     := SCJ->CJ_AC          //////
	_cObs    := SCJ->CJ_OBS         //////  UA_OBS
	_cEmi    := DtoC(SCJ->CJ_EMISSAO)
	nVal_Fre := SCJ->CJ_FRETE  /// valor do Frete
	nVal_Des := SCJ->CJ_DESPESA  /// valor das Despesas
	_cOperado:= "" // Operador
	_cNomeOpe:= "" // Nome do operador
	_cMailOpe:= "" // E-mail do operador
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

If SC5->C5_CONDPAG$"001/002" .And. SC5->C5_TIPODIP="1"
	_cMVista1 += "ATENÇÃO - PEDIDO À VISTA."
	_cMVista2 += "Por favor, encaminhar o comprovante de depósito para a liberação do pedido."
	_cMVista3 += "PIX:  47869078000100"
EndIf

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
		_cCalcSuf:=  SA1->A1_CALCSUF
		cCliST	 :=  SA1->A1_TIPO
		cRegEsp  :=  SA1->A1_DREGESP
		cContrib :=  SA1->A1_CONTRIB
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
xVal_IPI  :={}
xIA		  :={}
xIL		  :={}                          
xVal_ST	  :={}
xAL_ICMS  :={}
aDipST	  :={}
aDipSld	  :={}

If "TMK" $ FunName().or.(Type("lMenu") <> "U" .and. lMenu .and. (!"DIPAL10" $ FunName()) .and. (!"MATA410" $ FunName()))
	dbSelectArea("SUB")                   // * Itens de Venda da N.F.
	dbSetOrder(1)
	IF DbSeek(xFilial("SUB")+SUA->UA_NUM)
		While SUB->(!Eof()) .AND. xFilial("SUB") == SUB->UB_FILIAL .AND. SUA->UA_NUM == SUB->UB_NUM
			AADD(xITEM_ORC ,ALLTRIM(SUB->UB_ITEM))    ///// UB_ITEM
			AADD(xCOD_PRO  ,ALLTRIM(SUB->UB_PRODUTO))  ///// UB_PRODUTO
			AADD(xQTD_PRO  ,SUB->UB_QUANT)            ////// UB QUANT
			
			AADD(xIA  	   ,SUB->UB_MARGATU)
			AADD(xIL       ,SUB->UB_MARGITE)
			
			AADD(xUM_PRO   ,ALLTRIM(SUB->UB_UM))       ////// UB_UM
			
			dbSelectArea("SB1")                   // * Itens de Venda da N.F.
			dbSetOrder(1)
			IF DbSeek(xFilial("SB1")+SUB->UB_PRODUTO)
				AADD(xDESC_PRO ,ALLTRIM(SB1->B1_DESC))
			ENDIF
			
			AADD(xALIQ_PRO ,SB1->B1_PICM) // B1_PICM
			AADD(xPRE_UNI  ,Iif(nRadio==3,SUB->UB_VRUNIT / ((100-SB1->B1_PICM)/100),SUB->UB_VRUNIT))  //  UB_VRUNIT
			AADD(xVAL_MERC ,SUB->UB_VLRITEM)           //  UB_VLRITEM
			AADD(xVAL_cICM ,SUB->UB_VRUNIT / ((100-SB1->B1_PICM)/100) * SUB->UB_QUANT) //  VALOR COM ICMS INCLUSO
			_cTotG := _cTotG + SUB->UB_VLRITEM         // TOTAL GERAL
			_cTotI += SUB->UB_VRUNIT / ((100-SB1->B1_PICM)/100) * SUB->UB_QUANT // TOTAL GERAL COM ICMS
			
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
			
			DbSelectArea("SUB")
			Dbskip()
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
						lErroVal := .f.
					Endif
				Endif
				
				DbSelectArea("SCK")
				Dbskip()
			End
		ENDIF
	Endif
	
ElseIf "DIPAL10" $ FunName() .Or. "MATA410" $ FunName() //MCVN - 25/06/07
	dbSelectArea("SC6")                   // * ITENS DO PEDIDO DE VENDA
	SC6->(dbSetOrder(1))
	SC6->(DbGoTop())
	IF SC6->(DbSeek(xFilial("SC6")+SC5->C5_NUM))
		nItem := 1
		_nTtoPed:=CALCPED(SC5->C5_NUM)
		IniImp() 				//INICIO DAS INFORMACOES PARA CALCULO DOS IMPOSTOS
		While SC6->(!Eof()) .AND. xFilial("SC6") == SC6->C6_FILIAL .AND. SC5->C5_NUM == SC6->C6_NUM
			
			If SC6->C6_TIPODIP == '1'
				AADD(aDipSld,SC6->C6_CLI+SC6->C6_LOJA+SC6->C6_NUM+SC6->C6_ITEM)
				AADD(xITEM_ORC ,ALLTRIM(SC6->C6_ITEM))
				AADD(xCOD_PRO  ,ALLTRIM(SC6->C6_PRODUTO))
				AADD(xQTD_PRO  ,SC6->C6_QTDVEN)
				
				AADD(xIA  	   ,SC6->C6_MARGATU)
				AADD(xIL       ,SC6->C6_MARGITE)
				
				AADD(xUM_PRO   ,ALLTRIM(SC6->C6_UM))
				AADD(xDESC_PRO ,ALLTRIM(SC6->C6_DESCRI))
 				AADD(xREG_ANVI ,Posicione("SB1",1,xFilial("SB1")+SC6->C6_PRODUTO,"B1_REG_ANV")) // B1_REG_ANV				
				AADD(xALIQ_PRO ,Posicione("SB1",1,xFilial("SB1")+SC6->C6_PRODUTO,"B1_PICM")) // B1_PICM
				AADD(xPRE_UNI  ,Iif(nRadio==3 ,SC6->C6_PRCVEN / ((100-SB1->B1_PICM)/100),SC6->C6_PRCVEN))
				AADD(xVAL_MERC ,SC6->C6_VALOR)
				AADD(xVAL_cICM ,Round(SC6->C6_PRCVEN / ((100-SB1->B1_PICM)/100),3) * SC6->C6_QTDVEN) //  VALOR COM ICMS INCLUSO
				AADD(xVAL_IPI  ,Round(U_CALCIPI(SC6->C6_NUM,SC6->C6_PRODUTO, SC6->C6_ITEM),2)) 
	            /*
				--Adicionado nova regra de calculo da ST pela MATXFIS padrao
				--Tiago Stocco - Obify - 07/06/21
				*/
				//Verifica se tem frete para compor o valor da ST
				If nVal_Fre >0
					_nValItem := SC6->C6_VALOR + Round((SC6->C6_QTDVEN * SC6->C6_PRCVEN * nVal_Fre)/_nTtoPed,2)
				Else
					_nValItem := SC6->C6_VALOR
				EndIf
				ADDImp(_nValItem, SC6->C6_QTDVEN, SC6->C6_PRCVEN, SC6->C6_CLI, SC6->C6_LOJA, SC6->C6_PRODUTO, SC6->C6_TES)//Adicao os Itens para Imposto
				AADD(xVal_ST   ,MaFisRet(nItem,"IT_VALSOL"))
				_nTotST+=MaFisRet(nItem,"IT_VALSOL") 
				/*                         
				If cEmpAnt == '01' .And. cCliST == 'R' .And. cContrib <> "2" .And. (Empty(cRegEsp) .Or. SC5->C5_CLIENTE$GetNewPar("ES_STESPBA","010154")) .And. ('=ST=D'$SC5->C5_MENNOTA .Or. SC5->C5_TIPODIP=="2")  // No pedido só calcula para Dipromed
								
					aDipST := u_M460SOLI(nil,!Empty(SC6->C6_NOTA))	 
				
					AADD(xVal_ST   ,aDipST[2])

					_nTotST+=aDipST[2]                
				Else 
					AADD(xVal_ST   ,0)
				EndIf
				*/                                
				If cEmpAnt == '01'
					If SB1->B1_ORIGEM$"1/2/3/6/7/8" .And. SC5->C5_ESTE<>"SP"
						_nPICMS := 4
					ElseIf SC5->C5_ESTE$"RJ/MG/PR/RS/SC"
						_nPICMS := 12
					ElseIf !(SC5->C5_ESTE$"RJ/MG/PR/RS/SC/SP")
						_nPICMS := 7                          
					Else                                      
						_nPICMS := SB1->B1_PICM                        
					EndIf          
							
					AADD(xAL_ICMS  ,_nPICMS)
				EndIf
							
				_cTotG := _cTotG + SC6->C6_VALOR
				_cTotI += SC6->C6_PRCVEN / ((100-SB1->B1_PICM)/100) * SC6->C6_QTDVEN
								
				If !lErroVal  // MCVN - 20/10/2008
					If POSICIONE("SE4", 1, XFilial("SE4")+SUA->UA_CONDPG, "E4_USERDES") > 0 //11/11/2008
						If Round((SC6->C6_USERPRC * SC6->C6_QTDVEN)-SC6->C6_USERDES,2) <> SC6->C6_VALOR .And. (Empty(_cSuframa) .Or. _cCalcSuf = 'N')
							lErroVal := .T.
						Endif  
					ElseIf POSICIONE("SE4",1,XFilial("SE4")+SUA->UA_CONDPG,"E4_XUSRACR") > 0 
						If Round((SC6->C6_USERPRC * SC6->C6_QTDVEN)+SC6->C6_XUSRACR,2) <> SC6->C6_VALOR .And. (Empty(_cSuframa) .Or. _cCalcSuf = 'N')
							lErroVal := .T.
						Endif
					Else
						If Round((SC6->C6_PRCVEN  * SC6->C6_QTDVEN),2) <> SC6->C6_VALOR .And. (Empty(_cSuframa) .Or. _cCalcSuf = 'N')
							lErroVal := .T.
						Endif
					Endif
				Endif
				
			Endif
			//DbSelectArea("SC6")
			nItem++
			SC6->(Dbskip())
			
		EndDo
	Endif
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
	AADD(xVAL_cICM ," ")
	AADD(xALIQ_PRO ," ")
	AADD(xIA ," ")
	AADD(xIL ," ")
	AADD(xVal_IPI  ," ")
End
nIt := 1
nPagatu := 1

If lErroVal
	MsgAlert("Existe(m) erro(s) nos valores unitários e totais, FAVOR CONFERIR VALORES ANTES DE ENVIAR O PEDIDO AO CLIENTE!","Atenção")	
	_cFrom   := Lower(Alltrim(_cMailOpe))
	_cEmail  := "maximo.canuto@dipromed.com.br;"+Lower(Alltrim(_cMailOpe))
	_cAssunto:= EncodeUTF8("Problema nos valores unitários - Pedido  "+Iif("DIPAL10" $ FunName() .Or. "MATA410" $ FunName() ,SC5->C5_NUM,SUA->UA_NUMSC5)+" não impresso!  CONFERIR OS VALORES DO PEDIDO!", "cp1252")
	Aadd( _aMsg , { "Operador: "            , _cOperado +" - "+ _cNomeOpe } )
	Aadd( _aMsg , { "Cliente:  "            , _cCodCli  +" - "+ _cNomCli  } )
	Aadd( _aMsg , { "Explicação: "          , _cExplWor } )
	U_UEnvMail(_cEmail,_cAssunto,_aMsg,"",_cFrom,_cFuncSent)
Endif

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
Private CourN12      := TFont():New("Courier New",,12,,.F.,,,,.T.,.F.)
Private CourN12B     := TFont():New("Courier New",,12,,.T.,,,,.T.,.F.)
Private _lICM 		 := (nRadio == 3)
Private _cNomTel     := "" 
Private cComNoPed    := 'PV_'+SC5->C5_NUM+"_"+substr(time(),1,2)+substr(time(),4,2)+substr(time(),7,2)
//Private cComNoPed    := 'PV_'+SC5->C5_NUM+"_"+substr(DTOS(dDatabase),7,2)+substr(dtos(ddatabase),5,2)+"_"+substr(time(),1,2)+substr(time(),4,2)+substr(time(),7,2)
                                                                            
//Private oPrint 		 := FWMSPrinter():New('PV_'+SC5->C5_NUM+"_"+DTOS(dDatabase),6,.T.,,.T.)
Private oPrint 		 := FWMSPrinter():New(cComNoPed,6,.T.,,.T.,,,,,,,.F.)

Private lArquivo := .F.
Private _nValTotS:= 0 

If nRadio == 2
	lArquivo := MsgYesNo("Relatório para arquivo?")
EndIf 

cArquivo := "C:\pedidos\"+cComNoPed+".pdf"

oPrint:SetResolution(72)
oPrint:SetLandScape()
oPrint:SetPaperSize(9)               
oPrint:cPathPDF:= "C:\pedidos\"
	
_nORC := Iif("DIPAL10" $ FunName() .Or. "MATA410" $ FunName(),SC5->C5_NUM,SUA->UA_NUMSC5)

If nRadio == 1
	_cTelefon	:= If(cEmpAnt+cFilAnt == '0401',"(11) 4016-1506",If(_cPosto == '01',"APOIO:  0800-7700217","TELEVENDAS: 0800-0114066"))
	_cFax		:= If(cEmpAnt+cFilAnt == '0401',"FAX: (11) 4016-1506","FAX: 0800-0144997")
Else
	_cTelefon 	:= "LICITAÇÕES: (11) 3646-0192"
	_cFax		:= "FAX: (11) 3646-0193"
EndIf
_cTitulo	:= If(!_lCartaVale,"PEDIDO","CARTA")
_cTitulo2	:= If(nRadio != 1,"LICITAÇÕES","")
_cDipMail	:= If(nRadio != 1,"publico",If(_cPosto == '01',"dipromed","televendas"))+"@dipromed.com.br"
_cDipMail   := If(cEmpAnt == '04',If(cFilAnt='01',"www.healthquality.ind.br   -   vendas@healthquality.ind.br","www.healthquality.ind.br   -   "+_cDipMail )  ,"www.dipromed.com.br  -  "+_cDipMail)
If Alltrim(_cTelCli) == Alltrim(_cFaxCli) // Tratando telefone  MCVN - 10/08/07
	_cNomTel := "Fone/Fax:"
Else
	_cNomTel := "Fone:"
	_CTELCLI := _cTelCli+If(!Empty(Alltrim(_cFaxCli))," - Fax: "+_cFaxCli,"")
Endif

nPagina 	:= 0
U_CabecPDF(@nlin)
U_CorpoPDF(@nLin)
U_FinalPDF()
U_RodapPDF()

oPrint:Endpage()
if _nRadio1 == 2 
	If _lRascunho
		MsgAlert("O e-mail não será enviado, pois foi selecionada a opção de Rascunho!","Atenção")
		oPrint:SetViewPDF(.T.)
		oPrint:Preview()//Visualiza antes de imprimir	
	Else    
		While File(cArquivo)
			fErase(cArquivo)
			If _lFlagMsg 
				MsgAlert("FECHAR o arquivo "+cArquivo+" antes de enviar o e-mail.","ATENÇÃO!")
			EndIf	
			_lFlagMsg := .T.
			Loop
		EndDo                                                                        
		oPrint:Print()
		_cTo		:= Alltrim(SA1->A1_EMAILD)+If(_cPosto $ '01/03',";"+_cMailVen,Space(1))+Space(60)
		_cBodyPrvt 	:= U_RetBody(@_cTo)
		If !Empty(_cTo)
			U_PDFMail(_cMailOpe,_cTo,_cTipoVen)		
		EndIf
		WinExec("Explorer.exe "+cArquivo)		
	EndIf
Else
	oPrint:SetViewPDF(.T.)
	oPrint:Preview()//Visualiza antes de imprimir	
EndIf
FreeObj(oPrint)
oPrint := Nil

Return
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Funcao    ³  CabecPDF    ³Autor ³ CONSULTORIA         ³Data ³  12/02/2008     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³  Cabecalho em TmsPrinter - Pedido/Orcamento                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³  DIPROMED                                                        ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function CabecPDF(nLin)         
Local nCol := 0

oPrint:StartPage()  

nLin := 80               

// Contorno Geral
oPrint:Line(nLin	 ,0050, nLin	 , 3000) // Linha Superior
oPrint:Line(nLin	 ,0050, nLin+2330, 0050) // Linha Lateral Esquerda
oPrint:Line(nLin	 ,3000, nLin+2330, 3000) // Linha Lateral Direita
oPrint:Line(nLin+2330,0050, nLin+2330, 3000) // Linha Inferior oPrint:Line(nLin+2200,0050, nLin+2200, 3000)         

If !_lRascunho
	IF cEmpAnt=="01"   // MCVN - 03/03/2010
		nLin+=10 
		oPrint:SayBitmap(nLin,0080,"logo_pc.BMP",388,300)
		nLin+=30 
		oPrint:Say(nLin,700, "DIPROMED - Comércio e Importação Ltda." 				,ArialN14B	,100)
		
		If Upper(_cTitulo) == "ORCAMENTO" .And. Upper(_cTitulo2) == "LICITACOES" 
			nLin+=40			
			If cFilAnt == "01"
				oPrint:Say(nLin,700,"CNPJ: 47.869.078/0001-00   IE: 109.616.751.119"			,ArialN10	,100)
			Else 
				oPrint:Say(nLin,700,"CNPJ: 47.869.078/0004-53   IE: 492.462.393.118"			,ArialN10	,100)
			EndIf
			nLin+=40
			oPrint:Say(nLin,850,"Av. Dr. Mauro L.Monteiro , 185"			   				,ArialN12	,100)
			nLin+=45
			oPrint:Say(nLin,800,"Jardim Santa Fé - Osasco - SP - CEP: 06278-010"			,ArialN12	,100)
			nLin+=45
			oPrint:Say(nLin,0690,_cTeleFon								   	  			,ArialN12B	,100)
			oPrint:Say(nLin,1290,_cFax									   	  			,ArialN12B	,100)
		Else   
			nLin+=55
			oPrint:Say(nLin,850,"Rua Bartolomeu Paes, 441"			   					,ArialN12	,100)
			nLin+=35
			oPrint:Say(nLin,800,"Vila Anastácio - São Paulo-SP - CEP: 05092-000"			,ArialN12	,100)
			nLin+=55
			oPrint:Say(nLin,0690,_cTeleFon								   	  			,ArialN12B	,100)
			oPrint:Say(nLin,1290,_cFax									   	  			,ArialN12B	,100)
		Endif
		
		nLin+=40
		
		If("televendas"$_cDipMail)
			oPrint:Say(nLin,800,"Horário de Atendimento: 08:00 às 17:48" 		    ,ArialN12B	,100)
		Else
			oPrint:Say(nLin,800,"Horário de Atendimento: 08:00 às 17:48"            	,ArialN12B	,100)
		Endif         
		
		nLin+=40
		
	oPrint:Say(nLin,700,_cDipMail				 								,ArialN12B	,100)
	ElseIf cEmpAnt+cFilAnt=="0404"
		nLin+=10
		oPrint:SayBitmap(nLin,0080,"hq_logo.BMP",388,300)
		
		nLin+=30
		oPrint:Say(nLin,700, "HEALTH QUALITY - Indústria e Comércio LTDA."  			,ArialN12B	,100)
		
		nLin+=90
		oPrint:Say(nLin,850,"Av. Dr. Antenor Soares Gandra, 321"		   				,ArialN12	,100)
		
		nLin+=40
		oPrint:Say(nLin,800,"Jardim Saúde - Jarinu - SP - CEP: 13240-000"			,ArialN12	,100)
		
		nLin+=90
		oPrint:Say(nLin,0690,_cTeleFon								   	  			,ArialN12B	,100)
		oPrint:Say(nLin,1290,_cFax									   	  			,ArialN12B	,100)
		       
		nLin+=60
		If("televendas"$_cDipMail)
			oPrint:Say(nLin,800,"Horário de Atendimento: 08:00 às 17:48" 		    ,ArialN12B	,100)
		Else
			oPrint:Say(nLin,800,"Horário de Atendimento: 08:00 às 17:48"            	,ArialN12B	,100)
		Endif    
		
		nLin+=40
		oPrint:Say(nLin,700,_cDipMail				 								,ArialN12B	,100)
		
	ElseIf cEmpAnt+cFilAnt=="0401"
		nLin+=10
		oPrint:SayBitmap(nLin,0080,"hq_logo.BMP",388,300)
		
		nLin+=30
		oPrint:Say(nLin,700,"HEALTH QUALITY - Indústria e Comércio LTDA." 	        ,ArialN12B	,100)
		
		nLin+=45
		oPrint:Say(nLin,900,"CNPJ: 05.150.878/0001-27 "                          	,ArialN12	,100)
		
		nLin+=45
		//oPrint:Say(nLin,850,"Av. Dr. Antenor Soares Gandra, 321"		   				,ArialN12	,100)
		oPrint:Say(nLin,850,"Av. Ver. João Pedro Ferraz, 1255"		   					,ArialN12	,100)
		
		nLin+=40
		//oPrint:Say(nLin,800,"Jardim Saúde - Jarinu - SP - CEP: 13240-000"			,ArialN12	,100)
		oPrint:Say(nLin,800,"Bom Retiro - Jarinu - SP - CEP: 13240-000"				,ArialN12	,100)
		
		nLin+=50
		oPrint:Say(nLin,0800,_cTeleFon								   	  			,ArialN12B	,100)
		oPrint:Say(nLin,1100,_cFax									   	  			,ArialN12B	,100)
		               
		nLin+=40
		If("televendas"$_cDipMail)
			//oPrint:Say(nLin,800,"Horário de Atendimento: 08:00 às 18:00" 		    ,ArialN12B	,100)
			oPrint:Say(nLin,800,"Horário de Atendimento: 07:30 às 17:18" 		    ,ArialN12B	,100)
		Else
			//oPrint:Say(nLin,800,"Horário de Atendimento: 08:00 às 18:00"          ,ArialN12B	,100)
			oPrint:Say(nLin,800,"Horário de Atendimento: 07:30 às 17:18"            ,ArialN12B	,100)
		Endif   
		
		nLin+=40
		oPrint:Say(nLin,700,_cDipMail				 								,ArialN12B	,100)
	Endif
Else               
	nLin+=120
	oPrint:Say(nLin,0470, "* * * * R A S C U N H O * * * *" 		   				,ArialN20B	,100)
EndIf

nLin:=120
oPrint:Say(nLin,1790,_cTitulo+" : "	+_nORC			 	   					,ArialN14B	,100)

nPagina++
oPrint:Say(nLin,2880,"Pag: "+StrZero(nPagina,4) 					 		,ArialN10B	,100)

nLin+=40
oPrint:Say(nLin,1790,"Cliente:" 							 	  			 	,ArialN10	,100)
oPrint:Say(nLin,1980,_cCODCLI+" - "+SA1->A1_LOJA+"-"						,ArialN10	,100)
oPrint:Say(nLin,2170,Substr(_cNOMCLI,1,50) 						 			,ArialN10	,100)

nLin+=35
oPrint:Say(nLin,1790,"End.Entrega:" 							 				,ArialN10	,100)
oPrint:Say(nLin,1980,Transform(_cENDCLI,PesqPict("SA1","A1_END") )		  	,ArialN10	,100)

nLin+=35

oPrint:Say(nLin,1980,Trim(_cBAICLI)											,ArialN10	,100)//2710 
oPrint:Say(nLin,2420,Transform(_cCEPCLI,PesqPict("SA1","A1_CEP") ) 			,ArialN10	,100)//1980
oPrint:Say(nLin,2555,Trim(_cMUNCLI)   					   			 		,ArialN10	,100)//2380
oPrint:Say(nLin,2945,"-"			   					   			 		,ArialN10	,100)
oPrint:Say(nLin,2960,Transform(_cESTCLI,PesqPict("SA1","A1_EST") ) 			,ArialN10	,100)//2710

nLin+=35
oPrint:Say(nLin,1790,_cNomTel						 						,ArialN10	,100)
oPrint:Say(nLin,1980,_cTELCLI											  	,ArialN10	,100)
oPrint:Say(nLin,2710,"A/C:"+_cAC											 	,ArialN10	,100)

//AJUSTE PARA TRAZER CFP OU CNPJ NO LAYOUT DE IMPRESSAO      
If SA1->A1_PESSOA =='J' 

nLin+=35
oPrint:Say(nLin,1790,"CNPJ:"              	 				 				,ArialN10	,100)
oPrint:Say(nLin,1980,Transform(_cCGCCLI,PesqPict("SA1","A1_CGC") )  		,ArialN10	,100)
oPrint:Say(nLin,2385,"IE:"									   				,ArialN10	,100)
oPrint:Say(nLin,2435,Transform(_cINSCLI,PesqPict("SA1","A1_INSCR") )		,ArialN10	,100)

Else

nLin+=35
oPrint:Say(nLin,1790,"CPF:"              	 				 				,ArialN10	,100)
oPrint:Say(nLin,1980,Transform(_cCGCCLI,"@R 999.999.999-99")		  		,ArialN10	,100)
oPrint:Say(nLin,2385,"IE:"									   				,ArialN10	,100)
oPrint:Say(nLin,2435,Transform(_cINSCLI,PesqPict("SA1","A1_INSCR") )		,ArialN10	,100)

EndIf

If !_lCartaVale
	nLin+=35
	oPrint:Say(nLin,1790,"Data Pedido:" 					 						,ArialN10B	,100)
	oPrint:Say(nLin,1980,_cEMI												   	,ArialN10B	,100)
	
	//If cCliST == "F" Retirado em 03/2016 autorizado pelo Erich
		oPrint:Say(nLin,2385,"Validade:"			  				  					,ArialN10B	,100)
		oPrint:Say(nLin,2540,Transform(_cDTVali,"@d")								,ArialN10B 	,100)
	//EndIf
	
	If _cPosto == '01'
		oPrint:Say(nLin,2710,'Prazo Entrega:'+Transform(_cPraEnt,"@d")			,ArialN10B 	,100)
	ElseIf _cPosto == '03'
		oPrint:Say(nLin,2710,'Prazo Entrega:'+_cPraEnt 							,ArialN10B 	,100)
	EndIf
	
	nLin+=35
	oPrint:Say(nLin,1790,"Cond.Pagto:" 											,ArialN10B	,100)
	oPrint:Say(nLin,1980,SubStr(AllTrim(_cCODPAG)+'-'+AllTrim(_cNOMPAG),1,40)	,ArialN10B	,100)
	
	If _cFatMin > 0
		oPrint:Say(nLin,2385,"Faturamento Mínimo: "+;
		Transform(_cFatMin,"@E 9,999,999.99")					,ArialN10B	,100)
	Endif      
Else
	nLin+=70
Endif

nLin+=30
oPrint:Line(nLin,0050, nLin, 3000)

nCol+=70
nLin+=30
oPrint:Say(nLin,nCol,"Item"			  			       	  							,ArialN12B	,100)

nCol+=110
oPrint:Say(nLin,nCol,"Código"	           	   										,ArialN12B	,100)

nCol+=150
oPrint:Say(nLin,nCol,"Descrição"														,ArialN12B	,100)

If cEmpAnt+cFilAnt == '0401'//.And. SC5->C5_TIPODIP == '2'
	If _lICM .Or. _lRascunho
		nCol+=1370
		oPrint:Say(nLin,nCol,"Quant."					   		 					    ,ArialN12B	,100)      
		nCol+=170
		oPrint:Say(nLin,nCol,"Un"						    						    ,ArialN12B	,100)
		
		nCol+=100
		oPrint:Say(nLin,nCol,"Preço Unit"											,ArialN12B	,100)
		If _lRascunho
			nCol+=300
			oPrint:Say(nLin,nCol,"Preço Total"										,ArialN12B	,100)
			nCol+=300
			oPrint:Say(nLin,nCol,"IA:"+TransForm(_cIA,"@E ***.***")						,ArialN10B	,100)
			nCol+=200
			oPrint:Say(nLin,nCol,"IL:"+TransForm(_cIL,"@E ***.***")						,ArialN10B	,100)
		Else         
			nCol+=300
			oPrint:Say(nLin,nCol,"Total c/ ICMS"										,ArialN12B	,100)
			nCol+=300
			oPrint:Say(nLin,nCol,"Aliq"												,ArialN12B	,100)
			nCol+=150
			oPrint:Say(nLin,nCol,"Total s/ ICMS"										,ArialN12B	,100)
		EndIf
	Else	
		nCol+=1150
		oPrint:Say(nLin,nCol,"Quant."					   		 				     	,ArialN12B	,100)
		nCol+=200
		oPrint:Say(nLin,nCol,"UM"						    						    ,ArialN12B	,100)
		nCol+=110
		oPrint:Say(nLin,nCol,"Preço Unit"											,ArialN12B	,100)
		nCol+=240
		oPrint:Say(nLin,nCol,"Preço Liq."												,ArialN12B	,100)
		nCol+=175
		oPrint:Say(nLin,nCol,"% ICMS"												,ArialN12B	,100)
		nCol+=120
		oPrint:Say(nLin,nCol,"ICMS ST"												,ArialN12B	,100)       
		nCol+=200
		oPrint:Say(nLin,nCol,"IPI" 														,ArialN12B	,100)
		nCol+=200
		oPrint:Say(nLin,nCol,"Preço Total" 											,ArialN12B	,100)		
	EndIf                                                                                                
Else                                                                                                     
	If _lCartaVale  
		nCol+=1970
		oPrint:Say(nLin,nCol,"Quant."					   		 				     	,ArialN12B	,100)
		nCol+=480
		oPrint:Say(nLin,nCol,"UM"						    						    ,ArialN12B	,100)
	ElseIf _lICM .Or. _lRascunho
		nCol+=1320
		oPrint:Say(nLin,nCol,"Quant."					   		 					    ,ArialN12B	,100)
		
		nCol+=180
		oPrint:Say(nLin,nCol,"Un"						    						    ,ArialN12B	,100)
		
		nCol+=110
		oPrint:Say(nLin,nCol,"Preço Unit"											,ArialN12B	,100)
	
		If _lRascunho
			nCol+=300
			oPrint:Say(nLin,nCol,"Preço Total"										,ArialN12B	,100)
			nCol+=280
			oPrint:Say(nLin,nCol,"IA:"+TransForm(_cIA,"@E ***.***")						,ArialN10B	,100)
			nCol+=200
			oPrint:Say(nLin,nCol,"IL:"+TransForm(_cIL,"@E ***.***")						,ArialN10B	,100)
		Else         
			nCol+=300
			oPrint:Say(nLin,nCol,"Total c/ ICMS"										,ArialN12B	,100)
			nCol+=280
			oPrint:Say(nLin,nCol,"Aliq"												,ArialN12B	,100)
			nCol+=120
			oPrint:Say(nLin,nCol,"Total s/ ICMS"										,ArialN12B	,100)
		EndIf
	Else
		
		If  lArquivo
			nCol+=1040
			oPrint:Say(nLin,nCol,"Quant."					   		 				     	,ArialN12B	,100)
			nCol+=150
			oPrint:Say(nLin,nCol,"UM"						    						    ,ArialN12B	,100)
			nCol+=110
			oPrint:Say(nLin,nCol,"Preço Unit"											,ArialN12B	,100)
			nCol+=280
			oPrint:Say(nLin,nCol,"Preço Liq."												,ArialN12B	,100)
			nCol+=260
			oPrint:Say(nLin,nCol,"% ICMS"												,ArialN12B	,100)
			nCol+=160
			oPrint:Say(nLin,nCol,"Sald_Ped Qtd"												,ArialN12B	,100)
			nCol+=200	
			oPrint:Say(nLin,nCol,"Sald_Ped Vlr"												,ArialN12B	,100)
			nCol+=320
			oPrint:Say(nLin,nCol,"Preço Total" 											,ArialN12B	,100)					
		Else
			nCol+=1090
			oPrint:Say(nLin,nCol,"Quant."					   		 				     	,ArialN12B	,100)
			nCol+=200
			oPrint:Say(nLin,nCol,"UM"						    						    ,ArialN12B	,100)
			nCol+=110
			oPrint:Say(nLin,nCol,"Preço Unit"											,ArialN12B	,100)
			nCol+=280
			oPrint:Say(nLin,nCol,"Preço Liq."												,ArialN12B	,100)
			nCol+=260
			oPrint:Say(nLin,nCol,"% ICMS"												,ArialN12B	,100)
			nCol+=130	
			oPrint:Say(nLin,nCol,"ICMS ST"												,ArialN12B	,100)
			nCol+=280
			oPrint:Say(nLin,nCol,"Preço Total" 											,ArialN12B	,100)		
		EndIf	

	EndIf
EndIf
	    
nLin+=30
oPrint:Line(nLin,0050,nLin, 3000)
nLin+=10

Return
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ CorpoPDF  ³ Autor ³ Consultoria           ³ Data ³29.06.2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Impressao dos itens do Pedido/Orcamentoo                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function CorpoPDF(nLin)                    
Local nCol     := 0
Local _nSaldo  := 0
Local _nValSld := 0
Local _nBegin  := 1
Local nIt	   := 1

DbSelectArea("SC9")
DbSetOrder(2)

For nIt:=1 To Len(xCOD_PRO)

	nCol:=60	

	If Empty(xITEM_ORC[nIt])
		Exit
	EndIf
		
	If nRadio == 2
		If lArquivo
			SC9->(DbSeek(xFilial("SC9")+aDipSld[nIt]))
		EndIf
		If (nIt%2) == 0 .And. File("cinza.bmp") .And. !_lFax
			oPrint:SayBitmap(nLin+13,055,"cinza.bmp",2945,80)
		EndIf  
	Else
		If (nIt%2) == 0 .And. File("cinza.bmp") .And. !_lFax
			oPrint:SayBitmap(nLin+13,055,"cinza.bmp",2945,40)
		EndIf  	
	EndIf	

	U_LinPDF(@nLin,40)
	                       
	nCol+=10
	oPrint:Say(nLin,nCol,xITEM_ORC[nIt]									,CourN12	,100)
	
	nCol+=100
	oPrint:Say(nLin,nCol,xCOD_PRO[nIt]	  								,CourN12	,100)
	
	nCol+=150
	oPrint:Say(nLin,nCol,xDESC_PRO[nIt]	  								,CourN12	,100)
	        
	If cEmpAnt+cFilAnt == '0401' //.And. SC5->C5_TIPODIP == '2'
		If !_lICM .And. !_lRascunho                          
			nCol+=1200
			oPrint:Say(nLin,nCol,Transform(xQTD_PRO[nIt],"@E 999999")			,CourN12	,100)
			nCol+=160
			oPrint:Say(nLin,nCol,xUM_PRO[nIt]	 								,CourN12	,100)
			nCol+=120
			oPrint:Say(nLin,nCol,Transform(xPRE_UNI[nIt],"@E 99,999.9999")		,CourN12	,100)
			nCol+=200
			oPrint:Say(nLin,nCol,Transform(xVAL_MERC[nIt],"@E 9,999,999.99")	,CourN12	,100)
			nCol+=240
			oPrint:Say(nLin,nCol,Transform(xAL_ICMS[nIt],"@E 999")	,CourN12	,100)
			nCol+=060
			oPrint:Say(nLin,nCol,Transform(xVAL_ST[nIt],"@E 9,999,999.99")	    ,CourN12	,100)				
			nCol+=200
			oPrint:Say(nLin,nCol,Transform(xVAL_IPI[nIt],"@E 9,999,999.99")	,CourN12	,100)				
			nCol+=300
			oPrint:Say(nLin,nCol,Transform(xVAL_MERC[nIt]+xVAL_ST[nIt]+xVAL_IPI[nIt],"@E 9,999,999.99")	,CourN12	,100)
		Else                    
			nCol+=1380
			oPrint:Say(nLin,nCol,Transform(xQTD_PRO[nIt],"@E 999999")			,CourN12	,100)
			nCol+=190
			oPrint:Say(nLin,nCol,xUM_PRO[nIt]	 								,CourN12	,100)
			nCol+=170
			oPrint:Say(nLin,nCol,Transform(xPRE_UNI[nIt],"@E 99,999.9999")		,CourN12	,100)
		
			If _lRascunho
				nCol+=280
				oPrint:Say(nLin,nCol,Transform(xVAL_MERC[nIt],"@E 9,999,999.99")	,CourN12	,100)
				nCol+=280
				oPrint:Say(nLin,nCol,Transform(xIA[nIt],"@E ***.***")		,CourN12	,100)
				nCol+=250
				oPrint:Say(nLin,nCol,Transform(xIL[nIt],"@E ***.***")		,CourN12	,100)
			Else                    
				nCol+=280
				oPrint:Say(nLin,nCol,Transform(xVAL_CICM[nIt],"@E 9,999,999.99")		,CourN12	,100)
				nCol+=250
				oPrint:Say(nLin,nCol,Transform(xALIQ_PRO[nIt],"@E 99")				,CourN12	,100)
				nCol+=200
				oPrint:Say(nLin,nCol,Transform(xVAL_MERC[nIt],"@E 9,999,999.99")		,CourN12	,100)
			EndIf
		EndIf
	Else
	    If _lCartaVale
	    	oPrint:Say(nLin,2380,Transform(xQTD_PRO[nIt],"@E 999999")			,CourN12	,100)
			oPrint:Say(nLin,2880,xUM_PRO[nIt]	 								,CourN12	,100)
		ElseIf !_lICM .And. !_lRascunho                                
			
			If lArquivo
				_nSaldo := U_SALDC9(SC9->C9_PEDIDO,SC9->C9_PRODUTO,@_nSaldo,@_nValSld)
				
				nCol+=1030
				oPrint:Say(nLin,nCol,Transform(xQTD_PRO[nIt],"@E 999999")			,CourN12	,100)

				nCol+=175
				oPrint:Say(nLin,nCol,xUM_PRO[nIt]	 								,CourN12	,100)

				nCol+=70
				oPrint:Say(nLin,nCol,Transform(xPRE_UNI[nIt],"@E 99,999.9999")		,CourN12	,100)

				nCol+=255
				oPrint:Say(nLin,nCol,Transform(xVAL_MERC[nIt],"@E 9,999,999.99")		,CourN12	,100)

				nCol+= 340
				oPrint:Say(nLin,nCol,Transform(xAL_ICMS[nIt],"@E 999")		,CourN12	,100)
			
				nCol+=200
				
				oPrint:Say(nLin,nCol,Transform(_nSaldo,"@E 999999")		,CourN12	,100)
				
				nCol+=110
				oPrint:Say(nLin,nCol,Transform(_nValSld,"@E 9,999,999.99")		,CourN12	,100)
				_nValTotS += _nValSld
				
				nCol+=300
				oPrint:Say(nLin,nCol,Transform(xVAL_MERC[nIt]+xVal_ST[nIt],"@E 9,999,999.99")		,CourN12	,100)					
				
			Else
				nCol+=1150
				oPrint:Say(nLin,nCol,Transform(xQTD_PRO[nIt],"@E 999999")			,CourN12	,100)

				nCol+=170
				oPrint:Say(nLin,nCol,xUM_PRO[nIt]	 								,CourN12	,100)

				nCol+=150
				oPrint:Say(nLin,nCol,Transform(xPRE_UNI[nIt],"@E 99,999.9999")		,CourN12	,100)

				nCol+=260
				oPrint:Say(nLin,nCol,Transform(xVAL_MERC[nIt],"@E 9,999,999.99")		,CourN12	,100)

				nCol+= 280
				oPrint:Say(nLin,nCol,Transform(xAL_ICMS[nIt],"@E 999")		,CourN12	,100)
			
				oPrint:Say(nLin,nCol,Transform(xVal_ST[nIt],"@E 9,999,999.99")		,CourN12	,100)
				nCol+=350
				oPrint:Say(nLin,nCol,Transform(xVAL_MERC[nIt]+xVal_ST[nIt],"@E 9,999,999.99")		,CourN12	,100)							
			End

		Else          
			nCol+=1370
			oPrint:Say(nLin,nCol,Transform(xQTD_PRO[nIt],"@E 999999")			,CourN12	,100)
			
			nCOl+=150
			oPrint:Say(nLin,nCol,xUM_PRO[nIt]	 								,CourN12	,100)
			
			nCol+=150
			If !_lCartaVale
				oPrint:Say(nLin,nCol,Transform(xPRE_UNI[nIt],"@E 99,999.9999")		,CourN12	,100)
			Endif                   
			
			If _lRascunho
				nCol+=300
				oPrint:Say(nLin,nCol,Transform(xVAL_MERC[nIt],"@E 9,999,999.99")	,CourN12	,100)
				
				nCol+=250
				oPrint:Say(nLin,nCol,Transform(xIA[nIt],"@E ***.***")		,CourN12	,100)
				
				nCol+=250
				oPrint:Say(nLin,nCol,Transform(xIL[nIt],"@E ***.***")		,CourN12	,100)
			Else
				nCol+=300
				oPrint:Say(nLin,nCol,Transform(xVAL_CICM[nIt],"@E 9,999,999.99")		,CourN12	,100)
				
				nCol+=250
				oPrint:Say(nLin,nCol,Transform(xALIQ_PRO[nIt],"@E 99")				,CourN12	,100)
				
				nCol+=250
				oPrint:Say(nLin,nCol,Transform(xVAL_MERC[nIt],"@E 9,999,999.99")		,CourN12	,100)
			EndIf
		EndIf
	EndIf

	If nRadio == 2
		If! Empty(xREG_ANVI[nIt])
			nLin+=40
			oPrint:Say(nLin,0320,+"Registro ANVISA: "+xREG_ANVI[nIt])				
		EndIf
 	EndIf		 
					
	If _lObsProd .And. !Empty(Posicione("SB1",1,xFilial("SB1")+xCOD_PRO[nIt],"B1_CODOBS"))
		_cObsProd	:= MSMM(SB1->B1_CODOBS,60)
		_cObsProd	:= StrTran(_cObsProd,Chr(13),"")
		_cObsProd	:= StrTran(_cObsProd,Chr(10)," ")
		_nTotLinObs := MLCount(_cObsProd,50)
		
		For _nBegin := 1 To _nTotLinObs
			                           
			U_LinPDF(@nLin,40)
			
			If (nIt%2) == 0 .And. File("cinza.bmp") .And. !_lFax
				oPrint:SayBitmap(nLin-28,055,"cinza.bmp",2945,41)
			EndIf
			
			oPrint:Say(nLin,0390,MemoLine(_cObsProd,55,_nBegin)	,CourN12	,100)
		Next _nBegin
		If _nTotLinObs >0
			U_LinPDF(@nLin,15)
		EndIf
	EndIf
Next nIt

Return .T.
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ LinPDF    ³ Autor ³ Consultoria           ³ Data ³29.06.2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Controle de Linhas e Quebras do Relatório                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function LinPDF(nLin,nSoma,nLimite)
DEFAULT nLimite := 1960

nLin+=nSoma

If nLin > nLimite
	U_RodapPDF(.T.)
	U_CabecPDF(@nlin)
	nLin+=40
EndIf

Return
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ RodapPDF ³ Autor ³ CONSULTORIA           ³ Data ³          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Imprime o rodape do formulario e salta para a proxima folha³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ DIPROMED                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function RodapPDF(lSalto)
Local nLimite := 0                
Local nCol	  := 0
Default lSalto := .F.

nLimite := If(lSalto, 2000, 1880)

nCol+=50

// Linha do Final dos Itens
oPrint:Line(nLimite,nCol, nLimite, nCol+2950)

//Linha cpo:Codigo
nCol += 100
oPrint:Line(400,nCol, nLimite, nCol)

//Linha cpo:Descricao
nCol+=150
oPrint:Line(400,nCol, nLimite, nCol)
    
If cEmpAnt+cFilAnt == '0401' //.And. SC5->C5_TIPODIP = '2'

	If _lICM .Or. _lRascunho

		//Linha cpo:Qtde	
		nCol+=1350	
		oPrint:Line(400,nCol,nLimite,nCol)

		//Linha cpo:Un
		nCol+=200
		oPrint:Line(400,nCol,nLimite,nCol)	

		//Linha cpo:Pr.Unit
		nCol+=100
		oPrint:Line(400,nCol,nLimite,nCol)
	
		//Linha cpo:Total c/Icms
		nCol+=300
		oPrint:Line(400,nCol, nLimite, nCol)

		//Linha cpo:Aliq  ou IA
		nCol+=300
		oPrint:Line(400,nCol, nLimite, nCol)

		If !_lRascunho
			//Linha cpo:Pr.Total
			nCol+=100
			oPrint:Line(400,nCol, nLimite, nCol)
		Else
			//Linha cpo:IL
			nCol+=200
			oPrint:Line(400,nCol, nLimite, nCol)
		EndIf
	Else	
		//Linha cpo:Qtde	
		nCol+=1150	
		oPrint:Line(400,nCol,nLimite,nCol)

		//Linha cpo:Un
		nCol+=200
		oPrint:Line(400,nCol,nLimite,nCol)	

		//Linha cpo:Pr.Unit
		nCol+=100
		oPrint:Line(400,nCol,nLimite,nCol)

		//Linha cpo:Val.Liq.
		nCol+=250
		oPrint:Line(400,nCol, nLimite, nCol)

		//Linha cpo:Al.ICMS
		nCol+=200
		oPrint:Line(400,nCol, nLimite, nCol)

		//Linha cpo:ST
		nCol+=105
		oPrint:Line(400,nCol, nLimite, nCol)
		
		//Linha cpo:IPI
		nCol+=195
		oPrint:Line(400,nCol, nLimite, nCol)
		
		//Linha cpo:TOTAL
		nCol+=200
		oPrint:Line(400,nCol, nLimite, nCol)
	EndIf
Else    
	If _lCartaVale
		nCol+=2000
		oPrint:Line(400,nCol,nLimite,nCol)
		nCol+=350
		oPrint:Line(400,nCol,nLimite,nCol)	
	ElseIf _lICM .Or. _lRascunho          
		//Linha cpo:Qtde
		nCol+=1300		
		oPrint:Line(400,nCol,nLimite,nCol)

		//Linha cpo:Un
		nCol+=200
		oPrint:Line(400,nCol,nLimite,nCol)

		//Linha cpo:Pr.Unit
		nCol+=100
		oPrint:Line(400,nCol,nLimite,nCol)
	
		//Linha cpo:Total c/Icms
		nCol+=300
		oPrint:Line(400,nCol, nLimite, nCol)

		//Linha cpo:Aliq  ou IA
		nCol+=300
		oPrint:Line(400,nCol, nLimite, nCol)

		If !_lRascunho
			//Linha cpo:Pr.Total
			nCol+=100
			oPrint:Line(400,nCol, nLimite, nCol)
		Else
			//Linha cpo:IL
			nCol+=200
			oPrint:Line(400,nCol, nLimite, nCol)
		EndIf
	Else
	
		If lArquivo
			//Linha cpo:Qtde
			nCol+=1000		
			oPrint:Line(400,nCol,nLimite,nCol)
	
			//Linha cpo:Un
			nCol+=200
			oPrint:Line(400,nCol,nLimite,nCol)
	
			//Linha cpo:Pr.Unit
			nCol+=100
			oPrint:Line(400,nCol,nLimite,nCol)
	
			//Linha cpo:Preço Liq
			nCol+=280
			oPrint:Line(400,nCol,nLimite,nCol)
	
			//Linha cpo:ALiq ICMS
			nCol+=280
			oPrint:Line(400,nCol,nLimite,nCol)
	
			//Linha cpo:ValST / Sald_Ped Qtd
			nCol+=130
			oPrint:Line(400,nCol,nLimite,nCol)
						
			//Linha cpo: Sald_Ped Vlr
			nCol+= 220
			oPrint:Line(400,nCol,nLimite,nCol)	        
			
			//Linha cpo:Pr.Total
			nCol+=240
			oPrint:Line(400,nCol,nLimite,nCol)
		Else
			//Linha cpo:Qtde
			nCol+=1100		
			oPrint:Line(400,nCol,nLimite,nCol)
	
			//Linha cpo:Un
			nCol+=200
			oPrint:Line(400,nCol,nLimite,nCol)
	
			//Linha cpo:Pr.Unit
			nCol+=100
			oPrint:Line(400,nCol,nLimite,nCol)
	
			//Linha cpo:Preço Liq
			nCol+=280
			oPrint:Line(400,nCol,nLimite,nCol)
	
			//Linha cpo:ALiq ICMS 
			nCol+=280
			oPrint:Line(400,nCol,nLimite,nCol)
	
			//Linha cpo:ValST 
			nCol+=130
			oPrint:Line(400,nCol,nLimite,nCol)
	        
			//Linha cpo:Pr.Total
			nCol+=260
			oPrint:Line(400,nCol,nLimite,nCol)		
		EndIf		
	EndIf
EndIf    
                                       
If lSalto
	oPrint:Say(2070,1400,"Continua...",ArialN12B	,100)
EndIf

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ FinalPDF  ³ Autor ³ CONSULTORIA           ³ Data ³          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Imprime os dados complementares do Pedido de Venda         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ DIPROMED                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function FinalPDF()
                         
Local lRetST := U_VerProdST()



// Finaliza o Pedido, fazendo o "X" no espaço em branco...
If !_lCartaVale
	U_LinPDF(@nLin,015)
	If nLin < 1860 .Or. (nLin > 1800 .And. nLin < 1980 )
		oPrint:Line(nLin,0050, nLin, 3000)
		oPrint:Line(If(nLin < 1860,1880,2000),0050, nLin, 3000)
		oPrint:Line(If(nLin < 1860,1880,2000),3000, nLin, 0050)
	EndIf
	If nLin > 1860
		nLin := 2200
		U_LinPDF(@nLin,10)
		oPrint:Line(1880,0050, 0480, 3000)
		oPrint:Line(1880,3000, 0480, 0050)
	EndIf
EndIf                               

nLin:=1880

If _lCartaVale // Carta de Vale para licitação - MCVN 05/03/08
	
	// Nome do Cliente
	oPrint:Box(1880,2200,2000,3002)
	oPrint:Say(1900,2205,"Nome por extenso:"                   ,ArialN9 	,100)
	
	// Assinatura do cliente
	oPrint:Box(2000,2200,2120,3002)
	oPrint:Say(2020,2205,"Ass:" 		           				,ArialN9 	,100)
	
	// Data da assinatura
	oPrint:Box(2120,2200,2240,3002)
	oPrint:Say(2140,2205,"Local e Data:"  				       	,ArialN9 	,100)
	
Else 
	If cCliST   = "R" //A1_TIPO $ "R/S" e A1_CONTRIB <> "2"  e A1_PESSOA = "JURIDICA" e A1_DREGESP <> " "
		U_DIPICMSHEl(SC5->C5_NUM,0,"")	      
	EndIf                                
	
	If cEmpAnt = "04" 
	     nValIpi:=	U_CALCIPI(SC5->C5_NUM)
		// Box Tot. Mercadoris.
		oPrint:Box(2030,2200,1950,3002) //Giovani zago 13/01/12
		oPrint:Say(1920,2210,If(_lIcm,	"Totais",;
		"Total das Mercadorias:")		,ArialN12B	,100)
		If _lIcm
			oPrint:Say(1920,2410,Transform(_cTOTI,"@E 999,999,999.99")	,CourN12B	,100)
			oPrint:Say(1920,2750,Transform(_cTOTG,"@E 999,999,999.99")	,CourN12B	,100)
		Else
			oPrint:Say(1920,2750,Transform(_cTOTG,"@E 999,999,999.99")	,CourN12B	,100)
		EndIf
		
		// Box IPI / ICMS-ST
		oPrint:Box(1950,2200,2020,3002)
		oPrint:Say(1990,2210,"IPI:" 		           					,ArialN12B	,100)
		oPrint:Say(1990,2400,Transform(nValIpi, "@E 999,999,999.99")	,ArialN12	,100)
		oPrint:Say(1990,2650,"Sub.Trib.:" 	           					,ArialN12B	,100)

		        
		If Type("nValST")=="U"   
			nValSt := 0			
		EndIf          
		
		//oPrint:Say(1990,2830, Transform(nValST, "@E 999,999,999.99") 	,ArialN12	,100)
		oPrint:Say(1980,2830,Transform(MaFisRet(,"NF_VALSOL"),"@E 99,999,999.99") 	,ArialN10	,100)
		_nValIST := MaFisRet(,"NF_VALSOL")
		// Box Frete/Despesas
		oPrint:Box(2020,2200,2090,3002)
		oPrint:Say(2060,2210,"Frete:" 		           					,ArialN12B	,100)
		oPrint:Say(2060,2400,Transform(nVal_Fre, "@E 999,999,999.99")	,ArialN12	,100)
		oPrint:Say(2060,2650,"Despesas:" 	           					,ArialN12B	,100)
		oPrint:Say(2060,2830,Transform(nVal_Des, "@E 999,999,999.99")	,ArialN12	,100)
		
		// Box Total Geral
		oPrint:Box(2090,2200,2200,3002)
		oPrint:Say(2130,2210,"TOTAL GERAL:"  				           	,ArialN12B	,100)
		//oPrint:Say(2130,2830,Transform(_cTotG + nVal_Fre + nVal_Des + nValIpi + nValST, "@E 999,999,999.99")	,ArialN12B	,100)
		oPrint:Say(2130,2830,Transform(_cTotG + nVal_Fre + nVal_Des + nValIpi + _nValIST, "@E 999,999,999.99")	,ArialN12B	,100)
	Else                           

		// Box Tot. Mercadoris.
		oPrint:Line(nLin,2200,nLin+530,2200)
		//oPrint:Line(nLin+330,2200,nLin+330,3000)
	
		nLin+=45
		oPrint:Say(nLin,2220,If(_lIcm,"Totais","Total das Mercadorias:") ,ArialN12B	,100)
	
		If _lIcm
			oPrint:Say(nLin,2410,Transform(_cTOTI,"@E 999,999,999.99")	,ArialN12	,100)
			oPrint:Say(nLin,2790,Transform(_cTOTG,"@E 999,999,999.99")	,ArialN12	,100)
		Else
			oPrint:Say(nLin,2830,Transform(_cTOTG,"@E 999,999,999.99")	,ArialN12	,100)
		EndIf
		
		If lArquivo
			oPrint:Say(nLin,2500,Transform(_nValTotS,"@E 999,999,999.99")	,CourN12B	,100)		
		EndIf
		
		         
		// Box Frete/Despesas          
		nLin+=45
		oPrint:Line(nLin,2200,nLin,3000)
		
		nLin+=45
		oPrint:Say(nLin,2220,"Total de Frete:"         					,ArialN12B	,100)
		oPrint:Say(nLin,2400,Transform(nVal_Fre, "@E 999,999,999.99")	,ArialN12	,100)
		oPrint:Say(nLin,2650,"Despesas:" 	           					,ArialN12B	,100)
		oPrint:Say(nLin,2830,Transform(nVal_Des, "@E 999,999,999.99")	,ArialN12	,100)
	
		// Box Frete/Despesas          
		nLin+=45
		oPrint:Line(nLin,2200,nLin,3000)
		
		nLin+=45                        
		oPrint:Say(nLin,2220,"Total ICMS ST:"          					,ArialN12B	,100)    	
		//Aguardando reunião para ativar
		oPrint:Say(nLin,2400,Transform(_nTotST, "@E 999,999,999.99")	,ArialN12	,100)		

		// Box Total Geral
		
		nLin+=45
		oPrint:Line(nLin,2200,nLin,3000)		

		nLin+=65
		oPrint:Say(nLin,2220,"TOTAL GERAL:"  				           	,ArialN14B	,100)                            
		//Aguardando reunião para ativar a regra.
		oPrint:Say(nLin,2820,Transform(_cTotG + nVal_Fre + nVal_Des + _nTotST,"@E 999,999,999.99"),ArialN14B	,100)

	EndIf
Endif
EndImp()//Encerra Impostos
// Observacoes
Li := 1920
_lPed :=If("PEDIDO" $ _cTitulo .or. "CARTA" $ _cTitulo,.T.,.F.)

If !_lCartaVale
	oPrint:Say(Li,0070,"Tipo de Frete:"								,ArialN12B	,100)
	If _cTransp == '000111'
		oPrint:Say(Li,0250,_cTipFre +" - "+_cDestFre+" - "+_cTransp+" - "+_cNomeTra ,ArialN10, 100)
		oPrint:Say(Li+30,0070,"LOCAL DE RETIRA: AV. DR. MAURO LINDEMBERG MONTEIRO, 185 - GLP10 - CEP: 06278-010 - JD. SANTA FÉ - OSASCO - SP",ArialN12B	,100,CLR_RED)
	Else
		oPrint:Say(Li,0250,_cTipFre +" - "+_cDestFre+" - "+_cTransp+" - "+_cNomeTra ,ArialN10, 100)	
	EndIf	
Endif                              

If !_lCartaVale
	Li += 60
	oPrint:Say(Li,0070,"Obs:"										,ArialN12B	,100)
	oPrint:Say(Li,0150,Substr(_cObs,001,100)						,ArialN12	,100)
	Li += 45
	oPrint:Say(Li,0070,Substr(_cObs,101,100)						,ArialN12	,100)
	Li += 45
	oPrint:Say(Li,0070,Substr(_cObs,201,100)						,ArialN12	,100)
Else
	//Li += 60
	oPrint:Say(Li,0070,"Obs:"										,ArialN12B	,100)
	oPrint:Say(Li,0170,Substr(_cObs,001,100)						,ArialN12	,100)
	Li += 45
	oPrint:Say(Li,0070,Substr(_cObs,101,100)						,ArialN12	,100)
	Li += 45
	oPrint:Say(Li,0070,Substr(_cObs,201,100)						,ArialN12	,100)
Endif
                              
Li += 50
If !Empty(_cMVista1+_cMVista2)	
	oPrint:Say(Li,0070,_cMVista1									,ArialN12B	,100)
	oPrint:Say(Li,0450,_cMVista3									,ArialN12B	,100)
	oPrint:Say(Li,0830,_cMVista2									,ArialN12	,100)
EndIf


If _lPed
	Li += 100
	If !_lCartaVale
		oPrint:Say(385,0660,"São Paulo, "+Transform(_cEmi,"@D")+" - Vendedor(a): "+If(_cPosto $ '01/03',_cNomeVen+' / Operador(a):  '+_cNomeOpe,_cNomeVen)+" - "+If(_cPosto $ '01/03',_cMailOpe,_cMailVen) ,ArialN9	,100)
	Else
		Li += 110
		oPrint:Say(395,0660,"São Paulo, "+Transform(_cEmi,"@D")+" - Vendedor(a): "+If(_cPosto $ '01/03',_cNomeVen+' / Operador(a):  '+_cNomeOpe,_cNomeVen)+" - "+If(_cPosto $ '01/03',_cMailOpe,_cMailVen) ,ArialN9	,100)
	Endif
	
	If !_lCartaVale
                                         

		If AllTrim(SC5->C5_ESTE) == 'SP' .And. lRetST
			Li += 30			
			oPrint:Say(Li,0070,'"Produto comprado com SUBSTITUIÇAO, segundo o RICMS(Lei 6.374/89, art. 67, Não tem destaque de ICMS."',ArialN14B,100,CLR_HRED)
		EndIf
		Li += 40
		oPrint:Say(Li,0070,"ESTA É A CÓPIA DO SEU PEDIDO DE COMPRAS. EM CASO DE DIVERGÊNCIA ENTRAR EM CONTATO COM A VENDEDORA.", ArialN12B	,100)
		If _cPosto == '02' //RBorges - 02/09/2014 - Adicionada informação no pedidod de vendas, apenas para televendas.
			Li += 40
			oPrint:Say(Li,0070,"COMUNICADO IMPORTANTE! Por favor, antes da confirmação do seu pedido verificar as quantidades, os itens, frete, prazo de pagamento ",ArialN14B ,100)
			Li += 30
			oPrint:Say(Li,0070,"e o endereço de entrega. Após a sua conferência e confirmação, não aceitaremos devoluções ou trocas futuras. ",ArialN14B ,100)
			Li += 40
			oPrint:Say(Li,0070,"O PEDIDO SERÁ LIBERADO PARA FATURAMENTO, SOMENTE APÓS O RECEBIMENTO DO E-MAIL DE CONFIRMAÇÃO. ",ArialN14B,100)
		EndIf
	Endif
	
Else
	Li += 100
	oPrint:Say(Li,0070,'"ATENCÃO! ORÇAMENTO SUJEITO A ALTERAÇÃO DE PREÇO E ESTOQUE SEM PRÉVIO AVISO."',ArialN14B,100,CLR_HRED)	
    If AllTrim(SC5->C5_ESTE) == 'SP' .And. lRetST
		Li += 50			
		oPrint:Say(Li,0070,'"Produto comprado com SUBSTITUIÇAO, segundo o RICMS(Lei 6.374/89, art. 67, Não tem destaque de ICMS."',ArialN14B,100,CLR_HRED)
	EndIf	
	Li += 100
	oPrint:Say(Li,0070,"São Paulo, "+Transform(_cEmi,"@D")+" -  Vendedor(a): "+If(_cPosto $ '01/03',_cNomeVen+' / Operador(a):  '+_cNomeOpe,_cNomeVen)+" - "+If(_cPosto $ '01/03',_cMailOpe,_cMailVen) ,ArialN9	,100)
EndIf


Return .T.
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³JpegMail  ºAutor  ³Microsiga           º Data ³  01/22/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ DIPR064                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function PDFMail(cMailFrom,cMailTo,_cTipoVen,lOrc)
Local aArea      := GetArea()
Local cDir		 := "c:\pedidos\"
Local cArquivo	 := ""
Local cDestino   := "\RELATO\JPEG\"

Local cAccount  := Lower(Alltrim(GetMv("MV_RELACNT")))
Local cFrom     := Lower(Alltrim(GetMv("MV_RELACNT")))
Local cPassword := Alltrim(GetMv("MV_RELPSW"))
Local cServer   := Alltrim(GetMv("MV_RELSERV"))
Local cCC		:= cMailFrom
Local cBCC      := ""
Local cTo		:= cMailTo
Local lSmtpAuth := GetNewPar("MV_RELAUTH",.F.)
Local lAutOk	:= .F.
DEFAULT lOrc 	:= .F.

If !Empty(AllTrim(POSICIONE("SU7",1,XFILIAL("SU7")+SC5->C5_OPERADO,"U7_EMAIL"))) .And. !Empty(AllTrim(POSICIONE("SU7",1,XFILIAL("SU7")+SC5->C5_OPERADO,"U7_SENHA")))
	cAccount  := AllTrim(POSICIONE("SU7",1,XFILIAL("SU7")+SC5->C5_OPERADO,"U7_EMAIL"))
	cFrom     := AllTrim(POSICIONE("SU7",1,XFILIAL("SU7")+SC5->C5_OPERADO,"U7_EMAIL"))
	cPassword := AllTrim(POSICIONE("SU7",1,XFILIAL("SU7")+SC5->C5_OPERADO,"U7_SENHA"))
EndIf	

cArquivo := IIf(lOrc,"ORC_","PV_")+_nORC+"_"+IIf(lOrc,substr(cComNoPed,12,21),substr(cComNoPed,11,21))+".pdf"
 
cBody  := If(!Empty(_cBodyPrvt),_cBodyPrvt, "Segue em anexo "+_cTitulo+" nº. "	+_nORC)
cSubject := _cTitulo+" n: "+_nORC


If !Empty(_cMVista1+_cMvista2)
	cBody += CHR(10)+CHR(13)+CHR(10)+CHR(13)
	cBody += CHR(10)+CHR(13)+CHR(10)+CHR(13)
	cBody += _cMVista1
	cBody += CHR(10)+CHR(13)+CHR(10)+CHR(13)
	cBody += CHR(10)+CHR(13)+CHR(10)+CHR(13)
	cBody += _cMVista3
	cBody += CHR(10)+CHR(13)+CHR(10)+CHR(13)
	cBody += CHR(10)+CHR(13)+CHR(10)+CHR(13)
	cBody += _cMVista2
EndIf                        

CpyT2S(cDir+cArquivo,cDestino,.F.)

CONNECT SMTP SERVER cServer ACCOUNT cAccount PASSWORD cPassword Result lOk

If !lAutOk
	If ( lSmtpAuth )
		lAutOk := MailAuth(cAccount,cPassword)
	Else
		lAutOk := .T.
	EndIf
EndIf

If lOk .and. lAutOk
	If !Empty(cCC)
		SEND MAIL FROM cFrom TO cTo CC cCC BCC cBcc SUBJECT Alltrim(cSubject) BODY cBody ATTACHMENT cDestino+cArquivo Result lOk
	Else
		SEND MAIL FROM cFrom TO cTo SUBJECT Alltrim(cSubject) BODY cBody ATTACHMENT cDestino+cArquivo Result lOk
	EndIf
	If lOk
		MsgInfo("Email enviado com sucesso")
	Else
		GET MAIL ERROR cErro
		MsgStop("Não foi possível enviar o Email." +Chr(13)+Chr(10)+ cErro,"AVISO")
		Return .f.
	EndIf
Else
	GET MAIL ERROR cErro
	MsgStop("Erro na conexão com o SMTP Server." +Chr(13)+Chr(10)+ cErro,"AVISO")
	Return .f.
EndIf
DISCONNECT SMTP SERVER

fErase(cDestino+cArquivo)

RestArea(aArea)

Return .T.

User Function VerProdST()
Local _lRet  := .F.
Local nI 
Local cPosTes:= aScan(aHeader, { |x| Alltrim(x[2]) == "C6_TES" })

For nI := 1 To Len(aCols)
	If ! Funname() == "DIPAL10"
		If aCols[nI,cPosTes] $ '625/825'
			_lRet := .T.
			Exit
		EndIf
	EndIf
Next

Return (_lRet)

/*-------------------------------------------------------------+
| Funcao: SALDC9 | Autor : RBORGES   |    Data: 25/10/2018     |
+--------------------------------------------------------------+
|Descrição: Verificar saldo na C9 por pedido e produto.        |
|											                   |      													              
+--------------------------------------------------------------*/

User Function SALDC9(_cPedido,_cProduto,nSldC9,nValSldC9)

Local _xAlias    := GetArea()
Local QRY1       := ""
Local nSldC9     := 0
Local nValSldC9  := 0
           
QRY1 := "SELECT "
QRY1 += " SUM(C9_SALDO) AS SALDO, (C9_PRCVEN * C9_SALDO) AS VALSALDO "
QRY1 += " FROM " +RetSQLName("SC9")
QRY1 += " WHERE C9_FILIAL  = '"+xFilial("SC9")+"' "
QRY1 += " AND   C9_PEDIDO  = '"+_cPedido+ "'"
QRY1 += " AND   C9_PRODUTO = '"+_cProduto+"'"
QRY1 += " AND   C9_QTDVEN  > 0  "
QRY1 += " AND   C9_SALDO   > 0  "
QRY1 += " AND   C9_NFISCAL = '' "
QRY1 += " AND   D_E_L_E_T_ = ' ' "
QRY1 += " GROUP BY C9_SALDO, C9_PRCVEN, C9_SALDO "   

QRY1 := ChangeQuery(QRY1) 
dbUseArea(.T.,"TOPCONN",TcGenQry(,,QRY1),'SLDC9',.T.,.F.)    

If ! SLDC9->(EOF())
	nSldC9   := SLDC9->SALDO
	nValSldC9:= SLDC9->VALSALDO
EndIf

DBCLOSEAREA("SLDC9")
RestArea(_xAlias)

Return(nSldC9)

/*
|-----------------------------------------------------------------------------------|
|  Programa : IniImp                                       Data : 07/06/2021        |
|-----------------------------------------------------------------------------------|
|  Cliente  : DIPROMED                                        						|
|-----------------------------------------------------------------------------------|
|  Uso      : Rotina de calculo dos impostos através da MATXFIS 		            |
|-----------------------------------------------------------------------------------|
*/
Static Function IniImp()
Local aArea		:= GetArea()
Local aAreaSA1	:= SA1->(GetArea())
Local nPrcLista := 0
Local nValMerc  := 0
Local nDesconto := 0
Local nQtdPeso  := 0
Local nPosEntr  := 0
Local cProduto  := ""
Local nTotDesc  := 0
Local lSaldo    := .F.
Local nQtdEnt   := 0
Local aSolid	:= {}
Local nLancAp	:=	0
Local aTransp	:= {"",""}
Local aSaldos	:= {}
Local nValRetImp:= 0
Local cImpRet 	:= ""
Local cCliAux   := ""
Local cLjAux    := ""
Local cProsp    := ""
Local nTotal	:= 0
Private oLogApICMS
Private _nTotOper_ := 0		//total de operacoes (vendas) realizadas com um cliente - calculo de IB - Argentina
Private _aValItem_ := {}
Private cTpCli	   := SA1->A1_TIPO
MaFisSave()
MaFisEnd()
MaFisIni(SA1->A1_COD,SA1->A1_LOJA,"C","N",cTpCli,Nil,Nil,Nil,Nil,"MATA461",Nil,Nil,cProsp,Nil,Nil,Nil,Nil,aTransp)
/*
MaFisIni(SA1->A1_COD,;	// 1-Codigo Cliente/Fornecedor
		 SA1->A1_LOJA,;	// 2-Loja do Cliente/Fornecedor
		"C",;			// 3-C:Cliente , F:Fornecedor
		"N",;			// 4-Tipo da NF
		cTpCli,;		// 5-Tipo do Cliente/Fornecedor
		Nil,;
		Nil,;
		Nil,;
		Nil,;
		"MATA461",;
		Nil,;
		Nil,;
		Nil,;
		Nil,;
		Nil,;
		Nil,;
		Nil,;
		aTransp,;
		Nil,;
		Nil,;
		Nil,;
		Nil,;
		Nil,;
		nTotal,;
		Nil,;
		_cTipFre)
*/
Return

/*
|-----------------------------------------------------------------------------------|
|  Programa : ADDImp                                       Data : 07/06/2021        |
|-----------------------------------------------------------------------------------|
|  Cliente  : DIPROMED                                         						|
|-----------------------------------------------------------------------------------|
|  Uso      : Rotina de calculo dos impostos através da MATXFIS 		            |
|-----------------------------------------------------------------------------------|
*/
Static Function ADDImp(_nVALOR, _nQTDVEN, _nPRCVEN, _cCLIENT, _cLOJA, _cPRODUT, _cTES)
Local nRecOri   := 0
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Agrega os itens para a funcao fiscal         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nQtdPeso := 0

cProduto := _cPRODUT
SB1->(dbSetOrder(1))
If SB1->(MsSeek(xFilial("SB1")+cProduto))
	nQtdPeso := SB1->B1_PESO
EndIf

SB2->(dbSetOrder(1))
SB2->(MsSeek(xFilial("SB2")+SB1->B1_COD+SB1->B1_LOCPAD))

SF4->(dbSetOrder(1))
SF4->(MsSeek(xFilial("SF4")+_cTES))

cNfOri     := Nil
cSeriOri   := Nil
nRecnoSD1  := Nil
nDesconto  := 0
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Calcula o preco de lista                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

nValMerc  := _nVALOR
nPrcLista := _nPRCVEN
nQtd  	  := _nQTDVEN

If (nPrcLista == 0)
	nPrcLista := NoRound(nValMerc/nQtd,TamSX3("C6_PRCVEN")[2])
EndIf

nAcresFin := 0 //A410Arred(SCK->CK_PRCVEN*SCJ->CJ_ACRSFIN/100,"D2_PRCVEN")
nValMerc  += A410Arred(nQtd*nAcresFin,"D2_TOTAL")		
nDesconto := a410Arred(nPrcLista*nQtd,"D2_DESCON")-nValMerc
nDesconto := Max(0,nDesconto)
nPrcLista += nAcresFin
nValMerc  += nDesconto

//nPrcLista := SC6->C6_PRCVEN
//nValMerc  := SC6->C6_PRCVEN*SC6->C6_QTDVEN

dDataCnd  := dDatabase

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Agrega os itens para a funcao fiscal         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
MaFisAdd(cProduto,;	      // 1-Codigo do Produto ( Obrigatorio )
		 _cTES,; 		 // 2-Codigo do TES ( Opcional )
		 nQtd,;  		 // 3-Quantidade ( Obrigatorio )
		 nPrcLista,;     // 4-Preco Unitario ( Obrigatorio )
		 nDesconto,;     // 5-Valor do Desconto ( Opcional )
		 cNfOri,;        // 6-Numero da NF Original ( Devolucao/Benef )
		 cSeriOri,;      // 7-Serie da NF Original ( Devolucao/Benef )
		 nRecOri,;        // 8-RecNo da NF Original no arq SD1/SD2
		 0,;              // 9-Valor do Frete do Item ( Opcional )
		 0,;              // 10-Valor da Despesa do item ( Opcional )
		 0,;              // 11-Valor do Seguro do item ( Opcional )
		 0,;              // 12-Valor do Frete Autonomo ( Opcional )
		 nValMerc,;       // 13-Valor da Mercadoria ( Obrigatorio )
		 0,;              // 14-Valor da Embalagem ( Opiconal )
		 ,;               // 15
		 ,;               // 16
		 "",;             // 17
		 0,;              // 18-Despesas nao tributadas - Portugal
		 0,;              // 19-Tara - Portugal
		 SF4->F4_CF)      // 20-CFO

MaFisWrite(1)
Return

/*
|-----------------------------------------------------------------------------------|
|  Programa : EndImp                                       Data : 18/08/2020        |
|-----------------------------------------------------------------------------------|
|  Cliente  : DIPROMED                                         						|
|-----------------------------------------------------------------------------------|
|  Uso      : Rotina de calculo dos impostos através da MATXFIS 		            |
|-----------------------------------------------------------------------------------|
*/
Static Function EndImp()
MaFisEnd()
MaFisRestore()
Return

/*
|-----------------------------------------------------------------------------------|
|  Programa : CALCPED                                       Data : 18/08/2020       |
|-----------------------------------------------------------------------------------|
|  Cliente  : DIPROMED                                         						|
|-----------------------------------------------------------------------------------|
|  Uso      : Rotina de calculo total do pedido							            |
|-----------------------------------------------------------------------------------|
*/
Static Function CALCPED(cNumPed)
Local _cQry 	:= "" 
Local _nTotPed	:= 0
_cQry :=" SELECT ISNULL(SUM(C6_VALOR),0) AS 'TOT'   "
_cQry +=" FROM "+RETSQLNAME ("SC6") + " SC6 "
_cQry +=" WHERE C6_NUM       =  '"+cNumPed+"' "
_cQry +=" AND SC6.D_E_L_E_T_ = ' '       "
_cQry +=" AND C6_FILIAL      =  '"+XFILIAL("SC6")+"' "
dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQry),'TMP2A',.T.,.F.)
DbSelectArea("TMP2A")
TMP2A->(dbgotop())
_nTotPed:=TMP2A->TOT
TMP2A->(DbCloseArea())
Return(_nTotPed)   

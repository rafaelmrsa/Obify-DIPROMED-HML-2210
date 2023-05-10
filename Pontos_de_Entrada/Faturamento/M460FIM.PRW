#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "AP5MAIL.CH"
#INCLUDE "COLORS.CH"
#DEFINE CR    chr(13)+chr(10)
/*
PONTO.......: M460FIM           PROGRAMA....: MATA460
DESCRIÇÄO...: APOS A GRAVACAO DA NF.
UTILIZAÇÄO..: Este P.E. e' chamado apos a Gravacao da NF de Saida, e fora da transaçäo.
PARAMETROS..: Nenhum.
RETORNO.....: Nenhum.
OBSERVAÇÖES.: <NENHUM>
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³ M460FIM  º Autor ³   Alexandro Dias   º Data ³  24/08/01   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Atualiza Call Center com informacoes da Nota Fiscal quando º±±
±±º          ³ a mesma e gerada!                                          º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function M460FIM()
Local _xAlias   := GetArea()
Local _xAliasSD2 := SD2->(GetArea())
Local _xAliasSUA := SUA->(GetArea())
Local _xAliasSC5 := SC5->(GetArea())
Local _xAliasSE1 := SE1->(GetArea())
Local _xAliasSF2 := SF2->(GetArea())

Local aEnv_Tes     := {}
Local aEnv_STD     := {}
Local aAttach      := {}
Local cNum_Tes     := ""

Local cSuframa     := ""
Local cDescIcm     := ""
Local cAssunto     := ""
Local cEmail       := ""
Local cFrom        := ""
Local cNomeCliente := ""
Local aMsgSuf      := {}      
Local lEnvMailCF   := .F.

//Rafael Moraes Rosa - 13/01/2023 - Variaveis
Local cNome			:= ""
Local cEnd			:= ""
Local cBairro		:= ""
Local cCEP			:= ""
Local cCidad		:= ""
Local cEst			:= ""
Local cCGC			:= ""
Local cIE			:= ""
Local cTel			:= ""

U_DIPPROC(ProcName(0),U_DipUsr()) // JBS 05/10/2005 - Gravando o nome do Programa no SZU

Private cPorta     := Left(Upper(AllTrim(GETMV("MV_LPT_ETQ"))),4) // JBS 21/10/2005
Private cCaminho   := Upper(AllTrim(GETMV("MV_LPT_ETQ")))
Private cTLP2844   := AllTrim(GETMV("MV_TLP2844"))
Private nVolInit   := 1
Private lVolParcial:= .F.
//giovani icms 16/06/11
Private nLen          := 0
Private _cQry0        := " "
Private cNomecli      := " "
private cEmailIc      := " "
private cAssuntoIc    := " "
private cAttachIc     := "a"
private cDeIc         := " "
private cFuncSentIc   := " "
Private cChave        := " "
Private cMsgDecr      := " "
Private cNomeDes      := " "
Private  _aMsgNot     := { }
Private nValicm       := 0
Private cValEmai      := " "
Private cMSGcIC       := " "
Private cTitAl        := "ATENÇÃO NOTA FISCAL NÃO DEVE SAIR SEM A GUIA DE RECOLHIMENTO DE IMPOSTO" 
Private _cMailSU7	  := ""
Private _cNomeSU7 	  := ""  
Private _cNRedSU7	  := ""
Private _cMailSA1	  := ""
Private _cNomeSA1 	  := ""
Private _cNRedSA1 	  := ""   
Private _cSufrSA1	  := ""
Private _cBanco       :=""


If "MATA310"$Upper(FunName()) 
	GravaZZU(SF2->F2_DOC,SF2->F2_SERIE)
	Return .T.
EndIf
   
//*******************************************
If cEmpAnt = "04"  .And. !("TMSA200" $ FUNNAME()) .And.  SF2->F2_EST <> "SP"
	CICMAILTES()
EndIf

If !("TMSA200" $ FUNNAME())	.and. ( !Alltrim(FUNNAME()) == "TMSAE75" ) 
	SU7->(dbSetOrder(1))
	If SU7->(dbSeek(xFilial("SU7")+SC5->C5_OPERADO))
		_cMailSU7 := Lower(AllTrim(SU7->U7_EMAIL))
		_cNomeSU7 := AllTrim(SU7->U7_NOME)
		_cNRedSU7 := AllTrim(SU7->U7_NREDUZ)
	EndIF                                               
	
	SA1->(dbSetOrder(1))
	If SA1->(dbSeek(xFilial("SA1")+SC5->(C5_CLIENTE+C5_LOJACLI)))
		_cMailSA1 := Lower(AllTrim(SA1->A1_EMAIL))
		_cNomeSA1 := AllTrim(SA1->A1_NOME)
		_cNRedSA1 := AllTrim(SA1->A1_NREDUZ)
		_cSufrSA1 := AllTrim(SA1->A1_SUFRAMA)
	EndIf

	
	a_AreaSC9 := SC9->(GetArea())
	// Soma peso bruto, liquido, volume e total do pedido.
	_nPesoBr   := 0
	_nVlrTotal := 0
	_nQtItens  := 0
	Do While !SC9->(Eof()) .and. xFilial("SC9") == SC9->C9_FILIAL .And. SC9->C9_PEDIDO == SC5->C5_NUM

		If !("TMSA200" $ FUNNAME()) // Não entra se a rotina for chamada pelo TMS  - MCVN 01/12/2008
			If IsMark("C9_OK",ThisMark(),ThisInv()) 
				IF Empty(SC9->C9_BLEST) .and. Empty(SC9->C9_BLCRED) .and. Empty(U_C5PARCIAL())
					IF SB1->(DbSeek(xFilial("SB1")+SC9->C9_PRODUTO))
						_nPesoBr  +=(SC9->C9_QTDLIB * SB1->B1_PESO)
						_nVlrTotal+= NoRound((SC9->C9_QTDLIB * SC9->C9_PRCVEN),2)
						_nQtItens ++
					EndIF
				EndIF
			Endif
		Endif
		SC9->(DbSkip())
	EndDo 

	SC9->(DbSetOrder(1))
	If SC9->(DbSeek(xFilial("SC9")+SC5->C5_NUM)) //-- Reposiciona Tabela SC9
		U_TelSepar(.T.,_nVlrTotal)
	EndIf
	RestArea(a_AreaSC9)
	
EndIf 
//giovani icms inter estadual envia e-mail 15/06/2011
If !("DIPAL10" $ FunName())  .And. SE1->E1_PEDIDO = SC5->C5_NUM  .And. !("TMSA200" $ FUNNAME()) .and. ( !Alltrim(FUNNAME()) == "TMSAE75" )

	If substr(SC5->C5_XRECOLH,1,3) $ "ACR/GUI"  .And. SF2->F2_BASEICM > 0
				
		cAssuntoIc    :=  'CONFIRMACAO - NF NAO PODE SAIR SEM GUIA PAGA DE ICMS INTERESTADUAL - PV-' + SC5->C5_NUM + " - NF-" + SF2->F2_DOC + ' ' + SF2->F2_SERIE
		cAttachIc     :=  "  a"
		cDeIc         :=  _cMailSU7
		cFuncSentIc   :=  " M460FIM.prw"
		cEmailIc      :=  GetMv("ES_DIPV4_6") +";"+cDeIc
		
		nValicm:= round(((SF2->F2_BASEICM/100)*10),2)
		
		nLen:=len(cvaltochar(nValicm))
		cValEmai := cvaltochar(nValicm)
		
		If substr(cValEmai,(nLen - 1),1) = "."
			cValEmai := substr(cValEmai,1,(nLen - 2)) +","+substr(cValEmai,(nLen ),1)+"0"
		ElseIf substr(cValEmai,(nLen - 2),1) = "."
			cValEmai := substr(cValEmai,1,(nLen - 3)) +","+substr(cValEmai,(nLen - 1),2)
		Else
			cValEmai := cValEmai+",00"
		EndIf
		aAdd( _aMsgNot , { " EMPRESA"          , + Capital( AllTrim( GetAdvFVal( "SM0", "M0_NOMECOM", cEmpAnt + cFilAnt, 1, "" ) ) )  } )
		aAdd( _aMsgNot , { " FILIAL"           , + Capital( AllTrim( GetAdvFVal( "SM0", "M0_FILIAL" , cEmpAnt + cFilAnt, 1, "" ) ) ) } )
		aAdd( _aMsgNot , { " CLIENTE "         , ""+AllTrim(SA1->A1_COD)+" - "+AllTrim(SA1->A1_NREDUZ)+""  } )
		
		aAdd( _aMsgNot , { " MUNICIPIO-ESTADO ", ""+AllTrim(SA1->A1_MUN)+" - "+AllTrim(SA1->A1_EST)+""  } )
		aAdd( _aMsgNot , { " ENDEREÇO-BAIRRO"  , ""+AllTrim(SA1->A1_END)+" - "+AllTrim(SA1->A1_BAIRRO)+""  } )
		aAdd( _aMsgNot , { " CEP "             , ""+Transform(AllTrim(SA1->A1_CEP) ,"@R 99999-999")+""  } )
		aAdd( _aMsgNot , { " CGC-I.E."         , ""+Transform(AllTrim(SA1->A1_CGC) ,"@R 99.999.999/9999-99 ")+" - "+AllTrim(SA1->A1_INSCR)+""  } )
		aAdd( _aMsgNot , { " E-Mail"           , ""+_cMailSA1 } )//GIOVANI 19/07/11
		
		aAdd( _aMsgNot , { " SERIE "           , SF2->F2_SERIE  } )
		aAdd( _aMsgNot , { " NOTA "            , SF2->F2_DOC } )
		aAdd( _aMsgNot , { " PEDIDO "          , SC5->C5_NUM } )
		aAdd( _aMsgNot , { " OPERADOR"         , ""+SC5->C5_OPERADO+"-"+_cNomeSU7 })
		aAdd( _aMsgNot , { " VENDEDOR"         , ""+SC5->C5_VEND1+"-"+Posicione("SA3",1,xFilial("SA3")+SC5->C5_VEND1,"A3_NOME") })
		aAdd( _aMsgNot , { " TRANSPORTADORA"   , ""+SC5->C5_TRANSP+" - " + AllTrim(FDesc("SA4",SC5->C5_TRANSP,"SA4->A4_NREDUZ"))+" "  } )
		
		If  substr(SC5->C5_XRECOLH,1,3) $ "ACR"
			aAdd( _aMsgNot , { "OPÇÃO"        , "1- Acrescimo no Valor do Pedido."  } )
		ELSE
			aAdd( _aMsgNot , { "OPÇÃO"        , "Cliente recolhe os 10% do valor da Nota Fiscal e envia comprovante para Dipromed(Dep. Fiscal)" } )
			
		EndIf
		aAdd( _aMsgNot , { " BASE de ICMS "      , "R$: "+cvaltochar(SF2->F2_BASEICM) } )
		aAdd( _aMsgNot , { " VALOR a RECOLHER "      , "R$: "+cValEmai+"  "  } )
		
		u_UEnvMail(cEmailIc,cAssuntoIc,_aMsgNot,cAttachIc,cDeIc,cFuncSentIc)
		
		//manda cic do pedido
		
		cMSGcIC       := "CONFIRMACAO - NF NAO PODE SAIR SEM GUIA PAGA DE ICMS INTERESTADUAL - PV- " + SC5->C5_NUM + " - NF-" + SF2->F2_DOC + ' ' + SF2->F2_SERIE +CR +CR
		//................1 2 3 4 5 6 7 8 9 0
		cMSGcIC       += " EMPRESA:_______" + Capital( AllTrim( GetAdvFVal( "SM0", "M0_NOME", cEmpAnt + cFilAnt, 1, "" ) ) ) +"/"+ Capital( AllTrim( GetAdvFVal( "SM0", "M0_FILIAL" , cEmpAnt + cFilAnt, 1, "" ) ) )   + CR 
		cMSGcIC       += _aMsgNot[3][1]+":_______" +_aMsgNot[3][2] +CR
		//................1 2 3 4 5 6 7 8 9 0
		cMSGcIC       += _aMsgNot[9][1]+":_______" +_aMsgNot[9][2] +CR
		//................1 2 3 4 5 6 7 8 9 0
		cMSGcIC       += _aMsgNot[10][1]+":_______" +_aMsgNot[10][2] +CR
		//................1 2 3 4 5 6 7 8 9 0
		cMSGcIC       += _aMsgNot[11][1]+":________" +_aMsgNot[11][2] +CR
		//................1 2 3 4 5 6 7 8 9 0
		cMSGcIC       += _aMsgNot[12][1]+":_________" +_aMsgNot[12][2] +CR+CR
		//................1 2 3 4 5 6 7 8 9 0
		
		//cMSGcIC       += "AVISO: NOTA FISCAL NÂO DEVERA SAIR SEM GUIA DE RECOLHIMENTO " +CR
	
		//manda CIC
		U_DIPCIC(cMSGcIC,GetMV("ES_DIPV4_7"))
		
	EndIf
EndIf
//************************************************************************************************************

If Len(Alltrim(cCaminho))>4
	If !("TMSA200" $ FUNNAME()) .and. ( !Alltrim(FUNNAME()) == "TMSAE75" )  .And. !("DIPA012" $ FUNNAME())  .AND. !Type("lDIPA039") <> "U"
		WaitRun("NET USE "+cPorta+" /DELETE YES")  // JBS 18/10/2005
		WaitRun("NET USE "+cCaminho)  // MCVN 20/01/2006
	Endif
Endif

If ( !Alltrim(FUNNAME()) == "TMSA200" ) .and. ( !Alltrim(FUNNAME()) == "TMSAE75" ) // Não entra se a rotina for chamada pelo TMS  - MCVN 01/12/2008
	DbSelectArea("SD2")
	DbSetOrder(3)
	DbSeek(xFilial("SD2")+SF2->F2_DOC+SF2->F2_SERIE)
	
	//-- Posiciona Pedido do mesmo modo que estava no SF2460i
	SC5->(DbSetOrder(1))
	SC5->(DbSeek(xFilial("SC5")+If(Type("lDIPA039") <> "U",SD2->D2_PEDIDO,SC9->C9_PEDIDO)))
	
	SF4->(dbSetOrder(1))
	If SF4->(dbSeek(xFilial("SF4")+SD2->D2_TES))
		_cTextSF4 := SF4->F4_TEXTO
		_cDuplSF4 := SF4->F4_DUPLIC
		_cEstoSF4 := SF4->F4_ESTOQUE
	EndIf
	
	While SD2->(!Eof()) .AND. xFilial("SD2") == SD2->D2_FILIAL .AND. SD2->D2_DOC == SF2->F2_DOC .AND. SD2->D2_SERIE == SF2->F2_SERIE
		
		If SD2->D2_TES$GetNewPar("ES_TICMSCF","752")
			lEnvMailCF := .T.
		EndIf
		
		// BLOCO DE VALIDAÇÃO DA TES PARA ENVIO DE E-MAIL
		If AllTrim(SD2->D2_TES) != '501' .and. AllTrim(SD2->D2_TES) != '533'
			If !(AllTrim(SD2->D2_TES) $ cNum_Tes) // Verifica se já existe a TES no array
				Aadd(aEnv_Tes,{SD2->D2_TES,_cTextSF4,_cDuplSF4,_cEstoSF4, SC5->C5_EXPLSEN, SC5->C5_OPERADO+'-'+_cNRedSU7, SF2->F2_DOC, DtoC(SF2->F2_EMISSAO),SF2->F2_CLIENTE+'-'+SF2->F2_LOJA+'-'+_cNomeSA1})
				cNum_Tes	+= " " + AllTrim(SD2->D2_TES)
			EndIf
		EndIf
		
		//Rafael Moraes Rosa - 13/01/2023 - Inicio
		cNome	:= posicione("SA1",1,xFilial("SA1")+SF2->F2_CLIENTE+SF2->F2_LOJA,"A1_NOME")
		cEnd	:= posicione("SA1",1,xFilial("SA1")+SF2->F2_CLIENTE+SF2->F2_LOJA,"A1_END")
		cBairro	:= posicione("SA1",1,xFilial("SA1")+SF2->F2_CLIENTE+SF2->F2_LOJA,"A1_BAIRRO")
		cCEP	:= posicione("SA1",1,xFilial("SA1")+SF2->F2_CLIENTE+SF2->F2_LOJA,"A1_CEP")
		cCidad	:= posicione("SA1",1,xFilial("SA1")+SF2->F2_CLIENTE+SF2->F2_LOJA,"A1_MUN")
		cEst	:= posicione("SA1",1,xFilial("SA1")+SF2->F2_CLIENTE+SF2->F2_LOJA,"A1_EST")
		cCGC	:= posicione("SA1",1,xFilial("SA1")+SF2->F2_CLIENTE+SF2->F2_LOJA,"A1_CGC")
		cIE		:= posicione("SA1",1,xFilial("SA1")+SF2->F2_CLIENTE+SF2->F2_LOJA,"A1_INSCR")
		cTel	:= posicione("SA1",1,xFilial("SA1")+SF2->F2_CLIENTE+SF2->F2_LOJA,"A1_TEL")
		//Rafael Moraes Rosa - 13/01/2023 - Fim


		/// MONTAGEM DO ARRAY DE ENVIO DE E-MAIL PARA SUBSTITUIÇÃO TRIBUTÁRIA
		If SubStr(SC5->C5_MENNOTA,AT('=',SC5->C5_MENNOTA),5) == "=ST=D"  .AND. Val(Left(SC5->C5_MENNOTA,4)) > 0 /// VERIFICA SE SUBST. TRIBUTÁRIA ESTÁ INCLUSO NO VALOR DA DESPESA. TRATANDO ST COM VALOR 0 - MCVN 12/11/09.
			//Aadd(aEnv_STD,{SF2->F2_CLIENTE, SF2->F2_LOJA, SA1->A1_NOME, SA1->A1_END, SA1->A1_BAIRRO, SA1->A1_CEP, SA1->A1_MUN, SA1->A1_EST, SA1->A1_CGC, SA1->A1_INSCR, SC5->C5_NUM, SD2->D2_COD,Posicione("SB1",1,xFilial("SB1")+SD2->D2_COD,"B1_DESC"), SF2->F2_DESPESA, SD2->D2_TOTAL, Val(SubStr(SC5->C5_MENNOTA,1,AT('=',SC5->C5_MENNOTA)-1)), SF2->F2_FRETE, SF2->F2_VALFAT, _cMailSU7, SF2->F2_DOC, SA1->A1_TEL,SC5->C5_OPERADO, SF2->F2_TRANSP, Posicione("SA4",1,xFilial("SA4")+SF2->F2_TRANSP,"A4_NOME")}) //Rafael Moraes Rosa - 13/01/2023 - LINHA COMENTADA
			//             1                2             3             4            5               6            7            8            9            10             11           12          13                                                       14               15             16                                                        17             18              19         20           21          22  				23				24
			Aadd(aEnv_STD,{SF2->F2_CLIENTE, SF2->F2_LOJA, cNome, cEnd, cBairro, cCEP, cCidad, cEst, cCGC, cIE, SC5->C5_NUM, SD2->D2_COD,Posicione("SB1",1,xFilial("SB1")+SD2->D2_COD,"B1_DESC"), SF2->F2_DESPESA, SD2->D2_TOTAL, Val(SubStr(SC5->C5_MENNOTA,1,AT('=',SC5->C5_MENNOTA)-1)), SF2->F2_FRETE, SF2->F2_VALFAT, _cMailSU7, SF2->F2_DOC, cTel,SC5->C5_OPERADO, SF2->F2_TRANSP, Posicione("SA4",1,xFilial("SA4")+SF2->F2_TRANSP,"A4_NOME")}) //Rafael Moraes Rosa - 13/01/2023 - LINHA SUBSTITUIDA
		EndIf
		
		SD2->(DbSkip())
	End
	
	// VAMOS FAZER AS ETIQUES DAS EMBALAGENS
	If SF2->F2_TIPO == 'N' .and. SF2->F2_VOLUME1 > 0  .And. !("DIPA012" $ FUNNAME()) .AND. !Type("lDIPA039") <> "U"
		aEtiq := {}
		
		IF !(SF2->F2_TRANSP $ cTLP2844) //.AND. SF2->F2_TPFRETE <> 'F'  // Etiqueta dentro do parâmetro MV_TLP2844 SERÁ impressa na impressora térmica - MCVN 26/03/08
			
			If SF2->F2_TRANSP <> '000001' .and. SF2->F2_TRANSP <> '000111' .and. SF2->F2_TRANSP <> '000133' .And. SF2->F2_TRANSP <> '000851'// NOSSO CARRO e CLIENTE RETIRA
				//	MONTAGEM DO ARRAY COM A ETIQUETA
				//cEtiq001 := If(("HEALTH" $ SM0->M0_NOMECOM),"HEALTH QUALITY INDUSTRIA E COMERCIO LTDA-ME"+space(14),"DIPROMED COMERCIO E IMPORTACAO LTDA"+space(20))+If(SF2->F2_TRANSP = "000113",u_rotacep(Left(SC5->C5_CEPE,5),SF2->F2_TRANSP,AllTrim(SC5->C5_MUNE)),"")
				cEtiq001 := If(cEmpAnt=="04","HEALTH QUALITY INDUSTRIA E COMERCIO LTDA-ME"+space(14),"DIPROMED COMERCIO E IMPORTACAO LTDA"+space(20))+If(SF2->F2_TRANSP = "000113",u_rotacep(Left(SC5->C5_CEPE,5),SF2->F2_TRANSP,AllTrim(SC5->C5_MUNE)),"")
				cEtiq002 := REPLICATE("=",36)
				cEtiq003 := "Destino: " + AllTrim(SA1->A1_NOME)
				cEtiq004 := "Endereco: " + IIF(AllTrim(SC5->C5_ENDENT) = "O MESMO",Subs(SA1->A1_END,1,48),Subs(SC5->C5_ENDENT,1,48))
				cEtiq005 := "Cidade: " + IIF(AllTrim(SC5->C5_ENDENT) = "O MESMO",AllTrim(SA1->A1_MUN)+" / "+SA1->A1_EST+' - CEP:  '+SA1->A1_CEP,AllTrim(SC5->C5_MUNE)+" / "+SC5->C5_ESTE)+' - CEP:  '+SC5->C5_CEPE
				cEtiq006 := "Transportadora: " + AllTrim(FDesc("SA4",SF2->F2_TRANSP,"SA4->A4_NOME"))
				cEtiq007 := "    Especie: " + AllTrim(SF2->F2_ESPECI1)
				cEtiq008 := "Nota Fiscal/Serie: " + SF2->F2_DOC + "/" + SF2->F2_SERIE + "Pre-Nota: " + SC5->C5_NUM + "       " + SF2->F2_LOCEXP + "  " + SF2->F2_CONFERI //MCVN - 17/01/2007
				cEtiq009 := SF2->F2_VOLUME1
				Aadd(aEtiq,{cEtiq001, cEtiq002, cEtiq003, cEtiq004, cEtiq005, cEtiq006, cEtiq007, cEtiq008, cEtiq009})
			Else
				//Aadd(aEtiq,U_BigNumber(If(("HEALTH" $ SM0->M0_NOMECOM),SF2->F2_DOC,SC5->C5_NUM),.t.))
				Aadd(aEtiq,U_BigNumber(If(cEmpAnt+cFilAnt=="0401",SF2->F2_DOC,SC5->C5_NUM),.t.))
			EndIf
			Set Device To Print
			Set Printer to &cPorta
			PrinterWin(.F.) // IMPRESSAO DOS/WINDOWS
			PreparePrint(.F., "", .F., cPorta) // PREPARA A IMPRESSAO NA PORTA ESPECIFICADA
			#IFDEF WINDOWS
				initprint(1)
			#ENDIF
			
			u_EtiqImp(aEtiq,nVolInit:= 1,lVolParcial := .F.)
			
			SetPgEject(.F.) // JBS 03/01/2005
			MS_FLUSH()
			
			Set device to Screen
			
			// VAMOS IMPRIMIR ETIQUETAS DE CODIGO DE BARRA DA BRASPRESS
		Else
			
			cPorta  := Left(Upper(AllTrim(GETMV("MV_LPT_BAR"))),4)
			cCaminho:= Upper(AllTrim(GETMV("MV_LPT_BAR")))
			
			If Len(Alltrim(cCaminho))>4
				
				// Imprime normalmente as etiquetas de código de barras
				WaitRun("NET USE "+cPorta+" /DELETE YES")
				WaitRun("NET USE "+cCaminho)
				
			Endif
			
			MV_PAR01 := SF2->F2_SERIE
			MV_PAR02 := PADR(SF2->F2_DOC,9)
			MV_PAR03 := PADR(SF2->F2_DOC,9)
			u_GeraEtq(nVolInit:= 1,lVolParcial := .F.)
		EndIf
	EndIf
	
	//-- Chama a Impressao do Boleto
	//        O parâmetro com o Banco/Agencia/Conta deve estar preenchido  -  MCVN - 14/12/2007
	//        Limita inicialmente a impressão do boleto para as cidades de São Paulo e Campinas  -  MCVN - 14/12/2007
	//If ((SA1->A1_BLTAUTO == "1" .And. Empty(SA1->A1_PORTADO))  .Or. (SA1->A1_BOLETHQ == "1" .And. ("HEALTH" $ SM0->M0_NOMECOM))) .And. !("DIPA012" $ FUNNAME()) .AND. !Type("lDIPA039") <> "U"
	// Foi incluido a possibilidade de imprimir boleto se a condição de pagamento for 354, 504, 052 ou 051 - MCVN 24/02/11
	If !(SF2->F2_COND$'001/002')
		If ((SA1->A1_BLTAUTO == "1" .And. Empty(SA1->A1_PORTADO))  .Or. (SA1->A1_BOLETHQ == "1" .And. (cEmpAnt=="04")) .Or. (SF2->F2_COND $ ('354/052/051/504/661'))) .And. ;
			!("DIPA012" $ FUNNAME()) .AND. !Type("lDIPA039") <> "U" .And. !(SF2->F2_TIPO $ 'D/B')//Geração automática de Nota Fiscal
			
			If !Empty(SF2->F2_DUPL)	
				U_DIPM023(.T.,@_cBanco) // Gera Boleto
				ValImpBol(SF2->F2_DUPL,SF2->F2_PREFIXO)	   // Valida Impressão do Boleto 05/07/2013 
			Endif
			
		Endif
	EndIf	
	// ENVIA EMAIL SE CLIENTE TIVER SUFRAMA (PIN-PROTOCOLO DE INTERNAÇÃO DE NOTA FISCAL)  18/01/2008
	cSuframa := _cSufrSA1
	If  !Empty(cSuframa)
		cDescIcm     := SA1->A1_CALCSUF
		cNomeCliente := SA1->A1_NOME
		cFrom    := _cMailSU7
		
		Aadd( aMsgSuf , { "Cliente: "             , SC5->C5_CLIENTE + " - " + cNomeCliente} )
		Aadd( aMsgSuf , { "Numero da Nota: "      , SF2->F2_DOC } )
		Aadd( aMsgSuf , { "Série da Nota: "       , SF2->F2_SERIE } )
		Aadd( aMsgSuf , { "Numero Pedido: "       , SC5->C5_NUM } )
		Aadd( aMsgSuf , { "Operador: "            , SC5->C5_OPERADO +" - "+ _cNomeSU7 } )
		Aadd( aMsgSuf , { "Transportadora: "      , SC5->C5_TRANSP + " - " + Alltrim(Posicione("SA4",1,xFilial("SA4")+SC5->C5_TRANSP,"A4_NOME" )) } )
		Aadd( aMsgSuf , { "Destino do Pedido:  "  , SC5->C5_ESTE +" - "+ SC5->C5_MUNE } )
		Aadd( aMsgSuf , { "Código Suframa: "      , cSuframa } )
		If cDescIcm == "S"
			Aadd( aMsgSuf , { "Desconto Icms e PIS/COFINS:  "  , "SIM" } )
		ElseIf	cDescIcm == "I"
			Aadd( aMsgSuf , { "Desconto Icms:  "               , "SIM" } )
		Endif
		
		If Len(aMsgSuf) > 0
			cEmail   := GetNewPar("ES_MAILSUF","magda.teixeira@dipromed.com.br;sirlene.creatto@dipromed.com.br;deoclecio.santos@dipromed.com.br")
			cAssunto := 'CONFIRMACAO - Nota Fiscal com SUFRAMA - PV-' + SC5->C5_NUM + ' - NF-' + SF2->F2_DOC + ' ' + SF2->F2_SERIE
			U_UEnvMail(cEmail,cAssunto,aMsgSuf,"",cFrom,cFuncSentIc)
		Endif
	EndIf
	
	If SF2->F2_TIPO $ 'DB' .And. !('DIPA012'$Upper(FunName()))
		U_NfSEmail(1)
	Endif
	
	// BLOCO DE VERIFICAÇÃO DA TES E ENVIO DE E-MAIL
	If Len(aEnv_Tes) > 0
		cEmail := 'erich.pontoldio@dipromed.com.br'
		cAssunto := 'AVISO DE NOTA FISCAL - No.' + SF2->F2_DOC + '- Série ' + SF2->F2_SERIE
		Env_Tes(cEmail,cAssunto,aEnv_Tes,aAttach)
	EndIf
	
	If SF2->F2_TIPO=="N" .And. lEnvMailCF  .And. !SF2->F2_EST$GetNewPar("ES_ESTNGCF","BA/MG")
		u_DipICMSNF(SF2->F2_DOC,SF2->F2_SERIE,SF2->F2_CLIENTE,SF2->F2_LOJA,SF2->F2_TRANSP,SC5->C5_NUM,SF2->F2_EST)
	EndIf
	
	If Len(aEnv_STD) > 0 .And. !(SF2->F2_EST$GetNewPar("ES_ESTNGST","BA"))
		cEmail := GetNewPar("ES_DIP_STN","reginaldo.borges@dipromed.com.br")//"magda.teixeira@dipromed.com.br;william.pereira@dipromed.com.br;sirlene.creatto@dipromed.com.br;qualidade@dipromed.com.br"
		cAssunto := "CONFIRMACAO ? NF NAO PODE SAIR SEM GUIA PAGA DE ST INCLUSO - PV-" + SC5->C5_NUM + " - NF-" + SF2->F2_DOC + ' ' + SF2->F2_SERIE

		U_AVCicST()
		ENV_STD(cEmail,cAssunto,aEnv_STD)
	Endif
	
	U_DiprKardex(SC5->C5_NUM,U_DipUsr(),"NF OK - M460FIM",.T.,"50")
EndIf
    
/*-------------------------------------------------------------------------
+ RBORGES - 29/07/2013 ----- Static Funcion: AVCicNFA().                  +                                                     
+ Fará a validação  para o envio de e-mail e cic para as notas fiscais    +
+ geradas para o novo armazem, de acordo os parâmtros da validação.       +
-------------------------------------------------------------------------*/

If SF2->F2_CLIENTE $ GetNewPar("ES_ARM_CLI","019181").AND.; 
   SC5->C5_OPERADO $ GetNewPar("ES_ARM_OPE","000189").AND.;
   SC6->C6_TES     $ GetNewPar("ES_ARM_TES","904")
                                        	
   		cEmail := GetNewPar("ES_EMA_ARM","reginaldo.borges@dipromed.com.br")
		cAssunto := 'AVISO - REMESSA PARA ARMAZÉM NOTA FISCAL - No.' + SF2->F2_DOC + '- Série ' + SF2->F2_SERIE
		
		Env_Tes(cEmail,cAssunto,aEnv_Tes,aAttach)
		AVCicNFA()
		
EndIf	


/*
+-----------------------------------------------------------------------+
|FUNCAO: VERNCC() | Autor:  Reginaldo Borges   |    Data:   30/11/2018 |                                                     
+-----------------------------------------------------------------------+
|Verificar se há NCC para o cliente e disparar um e-mail para o         |
|financeiro, contas a receber.                                          | 
+-----------------------------------------------------------------------+
*/

VERNCC(SF2->F2_CLIENTE,SF2->F2_LOJA)


RestArea(_xAliasSF2)
RestArea(_xAliasSE1)
RestArea(_xAliasSC5)
RestArea(_xAliasSUA)
RestArea(_xAliasSD2)
RestArea(_xAlias)

If ( !Alltrim(FUNNAME()) == "TMSA200" ) .and. ( !Alltrim(FUNNAME()) == "TMSAE75" ) 
	CloseBrowse()      
EndIf
Return


/*============================================================================\
|Programa  | Env_Tes  | Autor | Rafael de Campos Falco  | Data | 29/27/2004   |
|=============================================================================|
|Desc.     | Envio de EMail relatando as TES utilizada                        |
|=============================================================================|
|Sintaxe   | Env_Tes                                                          |
|=============================================================================|
|Uso       | Especifico DIPROMED                                              |
\============================================================================*/

Static Function Env_Tes(cEmail,cAssunto,aMsg,aAttach)

Local cAccount  := Lower(Alltrim(GetMv("MV_RELACNT")))
Local cFrom     := Lower(Alltrim(GetMv("MV_RELACNT")))
Local cPassword := Alltrim(GetMv("MV_RELPSW"))
Local cServer   := Alltrim(GetMv("MV_RELSERV"))
Local cEmailTo  := ""
Local cEmailCc  := ""
Local cEmailBcc := ""
Local cError    := ""
Local cMsg      := ""
Local lResult   := .F.
Local xi		:= 0       
LOCAL lSmtpAuth := GetNewPar("MV_RELAUTH",.F.)
LOCAL lAutOk	:= .F.

/*==============================================================================\
| Definicao do cabecalho do email                                               |
\==============================================================================*/
cMsg := '<html>'
cMsg += '<head>'
cMsg += '<title>' +cAssunto+" - "+SM0->M0_NOME+"/"+SM0->M0_FILIAL+ '</title>'
cMsg += '</head>'
cMsg += '<body>'
cMsg += '<HR Width=85% Size=3 Align=Centered Color=Red> <P>'
cMsg += '<Table Align=Center BorderColor=#000000 CELLPADDING=4 CELLSPACING=0 Width=60%>'

/*=============================================================================*/
/*Definicao do cabecalho do relatório                                          */
/*=============================================================================*/

cMsg += '<table width="100%" border="1">'
cMsg += '<tr align="center">'
cMsg += '<td width="100%" colspan="10"><font color="blue" size="4">'+cAssunto+" - "+SM0->M0_NOME+"/"+SM0->M0_FILIAL+'</font></td>'
cMsg += '</tr>'
cMsg += '<tr align="center">'
cMsg += '<td width="10%"><font color="red" size="2">Documento</td>'
cMsg += '<td width="10%"><font color="red" size="2">Emissão</td>'
cMsg += '<td width="80%" colspan="10" align="left"><font color="red" size="2">Cliente</td>'
cMsg += '</font>'
cMsg += '</tr>'
cMsg += '<tr align="center">'
cMsg += '<td width="10%"><font color="red" size="2">TES</td>'
cMsg += '<td width="10%"><font color="red" size="2">Texto</td>'
cMsg += '<td width="10%"><font color="red" size="2">Duplicata</td>'
cMsg += '<td width="10%"><font color="red" size="2">Estoque</td>'
cMsg += '<td width="80%" colspan="10" align="left"><font color="red" size="2">Operador</td>'
cMsg += '</font>'
cMsg += '</tr>'
cMsg += '<tr align="center">'
cMsg += '<td width="100%" colspan="10" align="left"><font color="red" size="2">Explicação</td>'
cMsg += '</font>'
cMsg += '</tr>'
For xi:=1 to Len(aMsg)
	cMsg += '<tr align="center">'
	cMsg += '<td width="10%"><font color="blue" size="2">'+ aMsg[xi,7]+'</td>'
	cMsg += '<td width="10%"><font color="blue" size="2">'+ aMsg[xi,8]+'</td>'
	cMsg += '<td width="80%" colspan="10" align="left"><font color="blue" size="2">'+ aMsg[xi,9]+'</td>'
	cMsg += '</font>'
	cMsg += '</tr>'
	cMsg += '<tr align="center">'
	cMsg += '<td width="10%"><font color="blue" size="2">'+ aMsg[xi,1]+'</td>'
	cMsg += '<td width="10%"><font color="blue" size="2">'+ aMsg[xi,2]+'</td>'
	cMsg += '<td width="10%"><font color="blue" size="2">'+ aMsg[xi,3]+'</td>'
	cMsg += '<td width="10%"><font color="blue" size="2">'+ aMsg[xi,4]+'</td>'
	cMsg += '<td width="80%" colspan="10" align="left"><font color="blue" size="2">'+ aMsg[xi,6]+'</td>'
	cMsg += '</font>'
	cMsg += '</tr>'
	cMsg += '<tr align="center">'
	cMsg += '<td width="100%" colspan="10" align="left"><font color="blue" size="2">'+ aMsg[xi,5]+'</td>'
	cMsg += '</font>'
	cMsg += '</tr>'
Next
cMsg += '<tr align="center">'
cMsg += '<td colspan="10"><font color="red" size="3">Mensagem enviada automaticamente pelo sistema PROTHEUS - <font color="red" size="1">(SF2460I.PRW)</td>'
cMsg += '</tr>'

/*==============================================================================\
| Definicao do rodape do email                                                  |
\==============================================================================*/
cMsg += '</table>'
cMsg += '<HR Width=85% Size=3 Align=Centered Color=Red> <P>'
cMsg += '</body>'
cMsg += '</html>'

/*==============================================================================\
| Envia o mail para a lista selecionada. Envia como BCC para que a pessoa pense |
| que somente ela recebeu aquele email, tornando o email mais personalizado.    |
\==============================================================================*/
                       
If GetNewPar("ES_ATIVJOB",.T.)   
	u_UEnvMail(cEmail,cAssunto,nil,"",cFrom,"EnvEmailNFS(SF2460I.prw)",cMsg)
Else
	IF At(";",cEmail) > 0
		cEmailTo := SubStr(cEmail,1,At(";",cEmail)-1)
		cEmailCc := SubStr(cEmail,At(";",cEmail)+1,len(alltrim(cEmail)))
	Else
		cEmailTo := Alltrim(cEmail)
	EndIF

	CONNECT SMTP SERVER cServer ACCOUNT cAccount PASSWORD cPassword RESULT lResult
	
	If !lAutOk
		If ( lSmtpAuth )
			lAutOk := MailAuth(cAccount,cPassword)
		Else
			lAutOk := .T.
		EndIf
	EndIf
	
	If lResult .And. lAutOk
		SEND MAIL FROM cFrom ;
		TO      	Lower(cEmailTo);
		CC      	Lower(cEmailCc);
		BCC     	Lower(cEmailBcc);
		SUBJECT 	cAssunto;
		BODY    	cMsg;
		RESULT lResult
		//	ATTACHMENT  aAttach;
		
		If !lResult
			//Erro no envio do email
			GET MAIL ERROR cError
			MsgInfo(cError,OemToAnsi("Atenção"))
		EndIf
		
		DISCONNECT SMTP SERVER
	Else
		//Erro na conexao com o SMTP Server
		GET MAIL ERROR cError
		
		MsgInfo(cError,OemToAnsi("Atenção"))
	EndIf
EndIf

Return(.T.)

/*==========================================================================\
|Programa  | ENV_STD | Autor | Rafael de Campos Falco  | Data ³ 27/01/2005  |
|===========================================================================|
|Desc.     | Envio de EMail da Substituição tributária                      |
|===========================================================================|
|Sintaxe   | ENV_STD                                                        |
|===========================================================================|
|Uso       | Especifico DIPROMED                                            |
\==========================================================================*/

Static Function ENV_STD(cEmail,cAssunto,aEnv_STD,aAttach)

Local cAccount  := Lower(Alltrim(GetMv("MV_RELACNT")))
Local cFrom     := Lower(Alltrim(GetMv("MV_RELACNT")))//Lower(AllTrim(aEnv_STD[1,19]))
Local cPassword := Alltrim(GetMv("MV_RELPSW"))
Local cServer   := Alltrim(GetMv("MV_RELSERV"))
Local cEmailTo  := ""
Local cEmailCc  := ""
Local cEmailBcc := ""
Local lResult   := .F.
Local cError    := ""
Local cMsg      := ""
Local nTot_Prod := 0
Local nLin		:= 0       
LOCAL lSmtpAuth := GetNewPar("MV_RELAUTH",.F.)
LOCAL lAutOk	:= .F.

If !Empty(AllTrim(POSICIONE("SU7",1,XFILIAL("SU7")+AllTrim(aEnv_STD[1,24]),"U7_EMAIL"))) .And. !Empty(AllTrim(POSICIONE("SU7",1,XFILIAL("SU7")+AllTrim(aEnv_STD[1,22]),"U7_SENHA")))
	cAccount  := AllTrim(POSICIONE("SU7",1,XFILIAL("SU7")+AllTrim(aEnv_STD[1,24]),"U7_EMAIL"))
	cFrom     := AllTrim(POSICIONE("SU7",1,XFILIAL("SU7")+AllTrim(aEnv_STD[1,24]),"U7_EMAIL"))
	cPassword := AllTrim(POSICIONE("SU7",1,XFILIAL("SU7")+AllTrim(aEnv_STD[1,24]),"U7_SENHA"))
EndIf	

/*=============================================================================*/
/*Definicao do cabecalho do email                                              */
/*=============================================================================*/
cMsg := ""
cMsg += '<html>'
cMsg += '<head>'
cMsg += '<title>' +cAssunto+" - "+SM0->M0_NOME+"/"+SM0->M0_FILIAL+ '</title>'
cMsg += '</head>'
cMsg += '<body>'
cMsg += '<HR Width=85% Size=3 Align=Centered Color=Red> <P>'
cMsg += '<Table Align=Center BorderColor=#000000 CELLPADDING=4 CELLSPACING=0 Width=60%>'

/*=============================================================================*/
/*Definicao do cabecalho do relatório                                          */
/*=============================================================================*/

cMsg += '<table width="100%">'
cMsg += '<tr>'
cMsg += '<td width="100%"><font size="5">EMPRESA: - ' +SM0->M0_NOME+"/"+SM0->M0_FILIAL+ '</font></td>'
cMsg += '</tr>'
cMsg += '<tr>'
cMsg += '<td width="50%"><font size="4" color="red">Pedido - ' + aEnv_STD[1,11] + '</font></td>'
cMsg += '<td width="50%"><font size="4" color="red">Nota Fiscal - ' + aEnv_STD[1,20] + '</font></td>'
cMsg += '</tr>'

cMsg += '<tr>'
cMsg += '<td width="100%" colspan="2"><font size="2" color="blue">Operador(a): ' + Lower(AllTrim(aEnv_STD[1,19])) + '</font></td>'
cMsg += '</tr>'

cMsg += '<tr>'
cMsg += '<td width="100%" colspan="2"><font size="2" color="blue">Cliente: ' + aEnv_STD[1,1] + '-' + aEnv_STD[1,2] + '-' + aEnv_STD[1,3] + '</font></td>'
cMsg += '</tr>'

cMsg += '<tr>
cMsg += '<td width="100%" colspan="2"><font size="2" color="blue">End.: ' + aEnv_STD[1,4] + ' - Bairro: ' + aEnv_STD[1,5] +'</font></td>'
cMsg += '</tr>

cMsg += '<tr>'
cMsg += '<td width="100%" colspan="2"><font size="2" color="blue">CEP: ' + aEnv_STD[1, 6] +' - Cidade: '+ aEnv_STD[1, 7] +' - Estado: '+ aEnv_STD[1, 8] + '</font></td>'
cMsg += '</tr>
cMsg += '<tr>'
cMsg += '<td width="100%" colspan="2"><font size="2" color="blue">CNPJ: ' + aEnv_STD[1, 9] +' - I.E.: '+ aEnv_STD[1,10] + ' - Fone: '+ aEnv_STD[1,21] + '</font></td>'
cMsg += '</tr>'
//FELIPE DURAN - 16/10/2019
cMsg += '<tr>'
cMsg += '<td width="100%" colspan="2"><font size="2" color="blue">Transp.: ' + aEnv_STD[1, 23] + '-' + aEnv_STD[1,24] +'</font></td>'
cMsg += '</tr>'
//FIM
cMsg += '<tr>'
cMsg += '<td width="100%" colspan="2"><font size="2" color="blue">E-MAIL: ' + _cMailSA1 +'</font></td>' //giovani 19/07/11
cMsg += '</tr>'
cMsg += '</table>'
cMsg += '<table width="100%" cellspacing="0" cellpadding="0"><font size="2" color="blue">'
cMsg += '<tr>'
cMsg += '<td>===============================================================================================================</td>'
cMsg += '</tr>'
cMsg += '</font></table>'
cMsg += '<table width="100%" cellspacing="0" cellpadding="0"><font size="2" color="blue">'
cMsg += '<td width="80%">Código - Descrição</td>'
cMsg += '<td width="20%" align="right">Valor</td>'
cMsg += '</tr>'
cMsg += '</font></table>'
cMsg += '<table width="100%" cellspacing="0" cellpadding="0"><font size="2" color="blue">'
cMsg += '<tr>'
cMsg += '<td>===============================================================================================================</td>'
cMsg += '</tr>'
cMsg += '</font></table>'
/*=============================================================================*/
/*Definicao do texto/detalhe do email                                          */
/*=============================================================================*/
For nLin := 1 to Len(aEnv_STD)
	nTot_Prod += aEnv_STD[nLin,15]
	If Mod(nLin,2) == 0
		cMsg += '<table width="100%" border="0" cellspacing="0" cellpadding="0">'
		cMsg += '<tr BgColor="#B0E2FF">'
		cMsg += '<td width="80%"><font size="2">' + aEnv_STD[nLin,12] + ' - ' + aEnv_STD[nLin,13] + '</font></td>'
		cMsg += '<td width="20%" align="right"><font size="2">' + Transform(aEnv_STD[nLin,15],"@E 999,999,999.99") + '</font></td>'
		cMsg += '</tr>'
		cMsg += '</table>'
	Else
		cMsg += '<table width="100%" border="0" cellspacing="0" cellpadding="0">
		cMsg += '<tr bgcolor="#c0c0c0">
		cMsg += '<td width="80%"><font size="2">' + aEnv_STD[nLin,12] + ' - ' + aEnv_STD[nLin,13] + '</font></td>'
		cMsg += '<td width="20%" align="right"><font size="2">' + Transform(aEnv_STD[nLin,15],"@E 999,999,999.99") + '</font></td>'
		cMsg += '</tr>'
		cMsg += '</table>'
	EndIf
Next
cMsg += '<table width="100%" cellspacing="5" cellpadding="0">'
cMsg += '<tr BgColor=#FFFF80>'
cMsg += '<td width="33%" align="right"><font color="red" size="2">Frete: ' + Transform(aEnv_STD[1,17],"@E 999,999,999.99") + '</font></td>'
/// AJUSTE NO ARREDONDAMENTO DA DESPESA
//	nDif_Val := aEnv_STD[1,14]-aEnv_STD[1,16]
//	If (nDif_Val < 0 .and. nDif_Val > -0.03) .or. (nDif_Val > 0 .and. nDif_Val < 0.03)
//		nVal_Des := aEnv_STD[1,16]
//	Else
nVal_Des := aEnv_STD[1,14]-aEnv_STD[1,16]
//	EndIf	  // Eriberto 09/06/2005 - tirei este if pq acho que ele nao esta servindo pra nada
cMsg += '<td width="33%" align="right"><font color="red" size="2">Despesas: ' + Transform(nVal_Des,"@E 999,999,999.99") + '</font></td>'
cMsg += '<td width="33%" align="right"><font color="red" size="2">Total dos Produtos: ' + Transform(nTot_Prod,"@E 999,999,999.99") + '</font></td>'
cMsg += '</tr>'
cMsg += '<tr BgColor=#FFFF80>'
cMsg += '<td width="33%" align="right"><font color="red" size="2">Substituição Tributária: ' + Transform(aEnv_STD[1,16],"@E 999,999,999.99") + '</font></td>'
cMsg += '<td width="33%" align="right"></td>'
cMsg += '<td width="33%" align="right"><font color="red" size="2">Total do Pedido: ' + Transform(aEnv_STD[1,18],"@E 999,999,999.99") + '</font></td>'
cMsg += '</tr>'
cMsg += '</table>'
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Definicao do rodape do email                                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cMsg += '</Table>'
cMsg += '<HR Width=85% Size=3 Align=Centered Color=Red> <P>'
cMsg += '<table width="100%" Align="Center" border="0">'
cMsg += '<tr align="center">'
cMsg += '<td colspan="10"><font color="BLUE" size="2">Mensagem enviada automaticamente pelo sistema PROTHEUS - <font color="BLUE" size="1">(M460FIM.PRW)</td>'
cMsg += '</tr>'
cMsg += '</table>'
cMsg += '</body>'
cMsg += '</html>'
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Envia o mail para a lista selecionada. Envia como BCC para que a pessoa pense³
//³que somente ela recebeu aquele email, tornando o email mais personalizado.   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If GetNewPar("ES_ATIVJOB",.T.)   
	u_UEnvMail(cEmail,cAssunto,nil,"",cFrom,"ENV_STD(M460FIM.prw)",cMsg)
Else
	IF At(";",cEmail) > 0
		cEmailTo := SubStr(cEmail,1,At(";",cEmail)-1)
		cEmailCc := SubStr(cEmail,At(";",cEmail)+1,Len(cEmail))
	Else
		cEmailTo := Alltrim(cEmail)
	EndIF
	
	CONNECT SMTP SERVER cServer ACCOUNT cAccount PASSWORD cPassword RESULT lResult
	
	If !lAutOk
		If ( lSmtpAuth )
			lAutOk := MailAuth(cAccount,cPassword)
		Else
			lAutOk := .T.
		EndIf
	EndIf	
	
	If lResult .And. lAutOk
		SEND MAIL FROM cFrom ;
		TO      	Lower(cEmailTo);
		CC      	Lower(cEmailCc);
		BCC     	Lower(cEmailBcc);
		SUBJECT 	cAssunto;
		BODY    	cMsg;
		RESULT lResult
		
		If !lResult
			//Erro no envio do email
			GET MAIL ERROR cError
			
			MsgInfo(cError,OemToAnsi("Atenção"))
		EndIf
		
		DISCONNECT SMTP SERVER
	Else
		//Erro na conexao com o SMTP Server
		GET MAIL ERROR cError
		MsgInfo(cError,OemToAnsi("Atenção"))
	EndIf
EndIf
	
Return(.T.)
//GIOVANI rotina de e-mail especifica para bloquear nf com icms interestadual
Static Function UEnvMailIcms(cEmail,cAssunto,aMsg,cAttach,cDe,cFuncSent,cTiAlt)
Local cAccount  := Lower(Alltrim(GetMv("MV_RELACNT")))
Local cFrom     := Lower(Alltrim(GetMv("MV_RELACNT"))) //If(Empty(Alltrim(cDe)),"protheus@dipromed.com.br",cDe)
Local cPassword := Alltrim(GetMv("MV_RELPSW"))
Local cServer   := Alltrim(GetMv("MV_RELSERV"))
Local cEmailTo  := ""
Local cEmailCc  := ""
Local cEmailBcc := ""
Local lResult   := .F.
Local cError    := ""
Local i         := 0
Local cArq      := ""
Local cMsg      := ""
LOCAL _nLin                    
LOCAL lSmtpAuth := GetNewPar("MV_RELAUTH",.F.)
LOCAL lAutOk	:= .F.
If ( Type("l410Auto") == "U" .OR. !l410Auto )  
	U_DIPPROC(ProcName(0),U_DipUsr()) // JBS 05/10/2005 - Gravando o nome do Programa no SZU
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Definicao do cabecalho do email                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cMsg := ""
	cMsg += '<html>'
	cMsg += '<head>'
	cMsg += '<title>' + cAssunto + " - "+SM0->M0_NOME+"/"+SM0->M0_FILIAL+'</title>'
	cMsg += '</head>'
	cMsg += '<body>'
	//cMsg += '<Img Src="C:/AP5/SIGAADV/LGRL01.BMP"><BR>'
	cMsg += '</Table>'
	cMsg += '<P>'
	cMsg += '<Table align="center">'
	cMsg += '<tr>'
	cMsg += '<td colspan="10" align="center"><font color="red" size="5">'+cTiAlt+'<font color="red" size="1">.</td>'
	cMsg += '</tr>'
	cMsg += '</Table>'
	
	cMsg += '<HR Width=85% Size=3 Align=Centered Color=Red> <P>'
	
	cMsg += '<Table Border=1 Align=Center BorderColor=#000000 CELLPADDING=4 CELLSPACING=0 Width=60%>'
	cMsg += '<Caption> <FONT COLOR=#000000 FACE= "ARIAL" SIZE=5>' + cAssunto +" - "+SM0->M0_NOME+"/"+SM0->M0_FILIAL+ '</FONT> </Caption>'
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Definicao do texto/detalhe do email                                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For _nLin := 1 to Len(aMsg)
		IF (_nLin/2) == Int( _nLin/2 )
			cMsg += '<TR BgColor=#B0E2FF>'
		Else
			cMsg += '<TR BgColor=#FFFFFF>'
		EndIF
		cMsg += '<TD><B><Font Color=#000000 Size="2" Face="Arial">' + aMsg[_nLin,1] + ' </Font></B></TD>'
		cMsg += '<TD> <Font Color=#000000 Size="2" Face="Arial">' + aMsg[_nLin,2] + ' </Font></TD>'
		cMsg += '</TR>'
	Next
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Definicao do rodape do email                                                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cMsg += '</Table>'
	cMsg += '<P>'
	cMsg += '<Table align="center">'
	cMsg += '<tr>'
	cMsg += '<td colspan="10" align="center"><font color="red" size="3">Mensagem enviada automaticamente pelo sistema PROTHEUS - <font color="red" size="1">('+cFuncSent+')</td>'
	cMsg += '</tr>'
	cMsg += '</Table>'
	cMsg += '<HR Width=85% Size=3 Align=Centered Color=Red> <P>'
	//cMsg += '<B><Font Color=#000000 Size="2" Face="Arial"> Atenciosamente </Font></B><BR>'
	//cMsg += '<B><Font Color=#000000 Size="2" Face="Arial">' + SM0->M0_NOMECOM + '</Font></B><BR>'
	//cMsg += '<Img Src="C:/AP5/SIGAADV/LGRL01.BMP">'
	cMsg += '</body>'
	cMsg += '</html>'
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Envia o mail para a lista selecionada. Envia como BCC para que a pessoa pense³
	//³que somente ela recebeu aquele email, tornando o email mais personalizado.   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	If GetNewPar("ES_ATIVJOB",.T.)   
		u_UEnvMail(cEmail,cAssunto,nil,"",cFrom,"UEnvMailIcms(M460FIM.prw)",cMsg)
    Else
		IF At(";",cEmail) > 0
			cEmailTo := SubStr(cEmail,1,At(";",cEmail)-1)
			cEmailCc:= SubStr(cEmail,At(";",cEmail)+1,Len(cEmail))
		Else
			cEmailTo := Alltrim(cEmail)
		EndIF
		
		CONNECT SMTP SERVER cServer ACCOUNT cAccount PASSWORD cPassword RESULT lResult
		If !lAutOk
			If ( lSmtpAuth )
				lAutOk := MailAuth(cAccount,cPassword)
			Else
				lAutOk := .T.
			EndIf
		EndIf
	
		If lResult .And. lAutOk
			SEND MAIL FROM cFrom ;
			TO      	Lower(cEmailTo);
			CC      	Lower(cEmailCc);
			BCC     	Lower(cEmailBcc);
			SUBJECT 	cAssunto;
			BODY    	cMsg;
			ATTACHMENT  cAttach;
			RESULT lResult
			
			If !lResult
				//Erro no envio do email
				GET MAIL ERROR cError
				
				MsgInfo(cError,OemToAnsi("Aten??o"))
			EndIf
			
			DISCONNECT SMTP SERVER
		Else
			//Erro na conexao com o SMTP Server
			GET MAIL ERROR cError
			
			MsgInfo(cError,OemToAnsi("Aten??o"))
		EndIf
	EndIf
ENDIF
Return(.T.)
Static Function CICMAILTES()
Local _cQry0 := " "
Local lRet   := .F.
Local _aMsgVal 		:= {}
Local cAsIc  		:=  " CONFIRMACAO - TES 654 UTILIZADA"
Local cAttachIc   	:=  "  a"
Local cEc       	:=  Lower(Alltrim(GetMv("MV_RELACNT")))
Local cEIc    		:=  GetMv("ES_M460HQ",,"maximo.canuto@dipromed.com.br ")
Local cFuIc 		:=  "M460FIM.prw"
Local cMSGcVal      :=  ""
Local cEnvMsg       := "MAXIMO.CANUTO"
Local cTituV        := "ATENÇÃO NOTA COM S/T RECOLHER GUIA"
_cQry0 :=" SELECT     "
_cQry0 +=" LTRIM(RTRIM(A1_COD))+' - '+LTRIM(RTRIM(A1_NREDUZ))              AS  'NOME', "
_cQry0 +=" D2_DOC                              AS  'NOTA', "
_cQry0 +=" D2_SERIE                            AS 'SERIE'  "
_cQry0 +=" FROM "+RETSQLNAME ("SD2") + " SD2 "
_cQry0 +=" INNER JOIN(SELECT *      "
_cQry0 +=" FROM "+RETSQLNAME ("SA1") + " SA1 "
_cQry0 +=" WHERE SA1.D_E_L_E_T_ = ' ' )TA1    "
_cQry0 +=" ON TA1.A1_FILIAL 	= ' '  "
_cQry0 +=" AND TA1.A1_COD 		= D2_CLIENTE  "
_cQry0 +=" AND TA1.A1_LOJA 		= D2_LOJA  "
_cQry0 +=" WHERE D2_DOC 		= '"+SF2->F2_DOC+"'"
_cQry0 +=" AND   D2_FILIAL   	= '"+XFILIAL("SD2")+"'"
_cQry0 +=" AND   D2_TES     	= '654'               "
_cQry0 +=" AND   SD2.D_E_L_E_T_ = ' '                 "
DbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQry0),'TMP1',.T.,.F.)
TMP1->(dbgotop())
If !EMPTY ("TMP1")
	DbSelectArea("TMP1")
	DbGoTop()
	While TMP1->(!EOF())
		lRet := .T.
		cNoCli:=TMP1->NOME
		
		TMP1->( dbSkip())
	END
EndIf
TMP1->(DBCloseArea())
If lRet
	DBSELECTAREA("SM0")
	aAdd( _aMsgVal , { "EMPRESA"      , + Capital( AllTrim( GetAdvFVal( "SM0", "M0_NOMECOM", cEmpAnt + cFilAnt, 1, "" ) ) )  } )
	aAdd( _aMsgVal , { "FILIAL"       , + Capital( AllTrim( GetAdvFVal( "SM0", "M0_FILIAL" , cEmpAnt + cFilAnt, 1, "" ) ) ) } )
	aAdd( _aMsgVal , { "NOTA"         , ""+SF2->F2_DOC+""  } )
	aAdd( _aMsgVal , { "CLIENTE"      , ""+cNoCli+""  } )
	aAdd( _aMsgVal , { "TES"          , "654"  } )
	aAdd( _aMsgVal , { "ST a recolher: "          , Transform(SF2->F2_ICMSRET,"@E 999,999,999.99")  } )
	aAdd( _aMsgVal , { "Valor Mercadoria: "          , Transform(SF2->F2_VALMERC,"@E 999,999,999.99")  } )
   
	UEnvMailIcms(cEIc,cAsIc,_aMsgVal,cAttachIc,cEc,cFuIc,cTituV)
	
	
	cMSGcVal := SM0->M0_NOME+"/"+SM0->M0_FILIAL+CR+CR
	cMSGcVal += "ICMS-ST FORA DE SP. "+CR+CR
	cMSGcVal += "A NF "  +SF2->F2_DOC+" série  "+SF2->F2_SERIE+CR
	cMSGcVal += "  do cliente  "+cNoCli+CR
	cMSGcVal += "Foi emitida e tem ICMS-ST a recolher."+CR+CR
	cMSGcVal += "Valor Mercadoria: R$   " +Transform(SF2->F2_VALMERC,"@E 999,999,999.99")+CR
	cMSGcVal += "Base Icms-St:     R$   " +Transform(SF2->F2_BRICMS ,"@E 999,999,999.99")+CR
	cMSGcVal += "ST a recolher:    R$   " +Transform(SF2->F2_ICMSRET,"@E 999,999,999.99")
	
	U_DIPCIC(cMSGcVal,cEnvMsg)
	
	
EndIf
Return()
/*                     
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³ ValImpBolº Autor ³   Maximo Canuto    º Data ³  10/07/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Valida geração e impressão dos boletos           		  º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ValImpBol(_cBoleto,_cPrefixo)
Local _oDlg
Local _nOpcao    := 0
Local _cNumBco   := Space(100)   
Local _nParcela  := 0
Local _aBoletos  := {}          
Local _cMscCic   := ""
Local _cOpFatDest:= GetNewPar("ES_CICVBOL","MAXIMO.CANUTO")
Local _cEmail    := GetNewPar("ES_MAIVBOL","maximo.canuto@dipromed.com.br")
Local _cAssunto  := ""
Local _aMsg      := {}
Local _cFrom     := Lower(Alltrim(GetMv("MV_RELACNT")))
Local _cFuncSent := "M460FIM(ValImpBol)"
Local cAuxNumBco :=Space(100)
DEFAULT _cBoleto := ""
DEFAULT _cPrefixo:= ""
_aBoletos := DipBoletos(_cBoleto,_cPrefixo)
If cEmpAnt+cFilAnt=="0401" //RBORGES 12/08/2013 - Validação para enviar e-mail e cic para HQ, quando for ERRO HQ.
	
	_cOpFatDest:= GetNewPar("ES_CICBOLH","CAROLINA.SOSSOLOTE")
	_cEmail    := GetNewPar("ES_MAIBOLH","financeiro@healthquality.ind.br;vendas@healthquality.ind.br")
	
EndIf
  
While _nOpcao<>1
	
	
	@ 126,000 To 280,450 DIALOG _oDlg TITLE OemToAnsi("Validando impressão do boleto " + _cBoleto)
	
	If _aBoletos[2] > 1
		cAuxNumBco :=Space(100)
		@ 008,010 Say 'Digite o Nosso Número contido no boleto: '+_cBoleto+ ' e a quantidade de parcelas!'
		@ 020,010 Say "Nosso Numero: "
		@ 020,060 Get _cNumBco Size 60,20 Picture "@!"
		@ 035,010 Say "Número de Parcelas "
		@ 035,060 Get _nParcela Size 43,20 Picture "999"
		@ 050,130 BUTTON OemToAnsi("Confirma")       SIZE 30,15 ACTION (_nOpcao := 1, Close(_oDlg))
		@ 050,170 BUTTON OemToAnsi("Boleto")         SIZE 30,15 ACTION (u_DIPM023(.t.,@_cBanco),Aviso("Atenção!","SE O BOLETO NãO SAIR VERIFIQUE A IMPRESSORA!",{'OK'},1),_nOpcao := 0, Close(_oDlg))		
		@ 065,010 Say "Para sair descreva o problema no campo Nosso Numero iniciando com a palavra ERRO! "          COLOR CLR_HRED
	Else
		cAuxNumBco :=Space(100)
		@ 008,010 Say 'Digite o Nosso Número contido no boleto: '+_cBoleto
		@ 020,010 Say "Nosso Numero: "
		@ 020,060 Get _cNumBco Size 60,20 Picture "@!"
		@ 040,130 BUTTON OemToAnsi("Confirma")       SIZE 30,15 ACTION (_nOpcao := 1, Close(_oDlg))
		@ 040,170 BUTTON OemToAnsi("Boleto")         SIZE 30,15 ACTION (u_DIPM023(.t.,@_cBanco),Aviso("Atenção!","SE O BOLETO NãO SAIR VERIFIQUE A IMPRESSORA!",{'OK'},1),_nOpcao := 0, Close(_oDlg))		
		@ 065,010 Say "Para sair descreva o problema no campo Nosso Numero iniciando com a palavra ERRO! "          COLOR CLR_HRED
	Endif
	
	ACTIVATE DIALOG _oDlg Centered
	
	If Empty(cAuxNumBco) 
		cAuxNumBco := _cNumBco 
	EndIf
	if _cBanco == "237" .And. Left(Upper(Alltrim(_cNumBco)),4) <> 'ERRO'
		_cNumBco := Substr(cAuxNumBco,3,Len(Alltrim(cAuxNumBco))-2)
		
	ElseIf _cBanco == "341" .And. Left(Upper(Alltrim(_cNumBco)),4) <> 'ERRO'
	
		_cNumBco := Substr(cAuxNumBco,4,Len(Alltrim(cAuxNumBco))-4)+substr(_aBoletos[1],len(_aBoletos[1]),1)
	
	Elseif _cBanco == "356" .And. Left(Upper(Alltrim(_cNumBco)),4) <> 'ERRO'
	
		_cNumBco := Substr(cAuxNumBco,3,Len(Alltrim(cAuxNumBco))-2)
	
	EndIf
	If _nOpcao==1
		If Left(Upper(Alltrim(_cNumBco)),4) == 'ERRO'
			If Aviso("Atenção!",_cNumBco+CHR(10)+chr(13)+CHR(10)+chr(13)+"Confirma o problema na impressão do boleto?" ,{'SIM','NÃO'},1) <> 1
     			_nOpcao := 0                                     
     		Else                                                
     			
     			//Enviando Cic para Financeiro
				_cMscCic := "AVISO IMPORTANTE - ERRO NA GERAÇÃO DO BOLETO"+CR + CR
				_cMscCic += "Ocorreu um erro na geração/impressão do boleto " +_cBoleto+ " / " +_cPrefixo+CR+CR
				_cMscCic += _cNumBco+ CR + CR							
				_cMscCic +=CR + "Usuario: "+Upper(U_DipUsr())
				U_DIPCIC(_cMscCic,_cOpFatDest)//envia cic	    			
				
				//Enviando e-mail para Financeiro   
			    _cAssunto:= "ERRO NA GERAÇÃO/IMPRESSÃO DO BOLETO " +_cBoleto+ " / " +_cPrefixo
			    Aadd( _aMsg , { "Descrição: "       	, _cNumBco } )
		   		Aadd( _aMsg , { "Duplicata: "       	, _cBoleto } )
		   		Aadd( _aMsg , { "Prefixo: "      	 	, _cPrefixo } )
		   		Aadd( _aMsg , { "Numero Pedido: "  		, SC5->C5_NUM } )
				Aadd( _aMsg , { "Operador: "            , SC5->C5_OPERADO  +" - "+ _cNomeSU7 } )
				Aadd( _aMsg , { "Cliente:  "            , SC5->C5_CLIENTE  +" - "+ _cNomeSA1 } )
				Aadd( _aMsg , { "Usuário: "             , U_DipUsr() } )			
				U_UEnvMail(_cEmail,_cAssunto,_aMsg,"",_cFrom,_cFuncSent)
				
     		Endif
		ElseIf _aBoletos[2] > 1
		
		
			If !(_aBoletos[2] == _nParcela)
			    Aviso("Atenção!","Numero de parcelas incorreto, tente novamente!",{'OK'},1)
				_nOpcao := 0
				_cNumBco   := Space(100)
			ElseIf cEmpAnt=="04" .And. !(_aBoletos[1] == Alltrim(_cNumBco)) //Substr(_cNumBco,3,Len(Alltrim(_cNumBco))-2))
				Aviso("Atenção!","Numero Bancário incorreto, tente novamente!",{'OK'},1)
				_nOpcao := 0
				_cNumBco   := Space(100)
			ElseIf cEmpAnt=="01" .And. !(_aBoletos[1] == Alltrim(_cNumBco))
			    Aviso("Atenção!","Numero Bancário incorreto, tente novamente!",{'OK'},1)
				_nOpcao := 0
				_cNumBco   := Space(100)
			Else        
			    Aviso("Atenção!","Validação dos boletos está OK! Favor anexar na nota.",{'OK'},1)			
			    
       			
       			//Definindo usuários TI
       			_cOpFatDest:= ("MAXIMO.CANUTO,DIEGO.DOMINGOS")    
				_cEmail    := ("diego.domingos@dipromed.com.br;maximo.canuto@dipromed.com.br")        
       			
       			//Enviando Cic para TI
				_cMscCic := "BOLETO VALIDADO COM SUCESSO"+CR + CR
				_cMscCic += _cBoleto+ " / " +_cPrefixo+CR+CR
				_cMscCic +=CR + "Usuario: "+Upper(U_DipUsr())
				U_DIPCIC(_cMscCic,_cOpFatDest)//envia cic	    			
				
				//Enviando e-mail para Financeiro   
			    _cAssunto:= "BOLETO VALIDADO COM SUCESSO: " +_cBoleto+ " / " +_cPrefixo
		   		Aadd( _aMsg , { "Duplicata: "       	, _cBoleto } )
		   		Aadd( _aMsg , { "Prefixo: "      	 	, _cPrefixo } )
		   		Aadd( _aMsg , { "Numero Pedido: "  		, SC5->C5_NUM } )
				Aadd( _aMsg , { "Operador: "            , SC5->C5_OPERADO  +" - "+ _cNomeSU7 } )
				Aadd( _aMsg , { "Cliente:  "            , SC5->C5_CLIENTE  +" - "+ _cNomeSA1 } )
				Aadd( _aMsg , { "Usuário: "             , U_DipUsr() } )			
				U_UEnvMail(_cEmail,_cAssunto,_aMsg,"",_cFrom,_cFuncSent)       
			    
			EndIf	                      			
		Else
		
			If !(_aBoletos[1] == Alltrim(_cNumBco))
			    Aviso("Atenção!","Numero Bancário incorreto, tente novamente!",{'OK'},1)
				_nOpcao := 0
				_cNumBco   := Space(100)
			Else
			    Aviso("Atenção!","Validação do boleto está OK! Favor anexar na nota.",{'OK'},1)
			EndIf	
		Endif
		
	Endif     	
Enddo     
              
Return()
/*                     
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³ DipBoletos  º Autor ³   Maximo Canuto    º Data ³  10/07/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Busca os dados do título 								  º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function DipBoletos(_cBoleto,_cPrefixo)
Local _cNossoNum :=  ""
Local _nParcelas :=  0
DEFAULT _cBoleto := ""
DEFAULT _cPrefixo:= ""
                             
	// Buscando os dados dos títulos
	QRY1 := "SELECT E1_NUM, E1_PREFIXO, E1_EMISSAO, E1_PARCELA, E1_TIPO, E1_NUMBCO"
	QRY1 += " FROM " +  RetSQLName('SE1')  
	QRY1 += " WHERE " + RetSQLName('SE1') + ".D_E_L_E_T_ <> '*' AND "         
	QRY1 += RetSQLName('SE1') + ".E1_EMISSAO = '" + Dtos(dDatabase) + "' AND "
	QRY1 += RetSQLName('SE1') + ".E1_NUM = '" + _cBoleto + "' AND "
	QRY1 += RetSQLName('SE1') + ".E1_PREFIXO = '" + _cPrefixo + "' AND "
	QRY1 += RetSQLName('SE1') + ".E1_TIPO = 'NF' "
	QRY1 += "ORDER BY E1_NUM"
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
	// Posicionando no primeiro registro
	DbSelectArea("QRY1")
	DbGoTop()
	// Filtro para montagem do relatório em um Array
	Do While QRY1->(!Eof())
	    
		If QRY1->E1_PARCELA $ (' A')
			_cNossoNum := Alltrim(QRY1->E1_NUMBCO)
		Endif
		
		_nParcelas++
		
		QRY1->(DbSkip())
	EndDo            
	
QRY1->(DbCloseArea())
Return({_cNossoNum,_nParcelas}) 
/*-------------------------------------------------------------------------
+ RBORGES - 29/07/2013 ----- Static Funcion: AVCicNFA().                   +                                                     
+ Fará o tratamento para enviar CIC de aviso das Notas Fiscais             +
+ geradas para o novo armazem.  						                   +
-------------------------------------------------------------------------*/
*--------------------------------------------------------------------------*
Static Function AVCicNFA()
*--------------------------------------------------------------------------*
Local aArea       := GetArea()
Local cDeIc       := Lower(Alltrim(GetMv("MV_RELACNT")))
Local cCICDest    := Upper(GetNewPar("ES_CIC_ARM","REGINALDO.BORGES")) // Usuários que receberão CIC´s
Local cAttachIc   :=  "  a"
Local cFuncSentIc :=   " M460FIM.prw "
dbSelectArea("SM0")
_aMsgIc := {}
cMSGcIC       := 'AVISO - REMESSA PARA ARMAZÉM - NOTA FISCAL -' + SF2->F2_DOC + ' ' + SF2->F2_SERIE +CHR(13)+CHR(10)+CHR(13)+CHR(10)
cMSGcIC       += " EMPRESA:_______    " + Capital( AllTrim( GetAdvFVal( "SM0", "M0_NOME", cEmpAnt + cFilAnt, 1, "" ) ) ) +"/"+ Capital( AllTrim( GetAdvFVal( "SM0", "M0_FILIAL" , cEmpAnt + cFilAnt, 1, "" ) ) )   +CHR(13)+CHR(10)
cMSGcIC       += " PEDIDO:________    " + SC5->C5_NUM +CHR(13)+CHR(10)
cMSGcIC       += " CLIENTE:________   " + SC5->C5_CLIENTE+" - "+_cNRedSA1+CHR(13)+CHR(10)
cMSGcIC       += " COND.PAG:__________" + SC5->C5_CONDPAG+" - "+Posicione("SE4",1,XFILIAL("SE4")+SC5->C5_CONDPAG,'E4_DESCRI') +CHR(13)+CHR(10)
cMSGcIC       += " OPERADOR:_______   " + SC5->C5_OPERADO+"-"+_cNRedSU7+CHR(13)+CHR(10)
cMSGcIC       += " TRANSP.:_______    " + SC5->C5_TRANSP+" - " + AllTrim(FDesc("SA4",SC5->C5_TRANSP,"SA4->A4_NREDUZ"))        +CHR(13)+CHR(10)
U_DIPCIC(cMSGcIC,cCICDest)
RestArea(aArea)
return()
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³M460FIM   ºAutor  ³Microsiga           º Data ³  04/13/17   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function GravaZZU(cDoc,cSerie)
Local cSQL 	 	:= ""
DEFAULT cDoc    := ""
DEFAULT cSerie  := ""
cSQL := " SELECT "
cSQL += " 	R_E_C_N_O_ REC "
cSQL += " 	FROM "
cSQL +=  		RetSQLName("ZZU")
cSQL += " 		WHERE "
cSQL += " 			ZZU_FILIAL = '"+xFilial("ZZU")+"' AND "
cSQL += " 			ZZU_USUARI = '"+U_DipUsr()+"' AND "
cSQL += " 			ZZU_STATUS = '1' AND "
cSQL += " 			ZZU_NOTA   = ' ' AND "
cSQL += " 			ZZU_DATA   = '"+DtoS(dDataBase)+"' AND "
cSQL += " 			D_E_L_E_T_ = ' ' "
cSQL := ChangeQuery(cSQL)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),"QRYZZU",.T.,.T.)	  
While !QRYZZU->(Eof())
	ZZU->(dbGoTo(QRYZZU->REC))
	ZZU->(RecLock("ZZU",.F.))
		ZZU->ZZU_NOTA  := cDoc
		ZZU->ZZU_SERIE := cSerie
	ZZU->(MsUnLock())
	QRYZZU->(dbSkip())
EndDo
QRYZZU->(dbCloseArea())					
Return
/*
+-----------------------------------------------------------------------+
|FUNCAO: VERNCC() | Autor:  Reginaldo Borges   |    Data:   30/11/2018  |                                                     
+-----------------------------------------------------------------------+
|Verifica se há NCC para o cliente e disparar um e-mail para o          |
|financeiro, contas a receber.                                          | 
+-----------------------------------------------------------------------+
*/
Static Function VERNCC(_cCliente,_cLoja)
Local _xArea      := GetArea()
Local cDeIc       := Lower(Alltrim(GetMv("MV_RELACNT")))
Local cEmailIc    := GetNewPar("ES_VERNCC","sidneia.domingos@dipromed.com.br;reginaldo.borges@dipromed.com.br;maximo.canuto@dipromed.com.br")  //Usuários que receberão e-mails
Local cCICDest    := Upper(GetNewPar("ES_CIC_NCC","REGINALDO.BORGES,SIDNEIA.DOMINGOS,MAXIMO.CANUTO")) // Usuários que receberão CIC´s
Local cAssuntoIc  := "AVISO - CLIENTE COM NCC PENDENTE PARA CRÉDITO, "+AllTrim(_cCliente)
Local cAttachIc   :=  "  a"
Local cFuncSentIc :=   "VERNCC_M460FIM"
Local cQRY1       := ""
Local cMSGcIC     := ""
Local _aMsgIc     := {}
Local cNomeCli    := _cCliente+" - "+Posicione("SA1",1,xFilial("SA1")+_cCliente+_cLoja,"A1_NOME")
Local cEmpresa    := ""
cQRY1 := " SELECT E1_CLIENTE, E1_LOJA, E1_NUM, E1_PREFIXO, E1_TIPO " 
cQRY1 += " 	FROM "+RetSQLName("SE1") 
cQRY1 += " WHERE "
cQRY1 += " E1_CLIENTE = '"+_cCliente+"' AND "
cQRY1 += " E1_LOJA    = '"+_cLoja+"' AND   "
cQRY1 += " E1_TIPO    = 'NCC' AND "
cQRY1 += " E1_SALDO   > 0     AND "
cQRY1 += " D_E_L_E_T_ = ''  "
cQRY1 := ChangeQuery(cQRY1)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQRY1),"QRY1E1",.T.,.T.)
If !QRY1E1->(Eof())    
	
	If cEmpAnt == "01"
		cEmpresa = "DIPROMED"
	ElseIf cEmpAnt == "04"
		cEmpresa = "HEALTH QUALITY"
	Else	
		cEmpresa = " "	
	EndIf
	
	aAdd( _aMsgIc , { "CLIENTE ", +cNomeCli})
	aAdd( _aMsgIc , { "LOJA    ", +_cLoja})
	aAdd( _aMsgIc , { "TIPO    ", "NCC"})
	cMSGcIC := 'AVISO - CLIENTE COM NCC PENDENTE PARA CRÉDITO -' + AllTrim(_cCliente) + ' - '+cEmpresa +CHR(13)+CHR(10)+CHR(13)+CHR(10)
														
	cMSGcIC       += " CLIENTE:_____ " + cNomeCli +CHR(13)+CHR(10)
	cMSGcIC       += " LOJA:________ " + _cLoja +CHR(13)+CHR(10)
	cMSGcIC       += " TIPO:________ " + "NCC" +CHR(13)+CHR(10)
	cAssuntoIc := cAssuntoIc+" - "+cEmpresa+" !"
	If GetNewPar("ES_ATIVJOB",.T.)
		U_UEnvMail(cEmailIc,cAssuntoIc,_aMsgIc,cAttachIc,cDeIc,cFuncSentIc)
		U_DIPCIC(cMSGcIC,cCICDest)
		EndIf
		
EndIf
QRY1E1->(dbCloseArea())
RestArea(_xArea)
Return

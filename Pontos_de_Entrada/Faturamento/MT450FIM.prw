#Define CR chr(13)+chr(10)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MT450FIM  ºAutor  ³Maximo Canuto V. Netoº Data ³ 15/04/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Ponto de Entrada executado após a liberação do crédito.     º±±
±±º          ³                                                           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/


User Function MT450FIM()

// Preserva a area atual - Por Sandro Albuquerque
Local aArea      := GetArea()
Local aAreaSC5   := SC5->( GetArea() )
Local aAreaSC6   := SC6->( GetArea() )
Local aAreaSC9   := SC9->( GetArea() )
//  Ate aqui

Local lContinua := .T.
Local cPedido  := " "//SC5->C5_NUM  //Giovani Zago 11/11/11
Local cFilSC9  := xFilial("SC9")
Local cInd     := "1"
Local cMail
Local cServidor   := GetMV("MV_CIC")     // Servidor para enviar mensagem pelo CIC
Local cOpFatRem   := GetMV("MV_REMETCI") // Usuario do CIC remetente de mensgens no Protheus
Local cOpFatSenha := "123456"
Local cOpFatDest  := "maximo.canuto,andrea.almeida,juraci.rocha,ana.santos,luciana.matiazzo"
Local lEnviou     := .F. 
Local cTrpCol     := GetNewPar("ES_TRP_COLS","000235") 
Local nVlrPedCE   := 0
Local nTotped     := 0 // Criado por Sandro - Para trazer o total dos itens da NF para a mensagem do CIC.
Loca cGPRCXF      := ""

SC5->(MsSeek(xFilial("SC5")+SC9->C9_PEDIDO))

ConOut("MT450FIM - DEPOIS DE FINALIZADA A LIBERACAO MANUAL DE CREDITO - Data/Hora: "+ Dtoc(dDatabase)+"-"+time()+" - Usuario: "+ U_DipUsr())
ConOut("MT450FIM - PEDIDO-PRENOTA-PARCIAL ->"  +SC5->C5_NUM+" - "+SC5->C5_PRENOTA+" - "+SC5->C5_PARCIAL)

cPedido  := SC9->C9_PEDIDO //Giovani Zago 11/11/11 carregando variavel apos o posicionamento na sc5 - possivel erro de posicionamento , nao esta enviando cic.

If SC5->C5_PRENOTA == 'F'
	U_DIPPROC(ProcName(0),U_DipUsr())
	ConOut("MT450FIM - Entrei no IF do ponto de entrada MT450FIM - PEDIDO->"  +SC5->C5_NUM+"-"+SC5->C5_PRENOTA)
	Reclock("SC5",.F.)
	SC5->C5_PRENOTA := ""
	SC5->C5_HORALIB := Time()
	SC5->(MsUnLock())
	SC5->(DbCommit())  // Eriberto 24/04/07
	
	U_DiprKardex(SC9->C9_PEDIDO,U_DipUsr(),,.T.,"26")
EndIf

If !lEnviou
	lEnviou := .T.
	SC5->(DbSeek(cFilSC9+cPedido))
	
	SA1->(dbSetOrder(1))
	SA1->(dbSeek(xFilial("SA1") + SC5->C5_CLIENTE + SC5->C5_LOJACLI))
	
	
	If SC5->C5_CONDPAG $ "001/002"
		
		nTotped := ValorPedido(SC9->C9_PEDIDO)  // Incluido por Sandro em 10/11/09
		
		// Monta a mensagem a ser enviado ao operador
		cMail := "PEDIDO A VISTA"+CR+CR
		cMail += "O Pedido A VISTA "   +Alltrim(SC5->C5_NUM)
		cMail += " do Cliente "+AllTrim(SA1->A1_COD)+" - "+AllTrim(SA1->A1_NREDUZ)+CR
		cMail += " Valor total "+AllTrim(Transform(nTotped,"@E 999,999,999.99"))+CR   // Incluido por Sandro em 10/11/09
		cMail += "Foi liberado pelo Crédito."+CR+CR
		cMail += U_DipUsr() 
		
	
		
		// Envia a mensagem ao operador através do CIC                                            
		U_DIPCIC(cMail,AllTrim(cOpFatDest))// RBorges 12/03/15
//		WaitRun(cServidor+' '+cOpFatRem+' '+cOpFatSenha+' "'+AllTrim(cOpFatDest)+'" "'+cMail+'" ') // Comentada 12/03/15
			

			
	Endif
EndIf

//RBORGES 21/06/2013 - Se o pedido não passar direto pelo crédito fará o tratamento abaixo par enviar CIC e E-mail

nVlrPedCE := ValorPedido(SC5->C5_NUM)

//IF SC5->C5_PRENOTA == 'F'
   //	DbSeek(xFilial("SC9")+SC5->C5_NUM)
	
	
	U_CICMailAV(SC5->C5_NUM)
	u_DipICMSCF(SC5->C5_NUM)	

				
	If !  SC5->C5_TRANSP $ cTrpCol .And. ! U_NaoMovEst(SC5->C5_NUM) .And. cEmpAnt == "01" //Somente para Dipromed RBorges 28/08/2019.
		ColCicMail()
	endif
//EndIf
 
 If cEmpAnt <> "04"
	If SC5->C5_CLIENTE$GetNewPar("ES_DCLICXF","000665")
		u_DipCicPri(SC5->C5_NUM)
	EndIf
Else
	cGPRCXF := Posicione("SA1",1,xFilial("SA1")+SC5->C5_CLIENTE,'A1_GRPVEN')
	If (SC5->C5_CLIENTE$GetNewPar("ES_DCLICXF","000665") .Or. cGPRCXF$GetNewPar("ES_DGRPCXF","000175")) .And. !U_AmostrasHQ()
		u_DipCicPri(SC5->C5_NUM)
	EndIf
	cGPRCXF := ""
EndIf


RestArea( aAreaSC9 )
RestArea( aAreaSC6 )
RestArea( aAreaSC5 )
RestArea( aArea )



Return(lContinua)



*--------------------------------------------------------------------------*
//Função para enviar Cic para o responsável
Static Function ValorPedido(cPedido)
*--------------------------------------------------------------------------*
Local aArea      := GetArea()
Local aAreaSC6   := SC6->( GetArea() )
Local nVlrPed    := 0

DbSelectArea("SC6")
DbSetOrder(1)
SC6->(DbSeek(xFilial("SC6")+cPedido))
While SC6->C6_NUM == cPedido
	If SC6->C6_NUM == cPedido
		nVlrPed += SC6->C6_VALOR
	Endif
	SC6->(DbSkip())
Enddo
SC6->(DbCloseArea())

DbSelectArea("SC5")
DbSetOrder(1)
If SC5->(DbSeek(xFilial("SC5")+cPedido))
	nVlrPed := (nVlrPed + SC5->C5_DESPESA + SC5->C5_SEGURO + SC5->C5_FRETE)
Endif

RestArea( aAreaSC6 )
RestArea( aArea )

Return(nVlrPed) 


	
   
/*-----------------------------------------------------------------------------
+ Reginaldo Borges Data: 25/06/2013 Função: ColCicMail()                                                                              
+ Essa função enviará cic e e-mail para os usuários contidos nos parâmetros,
+ quando for necessário a solicitação de coleta à transportadora do pedido. 
-----------------------------------------------------------------------------*/
 


	*--------------------------------------------------------------------------*
	Static Function ColCicMail()
	*--------------------------------------------------------------------------*
	
	Local cDeIc       := "protheus@dipromed.com.br"
    Local cEmailIc    := GetMv("ES_MAI_COL")        //Usuários que receberão e-mails
    Local cCICDest    := Upper(GetMv("ES_CIC_COL")) // Usuários que receberão CIC´s
	Local cAssuntoIc  := "AVISO - SOLICITAR COLETA PARA ESSE PEDIDO! " +CR
	Local cAttachIc   :=  "  a"
	Local cFuncSentIc :=   " MT450FIM.prw "
 	Local cTrpCol     := GetNewPar("ES_TRP_COLS","000235")

	_aMsgIc := {}
    	cMSGcIC       := "AVISO - SOLICITAR COLETA PARA ESSE PEDIDO! " +CR +CR
	
	aAdd( _aMsgIc , { " EMPRESA"  				, + Capital( AllTrim( GetAdvFVal( "SM0", "M0_NOME", cEmpAnt + cFilAnt, 1, "" ) ) )  } )
	cMSGcIC       += " EMPRESA:_______" + Capital( AllTrim( GetAdvFVal( "SM0", "M0_NOME", cEmpAnt + cFilAnt, 1, "" ) ) ) +"/"+ Capital( AllTrim( GetAdvFVal( "SM0", "M0_FILIAL" , cEmpAnt + cFilAnt, 1, "" ) ) )   + CR
	aAdd( _aMsgIc , { " FILIAL"   	   			, + Capital( AllTrim( GetAdvFVal( "SM0", "M0_FILIAL" , cEmpAnt + cFilAnt, 1, "" ) ) ) } )
	aAdd( _aMsgIc , { "PEDIDO"    				,+SC5->C5_NUM  } )
	cMSGcIC       += " PEDIDO:________"+SC5->C5_NUM +CR
	aAdd( _aMsgIc , { "CLIENTE"    				,+SC5->C5_CLIENTE+" - "+Posicione("SA1",1,XFILIAL("SA1")+SC5->C5_CLIENTE,'A1_NREDUZ') } )
	cMSGcIC       += " CLIENTE:________"+SC5->C5_CLIENTE+" - "+Posicione("SA1",1,XFILIAL("SA1")+SC5->C5_CLIENTE,'A1_NREDUZ') +CR
	aAdd( _aMsgIc , { "COND.PAG"    	, +SC5->C5_CONDPAG+" - "+Posicione("SE4",1,XFILIAL("SE4")+SC5->C5_CONDPAG,'E4_DESCRI')   } )
	cMSGcIC       += "COND.PAG:__________"+SC5->C5_CONDPAG+" - "+Posicione("SE4",1,XFILIAL("SE4")+SC5->C5_CONDPAG,'E4_DESCRI') +CR
   	aAdd( _aMsgIc , { "OPERADOR"    			,""+SC5->C5_OPERADO+"-"+Posicione("SU7",1,xFilial("SU7")+SC5->C5_OPERADO,"U7_NREDUZ") })
	cMSGcIC       += " OPERADOR:_______"+SC5->C5_OPERADO+"-"+Posicione("SU7",1,xFilial("SU7")+SC5->C5_OPERADO,"U7_NREDUZ") +CR
	aAdd( _aMsgIc , { "VENDEDOR"      ,""+SC5->C5_VEND1+"-"+Posicione("SA3",1,xFilial("SA3")+SC5->C5_VEND1,"A3_NOME") })
	aAdd( _aMsgIc , { "TRANSPORTADORA"     , ""+SC5->C5_TRANSP+" - " + AllTrim(FDesc("SA4",SC5->C5_TRANSP,"SA4->A4_NREDUZ"))+" "  } )
    cMSGcIC       += " TRANSP.:_______"+SC5->C5_TRANSP+" - " + AllTrim(FDesc("SA4",SC5->C5_TRANSP,"SA4->A4_NREDUZ")) +CR
   	
   	U_DIPCIC(cMSGcIC,cCICDest)
   	  	
	U_UEnvMail(cEmailIc,cAssuntoIc,_aMsgIc,cAttachIc,cDeIc,cFuncSentIc)

	

	
	return() 

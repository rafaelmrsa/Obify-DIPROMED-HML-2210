#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#Include "Colors.ch"
#Define CR chr(13)+chr(10)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MTA450R   ºAutor  ³Fernando R. Assunçãoº Data ³  06/05/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Copiado do programa UMATA450, este ponto de entrada é exe- º±±
±±º          ³ executado após ser rejeitada a liberação do pedido.        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function MTA450R()
Local aAreaSC9		:= SC9->(GetArea())
Local cPedido  		:= SC9->C9_PEDIDO
Local cFilSC9  		:= xFilial("SC9")
Local cInd     		:= "1"
Local cMail         := ""
Local cServidor   	:= GetMV("MV_CIC")     // Servidor para enviar mensagem pelo CIC
Local cOpFatRem   	:= GetMV("MV_REMETCI") // Usuario do CIC remetente de mensgens no Protheus
Local cOpFatSenha 	:= "123456"
Local cOpFatDest  	:= ""
Local cGetMotivo  	:= Space(90)
Local lRetorno 		:= .T.
Local lSaida 		:= .f.                          
Local cSQL 			:= ""
Local nRecno		:= 0
Local nOpcao      	:= 0
Local aMsg 	 		:= {}                                                     
Local cFrom     	:= "protheus@dipromed.com.br"
Local cFuncSent 	:= "MTA450R(MTA450R)"
Local cAssunto		:= ""
Local cLockPed 		:= cPedido+"_"+cEmpAnt+cFilAnt	

If !LockByName(cLockPed,.T.,.T.)
	Aviso("Atenção","Não foi possível ter acesso exclusivo. Tente novamente.",{"Ok"},1) 
	RestArea(aAreaSC9)
	Return(.F.)
EndIf

U_DIPPROC(ProcName(0),U_DipUsr()) //MCVN - 22/01/2009

SC5->(DbSeek(cFilSC9+cPedido))

If SC5->C5_PRENOTA <> "F"   
	Aviso("Erro","Este pedido não pode ser rejeitado. Avise o T.I.",{"Ok"})
	UnlockByName(cLockPed,.T.,.T.)
	Return(.F.)
EndIf

// Dados do Destinatario da Mensagem CIC
SU7->(dbSetOrder(1))
SU7->(dbSeek(xFilial("SU7")+SC9->C9_OPERADO))
cOpFatDest := SU7->U7_CICNOME                    
cMailDest  := AllTrim(SU7->U7_EMAIL)
               
cMailDest+=";maximo.canuto@dipromed.com.br;diego.domingos@dipromed.com.br"

SA1->(dbSetOrder(1))
SA1->(dbSeek(xFilial("SA1") + SC9->C9_CLIENTE + SC9->C9_LOJA))
cObsFin := ""           

M->C9_PEDIDO  := cPedido
M->A1_CLIENTE := AllTrim(SC9->C9_CLIENTE)+"-"+SA1->A1_NREDUZ
M->U7_OPERADO := AllTrim(SC9->C9_OPERADO)+"-"+SU7->U7_NREDUZ

If Upper(U_DipUsr()) $ 'MCANUTO/DDOMINGOS/RBORGES'
	cGetMotivo := "Maximo - testando melhorias no Protheus."+space(44)
EndIf

Do While !lSaida
	nOpcao := 0
	
	Define msDialog oDlg Title "Rejeitando Pedido " From 10,10 TO 23,60
	
	@ 001,002 tO 78,196
	
	@ 010,010 say "Pedido  " COLOR CLR_BLACK
	@ 020,010 say "Cliente " COLOR CLR_BLACK
	@ 030,010 say "Operador" COLOR CLR_BLACK
	
	@ 010,050 get M->C9_PEDIDO  when .f. size 050,08
	@ 020,050 get M->A1_CLIENTE when .f. size 120,08
	@ 030,050 get M->U7_OPERADO when .f. size 120,08
	
	@ 050,010 say "Descreva o motivo da Rejeição" COLOR CLR_HBLUE
	@ 060,010 get cGetMotivo valid !empty(cGetMotivo) size 165,08
	
	DEFINE SBUTTON FROM 82,130 TYPE 1 ACTION IF(!empty(cGetMotivo),(lSaida:=.T.,nOpcao:=1,oDlg:End()),msgInfo("Motivo da rejeição do pedido não preenchido","Atenção")) ENABLE OF oDlg
	//	DEFINE SBUTTON FROM 82,160 TYPE 2 ACTION (nOpcao:=2,oDlg:End()) ENABLE OF oDlg
	
	Activate dialog oDlg centered
	
EndDo

If nOpcao == 1
	
	mObsFin := Trim(MSMM(SA1->A1_OBSFINM,60,,,3))
	
	If !empty(mObsFin)
		mObsFin := CR + mObsFin
	EndIf
	
	mObsFin := " Em "+dToc(dDatabase)+" o pedido nro "+Alltrim(M->C9_PEDIDO)+" foi rejeitado. Motivo: "+AllTrim(cGetMotivo)+". " + mObsFin
	
	//Registra a o Motivo do Bloqueio na observação do Cliente.
	RecLock("SA1",.F.)
	If empty(SA1->A1_OBSFINM)
		MSMM(,60,,mObsFin ,1,,,"SA1","A1_OBSFINM")
	Else
		MSMM(SA1->A1_OBSFINM,60,,mObsFin,4,,,"SA1","A1_OBSFINM")
	EndIf
	SA1->(MsUnLock())
	
	Reclock("SC5",.F.)
	SC5->C5_PARCIAL := "N"
	SC5->C5_PRENOTA := "R"   // Eriberto 16/02/2007
	SC5->C5_XBLQNF  := ""
	SC5->(MsUnLock())
	SC5->(DbCommit())  // Eriberto 24/04/07                    
	
	nRecno := SC9->(Recno())
	
	cSQL := "SELECT "
	cSQL += "	R_E_C_N_O_ REC "
	cSQL += "	FROM " 
	cSQL += 		RetSQLName("SC9")
	cSQL += "		WHERE "
	cSQL += "			C9_FILIAL  = '"+cFilSC9+"' AND "
	cSQL += "			C9_PEDIDO  = '"+cPedido+"' AND "
	cSQL += "			C9_NFISCAL = ' ' AND "
	cSQL += "			D_E_L_E_T_ = ' ' "

	cSQL := ChangeQuery(cSQL)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),"TRBSC9",.T.,.T.)
	
	While TRBSC9->(!Eof())	
		SC9->(dbGoTo(TRBSC9->REC))
		
		SC9->(Reclock("SC9",.F.))
			SC9->C9_BLCRED := Iif(SC9->C9_BLCRED $ "01/04","09",SC9->C9_BLCRED)
			SC9->C9_PARCIAL:= SC5->C5_PARCIAL
		SC9->(MsUnLock())		
	
		TRBSC9->(dbSkip())		
	EndDo
	TRBSC9->(dbCloseArea())

	SC9->(dbGoTo(nRecno))	
	
	// Registrando a ocorrencia na Ficha Kardex
	U_DiprKardex(cPedido,U_DipUsr(),cGetMotivo,.T.,"25")// JBS 29/08/2005
	
	// Monta a mensagem a ser enviado ao operador
	cMail := "AVISO IMPORTANTE"+CR+CR
	cMail += "O Pedido "   +Alltrim(SZ9->Z9_PEDIDO)
	cMail += " do Cliente "+AllTrim(SA1->A1_COD)+" - "+AllTrim(SA1->A1_NREDUZ)+CR
	cMail += "Foi rejeitado pelo Crédito."+CR+CR
	cMail += "Motivo: "+cGetMotivo +CR+CR
	cMail += U_DipUsr()
	
	// Envia a mensagem ao operador através do CIC
	u_DIPCIC(cMail,AllTrim(cOpFatDest))//Giovani Zago 09/02/2012 novo cic
	//	WaitRun(cServidor+' '+cOpFatRem+' '+cOpFatSenha+' "'+AllTrim(cOpFatDest)+'" "'+cMail+'" ')
	
	cAssunto := "PEDIDO ESTORNADO - "+SZ9->Z9_PEDIDO
	
	aAdd(aMsg,{"Pedido:   ",Alltrim(SZ9->Z9_PEDIDO) })   
	aAdd(aMsg,{"Cliente:  ",AllTrim(SA1->A1_COD)+" - "+AllTrim(SA1->A1_NREDUZ) })
	aAdd(aMsg,{"Motivo:   ",cGetMotivo })
	aAdd(aMsg,{"Usuário:  ",U_DipUsr() })
	
	U_UEnvMail(cMailDest,cAssunto,aMsg,"",cFrom,cFuncSent) 
	
	
EndIf                 

UnlockByName(cLockPed,.T.,.T.)

DbSelectArea("SC9")

RestArea(aAreaSC9)    

Return(lRetorno)
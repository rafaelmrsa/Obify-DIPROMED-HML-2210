#Include "protheus.ch"
#include "rwmake.ch"
#INCLUDE "AP5MAIL.CH"
#INCLUDE "COLORS.CH"
#DEFINE CR    chr(13)+chr(10) // Carreage Return (Fim de Linha)

Static cPedEst := ""

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ MT460EST ³ Autor ³   Fabio Rogerio       ³ Data ³ 15/09/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Estorna reserva do produto.                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function MT460EST()
Local aArea := GetArea()      
Local aMsg  := {}
Local cQuery:= ""
Local nQtdNF:= 0 
Local cEmailOper  := ""     
Local cHorario := Time()
Local cSuframa := ""


If ISINCALLSTACK("LOJA901A") .Or. ISINCALLSTACK("LOJA901")
	Return
EndIf

 
//-- Nao executo quando eh chamado pela liberação de Crédito
If !("MATA450"$FunName())

	U_DIPPROC(ProcName(0),U_DipUsr()) // JBS 05/10/2005 - Gravando o nome do Programa no SZU
	
	cQuery:= "SELECT Count(DISTINCT C9_NFISCAL) AS QTDNF FROM " + RetSqlName("SC9") + " SC9 WHERE SC9.D_E_L_E_T_ <> '*' AND SC9.C9_PEDIDO = '" + SC9->C9_PEDIDO + "'"
	cQuery:= ChangeQuery(cQuery)
	
	DbCommitAll()
	DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TMP",.T.,.T.)
	nQtdNF:= TMP->QTDNF
	
	TMP->(dbCloseArea())
	
	If (nQtdNF == 0)                   
		SUA->(DbSetOrder(8))
		IF SUA->(DbSeek(xFilial("SUA")+SC9->C9_PEDIDO))
			RecLock("SUA",.F.)
			SUA->UA_STATUS := "SUP"
			SUA->(MsUnLock())
			SUA->(DbCommit())
		EndIF
	EndIf
		
	SC5->(DbSetOrder(1))
	IF SC5->(DbSeek(xFilial("SC5")+SC9->C9_PEDIDO))
		
		IF FunName(0) == "MATA460A"
			If cPedEst != SC5->C5_NUM
				cPedEst := SC5->C5_NUM
				/*====================================================================================\
				| ENVIO DO E-MAIL DE ESTORNO DE PEDIDO COM SUBST. TRIBUTÁRIA INCLUÍDA NA DESPESA      |
				\====================================================================================*/
				/*
				SELECT C5_MENNOTA, U7_EMAIL, A1_COD, A1_LOJA, A1_NOME
				FROM SC5010, SU7010, SA1010
				WHERE C5_NUM = '045582'
				AND C5_OPERADO = U7_COD
				AND C5_CLIENTE = A1_COD
				AND C5_LOJACLI = A1_LOJA
				AND SC5010.D_E_L_E_T_ <> '*'
				AND SU7010.D_E_L_E_T_ <> '*'
				AND SA1010.D_E_L_E_T_ <> '*'
				ORDER BY C5_NUM
				*/
				
				QRY1 := "SELECT C5_MENNOTA, U7_EMAIL, A1_COD, A1_LOJA, A1_NOME "
				QRY1 += " FROM " + RetSQLName("SC5") +", " + RetSQLName("SU7") +", " + RetSQLName("SA1")
				QRY1 += " WHERE C5_NUM = '" + SC9->C9_PEDIDO + "'"
				QRY1 += " AND C5_OPERADO = U7_COD"
				QRY1 += " AND C5_CLIENTE = A1_COD"
				QRY1 += " AND C5_LOJACLI = A1_LOJA"
				QRY1 += " AND " + RetSQLName("SC5") + ".D_E_L_E_T_ <> '*'"
				QRY1 += " AND " + RetSQLName("SU7") + ".D_E_L_E_T_ <> '*'"
				QRY1 += " AND " + RetSQLName("SA1") + ".D_E_L_E_T_ <> '*'"
				QRY1 += " ORDER BY C5_NUM"
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
				
				// PROCESSA QUERY SQL
				DbCommitAll()
				TcQuery QRY1 NEW ALIAS "QRY1"         // ABRE UMA WORKAREA COM O RESULTADO DA QUERY
				
				DbSelectArea("QRY1")
				QRY1->(dbGotop())
				If SubStr(QRY1->C5_MENNOTA,AT('=',QRY1->C5_MENNOTA),5) == "=ST=D"  .AND. Val(Left(SC5->C5_MENNOTA,4)) > 0// TRATANDO ST COM VALOR 0 - MCVN 12/11/09./// VERIFICA SE SUBST. TRIBUTÁRIA ESTÁ INCLUSO NO VALOR DA DESPESA.
					cEmail := "magda.teixeira@dipromed.com.br"				
					cAssunto := EncodeUTF8("CANCELAMENTO - Substituição Tributária - PV-" + SC9->C9_PEDIDO,"cp1252")
					aadd(aMsg,{SC9->C9_PEDIDO, QRY1->U7_EMAIL, QRY1->A1_COD, QRY1->A1_LOJA, QRY1->A1_NOME, ""})
					EMail(cEmail,cAssunto,aMsg)     				
				Endif
			   	// Envia e-mail referente ao estorno de pedido  -  MCVN - 06/12/2007
			   	cEmail := QRY1->U7_EMAIL			
			   	cAssunto := "Estorno de Pedido de venda " + SC9->C9_PEDIDO
			   	aadd(aMsg,{SC9->C9_PEDIDO, QRY1->U7_EMAIL, QRY1->A1_COD, QRY1->A1_LOJA, QRY1->A1_NOME, cHorario})
			    EMail(cEmail,cAssunto,aMsg)  
				cEmailOper := QRY1->U7_EMAIL   
				cHorario := time()
				QRY1->(DBCLOSEAREA())
				///////////////////////////////////////////
				///// FIM DA ROTINA DE ENVIO DE E-MAIL ////
				///////////////////////////////////////////  
				
				//MCVN  18/01/2008
		        /*====================================================================================\
	     		| ENVIO DO E-MAIL DE ESTORNO DE PEDIDO DE CLIENTE COM SUFRAMA                         |
			    \====================================================================================*/
			                                                                                       
			    // ENVIA EMAIL SE CLIENTE TIVER SUFRAMA (PIN-PROTOCOLO DE INTERNAÇÃO DE NOTA FISCAL)  17/01/2008                                                            
			    cSuframa := Posicione('SA1', 1, xFilial('SA1') + SC5->C5_CLIENTE + SC5->C5_LOJACLI, 'A1_SUFRAMA')
			    If  !Empty(cSuframa)
		   		    aMsg := {}
			        EmailOper := Alltrim(Posicione("SU7",1,xFilial("SU7")+SC5->C5_OPERADO,"U7_EMAIL"))
			        NomeCli   := Posicione("SA1",1,xFilial("SA1")+SC5->C5_CLIENTE+SC5->C5_LOJACLI,"A1_NOME")
				    cEmail    := GetNewPar("ES_MAILSUF","magda.teixeira@dipromed.com.br;sirlene.creatto@dipromed.com.br;deoclecio.santos@dipromed.com.br")
	    		    cAssunto  := "CANCELAMENTO - Cliente com Suframa - PV- " + SC5->C5_NUM
				    aadd(aMsg,{SC5->C5_NUM, EmailOper, SC5->C5_CLIENTE, SC5->C5_LOJACLI, NomeCli,""})
	                EMail(cEmail,cAssunto,aMsg)
				EndIf 
				
				//giovani e-mail cancelamento com icms interestadual
				  If SC5->C5_TIPODIP = "1" .And. substr(SC5->C5_XRECOLH,1,3) $ "ACR" 
         
            	    aMsg := {}
			        EmailOper := Alltrim(Posicione("SU7",1,xFilial("SU7")+SC5->C5_OPERADO,"U7_EMAIL"))
			        NomeCli   := Posicione("SA1",1,xFilial("SA1")+SC5->C5_CLIENTE+SC5->C5_LOJACLI,"A1_NOME")
				    cEmail    := Getmv("ES_DIPV4_6")+","+EmailOper
	    		    cAssunto  := "CANCELAMENTO - Pedido com Icms Inter-Estadual - PV- " + SC5->C5_NUM
				    aadd(aMsg,{SC5->C5_NUM, EmailOper, SC5->C5_CLIENTE, SC5->C5_LOJACLI, NomeCli,""})
	                EMail(cEmail,cAssunto,aMsg)
				EndIf
			
				
	  // Executado no ponto de entrada M460DEL 		   
	  /*		dbSelectArea("SDC")
				dbSetOrder(4)
				If !DbSeek(xFilial("SDC")+SC5->C5_NUM)
				
					Reclock("SC5",.F.)
					SC5->C5_PRENOTA := "E"
					SC5->(MsUnLock())
					SC5->(DbCommit())  // Eriberto 24/04/07
				Endif */                      
				
				Mta460CIC(SC5->C5_NUM)   // Envia cic avisando do estorno
			
				
			EndIf
	
		   //	U_DiprKardex(SC9->C9_PEDIDO,U_DipUsr(),"Estornado Item "+SUBS(SC9->C9_PRODUTO,1,6),.T.,"08") // JBS 29/08/2005
		   		U_DiprKardex(SC9->C9_PEDIDO,U_DipUsr(),"Item "+SC9->C9_ITEM+" Seq "+SC9->C9_SEQUEN+" "+SUBS(SC9->C9_PRODUTO,1,6),.T.,"08") // MCVN 18/04/2007
			
		EndIf
		
	EndIf


EndIf

RestArea(aArea)

Return(.T.)                

/*==========================================================================\
|Programa  |EMail   | Autor | Rafael de Campos Falco  | Data ³ 13/01/2005   |
|===========================================================================|
|Desc.     | Envio de EMail                                                 |
|===========================================================================|
|Sintaxe   | EMail                                                          |
|===========================================================================|
|Uso       | Especifico DIPROMED                                            |
\==========================================================================*/

Static Function EMail(cEmail,cAssunto,aMsg,aAttach)

Local cAccount  := Lower(Alltrim(GetMv("MV_RELACNT")))
Local cFrom     := Lower(Alltrim(GetMv("MV_RELACNT")))
Local cPassword := Alltrim(GetMv("MV_RELPSW"))
Local cServer   := Alltrim(GetMv("MV_RELSERV"))
Local cEmailTo  := ""
Local cEmailCc  := ""
Local cEmailBcc := ""
Local lResult   := .F.
Local cError    := ""
Local cMsg      := ""
LOCAL lSmtpAuth := GetNewPar("MV_RELAUTH",.F.)
LOCAL lAutOk	:= .F.

/*=============================================================================*/
/*Definicao do cabecalho do email                                              */
/*=============================================================================*/
cMsg := ""
cMsg += '<html>'
cMsg += '<head>'
cMsg += '<title>' + cAssunto + '</title>'
cMsg += '</head>'
cMsg += '<body>'
cMsg += '<HR Width=85% Size=3 Align=Centered Color=Red> <P>'
cMsg += '<Table Align=Center BorderColor=#000000 CELLPADDING=4 CELLSPACING=0 Width=60%>'

/*=============================================================================*/
/*Definicao do cabecalho do relatório                                          */
/*=============================================================================*/
cMsg += '<table width="100%">'
cMsg += '<tr>'
cMsg += '<td>===============================================================================================================</td>'
cMsg += '</tr>'
cMsg += '</table>'

cMsg += '<table width="100%">'
cMsg += '<tr>'
cMsg += '<td width="100%"><font size="4" color="red">Pedido - ' + aMsg[1,1] + '</font></td>'
cMsg += '</tr>'
cMsg += '<tr>'
cMsg += '<td width="100%"><font size="2" color="Black">Horário - ' + aMsg[1,6] + '</font></td>'
cMsg += '</tr>
cMsg += '<tr>'
cMsg += '<td width="100%"><font size="2" color="blue">Cliente: ' + aMsg[1,3] + '-' + aMsg[1,4] + '-' + aMsg[1,5] + '</font></td>'
cMsg += '</tr>'
cMsg += '<tr>'
cMsg += '<td width="80%" align="center"><font size="4" color="RED">ATENÇÃO O PEDIDO FOI ESTORNADO !</font></td>'
cMsg += '</tr>'
cMsg += '</table>'

cMsg += '<table width="100%">'
cMsg += '<tr>'
cMsg += '<td>===============================================================================================================</td>'
cMsg += '</tr>'
cMsg += '</table>'

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Definicao do rodape do email                                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cMsg += '</Table>'
cMsg += '<HR Width=85% Size=3 Align=Centered Color=Red> <P>'
cMsg += '<table width="100%" Align="Center" border="0">'
cMsg += '<tr align="center">'
cMsg += '<td colspan="10"><font color="BLUE" size="2">Mensagem enviada automaticamente pelo sistema PROTHEUS - <font color="BLUE" size="1">(MT460EST.PRW)</td>'
cMsg += '</tr>'
cMsg += '</table>'
cMsg += '</body>'
cMsg += '</html>'

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Envia o mail para a lista selecionada. Envia como BCC para que a pessoa pense³
//³que somente ela recebeu aquele email, tornando o email mais personalizado.   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
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

Return(.T.)

*--------------------------------------------------------------------------*
Static Function Mta460CIC(cPedido)
// JBS 23/05/2006 - Pedido estornado
*--------------------------------------------------------------------------*
Local lRetorno := .T.
Local cFilSC9  := xFilial("SC9")
Local cMail
Local cServidor   := GetMV("MV_CIC")     // Servidor para enviar mensagem pelo CIC
Local cOpFatRem   := GetMV("MV_REMETCI") // Usuario do CIC remetente de mensgens no Protheus
Local cOpFatSenha := "123456"
Local cOpFatDest  := ""
Local cGetMotivo  := Space(90)
Local nOpcao      := 0
Local lSaida := .f.

If Upper(U_DipUsr()) $ 'ERIBERTO/EELIAS/MCANUTO/DDOMINGOS/VQUEIROZ/VEGON/RBORGES'
   cGetMotivo := "Eriberto - testando melhorias no Protheus."+space(44)
EndIf

//SC9->(DbSeek(cFilSC9+cPedido))  Não é necessário, estava disposicionando o C9 MCVN - 18/04/2007

// Dados do Destinatario da Mensagem CIC
SU7->(dbSetOrder(1))
SU7->(dbSeek(xFilial("SU7")+SC9->C9_OPERADO))
cOpFatDest := SU7->U7_CICNOME

SA1->(dbSetOrder(1))
SA1->(dbSeek(xFilial("SA1") + SC9->C9_CLIENTE + SC9->C9_LOJA))
cObsFin := ""
M->C9_PEDIDO  := SC9->C9_PEDIDO
M->A1_CLIENTE := AllTrim(SC9->C9_CLIENTE)+"-"+SA1->A1_NREDUZ
M->U7_OPERADO := AllTrim(SC9->C9_OPERADO)+"-"+SU7->U7_NREDUZ

Do While !lSaida
	nOpcao := 0
	
	Define msDialog oDlg Title "Estornando Pedido " From 10,10 TO 23,60
	
	@ 001,002 tO 78,196
	
	@ 010,010 say "Pedido  " COLOR CLR_BLACK
	@ 020,010 say "Cliente " COLOR CLR_BLACK
	@ 030,010 say "Operador" COLOR CLR_BLACK
	
	@ 010,050 get M->C9_PEDIDO  when .f. size 050,08
	@ 020,050 get M->A1_CLIENTE when .f. size 120,08
	@ 030,050 get M->U7_OPERADO when .f. size 120,08
	
	@ 050,010 say "Descreva o motivo do estorno: " COLOR CLR_HBLUE
	@ 060,010 get cGetMotivo valid !empty(cGetMotivo) size 165,08
	
	DEFINE SBUTTON FROM 82,130 TYPE 1 ACTION IF(!empty(cGetMotivo),(lSaida:=.T.,nOpcao:=1,oDlg:End()),msgInfo("Motivo do estorno não preenchido","Atenção")) ENABLE OF oDlg
//	DEFINE SBUTTON FROM 82,160 TYPE 2 ACTION (nOpcao:=0,oDlg:End()) ENABLE OF oDlg
	
	Activate dialog oDlg centered

EndDo

	If nOpcao == 1
		
		// Monta a mensagem a ser enviado ao operador
		cMail := "AVISO IMPORTANTE"+CR+CR
		cMail += "O Pedido " +M->C9_PEDIDO
		cMail += " do Cliente "+AllTrim(SA1->A1_COD)+" - "+AllTrim(SA1->A1_NREDUZ)+CR
		cMail += "Foi estornado pelo faturamento."+CR+CR
		cMail += "Motivo: "+cGetMotivo +CR+CR
		cMail += U_DipUsr()
		
		// Envia a mensagem ao operador através do CIC
		U_DIPCIC(cMail,AllTrim(cOpFatDest))// RBorges 12/03/15
//		WaitRun(cServidor+' '+cOpFatRem+' '+cOpFatSenha+' "'+AllTrim(cOpFatDest)+'" "'+cMail+'" ') //RBorges 12/03/15
	EndIf
Return() 


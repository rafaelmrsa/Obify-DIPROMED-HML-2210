#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "FILEIO.CH"
/*==========================================================================\
|Programa  | DIPR099 | Autor | Reginaldo Borges   |      Data ³ 15/02/2019  |
|===========================================================================|
|Desc.     | Envio de EMail dos pedidos parados no financeiro.              |
|===========================================================================|
|Sintaxe   | DIPR099                                                        |
|===========================================================================|
|Uso       | Especifico DIPROMED                                            |
\==========================================================================*/

User Function DIPR099(aWork)

Local lResult   := .F.
Local cError    := ""
Local cMsg      := ""
Local lAutOk	:= .F.
Local CATTACH   := "a"
Local cAssunto  := "Pedidos parados no financeiro!"
Local cSQL      := ""
Local aPedsSZ9  := {}
Local cMSGcIC         := ""

cWCodEmp  := aWork[1]
cWCodFil  := aWork[2]

If ValType(aWork) == 'A'
	PREPARE ENVIRONMENT EMPRESA cWCodEmp FILIAL cWCodFil FUNNAME "DIPR099" TABLES "SZ9"
EndIf

Private cAccount  := Lower(Alltrim(GetMv("MV_RELACNT")))
Private cFrom     := Lower(Alltrim(GetMv("MV_RELACNT")))
Private cPassword := Alltrim(GetMv("MV_RELPSW"))
Private cServer   := Alltrim(GetMv("MV_RELSERV"))
Private lSmtpAuth := GetNewPar("MV_RELAUTH",.F.)
Private nQtdMin   := GetNewPar("ES_R099MIN",5)
Private cCICDest  := UPPER(GetNewPar("ES_R099CIC","LUCIANA.MATIAZZO"))
Private cEmailTo  := Lower(GetNewPar("ES_R099EME","luciana.matiazzo@dipromed.com.br;reginaldo.borges@dipromed.com.br")) 
Private cEmailCc  := ""
Private cEmailBcc := ""


cSQL := "  SELECT  DISTINCT(C9_PEDIDO), C9_FILIAL "
cSQL += " 	FROM "
cSQL +=  		RetSQLName("SC9")  
cSQL += " 		INNER JOIN "
cSQL +=  		RetSQLName("SC5")
cSQL += " 			ON "
cSQL += "		    C5_FILIAL      = C9_FILIAL  AND "
cSQL += "		    C5_PRENOTA     = 'F' AND "      
cSQL += "		    C5_NUM         = C9_PEDIDO  AND "
cSQL += "		    C5_CLIENTE     = C9_CLIENTE AND "
cSQL += "		    C5_LOJACLI     = C9_LOJA    AND "
cSQL += 		    RetSQLName("SC5")+".D_E_L_E_T_ = ' ' "
cSQL += " 		INNER JOIN "
cSQL +=  		RetSQLName("SZ9")
cSQL += " 			ON "
cSQL += "		   Z9_FILIAL = C9_FILIAL AND " 
cSQL += "	       Z9_PEDIDO = C9_PEDIDO AND "
cSQL +=		   RetSQLName("SZ9")+".D_E_L_E_T_ = ' ' "
cSQL += " 		WHERE "
cSQL += "          C9_FILIAL IN ('01','04') AND "
cSQL += "	       C9_BLCRED NOT IN ('','10')  AND "
cSQL +=  		   RetSQLName("SC9")+".D_E_L_E_T_ = ' ' "     
cSQL += " ORDER BY C9_PEDIDO "

cSQL := ChangeQuery(cSQL)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),"QRYSC9",.T.,.T.)

While QRYSC9->(!EOF()) 

	U_VERSZ9(aPedsSZ9,QRYSC9->C9_PEDIDO,QRYSC9->C9_FILIAL)

	QRYSC9->( dbSkip())
END

If Len(aPedsSZ9)> 0

	/*=============================================================================*/
	/*Definicao do cabecalho do email                                              */
	/*=============================================================================*/
	cMsg := ""
	cMsg += '<html>'
	cMsg += '<head>'
	cMsg += '<title>' +cAssunto + '</title>'
	cMsg += '</head>'
	cMsg += '<body>'
	cMsg += '<HR Width=100% Size=3 Align=Centered Color=Red><P>'
	cMsg += '<Table Align=Center BorderColor=#000000 CELLPADDING=4 CELLSPACING=0 Width=100%>'
	
	cMsg += '<table width="100%">'
	cMsg += '<tr>'
	cMsg += '<td width="100%" align="center"><font size="4" color="red"> DIPROMED </font></td>'
	cMsg += '</tr>'
	cMsg += '</table>'
	
	cMsg += '<hr width="100%" size="3" align="center" color="#000000">'
	
	cMsg += '<table width="100%" cellspacing="0" cellpadding="0"><font size="3" >'
	cMsg += '<tr>'
	cMsg += '<td Width="18%"  Align="LEFT"  ><B>Pedido</B></td>'
	cMsg += '<td Width="18%"  Align="LEFT"  ><B>Dt.Liberação</B></td>'
	cMsg += '<td Width="18%" Align="LEFT"  ><B>Hr.Liberação</B></td>'
	cMsg += '<td Width="18%" Align="LEFT"  ><B>Hr.Relatório</B></td>'
	cMsg += '<td Width="18%" Align="LEFT"  ><B>Minutos da Liberação</B></td>'
	cMsg += '<td Width="10%" Align="LEFT"  ><B>Filial do Pedido</B></td>'
	cMsg += '</tr>'
	cMsg += '</font></table>'
	
	cMsg += '<hr width="100%" size="2" align="center" color="#000000">'
	
	For nI := 1 to Len(aPedsSZ9)
		
	nLin := nI
	
		If Mod(nLin,2) == 0
			
			cMsg += '<table width="100%" border="0" cellspacing="0" cellpadding="0">'
			cMsg += '<tr bgcolor="#F8F8FF">'
			cMsg += '<td width="18% " Align="Left"><font  size="2">'+aPedsSZ9[nLin,1]+ '</font></td>'
			cMsg += '<td width="18% " Align="Left"><font  size="2">'+DTOC(STOD(aPedsSZ9[nLin,2]))+ '</font></td>'		
			cMsg += '<td width="18% " Align="Left"><font  size="2" color="Blue">'+aPedsSZ9[nLin,3]+'</font></td>'
			cMsg += '<td width="18% " Align="Left"><font  size="2" color="Blue">'+aPedsSZ9[nLin,4]+'</font></td>'
			cMsg += '<td width="18% " Align="Left"><font  size="2">'+CVALTOCHAR(aPedsSZ9[nLin,5])+ '</font></td>'
			cMsg += '<td width="10% " Align="Left"><font  size="2">'+aPedsSZ9[nLin,6]+ '</font></td>'
			cMsg += '</tr>'
			cMsg += '</table>'
			
		Else
			
			cMsg += '<table width="100%" border="0" cellspacing="0" cellpadding="0">'
			cMsg += '<tr bgcolor="#CCCCCC">'
			cMsg += '<td width="18% " Align="Left"><font  size="2">'+aPedsSZ9[nLin,1]+ '</font></td>'
			cMsg += '<td width="18% " Align="Left"><font  size="2">'+DTOC(STOD(aPedsSZ9[nLin,2]))+ '</font></td>'		
			cMsg += '<td width="18% " Align="Left"><font  size="2" color="Blue">'+aPedsSZ9[nLin,3]+'</font></td>'
			cMsg += '<td width="18% " Align="Left"><font  size="2" color="Blue">'+aPedsSZ9[nLin,4]+'</font></td>'
			cMsg += '<td width="18% " Align="Left"><font  size="2">'+CVALTOCHAR(aPedsSZ9[nLin,5])+ '</font></td>'
			cMsg += '<td width="10% " Align="Left"><font  size="2">'+aPedsSZ9[nLin,6]+ '</font></td>'
			cMsg += '</tr>'
			cMsg += '</table>'
	
			
		EndIf
	
	nLin  += 1
		
	Next
	
	cMsg += '<table width="100%" cellspacing="0" cellpadding="0"><font size="2" color="blue">'
	cMsg += '<tr>'
	cMsg += '<td>==========================================================================================================================================================================================</td>'
	cMsg += '</tr>'
	cMsg += '</font></table>'
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Definicao do rodape do email                                                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cMsg += '</Table>'
	cMsg += '<HR Width=100% Size=3 Align=Centered Color=Red> <P>'
	cMsg += '<table width="100%" Align="Center" border="0">'
	cMsg += '<tr align="center">'
	cMsg += '<td colspan="10"><font color="BLUE" size="2">Mensagem enviada automaticamente pelo sistema PROTHEUS - <font color="BLUE" size="1">(DIPR099.PRW)</td>'
	cMsg += '</tr>'
	cMsg += '</table>'
	cMsg += '</body>'
	cMsg += '</html>'
	
	cMSGcIC := 'AVISO - PEDIDOS LIBERADOS PARADOS NO FINANCEIRO!' +CHR(13)+CHR(10)+CHR(13)+CHR(10)
	cMSGcIC       += " POR FAVOR VERIFICAR CAIXA DE E-MAIL. " +CHR(13)+CHR(10)

	/*
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
				
				MsgInfo(cError,OemToAnsi("Atencao"))
			EndIf
			
			DISCONNECT SMTP SERVER
		Else
			//Erro na conexao com o SMTP Server
			GET MAIL ERROR cError
			
			MsgInfo(cError,OemToAnsi("Atencao"))
		EndIf
	*/
	  
	If GetNewPar("ES_ATIVJOB",.T.)   
		U_UEnvMail(AllTrim(cEmailTo),cAssunto,nil,"",cFrom,"DIPR099.prw)",cMsg)
		U_DIPCIC(cMSGcIC,cCICDest)
	EndIf
	

	
EndIf

QRYSC9->(DBCloseArea())

Return(.T.)

/*==================================================
  Verifica se o pedido está parado no financeiro.
====================================================*/
User Function VERSZ9(aPedsSZ9,_cPedido,_cFilial)
Local cSQL := ""

cSQL := " SELECT "
cSQL += " 	DISTINCT TOP(1)(Z9_PEDIDO), Z9_DATAMOV, Z9_HORAMOV, (CONVERT(VARCHAR(8),GETDATE(),114)) 'HORA_REL',DATEDIFF(MI,Z9_HORAMOV,(CONVERT(VARCHAR(8),GETDATE(),114))) AS 'DIFERENCA', Z9_OCORREN, R_E_C_N_O_ "
cSQL += " 	FROM "
cSQL +=  		RetSQLName("SZ9")
cSQL += " 	WHERE "
cSQL += "		   Z9_FILIAL = '"+_cFilial+"' AND " 
cSQL += "	       Z9_PEDIDO = '"+_cPedido+"' AND "
cSQL += "	       Z9_OCORREN = '10' AND "
cSQL += "	       Z9_DATAMOV = (CONVERT(VARCHAR(8),GETDATE(),112)) AND "
cSQL += "	       DATEDIFF(MI,Z9_HORAMOV,(CONVERT(VARCHAR(8),GETDATE(),114))) >= 4 AND "
cSQL +=		   RetSQLName("SZ9")+".D_E_L_E_T_ = ' ' "
cSQL += "ORDER BY R_E_C_N_O_ DESC "
cSQL := ChangeQuery(cSQL)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),"cSQLSZ9",.T.,.T.)

If cSQLSZ9->(!EOF()) .And. cSQLSZ9->DIFERENCA >= nQtdMin
	If _cFilial == '01'
		aadd(aPedsSZ9,{cSQLSZ9->Z9_PEDIDO,cSQLSZ9->Z9_DATAMOV,cSQLSZ9->Z9_HORAMOV,cSQLSZ9->HORA_REL,cSQLSZ9->DIFERENCA,"MTZ"})
	Else
		aadd(aPedsSZ9,{cSQLSZ9->Z9_PEDIDO,cSQLSZ9->Z9_DATAMOV,cSQLSZ9->Z9_HORAMOV,cSQLSZ9->HORA_REL,cSQLSZ9->DIFERENCA,"CD"})
	EndIf
EndIf

cSQLSZ9->(DBCloseArea())

Return (aPedsSZ9)


#INCLUDE "Protheus.ch"
#include "rwmake.ch"
#Include "Ap5Mail.ch"
/*====================================================================================\
|Programa  |   MTA242IN                     | Autor | GIOVANI.ZAGO| Data | 15/09/2011 |
|=====================================================================================|
|Descrição | envia e-mail                                                             |
|          |                                                                          |
|          |                                                                          |
|=====================================================================================|
|Sintaxe   |                                                                          |
|=====================================================================================|
|Uso       | Especifico DIPROMED                                                      |
|=====================================================================================|
|........................................Histórico....................................|
\====================================================================================*/
*---------------------------------------------------*
User Function MTA242IN ( )
*---------------------------------------------------*
Local _xArea    := GetArea()
Local lRet      := .T.
//Local CCodProd  := aCols[n,1] Variável retirada pois não é utilizada no fonte. 
Local cEmail	:= If(cEmpAnt+cFilAnt=='0401',"vendas@healthquality.ind.br","lourival.nunes@dipromed.com.br;armazenamento@dipromed.com.br")
Local cAssunto	:= "Desmontagem de Produto"
Local aMsg		:= {}
Local aMsg2		:= {}
Local aMsg3		:= {}
Local cAttach	:= ""
Local cDe		:= Lower(Alltrim(GetMv("MV_RELACNT")))
Local cFuncSent := "MTA242IN"
Local n         := 0
If ("MATA242") $ FunName()
	aAdd( aMsg, {"Produto",cProduto})
	aAdd( aMsg, {"Lote",cLoteDigi})
	aAdd( aMsg, {"Armazem",cLocaliza})
	aAdd( aMsg, {"Documento",cDocumento})
	aAdd( aMsg, {"Usuario",__cUserId +" / " +  cUserName })
	aAdd( aMsg2, {"Produtos Gerados:",cvaltochar(len(aCols))})
	aAdd( aMsg3, {"Produto","Quantidade","Lote","Validade","Localização"})
	For n:= 1 To len(aCols)
		
		aAdd( aMsg3, {aCols[n,1] ,cvaltochar(aCols[n,2]),aCols[n,8] ,dtoc(aCols[n,10]),aCols[n,11]  })
		
		
	next n
	
	
	
	MailDes(cEmail,cAssunto,aMsg,cAttach,cDe,cFuncSent,aMsg2,aMsg3) 
	
	
	
	
EndIf

RestArea(_xArea)
Return(lRet)



//**************************************************************************************************************
Static Function MailDes(cEmail,cAssunto,aMsg,cAttach,cDe,cFuncSent,aMsg2,aMsg3)

Local cAccount  := Lower(Alltrim(GetMv("MV_RELACNT")))
Local cFrom     := Lower(Alltrim(GetMv("MV_RELACNT")))
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
	_nLin := 0
	For _nLin := 1 to Len(aMsg2)
		IF (_nLin/2) == Int( _nLin/2 )
			cMsg += '<TR BgColor=#B0E2FF>'
		Else
			cMsg += '<TR BgColor=#FFFFFF>'
		EndIF
		cMsg += '<TD><B><Font Color=#000000 Size="3" Face="Arial">' + aMsg2[_nLin,1] + ' </Font></B></TD>'
		cMsg += '<TD><B><Font Color=#000000 Size="3" Face="Arial">' + aMsg2[_nLin,2] + '  </Font></B></TD>'
		cMsg += '</TR>'
	Next
	_nLin := 0
	For _nLin := 1 to Len(aMsg3)
		If _nLin = 1
			IF (_nLin/2) == Int( _nLin/2 )
				cMsg += '<TR BgColor=#B0E2FF>'
			Else
				cMsg += '<TR BgColor=#FFFFFF>'
			EndIF
			cMsg += '<TD><B> <Font Color=#000000 Size="3" Face="Arial">' + aMsg3[_nLin,1] + '</Font></B></TD>'
			cMsg += '<TD><B> <Font Color=#000000 Size="3" Face="Arial">' + aMsg3[_nLin,2] + ' </Font></B></TD>'
			cMsg += '<TD><B> <Font Color=#000000 Size="3" Face="Arial">' + aMsg3[_nLin,3] + ' </Font></B></TD>'
			cMsg += '<TD><B> <Font Color=#000000 Size="3" Face="Arial">' + aMsg3[_nLin,4] + '</Font></B></TD>'
			cMsg += '<TD><B> <Font Color=#000000 Size="3" Face="Arial">' + aMsg3[_nLin,5] + '</Font></B></TD>'
			cMsg += '</TR>'
			
		else
			
			IF (_nLin/2) == Int( _nLin/2 )
				cMsg += '<TR BgColor=#B0E2FF>'
			Else
				cMsg += '<TR BgColor=#FFFFFF>'
			EndIF
			cMsg += '<TD> <Font Color=#000000 Size="2" Face="Arial">' + aMsg3[_nLin,1] + ' </Font></TD>'
			cMsg += '<TD> <Font Color=#000000 Size="2" Face="Arial">' + aMsg3[_nLin,2] + ' </Font></TD>'
			cMsg += '<TD> <Font Color=#000000 Size="2" Face="Arial">' + aMsg3[_nLin,3] + ' </Font></TD>'
			cMsg += '<TD> <Font Color=#000000 Size="2" Face="Arial">' + aMsg3[_nLin,4] + ' </Font></TD>'
			cMsg += '<TD> <Font Color=#000000 Size="3" Face="Arial">' + aMsg3[_nLin,5] + ' </Font></TD>'
			cMsg += '</TR>'
			
		EndIF
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
			
			MsgInfo(cError,OemToAnsi("Aten‡„o"))
		EndIf
		
		DISCONNECT SMTP SERVER
	Else
		//Erro na conexao com o SMTP Server
		GET MAIL ERROR cError
		
		MsgInfo(cError,OemToAnsi("Aten‡„o"))
	EndIf
ENDIF
Return(.T.)


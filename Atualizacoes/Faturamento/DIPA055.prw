#INCLUDE "Protheus.ch"
#INCLUDE "RWMAKE.CH"
#INCLUDE "Ap5Mail.CH"
#DEFINE CR    chr(13)+chr(10)

/*====================================================================================\
|Programa  | DIPA055       | Autor | GIOVANI.ZAGO               | Data | 15/12/2011   |
|=====================================================================================|
|Descrição | axcadastro clientes AMCOR                                                |
|          |                                                                          |
|          |                                                                          |
|=====================================================================================|
|Sintaxe   | DIPA055                                                                  |
|=====================================================================================|
|Uso       | Especifico DIPROMED-Licitação                                            |
|=====================================================================================|
|........................................Histórico....................................|
\====================================================================================*/
*--------------------------------------------------------------------------*
User Function DIPA055()
*--------------------------------------------------------------------------*

Local _aArea          	 := GetArea()
Private _aCamSzn   := {}
//AxCadastro("DAU",OemToAnsi(STR0001),'Os050Vdel()',"Os050TOK()",/*aRotAdic*/,/*bPre*/,/*bOK*/,{|| OS050Grv(IIf(INCLUI,3,IIF(ALTERA,4,5))) })//"Cadastro de Ajudantes"
   
If !(AllTrim(Upper(U_DipUsr())) $ 'MCANUTO/BRODRIGUES/DDOMINGOS/VQUEIROZ/RBORGES')
	MSGSTOP("Sem acesso","Usuario sem autorizacao!")
	Return
EndIf

AxCadastro("SZN","Clientes AMCOR",,,,{||_aCamSzn:= DIPATOK(IIf(INCLUI,3,IIF(ALTERA,4,5)),_aCamSzn) }     ,,{|| DIPAGrv(IIf(INCLUI,3,IIF(ALTERA,4,5)),_aCamSzn) })
RestArea(_aArea)

Return



*--------------------------------------------------------------------------*
Static Function DIPAGrv(nopc,_aCamSzn)
*--------------------------------------------------------------------------*
Local cMail       := ""
Local cOpFatDest  := GetMv("ES_DIP55_1")
Local cEmail      := GetMv("ES_DIP55_2")//"GIOVANI.ZAGO@DIPROMED.COM.BR"
Local cAssunto    := ""
Local cAttach     := ""
Local cDe         := ""
Local cFuncSent   := "DIPA055.PRW"
Local i			  := 0

If nopc = 3
	_aCamSzn:= DIPATOK(3,{})
	Begin transaction
	Reclock("SZN",.F.)
	SZN->ZN_XINCLUS := Upper(U_DipUsr())
	SZN->(MsUnLock())
	SZN->(DbCommit())
	End Transaction
	
	cAssunto:= EncodeUTF8("Inclusão na Tabela de Exceções de Cliente AMCOR","cp1252")
	U_MailAmcor(cEmail,cAssunto,_aCamSzn,cAttach,cDe,cFuncSent)
	
	
	cMail := "AVISO IMPORTANTE"+CR
	cMail += "Foi Cadastrado na Tabela de Exceções da AMCOR:"+ CR + CR
	For i:=1  To Len(_aCamSzn)
		cMail +=   alltrim(_aCamSzn[i,1]) +" : "+alltrim(_aCamSzn[i,2]) + CR
	Next i
	cMail +=CR + "Pelo usuario: "+Upper(U_DipUsr())
	
	U_DIPCIC(cMail,cOpFatDest)//envia cic
	
ElseIf nopc = 4
	
	Begin transaction
	Reclock("SZN",.F.)
	SZN->ZN_XALTERA := Upper(U_DipUsr())
	SZN->(MsUnLock())
	SZN->(DbCommit())
	End Transaction
	
	_aCamSzn:=	DIPAALT(nopc,_aCamSzn)
	cAssunto:= EncodeUTF8("Alteração na Tabela de Exceções de Cliente AMCOR","cp1252")
	U_MailAmcor(cEmail,cAssunto,_aCamSzn,cAttach,cDe,cFuncSent)
	
	//	If Empty(alltrim(SZN->ZN_XINCLUS))
	cMail := "AVISO IMPORTANTE"+CR+CR
	cMail += "Foi Alterado na Tabela de Exceções da AMCOR"+ CR + CR
	For i:=1  To Len(_aCamSzn)
		cMail +=   alltrim(_aCamSzn[i,1]) + "         :          " + alltrim(_aCamSzn[i,2])  + CR
	Next i

	U_DIPCIC(cMail,cOpFatDest)
	
	//	EndIf
EndIf
_aCamSzn:={}
Return



*--------------------------------------------------------------------------*
Static Function DIPATOK(nopc,_aCamSzn)
*--------------------------------------------------------------------------*

If  nopc = 3  .Or. nopc = 4
	
	aAdd( _aCamSzn , {"CNPJ"          , Transform(SZN->ZN_XCNPJ,PicPesFJ(RetPessoa(SZN->ZN_XCNPJ)))    } )
	aAdd( _aCamSzn , {"CLIENTE"       , SZN->ZN_XCLIENT  } )
	aAdd( _aCamSzn , {"COD. MUNICIPIO", SZN->ZN_XCODMUN  } )
	aAdd( _aCamSzn , {"MUNICIPIO"     , SZN->ZN_XCIDADE  } )
	aAdd( _aCamSzn , {"PGC"           , SZN->ZN_XPGC     } )
	aAdd( _aCamSzn , {"LIMPEZA"       , SZN->ZN_XLIMPEZ  } )
	aAdd( _aCamSzn , {"ESTERELIZAÇÃO" , SZN->ZN_XESTERE  } )
	aAdd( _aCamSzn , {"CREPADO"       , SZN->ZN_XCREPAD  } )
	aAdd( _aCamSzn , {"OPERADOR"      , Upper(U_DipUsr())  } )
	
EndIf
Return(_aCamSzn)

*--------------------------------------------------------------------------*
Static Function DIPAALT(nopc,_aCamSzn)
*--------------------------------------------------------------------------*
Local _aCompAr :={}

aAdd( _aCompAr , {"SITUAÇÃO"           ,"ATUAL"              , "ANTERIOR"    } )
aAdd( _aCompAr , {"CNPJ"               ,Transform(M->ZN_XCNPJ,PicPesFJ(RetPessoa(SZN->ZN_XCNPJ)))     , alltrim(_aCamSzn[1,2])    } )
aAdd( _aCompAr , {"CLIENTE"            ,M->ZN_XCLIENT        , alltrim(_aCamSzn[2,2])  } )
aAdd( _aCompAr , {"COD. MUNICIPIO"     ,M->ZN_XCODMUN        , alltrim(_aCamSzn[3,2])  } )
aAdd( _aCompAr , {"MUNICIPIO"          ,M->ZN_XCIDADE        , alltrim(_aCamSzn[4,2])  } )
aAdd( _aCompAr , {"PGC"                ,M->ZN_XPGC           , alltrim(_aCamSzn[5,2])  } )
aAdd( _aCompAr , {"LIMPEZA"            ,M->ZN_XLIMPEZ        , alltrim(_aCamSzn[6,2])  } )
aAdd( _aCompAr , {"ESTERELIZAÇÃO"      ,M->ZN_XESTERE        , alltrim(_aCamSzn[7,2])  } )
aAdd( _aCompAr , {"CREPADO"            ,M->ZN_XCREPAD        , alltrim(_aCamSzn[8,2])  } )
aAdd( _aCompAr , {"OPERADOR"           , Upper(U_DipUsr()) , " "                     } )

_aCamSzn:={}
_aCamSzn:= _aCompAr
_aCompAr:={}
Return(_aCamSzn)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ mail     º Autor ³   Giovani Zago   º Data ³  16/12/11     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Envio de email                                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function MailAmcor(cEmail,cAssunto,aMsg,cAttach,cDe,cFuncSent)

Local cAccount  := Lower(Alltrim(GetMv("MV_RELACNT")))
Local cFrom     := Lower(Alltrim(GetMv("MV_RELACNT")))
Local cPassword := Alltrim(GetMv("MV_RELPSW"))
Local cServer   := Alltrim(GetMv("MV_RELSERV"))
Local cEmailTo  := ""
Local cEmailCc  := ""
Local cEmailBcc := ""//"relatorios@dipromed.com.br"
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
		If ALLTRIM(aMsg[1,2]) = "ATUAL"
			cMsg += '<TD> <Font Color=#000000 Size="2" Face="Arial">' + aMsg[_nLin,3] + ' </Font></TD>'
		EndIf
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


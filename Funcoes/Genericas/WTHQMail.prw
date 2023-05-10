#INCLUDE "PROTHEUS.CH"
#INCLUDE "AP5MAIL.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³NOVO6     ºAutor  ³Microsiga           º Data ³  03/03/15   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function WTHQMail()     
Local cCodAnt := ""
Local aMsg 	  := {}
Local aDipDel := {} 
Local cHtml	  := ""
                    
RpcSetEnv("04","01",,,'FAT',, )

ConOut( dtoc( Date() )+" "+Time()+" Iniciando o job HQ Mail...." )   

//While !KillApp()              
	ConOut( dtoc( Date() )+" "+Time()+" Processando Job HQ Mail...." )   
	cCodAnt := ""      
	aDipDel := {}
	ZZI->(dbSetOrder(1))
	ZZI->(dbGoTop())
	While !ZZI->(Eof())
		If ZZI->ZZI_CODMSG <> cCodAnt 
			cEmail 	 := AllTrim(ZZI->ZZI_EMAIL)+AllTrim(ZZI->ZZI_EMAIL2)
			cAssunto := AllTrim(ZZI->ZZI_ASSUNT)
			cAttach  := AllTrim(ZZI->ZZI_ANEXO)
			cDe 	 := AllTrim(ZZI->ZZI_MAILDE)
		 	cFuncSent:= AllTrim(ZZI->ZZI_FUNCAO)
		 	aMsg 	 := {}    
		 	cHtml 	 := ""
		EndIf                                    
		
		If !Empty(ZZI->ZZI_HTML)
			cHtml := MSMM(ZZI->ZZI_HTML)
		Else		
			aAdd(aMsg,{ZZI->ZZI_MSG1,ZZI->ZZI_MSG2})
		EndIf
		cCodAnt := ZZI->ZZI_CODMSG 
		
		ZZI->(dbSkip())              
		
		If ZZI->ZZI_CODMSG <> cCodAnt .Or. ZZI->(Eof())
			u_DipEnvMail(cEmail,cAssunto,aMsg,cAttach,cDe,cFuncSent,cHtml)
			aAdd(aDipDel,cCodAnt)
		EndIf
	EndDo
		         
	If Len(aDipDel)>0            
		u_DipDelZZI(aDipDel)
	EndIf
	
//	Sleep(30000)
//Enddo    

Return      
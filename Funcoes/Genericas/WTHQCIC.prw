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
User Function WT_HQCIC()     
Local cCodAnt := ""
Local aMsg 	  := {}
Local aDipDel := {}
Local cServidor := ""
                    
RpcSetEnv("04","01",,,'FAT',, )

ConOut( dtoc( Date() )+" "+Time()+" Iniciando o job HQ CIC...." )   

//While !KillApp()              
	ConOut( dtoc( Date() )+" "+Time()+" Processando Job HQ CIC...." )   
	cCodAnt := ""              
	aDipDel := {}
	dbSelectArea("ZZJ")
	ZZJ->(dbSetOrder(1))
	ZZJ->(dbGoTop())
	While !ZZJ->(Eof())
		Conout("Achou CIC")
		
		cCIC 	  := AllTrim(ZZJ->ZZJ_CIC)+AllTrim(ZZJ->ZZJ_CIC2)
		cMsg	  := AllTrim(ZZJ->ZZJ_MSG)+AllTrim(ZZJ->ZZJ_MSG2)
		
//		If !("totvsrmt.ini"$ZZJ->ZZJ_REMOTE)
			cServidor   := GetMV("MV_CIC")
/*		Else
			cServidor   := GetMV("ES_CICEXTE")    // envia cic se o acesso for via RemoteActivex
		EndIf
*/                 
		Conout(cServidor)
		If !Empty(cCIC)
			u_DipEnvCIC(cMsg,cCIC,cServidor)          
		EndIf
		                             
		Conout("Deletou Msg: "+ZZJ->ZZJ_CODMSG )
		ZZJ->(RecLock("ZZJ",.F.))
			ZZJ->(dbDelete())
		ZZJ->(MsUnLock())
		
		
		ZZJ->(dbSkip())              
	EndDo
		         
//	Sleep(30000)
//Enddo    

Return  
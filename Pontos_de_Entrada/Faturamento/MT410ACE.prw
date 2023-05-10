#INCLUDE "PROTHEUS.CH"
#include "FWMVCDEF.CH"
#include "topconn.ch"
#include "tbiconn.ch"
#include "Totvs.ch"
#include "rwmake.ch"

User Function MT410ACE()     
Local nOpc 		:= PARAMIXB[1]
Local aAreaSZR 	:= SZR->(GetArea())
//Local aAreaZZK 	:= ZZK->(GetArea()) //Rafael
Local lRet 		:= .T.                       
Local cNumero	:= ""       
Local cMsg		:= ""

If Type("l410Auto")<>"U" .And. l410Auto
	Return lRet
EndIf             

If nOpc == 4
	SZR->(dbSetOrder(3))
	If SZR->(dbSeek(xFilial("SRZ")+SC5->C5_NUM)) .And. AllTrim(SZR->ZR_STATUS) == "AGUARDANDO"   
		If Aviso("Atenção","O pedido está em processo de aprovação. Deseja estornar a solicitação?",{"Sim","Não"},1)==1
			cNumero := SZR->ZR_NUMERO
			If LockByName("AVALIANDO "+cNumero,.T.,.F.)
				SC5->(RecLock("SC5",.F.))
					SC5->C5_XSTATUS := ""	
				SC5->(MsUnLock())
				SZR->(RecLock("SZR",.F.))
					SZR->(dbDelete())
				SZR->(MsUnLock())
				UnLockByName("AVALIANDO "+cNumero,.T.,.F.)				

				cMsg += "### ATENÇÃO ###"+CHR(10)+CHR(13)
				cMsg += CHR(10)+CHR(13)
				cMsg += "O pedido "+SC5->C5_NUM+" foi retirado da aprovação digital a pedido da vendedora."+CHR(10)+CHR(13)
				cMsg += CHR(10)+CHR(13)
				cMsg += AllTrim(u_DipUsr())

				U_DIPCIC(cMsg,GetNewPar("ES_D410ACE","ERICH.PONTOLDIO,PATRICIA.MENDONCA,DIEGO.DOMINGOS,MAXIMO.CANUTO"))
			Else
				Aviso("Atenção","O pedido está sendo analisado neste momento. Não será permitido alterá-lo.",{"Ok"},1)
				lRet := .F.		
			EndIf
		ELse
			lRet := .F.		
		EndIf
	EndIf
	
	If !Empty(SC5->C5_XAVARES) 
		If Aviso("Atenção","O pedido está em processo de aprovação de reserva. Deseja estornar a solicitação?",{"Sim","Não"},1)==1
			cNumero := SC5->C5_NUM
			If LockByName("AVALIANDO "+cNumero,.T.,.F.)
				SC5->(RecLock("SC5",.F.))
					SC5->C5_XAVARES := ""	
				SC5->(MsUnLock())
				UnLockByName("AVALIANDO "+cNumero,.T.,.F.)				
			
				cMsg += "### ATENÇÃO ###"+CHR(10)+CHR(13)
				cMsg += CHR(10)+CHR(13)
				cMsg += "O pedido "+SC5->C5_NUM+" foi retirado da aprovação de reserva a pedido da vendedora."+CHR(10)+CHR(13)
				cMsg += CHR(10)+CHR(13)
				cMsg += AllTrim(u_DipUsr())

				U_DIPCIC(cMsg,GetNewPar("ES_D410ACE","ERICH.PONTOLDIO,PATRICIA.MENDONCA,DIEGO.DOMINGOS,MAXIMO.CANUTO"))                                         
			Else
				Aviso("Atenção","O pedido está sendo analisado neste momento. Não será permitido alterá-lo.",{"Ok"},1)
				lRet := .F.		
			EndIf
		Else
			lRet := .F.					
		EndIf
	EndIf
	
	If lRet
		U_DIPV004(SC5->C5_CLIENTE,SC5->C5_LOJACLI,'1',.T.)   

		//Rafael Moraes Rosa - 15/02/2023 - INICIO
		IF SZR->(dbSeek(xFilial("SRZ")+SC5->C5_NUM))
			IF U_VldDtAprov(xFilial("SC5"),SC5->C5_NUM) <> DATE() .AND. (AllTrim(SZR->ZR_STATUS) = "APROVADO") 

				//Aviso("Atenção","Pedido com data de aprovação expirada. A aprovação será estornada.",{"Ok"},1)
				FWAlertWarning("Pedido com data de aprovação expirada. A aprovação será estornada.", "Atenção")

					SC5->(RecLock("SC5",.F.))
						SC5->C5_XSTATUS := ""	
					SC5->(MsUnLock())
					SZR->(RecLock("SZR",.F.))
						SZR->(dbDelete())
					SZR->(MsUnLock())

					//Instrucao de dbDelete na tabela ZZK nao esta operando
					/*
					ZZK->(dbSetOrder(1))
					ZZK->(dbSeek(xFilial("ZZK")+SC5->C5_NUM))
					ZZK->(RecLock("ZZK",.F.))
						ZZK->(dbDelete())
					ZZK->(MsUnLock())
					*/
					//Substituido pela instrucao SQL

					Begin Transaction
						cQuery := "UPDATE "+RetSqlName("ZZK")+ " SET D_E_L_E_T_ = '*', R_E_C_D_E_L_ = R_E_C_N_O_ "
						cQuery += "WHERE D_E_L_E_T_ = '' AND ZZK_FILIAL = '" + xFilial("SC5") + "' "
						cQuery += "AND ZZK_PEDIDO  = '" + SC5->C5_NUM + "'"
						nErro := TcSqlExec(cQuery)
						
						If nErro != 0
							MsgStop("Erro na execução da query: "+TcSqlError(), "Atenção")
							DisarmTransaction()
						EndIf
					End Transaction

					cMsg += "### ATENÇÃO ###"+CHR(10)+CHR(13)
					cMsg += CHR(10)+CHR(13)
					cMsg += "O pedido "+SC5->C5_NUM+" foi retirado da aprovação digital pela data da aprovação expirada."+CHR(10)+CHR(13)
					cMsg += CHR(10)+CHR(13)
					cMsg += AllTrim(u_DipUsr())

					U_DIPCIC(cMsg,GetNewPar("ES_D410ACE","ERICH.PONTOLDIO,PATRICIA.MENDONCA,DIEGO.DOMINGOS,MAXIMO.CANUTO"))

			ENDIF
		
		//Rafael Moraes Rosa - 16/02/2023 - INICIO
		ELSE
			IF U_VldDtAprov(xFilial("SC5"),SC5->C5_NUM) <> DATE() .AND. (EMPTY(SC5->C5_XSTATUS) .AND. (SC5->C5_PRENOTA = 'E' .OR. SC5->C5_PRENOTA = 'O'))

				DbSelectArea("ZZK")
				ZZK->(dbSetOrder(1))
					IF ZZK->(dbSeek(xFilial("ZZK")+SC5->C5_NUM))
						
						//Aviso("Atenção","Pedido com data de aprovação expirada. A aprovação será estornada.",{"Ok"},1)
						FWAlertWarning("Pedido com data de aprovação expirada. A aprovação será estornada.", "Atenção")

						Begin Transaction
								cQuery := "UPDATE "+RetSqlName("ZZK")+ " SET D_E_L_E_T_ = '*', R_E_C_D_E_L_ = R_E_C_N_O_ "
								cQuery += "WHERE D_E_L_E_T_ = '' AND ZZK_FILIAL = '" + xFilial("SC5") + "' "
								cQuery += "AND ZZK_PEDIDO  = '" + SC5->C5_NUM + "'"
								nErro := TcSqlExec(cQuery)
								
								If nErro != 0
									MsgStop("Erro na execução da query: "+TcSqlError(), "Atenção")
									DisarmTransaction()
								EndIf
						End Transaction

							cMsg += "### ATENÇÃO ###"+CHR(10)+CHR(13)
							cMsg += CHR(10)+CHR(13)
							cMsg += "O pedido "+SC5->C5_NUM+" foi retirado da aprovação digital pela data da aprovação expirada."+CHR(10)+CHR(13)
							cMsg += CHR(10)+CHR(13)
							cMsg += AllTrim(u_DipUsr())

							U_DIPCIC(cMsg,GetNewPar("ES_D410ACE","ERICH.PONTOLDIO,PATRICIA.MENDONCA,DIEGO.DOMINGOS,MAXIMO.CANUTO"))
					ENDIF
				ZZK->(DbSkip())   
			ENDIF
		//Rafael Moraes Rosa - 16/02/2023 - FIM
		ENDIF
		//Rafael Moraes Rosa - 15/02/2023 - FIM

	EndIf
EndIf

RestArea(aAreaSZR)
//RestArea(aAreaZZK)
	
Return lRet

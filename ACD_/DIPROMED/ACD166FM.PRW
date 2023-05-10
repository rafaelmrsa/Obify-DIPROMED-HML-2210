#INCLUDE "PROTHEUS.CH" 
#INCLUDE "APVT100.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ACD166VL  ºAutor  ³Microsiga           º Data ³  11/19/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function ACD166FM()  
Local aAreaCB7 := CB7->(GetArea())  
Local aTela    := {}  
Local cExped   := Space(120)
Local cPedido  := CB7->CB7_PEDIDO
Local cOrdSep  := CB7->CB7_ORDSEP
Local cTipo    := CB7->CB7_XTM      
Local cTipoTM  := CB7->CB7_XTOUM
Local cOrigem  := CB7->CB7_ORIGEM
Local lSeparado:= .T.                     
Local cSep 	   := ""   
Local _lRet    := .F.
	    
aTela   := VTSave()	
VTClear()     

if cOrigem <> '3'

	If !Empty(CB7->CB7_TRANSP)
		@ 0,0 VTSay "Pedido da Transp.:"
		@ 1,0 VtSay CB7->CB7_TRANSP
		@ 2,0 VtSay Posicione("SA4",1,xFilial("SA4")+CB7->CB7_TRANSP,"A4_NREDUZ")
		@ 4,0 VTPause "Enter para continuar"
	
		VTClear()     
	EndIf
	ZZ8->(dbSetOrder(1))
	ZZ5->(dbSetOrder(1))
	If ZZ5->(dbSeek(xFilial("ZZ5")+cPedido))
		If Empty(ZZ5->ZZ5_EXPED1) .Or. CB7->CB7_XTM == "M"
			While Empty(cExped)
				@ 0,0 VtSay "Informe o numero da"
				@ 1,0 VtSay "expedicao. (Se foi "
				@ 2,0 VtSay "utilizada mais de "
				@ 3,0 VtSay "uma expedicao, 
				@ 4,0 VtSay	"informe os codigos "
				@ 5,0 VtSay	"separados por /. "
				@ 6,0 VtSay	"Ex.: 001/002)"
				@ 7,0 VtGet cExped Pict "@!"
				
				VTRead
			EndDo
		Else 
			If !VTYesNo("Confirma a expedição?"+chr(10)+chr(13)+ZZ5->ZZ5_EXPED1,"Atenção",.T.) 
				While Empty(cExped)
					@ 0,0 VtSay "Informe o numero da"
					@ 1,0 VtSay "expedicao. (Se foi "
					@ 2,0 VtSay "utilizada mais de "
					@ 3,0 VtSay "uma expedicao, 
					@ 4,0 VtSay	"informe os codigos "
					@ 5,0 VtSay	"separados por /. "
					@ 6,0 VtSay	"Ex.: 001/002)"
					@ 7,0 VtGet cExped Pict "@!"
									
					VTRead
				EndDo		
			EndIf						
		EndIf
	
		CB7->(dbSetOrder(2))     
		If CB7->(dbSeek(xFilial("CB7")+cPedido)) 
			While !CB7->(Eof()) .And. CB7->CB7_PEDIDO = cPedido 
			    
				If lSeparado
			   		lSeparado := CB7->CB7_STATUS >= "2"   
			 	EndIf
			 			
				CB7->(dbSkip())
			EndDo
		EndIf
		
		If lSeparado .Or. !Empty(cExped)
			ZZ5->(RecLock("ZZ5",.F.))
				If !Empty(cExped)      
					If cTipo == "M"                 
						ZZ5->ZZ5_EXPEDM := cExped   
					Else
						ZZ5->ZZ5_EXPED1 := cExped   
					EndIf
				EndIf
				If lSeparado
					ZZ5->ZZ5_STATUS := "2"
				EndIf  
				cSep := POSICIONE("CB9",1,xFilial("CB9")+cOrdSep,"CB9_CODSEP")                            
				ZZ5->ZZ5_SEPARA := POSICIONE("CB1",1,xFilial("CB1")+cSep,"CB1_XCODSC") 
			ZZ5->(MsUnlock())		
		EndIf                
		
		If lSeparado .And. AllTrim(cTipoTM)<>"M"
			If (_lRet:=u_DpCxFACD(cPedido))
				u_UACDV167(_lRet)
			EndIf
		EndIf
	ElseIf ZZ8->(dbSeek(xFilial("ZZ8")+CB7->CB7_XREQMT))
		While Empty(cExped)
			@ 0,0 VtSay "Informe o numero da"
			@ 1,0 VtSay "expedicao. (Se foi "
			@ 2,0 VtSay "utilizada mais de "
			@ 3,0 VtSay "uma expedicao, 
			@ 4,0 VtSay	"informe os codigos "
			@ 5,0 VtSay	"separados por /. "
			@ 6,0 VtSay	"Ex.: 001/002)"
			@ 7,0 VtGet cExped Pict "@!"
			
			VTRead
		EndDo
		ZZ8->(RecLock("ZZ8",.F.))
			ZZ8->ZZ8_XEXPED := cExped		
			ZZ8->ZZ8_XSTCB7 := "1"		
		ZZ8->(MsUnlock())
	Else
		VTAlert("Pedido nao encontrado na fila.","Aviso",.t.,4000,3) 
	EndIf
else
	//Faz a transferencia para os produtos configurados como indiretos
	if U_DPTRAN01(cOrdSep)
		VTAlert("Separacao concluida com sucesso!","Aviso",.t.,4000,3) 
	else
		VTAlert("Erro no processo de separacao","Aviso",.t.,4000,3) 
	endif
endif

RestArea(aAreaCB7)

Return
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
User Function DIPA080()   
Local aAreaCB7 := CB7->(GetArea())  
Local aTela    := {}  
Local cExped   := Space(120)
Local cPedido  := ""
Local cSep 	   := ""
Local bVldSep  := {|| VldCodSep()}
Private cOrdSep  := Space(6)
	    
VTClear()

@ 0,0 VtSay "Informe a ordem de"
@ 1,0 VtSay "separacao."
@ 2,0 VTGET cOrdSep F3 "ZZ5DIP" Valid Eval(bVldSep)
VTRead

VTClear()

CB7->(dbSetOrder(1)) 
If !Empty(cOrdSep) .And. CB7->(dbSeek(xFilial("CB7")+cOrdSep))
	
	@ 0,0 VTSay "Pedido da Transp.:"
	@ 1,0 VtSay CB7->CB7_TRANSP
	@ 2,0 VtSay Posicione("SA4",1,xFilial("SA4")+CB7->CB7_TRANSP,"A4_NREDUZ")
	@ 4,0 VTPause "Enter para continuar"
	
	VTClear()     
	
	ZZ5->(dbSetOrder(1))
	If ZZ5->(dbSeek(xFilial("ZZ5")+CB7->CB7_PEDIDO))
		If Empty(ZZ5->ZZ5_EXPED1) .And. ZZ5->ZZ5_STATUS>="2"
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

			ZZ5->(RecLock("ZZ5",.F.))
				ZZ5->ZZ5_EXPED1 := cExped   
				cSep := POSICIONE("CB9",1,xFilial("CB9")+cOrdSep,"CB9_CODSEP")                            
				ZZ5->ZZ5_SEPARA := POSICIONE("CB1",1,xFilial("CB1")+cSep,"CB1_XCODSC") 
			ZZ5->(MsUnlock())
		Else 
			VTAlert("Esta ordem já possui expedicao informada ou ainda esta em processo de separacao.","Aviso",.t.,4000,3) 
		EndIf
	Else
		VTAlert("Pedido nao encontrado na fila.","Aviso",.t.,4000,3) 
	EndIf                                                            
Else
	VTAlert("Ordem de separacao nao encontrada.","Aviso",.t.,4000,3) 
EndIf

SET FILTER TO

RestArea(aAreaCB7)

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DIPA080   ºAutor  ³Microsiga           º Data ³  01/06/17   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function VldCodSep()
Local lRet := .T.

dbSelectArea("ZZ5")   

If Empty(cOrdSep)    	
	SET FILTER TO (ZZ5->ZZ5_FILIAL==xFilial("ZZ5") .And. ZZ5->ZZ5_STATUS=="2" .And.; 
	((ZZ5->ZZ5_TIPOTM=="Mezanino" .And. Empty(ZZ5->ZZ5_EXPEDM)) .Or. (ZZ5->ZZ5_TIPOTM<>"Mezanino" .And. Empty(ZZ5->(ZZ5_EXPED1+ZZ5_EXPED2)))) ) 
	VtKeyBoard(chr(23))
	lRet := .F.
Else
	SET FILTER TO
EndIf                 

Return lRet
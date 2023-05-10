#INCLUDE "PROTHEUS.CH"    
#INCLUDE "apvt100.ch"
User Function CBRastro() 
Local cLote 	:= Paramixb[2]
Local cSubLote  := Paramixb[3]
Local dValid	:= Paramixb[4]
Local dValidMin := MonthSum(Date(),18)
Local cUserAut  := GetNewPar("ES_120VALI","MCANUTO/RDOMINGOS/RBORGES/MBERNARDO")  
Local nOpcx     := 0

If "ACDV120"$FunName() 
	dValid := StoD("")
	 
	aSave   := VTSAVE()
	VTClear     
	
	If UPPER(AllTrim((U_DipUsr()))) $ cUserAut .And. VTYesNo("Permite Validade abaixo de 18 meses?","Atenção",.T.) 
		dValidMin := Date()
	Endif
	
	@ 0,0 VTSay "Produto com rastro"
	@ 2,0 VtSay "Lote"
	@ 3,0 VtGet cLote pict '@!' valid !Empty(cLote) 
	@ 5,0 VtSay "Validade"
	@ 6,0 VtGet dValid pict '@D' valid !Empty(dValid) .And. dValid >= dValidMin

	VTREAD              
	
	VtRestore(,,,,aSave)
EndIf                                               

Return {cLote,cSubLote,dValid}
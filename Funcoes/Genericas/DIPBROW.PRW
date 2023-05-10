
User function DIPBROW

Local cCodEmp	:= FWCodEmp()
Local cTransp	:= Posicione("SC5",1,SC5->C5_FILIAL+SC5->C5_NUM,"C5_TRANSP")
Local cTpFret	:= Posicione("SC5",1,SC5->C5_FILIAL+SC5->C5_NUM,"C5_TPFRETE")
Local cRet		:=''

If cCodEmp =='04'
	If cTransp  $ '000235/000236'
		cRet :="12:00"
	Else 
		cRet :="15:30"
	EndIf
Else
	If cTransp $ '123455/003025' .AND. cTpFret $ 'C/I'
			cRet :="16:00"
	ElseIf cTransp $ '000150' .AND. cTpFret $ 'C/I'
		cRet :="13:00"
	ElseIf cTpFret =='F'  
		cRet :="16:00"
	ElseIf cTransp $ '100000'
		cRet :="17:00"
	ElseIf cTransp $ '000000'
		cRet :="10:30"
	ElseIf cTransp $ '000235/000236'
		cRet :="15:00"
	ElseIf cTpFret =='R'
		cRet :="16:00"
	ElseIf cTpFret =='D'
		cRet :="16:00"
	ElseIf !(cTransp $ '123455/003025/000150') .AND. cTpFret $ 'C/I/F'  
		cRet :="16:00"
	EndIf
EndIf
	
Return (cRet)

#Include "RwMake.Ch"

User Function TMKOUT(lMsg,nOpc)

If Type("_cOut") == "U"
		_cOut := ""
EndIf 
If nOpc <> 3 .Or. Empty(M->UC_CODCONT)  //RBORGES - 27/08/2015
	lMsg := .F. 
EndIf
 
lDip271Ok := .f. // Libera o Botão OK
U_DIPPROC(ProcName(0),U_DipUsr()) //MCVN - 22/01/2009
// Volta os dados do SC5
If nOpc == 4 
	SC5->(DbSetOrder(1))
	If SC5->(MsSeek(xFilial("SC5")+SUA->UA_NUMSC5))
		Reclock("SC5",.F.)
		SC5->C5_PARCIAL := _cOut
		SC5->(MsUnLock())
		SC5->(DbCommit())  // MCVN 25/04/07     
	EndIf
	_cOut := ''
Endif
	
Return(.t.)
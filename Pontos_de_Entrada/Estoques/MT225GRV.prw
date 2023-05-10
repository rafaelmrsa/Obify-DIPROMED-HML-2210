/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPE MATA225³ MT225GRV     ºAutor  ³Maximo Canuto   º Data ³  26/10/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ PE do MATA225 atualiza BE_PRIOR e BF_PRIOR quando produto  º±±
±±º          ³ tiver controle de picking                                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ DIPROMED                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/                    

User Function MT225GRV()
Local _lRetorno   := .T.  
Local _cPrior     := '0'
Local _cPriorAnt  := ''
Local _cFrom      := ''
Local _cEmail     := ''
Local _cAssunto   := ''
Local _aMsg       := {}   
Local _cFuncSent  := "MT225GRV.PRW"  
Local _cDescProdu := ""
Local _cUser      := AllTrim(Upper(U_DipUsr()))   
Local _lConfirmou := (PARAMIXB[2]==1)

U_DIPPROC(ProcName(0),U_DipUsr())  //Atualiza SZU

If _lConfirmou
	If !Empty(SB2->B2_LOCALIZ) .And. SB2->B2_DIPQMAX > 0

		//Atualizando BE_PRIOR
		SBE->(DbSetOrder(1))
		If SBE->(DbSeek(xFilial('SBE')+SB2->B2_LOCAL+SB2->B2_LOCALIZ))
		    _cPriorAnt := SBE->BE_PRIOR
			RecLock("SBE",.F.)
			Replace BE_PRIOR WITH _cPrior
			SBE->(MsUnlock())
			SBE->(DbCommit())		
		Endif                
	
		//Atualizando BF_PRIOR
		SBF->(DbSetOrder(1))
		If SBF->(DbSeek(xFilial('SBF')+SB2->B2_LOCAL+SB2->B2_LOCALIZ+SB2->B2_COD))
			RecLock("SBF",.F.)
			Replace BF_PRIOR WITH _cPrior
			SBF->(MsUnlock())
			SBF->(DbCommit())		
		Endif  
	
		//  Envia e-mail para os gerentes   MCVN - 26/10/2007	 
   		_cFrom      := "" 
	    _cEmail     := "edvan.matias@dipromed.com.br;armazenamento@dipromed.com.br"                                
    	_cAssunto   := "Produto "+SB2->B2_COD+" incluido no endereço de Picking " +SB2->B2_LOCALIZ+ "!"+ " - Empresa: "+ If(cEmpAnt=="04","HQ","DIPROMED")
	    _cDescProdu := Posicione("SB1",1,xFilial("SB1") + SB2->B2_COD,"B1_DESC") 
    	Aadd( _aMsg , { "Empresa: "         , + " - Empresa: "+ If(cEmpAnt=="04","HQ","DIPROMED") } )
		Aadd( _aMsg , { "Produto: "         , SB2->B2_COD } )
		Aadd( _aMsg , { "Descrição "        , _cDescProdu } )
		Aadd( _aMsg , { "End de Picking: "  , SB2->B2_LOCALIZ  } )
		Aadd( _aMsg , { "Qtd. mínima: "     , Transform(SB2->B2_DIPQMIN, "@E 999999.999") } )
		Aadd( _aMsg , { "Qtd. máxima:  "    , Transform(SB2->B2_DIPQMAX, "@E 999999.999") } )
		Aadd( _aMsg , { "Prior Anterior:  " , _cPriorAnt } )
		Aadd( _aMsg , { "Usuário:  " , _cUser } )

   		U_UEnvMail(_cEmail,_cAssunto,_aMsg,"",_cFrom,_cFuncSent)

	EndIf
EndIf

Return(_lRetorno)             
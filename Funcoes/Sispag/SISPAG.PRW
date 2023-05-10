#INCLUDE "rwmake.ch"
/*
-------------------------------------------------------------------------
Rotinas para USO EXCLUSIVO para gerar arquivo SISPAG (Itau)                        
-------------------------------------------------------------------------
/**//*
-----------------------------------------------------------------------------
Funcao   : FVNumCon
-----------------------------------------------------------------------------
Descricao: Retorna Numero da Conta (sem digito verificador)      
-----------------------------------------------------------------------------
*/
User Function FVNumCon()

//Return( StrZero( Val(Subs(SEA->EA_NUMCON,1,At("-",SEA->EA_NUMCON)-1)) , 12 ) )
Return( StrZero( Val(LEFT(SEA->EA_NUMCON,9)), 12 ) )
/*/
-----------------------------------------------------------------------------
Funcao   : FVDacCon
-----------------------------------------------------------------------------
Descricao: Retorna Dac da Conta        
-----------------------------------------------------------------------------
*/
User Function FVDacCon()
//Local cDacCon := Subs(SEA->EA_NUMCON,At("-",SEA->EA_NUMCON)+1,1)
Local cDacCon := Right(SEA->EA_NUMCON,1)

Return( IIF(Empty(cDacCon)," ",cDacCon) )
/*/
-----------------------------------------------------------------------------
Funcao   : FVNomBco
-----------------------------------------------------------------------------
Descricao: Retorna Nome do Banco (Posiciona SA6)        
-----------------------------------------------------------------------------
/*/
User Function FVNomBco()
Local _cNomBco := GetAdvFVal("SA6","A6_NOME",xFilial("SA6")+SEA->(EA_PORTADO+EA_AGEDEP+EA_NUMCON),1,"")
_cNomBco := Subs(_cNomBco,1,30)

Return( _cNomBco )
/*/
-----------------------------------------------------------------------------
Funcao   : FVEndCob
-----------------------------------------------------------------------------
Descricao: Retorna Endereco de Cobranca (Sem Numero)        
-----------------------------------------------------------------------------
*/
User Function FVEndCob()

Return( Subs( Subs(SM0->M0_ENDCOB,1,At(",",SM0->M0_ENDCOB)-1) , 1 , 30 ) )
/*/
-----------------------------------------------------------------------------
Funcao   : FVEndNum
-----------------------------------------------------------------------------
Descricao: Retorna Numero do Endereco)        
-----------------------------------------------------------------------------
*/
User Function FVEndNum()
Local nPosVir := At(",",SM0->M0_ENDCOB)

Return( StrZero(Subs(SM0->M0_ENDCOB,nPosVir+1,30-nPosVir),5) )
/*/
-----------------------------------------------------------------------------
Funcao   : FVCodPag
-----------------------------------------------------------------------------
Descricao: Retorna Codigo de Pagamento para GPS       
-----------------------------------------------------------------------------
*/
User Function FVCodPag()

Return( IIF( AllTrim(SE2->E2_NATUREZ)=="INSS-PJ" , "2631" , "2100" )  )
/*/
-----------------------------------------------------------------------------
Funcao   : FVCompet
-----------------------------------------------------------------------------
Descricao: Retorna Competencia para GPS       
-----------------------------------------------------------------------------
*/
User Function FVCompet()

Return( SUBS(DTOS(SE2->E2_EMISSAO),5,2)+SUBS(DTOS(SE2->E2_EMISSAO),1,4)  )
/*/
-----------------------------------------------------------------------------
Funcao   : FVTribut
-----------------------------------------------------------------------------
Descricao: Dados do tributo (anexo C). Retirado do S23->E2_FV_AUX       
-----------------------------------------------------------------------------
*/
User Function FVTribut()
Local cTrib := ""

If SE2->E2_TIPO == 	"INS" .Or. AllTrim(SE2->E2_FORNECE) $ "INSS/INPS"
	cTrib += "01"
ElseIf SE2->E2_TIPO == "TX " .Or. AllTrim(SE2->E2_FORNECE) $ "UNIAO"
	cTrib += "02"
Else
	cTrib += "  "
EndIf

If cTrib == "01"
	/*
	-------------------------------------------------------------------------
	Cod.Pagamento: 2631-INSS Retido PJ / 2100                          
	-------------------------------------------------------------------------*/
	If AllTrim(SE2->E2_NATUREZ)=="INSS-PJ"
		cTrib += "2631"
	Else
		cTrib += "2100" // Folha de Pagamentos / Autonomos
	EndIf
	
	cTrib += Subs(DTOS(SE2->E2_EMIS1),5,2)+Subs(DTOS(SE2->E2_EMIS1),1,4)
	cTrib += StrZero(Val(SM0->M0_CGC),14)
	cTrib += StrZero(SE2->E2_SALDO*100,14)
	cTrib += StrZero(0,14)
	ctrib += StrZero(0,14)
	cTrib += StrZero(SE2->E2_SALDO*100,14)
	cTrib += GRAVADATA(SE2->E2_VENCREA,.F.,5)
	cTrib += Space(8)
	cTrib += Subs(SE2->E2_HIST,1,50)
	cTrib += Subs(SM0->M0_NOMECOM,1,30)
	
ElseIf cTrib == "02"
	/*
	-------------------------------------------------------------------------
	Cod.Pagamento: 	8301(PIS Folha)/1708(PJ)/0588(PF)/0561(Ferias)                                                    ³
				  	5952(PIS/COF/CSL)/5987(CSLL)/5960(COFINS)/5979(PIS)                                               ³
	-------------------------------------------------------------------------*/
	If AllTrim(SE2->E2_NATUREZ) == "IRJ"
		cTrib += "1708"
	ElseIf AllTrim(SE2->E2_NATUREZ) == "IRF" .And. SE2->E2_TIPO == "FOL" //.And. SE2->E2_FORNECE == "000658"
		cTrib += "0561"
	ElseIf AllTrim(SE2->E2_NATUREZ) == "503" .And. SE2->E2_TIPO == "FOL" //.And. SE2->E2_FORNECE == "000545"
		cTrib += "8301" // PIS Folha
	ElseIf AllTrim(SE2->E2_NATUREZ) == "IRF"
		cTrib += "0588"
	ElseIf AllTrim(SE2->E2_NATUREZ) == "PIS"
		cTrib += "5979"
	ElseIf AllTrim(SE2->E2_NATUREZ) == "COFINS"
		cTrib += "5960"
	ElseIf AllTrim(SE2->E2_NATUREZ) == "CSLL"
		cTrib += "5987"
	ElseIf AllTrim(SE2->E2_NATUREZ) == "PIS/COF/CSL"
		cTrib += "5952"
	Else
		cTrib += "    "
	EndIf
	cTrib += "2" // CNPJ
	cTrib += StrZero(Val(SM0->M0_CGC),14)
	cTrib += GRAVADATA(SE2->E2_EMIS1,.F.,5)
	ctrib += StrZero(0,17)
	cTrib += StrZero(SE2->E2_SALDO*100,14)
	cTrib += StrZero(0,14)
	ctrib += StrZero(0,14)
	cTrib += StrZero(SE2->E2_SALDO*100,14)
	cTrib += GRAVADATA(SE2->E2_VENCREA,.F.,5)
	cTrib += GRAVADATA(SE2->E2_VENCREA,.F.,5)
	cTrib += Space(30)
	cTrib += Subs(SM0->M0_NOMECOM,1,30)
EndIf

Return( cTrib )
/*/
-----------------------------------------------------------------------------
Funcao   : FVFavCon
-----------------------------------------------------------------------------
Descricao: Retorna Numero do Bco/Age/Cta do favorecido-Cr.Cta ou DOC       
-----------------------------------------------------------------------------
*/
User Function FVFavCon()
Local _cRet := Space(23)
Local _cBco := Space(3)
Local _cAge := Space(5)
Local _cDig := Space(1)
Local _cCta := Space(12)
Local _cDac := Space(2)
Local _nPos := 0
Local _cPor := SEA->EA_PORTADO
Local _nTed := 0
Local _nPosDV:= 0

If SEA->EA_MODELO $ "41/43" // TED
	If ( SA2->A2_BANCO == _cPor )
		_nTed := 1
	Else
		_nTed := 2
	EndIf
EndIf

If SEA->EA_MODELO $ "01/05" .Or. _nTed == 1 // Cred em Conta/Poupanca ou TED Itau
    If SA2->A2_BANCO == _cPor            
		_cBco := SA2->A2_BANCO
		_cAge := Subs(SA2->A2_AGENCIA,1,4)
		_cDig := Subs(SA2->A2_AGENCIA,5,1)
		_cCta := StrZero( Val(Subs(SA2->A2_NUMCON,1,8)) , 12 )
	
	    _nPosDV := AT("-",SA2->A2_NUMCON)
		IF _nPosDV == 0              			
			_cDac := SubStr(SA2->A2_NUMCON,9,2)	
		Else
			_cDac := SubStr(SA2->A2_NUMCON,_nPosDV+1,1)
		EndIf
	EndIf
ElseIf SEA->EA_MODELO == "03"  .Or. _nTed == 2 // Doc
	If SA2->A2_BANCO <> _cPor .And. !Empty(SA2->A2_BANCO)
		_cBco := SA2->A2_BANCO
		_cAge := StrZero( Val(Subs(SA2->A2_AGENCIA,1,4)) , 5 )
		_cDig := Subs(SA2->A2_AGENCIA,5,1)

		If SA2->A2_BANCO $ "347"
			_cCta := StrZero( Val(Subs(SA2->A2_NUMCON,1,9)) , 12 )
			_cDac := Subs(SA2->A2_NUMCON,10,1)
		Else
			_cCta := StrZero( Val(Subs(SA2->A2_NUMCON,1,8)) , 12 )

			_nPosDV := AT("-",SA2->A2_NUMCON)
			IF _nPosDV == 0              			
				_cDac := SubStr(SA2->A2_NUMCON,9,2)	
			Else
				_cDac := SubStr(SA2->A2_NUMCON,_nPosDV+1,1)
			EndIf
		EndIf
	EndIf
Else
	_cBco := SA2->A2_BANCO
	_cAge := StrZero( Val(Subs(SA2->A2_AGENCIA,1,4)) , 5 )
	_cDig := Subs(SA2->A2_AGENCIA,5,1)

	If SA2->A2_BANCO $ "347"
		_cCta := StrZero( Val(Subs(SA2->A2_NUMCON,1,9)) , 12 )
		_cDac := Subs(SA2->A2_NUMCON,10,1)
	Else
		_cCta := StrZero( Val(Subs(SA2->A2_NUMCON,1,8)) , 12 )
	
		_nPosDV := AT("-",SA2->A2_NUMCON)
		IF _nPosDV == 0              			
			_cDac := SubStr(SA2->A2_NUMCON,9,2)	
		Else
			_cDac := SubStr(SA2->A2_NUMCON,_nPosDV+1,1)
		EndIf
	EndIf
EndIf

If _cPor == "341" // Itau
	If _cBco == "341" // Cred. em Conta
		_cRet := _cBco + "0" + _cAge + " " + _cCta + " " + _cDac
	Else
		_cRet := _cBco + _cAge + " "  + _cCta + IIf( Len(AllTrim(_cDac))==1," " + _cDac,_cDac)
	EndIf
EndIf

Return( _cRet )
/*/
-----------------------------------------------------------------------------
Funcao   : FVFavNom 
-----------------------------------------------------------------------------
Descricao: Retorna Nome do Fornecedor/beneficiario de Deposito     
-----------------------------------------------------------------------------
/*/
User Function FVFavNom()
Local _cRet := Space(30)

If SEA->EA_MODELO $ "01/03/05" // Cred em Conta / DOC
	_cRet := Subs(SA2->A2_NOME,1,30)
EndIf

Return( _cRet )
/*
-----------------------------------------------------------------------------
Funcao   : FVFavCGC
-----------------------------------------------------------------------------
Descricao: Retorna CGC DO Fornecedor/Beneficiario de Deposito 
-----------------------------------------------------------------------------
*/
User Function FVFavCGC()
Local _cRet := Space(14)

If SEA->EA_MODELO $ "01/03/05" // Cred em Conta / DOC
	_cRet := StrZero(Val(SA2->A2_CGC),14)
EndIf

Return( _cRet )
#Include "RwMake.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³ DIPG003  º Autor ³  Rodrigo Franco    º Data ³  19/12/01   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ condicao de pagto conforme valor do pedido.                º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function DIPG003()
Local _cFiltro
Local _nPosValor
Local _nValor
Local _xAlias   	:= GetArea()
local _nLin
local _n 
Local _OperLicita := GetMV("MV_OPERLIC")                                               
Local _cPosto       := ""
Private _nPosProd	:= aScan(aHeader, { |x| Alltrim(x[2]) == "C6_PRODUTO"})
Private _nPosPrcven := aScan(aHeader, { |x| Alltrim(x[2]) == "C6_PRCVEN"})
Private _nPosQtdVen	:= aScan(aHeader, { |x| Alltrim(x[2]) == "C6_QTDVEN"})
Private _nPosUPrc 	:= aScan(aHeader, { |x| Alltrim(x[2]) == "C6_USERPRC"})
Private _nPosUDes 	:= aScan(aHeader, { |x| Alltrim(x[2]) == "C6_USERDES"})
Private _nPosUAcr 	:= aScan(aHeader, { |x| Alltrim(x[2]) == "C6_XUSRACR"})
Private _nPosPrUnit	:= aScan(aHeader, { |x| Alltrim(x[2]) == "C6_PRUNIT"})
Private _nPosDescont:= aScan(aHeader, { |x| Alltrim(x[2]) == "C6_DESCONT"})
Private _nPosValDesc:= aScan(aHeader, { |x| Alltrim(x[2]) == "C6_VALDESC"})
Private _nPosMini   := aScan(aHeader, { |x| Alltrim(x[2]) == "C6_PRVMINI"})
Private _nPosSupe   := aScan(aHeader, { |x| Alltrim(x[2]) == "C6_PRVSUPE"})

Private _cCliEspecial := GetMV("MV_CLIESPE") // Cliente especial

_lRet := .t.
U_DIPPROC(ProcName(0),U_DipUsr()) // JBS 05/10/2005 - Gravando o nome do Programa no SZU
IF 'TMK' $ FUNNAME() //FUNNAME() == "TMKA271"
	_mod := "TMK"
ELSEIf 'TMS' $ FUNNAME() //MCVN - 06/11/2008
    _Mod := 'TMS'
ELSE
	_mod := "FAT"
Endif

//Eriberto 20/01/2005 IF cModulo == _mod
_cFiltro := ""
_nPosValor := aScan(aHeader, { |x| Alltrim(x[2]) == IIF(_MOD == "TMK","UB_VLRITEM","C6_VALOR") })
_nValor    := 0

//³ Soma peso bruto, liquido, volume e total do pedido. ³
For _nLin := 1 to Len(aCols)
	IF !aCols[_nLin,Len(aHeader)+1]
		_nValor := _nValor + aCols[_nLin,_nPosValor]
	EndIF
Next

If _Mod == 'TMK'
	If !EMPTY(M->UA_CONDPAG)
		_lRet := .t.
        _nValor += M->UA_FRETE + M->UA_DESPESA
	EndIf
Else
	If !EMPTY(M->C5_CONDPAG)
		_lRet := .t.
        _nValor += M->C5_FRETE + M->C5_DESPESA
	EndIf                
	_cPosto := AllTrim(Posicione("SU7",1,xFilial("SU7")+M->C5_OPERADO,"U7_POSTO"))
EndIf

SE4->(dbSetOrder(1))
If !SE4->(dbSeek(xFilial("SE4")+M->C5_CONDPAG))	
	_lRet := .F.
EndIf	        

If _lRet .And. cEmpAnt=="01" .And. !Empty(M->C5_CONDPAG)
    If Empty(M->C5_CLIENTE)
   		Aviso("Atenção","Cliente não informado.",{"Ok"},1)
   		_lRet := .F. 
   	EndIf
   		   	
	If _lRet .And. !Empty(SA1->A1_XSTATCR) .And. !("DIPAL10" $ FunName()) 
		If 	!('VISTA' $ Posicione("SE4",1,XFILIAL("SE4")+M->C5_CONDPAG,'E4_DESCRI')) .And. SA1->A1_XSTATCR <> '1'
			Aviso("Atenção","Este cliente só pode efetuar compra A VISTA.",{"Ok"},1)						
			_lRet := .F.
		EndIf
	EndIf	
EndIf    

If _lRet .And. AllTrim(SE4->E4_TP) <> "V" .And. !(M->C5_CONDPAG=="167" .And. M->C5_OPERADO$_OperLicita)
	Aviso("Atenção","Esta condição de pagamento não é de venda ou está bloqueada pelo setor comercial.",{"Ok"},1)
	_lRet := .F.
EndIf

If _lRet .And. M->C5_CONDPAG=="575" .And. !M->C5_CLIENTE$GetNewPar("ES_CLIC575","013710")
	Aviso("Atenção","Esta condição de pagamento não é permitida para este cliente.",{"Ok"},1)
	_lRet := .F.
EndIf

//REGRA PARA CLIENTES RISCO C - FELIPE DURAN - DELTA
If _lRet .And. !Empty(SA1->A1_RISCO ='C') 
	If 	!('VISTA' $ Posicione("SE4",1,XFILIAL("SE4")+M->C5_CONDPAG,'E4_DESCRI'))
		Aviso("Atenção","Clientes Risco C só podem efetuar compra A VISTA.",{"Ok"},1)						
		_lRet := .F.
	EndIf
EndIf
//FIM REGRA 10/02/2020	

//REGRA PARA CLIENTES OUTROS ESTADOS COVID-19 - MAXIMO
/*If cEmpAnt =='04'
	If _lRet .And. SA1->A1_EST $ 'MG/PE/AL/BA/PR/SC' .AND. SA1->A1_GRPVEN <> '000021' .AND. SA1->A1_GRPVEN <> '000175'  .AND. SA1->A1_CONTRIB <> '2'
		If 	!('VISTA' $ Posicione("SE4",1,XFILIAL("SE4")+M->C5_CONDPAG,'E4_DESCRI'))
			Aviso("Atenção","Efetuar somente venda A VISTA.",{"Ok"},1)						
			_lRet := .F.
		EndIf
	EndIf
Else
	If _lRet .And. SA1->A1_EST $ 'MG/PE/AL/BA/PR/SC' .AND. SA1->A1_CONTRIB <> '2'
		If 	!('VISTA' $ Posicione("SE4",1,XFILIAL("SE4")+M->C5_CONDPAG,'E4_DESCRI'))
			Aviso("Atenção","Efetuar somente venda A VISTA.",{"Ok"},1)						
			_lRet := .F.
		EndIf
	EndIf
Endif*/
//FIM REGRA 23/03/2020	

// Regra abaixo desativada, solicitado pelo Maximo - REGRA REATIVADA 09/12/20 com outros produtos , REGRA DESATIVADA NOVAMENTE em 05/01/2021
//REGRA PARA VENDER LUVAS APENAS A VISTA - MAXIMO
/*If cEmpAnt =='01'
	For _n := 1 to Len(aCols)			
		If Alltrim(aCols[_n,_nPosProd]) $  '080512/080511/080510/080509/012200/012209/425208/010786/080477/080479/010785/080480/012203/012213/425191/012202/012212/425190/080478/012201/012214/425189/080310/080476';
			.And. SA1->A1_CONTRIB <> '2' .And. aCols[_n,Len(aHeader)+1] == .F.
			If 	M->C5_CONDPAG <> '001' .And. M->C5_CONDPAG <> '002' .And. M->C5_CONDPAG <> '005'  .And. M->C5_CONDPAG <> '016'  .And. M->C5_CONDPAG <> '602' .And. M->C5_CONDPAG <> '354' .And. M->C5_CONDPAG <> '008';
				.And. M->C5_CONDPAG <> '004' .And. M->C5_CONDPAG <> '005' .And. M->C5_CONDPAG <> '349' .And. M->C5_CONDPAG <> '554' .And. M->C5_CONDPAG <> '606' .And. M->C5_CONDPAG <> '616' .And. M->C5_CONDPAG <> '563' 
				Aviso("Atenção","LUVA SOMENTE  A VISTA OU ATÉ 28 DIAS.",{"Ok"},1)						
				_lRet := .F.
			EndIf	
		Endif
	Next
Endif*/
//FIM REGRA 25/03/2020		//REGRA DESATIVADA NOVAMENTE em 05/01/2021
//*/

If _lRet
	If cEmpAnt <> "01"
		//If M->C5_CONDPAG == '167' .and. M->C5_OPERADO $ '000013/000056/000106/000109/000130'// JBS 25/10/2006 000130
		If M->C5_CONDPAG == '167' .and. M->C5_OPERADO $ _OperLicita // Buscando no parâmetro os operadores de Licitação MCVN - 09/10/2007
			_lRet := .t.
		ElseIf _nValor >= SE4->E4_INFER .and. _nValor <= SE4->E4_SUPER  .and.;
			(Empty(SE4->E4_SEGMENT) .OR.;
			(!Empty(SE4->E4_SEGMENT).AND. AllTrim(SA1->A1_SATIV1) $ SE4->E4_SEGMENT))  // verifica se condição está atrelada a segmento
			_lRet := .t.
		ElseIf M->C5_CONDPAG == SA1->A1_COND // Caso a condição de pagamento do pedido seja a mesma do cadastro do cliente não pede senha  -  MCVN 09/10/2007
			_lRet := .t.
		ElseIf M->C5_TIPODIP $ "2/3" // SE FOR ORÇAMENTO OU PROGRAMAÇÃO NÃO PEDE SENHA  -  MCVN 09/10/2007
			_lRet := .t.
		ElseIf !(_nValor >= SE4->E4_INFER .and. _nValor <= SE4->E4_SUPER)
			
			If (Type("l410Auto") == "U" .OR. !l410Auto)
				_lRet := .f.
				If if(_Mod == 'TMK', !M->UA_CLIENTE $ _cCliEspecial,;
					M->C5_TIPO == 'N'.AND.!M->C5_CLIENTE $ _cCliEspecial)
					
					If !U_DipSenha("PAG", M->C5_CONDPAG, _nValor, 0,.f.)
						_lRet := U_Senha("PAG",_nValor,0,0)
						If _lRet
							U_DipSenha("PAG", M->C5_CONDPAG, _nValor, 0,.t.)
						EndIf
					Else
						_lRet := .t.
					Endif
				Else
					_lRet := .t.
				Endif
			EndIf
			
		ElseIf !Empty(SE4->E4_SEGMENT) .and. !AllTrim(SA1->A1_SATIV1) $ SE4->E4_SEGMENT
			
			If ( Type("l410Auto") == "U" .OR. !l410Auto )
				
				_lRet := .f.
				
				If If(_Mod == 'TMK',!M->UA_CLIENTE $ _cCliEspecial,;
					M->C5_TIPO=='N'.AND.!M->C5_CLIENTE $ _cCliEspecial)
					
					If !U_DipSenha("PAG", M->C5_CONDPAG, _nValor, 0,.f.)
						_lRet := U_Senha("PAG",_nValor,0,0,.t.)
						If _lRet
							U_DipSenha("PAG", M->C5_CONDPAG, _nValor, 0,.t.)
						EndIf
					Else
						_lRet := .t.
					Endif
					
					If _lRet
						If _Mod == 'TMK' .and. !'ERICH' $ Alltrim(M->UA_SENHPAG)
							MsgInfo("Para esta condicao de Pagamento, só vale a senha do Erich")
							_lRet := .f.
						ElseIf _Mod <> 'TMK' .and. !'ERICH' $ Alltrim(M->C5_SENHPAG)
							MsgInfo("Para esta condicao de Pagamento, só vale a senha do Erich")
							_lRet := .f.
						EndIf
					EndIf
				Else
					_lRet := .t.
				EndIf
			Else
				_lRet := .t.
			EndIf
		EndIF
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Calcula desconto da Condicao de pagamento ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	If _Mod == "FAT"  .And. M->C5_TIPO = "N" .And. (_cPosto<>"02" .Or. cEmpAnt<>"01")
		_nTotPed := 0
		For _n := 1 to Len(aCols)			
			If GetNewPar("ES_VLPADB1",.T.)
				nValPadB1 := VldPadB1(_n)
			Else
				nValPadB1 := aCols[_n,_nPosUPrc]
			EndIf
			
			If aCols[_n,_nPosUDes] = 0 .And. SE4->E4_USERDES > 0 .And. aCols[_n,Len(aHeader)+1] == .F.
				aCols[_n,_nPosUPrc]	   := NOROUND(nValPadB1,4)
				aCols[_n,_nPosValor]   := Round(nValPadB1 * aCols[_n,_nPosQtdVen],2)
				aCols[_n,_nPosUDes]    := Round(aCols[_n,_nPosValor] * ((SE4->E4_USERDES)/100),2)
				aCols[_n,_nPosValor ]  := Round(aCols[_n,_nPosValor] - aCols[_n,_nPosUDes],2)
				aCols[_n,_nPosPrcVen]  := Round(aCols[_n,_nPosValor] / aCols[_n,_nPosQtdVen],4)
				aCols[_n,_nPosDescont] := 0
				aCols[_n,_nPosValDesc] := 0
				aCols[_n,_nPosPrUnit]  := aCols[_n,_nPosPrcVen]
			ElseIf aCols[_n,_nPosUDes] > 0 .And. SE4->E4_USERDES == 0 .And. aCols[_n,Len(aHeader)+1] == .F.				
				aCols[_n,_nPosPrcVen]  := nValPadB1
				aCols[_n,_nPosPrUnit]  := aCols[_n,_nPosPrcVen]				
				aCols[_n,_nPosValor]   := aCols[_n,_nPosPrcVen] * aCols[_n,_nPosQtdVen]
				aCols[_n,_nPosUDes]    := 0
				aCols[_n,_nPosUPrc]	   := 0
				aCols[_n,_nPosDescont] := 0
			ElseIf aCols[_n,_nPosUAcr] = 0 .And. SE4->E4_XUSRACR > 0 .And. aCols[_n,Len(aHeader)+1] == .F.
				aCols[_n,_nPosUPrc]	   := NOROUND(nValPadB1,4)
				aCols[_n,_nPosValor]   := Round(nValPadB1 * aCols[_n,_nPosQtdVen],2)
				aCols[_n,_nPosUAcr]    := Round(aCols[_n,_nPosValor] * ((SE4->E4_XUSRACR)/100),2)
				aCols[_n,_nPosValor ]  := Round(aCols[_n,_nPosValor] + aCols[_n,_nPosUAcr],2)
				aCols[_n,_nPosPrcVen]  := Round(aCols[_n,_nPosValor] / aCols[_n,_nPosQtdVen],4)
				aCols[_n,_nPosPrUnit]  := aCols[_n,_nPosPrcVen]
			ElseIf aCols[_n,_nPosUAcr] > 0 .And. SE4->E4_XUSRACR == 0 .And. aCols[_n,Len(aHeader)+1] == .F.				
				aCols[_n,_nPosPrcVen]  := nValPadB1
				aCols[_n,_nPosPrUnit]  := aCols[_n,_nPosPrcVen]				
				aCols[_n,_nPosValor]   := aCols[_n,_nPosPrcVen] * aCols[_n,_nPosQtdVen]
				aCols[_n,_nPosUAcr]    := 0
				aCols[_n,_nPosUPrc]	   := 0
			Endif
			If aCols[_n,Len(aHeader)+1] == .F.
				_nTotPed += aCols[_n,_nPosValor]
			EndIf
		Next
		
		// Atualiza a Get Dados	e Rodapé
		If _nTotPed > 0
			Ma410Rodap(,_nTotPed,0)
			If ( Type("l410Auto") == "U" .OR. !l410Auto ) // JBS 12/04/2006
				oGetDad:oBrowse:Refresh()
			EndIf
		Endif
		
		U_DIPG007()
		
	Endif
EndIf


RestArea(_xAlias)
Return(_lRet)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DIPG003   ºAutor  ³Microsiga           º Data ³  05/26/15   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function VldPadB1(_nItem)                            
Local nValAux   := 0     
Local nFatorRec := 0            
Local nPorcAume := 0
        
SB1->(dbSetOrder(1))
If SB1->(dbSeek(xFilial("SB1")+aCols[_nItem,_nPosProd]))
	If SB1->B1_PRVSUPE<SB1->B1_PRVMINI .And. SB1->B1_PRVSUPE > 0
		nValAux := SB1->B1_PRVSUPE
	Else
		nValAux := SB1->B1_PRVMINI
	EndIf

	nValAux := u_DipAcrCli(nValAux,M->C5_CLIENTE,M->C5_LOJACLI,SB1->B1_COD)
Else
	nValAux := 0
EndIf                                                                                                    
        
//Calculo automático do frete CIF
If !aCols[_nItem,Len(aHeader)+1] .And. u_VldCifRev(M->C5_NUM,"M",.T.)
	SE4->(DbSetOrder(1))
	If !Empty(M->C5_CONDPAG) .And. SE4->(MsSeek(xFilial("SE4")+M->C5_CONDPAG))
		If SE4->E4_USERDES > 0
			nFatorRec := 1-(SE4->E4_USERDES/100)
		Else 
			nFatorRec := 1+(SE4->E4_XUSRACR/100)
		EndIf
	Else
		nFatorRec := 1
	EndIf
	
	If substr(M->C5_XRECOLH,1,3) $ "ACR"
		nPorcAume:= 1.16
	ElseIf substr(M->C5_XRECOLH,1,3) $ "ISE"
		nPorcAume:= 1.06
	EndIf
	
	SB1->(dbSetOrder(1))
	If SB1->(dbSeek(xFilial("SB1")+aCols[_nItem,_nPosProd]))
		If SubStr(M->C5_XRECOLH,1,3) $ "ACR/ISE"
			If  aCols[_nItem,_nPosSupe] > 0
				nValAux := Round(NoRound(aCols[_nItem,_nPosSupe]*nPorcAume,4)*nFatorRec,4)
			Else
				nValAux := Round(NoRound(aCols[_nItem,_nPosMini]*nPorcAume,4)*nFatorRec,4)
			EndIf
		Else
			nValAux := if(SB1->B1_PRVSUPE>0,SB1->B1_PRVSUPE,SB1->B1_PRVMINI)
		EndIf
		
		ZZB->(dbSetOrder(1))
		If ZZB->(dbSeek(xFilial("ZZB")+M->C5_ESTE))
			If  M->C5_ESTE <> "SP" .Or. (M->C5_ESTE == "SP" .And. "DEMAIS CIDADES"$M->C5_DESTFRE)
				nValAux += Round(nValAux*(ZZB->ZZB_PERC/100),4)
			EndIf
		EndIf
	EndIf
EndIf



Return nValAux

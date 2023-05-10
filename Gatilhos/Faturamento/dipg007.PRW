#INCLUDE "RWMAKE.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "PROTHEUS.CH"
//#INCLUDE "FIVEWIN.CH"

//#xtranslate bSETGET(<uVar>) => {|u| If(PCount() == 0, <uVar>, <uVar> := u) }

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³DIPG007   ºAutor  ³   Alexandro Dias   º Data ³  10/08/01   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.   ³ Calcula margem atual e minima do item e do pedido.           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±                            ATUALIZAÇÕES                                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºMaximo  ³ 30/10/08 ³ Alterado calculo da margem                        º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/                               
*-------------------------------------------*
User Function DIPG007(_cOrigem)
*-------------------------------------------*
Local _nCustoPed  := 0
Local _nVendaPed  := 0
Local _nCustoMin  := 0
Local _nMargLib   := 0
Local _nMargemMin := 0
Local _nMargAtuPed:= 0
Local _nTotItens  := 0
Local _cMA        := 0
Local _cML        := 0
Local _aPreco     := {}
Local _xAlias     := GetArea()
Local _areaSB1    := SB1->(getarea())
Local _nValor     := 0 //giovani 13/07/11
Local _lRetorno
Local _nFor        
Local _nFatorRecolh := 1 //Iif(substr(M->C5_XRECOLH,1,3) $ "ACR/REC/ISE" , 1.06, 1) //giovani - alterar valor do fator de conversão para 1.06 e se o cliente for fora do estado de sp
Local _lVldQtd 	  := .T.
Private _nPosProdut := aScan(aHeader, { |x| Alltrim(x[2]) == IIF("TMK"$FunName(),"UB_PRODUTO","C6_PRODUTO" ) })
Private _nPosMrgAtu := aScan(aHeader, { |x| Alltrim(x[2]) == IIF("TMK"$FunName(),"UB_MARGATU","C6_MARGATU" ) })
Private _nPosMrgIte := aScan(aHeader, { |x| Alltrim(x[2]) == IIF("TMK"$FunName(),"UB_MARGITE","C6_MARGITE" ) })
Private _nPosCusto  := aScan(aHeader, { |x| Alltrim(x[2]) == IIF("TMK"$FunName(),"UB_CUSTO"  ,"C6_CUSTO"   ) })
Private _nPosQuant  := aScan(aHeader, { |x| Alltrim(x[2]) == IIF("TMK"$FunName(),"UB_QUANT"  ,"C6_QTDVEN"  ) })
Private _nPosPrVend := aScan(aHeader, { |x| Alltrim(x[2]) == IIF("TMK"$FunName(),"UB_VRUNIT" ,"C6_PRCVEN"  ) })
Private _nPosTotItem:= aScan(aHeader, { |x| Alltrim(x[2]) == IIF("TMK"$FunName(),"UB_VLRITEM","C6_VALOR"   ) })
Private _nPosPrcMin := aScan(aHeader, { |x| Alltrim(x[2]) == IIF("TMK"$FunName(),"UB_PRCMIN" ,"C6_PRCMIN"  ) })
Private _nPosNota   := aScan(aHeader, { |x| Alltrim(x[2]) == IIF("TMK"$FunName(),"UB_NOTA"   ,"C6_NOTA"    ) })
Private _nPosTES    := aScan(aHeader, { |x| Alltrim(x[2]) == IIF("TMK"$FunName(),"UB_TES"    ,"C6_TES"     ) })
Private _nPosPrTAB  := aScan(aHeader, { |x| Alltrim(x[2]) == IIF("TMK"$FunName(),"UB_PRCTAB" ,"C6_PRUNIT"  ) })
Private _nPosDESC   := aScan(aHeader, { |x| Alltrim(x[2]) == IIF("TMK"$FunName(),"UB_DESC"    ,"C6_DESCONT") })
Private _nPosValDesc:= aScan(aHeader, { |x| Alltrim(x[2]) == IIF("TMK"$FunName(),"UB_VALDESC" ,"C6_VALDESC") })
Private _nPosPrDIPR := aScan(aHeader, { |x| Alltrim(x[2]) == IIF("TMK"$FunName(),"UB_USERPRC" ,"C6_USERPRC") }) // Senha a vista
Private _nPosDesDIP := aScan(aHeader, { |x| Alltrim(x[2]) == IIF("TMK"$FunName(),"UB_USERDES" ,"C6_USERDES") }) // Senha a vista
Private _cCliEspecial := GetMV("MV_CLIESPE") // Cliente especial

Static _lPassou

_cOrigem := If(_cOrigem == NIL,"Dipg007",_cOrigem)   
IF !("TMK"$FunName())  .and. !("DIPAL10" $ FunName()) .And. !("DIPA072"$Upper(FUNNAME()))//giovani 19/07/11
	If substr(M->C5_XRECOLH,1,3) $ "ACR"
     	_nFatorRecolh:= 1.16
    ElseIf substr(M->C5_XRECOLH,1,3) $ "ISE"
	_nFatorRecolh:= 1.06
	Else
	_nFatorRecolh:= 1
	EndIf             
	If "C6_QTDVEN"$ReadVar()
		_lVldQtd := u_VldCxFech(aCols,aHeader)
	EndIf
EndIf

U_DIPPROC(ProcName(0),U_DipUsr()) // JBS 05/10/2005 - Gravando o nome do Programa no SZU

If _lVldQtd
	For _nFor := 1 to Len(aCols)
		
		//³ Calcula a margem atual do Pedido e sua margem minima.      ³
		IF !aCols[_nFor,Len(aHeader)+1]
			IF !Empty(aCols[_nFor,_nPosProdut])
				_nCustoPed := _nCustoPed + ( aCols[_nFor,_nPosQuant] * aCols[_nFor,_nPosCusto])
				_nCustoMin := _nCustoMin + ( aCols[_nFor,_nPosQuant] * aCols[_nFor,_nPosPrcMin])
				//_nVendaPed := _nVendaPed + ( aCols[_nFor,_nPosQuant] * aCols[_nFor,_nPosPrVend]) //-- Daniel Leme 12/07/2011
				_nVendaPed := _nVendaPed + ( aCols[_nFor,_nPosQuant] * (aCols[_nFor,_nPosPrVend]/_nFatorRecolh))
				_nTotItens := _nTotItens + aCols[_nFor,_nPosQuant]
				
				SB1->(DbSetOrder(1))
				If SB1->(DbSeek(xFilial("SB1")+aCols[_nFor,_nPosProdut]))
					aCols[_nFor,_nPosprTAB] :=  aCols[_nFor,_nPosPrVend]
					aCols[_nFor,_nPosDESC]  :=  0
					aCols[_nFor,_nPosVALDESC]:=  0
					
					If _cOrigem $ "MTA410/TMKVFIM/TMKVPA/TLVENT/M410GET"
					   _lRetorno   := .T.
					ElseIf !Empty(ReadVar()) .And. !(Type(ReadVar())=="U") // !("M410LIOK" $ Upper(ProcName(1)))
				       _lRetorno   := &(ReadVar())
					EndIF
				
		
					//³ Se este programa (DIPG007) for chamada atraves do Ponto de ³
					//³ Entrada (M410LIOK) nao sera recalculado a margem do item.  ³
					
					//³ Calcula a margem minima do produto para venda.             ³
		            // _nMargemMin := Round( ((IIF(SB1->B1_PRVSUPE>0,SB1->B1_PRVSUPE,SB1->B1_PRVMINI) / (SB1->B1_UPRC+(SB1->B1_UPRC*SB1->B1_IPI/100))) - 1) * 100 ,2)
		            // O índice passa a ser calculado pelo B1_CUSDIP   MCVN - 30/10/2008
		            //_nMargemMin := Round( ((IIF(SB1->B1_PRVSUPE>0,SB1->B1_PRVSUPE,SB1->B1_PRVMINI) / (SB1->B1_CUSDIP)) - 1) * 100 ,2)                                
		
					// O índice passa a ser calculado pelo B1_LISFOR   MCVN - 26/03/2009           
		            //_nMargemMin := Round( ((IIF(SB1->B1_PRVSUPE>0,SB1->B1_PRVSUPE,SB1->B1_PRVMINI) / (SB1->B1_LISFOR)) - 1) * 100 ,2)
		            
		            // Se o fornecedor for AMCOR, NESTLE,3M e ROCHE o calculo dos índices é feito pelo B1_LISFOR
		            // caso contrário e feito pelo B1_CUSDIP 02/04/2009
		            //If SB1->B1_PROC $ '000041/000609/000334/000338/000183/100000/000630/000996/000997'
		            If SB1->B1_PROC$GetNewPar("ES_LISFOR","000041/000609/000334/000338/000183/100000/000630/000996/000997")
			            _nMargemMin := Round( ((IIF(SB1->B1_PRVSUPE>0,SB1->B1_PRVSUPE,SB1->B1_PRVMINI) / (SB1->B1_LISFOR)) - 1) * 100 ,2)
			        Else      
		   	            _nMargemMin := Round( ((IIF(SB1->B1_PRVSUPE>0,SB1->B1_PRVSUPE,SB1->B1_PRVMINI) / (SB1->B1_CUSDIP)) - 1) * 100 ,2)
			        Endif
		            
					//³ Avalia a tabela para definir a margem minima do produto.   ³
					IF                            _nMargemMin <= 21
						_nMargemMin := 19.96
					ElseIf _nMargemMin > 21 .and. _nMargemMin <= 22
						_nMargemMin := 20.76
					ElseIf _nMargemMin > 22 .and. _nMargemMin <= 23
						_nMargemMin := 21.76
					ElseIf _nMargemMin > 23 .and. _nMargemMin <= 24
						_nMargemMin := 22.76
					ElseIf _nMargemMin > 24 .and. _nMargemMin <= 25
						_nMargemMin := 23.76
					ElseIf _nMargemMin > 25 .and. _nMargemMin <= 26
						_nMargemMin := 24.76
					ElseIf _nMargemMin > 26 .and. _nMargemMin <= 27
						_nMargemMin := 25.68
					ElseIf _nMargemMin > 27 .and. _nMargemMin <= 28
						_nMargemMin := 26.68
					ElseIf _nMargemMin > 28 .and. _nMargemMin <= 29
						_nMargemMin := 27.68
					ElseIf _nMargemMin > 29 .and. _nMargemMin <= 30
						_nMargemMin := 28.68
					ElseIf _nMargemMin > 30 .and. _nMargemMin <= 32
						_nMargemMin := 29.68
					ElseIf _nMargemMin > 32 .and. _nMargemMin <= 34
						_nMargemMin := 31.62
					ElseIf _nMargemMin > 34 .and. _nMargemMin <= 36
						_nMargemMin := 33.62
					ElseIf _nMargemMin > 36 .and. _nMargemMin <= 38
						_nMargemMin := 35.62
					ElseIf _nMargemMin > 38 .and. _nMargemMin <= 40
						_nMargemMin := 37.54
					ElseIf _nMargemMin > 40 .and. _nMargemMin <= 42
						_nMargemMin := 39.54
					ElseIf _nMargemMin > 42 .and. _nMargemMin <= 44
						_nMargemMin := 41.44
					ElseIf _nMargemMin > 44 .and. _nMargemMin <= 46
						_nMargemMin := 43.40
					ElseIf _nMargemMin > 46 .and. _nMargemMin <= 48
						_nMargemMin := 45.38
					ElseIf _nMargemMin > 48 .and. _nMargemMin <= 50
						_nMargemMin := 47.36
					ElseIf _nMargemMin > 50 .and. _nMargemMin <= 53
						_nMargemMin := 49.40
					ElseIf _nMargemMin > 53 .and. _nMargemMin <= 56
						_nMargemMin := 52.40
					ElseIf _nMargemMin > 56 .and. _nMargemMin <= 59
						_nMargemMin := 55.40
					ElseIf _nMargemMin > 59 .and. _nMargemMin <= 61
						_nMargemMin := 58.30
					ElseIf _nMargemMin > 61 .and. _nMargemMin <= 65
						_nMargemMin := 60.30
					ElseIf _nMargemMin > 65 .and. _nMargemMin <= 69
						_nMargemMin := 64.30
					ElseIf _nMargemMin > 69 .and. _nMargemMin <= 75
						_nMargemMin := 68.20
					ElseIf _nMargemMin > 75 .and. _nMargemMin <= 80
						_nMargemMin := 74.20
					ElseIf _nMargemMin > 80 .and. _nMargemMin <= 88
						_nMargemMin := 79.00
					ElseIf _nMargemMin > 88
						_nMargemMin := 86.00
					EndIf
					
					//³ Atualiza aCols do produto em questao com a margem atual, minima e ³
					//³ ultimo preco de compra. 										  ³
		
		
					/*Calculo Antigo, desativado em 30/10/08 MCVN  
					aCols[_nFor,_nPosMrgAtu] := Round( (( aCols[_nFor,_nPosPrVend] / (SB1->B1_UPRC+(SB1->B1_UPRC*SB1->B1_IPI/100))) - 1) * 100 ,2) /20
					//aCols[_nFor,_nPosMrgIte] := _nMargemMin /20
					//aCols[_nFor,_nPosCusto]  := (SB1->B1_UPRC+(SB1->B1_UPRC*SB1->B1_IPI/100))
					aCols[_nFor,_nPosPrcMin] := (SB1->B1_UPRC+(SB1->B1_UPRC*SB1->B1_IPI/100)) + (((SB1->B1_UPRC+(SB1->B1_UPRC*SB1->B1_IPI/100)) *_nMargemMin ) / 100)*/
		             
					/* Novo calculo dos índices baseado no B1_CUSDIP   -   MCVN 30/10/2008  DESATIVADO 26/03/2009			
					aCols[_nFor,_nPosMrgAtu] := Round( (( aCols[_nFor,_nPosPrVend] / (SB1->B1_CUSDIP)) - 1) * 100 ,2) /20
					aCols[_nFor,_nPosMrgIte] := _nMargemMin /20		
					aCols[_nFor,_nPosCusto]  := (SB1->B1_CUSDIP)
					aCols[_nFor,_nPosPrcMin] := (SB1->B1_CUSDIP) + ((((SB1->B1_CUSDIP)) *_nMargemMin ) / 100)  */
					
					// Novo calculo dos índices baseado no B1_LISFOR   -   MCVN 26/03/2009	
					//	aCols[_nFor,_nPosMrgAtu] := Round( (( aCols[_nFor,_nPosPrVend] / (SB1->B1_LISFOR)) - 1) * 100 ,2) /20
					//	aCols[_nFor,_nPosMrgIte] := _nMargemMin /20		
					//	aCols[_nFor,_nPosCusto]  := (SB1->B1_LISFOR)
					//	aCols[_nFor,_nPosPrcMin] := (SB1->B1_LISFOR) + ((((SB1->B1_LISFOR)) *_nMargemMin ) / 100)
							
		            // Se o fornecedor for AMCOR, NESTLE,3M e ROCHE o calculo dos índices é feito pelo B1_LISFOR
		            // caso contrário e feito pelo B1_CUSDIP 02/04/2009
		            //If SB1->B1_PROC $ '000041/000609/000334/000338/000183/100000/000630/000996/000997'
		            If SB1->B1_PROC$GetNewPar("ES_LISFOR","000041/000609/000334/000338/000183/100000/000630/000996/000997")
						//aCols[_nFor,_nPosMrgAtu] := Round( (( aCols[_nFor,_nPosPrVend] / (SB1->B1_LISFOR)) - 1) * 100 ,2) /20  //-- Daniel Leme 12/07/2011
						aCols[_nFor,_nPosMrgAtu] := Round( (( (aCols[_nFor,_nPosPrVend]/_nFatorRecolh) / (SB1->B1_LISFOR)) - 1) * 100 ,2) /20
						aCols[_nFor,_nPosMrgIte] := _nMargemMin /20		
						aCols[_nFor,_nPosCusto]  := (SB1->B1_LISFOR)
						aCols[_nFor,_nPosPrcMin] := (SB1->B1_LISFOR) + ((((SB1->B1_LISFOR)) *_nMargemMin ) / 100)
					Else  
						//aCols[_nFor,_nPosMrgAtu] := Round( (( aCols[_nFor,_nPosPrVend] / (SB1->B1_CUSDIP)) - 1) * 100 ,2) /20  //-- Daniel Leme 12/07/2011
						aCols[_nFor,_nPosMrgAtu] := Round( (( (aCols[_nFor,_nPosPrVend]/_nFatorRecolh) / (SB1->B1_CUSDIP)) - 1) * 100 ,2) /20
						aCols[_nFor,_nPosMrgIte] := _nMargemMin /20		
						aCols[_nFor,_nPosCusto]  := (SB1->B1_CUSDIP)
						aCols[_nFor,_nPosPrcMin] := (SB1->B1_CUSDIP) + ((((SB1->B1_CUSDIP)) *_nMargemMin ) / 100)
					Endif
				
				EndIf
			EndIF
		EndIF
		
	Next
	
	_nMargAtuPed := ((_nVendaPed / _nCustoPed) -1 ) * 100 /20
	_nMargLib    := ((_nCustoMin / _nCustoPed) -1 ) * 100 /20
	
	// Inserido em 02/10/02 Zé Maria
	If "TMK"$FunName()
		M->UA_MARGATU := _nMargAtuPed
		M->UA_MARGLIB := _nMargLib
	    _NVENDAPED	+= M->UA_FRETE + M->UA_DESPESA   
	Else
		M->C5_MARGATU := _nMargAtuPed
		M->C5_MARGLIB := _nMargLib
	    _NVENDAPED   += M->C5_FRETE + M->C5_DESPESA   
	Endif
	
	// Faz o Refresh de todos os campos da Tela.
	_oDlgDefault := GetWndDefault()                          
	If Type("_oDlgDefault") <> "U"
		aEval(_oDlgDefault:aControls,{|x| IIf(Type("x")=="O",x:Refresh(),) })
	EndIf
		
	If Type("_lPassou") == "U"
		_lPassou := .T.
	EndIf
	
	_cMA := "IA"+Transform(_nMargAtuPed,"@E 9999.999")
	_cML := "IL"+Transform(_nMargLib,"@E 9999.999")   
	
	M->UA_MARGATU := _nMargAtuPed
	M->UA_MARGLIB := _nMargLib
	
	If ( Type("l410Auto") == "U" .OR. !l410Auto ) // JBS 12/04/2006
		IF Round(_nMargAtuPed,3) < Round(_nMargLib,3) .And. cEmpAnt<>"01"
			//³ Mostra na tela a margem atual do Pedido e sua margem minima. ³
			//     @ 002,310 SAY SPACE(160) SIZE 160,030
			//@ 002,315 GET _cMA When .F. SIZE 40,08 //OBJECT oMA
			//@ 002,355 GET _cML When .F. SIZE 40,08 //OBJECT oML
			
			IF _cOrigem $ "MTA410/TMKVPA"
				// Solicita senha para liberacao do pedido. 		           ³
		        If If(_cOrigem == "MTA410",M->C5_TIPO =='N'.AND.!M->C5_CLIENTE $ _cCliEspecial,;
	                                       !M->UA_CLIENTE $                      _cCliEspecial)	         
	
					If !U_DipSenha("MAR", "PED", Transform(_nMargAtuPed,"@E 9999.999"),Transform(_nMargLib,"@E 9999.999"),.f.)
	
						_lRetorno := U_Senha("MAR",_NVENDAPED,_nMargAtuPed,_nMargLib)
	
						If _lRetorno
							U_DipSenha("MAR", "PED", Transform(_nMargAtuPed,"@E 9999.999"),Transform(_nMargLib,"@E 9999.999"),.t.)
						EndIf
	
					Endif
	
				Else
					_lRetorno := .t.
				EndIf
	
			ElseIf _cOrigem == "TMKVFIM".and. lDipVpa .and. ;
				(Type("lTemTesDoacao") == "U" .or. !lTemTesDoacao) .and. ;
				(Type("lTemTesGerDup") == "U" .or. lTemTesGerDup)
				//³ Solicita senha para liberacao do pedido.
	
				If !Rtrim(ReadVar()) $ "M->UA_CONDPG/CCODPAGTO"
	
					If !M->UA_CLIENTE $ _cCliEspecial
	
						If !U_DipSenha("MAR", "PED", Transform(_nMargAtuPed,"@E 9999.999"),Transform(_nMargLib,"@E 9999.999"),.f.)
	
							_lRetorno := U_Senha("MAR",_NVENDAPED,_nMargAtuPed,_nMargLib)
	
							If _lRetorno
	
								U_DipSenha("MAR", "PED", Transform(_nMargAtuPed,"@E 9999.999"),Transform(_nMargLib,"@E 9999.999"),.t.)
	
							EndIf
	
						EndIf
					EndIf
				EndIf 
				
			ElseIf _cOrigem $ "TLVENT/M410GET"
	
				If !If(_cOrigem == "TLVENT", M->UA_CLIENTE, M->C5_CLIENTE) $ _cCliEspecial
					U_DipSenha("MAR", "PED", Transform(_nMargAtuPed,"@E 9999.999"),Transform(_nMargLib,"@E 9999.999"),.t.)
				EndIf
	
			Else
	
				//³ Mostra na tela a margem atual do Pedido e sua margem minima. ³
				//     @ 002,310 SAY SPACE(160) SIZE 160,030
			   //	@ 002,315 GET _cMA When .F. SIZE 40,08  //OBJECT oMA
			   //	@ 002,355 GET _cML When .F. SIZE 40,08  //OBJECT oML
			EndIf
	
		Else
			//³ Mostra na tela a margem atual do Pedido e sua margem minima. ³
			//     @ 002,310 SAY SPACE(160) SIZE 160,030
			//@ 002,315 GET _cMA When .F. SIZE 40,08  //OBJECT oMA
			//@ 002,355 GET _cML When .F. SIZE 40,08  //OBJECT oML
		EndIF
	ElseIf !Empty(ReadVar()) .And. !(Type(ReadVar())=="U") //!("M410LIOK"$ProcName(1))
		_lRetorno := &(ReadVar())
	EndIf
Else
	_lRetorno := 0
EndIf	                     

RestArea(_areaSB1)
RestArea(_xAlias)

Return(_lRetorno)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DIPG007   ºAutor  ³Microsiga           º Data ³  05/26/15   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User function VldCxFech(aCols,aHeader,nPos,nQtdInf)
Local lRet 		:= .T.  
Local nSaldoB2  := 0
Local nQtdCxEmb := 0
Local nPosPro 	:= aScan(aHeader,{|x| Alltrim(x[2])=="C6_PRODUTO"})
Local nPosQtd  	:= aScan(aHeader,{|x| Alltrim(x[2])=="C6_QTDVEN" })
Local nPosTES   := aScan(aHeader,{|x| Alltrim(x[2])=="C6_TES"    })
Local nPosLoc	:= aScan(aHeader,{|x| Alltrim(x[2])=="C6_LOCAL"  })
Local cMsgAviso := ""
Local cMsgSaldo := ""
DEFAULT aCols	:= {}
DEFAULT aHeader	:= {}
DEFAULT nPos 	:= n
DEFAULT nQtdInf := aCols[nPos,nPosQtd]        

If Len(aCols)>0
	SF4->(dbSetOrder(1))
	If SF4->(dbSeek(xFilial("SF4")+aCols[nPos,nPosTes])) .And. SF4->F4_ESTOQUE == "S" 
		If (cEmpAnt=="01" .And. aCols[nPos,nPosLoc]=="01") .Or. (cEmpAnt=="04" .And. aCols[nPos,nPosLoc]$"01/03/05/06")
			SB1->(DbSetOrder(1))
			If SB1->(DbSeek(xFilial("SB1")+aCols[nPos,nPosPro]))		
			    cCodPro := Alltrim(SB1->B1_COD)+" ("+SB1->B1_DESC+")"
				If SB1->B1_XCXFECH=="1"
					If SB1->B1_XVLDCXE=="1"
					    If SB1->B1_XTPEMBV=="1"
					    	nQtdCxEmb := SB1->B1_XQTDEMB
					    ElseIf SB1->B1_XTPEMBV=="2" 
					    	nQtdCxEmb := SB1->B1_XQTDSEC
					    Else             
					    	nQtdCxEmb := 1
						EndIf    
					    
						nSaldoB2 := u_DipSaldSB2(SB1->B1_XCODDES,.T.)
						
						If nSaldoB2>0 
							cMsgSaldo :=  "-> Este produto possui "+AllTrim(Str(nSaldoB2))+" "+AllTrim(SB1->B1_UM)
							cMsgSaldo +=  " disponíveis para venda fracionada no código: "+CHR(10)+CHR(13)
							cMsgSaldo +=  AllTrim(SB1->B1_XCODDES)+"-"+AllTrim(SB1->B1_DESC)
						EndIf                                                                                      
						If Mod(nQtdInf,nQtdCxEmb)<>0
							If EMPTY(SC5->C5_PEDECOM) //Exceção na validação de vendas por caixa fechada nos pedidos e-Commerce
								cMsgAviso := " -> O produto "+cCodPro+" só pode ser vendido em caixa fechada."+CHR(10)+CHR(13)
								cMsgAviso += "-> Venda múltiplos de "+AllTrim(Str(nQtdCxEmb))+CHR(10)+CHR(13)									
								lRet := .F.
							EndIf
						Endif
						If !Empty(cMsgAviso+cMsgSaldo)
							//Aviso("Atenção",cMsgAviso+cMsgSaldo,{"Ok"},3) // Alterada para facilitar o fechamento da tela.
							MsgInfo(cMsgAviso+cMsgSaldo,"ATenção!")
						EndIf
					Else 
						Aviso("Atenção","Produto "+cCodPro+" aguardando avaliação para venda em caixa fechada."+CHR(10)+CHR(13)+;
											  "Tente liberar o item mais tarde."+CHR(10)+CHR(13)+;
											  "Para previsão de liberação, entre em contato com o CD.",{"Ok"},2)
						lRet := .F.
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf
EndIf

Return lRet      
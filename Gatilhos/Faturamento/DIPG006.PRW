/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³DIPG006   ºAutor  ³   Alexandro Dias   º Data ³  08/11/01   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Mostra tabela de preco do produto em questao.              º±±
±±º          ³ Calcula comissao do vendedor conforme os % de desconto da  º±±
±±º          ³ tabela de preco do produto.                                º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

#include "rwmake.ch"
#include "tcbrowse.ch"

User Function DIPG006(_cOrig)
Local _cCliente
Local _oColuna
Local _nList
Local _lSaida
Local _aPreco
Local _nPosPrVend
Local _nPosPrvTot
Local _nPosPrUnit
Local _nPosQuant
Local _nPosComis1
Local _nPosValDes
Local _nPosDescon
Local _nPosMrgAtu
Local _nPosFornec
Local _nValor
Local _cGrupoDesc
Local _xAlias  := GetArea()
Local _areaSB1 := SB1->(getarea())
Local _areaSZ1 := SZ1->(getarea())
local _xL
local _nFor
Local _cFilialSZ1 := xFilial("SZ1")
//Local _nFatorRecolh := Iif(Left(M->C5_XRECOLH,3) == "ACR", 1.16, 1)
Local _nFatorRecolh := 1 //Iif(substr(M->C5_XRECOLH,1,3) $ "ACR/REC/ISE" , 1.06, 1) //giovani - alterar valor do fator de conversão para 1.06 e se o cliente for fora do estado de sp
Local _lConsNC := .F.
Local _nPerc   := 0
Local _lVendOk := .F.

U_DIPPROC(ProcName(0),U_DipUsr()) // MCVN - 22/01/2009 

IF !("TMK"$FunName())  .and. !("DIPAL10" $ FunName()) .And. _cOrig<>"O" //giovani 19/07/11
	If substr(M->C5_XRECOLH,1,3) $ "ACR"
		_nFatorRecolh:= 1.16
	ElseIf substr(M->C5_XRECOLH,1,3) $ "ISE"
		_nFatorRecolh:= 1.06
	Else
		_nFatorRecolh:= 1
	EndIf
	
EndIf

IF "TMK"$FunName()
	_nPosProdut := aScan(aHeader, { |x| Alltrim(x[2]) == "UB_PRODUTO"})
	_nPosPrVend := aScan(aHeader, { |x| Alltrim(x[2]) == "UB_VRUNIT" })
	_nPosPrcTab := aScan(aHeader, { |x| Alltrim(x[2]) == "UB_PRCTAB" })
	_nPosPrvTot := aScan(aHeader, { |x| Alltrim(x[2]) == "UB_VLRITEM"})
	_nPosPrUnit := aScan(aHeader, { |x| Alltrim(x[2]) == "UB_VRUNIT" })
	_nPosQuant  := aScan(aHeader, { |x| Alltrim(x[2]) == "UB_QUANT"  })
	_nPosComis1 := aScan(aHeader, { |x| Alltrim(x[2]) == "UB_COMIS1" })
	_nPosValDes := aScan(aHeader, { |x| Alltrim(x[2]) == "UB_VALDESC"})
	_nPosDescon := aScan(aHeader, { |x| Alltrim(x[2]) == "UB_DESC"   })
	_nPosMrgAtu := aScan(aHeader, { |x| Alltrim(x[2]) == "UB_MARGATU"})
	_nPosFornec := aScan(aHeader, { |x| Alltrim(x[2]) == "UB_FORNEC" })
	_nPosTes    := aScan(aHeader,  {|x| Alltrim(x[2]) == "UB_TES"    })
	
ElseIf "DIPAL10" $ FunName()//MCVN - 28/06/07
	_nPosProdut := aScan(aHeader, { |x| Alltrim(x[2]) == "UA4_PRODUT"})

	IF Alltrim(ReadVar()) $ "M->UA4_PRCVEN" //MCVN - 28/08/2007
		_nPosPrVend := aScan(aHeader, { |x| Alltrim(x[2]) == "UA4_PRCVEN" })
	Else                                                                
		_nPosPrVend := aScan(aHeader, { |x| Alltrim(x[2]) == "UA4_PRCMIN" })
	Endif

	_nPosPrcTab := 0//aScan(aHeader, { |x| Alltrim(x[2]) == "UB_PRCTAB" })
	_nPosPrvTot := 0//aScan(aHeader, { |x| Alltrim(x[2]) == "UB_VLRITEM"})
	_nPosPrUnit := 0//aScan(aHeader, { |x| Alltrim(x[2]) == "UB_VRUNIT" })
	_nPosQuant  := aScan(aHeader, { |x| Alltrim(x[2]) == "UA4_QUANT"  })
	_nPosComis1 := 0//aScan(aHeader, { |x| Alltrim(x[2]) == "UB_COMIS1" })
	_nPosValDes := 0//aScan(aHeader, { |x| Alltrim(x[2]) == "UB_VALDESC"})
	_nPosDescon := 0//aScan(aHeader, { |x| Alltrim(x[2]) == "UB_DESC"   })
	_nPosMrgAtu := 0//aScan(aHeader, { |x| Alltrim(x[2]) == "UB_MARGATU"})
	_nPosFornec := 0//aScan(aHeader, { |x| Alltrim(x[2]) == "UB_FORNEC" })
	_nPosTes    := aScan(aHeader,  {|x| Alltrim(x[2]) == "UA4_TES"    })
Else
	_nPosProdut := aScan(aHeader, { |x| Alltrim(x[2]) == (IIF(_cOrig=="O","CK","C6")+"_PRODUTO") })
	_nPosPrVend := aScan(aHeader, { |x| Alltrim(x[2]) == (IIF(_cOrig=="O","CK","C6")+"_PRCVEN" ) })
	_nPosPrcTab := aScan(aHeader, { |x| Alltrim(x[2]) == (IIF(_cOrig=="O","CK","C6")+"_PRUNIT" ) })
	_nPosPrvTot := aScan(aHeader, { |x| Alltrim(x[2]) == (IIF(_cOrig=="O","CK","C6")+"_VALOR"  ) })
	_nPosPrUnit := aScan(aHeader, { |x| Alltrim(x[2]) == (IIF(_cOrig=="O","CK","C6")+"_PRUNIT" ) })
	_nPosQuant  := aScan(aHeader, { |x| Alltrim(x[2]) == (IIF(_cOrig=="O","CK","C6")+"_QTDVEN" ) })
	_nPosComis1 := aScan(aHeader, { |x| Alltrim(x[2]) == (IIF(_cOrig=="O","CK","C6")+"_COMIS1" ) })
	_nPosValDes := aScan(aHeader, { |x| Alltrim(x[2]) == (IIF(_cOrig=="O","CK","C6")+"_VALDESC") })
	_nPosDescon := aScan(aHeader, { |x| Alltrim(x[2]) == (IIF(_cOrig=="O","CK","C6")+"_DESCONT") })
	_nPosMrgAtu := aScan(aHeader, { |x| Alltrim(x[2]) == (IIF(_cOrig=="O","CK","C6")+"_MARGATU") })
	_nPosFornec := aScan(aHeader, { |x| Alltrim(x[2]) == (IIF(_cOrig=="O","CK","C6")+"_FORNEC" ) })
Endif

If ( Type("l410Auto") == "U" .OR. !l410Auto )
	IF _cOrig == "O"
		//³ ** Quando a rotina de origem for Orcamento, observar outros ³
		//³ tratamentos abaixo.                                         ³
		//Iif("DIPAL10" $ FunName(),_cCliente := M->UA1_CODCLI,_cCliente := M->CJ_CLIENTE) //MCVN - 28/06/07
		_cCliente := M->CJ_CLIENTE//MCVN - 28/06/07
	Elseif "DIPAL10" $ FunName()
		_cCliente := M->UA1_CODCLI
	Else
		_cCliente := IIF("TMK"$FunName(),M->UA_CLIENTE,M->C5_CLIENTE)
	EndIF
	
	IF Empty(_cCliente)
		MsgBox("Informe o cliente para consultar a tabela de Preco !!!","Atencao","Alert")
		IF _cOrig != "O"  .And. !("DIPAL10" $ Funname())
			For _xL := 2 to Len(aHeader)
				aCols[n,_xL] := CriaVar(aHeader[_xL,2])
			Next
		EndIF    
		
		_nValor := 0
		
		//MCVN - 13/07/2007
		If "DIPAL10" $ Funname()
		    IF Alltrim(ReadVar()) $ "M->UA4_PRCVEN"//MCVN - 28/08/2007
  			    M->UA4_PRCVEN := _nValor
			Else	    
			    M->UA4_PRCMIN := _nValor
			Endif
			   
	        Return(.T.)
		Endif   
		
		Return(_nValor)
	EndIF
	
	_nList  := 1
	_nForn  := SPACE(6)
	_lSaida := .F.
	_aPreco := {}
	
	
	IF  Alltrim(ReadVar()) $ "M->C6_QTDVEN/M->C6_PRODUTO/M->CK_QTDVEN/M->CK_PRODUTO/M->UB_QUANT/M->UB_PRODUTO/M->UA4_QUANT/M->UA4_PRODUT/"
		IF _cOrig != "O" 
			_nValor := IIF(aCols[n,_nPosPrUnit]<=0,if(SB1->B1_PRVSUPE>0,SB1->B1_PRVSUPE,SB1->B1_PRVMINI), aCols[n,_nPosPrVend])
		ELSE
			_nValor := 0
		ENDIF
	Else
	    If _cOrig == "MTA410"  // MCVN - 14/08/09   
    		_nValor := &("M->C6_PRCVEN")
	    Else
			_nValor := &(ReadVar())
		Endif
	EndIF
	
	
	IF _cOrig != "O"
		DbSelectArea("SB1")
		DbSetOrder(1)
		DbSeek(xFilial("SB1")+aCols[n,_nPosProdut])
	EndIf
	
	//³ Avalia se o desconto sera pelo grupo do cliente ou por produto. ³
	_cGrupoDesc := IIF(Empty(SA1->A1_GRPDESC),"999999",SA1->A1_GRPDESC)
	_nForn   := SB1->B1_PROC // aCols[n,_nPosFornec]
	_lConsNC := (SA1->A1_TIPO == "F" .And. SA1->A1_CONTRIB == "2" .And. SA1->A1_ESTE <> "SP")    
	u_DipAcrCli(1,SA1->A1_COD,SA1->A1_LOJA,SB1->B1_COD,@_nPerc)	  
	
	_nPerc := 1+(_nPerc/100)         
	
	If !(Alltrim(ReadVar())$"M->C6_PRCVEN/M->CK_PRCVEN/M->UB_VRUNIT/M->UA4_PRCMIN/M->UA4_PRCVEN") .Or. _nValor<=0
		If _lConsNC		
			
			_nValor := _nValor*_nPerc
		EndIf  
		                
		If !("TMK"$FunName()) .And. !("DIPAL10" $ Funname()) .And. (Type("l410Auto")=="U" .Or. !l410Auto)
			If Alltrim(Posicione("SU7",1,xFilial("SU7")+M->C5_OPERADO,"U7_POSTO"))=="02"   
				If u_VldCifRev(M->C5_NUM,"M",.T.) .And. M->C5_TPFRETE == "C"
					ZZB->(dbSetOrder(1))
					If ZZB->(dbSeek(xFilial("ZZB")+M->C5_ESTE))			
						If  M->C5_ESTE <> "SP" .Or. (M->C5_ESTE == "SP" .And. "DEMAIS CIDADES"$M->C5_DESTFRE)      
							_nValor += Round(_nValor*(ZZB->ZZB_PERC/100),4)
						EndIf                                         				
					EndIf			                                  
				EndIf
			EndIf
		EndIf		
	EndIf
	
	_lVendOk := Iif("TMK"$FunName(),M->UA_VEND,Iif("DIPAL10"$FunName(),M->UA1_VEND,If(Type("M->C5_VEND1")<>"U",M->C5_VEND1,""))) <> '006684'
			
	DbSelectArea("SZ1")
	DbSetOrder(2)
	IF DbSeek(_cFilialSZ1+_cGrupoDesc+_nForn)
		
		While SZ1->(!Eof()) .AND. SZ1->Z1_FILIAL == _cFilialSZ1 .And. SZ1->Z1_SEGMENT == _cGrupoDesc .AND. SZ1->Z1_FORNEC == _nForn
			IF SZ1->Z1_TIPO == "1" // Lista Cheia
				IF SB1->B1_PRV1 > 0               
				
					AAdd( _aPreco,{ SZ1->Z1_DESCRIC,;
									Round(SB1->B1_PRV1*IIf(_lConsNC,_nPerc,1),4),;
									0,;
									SZ1->Z1_COMISSA,;
									SZ1->Z1_TIPO,;
									SZ1->Z1_LETRA } )
									
				EndIF
			ElseIF SZ1->Z1_TIPO == "3" // C
				IF SB1->B1_PRVMINI > 0 .And. _lVendOk

					AAdd( _aPreco,{ SZ1->Z1_DESCRIC,; 
									Round(SB1->B1_PRVMINI*IIf(_lConsNC,_nPerc,1),4),;
									0,;
									SZ1->Z1_COMISSA,;
									SZ1->Z1_TIPO,;
									SZ1->Z1_LETRA } )

				EndIF
			ElseIF SZ1->Z1_TIPO == "4" // D
				IF SB1->B1_PRVPROM > 0

					AAdd( _aPreco,{ SZ1->Z1_DESCRIC,;
									Round(SB1->B1_PRVPROM*IIf(_lConsNC,_nPerc,1),4),;
									0,;
									SZ1->Z1_COMISSA,;
									SZ1->Z1_TIPO,;
									SZ1->Z1_LETRA } )

				EndIF
			ElseIF SZ1->Z1_TIPO == "5"  // Promocao
				IF SB1->B1_PRVSUPE > 0 .And. _lVendOk
					
					AAdd( _aPreco,{ SZ1->Z1_DESCRIC,;
									Round(SB1->B1_PRVSUPE*IIf(_lConsNC,_nPerc,1),4),;
									0,;
									SZ1->Z1_COMISSA,;
									SZ1->Z1_TIPO,;
									SZ1->Z1_LETRA } )
									

				EndIf
			ElseIF SZ1->Z1_TIPO == "6"  // Abaixo do C
				If _lVendOk

					AAdd( _aPreco,{ SZ1->Z1_DESCRIC,;
									0,;
									0,;
									SZ1->Z1_COMISSA,;
									SZ1->Z1_TIPO,SZ1->Z1_LETRA } )
									
				EndIf
			Else
				AAdd(_aPreco,{  SZ1->Z1_DESCRIC,; 
								Round((SB1->B1_PRV1-(SB1->B1_PRV1*SZ1->Z1_PERCENT/100))*IIf(_lConsNC,_nPerc,1),4),;
								SZ1->Z1_PERCENT,;
								SZ1->Z1_COMISSA,;
								SZ1->Z1_TIPO,;
								SZ1->Z1_LETRA } )
			EndIF
			DbSkip()
		EndDo
		
		//³ Ordena por ordem de preco com desconto. 				   ³
		aSort( _aPreco ,,, {|a,b| a[2] < b[2]} )
		
		IF Alltrim(ReadVar()) $ "M->C6_PRCVEN/M->CK_PRCVEN/M->UB_VRUNIT/M->UA4_PRCMIN/M->UA4_PRCVEN"
			If _nValor <=0
				
				//³ A tabela de preco e visualizada somente quando o usuario   ³
				//³ informa 0 (Zero) no campo Preco do produto.                ³
				@ 150,400 TO 410,630 DIALOG oDlg TITLE "Tabela de Preco "+SB1->B1_COD
				_oColuna := TCBROWSE():New(005,010,105,120,,,,oDlg,,,,,;
				{||(_lSaida:=.T.,_nList:=_oColuna:nAt,IIF(_aPreco[_nList,2]>0,Close(oDlg),.T.))};
				,,,,,,,.F.,,.T.,,.F.,,)
				_oColuna:SetArray(_aPreco)
				ADD COLUMN TO _oColuna HEADER "Descricao   " OEM DATA {|| _aPreco[_oColuna:nAt,01] } SIZE 040 PIXEL
				ADD COLUMN TO _oColuna HEADER "Preco Venda " OEM DATA {|| Transform(_aPreco[_oColuna:nAt,02],"@E 999,999.9999") } SIZE 040 PIXEL
				ADD COLUMN TO _oColuna HEADER "Letra "       OEM DATA {|| _aPreco[_oColuna:nAt,06] } SIZE 030 PIXEL
				
				oDlg:LESCCLOSE := .f. // Desabilita a tecla ESC
				
				ACTIVATE DIALOG oDlg
				
				_nValor := ROUND(_aPreco[_nList,2],4)
				/*
				IF _lSaida
				// Atualiza valores do aCols - VALOR UNITARIO
				_nValor := _aPreco[_nList,2]
				EndIF
				*/
			EndIf
		EndIF
		IF _cOrig != "O" .And. !("DIPAL10" $ Funname())
			
			//³ Calcula os valores do aCols (comissao, % desconto e desconto em valor) ³
			//³ conforme o preco de venda informado pelo usuario, e atualiza o aCols.  ³
			//³ ** Somente se a rotina origem nao for Orcamento.                       ³

			For _nFor := 1 to Len(_aPreco)
				IF ( Round(_nValor,3) < Round(_aPreco[_nFor,2],4) )
					
					//³ Se o valor digitado pelo usuario for Menor que o preco da tabela. ³
					aCols[n,_nPosComis1] := _aPreco[_nFor,4]
					aCols[n,_nPosDescon] := 0 /// ((aCols[n,_nPosPrUnit] - _nValor) * 100) / aCols[n,_nPosPrUnit]
					aCols[n,_nPosValDes] := 0 /// (aCols[n,_nPosPrUnit] - _nValor) * aCols[n,_nPosQuant]
					Exit
  				ElseIF ( ( Round(_nValor,4) >= Round(_aPreco[_nFor,2],4) ) .and. ( Round(_nValor,4) < Round(_aPreco[IIF((_nFor+1)>=Len(_aPreco),Len(_aPreco),_nFor+1),2],4) ) )
					                                              
					//³ Se o valor digitado pelo usuario for Maior ou Igual e Menor que o proximo preco da tabela. ³
					aCols[n,_nPosComis1] := _aPreco[_nFor,4]
					aCols[n,_nPosDescon] := 0 /// ((aCols[n,_nPosPrUnit] - _nValor) * 100) / aCols[n,_nPosPrUnit]
					aCols[n,_nPosValDes] := 0 /// (aCols[n,_nPosPrUnit] - _nValor) * aCols[n,_nPosQuant]
					Exit
				ElseIF ( ( Round(_nValor,4) >= Round(_aPreco[_nFor,2],4)) .and. ( _nFor == Len(_aPreco)) )
					
					//³ Se o valor digitado pelo usuario for Maior ou Igual ao Maior preco da tabela. ³
					aCols[n,_nPosComis1] := _aPreco[_nFor,4] //-1,4]
					aCols[n,_nPosDescon] := 0
					aCols[n,_nPosValDes] := 0
					Exit
				EndIF
			Next
			//³ Atualiza valores do item.                                  ³
			If !(_cOrig == "MTA410") // MCVN - 14/08/09 
				aCols[n,_nPosPrVend] := _nValor
				aCols[n,_nPosPrcTab] := _nValor
				aCols[n,_nPosPrvTot] := ROUND(aCols[n,_nPosQuant] * aCols[n,_nPosPrVend],2)
			Endif
		EndIF
		
		//³ Chama funcao para calculo da margem dos itens e do pedido, ³
		//³ ** Caso a rotina origem nao seja Orcamento.                ³
		IF _cOrig != "O" .and. !("DIPAL10" $ Funname())  .And. !(_cOrig == "MTA410") // MCVN - 14/08/09 
			U_DIPG007("DIPG006")
		EndIF
	Else
		DbSelectArea("SZ1")
		DbSetOrder(2)
		IF DbSeek(_cFilialSZ1+_cGrupoDesc+"      ")
			
			While SZ1->(!Eof()) .AND. SZ1->Z1_FILIAL == _cFilialSZ1 .And. SZ1->Z1_SEGMENT == _cGrupoDesc .AND. SZ1->Z1_FORNEC == "      "
				IF SZ1->Z1_TIPO == "1" // Lista Cheia
					IF SB1->B1_PRV1 > 0
					
						AAdd( _aPreco,{	SZ1->Z1_DESCRIC,;
										Round(SB1->B1_PRV1*IIf(_lConsNC,_nPerc,1),4),;
										0,;
										SZ1->Z1_COMISSA,;
										SZ1->Z1_TIPO,;
										SZ1->Z1_LETRA } )
										
					EndIF
				ElseIF SZ1->Z1_TIPO == "3" // C
					IF SB1->B1_PRVMINI > 0 .And. _lVendOk

						AAdd( _aPreco,{	SZ1->Z1_DESCRIC,;
										Round(SB1->B1_PRVMINI*IIf(_lConsNC,_nPerc,1),4),;
										0,;
										SZ1->Z1_COMISSA,;
										SZ1->Z1_TIPO,;
										SZ1->Z1_LETRA } )

					EndIf
				ElseIF SZ1->Z1_TIPO == "4" // D
					IF SB1->B1_PRVPROM > 0
					
						AAdd( _aPreco,{	SZ1->Z1_DESCRIC,;
										Round(SB1->B1_PRVPROM*IIf(_lConsNC,_nPerc,1),4),;
										0,;
										SZ1->Z1_COMISSA,;
										SZ1->Z1_TIPO,;
										SZ1->Z1_LETRA } )
						
					EndIF
				ElseIF SZ1->Z1_TIPO == "5"  // Promocao
					IF SB1->B1_PRVSUPE > 0 .And. _lVendOk                                                                              
					
						AAdd( _aPreco,{	SZ1->Z1_DESCRIC,;
										Round(SB1->B1_PRVSUPE*IIf(_lConsNC,_nPerc,1),4),;
										0,;
										SZ1->Z1_COMISSA,;
										SZ1->Z1_TIPO,;
										SZ1->Z1_LETRA } )

					EndIF
				ElseIF SZ1->Z1_TIPO == "6"  // Abaixo do C
					If _lVendOk          
					
						AAdd( _aPreco,{	SZ1->Z1_DESCRIC,;
										0,;
										0,;
										SZ1->Z1_COMISSA,;
										SZ1->Z1_TIPO,;
										SZ1->Z1_LETRA } )
					EndIf
				Else
					AAdd(_aPreco,{	SZ1->Z1_DESCRIC,;
									Round((SB1->B1_PRV1-(SB1->B1_PRV1*SZ1->Z1_PERCENT/100))*IIf(_lConsNC,_nPerc,1),4),;
									SZ1->Z1_PERCENT,;
									SZ1->Z1_COMISSA,;
									SZ1->Z1_TIPO,;
									SZ1->Z1_LETRA } )
				EndIF
				DbSkip()
			EndDo
			
			//³ Ordena por ordem de preco com desconto. 				   ³
			aSort( _aPreco ,,, {|a,b| a[2] < b[2]} )
			
			IF Alltrim(ReadVar()) $ "M->C6_PRCVEN/M->CK_PRCVEN/M->UB_VRUNIT/M->UA4_PRCMIN/M->UA4_PRCVEN"
				IF  _nValor <=0
					//³ A tabela de preco e visualizada somente quando o usuario   ³
					//³ informa 0 (Zero) no campo Preco do produto.                ³
					@ 150,400 TO 410,630 DIALOG oDlg TITLE "Tabela de Preco "+SB1->B1_COD
					_oColuna := TCBROWSE():New(005,010,105,120,,,,oDlg,,,,,{||(_lSaida:=.T.,_nList:=_oColuna:nAt,;
					IIF(_aPreco[_nList,2]>0,Close(oDlg),.T.))},,,,,,,.F.,,.T.,,.F.,,)
					_oColuna:SetArray(_aPreco)
					ADD COLUMN TO _oColuna HEADER "Descricao   " OEM DATA {|| _aPreco[_oColuna:nAt,01] } SIZE 040 PIXEL
					ADD COLUMN TO _oColuna HEADER "Preco Venda " OEM DATA {|| Transform(_aPreco[_oColuna:nAt,02],"@E 999,999.9999") } SIZE 040 PIXEL
					ADD COLUMN TO _oColuna HEADER "Letra "       OEM DATA {|| _aPreco[_oColuna:nAt,06] } SIZE 030 PIXEL
					
					oDlg:LESCCLOSE := .f. // Desabilita a tecla ESC
					
					ACTIVATE DIALOG oDlg
					_nValor := ROUND(_aPreco[_nList,2],4) 

					/*
					IF _lSaida
					//³ Atualiza valores do aCols, comissao, % desconto e desconto em valor. ³
					Else
					//	aqui			IF _cOrig != "O"
					//					_nValor := Round((SB1->B1_UPRC+(SB1->B1_UPRC*SB1->B1_IPI/100)) + (((SB1->B1_UPRC+(SB1->B1_UPRC*SB1->B1_IPI/100)) * aCols[n,_nPosMrgAtu]) / 100),3)
					//				Else
					_nValor := 0
					//				EndIF
					EndIF
					*/
				EndIf
			EndIF
			IF _cOrig != "O"  .And. !("DIPAL10" $ Funname())
				
				//³ Calcula os valores do aCols (comissao, % desconto e desconto em valor) ³
				//³ conforme o preco de venda informado pelo usuario, e atualiza o aCols.  ³
				//³ ** Somente se a rotina origem nao for Orcamento.                       ³
				For _nFor := 1 to Len(_aPreco)
					//IF ( Round( _nValor ,3) < Round(_aPreco[_nFor,2],3) ) //-- Daniel Leme 12/07/2011
					IF ( Round( (_nValor/_nFatorRecolh) ,4) < Round(_aPreco[_nFor,2],4) )
						
						//³ Se o valor digitado pelo usuario for Menor que o preco da tabela. ³
						aCols[n,_nPosComis1] := _aPreco[_nFor,4]
						aCols[n,_nPosDescon] := 0  ///((aCols[n,_nPosPrUnit] - _nValor) * 100) / aCols[n,_nPosPrUnit]
						aCols[n,_nPosValDes] := 0  //// (aCols[n,_nPosPrUnit] - _nValor) * aCols[n,_nPosQuant]
						Exit
					//ElseIF ( ( Round(_nValor,3) >= Round(_aPreco[_nFor,2],3) ) .and. ( Round(_nValor,3) < Round(_aPreco[IIF((_nFor+1)>=Len(_aPreco),Len(_aPreco),_nFor+1),2],3) ) )
					ElseIF ( ( Round((_nValor/_nFatorRecolh),4) >= Round(_aPreco[_nFor,2],4) ) .and. ( Round((_nValor/_nFatorRecolh),4) < Round(_aPreco[IIF((_nFor+1)>=Len(_aPreco),Len(_aPreco),_nFor+1),2],4) ) )
						
						//³ Se o valor digitado pelo usuario for Maior ou Igual e Menor que o proximo preco da tabela. ³
						aCols[n,_nPosComis1] := _aPreco[_nFor,4]
						aCols[n,_nPosDescon] := 0  ///((aCols[n,_nPosPrUnit] - _nValor) * 100) / aCols[n,_nPosPrUnit]
						aCols[n,_nPosValDes] := 0  /////  (aCols[n,_nPosPrUnit] - _nValor) * aCols[n,_nPosQuant]
						Exit
					//ElseIF ( ( Round(_nValor,3) >= Round(_aPreco[_nFor,2],3)) .and. ( _nFor == Len(_aPreco)) )
					ElseIF ( ( Round((_nValor/_nFatorRecolh),4) >= Round(_aPreco[_nFor,2],4)) .and. ( _nFor == Len(_aPreco)) )
						
						//³ Se o valor digitado pelo usuario for Maior ou Igual ao Maior preco da tabela. ³
						aCols[n,_nPosComis1] := _aPreco[_nFor,4] //-1,4]
						aCols[n,_nPosDescon] := 0
						aCols[n,_nPosValDes] := 0
						Exit
					EndIF
				Next
				           
				If !(_cOrig == "MTA410")				 // MCVN - 14/08/09 
				//³ Atualiza valores do item.                                  ³
					aCols[n,_nPosPrVend] := _nValor
					aCols[n,_nPosPrcTab] := _nValor
					aCols[n,_nPosPrvTot] := ROUND(aCols[n,_nPosQuant] * aCols[n,_nPosPrVend],2)
				Endif
			EndIF
			
			//³ Chama funcao para calculo da margem dos itens e do pedido, ³
			//³ ** Caso a rotina origem nao seja Orcamento.                ³
			IF _cOrig != "O" .And. !("DIPAL10" $ Funname()) .And. !(_cOrig == "MTA410") // MCVN - 14/08/09 
				U_DIPG007("DIPG006")
			EndIF
		Else
			_nValor := 0
		EndIF
	EndIF
	
	// ESTES 8.11
	IF "TMK" $ FunName() // atualiza rodape se for CALL CENTER
		
		M->UB_VRUNIT := _nVALOR
		
		//aCols[N][_nPosPrvTot ] := _nValor // Valor total do item
		
		MaFisRef("IT_VALMERC","TK273",aCols[N,_nPosPrvTot])
		MaFisRef("IT_TES","TK273"    ,aCols[N,_nPosTES])
		
		// Atualiza totais da tela
		Tk273Trigger()
		
	Endif
	
	//MCVN - 13/07/2007
	If "DIPAL10" $ Funname()
	    IF Alltrim(ReadVar()) $ "M->UA4_PRCVEN"//MCVN - 28/08/2007
		    M->UA4_PRCVEN := _nValor
		Else	    
		    M->UA4_PRCMIN := _nValor
		Endif
	   
	   Return(.T.)
	Endif                
	
	RestArea(_areaSB1)
	RestArea(_areaSZ1)
	RestArea(_xAlias)
	
Else  // JBS 13/06/2006          
	_nValor :=  aCols[N,_nPosPrVend] // JBS 13/06/2006          
//	M->C6_QTDVEN  := aCols[N,_nPosQuant] // JBS 14/06/2006
Endif 
                                  
Return(_nValor)
#INCLUDE "FIVEWIN.CH"
#INCLUDE "FONT.CH"
#INCLUDE "COLORS.CH"

/*====================================================================================\
|Programa  | DIPG008       | Autor | RODRIGO FRANCO             | Data | 10/08/2001   |
|=====================================================================================|
|Descri็ใo | Mensagem para produtos Habilitados ou nao                                |
|          |                                                                          |
|          |                                                                          |
|=====================================================================================|
|Sintaxe   | DIPG008                                                                  |
|=====================================================================================|
|Uso       | Especifico DIPROMED                                                      |
|=====================================================================================|
|........................................Hist๓rico....................................|
|Rafael    | DD/MM/AA - Descri็ใo                                                     |
|Eriberto  | DD/MM/AA - Descri็ใo                                                     |
|Rafael    | 24/01/05 - Apresentar estoque do produto alternativo                     |
|GIOVANI   | 16/06/2011 - INCUBADORA CLEAN TRACE                                      |
\====================================================================================*/

#xtranslate bSETGET(<uVar>) => {|u| If(PCount() == 0, <uVar>, <uVar> := u) }
#Translate MSGBOX( => IW_MsgBox(

User Function DIPG008()
Local _aArea   	 := GetArea()
Local _aAreaSB1	 := SB1->(GetArea())
Local _Retorno   := .T.   
Local _cMsg      := ""  
Local _cProdAnt  := "" // Guardar o produto anterior  MCVN - 18/10/2007
Local _cFornVend := AllTrim(GETNEWPAR("MV_FORNVEN",""))  
Local _cCliente  := IF("DIPAL10" $ FunName(),M->UA1_CODCLI+M->UA1_LOJA,IIF("TMK"$FunName(),M->UA_CLIENTE+M->UA_LOJA,M->C5_CLIENTE+M->C5_LOJACLI))  //MCVN - 30/08/2007
Local _cUf       := POSICIONE("SA1",1,xFilial("SA1")+_cCliente,"A1_EST") //MCVN - 30/08/2007
Local _nPos		 := 0
Local _nPosVrUnit:= aScan(aHeader, { |x| Alltrim(x[2]) == IF("DIPAL10" $ FunName(),"UA4_PRCVEN",IIF("TMK"$FunName(),"UB_VRUNIT","C6_PRCVEN")) })    //MCVN - 15/02/2007 Alterado para compatibilizar com Licita็๕es
Local _nPosItem	 := aScan(aHeader, { |x| Alltrim(x[2]) == "C6_ITEM"    })
Local _nPosValor := aScan(aHeader, { |x| Alltrim(x[2]) == IF("DIPAL10" $ FunName(),"UA4_VALOR",  IIF("TMK"$FunName(),"UB_VLRITEM","C6_VALOR")) })   //MCVN - 15/02/2007 Alterado para compatibilizar com Licita็๕es
Local _nPosUPrc  := aScan(aHeader, { |x| Alltrim(x[2]) == IF("DIPAL10" $ FunName(),"UA4_USERPRC",IIF("TMK"$FunName(),"UB_USERPRC","C6_USERPRC")) }) //MCVN - 15/02/2007 Alterado para compatibilizar com Licita็๕es
Local _nPosUPrd  := aScan(aHeader, { |x| Alltrim(x[2]) == "UB_USEPROD" })
Local _nPosProd  := aScan(aHeader, { |x| Alltrim(x[2]) == IF("DIPAL10" $ FunName(),"UA4_PRODUT", IIF("TMK"$FunName(),"UB_PRODUTO","C6_PRODUTO")) }) //MCVN - 15/02/2007 Alterado para compatibilizar com Licita็๕es
Local _nPosUDes  := aScan(aHeader, { |x| Alltrim(x[2]) == IF("DIPAL10" $ FunName(),"UA4_USERDES",IIF("TMK"$FunName(),"UB_USERDES","C6_USERDES")) }) //MCVN - 15/02/2007 Alterado para compatibilizar com Licita็๕es
Local _nPosQuant := aScan(aHeader, { |x| Alltrim(x[2]) == IF("DIPAL10" $ FunName(),"UA4_QUANT",  IIF("TMK"$FunName(),"UB_QUANT","C6_QTDVEN")) })    //MCVN - 15/02/2007 Alterado para compatibilizar com Licita็๕es
Local _nPPrcTab  := aScan(aHeader, { |x| Alltrim(x[2]) == IF("DIPAL10" $ FunName(),"UA4_PRCMIN", IIF("TMK"$FunName(),"UB_PRCTAB","C6_PRUNIT")) })   //MCVN - 15/02/2007 Alterado para compatibilizar com Licita็๕es
Local _nPosDesc  := aScan(aHeader, { |x| Alltrim(x[2]) == IF("DIPAL10" $ FunName(),"UA4_DPRODU", IIF("TMK"$FunName(),"UB_DESC","C6_DESCRI")) })  


//Corrigindo erro de posicionamento no SB1 - MCVN - 26/07/09
SB1->(DbSetOrder(1))       
If "DIPAL10" $ FunName() .AND. Type("M->UA4_PRODUT") <> "U"    
	SB1->(DbSeek(xFilial("SB1")+M->UA4_PRODUT))     
Else                                                
	SB1->(DbSeek(xFilial("SB1")+M->C6_PRODUTO))     
Endif
	

If ( Type("l410Auto") == "U" .OR. !l410Auto )
	
	U_DIPPROC(ProcName(0),U_DipUsr()) // JBS 05/10/2005 - Gravando o nome do Programa no SZU

	If Readvar()=="M->C6_PRODUTO"
		_Retorno := u_VldAltDig(aCols[n,_nPosProd],M->C6_PRODUTO,M->C5_NUM)
	EndIf
	
	IF "TMK"$FunName()
		
		If Acols[n,_nPosUPrc] > 0 .And. Acols[n,_nPosProd] == Acols[n,_nPosUprd]
			If Acols[n,_nPosUDes] = 0
				Acols[n,_nPosVrUnit] := Acols[n,_nPosUPrc]
				Acols[n,_nPosValor]  := Acols[n,_nPosVrUnit]*Acols[n,_nPosQuant]
			Else
				Acols[n,_nPosVrUnit] := ((Acols[n,_nPosUPrc]*Acols[n,_nPosQuant])-Acols[n,_nPosUDes])/Acols[n,_nPosQuant]
				Acols[n,_nPosValor]	 := Acols[n,_nPosVrUnit]*Acols[n,_nPosQuant]
			EndIf
		EndIf
	EndIf

	//If Readvar() $ "M->UB_PRODUTO/M->C6_PRODUTO/M->UA4_PRODUT/M->UB_QUANT/M->C6_QTDVEN/M->UA4_QUANT"
	If Readvar() $ "M->UB_PRODUTO/M->C6_PRODUTO/M->UA4_PRODUT/M->UB_QUANT/M->C6_QTDVEN/UA4_QUANT"  //MCVN - 15/02/2007 Alterado para compatibilizar com Licita็๕es
	 
		If Readvar() $ "M->UA4_PRODUT" //MCVN - 15/02/2007 Alterado para compatibilizar com Licita็๕es
	   		SB1->(dbSeek(xFilial("SB1")+M->UA4_PRODUT))
		Endif             

		If Readvar() $ "M->UB_PRODUTO/M->C6_PRODUTO"
			Acols[n,_nPosVrUnit] := if(SB1->B1_PRVSUPE>0,SB1->B1_PRVSUPE,SB1->B1_PRVMINI)
			MaFisAlt("IT_PRCUNI",aCols[n,_nPosVrUnit],n)
			aCols[n][_nPPrcTab] := Acols[n,_nPosVrUnit]
			MaFisAlt("IT_PRCUNI",aCols[n,_nPosVrUnit],n)
			aCols[n][_nPosUPrc] := Acols[n,_nPosVrUnit]
     	Endif
		If Readvar() $ "M->UB_PRODUTO/M->C6_PRODUTO/M->UB_QUANT/M->C6_QTDVEN"
				aCols[n][_nPosValor]:= A410Arred(aCols[n,_nPosQuant]*aCols[n,_nPosVrUnit],"UB_VLRITEM")
				MaFisAlt("IT_VALMERC",aCols[n,_nPosValor],n)
		Endif		

		If Readvar() $ "M->UB_PRODUTO/M->C6_PRODUTO/M->UA4_PRODUT" //MCVN - 15/02/2007 Alterado para compatibilizar com Licita็๕es
			If SB1->B1_PRV1 == 0 .and. !(SB1->B1_HABILIT == "L" .AND. "DIPAL10" $ FunName()) .And. Iif("TMK" $ FunName() .or. "DIPAL10" $ FunName(),.t.,Iif(M->C5_TIPO='N',.t.,.f.))
				MsgBox("Produto sem pre็o de lista."+Chr(13)+"Fale com o pessoal de compras!"+Chr(13)+Chr(13)+"Obrigado","Aten็ใo - "+SB1->B1_COD,"Error")
				_Retorno := .F.
			EndIf            
		 
			
			// Nใo libera pedido se o ๚ltimo pre็o de compra for igual a 0(Zero)  MCVN - 03/11/08
			If SB1->B1_UPRC == 0 .and. !(SB1->B1_HABILIT == "L" .AND. "DIPAL10" $ FunName()) .And. Iif("TMK" $ FunName() .or. "DIPAL10" $ FunName(),.t.,Iif(M->C5_TIPO='N',.t.,.f.))
				MsgBox("Produto sem O ๚ltimo pre็o de compra."+Chr(13)+"Fale com o pessoal de compras!"+Chr(13)+Chr(13)+"Obrigado","Aten็ใo - "+SB1->B1_COD,"Error")
				_Retorno := .F.
			EndIf   
			
			// Mensagem para nใo vender Kimberly para fora de SP - MCVN 30/08/2007                                                                                      
			If _cUf <> "SP" .and. SB1->B1_PROC $ _cFornVend // "000366/000466"
			    _cMsg := "Por for็a de contrato nใo poderemos comercializar os produtos "
			    _cMsg += "Kimberly para fora do estado de SP. A Kimberly terแ distribuidores "
			    _cMsg += "nas regi๕es. Qualquer d๚vida entrar em contato com a Kimberly (11) 4503-4494."
			
				MsgBox(_cMsg,"Aten็ใo - "+SB1->B1_COD,"Error")
				
				// Validando o faturamento de produtos kimberly solicitando senha  MCVN - 03/09/2007 (DESABILITADO 25/03/2008 - MCVN )
				IF  !("DIPAL10" $ Funname())  // Solicita็ใo de senha 03/09/2007     	
					_Retorno := .T. //U_SENHA("KIM",0,0,0) 
				Else 
					_Retorno := .F.                  
				EndIf   
			EndIf
			
    		// Nใo libera pedido com produto sem Lote e/ou sem localiza็ใo
			If  !(SB1->B1_PROC $ '000222/000016/000376') // Nใo executa valida็ใo se o fornecedor for EDLO ou ERWIN OU INCOTERM  -   MCVN -  05/11/2008
				If (SB1->B1_RASTRO <> 'L' .Or. SB1->B1_LOCALIZ <> 'S') .AND. SB1->B1_TIPO = 'PA' .And. !(SB1->B1_HABILIT == "L" .AND. "DIPAL10" $ FunName()) .And. Iif("TMK" $ FunName() .or. "DIPAL10" $ FunName(),.t.,Iif(M->C5_TIPO='N',.t.,.f.))
				MsgBox("Produto sem lote e/ou sem localiza็ใo."+Chr(13)+"Fale com o pessoal de compras!"+Chr(13)+Chr(13)+"Obrigado","Aten็ใo - "+SB1->B1_COD,"Error")
				_Retorno := .F.
				EndIf     
			Endif
			
			// Nใo libera pedido com produto sem CLASSIFICAวรO FISCAL - MCVN 08/10/2008
			If (Empty(SB1->B1_POSIPI)) .AND. SB1->B1_TIPO = 'PA' .And. !(SB1->B1_HABILIT == "L" .AND. "DIPAL10" $ FunName()) .And. Iif("TMK" $ FunName() .or. "DIPAL10" $ FunName(),.t.,Iif(M->C5_TIPO='N',.t.,.f.))
				MsgBox("Produto sem NCM/NBM (CLASSIFICAวรO FISCAL)."+Chr(13)+"Fale com o pessoal de compras!"+Chr(13)+Chr(13)+"Obrigado","Aten็ใo - "+SB1->B1_COD,"Error")
				_Retorno := .F.
			EndIf  
                                                                                       
			// Nใo libera pedido com produto sem PESO - MCVN 29/05/2009
			If (SB1->B1_PESO <= 0) .AND. SB1->B1_TIPO = 'PA' .And. !(SB1->B1_HABILIT == "L" .AND. "DIPAL10" $ FunName()) .And. Iif("TMK" $ FunName() .or. "DIPAL10" $ FunName(),.t.,Iif(M->C5_TIPO='N',.t.,.f.))
				MsgBox("Produto sem PESO."+Chr(13)+"Fale com o pessoal de compras!"+Chr(13)+Chr(13)+"Obrigado","Aten็ใo - "+SB1->B1_COD,"Error")
				_Retorno := .F.
			EndIf  
                      
            // Nใo permite faturamento sem pre็o de custo   -  MCVN - 26/08/09
			If SB1->B1_CUSDIP == 0 .and. !(SB1->B1_HABILIT == "L" .AND. "DIPAL10" $ FunName()) .And. Iif("TMK" $ FunName() .or. "DIPAL10" $ FunName(),.t.,Iif(M->C5_TIPO='N',.t.,.f.)) 
				MsgBox("Produto sem custo."+Chr(13)+"Fale com o pessoal de compras!"+Chr(13)+Chr(13)+"Obrigado","Aten็ใo - "+SB1->B1_COD,"Error")
				_Retorno := .F.
			EndIf   
			
            // Nใo permite faturamento sem pre็o de custo   -  MCVN - 26/08/09
			If Empty(Alltrim(SB1->B1_DREVFIS)) .and. !(SB1->B1_HABILIT == "L" .AND. "DIPAL10" $ FunName()) .And. Iif("TMK" $ FunName() .or. "DIPAL10" $ FunName(),.t.,Iif(M->C5_TIPO='N',.t.,.f.)) 
				MsgBox("Produto bloqueado, falta avalia็ใo fiscal."+Chr(13)+"Fale com o pessoal do Departamento responsแvel!"+Chr(13)+Chr(13)+"Obrigado","Aten็ใo - "+SB1->B1_COD,"Error")
				_Retorno := .F.
			EndIf   
			
            // Nใo permite faturamento sem TES de Saida  -  D'Leme - 10/10/2011
			If Empty(Alltrim(SB1->B1_TS)) .and. !(SB1->B1_HABILIT == "L" .AND. "DIPAL10" $ FunName()) .And. Iif("TMK" $ FunName() .or. "DIPAL10" $ FunName(),.t.,Iif(M->C5_TIPO='N',.t.,.f.)) 
				MsgBox("Produto sem TES padrใo de Saํda."+Chr(13)+"Fale com o pessoal de compras!"+Chr(13)+Chr(13)+"Obrigado","Aten็ใo - "+SB1->B1_COD,"Error")
				_Retorno := .F.
			EndIf   

		   //	IF _Retorno           			    
				If SB1->B1_HABILIT == "N" .OR. SB1->B1_HABILIT == "O" .OR. (SB1->B1_HABILIT == "L" .AND. !("DIPAL10" $ FunName())) // //MCVN - 15/02/2007 Alterado para compatibilizar com Licita็๕es
					If !Empty(SB1->B1_MEN_HAB)
						MSGINFO(SB1->B1_MEN_HAB)
					EndIf
						_Retorno := .F.
				ElseIf SB1->B1_HABILIT == "S"
					If !Empty(SB1->B1_MEN_HAB)
						MSGINFO(SB1->B1_MEN_HAB)
					EndIf                                      				
				EndIf
		//	EndIf
		EndIf
		If Readvar()$"M->C6_PRODUTO" .And. !Upper(u_DipUsr())$GetNewPar("ES_USR2PRO","JLIMA,DFELLIZARDO")
			If (_nPos := aScan(aCols,{|x| !x[Len(aHeader)+1] .And. x[_nPosProd]==M->C6_PRODUTO .And. x[_nPosItem] <> aCols[n,_nPosItem]}))>0
				Aviso("Aten็ใo","Produto jแ informado no pedido (Item "+aCols[_nPos,_nPosItem]+"). Nใo serแ permitido usar o mesmo c๓digo em duas linhas diferentes.",{"Ok"},1)
				_Retorno := .F.
			EndIf
		EndIf
	EndIf
	
	IF _Retorno  // Mostra ESTOQUES
		U_MYSALDOSB2('01',Readvar())
	EndIf  
	//giovani  16/06/2011   INCUBADORA CLEAN TRACE****************************
	If _Retorno  // Valida produto
        If SB1->B1_COD = GetMv("ES_DIPV3_1",,"")
		   _Retorno:=U_DIPV003("003",M->C5_CLIENTE,M->C5_LOJACLI)
		ElseIf SB1->B1_COD = GetMv("ES_DIPV3_2",,"")
		   _Retorno:=U_DIPV003("004",M->C5_CLIENTE,M->C5_LOJACLI)
		EndIf
	EndIf 
	//***********************************************************
	
	If _Retorno .And. !u_VldPerPro(SB1->B1_COD)
		//Aviso("Aten็ใo","Produto com promo็ใo vencida."+CHR(13)+CHR(10)+"Fale com o pessoal de COMPRAS",{"Ok"})
		MsgInfo("Produto com promo็ใo vencida."+CHR(13)+CHR(10)+"Fale com o pessoal de COMPRAS","Aten็ใo!")
		_Retorno := .F.
	EndIf
	
	if _Retorno .And. Readvar()=="M->C6_PRODUTO" .And. M->C5_TPFRETE=="C" .And. M->C5_ESTE<>"SP"
		If AllTrim(M->C6_PRODUTO)$GetNewPar("ES_NFORASP","018591,425160,010601,400049,018583,400062,018584,010602,030484,030760,030761,030762,030763")
			MsgInfo("Este produto nใo pode ser cotado para fora do estado de SP","ES_NFORASP")
			_Retorno := .F.
		EndIf
	EndIf
	
	// Regra para limpar linha quando rotina retorna falso
	If !_Retorno                  
		aCols[n,Len(aHeader)+1]:=.T.     	
		aCols[n,_nPosProd] := SPACE(15)
		aCols[n,_nPosDesc] := SPACE(1) 
		M->C6_PRODUTO := SPACE(15)		
	EndIf
	
	
EndIf                                   

RestArea(_aAreaSB1)
RestArea(_aArea)


Return(_Retorno)

*---------------------------------------------------*
User Function MYSALDOSB2(cLocal,cCampo)
*---------------------------------------------------*
Local _aArea	:= GetArea()
Local _aAreaSB2	:= SB2->(GetArea())
Local oDlg
Local oBtnOk
Local cBotao := "Estoque de &amostras"
Local cTitulo:= "Estoque para vendas "
Local cBtnAlt:= "&Ver Alternativo"
Local nOpcao := 0
Local nSaldos:= 0
Local _nPosProd  := 0 // aScan(aHeader, { |x| Alltrim(x[2]) == IIF("TMK"$FunName(),"UB_PRODUTO","C6_PRODUTO") })
Local _nPosQuant := 0 // aScan(aHeader, { |x| Alltrim(x[2]) == IIF("TMK"$FunName(),"UB_QUANT","C6_QTDVEN") })
Local cMsgTela   := ""
Local lSaldoAlt  := .T.            
Local lGatilho   := .F.
Private aEstMTZ    := {}
Private aEstCD     := {}
Private aEstTOTAL  := {}
Private aEstAltMTZ := {}
Private aEstAltCD  := {}
Private aEstAltTOT := {}

// ATUALIZA ARRAY COM ESTOQUE POR EMPRESA E TOTAL
aEstMTZ  := U_DIPSALDSB2(SB1->B1_COD,lGatilho,'MTZ') //Array com estoque da Matriz
aEstCD   := U_DIPSALDSB2(SB1->B1_COD,lGatilho,'CD')  //Array com estoque do CD

AADD(aEstTOTAL,{aEstMTZ[1][1]+aEstCD[1][1],; // Estoque total          01
				aEstMTZ[1][2]+aEstCD[1][2],; // Reserva total          02
				aEstMTZ[1][3]+aEstCD[1][3],; // Total A Endere็ar      03
				aEstMTZ[1][4]+aEstCD[1][4],; // Saldo total Disponํvel 04
				aEstMTZ[1][5]+aEstCD[1][5],; // Saldo em Pedidos	   05  
				aEstMTZ[1][6]+aEstCD[1][6]}) // Total A Entrar         06  


// ATUALIZA ARRAY COM ESTOQUE POR EMPRESA E TOTAL DO CำDIGO ALTERNATIVO CASO EXISTE
If !Empty(SB1->B1_ALTER)               
	aEstAltMTZ  := U_DIPSALDSB2(SB1->B1_ALTER,lGatilho,'MTZ') //Array com estoque do c๓gigo alternativo da Matriz
	aEstAltCD   := U_DIPSALDSB2(SB1->B1_ALTER,lGatilho,'CD') //Array com estoque do c๓gigo alternativo do CD
	
	AADD(aEstAltTOT,{aEstAltMTZ[1][1]+aEstAltCD[1][1],; // Estoque total          01
					 aEstAltMTZ[1][2]+aEstAltCD[1][2],; // Reserva total          02
					 aEstAltMTZ[1][3]+aEstAltCD[1][3],; // Total A Endere็ar   	  03
					 aEstAltMTZ[1][4]+aEstAltCD[1][4],; // Saldo total Disponํvel 04
					 aEstAltMTZ[1][5]+aEstAltCD[1][5],; // Saldo em Pedidos	      05  
					 aEstAltMTZ[1][6]+aEstAltCD[1][6]}) // Total A Entrar         06   
Endif                                              



If ( Type("l410Auto") == "U" .OR. !l410Auto )
	
	Private lMostraBt := .T.
	Private lBtnAlt   := .F.
	
	_nPosProd  := aScan(aHeader, { |x| Alltrim(x[2]) == IF("DIPAL10" $ FunName(),"UA4_PRODUT", IIF("TMK"$FunName(),"UB_PRODUTO","C6_PRODUTO")) }) //MCVN - 15/02/2007 Alterado para compatibilizar com Licita็๕es
	_nPosQuant := aScan(aHeader, { |x| Alltrim(x[2]) == IF("DIPAL10" $ FunName(),"UA4_QUANT",IIF("TMK"$FunName(),"UB_QUANT","C6_QTDVEN")) })      //MCVN - 15/02/2007 Alterado para compatibilizar com Licita็๕es

	
	Do While .T.
		nOpcao := 0
		
		Do Case
			
			Case cCampo $ "M->UB_PRODUTO/M->C6_PRODUTO/M->UA4_PRODUT"
										
				If aEstTOTAL[1][4] <= 0 .and. !Empty(SB1->B1_ALTER)
					If aEstAltTOT[1][4] <= 0
						cMsgTela := "Este produto e o alternativo estใo com o estoque ZERADO"
						lSaldoAlt:= .F.
					Else
						cMsgTela := "Este produto estแ com o estoque ZERADO. Ofere็a o produto alternativo!"
						lSaldoAlt:= .T.   
					EndIf
				Else
					cMsgTela := Nil
				EndIf
				nOpcao := 0
				DIPG8ProdAlt(@nOpcao,cBotao,cTitulo,cMsgTela,_nPosProd,cLocal,lSaldoAlt,cBtnAlt)
					
			Case cCampo $ "M->UB_QUANT/M->C6_QTDVEN/M->UA4_QUANT"
				
				If aEstTOTAL[1][4] < Acols[n,_nPosQuant]
					If !Empty(SB1->B1_ALTER)
						If	aEstAltTOT[1][4] <= 0
							cMsgTela := "Este produto e o alternativo nใo possuem estoque suficiente"
							lSaldoAlt:= .F.  
						Else
							cMsgTela := "Produto nใo possui estoque suficiente. Ofere็a o produto alternativo!"
							lSaldoAlt:= .T.
						EndIf
						nOpcao := 0
						DIPG8ProdAlt(@nOpcao,cBotao,cTitulo,cMsgTela,_nPosProd,cLocal,lSaldoAlt,cBtnAlt)
					EndIf
				EndIf
		EndCase

		If nOpcao = 0 .or. nOpcao = 2
			Exit
		ElseIf nOpcao = 3
			lBtnAlt := .T.
			cTitulo:= "Estoque para vendas - Produto Alternativo"
			cBtnAlt := "&Ver Produto"
		ElseIf nOpcao = 4
			lBtnAlt := .F.
			cTitulo:= "Estoque para vendas"
			cBtnAlt := "&Ver Alternativo"
		EndIf
	EndDo                                                                                       
EndIf    
RestArea(_aAreaSB2)
RestArea(_aArea)

Return(.t.)
*------------------------------------------------------------*
Static Function DIPG8ProdAlt(nOpcao,cBotao,cTitulo,cMensagem,_nPosProd,cLocal,lSaldoAlt,cBtnAlt)
// JBS 25/07/2005 - Mostra dados do item no estoque Amost/Ven.
*------------------------------------------------------------*
Local _aArea	:= GetArea()
Local _aAreaSB1	:= SB1->(GetArea())
Local _aAreaSB2	:= SB2->(GetArea())
Local nSaldos := 0
Local oBtn1
Local _nSalPoder3 := 0     
Local nValAux     := 0
Local cProdut     := ""
Local nMultVend   := 0
Local nCxSec      := 0
Local nCxEmb      := 0

If cMensagem <> NIL 
	M->B1_COD	:= AllTrim(IIF("DIPAL10" $ FunName(),M->UA4_PRODUT, IIF("TMK"$FunName(),M->UB_PRODUTO,M->C6_PRODUTO)))+"-"+SB1->B1_DESC
	M->Mensag   := cMensagem
   _nSalPoder3  := U_DIP8Poder3(IIF("DIPAL10" $ FunName(),M->UA4_PRODUT, IIF("TMK"$FunName(),M->UB_PRODUTO,M->C6_PRODUTO)))            
   cProdut		:= IIF("DIPAL10" $ FunName(),M->UA4_PRODUT, IIF("TMK"$FunName(),M->UB_PRODUTO,M->C6_PRODUTO))
Else 
   	M->B1_COD   := AllTrim(SB1->B1_COD) +"-"+SB1->B1_DESC
	M->Mensag   := ""
	_nSalPoder3 := U_DIP8Poder3(SB1->B1_COD)        
	cProdut 	:= SB1->B1_COD
EndIf

Define FONT oFontCn    NAME "Courier"
Define FONT oFontCb    NAME "Courier" BOLD
Define FONT oFontCb16  NAME "Courier" SIZE 0, -16 BOLD  
Define FONT oFontCb14  NAME "Courier" SIZE 0, -14 BOLD  
Define FONT oFontCb12  NAME "Courier" SIZE 0, -14 BOLD  
Define FONT oFontN     NAME "Arial"
Define FONT oFontB     NAME "Arial" BOLD                           
Define FONT oFontB16   NAME "Arial" SIZE 0, -16 BOLD  
Define FONT oFontB14   NAME "Arial" SIZE 0, -14 BOLD 
Define FONT oFontB12   NAME "Arial" SIZE 0, -12 BOLD 


//Atualizando variแveis de mem๓ria
M->B1_ALTER    := SB1->B1_ALTER  
M->B1_PRVSUPE  := SB1->B1_PRVSUPE
M->B1_MOSTPRO  := SB1->B1_MOSTPRO
M->B1_NPROMOC  := SB1->B1_NPROMOC
M->B1_PESO     := SB1->B1_PESO
M->B1_PERPROM  := SB1->B1_PERPROM 


//Definindo Linhas
nLf  := 25
nLf1 := 00
nLf2 := 00
                  
//Verifica se o produto estแ em Promo็ใo e incrementa a linha
If M->B1_PRVSUPE > 0
    nLf  += 2
    nLf1 += 15
EndIf    

//Verifica se o Peso ้ maior que 250 gramas e incrementa a linha
If M->B1_PESO > 0.250
    nLf  += 2
EndIf    


//Variaveis para carregar quantidade de mult de venda, cx secundaria e de embaque
If     SB1->B1_XTPEMBV == '1' .And. SB1->B1_XCXFECH == "1" .And. SB1->B1_XVLDCXE == "1"
	   	nMultVend := SB1->B1_XQTDEMB
	   	nCxSec    := SB1->B1_XQTDSEC
	   	nCxEmb    := SB1->B1_XQTDEMB
ElseIf SB1->B1_XTPEMBV == '2' .And. SB1->B1_XCXFECH == "1" .And. SB1->B1_XVLDCXE == "1"
	   	nMultVend := SB1->B1_XQTDSEC
	   	nCxSec    := SB1->B1_XQTDSEC
	   	nCxEmb    := SB1->B1_XQTDEMB
Else
	   	nMultVend := "Fora da Regra!"
	   	nCxSec    := SB1->B1_XQTDSEC
	   	nCxEmb    := SB1->B1_XQTDEMB
EndIf	


//MONTA TELA PRINCIPAL
Define msDialog oDlg Title cTitulo From 003,010 TO 35,073
                                                        

//MONTANDO INFORMAวรO PRINCIPAL COM A CONSOLIDAวรO DOS ESTOQUES//
//-------------------------------------------------------------//

@ 005,010 say "Produto:" Size 50,10 COLOR CLR_BLUE pixel FONT oFontB
@ 005,037 say oemtoansi(M->B1_COD) SIZE 210,10 COLOR CLR_RED pixel FONT oFontCB14

@ 015,010 say "Venda Multipla de:" Size 50,10 COLOR CLR_BLUE pixel FONT oFontB
@ 020,010 say nMultVend SIZE 210,10 COLOR CLR_RED pixel FONT oFontCB14

@ 015,080 say "Cx Secundaria:" Size 50,10 COLOR CLR_BLUE pixel FONT oFontB
@ 020,080 say nCxSec SIZE 210,10 COLOR CLR_RED pixel FONT oFontCB14

@ 015,140 say "Cx de Embaque:" Size 50,10 COLOR CLR_BLUE pixel FONT oFontB
@ 020,140 say nCxEmb SIZE 210,10 COLOR CLR_RED pixel FONT oFontCB14


If cMensagem <> NIL
	@ 035,010 say "Alternativo: "      SIZE 50,10 COLOR CLR_BLUE pixel FONT oFontB
	@ 025,010 Say Padc(M->Mensag,79)   SIZE 235,10 pixel FONT oFontB COLOR CLR_HRED
	@ 035,060 say AllTrim(M->B1_ALTER) SIZE 040,08 pixel FONT oFontCB12 COLOR CLR_BLACK
EndIf                                                         

@ 070,010 say "Estoque    " SIZE 50,08 COLOR CLR_BLUE pixel FONT oFontb
@ 080,010 say "Reserva    " SIZE 50,08 COLOR CLR_BLUE pixel FONT oFontb
@ 090,010 say "a Enderecar" SIZE 50,08 COLOR CLR_BLUE pixel FONT oFontb
@ 100,010 say "DISPONIVEL " SIZE 50,08 COLOR CLR_HRED,CLR_BLUE pixel FONT oFontb
@ 110,010 say "Saldos     " SIZE 50,08 COLOR CLR_BLUE pixel FONT oFontb
@ 120,010 say "a Entrar   " SIZE 50,08 COLOR CLR_BLUE pixel FONT oFontb


/////////////////////////////////////////////////////////////////////////////////////////////////
//ESTOQUE DA DIPROMED MATRIZ
@ 055,050 say "MATRIZ" SIZE 50,08 COLOR CLR_BLUE pixel FONT oFontB12
@ 070,050 say Iif(nOpcao<>3 .And. !lBtnAlt,aEstMTZ[1][1],aEstAltMTZ[1][1]) picture "@E 999,999,999" SIZE 50,08 pixel FONT oFontcb COLOR CLR_BLUE
@ 080,050 say Iif(nOpcao<>3 .And. !lBtnAlt,aEstMTZ[1][2],aEstAltMTZ[1][2]) picture "@E 999,999,999" SIZE 50,08 pixel FONT oFontcb COLOR CLR_BLUE
@ 090,050 say Iif(nOpcao<>3 .And. !lBtnAlt,aEstMTZ[1][3],aEstAltMTZ[1][3]) picture "@E 999,999,999" SIZE 50,08 pixel FONT oFontcb COLOR CLR_BLUE
@ 100,050 say Iif(nOpcao<>3 .And. !lBtnAlt,aEstMTZ[1][4],aEstAltMTZ[1][4]) picture "@E 999,999,999" SIZE 50,08 pixel FONT oFontcb COLOR CLR_HRED
@ 110,050 say Iif(nOpcao<>3 .And. !lBtnAlt,aEstMTZ[1][5],aEstAltMTZ[1][5]) picture "@E 999,999,999" SIZE 50,08 pixel FONT oFontcb COLOR CLR_BLUE
@ 120,050 say Iif(nOpcao<>3 .And. !lBtnAlt,aEstMTZ[1][6],aEstAltMTZ[1][6]) picture "@E 999,999,999" SIZE 50,08 pixel FONT oFontcb COLOR CLR_HRED
@ 068,045 to 078,104 pixel COLOR CLR_BLUE
@ 078,045 to 088,104 pixel COLOR CLR_BLUE
@ 088,045 to 098,104 pixel COLOR CLR_BLUE
@ 098,045 to 108,104 pixel COLOR CLR_BLUE
@ 108,045 to 118,104 pixel COLOR CLR_BLUE
@ 118,045 to 128,104 pixel COLOR CLR_BLUE                                                        
/////////////////////////////////////////////////////////////////////////////////////////////////

/////////////////////////////////////////////////////////////////////////////////////////////////
//ESTOQUE DA DIPROMED CD
@ 055,110 say "CD" SIZE 50,08 COLOR CLR_BLUE pixel FONT oFontB12
@ 070,110 say Iif(nOpcao<>3 .And. !lBtnAlt,aEstCD[1][1],aEstAltCD[1][1]) picture "@E 999,999,999" SIZE 50,08 pixel FONT oFontcb COLOR CLR_BLUE
@ 080,110 say Iif(nOpcao<>3 .And. !lBtnAlt,aEstCD[1][2],aEstAltCD[1][2]) picture "@E 999,999,999" SIZE 50,08 pixel FONT oFontcb COLOR CLR_BLUE
@ 090,110 say Iif(nOpcao<>3 .And. !lBtnAlt,aEstCD[1][3],aEstAltCD[1][3]) picture "@E 999,999,999" SIZE 50,08 pixel FONT oFontcb COLOR CLR_BLUE
@ 100,110 say Iif(nOpcao<>3 .And. !lBtnAlt,aEstCD[1][4],aEstAltCD[1][4]) picture "@E 999,999,999" SIZE 50,08 pixel FONT oFontcb COLOR CLR_HRED
@ 110,110 say Iif(nOpcao<>3 .And. !lBtnAlt,aEstCD[1][5],aEstAltCD[1][5]) picture "@E 999,999,999" SIZE 50,08 pixel FONT oFontcb COLOR CLR_BLUE
@ 120,110 say Iif(nOpcao<>3 .And. !lBtnAlt,aEstCD[1][6],aEstAltCD[1][6]) picture "@E 999,999,999" SIZE 50,08 pixel FONT oFontcb COLOR CLR_HRED
@ 068,105 to 078,164 pixel COLOR CLR_BLUE
@ 078,105 to 088,164 pixel COLOR CLR_BLUE
@ 088,105 to 098,164 pixel COLOR CLR_BLUE
@ 098,105 to 108,164 pixel COLOR CLR_BLUE
@ 108,105 to 118,164 pixel COLOR CLR_BLUE
@ 118,105 to 128,164 pixel COLOR CLR_BLUE
/////////////////////////////////////////////////////////////////////////////////////////////////

/////////////////////////////////////////////////////////////////////////////////////////////////
//ESTOQUE CONSOLIDADO DA DIPROMED
@ 055,180 say "TOTAL" SIZE 50,08 COLOR CLR_BLUE pixel FONT oFontB14
@ 070,180 say Iif(nOpcao<>3 .And. !lBtnAlt,aEstTOTAL[1][1],aEstAltTOT[1][1]) picture "@E 999,999,999" SIZE 50,08 pixel FONT oFontCB12 COLOR CLR_BLUE
@ 080,180 say Iif(nOpcao<>3 .And. !lBtnAlt,aEstTOTAL[1][2],aEstAltTOT[1][2]) picture "@E 999,999,999" SIZE 50,08 pixel FONT oFontCB12 COLOR CLR_BLUE
@ 090,180 say Iif(nOpcao<>3 .And. !lBtnAlt,aEstTOTAL[1][3],aEstAltTOT[1][3]) picture "@E 999,999,999" SIZE 50,08 pixel FONT oFontCB12 COLOR CLR_BLUE
@ 100,180 say Iif(nOpcao<>3 .And. !lBtnAlt,aEstTOTAL[1][4],aEstAltTOT[1][4]) picture "@E 999,999,999" SIZE 50,08 pixel FONT oFontCB12 COLOR CLR_HRED
@ 110,180 say Iif(nOpcao<>3 .And. !lBtnAlt,aEstTOTAL[1][5],aEstAltTOT[1][5]) picture "@E 999,999,999" SIZE 50,08 pixel FONT oFontCB12 COLOR CLR_BLUE
@ 120,180 say Iif(nOpcao<>3 .And. !lBtnAlt,aEstTOTAL[1][6],aEstAltTOT[1][6]) picture "@E 999,999,999" SIZE 50,08 pixel FONT oFontCB12 COLOR CLR_HRED
@ 068,175 to 078,233 pixel COLOR CLR_BLUE
@ 078,175 to 088,233 pixel COLOR CLR_BLUE
@ 088,175 to 098,233 pixel COLOR CLR_BLUE
@ 098,175 to 108,233 pixel COLOR CLR_BLUE
@ 108,175 to 118,233 pixel COLOR CLR_BLUE
@ 118,175 to 128,233 pixel COLOR CLR_BLUE
/////////////////////////////////////////////////////////////////////////////////////////////////


//PREวO DE PROMOวรO FOR MAIOR QUE 0                                                                  
If M->B1_PRVSUPE > 0
	If !("DIPAL10"$ FunName()) .And. !("TMK"$FunName())
		nValAux := u_DipAcrCli(M->B1_PRVSUPE,M->C5_CLIENTE,M->C5_LOJACLI,cProdut)
	EndIf
	If M->B1_MOSTPRO == "S"
	    @ 130,0 to 158,250 pixel COLOR CLR_BLUE
	    @ 135,5 say Padc("PROMOวรO:  "+Alltrim(M->B1_NPROMOC)+ "  -  Perํodo: " +Alltrim(M->B1_PERPROM),120) SIZE 235,10 COLOR CLR_HRED,CLR_BLUE pixel FONT oFontb
        @ 145,100 say "R$  " +AllTrim(Transform(nValAux,"@e 9,999,999.9999")) SIZE 50,08 pixel FONT oFontB16 COLOR CLR_BLACK
	Else                                       
	    @ 130,0 to 158,250 pixel COLOR CLR_BLUE
	    @ 135,5 say Padc("PROMOวรO  -  Perํodo: " +Alltrim(M->B1_PERPROM),120) SIZE 235,10 COLOR CLR_HRED,CLR_BLUE pixel FONT oFontb
        @ 145,100 say "R$  " +AllTrim(Transform(nValAux,"@e 9,999,999.9999")) SIZE 50,08 pixel FONT oFontB16 COLOR CLR_BLACK
	Endif                  
    @ 155,0 to 170,250 pixel COLOR CLR_BLUE
    @ 160,5 say Padc("Nใo fazer saldo no Pre็o de Promo็ใo.",120) SIZE 235,10 pixel FONT oFontB COLOR CLR_HRED
EndIf    
                    

//PESO DO PRODUTO MAIOR QUE 250 GRAMAS
If M->B1_PESO > 0.250
    @ 155+nLf1,0 to 170+nLf1,250 pixel COLOR CLR_BLUE
    @ 160+nLf1,5 say Padc("CUIDADO: Peso superior a 250 Gramas. ("+AllTrim(Transform(M->B1_PESO,"@ke 999,999.999"))+")",120) SIZE 235,10 pixel FONT oFontB COLOR CLR_BLACK
EndIf    

If lMostraBt .And. !lSaldoAlt
	@ 225,060 Button cBtnAlt  Size 80,15 Action (nOpcao:=If(!lBtnAlt,3,4),oDlg:End()) pixel
EndIf

// @ 180,001 SAY OemToAnsi(" Foto") Size 014,007
// @ 225,160 Button "&Sair" Size 80,15 Action (ShowBMP(),oDlg:End()) pixel


@ 225,160 Button "&Sair" Size 80,15 Action (nOpcao:=2,oDlg:End()) pixel // ShowBMP()

IF !Empty(SB1->B1_BITMAP)
	@ 225,060 Button "&Foto" Size 80,15 Action (ShowBMP()) pixel // ShowBMP()
Endif

//DEFINE SBUTTON FROM 55, 120 TYPE 1 ACTION (oDlg:End(), UGrvSb1()) ENABLE OF oDlg

Activate Dialog oDlg Centered

RestArea(_aAreaSB1)
RestArea(_aAreaSB2)
RestArea(_aArea)

Return(.T.)

//=======================
Static Function ShowBMP()
//=======================
Local owDlg
Local oDlgF
Local aSize := {}
//aSize := MsAdvSize(.F.)
aSize := MsAdvSize( ,.T.,600)
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณCarrega a imagem do produto                         ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
/*
Alert("ShowBMP")
// @ 65,019 TO 200,200 LABEL "Foto" OF owDlg PIXEL
// @ 70,21 REPOSITORY _oBitPro OF owDlg NOBORDER SIZE 200,200 PIXEL
// Showbitmap(oBitPro,SB1->B1_BITMAP,"")
// Showbitmap(oBitPro,IIF(!Empty(SB1->B1_BITMAP),SB1->B1_BITMAP,"LOJAWIN"),"")
// oBitPro:lStretch:=.T.
// oBitPro:Refresh(.T.)
// Define SButton From 205,096 Type 1 Action (owDlg:End()) Enable Of owDlg Pixel
// Activate MsDialog owDlg Center
// @ 001,001 REPOSITORY _oBitPro OF oDlg SIZE 135,120 Pixel
cTitulo := "Foto do Produto"
Define msDialog owDlg Title cTitulo From 003,010 TO 35,073
@ 110,158 REPOSITORY _oBitPro OF owDlg SIZE 135,120 Pixel
Showbitmap(_oBitPro,IIF(!Empty(SB1->B1_BITMAP),SB1->B1_BITMAP,"LOJAWIN"),"")
_oBitPro:lStretch:=.T.
_oBitPro:Refresh(.T.)

@ 105,164 SAY OemToAnsi(" Foto") Size 014,007
//owDlg:End()
*/

DEFINE MSDIALOG oDlgF TITLE "Foto" FROM aSize[7],0 To aSize[6],aSize[5] OF oMainWnd PIXEL 


@ 00,00 REPOSITORY oBmp OF oDlgF SIZE 135,120
ShowBitmap(oBmp,IIF(!Empty(SB1->B1_BITMAP),SB1->B1_BITMAP,"LOJAWIN"))
oBmp:lStretch:=.T.
oBmp:Refresh(.T.)
oBmp:lVisibleControl := .T.
oBmp:lAutoSize := .T.
@ 275,118 Button "&Sair" Size 80,15 Action (oDlgF:End()) pixel
ACTIVATE MSDIALOG oDlgF  Center // ON INIT (oBmp:lStretch := .T.,))
Return (.T.)


*----------------------------------------------*
User Function DIP8Amostra()
// JBS 25/07/2005 - Verifica se existe amostra
*----------------------------------------------*
Local _aArea	:= GetArea()
Local _aAreaSB2	:= SB2->(GetArea())

Local nSB2Rec  := SB2->(Recno())
Local lAmostra := SB2->(dbSeek(xFilial("SB2")+SB1->B1_COD+"05")) .and. SB2->B2_QATU > 0

If ( Type("l410Auto") == "U" .OR. !l410Auto )
	SB2->(DbGoTo(nSB2Rec))
Else
	lAmostra := .T.
EndIf

RestArea(_aAreaSB2)
RestArea(_aArea)

Return(lAmostra)
*----------------------------------------------*


User Function DIP8Poder3(_cProd3,lCons)
	//MCVN 07/08/2013 - Verifica se existe saldo em Poder de 3บ
	*----------------------------------------------*
	Local _aArea	:= GetArea()
	Local _SldPoder3:= 0
	Local _cLocal   := '06'
	DEFAULT lCons := .F.
	
	If cEmpAnt == "01"
		_cLocal := '06'
	Else
		_cLocal := '07'	
	EndIf
	//ESTOQUE EM PODE DE TERCEIRO (ULTRALINE E MEDICAL ACTION)
	//RBORGES - 08/02/2018 - ALTERADA PARA TRAZER O SALDO DO LOCAL 06.
/*	
	QRY1 := "SELECT "
	QRY1 += " SUM(B6_SALDO) AS SALDO "
	QRY1 += " FROM "+RetSQLName("SB6")
	QRY1 += " WHERE B6_FILIAL = '"+ xFilial("SB6")+"' "
	QRY1 += " AND B6_PRODUTO  = '"+ _cProd3       +"' "
	//QRY1 += " AND B6_LOCAL    = '"+ _cLocal       +"' "
	QRY1 += " AND B6_PODER3   = 'R' "
	QRY1 += " AND B6_CLIFOR   = '019181' "
	QRY1 += " AND "+RetSQLName("SB6")+".D_E_L_E_T_ = ' ' "

	#xcommand TCQUERY <sql_expr>                          ;
	[ALIAS <a>]                                           ;
	[<new: NEW>]                                          ;
	[SERVER <(server)>]                                   ;
	[ENVIRONMENT <(environment)>]                         ;
	=> dbUseArea(                                         ;
	<.new.>,                                              ;
	"TOPCONN",                                            ;
	TCGENQRY(<(server)>,<(environment)>,<sql_expr>),      ;
	<(a)>, .F., .T.)

	// PROCESSA QUERY SQL
	DbCommitAll()
	TcQuery QRY1 NEW ALIAS "QRYPOD3"         // ABRE UMA WORKAREA COM O RESULTADO DA QUERY

	If !QRYPOD3->(Eof())
		_SldPoder3 := QRYPOD3->SALDO
	EndIf
	QRYPOD3->(dbCloseArea())
*/
If lCons
	
	dbSelectArea("SB2")
	
	dbSeek("01"+_cProd3+_cLocal)
	_SldPoder3 += SaldoSb2()
	
	dbSeek("04"+_cProd3+_cLocal)
	_SldPoder3 += SaldoSb2()
	
Else
	
	dbSelectArea("SB2")
	dbSeek(xFilial("SB2")+_cProd3+_cLocal)
	_SldPoder3 := SaldoSb2()
	
EndIf

RestArea(_aArea)

Return(_SldPoder3)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDIPG008   บAutor  ณMicrosiga           บ Data ณ  07/06/16   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function VldAltDig(cAntes,cDepois,cPedido)
Local aAreaSZR 	:= SZR->(GetArea())      
Local lRet 	   	:= .T.
DEFAULT cAntes 	:= ""
DEFAULT cDepois	:= ""
DEFAULT cPedido	:= ""

If !("DIPAL10" $ FunName()) .And. !("TMK"$FunName())	
	SZR->(dbsetorder(3))
	If SZR->(dbSeek(xFilial("SZR")+cPedido))
		If cAntes<>cDepois
	   		If Aviso("Confirma a altera็ใo?","Este pedido possui aprova็ใo digital. Se a estrutura do pedido for alterada serแ necessแrio uma nova avalia็ใo.",{"Sim","Nใo"}) == 1
	   			SZR->(RecLock("SZR",.F.))
	   				SZR->(dbDelete())
	   			SZR->(MsUnLock())   
	   			M->C5_XSTATUS := ""
	   		Else
	   			lRet := .F.
	   		EndIf
		EndIf
	EndIf
EndIf

RestArea(aAreaSZR)      

Return lRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDIPG008   บAutor  ณMicrosiga           บ Data ณ  07/06/16   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function VldQtdDig()
Local lRet := .T.

If Readvar()=="M->C6_QTDVEN" .And. Altera
	lRet := u_VldAltDig(SC6->C6_QTDVEN,M->C6_QTDVEN,M->C5_NUM) 
EndIf

Return lRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDIPG008   บAutor  ณMicrosiga           บ Data ณ  07/28/17   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function VldPerPro(cProduto)
Local aArea :=  GetArea()
Local lRet  := .F.           
Local cSQL  := ""      
Local cDatAux := DtoS(Date())

cDatAux := SubStr(cDatAux,3,2)+SubStr(cDatAux,5,2)+SubStr(cDatAux,7,2)

cSQL := " SELECT "
cSQL += " 	SUBSTRING(B1_PERPROM,10,8) "
cSQL += "	FROM "
cSQL += 		RetSQLName("SB1")
cSQL += "		WHERE "
cSQL += "			B1_FILIAL = '"+xFilial("SB1")+"' AND "
cSQL += "			B1_COD = '"+cProduto+"' AND "
cSQL += "			SUBSTRING(B1_PERPROM,10,8) NOT IN(' ','  /  /  ') AND  "
cSQL += "			SUBSTRING(B1_PERPROM,16,2)+SUBSTRING(B1_PERPROM,13,2)+SUBSTRING(B1_PERPROM,10,2) < '"+cDatAux+"' AND "
cSQL += "			D_E_L_E_T_ = ' ' "

cSQL := ChangeQuery(cSQL)          
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),"SB1TRB",.T.,.T.)

lRet := SB1TRB->(Eof()) // Se encontrar o registro ้ por que a promo็ใo estแ vencida.
SB1TRB->(dbCloseArea())
            
RestArea(aArea)

Return lRet

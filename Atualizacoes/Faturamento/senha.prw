/*                                                              Sao Paulo,  29 Mai 2006
---------------------------------------------------------------------------------------
Empresa.......: DIPROMED Comércio e Importação Ltda.

Data..........: 29 Mai 2006
Versão........: 1.0
Consideraçoes.: Função chamada do X3_WHEN do campo A1_OBSFINM.
---------------------------------------------------------------------------------------
*/
#INCLUDE "RWMAKE.CH"

#DEFINE TIPO    01
#DEFINE PRODUTO 02
#DEFINE VALOR1  03
#DEFINE VALOR2  04
#DEFINE DSENHA  05

STATIC aTesPed := {}
*--------------------------------------------------------------*
User Function DipSenha(cTipo, cObjeto, nValor1, nValor2, lSenha )
*--------------------------------------------------------------*
/*
-----------------------------------------------------------------------
U_DipSenha("MAR", "TMKVPA", aCols[][], aCols[][], aCols[][])
-----------------------------------------------------------------------
*/
Local lRetorno := .f. // No default a solicitação de senha fica bloqueada até a avaliação
//Local _cNopassword  := GetMV("MV_NOPASSW") // MCVN - 11/02/2008
Local _nFatorRecolh:= 1



U_DIPPROC(ProcName(0),U_DipUsr()) //MCVN - 22/01/2009

If ISINCALLSTACK("LOJA901A") .Or. ISINCALLSTACK("LOJA901")
	Return .T.
EndIf

//Tratamento para não solicitar senha para usuários informado no parâmetro MV_NOPASSW - MCVN - 11/02/2008
//Alterado para quando for HQ não passar na regra, conforme Maximo - 08/11/2018 - RBORGES
//If Upper(U_DipUsr()) $ _cNopassword
If cEmpAnt == "04"
	Return(.T.)
Endif
//Giovani Zago 17/08/11
If cTipo$"DTV/MA3"  
	If type("aDipSenhas") == "U"
		Public aDipSenhas := {} // Array que controla as senhas.
	EndIf
EndIf
//**********************************************
If cTipo == "LIMPA"
	aDipSenhas := {} // Array que controla as senhas.
	Return(lRetorno)
EndIf
/*
--------------------------------------------------------------
Avalia se já possui a senha para cada situação.
Se ja possui senha para determinada situação, não pede senha.
Se não foi pedido senha, pede a senha.
--------------------------------------------------------------
*/
Do Case
	
	Case cTipo == "MAR" // Condição de Pagamento
		
		If (nPos := Ascan(aDipSenhas,{|x| x[1] == cTipo .and. x[2] == cObjeto})) > 0 .and. !aDipSenhas[nPos][DSENHA]
			If lSenha // Alterando senha para Liberado
				aDipSenhas[nPos][DSENHA] := lSenha
				lRetorno := .t. // Autorizado a liberação do pedido, não pedir mais senha.
			Else
				lRetorno := .f. // Não Autorizado a liberação do pedido, pode pedir a senha novamente
			EndIf
			
		ElseIf nPos > 0
			
			If aDipSenhas[nPos][VALOR1] <> nValor1 .or. aDipSenhas[nPos][VALOR2] <> nValor2
				
				If nValor1 < nValor2
					aDipSenhas[nPos][DSENHA] := .f.    // Invalida senha recebida antes da troca do valor do item Prc*Qtd
					aDipSenhas[nPos][VALOR1] := nValor1
					aDipSenhas[nPos][VALOR2] := nValor2
					lRetorno := .f.                    // Não Autorizado a liberação do item, pode pedir a senha.
				EndIf
				
			Else
				lRetorno := .t.               // Autorizado a liberação do item, não pode pedir a senha novamente
			EndIf
			
		Else
			// Inclusão da senha senha para o pedido
			aadd(aDipSenhas,{cTipo, cObjeto, nValor1, nValor2, lSenha})
			
			If lSenha // Bloqueando para não pedir de novo esta senha.
				lRetorno := .t. // Autorizado a liberação do pedido, não pedir mais senha.
			Else
				lRetorno := .f. // Não Autorizado a liberação do pedido, pode pedir a senha novamente
			EndIf
			
		EndIf
		
	Case cTipo == "MA2"
		
		If (nPos := Ascan(aDipSenhas,{|x| x[1] == cTipo .and. x[2] == cObjeto})) > 0 .and. !aDipSenhas[nPos][DSENHA]
			
			If lSenha // Alterando senha para Liberação do item
				aDipSenhas[nPos][DSENHA] := lSenha
				lRetorno := .t. // Autorizado a liberação do pedido, não pedir mais senha.
			Else
				lRetorno := .f. // Não Autorizado a liberação do pedido, pode pedir a senha novamente
			EndIf
			
		ElseIf nPos > 0
			
			If aDipSenhas[nPos][VALOR1] <> nValor1
				aDipSenhas[nPos][DSENHA] := .f. // Invalida senha recebida antes da troca do valor do item Prc*Qtd
				aDipSenhas[nPos][VALOR1] := nValor1
				lRetorno := .f.                 // Não Autorizado a liberação do item, pode pedir a senha.
			Else
				lRetorno := .t.                 // Autorizado a liberação do item, não pode pedir a senha novamente
			EndIf
			
		Else
			
			aadd(aDipSenhas,{cTipo, cObjeto, nValor1, nValor2, lSenha})	// Inclusão da senha para o item
			
			If lSenha // Bloqueando para não pedir de novo esta senha.
				lRetorno := .t. // Autorizado a liberação do pedido, não pedir mais senha.
			Else
				lRetorno := .f. // Não Autorizado a liberação do pedido, pode pedir a senha novamente
			EndIf
		EndIf

	Case cTipo == "MA3"
		
		If (nPos := Ascan(aDipSenhas,{|x| x[1] == cTipo .and. x[2] == cObjeto})) > 0 .and. !aDipSenhas[nPos][DSENHA]
			
			If lSenha // Alterando senha para Liberação do item
				aDipSenhas[nPos][DSENHA] := lSenha
				lRetorno := .t. // Autorizado a liberação do pedido, não pedir mais senha.
			Else
				lRetorno := .f. // Não Autorizado a liberação do pedido, pode pedir a senha novamente
			EndIf
			
		ElseIf nPos > 0
			
			If aDipSenhas[nPos][VALOR1] <> nValor1
				aDipSenhas[nPos][DSENHA] := .f. // Invalida senha recebida antes da troca do valor do item Prc*Qtd
				aDipSenhas[nPos][VALOR1] := nValor1
				lRetorno := .f.                 // Não Autorizado a liberação do item, pode pedir a senha.
			Else
				lRetorno := .t.                 // Autorizado a liberação do item, não pode pedir a senha novamente
			EndIf
			
		Else
			
			aadd(aDipSenhas,{cTipo, cObjeto, nValor1, nValor2, lSenha})	// Inclusão da senha para o item
			
			If lSenha // Bloqueando para não pedir de novo esta senha.
				lRetorno := .t. // Autorizado a liberação do pedido, não pedir mais senha.
			Else
				lRetorno := .f. // Não Autorizado a liberação do pedido, pode pedir a senha novamente
			EndIf
		EndIf
		
	case cTipo == "PAG"
		
		If (nPos := Ascan(aDipSenhas,{|x| x[1] == cTipo .and. x[2] == cObjeto})) > 0 .and. !aDipSenhas[nPos][DSENHA]
			
			If lSenha // Alterando senha para Liberação
				aDipSenhas[nPos][DSENHA] := lSenha
				aDipSenhas[nPos][VALOR1]  := nValor1
				lRetorno := .t. // Autorizado a liberação do pedido, não pedir mais senha.
			Else
				lRetorno := .f. // Não Autorizado a liberação do pedido, pode pedir a senha novamente
			EndIf
			
		ElseIf nPos > 0
			
			If aDipSenhas[nPos][VALOR1] <> nValor1
				aDipSenhas[nPos][DSENHA] := .f.// Invalida senha recebida antes da troca do valor do item Prc*Qtd
				aDipSenhas[nPos][VALOR1] := nValor1
				lRetorno := .f.               // Não Autorizado a liberação do item, pode pedir a senha.
			Else
				lRetorno := .t.               // Autorizado a liberação do item, não pode pedir a senha novamente
			EndIf
			
		Else
			
			aadd(aDipSenhas,{cTipo, cObjeto, nValor1, nValor2, lSenha})	// Inclusão da senha para o item
			
			If lSenha // Bloqueando para não pedir de novo esta senha.
				lRetorno := .t. // Autorizado a liberação do pedido, não pedir mais senha.
			Else
				lRetorno := .f. // Não Autorizado a liberação do pedido, pode pedir a senha novamente
			EndIf
		EndIf
		
		// GIOVANI 01/08/11
	Case cTipo == "MIE"
		
		If (nPos := Ascan(aDipSenhas,{|x| x[1] == cTipo .and. x[2] == cObjeto})) > 0 .and. !aDipSenhas[nPos][DSENHA]
			
			If lSenha // Alterando senha para Liberação do item
				aDipSenhas[nPos][DSENHA] := lSenha
				lRetorno := .t. // Autorizado a liberação do pedido, não pedir mais senha.
			Else
				lRetorno := .f. // Não Autorizado a liberação do pedido, pode pedir a senha novamente
			EndIf
			
		ElseIf nPos > 0
			
			If aDipSenhas[nPos][VALOR1] <> nValor1
				aDipSenhas[nPos][DSENHA] := .f. // Invalida senha recebida antes da troca do valor do item Prc*Qtd
				aDipSenhas[nPos][VALOR1] := nValor1
				lRetorno := .f.                 // Não Autorizado a liberação do item, pode pedir a senha.
			Else
				lRetorno := .t.                 // Autorizado a liberação do item, não pode pedir a senha novamente
			EndIf
			
		Else
			
			aadd(aDipSenhas,{cTipo, cObjeto, nValor1, nValor2, lSenha})	// Inclusão da senha para o item
			
			If lSenha // Bloqueando para não pedir de novo esta senha.
				lRetorno := .t. // Autorizado a liberação do pedido, não pedir mais senha.
			Else
				lRetorno := .f. // Não Autorizado a liberação do pedido, pode pedir a senha novamente
			EndIf
		EndIf
		
		//**************************************************************************************************************************************
		
		
	case cTipo == "CID"
	case cTipo == "TES"
	case cTipo == "DEL"
	case cTipo == "FRE" // SENHA PARA ALTERAR O DESTINO DO FRETE - MCVN 02/08/2007
	case cTipo == "KIM" // SENHA PARA FATURAR KIMBERLY FORA DE SP - MCVN 03/08/2007
	case cTipo == "DTV" // SENHA PARA LIBERAR DATA DE VALIDADE COM DATA MENOR QUE 6 MESES - MCVN 23/07/2008  //Giovani Zago 17/08/11
		//Giovani Zago 17/08/11
		If (nPos := Ascan(aDipSenhas,{|x| x[1] == cTipo .and. x[2] == cObjeto .and. x[3] == nValor1 })) > 0  .and. aDipSenhas[nPos][5]  //verifica se ja foi digitado senha no array - aDipSenhas 1-["DTV"] 2-[ITEM] 3-[DATA] 4-[VAZIO CASO NECESSITE DE OUTRO IDENTIFICADOR] 5-[.T. OU .F.]
			lRetorno := .t. // Autorizado a liberação do pedido, não pedir mais senha.
		Else
			If lSenha
				aadd(aDipSenhas,{cTipo, cObjeto, nValor1, nValor2, lSenha})	// Inclusão da senha para o item
				lRetorno := .t. // Autorizado a liberação do pedido, não pedir mais senha.
			Else
				lRetorno := .f.// Não Autorizado a liberação do pedido, pode pedir a senha novamente
			EndIf
		EndIf
		
		//**************************************************************************************************************************************
	case cTipo == "EMP" // SENHA PARA LIBERAR ALTERAÇÃO/EXCLUSÃO DE PEDIDOS DE CLIENTES DE OUTRA EMPRESA - MCVN 27/04/2010
		
EndCase
Return(lRetorno)
/*
|=============================================================================|
|  Programa  |  SENHA   | Autor |   Rodrigo Franco   | Data |  29/01/2002     |
|------------+----------+-------+--------------------+------+-----------------|
|  Descricao | Rotina utilizada para liberacao de acordo com a senha          |
|------------+----------------------------------------------------------------|
|  Andreia.......  65 'A'                                                     |
|  Bete..........  66 'B'                                                     |
|  Daniela.......  68 'E'                                                     |
|  Erich.........  69 'E'                                                     |
|  Fernanda......  70 'F'                                                     |
|  Licitação.....  76 'L'                                                     |
|  Elenice.......  78 'N'                                                     |
|  Patricia......  80 'P'                                                     |
|  Luciana.......  85 'U'                                                     |
|  Paula.........  96 '`'                                                     |
|=============================================================================|
*/
*-------------------------------------------------------------------------------------*
User Function Senha(_cFunc,_cValPed,_nMargAtuPed,_nMargLib,_lPagEsp, aAdvertc,bSenha)
*-------------------------------------------------------------------------------------*
Local _xArea    := GetArea()
Local _xAreaSF4
Local _xTES
Local _xCliente
Local _cPedido
Local oDlg
//Local nPosPrcven
Local cMV_DtProd // JBS 25/10/2006
Local dDtIni // JBS 25/10/2006
Local dDtFin // JBS 25/10/2006
Local _cNopassword  := GetMV("MV_NOPASSW") // Usuário que utilizam todo o sistema sem senha
Local _cTesFree     := GetMV("MV_TESFREE") // Tes que não precisa de senha
Local _cUserTesAmost:= GetMV("MV_TESAMOS") // Usuário com liberação de senha para TES de amostra - MCVN 29/05/09
Local _nFatorRecolh := 1 // giovani 01/08/11
Local i	:= 0 //Rafael Rosa Obify - 01/07/2022

Private _cSenha     := Space(10)
Private _lRet       := .F.
Private _lSaida     := .F.
Private cNom_Lib    := Space(15)
Private bSenhaVal   := If(bSenha==NIL, '', bSenha)
                                                      
If !("DIPA040"$UPPER(FunName()))
	Private  nPosPrcven  := aScan(aHeader,{|x|Alltrim(x[2])==IIF("TMK"$FunName(),"UB_VRUNIT","C6_PRCVEN")})
	Private _nPosSupe    := aScan(aHeader,{|x|Alltrim(x[2])==IIF("TMK"$FunName(),"UB_VRUNIT","C6_PRVSUPE")})  // giovani 01/08/11
	Private _nPosMini    := aScan(aHeader,{|x|Alltrim(x[2])==IIF("TMK"$FunName(),"UB_VRUNIT","C6_PRVMINI")})  // giovani 01/08/11
	Private _nPosProd    := aScan(aHeader,{|x|Alltrim(x[2])==IIF("TMK"$FunName(),"UB_PRODUTO","C6_PRODUTO")})  // giovani 01/08/11
EndIf

//giovani 09/08/11
Private cValSenha := ""
Static cSenmail    := ""

If ISINCALLSTACK("LOJA901A") .Or. ISINCALLSTACK("LOJA901")
	Return .T.
EndIf

//Tratamento para não solicitar senha para usuários informado no parâmetro MV_NoPassw
If Upper(U_DipUsr()) $ _cNopassword
	Return(.T.)
Endif


_lPagEsp := Iif(_lPagEsp=NIL,.f.,_lPagEsp)

IF _cFunc == "PAG"
	Do While !_lSaida
		@ 100,150 To 250,600 Dialog oDlg Title OemToAnsi("Liberacao da Condição de Pagamento. R$ "+Transform(_cValPed,"@E 99,999,999.99")) // Condicao de Pagamento nao permitida, pelo valor praticado
		@ 010,020 SAY "Valor Minimo:  "
		@ 010,060 SAY SE4->E4_INFER PICTURE "@E 99,999,999,999.99" SIZE 170,020
		@ 020,020 SAY "Valor Maximo: "
		@ 020,060 SAY SE4->E4_SUPER PICTURE "@E 99,999,999,999.99" SIZE 170,020
		@ 040,020 Say OemToAnsi("Senha :") 	Size 040,020
		
		@ 040,060 Get _cSenha Size 060,020
		@ 055,100 BmpButton Type 1 Action (SenhaOk1(_cSenha,_cValPed,_cFunc,_lPagEsp),Close(oDlg))
		@ 055,130 BmpButton Type 2 Action (Saida(),Close(oDlg))
		Activate Dialog oDlg Centered
	EndDo
ElseIf _cFunc == "MAR"
	Do While !_lSaida
		@ 200,150 To 400,600 Dialog oDlg Title OemToAnsi("Liberacao do Pedido. R$ "+Transform(_cValPed,"@E 999,999.99"))
		@ 010,020 SAY "Indice do Pedido: " + Transform(_nMargAtuPed,"@E 999.999") SIZE 160,020
		@ 020,020 SAY "Indice  Minimo:   " + Transform(_nMargLib,"@E 999.999")    SIZE 160,020
		If "TMK" $ Alltrim(FunName())
			@ 040,020 SAY "Despesa:  " + Transform(M->UA_DESPESA,"@E 999,999.99") SIZE 080,020
			@ 050,020 SAY "Frete:    " + Transform(M->UA_FRETE,"@E 999,999.99")   SIZE 080,020
		Else
			@ 040,020 SAY "Despesa:  " + Transform(M->C5_DESPESA,"@E 999,999.99") SIZE 080,020
			@ 050,020 SAY "Frete:    " + Transform(M->C5_FRETE,"@E 999,999.99") SIZE 080,020
		EndIf
		@ 070,020 Say OemToAnsi("Senha :") 	Size 040,020
		@ 070,060 Get _cSenha Size 060,020
		@ 085,100 BmpButton Type 1 Action (SenhaOk2(_cSenha,_nMargAtuPed,_cValPed,_cFunc),Close(oDlg))
		@ 085,130 BmpButton Type 2 Action (Saida(),Close(oDlg))
		Activate Dialog oDlg Centered
		lDipSenha1 := _lRet
	EndDo
ElseIf _cFunc == "MA2"
	
	If !Empty(SB1->B1_PERPROM) // JBS 25/10/2006
		
		dDtIni := cTod(SubStr(SB1->B1_PERPROM,1,at('-',SB1->B1_PERPROM)-1)) // JBS 25/10/2006
		dDtFin := cTod(SubStr(SB1->B1_PERPROM,at('-',SB1->B1_PERPROM)+1,len(AllTrim(SB1->B1_PERPROM)))) // JBS 25/10/2006
		
		//	nPosPrcven := aScan(aHeader,{|x|Alltrim(x[2])==IIF("TMK"$FunName(),"UB_VRUNIT","C6_PRCVEN")}) // JBS 25/10/2006
		
		If ((Acols[n,nPosPrcven]>=SB1->B1_PRVSUPE .AND. SB1->B1_PRVSUPE >0) .OR.;
			(Acols[n,nPosPrcven]>=SB1->B1_PRVMINI .AND. SB1->B1_PRVMINI >0)) .and. ;
			dDataBase >= dDtIni .and. dDataBase <= dDtFin // JBS 25/10/2006
			_lSaida := .T. // JBS 25/10/2006
			_lRet   := .T. // JBS 25/10/2006
		EndIf // JBS 25/10/2006
		
	EndIf // JBS 25/10/2006
	
	Do While !_lSaida
		@ 200,150 To 350,480 Dialog oDlg Title OemToAnsi("Liberacao do Item: "+AllTrim(aCols[n,1])) +". R$ "+Transform(_cValPed,"@E 999,999.9999")
		//		@ 010,020 SAY "Margem Atual do Item: " + Transform(_nMargAtuPed,"@E 999.99")+ "%" SIZE 160,020
		//		@ 020,020 SAY "Margem Minima do Item:  " + Transform(_nMargLib,"@E 999.99")+ "%" SIZE 160,020
		@ 010,020 SAY "Indice do Item:     " + Transform(_nMargAtuPed,"@E 999.999") SIZE 160,020
		@ 020,020 SAY "Indice  Minimo:    " + Transform(_nMargLib,"@E 999.999") SIZE 160,020
		@ 040,020 Say OemToAnsi("Senha :") 	Size 040,020
		@ 040,060 Get _cSenha Size 060,020
		@ 055,100 BmpButton Type 1 Action (SenhaOk2(_cSenha,_nMargAtuPed,_cValPed,_cFunc),Close(oDlg))
		@ 055,130 BmpButton Type 2 Action (Saida(),Close(oDlg))
		Activate Dialog oDlg Centered
		lDipSenha2 := _lRet
	EndDo
	
ElseIf _cFunc == "MA3"	
                                                 
	_nValInf := _nMargLib   
	SB1->(dbSetOrder(1))
	If SB1->(dbSeek(xFilial("SB1")+AllTrim(aCols[n,_nPosProd])))
		If SB1->B1_PRVSUPE > 0 .And. _nValInf >= SB1->B1_PRVSUPE//PROMOÇÃO
			_lSaida := .T.
			_lRet 	:= .T.
		ElseIf SB1->B1_PRVMINI > 0 .And. _nValInf >= SB1->B1_PRVMINI //Preço C		
			_lSaida := .T.
			_lRet 	:= .T.
		EndIf
	
		Do While !_lSaida
			@ 200,150 To 350,480 Dialog oDlg Title OemToAnsi("Liberacao do Item: "+AllTrim(aCols[n,1])) +". R$ "+Transform(_cValPed,"@E 999,999.9999")
			@ 010,020 SAY "Valor Informado:     " + Transform(_nValInf,"@E 999.999") SIZE 160,020
			@ 020,020 SAY "Valor Mínimo   :     " + Transform(IIf(SB1->B1_PRVSUPE<SB1->B1_PRVMINI .And. SB1->B1_PRVSUPE>0,SB1->B1_PRVSUPE,SB1->B1_PRVMINI),"@E 999.999") SIZE 160,020
			@ 040,020 Say OemToAnsi("Senha :") 	Size 040,020
			@ 040,060 Get _cSenha Size 060,020
			@ 055,100 BmpButton Type 1 Action (SenhaOk2(_cSenha,_nValInf,_cValPed,_cFunc),Close(oDlg))
			@ 055,130 BmpButton Type 2 Action (Saida(),Close(oDlg))
			Activate Dialog oDlg Centered
			lDipSenha2 := _lRet
		EndDo
	Else 
		Aviso("SENHA L401","Produto não encontrado. Avise o T.I.",{"Ok"},1)
	EndIf

ElseIf _cFunc == "MIE"
	
	IF !("TMK"$FunName())  .and. !("DIPAL10" $ FunName())
		If substr(M->C5_XRECOLH,1,3) $ "ACR"
			_nFatorRecolh:= 1.16
		ElseIf substr(M->C5_XRECOLH,1,3) $ "ISE"
			_nFatorRecolh:= 1.06
		Else
			_nFatorRecolh:= 1
		EndIf
	EndIf

	
	If !Empty(SB1->B1_PERPROM)
		
		dDtIni := cTod(SubStr(SB1->B1_PERPROM,1,at('-',SB1->B1_PERPROM)-1))
		dDtFin := cTod(SubStr(SB1->B1_PERPROM,at('-',SB1->B1_PERPROM)+1,len(AllTrim(SB1->B1_PERPROM))))
		
		
		
		
		If ((Acols[n,nPosPrcven]>=SB1->B1_PRVSUPE .AND. SB1->B1_PRVSUPE >0) .OR.;
			(Acols[n,nPosPrcven]>=SB1->B1_PRVMINI .AND. SB1->B1_PRVMINI >0)) .and. ;
			dDataBase >= dDtIni .and. dDataBase <= dDtFin
			_lSaida := .T.
			_lRet   := .T.
		EndIf
		
	EndIf
	Do While !_lSaida
		@ 200,150 To 350,480 Dialog oDlg Title OemToAnsi("Liberacao do Item: "+AllTrim(aCols[n,1])) +". R$ "+Transform(_cValPed,"@E 999,999.9999")
		@ 010,020 SAY "Valor do Item:     " + Transform( Acols[n,nPosPrcven],"@E 999.9999") SIZE 160,020
		If  aCols[n,_nPosSupe] > 0
			@ 020,020 SAY "Valor Minimo:    " + Transform((Acols[n,_nPosSupe]*_nFatorRecolh),"@E 999.9999") SIZE 160,020
		Else
			@ 020,020 SAY "Valor Minimo:    " + Transform((Acols[n,_nPosMini]*_nFatorRecolh),"@E 999.9999") SIZE 160,020
		EndIf
		@ 040,020 Say OemToAnsi("Senha :") 	Size 040,020
		@ 040,060 Get _cSenha Size 060,020
		@ 055,100 BmpButton Type 1 Action (SenhaOk6(_cSenha,_nMargAtuPed,_cValPed,_cFunc),Close(oDlg))
		@ 055,130 BmpButton Type 2 Action (Saida(),Close(oDlg))
		Activate Dialog oDlg Centered
		lDipSenha3 := _lRet
	EndDo
	//********************************************************************************
ElseIf _cFunc == "CID"
	Do While !_lSaida
		@ 100,150 To 250,530 Dialog oDlg Title OemToAnsi("Liberacao do Bloqueio")
		@ 010,020 SAY "PRODUTO NAO PODE SER VENDIDO PARA ESTE CLIENTE"
		@ 020,020 SAY "Deseja Liberar"
		@ 040,020 Say OemToAnsi("Senha :") 	Size 040,020
		@ 040,060 Get _cSenha Size 060,020
		@ 055,100 BmpButton Type 1 Action (SenhaOk3(_cSenha,_cFunc),Close(oDlg))
		@ 055,130 BmpButton Type 2 Action (Saida(),Close(oDlg))
		Activate Dialog oDlg Centered
	EndDo
ElseIf _cFunc == "FRE" // SENHA PARA ALTERAR O DESTINO DO FRETE - MCVN 02/08/2007
	Do While !_lSaida
		@ 100,150 To 250,530 Dialog oDlg Title OemToAnsi("Liberacao do Destino Frete")
		@ 010,020 SAY "ALTERANDO DESTINO DO FRETE"
		@ 020,020 SAY "Deseja Liberar"
		@ 040,020 Say OemToAnsi("Senha :") 	Size 040,020
		@ 040,060 Get _cSenha Size 060,020
		@ 055,100 BmpButton Type 1 Action (SenhaOk3(_cSenha,_cFunc),Close(oDlg))
		@ 055,130 BmpButton Type 2 Action (Saida(),Close(oDlg))
		Activate Dialog oDlg Centered
	EndDo
ElseIf _cFunc == "KIM" // SENHA PARA FATURAR KIMBERLY FORA DE SP - MCVN 03/08/2007
	Do While !_lSaida
		@ 100,150 To 250,530 Dialog oDlg Title OemToAnsi("Liberacao DE Kimberly p/ fora de SP")
		@ 010,020 SAY "FATURANDO KIMBERLY FORA DE SP"
		@ 020,020 SAY "Deseja Liberar?"
		@ 040,020 Say OemToAnsi("Senha :") 	Size 040,020
		@ 040,060 Get _cSenha Size 060,020
		@ 055,100 BmpButton Type 1 Action (SenhaOk3(_cSenha,_cFunc),Close(oDlg))
		@ 055,130 BmpButton Type 2 Action (Saida(),Close(oDlg))
		Activate Dialog oDlg Centered
	EndDo
ElseIf _cFunc == "DTV" //  SENHA PARA LIBERAR DATA DE VALIDADE COM DATA MENOR QUE 6 MESES - MCVN 23/07/2008
	Do While !_lSaida
		@ 100,150 To 250,530 Dialog oDlg Title OemToAnsi("Libera Data de Validade do Lote menor que 6 meses")
		@ 010,020 SAY "VALIDADE DO LOTE MENOR QUE 6 MESES"
		@ 020,020 SAY "Confirma validade?"
		@ 040,020 Say OemToAnsi("Senha :") 	Size 040,020
		@ 040,060 Get _cSenha Size 060,020
		@ 055,100 BmpButton Type 1 Action (SenhaOk7(_cSenha,_nMargAtuPed,_cValPed,_cFunc),Close(oDlg)) //Giovani Zago 17/08/11   chama função SenhaOk7()
		@ 055,130 BmpButton Type 2 Action (Saida(),Close(oDlg))
		Activate Dialog oDlg Centered
	EndDo
	cSenmail := _cSenha  // GIOVANI 09/08/11
ElseIf _cFunc == "PED" // SENHA PARA IMPRIMIR NO WORD - MCVN 04/03/2008
	Do While !_lSaida
		@ 100,150 To 250,530 Dialog oDlg Title OemToAnsi("Impressão de Pedido de Venda no Word")
		@ 010,020 SAY "IMPRESSÃO DE PEDIDO DE VENDA NO WORD"
		@ 020,020 SAY "Deseja imprimir no word?"
		@ 040,020 Say OemToAnsi("Senha :") 	Size 040,020
		@ 040,060 Get _cSenha Size 060,020
		@ 055,100 BmpButton Type 1 Action (SenhaOk3(_cSenha,_cFunc),Close(oDlg))
		@ 055,130 BmpButton Type 2 Action (Saida(),Close(oDlg))
		Activate Dialog oDlg Centered
	EndDo
ElseIf _cFunc == "EMP" //  SENHA PARA LIBERAR DATA DE VALIDADE COM DATA MENOR QUE 6 MESES - MCVN 23/07/2008
	Do While !_lSaida
		@ 100,150 To 250,530 Dialog oDlg Title OemToAnsi("Autorização para alterar/excluir pedido!")
		@ 010,020 SAY "AUTORIZA  ALTERAÇÃO/EXCLUSÃO  DE  PEDIDO"
		@ 020,020 SAY "Confirma Alteração/Exclusão?"
		@ 040,020 Say OemToAnsi("Senha :") 	Size 040,020
		@ 040,060 Get _cSenha Size 060,020
		@ 055,100 BmpButton Type 1 Action (SenhaOk3(_cSenha,_cFunc),Close(oDlg))
		@ 055,130 BmpButton Type 2 Action (Saida(),Close(oDlg))
		Activate Dialog oDlg Centered
	EndDo
ElseIf _cFunc == "TES"

//Rafael Rosa Obify - 01/07/2022 - INICIO
IF (Type("l103Auto") <> "U" .And. l103Auto) .OR. FunName()=="SCHEDCOMCOL"
ELSE
//Rafael Rosa Obify - 01/07/2022 - FIM

	_xAreaSF4 := SF4->(GetArea())
	
	If "TMK"$FunName()
		_xTES := aCols[n,aScan(aHeader, { |x| Alltrim(x[2]) == "UB_TES"})]
		//M->UB_TES
		_xCLiente := M->UA_CLIENTE
		_cPedido  := M->UA_NUM // JBS 10/01/2006
		
	ElseIf FunName() == 'MATA103'
		_xTES := aCols[n,aScan(aHeader, { |x| Alltrim(x[2]) == "D1_TES"})]
		_xCLiente := 'XXXXXX'
		_cPedido  := aCols[n,aScan(aHeader, { |x| Alltrim(x[2]) == "D1_PEDIDO"})] // JBS 10/01/2006
	Else
		_xTES := M->C6_TES
		_xCLiente := M->C5_CLIENTE
		_cPedido  := M->C5_NUM  // JBS 10/01/2006
	EndIf

	Dbselectarea("SF4")
	Dbsetorder(1)
	If Dbseek(xfilial("SF4")+_xTES)
		IF  ("AMOSTRA" $ Upper(SF4->F4_TEXTO) .And. Upper(U_DipUsr()) $ _cUserTesAmost)  .OR.; // Se for TES de amostra e o usuario estiver contido no parametro 29/05/09
			_xTES $ _cTesFree                                          .OR.;
			Upper(U_DipUsr()) $ 'ERIBERTO/EELIAS'        .OR.;
			Upper(U_DipUsr()) $ 'RENATA/RENATA'          .OR.;
			Upper(U_DipUsr()) $ 'WILLIAM PEREIRA/WPEREIRA' .OR.;
			Upper(U_DipUsr()) $ 'MAGDA/MTEIXEIRA'           .OR.;
			'CONSIGNA' $ SF4->F4_TEXTO .OR.;
			'CONSIGNA' $ SF4->F4_TXTLEGA .OR.;
			(Upper(U_DipUsr()) $ 'CRISTIANE/CARLA/CRODRIGUES' .AND. _xCliente $ '010231/004303/000270') .OR.;
			(Upper(U_DipUsr()) $ 'CLEIA/CFREITAS'           .AND. _xTES $ '569/594') .OR.;
			(Upper(U_DipUsr()) $ 'WILLIAM SOARES'  .AND. _xTES $ '569/594') .OR.;
			(Upper(U_DipUsr()) $ 'FABIANA BESSA/FBESSA'   .AND. _xTES $ '569/594') .OR.;
			(Upper(U_DipUsr()) $ 'TIAGO DANTAS'    .AND. _xTES $ '569/594') .OR.;
			(Upper(U_DipUsr()) $ 'TATIANE'         .AND. _xTES $ '569/594') .OR.;
			(Upper(U_DipUsr()) $ 'TIAGO DANTAS'    .AND. _xTES $ '569/594') .OR.;
			(Upper(U_DipUsr()) $ 'LUCIANE/LCIRILO'         .AND. _xTES $ '569/594') .OR.;
			(Upper(U_DipUsr()) $ 'ALINE CAMPOS/ACAMPOS'    .AND. _xTES $ '569/594') .OR.;
			(Upper(U_DipUsr()) $ 'JANE/JLIMA'            .AND. _xTES $ '569/594') .OR.;
			(Upper(U_DipUsr()) $ 'ADRIANA SILVA'   .AND. _xTES $ '569/594') .OR.;
			(Upper(U_DipUsr()) $ 'CAMILA'          .AND. _xTES $ '569/594')
			_lRet := .T.
		Else
			If len(aTesPed)>1 .and. aTesPed[1] <> _cPedido
				aTesPed := {}
			EndIf
			
			If len(aTesPed)>1 .and. _xTes $ aTesPed[2]
				_lSaida := .T.
				_lRet   := .T.
			ElseIf len(aTesPed)>2 .and. _xTes $ aTesPed[3]
				_lSaida := .T.
				_lRet   := .T.
			EndIf
			
			Do While !_lSaida
				@ 200,150 To 400,480 Dialog oDlg Title OemToAnsi("Liberacao do TES")
				@ 020,020 SAY "Controle: " + Transform(_cValPed,"@E 999,999,999,999.9999") SIZE 160,020
				@ 050,020 Say OemToAnsi("Senha :") 	Size 040,020
				@ 050,060 Get _cSenha Size 060,020
				@ 085,100 BmpButton Type 1 Action (SenhaOk4(_cSenha,_cValPed,_cFunc),Close(oDlg))
				@ 085,130 BmpButton Type 2 Action (Saida(),Close(oDlg))
				Activate Dialog oDlg Centered
				// Confirmando a senha a senha digitada com verdadeira
				// Guarda a Tes digitada na array estatica de TES
				If _lRet
					If len(aTesPed)>1
						aTesPed[3]:=aTesPed[3]+', '+aTesPed[2]+', '+_xTES
						aTesPed[2]:=_xTES
					Else // Se achou, faz a aleração para a nova TES
						aAdd(aTesPed,_cPedido)
						aAdd(aTesPed,_xTES)
						aAdd(aTesPed,_xTES)
					EndIf
				EndIf
			EndDo
			cSenmail := _cSenha  // GIOVANI 09/08/11
		EndIf
	Else
		Help("",1,"REGNOIS")
	EndIf
	RestArea(_xAreaSF4)

//Rafael Rosa Obify - 01/07/2022
ENDIF

ElseIf _cFunc == "DEL"
	Do While !_lSaida
		@ 100,150 To 290,530 Dialog oDlg Title OemToAnsi("Liberação de Exclusão")
		_li := 10
		aAdvertc:={}
		For i:= 1 to Len(aAdvertc)
			@ _li,020 say aAdvertc[i]
			_li+=10
		Next
		@ _li+20,020 Say OemToAnsi("Senha :") 	Size 040,020
		@ _li+20,060 Get _cSenha Size 060,020
		@ _li+40,100 BmpButton Type 1 Action (SenhaOk5(_cSenha,_cValPed,_cFunc),Close(oDlg))
		@ _li+40,130 BmpButton Type 2 Action (Saida(),Close(oDlg))
		Activate Dialog oDlg Centered
	EndDo
ElseIf _cFunc == "END"
	Do While !_lSaida
		@ 200,150 To 400,480 Dialog oDlg Title OemToAnsi("Liberacao de endereçamento")
		@ 020,020 SAY "Peça a senha para o T.I." SIZE 160,020
		@ 050,020 Say OemToAnsi("Senha :") 	Size 040,020
		@ 050,060 Get _cSenha Size 060,020
		@ 085,100 BmpButton Type 1 Action (SenhaOk4(_cSenha,_cValPed,_cFunc),Close(oDlg))
		@ 085,130 BmpButton Type 2 Action (Saida(),Close(oDlg))
		Activate Dialog oDlg Centered
	EndDo
ENDIF

RestArea(_xArea)

Return(_lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³ SENHAOK1 ºAutor  ³   Rodrigo Franco   º Data ³  29/01/2002 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Confirma senha informada. - PARA PAGAMENTO                 º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function SenhaOk1(_cSenha,_cValPed,_cFunc,_lPagEsp)
Local cNomeSenha := ''
// Verifica se senha digitada foi fornecida por Eriberto
If !Upper(SubStr(_cSenha,1,1)) $ "ABEFLMNPUX"
	//'EeAaPp'
	// Erich  69 'E'
	_cValid1 := 0
	_cValid1 := _cValPed/val(SUBSTR(DTOC(DDATABASE),1,2))*val(SUBSTR(DTOC(DDATABASE),4,2))
	//_cValid1 := int(abs(_cValid1))
	_cValid1 := '69'+AllTrim(Iif(Len(AllTrim(str(int(abs(_cValid1)))))<6,str(int(abs(_cValid1))),Substr(AllTrim(str(int(abs(_cValid1)))),1,6)))
	If ALLTRIM(UPPER(cNom_Lib)) = 'ERICH'
		_cSenha := ALLTRIM(_cValid1)
	EndIf
	
	// Patricia  80 'P'
	_cValid2 := 0
	_cValid2 := _cValPed/val(SUBSTR(DTOC(DDATABASE),1,2))*150
	//_cValid2 := (_cValPed/val(SUBSTR(DTOC(DDATABASE),4,2))*val(SUBSTR(DTOC(DDATABASE),1,2))+10000)/5 // 18/04/06 _cValPed/3*val(SUBSTR(DTOC(DDATABASE),1,2))/7
	//_cValid2 := int(abs(_cValid2))
	//_cValid2 := str(_cValid2)
	_cValid2 := '80'+AllTrim(Iif(Len(AllTrim(str(int(abs(_cValid2)))))<6,str(int(abs(_cValid2))),Substr(AllTrim(str(int(abs(_cValid2)))),1,6)))
	If ALLTRIM(UPPER(cNom_Lib)) = 'PATRICIA'
		_cSenha := ALLTRIM(_cValid2)
	EndIf
	
	// Andreia  65 'A'
	_cValid3 := 0
	_cValid3 := _cValPed/val(SUBSTR(DTOC(DDATABASE),4,2))*17
	//_cValid3 := int(abs(_cValid3))
	//_cValid3 := str(_cValid3)
	_cValid3 := '65'+AllTrim(Iif(Len(AllTrim(str(int(abs(_cValid3)))))<6,str(int(abs(_cValid3))),Substr(AllTrim(str(int(abs(_cValid3)))),1,6)))
	If ALLTRIM(UPPER(cNom_Lib)) = 'ANDREIA'
		_cSenha := ALLTRIM(_cValid3)
	EndIf
	
	// Fernanda  70 'F'
	_cValid4 := 0
	_cValid4 := _cValPed/3*19
	//_cValid4 := int(abs(_cValid4))
	//_cValid4 := str(_cValid4)
	_cValid4 := '70'+AllTrim(Iif(Len(AllTrim(str(int(abs(_cValid4)))))<6,str(int(abs(_cValid4))),Substr(AllTrim(str(int(abs(_cValid4)))),1,6)))
	If ALLTRIM(UPPER(cNom_Lib)) = 'FERNANDA'
		_cSenha := ALLTRIM(_cValid4)
	EndIf
	
	// Licitação   76 'L'
	_cValid5 := 0
	_cValid5 := _cValPed/4*val(SUBSTR(DTOC(DDATABASE),1,2))/5  //_cValPed/7*5
	//_cValid5 := int(abs(_cValid5))
	//_cValid5 := str(_cValid5)
	_cValid5 := '76'+AllTrim(Iif(Len(AllTrim(str(int(abs(_cValid5)))))<6,str(int(abs(_cValid5))),Substr(AllTrim(str(int(abs(_cValid5)))),1,6)))
	If ALLTRIM(UPPER(cNom_Lib)) = Upper(U_DipUsr())
		_cSenha := ALLTRIM(_cValid5)
	EndIf
	
	// Luciana  85 'U'
	_cValid6 := 0
	_cValid6 := (_cValPed/val(SUBSTR(DTOC(DDATABASE),4,2))+4)*16 // _cValPed/3*19
	_cValid6 := '85'+AllTrim(Iif(Len(AllTrim(str(int(abs(_cValid6)))))<6,str(int(abs(_cValid6))),Substr(AllTrim(str(int(abs(_cValid6)))),1,6)))
	If ALLTRIM(UPPER(cNom_Lib)) = 'LUCIANA'
		_cSenha := ALLTRIM(_cValid6)
	EndIf
	
	// Elenice 78 'N'
	_cValid7 := 0
	_cValid7 := (_cValPed/val(SUBSTR(DTOC(DDATABASE),4,2))+8)*18 //_cValPed/8*16
	_cValid7 := '78'+AllTrim(Iif(Len(AllTrim(str(int(abs(_cValid7)))))<6,str(int(abs(_cValid7))),Substr(AllTrim(str(int(abs(_cValid7)))),1,6)))
	If ALLTRIM(UPPER(cNom_Lib)) = 'ELENICE'
		_cSenha := ALLTRIM(_cValid7)
	EndIf
	
	// Bete 66 'B'
	_cValid8 := 0
	_cValid8 := _cValPed/val(SUBSTR(DTOC(DDATABASE),1,2))*95   //083 // * 250
	_cValid8 := '66'+AllTrim(Iif(Len(AllTrim(str(int(abs(_cValid8)))))<6,str(int(abs(_cValid8))),Substr(AllTrim(str(int(abs(_cValid8)))),1,6)))
	If ALLTRIM(UPPER(cNom_Lib)) = 'BETE'
		_cSenha := ALLTRIM(_cValid8)
	EndIf
	
	// Paula 96 '`'
	_cValid9 := 0
	_cValid9 := _cValPed/val(SUBSTR(DTOC(DDATABASE),1,2))*350
	_cValid9 := '96'+AllTrim(Iif(Len(AllTrim(str(int(abs(_cValid9)))))<6,str(int(abs(_cValid9))),Substr(AllTrim(str(int(abs(_cValid9)))),1,6)))
	If ALLTRIM(UPPER(cNom_Lib)) = 'PAULA'
		_cSenha := ALLTRIM(_cValid9)
	EndIf
	
	// Daniela 68 'D'
	_cValid0 := 0
	_cValid0 := _cValPed/val(SUBSTR(DTOC(DDATABASE),1,2))*103
	_cValid0 := '68'+AllTrim(Iif(Len(AllTrim(str(int(abs(_cValid0)))))<6,str(int(abs(_cValid0))),Substr(AllTrim(str(int(abs(_cValid0)))),1,6)))
	If ALLTRIM(UPPER(cNom_Lib)) = 'DANIELA'
		_cSenha := ALLTRIM(_cValid0)
	EndIf
	
	IF ALLTRIM(_cSenha) == ALLTRIM(_cValid1)
		_lSaida := .T.
		_lRet   := .T.
		//		Close(oDlg)
		If "TMK"$FunName()
			M->UA_SENHPAG := "ERICH"
		Else
			M->C5_SENHPAG := "ERICH"
		EndIf
	ElseIf ALLTRIM(_cSenha) == ALLTRIM(_cValid2)
		_lSaida := .T.
		_lRet   := .T.
		//		Close(oDlg)
		If "TMK"$FunName()
			M->UA_SENHPAG := "PATRICIA"
		Else
			M->C5_SENHPAG := "PATRICIA"
		EndIf
	ElseIf ALLTRIM(_cSenha) == ALLTRIM(_cValid3)
		_lSaida := .T.
		_lRet   := .T.
		//		Close(oDlg)
		If "TMK"$FunName()
			M->UA_SENHPAG := "ANDREIA"
		Else
			M->C5_SENHPAG := "ANDREIA"
		EndIf
	ElseIf ALLTRIM(_cSenha) == ALLTRIM(_cValid4)  //     (Eriberto solicitou dia - 14/03/2005)
		_lSaida := .T.
		_lRet   := .T.
		//		Close(oDlg)
		If "TMK"$FunName()
			M->UA_SENHPAG := "FERNANDA"
		Else
			M->C5_SENHPAG := "FERNANDA"
		EndIf
	ElseIf ALLTRIM(_cSenha) == ALLTRIM(_cValid5)
		_lSaida := .T.
		_lRet   := .T.
		//		Close(oDlg)
		If "TMK"$FunName()
			M->UA_SENHPAG := Upper(U_DipUsr())
		Else
			M->C5_SENHPAG := Upper(U_DipUsr())
		EndIf
	ElseIf ALLTRIM(_cSenha) == ALLTRIM(_cValid6)
		_lSaida := .T.
		_lRet   := .T.
		If "TMK"$FunName()
			M->UA_SENHPAG := "LUCIANA"
		Else
			M->C5_SENHPAG := "LUCIANA"
		EndIf
	ElseIf ALLTRIM(_cSenha) == ALLTRIM(_cValid7)
		_lSaida := .T.
		_lRet   := .T.
		If "TMK"$FunName()
			M->UA_SENHPAG := "ELENICE"
		Else
			M->C5_SENHPAG := "ELENICE"
		EndIf
	ElseIf ALLTRIM(_cSenha) == ALLTRIM(_cValid8)
		_lSaida := .T.
		_lRet   := .T.
		If "TMK"$FunName()
			M->UA_SENHPAG := "BETE"
		Else
			M->C5_SENHPAG := "BETE"
		EndIf
	ElseIf ALLTRIM(_cSenha) == ALLTRIM(_cValid9)
		_lSaida := .T.
		_lRet   := .T.
		If "TMK"$FunName()
			M->UA_SENHPAG := "PAULA"
		Else
			M->C5_SENHPAG := "PAULA"
		EndIf
	ElseIf ALLTRIM(_cSenha) == ALLTRIM(_cValid0)
		_lSaida := .T.
		_lRet   := .T.
		If "TMK"$FunName()
			M->UA_SENHPAG := "DANIELA"
		Else
			M->C5_SENHPAG := "DANIELA"
		EndIf
	ELSE
		MsgBox("Senha Invalida !!! ","Atencao ","ALERT")
	EndIF
	
Else
	
	// Chama validação para senha informada pelo Eriberto.
	EESenha(_cSenha,_cFunc)
	
EndIf
If "TMK"$FunName()
	cNomeSenha := M->UA_SENHPAG
Else
	cNomeSenha := M->C5_SENHPAG
EndIf
If _lSaida .AND. _lRet .and. (!_lPagEsp .or. (_lPagEsp .and. 'ERICH' $ ALLTRIM(UPPER(cNomeSenha))))
	PegaExplSen(_cSenha)
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³ SENHAOK2 ºAutor  ³   Rodrigo Franco   º Data ³  29/01/2002 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Confirma senha informada. - PARA MARGEM                    º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function SenhaOk2(_cSenha,_nMargAtuPed,_cValPed,_cFunc)

//Verifica se senha digitada foi fornecida por Eriberto
If !Upper(SubStr(_cSenha,1,1)) $ "ABEFLMNPUX"// 'EeAaPp'
	
	// Erich  69 'E'
	_cValid1 := 0
	_cValid1 := _cValPed/val(SUBSTR(DTOC(DDATABASE),1,2))*val(SUBSTR(DTOC(DDATABASE),4,2))
	//_cValid1 := int(abs(_cValid1))
	_cValid1 := '69'+AllTrim(Iif(Len(AllTrim(str(int(abs(_cValid1)))))<6,str(int(abs(_cValid1))),Substr(AllTrim(str(int(abs(_cValid1)))),1,6)))
	If ALLTRIM(UPPER(cNom_Lib)) = 'ERICH'
		_cSenha := ALLTRIM(_cValid1)
	EndIf
	
	// Patricia  80 'P'
	_cValid2 := 0
	_cValid2 := _cValPed/val(SUBSTR(DTOC(DDATABASE),1,2))*150
	_cValid2 := '80'+AllTrim(Iif(Len(AllTrim(str(int(abs(_cValid2)))))<6,str(int(abs(_cValid2))),Substr(AllTrim(str(int(abs(_cValid2)))),1,6)))
	If ALLTRIM(UPPER(cNom_Lib)) = 'PATRICIA'
		_cSenha := ALLTRIM(_cValid2)
	EndIf
	
	// Andreia  65 'A'
	_cValid3 := 0
	_cValid3 := _cValPed/val(SUBSTR(DTOC(DDATABASE),4,2))*17
	//_cValid3 := int(abs(_cValid3))
	//_cValid3 := str(_cValid3)
	_cValid3 := '65'+AllTrim(Iif(Len(AllTrim(str(int(abs(_cValid3)))))<6,str(int(abs(_cValid3))),Substr(AllTrim(str(int(abs(_cValid3)))),1,6)))
	If ALLTRIM(UPPER(cNom_Lib)) = 'ANDREIA'
		_cSenha := ALLTRIM(_cValid3)
	EndIf
	
	
	// Fernanda 70 'F'
	_cValid4 := 0
	_cValid4 := _cValPed/3*19
	//_cValid4 := int(abs(_cValid4))
	//_cValid4 := str(_cValid4)
	_cValid4 := '70'+AllTrim(Iif(Len(AllTrim(str(int(abs(_cValid4)))))<6,str(int(abs(_cValid4))),Substr(AllTrim(str(int(abs(_cValid4)))),1,6)))
	If ALLTRIM(UPPER(cNom_Lib)) = 'FERNANDA'
		_cSenha := ALLTRIM(_cValid4)
	EndIf
	
	// Licitação 76 'L'
	_cValid5 := 0
	_cValid5 := _cValPed/4*val(SUBSTR(DTOC(DDATABASE),1,2))/5 //_cValPed/7*5
	//_cValid5 := int(abs(_cValid5))
	//_cValid5 := str(_cValid5)
	_cValid5 := '76'+AllTrim(Iif(Len(AllTrim(str(int(abs(_cValid5)))))<6,str(int(abs(_cValid5))),Substr(AllTrim(str(int(abs(_cValid5)))),1,6)))
	If ALLTRIM(UPPER(cNom_Lib)) = Upper(U_DipUsr())
		_cSenha := ALLTRIM(_cValid5)
	EndIf
	
	// Luciana  85 'U'
	_cValid6 := 0
	_cValid6 := (_cValPed/val(SUBSTR(DTOC(DDATABASE),4,2))+4)*16 // _cValPed/8*16
	_cValid6 := '85'+AllTRim(Iif(Len(AllTrim(str(int(abs(_cValid6)))))<6,str(int(abs(_cValid6))),Substr(AllTrim(str(int(abs(_cValid6)))),1,6)))
	If ALLTRIM(UPPER(cNom_Lib)) = 'LUCIANA'
		_cSenha := ALLTRIM(_cValid6)
	EndIf
	// Elenice 78 'N'
	_cValid7 := 0
	_cValid7 := (_cValPed/val(SUBSTR(DTOC(DDATABASE),4,2))+8)*18 //  _cValPed/9*18
	_cValid7 := '78'+AllTrim(Iif(Len(AllTrim(str(int(abs(_cValid7)))))<6,str(int(abs(_cValid7))),Substr(AllTrim(str(int(abs(_cValid7)))),1,6)))
	If ALLTRIM(UPPER(cNom_Lib)) = 'ELENICE'
		_cSenha := ALLTRIM(_cValid7)
	EndIf
	// BETE 66 'B'
	_cValid8 := 0
	_cValid8 := _cValPed/val(SUBSTR(DTOC(DDATABASE),1,2))*95 //83 // * 250
	_cValid8 := '66'+AllTrim(Iif(Len(AllTrim(str(int(abs(_cValid8)))))<6,str(int(abs(_cValid8))),Substr(AllTrim(str(int(abs(_cValid8)))),1,6)))
	If ALLTRIM(UPPER(cNom_Lib)) = 'BETE'
		_cSenha := ALLTRIM(_cValid8)
	EndIf
	
	// Paula 96 '`'
	_cValid9 := 0
	_cValid9 := _cValPed/val(SUBSTR(DTOC(DDATABASE),1,2))*350
	_cValid9 := '96'+AllTrim(Iif(Len(AllTrim(str(int(abs(_cValid9)))))<6,str(int(abs(_cValid9))),Substr(AllTrim(str(int(abs(_cValid9)))),1,6)))
	If ALLTRIM(UPPER(cNom_Lib)) = 'PAULA'
		_cSenha := ALLTRIM(_cValid9)
	EndIf
	
	// Daniela 68 'D'
	_cValid0 := 0
	_cValid0 := _cValPed/val(SUBSTR(DTOC(DDATABASE),1,2))*103
	_cValid0 := '68'+AllTrim(Iif(Len(AllTrim(str(int(abs(_cValid0)))))<6,str(int(abs(_cValid0))),Substr(AllTrim(str(int(abs(_cValid0)))),1,6)))
	If ALLTRIM(UPPER(cNom_Lib)) = 'DANIELA'
		_cSenha := ALLTRIM(_cValid0)
	EndIf
	
	IF ALLTRIM(_cSenha) == ALLTRIM(_cValid1)
		_lSaida := .T.
		_lRet   := .T.
		//	Close(oDlg)
		If "TMK"$FunName()
			M->UA_SENHMAR := "ERICH"
		Else
			M->C5_SENHMAR := "ERICH"
		EndIf
	ElseIf ALLTRIM(_cSenha) == ALLTRIM(_cValid2)
		_lSaida := .T.
		_lRet   := .T.
		//	Close(oDlg)
		If "TMK"$FunName()
			M->UA_SENHMAR := "PATRICIA"
		Else
			M->C5_SENHMAR := "PATRICIA"
		EndIf
	ElseIf ALLTRIM(_cSenha) == ALLTRIM(_cValid3)
		_lSaida := .T.
		_lRet   := .T.
		//	Close(oDlg)
		If "TMK"$FunName()
			M->UA_SENHMAR := "ANDREIA"
		Else
			M->C5_SENHMAR := "ANDREIA"
		EndIf
	ElseIf ALLTRIM(_cSenha) == ALLTRIM(_cValid4)
		_lSaida := .T.
		_lRet   := .T.
		//	Close(oDlg)
		If "TMK"$FunName()
			M->C5_SENHMAR := "FERNANDA"
		Else
			M->C5_SENHMAR := "FERNANDA"
		EndIf
	ElseIf ALLTRIM(_cSenha) == ALLTRIM(_cValid5)
		_lSaida := .T.
		_lRet   := .T.
		//	Close(oDlg)
		If "TMK"$FunName()
			M->UA_SENHMAR := Upper(U_DipUsr())
		Else
			M->C5_SENHMAR := Upper(U_DipUsr())
		EndIf
	ElseIf ALLTRIM(_cSenha) == ALLTRIM(_cValid6)
		_lSaida := .T.
		_lRet   := .T.
		//	Close(oDlg)
		If "TMK"$FunName()
			M->UA_SENHMAR := "LUCIANA"
		Else
			M->C5_SENHMAR := "LUCIANA"
		EndIf
	ElseIf ALLTRIM(_cSenha) == ALLTRIM(_cValid7)
		_lSaida := .T.
		_lRet   := .T.
		//	Close(oDlg)
		If "TMK"$FunName()
			M->UA_SENHMAR := "ELENICE"
		Else
			M->C5_SENHMAR := "ELENICE"
		EndIf
	ElseIf ALLTRIM(_cSenha) == ALLTRIM(_cValid8)
		_lSaida := .T.
		_lRet   := .T.
		//	Close(oDlg)
		If "TMK"$FunName()
			M->UA_SENHMAR := "BETE"
		Else
			M->C5_SENHMAR := "BETE"
		EndIf
	ElseIf ALLTRIM(_cSenha) == ALLTRIM(_cValid9)
		_lSaida := .T.
		_lRet   := .T.
		//	Close(oDlg)
		If "TMK"$FunName()
			M->UA_SENHMAR := "PAULA"
		Else
			M->C5_SENHMAR := "PAULA"
		EndIf
	ElseIf ALLTRIM(_cSenha) == ALLTRIM(_cValid0)
		_lSaida := .T.
		_lRet   := .T.
		//	Close(oDlg)
		If "TMK"$FunName()
			M->UA_SENHMAR := "DANIELA"
		Else
			M->C5_SENHMAR := "DANIELA"
		EndIf
	ELSE
		MsgBox("Senha Invalida !!! ","Atencao ","ALERT")
		//MsgBox("Senha Invalida !!! "+_cvalid1,"Atencao "+str(_cValPed)+'  '+SUBSTR(DTOC(DDATABASE),1,2)+'   '+SUBSTR(DTOC(DDATABASE),4,2),"ALERT")
	EndIF
	
Else
	
	// Chama validação para senha informada pelo Eriberto.
	EESenha(_cSenha,_cFunc)
	
EndIf

If _lSaida .AND. _lRet
	PegaExplSen(_cSenha)
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³ SENHAOK3 ºAutor  ³   Rodrigo Franco   º Data ³  29/01/2002 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Confirma senha informada. - PARA CIDADE                    º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function SenhaOk3(_cSenha,_cFunc)

//Verifica se senha digitada foi fornecida por Eriberto
If !Upper(SubStr(_cSenha,1,1)) $ "ABEFLMNPUX" // $ 'EeAaPp'
	
	If _cFunc == "FRE"  .OR. _cFunc == "KIM" .or. _cFunc == "DTV" .or. _cFunc == "PED"  .or. _cFunc == "EMP" //MCVN 02/08/2007
		_cValPed := 0
	Endif
	
	// Erich  69 'E'
	_cValid1 := 0
	_cValid1 := _cValPed/val(SUBSTR(DTOC(DDATABASE),1,2))*val(SUBSTR(DTOC(DDATABASE),4,2))
	//_cValid1 := int(abs(_cValid1))
	_cValid1 := '69'+AllTrim(Iif(Len(AllTrim(str(int(abs(_cValid1)))))<6,str(int(abs(_cValid1))),Substr(AllTrim(str(int(abs(_cValid1)))),1,6)))
	
	// Patricia 80 'P'
	_cValid2 := 0
	_cValid2 := _cValPed/val(SUBSTR(DTOC(DDATABASE),1,2))*150
	_cValid2 := '80'+AllTrim(Iif(Len(AllTrim(str(int(abs(_cValid2)))))<6,str(int(abs(_cValid2))),Substr(AllTrim(str(int(abs(_cValid2)))),1,6)))
	
	// Andreia 65 'A'
	_cValid3 := 0
	_cValid3 := _cValPed/val(SUBSTR(DTOC(DDATABASE),4,2))*17
	//_cValid3 := int(abs(_cValid3))
	//_cValid3 := str(_cValid3)
	_cValid3 := '65'+AllTrim(Iif(Len(AllTrim(str(int(abs(_cValid3)))))<6,str(int(abs(_cValid3))),Substr(AllTrim(str(int(abs(_cValid3)))),1,6)))
	
	
	// FERNANDA 70 'F'
	_cValid4 := 0
	_cValid4 := _cValPed/3*19
	//_cValid4 := int(abs(_cValid4))
	//_cValid4 := str(_cValid4)
	_cValid4 := '70'+AllTrim(Iif(Len(AllTrim(str(int(abs(_cValid4)))))<6,str(int(abs(_cValid4))),Substr(AllTrim(str(int(abs(_cValid4)))),1,6)))
	
	
	// Licitação 76 'L'
	_cValid5 := 0
	_cValid5 := _cValPed/4*val(SUBSTR(DTOC(DDATABASE),1,2))/5 //_cValPed/7*5
	//_cValid5 := int(abs(_cValid5))
	//_cValid5 := str(_cValid5)
	_cValid5 := '76'+AllTrim(Iif(Len(AllTrim(str(int(abs(_cValid5)))))<6,str(int(abs(_cValid5))),Substr(AllTrim(str(int(abs(_cValid5)))),1,6)))
	
	// Luciana 85 'U'
	_cValid6 := 0
	_cValid6 := (_cValPed/val(SUBSTR(DTOC(DDATABASE),4,2))+4)*16 // _cValPed/8*16
	_cValid6 := '85'+AllTrim(Iif(Len(AllTrim(str(int(abs(_cValid6)))))<6,str(int(abs(_cValid6))),Substr(AllTrim(str(int(abs(_cValid6)))),1,6)))
	
	// Elenice  78 'N'
	_cValid7 := 0
	_cValid7 := (_cValPed/val(SUBSTR(DTOC(DDATABASE),4,2))+8)*18 //_cValPed/9*18
	_cValid7 := '78'+AllTrim(Iif(Len(AllTrim(str(int(abs(_cValid7)))))<6,str(int(abs(_cValid7))),Substr(AllTrim(str(int(abs(_cValid7)))),1,6)))
	
	// BETE  66 'B'
	_cValid8 := 0
	_cValid8 := _cValPed/val(SUBSTR(DTOC(DDATABASE),1,2))*83
	_cValid8 := '66'+AllTrim(Iif(Len(AllTrim(str(int(abs(_cValid8)))))<6,str(int(abs(_cValid8))),Substr(AllTrim(str(int(abs(_cValid8)))),1,6)))
	
	// Paula 96 '`'
	_cValid9 := 0
	_cValid9 := _cValPed/val(SUBSTR(DTOC(DDATABASE),1,2))*350
	_cValid9 := '96'+AllTrim(Iif(Len(AllTrim(str(int(abs(_cValid9)))))<6,str(int(abs(_cValid9))),Substr(AllTrim(str(int(abs(_cValid9)))),1,6)))
	
	// Paula 68 'D'
	_cValid0 := 0
	_cValid0 := _cValPed/val(SUBSTR(DTOC(DDATABASE),1,2))*103
	_cValid0 := '68'+AllTrim(Iif(Len(AllTrim(str(int(abs(_cValid0)))))<6,str(int(abs(_cValid0))),Substr(AllTrim(str(int(abs(_cValid0)))),1,6)))
	
	IF ALLTRIM(_cSenha) == ALLTRIM(_cValid1)
		_lSaida := .T.
		_lRet   := .T.
		//	Close(oDlg)
		If "TMK"$FunName()
			M->UA_SENHCID := "ERICH"
		Else
			M->C5_SENHCID := "ERICH"
		EndIf
	ElseIf ALLTRIM(_cSenha) == ALLTRIM(_cValid2)
		_lSaida := .T.
		_lRet   := .T.
		//	Close(oDlg)
		If "TMK"$FunName()
			M->UA_SENHCID := "PATRICIA"
		Else
			M->C5_SENHCID := "PATRICIA"
		EndIf
	ElseIf ALLTRIM(_cSenha) == ALLTRIM(_cValid3)
		_lSaida := .T.
		_lRet   := .T.
		//	Close(oDlg)
		If "TMK"$FunName()
			M->UA_SENHCID := "ANDREIA"
		Else
			M->C5_SENHCID := "ANDREIA"
		EndIf
	ElseIf ALLTRIM(_cSenha) == ALLTRIM(_cValid4)
		_lSaida := .T.
		_lRet   := .T.
		//	Close(oDlg)
		If "TMK"$FunName()
			M->UA_SENHPAG := "FERNANDA"
		Else
			M->C5_SENHPAG := "FERNANDA"
		EndIf
	ElseIf ALLTRIM(_cSenha) == ALLTRIM(_cValid5)
		_lSaida := .T.
		_lRet   := .T.
		//	Close(oDlg)
		If "TMK"$FunName()
			M->UA_SENHPAG := Upper(U_DipUsr())
		Else
			M->C5_SENHPAG := Upper(U_DipUsr())
		EndIf
	ElseIf ALLTRIM(_cSenha) == ALLTRIM(_cValid6)
		_lSaida := .T.
		_lRet   := .T.
		//	Close(oDlg)
		If "TMK"$FunName()
			M->UA_SENHPAG := "LUCIANA"
		Else
			M->C5_SENHPAG := "LUCIANA"
		EndIf
	ElseIf ALLTRIM(_cSenha) == ALLTRIM(_cValid7)
		_lSaida := .T.
		_lRet   := .T.
		//	Close(oDlg)
		If "TMK"$FunName()
			M->UA_SENHPAG := "ELENICE"
		Else
			M->C5_SENHPAG := "ELENICE"
		EndIf
	ElseIf ALLTRIM(_cSenha) == ALLTRIM(_cValid8)
		_lSaida := .T.
		_lRet   := .T.
		//	Close(oDlg)
		If "TMK"$FunName()
			M->UA_SENHPAG := "BETE"
		Else
			M->C5_SENHPAG := "BETE"
		EndIf
	ElseIf ALLTRIM(_cSenha) == ALLTRIM(_cValid9)
		_lSaida := .T.
		_lRet   := .T.
		//	Close(oDlg)
		If "TMK"$FunName()
			M->UA_SENHPAG := "PAULA"
		Else
			M->C5_SENHPAG := "PAULA"
		EndIf
	ElseIf ALLTRIM(_cSenha) == ALLTRIM(_cValid0)
		_lSaida := .T.
		_lRet   := .T.
		//	Close(oDlg)
		If "TMK"$FunName()
			M->UA_SENHPAG := "DANIELA"
		Else
			M->C5_SENHPAG := "DANIELA"
		EndIf
	ELSE
		MsgBox("Senha Invalida !!!","Atencao","ALERT")
	EndIF
	
Else
	
	// Chama validação para senha informada pelo Eriberto.
	EESenha(_cSenha,_cFunc)
	
EndIf

If _lSaida .AND. _lRet
	PegaExplSen(_cSenha)
EndIf

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³ SENHAOK4 ºAutor  ³ Eriberto Elias     º Data ³ 21/07/2003  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Confirma senha informada. - PARA TES                       º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function SenhaOk4(_cSenha,_cValPed,_cFunc)

//Verifica se senha digitada foi fornecida por Eriberto
If !SubStr(_cSenha,1,1) $  'MmeE'
	
	// Magda
	_cValid1 := 0
	_cValid1 := _cValPed * Val(Substr(DtoS(Date()),7,2)) * Val(Substr(DtoS(Date()),5,2)) / 21
	//_cValid1 := _cValPed / 11*13
	//val(SUBSTR(DTOC(DDATABASE),1,2))*val(SUBSTR(DTOC(DDATABASE),4,2))
	_cValid1 := Iif(Len(AllTrim(str(int(abs(_cValid1)))))<6,str(int(abs(_cValid1))),Substr(AllTrim(str(int(abs(_cValid1)))),1,6))
	
	IF ALLTRIM(_cSenha) == ALLTRIM(_cValid1)
		_lSaida := .T.
		_lRet   := .T.
		//	Close(oDlg)
		If "TMK"$FunName()
			M->UA_SENHTES := "MAGDA"
		ElseIf FunName() == 'MATA103'
			M->D1_SENHTES := "MAGDA"
		Else
			M->C5_SENHTES := "MAGDA"
		EndIf
	ELSE
		MsgBox("Senha Invalida !!! ","Atencao ","ALERT")
	EndIF
	
Else
	
	// Chama validação para senha informada pelo Eriberto.
	EESenha(_cSenha,_cFunc)
	
EndIf


If _lSaida .AND. _lRet
	PegaExplSen(_cSenha)
EndIf

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³ SENHAOK5 ºAutor  ³ Jailton B Santos  º Data ³ 09/01/2006  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Confirma senha informada. - Exclusão em Geral              º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function SenhaOk5(_cSenha,_cValPed,_cFunc)

//Verifica se senha digitada foi fornecida por Eriberto
If !SubStr(_cSenha,1,1) $ 'MmeE'
	
	// Magda
	_cValid1 := 0
	_cValid1 := _cValPed * Val(Substr(DtoS(Date()),7,2)) * Val(Substr(DtoS(Date()),5,2)) / 21
	_cValid1 := Iif(Len(AllTrim(str(int(abs(_cValid1)))))<6,str(int(abs(_cValid1))),Substr(AllTrim(str(int(abs(_cValid1)))),1,6))
	
	IF AllTrim(_cSenha) == AllTrim(_cValid1)
		_lSaida := .T.  //
		_lRet   := .T.  //
		If !empty(bSenhaVal) // Verifica se foi informado um code block na chamada da fução
			Eval(bSenhaVal)  // Avalia o code block passado e o executa
		EndIf
		
		//		If("TMK"$FunName(),M->UA_SENHTES:="MAGDA",if(FunName()=='MATA103',M->D1_SENHTES:="MAGDA",M->C5_SENHTES:="MAGDA"))
		/*
		
		If "TMK"$FunName()
		//		M->UA_SENHTES := "MAGDA"
		ElseIf FunName() == 'MATA103'
		//		M->D1_SENHTES := "MAGDA"
		Else
		//		M->C5_SENHTES := "MAGDA"
		EndIf
		*/
	ELSE
		MsgBox("Senha Invalida !!! ","Atencao ","ALERT")
	EndIF
	
Else
	
	// Chama validação para senha informada pelo Eriberto.
	EESenha(_cSenha,_cFunc)
	
EndIf

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma ³ PegaExplSena ºAutor ³ Eriberto Elias   º Data ³  05/04/2003 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³  Grava a explicacao da senha.                             º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function PegaExplSen(_cSenha)
Local oDlg
Private _lSaidaP  := .F.
Private _cExplSen //:= IIf("TMK"$FunName(),M->UA_EXPLSEN,M->C5_EXPLSEN)


If !("DIPR061"$Funname())
	If "TMK"$FunName()
		_cExplSen := M->UA_EXPLSEN
	ElseIf FunName() == 'MATA103'
		_cExplSen := aCols[n,aScan(aHeader, { |x| Alltrim(x[2]) == "D1_EXPLSEN"})]
	ElseIf (FunName() $'MATA240/MATA241/MATA265/DIPA040' .or. PROCNAME(5) == 'U_DIPV002')
		_cExplSen := Space(100)
	Else
		_cExplSen := M->C5_EXPLSEN
	EndIf
	
	If Upper(SubStr(_cSenha,1,7)) == "MX1976*"
		_cExplSen := "Testando optimizacoes Protheus - Departamento de T.I."
	EndIf
	
	While !_lSaidaP
		@ 100,150 To 200,530 Dialog oDlg Title OemToAnsi("Explicacao da SENHA de Liberacao")
		@ 010,010 Get _cExplSen Valid !Empty(_cExplSen) SIZE 170,10
		@ 030,150 BmpButton Type 1 Action (SaidaP(),Close(oDlg))
		Activate Dialog oDlg Centered
	EndDo
	
	If "TMK"$FunName()
		M->UA_EXPLSEN := Iif(Empty(_cExplSen),M->UA_EXPLSEN,_cExplSen)
	ElseIf FunName() == 'MATA103'
		M->UA_EXPLSEN := Iif(Empty(_cExplSen),aCols[n,aScan(aHeader, { |x| Alltrim(x[2]) == "D1_EXPLSEN"})],_cExplSen)
	ElseIf (FunName() == 'MATA240' .Or. FunName() == 'MATA241' .Or.  FunName() == 'DIPA040' )
		// Não grava explicação
	Else
		M->C5_EXPLSEN := Iif(Empty(_cExplSen),M->C5_EXPLSEN,_cExplSen)
	EndIf
EndIf
Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³  SaidaP   ºAutor  ³   Eriberto Elias   º Data ³ 05/04/2003 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Valida saida da tela de explicacao                         º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function SaidaP()
//_lSaidaP := Iif(Empty(_cExplSen),.F.,.T.)
//Close(oDlg)

If Len(AllTrim(_cExplSen)) > 25
	//		Close(oDlg)
	_lSaidaP := .T.
Else
	_lSaidaP := .F.
	MsgBox("Explicação inválida, explique com mais detalhes !!!","Atenção!","Error")
EndIf

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³  SAIDA   ºAutor  ³   Rodrigo Franco   º Data ³  29/01/2002 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Valida saida da tela de senha.                             º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Saida()
_lSaida := .T.
_lRet   := .F.
//Close(oDlg)
Return

/*====================================================================================\
|Programa  | EESENHA       | Autor | Rafael de Campos Falco     | Data | 05/03/2005   |
|=====================================================================================|
|Descrição | Calculo de senha específico para Eriberto                                |
|          |                                                                          |
|          |                                                                          |
|=====================================================================================|
|Sintaxe   | EESENHA                                                                  |
|=====================================================================================|
|Uso       | Especifico DIPROMED                                                      |
|=====================================================================================|
|........................................Histórico....................................|
|Rafael    | DD/MM/AA - Descrição                                                     |
|Eriberto  | DD/MM/AA - Descrição                                                     |
\====================================================================================*/
*----------------------------------------*
Static Function EESenha(_cSenha,_cFunc)
*----------------------------------------*
Local cHora
Local cDia
Local nPos
Local cCalcSenha

If Upper(SubStr(_cSenha,1,7)) == "MX1976*"
	_lSaida := .T.
	_lRet   := .T.
	Return
ElseIf Upper(SubStr(_cSenha,1,1)) == "A"
	cNom_Lib := "*ANDREIA"
ElseIf Upper(SubStr(_cSenha,1,1)) == "B"
	cNom_Lib := "*ELIZABETE"
ElseIf Upper(SubStr(_cSenha,1,1)) == "D"
	cNom_Lib := "*DANIELA"
ElseIf Upper(SubStr(_cSenha,1,1)) == "E"
	cNom_Lib := "*ERICH"
ElseIf Upper(SubStr(_cSenha,1,1)) == "F"
	cNom_Lib := "*FERNANDA"
ElseIf Upper(SubStr(_cSenha,1,1)) == "L"
	cNom_Lib := "*"+Upper(U_DipUsr())
ElseIf Upper(SubStr(_cSenha,1,1)) == "M"
	cNom_Lib := "*MAGDA"
ElseIf Upper(SubStr(_cSenha,1,1)) == "N"
	cNom_Lib := "*ELENICE"
ElseIf Upper(SubStr(_cSenha,1,1)) == "P"
	cNom_Lib := "*PATRICIA"
ElseIf Upper(SubStr(_cSenha,1,1)) == "U"
	cNom_Lib := "*LUCIANA"
ElseIf Upper(SubStr(_cSenha,1,1)) == "X"
	cNom_Lib := "*PAULA"
EndIf

aLetra := {{"Q","00","09"},;
{"W","09","10"},;
{"E","10","11"},;
{"R","11","12"},;
{"T","12","13"},;
{"Y","13","14"},;
{"U","14","15"},;
{"I","15","16"},;
{"O","16","17"},;
{"P","17","24"}}

cHora := StrZero(Val(SubStr(Time(),1,2))+1,2)
cDia  := SubStr(dtos(date()),7,2)
nPos  := Ascan(aLetra,{|x| cHora > x[2] .and. cHora <= x[3] })
cCalcSenha := aLetra[nPos][1] + StrZero(val(cDia)+val(aLetra[nPos][3]),2)
/*
Horário:
00-09   = Q + ( dia +  9) -> AQ15 para: Andreia 06 de junho
09-10   = W + ( dia + 10) -> AW16
10-11   = E + ( dia + 11) -> AE17
11-12   = R + ( dia + 12) -> AR18
12-13   = T + ( dia + 13) -> AT19
13-14   = Y + ( dia + 14) -> AY20
14-15   = U + ( dia + 15) -> AU21
15-16   = I + ( dia + 16) -> AI22
16-17   = O + ( dia + 17) -> AO23
17-24   = P + ( dia + 24) -> AP30
*/

If Upper(SubStr(_cSenha,2,6)) <> cCalcSenha
	// Val(SubStr(DtoS(dDataBase),7,2))+Val(Substr(Time(),1,2))+Val(SubStr(Time(),4,2))+3
	MsgBox("Senha Invalida !!! ee","Atencao ","ALERT")
	_lSaida := .F.
	_lRet   := .F.
ElseIf _cFunc == 'DEL'
	_lSaida := .T.
	_lRet   := .T.   
Else
	_lSaida := .T.
	_lRet   := .T.   	
	
	If Upper(SubStr(_cSenha,1,1)) != "M"  .And. _cFunc <> 'TES'  // MCVN - 21/08/2007 //If Upper(SubStr(_cSenha,1,1)) != "M"
		
		If _cFunc = 'PAG'
			_cCampo := 'SENHPAG'
		ElseIf _cFunc $ 'MAR/MA2/MIE/MA3/END'
			_cCampo := 'SENHMAR'
		ElseIf _cFunc = 'CID'
			_cCampo := 'SENHCID'
		ElseIf _cFunc = 'FRE'
			_cCampo := 'SENHCID'
		ElseIf _cFunc = 'KIM'
			_cCampo := 'SENHCID'
		ElseIf _cFunc = 'DTV'
			_cCampo := 'SENHCID'
		ElseIf _cFunc = 'PED'
			_cCampo := 'SENHCID'
		ElseIf _cFunc = 'EMP'
			_cCampo := 'SENHCID'
		EndIf
		
		If !("DIPR061"$Funname())
			If "TMK" $ FunName()
				_cCampo := 'M->UA_'+_cCampo
			Else
				_cCampo := 'M->C5_'+_cCampo
			EndIf
			
			
			&(_cCampo) := cNom_Lib
		Endif
	Else
		If "TMK"$FunName()
			M->UA_SENHTES := "*MAGDA"
		ElseIf FunName() == 'MATA103'
			M->D1_SENHTES := "*MAGDA"
		Else
			M->C5_SENHTES := "*MAGDA"
		EndIf
	EndIf
	
EndIf
Return
*------------------------------------------*
User function CalcSenha(cCalcSenha,cCalac)
*------------------------------------------*
Local oSenha
@ 100,150 To 250,530 Dialog oSenha Title OemToAnsi("Liberacao da Condição de Pagamento.")
@ 040,020 Say "Senha" 	Size 040,020
@ 030,060 Get cCalac when .f. Size 120,010
@ 040,060 Get cCalcSenha when .f. Size 060,010
@ 055,100 BmpButton Type 1 Action (oSenha)

Activate Dialog oSenha Centered

Return(.t.)


//giovani 01/08/11

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³ SENHAOK6 ºAutor  ³   Giovani Zago     º Data ³  01/08/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Confirma senha informada. - PARA PEDIDO ICMS               º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function SenhaOk6(_cSenha,_nMargAtuPed,_cValPed,_cFunc)

//Verifica se senha digitada foi fornecida por Eriberto
If !Upper(SubStr(_cSenha,1,1)) $ "ABEFLMNPUX"// 'EeAaPp'
	
	// Erich  69 'E'
	_cValid1 := 0
	_cValid1 := _cValPed/val(SUBSTR(DTOC(DDATABASE),1,2))*val(SUBSTR(DTOC(DDATABASE),4,2))
	//_cValid1 := int(abs(_cValid1))
	_cValid1 := '69'+AllTrim(Iif(Len(AllTrim(str(int(abs(_cValid1)))))<6,str(int(abs(_cValid1))),Substr(AllTrim(str(int(abs(_cValid1)))),1,6)))
	If ALLTRIM(UPPER(cNom_Lib)) = 'ERICH'
		_cSenha := ALLTRIM(_cValid1)
	EndIf
	
	// Patricia  80 'P'
	_cValid2 := 0
	_cValid2 := _cValPed/val(SUBSTR(DTOC(DDATABASE),1,2))*150
	_cValid2 := '80'+AllTrim(Iif(Len(AllTrim(str(int(abs(_cValid2)))))<6,str(int(abs(_cValid2))),Substr(AllTrim(str(int(abs(_cValid2)))),1,6)))
	If ALLTRIM(UPPER(cNom_Lib)) = 'PATRICIA'
		_cSenha := ALLTRIM(_cValid2)
	EndIf
	
	// Andreia  65 'A'
	_cValid3 := 0
	_cValid3 := _cValPed/val(SUBSTR(DTOC(DDATABASE),4,2))*17
	//_cValid3 := int(abs(_cValid3))
	//_cValid3 := str(_cValid3)
	_cValid3 := '65'+AllTrim(Iif(Len(AllTrim(str(int(abs(_cValid3)))))<6,str(int(abs(_cValid3))),Substr(AllTrim(str(int(abs(_cValid3)))),1,6)))
	If ALLTRIM(UPPER(cNom_Lib)) = 'ANDREIA'
		_cSenha := ALLTRIM(_cValid3)
	EndIf
	
	
	// Fernanda 70 'F'
	_cValid4 := 0
	_cValid4 := _cValPed/3*19
	//_cValid4 := int(abs(_cValid4))
	//_cValid4 := str(_cValid4)
	_cValid4 := '70'+AllTrim(Iif(Len(AllTrim(str(int(abs(_cValid4)))))<6,str(int(abs(_cValid4))),Substr(AllTrim(str(int(abs(_cValid4)))),1,6)))
	If ALLTRIM(UPPER(cNom_Lib)) = 'FERNANDA'
		_cSenha := ALLTRIM(_cValid4)
	EndIf
	
	// Licitação 76 'L'
	_cValid5 := 0
	_cValid5 := _cValPed/4*val(SUBSTR(DTOC(DDATABASE),1,2))/5 //_cValPed/7*5
	//_cValid5 := int(abs(_cValid5))
	//_cValid5 := str(_cValid5)
	_cValid5 := '76'+AllTrim(Iif(Len(AllTrim(str(int(abs(_cValid5)))))<6,str(int(abs(_cValid5))),Substr(AllTrim(str(int(abs(_cValid5)))),1,6)))
	If ALLTRIM(UPPER(cNom_Lib)) = Upper(U_DipUsr())
		_cSenha := ALLTRIM(_cValid5)
	EndIf
	
	// Luciana  85 'U'
	_cValid6 := 0
	_cValid6 := (_cValPed/val(SUBSTR(DTOC(DDATABASE),4,2))+4)*16 // _cValPed/8*16
	_cValid6 := '85'+AllTRim(Iif(Len(AllTrim(str(int(abs(_cValid6)))))<6,str(int(abs(_cValid6))),Substr(AllTrim(str(int(abs(_cValid6)))),1,6)))
	If ALLTRIM(UPPER(cNom_Lib)) = 'LUCIANA'
		_cSenha := ALLTRIM(_cValid6)
	EndIf
	// Elenice 78 'N'
	_cValid7 := 0
	_cValid7 := (_cValPed/val(SUBSTR(DTOC(DDATABASE),4,2))+8)*18 //  _cValPed/9*18
	_cValid7 := '78'+AllTrim(Iif(Len(AllTrim(str(int(abs(_cValid7)))))<6,str(int(abs(_cValid7))),Substr(AllTrim(str(int(abs(_cValid7)))),1,6)))
	If ALLTRIM(UPPER(cNom_Lib)) = 'ELENICE'
		_cSenha := ALLTRIM(_cValid7)
	EndIf
	// BETE 66 'B'
	_cValid8 := 0
	_cValid8 := _cValPed/val(SUBSTR(DTOC(DDATABASE),1,2))*95 //83 // * 250
	_cValid8 := '66'+AllTrim(Iif(Len(AllTrim(str(int(abs(_cValid8)))))<6,str(int(abs(_cValid8))),Substr(AllTrim(str(int(abs(_cValid8)))),1,6)))
	If ALLTRIM(UPPER(cNom_Lib)) = 'BETE'
		_cSenha := ALLTRIM(_cValid8)
	EndIf
	
	// Paula 96 '`'
	_cValid9 := 0
	_cValid9 := _cValPed/val(SUBSTR(DTOC(DDATABASE),1,2))*350
	_cValid9 := '96'+AllTrim(Iif(Len(AllTrim(str(int(abs(_cValid9)))))<6,str(int(abs(_cValid9))),Substr(AllTrim(str(int(abs(_cValid9)))),1,6)))
	If ALLTRIM(UPPER(cNom_Lib)) = 'PAULA'
		_cSenha := ALLTRIM(_cValid9)
	EndIf
	
	// Daniela 68 'D'
	_cValid0 := 0
	_cValid0 := _cValPed/val(SUBSTR(DTOC(DDATABASE),1,2))*103
	_cValid0 := '68'+AllTrim(Iif(Len(AllTrim(str(int(abs(_cValid0)))))<6,str(int(abs(_cValid0))),Substr(AllTrim(str(int(abs(_cValid0)))),1,6)))
	If ALLTRIM(UPPER(cNom_Lib)) = 'DANIELA'
		_cSenha := ALLTRIM(_cValid0)
	EndIf
	
	IF ALLTRIM(_cSenha) == ALLTRIM(_cValid1)
		_lSaida := .T.
		_lRet   := .T.
		//	Close(oDlg)
		If "TMK"$FunName()
			M->UA_SENHMAR := "ERICH"
		Else
			M->C5_SENHMAR := "ERICH"
		EndIf
	ElseIf ALLTRIM(_cSenha) == ALLTRIM(_cValid2)
		_lSaida := .T.
		_lRet   := .T.
		//	Close(oDlg)
		If "TMK"$FunName()
			M->UA_SENHMAR := "PATRICIA"
		Else
			M->C5_SENHMAR := "PATRICIA"
		EndIf
	ElseIf ALLTRIM(_cSenha) == ALLTRIM(_cValid3)
		_lSaida := .T.
		_lRet   := .T.
		//	Close(oDlg)
		If "TMK"$FunName()
			M->UA_SENHMAR := "ANDREIA"
		Else
			M->C5_SENHMAR := "ANDREIA"
		EndIf
	ElseIf ALLTRIM(_cSenha) == ALLTRIM(_cValid4)
		_lSaida := .T.
		_lRet   := .T.
		//	Close(oDlg)
		If "TMK"$FunName()
			M->C5_SENHMAR := "FERNANDA"
		Else
			M->C5_SENHMAR := "FERNANDA"
		EndIf
	ElseIf ALLTRIM(_cSenha) == ALLTRIM(_cValid5)
		_lSaida := .T.
		_lRet   := .T.
		//	Close(oDlg)
		If "TMK"$FunName()
			M->UA_SENHMAR := Upper(U_DipUsr())
		Else
			M->C5_SENHMAR := Upper(U_DipUsr())
		EndIf
	ElseIf ALLTRIM(_cSenha) == ALLTRIM(_cValid6)
		_lSaida := .T.
		_lRet   := .T.
		//	Close(oDlg)
		If "TMK"$FunName()
			M->UA_SENHMAR := "LUCIANA"
		Else
			M->C5_SENHMAR := "LUCIANA"
		EndIf
	ElseIf ALLTRIM(_cSenha) == ALLTRIM(_cValid7)
		_lSaida := .T.
		_lRet   := .T.
		//	Close(oDlg)
		If "TMK"$FunName()
			M->UA_SENHMAR := "ELENICE"
		Else
			M->C5_SENHMAR := "ELENICE"
		EndIf
	ElseIf ALLTRIM(_cSenha) == ALLTRIM(_cValid8)
		_lSaida := .T.
		_lRet   := .T.
		//	Close(oDlg)
		If "TMK"$FunName()
			M->UA_SENHMAR := "BETE"
		Else
			M->C5_SENHMAR := "BETE"
		EndIf
	ElseIf ALLTRIM(_cSenha) == ALLTRIM(_cValid9)
		_lSaida := .T.
		_lRet   := .T.
		//	Close(oDlg)
		If "TMK"$FunName()
			M->UA_SENHMAR := "PAULA"
		Else
			M->C5_SENHMAR := "PAULA"
		EndIf
	ElseIf ALLTRIM(_cSenha) == ALLTRIM(_cValid0)
		_lSaida := .T.
		_lRet   := .T.
		//	Close(oDlg)
		If "TMK"$FunName()
			M->UA_SENHMAR := "DANIELA"
		Else
			M->C5_SENHMAR := "DANIELA"
		EndIf
	ELSE
		MsgBox("Senha Invalida !!! ","Atencao ","ALERT")
		//MsgBox("Senha Invalida !!! "+_cvalid1,"Atencao "+str(_cValPed)+'  '+SUBSTR(DTOC(DDATABASE),1,2)+'   '+SUBSTR(DTOC(DDATABASE),4,2),"ALERT")
	EndIF
	
Else
	
	// Chama validação para senha informada pelo Eriberto.
	EESenha(_cSenha,_cFunc)
	
EndIf

If _lSaida .AND. _lRet
	
	If substr(M->C5_XRECOLH,1,3) $ "ACR/REC/ISE"
		M->C5_EXPLSEN :=   alltrim(	M->C5_EXPLSEN)+"ICMS Liberado por:("+alltrim(M->C5_SENHMAR)+")."
		M->C5_XRECOLH :=   alltrim(M->C5_XRECOLH) +" - "+alltrim(M->C5_SENHMAR)
	EndIf
	//	PegaExplSen(_cSenha)
EndIf

Return (.t.)




/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³ SENHAOK7 ºAutor  ³   Giovani Zago     º Data ³  17/08/2011 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Confirma senha informada. - PARA LOTE                      º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function SenhaOk7(_cSenha,_nMargAtuPed,_cValPed,_cFunc)

//Verifica se senha digitada foi fornecida por Eriberto
If !Upper(SubStr(_cSenha,1,1)) $ "ABEFLMNPUX"// 'EeAaPp'
	
	// Erich  69 'E'
	_cValid1 := 0
	_cValid1 := _cValPed/val(SUBSTR(DTOC(DDATABASE),1,2))*val(SUBSTR(DTOC(DDATABASE),4,2))
	//_cValid1 := int(abs(_cValid1))
	_cValid1 := '69'+AllTrim(Iif(Len(AllTrim(str(int(abs(_cValid1)))))<6,str(int(abs(_cValid1))),Substr(AllTrim(str(int(abs(_cValid1)))),1,6)))
	If ALLTRIM(UPPER(cNom_Lib)) = 'ERICH'
		_cSenha := ALLTRIM(_cValid1)
	EndIf
	
	// Patricia  80 'P'
	_cValid2 := 0
	_cValid2 := _cValPed/val(SUBSTR(DTOC(DDATABASE),1,2))*150
	_cValid2 := '80'+AllTrim(Iif(Len(AllTrim(str(int(abs(_cValid2)))))<6,str(int(abs(_cValid2))),Substr(AllTrim(str(int(abs(_cValid2)))),1,6)))
	If ALLTRIM(UPPER(cNom_Lib)) = 'PATRICIA'
		_cSenha := ALLTRIM(_cValid2)
	EndIf
	
	// Andreia  65 'A'
	_cValid3 := 0
	_cValid3 := _cValPed/val(SUBSTR(DTOC(DDATABASE),4,2))*17
	//_cValid3 := int(abs(_cValid3))
	//_cValid3 := str(_cValid3)
	_cValid3 := '65'+AllTrim(Iif(Len(AllTrim(str(int(abs(_cValid3)))))<6,str(int(abs(_cValid3))),Substr(AllTrim(str(int(abs(_cValid3)))),1,6)))
	If ALLTRIM(UPPER(cNom_Lib)) = 'ANDREIA'
		_cSenha := ALLTRIM(_cValid3)
	EndIf
	
	
	// Fernanda 70 'F'
	_cValid4 := 0
	_cValid4 := _cValPed/3*19
	//_cValid4 := int(abs(_cValid4))
	//_cValid4 := str(_cValid4)
	_cValid4 := '70'+AllTrim(Iif(Len(AllTrim(str(int(abs(_cValid4)))))<6,str(int(abs(_cValid4))),Substr(AllTrim(str(int(abs(_cValid4)))),1,6)))
	If ALLTRIM(UPPER(cNom_Lib)) = 'FERNANDA'
		_cSenha := ALLTRIM(_cValid4)
	EndIf
	
	// Licitação 76 'L'
	_cValid5 := 0
	_cValid5 := _cValPed/4*val(SUBSTR(DTOC(DDATABASE),1,2))/5 //_cValPed/7*5
	//_cValid5 := int(abs(_cValid5))
	//_cValid5 := str(_cValid5)
	_cValid5 := '76'+AllTrim(Iif(Len(AllTrim(str(int(abs(_cValid5)))))<6,str(int(abs(_cValid5))),Substr(AllTrim(str(int(abs(_cValid5)))),1,6)))
	If ALLTRIM(UPPER(cNom_Lib)) = Upper(U_DipUsr())
		_cSenha := ALLTRIM(_cValid5)
	EndIf
	
	// Luciana  85 'U'
	_cValid6 := 0
	_cValid6 := (_cValPed/val(SUBSTR(DTOC(DDATABASE),4,2))+4)*16 // _cValPed/8*16
	_cValid6 := '85'+AllTRim(Iif(Len(AllTrim(str(int(abs(_cValid6)))))<6,str(int(abs(_cValid6))),Substr(AllTrim(str(int(abs(_cValid6)))),1,6)))
	If ALLTRIM(UPPER(cNom_Lib)) = 'LUCIANA'
		_cSenha := ALLTRIM(_cValid6)
	EndIf
	// Elenice 78 'N'
	_cValid7 := 0
	_cValid7 := (_cValPed/val(SUBSTR(DTOC(DDATABASE),4,2))+8)*18 //  _cValPed/9*18
	_cValid7 := '78'+AllTrim(Iif(Len(AllTrim(str(int(abs(_cValid7)))))<6,str(int(abs(_cValid7))),Substr(AllTrim(str(int(abs(_cValid7)))),1,6)))
	If ALLTRIM(UPPER(cNom_Lib)) = 'ELENICE'
		_cSenha := ALLTRIM(_cValid7)
	EndIf
	// BETE 66 'B'
	_cValid8 := 0
	_cValid8 := _cValPed/val(SUBSTR(DTOC(DDATABASE),1,2))*95 //83 // * 250
	_cValid8 := '66'+AllTrim(Iif(Len(AllTrim(str(int(abs(_cValid8)))))<6,str(int(abs(_cValid8))),Substr(AllTrim(str(int(abs(_cValid8)))),1,6)))
	If ALLTRIM(UPPER(cNom_Lib)) = 'BETE'
		_cSenha := ALLTRIM(_cValid8)
	EndIf
	
	// Paula 96 '`'
	_cValid9 := 0
	_cValid9 := _cValPed/val(SUBSTR(DTOC(DDATABASE),1,2))*350
	_cValid9 := '96'+AllTrim(Iif(Len(AllTrim(str(int(abs(_cValid9)))))<6,str(int(abs(_cValid9))),Substr(AllTrim(str(int(abs(_cValid9)))),1,6)))
	If ALLTRIM(UPPER(cNom_Lib)) = 'PAULA'
		_cSenha := ALLTRIM(_cValid9)
	EndIf
	
	// Daniela 68 'D'
	_cValid0 := 0
	_cValid0 := _cValPed/val(SUBSTR(DTOC(DDATABASE),1,2))*103
	_cValid0 := '68'+AllTrim(Iif(Len(AllTrim(str(int(abs(_cValid0)))))<6,str(int(abs(_cValid0))),Substr(AllTrim(str(int(abs(_cValid0)))),1,6)))
	If ALLTRIM(UPPER(cNom_Lib)) = 'DANIELA'
		_cSenha := ALLTRIM(_cValid0)
	EndIf
	
	IF ALLTRIM(_cSenha) == ALLTRIM(_cValid1)
		_lSaida := .T.
		_lRet   := .T.
		//	Close(oDlg)
		If "TMK"$FunName()
			M->UA_SENHMAR := "ERICH"
		Else
			M->C5_SENHMAR := "ERICH"
		EndIf
	ElseIf ALLTRIM(_cSenha) == ALLTRIM(_cValid2)
		_lSaida := .T.
		_lRet   := .T.
		//	Close(oDlg)
		If "TMK"$FunName()
			M->UA_SENHMAR := "PATRICIA"
		Else
			M->C5_SENHMAR := "PATRICIA"
		EndIf
	ElseIf ALLTRIM(_cSenha) == ALLTRIM(_cValid3)
		_lSaida := .T.
		_lRet   := .T.
		//	Close(oDlg)
		If "TMK"$FunName()
			M->UA_SENHMAR := "ANDREIA"
		Else
			M->C5_SENHMAR := "ANDREIA"
		EndIf
	ElseIf ALLTRIM(_cSenha) == ALLTRIM(_cValid4)
		_lSaida := .T.
		_lRet   := .T.
		//	Close(oDlg)
		If "TMK"$FunName()
			M->C5_SENHMAR := "FERNANDA"
		Else
			M->C5_SENHMAR := "FERNANDA"
		EndIf
	ElseIf ALLTRIM(_cSenha) == ALLTRIM(_cValid5)
		_lSaida := .T.
		_lRet   := .T.
		//	Close(oDlg)
		If "TMK"$FunName()
			M->UA_SENHMAR := Upper(U_DipUsr())
		Else
			M->C5_SENHMAR := Upper(U_DipUsr())
		EndIf
	ElseIf ALLTRIM(_cSenha) == ALLTRIM(_cValid6)
		_lSaida := .T.
		_lRet   := .T.
		//	Close(oDlg)
		If "TMK"$FunName()
			M->UA_SENHMAR := "LUCIANA"
		Else
			M->C5_SENHMAR := "LUCIANA"
		EndIf
	ElseIf ALLTRIM(_cSenha) == ALLTRIM(_cValid7)
		_lSaida := .T.
		_lRet   := .T.
		//	Close(oDlg)
		If "TMK"$FunName()
			M->UA_SENHMAR := "ELENICE"
		Else
			M->C5_SENHMAR := "ELENICE"
		EndIf
	ElseIf ALLTRIM(_cSenha) == ALLTRIM(_cValid8)
		_lSaida := .T.
		_lRet   := .T.
		//	Close(oDlg)
		If "TMK"$FunName()
			M->UA_SENHMAR := "BETE"
		Else
			M->C5_SENHMAR := "BETE"
		EndIf
	ElseIf ALLTRIM(_cSenha) == ALLTRIM(_cValid9)
		_lSaida := .T.
		_lRet   := .T.
		//	Close(oDlg)
		If "TMK"$FunName()
			M->UA_SENHMAR := "PAULA"
		Else
			M->C5_SENHMAR := "PAULA"
		EndIf
	ElseIf ALLTRIM(_cSenha) == ALLTRIM(_cValid0)
		_lSaida := .T.
		_lRet   := .T.
		//	Close(oDlg)
		If "TMK"$FunName()
			M->UA_SENHMAR := "DANIELA"
		Else
			M->C5_SENHMAR := "DANIELA"
		EndIf
	ELSE
		MsgBox("Senha Invalida !!! ","Atencao ","ALERT")
		//MsgBox("Senha Invalida !!! "+_cvalid1,"Atencao "+str(_cValPed)+'  '+SUBSTR(DTOC(DDATABASE),1,2)+'   '+SUBSTR(DTOC(DDATABASE),4,2),"ALERT")
	EndIF
	
Else
	
	// Chama validação para senha informada pelo Eriberto.
	EESenha(_cSenha,_cFunc)
	
EndIf

Return (.t.)
//************************************************************************************
//giovani 09/08/11
User function SENHAMAIL()

cValSenha := cSenmail

Return(cValSenha)


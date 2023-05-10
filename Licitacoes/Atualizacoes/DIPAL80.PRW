#Include "PROTHEUS.CH"
#Include "RWMAKE.CH"
#DEFINE CR    chr(13)+chr(10)
#DEFINE	_UA9	1
#DEFINE	_UA8	2

*--------------------------------------------*
User Function DIPAL80(cAlias,nReg,nOpcx)
*--------------------------------------------*
Local oDlg
Local aTitles   := {"Produtos"}
Local aArea 	:= GetArea()
Local cCadastro := "Entrada de Empenho"
Local aObjects  := {}
Local aSize     := MsAdvSize(.T.)
Local nCntFor	:= 1
Local nCntFor2	:= 1
Local nWndAlt	:= 0
Local nWndLar	:= 0
Local aButtons  := {}
Local cAux		:=	""

// campos que serao mostrados UA1,UA2,UA3,UA4
Local aUsed		:= {{},; //UA4
                    {}}  //UA1
Local nOpcA		:= 0
Local nOpt		:= GD_UPDATE
Local nOpcao    := 0
//Tab atual
private nTabPos	:= 1
private aGETS   := {}
private aTELA   := {}
private oGetDados
private aHeader	:= {}
private aCols	:= {}
private cPerg   := "DPAL80" 
//private	lFinAcerto := .F.  //MCVN - 12/03/2009

U_DIPPROC(ProcName(0),U_DipUsr()) // MCVN 22/01/2009

AjustaSX1(cPerg)

If Pergunte(cPerg,.T.)

	Begin Sequence
    
   /*	If Upper(U_DipUsr()) $ 'ERIBERTO/MAXIMO/CLEIA' 
  		If UA1->UA1_ACERTO <> 'S'
			If MsgYesNo("Acerto de EDITAL ?","Aten‡„o")
				RecLock("UA1",.F.)
				UA1->UA1_ACERTO := 'S'
				UA1->( MsUnLock()  ) 
			Endif	
		Else     
			If !(MsgYesNo("Este edital está marcado como acerto!! Confirma?","Aten‡„o"))
				RecLock("UA1",.F.)
				UA1->UA1_ACERTO := ''
				UA1->( MsUnLock()  ) 		
			Endif
		Endif
	EndiF    */
	
  //	If UA1->UA1_ACERTO <> 'S'
		If UA8->(dbSeek(xFilial("UA8")+UA1->UA1_CODIGO+MV_PAR01)).and.!Empty(UA8->UA8_PEDIDO)
			MsgInfo("Este empenho já gerou o pedido de vendas "+AllTrim(UA8->UA8_PEDIDO)+". Para alterá-lo estorne o pedido.","ATENÇÃO")
			Break
		EndIf
	    
	    // Validando cliente na chamada da rotina de empenho - MCVN 20/08/10
		M->UA8_CODCL := UA1->UA1_CODCLI  
		M->UA8_LOJA  := UA1->UA1_LOJA
		If !U_DIPV002("UA8CLIENTE" )                 
			Break
		Endif

		If UA1->UA1_STATUS == "8"
			MsgInfo("Este Edital já foi concluido. Para alterá-lo estorne o(s) pedido(s).","ATENÇÃO")
			Break
		EndIf  
		
 //	Endif
	
	RegToMemory(cAlias,.F.)
	RegToMemory("UA8",.F.)
	
	nWndLar := (aSize[5]  - (aSize[5] * 0.00)) - (aSize[5] / 6)
	nWndLar /= 2
	nWndAlt := (aSize[6]  - aSize[7]) / 2
	
	aAdd( aObjects, { nWndLar - 3 , (nWndAlt  / 2) - (nWndAlt * 0.00) ,.F.,.F. } )
	aAdd( aObjects, { nWndLar , nWndAlt - aObjects[1,2] , .F.,.F. } )
	aInfo := { aSize[1],aSize[2],aSize[3],aSize[4], 3, 3 }
	aPosObj  := MsObjSize( aInfo, aObjects,.T. )
	
	AADD(aUsed[_UA8],"UA8_DATA")
	AADD(aUsed[_UA8],"UA8_DTENTR")
	AADD(aUsed[_UA8],"UA8_PEDIDO")
	AADD(aUsed[_UA8],"UA8_NOTA")
	AADD(aUsed[_UA8],"UA8_CODCL")
	AADD(aUsed[_UA8],"UA8_LOJA")
	AADD(aUsed[_UA8],"UA8_CGC")
	AADD(aUsed[_UA8],"UA8_LOJA")
	AADD(aUsed[_UA8],"UA8_NRCON")
	AADD(aUsed[_UA8],"UA8_DENCE")
	AADD(aUsed[_UA8],"UA8_HENCE")
	AADD(aUsed[_UA8],"UA8_DABER")
	AADD(aUsed[_UA8],"UA8_HABER")
	AADD(aUsed[_UA8],"UA8_DVALI")
	AADD(aUsed[_UA8],"UA8_DPROP")
	AADD(aUsed[_UA8],"UA8_PROCE")
	AADD(aUsed[_UA8],"UA8_CONDP")
	
	M->UA8_FILIAL:= xFilial("UA8")
	M->UA8_EDITAL:= UA1->UA1_CODIGO
	M->UA8_EMPENH:= MV_PAR01 // If(UA8->(!EOF()).and.!Empty(UA8->UA8_EMPENH),UA8->UA8_EMPENH,CriaVar("UA8_EMPENH",.T.))
	M->UA8_DATA  := MV_PAR02 // If(UA8->(!EOF()).and.!Empty(UA8->UA8_DATA)  ,UA8->UA8_DATA  ,dDataBase)
	M->UA8_PEDIDO:= If(UA8->(!EOF()).and.!Empty(UA8->UA8_PEDIDO),UA8->UA8_PEDIDO,CriaVar("UA8_PEDIDO",.T.))
	M->UA8_NOTA  := If(UA8->(!EOF()).and.!Empty(UA8->UA8_NOTA)  ,UA8->UA8_NOTA  ,CriaVar("UA8_NOTA",.T.))
	
	M->UA8_CODCL := UA1->UA1_CODCLI
	M->UA8_LOJA  := UA1->UA1_LOJA
	M->UA8_CGC   := UA1->UA1_CGC
	M->UA8_LOJA  := UA1->UA1_LOJA
	M->UA8_NRCON := UA1->UA1_NRCONC
	M->UA8_DENCE := UA1->UA1_DENCER
	M->UA8_HENCE := UA1->UA1_HENCER
	M->UA8_DABER := UA1->UA1_DABERT
	M->UA8_HABER := UA1->UA1_HABERT
	M->UA8_DVALI := UA1->UA1_DVALID
	M->UA8_DPROP := UA1->UA1_DPROPO
	M->UA8_PROCE := UA1->UA1_PROCES
	M->UA8_CONDP := UA1->UA1_CONDPA
	M->UA8_ORGAO := If(!Empty(UA1->UA1_ORGM),MSMM(UA1->UA1_ORGM,,,,3),space(1000))
	
	aHeader 	 := apBuildHeader("UA9",{"UA9_EDITAL"})
	
	UA4->( dbSetOrder(1) )
	UA4->( dbSeek(xFilial("UA4") + UA1->UA1_CODIGO) )
	
	Do While UA4->(!EOF()) .And.;
		UA4->UA4_FILIAL == xFilial("UA4") .And.;
		UA4->UA4_EDITAL == UA1->UA1_CODIGO
		
		If UA4->UA4_VENCEU == "1"
			
			AADD(aCols,Array(Len(aHeader)+1))
			
			For nCntFor2 := 1 To Len(aHeader)
				If ( aHeader[nCntFor2][10] != "V" )
					If UA4->(FieldPos( StrTran (aHeader[nCntFor2][2],"UA9","UA4") ) ) > 0
						aCols[Len(aCols)][nCntFor2] := UA4->(FieldGet(FieldPos(StrTran(aHeader[nCntFor2][2],"UA9","UA4"))))
					EndIf
				Else
					aCols[Len(aCols)][nCntFor2] := CriaVar(aHeader[nCntFor2][2])
				EndIf
			Next nCntFor2
			
			If UA9->(dbSeek(xfilial("UA9")+UA1->UA1_CODIGO+UA4->UA4_ITEM+MV_PAR01))
				aCols[Len(aCols)][12] := UA9->UA9_QTDEMP
			Else
				aCols[Len(aCols)][12] := 0.00
			EndIf
			
			aCols[Len(aCols)][Len(aHeader)+1] := .F.
			
		EndIf
		
		UA4->( dbSkip() )
		
	EndDo
	
	define msdialog odlg title ccadastro from asize[7], asize[5] / 6 to asize[6] - 25, asize[5] of omainwnd pixel
	EnChoice( "UA8" ,nReg, nOpcx, , , , aUsed[_UA8], aPosObj[1], If(Empty(UA8_PEDIDO),{"UA8_DATA","UA8_DTENTR","UA8_CODCL"},{}),3)
	
	aPos:={aPosObj[2,1], aPosObj[2,2],nWndAlt-14,aPosObj[2,4]-3 } //- (aObjects[1,2] / 2) - (nWndAlt * 0.00), aPosObj[2,4] - 3}
	
oGetDados := MSNewGetDados():New(aPos[1], aPos[2],aPos[3],aPos[4],If(nOpcx != 2, GD_UPDATE+GD_DELETE, 0),,,,{"UA9_QTDEMP","UA9_PROD01","UA9_PROD02","UA9_PROD03","UA9_PROD04","UA9_PROD05","UA9_PROD06","UA9_PRODPV"},,,,,,oDlg, aHeader, aCols)
	
	ACTIVATE MSDIALOG oDlg CENTERED ON INIT (u_DIP80TG(), ;
	EnchoiceBar(oDlg, {||nOpcA:=If(Obrigatorio(aGets,aTela), 1,0),If(nOpcA==1,(nOpcao:=1,oDlg:End()),Nil)},{||(nOpcao:=0,oDlg:End())},,@aButtons))
	
	If ( nOpcx != 2 .And. nOpcA == 1 .and. nOpcao ==1)
		aCols := aClone(oGetDados:aCols)
		u_DIP80Grv(nOpcx)
		
	  //	If UA1->UA1_ACERTO <> "S"  // MCVN - 12/03/09
	   //		Aviso("Atencao","O sistema vai gerar o pedido de venda!",{"Ok"} )     //giovani 27/07/11
	 //		Processa( { | lEnd | U_050PED(MV_PAR01) },  'Gerando Pedidos de Vendas', 'Aguarde...', .F. ) //giovani 27/07/11
	   //	Else  // Acerto MCVN - 12/03/09
	  //		While 	!lFinAcerto
	   //			AcertoEdital()
	   //		Enddo			
	   //	Endif
	EndIf

	End Sequence

EndIf
RestArea(aArea)
Return(.T.)

*-----------------------------------------------------*
User Function DIPAL80VLD(cCampo)
*-----------------------------------------------------*
Local lRetorno := .t.
Local nSaldo   := oGetDados:aCols[oGetDados:nAt][14] 
Local lValSaldo 
U_DIPPROC(ProcName(0),U_DipUsr()) // MCVN 22/01/2009
Do Case
	Case cCampo == "QTDEMP"
		If UA9->( dbSeek(xFilial("UA9") + UA1->UA1_CODIGO + oGetDados:aCols[oGetDados:nAt][1] + MV_PAR01) )
			nSaldo += UA9->UA9_QTDEMP
		EndIf
		If M->UA9_QTDEMP > nSaldo 
		   MsgBox("Quantidade de empenho maior que o saldo!!! "+CR+CR+"Cadastre saldo adicional para"+CR+"liberar a quantidade desejada!!!! ","Atencao","OK")
		   // lValSaldo := MsgBox("Quantidade empenhado maior que o saldo! Deseja realmente empenhar essa quantidade?","Atencao","YESNO")
       
          //	IF lValSaldo = .T.
           //    lRetorno := .t. 
		   // Else 
     	   //	   lRetorno := .f.
     	   //	Endif
     	lRetorno := .f.	   
		EndIf
Endcase
Return(lRetorno)

*-----------------------------------------------------*
User Function DIP80Grv(nOpc)
*-----------------------------------------------------*
Local aArea     := GetArea()
Local nCntFor   := 0
Local nCntFor2  := 0
Local nUsado    := 0
Local aRegs 	:= { }
Local lConcluiu := .t.
Local lGravouUA9:= .f.
Local cGeraPedi := ".T."


UA4->( dbSetOrder(1) )
UA4->( dbSeek(xFilial("UA4") + UA1->UA1_CODIGO) )

Begin Transaction
id := 1
IdUA9 := 1 

Do While UA4->(!EOF()) .And.;
	UA4->UA4_FILIAL == xFilial("UA4") .And.;
	UA4->UA4_EDITAL == UA1->UA1_CODIGO
	
//	If UA4->UA4_VENCEU != "2" .and. aCols[,4] > 0
    If UA4->UA4_VENCEU == "1" 
    	If aCols[idUA9,11] > 0  //giovani Zago 03/10/2011 
			UA4->(RecLock("UA4",.f.))
		
			If UA9->(dbSeek(xfilial("UA9")+UA1->UA1_CODIGO+UA4->UA4_ITEM+MV_PAR01))
			
				UA4->UA4_QTDENT := UA4->UA4_QTDENT - UA9->UA9_QTDEMP
				UA4->UA4_SALDO  := (UA4->UA4_QUANT+UA4->UA4_XSALAD)-UA4->UA4_QTDENT//UA4->UA4_SALDO + UA9->UA9_QTDEMP
		    	UA9->UA9_QTDENT := UA4->UA4_QTDENT
            	UA9->UA9_SALDO  := UA4->UA4_SALDO
              
				UA9->(RecLock("UA9",.f.))

			Else

				UA9->(RecLock("UA9",.t.))
				UA9->UA9_FILIAl := xFilial("UA9")
				UA9->UA9_EDITAL := UA1->UA1_CODIGO
				UA9->UA9_EMPENH := MV_PAR01
            	//UA9->UA9_QTDENT := UA4->UA4_QTDENT
            	//UA9->UA9_SALDO  := UA4->UA4_SALDO
			EndIf
		
			For nCntFor2 := 1 To Len(aHeader)
				If aHeader[nCntFor2][10] != "V"
					UA9->(FieldPut(FieldPos(aHeader[nCntFor2][2]),aCols[idUA9][nCntFor2]))
				EndIf
			Next nCntFor2
		
			UA4->UA4_QTDENT := UA4->UA4_QTDENT + UA9->UA9_QTDEMP
		   	UA4->UA4_SALDO  := (UA4->UA4_QUANT+UA4->UA4_XSALAD)-UA4->UA4_QTDENT//UA4->UA4_SALDO  - UA9->UA9_QTDEMP
        	UA9->UA9_QTDENT := UA4->UA4_QTDENT
	        UA9->UA9_SALDO  := UA4->UA4_SALDO
		
			UA9->(msUnlock("UA9"))
			UA4->(msUnlock("UA4"))
		
			lGravouUA9 := .t.
		
			If (UA4->UA4_QUANT + UA4->UA4_XSALAD)  =  UA4->UA4_QTDENT//UA4->UA4_SALDO > 0 
	    	    lConcluiu := .f.
		    EndIf            
	
		Endif
			IdUA9++ 
	EndIf

	//	If UA4->UA4_VENCEU != "2" .and. UA4->UA4_SALDO > 0      alert(ctod("04/08/12") - ddatabase)                                                                                             
		If UA4->UA4_VENCEU == "1" .and. UA4->UA4_QUANT + UA4->UA4_XSALAD  =  UA4->UA4_QTDENT  //alterar aqui para validar prorrogação do edital giovani 08/08/11
        	lConcluiu := .f.
	    EndIf   
	
		UA4->( dbSkip() )
		id++
	
EndDo

If lGravouUA9
	
	If UA8->(dbSeek(xFilial("UA8")+UA1->UA1_CODIGO+MV_PAR01))
		
		UA8->(RecLock("UA8",.f.))
		AvReplace("M","UA8")
		
	Else
		
		UA8->(RecLock("UA8",.t.))
		AvReplace("M","UA8")
		UA8->UA8_FILIAL := xFilial("UA8")
		UA8->UA8_EDITAL := UA1->UA1_CODIGO
		UA8->UA8_EMPENH := MV_PAR01
		
	EndIf
	
	UA8->(Msunlock("UA8"))
	UA8->(dbGoTop())
	
	If lConcluiu
		UA1->( RecLock("UA1", .F.) )  // Todos os produtos nas quantidades
		UA1->UA1_STATUS := "8"        // e preços contratados, foram entregues...
		UA1->( MsUnLock("UA1") )      // Coloca status do edital como concluido
	EndIf
	
EndIf
    
	Aviso("Atencao","O sistema vai gerar o pedido de venda!",{"Ok"} )     //giovani 27/07/11
	Processa( { | lEnd | cGeraPedi := U_050PED(MV_PAR01) },  'Gerando Pedidos de Vendas', 'Aguarde...', .F. ) //giovani 27/07/11
	If cGeraPedi
		ConfirmSX8()
	Else
		RollBackSX8()
	EndIf

	/*
	cGeraPedi := .T.
	   
	If cGeraPedi = ".T." //giovani 27/07/11
		ConfirmSX8() //giovani 27/07/11
	Else //giovani 27/07/11
		RollBackSX8()//giovani 27/07/11
	EndIf//giovani 27/07/11
	*/
End Transaction

RestArea(aArea)
Return( .T. )
*-----------------------------------------------*
User Function DIP80TG()
*-----------------------------------------------*
Local nHItem
Local nAItem

aHeader := oGetDados:aHeader
aCols	:= oGetDados:aCols

For nAItem := 1 to Len(aCols)
	For nHItem := 1 to Len(aHeader)
		If ExistTrigger(aHeader[nHitem][2])
			RunTrigger(2, nAItem)
		EndIF
	Next nHItem
Next nAItem
oGetDados:ForceRefresh()
Return (.T.)

*----------------------------------------*
Static Function AjustaSX1(cPerg)

Local _sAlias := Alias()
Local aRegs := {}
Local i,j
dbSelectArea("SX1")
dbSetOrder(1)   

cPerg := PADR(cPerg, Len(SX1->X1_GRUPO)," " ) // Incluido por Sandro em 18/11/09.

aAdd(aRegs,{cPerg,"01","Codigo do Empenho  ?","","","mv_ch1","C",15,0,0,"G","","mv_par01","","",""," ","","","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"02","Data do Empenho    ?","","","mv_ch2","D",08,0,0,"G","","mv_par02","","","","Z","","","","","","","","","","","","","","","","","","","","","",""})
For i:=1 to Len(aRegs)
	If !dbSeek(cPerg+aRegs[i,2])
		RecLock("SX1",.T.)
		For j:=1 to FCount()
			If j <= Len(aRegs[i])
				FieldPut(j,aRegs[i,j])
			Endif
		Next
		MsUnlock()
	Endif
Next
DbSelectArea(_sAlias)
Return
            /*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AcertoEdital() º Autor ³ Maximo       º Data ³ 12/03/2009   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ ACERTA PEDIDO EMPENHO    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ ESPECIFICO DIPROMED                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
*-------------------------------*
Static Function AcertoEdital()
*-------------------------------*
Local bOk:={|| nOpcao:=1,lSaida := .T.,oDlg:End()}
Local oDlg
Local oBt1
Local oBt2
Local nOpcao  := 0   
Local nX      := 0 
Local lSaida  := .F.         
Local cPedido := SPACE(6)
Local _xAlias := GetArea()  
Local cDiverg := "" 
Local aContaUser  := {"maximo"} //{UA1->UA1_USUDIG,U_DipUsr(),"Patricia","Helena Souza"} 

Do While !lSaida
	nOpcao := 0
	Define msDialog oDlg title OemToAnsi("Informe o Pedido de VENDA") From 09,10 TO 15,45
	@ 002,002 to 045,136 pixel
	@ 010,010 say "Pedido "   Pixel
	@ 010,060 get oPedido var cPedido Size 40,08 pixel  VALID SC5->(DbSeek(xFilial("SC5")+cPedido)) = .T.
	Define sbutton oBt1 from 030,090 type 1 action Eval(bOK) enable of oDlg
	Activate Dialog oDlg Centered                          
EndDo          
	
		  				  	    
IF SC5->(DbSeek(xFilial("SC5")+cPedido))
	If Empty(SC5->C5_EDITAL)
		If (Aviso("Atenção","O pedido de empenho "+cPedido+" foi encontrado! Confirma gravação?" ,{"Sim","Não"}) = 1)
			
			// Atualiza UA8 
			DbSelectArea("UA8")
			DbGoTop("UA8")
			UA8->(DbSeek(xFilial("UA8")+UA1_CODIGO+MV_PAR01))
	 		RecLock("UA8",.F.)	
			UA8->UA8_PEDIDO  := SC5->C5_NUM				
			UA8->( MsUnLock()  ) 
			
			RecLock("SC5",.F.)
			SC5->C5_EDITAL  := UA1->UA1_CODIGO
			SC5->C5_EMPENHO := MV_PAR01						
			SC5->(MsUnLock()) 
			If SC6->(DbSeek(xFilial("SC6")+cPedido))			  	
	  	        While SC6->C6_NUM == cPedido
				    If UA4->(DbSeek(xFilial("UA4")+UA1->UA1_CODIGO))  // Verificar - Erro no conceito			  	
						While UA4->UA4_EDITAL == UA1->UA1_CODIGO
							If UA4->UA4_PRODUT <> SC6->C6_PRODUTO
					 			cMsgDiver := "ACERTO DE EDITAL - O PRODUTO "+SC6->C6_PRODUTO+" no pedido "+SC6->C6_NUM+" não está informado no Edital! "+dtoc(date())
					 			cDiverg:=cDiverg+If(Empty(cDiverg),""," / ")+cMsgDiver
					 		Endif
					 	UA4->(dbSkip())		
			 			Enddo
			    	Endif
		    	SC6->(dbSkip())	
       		 	Enddo
			Endif					
			If (Aviso("Atenção","Existem mais pedidos para este empenho a informar ?" ,{"Sim","Não"}) = 2)			  	
			  	// Atualiza UA1
		  		RecLock("UA1",.F.)	
				UA1->UA1_PEDIDO  := SC5->C5_NUM
				UA1->UA1_NFISCA  := SC5->C5_NOTA
				UA1->UA1_SERIE   := SC5->C5_SERIE				
				UA1->( MsUnLock()  )   							
				lFinAcerto := .T.
			Endif
		Endif					
		UA1->(Reclock("UA1",.f.))				
		If Empty(cDiverg)
			MSMM(UA1->UA1_OBSMEM,60,,cDiverg,2,,,"UA1","UA1_OBSMEM")
			UA1->UA1_OBSMEM := ''
		Else
			If Empty(UA1->UA1_OBSMEM)
				MSMM(UA1->UA1_OBSMEM,60,,cDiverg,1,,,"UA1","UA1_OBSMEM")
			Else
				MSMM(UA1->UA1_OBSMEM,60,,cDiverg,4,,,"UA1","UA1_OBSMEM")
			EndIf
		EndIf	
		UA1->(MsUnlock("UA1"))  
		UA1->(DbCommit()) 	
		
		// Envia e-mail com divergência
		u_Dipal10Mail(cDiverg,aContaUser,"Licitação - Acerto de Edital [" +UA1->UA1_CODIGO+ "]  feito por "+ U_DipUsr()+".") 
	Else 
		Aviso("Atenção","Esse pedido já está com o campo de edital preenchido com o nº "+SC5->C5_EDITAL,{"OK"})
	Endif
Else
	Aviso("Atenção","Pedido não encontrado ?" ,{"OK"})
EndIf			  				  	        	

RestArea(_xAlias )	
Return()


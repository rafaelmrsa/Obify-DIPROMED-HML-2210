// PROPOSTA DE EDITAL//


#Include "MSOLE.CH"
*------------------------------------------*
User Function 070PROPOSTA()
*------------------------------------------*
Local oWord
Local cFile		:= ""
Local nA		:= 0
Local cArqDot	:= ""
Local cCaract	:= ""
Local nCol		:= 1
Local cValid	:= ""
Local cNewFile	:= ""
Local nPos		:= 0
Local cNomOrgao := Trim(MSMM(UA1->UA1_ORGM,,,,3))
Local nLinOrgao := MlCount( cNomOrgao , 60)
Local nPgUlt    := 1
Local nPgAtu    := 0
Local cDecreto  := "" 
Local cAtividade:= ""
Local aTipoEdit := RetSx3Box(Posicione("SX3",2,"UA1_TIPO","X3_CBOX"),,,14)
Local cLote     := ""
Local cUltLote  := ""
Local cNumEdit  := "" // giovani 01/08/11
Private cPathEst := "C:\WINDOWS\TEMP\" // PATH DO ARQUIVO A SER ARMAZENADO NA ESTACAO DE TRABALHO
Private aMes := {"Janeiro","Fevereiro","Março","Abril","Maio","Junho","Julho","Agosto","Setembro","Outubro","Novembro","Dezembro"}  
//Giovani Zago 05/01/12
Private dDtBloq  := GetMv("ES_DIPML70",,"01/01/2001") 
Private dDtEmiss := M->UA1_EMISSA



        
U_DIPPROC(ProcName(0),U_DipUsr()) // MCVN 22/01/2009

IF UA4->( !dbSeek(xFilial("UA4") + UA1->UA1_CODIGO))
	Alert("Edital sem nenhum produto cadastrado!")
	Return (.F.)
EndIF

IF Empty(UA1->UA1_FINANC)
	Alert("Edital ainda não avaliado pelo Departamento Financeiro!")
	Return (.F.)
EndIF

IF Empty(UA1->UA1_VENDAS)
	Alert("Edital ainda não avaliado pela Gerencia Comercial!")
	Return (.F.)
EndIF

If !Empty(cFile) .And. At(".DOT",Upper(cFile))>0
	If !MsgYESNO("Deseja utilizar o mesmo arquivo ("+cFile+") usado anteriormente?")
		cTipo :=         "Modelo Word (*.DOT)        | *.DOT | "
		cFile := cGetFile(cTipo,"Selecione o modelo do arquivo",,,.T.,GETF_ONLYSERVER ,.T.)
		If !Empty(cFile)
			Aviso("Arquivo Selecionado",cFile,{"Ok"})
		Else
			Aviso("Cancelada a Selecao!","Voce cancelou a selecao do arquivo.",{"Ok"})
			Return(.f.)
		Endif
	EndIf
Else
	cTipo := "Modelo Word (*.DOT)        | *.DOT | "
	cFile := cGetFile(cTipo ,"Selecione o modelo do arquivo",,,.T.,GETF_ONLYSERVER ,.T.)
	If !Empty(cFile)
		Aviso("Arquivo Selecionado",cFile,{"Ok"})
	Else
		Aviso("Cancelada a Selecao!","Voce cancelou a selecao do arquivo.",{"Ok"})
		Return(.f.)
	Endif
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Criando link de comunicacao com o word                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

For nA := 1  To Len(cFile)
	cCaract := SubStr(cFile,nCol,1)
	If  cCaract == "\"
		cArqDot := ""
	Else
		cArqDot += cCaract
	EndIf
	nCol := nCol + 1
Next

UA1->(dbSetOrder(1))

If UA1->(dbSeek(xFilial("UA1")+M->UA1_CODIGO))
	oWord := OLE_CreateLink('TMsOleWord')
	MontaDir(cPathEst)
	CpyS2T(cFile,cPathEst,.T.)
	//----------------------------------------------------------------------------------
	// Copia do Server para o Remote, eh necessario
	// para que o wordview e o proprio word possam preparar o arquivo para impressao e
	// ou visualizacao .... copia o DOT que esta no ROOTPATH Protheus para o PATH da
	// estacao , por exemplo C:\WORDTMP
	// Abre o arquivo e ajusta suas propriedades
	//----------------------------------------------------------------------------------
	OLE_NewFile( oWord, cPathEst+cArqDot)
	OLE_SetProperty( oWord, oleWdVisible,   .F. )
	OLE_SetProperty( oWord, oleWdPrintBack, .T. )
	For id_1 := 1 to nLinOrgao
		If Id_1 <= 5
			OLE_SetDocumentVar(oWord,"cOrgao"+StrZero(id_1,2),AllTrim(StrTran(MemoLine( cNomOrgao, 60, id_1 ),chr(13)+chr(10),"")))
		EndIf
	Next
    //	id_1 --
	Do While Id_1 <= 5
		OLE_SetDocumentVar(oWord,"cOrgao"+StrZero(id_1,2)," ")
		id_1++
	EndDo
	cTipoEdital := Upper(aTipoEdit[Val(UA1->UA1_TIPO)][3]) + "  Nº  " + AllTrim(M->UA1_NRCONC) //MCVN - 13/04/2007
	OLE_SetDocumentVar(oWord,"cDescEdital", cTipoEdital)
    OLE_SetDocumentVar(oWord,"cProcesso"  , AllTrim(M->UA1_PROCES))
    OLE_SetDocumentVar(oWord,"cRealizacao", dtoc(UA1->UA1_DABERT)+" ás " +Alltrim(UA1->UA1_HABERT))
	Id := 01
	nTotal_Proposta := 0
	nTotal_Lote := 0
	cLote := UA4->UA4_LOTE
	If Empty(cLote)  
		UA4->(dbSetOrder(2))
		UA4->( dbSeek(xFilial("UA4") + UA1->UA1_CODIGO))
	Else
		UA4->(dbSetOrder(3)) 
		UA4->( dbSeek(xFilial("UA4") + UA1->UA1_CODIGO))
	Endif	
	Do While UA4->(!EOF()).and.;
		     UA4->UA4_FILIAL == xFilial("UA1").and.;
		     UA4->UA4_EDITAL == UA1->UA1_CODIGO
		SB1->(dbSeek(xFilial("SB1") + UA4->UA4_PRODUT))
		SA2->(dbSeek(xFilial("SA2") + SB1->B1_PROC))   
		cProMem := StrTran(AllTrim(MSMM(UA4->UA4_PROMEM,,,,3)),"/13/10","")   
		
        // PROPOSTA COM ITENS QUE GANHAMOS QUANDO O PREÇÃO É ELETRÔNICO
		If UA1->UA1_TIPO == '2'  .AND. UA4->UA4_VENCEU <> '1' 
			UA4->(dbSkip())
			Loop
		EndIf
		cLote       := UA4->UA4_LOTE
		if Empty(AllTrim(cProMem))
		   cProMem := SB1->B1_DESC
		EndIf    
        If !Empty(UA4->UA4_LOTE) 
		    OLE_SetDocumentVar(oWord,"cLote" + StrZero(id,3), Alltrim(UA4->UA4_LOTE))
		Else    
		    OLE_SetDocumentVar(oWord,"cLote" + StrZero(id,3), " ")
        EndIf                                   
        If Empty(UA4->UA4_ITEMLT)
		    OLE_SetDocumentVar(oWord,"Item"    + StrZero(id,3), UA4->UA4_ITEMAM) // MCVN - 13/04/2007
		Else
		    OLE_SetDocumentVar(oWord,"Item"    + StrZero(id,3), Alltrim(UA4->UA4_LOTE)+"."+UA4->UA4_ITEMLT)
		EndIf 
		OLE_SetDocumentVar(oWord,"cQtde"        + StrZero(id,3), Alltrim(Transform(UA4->UA4_QUANT,AvSx3("UA4_QUANT",6))) ) 
		OLE_SetDocumentVar(oWord,"cUni"         + StrZero(id,3), UA4->UA4_UM )
		OLE_SetDocumentVar(oWord,"cDescri"      + StrZero(id,3), cProMem)
		OLE_SetDocumentVar(oWord,"cMarca"       + StrZero(id,3), AllTrim(SB1->B1_MARCA)+"/"+AllTrim(SB1->B1_FABRIC))      // Marca do Produto
		OLE_SetDocumentVar(oWord,"cProced"      + StrZero(id,3), AllTrim(SB1->B1_CODALF))     // Codigo Alfandegario
		OLE_SetDocumentVar(oWord,"cPUniICM"     + StrZero(id,3), "R$ "+Transform(UA4->UA4_PRCVEN/(100-SB1->B1_PICM)*100,AvSx3("UA4_PRCVEN",6)))
		OLE_SetDocumentVar(oWord,"cPrTotalICM"  + StrZero(id,3), "R$ "+Transform(UA4->UA4_QUANT*((UA4->UA4_PRCVEN/(100-SB1->B1_PICM)*100)),AvSx3("UA4_TOTAL",6)))
		OLE_SetDocumentVar(oWord,"cAliq"        + StrZero(id,3), SB1->B1_PICM)                                           
		OLE_SetDocumentVar(oWord,"cPUni"        + StrZero(id,3), "R$ "+Transform(UA4->UA4_PRCVEN,AvSx3("UA4_PRCVEN",6)))
		OLE_SetDocumentVar(oWord,"cPrTotal"     + StrZero(id,3), "R$ "+Transform(UA4->UA4_QUANT*UA4->UA4_PRCVEN,AvSx3("UA4_TOTAL",6)))
	  	OLE_SetDocumentVar(oWord,"cPreUniExten" + StrZero(id,3), U_DIPEXTENSO(UA4->UA4_PRCVEN))
		OLE_SetDocumentVar(oWord,"cPrecTotExt"  + StrZero(id,3), U_DIPEXTENSO(ROUND(UA4->UA4_QUANT*UA4->UA4_PRCVEN,2)))//Extenso(UA4->UA4_QUANT*UA4->UA4_PRCVEN,.f.,1)+Iif(UA4->UA4_QUANT*UA4->UA4_PRCVEN < 1," DE REAL",""))
		OLE_SetDocumentVar(oWord,"cValMerc"     + StrZero(id,3), "R$ "+Transform(UA4->UA4_QUANT*UA4->UA4_PRCVEN,AvSx3("UA4_TOTAL",6)))
		OLE_SetDocumentVar(oWord,"cValTotItem"  + StrZero(id,3), U_DIPEXTENSO(ROUND(UA4->UA4_QUANT*UA4->UA4_PRCVEN,2)))//Extenso(UA4->UA4_QUANT*UA4->UA4_PRCVEN,.f.,1)+Iif(UA4->UA4_QUANT*UA4->UA4_PRCVEN < 1," DE REAL",""))
        nTotal_Proposta	+= (UA4->UA4_QUANT*UA4->UA4_PRCVEN)
        nTotal_Lote     += (UA4->UA4_QUANT*UA4->UA4_PRCVEN) 
        cNumEdit := UA4->UA4_EDITAL //giovani 01/08/11  							
        //cLote := UA4->UA4_LOTE
		UA4->(dbSkip())
		
        If !Empty(UA4->UA4_LOTE) .and. cLote <> UA4->UA4_LOTE 
	 	    OLE_SetDocumentVar(oWord,"cTotalLote"  + StrZero(id,3), "VALOR TOTAL DO LOTE "+AllTrim(cLote)+Space(163)+"|R$ "+Transform(nTotal_Lote,AvSx3("UA4_TOTAL",6)))
   	 	    OLE_SetDocumentVar(oWord,"cTotExtenso" + StrZero(id,3), "VALOR TOTAL DO LOTE "+AllTrim(cLote)+" POR EXTENSO: " + "("+U_DIPEXTENSO(ROUND(nTotal_Lote,2))+")")
	        nTotal_Lote := 0
	        //cUltLote    := cLote
	        cLote       := UA4->UA4_LOTE
	    //giovani 01/08/11
	    ElseIf cLote <> UA4->UA4_LOTE  .And. UA4->UA4_EDITAL <> cNumEdit
	        OLE_SetDocumentVar(oWord,"cTotalLote"  + StrZero(id,3), "VALOR TOTAL DO LOTE "+AllTrim(cLote)+Space(163)+"|R$ "+Transform(nTotal_Lote,AvSx3("UA4_TOTAL",6)))
   	 	    OLE_SetDocumentVar(oWord,"cTotExtenso" + StrZero(id,3), "VALOR TOTAL DO LOTE "+AllTrim(cLote)+" POR EXTENSO: " +  "("+U_DIPEXTENSO(ROUND(nTotal_Lote,2))+")")
	        nTotal_Lote := 0
	        cLote       := UA4->UA4_LOTE
	     //*********************************************
	    
	    Else         
		    OLE_SetDocumentVar(oWord,"cExpressao"   + StrZero(id,3), " ")
		    cLote := UA4->UA4_LOTE
        EndIf
        
		id++
	EndDO   
	
	If !Empty(cUltLote)
		OLE_SetDocumentVar(oWord,"cTotalLote"  + StrZero(id-1,3), "VALOR TOTAL DO LOTE "+AllTrim(cLote)+Space(163)+"|R$ "+Transform(nTotal_Lote,AvSx3("UA4_TOTAL",6)))
    	OLE_SetDocumentVar(oWord,"cTotExtenso" + StrZero(id-1,3), "VALOR TOTAL DO LOTE "+AllTrim(cLote)+" POR EXTENSO: " + "("+U_DIPEXTENSO(ROUND(nTotal_Lote,2))+")")
    Endif
    	
	OLE_SetDocumentVar(oWord, 'psl_nroitens',id)
  /*	Do While id < 12
		OLE_SetDocumentVar(oWord,"cLote"        + StrZero(id,3), " ")
		OLE_SetDocumentVar(oWord,"Item"         + StrZero(id,3), " ")
		OLE_SetDocumentVar(oWord,"cQtde"        + StrZero(id,3), " ")
		OLE_SetDocumentVar(oWord,"cUni"         + StrZero(id,3), " ")
		OLE_SetDocumentVar(oWord,"cDescri"      + StrZero(id,3), " ")
		OLE_SetDocumentVar(oWord,"cMarca"       + StrZero(id,3), " ")
		OLE_SetDocumentVar(oWord,"cProced"      + StrZero(id,3), " ")
		OLE_SetDocumentVar(oWord,"cPUni"        + StrZero(id,3), " ")
		OLE_SetDocumentVar(oWord,"cPrTotal"     + StrZero(id,3), " ")
		OLE_SetDocumentVar(oWord,"cPreUniExten" + StrZero(id,3), " ")
		OLE_SetDocumentVar(oWord,"cPrecTotExt"  + StrZero(id,3), " ")
		OLE_SetDocumentVar(oWord,"cValMerc"     + StrZero(id,3), " ")
		OLE_SetDocumentVar(oWord,"cValTotItem"  + StrZero(id,3), " ")
		OLE_SetDocumentVar(oWord,"cExpressao"   + StrZero(id,3), " ")
		id++
	EndDo */
	OLE_ExecuteMacro(oWord,"pregaosemlote")

	OLE_SetDocumentVar(oWord,"cTotalEdital", +" R$ "+Transform(nTotal_Proposta,AvSx3("UA4_TOTAL",6)))
	OLE_SetDocumentVar(oWord,"cTotEditExtenso", U_DIPEXTENSO(ROUND(nTotal_Proposta,2)))                      
	
    //MCVN - 13/04/2007
	OLE_SetDocumentVar(oWord,"cValProposta", UA1_DPROPO)
	OLE_SetDocumentVar(oWord,"cPEntrega",    UA1_DENTRE)
	OLE_SetDocumentVar(oWord,"cPPagamento",  Posicione("SE4",1,xFilial("SE4")+ M->UA1_CONDPA,"E4_DESCRI"))		
    
    If  UA1->UA1_CONTRA = "1"   //MCVN - 12/06/2007
	    If(Empty(UA1_VCONT2))
			OLE_SetDocumentVar(oWord,"cValContrato",(" Até o dia"+' '+StrZero(Day(UA1_VCONTR),2)+" de " +aMes[Month(UA1_VCONTR)]+" de " +SubStr(Dtos(UA1_VCONTR),1,4)))
		ElseIf !Empty(UA1_VCONT2) .And. UA1_TPVALI = "D"
			OLE_SetDocumentVar(oWord,"cValContrato" 	,UA1_VCONT2 +' '+ "DIA(S)")
		ElseIf !Empty(UA1_VCONT2) .And. UA1_TPVALI = "M"	
			OLE_SetDocumentVar(oWord,"cValContrato" 	,UA1_VCONT2 +' '+ "MES(ES)")
		Else  	
		OLE_SetDocumentVar(oWord,"cValContrato"     	,UA1_VCONT2 +' '+ "ANO(S)")
		Endif
	Else
		OLE_SetDocumentVar(oWord,"cValContrato","")	
	Endif
	
    cDecreto := '"Declaramos expressamente que optamos a utilizar a faculdade de isenção do ICMS mediante Decreto 48034/03 - Art. 55."'	
    cAtividade := Posicione("SA1",1,xFilial("SA1")+ M->UA1_CODCLI,"A1_SATIV1")    
    If cAtividade == "1.2.02" 
		OLE_SetDocumentVar(oWord,"IsentoICMS", cDecreto)
	Else	                                            
		OLE_SetDocumentVar(oWord,"IsentoICMS", "")
	Endif			
	
	OLE_SetDocumentVar(oWord,"cDataExtenso","Osasco, " + StrZero(Day(dDataBase),2)+" de " +aMes[Month(dDataBase)]+" de " +SubStr(Dtos(dDataBase),1,4))
	OLE_UpDateFields(oWord)
	cNewFile := cGetFile(" | *.* |" , "Salvar em" ,,,.F., GETF_LOCALHARD + GETF_LOCALFLOPPY + GETF_RETDIRECTORY,.F.)
	If(Len(cNewFile) < 1)
		Alert("Nome inválido!")
		Return(.F.)
	Else
		nPos := RAT("\",cNewFile)
		cPathEst := SUBSTR(cNewFile, 1, nPos)
		cNewFile := cPathEst
	EndIf
	cNewFile := cNewFile+"Proposta_" + AllTrim(M->UA1_CODIGO) + ".doc"
	OLE_SaveAsFile(oWord,cNewFile,,,.F.,) // Salva o arquivo na estacao
	CpyT2S(cNewFile,"\word\",.T.)         // Copia o arquivo salvo na estacao para o servidor no diretorio \word\ a partir do rootpath
	OLE_CloseLink(oWord)                  // Copia do Remote para o Servidor
EndIf
Return(.T.)

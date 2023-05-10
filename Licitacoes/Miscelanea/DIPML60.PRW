#INCLUDE "protheus.ch"   
#INCLUDE "RWMAKE.CH" 
#INCLUDE "COLORS.CH"
#INCLUDE "MSOLE.CH"
#define SIM  '1'
#define NAO  '2'
#DEFINE CR    chr(13)+chr(10)
*----------------------------------------*
User Function 060PED(lRetorno)
*----------------------------------------*
Local aCabec	:= {}                                                   
Local aItens	:= {}
Local cMensagem := ""
Local nRegua	:= 0
Local i			:= 1
Local cItem		:= "00"
Local cTes		:= "" // JBS 13/06/2006
//Local cDestFrete:= Posicione("SA1",1,xFilial("SA1") + M->UA1_CODCLI + M->UA1_LOJA,"A1_EST")+"-TODAS" // JBS 05/06/2006
Local cDestFrete := U_Mt410Frete('GATILHO')
Local cQuemcon	:= U_DipUsr()
Local lFinaliza := .t.
Local aUA4_REC  := {}
Local cObsMem   := ""  
Local cMenNota  := Space(120) // MCVN - 20/06/2007
Local cMenDep   := Space(120) // MCVN - 20/06/2007      
Local cOperador := Posicione("SU7",6,xFilial("SU7")+U_DipUsr(),"U7_COD") // MCVN - 10/07/2007
Local cEstCli   := ""
Local nPicmRet  := 0 
Local cTesAmostra := ""

Private lMsHelpAuto := .T. 	// se .T. direciona as mensagens de help para o arq. de log
Private lMsErroAuto := .F. 	//necessario a criacao, pois sera atualizado quando houver erro   
Private lFinAmostra := .F.
U_DIPPROC(ProcName(0),U_DipUsr()) // MCVN 22/01/2009
IF UA4->( !dbSeek(xFilial("UA4") + UA1->UA1_CODIGO))
	Alert("Edital sem nenhum produto cadastrado!")
	Return(.F.)
EndIF

//If M->UA1_ACERTO <> "S"
	IF Empty(UA1->UA1_FINANC)
		Alert("Edital ainda não avaliado pelo Departamento Financeiro!")
		Return(.F.)
	EndIF


//  Chama Tela para incluir mensagem para Depósito e Mensagem de Depósito
	Define msDialog oDlg Title "MENSAGENS PARA NOTA FISCAL" From 10,10 TO 26,57
	
	@ 001,002 tO 120,185
	
	@ 010,010 say "Edital  " COLOR CLR_BLACK
	@ 020,010 say "Cliente " COLOR CLR_BLACK
	@ 030,010 say "Loja    " COLOR CLR_BLACK
	
	@ 010,050 get M->UA1_CODIGO  when .f. size 050,08
	@ 020,050 get M->UA1_CODCLI when .f. size 120,08
	@ 030,050 get M->UA1_LOJA  when .f. size 120,08
	
	@ 050,010 say "Informe a mensagem para Nota: "  COLOR CLR_HBLUE
	@ 060,010 get cMenNota size 165,08
	
    @ 080,010 say "Informe a mensagem para Depósito: "  COLOR CLR_HBLUE
	@ 090,010 get cMenDep  size 165,08
	
	DEFINE SBUTTON FROM 105,148 TYPE 1 ACTION (lSaida:=.T.,nOpcao:=1,oDlg:End()) ENABLE OF oDlg
//	DEFINE SBUTTON FROM 82,160 TYPE 2 ACTION (nOpcao:=0,oDlg:End()) ENABLE OF oDlg
	
	Activate dialog oDlg centered



	UA4->(dbSetOrder(1))
	UA4->(dbSeek(xFilial("UA4") + M->UA1_CODIGO ))

	Do While UA4->(!EOF()) .And. M->UA1_CODIGO = UA4->UA4_EDITAL
		nRegua ++
		UA4->(dbSkip())
	EndDo
 


	ProcRegua(nRegua)
	SA1->(dbSeek(xfilial("SA1") + M->UA1_CODCLI + M->UA1_LOJA ))

	M->C5_CLIENTE := M->UA1_CODCLI  // JBS 08/06/2006
	M->C5_LOJACLI := M->UA1_LOJA    // JBS 08/06/2006
	M->C5_OPERADO := Iif(Empty(Alltrim(cOperador)),"000095",cOperador) //MCVN 10/07/2007
	M->C5_CONDPAG := "002"//M->UA1_CONDPA  // JBS 13/06/2006    //Giovani Zago 09/09/11 
	M->C5_TRANSP  := "000000" // A TRANSPORTADORA PARA PEDIDOS DE AMOSTRA SEMPRE SERÁ 000111 - CLIENTE RETIRA REPRESENTANTE - MCVN 29/01/2007   //Giovani Zago 09/09/11
	M->C5_VEND1   := IIF(Empty(Alltrim(UA1_XVEND1)) .OR. SA1->A1_GRPVEN $ cGrpSa1 ,SA1->A1_VEND,Alltrim(UA1_XVEND1)) // MCVN 06/08/13 - Felipe Delta 04/10/19      
	M->C5_VEND2   := ""//SA1->A1_VENDKC // MCVN - 06/09/2007
	M->C5_TIPOCLI := SA1->A1_TIPO   // JBS 13/06/2006
	//M->C5_DESTFRE := SA1->A1_EST + "-TODAS" // JBS 13/06/2006
	M->C5_DESTFRE := cDestFrete
	M->C5_TPFRETE := "F" // Frete CIF   //Giovani Zago 09/09/11  
	M->C5_MENNOTA := Upper(Alltrim(cMenNota))
	M->C5_MENDEP  := Upper(Alltrim(cMenDep))      
	M->C5_TIPLIB  := "1"     
	M->C5_TIPODIP := "1"    
	M->C5_TMK     := "1"    
	cEstCli       := SA1->A1_EST


	Begin Transaction

	// Cabecalho do pedidos de venda SC5

	aCabec := {}
	aadd(aCabec,{"C5_TIPO"   , "N",			  Nil})
	aadd(aCabec,{"C5_CLIENTE", M->C5_CLIENTE, Nil})
	aadd(aCabec,{"C5_LOJACLI", M->C5_LOJACLI, Nil})
	aadd(aCabec,{"C5_OPERADO", M->C5_OPERADO, Nil})
	aadd(aCabec,{"C5_VEND1"  , M->C5_VEND1  , Nil}) 
	aadd(aCabec,{"C5_VEND2"  , M->C5_VEND2  , Nil}) // MCVN - 06/09/2007
	aadd(aCabec,{"C5_CONDPAG", M->C5_CONDPAG, Nil})
	aadd(aCabec,{"C5_TRANSP" , M->C5_TRANSP , Nil})
	aadd(aCabec,{"C5_QUEMCON", cQuemcon     , Nil})
	aadd(aCabec,{"C5_TIPOCLI", M->C5_TIPOCLI, Nil})
	aadd(aCabec,{"C5_DESTFRE", M->C5_DESTFRE, Nil})
	aadd(aCabec,{"C5_EDITAL" , M->UA1_CODIGO, Nil})
	aadd(aCabec,{"C5_TPFRETE", M->C5_TPFRETE, Nil})
	aadd(aCabec,{"C5_EMPENHO", "0", Nil})
	aadd(aCabec,{"C5_MENNOTA", M->C5_MENNOTA, Nil})
	aadd(aCabec,{"C5_MENDEP" , M->C5_MENDEP , Nil})
	aadd(aCabec,{"C5_TIPLIB" , M->C5_TIPLIB , Nil})  
	aadd(aCabec,{"C5_TIPODIP" , M->C5_TIPODIP , Nil})
	aadd(aCabec,{"C5_TMK" , M->C5_TMK , Nil})
	// Itens do pedido de vendas SC6

	UA4->(dbSetOrder(1))

	UA4->(dbSeek(xFilial("UA4") + M->UA1_CODIGO))

	Do While UA4->(!EOF()) .And. M->UA1_CODIGO = UA4->UA4_EDITAL
	
		IncProc()
			
		If UA4->UA4_QAMOST > 0  .and.; // Possui Quantidade para amostra e não 
    	   UA4->UA4_GERAMO == SIM      // Empty(UA4->UA4_PEDIDO)     // Não possui pedido de amostra gerado
			
  	        //cItem    := AllTrim(Str(i))  // Desabilitado   MCVN - 07/04/09 
			//cItem    := PadL(cItem, 02, '0') // Desabilitado item no pedido   MCVN - 07/04/09 
			
			cItem    := Soma1(cItem) // Corrigindo item no pedido   MCVN - 07/04/09 
			cTes     := Posicione("SB1",1,xFilial("SB1") + UA4->UA4_PRODUT,"B1_TS")
			nPicmRet := Posicione("SB1",1,xFilial("SB1") + UA4->UA4_PRODUT,"SB1->B1_PICMRET")  
		
			Do case
				Case cTes == "501"; cTesAmostra := If((cEstCli == "SP" .And. nPicmRet > 0),"630","505")  // Tratamento de amostra para Substituição tributária  MCVN - 30/04/2008
				Case cTes == "533"; cTesAmostra := "593"  // Quando é  ISENTO de ICMS  
			Endcase 
			
    				      
  		   
			Aadd(aItens,{;			
			{"C6_ITEM"   ,  cItem,			    Nil},; // Numero do Item
			{"C6_PRODUTO",	If(!Empty(UA4->UA4_AMOSTR),UA4->UA4_AMOSTR,UA4->UA4_PRODUT),    Nil},; // Codigo do Produto
			{"C6_QTDVEN" , 	UA4->UA4_QAMOST,	Nil},; // Quantidade Empenhada
			{"C6_PRCVEN" , 	If(UA4->UA4_PRCAMO <> 0,UA4->UA4_PRCAMO,If(UA4->UA4_PRCMIN <> 0,UA4->UA4_PRCMIN,UA4->UA4_PRCVEN)),	Nil},; // Preço Contratado
			{"C6_TES"    ,  cTesAmostra,  Nil},; // TES do Produto
			{"C6_PRUNIT" , 	If(UA4->UA4_PRCAMO <> 0,UA4->UA4_PRCAMO,If(UA4->UA4_PRCMIN <> 0,UA4->UA4_PRCMIN,UA4->UA4_PRCVEN)),	Nil},; // Preço Contratado
			{"C6_VALOR"  , 	Round(If(UA4->UA4_PRCAMO <> 0,UA4->UA4_PRCAMO,If(UA4->UA4_PRCMIN <> 0,UA4->UA4_PRCMIN,UA4->UA4_PRCVEN))*UA4->UA4_QAMOST,2),	Nil},;
			{"C6_TIPODIP", "1",	Nil}}) // Tipo do pedido 24/07/09
			aadd(aUA4_Rec,UA4->(Recno()))
			i++
		EndIf
		UA4->(dbSkip())
	EndDo

	If i > 1 // Se tiver item, entra para gravar
	
		MSExecAuto({|x,y,z| MATA410(x,y,z)},aCabec,aItens,3)
	
	//Se ocorrer erro no MSExecAuto, exibe o mesmo
	
		If lMsErroAuto
			If __lSX8
				RollBackSX8()
			EndIf
		
			cMensagem := "Nao foi possivel gerar pedido."
			Aviso("Erro!!!",cMensagem,{"Ok"},2,"Erro")
			mostraerro()
			DisarmTransaction()
			Return(.F.)
		Else
			If __lSX8
				ConfirmSX8()
			EndIf
		EndIf
	
		SC5->(dbSetOrder(3))
	
	   /*	If SC5->(dbSeek(xFilial("SC5") + M->UA1_CODCLI + M->UA1_LOJA))

		Do While !SC5->(EOF())

			If SC5->C5_EDITAL = M->UA1_CODIGO */

				cObsMem := "Gerado o Pedido de Amostra "+SC5->C5_NUM+" em "+dtoc(ddatabase)+"."+chr(13)+chr(10)
				cObsMem += AllTrim(MSMM(UA1->UA1_OBSMEM,,,,3))

				UA1->( RecLock("UA1", .F.) )
				If Empty(UA1->UA1_OBSMEM)
				    MSMM(UA1->UA1_OBSMEM,60,,cObsMem,1,,,"UA1","UA1_OBSMEM")
			    Else
				    MSMM(UA1->UA1_OBSMEM,60,,cObsMem,2,,,"UA1","UA1_OBSMEM")
			    EndIf
				UA1->( MsUnLock("UA1") )
				
				For id:=1 to len(aUA4_Rec)
				
				    UA4->( dbGoTo(aUA4_Rec[id]) )
				
				    UA4->( RecLock("UA4", .F.) )
				    UA4->UA4_PEDAMO := SC5->C5_NUM
    				UA4->( MsUnLock("UA4") )

				Next id

		/*	EndIf
			SC5->(dbSkip())
		EndDo
		EndIf */
		lRetorno := .T.
		ApMsgInfo( 'Pedido de Amostras gerado com sucesso. PEDIDO Nº '+SC5->C5_NUM+'', 'ATENÇÃO' )// MCVN - 20/06/2007
		U_DiprKardex(SC5->C5_NUM,U_DipUsr(),"AMOSTRA-EDITAL Nº "+UA1->UA1_CODIGO,.T.,"41")// MCVN - 20/06/2007
		u_UTmkR03()
	Else
		ApMsgInfo( 'Não encontrado itens para gerar o pedido de amostra.', 'ATENÇÃO' )
	EndIf

	End Transaction

	If __lSX8
		ConfirmSX8()
	EndIf
//Else 
  //  While !lFinAmostra
	//	AcertAmostra()
//	EndDo	
//EndIf
Return(.T.)
*------------------------------------------*
User Function 060CON()
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
Local cLote     := ""
Local cGrpSa1	:= GetMV("ES_GRPSA1") //FELIPE DURAN 09/10/19 - GRUPO DE CLIENTES PARA AJUSTE DO VENDEDOR

Private cPathEst := "C:\WINDOWS\TEMP\" // PATH DO ARQUIVO A SER ARMAZENADO NA ESTACAO DE TRABALHO
Private aMes := {"Janeiro","Fevereiro","Março","Abril","Maio","Junho","Julho","Agosto","Setembro","Outubro","Novembro","Dezembro"}
U_DIPPROC(ProcName(0),U_DipUsr()) // MCVN 22/01/2009
IF UA4->( !dbSeek(xFilial("UA4") + UA1->UA1_CODIGO))
	Alert("Edital sem nenhum produto cadastrado!")
	Return (.F.)
EndIF

IF Empty(UA1->UA1_FINANC)
	Alert("Edital ainda não avaliado pelo Departamento Financeiro!")
	Return (.F.)
EndIF

//IF Empty(UA1->UA1_VENDAS)
//	Alert("Edital ainda não avaliado pela Gerencia Comercial!")
//	Return (.F.)
//EndIF

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
                                                                         
//UA4->(dbSetOrder(1))  
	If Empty(UA4->UA4_LOTE)     // MCVN - 16/08/2007
		UA4->(dbSetOrder(2))
		UA4->( !dbSeek(xFilial("UA4") + UA1->UA1_CODIGO))
	Else
		UA4->(dbSetOrder(3)) 
		UA4->( !dbSeek(xFilial("UA4") + UA1->UA1_CODIGO))
	Endif	

If UA4->(dbSeek(xFilial("UA4")+M->UA1_CODIGO))
	Id := 1000
	Do While UA4->(!EOF()).and.;
		UA4->UA4_FILIAL == xFilial("UA4").and.;
		UA4->UA4_EDITAL == UA1->UA1_CODIGO
		
		If UA4->UA4_QAMOST > 0
			
			If id > 999 // Faz o cabeçario
				
			  	If nPgAtu > 0 // Faz o rodapé
					
					OLE_SetDocumentVar(oWord,"cDataExtenso","Osasco, " + StrZero(Day(dDataBase),2)+" de " +aMes[Month(dDataBase)]+" de " +SubStr(Dtos(dDataBase),1,4))
					
					OLE_SetDocumentVar(oWord,"cFolha","Folha "+AllTrim(Str(nPgAtu)))
					OLE_UpDateFields(oWord)
					
				   //	Ole_PrintFile(oWord,"ALL",,,1) // Imprime a Proposta
   					inkey(6)            
					Ole_CloseFile(oWord)
					Ole_CloseLink(oWord)
				EndIf
								
				nPgAtu++
				
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
				OLE_NewFile(oWord, cPathEst+cArqDot)
				OLE_SetProperty( oWord, oleWdVisible,   .F. )
				OLE_SetProperty( oWord, oleWdPrintBack, .T. )
				
				//	OLE_ExecuteMacro(oWord,"novo_doc")
				
				For id_1 := 1 to nLinOrgao
					If Id_1 <= 4
						OLE_SetDocumentVar(oWord,"cOrgao"+StrZero(id_1,2),AllTrim(StrTran(MemoLine( cNomOrgao, 60, id_1 ),chr(13)+chr(10),"")))
					EndIf
				Next
//				id_1 -- Acredito que esteja errado, está apagando a última linha preenchida - MCVN - 13/04/2007
				Do While Id_1 <= 4
					OLE_SetDocumentVar(oWord,"cOrgao"+StrZero(id_1,2)," ")
					id_1++
				EndDo
				
				OLE_SetDocumentVar(oWord,"cEdital"	,AllTrim(M->UA1_NRCONC))
				OLE_SetDocumentVar(oWord,"cProcesso",AllTrim(M->UA1_PROCES))
				
				Id := 01
				
			EndIf                                            
			
			SB1->(dbSeek(xFilial("SB1") + If(!Empty(UA4->UA4_AMOSTR),UA4->UA4_AMOSTR,UA4->UA4_PRODUT)))
			SA2->(dbSeek(xFilial("SA2") + SB1->B1_PROC))
			
            If Empty(cLote) .And. !(Empty(Alltrim(UA4->UA4_LOTE)))	                                                                        
	            cLote := Alltrim(UA4->UA4_LOTE)                                             
	            OLE_SetDocumentVar(oWord,"cLinha"+StrZero(id,3), "LOTE:   " + UA4->UA4_LOTE)					            							           
   				id++
				OLE_SetDocumentVar(oWord,"cLinha"+StrZero(id,3), "")				
 			Endif 
 			
	        If cLote <> Alltrim(UA4->UA4_LOTE)     	        	       			      	        
				id++
				OLE_SetDocumentVar(oWord,"cLinha"+StrZero(id,3), "LOTE:   " + UA4->UA4_LOTE)				
				cLote := Alltrim(UA4->UA4_LOTE)        								
				id++
				OLE_SetDocumentVar(oWord,"cLinha"+StrZero(id,3), "")				
			Endif
			
		    If id > 1
		   		id++
		   	Endif	
		   
		   	
		   	                                     		      										          	            
			OLE_SetDocumentVar(oWord,"cLinha"+StrZero(id,3), If((!Empty(UA4->UA4_LOTE)),UA4->UA4_ITEMLT,UA4->UA4_ITEMAM) + " - " +;
			                                                 StrZero(UA4->UA4_QAMOST,6) +" "+;
			                                                 If(!Empty(UA4->UA4_UMAMOS),UA4->UA4_UMAMOS,UA4->UA4_UM) + " - "+;
			                                                 SB1->B1_DESC)
			id++
			OLE_SetDocumentVar(oWord,"cLinha"+StrZero(id,3),"FABRICANTE: " + SA2->A2_NOME)
			id++           
			OLE_SetDocumentVar(oWord,"cLinha"+StrZero(id,3), "")
			
		EndIf
		
		UA4->(dbSkip())
		
	EndDO
	OLE_SetDocumentVar(oWord, 'amo_nroitens',id)
/* 	Do While id < 20
     	OLE_SetDocumentVar(oWord,"cLinha"+StrZero(id,1)," ")
 		id++
 		OLE_SetDocumentVar(oWord,"cLinha"+StrZero(id,1)," ")
 		id++
 	EndDo */
	OLE_ExecuteMacro(oWord,"amostra")
	OLE_SetDocumentVar(oWord,"cDataExtenso","Osasco, " + StrZero(Day(dDataBase),2)+" de " +aMes[Month(dDataBase)]+" de " +SubStr(Dtos(dDataBase),1,4))
	
	OLE_SetDocumentVar(oWord,"cFolha","Folha "+AllTrim(Str(nPgAtu)))
	OLE_UpDateFields(oWord)
	
	//Seleciona o diretorio onde sera salvo o arquivo ".DOC"
	cNewFile := cGetFile(" | *.* |" , "Salvar em" ,,,.F., GETF_LOCALHARD + GETF_LOCALFLOPPY + GETF_RETDIRECTORY,.F.)
	
	If(Len(cNewFile) < 1)
		Alert("Nome inválido!")
		Return(.F.)
	Else
		nPos := RAT("\",cNewFile)
		cPathEst := SUBSTR(cNewFile, 1, nPos)
		cNewFile := cPathEst
	EndIF
	
	cNewFile := cNewFile+"Amostra_" + AllTrim(M->UA1_CODIGO) + ".doc"
	OLE_SaveAsFile(oWord,cNewFile,,,.F.,) // Salva o arquivo na estacao
	CpyT2S(cNewFile,"\word\",.T.)         //Copia o arquivo salvo na estacao para o servidor no diretorio \word\ a partir do rootpath
	OLE_CloseLink(oWord)                  // Copia do Remote para o Servidor
	
EndIf

Return(.T.)

*------------------------------------------*
User Function 060Etiq()
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

Private cPathEst := "C:\WINDOWS\TEMP\" // PATH DO ARQUIVO A SER ARMAZENADO NA ESTACAO DE TRABALHO
Private aMes := {"Janeiro","Fevereiro","Março","Abril","Maio","Junho","Julho","Agosto","Setembro","Outubro","Novembro","Dezembro"}

IF UA4->( !dbSeek(xFilial("UA4") + UA1->UA1_CODIGO))
	Alert("Edital sem nenhum produto cadastrado!")
	Return (.F.)
EndIF

IF Empty(UA1->UA1_FINANC)
	Alert("Edital ainda não avaliado pelo Departamento Financeiro!")
	Return (.F.)
EndIF

//IF Empty(UA1->UA1_VENDAS)
//	Alert("Edital ainda não avaliado pela Gerencia Comercial!")
//	Return (.F.)
//EndIF

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
                                                                            '
UA4->(dbSetOrder(1))

If UA4->(dbSeek(xFilial("UA4")+M->UA1_CODIGO))
	Id := 1000
	Do While UA4->(!EOF()).and.;
		UA4->UA4_FILIAL == xFilial("UA4").and.;
		UA4->UA4_EDITAL == UA1->UA1_CODIGO
		
		If UA4->UA4_QAMOST > 0
			
			If id > 999 // Faz o cabeçario
				
			  	If nPgAtu > 0 // Faz o rodapé
					
					OLE_SetDocumentVar(oWord,"cDataExtenso","Osasco, " + StrZero(Day(dDataBase),2)+" de " +aMes[Month(dDataBase)]+" de " +SubStr(Dtos(dDataBase),1,4))
					
					OLE_SetDocumentVar(oWord,"cFolha","Folha "+AllTrim(Str(nPgAtu)))
					OLE_UpDateFields(oWord)
					
				   //	Ole_PrintFile(oWord,"ALL",,,1) // Imprime a Proposta
   					inkey(6)            
					Ole_CloseFile(oWord)
					Ole_CloseLink(oWord)
				EndIf
								
				nPgAtu++
				
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
				OLE_NewFile(oWord, cPathEst+cArqDot)
				OLE_SetProperty( oWord, oleWdVisible,   .F. )
				OLE_SetProperty( oWord, oleWdPrintBack, .T. )
				
				//	OLE_ExecuteMacro(oWord,"novo_doc")
				
				For id_1 := 1 to nLinOrgao
					If Id_1 <= 4
						OLE_SetDocumentVar(oWord,"cOrgao"+StrZero(id_1,2),AllTrim(StrTran(MemoLine( cNomOrgao, 60, id_1 ),chr(13)+chr(10),"")))
					EndIf
				Next
//				id_1 -- Acredito que esteja errado, está apagando a última linha preenchida - MCVN - 13/04/2007
				Do While Id_1 <= 4
					OLE_SetDocumentVar(oWord,"cOrgao"+StrZero(id_1,2)," ")
					id_1++
				EndDo
						
				OLE_SetDocumentVar(oWord,"cDipromed","DIPROMED COMÉRIO E IMPORTAÇÃO LTDA"+CR+"CNPJ:47.869.078/0004-53"+CR+CR+Capital(AllTrim(Posicione("SA1",1,XFilial("SA1")+ M->UA1_CODCLI+M->UA1_LOJA,"A1_NOME")))+CR+"PREGÃO  Nº  "+AllTrim(M->UA1_NRCONC)+CR+" PROCESSO Nº  "+AllTrim(M->UA1_PROCES)+CR+CR+"ITEM ")
			   //	OLE_SetDocumentVar(oWord,"cCnpj","   CNPJ:47.869.078/0004-53")								
			   //	OLE_SetDocumentVar(oWord,"cCliente"	," "+AllTrim(M->UA1_CODCLI))
			  //	OLE_SetDocumentVar(oWord,"cNomeCliente"	,Capital(AllTrim(Posicione("SA1",1,XFilial("SA1")+ M->UA1_CODCLI+M->UA1_LOJA,"A1_NOME"))) ) // MCVN - 15/02/2007								
			   //	OLE_SetDocumentVar(oWord,"cEdital"	,"PREGÃO  Nº  "+AllTrim(M->UA1_NRCONC)+" - PROCESSO Nº  "+AllTrim(M->UA1_PROCES))

				
				Id := 01
				
			EndIf                                            
			
			SB1->(dbSeek(xFilial("SB1") + UA4->UA4_AMOSTR))
			SA2->(dbSeek(xFilial("SA2") + SB1->B1_PROC))
			
		   	OLE_SetDocumentVar(oWord,"cItem"+StrZero(id,3)," "+UA4->UA4_ITEMAM)
			
			OLE_SetDocumentVar(oWord,"cLinha"+StrZero(id,3), If((!Empty(UA4->UA4_LOTE)),UA4->UA4_LOTE+"-"+UA4->UA4_ITEMLT,UA4->UA4_ITEMAM) + " - " +;
			                                                 StrZero(UA4->UA4_QAMOST,6) +" "+;
			                                                 UA4->UA4_UMAMOS + " - "+;
			                                                 SB1->B1_DESC)
			id++
			OLE_SetDocumentVar(oWord,"cLinha"+StrZero(id,3),"FABRICANTE: " + SA2->A2_NOME)
			id++
		EndIf
		
		UA4->(dbSkip())
		
	EndDO
	OLE_SetDocumentVar(oWord, 'etq_nroitens',id)
/* 	Do While id < 20
     	OLE_SetDocumentVar(oWord,"cLinha"+StrZero(id,1)," ")
 		id++
 		OLE_SetDocumentVar(oWord,"cLinha"+StrZero(id,1)," ")
 		id++
 	EndDo */
	OLE_ExecuteMacro(oWord,"Etiqueta")
	OLE_SetDocumentVar(oWord,"cDataExtenso","Osasco, " + StrZero(Day(dDataBase),2)+" de " +aMes[Month(dDataBase)]+" de " +SubStr(Dtos(dDataBase),1,4))
	
	OLE_SetDocumentVar(oWord,"cFolha","Folha "+AllTrim(Str(nPgAtu)))
	OLE_UpDateFields(oWord)
	
	//Seleciona o diretorio onde sera salvo o arquivo ".DOC"
	cNewFile := cGetFile(" | *.* |" , "Salvar em" ,,,.F., GETF_LOCALHARD + GETF_LOCALFLOPPY + GETF_RETDIRECTORY,.F.)
	
	If(Len(cNewFile) < 1)
		Alert("Nome inválido!")
		Return(.F.)
	Else
		nPos := RAT("\",cNewFile)
		cPathEst := SUBSTR(cNewFile, 1, nPos)
		cNewFile := cPathEst
	EndIF
	
	cNewFile := cNewFile+"etiqueta_" + AllTrim(M->UA1_CODIGO) + ".doc"
	OLE_SaveAsFile(oWord,cNewFile,,,.F.,) // Salva o arquivo na estacao
	CpyT2S(cNewFile,"\word\",.T.)         //Copia o arquivo salvo na estacao para o servidor no diretorio \word\ a partir do rootpath
	OLE_CloseLink(oWord)                  // Copia do Remote para o Servidor
	
EndIf

Return(.T.)    
            /*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AcertAmostra() º Autor ³ Maximo       º Data ³ 12/03/2009   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ ACERTA PEDIDO EMPENHO    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ ESPECIFICO DIPROMED                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
*-------------------------------*
Static Function AcertAmostra()
*-------------------------------*
Local bOk:={|| nOpcao:=1,lSaida := .T.,oDlg:End()}
Local oDlg
Local oBt1
Local oBt2
Local nOpcao    := 0   
Local nX        := 0 
Local lSaida    := .F.         
Local cPedido   := SPACE(6)
Local _xAlias   := GetArea()  
Local cMsgDiver := ""
Local cDiverg   := ""

Do While !lSaida
	nOpcao := 0
	Define msDialog oDlg title OemToAnsi("Informe o Pedido de AMOSTRA") From 09,10 TO 15,45
	@ 002,002 to 045,136 pixel
	@ 010,010 say "Pedido"   Pixel
	@ 010,060 get oPedido var cPedido Size 40,08 pixel  VALID SC5->(DbSeek(xFilial("SC5")+cPedido)) = .T.
	Define sbutton oBt1 from 030,090 type 1 action Eval(bOK) enable of oDlg
	Activate Dialog oDlg Centered                          
EndDo          


IF SC5->(DbSeek(xFilial("SC5")+cPedido))
	If Empty(SC5->C5_EDITAL)
		If MSGBOX("O pedido de amostra "+cPedido+" foi encontrado! Confirma gravação?" ,"Atencao","YESNO")
			RecLock("SC5",.F.)
			SC5->C5_EDITAL  := UA1->UA1_CODIGO
			SC5->C5_EMPENHO := "0"
			SC5->(MsUnLock())  		    		
			If SC6->(DbSeek(xFilial("SC6")+cPedido))			  	
	  	        While SC6->C6_NUM == cPedido
				    If UA4->(DbSeek(xFilial("UA4")+UA1->UA1_CODIGO))			  	
						While UA4->UA4_EDITAL == UA1->UA1_CODIGO
							If UA4->UA4_PRODUT == SC6->C6_PRODUTO .or. UA4->UA4_AMOSTR == SC6->C6_PRODUTO
								RecLock("UA4",.F.)	
								UA4->UA4_PEDAMO  := SC5->C5_NUM						
					 			UA4->( MsUnLock()  )           
					 		Else
					 			cMsgDiver := "ACERTO DE EDITAL - O PRODUTO "+SC6->C6_PRODUTO+" no pedido "+SC6->C6_NUM+" não está informado no Edital! "+dtoc(date())
					 			cDiverg:=cDiverg+If(Empty(cDiverg),""," / ")+cMsgDiver
					 		Endif
					 	UA4->(dbSkip())		
			 			Enddo
			    	Endif
		    	SC6->(dbSkip())	
       		 	Enddo
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
		
		// Aqui vem a rotina que envia e-mail - MCVN
	Else	          
		MSGBOX("Esse pedido já está com o campo de edital preenchido com o nº "+SC5->C5_EDITAL ,"Atencao","OK")
	Endif
Endif			
			  				  	    
If !(MSGBOX("Existem mais pedidos de amostra a informar ?" ,"Atencao","YESNO"))
   	lFinAmostra := .T.
Endif    

RestArea(_xAlias )	
Return()      
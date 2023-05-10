#INCLUDE "TCBROWSE.CH"
#INCLUDE "RWMAKE.CH"
#DEFINE TELEMARKETING 1 // JBS 03/11/2005
#DEFINE TELEVENDAS    2 // JBS 03/11/2005
#DEFINE TELECOBRANCA  3 // JBS 03/11/2005   


User Function TK271BOK(_nOpc)

Local _aArea	    := GetArea()    
Local _lRetorno 	:= .T.
Local _n			:= 0
Local cCondPag      := space(len(SUA->UA_CONDPG)) 
Local nPProd        := aPosicoes[1][2]					// Posicao do Produto
Local nPQtd         := aPosicoes[4][2]					// Posicao da Quantidade
Local nPVrUnit      := aPosicoes[5][2]					// Posicao do Valor Unitario
Local nPVlrItem     := aPosicoes[6][2]					// Posicao do Valor do item 
Local nPTes	        := aPosicoes[11][2]					// Posicao do Tes 	
Local nPCf          := aPosicoes[12][2]					// Posicao do CF 	
Local _aMsg         := {}
Local _cAssunto     := ""
Local _cEmail       := ""  
Local _cDestCli  	:= ""  
Local _cFrom     	:= "" 
Local _cFuncSent 	:= "TK271BOK.PRW"
Local _aInfoPro     := {}
Local _mInfoPro     := "" 
Local _pn      
Local lverOperado := .F.   
Local I := 0                        
Local cUcStatus   := GetNewPar("ES_UCTATUS","EPONTOLDIO")  
Local _cUsrSAC    := AllTrim(Upper(GetNewPar("ES_SAC_SC","RBEAZIN/RBORGES"))) 
Local cEsDifal    := GetNewPar('ES_ESDIFAL','ES/BA/MG/RJ')
Local cEstDifal   := ""
Local lRetTmk     := .T.
Local nDifal      := 0
Local nProdSt     := 0
Local aMultCx     := {}
Local cValProd    := ""   
Private cPosDoc   := aScan(aHeader, { |x| Alltrim(x[2]) == "UD_XNFORI" })
Private cPosCli   := aScan(aHeader, { |x| Alltrim(x[2]) == "UD_XCLIENT" })
Private cPosEmi   := aScan(aHeader, { |x| Alltrim(x[2]) == "UD_XEMISSA" })
Private cPosProd  := aScan(aHeader, { |x| Alltrim(x[2]) == "UD_PRODUTO" })



/*
+-----------------------------------------------------------------------------------+
|Função: TELATMKB()             Alteração por: REGINALDO BORGES Data: 07/08/15      |
+-----------------------------------------------------------------------------------+
|Objetivo......: Validar se o cliente carregado pela nota fiscal é o mesmo informado|
|                no cabeçalho da ocorrência. Validação na confirmação.              |
+-----------------------------------------------------------------------------------+
|Consideraçoes.: Função chamada no X3_VLDUSER.                                      |
+-----------------------------------------------------------------------------------+
*/

IF INCLUI .Or. ALTERA
	FOR I := 1 TO Len(aCols)
		If !Empty(aCols[I,cPosDoc])
			if !aCols[I,cPosCli] == M->UC_CLIENTE .And. !aCols[I,Len(aHeader)+1] == .T. 
				MsgInfo("Cliente "+aCols[I,cPosCli]+", da Nota Fiscal, difere do Informado no cabeçalho.","ATENÇÃO!")
				Return(.F.)		
			EndIf
		EndIf		
	Next             
   If UPPER(U_DipUsr()) $ cUcStatus .And. M->UC_STATUS <> "14" //RBorges M->UC_STATUS <> "14", pois a Patricia, as vezes, precisa enviar SAC direto para a vendedora.
   		M->UC_STATUS := "1" 
   EndIf	

If (INCLUI .Or. ALTERA) .And. UPPER(U_DipUsr()) $ _cUsrSAC
	
	FOR I := 1 TO Len(aCols)
		If !Empty(aCols[I,cPosDoc])
			U_NFDIFAL(aCols[I,cPosDoc],aCols[I,cPosEmi],aCols[I,cPosProd],@nDifal,@cEstDifal,@nProdSt)
			U_VALPROD(aCols[I,cPosDoc],aCols[I,cPosEmi],aCols[I,cPosProd],aCols[I,10],@cValProd)
			
			If cEmpAnt <> "04"
				If INCLUI .And. UPPER(U_DipUsr()) $ _cUsrSAC
					U_PRODMULTCX(aCols[I,cPosDoc],aCols[I,cPosEmi],aCols[I,cPosProd],@aMultCx)
					If Len(aMultCx) > 0
						cMsgAviso := "Produto "+AllTrim(aCols[I,cPosProd])+" da NF "+aCols[I,cPosDoc]+", está na regra para venda em múltipos de caixa fechada! "+CHR(10)+CHR(13)
						cMsgAviso += "-> Venda múltiplos de "+AllTrim(Str(aMultCx[I,6]))+"! "
						Aviso("Atenção",cMsgAviso,{"Ok"},3)
					EndIf
				EndIf
			EndIf
			
			If     nDifal > 0 .And. !cEstDifal $ cEsDifal
				MsgInfo("Produto "+AllTrim(aCols[I,cPosProd])+" da NF "+aCols[I,cPosDoc]+" saiu com diferencial de ICMS, verificar tabela! ","ATENÇÃO!")
			ElseIf nProdSt > 0
				MsgInfo("Produto "+AllTrim(aCols[I,cPosProd])+" da NF "+aCols[I,cPosDoc]+" saiu com ST, verificar tabela! ","ATENÇÃO!")
			EndIf
			
			If     cValProd == "P"
				MsgInfo("Produto "+AllTrim(aCols[I,cPosProd])+" da NF "+aCols[I,cPosDoc]+" saiu como Promoção, VALIDADE."," ATENÇÃO!")
			ElseIf cValProd == "D"
				MsgInfo("Produto "+AllTrim(aCols[I,cPosProd])+" da NF "+aCols[I,cPosDoc]+" verificar se saiu como Doação, VALIDADE."," ATENÇÃO!")
			ElseIf cValProd == "V"
				MsgInfo("Produto "+AllTrim(aCols[I,cPosProd])+" da NF "+aCols[I,cPosDoc]+" está com a VALIDADE vencida."," ATENÇÃO!")
			EndIf
			
		EndIf
		
	Next
	
EndIf
 


	FOR I := 1 TO 1 //Len(aCols)
		If !Empty(aCols[I,11])
			lRetTmk := U_telatmkb()
			If ! lRetTmk
				Return(.F.)
			EndIf
		EndIf		
	Next                
   	
EndIf 


If "TMK"$FunName() .and. nFolder <> TELEVENDAS  // JBS 04/12/2005 

	Return(.t.)
	RestArea(aArea)
EndIf
              


Private lTemTesDoacao := .f.
Private lTemTesGerDup := .f.


// Tratando erro de TES de ICMS-ST fora de São Paulo
For _ncont := 1 to Len(aCols)   
	If SA1->A1_EST <> "SP" .And. (aCols[_ncont][nPTes]) $ "625/626/627/630/631/632/633" 
		MsgInfo("A TES do produto  "+(aCols[_ncont][nPProd])+ " está incorreta, Favor dar ENTER no produto e liberar novamente.",'Atenção')       
     	Return(.f.)
	EndIf        
	//Iif(CheckSX3("UB_TES",(aCols[_ncont][nPTes])),(aCols[_ncont][nPTes]),0)                                                   	
//	Iif(valtype(RunTrigger(2,n,NIL,"UB_TES"))=="U",(aCols[_ncont][nPTes]),(aCols[_ncont][nPTes]))                           
Next _ncont        

// Verifica Operador  MCVN - 10/11/2008

If M->UA_OPERADO $ "000126/000168/000169"
	While !lverOperado
		lverOperado:=u_VerOperad()
	Enddo
Endif

// Mensagem referente a emissão da nota fiscal com 2ª descrição - MCVN 10/04/2008
If SA1->A1_DIFEREN $ "ET" 

	For _pn := 1 to Len(aCols)    					
		// Verificando informações referente a segunda descrição dos produtos - MCVN 06/08/08
		If (!aCols[_pn,Len(aHeader)+1])  // Não verifica os deletados
			If SA1->A1_DIFEREN == "T" .And. (Empty(Posicione("SB1",1,xFilial("SB1")+aCols[_pn,nPProd],"B1_SEGUM")) .Or. ;
			Posicione("SB1",1,xFilial("SB1")+aCols[_pn,nPProd],"SB1->B1_CONV") = 0) 
				Aadd( _aInfoPro,Alltrim(aCols[_pn,nPProd]) )
			ElseIf SA1->A1_DIFEREN == "E" .And. (Empty(Posicione("SB1",1,xFilial("SB1")+aCols[_pn,nPProd],"B1_SEGUM")) .Or. ;
    		Posicione("SB1",1,xFilial("SB1")+aCols[_pn,nPProd],"SB1->B1_CONV") = 0 .Or. ;
			Empty(Posicione("SB1",1,xFilial("SB1")+aCols[_pn,nPProd],"SB1->B1_DESC2")))
				Aadd( _aInfoPro,Alltrim(aCols[_pn,nPProd]) )
			Endif                                                                   
		Endif
	Next                                                                            
		
	
	If SA1->A1_DIFEREN == "E"	
   	   _mInfoCli := 'O cliente deste pedido está marcado como "ERIKA", a nota será emitida pela 2a. descrição, será alterado também: Quantidade, Preço Unitário e Unidade de medida.'
	   If !(MsgBox(_mInfoCli," CONFIRMA EMISSÃO DO PEDIDO UTILIZANDO A 2ª DESCRIÇÃO DOS PRODUTOS?",'YESNO'))	
		   DbSelectArea("SA1")
		   If MsgBox("O cliente será alterado para não utilizar 2ª descrição. Confirma Alteração? ","Atencao","YESNO")
		   	  RecLock("SA1",.F.)
		   	  SA1->A1_DIFEREN := "N"
		   	  SA1->(MsUnLock())		  	
    	      lUsa2Desc := .F.
		   EndIF 
   	   Else
	   	   lUsa2Desc := .T.
	   Endif	   
	  
	ElseIf SA1->A1_DIFEREN == "T"
   	   _mInfoCli := 'O cliente deste pedido está marcado como "TAIS", na emissão da nota será alterado os campos: Quantidade, Preço Unitário e Unidade de medida.'
	   If !(MsgBox(_mInfoCli," CONFIRMA EMISSÃO DO PEDIDO UTILIZANDO A 2ª DESCRIÇÃO DOS PRODUTOS?",'YESNO'))	
	       DbSelectArea("SA1")
		   If MsgBox("O cliente será alterado para não utilizar 2ª descrição. Confirma Alteração? ","Atencao","YESNO")
		      RecLock("SA1",.F.)
		   	  SA1->A1_DIFEREN := "N"
		   	  SA1->(MsUnLock())		  	
    	      lUsa2Desc := .F.
		   EndIF 
   	   Else
	   	  lUsa2Desc := .T.
	   Endif
	   
	EndIf  
	
    If Len(_aInfoPro) > 0 .And. _lRetorno .And. lUsa2Desc
        For aa := 1 to Len(_aInfoPro)        
	        _mInfoPro += If(Empty(_mInfoPro),"Produto(s) com problema no cadastro referente a 2ª descrição, 2ª UM ou Fator de conversão: Produto(s) "+_aInfoPro[aa]," / "+_aInfoPro[aa])	       
	    Next
        	
 		MsgBox(_mInfoPro," O PEDIDO FICARÁ BLOQUEADO, FAVOR SOLICITAR CORREÇÃO DO(S) PRODUTO(S)!",'ALERT')	   	  
		_aInfoPro := {}
		_mInfoPro := ""
		M->UA_PARCIAL := "T"
    Endif
	_aInfoPro := {}
	_mInfoPro := "" 
	lUsa2Desc := .F.
Endif

                                                                       
/*// Validando a alteraçao do destino do frete solicitando senha  MCVN - 03/08/2007
If Alltrim(M->UA_DESTFRE) <> Alltrim(U_Mt410Frete('GATILHO'))  .And. M->UA_TPFRETE $ "IC"
    MsgInfo("O DESTINO DO FRETE FOI ALTERADO. É NECESSÁRIO UMA SENHA PARA VALIDAR A ALTERAÇÃO",'Atenção')
	If !(U_SENHA("FRE",0,0,0)) 
	   M->UA_TRANSP  := Space(06)
	   AVALORES[4]   := 0  	
   	   M->UA_DESTFRE := U_Mt410Frete('GATILHO')
       Return(.f.)
	Endif
Endif*/
               

If Type("lDip271Ok") == "U"
   Public lDip271Ok := .t.
ElseIf !lDip271Ok
   lDip271Ok := .t.
Else
   Return(.f.)
EndIf
//lDipSenha1 := .f.
//lDipSenha2 := .f.

U_DIPPROC(ProcName(0),U_DipUsr()) // JBS 05/10/2005 - Gravando o nome do Programa no SZU

If Empty(aCols[n][nPProd]) 	.OR.;
		Empty(aCols[n][nPQtd])  	.OR.;
		Empty(aCols[n][nPVrUnit])  	.OR.;			
		Empty(aCols[n][nPVlrItem]) 	.OR.;			
		Empty(aCols[n][nPTes]) 		

   MsgBox(U_DipUsr()+" você está querendo perder o pedido? Por favor suba uma linha!","      Pelo amor de  DEUS!","Error")      
   lDip271Ok := .F.
   return(.f.)
EndIf         

/*
   Adel(aCols,len(aCols))
   Asize(aCols,len(aCols)-1)
   n:=len(aCols)
   lDip271Ok := .F.
   return(.f.)
EndIf
*/
SF4->(dbSetOrder(1))

For _n := 1 to Len(aCols)   
	If SF4->(dbSeek(xFilial("SF4")+aCols[_n,aScan(aHeader, { |x| Alltrim(x[2]) == "UB_TES"})]))
		If SF4->F4_DUPLIC == 'S'
			lTemTesGerDup := .t.
		EndIf
		If "AMOSTRA" $ Upper(SF4->F4_TEXTO) .OR.;
			"DOACAO" $ Upper(SF4->F4_TEXTO) .OR.;
			"BONIFICACAO" $ Upper(SF4->F4_TEXTO)
			lTemTesDoacao := .t.
		EndIf
	EndIf     
Next _n

If !lTemTesGerDup .and. lTemTesDoacao
	U_TMKVLDE4(_nOpc,cCondPag)
	U_CalcuFrete('TMKVLDE4')
EndIf      
           

 //  Envia e-mail sempre que o destino de frete for alterado   MCVN - 16/10/2007
_cDestCli := Alltrim(U_Mt410Frete('GATILHO'))
If Alltrim(M->UA_DESTFRE) <> _cDestCli .And. M->UA_TPFRETE $ "IC"  .And. SUA->UA_DESTFRE <> M->UA_DESTFRE
   	IF MsgBox("O DESTINO DO FRETE FOI ALTERADO. CONFIRMA A ALTERAÇÃO?","Atencao","YESNO")  
 	 
   	    _cFrom   := Lower(Alltrim(Posicione("SU7",1,xFilial("SU7")+UA_OPERADO,"U7_EMAIL")))
   	    _cEmail  := "maximo@dipromed.com.br"                                
  	    _cAssunto:= "Destino de FRETE do atendimento "+M->UA_NUM+" foi alterado!"
    	Aadd( _aMsg , { "Numero Pedido: "       , M->UA_NUM } )
		Aadd( _aMsg , { "Operador: "            , M->UA_OPERADO +" - "+ M->UA_DESCOPE } )
		Aadd( _aMsg , { "Transportadora: "      , M->UA_TRANSP  } )
		Aadd( _aMsg , { "Destino do Cliente: "  , _cDestCli + " - " + If(Empty(Alltrim(SA1->A1_MUNE)),SA1->A1_MUNE,SA1->A1_MUN) } )
		Aadd( _aMsg , { "Destino do Pedido:  "  , M->UA_DESTFRE } )
		Aadd( _aMsg , { "Tipo de Frete: "       , M->UA_TPFRETE } )		
	
       	U_UEnvMail(_cEmail,_cAssunto,_aMsg,"",_cFrom,_cFuncSent)
        	
        _lRetorno := .T.
    Else
	    M->UA_TRANSP  := Space(06)
	    AVALORES[4]   := 0  	
   	    M->UA_DESTFRE := U_Mt410Frete('GATILHO')
        _lRetorno := .T.
	Endif
Endif           

If _lRetorno .And. M->UA_OPER == '2' .AND. EMPTY(M->UA_CONDPG)
	M->UA_CONDPG := 'KKK'
ENDIF    

If _lRetorno
	M->UA_STATUS := If(Empty(M->UA_STATUS) .Or. M->UA_STATUS = "LIB","SUP", M->UA_STATUS)
Endif

RestArea(aArea)
Return(_lRetorno)
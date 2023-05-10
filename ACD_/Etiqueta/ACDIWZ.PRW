#Include "Protheus.ch"
#Include "ApWizard.ch"         

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  Tst10WZ2   บAutor  ณEmerson Leal Bruno  บ Data ณ  15/09/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณEtiqueta de Pre Nota de entrada utilizado no rece			  บฑฑ
ฑฑบ          ณbimento                                                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP5                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/  
                                                                         
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
User Function Tst10WZ()                                                                                                                          
///////////////////////
U_ACDIWZ3()
Return                          

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
User Function ACDIWZ3(nOrigem,aParIni)                                                                                                            
//////////////////////////////////////
Local oWizard
Local oPanel
Local nTam

Local oOrigem
Local aOrigem	:= {}

Local aparNF	:= {	{1,"Nota Fiscal" 		,Space(9) ,"","","CBW"	,If(aParIni==NIL,".T.",".F."),0,.F.},; //"Nota Fiscal"
						{1,"Serie" 					,Space(3) ,"","",		,If(aParIni==NIL,".T.",".F."),0,.F.},; //"Serie"
						{1,"Fornecedor"			,Space(6) ,"","","SA2"	,If(aParIni==NIL,".T.",".F."),0,.F.},; //"Fornecedor"
						{1,"Loja"					,Space(2) ,"","",		,If(aParIni==NIL,".T.",".F."),0,.F.} } //"Loja"

Local aRetNF	:= {Space(9),Space(3),Space(6),Space(2)}

Local aParPR	:= {{1,"Produto" ,Space(15),"","","SB1"	,If(aParIni==NIL,".T.",".F."),0,.F.}} //"Produto"
Local aRetPR	:= {Space(15)}

Local aParOP	:= {{1,"OP" ,Space(13),"","","SC2"	,If(aParIni==NIL,".T.",".F."),0,.F.}}
Local aRetOP	:= {Space(13)}

Local aParImp	:= {{1,"Local de Impressใo"	,Space(06),"","","CB5"	,".F.",0,.F.}} //"Local de Impressใo"
Local aRetImp	:= {Space(6)}

Local aParam	:= {} 
Local aRetPE	:= {}

Local nx:= 1

Private cCondSF1:= ' 1234567890'  // variavel utilizada na consulta sxb CBW, favor nao remover esta linha
Private oLbx
Private aLbx	:= {{.f., Space(15),Space(20),Space(10),Space(10),Space(10),Space(10),Space(20)}}
Private aSvPar	:= {}
Private cOpcSel	:= ""  // variavel disponivel para infomar a opcao de origem selecionada

Private cNota	:= ''
Private cSerie	:= ''
Private cForn 	:= ''
Private cLoja 	:= ''
Private cOp		:= ''
Private cProduto	:= ''
Private cPedComp			:= ""      
Private cOpc_NP :=""

DEFAULT nOrigem := 1

aParam:={	{"Nota Fiscal"				,aParNF,aRetNF,{|| AWzVNF()}},; //"Nota Fiscal"
			{"Produto" 					,aParPR,aRetPR,{|| AWzVPR()}} } //"Produto"
//			{"Ordem de Producao"		,aParOP,aRetOP,{|| AWzVOP()}} } //"Ordem de Producao"	

// carrega parametros vindo da funcao pai
If aParIni <> NIL  
	For nX := 1 to len(aParIni)              
		nTam := len( aParam[nOrigem,3,nX ] )
		aParam[nOrigem,3,nX ] := Padr(aParIni[nX],nTam )
	Next             
EndIf 

For nx:= 1 to len(aParam)                       
	aadd(aOrigem,aParam[nX,1])
Next

DEFINE WIZARD oWizard TITLE "Etiqueta de Produto ACD" ; //"Etiqueta de Produto ACD"
       HEADER "Rotina de Impressใo de etiquetas termica." ; //"Rotina de Impressใo de etiquetas termica."
       MESSAGE "";
       TEXT "Esta rotina tem por objetivo realizar a impressao das etiquetas termicas de identifica็ใo de produto no padrใo codigo natural/EAN conforme as opcoes disponives a seguir." ; //"Esta rotina tem por objetivo realizar a impressao das etiquetas termicas de identifica็ใo de produto no padrใo codigo natural/EAN conforme as opcoes disponives a seguir."
       NEXT {|| .T.} ;
		 FINISH {|| .T. } ;
       PANEL

   // Primeira etapa
   CREATE PANEL oWizard ;
          HEADER "Informe a origem das informa็๕es para impressใo" ; //"Informe a origem das informa็๕es para impressใo"
          MESSAGE "" ;
          BACK {|| .T. } ;
 	       NEXT {|| nc:= 0,aeval(aParam,{|| &("oP"+str(++nc,1)):Hide()} ),&("oP"+str(nOrigem,1)+":Show()"),cOpcSel:= aParam[nOrigem,1],A11WZIniPar(nOrigem,aParIni,aParam) ,.T. } ;
          FINISH {|| .F. } ;
          PANEL
   
   oPanel := oWizard:GetPanel(2)  
   
   oOrigem := TRadMenu():New(30,10,aOrigem,BSetGet(nOrigem),oPanel,,,,,,,,100,8,,,,.T.)
   If aParIni <> NIL
	   oOrigem:Disable()
	EndIf	   
	
   // Segunda etapa
   CREATE PANEL oWizard ;
          HEADER "Preencha as solicita็๕es abaixo para a sele็ใo do produto" ; //"Preencha as solicita็๕es abaixo para a sele็ใo do produto"
          MESSAGE "" ;
          BACK {|| .T. } ;
          NEXT {|| Eval(aParam[nOrigem,4]) } ;
          FINISH {|| .F. } ;
          PANEL                                  

   oPanel := oWizard:GetPanel(3)                                     
   
	For nx:= 1 to len(aParam)
  		&("oP"+str(nx,1)) := TPanel():New( 028, 072, ,oPanel, , , , , , 120, 20, .F.,.T. )
		&("oP"+str(nx,1)):align:= CONTROL_ALIGN_ALLCLIENT       
		ParamBox(aParam[nX,2],"Parโmetros...",aParam[nX,3],,,,,,&("oP"+str(nx,1)))		 //"Parโmetros..."
		&("oP"+str(nx,1)):Hide()
	Next		

   CREATE PANEL oWizard ;
          HEADER "Parametriza็ใo por produto" ; //"Parametriza็ใo por produto"
          MESSAGE "Marque os produtos que deseja imprimir" ; //"Marque os produtos que deseja imprimir"
          BACK {|| .T. } ;
          NEXT {|| aRetImp  := {"000001"},VldaLbx()} ;
          FINISH {|| .T. } ;
          PANEL
   oPanel := oWizard:GetPanel(4)       
   ListBoxMar(oPanel)
                        
   CREATE PANEL oWizard ;
          HEADER "Parametriza็ใo da impressora" ; //"Parametriza็ใo da impressora"
          MESSAGE "Informe o Local de Impressใo" ; //"Informe o Local de Impressใo"
          BACK {|| .T. } ;
          NEXT {|| MV_PAR01:="000001",Imprime(aParam[nOrigem,1]) } ;
          FINISH {|| .T.  } ;
          PANEL
   oPanel := oWizard:GetPanel(5)       
   ParamBox(aParImp,"Parโmetros...",aRetImp,,,,,,oPanel)	 //"Parโmetros..."
   
     CREATE PANEL oWizard ;
          HEADER "Impressใo Finalizada" ; //"Impressใo Finalizada"
          MESSAGE "" ;
          BACK {|| .T. } ;
          NEXT {|| .T. } ;
          FINISH {|| .T.  } ;
          PANEL

ACTIVATE WIZARD oWizard CENTERED

Return                                           

Static Function A11WZIniPar(nOrigem, aParIni,aParam)
Local nX
If aParIni <> NIL
	For nx:= 1 to len(aParIni)
		&( "MV_PAR" + StrZero( nX, 2, 0 ) ) := aParIni[ nX ]
	Next
EndIf
         
For nx:= 1 to len(aParam[nOrigem,3])                                    
	&( "MV_PAR" + StrZero( nX, 2, 0 ) ) := aParam[nOrigem,3,nX ]
Next                       

Return .t.                                                                                               

/////////////////////////////////////////////////////////////////////////////////////////////////////////
Static Function AWzVNF()
 
Local nQE
Local nQVol
Local nResto
Local cD1cod               
Local oOk  		:= LoadBitmap( GetResources(), "LBOK" )   //CHECKED    //LBOK  //LBTIK
Local oNo  		:= LoadBitmap( GetResources(), "LBNO" ) //UNCHECKED  //LBNO   
Local nT   		:= TamSx3("D3_QUANT")[1]
Local nD   		:= TamSx3("D3_QUANT")[2]

cNota	:= Padr(MV_PAR01,9)
cSerie	:= Padr(MV_PAR02,3)
cForn 	:= Padr(MV_PAR03,6)
cLoja 	:= Padr(MV_PAR04,2)  

If Empty(cNota+cSerie+cForn+cLoja)
  	MsgAlert(" Necessario informar a nota e o fornecedor. ") //" Necessario informar a nota e o fornecedor. "
 	Return .F.
EndIf
SF1->(DbSetOrder(1))
If ! SF1->(DbSeek(xFilial('SF1')+cNota+cSerie+cForn+cLoja))
  	MsgAlert(" Nota fiscal nใo encontrada. ") //" Nota fiscal nใo encontrada. "
  	Return .F.
EndIf       

aLbx:={}
SD1->(DbSetOrder(1))
SD1->(dbSeek(xFilial('SD1')+cNota+cSerie+cForn+cLoja)	)
While SD1->(!EOF()  .and. D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA == xFilial('SD1')+cNota+cSerie+cForn+cLoja) 

	cPedComp := SD1->D1_PEDIDO //PEDIDO DE COMPRA

   If cEmpAnt == '04'
   		If SubStr(SD1->D1_COD,1,1) == '8'
			SB1->(dbSeek(xFilial('SB1')+"2"+SubStr(SD1->D1_COD,2,Len(SD1->D1_COD)-1)))
		Else
			SB1->(dbSeek(xFilial('SB1')+SD1->D1_COD))	
		EndIf	
	Else
		SB1->(dbSeek(xFilial('SB1')+SD1->D1_COD))		
	EndIf		

	If ! CBImpEti(SB1->B1_COD)
		SD1->(dbSkip()	)
		Loop
	EndIf 
	nQE     := SD1->D1_QUANT//CBQEmbI()
//	nQE	    := If(Empty(nQE),1,nQE)
	nQVol   := Int(SD1->D1_QUANT/nQE)
	nResto  := SD1->D1_QUANT%nQE          
	  
   If cEmpAnt == '04'
   		If SubStr(SD1->D1_COD,1,1) == '8'
			cD1cod  := "2"+SubStr(SD1->D1_COD,2,Len(SD1->D1_COD)-1)
		Else
			cD1cod  := SD1->D1_COD  
		EndIf	
	Else
		cD1cod  := SD1->D1_COD  
	EndIf			
	

	
//	If nResto >0
//	   nQVol++
//	EndIf
	SD1->(aadd(aLbx,{.f.,cD1cod,Str(SD1->D1_QUANT,nT,nD),Str(nQe,nT,nD),Str(nResto,nT,nD),Str(nQVol,nT,nD),SD1->D1_LOTECTL,Space(20),"SD1",Recno()}))  
	SD1->(dbSkip()	)
End     

cOpc_NP:= "N"

oLbx:SetArray( aLbx )
oLbx:bLine := {|| {Iif(aLbx[oLbx:nAt,1],oOk,oNo),aLbx[oLbx:nAt,2],aLbx[oLbx:nAt,3],aLbx[oLbx:nAt,4],aLbx[oLbx:nAt,5],aLbx[oLbx:nAt,6],aLbx[oLbx:nAt,7],aLbx[oLbx:nAt,8]}}
oLbx:Refresh()

Return .t.

////////////////////////////////////////////////////////////////////////////////////////////////////////
Static Function AWzVPR()                                                                                

Local oOk		:= LoadBitmap( GetResources(), "LBOK" )   //CHECKED    //LBOK  //LBTIK
Local oNo		:= LoadBitmap( GetResources(), "LBNO" )   //UNCHECKED  //LBNO      
Local nT	  		:= TamSx3("D3_QUANT")[1]
Local nD	  		:= TamSx3("D3_QUANT")[2]  
                 
cProduto		:= Padr(MV_PAR01,15)
cNota			:= ''
cSerie 		:= ''     
cOp			:= ''

If Empty(cProduto)
  	MsgAlert(" Necessario informar o codigo do produto. ") //" Necessario informar o codigo do produto. "
  	Return .F.
EndIf

SB1->(DbSetOrder(1))
If ! SB1->(DbSeek(xFilial('SB1')+cProduto))
  	MsgAlert(" Produto nใo encontrado ") //" Produto nใo encontrado "
  	Return .F.
EndIf    

If ! CBImpEti(SB1->B1_COD)
  	MsgAlert(" Este Produto estแ configurado para nao imprimir etiqueta ") //" Este Produto estแ configurado para nao imprimir etiqueta "
  	Return .F.
EndIf 

cOpc_NP:= "P"

aLbx:={{	.f., SB1->B1_COD,Space(10),Str(CBQEmbI(),nT,nD),Str(0,nT,nD),Str(0,nT,nD),Space(10),Space(20),"SB1",SB1->(Recno())}}
oLbx:SetArray( aLbx )
oLbx:bLine := {|| {Iif(aLbx[oLbx:nAt,1],oOk,oNo),aLbx[oLbx:nAt,2],aLbx[oLbx:nAt,3],aLbx[oLbx:nAt,4],aLbx[oLbx:nAt,5],aLbx[oLbx:nAt,6],aLbx[oLbx:nAt,7],aLbx[oLbx:nAt,8]}}
oLbx:Refresh()
Return .t.

/*
////////////////////////////////////////////////////////////////////////////////////////////////////////////////
Static Function AWzVOP()                                 
////////////////////////////////////////////////////////

Local oOk	:= LoadBitmap( GetResources(), "LBOK" )   //CHECKED    //LBOK  //LBTIK
Local oNo	:= LoadBitmap( GetResources(), "LBNO" ) //UNCHECKED  //LBNO
Local nQtde
Local nQE
Local nQVol
Local nResto := 0                                           
Local nT	 := TamSx3("D3_QUANT")[1]
Local nD	 := TamSx3("D3_QUANT")[2] 

cOp		:= Padr(MV_PAR01,13)

If Empty(cOP)
  	MsgAlert(" Necessario informar o codigo do ordem de produ็ใo. ") //" Necessario informar o codigo do ordem de produ็ใo. "
  	Return .F.
EndIf

SC2->(DbSetOrder(1))
If ! SC2->(DbSeek(xFilial('SC2')+cOP))
  	MsgAlert(" Ordem de Produ็ใo nใo encontrado ") //" Ordem de Produ็ใo nใo encontrado "
 	Return .F.
EndIf               
SB1->(DbSetOrder(1))
SB1->(DbSeek(xFilial("SB1")+SC2->C2_PRODUTO))
If ! CBImpEti(SB1->B1_COD)
  	MsgAlert(" Este Produto estแ configurado para nao imprimir etiqueta ") //" Este Produto estแ configurado para nao imprimir etiqueta "
  	Return .F.
EndIf 
                                                        
nQtde	:= SC2->(C2_QUANT)//(C2_QUANT-C2_QUJE)
nQE		:= SC2->(C2_QUANT)//CBQEmbI()
nQE		:= If(Empty(nQE),1,nQE)
nQVol	:= Int(nQtde/nQE)
//nResto  :=nQtde%nQE                                               
//If nResto >0
//   nQVol++
//EndIf

aLbx:={{	.f., SB1->B1_COD,Str(nQtde,nT,nD),Str(nQE,nT,nD),Str(nResto,nT,nD),Str(nQVol,nT,nD),Space(10),Space(20),"SC2",SC2->(Recno())}}
oLbx:SetArray( aLbx )
oLbx:bLine := {|| {Iif(aLbx[oLbx:nAt,1],oOk,oNo),aLbx[oLbx:nAt,2],aLbx[oLbx:nAt,3],aLbx[oLbx:nAt,4],aLbx[oLbx:nAt,5],aLbx[oLbx:nAt,6],aLbx[oLbx:nAt,7],aLbx[oLbx:nAt,8]}}
oLbx:Refresh()

Return .t.     
*/
/////////////////////////////////////////////////
Static Function ListBoxMar(oDlg)                  
/////////////////////////////////////////////////
Local oChk1
Local oChk2
Local lChk1 := .F.
Local lChk2 := .F.
Local oOk	:= LoadBitmap( GetResources(), "LBOK" )   //CHECKED    //LBOK  //LBTIK
Local oNo	:= LoadBitmap( GetResources(), "LBNO" ) //UNCHECKED  //LBNO
Local oP
   
@ 10,10 LISTBOX oLbx FIELDS HEADER " ", "Produto", "Qtde do Item","Qtde Emb.","Resto","Qtde Volumes", "Lote", "Serie"  SIZE 230,095 OF oDlg PIXEL ;  //"Produto"###"Qtde do Item"###"Qtde Emb."###"Resto"###"Qtde Volumes"###"Lote"###"Serie"
        ON dblClick(VerLoteId()) //dblClick(aLbx[oLbx:nAt,1] := !aLbx[oLbx:nAt,1])

oLbx:SetArray( aLbx )
oLbx:bLine	:= {|| {Iif(aLbx[oLbx:nAt,1],oOk,oNo),aLbx[oLbx:nAt,2],aLbx[oLbx:nAt,3],aLbx[oLbx:nAt,4],aLbx[oLbx:nAt,5],aLbx[oLbx:nAt,6],aLbx[oLbx:nAt,7],aLbx[oLbx:nAt,8]}}
oLbx:align	:= CONTROL_ALIGN_ALLCLIENT

oP := TPanel():New( 028, 072, ,oDlg, , , , , , 120, 20, .F.,.T. )
oP:align:= CONTROL_ALIGN_BOTTOM

@ 5,010  BUTTON "Alterar"	 SIZE 55,11 ACTION FormProd(1) OF oP PIXEL //"Alterar"
//@ 5,080  BUTTON "Copiar"	 SIZE 55,11 ACTION FormProd(2) OF oP PIXEL //"Copiar"
@ 5,160 CHECKBOX oChk1 VAR lChk1 PROMPT "Marca/Desmarca Todos" SIZE 70,7 	PIXEL OF oP ON CLICK( aEval( aLbx, {|x| x[1] := lChk1 } ),oLbx:Refresh() ) //"Marca/Desmarca Todos"
//@ 5,230 CHECKBOX oChk2 VAR lChk2 PROMPT "Inverter a sele็ใo" 	SIZE 70,7 	PIXEL OF oP ON CLICK( aEval( aLbx, {|x| x[1] := !x[1] } ), oLbx:Refresh() ) //"Inverter a sele็ใo"

Return

/////////////////////////////////////////////////////////           
Static Function FormProd(nopcao)
/////////////////////////////////////////////////////////

Local oOk		:= LoadBitmap( GetResources(), "LBOK" ) //CHECKED    //LBOK  //LBTIK
Local oNo		:= LoadBitmap( GetResources(), "LBNO" ) //UNCHECKED  //LBNO
Local aRet		:= {}
Local aParamBox := {}  
Local cProduto	:= aLbx[oLbx:nAt,2]
Local nQtde		:= Val(aLbx[oLbx:nAt,3]) 
Local nQEmb		:= Val(aLbx[oLbx:nAt,4]) 
Local cQtde		:= aLbx[oLbx:nAt,3]
Local cQEmb		:= aLbx[oLbx:nAt,4]
Local aRet      := .T.

Local nQVol		:= 0
Local nResto	:= 0
Local cLote		:= aLbx[oLbx:nAt,7]
Local cNumSer	:= aLbx[oLbx:nAt,8]   
Local nAt		:= oLbx:nAt  

Local nMv
Local aMvPar	:={}
Local lRastro 	:= Rastro(cProduto) //.T.
Local lEndere 	:=.F. //Localiza(cProduto) 
Local nT		:= TamSx3("D3_QUANT")[1]
Local nD		:= TamSx3("D3_QUANT")[2] 


For nMv := 1 To 40
     aAdd( aMvPar, &( "MV_PAR" + StrZero( nMv, 2, 0 ) ) )
Next nMv                                          

If cOpc_NP == "N" .And. cEmpAnt <> "01"

	aParamBox :={	{1,"Produto"				,cProduto	,"","",""	,".F.",0,.F.},; 							//"Produto"
						{1,"Quantidade"			,cQtde 		,"",'PesqPict("SD3","D3_QUANT")',""	,".T.",0,.F.},; 	//"Quantidade"
						{1,"Qtd por Embalagem"	,cQEmb 		,"",'PesqPict("SD3","D3_QUANT")',""	,".T.",0,.t.},; 	//"Qtd por Embalagem"
						{1,"Lote"  				,cLote 		,"","",""	,If(lRastro,".F.",".T."),0,.F.},; 			//"Lote"
						{1,"Serie" 				,cNumSer 	,"","",""	,If(lEndere,".T.",".F."),0,.F.}} 			//"Serie"

Else //If cOpc_NP == "P"

	aParamBox :={	{1,"Produto"				,cProduto	,"","",""	,".F.",0,.F.},; 							//"Produto"
						{1,"Quantidade"			,cQtde 		,"",'PesqPict("SD3","D3_QUANT")',""	,".T.",0,.F.},; 	//"Quantidade"
						{1,"Qtd por Embalagem"	,cQEmb 		,"",'PesqPict("SD3","D3_QUANT")',""	,".T.",0,.t.},; 	//"Qtd por Embalagem"
						{1,"Lote"  				,cLote 		,"","",""	,If(lRastro,".T.",".T."),0,.F.},; 			//"Lote"
						{1,"Serie" 				,cNumSer 	,"","",""	,If(lEndere,".T.",".F."),0,.F.}} 			//"Serie"
EndIf

				
	If ! ParamBox(aParamBox,If(nopcao == 1,"Alterar","Copiar"),@aRet,,,,,,,,.f.)    //"Alterar","Copiar" 
	For nMv := 1 To Len( aMvPar )
  	  &( "MV_PAR" + StrZero( nMv, 2, 0 ) ) := aMvPar[ nMv ]
	Next nMv
		
	oLbx:SetArray( aLbx )
	oLbx:bLine := {|| {Iif(aLbx[oLbx:nAt,1],oOk,oNo),aLbx[oLbx:nAt,2],aLbx[oLbx:nAt,3],aLbx[oLbx:nAt,4],aLbx[oLbx:nAt,5],aLbx[oLbx:nAt,6],aLbx[oLbx:nAt,7],aLbx[oLbx:nAt,8]}}
	oLbx:Refresh()
	Return
EndIf


nQtde 	:= val(aRet[2])  
If Empty(nQtde)  
	If nOpcao == 2
		MsgAlert("Para a copia a quantidade nใo pode estar em branco!") //"Para a copia a quantidade nใo pode estar em branco!"
	EndIf
	If MsgYesNo("Quantidade informada igual a zero, deseja excluir esta linha?") //"Quantidade informada igual a zero, deseja excluir esta linha?"
	   aDel(aLbx,nAt)
	   aSize(aLbx,len(albx)-1)
   EndIf
Else
	nQEmb	:= val(aRet[3])
	cLote 	:= aRet[4]
	cNumSer	:= aRet[5]


	nQVol	:= Int(nQtde/nQEmb)     
	
//	nResto	:= nQtde%nQEmb
//	If nResto >0
//	   nQVol++
//	EndIf
	

	If nOpcao == 2
		aadd(aLbx,aClone(aLbx[nAt]))
		nAt := Len(aLbx)
	EndIf  
	

	aLbx[nAt,3] := str(nQtde,nT,nD)
	aLbx[nAt,4] := str(nQEmb,nT,nD) 
	aLbx[nAt,5] := str(nResto,nT,nD) 
	aLbx[nAt,6] := str(nQVol,nT,nD) 	
	aLbx[nAt,7] := cLote
	aLbx[nAt,8] := cNumSer  
	
EndIf

oLbx:SetArray( aLbx )
oLbx:bLine := {|| {Iif(aLbx[oLbx:nAt,1],oOk,oNo),aLbx[oLbx:nAt,2],aLbx[oLbx:nAt,3],aLbx[oLbx:nAt,4],aLbx[oLbx:nAt,5],aLbx[oLbx:nAt,6],aLbx[oLbx:nAt,7],aLbx[oLbx:nAt,8]}}
oLbx:Refresh()

For nMv := 1 To Len( aMvPar )
    &( "MV_PAR" + StrZero( nMv, 2, 0 ) ) := aMvPar[ nMv ]
Next nMv
Return .t.          

/////////////////////////////////////////////////////////////////////////
Static Function VldaLbx()                                                
/////////////////////////////////////////////////////////////////////////
Local cAlias := ""
Local nx
Local nMv
Local lRet := .T.

SB1->(DbSetOrder(1))
For nX := 1 to Len(aLbx)   
	cAlias := aLbx[nx,9]
	If aLbx[nx,1] .and. ! Empty(aLbx[nX,3])
		exit
	EndIf	
Next

If nX > len(aLbx)
	MsgAlert("Necessario marcar pelo menos um item com quantidade para imprimir!") //"Necessario marcar pelo menos um item com quantidade para imprimir!"
	Return .f.
EndIf      

aSvPar := {}

For nMv := 1 To 40
     aAdd( aSvPar, &( "MV_PAR" + StrZero( nMv, 2, 0 ) ) )
Next nMv

If cAlias == "SB1"
	If !VlLote()	
		lRet := .F.	
	EndIf
EndIf
	
Return (lRet)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณACDIWZ    บAutor  ณMicrosiga           บ Data ณ  05/27/13   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Imprime(cOrigem)                                          
Local cLocImp := MV_PAR01
Local nX 
Local cProduto
Local nQtde
Local nQE   
Local nQVol
Local nResto
Local cAliasOri
Local nRecno    
Local cLote
Local cNumId 
Local nMv
//Local cData		:= ""
//Local cData1	:= ""

If ! CBYesNo("Confirma a Impressao de Etiquetas","Aviso")  //"Confirma a Impressao de Etiquetas"###"Aviso"
	Return .f.
EndIf

If ! CB5SetImp(cLocImp)  
	MsgAlert("Local de Impressใo "+cLocImp+" nao Encontrado!") //"Local de Impressใo "###" nao Encontrado!"
	Return .f.
Endif	

For nMv := 1 To Len( aSvPar )
    &( "MV_PAR" + StrZero( nMv, 2, 0 ) ) := aSvPar[ nMv ]
Next nMv

SB1->(DbSetOrder(1))
For nX := 1 to Len(aLbx)                                                
	If ! aLbx[nx,1]
		Loop
	EndIf	
	cProduto:= aLbx[nx,2]                              
	
	nQtde	:= val(aLbx[nx,3])
	If Empty(nQtde)
		Loop
	EndIf	
	nQE			:= val(aLbx[nx,4])
	nResto		:= val(aLbx[nx,5])
	nQVol 		:= val(aLbx[nx,6])
	//If nResto > 0 
	//	nQVol--
	//EndIf	                 
	cLote	 		:= aLbx[nx,7] 
	cNumId		:= aLbx[nx,8]
	cAliasOri	:= aLbx[nx,9] 
	nRecno		:= aLbx[nx,10]  
//	cData			:= dtos(Posicione("SD1",1,xFilial("SD1")+cNota+cSerie,"D1_EMISSAO"))  //D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_COD+D1_ITEM
//	cData1      := (substr(cData,7,2)+"/"+substr(cData,5,2)+"/"+substr(cData,1,4))
		
	(cAliasOri)->(DbGoto(nRecno)) //posiciona na tabela de origem da informa็ใo           

 	U_GERAETIQ(cProduto,nQtde,nQE,nQVol,cNumId,cLote,cNota,cSerie,cOp) //cNota+cSerie+cForn+cLoja
	                                                    	
Next

MSCBCLOSEPRINTER()                 

Return .t.                             

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
User Function GERAETIQ(cProdr,nQtdee,nQee,nQVoll,cNumId,cLote,cNota,cSerie,cOp,cPedido,cOrdem,lExp,cTransp,cDesc,cOSReqMt)
////////////////////////////////////////////////////////////////////////                                                     

Local cCodBarra := ''    
Local cCodCliePr:= ''  
Local cPesoLiq	:= ''
Local cPesoBru	:= ''   
Local cUM		:= ''
DEFAULT cProdr  := ''
DEFAULT cNumId  := ''
DEFAULT cLote   := ''
DEFAULT cNota   := ''
DEFAULT cSerie  := ''
DEFAULT cOp     := ''  
DEFAULT nQtdee  := 0
DEFAULT nQee    := 0
DEFAULT nQVoll  := 0  
DEFAULT cPedido := ''
DEFAULT cOrdem  := ''    
DEFAULT lExp	:= .F.
DEFAULT cTransp := ''
DEFAULT cDesc	:= ''
DEFAULT cOSReqMt:= ''  

DBSELECTAREA('SB1')
DBSETORDER(1)		//B1_FILIAL+B1_COD
DBSEEK(xFilial('SB1')+cProdr)

If Empty(cDesc)
	cDesc 			:= SB1->B1_DESC  
EndIf

cUM				:= SB1->B1_UM 
//cDesc			:= STRTRAN(cDesc,'"','')
//cCodBarra		:= PADR(SB1->B1_CODBAR,15)                   
   
If EMPTY(cDesc)
	MsgAlert("A Descri็ใo auxiliar para o produto "+cProdr+" nao foi informada, impressao cancelada do item !")
	Return
EndIf

/*                                    
If EMPTY(cCodBarra)
	MsgAlert("Nao possui informacao para o codigo de barra do produto  "+cProdr+" verifique, inpressao sera cancelada !")
	Return
EndIf
*/
            
cCodBarra	:= PADR(cProdr,15)+PADR(cLote,10) 

For n := 1 to nQVoll
	
	If lExp                  
		MSCBInfoEti("OS/PROD: "+cOrdem+"/"+cProdr,"VOLUME")       	      
	Else
		MSCBInfoEti("OS/PROD: "+cOrdem+"/"+cProdr,"PRODUTO")       	      
	EndIf
	MSCBBEGIN(1,4)      
	
//	MSCBBOX(03,03,98,152,6)
	                   
  	  	MSCBSAY(03,04,'CODIGO: '						,"N", "C", "25")				//Codigo produto  		
  	  	MSCBSAY(18,03,alltrim(cProdr)					,"N", "C", "30") 				//Codigo produto  				

  	  	MSCBSAY(85,03,alltrim(cUM)						,"N", "C", "30") 			

		MSCBLineH(01,08,97,3)

// 	  	MSCBSAY(03,10,'Descricao:'						,"N", "C", "20")				//Descricao  		
  	  	MSCBSAY(03,10,Substr(cDesc,1,60)				,"N", "C", "25") 				//Descricao  		
// 	  	MSCBSAY(63,06,Substr(cDesc,42,41)				,"N", "B", "30")				//Descricao    

		MSCBSAY(03,14,'Lote: '							,"N", "C", "20")				//Codigo Lote 				
 	  	MSCBSAY(18,13,alltrim(cLote)					,"N", "C", "30")				//Codigo Lote   
 	  	
/* 	  	If cEmpAnt=='04' 
			MSCBSAY(55,14,'Validade: '						,"N", "C", "20")				//Validade
	 	  	MSCBSAY(70,13,DtoC(U_ACDRetVld(cProdr,cLote))	,"N", "C", "30")				//Dt. Validade
	 	EndIf
  */	  	
 	  	MSCBSAYBAR(03,19,cCodBarra				  		,"N", "C",08,.F.,.F.,.F., ,2,2,.F.)//CODIGO DE BARRA 	//3,2     
 	  	             
 	  	If cEmpAnt == '01'
		  	MSCBSAY(83,19,alltrim(If(cFilAnt == '01', "MTZ","CD"))  ,"N", "C", "25")	 
		EndIf
        
	  	If !lExp .And. !Empty(cProduto)
	  		MSCBSAY(88,19,"A" ,"N", "C", "30")	
	  	EndIf                                 
	  	
	  	If GetNewPar("ES_DIPINVE","0") == "1"
		  	MSCBSAY(83,23,"INV" ,"N", "C", "30")	
		EndIf
	  	
		If !Empty(cPedido) .And. !Empty(cOrdem)
			If !Empty(cTransp)
				MSCBSAY(03,28,"PEDIDO: "+cPedido+Space(2)+"ORD. SEPARACAO: "+cOrdem+Space(2)+"TRANSP: "+cTransp ,"N", "C", "25")   
			Else
			  	If cEmpAnt == "04" .And. !Empty(cOSReqMt)
			  		MSCBSAY(03,28,"REQUISIวรO: "+cPedido+Space(16)+"ORD. SEPARACAO: "+cOrdem ,"N", "C", "25")
			  	Else
			  		MSCBSAY(03,28,"PEDIDO: "+cPedido+Space(16)+"ORD. SEPARACAO: "+cOrdem ,"N", "C", "25")			  	
			  	EndIf	
			  	   
			EndIf
		EndIf

	MSCBEND()    
	
Next

return()   
                                
/*------------------------------------------------------------------------------------
*
* Fun็ใo:VerLoteId()           
* Desri็ใo: No double click do listbox nใo deixa imprimir o produto que 
*           nใo tiver lote 
*
------------------------------------------------------------------------------------*/
Static Function VerLoteId()

If Empty(aLbx[oLbx:nAt,7]) //Se Lote 
	MsgAlert("ษ necessแrio informar um lote valido no sistema !") 
Else
	aLbx[oLbx:nAt,1] := !aLbx[oLbx:nAt,1]
EndIf                                        

Return        
/*=====================================================================================
* Fun็ใo: VlLote()                                                    Data:21/05/2013
* Descri็ใo: Esta fun็ใo verificarแ se o lote digitado pelo usuแrio existe ou nใo
* no sistema, se nใo existi informa ao usuแrio e retornar falso para impressใo da etiq.
=====================================================================================*/
Static Function VlLote()
Local lRet := .F.

dbSelectArea("SB8")
SB8->(dbSetOrder(3))

If ! SB8->(DbSeek(xFilial('SB8')+aLbx[oLbx:nAt,2]+"01"+aLbx[oLbx:nAt,7]))	
	If Aviso("Aten็ใo","Lote ("+aLbx[oLbx:nAt,7]+") nใo encontrado."+CHR(10)+CHR(13)+"Deseja continuar?",{"Sim","Nใo"},1)==1
		Conout("Usuแrio confirmou lote ("+aLbx[oLbx:nAt,7]+") nใo encontrado - "+U_DipUsr())
		lRet := .T.
	EndIf
Else
	lRet := .T.
EndIf         

Return(lRet)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณACDIWZ    บAutor  ณMicrosiga           บ Data ณ  04/12/17   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function ACDRetVld(cProduto,cLote)
Local dDtVldRet  := StoD("")
Local cSQL 		 := ""
DEFAULT cProduto := "" 
DEFAULT cLote 	 := ""

cSQL := " SELECT TOP 1 "
cSQL += "	B8_DTVALID "
cSQL += "	FROM "
cSQL += 		RetSQLName("SB8")+" WITH(NOLOCK) "
cSQL += "		WHERE "                      

If cEmpAnt=="01"
	cSQL += "			B8_FILIAL IN('01','04') AND "
ElseIf cEmpAnt=="04" 
	cSQL += "			B8_FILIAL IN('01','02') AND "	
EndIf

cSQL += "			B8_PRODUTO = '"+cProduto+"' AND "
cSQL += "			B8_LOTECTL = '"+cLote+"' AND "
cSQL += "			D_E_L_E_T_ = ' ' "
cSQL += " ORDER BY R_E_C_N_O_ DESC "

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),"QRYSB8",.T.,.T.)  

TCSETFIELD("QRYSB8","B8_DTVALID","D",8,0)

If !QRYSB8->(Eof())
	dDtVldRet := QRYSB8->B8_DTVALID
EndIf
QRYSB8->(dbCloseArea())

Return dDtVldRet
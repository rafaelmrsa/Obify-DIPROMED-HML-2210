
#Include "PROTHEUS.Ch"

#DEFINE TAM_VALOR  20
#DEFINE TAM_CONTA    17
#DEFINE AJUST_CONTA  10

Static lFWCodFil := FindFunction("FWCodFil") 
Static cTpValor  := "D"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 � CTBR400  � Autor � Cicero J. Silva   	� Data � 04.08.06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Balancete Centro de Custo/Conta         			 		  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe	 � CTBR400()    											  ���
�������������������������������������������������������������������������Ĵ��
���Retorno	 � Nenhum       											  ���
�������������������������������������������������������������������������Ĵ��
���Uso 		 � SIGACTB      											  ���
�������������������������������������������������������������������������Ĵ��
���Parametros� Nenhum													  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function UCTBR400(cContaIni, cContaFim, dDataIni, dDataFim, cMoeda, cSaldos,;
				 cBook, lCusto, cCustoIni, cCustoFim, lItem, cItemIni, cItemFim,;
				 lClVl, cClvlIni, cClvlFim,lSaltLin,cMoedaDesc,aSelFil )


Local aArea := GetArea()
Local aCtbMoeda		:= {}

Local cArqTmp		:= "" 
Local lOk := .T.
Local lExterno		:= cContaIni <> Nil 
Local lImpRazR4		:= FindFunction( "TRepInUse" ) .And. TRepInUse()

Local lTodasFil 	:= .F.

PRIVATE cTipoAnt	:= ""
PRIVATE cPerg	 	:= "CTR400"
PRIVATE nomeProg  	:= "CTBR400"  
PRIVATE nSldTransp	:= 0 // Esta variavel eh utilizada para calcular o valor de transporte
PRIVATE oReport   
PRIVATE nLin		:= 0    
PRIVATE nLinha		:= 6  
PRIVATE nTipoRel    := 0
DEFAULT lCusto		:= .F.
DEFAULT lItem		:= .F.
DEFAULT lCLVL		:= .F.
DEFAULT lSaltLin	:= .T.
DEFAULT cMoedaDesc  := cMoeda // RFC - 18/01/07 | BOPS 103653
DEFAULT aSelFil		:= {}

cTpValor := Alltrim(GetMV("MV_TPVALOR"))

//CtAjustSx1('CTR400')

lOk := AMIIn(34)		// Acesso somente pelo SIGACTB
		
If lOk
	Pergunte("CTR400", .F.)
	If !lExterno
		lOk := Pergunte("CTR400", .T.)
	Endif
Endif

If lOk
	//Verifica se o relatorio foi chamado a partir de outro programa. Ex. CTBC400
	If !lExterno
		lCusto	:= Iif(mv_par12 == 1,.T.,.F.)
		lItem	:= Iif(mv_par15 == 1,.T.,.F.)
		lCLVL	:= Iif(mv_par18 == 1,.T.,.F.)
		// Se aFil nao foi enviada, exibe tela para selecao das filiais
		If lOk .And. mv_par36 == 1 .And. Len( aSelFil ) <= 0
				aSelFil := AdmGetFil(@lTodasFil)
	
			If Len( aSelFil ) <= 0
				lOk := .F.
			EndIf 
		EndIf
	Else  //Caso seja externo, atualiza os parametros do relatorio com os dados passados como parametros.
		mv_par01 := cContaIni
		mv_par02 := cContaFim
		mv_par03 := dDataIni
		mv_par04 := dDataFim
		mv_par05 := cMoeda
		mv_par06 := cSaldos
		mv_par07 := cBook
		mv_par12 := If(lCusto =.T.,1,2)
		mv_par13 := cCustoIni
		mv_par14 := cCustoFim
		mv_par15 := If(lItem =.T.,1,2)
		mv_par16 := cItemIni
		mv_par17 := cItemFim
		mv_par18 := If(lClVl =.T.,1,2)
		mv_par19 := cClVlIni
		mv_par20 := cClVlFim
		mv_par31 := If(lSaltLin==.T.,1,2)
		mv_par32 := 56
		mv_par34 := cMoedaDesc
	Endif
Endif   
	
//��������������������������������������������������������������Ŀ
//� Verifica se usa Set Of Books + Plano Gerencial (Se usar Plano�
//� Gerencial -> montagem especifica para impressao)			 �
//����������������������������������������������������������������
If ! ct040Valid(mv_par07) // Set Of Books
		lOk := .F.
EndIf 

If lOk .And. mv_par32 < 10
		ShowHelpDlg("MINQTDELIN", {"Valor informado inv�lido do","'Num. linhas p/ o raz�o'"},5,{"Favor preencher uma quantidade","m�nima de 10 linhas"},5)   
		lOk := .F.
EndIf

If lOk
    aCtbMoeda  	:= CtbMoeda(MV_PAR05) // Moeda?
    If Empty( aCtbMoeda[1] )
			Help(" ",1,"NOMOEDA")
		    lOk := .F.
		Endif
  
	IF lOk .And. ! Empty( mv_par34 )
			aCtbMoeddesc := CtbMoeda(mv_par34) // Moeda?

		    If Empty( aCtbMoeddesc[1] )
				Help(" ",1,"NOMOEDA")
			    lOk := .F.
			Endif
			aCtbMoeddesc := nil
		Endif
Endif 

If lOk
//	If lImpRazR4 
		CTBR400R4(aCtbMoeda,lCusto,lItem,lCLVL,@cArqTmp,aSelFil,lTodasFil )
/*	
	Else
		CTBR400R3( cContaIni, cContaFim, dDataIni, dDataFim, cMoeda, cSaldos,;
					cBook, lCusto, cCustoIni, cCustoFim, lItem, cItemIni, cItemFim,;
					lClVl, cClvlIni, cClvlFim,lSaltLin,cMoedaDesc,aSelFil ) // Executa vers�o anterior do fonte
	Endif                                                                                                      
*/						
Endif

If Select("cArqTmp") > 0
		dbSelectArea("cArqTmp")
		Set Filter To
		dbCloseArea()

		If Select("cArqTmp") == 0
			FErase(cArqTmp+GetDBExtension())
			FErase(cArqTmp+OrdBagExt())
		EndIf
EndIf	
RestArea(aArea)

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � CTBR400R4 � Autor �                    � Data �  15/09/09  ���
�������������������������������������������������������������������������͹��
���Descricao �Impressao do relatorio em R4                                ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Parametros�                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � SIGACTB                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function CTBR400R4(aCtbMoeda,lCusto,lItem,lCLVL,cArqTmp,aSelFil,lTodasFil )
	
oReport := ReportDef(aCtbMoeda,lCusto,lItem,lCLVL,@cArqTmp,aSelFil,lTodasFil)
oReport:PrintDialog()
             
oReport := Nil

Return


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � ReportDef � Autor � Cicero J. Silva    � Data �  01/08/06  ���
�������������������������������������������������������������������������͹��
���Descricao � Definicao do objeto do relatorio personalizavel e das      ���
���          � secoes que serao utilizadas                                ���
�������������������������������������������������������������������������͹��
���Parametros� aCtbMoeda  - Matriz ref. a moeda                           ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � SIGACTB                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function ReportDef(aCtbMoeda,lCusto,lItem,lCLVL,cArqTmp,aSelFil,lTodasFil)

Local oReport
Local oSection1
Local oSection1_1  
Local oSection1_2
Local oSection2
Local oSection3
Local cDesc1		:= "Este programa ir� imprimir o Raz�o Contabil,"
Local cDesc2		:= "de acordo com os parametros solicitados pelo"
Local cDesc3		:= "usuario."
Local titulo		:= "Emissao do Razao Contabil"
Local cNormal		:= ""

Local aTamConta	:= TAMSX3("CT1_CONTA")
Local aTamCusto	:=  TAMSX3("CT3_CUSTO")
Local nTamConta	:= Len(CriaVar("CT1_CONTA"))
Local nTamHist	:= If(cPaisLoc$"CHI|ARG",29,40)
Local nTamItem	:= Len(CriaVar("CTD_ITEM"))
Local nTamCLVL	:= Len(CriaVar("CTH_CLVL"))
Local nTamLote	:= Len(CriaVar("CT2_LOTE")+CriaVar("CT2_SBLOTE")+CriaVar("CT2_DOC")+CriaVar("CT2_LINHA"))
Local nTamData	:= 10

Local lAnalitico	:= If(mv_par08 == 1,.T.,.F.)

Local lPrintZero	:= IIf(mv_par30==1,.T.,.F.)// Imprime valor 0.00    ?
Local lSalto		:= Iif(mv_par21==1,.T.,.F.)// Salto de pagina                       �

Local cSayCusto		:= CtbSayApro("CTT")
Local cSayItem		:= CtbSayApro("CTD")
Local cSayClVl		:= CtbSayApro("CTH")

Local nDigitAte		:= 0
Local aSetOfBook 	:= CTBSetOf(mv_par07)// Set Of Books	
Local cPicture 		:= aSetOfBook[4]
Local cDescMoeda 	:= aCtbMoeda[2]
Local nDecimais 	:= DecimalCTB(aSetOfBook,mv_par05)// Moeda
Local nTamTransp    := 0
Local nTamFilial 	:= IIf( lFWCodFil, FWGETTAMFILIAL, TamSx3( "CT2_FILIAL" )[1] )
           

nTipoRel := mv_par08  // Tipo de Relatorio -> Analitico, Resumido ou Sintetico 

aTamCusto[1]	:= 25
nTamItem		:= 25
nTamCLVL		:= 25

If mv_par11 == 3 						//// SE O PARAMETRO DO CODIGO ESTIVER PARA IMPRESSAO
	nTamConta := Len(CT1->CT1_CODIMP)	//// USA O TAMANHO DO CAMPO CODIGO DE IMPRESSAO
Else
	If nTipoRel == 1 // se analitico 
		If (lCusto .Or. lItem .Or. lCLVL)
			nTamConta := 30						// Tamanho disponivel no relatorio para imprimir
		Else
			nTamConta := 40						// Tamanho disponivel no relatorio para imprimir
		Endif
	EndIf		
Endif
	
oReport := TReport():New(nomeProg,titulo,cPerg, {|oReport| ReportPrint(oReport,aCtbMoeda,aSetOfBook,cPicture,cDescMoeda,nDecimais,nTamConta,lAnalitico,lCusto,lItem,lCLVL,cArqTmp,aSelFil,lTodasFil)},cDesc1+cDesc2+cDesc3)

//Habilitado o parametro de personaliza��o por�m,
// n�o ser� permitido a altera��o das sections
IF GETNEWPAR("MV_CTBPOFF",.T.)
	oReport:SetEdit(.F.)
ENDIF
  
oReport:SetTotalInLine(.F.)
oReport:EndPage(.T.)

If nTipoRel == 1 // Analitico
	oReport:SetLandScape(.T.)
Else
	oReport:SetPortrait(.T.)
EndIf
	
// oSection1
oSection1 := TRSection():New(oReport,"Conta",{"cArqTmp"},/*aOrder*/,/*lLoadCells*/,/*lLoadOrder*/)	//"Conta"

If lSalto
	oSection1:SetPageBreak(.T.)
EndIf

TRCell():New(oSection1,"CONTA"	,"cArqTmp","CONTA",/*Picture*/,aTamConta[1],/*lPixel*/,/*{|| }*/)	//"CONTA"
TRCell():New(oSection1,"DESCCC"	,"cArqTmp","DESCRICAO",/*Picture*/,nTamConta+20,/*lPixel*/,/*{|| }*/)		//"DESCRICAO"
oSection1:SetReadOnly()
oSection1:SetEdit(.F.)
    
// oSection2
oSection2 := TRSection():New(oReport,"Custo",{"cArqTmp","CT2"},/*aOrder*/,/*lLoadCells*/,/*lLoadOrder*/)	//"Custo"
oSection2:SetHeaderPage(.T.)
oSection2:SetReadOnly()       
oSection2:SetEdit(.F.)

If nTipoRel == 3 // relatorio sintetico
	TRCell():New(oSection2,"DATAL"	,"cArqTmp","DATA",/*Picture*/,80,/*lPixel*/,/*{|| }*/,/*"LEFT"*/,,/*"LEFT"*/,,,.F.)	// "DATA"
Endif
	
TRCell():New(oSection2,"DOCUMENTO"	,""       ,"LOTE/SUB/DOC/LINHA",/*Picture*/,If(nTamLote < 20, 20,nTamLote),/*lPixel*/,{|| cArqTmp->LOTE+cArqTmp->SUBLOTE+cArqTmp->DOC+cArqTmp->LINHA },/*"LEFT"*/,,/*"LEFT"*/,,,.F.)// "LOTE/SUB/DOC/LINHA"
TRCell():New(oSection2,"HISTORICO"	,""		  ,"HISTORICO",/*Picture*/,nTamHist+2	,/*lPixel*/,{|| cArqTmp->HISTORICO},/*"LEFT"*/,.T.,/*"LEFT"*/,,,.F.)// "HISTORICO"	
TRCell():New(oSection2,"XPARTIDA"	,"cArqTmp","XPARTIDA",/*Picture*/,22,/*lPixel*/,/*{|| }*/,/*"LEFT"*/,,/*"LEFT"*/,,,.F.)// "XPARTIDA"
TRCell():New(oSection2,"Filial"		,""		  ,"Fil",/*Picture*/,4,/*lPixel*/,/*{|| }*/)// "FILIAL"
TRCell():New(oSection2,"CCUSTO"		,"cArqTmp",Upper(cSayCusto),/*Picture*/,aTamCusto[1],/*lPixel*/,{|| IIF(lCusto == .T.,cArqTmp->CCUSTO,Nil) },/*"LEFT"*/,,/*"LEFT"*/,,,.F.)// Centro de Custo
TRCell():New(oSection2,"ITEM"		,"cArqTmp",Upper(cSayItem) ,/*Picture*/,nTamItem,/*lPixel*/,{|| IIF(lItem == .T.,cArqTmp->ITEM,Nil) },/*"LEFT"*/,,/*"LEFT"*/,,,.F.)// Item Contabil
TRCell():New(oSection2,"CLVL"		,"cArqTmp",Upper(cSayClVl) ,/*Picture*/,nTamCLVL,/*lPixel*/,{|| IIF(lCLVL == .T.,cArqTmp->CLVL,Nil) },/*"LEFT"*/,,/*"LEFT"*/,,,.F.)// Classe de Valor
If cTpValor != "P"
	TRCell():New(oSection2,"CLANCDEB"	,"cArqTmp","DEBITO",/*Picture*/,TAM_VALOR,/*lPixel*/,{|| ValorCTB(cArqTmp->LANCDEB,,,TAM_VALOR,nDecimais,.F.,cPicture,"1",,,,,,lPrintZero,.F.) },/*"RIGHT"*/,,"CENTER",,,.F.)// "DEBITO"
	TRCell():New(oSection2,"CLANCCRD"	,"cArqTmp","CREDITO",/*Picture*/,TAM_VALOR,/*lPixel*/,{|| ValorCTB(cArqTmp->LANCCRD,,,TAM_VALOR,nDecimais,.F.,cPicture,"2",,,,,,lPrintZero,.F.) },/*"RIGHT"*/,,"CENTER",,,.F.)// "CREDITO"
	TRCell():New(oSection2,"CTPSLDATU"	,"cArqTmp","SALDO ATUAL",/*Picture*/,TAM_VALOR+2,/*lPixel*/,/*{|| }*/,/*"RIGHT"*/,,"CENTER",,,.F.)// "SALDO ATUAL"
Else
	TRCell():New(oSection2,"CLANCDEB"	,"cArqTmp","DEBITO",/*Picture*/,TAM_VALOR,/*lPixel*/,{|| ValorCTB(cArqTmp->LANCDEB,,,TAM_VALOR,nDecimais,.F.,cPicture,"1",,,,,,lPrintZero,.F.) },"RIGHT",,"RIGHT",,,.F.)// "DEBITO"
	TRCell():New(oSection2,"CLANCCRD"	,"cArqTmp","CREDITO",/*Picture*/,TAM_VALOR,/*lPixel*/,{|| ValorCTB(cArqTmp->LANCCRD,,,TAM_VALOR,nDecimais,.F.,cPicture,"2",,,,,,lPrintZero,.F.) },"RIGHT",,"RIGHT",,,.F.)// "CREDITO"
	TRCell():New(oSection2,"CTPSLDATU"	,"cArqTmp","SALDO ATUAL",/*Picture*/,TAM_VALOR+2,/*lPixel*/,/*{|| }*/,"RIGHT",,"RIGHT",,,.F.)// "SALDO ATUAL"
EndIf    
oSection2:Cell("DOCUMENTO"):lHeaderSize	:= .F.
oSection2:Cell("HISTORICO"):lHeaderSize	:= .F.
oSection2:Cell("XPARTIDA"):lHeaderSize	:= .F.
oSection2:Cell("FILIAL"):lHeaderSize	:= .F.
oSection2:Cell("CCUSTO"):lHeaderSize	:= .F.
oSection2:Cell("ITEM"):lHeaderSize		:= .F.
oSection2:Cell("CLVL"):lHeaderSize		:= .F.
oSection2:Cell("CLANCDEB"):lHeaderSize	:= .F.
oSection2:Cell("CLANCCRD"):lHeaderSize	:= .F.
oSection2:Cell("CTPSLDATU"):lHeaderSize	:= .F.     

If cPaisLoc $ "CHI|ARG"
	TRCell():New(oSection2,"SEGOFI"	,"cArqTmp","SEGOFI",/*Picture*/,TamSx3("CT2_SEGOFI")[1],/*lPixel*/,{|| cArqTmp->SEGOFI }) //"SEGOFI"
EndIf    


//*************************************************************
// Tratamento do campo SEGOFI para Chile e Argentina          *
// Caso o relatorio seja resumido imprime na coluna historico *
// Caso seja analitico imprime em uma nova coluna.            *
//*************************************************************

If cPaisLoc $ "CHI|ARG" .and. nTipoRel == 1 //Se for relatorio analitico

	oSection2:Cell("HISTORICO"):SetSize(29)
	oSection2:Cell("HISTORICO"):SetBlock( { || Subs(cArqTmp->HISTORICO,1,29)})

ElseIf cPaisLoc $ "CHI|ARG" .and. nTipoRel == 3 //Se for relatorio Sintetico

	oSection2:Cell("SEGOFI"):Hide()
	oSection2:Cell("SEGOFI"):HideHeader()

	oSection2:Cell("DOCUMENTO"):SetTitle("LOTE/SUB/DOC/LINHA" + " - " + "SEGOFI")
	oSection2:Cell("DOCUMENTO"):SetSize(oSection2:Cell("DOCUMENTO"):GetSize() + Len(CriaVar("CT2_SEGOFI")) )
 	oSection2:Cell("DOCUMENTO"):SetBlock( { || cArqTmp->LOTE+cArqTmp->SUBLOTE+cArqTmp->DOC+cArqTmp->LINHA+" - "+cArqTmp->SEGOFI } )
 	oSection2:Cell("HISTORICO"):SetBlock( { || Subs(cArqTmp->HISTORICO,1,40)})
EndIf      
        

//****************************************
// Oculta campos para relatorio resumido *
//****************************************

If nTipoRel == 3 // Sintetico

  	oSection2:Cell("DOCUMENTO"):Hide()
	oSection2:Cell("DOCUMENTO"):SetTitle('')

  	oSection2:Cell("HISTORICO"):Hide()
 	oSection2:Cell("HISTORICO"):SetTitle('')
  	oSection2:Cell("HISTORICO"):SetSize(0)	
                                                 
    oSection2:Cell("XPARTIDA"):Disable() 	 
    oSection2:Cell("FILIAL"):Disable() 	  	

EndIf  
                
If nTamFilial > 4 
	oSection2:Cell("FILIAL"):Disable()
Endif

// Inibir a coluna FILIAL do relatorio quando utiliza multi-filiais
                        
If nTipoRel == 2 // Resumido
	nTamTransp := oSection2:Cell("DOCUMENTO"):GetSize() + oSection2:Cell("HISTORICO"):GetSize();
	              + oSection2:Cell("FILIAL"):GetSize() + oSection2:Cell("XPARTIDA"):GetSize();  
	              + oSection2:Cell("CLANCDEB"):GetSize() + oSection2:Cell("CLANCCRD"):GetSize()	              
ElseIf nTipoRel == 1  // Analitico
	nTamTransp := oSection2:Cell("DOCUMENTO"):GetSize() + oSection2:Cell("HISTORICO"):GetSize();
	              + oSection2:Cell("FILIAL"):GetSize() + oSection2:Cell("XPARTIDA"):GetSize() + oSection2:Cell("CCUSTO"):GetSize();
	              + oSection2:Cell("ITEM"):GetSize() + oSection2:Cell("CLVL"):GetSize() + oSection2:Cell("CLANCDEB"):GetSize();
	              + oSection2:Cell("CLANCCRD"):GetSize()+5
Else //Sintetico
	nTamTransp := oSection2:Cell("DATAL"):GetSize() + (oSection2:Cell("CLANCDEB"):GetSize() * 3)
Endif   

//********************************
// Imprime linha saldo anterior  *
//********************************
           
//oSection1_1 - Totalizadores Conta               

oSection1_1 := TRSection():New(oReport,"Totalizadores da Conta",/*{"cArqTmp","CT2"}*/,/*aOrder*/,/*lLoadCells*/,/*lLoadOrder*/)

// Tamanho da coluna descri��o da se��o Section1_1
//nTamDesc := nTamData + nTamLote + nTamHist
nTamDesc := Len("CONTA - ")+nTamConta+65

TRCell():New(oSection1_1,"DESCRICAO","cArqTmp","",/*Picture*/,nTamDesc,/*lPixel*/,{|| })
TRCell():New(oSection1_1,"SALDOANT"	,"cArqTmp","",/*Picture*/,TAM_VALOR + 20,/*lPixel*/,{|| },"RIGHT",,"RIGHT")
oSection1_1:SetHeaderSection(.F.)  
oSection1_1:SetReadOnly()          
oSection1_1:SetEdit(.F.)

//oSection3 - Totalizadores Transporte

oSection3 := TRSection():New(oReport,"Totalizadores de Transporte",/*Alias*/,/*aOrder*/,/*lLoadCells*/,/*lLoadOrder*/,,,,,,.F.,,,)	//"Transporte"

TRCell():New(oSection3,"CTRANSP"	,/*Alias*/,/*titulo*/,/*Picture*/,nTamTransp,/*lPixel*/,/*{||}*/,,,,,,.F.)	
TRCell():New(oSection3,"CSLDATU"	,/*Alias*/,/*titulo*/,/*Picture*/,TAM_VALOR+2,/*lPixel*/,/*{||}*/,,,/*"RIGHT"*/,,,.F.)
oSection3:SetHeaderSection(.F.) 
oSection3:SetReadOnly()    
oSection3:SetEdit(.F.)

oSection3:Cell("CTRANSP"):lHeaderSize := .F.
oSection3:Cell("CSLDATU"):lHeaderSize := .F.   

oSection4 := TRSection():New(oReport,"Linha da Data",/*{"cArqTmp","CT2"}*/,/*aOrder*/,/*lLoadCells*/,/*lLoadOrder*/)  // Data

TRCell():New(oSection4,"DATAL"	,"cArqTmp","DATA",/*Picture*/,nTamData,/*lPixel*/,/*{|| }*/,/*"LEFT"*/,,/*"LEFT"*/,,,.F.)	// "DATA"
oSection4:SetHeaderSection(.F.)  
oSection4:SetReadOnly()  
oSection4:SetEdit(.F.)
     
oReport:ParamReadOnly() 


Return oReport

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ReportPrint� Autor � Cicero J. Silva    � Data �  14/07/06  ���
�������������������������������������������������������������������������͹��
���Descricao � Definicao do objeto do relatorio personalizavel e das      ���
���          � secoes que serao utilizadas                                ���
�������������������������������������������������������������������������͹��
���Parametros�                                                            ���
�������������������������������������������������������������������������͹��
���Uso       �                                                            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
����������������������������������������������������������������������������*/
Static Function ReportPrint(oReport,aCtbMoeda,aSetOfBook,cPicture,cDescMoeda,nDecimais,nTamConta,lAnalitico,lCusto,lItem,lCLVL,cArqTmp,aSelFil,lTodasFil)

Local oSection1 	:= oReport:Section(1)
Local oSection2		:= oReport:Section(2)
Local oSection1_1	:= oReport:Section(3)
Local oSection3		:= oReport:Section(4)    
Local oSection4		:= oReport:Section(5)

Local cFiltro		:= oSection2:GetAdvplExp()

Local cSayCusto		:= CtbSayApro("CTT")
Local cSayItem		:= CtbSayApro("CTD")
Local cSayClVl		:= CtbSayApro("CTH")    
Local aTamCusto		:= TAMSX3("CT3_CUSTO")

Local aSaldo		:= {}
Local aSaldoAnt		:= {}

Local cContaIni		:= mv_par01 // da conta
Local cContaFIm		:= mv_par02 // ate a conta 
Local cMoeda		:= mv_par05 // Moeda
Local cSaldo		:= mv_par06 // Saldos
Local cCustoIni		:= mv_par13 // Do Centro de Custo
Local cCustoFim		:= mv_par14 // At� o Centro de Custo
Local cItemIni		:= mv_par16 // Do Item 
Local cItemFim		:= mv_par17 // Ate Item 
Local cCLVLIni		:= mv_par19 // Imprime Classe de Valor?
Local cCLVLFim		:= mv_par20 // Ate a Classe de Valor
Local cContaAnt		:= ""
Local cDescConta	:= ""
Local cCodRes		:= ""
Local cResCC		:= ""
Local cResItem		:= ""
Local cResCLVL		:= ""
Local cDescSint		:= ""
Local cContaSint	:= ""
Local cNormal 		:= ""

Local xConta		:= ""

Local cSepara1		:= ""
Local cSepara2		:= ""
Local cSepara3		:= ""
Local cSepara4		:= ""
Local cMascara1		:= ""
Local cMascara2		:= ""
Local cMascara3		:= ""
Local cMascara4		:= ""

Local dDataAnt		:= CTOD("  /  /  ")
Local dDataIni		:= mv_par03 // da data
Local dDataFim		:= mv_par04 // Ate a data

Local nTotDeb		:= 0
Local nTotCrd		:= 0
Local nTotGerDeb	:= 0
Local nTotGerCrd	:= 0
Local nVlrDeb		:= 0
Local nVlrCrd		:= 0
Local nCont			:= 0
Local nTotTransp	:= 0

Local lNoMov		:= Iif(mv_par09==1,.T.,.F.) // Imprime conta sem movimento?
Local lSldAnt		:= Iif(mv_par09==3,.T.,.F.) // Imprime conta sem movimento?
Local lJunta		:= Iif(mv_par10==1,.T.,.F.) // Junta Contas com mesmo C.Custo?
Local lPrintZero	:= Iif(mv_par30==1,.T.,.F.) // Imprime valor 0.00    ?
Local lImpLivro		:= .t.
Local lImpTermos	:= .f.
Local lEmissUnica	:= If(GetNewPar("MV_CTBQBPG","M") == "M",.T.,.F.)			/// U=Quebra �nica (.F.) ; M=Multiplas quebras (.T.)
Local lSldAntCta	:= Iif(mv_par33 == 1, .T.,.F.)// Saldo Ant. nivel?Cta/C.C/Item/Cl.Vlr
Local lSldAntCC		:= Iif(mv_par33 == 2, .T.,.F.)// Saldo Ant. nivel?Cta/C.C/Item/Cl.Vlr
Local lSldAntIt  	:= Iif(mv_par33 == 3, .T.,.F.)// Saldo Ant. nivel?Cta/C.C/Item/Cl.Vlr
Local lSldAntCv  	:= Iif(mv_par33 == 4, .T.,.F.)// Saldo Ant. nivel?Cta/C.C/Item/Cl.Vlr

Local cMoedaDesc	:= iif( Empty( mv_par34 ) , cMoeda , mv_par34 ) // RFC - 18/01/07 | BOPS 103653
Local nMaxLin   	:= mv_par32 // Num.linhas p/ o Razao?

Local lResetPag		:= .T.
Local m_pag			:= 1 // controle de numera��o de pagina
Local l1StQb		:= .T.  
Local nPagIni		:= mv_par22
Local nPagFim		:= mv_par23
Local nReinicia		:= mv_par24
Local nBloco		:= 0
Local nBlCount		:= 1
Local cEspFil		:= ""
Local cFilSTR   	:= ""
Local cMasc 		:= ""
Local aMasc			:= {}
Local nMascFor		:= 0
Local nPosMV		:= 0
Local nAte	 		:= Len(alltrim(mv_par36))
Local nX    

aTamCusto[1] := 25

If oReport:GetOrientation() == 1 .or. nTipoRel > 1 // Resumido ou Sintetico     
    
   	nTransp :=  oSection2:Cell("DOCUMENTO"):GetSize() + oSection2:Cell("HISTORICO"):GetSize();
             + oSection2:Cell("FILIAL"):GetSize() + oSection2:Cell("XPARTIDA"):GetSize()+ oSection2:Cell("CLANCDEB"):GetSize();
	         + oSection2:Cell("CLANCCRD"):GetSize()+5
      
    If nTipoRel == 3
	   	nTransp := oSection2:Cell("DATAL"):GetSize() + (oSection2:Cell("CLANCDEB"):GetSize() * 3)
    Endif
    
	oSection3:Cell("CTRANSP"):SetSize(nTransp) 	
   	oSection2:Cell("CCUSTO"):Disable()	
  	oSection2:Cell("ITEM"):Disable()
  	oSection2:Cell("CLVL"):Disable()  

 	MsgAlert("Aten��o, as colunas das entidades Cl Valor, C.Custo e Item Cont�bil  n�o ser�o impressas no modo retrato ou na op��o Resumido") // "Aten��o, as colunas das entidades Cl Valor, C.Custo e Item Cont�bil  n�o ser�o impressas no modo retrato ou na op��o Resumido.")	  		 
 	
Endif     


// Mascara da Conta
cMascara1 := IIf (Empty(aSetOfBook[2]),GetMv("MV_MASCARA"),RetMasCtb(aSetOfBook[2],@cSepara1) )

If lCusto .Or. lItem .Or. lCLVL
	// Mascara do Centro de Custo
	cMascara2 := IIf ( Empty(aSetOfBook[6]),GetMv("MV_MASCCUS"),RetMasCtb(aSetOfBook[6],@cSepara2) )
	// Mascara do Item Contabil
	dbSelectArea("CTD")
	cMascara3 := IIf ( Empty(aSetOfBook[7]),GetMv("MV_MASCCTD"),RetMasCtb(aSetOfBook[7],@cSepara3) )
	// Mascara da Classe de Valor
	dbSelectArea("CTH")
	cMascara4 := IIf ( Empty(aSetOfBook[8]),GetMv("MV_MASCCTH"),RetMasCtb(aSetOfBook[8],@cSepara4) )
	
EndIf	 


//��������������������������������������������������������������Ŀ
//� Impressao de Termo / Livro                                   �
//����������������������������������������������������������������
Do Case
	Case mv_par29==1 ; lImpLivro:=.t. ; lImpTermos:=.f.
	Case mv_par29==2 ; lImpLivro:=.t. ; lImpTermos:=.t.
	Case mv_par29==3 ; lImpLivro:=.f. ; lImpTermos:=.t.
EndCase		

//��������������������������������������������������������������������������Ŀ
//�Titulo do Relatorio                                                       �
//����������������������������������������������������������������������������

If oReport:Title() == oReport:cRealTitle //If Type("NewHead")== "U" 
	IF nTipoRel == 1 //lAnalitico
		Titulo	:=	"RAZAO ANALITICO EM "	//
	ElseIf nTipoRel == 2 // Resumido
		Titulo	:=	"RAZAO RESUMIDO EM "	//"RAZAO RESUMIDO EM "
	Else  // Sintetico
		Titulo	:=	"RAZAO SINTETICO EM "	//"RAZAO SINTETICO EM "
	EndIf
	Titulo += 	cDescMoeda + "DE" + DTOC(dDataIni) +;	// "DE"
				"ATE" + DTOC(dDataFim) + CtbTitSaldo(mv_par06)	// "ATE"
Else
	Titulo := oReport:Title()  //NewHead
EndIf     

oReport:SetTitle(Titulo)   

oReport:SetCustomText( {|| CtCGCCabTR(,,,,,dDataFim,oReport:Title(),,,,,oReport,.T.,@lResetPag,@nPagIni,@nPagFim,@nReinicia,@m_pag,@nBloco,@nBlCount,.T.) } )

oSection1:OnPrintLine( {|| CTR400Maxl(@nMaxLin,.F.,.F.)} )	  
oSection1_1:OnPrintLine( {|| CTR400Maxl(@nMaxLin,.F.,.F.)} )	  
oSection2:OnPrintLine( {|| CTR400Maxl(@nMaxLin,.F.,.F.)} )	  
oSection4:OnPrintLine( {|| CTR400Maxl(@nMaxLin,.F.,.F.)} )	  

oReport:OnPageBreak( {|| CTR400Maxl(@nMaxLin,.T.,.F.) } )	 

If lImpLivro
	//��������������������������������������������������������������Ŀ
	//� Monta Arquivo Temporario para Impressao   					 �
	//����������������������������������������������������������������
	MsgMeter({|	oMeter, oText, oDlg, lEnd | CTBGerRaz(	oMeter,oText,oDlg,lEnd,@cArqTmp,cContaIni,cContaFim,cCustoIni,cCustoFim,;
							cItemIni,cItemFim,cCLVLIni,cCLVLFim,cMoeda,dDataIni,dDataFim,;
							aSetOfBook,lNoMov,cSaldo,lJunta,"1",lAnalitico,,,cFiltro,lSldAnt,aSelFil) },;
				"Criando Arquivo Tempor�rio...",;		// "Criando Arquivo Tempor�rio..."
				"Emissao do Razao")		// "Emissao do Razao"				

	dbSelectArea("cArqTmp")
	dbGoTop()

	oReport:SetMeter( RecCount() )
	oReport:NoUserFilter()

Endif

oBrkConta 	:= TRBreak():New( oSection2, { || cContaAnt }, OemToAnsi("T o t a i s  d a  C o n t a  ==> "), )
If cTpValor != "P"
	oTotDeb 	:= TRFunction():New( oSection2:Cell("CLANCDEB")	, ,"ONPRINT", oBrkConta,/*Titulo*/,cPicture,;
						{ || ValorCTB(nTotDeb  ,,,TAM_VALOR,nDecimais,.F.,cPicture,"1",,,,,,lPrintZero,.F.) },.F.,.F.,.F.,oSection2)

	oTotCred	:= TRFunction():New( oSection2:Cell("CLANCCRD")	, ,"ONPRINT", oBrkConta,/*Titulo*/,cPicture,;
						{ || ValorCTB(nTotCrd  ,,,TAM_VALOR,nDecimais,.F.,cPicture,"2",,,,,,lPrintZero,.F.) },.F.,.F.,.F.,oSection2)

	oTotTpSld2 	:= TRFunction():New( oSection2:Cell("CTPSLDATU")	, ,"ONPRINT", oBrkConta,/*Titulo*/,cPicture,;
						{ || ValorCTB(nSaldoAtu,,,TAM_VALOR-2,nDecimais,.T.,cPicture,cNormal,,,,,,lPrintZero,.F.)},.F.,.F.,.F.,oSection2)
Else
	oTotDeb 	:= TRFunction():New( oSection2:Cell("CLANCDEB")	, ,"ONPRINT", oBrkConta,/*Titulo*/,cPicture,;
						{ || PadL(ValorCTB(nTotDeb  ,,,TAM_VALOR,nDecimais,.F.,cPicture,"1",,,,,,lPrintZero,.F.),TAM_VALOR) },.F.,.F.,.F.,oSection2)
	
	oTotCred	:= TRFunction():New( oSection2:Cell("CLANCCRD")	, ,"ONPRINT", oBrkConta,/*Titulo*/,cPicture,;
						{ || PadL(ValorCTB(nTotCrd  ,,,TAM_VALOR,nDecimais,.F.,cPicture,"2",,,,,,lPrintZero,.F.),TAM_VALOR) },.F.,.F.,.F.,oSection2)
	
	oTotTpSld2 	:= TRFunction():New( oSection2:Cell("CTPSLDATU")	, ,"ONPRINT", oBrkConta,/*Titulo*/,cPicture,;
						{ || PadL(ValorCTB(nSaldoAtu,,,TAM_VALOR,nDecimais,.T.,cPicture,cNormal,,,,,,lPrintZero,.F.),TAM_VALOR+2)},.F.,.F.,.F.,oSection2)
EndIf
If oReport:nDevice != 4  //Condicao necessaria para evitar erros quando o relatorio e gerado em excel

// Apenas para contar as linhas
	oTotTpSld 	:= TRFunction():New( oSection2:Cell("HISTORICO")	, ,"ONPRINT", oBrkConta,/*Titulo*/,cPicture,;
					{ || CTR400Maxl(@nMaxLin,.F.,.T.) },.F.,.F.,.F.,oSection2)
Endif 


If lImpLivro .And. mv_par28 == 1	//Imprime total Geral

	oBrkEnd 	:= TRBreak():New( oReport, { || /*cArqTmp->(Eof())*/	}, OemToAnsi("T O T A L  G E R A L ==> "), )//"T O T A L  G E R A L  ==> "
	If cTpValor != "P"
		oTotGerDeb 	:= TRFunction():New( oSection2:Cell("CLANCDEB")	, ,"ONPRINT", oBrkEnd,/*Titulo*/,cPicture,;
					{ || ValorCTB(nTotGerDeb  ,,,TAM_VALOR,nDecimais,.F.,cPicture,"1",,,,,,lPrintZero,.F.) },.F.,.F.,.F.,oSection2)
		oTotGerCred	:= TRFunction():New( oSection2:Cell("CLANCCRD")	, ,"ONPRINT", oBrkEnd,/*Titulo*/,cPicture,;
					{ || ValorCTB(nTotGerCrd  ,,,TAM_VALOR,nDecimais,.F.,cPicture,"2",,,,,,lPrintZero,.F.) },.F.,.F.,.F.,oSection2)
	Else
		oTotGerDeb 	:= TRFunction():New( oSection2:Cell("CLANCDEB")	, ,"ONPRINT", oBrkEnd,/*Titulo*/,cPicture,;
					{ || PADL(ValorCTB(nTotGerDeb  ,,,TAM_VALOR,nDecimais,.F.,cPicture,"1",,,,,,lPrintZero,.F.),TAM_VALOR) },.F.,.F.,.F.,oSection2)
		oTotGerCred	:= TRFunction():New( oSection2:Cell("CLANCCRD")	, ,"ONPRINT", oBrkEnd,/*Titulo*/,cPicture,;
					{ || PADL(ValorCTB(nTotGerCrd  ,,,TAM_VALOR,nDecimais,.F.,cPicture,"2",,,,,,lPrintZero,.F.),TAM_VALOR) },.F.,.F.,.F.,oSection2)
	EndIf

EndIf

//����������������������������������������������Ŀ
//�Impressao do Saldo Anterior do Centro de Custo�
//������������������������������������������������
oSection1_1:Cell("DESCRICAO"):SetBlock( {|| xConta } )
oSection1_1:Cell("SALDOANT"):SetBlock( {|| "SALDO ANTERIOR: " + ValorCTB(aSaldoAnt[6],,,TAM_VALOR,nDecimais,.T.,cPicture,cNormal,,,,,,lPrintZero,.F.) } )//"SALDO ANTERIOR: "

oSection1_1:Cell("DESCRICAO"):HideHeader() 
oSection1_1:Cell("SALDOANT"):HideHeader() 

//Se tiver parametrizado com Plano Gerencial, exibe a mensagem que o Plano Gerencial 
//nao esta disponivel e sai da rotina.
If lImpLivro
	If cArqTmp->(EoF())              
		// Atencao ### "Nao existem dados para os par�metros especificados."
		Aviso("Aten��o","Nao existem dados para os par�metros especificados.",{"Ok"})
		oReport:CancelPrint()
		Return
	Else
		While lImpLivro .And. cArqTmp->(!Eof()) .And. !oReport:Cancel()
			//�������������������������������Ŀ
			//�INICIO DA 1a SECAO             �
			//���������������������������������
		    If oReport:Cancel()
		    	Exit
		    EndIf        
		   
			If lSldAntCC
				aSaldo    := SaldTotCT3(cCustoIni,cCustoFim,cArqTmp->CONTA,cArqTmp->CONTA,cArqTmp->DATAL,cMoeda,cSaldo,aSelFil)	
				aSaldoAnt := SaldTotCT3(cCustoIni,cCustoFim,cArqTmp->CONTA,cArqTmp->CONTA,dDataIni,cMoeda,cSaldo,aSelFil)
			ElseIf lSldAntIt
				aSaldo    := SaldTotCT4(cItemIni,cItemFim,cCustoIni,cCustoFim,cArqTmp->CONTA,cArqTmp->CONTA,cArqTmp->DATAL,cMoeda,cSaldo,aSelFil)	
				aSaldoAnt := SaldTotCT4(cItemIni,cItemFim,cCustoIni,cCustoFim,cArqTmp->CONTA,cArqTmp->CONTA,dDataIni,cMoeda,cSaldo,aSelFil)
			ElseIf lSldAntCv
				aSaldo    := SaldTotCTI(cClVlIni,cClVlFim,cItemIni,cItemFim,cCustoIni,cCustoFim,cArqTmp->CONTA,cArqTmp->CONTA,cArqTmp->DATAL,cMoeda,cSaldo,aSelFil)	
				aSaldoAnt := SaldTotCTI(cClVlIni,cClVlFim,cItemIni,cItemFim,cCustoIni,cCustoFim,cArqTmp->CONTA,cArqTmp->CONTA,dDataIni,cMoeda,cSaldo,aSelFil)
			Else 					
				aSaldo 		:= SaldoCT7Fil(cArqTmp->CONTA,cArqTmp->DATAL,cMoeda,cSaldo,,,,aSelFil,,lTodasFil)	
				aSaldoAnt	:= SaldoCT7Fil(cArqTmp->CONTA,dDataIni,cMoeda,cSaldo,"CTBR400",,,aSelFil,,lTodasFil)	
			EndIf

			If f180Fil(lNoMov,aSaldo,dDataIni,dDataFim)
				dbSkip()
				Loop
			EndIf

			// Conta Sintetica	
			cContaSint := Ctr400Sint(cArqTmp->CONTA,@cDescSint,cMoeda,@cDescConta,@cCodRes,cMoedaDesc)
			cNormal := CT1->CT1_NORMAL
			
 			oSection1:Cell("DESCCC"):SetBlock( { || " - " + cDescSint } )  
			oSection1:Cell("DESCCC"):SetSize(LEN(cDescSint)+3)
			If mv_par11 == 3
				oSection1:Cell("CONTA" ):SetBlock( { || EntidadeCTB(CT1->CT1_CODIMP,0,0,nTamConta,.F.,cMascara1,cSepara1,,,,,.F.) } )
			Else
				oSection1:Cell("CONTA" ):SetBlock( { || EntidadeCTB(cContaSint,0,0,Len(cContaSint),.F.,cMascara1,cSepara1,,,,,.F.) } )
			Endif

			oSection3:Cell("CTRANSP"):SetBlock( { || Iif(nLinha == 7,  "DE TRANSPORTE :", "A TRANSPORTAR :")}) 
			oSection3:Cell("CSLDATU"):SetBlock( { || ValorCTB(nSldTransp,,,TAM_VALOR-2,nDecimais,.T.,cPicture,cNormal,,,,,,lPrintZero,.F.) })  
 			
                  
			//�������������������������������Ŀ
			//�INICIO DA IMPRESSAO DA 1A SECAO�
			//���������������������������������
    	 	oSection1:Init() 
	     	oSection1:PrintLine() 
		    oSection1:Finish()  

			xConta := "CONTA - "	 //"CONTA - "	

			If mv_par11 == 1							// Imprime Cod Normal
				xConta += EntidadeCTB(cArqTmp->CONTA,0,0,nTamConta,.F.,cMascara1,cSepara1,,,,,.F.)
			Else
				dbSelectArea("CT1")
				dbSetOrder(1)
				MsSeek(xFilial("CT1")+cArqTMP->CONTA,.F.)
				If mv_par11 == 3						// Imprime Codigo de Impressao
					xConta += EntidadeCTB(CT1->CT1_CODIMP,0,0,nTamConta,.F.,cMascara1,cSepara1,,,,,.F.)
				Else										// Caso contr�rio usa codigo reduzido
					xConta += EntidadeCTB(CT1->CT1_RES,0,0,nTamConta,.F.,cMascara1,cSepara1,,,,,.F.)
				EndIf
			
				cDescConta := &("CT1->CT1_DESC" + cMoedaDesc )
			Endif

			If nTipoRel == 3 // Resumido 
				xConta +=  " - " + Left(cDescConta,30)
			Else
				xConta +=  " - " + Left(cDescConta,40)
			Endif

			oSection1_1:Init()
	     	oSection1_1:PrintLine()
		    oSection1_1:Finish()
		
			nSaldoAtu := aSaldoAnt[6]                                           
			//���������������Ŀ
			//�FIM DA 1a SECAO�
			//�����������������


			//������������������Ŀ
			//�INICIO DA 2a SECAO�
			//��������������������
			dbSelectArea("cArqTmp")
			cContaAnt:= cArqTmp->CONTA
			dDataAnt	:= CTOD("  /  /  ")
			oSection2:Init()                            
			
			Do While cArqTmp->(!Eof() .And. CONTA == cContaAnt ) .And. !oReport:Cancel()   

			    If oReport:Cancel()
			    	Exit
			    EndIf        
				
				If dDataAnt <> cArqTmp->DATAL   
				
					If mv_par08 == 3
						If ( cArqTmp->LANCDEB <> 0 .Or. cArqTmp->LANCCRD <> 0 )
							oSection2:Cell("DATAL"):SetBlock( { || dDataAnt } )
						Endif	
					Else
						oSection4:Init()
					    oSection4:PrintLine()  
					    oSection4:Finish()
					Endif
							
					dDataAnt := cArqTmp->DATAL    
				EndIf	
				
				If mv_par08 < 3 //Se for relatorio analitico ou resumido  				
   					
					nSaldoAtu 	:= nSaldoAtu - cArqTmp->LANCDEB + cArqTmp->LANCCRD
					nTotDeb		+= cArqTmp->LANCDEB
					nTotCrd		+= cArqTmp->LANCCRD
					nTotGerDeb	+= cArqTmp->LANCDEB
					nTotGerCrd	+= cArqTmp->LANCCRD			
					
					dbSelectArea("cArqTmp")				
	   					   				
					If mv_par11 == 1 // Impr Cod (Normal/Reduzida/Cod.Impress)
						oSection2:Cell("XPARTIDA"):SetBlock( { || EntidadeCTB(cArqTmp->XPARTIDA,0,0,nTamConta,.F.,cMascara1,cSepara1,,,,,.F.) } )
					ElseIf mv_par11 == 3
						oSection2:Cell("XPARTIDA"):SetBlock( { || EntidadeCTB(CT1->CT1_CODIMP,0,0,nTamConta,.F.,cMascara1,cSepara1,,,,,.F.) } )
					Else
						dbSelectArea("CT1")
						dbSetOrder(1)
						MsSeek(xFilial("CT1")+cArqTmp->XPARTIDA,.F.)
						oSection2:Cell("XPARTIDA"):SetBlock( { || EntidadeCTB(CT1->CT1_RES,0,0,TAM_CONTA,.F.,cMascara1,cSepara1,,,,,.F.) } )
					Endif
					
					oSection2:Cell("Filial"):SetBlock( { || cArqTmp->FILORI } )
					
					If lCusto
						If mv_par25 == 1 //Imprime Cod. Centro de Custo Normal 
							oSection2:Cell("CCUSTO"):SetBlock( { || EntidadeCTB(cArqTmp->CCUSTO,0,0,25,.F.,cMascara2,cSepara2,,,,,.F.) } )
						Else 
							dbSelectArea("CTT")
							dbSetOrder(1)
							dbSeek(xFilial("CTT")+cArqTmp->CCUSTO)				
							cResCC := CTT->CTT_RES
							oSection2:Cell("CCUSTO"):SetBlock( { || EntidadeCTB(cResCC,0,0,25,.F.,cMascara2,cSepara2,,,,,.F.) } )
							dbSelectArea("cArqTmp")
						Endif                                                       
					Endif
					If lItem 						//Se imprime item 
						If mv_par26 == 1 //Imprime Codigo Normal Item Contabl
							oSection2:Cell("ITEM"):SetBlock( { || EntidadeCTB(cArqTmp->ITEM,0,0,25,.F.,cMascara3,cSepara3,,,,,.F.) } )
						Else
							dbSelectArea("CTD")
							dbSetOrder(1)
							dbSeek(xFilial("CTD")+cArqTmp->ITEM)				
							cResItem := CTD->CTD_RES
							oSection2:Cell("ITEM"):SetBlock( { || EntidadeCTB(cResItem,0,0,25,.F.,cMascara3,cSepara3,,,,,.F.) } )
							dbSelectArea("cArqTmp")					
						Endif
					Endif
					If lCLVL //Se imprime classe de valor
						If mv_par27 == 1 //Imprime Cod. Normal Classe de Valor
							oSection2:Cell("CLVL"):SetBlock( { || EntidadeCTB(cArqTmp->CLVL,0,0,25,.F.,cMascara4,cSepara4,,,,,.F.) } )
						Else
							dbSelectArea("CTH")
							dbSetOrder(1)
							dbSeek(xFilial("CTH")+cArqTmp->CLVL)				
							cResClVl := CTH->CTH_RES						
							oSection2:Cell("CLVL"):SetBlock( { || EntidadeCTB(cResClVl,0,0,25,.F.,cMascara4,cSepara4,,,,,.F.) } )
							dbSelectArea("cArqTmp")					
						Endif			
					Endif

					oSection2:Cell("CTPSLDATU"):SetBlock( { || ValorCTB(nSaldoAtu,,,TAM_VALOR-2,nDecimais,.T.,cPicture,cNormal,,,,,,lPrintZero,.F.) } )
			    
			     	oSection2:PrintLine() 
			     	
					nSldTransp := nSaldoAtu // Valor a Transportar - 1

				    oReport:IncMeter()

					// Procura complemento de historico e imprime
				  	ImpCompl( oSection2 ) // oReport)
			        
					dbSkip()
			
				Else      // -- Se for sintetico                               			
					
					dbSelectArea("cArqTmp")
					
					While dDataAnt == cArqTmp->DATAL .And. cContaAnt == cArqTmp->CONTA
						nVlrDeb	+= cArqTmp->LANCDEB		                                         
						nVlrCrd	+= cArqTmp->LANCCRD		                                         
						nTotGerDeb	+= cArqTmp->LANCDEB
						nTotGerCrd	+= cArqTmp->LANCCRD			
						dbSkip()
					EndDo
					
					nSaldoAtu	:= nSaldoAtu - nVlrDeb + nVlrCrd
				  	oSection2:Cell("CLANCDEB"):SetBlock( { || ValorCTB(nVlrDeb,,,TAM_VALOR,nDecimais,.F.,cPicture,"1",,,,,,lPrintZero,.F.) })// Debito
				  	oSection2:Cell("CLANCCRD"):SetBlock( { || ValorCTB(nVlrCrd,,,TAM_VALOR,nDecimais,.F.,cPicture,"2",,,,,,lPrintZero,.F.) })// Credito
					oSection2:Cell("CTPSLDATU"):SetBlock( { || ValorCTB(nSaldoAtu,,,TAM_VALOR-2,nDecimais,.T.,cPicture,cNormal,,,,,,lPrintZero,.F.) })// Sinal do Saldo Atual => Consulta Razao

					//Imprime Section(1) - resumida.
			     	oSection2:PrintLine()
				    oReport:IncMeter()

					nSldTransp := nSaldoAtu // Valor a Transportar  

					nTotDeb		+= nVlrDeb
					nTotCrd		+= nVlrCrd         
					nVlrDeb	:= 0
					nVlrCrd	:= 0
				Endif // lAnalitico	 
					   			
			EndDo //cArqTmp->(!Eof()) .And. cArqTmp->CONTA == cContaAnt

 			oSection2:Finish()   
 		
           	nSldTransp  := 0
			nSaldoAtu   := 0
			nTotDeb	    := 0
			nTotCrd	    := 0                              
 			
			//���������������Ŀ
			//�FIM DA 2a SECAO�
			//�����������������
	
		EndDo //lImpLivro .And. !cArqTmp->(Eof()) 
	EndIf //!(cArqTmp->(RecCount()) == 0 .And. !Empty(aSetOfBook[5]))
EndIf // lImpLivro

//���������������������Ŀ
//�Impressao dos Termos �
//�����������������������
If lImpTermos 							// Impressao dos Termos
	//Inibido cabe�alho na impressao dos termos
	oReport:HideHeader()
	oSection2:Hide()	
	oSection2:SetHeaderPage(.F.) // Desabilita a impressao 
	
	cArqAbert:=GetNewPar("MV_LRAZABE","")
	cArqEncer:=GetNewPar("MV_LRAZENC","")
	
    If Empty(cArqAbert)
		ApMsgAlert(	"Devem ser criados os parametros MV_LRAZABE e MV_LRAZENC. " +; //"Devem ser criados os parametros MV_LRAZABE e MV_LRAZENC. "
					"Utilize como base o parametro MV_LDIARAB.") //"Utilize como base o parametro MV_LDIARAB."
	Endif
Endif

If lImpTermos .And. ! Empty(cArqAbert)	
	dbSelectArea("SM0")
	aVariaveis:={}

	For nCont:=1 to FCount()	
		If FieldName(nCont)=="M0_CGC"
			AADD(aVariaveis,{FieldName(nCont),Transform(FieldGet(nCont),"@R 99.999.999/9999-99")})
		Else
            If FieldName(nCont)=="M0_NOME"
                Loop
            EndIf
			AADD(aVariaveis,{FieldName(nCont),FieldGet(nCont)})
		Endif
	Next

	dbSelectArea("SX1")
	dbSeek( padr( "CTR400" , Len( X1_GRUPO ) , ' ' ) + "01" )
	While ! Eof() .And. SX1->X1_GRUPO  == padr( "CTR400" , Len( X1_GRUPO ) , ' ' )
		AADD(aVariaveis,{Rtrim(Upper(X1_VAR01)),&(X1_VAR01)})
		dbSkip()
	End

	If AliasIndic( "CVB" )
		dbSelectArea( "CVB" )
		CVB->(dbSeek( xFilial( "CVB" ) ))
		For nCont:=1 to FCount()
			If FieldName(nCont)=="CVB_CGC"
				AADD(aVariaveis,{FieldName(nCont),Transform(FieldGet(nCont),"@R 99.999.999/9999-99")})
			ElseIf FieldName(nCont)=="CVB_CPF"
				AADD(aVariaveis,{FieldName(nCont),Transform(FieldGet(nCont),"@R 999.999.999-99")})
			Else
				AADD(aVariaveis,{FieldName(nCont),FieldGet(nCont)})
			Endif
		Next
	EndIf

	AADD(aVariaveis,{"M_DIA",StrZero(Day(dDataBase),2)})
	AADD(aVariaveis,{"M_MES",MesExtenso()})
	AADD(aVariaveis,{"M_ANO",StrZero(Year(dDataBase),4)})

	If !File(cArqAbert)
		aSavSet:=__SetSets()
		cArqAbert:=CFGX024(,"Raz�o") // Editor de Termos de Livros
		__SetSets(aSavSet)
		Set(24,Set(24),.t.)
	Endif

	If !File(cArqEncer)
		aSavSet:=__SetSets()
		cArqEncer:=CFGX024(,"Raz�o") // Editor de Termos de Livros
		__SetSets(aSavSet)
		Set(24,Set(24),.t.)
	Endif

	If cArqAbert#NIL
		oReport:EndPage()
		ImpTerm2(cArqAbert,aVariaveis,,,,oReport)
	Endif
	If cArqEncer#NIL
		oReport:EndPage()
		ImpTerm2(cArqEncer,aVariaveis,,,,oReport)
	Endif	 
Endif

dbselectArea("CT2")
If !Empty(dbFilter())
	dbClearFilter()
Endif

Return

/*��������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �CTR400MaxL�Autor  �                    � Data �  25/05/09   ���
�������������������������������������������������������������������������͹��
���Desc.     �														      ���
���          �						                                      ���
�������������������������������������������������������������������������͹��
���Uso       � CTBR400                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/

Static Function CTR400MaxL(nMaxLin, lQuebra, lTotConta) 
Local oSection1 	:= oReport:Section(1)
Local oSection2		:= oReport:Section(2)
Local oSection1_1	:= oReport:Section(3)
Local oSection3		:= oReport:Section(4)    
Local oSection4		:= oReport:Section(5)

Local lSalLin 		:= IIf(mv_par31==1,.T.,.F.)//"Salta linha entre contas?"  
   
If lQuebra
	nLinha := 6 
Endif          
   
If lTotConta
	nLinha += 3
	nSldTransp := 0	 
Endif

If oSection1:Printing()
	If lSalLin
		nLinha += 2
	Else 
		nLinha += 1
	Endif           
Endif	

If oSection2:Printing()
	nLinha += 1
Endif

If oSection1_1:Printing()  .Or. oSection4:Printing()
	nLinha += 2
Endif 

If nLinha > nMaxLin

	If nSldTransp != 0
		oSection3:Init()
		oSection3:PrintLine()
		oReport:EndPage()
		
		nLinha := 7
		oSection3:PrintLine()
		oReport:SkipLine()
		oSection3:Finish()	
    Else
    	oReport:EndPage()
    	nLinha := 6
    Endif	
Endif          
  
Return Nil
      

/*��������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ImpCompl  �Autor  �Cicero J. Silva     � Data �  27/07/06   ���
�������������������������������������������������������������������������͹��
���Desc.     �Retorna a descricao, da conta contabil, item, centro de     ���
���          �custo ou classe valor                                       ���
�������������������������������������������������������������������������͹��
���Uso       � CTBR390                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/

Static Function ImpCompl(oSection2)
 //	oSection2:Cell("DATAL"		):Hide()
	oSection2:Cell("DOCUMENTO"	):Hide()
 	oSection2:Cell("XPARTIDA"	):Hide()
	oSection2:Cell("CCUSTO"		):Hide()
	oSection2:Cell("ITEM"		):Hide()
	oSection2:Cell("CLVL"		):Hide()
	oSection2:Cell("CLANCDEB"	):Hide()
	oSection2:Cell("CLANCCRD"	):Hide()
	oSection2:Cell("CTPSLDATU"	):Hide()
	oSection2:Cell("FILIAL"		):Hide()
	
	// Procura pelo complemento de historico
	dbSelectArea("CT2")               
	dbSetOrder(10)
	If MsSeek(cArqTMP->(FILIAL+DTOS(DATAL)+LOTE+SUBLOTE+DOC+SEQLAN+EMPORI+FILORI),.F.)
		dbSkip()

		If CT2->CT2_DC == "4"			//// TRATAMENTO PARA IMPRESSAO DAS CONTINUACOES DE HISTORICO
			While !CT2->(Eof()) .And.;
					CT2->CT2_FILIAL == cArqTMP->FILIAL .And.;
					 CT2->CT2_LOTE == cArqTMP->LOTE .And.;
					  CT2->CT2_SBLOTE == cArqTMP->SUBLOTE .And.;
					   CT2->CT2_DOC == cArqTmp->DOC .And.;
						CT2->CT2_SEQLAN == cArqTmp->SEQLAN .And.;
						 CT2->CT2_EMPORI == cArqTmp->EMPORI .And.;
						  CT2->CT2_FILORI == cArqTmp->FILORI .And.;
						   CT2->CT2_DC == "4" .And.;
				    	    DTOS(CT2->CT2_DATA) == DTOS(cArqTmp->DATAL)

		   		oSection2:Cell("HISTORICO"):SetBlock({|| CT2->CT2_HIST } )
				oSection2:Printline()

				CT2->(dbSkip())			
			EndDo	
		EndIf
	EndIf                  

 	oSection2:Cell("HISTORICO"):SetBlock( { || cArqTmp->HISTORICO } )

//	oSection2:Cell("DATAL"		):Show()
	oSection2:Cell("DOCUMENTO"	):Show()
  	oSection2:Cell("XPARTIDA"	):Show()
	oSection2:Cell("CCUSTO"		):Show()
	oSection2:Cell("ITEM"		):Show()
	oSection2:Cell("CLVL"		):Show()
	oSection2:Cell("CLANCDEB"	):Show()
	oSection2:Cell("CLANCCRD"	):Show()
	oSection2:Cell("CTPSLDATU"	):Show()   
	oSection2:Cell("FILIAL"		):Show()

	dbSelectArea("cArqTmp")

Return 

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �f180Fil   �Autor  �Cicero J. Silva     � Data �  24/07/06   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � CTBR400                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Static Function f180Fil(lNoMov,aSaldo,dDataIni,dDataFim)

Local lDeixa	:= .F.

	If !lNoMov //Se imprime conta sem movimento
		If aSaldo[6] == 0 .And. cArqTmp->LANCDEB ==0 .And. cArqTmp->LANCCRD == 0 
			lDeixa	:= .T.
		Endif	
	Endif             
	
	If lNoMov .And. aSaldo[6] == 0 .And. cArqTmp->LANCDEB ==0 .And. cArqTmp->LANCCRD == 0 
		If CtbExDtFim("CT1") 			
			dbSelectArea("CT1") 
			dbSetOrder(1) 
			If MsSeek(xFilial()+cArqTmp->CONTA)
				If !CtbVlDtFim("CT1",dDataIni) 		
					lDeixa	:= .T.
	            EndIf                                   
	            
	            If !CtbVlDtIni("CT1",dDataFim)
					lDeixa	:= .T.
	            EndIf                                   

		    EndIf
		EndIf
	EndIf

	dbSelectArea("cArqTmp")

Return (lDeixa)

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � CTBR400R3� Autor � Pilar S. Albaladejo   � Data � 05.02.01 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Emiss�o do Raz�o                                           ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � CTBR400R3()                                                ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � Nenhum                                                     ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
�������������������������������������������������������������������������Ĵ��
���Parametros� Nenhum                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function CTBR400R3(	cContaIni, cContaFim, dDataIni, dDataFim, cMoeda, cSaldos,;
					cBook, lCusto, cCustoIni, cCustoFim, lItem, cItemIni, cItemFim,;
					lClVl, cClvlIni, cClvlFim,lSaltLin,cMoedaDesc,aSelFil )

Local aCtbMoeda	:= {}
Local WnRel			:= "CTBR400"
Local cDesc1		:= "Este programa ir� imprimir o Raz�o Contabil,"	//"Este programa ir� imprimir o Raz�o Contabil,"
Local cDesc2		:= "de acordo com os parametros solicitados pelo"	// "de acordo com os parametros solicitados pelo"
Local cDesc3		:= "usuario."	// "usuario."
Local cString		:= "CT2"
Local titulo		:= "Emissao do Razao Contabil" 	//"Emissao do Razao Contabil"
Local lAnalitico 	:= .T.
Local lRet			:= .T.
Local lExterno		:= cContaIni <> Nil
Local nTamLinha	:= 220
Local nTamConta		:= 22
//Local nTamConta		:= Len(CriaVar ("CT1_CONTA"))
Local cSepara1		:= ""

DEFAULT lCusto		:= .F.
DEFAULT lItem		:= .F.
DEFAULT lCLVL		:= .F.
DEFAULT lSaltLin	:= .T.
DEFAULT cMoedaDesc  := cMoeda
DEFAULT aSelFil 		:= {}

Private aReturn	:= { "Zebrado", 1,"Administracao", 2, 2, 1, "", 1 }  //"Zebrado"###"Administracao"
Private nomeprog	:= "CTBR400"
Private aLinha		:= {}
Private nLastKey	:= 0
Private cPerg		:= "CTR400"
Private Tamanho 	:= "G"
Private lSalLin		:= .T.

lAnalitico	:= ( mv_par08 == 1 )
nTamLinha	:= If( lAnalitico, 220, 132)  

//��������������������������������������������������������������Ŀ
//� Verifica se usa Set Of Books -> Conf. da Mascara / Valores   �
//����������������������������������������������������������������
aSetOfBook := CTBSetOf(mv_par07)

//�������������������������������Ŀ
//�Carrega as informacoes da moeda�
//���������������������������������
aCtbMoeda  	:= CtbMoeda(MV_PAR05)

// Mascara da Conta
If Empty(aSetOfBook[2])
	cMascara1 := GetMv("MV_MASCARA")
Else
	cMascara1	:= RetMasCtb(aSetOfBook[2],@cSepara1)
	//A mascara sera considerada no tamanho da conta somente com a mascara da configuracao de livros. 
	//Quando nao tiver configuracao de livros, o relatorio podera ser impresso em formato retrato e, caso 
	//nao haja espaco para a impressao do codigo da conta (contra-partida), esse codigo sera truncado.
	nTamConta	:= nTamConta+Len(ALLTRIM(cSepara1))	
EndIf               

If (lAnalitico .And. (!lCusto .And. !lItem .And. !lCLVL) .And. nTamConta <= 22) .Or. ! lAnalitico 
	Tamanho := "M"
	nTamLinha := 132
EndIf	

wnrel := SetPrint(cString,wnrel,,@titulo,cDesc1,cDesc2,cDesc3,.F.,"",,Tamanho)

If nLastKey = 27
	Set Filter To
	Return
Endif

SetDefault(aReturn,cString)

If nLastKey = 27
	Set Filter To
	Return
Endif

RptStatus({|lEnd| CTR400Imp(@lEnd,wnRel,cString,aSetOfBook,lCusto,lItem,lCLVL,;
	   	lAnalitico,Titulo,nTamlinha,aCtbMoeda, nTamConta,aSelFil)})
Return 

/*/
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
��� Fun��o    �CTR400Imp � Autor � Pilar S. Albaladejo   � Data � 05/02/01 ���
��������������������������������������������������������������������������Ĵ��
��� Descri��o � Impressao do Razao                                         ���
��������������������������������������������������������������������������Ĵ��
��� Sintaxe   �Ctr400Imp(lEnd,wnRel,cString,aSetOfBook,lCusto,lItem,;      ���
���           �          lCLVL,Titulo,nTamLinha,aCtbMoeda)                 ���
��������������������������������������������������������������������������Ĵ��
��� Retorno   �Nenhum                                                      ���
��������������������������������������������������������������������������Ĵ��
��� Uso       � SIGACTB                                                    ���
��������������������������������������������������������������������������Ĵ��
���Parametros � lEnd       - A�ao do Codeblock                             ���
���           � wnRel      - Nome do Relatorio                             ���
���           � cString    - Mensagem                                      ���
���           � aSetOfBook - Array de configuracao set of book             ���
���           � lCusto     - Imprime Centro de Custo?                      ���
���           � lItem      - Imprime Item Contabil?                        ���
���           � lCLVL      - Imprime Classe de Valor?                      ��� 
���           � Titulo     - Titulo do Relatorio                           ���
���           � nTamLinha  - Tamanho da linha a ser impressa               ��� 
���           � aCtbMoeda  - Moeda                                         ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������
/*/
Static Function CTR400Imp(lEnd,WnRel,cString,aSetOfBook,lCusto,lItem,lCLVL,lAnalitico,Titulo,nTamlinha,aCtbMoeda,nTamConta,aSelFil)

//��������������������������������������������������������������Ŀ
//� Define Variaveis                                             �
//����������������������������������������������������������������
Local aSaldo		:= {}
Local aSaldoAnt		:= {}
Local aColunas 

Local cArqTmp
Local cSayCusto		:= CtbSayApro("CTT")
Local cSayItem		:= CtbSayApro("CTD")
Local cSayClVl		:= CtbSayApro("CTH")

Local cDescMoeda
Local cMascara1
Local cMascara2
Local cMascara3
Local cMascara4
Local cPicture
Local cSepara1		:= ""
Local cSepara2		:= ""
Local cSepara3		:= ""
Local cSepara4		:= ""
Local cSaldo		:= mv_par06
Local cContaIni	:= mv_par01
Local cContaFIm	:= mv_par02
Local cCustoIni	:= mv_par13
Local cCustoFim	:= mv_par14
Local cItemIni		:= mv_par16
Local cItemFim		:= mv_par17
Local cCLVLIni		:= mv_par19
Local cCLVLFim		:= mv_par20
Local cContaAnt	:= ""
Local cDescConta	:= ""
Local cCodRes		:= ""
Local cResCC		:= ""
Local cResItem		:= ""
Local cResCLVL		:= ""
Local cDescSint	:= ""
Local cMoeda		:= mv_par05
Local cContaSint	:= ""
Local cNormal 		:= ""

Local dDataAnt		:= CTOD("  /  /  ")
Local dDataIni		:= mv_par03
Local dDataFim		:= mv_par04

Local lNoMov		:= Iif(mv_par09==1,.T.,.F.)
Local lSldAnt		:= Iif(mv_par09==3,.T.,.F.)
Local lJunta		:= Iif(mv_par10==1,.T.,.F.)
Local lSalto		:= Iif(mv_par21==1,.T.,.F.)
Local lFirst		:= .T.
Local lImpLivro		:= .t.
Local lImpTermos	:= .f.
Local lPrintZero	:= Iif(mv_par30==1,.T.,.F.)

Local nDecimais
Local nTotDeb		:= 0
Local nTotCrd		:= 0
Local nTotGerDeb	:= 0
Local nTotGerCrd	:= 0
Local nPagIni		:= mv_par22
Local nReinicia 	:= mv_par24
Local nPagFim		:= mv_par23
Local nVlrDeb		:= 0
Local nVlrCrd		:= 0
Local nCont			:= 0
Local l1StQb 		:= .T.
Local lQbPg			:= .F.
Local lEmissUnica	:= If(GetNewPar("MV_CTBQBPG","M") == "M",.T.,.F.)			/// U=Quebra �nica (.F.) ; M=Multiplas quebras (.T.)
Local lNewPAGFIM	:= If(nReinicia > nPagFim,.T.,.F.)
Local LIMITE		:= If(TAMANHO=="G",220,If(TAMANHO=="M",132,80))
Local nInutLin		:= 1
Local nMaxLin   	:= mv_par32

Local nBloco		:= 0
Local nBlCount		:= 0

Local lSldAntCta	:= Iif(mv_par33 == 1, .T.,.F.)
Local lSldAntCC		:= Iif(mv_par33 == 2, .T.,.F.)
Local lSldAntIt  	:= Iif(mv_par33 == 3, .T.,.F.)
Local lSldAntCv  	:= Iif(mv_par33 == 4, .T.,.F.)
Local cMoedaDesc	:= iif( Empty( mv_par34 ) , cMoeda , mv_par34)

nTipoRel := mv_par08
	
lSalLin	:= If(mv_par31 ==1 ,.T.,.F.)
m_pag   := 1

CtbQbPg(.T.,@nPagIni,@nPagFim,@nReinicia,@m_pag,@nBloco,@nBlCount,.T.)		/// FUNCAO PARA TRATAMENTO DA QUEBRA //.T. INICIALIZA VARIAVEIS

//��������������������������������������������������������������Ŀ
//� Impressao de Termo / Livro                                   �
//����������������������������������������������������������������
Do Case
	Case mv_par29==1 ; lImpLivro:=.t. ; lImpTermos:=.f.
	Case mv_par29==2 ; lImpLivro:=.t. ; lImpTermos:=.t.
	Case mv_par29==3 ; lImpLivro:=.f. ; lImpTermos:=.t.
EndCase		

//��������������������������������������������������������������Ŀ
//� Variaveis utilizadas para Impressao do Cabecalho e Rodape    �
//����������������������������������������������������������������
cbtxt    := SPACE(10)
cbcont   := 0
li       := 80

cDescMoeda 	:= Alltrim(aCtbMoeda[2])
nDecimais 	:= DecimalCTB(aSetOfBook,cMoeda)

// Mascara da Conta
If Empty(aSetOfBook[2])
	cMascara1 := GetMv("MV_MASCARA")
Else
	cMascara1	:= RetMasCtb(aSetOfBook[2],@cSepara1)
EndIf               

If lCusto .Or. lItem .Or. lCLVL
	// Mascara do Centro de Custo
	If Empty(aSetOfBook[6])
		cMascara2 := GetMv("MV_MASCCUS")
	Else
		cMascara2	:= RetMasCtb(aSetOfBook[6],@cSepara2)
	EndIf                                                

	// Mascara do Item Contabil
	If Empty(aSetOfBook[7])
		dbSelectArea("CTD")
		cMascara3 := GetMv("MV_MASCCTD")
	Else
		cMascara3 := RetMasCtb(aSetOfBook[7],@cSepara3)
	EndIf

	// Mascara da Classe de Valor
	If Empty(aSetOfBook[8])
		dbSelectArea("CTH")
		cMascara4 := GetMv("MV_MASCCTH")
	Else
		cMascara4 := RetMasCtb(aSetOfBook[8],@cSepara4)
	EndIf
EndIf	

cPicture 	:= aSetOfBook[4]

//��������������������������������������������������������������������������Ŀ
//�Titulo do Relatorio                                                       �
//����������������������������������������������������������������������������
If Type("NewHead")== "U"
	IF nTipoRel == 1 //lAnalitico
		Titulo	:=	"RAZAO ANALITICO EM "	//"RAZAO ANALITICO EM "
	ElseIf nTipoRel == 2 // Resumido
		Titulo	:=	"RAZAO RESUMIDO EM "	//"RAZAO RESUMIDO EM "
	Else  // Sintetico
		Titulo	:=	"RAZAO SINTETICO EM "	//"RAZAO SINTETICO EM "
	EndIf
	Titulo += 	cDescMoeda + "DE" + DTOC(dDataIni) +;	// "DE"
				"ATE" + DTOC(dDataFim) + CtbTitSaldo(mv_par06)	// "ATE"
Else
	Titulo := NewHead
EndIf

//��������������������������������������������������������������������������Ŀ
//�Resumido                                  						         �
//����������������������������������������������������������������������������
// DATA                         					                                DEBITO               CREDITO            SALDO ATUAL
// XX/XX/XXXX 			                                 		     99,999,999,999,999.99 99,999,999,999,999.99 99,999,999,999,999.99D
// 01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
//           1         2         3         4         5         6         7         8         9        10        11        12        13        14        15        16         17        18        19        20       21        22
//��������������������������������������������������������������������������Ŀ
//�Cabe�alho Conta                                                           �
//����������������������������������������������������������������������������
// DATA
// LOTE/SUB/DOC/LINHA H I S T O R I C O                        C/PARTIDA                      DEBITO          CREDITO       SALDO ATUAL"
// XX/XX/XXXX         
// XXXXXXXXXXXXXXXXXX XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX XXXXXXXXXXXXXXXXXXXX 9999999999999.99 9999999999999.99 9999999999999.99D
// 012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234
//           1         2         3         4         5         6         7         8         9        10        11        12        13        14        15        16    
//��������������������������������������������������������������������������Ŀ
//�Cabe�alho Conta + CCusto + Item + Classe de Valor								  �
//����������������������������������������������������������������������������
// DATA
// LOTE/SUB/DOC/LINHA  H I S T O R I C O                        C/PARTIDA                      CENTRO CUSTO         ITEM                 CLASSE DE VALOR                     DEBITO               CREDITO           SALDO ATUAL"
// XX/XX/XXXX 
// XXXXXXXXXXXXXXXXXX XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX XXXXXXXXXXXXXXXXXXXX XXXXXXXXXXXXXXXXXXXX XXXXXXXXXXXXXXXXXXXX 99,999,999,999,999.99 99,999,999,999,999.99 99,999,999,999,999.99D
// 01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
//           1         2         3         4         5         6         7         8         9        10        11        12        13        14        15        16         17        18        19        20       21        22

#DEFINE 	COL_NUMERO 			1
#DEFINE 	COL_HISTORICO		2
#DEFINE 	COL_CONTRA_PARTIDA	3
#DEFINE 	COL_CENTRO_CUSTO 	4
#DEFINE 	COL_ITEM_CONTABIL 	5
#DEFINE 	COL_CLASSE_VALOR  	6 
#DEFINE 	COL_VLR_DEBITO		7
#DEFINE 	COL_VLR_CREDITO		8
#DEFINE 	COL_VLR_SALDO  		9
#DEFINE 	TAMANHO_TM       	10
#DEFINE 	COL_VLR_TRANSPORTE  11

If mv_par11 == 3 						//// SE O PARAMETRO DO CODIGO ESTIVER PARA IMPRESSAO
	nTamConta := Len(CT1->CT1_CODIMP)	//// USA O TAMANHO DO CAMPO CODIGO DE IMPRESSAO
Endif

If lAnalitico .And. (lCusto .Or. lItem .Or. lCLVL)
	nTamConta := 20						// Tamanho disponivel no relatorio para imprimir
EndIf

If nTipoRel > 1  // Relatorio Sintetico
	aColunas := { 000, 019, 060,    ,    ,    , 84, 100, 115, 15, 097}
Else
	If cPaisLoc $ "CHI|ARG"
		If ((!lCusto .And. !lItem .And. !lCLVL) .And. nTamConta<= 22)
			aColunas := { 000, 030, 060,    ,    ,    , 84, 100, 115, 15, 097}
		Else
			aColunas := { 000, 030, 060, 092, 113, 134, 156, 178, 198, 20 ,178 }
		Endif
	Else
		If ((!lCusto .And. !lItem .And. !lCLVL) .And. nTamConta<=22)
			aColunas := { 000, 019, 060,    ,    ,    , 84, 100, 115, 15, 097}
		Else
			aColunas := { 000, 019, 060, 086, 112, 138, 154, 176, 196, 20 ,176 }
		Endif
	EndIf
Endif   

If nTipoRel == 1 // Relatorio Analitico
	Cabec1 := "DATA"					   	// "DATA"
	Cabec2 := ""
	If (!lCusto .And. !lItem .And. !lCLVL)
		If nTamConta <= 22
			Cabec2:= "LOTE/SUB/DOC/LINHA H I S T O R I C O                        C/PARTIDA                       DEBITO         CREDITO       SALDO ATUAL"        	//LOTE/SUB/DOC/LINHA H I S T O R I C O                          C/PARTIDA                      DEBITO          CREDITO       SALDO ATUAL
		Else
			Cabec2 := "LOTE/SUB/DOC/LINHA H I S T O R I C O                        C/PARTIDA                                                                                       DEBITO               CREDITO                SALDO ATUAL"			//LOTE/SUB/DOC/LINHA H I S T O R I C O                          C/PARTIDA                      													                                                                             DEBITO               CREDITO         SALDO ATUAL
		EndIf
	Else
		Cabec2 := "LOTE/SUB/DOC/LINHA  H I S T O R I C O              C/PARTIDA                "			   	// "LOTE/SUB/DOC/LINHA  H I S T O R I C O                    C/PARTIDA            CENTRO CUSTO         ITEM                 CLASSE DE VALOR                     DEBITO               CREDITO           SALDO ATUAL
		
		// impress�o da descri��o do custo
		If lCusto
			Cabec2 += Upper(cSayCusto)
		Else
			Cabec2 += Space( Len( cSayCusto ) )
		Endif
		
		Cabec2 += Space(16)
		
		// impress�o da descri��o do item
		If lItem
			Cabec2 += Upper(cSayItem)
		Else
			Cabec2 += Space( Len( cSayItem ) )
		Endif
		
		Cabec2 += Space(16)
		
		// impress�o da descri��o do clvl
		If lCLVL
			Cabec2 += Upper(cSayClVl)
		Else
			Cabec2 += Space( Len( cSayClVl ) )
		Endif
		
		// impress�o dos totalizadores
		Cabec2 += Space(18) + "DEBITO               CREDITO           SALDO ATUAL        "
	EndIf
ElseIf nTipoRel == 2 //Relatorio Resumido
	lCusto := .F.
	lItem  := .F.
	lCLVL  := .F.
	Cabec1 := "DATA"
	Cabec2 := "LOTE/SUB/DOC/LINHA H I S T O R I C O                          C/PARTIDA                      DEBITO          CREDITO       SALDO ATUAL"
Else 	//Relatorio Sintetico
	lCusto := .F.
	lItem  := .F.
	lCLVL  := .F.
	Cabec1 := "DATA                                                                                         DEBITO         CREDITO    SALDO ATUAL"
	Cabec2 := ""
EndIf

If cPaisLoc $ "CHI|ARG" .and. lAnalitico
	Cabec2 := SubStr(Cabec2,1,18) + "-SEGOFI    " + SubStr(Cabec2,20,31) + SubStr(Cabec2,62)
EndIf 

m_pag := mv_par22

If lImpLivro
	//��������������������������������������������������������������Ŀ
	//� Monta Arquivo Temporario para Impressao   					 �
	//����������������������������������������������������������������
	MsgMeter({|	oMeter, oText, oDlg, lEnd | ;
	CTBGerRaz(oMeter,oText,oDlg,lEnd,@cArqTmp,cContaIni,cContaFim,cCustoIni,cCustoFim,;
	cItemIni,cItemFim,cCLVLIni,cCLVLFim,cMoeda,dDataIni,dDataFim,;
	aSetOfBook,lNoMov,cSaldo,lJunta,"1",lAnalitico,,,aReturn[7],lSldAnt,aSelFil)},;
	"Criando Arquivo Tempor�rio...",;		// "Criando Arquivo Tempor�rio..."
	"Emissao do Razao")		// "Emissao do Razao"
	
	dbSelectArea("CT2")
	If !Empty(dbFilter())
		dbClearFilter()
	Endif
	dbSelectArea("cArqTmp")
	SetRegua(RecCount())
	dbGoTop()
Endif

//Se tiver parametrizado com Plano Gerencial, exibe a mensagem que o Plano Gerencial
//nao esta disponivel e sai da rotina.
If lImpLivro
	If cArqTmp->(RecCount()) == 0 .And. !Empty(aSetOfBook[5])
		dbCloseArea()
		FErase(cArqTmp+GetDBExtension())
		FErase(cArqTmp+OrdBagExt())
		Return
	EndIf
Endif

While lImpLivro .And. !cArqTmp->(Eof())
	IF lEnd
		@Prow()+1,0 PSAY "***** CANCELADO PELO OPERADOR *****"  //"***** CANCELADO PELO OPERADOR *****"
		Exit
	EndIF
	
	IncRegua()
	
	If lSldAntCC
		aSaldo    := SaldTotCT3(cCustoIni,cCustoFim,cArqTmp->CONTA,cArqTmp->CONTA,cArqTmp->DATAL,cMoeda,cSaldo,aSelFil)
		aSaldoAnt := SaldTotCT3(cCustoIni,cCustoFim,cArqTmp->CONTA,cArqTmp->CONTA,dDataIni,cMoeda,cSaldo,aSelFil)
	ElseIf lSldAntIt
		aSaldo    := SaldTotCT4(cItemIni,cItemFim,cCustoIni,cCustoFim,cArqTmp->CONTA,cArqTmp->CONTA,cArqTmp->DATAL,cMoeda,cSaldo,aSelFil)
		aSaldoAnt := SaldTotCT4(cItemIni,cItemFim,cCustoIni,cCustoFim,cArqTmp->CONTA,cArqTmp->CONTA,dDataIni,cMoeda,cSaldo,aSelFil)
	ElseIf lSldAntCv
		aSaldo    := SaldTotCTI(cClVlIni,cClVlFim,cItemIni,cItemFim,cCustoIni,cCustoFim,cArqTmp->CONTA,cArqTmp->CONTA,cArqTmp->DATAL,cMoeda,cSaldo,aSelFil)
		aSaldoAnt := SaldTotCTI(cClVlIni,cClVlFim,cItemIni,cItemFim,cCustoIni,cCustoFim,cArqTmp->CONTA,cArqTmp->CONTA,dDataIni,cMoeda,cSaldo,aSelFil)
	Else
		aSaldo 		:= SaldoCT7Fil(cArqTmp->CONTA,cArqTmp->DATAL,cMoeda,cSaldo,,,,aSelFil)
		aSaldoAnt	:= SaldoCT7Fil(cArqTmp->CONTA,dDataIni,cMoeda,cSaldo,"CTBR400",,,aSelFil)
	EndIf
	
	If !lNoMov //Se imprime conta sem movimento
		If aSaldo[6] == 0 .And. cArqTmp->LANCDEB ==0 .And. cArqTmp->LANCCRD == 0
			dbSelectArea("cArqTmp")
			dbSkip()
			Loop
		Endif
	Endif
	
	If lNomov .And. aSaldo[6] == 0 .And. cArqTmp->LANCDEB ==0 .And. cArqTmp->LANCCRD == 0
		If CtbExDtFim("CT1")
			dbSelectArea("CT1")
			dbSetOrder(1)
			If MsSeek(xFilial()+cArqTmp->CONTA)
				If !CtbVlDtFim("CT1",dDataIni)
					dbSelectArea("cArqTmp")
					dbSkip()
					Loop
				EndIf
				
				If !CtbVlDtIni("CT1",dDataFim)
					dbSelectArea("cArqTmp")
					dbSkip()
					Loop
				EndIf
				
			EndIf
			dbSelectArea("cArqTmp")
		EndIf
	EndIf
	
	If li > nMaxLin .Or. lSalto
		CtbQbPg(.F.,@nPagIni,@nPagFim,@nReinicia,@m_pag,@nBloco,@nBlCount,.T.)		/// FUNCAO PARA TRATAMENTO DA QUEBRA //.T. INICIALIZA VARIAVEIS
		
		CtCGCCabec(lItem,lCusto,lCLVL,Cabec1,Cabec2,dDataFim,Titulo,lAnalitico,"1",Tamanho)
		
		If !lFirst
			lQbPg	:= .T.
		Else
			lFirst := .F.
		Endif
		
	EndIf
	
	nSaldoAtu:= 0
	nTotDeb	:= 0
	nTotCrd	:= 0
	
	// Conta Sintetica
	cContaSint := Ctr400Sint(cArqTmp->CONTA,@cDescSint,cMoeda,@cDescConta,@cCodRes,cMoedaDesc)
	cNormal := CT1->CT1_NORMAL
	If mv_par11 == 3
		EntidadeCTB(CT1->CT1_CODIMP,li,000,nTamConta,.F.,cMascara1,cSepara1)
		@li,Len(CT1->CT1_CODIMP) PSAY " - " + cDescSint
	Else
		EntidadeCTB(cContaSint,li,000,Len(cContaSint),.F.,cMascara1,cSepara1)
		@li,Len(cContaSint) PSAY " - " + cDescSint
	Endif
	If lSalLin
		li+=2
	Else
		li+=1
	EndIf
	// Conta Analitica
	
	@li,001 PSAY "CONTA - " 	//"CONTA - "

	If mv_par11 == 1							// Imprime Cod Normal
		EntidadeCTB(cArqTmp->CONTA,li,9,nTamConta+AJUST_CONTA,.F.,cMascara1,cSepara1)
	Else
		dbSelectArea("CT1")
		dbSetOrder(1)
		MsSeek(xFilial("CT1")+cArqTMP->CONTA,.F.)
		If mv_par11 == 3						// Imprime Codigo de Impressao
			EntidadeCTB(CT1->CT1_CODIMP,li,9,nTamConta+AJUST_CONTA,.F.,cMascara1,cSepara1)
		Else										// Caso contr�rio usa codigo reduzido
			EntidadeCTB(CT1->CT1_RES,li,9,nTamConta+AJUST_CONTA,.F.,cMascara1,cSepara1)
		EndIf

		cDescConta := &("CT1->CT1_DESC" + cMoedaDesc )
	Endif
	If !lAnalitico 
		@ li, 9+nTamConta+AJUST_CONTA PSAY "- " + Left(cDescConta,30)	
	Else
		@ li, 9+nTamConta+AJUST_CONTA PSAY "- " + Left(cDescConta,38)
	Endif
	
	@li,aColunas[COL_VLR_TRANSPORTE] - Len("SALDO ANTERIOR:") - 1;
		 PSAY "SALDO ANTERIOR: "		//"SALDO ANTERIOR: "	
	
	// Impressao do Saldo Anterior do Centro de Custo
	ValorCTB(aSaldoAnt[6],li,aColunas[COL_VLR_SALDO],aColunas[TAMANHO_TM],nDecimais,;
							         .T.,cPicture, cNormal, , , , , ,lPrintZero)

	nSaldoAtu := aSaldoAnt[6]                                           
	If lSalLin
		li+=2
	Else
		li += 1         
	EndIf
	dbSelectArea("cArqTmp")
	cContaAnt:= cArqTmp->CONTA
	dDataAnt	:= CTOD("  /  /  ")
	While cArqTmp->(!Eof()) .And. cArqTmp->CONTA == cContaAnt
	
		If li > nMaxLin
			If lSalLin
				li++
			EndIf
			
			@li,aColunas[COL_VLR_TRANSPORTE] - Len("A TRANSPORTAR :") - 1;
						 PSAY "A TRANSPORTAR : "	//"A TRANSPORTAR : "
			ValorCTB(nSaldoAtu,li,aColunas[COL_VLR_SALDO],;
					   aColunas[TAMANHO_TM],nDecimais, .T.,cPicture,cNormal , , , , , ,lPrintZero)
			
			CtbQbPg(.F.,@nPagIni,@nPagFim,@nReinicia,@m_pag,@nBloco,@nBlCount,.T.)		/// FUNCAO PARA TRATAMENTO DA QUEBRA //.T. INICIALIZA VARIAVEIS

			CtCGCCabec(lItem,lCusto,lCLVL,Cabec1,Cabec2,dDataFim,Titulo,lAnalitico,"1",Tamanho)

			lQbPg := .T.
			
			@li,001 PSAY "CONTA - "	 	//"CONTA - "	

			If mv_par11 == 1							// Imprime Cod Normal
				EntidadeCTB(cArqTmp->CONTA,li,9,nTamConta+AJUST_CONTA,.F.,cMascara1,cSepara1)
			Else
				dbSelectArea("CT1")
				dbSetOrder(1)
				MsSeek(xFilial("CT1")+cArqTMP->CONTA,.F.)
				If mv_par11 == 3						// Imprime Codigo de Impressao
					EntidadeCTB(CT1->CT1_CODIMP,li,9,nTamConta+AJUST_CONTA,.F.,cMascara1,cSepara1)
				Else										// Caso contr�rio usa codigo reduzido
					EntidadeCTB(CT1->CT1_RES,li,9,nTamConta+AJUST_CONTA,.F.,cMascara1,cSepara1)
				EndIf
				cDescConta := &("CT1->CT1_DESC" + cMoedaDesc)
			Endif
			@ li, 9+nTamConta+AJUST_CONTA PSAY "- " + Left(cDescConta,38)			
			
			@li,aColunas[COL_VLR_TRANSPORTE] - Len("DE TRANSPORTE : ") - 1 PSAY "DE TRANSPORTE : "	//"DE TRANSPORTE : "
			ValorCTB(nSaldoAtu,li,aColunas[COL_VLR_SALDO],aColunas[TAMANHO_TM],nDecimais, .T.,cPicture,cNormal , , , , , ,lPrintZero)
			li+= 2
		EndIf
	
		// Imprime os lancamentos para a conta                          
		
		If dDataAnt != cArqTmp->DATAL 
			If (cArqTmp->LANCDEB <> 0 .Or. cArqTmp->LANCCRD <> 0)
				If nTiporel < 3
					@li,000 PSAY cArqTmp->DATAL
					li++                       
				Else
					@li,000 PSAY cArqTmp->DATAL
				Endif		
			Endif	
			dDataAnt := cArqTmp->DATAL    
			lQbPg := .F.			
		ElseIf lQbPg
			@li,000 PSAY dDataAnt
			li++                       		
			lQbPg := .F.
		EndIf	
		
		If nTipoRel < 3	//Se for relatorio analitico ou resumido
			nSaldoAtu 	:= nSaldoAtu - cArqTmp->LANCDEB + cArqTmp->LANCCRD
			nTotDeb		+= cArqTmp->LANCDEB
			nTotCrd		+= cArqTmp->LANCCRD
			nTotGerDeb	+= cArqTmp->LANCDEB
			nTotGerCrd	+= cArqTmp->LANCCRD			
			
			dbSelectArea("CT1")
			dbSetOrder(1)
			MsSeek(xFilial("CT1")+cArqTmp->XPARTIDA)
			cCodRes := CT1->CT1_RES
			dbSelectArea("cArqTmp")

			If cPaisLoc $ "CHI|ARG"
				@li,aColunas[COL_NUMERO] PSAY cArqTmp->LOTE+cArqTmp->SUBLOTE+cArqTmp->DOC+cArqTmp->LINHA+"-"+cArqTmp->SEGOFI 
				@li,aColunas[COL_HISTORICO] PSAY Subs(cArqTmp->HISTORICO,1,29)

				// historico complementar da linha (deve-se imprimir na proxima linha)
				cHistComp := Subs(cArqTmp->HISTORICO,30)
			Else
  				@li,aColunas[COL_NUMERO] PSAY cArqTmp->LOTE+cArqTmp->SUBLOTE+cArqTmp->DOC+cArqTmp->LINHA
				@li,aColunas[COL_HISTORICO] PSAY Subs(cArqTmp->HISTORICO,1,40)

				// historico complementar da linha (deve-se imprimir na proxima linha)
				cHistComp := Subs(cArqTmp->HISTORICO,41)
			EndIf									   

			If mv_par11 == 1
				EntidadeCTB(cArqTmp->XPARTIDA,li,aColunas[COL_CONTRA_PARTIDA], nTamConta ,.F.,cMascara1 ,cSepara1)
			ElseIf mv_par11 == 3
				EntidadeCTB(CT1->CT1_CODIMP,li,aColunas[COL_CONTRA_PARTIDA],nTamConta,.F., cMascara1 ,cSepara1)				
			Else
				EntidadeCTB(CT1->CT1_RES,li,aColunas[COL_CONTRA_PARTIDA],17,.F., cMascara1 ,cSepara1)				
			Endif                              

			If lCusto  
		
				If mv_par25 == 1 //Imprime Cod. Centro de Custo Normal 
					EntidadeCTB(cArqTmp->CCUSTO,li,aColunas[COL_CENTRO_CUSTO],25,.F.,cMascara2,cSepara2)
				Else 
					dbSelectArea("CTT")
					dbSetOrder(1)
					dbSeek(xFilial("CTT")+cArqTmp->CCUSTO)				
					cResCC := CTT->CTT_RES
					EntidadeCTB(cResCC,li,aColunas[COL_CENTRO_CUSTO],25,.F.,cMascara2,cSepara2)
					dbSelectArea("cArqTmp")
				Endif  
					                                                     
			Endif

			If lItem 						//Se imprime item 
				If mv_par26 == 1 //Imprime Codigo Normal Item Contabl
					EntidadeCTB(cArqTmp->ITEM,li,aColunas[COL_ITEM_CONTABIL],25,.F.,cMascara3,cSepara3)
				Else
					dbSelectArea("CTD")
					dbSetOrder(1)
					dbSeek(xFilial("CTD")+cArqTmp->ITEM)				
					cResItem := CTD->CTD_RES
					EntidadeCTB(cResItem,li,aColunas[COL_ITEM_CONTABIL],25,.F.,cMascara3,cSepara3)						
					dbSelectArea("cArqTmp")					
				Endif
			Endif
				
			If lCLVL						//Se imprime classe de valor
				If mv_par27 == 1 //Imprime Cod. Normal Classe de Valor
					EntidadeCTB(cArqTmp->CLVL,li,aColunas[COL_CLASSE_VALOR],16,.F.,cMascara4,cSepara4)
				Else
					dbSelectArea("CTH")
					dbSetOrder(1)
					dbSeek(xFilial("CTH")+cArqTmp->CLVL)				
					cResClVl := CTH->CTH_RES						
					EntidadeCTB(cResClVl,li,aColunas[COL_CLASSE_VALOR],16,.F.,cMascara4,cSepara4)
					dbSelectArea("cArqTmp")					
				Endif			
			Endif
			
			ValorCTB(cArqTmp->LANCDEB,li,aColunas[COL_VLR_DEBITO] 	, aColunas[TAMANHO_TM],nDecimais,.F.,cPicture,"1", , , , , ,lPrintZero)
			ValorCTB(cArqTmp->LANCCRD,li,aColunas[COL_VLR_CREDITO]	, aColunas[TAMANHO_TM],nDecimais,.F.,cPicture,"2", , , , , ,lPrintZero)
			ValorCTB(nSaldoAtu,li,aColunas[COL_VLR_SALDO]			, aColunas[TAMANHO_TM],nDecimais,.T.,cPicture,cNormal, , , , , ,lPrintZero)

			// rotina de impress�o do restante do historico da linha
			While ! Empty( ALLTRIM( cHistComp ) )

				li++
				// controle de quebra de pagina do raz�o
				If li > nMaxLin
					//// VALOR A TRANSPORTAR NA QUEBRA DE PAGINA    
						
					If lSalLin
						li++
					EndIf
					
					@li,aColunas[COL_VLR_TRANSPORTE] - Len("A TRANSPORTAR : ") - 1 PSAY "A TRANSPORTAR : "	//"A TRANSPORTAR : "
					ValorCTB(nSaldoAtu,li,aColunas[COL_VLR_SALDO],aColunas[TAMANHO_TM],nDecimais, .T.,cPicture,cNormal, , , , , ,lPrintZero)
				    //// FIM DO TRATAMENTO PARA QUEBRA DO VALORA A TRANSPORTAR
				              
					CtbQbPg(.F.,@nPagIni,@nPagFim,@nReinicia,@m_pag,@nBloco,@nBlCount,.T.)		/// FUNCAO PARA TRATAMENTO DA QUEBRA //.T. INICIALIZA VARIAVEIS

					CtCGCCabec(lItem,lCusto,lCLVL,Cabec1,Cabec2,dDataFim,Titulo,lAnalitico,"1",Tamanho)
				
					//// VALOR DE TRANSPORTE NA QUEBRA DE P�GINA
					@li,001 PSAY "CONTA - " 	//"CONTA - "	
				
					If mv_par11 == 1							// Imprime Cod Normal
						EntidadeCTB(cArqTmp->CONTA,li,9,nTamConta+AJUST_CONTA,.F.,cMascara1,cSepara1)
					Else
						dbSelectArea("CT1")
						dbSetOrder(1)
						MsSeek(xFilial("CT1")+cArqTMP->CONTA,.F.)											
						If mv_par11 == 3						// Imprime Codigo de Impressao
							EntidadeCTB(CT1->CT1_CODIMP,li,9,nTamConta+AJUST_CONTA,.F.,cMascara1,cSepara1)
						Else										// Caso contr�rio usa codigo reduzido
							EntidadeCTB(CT1->CT1_RES,li,9,nTamConta+AJUST_CONTA,.F.,cMascara1,cSepara1)
						Endif
						cDescConta := &("CT1->CT1_DESC" + cMoedaDesc)
						dbSelectArea("CT2")
					EndIf
					@ li, 9+nTamConta+AJUST_CONTA PSAY "- " + Left(cDescConta,38)			
				
					@li,aColunas[COL_VLR_TRANSPORTE] - Len("DE TRANSPORTE : ") - 1 PSAY "DE TRANSPORTE : "	//"DE TRANSPORTE : "
					ValorCTB(nSaldoAtu,li,aColunas[COL_VLR_SALDO],aColunas[TAMANHO_TM],nDecimais, .T.,cPicture,cNormal , , , , , ,lPrintZero)
					li+= 2
					//// FINAL DO TRATAMENTO PARA O VALOR DE TRANSPORTE NA QUEBRA DE PAGINA
					
					If !lFirst
						@li,000 PSAY dDataAnt
						li++
					Else
						lFirst := .F.
					Endif
				
				EndIf

				//@li,aColunas[COL_NUMERO] PSAY Space(15) + cArqTmp->LINHA 

				If cPaisLoc $ "CHI|ARG"
					@li,aColunas[COL_HISTORICO] PSAY Subs(cHistComp,1,29)
	
					// historico complementar da linha (deve-se imprimir na proxima linha)
					cHistComp := Subs(cHistComp,30)
				Else
					@li,aColunas[COL_HISTORICO] PSAY Subs(cHistComp,1,40)
	
					// historico complementar da linha (deve-se imprimir na proxima linha)
					cHistComp := Subs(cHistComp,41)
				EndIf									   
			EndDo

			// Procura pelo complemento de historico
			dbSelectArea("CT2")
			dbSetOrder(10)
			If MsSeek(cArqTMP->(FILIAL+DTOS(DATAL)+LOTE+SUBLOTE+DOC+SEQLAN+EMPORI+FILORI),.F.)
				dbSkip()
				If CT2->CT2_DC == "4"			//// TRATAMENTO PARA IMPRESSAO DAS CONTINUACOES DE HISTORICO
					While !CT2->(Eof()) .And. CT2->CT2_FILIAL == cArqTMP->FILIAL .And.;
										CT2->CT2_LOTE == cArqTMP->LOTE 		.And.;
										CT2->CT2_SBLOTE == cArqTMP->SUBLOTE 	.And.;
										CT2->CT2_DOC == cArqTmp->DOC 			.And.;
										CT2->CT2_SEQLAN == cArqTmp->SEQLAN 	.And.;
										CT2->CT2_EMPORI == cArqTmp->EMPORI	.And.;
										CT2->CT2_FILORI == cArqTmp->FILORI	.And.;
										CT2->CT2_DC == "4" 					.And.;
									    DTOS(CT2->CT2_DATA) == DTOS(cArqTmp->DATAL)                        

						li++

						// controle de quebra de pagina do raz�o
						If li > nMaxLin
							//// VALOR A TRANSPORTAR NA QUEBRA DE PAGINA    
							
							If lSalLin
								li++
							EndIf
							
							@li,aColunas[COL_VLR_TRANSPORTE] - Len("A TRANSPORTAR : ") - 1 PSAY "A TRANSPORTAR : "	//"A TRANSPORTAR : "
							ValorCTB(nSaldoAtu,li,aColunas[COL_VLR_SALDO],aColunas[TAMANHO_TM],nDecimais, .T.,cPicture,cNormal, , , , , ,lPrintZero)
						    //// FIM DO TRATAMENTO PARA QUEBRA DO VALORA A TRANSPORTAR
						              
							CtbQbPg(.F.,@nPagIni,@nPagFim,@nReinicia,@m_pag,@nBloco,@nBlCount,.T.)		/// FUNCAO PARA TRATAMENTO DA QUEBRA //.T. INICIALIZA VARIAVEIS

							CtCGCCabec(lItem,lCusto,lCLVL,Cabec1,Cabec2,dDataFim,Titulo,lAnalitico,"1",Tamanho)
						
							//// VALOR DE TRANSPORTE NA QUEBRA DE P�GINA
							@li,001 PSAY "CONTA - "	 	//"CONTA - "	
						
							If mv_par11 == 1							// Imprime Cod Normal
								EntidadeCTB(cArqTmp->CONTA,li,9,nTamConta+AJUST_CONTA,.F.,cMascara1,cSepara1)
							Else
								dbSelectArea("CT1")
								dbSetOrder(1)
								MsSeek(xFilial("CT1")+cArqTMP->CONTA,.F.)											
								If mv_par11 == 3						// Imprime Codigo de Impressao
									EntidadeCTB(CT1->CT1_CODIMP,li,9,nTamConta+AJUST_CONTA,.F.,cMascara1,cSepara1)
								Else										// Caso contr�rio usa codigo reduzido
									EntidadeCTB(CT1->CT1_RES,li,9,nTamConta+AJUST_CONTA,.F.,cMascara1,cSepara1)
								Endif
								cDescConta := &("CT1->CT1_DESC" + cMoedaDesc)
								dbSelectArea("CT2")
							EndIf
							@ li, 9+nTamConta+AJUST_CONTA PSAY "- " + Left(cDescConta,38)			
						
							@li,aColunas[COL_VLR_TRANSPORTE] - Len("DE TRANSPORTE : ") - 1 PSAY "DE TRANSPORTE : "	//"DE TRANSPORTE : "
							ValorCTB(nSaldoAtu,li,aColunas[COL_VLR_SALDO],aColunas[TAMANHO_TM],nDecimais, .T.,cPicture,cNormal , , , , , ,lPrintZero)
							li+= 2
							//// FINAL DO TRATAMENTO PARA O VALOR DE TRANSPORTE NA QUEBRA DE PAGINA
							
							If !lFirst
								@li,000 PSAY dDataAnt
								li++
							Else
								lFirst := .F.
							Endif
						
						EndIf

		  			   	@li,aColunas[COL_NUMERO] PSAY Space(15)+CT2->CT2_LINHA

						If cPaisLoc $ "CHI|ARG"
							@li,aColunas[COL_HISTORICO] PSAY Subs(CT2->CT2_HIST,1,29)
							
							// historico complementar da linha (deve-se imprimir na proxima linha)
							cHistComp := Subs(CT2->CT2_HIST,30)
						Else
							@li,aColunas[COL_HISTORICO] PSAY Subs(CT2->CT2_HIST,1,40)
			
							// historico complementar da linha (deve-se imprimir na proxima linha)
							cHistComp := Subs(CT2->CT2_HIST,41)
						EndIf									   

						// rotina de impress�o do restante do historico da linha
						While ! Empty( cHistComp )
					
							li++
			
							// controle de quebra de pagina do raz�o
							If li > nMaxLin
								//// VALOR A TRANSPORTAR NA QUEBRA DE PAGINA    
								
								If lSalLin
									li++
								EndIf
								
								@li,aColunas[COL_VLR_TRANSPORTE] - Len("A TRANSPORTAR : ") - 1 PSAY "A TRANSPORTAR : "	//"A TRANSPORTAR : "
								ValorCTB(nSaldoAtu,li,aColunas[COL_VLR_SALDO],aColunas[TAMANHO_TM],nDecimais, .T.,cPicture,cNormal, , , , , ,lPrintZero)
							    //// FIM DO TRATAMENTO PARA QUEBRA DO VALORA A TRANSPORTAR
							              
								CtbQbPg(.F.,@nPagIni,@nPagFim,@nReinicia,@m_pag,@nBloco,@nBlCount,.T.)		/// FUNCAO PARA TRATAMENTO DA QUEBRA //.T. INICIALIZA VARIAVEIS

								CtCGCCabec(lItem,lCusto,lCLVL,Cabec1,Cabec2,dDataFim,Titulo,lAnalitico,"1",Tamanho)
						
								//// VALOR DE TRANSPORTE NA QUEBRA DE P�GINA
								@li,001 PSAY "CONTA - " 	//"CONTA - "	
							
								If mv_par11 == 1							// Imprime Cod Normal
									EntidadeCTB(cArqTmp->CONTA,li,9,nTamConta+AJUST_CONTA,.F.,cMascara1,cSepara1)
								Else
									dbSelectArea("CT1")
									dbSetOrder(1)
									MsSeek(xFilial("CT1")+cArqTMP->CONTA,.F.)											
									If mv_par11 == 3						// Imprime Codigo de Impressao
										EntidadeCTB(CT1->CT1_CODIMP,li,9,nTamConta+AJUST_CONTA,.F.,cMascara1,cSepara1)
									Else										// Caso contr�rio usa codigo reduzido
										EntidadeCTB(CT1->CT1_RES,li,9,nTamConta+AJUST_CONTA,.F.,cMascara1,cSepara1)
									Endif
									cDescConta := &("CT1->CT1_DESC" + cMoedaDesc)
									dbSelectArea("CT2")
								EndIf
								@ li, 9+nTamConta+AJUST_CONTA PSAY "- " + Left(cDescConta,38)			
							
								@li,aColunas[COL_VLR_TRANSPORTE] - Len("DE TRANSPORTE : ") - 1 PSAY "DE TRANSPORTE : "	//"DE TRANSPORTE : "
								ValorCTB(nSaldoAtu,li,aColunas[COL_VLR_SALDO],aColunas[TAMANHO_TM],nDecimais, .T.,cPicture,cNormal , , , , , ,lPrintZero)
								li+= 2
								//// FINAL DO TRATAMENTO PARA O VALOR DE TRANSPORTE NA QUEBRA DE PAGINA
								
								If !lFirst
									@li,000 PSAY dDataAnt
									li++
								Else
									lFirst := .F.
								Endif
							
							EndIf
					
							//@li,aColunas[COL_NUMERO] PSAY Space(15)+CT2->CT2_LINHA

							If cPaisLoc $ "CHI|ARG"
								@li,aColunas[COL_HISTORICO] PSAY Subs(cHistComp,1,29)
				
								// historico complementar da linha (deve-se imprimir na proxima linha)
								cHistComp := Subs(cHistComp,30)
							Else
								@li,aColunas[COL_HISTORICO] PSAY Subs(cHistComp,1,40)
				
								// historico complementar da linha (deve-se imprimir na proxima linha)
								cHistComp := Subs(cHistComp,41)
							EndIf									   
						EndDo
			
						CT2->(dbSkip())
						EndDo
					EndIf	
				EndIf	
			dbSelectArea("cArqTmp")
			dbSkip()			
		Else		// Se for sintetico.                               			
			dbSelectArea("cArqTmp")
			While dDataAnt == cArqTmp->DATAL .And. cContaAnt == cArqTmp->CONTA
				nVlrDeb	+= cArqTmp->LANCDEB		                                         
				nVlrCrd	+= cArqTmp->LANCCRD		                                         
				nTotGerDeb	+= cArqTmp->LANCDEB
				nTotGerCrd	+= cArqTmp->LANCCRD			
				dbSkip()                                                                    				
			End			                                                                    
			nSaldoAtu	:= nSaldoAtu - nVlrDeb + nVlrCrd
			ValorCTB(nVlrDeb,li,aColunas[COL_VLR_DEBITO],aColunas[TAMANHO_TM],;
				nDecimais,.F.,cPicture,"1", , , , , ,lPrintZero)
			ValorCTB(nVlrCrd,li,aColunas[COL_VLR_CREDITO],aColunas[TAMANHO_TM],;
				nDecimais,.F.,cPicture,"2", , , , , ,lPrintZero)
			ValorCTB(nSaldoAtu,li,aColunas[COL_VLR_SALDO],aColunas[TAMANHO_TM],;
				nDecimais,.T.,cPicture,cNormal, , , , , ,lPrintZero)
			nTotDeb		+= nVlrDeb
			nTotCrd		+= nVlrCrd         
			nVlrDeb	:= 0
			nVlrCrd	:= 0
		Endif
		dbSelectArea("cArqTmp")
		//dbSkip()  
		li++
	EndDo

   	If lSalLin
		li+=2
	EndIf
	If li > nMaxLin
		If lSalLin
			li++
		EndIf
	
		@li,aColunas[COL_VLR_TRANSPORTE] - Len("A TRANSPORTAR : ") - 1;
					 PSAY "A TRANSPORTAR : "	//"A TRANSPORTAR : "
		ValorCTB(nSaldoAtu,li,aColunas[COL_VLR_SALDO],;
		   aColunas[TAMANHO_TM],nDecimais, .T.,cPicture,cNormal, , , , , ,lPrintZero)

		CtbQbPg(.F.,@nPagIni,@nPagFim,@nReinicia,@m_pag,@nBloco,@nBlCount,.T.)		/// FUNCAO PARA TRATAMENTO DA QUEBRA //.T. INICIALIZA VARIAVEIS

		CtCGCCabec(lItem,lCusto,lCLVL,Cabec1,Cabec2,dDataFim,Titulo,lAnalitico,"1",Tamanho)
		If !lFirst
			lQbPg := .T.
		Else
			lFirst := .F.                                
		Endif
		
		@li,001 PSAY "CONTA - " 	//"CONTA - "	

		If Empty(cContaAnt) .or. cArqTMP->CONTA == cContaAnt			//// SE O REG NO COMECO DA PAGINA FOR DA MESMA CONTA DA PG ANTERIOR
			If mv_par11 == 1							// Imprime Cod Normal
				EntidadeCTB(cArqTmp->CONTA,li,9,nTamConta+AJUST_CONTA,.F.,cMascara1,cSepara1)
			Else
				dbSelectArea("CT1")
				dbSetOrder(1)
				MsSeek(xFilial("CT1")+cArqTMP->CONTA,.F.)			
				If mv_par11 == 3						// Imprime Codigo de Impressao
					EntidadeCTB(CT1->CT1_CODIMP,li,9,nTamConta+AJUST_CONTA,.F.,cMascara1,cSepara1)
				Else										// Caso contr�rio usa codigo reduzido
					EntidadeCTB(CT1->CT1_RES,li,9,nTamConta+AJUST_CONTA,.F.,cMascara1,cSepara1)
				EndIf
			Endif
		Else									//// SE NAO FOR DA MESMA CONTA
			dbSelectArea("CT1")
			dbSetOrder(1)
			If MsSeek(xFilial("CT1")+cContaAnt,.F.)		/// IMPRIME OS DADOS DA CONTA ANTERIOR
				If mv_par11 == 1							// Imprime Cod Normal
					EntidadeCTB(cContaAnt,li,9,nTamConta+AJUST_CONTA,.F.,cMascara1,cSepara1)
				ElseIf mv_par11 == 3						// Imprime Codigo de Impressao
					EntidadeCTB(CT1->CT1_CODIMP,li,9,nTamConta+AJUST_CONTA,.F.,cMascara1,cSepara1)
				Else										// Caso contr�rio usa codigo reduzido
					EntidadeCTB(CT1->CT1_RES,li,9,nTamConta+AJUST_CONTA,.F.,cMascara1,cSepara1)
				EndIf
			Endif
		Endif
		cDescConta := &("CT1->CT1_DESC" + cMoedaDesc)
		@ li, 9+nTamConta+AJUST_CONTA PSAY "- " + Left(cDescConta,38)				
	
		@li,aColunas[COL_VLR_TRANSPORTE] - Len("DE TRANSPORTE ") - 1 PSAY "DE TRANSPORTE "	//"DE TRANSPORTE "
		ValorCTB(nSaldoAtu,li,aColunas[COL_VLR_SALDO],aColunas[TAMANHO_TM],nDecimais, .T.,cPicture,cNormal, , , , , ,lPrintZero)
		
		If lSalLin
			li+=2
		Else
			li+= 1
		EndIf
		
		If lQbPg
			If cArqtmp->(!Eof()) .And. cArqTmp->CONTA == cContaAnt		
				@li,000 PSAY dDataAnt
			EndIf
			li++
			lQbPg := .F.
		Endif
   EndIf
    
	@li,aColunas[If(lAnalitico,COL_HISTORICO,COL_NUMERO)] PSAY "T o t a i s  d a  C o n t a  ==> "  //"T o t a i s  d a  C o n t a  ==> " 	    

	ValorCTB(nTotDeb,li,aColunas[COL_VLR_DEBITO],aColunas[TAMANHO_TM],nDecimais,;
			 .F.,cPicture,"1", , , , , ,lPrintZero)
	ValorCTB(nTotCrd,li,aColunas[COL_VLR_CREDITO],aColunas[TAMANHO_TM],nDecimais,;
			 .F.,cPicture,"2", , , , , ,lPrintZero)
	ValorCTB(nSaldoAtu,li,aColunas[COL_VLR_SALDO],aColunas[TAMANHO_TM],nDecimais,;
			 .T.,cPicture,cNormal, , , , , ,lPrintZero)
    
	li++
	@li, 00 PSAY Replicate("-",nTamLinha)
	li++
	dbSelectArea("cArqTMP")
EndDo
                
If li != 80 .And. lImpLivro .And. mv_par28 == 1	//Imprime total Geral
	@li, 30 PSAY "T O T A L  G E R A L  ==> "  //"T O T A L  G E R A L  ==> "
	If lAnalitico .And. (lCusto .Or. lItem .Or. lClVl)
		ValorCTB(nTotGerDeb,li,aColunas[COL_VLR_DEBITO],aColunas[TAMANHO_TM],nDecimais,.F.,cPicture,"1", , , , , ,lPrintZero)
		ValorCTB(nTotGerCrd,li,aColunas[COL_VLR_CREDITO],aColunas[TAMANHO_TM],nDecimais,.F.,cPicture,"2", , , , , ,lPrintZero)
		li++
		@li, 00 PSAY Replicate("-",nTamLinha)
	Else
		ValorCTB(nTotGerDeb,li,aColunas[COL_VLR_DEBITO],aColunas[TAMANHO_TM],nDecimais,.F.,cPicture,"1", , , , , ,lPrintZero)
		ValorCTB(nTotGerCrd,li,aColunas[COL_VLR_CREDITO],aColunas[TAMANHO_TM],nDecimais,.F.,cPicture,"2", , , , , ,lPrintZero)
		li++
		@li, 00 PSAY Replicate("-",nTamLinha)
	Endif
Endif

nLinAst := GetNewPar("MV_INUTLIN",0)
If li < nMaxLin .and. nLinAst <> 0 .and. !lEnd
	For nInutLin := 1 to nLinAst
		li++
		@li,00 PSAY REPLICATE("*",LIMITE)
		If li == nMaxLin
			Exit
		EndIf
	Next
EndIf

If lImpTermos 							// Impressao dos Termos
	
	cArqAbert:=GetNewPar("MV_LRAZABE","")
	cArqEncer:=GetNewPar("MV_LRAZENC","")
	
	If Empty(cArqAbert)
		ApMsgAlert(	"Devem ser criados os parametros MV_LRAZABE e MV_LRAZENC. " +; //"Devem ser criados os parametros MV_LRAZABE e MV_LRAZENC. "
		"Utilize como base o parametro MV_LDIARAB.") //"Utilize como base o parametro MV_LDIARAB."
	Endif
Endif

If lImpTermos .And. ! Empty(cArqAbert)	// Impressao dos Termos
	li+=2
	dbSelectArea("SM0")
	aVariaveis:={}
	
	For nCont:=1 to FCount()
		If FieldName(nCont)=="M0_CGC"
			AADD(aVariaveis,{FieldName(nCont),Transform(FieldGet(nCont),"@R 99.999.999/9999-99")})
		Else
			If FieldName(nCont)=="M0_NOME"
				Loop
			EndIf
			AADD(aVariaveis,{FieldName(nCont),FieldGet(nCont)})
		Endif
	Next
	
	dbSelectArea("SX1")
	dbSeek( padr( "CTR400" , Len( X1_GRUPO ) , ' ' ) + "01" )
	While ! Eof() .And. SX1->X1_GRUPO  == padr( "CTR400" , Len( X1_GRUPO ) , ' ' )
		AADD(aVariaveis,{Rtrim(Upper(X1_VAR01)),&(X1_VAR01)})
		dbSkip()
	End
	
	If AliasIndic( "CVB" )
		dbSelectArea( "CVB" )
		CVB->(dbSeek( xFilial( "CVB" ) ))
		For nCont:=1 to FCount()
			If FieldName(nCont)=="CVB_CGC"
				AADD(aVariaveis,{FieldName(nCont),Transform(FieldGet(nCont),"@R 99.999.999/9999-99")})
			ElseIf FieldName(nCont)=="CVB_CPF"
				AADD(aVariaveis,{FieldName(nCont),Transform(FieldGet(nCont),"@R 999.999.999-99")})
			Else
				AADD(aVariaveis,{FieldName(nCont),FieldGet(nCont)})
			Endif
		Next
	EndIf
	
	AADD(aVariaveis,{"M_DIA",StrZero(Day(dDataBase),2)})
	AADD(aVariaveis,{"M_MES",MesExtenso()})
	AADD(aVariaveis,{"M_ANO",StrZero(Year(dDataBase),4)})
	
	If !File(cArqAbert)
		aSavSet:=__SetSets()
		cArqAbert:=CFGX024(,"Raz�o") // Editor de Termos de Livros
		__SetSets(aSavSet)
		Set(24,Set(24),.t.)
	Endif
	
	If !File(cArqEncer)
		aSavSet:=__SetSets()
		cArqEncer:=CFGX024(,"Raz�o") // Editor de Termos de Livros
		__SetSets(aSavSet)
		Set(24,Set(24),.t.)
	Endif
	
	If cArqAbert#NIL
		ImpTerm(cArqAbert,aVariaveis,AvalImp(132))
	Endif
	
	If cArqEncer#NIL
		ImpTerm(cArqEncer,aVariaveis,AvalImp(132))
	Endif
Endif

If aReturn[5] = 1
	Set Printer To
	Commit
	Ourspool(wnrel)
End

If lImpLivro
	dbSelectArea("cArqTmp")
	Set Filter To
	dbCloseArea()
	If Select("cArqTmp") == 0
		FErase(cArqTmp+GetDBExtension())
		FErase(cArqTmp+OrdBagExt())
	EndIf
Endif

dbselectArea("CT2")

MS_FLUSH()

Return

/*/
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
��� Fun��o    �CtbGerRaz � Autor � Pilar S. Albaladejo   � Data � 05/02/01 ���
��������������������������������������������������������������������������Ĵ��
��� Descri��o �Cria Arquivo Temporario para imprimir o Razao               ���
��������������������������������������������������������������������������Ĵ��
��� Sintaxe   �CtbGerRaz(oMeter,oText,oDlg,lEnd,cArqTmp,cContaIni,cContaFim���
���			  �cCustoIni,cCustoFim,cItemIni,cItemFim,cCLVLIni,cCLVLFim,    ���
���			  �cMoeda,dDataIni,dDataFim,aSetOfBook,lNoMov,cSaldo,lJunta,   ���
���			  �cTipo,lAnalit)                                              ���
��������������������������������������������������������������������������Ĵ��
���Retorno    �Nome do arquivo temporario                                  ���
��������������������������������������������������������������������������Ĵ��
��� Uso       � SIGACTB                                                    ���
��������������������������������������������������������������������������Ĵ��
���Parametros � ExpO1 = Objeto oMeter                                      ���
���           � ExpO2 = Objeto oText                                       ���
���           � ExpO3 = Objeto oDlg                                        ���
���           � ExpL1 = Acao do Codeblock                                  ���
���           � ExpC1 = Arquivo temporario                                 ���
���           � ExpC2 = Conta Inicial                                      ���
���           � ExpC3 = Conta Final                                        ���
���           � ExpC4 = C.Custo Inicial                                    ���
���           � ExpC5 = C.Custo Final                                      ���
���           � ExpC6 = Item Inicial                                       ���
���           � ExpC7 = Cl.Valor Inicial                                   ���
���           � ExpC8 = Cl.Valor Final                                     ���
���           � ExpC9 = Moeda                                              ���
���           � ExpD1 = Data Inicial                                       ���
���           � ExpD2 = Data Final                                         ���
���           � ExpA1 = Matriz aSetOfBook                                  ���
���           � ExpL2 = Indica se imprime movimento zerado ou nao.         ���
���           � ExpC10= Tipo de Saldo                                      ���
���           � ExpL3 = Indica se junta CC ou nao.                         ���
���           � ExpC11= Tipo do lancamento                                 ���
���           � ExpL4 = Indica se imprime analitico ou sintetico           ���
���           � c2Moeda = Indica moeda 2 a ser incluida no relatorio       ���
���           � cUFilter= Conteudo Txt com o Filtro de Usuario (CT2)       ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������
/*/
Static Function CtbGerRaz(oMeter,oText,oDlg,lEnd,cArqTmp,cContaIni,cContaFim,cCustoIni,cCustoFim,;
						cItemIni,cItemFim,cCLVLIni,cCLVLFim,cMoeda,dDataIni,dDataFim,;
						aSetOfBook,lNoMov,cSaldo,lJunta,cTipo,lAnalit,c2Moeda,;
						nTipo,cUFilter,lSldAnt,aSelFil,lExterno)

Local aTamConta	:= TAMSX3("CT1_CONTA")
Local aTamCusto	:= TAMSX3("CT3_CUSTO") 
Local aTamVal	:= TAMSX3("CT2_VALOR")
Local aCtbMoeda	:= {}
Local aSaveArea := GetArea()                       
Local aCampos
Local cChave
Local nTamHist	:= Len(CriaVar("CT2_HIST"))
Local nTamItem	:= Len(CriaVar("CTD_ITEM"))
Local nTamCLVL	:= Len(CriaVar("CTH_CLVL"))
Local nDecimais	:= 0    
Local cMensagem		:= "O plano gerencial nao esta disponivel nesse relatorio."// O plano gerencial nao esta disponivel nesse relatorio. 
Local lCriaInd := .F.
Local nTamFilial 	:= IIf( lFWCodFil, FWGETTAMFILIAL, TamSx3( "CT2_FILIAL" )[1] )
Local oTempTable

DEFAULT c2Moeda := ""
DEFAULT nTipo	:= 1
DEFAULT cUFilter:= ""
DEFAULT lSldAnt	:= .F.
DEFAULT aSelFil := {}   
DEFAULT lExterno := .F.

#IFDEF TOP
If TcSrvType() != "AS/400" .And. cTipo == "1" .And. FunName() == 'CTBR400' .And. TCGetDb() $ "MSSQL7/MSSQL"		
	DEFAULT cUFilter	:= ".T."		
Else
#ENDIF

DEFAULT cUFilter	:= ""

#IFDEF TOP
Endif
#ENDIF

// Retorna Decimais
aCtbMoeda := CTbMoeda(cMoeda)
nDecimais := aCtbMoeda[5]
                
aCampos :={	{ "CONTA"		, "C", aTamConta[1], 0 },;  		// Codigo da Conta
			{ "XPARTIDA"   	, "C", aTamConta[1] , 0 },;		// Contra Partida
			{ "TIPO"       	, "C", 01			, 0 },;			// Tipo do Registro (Debito/Credito/Continuacao)
			{ "LANCDEB"		, "N", aTamVal[1]+2, nDecimais },; // Debito
			{ "LANCCRD"		, "N", aTamVal[1]+2	, nDecimais },; // Credito
			{ "SALDOSCR"	, "N", aTamVal[1]+2, nDecimais },; 			// Saldo
			{ "TPSLDANT"	, "C", 01, 0 },; 					// Sinal do Saldo Anterior => Consulta Razao
			{ "TPSLDATU"	, "C", 01, 0 },; 					// Sinal do Saldo Atual => Consulta Razao			
			{ "HISTORICO"	, "C", nTamHist   	, 0 },;			// Historico
			{ "CCUSTO"		, "C", aTamCusto[1], 0 },;			// Centro de Custo
			{ "ITEM"		, "C", nTamItem		, 0 },;			// Item Contabil
			{ "CLVL"		, "C", nTamCLVL		, 0 },;			// Classe de Valor
			{ "DATAL"		, "D", 10			, 0 },;			// Data do Lancamento
			{ "LOTE" 		, "C", 06			, 0 },;			// Lote
			{ "SUBLOTE" 	, "C", 03			, 0 },;			// Sub-Lote
			{ "DOC" 		, "C", 06			, 0 },;			// Documento
			{ "LINHA"		, "C", 03			, 0 },;			// Linha
			{ "SEQLAN"		, "C", 03			, 0 },;			// Sequencia do Lancamento
			{ "SEQHIST"		, "C", 03			, 0 },;			// Seq do Historico
			{ "EMPORI"		, "C", 02			, 0 },;			// Empresa Original
			{ "FILORI"		, "C", nTamFilial	, 0 },;			// Filial Original
			{ "NOMOV"		, "L", 01			, 0 },;			// Conta Sem Movimento
			{ "FILIAL"		, "C", nTamFilial	, 0 }} // Filial do sistema

If cPaisLoc $ "CHI|ARG"
	Aadd(aCampos,{"SEGOFI","C",TamSx3("CT2_SEGOFI")[1],0})
EndIf
If ! Empty(c2Moeda)
	Aadd(aCampos, { "LANCDEB_1"	, "N", aTamVal[1]+2, nDecimais }) // Debito
	Aadd(aCampos, { "LANCCRD_1"	, "N", aTamVal[1]+2, nDecimais }) // Credito
	Aadd(aCampos, { "TXDEBITO"	, "N", aTamVal[1]+2, 6 }) // Taxa Debito
	Aadd(aCampos, { "TXCREDITO"	, "N", aTamVal[1]+2, 6 }) // Taxa Credito
Endif
																	
// Se o arquivo temporario de trabalho esta aberto
If ( Select ( "cArqTmp" ) > 0 )
	cArqTmp->(dbCloseArea())
EndIf

/*
cArqTmp := CriaTrab(aCampos, .T.)
dbUseArea( .T.,, cArqTmp, "cArqTmp", .F., .F. )
*/

If(oTempTable <> NIL)
	oTempTable:Delete()
	oTempTable := NIL
EndIf
oTempTable := FWTemporaryTable():New("cArqTmp")
oTempTable:SetFields( aCampos )
//oTempTable:AddIndex("1", {"LANCDEB_1", "LANCCRD_1"} )
oTempTable:Create()

//DbSelectArea("cArqTmp")
//cArqTmp->(DbSetOrder(1))


lCriaInd := .T.

DbSelectArea("cArqTmp")

//��������������������������������������������������������������Ŀ
//� Cria Indice Temporario do Arquivo de Trabalho 1.             �
//����������������������������������������������������������������
If cTipo == "1"			// Razao por Conta
    If FunName() <> "CTBC400"
		cChave   := "CONTA+DTOS(DATAL)+LOTE+SUBLOTE+DOC+LINHA+EMPORI+FILORI"
	Else
		cChave   := "CONTA+DTOS(DATAL)+LOTE+SUBLOTE+DOC+EMPORI+FILORI+LINHA"
	EndIf
ElseIf cTipo == "2"		// Razao por Centro de Custo                   
	If lAnalit 				// Se o relatorio for analitico
		If FunName() <> "CTBC440"
			If FunName() <> "CTBR440"
				cChave 	:= "CCUSTO+CONTA+DTOS(DATAL)+LOTE+SUBLOTE+DOC+LINHA+EMPORI+FILORI"
			Else
				cChave 	:= "FILIAL+CCUSTO+CONTA+DTOS(DATAL)+LOTE+SUBLOTE+DOC+LINHA+EMPORI+FILORI"
			EndIf
		Else
			cChave 	:= "CCUSTO+CONTA+DTOS(DATAL)+LOTE+SUBLOTE+DOC+EMPORI+FILORI+LINHA"		
		EndIf
	Else    
		If FunName() <> "CTBR440"
	   		cChave 	:= "CCUSTO+CONTA+DTOS(DATAL)+LOTE+SUBLOTE+DOC+LINHA+EMPORI+FILORI"
        Else                                                      
			cChave 	:= "FILIAL+CCUSTO+DTOS(DATAL)+LOTE+SUBLOTE+DOC+LINHA+EMPORI+FILORI"
		EndIf
	Endif
ElseIf cTipo == "3" 		//Razao por Item Contabil      
	If lAnalit 				// Se o relatorio for analitico               
		If FunName() <> "CTBC480"
			cChave 	:= "ITEM+CONTA+DTOS(DATAL)+LOTE+SUBLOTE+DOC+LINHA+EMPORI+FILORI"
		Else
			cChave 	:= "ITEM+CONTA+DTOS(DATAL)+LOTE+SUBLOTE+DOC+EMPORI+FILORI+LINHA"		
		Endif
	Else                                                                  
		cChave 	:= "ITEM+DTOS(DATAL)+LOTE+SUBLOTE+DOC+LINHA+EMPORI+FILORI"
	Endif
ElseIf cTipo == "4"		//Razao por Classe de Valor	
	If lAnalit 				// Se o relatorio for analitico               
		If FunName() <> "CTBC490"	
			cChave 	:= "CLVL+CONTA+DTOS(DATAL)+LOTE+SUBLOTE+DOC+LINHA+EMPORI+FILORI"
		Else
			cChave 	:= "CLVL+CONTA+DTOS(DATAL)+LOTE+SUBLOTE+DOC+EMPORI+FILORI+LINHA"
		EndIf
	Else                                                                  
		cChave 	:= "CLVL+DTOS(DATAL)+LOTE+SUBLOTE+DOC+LINHA+EMPORI+FILORI"
	Endif	
EndIf

dbSelectArea("cArqTmp")

If lCriaInd
	IndRegua("cArqTmp",cArqTmp,cChave,,,"Selecionando Registros...")  //"Selecionando Registros..."
	dbSelectArea("cArqTmp")
	dbSetIndex(cArqTmp+OrdBagExt())
Endif	
dbSetOrder(1)
                                                                                        
If !Empty(aSetOfBook[5])
	MsgAlert(cMensagem)	
	Return
EndIf                   

//CT2->(dbGotop())
#IFDEF TOP
	If TcSrvType() != "AS/400" .And. cTipo == "1" .And. FunName() == 'CTBR400' .And. TCGetDb() $ "MSSQL7/MSSQL"		
		CtbQryRaz(oMeter,oText,oDlg,lEnd,cContaIni,cContaFim,cCustoIni,cCustoFim,;
				cItemIni,cItemFim,cCLVLIni,cCLVLFim,cMoeda,dDataIni,dDataFim,;
				aSetOfBook,lNoMov,cSaldo,lJunta,cTipo,c2Moeda,cUFilter,lSldAnt,aSelFil,lExterno)	
	Else
#ENDIF
	// Monta Arquivo para gerar o Razao
	CtbRazao(oMeter,oText,oDlg,lEnd,cContaIni,cContaFim,cCustoIni,cCustoFim,;
			cItemIni,cItemFim,cCLVLIni,cCLVLFim,cMoeda,dDataIni,dDataFim,;
			aSetOfBook,lNoMov,cSaldo,lJunta,cTipo,c2Moeda,nTipo,cUFilter,lSldAnt,aSelFil,lExterno)
#IFDEF TOP
	EndIf
#ENDIF	

RestArea(aSaveArea)

Return cArqTmp

/*/
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
��� Fun��o    �CtbRazao  � Autor � Pilar S. Albaladejo   � Data � 05/02/01 ���
��������������������������������������������������������������������������Ĵ��
��� Descri��o �Realiza a "filtragem" dos registros do Razao                ���
��������������������������������������������������������������������������Ĵ��
���Sintaxe    �CtbRazao(oMeter,oText,oDlg,lEnd,cContaIni,cContaFim,		   ���
���			  �cCustoIni,cCustoFim, cItemIni,cItemFim,cCLVLIni,cCLVLFim,   ���
���			  �cMoeda,dDataIni,dDataFim,aSetOfBook,lNoMov,cSaldo,lJunta,   ���
���			  �cTipo)                                                      ���
��������������������������������������������������������������������������Ĵ��
���Retorno    �Nenhum                                                      ���
��������������������������������������������������������������������������Ĵ��
��� Uso       � SIGACTB                                                    ���
��������������������������������������������������������������������������Ĵ��
���Parametros � ExpO1 = Objeto oMeter                                      ���
���           � ExpO2 = Objeto oText                                       ���
���           � ExpO3 = Objeto oDlg                                        ���
���           � ExpL1 = Acao do Codeblock                                  ���
���           � ExpC2 = Conta Inicial                                      ���
���           � ExpC3 = Conta Final                                        ���
���           � ExpC4 = C.Custo Inicial                                    ���
���           � ExpC5 = C.Custo Final                                      ���
���           � ExpC6 = Item Inicial                                       ���
���           � ExpC7 = Cl.Valor Inicial                                   ���
���           � ExpC8 = Cl.Valor Final                                     ���
���           � ExpC9 = Moeda                                              ���
���           � ExpD1 = Data Inicial                                       ���
���           � ExpD2 = Data Final                                         ���
���           � ExpA1 = Matriz aSetOfBook                                  ���
���           � ExpL2 = Indica se imprime movimento zerado ou nao.         ���
���           � ExpC10= Tipo de Saldo                                      ���
���           � ExpL3 = Indica se junta CC ou nao.                         ���
���           � ExpC11= Tipo do lancamento                                 ���
���           � c2Moeda = Indica moeda 2 a ser incluida no relatorio       ���
���           � cUFilter= Conteudo Txt com o Filtro de Usuario (CT2)       ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������
/*/
Static Function CtbRazao(oMeter,oText,oDlg,lEnd,cContaIni,cContaFim,cCustoIni,cCustoFim,;
					  	cItemIni,cItemFim,cCLVLIni,cCLVLFim,cMoeda,dDataIni,dDataFim,;
					  	aSetOfBook,lNoMov,cSaldo,lJunta,cTipo,c2Moeda,nTipo,cUFilter,lSldAnt,aSelFil,lExterno)

Local cCpoChave	:= ""
Local cTmpChave	:= ""
Local cContaI	:= ""
Local cContaF	:= ""
Local cCustoI	:= ""
Local cCustoF	:= ""
Local cItemI	:= ""
Local cItemF	:= ""
Local cClVlI	:= ""
Local cClVlF	:= ""
Local cVldEnt	:= ""
Local cAlias	:= ""
Local lUFilter	:= !Empty(cUFilter)			//// SE O FILTRO DE USU�RIO N�O ESTIVER VAZIO - TEM FILTRO DE USU�RIO
Local cFilMoeda	:= "" 							
Local cAliasCT2	:= "CT2"	
Local bCond		:= {||.T.}
Local cQryFil	:= '' // variavel de condicional da query
Local cTmpCT2Fil

#IFDEF TOP
	Local cQuery	:= ""
	Local cOrderBy	:= ""
	Local nI	:= 0
	Local aStru	:= {}
#ENDIF

DEFAULT cUFilter := ".T."
DEFAULT lSldAnt	 := .F.
DEFAULT aSelFil  := {}      
DEFAULT lExterno := .F.

cQryFil := " CT2_FILIAL " + GetRngFil( aSelFil ,"CT2", .T., @cTmpCT2Fil) 

cCustoI	:= CCUSTOINI
cCustoF := CCUSTOFIM
cContaI	:= CCONTAINI
cContaF := CCONTAFIM
cItemI	:= CITEMINI      
cItemF 	:= CITEMFIM
cClvlI	:= CCLVLINI
cClVlF 	:= CCLVLFIM

#IFDEF TOP
	If TcSrvType() != "AS/400"
		If !Empty(c2Moeda) 			
			cFilMoeda	:= " (CT2_MOEDLC = '" + cMoeda + "' OR "		
			cFilMoeda	+= " CT2_MOEDLC = '" + c2Moeda + "') " 			
		Else
			cFilMoeda	:= " CT2_MOEDLC = '" + cMoeda + "' "				
		EndIf
	Else
#ENDIF 
	If !Empty(c2Moeda) 			
		cFilMoeda	:= " (CT2_MOEDLC = '" + cMoeda + "' .Or. "		
		cFilMoeda	+= " CT2_MOEDLC = '" + c2Moeda + "') " 			
	Else
		cFilMoeda	:= " CT2_MOEDLC = '" + cMoeda + "' "				
	EndIf
#IFDEF TOP
	EndIf
#ENDIF 

If !lExterno
	oMeter:nTotal := CT1->(RecCount())
Endif

// ������������������Ŀ
// � Obt�m os d�bitos �
// ��������������������

If cTipo <> "1"
	If cTipo = "2" .And. Empty(cCustoIni)
		CTT->(DbSeek(xFilial("CTT")))
		cCustoIni := CTT->CTT_CUSTO
	Endif
	If cTipo = "3" .And. Empty(cItemIni)
		CTD->(DbSeek(xFilial("CTD")))
		cItemIni := CTD->CTD_ITEM
	Endif
	If cTipo = "4" .And. Empty(cClVlIni)
		CTH->(DbSeek(xFilial("CTH")))
		cClVlIni := CTH->CTH_CLVL
	Endif
Endif

#IFDEF TOP
	If TcSrvType() != "AS/400"

		If cTipo == "1"
			dbSelectArea("CT2")
			dbSetOrder(2)
			cValid	:= 	"CT2_DEBITO>='" + cContaIni + "' AND " +;
						"CT2_DEBITO<='" + cContaFim + "'"
			cVldEnt := 	"CT2_CCD>='" + cCustoIni + "' AND " +;
						"CT2_CCD<='" + cCustoFim + "' AND " +;
						"CT2_ITEMD>='" + cItemIni + "' AND " +;
						"CT2_ITEMD<='" + cItemFim + "' AND " +;
						"CT2_CLVLDB>='" + cClVlIni + "' AND " +;
						"CT2_CLVLDB<='" + cClVlFim + "'"						
			cOrderBy:= " CT2_FILIAL, CT2_DEBITO, CT2_DATA "
		ElseIf cTipo == "2"
			dbSelectArea("CT2")
			dbSetOrder(4)
			cValid	:= 	"CT2_CCD >= '" + cCustoIni + "'  AND  " +;
						"CT2_CCD <= '" + cCustoFim + "'"
			cVldEnt := 	"CT2_DEBITO >= '" + cContaIni + "'  AND  " +;
						"CT2_DEBITO <= '" + cContaFim + "'  AND  " +;
						"CT2_ITEMD >= '" + cItemIni + "'  AND  " +;
						"CT2_ITEMD <= '" + cItemFim + "'  AND  " +;
						"CT2_CLVLDB >= '" + cClVlIni + "'  AND  " +;
						"CT2_CLVLDB <= '" + cClVlFim + "'" 
			cOrderBy:= " CT2_FILIAL, CT2_CCD, CT2_DATA "						
		ElseIf cTipo == "3"
			dbSelectArea("CT2")
			dbSetOrder(6)
			cValid 	:= 	"CT2_ITEMD >= '" + cItemIni + "'  AND  " +;
						"CT2_ITEMD <= '" + cItemFim + "'"
			cVldEnt	:= 	"CT2_DEBITO >= '" + cContaIni + "'  AND  " +;
						"CT2_DEBITO <= '" + cContaFim + "'  AND  " +;
						"CT2_CCD >= '" + cCustoIni + "'  AND  " +;
						"CT2_CCD <= '" + cCustoFim + "'  AND  " +;
						"CT2_CLVLDB >= '" + cClVlIni + "'  AND  " +;
						"CT2_CLVLDB <= '" + cClVlFim + "'"
			cOrderBy:= " CT2_FILIAL, CT2_ITEMD, CT2_DATA "												
		ElseIf cTipo == "4"
			dbSelectArea("CT2")
			dbSetOrder(8)
			cValid 	:= 	"CT2_CLVLDB >= '" + cClVlIni + "'  AND  " +;
						"CT2_CLVLDB <= '" + cClVlFim + "'"
			cVldEnt	:= 	"CT2_DEBITO >= '" + cContaIni + "'  AND  " +;
						"CT2_DEBITO <= '" + cContaFim + "'  AND  " +;
						"CT2_CCD >= '" + cCustoIni + "'  AND  " +;
						"CT2_CCD <= '" + cCustoFim + "'  AND  " +;
						"CT2_ITEMD >= '" + cItemIni + "'  AND  " +;
						"CT2_ITEMD <= '" + cItemFim + "'"
			cOrderBy:= " CT2_FILIAL, CT2_CLVLDB, CT2_DATA "												
		EndIf                                           

		cAliasCT2	:= "cAliasCT2"
		
		cQuery	:= " SELECT * "
		cQuery	+= " FROM " + RetSqlName("CT2")  
		cQuery	+= " WHERE " + cQryFil + " AND "
		cQuery	+= cValid + " AND "
		cQuery	+= " CT2_DATA >= '" + DTOS(dDataIni) + "' AND "
		cQuery	+= " CT2_DATA <= '" + DTOS(dDataFim) + "' AND "
		cQuery	+= cVldEnt+ " AND " 
		cQuery	+= cFilMoeda + " AND " 
		cQuery	+= " CT2_TPSALD = '"+ cSaldo + "'"
		cQuery	+= " AND (CT2_DC = '1' OR CT2_DC = '3')"
		cQuery   += " AND CT2_VALOR <> 0 "
		cQuery	+= " AND D_E_L_E_T_ = ' ' " 
		cQuery	+= " ORDER BY "+ cOrderBy
		cQuery := ChangeQuery(cQuery)
		
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasCT2,.T.,.F.)
		aStru := CT2->(dbStruct())
		
		For ni := 1 to Len(aStru)
			If aStru[ni,2] != 'C'
				TCSetField(cAliasCT2, aStru[ni,1], aStru[ni,2],aStru[ni,3],aStru[ni,4])
			Endif
		Next ni		

		If lUFilter					//// ADICIONA O FILTRO DEFINIDO PELO USU�RIO SE N�O ESTIVER EM BRANCO
			If !Empty(cVldEnt)
				cVldEnt  += " AND "			/// SE J� TIVER CONTEUDO, ADICIONA "AND"				
				cVldEnt  += cUFilter				/// ADICIONA O FILTRO DE USU�RIO		
			EndIf		
		EndIf	
		                                     
		If (!lUFilter) .or. Empty(cUFilter)
			cUFilter := ".T."
		EndIf			
		
		dbSelectArea(cAliasCT2)				
		While !Eof()
			If &cUFilter
				CtbGrvRAZ(lJunta,cMoeda,cSaldo,"1",c2Moeda,cAliasCT2,nTipo)
				dbSelectArea(cAliasCT2)
			EndIf
			dbSkip()
		EndDo			
		If ( Select ( "cAliasCT2" ) <> 0 )
			dbSelectArea ( "cAliasCT2" )
			dbCloseArea ()
		Endif
		
    Else    
#ENDIF    
	If cTipo == "1"
		dbSelectArea("CT2")                              
		dbSetOrder(2)
		cValid	:= 	"CT2_DEBITO>='" + cContaIni + "' .And. " +;
					"CT2_DEBITO<='" + cContaFim + "'"
		cVldEnt := 	"CT2_CCD>='" + cCustoIni + "' .And. " +;
					"CT2_CCD<='" + cCustoFim + "' .And. " +;
					"CT2_ITEMD>='" + cItemIni + "' .And. " +;
					"CT2_ITEMD<='" + cItemFim + "' .And. " +;
					"CT2_CLVLDB>='" + cClVlIni + "' .And. " +;
					"CT2_CLVLDB<='" + cClVlFim + "'"
		bCond 	:= { ||CT2->CT2_DEBITO >= cContaIni .And. CT2->CT2_DEBITO <= cContaFim}
	ElseIf cTipo == "2"
		dbSelectArea("CT2")
		dbSetOrder(4)
		cValid	:= 	"CT2_CCD >= '" + cCustoIni + "'  .And.  " +;
					"CT2_CCD <= '" + cCustoFim + "'"
		cVldEnt := 	"CT2_DEBITO >= '" + cContaIni + "'  .And.  " +;
					"CT2_DEBITO <= '" + cContaFim + "'  .And.  " +;
					"CT2_ITEMD >= '" + cItemIni + "'  .And.  " +;
					"CT2_ITEMD <= '" + cItemFim + "'  .And.  " +;
					"CT2_CLVLDB >= '" + cClVlIni + "'  .And.  " +;
					"CT2_CLVLDB <= '" + cClVlFim + "'"
	ElseIf cTipo == "3"
		dbSelectArea("CT2")
		dbSetOrder(6)
		cValid 	:= 	"CT2_ITEMD >= '" + cItemIni + "'  .And.  " +;
					"CT2_ITEMD <= '" + cItemFim + "'"
		cVldEnt	:= 	"CT2_DEBITO >= '" + cContaIni + "'  .And.  " +;
					"CT2_DEBITO <= '" + cContaFim + "'  .And.  " +;
					"CT2_CCD >= '" + cCustoIni + "'  .And.  " +;
					"CT2_CCD <= '" + cCustoFim + "'  .And.  " +;
					"CT2_CLVLDB >= '" + cClVlIni + "'  .And.  " +;
					"CT2_CLVLDB <= '" + cClVlFim + "'"
	ElseIf cTipo == "4"
		dbSelectArea("CT2")
		dbSetOrder(8)
		cValid 	:= 	"CT2_CLVLDB >= '" + cClVlIni + "'  .And.  " +;
					"CT2_CLVLDB <= '" + cClVlFim + "'"
		cVldEnt	:= 	"CT2_DEBITO >= '" + cContaIni + "'  .And.  " +;
					"CT2_DEBITO <= '" + cContaFim + "'  .And.  " +;
					"CT2_CCD >= '" + cCustoIni + "'  .And.  " +;
					"CT2_CCD <= '" + cCustoFim + "'  .And.  " +;
					"CT2_ITEMD >= '" + cItemIni + "'  .And.  " +;
					"CT2_ITEMD <= '" + cItemFim + "'"
	EndIf
		
	If lUFilter					//// ADICIONA O FILTRO DEFINIDO PELO USU�RIO SE N�O ESTIVER EM BRANCO
		If !Empty(cVldEnt)
			cVldEnt  += " .and. "			/// SE J� TIVER CONTEUDO, ADICIONA ".AND."		
		EndIf
	Endif
	
	cVldEnt  += cUFilter				/// ADICIONA O FILTRO DE USU�RIO		
		
	If cTipo == "1"						/// TRATAMENTO CONTAS A CREDITO

		dbSelectArea("CT2")
		dbSetOrder(2)
		
		dbSelectArea("CT1")
		dbSetOrder(3)
		cFilCT1 := xFilial("CT1")
		cFilCT2	:= xFilial("CT2")
		cContaIni := If(Empty(cContaIni),"",cContaIni)		/// Se tiver espacos em branco usa "" p/ seek
		dbSeek(cFilCT1+"2"+cContaIni,.T.)					/// Procura inicial analitica
		
		While CT1->(!Eof()) .and. CT1->CT1_FILIAL == cFilCT1 .And. CT1->CT1_CONTA <= cContaFim
			dbSelectArea("CT2")
			MsSeek(cFilCT2+CT1->CT1_CONTA+DTOS(dDataIni),.T.)
			While !Eof() .And. CT2->CT2_FILIAL == cFilCT2 .And. CT2->CT2_DEBITO == CT1->CT1_CONTA .and. CT2->CT2_DATA <= dDataFim
		        
				If CT2->CT2_VALOR = 0
					dbSkip()
					Loop				
				EndIf
		
				If Empty(c2Moeda)			
					If CT2->CT2_MOEDLC <> cMoeda
						dbSkip()
						Loop
					EndIF
				Else
					If !(&(cFilMoeda))
						dbSkip()
						Loop
					EndIf			
				EndIf
				
				If (CT2->CT2_DC == "1" .Or. CT2->CT2_DC == "3") .And. &(cValid) .And. &(cVldEnt) .And. CT2->CT2_TPSALD == cSaldo
					CT2->(CtbGrvRAZ(lJunta,cMoeda,cSaldo,"1",c2Moeda,cAliasCT2,nTipo))
				Endif
				dbSelectArea("CT2")
				dbSkip()
			EndDo
			CT1->(dbSkip())
		EndDo
	Else
		dbSelectArea("CT2")

		cTabCad := "CTT"
		cEntIni	:= cCustoIni
		bCond 	:= { || CT2->CT2_CCD == CTT->CTT_CUSTO}
		bCondCad:= { || .T.}
		dbSetOrder(4)

		If cTipo == "3"
			cTabCad := "CTD"
			cEntIni := cItemIni
			bCond 	:= { || CT2->CT2_ITEMD == CTD->CTD_ITEM}			
			dbSetOrder(6)
		ElseIf cTipo == "4"
			cTabCad := "CTH"
			cEntIni := cCLVLIni
			bCond 	:= { || CT2->CT2_CLVLDB == CTH->CTH_CLVL}					
			dbSetOrder(8)
		EndIf
		
		dbSelectArea(cTabCad)
		dbSetOrder(2)
		cFilEnt := xFilial(cTabCad)
		cFilCT2	:= xFilial("CT2")
		cEntIni := If(Empty(cEntIni),"",cEntIni)		/// Se tiver espacos em branco usa "" p/ seek
		dbSeek(cFilEnt+"2"+cEntIni,.T.)					/// Procura inicial analitica
		
		If cTipo == "2"
			bCondCad := {|| CTT->CTT_FILIAL == cFilEnt .and. CTT->CTT_CUSTO <= cCustoFim }
		ElseIf cTipo == "3"
   			bCondCad := {|| CTD->CTD_FILIAL == cFilEnt .and. CTD->CTD_ITEM <= cItemFim }
  		ElseIf cTipo == "4"
			bCondCad := {|| CTH->CTH_FILIAL == cFilEnt .and. CTH->CTH_CLVL <= cCLVLFim }  		
  		EndIf
		
		While (cTabCad)->(!Eof()) .and. Eval(bCondCad)			/// WHILE DO CADASTRO DE ENTIDADES
	
			dbSelectArea("CT2")    			
			If cTipo == "2"
				MsSeek(cFilCT2+CTT->CTT_CUSTO+DTOS(dDataIni),.T.)
			ElseIf cTipo == "3"
				MsSeek(cFilCT2+CTD->CTD_ITEM+DTOS(dDataIni),.T.)			
			Else
				MsSeek(cFilCT2+CTH->CTH_CLVL+DTOS(dDataIni),.T.)						
			EndIf

			dbSelectArea("CT2")									/// WHILE CT2 - DEBITOS
			While CT2->(!Eof()) .And. CT2->CT2_FILIAL == cFilCT2 .and. Eval(bCond) .and. CT2->CT2_DATA <= dDataFim
		
				If CT2->CT2_VALOR = 0
					dbSkip()
					Loop				
				EndIf

				If Empty(c2Moeda)			
					If CT2->CT2_MOEDLC <> cMoeda
						dbSkip()
						Loop
					EndIF
				Else
					If !(&(cFilMoeda))
						dbSkip()
						Loop
					EndIf			
				EndIf
				
				If (CT2->CT2_DC == "1" .Or. CT2->CT2_DC == "3") .And. &(cVldEnt) .And. CT2->CT2_TPSALD == cSaldo
					CT2->(CtbGrvRAZ(lJunta,cMoeda,cSaldo,"1",c2Moeda,cAliasCT2,nTipo))
				Endif
				dbSelectArea("CT2")
				dbSkip()
			EndDo	
			(cTabCad)->(dbSkip())
		EndDo
	Endif
		
#IFDEF TOP
	EndIf
#ENDIF


// ������������������Ŀ
// � Obt�m os creditos�
// ��������������������
If cTipo == "1"
	dbSelectArea("CT2")
	dbSetOrder(3)
ElseIf cTipo == "2"
	dbSelectArea("CT2")
	dbSetOrder(5)
ElseIf cTipo == "3"
	dbSelectArea("CT2")
	dbSetOrder(7)
ElseIf cTipo == "4"		
	dbSelectArea("CT2")
	dbSetOrder(9)
EndIf

#IFDEF TOP
	If TcSrvType() != "AS/400"                          
		If cTipo == "1"
			cValid	:= 	"CT2_CREDIT>='" + cContaIni + "' AND " +;
						"CT2_CREDIT<='" + cContaFim + "'"
			cVldEnt :=	"CT2_CCC>='" + cCustoIni + "' AND " +;
						"CT2_CCC<='" + cCustoFim + "' AND " +;
						"CT2_ITEMC>='" + cItemIni + "' AND " +;
						"CT2_ITEMC<='" + cItemFim + "' AND " +;
						"CT2_CLVLCR>='" + cClVlIni + "' AND " +;
						"CT2_CLVLCR<='" + cClVlFim + "'"
			cOrderBy:= " CT2_FILIAL, CT2_CREDIT, CT2_DATA "																	
		ElseIf cTipo == "2"
			cValid 	:= 	"CT2_CCC >= '" + cCustoIni + "'  AND  " +;
						"CT2_CCC <= '" + cCustoFim + "'"
			cVldEnt	:= 	"CT2_CREDIT >= '" + cContaIni + "'  AND  " +;
						"CT2_CREDIT <= '" + cContaFim + "'  AND  " +;
						"CT2_ITEMC >= '" + cItemIni + "'  AND  " +;
						"CT2_ITEMC <= '" + cItemFim + "'  AND  " +;
						"CT2_CLVLCR >= '" + cClVlIni + "'  AND  " +;
						"CT2_CLVLCR <= '" + cClVlFim + "'"
			cOrderBy:= " CT2_FILIAL, CT2_CCC, CT2_DATA "																	
		ElseIf cTipo == "3"
			cValid 	:= 	"CT2_ITEMC >= '" + cItemIni + "'  AND  " +;
						"CT2_ITEMC <= '" + cItemFim + "'"
			cVldEnt := 	"CT2_CREDIT >= '" + cContaIni + "'  AND  " +;
						"CT2_CREDIT <= '" + cContaFim + "'  AND  " +;
						"CT2_CCC >= '" + cCustoIni + "'  AND  " +;
						"CT2_CCC <= '" + cCustoFim + "'  AND  " +;
						"CT2_CLVLCR >= '" + cClVlIni + "'  AND  " +;
						"CT2_CLVLCR <= '" + cClVlFim + "'"
			cOrderBy:= " CT2_FILIAL, CT2_ITEMC, CT2_DATA "																	
		ElseIf cTipo == "4"		
			cValid 	:= 	"CT2_CLVLCR >= '" + cClVlIni + "'  AND  " +;
						"CT2_CLVLCR <= '" + cClVlFim + "'"
			cVldEnt := 	"CT2_CREDIT >= '" + cContaIni + "'  AND  " +;
						"CT2_CREDIT <= '" + cContaFim + "'  AND  " +;
						"CT2_CCC >= '" + cCustoIni + "'  AND  " +;
						"CT2_CCC <= '" + cCustoFim + "'  AND  " +;
						"CT2_ITEMC >= '" + cItemIni + "'  AND  " +;
						"CT2_ITEMC <= '" + cItemFim + "'"
			cOrderBy:= " CT2_FILIAL, CT2_CLVLCR, CT2_DATA "																						
		EndIf	                    
		
		cAliasCT2	:= "cAliasCT2"		
		
		cQuery	:= " SELECT * "
		cQuery	+= " FROM " + RetSqlName("CT2")  
		cQuery	+= " WHERE " + cQryFil + " AND "
		cQuery	+= cValid + " AND "
		cQuery	+= " CT2_DATA >= '" + DTOS(dDataIni) + "' AND "
		cQuery	+= " CT2_DATA <= '" + DTOS(dDataFim) + "' AND "
		cQuery	+= cVldEnt+ " AND " 
		cQuery	+= cFilMoeda + " AND " 
		cQuery	+= " CT2_TPSALD = '"+ cSaldo + "' AND "  
		cQuery	+= " (CT2_DC = '2' OR CT2_DC = '3') AND "
		cQuery	+= " CT2_VALOR <> 0 AND "
		cQuery	+= " D_E_L_E_T_ = ' ' " 
		cQuery	+= " ORDER BY "+ cOrderBy
		cQuery := ChangeQuery(cQuery)
			
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasCT2,.T.,.F.)
		
		aStru := CT2->(dbStruct())
		
		For ni := 1 to Len(aStru)
			If aStru[ni,2] != 'C'
				TCSetField(cAliasCT2, aStru[ni,1], aStru[ni,2],aStru[ni,3],aStru[ni,4])
			Endif
		Next ni		
		

		If lUFilter					//// ADICIONA O FILTRO DEFINIDO PELO USU�RIO SE N�O ESTIVER EM BRANCO
			If !Empty(cVldEnt)
				cVldEnt  += " AND "			/// SE J� TIVER CONTEUDO, ADICIONA "AND"				
				cVldEnt  += cUFilter				/// ADICIONA O FILTRO DE USU�RIO		
			EndIf		
		EndIf	
		
		If (!lUFilter) .or. Empty(cUFilter)
			cUFilter := ".T."
		EndIf			
		
		dbSelectArea(cAliasCT2)				
		While !Eof()
			If &cUFilter
				CtbGrvRAZ(lJunta,cMoeda,cSaldo,"2",c2Moeda,cAliasCT2,nTipo)
				dbSelectArea(cAliasCT2)
		    EndIf
			dbSkip()
		EndDo
		
		If ( Select ( "cAliasCT2" ) <> 0 )
			dbSelectArea ( "cAliasCT2" )
			dbCloseArea ()
		Endif

	Else
#ENDIF
	bCond	:= {||.T.}

	If cTipo == "1"
		cValid	:= 	"CT2_CREDIT>='" + cContaIni + "'.And." +;
					"CT2_CREDIT<='" + cContaFim + "'"
		cVldEnt :=	"CT2_CCC>='" + cCustoIni + "'.And." +;
					"CT2_CCC<='" + cCustoFim + "'.And." +;
					"CT2_ITEMC>='" + cItemIni + "'.And." +;
					"CT2_ITEMC<='" + cItemFim + "'.And." +;
					"CT2_CLVLCR>='" + cClVlIni + "'.And." +;
					"CT2_CLVLCR<='" + cClVlFim + "'"
		bCond 	:= { ||CT2->CT2_CREDIT >= cContaIni .And. CT2->CT2_CREDIT <= cContaFim}
	ElseIf cTipo == "2"
		cValid 	:= 	"CT2_CCC >= '" + cCustoIni + "' .And. " +;
					"CT2_CCC <= '" + cCustoFim + "'"
		cVldEnt	:= 	"CT2_CREDIT >= '" + cContaIni + "' .And. " +;
					"CT2_CREDIT <= '" + cContaFim + "' .And. " +;
					"CT2_ITEMC >= '" + cItemIni + "' .And. " +;
					"CT2_ITEMC <= '" + cItemFim + "' .And. " +;
					"CT2_CLVLCR >= '" + cClVlIni + "' .And. " +;
					"CT2_CLVLCR <= '" + cClVlFim + "'"
	ElseIf cTipo == "3"
		cValid 	:= 	"CT2_ITEMC >= '" + cItemIni + "' .And. " +;
					"CT2_ITEMC <= '" + cItemFim + "'"
		cVldEnt := 	"CT2_CREDIT >= '" + cContaIni + "' .And. " +;
					"CT2_CREDIT <= '" + cContaFim + "' .And. " +;
					"CT2_CCC >= '" + cCustoIni + "' .And. " +;
					"CT2_CCC <= '" + cCustoFim + "' .And. " +;
					"CT2_CLVLCR >= '" + cClVlIni + "' .And. " +;
					"CT2_CLVLCR <= '" + cClVlFim + "'"
	ElseIf cTipo == "4"		
		cValid 	:= 	"CT2_CLVLCR >= '" + cClVlIni + "' .And. " +;
					"CT2_CLVLCR <= '" + cClVlFim + "'"
		cVldEnt := 	"CT2_CREDIT >= '" + cContaIni + "' .And. " +;
					"CT2_CREDIT <= '" + cContaFim + "' .And. " +;
					"CT2_CCC >= '" + cCustoIni + "' .And. " +;
					"CT2_CCC <= '" + cCustoFim + "' .And. " +;
					"CT2_ITEMC >= '" + cItemIni + "' .And. " +;
					"CT2_ITEMC <= '" + cItemFim + "'"
	EndIf	
	
	If lUFilter					//// ADICIONA O FILTRO DEFINIDO PELO USU�RIO SE N�O ESTIVER EM BRANCO
		If !Empty(cVldEnt)
			cVldEnt  += " .and. "			/// SE J� TIVER CONTEUDO, ADICIONA ".AND."		
		EndIf
	Endif
	
	cVldEnt  += cUFilter				/// ADICIONA O FILTRO DE USU�RIO		
	
	If cTipo == "1"						/// TRATAMENTO CONTAS A CREDITO
		dbSelectArea("CT2")
		dbSetOrder(3)
		
		dbSelectArea("CT1")
		dbSetOrder(3)
		cFilCT1 := xFilial("CT1")
		cFilCT2	:= xFilial("CT2")
		cContaIni := If(Empty(cContaIni),"",cContaIni)		/// Se tiver espacos em branco usa "" p/ seek
		dbSeek(cFilCT1+"2"+cContaIni,.T.)					/// Procura inicial analitica
		
		While CT1->(!Eof()) .and. CT1->CT1_FILIAL == cFilCT1 .And. CT1->CT1_CONTA <= cContaFim
			dbSelectArea("CT2")
			MsSeek(cFilCT2+CT1->CT1_CONTA+DTOS(dDataIni),.T.)
			While !Eof() .And. CT2->CT2_FILIAL == cFilCT2 .And. CT2->CT2_CREDIT == CT1->CT1_CONTA .and. CT2->CT2_DATA <= dDataFim

				If CT2->CT2_VALOR = 0
					dbSkip()
					Loop				
				EndIf
	
				If (CT2->CT2_DC == "2" .Or. CT2->CT2_DC == "3") .And. &(cValid) .And. &(cVldEnt) .And. CT2->CT2_TPSALD == cSaldo
					If Empty(c2Moeda)			
						If CT2->CT2_MOEDLC <> cMoeda
							dbSkip()
							Loop
						EndIF
					Else
						If !(&(cFilMoeda))
							dbSkip()
							Loop
						EndIf			
					EndIf			
					CT2->(CtbGrvRAZ(lJunta,cMoeda,cSaldo,"2",c2Moeda,cAliasCT2,nTipo))
				Endif
				dbSelectArea("CT2")
				dbSkip()
			EndDo			
			CT1->(dbSkip())
		EndDo
	Else
		dbSelectArea("CT2")

		cTabCad := "CTT"
		cEntIni	:= cCustoIni
		bCond 	:= { || CT2->CT2_CCC == CTT->CTT_CUSTO}
		bCondCad:= { || .T.}
		dbSetOrder(5)

		If cTipo == "3"
			cTabCad := "CTD"
			cEntIni := cItemIni
			bCond 	:= { || CT2->CT2_ITEMC == CTD->CTD_ITEM}			
			dbSetOrder(7)
		ElseIf cTipo == "4"
			cTabCad := "CTH"
			cEntIni := cCLVLIni
			bCond 	:= { || CT2->CT2_CLVLCR == CTH->CTH_CLVL}					
			dbSetOrder(9)
		EndIf
		
		dbSelectArea(cTabCad)
		dbSetOrder(2)
		cFilEnt := xFilial(cTabCad)
		cFilCT2	:= xFilial("CT2")
		cEntIni := If(Empty(cEntIni),"",cEntIni)		/// Se tiver espacos em branco usa "" p/ seek
		dbSeek(cFilEnt+"2"+cEntIni,.T.)					/// Procura inicial analitica
		
		If cTipo == "2"
			bCondCad := {|| CTT->CTT_FILIAL == cFilEnt .and. CTT->CTT_CUSTO <= cCustoFim }
		ElseIf cTipo == "3"
   			bCondCad := {|| CTD->CTD_FILIAL == cFilEnt .and. CTD->CTD_ITEM <= cItemFim }
  		ElseIf cTipo == "4"
			bCondCad := {|| CTH->CTH_FILIAL == cFilEnt .and. CTH->CTH_CLVL <= cCLVLFim }  		
  		EndIf
		
		While (cTabCad)->(!Eof()) .and. Eval(bCondCad)			/// WHILE DO CADASTRO DE ENTIDADES
	
			dbSelectArea("CT2")    	
			If cTipo == "2"
				MsSeek(cFilCT2+CTT->CTT_CUSTO+DTOS(dDataIni),.T.)
			ElseIf cTipo == "3"
				MsSeek(cFilCT2+CTD->CTD_ITEM+DTOS(dDataIni),.T.)			
			Else
				MsSeek(cFilCT2+CTH->CTH_CLVL+DTOS(dDataIni),.T.)						
			EndIf

			dbSelectArea("CT2")									/// WHILE CT2 - CREDITO
			While CT2->(!Eof()) .And. CT2->CT2_FILIAL == cFilCT2 .and. Eval(bCond) .and. CT2->CT2_DATA <= dDataFim

				If CT2->CT2_VALOR = 0
					dbSkip()
					Loop				
				EndIf
		
				If Empty(c2Moeda)			
					If CT2->CT2_MOEDLC <> cMoeda
						dbSkip()
						Loop
					EndIF
				Else
					If !(&(cFilMoeda))
						dbSkip()
						Loop
					EndIf			
				EndIf
				
				If (CT2->CT2_DC == "2" .Or. CT2->CT2_DC == "3") .And. &(cVldEnt) .And. CT2->CT2_TPSALD == cSaldo
					CT2->(CtbGrvRAZ(lJunta,cMoeda,cSaldo,"2",c2Moeda,cAliasCT2,nTipo))
				Endif
				dbSelectArea("CT2")
				dbSkip()
			EndDo	
			(cTabCad)->(dbSkip())
		EndDo
	EndIf

#IFDEF TOP
	EndIf
#ENDIF

If lNoMov .or. lSldAnt
	If cTipo == "1"
		dbSelectArea("CT1")
		dbSetOrder(3)
		IndRegua(	Alias(),CriaTrab(nil,.f.),IndexKey(),,;
						"CT1_FILIAL == '" + xFilial("CT1") + "' .And. CT1_CONTA >= '"+cContaI+ "' .And. CT1_CONTA <= '" +;
						cContaF + "' .And. CT1_CLASSE = '2'","Selecionando Registros...")
		cCpoChave := "CT1_CONTA"
		cTmpChave := "CONTA"
	ElseIf cTipo == "2"
		dbSelectArea("CTT")
		dbSetOrder(2)
		IndRegua(	Alias(),CriaTrab(nil,.f.),IndexKey(),,;
						"CTT_FILIAL == '" + xFilial("CTT") + "' .And. CTT_CUSTO >= '"+cCustoI+"' .And. CTT_CUSTO <= '" +;
						cCUSTOF + "' .And. CTT_CLASSE == '2'","Selecionando Registros...")
		cCpoChave := "CTT_CUSTO"
		cTmpChave := "CCUSTO"
	ElseIf ctipo == "3"
		dbSelectArea("CTD")
		dbSetOrder(2)
		IndRegua(	Alias(),CriaTrab(nil,.f.),IndexKey(),,;
						"CTD_FILIAL == '" + xFilial("CTD") + "' .And. CTD_ITEM >= '"+cItemI+"' .And. CTD_ITEM <= '" +;
						cITEMF + "' .And. CTD_CLASSE == '2'","Selecionando Registros...")
		cCpoChave := "CTD_ITEM"
		cTmpChave := "ITEM"
	ElseIf ctipo == "4"
		dbSelectArea("CTH")
		dbSetOrder(2)
		IndRegua(	Alias(),CriaTrab(nil,.f.),IndexKey(),,;
						"CTH_FILIAL == '" + xFilial("CTH") + "' .And. CTH_CLVL >= '"+cClVlI+"' .And. CTH_CLVL <= '" +;
						cCLVLF + "' .And. CTH_CLASSE == '2'","Selecionando Registros...")
		cCpoChave := "CTH_CLVL"
		cTmpChave := "CLVL"
	EndIf

	cAlias := Alias()

	While ! Eof()
		dbSelectArea("cArqTmp")
		cKey2Seek	:= &(cAlias + "->" + cCpoChave)
		If !DbSeek(cKey2Seek)
			If lNoMov		
				CtbGrvNoMov(cKey2Seek,dDataIni,cTmpChave)
			ElseIf cTipo == "1"		/// SOMENTE PARA O RAZAO POR CONTA
				/// TRATA OS DADOS PARA A PERGUNTA "IMPRIME CONTA SEM MOVIMENTO" = "NAO C/ SLD.ANT."
				If SaldoCT7Fil(cKey2Seek,dDataIni,cMoeda,cSaldo,'CTBR400')[6] <> 0 .and. cArqTMP->CONTA <> cKey2Seek
					/// SE TIVER SALDO ANTERIOR E N�O TIVER MOVIMENTO GRAVADO
					CtbGrvNoMov(cKey2Seek,dDataIni,cTmpChave)
				Endif
			EndIf
		Endif
		DbSelectArea(cAlias)
		DbSkip()
	EndDo

	DbSelectArea(cAlias)
	DbClearFil()
	RetIndex(cAlias)
Endif

CtbTmpErase(cTmpCT2Fil)
Return

/*/
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
��� Fun��o    �CtbGrvRaz � Autor � Pilar S. Albaladejo   � Data � 05/02/01 ���
��������������������������������������������������������������������������Ĵ��
��� Descri��o �Grava registros no arq temporario - Razao                   ���
��������������������������������������������������������������������������Ĵ��
���Sintaxe    �CtbGrvRaz(lJunta,cMoeda,cSaldo,cTipo)                       ���
��������������������������������������������������������������������������Ĵ��
���Retorno    �Nenhum                                                      ���
��������������������������������������������������������������������������Ĵ��
��� Uso       � SIGACTB                                                    ���
��������������������������������������������������������������������������Ĵ��
���Parametros � ExpL1 = Se Junta CC ou nao                                 ���
���           � ExpC1 = Moeda                                              ���
���           � ExpC2 = Tipo de saldo                                      ���
��            � ExpC3 = Tipo do lancamento                                 ���
���           � c2Moeda = Indica moeda 2 a ser incluida no relatorio       ���
���           � cAliasQry = Alias com o conteudo selecionado do CT2        ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������
/*/
Static Function CtbGrvRAZ(lJunta,cMoeda,cSaldo,cTipo,c2Moeda,cAliasCT2,nTipo)

Local cConta
Local cContra
Local cCusto
Local cItem
Local cCLVL
Local cChave   	:= ""
Local lImpCPartida := GetNewPar("MV_IMPCPAR",.T.) // Se .T.,     IMPRIME Contra-Partida para TODOS os tipos de lan�amento (D�bito, Credito e Partida-Dobrada),
                                                  // se .F., N�O IMPRIME Contra-Partida para NENHUM   tipo  de lan�amento.
DEFAULT cAliasCT2	:= "CT2"

If !Empty(c2Moeda)
	If cTipo == "1"
		cChave	:=	(cAliasCT2)->(CT2_DEBITO+DTOS(CT2_DATA)+CT2_LOTE+CT2_SBLOTE+CT2_DOC+CT2_LINHA+CT2_EMPORI+CT2_FILORI)
	Else
    	cChave	:=	(cAliasCT2)->(CT2_CREDIT+DTOS(CT2_DATA)+CT2_LOTE+CT2_SBLOTE+CT2_DOC+CT2_LINHA+CT2_EMPORI+CT2_FILORI)
 	EndIf
EndIf

If cTipo == "1"
	cConta 	:= (cAliasCT2)->CT2_DEBITO
	cContra	:= (cAliasCT2)->CT2_CREDIT
	cCusto	:= (cAliasCT2)->CT2_CCD
	cItem	:= (cAliasCT2)->CT2_ITEMD
	cCLVL	:= (cAliasCT2)->CT2_CLVLDB
EndIf	
If cTipo == "2"
	cConta 	:= (cAliasCT2)->CT2_CREDIT
	cContra := (cAliasCT2)->CT2_DEBITO
	cCusto	:= (cAliasCT2)->CT2_CCC
	cItem	:= (cAliasCT2)->CT2_ITEMC
	cCLVL	:= (cAliasCT2)->CT2_CLVLCR
EndIf		           

dbSelectArea("cArqTmp")
dbSetOrder(1)	
If !Empty(c2Moeda) 
	If MsSeek(cChave,.F.)
		Reclock("cArqTmp",.F.)
	Else
		RecLock("cArqTmp",.T.)		
	EndIf
Else
	RecLock("cArqTmp",.T.)
EndIf

Replace FILIAL		With (cAliasCT2)->CT2_FILIAL
Replace DATAL		With (cAliasCT2)->CT2_DATA
Replace TIPO		With cTipo
Replace LOTE		With (cAliasCT2)->CT2_LOTE
Replace SUBLOTE		With (cAliasCT2)->CT2_SBLOTE
Replace DOC			With (cAliasCT2)->CT2_DOC
Replace LINHA		With (cAliasCT2)->CT2_LINHA
Replace CONTA		With cConta

If lImpCPartida
	Replace XPARTIDA	With cContra
EndIf

Replace CCUSTO		With cCusto
Replace ITEM		With cItem
Replace CLVL		With cCLVL
Replace HISTORICO	With (cAliasCT2)->CT2_HIST
Replace EMPORI		With (cAliasCT2)->CT2_EMPORI
Replace FILORI		With (cAliasCT2)->CT2_FILORI
Replace SEQHIST		With (cAliasCT2)->CT2_SEQHIST
Replace SEQLAN		With (cAliasCT2)->CT2_SEQLAN
Replace NOMOV		With .F.							// Conta com movimento

If cPaisLoc $ "CHI|ARG"
	Replace SEGOFI With (cAliasCT2)->CT2_SEGOFI// Correlativo para Chile
EndIf

If Empty(c2Moeda)	//Se nao for Razao em 2 Moedas
	If cTipo == "1"
		Replace LANCDEB	With LANCDEB + (cAliasCT2)->CT2_VALOR
	EndIf	
	If cTipo == "2"
		Replace LANCCRD	With LANCCRD + (cAliasCT2)->CT2_VALOR
	EndIf	    
	If (cAliasCT2)->CT2_DC == "3"
		Replace TIPO	With cTipo
	Else
		Replace TIPO 	With (cAliasCT2)->CT2_DC
	EndIf		
Else	//Se for Razao em 2 Moedas
	If (nTipo = 1 .Or. nTipo = 3) .And. (cAliasCT2)->CT2_MOEDLC = cMoeda //Se Imprime Valor na Moeda ou ambos
		If cTipo == "1"
			Replace LANCDEB With (cAliasCT2)->CT2_VALOR	
		Else			
			Replace LANCCRD With (cAliasCT2)->CT2_VALOR	
		EndIf
	EndIf
    If (nTipo = 2 .Or. nTipo = 3) .And. (cAliasCT2)->CT2_MOEDLC = c2Moeda	//Se Imprime Moeda Corrente ou Ambas
		If cTipo == "1"
			Replace LANCDEB_1	With (cAliasCT2)->CT2_VALOR
		Else
			Replace LANCCRD_1	With (cAliasCT2)->CT2_VALOR
		Endif
	EndIf
	If LANCDEB_1 <> 0 .And. LANCDEB <> 0 
		Replace TXDEBITO  	With LANCDEB_1 / LANCDEB		
	Endif                                               
	If LANCCRD_1 <> 0 .And. LANCCRD <> 0
		Replace TXCREDITO 	With LANCCRD_1 / LANCCRD
	EndIf	
	If (cAliasCT2)->CT2_DC == "3"
		Replace TIPO	With cTipo
	Else
		Replace TIPO 	With (cAliasCT2)->CT2_DC
	EndIf			
EndIf

If nTipo = 1 .And. (LANCDEB + LANCCRD) = 0
	DbDelete()
ElseIf nTipo = 2 .And. (LANCDEB_1 + LANCCRD_1) = 0
	DbDelete()
Endif
If ! Empty(c2Moeda) .And. LANCDEB + LANCDEB_1 + LANCCRD + LANCCRD_1 = 0
	DbDelete()
Endif
MsUnlock()

Return

/*/
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
��� Fun��o    �CtbGrvNoMov � Autor � Pilar S. Albaladejo � Data � 05/02/01 ���
��������������������������������������������������������������������������Ĵ��
��� Descri��o �Grava registros no arq temporario sem movimento.            ���
��������������������������������������������������������������������������Ĵ��
���Sintaxe    �CtbGrvNoMov(cConta)                                         ���
��������������������������������������������������������������������������Ĵ��
���Retorno    �Nenhum                                                      ���
��������������������������������������������������������������������������Ĵ��
��� Uso       � SIGACTB                                                    ���
��������������������������������������������������������������������������Ĵ��
���Parametros � cConteudo = Conteudo a ser gravado no campo chave de acordo���
���           �             com o razao impresso                           ���
���           � dDataL = Data para verificacao do movimento da conta       ���
���           � cCpoChave = Nome do campo para gravacao no temporario      ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������
/*/
Static Function CtbGrvNoMov(cConteudo,dDataL,cCpoTmp)

dbSelectArea("cArqTmp")
dbSetOrder(1)	

RecLock("cArqTmp",.T.)      
Replace FILIAL      With xFilial( 'CT2' )
Replace &(cCpoTmp)	With cConteudo
If cCpoTmp = "CONTA"
	Replace HISTORICO		With "CONTA SEM MOVIMENTO NO PERIODO"		//"CONTA SEM MOVIMENTO NO PERIODO"
ElseIf cCpoTmp = "CCUSTO"
	Replace HISTORICO		With Upper(AllTrim(CtbSayApro("CTT"))) + " "  + "SEM MOVIMENTO NO PERIODO"	//"SEM MOVIMENTO NO PERIODO"
ElseIf cCpoTmp = "ITEM"
	Replace HISTORICO		With Upper(AllTrim(CtbSayApro("CTD"))) + " "  + "SEM MOVIMENTO NO PERIODO"	//"SEM MOVIMENTO NO PERIODO"
ElseIf cCpoTmp = "CLVL"
	Replace HISTORICO		With Upper(AllTrim(CtbSayApro("CTH"))) + " "  + "SEM MOVIMENTO NO PERIODO"	//"SEM MOVIMENTO NO PERIODO"
Endif
Replace DATAL 			WITH dDataL 
// Grava filial do sistema para uso no relatorio
Replace FILORI		With cFilAnt
MsUnlock()

Return

/*/
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
��� Fun��o    �Ctr400Sint� Autor � Pilar S. Albaladejo   � Data � 05/02/01 ���
��������������������������������������������������������������������������Ĵ��
��� Descri��o �Imprime conta sintetica da conta do razao                   ���
��������������������������������������������������������������������������Ĵ��
���Sintaxe    �Ctr400Sint( cConta,cDescSint,cMoeda,cDescConta,cCodRes	   ���
���		      |		   	 , cMoedaDesc)									   ���
��������������������������������������������������������������������������Ĵ��
���Retorno    �Conta Sintetic		                                       ���
��������������������������������������������������������������������������Ĵ��
��� Uso       � SIGACTB                                                    ���
��������������������������������������������������������������������������Ĵ��
���Parametros � ExpC1 = Conta                                              ���
���           � ExpC2 = Descricao da Conta Sintetica                       ���
���           � ExpC3 = Moeda                                              ���
���           � ExpC4 = Descricao da Conta                                 ���
���           � ExpC5 = Codigo reduzido                                    ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������
/*/
Static Function Ctr400Sint(cConta,cDescSint,cMoeda,cDescConta,cCodRes,cMoedaDesc)

Local aSaveArea := GetArea()

Local nPosCT1					//Guarda a posicao no CT1
Local cContaPai	:= ""
Local cContaSint	:= ""

// seta o default da descri��o da moeda para a moeda corrente
Default cMoedaDesc := cMoeda

dbSelectArea("CT1")
dbSetOrder(1)
If dbSeek(xFilial("CT1")+cConta)
	nPosCT1 	:= Recno()
	cDescConta  := &("CT1->CT1_DESC" + cMoedaDesc )

	If Empty( cDescConta )
		cDescConta  := CT1->CT1_DESC01
	Endif

	cCodRes		:= CT1->CT1_RES
	cContaPai	:= CT1->CT1_CTASUP

	If dbSeek(xFilial("CT1")+cContaPai)
		cContaSint 	:= CT1->CT1_CONTA
		cDescSint	:= &("CT1->CT1_DESC" + cMoedaDesc )

		If Empty(cDescSint)
			cDescSint := CT1->CT1_DESC01
		Endif
	EndIf	

	dbGoto(nPosCT1)
EndIf	

RestArea(aSaveArea)

Return cContaSint

/*/
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
��� Fun��o    �CtbQryRaz � Autor � Simone Mie Sato       � Data � 22/01/04 ���
��������������������������������������������������������������������������Ĵ��
��� Descri��o �Realiza a "filtragem" dos registros do Razao                ���
��������������������������������������������������������������������������Ĵ��
���Sintaxe    �CtbQryRaz(oMeter,oText,oDlg,lEnd,cContaIni,cContaFim,	   ���
���			  �	cCustoIni,cCustoFim, cItemIni,cItemFim,cCLVLIni,cCLVLFim,  ���
���			  �	cMoeda,dDataIni,dDataFim,aSetOfBook,lNoMov,cSaldo,lJunta,  ���
���			  �	cTipo)                                                     ���
��������������������������������������������������������������������������Ĵ��
���Retorno    �Nenhum                                                      ���
��������������������������������������������������������������������������Ĵ��
��� Uso       � SIGACTB                                                    ���
��������������������������������������������������������������������������Ĵ��
���Parametros � ExpO1 = Objeto oMeter                                      ���
���           � ExpO2 = Objeto oText                                       ���
���           � ExpO3 = Objeto oDlg                                        ���
���           � ExpL1 = Acao do Codeblock                                  ���
���           � ExpC2 = Conta Inicial                                      ���
���           � ExpC3 = Conta Final                                        ���
���           � ExpC4 = C.Custo Inicial                                    ���
���           � ExpC5 = C.Custo Final                                      ���
���           � ExpC6 = Item Inicial                                       ���
���           � ExpC7 = Cl.Valor Inicial                                   ���
���           � ExpC8 = Cl.Valor Final                                     ���
���           � ExpC9 = Moeda                                              ���
���           � ExpD1 = Data Inicial                                       ���
���           � ExpD2 = Data Final                                         ���
���           � ExpA1 = Matriz aSetOfBook                                  ���
���           � ExpL2 = Indica se imprime movimento zerado ou nao.         ���
���           � ExpC10= Tipo de Saldo                                      ���
���           � ExpL3 = Indica se junta CC ou nao.                         ���
���           � ExpC11= Tipo do lancamento                                 ���
���           � c2Moeda = Indica moeda 2 a ser incluida no relatorio       ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������
/*/
Static Function CtbQryRaz(oMeter,oText,oDlg,lEnd,cContaIni,cContaFim,cCustoIni,cCustoFim,;
				  cItemIni,cItemFim,cCLVLIni,cCLVLFim,cMoeda,dDataIni,dDataFim,;
				  aSetOfBook,lNoMov,cSaldo,lJunta,cTipo,c2Moeda,cUFilter,lSldAnt,aSelFil,lExterno)

Local aSaveArea := GetArea()
Local nMeter	:= 0
Local cQuery	:= ""
Local aTamVlr	:= TAMSX3("CT2_VALOR")     
Local lNoMovim	:= .F.
Local cContaAnt	:= ""
Local cCampUSU	:= ""
local aStrSTRU	:= {}
Local nStr		:= 0
Local cQryFil	:= '' // variavel de condicional da query
Local lImpCPartida := GetNewPar( "MV_IMPCPAR" , .T.)	// Se .T.,     IMPRIME Contra-Partida para TODOS os tipos de lan�amento (D�bito, Credito e Partida-Dobrada),
														// se .F., N�O IMPRIME Contra-Partida para NENHUM   tipo  de lan�amento.
Local cTmpCT2Fil
DEFAULT lSldAnt 	:= .F.
DEFAULT aSelFil 	:= {} 
DEFAULT lExterno	:= .F.

// trataviva para o filtro de multifiliais 
cQryFil := " CT2.CT2_FILIAL " + GetRngFil( aSelFil, "CT2", .T., @cTmpCT2Fil )

If !lExterno
	oMeter:SetTotal(CT2->(RecCount()))
	oMeter:Set(0)
Endif

cQuery	:= " SELECT CT2_FILIAL FILIAL, CT1_CONTA CONTA, ISNULL(CT2_CCD,'') CUSTO,ISNULL(CT2_ITEMD,'') ITEM, ISNULL(CT2_CLVLDB,'') CLVL, ISNULL(CT2_DATA,'') DDATA, ISNULL(CT2_TPSALD,'') TPSALD, "	
cQuery	+= " ISNULL(CT2_DC,'') DC, ISNULL(CT2_LOTE,'') LOTE, ISNULL(CT2_SBLOTE,'') SUBLOTE, ISNULL(CT2_DOC,'') DOC, ISNULL(CT2_LINHA,'') LINHA, ISNULL(CT2_CREDIT,'') XPARTIDA, ISNULL(CT2_HIST,'') HIST, ISNULL(CT2_SEQHIS,'') SEQHIS, ISNULL(CT2_SEQLAN,'') SEQLAN, '1' TIPOLAN, "	

////////////////////////////////////////////////////////////
//// TRATAMENTO PARA O FILTRO DE USU�RIO NO RELATORIO
////////////////////////////////////////////////////////////
cCampUSU  := ""										//// DECLARA VARIAVEL COM OS CAMPOS DO FILTRO DE USU�RIO
If !Empty(cUFilter)									//// SE O FILTRO DE USU�RIO NAO ESTIVER VAZIO
	aStrSTRU := CT2->(dbStruct())				//// OBTEM A ESTRUTURA DA TABELA USADA NA FILTRAGEM
	nStruLen := Len(aStrSTRU)						
	For nStr := 1 to nStruLen                       //// LE A ESTRUTURA DA TABELA 
		cCampUSU += aStrSTRU[nStr][1]+","			//// ADICIONANDO OS CAMPOS PARA FILTRAGEM POSTERIOR
	Next
Endif
cQuery += cCampUSU									//// ADICIONA OS CAMPOS NA QUERY

////////////////////////////////////////////////////////////
cQuery  += " ISNULL(CT2_VALOR,0) VALOR, ISNULL(CT2_EMPORI,'') EMPORI, ISNULL(CT2_FILORI,'') FILORI"       
If cPaisLoc $ "CHI|ARG"
	cQuery	+= ", ISNULL(CT2_SEGOFI,'') SEGOFI"
EndIf

cQuery += " FROM "+ RetSqlName("CT1") + " CT1 LEFT JOIN " + RetSqlName("CT2") + " CT2 "
cQuery += " ON " + cQryFil

cQuery	+= " AND CT2.CT2_DEBITO = CT1.CT1_CONTA"  
cQuery  += " AND CT2.CT2_DATA >= '"+DTOS(dDataIni)+ "' AND CT2.CT2_DATA <= '"+DTOS(dDataFim)+"'"
cQuery	+= " AND CT2.CT2_CCD >= '" + cCustoIni + "' AND CT2.CT2_CCD <= '" + cCustoFim +"'"
cQuery  += " AND CT2.CT2_ITEMD >= '" + cItemIni + "' AND CT2.CT2_ITEMD <= '"+ cItemFim +"'"
cQuery  += " AND CT2.CT2_CLVLDB >= '" + cClvlIni + "' AND CT2.CT2_CLVLDB <= '" + cClVlFim +"'"
cQuery  += " AND CT2.CT2_TPSALD = '"+ cSaldo + "'"
cQuery	+= " AND CT2.CT2_MOEDLC = '" + cMoeda +"'"
cQuery  += " AND (CT2.CT2_DC = '1' OR CT2.CT2_DC = '3') "
cQuery  += " AND CT2_VALOR <> 0 "
cQuery	+= " AND CT2.D_E_L_E_T_ = ' ' "	
cQuery	+= " WHERE CT1.CT1_FILIAL = '"+xFilial("CT1")+"' "
cQuery	+= " AND CT1.CT1_CLASSE = '2' "
cQuery	+= " AND CT1.CT1_CONTA >= '"+ cContaIni+"' AND CT1.CT1_CONTA <= '"+cContaFim+"'"
cQuery	+= " AND CT1.D_E_L_E_T_ = '' "

cQuery	+= " UNION "

cQuery	+= " SELECT CT2_FILIAL FILIAL, CT1_CONTA CONTA, ISNULL(CT2_CCC,'') CUSTO, ISNULL(CT2_ITEMC,'') ITEM, ISNULL(CT2_CLVLCR,'') CLVL, ISNULL(CT2_DATA,'') DDATA, ISNULL(CT2_TPSALD,'') TPSALD, "	
cQuery	+= " ISNULL(CT2_DC,'') DC, ISNULL(CT2_LOTE,'') LOTE, ISNULL(CT2_SBLOTE,'')SUBLOTE, ISNULL(CT2_DOC,'') DOC, ISNULL(CT2_LINHA,'') LINHA, ISNULL(CT2_DEBITO,'') XPARTIDA, ISNULL(CT2_HIST,'') HIST, ISNULL(CT2_SEQHIS,'') SEQHIS, ISNULL(CT2_SEQLAN,'') SEQLAN, '2' TIPOLAN, "	

////////////////////////////////////////////////////////////
//// TRATAMENTO PARA O FILTRO DE USU�RIO NO RELATORIO
////////////////////////////////////////////////////////////
cCampUSU  := ""										//// DECLARA VARIAVEL COM OS CAMPOS DO FILTRO DE USU�RIO
If !Empty(cUFilter)									//// SE O FILTRO DE USU�RIO NAO ESTIVER VAZIO
	aStrSTRU := CT2->(dbStruct())				//// OBTEM A ESTRUTURA DA TABELA USADA NA FILTRAGEM
	nStruLen := Len(aStrSTRU)						
	For nStr := 1 to nStruLen                       //// LE A ESTRUTURA DA TABELA 
		cCampUSU += aStrSTRU[nStr][1]+","			//// ADICIONANDO OS CAMPOS PARA FILTRAGEM POSTERIOR
	Next
Endif

cQuery += cCampUSU									//// ADICIONA OS CAMPOS NA QUERY

cQuery  += " ISNULL(CT2_VALOR,0) VALOR, ISNULL(CT2_EMPORI,'') EMPORI, ISNULL(CT2_FILORI,'') FILORI"              
If cPaisLoc $ "CHI|ARG"
	cQuery	+= ", ISNULL(CT2_SEGOFI,'') SEGOFI"
EndIf
cQuery += " FROM "+RetSqlName("CT1")+ ' CT1 LEFT JOIN '+ RetSqlName("CT2") + ' CT2 '
cQuery += " ON " + cQryFil

cQuery	+= " AND CT2.CT2_CREDIT =  CT1.CT1_CONTA "
cQuery  += " AND CT2.CT2_DATA >= '"+DTOS(dDataIni)+ "' AND CT2.CT2_DATA <= '"+DTOS(dDataFim)+"'"
cQuery	+= " AND CT2.CT2_CCC >= '" + cCustoIni + "' AND CT2.CT2_CCC <= '" + cCustoFim +"'"
cQuery  += " AND CT2.CT2_ITEMC >= '" + cItemIni + "' AND CT2.CT2_ITEMC <= '"+ cItemFim +"'"
cQuery  += " AND CT2.CT2_CLVLCR >= '" + cClvlIni + "' AND CT2.CT2_CLVLCR <= '" + cClVlFim +"'"
cQuery  += " AND CT2.CT2_TPSALD = '"+ cSaldo + "'"
cQuery	+= " AND CT2.CT2_MOEDLC = '" + cMoeda +"'"
cQuery  += " AND (CT2.CT2_DC = '2' OR CT2.CT2_DC = '3') "
cQuery  += " AND CT2_VALOR <> 0 "
cQuery	+= " AND CT2.D_E_L_E_T_ = ' ' "	
cQuery	+= " WHERE CT1.CT1_FILIAL = '"+xFilial("CT1")+"' "
cQuery	+= " AND CT1.CT1_CLASSE = '2' "
cQuery	+= " AND CT1.CT1_CONTA >= '"+ cContaIni+"' AND CT1.CT1_CONTA <= '"+cContaFim+"'"
cQuery	+= " AND CT1.D_E_L_E_T_ = ''"	            
If FunName() <> "CTBR440"
	cQuery  += " ORDER BY CONTA, DDATA"
EndIf
cQuery := ChangeQuery(cQuery)		   

If Select("cArqCT2") > 0
	dbSelectArea("cArqCT2")
	dbCloseArea()
Endif

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"cArqCT2",.T.,.F.)

TcSetField("cArqCT2","CT2_VLR"+cMoeda,"N",aTamVlr[1],aTamVlr[2])
TcSetField("cArqCT2","DDATA","D",8,0)

If !Empty(cUFilter)									//// SE O FILTRO DE USU�RIO NAO ESTIVER VAZIO
	For nStr := 1 to nStruLen                       //// LE A ESTRUTURA DA TABELA 
		If aStrSTRU[nStr][2] <> "C" .and. cArqCT2->(FieldPos(aStrSTRU[nStr][1])) > 0
			TcSetField("cArqCT2",aStrSTRU[nStr][1],aStrSTRU[nStr][2],aStrSTRU[nStr][3],aStrSTRU[nStr][4])
		EndIf
	Next
Endif
 			
dbSelectarea("cArqCT2")

dbSelectarea("cArqCT2")
If Empty(cUFilter)
	cUFilter := ".T."
Endif						

While !Eof()                                              
	If Empty(cArqCT2->DDATA) //Se nao existe movimento 
		cContaAnt	:= cArqCT2->CONTA	
		dbSkip()
		If Empty(cArqCT2->DDATA) .And. cContaAnt == cArqCT2->CONTA
			lNoMovim	:= .T.
		EndIf
	Endif        
	
	If &("cArqCT2->("+cUFilter+")")						
		If lNoMovim
			If lNoMov  
				If CtbExDtFim("CT1")							
					dbSelectArea("CT1")
					dbSetOrder(1) 
					If MsSeek(xFilial()+cArqCT2->CONTA)
						If CtbVlDtFim("CT1",dDataIni) 
							CtbGrvNoMov(cArqCT2->CONTA,dDataIni,"CONTA")	//Esta sendo passado "CONTA" fixo, porque essa funcao esta sendo 									
						EndIf												//chamada somente para o CTBR400
					EndIf				
				Else
					CtbGrvNoMov(cArqCT2->CONTA,dDataIni,"CONTA")	//Esta sendo passado "CONTA" fixo, porque essa funcao esta sendo 				
				EndIf												//chamada somente para o CTBR400
			ElseIf lSldAnt 
				If SaldoCT7Fil(cArqCT2->CONTA,dDataIni,cMoeda,cSaldo,'CTBR400')[6] <> 0 .and. cArqTMP->CONTA <> cArqCT2->CONTA																							
					CtbGrvNoMov(cArqCT2->CONTA,dDataIni,"CONTA")	
				Endif			
			EndIf
		Else
			RecLock("cArqTmp",.T.)		    	
		    Replace FILIAL		With cArqCT2->FILIAL
		    Replace DATAL		With cArqCT2->DDATA
			Replace TIPO		With cArqCT2->DC
			Replace LOTE		With cArqCT2->LOTE
			Replace SUBLOTE		With cArqCT2->SUBLOTE
			Replace DOC			With cArqCT2->DOC
			Replace LINHA		With cArqCT2->LINHA
			Replace CONTA		With cArqCT2->CONTA			
			Replace CCUSTO		With cArqCT2->CUSTO
			Replace ITEM		With cArqCT2->ITEM
			Replace CLVL		With cArqCT2->CLVL

			If lImpCPartida
				Replace XPARTIDA	With cArqCT2->XPARTIDA
			EndIf		

			Replace HISTORICO	With cArqCT2->HIST
			Replace EMPORI		With cArqCT2->EMPORI
			Replace FILORI		With cArqCT2->FILORI
			Replace SEQHIST		With cArqCT2->SEQHIS
			Replace SEQLAN		With cArqCT2->SEQLAN

			If cPaisLoc $ "CHI|ARG"
				Replace SEGOFI With cArqCT2->SEGOFI// Correlativo para Chile
			EndIf
	
			If cArqCT2->TIPOLAN = '1'
				Replace LANCDEB	With LANCDEB + cArqCT2->VALOR
			EndIf
			If cArqCT2->TIPOLAN = '2'
				Replace LANCCRD	With LANCCRD + cArqCT2->VALOR
			EndIf	
			MsUnlock()
		Endif         
	EndIf
	lNoMovim	:= .F.	
	dbSelectArea("cArqCT2")	
	dbSkip()
	nMeter++ 
	
	If !lExterno
		oMeter:Set(nMeter)		
	Endif
		
Enddo	

CtbTmpErase(cTmpCT2Fil)
RestArea(aSaveArea)

Return

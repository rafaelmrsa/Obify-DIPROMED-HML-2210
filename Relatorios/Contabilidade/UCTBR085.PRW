/*====================================================================================\
|Programa  | UCTBR085      | Autor | Eriberto Elias             | Data | 16/07/2004   |
|=====================================================================================|
|Descrição | Adaptacao para impressao do nome da conta                                |
|=====================================================================================|
|Sintaxe   | uctbr085                                                                 |
|=====================================================================================|
|Uso       | Especifico DIPROMED                                                      |
|=====================================================================================|
|Histórico | DD/MM/AA - Descrição da alteração                                        |
\====================================================================================*/

#Include "UCtbr085.Ch"
#Include "PROTHEUS.Ch"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³ Ctbr085	³ Autor ³ Simone Mie Sato   	³ Data ³ 21.10.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Relacao Lancamentos Classificados por Sublote/Doc.Fiscal	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ Ctbr085()    											  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ Nenhum       											  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso 	     ³ Generico     											  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function UCtbR085()

Local aCtbMoeda		:= {}
Local cDesc1 		:= STR0001		//"Este programa ira imprimir o Relatorio de Lancamentos"
Local cDesc2 		:= STR0002	  	//"por SubLote / Doc. Fiscal."
Local cDesc3		:= ""
Local cNomeArq
Local wnrel
Local cString		:= "CT2"
Local titulo 		:= STR0003	 	//"Lancamentos Classificados por SubLote/Doc.Fiscal"
Local lRet			:= .T.

Private Tamanho		:= "G"
Private nLastKey 	:= 0

//Private cPerg	 	:= "CTR085"
// FPADR(cPerg, cArq, cCampo, cTipo)  - Para ajustar o tamanho das perguntas no SX1 - uso generico
PRIVATE cPerg  	:= U_FPADR( "CTR085","SX1","SX1->X1_GRUPO"," " ) //Função criada por Sandro em 19/11/09.

Private aReturn 	:= { STR0004, 1,STR0005, 2, 2, 1, "",1 }  //"Zebrado"###"Administracao"
Private aLinha		:= {}
Private nomeProg  	:= "CTBR085"
U_DIPPROC(ProcName(0),U_DipUsr()) // JBS 05/10/2005 - Gravando o nome do Programa no SZU
li 		:= 80
m_pag	:= 1

If ( !AMIIn(34) )		// Acesso somente pelo SIGACTB
	Return
EndIf     

If	CT2->(FieldPos("CT2_KEY")) = 0
	MsgAlert(STR0024)//"Esse relatorio necessita do campo CT2_KEY. Favor criá-lo com tipo caracter de 100"
	Return
EndIf

//Cria as perguntas
CTR085SX1(cPerg)

If !Pergunte(cPerg,.T.)
	Return
EndIf       

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros						 	³
//³ mv_par01				// Data Inicial                  	 	³
//³ mv_par02				// Data Final                         	³
//³ mv_par03				// Lote  Inicial                        ³
//³ mv_par04				// Lote  Final  						³
//³ mv_par05				// Sub-Lote Inicial                  	³
//³ mv_par06				// Sub-Lote Final  						³
//³ mv_par07				// Documento Inicial                    ³
//³ mv_par08				// Documento Final			    		³
//³ mv_par09				// Moeda?						     	³
//³ mv_par10				// Codigos? Normal / Reduzido 			³
//³ mv_par11				// Imprime Lcto? Real/Ger/Orc/Pre/Todos ³
//³ mv_par12				// Quebra Pagina? Sim / Nao		    	³
//³ mv_par13				// Considera Doc. em Branco?Sim/Nao	    ³
//³ mv_par14				// Totaliza Lote? Sim/Nao          	    ³
//³ mv_par15				// Totaliza Doc? Sim/Nao           	    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

wnrel	:= "CTBR085"            //Nome Default do relatorio em Disco
wnrel := SetPrint(cString,wnrel,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,"",,Tamanho)

If nLastKey == 27
	Set Filter To
	Return
Endif

If lRet
	aCtbMoeda  	:= CtbMoeda(mv_par09)
	If Empty(aCtbMoeda[1])                       
      Help(" ",1,"NOMOEDA")
      lRet := .F.
   Endif
Endif

If !lRet
	Set Filter To
	Return
EndIf

SetDefault(aReturn,cString)

RptStatus({|lEnd| CTR085Imp(@lEnd,wnRel,cString,Titulo,aCtbMoeda)})

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³CTR085IMP ³ Autor ³ Simone Mie Sato       ³ Data ³ 22.10.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Imprime Lancamentos Classificados por Sublote/Doc.Fiscal   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³Ctr085Imp(lEnd,WnRel,cString,Titulo)                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ lEnd       - A‡ao do Codeblock                             ³±±
±±³          ³ wnRel      - Nome do Relatorio                             ³±±
±±³          ³ cString    - Mensagem                                      ³±±
±±³          ³ Titulo     - Titulo do Relatorio                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function CTR085Imp(lEnd,WnRel,cString,Titulo,aCtbMoeda)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local aTamCta		:= TamSX3("CT1_CONTA")
Local aSaldo		:= {}
Local aColunas 
Local aSetOfBook	:= {"","",0,"","","","","",1,""}

Local nTamCta 		:= aTamCta[1]
Local nDecimais
Local nTotDeb		:= 0
Local nTotCrd		:= 0
Local nTotGerDeb	:= 0
Local nTotGerCrd	:= 0
Local nTotDocDeb	:= 0
Local nTotDocCrd	:= 0
Local nTotLotDeb	:= 0
Local nTotLotCrd	:= 0
Local nTotSbLtDb	:= 0
Local nTotSbLtCr	:= 0

Local CbTxt
Local cbcont
Local Cabec1		:= ""
Local Cabec2		:= ""
Local cDescMoeda	:= ""
Local cSaldo		:= mv_par11
Local cMoeda		:= mv_par09
Local cArqTmp
Local cLoteIni		:= mv_par03
Local cLoteFim		:= mv_par04
Local cDocIni		:= mv_par07
Local cDocFim		:= mv_par08
Local cSbLoteIni	:= mv_par05
Local cSbLoteFim	:= mv_par06
Local cContaIni		:= ""
Local cContaFim		:= Repl("Z",nTamCta)
Local cLote			:= ""
Local cSblote		:= ""
Local cDoc			:= ""
Local cPicture		:= ""
Local cLoteAnt		:= ""
Local cDocAnt		:= ""

Local dDataAnt		:= CTOD("  /  /  ")
Local dDataIni		:= mv_par01
Local dDataFim		:= mv_par02
Local dData

Local lPrimPag		:= .T.
Local lImpDoc0		:= Iif(mv_par13 == 1,.T.,.F.)
Local lTotLote		:= Iif(mv_par14 == 1,.T.,.F.)
Local lTotDoc		:= Iif(mv_par15 == 1,.T.,.F.)
Local lQuebra		:= Iif(mv_par12 == 1,.T.,.F.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para Impressao do Cabecalho e Rodape    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cbtxt    := SPACE(10)
cbcont   := 0
li       := 80
m_pag    := 1

cDescMoeda 	:= Alltrim(aCtbMoeda[2])

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Cabe‡alho Relatorio  		                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
// DOC      CONTA                                      DOC. FISCAL                                  VALOR DEB               VALOR CRED        HP   HIST
// XXXXXX   XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX   XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX 99999999999999999999.99  99999999999999999999.99        XXX  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
// 01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
//           1         2         3         4         5         6         7         8         9        10        11        12        13        14        15        16        17        18        19        20        21        22

#DEFINE COL_DOC      		1
#DEFINE COL_CONTA    		2
#DEFINE COL_DOCFISCAL		3
#DEFINE COL_VLRDEBITO 		4
#DEFINE COL_VLRCREDIT		5
#DEFINE COL_HP				6
#DEFINE COL_HISTORICO		7
#DEFINE TAMANHO_TM       	8

aColunas    := { 000, 009, 052, 085, 108, 133, 138, 021 }
Cabec1 		:= Iif (cPaisLoc<>"MEX" ,STR0006,STR0025) //DOC      CONTA                                      DOC. FISCAL                                  VALOR DEB             VALOR CRED       HP   HIST
Tamanho		:= "G"
limite		:= 220
Titulo 		+= 	STR0021+cDescMoeda + STR0022 + DTOC(dDataIni) +;	// "EM"/DE"
				STR0023 + DTOC(dDataFim) + CtbTitSaldo(mv_par11)	// "ATE"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta Arquivo Temporario para Impressao   					 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
MsgMeter({|	oMeter, oText, oDlg, lEnd | ;
			CTBR420Raz(oMeter,oText,oDlg,lEnd,@cArqTmp,cContaIni,cContaFim,;
			cMoeda,dDataIni,dDataFim,aSetOfBook,.F.,cSaldo,"3",.T.,cLoteIni,cLoteFim,;
			cSbLoteIni,cSbLoteFim,cDocIni,cDocFim)},;
			STR0008,;		// "Criando Arquivo Tempor rio..."
			STR0007)		// "Emissao do Relat. SubLote/Doc.Fiscal"
				

dbSelectArea("cArqTmp")
SetRegua(RecCount())
dbGoTop()

While !Eof()

	IF lEnd
		@Prow()+1,0 PSAY STR0009  //"***** CANCELADO PELO OPERADOR *****"
		Exit
	EndIF                                         
	
	If !lImpDoc0 .And. Empty(cArqTmp->CT2KEY) 
		dbSkip()
		Loop
	Endif	

	IncRegua()                                    	
	
	cSubLote 	:= cArqTmp->SUBLOTE

	lFirst:= .T.
	
	nTotalDeb := 0
	nTotalCrd := 0

	lQuebra	 := Iif(mv_par12==1,.T.,.F.)
	
	While !Eof() .And. 	cArqTmp->SUBLOTE == cSubLote 				
	
		cLote 		:= cArqTmp->LOTE
		cDoc		:= cArqTmp->DOC
		dData 		:= cArqTmp->DATAL	
	
		IncRegua()
			
		IF li > 62 .Or. lQuebra
			Cabec( Titulo, Cabec1, Cabec2, NomeProg, Tamanho,;
				Iif(aReturn[4] == 1, GetMv("MV_COMP"), GetMv("MV_NORM")))
			If lQuebra .Or. lPrimPag
				lPrimPag	:= .F.				
			EndIf	
			lQuebra := .F.
		EndIf                
			
		If lFirst  
			@ li,00 PSAY Replicate("-",Limite)			
			li++      
			@ li,000 PSAY OemToAnsi(STR0015) + cSubLote			// "SUB-LOTE:"
			li++ 
			@ li,000 PSAY "-------------"
			li++
			@ li,000 PSAY OemToAnsi(STR0017) + DTOC(dData)		// "DATA: "
			@ li,019 PSAY OemToAnsi(STR0018) + cLote			// "LOTE: "
			li+=2
			lFirst := .F.
		ElseIf 	cLoteAnt <> cArqTmp->LOTE .Or.	 Dtos(dDataAnt) != Dtos(cArqTmp->DATAL) 
			li++
			@ li,000 PSAY OemToAnsi(STR0017) + DTOC(dData)		// "DATA: "
			@ li,019 PSAY OemToAnsi(STR0018) + cLote			// "LOTE: "
			li+=2
		EndIf

		@ li,aColunas[COL_DOC] PSAY cDoc

		If mv_par10 == 2
			dbSelectArea("CT1")
			dbSetOrder(1)
			If MsSeek(xFilial()+cArqTmp->CONTA)
				@ li, aColunas[COL_CONTA] PSAY CT1->CT1_RES
			EndIf
		Else
			@ li, aColunas[COL_CONTA] PSAY cArqTmp->CONTA
		Endif			

	 	//@ li, aColunas[COL_DOCFISCAL] PSAY Subs(cArqTmp->CT2KEY,1,30) 				
	 	@ li, aColunas[COL_DOCFISCAL]-10 PSAY POSICIONE("CT1",1,xFilial("CT1")+cArqTmp->CONTA,"CT1_DESC01")
	 	
 		ValorCTB(cArqTmp->LANCDEB,li,aColunas[COL_VLRDEBITO],aColunas[TAMANHO_TM],2,;
							         .F.,cPicture)
 		ValorCTB(cArqTmp->LANCCRD,li,aColunas[COL_VLRCREDIT],aColunas[TAMANHO_TM],2,;
							         .F.,cPicture)


		nTotalDeb += cArqTmp->LANCDEB
		nTotGerDeb+= cArqTmp->LANCDEB
		nTotLotDeb+= cArqTmp->LANCDEB
		nTotDocDeb+= cArqTmp->LANCDEB
		nTotSbLtDb+= cArqTmp->LANCDEB 

		nTotalCrd += cArqTmp->LANCCRD				
		nTotGerCrd+= cArqTmp->LANCCRD				
		nTotLotCrd+= cArqTmp->LANCCRD
		nTotDocCrd+= cArqTmp->LANCCRD
		nTotSbLtCr+= cArqTmp->LANCCRD				

		@ li, aColunas[COL_HP] 			PSAY cArqTmp->HP
		@ li, aColunas[COL_HISTORICO]	PSAY cArqTmp->HISTORICO
		li++

		dbSelectarea("cArqTmp")	
		cLoteAnt	:= cArqTmp->LOTE
		cDocAnt		:= cArqtmp->DOC
		dDataAnt	:= cArqTmp->DATAL
		dbSkip()				
   
		//TOTALIZA O DOCUMENTO		
		If lTotDoc    
			If cLote != cArqTmp->LOTE 				.Or.;
			   cSubLote != cArqTmp->SUBLOTE			.Or.;			
			   cDoc		!= cArqTmp->DOC 			.Or. ;
			   Dtos(dData) != Dtos(cArqTmp->DATAL)			
				li++
				@ li,00 PSAY Iif (cPaisLoc<>"MEX" ,STR0019,STR0026 )+ cDoc		//TOTAL DOCUMENTO
				CTC->(MsSeek(xFilial()+dtos(dData)+cLote+cSubLote+cDoc+cMoeda))
				
				ValorCTB(nTotDocDeb,li,aColunas[COL_VLRDEBITO],aColunas[TAMANHO_TM],2,;
						         .F.,cPicture)
		 		ValorCTB(nTotDocCrd,li,aColunas[COL_VLRCREDIT],aColunas[TAMANHO_TM],2,;
							         .F.,cPicture)
				@ li, aColunas[COL_HISTORICO]	PSAY STR0012 + Trans(CTC->CTC_INF,; //"INFORMADO "
																Tm(CTC->CTC_INF,17)) +;
		 									     Space(2) + STR0013 +; //"DIGITADO "
	 										     Trans(CTC->CTC_DIG, Tm(CTC->CTC_DIG,17)) +;
	 										     Space(2) + STR0010 +;  //"DIFERENCA"
												 Trans(	Abs(CTC->CTC_DIG-CTC->CTC_INF),;
												 Tm(CTC->CTC_DIG,17))
				li+=2
				nTotDocDeb 	:= 0	
				nTotDocCrd 	:= 0
			EndIf    
		EndIf

		// TOTALIZA O LOTE	
		If lTotLote			   
			If cLote != cArqTmp->LOTE 				.Or.;
			  cSubLote != cArqTmp->SUBLOTE			.Or.;
			   Dtos(dData) != Dtos(cArqTmp->DATAL)			
     			If !lTotDoc
					li++
				Endif
				@ li,00 PSAY STR0011 + cLote //TOTAL LOTE
				CT6->(MsSeek(xFilial()+dtos(dData)+cLote+cSubLote+cMoeda))
			
	 			ValorCTB(nTotLotDeb,li,aColunas[COL_VLRDEBITO],aColunas[TAMANHO_TM],2,;
				         .F.,cPicture)
				ValorCTB(nTotLotCrd,li,aColunas[COL_VLRCREDIT],aColunas[TAMANHO_TM],2,;
				         .F.,cPicture)			
				@ li, aColunas[COL_HISTORICO] 	PSAY STR0012 + Trans(CT6->CT6_INF,; //"INFORMADO "
																		Tm(CT6->CT6_INF,17)) +;
		 									  	   	Space(2) + STR0013 +; //"DIGITADO "
		 									   	  	Trans(CT6->CT6_DIG, Tm(CT6->CT6_DIG,17)) +;
	 										   	  	Space(2) + STR0010 +;  //"DIFERENCA"
													Trans(	Abs(CT6->CT6_DIG-CT6->CT6_INF),;
												 	Tm(CT6->CT6_DIG,17))
				li++   			
				nTotLotDeb := 0	
				nTotLotCrd := 0		
	   		EndIf		
	   EndIf
	Enddo     
	li++                                                  
	@ li,00 PSAY Replicate("-",Limite)			
	li++
	@ li,00 PSAY STR0020 + cSubLote //TOTAL SUB-LOTE
	ValorCTB(nTotSbLtDb,li,aColunas[COL_VLRDEBITO],aColunas[TAMANHO_TM],2,;
		         .F.,cPicture)
	ValorCTB(nTotSbLtCr,li,aColunas[COL_VLRCREDIT],aColunas[TAMANHO_TM],2,;
		         .F.,cPicture)			
	li++   			
	@ li,00 PSAY Replicate("-",Limite)			
	li++
	nTotSbLtDb := 0	
	nTotSbLtCr := 0			
EndDo    

If li != 80
		IF li > 55 
			Cabec( Titulo, Cabec1, Cabec2, NomeProg, Tamanho,;
					Iif(aReturn[4] == 1, GetMv("MV_COMP"), GetMv("MV_NORM")))
		EndIf		
		li+=2
		@ li,00 PSAY Replicate("-",Limite)
		li++
		@ li,02 PSAY STR0014//"T O T A L  G E R A L ==> "		
		ValorCTB(nTotGerDeb,li,aColunas[COL_VLRDEBITO],aColunas[TAMANHO_TM],2,;
		         .F.,cPicture)
 		ValorCTB(nTotGerCrd,li,aColunas[COL_VLRCREDIT],aColunas[TAMANHO_TM],2,;
		         .F.,cPicture)			
		li++
		@ li,00 PSAY Replicate("-",Limite)
	roda(cbcont,cbtxt,"G")
	Set Filter To
EndIf	

If aReturn[5] = 1
	Set Printer To
	Commit
	Ourspool(wnrel)
EndIf

dbSelectArea("cArqTmp")
Set Filter To
dbCloseArea()
If Select("cArqTmp") == 0
   FErase(cArqTmp+GetDBExtension())
   FErase(cArqTmp+OrdBagExt())
EndIf	


dbselectArea("CT2")

MS_FLUSH()

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ CTR085SX1    ³Autor ³  Simone Mie Sato     ³Data³ 06/11/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Cria as perguntas ref. o relatorio CTBR085.                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function CTR085SX1(cPerg)

Local aArea 	:= GetArea()
Local aPergs	:= {}
Local aHelpPor	:= {} 
Local aHelpEng	:= {}	
Local aHelpSpa	:= {}

Local nTamCta	:= Len(CriaVar("CT1_CONTA"))
                
//Grupo de perguntas do relatorio CTR085.(Relatorio SubLote/Doc.Fiscais)
aPergs := {}    

aHelpPor	:= {} 
aHelpEng	:= {}	
aHelpSpa	:= {}

Aadd(aPergs,{  "Data Inicial       ?","¨Fecha Inicial     ?","Initial Date       ?","mv_ch1","D",8,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","","","S",".CTR07001."})
Aadd(aPergs,{  "Data Final         ?","¨Fecha Final       ?","Final Date         ?","mv_ch2","D",8,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","","","S",".CTR07002."})
Aadd(aPergs,{  "Lote Inicial       ?","¨De Lote           ?","Initial Lot        ?","mv_ch3","C",6,0,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","","","S",".CTR07003."})
Aadd(aPergs,{  "Lote Final         ?","¨A Lote            ?","Final Lote         ?","mv_ch4","C",6,0,0,"G","","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","","","","S",".CTR07004."})
Aadd(aPergs,{  "SubLote Inicial    ?","¨De SubLote        ?","Initial Sublot     ?","mv_ch5","C",3,0,0,"G","","mv_par05","","","","","","","","","","","","","","","","","","","","","","","","","","","S",".CTR07015."})
Aadd(aPergs,{  "SubLote Final      ?","¨A SubLote         ?","Final SubLot       ?","mv_ch6","C",3,0,0,"G","","mv_par06","","","","","","","","","","","","","","","","","","","","","","","","","","","S",".CTR07016."})
Aadd(aPergs,{  "Documento Inicial  ?","¨De Documento      ?","Initial Document   ?","mv_ch7","C",9,0,0,"G","","mv_par07","","","","","","","","","","","","","","","","","","","","","","","","","","","S",".CTR07005."})
Aadd(aPergs,{  "Documento Final    ?","¨A Documento       ?","Final Document     ?","mv_ch8","C",9,0,0,"G","","mv_par08","","","","","","","","","","","","","","","","","","","","","","","","","","","S",".CTR07006."})
Aadd(aPergs,{  "Moeda              ?","¨Moneda            ?","Currency           ?","mv_ch9","C",2,0,0,"G","","mv_par09","","","","","","","","","","","","","","","","","","","","","","","","","CTO","","S",".CTR07007."})                    
Aadd(aPergs,{  	"Impr Cod Conta     ?","¨Impr Cod Cuenta   ?","Print Account Code ?","mv_cha","N",1,0,1,"C","","mv_par10","Normal","Normal","Normal","","","Reduzido","Reducido","Reduced","","","","","","","","","","","","","","","","","","","S",".CTR04019."})
Aadd(aPergs,{  "Imprime Lancamento ?","¨Imprime Asiento   ?","Print Acc.Entry    ?","mv_chb","C",1,0,0,"G","","mv_par11","","","","","","","","","","","","","","","","","","","","","","","","","SLW","","S",".CTR07011."})                    

Aadd(aHelpPor,"Informe se deseja pular pagina")			
Aadd(aHelpPor,"quando mudar o sublote. ")
Aadd(aHelpSpa,"Informe si desea saltar pagina")			
Aadd(aHelpSpa,"cuando mudar el sublote. ")
Aadd(aHelpEng,"Inform if you wish to skip page")			
Aadd(aHelpEng,"when the sublote changes. ")
Aadd(aPergs,{  "Quebra Pagina       ?","¨Salto Pagina      ?","Skip  Page         ?","mv_chc","N",1,0,1,"C","","mv_par12","Sim","Si","Yes","","","Nao","No","No","","","","","","","","","","","","","","","","","","","S",,"",aHelpPor,aHelpEng,aHelpSpa})

Aadd(aPergs,{  	"Imp. Doc em Branco ?","¨Imp. Doc en Blanco?","Print Empty Docum. ?","mv_chd","N",1,0,2,"C","","mv_par13","Sim","Si","Yes","","","Nao","No","No","","","","","","","","","","","","","","","","","","","S",".CTR42016."})

aHelpPor	:= {} 
aHelpEng	:= {}	
aHelpSpa	:= {}
Aadd(aHelpPor,"Informe se deseja imprimir o ")			
Aadd(aHelpPor,"total por lote.")
Aadd(aHelpSpa,"Informe si desea imprimir el ")			
Aadd(aHelpSpa,"total por lote.")
Aadd(aHelpEng,"Inform if you wish to print the ")			
Aadd(aHelpEng,"total by lot.")
Aadd(aPergs,{  "Totaliza Lote       ?","¨Totaliza Lote     ?","Totalize Lot       ?","mv_che","N",1,0,2,"C","","mv_par14","Sim","Si","Yes","","","Nao","No","No","","","","","","","","","","","","","","","","","","","S",,"",aHelpPor,aHelpEng,aHelpSpa})

aHelpPor	:= {} 
aHelpEng	:= {}	
aHelpSpa	:= {}                
Aadd(aHelpPor,"Informe se deseja imprimir o ")			
Aadd(aHelpPor,"total por documento.")
Aadd(aHelpSpa,"Informe si desea imprimir el  ")
Aadd(aHelpSpa,"total por documento. ")
Aadd(aHelpEng,"Inform if you wish to print the ")
Aadd(aHelpEng,"total by  document.")
Aadd(aPergs,{  "Totaliza Doc.       ?","¨Totaliza Doc.     ?","Totalize Doc.      ?","mv_chf","N",1,0,2,"C","","mv_par15","Sim","Si","Yes","","","Nao","No","No","","","","","","","","","","","","","","","","","","","S",,"",aHelpPor,aHelpEng,aHelpSpa})

AjustaSx1(cPerg, aPergs)

RestArea(aArea)

Return
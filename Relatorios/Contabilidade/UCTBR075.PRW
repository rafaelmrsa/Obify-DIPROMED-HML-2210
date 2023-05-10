/*====================================================================================\
|Programa  | UCTBR075      | Autor | Eriberto Elias             | Data | 16/07/2004   |
|=====================================================================================|
|Descrição | Adaptacao para impressao do nome da conta                                |
|=====================================================================================|
|Sintaxe   | uctbr075                                                                 |
|=====================================================================================|
|Uso       | Especifico DIPROMED                                                      |
|=====================================================================================|
|Histórico | DD/MM/AA - Descrição da alteração                                        |
\====================================================================================*/

#Include "UCTBR075.Ch"
#Include "PROTHEUS.Ch"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ CTBR075  ³ Autor ³ Simone Mie Sato       ³ Data ³ 08.10.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Emiss„o do Relatorio de Conferencia por Documento Fiscal   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CTBR075()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function UCTBR075()

Local aCtbMoeda	:= {}
Local WnRel			:= "CTBR075"
Local cDesc1		:= STR0001	//"Este programa ira imprimir o Relatorio para Conferencia"
Local cDesc2		:= STR0002	//"de Digitacao.Podera ser impresso por Documento Fiscal ou"
Local cDesc3		:= STR0003	//"por Conta/Documento Fiscal."                             
Local cString		:= "CT2"
Local titulo		:= STR0015 	//"Conferencia de Digitacao "
Local lRet			:= .T.
Local nTamLinha		:= 132

Private aReturn	:= { STR0004, 1,STR0005, 2, 2, 1, "", 1 }  //"Zebrado"###"Administracao"
Private nomeprog	:= "CTBR075"
Private aLinha		:= {}
Private nLastKey	:= 0

//Private cPerg		:= "CTR075"
// FPADR(cPerg, cArq, cCampo, cTipo)  - Para ajustar o tamanho das perguntas no SX1 - uso generico
PRIVATE cPerg  	:= U_FPADR( "CTR075","SX1","SX1->X1_GRUPO"," " ) //Função criada por Sandro em 19/11/09.

Private Tamanho 	:= "M"             

U_DIPPROC(ProcName(0),U_DipUsr()) // JBS 05/10/2005 - Gravando o nome do Programa no SZU

If ( !AMIIn(34) )		// Acesso somente pelo SIGACTB
	Return
EndIf

If	CT2->(FieldPos("CT2_KEY")) = 0
	MsgAlert(STR0029)//"Esse relatorio necessita do campo CT2_KEY. Favor criá-lo com tipo caracter de 100"
	Return
EndIf

//Cria as perguntas
CTR075SX1(cPerg)

If ! Pergunte(cPerg, .T. )
	Return
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros						 	³
//³ mv_par01				// Data Inicial                  	 	³
//³ mv_par02				// Data Final                         	³
//³ mv_par03				// Lote  Inicial                        ³
//³ mv_par04				// Lote  Final  						³
//³ mv_par05				// Documento Inicial                    ³
//³ mv_par06				// Documento Final			    		³
//³ mv_par07				// Moeda?						     	³
//³ mv_par08				// Imprime Lcto? Realiz. / Orcado / Pre ³
//³ mv_par09				// Quebra Pagina por?Lote/Doc/Nao Quebra³
//³ mv_par10				// Totaliza    ? Sim / Nao			    ³
//³ mv_par11				// Sub-Lote Inicial                  	³
//³ mv_par12				// Sub-Lote Final  						³
//³ mv_par13				//Imprime Doc. Fiscal em Branco(Sim/Nao)³
//³ mv_par14				//Relatorio?Analitico/Sintetico         ³
//³ mv_par15				//Conta Inicial                         ³
//³ mv_par16				//Conta Final                           ³
//³ mv_par17				//Codigo da Conta? Normal/Reduzido      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

wnrel	:= "CTBR075"            //Nome Default do relatorio em Disco
wnrel 	:= SetPrint(cString,wnrel,cPerg,@titulo,cDesc1,cDesc2,,.F.,"",,Tamanho)

If nLastKey = 27
	Set Filter To
	Return
Endif

If lRet
	aCtbMoeda  	:= CtbMoeda(mv_par07)
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

If nLastKey = 27
	Set Filter To
	Return
Endif

RptStatus({|lEnd| CTR075Imp(@lEnd,wnRel,cString,Titulo,nTamlinha,aCtbMoeda)})

Return 

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡…o    ³CTR075Imp ³ Autor ³ Simone Mie Sato       ³ Data ³ 08/10/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡…o ³ Impressao do Razao                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Sintaxe   ³Ctr075Imp(lEnd,wnRel,cString,aSetOfBook,Titulo,nTamlinha,   ³±±
±±³           ³          aCtbMoeda)                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso       ³ SIGACTB                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros ³ lEnd       - A‡ao do Codeblock                             ³±±
±±³           ³ wnRel      - Nome do Relatorio                             ³±±
±±³           ³ cString    - Mensagem                                      ³±±
±±³           ³ Titulo     - Titulo do Relatorio                           ³±±
±±³           ³ nTamLinha  - Tamanho da linha a ser impressa               ³±± 
±±³           ³ aCtbMoeda  - Moeda                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function CTR075Imp(lEnd,WnRel,cString,Titulo,nTamlinha,aCtbMoeda)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local CbTxt
Local cbcont
Local Cabec1		:= ""
Local Cabec2		:= ""
Local cDescMoeda
Local cSaldo		:= mv_par08
Local cMoeda		:= mv_par07
Local cArqTmp
Local cLoteIni		:= mv_par03
Local cLoteFim		:= mv_par04
Local cDocIni		:= mv_par05
Local cDocFim		:= mv_par06
Local cSbLoteIni	:= mv_par11
Local cSbLoteFim	:= mv_par12
Local cContaIni		:= ""
Local cContaFim		:= ""
Local cLote			:= ""
Local cSblote		:= ""
Local cDoc			:= ""
Local cPicture		:= ""

Local aSaldo		:= {}
Local aColunas 
Local aSetOfBook	:= {"","",0,"","","","","",1,""}

Local dDataAnt		:= CTOD("  /  /  ")
Local dDataIni		:= mv_par01
Local dDataFim		:= mv_par02
Local dData

Local lPrimPag		:= .T.
Local lImpDoc0		:= Iif(mv_par13 == 1,.T.,.F.)
Local lAnalitico	:= Iif(mv_par14 == 1,.T.,.F.)
Local lQuebraDoc	:= .F.
Local lTotal		:= Iif(mv_par10 == 1,.T.,.F.)

Local nDecimais
Local nTotDeb		:= 0
Local nTotCrd		:= 0
Local nTotGerDeb	:= 0
Local nTotGerCrd	:= 0
Local nTotalDeb		:= 0
Local nTotalCrd		:= 0
Local nTotLotDeb	:= 0
Local nTotLotCrd	:= 0
Local nTotGerInf	:= 0
Local nTotGerDig	:= 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para Impressao do Cabecalho e Rodape    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cbtxt    := SPACE(10)
cbcont   := 0
li       := 80
m_pag    := 1

cDescMoeda 	:= Alltrim(aCtbMoeda[2])

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Cabe‡alho Relatorio Sintetico                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
// DOC. FISCAL  									        VALOR DEB        VALOR CRED        HP   HIST
// XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX 999999999999999999999.99 99999999999999.99        XXX  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
// 01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
//           1         2         3         4         5         6         7         8         9        10        11        12        13        14        15        16        17        18        19        20        21        22

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Cabe‡alho Relatorio Analitico                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
// CONTA                                      DOC. FISCAL  									         VALOR DEB               VALOR CRED    HP  HIST
// XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX   XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX 9999999999999999999.99   9999999999999999999.99   XXX  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
// 01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
//           1         2         3         4         5         6         7         8         9        10        11        12        13        14        15        16        17        18        19        20        21        22

#DEFINE COL_CONTA    		1
#DEFINE COL_DOCFISCAL		2
#DEFINE COL_VLRDEBITO 		3
#DEFINE COL_VLRCREDIT		4
#DEFINE COL_HP				5
#DEFINE COL_HISTORICO		6
#DEFINE TAMANHO_TM       	7

If lAnalitico
	aColunas    := { 000, 043, 085, 110, 135,140,021 }
	Cabec1 		:= Iif (cPaisLoc<>"MEX" ,STR0014,STR0031) //"CONTA                                     DOC. FISCAL  									                          VALOR DEB                    VALOR CRED      HP    HIST"
	cContaIni   := mv_par15
	cContaFim	:= mv_par16
	Tamanho		:= "G"
	limite		:= 220
	Titulo 		+= 	STR0016+STR0011+cDescMoeda + STR0007 + DTOC(dDataIni) +;	// "DE"
					STR0008 + DTOC(dDataFim) + CtbTitSaldo(mv_par08)	// "ATE"
Else
	aColunas   	:= { , 000, 042, 067, 092, 097,021 }
	Cabec1 		:= Iif (cPaisLoc<>"MEX" ,STR0009 ,STR0030)//"DOC. FISCAL  									           VALOR DEB         VALOR CRED    HP  HIST"	
	limite	    := 132
	Tamanho		:= "M"                                                        
	Titulo 		+= 	STR0017+STR0011+cDescMoeda + STR0007 + DTOC(dDataIni) +;	// "DE"
					STR0008 + DTOC(dDataFim) + CtbTitSaldo(mv_par08)	// "ATE	
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta Arquivo Temporario para Impressao   					 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
MsgMeter({|	oMeter, oText, oDlg, lEnd | ;
			CTBR420Raz(oMeter,oText,oDlg,lEnd,@cArqTmp,cContaIni,cContaFim,;
			cMoeda,dDataIni,dDataFim,aSetOfBook,.F.,cSaldo,"2",lAnalitico,cLoteIni,cLoteFim,;
			cSbLoteIni,cSbLoteFim,cDocIni,cDocFim,)},;
			STR0012,;		// "Criando Arquivo Tempor rio..."
			STR0006)		// "Emissao do Relat. Conf. Dig. "
				

dbSelectArea("cArqTmp")
SetRegua(RecCount())
dbGoTop()

While !Eof()

	IF lEnd
		@Prow()+1,0 PSAY STR0010  //"***** CANCELADO PELO OPERADOR *****"
		Exit
	EndIF                                         
	
	If !lImpDoc0 .And. Empty(cArqTmp->CT2KEY) 
		dbSkip()
		Loop
	Endif	

	IncRegua()                                    	
	
	cLote 		:= cArqTmp->LOTE
	cSubLote 	:= cArqTmp->SUBLOTE
	cDoc		:= cArqTmp->DOC
	dData 		:= cArqTmp->DATAL
	
	lFirst:= .T.
	
	nTotalDeb := 0
	nTotalCrd := 0

	lQuebraDoc := Iif(mv_par09==2,.T.,.F.)
	While !Eof() .And. 	Dtos(cArqTmp->DATAL) == Dtos(dData) 	.And.;
						cArqTmp->LOTE == cLote 					.And.;
						cArqTmp->SUBLOTE == cSubLote 			.And.;
						cArqTmp->DOC == cDoc


		IncRegua()
			
		IF li > 62 .Or. lQuebraDoc
			Cabec( Titulo, Cabec1, Cabec2, NomeProg, Tamanho,;
				Iif(aReturn[4] == 1, GetMv("MV_COMP"), GetMv("MV_NORM")))
			If lQuebraDoc .Or. lPrimPag
				lPrimPag	:= .F.				
			EndIf	
			lQuebraDoc := .F.
		EndIf                
			
		If lFirst 
			@ li,00 PSAY Replicate("-",Limite)			
			li++
			@ li,000 PSAY OemToAnsi(STR0018)  //"DATA: "
			@ li,007 PSAY DTOC(dData)
			@ li,019 PSAY OemToAnsi(STR0019)  //"LOTE: "
			@ li,027 PSAY cLote
			@ li,038 PSAY OemToAnsi(STR0021) //"Sub-Lote"
			@ li,049 PSAY cSubLote
			@ li,058 PSAY Iif (cPaisLoc<>"MEX" ,OemToAnsi(STR0020),OemToAnsi(STR0032))  //"DOC: "
			@ li,064 PSAY cDoc
			lFirst := .F.
			li ++
			@ li,00 PSAY Replicate("-",Limite)						
			li++
		EndIf

		If lAnalitico			
			If mv_par17 == 2
				dbSelectArea("CT1")
				dbSetOrder(1)
				If MsSeek(xFilial()+cArqTmp->CONTA)
					@ li, aColunas[COL_CONTA] PSAY CT1->CT1_RES
				EndIf
			Else
				@ li, aColunas[COL_CONTA] PSAY cArqTmp->CONTA
			Endif			
		EndIf

	 	//@ li, aColunas[COL_DOCFISCAL] PSAY Subs(cArqTmp->CT2KEY,1,40) 				
	 	@ li, aColunas[COL_DOCFISCAL]-10 PSAY POSICIONE("CT1",1,xFilial("CT1")+cArqTmp->CONTA,"CT1_DESC01")

	 	
 		ValorCTB(cArqTmp->LANCDEB,li,aColunas[COL_VLRDEBITO],aColunas[TAMANHO_TM],2,;
							         .F.,cPicture)
 		ValorCTB(cArqTmp->LANCCRD,li,aColunas[COL_VLRCREDIT],aColunas[TAMANHO_TM],2,;
							         .F.,cPicture)


		nTotalDeb += cArqTmp->LANCDEB
		nTotGerDeb+= cArqTmp->LANCDEB
		nTotLotDeb+= cArqTmp->LANCDEB

		nTotalCrd += cArqTmp->LANCCRD				
		nTotGerCrd+= cArqTmp->LANCCRD				
		nTotLotCrd+= cArqTmp->LANCCRD				

		@ li, aColunas[COL_HP] 	PSAY cArqTmp->HP
		@ li, aColunas[COL_HISTORICO] PSAY cArqTmp->HISTORICO
		li++

		dbSelectarea("cArqTmp")	
		dbSkip()			
			
	Enddo	                       
	If lTotal 
		li++
		@ li,02 PSAY STR0027	//TOTAL DOCUMENTO
		CTC->(MsSeek(xFilial()+dtos(dData)+cLote+cSubLote+cDoc+"01"))
		nTotGerInf += CTC->CTC_INF
		nTotGerDig += CTC->CTC_DIG
 		ValorCTB(nTotalDeb,li,aColunas[COL_VLRDEBITO],aColunas[TAMANHO_TM],2,;
							         .F.,cPicture)
 		ValorCTB(nTotalCrd,li,aColunas[COL_VLRCREDIT],aColunas[TAMANHO_TM],2,;
							         .F.,cPicture)
		

		
		If limite = 132
			nCol := If(Len(aColunas) > 0, aColunas[COL_HISTORICO], 097)
			@ li ++, nCol	PSAY STR0024 + 	Trans(CTC->CTC_INF, Tm(CTC->CTC_INF,17)) //"INFORMADO"
			@ li   , nCol	PSAY STR0025 + 	Trans(CTC->CTC_DIG, Tm(CTC->CTC_DIG,17)) //"DIGITADO "
			If Round(NoRound(CTC->CTC_DIG - CTC->CTC_INF, 2), 2) # 0
				li ++
				@ li,nCol PSAY STR0026 + Trans(Abs(CTC->CTC_DIG - CTC->CTC_INF),; //"DIFERENCA"
						   					 Tm(CTC->CTC_DIG,17))
			Endif
		Else
			@ li, aColunas[COL_HP] 		PSAY STR0024 + Trans(CTC->CTC_INF,; //"INFORMADO "
																Tm(CTC->CTC_INF,17)) +;
			 								     Space(2) + STR0025 +; //"DIGITADO "
			 								     Trans(CTC->CTC_DIG, Tm(CTC->CTC_DIG,17)) +;
			 								     Space(2) + STR0026 +; //"DIFERENCA"
												 Trans(	Abs(CTC->CTC_DIG-CTC->CTC_INF),;
												 Tm(CTC->CTC_DIG,17))
		Endif
		li++
		nTotalDeb := 0	
		nTotalCrd := 0	
		
		// TOTALIZA O LOTE
		If cLote != cArqTmp->LOTE 				.Or.;
		   cSubLote != cArqTmp->SUBLOTE 			.Or.;
		   Dtos(dData) != Dtos(cArqTmp->DATAL)
			li++
			@ li,00 PSAY Replicate("-",Limite)			
			li++
			@ li,02 PSAY OemToAnsi(STR0028)//TOTAL LOTE
			CT6->(MsSeek(xFilial()+dtos(dData)+cLote+cSubLote+"01"))
			
	 		ValorCTB(nTotLotDeb,li,aColunas[COL_VLRDEBITO],aColunas[TAMANHO_TM],2,;
			         .F.,cPicture)
	 		ValorCTB(nTotLotCrd,li,aColunas[COL_VLRCREDIT],aColunas[TAMANHO_TM],2,;
			         .F.,cPicture)			

			If limite = 132
				nCol := If(Len(aColunas) > 0, aColunas[COL_HISTORICO], 097)
				@ li ++, nCol PSAY STR0024 + 	Trans(CT6->CT6_INF,; //"INFORMADO"
													Tm(CT6->CT6_INF,17))
				@ li   , nCol PSAY STR0025 + 	Trans(CT6->CT6_DIG,; //"DIGITADO "
													Tm(CT6->CT6_DIG,17))
				If Round(NoRound(CT6->CT6_DIG - CT6->CT6_INF, 2), 2) # 0
					li ++
					@ li,nCol PSAY STR0026 + 	Trans(Abs(CT6->CT6_DIG -; //"DIFERENCA"
													CT6->CT6_INF), Tm(CT6->CT6_DIG,17))
				Endif
			Else
				@ li, aColunas[COL_HP] 		PSAY STR0024 + Trans(CT6->CT6_INF,; //"INFORMADO "
																	Tm(CT6->CT6_INF,17)) +;
			 								     Space(2) + STR0025 +; //"DIGITADO "
			 								     Trans(CT6->CT6_DIG, Tm(CT6->CT6_DIG,17)) +;
			 								     Space(2) + STR0026 +;  //"DIFERENCA"
												 Trans(	Abs(CT6->CT6_DIG-CT6->CT6_INF),;
												 Tm(CT6->CT6_DIG,17))
			Endif
			li++   
			@ li,00 PSAY Replicate("-",Limite)			
			li++
			
			nTotLotDeb := 0	
			nTotLotCrd := 0	
        EndIf
	EndIf
	
	// Impressao do Cabecalho
	If mv_par09 == 1 .And. !Eof()		// Quebra pagina quando for lote diferente
		If cLote != cArqTmp->LOTE 				.Or.;
		   cSubLote != cArqTmp->SUBLOTE 		.Or.;
		   Dtos(dData) != Dtos(cArqTmp->DATAL)  
			Cabec( Titulo, Cabec1, Cabec2, NomeProg, Tamanho,;
			Iif(aReturn[4] == 1, GetMv("MV_COMP"), GetMv("MV_NORM")))
		EndIf
	ElseIF li > 62
		Cabec( Titulo, Cabec1, Cabec2, NomeProg, Tamanho,;
				Iif(aReturn[4] == 1, GetMv("MV_COMP"), GetMv("MV_NORM")))
	EndIf
	
EndDo
If li != 80
	If lTotal
		IF li > 55 
			Cabec( Titulo, Cabec1, Cabec2, NomeProg, Tamanho,;
					Iif(aReturn[4] == 1, GetMv("MV_COMP"), GetMv("MV_NORM")))
		EndIf		
		li+=2
		@ li,00 PSAY Replicate("-",Limite)
		li++
		@ li,02 PSAY OemToAnsi(STR0013)//"T O T A L  G E R A L ==> "		
 		ValorCTB(nTotGerDeb,li,aColunas[COL_VLRDEBITO],aColunas[TAMANHO_TM],2,;
		         .F.,cPicture)
 		ValorCTB(nTotGerCrd,li,aColunas[COL_VLRCREDIT],aColunas[TAMANHO_TM],2,;
		         .F.,cPicture)			

		If limite = 132
			nCol := If(Len(aColunas) > 0, aColunas[COL_HISTORICO], 097)
			@ li ++, nCol  	PSAY STR0024 + 	Trans(nTotGerInf, Tm(nTotGerInf,17)) //"INFORMADO"
			@ li   , nCol	PSAY STR0025 + 	Trans(nTotGerDig, Tm(nTotGerDig,17)) //"DIGITADO "
			If Round(NoRound(nTotGerDig - nTotGerInf, 2), 2) # 0
				li ++
				@ li,nCol	PSAY STR0026 + 	Trans(Abs(nTotGerDig - nTotGerInf),; //"DIFERENCA"
												Tm(nTotGerDig,17))
			Endif
		Else
			@ li, aColunas[COL_HP] 	PSAY STR0024 + Trans(nTotGerInf,; //"INFORMADO "
																Tm(nTotGerInf,17)) +;
		 								     Space(2) + STR0025 +; //"DIGITADO "
		 								     Trans(nTotGerDig, Tm(nTotGerDig,17)) +;
		 								     Space(2) + STR0026 +;  //"DIFERENCA"
											 Trans(	Abs(nTotGerDig-nTotGerInf),;
											 Tm(nTotGerDig,17))
		Endif
		li++
		@ li,00 PSAY Replicate("-",Limite)
	EndIf	
	roda(cbcont,cbtxt,"M")
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

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡…o    ³Ctbr075Flt³ Autor ³ Simone Mie Sato       ³ Data ³ 08/10/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡…o ³Realiza a "filtragem" dos registros do Conf. Digitacao      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe    ³Ctbr075Flt(oMeter,oText,oDlg,lEnd,cMoeda,dDataIni,dDataFim, ³±±
±±³           ³           cSaldo)   								       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno    ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso       ³ SIGACTB                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros ³ oMeter 		= Objeto oMeter                                ³±±
±±³           ³ oText  		= Objeto oText                                 ³±±
±±³           ³ oDlg   		= Objeto oDlg                                  ³±±
±±³           ³ lEnd   		= Acao do Codeblock                            ³±±
±±³           ³ cMoeda 		= Moeda                                        ³±±
±±³           ³ dDataIni 	= Data Inicial                                 ³±±
±±³           ³ dDataFim 	= Data Final                                   ³±±
±±³           ³ cSaldo		= Tipo de Saldo                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Ctbr075Flt(oMeter,oText,oDlg,lEnd,cMoeda,dDataIni,dDataFim,cSaldo,;
			lAnalitico,cLoteIni,cLoteFim,cSbLoteIni,cSbLoteFim,cDocIni,cDocFim)

Local aSaveArea := GetArea()
Local nMoeda	:= Val(cMoeda), cChave

oMeter:nTotal := CT2->(RecCount())

dbSelectArea("CT2")
dbSetOrder(1)
MsSeek(xFilial()+dtos(dDataIni)+cLoteIni+cSbLoteIni+cDocIni,.T.)

While !Eof() .And. CT2->CT2_FILIAL == xFilial() .And. ;
	CT2->CT2_DATA >= dDataIni .And. CT2->CT2_DATA <= dDataFim 
		

		IF 	CT2->CT2_MOEDLC <> cMoeda .Or.;
			CT2->CT2_VALOR == 0 .Or. CT2->CT2_TPSALD != cSaldo
			dbSkip()
			Loop
		EndIF

		If  (CT2->CT2_LOTE < cLoteIni .Or. CT2->CT2_LOTE > cLoteFim) .Or. ;
			(CT2->CT2_SBLOTE < cSbLoteIni .Or. CT2->CT2_SBLOTE > cSbLoteFim) .Or. ;
			(CT2->CT2_DOC < cDocIni .Or. CT2->CT2_DOC > cDocFim)
			dbSkip()
			Loop
		EndIf
         
		If CT2->CT2_DC == "1"
			Ctbr420Grv(cMoeda,cSaldo,"1","2",lAnalitico)
		ElseIf CT2->CT2_DC == "2"
			Ctbr420Grv(cMoeda,cSaldo,"2","2",lAnalitico)
		ElseIf CT2->CT2_DC == "3"     
			Ctbr420Grv(cMoeda,cSaldo,"1","2",lAnalitico)
			Ctbr420Grv(cMoeda,cSaldo,"2","2",lAnalitico)		
		EndIf
		dbSelectArea("CT2")
		dbSetOrder(1)
		dbSkip()
	Enddo

Return                        

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ CTR075SX1    ³Autor ³  Simone Mie Sato     ³Data³ 06/11/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Cria as perguntas ref. o relatorio CTBR075.                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function CTR075SX1(cPerg)

Local aArea 	:= GetArea()
Local aPergs	:= {}

Local nTamCta	:= Len(CriaVar("CT1_CONTA"))

aPergs := {}    

Aadd(aPergs,{  "Data Inicial       ?","¨Fecha Inicial     ?","Initial Date       ?","mv_ch1","D",8,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","","","S",".CTR07001."})
Aadd(aPergs,{  "Data Final         ?","¨Fecha Final       ?","Final Date         ?","mv_ch2","D",8,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","","","S",".CTR07002."})                       
Aadd(aPergs,{  "Lote Inicial       ?","¨De Lote           ?","Initial Lot        ?","mv_ch3","C",6,0,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","","","S",".CTR07003."})
Aadd(aPergs,{  "Lote Final         ?","¨A Lote            ?","Final Lote         ?","mv_ch4","C",6,0,0,"G","","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","","","","S",".CTR07004."})

If cPaisLoc<>"MEX"
	Aadd(aPergs,{  "Documento Inicial  ?","¨De Documento      ?","Initial Document   ?","mv_ch5","C",9,0,0,"G","","mv_par05","","","","","","","","","","","","","","","","","","","","","","","","","","","S",".CTR07005."})
	Aadd(aPergs,{  "Documento Final    ?","¨A Documento       ?","Final Document     ?","mv_ch6","C",9,0,0,"G","","mv_par06","","","","","","","","","","","","","","","","","","","","","","","","","","","S",".CTR07006."})
Else
	Aadd(aPergs,{  "Documento Inicial  ?","¨De Poliza         ?","Initial Document   ?","mv_ch5","C",9,0,0,"G","","mv_par05","","","","","","","","","","","","","","","","","","","","","","","","","","","S",".CTR07005."})
	Aadd(aPergs,{  "Documento Final    ?","¨A Poliza          ?","Final Document     ?","mv_ch6","C",9,0,0,"G","","mv_par06","","","","","","","","","","","","","","","","","","","","","","","","","","","S",".CTR07006."})
EndIf

Aadd(aPergs,{  "Moeda              ?","¨Moneda            ?","Currency           ?","mv_ch7","C",2,0,0,"G","","mv_par07","","","","","","","","","","","","","","","","","","","","","","","","","CTO","","S",".CTR07007."})                    
Aadd(aPergs,{  "Imprime Lancamento ?","¨Imprime Asiento   ?","Print Acc.Entry    ?","mv_ch8","C",1,0,0,"G","","mv_par08","","","","","","","","","","","","","","","","","","","","","","","","","SLD","","S",".CTR07011."})                    

If cPaisLoc<>"MEX"
	Aadd(aPergs,{  "Quebra Pagina Por  ?","¨Salto Pagina Por  ?","Break Page By      ?","mv_ch9","N",1,0,1,"C","","mv_par09","Lote","Lote","Lot","","","Documento","Documento","Document","","","Nao Quebra","No Salta","No Break","","","","","","","","","","","","","","S",".CTR07012."})
Else
	Aadd(aPergs,{  "Quebra Pagina Por  ?","¨Salto Pagina Por  ?","Break Page By      ?","mv_ch9","N",1,0,1,"C","","mv_par09","Lote","Lote","Lot","","","Documento","Poliza   ","Document","","","Nao Quebra","No Salta","No Break","","","","","","","","","","","","","","S",".CTR07012."})
EndIf

Aadd(aPergs,{  "Totaliza           ?","¨Totaliza          ?","Totalize           ?","mv_cha","N",1,0,2,"C","","mv_par10","Sim","Si","Yes","","","Nao","No","No","","","","","","","","","","","","","","","","","","","S",".CTR07013."})
Aadd(aPergs,{  "SubLote Inicial    ?","¨De SubLote        ?","Initial Sublot     ?","mv_chb","C",3,0,0,"G","","mv_par11","","","","","","","","","","","","","","","","","","","","","","","","","","","S",".CTR07015."})
Aadd(aPergs,{  "SubLote Final      ?","¨A SubLote         ?","Final SubLot       ?","mv_chc","C",3,0,0,"G","","mv_par12","","","","","","","","","","","","","","","","","","","","","","","","","","","S",".CTR07016."})
Aadd(aPergs,{  	"Imp. Doc em Branco ?","¨Imp. Doc en Blanco?","Print Empty Docum. ?","mv_chd","N",1,0,2,"C","","mv_par13","Sim","Si","Yes","","","Nao","No","No","","","","","","","","","","","","","","","","","","","S",".CTR42016."})
Aadd(aPergs,{  	"Tipo Relatorio     ?","¨Tipo Informe      ?","Report Type        ?","mv_che","N",1,0,1,"C","","mv_par14","Analitico","Analitico","Detailed","","","Resumido","Resumido","Summarized","","","","","","","","","","","","","","","","","","","S",".CTR44008."})
Aadd(aPergs,{  	"Da Conta           ?","¨De Cuenta         ?","From Account       ?","mv_chf","C",nTamCta,0,0,"G","","mv_par15","","","","","","","","","","","","","","","","","","","","","","","","","CT1","003","S",".CTR40001."})
Aadd(aPergs,{  	"Ate Conta          ?","¨A  Cuenta         ?","To Account         ?","mv_chg","C",nTamCta,0,0,"G","","mv_par16","","","",Repl("Z", nTamCta),"","","","","","","","","","","","","","","","","","","","","CT1","003","S",".CTR40002."})
Aadd(aPergs,{  	"Impr Cod Conta     ?","¨Impr Cod Cuenta   ?","Print Account Code ?","mv_chh","N",1,0,1,"C","","mv_par17","Normal","Normal","Normal","","","Reduzido","Reducido","Reduced","","","","","","","","","","","","","","","","","","","S",".CTR04019."})
          
AjustaSx1(cPerg,aPergs)

RestArea(aArea)

Return

/*====================================================================================\
|Programa  | UCTBR070      | Autor | Eriberto Elias             | Data | 13/10/2004   |
|=====================================================================================|
|Descrição | Adaptacao para impressao do nome da conta                                |
|=====================================================================================|
|Sintaxe   | uctbr070                                                                 |
|=====================================================================================|
|Uso       | Especifico DIPROMED                                                      |
|=====================================================================================|
|Histórico | DD/MM/AAAA - Descrição da alteração                                      |
|Rafael    | 14/10/2004 - Inclusão da descrição da conta no relatório                 |
\====================================================================================*/


#Include "uCtbr070.Ch"
#Include "rwmake.Ch"

#DEFINE CENTRO_CUSTO		1
#DEFINE ITEM_CONTABIL	2
#DEFINE CLASSE_VALOR 	3
#DEFINE VALOR_DEBITO 	4
#DEFINE VALOR_CREDITO	5
#DEFINE CODIGO_HP    	6
#DEFINE HISTORICO    	7

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³ Ctbr070	³ Autor ³ Pilar S Albaladejo	³ Data ³ 12.09.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Conferencia de Digitacao               	 				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ Ctbr070()    											  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ Nenhum       											  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ Generico      											  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
USer Function uCtbR070()

Local aCtbMoeda		:= {}
LOCAL cDesc1 		:= OemToAnsi(STR0001)	//"Este programa ira imprimir o Relatorio para Conferencia"
LOCAL cDesc2 		:= OemToansi(STR0002)   //"de Digitacao - Modelo 1. Ideal para Plano de Contas "
LOCAL cDesc3		:= OemToansi(STR0003)   //"que possuam codigos nao muito extensos.            "
Local cNomeArq
LOCAL wnrel
LOCAL cString		:= "CT2"
Local titulo 		:= OemToAnsi(STR0004) 	//"Conferencia de Digitacao - Modelo 1"
Local lRet			:= .T.
Local lCusto 		:= .F.
Local lItem 		:= .F.
Local lCV	 		:= .F.
Local Limite		:= 220
Local cDescMoeda	:= ""

PRIVATE Tamanho		:="M"
PRIVATE nLastKey 	:= 0

//PRIVATE cPerg	 	:= "CTR070"
// FPADR(cPerg, cArq, cCampo, cTipo)  - Para ajustar o tamanho das perguntas no SX1 - uso generico
PRIVATE cPerg  	:= U_FPADR( "CTR070","SX1","SX1->X1_GRUPO"," " ) //Função criada por Sandro em 19/11/09.

PRIVATE aReturn 	:= { OemToAnsi(STR0005), 1,OemToAnsi(STR0006), 2, 2, 1, "",1 }  //"Zebrado"###"Administracao"
PRIVATE aLinha		:= {}
PRIVATE nomeProg  := "CTBR070"

U_DIPPROC(ProcName(0),U_DipUsr()) // JBS 05/10/2005 - Gravando o nome do Programa no SZU
li 		:= 80
m_pag	:= 1
                     
If cPaisLoc == "CHI"
	AjustaSX1(cPerg)
EndIf
 
Pergunte(cPerg,.F.)
            
If mv_par17 == 1		// Resumido
	Titulo += OemToAnsi(STR0022)
EndIf	

If mv_par09 == 1 
	lCusto := .T.
Else 
	lCusto := .F.	
Endif	

If mv_par10 == 1 
	lItem := .T.
Else 
	lItem := .F.	
Endif	

If mv_par14 == 1 
	lCV := .T.
Else 
	lCV := .F.	
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
//³ mv_par08				// Cod Conta? Normal / Reduzido 		³
//³ mv_par09				// Imprime C. Custo? Sim / Nao	    	³
//³ mv_par10				// Imprime Item? Sim / Nao			    ³
//³ mv_par11				// Imprime Lcto? Realiz. / Orcado / Pre ³
//³ mv_par12				// Quebra Pagina por?Lote/Doc/Nao Quebra³
//³ mv_par13				// Totaliza    ? Sim / Nao			    ³
//³ mv_par14				// Imprime Classe de Valores? Sim / Nao ³
//³ mv_par15				// Sub-Lote Inicial                  	³
//³ mv_par16				// Sub-Lote Final  						³
//³ mv_par17				// Imprime? Resumido / Completo			³
//³ mv_par18				// Cod C.C. ? Normal / Reduzido			³
//³ mv_par19				// Cod Item ? Normal / Reduzido 		³
//³ mv_par20				// Cod Cl.Vlr? Normal / Reduzido 		³ 
//³ mv_par21				// Impr. Compl. Part. Dobrada? Sim/Não  ³
//³ mv_par22				// Do Corrrelativo               	 	³
//³ mv_par23				// Ate Correlativo                    	³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

wnrel	:= "CTBR070"            //Nome Default do relatorio em Disco
wnrel := SetPrint(cString,wnrel,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,"",,Tamanho)

If mv_par09 == 1                   
	lCusto := .T.
Else 
	lCusto := .F.	 
Endif	

If mv_par10 == 1 
	lItem := .T.
Else 
	lItem := .F.	
Endif	

If mv_par14 == 1 
	lCV := .T.
Else 
	lCV := .F.	
Endif	

If nLastKey == 27
	Set Filter To
	Return
Endif

If lRet
	aCtbMoeda  	:= CtbMoeda(mv_par07)
	If Empty(aCtbMoeda[1])                       
      Help(" ",1,"NOMOEDA")
      Set Filter To
      Return
   Endif
Endif

cDescMoeda 	:= Alltrim(aCtbMoeda[2])

Titulo	+= STR0040 + cDescMoeda

// Somente caso imprima dois tipos juntos envio como 220 colunas
If (mv_par17 == 2) .And. ((lCusto .And. lItem) .Or. (lItem .And. lCv) .Or. (lCusto .And. lCv) .Or.;
   (lCusto .And. lItem .And. lCv)) .Or. mv_par17 = 1
	tamanho := "G"
//	Limite  := 220
Endif

SetDefault(aReturn,cString,,,Tamanho,If(Tamanho="G",2,1))	

If nLastKey == 27
	Set Filter To
	Return
Endif

RptStatus({|lEnd| CTR070Imp(@lEnd,wnRel,cString,Titulo,lCusto,lItem,lCV,Limite)})

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³CTR070IMP ³ Autor ³ Pilar S. Albaladejo   ³ Data ³ 24.07.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Imprime relatorio -> Conferencia Digitacao Modelo 1        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³CTR070Imp(lEnd,WnRel,cString,Titulo,lCusto,lItem,lCV)       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpL1   - A‡ao do Codeblock                                ³±±
±±³          ³ ExpC1   - T¡tulo do relat¢rio                              ³±±
±±³          ³ ExpC2   - Mensagem                                         ³±±
±±³          ³ ExpC3   - Titulo                                           ³±±
±±³          ³ ExpL1   - Define se imprime o centro de custo              ³±±
±±³          ³ ExpL2   - Define se imprime o item                         ³±±
±±³          ³ ExpL3   - Define se imprime a classe de valor              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function CTR070Imp(lEnd,WnRel,cString,Titulo,lCusto,lItem,lCV,Limite)

LOCAL CbTxt		:= Space(10)
Local CbCont	:= 0
Local cabec1  	:= ""                                       
Local cabec2  	:= " "

Local aColunas		:= {}
Local cDigVer  		:= GetMv("MV_DIGVER")
Local cLote
Local cSubLote
Local cDoc                
Local cMoeda		:= mv_par07
Local cSayItem		:= CtbSayApro("CTD")
Local cSayCC		:= CtbSayApro("CTT")
Local cSayCV		:= CtbSayApro("CTH")
Local cLoteRes
Local cSubRes
Local cDocRes                            

Local dDataRes
Local dData
Local lTotal		:= Iif(mv_par13 == 1,.T.,.F.)
Local lResumo	    := Iif(mv_par17 == 1,.T.,.F.)
Local lPrimPag		:= .T.
Local lQuebraDoc	:= .F.   
Local cSEGOFI		:= "" //Correlativo para o Chile
Local nTotalDeb		:= 0
Local nTotalCrd		:= 0
Local nTotLotDeb	:= 0
Local nTotLotCrd	:= 0
Local nTotGerDeb	:= 0
Local nTotGerCrd	:= 0
Local nTotGerInf	:= nTotGerDig := 0
Local nDif			:= 0
Local nCol

If !lResumo
	If !lCusto .And. !lItem .And. !lCV //So imprime a conta
		Cabec1 := Iif (cPaisLoc<>"MEX" ,OemToAnsi(STR0007),OemToAnsi(STR0029))+space(19)+ Iif (cPaisLoc<>"MEX" ,OemToAnsi(STR0015),OemToAnsi(STR0033))
	Else
	
	/*	
	LI TP CONTA                C CUSTO              ITEM CONTA           COD CL VAL                   VALOR DEB        VALOR CRED  HP HIST
	
	      12345678901234567890 12345678901234567890 12345678901234567890 12345678901234567890 12345678901234567 12345678901234567 123 1234567890123456789012345678901234567890
	
	LI TP CONTA                ITEM CONTA           COD CL VAL                   VALOR DEB        VALOR CRED  HP HIST
	
	      12345678901234567890 12345678901234567890 12345678901234567890 12345678901234567 12345678901234567 123 1234567890123456789012345678901234567890
	      
	LI TP CONTA                COD CL VAL                   VALOR DEB        VALOR CRED  HP HIST
	                           12345678901234567890         VALOR DEB        VALOR CRED  HP HIST 
	
	      12345678901234567890 12345678901234567890 12345678901234567 12345678901234567 123 1234567890123456789012345678901234567890
	*/
	
		Cabec1 := OemToAnsi(STR0008)
		If lCusto .And. lItem .And. lCv
			aColunas := { 047, 060, 073, 090, 108, 126, 130 }
//			aColunas := { 027, 048, 069, 090, 108, 126, 130 }
		ElseIf (lCusto .And. lItem)
			aColunas := { 047, 060, 000, 073, 091, 109, 113 }
//			aColunas := { 027, 048, 000, 069, 087, 105, 109 }
		ElseIf (lCusto .And. lCv)
			aColunas := { 047, 000, 060, 073, 091, 109, 113 }
//			aColunas := { 027, 000, 048, 069, 087, 105, 109 }
		ElseIf (lItem .And. lCv)
			aColunas := { 000, 047, 060, 073, 091, 109, 113 }
//			aColunas := { 000, 027, 048, 069, 087, 105, 109 }
		ElseIf lCusto
			aColunas := { 047, 000, 000, 060, 078, 096, 100 }
//			aColunas := { 027, 000, 000, 048, 066, 084, 088 }
		ElseIf lItem
			aColunas := { 000, 047, 000, 060, 078, 096, 100 }
//			aColunas := { 000, 027, 000, 048, 066, 084, 088 }
		Else
			aColunas := { 000, 000, 047, 060, 078, 096, 100 }
//			aColunas := { 000, 000, 027, 048, 066, 084, 088 }
		Endif 
		If lCusto
			Cabec1 += OemToAnsi(Upper(Left(cSayCC + Space(13), 13)))
		Endif
		If lItem
			Cabec1 += OemToAnsi(Upper(Left(cSayItem + Space(13), 13)))
		Endif
		If lCv
			Cabec1 += OemToAnsi(Upper(Left(cSayCv + Space(17), 17)))
		Endif
		Cabec1 += Iif (cPaisLoc<>"MEX" ,OemToAnsi(STR0016),OemToAnsi(STR0034))
	EndIf
Else
	Cabec1 := Iif (cPaisLoc<>"MEX" ,OemToAnsi(STR0021),OemToAnsi(STR0035))
	
	CTC->(DbSetOrder(1))
/*
DATA          LOTE      SUBLOTE    DOCUMENTO      TOTAL INFORMADO       VALOR A DEBITO      VALOR A CREDITO           DIFERENCA                        TOTAL DIGITADO    DIFERENCA INF/DIG
***********************************************************************************************************************************************************************************************************
10/06/2002    008850        001       000001             2.500,00             2.500,00             2.500,00                0,00    1234567890123             2.500,00                 0,00    1234567890123
*/                                                                                                                                                                                         
EndIf	

dbSelectArea("CT2")
dbSetOrder(1)
dbSeek(xFilial()+DTOS(mv_par01)+mv_par03+mv_par15+mv_par05,.T.)

SetRegua(RecCount())

While !Eof() .And. CT2->CT2_FILIAL == xFilial() 	.And.;
					CT2->CT2_DATA <= mv_par02                       
					
	If lEnd
		@Prow()+1,0 PSAY OemToAnsi(STR0009)   //"***** CANCELADO PELO OPERADOR *****"
		Exit
	EndIF                        
	
	If Ctr070Skip()
		dbSkip()
		Loop
	EndIf	

	IncRegua()

	cLote 		:= CT2->CT2_LOTE
	cSubLote 	:= CT2->CT2_SBLOTE
	cDoc		:= CT2->CT2_DOC
	dData 		:= CT2->CT2_DATA   
	If cPaisLoc == "CHI"	
		cSegOfi := CT2->CT2_SEGOFI
	EndIf		
	
	lFirst:= .T.
	nTotalDeb := 0
	nTotalCrd := 0

	lQuebraDoc := Iif(mv_par12==2,.T.,.F.)
	While !Eof() .And. CT2->CT2_FILIAL == xFilial() 			.And.;
						Dtos(CT2->CT2_DATA) == Dtos(dData) 	.And.;
						CT2->CT2_LOTE == cLote 				.And.;
						CT2->CT2_SBLOTE == cSubLote 			.And.;
						CT2->CT2_DOC == cDoc

		If Ctr070Skip()
			dbSkip()
			Loop
		EndIf	

		IncRegua()

		IF (!lResumo .And. li > 62) .Or. lQuebraDoc
			Cabec( Titulo, Cabec1, Cabec2, NomeProg, Tamanho,;
					Iif(aReturn[4] == 1, GetMv("MV_COMP"), GetMv("MV_NORM")))
			If lQuebraDoc .Or. lPrimPag
				lPrimPag	:= .F.				
			EndIf	
			lQuebraDoc := .F.
		EndIf

		If lFirst .And. !lResumo
			@ li,00 PSAY Replicate("-",Limite)			
			li++
			@ li,000 PSAY OemToAnsi(STR0012)
			@ li,007 PSAY DTOC(dData)
			@ li,019 PSAY OemToAnsi(STR0013)
			@ li,027 PSAY cLote
			@ li,038 PSAY OemToAnsi(STR0017) //"Sub-Lote"
			@ li,049 PSAY cSubLote
			@ li,058 PSAY Iif (cPaisLoc<>"MEX" ,OemToAnsi(STR0014),OemToAnsi(STR0032))
			@ li,064 PSAY cDoc        

			If cPaisLoc == "CHI"
				@ Li,80 PSAY STR0039 + cSegOfi
			EndIf		

			lFirst := .F.
			li ++
			@ li,00 PSAY Replicate("-",Limite)						
			li++
		EndIf
	
		If !lResumo			// Imprime o relatorio detalhado
			If ! lCusto .And. ! lItem .And. ! lCv //Se nao imprime C.C, Item E Cl.Valores
				@ li, 000 PSAY CT2->CT2_LINHA
				@ li, 004 PSAY CT2->CT2_DC
				If mv_par08 == 2
					dbSelectArea("CT1")
					dbSeek(xFilial()+CT2->CT2_DEBITO)
					@ li, 006 PSAY CT1->CT1_RES
					dbSeek(xFilial()+CT2->CT2_CREDIT)				
					@ li, 027 PSAY CT1->CT1_RES
					dbSelectArea("CT2")				
				Else
					@ li, 006 PSAY CT2->CT2_DEBITO
					@ li, 027 PSAY CT2->CT2_CREDIT
				Endif			

				nValor := &('CT2->CT2_VLR'+cMoeda)

				If CT2->CT2_DC == "1" .Or. CT2->CT2_DC == "3" 
					@ li, 049 PSAY nValor Picture Tm(nValor,17)
					nTotalDeb += nValor
					nTotGerDeb+= nValor
					nTotLotDeb+= nValor
				Endif
				If CT2->CT2_DC == "2" .Or. CT2->CT2_DC == "3"
					@ li, 070 PSAY nValor Picture Tm(nValor,17)
					nTotalCrd += nValor
					nTotGerCrd+= nValor
					nTotLotCrd+= nValor					
				Endif
				@ li, 092 PSAY CT2->CT2_HP
				@ li, 097 PSAY CT2->CT2_HIST
			Else //Se imprime C.C ou Item ou Cl. Valores os lanc. tipo '3' serao desdobrados
				If CT2->CT2_DC == '1' .Or. CT2->CT2_DC =='2'//Se o lancamento e tipo '1' ou '2'
					@ li, 000 PSAY AllTrim(CT2->CT2_LINHA)
					@ li, 004 PSAY AllTrim(CT2->CT2_DC)
					If mv_par08 == 2
						dbSelectArea("CT1")
						If CT2->CT2_DC == '1'
							dbSeek(xFilial()+CT2->CT2_DEBITO)
							@ li, 006 PSAY AllTrim(CT1->CT1_RES)
						ElseIf CT2->CT2_DC == '2'												
							dbSeek(xFilial()+CT2->CT2_CREDIT)
							@ li, 006 PSAY AllTrim(CT1->CT1_RES)
						Endif
						dbSelectArea("CT2")				
					Else
						If CT2->CT2_DC == '1'
							@ li, 006 PSAY AllTrim(CT2->CT2_DEBITO)
						ElseIf CT2->CT2_DC == '2'					
							@ li, 006 PSAY AllTrim(CT2->CT2_CREDIT)
						Endif
					Endif			

					dbSelectArea("CT1")
					DbSetOrder(1)
					If !Empty(CT2->CT2_DEBITO)
						dbSeek(xFilial() + AllTrim(CT2->CT2_DEBITO))
					Else
						dbSeek(xFilial() + AllTrim(CT2->CT2_CREDIT))
					EndIf

					// IMPRIME A DESCRIÇÃO
					@ li,015 PSAY AllTrim(Substr(CT1->CT1_DESC01,1,30))
	  	
					nValor := &('CT2->CT2_VLR'+cMoeda)
					If CT2->CT2_DC == '1'
						If lCusto
							@ li,aColunas[CENTRO_CUSTO] PSAY Ctr070CTT(CT2->CT2_CCD)
						Endif
						If lItem
							@ li,aColunas[ITEM_CONTABIL] PSAY Ctr070CTD(CT2->CT2_ITEMD)
						Endif   
						If lCv
							@ li,aColunas[CLASSE_VALOR] PSAY Ctr070CTH(CT2->CT2_CLVLDB)
						Endif						
						@ li,aColunas[VALOR_DEBITO] PSAY nValor Picture Tm(nValor,17)
						nTotalDeb += nValor
						nTotGerDeb+= nValor
						nTotLotDeb+= nValor						
					ElseIf CT2->CT2_DC =='2'
					
						If lCusto
							@ li,aColunas[CENTRO_CUSTO] PSAY Ctr070CTT(CT2->CT2_CCC)
						Endif
						If lItem
							@ li,aColunas[ITEM_CONTABIL] PSAY Ctr070CTD(CT2->CT2_ITEMC)
						Endif   
						If lCv
							@ li,aColunas[CLASSE_VALOR] PSAY Ctr070CTH(CT2->CT2_CLVLCR)
						Endif						
						@ li,aColunas[VALOR_CREDITO] PSAY nValor Picture Tm(nValor,17)
						nTotalCrd += nValor
						nTotGerCrd+= nValor
						nTotLotCrd+= nValor
					Endif	
					@ li, aColunas[CODIGO_HP] PSAY CT2->CT2_HP
					@ li, aColunas[HISTORICO] PSAY CT2->CT2_HIST                       
									
				Elseif CT2->CT2_DC == '3' //Se o lancamento e tipo '3', e desdobrado
					For n:=1 to 2
					   @ li, 000 PSAY CT2->CT2_LINHA
					   If n == 1
							@ li, 004 PSAY '1'
						Else
						           
							@ li, 004 PSAY '2'
						Endif						
						If mv_par08 == 2
							dbSelectArea("CT1")
							If n==1
								dbSeek(xFilial()+CT2->CT2_DEBITO)
								@ li, 006 PSAY CT1->CT1_RES
							Else
								dbSeek(xFilial()+CT2->CT2_CREDIT)				
								@ li, 006 PSAY CT1->CT1_RES
							Endif
							dbSelectArea("CT2")				
						Else                             
							If n==1
								@ li, 006 PSAY CT2->CT2_DEBITO
							Else
								@ li, 006 PSAY CT2->CT2_CREDIT
							Endif
						Endif			
	  		
						nValor := &('CT2->CT2_VLR'+cMoeda)                 
						If n == 1
							If lCusto
								@ li,aColunas[CENTRO_CUSTO] PSAY Ctr070CTT(CT2->CT2_CCD)
							Endif
							If lItem
								@ li,aColunas[ITEM_CONTABIL] PSAY Ctr070CTD(CT2->CT2_ITEMD)
							Endif   
							If lCv
								@ li,aColunas[CLASSE_VALOR] PSAY Ctr070CTH(CT2->CT2_CLVLDB)
							Endif						
							@ li,aColunas[VALOR_DEBITO] PSAY nValor Picture Tm(nValor,17)
							nTotalDeb += nValor
							nTotGerDeb+= nValor
							nTotLotDeb+= nValor
						Else
							If lCusto
								@ li,aColunas[CENTRO_CUSTO] PSAY Ctr070CTT(CT2->CT2_CCC)
							Endif
							If lItem
								@ li,aColunas[ITEM_CONTABIL] PSAY Ctr070CTD(CT2->CT2_ITEMC)
							Endif   
							If lCv
								@ li,aColunas[CLASSE_VALOR] PSAY Ctr070CTH(CT2->CT2_CLVLCR)
							Endif						
							@ li,aColunas[VALOR_CREDITO] PSAY nValor Picture Tm(nValor,17)						
							nTotalCrd += nValor
							nTotGerCrd+= nValor
							nTotLotCrd+= nValor
						Endif
						@ li, aColunas[CODIGO_HP]	PSAY CT2->CT2_HP
						@ li,aColunas[HISTORICO] 	PSAY CT2->CT2_HIST
						
						If n == 1 .And. mv_par21 == 1
							cSeq := CT2->CT2_SEQLAN
							nReg := Recno()
							dbSelectArea("CT2")
							dbSetOrder(10)
							If dbSeek(xFilial()+DTOS(dData)+cLote+cSubLote+cDoc+cSeq)
								dbSkip()
								If CT2->CT2_DC == "4"
								    li++
									While !Eof() .And. CT2->CT2_FILIAL == xFilial() .And.;
										CT2->CT2_LOTE == cLote .And. CT2->CT2_DOC == cDoc .And.;
										CT2->CT2_SEQLAN == cSeq .And. CT2->CT2_DC == "4" .And.;
										DTOS(CT2->CT2_DATA) == DTOS(dData)
										
										If !lCusto .And. !lItem .And. !lCV
											@ li, 000 PSAY CT2->CT2_LINHA
											@ li, 004 PSAY CT2->CT2_DC
											@ li, 097 PSAY CT2->CT2_HIST
										Else
											@ li, 000 PSAY CT2->CT2_LINHA
											@ li, 004 PSAY CT2->CT2_DC
											@ li, aColunas[HISTORICO] PSAY CT2->CT2_HIST                       
										EndIf													
										dbSkip() 
										li++
									EndDo	
								EndIf				
								dbGoto(nReg)
								dbSetOrder(1)
							EndIf
						ElseIf n == 1
							li++
						Endif
					  Next
				Endif		   
			EndIf			
			
			// Procura pelo complemento de historico        
			cSeq := CT2->CT2_SEQLAN
			nReg := Recno()
			dbSelectArea("CT2")
			dbSetOrder(10)
			If dbSeek(xFilial()+DTOS(dData)+cLote+cSubLote+cDoc+cSeq)
				dbSkip()
				If CT2->CT2_DC == "4"
					While !Eof() .And. CT2->CT2_FILIAL == xFilial() .And.;
						CT2->CT2_LOTE == cLote .And. CT2->CT2_DOC == cDoc .And.;
						CT2->CT2_SEQLAN == cSeq .And. CT2->CT2_DC == "4" .And.;
						DTOS(CT2->CT2_DATA) == DTOS(dData)
						li++
						If !lCusto .And. !lItem .And. !lCV
							@ li, 000 PSAY CT2->CT2_LINHA
							@ li, 004 PSAY CT2->CT2_DC
							@ li, 097 PSAY CT2->CT2_HIST
						Else
							@ li, 000 PSAY CT2->CT2_LINHA
							@ li, 004 PSAY CT2->CT2_DC
							@ li, aColunas[HISTORICO] PSAY CT2->CT2_HIST                       
						EndIf													
						dbSkip()
					EndDo	
				EndIf				
			Else         
				dbGoto(nReg)
				dbSetOrder(1)
				dbSkip()			
			EndIf 
			
			dbSetOrder(1)
			li++
		Else						// Armazena valores para impressa resumida
			cLoteRes 	:= CT2->CT2_LOTE
			cSubRes		:= CT2->CT2_SBLOTE
			cDocRes		:= CT2->CT2_DOC
			dDataRes	:= CT2->CT2_DATA
			If CT2->CT2_DC == "1" .Or. CT2->CT2_DC == "3"
				nValor := &('CT2->CT2_VLR'+cMoeda)       
				nTotalDeb += nValor
				nTotGerDeb+= nValor
				nTotLotDeb+= nValor
			EndIf
			If CT2->CT2_DC == "2" .Or. CT2->CT2_DC == "3"
				nValor := &('CT2->CT2_VLR'+cMoeda)       
				nTotalCrd += nValor
				nTotGerCrd+= nValor			
				nTotLotCrd+= nValor
			EndIf	
			dbSkip()
		EndIf
	EndDO

	If lTotal .And. !lResumo			// Relatorio Completo
		li++
		@ li,02 PSAY Iif (cPaisLoc<>"MEX" ,OemToAnsi(STR0018),OemToAnsi(STR0038))
		CTC->(MsSeek(xFilial()+dtos(dData)+cLote+cSubLote+cDoc+"01"))
		nTotGerInf += CTC->CTC_INF
		nTotGerDig += CTC->CTC_DIG
		If !lCusto .And. !lItem  .And. !lCV                     
			@ li, 049 		PSAY nTotalDeb Picture Tm(nTotalDeb,17)
			@ li, 070 		PSAY nTotalCrd Picture Tm(nTotalCrd,17)
		Else
			@ li, aColunas[VALOR_DEBITO] 	PSAY nTotalDeb Picture Tm(nTotalDeb,17)
			@ li, aColunas[VALOR_CREDITO] 	PSAY nTotalCrd Picture Tm(nTotalCrd,17)
		Endif
		
		If limite = 132
			nCol := If(Len(aColunas) > 0, aColunas[HISTORICO], 097)
			@ li ++, nCol	PSAY STR0025 + 	Trans(CTC->CTC_INF, Tm(CTC->CTC_INF,17)) //"INFORMADO"
			@ li   , nCol	PSAY STR0026 + 	Trans(CTC->CTC_DIG, Tm(CTC->CTC_DIG,17)) //"DIGITADO "
			If Round(NoRound(CTC->CTC_DIG - CTC->CTC_INF, 2), 2) # 0
				li ++
				@ li,nCol PSAY STR0027 + Trans(Abs(CTC->CTC_DIG - CTC->CTC_INF),; //"DIFERENCA"
						   					 Tm(CTC->CTC_DIG,17))
			Endif
		Else
			@ li, aColunas[HISTORICO] 		PSAY STR0028 + Trans(CTC->CTC_INF,; //"INFORMADO "
																Tm(CTC->CTC_INF,17)) +;
			 								     Space(4) + STR0026 +; //"DIGITADO "
			 								     Trans(CTC->CTC_DIG, Tm(CTC->CTC_DIG,17)) +;
			 								     Space(4) + STR0027 +; //"DIFERENCA"
												 Trans(	Abs(CTC->CTC_DIG-CTC->CTC_INF),;
												 Tm(CTC->CTC_DIG,17))
		Endif
		li++
		nTotalDeb := 0	
		nTotalCrd := 0	
		
		// TOTALIZA O LOTE
		If cLote != CT2->CT2_LOTE 				.Or.;
		   cSubLote != CT2->CT2_SBLOTE 			.Or.;
		   Dtos(dData) != Dtos(CT2->CT2_DATA)
			li++
			@ li,02 PSAY OemToAnsi(STR0020)
			CT6->(MsSeek(xFilial()+dtos(dData)+cLote+cSubLote+"01"))
			If !lCusto .And. !lItem  .And. !lCV                     
				@ li, 049 PSAY nTotLotDeb Picture Tm(nTotLotDeb,17)
				@ li, 070 PSAY nTotLotCrd Picture Tm(nTotLotCrd,17)
			Else
				@ li, aColunas[VALOR_DEBITO] 	PSAY nTotLotDeb Picture Tm(nTotLotDeb,17)
				@ li, aColunas[VALOR_CREDITO] 	PSAY nTotLotCrd Picture Tm(nTotLotCrd,17)
			Endif
			If limite = 132
				nCol := If(Len(aColunas) > 0, aColunas[HISTORICO], 097)
				@ li ++, nCol PSAY STR0025 + 	Trans(CT6->CT6_INF,; //"INFORMADO"
													Tm(CT6->CT6_INF,17))
				@ li   , nCol PSAY STR0026 + 	Trans(CT6->CT6_DIG,; //"DIGITADO "
													Tm(CT6->CT6_DIG,17))
				If Round(NoRound(CT6->CT6_DIG - CT6->CT6_INF, 2), 2) # 0
					li ++
					@ li,nCol PSAY STR0027 + 	Trans(Abs(CT6->CT6_DIG -; //"DIFERENCA"
													CT6->CT6_INF), Tm(CT6->CT6_DIG,17))
				Endif
			Else
				@ li, aColunas[HISTORICO] 		PSAY STR0028 + Trans(CT6->CT6_INF,; //"INFORMADO "
																	Tm(CT6->CT6_INF,17)) +;
			 								     Space(4) + STR0026 +; //"DIGITADO "
			 								     Trans(CT6->CT6_DIG, Tm(CT6->CT6_DIG,17)) +;
			 								     Space(4) + STR0027 +;  //"DIFERENCA"
												 Trans(	Abs(CT6->CT6_DIG-CT6->CT6_INF),;
												 Tm(CT6->CT6_DIG,17))
			Endif
			li++
			nTotLotDeb := 0	
			nTotLotCrd := 0	
        EndIf
	ElseiF lResumo       			// Relatorio Resumido
		IF li > 62
			Cabec( Titulo, Cabec1, Cabec2, NomeProg, Tamanho,;
					Iif(aReturn[4] == 1, GetMv("MV_COMP"), GetMv("MV_NORM")))
		EndIf
		nDif := Round(NoRound(nTotalDeb - nTotalCrd, 2), 2)
		CTC->(MsSeek(xFilial()+dtos(dDataRes)+cLoteRes+cSubRes+cDocRes+"01"))

		@ li,000 PSAY DTOC(dDataRes)
		@ li,014 PSAY cLoteRes
		@ li,028 PSAY cSubRes
		@ li,038 PSAY cDocRes
		@ li,048 PSAY CTC->CTC_INF 	Picture Tm(CTC->CTC_INF,17)		
		@ li,069 PSAY nTotalDeb 	Picture Tm(nTotalDeb,17)		
		@ li,090 PSAY nTotalCrd 	Picture Tm(nTotalCrd,17)    
		@ li,110 PSAY Abs(nDif)		Picture Tm(Abs(nDif),17)
		If nDif > 0
			@ li,131 PSAY Iif (cPaisLoc<>"MEX" ,OemToAnsi(STR0023),OemToAnsi(STR0036) )  		// "DIF A DEBITO"
		ElseIf nDif < 0
			@ li,131 PSAY Iif (cPaisLoc<>"MEX" ,OemToAnsi(STR0024),OemToAnsi(STR0037) )		// "DIF A CREDITO"
		EndIf			
		@ li,148 PSAY CTC->CTC_DIG 	Picture Tm(CTC->CTC_DIG,17)		
		nTotGerDig += CTC->CTC_DIG
		nTotGerInf += CTC->CTC_INF

		nDif := Round(NoRound(CTC->CTC_DIG - CTC->CTC_INF, 2), 2)
		@ li,169 PSAY Abs(nDif)		Picture Tm(nDif,17)		
		li++
		nTotalDeb 	:= 0	
		nTotalCrd 	:= 0			
	Endif
	
	// Impressao do Cabecalho
	If mv_par12 == 1			// Quebra pagina quando for lote diferente
		If cLote != CT2->CT2_LOTE 				.Or.;
		   cSubLote != CT2->CT2_SBLOTE 			.Or.;
		   Dtos(dData) != Dtos(CT2->CT2_DATA)   .And. Ctr070Skip()
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
		IF li > 62 
			Cabec( Titulo, Cabec1, Cabec2, NomeProg, Tamanho,;
					Iif(aReturn[4] == 1, GetMv("MV_COMP"), GetMv("MV_NORM")))
		EndIf		
		li+=2
		@ li,00 PSAY Replicate("-",Limite)
		li++
		@ li,02 PSAY OemToAnsi(STR0019)
		If !lResumo
			If !lCusto .And. !lItem  .And. !lCV                     
				@ li, 049 PSAY nTotGerDeb Picture Tm(nTotGerDeb,17)
				@ li, 070 PSAY nTotGerCrd Picture Tm(nTotGerCrd,17)
			Else
				@ li, aColunas[VALOR_DEBITO] 	PSAY nTotGerDeb Picture Tm(nTotGerDeb,17)
				@ li, aColunas[VALOR_CREDITO] 	PSAY nTotGerCrd Picture Tm(nTotGerCrd,17)
			Endif
			If limite = 132
				nCol := If(Len(aColunas) > 0, aColunas[HISTORICO], 097)
				@ li ++, nCol  	PSAY STR0025 + 	Trans(nTotGerInf, Tm(nTotGerInf,17)) //"INFORMADO"
				@ li   , nCol	PSAY STR0026 + 	Trans(nTotGerDig, Tm(nTotGerDig,17)) //"DIGITADO "
				If Round(NoRound(nTotGerDig - nTotGerInf, 2), 2) # 0
					li ++
					@ li,nCol	PSAY STR0027 + 	Trans(Abs(nTotGerDig - nTotGerInf),; //"DIFERENCA"
													Tm(nTotGerDig,17))
				Endif
			Else
				@ li, aColunas[HISTORICO] 		PSAY STR0028 + Trans(nTotGerInf,; //"INFORMADO "
																	Tm(nTotGerInf,17)) +;
			 								     Space(4) + STR0026 +; //"DIGITADO "
			 								     Trans(nTotGerDig, Tm(nTotGerDig,17)) +;
			 								     Space(4) + STR0027 +;  //"DIFERENCA"
												 Trans(	Abs(nTotGerDig-nTotGerInf),;
												 Tm(nTotGerDig,17))
			Endif
		Else
			nDif := nTotGerDeb - nTotGerCrd

			@ li,048 PSAY nTotGerInf 	Picture Tm(nTotGerInf,17)		
			@ li,069 PSAY nTotGerDeb 	Picture Tm(nTotGerDeb,17)		
			@ li,090 PSAY nTotGerCrd 	Picture Tm(nTotGerCrd,17)    
			@ li,110 PSAY Abs(nDif)		Picture Tm(Abs(nDif),17)
			@ li,148 PSAY nTotGerDig 	Picture Tm(nTotGerDig,17)		

			nDif := Round(NoRound(nTotGerDig - nTotGerInf, 2), 2)
			@ li,169 PSAY Abs(nDif)		Picture Tm(nDif,17)		
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

MS_FLUSH()

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³Ctr070Skip³ Autor ³ Pilar S Albaladejo	³ Data ³ 02.04.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Verifica condicoes para pular os registros			      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ Ctr070Skip()    											  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ Nenhum       											  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ Generico      											  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Ctr070Skip()

Local lRet := .F.

If mv_par11 <> CT2->CT2_TPSALD
	lRet := .T.
Endif
	   
If (CT2->CT2_LOTE < mv_par03) .Or. (CT2->CT2_LOTE > mv_par04)
	lRet := .T.
Endif
	
If (CT2->CT2_SBLOTE < mv_par15) .Or. (CT2->CT2_SBLOTE > mv_par16)
	lRet := .T.
Endif
	
If (CT2->CT2_DOC < mv_par05) .Or. (CT2->CT2_DOC > mv_par06)
	lRet := .T.
Endif
     
If cPaisLoc == "CHI" .And. (CT2->CT2_SEGOFI < mv_par22 .Or. CT2->CT2_SEGOFI > mv_par23)
	lRet := .T.
EndIf	        

Return(lRet)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³Ctr070Ctt ³ Autor ³ Wagner Mobile Costa   ³ Data ³ 17.02.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Faz a troca para impressao de codigo reduzido de acordo com ³±±
±±³          ³mv_par15 = 2                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³Ctr070Ctt(cCC)                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³cCC = Conteudo a Ser impresso                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Ctbr070                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cCc = Centro de custo a ser substituido (se for o caso)    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Ctr070Ctt(cCc)

Local aSaveArea := GetArea()

If mv_par18 = 2
	dbSelectArea("CTT")
	dbSetOrder(1)		
	MsSeek(xFilial() + cCC)
	cCC := CTT->CTT_RES
Endif

RestArea(aSaveArea)
Return(cCC)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³Ctr070Ctd ³ Autor ³ Wagner Mobile Costa   ³ Data ³ 17.02.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Faz a troca para impressao de codigo reduzido de acordo com ³±±
±±³          ³mv_par16 = 2                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³Ctr070Ctd(cItem)                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³cItem = Conteudo a Ser impresso                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Ctbr070                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cItem = Item a ser substituido (se for o caso)    	      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Ctr070Ctd(cItem)

Local aSaveArea := GetArea()

If mv_par19 = 2
	dbSelectArea("CTD")
	dbSetOrder(1)
	MsSeek(xFilial() + cItem)
	cItem := CTD->CTD_RES
Endif

RestArea(aSaveArea)
Return(cItem)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³Ctr070Cth ³ Autor ³ Wagner Mobile Costa   ³ Data ³ 17.02.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Faz a troca para impressao de codigo reduzido de acordo com ³±±
±±³          ³mv_par17 = 2                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³Ctr070Cth(cClVl)                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³cItem = Conteudo a Ser impresso                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Ctbr070                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cClVl = Classe de valor a ser substituida (se for o caso)  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Ctr070Cth(cClVl)

Local aSaveArea := GetArea()

If mv_par20 = 2
	dbSelectArea("CTH")
	dbSetOrder(1)
	MsSeek(xFilial() + cCLVL)
	cCLVL := CTH->CTH_RES
Endif

RestArea(aSaveArea)
Return(cCLVL)
                     
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ AjustaSX1    ³Autor ³  Gilson Silva        ³Data³ 17/09/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Ajusta perguntas do SX1                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function AjustaSX1(cPerg)
/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³ATENCAO                                                                ³
  ³Caso haja a necessidade de adicao de novos parametros entrar em contato³
  ³com o departamento de Localizacoes.          						  ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
Local aArea := GetArea()

PutSx1(cPerg, "22","Do Correlativo ?","¿De Correlativo ?","From Correlative?","mv_chm","C",10,0,0,;
		"G",""," ","","","MV_PAR22"," "," "," ","",	" "," "," "," "," "," ", " "," "," "," ",;
		" "," ",,,)

PutSx1(cPerg, "23","Ate Correlativo ?","¿Hasta Correlativo ?","To Correlative?","mv_chn","C",10,0,0,;
		"G","","","","","MV_PAR23"," "," "," ","",	" "," "," "," "," "," ", " "," "," "," ",;
		" "," ",,,)

RestArea(aArea)

Return

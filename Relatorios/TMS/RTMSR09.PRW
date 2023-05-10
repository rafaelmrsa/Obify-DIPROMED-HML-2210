#INCLUDE "protheus.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ RTMSR09  ³ Autor ³ Antonio C Ferreira    ³ Data ³24.06.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Impressao do Romaneio de Entrega                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ RTMSR09                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Gestao de Transporte                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³        ³      ³                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function RTMSR09()

Local titulo   := "Relacao de Coletas" //"Relacao de Coletas"
Local cString  := "DTQ"
Local wnrel    := "RTMSR09"
Local cDesc1   := "Este programa ira listar os Mapas de Coleta" //"Este programa ira listar os Mapas de Coleta"
Local cDesc2   := ""
Local cDesc3   := ""
Local tamanho  := "G"

Private NomeProg := "RTMSR09"
Private aReturn  := {"Zebrado",1,"Administracao",1, 2, 1, "",1 } //"Zebrado"###"Administracao"
Private cPerg    := "RTMR09"
Private nLastKey := 0

U_DIPPROC(ProcName(0),U_DipUsr()) //MCVN - 22/01/2009

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica as perguntas                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros                         ³
//³ mv_par01        	// Viagem Inicial	                     ³
//³ mv_par02        	// Viagem Final       	                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

//Chamada do relatorio padrao
If FindFunction("TRepInUse") .And. TRepInUse()
	TMSR560()
	Return
EndIf


DbSelectArea("SX1")
DbSetOrder(1)
cPerg := PADR(cPerg, Len(SX1->X1_GRUPO), " " ) // Incluido por Sandro em 17/11/09.


pergunte(cPerg,.F.)

wnrel:=SetPrint(cString,wnrel,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,"",,Tamanho)

If nLastKey = 27
	Set Filter To
	Return
Endif

SetDefault(aReturn,cString)

If nLastKey = 27
	Set Filter To
	Return
Endif

RptStatus({|lEnd| RTMSR09Imp(@lEnd,wnRel,titulo,tamanho)},titulo)

Return NIL

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³RTMSR09Imp³ Autor ³ Antonio C Ferreira    ³ Data ³24.06.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Chamada do Relat¢rio                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ RTMSR09			                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³        ³                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function RTMSR09Imp(lEnd,wnRel,titulo,tamanho)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local cDesc1, cDesc2
Local nTotPed:=nTotPeso:=nTotVol:=0
Local nCountVei:=nCountMot:=nCountAju:=0
Local cString := ""
//Local nBegin := 0
Local nTamMaxCol := 180
Local lImp := .F.
Local cViagem := ""
Local acabec := {}
//Local cabec1
Local nA     := 0
Local nX     := 0
// "FIL.ORIG.  SOLICIT.   CLIENTE                                   ENDERECO                                  BAIRRO                           VOLS.   PESO       OBSERVACAO "
//  xx         xxxxxx     xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx  xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx  xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx  123456  123456789   xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
//  01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
//  0         1         2         3         4         5         6         7         8         9        10        11        12        13        14        15        16        17        18        19        20        21        22
//Local cabec2:= ""
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define variaveis utilizadas para Impressao do cabecalho e rodape.     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private cbtxt  := Space(10)
Private cbcont := 0
Private m_pag  := 1
Private Li:=80
Private nTipo  := aReturn[4]
Private aNfcli := {}
Private aObsEnt:= {}
//Giovani Zago 12/01/2012
Private cCodEmp  := ""
Private	QURY1     := ""
Private	cNomDes  := ""
Private	cEndDes  := ""
Private	cCEPDes  := ""
Private	cMunDes  := ""
Private	cEstDes  := ""
Private	cBairroE := ""
Private	cCGCDes  := ""

//********************************************






Inclui := .F.
SM0->(dbSeek(cEmpAnt+cFilAnt, .T.))


//-- Viagens
DTQ->(dbSetOrder(1))

//-- Rotas
DA8->(dbSetOrder(1))

//-- Clientes
SA1->(dbSetOrder(1))

//-- Nota Fiscal Cliente
DTC->(dbSetOrder(3))

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Alimenta Arquivo de Trabalho                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("DUD")
dbSetOrder(2)   // DUD_FILIAL+DUD_FILORI+DUD_VIAGEM+DUD_FILDOC+DUD_DOC+DUD_SERIE

dbSeek(xFilial("DUD") + cFilAnt + mv_par01, .T.)

SetRegua(LastRec())

Do While !Eof() .And. (DUD_FILIAL == xFilial("DUD")) .And. (DUD_FILORI == cFilAnt) .And. (DUD_VIAGEM <= mv_par02)
	
	cViagem := DUD_VIAGEM
	
	// DOCUMENTOS DE TRANSPORTE
	DT6->( MsSeek(xFilial("DT6") + DUD->(DUD_FILDOC + DUD_DOC + DUD_SERIE)) )
	
	If Empty(cViagem) .Or. !(DT6->DT6_DOCTMS $ "25")  // Somente 2-CTRC e 5-Nota Fiscal.
		IncRegua()
		If Interrupcao(@lEnd)
			Exit
		Endif
		
		dbSkip()
		Loop
	EndIf
	
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta o array acabec (Informacoes iniciais do cabecalho)              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nCountVei:=nCountMot:=nCountAju:=0
	
	RTMSR09Cabec(@nCountVei,@nCountMot,@nCountAju,@acabec, cViagem, nTamMaxCol)
	
	cDesc1 := "Viagem: " + cFilAnt + " " + cViagem  +"          "+" + Rota: " + AllTrim(DA8->DA8_COD) + " - " + AllTrim(DA8->DA8_DESC)  //// Viagem: ## ######    + Rota: ### - #######
	cDesc2 := ""
	nTotPed:=nTotPeso:=nTotVol:=0
	li   := 80
	nCol := 0
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Imprime o cabecalho                                                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Do While !DUD->(Eof()) .And. DUD->DUD_FILIAL == xFilial("DUD") .And. DUD->DUD_FILORI == cFilAnt .And.;
		DUD->DUD_VIAGEM == cViagem
		
		IncRegua()
		If Interrupcao(@lEnd)
			Exit
		Endif
		
		// DOCUMENTOS DE TRANSPORTE
		DT6->( MsSeek(xFilial("DT6") + DUD->(DUD_FILDOC + DUD_DOC + DUD_SERIE)) )
		
		If !(DT6->DT6_DOCTMS $ "25")  // Somente 2-CTRC e 5-Nota Fiscal.
			dbSkip()
			Loop
		EndIf
		
		If Li > 60
			Cabec(Titulo, cDesc1, cDesc2, NomeProg, Tamanho)
			For nA := 1 to len(aCabec)
				@ Li++, 0 PSay aCabec[nA,1]
			Next
			++Li
			@Li,000 PSay __PrtThinLine()
			++Li
			@Li,000 PSay "Fil Documento   Cliente                                                  Endereco                                   Bairro              Cidade             Vols.         Peso      Nota Fiscal       Valor Doc.   "
			++Li
			@Li,000 PSay __PrtThinLine()
			Li += 2
		EndIf
		
		//-- Viagens
		DTQ->(dbSeek(xFilial("DTQ")+cViagem))
		
		//-- Rotas
		DA8->(dbSeek(xFilial("DA8")+DTQ->DTQ_ROTA))
		
		//-- Nota Fiscal Cliente
		DTC->(MsSeek(xFilial("DTC")+DT6->DT6_FILDOC+DT6->DT6_DOC+DT6->DT6_SERIE))
		
		//-- Clientes
		SA1->(dbSeek(xFilial("SA1")+DTC->( DTC_CLIDES + DTC_LOJDES )))
		
		//Giovani Zago 12/01/2012
		cCodEmp := U_fTmsCodEmp(DT6->DT6_CLIREM + DT6->DT6_LOJREM)  // Retorna emprea e filial  
		
			//-- Clientes
		SA1->(dbSeek(xFilial("SA1")+DTC->( DTC_CLIDES + DTC_LOJDES )))  
		
		If cCodEmp <> ""
			
			QURY1 := " SELECT C5_ENDENT, C5_MUNE, C5_CEPE, C5_ESTE, C5_BAIRROE"
			QURY1 += "   FROM SC5" + SubStr(cCodEmp,1,3) + " SC5, SD2" + SubStr(cCodEmp,1,3) + " SD2, " + RetSqlName('DTC') + " DTC "
			QURY1 += "  WHERE DTC_NUMNFC     = '" + DTC->DTC_NUMNFC + "' " // Nota Fiscal Original do CTRC
			QURY1 += "    AND DTC_SERNFC     = '" + DTC->DTC_SERNFC + "' " // Serie da Mesma
			QURY1 += "    AND DTC_FILIAL     = '" + xFilial('DTC')  + "' " // Filial Corrente da Empresa Corrente
			QURY1 += "    AND D2_FILIAL      = '"+SubStr(cCodEmp,4,2)+"' " // Filial do Pedido Originario da Nota que Originou o CTRC
			QURY1 += "    AND D2_DOC         = DTC_NUMNFC "                 //
			QURY1 += "    AND D2_SERIE       = DTC_SERNFC"                  //
			QURY1 += "    AND C5_FILIAL      = D2_FILIAL "                  //
			QURY1 += "    AND C5_NUM         = D2_PEDIDO "                  //
			QURY1 += "    AND D2_ITEM        = '01'"                        //
			QURY1 += "    AND SC5.D_E_L_E_T_ = ''"                          //
			QURY1 += "    AND SD2.D_E_L_E_T_ = ''"                          //
			QURY1 += "    AND DTC.D_E_L_E_T_ = ''"                          //
			QURY1 += "  ORDER BY C5_NUM "                                   //
			
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,QURY1),'QURY1',.T.,.F.)      
			
			DbSelectArea("QURY1")
			QURY1->(dbGotop())
			
			
			
			cEndDes  := QURY1->C5_ENDENT
			//cCEPDes  := QURY1->C5_CEPE
			cMunDes  := QURY1->C5_MUNE
			//cEstDes  := QURY1->C5_ESTE
			cBairroE := QURY1->C5_BAIRROE
			QURY1->(DbCloseArea())
			
			
			@Li,000 PSAY DUD->DUD_FILDOC           	Picture "99"
			@Li,003 PSAY DUD->DUD_DOC+"/"+DUD->DUD_SERIE
			@Li,017 PSay Left(SA1->A1_NOME,54) 		Picture PesqPict("SA1","A1_NOME")
			@Li,073 PSay lEFT(cEndDes,40)	   	    Picture PesqPict("SA1","A1_END")
			@Li,116 PSay cBairroE           		Picture PesqPict("SA1","A1_BAIRRO")
			@Li,136 PSay cMunDes        		    Picture PesqPict("SA1","A1_MUN")
			@Li,154 PSay DT6->DT6_QTDVOL     		Picture PesqPict("DT6","DT6_QTDVOL")
			@Li,164 PSay DT6->DT6_PESO       		Picture PesqPict("DT6","DT6_PESO")
			@Li,180 PSay "________:________ ________:________"
			++LI 
			
		Else
			
			@Li,000 PSAY DUD->DUD_FILDOC           	Picture "99"
			@Li,003 PSAY DUD->DUD_DOC+"/"+DUD->DUD_SERIE
			@Li,017 PSay Left(SA1->A1_NOME,54) 		Picture PesqPict("SA1","A1_NOME")
			@Li,073 PSay lEFT(SA1->A1_END,40)	   	Picture PesqPict("SA1","A1_END")
			@Li,116 PSay SA1->A1_BAIRRO      		Picture PesqPict("SA1","A1_BAIRRO")
			@Li,136 PSay SA1->A1_MUN        		Picture PesqPict("SA1","A1_MUN")
			@Li,154 PSay DT6->DT6_QTDVOL     		Picture PesqPict("DT6","DT6_QTDVOL")
			@Li,164 PSay DT6->DT6_PESO       		Picture PesqPict("DT6","DT6_PESO")
			@Li,180 PSay "________:________ ________:________"
			++LI
			
			
		EndIf
		// Busca NF do cliente pelo CTRC
		FindNFCli()
		aObsEnt := {}
		
		If Len(aNfcli) = 1
			@Li,000 PSAY "Nota Fiscal:  "
			nCol := 17
			@Li,nCol PSAY aNfcli[1,1]+"  "+aNfcli[1,2]
			
		ElseIf Len(aNfcli) > 1
			nCol := 17
			For nY := 1 to Len(aNfcli)
				
				If nY == 1
					AAdd(aObsEnt, {aNfcli[nY,1],aNfcli[nY,2]})
				ElseIf !(aScan(aObsEnt, { |x| x[2] == aNfcli[nY,2]}) > 0)
					AAdd(aObsEnt, {aNfcli[nY,1],aNfcli[nY,2]})
				ElseIf aScan(aObsEnt, { |x| x[2] == aNfcli[nY,2]}) > 0
					aObsEnt[aScan(aObsEnt, { |x| x[2] == aNfcli[nY,2] }),1]  := aObsEnt[aScan(aObsEnt, { |x| x[2] == aNfcli[nY,2] }),1]+"  "+aNfcli[nY,1]
				Endif
				
			Next nY
			
			// Imprimindo observação de entrega
			For x := 1 to Len(aObsEnt)
				
				If Len(aObsEnt) = 1
					@Li,000 PSAY "Notas Fiscais:  "
					nCol := 17
					@Li,nCol PSAY aObsEnt[1,1] 	+"  "+aObsEnt[1,2]
				ElseIf Len(aObsEnt) > 1
					@Li,000 PSAY "Notas Fiscais:  "
					@Li,nCol PSAY aObsEnt[x,1]+"  "+aObsEnt[x,2]
					If X<Len(aObsEnt)
						++LI// MCVN - 14/01/2009
					Endif
				Endif
				
			Next x
		Endif
		
		++LI// MCVN - 14/01/2009
		++LI// MCVN - 03/02/2009
		nTotPed ++
		
		//-- Totalizadores
		nTotVol   += DT6->DT6_QTDVOL
		nTotPeso  += DT6->DT6_PESO
		lImp := .T.
		
		dbSelectArea("DUD")
		dbSkip()
	EndDo
	
	If lEnd
		Exit
	EndIf
	
	If lImp
		Li+=1
		@Li,000 PSay __PrtThinLine()
		Li+=2
		@Li,000 PSay "Totais -> " //"TOTAIS -> "
		@Li,013 PSay "PEDIDOS : " + AllTrim(STR(nTotPed)) //"PEDIDOS : "
		//		@Li,140 PSay STR0008 + TransForm(nTotPeso ,PesqPict("DT6","DT6_PESO"))  //"PESO : "
		//		@Li,165 PSay STR0009 + TransForm(nTotVol  ,PesqPict("DT6","DT6_QTDVOL")) //"VOLUME : "
		@Li,153 PSay TransForm(nTotVol  ,PesqPict("DT6","DT6_QTDVOL")) //"VOLUME    MCVN - 05/01/2009
		@Li,164 PSay TransForm(nTotPeso ,PesqPict("DT6","DT6_PESO"))  //"PESO : "   MCVN - 05/01/2009
		
		Li+=2
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Imprime o cabecalho                                                   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If Li > 60
			Cabec(Titulo, cDesc1, cDesc2, NomeProg, Tamanho)
		EndIf
		
		nCol:=0
		Li++
		/*
		For nX:=1 to nCountMot+1
		ImpLin(Li,@nCol,nTamMaxCol)
		Next
		
		nCol:=0
		Li++
		For nX:=1 to Len(aCabec)
		If aCabec[nX,2] == "2"
		cString := Right(aCabec[nX,1],Len(DA4->DA4_NREDUZ)+2)  //STR0011 //" Assinatura Motorista "
		ImpAss(@Li,@nCol,cString,nX,nCountMot,nTamMaxCol,.F.)
		EndIf
		Next
		
		nCol:=0
		Li+=3
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Imprime o cabecalho                                                   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If Li > 55
		Cabec(Titulo, cDesc1, cDesc2, NomeProg, Tamanho)
		EndIf
		
		Li++
		For nX:=1 to nCountAju +1
		ImpLin(Li,@nCol,nTamMaxCol)
		Next
		
		nCol:=0
		Li++
		
		For nX:=1 to Len(aCabec)
		If aCabec[nX,2] == "3"
		cString := Right(aCabec[nX,1],Len(DAU->DAU_NREDUZ)+2) // STR0012 //" Assinatura Ajudante  "
		ImpAss(@Li,@nCol,cString,nX,nCountMot,nTamMaxCol,.F.)
		EndIf
		Next
		
		*/
	EndIf
	
EndDo

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se em disco, desvia para Spool                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If aReturn[5] == 1
	Set Printer To
	dbCommitAll()
	OurSpool(wnrel)
Endif

MS_FLUSH()

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³RTMSR09Cab³ Autor ³ Antonio C Ferreira    ³ Data ³24.06.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Imprime Cabecalho com os Dados da Empresa                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ RTMSR09Cabec(ExpN1,ExpN2,ExpN3,ExpN4,ExpN5)                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametro ³ ExpN1 - No. Total de Veiculos a serem Impressos            ³±±
±±³Parametro ³ ExpN2 - No. Total de Motoristas a serem Impressos          ³±±
±±³Parametro ³ ExpN3 - No. Total de Ajudante a serem Impressos            ³±±
±±³Parametro ³ ExpA4 - Array contendo as informacoes iniciais do cabecalho³±±
±±³Parametro ³ ExpC5 - Codigo da Viagem.                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ RTMSR09			                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³        ³                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function RTMSR09Cabec(nCountVei,nCountMot,nCountAju,acabec,cViagem,nTamMaxCol)
Local lOk
Local aAux   := {}
Local nA     := 0
Local nBegin := 0

nCountVei   :=0
nCountMot   :=0
nCountAju   :=0
acabec      := {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta as linhas do cabecalho.                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

//-- Lista Veiculos
lOk  := .F.
DTR->(dbSetOrder(1))
DTR->(dbSeek(xFilial("DTR") + cFilAnt + cViagem ))

Do While DTR->( !Eof() .And. ((DTR_FILORI + DTR_VIAGEM) == (cFilAnt + cViagem)))
	
	dbSelectArea("DA3")
	dbSetOrder(1)
	If MsSeek(xFilial("DA3") + DTR->DTR_CODVEI)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Monta uma linha para cada registro do mesmo tipo(Veiculos).           ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Aadd(acabec,{if(nCountvei==0, "VEICULO "+": ", space(len("Veiculo   "+": "))) + AllTrim(Str(++nCountVei)) + "-" + DA3->DA3_COD + "  -  " + AllTrim(DA3->DA3_DESC)+ Space(05) +; //"VEICULO "
		"Placa : " + DA3->DA3_PLACA + Space(05)+ "   Capacidade : " + Transform(DA3->DA3_CAPACM,PesqPict("DA3","DA3_CAPACM")) +  Space(05)+ "Tipo Veic.: "  + AllTrim(Tabela("M2", DA3->DA3_TIPVEI, .F.))+; //"PLACA : "###"   CAPACIDADE : "###"TIPO VEIC.: "
		Space(05)+ "KM Saida : " + Replicate("_",25) + "KM Chegada : " + Replicate("_",25),"1"}) //"KM SAIDA : "###"KM CHEGADA : "
		
		lOK := .T.
	EndIf
	
	If !Empty(DTR->DTR_CODRB1) .And. DA3->(MsSeek(xFilial("DA3") + DTR->DTR_CODRB1))
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Monta uma linha com os dados do 1o. Reboque                           ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Aadd(aCabec, {if(nCountvei==0, "Veiculo   ", space(len("Veiculo   ") + 2)) + StrZero(++nCountvei, 1) + "-" + DA3->DA3_COD + " " + DA3->DA3_PLACA +; // Veiculo: ## - #### ###-####
		" " + "Tipo Veic.: " + Substr(Tabela("M2", DA3->DA3_TIPVEI, .F.),1,25) +; // Tipo: ############
		" " + "   Capacidade : " + Alltrim(Transform(DA3->DA3_CAPACM, PesqPict("DA3","DA3_CAPACM"))),"1"} ) //Capac: 999999.99
	EndIf
	
	If !Empty(DTR->DTR_CODRB2) .And. DA3->(MsSeek(xFilial("DA3") + DTR->DTR_CODRB2))
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³  Monta uma linha com os dados do 2o. Reboque                          ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Aadd(aCabec, {if(nCountvei==0, "Veiculo   ", space(len("Veiculo   ") + 2)) + StrZero(++nCountvei, 1) + "-" + DA3->DA3_COD + " " + DA3->DA3_PLACA +; // Veiculo: ## - #### ###-####
		" " + "Tipo Veic.: " + Substr(Tabela("M2", DA3->DA3_TIPVEI, .F.),1,25) +; // Tipo: ############
		" " + "   Capacidade : " + Alltrim(Transform(DA3->DA3_CAPACM, PesqPict("DA3","DA3_CAPACM"))),"1"} ) //Capac: 999999.99
	EndIf
	
	// Ajudante
	DUQ->(MsSeek(xFilial("DUQ") + cFilAnt + cViagem + DTR->DTR_ITEM))
	While DUQ->(!Eof()) .And. DUQ->(DUQ_FILIAL + DUQ_FILORI + DUQ_VIAGEM + DUQ_ITEDTR) == xFilial("DUQ") + cFilAnt + cViagem + DTR->DTR_ITEM
		
		If DAU->(MsSeek(xFilial("DAU") + DUQ->DUQ_CODAJU))
			Aadd(aAux,if(nCountAju==0, "Ajudante  "+" : ", Space(Len("Ajudante  "+" : "))) + AllTrim(Str(++nCountAju)) + "-" + DAU->DAU_NREDUZ) //"AJUDANTE "
		EndIf
		
		DUQ->(dbSkip())
	EndDo
	dbSelectArea("DTR")
	dbSkip()
EndDo

If lOk
	Aadd(acabec, {" ", ""})
EndIf

lOk := .F.

//Motirista
DUP->(dbSetOrder(1))
DUP->(dbSeek(xFilial("DUP") + cFilAnt + cViagem))
Do While !DUP->(Eof()) .And. DUP->DUP_FILIAL + DUP->DUP_FILORI + DUP->DUP_VIAGEM == xFilial('DUP') + cFilAnt + cViagem
	
	If DA4->(dbSeek(xFilial("DA4")+DUP->DUP_CODMOT))
		Aadd(aCabec,{if(nCountMot==0, "Motorista "+" : ", space(len("Motorista "+" : "))) + AllTrim(Str(++nCountMot)) + "-" + DA4->DA4_NREDUZ+replicate("_",35)+space(4)+"Data  ______/______/______      Hora da saída:  ________:________     Hora da Chegada  ________:________","2"}) //"MOTORISTA  "//
		
		lOk := .T.
	EndIf
	
	DUP->(dbSkip())
EndDo

If lOk
	Aadd(acabec, {" ", ""})
EndIf
lOk := .F.

//-- Lista Ajudantes
For nA := 1 To Len(aAux)
	lOk := .T.
	Aadd(aCabec, {aAux[nA], "3"})
Next nA

//-- Imprime Campo memo
If !Empty(DTQ->DTQ_CODOBS)
	If lOk
		Aadd(acabec, {" ", ""})
	EndIf
	
	cDescri := E_MsMM(DTQ->DTQ_CODOBS,80)
	nLinha:= MLCount(cDescri,nTamMaxCol)
	Aadd(acabec, {"Observacao : " + MemoLine(cDescri,nTamMaxCol,1), "4"})
	For nBegin := 2 To nLinha
		Aadd(acabec, {space(len("Observacao : ")) + Memoline(cDescri,nTamMaxCol,nBegin),"4"})
	Next nBegin
EndIf


Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ImpLin    ³ Autor ³Antonio C Ferreira     ³ Data ³18.02.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Imprime Linha para as Assinaturas dos Motoristas / Ajudantes³±±
±±³          ³(de 1 a n ...)                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ImpLin(ExpN1,ExpN2,ExpN3)                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametro ³ ExpN1 - No. da Linha                                       ³±±
±±³          ³ ExpN2 - No. da Coluna                                      ³±±
±±³Parametro ³ ExpN3 - Tam. Max da Coluna; Controla a Impressao dos dados ³±±
±±³          ³         na proxima linha.                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ RTMSR09			                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ImpLin(Li,nCol,nTamMaxCol)
If nCol <= nTamMaxCol
	@Li,nCol PSay "______________________________"
	nCol+=35
EndIf

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ImpAss    ³ Autor ³Antonio C Ferreira     ³ Data ³18.02.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Imprime Linha para as Assinaturas dos Motoristas / Ajudantes³±±
±±³          ³(de 1 a n ...)                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ImpAss(ExpN1,ExpN2,ExpC1,ExpN3,ExpN4,ExpN5)                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametro ³ ExpN1 - No. da Linha                                       ³±±
±±³          ³ ExpN2 - No. da Coluna                                      ³±±
±±³          ³ ExpC1 - Descricao da Assinatura (Motorista / Ajudante)     ³±±
±±³          ³ ExpN3 - No. para controlar se imprime ou nao na outra linha³±±
±±³          ³ ExpN4 - No. Total de Motoristas/Ajudantes a serem Impressos³±±
±±³Parametro ³ ExpN5 - Tam. Max da Coluna; Controla a Impressao dos dados ³±±
±±³          ³         na proxima linha.                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ RTMSR09			                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ImpAss(Li,nCol,cString,nNumDe,nNumAte,nTamMaxCol, lSequen)

Local nY  := 0
// Imprime numero sequencial.
Default lSequen := .T.

If nCol >= nTamMaxCol
	nCol:=0
	Li+=2
	For nY := nNumDe To nNumAte+1
		ImpLin(@Li,@nCol)
	Next
	nCol:=0
	Li++
EndIf
If nCol == 0
	@Li,nCol PSay "Data" //"Data"
	nCol+=35
EndIf
@Li,nCol PSay cString + Iif(lSequen, AllTrim(Str(nX)), "")
nCol+=35

Return


//===========================================================================\\
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³FindNFCli ³ Autor ³Maximo Canuto V. Neto  ³ Data ³18.02.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Imprime as notas do cliente contidas nos ctrc's             ³±±
±±³ Uso      ³ RTMSR09			                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FindNFCli()
Local _xArea     := GetArea()
Local cCodEmp    := U_fTmsCodEmp(DT6->DT6_CLIREM + DT6->DT6_LOJREM)  // JBS 05/02/2010 - Retorna emprea e filial

aNfcli := {}

QRY1 := " SELECT DTC_NUMNFC, DTC_SERNFC, C5_HRRECEB"
QRY1 += " FROM " + RetSQLName("DTC") + " , SC5" + SubStr(cCodEmp,1,3) + " SC5, SD2" + SubStr(cCodEmp,1,3) + " SD2 "
QRY1 += " WHERE DTC_DOC         = '"+DUD->DUD_DOC+"'"
QRY1 += "    AND DTC_SERIE      = '"+DUD->DUD_SERIE+"'"
QRY1 += "    AND DTC_FILIAL     = '"+xFilial('DTC') + "'"
QRY1 += "    AND D2_FILIAL      = '"+SubStr(cCodEmp,4,2)+"' " // Filial do Pedido Originario da Nota que Originou o CTRC
QRY1 += "    AND D2_DOC         = DTC_NUMNFC "                 //
QRY1 += "    AND D2_SERIE       = DTC_SERNFC"                  //
QRY1 += "    AND C5_FILIAL      = D2_FILIAL "                  //
QRY1 += "    AND C5_NUM         = D2_PEDIDO "                  //
QRY1 += "    AND D2_ITEM        = '01'"                        //
QRY1 += "    AND SC5.D_E_L_E_T_ = ''"                          //
QRY1 += "    AND SD2.D_E_L_E_T_ = ''"                          //
QRY1 += "    AND " + RetSQLName("DTC") + ".D_E_L_E_T_ = ''"
QRY1 += " ORDER BY DTC_NUMNFC

#xcommand TCQUERY <sql_expr>                          ;
[ALIAS <a>]                                           ;
[<new: NEW>]                                          ;
[SERVER <(server)>]                                   ;
[ENVIRONMENT <(environment)>]                         ;
=> dbUseArea(                                         ;
<.new.>,                                              ;
"TOPCONN",                                            ;
TCGENQRY(<(server)>,<(environment)>,<sql_expr>),      ;
<(a)>, .F., .T.)
// Processa Query SQL
TcQuery QRY1 NEW ALIAS "QRY1"         // Abre uma workarea com o resultado da query

DbSelectArea("QRY1")
QRY1->(dbGotop())

While !Eof()
	aadd(aNfCli,{QRY1->DTC_NUMNFC+"/"+QRY1->DTC_SERNFC,QRY1->C5_HRRECEB})
	QRY1->(DbSkip())
Enddo

QRY1->(DbCloseArea())

RestArea(_xArea)

Return()

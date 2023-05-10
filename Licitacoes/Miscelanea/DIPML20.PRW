#Include "Protheus.ch"
#Include "MSOLE.CH

User Function DIPML20()
Local cPerg	:= "DPML20"
Private cAviso := '' 
Private cDirWord := Upper(AllTrim(GETNEWPAR("MV_LICIDOC","")))

U_DIPPROC(ProcName(0),U_DipUsr()) // MCVN 22/01/2009

AjustaSX1(cPerg)

If Pergunte(cPerg,.T.)
	If MV_PAR02 == 1
		Processa({|| RunRosto()},"Selecionando Registros...")
	ElseIf MV_PAR02 == 2
		Processa({|| RunCheck()},"Selecionando Registros...")
	ElseIf MV_PAR02 == 3
		Processa({|| RunRosto()},"Selecionando Registros...")
		Processa({|| RunCheck()},"Selecionando Registros...")
	EndIf
EndIF
Return(Nil)    

*---------------------------------------*
Static Function RunRosto()
*---------------------------------------*
//Local cDirWord:='M:\data'+GetSrvProfString('STARTPATH','')+'Doc-Licitacao\'
Local nCount	:= 0
Local aArea 	:= GetArea()
Local cQuery := ''
Local oWord
Local cCartas := ''
Local cDoctos := ''
Local cProdts := ''
Local aTipo := {'','','','','',''}
Local aContrato := {'',''}
Local aPontual := {'',''}
Local aCliDeso := {'',''}
Local aTpverba := {'','','',''}
Local cFile := 'FolhaRosto.dot'
Local cOrgao := ''

If cEmpAnt = '04'
	cFile := 'FolhaRostoHQ.dot'
EndIf

Begin Sequence

cQuery	:= "SELECT DISTINCT "
cQuery	+= "UA1_CODIGO  CODIGO, "
cQuery	+= "UA1_ORGM    ORGAO, "
cQuery	+= "UA1_CGC     CGC, "
cQuery	+= "UA1_TIPO    TIPO, "
cQuery	+= "UA1_NRCONC  CONCOR, "   //Nº CONCORRENCIA
cQuery	+= "UA1_PROCES  PROCES, "   //Nº PROCESSO
cQuery	+= "UA1_DENCER  DENCER, "   //DATA ENCERRAMENTO
cQuery	+= "UA1_HENCER  HENCER, "   //HORA ENCERRAMENTO
cQuery	+= "UA1_DABERT  DABERT, "   //DATA ABERTURA
cQuery	+= "UA1_HABERT  HABERT, "   //HORA ABERTURA
cQuery	+= "UA1_CODCLI  CLIENTE, "   //CLIENTE
cQuery	+= "A1_NREDUZ   NOMCLIENT,"  //CLIENTE
cQuery	+= "UA1_CONDPA CONDPA, " //CONDICOES DE PAGAM,ENTO
cQuery	+= "UA1_DPROPO  DPROPO, "   //VALIDADE DA PROPOSTA EM DIAS
cQuery	+= "UA1_DENTRE  DENTRE, "   //PRAZO DE ENTREGA EM DIAS
cQuery	+= "UA1_VCONTR  DVALID, "	//DATA DE VALIDADE DO CONTRATO
cQuery	+= "UA1_VCONT2  DIASVALID, "	//DIAS DE VALIDADE DO CONTRATO
cQuery	+= "UA1_TPVALI  TIPOVALID, "	//TIPO DA VALIDADE DO CONTRATO(DIAS=D, MESES=M E ANOS =A)
cQuery	+= "UA1_ENCONT  ENCONT, "   //FORMA DE ENTREGA DO CONTRATO
cQuery	+= "UA1_CLDESO  CLDESO, "   //SE CLIENTE DESONERA
cQuery	+= "UA1_VEND NREDUZ, " // REPRESENTANTE  
cQuery	+= " A1_TECNICO	, " 
cQuery	+= " A1_TECN_A	, " 
cQuery	+= " A1_TECN_3	, " 
cQuery	+= " A1_TECN_R	, "  
cQuery	+= " A1_TECN_C	, "
cQuery	+= " A1_VENDHQ	, " 
cQuery	+= " A1_XVENDSP	, "  // RBORGES - 22/11/2013  
cQuery	+= "UA1_CONTRA  CONTRATO, "    //CONTRATO
cQuery	+= "UA1_FINANC  FINANCEIRO, "    //LIBERADO POR
cQuery	+= "UA1_VENDAS  VENDAS, "    //LIBERADO POR
cQuery	+= "UA1_PAGORG  PONTUAL, "    //PGTO. PONTUAL
cQuery	+= "UA1_VLRVER  VERBA, "    //VERBA DO ORGAO
cQuery	+= "UA1_TPVERB  TPVERB, "    //TIPO DE VERVA
cQuery	+= "UA1_CONSUL  CONSULTA, "    //CONSULTADO EM
cQuery	+= "UA1_POSICA  POSICAO, "    //POSICAO
cQuery	+= "UA1_OBSMEM  OBS, "    //OBSERVACAO
cQuery	+= "UA1_FORNE1  FORNE1, " // FORNECEDOR 1
cQuery	+= "UA1_TFORN1  FONE1, " //FONE FORNECEDOR 1
cQuery	+= "UA1_FORNE2  FORNE2, " //FORNECEDOR 2
cQuery	+= "UA1_TFORN2  FONE2, " //FONE FORNECEDOR 2
cQuery	+= "UA1_FORNE3  FORNE3, " //FORNECEDOR 3
cQuery	+= "UA1_TFORN3  FONE3 "		//FONE FORNECEDOR 3
cQuery	+= " FROM "
cQuery	+= RetSQLName("UA1") + " UA1, " //EDITAIS
cQuery	+= RetSQLName("SA1") + " SA1 " //EDITAIS

cQuery	+= "WHERE "
cQuery	+= "UA1.D_E_L_E_T_	<> '*'	AND	"
cQuery	+= "UA1.UA1_FILIAL	= '" + xFilial("UA1") + "' AND "
cQuery	+= "A1_COD  = UA1.UA1_CODCLI AND "
//	cQuery	+= "UA1.UA1_STATUS = '2' AND "
cQuery	+= "UA1.UA1_CODIGO = '" + mv_par01 + "' "
cQuery	+= "ORDER BY "
cQuery	+= "UA1.UA1_CODIGO "
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Faz o tratamento/compatibilidade com o Top Connect    		 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//	cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,'TOPCONN', TCGENQRY(,,cQuery),'EDITAL', .F., .T.)

cPathDot := '\word\'+cFile
//Local HandleWord
cPathEst:= cDirWord+'Temp\' // 
MontaDir(cPathEst)
CpyS2T(cPathDot,cPathEst,.T.) // Copia do Server para o Remote, eh necessario

ProcRegua(200)
EDITAL->( DbGotop() )
For x:=1 to 100
   Incproc('Editais . . .')
Next

If EDITAL->(EOF())
	If MV_PAR02 == 2
		Aviso('Atenção','Codigo de edital não encontrado!',{'Ok'})
	EndIf
	Break
EndIf

Do While EDITAL->( !Eof() )
	oWord := OLE_CreateLink('TMsOleWord')
	OLE_SetProperty( oWord, oleWdVisible,   .F. )
	OLE_NewFile(oWord, cPathEst+cFile)
	
	cCartas := ''
	cDoctos := ''
	cProdts	:= ''
	
	aTipo[val(EDITAL->TIPO)] := 'X'
	aContrato[val(EDITAL->CONTRATO)] := 'X'
	aPontual[val(EDITAL->PONTUAL)] := 'X'
	
	If val(EDITAL->CLDESO) <> 0
		aCliDeso[val(EDITAL->CLDESO)] := 'X'
	EndIf
		
	If !Empty(AllTrim(EDITAL->TPVERB))
		aTpverba[val(EDITAL->TPVERB)] := 'X'
	EndIf
	
	cOrgao  := StrTran(MSMM(EDITAL->ORGAO,,,,3),'/13/10',' ')//chr(13)+chr(10))
	
	OLE_SetDocumentVar(oWord,"nAcomp"	,EDITAL->CODIGO)
	OLE_SetDocumentVar(oWord,"nCliente" ,Alltrim(EDITAL->CLIENTE)+' - '+EDITAL->NOMCLIENT)
	OLE_SetDocumentVar(oWord,"cOrgao"	,Alltrim(cOrgao))
	OLE_SetDocumentVar(oWord,"cCGC"		,substr(EDITAL->CGC,1,2)+"."+;
	substr(EDITAL->CGC,3,3)+"."+;
	substr(EDITAL->CGC,6,3)+"/"+;
	substr(EDITAL->CGC,9,4)+"-"+;
	substr(EDITAL->CGC,13,2))
	OLE_SetDocumentVar(oWord,"lEdital" 	,aTipo[1]) //Pregao presencial
	OLE_SetDocumentVar(oWord,"lPregao" 	,aTipo[2]) //Pregao eletronico
	OLE_SetDocumentVar(oWord,"lPrecos" 	,aTipo[3]) //Tomada de preocos
	OLE_SetDocumentVar(oWord,"lConvite" ,aTipo[4]) //Convite
	OLE_SetDocumentVar(oWord,"lRegis"   ,aTipo[5])	//Registro de precos
	OLE_SetDocumentVar(oWord,"cConcor" 	,Alltrim(EDITAL->CONCOR))
	OLE_SetDocumentVar(oWord,"cProces" 	,Alltrim(EDITAL->PROCES))
	OLE_SetDocumentVar(oWord,"dEncerra"	,stod(EDITAL->DENCER))
	OLE_SetDocumentVar(oWord,"cHencer" 	,Alltrim(EDITAL->HENCER))
	OLE_SetDocumentVar(oWord,"dAbert" 	,stod(EDITAL->DABERT))
	OLE_SetDocumentVar(oWord,"cHabert" 	,Alltrim(EDITAL->HABERT))
	OLE_SetDocumentVar(oWord,"cPgto" 	,Alltrim(POSICIONE("SE4", 1, XFilial("SE4")+EDITAL->CONDPA, "E4_DESCRI")))
	OLE_SetDocumentVar(oWord,"cDpropo" 	,Alltrim(EDITAL->DPROPO) + " dia(s)")
	OLE_SetDocumentVar(oWord,"cDentre" 	,Alltrim(EDITAL->DENTRE) + " dia(s)")
	OLE_SetDocumentVar(oWord,"cRepres" 	,Alltrim(POSICIONE("SA3", 1, XFilial("SA3")+EDITAL->NREDUZ, "A3_NREDUZ")))
	OLE_SetDocumentVar(oWord,"cVendHq" 	,Alltrim(POSICIONE("SA3", 1, XFilial("SA3")+EDITAL->A1_VENDHQ, "A3_NREDUZ")))
	OLE_SetDocumentVar(oWord,"cTec1" 	,Alltrim(POSICIONE("SA3", 1, XFilial("SA3")+EDITAL->A1_TECNICO, "A3_NREDUZ")))
	OLE_SetDocumentVar(oWord,"cTec2" 	,Alltrim(POSICIONE("SA3", 1, XFilial("SA3")+EDITAL->A1_TECN_A, "A3_NREDUZ")))
	OLE_SetDocumentVar(oWord,"cTec3" 	,Alltrim(POSICIONE("SA3", 1, XFilial("SA3")+EDITAL->A1_TECN_3, "A3_NREDUZ")))
	OLE_SetDocumentVar(oWord,"cTec4" 	,Alltrim(POSICIONE("SA3", 1, XFilial("SA3")+EDITAL->A1_TECN_R, "A3_NREDUZ")))
	OLE_SetDocumentVar(oWord,"cTec5" 	,Alltrim(POSICIONE("SA3", 1, XFilial("SA3")+EDITAL->A1_TECN_C, "A3_NREDUZ"))) 
	OLE_SetDocumentVar(oWord,"cVendSp" 	,Alltrim(POSICIONE("SA3", 1, XFilial("SA3")+EDITAL->A1_XVENDSP, "A3_NREDUZ")))//RBORGES 22/11/2013.
	OLE_SetDocumentVar(oWord,"lContS" 	,AllTrim(aContrato[1]))
	OLE_SetDocumentVar(oWord,"lContN" 	,AllTrim(aContrato[2]))
	OLE_SetDocumentVar(oWord,"lDesoS" 	,aCliDeso[1])
	OLE_SetDocumentVar(oWord,"lDesoN" 	,aCliDeso[2])	
	OLE_SetDocumentVar(oWord,"cFormEnt"	,AllTrim(EDITAL->ENCONT))
	
	If Empty(DIASVALID)
		OLE_SetDocumentVar(oWord,"dEncer" 	,stod(EDITAL->DVALID))
	ElseIf !Empty(DIASVALID) .And. TIPOVALID = "D"
		OLE_SetDocumentVar(oWord,"dEncer" 	,DIASVALID +' '+ "DIA(S)")
	ElseIf !Empty(DIASVALID) .And. TIPOVALID = "M"	
		OLE_SetDocumentVar(oWord,"dEncer" 	,DIASVALID +' '+ "MES(ES)")
	Else	
		OLE_SetDocumentVar(oWord,"dEncer" 	,DIASVALID +' '+ "ANO(S)")
	Endif
	OLE_SetDocumentVar(oWord,"lPontS" 	,aPontual[1])
	OLE_SetDocumentVar(oWord,"lPontN" 	,aPontual[2])
	OLE_SetDocumentVar(oWord,"cVerba" 	,Transform(EDITAL->VERBA,"999,999,999.99"))
	
	/* Campos retirados do relatorio - RBorges 26/10/18
	OLE_SetDocumentVar(oWord,"lTpverba1",aTpverba[1])
	OLE_SetDocumentVar(oWord,"lTpverba2",aTpverba[2])
	OLE_SetDocumentVar(oWord,"lTpverba3",aTpverba[3])
	OLE_SetDocumentVar(oWord,"lTpverba4",aTpverba[4])
	*/
	
	OLE_SetDocumentVar(oWord,"cFinanceiro" 	,Alltrim(EDITAL->FINANCEIRO))
	OLE_SetDocumentVar(oWord,"cVendas" 	,Alltrim(EDITAL->VENDAS))
	OLE_SetDocumentVar(oWord,"cConsul" 	,stod(EDITAL->CONSULTA))
	OLE_SetDocumentVar(oWord,"cPosicao"	,Alltrim(EDITAL->POSICAO))	
	OLE_SetDocumentVar(oWord,"cForne1"	,Alltrim(EDITAL->FORNE1))
	OLE_SetDocumentVar(oWord,"cFone1"	,Alltrim(EDITAL->FONE1))
	OLE_SetDocumentVar(oWord,"cForne2"	,Alltrim(EDITAL->FORNE2))
	OLE_SetDocumentVar(oWord,"cFone2"	,Alltrim(EDITAL->FONE2))
	OLE_SetDocumentVar(oWord,"cForne3"	,Alltrim(EDITAL->FORNE3))
	OLE_SetDocumentVar(oWord,"cFone3"	,Alltrim(EDITAL->FONE3))
	
	OLE_SetDocumentVar(oWord,"cObs"		,MSMM(EDITAL->OBS))
	
	cQuery	:= "SELECT DISTINCT UA6.UA6_DESCRI CARTA, UA2.UA2_SEPARA SEPARA FROM "
	cQuery	+= RetSQLName("UA1") + " UA1 " //EDITAIS"
	cQuery	+= " INNER JOIN "+ RetSQLName("UA2") + " UA2 ON  UA1.UA1_CODIGO = UA2.UA2_EDITAL "//UA2
	cQuery	+= " INNER JOIN "+ RetSQLName("UA6") + " UA6 ON  UA2.UA2_CARTA = UA6.UA6_CODIGO "//UA2
	cQuery	+= " WHERE "
	cQuery	+= "UA1.D_E_L_E_T_	<> '*'	AND	"
	cQuery	+= "UA2.D_E_L_E_T_	<> '*'	AND	"
	cQuery	+= "UA6.D_E_L_E_T_	<> '*'	AND	"
	cQuery	+= "UA1.UA1_FILIAL	= '" + xFilial("UA1") + "' AND "
	cQuery	+= "UA2.UA2_FILIAL	= '" + xFilial("UA2") + "' AND "
	cQuery	+= "UA6.UA6_FILIAL	= '" + xFilial("UA6") + "' AND "
	cQuery	+= "UA1.UA1_CODIGO = '" + EDITAL->CODIGO + "' "
	//		cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN", TCGENQRY(,,cQuery),"CARTAS", .F., .T.)
	Do While CARTAS->( !Eof() )
		If CARTAS->SEPARA == "1"
			cCartas += "( X ) " + CARTAS->CARTA + chr(13)
		ElseIf CARTAS->SEPARA == "2"
			cCartas += "(   ) " + CARTAS->CARTA + chr(13)
		EndIf
		CARTAS->( dbSkip() )
	EndDo
	OLE_SetDocumentVar(oWord,"aCartas" ,cCartas)
	CARTAS->( dbCloseArea() )
	
	cQuery	:= "SELECT DISTINCT UA7.UA7_DESCRI DOCTO, UA3.UA3_SEPARA SEPARA FROM "
	cQuery	+= RetSQLName("UA1") + " UA1 " //EDITAIS"
	cQuery	+= " INNER JOIN "+ RetSQLName("UA3") + " UA3 ON  UA1.UA1_CODIGO = UA3.UA3_EDITAL "
	cQuery	+= " INNER JOIN "+ RetSQLName("UA7") + " UA7 ON  UA3.UA3_DOCTO = UA7.UA7_CODIGO "
	cQuery	+= " WHERE "
	cQuery	+= "UA1.D_E_L_E_T_	<> '*'	AND	"
	cQuery	+= "UA3.D_E_L_E_T_	<> '*'	AND	"
	cQuery	+= "UA7.D_E_L_E_T_	<> '*'	AND	"
	cQuery	+= "UA1.UA1_FILIAL	= '" + xFilial("UA1") + "' AND "
	cQuery	+= "UA3.UA3_FILIAL	= '" + xFilial("UA3") + "' AND "
	cQuery	+= "UA7.UA7_FILIAL	= '" + xFilial("UA7") + "' AND "
	cQuery	+= "UA1.UA1_CODIGO = '" + EDITAL->CODIGO + "' "
	//		cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN", TCGENQRY(,,cQuery),"DOCTOS", .F., .T.)
	Do While DOCTOS->( !Eof() )
		If DOCTOS->SEPARA == "1"
			cDoctos += "( X ) " + DOCTOS->DOCTO + chr(13)
		ElseIf DOCTOS->SEPARA == "2"
			cDoctos += "(   ) " + DOCTOS->DOCTO + chr(13)
		EndIf
		DOCTOS->( dbSkip() )
	EndDo

	OLE_SetDocumentVar(oWord,"aDocs" ,cDoctos)
	DOCTOS->( dbCloseArea() )
	
	cQuery	:= "SELECT UA4.UA4_PROMEM PRODT, UA4.UA4_QAMOST AMOST, UA4.UA4_OBSMEM OBSAMOST FROM "
	cQuery	+= RetSQLName("UA1") + " UA1 " //EDITAIS"
	cQuery	+= " INNER JOIN "+ RetSQLName("UA4") + " UA4 ON  UA1.UA1_CODIGO = UA4.UA4_EDITAL "
	cQuery	+= " WHERE "
	cQuery	+= "UA1.D_E_L_E_T_	<> '*'	AND	"
	cQuery	+= "UA4.D_E_L_E_T_	<> '*'	AND	"
	cQuery	+= "UA1.UA1_FILIAL	= '" + xFilial("UA1") + "' AND "
	cQuery	+= "UA4.UA4_FILIAL	= '" + xFilial("UA4") + "' AND "
	cQuery	+= "UA1.UA1_CODIGO = '" + EDITAL->CODIGO + "' "
	//		cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN", TCGENQRY(,,cQuery),"PRODTS", .F., .T.)
	Do While PRODTS->( !Eof() )
		If PRODTS->AMOST >= 1
			cProdts += 	"( X ) " + MSMM(PRODTS->OBSAMOST) + chr(13)
		Else
			cProdts += 	"(   ) " + MSMM(PRODTS->OBSAMOST) + chr(13)
		EndIf
		PRODTS->( dbSkip() )
	EndDo
	OLE_SetDocumentVar(oWord,"aProdutos" ,cProdts)
	PRODTS->( dbCloseArea() )
	
	dbSelectArea("EDITAL")
	OLE_SetDocumentVar(oWord,"aProdutos" ,cProdts)
	OLE_UpDateFields(oWord)

    If MV_PAR03 == 1 .or. MV_PAR03 == 3
	    OLE_PrintFile(oWord,"ALL")
        cAviso += 'Folha de Rosto do Edital '+EDITAL->CODIGO+' foi impresso com sucesso.'+chr(13)+chr(10)
    EndIf                                                                   
    
	Inkey(3)

    If MV_PAR03 == 2 .or. MV_PAR03 == 3
        OLE_SaveAsFile(oWord,cDirWord+'Rosto'+EDITAL->CODIGO+'.doc')
        cAviso += 'Folha de Rosto do edtial '+EDITAL->CODIGO+' gravado com o nome de arquivo '+chr(13)+chr(10)+cDirWord+'Rosto'+EDITAL->CODIGO+'.doc. Consulte-o através do MsWord se for necessario.'+chr(13)+chr(10)+chr(13)+chr(10)
    EndIf    

	OLE_CloseFile(oWord)
	OLE_CloseLink(oWord)
	
	EDITAL->( dbSkip() )
	
	IncProc()
	
    If !empty(cAviso) .and. MV_PAR02 == 1
	    Aviso('Aviso',cAviso,{"Ok"})
    EndIf    
	
EndDO

End Sequence

EDITAL->( dbCloseArea() )
RestArea(aArea)
Return Nil

*---------------------------------------*
Static Function RunCheck()
*---------------------------------------*
//Local cDirWord:='M:\Data'+GetSrvProfString("STARTPATH","")+"Doc-Licitacao\"
Local nCount:=0
Local aArea:=GetArea()
Local cQuery:=''
Local oWord
Local cCartas:=''
Local cDoctos:=''
Local cProdts:=''
Local aTipo:=RetSx3Box(Posicione('SX3',2,'UA1_TIPO','X3_CBOX'),,,14)
Local aContrato:={'',''}
Local aPontual:={'',''}
Local aCliDeso := {'',''}
Local aTpverba:={'','','',''}
Local cFile:='CheckList.dot'
Local cOrgao:=''
Local cDataAber
Local nTotAutent:=0
Local nTotCopias:=0

Begin Sequence

cQuery	:= " SELECT DISTINCT UA1_CODIGO CODIGO, UA1_ORGM ORGAO, UA1_TIPO TIPO, "
cQuery	+= " UA1_NRCONC  CONCOR, "   //Nº CONCORRENCIA
cQuery	+= " UA1_PROCES  PROCES, "   //Nº PROCESSO
cQuery	+= " UA1_DENCER  DENCER, "   //DATA ENCERRAMENTO
cQuery	+= " UA1_HENCER  HENCER, "   //HORA ENCERRAMENTO
cQuery	+= " UA1_DABERT  DABERT, "   //DATA ABERTURA
cQuery	+= " UA1_HABERT  HABERT, "   //HORA ABERTURA
cQuery	+= " UA1_CODCLI  CLIENTE, "   //CLIENTE
cQuery	+= " A1_NREDUZ   NOMCLIENT,"  //CLIENTE          '
cQuery	+= " A1_TECNICO     A1_TECNICO , " 
cQuery	+= " A1_TECN_A     A1_TECN_A            , " 
cQuery	+= " A1_TECN_3     A1_TECN_3             , " 
cQuery	+= " A1_TECN_R     A1_TECN_R , " 
cQuery	+= "A1_VENDHQ     A1_VENDHQ  , "
cQuery	+= " UA1_VEND NREDUZ, "       // REPRESENTANTE
cQuery	+= " UA1_USUDIG  USUDIGITOU " // REPRESENTANTE
cQuery	+= " FROM " + RetSQLName("UA1") + " UA1, " + RetSQLName("SA1") + " SA1 "
cQuery	+= " WHERE UA1.D_E_L_E_T_ <> '*'	"
cQuery	+= "   AND UA1.UA1_FILIAL	= '" + xFilial("UA1") + "'"
cQuery	+= "   AND UA1_CODIGO = '" + mv_par01 + "'"
cQuery	+= "   AND A1_COD = UA1.UA1_CODCLI "
cQuery	+= " ORDER BY UA1_CODIGO "

dbUseArea(.T.,"TOPCONN", TCGENQRY(,,cQuery),"EDITAL", .F., .T.)

ProcRegua(200)
EDITAL->( DbGotop() )

For x:=1 to 100
   Incproc('Editais . . .')
Next   

If EDITAL->(EOF())
	Aviso("Atenção","Codigo de edital não encontrado!",{"Ok"})
	Break
EndIf

cQuery	:= " SELECT DISTINCT UA6.UA6_DESCRI CARTA, UA2.UA2_SEPARA SEPARA "
cQuery	+= " FROM "+RetSQLName("UA1") + " UA1 " //EDITAIS"
cQuery	+= " INNER JOIN "+ RetSQLName("UA2") + " UA2 ON  UA1.UA1_CODIGO = UA2.UA2_EDITAL "//UA2
cQuery	+= " INNER JOIN "+ RetSQLName("UA6") + " UA6 ON  UA2.UA2_CARTA = UA6.UA6_CODIGO "//UA2
cQuery	+= " WHERE UA1.D_E_L_E_T_ <> '*' "
cQuery	+= "   AND UA2.D_E_L_E_T_ <> '*' "
cQuery	+= "   AND UA6.D_E_L_E_T_ <> '*' "
cQuery	+= "   AND UA1.UA1_FILIAL = '" + xFilial("UA1") + "' "
cQuery	+= "   AND UA2.UA2_FILIAL = '" + xFilial("UA2") + "' "
cQuery	+= "   AND UA6.UA6_FILIAL = '" + xFilial("UA6") + "' "
cQuery	+= "   AND UA1.UA1_CODIGO = '" + EDITAL->CODIGO + "' "

dbUseArea(.T.,"TOPCONN", TCGENQRY(,,cQuery),"CARTAS", .F., .T.)
CARTAS->(dbGotop())

cQuery	:= " SELECT DISTINCT UA7.UA7_DESCRI DOCTO, UA3.UA3_SEPARA SEPARA, UA3_VIAS, UA3_XEROX, UA3_ASSINA, UA3_AUTENT "
cQuery	+= " FROM "+RetSQLName("UA1") + " UA1 " //EDITAIS"
cQuery	+= " INNER JOIN "+ RetSQLName("UA3") + " UA3 ON  UA1.UA1_CODIGO = UA3.UA3_EDITAL "
cQuery	+= " INNER JOIN "+ RetSQLName("UA7") + " UA7 ON  UA3.UA3_DOCTO = UA7.UA7_CODIGO "
cQuery	+= " WHERE UA1.D_E_L_E_T_ <> '*' "
cQuery	+= "   AND UA3.D_E_L_E_T_ <> '*' "
cQuery	+= "   AND UA7.D_E_L_E_T_ <> '*' "
cQuery	+= "   AND UA1.UA1_FILIAL = '" + xFilial("UA1") + "' "
cQuery	+= "   AND UA3.UA3_FILIAL = '" + xFilial("UA3") + "' "
cQuery	+= "   AND UA7.UA7_FILIAL = '" + xFilial("UA7") + "' "
cQuery	+= "   AND UA1.UA1_CODIGO = '" + EDITAL->CODIGO + "' "

dbUseArea(.T.,"TOPCONN", TCGENQRY(,,cQuery),"DOCTOS", .F., .T.)
DOCTOS->(dbGotop())

cPathDot := "\word\"+cFile
//Local HandleWord
//cPathEst:= "C:\WINDOWS\TEMP\"
cPathEst:= cDirWord+'Temp\' // "M:\Data\sigaadv\Doc-Licitacao\"
MontaDir(cPathEst)
CpyS2T(cPathDot,cPathEst,.T.)

oWord := OLE_CreateLink('TMsOleWord')
OLE_SetProperty( oWord, oleWdVisible,   .F. )
OLE_NewFile(oWord, cPathEst+cFile)

cOrgao:=StrTran(MSMM(EDITAL->ORGAO,,,,3),"/13/10"," ")//chr(13)+chr(10))
cDataAber:=SubStr(EDITAL->DABERT,7,2)+'/'+SubStr(EDITAL->DABERT,5,2)+'/'+SubStr(EDITAL->DABERT,1,4)+' - '+EDITAL->HABERT

OLE_SetDocumentVar(oWord,"cUsuario"	     ,Alltrim(EDITAL->USUDIGITOU))
OLE_SetDocumentVar(oWord,"cEdital"	     ,Alltrim(EDITAL->CODIGO))
OLE_SetDocumentVar(oWord,"cConcorrencia" ,Alltrim(EDITAL->CONCOR))
OLE_SetDocumentVar(oWord,"cProcesso"	 ,Alltrim(EDITAL->PROCES))
OLE_SetDocumentVar(oWord,"cCliente"	     ,EDITAL->CLIENTE+'-'+Alltrim(EDITAL->NOMCLIENT))
OLE_SetDocumentVar(oWord,"cOrgao"     	 ,Alltrim(cOrgao))
OLE_SetDocumentVar(oWord,"cTipo"	     ,Alltrim(aTipo[val(EDITAL->TIPO)][3]))
OLE_SetDocumentVar(oWord,"cRealizacao"   ,cDataAber)

Id := 1
Do While CARTAS->( !Eof() )
	OLE_SetDocumentVar(oWord,"cDocumento" + StrZero(id,2),SubStr(CARTAS->CARTA,1,20)+If(CARTAS->SEPARA=='1',' (S)',' (N)'))
	CARTAS->( dbSkip() )
	Id ++
EndDo

nTotAutent := 0
nTotCopias := 0

Do While DOCTOS->( !Eof() )
	OLE_SetDocumentVar(oWord,"cDocumento" + StrZero(id,2),SubStr(DOCTOS->DOCTO,1,20)+If(DOCTOS->SEPARA=='1',' (S)',' (N)'))
	If DOCTOS->UA3_AUTENT = '1'
		nTotAutent += DOCTOS->UA3_VIAS
	EndIf
	If DOCTOS->UA3_XEROX = '1'
		nTotCopias += DOCTOS->UA3_VIAS
	EndIf
	DOCTOS->( dbSkip() )
	Id ++
EndDo

For id2 := id to 75
	OLE_SetDocumentVar(oWord,"cDocumento" + StrZero(id2,2)," ")
Next id2

OLE_SetDocumentVar(oWord,"cAutenticacao", Transform(nTotAutent,'@ke 999'))
OLE_SetDocumentVar(oWord,"cCopia"	    , Transform(nTotCopias,'@ke 999'))

OLE_UpDateFields(oWord)

If MV_PAR03 == 1 .or. MV_PAR03 == 3
    OLE_PrintFile(oWord,"ALL")
    cAviso += 'Checklist do Edital '+EDITAL->CODIGO+' foi impresso com sucesso.'+chr(13)+chr(10)
EndIf    

Inkey(3)

If MV_PAR03 == 2 .or. MV_PAR03 == 3
    OLE_SaveAsFile(oWord,cDirWord+'Chck'+EDITAL->CODIGO+'.doc')
    cAviso += 'Checklist do edtial '+EDITAL->CODIGO+' gravado com o nome de arquivo '+chr(13)+chr(10)+cDirWord+'Chck'+EDITAL->CODIGO+'.doc. Consulte-o através do MsWord se for necessario.'
EndIf    

OLE_CloseFile(oWord)
OLE_CloseLink(oWord)

CARTAS->(dbCloseArea())
DOCTOS->(dbCloseArea())

If !empty(cAviso)
	Aviso('Aviso',cAviso,{"Ok"})
EndIf    

End Sequence

EDITAL->(dbCloseArea())
RestArea(aArea)
Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AtualPerg ºAutor  ³William Ailton Mafraº Data ³  10/10/2005 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Atualiza o SX1 com as perguntas                             º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Dipromed                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function AjustaSX1(cPerg)

Local aPutSx1   := {}	//armazena o conteudo a ser enviado ao SX1
Local nItem
                 
DbSelectArea("SX1")
DbSetOrder(1) //X1_GRUPO = X1_ORDEM

cPerg := PADR(cPerg, Len(SX1->X1_GRUPO)," " ) // Incluido por Sandro em 18/11/09.

// PutSx1(       cGrupo ,cOrdem,cPergunt                ,cPerSpa,cPerEng,cVar     ,cTipo  ,nTamanho,nDecimal,nPresel,cGSC,cValid,cF3       , cGrpSxg,cPyme,cVar01    , cDef01          ,cDefSpa1 ,cDefEng1,cCnt01,cDef02      ,cDefSpa2,cDefEng2,cDef03,cDefSpa3,cDefEng3,cDef04,cDefSpa4,cDefEng4,cDef05,cDefSpa5,cDefEng5,aHelpPor,aHelpEng,aHelpSpa,cHelp)
AADD (aPutSX1, {cPerg, "01",  "Codigo do Edital  ?"  ,""     ,""     ,"mv_ch1" , "C"   ,6       ,0       ,0      ,"G" ,""    ,"UA1"   ,""      ,""   ,"mv_par01", ""                ,""       ,""      ,""    ,""          ,""      ,""      ,""     ,""      ,""      ,""    ,""      ,""      ,""   ,""      ,""      ,""      ,""      ,""       ,""     ,""})
AADD (aPutSX1, {cPerg, "02",  "Tipo de Relatorio ?"  ,""     ,""     ,"mv_ch2" , "N"   ,1       ,0       ,0      ,"C" ,""    ,""      ,""      ,""   ,"mv_par02", "Folha de Rosto"  ,""       ,""       ,""    ,"Check List",""     ,""     ,"Ambos",""      ,""      ,""    ,""      ,""      ,""   ,""      ,""      ,""      ,""      ,""       ,""     ,"",""})
AADD (aPutSX1, {cPerg, "03",  "Imprime/Salva/Ambos?" ,""     ,""     ,"mv_ch3" , "N"   ,1       ,0       ,0      ,"C" ,""    ,""      ,""      ,""   ,"mv_par03", "Imprimir"       ,""       ,""       ,""    ,"Salvar Arquivo" ,""      ,""    ,"Ambos",""      ,""      ,""    ,""      ,""      ,""   ,""      ,""      ,""      ,""      ,""       ,""     ,"",""})

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Atualiza o SX1 de forma dinamica.                             ³
//³Assim, quando houver a necessidade de inserir novas perguntas,³
//³basta inserir uma nova linha no array.                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

For nItem := 1 To Len(aPutSx1)
	If !DbSeek (aPutSX1[nItem][1]+aPutSX1[nItem][2])
		PutSX1( aPutSX1[nItem][1] , aPutSX1[nItem][2] , aPutSX1[nItem][3] , aPutSX1[nItem][4] , aPutSX1[nItem][5] ,;
		aPutSX1[nItem][6] , aPutSX1[nItem][7] , aPutSX1[nItem][8] , aPutSX1[nItem][9] , aPutSX1[nItem][10],;
		aPutSX1[nItem][11], aPutSX1[nItem][12], aPutSX1[nItem][13], aPutSX1[nItem][14], aPutSX1[nItem][15],;
		aPutSX1[nItem][16], aPutSX1[nItem][17], aPutSX1[nItem][18], aPutSX1[nItem][19], aPutSX1[nItem][20],;
		aPutSX1[nItem][21], aPutSX1[nItem][22], aPutSX1[nItem][23], aPutSX1[nItem][24], aPutSX1[nItem][25],;
		aPutSX1[nItem][26], aPutSX1[nItem][27], aPutSX1[nItem][28], aPutSX1[nItem][29], aPutSX1[nItem][30],;
		aPutSX1[nItem][31], aPutSX1[nItem][32], aPutSX1[nItem][33], aPutSX1[nItem][34], aPutSX1[nItem][35],;
		aPutSX1[nItem][36], aPutSX1[nItem][37], {}                , {}                , {} )
	EndIF
Next nItem
Return
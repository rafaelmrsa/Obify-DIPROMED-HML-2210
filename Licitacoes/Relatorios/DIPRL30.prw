#Include "PROTHEUS.CH"
#Include "MSOLE.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDIPRL30   บAutor  ณAlexandro Meier     บ Data ณ  06/10/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณGera relat๓rio de editais no Word                           บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function DIPRL30()

Private cPathEst
Private cPerg   := "Edital"

AjustaSx1(cPerg)

U_DIPPROC(ProcName(0),U_DipUsr()) // MCVN 22/01/2009

Pergunte(cPerg,.T.,"Selecione o c๓digo do edital") // True - abre a janela

If Empty(mv_par01) .OR. UA1->(dbSeek(xFiliaL("UA1") + mv_par01 ) ) .AND.;
	Empty(mv_par02)
	Alert("C๓digo do edital invแlido ou nome do arquivo vazio!")
Else
	u_RunArq()
EndIf

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDIPRL30   บAutor  ณAlexandro Meier     บ Data ณ  06/10/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao que gera relatorio no word atraves de modelos .DOT   บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function RunArq()

Local oWord		:= ""
Local cCodigo	:= ""
Local cFile  	:= ""
Local cETipo	:= ""
Local cSepara   := ""
Local cData 	:= ""
Local cDabert	:= ""
Local cDencer	:= ""
Local cDAutent	:= ""
Local cDCopia	:= ""
Local cDAssina	:= ""
Local cDSepara	:= ""
Local nA		:= 0
Local cArqDot
Local cCaract
Local nCol		:= 1
Local cNewFile
Local nCvias	:= 0
Local nDvias	:= 0
Local nQtd		:= 0
Local cProdu	:= ""

Private cPathEst

U_DIPPROC(ProcName(0),U_DipUsr()) // MCVN 22/01/2009
dbSelectArea("UA1")
UA1->(dbSetOrder(1))

cCodigo := UA1->UA1_CODIGO

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณABRE JANELA PARA SELEวAO DO ARQUIVO DE MODELO ".DOT"ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If !Empty(cFile) .And. At(".DOT",Upper(cFile))>0
	If !MsgYESNO("Deseja utilizar o mesmo arquivo ("+cFile+") usado anteriormente?")
		cTipo :=         "Modelo Word (*.DOT)        | *.DOT | "
		cFile := cGetFile(cTipo,"Selecione o modelo do arquivo",,,.T.,GETF_ONLYSERVER ,.T.)
		If !Empty(cFile)
			Aviso("Arquivo Selecionado",cFile,{"Ok"})
		Else
			Aviso("Cancelada a Selecao!","Voce cancelou a selecao do arquivo.",{"Ok"})
			Return
		Endif
	EndIf
Else
	cTipo :=         "Modelo Word (*.DOT)        | *.DOT | "
	cFile := cGetFile(cTipo ,"Selecione o modelo do arquivo",,,.T.,GETF_ONLYSERVER ,.T.)
	If !Empty(cFile)
		Aviso("Arquivo Selecionado",cFile,{"Ok"})
	Else
		Aviso("Cancelada a Selecao!","Voce cancelou a selecao do arquivo.",{"Ok"})
		Return
	Endif
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Criando link de comunicacao com o word                                ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

oWord := OLE_CreateLink('TMsOleWord')

For nA := 1  To Len(cFile)
	cCaract := SubStr(cFile,nCol,1)
	If  cCaract == "\"
		cArqDot := ""
	Else
		cArqDot += cCaract
	EndIf
	nCol := nCol + 1
Next

cPathEst := "C:\WINDOWS\Temp\" // PATH DO ARQUIVO A SER ARMAZENADO NA ESTACAO DE TRABALHO
MontaDir(cPathEst)

CpyS2T(cFile,cPathEst,.T.) // Copia do Server para o Remote, eh necessario
//para que o wordview e o proprio word possam preparar o arquivo para impressao e
// ou visualizacao .... copia o DOT que esta no ROOTPATH Protheus para o PATH da
// estacao , por exemplo C:\WORDTMP
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Abre o arquivo e ajusta suas propriedades                             ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

OLE_NewFile(oWord, cPathEst+cArqDot)
OLE_SetProperty( oWord, oleWdVisible,   .F. )
OLE_SetProperty( oWord, oleWdPrintBack, .T. )

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณQUERY PARA SELECIONAR CAMPOS DO EDITALณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
cQuery	:= "SELECT DISTINCT "
cQuery	+= "UA1_CODIGO  CODIGO, "
//	cQuery	+= "UA1_ORGAO   ORGAO, "
cQuery	+= "UA1_CGC     CGC, "
cQuery	+= "UA1_TIPO    TIPO, "
cQuery	+= "UA1_NRCONC  CONCOR, "
cQuery	+= "UA1_PROCES  PROCES, "
cQuery	+= "UA1_DENCER  DENCER, "
cQuery	+= "UA1_HENCER  HENCER, "
cQuery	+= "UA1_DABERT  DABERT, "
cQuery	+= "UA1_HABERT  HABERT, "
cQuery	+= "UA1_CODCLI  CLIENTE, "
cQuery	+= "UA1_DPROPO  DPROPO, "
cQuery	+= "UA1_DENTRE  DENTRE, "
cQuery	+= "UA1_VCONTR  DVALID, "
cQuery	+= "UA1_CONTRA  CONTRATO, "
cQuery	+= "UA1_PAGORG  PONTUAL "

cQuery	+= " FROM "
cQuery	+= RetSQLName("UA1") + " AS UA1 "

cQuery	+= "WHERE "
cQuery	+= "UA1.UA1_FILIAL	= '" + xFilial("UA1") + "' AND "
cQuery	+= "UA1.UA1_CODIGO = '" + mv_par01 + "' AND "
cQuery	+= "UA1.D_E_L_E_T_	<> '*'	"

cQuery	+= "ORDER BY "
cQuery	+= "UA1.UA1_CODIGO "

//	cQuery  := ChangeQuery(cQuery)

dbUseArea(.T.,"TOPCONN", TCGenQry(,,cQuery),'EDITAL', .F., .T.)

dbSelectArea("EDITAL")
EDITAL->(dbGoTop())

While EDITAL->(!Eof())
	
	OLE_SetDocumentVar(oWord,"cOrgao" ,"xxxxx") //AllTrim(EDITAL->ORGAO))
	OLE_SetDocumentVar(oWord,"cCgc"   ,AllTrim(EDITAL->CGC))
	
	If EDITAL->TIPO == "1"
		cETipo := "Edital"
	ElseIf EDITAL->TIPO == "2"
		cETipo := "Pregใo Eletr๔nico"
	ElseIf EDITAL->TIPO == "3"
		cETipo := "Tomada de Pre็os"
	ElseIf EDITAL->TIPO == "4"
		cETipo := "Convite"
	EndIf
	
	OLE_SetDocumentVar(oWord,"cTipo"  ,cETipo)
	OLE_SetDocumentVar(oWord,"cNrconc",AllTrim(EDITAL->CONCOR)) //Nr concorrencia
	OLE_SetDocumentVar(oWord,"cProces",AllTrim(EDITAL->PROCES)) //Nr processo
	
	cData := EDITAL->DENCER
	cDencer := substr(cData,7,2) + "/" + substr(cData,5,2) + "/" + substr(cData,3,2)
	OLE_SetDocumentVar(oWord,"cDencer",cDencer) //Data Encerramento
	OLE_SetDocumentVar(oWord,"cHencer",AllTrim(EDITAL->HENCER)) //Hora encerramento
	
	cData 	:= EDITAL->DABERT
	cDabert := substr(cData,7,2) + "/" + substr(cData,5,2) + "/" + substr(cData,3,2)
	OLE_SetDocumentVar(oWord,"cDabert",cDabert) //Data Abertura
	OLE_SetDocumentVar(oWord,"cHabert",AllTrim(EDITAL->HABERT)) //Hora Abertura
	OLE_SetDocumentVar(oWord,"cDpropo",AllTrim(EDITAL->DPROPO)+" (Dias)") //Validade da proposta em dias
	
	OLE_UpDateFields(oWord)
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณGera as variaveis do word para as cartas do editalณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	cQuery	:= "SELECT DISTINCT  "
	cQuery	+= "UA6.UA6_DESCRI CARTA, "
	cQuery	+= "UA2.UA2_VIAS VIAS, "
	cQuery	+= "UA2.UA2_SEPARA SEPARA, "
	cQuery	+= "UA2.UA2_USER USUAR "
	
	cQuery	+= "FROM "
	cQuery	+= RetSQLName("UA1") + " UA1 "
	
	cQuery	+= "INNER JOIN "
	cQuery	+= RetSQLName("UA2") + " AS UA2 "
	cQuery	+= "ON  UA1.UA1_CODIGO = UA2.UA2_EDITAL "
	cQuery	+= "INNER JOIN "
	cQuery	+= RetSQLName("UA6") + " AS UA6 "
	cQuery	+= "ON  UA2.UA2_CARTA = UA6.UA6_CODIGO "
	
	cQuery	+= "WHERE "
	cQuery	+= "UA1.UA1_FILIAL	= '" + xFilial("UA1") + "' AND "
	cQuery	+= "UA2.UA2_FILIAL	= '" + xFilial("UA2") + "' AND "
	cQuery	+= "UA6.UA6_FILIAL	= '" + xFilial("UA6") + "' AND "
	cQuery	+= "UA2.UA2_EDITAL = '" + EDITAL->CODIGO + "' AND "
	cQuery	+= "UA1.D_E_L_E_T_	<> '*'	AND	"
	cQuery	+= "UA2.D_E_L_E_T_	<> '*'	AND	"
	cQuery	+= "UA6.D_E_L_E_T_	<> '*' "
	
	//		cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN", TCGENQRY(,,cQuery),"CARTAS", .F., .T.)
	
	OLE_ExecuteMacro(oWord,"FimTab")
	OLE_ExecuteMacro(oWord,"FimTxt")
	OLE_ExecuteMacro(oWord,"CabCarta")
	
	While CARTAS->(!Eof())
		
		OLE_SetDocumentVar(oWord,"aCartas",AllTrim(CARTAS->CARTA))
		nCvias := CARTAS->VIAS
		OLE_SetDocumentVar(oWord,"aVias"  ,nCvias)
		
		cSepara := CARTAS->SEPARA
		If cSepara == "1"
			cSepara := "Sim"
		ElseIf cSepara == "2"
			cSepara := "Nใo"
		EndIf
		
		OLE_SetDocumentVar(oWord,"aSepara",cSepara)
		OLE_SetDocumentVar(oWord,"aUser"  ,AllTrim(CARTAS->USUAR))
		
		OLE_ExecuteMacro(oWord,"InsCarta")
		
		CARTAS->(dbSkip())
	EndDo
	CARTAS->(dbCloseArea())
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณGera as variaveis do word para os documentos do edital
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	cQuery	:= "SELECT "
	cQuery	+= "UA7.UA7_DESCRI DOCTO, "
	cQuery	+= "UA3.UA3_VIAS VIAS, "
	cQuery	+= "UA3.UA3_AUTENT AUTENT, "
	cQuery	+= "UA3.UA3_XEROX COPIA, "
	cQuery	+= "UA3.UA3_ASSINA ASSINA, "
	cQuery	+= "UA3.UA3_SEPARA SEPARA, "
	cQuery	+= "UA3.UA3_USER USUAR "
	
	cQuery	+= "FROM "
	cQuery	+= RetSQLName("UA1") + " UA1 "
	
	cQuery	+= "INNER JOIN "
	cQuery	+= RetSQLName("UA3") + " UA3 ON "
	cQuery	+= "UA1.UA1_CODIGO = UA3.UA3_EDITAL "
	cQuery	+= "INNER JOIN "
	cQuery	+= RetSQLName("UA7") + " UA7 ON "
	cQuery	+= "UA3.UA3_DOCTO = UA7.UA7_CODIGO "
	
	cQuery	+= "WHERE "
	cQuery	+= "UA1.UA1_FILIAL	= '" + xFilial("UA1") + "' AND "
	cQuery	+= "UA3.UA3_FILIAL	= '" + xFilial("UA3") + "' AND "
	cQuery	+= "UA7.UA7_FILIAL	= '" + xFilial("UA7") + "' AND "
	cQuery	+= "UA3.UA3_EDITAL = '" + EDITAL->CODIGO + "' AND "
	cQuery	+= "UA1.D_E_L_E_T_	<> '*' AND "
	cQuery	+= "UA3.D_E_L_E_T_	<> '*' AND "
	cQuery	+= "UA7.D_E_L_E_T_	<> '*' "
	
	//		cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN", TCGENQRY(,,cQuery),"DOCTOS", .F., .T.)
	
	OLE_ExecuteMacro(oWord,"FimTab")
	OLE_ExecuteMacro(oWord,"CabDoctos")
	
	Do While DOCTOS->( !Eof() )
		
		OLE_SetDocumentVar(oWord,"aDoctos"  ,AllTrim(DOCTOS->DOCTO))
		nDvias := DOCTOS->VIAS
		OLE_SetDocumentVar(oWord,"aDVias"   ,nDvias)
		
		cDAutent := DOCTOS->AUTENT
		If cDAutent == "1"
			cDAutent := "Sim"
		ElseIf cDAutent == "2"
			cDAutent := "Nใo"
		EndIf
		OLE_SetDocumentVar(oWord,"aDAutent" ,cDAutent)
		
		cDCopia := DOCTOS->COPIA
		If cDCopia == "1"
			cDCopia := "Sim"
		ElseIf cDCopia == "2"
			cDCopia := "Nใo"
		EndIf
		OLE_SetDocumentVar(oWord,"aDCopia"  ,cDCopia)
		
		cDAssina := DOCTOS->ASSINA
		If cDAssina == "1"
			cDAssina := "Sim"
		ElseIf cDAssina == "2"
			cDAssina := "Nใo"
		EndIf
		OLE_SetDocumentVar(oWord,"aDAssina" ,cDAssina)
		
		cDSepara := DOCTOS->SEPARA
		If cDSepara == "1"
			cDSepara := "Sim"
		ElseIf cDSepara == "2"
			cDSepara := "Nใo"
		EndIf
		OLE_SetDocumentVar(oWord,"aDSepara" ,cDSepara)
		OLE_SetDocumentVar(oWord,"aDUsuar"  ,AllTrim(DOCTOS->USUAR))
		
		OLE_ExecuteMacro(oWord,"InsDoctos")
		
		DOCTOS->(dbSkip())
	EndDo
	DOCTOS->(dbCloseArea())
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณGera as variaveis do word para os produtos do edital
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	cQuery	:= "SELECT "
	cQuery	+= "UA4.UA4_PRODUT CODIGO, "
	cQuery	+= "UA4.UA4_PROMEM PRODU, "
	cQuery	+= "UA4.UA4_QUANT QUANT, "
	cQuery	+= "SB1.B1_UM UNID "
	
	cQuery	+= "FROM "
	cQuery	+= RetSQLName("UA1") + " UA1 "
	
	cQuery	+= "INNER JOIN "
	cQuery	+= RetSQLName("UA4") + " UA4 ON "
	cQuery	+= "UA1.UA1_CODIGO = UA4.UA4_EDITAL "
	cQuery	+= "INNER JOIN "
	cQuery	+= RetSQLName("SB1") + " SB1 ON "
	cQuery	+= "UA4.UA4_PRODUT = SB1.B1_COD "
	
	cQuery	+= "WHERE "
	cQuery	+= "UA1.UA1_FILIAL	= '" + xFilial("UA1") + "' AND "
	cQuery	+= "UA4.UA4_FILIAL	= '" + xFilial("UA4") + "' AND "
	cQuery	+= "SB1.B1_FILIAL	= '" + xFilial("SB1") + "' AND "
	cQuery	+= "UA4.UA4_EDITAL  = '" + EDITAL->CODIGO + "' AND "
	cQuery	+= "UA1.D_E_L_E_T_	<> '*'	AND "
	cQuery	+= "UA4.D_E_L_E_T_	<> '*'	AND	"
	cQuery	+= "SB1.D_E_L_E_T_	<> '*'	"
	
	//		cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN", TCGENQRY(,,cQuery),"PRODU", .F., .T.)
	
	OLE_ExecuteMacro(oWord,"FimTab")
	OLE_ExecuteMacro(oWord,"CabProdu")
	
	While PRODU->(!Eof())
		
		OLE_SetDocumentVar(oWord,"aCodigo" ,AllTrim(PRODU->CODIGO))
		cProdu := MSMM(PRODU->PRODU)
		OLE_SetDocumentVar(oWord,"aProdu"  ,cProdu)
		nQtd := PRODU->QUANT
		OLE_SetDocumentVar(oWord,"aQuant"  ,nQtd)
		OLE_SetDocumentVar(oWord,"aUnid"   ,AllTrim(PRODU->UNID))
		
		OLE_ExecuteMacro(oWord,"InsProdu")
		
		PRODU->(dbSkip())
	EndDo
	PRODU->(dbCloseArea())
	
	EDITAL->(dbSkip())
EndDo
EDITAL->(dbCloseArea())

//SELECIONA O DIRETำRIO ONDE SERม SALVO O ARQUIVO ".DOC"
cNewFile := cGetFile(" | *.* |" , "Salvar em" ,,,.F., GETF_LOCALHARD + GETF_LOCALFLOPPY + GETF_RETDIRECTORY,.F.)

If(Len(cNewFile) < 1)
	Alert("Nome invแlido!")
	Return .F.
Else
	nPos := RAT("\",cNewFile)
	cPathEst := SUBSTR(cNewFile, 1, nPos)
	cNewFile := cPathEst
EndIF

cNewFile := cNewFile+AllTrim(mv_par02) + ".doc"

//SALVA O ARQUIVO NA ESTAวรO
OLE_SaveAsFile(oWord,cNewFile,,,.F.,)

//COPIA O ARQUIVO SALVO NA ESTAวAO PARA O SERVIDOR NO DIRETORIO \WORD\ A PARTIR DO ROOTPATH
CpyT2S(cNewFile,"\word\",.T.) // Copia do Remote para o Servidor

//GRAVA O DIRETำRIO + O NOME DO ARQUIVO .DOC NO UA1 PARA SER CHAMADO EM OUTRA ROTINA
dbSelectArea("UA1")
dbSeek(xFILIAL()+cCodigo)
RecLock("UA1",.F.)
UA1->UA1_MODELO	:= "\word\" + AllTrim(mv_par02) + ".doc"
MSUnlock()

OLE_CloseLink(oWord)

UA1->(dbCloseArea())

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPROWORD   บAutor  ณMicrosiga           บ Data ณ  10/06/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณCria o grupo de perguntas                                   บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function AjustaSX1(cPerg)
Local aPutSX1 := {}

cPerg := PADR(cPerg, Len(SX1->X1_GRUPO)," " ) // Incluido por Sandro em 18/11/09.

AADD (aPutSX1, {cPerg,"01","C๓digo Edital  ?","","","mv_ch1","C",06,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","UA1","","","","","",""})
AADD (aPutSX1, {cPerg,"02","Salvar Como    ?","","","mv_ch2","C",30,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})

u_AtuSX1(aPutSX1)

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ AtuSX1   บAutor  ณ Daniel Possebon    บ Data ณ  01/04/2005 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Atualiza o grupo de perguntas no SX1 seguindo a ordem      บฑฑ
ฑฑบ          ณ abaixo                                                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
User Function AtuSX1(aPerg)

/*
+-------+----------+----+-----+---+
| Ordem |Campo     |Tipo| Tam |Dec|
+-------+----------+----+-----+---+
| 01	ฆX1_GRUPO  ฆC   ฆ    6ฆ  0|
| 02	ฆX1_ORDEM  ฆC   ฆ    2ฆ  0|
| 03	ฆX1_PERGUNTฆC   ฆ   30ฆ  0|
| 04	ฆX1_PERSPA ฆC   ฆ   30ฆ  0|
| 05	ฆX1_PERENG ฆC   ฆ   30ฆ  0|
| 06	ฆX1_VARIAVLฆC   ฆ    6ฆ  0|
| 07	ฆX1_TIPO   ฆC   ฆ    1ฆ  0|
| 08	ฆX1_TAMANHOฆN   ฆ    2ฆ  0|
| 09	ฆX1_DECIMALฆN   ฆ    1ฆ  0|
| 10	ฆX1_PRESEL ฆN   ฆ    1ฆ  0|
| 11	ฆX1_GSC    ฆC   ฆ    1ฆ  0|
| 12	ฆX1_VALID  ฆC   ฆ   60ฆ  0|
| 13	ฆX1_VAR01  ฆC   ฆ   15ฆ  0|
| 14	ฆX1_DEF01  ฆC   ฆ   15ฆ  0|
| 15	ฆX1_DEFSPA1ฆC   ฆ   15ฆ  0|
| 16	ฆX1_DEFENG1ฆC   ฆ   15ฆ  0|
| 17	ฆX1_CNT01  ฆC   ฆ   60ฆ  0|
| 18	ฆX1_VAR02  ฆC   ฆ   15ฆ  0|
| 19	ฆX1_DEF02  ฆC   ฆ   15ฆ  0|
| 20	ฆX1_DEFSPA2ฆC   ฆ   15ฆ  0|
| 21	ฆX1_DEFENG2ฆC   ฆ   15ฆ  0|
| 22	ฆX1_CNT02  ฆC   ฆ   60ฆ  0|
| 23	ฆX1_VAR03  ฆC   ฆ   15ฆ  0|
| 24	ฆX1_DEF03  ฆC   ฆ   15ฆ  0|
| 25	ฆX1_DEFSPA3ฆC   ฆ   15ฆ  0|
| 26	ฆX1_DEFENG3ฆC   ฆ   15ฆ  0|
| 27	ฆX1_CNT03  ฆC   ฆ   60ฆ  0|
| 28	ฆX1_VAR04  ฆC   ฆ   15ฆ  0|
| 29	ฆX1_DEF04  ฆC   ฆ   15ฆ  0|
| 30	ฆX1_DEFSPA4ฆC   ฆ   15ฆ  0|
| 31	ฆX1_DEFENG4ฆC   ฆ   15ฆ  0|
| 32	ฆX1_CNT04  ฆC   ฆ   60ฆ  0|
| 33	ฆX1_VAR05  ฆC   ฆ   15ฆ  0|
| 34	ฆX1_DEF05  ฆC   ฆ   15ฆ  0|
| 35	ฆX1_DEFSPA5ฆC   ฆ   15ฆ  0|
| 36	ฆX1_DEFENG5ฆC   ฆ   10ฆ  0|
| 37	ฆX1_CNT05  ฆC   ฆ   60ฆ  0|
| 38	ฆX1_F3     ฆC   ฆ    6ฆ  0|
| 39	ฆX1_PYME   ฆC   ฆ    1ฆ  0|
| 40	ฆX1_GRPSXG ฆC   ฆ    3ฆ  0|
| 41	ฆX1_HELP   ฆC   ฆ   10ฆ  0|
| 42	ฆX1_PICTUREฆC   ฆ   40ฆ  0|
+-------+----------+----+-----+---+
*/
Local nX
Local lFound := .F.

Local oFWSX1 as object
Local aPergunte	:= {}

oFWSX1 := FWSX1Util():New()
oFWSX1:AddGroup(ALLTRIM(aPerg[1][1]))
oFWSX1:SearchGroup()
aPergunte := oFWSX1:GetGroup(ALLTRIM(aPerg[1][1]))

IF Empty(aPergunte[2])

	For nX:=1 to Len(aPerg)

		Begin Transaction
			cExec	:=	"INSERT INTO "+MPSysSqlName("SX1")+ " " + CRLF
			cExec	+=	"(	X1_GRUPO, " + CRLF
			cExec	+=	"	X1_ORDEM, " + CRLF
			cExec	+=	"	X1_PERGUNT, " + CRLF
				cExec	+=	"	X1_PERSPA, " + CRLF
				cExec	+=	"	X1_PERENG, " + CRLF
			cExec	+=	"	X1_VARIAVL, " + CRLF
			cExec	+=	"	X1_TIPO, " + CRLF
			cExec	+=	"	X1_TAMANHO, " + CRLF
			cExec	+=	"	X1_DECIMAL, " + CRLF
			cExec	+=	"	X1_PRESEL, " + CRLF
			cExec	+=	"	X1_GSC, " + CRLF
				cExec	+=	"	X1_VALID, " + CRLF
			cExec	+=	"	X1_VAR01, " + CRLF
				cExec	+=	"	X1_DEF01, " + CRLF
				cExec	+=	"	X1_DEFSPA1, " + CRLF
				cExec	+=	"	X1_DEFENG1, " + CRLF
				cExec	+=	"	X1_CNT01, " + CRLF
				cExec	+=	"	X1_VAR02, " + CRLF
				cExec	+=	"	X1_DEF02, " + CRLF
				cExec	+=	"	X1_DEFSPA2, " + CRLF
				cExec	+=	"	X1_DEFENG2, " + CRLF
				cExec	+=	"	X1_CNT02, " + CRLF
				cExec	+=	"	X1_VAR03, " + CRLF
				cExec	+=	"	X1_DEF03, " + CRLF
				cExec	+=	"	X1_DEFSPA3, " + CRLF
				cExec	+=	"	X1_DEFENG3, " + CRLF
				cExec	+=	"	X1_CNT03, " + CRLF
				cExec	+=	"	X1_VAR04, " + CRLF
				cExec	+=	"	X1_DEF04, " + CRLF
				cExec	+=	"	X1_DEFSPA4, " + CRLF
				cExec	+=	"	X1_DEFENG4, " + CRLF
				cExec	+=	"	X1_CNT04, " + CRLF
				cExec	+=	"	X1_VAR05, " + CRLF
				cExec	+=	"	X1_DEF05, " + CRLF
				cExec	+=	"	X1_DEFSPA5, " + CRLF
				cExec	+=	"	X1_DEFENG5, " + CRLF
				cExec	+=	"	X1_CNT05, " + CRLF
			cExec	+=	"	X1_F3, " + CRLF
				cExec	+=	"	X1_PYME, " + CRLF
				cExec	+=	"	X1_GRPSXG, " + CRLF
				cExec	+=	"	X1_HELP, " + CRLF
				cExec	+=	"	X1_PICTURE, " + CRLF
				cExec	+=	"	X1_IDFIL, " + CRLF
			cExec	+=	"	D_E_L_E_T_, " + CRLF
			cExec	+=	"	R_E_C_N_O_, " + CRLF
			cExec	+=	"	R_E_C_D_E_L_) " + CRLF
			cExec	+=	"	VALUES ( " + CRLF
			cExec	+=	"	'"+aPerg[nX][1]+"', " + CRLF
			cExec	+=	"	'"+aPerg[nX][2]+"', " + CRLF
			cExec	+=	"	'"+aPerg[nX][3]+"', " + CRLF
			cExec	+=	"	'', " + CRLF
			cExec	+=	"	'', " + CRLF
			cExec	+=	"	'"+aPerg[nX][6]+"', " + CRLF
			cExec	+=	"	'"+aPerg[nX][7]+"', " + CRLF
			cExec	+=	"	"+cValToChar(aPerg[nX][8])+", " + CRLF
			cExec	+=	"	"+cValToChar(aPerg[nX][9])+", " + CRLF
			cExec	+=	"	"+cValToChar(aPerg[nX][10])+", " + CRLF
			cExec	+=	"	'"+aPerg[nX][11]+"', " + CRLF
			cExec	+=	"	'', " + CRLF
			cExec	+=	"	'"+aPerg[nX][13]+"', " + CRLF
			cExec	+=	"	'', " + CRLF
			cExec	+=	"	'', " + CRLF
			cExec	+=	"	'', " + CRLF
			cExec	+=	"	'', " + CRLF
			cExec	+=	"	'', " + CRLF
			cExec	+=	"	'', " + CRLF
			cExec	+=	"	'', " + CRLF
			cExec	+=	"	'', " + CRLF
			cExec	+=	"	'', " + CRLF
			cExec	+=	"	'', " + CRLF
			cExec	+=	"	'', " + CRLF
			cExec	+=	"	'', " + CRLF
			cExec	+=	"	'', " + CRLF
			cExec	+=	"	'', " + CRLF
			cExec	+=	"	'', " + CRLF
			cExec	+=	"	'', " + CRLF
			cExec	+=	"	'', " + CRLF
			cExec	+=	"	'', " + CRLF
			cExec	+=	"	'', " + CRLF
			cExec	+=	"	'', " + CRLF
			cExec	+=	"	'', " + CRLF
			cExec	+=	"	'', " + CRLF
			cExec	+=	"	'', " + CRLF
			cExec	+=	"	'', " + CRLF
			cExec	+=	"	'"+aPerg[nX][38]+"', " + CRLF
			cExec	+=	"	'', " + CRLF
			cExec	+=	"	'', " + CRLF
			cExec	+=	"	'', " + CRLF
			cExec	+=	"	'', " + CRLF
			cExec	+=	"	'', " + CRLF
			cExec	+=	"	'', " + CRLF
			cExec	+=	"	ISNULL((SELECT MAX(R_E_C_N_O_) + 1 FROM "+MPSysSqlName("SX1")+ "),1),
			cExec	+=	"	'') "

			nErro := TcSqlExec(cExec)
					
			If nErro != 0
				MsgStop("Erro na execu็ใo da query: "+TcSqlError(), "Aten็ใo")
				DisarmTransaction()
			EndIf

		End Transaction

		If nErro != 0
			Exit
		Endif
	Next nX
ENDIF
aSize(aPergunte,0)
oFWSX1:Destroy()

FreeObj(oFWSX1)

/*
SX1-> ( dbSetOrder(1) )		//X1_GRUPO+X1_ORDEM

For nX := 1 To Len(aPerg)
	If SX1->( dbSeek( aPerg[nX][1] + aPerg[nX][2] ) )
		RecLock("SX1", .F.)
		lFound := .T.
	Else
		RecLock("SX1", .T.)
		lFound := .F.
		SX1->X1_GRUPO := aPerg[nX][1]
		SX1->X1_ORDEM := aPerg[nX][2]
	EndIf
	SX1->X1_PERGUNT	:= aPerg[nX][3]
	SX1->X1_PERSPA	:= aPerg[nX][4]
	SX1->X1_PERENG	:= aPerg[nX][5]
	SX1->X1_VARIAVL	:= aPerg[nX][6]
	SX1->X1_TIPO	:= aPerg[nX][7]
	SX1->X1_TAMANHO	:= aPerg[nX][8]
	SX1->X1_DECIMAL	:= aPerg[nX][9]
	SX1->X1_PRESEL	:= aPerg[nX][10]
	SX1->X1_GSC		:= aPerg[nX][11]
	SX1->X1_VALID	:= aPerg[nX][12]
	SX1->X1_VAR01	:= aPerg[nX][13]
	SX1->X1_DEF01	:= aPerg[nX][14]
	SX1->X1_DEFSPA1	:= aPerg[nX][15]
	SX1->X1_DEFENG1	:= aPerg[nX][16]
	SX1->X1_VAR02	:= aPerg[nX][18]
	SX1->X1_DEF02	:= aPerg[nX][19]
	SX1->X1_DEFSPA2	:= aPerg[nX][20]
	SX1->X1_DEFENG2	:= aPerg[nX][21]
	SX1->X1_VAR03	:= aPerg[nX][23]
	SX1->X1_DEF03	:= aPerg[nX][24]
	SX1->X1_DEFSPA3	:= aPerg[nX][25]
	SX1->X1_DEFENG3	:= aPerg[nX][26]
	SX1->X1_VAR04	:= aPerg[nX][28]
	SX1->X1_DEF04	:= aPerg[nX][29]
	SX1->X1_DEFSPA4	:= aPerg[nX][30]
	SX1->X1_DEFENG4	:= aPerg[nX][31]
	SX1->X1_VAR05	:= aPerg[nX][33]
	SX1->X1_DEF05	:= aPerg[nX][34]
	SX1->X1_DEFSPA5	:= aPerg[nX][35]
	SX1->X1_DEFENG5	:= aPerg[nX][36]
	SX1->X1_F3		:= aPerg[nX][38]
	SX1->X1_PYME	:= aPerg[nX][39]
	SX1->X1_GRPSXG	:= aPerg[nX][40]
	SX1->X1_HELP	:= aPerg[nX][41]
	SX1->X1_PICTURE	:= aPerg[nX][42]
	If !lFound
		SX1->X1_CNT01	:= aPerg[nX][17]
		//			SX1->X1_CNT02	:= aPerg[nX][22]
		//			SX1->X1_CNT03	:= aPerg[nX][27]
		//			SX1->X1_CNT04	:= aPerg[nX][32]
		//			SX1->X1_CNT05	:= aPerg[nX][37]
	EndIf
	MsUnlock()
Next nX
*/
Return

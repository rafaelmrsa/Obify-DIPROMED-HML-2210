#Include "Protheus.ch"
#Include "MSOLE.CH"


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDIPML30   บAutor  ณWilliam Ailton Mafraบ Data ณ  10/20/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณGera็ao de etiquetas.                                       บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function DIPML30()

Local cQuery 	:= ""
Local aHeader 	:= {}
Local nCount	:= 0
Local oWord
Local cNewPath	:= "C:\TMP\" //Diretorio no remote onde grava os arquivos

//Local cDBFPath	:= GetSrvProfString( 'STARTPATH', '' ) //Diretorio onde gera o DBF no Server: \System\

Local cDBFPath	:= "\system\"   // Alterado para gravar arquivos na pasta protheus_data - Por Sandro em 19/11/09. 

Local cDOTPath	:= "\word\" //diretorio onde encontra-se o .dot no server
Local cDOTFile	:= "modelo etiquetas.dot" //nome do arquivo modelo
Local cDBFFile	:= "TMP.dbf" //nome do arquivo DBF que sera gerado
Local cTipo 	:= "Diret๓rio         | *.* | "
U_DIPPROC(ProcName(0),U_DipUsr()) // MCVN 22/01/2009
	If(!u_DIP10Ok(.F.))			
		Alert("Edital em aberto ou data de validade expirada!")
		Return (.F.)
	EndIF           
	
	MontaDir(cNewPath)
	
    AADD(aHeader, {"DESC","C",30,0})
    AADD(aHeader, {"USUARIO","C",15,0})
    
    If File( cDBFPath + cDBFFile )
		Ferase( cDBFPath + cDBFFile )
	EndIf
    
    dbCreate( cDBFPath+cDBFFile, aHeader, "DBFCDX" )
    dbUseArea( .T., "DBFCDX", cDBFPath+cDBFFile, "EDITAL" )
                 
    cQuery	:= "SELECT DISTINCT UA2.UA2_USER USUARIO, UA6.UA6_DESCRI DESCRI from  "
	cQuery	+= RetSQLName("UA1") + " UA1 " //EDITAIS
	cQuery	+= "INNER JOIN "+ RetSQLName("UA2") + " UA2 ON  UA1.UA1_CODIGO = UA2.UA2_EDITAL "//UA2
	cQuery	+= "INNER JOIN "+ RetSQLName("UA6") + " UA6 ON  UA2.UA2_CARTA = UA6.UA6_CODIGO "//UA2
	cQuery	+= "WHERE "		
	cQuery	+= "UA1.D_E_L_E_T_	<> '*'	AND	"
	cQuery	+= "UA2.D_E_L_E_T_	<> '*'	AND	"
	cQuery	+= "UA6.D_E_L_E_T_	<> '*'	AND	"
	cQuery	+= "UA1.UA1_FILIAL	= '" + xFilial("UA1") + "' AND "
	cQuery	+= "UA2.UA2_FILIAL	= '" + xFilial("UA2") + "' AND "
	cQuery	+= "UA6.UA6_FILIAL	= '" + xFilial("UA6") + "' AND "
	cQuery	+= "UA1.UA1_CODIGO = '" + UA1->UA1_CODIGO + "' " 
	cQuery	+= "UNION "
	cQuery	+= "SELECT DISTINCT UA3.UA3_USER, UA7.UA7_DESCRI FROM  "
	cQuery	+= RetSQLName("UA1") + " UA1 " //EDITAIS"
	cQuery	+= "INNER JOIN "+ RetSQLName("UA3") + " UA3 ON  UA1.UA1_CODIGO = UA3.UA3_EDITAL "//UA2
	cQuery	+= "INNER JOIN "+ RetSQLName("UA7") + " UA7 ON  UA3.UA3_DOCTO = UA7.UA7_CODIGO "//UA2
	cQuery	+= "WHERE "		
	cQuery	+= "UA1.D_E_L_E_T_	<> '*'	AND	"
	cQuery	+= "UA3.D_E_L_E_T_	<> '*'	AND	"
	cQuery	+= "UA7.D_E_L_E_T_	<> '*'	AND	"
	cQuery	+= "UA1.UA1_FILIAL	= '" + xFilial("UA1") + "' AND "
	cQuery	+= "UA3.UA3_FILIAL	= '" + xFilial("UA3") + "' AND "
	cQuery	+= "UA7.UA7_FILIAL	= '" + xFilial("UA7") + "' AND "
	cQuery	+= "UA1.UA1_CODIGO = '" + UA1->UA1_CODIGO + "' " 
		
	//cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN", TCGENQRY(,,cQuery),"TMPEDITAL", .F., .T.)
	
	//Nr de registros encontrados
	TMPEDITAL->( DbGotop() )
    TMPEDITAL->( DbEval( {|| nCount++ }) )
    ProcRegua(nCount)
	TMPEDITAL->( DbGotop() )

	While TMPEDITAL->( !Eof() )		
	 	RecLock("EDITAL",.T.)
		EDITAL->DESC := TMPEDITAL->DESCRI
		EDITAL->USUARIO := TMPEDITAL->USUARIO
		MsUnLock() 		
		TMPEDITAL->( dbSkip() )  		
	EndDo	
	TMPEDITAL->( dbCloseArea() )    
	
	nPos := Len(cNewPath)
	If !SUBSTR(cNewPath, nPos,  1) == "\"
		cNewPath += "\"			
	EndIf
	
	//Copia o DOT do server para o remote
	CpyS2T(cDOTPath+cDOTFile, cNewPath, .T.)        
	                                       
	//Copia o DBF do Server para o Remote
	CpyS2T(cDBFPath+cDBFFile, cNewPath, .T.) 
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Criando link de comunicacao com o word                                ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู	
	oWord := OLE_CreateLink('TMsOleWord')
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Abre o arquivo e ajusta suas propriedades                             ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	OLE_OpenFile(oWord, cNewPath+cDOTFile)
	OLE_SetProperty( oWord, oleWdVisible,   .T. )
	OLE_SetProperty( oWord, oleWdPrintBack, .T. )
			
	OLE_ExecuteMacro(oWord,"novo_doc")                      
	

	EDITAL->( dbCloseArea() )    
	
	Ferase( cNewPath + "*.tmp" )

Return (.T.)
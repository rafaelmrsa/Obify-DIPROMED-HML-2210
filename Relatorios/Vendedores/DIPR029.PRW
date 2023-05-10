/*================================================================================\
|Programa  | DIPR029   | Autor | Rafael de Campos Falco   | Data | 15/10/2003     |
|=================================================================================|
|Descrição | Faturamento por cliente mes a mes e total do ano                     |
|=================================================================================|
|Sintaxe   | DIPR029                                                              |
|=================================================================================|
|Uso       | Especifico DIPROMED                                                  |
|=================================================================================|
|                               Histórico                                         |
|=================================================================================|
|Maximo    | 23/08/07 - Incluir tratamento para gerar relatírio p/ vendedor 2     |
|Daniel    | 23/10/07 - Adicionado Filtro de Representande e Grupo de Clientes    |
|Maximo    | 15/10/09 - Alterado o caminho do arquivo e PREPARE ENVIRONMENT       | 
\================================================================================*/

#INCLUDE "RWMAKE.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "FILEIO.CH"

#IFNDEF WINDOWS
	#DEFINE PSay Say
#ENDIF

User Function DIPR029(aWork)
Local _xArea := GetArea()
Local _aFeriad		:= {}
Local cUserAut      := ""
Local cVendInt      := ""
Local cVendExt      := ""
Private tamanho   	:= "P"
Private limite		:= 80
Private titulo		:= OemTOAnsi("Faturamento por cliente",72)
Private cDesc1		:= (OemToAnsi("Este programa tem como objetivo emitir um relat¢rio",72))
Private cDesc2		:= (OemToAnsi("de Faturamento por cliente.",72))
Private cDesc3		:= (OemToAnsi(" ",72))
Private aReturn	:= {"Bco A4", 1,"Faturamento", 1, 2, 1,"",1}
Private nomeprog	:= "DIPR029"

// Private cPerg		:= "DIPR29"
// FPADR(cPerg, cArq, cCampo, cTipo)  - Para ajustar o tamanho das perguntas no SX1- uso generico
PRIVATE cPerg  	    

Private nLastKey	:= 0
Private lEnd		:= .F.
Private li			:= 67
Private wnrel		:= "DIPR029"
Private M_PAG		:= 1
Private cString	:= "SF2"
Private _cRanking	:= ''
Private aEmiFat	:= {}
Private aEmiFatv:= {} // JBS 06/10/2006 
Private aEmiOrd	:= {}
Private cWorkFlow := "" 
Private cWCodEmp  := ""  
Private cWCodFil  := "" 
Private nHandle	  := ""   
Private _dDatIni  := ""
Private _dDatFim  := ""
Private _cDipUsr  := ""
//Tratamento para workflow
If ValType(aWork) <> 'A'
	cWorkFlow := "N"          
	cWCodEmp  := cEmpAnt
    cWCodFil  := cFilAnt                                                                          
	cPerg  	:= U_FPADR( "DIPR29","SX1","SX1->X1_GRUPO"," " ) //Função criada por Sandro em 19/11/09.
    U_DIPPROC(ProcName(0),U_DipUsr()) // JBS 13/12/2005 - Gravando o nome do Programa no SZU
Else
	cWorkFlow := aWork[1]    
	cWCodEmp  := aWork[3]
    cWCodFil  := aWork[4] 
	If cWorkFlow == "S"
		PREPARE ENVIRONMENT EMPRESA cWCodEmp FILIAL cWCodFil FUNNAME "DIPR029" //TABLES "SA3", "SA2", "SX5"
	EndIf
EndIf

If cWorkFlow == "N"    

   _cDipUsr  := U_DipUsr()
	cUserAut :=	GetMV("MV_URELFAT")   
	cVendInt := GetMV("MV_DIPVINT")
	cVendExt := GetMV("MV_DIPVEXT")
	
	If !(Upper(_cDipUsr) $ cUserAut .Or.;
		 Upper(_cDipUsr) $ cVendInt .Or.;
		 Upper(_cDipUsr) $ cVendExt .Or.;
		 Upper(_cDipUsr) $ cVendPub) 
		 Alert(Upper(_cDipUsr)+", você não tem autorização para utilizar esta rotina. Qualquer dúvida falar com Departamento de T.I.!!!!","Atenção")
		 Return()
	Endif
       


	AjustaSX1(cPerg)             // Verifica perguntas. Se nao existe INCLUI
	
	If !Pergunte(cPerg,.T.)    // Solicita parametros
		Return
	EndIf                      
	
	wnrel := SetPrint(cString,wnrel,cPerg,Titulo,cDesc1,cDesc2,cDesc3,.f.,,.f.,tamanho,,.f.,,,,,)
	
	If nLastKey == 27
		Return
	Endif
	
	SetDefault(aReturn,cString)
	
	Processa({|lEnd| RunProc()},"Totalizando por cliente e mes...")
	
	RptStatus({|lEnd| RptDetail()},"Imprimindo Faturamento por cliente e mes...")
	
	Set device to Screen


	/*==========================================================================\
	| Se em disco, desvia para Spool                                            |
	\==========================================================================*/	
	If aReturn[5] == 1    // Se Saida para disco, ativa SPOOL
		Set Printer TO
		Commit
		ourspool(wnrel)
	Endif

Else


    /* Inicio - Desabilitado 3 dias uteis - MCVN 27/09/2007 
	/*==========================================================================\
	| Este relatório executado via WORKFLOW, deverá usar as datas MV_PAR01 e    |
	| MV_PAR02. A data INICIAL deverá ser calculada da seguinte forma, a data   |
	| atual do sistema DDATABASE()-1, deverá voltar sempre um dia, com uma      |
	| ressalva de quando for o dia primeiro ele deverá retornar ao mês anterior |
	| executando o relatório no primeiro e último dia do mês anterior           |
	|                                                                           |
	\==========================================================================

   	dDatSis  := Date()-1 		// Data atual menos um dia Desabilitado dia 04/09/2007
	_dDatIni := FirstDay(dDatSis)	// Primeiro dia
	_dDatFim := LastDay (dDatSis)	// Último Dia*/
                                                      
                                                      
	/*==========================================================================\
	| Este relatório executado via WORKFLOW, deverá usar as datas MV_PAR02 e    |
	| MV_PAR03. A data INICIAL deverá ser calculada da seguinte forma, a data   |
	| atual do sistema DDATABASE(), deverá verificar se a data é o 3o. dia útil |
	| ou menor que ele se sim deverá voltar para o dia 01 do mês anterior e o   |
	| útimo dia do mês anterior. Caso a data esteja no 4o. útil em diante deverá|
	| usar o mês atual começando pelo dia 1o. até o último dîa do mês atual     |
	|                                                                           |
	\==========================================================================

	// Montagem do array com feriados
	dbSelectArea("SX5")
	dbSetOrder(1)
	dbSeek(xFilial("SX5")+"63")
	While X5_TABELA == "63"
		If SubStr(X5_DESCRI,1,1) != "*" .and. Val(SubStr(X5_DESCRI,7,2)) < 80 // Condição para pegar campos somente com datas e com ano de 2000 em diante
			// Monta data extraída do campo X5_DESCRI
			cTemp := Iif(Empty(SubStr(X5_DESCRI,7,2)),CtoD(SubStr(X5_DESCRI,1,2)+"/"+SubStr(X5_DESCRI,4,2)+"/"+"20"+AllTrim(Str(Year(Date())))),CtoD(SubStr(X5_DESCRI,1,2)+"/"+SubStr(X5_DESCRI,4,2)+"/"+"20"+SubStr(X5_DESCRI,7,2)))
			Aadd(_aFeriad,{cTOD(AllTrim(cTemp))})
		EndIf
		SX5->(DbSkip())
	EndDo
	
	// Verificação da data se o dia é feriado, se sim voltar (-1) dia
	_nPos := Ascan(_aFeriad,{|y| y[1] == dDatSis}) // Verifica se data é um Feriado
	If _nPos == 0 	// Se a data for um feriado despreza o dia
		dDatSis := dDatSis-1	
	EndIf

	// Verificação da data se o dia é domingo, se sim voltar (-1) dia
	If (AllTrim(cDow(dDatSis)) == "Sunday")// Descarta qdo. for Domingo
		dDatSis := dDatSis-1	
	EndIf

	// Verificação da data se o dia é sábado, se sim voltar (-1) dia
	If (AllTrim(cDow(dDatSis)) == "Saturday") // Descarta qdo. for Sábado
		dDatSis := dDatSis-1	
	EndIf
	     

	/*==========================================================================\
	| No bloco seguinte é feita a identificação do 3o. dia útil do mês atual    |
	|                                                                           |
	\==========================================================================

  	// Data do DIA atual
	nConta := 0
	nDia_Uti:= 0
	dDatSis := Date()
	dDatUti := FirstDay(dDatSis)
	
	// Verifica se data do dia útil é um feriado ou ponte  MCVN - 04/09/2007
	While nConta < 4 // Quantidade de DIAS utéis considerando que os relatórios são enviados na madrugada do dia seguinte MCVN - 04/09/2007
		_nPos := Ascan(_aFeriad,{|y| y[1] == dDatUti}) // Verifica se data é um Feriado
		If _nPos != 0 	// Se a data for um feriado despreza o dia
			nDia_Uti++
		Else
			// verifica se data do dia útil é um sábado ou domingo
			If cDow(dDatUti) == "Saturday"
				nDia_Uti++
			ElseIf cDow(dDatUti) == "Sunday"
				nDia_Uti++
			Endif
						
 		EndIf
        nConta++   
        dDatUti++
        nDia_Uti++
	EndDo
                
  
  	// Data do DIA atual
	//dDatSis := Date()
	
	// Verificação se está entre o 1o. e 3o. dia útil para voltar para o mês anterior
   If val(substr(dtos(dDatSis),7,2)) > nDia_Uti
   		_dDatIni := FirstDay(dDatSis)	// Primeiro dia
		_dDatFim := LastDay (dDatSis)	// Último Dia
	Else   
		_dDatIni := FirstDay(dDatSis)-10 // volta para o mês anterior			
   		_dDatIni := FirstDay(_dDatIni)	// Primeiro dia
		_dDatFim := LastDay (_dDatIni)	// Último Dia
	EndIf                                                      
                                                      
                                                      
	MV_PAR01 := _dDatIni
	MV_PAR02 := _dDatFim
	MV_PAR03 := aWork[2]
	MV_PAR04 := 1     - Fim da rotina de tratamento de 3 dias uteis*/
	



	dDatSis  := Date()-1 		// Data atual menos um dia 
	_dDatIni := FirstDay(dDatSis)	// Primeiro dia
	_dDatFim := LastDay (dDatSis)	// Último Dia
                                                      
	MV_PAR01 := _dDatIni
	MV_PAR02 := _dDatFim
	MV_PAR03 := aWork[2]
	MV_PAR04 := ""
	
	//Desabilitado tratamento para Scheduler Unico
/*  
	aCod_Rep := {}
	Qry := " SELECT A3_COD"
	Qry += " FROM " + RetSQLName("SA3")
	Qry += " WHERE A3_DESLIG = ''"
	Qry += " AND A3_TIPO = 'E'"
	Qry += " AND A3_EMAIL <> ''"
	Qry += " AND SA3010.D_E_L_E_T_ = ''"
	Qry := ChangeQuery(Qry)
	
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,Qry),"Qry",.F.,.T.)
	
	DbSelectArea("Qry")
	DbGoTop()
	While Qry->(!EOF())
		aadd(aCod_Rep,{Qry->A3_COD})
		Qry->(DbSkip())
	EndDo
	Qry->(dbCloseArea())
	
	Qry := " SELECT A3_COD"
	Qry += " FROM " + RetSQLName("SU7")+', '+RetSQLName("SA3")
	Qry += " WHERE U7_CODVEN <> ''"
	Qry += " AND U7_CODVEN = A3_COD"
	Qry += " AND A3_COD <> '000204'"
	Qry += " AND A3_DESLIG = ''"
	Qry += " AND SU7010.D_E_L_E_T_ = ''"
	Qry += " AND SA3010.D_E_L_E_T_ = ''"
	Qry := ChangeQuery(Qry)
	
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,Qry),"Qry",.F.,.T.)
	
	DbSelectArea("Qry")
	DbGoTop()
	While Qry->(!EOF())
		If aScan(aCod_Rep,{|x| x[1] ==Qry->A3_COD}) == 0
			aadd(aCod_Rep,{Qry->A3_COD})
		EndIf
		Qry->(DbSkip())
	EndDo
	Qry->(dbCloseArea())
*/
	If Empty( Posicione("SA3",1,xFilial("SA3")+MV_PAR03,"A3_DESLIG") )
	
		ConOut("--------------------------")
	    ConOut('Faturamento por cliente - Vendedor ')
		ConOut('Inicio - ' + dToc(date())+' - '+Time())
		ConOut("--------------------------")
	
		//Desabilitado tratamento para Scheduler Unico
	/*
		For zi := 1 To Len(aCod_Rep)
			MV_PAR03 := aCod_Rep[zi,1]
			ConOut("--------------------------")
			ConOut('Inicio - ' + aCod_Rep[zi,1]+' - '+Time())
			ConOut("--------------------------")
	
			ConOut(' ')
			ConOut(' ')
	*/	
			RunProc()
			RptDetail()	
	
		//Desabilitado tratamento para Scheduler Unico
	/*	
			ConOut("--------------------------")
			ConOut('Fim - ' + aCod_Rep[zi,1]+' - '+Time())
			ConOut("--------------------------")
		Next
	*/
		ConOut("--------------------------")
	    ConOut('Faturamento por cliente - Vendedor ')
		ConOut('Fim - ' + dToc(date())+' - '+Time())
		ConOut("--------------------------")
	
		ConOut(' ')
	EndIf
	
EndIf

RestArea(_xArea)

Return
*--------------------------------*
Static Function RunProc()
*--------------------------------*
Local nTotCli	:= nPos := 0
Local cCliAnt	:= ""
Local dDatAnt	:= ""
Local dEmissa	:= ""
Local cNomcli	:= ""
Local cLojCli	:= ""
Local cDat_Dev := ""
Local cLoj_Dev := ""
Local cCli_Dev := ""
Local cNom_Dev := ""
Local cTot_Dev := 0                                   
Local bVendedor := {|cAlias| IIf(&(cAlias+"->D2_FORNEC")=='000996' .And. !Empty(&(cALias+"->F2_VEND2")) ,&(cALias+"->F2_VEND2"),&(cAlias+"->F2_VEND1"))}

/*
SELECT F2_DOC, (D2_TOTAL + D2_VALFRE) VALFAT, F2_EMISSAO, F2_CLIENTE, F2_LOJA, F2_VEND1, A1_NOME
FROM SF2010, SA1010, SD2010, SF4010
WHERE F2_EMISSAO BETWEEN '20031101' AND '20031131'
AND F2_VEND1 = '000209'
AND F2_CLIENTE = A1_COD
AND F2_FILIAL = D2_FILIAL
AND F2_DOC = D2_DOC
AND D2_TES = F4_CODIGO
AND F4_DUPLIC = 'S'
AND SF2010.D_E_L_E_T_ <> '*'
AND SA1010.D_E_L_E_T_ <> '*'
AND SF4010.D_E_L_E_T_ <> '*'
AND SD2010.D_E_L_E_T_ <> '*'
ORDER BY F2_EMISSAO, F2_CLIENTE
*/

ProcRegua(1000)
For _x := 1 to 200
	IncProc()
Next

//*********************** QUERY DO FATURAMENTO GERAL **************************************
QRY1 := "SELECT F2_DOC, (D2_TOTAL + D2_VALFRE) VALFAT, F2_EMISSAO, F2_CLIENTE, F2_LOJA, A1_NOME, F2_VEND2, D2_FORNEC, F2_VEND1"
QRY1 += " FROM " +  RetSQLName('SF2') + ',' + RetSQLName('SA1')  + ',' + RetSQLName('SF4')  + ',' + RetSQLName('SD2') 
QRY1 += " WHERE F2_EMISSAO BETWEEN '" + DTOS(MV_PAR01) + "' AND '" + DTOS(MV_PAR02) +"'"
//QRY1 += " AND F2_VEND1 = '" + MV_PAR03 + "'"

// MCVN - 08/03/2010
QRY1 += " AND F2_FILIAL = '"+xFilial("SF2")+"'" 
QRY1 += " AND F4_FILIAL = '"+xFilial("SF4")+"'"
QRY1 += " AND A1_FILIAL = '"+xFilial("SA1")+"'"  //Giovani Zago 28/10/11

If !Empty(MV_PAR03)
	QRY1 += " AND (F2_VEND1 = '" + MV_PAR03 + "' AND (F2_VEND2 = ' ' OR D2_FORNEC <> '000996') "
	QRY1 += " OR (F2_VEND2 = '" + MV_PAR03 + "' and D2_FORNEC IN ('000366','000446','000996')))"  //MCVN - 24/08/07
EndIf

//QRY1 += " AND F2_CLIENTE = A1_COD" //Giovani Zago 28/10/11
QRY1 += " AND F2_FILIAL = D2_FILIAL"
QRY1 += " AND F2_DOC = D2_DOC"
QRY1 += " AND F2_SERIE = D2_SERIE"
QRY1 += " AND D2_TES = F4_CODIGO"
QRY1 += " AND F4_DUPLIC = 'S'"

If U_ListVend() != ''
	QRY1 += " AND (F2_VEND1 " + U_ListVend() + " AND (F2_VEND2 = ' ' OR D2_FORNEC <> '000996') "
	QRY1 += " OR (F2_VEND2 " + U_ListVend() + " and D2_FORNEC IN ('000366','000446','000996')))" 
EndIf 

QRY1 += " AND A1_COD = D2_CLIENTE"//Giovani Zago 28/10/11
QRY1 += " AND A1_LOJA = D2_LOJA"//Giovani Zago 28/10/11
If !Empty(MV_PAR04)
	QRY1 += " AND A1_GRPVEN = '" + MV_PAR04 + "'"
EndIf
QRY1 += " AND " + RetSQLName('SF2') + ".D_E_L_E_T_ <> '*' AND "
QRY1 += RetSQLName('SD2') + ".D_E_L_E_T_ <> '*' AND "
QRY1 += RetSQLName('SF4') + ".D_E_L_E_T_ <> '*' AND "
QRY1 += RetSQLName('SA1') + ".D_E_L_E_T_ <> '*' "
QRY1 += "ORDER BY F2_EMISSAO, F2_CLIENTE"
memowrite('DIPR029A.SQL',QRY1)

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


/********************************** QUERY DAS DEVOLUÇÕES **************************************
SELECT D1_DOC, D1_DTDIGIT, D1_TOTAL, D2_CLIENTE, D2_LOJA, A1_NOME
FROM SF1010, SD1010, SD2010, SF4010, SF2010, SA1010
WHERE D1_DTDIGIT BETWEEN '20031111' AND '20031111'
AND D1_TIPO = 'D'
AND D1_FILIAL = D2_FILIAL
AND D1_NFORI = D2_DOC
AND D1_SERIORI = D2_SERIE
--AND D1_ITEMORI = D2_ITEM
AND D2_DOC = F2_DOC
AND F2_VEND1 = '000208'
AND D1_TES = F4_CODIGO
AND F4_DUPLIC = 'S'
AND A1_COD = D2_CLIENTE
AND A1_LOJA = D2_LOJA
AND SD1010.D_E_L_E_T_ <> '*'
AND SD2010.D_E_L_E_T_ <> '*'
AND SF4010.D_E_L_E_T_ <> '*'
AND SD2010.D_E_L_E_T_ <> '*'
AND SA1010.D_E_L_E_T_ <> '*'
ORDER BY D1_DTDIGIT
*/  

ProcRegua(1000)
For _x := 1 to 200
	IncProc()
Next

QRY2 := "SELECT D1_DOC, D1_DTDIGIT, D1_TOTAL, D2_CLIENTE, D2_LOJA, A1_NOME, F2_VEND2, D2_FORNEC, F2_VEND1 "
QRY2 += " FROM " +  RetSQLName('SD1') + ',' + RetSQLName('SD2') + ',' + RetSQLName('SF4') + ',' + RetSQLName('SF2') + ',' + RetSQLName('SA1')
QRY2 += " WHERE D1_DTDIGIT BETWEEN '" + DTOS(MV_PAR01) + "' AND '" + DTOS(MV_PAR02) +"'"
QRY2 += " AND D1_TIPO = 'D'" 

// MCVN - 08/03/2010
QRY2 += " AND D1_FILIAL = '"+xFilial("SD1")+"'" 
QRY2 += " AND F2_FILIAL = '"+xFilial("SF2")+"'" 
QRY2 += " AND F4_FILIAL = '"+xFilial("SF4")+"'"
QRY2 += " AND A1_FILIAL = '"+xFilial("SA1")+"'"  //Giovani Zago 28/10/11

QRY2 += " AND D1_FILIAL = D2_FILIAL"
QRY2 += " AND D1_NFORI = D2_DOC"
QRY2 += " AND D1_SERIORI = D2_SERIE"
QRY2 += " AND D1_ITEMORI = D2_ITEM"
QRY2 += " AND D1_TES = F4_CODIGO"
QRY2 += " AND F4_DUPLIC = 'S'"
QRY2 += " AND D2_DOC = F2_DOC"
QRY2 += " AND D2_SERIE = F2_SERIE" 
QRY2 += " AND D2_FILIAL = F2_FILIAL"

If !Empty(MV_PAR03)
	QRY2 += " AND (F2_VEND1 = '" + MV_PAR03 + "' AND (F2_VEND2 = ' ' OR D2_FORNEC <> '000996') "
	QRY2 += " OR (F2_VEND2 = '" + MV_PAR03 + "' and D2_FORNEC IN ('000366','000446','000996')))"  //MCVN - 24/08/07
EndIf   

QRY2 += " AND A1_COD = D2_CLIENTE"
QRY2 += " AND A1_LOJA = D2_LOJA"

If U_ListVend() != ''
	QRY2 += " AND (F2_VEND1 " + U_ListVend() + " AND (F2_VEND2 = ' ' OR D2_FORNEC <> '000996') "
	QRY2 += " OR (F2_VEND2 " + U_ListVend() + " and D2_FORNEC IN ('000366','000446','000996')))" 
EndIf

If !Empty(MV_PAR04)
	QRY2 += " AND A1_GRPVEN = '" + MV_PAR04 + "'"
EndIf
QRY2 += " AND " + RetSQLName('SD1') + ".D_E_L_E_T_ <> '*'"
QRY2 += " AND " + RetSQLName('SD2') + ".D_E_L_E_T_ <> '*'"
QRY2 += " AND " + RetSQLName('SF4') + ".D_E_L_E_T_ <> '*'"
QRY2 += " AND " + RetSQLName('SF2') + ".D_E_L_E_T_ <> '*'"
QRY2 += " AND " + RetSQLName('SA1') + ".D_E_L_E_T_ <> '*'"
QRY2 += "ORDER BY D1_DTDIGIT"
memowrite('DIPR029B.SQL',QRY2)

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
TcQuery QRY2 NEW ALIAS "QRY2"         // Abre uma workarea com o resultado da query

dbSelectArea("QRY1")
QRY1->(dbGotop())

// montando array para impressão
Do While QRY1->(!Eof())
	IncProc( "Processando... Dados vendas de " + Left(QRY1->A1_NOME,15)+"...")

	nPos := Ascan(aEmiFat,{|x| x[6]+x[3]+x[2]+x[1] == Eval(bVendedor,"QRY1")+QRY1->F2_CLIENTE+QRY1->F2_LOJA+QRY1->F2_EMISSAO })

	If nPos == 0
		Aadd(aEmiFat,{QRY1->F2_EMISSAO, QRY1->F2_LOJA, QRY1->F2_CLIENTE, QRY1->A1_NOME, QRY1->VALFAT, Eval(bVendedor,"QRY1")})
	Else
		aEmiFat[nPos,5] += QRY1->VALFAT
	EndIf	
    
    If !Empty(QRY1->F2_VEND2) .and. AllTrim(QRY1->D2_FORNEC) $ '000366/000446' .And. QRY1->F2_VEND2 <> QRY1->F2_VEND1
	    nPos := Ascan(aEmiFatV,{|x| x[1]+x[3] == QRY1->F2_VEND2+QRY1->F2_VEND1 })
	    If nPos == 0
		    Aadd(aEmiFatV,{QRY1->F2_VEND2, QRY1->VALFAT, QRY1->F2_VEND1})
	    Else
		    aEmiFatV[nPos,2] += QRY1->VALFAT
	    EndIf	
    EndIf
	QRY1->(DbSkip())
EndDo	

dbSelectArea("QRY2")
QRY2->(dbGotop())

// Subtrai devoluções 
Do While QRY2->(!Eof())
	IncProc( "Processando... Devoluções " + QRY2->D1_DOC + "...")

	nPos := Ascan(aEmiFat,{|x| x[6]+x[3]+x[2]+x[1] == Eval(bVendedor,"QRY2")+QRY2->D2_CLIENTE+QRY2->D2_LOJA+QRY2->D1_DTDIGIT })

	If nPos == 0
		Aadd(aEmiFat,{QRY2->D1_DTDIGIT, QRY2->D2_LOJA, QRY2->D2_CLIENTE, QRY2->A1_NOME, QRY2->D1_TOTAL*-1, Eval(bVendedor,"QRY2")})
	Else
		aEmiFat[nPos,5] -= QRY2->D1_TOTAL
	EndIf
	If !Empty(QRY2->F2_VEND2) .and. AllTrim(QRY1->D2_FORNEC) $ '000366/000446' .And. QRY2->F2_VEND2 <> QRY2->F2_VEND1
	    nPos:=Ascan(aEmiFatV,{|x| x[1]+x[3] == QRY2->F2_VEND2+QRY2->F2_VEND1 })
	    If nPos == 0
		    Aadd(aEmiFatV,{QRY2->F2_VEND2, QRY2->D1_TOTAL*-1,QRY2->F2_VEND1})
	    Else
		    aEmiFatV[nPos,2] -= QRY2->D1_TOTAL
	    EndIf	
	EndIf
	QRY2->(DbSkip())	
EndDo

aSort( aEmiFat ,,, {|a,b| a[6]+a[1] < b[6]+b[1]} )
aSort( aEmiFatV ,,, {|a,b| a[3]+a[1] < b[3]+b[1]} )

Return
*--------------------------------*
Static Function RptDetail()                   
*--------------------------------*
Local _cTitulo	:= "Faturamento por cliente: " + SubStr(DToC(mv_par01),1,2) + ' a ' + DToC(mv_par02) 
Local _cDesc1	:= "Código-Lj-Nome                                                             Valor"
Local _cDesc2	:= ""
Local _nReg		:= 0
Local dDatAnt	:= ""
Local cCliAnt	:= ""
Local nTotDia	:= 0
Local nTotVend	:= 0
Local nTotGer	:= 0
Local cCampos	:= ""
Local aAcuFat	:= {}
Local nAcuCli	:= 0
Local nTotAcu	:= 0
Local nTotAcu2	:= 0
Local cVended	:= ""
Local cCodigo	:= ""

If cWorkFlow == "S"             
	If ("0401" $ cWCodEmp+cWCodFil)
		cArq := "/VENDEDORES/HQ/" + MV_PAR03 + Substr(Dtoc(Date()),1,2) + Substr(Dtoc(Date()),4,2) + ".029"
	ElseIf ("0404" $ cWCodEmp+cWCodFil)                                                                                                
		cArq := "/VENDEDORES/HQ-CD/" + MV_PAR03 + Substr(Dtoc(Date()),1,2) + Substr(Dtoc(Date()),4,2) + ".029"
	ElseIf ("0101" $ cWCodEmp+cWCodFil)                                                                  
		cArq := "/VENDEDORES/DIPROMED-MTZ/"+MV_PAR03+ Substr(Dtoc(Date()),1,2) + Substr(Dtoc(Date()),4,2) + ".029"			
	Else
		cArq := "/VENDEDORES/DIPROMED/" + MV_PAR03 + Substr(Dtoc(Date()),1,2) + Substr(Dtoc(Date()),4,2) + ".029"
	Endif
	cCampos		:= ""
	nHandle		:= Fcreate(cArq,0)
Else
	SetRegua(Len(aEmiFat))
EndIf

*                                                                                                    1                                                                                                   2                                                                                                   3
*          1         2         3         4         5         6         7         8         9         0         1         2         3         4         5         6         7         8         9         0         1         2         3         4         5         6         7         8         9         0         1         2         3         4         5         6
*01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
*999999-XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
*---------------------------------------------------------------------------------
*01/01/01
*Código-Lj-Nome                                                              Valor
*999999-99-XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX 999.999.999,99
*---------------------------------------------------------------------------------
*Total do Dia                                                       999.999.999,99
*---------------------------------------------------------------------------------
*Total Geral                                                        999.999.999,99
*---------------------------------------------------------------------------------

SA3->(DbSetorder(1))
SA3->(DbSeek(xFilial("SA3") + mv_par03))

If Len(aEmiFat) > 0     
	cVendAnt 	:= ""    
	dDatAnt 	:= aEmiFat[1,1]
	For xi:=1 to Len(aEmiFat)
	    // Impressao por Dia...
		If dDatAnt != aEmiFat[xi,1] .Or.(!Empty(cVendAnt).And. cVendAnt != aEmiFat[xi,6])
			aSort( aEmiOrd ,,, {|a,b| a[5] > b[5]} )
			If cWorkFlow == "N" 
				For ni:=1 To Len(aEmiOrd)
					IncRegua( "Imprimindo: " + aEmiOrd[ni,2] )
					If ni == 1
						@ li,000 PSay SubStr(aEmiOrd[ni,1],7,2) + '/' + SubStr(aEmiOrd[ni,1],5,2) + '/' + SubStr(aEmiOrd[ni,1],1,4)
						li++
					EndIf
					@ li,000 PSay aEmiOrd[ni,3] + '-' + aEmiOrd[ni,2] + '-' + Substr(aEmiOrd[ni,4],1,55)
					@ li,066 PSay aEmiOrd[ni,5] Picture "@E 999,999,999.99"
					nTotDia 	+= aEmiOrd[ni,5]
					nTotGer 	+= aEmiOrd[ni,5]
					nTotVend 	+= aEmiOrd[ni,5]
					li++
				Next
				@ li,000 PSay 'Total do Dia'
				@ li,066 PSay nTotDia Picture "@E 999,999,999.99"
				li++
				nTotDia := 0
				@ li,000 PSay Replic("-",Limite)
				li++
				aEmiOrd := {}         
			Else
				For ni:=1 To Len(aEmiOrd)
					If ni == 1
						cCampos := SubStr(aEmiOrd[ni,1],7,2) + '/' + SubStr(aEmiOrd[ni,1],5,2) + '/' + SubStr(aEmiOrd[ni,1],1,4) + Chr(13) + Chr(10)
						Fwrite(nHandle,cCampos)
						li++
						// Quebra de página
						If li > 56
							u_Pag029(_cTitulo,_cDesc1,_cDesc2,nHandle,cWorkFlow)
						EndIf
					EndIf
					cCampos := aEmiOrd[ni,3] + '-' + aEmiOrd[ni,2] + '-' + Substr(aEmiOrd[ni,4],1,55) + Space(01)
					cCampos += Transform(aEmiOrd[ni,5],"@E 999,999,999.99") + Chr(13) + Chr(10)
					Fwrite(nHandle,cCampos)
					nTotDia += aEmiOrd[ni,5]
					nTotGer += aEmiOrd[ni,5]
					li++
					// Quebra de página
					If li > 56
						u_Pag029(_cTitulo,_cDesc1,_cDesc2,nHandle,cWorkFlow)
					EndIf
					
				Next
				cCampos := 'Total do Dia' + Space(54)
				cCampos +=  Transform(nTotDia,"@E 999,999,999.99") + Chr(13) + Chr(10)
				Fwrite(nHandle,cCampos)
				li++
				// Quebra de página
				If li > 56
					u_Pag029(_cTitulo,_cDesc1,_cDesc2,nHandle,cWorkFlow)
				EndIf
				nTotDia := 0
				cCampos := Replic("-",Limite) + Chr(13) + Chr(10)
				Fwrite(nHandle,cCampos)
				li++
				// Quebra de página
				If li > 56
					u_Pag029(_cTitulo,_cDesc1,_cDesc2,nHandle,cWorkFlow)
				EndIf
				aEmiOrd := {}				
			EndIf
			dDatAnt := aEmiFat[xi,1]
		EndIf
		// Quebra de página / Vendedor
		If li > 56 .Or. cVendAnt != aEmiFat[xi,6] 
			If cVendAnt != aEmiFat[xi,6]
				If cWorkFlow == "N" .And. !Empty(cVendAnt)
			        nTotVd2 := 0
					If (nPos := aScan(aEmiFatV,{|x| x[3] == cVendAnt })) != 0
						If li > (56-8)
							u_Pag029(_cTitulo,_cDesc1,_cDesc2,nHandle,cWorkFlow) 
						EndIf
					    li+=2     
			            @ li,000 PSay 'Vendas técnicos:'
					    li+=2     
				        For id := nPos To Len(aEmiFatV)              
				        	If cVendAnt != aEmiFatV[id][3]
				        		exit
				        	EndIf
				        	SA3->(dbSeek(xFilial('SA3')+aEmiFatv[id][1]))
					        @ li,000 PSay aEmiFatv[id][1] +' - ' + AllTrim(SA3->A3_NOME)
					        @ li,066 PSay aEmiFatv[id][2] Picture "@E 999,999,999.99"
		       		        nTotVd2 += aEmiFatv[id][2]
					        li++
							If li > 56
								u_Pag029(_cTitulo,_cDesc1,_cDesc2,nHandle,cWorkFlow) 
							EndIf
					    Next id
					    @ li,066 PSay '--------------'
				        li++
		//		        @ li,030 PSay 'Total em R$ Tecno KC'
				        @ li,066 PSay nTotVd2 Picture "@E 999,999,999.99"
					EndIf
			        SA3->(dbSeek(xFilial('SA3')+cVendAnt))
			        li++
			        @ li,000 PSay "Vendedor: "+cVendAnt +' - ' + AllTrim(SA3->A3_NOME)
			        li++
		            @ li,000 psay 'Total Vendas:'
			        @ li,066 PSay nTotVend-nTotVd2 Picture "@E 999,999,999.99"
                EndIf
				cVendAnt	:= aEmiFat[xi,6]
				nTotVend	:= 0
			EndIf                       
				
			u_Pag029(_cTitulo,_cDesc1,_cDesc2,nHandle,cWorkFlow) 
	        SA3->(dbSeek(xFilial('SA3')+cVendAnt))
			If cWorkFlow == "N"
		        @ li,000 PSay "Vendedor: "+cVendAnt +' - ' + AllTrim(SA3->A3_NOME)
		        li++
		 	EndIf
		EndIf
		Aadd(aEmiOrd,{aEmiFat[xi,1],aEmiFat[xi,2],aEmiFat[xi,3],aEmiFat[xi,4],aEmiFat[xi,5]})
	Next	

	aSort( aEmiOrd ,,, {|a,b| a[5] > b[5]} )
	If cWorkFlow == "N"
		For ni:=1 To Len(aEmiOrd)
			IncRegua( "Imprimindo: " + aEmiOrd[ni,2] )
			If ni == 1
				@ li,000 PSay SubStr(aEmiOrd[ni,1],7,2) + '/' + SubStr(aEmiOrd[ni,1],5,2) + '/' + SubStr(aEmiOrd[ni,1],1,4)
				li++
			EndIf
			@ li,000 PSay aEmiOrd[ni,3] + '-' + aEmiOrd[ni,2] + '-' + Substr(aEmiOrd[ni,4],1,55)
			@ li,066 PSay aEmiOrd[ni,5] Picture "@E 999,999,999.99"
			nTotDia 	+= aEmiOrd[ni,5]
			nTotGer 	+= aEmiOrd[ni,5]
			nTotVend 	+= aEmiOrd[ni,5]
			li++
		Next
		@ li,000 PSay 'Total do Dia'
		@ li,066 PSay nTotDia Picture "@E 999,999,999.99"
		li++
		nTotDia := 0
		@ li,000 PSay Replic("-",Limite)
		li++
		aEmiOrd := {}
		// Total do Vendedor
        nTotVd2 := 0
		If (nPos := aScan(aEmiFatV,{|x| x[3] == cVendAnt })) != 0
			If li > (56-8)
				u_Pag029(_cTitulo,_cDesc1,_cDesc2,nHandle,cWorkFlow) 
			EndIf
		    li+=2     
            @ li,000 PSay 'Vendas técnicos:'
		    li+=2     
	        For id := nPos To Len(aEmiFatV)              
	        	If cVendAnt != aEmiFatV[id][3]
	        		exit
	        	EndIf
	        	SA3->(dbSeek(xFilial('SA3')+aEmiFatv[id][1]))
		        @ li,000 PSay aEmiFatv[id][1] +' - ' + AllTrim(SA3->A3_NOME)
		        @ li,066 PSay aEmiFatv[id][2] Picture "@E 999,999,999.99"
       		        nTotVd2 += aEmiFatv[id][2]
		        li++
				If li > 56
					u_Pag029(_cTitulo,_cDesc1,_cDesc2,nHandle,cWorkFlow) 
				EndIf
		    Next id
		    @ li,066 PSay '--------------'
	        li++
//		        @ li,030 PSay 'Total em R$ Tecno KC'
	        @ li,066 PSay nTotVd2 Picture "@E 999,999,999.99"
		EndIf
        SA3->(dbSeek(xFilial('SA3')+cVendAnt))
        li++
        @ li,000 PSay "Vendedor: "+cVendAnt +' - ' + AllTrim(SA3->A3_NOME)
        li++
            @ li,000 psay 'Total Vendas:'
        @ li,066 PSay nTotVend-nTotVd2 Picture "@E 999,999,999.99"
	Else
		For ni:=1 To Len(aEmiOrd)
			If ni == 1
				cCampos := SubStr(aEmiOrd[ni,1],7,2) + '/' + SubStr(aEmiOrd[ni,1],5,2) + '/' + SubStr(aEmiOrd[ni,1],1,4) + Chr(13) + Chr(10)
				Fwrite(nHandle,cCampos)
				li++
					// Quebra de página
					If li > 56
						u_Pag029(_cTitulo,_cDesc1,_cDesc2,nHandle,cWorkFlow)
					EndIf
			EndIf
			cCampos := aEmiOrd[ni,3] + '-' + aEmiOrd[ni,2] + '-' + Substr(aEmiOrd[ni,4],1,55) + Space(01)
			cCampos += Transform(aEmiOrd[ni,5],"@E 999,999,999.99") + Chr(13) + Chr(10)
			Fwrite(nHandle,cCampos)
			nTotDia += aEmiOrd[ni,5]
			nTotGer += aEmiOrd[ni,5]
			li++
			// Quebra de página
			If li > 56
				u_Pag029(_cTitulo,_cDesc1,_cDesc2,nHandle,cWorkFlow)
			EndIf
			
		Next
		cCampos := 'Total do Dia' + Space(54)
		cCampos +=  Transform(nTotDia,"@E 999,999,999.99") + Chr(13) + Chr(10)
		Fwrite(nHandle,cCampos)
		li++
					// Quebra de página
					If li > 56
						u_Pag029(_cTitulo,_cDesc1,_cDesc2,nHandle,cWorkFlow)
					EndIf
		nTotDia := 0
		cCampos := Replic("-",Limite) + Chr(13) + Chr(10)
		Fwrite(nHandle,cCampos)
		li++
					// Quebra de página
					If li > 56
						u_Pag029(_cTitulo,_cDesc1,_cDesc2,nHandle,cWorkFlow)
					EndIf
		aEmiOrd := {}
	EndIf

	// Quebra de página
	If li > 56
		u_Pag029(_cTitulo,_cDesc1,_cDesc2,nHandle,cWorkFlow)
	EndIf

	If li <> 80
		If cWorkFlow == "N"
			li++
			@ li,000 PSay Replic("*",Limite)
			li++
			@ li,000 PSay 'Total Geral'
			@ li,066 PSay nTotGer Picture "@E 999,999,999.99"
			li++     
			@ li,000 PSay Replic("*",Limite)
		Else
			cCampos := Replic("*",Limite) + Chr(13) + Chr(10)
			Fwrite(nHandle,cCampos)
			li++
			// Quebra de página
			If li > 56
				u_Pag029(_cTitulo,_cDesc1,_cDesc2,nHandle,cWorkFlow)
			EndIf
			cCampos := 'Total Geral' + Space(55)
			cCampos += Transform(nTotGer,"@E 999,999,999.99") + Chr(13) + Chr(10)
			Fwrite(nHandle,cCampos)
			li++
			// Quebra de página
			If li > 56
				u_Pag029(_cTitulo,_cDesc1,_cDesc2,nHandle,cWorkFlow)
			EndIf
			cCampos := Replic("*",Limite) + Chr(13) + Chr(10) + Chr(13) + Chr(10)
			Fwrite(nHandle,cCampos)
			li++
			// Quebra de página
			If li > 56
				u_Pag029(_cTitulo,_cDesc1,_cDesc2,nHandle,cWorkFlow)
			EndIf
			
			If len(aEmiFatv) > 0
				li++     
	            If li > 56
				    u_Pag029(_cTitulo,_cDesc1,_cDesc2,nHandle,cWorkFlow)
			    EndIf
			    cCampos := 'Vendas técnicos:' + Chr(13) + Chr(10)  + Chr(13) + Chr(10)
			    Fwrite(nHandle,cCampos)
			    li+=2     
		        nTotVd2 := 0
			    For id:=1 to len(aEmiFatv)
			         SA3->(dbSeek(xFilial('SA3')+aEmiFatv[id][1]))
		             If li > 56
				         u_Pag029(_cTitulo,_cDesc1,_cDesc2,nHandle,cWorkFlow)
			         EndIf
		
			         cCampos := aEmiFatv[id][1] +' - ' + SA3->A3_NOME+ Space(17)
			         cCampos += Transform(aEmiFatv[id][2],"@E 999,999,999.99") + Chr(13) + Chr(10)
			         Fwrite(nHandle,cCampos)
			         
       		         nTotVd2 += aEmiFatv[id][2]
			         li++
			    Next id

		        If li > 56
				     u_Pag029(_cTitulo,_cDesc1,_cDesc2,nHandle,cWorkFlow)
			    EndIf
			    cCampos := space(66) + '--------------' + Chr(13)+Chr(10)
			    Fwrite(nHandle,cCampos)
		        li++
		        
		        If li > 56
				     u_Pag029(_cTitulo,_cDesc1,_cDesc2,nHandle,cWorkFlow)
			    EndIf
			    cCampos := space(66)
			    cCampos += Transform(nTotVd2,"@E 999,999,999.99") + Chr(13) + Chr(10)
			    Fwrite(nHandle,cCampos)
		        li++
		        
	            SA3->(DbSeek(xFilial("SA3") + mv_par03))
		        If li > 56
				     u_Pag029(_cTitulo,_cDesc1,_cDesc2,nHandle,cWorkFlow)
			    EndIf
			    cCampos := 'Vendedor:' +SA3->A3_COD +'-' + SA3->A3_NOME+ Space(10)
			    cCampos += Transform(nTotGer-nTotVd2,"@E 999,999,999.99") + Chr(13) + Chr(10) +Chr(13) + Chr(10)
			    Fwrite(nHandle,cCampos)
		        li++
		        
			EndIf
		EndIf	
	EndIf
	
	If cWorkFlow == "N"

		aSort( aEmiFat ,,, {|a,b| a[6]+a[3] < b[6]+b[3]} )
		cCodCli := aEmiFat[1,3]
		For ni := 1 to Len(aEmiFat)           
			If (nPos := aScan(aAcuFat,{|x| x[5]+x[1] == aEmiFat[ni][6]+aEmiFat[ni][3]})) == 0
				Aadd(aAcuFat,{aEmiFat[ni,3], Substr(aEmifat[ni,4],1,55), aEmiFat[ni,5], aEmiFat[ni,2], aEmiFat[ni][6]})
			Else 
				aAcuFat[nPos][3] += aEmiFat[ni,5]
			EndIf
		Next
		li := U_MYCABEC(_cTitulo,_cDesc1,_cDesc2,nHandle,cWorkFlow)
		li+=2
		@ li,000 PSay Replic("*",Limite)
		li++
		@ li,000 PSay "Acumulado por cliente de " + SubStr(dtos(mv_par01),7,2) + '/' + SubStr(dtos(mv_par01),5,2) + '/' + SubStr(dtos(mv_par01),1,4) + " até " + SubStr(dtos(mv_par02),7,2) + '/' + SubStr(dtos(mv_par02),5,2) + '/' + SubStr(dtos(mv_par02),1,4)
		li++
		@ li,000 PSay Replic("-",Limite)
		li++
		// Ordena o Array por Cod. Vendedor Ascendente + Valor do Cliente Descendente
		aSort( aAcuFat ,,, {|a,b| Iif(a[5]==b[5], a[3]>b[3], a[5]<b[5] )} )
		
		cVendAnt := ""
		For ni := 1 to Len(aAcuFat)
			If cVendAnt != aAcuFat[ni,5]
				// Total do Vendedor     
		        nTotVd2 	:= 0
				If (nPos := aScan(aEmiFatV,{|x| x[3] == cVendAnt })) != 0    
					If li > (56-8)
						li := U_MYCABEC(_cTitulo,_cDesc1,_cDesc2,nHandle,cWorkFlow)
					EndIf
			        li++
		            @ li,000 PSay 'Vendas técnicos:'
				    li++     
			        For id := nPos To Len(aEmiFatV)              
			        	If cVendAnt != aEmiFatV[id][3]
			        		exit
			        	EndIf
			        	SA3->(dbSeek(xFilial('SA3')+aEmiFatv[id][1]))
				        @ li,000 PSay aEmiFatv[id][1] +' - ' + AllTrim(SA3->A3_NOME)
				        @ li,066 PSay aEmiFatv[id][2] Picture "@E 999,999,999.99"
	       		        nTotVd2 += aEmiFatv[id][2]
				        li++
						If li > 56
							li := U_MYCABEC(_cTitulo,_cDesc1,_cDesc2,nHandle,cWorkFlow)
						EndIf
				    Next id
			        li++
		//		        @ li,030 PSay 'Total em R$ Tecno KC'
			        @ li,066 PSay nTotVd2 Picture "@E 999,999,999.99"
				EndIf    
				If !Empty(cVendAnt)
				    @ li,066 PSay '--------------'
					li++
					@ li,000 PSay 'Total de Vendas'
			        @ li,066 PSay nTotVend-nTotVd2 Picture "@E 999,999,999.99"
			  	EndIf

				nTotVend 	:= 0
				nTotAcu2 	+= nTotVd2
				cVendAnt 	:= aAcuFat[ni,5]
				SA3->(dbSeek(xFilial('SA3')+aAcuFat[ni,5]))
				li+=2
				@ li,000 PSay 'Vendedor: ' + SA3->A3_COD +'-'+SA3->A3_NOME
				li+=2
			EndIf
			@ li,000 PSay aAcuFat[ni,1] + "-" + aAcuFat[ni,4] + "-" + aAcuFat[ni,2]
			@ li,066 PSay aAcuFat[ni,3] Picture "@E 999,999,999.99"
			li++
			nTotVend	+= aAcuFat[ni,3]
			nTotAcu 	+= aAcuFat[ni,3]
			If li > 60
				li := U_MYCABEC(_cTitulo,_cDesc1,_cDesc2,nHandle,cWorkFlow)
			EndIf
		Next
		// Total do Vendedor
        nTotVd2 := 0
		If (nPos := aScan(aEmiFatV,{|x| x[3] == cVendAnt })) != 0
			If li > (56-8)
				li := U_MYCABEC(_cTitulo,_cDesc1,_cDesc2,nHandle,cWorkFlow)
			EndIf
	        li++
            @ li,000 PSay 'Vendas técnicos:'
		    li++     
	        For id := nPos To Len(aEmiFatV)              
	        	If cVendAnt != aEmiFatV[id][3]
	        		exit
	        	EndIf
	        	SA3->(dbSeek(xFilial('SA3')+aEmiFatv[id][1]))
		        @ li,000 PSay aEmiFatv[id][1] +' - ' + AllTrim(SA3->A3_NOME)
		        @ li,066 PSay aEmiFatv[id][2] Picture "@E 999,999,999.99"
       		        nTotVd2 += aEmiFatv[id][2]
		        li++
				If li > 56
					li := U_MYCABEC(_cTitulo,_cDesc1,_cDesc2,nHandle,cWorkFlow)
				EndIf
		    Next id
	        li++
//		        @ li,030 PSay 'Total em R$ Tecno KC'
	        @ li,066 PSay nTotVd2 Picture "@E 999,999,999.99" 
		EndIf
	    @ li,066 PSay '--------------'
		li++
		@ li,000 PSay 'Total de Vendas'
        @ li,066 PSay nTotVend-nTotVd2 Picture "@E 999,999,999.99"
		nTotAcu2 += nTotVd2

		li+=2
		@ li,000 PSay Replic("-",Limite)
		li++
		@ li,000 PSay "Total Geral do Acumulado"
		@ li,066 PSay nTotAcu Picture "@E 999,999,999.99"
		li++
		@ li,000 PSay "Total Geral Técnico"
		@ li,066 PSay nTotAcu2 Picture "@E 999,999,999.99"
		li++
		@ li,000 PSay "Total Geral"
		@ li,066 PSay nTotAcu-nTotAcu2 Picture "@E 999,999,999.99"
		li++
		@ li,000 PSay Replic("*",Limite)

		li+=2
		@ li,000 PSAY 'Impresso em '+DtoC(DATE())+' as '+TIME()
	
	Else
	
		aSort( aEmiFat ,,, {|a,b| a[3] > b[3]} )
		cCodCli := aEmiFat[1,3]
		For ni := 1 to Len(aEmiFat)   
			If aEmiFat[ni,3] <> cCodCli
				xi := ni - 1
				Aadd(aAcuFat,{aEmiFat[xi,3], Substr(aEmifat[xi,4],1,55), nAcuCli, aEmiFat[xi,2]})
				cCodCli := aEmiFat[ni,3]
				nAcuCli := 0
			EndIf
			nAcuCli += aEmiFat[ni,5]
		Next
		
		//Inclui o último item do array
		xi := ni - 1
		Aadd(aAcuFat,{aEmiFat[xi,3], Substr(aEmifat[xi,4],1,55), nAcuCli, aEmiFat[xi,2]})
		For li:=li to 60
			cCampos :=  ''
			Fwrite(nHandle,cCampos)
		Next	
		// Quebra de página
		If li > 56
			u_Pag029(_cTitulo,_cDesc1,_cDesc2,nHandle,cWorkFlow)
		EndIf
		cCampos := Replic("*",Limite)  + Chr(13) + Chr(10)
		Fwrite(nHandle,cCampos)
		li++
		// Quebra de página
		If li > 56
			u_Pag029(_cTitulo,_cDesc1,_cDesc2,nHandle,cWorkFlow)
		EndIf
		cCampos := "Acumulado por cliente de " + SubStr(dtos(mv_par01),7,2) + '/' + SubStr(dtos(mv_par01),5,2) + '/' + SubStr(dtos(mv_par01),1,4) + " até " + SubStr(dtos(mv_par02),7,2) + '/' + SubStr(dtos(mv_par02),5,2) + '/' + SubStr(dtos(mv_par02),1,4) + Chr(13) + Chr(10)
		Fwrite(nHandle,cCampos)
		li++
		// Quebra de página
		If li > 56
			u_Pag029(_cTitulo,_cDesc1,_cDesc2,nHandle,cWorkFlow)
		EndIf
		cCampos := Replic("-",Limite) + Chr(13) + Chr(10)
		Fwrite(nHandle,cCampos)
		li++
		// Quebra de página
		If li > 56
			u_Pag029(_cTitulo,_cDesc1,_cDesc2,nHandle,cWorkFlow)
		EndIf
		aSort( aAcuFat ,,, {|a,b| a[3] > b[3]} )

		For ni := 1 to Len(aAcuFat)
			cCampos := aAcuFat[ni,1] + "-" + aAcuFat[ni,4] + "-" + aAcuFat[ni,2]
			cCampos += Space(01) + Transform(aAcuFat[ni,3],"@E 999,999,999.99") + Chr(13) + Chr(10)
			Fwrite(nHandle,cCampos)
			li++
			// Quebra de página
			If li > 56
				u_Pag029(_cTitulo,_cDesc1,_cDesc2,nHandle,cWorkFlow)
			EndIf
			nTotAcu += aAcuFat[ni,3]
			If li > 60
				li := U_MYCABEC(_cTitulo,_cDesc1,_cDesc2,nHandle,cWorkFlow)
				cCampos := 'Vendedor: ' + SA3->A3_COD +'-'+SA3->A3_NOME + Chr(13) + Chr(10) + Chr(13) + Chr(10)
				Fwrite(nHandle,cCampos)
				li+=2
				// Quebra de página
				If li > 56
					u_Pag029(_cTitulo,_cDesc1,_cDesc2,nHandle,cWorkFlow)
				EndIf
			EndIf
			
		Next
		cCampos := Replic("-",Limite) + Chr(13) + Chr(10)
		Fwrite(nHandle,cCampos)
		li++
		// Quebra de página
		If li > 56
			u_Pag029(_cTitulo,_cDesc1,_cDesc2,nHandle,cWorkFlow)
		EndIf
		cCampos := "Total Geral do Acumulado =>"
		cCampos += Space(39) + Transform(nTotAcu,"@E 999,999,999.99") + Chr(13) + Chr(10)
		Fwrite(nHandle,cCampos)
		li++
		// Quebra de página
		If li > 56
			u_Pag029(_cTitulo,_cDesc1,_cDesc2,nHandle,cWorkFlow)
		EndIf
		cCampos := Replic("*",Limite) + Chr(13) + Chr(10) + Chr(13) + Chr(10) + Chr(13) + Chr(10)
		Fwrite(nHandle,cCampos)
		li+=3     
		If len(aEmiFatv) > 0
			li++     
	        If li > 56
		        u_Pag029(_cTitulo,_cDesc1,_cDesc2,nHandle,cWorkFlow)
		    EndIf
		    cCampos := 'Vendas técnicos:' + Chr(13) + Chr(10)  + Chr(13) + Chr(10)
		    Fwrite(nHandle,cCampos)
		    li++     
	        nTotVd2 := 0
		    For id:=1 to len(aEmiFatv)
		         SA3->(dbSeek(xFilial('SA3')+aEmiFatv[id][1]))
	             If li > 56
			         u_Pag029(_cTitulo,_cDesc1,_cDesc2,nHandle,cWorkFlow)
		         EndIf
		         cCampos := aEmiFatv[id][1] +' - ' + SA3->A3_NOME + Space(17)
		         cCampos += Transform(aEmiFatv[id][2],"@E 999,999,999.99") + Chr(13) + Chr(10)
  	             Fwrite(nHandle,cCampos)
   		         nTotVd2 += aEmiFatv[id][2]
		         li++
		    Next id

	        If li > 56
			     u_Pag029(_cTitulo,_cDesc1,_cDesc2,nHandle,cWorkFlow)
		    EndIf
		    cCampos := space(66) + '--------------' + Chr(13)+Chr(10)
		    Fwrite(nHandle,cCampos)
	        li++
	        If li > 56
			     u_Pag029(_cTitulo,_cDesc1,_cDesc2,nHandle,cWorkFlow)
		    EndIf
		    cCampos := space(66)
		    cCampos += Transform(nTotVd2,"@E 999,999,999.99") + Chr(13) + Chr(10)
		    Fwrite(nHandle,cCampos)
	        li++
	        
            SA3->(DbSeek(xFilial("SA3") + mv_par03))
	        If li > 56
			     u_Pag029(_cTitulo,_cDesc1,_cDesc2,nHandle,cWorkFlow)
		    EndIf
		    cCampos := 'Vendedor:' + SA3->A3_COD +'-'+SA3->A3_NOME + space(10)
		    cCampos += Transform(nTotAcu-nTotVd2,"@E 999,999,999.99") + Chr(13) + Chr(10) + Chr(13) + Chr(10)
		    Fwrite(nHandle,cCampos)
	        li++
	        
		EndIf
		// Quebra de página
		If li > 56
			u_Pag029(_cTitulo,_cDesc1,_cDesc2,nHandle,cWorkFlow)
		EndIf
	
		cCampos := Space(Limite-(Len('Impresso em '+DtoC(DATE())+' às '+TIME())))
		cCampos += 'Impresso em '+DtoC(DATE())+' às '+TIME() + chr(13) + chr(10)
		Fwrite(nHandle,cCampos)
		li+=2
		// Quebra de página
		If li > 56
			u_Pag029(_cTitulo,_cDesc1,_cDesc2,nHandle,cWorkFlow)
		EndIf
		cCampos := "Padrões de impressão p/ bloco de notas (NotePad):" + chr(13) + chr(10)
		cCampos += "Fonte Courier - Normal - 10 " + chr(13) + chr(10)
		cCampos += "Papel Carta 21,59 X 27,94cm " + chr(13) + chr(10)
		cCampos += "Margens: Direita 20 , Esquerda 20 , Superior 25 e Inferior 20"
		Fwrite(nHandle,cCampos)
		cCampos := ""
		
	EndIf
	
Else

	If cWorkFlow == "N"	
		@ li,000 PSay Replic("-",Limite)
		li++
		@ li,000 PSay "Não foi localizado nenhum registro no período de " + SubStr(dtos(mv_par01),7,2) + '/' + SubStr(dtos(mv_par01),5,2) + '/' + SubStr(dtos(mv_par01),1,4) + " até " + SubStr(dtos(mv_par02),7,2) + '/' + SubStr(dtos(mv_par02),5,2) + '/' + SubStr(dtos(mv_par02),1,4)
		li++
		@ li,000 PSay Replic("-",Limite)
		li+=2
		@ li,000 PSAY 'Impresso em '+DtoC(DATE())+' as '+TIME()
	
	Else
		// Quebra de página
		If li > 56
			u_Pag029(_cTitulo,_cDesc1,_cDesc2,nHandle,cWorkFlow)
		EndIf
		cCampos := Replic("-",Limite)  + Chr(13) + Chr(10)
		Fwrite(nHandle,cCampos)
		li++
		// Quebra de página
		If li > 56
			u_Pag029(_cTitulo,_cDesc1,_cDesc2,nHandle,cWorkFlow)
		EndIf
		cCampos := "Não foi localizado nenhum registro no período de " + SubStr(dtos(mv_par01),7,2) + '/' + SubStr(dtos(mv_par01),5,2) + '/' + SubStr(dtos(mv_par01),1,4) + " até " + SubStr(dtos(mv_par02),7,2) + '/' + SubStr(dtos(mv_par02),5,2) + '/' + SubStr(dtos(mv_par02),1,4) + Chr(13) + Chr(10)
		Fwrite(nHandle,cCampos)
		li++
		// Quebra de página
		If li > 56
			u_Pag029(_cTitulo,_cDesc1,_cDesc2,nHandle,cWorkFlow)
		EndIf
		cCampos := Replic("-",Limite) + Chr(13) + Chr(10)
		Fwrite(nHandle,cCampos)
		li++
		// Quebra de página
		If li > 56
			u_Pag029(_cTitulo,_cDesc1,_cDesc2,nHandle,cWorkFlow)
		EndIf
		cCampos := Replic("-",Limite) + Chr(13) + Chr(10)
		Fwrite(nHandle,cCampos)
		li+=2
		// Quebra de página
		If li > 56
			u_Pag029(_cTitulo,_cDesc1,_cDesc2,nHandle,cWorkFlow)
		EndIf
		cCampos := Space(Limite-(Len('Impresso em '+DtoC(DATE())+' às '+TIME())))
		cCampos += 'Impresso em '+DtoC(DATE())+' às '+TIME() + chr(13) + chr(10)
		Fwrite(nHandle,cCampos)
		cCampos := "Padrões  de impressão p/ Word (qualquer versão):" + chr(13) + chr(10)
		cCampos += "Fonte Courier - Normal - 10 " + chr(13) + chr(10)
		cCampos += "Papel Carta 21,59 X 27,94cm " + chr(13) + chr(10)
		cCampos += "Margens: Direita 20 , Esquerda 20 , Superior 25 e Inferior 20"
		Fwrite(nHandle,cCampos)
		cCampos := ""
		Fclose(nHandle)	
	EndIf
EndIf

QRY1->(dbCloseArea())
QRY2->(dbCloseArea())

Return(.T.)


/*==========================================================================\
|Programa  |VALIDPERG| Autor | Rafael de Campos Falco  | Data ³ 04/06/2004  |
|===========================================================================|
|Desc.     | Inclui as perguntas caso nao existam                           |
|===========================================================================|
|Sintaxe   | VALIDPERG                                                      |
|===========================================================================|
|Uso       | Especifico DIPROMED                                            |
|===========================================================================|
|Histórico | DD/MM/AA - Descrição da alteração                              |
\==========================================================================*/

Static Function AjustaSX1(cPerg)
_sAlias := Alias()
dbSelectArea("SX1")
dbSetOrder(1)                                                                                   

aRegs:={}

//------------ Grupo/Ordem/Pergunta/PERGING/PERGESP/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05/F3

aAdd(aRegs,{cPerg,"01","Da Data            ?","","","mv_ch1","D",8,0,0,"G","","mv_par01","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"02","Ate a Data         ?","","","mv_ch2","D",8,0,0,"G","","mv_par02","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"03","Vendedor           ?","","","mv_ch3","C",6,0,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","",'SA3'})
aAdd(aRegs,{cPerg,"04","Grupo Clientes     ?","","","mv_ch4","C",6,0,0,"G","","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","",'ACY'})

For i:=1 to Len(aRegs)
	If !dbSeek(cPerg+aRegs[i,2])
		RecLock("SX1",.T.)
		For j:=1 to FCount()
			If j <= Len(aRegs[i])
				FieldPut(j,aRegs[i,j])
			Endif
		Next
		MsUnlock()
	Endif                              
Next

dbSelectArea(_sAlias)
Return

// Quebra de página
User Function Pag029(_cTitulo,_cDesc1,_cDesc2,nHandle,cWorkFlow)
	li := U_MYCABEC(_cTitulo,_cDesc1,_cDesc2,nHandle,cWorkFlow)
	If cWorkFlow != "N"
		li++
		cCampos := Chr(13) + Chr(10) + 'Vendedor: ' + SA3->A3_COD +'-'+SA3->A3_NOME  + Chr(13) + Chr(10)  + Chr(13) + Chr(10)
		Fwrite(nHandle,cCampos)
		li+=2
	EndIf	
Return
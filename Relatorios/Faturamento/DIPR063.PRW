/*================================================================================\
|Programa  | DIPR063   | Autor | Maximo Canuto V. Neto    | Data | 26/03/2007     |
|=================================================================================|
|Descrição | Faturamento por cliente/Produto mes a mes                            |
|=================================================================================|
|Sintaxe   | DIPR063                                                              |
|=================================================================================|
|Uso       | Especifico DIPROMED                                                  |
|=================================================================================|
|=================================================================================|
|Histórico |   /  /   -                                                           |
|Maximo    | 23/08/07 - Incluir tratamento para gerar relatírio p/ vendedor 2     | 
|Maximo    | 15/10/09 - Alterado o caminho do arquivo e PREPARE ENVIRONMENT       | 
\================================================================================*/

#INCLUDE "RWMAKE.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "FILEIO.CH"

#IFNDEF WINDOWS
	#DEFINE PSay Say
#ENDIF

User Function DIPR063(aWork)
Local _xArea := GetArea()
Local _aFeriad		:= {}     
Local cUserAut      := ""

Private tamanho	:= "P"
Private limite		:= 80
Private titulo		:= OemTOAnsi("Faturamento por cliente/Produto",72)
Private cDesc1		:= (OemToAnsi("Este programa tem como objetivo emitir um relat¢rio",72))
Private cDesc2		:= (OemToAnsi("de Faturamento por cliente/Produto.",72))
Private cDesc3		:= (OemToAnsi(" ",72))
Private aReturn	:= {"Bco A4", 1,"Faturamento", 1, 2, 1,"",1}
Private nomeprog	:= "DIPR063"

// Private cPerg		:= "DIPR63"
// FPADR(cPerg, cArq, cCampo, cTipo)  - Para ajustar o tamanho das perguntas no SX1- uso generico
PRIVATE cPerg    	
Private nLastKey	:= 0
Private lEnd		:= .F.
Private li			:= 67
Private wnrel		:= "DIPR063"
Private M_PAG		:= 1
Private cString	:= "SF2"
Private _cRanking	:= ''
Private aEmiFat	:= {}
Private aEmiFatv:= {} // JBS 06/10/2006 
Private aEmiOrd	:= {}
Private cWorkFlow := ""
Private cWCodEmp  := ""  
Private cWCodFil  := "" 
Private nHandle	:= ""  
Private _dDatIni   := ""
Private _dDatFim   := ""
//Tratamento para workflow
If ValType(aWork) <> 'A'
	cWorkFlow := "N"    
	cWCodEmp  := cEmpAnt
    cWCodFil  := cFilAnt 
    U_DIPPROC(ProcName(0),U_DipUsr()) // JBS 13/12/2005 - Gravando o nome do Programa no SZU
    cPerg  := U_FPADR( "DIPR63","SX1","SX1->X1_GRUPO"," " ) //Função criada por Sandro em 19/11/09.
Else
	cWorkFlow := aWork[1]    
	cWCodEmp  := aWork[3]
    cWCodFil  := aWork[4]       
	If cWorkFlow == "S"                                                                
		PREPARE ENVIRONMENT EMPRESA cWCodEmp FILIAL cWCodFil FUNNAME "DIPR063" //TABLES "SA3", "SA2", "SX5"
	EndIf
EndIf

If cWorkFlow == "N" 

	// MCVN - 04/05/09    
	cUserAut      := GetMV("MV_URELFAT") // MCVN - 04/05/09 
	If !(Upper(U_DipUsr()) $ cUserAut)
		Alert(Upper(U_DipUsr())+", você não tem autorização para utilizar esta rotina. Qualquer dúvida falar com Eriberto!","Atenção")	
		Return()
	EndIF 

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
/*
	dDatSis  := Date()-1 		// Data atual menos um dia 
	_dDatIni := FirstDay(dDatSis)	// Primeiro dia
	_dDatFim := LastDay (dDatSis)	// Último Dia    
                                                      
  
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
	
/*	// Verificação da data se o dia é feriado, se sim voltar (-1) dia
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
	EndIf*/
	     

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
	MV_PAR04 := 1    - Fim da rotina de tratamento de 3 dias uteis*/
	
		/*==========================================================================\
	| Este relatório executado via WORKFLOW, deverá usar as datas MV_PAR01 e    |
	| MV_PAR02. A data INICIAL deverá ser calculada da seguinte forma, a data   |
	| atual do sistema DDATABASE()-1, deverá voltar sempre um dia, com uma      |
	| ressalva de quando for o dia primeiro ele deverá retornar ao mês anterior |
	| executando o relatório no primeiro e último dia do mês anterior           |
	|                                                                           |
	\==========================================================================*/

	dDatSis  := Date()-1 		// Data atual menos um dia 
	_dDatIni := FirstDay(dDatSis)	// Primeiro dia
	_dDatFim := LastDay (dDatSis)	// Último Dia
                                                      
	MV_PAR01 := _dDatIni
	MV_PAR02 := _dDatFim
	MV_PAR03 := aWork[2]
	MV_PAR04 := ""                                                                           



	If Empty( Posicione("SA3",1,xFilial("SA3")+MV_PAR03,"A3_DESLIG") )
		ConOut(' ')
	    ConOut('Faturamento por cliente - Vendedor ' + MV_PAR03 + ' Inicio em '+dToc(date())+' as '+Time())
		ConOut(' ')
	
		RunProc()
		RptDetail()	
	
		ConOut(' ')
	    ConOut('Faturamento por cliente - Vendedor ' + MV_PAR03 + ' Concluido em '+dToc(date())+' as '+Time())
		ConOut(' ')
	EndIf
/*	
	ConOut("--------------------------")
	ConOut('Inicio - ' + dToc(date())+' - '+Time())
	ConOut("--------------------------")
	
	RunProc()
	RptDetail()	

	ConOut("------------------------")
	ConOut('Fim - ' + dToc(date())+' - '+Time())
	ConOut("------------------------")
*/
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

ProcRegua(1000)
For _x := 1 to 200
	IncProc()
Next

//*********************** QUERY DO FATURAMENTO GERAL **************************************
QRY1 := "SELECT D2_DOC, (D2_TOTAL + D2_VALFRE) TOTAL, D2_EMISSAO, D2_CLIENTE, D2_LOJA, A1_NOME, F2_VEND2, D2_FORNEC, D2_COD, D2_QUANT, D2_PRCVEN, D2_PEDIDO, D2_COMIS1, B1_DESC,F2_TRANSP, F2_DATASAI, A4_NOME, F2_VEND1 "
QRY1 += " FROM " +  RetSQLName('SF2') + ',' + RetSQLName('SA1')  + ',' + RetSQLName('SF4')  + ',' + RetSQLName('SD2') + ',' + RetSQLName('SB1') + ',' + RetSQLName('SA4') 
QRY1 += " WHERE F2_EMISSAO BETWEEN '" + DTOS(MV_PAR01) + "' AND '" + DTOS(MV_PAR02) +"'"
//QRY1 += " AND F2_VEND1 = '" + MV_PAR03 + "'"

If !Empty(MV_PAR03)
	QRY1 += " AND (F2_VEND1 = '" + MV_PAR03 + "' AND (F2_VEND2 = ' ' OR D2_FORNEC <> '000996') "
	QRY1 += " OR (F2_VEND2 = '" + MV_PAR03 + "' and D2_FORNEC IN ('000366','000446','000996')))"
EndIf
   
// MCVN - 08/03/2010
QRY1 += " AND F2_FILIAL = '"+xFilial("SF2")+"'" 
QRY1 += " AND F4_FILIAL = '"+xFilial("SF4")+"'" 
QRY1 += " AND B1_FILIAL = '"+xFilial("SB1")+"'"                                
QRY1 += " AND D2_FILIAL = '"+xFilial("SD2")+"'" 
QRY1 += " AND F2_CLIENTE = A1_COD"
QRY1 += " AND F2_FILIAL = D2_FILIAL"
QRY1 += " AND F2_DOC = D2_DOC"
QRY1 += " AND F2_SERIE = D2_SERIE"
QRY1 += " AND D2_TES = F4_CODIGO"
QRY1 += " AND D2_COD = B1_COD"
QRY1 += " AND F4_DUPLIC = 'S'"
QRY1 += " AND F2_TRANSP = A4_COD" 

If U_ListVend() != ''
	QRY1 += " AND (F2_VEND1 " + U_ListVend() + " AND (F2_VEND2 = ' ' OR D2_FORNEC <> '000996') "
	QRY1 += " OR (F2_VEND2 " + U_ListVend() + " and D2_FORNEC IN ('000366','000446','000996')))" 
EndIf

If !Empty(MV_PAR04)
	QRY1 += " AND A1_GRPVEN = '" + MV_PAR04 + "'"
EndIf
QRY1 += " AND " + RetSQLName('SF2') + ".D_E_L_E_T_ <> '*' AND "
QRY1 += RetSQLName('SD2') + ".D_E_L_E_T_ <> '*' AND "
QRY1 += RetSQLName('SF4') + ".D_E_L_E_T_ <> '*' AND "
QRY1 += RetSQLName('SB1') + ".D_E_L_E_T_ <> '*' AND "
QRY1 += RetSQLName('SA4') + ".D_E_L_E_T_ <> '*' AND "
QRY1 += RetSQLName('SA1') + ".D_E_L_E_T_ <> '*' "
QRY1 += "ORDER BY D2_EMISSAO, D2_CLIENTE"
memowrite('DIPR063A.SQL',QRY1)

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


ProcRegua(1000)
For _x := 1 to 200
	IncProc()
Next

QRY2 := "SELECT D2_DOC, D1_TOTAL, D1_DTDIGIT, D2_CLIENTE, D2_LOJA, A1_NOME, F2_VEND2, D2_FORNEC,  D2_COD, D2_QUANT, D2_PRCVEN, D2_PEDIDO, B1_DESC, D1_DOC, D1_NFORI, F2_VEND1 "
QRY2 += " FROM " +  RetSQLName('SD1') + ',' + RetSQLName('SD2') + ',' + RetSQLName('SF4') + ',' + RetSQLName('SF2') + ',' + RetSQLName('SA1') + ',' + RetSQLName('SB1')
QRY2 += " WHERE D1_DTDIGIT BETWEEN '" + DTOS(MV_PAR01) + "' AND '" + DTOS(MV_PAR02) +"'"
QRY2 += " AND D1_TIPO = 'D'"           
// MCVN - 08/03/2010
QRY2 += " AND F2_FILIAL = '"+xFilial("SF2")+"'" 
QRY2 += " AND D2_FILIAL = '"+xFilial("SD2")+"'" 
QRY2 += " AND D1_FILIAL = '"+xFilial("SD1")+"'" 
QRY2 += " AND F4_FILIAL = '"+xFilial("SF4")+"'" 
QRY2 += " AND B1_FILIAL = '"+xFilial("SB1")+"'" 
QRY2 += " AND A1_FILIAL = '"+xFilial("SA1")+"'" 
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
QRY2 += " AND D1_COD = B1_COD"    

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
QRY2 += " AND " + RetSQLName('SB1') + ".D_E_L_E_T_ <> '*'"
QRY2 += "ORDER BY D1_DTDIGIT, D2_CLIENTE"
memowrite('DIPR063B.SQL',QRY2)

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

	Aadd(aEmiFat,{QRY1->D2_EMISSAO, QRY1->D2_DOC,QRY1->D2_CLIENTE, QRY1->D2_LOJA, QRY1->A1_NOME, QRY1->D2_QUANT, QRY1->D2_PRCVEN, QRY1->TOTAL, QRY1->D2_COD, QRY1->B1_DESC, QRY1->D2_PEDIDO, QRY1->F2_VEND2, QRY1->D2_FORNEC,"","A",QRY1->F2_TRANSP,QRY1->A4_NOME,QRY1->F2_DATASAI, Eval(bVendedor,"QRY1"), QRY1->D2_COMIS1 })
    
QRY1->(DbSkip())
EndDo	
QRY1->(dbCloseArea())


dbSelectArea("QRY2")
QRY2->(dbGotop())
// Inclui devoluções 
Do While QRY2->(!Eof())
	IncProc( "Processando... Devoluções " + QRY2->D1_DOC + "...")

	Aadd(aEmiFat,{QRY2->D1_DTDIGIT, QRY2->D1_DOC,QRY2->D2_CLIENTE, QRY2->D2_LOJA, QRY2->A1_NOME, QRY2->D2_QUANT, QRY2->D2_PRCVEN, QRY2->D1_TOTAL, QRY2->D2_COD, QRY2->B1_DESC, QRY2->D2_PEDIDO, QRY2->F2_VEND2, QRY2->D2_FORNEC,QRY2->D1_NFORI,"B","","","", Eval(bVendedor,"QRY2"),""})
	
QRY2->(DbSkip())	
EndDo
QRY2->(dbCloseArea())

//aSort(aEmiFat,,,{|a, b| a[3]+a[4]+a[15]+a[1]+a[2] < b[3]+b[4]+b[15]+b[1]+b[2]})
//aSort(aEmiFat,,,{|a, b| a[3]+a[4]+a[1]+a[15]+a[2] < b[3]+b[4]+b[1]+b[15]+b[2]})
aSort(aEmiFat,,,{|a, b| a[19]+a[3]+a[4]+a[1]+a[15]+a[2] < b[19]+b[3]+b[4]+b[1]+b[15]+b[2]})
Return
*--------------------------------*
Static Function RptDetail()                   
*--------------------------------*
Local _cTitulo	  := "Faturamento por cliente/Produto: " + SubStr(DToC(mv_par01),1,2) + ' a ' + DToC(mv_par02) 
Local _cDesc1	  := "Código-Lj-Nome                                          Emissão     Nota  Pedido"
Local _cDesc2	  := "Produto-Descrição                       Comis.  Quant.  Valor Unit.  Valor Total"
Local _nReg		  := 0
Local dDatAnt	  := ""
Local cCliAnt	  := ""
Local cVendAnt	  := ""
Local nTotDia	  := 0
Local nTotFat	  := 0
Local nTotDev	  := 0
Local nTotGer	  := 0
Local nTotVend	  := 0     
Local nTotPerComis:= 0
Local nContComis  := 0
Local cCampos	  := ""
Local aAcuFat	  := {}
Local nAcuCli	  := 0
Local nTotAcu	  := 0
Local cVended	  := ""
Local cCodigo	  := "" 
Local cNFiscal	  := "" 
Local cCliente	  := ""
Local cClinew	  := ""
Local cCodTransp  := ""
Local cNomeTransp := ""
Local dDtSaida    := ""


If cWorkFlow == "S"        
	If ("0401" $ cWCodEmp+cWCodFil)
		cArq := "/VENDEDORES/HQ/" + MV_PAR03 + Substr(Dtoc(Date()),1,2) + Substr(Dtoc(Date()),4,2) + ".063"
	ElseIf ("0404" $ cWCodEmp+cWCodFil)
		cArq := "/VENDEDORES/HQ-CD/" + MV_PAR03 + Substr(Dtoc(Date()),1,2) + Substr(Dtoc(Date()),4,2) + ".063"  
	ElseIf ("0101" $ cWCodEmp+cWCodFil)                                                                  
		cArq := "/VENDEDORES/DIPROMED-MTZ/"+MV_PAR03 + Substr(Dtoc(Date()),1,2) + Substr(Dtoc(Date()),4,2) + ".063"			
	Else                                                                                                   	
		cArq := "/VENDEDORES/DIPROMED/" + MV_PAR03 + Substr(Dtoc(Date()),1,2) + Substr(Dtoc(Date()),4,2) + ".063"
	Endif
	cCampos		:= ""
	nHandle		:= Fcreate(cArq,0)
Else
	SetRegua(Len(aEmiFat))
EndIf


If Len(aEmiFat) > 0   
	cVendAnt 	:= aEmiFat[01][19]  
	cCliente	:= aEmiFat[01][03]
	nTotVend	:= 0   
	SA3->(DbSetorder(1))
	SA3->(DbSeek(xFilial("SA3") + cVendAnt))
	
	For xi:=1 to Len(aEmiFat)
	
		// Quebra de página
		If li > 56
			u_Pag063(_cTitulo,_cDesc1,_cDesc2,nHandle,cWorkFlow)
			If xi == 1
		   	    cNfiscal := aEmiFat[xi,2]
			EndIf
		EndIf  
		
		*                                                                                                    1                                                                                                   2                                                                                                   3
		*          1         2         3         4         5         6         7         8         9         0         1         2         3         4         5         6         7         8         9         0         1         2         3         4         5         6         7         8         9         0         1         2         3         4         5         6
		*01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
		*999999-XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
		*---------------------------------------------------------------------------------
		*01/01/01
		*CÓDIGO-LJ-NOME                                           Emissão  Nfiscal  Pedido
		*Produto-Descrição                                Quant.  Valor Unit.  Valor Total
		*999999-99-XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX              S
		*999999-XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX  99.999  99.999,99  999.999,99  		
		*---------------------------------------------------------------------------------
		*Total do Dia                                                       999.999.999,99
		*---------------------------------------------------------------------------------
		*Total Geral                                                        999.999.999,99
		*---------------------------------------------------------------------------------
	
		If cNfiscal <> aEmiFat[xi,2]
			cNfiscal := aEmiFat[xi,2] 	
			 
//	   	  aSort(aEmiFat,,,{|a, b| a[3]+a[4]+a[15]+a[1]+a[2] < b[3]+b[4]+b[15]+b[1]+b[2]})
//	   	  aSort(aEmiFat,,,{|a, b| a[3]+a[4]+a[1]+a[15]+a[2] < b[3]+b[4]+b[1]+b[15]+b[2]})
			If cWorkFlow == "N"
				For ni:=1 To Len(aEmiOrd)
					IncRegua( "Imprimindo: " + aEmiOrd[ni,3] )
					
					
					// QUEBRA DE PáGINA APóS A IMPRESSãO SE NECESSáRIO
					If li > 56
				  		u_Pag063(_cTitulo,_cDesc1,_cDesc2,nHandle,cWorkFlow)
					EndIf
						
								
					If ni == 1  
					    cCodTransp := aEmiOrd[ni,16]
					    cNomeTransp:= aEmiOrd[ni,17]
					    dDtSaida   := aEmiOrd[ni,18]
						@ li,000 PSay aEmiOrd[ni,3] + '-' + aEmiOrd[ni,4] + '-' + Substr(aEmiOrd[ni,5],1,40) 
						@ li,056 PSay SubStr(aEmiOrd[ni,1],7,2) + '/' + SubStr(aEmiOrd[ni,1],5,2) + '/' + SubStr(aEmiOrd[ni,1],1,4)+ ' ' +aEmiOrd[ni,2]+ ' ' + Substr(aEmiOrd[ni,11],1,6)
						li++
						li++
					EndIf
					   
                    // IMPRIME OS ITENS POR NOTA FISCAL
					If  Empty(aEmiOrd[ni,14])
						@ li,000 PSay Substr(aEmiOrd[ni,9],1,6) + '-' + Substr(aEmiOrd[ni,10],1,30)  
						@ li,040 PSay aEmiOrd[ni,20] Picture "@E 99.99"	 
						@ li,047 PSay aEmiOrd[ni,6] Picture "@E 999,999"
						@ li,056 PSay aEmiOrd[ni,7] Picture "@E 999,999.99"
						@ li,068 PSay aEmiOrd[ni,8] Picture "@E 9,999,999.99"
						nTotDia  += aEmiOrd[ni,8]
						nTotFat  += aEmiOrd[ni,8]
						nTotGer	 += aEmiOrd[ni,8]
						nTotVend += aEmiOrd[ni,8]     
						nTotPerComis += aEmiOrd[ni,20]*aEmiOrd[ni,8]/100
						nContComis   += 1
						li++
					Endif	 
						                               
					// IMPRIME AS DEVOLUÇÕES E SUBTRAI DO TOTAL POR CLIENTE E DO TOTAL GERAL
					If	!Empty(aEmiOrd[ni,14]) 
						@ li,000 PSay "DEVOLUÇÃO REFERENTE A NOTA FISCAL: "+ ' ' + aEmiOrd[ni,14]
						li++
						@ li,000 PSay Substr(aEmiOrd[ni,9],1,6) + '-' + Substr(aEmiOrd[ni,10],1,35)  
						@ li,047 PSay aEmiOrd[ni,6] Picture "@E 999,999"
						@ li,056 PSay aEmiOrd[ni,7] Picture "@E 999,999.99"
						@ li,068 PSay aEmiOrd[ni,8] Picture "@E 9,999,999.99"
						nTotDia  += aEmiOrd[ni,8]
						nTotDev  += aEmiOrd[ni,8]
						nTotGer  -= aEmiOrd[ni,8]	
						nTotVend -= aEmiOrd[ni,8]	
						li++
					Endif	
					
				Next
				@ li,000 PSay 'Total da Nota'   
				@ li,040 PSay nTotPerComis/nTotDia*100 Picture "@E 99.99"
				@ li,066 PSay nTotDia Picture "@E 999,999,999.99"
				li++                                             
                @ li,000 PSay 'Transportadora: ' +cCodTransp+ '-' +Substr(cNomeTransp,1,30)+ '  Data de saida: ' +SubStr(dDtSaida,7,2) + '/' + SubStr(dDtSaida,5,2) + '/' + SubStr(dDtSaida,1,4)
                li++
                cCodTransp := ''
                cNomeTransp:= ''
                dDtSaida   := ''      
				nTotDia    := 0  
			    nTotPerComis := 0
		        nContComis   := 0
				
				@ li,000 PSay Replic("-",Limite)
				li++   

				// IMPRIME O TOTAL POR CLIENTE					
		     	If cCliente <> aEmiFat[xi,3] 
		  	    	// Quebra de página
			   		If li > 52
		  		 		u_Pag063(_cTitulo,_cDesc1,_cDesc2,nHandle,cWorkFlow)
			   		EndIf
       				  		@ li,000 PSay Replic(".",Limite)
			 		li++
			 		@ li,000 PSay 'Total do Faturamento'
			 		@ li,066 PSay nTotFat Picture "@E 999,999,999.99" 
			 		li++
			 		@ li,000 PSay 'Total de Devoluções'
			 		@ li,066 PSay nTotDev Picture "@E 999,999,999.99"
			 		li++
			 		@ li,000 PSay 'Total do Cliente'
			 		@ li,066 PSay nTotFat - nTotDev Picture "@E 999,999,999.99"
			 		li++     
			 		@ li,000 PSay Replic(".",Limite) 
			 		li++
			  		li++
			   		cCLiente := aEmiFat[xi,3] 
					nTotFat	 := 0
					nTotDev	 := 0
				Endif

				// Quebra por Vendedor
				If cVendAnt != aEmiFat[xi][19]  
					If !Empty(cVendAnt)          
				        // IMPRIME O TOTAL DO VENDEDOR
						li++
						@ li,000 PSay Replic("*",Limite)
						li++
						@ li,000 PSay 'Total Vendedor'
						@ li,066 PSay nTotVend Picture "@E 999,999,999.99"
						li++     
						@ li,000 PSay Replic("*",Limite)
					EndIf
					cVendAnt 	:= aEmiFat[xi][19]
					nTotVend	:= 0
		
					SA3->(DbSetorder(1))
					SA3->(DbSeek(xFilial("SA3") + cVendAnt))
					u_Pag063(_cTitulo,_cDesc1,_cDesc2,nHandle,cWorkFlow)
				EndIf
					
				aEmiOrd := {}          
			
			Else
				For ni:=1 To Len(aEmiOrd)     
			   	
				 	// IMPRIME O TOTAL POR CLIENTE	
			  		If cCliente <> aEmiOrd[ni,3]  
				   		If cCLiente <> "" 
				    		If li > 52
				  		 		u_Pag063(_cTitulo,_cDesc1,_cDesc2,nHandle,cWorkFlow)
					   		EndIf
		       		   		cCampos := Replic(".",Limite) + Chr(13) + Chr(10)
					   		Fwrite(nHandle,cCampos)	       			
					   		li++
					   		cCampos :=  'Total do Faturamento' + Space(46)
					   		cCampos += Transform(nTotFat,"@E 999,999,999.99") + Chr(13) + Chr(10)
					   		Fwrite(nHandle,cCampos)	       			
					   		li++     
					   		cCampos :=  'Total de Devolução' + Space(48)
					   		cCampos += Transform(nTotDev,"@E 999,999,999.99") + Chr(13) + Chr(10)
					   		Fwrite(nHandle,cCampos)	       			
					   		li++  
					   		cCampos :=  'Total do Cliente' + Space(50)
					   		cCampos += Transform(nTotFat - nTotDev,"@E 999,999,999.99") + Chr(13) + Chr(10)
					   		Fwrite(nHandle,cCampos)	       			
					   		li++  
		       		   		cCampos := Replic(".",Limite) + Chr(13) + Chr(10)+ Chr(13) + Chr(10)
					  		Fwrite(nHandle,cCampos)	       			
					 		li++
					 		li++
	             	   Endif
				 		cCLiente := aEmiOrd[ni,3] 
				 		nTotFat	 := 0
				 		nTotDev	 := 0	
			  		Endif			
			
			   		If ni == 1 
			   		    cCodTransp := aEmiOrd[ni,16]
					    cNomeTransp:= aEmiOrd[ni,17]
					    dDtSaida   := aEmiOrd[ni,18] 
				  		cCampos := aEmiOrd[ni,3] + '-' + aEmiOrd[ni,4] + '-' + Substr(aEmiOrd[ni,5],1,40) + Space(5)
				  		cCampos += + ' ' + SubStr(aEmiOrd[ni,1],7,2) + '/' + SubStr(aEmiOrd[ni,1],5,2) + '/' + SubStr(aEmiOrd[ni,1],1,4)+ ' ' + aEmiOrd[ni,2]+ ' ' + Substr(aEmiOrd[ni,11],1,6)  + Chr(13) + Chr(10) + Chr(13) + Chr(10)
				  		Fwrite(nHandle,cCampos)
				  	   
				  		li++
				  		li++
						// Quebra de página
						If li > 56
							u_Pag063(_cTitulo,_cDesc1,_cDesc2,nHandle,cWorkFlow)
							li++
						EndIf
						
			  		EndIf    
	
			   		// IMPRIME OS ITENS POR NOTA FISCAL
			  		If  Empty(aEmiOrd[ni,14])
				   		cCampos := Substr(aEmiOrd[ni,9],1,6) + '-' + Substr(aEmiOrd[ni,10],1,30)+ Space(4) 
			   	    	cCampos += Transform(aEmiOrd[ni,20],"@E 99.99")+Space(5) 
				   		cCampos += Transform(aEmiOrd[ni,6],"@E 999,999") 
				   		cCampos += Transform(aEmiOrd[ni,7],"@E 999,999.99") 
				   		cCampos += Transform(aEmiOrd[ni,8],"@E 9,999,999.99") + Chr(13) + Chr(10)
				  		Fwrite(nHandle,cCampos)
				  		nTotDia  += aEmiOrd[ni,8]
				  		nTotFat  += aEmiOrd[ni,8]
				   		nTotGer  += aEmiOrd[ni,8] 
	    				nTotPerComis += aEmiOrd[ni,20]*aEmiOrd[ni,8]/100
    					nContComis   += 1
				  		li++ 
					
				 		// Quebra de página
						If li > 56
							u_Pag063(_cTitulo,_cDesc1,_cDesc2,nHandle,cWorkFlow)
				 		EndIf
			  		Endif	 
				
			  		// IMPRIME AS DEVOLUÇÕES E SUBTRAI DO TOTAL POR CLIENTE E DO TOTAL GERAL	
			  		If	!Empty(aEmiOrd[ni,14]) 
				  		cCampos := "DEVOLUÇÃO REFERENTE A NOTA FISCAL: "+ ' '  + aEmiOrd[ni,14]  + Chr(13) + Chr(10)
				  		Fwrite(nHandle,cCampos)
				   		li++
				   		cCampos := Substr(aEmiOrd[ni,9],1,6) + '-' + Substr(aEmiOrd[ni,10],1,35) + Space(9)   
				   		cCampos += Transform(aEmiOrd[ni,6],"@E 999,999") 
				   		cCampos += Transform(aEmiOrd[ni,7],"@E 999,999.99") 
				   		cCampos += Transform(aEmiOrd[ni,8],"@E 9,999,999.99") + Chr(13) + Chr(10)
				  		Fwrite(nHandle,cCampos)				
				  		nTotDia += aEmiOrd[ni,8]
			  	  		nTotDev += aEmiOrd[ni,8]
				 		nTotGer -= aEmiOrd[ni,8]	
				  		li++ 
					
				   		// Quebra de página
				   		If li > 56
				  			u_Pag063(_cTitulo,_cDesc1,_cDesc2,nHandle,cWorkFlow)
				  		EndIf
			 		Endif
			
				Next
				cCampos := 'Total da Nota' + Space(28)                      
	    		cCampos += Transform(nTotPerComis/nTotDia*100,"@E 99.99") + Space(20)
				cCampos +=  Transform(nTotDia,"@E 999,999,999.99") + Chr(13) + Chr(10)
				Fwrite(nHandle,cCampos)
				li++                      
				cCampos := 'Transportadora: ' +Substr(cCodTransp,1,6)+ '-' +Substr(cNomeTransp,1,30)+ '  Data de saida: ' +SubStr(dDtSaida,7,2) + '/' + SubStr(dDtSaida,5,2) + '/' + SubStr(dDtSaida,1,4) + Chr(13) + Chr(10)
				Fwrite(nHandle,cCampos)
				li++          
				
		        cCodTransp := ''
		        cNomeTransp:= ''
		        dDtSaida   := ''      
				// Quebra de página
				If li > 56
					u_Pag063(_cTitulo,_cDesc1,_cDesc2,nHandle,cWorkFlow)
				EndIf
				nTotDia := 0
			    nTotPerComis := 0
		        nContComis   := 0
				cCampos := Replic("-",Limite) + Chr(13) + Chr(10)
				Fwrite(nHandle,cCampos)
				li++
				// Quebra de página
				If li > 56
					u_Pag063(_cTitulo,_cDesc1,_cDesc2,nHandle,cWorkFlow)
				EndIf
				aEmiOrd := {}
			EndIf
		EndIf		
		Aadd(aEmiOrd,{aEmiFat[xi,1],aEmiFat[xi,2],aEmiFat[xi,3],aEmiFat[xi,4],aEmiFat[xi,5],aEmiFat[xi,6],aEmiFat[xi,7],aEmiFat[xi,8],aEmiFat[xi,9],aEmiFat[xi,10],aEmiFat[xi,11],aEmiFat[xi,12],aEmiFat[xi,13],aEmiFat[xi,14],aEmiFat[xi,15],aEmiFat[xi,16],aEmiFat[xi,17],aEmiFat[xi,18],aEmiFat[xi,19],aEmiFat[xi,20]})
	Next	


//    aSort(aEmiFat,,,{|a, b| a[3]+a[4]+a[15]+a[1]+a[2] < b[3]+b[4]+b[15]+b[1]+b[2]})
// 	  aSort(aEmiFat,,,{|a, b| a[3]+a[4]+a[1]+a[15]+a[2] < b[3]+b[4]+b[1]+b[15]+b[2]})
	If cWorkFlow == "N"
		For ni:=1 To Len(aEmiOrd)
			IncRegua( "Imprimindo: " + aEmiOrd[ni,3] )   			

			// IMPRIME O TOTAL POR CLIENTE	
			If cCliente <> aEmiOrd[ni,3]  
			    	If cCLiente <> "" 
			  	    	// Quebra de página
				   		If li > 52
			  		 		u_Pag063(_cTitulo,_cDesc1,_cDesc2,nHandle,cWorkFlow)
				   		EndIf
	       		  		@ li,000 PSay Replic(".",Limite)
				 		li++
				 		@ li,000 PSay 'Total do Faturamento'
				 		@ li,066 PSay nTotFat Picture "@E 999,999,999.99" 
				 		li++
				 		@ li,000 PSay 'Total de Devoluções'
				 		@ li,066 PSay nTotDev Picture "@E 999,999,999.99"
				 		li++
				 		@ li,000 PSay 'Total do Cliente'
				 		@ li,066 PSay nTotFat - nTotDev Picture "@E 999,999,999.99"
				 		li++     
				 		@ li,000 PSay Replic(".",Limite) 
				 		li++
				  		li++
                	  	Endif
				   		cCLiente := aEmiOrd[ni,3] 
						nTotFat	 := 0
						nTotDev	 := 0
					Endif
			
			// QUEBRA DE PáGINA APóS A IMPRESSãO SE NECESSáRIO
			If li > 56
		  		u_Pag063(_cTitulo,_cDesc1,_cDesc2,nHandle,cWorkFlow)
			EndIf
            
					
			If ni == 1 
				cCodTransp := aEmiOrd[ni,16]
			    cNomeTransp:= aEmiOrd[ni,17]
			    dDtSaida   := aEmiOrd[ni,18]
				@ li,000 PSay aEmiOrd[ni,3] + '-' + aEmiOrd[ni,4] + '-' + Substr(aEmiOrd[ni,5],1,40) 
				@ li,056 PSay SubStr(aEmiOrd[ni,1],7,2) + '/' + SubStr(aEmiOrd[ni,1],5,2) + '/' + SubStr(aEmiOrd[ni,1],1,4)+ ' ' +aEmiOrd[ni,2]+ ' ' + Substr(aEmiOrd[ni,11],1,6)
				li++
				li++
			EndIf
		   	
		   	// IMPRIME OS ITENS POR NOTA FISCAL
			If  Empty(aEmiOrd[ni,14])
				@ li,000 PSay Substr(aEmiOrd[ni,9],1,6) + '-' + Substr(aEmiOrd[ni,10],1,30)  
				@ li,040 PSay aEmiOrd[ni,20] Picture "@E 99.99"	 
				@ li,047 PSay aEmiOrd[ni,6] Picture "@E 999,999"
				@ li,056 PSay aEmiOrd[ni,7] Picture "@E 999,999.99"
				@ li,068 PSay aEmiOrd[ni,8] Picture "@E 9,999,999.99"
				nTotDia  += aEmiOrd[ni,8]
				nTotFat  += aEmiOrd[ni,8]
				nTotGer  += aEmiOrd[ni,8]
				nTotVend += aEmiOrd[ni,8]   
				nTotPerComis += aEmiOrd[ni,20]*aEmiOrd[ni,8]/100
				nContComis   += 1
				li++
			Endif	 
			
			// IMPRIME AS DEVOLUÇÕES E SUBTRAI DO TOTAL POR CLIENTE E DO TOTAL GERAL	
			If	!Empty(aEmiOrd[ni,14]) 
				@ li,000 PSay "DEVOLUÇÃO REFERENTE A NOTA FISCAL: "+ '' + aEmiOrd[ni,14]
				li++
				@ li,000 PSay Substr(aEmiOrd[ni,9],1,6) + '-' + Substr(aEmiOrd[ni,10],1,35)  
				@ li,047 PSay aEmiOrd[ni,6] Picture "@E 999,999"
				@ li,056 PSay aEmiOrd[ni,7] Picture "@E 999,999.99"
				@ li,068 PSay aEmiOrd[ni,8] Picture "@E 9,999,999.99"
				nTotDia  += aEmiOrd[ni,8]
		  		nTotDev  += aEmiOrd[ni,8]
				nTotGer  -= aEmiOrd[ni,8]	
				nTotVend -= aEmiOrd[ni,8]	
				li++
			Endif
		Next
		@ li,000 PSay 'Total da Nota'   
		@ li,040 PSay nTotPerComis/nTotDia*100 Picture "@E 99.99"
		@ li,066 PSay nTotDia Picture "@E 999,999,999.99"
		li++                                             
        @ li,000 PSay 'Transportadora: ' +cCodTransp+ '-' +Substr(cNomeTransp,1,30)+ '  Data de saida: ' +SubStr(dDtSaida,7,2) + '/' + SubStr(dDtSaida,5,2) + '/' + SubStr(dDtSaida,1,4)
        li++      
        cCodTransp := ''
        cNomeTransp:= ''
        dDtSaida   := ''          
		nTotDia    := 0
	    nTotPerComis := 0
        nContComis   := 0
		@ li,000 PSay Replic("-",Limite)
		li++   	
	Else
		For ni:=1 To Len(aEmiOrd)     
		
					// IMPRIME O TOTAL POR CLIENTE	
		  		If cCliente <> aEmiOrd[ni,3]  
			   		If cCLiente <> "" 
			    		If li > 52
			  		 		u_Pag063(_cTitulo,_cDesc1,_cDesc2,nHandle,cWorkFlow)
				   		EndIf
	       		   		cCampos := Replic(".",Limite) + Chr(13) + Chr(10)
				   		Fwrite(nHandle,cCampos)	       			
				   		li++
				   		cCampos :=  'Total do Faturamento' + Space(46)
				   		cCampos += Transform(nTotFat,"@E 999,999,999.99") + Chr(13) + Chr(10)
				   		Fwrite(nHandle,cCampos)	       			
				   		li++     
				   		cCampos :=  'Total de Devolução' + Space(48)
				   		cCampos += Transform(nTotDev,"@E 999,999,999.99") + Chr(13) + Chr(10)
				   		Fwrite(nHandle,cCampos)	       			
				   		li++  
				   		cCampos :=  'Total do Cliente' + Space(50)
				   		cCampos += Transform(nTotFat - nTotDev,"@E 999,999,999.99") + Chr(13) + Chr(10)
				   		Fwrite(nHandle,cCampos)	       			
				   		li++  
	       		   		cCampos := Replic(".",Limite) + Chr(13) + Chr(10)+ Chr(13) + Chr(10)
				  		Fwrite(nHandle,cCampos)	       			
				 		li++
				 		li++
             	   Endif
			 		cCLiente := aEmiOrd[ni,3] 
			 		nTotFat	 := 0
			 		nTotDev	 := 0	
		  		Endif
			
		
		   		If ni == 1  
			   		cCodTransp := aEmiOrd[ni,16]
				    cNomeTransp:= aEmiOrd[ni,17]
				    dDtSaida   := aEmiOrd[ni,18]
			  		cCampos := aEmiOrd[ni,3] + '-' + aEmiOrd[ni,4] + '-' + Substr(aEmiOrd[ni,5],1,40)+ Space(5) 
			  		cCampos += + ' ' + SubStr(aEmiOrd[ni,1],7,2) + '/' + SubStr(aEmiOrd[ni,1],5,2) + '/' + SubStr(aEmiOrd[ni,1],1,4)+ ' ' + aEmiOrd[ni,2]+ ' ' + Substr(aEmiOrd[ni,11],1,6)  + Chr(13) + Chr(10) + Chr(13) + Chr(10)
			  		Fwrite(nHandle,cCampos)
			  		li++
			  		li++
					// Quebra de página
					If li > 56
						u_Pag063(_cTitulo,_cDesc1,_cDesc2,nHandle,cWorkFlow)
					EndIf
		  		EndIf    

		   		// IMPRIME OS ITENS POR NOTA FISCAL
		  		If  Empty(aEmiOrd[ni,14])
			   		cCampos := Substr(aEmiOrd[ni,9],1,6) + '-' + Substr(aEmiOrd[ni,10],1,30)+ Space(4) 
			    	cCampos += Transform(aEmiOrd[ni,20],"@E 99.99")+Space(5) 
			   		cCampos += Transform(aEmiOrd[ni,6],"@E 999,999") 
			   		cCampos += Transform(aEmiOrd[ni,7],"@E 999,999.99") 
			   		cCampos += Transform(aEmiOrd[ni,8],"@E 9,999,999.99") + Chr(13) + Chr(10)
			  		Fwrite(nHandle,cCampos)
			  		nTotDia += aEmiOrd[ni,8]
			  		nTotFat += aEmiOrd[ni,8]
			   		nTotGer += aEmiOrd[ni,8]    
					nTotPerComis += aEmiOrd[ni,20]*aEmiOrd[ni,8]/100
					nContComis   += 1
			  		li++ 
				
			 		// Quebra de página
					If li > 56
						u_Pag063(_cTitulo,_cDesc1,_cDesc2,nHandle,cWorkFlow)
			 		EndIf
		  		Endif	 
			
		  		// IMPRIME AS DEVOLUÇÕES E SUBTRAI DO TOTAL POR CLIENTE E DO TOTAL GERAL	
		  		If	!Empty(aEmiOrd[ni,14]) 
			  		cCampos := "DEVOLUÇÃO REFERENTE A NOTA FISCAL: "+ ' '  + aEmiOrd[ni,14]  + Chr(13) + Chr(10)
			  		Fwrite(nHandle,cCampos)
			   		li++
			   		cCampos := Substr(aEmiOrd[ni,9],1,6) + '-' + Substr(aEmiOrd[ni,10],1,35) + Space(9)   
			   		cCampos += Transform(aEmiOrd[ni,6],"@E 999,999") 
			   		cCampos += Transform(aEmiOrd[ni,7],"@E 999,999.99") 
			   		cCampos += Transform(aEmiOrd[ni,8],"@E 9,999,999.99") + Chr(13) + Chr(10)
			  		Fwrite(nHandle,cCampos)				
			  		nTotDia += aEmiOrd[ni,8]
		  	  		nTotDev += aEmiOrd[ni,8]
			 		nTotGer -= aEmiOrd[ni,8]	
			  		li++ 
				
			   		// Quebra de página
			   		If li > 56
			  			u_Pag063(_cTitulo,_cDesc1,_cDesc2,nHandle,cWorkFlow)
			  		EndIf
		 		Endif
			
		Next
		cCampos := 'Total da Nota' + Space(28)                      
	    cCampos += Transform(nTotPerComis/nTotDia*100,"@E 99.99") + Space(20)
		cCampos +=  Transform(nTotDia,"@E 999,999,999.99") + Chr(13) + Chr(10)
		Fwrite(nHandle,cCampos)
		li++                      
		cCampos := 'Transportadora: ' +Substr(cCodTransp,1,6)+ '-' +Substr(cNomeTransp,1,30)+ '  Data de saida: ' +SubStr(dDtSaida,7,2) + '/' + SubStr(dDtSaida,5,2) + '/' + SubStr(dDtSaida,1,4) + Chr(13) + Chr(10)
		Fwrite(nHandle,cCampos)
		li++

        cCodTransp := ''
        cNomeTransp:= ''
        dDtSaida   := ''      
		// Quebra de página
		If li > 56
			u_Pag063(_cTitulo,_cDesc1,_cDesc2,nHandle,cWorkFlow)
		EndIf
		nTotDia := 0
	    nTotPerComis := 0
        nContComis   := 0
		cCampos := Replic("-",Limite) + Chr(13) + Chr(10)
		Fwrite(nHandle,cCampos)
		li++
		// Quebra de página
		If li > 56
			u_Pag063(_cTitulo,_cDesc1,_cDesc2,nHandle,cWorkFlow)
		EndIf
		aEmiOrd := {}
	EndIf

	// Quebra de página
	If li > 56
		u_Pag063(_cTitulo,_cDesc1,_cDesc2,nHandle,cWorkFlow)
	EndIf  
	
			
	If li <> 80
		If cWorkFlow == "N"
		    
			// IMPRIME O TOTAL DO ÚLTIMO CLIENTE NA QUERY
			@ li,000 PSay Replic(".",Limite)
			li++
			@ li,000 PSay 'Total do Faturamento'
			@ li,066 PSay nTotFat Picture "@E 999,999,999.99" 
			li++
			@ li,000 PSay 'Total de Devoluções'
			@ li,066 PSay nTotDev Picture "@E 999,999,999.99"
			li++
			@ li,000 PSay 'Total do Cliente'
			@ li,066 PSay nTotFat - nTotDev Picture "@E 999,999,999.99"
			li++     
			@ li,000 PSay Replic(".",Limite) 
			li++
			li++

	        // IMPRIME O TOTAL DO VENDEDOR
			@ li,000 PSay Replic("*",Limite)
			li++
			@ li,000 PSay 'Total Vendedor'
			@ li,066 PSay nTotVend Picture "@E 999,999,999.99"
			li++     
			@ li,000 PSay Replic("*",Limite)
			li++

	        // IMPRIMI O TOTAL GERAL
			@ li,000 PSay Replic("*",Limite)
			li++
			@ li,000 PSay 'Total Geral'
			@ li,066 PSay nTotGer Picture "@E 999,999,999.99"
			li++     
			@ li,000 PSay Replic("*",Limite)
			
		ELSE	    
			
			// IMPRIME O TOTAL DO ÚLTIMO CLIENTE NA QUERY
	 		cCampos := Replic(".",Limite) + Chr(13) + Chr(10)
			Fwrite(nHandle,cCampos)	       			
			li++
			cCampos :=  'Total do Faturamento' + Space(46)
			cCampos += Transform(nTotFat,"@E 999,999,999.99") + Chr(13) + Chr(10)
			Fwrite(nHandle,cCampos)	       			
			li++     
			cCampos :=  'Total de Devolução' + Space(48)
			cCampos += Transform(nTotDev,"@E 999,999,999.99") + Chr(13) + Chr(10)
			Fwrite(nHandle,cCampos)	       			
			li++  
			cCampos :=  'Total do Cliente' + Space(50)
			cCampos += Transform(nTotFat - nTotDev,"@E 999,999,999.99") + Chr(13) + Chr(10)
			Fwrite(nHandle,cCampos)	       			
			li++  
		    cCampos := Replic(".",Limite) + Chr(13) + Chr(10)+ Chr(13) + Chr(10)
			Fwrite(nHandle,cCampos)	       			
			li++
			li++

	        // IMPRIMI O TOTAL GERAL
			cCampos := Replic("*",Limite) + Chr(13) + Chr(10)
			Fwrite(nHandle,cCampos)
			li++
			cCampos := 'Total Geral' + Space(53)
			cCampos += Transform(nTotGer,"@E 999,999,999.99") + Chr(13) + Chr(10)
			Fwrite(nHandle,cCampos)
			li++     
			cCampos := Replic("*",Limite) + Chr(13) + Chr(10)
			Fwrite(nHandle,cCampos)
			li++ 
		EndIf		
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
			u_Pag063(_cTitulo,_cDesc1,_cDesc2,nHandle,cWorkFlow)
		EndIf
		cCampos := Replic("-",Limite)  + Chr(13) + Chr(10)
		Fwrite(nHandle,cCampos)
		li++
		// Quebra de página
		If li > 56
			u_Pag063(_cTitulo,_cDesc1,_cDesc2,nHandle,cWorkFlow)
		EndIf
		cCampos := "Não foi localizado nenhum registro no período de " + SubStr(dtos(mv_par01),7,2) + '/' + SubStr(dtos(mv_par01),5,2) + '/' + SubStr(dtos(mv_par01),1,4) + " até " + SubStr(dtos(mv_par02),7,2) + '/' + SubStr(dtos(mv_par02),5,2) + '/' + SubStr(dtos(mv_par02),1,4) + Chr(13) + Chr(10)
		Fwrite(nHandle,cCampos)
		li++
		// Quebra de página
		If li > 56
			u_Pag063(_cTitulo,_cDesc1,_cDesc2,nHandle,cWorkFlow)
		EndIf
		cCampos := Replic("-",Limite) + Chr(13) + Chr(10)
		Fwrite(nHandle,cCampos)
		li++
		// Quebra de página
		If li > 56
			u_Pag063(_cTitulo,_cDesc1,_cDesc2,nHandle,cWorkFlow)
		EndIf
		cCampos := Replic("-",Limite) + Chr(13) + Chr(10)
		Fwrite(nHandle,cCampos)
		li+=2
		// Quebra de página
		If li > 56
			u_Pag063(_cTitulo,_cDesc1,_cDesc2,nHandle,cWorkFlow)
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
User Function Pag063(_cTitulo,_cDesc1,_cDesc2,nHandle,cWorkFlow)
	li := U_MYCABEC(_cTitulo,_cDesc1,_cDesc2,nHandle,cWorkFlow)
	If cWorkFlow == "N"
		@ li,000 PSay 'Vendedor: ' + SA3->A3_COD + ' - ' + SA3->A3_NOME
		li+=2
	Else
		li++
		cCampos := Chr(13) + Chr(10) + 'Vendedor: ' + SA3->A3_COD +'-'+SA3->A3_NOME  + Chr(13) + Chr(10)  + Chr(13) + Chr(10)
		Fwrite(nHandle,cCampos)
		li+=2
	EndIf	
Return

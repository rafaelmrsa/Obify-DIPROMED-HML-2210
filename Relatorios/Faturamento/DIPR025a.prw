/*====================================================================================\
|Programa  | DIPR025       | Autor | Eriberto Elias             | Data | 15/05/2003   |
|=====================================================================================|
|DescriÁ„o | Faturamento por cliente mes a mes e total do ano                         |
|          |                                                                          |
|          |                                                                          |
|=====================================================================================|
|Sintaxe   | DIPR025                                                                  |
|=====================================================================================|
|Uso       | Especifico DIPROMED                                                      |
|=====================================================================================|
|........................................HistÛrico....................................|
|Rafael    | DD/MM/AA - DescriÁ„o                                                     |
|Eriberto  | 12/01/05 - coloquei A1_VEND, A1_SATIV1 e A1_MUN no arquivo temporario    |
|          |            para usar no excel                                            |
|Eriberto  | 13/01/05 - coloquei a QRY3 com o SA1 para pegar os clientes que nao      |
|          |            compraram MV_PAR09 = SIM                                      |
|Rafael    | 03/02/05 - AlteraÁ„o para envio de e-mail para os representantes         |
|Rafael    | 09/02/05 - AlteraÁ„o para envio de e-mail para CALLCENTER                |
|Eriberto  | 09/08/05 - coloquei X5_DESCRI, A1_ULTCOM, A1_PRICOM e A1_HPGAE           |
|          |             no arquivo temporario para usar no excel                     |
|Daniel    | 11/10/07 - Inclusao de filtro por Grupo de Clientes                      |
|          |            Inclusao do tratamento de filtro de Vendedores                |
|Maximo    | 29/09/09 - Inclus„o de tratamento para Vendedor HQ/Empresa HQ            |
|Eriberto  | 07/10/09 - Inclus„o dos campos A1_CGC e A1_IE                            |
|          |            no arquivo temporario para usar no excel                      |
|Jailton   | 23/03/10 - Customizacao para imprimir multyempresas, somando os fatura-  |
|JBS       |            mentos     Health Quality e Dipromed (CDs)                    |
|Maximo    | 26/07/10 - Customizacao para filtrar pelos dois fornecedores HQ que s„o: |
|MCVN      |            (000851 e 051508) quando um deles for solicitado no MV_PAR05  |
|Jailton/  | 29/07/10 - Tratamento para Imprimir carteira ou venda realizada.Otimizado|
|JBS       |a 30/07/10  os parametros do pegunte.                                     |  
|Giovani   |  28/08/11  Inserido coluna de endereÁo no arquivo de excel A1_END        |
|RBorges   | 28/08/2012 Inserido A1_XCANALV no relatorio.                             | 
|RBorges   | 02/10/2012 Inserido TÈcnico Convatec no relatorio.                       |
|MAximo    | 17/01/2013 Inserido A1_CNAE/A1_CNES no relatorio.                        |
|RBorges   | 22/02/2013 Inserido A1_XTEC_SP/ A1_XTEC_MA/ A1_XTEC_HQ                   |
|RBorges   | 26/09/2013 Inserido A1_XVENDSP/ A1_NVENDSP                               |
|RBorges   | 01/11/2013 Inserido A1_VENDHQ                                            |
|FDuran    | 11/10/2019 Inserido A1_EMAILD                                            |
\====================================================================================*/

#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"

User Function DipR025A(aWork)  

Local _xArea    := GetArea() 
Local zi

Private cUserAut  := GetMV("MV_URELFAT") // MCVN - 04/05/09    
Private tamanho    := "G"
Private limite     := 220
Private titulo     := OemTOAnsi("Dipr025A - Vendas por cliente mes a mes com total do ano",72)
Private cDesc1     := (OemToAnsi("Este programa tem como objetivo emitir um relat¢rio",72))
Private cDesc2     := (OemToAnsi("de Faturamento por cliente, mes a mes e inclui a carteira.",72))
Private cDesc3     := (OemToAnsi("Ranking: 0 pelo Total, 1 a 12 pelo mÍs ou 13 pela Media",72))
Private aReturn    := {"Bco A4", 1,"Faturamento", 1, 2, 1,"",1}
Private nomeprog   := "DIPR025"
Private nLastKey   := 0
Private lContinua  := .T.
Private lEnd       := .F.
Private li         := 67
Private wnrel      := "DIPR025"
Private M_PAG      := 1
Private cString    := "SD2"
Private _nAnoIni   := ""
Private _nMesIni   := ""
Private _nParIni   := ""
Private _nParFim   := ""
Private _nAnoFim   := ""
Private _nMesFim   := ""
Private cWorkFlow  := ""
Private _cArqTrb   := ""
Private _cRanking  := ""
Private cFilSA3    := ""       
Private cVendInt   := GetMV("MV_DIPVINT")// MCVN - 06/05/09
Private cVendExt   := GetMV("MV_DIPVEXT")// MCVN - 06/05/09  
Private cSHWCUST   := GetMV("MV_SHWCUST")// MCVN - 13/11/09  
Private cDestino   := "C:\EXCELL-DBF\"
Private _cPosto    := ""
Private _CodVen    := "" 
Private _cDipUsr   := U_DipUsr() 
Private cCodUser   := RetCodUsr()

U_USESU7(cCodUser,@_CodVen,@_cPosto)
  

//-------------------------------------------------------------------------------------------------------------------------------
// JBS 22/03/2010: Tratamento para montar a query quando for executado para Health Quality apenas, ou para o Grupo Dipromed.
//-------------------------------------------------------------------------------------------------------------------------------
// Leia com atencao porque dentro do If sao duas matrizes: 1a. Condicao retorna uma matriz com um elemento (Uma empresa).
//                                                         2a. Condicao retorna uma matriz com 2 elementos (Duas Empresas).      
//-------------------------------------------------------------------------------------------------------------------------------        
Private aEmpresa   := If("HEALTH" $ SM0->M0_NOMECOM,{{'010','01'}},{{'010','04'},{"010","01"}} ) // Empresa e filial para processar as querys
Private cPerg 
Private nIndFil := Aviso('AtenÁ„o','Imprime relatorio individual por filial ?',{'N√O','SIM'})                                                                                                

If nIndFil = 2 
	aEmpresa   := {{cEmpAnt+'0',cFilAnt}}
Endif                                  

//Tratamento para workflow
If ValType(aWork) <> 'A'
	cWorkFlow := "N"
	cPerg  	:= U_FPADR( "DIPR25A","SX1","SX1->X1_GRUPO"," " ) //Criado por Sandro em 19/11/09. 
Else
	cWorkFlow := aWork[1]
EndIf

If cWorkFlow == "S"  
	PREPARE ENVIRONMENT EMPRESA "01" FILIAL "04" FUNNAME "DIPR025"
EndIf
// Somente depois que preparar o ambiente...
cFilSA3     := xFilial("SA3")
U_DIPPROC(ProcName(0),_cDipUsr) // JBS 05/10/2005 - Gravando o nome do Programa no SZU

If cWorkFlow == "N"      
    
If _cPosto <> "02" .Or. Upper(_cDipUsr) $ Upper(cUserAut)//RBorges 07/02/17
	// MCVN - 10/05/09    
	If !(Upper(_cDipUsr) $ cUserAut .Or. Upper(_cDipUsr) $ cVendInt .or. Upper(_cDipUsr) $ cVendExt .or. Upper(_cDipUsr) $ "IFERREIRA") // MCVN - 07/05/09
		Alert(Upper(_cDipUsr)+", vocÍ n„o tem autorizaÁ„o para utilizar esta rotina. Qualquer d˙vida falar com Departamento de T.I. !","AtenÁ„o")	 //Giovani Zago 17/08/11
		Return()
	Endif
EndIf	     
	
	AjustaSX1(cPerg)             // Verifica perguntas. Se nao existe INCLUI
	
	If !Pergunte(cPerg,.T.)
		Return     // Solicita parametros
	ElseIf SubStr(MV_PAR01,1,2)<'01'.or.SubStr(MV_PAR01,1,2)>'12' // JBS 28/11/2005
		MsgInfo('MÍs informado Invalido','AtenÁ„o') // JBS 28/11/2005
		Return // JBS 28/11/2005
	ElseIf SubStr(MV_PAR01,3,4)<'2001'.or.SubStr(MV_PAR01,3,4)>'2099' // JBS 28/11/2005
		MsgInfo('Ano informado Invalido','AtenÁ„o') // JBS 28/11/2005
		Return // JBS 28/11/2005  
	ElseIf Empty(MV_PAR02) .And. MV_PAR10 = 1      // MCVN 18/01/2008
		MsgInfo('O e-mail sÛ pode ser enviado se o par‚metro de vendedor estiver preenchido!','AtenÁ„o') // MCVN 18/01/2008
		Return  // MCVN 18/01/2008
	EndIf
	If (!EMPTY(ALLTRIM(DTOS(MV_PAR12)))  .AND. !empty(ALLTRIM(DTOS(MV_PAR13))) )

		_nMesIni := Val(Substr(dtos(MV_PAR12),5,2))
		_nAnoIni := Val(Substr(dtos(MV_PAR12),1,4))
		_nMesFim := Substr(dtos(MV_PAR13),5,2)
		_nAnoFim := Substr(dtos(MV_PAR13),1,4)

		if (DateDiffMonth(MV_PAR12,MV_PAR13)>12)
			Alert('Intervalo de datas inv·lido')
			Return
		EndIF
	EndIF
    wnrel := SetPrint(cString,wnrel,cPerg,Titulo,cDesc1,cDesc2,cDesc3,.f.,,.f.,tamanho,,.f.,,,,,)
	
	If nLastKey == 27
		Return
	Endif
	
	SetDefault(aReturn,cString)
	
	Processa({|lEnd| RunProc()},"Processando...")
	
	RptStatus({|lEnd| RptDetail()},"Imprimindo Faturamento por cliente e mes...")
	
	Set device to Screen
	
	//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
	//≥ Se em disco, desvia para Spool                                            ≥
	//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
	If aReturn[5] == 1    // Se Saida para disco, ativa SPOOL
		Set Printer TO
		Commit
		ourspool(wnrel)
	Endif
	QRY1->(dbCloseArea())
	QRY2->(dbCloseArea())
	QRY3->(dbCloseArea())
	TRB->(DbCloseArea())
	Ferase(_cArqTrb+".DBF")
	Ferase(_cArqTrb+OrdBagExt())
	RestArea(_xArea)
Else
	/*==========================================================================\
	| Este relatÛrio executado via WORKFLOW, dever· ser executado somente no 2o.|
	| dia ˙til de cada mÍs                                                     |
	|                                                                           |
	\==========================================================================*/
	If Val(SubStr(DtoS(dDataBase),7,2)) < 31 //5
		// Montagem do array com feriados
		cTemp := ""
		_aFeriad := {}
		aCod_Rep := {}
		dbSelectArea("SX5")
		dbSetOrder(1)
		dbSeek(xFilial("SX5")+"63")
		While X5_TABELA == "63"
			If SubStr(X5_DESCRI,1,1) != " " .and. Val(SubStr(X5_DESCRI,7,2)) < 80 // CondiÁ„o para pegar campos somente com datas e com ano de 2000 em diante
				// Monta data extraÌda do campo X5_DESCRI
				cTemp := Iif(Empty(SubStr(X5_DESCRI,7,2)),CtoD(SubStr(X5_DESCRI,1,2)+"/"+SubStr(X5_DESCRI,4,2)+"/"+"20"+AllTrim(Str(Year(Date())))),CtoD(SubStr(X5_DESCRI,1,2)+"/"+SubStr(X5_DESCRI,4,2)+"/"+"20"+SubStr(X5_DESCRI,7,2)))
				Aadd(_aFeriad,{cTOD(AllTrim(cTemp))})
			EndIf
			SX5->(DbSkip())
		EndDo
		
		// soma Dias Uteis
		_nDias 		:= 3
		_dBase 		:= CtoD("01/" + SubStr(DtoS(dDataBase),5,2) + "/" + SubStr(DtoS(dDataBase),1,4))
		_nPastDays := 0               
		While _nPastDays < _nDias
			_dBase++
			If Ascan(_aFeriad,{|y| y[1] == _dBase}) == 0 .And. Dow(_dBase) <> 1 .And. Dow(_dBase) <> 7
			   _nPastDays++
			EndIf     
		EndDo
		dDatSis := _dBase
		
		If dDataBase == dDatSis      
		    // dDatSis - 6 // retirado por Daniel: Este comando n„o produz nenhum efeito - Analisar.
			MV_PAR01 := SubStr(DtoS(dDatSis),5,2) + SubStr(DtoS(dDatSis),1,4)
			MV_PAR11 := 999999
			MV_PAR03 := 2    
			MV_PAR08 := Val(SubStr(DtoS(dDatSis),5,2))
			MV_PAR04 := 3
			MV_PAR09 := 1
			MV_PAR10 := 1
//			MV_PAR05 := SPACE(6)
			/*
			SELECT A3_COD FROM SA3010
			WHERE A3_DESLIG = ''
			AND A3_TIPO = 'E'
			AND A3_EMAIL <> ''
			AND SA3010.D_E_L_E_T_ = ''
			
			SELECT A3_COD FROM SU7010, SA3010
			WHERE U7_CODVEN <> ''
			AND U7_CODVEN = A3_COD
			AND A3_COD <> '000204'
			AND A3_DESLIG = ''
			AND SU7010.D_E_L_E_T_ = ''
			AND SA3010.D_E_L_E_T_ = ''
			*/
			
			Qry := " SELECT A3_COD"
			Qry += " FROM " + RetSQLName("SA3")
			Qry += " WHERE A3_DESLIG = ''"
			Qry += " AND A3_TIPO = 'E'"
			Qry += " AND A3_EMAIL <> ''"
			Qry += " AND " + RetSQLName("SA3") + ".D_E_L_E_T_ = ''"
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
			Qry += " AND " + RetSQLName("SU7") + ".D_E_L_E_T_ = ''"
			Qry += " AND " + RetSQLName("SA3") + ".D_E_L_E_T_ = ''"
			Qry := ChangeQuery(Qry)
			
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,Qry),"Qry",.F.,.T.)
			
			DbSelectArea("Qry")
			DbGoTop()
			While Qry->(!EOF())
				aadd(aCod_Rep,{Qry->A3_COD})
				Qry->(DbSkip())
			EndDo
			Qry->(dbCloseArea())
			
			ConOut("--------------------------")
			ConOut('Inicio - ' + dToc(date())+' - '+Time())
			ConOut("--------------------------")
			For zi := 1 To Len(aCod_Rep)
				MV_PAR02 := aCod_Rep[zi,1]
				ConOut("--------------------------")
				ConOut('Inicio - ' + aCod_Rep[zi,1]+' - '+Time())
				ConOut("--------------------------")
				
				RunProc()
				
				ConOut("--------------------------")
				ConOut('Fim - ' + aCod_Rep[zi,1]+' - '+Time())
				ConOut("--------------------------")
				
				QRY1->(dbCloseArea())
				QRY2->(dbCloseArea())
				QRY3->(dbCloseArea())
				TRB->(DbCloseArea())
				Ferase(_cArqTrb+".DBF")
				Ferase(_cArqTrb+OrdBagExt())
			Next
			ConOut("--------------------------")
			ConOut('Fim - ' + dToc(date())+' - '+Time())
			ConOut("--------------------------")
			RestArea(_xArea)
		EndIf
	EndIf
EndIf

Return

/*====================================================================================\
|PROCESSAMENTO DOS DADOS, CRIA«√O DO ARQUIVO TEMPOR¡RIO, CRIA«√O DO DBF E ENVIO DO E-MAIL
\====================================================================================*/
Static Function RunProc()
Local _mes
Local _Media:= 0
Local _MediaC:= 0
Local nPar_Med:= 0
Local cEmail:= ""
Local cAssunto:= ""                                                                                              
Local aEnv_025:= {}
Local nTot_001:= nTot_002:=nTot_003:=nTot_004:=nTot_005:=nTot_006:=nTot_007:=nTot_008:=nTot_009:=nTot_010:=nTot_011:=nTot_012:=nTot_013:=0
Local nCTot_001:= nCTot_002:=nCTot_003:=nCTot_004:=nCTot_005:=nCTot_006:=nCTot_007:=nCTot_008:=nCTot_009:=nCTot_010:=nCTot_011:=nCTot_012:=nCTot_013:=0
Local nLTot_001:= nLTot_002:=nLTot_003:=nLTot_004:=nLTot_005:=nLTot_006:=nLTot_007:=nLTot_008:=nLTot_009:=nLTot_010:=nLTot_011:=nHTot_012:=nLTot_013:=0 
Local cQuery := ""  // JBS 22/03/2010
Local cUniao := ""  // JBS 22/03/2010
Local aRankChav :={}  // MCVN 26/08/10  
Local aTmp      :={}  // MCVN 27/08/10             
Local cVendedor := ""

//Local cArqExcell:= GetSrvProfString("STARTPATH","")+"Excell-DBF\"+_cDipUsr+"-DIPR025" // JBS 08/12/2005 

// Alterado para gravar os arquivos na pasta protheus_data - Por Sandro em 19/11/09. 
Local cArqExcell:= "\Excell-DBF\"+_cDipUsr+"-DIPR025" // JBS 08/12/2005
Local _x, nEmp, wi, nI
Local _E
// Determina os 12 meses que ser„o apresentados

If (EMPTY(ALLTRIM(DTOS(MV_PAR12)))  .AND. empty(ALLTRIM(DTOS(MV_PAR13))) )
	_nMesFim := Substr(MV_PAR01,1,2)
	_nAnoFim := Substr(MV_PAR01,3,4)

	If Val(_nMesFim) == 12
		_nMesIni := 1
		_nAnoIni := Val(Substr(MV_PAR01,3,4))
	Else
		_nMesIni := Val(_nMesFim) + 1
		_nAnoIni := Val(_nAnoFim) - 1
	EndIf
Else
	_nMesIni := Val(Substr(dtos(MV_PAR12),5,2))
	_nAnoIni := Val(Substr(dtos(MV_PAR12),1,4))
	_nMesFim := Substr(dtos(MV_PAR13),5,2)
	_nAnoFim := Substr(dtos(MV_PAR13),1,4)

EndIF
_nParIni := AllTrim(Str(_nAnoIni))+AllTrim(StrZero(_nMesIni,2))
_nParFim := AllTrim(_nAnoFim)+AllTrim(_nMesFim) 
//_nParIni := "200706"
//_nParFim := "200706"

/*
SELECT D2_CLIENTE, D2_LOJA, A1_NOME, A1_MUN, A1_EST, A1_VEND, LEFT(D2_EMISSAO,6) D2_EMISSAO, SUM(D2_TOTAL + D2_VALFRE + D2_SEGURO + D2_DESPESA) D2_TOTAL
FROM SD2010, SA1010, SF4010, SC5010, SU7010
WHERE LEFT(D2_EMISSAO,6) BETWEEN '200403' AND '200403'
AND D2_CLIENTE = A1_COD
AND D2_LOJA = A1_LOJA
AND D2_TES = F4_CODIGO
AND F4_DUPLIC = 'S'
AND D2_FILIAL = C5_FILIAL
AND D2_PEDIDO = C5_NUM
AND C5_OPERADO = U7_COD

-- **********  APOIO  **********
--	AND U7_VEND = 2
--  OR U7_COD  = '000015'

-- ********* CALLCENTER ********
--	AND U7_VEND = 1
--	AND U7_COD <> '000015'

-- ********** VENDEDOR **********
-- AND C5_VEND1 = '006724'

AND SD2010.D_E_L_E_T_<> '*'
AND SF4010.D_E_L_E_T_<> '*'
AND SA1010.D_E_L_E_T_<> '*'
AND SU7010.D_E_L_E_T_<> '*'
AND SC5010.D_E_L_E_T_<> '*'
GROUP BY D2_CLIENTE, D2_LOJA, A1_NOME, A1_MUN, A1_EST, A1_VEND, LEFT(D2_EMISSAO,6)
ORDER BY D2_CLIENTE, D2_LOJA, LEFT(D2_EMISSAO,6)
*/

ProcRegua(600)
For _x := 1 to 200
	IncProc("Processando faturamento . . . ")
Next               
//-------------------------------------------------------------------------------------------
// JBS 22/03/2010 - Montagem da Query, sao duas querys unidas por empresas.
// Empresa 010 uniada a empresa 040. 
// Esta primeira consulta os produtos faturados dentro de um periodo e atendendo
// Aos parametros informados pelo usuario.
// A array aEmpresa determina quais empresas/filiais podem ser processadas.
//-------------------------------------------------------------------------------------------
cUniao := "" 
cQuery := "" 

For nEmp := 1 to len(aEmpresa)

	 If Select('SX2_2') > 0
	     SX2_2->( DbCloseArea() ) 
	 EndIf

     cQuery += cUniao + fQuery01(aEmpresa[nEmp][01],aEmpresa[nEmp][02])
     cUniao  := "  UNION  " 
Next nEmp

If Select("QRY1") > 0
	QRY1->( DbCloseArea() )
EndIf

//TcQuery cQuery NEW ALIAS "QRY1"        

cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"QRY1",.T.,.T.)

memowrite('DIPR25A_SD2_'+SM0->M0_CODIGO+'0_'+SM0->M0_CODFIL+'.SQL',cQuery)

/*
SELECT SUM(D1_TOTAL) D1_TOTAL, SUBSTRING(D1_DTDIGIT,1,6) D1_DTDIGIT, D1_FORNECE, D1_LOJA, A1_NOME, A1_EST
FROM SD1010, SD2010, SF4010, SC5010, SU7010, SA1010
WHERE SUBSTRING(D1_DTDIGIT,1,6) BETWEEN '200403' AND '200403'
AND D1_TIPO   = 'D'
AND D1_FORNECE = A1_COD
AND D1_LOJA    = A1_LOJA
AND D1_FILIAL = D2_FILIAL
AND D1_NFORI  = D2_DOC
AND D1_ITEMORI= D2_ITEM
AND D1_TES    = F4_CODIGO
AND F4_DUPLIC = 'S'
AND D2_PEDIDO = C5_NUM
AND C5_OPERADO = U7_COD

-- **********  APOIO  **********
--	AND U7_VEND = 2

-- ********* CALLCENTER ********
--	AND U7_VEND = 1
--	AND U7_COD <> '000015'

-- ********** VENDEDOR **********
AND C5_VEND1 = '006724'

AND SD1010.D_E_L_E_T_ <> '*'
AND SD2010.D_E_L_E_T_ <> '*'
AND SF4010.D_E_L_E_T_ <> '*'
AND SC5010.D_E_L_E_T_ <> '*'
AND SU7010.D_E_L_E_T_ <> '*'
AND SA1010.D_E_L_E_T_ <> '*'

GROUP BY SUBSTRING(D1_DTDIGIT,1,6), D1_FORNECE, D1_LOJA, A1_NOME, A1_EST
ORDER BY D1_FORNECE, D1_LOJA, D1_DTDIGIT
*/

ProcRegua(600)
For _x := 1 to 400
	IncProc("Processando devoluÁıes . . . ")
Next

cUniao := "" 
cQuery := ""
 
For nEmp := 1 to len(aEmpresa)

	If Select('SX2_2') > 0
	    SX2_2->( DbCloseArea() ) 
	EndIf

     cQuery += cUniao + fQuery02(aEmpresa[nEmp][01],aEmpresa[nEmp][02])
     cUniao  := "  UNION  " 
Next nEmp
cQuery += " ORDER BY D1_FORNECE, D1_LOJA, D1_DTDIGIT"

If Select("QRY2") > 0
	QRY2->( DbCloseArea() )
EndIf

TcQuery cQuery NEW ALIAS "QRY2"
//aviso('query',cQuery,,,,,,.T.)
memowrite('DIPR25A_SD1_'+SM0->M0_CODIGO+'0_'+SM0->M0_CODFIL+'.SQL',cQuery)

ProcRegua(300)
For _x := 1 to 200
	IncProc("Processando carteira. . . ")
Next

QRY3 := "SELECT A1_COD, "
QRY3 += " A1_LOJA, " 
QRY3 += " A1_NOME, "
QRY3 += " A1_MUN, "
QRY3 += " A1_EST, "
QRY3 += " A1_VEND VENDEDOR,"
QRY3 += " A1_PRICOM, "
QRY3 += " A1_ULTCOM, "
QRY3 += " A1_XCANALV, " //Reginaldo Borges 28/08/2012
QRY3 += " A1_CNAE, "    //MCVN 17/01/2013
QRY3 += " A1_CNES, "    //MCVN 17/01/2013
QRY3 += " A1_DESCNES, "    //MCVN 17/01/2013
QRY3 += " A1_HPAGE, "
QRY3 += " A1_SATIV1, "
QRY3 += " A1_SATIV8, " //Giovani Zago	06/10/11
QRY3 += " A1_OBSERV, "
QRY3 += " X5_DESCRI, "
QRY3 += " A1_CGC, "
QRY3 += " A1_INSCR,  "
QRY3 += " A1_GRPVEN, "     
//QRY3 += " A1_VENDKC, "RBORGES 01/11/13 - Comentado conforme solicitaÁ„o do ALVARO MENEZES.
//QRY3 += "       A1_TECNICO, " RBORGES 01/10/13 - Comentado conforme solicitaÁ„o do Maximo.
QRY3 += " A1_TECN_3, "
QRY3 += " A1_TECN_A, "
QRY3 += " A1_TECN_R, "//Giovani Zago 17/08/11
QRY3 += " A1_TECN_C, "//Reginaldo Borges 02/10/2012
QRY3 += " A1_TECN_B,"  // Reginaldo Borges 06/08/2013
QRY3 += " A1_XTEC_SP, "//Reginaldo Borges 22/02/2013
QRY3 += " A1_XTEC_MA, "//Reginaldo Borges 22/02/2013
QRY3 += " A1_XTEC_HQ, "//Reginaldo Borges 22/02/2013
QRY3 += " A1_VENDHQ,  "//Reginaldo Borges 01/11/2013
QRY3 += " A1_XVENDSP, "//Reginaldo Borges 26/09/2013
QRY3 += " A1_END, "  //Giovani Zago 17/08/11 
QRY3 += " A1_EMAILD "  //FELIPE DURAN 11/10/2019
QRY3 += " FROM " 
QRY3 += RetSQLName("SA1") + ", "
QRY3 += RetSQLName("SX5") + ", "
QRY3 += RetSQLName("SA3")

QRY3 += " WHERE " + RetSQLName("SA1") + ".D_E_L_E_T_ = ''"
QRY3 += " AND " + RetSQLName("SX5") + ".D_E_L_E_T_ = ''"
QRY3 += " AND " + RetSQLName("SA3") + ".D_E_L_E_T_ = ''"
QRY3 += " AND X5_TABELA = 'T3'"
//QRY3 += " AND X5_FILIAL = '"+xFilial("SX5")+"' "
QRY3 += " AND X5_CHAVE = A1_SATIV1 "  

QRY3 += " AND A1_VEND = A3_COD "

If !Empty(MV_PAR06)
	QRY3 += " AND A1_GRPVEN = '" +MV_PAR06+"'"
EndIf

If U_ListVend() != ''
	QRY3 += " AND A1_VEND " + U_ListVend()
EndIf

If !Empty(MV_PAR02) // VENDEDOR
	QRY3 += " AND A1_VEND = '" + MV_PAR02 + "'"
Else
   //	If MV_PAR04 == 1 // APOIO
	//	QRY3 += " AND A3_TIPO = 'E'	"
If MV_PAR04 == 2//	ElseIf MV_PAR04 == 2 // CALL CENTER
		QRY3 += " AND A3_TIPO = 'I' "
	EndIf
EndIf

QRY3 += " ORDER BY A1_COD, A1_LOJA "

cQuery := ChangeQuery(QRY3)
dbUseArea(.T., "TOPCONN", TCGenQry(,,QRY3), 'QRY3', .F., .T.)
memowrite('DIPR25A_SA1_'+SM0->M0_CODIGO+'0_'+SM0->M0_CODFIL+'.SQL',QRY3)  // JBS 29/07/2010

ProcRegua(600)
For _x := 1 to 600
	IncProc("Encerrando processamento . . . ")
Next

// cria arquivo com meses colunados

_aCampos := {}                                          

AAdd(_aCampos ,{"GRUPO", "C",39,0})
_aTamSX3 := TamSX3("D2_CLIENTE")
AAdd(_aCampos ,{"CLIENTE", "C",_aTamSX3[1],_aTamSX3[2]})
_aTamSX3 := TamSX3("D2_LOJA")
AAdd(_aCampos ,{"LOJA", "C",_aTamSX3[1],_aTamSX3[2]})
_aTamSX3 := TamSX3("A1_NOME")
AAdd(_aCampos ,{"NOME", "C",_aTamSX3[1],_aTamSX3[2]})
_aTamSX3 := TamSX3("A1_MUN")
AAdd(_aCampos ,{"CIDADE", "C",_aTamSX3[1],_aTamSX3[2]})
_aTamSX3 := TamSX3("A1_EST")
AAdd(_aCampos ,{"UF", "C",_aTamSX3[1],_aTamSX3[2]})
_aTamSX3 := TamSX3("A1_VEND")
AAdd(_aCampos ,{"VENDEDOR", "C",_aTamSX3[1],_aTamSX3[2]})
_aTamSX3 := TamSX3("A3_NREDUZ") 
AAdd(_aCampos ,{"NOME_VEN", "C",_aTamSX3[1],_aTamSX3[2]})
_aTamSX3 := TamSX3("A1_SATIV1")
AAdd(_aCampos ,{"SEGMENTO", "C",_aTamSX3[1]+30,_aTamSX3[2]})
_aTamSX3 := TamSX3("A1_NOME")
AAdd(_aCampos ,{"DESCRICAO", "C",_aTamSX3[1],_aTamSX3[2]}) 
_aTamSX3 := TamSX3("A1_PRICOM")
AAdd(_aCampos ,{"PRI_COMPRA", "D",_aTamSX3[1],_aTamSX3[2]})
_aTamSX3 := TamSX3("A1_ULTCOM")
AAdd(_aCampos ,{"ULT_COMPRA", "D",_aTamSX3[1],_aTamSX3[2]})
_aTamSX3 := TamSX3("A1_HPAGE")
AAdd(_aCampos ,{"HOMEPAGE", "C",_aTamSX3[1],_aTamSX3[2]})
AAdd(_aCampos ,{"HOMECP_O", "C",30,0})
AAdd(_aCampos ,{"HOMECP"  , "C",30,0})

nNom_Cam := _nMesIni
For wi := 1 to 12
	_aTamSX3 := TamSX3("D2_TOTAL")
	AAdd(_aCampos ,{"M"+StrZero(nNom_Cam,2),"N",_aTamSX3[1],_aTamSX3[2]})
	If Upper(_cDipUsr) $ cSHWCUST// JBS 20/03/2006
		AAdd(_aCampos ,{"C"+StrZero(nNom_Cam,2),"N",_aTamSX3[1],_aTamSX3[2]}) // JBS 20/03/2006
		AAdd(_aCampos ,{"L"+StrZero(nNom_Cam,2),"N",_aTamSX3[1],_aTamSX3[2]}) // JBS 20/03/2006
	EndIf // JBS 20/03/2006
	If nNom_Cam = 12
		nNom_Cam := 1
	Else
		nNom_Cam++
	EndIf
Next

_aTamSX3 := TamSX3("D2_TOTAL")
AAdd(_aCampos ,{"TOTAL","N",_aTamSX3[1],_aTamSX3[2]})
AAdd(_aCampos ,{"MEDIA","N",_aTamSX3[1],_aTamSX3[2]})
If Upper(_cDipUsr) $ cSHWCUST             // JBS 20/03/2006
	AAdd(_aCampos ,{"CUST_TOTAL","N",_aTamSX3[1],_aTamSX3[2]}) // JBS 20/03/2006
	AAdd(_aCampos ,{"MARG_TOTAL","N",_aTamSX3[1],_aTamSX3[2]}) // JBS 20/03/2006
	AAdd(_aCampos ,{"CUST_MEDIA","N",_aTamSX3[1],_aTamSX3[2]}) // JBS 20/03/2006
	AAdd(_aCampos ,{"MARG_MEDIA","N",_aTamSX3[1],_aTamSX3[2]}) // JBS 20/03/2006
EndIf
AAdd(_aCampos ,{"CNT"    , "N", 12,4})
AAdd(_aCampos ,{"PCT_CNT", "N", 12,4})
AAdd(_aCampos ,{"OBSERVACAO", "C", 40,0})           


// Eriberto 07/10/09
_aTamSX3 := TamSX3("A1_CGC")
AAdd(_aCampos ,{"CNPJ", "C",_aTamSX3[1],_aTamSX3[2]}) 
_aTamSX3 := TamSX3("A1_INSCR")                                       

AAdd(_aCampos ,{"IE", "C",_aTamSX3[1],_aTamSX3[2]})
 
_aTamSX3 := TamSX3("A1_SATIV8")//Giovani Zago	06/10/11
AAdd(_aCampos ,{"SEGMENTO2", "C",_aTamSX3[1]+30,_aTamSX3[2]})//Giovani Zago	06/10/11 

	AAdd(_aCampos ,{"SEG_DESCR2"   , "C", TamSX3("X5_DESCRI")[1]    ,TamSX3("X5_DESCRI")[2]}) //Giovani Zago 10/10/11
_aTamSX3 := TamSX3("A1_END")                     //Giovani Zago 18/08/11
AAdd(_aCampos ,{"ENDERECO", "C",_aTamSX3[1],_aTamSX3[2]})//Giovani Zago 18/08/11 

_aTamSX3 := TamSX3("A1_XCANALV")
AAdd(_aCampos ,{"CANAL_VEND", "C",_aTamSX3[1]+40,_aTamSX3[2]})// Reginaldo Borges 28/08/2012

_aTamSX3 := TamSX3("A1_CNAE")
AAdd(_aCampos ,{"CNAE", "C",_aTamSX3[1]+30,_aTamSX3[2]})// MCVN 17/01/2013

_aTamSX3 := TamSX3("A1_CNES")
AAdd(_aCampos ,{"CNES", "C",_aTamSX3[1]+30,_aTamSX3[2]})// MCVN 17/01/2013


// Incluindo os tÈcnicos no relatÛrio  -   MCVN 04/12/07

/* RBORGES 01/11/13 - Comentado conforme solicitaÁ„o do ALVARO MENEZES.
_aTamSX3 := TamSX3("A3_COD")
AAdd(_aCampos ,{"VENDKC", "C",_aTamSX3[1],_aTamSX3[2]})
_aTamSX3 := TamSX3("A3_NOME")
AAdd(_aCampos ,{"N_VENDKC", "C",_aTamSX3[1],_aTamSX3[2]})
 */
_aTamSX3 := TamSX3("A3_COD")
AAdd(_aCampos ,{"TEC_AMCOR", "C",_aTamSX3[1],_aTamSX3[2]})
_aTamSX3 := TamSX3("A3_NOME")
AAdd(_aCampos ,{"NTEC_AMCOR", "C",_aTamSX3[1],_aTamSX3[2]})

_aTamSX3 := TamSX3("A3_COD")
AAdd(_aCampos ,{"TEC_3M", "C",_aTamSX3[1],_aTamSX3[2]})
_aTamSX3 := TamSX3("A3_NOME")
AAdd(_aCampos ,{"N_TEC_3M", "C",_aTamSX3[1],_aTamSX3[2]})

_aTamSX3 := TamSX3("A3_COD")
AAdd(_aCampos ,{"TEC_ROCHE", "C",_aTamSX3[1],_aTamSX3[2]})
_aTamSX3 := TamSX3("A3_NOME")
AAdd(_aCampos ,{"NTEC_ROCHE", "C",_aTamSX3[1],_aTamSX3[2]})
/*  RBORGES 01/10/13 - Comentado conforme solicitaÁ„o do Maximo.
_aTamSX3 := TamSX3("A3_COD")
AAdd(_aCampos ,{"TECNICO", "C",_aTamSX3[1],_aTamSX3[2]})
_aTamSX3 := TamSX3("A3_NOME")
AAdd(_aCampos ,{"NOME_TEC", "C",_aTamSX3[1],_aTamSX3[2]}) 
*/
_aTamSX3 := TamSX3("A3_COD")
AAdd(_aCampos ,{"TEC_CONVAT", "C",_aTamSX3[1],_aTamSX3[2]})
_aTamSX3 := TamSX3("A3_NOME")
AAdd(_aCampos ,{"NTEC_CONVA", "C",_aTamSX3[1],_aTamSX3[2]})

_aTamSX3 := TamSX3("A3_COD")
AAdd(_aCampos ,{"TEC_BBRAU", "C",_aTamSX3[1],_aTamSX3[2]})
_aTamSX3 := TamSX3("A3_NOME")
AAdd(_aCampos ,{"NTEC_BBRAU", "C",_aTamSX3[1],_aTamSX3[2]})

_aTamSX3 := TamSX3("A3_COD")
AAdd(_aCampos ,{"TECN_SP", "C",_aTamSX3[1],_aTamSX3[2]})
_aTamSX3 := TamSX3("A3_NOME")
AAdd(_aCampos ,{"NTECN_SP", "C",_aTamSX3[1],_aTamSX3[2]})
                            
_aTamSX3 := TamSX3("A3_COD")
AAdd(_aCampos ,{"TECN_MA", "C",_aTamSX3[1],_aTamSX3[2]})
_aTamSX3 := TamSX3("A3_NOME")
AAdd(_aCampos ,{"NTECN_MA", "C",_aTamSX3[1],_aTamSX3[2]})                  
_aTamSX3 := TamSX3("A3_COD")
AAdd(_aCampos ,{"TECN_HQ", "C",_aTamSX3[1],_aTamSX3[2]})
_aTamSX3 := TamSX3("A3_NOME")
AAdd(_aCampos ,{"NTECN_HQ", "C",_aTamSX3[1],_aTamSX3[2]})

_aTamSX3 := TamSX3("A3_COD")
AAdd(_aCampos ,{"VENDSP", "C",_aTamSX3[1],_aTamSX3[2]})
_aTamSX3 := TamSX3("A3_NOME")
AAdd(_aCampos ,{"N_VENDSP", "C",_aTamSX3[1],_aTamSX3[2]})

_aTamSX3 := TamSX3("A3_COD")
AAdd(_aCampos ,{"VENDHQ", "C",_aTamSX3[1],_aTamSX3[2]})
_aTamSX3 := TamSX3("A3_NOME")
AAdd(_aCampos ,{"N_VENDHQ", "C",_aTamSX3[1],_aTamSX3[2]})
//INCLUIDO E-MAIL DE CAMPO CUSTOMIZADO - FELIPE DURAN - 11/10/2019
_aTamSX3 := TamSX3("A1_EMAILD")
AAdd(_aCampos ,{"EMAILD", "C",_aTamSX3[1],_aTamSX3[2]})


_cArqTrb := CriaTrab(_aCampos,.T.)
DbUseArea(.T.,,_cArqTrb,"TRB",.F.,.F.)

_cChave  := 'CLIENTE + LOJA + VENDEDOR'   // JBS 29/07/2010 - Incluido o vendedor na chave.
IndRegua("TRB",_cArqTrb,_cChave,,,"Criando Indice...(cliente)")

ProcRegua(5000)

DbSelectArea("QRY1")
QRY1->(dbGotop())
DbSelectArea("TRB")
SA3->(DbSetOrder(1))
While QRY1->(!Eof())
	
	IncProc(OemToAnsi("Vendas..: " + QRY1->D2_CLIENTE+'-'+QRY1->D2_LOJA))
	
	If !Empty(QRY1->F2_VEND2) .And. QRY1->D2_FORNEC = '000996' .And. MV_PAR07 <> 1
		cVendedor := QRY1->F2_VEND2
	Else
		cVendedor := QRY1->VENDEDOR
	EndIf
	
	If TRB->(!DbSeek(QRY1->D2_CLIENTE + QRY1->D2_LOJA + cVendedor))  // JBS 29/07/2010 - Incluir o vendedor na quebra por cliente
                 
		SA3->( DbSeek(cFilSA3 + cVendedor)) 
		
		RecLock("TRB",.T.)
		ACY->(dbSeek(xFilial('ACY')+QRY1->A1_GRPVEN))
		TRB->GRUPO      := QRY1->A1_GRPVEN+" - "+ACY->ACY_DESCRI
		TRB->CLIENTE    := QRY1->D2_CLIENTE
		TRB->LOJA       := QRY1->D2_LOJA
		TRB->NOME       := QRY1->A1_NOME
		TRB->CIDADE     := QRY1->A1_MUN
		TRB->UF         := QRY1->A1_EST          
		TRB->VENDEDOR   := cVendedor // JBS 29/07/2010 - Usando o vendedor fixo da query
		TRB->NOME_VEN   := SA3->A3_NREDUZ
		TRB->SEGMENTO   := QRY1->A1_SATIV1
		TRB->SEGMENTO2  := QRY1->A1_SATIV8 //Giovani Zago	06/10/11 
		TRB->SEG_DESCR2	:= IF(!Empty(QRY1->A1_SATIV8),posicione("SX5",1,xFilial("SX5")+"T3"+ALLTRIM(QRY1->A1_SATIV8),"X5_DESCRI"),"")//Giovani Zago 10/10/11
	 	TRB->DESCRICAO := QRY1->X5_DESCRI
		TRB->PRI_COMPRA:= CTOD(SUBSTRING(QRY1->A1_PRICOM,7,2)+'/'+SUBSTRING(QRY1->A1_PRICOM,5,2)+'/'+SUBSTRING(QRY1->A1_PRICOM,1,4))
		TRB->ULT_COMPRA:= CTOD(SUBSTRING(QRY1->A1_ULTCOM,7,2)+'/'+SUBSTRING(QRY1->A1_ULTCOM,5,2)+'/'+SUBSTRING(QRY1->A1_ULTCOM,1,4))
		TRB->HOMEPAGE  := QRY1->A1_HPAGE
		TRB->HOMECP_O  := Space(len(QRY1->A1_HPAGE))
		TRB->HOMECP    := Space(len(QRY1->A1_HPAGE))
		TRB->TOTAL     := TRB->TOTAL + QRY1->D2_TOTAL
		TRB->CNT       := 1
		TRB->OBSERVACAO:= QRY1->A1_OBSERV 
		//TRB->VENDKC    := QRY1->A1_VENDKC
		//SA3->(dbSeek(xFilial('SA3')+QRY1->A1_VENDKC))RBORGES 01/11/13 - Comentado conforme solicitaÁ„o do ALVARO MENEZES.
		//TRB->N_VENDKC  := SA3->A3_NOME		
		//TRB->TECNICO   := QRY1->A1_TECNICO             RBORGES 01/10/13 - Comentado conforme solicitaÁ„o do Maximo.
		//SA3->(dbSeek(xFilial('SA3')+QRY1->A1_TECNICO))
		//TRB->NOME_TEC  := SA3->A3_NOME                                                            
		TRB->TEC_3M    := QRY1->A1_TECN_3
		SA3->(dbSeek(xFilial('SA3')+QRY1->A1_TECN_3))
		TRB->N_TEC_3M  := SA3->A3_NOME                                                             
		TRB->TEC_AMCOR := QRY1->A1_TECN_A
		SA3->(dbSeek(xFilial('SA3')+QRY1->A1_TECN_A))
		TRB->NTEC_AMCOR:=  SA3->A3_NOME 	
		TRB->TEC_ROCHE := QRY1->A1_TECN_R
		SA3->(dbSeek(xFilial('SA3')+QRY1->A1_TECN_R))
		TRB->NTEC_ROCHE:=  SA3->A3_NOME
		TRB->TEC_CONVAT:= QRY1->A1_TECN_C
		SA3->(dbSeek(xFilial('SA3')+QRY1->A1_TECN_C))
		TRB->NTEC_CONVA :=  SA3->A3_NOME
		TRB->TEC_BBRAU  := QRY1->A1_TECN_B 
		SA3->(dbSeek(xFilial('SA3')+QRY1-> A1_TECN_B))
        TRB->NTEC_BBRAU	:= SA3->A3_NOME
		TRB->TECN_SP:= QRY1->A1_XTEC_SP
		SA3->(dbSeek(xFilial('SA3')+QRY1->A1_XTEC_SP)) 
		TRB->NTECN_SP   := SA3->A3_NOME
		TRB->TECN_MA:= QRY1->A1_XTEC_MA		
		SA3->(dbSeek(xFilial('SA3')+QRY1->A1_XTEC_MA))
		TRB->NTECN_MA   := SA3->A3_NOME
	   	TRB->TECN_HQ:= QRY1->A1_XTEC_HQ
		SA3->(dbSeek(xFilial('SA3')+QRY1->A1_XTEC_HQ))
		TRB->NTECN_HQ   := SA3->A3_NOME
		TRB->VENDSP     := QRY1->A1_XVENDSP
		SA3->(dbSeek(xFilial('SA3')+QRY1->A1_XVENDSP))
		TRB->N_VENDSP   := SA3->A3_NOME
		TRB->VENDHQ     := QRY1->A1_VENDHQ
		SA3->(dbSeek(xFilial('SA3')+QRY1->A1_VENDHQ))
		TRB->N_VENDHQ   := SA3->A3_NOME
		//		QRY1->A1_EMAILD //INCLUSAO DO EMAILD - FELIPE DURAN - 11/10/2019
		// EAP - DELTA 2008 corrigido o campo para tirar  ; devido a erro no exce
		//TRB->EMAILD:= AllTrim(StrTran(QRY1->A1_EMAILD, ";","|" ))
		_E:=0
        _cmail:= AllTrim(QRY1->A1_EMAILD)
		FOR _E = 1 TO LEN(QRY1->A1_EMAILD)
		  IF SUBSTRING(QRY1->A1_EMAILD,_E,1) == ';'
		      _cmail:=SUBSTRING(QRY1->A1_EMAILD,1,_E-1)
		  	 Exit
		  Endif
		 Next _E
		TRB->EMAILD 	:= _cmail
	    // Eriberto 07/10/09
		TRB->CNPJ := QRY1->A1_CGC
		TRB->IE   := QRY1->A1_INSCR
		//Giovani Zago 18/08/11
		TRB->ENDERECO   := QRY1->A1_END 	
   		TRB->CANAL_VEND	:= IF(!Empty(QRY1->A1_XCANALV),posicione("SX5",1,xFilial("SX5")+"X0"+ALLTRIM(QRY1->A1_XCANALV),"X5_DESCRI"),"") //Reginaldo Borges
   		TRB->CNAE := QRY1->A1_CNAE+' - '+IF(!Empty(QRY1->A1_CNAE),posicione("CC3",1,xFilial("CC3")+ALLTRIM(QRY1->A1_CNAE),"CC3_DESC"),"") 
   		TRB->CNES := QRY1->A1_CNES +' - '+ QRY1->A1_DESCNES
				
		//************************
		nTotMes := TRB->(FieldGet(FieldPos('M'+SubStr(QRY1->D2_EMISSAO,5,2)))) + QRY1->D2_TOTAL // JBS 20/03/2006
		TRB->(Fieldput(FieldPos('M'+SubStr(QRY1->D2_EMISSAO,5,2)),nTotMes))      // JBS 20/03/2006
		If Upper(_cDipUsr) $ cSHWCUST     // JBS 20/03/2006
			nCusto := TRB->(FieldGet(FieldPos('C'+SubStr(QRY1->D2_EMISSAO,5,2)))) + (QRY1->D2_CUSDIP)  // JBS 20/03/2006
			TRB->CUST_TOTAL := TRB->CUST_TOTAL + (QRY1->D2_CUSDIP)// JBS 20/03/2006
			TRB->(Fieldput(FieldPos('C'+SubStr(QRY1->D2_EMISSAO,5,2)),nCusto))   // JBS 20/03/2006
		EndIf
	Else
		RecLock("TRB",.F.)
		TRB->TOTAL := TRB->TOTAL + QRY1->D2_TOTAL
		nTotMes := TRB->(FieldGet(FieldPos('M'+SubStr(QRY1->D2_EMISSAO,5,2)))) + QRY1->D2_TOTAL // JBS 20/03/2006
		TRB->(Fieldput(FieldPos('M'+SubStr(QRY1->D2_EMISSAO,5,2)),nTotMes))       // JBS 20/03/2006
		If Upper(_cDipUsr) $ cSHWCUST      // JBS 20/03/2006
			nCusto := TRB->(FieldGet(FieldPos('C'+SubStr(QRY1->D2_EMISSAO,5,2)))) + (QRY1->D2_CUSDIP)  // JBS 20/03/2006
			TRB->CUST_TOTAL := TRB->CUST_TOTAL + (QRY1->D2_CUSDIP) // JBS 20/03/2006
			TRB->(Fieldput(FieldPos('C'+SubStr(QRY1->D2_EMISSAO,5,2)),nCusto))    // JBS 20/03/2006
		EndIf
	EndIf

	MsUnLock()
	QRY1->(dbSkip())
EndDo

ProcRegua(500)

DbSelectArea("QRY2")
QRY2->(dbGotop())
DbSelectArea("TRB")
While QRY2->(!Eof())
	
	IncProc(OemToAnsi("DevoluÁıes..: " + QRY2->D1_FORNECE+'-'+QRY2->D1_LOJA))
	
	If !Empty(QRY2->F2_VEND2) .And. QRY2->D2_FORNEC = '000996' .And. MV_PAR07 <> 1
		cVendedor := QRY2->F2_VEND2
	Else
		cVendedor := QRY2->VENDEDOR
	EndIf
	
	If TRB->(!DbSeek(QRY2->D1_FORNECE + QRY2->D1_LOJA))

		SA3->(dbSeek(cFilSA3+cVendedor)) // JBS 29/07/2010 - Incluido o vendedor na quebra do cliente

		RecLock("TRB",.T.)               
		ACY->(dbSeek(xFilial('ACY')+QRY2->A1_GRPVEN))   
		TRB->GRUPO     := QRY2->A1_GRPVEN+" - "+ACY->ACY_DESCRI	
		TRB->CLIENTE   := QRY2->D1_FORNECE
		TRB->LOJA      := QRY2->D1_LOJA
		TRB->NOME      := QRY2->A1_NOME
		TRB->UF        := QRY2->A1_EST  
		TRB->CIDADE    := QRY2->A1_MUN          
		TRB->VENDEDOR  := cVendedor
		TRB->NOME_VEN  := SA3->A3_NREDUZ
		TRB->SEGMENTO  := QRY2->A1_SATIV1 
			
		
			
		TRB->SEG_DESCR2	:= IF(!Empty(QRY2->A1_SATIV8),posicione("SX5",1,xFilial("SX5")+"T3"+ALLTRIM(QRY2->A1_SATIV8),"X5_DESCRI"),"")//Giovani Zago 10/10/11
		TRB->SEGMENTO2 := QRY2->A1_SATIV8 //Giovani Zago 06/10/11
		TRB->DESCRICAO := QRY2->X5_DESCRI
		TRB->PRI_COMPRA:= CTOD(SUBSTRING(QRY2->A1_PRICOM,7,2)+'/'+SUBSTRING(QRY2->A1_PRICOM,5,2)+'/'+SUBSTRING(QRY2->A1_PRICOM,1,4))
		TRB->ULT_COMPRA:= CTOD(SUBSTRING(QRY2->A1_ULTCOM,7,2)+'/'+SUBSTRING(QRY2->A1_ULTCOM,5,2)+'/'+SUBSTRING(QRY2->A1_ULTCOM,1,4))
		TRB->HOMEPAGE  := QRY2->A1_HPAGE
		TRB->HOMECP_O  := Space(len(QRY2->A1_HPAGE))
		TRB->HOMECP    := Space(len(QRY2->A1_HPAGE))
		TRB->TOTAL     := TRB->TOTAL - QRY2->D1_TOTAL
		TRB->CNT       := 1   
		TRB->OBSERVACAO:= QRY2->A1_OBSERV
		//TRB->VENDKC    := QRY2->A1_VENDKC
		//SA3->(dbSeek(xFilial('SA3')+QRY2->A1_VENDKC))  RBORGES 01/11/13 - Comentado conforme solicitaÁ„o do ALVARO MENEZES.
		//TRB->N_VENDKC  := SA3->A3_NOME		
		//TRB->TECNICO   := QRY2->A1_TECNICO             RBORGES 01/10/13 - Comentado conforme solicitaÁ„o do Maximo.
		//SA3->(dbSeek(xFilial('SA3')+QRY2->A1_TECNICO))
		//TRB->NOME_TEC  := SA3->A3_NOME                                                            
		TRB->TEC_3M    := QRY2->A1_TECN_3
		SA3->(dbSeek(xFilial('SA3')+QRY2->A1_TECN_3))
		TRB->N_TEC_3M  := SA3->A3_NOME                                                             
		TRB->TEC_AMCOR := QRY2->A1_TECN_A
		SA3->(dbSeek(xFilial('SA3')+QRY2->A1_TECN_A))
		TRB->NTEC_AMCOR:=  SA3->A3_NOME 	
		TRB->TEC_ROCHE := QRY2->A1_TECN_R
		SA3->(dbSeek(xFilial('SA3')+QRY2->A1_TECN_R))
		TRB->NTEC_ROCHE:=  SA3->A3_NOME
		TRB->TEC_CONVAT:= QRY2->A1_TECN_C
		SA3->(dbSeek(xFilial('SA3')+QRY2->A1_TECN_C))
		TRB->NTEC_CONVA:=  SA3->A3_NOME
		TRB->TEC_BBRAU  := QRY2->A1_TECN_B 
		SA3->(dbSeek(xFilial('SA3')+QRY2-> A1_TECN_B))
        TRB->NTEC_BBRAU	:= SA3->A3_NOME
		TRB->TECN_SP:= QRY2->A1_XTEC_SP
		SA3->(dbSeek(xFilial('SA3')+QRY2->A1_XTEC_SP)) 
		TRB->NTECN_SP   := SA3->A3_NOME
		TRB->TECN_MA:= QRY2->A1_XTEC_MA		
		SA3->(dbSeek(xFilial('SA3')+QRY2->A1_XTEC_MA))
		TRB->NTECN_MA   := SA3->A3_NOME
	   	TRB->TECN_HQ:= QRY2->A1_XTEC_HQ
		SA3->(dbSeek(xFilial('SA3')+QRY2->A1_XTEC_HQ))
		TRB->NTECN_HQ   := SA3->A3_NOME
		TRB->VENDSP     := QRY2->A1_XVENDSP
		SA3->(dbseek(xFilial('SA3')+QRY2->A1_XVENDSP))
		TRB->N_VENDSP   := SA3->A3_NOME
	   	TRB->VENDHQ     := QRY2->A1_VENDHQ
		SA3->(dbSeek(xFilial('SA3')+QRY2->A1_VENDHQ))
		TRB->N_VENDHQ   := SA3->A3_NOME
	    //TRB->EMAILD 	:= QRY2->A1_EMAILD //INCLUSAO DO EMAILD - FELIPE DURAN - 11/10/2019		  
	    //QRY1->A1_EMAILD //INCLUSAO DO EMAILD - FELIPE DURAN - 11/10/2019
		//EAP - DELTA 2008 corrigido o campo para tirar  ; devido a erro no exce
		//TRB->EMAILD 	:= AllTrim( StrTran(QRY2->A1_EMAILD, ";","|" ))
		_E:=0
        _cmail:= AllTrim(QRY2->A1_EMAILD)
		FOR _E = 1 TO LEN(QRY2->A1_EMAILD)
		  IF SUBSTRING(QRY2->A1_EMAILD,_E,1) == ';'
		      _cmail:=SUBSTRING(QRY2->A1_EMAILD,1,_E-1)
		  	 Exit
		  Endif
		 Next _E
		TRB->EMAILD 	:= _cmail
			
        // Eriberto 07/10/09
		TRB->CNPJ := QRY2->A1_CGC
		TRB->IE   := QRY2->A1_INSCR
			//Giovani Zago 18/08/11
		TRB->ENDERECO   := QRY2->A1_END		
		TRB->CANAL_VEND := IF(!Empty(QRY2->A1_XCANALV),posicione("SX5",1,xFilial("SX5")+"X0"+ALLTRIM(QRY2->A1_XCANALV),"X5_DESCRI"),"") // Reginaldo Borges 28/08/2012
   		TRB->CNAE := QRY2->A1_CNAE+' - '+IF(!Empty(QRY2->A1_CNAE),posicione("CC3",1,xFilial("CC3")+ALLTRIM(QRY2->A1_CNAE),"CC3_DESC"),"") 
   		TRB->CNES := QRY2->A1_CNES +' - '+ QRY2->A1_DESCNES
				
		//************************
		nTotMes := TRB->(FieldGet(FieldPos('M'+SubStr(QRY2->D1_DTDIGIT,5,2)))) - QRY2->D1_TOTAL // JBS 20/03/2006
		TRB->(Fieldput(FieldPos('M'+SubStr(QRY2->D1_DTDIGIT,5,2)),nTotMes))
		If Upper(_cDipUsr) $ cSHWCUST// JBS 20/03/2006
			nCusto := TRB->(FieldGet(FieldPos('C'+SubStr(QRY2->D1_DTDIGIT,5,2)))) - (QRY2->D2_CUSDIP) // JBS 20/03/2006
			TRB->CUST_TOTAL := TRB->CUST_TOTAL - (QRY2->D2_CUSDIP) // JBS 20/03/2006
			TRB->(Fieldput(FieldPos('C'+SubStr(QRY2->D1_DTDIGIT,5,2)),nCusto)) // JBS 20/03/2006
		EndIf // JBS 20/03/2006
	Else
		RecLock("TRB",.F.)
		TRB->TOTAL := TRB->TOTAL - QRY2->D1_TOTAL
		nTotMes := TRB->(FieldGet(FieldPos('M'+SubStr(QRY2->D1_DTDIGIT,5,2)))) - QRY2->D1_TOTAL // JBS 20/03/2006
		TRB->(Fieldput(FieldPos('M'+SubStr(QRY2->D1_DTDIGIT,5,2)),nTotMes)) // JBS 20/03/2006
		If Upper(_cDipUsr) $ cSHWCUST// JBS 20/03/2006
			nCusto := TRB->(FieldGet(FieldPos('C'+SubStr(QRY2->D1_DTDIGIT,5,2)))) - (QRY2->D2_CUSDIP) // JBS 20/03/2006
			TRB->CUST_TOTAL := TRB->CUST_TOTAL - (QRY2->D2_CUSDIP) // JBS 20/03/2006
			TRB->(Fieldput(FieldPos('C'+SubStr(QRY2->D1_DTDIGIT,5,2)),nCusto)) // JBS 20/03/2006
		EndIf // JBS 20/03/2006
	EndIf
	MsUnLock()
	QRY2->(dbSkip())
EndDo

If MV_PAR09 == 1
	
	ProcRegua(10000)
	
	DbSelectArea("QRY3")
	QRY3->(dbGotop())
	DbSelectArea("TRB")
	While QRY3->(!Eof())
		
		IncProc(OemToAnsi("Carteira......: " + QRY3->A1_COD+'-'+QRY3->A1_LOJA))
		
		If TRB->( !DbSeek(QRY3->A1_COD + QRY3->A1_LOJA + QRY3->VENDEDOR))

			SA3->(dbSeek(cFilSA3+QRY3->VENDEDOR)) 
			
			RecLock("TRB",.T.)                                      
			ACY->(dbSeek(xFilial('ACY')+QRY3->A1_GRPVEN))             
			TRB->GRUPO   := QRY3->A1_GRPVEN+" - "+ACY->ACY_DESCRI
			TRB->CLIENTE := QRY3->A1_COD
			TRB->LOJA    := QRY3->A1_LOJA
			TRB->NOME    := QRY3->A1_NOME
			TRB->CIDADE  := QRY3->A1_MUN
			TRB->UF      := QRY3->A1_EST 
			TRB->VENDEDOR:= QRY3->VENDEDOR // JBS 30/07/2010
			TRB->NOME_VEN:= SA3->A3_NREDUZ
			
			
			
			TRB->SEGMENTO:= QRY3->A1_SATIV1
				TRB->SEG_DESCR2	:= IF(!Empty(QRY3->A1_SATIV8),posicione("SX5",1,xFilial("SX5")+"T3"+ALLTRIM(QRY3->A1_SATIV8),"X5_DESCRI"),"")//Giovani Zago 10/10/11
					TRB->SEGMENTO2  := QRY3->A1_SATIV8 //Giovani Zago 06/10/11
			TRB->DESCRICAO:= QRY3->X5_DESCRI
			TRB->PRI_COMPRA:= CTOD(SUBSTRING(QRY3->A1_PRICOM,7,2)+'/'+SUBSTRING(QRY3->A1_PRICOM,5,2)+'/'+SUBSTRING(QRY3->A1_PRICOM,1,4))
			TRB->ULT_COMPRA:= CTOD(SUBSTRING(QRY3->A1_ULTCOM,7,2)+'/'+SUBSTRING(QRY3->A1_ULTCOM,5,2)+'/'+SUBSTRING(QRY3->A1_ULTCOM,1,4))
			TRB->HOMEPAGE:= QRY3->A1_HPAGE
			TRB->HOMECP_O:= Space(len(QRY3->A1_HPAGE))
			TRB->HOMECP  := Space(len(QRY3->A1_HPAGE))
			TRB->CNT     := 1
			TRB->OBSERVACAO := QRY3->A1_OBSERV
		   //TRB->VENDKC    := QRY3->A1_VENDKC
		   //SA3->(dbSeek(xFilial('SA3')+QRY3->A1_VENDKC)) RBORGES 01/11/13 - Comentado conforme solicitaÁ„o do ALVARO MENEZES.
		   //TRB->N_VENDKC  := SA3->A3_NOME		
			//TRB->TECNICO   := QRY3->A1_TECNICO             RBORGES 01/10/13 - Comentado conforme solicitaÁ„o do Maximo.
			//SA3->(dbSeek(xFilial('SA3')+QRY3->A1_TECNICO))
			//TRB->NOME_TEC  := SA3->A3_NOME                                                            
			TRB->TEC_3M    := QRY3->A1_TECN_3
			SA3->(dbSeek(xFilial('SA3')+QRY3->A1_TECN_3))
			TRB->N_TEC_3M  := SA3->A3_NOME                                                             
			TRB->TEC_AMCOR := QRY3->A1_TECN_A
			SA3->(dbSeek(xFilial('SA3')+QRY3->A1_TECN_A))
			TRB->NTEC_AMCOR:=  SA3->A3_NOME 	
			TRB->TEC_ROCHE := QRY3->A1_TECN_R
			SA3->(dbSeek(xFilial('SA3')+QRY3->A1_TECN_R))
			TRB->NTEC_ROCHE:=  SA3->A3_NOME
			TRB->TEC_CONVAT:= QRY3->A1_TECN_C
			SA3->(dbSeek(xFilial('SA3')+QRY3->A1_TECN_C))
			TRB->NTEC_CONVA:=  SA3->A3_NOME
			TRB->TEC_BBRAU  := QRY3->A1_TECN_B 
			SA3->(dbSeek(xFilial('SA3')+QRY3-> A1_TECN_B))
    	    TRB->NTEC_BBRAU	:= SA3->A3_NOME
			TRB->TECN_SP:= QRY3->A1_XTEC_SP
			SA3->(dbSeek(xFilial('SA3')+QRY3->A1_XTEC_SP)) 
			TRB->NTECN_SP   := SA3->A3_NOME
			TRB->TECN_MA:= QRY3->A1_XTEC_MA		
			SA3->(dbSeek(xFilial('SA3')+QRY3->A1_XTEC_MA))
			TRB->NTECN_MA   := SA3->A3_NOME
	   		TRB->TECN_HQ:= QRY3->A1_XTEC_HQ
			SA3->(dbSeek(xFilial('SA3')+QRY3->A1_XTEC_HQ))
			TRB->NTECN_HQ   := SA3->A3_NOME 
			TRB->VENDSP     := QRY3->A1_XVENDSP
			SA3->(dbseek(xFilial('SA3')+QRY3->A1_XVENDSP))
			TRB->N_VENDSP   := SA3->A3_NOME
			TRB->VENDHQ     := QRY3->A1_VENDHQ
	     	SA3->(dbSeek(xFilial('SA3')+QRY3->A1_VENDHQ))
     		TRB->N_VENDHQ   := SA3->A3_NOME
     	    //TRB->EMAILD 	:= QRY3->A1_EMAILD //INCLUSAO DO EMAILD - FELIPE DURAN - 11/10/2019
   		    //QRY1->A1_EMAILD //INCLUSAO DO EMAILD - FELIPE DURAN - 11/10/2019
		    //EAP - DELTA 2008 corrigido o campo para tirar  ; devido a erro no exce
			//TRB ->EMAILD 	:= AllTrim( StrTran(QRY3->A1_EMAILD, ";","|" ))
   			_E:=0
        	_cmail:= AllTrim(QRY3->A1_EMAILD)
			FOR _E = 1 TO LEN(QRY3->A1_EMAILD)
		  	IF SUBSTRING(QRY3->A1_EMAILD,_E,1) == ';'
		      	_cmail:=SUBSTRING(QRY3->A1_EMAILD,1,_E-1)
		  	 	Exit
		  	Endif
		 	Next _E
			TRB->EMAILD 	:= _cmail
			
            // Eriberto 07/10/09
			TRB->CNPJ := QRY3->A1_CGC
			TRB->IE   := QRY3->A1_INSCR
				//Giovani Zago 18/08/11
		TRB->ENDERECO   := QRY3->A1_END
		
		
		TRB->CANAL_VEND := IF(!Empty(QRY3->A1_XCANALV),posicione("SX5",1,xFilial("SX5")+"X0"+ALLTRIM(QRY3->A1_XCANALV),"X5_DESCRI"),"")// Reginaldo Borges 28/08/2012
   		TRB->CNAE := QRY3->A1_CNAE+' - '+IF(!Empty(QRY3->A1_CNAE),posicione("CC3",1,xFilial("CC3")+ALLTRIM(QRY3->A1_CNAE),"CC3_DESC"),"") 		
   		TRB->CNES := QRY3->A1_CNES +' - '+ QRY3->A1_DESCNES
		//************************
			
			MsUnLock()
		EndIf
		
		QRY3->(dbSkip())
	EndDo
EndIf

dbSelectArea("TRB")
TRB->(dbGotop())

ProcRegua(TRB->(RECCOUNT()))

While TRB->(!Eof())
	
	IncProc(OemToAnsi("Cliente..: " + TRB->NOME))
	
	RecLock("TRB",.F.) // JBS 21/03/2006
	
	For _x := 1 TO 12
		nFat:=TRB->(FieldGet(Fieldpos("M"+StrZero(_x,2))))
		If nFat <> 0
			nPar_Med++
			_Media += nFat
		EndIf
		If Upper(_cDipUsr) $ cSHWCUST// JBS 21/03/2006
			nCus:=TRB->(FieldGet(Fieldpos("C"+StrZero(_x,2))))// JBS 21/03/2006
			If nCus <> 0// JBS 21/03/2006
				_MediaC += nCus// JBS 21/03/2006
			EndIf// JBS 21/03/2006
			nCus:=TRB->(FieldGet(Fieldpos("C"+StrZero(_x,2)))) // JBS 21/03/2006
			nMag:= If(nCus>0 .and. nFat>0,100 - ((nCus / nFat)*100),0) // JBS 21/03/2006
			TRB->(Fieldput(FieldPos('L'+StrZero(_x,2)),nMag))  // JBS 20/03/2006
		EndIf
	Next
	
	TRB->MEDIA := _Media /  nPar_Med
	
	If Upper(_cDipUsr) $ cSHWCUST// JBS 21/03/2006
		TRB->CUST_MEDIA := _MediaC /  nPar_Med
		TRB->MARG_TOTAL := If(TRB->CUST_TOTAL>0 .and. TRB->TOTAL>0,100-((TRB->CUST_TOTAL/TRB->TOTAL)*100),0) // JBS 21/03/2006
		TRB->MARG_MEDIA := If(TRB->CUST_MEDIA>0 .and. TRB->MEDIA>0,100-((TRB->CUST_MEDIA/TRB->MEDIA)*100),0) // JBS 21/03/2006
	EndIf
	
	MsUnLock()
	TRB->(dbSkip())
	
	_Media := 0
	_MediaC:= 0 // JBS 21/03/2006
	nPar_Med := 0
	
EndDo

If MV_PAR08 == 0
	_cChave  := 'TOTAL*-1'
	_cranking := ' - Ranking pelo Total'
ElseIf MV_PAR08 > 12
	_cChave  := 'MEDIA*-1'
	_cranking := ' - Ranking pela Media'
Else
	_cChave  := 'M'+StrZero(MV_PAR08,2)+'*-1'
	_cranking := ' - Ranking pelo mes de '+MesExtenso(MV_PAR08)
EndIf  

// Atualizando ranking e chave - MCVN 25/08/10
aRankChav:=U_Dipr25Rank()
_cChave   := aRankChav[1][1]
_cranking := aRankChav[1][2]

IndRegua("TRB",_cArqTrb,_cChave,,,"Criando Indice...(maior faturamento)")
ProcRegua(2)
IncProc(OemToAnsi("Gerando arquivo MESAMES.DBF para usar no excel"))

DbSelectArea("TRB")
If MV_PAR03 == 1

	DbSelectArea("TRB")
	TRB->(dbGotop())
	ProcRegua(TRB->(RECCOUNT()))	
	aCols := Array(TRB->(RECCOUNT()),Len(_aCampos))
	nColuna := 0
	nLinha := 0
	While TRB->(!Eof())
		nLinha++
		IncProc(OemToAnsi("Gerando planilha excel..."))
		For nColuna := 1 to Len(_aCampos)
			aCols[nLinha][nColuna] := &("TRB->("+_aCampos[nColuna][1]+")")			
		Next nColuna
		TRB->(dbSkip())	
	EndDo
	 u_GDToExcel(_aCampos,aCols,Alltrim(FunName()))
	
	DbSelectArea("TRB")


	COPY TO &cArqExcell VIA "DBFCDX"
  
  //EMERSON -- DELTADECISAO ALTERACAO PARA DTC 19.08.2020   
     FRename(cArqExcell+".dtc",cArqExcell+".xls")
	
	MakeDir(cDestino) // CRIA DIRET”RIO CASO N√O EXISTA
	CpyS2T(cArqExcell+".xls",cDestino,.T.) // COPIA ARQUIVO PARA MAQUINA DO USU¡RIO
	
	// Buscando e apagando arquivos tempor·rios - MCVN 27/08/10
	aTmp := Directory( cDestino+".tmp" )
	For nI:= 1 to Len(aTmp)
		fErase(cDestino+aTmp[nI,1])
	Next nI 

EndIf
TRB->(DbGoTop())


/*====================================================================================\
| MONTAGEM DO E-MAIL PARA SER ENVIADO                                                 |
\====================================================================================*/
If MV_PAR10 == 1 .And. !Empty(MV_PAR02)
	ProcRegua(100)
	For _x := 1 to 50
		IncProc("Montagem do arquivo para envio de E-mail, aguarde")
	Next
	
	nNum_Mes := _nMesIni
	cMes := ""
	cNom_Mes = ""
	
	
	For wi := 1 to 12
		
		cMes += "TRB->M"+StrZero(nNum_Mes,2)
		cNom_Mes += StrZero(nNum_Mes,2)
		
		
		If nNum_Mes = 12
			nNum_Mes := 1
		Else
			nNum_Mes++
		EndIf
	Next
	aadd(aEnv_025,{MesExtenso(Val(SubStr(cNom_Mes,1,2))) ,MesExtenso(Val(SubStr(cNom_Mes,3,2))) ,MesExtenso(Val(SubStr(cNom_Mes,5,2))) ,MesExtenso(Val(SubStr(cNom_Mes,7,2))) ,MesExtenso(Val(SubStr(cNom_Mes,9,2))) ,MesExtenso(Val(SubStr(cNom_Mes,11,2))) ,MesExtenso(Val(SubStr(cNom_Mes,13,2))) ,MesExtenso(Val(SubStr(cNom_Mes,15,2))) ,MesExtenso(Val(SubStr(cNom_Mes,17,2))) ,MesExtenso(Val(SubStr(cNom_Mes,19,2))) ,MesExtenso(Val(SubStr(cNom_Mes,21,2))) ,MesExtenso(Val(SubStr(cNom_Mes,23,2)))})
	Do While TRB->(!EOF())
		aadd(aEnv_025,{TRB->CLIENTE ,TRB->LOJA ,TRB->NOME ,TRB->UF ,&(SubStr(cMes,1,8)) ,&(SubStr(cMes,9,8)) ,&(SubStr(cMes,17,8)) ,&(SubStr(cMes,25,8)) ,&(SubStr(cMes,33,8)) ,&(SubStr(cMes,41,8)) ,&(SubStr(cMes,49,8)) ,&(SubStr(cMes,57,8)) ,&(SubStr(cMes,65,8)) ,&(SubStr(cMes,73,8)) ,&(SubStr(cMes,81,8)) ,&(SubStr(cMes,89,8)) ,TRB->TOTAL ,TRB->MEDIA, TRB->CIDADE, TRB->SEGMENTO, POSICIONE('SX5',1,xFilial('SX5') + "T3" + TRB->SEGMENTO,"X5_DESCRI")})
		// Total Faturado
		nTot_001 += &(SubStr(cMes,1,8))
		nTot_002 += &(SubStr(cMes,9,8))
		nTot_003 += &(SubStr(cMes,17,8))
		nTot_004 += &(SubStr(cMes,25,8))
		nTot_005 += &(SubStr(cMes,33,8))
		nTot_006 += &(SubStr(cMes,41,8))
		nTot_007 += &(SubStr(cMes,49,8))
		nTot_008 += &(SubStr(cMes,57,8))
		nTot_009 += &(SubStr(cMes,65,8))
		nTot_010 += &(SubStr(cMes,73,8))
		nTot_011 += &(SubStr(cMes,81,8))
		nTot_012 += &(SubStr(cMes,89,8))
		nTot_013 += TRB->TOTAL
		TRB->(DbSkip())
	EndDo
	aadd(aEnv_025,{nTot_001, nTot_002, nTot_003, nTot_004, nTot_005, nTot_006, nTot_007, nTot_008, nTot_009, nTot_010, nTot_011, nTot_012, nTot_013, (nTot_013/12)})
	
	If Len(aEnv_025) > 0 // SE N√O POSSUIR NENHUMA LINHA NO ARRAY N√O ENVIA NADA
		cEmail := POSICIONE('SA3',1,xFilial('SA3') + MV_PAR02,"A3_EMAIL")
		cAssunto := "Faturamento por cliente "+Iif(MV_PAR11<>99999,"(" + AllTrim(Str(MV_PAR11)) + ")","")+" de " + AllTrim(StrZero(_nMesIni,2)) + "/" + AllTrim(Str(_nAnoIni)) +" atÈ " + Substr((MV_PAR01),1,2)+"/"+Substr((MV_PAR01),3,4) + _cRanking + Iif(!Empty(MV_PAR02)," - Vendedor: " + MV_PAR02 + "-" + POSICIONE('SA3',1,xFilial('SA3') + MV_PAR02,"A3_NOME"),"")
		ENV_025(cEmail,cAssunto,aEnv_025)
	Endif
	ProcRegua(100)
	For _x := 1 to 100
		IncProc("E-mail enviado com sucesso...")
	Next
EndIf

Return

/*====================================================================================\
| IMPRESS√O DO RELAT”RIO                                                              |
\====================================================================================*/

Static Function RptDetail()
Local nCus
Local nFat
Local nMag 
Local xi,wi,I

_cTitulo:= ""
_cDesc1 := ""
_cDesc2 := ""
cRel_Dep:= "Ambos"
_nReg   := 0
nQtd_Mes:= 0
nNum_Cam:= _nMesIni
_Total  :={0,0,0,0,0,0,0,0,0,0,0,0,0,0}
_TotalC :={0,0,0,0,0,0,0,0,0,0,0,0,0,0} // JBS 20/03/2006
_Outros :={0,0,0,0,0,0,0,0,0,0,0,0,0,0} // JBS 20/03/2006
_OutrosC:={0,0,0,0,0,0,0,0,0,0,0,0,0,0} // JBS 20/03/2006

// MONTA O CABECALHO COM OS 12 MESES SELECIONADOS
For xi:=1 to 12
	_nMesIni := Str(_nMesIni)
	If xi == 1
		_nTamMes := 14 - Len(MesExtenso(_nMesIni))
	Else
		_nTamMes := 16 - Len(MesExtenso(_nMesIni))
	EndIf
	_cDesc1 += Space(_nTamMes)+MesExtenso(_nMesIni)
	
	_nMesIni := Val(_nMesIni)
	If _nMesIni >= 12
		_nMesIni := 1
		_nAnoIni := Val(Substr((MV_PAR01),3,4))
	Else
		_nMesIni++
		_nAnoIni := Val(Substr((MV_PAR01),3,4))-1
	EndIf
Next               

If !Empty(MV_PAR02) // JBS 21/03/2006
	cRel_Dep := '' // JBS 21/03/2006
ElseIf MV_PAR04 == 1
	cRel_Dep := "Apoio"
ElseIf MV_PAR04 == 2
	cRel_Dep := "Call Center"
EndIf
     

_cDesc1  += "           Total         MEDIA"
_cTitulo := "Faturamento por cliente "+Iif(MV_PAR11<>99999,"(" + AllTrim(Str(MV_PAR11)) + ")","")+" de " + AllTrim(StrZero(_nMesIni,2)) + "/" + AllTrim(Str(_nAnoIni)) +" atÈ " + Substr((MV_PAR01),1,2)+"/"+Substr((MV_PAR01),3,4) + _cRanking + Iif(!Empty(MV_PAR02)," - Vendedor: " + MV_PAR02 + "-" + POSICIONE('SA3',1,xFilial('SA3') + MV_PAR02,"A3_NOME"),"") + " - "  + cRel_Dep +If(!Empty(MV_PAR05),' - Fornecedor: '+If(MV_PAR05$"000851/051508","000851/051508",MV_PAR05),'') + Iif(MV_PAR07 = 1,' Por Carteira ',' Por Faturamento ')  // JBS 29/07/2010

DbSelectArea("TRB")
DbGoTop()
SetRegua(TRB->(RECCOUNT()))
Do While TRB->(!Eof())
	IncRegua( "Imprimindo: " + TRB->CLIENTE +' - '+ TRB->LOJA )
	If li > 65
		li := Cabec(_cTitulo,_cDesc1,_cDesc2,nomeprog,tamanho) + 1
	EndIf
	*                                                                                                    1                                                                                                   2                                                                                                   3
	*          1         2         3         4         5         6         7         8         9         0         1         2         3         4         5         6         7         8         9         0         1         2         3         4         5         6         7         8         9         0         1         2         3         4         5         6
	*01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
	*      Janeiro       Fevereiro           Marco           Abril            Maio           Junho           Julho          Agosto        Setembro         Outubro        Novembro        Dezembro           Total         MEDIA
	*Cliente: 999999-99 123456789012345678901234567890123456789012345678901234567890
	*999.999.999,99  999.999.999,99  999.999.999,99  999.999.999,99  999.999.999,99  999.999.999,99  999.999.999,99  999.999.999,99  999.999.999,99  999.999.999,99  999.999.999,99  999.999.999,99  999.999.999,99 99.999.999,99
	
	@ li,001 PSay 'Cliente..: ' + TRB->CLIENTE +'-'+TRB->LOJA +' - '+ TRB->NOME +'  Estado..: '+ TRB->UF  + '  Vendedor.: ' + TRB->VENDEDOR + '-' + TRB->NOME_VEN  //+ '  Canal de Venda.: ' + TRB->CANAL_VEND// JBS 29/07/2010
	li++
	col:=0
	nNum := nNum_Cam
	For wi:=1 to 12
		If nNum > 12
			nNum := 1
		EndIf
		@ li,col PSay (nFat:=TRB->(FieldGet(Fieldpos("M"+StrZero(nNum,2))))) Picture "@E 999,999,999.99"
		_Total[nNum]+= nFat
		nNum++
		col += 16
	Next
	@ li,190 PSay TRB->TOTAL Picture "@E 99999,999,999.99"
	@ li,206 PSay TRB->MEDIA Picture "@E 999,999,999.99"
	li++
	_Total[13] := _Total[13] + TRB->TOTAL
	_Total[14] := _Total[14] + TRB->MEDIA
	If Upper(_cDipUsr) $ "ERIBERTO/ERICH/MAXIMO"
		col:=0
		nNum := nNum_Cam
		For wi:=1 to 12
			If nNum > 12
				nNum := 1
			EndIf
			@ li,col PSay (nCus:=TRB->(FieldGet(Fieldpos("C"+StrZero(nNum,2))))) Picture "@E 999,999,999.99"
			_TotalC[nNum]+= nCus
			nNum++
			col += 16
		Next
		@ li,190 PSay TRB->CUST_TOTAL Picture "@E 99999,999,999.99"
		@ li,206 PSay TRB->CUST_MEDIA Picture "@E 999,999,999.99"
		li++
		_TotalC[13] := _TotalC[13] + TRB->CUST_TOTAL
		_TotalC[14] := _TotalC[14] + TRB->CUST_MEDIA
		col:=0
		nNum := nNum_Cam
		For wi:=1 to 12
			If nNum > 12
				nNum := 1
			EndIf
			nCus := TRB->(FieldGet(Fieldpos("C"+StrZero(nNum,2))))
			nFat := TRB->(FieldGet(Fieldpos("M"+StrZero(nNum,2))))
			nMag:= If(nCus>0 .and. nFat>0,100 - ((nCus / nFat)*100),0)
			@ li,col PSay nMag Picture "@E 999,999,999.99"
			nNum++
			col += 16
		Next
		@ li,190 PSay If(TRB->CUST_TOTAL>0.and.TRB->TOTAL>0,100-((TRB->CUST_TOTAL/TRB->TOTAL)*100),0) Picture "@E 99999,999,999.99"
		@ li,206 PSay If(TRB->CUST_MEDIA>0.and.TRB->MEDIA>0,100-((TRB->CUST_MEDIA/TRB->MEDIA)*100),0) Picture "@E 999,999,999.99"
		li++
	EndIf
	
	DbSelectArea("TRB")
	_nReg++
	TRB->(dbSkip())
	
	If _nReg = MV_PAR11   // quando preencher o numero de clientes
		Do While TRB->(!Eof())
			IncRegua( "Imprimindo: " + TRB->CLIENTE +' - '+ TRB->LOJA )
			_nReg++
			nNum := nNum_Cam
			For I=1 to 12
				If nNum > 12
					nNum := 1
				EndIf
				_Outros[nNum] := _Outros[nNum] + TRB->(FieldGet(Fieldpos("M"+StrZero(nNum,2))))
				_Total[nNum] := _Total[nNum] + TRB->(FieldGet(Fieldpos("M"+StrZero(nNum,2))))
				nNum++
			Next
			_Outros[13] := _Outros[13] + TRB->TOTAL
			_Outros[14] := _Outros[14] + TRB->MEDIA
			_Total[13] := _Total[13] + TRB->TOTAL
			_Total[14] := _Total[14] + TRB->MEDIA
			If Upper(_cDipUsr) $ "ERIBERTO/ERICH/MAXIMO"
				nNum := nNum_Cam
				For I=1 to 12
					If nNum > 12
						nNum := 1
					EndIf
					_OutrosC[nNum]:= _OutrosC[nNum] + TRB->(FieldGet(Fieldpos("C"+StrZero(nNum,2))))
					_TotalC[nNum] := _TotalC[nNum] + TRB->(FieldGet(Fieldpos("C"+StrZero(nNum,2))))
					nNum++
				Next
				_OutrosC[13]+= TRB->CUST_TOTAL
				_OutrosC[14]+= TRB->CUST_MEDIA
				_TotalC[13] += TRB->CUST_TOTAL
				_TotalC[14] += TRB->CUST_MEDIA
			EndIf
			DbSelectArea("TRB")
			TRB->(dbSkip())
		EndDo
		@ li,000 PSay ' '+ALLTRIM(STR(_nReg - MV_PAR11,5,0))+' clientes  '
		li++
		col:=0
		nNum := nNum_Cam
		nQtd_Mes := 0
		For wi:=1 to 12
			If nNum > 12
				nNum := 1
			EndIf
			If _Outros[nNum] <> 0
				nQtd_Mes++
			EndIf
			@ li,col PSay _Outros[nNum] Picture "@E 999,999,999.99"
			nNum++
			col += 16
		Next
		@ li,190 PSay _Outros[13] Picture "@E 99999,999,999.99"
		@ li,206 PSay _Outros[13]/nQtd_Mes Picture "@E 999,999,999.99"
		li++
		If Upper(_cDipUsr) $ "ERIBERTO/ERICH/MAXIMO"
			col:=0
			nNum := nNum_Cam
			nQtd_Mes := 0
			For wi:=1 to 12
				If nNum > 12
					nNum := 1
				EndIf
				If _OutrosC[nNum] <> 0
					nQtd_Mes++
				EndIf
				@ li,col PSay _OutrosC[nNum] Picture "@E 999,999,999.99"
				nNum++
				col += 16
			Next
			@ li,190 PSay _OutrosC[13] Picture "@E 99999,999,999.99"
			@ li,206 PSay _OutrosC[13]/nQtd_Mes Picture "@E 999,999,999.99"
			li++
			//------------------>
			col:=0
			nNum := nNum_Cam
			nQtd_Mes := 0
			For wi:=1 to 12
				If nNum > 12
					nNum := 1
				EndIf
				If _OutrosC[nNum] <> 0
					nQtd_Mes++
				EndIf
				nMarg := If(_OutrosC[nNum]>0.and._Outros[nNum]>0,100-((_OutrosC[nNum]/_Outros[nNum])*100),0)
				@ li,col PSay nMarg Picture "@E 999,999,999.99"
				nNum++
				col += 16
			Next
			nMarg := If(_OutrosC[13]>0.and._Outros[13]>0,100-((_OutrosC[13]/_Outros[13])*100),0)
			nMargM:= If(_OutrosC[13]>0.and._Outros[13]>0,100-(((_OutrosC[13]/nQtd_Mes)/(_Outros[13]/nQtd_Mes))*100),0)
			@ li,190 PSay nMarg Picture "@E 99999,999,999.99"
			@ li,206 PSay nMargM Picture "@E 999,999,999.99"
			li++
			
		EndIf
	EndIf
EndDo
If li <> 80
	@ li,000 PSay Replic(" ",Limite)
	li++
	col:=0
	nNum := nNum_Cam
	nQtd_Mes := 0
	For wi:=1 to 12
		If nNum > 12
			nNum := 1
		EndIf
		If _Total[nNum] <> 0
			nQtd_Mes++
		EndIf
		@ li,col PSay _Total[nNum] Picture "@E 999,999,999.99"
		nNum++
		col += 16
	Next
	@ li,190 PSay _Total[13] Picture "@E 99999,999,999.99"
	@ li,206 PSay _Total[13]/nQtd_Mes Picture "@E 999,999,999.99"
	li++
	If Upper(_cDipUsr) $ "ERIBERTO/ERICH/MAXIMO"
		col:=0
		nNum := nNum_Cam
		nQtd_Mes := 0
		For wi:=1 to 12
			If nNum > 12
				nNum := 1
			EndIf
			If _TotalC[nNum] <> 0
				nQtd_Mes++
			EndIf
			@ li,col PSay _TotalC[nNum] Picture "@E 999,999,999.99"
			nNum++
			col += 16
		Next
		@ li,190 PSay _TotalC[13] Picture "@E 99999,999,999.99"
		@ li,206 PSay _TotalC[13]/nQtd_Mes Picture "@E 999,999,999.99"
		li++
		
		col:=0
		nNum := nNum_Cam
		nQtd_Mes := 0
		For wi:=1 to 12
			If nNum > 12
				nNum := 1
			EndIf
			If _TotalC[nNum] <> 0
				nQtd_Mes++
			EndIf
			nMarg := If(_TotalC[nNum]>0.and._Total[nNum]>0,100-((_TotalC[nNum]/_Total[nNum])*100),0)
			@ li,col PSay nMarg Picture "@E 999,999,999.99"
			nNum++
			col += 16
		Next
		nMarg := If(_TotalC[13]>0.and._Total[13]>0,100-((_TotalC[13]/_Total[13])*100),0)
		nMargM:= If(_TotalC[13]>0.and._Total[13]>0,100-(((_TotalC[13]/nQtd_Mes)/(_Total[13]/nQtd_Mes))*100),0)
		@ li,190 PSay nMarg Picture "@E 99999,999,999.99"
		@ li,206 PSay nMargM Picture "@E 999,999,999.99"
		li++
	EndIf
	@ li,000 PSay Replic(" ",Limite)
	li+=2
EndIf
Return(.T.)
/*==========================================================================\
|Programa  | ENV_025 | Autor | Rafael de Campos Falco  | Data ≥ 02/02/2005  |
|===========================================================================|
|Desc.     | Envio de EMail do faturamento de cliente por vendedor          |
|===========================================================================|
|Sintaxe   | ENV_025                                                        |
|===========================================================================|
|Uso       | Especifico DIPROMED                                            |
\==========================================================================*/

Static Function ENV_025(cEmail,cAssunto,aEnv_025,aAttach)

Local cAccount  := Lower(Alltrim(GetMv("MV_RELACNT")))
Local cFrom     := Lower(Alltrim(GetMv("MV_RELACNT")))
Local cPassword := Alltrim(GetMv("MV_RELPSW"))
Local cServer   := Alltrim(GetMv("MV_RELSERV"))
Local cEmailTo  := ""
Local cEmailCc  := "patricia.mendonca@dipromed.com.br"
Local cEmailBcc := ""
Local lResult   := .F.
Local cError    := ""
Local cMsg      := ""
Local nTot_Prod := 0
Local xi               
LOCAL lSmtpAuth := GetNewPar("MV_RELAUTH",.F.)
LOCAL lAutOk	:= .F.

/*=============================================================================*/
/*Definicao do cabecalho do email                                              */
/*=============================================================================*/
cMsg := ""
cMsg += '<html>'
cMsg += '<head>'
cMsg += '<title>' + SubStr(cAssunto,1,24) + '</title>'
cMsg += '</head>'
cMsg += '<body>'
cMsg += '<HR Width=85% Size=3 Align=Centered Color=Red><P>'
cMsg += '<Table Align=Center BorderColor=#000000 CELLPADDING=4 CELLSPACING=0 Width=60%>'

cMsg += '<table width="100%">'
cMsg += '<tr>'
cMsg += '<td width="100%" align="center"><font size="3" color="red">ATEN«√O: Este e-mail deve ser respondido para PatrÌcia do Apoio</font></td>'
cMsg += '</tr>'
cMsg += '</table>'

cMsg += '<table width="100%">'
cMsg += '<tr>'
//cMsg += '<td width="100%" align="center"><font size="2" color="blue">' + SubStr(cAssunto,1,87) + '</font></td>'
cMsg += '<td width="100%" align="center"><font size="2" color="blue">' + cAssunto + '</font></td>' // MCVN - 08/04/2008
cMsg += '</tr>'
//cMsg += '<tr>'
//cMsg += '<td width="100%" align="center"><font size="2" color="blue">' + AllTrim(SubStr(cAssunto,90,40)) + '</font></td>'
//cMsg += '</tr>'
cMsg += '</table>'

cMsg += '<hr width="100%" size="2" align="center" color="#000000">'
cMsg += '<table width="100%" cellspacing="0" cellpadding="0"><font size="2" color="blue">'
cMsg += '<td align="right" width="7%"><font size="1">' + aEnv_025[1,1] + '</font></td>'
cMsg += '<td align="right" width="7%"><font size="1">' + aEnv_025[1,2] + '</font></td>'
cMsg += '<td align="right" width="7%"><font size="1">' + aEnv_025[1,3] + '</font></td>'
cMsg += '<td align="right" width="7%"><font size="1">' + aEnv_025[1,4] + '</font></td>'
cMsg += '<td align="right" width="7%"><font size="1">' + aEnv_025[1,5] + '</font></td>'
cMsg += '<td align="right" width="7%"><font size="1">' + aEnv_025[1,6] + '</font></td>'
cMsg += '<td align="right" width="7%"><font size="1">' + aEnv_025[1,7] + '</font></td>'
cMsg += '<td align="right" width="7%"><font size="1">' + aEnv_025[1,8] + '</font></td>'
cMsg += '<td align="right" width="7%"><font size="1">' + aEnv_025[1,9] + '</font></td>'
cMsg += '<td align="right" width="7%"><font size="1">' + aEnv_025[1,10] + '</font></td>'
cMsg += '<td align="right" width="7%"><font size="1">' + aEnv_025[1,11] + '</font></td>'
cMsg += '<td align="right" width="7%"><font size="1">' + aEnv_025[1,12] + '</font></td>'
cMsg += '<td align="right" width="8%"><font size="1">Total</font></td>'
cMsg += '<td align="right" width="8%"><font size="1">MÈdia</font></td>'
cMsg += '</tr>'
cMsg += '</table>'
cMsg += '<hr width="100%" size="2" align="center" color="#000000">'


cMsg += '<table width="100%" border="0" cellspacing="0" cellpadding="0">'

For xi:=2 to Len(aEnv_025)-1
	If xi%2 == 0
		cMsg += '<tr BgColor="#B0E2FF">'
		cMsg += '<td align="left" width="80%" colspan="10"><font size="1">Cliente: ' + aEnv_025[xi,1] + '-' + aEnv_025[xi,2] + '-' + aEnv_025[xi,3] + ' / ' + aEnv_025[xi,19] + '-' + aEnv_025[xi,4] +'</font></td>'
		cMsg += '<td align="left" width="20%" colspan="04"><font size="1">Segmento: ' + aEnv_025[xi,20] + '-' + aEnv_025[xi,21] +'</font></td>'
		cMsg += '</tr>'
		cMsg += '<tr BgColor="#B0E2FF">'
		cMsg += '<td align="right" width="7%"><font size="1">' + Transform(aEnv_025[xi,5] ,"@E 999,999,999.99") + '</font></td>'
		cMsg += '<td align="right" width="7%"><font size="1">' + Transform(aEnv_025[xi,6] ,"@E 999,999,999.99") + '</font></td>'
		cMsg += '<td align="right" width="7%"><font size="1">' + Transform(aEnv_025[xi,7] ,"@E 999,999,999.99") + '</font></td>'
		cMsg += '<td align="right" width="7%"><font size="1">' + Transform(aEnv_025[xi,8] ,"@E 999,999,999.99") + '</font></td>'
		cMsg += '<td align="right" width="7%"><font size="1">' + Transform(aEnv_025[xi,9] ,"@E 999,999,999.99") + '</font></td>'
		cMsg += '<td align="right" width="7%"><font size="1">' + Transform(aEnv_025[xi,10],"@E 999,999,999.99") + '</font></td>'
		cMsg += '<td align="right" width="7%"><font size="1">' + Transform(aEnv_025[xi,11],"@E 999,999,999.99") + '</font></td>'
		cMsg += '<td align="right" width="7%"><font size="1">' + Transform(aEnv_025[xi,12],"@E 999,999,999.99") + '</font></td>'
		cMsg += '<td align="right" width="7%"><font size="1">' + Transform(aEnv_025[xi,13],"@E 999,999,999.99") + '</font></td>'
		cMsg += '<td align="right" width="7%"><font size="1">' + Transform(aEnv_025[xi,14],"@E 999,999,999.99") + '</font></td>'
		cMsg += '<td align="right" width="7%"><font size="1">' + Transform(aEnv_025[xi,15],"@E 999,999,999.99") + '</font></td>'
		cMsg += '<td align="right" width="7%"><font size="1">' + Transform(aEnv_025[xi,16],"@E 999,999,999.99") + '</font></td>'
		cMsg += '<td align="right" width="8%"><font size="1">' + Transform(aEnv_025[xi,17],"@E 999,999,999.99") + '</font></td>'
		cMsg += '<td align="right" width="8%"><font size="1">' + Transform(aEnv_025[xi,18],"@E 999,999,999.99") + '</font></td>'
		cMsg += '</tr>'
		cMsg += '<tr BgColor="#B0E2FF">'
		cMsg += '<td align="left" width="100%" colspan="14"><font size="1" color="red">OcorrÍncia: </font></td>'
		cMsg += '</tr>'
	Else
		cMsg += '<tr BgColor="#c0c0c0">'
		cMsg += '<td align="left" width="80%" colspan="10"><font size="1">Cliente: ' + aEnv_025[xi,1] + '-' + aEnv_025[xi,2] + '-' + aEnv_025[xi,3] + '</font></td>'
		cMsg += '<td align="left" width="20%" colspan="04"><font size="1">Estado: ' + aEnv_025[xi,4] + '</font></td>'
		cMsg += '</tr>'
		cMsg += '<tr BgColor="#c0c0c0">'
		cMsg += '<td align="right" width="7%"><font size="1">' + Transform(aEnv_025[xi,5] ,"@E 999,999,999.99") + '</font></td>'
		cMsg += '<td align="right" width="7%"><font size="1">' + Transform(aEnv_025[xi,6] ,"@E 999,999,999.99") + '</font></td>'
		cMsg += '<td align="right" width="7%"><font size="1">' + Transform(aEnv_025[xi,7] ,"@E 999,999,999.99") + '</font></td>'
		cMsg += '<td align="right" width="7%"><font size="1">' + Transform(aEnv_025[xi,8] ,"@E 999,999,999.99") + '</font></td>'
		cMsg += '<td align="right" width="7%"><font size="1">' + Transform(aEnv_025[xi,9] ,"@E 999,999,999.99") + '</font></td>'
		cMsg += '<td align="right" width="7%"><font size="1">' + Transform(aEnv_025[xi,10],"@E 999,999,999.99") + '</font></td>'
		cMsg += '<td align="right" width="7%"><font size="1">' + Transform(aEnv_025[xi,11],"@E 999,999,999.99") + '</font></td>'
		cMsg += '<td align="right" width="7%"><font size="1">' + Transform(aEnv_025[xi,12],"@E 999,999,999.99") + '</font></td>'
		cMsg += '<td align="right" width="7%"><font size="1">' + Transform(aEnv_025[xi,13],"@E 999,999,999.99") + '</font></td>'
		cMsg += '<td align="right" width="7%"><font size="1">' + Transform(aEnv_025[xi,14],"@E 999,999,999.99") + '</font></td>'
		cMsg += '<td align="right" width="7%"><font size="1">' + Transform(aEnv_025[xi,15],"@E 999,999,999.99") + '</font></td>'
		cMsg += '<td align="right" width="7%"><font size="1">' + Transform(aEnv_025[xi,16],"@E 999,999,999.99") + '</font></td>'
		cMsg += '<td align="right" width="8%"><font size="1">' + Transform(aEnv_025[xi,17],"@E 999,999,999.99") + '</font></td>'
		cMsg += '<td align="right" width="8%"><font size="1">' + Transform(aEnv_025[xi,18],"@E 999,999,999.99") + '</font></td>'
		cMsg += '</tr>'
		cMsg += '<tr BgColor="#c0c0c0">'
		cMsg += '<td align="left" width="100%" colspan="14"><font size="1" color="red">OcorrÍncia: </font></td>'
		cMsg += '</tr>'
	EndIf
Next
cMsg += '</table>'

cMsg += '<hr width="100%" size="3" align="center" color="#000000" >'
cMsg += '<table width="100%" cellspacing="5" cellpadding="0">'
cMsg += '<tr BgColor="#FFFF80">'
cMsg += '<td align="right" width="7%"><font size="1">' + Transform(aEnv_025[Len(aEnv_025),1],"@E 999,999,999.99")  + '</font></td>'
cMsg += '<td align="right" width="7%"><font size="1">' + Transform(aEnv_025[Len(aEnv_025),2],"@E 999,999,999.99")  + '</font></td>'
cMsg += '<td align="right" width="7%"><font size="1">' + Transform(aEnv_025[Len(aEnv_025),3],"@E 999,999,999.99")  + '</font></td>'
cMsg += '<td align="right" width="7%"><font size="1">' + Transform(aEnv_025[Len(aEnv_025),4],"@E 999,999,999.99")  + '</font></td>'
cMsg += '<td align="right" width="7%"><font size="1">' + Transform(aEnv_025[Len(aEnv_025),5],"@E 999,999,999.99")  + '</font></td>'
cMsg += '<td align="right" width="7%"><font size="1">' + Transform(aEnv_025[Len(aEnv_025),6],"@E 999,999,999.99")  + '</font></td>'
cMsg += '<td align="right" width="7%"><font size="1">' + Transform(aEnv_025[Len(aEnv_025),7],"@E 999,999,999.99")  + '</font></td>'
cMsg += '<td align="right" width="7%"><font size="1">' + Transform(aEnv_025[Len(aEnv_025),8],"@E 999,999,999.99")  + '</font></td>'
cMsg += '<td align="right" width="7%"><font size="1">' + Transform(aEnv_025[Len(aEnv_025),9],"@E 999,999,999.99")  + '</font></td>'
cMsg += '<td align="right" width="7%"><font size="1">' + Transform(aEnv_025[Len(aEnv_025),10],"@E 999,999,999.99") + '</font></td>'
cMsg += '<td align="right" width="7%"><font size="1">' + Transform(aEnv_025[Len(aEnv_025),11],"@E 999,999,999.99") + '</font></td>'
cMsg += '<td align="right" width="7%"><font size="1">' + Transform(aEnv_025[Len(aEnv_025),12],"@E 999,999,999.99") + '</font></td>'
cMsg += '<td align="right" width="8%"><font size="1">' + Transform(aEnv_025[Len(aEnv_025),13],"@E 999,999,999.99") + '</font></td>'
cMsg += '<td align="right" width="8%"><font size="1">' + Transform(aEnv_025[Len(aEnv_025),14],"@E 999,999,999.99") + '</font></td>'
cMsg += '</tr>'
cMsg += '</table>'
cMsg += '<hr width="100%" size="3" align="center" color="#000000"><p>'

cMsg += '</Table>'
cMsg += '<HR Width=85% Size=3 Align=Centered Color=Red><P>'
cMsg += '<table width="100%" Align="Center" border="0">'
cMsg += '<tr align="center">'
cMsg += '<td colspan="10"><font color="BLUE" size="2">Mensagem enviada automaticamente pelo sistema PROTHEUS - <font color="BLUE" size="1">(DIPR025.PRW)</td>'
cMsg += '</tr>'

cMsg += '</table>'
cMsg += '</body>'
cMsg += '</html>'
                                 

If GetNewPar("ES_ATIVJOB",.T.)
	cEmail+=";"+AllTrim(cEmailCc+";"+cEmailBcc)
	u_UEnvMail(AllTrim(cEmail),SubStr(cAssunto,1,55),nil,"",cFrom,"ENV_025(DIPR025A.prw)",cMsg)
EndIf


/*
//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥Envia o mail para a lista selecionada. Envia como BCC para que a pessoa pense≥
//≥que somente ela recebeu aquele email, tornando o email mais personalizado.   ≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
IF At(";",cEmail) > 0
	cEmailTo := SubStr(cEmail,1,At(";",cEmail)-1)
	cEmailCc := SubStr(cEmail,At(";",cEmail)+1,Len(cEmail))
Else
	cEmailTo := Alltrim(cEmail)
EndIF

CONNECT SMTP SERVER cServer ACCOUNT cAccount PASSWORD cPassword RESULT lResult

If !lAutOk
	If ( lSmtpAuth )
		lAutOk := MailAuth(cAccount,cPassword)
	Else
		lAutOk := .T.
	EndIf
EndIf

If lResult .And. lAutOk
	SEND MAIL FROM cFrom ;
	TO      	Lower(cEmailTo);
	CC      	Lower(cEmailCc);
	BCC     	Lower(cEmailBcc);
	SUBJECT 	SubStr(cAssunto,1,55);
	BODY    	cMsg;
	RESULT lResult
	
	If !lResult
		//Erro no envio do email
		GET MAIL ERROR cError
		
		MsgInfo(cError,OemToAnsi("AtenÁ„o"))
	EndIf
	
	DISCONNECT SMTP SERVER
Else
	//Erro na conexao com o SMTP Server
	GET MAIL ERROR cError
	MsgInfo(cError,OemToAnsi("AtenÁ„o"))
EndIf
*/

Return(.T.)

/////////////////////////////////////////////////////////////////////////////
//
Static Function AjustaSX1(cPerg)
Local i,j

_sAlias := Alias()
dbSelectArea("SX1")
dbSetOrder(1)
aRegs:={}

//------------ Grupo/Ordem/Pergunta/PERGING/PERGESP/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05/F3

AADD(aRegs,{cPerg,"01","Mes e Ano Final    ?","","","mv_ch1","C",6,0,0,"G","","MV_PAR01","","","","","","","","","","","","","",""})
AADD(aRegs,{cPerg,"02","Vendedor           ?","","","mv_ch2","C",6,0,0,"G","","MV_PAR02","","","","","","","","","","","","","","","","","","","","","","","","",'SA3'})
AADD(aRegs,{cPerg,"03","Cria arquivo       ?","","","mv_ch3","N",1,0,1,"C","","MV_PAR03","Sim","","","","","Nao","","","","","","","",""})
AADD(aRegs,{cPerg,"04","Informe o setor    ?","","","mv_ch4","N",1,0,0,"C","","MV_PAR04","1-Apoio","","","","","2-Call Center","","","","","3-Ambos","","","","","4-Licitacoes"})
AADD(aRegs,{cPerg,"05","Fornecedor         ?","","","mv_ch5","C",6,0,0,"G","","MV_PAR05","","","","","","","","","","","","","","","","","","","","","","","","",'SA2'})
AADD(aRegs,{cPerg,"06","Grupo de Clientes  ?","","","mv_ch6","C",6,0,0,"G","","MV_PAR06","","","","","","","","","","","","","","","","","","","","","","","","",'ACY'})
AADD(aRegs,{cPerg,"07","Por Carteira       ?","","","mv_ch7","N",1,0,1,"C","","MV_PAR07","Sim","","","","","Nao","","","","","","","",""})
AADD(aRegs,{cPerg,"08","Ordenar pela Coluna?","","","mv_ch8","N",2,0,0,"G","","MV_PAR08","","","","","","","","","","","","","","","","","","","","","","","","",''})
AADD(aRegs,{cPerg,"09","Carteira TODA      ?","","","mv_ch9","N",1,0,1,"C","","MV_PAR09","Sim","","","","","Nao","","","","","","","",""})
AADD(aRegs,{cPerg,"10","Envia E-mail       ?","","","mv_chA","N",1,0,1,"C","","MV_PAR10","Sim","","","","","Nao","","","","","","","",""})
AADD(aRegs,{cPerg,"11","Quantos CLIENTES   ?","","","mv_chB","N",5,0,0,"G","","MV_PAR11","","","","","","","","","","","","","",""})

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
///////////////////////////////////////////////////////////////////////////
/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥fQuery01  ∫Autor  ≥Jailton B Santos-JBS∫ Data ≥ 22/03/2010  ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥ Esta Query apura os falores faturado no pedido pela empresa∫±±
±±∫          ≥ informada como parametro, Retorna Query QRY1.              ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ Especifico - Faturamento - DIPROMED.                       ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Static Function fQuery01( _cEmpresa ,_cFilial)

Local cQuery  := ""
Local cFilSD2 := fFilial(_cEmpresa,'SD2',_cFilial)
Local cFilSF4 := fFilial(_cEmpresa,'SF4',_cFilial)
Local cFilSU7 := fFilial(_cEmpresa,'SU7',_cFilial) // JBS 30/07/2010
Local cFilSX5 := fFilial(_cEmpresa,'SX5',_cFilial)
Local nId     := 0
Local _x

ProcRegua(500)
For _x := 1 to 150
	IncProc( "Processando...VENDAS ")
Next

cQuery   := "SELECT D2_CLIENTE,"
cQuery   += "D2_LOJA,"
cQuery   += "A1_NOME,"
cQuery   += "A1_MUN,"
cQuery   += "A1_EST,"
cQuery   += "A1_SATIV1,"
cQuery   += "A1_SATIV8,"//Giovani Zago	06/10/11
cQuery   += "X5_DESCRI,"



If MV_PAR07 = 1  // JBS 30/07/2010 - Carteira = Sim
	cQuery += "A1_VEND VENDEDOR,"
Else
	cQuery += "F2_VEND1 VENDEDOR,"
Endif

cQuery   += "A1_PRICOM,"
cQuery   += "A1_ULTCOM,"
cQuery   += "A1_HPAGE,"
cQuery   += "A1_OBSERV,"
//cQuery   += "A1_VENDKC," RBORGES 01/11/13 - Comentado conforme solicitaÁ„o do ALVARO MENEZES.
//cQuery   += "       A1_TECNICO, "   RBORGES 01/10/13 - Comentado conforme solicitaÁ„o do Maximo.
cQuery   += "A1_TECN_3,"
cQuery   += "A1_TECN_A,"
cQuery   += "A1_TECN_R," //Reginaldo Borges 02/10/2012
cQuery   += "A1_TECN_C,"
cQuery   += "A1_TECN_B,"   //Reginaldo Borges 02/10/2012 06/08/2013
cQuery   += "A1_XTEC_SP," // Reginaldo Borges 22/02/2013
cQuery   += "A1_XTEC_MA," // Reginaldo Borges 22/02/2013
cQuery   += "A1_XTEC_HQ," // Reginaldo Borges 22/02/2013
cQuery   += "A1_VENDHQ,"  //Reginaldo Borges 01/11/2013
cQuery   += "A1_XVENDSP," // Reginaldo Borges 26/09/2013
cQuery   += "A1_GRPVEN,"
cQuery   += "LEFT(D2_EMISSAO,6) D2_EMISSAO,"
cQuery   += "SUM(D2_TOTAL) D2_TOTAL,"
cQuery   += "SUM(D2_CUSDIP*D2_QUANT) D2_CUSDIP,"
cQuery   += "SUM(D2_QUANT) D2_QUANT,"
cQuery   += "A1_CGC,"
cQuery   += "A1_INSCR,"//Giovani Zago
//Giovani Zago 18/08/11
cQuery   += "A1_END,"

//*****************************

cQuery   += "A1_XCANALV," // Reginaldo Borges 28/08/2012

cQuery   += "A1_CNAE," // MCVN - 18/01/13

cQuery   += "A1_CNES," // MCVN - 18/01/13

cQuery   += "A1_DESCNES, " // MCVN - 18/01/13
cQuery   += "D2_FORNEC, " // MCVN - 18/01/13
cQuery   += "F2_VEND2, " // MCVN - 18/01/13
cQuery   += "A1_EMAILD " // FELIPE DURAN 11/10/2019

//*****************************

cQuery   += "FROM SD2" + _cEmpresa + " SD2 "

cQuery   += "INNER JOIN SF2" + _cEmpresa + " SF2 ON F2_FILIAL = D2_FILIAL "
cQuery   += " AND F2_DOC = D2_DOC "
cQuery   += " AND F2_SERIE = D2_SERIE "
cQuery   += " AND SF2.D_E_L_E_T_ =  '' "

If cEmpAnt = "04"
	cQuery   += "INNER JOIN SA1010 SA1 ON A1_FILIAL = '" + xFilial('SA1') + "' "
Else
	cQuery   += "INNER JOIN SA1010 SA1 ON A1_FILIAL = '" + xFilial('SA1') + "' "
EndIf

cQuery   += "AND A1_COD = D2_CLIENTE "
cQuery   += "AND A1_LOJA = D2_LOJA "
cQuery   += "AND SA1.D_E_L_E_T_ = '' "
If !Empty(MV_PAR06)
	cQuery   += "AND A1_GRPVEN = '" +MV_PAR06+"' "
EndIf

cQuery   += "INNER JOIN SA3010 SA3 ON A3_FILIAL = '"+xFilial('SA3')+"' "
If MV_PAR07 = 1 // JBS 30/07/2010
	cQuery   += "And A3_COD  = A1_VEND " // JBS 30/07/2010
Else
	cQuery   += "And A3_COD  = F2_VEND1 " // JBS 30/07/2010
Endif
cQuery   += "AND SA3.D_E_L_E_T_ = '' "

cQuery   += "LEFT JOIN SX5" + _cEmpresa + " SX5 ON X5_FILIAL = '"+ cFilSX5 +"' "
cQuery   += "AND X5_CHAVE = A1_SATIV1 "
//cQuery 	 += "					   AND X5_FILIAL = '"+xFilial("SX5")+"' "
cQuery   += "AND X5_TABELA = 'T3' "
cQuery   += "AND SX5.D_E_L_E_T_ = '' "

cQuery   += "INNER JOIN SF4" + _cEmpresa + " SF4 ON F4_FILIAL = '" + cFilSF4 + "' "
cQuery   += "AND F4_CODIGO = D2_TES "
cQuery   += "AND F4_DUPLIC = 'S' "
cQuery   += "AND SF4.D_E_L_E_T_ =  '' "


If _cPosto <> "02" .Or. Upper(_cDipUsr) $ Upper(cUserAut)// Televendas RBorges 07/02/17
	
	If Empty(MV_PAR02) .and.MV_PAR04 == 4                                                   // Licitacoes JBS 30/07/2010
		
		cQuery   += "INNER JOIN SC5" + _cEmpresa + " SC5 ON C5_FILIAL = D2_FILIAL "             // Licitacoes JBS 30/07/2010
		cQuery   += "And C5_NUM    = D2_PEDIDO "                          // Licitacoes JBS 30/07/2010
		cQuery   += "And SC5.D_E_L_E_T_ =  '' "                           // Licitacoes JBS 30/07/2010
		
		cQuery   += "INNER JOIN SU7010 SU7 ON U7_FILIAL = '" + cFilSU7 + "' " // Licitacoes JBS 30/07/2010
		cQuery   += "And U7_COD = C5_OPERADO "                            // Licitacoes JBS 30/07/2010
		cQuery   += "And U7_POSTO = '03' "                                // Licitacoes JBS 30/07/2010
		cQuery   += "And SU7.D_E_L_E_T_ = '' "                            // Licitacoes JBS 30/07/2010
		
	EndIf
	If Empty(MV_PAR02) .and.MV_PAR04 == 1                                                   // Giovani Zago 11/10/2011
		
		cQuery   += "INNER JOIN SC5" + _cEmpresa + " SC5 ON C5_FILIAL = D2_FILIAL "          // Giovani Zago 11/10/2011
		cQuery   += "And C5_NUM    = D2_PEDIDO "                          // Giovani Zago 11/10/2011
		cQuery   += "And SC5.D_E_L_E_T_ =  '' "                           // Giovani Zago 11/10/2011
		
		cQuery   += "INNER JOIN SU7010 SU7 ON U7_FILIAL = '" + cFilSU7 + "' " // Giovani Zago 11/10/2011
		cQuery   += "And U7_COD = C5_OPERADO "                            // Giovani Zago 11/10/2011
		cQuery   += "And U7_POSTO = '01' "                                // Giovani Zago 11/10/2011
		cQuery   += "And SU7.D_E_L_E_T_ = '' "                            // Giovani Zago 11/10/2011
		
	EndIf
	
Else
	
	cQuery   += "INNER JOIN SC5" + _cEmpresa + " SC5 ON C5_FILIAL = D2_FILIAL " // Televendas RBorges 07/02/17
	cQuery   += "And C5_NUM    = D2_PEDIDO "                          			// Televendas RBorges 07/02/17
	cQuery   += "And SC5.D_E_L_E_T_ =  '' "                           			// Televendas RBorges 07/02/17
	
	cQuery   += "INNER JOIN SU7010 SU7 ON U7_FILIAL = '" + cFilSU7 + "' "       // Televendas RBorges 07/02/17
	cQuery   += "And U7_COD = C5_OPERADO "                            			// Televendas RBorges 07/02/17
	cQuery   += "And U7_POSTO = '"+_cPosto+"' "                       			// Televendas RBorges 07/02/17
//	cQuery   += "And U7_CODVEN = '"+_CodVen+"' "								// Televendas RBorges 07/02/17
	cQuery   += "And SU7.D_E_L_E_T_ = '' "                            			// Televendas RBorges 07/02/17
	
EndIf 

cQuery   += " WHERE D2_FILIAL = '"+cFilSD2+"' "
cQuery   += "AND D2_TIPO IN ('N','C') "
If Empty(MV_PAR12) .AND. Empty(MV_PAR13)
	cQuery   += "AND LEFT(D2_EMISSAO,6) BETWEEN '" + _nParIni + "' AND '" + _nParFim + "' "
Else
	cQuery   += "AND D2_EMISSAO BETWEEN '" + DTOS(mv_par12) + "' AND '" + DTOS(mv_par13) + "' "
End
//-- Tratamento da HQ-CD: se Dipromed-Mtz, somente listar dados a partir de 01/05/2011 => Daniel Leme: 05/05/2011
If _cEmpresa + _cFilial == "0101"
	cQuery +=  "AND D2_EMISSAO >= '20110501' "
EndIf

cQuery   += "AND SD2.D_E_L_E_T_ = '' "
//cQuery   += "   AND A1_VEND = A3_COD"


If U_ListVend() != ''                                  // JBS 30/07/2010
	If MV_PAR07 = 1                                    // JBS 30/07/2010
		cQuery += " AND A1_VEND " + U_ListVend()      // JBS 30/07/2010
	Else                                               // JBS 30/07/2010
		cQuery += " AND F2_VEND1 " + U_ListVend()
	EndIf                                             // JBS 30/07/2010
EndIf

If _cPosto <> "02" .Or. Upper(_cDipUsr) $ Upper(cUserAut)// Televendas RBorges 07/02/17
	
	If !Empty(MV_PAR02) // VENDEDOR
		If MV_PAR07 = 1
			cQuery += " AND A1_VEND = '" + MV_PAR02 + "'"
		Else
			//cQuery += " AND (F2_VEND1 = '"+MV_PAR02+"' AND (F2_VEND2 = ' ' OR D2_FORNEC <> '000996') "
			//cQuery += "	OR (F2_VEND2 = '"+MV_PAR02+"' AND D2_FORNEC IN ('000366','000446','000996'))) "
			cQuery += "	AND (CASE WHEN F2_VEND2 <> ' ' AND D2_FORNEC IN('000366','000446','000996') THEN F2_VEND2 ELSE F2_VEND1 END) = '" + MV_PAR02 + "'"
		EndIf
	Else
		If MV_PAR04 == 1 // APOIO
			cQuery += " AND A3_TIPO = 'E'
		ElseIf MV_PAR04 == 2 // CALL CENTER
			cQuery += " AND A3_TIPO = 'I'
		EndIf
	EndIf
	
Else
	cQuery += " AND A1_VEND = '" +_CodVen+ "'"
EndIf


If !Empty(MV_PAR05) // FORNECEDOR
	If MV_PAR05 $ "000851/051508" //CÛdigos do fornecedor HQ
		cQuery += " AND D2_FORNEC IN ('000851','051508') "
	Else
		cQuery += " AND D2_FORNEC = '" + MV_PAR05 + "'"
	Endif
EndIf

cQuery   += " GROUP BY D2_CLIENTE,"
cQuery   += "D2_LOJA,"
cQuery   += "A1_NOME,"
cQuery   += "A1_MUN,"
cQuery   += "A1_EST,"

If MV_PAR07 = 1  // JBS 30/07/2010
	cQuery   += "A1_VEND,"
Else
	cQuery   += "F2_VEND1,"
Endif

cQuery   += "A1_VEND,"
cQuery   += "A1_PRICOM,"
cQuery   += "A1_ULTCOM,"
cQuery   += "A1_HPAGE,"
cQuery   += "A1_OBSERV,"
cQuery   += "A1_SATIV1,"
cQuery   += "A1_SATIV8,"//Giovani Zago	06/10/11
cQuery   += "X5_DESCRI,"
cQuery   += "LEFT(D2_EMISSAO,6),"
//cQuery   += "A1_VENDKC," RBORGES 01/11/13 - Comentado conforme solicitaÁ„o do ALVARO MENEZES.
//cQuery   += "          A1_TECNICO, "  RBORGES 01/10/13 - Comentado conforme solicitaÁ„o do Maximo.
cQuery   += "A1_TECN_3,"
cQuery   += "A1_TECN_A,"
cQuery   += "A1_TECN_R,"
cQuery   += "A1_TECN_C,"// Reginaldo Borges 02/10/2012
cQuery   += "A1_TECN_B," // Reginaldo Borges 06/08/2013
cQuery   += "A1_XTEC_SP,"// Reginaldo Borges 22/02/2013
cQuery   += "A1_XTEC_MA,"// Reginaldo Borges 22/02/2013
cQuery   += "A1_XTEC_HQ,"// Reginaldo Borges 22/02/2013
cQuery   += "A1_VENDHQ, "//Reginaldo Borges 01/11/2013
cQuery   += "A1_XVENDSP,"// Reginaldo Borges 26/09/2013
cQuery   += "A1_CGC,"
cQuery   += "A1_INSCR,"
cQuery   += "A1_GRPVEN,"//Giovani Zago

//Giovani Zago
cQuery   += "A1_END,"

cQuery   += "A1_XCANALV," // Reginaldo Borges 28/08/2012

cQuery   += "A1_CNAE," // MCVN - 18/01/13

cQuery   += "A1_CNES," // MCVN - 18/01/13

cQuery   += "A1_DESCNES," // MCVN - 18/01/13
cQuery   += "D2_FORNEC,"
cQuery   += "F2_VEND2,"
cQuery   += "A1_EMAILD" // FELIPE DURAN 11/10/2019



//*******************************
Return(cQuery)      
/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥fQuery02  ∫Autor  ≥Jailton B Santos-JBS∫ Data ≥ 22/03/2010  ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥ Esta Query apura os falores faturado no pedido pela empresa∫±±
±±∫          ≥ informada como parametro, Retorna Query QRY1.              ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ Especifico - Faturamento - DIPROMED.                       ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Static Function fQuery02( _cEmpresa ,_cFilial)

Local cQuery   := ""
Local cFilSD1 := fFilial(_cEmpresa,'SD1',_cFilial)
Local cFilSD2 := fFilial(_cEmpresa,'SD2',_cFilial)
Local cFilSU7 := fFilial(_cEmpresa,'SU7',_cFilial) // JBS 30/07/2010
Local cFilSF4 := fFilial(_cEmpresa,'SF4',_cFilial)
Local cFilSX5 := fFilial(_cEmpresa,'SX5',_cFilial)
Local nId     := 0
Local _x

ProcRegua(500)
For _x := 1 to 150
	IncProc( "Processando...VENDAS ")
Next

cQuery   := "SELECT SUM(D1_TOTAL) D1_TOTAL,"
cQuery   += "SUBSTRING(D1_DTDIGIT,1,6) D1_DTDIGIT,"
cQuery   += "D1_FORNECE,"
cQuery   += "D1_LOJA,"
cQuery   += "A1_NOME,"
cQuery   += "A1_EST,"
cQuery   += "A1_PRICOM,"
cQuery   += "A1_ULTCOM,"
cQuery   += "A1_HPAGE,"
cQuery   += "A1_OBSERV,"
cQuery   += "A1_SATIV1,"
cQuery   += "A1_SATIV8,"//Giovani Zago 06/10/11
If MV_PAR07 = 1 // JBS 30/07/2010 - Carteira = Sim
	cQuery += "A1_VEND  VENDEDOR,"
Else
	cQuery += "F2_VEND1 VENDEDOR,"
Endif

//cQuery   += "A1_VENDKC,"RBORGES 01/11/13 - Comentado conforme solicitaÁ„o do ALVARO MENEZES.
//cQuery   += "       A1_TECNICO, " RBORGES 01/10/13 - Comentado conforme solicitaÁ„o do Maximo.
cQuery   += "A1_TECN_3,"
cQuery   += "A1_TECN_A,"
cQuery   += "A1_TECN_R,"
cQuery   += "A1_TECN_C," // Reginaldo Borges 02/10/2012
cQuery   += "A1_TECN_B," // Reginaldo Borges 06/08/2013
cQuery   += "A1_XTEC_SP,"// Reginaldo Borges 22/02/2013
cQuery   += "A1_XTEC_MA,"// Reginaldo Borges 22/02/2013
cQuery   += "A1_XTEC_HQ,"// Reginaldo Borges 22/02/2013
cQuery   += " A1_VENDHQ,"//Reginaldo Borges 01/11/2013
cQuery   += "A1_XVENDSP,"// Reginaldo Borges 26/09/2013
cQuery   += "A1_MUN,"
cQuery   += "A1_GRPVEN,"
cQuery   += "A1_XCANALV,"
cQuery   += "A1_CNAE," // MCVN - 18/01/13
cQuery   += "A1_CNES," // MCVN - 18/01/13
cQuery   += "A1_DESCNES," // MCVN - 18/01/13
cQuery   += "X5_DESCRI,"
cQuery   += "SUM(D2_CUSDIP*D2_QUANT) D2_CUSDIP,"
cQuery   += "SUM(D1_QUANT) D1_QUANT,"
cQuery   += "A1_CGC,"
cQuery   += "A1_INSCR,"//Giovani Zago 18/08/11
//Giovani Zago 18/08/11
cQuery   += "A1_END, "
cQuery   += "D2_FORNEC, "
cQuery   += "F2_VEND2, "
cQuery   += "A1_EMAILD " // FELIPE DURAN 11/10/2019

//*****************************
cQuery   += "FROM SD1" + _cEmpresa + " SD1 "

cQuery   += "INNER JOIN SD2" + _cEmpresa + " SD2 ON D2_FILIAL = D1_FILIAL "
cQuery   += "AND D2_DOC = D1_NFORI "
cQuery   += "AND D2_SERIE = D1_SERIORI "
cQuery   += "AND D2_ITEM = D1_ITEMORI "
cQuery   += "AND SD2.D_E_L_E_T_ = '' "

cQuery   += "INNER JOIN SF4" + _cEmpresa + " SF4 ON F4_FILIAL = '" + cFilSF4 + "' "
cQuery   += "AND F4_CODIGO = D1_TES "
cQuery   += "AND F4_DUPLIC  = 'S' "
cQuery   += "AND SF4.D_E_L_E_T_ = '' "

cQuery   += "INNER JOIN SF2" + _cEmpresa + " SF2 ON F2_FILIAL = D2_FILIAL "
cQuery   += "AND F2_DOC    = D2_DOC "
cQuery   += "AND F2_SERIE  = D2_SERIE "
cQuery   += "AND SF2.D_E_L_E_T_ =  '' "

If cEmpAnt = "04"
	cQuery   += " INNER JOIN SA1010 SA1 ON A1_FILIAL = '" + xFilial('SA1') + "' "
Else
	cQuery   += " INNER JOIN SA1010 SA1 ON A1_FILIAL = '" + xFilial('SA1') + "' "
EndIf

cQuery   += "AND A1_COD = D1_FORNECE "
cQuery   += "AND A1_LOJA = D1_LOJA "
cQuery   += "AND SA1.D_E_L_E_T_ = '' "
If !Empty(MV_PAR06)
	cQuery   += "AND A1_GRPVEN = '" +MV_PAR06+"'"
EndIf

cQuery   += " INNER JOIN SA3010 SA3 ON A3_FILIAL = '" + xFilial('SA3') + "' "
If MV_PAR07 = 1 // JBS 30/07/2010
	cQuery   += " And A3_COD  = A1_VEND " // JBS 30/07/2010
Else
	cQuery   += " And A3_COD  = F2_VEND1 " // JBS 30/07/2010
Endif
cQuery   += " AND SA3.D_E_L_E_T_ = '' "

cQuery   += " LEFT JOIN SX5" + _cEmpresa + " SX5 ON X5_FILIAL = '" + cFilSX5 + "' "
cQuery   += " AND X5_CHAVE  = A1_SATIV1 "
//cQuery 	 += "					   AND X5_FILIAL = '"+xFilial("SX5")+"' "
cQuery   += " AND X5_TABELA = 'T3' "
cQuery   += " AND SX5.D_E_L_E_T_ = '' "


If _cPosto <> "02" .Or. Upper(_cDipUsr) $ Upper(cUserAut) // Televendas RBorges 07/02/17
	
	If Empty(MV_PAR02) .and.MV_PAR04 == 4                                                   // Licitacoes JBS 30/07/2010
		
		cQuery   += " INNER JOIN SC5" + _cEmpresa + " SC5 ON C5_FILIAL = D2_FILIAL "             // Licitacoes JBS 30/07/2010
		cQuery   += " And C5_NUM    = D2_PEDIDO "                          // Licitacoes JBS 30/07/2010
		cQuery   += " And SC5.D_E_L_E_T_ =  '' "                           // Licitacoes JBS 30/07/2010
		
		cQuery   += " INNER JOIN SU7010 SU7 ON U7_FILIAL = '" + cFilSU7 + "' " // Licitacoes JBS 30/07/2010
		cQuery   += " And U7_COD = C5_OPERADO "                            // Licitacoes JBS 30/07/2010
		cQuery   += " And U7_POSTO = '03' "                                // Licitacoes JBS 30/07/2010
		cQuery   += " And SU7.D_E_L_E_T_ = '' "                            // Licitacoes JBS 30/07/2010
		
	EndIf
	If Empty(MV_PAR02) .and.MV_PAR04 == 1                                                   // Giovani Zago 11/10/2011
		
		cQuery   += "INNER JOIN SC5" + _cEmpresa + " SC5 ON C5_FILIAL = D2_FILIAL "          // Giovani Zago 11/10/2011
		cQuery   += " And C5_NUM = D2_PEDIDO "                          // Giovani Zago 11/10/2011
		cQuery   += " And SC5.D_E_L_E_T_ =  '' "                           // Giovani Zago 11/10/2011
		
		cQuery   += "INNER JOIN SU7010 SU7 ON U7_FILIAL = '" + cFilSU7 + "' " // Giovani Zago 11/10/2011
		cQuery   += " And U7_COD = C5_OPERADO "                            // Giovani Zago 11/10/2011
		cQuery   += " And U7_POSTO = '01' "                                // Giovani Zago 11/10/2011
		cQuery   += " And SU7.D_E_L_E_T_ = '' "                            // Giovani Zago 11/10/2011
		
	EndIf
	
Else
	
	cQuery   += "INNER JOIN SC5" + _cEmpresa + " SC5 ON C5_FILIAL = D2_FILIAL " // Televendas RBorges 07/02/17
	cQuery   += "And C5_NUM    = D2_PEDIDO "                          			// Televendas RBorges 07/02/17
	cQuery   += "And SC5.D_E_L_E_T_ =  '' "                           			// Televendas RBorges 07/02/17
	
	cQuery   += "INNER JOIN SU7010 SU7 ON U7_FILIAL = '" + cFilSU7 + "' "       // Televendas RBorges 07/02/17
	cQuery   += "And U7_COD = C5_OPERADO "                            			// Televendas RBorges 07/02/17
	cQuery   += "And U7_POSTO = '"+_cPosto+"' "                       			// Televendas RBorges 07/02/17
	//cQuery   += "And U7_CODVEN = '"+_CodVen+"' "								// Televendas RBorges 07/02/17
	cQuery   += "And SU7.D_E_L_E_T_ = '' "                            			// Televendas RBorges 07/02/17
	
EndIf

cQuery   += " WHERE D1_FILIAL = '" + cFilSD1 + "' "

If Empty(mv_par12) .and. Empty(mv_par13)
	cQuery   += " AND SUBSTRING(D1_DTDIGIT,1,6) BETWEEN '" + _nParIni + "' AND '" + _nParFim + "' "
Else
	cQuery   += "AND D1_DTDIGIT BETWEEN '" + DTOS(mv_par12) + "' AND '" + DTOS(mv_par13) + "' "
End

//-- Tratamento da HQ-CD: se Dipromed-Mtz, somente listar dados a partir de 01/05/2011 => Daniel Leme: 05/05/2011
If _cEmpresa + _cFilial == "0101"
	cQuery +=  " AND D1_DTDIGIT >= '20110501'"
EndIf

cQuery   += " AND D1_TIPO    = 'D' "
cQuery   += " AND SD1.D_E_L_E_T_ <> '*'"


If U_ListVend() != ''
	If MV_PAR07 = 1                                // JBS 30/07/2010
		cQuery += " AND A1_VEND " + U_ListVend()  // JBS 30/07/2010
	Else                                           // JBS 30/07/2010
		cQuery += " AND F2_VEND1  " + U_ListVend()
	EndIf                                          // JBS 30/07/2010
EndIf

If _cPosto <> "02" .Or. Upper(_cDipUsr) $ Upper(cUserAut)// Televendas RBorges 07/02/17
	
	If !Empty(MV_PAR02) // VENDEDOR                           // JBS 30/07/2010
		If MV_PAR07 = 1                                       // JBS 30/07/2010
			cQuery += " AND A1_VEND = '" + MV_PAR02 + "'"	  // JBS 30/07/2010
		Else                                                  // JBS 30/07/2010
			//cQuery += " AND (F2_VEND1 = '"+MV_PAR02+"' AND (F2_VEND2 = ' ' OR D2_FORNEC <> '000996') "
			//cQuery += "	OR (F2_VEND2 = '"+MV_PAR02+"' AND D2_FORNEC IN ('000366','000446','000996'))) "
			cQuery += "	AND (CASE WHEN F2_VEND2 <> ' ' AND D2_FORNEC IN('000366','000446','000996') THEN F2_VEND2 ELSE F2_VEND1 END) = '" + MV_PAR02 + "'"
		EndIf                                                 // JBS 30/07/2010
	Else
		//	If MV_PAR04 == 1 // APOIO
		//	cQuery += " AND A3_TIPO = 'E'
		If MV_PAR04 == 2//	ElseIf MV_PAR04 == 2 // CALL CENTER
			cQuery += " AND A3_TIPO = 'I'
		EndIf
	EndIf

Else
	cQuery += " AND A1_VEND = '" +_CodVen+ "'"	
EndIf


If !Empty(MV_PAR05)
	If MV_PAR05 $ "000851/051508" //CÛdigos do fornecedor HQ
		cQuery += " AND D2_FORNEC IN ('000851','051508') "
	Else
		cQuery += " AND D2_FORNEC = '" + MV_PAR05 + "'"
	Endif
EndIf

cQuery   += " GROUP BY SUBSTRING(D1_DTDIGIT,1,6),"
cQuery   += "D1_FORNECE,"
cQuery   += "D1_LOJA,"
cQuery   += "A1_NOME,"
cQuery   += "A1_EST,"
cQuery   += "A1_MUN,"
cQuery   += "A1_PRICOM,"
cQuery   += "A1_ULTCOM,"
cQuery   += "A1_HPAGE,"
cQuery   += "A1_OBSERV,"
cQuery   += "A1_SATIV1,"
cQuery   += "A1_XCANALV,"
cQuery   += "A1_CNAE," // MCVN - 18/01/13
cQuery   += "A1_CNES," // MCVN - 18/01/13
cQuery   += "A1_DESCNES," // MCVN - 18/01/13
cQuery   += "A1_SATIV8,"//Giovani Zago 06/10/11

If MV_PAR07 = 1
	cQuery   += "A1_VEND,"
Else
	cQuery   += "F2_VEND1,"
EndIf

cQuery   += "A1_VEND,"
//cQuery   += "A1_VENDKC,"RBORGES 01/11/13 - Comentado conforme solicitaÁ„o do ALVARO MENEZES.
//cQuery   += "         A1_TECNICO, "  RBORGES 01/10/13 - Comentado conforme solicitaÁ„o do Maximo.
cQuery   += "A1_TECN_3,"
cQuery   += "A1_TECN_A,"
cQuery   += "A1_TECN_R,"
cQuery   += "A1_TECN_C," // Reginaldo Borges
cQuery   += "A1_TECN_B," // Reginaldo Borges 06/08/2013
cQuery   += "A1_XTEC_SP,"// Reginaldo Borges 22/02/2013
cQuery   += "A1_XTEC_MA,"// Reginaldo Borges 22/02/2013
cQuery   += "A1_XTEC_HQ,"// Reginaldo Borges 22/02/2013
cQuery   += " A1_VENDHQ,"//Reginaldo Borges 01/11/2013
cQuery   += "A1_XVENDSP,"// Reginaldo Borges 26/09/2013
cQuery   += "X5_DESCRI,"
//cQuery   += "         D2_CUSDIP, "
//cQuery   += "         D1_QUANT, "
cQuery   += "A1_CGC,"
cQuery   += "A1_INSCR,"
cQuery   += "A1_GRPVEN,"  //Giovani Zago 18/08/11
//Giovani Zago
cQuery   += "A1_END, "
cQuery   += "D2_FORNEC, "
cQuery   += "F2_VEND2, "
cQuery   += "A1_EMAILD" // FELIPE DURAN 11/10/2019


//*******************************
Return(cQuery)

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥fFilial() ∫Autor  ≥Jailton B Santos-JBS∫ Data ≥ 22/03/2010  ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥Faz o tratamento para achar a filial para empresa para a    ∫±±
±±∫          ≥qual ira' abrir a tabela informada.                         ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Parametro ≥_cEmpresa: Empresa na qual queremos coletar dados           ∫±±
±±∫          ≥_cTabela : Nome da tabela da qual queremos coletar dados    ∫±±
±±∫          ≥_cFilial : Se a tabela for exclusiva, esta eh a filial da   ∫±±
±±∫          ≥           qual eh preciso coletar dados.                   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ Especifico - Faturamento - DIPROMED                        ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ                                                       
*/
Static Function fFilial(_cEmpresa,_cTabela,_cFilial)
 
Local _cNewFilial := Space(2)
Local _cFile      := 'SX2'+_cEmpresa
Local _cFileIdx   := _cFile 

If Select("SX2_2") = 0
   MsOpEndbf(.T.,"DBFCDX",_cFile,"SX2_2",.T.,.F.)
EndIf

SX2_2->( DbSetOrder(1) )
If SX2_2->( DbSeek(_cTabela) )				
    If SX2_2->X2_MODO = 'E'
        _cNewFilial := _cFilial 
    EndIf 
Else
    _cNewFilial := xFilial(_cTabela) 
EndIf

Return(_cNewFilial) 

  
/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥FindRank() ∫Autor  ≥Maximo Canuto V. Neto-MCVN∫ 25/08/2010  ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥Faz o tratamento para acher o mÍs real do ranking           ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ Especifico - Faturamento - DIPROMED                        ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ                                                       
*/
User Function Dipr25Rank() 

Local cRankDip:= "" 
Local cChave  := "" 
Local aFinkRank := {}
Local nMesFim := Substr(MV_PAR01,1,2)
Local nAnoFim := Substr(MV_PAR01,3,4)
Local nColuna := 1 
Local x

If Val(nMesFim) == 12
	nMesIni := 1
	nAnoIni := Val(Substr(MV_PAR01,3,4))
Else
	nMesIni := Val(nMesFim) + 1
	nAnoIni := Val(nAnoFim) - 1
EndIf


Do case
case MV_PAR08 = 0   
	cChave  := 'TOTAL*-1'
	cRankDip := ' - Ranking pelo Total'
case MV_PAR08 > 12
	cChave  := 'MEDIA*-1'
	cRankDip := ' - Ranking pela Media'
OtherWise
	nColuna := 1 
	For x:= 1 to 12		    
		If nMesIni >= 12
			nMesIni := 1
			nAnoIni := Val(Substr((MV_PAR01),3,4))
			If nColuna == MV_PAR08                                 
				cChave   := 'M'+StrZero(nMesIni,2)+'*-1'    
				cRankDip := ' - Ranking pelo mes de '+MesExtenso(Str(nMesIni))			
			Endif     
			nColuna++
		Else                                        
			If nColuna == MV_PAR08                                 
				cChave   := 'M'+StrZero(nMesIni,2)+'*-1'    
				cRankDip := ' - Ranking pelo mes de '+MesExtenso(Str(nMesIni))			
			Endif     
			nMesIni++
			nAnoIni := Val(Substr((MV_PAR01),3,4))-1
			nColuna++
		EndIf
	Next

End case     
aAdd(aFinkRank,{cChave,cRankDip}) 
Return (aFinkRank)
	

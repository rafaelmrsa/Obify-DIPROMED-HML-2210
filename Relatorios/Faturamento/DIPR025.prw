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
|Jailton/  | 23/03/10 - Customizacao para imprimir multyempresas, somando os fatura-  |
|JBS       |            mentos das Health Quality e Dipromed (CDs)                    |  
|Maximo/   | 26/07/10 - Customizacao para filtrar pelos dois fornecedores HQ que s„o: |
|MCVN      |            (000851 e 051508) quando um deles for solicitado no MV_PAR05  |
|Jailton/  | 28/07/10 - Tratamento para Imprimir carteira ou venda realizada.Otimizado|
|JBS       |a 29/07/10  os parametros do pegunte.                                     |  
\====================================================================================*/

#INCLUDE "Protheus.CH"
#include "rwmake.ch"
#INCLUDE "AP5MAIL.CH"
#INCLUDE "TBICONN.CH"

User Function DIPR025(aWork) 

Local ___cDiprEmpresa := ""  // Nome de Bem diversificado por se tratar de informacoes tratadas por padrao e futuras atualizacoes
Local ___cDiprFilial  := ""

If ValType(aWork) <> 'A'
	cWorkFlow := "N"  
    ___cDiprEmpresa := cEmpAnt
    ___cDiprFilial  := cFilAnt	
Else
    ___cDiprEmpresa := aWork[2]
    ___cDiprFilial  := aWork[3]	
EndIf              

If ___cDiprEmpresa == '04' .and. ___cDiprFilial == '01' 
    fDipR025(aWork) // Versao Anterior, para rodar apenas para a Health Quality (Matriz)
Else                                                                                 
    U_DipR025a(aWork) // Chama a versao MultyEmpresas (Dipromed CD e Health Quality CD) 
EndIf

Return(Nil) 
/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥fDipR025()∫Autor  ≥Eriberto Elias      ∫ Data ≥ 15/05/2003  ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥ Versao anterior do programa, versao apenas uma empresa.    ∫±±
±±∫          ≥                                                            ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ AP                                                         ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Static Function fDipR025(aWork)
                                                            '
Local _xArea    := GetArea() 
Local cUserAut  := GetMV("MV_URELFAT") // MCVN - 04/05/09    
Local zi
Private tamanho    := "G"
Private limite     := 220
Private titulo     := OemTOAnsi("Vendas por cliente mes a mes com total do ano",72)
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

// Private cPerg   := "DIPR25"
// FPADR(cPerg, cArq, cCampo, cTipo)
Private cPerg 
Private _cDipUsr := U_DipUsr()
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

	// MCVN - 10/05/09    
	If !(Upper(_cDipUsr) $ cUserAut .Or. Upper(_cDipUsr) $ cVendInt .or. Upper(_cDipUsr) $ cVendExt .or. Upper(_cDipUsr) $ "IFERREIRA") // MCVN - 07/05/09
		Alert(Upper(_cDipUsr)+", vocÍ n„o tem autorizaÁ„o para utilizar esta rotina. Qualquer d˙vida falar com Eriberto!","AtenÁ„o")	
		Return()
	Endif     
	
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
			If SubStr(X5_DESCRI,1,1) != "*" .and. Val(SubStr(X5_DESCRI,7,2)) < 80 // CondiÁ„o para pegar campos somente com datas e com ano de 2000 em diante
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
		    dDatSis - 6
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
//Local cArqExcell:= GetSrvProfString("STARTPATH","")+"Excell-DBF\"+_cDipUsr+"-DIPR025" // JBS 08/12/2005 

// Alterado para gravar os arquivos na pasta protheus_data - Por Sandro em 19/11/09. 
Local cArqExcell:= "\Excell-DBF\"+_cDipUsr+"-DIPR025" // JBS 08/12/2005
Local aRankChav :={}  // MCVN 26/08/10  
Local aTmp      :={}  // MCVN 27/08/10 

Local aCols	:= {} 
Local _x
Local wi
Local nColuna
Local nI
// Determina os 12 meses que ser„o apresentados
_nMesFim := Substr(MV_PAR01,1,2)
_nAnoFim := Substr(MV_PAR01,3,4)

If Val(_nMesFim) == 12
	_nMesIni := 1
	_nAnoIni := Val(Substr(MV_PAR01,3,4))
Else
	_nMesIni := Val(_nMesFim) + 1
	_nAnoIni := Val(_nAnoFim) - 1
EndIf
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

QRY1 := "SELECT D2_CLIENTE, "
QRY1 += "       D2_LOJA, "
QRY1 += "       A1_NOME, "
QRY1 += "       A1_MUN, "
QRY1 += "       A1_EST, "
QRY1 += "       A1_SATIV1, "
QRY1   += "         A1_SATIV8, "//Giovani Zago 06/10/11
QRY1 += "       X5_DESCRI, " 

If MV_PAR07 = 1  // JBS 28/07/2010 - Carteira = Sim
	QRY1 += "       A1_VENDHQ VENDEDOR, "
Else
	QRY1 += "       F2_VEND1 VENDEDOR, "
Endif

QRY1 += "       A1_PRICOM, "
QRY1 += "       A1_ULTCOM, "
QRY1 += "		A1_XCANALV, "
QRY1 += "       A1_CNAE, "    //MCVN 17/01/2013
QRY1 += "       A1_CNES, "    //MCVN 17/01/2013
QRY1 += "       A1_DESCNES, "    //MCVN 17/01/2013
QRY1 += "       A1_HPAGE, "
QRY1 += "       A1_OBSERV, "
QRY1 += "       A1_VENDKC, "
QRY1 += "       A1_TECNICO, "
QRY1 += "       A1_TECN_3, "
QRY1 += "       A1_TECN_A, "
QRY1 += "       A1_TECN_R, "
QRY1 += "       A1_TECN_C," 
QRY1 += "       A1_XTEC_SP, "
QRY1 += "       A1_XTEC_MA, "
QRY1 += "       A1_XTEC_HQ, "
QRY1 += "       LEFT(D2_EMISSAO,6) D2_EMISSAO, "
QRY1 += "       SUM(D2_TOTAL) D2_TOTAL, "
QRY1 += "       SUM(D2_CUSDIP) D2_CUSDIP, "
QRY1 += "       D2_QUANT, "
QRY1 += "       A1_CGC, "
QRY1 += "       A1_INSCR, "
QRY1 += "       A1_GRPVEN, "
QRY1 += "       A1_END, "  //Giovani Zago 17/08/11
QRY1 += "       A1_EMAILD "  //FELIPE DURAN 11/10/2019
QRY1 += " FROM " 
QRY1 += RetSQLName("SD2") + ', '
QRY1 += RetSQLName("SF2") + ' SF2, '
QRY1 += RetSQLName("SA1") + ', ' 
QRY1 += RetSQLName("SF4") + ', ' 
QRY1 += RetSQLName("SA3") + ', ' 
QRY1 += RetSQLName("SX5")   

If MV_PAR04 == 4 .and. Empty(MV_PAR02)          // JBS 28/07/2010 - Quando For o setor de licitacoes
    QRY1 += ', ' + RetSQLName("SC5") + ' SC5'   // JBS 28/07/2010 - relaciona as tabeas de Pedidos
    QRY1 += ', ' + RetSQLName("SU7") + ' SU7'   // JBS 28/07/2010 - e Operadores ao SD2
EndIf                                            // JBS 28/07/2010
	                  
QRY1 += " WHERE LEFT(D2_EMISSAO,6) BETWEEN '" + _nParIni + "' AND '" + _nParFim + "'"
QRY1 += "    AND D2_TIPO IN ('N','C')"
//QRY1 += " AND D2_TIPO <> 'B'"
QRY1 += " AND F2_FILIAL = D2_FILIAL " // JBS 29/07/2010
QRY1 += " AND F2_DOC    = D2_DOC "    // JBS 29/07/2010 
QRY1 += " AND F2_SERIE  = D2_SERIE "  // JBS 29/07/2010
QRY1 += " AND SF2.D_E_L_E_T_ = '' " // JBS 29/07/2010
QRY1 += " AND D2_CLIENTE = A1_COD"
QRY1 += " AND D2_LOJA = A1_LOJA"
QRY1 += " AND D2_TES = F4_CODIGO"
QRY1 += " AND F4_DUPLIC = 'S'"  

If MV_PAR07 = 1
	QRY1 += " And A3_COD  = A1_VENDHQ " // JBS 28/07/2010
Else
	QRY1 += " And A3_COD  = F2_VEND1 " // JBS 28/07/2010
Endif

QRY1 += " AND A1_SATIV1 *= X5_CHAVE"  // JBS 09/08/2010  - Incluido o left join (*=)  
QRY1 += " AND X5_TABELA = 'T3'"

If !Empty(MV_PAR06)
	QRY1 += " AND A1_GRPVEN = '" +MV_PAR06+"'"
EndIf

If U_ListVend() != ''  
    If MV_PAR07 = 1       
	    QRY1 += " AND A1_VENDHQ " + U_ListVend() 
	Else
	    QRY1 += " AND F2_VEND1 " + U_ListVend() 
	EndIf
EndIf                  

If !Empty(MV_PAR02) // VENDEDOR 
    If MV_PAR07 = 1       
	    QRY1 += " AND A1_VENDHQ = '" + MV_PAR02 + "'"	 
	Else
	    QRY1 += " AND F2_VEND1 = '" + MV_PAR02 + "'"	
	EndIf
Else
	If MV_PAR04 == 1 // APOIO
		QRY1 += " AND A3_TIPO = 'E'	"
	ElseIf MV_PAR04 == 2 // CALL CENTER
		QRY1 += " AND A3_TIPO = 'I'"
	ElseIf MV_PAR04 == 4 // Licitacoes     JBS 28/07/2010
	    QRY1 += " And C5_FILIAL = D2_FILIAL "// Licitacoes     JBS 28/07/2010
	    QRY1 += " And C5_NUM    = D2_PEDIDO "// Licitacoes     JBS 28/07/2010
	    QRY1 += " And SC5.D_E_L_E_T_ = '' "// Licitacoes     JBS 28/07/2010
	    QRY1 += " And UF_FILIAL = '" + xFilial('SU7') + "' "// Licitacoes     JBS 28/07/2010
	    QRY1 += " And U7_COD = C5_OPERADO "// Licitacoes     JBS 28/07/2010
		QRY1 += " And U7_POSTO = '03' "// Licitacoes     JBS 28/07/2010
		QRY1 += " And SU7.D_E_L_E_T_ = '' "// Licitacoes     JBS 28/07/2010
	EndIf
EndIf

// JBS 01/11/2006 - SeleÁ„o por fornecedor

If !Empty(MV_PAR05) // FORNECEDOR
	If MV_PAR05 $ "000851/051508" //CÛdigos do fornecedor HQ
		QRY1 += " AND D2_FORNEC IN ('000851','051508') "
	Else
		QRY1 += " AND D2_FORNEC = '" + MV_PAR05 + "'"
	Endif
EndIf

QRY1 += " AND D2_FILIAL = '" + xFilial('SD2') + "'"
QRY1 += " AND F4_FILIAL = '" + xFilial('SF4') + "'"
QRY1 += " AND A1_FILIAL = '" + xFilial('SA1') + "'"
QRY1 += " AND A3_FILIAL = '" + xFilial('SA3') + "'"
QRY1 += " AND X5_FILIAL = '" + xFilial('SX5') + "'"
QRY1 += " AND " + RetSQLName("SD2") + ".D_E_L_E_T_ = ''"
QRY1 += " AND " + RetSQLName("SF4") + ".D_E_L_E_T_ = ''"
QRY1 += " AND " + RetSQLName("SA1") + ".D_E_L_E_T_ = ''"
QRY1 += " AND " + RetSQLName("SA3") + ".D_E_L_E_T_ = ''"
QRY1 += " AND " + RetSQLName("SX5") + ".D_E_L_E_T_ = ''"
QRY1 += " GROUP BY D2_CLIENTE, "
QRY1 += "          D2_LOJA, "
QRY1 += "          A1_NOME, "
QRY1 += "          A1_MUN, "
QRY1 += "          A1_EST, " 

If MV_PAR07 = 1  // JBS 28/07/2010 
	QRY1   += "       A1_VENDHQ, "
Else
	QRY1   += "       F2_VEND1, "
Endif

QRY1 += "          A1_PRICOM, "
QRY1 += "          A1_ULTCOM, "
QRY1 += "		   A1_XCANALV, "
QRY1 += "   	   A1_CNAE, "    //MCVN 17/01/2013
QRY1 += "      	   A1_CNES, "    //MCVN 17/01/2013
QRY1 += "          A1_DESCNES, "    //MCVN 17/01/2013
QRY1 += "          A1_HPAGE, "
QRY1 += "          A1_OBSERV, "
QRY1 += "          A1_SATIV1, "
QRY1 += "          A1_SATIV8, "//Giovani Zago 06/10/11
QRY1 += "          X5_DESCRI, "
QRY1 += "          LEFT(D2_EMISSAO,6), "
QRY1 += "          D2_TOTAL, "
QRY1 += "          D2_CUSDIP, "
QRY1 += "          D2_QUANT, "
QRY1 += "          A1_VENDKC, "
QRY1 += "          A1_TECNICO, "
QRY1 += "          A1_TECN_3, "
QRY1 += "          A1_TECN_A, "
QRY1 += "          A1_TECN_R, "
QRY1 += "          A1_TECN_C," 
QRY1 += "          A1_XTEC_SP, "
QRY1 += "          A1_XTEC_MA, "
QRY1 += "          A1_XTEC_HQ, "
QRY1 += "          A1_CGC, "
QRY1 += "          A1_INSCR, " // Eriberto 07/10/09      
QRY1 += "          A1_GRPVEN ,"
QRY1 += "          A1_END, "  //Giovani Zago 17/08/11
QRY1 += "          A1_EMAILD "  //FELIPE DURAN 11/10/2019

QRY1 += " ORDER BY D2_CLIENTE, D2_LOJA, LEFT(D2_EMISSAO,6)"

cQuery := ChangeQuery(QRY1)
memowrite('DIPR25_SD2_'+SM0->M0_CODIGO+'0_'+SM0->M0_CODFIL+'.SQL',QRY1)
dbUseArea(.T., "TOPCONN", TCGenQry(,,QRY1), 'QRY1', .F., .T.)


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
/* query antiga
QRY2 := "SELECT SUM(D1_TOTAL) D1_TOTAL, "
QRY2 += "       SUBSTRING(D1_DTDIGIT,1,6) D1_DTDIGIT, " 
QRY2 += "       D1_FORNECE, "
QRY2 += "       D1_LOJA, "
QRY2 += "       A1_NOME, "
QRY2 += "       A1_EST, "
QRY2 += "       A1_PRICOM, "
QRY2 += "       A1_ULTCOM, "  
QRY2 += " 		A1_XCANALV, "
QRY2 += "       A1_CNAE, "    //MCVN 17/01/2013
QRY2 += "       A1_CNES, "    //MCVN 17/01/2013
QRY2 += "       A1_DESCNES, "    //MCVN 17/01/2013
QRY2 += "       A1_HPAGE, "
QRY2 += "       A1_OBSERV," 
QRY2 += "       A1_SATIV1, "
QRY2 += "       A1_SATIV8, "//Giovani Zago 06/10/11
If MV_PAR07 = 1 // JBS 28/07/2010 - Carteira = Sim
	QRY2 += "       A1_VENDHQ  VENDEDOR, "
Else
	QRY2 += "       F2_VEND1 VENDEDOR, "
Endif

QRY2 += "       A1_VENDKC, "
QRY2 += "       A1_TECNICO, "
QRY2 += "       A1_TECN_3, " 
QRY2 += "       A1_TECN_A, "
QRY2 += "       A1_TECN_R, "
QRY2 += "       A1_TECN_C," 
QRY2 += "       A1_XTEC_SP, "
QRY2 += "       A1_XTEC_MA, "
QRY2 += "       A1_XTEC_HQ, "
QRY2 += "       A1_MUN, "
QRY2 += "       X5_DESCRI, " 
QRY2 += "       SUM(D2_CUSDIP) D2_CUSDIP, "
QRY2 += "       D1_QUANT " 
QRY2 += "       A1_CGC, "
QRY2 += "       A1_INSCR, "
QRY2 += "       A1_GRPVEN, "
QRY2 += "       A1_END, "  //Giovani Zago 17/08/11
QRY2 += "       A1_EMAILD "  //FELIPE DURAN 11/10/2019
QRY2 += " FROM " 
QRY2 += RetSQLName('SD1') + ", " 
QRY2 += RetSQLName('SD2') + ", " 
QRY2 += RetSQLName("SF2") + ' SF2, '
QRY2 += RetSQLName('SF4') + ", " 
QRY2 += RetSQLName('SA3') + ", " 
QRY2 += RetSQLName('SA1') + ", "
QRY2 += RetSQLName("SX5")

If MV_PAR04 == 4 .and. Empty(MV_PAR02)          // JBS 28/07/2010 - Quando For o setor de licitacoes
    QRY2 += ', ' + RetSQLName("SC5") + ' SC5'   // JBS 28/07/2010 - relaciona as tabeas de Pedidos
    QRY2 += ', ' + RetSQLName("SU7") + ' SU7'   // JBS 28/07/2010 - e Operadores ao SD2
EndIf                                            // JBS 28/07/2010

QRY2 += " WHERE SUBSTRING(D1_DTDIGIT,1,6) BETWEEN '" + _nParIni + "' AND '" + _nParFim + "'"
QRY2 += " AND D1_TIPO    = 'D'"
QRY2 += " AND D1_FORNECE = A1_COD"
QRY2 += " AND D1_LOJA    = A1_LOJA"
QRY2 += " AND D1_FILIAL  = D2_FILIAL"
QRY2 += " AND D1_NFORI   = D2_DOC"
QRY2 += " AND D1_SERIORI = D2_SERIE"
QRY2 += " AND D1_ITEMORI = D2_ITEM"  
QRY2 += " AND F2_FILIAL = D2_FILIAL " // JBS 29/07/2010
QRY2 += " AND F2_DOC    = D2_DOC "    // JBS 29/07/2010 
QRY2 += " AND F2_SERIE  = D2_SERIE "  // JBS 29/07/2010
QRY2 += " AND SF2.D_E_L_E_T_ = '' " // JBS 29/07/2010
QRY2 += " AND D1_TES     = F4_CODIGO"
QRY2 += " AND F4_DUPLIC  = 'S' "   

If MV_PAR07 = 1 // JBS 29/07/2010
	QRY2 += " And A3_COD  = A1_VENDHQ " // JBS 28/07/2010
Else
	QRY2 += " And A3_COD  = F2_VEND1 " // JBS 28/07/2010
Endif

QRY2 += " AND A1_SATIV1 *= X5_CHAVE"   // JBS 09/08/2010  - Incluido o left join (*=)
QRY2 += " AND X5_TABELA = 'T3'"

If !Empty(MV_PAR06)
	QRY2 += " AND A1_GRPVEN = '" +MV_PAR06+"'"
EndIf

If U_ListVend() != ''  
    If MV_PAR07 = 1       
	    QRY2 += " AND A1_VENDHQ " + U_ListVend() 
	Else
	    QRY2 += " AND F2_VEND1 " + U_ListVend() 
	EndIf
EndIf                  

If !Empty(MV_PAR02) // VENDEDOR 
    If MV_PAR07 = 1       
	    QRY2 += " AND A1_VENDHQ = '" + MV_PAR02 + "'"	 
	Else
	    QRY2 += " AND F2_VEND1 = '" + MV_PAR02 + "'"	
	EndIf
Else
	If MV_PAR04 == 1 // APOIO
		QRY2 += " AND A3_TIPO = 'E'	"
	ElseIf MV_PAR04 == 2 // CALL CENTER
		QRY2 += " AND A3_TIPO = 'I'"
	ElseIf MV_PAR04 == 4 // Licitacoes     JBS 28/07/2010
	    QRY2 += " And C5_FILIAL = D2_FILIAL "// Licitacoes     JBS 28/07/2010
	    QRY2 += " And C5_NUM    = D2_PEDIDO "// Licitacoes     JBS 28/07/2010
	    QRY2 += " And SC5.D_E_L_E_T_ = '' "// Licitacoes     JBS 28/07/2010
	    QRY2 += " And UF_FILIAL = '" + xFilial('SU7') + "' "// Licitacoes     JBS 28/07/2010
	    QRY2 += " And U7_COD = C5_OPERADO "// Licitacoes     JBS 28/07/2010
		QRY2 += " And U7_POSTO = '03' "// Licitacoes     JBS 28/07/2010
		QRY2 += " And SU7.D_E_L_E_T_ = '' "// Licitacoes     JBS 28/07/2010
	EndIf
EndIf

// JBS 01/11/2006 - SeleÁ„o por fornecedor

If !Empty(MV_PAR05) // FORNECEDOR
	If MV_PAR05 $ "000851/051508" //CÛdigos do fornecedor HQ
		QRY2 += " AND D2_FORNEC IN ('000851','051508') "
	Else
		QRY2 += " AND D2_FORNEC = '" + MV_PAR05 + "'"
	Endif
EndIf

QRY2 += " AND D1_FILIAL = '" + xFilial('SD1') + "'"
QRY2 += " AND D2_FILIAL = '" + xFilial('SD2') + "'"
QRY2 += " AND F4_FILIAL = '" + xFilial('SF4') + "'"
QRY2 += " AND A1_FILIAL = '" + xFilial('SA1') + "'"
QRY2 += " AND A3_FILIAL = '" + xFilial('SA3') + "'"
QRY2 += " AND X5_FILIAL = '" + xFilial('SX5') + "'"
QRY2 += " AND " + RetSQLName('SD1') + ".D_E_L_E_T_ <> '*'"
QRY2 += " AND " + RetSQLName('SD2') + ".D_E_L_E_T_ <> '*'"
QRY2 += " AND " + RetSQLName('SF4') + ".D_E_L_E_T_ <> '*'"
QRY2 += " AND " + RetSQLName('SA3') + ".D_E_L_E_T_ <> '*'"
QRY2 += " AND " + RetSQLName('SA1') + ".D_E_L_E_T_ <> '*'"
QRY2 += " AND " + RetSQLName('SX5') + ".D_E_L_E_T_ <> '*'"
QRY2 += " GROUP BY SUBSTRING(D1_DTDIGIT,1,6), "
QRY2 += "          D1_FORNECE, "
QRY2 += "          D1_LOJA, "
QRY2 += "          A1_NOME, "
QRY2 += "          A1_EST, "
QRY2 += "          A1_MUN, "
QRY2 += "          A1_PRICOM, "
QRY2 += "          A1_ULTCOM, "
QRY2 += " 		   A1_XCANALV, "
QRY2 += "          A1_CNAE, "    //MCVN 17/01/2013
QRY2 += "          A1_CNES, "    //MCVN 17/01/2013
QRY2 += "          A1_DESCNES, "    //MCVN 17/01/2013
QRY2 += "          A1_HPAGE, "
QRY2 += "          A1_OBSERV, "
QRY2 += "          A1_SATIV1, "
QRY2 += "          A1_SATIV8, "//Giovani Zago 06/10/11
If MV_PAR07 = 1 
    QRY2 += "          A1_VENDHQ, "
Else
    QRY2 += "          F2_VEND1, "
EndIf
QRY2 += "          A1_VENDKC, "
QRY2 += "          A1_TECNICO, "
QRY2 += "          A1_TECN_3, "
QRY2 += "          A1_TECN_A, "
QRY2 += "          A1_TECN_R, "
QRY2 += "   	   A1_TECN_C," 
QRY2 += "   	   A1_XTEC_SP, "
QRY2 += "   	   A1_XTEC_MA, "
QRY2 += "    	   A1_XTEC_HQ, "
QRY2 += "          X5_DESCRI, "
QRY2 += "          D2_CUSDIP, "
QRY2 += "          D1_QUANT, "
QRY2 += "          A1_CGC, "
QRY2 += "          A1_INSCR, " 
QRY2 += "          A1_GRPVEN, "
QRY2 += "       A1_END, "  //Giovani Zago 17/08/11
QRY2 += "       A1_EMAILD "  //FELIPE DURAN 11/10/2019 
QRY2 += " ORDER BY D1_FORNECE, D1_LOJA, D1_DTDIGIT "
*/

QRY2 := "SELECT SUM(D1_TOTAL) D1_TOTAL, "
QRY2 += "       SUBSTRING(D1_DTDIGIT,1,6) D1_DTDIGIT, " 
QRY2 += "       D1_FORNECE, "
QRY2 += "       D1_LOJA, "
QRY2 += "       A1_NOME, "
QRY2 += "       A1_EST, "
QRY2 += "       A1_PRICOM, "
QRY2 += "       A1_ULTCOM, "  
QRY2 += " 		A1_XCANALV, "
QRY2 += "       A1_CNAE, "    //MCVN 17/01/2013
QRY2 += "       A1_CNES, "    //MCVN 17/01/2013
QRY2 += "       A1_DESCNES, "    //MCVN 17/01/2013
QRY2 += "       A1_HPAGE, "
QRY2 += "       A1_OBSERV," 
QRY2 += "       A1_SATIV1, "
QRY2 += "       A1_SATIV8, "//Giovani Zago 06/10/11
If MV_PAR07 = 1 // JBS 28/07/2010 - Carteira = Sim
	QRY2 += "       A1_VENDHQ  VENDEDOR, "
Else
	QRY2 += "       F2_VEND1 VENDEDOR, "
Endif
QRY2 += "       A1_VENDKC, "
QRY2 += "       A1_TECNICO, "
QRY2 += "       A1_TECN_3, " 
QRY2 += "       A1_TECN_A, "
QRY2 += "       A1_TECN_R, "
QRY2 += "       A1_TECN_C," 
QRY2 += "       A1_XTEC_SP, "
QRY2 += "       A1_XTEC_MA, "
QRY2 += "       A1_XTEC_HQ, "
QRY2 += "       A1_MUN, "
QRY2 += "       X5_DESCRI, " 
QRY2 += "       SUM(D2_CUSDIP) D2_CUSDIP, "
QRY2 += "       D1_QUANT " 
QRY2 += "       A1_CGC, "
QRY2 += "       A1_INSCR, "
QRY2 += "       A1_GRPVEN, "
QRY2 += "       A1_END, "  //Giovani Zago 17/08/11
QRY2 += "       A1_EMAILD "  //FELIPE DURAN 11/10/2019
QRY2 += " FROM " 
QRY2 += RetSQLName('SD1') + " " 
QRY2 += " INNER JOIN "+RetSQLName('SD2') + " ON " 
QRY2 += " D1_FILIAL  = D2_FILIAL"
QRY2 += " AND D1_NFORI   = D2_DOC"
QRY2 += " AND D1_SERIORI = D2_SERIE"
QRY2 += " AND D1_ITEMORI = D2_ITEM"  
QRY2 += " INNER JOIN "+RetSQLName("SF2") + ' SF2 ON '
QRY2 += " F2_FILIAL = D2_FILIAL " // JBS 29/07/2010
QRY2 += " AND F2_DOC    = D2_DOC "    // JBS 29/07/2010 
QRY2 += " AND F2_SERIE  = D2_SERIE "  // JBS 29/07/2010
QRY2 += " AND SF2.D_E_L_E_T_ = '' " // JBS 29/07/2010
QRY2 += " INNER JOIN "+RetSQLName('SF4') + " ON " 
QRY2 += " D1_TES     = F4_CODIGO"
QRY2 += " AND F4_DUPLIC  = 'S' "   
QRY2 += " INNER JOIN "+RetSQLName('SA1') + " ON "
QRY2 += " D1_FORNECE = A1_COD"
QRY2 += " AND D1_LOJA    = A1_LOJA"
QRY2 += " INNER JOIN "+RetSQLName('SA3') + " ON " 
If MV_PAR07 = 1 // JBS 29/07/2010
	QRY2 += " A3_COD  = A1_VENDHQ " // JBS 28/07/2010
Else
	QRY2 += " A3_COD  = F2_VEND1 " // JBS 28/07/2010
Endif
If MV_PAR04 == 4 .and. Empty(MV_PAR02)          // JBS 28/07/2010 - Quando For o setor de licitacoes
    QRY2 += " INNER JOIN "+RetSQLName("SC5") + ' SC5 ON'   // JBS 28/07/2010 - relaciona as tabeas de Pedidos
    QRY2 += " C5_FILIAL = D2_FILIAL "// Licitacoes     JBS 28/07/2010
    QRY2 += " And C5_NUM    = D2_PEDIDO "// Licitacoes     JBS 28/07/2010
	QRY2 += " INNER JOIN "+RetSQLName("SU7") + ' SU7 ON'   // JBS 28/07/2010 - e Operadores ao SD2
	QRY2 += " U7_COD = C5_OPERADO "// Licitacoes     JBS 28/07/2010
	QRY2 += " And U7_POSTO = '03' "// Licitacoes     JBS 28/07/2010
EndIf                                            // JBS 28/07/2010
QRY2 += " LEFT JOIN "+RetSQLName("SX5")+" ON "
QRY2 += " X5_FILIAL = '" + xFilial('SX5') + "'"
QRY2 += " AND A1_SATIV1 = X5_CHAVE"   // JBS 09/08/2010  - Incluido o left join (*=) //AJUSTADO HQ - MIGRACAO NUVEM
QRY2 += " AND X5_TABELA = 'T3'"
QRY2 += " AND " + RetSQLName('SX5') + ".D_E_L_E_T_ <> '*'"
QRY2 += " WHERE SUBSTRING(D1_DTDIGIT,1,6) BETWEEN '" + _nParIni + "' AND '" + _nParFim + "'"
QRY2 += " AND D1_TIPO    = 'D'"
If !Empty(MV_PAR06)
	QRY2 += " AND A1_GRPVEN = '" +MV_PAR06+"'"
EndIf
If U_ListVend() != ''  
    If MV_PAR07 = 1       
	    QRY2 += " AND A1_VENDHQ " + U_ListVend() 
	Else
	    QRY2 += " AND F2_VEND1 " + U_ListVend() 
	EndIf
EndIf                  
If !Empty(MV_PAR02) // VENDEDOR 
    If MV_PAR07 = 1       
	    QRY2 += " AND A1_VENDHQ = '" + MV_PAR02 + "'"	 
	Else
	    QRY2 += " AND F2_VEND1 = '" + MV_PAR02 + "'"	
	EndIf
Else
	If MV_PAR04 == 1 // APOIO
		QRY2 += " AND A3_TIPO = 'E'	"
	ElseIf MV_PAR04 == 2 // CALL CENTER
		QRY2 += " AND A3_TIPO = 'I'"
	ElseIf MV_PAR04 == 4 // Licitacoes     JBS 28/07/2010
	    QRY2 += " And SC5.D_E_L_E_T_ = '' "// Licitacoes     JBS 28/07/2010
	    QRY2 += " And UF_FILIAL = '" + xFilial('SU7') + "' "// Licitacoes     JBS 28/07/2010
		QRY2 += " And SU7.D_E_L_E_T_ = '' "// Licitacoes     JBS 28/07/2010
	EndIf
EndIf
// JBS 01/11/2006 - SeleÁ„o por fornecedor
If !Empty(MV_PAR05) // FORNECEDOR
	If MV_PAR05 $ "000851/051508" //CÛdigos do fornecedor HQ
		QRY2 += " AND D2_FORNEC IN ('000851','051508') "
	Else
		QRY2 += " AND D2_FORNEC = '" + MV_PAR05 + "'"
	Endif
EndIf
QRY2 += " AND D1_FILIAL = '" + xFilial('SD1') + "'"
QRY2 += " AND D2_FILIAL = '" + xFilial('SD2') + "'"
QRY2 += " AND F4_FILIAL = '" + xFilial('SF4') + "'"
QRY2 += " AND A1_FILIAL = '" + xFilial('SA1') + "'"
QRY2 += " AND A3_FILIAL = '" + xFilial('SA3') + "'"
QRY2 += " AND " + RetSQLName('SD1') + ".D_E_L_E_T_ <> '*'"
QRY2 += " AND " + RetSQLName('SD2') + ".D_E_L_E_T_ <> '*'"
QRY2 += " AND " + RetSQLName('SF4') + ".D_E_L_E_T_ <> '*'"
QRY2 += " AND " + RetSQLName('SA3') + ".D_E_L_E_T_ <> '*'"
QRY2 += " AND " + RetSQLName('SA1') + ".D_E_L_E_T_ <> '*'"
QRY2 += " GROUP BY SUBSTRING(D1_DTDIGIT,1,6), "
QRY2 += "          D1_FORNECE, "
QRY2 += "          D1_LOJA, "
QRY2 += "          A1_NOME, "
QRY2 += "          A1_EST, "
QRY2 += "          A1_MUN, "
QRY2 += "          A1_PRICOM, "
QRY2 += "          A1_ULTCOM, "
QRY2 += " 		   A1_XCANALV, "
QRY2 += "          A1_CNAE, "    //MCVN 17/01/2013
QRY2 += "          A1_CNES, "    //MCVN 17/01/2013
QRY2 += "          A1_DESCNES, "    //MCVN 17/01/2013
QRY2 += "          A1_HPAGE, "
QRY2 += "          A1_OBSERV, "
QRY2 += "          A1_SATIV1, "
QRY2 += "          A1_SATIV8, "//Giovani Zago 06/10/11
If MV_PAR07 = 1 
    QRY2 += "          A1_VENDHQ, "
Else
    QRY2 += "          F2_VEND1, "
EndIf
QRY2 += "          A1_VENDKC, "
QRY2 += "          A1_TECNICO, "
QRY2 += "          A1_TECN_3, "
QRY2 += "          A1_TECN_A, "
QRY2 += "          A1_TECN_R, "
QRY2 += "   	   A1_TECN_C," 
QRY2 += "   	   A1_XTEC_SP, "
QRY2 += "   	   A1_XTEC_MA, "
QRY2 += "    	   A1_XTEC_HQ, "
QRY2 += "          X5_DESCRI, "
QRY2 += "          D2_CUSDIP, "
QRY2 += "          D1_QUANT, "
QRY2 += "          A1_CGC, "
QRY2 += "          A1_INSCR, " 
QRY2 += "          A1_GRPVEN, "
QRY2 += "       A1_END, "  //Giovani Zago 17/08/11
QRY2 += "       A1_EMAILD "  //FELIPE DURAN 11/10/2019 
QRY2 += " ORDER BY D1_FORNECE, D1_LOJA, D1_DTDIGIT "

cQuery := ChangeQuery(QRY2)
memowrite('DIPR25_SD1_'+SM0->M0_CODIGO+'0_'+SM0->M0_CODFIL+'.SQL',QRY2)
dbUseArea(.T., "TOPCONN", TCGenQry(,,QRY2), 'QRY2', .F., .T.)


ProcRegua(300)
For _x := 1 to 200
	IncProc("Processando carteira. . . ")
Next
/* query antiga
QRY3 := "SELECT A1_COD, "
QRY3 += "       A1_LOJA, " 
QRY3 += "       A1_NOME, "
QRY3 += "       A1_MUN, "
QRY3 += "       A1_EST, "
QRY3 += "       A1_VENDHQ VENDEDOR," 
QRY3 += "       A1_PRICOM, "
QRY3 += "       A1_ULTCOM, "
QRY3 += "       A1_XCANALV, " //Reginaldo Borges 28/08/2012
QRY3 += "       A1_CNAE, "    //MCVN 17/01/2013
QRY3 += "       A1_CNES, "    //MCVN 17/01/2013
QRY3 += "       A1_DESCNES, "    //MCVN 17/01/2013
QRY3 += "       A1_HPAGE, "
QRY3 += "       A1_SATIV1, "
QRY3 += "          A1_SATIV8, "//Giovani Zago 06/10/11
QRY3 += "       A1_OBSERV, "
QRY3 += "       X5_DESCRI, "
QRY3 += "       A1_CGC, "
QRY3 += "       A1_INSCR, "     
QRY3 += "       A1_GRPVEN, "
QRY3 += "       A1_VENDKC, "
QRY3 += "       A1_TECNICO, "
QRY3 += "       A1_TECN_3, "
QRY3 += "       A1_TECN_A, "
QRY3 += "       A1_TECN_R, "
QRY3 += "       A1_TECN_C, "
QRY3 += "       A1_XTEC_SP, "
QRY3 += "       A1_XTEC_MA, "
QRY3 += "       A1_XTEC_HQ, "
QRY3 += "       A1_END, "
QRY3 += "       A1_EMAILD " //FELIPE DURAN 11/10/2019
QRY3 += " FROM " 
QRY3 += RetSQLName("SA1") + ", "
QRY3 += RetSQLName("SX5") + ", "
QRY3 += RetSQLName("SA3")

QRY3 += " WHERE " + RetSQLName("SA1") + ".D_E_L_E_T_ = ''"
QRY3 += " AND " + RetSQLName("SX5") + ".D_E_L_E_T_ = ''"
QRY3 += " AND " + RetSQLName("SA3") + ".D_E_L_E_T_ = ''"
QRY3 += " AND A1_SATIV1 *= X5_CHAVE"  
QRY3 += " AND X5_TABELA = 'T3'"

QRY3 += " AND A1_VENDHQ = A3_COD "

If !Empty(MV_PAR06)
	QRY3 += " AND A1_GRPVEN = '" +MV_PAR06+"'"
EndIf

If U_ListVend() != ''
	QRY3 += " AND A1_VENDHQ " + U_ListVend()
EndIf

If !Empty(MV_PAR02) // VENDEDOR
	QRY3 += " AND A1_VENDHQ = '" + MV_PAR02 + "'"
Else
	If MV_PAR04 == 1 // APOIO
		QRY3 += " AND A3_TIPO = 'E'	"
	ElseIf MV_PAR04 == 2 // CALL CENTER
		QRY3 += " AND A3_TIPO = 'I' "
	EndIf
EndIf

QRY3 += " ORDER BY A1_COD, A1_LOJA "
*/

QRY3 := "SELECT A1_COD, "
QRY3 += "       A1_LOJA, " 
QRY3 += "       A1_NOME, "
QRY3 += "       A1_MUN, "
QRY3 += "       A1_EST, "
QRY3 += "       A1_VENDHQ VENDEDOR," 
QRY3 += "       A1_PRICOM, "
QRY3 += "       A1_ULTCOM, "
QRY3 += "       A1_XCANALV, " //Reginaldo Borges 28/08/2012
QRY3 += "       A1_CNAE, "    //MCVN 17/01/2013
QRY3 += "       A1_CNES, "    //MCVN 17/01/2013
QRY3 += "       A1_DESCNES, "    //MCVN 17/01/2013
QRY3 += "       A1_HPAGE, "
QRY3 += "       A1_SATIV1, "
QRY3 += "          A1_SATIV8, "//Giovani Zago 06/10/11
QRY3 += "       A1_OBSERV, "
QRY3 += "       X5_DESCRI, "
QRY3 += "       A1_CGC, "
QRY3 += "       A1_INSCR, "     
QRY3 += "       A1_GRPVEN, "
QRY3 += "       A1_VENDKC, "
QRY3 += "       A1_TECNICO, "
QRY3 += "       A1_TECN_3, "
QRY3 += "       A1_TECN_A, "
QRY3 += "       A1_TECN_R, "
QRY3 += "       A1_TECN_C, "
QRY3 += "       A1_XTEC_SP, "
QRY3 += "       A1_XTEC_MA, "
QRY3 += "       A1_XTEC_HQ, "
QRY3 += "       A1_END, "
QRY3 += "       A1_EMAILD " //FELIPE DURAN 11/10/2019
QRY3 += " FROM " 
QRY3 += RetSQLName("SA1") +" "
QRY3 += " INNER JOIN "+RetSQLName("SA3") + " ON "
QRY3 += " A1_VENDHQ = A3_COD "
QRY3 += " LEFT JOIN "+RetSQLName("SX5") + " ON " //AJUSTADO HQ - MIGRACAO NUVEM
QRY3 += " A1_SATIV1 = X5_CHAVE"  
QRY3 += " AND X5_TABELA = 'T3'"
QRY3 += " AND " + RetSQLName("SX5") + ".D_E_L_E_T_ = ''"
QRY3 += " WHERE " + RetSQLName("SA1") + ".D_E_L_E_T_ = ''"
QRY3 += " AND " + RetSQLName("SA3") + ".D_E_L_E_T_ = ''"
If !Empty(MV_PAR06)
	QRY3 += " AND A1_GRPVEN = '" +MV_PAR06+"'"
EndIf
If U_ListVend() != ''
	QRY3 += " AND A1_VENDHQ " + U_ListVend()
EndIf
If !Empty(MV_PAR02) // VENDEDOR
	QRY3 += " AND A1_VENDHQ = '" + MV_PAR02 + "'"
Else
	If MV_PAR04 == 1 // APOIO
		QRY3 += " AND A3_TIPO = 'E'	"
	ElseIf MV_PAR04 == 2 // CALL CENTER
		QRY3 += " AND A3_TIPO = 'I' "
	EndIf
EndIf
QRY3 += " ORDER BY A1_COD, A1_LOJA "

cQuery := ChangeQuery(QRY3)
memowrite('DIPR25_SA1_'+SM0->M0_CODIGO+'0_'+SM0->M0_CODFIL+'.SQL',QRY3)  // JBS 28/07/2010
dbUseArea(.T., "TOPCONN", TCGenQry(,,QRY3), 'QRY3', .F., .T.)


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
If Upper(_cDipUsr) $ cSHWCUST// JBS 20/03/2006
	AAdd(_aCampos ,{"CUST_TOTAL","N",_aTamSX3[1],_aTamSX3[2]}) // JBS 20/03/2006
	AAdd(_aCampos ,{"MARG_TOTAL","N",_aTamSX3[1],_aTamSX3[2]}) // JBS 20/03/2006
	AAdd(_aCampos ,{"CUST_MEDIA","N",_aTamSX3[1],_aTamSX3[2]}) // JBS 20/03/2006
	AAdd(_aCampos ,{"MARG_MEDIA","N",_aTamSX3[1],_aTamSX3[2]}) // JBS 20/03/2006
EndIf
AAdd(_aCampos ,{"CNT"    , "N", 12,4})
AAdd(_aCampos ,{"PCT_CNT", "N", 12,4})
AAdd(_aCampos ,{"OBSERVACAO", "C", 40,0})           

// Incluindo os tÈcnicos no relatÛrio  -   MCVN 04/12/07
_aTamSX3 := TamSX3("A3_COD")
AAdd(_aCampos ,{"VENDKC", "C",_aTamSX3[1],_aTamSX3[2]})
_aTamSX3 := TamSX3("A3_NOME")
AAdd(_aCampos ,{"N_VENDKC", "C",_aTamSX3[1],_aTamSX3[2]})
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
_aTamSX3 := TamSX3("A3_COD")
AAdd(_aCampos ,{"TECNICO", "C",_aTamSX3[1],_aTamSX3[2]})
_aTamSX3 := TamSX3("A3_NOME")
AAdd(_aCampos ,{"NOME_TEC", "C",_aTamSX3[1],_aTamSX3[2]}) 
_aTamSX3 := TamSX3("A3_COD")
AAdd(_aCampos ,{"TEC_CONVAT", "C",_aTamSX3[1],_aTamSX3[2]})
_aTamSX3 := TamSX3("A3_NOME")
AAdd(_aCampos ,{"NTEC_CONVA", "C",_aTamSX3[1],_aTamSX3[2]})
AAdd(_aCampos ,{"TECN_SP", "C",_aTamSX3[1],_aTamSX3[2]})
_aTamSX3 := TamSX3("A3_NOME")
AAdd(_aCampos ,{"NTECN_SP", "C",_aTamSX3[1],_aTamSX3[2]})
AAdd(_aCampos ,{"TECN_MA", "C",_aTamSX3[1],_aTamSX3[2]})
_aTamSX3 := TamSX3("A3_NOME")
AAdd(_aCampos ,{"NTECN_MA", "C",_aTamSX3[1],_aTamSX3[2]})
AAdd(_aCampos ,{"TECN_HQ", "C",_aTamSX3[1],_aTamSX3[2]})
_aTamSX3 := TamSX3("A3_NOME")
AAdd(_aCampos ,{"NTECN_HQ", "C",_aTamSX3[1],_aTamSX3[2]})

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
_aTamSX3 := TamSX3("A1_EMAILD")
AAdd(_aCampos ,{"EMAILD", "C",_aTamSX3[1],_aTamSX3[2]})
_aTamSX3 := TamSX3("A1_XCANALV")
AAdd(_aCampos ,{"CANAL_VEND", "C",_aTamSX3[1]+40,_aTamSX3[2]})// Reginaldo Borges 28/08/2012

_aTamSX3 := TamSX3("A1_CNAE")
AAdd(_aCampos ,{"CNAE", "C",_aTamSX3[1]+30,_aTamSX3[2]})// MCVN 17/01/2013

_aTamSX3 := TamSX3("A1_CNES")
AAdd(_aCampos ,{"CNES", "C",_aTamSX3[1]+30,_aTamSX3[2]})// MCVN 17/01/2013

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
	
	If TRB->(!DbSeek(QRY1->D2_CLIENTE + QRY1->D2_LOJA + QRY1->VENDEDOR))  // JBS 29/07/2010 - Incluir o vendedor na quebra por cliente

		SA3->( DbSeek(cFilSA3 + QRY1->VENDEDOR)) 
		
		RecLock("TRB",.T.)    
		ACY->(dbSeek(xFilial('ACY')+QRY1->A1_GRPVEN))
		TRB->GRUPO     := QRY1->A1_GRPVEN+" - "+ACY->ACY_DESCRI
		TRB->CLIENTE   := QRY1->D2_CLIENTE
		TRB->LOJA      := QRY1->D2_LOJA
		TRB->NOME      := QRY1->A1_NOME
		TRB->CIDADE    := QRY1->A1_MUN
		TRB->UF        := QRY1->A1_EST          
		TRB->VENDEDOR  := QRY1->VENDEDOR // JBS 29/07/2010 - Usando o vendedor fixo da query
		TRB->NOME_VEN  := SA3->A3_NREDUZ
		TRB->SEGMENTO  := QRY1->A1_SATIV1
		TRB->SEGMENTO2 := QRY1->A1_SATIV8 //Giovani Zago	06/10/11 
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
		TRB->VENDKC    := QRY1->A1_VENDKC
		SA3->(dbSeek(xFilial('SA3')+QRY1->A1_VENDKC))
		TRB->N_VENDKC  := SA3->A3_NOME		
		TRB->TECNICO   := QRY1->A1_TECNICO
		SA3->(dbSeek(xFilial('SA3')+QRY1->A1_TECNICO))
		TRB->NOME_TEC  := SA3->A3_NOME                                                            
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
		TRB->TECN_SP:= QRY1->A1_XTEC_SP
		SA3->(dbSeek(xFilial('SA3')+QRY1->A1_XTEC_SP)) 
		TRB->NTECN_SP   := SA3->A3_NOME
		TRB->TECN_MA:= QRY1->A1_XTEC_MA		
		SA3->(dbSeek(xFilial('SA3')+QRY1->A1_XTEC_MA))
		TRB->NTECN_MA   := SA3->A3_NOME
	   	TRB->TECN_HQ:= QRY1->A1_XTEC_HQ
		SA3->(dbSeek(xFilial('SA3')+QRY1->A1_XTEC_HQ))
		TRB->NTECN_HQ   := SA3->A3_NOME
		TRB->EMAILD		:= QRY1->A1_EMAILD
		
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
			nCusto := TRB->(FieldGet(FieldPos('C'+SubStr(QRY1->D2_EMISSAO,5,2)))) + (QRY1->D2_CUSDIP*QRY1->D2_QUANT)  // JBS 20/03/2006
			TRB->CUST_TOTAL := TRB->CUST_TOTAL + (QRY1->D2_CUSDIP*QRY1->D2_QUANT)// JBS 20/03/2006
			TRB->(Fieldput(FieldPos('C'+SubStr(QRY1->D2_EMISSAO,5,2)),nCusto))   // JBS 20/03/2006					
			
		EndIf
	Else
		RecLock("TRB",.F.)
		TRB->TOTAL := TRB->TOTAL + QRY1->D2_TOTAL
		nTotMes := TRB->(FieldGet(FieldPos('M'+SubStr(QRY1->D2_EMISSAO,5,2)))) + QRY1->D2_TOTAL // JBS 20/03/2006
		TRB->(Fieldput(FieldPos('M'+SubStr(QRY1->D2_EMISSAO,5,2)),nTotMes))       // JBS 20/03/2006		
		
		If Upper(_cDipUsr) $ cSHWCUST      // JBS 20/03/2006
			nCusto := TRB->(FieldGet(FieldPos('C'+SubStr(QRY1->D2_EMISSAO,5,2)))) + (QRY1->D2_CUSDIP*QRY1->D2_QUANT)  // JBS 20/03/2006
			TRB->CUST_TOTAL := TRB->CUST_TOTAL + (QRY1->D2_CUSDIP*QRY1->D2_QUANT) // JBS 20/03/2006
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
	
	If TRB->(!DbSeek(QRY2->D1_FORNECE + QRY2->D1_LOJA))

		SA3->(dbSeek(cFilSA3+QRY2->VENDEDOR)) // JBS 29/07/2010 - Incluido o vendedor na quebra do cliente
		
		RecLock("TRB",.T.)      
		ACY->(dbSeek(xFilial('ACY')+QRY2->A1_GRPVEN))
		TRB->GRUPO     := QRY2->A1_GRPVEN+" - "+ACY->ACY_DESCRI
		TRB->CLIENTE   := QRY2->D1_FORNECE
		TRB->LOJA      := QRY2->D1_LOJA
		TRB->NOME      := QRY2->A1_NOME
		TRB->UF        := QRY2->A1_EST  
		TRB->CIDADE    := QRY2->A1_MUN          
		TRB->VENDEDOR  := QRY2->VENDEDOR  // JBS 29/07/2010 - Usando um vendedor so trazido da query
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
		TRB->VENDKC    := QRY2->A1_VENDKC
		SA3->(dbSeek(xFilial('SA3')+QRY2->A1_VENDKC))
		TRB->N_VENDKC  := SA3->A3_NOME		
		TRB->TECNICO   := QRY2->A1_TECNICO
		SA3->(dbSeek(xFilial('SA3')+QRY2->A1_TECNICO))
		TRB->NOME_TEC  := SA3->A3_NOME                                                            
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
		TRB->TECN_SP:= QRY2->A1_XTEC_SP
		SA3->(dbSeek(xFilial('SA3')+QRY2->A1_XTEC_SP)) 
		TRB->NTECN_SP   := SA3->A3_NOME
		TRB->TECN_MA:= QRY2->A1_XTEC_MA		
		SA3->(dbSeek(xFilial('SA3')+QRY2->A1_XTEC_MA))
		TRB->NTECN_MA   := SA3->A3_NOME
	   	TRB->TECN_HQ:= QRY2->A1_XTEC_HQ
		SA3->(dbSeek(xFilial('SA3')+QRY2->A1_XTEC_HQ))
		TRB->NTECN_HQ   := SA3->A3_NOME
		TRB->EMAILD		:= QRY2->A1_EMAILD
				
        // Eriberto 07/10/09
		TRB->CNPJ := QRY1->A1_CGC
		TRB->IE   := QRY1->A1_INSCR
			//Giovani Zago 18/08/11
		TRB->ENDERECO   := QRY1->A1_END
		TRB->CANAL_VEND := IF(!Empty(QRY2->A1_XCANALV),posicione("SX5",1,xFilial("SX5")+"X0"+ALLTRIM(QRY2->A1_XCANALV),"X5_DESCRI"),"") // Reginaldo Borges 28/08/2012
   		TRB->CNAE := QRY2->A1_CNAE+' - '+IF(!Empty(QRY2->A1_CNAE),posicione("CC3",1,xFilial("CC3")+ALLTRIM(QRY2->A1_CNAE),"CC3_DESC"),"") 
   		TRB->CNES := QRY2->A1_CNES +' - '+ QRY2->A1_DESCNES
				
		//************************
		nTotMes := TRB->(FieldGet(FieldPos('M'+SubStr(QRY2->D1_DTDIGIT,5,2)))) - QRY2->D1_TOTAL // JBS 20/03/2006
		TRB->(Fieldput(FieldPos('M'+SubStr(QRY2->D1_DTDIGIT,5,2)),nTotMes))		
		
		If Upper(_cDipUsr) $ cSHWCUST// JBS 20/03/2006
			nCusto := TRB->(FieldGet(FieldPos('C'+SubStr(QRY2->D1_DTDIGIT,5,2)))) - (QRY2->D2_CUSDIP*QRY2->D1_QUANT) // JBS 20/03/2006
			TRB->CUST_TOTAL := TRB->CUST_TOTAL - (QRY2->D2_CUSDIP*QRY2->D1_QUANT) // JBS 20/03/2006
			TRB->(Fieldput(FieldPos('C'+SubStr(QRY2->D1_DTDIGIT,5,2)),nCusto)) // JBS 20/03/2006
			
		EndIf // JBS 20/03/2006
	Else
		RecLock("TRB",.F.)
		TRB->TOTAL := TRB->TOTAL - QRY2->D1_TOTAL
		nTotMes := TRB->(FieldGet(FieldPos('M'+SubStr(QRY2->D1_DTDIGIT,5,2)))) - QRY2->D1_TOTAL // JBS 20/03/2006
		TRB->(Fieldput(FieldPos('M'+SubStr(QRY2->D1_DTDIGIT,5,2)),nTotMes)) // JBS 20/03/2006
		
		If Upper(_cDipUsr) $ cSHWCUST// JBS 20/03/2006
			nCusto := TRB->(FieldGet(FieldPos('C'+SubStr(QRY2->D1_DTDIGIT,5,2)))) - (QRY2->D2_CUSDIP*QRY2->D1_QUANT) // JBS 20/03/2006
			TRB->CUST_TOTAL := TRB->CUST_TOTAL - (QRY2->D2_CUSDIP*QRY2->D1_QUANT) // JBS 20/03/2006
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
			TRB->VENDEDOR:= QRY3->VENDEDOR // JBS 29/07/2010
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
		    TRB->VENDKC    := QRY3->A1_VENDKC
			SA3->(dbSeek(xFilial('SA3')+QRY3->A1_VENDKC))
			TRB->N_VENDKC  := SA3->A3_NOME		
			TRB->TECNICO   := QRY3->A1_TECNICO
			SA3->(dbSeek(xFilial('SA3')+QRY3->A1_TECNICO))
			TRB->NOME_TEC  := SA3->A3_NOME                                                            
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
			TRB->TECN_SP:= QRY3->A1_XTEC_SP
			SA3->(dbSeek(xFilial('SA3')+QRY3->A1_XTEC_SP)) 
			TRB->NTECN_SP   := SA3->A3_NOME
			TRB->TECN_MA:= QRY3->A1_XTEC_MA		
			SA3->(dbSeek(xFilial('SA3')+QRY3->A1_XTEC_MA))
			TRB->NTECN_MA   := SA3->A3_NOME
	   		TRB->TECN_HQ:= QRY3->A1_XTEC_HQ
			SA3->(dbSeek(xFilial('SA3')+QRY3->A1_XTEC_HQ))
			TRB->NTECN_HQ   := SA3->A3_NOME
			TRB->EMAILD		:= QRY3->A1_EMAILD
   				
            // Eriberto 07/10/09
			TRB->CNPJ := QRY1->A1_CGC
			TRB->IE   := QRY1->A1_INSCR
				//Giovani Zago 18/08/11
		TRB->ENDERECO   := QRY1->A1_END
		
		TRB->CANAL_VEND := IF(!Empty(QRY3->A1_XCANALV),posicione("SX5",1,xFilial("SX5")+"X0"+ALLTRIM(QRY3->A1_XCANALV),"X5_DESCRI"),"")// Reginaldo Borges 28/08/2012
   		TRB->CNAE := QRY3->A1_CNAE+' - '+IF(!Empty(QRY3->A1_CNAE),posicione("CC3",1,xFilial("CC3")+ALLTRIM(QRY3->A1_CNAE),"CC3_DESC"),"") 		
   		TRB->CNES := QRY3->A1_CNES +' - '+ QRY3->A1_DESCNES
		//************************
			MsUnLock()	
			
		EndIf
		
		QRY3->( DbSkip() )                   
		
	EndDo
EndIf

DbSelectArea("TRB")
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

	MakeDir(cDestino) // CRIA DIRET”RIO CASO N√O EXISTA
	CpyS2T(cArqExcell+".dbf",cDestino,.T.) // COPIA ARQUIVO PARA MAQUINA DO USU¡RIO   

	// Buscando e apagando arquivos tempor·rios - MCVN 27/08/10
	aTmp := Directory( cDestino+"*.tmp" )
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
Local xi
Local wi
Local I
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
ElseIf MV_PAR04 == 4
	cRel_Dep := "LicitaÁıes"
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
	*       Janeiro       Fevereiro           Marco           Abril            Maio           Junho           Julho          Agosto        Setembro         Outubro        Novembro        Dezembro           Total         MEDIA
	*Cliente: 999999-99 123456789012345678901234567890123456789012345678901234567890
	*999.999.999,99  999.999.999,99  999.999.999,99  999.999.999,99  999.999.999,99  999.999.999,99  999.999.999,99  999.999.999,99  999.999.999,99  999.999.999,99  999.999.999,99  999.999.999,99  999.999.999,99 99.999.999,99
	
	@ li,001 PSay 'Cliente..: ' + TRB->CLIENTE +'-'+TRB->LOJA +' - '+ TRB->NOME +'  Estado..: '+ TRB->UF  + '  Vendedor.: ' + TRB->VENDEDOR + '-' + TRB->NOME_VEN // JBS 29/07/2010
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
		@ li,000 PSay '*** '+ALLTRIM(STR(_nReg - MV_PAR11,5,0))+' clientes ***'
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
	@ li,000 PSay Replic("*",Limite)
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
	@ li,000 PSay Replic("*",Limite)
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
Local cEmailCc  := "patricia@dipromed.com.br"
Local cEmailBcc := ""
Local lResult   := .F.
Local cError    := ""
Local cMsg      := ""
Local nTot_Prod := 0
LOCAL lSmtpAuth := GetNewPar("MV_RELAUTH",.F.)
LOCAL lAutOk	:= .F.
Local xi

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

Return(.T.)

/////////////////////////////////////////////////////////////////////////////
//
Static Function AjustaSX1(cPerg)
Local j
Local i
_sAlias := Alias()
dbSelectArea("SX1")
dbSetOrder(1)
aRegs:={}

//------------ Grupo/Ordem/Pergunta/PERGING/PERGESP/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05/F3

AADD(aRegs,{cPerg,"01","Mes e Ano Final    ?","","","mv_ch1","C",6,0,0,"G","","MV_PAR01","","","","","","","","","","","","","",""})
AADD(aRegs,{cPerg,"02","Vendedor           ?","","","mv_ch2","C",6,0,0,"G","","MV_PAR02","","","","","","","","","","","","","","","","","","","","","","","","",'SA3'})
AADD(aRegs,{cPerg,"03","Cria arquivo       ?","","","mv_ch3","N",1,0,1,"C","","MV_PAR03","Sim","","","","","Nao","","","","","","","",""})
AADD(aRegs,{cPerg,"04","Informe o setor    ?","","","mv_ch4","N",1,0,0,"C","","MV_PAR04","1-Apoio","","","","","2-Call Center","","","","","3-Ambos","","","4-Licitacoes"})
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

#include 'protheus.ch'
#Include 'Report.ch'
#include 'topconn.ch'
#include "tbiconn.ch"



/*/{Protheus.doc} DIPR097
(long_description)
@author    fernando.bombardi
@since     28/08/2018
@version   1.0
/*/
User Function DIPR097()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Declaracao de variaveis                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Private oReport  := Nil
Private oSecCab	 := Nil
Private cPerg 	 := PadR ("DIPR097", Len (SX1->X1_GRUPO))

Private	_nDias 	:= 0
Private	_nMedia := 0

Private cPesq	:= ";"
Private cResp	:= " "
Private cChar1	:= " "
Private cMVPar05:= " "
Private nLoop	:= " "

CriaSX1( cPerg )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Definicoes/preparacao para impressao      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Pergunte(cPerg,.T.)

oReport := ReportDef()

If Valtype( oReport ) == 'O'
	If ! Empty( oReport:uParam )
		Pergunte( oReport:uParam, .F. )
	EndIf	
	
	oReport:PrintDialog()      
Endif
	
oReport := Nil

Return Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ReportDef ºAutor  ³ Vinícius Moreira   º Data ³ 21/10/2013  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Definição da estrutura do relatório.                       º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ReportDef()
	Local oReport := Nil
	Local oSection1:= Nil
	
	/*Sintaxe: TReport():New(cNome,cTitulo,cPerguntas,bBlocoCodigo,cDescricao)*/
	oReport := TReport():New("DIPR097","Produtos x Periodos",cPerg,{|oReport| ReportPrint(oReport)},"Impressão de relatorio de Produtos x Periodos.")
	oReport:SetLandScape(.T.)
	oReport:SetTotalInLine(.F.)
	oreport:nfontbody := 6
	oreport:cfontbody := "Calibri"
	 
	oSection1:= TRSection():New(oReport, "Produtos", {"SB1"}, , .F., .T.)
	oSection1:SetTotalInLine(.F.)
	IF MV_PAR06 == 1
		TRCell():New(oSection1,"B1_COD"   	,"QRY",RetTitle('B1_COD')    ,"@!",TamSX3("B1_COD")[1]  )
		TRCell():New(oSection1,"B1_DESC"  	,"QRY",RetTitle('B1_DESC')   ,"@!",TamSX3("B1_DESC")[1] + 10  )
		TRCell():New(oSection1,"D2_QUANT"   ,"QRY",RetTitle('D2_QUANT')  ,"@E 999,999,999.99",TamSX3("D2_QUANT")[1] +3 )
		TRCell():New(oSection1,"D2_EMISSAO"	,"QRY",RetTitle('D2_EMISSAO'),"@!",TamSX3("D2_EMISSAO")[1] +3 )	
		TRCell():New(oSection1,"D2_PRCVEN"  ,"QRY",RetTitle('D2_PRCVEN') ,"@E 999,999,999.99",TamSX3("D2_PRCVEN")[1] +3 )
		TRCell():New(oSection1,"D2_TOTAL"  	,"QRY",RetTitle('D2_TOTAL')  ,"@E 999,999,999.99",TamSX3("D2_TOTAL")[1] +3 )		
		TRCell():New(oSection1,"E4_DESCRI"	,"QRY","Cond. Pagamento" ,"@!",TamSX3("E4_DESCRI")[1] +3 )
		TRCell():New(oSection1,"A2_NREDUZ"	,"QRY","Fornecedor" ,"@!",TamSX3("A2_NREDUZ")[1] +3 )
		TRCell():New(oSection1,"U7_NOME"	,"QRY","Operador"   ,"@!",TamSX3("U7_NOME")[1] +3 )

		TRFunction():New(oSection1:Cell("D2_QUANT"),"TOTAL QUANTIDADE","SUM",/*oBreak*/,,"@E 999,999,999.99",,.T.,.T.)
		TRFunction():New(oSection1:Cell("D2_TOTAL"),"TOTAL FATURADO"  ,"SUM",/*oBreak*/,,"@E 999,999,999.99",,.T.,.T.)

	ELSE
		TRCell():New(oSection1,"B1_COD"   	,"QRY",RetTitle('B1_COD')    ,"@!",TamSX3("B1_COD")[1]  )
		TRCell():New(oSection1,"B1_DESC"  	,"QRY",RetTitle('B1_DESC')   ,"@!",TamSX3("B1_DESC")[1] + 10 )
		TRCell():New(oSection1,"D2_QUANT"   ,"QRY",RetTitle('D2_QUANT')  ,"@E 999,999,999.99",TamSX3("D2_QUANT")[1] +3 )		
		TRCell():New(oSection1,"D2_EMISSAO"	,"QRY",RetTitle('D2_EMISSAO'),"@!",TamSX3("D2_EMISSAO")[1] +3 )	
		TRCell():New(oSection1,"A2_NREDUZ"	,"QRY","Fornecedor" ,"@!",TamSX3("A2_NREDUZ")[1] +3 )
		TRCell():New(oSection1,"MEDIA"	    ,"QRY","Media Diaria" ,"@E 999,999,999.99",TamSX3("D2_TOTAL")[1] +3 )		

		TRFunction():New(oSection1:Cell("D2_QUANT"),"TOTAL QUANTIDADE","SUM",/*oBreak*/,,"@E 999,999,999.99",,.T.,.T.)

	ENDIF
		
Return(oReport)

/*/{Protheus.doc} ReportPrint
Realiza a impressao do relatorio.
@author    fernando.bombardi
@since     28/08/2018
@version   1.0
/*/ 
Static Function ReportPrint(oReport)
	Local oSection1 := oReport:Section(1)
	Local cQuery    := ""		
	Local cNcm      := ""   
	Local lPrim 	:= .T.	      
	
	IF MV_PAR06 == 1 //ANALITICO
	
		cQuery := "	SELECT "
		cQuery += "		B1_COD "
		cQuery += "		,B1_DESC "
		cQuery += "		,D2_QUANT "
		cQuery += "		,D2_PRCVEN "
		cQuery += "		,D2_TOTAL "
		cQuery += "		,E4_DESCRI "
		cQuery += "		,D2_EMISSAO "
		cQuery += "		,A2_NREDUZ "
		cQuery += "		,U7_NOME "		
		cQuery += "	FROM "
		cQuery += "		"+RETSQLNAME("SD2")+" SD2 INNER JOIN "+RETSQLNAME("SB1")+" SB1 " 
		cQuery += "		ON D2_FILIAL = B1_FILIAL AND D2_COD = B1_COD "
		cQuery += "		INNER JOIN "+RETSQLNAME("SF2")+" SF2 "
		cQuery += "		ON D2_FILIAL = F2_FILIAL AND D2_DOC = F2_DOC AND D2_SERIE = F2_SERIE "
		cQuery += "		INNER JOIN "+RETSQLNAME("SE4")+" SE4 "
		cQuery += "		ON F2_COND = E4_CODIGO "
		cQuery += "		INNER JOIN "+RETSQLNAME("SC5")+" SC5 "
		cQuery += "		ON C5_FILIAL = D2_FILIAL AND C5_NUM = D2_PEDIDO "
		cQuery += "		INNER JOIN "+RETSQLNAME("SU7")+" SU7 "
		cQuery += "		ON U7_FILIAL = '' AND U7_COD = C5_OPERADO "
		cQuery += "		LEFT JOIN "+RETSQLNAME("SA2")+" SA2 "
		cQuery += "		ON A2_FILIAL = '' AND A2_COD = B1_PROC AND A2_LOJA = B1_LOJPROC "
		cQuery += "	WHERE "
		IF cEmpAnt == "04"
			cQuery += "	D2_FILIAL = '"+XFILIAL("SD2")+"' AND "
		ENDIF
		cQuery += "		D2_TIPO = 'N' "
		cQuery += "		AND D2_EMISSAO 	BETWEEN '"+DTOS(MV_PAR01)+"' 	AND '"+DTOS(MV_PAR02)+"' "
		
		If !Empty(MV_PAR03) .AND. !Empty(MV_PAR04)
			cQuery += " AND D2_COD BETWEEN '" + MV_PAR03 + "' AND '" + MV_PAR04 + "'"
		ELSEIF !EMPTY(MV_PAR05)
		cChar1	:= " "
		cMVPar05:= Alltrim(MV_PAR05)
		
			For i := 1 to len(ALLTRIM(MV_PAR05))
				
				nLoop	:= At(cPesq,ALLTRIM(cMVPar05))
				cResp	:= Substr(Alltrim(cMVPar05),nLoop-7,nLoop-1)
				cMVPar05 := Substr(Alltrim(cMVPar05),nLoop+1,len(mv_par05)-nLoop)
				cChar1 	+= "'" + cResp + "',"
				
				If cMVPar05 = ""
					i := len(ALLTRIM(MV_PAR05))
				EndIf
			Next
		cChar1	:= AllTrim(cChar1)
		cChar1	:= Substring(cChar1,0,len(cChar1)-1)	
		cQuery	+= "		AND D2_COD  IN ( "+cChar1+" ) 					"
		ENDIF 
		
		cQuery += "		AND SD2.D_E_L_E_T_ = '' "
		cQuery += "		AND SB1.D_E_L_E_T_ = '' "
		cQuery += "		AND SF2.D_E_L_E_T_ = '' "
		cQuery += "		AND SE4.D_E_L_E_T_ = '' "
		cQuery += "		AND SA2.D_E_L_E_T_ = '' "
		cQuery += "		AND SC5.D_E_L_E_T_ = '' "
		cQuery += "		AND SU7.D_E_L_E_T_ = '' "	
		cQuery += "	ORDER BY B1_COD, D2_EMISSAO, D2_DOC, D2_SERIE, D2_ITEM "
	
	ELSE //SINTETICO
	
		cQuery := "	SELECT "
		cQuery += "		B1_COD "
		cQuery += "		,B1_DESC "
		cQuery += "		,SUM(D2_QUANT) AS D2_QUANT "
		cQuery += "		,D2_EMISSAO "
		cQuery += "		,A2_NREDUZ "
		cQuery += "	FROM "
		cQuery += "		"+RETSQLNAME("SD2")+" SD2 INNER JOIN "+RETSQLNAME("SB1")+" SB1 " 
		cQuery += "		ON D2_FILIAL = B1_FILIAL AND D2_COD = B1_COD "
		cQuery += "		INNER JOIN "+RETSQLNAME("SF2")+" SF2 "
		cQuery += "		ON D2_FILIAL = F2_FILIAL AND D2_DOC = F2_DOC AND D2_SERIE = F2_SERIE "
		cQuery += "		INNER JOIN "+RETSQLNAME("SE4")+" SE4 "
		cQuery += "		ON F2_COND = E4_CODIGO "
		cQuery += "		LEFT JOIN "+RETSQLNAME("SA2")+" SA2 "
		cQuery += "		ON A2_FILIAL = '' AND A2_COD = B1_PROC AND A2_LOJA = B1_LOJPROC "
		cQuery += "	WHERE "
		IF cEmpAnt == "04"
			cQuery += "	D2_FILIAL = '"+XFILIAL("SD2")+"' AND "
		ENDIF
		cQuery += "		D2_TIPO = 'N' "		
		cQuery += "		AND D2_EMISSAO BETWEEN '"+DTOS(MV_PAR01)+"' AND '"+DTOS(MV_PAR02)+"' "
		
		If !Empty(MV_PAR03) .AND. !Empty(MV_PAR04)
			cQuery += " AND D2_COD BETWEEN '" + MV_PAR03 + "' AND '" + MV_PAR04 + "'"
		ELSEIF !EMPTY(MV_PAR05)
		cChar1	:= " "
		cMVPar05:= Alltrim(MV_PAR05)
		
			For i := 1 to len(ALLTRIM(MV_PAR05))
				
				nLoop	:= At(cPesq,ALLTRIM(cMVPar05))
				cResp	:= Substr(Alltrim(cMVPar05),nLoop-7,nLoop-1)
				cMVPar05 := Substr(Alltrim(cMVPar05),nLoop+1,len(mv_par05)-nLoop)
				cChar1 	+= "'" + cResp + "',"
				
				If cMVPar05 = ""
					i := len(ALLTRIM(MV_PAR05))
				EndIf
			Next
		cChar1	:= AllTrim(cChar1)
		cChar1	:= Substring(cChar1,0,len(cChar1)-1)	
		cQuery	+= "		AND D2_COD  IN ( "+cChar1+" ) 					"
		ENDIF 

		cQuery += "		AND SD2.D_E_L_E_T_ = '' "
		cQuery += "		AND SB1.D_E_L_E_T_ = '' "
		cQuery += "		AND SF2.D_E_L_E_T_ = '' "
		cQuery += "		AND SE4.D_E_L_E_T_ = '' "
		cQuery += "		AND SA2.D_E_L_E_T_ = '' "	
		cQuery += "	GROUP BY "
		cQuery += "		B1_COD "
		cQuery += "		,B1_DESC "
		cQuery += "		,D2_EMISSAO "
		cQuery += "		,A2_NREDUZ "
		cQuery += "	ORDER BY B1_COD,D2_EMISSAO "
	
	ENDIF
	
	//Se o alias estiver aberto, irei fechar, isso ajuda a evitar erros
	IF Select("TRB") > 0
		DbSelectArea("TRB")
		DbCloseArea()
	ENDIF

	//crio o novo alias
	TCQUERY cQuery NEW ALIAS "TRB"	

	dbSelectArea("TRB")
	
	oReport:SetMeter(TRB->(LastRec()))	
 
 	//inicializo a primeira seção
	oSection1:Init()
 
 
	_cProd 	:= ""
 
	//Irei percorrer todos os meus registros
	While TRB->(!Eof())
		
		If oReport:Cancel()
			Exit
		EndIf
 
		oReport:IncMeter()

		IF ALLTRIM(TRB->B1_COD) <> ALLTRIM(_cProd) .AND. !EMPTY(_cProd) 
			//Imprimo Total do Produto
			oSection1:SetTotalText("Total Geral ")		
			//finalizo a primeira seção
			oSection1:Finish()
		 	//inicializo a primeira seção
			oSection1:Init()			
			_cProd 	:= TRB->B1_COD
			_nDias 	:= 0
			_nMedia := 0
		ELSE
			_cProd 	:= TRB->B1_COD
		ENDIF
		
		//imprimo a primeira seção				
		IF MV_PAR06 == 1 //ANALITICO
			oSection1:Cell("B1_COD"):SetValue(TRB->B1_COD)
			oSection1:Cell("B1_DESC"):SetValue(TRB->B1_DESC)				
			oSection1:Cell("D2_QUANT"):SetValue(TRB->D2_QUANT)
			oSection1:Cell("D2_EMISSAO"):SetValue(dtoc(stod(TRB->D2_EMISSAO)))
			oSection1:Cell("D2_PRCVEN"):SetValue(TRB->D2_PRCVEN)
			oSection1:Cell("D2_TOTAL"):SetValue(TRB->D2_TOTAL)
			oSection1:Cell("E4_DESCRI"):SetValue(TRB->E4_DESCRI)			
			oSection1:Cell("A2_NREDUZ"):SetValue(TRB->A2_NREDUZ)
			oSection1:Cell("U7_NOME"):SetValue(TRB->U7_NOME)
		ELSE
			oSection1:Cell("B1_COD"):SetValue(TRB->B1_COD)
			oSection1:Cell("B1_DESC"):SetValue(TRB->B1_DESC)				
			oSection1:Cell("D2_QUANT"):SetValue(TRB->D2_QUANT)
			oSection1:Cell("D2_EMISSAO"):SetValue(dtoc(stod(TRB->D2_EMISSAO)))
			oSection1:Cell("A2_NREDUZ"):SetValue(TRB->A2_NREDUZ)
			oSection1:Cell("MEDIA"):SetValue(IIF(_nDias == 0,Media(stod(TRB->D2_EMISSAO),TRB->B1_COD),_nMedia))
		ENDIF

		oSection1:Printline()
	
		TRB->(dbSkip())
 
	Enddo

	//finalizo a primeira seção
	oSection1:Finish()

    //Aqui, farei uma quebra  por seção
	oSection1:SetPageBreak(.T.)

Return

/*/{Protheus.doc} CriaSX1
Cria perguntas para parametros do relatorio.
@author    fernando.bombardi
@since     28/08/2018
@version   1.0
/*/
Static Function CriaSX1( cPerg )

Local i,j
Local aAreaAtu	:= GetArea()
Local aAreaSX1	:= SX1->( GetArea() )
Local aTamSX3	:= {}
Local aRegs     := {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Grava as perguntas no arquivo SX1                                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aTamSX3	:= TAMSX3( "D2_EMISSAO" )
AADD(aRegs,{cPerg,"01","Periodo de?"    ,"" ,"" ,"mv_ch1", aTamSX3[3],aTamSx3[1],	aTamSX3[2],         0,	"G" ,"","MV_PAR01"  ,                "",               "",           "",""         ,"",              "",                "",              "","","",         "",          "",            "","","",         "",          "",            "","","",         "",          "",            "","",   "","S",    "",          "","","" })
AADD(aRegs,{cPerg,"02","Periodo ate?"   ,"" ,"" ,"mv_ch2", aTamSX3[3],aTamSx3[1],	aTamSX3[2],         0,	"G" ,"","MV_PAR02" ,                "",               "",            "",""         ,"",              "",                "",              "","","",         "",          "",            "","","",         "",          "",            "","","",         "",          "",            "","",   "","S",    "",          "","","" })

aTamSX3	:= TAMSX3( "D2_COD" )
AADD(aRegs,{cPerg,"03","Do Produto?"    ,"" ,"","mv_ch3", aTamSX3[3],aTamSx3[1],	aTamSX3[2],         0,	"G" ,"","MV_PAR03","","","","","","","","","","","","","","","","","","","","","","","","","SB1"})
AADD(aRegs,{cPerg,"04","Ate o Produto?" ,"" ,"","mv_ch4", aTamSX3[3],aTamSx3[1],	aTamSX3[2],         0,	"G" ,"","MV_PAR04","","","","","","","","","","","","","","","","","","","","","","","","","SB1"})

aTamSX3	:= TAMSX3( "D2_COD" )
AADD(aRegs,{cPerg,"05","Produtos Ex: 000000;011111;		","","","mv_ch5",	"C",62,0,0,						"R","","MV_PAR05","","","","","","","","","","","","","","","","","","","","","","","","","SB1"})

AADD(aRegs,{cPerg,"06","Tipo relatorio?					","" ,"","mv_ch6",	"N",1,0,1,						"C","","MV_PAR06","Analitico","Analitico","Analitico","","","Sintetico","Sintetico","Sintetico","","",         "",          "",            "","","",         "",          "",            "","","",         "",          "",            "","",   "","S",    "",          "","","" })

DbSelectArea("SX1")
SX1->(DbSetOrder(1))

For I := 1 To Len(aRegs)
	If 	!dbSeek(cPerg+aRegs[i,2])
		RecLock("SX1",.T.)
		For j:=1 to FCount()
			IF j <= Len(aRegs[i])
				FieldPut(j,aRegs[i,j])
			EndIf
		Next
		MsUnLock()
	Else
		RecLock("SX1",.F.)
		For j:= 7 to 10
			FieldPut(j,aRegs[i,j])
		Next
		MsUnLock()
	EndIf
Next

RestArea( aAreaSX1 )
RestArea( aAreaAtu )

Return()

/*/{Protheus.doc} CriaSX1
realiza o calculo da media.
@author    fernando.bombardi
@since     28/08/2018
@version   1.0
/*/
Static Function Media(_dData,_cProd)
Local _cMesAtu  := STRZERO(VAL(SUBSTR(DTOS(_dData),5,2)), 2)
Local _cMesUni  := ""
Local _cMesFim  := ""
Local _cDataIni := ""
Local _cDataFim := ""
Local _nDias    := 0

DO CASE
	CASE _cMesAtu == "01"
		_cDataIni := Alltrim(str(YEAR(_dData)-1)+"10"+"01")
		_cDataFim := Alltrim(str(YEAR(_dData)-1)+"12"+"31")
	CASE _cMesAtu == "02"
		_cDataIni := Alltrim(str(YEAR(_dData)-1)+"11"+"01")
		_cDataFim := Alltrim(str(YEAR(_dData))+"01"+"31")
	CASE _cMesAtu == "03"
		_cDataIni := Alltrim(str(YEAR(_dData)-1)+"12"+"01")
		_cDataFim := Alltrim(str(YEAR(_dData))+"02"+"31")
	OTHERWISE
		_cMesUni  := STRZERO(VAL(SUBSTR(DTOS(_dData),5,2)) - 3, 2)
		_cMesFim  := STRZERO(VAL(SUBSTR(DTOS(_dData),5,2)) - 1, 2)
		_cDataIni := Alltrim(str(YEAR(_dData))+_cMesUni+"01")
		_cDataFim := Alltrim(str(YEAR(_dData))+_cMesFim+"31")
END CASE

cQuery := "	SELECT "
cQuery += "		ROUND(SUM(D2_QUANT),2) AS QTDTOTAL " 
cQuery += "	FROM "+RETSQLNAME("SD2")
cQuery += "	WHERE 
IF cEmpAnt == "04"
	cQuery += "	D2_FILIAL = '"+XFILIAL("SD2")+"' AND "
ENDIF
cQuery += "		D2_TIPO = 'N' "
cQuery += "		AND D2_EMISSAO BETWEEN '"+_cDataIni+"' AND '"+_cDataFim+"' "
cQuery += "		AND D2_COD = '"+_cProd+"' "
cQuery += "		AND D_E_L_E_T_ = '' "
TCQUERY cQuery NEW ALIAS "QSD2"
dbSelectArea("QSD2")
IF QSD2->(!EOF())
	_nDias  := DiasUteis(STOD(_cDataIni), STOD(_cDataFim))
	_nMedia := QSD2->QTDTOTAL / _nDias
ENDIF
QSD2->(dbCloseArea())

Return(_nMedia)

/*/{Protheus.doc} CriaSX1
Realiza o calculo dos dias uteis.
@author    fernando.bombardi
@since     28/08/2018
@version   1.0
/*/
Static Function DiasUteis(dDtIni, dDtFin)
	Local aArea    := GetArea()
	//Local _nDias    := 0
	Local dDtAtu   := sToD("")
	Default dDtIni := dDataBase
	Default dDtFin := dDataBase
	
	//Enquanto a data atual for menor ou igual a data final
	dDtAtu := dDtIni
	While dDtAtu <= dDtFin
		//Se a data atual for uma data Válida
		If dDtAtu == DataValida(dDtAtu) 
			_nDias++
		EndIf
		
		dDtAtu := DaySum(dDtAtu, 1)
	EndDo
	
	RestArea(aArea)
Return _nDias

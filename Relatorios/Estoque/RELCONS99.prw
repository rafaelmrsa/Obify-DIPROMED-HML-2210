#include 'protheus.ch'
#include 'parmtype.ch'
#include "report.ch"
#include "topconn.ch"

/*/
{Protheus.doc} RELCONS99
Lista consumo dos últimos 4 meses, com estoque.
@type Function
@author Felipe Almeida
@since 20/05/2020
@version 1.0
/*/

User Function RELCONS99()
    
    //Local cPerg := "RELCONS99"

    If MsgYesNo("Deseja gerar o relatório de consumo?","Atenção")
        Processa({ || GeraRel()},'Aguarde, processando...')
    Else
        Return .F.
    EndIf

Return

Static Function GeraRel()

	Private oReport
	Private oSection1
	Private oSection2
    Private oSection3
	Private oBreak

    Private dDataAtual  := Date()
    Private cMes1       := MesExtenso(MonthSub(dDataAtual,3))
    Private cMes2       := MesExtenso(MonthSub(dDataAtual,2))
    Private cMes3       := MesExtenso(MonthSub(dDataAtual,1))
    Private cMes4       := MesExtenso(dDataAtual)

	oReport := TReport():New("RELCONS99", "Relatório de Consumo",, {|oReport| ReportPrint(oReport)}, "Gera relatório de consumo com estoque")
	oReport:SetLandscape()
	oReport:SetTotalInLine(.F.)
	oReport:HideParamPage(.T.)

    oSection1 := TRSection():New(oReport, "PA", {"QRY1"}, /*aOrder*/, .F., .T., /*uTotalText*/, /*lTotalInLine*/, .F., .F., .F.,, 2)
	oSection2 := TRSection():New(oReport, "PI", {"QRY2"}, /*aOrder*/, .F., .T., /*uTotalText*/, /*lTotalInLine*/, .F., .F., .F.,, 2)
    oSection3 := TRSection():New(oReport, "MP", {"QRY3"}, /*aOrder*/, .F., .T., /*uTotalText*/, /*lTotalInLine*/, .F., .F., .F.,, 2)
    oSection4 := TRSection():New(oReport, "MC", {"QRY4"}, /*aOrder*/, .F., .T., /*uTotalText*/, /*lTotalInLine*/, .F., .F., .F.,, 2)

	TRCell():New(oSection1, "CODIGO"		    , "QRY1", "Código"		    ,/*Picture*/, 20,,,,,,,, .F.)
	TRCell():New(oSection1, "DESCRICAO"		    , "QRY1", "Descrição"		,/*Picture*/, 20,,,,,,,, .F.)
	TRCell():New(oSection1, "ESTOQUE_VALOR"		, "QRY1", "Estoque ($)"		,/*Picture*/, 20,,,,,,,, .F.)
	TRCell():New(oSection1, "ESTOQUE_ATUAL"	    , "QRY1", "Estoque Atual"	,/*Picture*/, 20,,,,,,,, .F.)
	TRCell():New(oSection1, "RESERVADO"		    , "QRY1", "Reservado"		,/*Picture*/, 20,,,,,,,, .F.)
	TRCell():New(oSection1, "SALDO"		        , "QRY1", "Saldo"			,/*Picture*/, 20,,,,,,,, .F.)
	TRCell():New(oSection1, "PODER_TERCEIRO"	, "QRY1", "Poder Terceiro" 	,/*Picture*/, 20,,,,,,,, .F.)
    TRCell():New(oSection1, "MES1"	            , "QRY1", cMes1             ,/*Picture*/, 20,,,,,,,, .F.)
    TRCell():New(oSection1, "MES2"	            , "QRY1", cMes2          	,/*Picture*/, 20,,,,,,,, .F.)
    TRCell():New(oSection1, "MES3"	            , "QRY1", cMes3          	,/*Picture*/, 20,,,,,,,, .F.)
    TRCell():New(oSection1, "MES4"          	, "QRY1", cMes4          	,/*Picture*/, 20,,,,,,,, .F.)
    TRCell():New(oSection1, "MEDIA"	            , "QRY1", "Média"         	,/*Picture*/, 20,,,,,,,, .F.)

    TRCell():New(oSection2, "CODIGO"		    , "QRY2", "Código"		    ,/*Picture*/, 20,,,,,,,, .F.)
	TRCell():New(oSection2, "DESCRICAO"		    , "QRY2", "Descrição"		,/*Picture*/, 20,,,,,,,, .F.)
	TRCell():New(oSection2, "ESTOQUE_VALOR"		, "QRY2", "Estoque ($)"		,/*Picture*/, 20,,,,,,,, .F.)
	TRCell():New(oSection2, "ESTOQUE"	        , "QRY2", "Estoque"	        ,/*Picture*/, 20,,,,,,,, .F.)
	TRCell():New(oSection2, "A_ENDERECAR"		, "QRY2", "À Endereçar"		,/*Picture*/, 20,,,,,,,, .F.)
	TRCell():New(oSection2, "PEDIDO_COMPRA"		, "QRY2", "Pedido Compra"	,/*Picture*/, 20,,,,,,,, .F.)
    TRCell():New(oSection2, "MES1"	            , "QRY2", cMes1             ,/*Picture*/, 20,,,,,,,, .F.)
    TRCell():New(oSection2, "MES2"	            , "QRY2", cMes2          	,/*Picture*/, 20,,,,,,,, .F.)
    TRCell():New(oSection2, "MES3"	            , "QRY2", cMes3          	,/*Picture*/, 20,,,,,,,, .F.)
    TRCell():New(oSection2, "MES4"          	, "QRY2", cMes4          	,/*Picture*/, 20,,,,,,,, .F.)
    TRCell():New(oSection2, "MEDIA"	            , "QRY2", "Média"         	,/*Picture*/, 20,,,,,,,, .F.)

    TRCell():New(oSection3, "CODIGO"		    , "QRY3", "Código"		    ,/*Picture*/, 20,,,,,,,, .F.)
	TRCell():New(oSection3, "DESCRICAO"		    , "QRY3", "Descrição"		,/*Picture*/, 20,,,,,,,, .F.)
	TRCell():New(oSection3, "ESTOQUE_VALOR"		, "QRY3", "Estoque ($)"		,/*Picture*/, 20,,,,,,,, .F.)
	TRCell():New(oSection3, "ESTOQUE"	        , "QRY3", "Estoque"	        ,/*Picture*/, 20,,,,,,,, .F.)
	TRCell():New(oSection3, "A_ENDERECAR"		, "QRY3", "À Endereçar"		,/*Picture*/, 20,,,,,,,, .F.)
	TRCell():New(oSection3, "PEDIDO_COMPRA"		, "QRY3", "Pedido Compra"	,/*Picture*/, 20,,,,,,,, .F.)
    TRCell():New(oSection3, "MES1"	            , "QRY3", cMes1             ,/*Picture*/, 20,,,,,,,, .F.)
    TRCell():New(oSection3, "MES2"	            , "QRY3", cMes2          	,/*Picture*/, 20,,,,,,,, .F.)
    TRCell():New(oSection3, "MES3"	            , "QRY3", cMes3          	,/*Picture*/, 20,,,,,,,, .F.)
    TRCell():New(oSection3, "MES4"          	, "QRY3", cMes4          	,/*Picture*/, 20,,,,,,,, .F.)
    TRCell():New(oSection3, "MEDIA"	            , "QRY3", "Média"         	,/*Picture*/, 20,,,,,,,, .F.)


    TRCell():New(oSection4, "CODIGO"		    , "QRY4", "Código"		    ,/*Picture*/, 20,,,,,,,, .F.)
	TRCell():New(oSection4, "DESCRICAO"		    , "QRY4", "Descrição"		,/*Picture*/, 20,,,,,,,, .F.)
	TRCell():New(oSection4, "ESTOQUE_VALOR"		, "QRY4", "Estoque ($)"		,/*Picture*/, 20,,,,,,,, .F.)
	TRCell():New(oSection4, "ESTOQUE"	        , "QRY4", "Estoque"	        ,/*Picture*/, 20,,,,,,,, .F.)
	TRCell():New(oSection4, "A_ENDERECAR"		, "QRY4", "À Endereçar"		,/*Picture*/, 20,,,,,,,, .F.)
	TRCell():New(oSection4, "PEDIDO_COMPRA"		, "QRY4", "Pedido Compra"	,/*Picture*/, 20,,,,,,,, .F.)
    TRCell():New(oSection4, "MES1"	            , "QRY4", cMes1             ,/*Picture*/, 20,,,,,,,, .F.)
    TRCell():New(oSection4, "MES2"	            , "QRY4", cMes2          	,/*Picture*/, 20,,,,,,,, .F.)
    TRCell():New(oSection4, "MES3"	            , "QRY4", cMes3          	,/*Picture*/, 20,,,,,,,, .F.)
    TRCell():New(oSection4, "MES4"          	, "QRY4", cMes4          	,/*Picture*/, 20,,,,,,,, .F.)
    TRCell():New(oSection4, "MEDIA"	            , "QRY4", "Média"         	,/*Picture*/, 20,,,,,,,, .F.)

	oReport:PrintDialog()

Return

Static Function ReportPrint(oReport)

    Local cQuery := ""

    // Início Section 1 (PA)

    cQuery := " SELECT CODIGO, DESCRICAO, ESTOQUE_VALOR, ESTOQUE_ATUAL,RESERVADO, SALDO, PODER_TERCEIRO, " 
    cQuery += " SUM(MES1) MES1, SUM(MES2) MES2, SUM(MES3) MES3, SUM(MES4) MES4, "
    cQuery += " ROUND((SUM(MES1)+SUM(MES2)+SUM(MES3)+SUM(MES4))/4,2) MEDIA "

    cQuery += " FROM (SELECT D2_COD CODIGO, B1_DESC DESCRICAO, ROUND(ISNULL((SELECT SUM(B2_QATU) " 
    cQuery += " FROM SB2040 
    cQuery += " WHERE B2_FILIAL IN('01','02') "
    cQuery += " AND B2_COD = D2_COD 
    cQuery += " AND B2_LOCAL IN ('01','02') AND D_E_L_E_T_ = ' '),0) * B1_CUSDIP,2) 'ESTOQUE_VALOR', " 
    cQuery += " ISNULL((SELECT SUM(B2_QATU) FROM SB2040 WHERE B2_FILIAL IN('01','02') AND B2_COD = D2_COD " 
    cQuery += " AND B2_LOCAL IN ('01','02') AND D_E_L_E_T_ = ' '),0) ESTOQUE_ATUAL, "
    cQuery += " ISNULL((SELECT SUM(B2_RESERVA) FROM SB2040 WHERE B2_FILIAL IN('01','02') AND B2_COD = D2_COD "
    cQuery += " AND B2_LOCAL IN ('01','02') AND D_E_L_E_T_ = ' '),0) RESERVADO, "
    cQuery += " ISNULL((SELECT SUM(B2_QPEDVEN) FROM SB2040 WHERE B2_FILIAL IN('01','02') AND B2_COD = D2_COD "
    cQuery += " AND B2_LOCAL IN ('01','02') AND D_E_L_E_T_ = ' '),0) SALDO, "
        
    cQuery += " ISNULL((SELECT SUM(B6_SALDO) AS SALDO FROM SB6040 SB6, SF2040 SF2 WHERE  SB6.B6_FILIAL = '01' "
    cQuery += " AND   SB6.B6_FILIAL  = SF2.F2_FILIAL "
    cQuery += " AND   SB6.B6_CLIFOR IN ('019433','110087') "
    cQuery += " AND   SB6.B6_PRODUTO = '8'+RIGHT(RTRIM(LTRIM(SD2040.D2_COD)),5) "
    cQuery += " AND   SF2.F2_TIPO    = 'B' "
    cQuery += " AND   SF2.F2_DOC     = SB6.B6_DOC "
    cQuery += " AND   SF2.F2_SERIE   = SB6.B6_SERIE "
    cQuery += " AND   SF2.F2_CLIENTE = SB6.B6_CLIFOR "
    cQuery += " AND   SF2.F2_LOJA    = SB6.B6_LOJA "
    cQuery += " AND   SF2.F2_EMISSAO = SB6.B6_EMISSAO "
    cQuery += " AND   SB6.B6_ATEND   = '' "
    cQuery += " AND   SB6.B6_UENT    = '' "
    cQuery += " AND   SB6.B6_SALDO   > 0 "
    cQuery += " AND   SF2.D_E_L_E_T_ = '' "
    cQuery += " AND   SB6.D_E_L_E_T_ = ''     ),0) PODER_TERCEIRO, "
                                                            
    cQuery += " (CASE WHEN LEFT(D2_EMISSAO,6) = '" + AnoMes(MonthSub(dDataAtual,3)) + "' THEN Round(SUM(D2_QUANT),2) ELSE 0 END) MES1, "
    cQuery += " (CASE WHEN LEFT(D2_EMISSAO,6) = '" + AnoMes(MonthSub(dDataAtual,2)) + "' THEN Round(SUM(D2_QUANT),2) ELSE 0 END) MES2, "
    cQuery += " (CASE WHEN LEFT(D2_EMISSAO,6) = '" + AnoMes(MonthSub(dDataAtual,1)) + "' THEN Round(SUM(D2_QUANT),2) ELSE 0 END) MES3, "
    cQuery += " (CASE WHEN LEFT(D2_EMISSAO,6) = '" + AnoMes(dDataAtual) + "' THEN Round(SUM(D2_QUANT),2) ELSE 0 END) MES4 "
        
    cQuery += " FROM SD2040 WITH(NOLOCK) "
    cQuery += " INNER JOIN SB1040 WITH(NOLOCK) " 
    cQuery += " ON B1_FILIAL = D2_FILIAL AND B1_COD = D2_COD AND B1_TIPO = 'PA' AND SB1040.D_E_L_E_T_ = '' " 
    cQuery += " INNER JOIN SF4040 WITH(NOLOCK) "
    cQuery += " ON F4_FILIAL = D2_FILIAL AND F4_CODIGO = D2_TES AND F4_ESTOQUE = 'S' AND SF4040.D_E_L_E_T_ = '' "
    cQuery += " WHERE D2_FILIAL IN('01') AND D2_EMISSAO BETWEEN '" + AnoMes(MonthSub(dDataAtual,3)) + "01' " 
    cQuery += " AND '" + AnoMes(dDataAtual) + "30' AND D2_TIPO = 'N' AND "
    cQuery += " D2_CLIENTE <> '019170' AND D2_LOCAL ='01' AND SD2040.D_E_L_E_T_ = '' "
    cQuery += " GROUP BY LEFT(D2_EMISSAO,6), D2_COD, B1_DESC, B1_CUSDIP ) TRB "
    cQuery += " GROUP BY CODIGO, DESCRICAO, ESTOQUE_VALOR, ESTOQUE_ATUAL, RESERVADO, SALDO, PODER_TERCEIRO "

    cQuery += " UNION "

    cQuery += " SELECT B2_COD, B1_DESC, SUM((B2_QATU) * B1_CUSDIP) 'ESTOQUE_VALOR',SUM(B2_QATU-B2_QACLASS) ESTOQUE_ATUAL,SUM(B2_RESERVA), "
    cQuery += " SUM(B2_QPEDVEN),0,0,0,0,0,0 "
    cQuery += " FROM SB2040, SB1040 "
    cQuery += " WHERE B2_FILIAL IN('01','02') AND B2_COD = B1_COD AND B2_LOCAL IN ('01','02') AND SB2040.D_E_L_E_T_ = '' "
    cQuery += " AND SB1040. D_E_L_E_T_ = '' AND B2_FILIAL = B1_FILIAL AND (B2_QATU-B2_RESERVA+B2_QACLASS) > 0 "
    cQuery += " AND B1_TIPO = 'PA' AND B2_COD NOT IN (SELECT CODIGO FROM (SELECT D2_COD CODIGO, B1_DESC DESCRICAO, " 
    cQuery += " ROUND(ISNULL((SELECT SUM(B2_QATU) FROM SB2040 WHERE B2_FILIAL IN('01','02') AND B2_COD = D2_COD "
    cQuery += " AND B2_LOCAL IN ('01','02') AND D_E_L_E_T_ = ' '),0) * B1_CUSDIP,2) 'ESTOQUE_VALOR', " 
    cQuery += " ISNULL((SELECT SUM(B2_QATU) FROM SB2040 WHERE B2_FILIAL IN('01','02') AND B2_COD = D2_COD "
    cQuery += " AND B2_LOCAL IN ('01','02') AND D_E_L_E_T_ = ' '),0) ESTOQUE_ATUAL, "
    cQuery += " ISNULL((SELECT SUM(B2_RESERVA) FROM SB2040 WHERE B2_FILIAL IN('01','02') AND B2_COD = D2_COD "
    cQuery += " AND B2_LOCAL IN ('01','02') AND D_E_L_E_T_ = ' '),0) RESERVADO, " 
    cQuery += " ISNULL((SELECT SUM(B2_QPEDVEN) FROM SB2040 WHERE B2_FILIAL IN('01','02') AND B2_COD = D2_COD "
    cQuery += " AND B2_LOCAL IN ('01','02') AND D_E_L_E_T_ = ' '),0) SALDO, "
        
    cQuery += " ISNULL((SELECT SUM(B6_SALDO) AS SALDO FROM SB6040 SB6, SF2040 SF2 WHERE  SB6.B6_FILIAL = '01' "
    cQuery += " AND SB6.B6_FILIAL = SF2.F2_FILIAL AND SB6.B6_CLIFOR IN ('019433','110087') "   
    cQuery += " AND SB6.B6_PRODUTO = '8'+RIGHT(RTRIM(LTRIM(SD2040.D2_COD)),5) AND SF2.F2_TIPO = 'B' "      
    cQuery += " AND SF2.F2_DOC = SB6.B6_DOC AND SF2.F2_SERIE = SB6.B6_SERIE AND SF2.F2_CLIENTE = SB6.B6_CLIFOR "       
    cQuery += " AND SF2.F2_LOJA = SB6.B6_LOJA AND SF2.F2_EMISSAO = SB6.B6_EMISSAO AND SB6.B6_ATEND = '' "             
    cQuery += " AND SB6.B6_UENT = '' AND SB6.B6_SALDO > 0 AND SF2.D_E_L_E_T_ = '' AND SB6.D_E_L_E_T_ = ''     ),0) PODER_TERCEIRO, "

    cQuery += " (CASE WHEN LEFT(D2_EMISSAO,6) = '" + AnoMes(MonthSub(dDataAtual,3)) + "' THEN Round(SUM(D2_QUANT),2) ELSE 0 END) MES1, "
    cQuery += " (CASE WHEN LEFT(D2_EMISSAO,6) = '" + AnoMes(MonthSub(dDataAtual,2)) + "' THEN Round(SUM(D2_QUANT),2) ELSE 0 END) MES2, "
    cQuery += " (CASE WHEN LEFT(D2_EMISSAO,6) = '" + AnoMes(MonthSub(dDataAtual,1)) + "' THEN Round(SUM(D2_QUANT),2) ELSE 0 END) MES3, "
    cQuery += " (CASE WHEN LEFT(D2_EMISSAO,6) = '" + AnoMes(dDataAtual) + "' THEN Round(SUM(D2_QUANT),2) ELSE 0 END) MES4 "
                
    cQuery += " FROM SD2040 WITH(NOLOCK) "
    cQuery += " INNER JOIN SB1040 WITH(NOLOCK) "
    cQuery += " ON B1_FILIAL = D2_FILIAL AND B1_COD = D2_COD AND B1_TIPO = 'PA' AND SB1040.D_E_L_E_T_ = '' "
    cQuery += " INNER JOIN SF4040 WITH(NOLOCK) "
    cQuery += " ON F4_FILIAL = D2_FILIAL AND F4_CODIGO = D2_TES AND F4_ESTOQUE = 'S' AND SF4040.D_E_L_E_T_ = '' "
    cQuery += " WHERE D2_FILIAL IN('01') AND D2_EMISSAO BETWEEN '" + AnoMes(MonthSub(dDataAtual,3)) + "01' "
    cQuery += " AND '" + AnoMes(dDataAtual) + "30' AND D2_TIPO = 'N' AND "
    cQuery += " D2_CLIENTE <> '019170' AND D2_LOCAL ='01' AND SD2040.D_E_L_E_T_ = '' "
    cQuery += " GROUP BY LEFT(D2_EMISSAO,6), D2_COD, B1_DESC, B1_CUSDIP ) TRB "
    cQuery += " GROUP BY CODIGO, DESCRICAO, ESTOQUE_VALOR, ESTOQUE_ATUAL, RESERVADO, SALDO, PODER_TERCEIRO "
    cQuery += " ) "

    cQuery += " GROUP BY B2_COD,B1_DESC "
    cQuery += " ORDER BY ESTOQUE_VALOR "  

    If Select("QRY1") > 0
		QRY1->(dbCloseArea())
	EndIf
	
	TCQuery cQuery New Alias "QRY1"

   	QRY1->(DbGoTop())

   	oSection1:Init()

    While !QRY1->(EOF())
   	
   		If oReport:Cancel()
   			Exit
   		EndIf   		

   		oReport:IncMeter()
   		
   		oSection1:Cell("CODIGO"):SetValue(Alltrim(QRY1->(CODIGO)))
        oSection1:Cell("DESCRICAO"):SetValue(Alltrim(QRY1->(DESCRICAO)))
   		oSection1:Cell("ESTOQUE_VALOR"):SetValue(Alltrim(cValToChar(QRY1->(ESTOQUE_VALOR))))
        oSection1:Cell("ESTOQUE_ATUAL"):SetValue(Alltrim(cValToChar(QRY1->(ESTOQUE_ATUAL))))
        oSection1:Cell("RESERVADO"):SetValue(Alltrim(cValToChar(QRY1->(RESERVADO))))
        oSection1:Cell("SALDO"):SetValue(Alltrim(cValToChar(QRY1->(SALDO))))
        oSection1:Cell("PODER_TERCEIRO"):SetValue(Alltrim(cValToChar(QRY1->(PODER_TERCEIRO))))
        oSection1:Cell("MES1"):SetValue(Alltrim(cValToChar(QRY1->(MES1))))
        oSection1:Cell("MES2"):SetValue(Alltrim(cValToChar(QRY1->(MES2))))
        oSection1:Cell("MES3"):SetValue(Alltrim(cValToChar(QRY1->(MES3))))
        oSection1:Cell("MES4"):SetValue(Alltrim(cValToChar(QRY1->(MES4))))
        oSection1:Cell("MEDIA"):SetValue(Alltrim(cValToChar(QRY1->(MEDIA))))

   		oSection1:PrintLine()
   		
   		QRY1->(DbSkip())

	EndDo
	
	oSection1:Finish() 
		
	QRY1->(DbCloseArea())  

    // Início Section 2 (PI)

    cQuery := " SELECT B2_COD CODIGO, B1_DESC DESCRICAO, ROUND((B2_QATU)*B1_CUSDIP,2) 'ESTOQUE_VALOR', "
    cQuery += " B2_QATU ESTOQUE, B2_QACLASS A_ENDERECAR, "
    cQuery += " ISNULL((SELECT SUM(C7_QUANT - C7_QUJE) " 
    cQuery += " FROM SC7040 "
    cQuery += " WHERE C7_PRODUTO = B2_COD AND "
    cQuery += " C7_FILIAL = '01'  AND "
    cQuery += " C7_QUJE < C7_QUANT AND "
    cQuery += " C7_CONAPRO <> 'B' AND "
    cQuery += " C7_RESIDUO = '' AND "
    cQuery += " DATEDIFF(DAY,'" + DTOS(dDataAtual) + "',C7_DENTREG) <= 30 AND "
    cQuery += " SC7040.D_E_L_E_T_ = ' ' GROUP BY B2_COD),0) PEDIDO_COMPRA, "
    cQuery += " ISNULL(SUM(MES1),0) MES1, ISNULL(SUM(MES2),0) MES2, ISNULL(SUM(MES3),0) MES3, ISNULL(SUM(MES4),0) MES4,
    cQuery += " ISNULL(((SUM(MES1)+SUM(MES2)+SUM(MES3)+SUM(MES4))/4),0) MEDIA "
    cQuery += " FROM (SELECT  ZZA_CODPRO CODIGO,B1_DESC DESCRIÇÃO, "
    cQuery += " (CASE WHEN LEFT(ZZ8_DATA,6) = '" + AnoMes(MonthSub(dDataAtual,3)) + "' THEN Round(SUM(ZZA_QTDPRO),2) ELSE 0 END) MES1, "
    cQuery += " (CASE WHEN LEFT(ZZ8_DATA,6) = '" + AnoMes(MonthSub(dDataAtual,2)) + "' THEN Round(SUM(ZZA_QTDPRO),2) ELSE 0 END) MES2, "
    cQuery += " (CASE WHEN LEFT(ZZ8_DATA,6) = '" + AnoMes(MonthSub(dDataAtual,1)) + "' THEN Round(SUM(ZZA_QTDPRO),2) ELSE 0 END) MES3, "
    cQuery += " (CASE WHEN LEFT(ZZ8_DATA,6) = '" + AnoMes(dDataAtual) + "' THEN Round(SUM(ZZA_QTDPRO),2) ELSE 0 END) MES4, "
    cQuery += " B1_CUSDIP CUSTO "
    cQuery += " FROM ZZ8040, ZZA040, SB1040 "
    cQuery += " WHERE ZZ8040.D_E_L_E_T_ = '' "
    cQuery += " AND ZZA040.D_E_L_E_T_ = '' "
    cQuery += " AND SB1040.D_E_L_E_T_ = '' "
    cQuery += " AND ZZ8_REQMAT = ZZA_REQMAT "
    cQuery += " AND ZZ8_FILIAL = ZZA_FILIAL "
    cQuery += " AND ZZ8_STATUS = '2' "
    cQuery += " AND ZZ8_DATA BETWEEN '" + AnoMes(MonthSub(dDataAtual,3)) + "01' AND '" + AnoMes(dDataAtual) + "30' "
    cQuery += " AND B1_COD = ZZA_CODPRO "
    cQuery += " AND B1_FILIAL = ZZA_FILIAL "
    cQuery += " AND B1_TIPO = 'PI' "
    cQuery += " AND ZZ8_ORDPRO <> 'TESTE' "
    cQuery += " GROUP BY ZZA_CODPRO, B1_DESC, LEFT(ZZ8_DATA,6) , B1_CUSDIP) TRB, SB2040, SB1040 "
    cQuery += " WHERE SB2040.D_E_L_E_T_ = '' "
    cQuery += " AND SB1040.D_E_L_E_T_ = '' "
    cQuery += " AND B1_COD = B2_COD "
    cQuery += " AND B1_FILIAL = B2_FILIAL "
    cQuery += " AND B1_TIPO = 'PI' "
    cQuery += " AND B2_LOCAL = '01' "
    cQuery += " AND B2_FILIAL = '01' "
    cQuery += " AND B2_COD = CODIGO "
    cQuery += " GROUP BY B2_COD, B1_DESC, B1_CUSDIP, B2_QATU, B2_RESERVA, B2_QACLASS, B2_QPEDVEN "  

    If Select("QRY2") > 0
		QRY2->(dbCloseArea())
	EndIf
	
	TCQuery cQuery New Alias "QRY2"

   	QRY2->(DbGoTop())

   	oSection2:Init()

    While !QRY2->(EOF())
   	
   		If oReport:Cancel()
   			Exit
   		EndIf   		

   		oReport:IncMeter()
   		
   		oSection2:Cell("CODIGO"):SetValue(Alltrim(QRY2->(CODIGO)))
        oSection2:Cell("DESCRICAO"):SetValue(Alltrim(QRY2->(DESCRICAO)))
   		oSection2:Cell("ESTOQUE_VALOR"):SetValue(Alltrim(cValToChar(QRY2->(ESTOQUE_VALOR))))
        oSection2:Cell("ESTOQUE"):SetValue(Alltrim(cValToChar(QRY2->(ESTOQUE))))
        oSection2:Cell("A_ENDERECAR"):SetValue(Alltrim(cValToChar(QRY2->(A_ENDERECAR))))
        oSection2:Cell("PEDIDO_COMPRA"):SetValue(Alltrim(cValToChar(QRY2->(PEDIDO_COMPRA))))
        oSection2:Cell("MES1"):SetValue(Alltrim(cValToChar(QRY2->(MES1))))
        oSection2:Cell("MES2"):SetValue(Alltrim(cValToChar(QRY2->(MES2))))
        oSection2:Cell("MES3"):SetValue(Alltrim(cValToChar(QRY2->(MES3))))
        oSection2:Cell("MES4"):SetValue(Alltrim(cValToChar(QRY2->(MES4))))
        oSection2:Cell("MEDIA"):SetValue(Alltrim(cValToChar(QRY2->(MEDIA))))

   		oSection2:PrintLine()
   		QRY2->(DbSkip())

	EndDo
	
	oSection2:Finish() 
	QRY2->(DbCloseArea()) 

    // Início Section 3 (MP)

    cQuery := " SELECT B2_COD CODIGO, B1_DESC DESCRICAO, ROUND((B2_QATU)*B1_CUSDIP,2) 'ESTOQUE_VALOR', "
    cQuery += " B2_QATU ESTOQUE, B2_QACLASS A_ENDERECAR, "
    cQuery += " ISNULL((SELECT SUM(C7_QUANT - C7_QUJE) " 
    cQuery += " FROM SC7040 "
    cQuery += " WHERE C7_PRODUTO = B2_COD AND "
    cQuery += " C7_FILIAL = '01'  AND "
    cQuery += " C7_QUJE < C7_QUANT AND "
    cQuery += " C7_CONAPRO <> 'B' AND "
    cQuery += " C7_RESIDUO = '' AND "
    cQuery += " DATEDIFF(DAY,'" + DTOS(dDataAtual) + "',C7_DENTREG) <= 30 AND "
    cQuery += " SC7040.D_E_L_E_T_ = '' GROUP BY B2_COD),0) PEDIDO_COMPRA, "
    cQuery += " ISNULL(SUM(MES1),0) MES1, ISNULL(SUM(MES2),0) MES2, ISNULL(SUM(MES3),0) MES3, ISNULL(SUM(MES4),0) MES4,
    cQuery += " ISNULL(((SUM(MES1)+SUM(MES2)+SUM(MES3)+SUM(MES4))/4),0) MEDIA "
    cQuery += " FROM (SELECT  ZZA_CODPRO CODIGO,B1_DESC DESCRIÇÃO, "
    cQuery += " (CASE WHEN LEFT(ZZ8_DATA,6) = '" + AnoMes(MonthSub(dDataAtual,3)) + "' THEN Round(SUM(ZZA_QTDPRO),2) ELSE 0 END) MES1, "
    cQuery += " (CASE WHEN LEFT(ZZ8_DATA,6) = '" + AnoMes(MonthSub(dDataAtual,2)) + "' THEN Round(SUM(ZZA_QTDPRO),2) ELSE 0 END) MES2, "
    cQuery += " (CASE WHEN LEFT(ZZ8_DATA,6) = '" + AnoMes(MonthSub(dDataAtual,1)) + "' THEN Round(SUM(ZZA_QTDPRO),2) ELSE 0 END) MES3, "
    cQuery += " (CASE WHEN LEFT(ZZ8_DATA,6) = '" + AnoMes(dDataAtual) + "' THEN Round(SUM(ZZA_QTDPRO),2) ELSE 0 END) MES4, "
    cQuery += " B1_CUSDIP CUSTO "
    cQuery += " FROM ZZ8040, ZZA040, SB1040 "
    cQuery += " WHERE ZZ8040.D_E_L_E_T_ = '' "
    cQuery += " AND ZZA040.D_E_L_E_T_ = '' "
    cQuery += " AND SB1040.D_E_L_E_T_ = '' "
    cQuery += " AND ZZ8_REQMAT = ZZA_REQMAT "
    cQuery += " AND ZZ8_FILIAL = ZZA_FILIAL "
    cQuery += " AND ZZ8_STATUS = '2' "
    cQuery += " AND ZZ8_DATA BETWEEN '" + AnoMes(MonthSub(dDataAtual,3)) + "01' AND '" + AnoMes(dDataAtual) + "30' "
    cQuery += " AND B1_COD = ZZA_CODPRO "
    cQuery += " AND B1_FILIAL = ZZA_FILIAL "
    cQuery += " AND B1_TIPO = 'MP' "
    cQuery += " AND ZZ8_ORDPRO <> 'TESTE' "
    cQuery += " GROUP BY ZZA_CODPRO, B1_DESC, LEFT(ZZ8_DATA,6) , B1_CUSDIP) TRB, SB2040, SB1040 "
    cQuery += " WHERE SB2040.D_E_L_E_T_ = '' "
    cQuery += " AND SB1040.D_E_L_E_T_ = '' "
    cQuery += " AND B1_COD = B2_COD "
    cQuery += " AND B1_FILIAL = B2_FILIAL "
    cQuery += " AND B1_TIPO = 'MP' "
    cQuery += " AND B2_LOCAL = '01' "
    cQuery += " AND B2_FILIAL = '01' "
    cQuery += " AND B2_COD = CODIGO "
    cQuery += " GROUP BY B2_COD, B1_DESC, B1_CUSDIP, B2_QATU, B2_RESERVA, B2_QACLASS, B2_QPEDVEN "  

    If Select("QRY3") > 0
		QRY3->(dbCloseArea())
	EndIf
	
	TCQuery cQuery New Alias "QRY3"

   	QRY3->(DbGoTop())

   	oSection3:Init()

    While !QRY3->(EOF())
   	
   		If oReport:Cancel()
   			Exit
   		EndIf   		

   		oReport:IncMeter()
   		
   		oSection3:Cell("CODIGO"):SetValue(Alltrim(QRY3->(CODIGO)))
        oSection3:Cell("DESCRICAO"):SetValue(Alltrim(QRY3->(DESCRICAO)))
   		oSection3:Cell("ESTOQUE_VALOR"):SetValue(Alltrim(cValToChar(QRY3->(ESTOQUE_VALOR))))
        oSection3:Cell("ESTOQUE"):SetValue(Alltrim(cValToChar(QRY3->(ESTOQUE))))
        oSection3:Cell("A_ENDERECAR"):SetValue(Alltrim(cValToChar(QRY3->(A_ENDERECAR))))
        oSection3:Cell("PEDIDO_COMPRA"):SetValue(Alltrim(cValToChar(QRY3->(PEDIDO_COMPRA))))
        oSection3:Cell("MES1"):SetValue(Alltrim(cValToChar(QRY3->(MES1))))
        oSection3:Cell("MES2"):SetValue(Alltrim(cValToChar(QRY3->(MES2))))
        oSection3:Cell("MES3"):SetValue(Alltrim(cValToChar(QRY3->(MES3))))
        oSection3:Cell("MES4"):SetValue(Alltrim(cValToChar(QRY3->(MES4))))
        oSection3:Cell("MEDIA"):SetValue(Alltrim(cValToChar(QRY3->(MEDIA))))

   		oSection3:PrintLine()
   		QRY3->(DbSkip())

	EndDo
	
	oSection3:Finish() 
	QRY3->(DbCloseArea())   

    // Início Section 4 (MC)

    cQuery := " SELECT B2_COD CODIGO, B1_DESC DESCRICAO, ROUND((B2_QATU)*B1_CUSDIP,2) 'ESTOQUE_VALOR', "
    cQuery += " B2_QATU ESTOQUE, B2_QACLASS A_ENDERECAR, "
    cQuery += " ISNULL((SELECT SUM(C7_QUANT - C7_QUJE) " 
    cQuery += " FROM SC7040 "
    cQuery += " WHERE C7_PRODUTO = B2_COD AND "
    cQuery += " C7_FILIAL = '01'  AND "
    cQuery += " C7_QUJE < C7_QUANT AND "
    cQuery += " C7_CONAPRO <> 'B' AND "
    cQuery += " C7_RESIDUO = '' AND "
    cQuery += " DATEDIFF(DAY,'" + DTOS(dDataAtual) + "',C7_DENTREG) <= 30 AND "
    cQuery += " SC7040.D_E_L_E_T_ = '' GROUP BY B2_COD),0) PEDIDO_COMPRA, "
    cQuery += " ISNULL(SUM(MES1),0) MES1, ISNULL(SUM(MES2),0) MES2, ISNULL(SUM(MES3),0) MES3, ISNULL(SUM(MES4),0) MES4,
    cQuery += " ISNULL(((SUM(MES1)+SUM(MES2)+SUM(MES3)+SUM(MES4))/4),0) MEDIA "
    cQuery += " FROM (SELECT  ZZA_CODPRO CODIGO,B1_DESC DESCRIÇÃO, "
    cQuery += " (CASE WHEN LEFT(ZZ8_DATA,6) = '" + AnoMes(MonthSub(dDataAtual,3)) + "' THEN Round(SUM(ZZA_QTDPRO),2) ELSE 0 END) MES1, "
    cQuery += " (CASE WHEN LEFT(ZZ8_DATA,6) = '" + AnoMes(MonthSub(dDataAtual,2)) + "' THEN Round(SUM(ZZA_QTDPRO),2) ELSE 0 END) MES2, "
    cQuery += " (CASE WHEN LEFT(ZZ8_DATA,6) = '" + AnoMes(MonthSub(dDataAtual,1)) + "' THEN Round(SUM(ZZA_QTDPRO),2) ELSE 0 END) MES3, "
    cQuery += " (CASE WHEN LEFT(ZZ8_DATA,6) = '" + AnoMes(dDataAtual) + "' THEN Round(SUM(ZZA_QTDPRO),2) ELSE 0 END) MES4, "
    cQuery += " B1_CUSDIP CUSTO "
    cQuery += " FROM ZZ8040, ZZA040, SB1040 "
    cQuery += " WHERE ZZ8040.D_E_L_E_T_ = '' "
    cQuery += " AND ZZA040.D_E_L_E_T_ = '' "
    cQuery += " AND SB1040.D_E_L_E_T_ = '' "
    cQuery += " AND ZZ8_REQMAT = ZZA_REQMAT "
    cQuery += " AND ZZ8_FILIAL = ZZA_FILIAL "
    cQuery += " AND ZZ8_STATUS = '2' "
    cQuery += " AND ZZ8_DATA BETWEEN '" + AnoMes(MonthSub(dDataAtual,3)) + "01' AND '" + AnoMes(dDataAtual) + "30' "
    cQuery += " AND B1_COD = ZZA_CODPRO "
    cQuery += " AND B1_FILIAL = ZZA_FILIAL "
    cQuery += " AND B1_TIPO = 'MC' "
    cQuery += " AND ZZ8_ORDPRO <> 'TESTE' "
    cQuery += " GROUP BY ZZA_CODPRO, B1_DESC, LEFT(ZZ8_DATA,6) , B1_CUSDIP) TRB, SB2040, SB1040 "
    cQuery += " WHERE SB2040.D_E_L_E_T_ = '' "
    cQuery += " AND SB1040.D_E_L_E_T_ = '' "
    cQuery += " AND B1_COD = B2_COD "
    cQuery += " AND B1_FILIAL = B2_FILIAL "
    cQuery += " AND B1_TIPO = 'MC' "
    cQuery += " AND B2_LOCAL = '01' "
    cQuery += " AND B2_FILIAL = '01' "
    cQuery += " AND B2_COD = CODIGO "
    cQuery += " GROUP BY B2_COD, B1_DESC, B1_CUSDIP, B2_QATU, B2_RESERVA, B2_QACLASS, B2_QPEDVEN "  

    If Select("QRY4") > 0
		QRY4->(dbCloseArea())
	EndIf
	
	TCQuery cQuery New Alias "QRY4"

   	QRY4->(DbGoTop())

   	oSection4:Init()

    While !QRY4->(EOF())
   	
   		If oReport:Cancel()
   			Exit
   		EndIf   		

   		oReport:IncMeter()
   		
   		oSection4:Cell("CODIGO"):SetValue(Alltrim(QRY4->(CODIGO)))
        oSection4:Cell("DESCRICAO"):SetValue(Alltrim(QRY4->(DESCRICAO)))
   		oSection4:Cell("ESTOQUE_VALOR"):SetValue(Alltrim(cValToChar(QRY4->(ESTOQUE_VALOR))))
        oSection4:Cell("ESTOQUE"):SetValue(Alltrim(cValToChar(QRY4->(ESTOQUE))))
        oSection4:Cell("A_ENDERECAR"):SetValue(Alltrim(cValToChar(QRY4->(A_ENDERECAR))))
        oSection4:Cell("PEDIDO_COMPRA"):SetValue(Alltrim(cValToChar(QRY4->(PEDIDO_COMPRA))))
        oSection4:Cell("MES1"):SetValue(Alltrim(cValToChar(QRY4->(MES1))))
        oSection4:Cell("MES2"):SetValue(Alltrim(cValToChar(QRY4->(MES2))))
        oSection4:Cell("MES3"):SetValue(Alltrim(cValToChar(QRY4->(MES3))))
        oSection4:Cell("MES4"):SetValue(Alltrim(cValToChar(QRY4->(MES4))))
        oSection4:Cell("MEDIA"):SetValue(Alltrim(cValToChar(QRY4->(MEDIA))))

   		oSection4:PrintLine()
   		QRY4->(DbSkip())

	EndDo
	
	oSection4:Finish() 
	QRY4->(DbCloseArea())    

Return
#include 'protheus.ch'
#include 'parmtype.ch'
#include "report.ch"
#include "topconn.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±º Programa   DIPRFINCRD    ºAutor  ³Rafael Rosa     º Data ³  27/10/22  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±																		  ¹±±
±± ºDesc.    ³ RELATORIO DE TOTALIZACAO DO LC POR GRP E CNPJ RAIZ DE	  º±±
±±			   CLIENTES               									  º±±
±±																		  ¹±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

user function DIPRFINCRD()

If FindFunction("TRepInUse") 
	IMPREL()
EndIf

Return

Static Function IMPREL()	
	Local oReport 	:= NIL
	Local cPerg 	:= "DIPRFINCRD"
	    
	//AjustaSx1(cPerg)	
	If Pergunte(cPerg,.T.)			
   		oReport := ReportDef(cPerg)
   		oReport:PrintDialog()			
	EndIf	
		
Return

Static Function ReportDef(clPerg)

	Local oReport	:= Nil
	Local oSection1	:= Nil
	Local oBreak1	:= Nil
	
	oReport := TReport():New("DIPRFINCRD","Relatório Limite de Credito",clPerg,{|oReport| PrintReport(oReport)},"Relatório Limite de Credito") 
	 
	oReport:SetTotalInLine(.F.)
	oReport:lParamPage := .F.
	oReport:oPage:SetPaperSize(9)  
	oReport:SetLandscape()
	  
  	oSection1 := TRSection():New(oReport ,"Agrupador",{"QRY"})
  	
  	oSection1:SetTotalInLine(.F.)

  	TRCell():New(oSection1, "GRP_CNPJ"			, "QRY", "GRP/CNPJ"			,,14,,,,,,,,,,,)
  	TRCell():New(oSection1, "CLIENTE"			, "QRY", "Cod.Cliente"		,,6,,,,,,,,,,,)
  	TRCell():New(oSection1, "LOJA"				, "QRY", "Cod.Loja"			,,2,,,,,,,,,,,)
  	TRCell():New(oSection1, "RAZAO_SOCIAL"		, "QRY", "Razao Social"		,,61,,,,,,,,,,,)
  	TRCell():New(oSection1, "RISCO"				, "QRY", "Risco"			,,1,,,,,,,,,,,)
  	TRCell():New(oSection1, "LIM_CRED"			, "QRY", "Lim. Credito"		,,30,,,,,,,,,,,)
  	TRCell():New(oSection1, "DT_LIM_LC"			, "QRY", "Dt. Lim. Cred."	,,8,,,,,,,,,,,) 	
  	TRCell():New(oSection1, "SALDO_ATUAL_LC"	, "QRY", "Saldo Atual"		,,30,,,,,,,,,,,)
	
  	oBreak1 := TRBreak():New(oSection1,{|| QRY->(IIF(MV_PAR01=1,A1_XGRPCLI,SUBSTR(A1_CGC,1,8))) },{|| })
	TRFunction():New(oSection1:Cell("LIM_CRED"),/* cID */,"SUM",oBreak1,/*cTitle*/,PesqPict("SE1","E1_VALOR"),/*uFormula*/,.T./*lEndSection*/,.T./*lEndReport*/,/*lEndPage*/)
	TRFunction():New(oSection1:Cell("SALDO_ATUAL_LC"),/* cID */,"SUM",oBreak1,/*cTitle*/,PesqPict("SE1","E1_VALOR"),/*uFormula*/,.T./*lEndSection*/,.T./*lEndReport*/,/*lEndPage*/)
	oSection1:Cell("LIM_CRED"):SetHeaderAlign("LEFT")
	oSection1:Cell("SALDO_ATUAL_LC"):SetHeaderAlign("LEFT")
  	oSection1:SetHeaderBreak(.T.)
  	
Return oReport

Static Function PrintReport(oReport)
 
 	Local aArea 	:= GetArea()
	Local oSection1	:= Nil
	Local nAtual 	:= 0
	Local nTotal 	:= 0
	Local cQuery	:= ""
	
	oSection1 := oReport:Section(1) 	

	cQuery := "	SELECT " + CRLF
	cQuery += IIF(MV_PAR01=1," A1_XGRPCLI, ",IIF(MV_PAR01=2," A1_CGC, ",""))
	cQuery += " A1_COD, A1_LOJA, A1_NOME, A1_LC, A1_VENCLC, A1_RISCO, " + CRLF

		cQuery += "(A1.A1_LC - (SELECT SUM(E1_VALOR) FROM "+RetSqlName("SE1")+" SE1 " + CRLF
		cQuery += "WHERE SE1.D_E_L_E_T_ = '' " + CRLF
		cQuery += "AND E1_CLIENTE = A1.A1_COD " + CRLF
		cQuery += "AND E1_LOJA = A1.A1_LOJA " + CRLF
		cQuery += "AND E1_SALDO > 0 " + CRLF
		cQuery += "AND E1_TIPO IN('NF','JP','FT','NDC','JUR') " + CRLF
		cQuery += "AND SE1.E1_VENCREA < CONVERT(VARCHAR(8),GETDATE(),112))) AS SALDO_ATUAL " + CRLF
          
	cQuery +=  " 	from "+RetSqlName("SA1")+" A1 " + CRLF
	cQuery +=  " 	where " + CRLF
	cQuery +=  "    A1.D_E_L_E_T_ = '' AND " + CRLF
	IF MV_PAR01 = 1
		cQuery +=  "       A1_XGRPCLI BETWEEN '" + MV_PAR02 + "' AND '" + MV_PAR03 + "' " + CRLF
		cQuery +=  "     ORDER BY  A1_XGRPCLI "
	ELSEIF MV_PAR01 = 2
		cQuery +=  "       SUBSTRING(A1_CGC,1,8) = '" + MV_PAR04 + "' " + CRLF
		cQuery +=  "     ORDER BY  A1_CGC "
	ENDIF
	
	If Select("QRY") > 0
		QRY->(dbCloseArea())
	EndIf
	
	TCQuery cQuery New Alias "QRY"
	Count to nTotal
	oReport:SetMeter(nTotal)

   	QRY->(DbGoTop())
   	oSection1:Init()
   	
   	While !QRY->(EOF())
   	
   		If oReport:Cancel()
   			Exit
   		EndIf   		
   		
   		nAtual++
   		oReport:SetMsgPrint("Imprimindo registro " + cValtoChar(nAtual)+ " de " + cValtoChar(nTotal)+ "...")
   		oReport:IncMeter()
   		
   		oSection1:Cell("GRP_CNPJ"):SetValue(Alltrim(QRY->(IIF(MV_PAR01=1,A1_XGRPCLI,A1_CGC))))
		oSection1:Cell("CLIENTE"):SetValue(Alltrim(QRY->(A1_COD)))
		oSection1:Cell("LOJA"):SetValue(Alltrim(QRY->(A1_LOJA)))
		oSection1:Cell("RAZAO_SOCIAL"):SetValue(Alltrim(QRY->(A1_NOME)))
		oSection1:Cell("RISCO"):SetValue(Alltrim(QRY->(A1_RISCO)))
		oSection1:Cell("LIM_CRED"):SetValue(Alltrim(Transform(QRY->(A1_LC),PesqPict("SA1", "A1_LC"))))
		oSection1:Cell("DT_LIM_LC"):SetValue(Alltrim(DTOC(STOD(QRY->(A1_VENCLC)))))
		oSection1:Cell("SALDO_ATUAL_LC"):SetValue(Alltrim(Transform(QRY->(SALDO_ATUAL),PesqPict("SA1", "A1_LC"))))

   		oSection1:PrintLine()

   		QRY->(DbSkip())
	EndDo
	
	oSection1:Finish() 
		
	QRY->(DbCloseArea())
	
	RestArea(aArea)

Return

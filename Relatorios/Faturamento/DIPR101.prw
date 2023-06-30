#include 'protheus.ch'
#include 'parmtype.ch'
#include "report.ch"
#include "topconn.ch"

user function DIPR101()

If FindFunction("TRepInUse") 
	IMPREL()
EndIf

Return

Static Function IMPREL()	
	Local oReport 	:= NIL
	Local cPerg 	:= "DIPR100"
	    
	AjustaSx1(cPerg)	
	If Pergunte(cPerg,.T.)			
   		oReport := ReportDef(cPerg)
   		oReport:PrintDialog()			
	EndIf	
		
Return

Static Function ReportDef(clPerg)

	Local oReport	:= Nil
	Local oSection1	:= Nil
	Local oBreak1	:= Nil
	
	Local cMesCor	:= StrZero(Month(DATE()),2)
	
	oReport := TReport():New("DIPR100","Relatório de Itens de NF Saída",clPerg,{|oReport| PrintReport(oReport)},"Relatório de Itens de NF Saída") 
	 
	oReport:SetTotalInLine(.F.)
	oReport:lParamPage := .F.
	oReport:oPage:SetPaperSize(9)  
	oReport:SetLandscape()
	  
  	oSection1 := TRSection():New(oReport ,"Agrupador",{"QRY"})
  	
  	oSection1:SetTotalInLine(.F.)
  	
  	TRCell():New(oSection1, "PRODUTO"			, "QRY", "PRODUTO"				,,6,,,,,,,,,,,)
  	TRCell():New(oSection1, "DESCRITIVO"		, "QRY", "DESCRITIVO"			,,30,,,,,,,,,,,)
  	TRCell():New(oSection1, "UNIDADE_DE_MEDIDA"	, "QRY", "UNIDADE_DE_MEDIDA"	,,2,,,,,,,,,,,)
  	TRCell():New(oSection1, "QUANTIDADE"		, "QRY", "QUANTIDADE"			,,30,,,,,,,,,,,)  	
  	TRCell():New(oSection1, "PRECO_TOTAL"		, "QRY", "PREÇO TOTAL"			,,30,,,,,,,,,,,)
  	If cMesCor $ '04'  	
  		TRCell():New(oSection1, "CONSUMO_JANEIRO"	, "QRY", "CONSUMO_JANEIRO"		,,30,,,,,,,,,,,)
  	EndIf
  	If cMesCor $ '04|05'  	
  		TRCell():New(oSection1, "CONSUMO_FEVEREIRO"	, "QRY", "CONSUMO_FEVEREIRO"	,,30,,,,,,,,,,,)
  	EndIf
  	If cMesCor $ '04|05|06'  	
  		TRCell():New(oSection1, "CONSUMO_MARCO"		, "QRY", "CONSUMO_MARCO"		,,30,,,,,,,,,,,)
  	EndIf
  	If cMesCor $ '05|06|07'  	
  		TRCell():New(oSection1, "CONSUMO_ABRIL"		, "QRY", "CONSUMO_ABRIL"		,,30,,,,,,,,,,,)
  	EndIf
  	If cMesCor $ '06|07|08'  	
  		TRCell():New(oSection1, "CONSUMO_MAIO"		, "QRY", "CONSUMO_MAIO"			,,30,,,,,,,,,,,)
  	EndIf
  	If cMesCor $ '07|08|09'  	
  		TRCell():New(oSection1, "CONSUMO_JUNHO"		, "QRY", "CONSUMO_JUNHO"		,,30,,,,,,,,,,,)
  	EndIf
  	If cMesCor $ '08|09|10'  	
  		TRCell():New(oSection1, "CONSUMO_JULHO"		, "QRY", "CONSUMO_JULHO"		,,30,,,,,,,,,,,)
  	EndIf
  	If cMesCor $ '09|10|11'  	
  		TRCell():New(oSection1, "CONSUMO_AGOSTO"	, "QRY", "CONSUMO_AGOSTO"		,,30,,,,,,,,,,,)
  	EndIf
  	If cMesCor $ '10|11|12'  	
  		TRCell():New(oSection1, "CONSUMO_SETEMBRO"	, "QRY", "CONSUMO_SETEMBRO"		,,30,,,,,,,,,,,)
  	EndIf
  	If cMesCor $ '11|12|01'  		
  		TRCell():New(oSection1, "CONSUMO_OUTUBRO"	, "QRY", "CONSUMO_OUTUBRO"		,,30,,,,,,,,,,,)
  	EndIf
  	If cMesCor $ '12|01|02'  	
  		TRCell():New(oSection1, "CONSUMO_NOVEMBRO"	, "QRY", "CONSUMO_NOVEMBRO"		,,30,,,,,,,,,,,)
  	EndIf
  	If cMesCor $ '01|02|03'  	
  		TRCell():New(oSection1, "CONSUMO_DEZEMBRO"	, "QRY", "CONSUMO_DEZEMBRO"		,,30,,,,,,,,,,,)
  	EndIf 
  	If cMesCor $ '02|03'  	
  		TRCell():New(oSection1, "CONSUMO_JANEIRO"	, "QRY", "CONSUMO_JANEIRO"		,,30,,,,,,,,,,,)
  	EndIf
  	If cMesCor $ '03'  	
  		TRCell():New(oSection1, "CONSUMO_FEVEREIRO"	, "QRY", "CONSUMO_FEVEREIRO"	,,30,,,,,,,,,,,)
  	EndIf		
  	Do Case
		Case cMesCor ='01'
			TRCell():New(oSection1, "CONSUMO_ATUAL"	, "QRY", "CONSUMO_ATUAL"		,,30,,,,,,,,,,,)
		Case cMesCor ='02'
			TRCell():New(oSection1, "CONSUMO_ATUAL"	, "QRY", "CONSUMO_ATUAL"	,,30,,,,,,,,,,,)
		Case cMesCor ='03'
			TRCell():New(oSection1, "CONSUMO_ATUAL"	, "QRY", "CONSUMO_ATUAL"		,,30,,,,,,,,,,,)
		Case cMesCor ='04'
			TRCell():New(oSection1, "CONSUMO_ATUAL"	, "QRY", "CONSUMO_ATUAL"		,,30,,,,,,,,,,,)
		Case cMesCor ='05'
			TRCell():New(oSection1, "CONSUMO_ATUAL"	, "QRY", "CONSUMO_ATUAL"			,,30,,,,,,,,,,,)
		Case cMesCor ='06'
			TRCell():New(oSection1, "CONSUMO_ATUAL"	, "QRY", "CONSUMO_ATUAL"		,,30,,,,,,,,,,,)
		Case cMesCor ='07'
			TRCell():New(oSection1, "CONSUMO_ATUAL"	, "QRY", "CONSUMO_ATUAL"		,,30,,,,,,,,,,,)
		Case cMesCor ='08'
			TRCell():New(oSection1, "CONSUMO_ATUAL"	, "QRY", "CONSUMO_ATUAL"		,,30,,,,,,,,,,,)
		Case cMesCor ='09'
			TRCell():New(oSection1, "CONSUMO_ATUAL"	, "QRY", "CONSUMO_ATUAL"		,,30,,,,,,,,,,,)
		Case cMesCor ='10'
			TRCell():New(oSection1, "CONSUMO_ATUAL"	, "QRY", "CONSUMO_ATUAL"		,,30,,,,,,,,,,,)
		Case cMesCor ='11'
			TRCell():New(oSection1, "CONSUMO_ATUAL"	, "QRY", "CONSUMO_ATUAL"		,,30,,,,,,,,,,,)
		Case cMesCor ='12'
			TRCell():New(oSection1, "CONSUMO_ATUAL"	, "QRY", "CONSUMO_ATUAL"		,,30,,,,,,,,,,,)
		EndCase
  	TRCell():New(oSection1, "FORNECEDOR"		, "QRY", "FORNECEDOR"			,,6,,,,,,,,,,,)
  	  
  	oBreak1 := TRBreak():New(oSection1,{|| QRY->(DESCRITIVO) },{|| })  	
  	oSection1:SetHeaderBreak(.T.)
  	
Return oReport

Static Function PrintReport(oReport)
 
 	Local aArea 	:= GetArea()
	Local oSection1	:= Nil
	Local _cQuery	:= ""
	Local nAtual 	:= 0
	Local nTotal 	:= 0
	Local aCli		:= {}
	Local aGrupo	:= {}
	Local _cAlias   := ""
	Local cQuery	:= ""
	Local cMesCor	:= StrZero(Month(DATE()),2)
	
	oSection1 := oReport:Section(1) 	
	
	cQuery :=  "	select " + CRLF 
	cQuery +=  " 		LEFT(D2_COD,6) PRODUTO,  " + CRLF
	cQuery +=  " 		B1_DESC DESCRITIVO, " + CRLF 
	cQuery +=  " 		B1_UM UNIDADE_DE_MEDIDA, " + CRLF
	cQuery +=  " 		SUM(D2_QUANT) QUANTIDADE, " + CRLF
	cQuery +=  " 		SUM(D2_TOTAL) 'PRECO_TOTAL', " + CRLF
	cQuery +=  " 			(SELECT	SUM(B3_Q01) FROM SB3010	WHERE D_E_L_E_T_ ='' AND D2_COD = B3_COD) CONSUMO_JANEIRO, " + CRLF
	cQuery +=  " 			(SELECT	SUM(B3_Q02) FROM SB3010	WHERE D_E_L_E_T_ ='' AND D2_COD = B3_COD) CONSUMO_FEVEREIRO, " + CRLF
	cQuery +=  " 			(SELECT	SUM(B3_Q03) FROM SB3010	WHERE D_E_L_E_T_ ='' AND D2_COD = B3_COD) CONSUMO_MARCO, " + CRLF
	cQuery +=  " 			(SELECT	SUM(B3_Q04) FROM SB3010	WHERE D_E_L_E_T_ ='' AND D2_COD = B3_COD) CONSUMO_ABRIL, " + CRLF
	cQuery +=  " 			(SELECT	SUM(B3_Q05) FROM SB3010	WHERE D_E_L_E_T_ ='' AND D2_COD = B3_COD) CONSUMO_MAIO, " + CRLF
	cQuery +=  " 			(SELECT	SUM(B3_Q06) FROM SB3010	WHERE D_E_L_E_T_ ='' AND D2_COD = B3_COD) CONSUMO_JUNHO, " + CRLF
	cQuery +=  " 			(SELECT	SUM(B3_Q07) FROM SB3010	WHERE D_E_L_E_T_ ='' AND D2_COD = B3_COD) CONSUMO_JULHO, " + CRLF
	cQuery +=  " 			(SELECT	SUM(B3_Q08) FROM SB3010	WHERE D_E_L_E_T_ ='' AND D2_COD = B3_COD) CONSUMO_AGOSTO, " + CRLF
	cQuery +=  " 			(SELECT	SUM(B3_Q09) FROM SB3010	WHERE D_E_L_E_T_ ='' AND D2_COD = B3_COD) CONSUMO_SETEMBRO, " + CRLF
	cQuery +=  " 		    (SELECT SUM(B3_Q10) FROM SB3010	WHERE D_E_L_E_T_ ='' AND D2_COD = B3_COD) CONSUMO_OUTUBRO, " + CRLF
	cQuery +=  " 		    (SELECT	SUM(B3_Q11) FROM SB3010	WHERE D_E_L_E_T_ ='' AND D2_COD = B3_COD) CONSUMO_NOVEMBRO, " + CRLF
	cQuery +=  " 		    (SELECT	SUM(B3_Q12) FROM SB3010	WHERE D_E_L_E_T_ ='' AND D2_COD = B3_COD) CONSUMO_DEZEMBRO,	 " + CRLF
	cQuery +=  " 		D2_FORNEC + ' - '+ A2_NOME 'FORNECEDOR' " + CRLF             
	cQuery +=  " 	from "+RetSqlName("SD2")+" D2, "+RetSqlName("SF4")+" F4 , "+RetSqlName("SA1")+" A1, "+RetSqlName("SB1")+" B1, "+RetSqlName("SA2")+" A2 " + CRLF
	cQuery +=  " 	where " + CRLF 
	cQuery +=  "       D2_EMISSAO BETWEEN '" + DTOS(MV_PAR01) + "' AND '" + DTOS(MV_PAR02) + "' " + CRLF
	cQuery +=  "       and A2_COD BETWEEN '" + MV_PAR03 + "' AND '" + MV_PAR04 + "' " + CRLF
	cQuery +=  "       and A2_LOJA BETWEEN '" + MV_PAR05 + "' AND '" + MV_PAR06 + "' " + CRLF
	cQuery +=  "       and D2.D_E_L_E_T_ = '' and F4.D_E_L_E_T_ = '' and A1.D_E_L_E_T_ = '' and B1.D_E_L_E_T_ = ''  and A2.D_E_L_E_T_ = '' " + CRLF
	cQuery +=  "       and D2_COD = B1_COD " + CRLF
	cQuery +=  "       and D2_TIPO in ('N','C') " + CRLF
	cQuery +=  "       and D2_CLIENTE = A1_COD and D2_LOJA = A1_LOJA " + CRLF
	cQuery +=  "       and D2_TES = F4_CODIGO and F4_DUPLIC = 'S' " + CRLF
	cQuery +=  "       and D2_FILIAL IN ('01','04') " + CRLF
	cQuery +=  "       and A1_FILIAL = '' " + CRLF
	cQuery +=  "       and F4_FILIAL = D2_FILIAL " + CRLF
	cQuery +=  "       and B1_FILIAL = D2_FILIAL " + CRLF
	cQuery +=  "       and D2_FORNEC = A2_COD " + CRLF
	cQuery +=  "       and A2_FILIAL = '' " + CRLF
	cQuery +=  "     GROUP BY D2_COD, B1_DESC, B1_UM, D2_FORNEC, A2_NOME " + CRLF
	cQuery +=  "     ORDER BY  B1_DESC " + CRLF
	
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
   		  
//		oSection1:Cell("EMISSAO"):SetValue(Alltrim(DTOC(STOD(QRY->(EMISSAO)))))
		oSection1:Cell("PRODUTO"):SetValue(Alltrim(QRY->(PRODUTO)))
		oSection1:Cell("DESCRITIVO"):SetValue(Alltrim(QRY->(DESCRITIVO)))
		oSection1:Cell("UNIDADE_DE_MEDIDA"):SetValue(Alltrim(QRY->(UNIDADE_DE_MEDIDA)))		
		oSection1:Cell("QUANTIDADE"):SetValue(Alltrim(Transform(QRY->(QUANTIDADE),PesqPict("SD2", "D2_QUANT"))))
		oSection1:Cell("PRECO_TOTAL"):SetValue(Alltrim(Transform(QRY->(PRECO_TOTAL),PesqPict("SD2", "D2_TOTAL"))))
		If cMesCor $ '04'
			oSection1:Cell("CONSUMO_JANEIRO"):SetValue(Alltrim(Transform(QRY->(CONSUMO_JANEIRO),PesqPict("SB3", "B3_Q01"))))
		EndIf
		If cMesCor $ '04|05'
			oSection1:Cell("CONSUMO_FEVEREIRO"):SetValue(Alltrim(Transform(QRY->(CONSUMO_FEVEREIRO),PesqPict("SB3", "B3_Q02"))))
		EndIf
		If cMesCor $ '04|05|06'
			oSection1:Cell("CONSUMO_MARCO"):SetValue(Alltrim(Transform(QRY->(CONSUMO_MARCO),PesqPict("SB3", "B3_Q03"))))
		EndIf
		If cMesCor $ '05|06|07'
			oSection1:Cell("CONSUMO_ABRIL"):SetValue(Alltrim(Transform(QRY->(CONSUMO_ABRIL),PesqPict("SB3", "B3_Q04"))))
		EndIf
		If cMesCor $ '06|07|08'
			oSection1:Cell("CONSUMO_MAIO"):SetValue(Alltrim(Transform(QRY->(CONSUMO_MAIO),PesqPict("SB3", "B3_Q05"))))
		EndIf
		If cMesCor $ '07|08|09'
			oSection1:Cell("CONSUMO_JUNHO"):SetValue(Alltrim(Transform(QRY->(CONSUMO_JUNHO),PesqPict("SB3", "B3_Q06"))))
		EndIf
		If cMesCor $ '08|09|10'
			oSection1:Cell("CONSUMO_JULHO"):SetValue(Alltrim(Transform(QRY->(CONSUMO_JULHO),PesqPict("SB3", "B3_Q07"))))
		EndIf
		If cMesCor $ '09|10|11'
			oSection1:Cell("CONSUMO_AGOSTO"):SetValue(Alltrim(Transform(QRY->(CONSUMO_AGOSTO),PesqPict("SB3", "B3_Q08"))))
		EndIf
		If cMesCor $ '10|11|12'
			oSection1:Cell("CONSUMO_SETEMBRO"):SetValue(Alltrim(Transform(QRY->(CONSUMO_SETEMBRO),PesqPict("SB3", "B3_Q09"))))
		EndIf
		If cMesCor $ '11|12|01'
			oSection1:Cell("CONSUMO_OUTUBRO"):SetValue(Alltrim(Transform(QRY->(CONSUMO_OUTUBRO),PesqPict("SB3", "B3_Q10"))))
		EndIf
		If cMesCor $ '12|01|02'
			oSection1:Cell("CONSUMO_NOVEMBRO"):SetValue(Alltrim(Transform(QRY->(CONSUMO_NOVEMBRO),PesqPict("SB3", "B3_Q11"))))
		EndIf
		If cMesCor $ '01|02|03'
			oSection1:Cell("CONSUMO_DEZEMBRO"):SetValue(Alltrim(Transform(QRY->(CONSUMO_DEZEMBRO),PesqPict("SB3", "B3_Q12"))))
		EndIf
		If cMesCor $ '02|03' //TESTE
			oSection1:Cell("CONSUMO_JANEIRO"):SetValue(Alltrim(Transform(QRY->(CONSUMO_JANEIRO),PesqPict("SB3", "B3_Q01"))))
		EndIf
		If cMesCor $ '03'
			oSection1:Cell("CONSUMO_FEVEREIRO"):SetValue(Alltrim(Transform(QRY->(CONSUMO_FEVEREIRO),PesqPict("SB3", "B3_Q02"))))
		EndIf//FIM TESTE
		Do Case
			Case cMesCor ='01'
				oSection1:Cell("CONSUMO_ATUAL"):SetValue(Alltrim(Transform(QRY->(CONSUMO_JANEIRO),PesqPict("SB3", "B3_Q01"))))
			Case cMesCor ='02'
				oSection1:Cell("CONSUMO_ATUAL"):SetValue(Alltrim(Transform(QRY->(CONSUMO_FEVEREIRO),PesqPict("SB3", "B3_Q02"))))
			Case cMesCor ='03'
				oSection1:Cell("CONSUMO_ATUAL"):SetValue(Alltrim(Transform(QRY->(CONSUMO_MARCO),PesqPict("SB3", "B3_Q03"))))
			Case cMesCor ='04'
				oSection1:Cell("CONSUMO_ATUAL"):SetValue(Alltrim(Transform(QRY->(CONSUMO_ABRIL),PesqPict("SB3", "B3_Q04"))))
			Case cMesCor ='05'
				oSection1:Cell("CONSUMO_ATUAL"):SetValue(Alltrim(Transform(QRY->(CONSUMO_MAIO),PesqPict("SB3", "B3_Q05"))))
			Case cMesCor ='06'
				oSection1:Cell("CONSUMO_ATUAL"):SetValue(Alltrim(Transform(QRY->(CONSUMO_JUNHO),PesqPict("SB3", "B3_Q06"))))
			Case cMesCor ='07'
				oSection1:Cell("CONSUMO_ATUAL"):SetValue(Alltrim(Transform(QRY->(CONSUMO_JULHO),PesqPict("SB3", "B3_Q07"))))
			Case cMesCor ='08'
				oSection1:Cell("CONSUMO_ATUAL"):SetValue(Alltrim(Transform(QRY->(CONSUMO_AGOSTO),PesqPict("SB3", "B3_Q08"))))
			Case cMesCor ='09'
				oSection1:Cell("CONSUMO_ATUAL"):SetValue(Alltrim(Transform(QRY->(CONSUMO_SETEMBRO),PesqPict("SB3", "B3_Q09"))))
			Case cMesCor ='10'
				oSection1:Cell("CONSUMO_ATUAL"):SetValue(Alltrim(Transform(QRY->(CONSUMO_OUTUBRO),PesqPict("SB3", "B3_Q10"))))
			Case cMesCor ='11'
				oSection1:Cell("CONSUMO_ATUAL"):SetValue(Alltrim(Transform(QRY->(CONSUMO_NOVEMBRO),PesqPict("SB3", "B3_Q11"))))
			Case cMesCor ='12'
				oSection1:Cell("CONSUMO_ATUAL"):SetValue(Alltrim(Transform(QRY->(CONSUMO_DEZEMBRO),PesqPict("SB3", "B3_Q12"))))
		EndCase
		oSection1:Cell("FORNECEDOR"):SetValue(Alltrim(QRY->(FORNECEDOR)))
   		
   		oSection1:PrintLine()
   		
   		QRY->(DbSkip())
	EndDo
	
	oSection1:Finish() 
		
	QRY->(DbCloseArea())
	
	RestArea(aArea)

Return

Static Function AjustaSx1(cPerg)

Local aArea := GetArea()
Local aRegs
Local i, j

DbSelectArea("SX1")
SX1->(dbSetOrder(1))
cPerg := Padr(cPerg,10)

aRegs := {}

aAdd(aRegs,	{cPerg, "01", "Emissão De ?" 		, "","", "mv_ch1", "D", 08, 0, 0, "G", "", "mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,	{cPerg, "02", "Emissão Até ?"		, "","", "mv_ch2", "D", 08, 0, 0, "G", "", "mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})

aAdd(aRegs,	{cPerg, "03", "Fornecedor De ?" 	, "","", "mv_ch3", "C", 06, 0, 0, "G", "", "mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,	{cPerg, "04", "Fornecedor Até ?"	, "","", "mv_ch4", "C", 06, 0, 0, "G", "", "mv_par04","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})

aAdd(aRegs,	{cPerg, "05", "Loja De ?" 			, "","", "mv_ch5", "C", 02, 0, 0, "G", "", "mv_par05","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,	{cPerg, "06", "Loja Até ?"			, "","", "mv_ch6", "C", 02, 0, 0, "G", "", "mv_par06","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})

For i:= 1 to Len(aRegs)
	If !DbSeek(cPerg + aRegs[i,2])
		RecLock("SX1", .T.)
		For j:= 1 to fCount()
			FieldPut(j, aRegs[i,j])
		Next j
		MsUnlock()
		DbCommit()	
	EndIf
Next i

RestArea(aArea)	
			   	
Return Nil                                                                 
	
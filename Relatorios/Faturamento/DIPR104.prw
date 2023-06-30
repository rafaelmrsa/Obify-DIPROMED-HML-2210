#include 'protheus.ch'
#include 'parmtype.ch'
#include "report.ch"
#include "topconn.ch"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ DIPR104	 ³ Autor ³ Vinicius Leonardo   ³ Data ³ 05/06/18  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Relatório de NF			             					   ±±
±±³          ³                                  						   ±±                                                                                                                     ±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ HEALTH QUALITY	                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
user function DIPR104()

If FindFunction("TRepInUse") 
	IMPREL()
EndIf

Return
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ DIPR104	 ³ Autor ³ Vinicius Leonardo   ³ Data ³ 05/06/18  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Relatório de NF			               					   ±±
±±³          ³                                  						   ±±                                                                                                                     ±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ HEALTH QUALITY	                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function IMPREL()	
	Local oReport 	:= NIL
	Local cPerg 	:= "DIPR104"
	    
	AjustaSx1(cPerg)	
	If Pergunte(cPerg,.T.)			
   		oReport := ReportDef(cPerg)
   		oReport:PrintDialog()			
	EndIf	
		
Return
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ DIPR104	 ³ Autor ³ Vinicius Leonardo   ³ Data ³ 05/06/18  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Relatório de NF			               					   ±±
±±³          ³                                  						   ±±                                                                                                                     ±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ HEALTH QUALITY	                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ReportDef(clPerg)

	Local oReport	:= Nil
	Local oSection1	:= Nil
	Local oBreak1	:= Nil
	
	oReport := TReport():New("DIPR104","Relatório de NF",clPerg,{|oReport| PrintReport(oReport)},"Relatório de NF") 
	 
	oReport:SetTotalInLine(.F.)
	oReport:lParamPage := .F.
	oReport:oPage:SetPaperSize(9)  
	oReport:SetLandscape()
	  
  	oSection1 := TRSection():New(oReport ,"Agrupador",{"QRY"})
  	
  	oSection1:SetTotalInLine(.F.)
  	
  	TRCell():New(oSection1, "NOTA_FISCAL"	, "QRY", "NOTA FISCAL"	,,10,,,,,,,,,,,)
  	TRCell():New(oSection1, "EMISSAO"		, "QRY", "EMISSAO"		,,10,,,,,,,,,,,) 
  	TRCell():New(oSection1, "CHAVE_NFE"		, "QRY", "CHAVE NFE"	,,20,,,,,,,,,,,)
  	TRCell():New(oSection1, "TIPO"			, "QRY", "TIPO"			,,10,,,,,,,,,,,)
  	TRCell():New(oSection1, "OBSERVACAO"	, "QRY", "OBSERVACAO"	,,20,,,,,,,,,,,)
  	TRCell():New(oSection1, "OBS_DA_NOTA"	, "QRY", "OBS_DA_NOTA"	,,20,,,,,,,,,,,)  	
  	  
  	oBreak1 := TRBreak():New(oSection1,{|| QRY->(F3_FILIAL) },{|| })  	
  	oSection1:SetHeaderBreak(.T.)
  	
Return oReport
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ DIPR104	 ³ Autor ³ Vinicius Leonardo   ³ Data ³ 05/06/18  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Relatório de NF			               					   ±±
±±³          ³                                  						   ±±                                                                                                                     ±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ HEALTH QUALITY	                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
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
	
	oSection1 := oReport:Section(1) 
	
	cQuery := " SELECT DISTINCT F3_FILIAL, F3_NFISCAL 'NOTA_FISCAL', F3_ENTRADA EMISSAO, F3_CHVNFE 'CHAVE_NFE', " + CRLF 
	cQuery += " (CASE WHEN F3_CFO > '5000' THEN 'SAÍDA' ELSE 'ENTRADA' END) TIPO,F3_OBSERV OBSERVACAO, " + CRLF 
	cQuery += " (CASE WHEN F3_CFO > '5000' THEN '' ELSE " + CRLF 
	cQuery += " (SELECT F1_OBS FROM SF1040 WHERE F1_DOC = F3_NFISCAL AND F1_SERIE = F3_SERIE AND F1_DTDIGIT = F3_ENTRADA " + CRLF 
	cQuery += " AND F1_FORNECE = F3_CLIEFOR AND F1_FILIAL = F3_FILIAL AND D_E_L_E_T_ = '') END) 'OBS_DA_NOTA' " + CRLF
	cQuery += " FROM " + RetSqlName("SF3") + CRLF
	cQuery += " WHERE LEFT(F3_ENTRADA,6) = '" + SubStr(DTOS(mv_par01),1,6) + "' " + CRLF
	cQuery += " AND D_E_L_E_T_ <> '*' " + CRLF
	cQuery += " AND F3_FILIAL = '" + xFilial("SF3") + "' " + CRLF
	cQuery += " AND F3_SERIE = '" + mv_par02 + "' " + CRLF
	cQuery += " ORDER BY F3_NFISCAL " + CRLF
	
	Conout(cQuery)
	
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
   		
   		oSection1:Cell("NOTA_FISCAL"):SetValue(Alltrim(QRY->(NOTA_FISCAL)))
		oSection1:Cell("EMISSAO"):SetValue(Alltrim(DTOC(STOD(QRY->(EMISSAO)))))
		oSection1:Cell("CHAVE_NFE"):SetValue(Alltrim(QRY->(CHAVE_NFE)))
		oSection1:Cell("TIPO"):SetValue(Alltrim(QRY->(TIPO)))
		oSection1:Cell("OBSERVACAO"):SetValue(Alltrim(QRY->(OBSERVACAO)))
		oSection1:Cell("OBS_DA_NOTA"):SetValue(Alltrim(QRY->(OBS_DA_NOTA)))
   		
   		oSection1:PrintLine()
   		
   		QRY->(DbSkip())
	EndDo
	
	oSection1:Finish() 
		
	QRY->(DbCloseArea())
	
	RestArea(aArea)

Return
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ DIPR104	 ³ Autor ³ Vinicius Leonardo   ³ Data ³ 05/06/18  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Relatório de NF			               					   ±±
±±³          ³                                  						   ±±                                                                                                                     ±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ HEALTH QUALITY	                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function AjustaSx1(cPerg)

Local aArea := GetArea()
Local aRegs
Local i, j

DbSelectArea("SX1")
SX1->(dbSetOrder(1))
cPerg := Padr(cPerg,10)

aRegs := {}

aAdd(aRegs,	{cPerg, "01", "Dt. Emissão ?" 	, "","", "mv_ch1", "D", 08, 0, 0, "G", "", "mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,	{cPerg, "02", "Série NF ?"		, "","", "mv_ch2", "C", 03, 0, 0, "G", "", "mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})

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
	
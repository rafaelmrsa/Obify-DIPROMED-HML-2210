#include 'protheus.ch'
#include 'parmtype.ch'
#include "report.ch"
#include "topconn.ch"

user function DIPR010A()

If FindFunction("TRepInUse") 
	IMPREL()
EndIf

Return

Static Function IMPREL()	
	Local oReport 	:= NIL
	Local cPerg 	:= "DIPR010A"
	    
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
	
	oReport := TReport():New("DIPR010A","Relatório de Itens de NF Saída",clPerg,{|oReport| PrintReport(oReport)},"Relatório de Itens de NF Saída") 
	 
	oReport:SetTotalInLine(.F.)
	oReport:lParamPage := .F.
	oReport:oPage:SetPaperSize(9)  
	oReport:SetLandscape()
	  
  	oSection1 := TRSection():New(oReport ,"Agrupador",{"QRY"})
  	
  	oSection1:SetTotalInLine(.F.)
  	
  	TRCell():New(oSection1, "EMISSAO"			, "QRY", "EMISSAO"				,,8,,,,,,,,,,,) 
  	TRCell():New(oSection1, "PRODUTO"			, "QRY", "PRODUTO"				,,6,,,,,,,,,,,)
  	TRCell():New(oSection1, "DESCRITIVO"		, "QRY", "DESCRITIVO"			,,30,,,,,,,,,,,)
  	TRCell():New(oSection1, "UNIDADE_DE_MEDIDA"	, "QRY", "UNIDADE_DE_MEDIDA"	,,2,,,,,,,,,,,)
  	TRCell():New(oSection1, "QUANTIDADE"		, "QRY", "QUANTIDADE"			,,30,,,,,,,,,,,)  	
  	TRCell():New(oSection1, "PRECO_TOTAL"		, "QRY", "PREÇO TOTAL"			,,30,,,,,,,,,,,)	
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
	
	oSection1 := oReport:Section(1) 	
	
	cQuery := "	select " + CRLF 
	cQuery +=  " 		D2_EMISSAO EMISSAO, LEFT(D2_COD,6) PRODUTO,  " + CRLF
	cQuery +=  " 		B1_DESC DESCRITIVO, " + CRLF 
	cQuery +=  " 		B1_UM UNIDADE_DE_MEDIDA, " + CRLF
	cQuery +=  " 		SUM(D2_QUANT) QUANTIDADE, " + CRLF
	cQuery +=  " 		SUM(D2_TOTAL) 'PRECO_TOTAL', " + CRLF
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

	cQuery +=  "     GROUP BY D2_EMISSAO, D2_COD, B1_DESC, B1_UM, D2_FORNEC, A2_NOME " + CRLF
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
   		  
		oSection1:Cell("EMISSAO"):SetValue(Alltrim(DTOC(STOD(QRY->(EMISSAO)))))
		oSection1:Cell("PRODUTO"):SetValue(Alltrim(QRY->(PRODUTO)))
		oSection1:Cell("DESCRITIVO"):SetValue(Alltrim(QRY->(DESCRITIVO)))
		oSection1:Cell("UNIDADE_DE_MEDIDA"):SetValue(Alltrim(QRY->(UNIDADE_DE_MEDIDA)))		
		oSection1:Cell("QUANTIDADE"):SetValue(Alltrim(Transform(QRY->(QUANTIDADE),PesqPict("SD2", "D2_QUANT"))))
		oSection1:Cell("PRECO_TOTAL"):SetValue(Alltrim(Transform(QRY->(PRECO_TOTAL),PesqPict("SD2", "D2_TOTAL"))))
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
	
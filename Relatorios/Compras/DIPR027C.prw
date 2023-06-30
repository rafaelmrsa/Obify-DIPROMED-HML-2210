#include 'protheus.ch'
#include 'parmtype.ch'

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Funcao    ³ DIPR027C ³ Autor ³ Gabriel Veríssimo  ³ Data ³ 08/11/2019  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Relacao de pedidos de compra livro caixa			          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ DIPR027C                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Especifico DIPROMED                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function DIPR027C()

	Local aPergs	:= {}
	Private oReport
	Private aRet	:= {}
	
	aAdd(aPergs, {1, "Vencimento De"	, Space(14)	, "99/99/9999"	, "", "", "", 50, .T.})
	aAdd(aPergs, {1, "Vencimento Até"	, Space(14)	, "99/99/9999"	, "", "", "", 50, .T.})
	aAdd(aPergs, {1, "Filial De"		, Space(2)	, "@!"			, "", "", "", 50, .T.})
	aAdd(aPergs, {1, "Filial Até"		, Space(2)	, "@!"			, "", "", "", 50, .T.})

	If ParamBox(aPergs, "Parametros", aRet)
		Processa({|lEnd| ImpRel()}, "Aguarde...", "Gerando arquivo...", .T.)
	Else
		Return .F.
	EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Funcao    ³ ImpRel   ³ Autor ³ Gabriel Veríssimo  ³ Data ³ 08/11/2019  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Impressão do relatório							          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ImpRel	                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Especifico DIPROMED                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function ImpRel()

	Local cTitulo := ""
	Private oSection1
	Private oBreak
	Private oFunction

	cTitulo := "Pedidos de Compra / Livro Caixa"
	oReport := TReport():New("DIPR027C", cTitulo, "", {|oReport| ReportPrint(oReport)}, "Gera relatório de Pedidos de Compra / Livro Caixa.")
	oReport:SetPortrait()
	oReport:SetTotalInLine(.F.)

	oSection1 := TRSection():New(oReport, "Cabec", {"SC7"}, /*aOrder*/, .F., .T., /*uTotalText*/, /*lTotalInLine*/, .F., .F., .F.,, 2)
	oSection2 := TRSection():New(oReport, "Itens", {"SC7"}, /*aOrder*/, .F., .T., /*uTotalText*/, /*lTotalInLine*/, .F., .F., .F.,, 2, /*lLineStyle*/, 5/*nColSpace*/)

	TRCell():New(oSection1, "C7_EMISSAO", "SC7", "Emissão" 		,/*Picture*/, 7,,,,,,, 1.5, .T.)
	TRCell():New(oSection1, "C7_DENTREG", "SC7", "Prv. Entreg." ,/*Picture*/, 7,,,,,,, 1.5, .T.)
	TRCell():New(oSection1, "C7_FORNECE", "SC7", "Fornecedor" 	,/*Picture*/, 7,,,,,,, 1.5, .T.)
	TRCell():New(oSection1, "C7_NUM"	, "SC7", "Pedido" 		,/*Picture*/, 7,,,,,,, 1.5, .T.)
	TRCell():New(oSection1, "C7_COND"	, "SC7", "Condição" 	,/*Picture*/, 7,,,,,,, 1.5, .T.)
	TRCell():New(oSection1, "VENC"		, "SC7", "Vencimento" 	,PesqPict("SC7", "C7_EMISSAO"), 7,,,,,,, 1.5, .T.)
	TRCell():New(oSection1, "VALOR"		, "SC7", "Valor"	 	,PesqPict("SC7", "C7_TOTAL"),,,, /*"LEFT"*/,,,,, .T.)
	
	oBreak := TRBreak():New(oSection1, oSection1:Cell("VENC"), "Total", .F.,,.F.)

	oReport:PrintDialog()

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Funcao   ³ ReportPrint ³ Autor ³ Gabriel Veríssimo ³ Data ³ 08/11/2019 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Impressão do relatório							          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ImpRel	                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Especifico DIPROMED                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function ReportPrint(oReport)

	Local nReg			:= 0
	Local dDataDe		:= CtoD(AllTrim(aRet[1]))
	Local dDataAte		:= CtoD(AllTrim(aRet[2]))
	Local cQuery		:= ""
	Local dData			:= ""
	Local nValTot		:= 0
	Local aDados		:= {}

	If Select("TRB") > 0
		TRB->(DbCloseArea())
	EndIf

	cQuery += "SELECT C7_FILIAL,												"
	cQuery += " 	  C7_NUM,													"
	cQuery += " 	  C7_EMISSAO,												"
	cQuery += " 	  C7_FORNECE,												"
	cQuery += " 	  C7_LOJA,													"
	cQuery += " 	  C7_COND,													"
	cQuery += " 	  E4_DESCRI,												"
	cQuery += " 	  C7_DENTREG,												"												
	cQuery += " 	  C7_XDATA1,												"												
	cQuery += " 	  C7_XPARC1,												"												
	cQuery += " 	  C7_XDATA2,												"												
	cQuery += " 	  C7_XPARC2,												"												
	cQuery += " 	  C7_XDATA3,												"												
	cQuery += " 	  C7_XPARC3,												"												
	cQuery += " 	  C7_XDATA4,												"
	cQuery += " 	  C7_XPARC4													"
	cQuery += " FROM " + RetSQLName("SC7") + " SC7 								"
	cQuery += "	LEFT JOIN " + RetSQLName("SE4") + " SE4							"
	cQuery += "  ON E4_CODIGO = C7_COND											"
	cQuery += "  AND SE4.D_E_L_E_T_ = ''										"
	cQuery += " WHERE C7_FILIAL >= '" + aRet[3] + "' 							"
	cQuery += "	 AND C7_FILIAL <= '" + aRet[4] + "' 							"
	cQuery += "	 AND SC7.D_E_L_E_T_ = '' 										"
	cQuery += "  AND C7_QUJE < C7_QUANT 										"
	cQuery += "  AND C7_RESIDUO <> 'S' 											"
	cQuery += "  AND C7_FLUXO   <> 'N'											"
	cQuery += "  AND ((C7_XDATA1 >= '" + DtoS(dDataDe) + "' AND C7_XDATA1 <= '" + DtoS(dDataAte) + "') 	"
	cQuery += "  OR (C7_XDATA2 >= '" + DtoS(dDataDe) + "' AND C7_XDATA2 <= '" + DtoS(dDataAte) + "') 	"
	cQuery += "  OR (C7_XDATA3 >= '" + DtoS(dDataDe) + "' AND C7_XDATA3 <= '" + DtoS(dDataAte) + "') 	"
	cQuery += "  OR (C7_XDATA4 >= '" + DtoS(dDataDe) + "' AND C7_XDATA4 <= '" + DtoS(dDataAte) + "') 	"
	cQuery += "  OR (C7_DENTREG >= '" + DtoS(dDataDe) + "' AND C7_DENTREG <= '" + DtoS(dDataAte) + "'))	"
	cQuery += " GROUP BY C7_FILIAL,												"
	cQuery += " 		 C7_NUM,												"
	cQuery += " 		 C7_EMISSAO,											"
	cQuery += " 		 C7_FORNECE,											"
	cQuery += " 	     C7_LOJA,												"
	cQuery += " 		 C7_COND,												"
	cQuery += " 		 E4_DESCRI,												"
	cQuery += " 		 C7_DENTREG,											"
	cQuery += " 		 C7_XDATA1,												"
	cQuery += " 		 C7_XPARC1,												"
	cQuery += " 		 C7_XDATA2,												"
	cQuery += " 		 C7_XPARC2,												"
	cQuery += " 		 C7_XDATA3,												"
	cQuery += "			 C7_XPARC3,												"
	cQuery += "			 C7_XDATA4,												"												"
	cQuery += "			 C7_XPARC4												"
	cQuery += " ORDER BY C7_DENTREG, C7_XDATA1, C7_XDATA2, C7_XDATA3, C7_XDATA4	"

	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T., "TOPCONN", TcGenQry(,, cQuery), "TRB", .F., .T.)

	TRB->(DbGoTop())
	While !TRB->(EoF())
		nReg++ //Contador para determinar a quantidade de registros da query
		TRB->(DbSkip())
	End

	oReport:SetMeter(nReg) //Define total da régua de progressão

	TRB->(DbGotop())
	oSection1:Init()
	While !TRB->(EoF())
		If oReport:Cancel()
			Exit
		EndIf

		cFilPed		:= TRB->C7_FILIAL
		cNumPed		:= TRB->C7_NUM
		nValTot		:= 0

		While !TRB->(EoF()) .And. cFilPed == TRB->C7_FILIAL .And. TRB->C7_NUM == cNumPed
			If !Empty(TRB->C7_XDATA1)
				If TRB->C7_XDATA1 >= DtoS(dDataDe) .And. TRB->C7_XDATA1 <= DtoS(dDataAte)
					dData := STOD(TRB->C7_XDATA1)
					nValTot := TRB->C7_XPARC1
					aAdd(aDados, {TRB->C7_EMISSAO, TRB->C7_DENTREG, TRB->C7_FORNECE, TRB->C7_NUM, TRB->C7_COND, TRB->E4_DESCRI, dData, nValTot})
				EndIf
			EndIf
			
			If !Empty(TRB->C7_XDATA2)
				If TRB->C7_XDATA2 >= DtoS(dDataDe) .And. TRB->C7_XDATA2 <= DtoS(dDataAte)
					dData := STOD(TRB->C7_XDATA2)
					nValTot := TRB->C7_XPARC2
					aAdd(aDados, {TRB->C7_EMISSAO, TRB->C7_DENTREG, TRB->C7_FORNECE, TRB->C7_NUM, TRB->C7_COND, TRB->E4_DESCRI, dData, nValTot})
				EndIf
			EndIf
			
			If !Empty(TRB->C7_XDATA3)
				If TRB->C7_XDATA3 >= DtoS(dDataDe) .And. TRB->C7_XDATA3 <= DtoS(dDataAte)
					dData := STOD(TRB->C7_XDATA3)
					nValTot := TRB->C7_XPARC3
					aAdd(aDados, {TRB->C7_EMISSAO, TRB->C7_DENTREG, TRB->C7_FORNECE, TRB->C7_NUM, TRB->C7_COND, TRB->E4_DESCRI, dData, nValTot})
				EndIf
			EndIf
			
			If !Empty(TRB->C7_XDATA4)
				If TRB->C7_XDATA4 >= DtoS(dDataDe) .And. TRB->C7_XDATA4 <= DtoS(dDataAte)
					dData := STOD(TRB->C7_XDATA4)
					nValTot := TRB->C7_XPARC4
					aAdd(aDados, {TRB->C7_EMISSAO, TRB->C7_DENTREG, TRB->C7_FORNECE, TRB->C7_NUM, TRB->C7_COND, TRB->E4_DESCRI, dData, nValTot})
				EndIf
			EndIf
			
			//Realizar tratamento idêntico ao fonte padrão F020Compra - utilizar função Condicao() e trabalhar com
			//o seu retorno
			//aVenc := Condicao(nValTot, cCond, nValIpi (BASE IPI * C7_IPI), dData)
			If Empty(TRB->C7_XDATA1) .And. Empty(TRB->C7_XDATA2) .And. Empty(TRB->C7_XDATA3) .And. Empty(TRB->C7_XDATA4)
				dData := TRB->C7_DENTREG
				aRetSC7 := GetSC7(TRB->C7_FILIAL, TRB->C7_NUM)
				aVenc := Condicao(aRetSC7[1][1], aRetSC7[1][2], aRetSC7[1][3], StoD(dData))
				//aAdd(aDados, {TRB->C7_EMISSAO, TRB->C7_DENTREG, TRB->C7_FORNECE, TRB->C7_NUM, TRB->C7_COND, TRB->E4_DESCRI, dData, nValTot})
				For nX := 1 To Len(aVenc)
					aAdd(aDados, {TRB->C7_EMISSAO, TRB->C7_DENTREG, TRB->C7_FORNECE, TRB->C7_NUM, TRB->C7_COND, TRB->E4_DESCRI, aVenc[nX][1], aVenc[nX][2]})
				Next
			EndIf
			
			TRB->(DbSkip())
		End
		oReport:IncMeter()
	End
	aSort(aDados,,,{|x, y| DtoS(x[7]) + x[4] < DtoS(y[7]) + y[4]})
	oFunction := TRFunction():New(oSection1:Cell("VALOR"), Nil, "SUM", oBreak, /*cTitle*/, PesqPict("SC7", "C7_TOTAL"), /*uFormula*/, .F., .T.)
	oSection1:Cell("VALOR"):SetHeaderAlign("RIGHT")
	For nI := 1 To Len(aDados)
		oBreak:SetTitle("Total " + DtoC(aDados[nI][7]))
		oSection1:Cell("C7_EMISSAO"):SetValue(StoD(aDados[nI][1]))
		oSection1:Cell("C7_DENTREG"):SetValue(StoD(aDados[nI][2]))
		oSection1:Cell("C7_FORNECE"):SetValue(aDados[nI][3] + " - " + Posicione("SA2", 1, xFilial("SA2") + aDados[nI][3], "A2_NREDUZ"))
		oSection1:Cell("C7_NUM"):SetValue(aDados[nI][4])
		oSection1:Cell("C7_COND"):SetValue(aDados[nI][5] + " - " + aDados[nI][6])
		//oSection1:Cell("VENC"):SetValue(StoD(aDados[nI][7]))
		oSection1:Cell("VENC"):SetValue(aDados[nI][7])
		oSection1:Cell("VALOR"):SetValue(aDados[nI][8])
		oSection1:PrintLine()
	Next

	oSection1:Finish()

	If Select("TRB") > 0
		TRB->(DbCloseArea())
	EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Funcao    ³ GetTotal ³ Autor ³ Gabriel Veríssimo ³ Data ³ 08/11/2019   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Retorna saldo do pedido informado				          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ GetTotal	                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Especifico DIPROMED                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function GetSC7(cFilPed, cNumPed)

	Local aArea		:= GetArea()
	Local aAreaSC7	:= SC7->(GetArea())
	Local nVlr 		:= 0
	Local nIpi		:= 0
	Local cCond		:= ""
	Local nMoeda	:= 1
	Local aRet		:= {}
	Local nTotDesc, nDespFrete, nPrcCompra, nValTot, nValIPILiq, nBaseIPI, nValIPI := 0
	Local nTotSC7 := 0
	Local nIpiSC7 := 0
	
	SC7->(DbSetOrder(1)) //C7_FILIAL+C7_NUM
	If SC7->(DbSeek(cFilPed + cNumPed))
		cCond := SC7->C7_COND
		While !SC7->(EoF()) .And. SC7->C7_FILIAL + SC7->C7_NUM == cFilPed + cNumPed
			nTotDesc	:= SC7->C7_VLDESC
			nPrcCompra 	:= SC7->C7_PRECO
			nDespFrete 	:= SC7->C7_VALFRE + SC7->C7_SEGURO + SC7->C7_DESPESA
			nValTot		:= ((SC7->C7_QUANT-SC7->C7_QUJE) * nPrcCompra ) + nDespFrete
			nValIPILiq  := nValTot
			If nTotDesc == 0
				nTotDesc := CalcDesc(nValTot,SC7->C7_DESC1,SC7->C7_DESC2,SC7->C7_DESC3)
			Else
				nTotDesc := ((SC7->C7_VLDESC * nValTot)/SC7->C7_TOTAL)
			EndIf
			nValTot	  := nValTot - nTotDesc
			If SC7->C7_IPI > 0
				If SC7->C7_IPIBRUT != "L"
					nBaseIPI := nValTot
				Else
					nBaseIPI := nValIPILiq
				EndIf
				nValIPI := IIf(nBaseIPI = 0, 0, nBaseIPI * SC7->C7_IPI / 100)
			EndIf
			nValTot  += nValIPI
			//Variáveis que serão passadas como retorno
			nTotSC7 += nValTot
			nIpiSC7 += nValIpi
			SC7->(DbSkip())
		End
	EndIf
	
	AAdd(aRet, {nTotSC7, cCond, nIpiSC7})
	
	RestArea(aAreaSC7)
	RestArea(aArea)
	
Return aRet
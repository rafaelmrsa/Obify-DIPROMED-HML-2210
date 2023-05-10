#INCLUDE 'PROTHEUS.ch'
#INCLUDE 'TOTVS.ch'


User Function TME80IMP()

	Local aArea		:= GetArea()
	Local aAreaDTC	:= DTC->(GetArea())
	Local aAreaDTP	:= DTP->(GetArea())	
	Local aAreaSA1	:= SA1->(GetArea())	
	Local oXml   	:= PARAMIXB[1]	//	Objeto contendo a estrutura do arquivo XML da nota
	Local aHeadDE5  := PARAMIXB[2]	// 	Array contendo cabeçalho das notas (aHeader)
	Local nOpcx     := PARAMIXB[3]	//	Operação que esta sendo executada (nOpcx)
	Local aColsDE5  := PARAMIXB[4]	//	Array contendo Itens das notas (aCols)
	Local cPosic    := PARAMIXB[5]	// 	Posição para identificar se 1º ou o º PE que esta sendo executado.
	Local nNumDet	:= 0
	Local cDetalhe	:= ""
	Local cMotivo	:= ""
	Local cFile		:= ""
	Local lRet      := .T.

	Public oXmlDE5  := PARAMIXB[1]

	If cPosic == '2'

		cCGCRem	:= aHeadDE5[Ascan(aHeadDE5,{|x| x[1] == "DE5_CGCREM"})][2]
		cNFiscal:= aHeadDE5[Ascan(aHeadDE5,{|x| x[1] == "DE5_DOC"})][2]
		cSerie	:= aHeadDE5[Ascan(aHeadDE5,{|x| x[1] == "DE5_SERIE"})][2]
		cChvNfe	:= aHeadDE5[Ascan(aHeadDE5,{|x| x[1] == "DE5_NFEID"})][2]


		SA1->(dbSetOrder(3))
		If SA1->(MsSeek(xFilial("SA1") + cCGCRem))

			cCliRem := SA1->A1_COD
			cLojRem := SA1->A1_LOJA

			DTC->(DbSetOrder(5))	// DTC_FILIAL+DTC_CLIREM+DTC_LOJREM+DTC_NUMNFC+DTC_SERNFC
			If DTC->(DbSeek(xFilial("DTC") + cCliRem + cLojRem + cNFiscal + cSerie ) )

				nNumDet 	+= 1
				cDetalhe += "ID de NF-e já registrado na tabela DTC  "
				cMotivo  := "NF Ja Importada (DTC): " + cCGCRem +"/"+ cNFiscal +"-"+ cSerie
				lRet 		:= .F.

				TMSAE80GRV(cFile,cChvNfe,cNFiscal,cSerie,cCGCRem,cMotivo,cDetalhe)
			EndIf
		EndIf

	EndIf

	RestArea(aAreaDTC)
	RestArea(aAreaDTP)
	RestArea(aAreaSA1)
	RestArea(aArea)

Return lRet
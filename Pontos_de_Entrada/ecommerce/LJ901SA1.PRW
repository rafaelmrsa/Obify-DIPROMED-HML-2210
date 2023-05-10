/*/
**************************************************************************************
BRUNO COELHO
09-MAI-2018
ÁPIA CONSULTORIA E SISTEMAS

Executado uma única vez, somente na inclusão do cliente no Protheus

PARAMIXB É ARRAY VINDO DOS FONTES: LOJA901 (Compradores), e LOJA901A (Pedidos)
1-nOrigem   Numérico    Indicativo da rotina em execução, onde: 1 - LOJA901 - Compradores ou 2-  LOJA901A - Geração de Cliente com Endereço de Entrega
2-aCli      Array       Array dos Campos a serem inseridos pela rotina automática
3-oAComp    Objeto      Objeto XML do Comprador, caso a origem seja 1
4-oAPed     Objeto      Objeto do XML do Pedido de Venda, caso a origem seja 2

Referência
http://tdn.totvs.com/display/public/PROT/DT_LJ901SA1_Integracao_e-Commerce_CiaShop

***************************************************************************************/
#Include 'Protheus.ch'
User Function LJ901SA1()

	Local aArea := GetArea()
	//Variaveis para os parametros do Ponto de Entrada
	Local nOrigem := 0      //1-LOJA901 (Compradores), 2-LOJA901A (Pedido Venda)
	Local aCli    := {}       //array que será retornado no final
	Local oAPed   := Nil      //XML Pedido Venda (se nOrigem 2)
	Local nPos1   := 0
	Local cMunic  := ""
	Local cDDD    := ""
	//Local l_sCodProd := ""

	If ValType(PARAMIXB) == "A";
	.AND. Len(PARAMIXB) >= 4;
	.AND. ValType(PARAMIXB[1]) == "N";
	.AND. ValType(PARAMIXB[2]) == "A"

		nPos1 := AScan(PARAMIXB[2], {|x| AllTrim(Upper(x[1])) == "A1_CGC"})
		SA1->(dbSetOrder(3))
		If SA1->(DBSeek(xFilial("SA1") +ALLTRIM(PARAMIXB[2][nPos1][2])))
			PARAMIXB[2] := aCli
			Return aCli
		EndIf

		nOrigem := PARAMIXB[1]
		aCli    := AClone(PARAMIXB[2])

		//If nOrigem == 1 .AND. ValType(PARAMIXB[3]) == "O" // Tratar somente quando vier do pedido, pois é aqui que existe o código do produto

		If nOrigem == 1
			oAPed  := PARAMIXB[3]
			cMunic := upper(oAped:_cidade:text)
		else
			oAPed  := PARAMIXB[4]
			cMunic := upper(oAPed:_RECEIPT_BILLING:_CITY:text)
		EndIf

		nPos1 := AScan(aCli, {|x| AllTrim(Upper(x[1])) == "A1_CEP"}) // Econtrar campo CEP
		If nPos1 > 0
			aAdd(aCli, {"A1_CEPC", aCli[nPos1,2] , Nil}) // CEP de cobrança cliente
			aAdd(aCli, {"A1_CEPE", aCli[nPos1,2] , Nil}) // CEP de entrega cliente
		EndIf

		nPos1 := AScan(aCli, {|x| AllTrim(Upper(x[1])) == "A1_END"}) // Encontrar campo endereço
		If nPos1 > 0

			aCli[nPos1,2] := FwNoAccent(aCli[nPos1,2])

			aAdd(aCli, {"A1_ENDCOB", Substr(aCli[nPos1,2],1,40), Nil}) // End.de cobrança do cliente
			aAdd(aCli, {"A1_ENDENT", aCli[nPos1,2] , Nil}) // End.de entrega do cliente
		EndIf

		nPos1 := AScan(aCli, {|x| AllTrim(Upper(x[1])) == "A1_BAIRRO"}) // Encontrar campo bairro
		If nPos1 > 0
			aAdd(aCli, {"A1_BAIRROC", aCli[nPos1,2] , Nil}) // Bairro de cobrança do cliente
			aAdd(aCli, {"A1_BAIRROE", aCli[nPos1,2] , Nil}) // Bairro de entrega do cliente
		EndIf

		If ValType(oAPed)  == "O"
			AAdd(aCli, {"A1_MUNC", cMunic, Nil})
			AAdd(aCli, {"A1_MUNE", cMunic, Nil})
		EndIf

		nPos1 := AScan(aCli, {|x| AllTrim(Upper(x[1])) == "A1_EST"}) // Encontrar campo estado
		If nPos1 > 0
			AAdd(aCli, {"A1_ESTC", aCli[nPos1,2], Nil}) // Estado de cobranca
			AAdd(aCli, {"A1_ESTE", aCli[nPos1,2], Nil}) // Estado de entega
		EndIf

		nPos1 := AScan(aCli, {|x| AllTrim(Upper(x[1])) == "A1_DDD"}) // Encontrar campo DDD
		If nPos1 > 0
			cDDD := "0"+aCli[nPos1,2]
			aCli[nPos1,2] := cDDD
		EndIf

		aAdd(aCli, {"A1_VEND"   ,GetNewPar("MV_LJECOMA",""), Nil}) // Vendedor
		aAdd(aCli, {"A1_CONTATO", "CIASHOP"                , Nil}) // Contato
		aAdd(aCli, {"A1_CONTA"  , "112101001"              , Nil}) // Conta
		aAdd(aCli, {"A1_DTALTER", DATE()                   , Nil}) // Data da alteração
		aAdd(aCli, {"A1_SET_PLA", "1"                      , Nil}) // Set Plascalp
		aAdd(aCli, {"A1_SET_DIP", "01"                     , Nil}) // Set Dipromed
		aAdd(aCli, {"A1_CONTRIB", "2"                      , Nil}) // Contribuinte
		aAdd(aCli, {"A1_RISCO  ", "A"                      , Nil}) // Risco
		aAdd(aCli, {"A1_SATIV1 ", "6.1.01"                 , Nil}) // Segmento 1
		aAdd(aCli, {"A1_SATIV8 ", "999994"                 , Nil}) // Segmento area
		aAdd(aCli, {"A1_TIPCLI ", "1"                      , Nil}) // Tipo cliente
		aAdd(aCli, {"A1_ENVMALA",  "N"                     , Nil}) // Envia mala?

		//    EndIf
	EndIf

	RestArea(aArea)

Return aCli

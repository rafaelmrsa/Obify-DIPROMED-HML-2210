#INCLUDE "PROTHEUS.CH"
/*/
+---------------------------------------------------------------------------+
|  Programa  | DIPR066 |Autor  |Maximo Canuto          | Data |  13/01/09   |
+---------------------------------------------------------------------------+
|  Descricao | Emissão de fatura de Frete baseado no DT6                    |
+---------------------------------------------------------------------------+
|  Uso       | TMS / Financeiro                                             |
+---------------------------------------------------------------------------+

/*/

#include "rwmake.ch"
User Function DIPR066()

Local nPag      := 1
Local nTPag     := SE1->(FCount())
Local nLin      := 0
Local cQuery    := ""
Local cAliasQry := ""
Local cCodUsr   := RetCodUsr()

/*If cCodUsr != "000022" .And. cCodUsr != "000038" .And. cCodUsr != "000001"
	MsgAlert("Usuario nao autorizado")
	Return
EndIf*/

SetPrvt("DV_NNUM,DV_BARRA,CBARRA,LINEDIG,NFI,NFF")
SetPrvt("SERIE,BANCO,NUMBOLETA,NDIGITO,PEDACO,CHAVE")
SetPrvt("FATORVCTO,B_CAMPO,CHAVE,NCONT,CCAMPO,I")
SetPrvt("NVAL,DEZENA,RESTO,NCONT,CPESO,RESULT")
SetPrvt("ARQ,CGRUPO,PERG")
SetPrvt("TIT,DESC1,DESC2,DESC3,ORDEM")
SetPrvt("TAMANHO,FILTIMP,ARETURN,AINFO,NLASTKEY,CSTRING")
SetPrvt("WNREL,TELA,BANCO,SERIE,NFI,NFF")
SetPrvt("CSAVSCR1,CSAVCUR1,CSAVROW1,CSAVCOL1,CCAMPO,NDIGITO")
SetPrvt("NCONT,XI,NVAL,CPESO,RESTO,APERGUNTAS")
SetPrvt("NXZ,NXY,cgrupo,xrow,Nvia,Nnumero")

Private cObs1 := ""
Private cObs2 := ""
Private cVenc := ""

U_DIPPROC(ProcName(0),U_DipUsr()) // MCVN - 22/01/2009

M->DV_NNUM   := SPACE(1)
M->DV_BARRA  := SPACE(1)
M->cBARRA    := ""
M->LineDig   := ""
M->NumBoleta := ""
M->nDigito   := ""
M->Pedaco    := ""

//Paramentros de Impressao
M->NFi       := Space(6)
M->NFf       := Space(6)
M->Serie     := Space(3)
M->Banco     := Space(3)
M->Ag        := Space(5)
M->CC        := Space(10)

//Cadastro de Clientes
DbSelectArea("SA1")
DbSetOrder(1)

@ 00,00 TO 250,380 DIALOG oDlgX TITLE "Impressão Fatura de Frete"
@ 05,05 TO 120,185 TITLE " Parametros "

@ 20,008 SAY "Prefixo do Título"
@ 35,008 SAY "Título Inicial"
@ 50,008 SAY "Título Final"


@ 20,090 GET M->Serie  PICTURE "@!"         //VALID !Empty(M->Serie)
@ 35,090 GET M->NFi    PICTURE "@E 999999"  //VALID !Empty(M->NFi)
@ 50,090 GET M->NFf    PICTURE "@E 999999"  //VALID !Empty(M->NFf)


@ 100,100 BMPBUTTON TYPE 01 ACTION BoletaOK()
@ 100,140 BMPBUTTON TYPE 02 ACTION Close(oDlgX)

ACTIVATE  DIALOG oDlgX CENTER

Return


Static Function BoletaOK()

Local aDoc     := {}
Local nCont    := 0
Local aDig     := {}
Local nSoma    := 0
Local nResto   := 0
Local nDigNum  := 0
Local nDig2    := 0
Local cLogoFAT := "emovere.bmp"
Local nCol     := "A"
Local nCnt2    := 0  
Local nBoxVIni := 1150
Local nBoxVFim := 1200
Local nConV    := 1100    
//Local nLimite  := 133//Giovani Zago 11/11/11
Local nLimite  := 43//Andre Mendes - Obify 26/01/22
Local nPag     := 1

Local nTotNotas := 0 // Andre Mendes - Obify 02/02/22


Close(oDlgX)

//Titulos dos Campos
oFont1 :=     TFont():New("Arial"      		,09,08,,.F.,,,,,.F.)
//Conteudo dos Campos
oFont2 :=     TFont():New("Arial"      		,09,10,,.F.,,,,,.F.)
//Nome do Banco
oFont3Bold := TFont():New("Arial Black"		,09,16,,.T.,,,,,.F.)
//Dados do Recibo de Entrega
oFont4 := 	  TFont():New("Arial"      		,09,12,,.T.,,,,,.F.)
//Codigo de Compensação do Banco
oFont5 := 	  TFont():New("Arial"      		,09,18,,.T.,,,,,.F.)
//Codigo de Compensação do Banco
oFont6 := 	  TFont():New("Arial"      	    ,09,14,,.T.,,,,,.F.)
//Conteudo dos Campos em Negrito
oFont7 := 	  TFont():New("Arial"           ,09,10,,.T.,,,,,.F.)
//Dados do Cliente
oFont8 := 	  TFont():New("Arial"           ,09,09,,.F.,,,,,.F.)
//Linha Digitavel
oFont9 := 	  TFont():New("Times New Roman" ,09,14,,.T.,,,,,.F.)

oPrn:=TAvPrinter():New()

//Cadastro de Contas a Receber
//Posicionar no titulo Incial do Paramentro
DbSelectArea("SE1")
DbSetOrder(1)
DbGoTop()
DbSeek(xFilial("SE1")+ M->Serie + M->NFi)

//--Verifica todos os CTRCs perterncentes a esta fatura
cAliasQry := GetNextAlias()
//cQuery := "SELECT DT6_DATEMI, DT6_DOC, DT6_VALTOT * DTC_PESO/ DT6_PESO AS DT6_VALTOT, DT6_DECRES, DTC_NUMNFC, DTC_VALOR, ROUND(DT6_VALTOT * DTC_PESO/ DT6_PESO / DTC_VALOR*100,2) AS PERC  "

cQuery := "SELECT DT6_DATEMI, DT6_DOC, DT6_VALTOT * DTC_VALOR/ (SELECT "
cQuery += "			SUM(DTC_02.DTC_VALOR)  "
cQuery += "	FROM  "
cQuery += "		"+RetSqlName("DTC")+ " DTC_02 "
cQuery += "	WHERE "
cQuery += "		DTC_02.DTC_FILIAL	= DT6.DT6_FILIAL	AND "
cQuery += "		DTC_02.DTC_FILORI	= DT6.DT6_FILORI	AND "
cQuery += "		DTC_02.DTC_LOTNFC	= DT6.DT6_LOTNFC	AND "
cQuery += "		DTC_02.DTC_FILDOC	= DT6.DT6_FILDOC	AND "
cQuery += "		DTC_02.DTC_DOC		= DT6.DT6_DOC		AND "
cQuery += "		DTC_02.DTC_SERIE	= DT6.DT6_SERIE		AND "
cQuery += "		DTC_02.D_E_L_E_T_	= '') AS DT6_VALTOT, DT6_DECRES, DTC_NUMNFC, DTC_VALOR, ROUND(DT6_VALTOT * DTC_VALOR/ (SELECT  "
cQuery += "			SUM(DTC_02.DTC_VALOR)  "
cQuery += "	FROM  "
cQuery += "		"+RetSqlName("DTC")+ " DTC_02 "
cQuery += "	WHERE "
cQuery += "		DTC_02.DTC_FILIAL	= DT6.DT6_FILIAL	AND "
cQuery += "		DTC_02.DTC_FILORI	= DT6.DT6_FILORI	AND "
cQuery += "		DTC_02.DTC_LOTNFC	= DT6.DT6_LOTNFC	AND "
cQuery += "		DTC_02.DTC_FILDOC	= DT6.DT6_FILDOC	AND "
cQuery += "		DTC_02.DTC_DOC		= DT6.DT6_DOC		AND "
cQuery += "		DTC_02.DTC_SERIE	= DT6.DT6_SERIE		AND "
cQuery += "		DTC_02.D_E_L_E_T_	= '') / DTC_VALOR*100,2) AS PERC , "
cQuery += "	(SELECT  "
cQuery += "			SUM(DTC_02.DTC_VALOR)  "
cQuery += "	FROM  "
cQuery += "		"+RetSqlName("DTC")+ " DTC_02 "
cQuery += "	WHERE "
cQuery += "		DTC_02.DTC_FILIAL	= DT6.DT6_FILIAL	AND "
cQuery += "		DTC_02.DTC_FILORI	= DT6.DT6_FILORI	AND "
cQuery += "		DTC_02.DTC_LOTNFC	= DT6.DT6_LOTNFC	AND "
cQuery += "		DTC_02.DTC_FILDOC	= DT6.DT6_FILDOC	AND "
cQuery += "		DTC_02.DTC_DOC		= DT6.DT6_DOC		AND "
cQuery += "		DTC_02.DTC_SERIE	= DT6.DT6_SERIE		AND "
cQuery += "		DTC_02.D_E_L_E_T_	= '') AS TOTAL "

cQuery += " FROM "+RetSqlName("DT6")+ " DT6 "
cQuery += "INNER JOIN "
cQuery += " "+RetSqlName("DTC")+ " DTC ON "
cQuery += "		DTC.DTC_FILIAL	= DT6.DT6_FILIAL	AND "
cQuery += "		DTC.DTC_FILORI	= DT6.DT6_FILORI	AND "
cQuery += "		DTC.DTC_LOTNFC	= DT6.DT6_LOTNFC	AND "
cQuery += "		DTC.DTC_FILDOC	= DT6.DT6_FILDOC	AND "
cQuery += "		DTC.DTC_DOC		= DT6.DT6_DOC		AND "
cQuery += "		DTC.DTC_SERIE	= DT6.DT6_SERIE		AND "
cQuery += "		DTC.D_E_L_E_T_	= '' "
cQuery += " WHERE DT6.DT6_FILIAL = '" +xFilial("DT6")+ "'"
cQuery += "  AND DT6.DT6_PREFIX  = '" +SE1->E1_PREFIXO+ "'"
cQuery += "  AND DT6.DT6_TIPO    = '" +SE1->E1_TIPO+ "'"
cQuery += "  AND DT6.DT6_NUM     = '" +SE1->E1_NUM+ "'"
cQuery += "  AND DT6.D_E_L_E_T_  = ' '"
cQuery += "  ORDER BY  DT6_DATEMI, DT6_DOC"	//Ordenando por emissão + doc MCVN - 18/06/10
cQuery := ChangeQuery(cQuery)
	
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry)

TcSetField(cAliasQry,"DT6_DATEMI","D",8,0)

While (cAliasQry)->(!Eof())
	Aadd(aDoc,{(cAliasQry)->DT6_DATEMI, (cAliasQry)->DT6_DOC, (cAliasQry)->DT6_VALTOT, (cAliasQry)->DT6_DECRES, (cAliasQry)->DTC_NUMNFC, (cAliasQry)->DTC_VALOR, (cAliasQry)->PERC  })
	(cAliasQry)->(dbSkip())
EndDo
(cAliasQry)->(dbCloseArea())


//--Volta o Ponteiro para o Contas a Receber
dbSelectArea("SE1")

If !Found()
	MsgBox("Titulo não Encontrado, verifique os paramentros digitados!!")
	Return
Endif

oprn:Setup() //--Exibe Configuracoes da Impressao

While !Eof()
	
	If Val(SE1->E1_NUM) > Val(M->NFf) .or. SE1->E1_PREFIXO != M->Serie
		Exit
	Endif
	
   cVenc := Substr(DTOS(SE1->E1_VENCTO), 7, 2) + "/" + Substring(DTOS(SE1->E1_VENCTO), 5, 2) + "/" + Substring(DTOS(SE1->E1_VENCTO), 1, 4)
   cEmis := Substr(DTOS(SE1->E1_EMISSAO), 7, 2) + "/" + Substring(DTOS(SE1->E1_EMISSAO), 5, 2) + "/" + Substring(DTOS(SE1->E1_EMISSAO), 1, 4)	

	//Incrementar o Numero da Boleta(1a. Impressão) ou buscar no arquivo(reimpressão)
	M->RegSE1 := Recno()
	
	//Posicionar no Cliente
	DbSelectArea("SA1")
	DbSetOrder(1)
	DbGoTop()
	DbSeek(xFilial("SA1") + SE1->E1_CLIENTE + SE1->E1_LOJA)
	
	DbSelectArea("SE1")
	DbGoto(M->RegSE1)
	
	oprn:StartPage() //--Inicio da Impressao
	oPrn:SetPortrait() //--Retrato
	
	//Calculos a serem impressos na boleta e gravados no SE1
  
	//--Boleta
	Do Case		
		Case M->Banco == "341"
			M->Nome_Bco := "Banco Itau"
			M->Cod_Comp := "|341-7|"
			M->Ag_Conta := "0070-X / 72100-6"
			M->Carteira := "109"
			M->Aceite   := "N"
	EndCase

	oprn:Say(010,2200," Pag: "+Transform(nPag,"@E 99"),oFont1,100)
	
	//--Cabecalho da Fatura
	oPrn:Box(050,0100,0300,0500)
	oPrn:Box(050,0500,0300,1600)
	oPrn:Box(050,1600,0300,2300)

	//--Primeiro Box
	oPrn:SayBitmap( 0120, 0150, cLogoFAT, 250, 100 )
	
	//--Segundo Box
	oprn:Say(050,0520,"EMOVERE LOGÍSTICA LTDA.",oFont4,100)
	oprn:say(100,0520,"AV. DR. MAURO LINDEMBERG MONTEIRO, 185",oFont4,100)
	oprn:say(150,0520,"GALPÃO 10 - MEZANINO - BLOCO 1",oFont4,100)
	oprn:say(200,0520,"CEP: 06278-010",oFont4,100)
	oprn:say(250,0520,"JD. SANTA FÉ - OSASCO - SP",oFont4,100)

	//--Terceiro Box
	oPrn:Say(050,1610,"Fone:(11)  3658-8892",oFont4,100)
	oPrn:Say(100,1610,"Fax:(11)   3658-8893",oFont4,100)
	oPrn:Say(150,1610,"C.N.P.J.:  10.245.270/0001-16",oFont4,100)
	oPrn:Say(200,1610,"Insc.Est.: 492.539.225.119",oFont4,100)
	oPrn:Say(250,1610,"Email: emovere@emovere.com.br",oFont4,100)
	
	
	//--(Linha,Coluna Inicial,Linha Final, Coluna Final)
	oPrn:Box(350,0100,0400,1150)
	oPrn:Box(350,1150,0400,2300)	
	
	oPrn:Say(350,0550,"FATURA",oFont2,100)
	oPrn:Say(350,1700,"DUPLICATA",oFont2,100)
	
	oPrn:Box(400,0100,0450,0400) //--Numero
	oPrn:Box(400,0400,0450,0700) //--Valor
	oPrn:Box(400,0700,0450,1150) //--Data Emissao
	oPrn:Box(400,1150,0450,1450) //--Numero
	oPrn:Box(400,1450,0450,1750) //--Parcela
	oPrn:Box(400,1750,0450,2050) //--Valor
	oPrn:Box(400,2050,0450,2300) //--Vencimento
	
	oPrn:Say(400,0110,"Numero",oFont2,100)
	oPrn:Say(400,0410,"Valor R$",oFont2,100)
	oPrn:Say(400,0710,"Data da Emissão",oFont2,100)
	oPrn:Say(400,1160,"Número",oFont2,100)
	oPrn:Say(400,1460,"Parcela",oFont2,100)
	oPrn:Say(400,1760,"Valor R$",oFont2,100)
	oPrn:Say(400,2060,"Vencimento",oFont2,100)

	oPrn:Box(450,0100,0500,0400) //--Numero
	oPrn:Box(450,0400,0500,0700) //--Valor
	oPrn:Box(450,0700,0500,1150) //--Data Emissao
	oPrn:Box(450,1150,0500,1450) //--Numero
	oPrn:Box(450,1450,0500,1750) //--Parcela
	oPrn:Box(450,1750,0500,2050) //--Valor
	oPrn:Box(450,2050,0500,2300) //--Vencimento

	//--Valores, pesquisar no banco de dados
	oPrn:Say(450,0110,SE1->E1_NUM,oFont2,100)
	oPrn:Say(450,0410,Transform(SE1->E1_VALOR,"@E 999,999,999.99"),oFont2,100)
	oPrn:Say(450,0710,Dtoc(SE1->E1_EMISSAO),oFont2,100)
	oPrn:Say(450,1160,SE1->E1_NUM,oFont2,100)
	oPrn:Say(450,1460,SE1->E1_PARCELA,oFont2,100)
	oPrn:Say(450,1760,Transform(SE1->E1_VALOR,"@E 999,999,999.99"),oFont2,100)
	oPrn:Say(450,2060,Dtoc(SE1->E1_VENCTO),oFont2,100)

   
	//--Detalhes do Cliente
	oPrn:Box(500,0100,830,2300)
	oPrn:Say(510,0110,"Sacado: " + SA1->A1_NOME ,oFont2,100)
	oPrn:Say(510,1500,"Código: " + SA1->A1_COD + "-" + SA1->A1_LOJA ,oFont2,100)
	oPrn:Say(560,0110,"Endereço: " + AllTrim(SA1->A1_END) ,oFont2,100)
	oPrn:Say(560,1500,"CEP: " + Substr(SA1->A1_CEP,1,5) + "-" + Substr(SA1->A1_CEP,5,3) ,oFont2,100)
	oPrn:Say(610,0110,"Bairro: " + AllTrim(SA1->A1_BAIRRO) ,oFont2,100)
	oPrn:Say(610,0700,"Municipio: " + AllTrim(SA1->A1_MUN) ,oFont2,100)
	oPrn:Say(610,1500,"Estado: " + SA1->A1_EST ,oFont2,100)
	If SA1->A1_PESSOA == "J" //--Juridica
		oprn:Say(670,0110,'CNPJ: ' + Transform(SA1->A1_CGC,"@R 99.999.999/9999-99"),oFont2,100)
	ElseIf SA1->A1_PESSOA == "F" //--Fisica
		oprn:Say(670,0110,'CPF: ' + Transform(SA1->A1_CGC,"@R 999.999.999-99"),oFont2,100)
	EndIf	
	oPrn:Say(670,1500,"Insc Estadual: " + SA1->A1_INSCR ,oFont2,100)
	
	If !Empty(SA1->A1_ENDCOB)
		oPrn:Say(720,0110,"End Cobrança: " + Substr(SA1->A1_ENDCOB,1,32) ,oFont2,100)
	Else
		oPrn:Say(720,0110,"End Cobrança: " + Substr(SA1->A1_END,1,32) ,oFont2,100)
	EndIf
	
	oPrn:Say(720,1000,"CEP: " + Substr(SA1->A1_CEP,1,5) + "-" + Substr(SA1->A1_CEP,5,3) ,oFont2,100)
	oPrn:Say(720,1500,"Estado: " + SA1->A1_EST ,oFont2,100)
	oPrn:Say(770,0110,"Municipio: " + AllTrim(SA1->A1_MUN) ,oFont2,100)
	
	//--Valor por Extenso
	oPrn:Box(850,0100,1000,2300)
	oPrn:Say(860,0110," Valor"  + "    " + AllTrim(Extenso(SE1->E1_VALOR,.F.,1)) ,oFont2,100)
	oPrn:Say(910,0110,"  por"   + Replicate('.',200) ,oFont2,100)
	oPrn:Say(960,0110,"Extenso" + Replicate('.',200) ,oFont2,100)
	
	
	//--Conhecimentos a Faturar
	oPrn:Box(1050,0100,1150,0344)
	oPrn:Box(1050,0344,1150,0588)
	oPrn:Box(1050,0588,1150,0832)
	oPrn:Box(1050,0832,1150,1076)
	oPrn:Box(1050,1076,1150,1320)
	oPrn:Box(1050,1320,1150,2296)
	/*
	oPrn:Box(1050,1564,1150,1808)
	oPrn:Box(1050,1808,1150,2052)
	oPrn:Box(1050,2052,1150,2296)
	*/
	
	//--Cabecalho dos Itens da fatura
	oPrn:Say(1050,0150,"Data",oFont2,100)
	oPrn:Say(1050,0384,"Numero",oFont2,100)
	oPrn:Say(1100,0390,"CTRC",oFont2,100)
	oPrn:Say(1050,0598,"Frete",oFont2,100)
	oPrn:Say(1100,0598,"(R$)",oFont2,100)


	oPrn:Say(1050,0842,"Nota Cliente",oFont2,100)
	oPrn:Say(1050,1086,"Valor Nota",oFont2,100)
	oPrn:Say(1050,1830,"% Frete/Valor",oFont2,100)


	/*
	oPrn:Say(1050,0842,"Data",oFont2,100)
	oPrn:Say(1050,1086,"Numero",oFont2,100)
	oPrn:Say(1100,1086,"CTRC",oFont2,100)
	oPrn:Say(1050,1330,"Frete",oFont2,100)
	oPrn:Say(1100,1330,"(R$)",oFont2,100)
	oPrn:Say(1050,1574,"Data",oFont2,100)
	oPrn:Say(1050,1818,"Numero",oFont2,100)
	oPrn:Say(1100,1818,"CTRC",oFont2,100)
	oPrn:Say(1050,2062,"Frete",oFont2,100)
	oPrn:Say(1100,2062,"(R$)",oFont2,100)       
	*/
		
	//--Verifica o numero de CTRCs, para jogar nas linhas
	nCol  := "A"                   
	nBoxVIni := 1150
	nBoxVFim := 1200
	nConV    := 1100
	
	For nCont := 1 To Len(aDoc)
	  
	  	If nCont == nLimite 
			
			nPag += 1
		   
			//nLimite := nLimite+183//Giovani Zago 11/11/11
			nLimite := nLimite+60//Giovani Zago 11/11/11
			
			oprn:EndPage()
			oprn:StartPage() //--Inicio da Impressao
 			oPrn:SetPortrait() //--Retrato	
 			nCol  := "A"           
			nCnt2 := 0  
			nBoxVIni := 0100
			nBoxVFim := 0150
			nConV    := 0050
            
			//-- Página
			oprn:Say(010,2200," Pag: "+Transform(nPag,"@E 99"),oFont1,100)
			
			//--Conhecimentos a Faturar
			oPrn:Box(nBoxVIni,0100,nBoxVFim+50,0344)
			oPrn:Box(nBoxVIni,0344,nBoxVFim+50,0588)
			oPrn:Box(nBoxVIni,0588,nBoxVFim+50,0832)
			oPrn:Box(nBoxVIni,0832,nBoxVFim+50,1076)
			oPrn:Box(nBoxVIni,1076,nBoxVFim+50,1320)
			oPrn:Box(nBoxVIni,1320,nBoxVFim+50,2296)
			/*
			oPrn:Box(nBoxVIni,1564,nBoxVFim+50,1808)
			oPrn:Box(nBoxVIni,1808,nBoxVFim+50,2052)
			oPrn:Box(nBoxVIni,2052,nBoxVFim+50,2296)
	*/
			//--Cabecalho dos Itens da fatura
			oPrn:Say(nBoxVIni,0150,"Data",oFont2,100)
			oPrn:Say(nBoxVIni,0384,"Numero",oFont2,100)
			oPrn:Say(nBoxVFim,0390,"CTRC",oFont2,100)
			oPrn:Say(nBoxVIni,0598,"Frete",oFont2,100)
			oPrn:Say(nBoxVFim,0598,"(R$)",oFont2,100)

			oPrn:Say(nBoxVIni,0842,"Nota Cliente",oFont2,100)
			oPrn:Say(nBoxVIni,1086,"Valor Nota",oFont2,100)
			oPrn:Say(nBoxVIni,1830,"% Frete/Valor",oFont2,100)



			/*
			oPrn:Say(nBoxVIni,0842,"Data",oFont2,100)
			oPrn:Say(nBoxVIni,1086,"Numero",oFont2,100)
			oPrn:Say(nBoxVFim,1086,"CTRC",oFont2,100)
			oPrn:Say(nBoxVIni,1330,"Frete",oFont2,100)
			oPrn:Say(nBoxVFim,1330,"(R$)",oFont2,100)
			oPrn:Say(nBoxVIni,1574,"Data",oFont2,100)
			oPrn:Say(nBoxVIni,1818,"Numero",oFont2,100)
			oPrn:Say(nBoxVFim,1818,"CTRC",oFont2,100)
			oPrn:Say(nBoxVIni,2062,"Frete",oFont2,100)
			oPrn:Say(nBoxVFim,2062,"(R$)",oFont2,100) 
			*/
			nCnt2 += 100
		Endif      
		
		If 	nCol == "A"
			                 			
			// Linha ctrc,s   
			oPrn:Box(nBoxVIni+nCnt2,0100,nBoxVFim+nCnt2,0344)
			oPrn:Box(nBoxVIni+nCnt2,0344,nBoxVFim+nCnt2,0588)
			oPrn:Box(nBoxVIni+nCnt2,0588,nBoxVFim+nCnt2,0832)
			oPrn:Box(nBoxVIni+nCnt2,0832,nBoxVFim+nCnt2,1076)
			oPrn:Box(nBoxVIni+nCnt2,1076,nBoxVFim+nCnt2,1320)
			oPrn:Box(nBoxVIni+nCnt2,1320,nBoxVFim+nCnt2,2296)
			/*
			oPrn:Box(nBoxVIni+nCnt2,1564,nBoxVFim+nCnt2,1808)
			oPrn:Box(nBoxVIni+nCnt2,1808,nBoxVFim+nCnt2,2052)
			oPrn:Box(nBoxVIni+nCnt2,2052,nBoxVFim+nCnt2,2296)
			*/
			nCnt2 += 50
			
			oPrn:Say(nConV+(nCnt2),0110,Dtoc(aDoc[nCont][01]),oFont2,100)
			oPrn:Say(nConV+(nCnt2),0354,aDoc[nCont][02],oFont2,100)
			oPrn:Say(nConV+(nCnt2),0598,Transform(aDoc[nCont][03],"@E 999,999,999.99"),oFont2,100)


			oPrn:Say(nConV+(nCnt2),0842,aDoc[nCont][05],oFont2,100)
			oPrn:Say(nConV+(nCnt2),1086,Transform(aDoc[nCont][06],"@E 999,999,999.99"),oFont2,100)
			oPrn:Say(nConV+(nCnt2),1830,Transform(aDoc[nCont][07],"@E 999.99"),oFont2,100)


/*			nCol  := "B"
			
		ElseIf 	nCol == "B"
			oPrn:Say(nConV+(nCnt2),0842,Dtoc(aDoc[nCont][01]),oFont2,100)
			oPrn:Say(nConV+(nCnt2),1086,aDoc[nCont][02],oFont2,100)
			oPrn:Say(nConV+(nCnt2),1330,Transform(aDoc[nCont][03],"@E 999,999,999.99"),oFont2,100)
			nCol  := "C"
		ElseIf nCol == "C"
			oPrn:Say(nConV+(nCnt2),1574,Dtoc(aDoc[nCont][01]),oFont2,100)
			oPrn:Say(nConV+(nCnt2),1818,aDoc[nCont][02],oFont2,100)
			oPrn:Say(nConV+(nCnt2),2062,Transform(aDoc[nCont][03],"@E 999,999,999.99"),oFont2,100)*/
			nCol  := "A"
		EndIf		
	Next nCont
	nTotNotas := 0
	aEval(aDoc,{ |x| nTotNotas += x[6] })



	nCnt2 += 50

	//--Total Notas
	//oPrn:Box(nBoxVIni+nCnt2,0100,nBoxVIni+100+nCnt2,2000)
	//oPrn:Box(nBoxVIni+nCnt2,2000,nBoxVIni+100+nCnt2,2300)
	oPrn:Say(nBoxVIni+(nCnt2),1086,"Valor total das notas transportadas",oFont2,100)
	oPrn:Say(nBoxVFim+(nCnt2),1086,Transform(nTotNotas,"@E 999,999,999.99"),oFont2,100)



	//--Total Bruto
	oPrn:Box(nBoxVIni+nCnt2,0100,nBoxVIni+100+nCnt2,2000)
	oPrn:Box(nBoxVIni+nCnt2,2000,nBoxVIni+100+nCnt2,2300)
	oPrn:Say(nBoxVIni+(nCnt2),2010,"Total Bruto",oFont2,100)
	oPrn:Say(nBoxVFim+(nCnt2),2010,Transform(SE1->E1_VALOR,"@E 999,999,999.99"),oFont2,100)
	
	nCnt2 += 100
	//--Total Liquido
	oPrn:Box(nBoxVIni+nCnt2,0100,nBoxVIni+100+nCnt2,2000)
	oPrn:Box(nBoxVIni+nCnt2,2000,nBoxVIni+100+nCnt2,2300)
	oPrn:Say(nBoxVIni+(nCnt2),2010,"Total Liquido",oFont2,100)
	oPrn:Say(nBoxVFim+(nCnt2),0110,"Quantidade de CTRC'S : "+Transform(Len(aDoc),"@E 999999"),oFont2,100)
	oPrn:Say(nBoxVFim+(nCnt2),2010,Transform(SE1->E1_VALOR,"@E 999,999,999.99"),oFont2,100)
	
	Eject
	DbSkip()
	
	oprn:EndPage()
	
EndDo

//--Preview em tela da impressao
oprn:Preview()

//--Enviar a Impressora
//oPrn:Print()

oprn:End()

Ms_Flush()

Return

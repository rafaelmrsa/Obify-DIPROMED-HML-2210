#include "protheus.ch"
#include "rwmake.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ UMATA455 ³ Autor ³    Alexandro Dias     ³ Data ³ 12.09.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Mostra posicao do pedidos de venda.                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
User Function UMata455(cCliente)
Local aArea      := GetArea()
Local aSize    	 := MsAdvSize(.F.)
Local aObjects   := {}
Local aPosObj    := {}
Local aOrd       := {}
Local aCab       := {}
Local oDlg
Local oScro1
Local oScro2
Local oPsq
Local oKey
Local nPsq		 := 0
Local cKey		 := Space(14)
Private cCadastro:= "Status de Pedido de Venda"
Private cCliBrw  := ""
Private aBrw     := {}
Private oBrw
Private aCoresLeg:= {	{"BR_VERDE"	  , "Item com Pré-Nota Emitida"},;
{"BR_VERMELHO", "Item Faturado"},;
{"BR_AZUL"    , "Item Bloqueado por Credito"},;
{"BR_MARROM"  , "Item Rejeitado pelo Credito"},;
{"BR_PINK"    , "Item Bloqueado pelo Operador" },;
{"BR_LARANJA" , "Item Reservado" },;
{"BR_AMARELO" , "Item Com Saldo a Liberar" },;
{"BR_BRANCO"   , "Item Bloqueado por Estoque"}}

Private oVerde     := Loadbitmap( GetResources(), "BR_VERDE" )
Private oVermelho  := Loadbitmap( GetResources(), "BR_VERMELHO" )
Private oCinza     := Loadbitmap( GetResources(), "BR_CINZA" )
Private oAzul      := Loadbitmap( GetResources(), "BR_AZUL" )
Private oMarrom    := Loadbitmap( GetResources(), "BR_MARROM" )
Private oPink      := Loadbitmap( GetResources(), "BR_PINK" )
Private oAmarelo   := Loadbitmap( GetResources(), "BR_AMARELO" )
Private oLaranja   := Loadbitmap( GetResources(), "BR_LARANJA" )
Private oBranco    := Loadbitmap( GetResources(), "BR_BRANCO" )

DEFAULT cCliente := ""
cCliBrw:= cCliente

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Alimenta Cabecalho.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aCab:= {"","Pre-Nota","Pedido","Item","Seq.","Cliente","Nome Cliente","Produto","Descricao","Quant.","Qt.Liberada","Saldo","Sld.Estoque","Status","Operador","Nota Fiscal","Serie NF","Dt.Liberacao","Prc.Venda","Lote","Validade do Lote","Almoxarifado","Vendedor","Separador"}

Aadd(aOrd, "Pedido  + Cliente" )
Aadd(aOrd, "Cliente + Pedido" )
Aadd(aOrd, "Produto + Pedido  + Cliente" )


AAdd( aObjects, { 100 , 10, .T., .T.,.T. } )
AAdd( aObjects, { 100 , 80, .T., .T.,.T. } )
AAdd( aObjects, { 100 , 10, .T., .T.,.T. } )

aInfo   := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 1, 1 }
aPosObj := MsObjSize( aInfo, aObjects, .T. )

Processa( { | lEnd | A455BRW(@aBrw,@lEnd) }, "Aguarde","Filtrando Pedidos", .T. )

If Len(aBrw) == 0
	Return
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta a tela para usuario visualizar consulta                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DEFINE MSDIALOG oDlg FROM 0,0 TO aSize[6],aSize[5] TITLE "Status de Pedido de Vendas" Of oMainWnd PIXEL

oScro1 := TScrollBox():New( oDlg, aPosObj[1,1], aPosObj[1,2],aPosObj[1,4], aPosObj[1,3], .T., .T., .T.)
oScro1:Align:= CONTROL_ALIGN_TOP

@ 02,02  MSCOMBOBOX oPsq VAR nPsq ITEMS aOrd WHEN Len(aBrw) < 140000 SIZE 80,40 Of oScro1 Pixel
oPsq:nAt:= 1
oPsq:bChange:= {|| A455Ordem(oPsq,@oBrw,@aBrw,aOrd,@cKey) }


@ 02,85  MSGET oKey VAR cKey  WHEN Len(aBrw) < 140000 OF oScro1 SIZE 100,10 PIXEL
@ 02,187 BUTTON "Pesquisar"  WHEN Len(aBrw) < 140000 SIZE 36,12 ACTION A455Psq(oPsq,@oBrw,@aBrw,aOrd,@cKey) OF oScro1 PIXEL

oBrw:= TwBrowse():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,4],aPosObj[2,3],,aCab,,oDlg,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
oBrw:Align:= CONTROL_ALIGN_ALLCLIENT
oBrw:SetArray( aBrw )
oBrw:bLine := {|| FrmCposSC9(aBrw,oBrw) }
oScro2 := TScrollBox():New( oDlg, aPosObj[3,1], aPosObj[3,2],aPosObj[3,4], aPosObj[3,3], .T., .T., .T.)
oScro2:Align:= CONTROL_ALIGN_BOTTOM


@ 02,02  BUTTON "Visualiza Pedido" 		SIZE 45,12 ACTION A455PEDIDO(aBrw,oBrw) OF oScro2 PIXEL
@ 02,50  BUTTON "Caract. Produto"  		SIZE 45,12 ACTION A455CARAC(aBrw,oBrw) OF oScro2 PIXEL
@ 02,194 BUTTON "Legenda"  				SIZE 45,12 ACTION BrwLegenda(cCadastro,"Legenda",aCoresLeg) OF oScro2 PIXEL
@ 02,241 BUTTON "Sair"                  SIZE 45,12 ACTION oDlg:End() OF oScro2 PIXEL

ACTIVATE MSDIALOG oDlg

Return(.T.)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A455PEDIDO³ Autor ³    Alexandro Dias     ³ Data ³ 12.09.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Visualiza o pedido de venda em questao.                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function A455PEDIDO(aBrw,oBrw)
Private aRotina := { { OemToAnsi("Pesquisar"),"AxPesqui"  ,0,1},;
{ OemToAnsi("Visual"),"A410Visual",0,2},;
{ OemToAnsi("Incluir"),"A410Inclui",0,3},;
{ OemToAnsi("Alterar"),"A410Altera",0,4,20},;
{ OemToAnsi("Excluir"),"A410Deleta",0,5,21},;
{ OemToAnsi("Cod.barra"),"A410Barra" ,0,3,0},;
{ OemToAnsi("Copia"),"A410Copia",0,3},;
{ OemToAnsi("Dev. Compras"),"A410Devol",0,3},;
{ OemToAnsi("Legenda"),"A410Legend" ,0,3,0} }

DbSelectArea("SC5")
DbSetOrder(1)
DbGoto(aBrw[oBrw:nAT,2])
IF !Eof()
	A410Visual("SC5",SC5->(Recno()),2)
EndIF

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ SALDSB2 ³ Autor ³    Alexandro Dias     ³ Data ³ 12.09.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna o saldo em estoque do produto em questao.          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function SALDSB2(cProduto)

Local _nQuant := 0
Local _xAlias := GetArea()
DEFAULT cProduto:= SC9->C9_PRODUTO

DbSelectArea("SB2")
DbSetOrder(1)
DbSeek(xFilial("SB2")+cProduto)
While !Eof() .and. SB2->B2_COD == cProduto
	IF SB2->B2_LOCAL $ "01/02"
		_nQuant := _nQuant + SaldoSb2()
	EndIF
	DbSkip()
EnDdo

RestArea(_xAlias)

Return(_nQuant)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³C5PARCIALºAutor  ³Fabio Rogerio      º Data ³  09/26/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Rotina para retornar se o pedido eh liberado parcial ou nao.º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function C5PARCIAL()
Local cRet := ""
Local aArea:= GetArea()

cRet:= Posicione("SC5",1,xFilial("SC5")+SC9->C9_PEDIDO,"C5_PARCIAL")

RestArea(aArea)
Return(cRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³  FrmCposSC9  ³ Autor ³   Fabio Rogerio  ³ Data ³ 30/06/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Formata os campos do SC9 para exibicao.	                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function FrmCposSC9(aBrw, oBrw)
Local nI         := 0
Local aBrwLine   := {}
Local aLine      := {}

If (Len(aBrw) > 0)
	
	SC9->(DbGoto(aBrw[oBrw:nAt][1]))
	SC5->(DbGoto(aBrw[oBrw:nAt][2]))
	
	SA1->(dbSetOrder(1))
	SA1->(dbSeek(xFilial("SA1")+SC9->(C9_CLIENTE+C9_LOJA)))   

	SA2->(dbSetOrder(1))
	SA2->(dbSeek(xFilial("SA2")+SC9->(C9_CLIENTE+C9_LOJA)))   

	SC5->(dbSetOrder(3))
	SC5->(dbSeek(xFilial("SC5")+SC9->(C9_CLIENTE+C9_LOJA+C9_PEDIDO)))   

	//		            1            2              3          4         5          6           7         8          9          10         11        12                   13         14        15        16          17         18        19         20          21        22       23          24                25       26        27          28
	aBrwLine := SC9->({/*oObj*/,SC5->C5_PRENOTA,C9_PEDIDO,C9_ITEM,C9_SEQUEN,C9_CLIENTE,SA1->A1_NOME,C9_PRODUTO,"          ",C9_QTDVEN,C9_QTDLIB,C9_SALDO,0                        ,"   ",C9_OPERADO,C9_NFISCAL,C9_SERIENF,C9_DATALIB,C9_PRCVEN,C9_LOTECTL,C9_DTVALID,C9_LOCAL,C9_VEND,SC9->(Recno()),SC5->C5_PARCIAL,C9_BLEST,C9_BLCRED,C9_SEPARAD})
	
	Do Case
		
		Case (aBrwLine[25]  == 'N') .And. (aBrwLine[26] != '10' .And. aBrwLine[27] != '10' .And. aBrwLine[27] != '09')
			Aadd( aLine, oPink )
			
		Case (Empty(aBrwLine[26]) .And. Empty(aBrwLine[27]))
			Aadd( aLine, oVerde )
			
		Case (!Empty(aBrwLine[16]))
			Aadd( aLine, oVermelho )
			
		Case (aBrwLine[27]  $ '01/04' )
			Aadd( aLine, oAzul )
			
		Case (aBrwLine[27]  == '09' )
			Aadd( aLine, oMarrom )
			
		Case (aBrwLine[13] > 0 .And. aBrwLine[12]  > 0 .And. aBrwLine[26] == '02')
			Aadd( aLine, oAmarelo )
			
		Case (aBrwLine[13] >= 0 .And. aBrwLine[12] == 0 .And. aBrwLine[26] == '02')
			Aadd( aLine, oLaranja )
			
		Case (aBrwLine[13] == 0 .And. aBrwLine[12]  > 0 .And. aBrwLine[26] == '02')
			Aadd( aLine, oBranco )
			
		Otherwise
			Aadd( aLine, oCinza )
	EndCase
	
	SA1->(dbSetOrder(1))
	SA1->(dbSeek(xFilial("SA1")+aBrwLine[6]+aBrwLine[7]))
	
	SB1->(dbSetOrder(1))
	SB1->(dbSeek(xFilial("SB1")+aBrwLine[8]))
	
	aAdd(aLine,Transform(aBrwLine[2],PesqPict("SC5","C5_PRENOTA")))
	aAdd(aLine,Transform(aBrwLine[3],PesqPict("SC9","C9_PEDIDO")))
	aAdd(aLine,Transform(aBrwLine[4],PesqPict("SC9","C9_ITEM")))
	aAdd(aLine,Transform(aBrwLine[5],PesqPict("SC9","C9_SEQUEN")))
	aAdd(aLine,Transform(aBrwLine[6],PesqPict("SC9","C9_CLIENTE")))
	
  	If SC5->C5_TIPO $ 'D/B'
		aAdd(aLine,Transform(SA2->A2_NOME,PesqPict("SA2","A2_NOME")))
  	Else
		aAdd(aLine,Transform(SA1->A1_NOME,PesqPict("SA1","A1_NOME")))
	EndIf                                                                                      
	
	aAdd(aLine,Transform(aBrwLine[8],PesqPict("SB1","B1_COD")))
	aAdd(aLine,Transform(SB1->B1_DESC,PesqPict("SB1","B1_DESC")))
	
	aAdd(aLine,Transform(aBrwLine[10],PesqPict("SC9","C9_QTDVEN")))
	aAdd(aLine,Transform(aBrwLine[11],PesqPict("SC9","C9_QTDLIB")))
	aAdd(aLine,Transform(aBrwLine[12],PesqPict("SC9","C9_SALDO")))
	aAdd(aLine,Transform(U_SaldSB2(aBrwLine[8]),PesqPict("SB2","B2_QATU")))
	
	aAdd(aLine,Transform(aBrwLine[14],PesqPict("SC9","C9_STATUS")))
	aAdd(aLine,Transform(aBrwLine[15],PesqPict("SC9","C9_OPERADO")))
	aAdd(aLine,Transform(aBrwLine[16],PesqPict("SC9","C9_NFISCAL")))
	aAdd(aLine,Transform(aBrwLine[17],PesqPict("SC9","C9_SERIENF")))
	aAdd(aLine,Transform(aBrwLine[18],PesqPict("SC9","C9_DATALIB")))
	aAdd(aLine,Transform(aBrwLine[19],PesqPict("SC9","C9_PRCVEN")))
	aAdd(aLine,Transform(aBrwLine[20],PesqPict("SC9","C9_LOTECTL")))
	aAdd(aLine,Transform(aBrwLine[21],PesqPict("SC9","C9_DTVALID")))
	aAdd(aLine,Transform(aBrwLine[22],PesqPict("SC9","C9_LOCAL")))
	aAdd(aLine,Transform(aBrwLine[23],PesqPict("SC9","C9_VEND")))
	aAdd(aLine,Transform(aBrwLine[28],PesqPict("SC9","C9_SEPARAD")))
	
EndIf

Return aLine


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³A455Brw   ºAutor  ³Microsiga           º Data ³  01/26/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Preenche o array com o filtro                               º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function A455BRW(aBrw,lEnd)
Local cQuery    := ""
Local cCondicao := ""
Local cSelect   := " SELECT SC9.* "
Local cFrom	    := " FROM " + RetSqlName("SC9")+" SC9 "
Local aBoxParam := {}
Local aRetParam := {}
Local aStru     := SC9->(dbStruct())
Local lRet      := .T.
Local oObj      := ""
Local cStatus   := ""
Local nI
local nStep        
Local cPerg 	:= "DIPG13"

If Empty(cCliBrw)
	Aadd(aBoxParam,{2,"Quais Pedidos"		,1,{"1 - Todos","2 - Item Liberado","3 - Item Faturado","4 - Item Bloqueado por Credito","5 - Item Bloqueado Parcialmente","6 - Item Com Saldo a Liberar","7 - Item Bloqueado por Estoque","8 - Item Reservado"},100,"",.F.})
	Aadd(aBoxParam,{1,"Do Pedido" 			,Space(6)                	,"@!","","","",6,.F.})
	Aadd(aBoxParam,{1,"Ate o Pedido"		,Replicate("Z",6)  			,"@!","","","",6,.F.})
	Aadd(aBoxParam,{1,"Do Cliente"			,Space(TamSX3("A1_COD")[1])	,"@!","","SA1","",6,.F.})
	Aadd(aBoxParam,{1,"Ate o Cliente"		,Replicate("Z",6)			,"@!","","SA1","",6,.F.})
	Aadd(aBoxParam,{1,"Do Operador"			,Space(TamSX3("U7_COD")[1])	,"@!","","SU7","",6,.F.})
	Aadd(aBoxParam,{1,"Ate o Operador"		,Replicate("Z",6)			,"@!","","SU7","",6,.F.})
	Aadd(aBoxParam,{1,"Do Vendedor"			,Space(TamSX3("A3_COD")[1])	,"@!","","SA3","",6,.F.})
	Aadd(aBoxParam,{1,"Ate o Vendedor"		,Replicate("Z",6)			,"@!","","SA3","",6,.F.})
	Aadd(aBoxParam,{1,"Do Produto"			,Space(TamSX3("B1_COD")[1])	,"@!","","SB1","",50,.F.})
	Aadd(aBoxParam,{1,"Ate o Produto"		,Replicate("Z",15)			,"@!","","SB1","",50,.F.})
	Aadd(aBoxParam,{1,"Liber. Data Inicial"	,FirstDay(dDatabase),"99/99/9999","","","",10,.F.})
	Aadd(aBoxParam,{1,"Liber. Data Final"	,LastDay(dDatabase),"99/99/9999","","","",10,.F.})
	
	
	If ParamBox(aBoxParam,"Informe os Parametros",@aRetParam,,,,,,,,.F.)
		 //Giovani Zago 08/03/2012 filtro para os vendedores.
		If Alltrim(Posicione("SU7",4,xFilial("SU7") + RetCodUsr(),"U7_CGC")) $ GetMv("ES_VENDUSE",,"000053" )
			mv_par08 := alltrim(Posicione("SU7",4,xFilial("SU7") + RetCodUsr(),"U7_CGC"))
			mv_par09:=mv_par08
		EndIf
		
        //Permirir consulta do faturamento somente para os notas da própria vendedora caso seja televendas - 28/10/15
        If Alltrim(Posicione("SU7",4,xFilial("SU7") + RetCodUsr(),"U7_CODVEN")) <> '' 
	        MV_Par01:= IIf(ValType(Mv_Par01) == "N",StrZero(Mv_Par01,1),Left(Mv_Par01,1))
		    If MV_PAR01 $ '1,2,3'
				mv_par08 := alltrim(Posicione("SU7",4,xFilial("SU7") + RetCodUsr(),"U7_CODVEN"))
				mv_par09:=mv_par08        
        	Endif                                                                               
    	Endif
        

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Grava LOG de acesso dos usuarios.³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		U_DIPPROC(ProcName(0),U_DipUsr()) // JBS 05/10/2005 - Gravando o nome do Programa no SZU
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Variaveis para o complemento do Filtro, ou quando Mv_par01=="1" ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cCondicao += " AND (SC9.C9_PEDIDO >='" + mv_par02 		+ "' AND SC9.C9_PEDIDO <= '" + mv_par03 + "')"
		cCondicao += " AND (SC9.C9_CLIENTE>='" + mv_par04 		+ "' AND SC9.C9_CLIENTE<= '" + mv_par05 + "')"
		cCondicao += " AND (SC9.C9_OPERADO>='" + mv_par06 		+ "' AND SC9.C9_OPERADO<= '" + mv_par07 + "')"
		cCondicao += " AND (SC9.C9_VEND   >='" + mv_par08 		+ "' AND SC9.C9_VEND<=    '" + mv_par09 + "')"
		cCondicao += " AND (SC9.C9_PRODUTO>='" + mv_par10 		+ "' AND SC9.C9_PRODUTO<= '" + mv_par11 + "')"
		cCondicao += " AND (SC9.C9_DATALIB>='" + Dtos(mv_par12) + "' AND SC9.C9_DATALIB<= '" + Dtos(mv_par13)+"')"
	Else
		Return(.F.)
	EndIf
Else
	cCondicao := " AND (SC9.C9_PEDIDO >='"	+ Space(6)	+ "' AND SC9.C9_PEDIDO  <='" + Replicate("Z",6) + "') "
	cCondicao += " AND (SC9.C9_CLIENTE ='"	+ cCliBrw	+ "' ) "
	cCondicao += " AND (SC9.C9_OPERADO>='"	+ Space(6)	+ "' AND SC9.C9_OPERADO <='" + Replicate("Z",6) + "') "
	cCondicao += " AND (SC9.C9_VEND   >='"	+ Space(6)	+ "' AND SC9.C9_VEND    <='" + Replicate("Z",6) + "') "
	cCondicao += " AND (SC9.C9_PRODUTO>='"	+ Space(15)	+ "' AND SC9.C9_PRODUTO <='" + Replicate("Z",15) + "') "
	
	uMvAux1 := mv_par01
	uMvAux2 := mv_par02
	
	AjustaSX1(cPerg)              
	              
	Pergunte(cPerg,.T.) 	                                                
	                    
	cDatIni := ""
	If !Empty(mv_par01)
		cCondicao += " AND SC9.C9_DATALIB >= '"+DtoS(mv_par01)+"'"
		cDatIni := DtoS(mv_par01)
	EndIf                              
	                        
	cDatFim := "20491231
	If !Empty(mv_par02)
		cCondicao += " AND  SC9.C9_DATALIB <= '"+DtoS(mv_par02)+"'" 
		cDatFim := DtoS(mv_par02)
	EndIf              
	
	mv_par01 := uMvAux1
	mv_par02 := uMvAux2

EndIf

MV_Par01:= IIf(ValType(Mv_Par01) == "N",StrZero(Mv_Par01,1),Left(Mv_Par01,1))

If mv_par01 <> '3'

	cQuery := " SELECT SC9.R_E_C_N_O_ NRECNOSC9"
	cQuery += " ,SC5.R_E_C_N_O_ NRECNOSC5"
	cQuery += " FROM " + RetSqlName("SC5") + " SC5 (NOLOCK)," + RetSqlName("SC9") + " SC9 (NOLOCK) "
	If mv_par01 $ '6,7,8'
		cQuery += " , " + RetSqlName("SB2") + " SB2 (NOLOCK) "
	EndIf
	cQuery += " WHERE SC9.D_E_L_E_T_ = ' '"
	cQuery += "   AND SC9.C9_FILIAL  = '" + xFilial("SC9") + "'"
	cQuery += "   AND SC5.D_E_L_E_T_ = ' '"
	cQuery += "   AND SC5.C5_FILIAL  = '" + xFilial("SC5") + "'"
	cQuery += "   AND SC5.C5_NUM     = SC9.C9_PEDIDO"
	If mv_par01 $ '6,7,8'
		cQuery += "   AND SB2.D_E_L_E_T_ = ' '"
		cQuery += "   AND SB2.B2_FILIAL  = '" + xFilial("SB2") + "'"
		cQuery += "   AND SB2.B2_COD     = SC9.C9_PRODUTO "
		cQuery += "   AND SB2.B2_LOCAL   = SC9.C9_LOCAL "
	EndIf
	cQuery += cCondicao
	
	If mv_par01 == '1'
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Busco os faturados no D2								     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cCondicao += " AND SC9.C9_NFISCAL = ' ' "	 
	ElseIf mv_par01 == '2'
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Somente Itens Liberados									     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cQuery += " AND (SC9.C9_BLCRED  = ' ' OR SC9.C9_BLEST = ' ')"
		cQuery += " AND SC5.C5_PARCIAL  = ' ' "
		cQuery += " AND SC9.C9_NFISCAL  = ' ' "
		
	ElseIf mv_par01 == '4'
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Somente Itens Bloqueados por Credito					     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cQuery += " AND SC9.C9_BLCRED   NOT IN('01','04') "
		cQuery += " AND SC5.C5_PARCIAL  = ' ' "
		
	ElseIf mv_par01 == '5'
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Somente Itens Bloqueados Parcialmente					     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cQuery += " AND SC5.C5_PARCIAL  = 'N' "
		
	ElseIf mv_par01 == '6'
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Somente Itens com Saldo a Liberar						     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cQuery += " AND SC9.C9_SALDO    > 0   "
		cQuery += " AND (SB2.B2_QATU-SB2.B2_RESERVA-SB2.B2_QACLASS-SB2.B2_QEMP) > 0 "
		cQuery += " AND SC9.C9_NFISCAL  = ' ' "
		cQuery += " AND SC5.C5_PARCIAL <> 'N' "
		cQuery += " AND SC9.C9_BLEST    = '02'"
		
	ElseIf mv_par01 == '7'
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Somente Itens com Bloqueados por Estoque     			     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cQuery += " AND SC9.C9_SALDO    > 0   "
		cQuery += " AND SC9.C9_NFISCAL  = ' ' "
		cQuery += " AND SC5.C5_PARCIAL <> 'N' "
		cQuery += " AND SC9.C9_BLEST    = '02'"
		cQuery += " AND (SB2.B2_QATU-SB2.B2_RESERVA-SB2.B2_QACLASS-SB2.B2_QEMP) = 0 "
		
	ElseIf mv_par01 == '8'
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Somente Itens Reservados no Estoque        			         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		
		cQuery += " AND SC9.C9_NFISCAL  = ' ' "
		cQuery += " AND SC5.C5_PARCIAL <> 'N' "
		cQuery += " AND SC9.C9_SALDO   <= 0   "
		cQuery += " AND SC9.C9_BLCRED   = ' ' "
		cQuery += " AND SC9.C9_BLEST    > ' ' "
		cQuery += " AND (SC9.C9_BLEST  <> '02' OR (SB2.B2_QATU-SB2.B2_RESERVA-SB2.B2_QACLASS-SB2.B2_QEMP) <> 0) "
	EndIf
EndIf	                 

If mv_par01 $ '1,3'
	If Empty(cCliBrw)
		U_UMAT455A(	mv_par01,; //cTipo
					cCondicao,;//cSQL
					mv_par02,; //cPedIni
					mv_par03,; //cPedFim
					mv_par04,; //cCliIni
					mv_par05,; //cCliFim
					mv_par06,; //cOpeIni
					mv_par07,; //cOpeFim
					mv_par08,; //cVenIni
					mv_par09,; //cVenFim
					mv_par10,; //cProIni
					mv_par11,; //cProFim
					DtoS(mv_par12),; //cDatIni
					DtoS(mv_par13))  //cDatFim
	Else                                      
		U_UMAT455A(	"1",; 				//cTipo
					cCondicao,;			//cSQL
					Space(6),; 			//cPedIni
					Replicate("Z",6),; 	//cPedFim
					cCliBrw,; 			//cCliIni
					cCliBrw,; 			//cCliFim
					Space(6),; 			//cOpeIni
					Replicate("Z",6),; 	//cOpeFim
					Space(6),; 			//cVenIni
					Replicate("Z",6),; 	//cVenFim
					Space(15),; 		//cProIni
				 	Replicate("Z",15),; //cProFim
					cDatIni,; 				//cDatIni
					cDatFim)  		//cDatFim
	EndIf					
	Return .T.
EndIf

nTempo_I := Seconds()
cQuery := ChangeQuery(cQuery)

nTempo_Qry := 0
nTempo_Arr := 0

nMaxDias := 1000

If 	!Empty(cCliBrw) .Or.;
	mv_par02 == mv_par03 .Or.;
	mv_par04 == mv_par05 .Or.;
	mv_par06 == mv_par07 .Or.;
	mv_par08 == mv_par09 .Or.;
	mv_par10 == mv_par11
	nStep := 120
Else
	nStep := Min(Min(mv_par13-mv_par12,nMaxDias)/10,30)
EndIf

nTotPer := Int(Min(mv_par13-mv_par12,nMaxDias)/nStep) + 1

ProcRegua(nTotPer)

For nI := mv_par12 To mv_par13 Step nStep
	If lEnd
		Exit
	EndIf
	IncProc()
	If (nI + nStep) < mv_par13 - nMaxDias
		cQuery2 := cQuery
		cQuery2 += " AND SC9.C9_DATALIB >= '"+DtoS(nI)+"'"
		cQuery2 += " AND SC9.C9_DATALIB <= '"+DtoS(mv_par13 - nMaxDias)+"'"
		nI := mv_par13 - nMaxDias + 1 - nStep
	Else
		If nStep == 1
			cQuery2 := cQuery
			cQuery2 += " AND SC9.C9_DATALIB  = '"+DtoS(nI)+"'"
		Else
			cQuery2 := cQuery
			cQuery2 += " AND SC9.C9_DATALIB >= '"+DtoS(nI)+"'"
			cQuery2 += " AND SC9.C9_DATALIB <= '"+DtoS(Min(nI+nStep-1,mv_par13))+"'"
		EndIf
	EndIf
	DbCommitAll()
	MemoWrite("UMATA455",cQuery2)
	
	nTempoAux := Seconds()
	DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery2),"QRY",.T.,.T.)
	
	nTempo_Qry += Seconds() - nTempoAux
	
	DbSelectArea("QRY")
	dbGoTop()
	
	nTempoAux := Seconds()
	QRY->(DbEval( {|| aAdd(aBrw,{NRECNOSC9,NRECNOSC5,/*Pedido*/,/*Cliente*/,/*Produto*/}) }  ) )
	nTempo_Arr += Seconds() - nTempoAux
	QRY->(DbCloseArea())
Next nI

nTempo_Tot := Seconds() - nTempo_I

/*
MsgAlert(	"Tempo Total: " + Str(nTempo_Tot) + Chr(13) + Chr(10) +;
"Tempo Qry:   " + Str(nTempo_Qry) + Chr(13) + Chr(10) +;
"Tempo Arr:   " + Str(nTempo_Arr) + Chr(13) + Chr(10) +;
"Quant Arr:   " + Str(Len(aBrw)) )
*/
If (Len(aBrw) == 0)
	Aviso("Atencao","Nao Existem Pedidos Para Este Cliente !!!",{"Ok"})
	lRet:= .F.
EndIf

Return(lRet)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³A455Ordem ºAutor  ³Fabio Rogerio       º Data ³  01/24/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Rotina para indexar os arrays                               º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function A455Ordem(oPsq,oBrw,aBrw,aOrd,cKey)

A455BrwOrd() //-- Verifica e carrega array auxiliar para ordenação

If (oPsq:nAt == 1) 		//-- "Pedido  + Cliente"
	aBrw:= aSort(aBrw,,,{|x,y| x[3]+x[4] < y[3]+y[4]})
	cKey:= Space(12)
ElseIf (oPsq:nAt == 2)	//-- "Cliente + Pedido"
	aBrw:= aSort(aBrw,,,{|x,y| x[4]+x[3] < y[4]+y[3]})
	cKey:= Space(12)
ElseIf (oPsq:nAt == 3)	//-- "Produto + Pedido  + Cliente"
	aBrw:= aSort(aBrw,,,{|x,y| x[5]+x[3]+x[4] < y[5]+y[3]+y[4]})
	cKey:= Space(27)
EndIf

oBrw:SetArray(aBrw)
oBrw:bLine := {|| FrmCposSC9(aBrw,oBrw) }
oBrw:Refresh()

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³A455PSQ   ºAutor  ³Fabio Rogerio       º Data ³  01/24/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Rotina para pesquisa de pedidos no browse.                  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function A455PSQ(oPsq,oBrw,aBrw,aOrd,cKey)
Local nPos:= 0

A455BrwOrd() //-- Verifica e carrega array auxiliar para ordenação

If (oPsq:nAt == 1) 		//-- "Pedido  + Cliente"
	nPos:= aScan(aBrw,{|x| AllTrim(cKey) $ x[3]+x[4] })
ElseIf (oPsq:nAt == 2)	//-- "Cliente + Pedido"
	nPos:= aScan(aBrw,{|x| AllTrim(cKey) $ x[4]+x[3] })
ElseIf (oPsq:nAt == 3)	//-- "Produto + Pedido  + Cliente"
	nPos:= aScan(aBrw,{|x| AllTrim(cKey) $ x[5]+x[3]+x[4] })
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se achou o item para posiciona-lo.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nPos:= IIf(nPos > 0,nPos,1)
oBrw:nAt:= nPos

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³A455Carac  ºAutor  ³Microsiga           º Data ³  03/13/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Posiciona no SC9 para exibir caracteristica do produto     º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function A455Carac(aBrw,oBrw)

dbSelectArea("SC9")
SC9->(DbGoto(aBrw[oBrw:nAt,1]))
U_DIPA004("SALDO",.F.)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³A455BrwOrdºAutor  ³Microsiga           º Data ³  08/16/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Carrega dados auxilires no array para permitir ordenacao e º±±
±±º          ³ Pesquisa                                                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ UMATA455                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function A455BrwOrd()

If aBrw[Len(aBrw)][3] == Nil
	CursorWait()
	aEval(aBrw,{|x| SC9->(DbGoTo(x[1])),;
	x[3] := SC9->C9_PEDIDO,;
	x[4] := SC9->C9_CLIENTE,;
	x[5] := SC9->C9_PRODUTO  })
	CursorArrow()
EndIf

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DIPG013   ºAutor  ³Microsiga           º Data ³  05/27/16   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function AjustaSX1(cPerg)
Local aRegs 	:= {}

dbSelectArea("SX1")
dbSetOrder(1)

aAdd(aRegs,{cPerg,"01","Data De     ?","","","mv_ch1","D", 8,0,0,"G","","MV_PAR01","","","","","","","","","","","","","","","","","","","","","","","","",''})
aAdd(aRegs,{cPerg,"02","Data Até    ?","","","mv_ch2","D", 8,0,0,"G","","MV_PAR02","","","","","","","","","","","","","","","","","","","","","","","","",''})

PlsVldPerg( aRegs )       

Return
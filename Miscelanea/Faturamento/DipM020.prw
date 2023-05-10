#include "protheus.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDIPM020   บAutor  ณFabio Rogerio       บ Data ณ  10/06/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Rotina para Exibir os Pedidos Nao Entregues do Cliente     บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function DIPM020(cCliente,cLoja)

Local oDlg
Local oPanel
Local cObj      := "ENABLE"
Local cQuery    := ""
Local cNome     := ""
Local cTitulo   := "Consulta de Pedidos Nao Faturados de Cliente"
Local aButtons  := {}
Local aArea	   	:= GetArea()									// Salva a area atual
Local aInfo    	:= {}											// Informacoes para a divisao da area de trabalho
Local aObjects 	:= {}											// Definicoes dos objetos
Local aSize    	:= {}											// Size da Dialog
Local aItens 	:= {}	  										// Size da Dialog
Local _xAliasSC5:= SC5->(GetArea())    // MCVN - 13/08/09
Local _lOldAlt  := ALTERA  // Guarda valor da variแvel ALTERA MCVN - 13/08/09
Local _lOldInc  := INCLUI  // Guarda valor da variแvel INCLUI MCVN - 13/08/09 teste
 
If "MATA310"$Upper(FunName())
	Return .T.
EndIf

U_SavePerg("SC5")

Private aCores  := {	{"ENABLE"	 , "Item Liberado"},;
						{"DISABLE"   , "Item Faturado"},;
						{"BR_AZUL"   , "Item Bloqueado por Credito"},;
						{"BR_MARROM" , "Item Rejeitado pelo Credito"},;
						{"BR_PINK"   , "Item Bloqueado Parcialmente" },;
						{"BR_AMARELO", "Item Com Saldo a Liberar" },;
						{"BR_LARANJA", "Item Reservado" },;
						{"BR_PRETO"  , "Item Bloqueado por Estoque"}}

If ("TMK"$FunName())  // MCVN - 13/08/09
	DEFAULT cCliente:= SUA->UA_CLIENTE
	DEFAULT cLoja   := SUA->UA_LOJA
Else                                  
	DEFAULT cCliente:= SC5->C5_CLIENTE
	DEFAULT cLoja   := SC5->C5_LOJACLI
Endif

U_DIPPROC(ProcName(0),U_DipUsr()) // MCVN - 22/01/2009

// Nใo chama rotina quando o pedido ้ gerado pelo m๓dulo de licita็ใo
IF !("DIPAL10" $ FunName()) // MCVN - 05/06/2007 

aButtons  := {	{"ANALITICO",{|| LjMsgRun("Visualizando Pedido...","Aguarde",{||M020Visual(aItens,oLbx)})},"Visualiza Pedido"},;
				{"FILTRO"   ,{|| BrwLegenda(cTitulo,"Legenda",aCores)},"Legenda"}}

cQuery := " SELECT * FROM " + RetSqlName("SC9") + " SC9 "
cQuery += " WHERE SC9.D_E_L_E_T_ = '' AND SC9.C9_FILIAL = '" + xFilial("SC9") + "' AND SC9.C9_CLIENTE = '" + cCliente + "' AND SC9.C9_LOJA = '" + cLoja + "' AND SC9.C9_NFISCAL = ''"
cQuery += " ORDER BY C9_PEDIDO,C9_ITEM,C9_SEQUEN"
cQuery := ChangeQuery(cQuery)

DbCommitAll()
dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), "QRY", .F., .T.)

   		While !Eof()
                      
		SC5->(dbSetOrder(1))
	    SC5->(dbSeek(xFilial("SC5")+QRY->C9_PEDIDO))

		SC9->(dbSetOrder(1))
		SC9->(dbGoTo(QRY->R_E_C_N_O_))

		If (U_C5PARCIAL() == 'N')
			cObj:= "BR_PINK"   //Item Bloqueado pelo usuario
		ElseIf (!Empty(QRY->C9_NFISCAL))	//Item Faturado
			cObj:= "DISABLE"
		ElseIf Empty(QRY->C9_BLEST)  .And. Empty(QRY->C9_BLCRED)
			cObj:= "ENABLE" 	//Item Liberado
		ElseIf (QRY->C9_BLCRED $ '01/04')
			cObj:= "BR_AZUL"   //Item Bloqueado - Credito
		ElseIf (QRY->C9_BLCRED == '09')
			cObj:= "BR_MARROM"   //Item Rejeitado - Credito
		ElseIf (U_SALDSB2(QRY->C9_PRODUTO) > 0 .And. QRY->C9_SALDO  > 0 .And. QRY->C9_BLEST == '02')
			cObj:= "BR_AMARELO"//Item Com Saldo a Liberar
		ElseIf (U_SALDSB2(QRY->C9_PRODUTO) >= 0 .And. QRY->C9_SALDO == 0 .And. QRY->C9_BLEST == '02')
			cObj:= "BR_LARANJA"//Item Reservado no Estoque
		ElseIf (U_SALDSB2(QRY->C9_PRODUTO) <= 0 .And. QRY->C9_SALDO  > 0 .And. QRY->C9_BLEST == '02')
			cObj:= "BR_PRETO"  //Item Bloqueado - Estoque
		EndIf	

		aAdd(aItens,{	LoadBitMap(GetResources(), cObj),;
					QRY->C9_PEDIDO,;
					QRY->C9_ITEM,;
					QRY->C9_SEQUEN,;
					QRY->C9_PRODUTO,;
					Posicione("SB1",1,xFilial("SB1")+QRY->C9_PRODUTO,"B1_DESC"),;
					QRY->C9_QTDLIB,;
					QRY->C9_SALDO,;
					U_SALDSB2(QRY->C9_PRODUTO),;
					QRY->C9_PRCVEN,;
					Stod(QRY->C9_DATALIB),;
					QRY->C9_OPERADO,;
					Posicione("SU7",1,xFilial("SU7")+QRY->C9_OPERADO,"U7_NOME"),;
					QRY->C9_VEND,;
					Posicione("SA3",1,xFilial("SA3")+QRY->C9_VEND,"A3_NOME") })
		dbSelectArea("QRY")
		dbSkip()
	End
	QRY->(dbCloseArea())

If (Len(aItens) == 0)
	aAdd(aItens,{	"","","","","","",0,0,0,0,Ctod(""),"","","","" })
	Return(.T.)
EndIf               

aSize    := MsAdvSize(.T.,.T.)
aInfo    := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ]+60 , 2, 2 }

aAdd( aObjects, { 100, 100, .T., .T. } )
aPosObj := MsObjSize( aInfo, aObjects , .T. )

DEFINE MSDIALOG oDlg FROM 0,0 TO aSize[6],aSize[5]*1.30 TITLE cTitulo Of oMainWnd PIXEL

	@aPosObj[1,1], 05 LISTBOX oLbx VAR nLbx FIELDS HEADER "","Pedido","Item","Seq.","Produto","Descricao","Qtde. Liberada","Saldo a Liberar","Estoque","Preco Unitario","Data Liberacao","Operador","Nome","Vendedor","Nome" SIZE aPosObj[1,4],aPosObj[1,3]+15 OF oDlg PIXEL 
	oLbx:SetArray(aItens)
	oLbx:bLine:= {|| {	aItens[oLbx:nAT,1],;
						aItens[oLbx:nAT,2],;
						aItens[oLbx:nAT,3],;
						aItens[oLbx:nAT,4],;
						aItens[oLbx:nAT,5],;
						aItens[oLbx:nAT,6],;
						Transform(aItens[oLbx:nAT,7],"@E 999999999"),;
						Transform(aItens[oLbx:nAT,8],"@E 999999999"),;
						Transform(aItens[oLbx:nAT,9],"@E 999999999"),;
						Transform(aItens[oLbx:nAT,10],PesqPict("SC9","C9_PRCVEN")),;
						Dtoc(aItens[oLbx:nAT,11]),;
						aItens[oLbx:nAT,12],;
						aItens[oLbx:nAT,13],;
						aItens[oLbx:nAT,14],;
						aItens[oLbx:nAT,15]}}                                                          
	oLbx:Align	   := CONTROL_ALIGN_ALLCLIENT
					
ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||oDlg:End()},{||oDlg:End()},,aButtons) CENTERED

Endif               

// A fun็ใo de visualiza็ใo de pedido A410Visual("SC5",Recno(),2) altera as variแveis INCLUI e ALTERA
// Entใo guardamos no inํcio da rotina e voltamos na saida da mesma. 
// MCVN - 13/08/09     
U_RestPerg()

ALTERA := _lOldAlt
INCLUI := _lOldInc   

RestArea(_xAliasSC5)
Return(.T.)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณC001VisualบAutor  ณMicrosiga           บ Data ณ  11/22/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRotina para exibir os detalhes do movimento selecionado.    บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function M020Visual(aItens,oLbx)
                  
Local _xAlias   := GetArea() // MCVN - 13/08/09

U_SavePerg("SC5")

DbSelectArea("SC5")
DbSetOrder(1)
IF DbSeek(xFilial("SC5")+aItens[oLbx:nAT,2])
	cCadastro := "Visualiza็ใo de Pedidos de Venda Nใo Entregues do Cliente "
	aRotina := { {  "Visualizar","A410Visual",0,2 } }
	A410Visual("SC5",Recno(),1)
EndIF

U_RestPerg()

RestArea(_xAlias)  // MCVN - 13/08/09
Return

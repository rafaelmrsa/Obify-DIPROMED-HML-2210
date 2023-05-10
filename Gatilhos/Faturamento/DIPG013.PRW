/*====================================================================================\
|Programa  | DIPG013       | Autor | Rodrigo Franco             | Data | 25/02/2002   |
|=====================================================================================|
|Descrição | Mostra posicao do pedido de venda                                       |
|          |                                                                          |      
|          |                                                                          |
|=====================================================================================|
|Sintaxe   | DIPG013                                                                  |
|=====================================================================================|
|Uso       | Especifico DIPROMED                                                      |
|=====================================================================================|
|........................................Histórico....................................|
|Rafael    | DD/MM/AA - Descrição                                                     |
|Eriberto  | DD/MM/AA - Descrição                                                     |
\====================================================================================*/

#INCLUDE "RWMAKE.CH"
User Function DIPG013(_cFun)
Local aArea     := GetArea()
Local _cRet     := IIF("TMK"$FunName(),M->UA_CLIENTE,M->C5_CLIENTE)
Local cCondicao := ""
Local aIndSC9   := {}    
Local _lOldAlt  := ALTERA   // Guarda valor da variável ALTERA MCVN - 13/08/09
Local _lOldInc  := INCLUI   // Guarda valor da variável INCLUI MCVN - 13/08/09
Local cPerg     := "DIPG13"
Local aCores    := {{ "SC9->C9_BLCRED=='10'.And.SC9->C9_BLEST=='10'",'DISABLE'},; //Item Faturado
{"SC9->C9_PARCIAL=='N'" , 'BR_PINK' },;											  //Item Bloqueado pelo usuario
{"SC9->C9_BLEST=='  '.And.SC9->C9_BLCRED2=='  '",'ENABLE' },;					  //Item Liberado
{"SC9->C9_BLCRED2=='01'.And.SC9->C9_BLCRED<>'10'",'BR_AZUL'},;		 			  //Item Bloqueado - Credito
{"SALDOSB2() > 0 .And. SC9->C9_SALDO > 0 " , 'BR_AMARELO' },; 				  //Item Bloqueado por Estoque, Porem chegou Estoque
{"SC9->C9_BLEST=='02'" ,'BR_PRETO' }}                                             //Item Bloqueado - Estoque
Local _aRadio
Local _aCpos := {}

Private bFiltraBrw := {|| Nil}
Private cCadastro  := OemToAnsi("Pedidos Pendentes")

Private _aCoresLeg := {{"ENABLE","Item Liberado"},;
{"DISABLE"   , "Item Faturado"},;
{"BR_AZUL"   , "Item Bloqueado por Credito"},;
{"BR_PINK"   , "Item Bloqueado Parcialmente" },;
{"BR_AMARELO", "Item Com Saldo a Liberar" },;
{"BR_PRETO"  , "Item Bloqueado por Estoque"}}

Private aRotina := { { 'Pesquisa','PesqBrw', 0 , 1},;		 	     //Pesquisa
{ 'Visualiza Pedido','U_DIPG13Vi', 0 , 2},;				     	 //Visualiza pedido
{ 'Legenda','BrwLegenda(cCadastro,"Legenda",_aCoresLeg)', 0 , 5}}    //Legenda
//{ 'Fatura','U_NAO1()', 0 , 3},;										 //Fatura
//{ 'Excluir','U_NAO2()', 0 , 4},;					 				 //Exclui

If (Type("l410Auto") == "U" .OR. !l410Auto)
    
	AjustaSX1(cPerg)
	//MsgInfo("Carla, estou testando, se esta msg nao aparecer me avise. obrigado")    // Eriberto 27/10/2004
	U_DIPPROC(ProcName(0),U_DipUsr()) // JBS 05/10/2005 - Gravando o nome do Programa no SZU
	dbSelectArea("SC9")
	dbSetOrder(1)
	If _cFun <> "GAT"
		Private _nRadio := 1
		_aRadio   := {"Todos","Item Liberado","Item Faturado","Item Bloqueado por Credito",;
		"Item Bloqueado Parcialmente","Item Com Saldo a Liberar","Item Bloqueado por Estoque"}
		
		@ 050,110 To 200,400 Dialog _oDlg Title OemToAnsi("Quais Pedidos ?")
		@ 010,010 RADIO _aRadio VAR _nRadio
		
		@ 060,110 BmpButton Type 1 Action Close(_oDlg)
		
		Activate MsDialog _oDlg Centered Valid _nRadio > 0
		
		If _nRadio == 1
			u_UMata455(_cRet)
			
			ALTERA := _lOldAlt
			INCLUI := _lOldInc
			RestArea(aArea)   			
			Return .T.
		EndIf                                                     
		
		_Par1 := Alltrim(Str(_nRadio))//+"-"+_aRadio[_nRadio]
		
		dbSelectArea("SC9")
		dbSetOrder(1)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Inicializa variavel com a condicao padrao do Filtro, ou quando Mv_par01=="1". ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cCondicao := "SC9->C9_FILIAL=='"+xFilial("SC9")+"'.And."
		
		IF Substr(_par1,1,1) == "2"
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Somente Itens Liberados									     ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cCondicao += "C9_BLEST=='  ' .And. C9_BLCRED2=='  ' .And."
		ElseIF Substr(_par1,1,1) == "3"
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Somente Itens Faturados									     ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cCondicao += "SC9->C9_BLCRED=='10'.And.SC9->C9_BLEST=='10' .And."
		ElseIF Substr(_par1,1,1) == "4"
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Somente Itens Bloqueados por Credito					     ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cCondicao += "SC9->C9_BLCRED2=='01'.And.SC9->C9_BLCRED<>'10' .And."
		ElseIF Substr(_par1,1,1) == "5"
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Somente Itens Bloqueados Parcialmente					     ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cCondicao += "SC9->C9_PARCIAL=='N' .And."
		ElseIF Substr(_par1,1,1) == "6"
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Somente Itens com Saldo a Liberar						     ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cCondicao := "SALDOSB2()> 0 .And. SC9->C9_SALDO > 0 .And."
			cCondicao += "C9_BLEST<>'  '.And.C9_BLEST<>'10' .And."
		ElseIF Substr(_par1,1,1) == "7"
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Somente Itens com Bloqueados por Estoque     			     ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cCondicao += "SC9->C9_BLEST=='02' .And."
		EndIF
		
		
	Else
		
		cCondicao := "SC9->C9_FILIAL=='"+xFilial("SC9")+"'.And."
		cCondicao += "SC9->C9_BLCRED<>'10'.And.SC9->C9_BLEST<>'10' .And."
		
	Endif
	
	// aqui inicio
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Variaveis para o complemento do Filtro, ou quando Mv_par01=="1" ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cCondicao += 'SC9->C9_CLIENTE=="'+_cRet+'"' // ERIBERTO 27/10/04 .And.C9_CLIENTE<="'+_cRet+'"'

	uMvAux1 := mv_par01
	uMvAux2 := mv_par02
	                                                
	Pergunte(cPerg,.T.) 	                                                
	                                                
	If !Empty(mv_par01)
		cCondicao += ' .And. SC9->C9_DATALIB >= StoD("'+DtoS(mv_par01)+'")' 
	EndIf                              
	
	If !Empty(mv_par02)
		cCondicao += ' .And. SC9->C9_DATALIB <= StoD("'+DtoS(mv_par02)+'")' 
	EndIf              
	
	mv_par01 := uMvAux1
	mv_par02 := uMvAux2
	
	bFiltraBrw := {|| FilBrowse("SC9",@aIndSC9,@cCondicao) }
	Eval(bFiltraBrw)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Endereca a funcao de BROWSE                                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	IF SC9->(Eof())
		IF _cFun <> "GAT"
			MsgInfo("Nao há SALDOS para este cliente nesta consulta")
		Endif
	Else
		mBrowse( 7, 4,20,74,"SC9",,,,,,aCores)
	EndIF
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Restaura a integridade da rotina                                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SC9")
	RetIndex("SC9")
	dbClearFilter()
	aEval(aIndSc9,{|x| Ferase(x[1]+OrdBagExt())})
	
	//aqui fim
	
EndIf 

// A função de visualização de pedido A410Visual("SC5",Recno(),2) altera as variáveis INCLUI e ALTERA
// Então guardamos no início da rotina e voltamos na saida da mesma. 
// MCVN - 13/08/09
ALTERA := _lOldAlt
INCLUI := _lOldInc

RestArea(aArea)
Return(.t.)     // Eriberto 28/09/2004 coloquei .t.  e tirei do gatilho


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DIPG13Vi  ºAutor  ³Microsiga           º Data ³  01/28/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Visualização do PV                                         º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function DIPG13Vi(cAlias, nReg, nOpc)

Local _xAlias   := GetArea() // MCVN - 13/08/09

U_SavePerg("SC5")

DbSelectArea("SC5")
DbSetOrder(1)
IF DbSeek(xFilial("SC5")+SC9->C9_PEDIDO)
	A410Visual("SC5",Recno(),nOpc)
EndIF

U_RestPerg()

RestArea(_xAlias)  // MCVN - 13/08/09
Return Nil
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
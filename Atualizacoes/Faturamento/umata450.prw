#INCLUDE "RWMAKE.CH"
#INCLUDE "FONT.CH"
#INCLUDE "COLORS.CH"
#DEFINE CR    chr(13)+chr(10) // Carreage Return (Fim de Linha)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Fun‡…o    ³ UMATA450 ³ Autor ³    Alexandro Dias     ³ Data ³ 12.09.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa de Liberacao de Credito.                          ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Array contendo as Rotinas a executar do programa      ³
//³ ----------- Elementos contidos por dimensao ------------     ³
//³ 1. Nome a aparecer no cabecalho                              ³
//³ 2. Nome da Rotina associada                                  ³
//³ 3. Usado pela rotina                                         ³
//³ 4. Tipo de Transa‡„o a ser efetuada                          ³
//³    1 - Pesquisa e Posiciona em um Banco de Dados             ³
//³    2 - Simplesmente Mostra os Campos                         ³
//³    3 - Inclui registros no Bancos de Dados                   ³
//³    4 - Altera o registro corrente                            ³
//³    5 - Remove o registro corrente do Banco de Dados          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

User Function DipMTA450()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local aArea     := GetArea()
Local cFilSC9   := ""
Local cCondicao := ""
Local aIndSC9   := {}
Local aCores    := {{ "C9_BLCRED=='10'.And.C9_BLEST=='10'",'DISABLE'},;		   	//Item Faturado
{"C9_BLCRED2=='  '",'ENABLE' },;	//Item Liberado
{"C9_BLCRED2=='01'.And.C9_BLCRED<>'10'",'BR_AZUL'},;	//Item Bloqueado - Credito
{"C9_BLEST<>'  '.And.C9_BLEST<>'10'",'BR_PRETO'}}		//Item Bloqueado - Estoque
Private bFiltraBrw := {|| Nil}
Private lPedBloq   := .F. // JBS 04/08/2005
If cPaisLoc $ "ARG|POR|EUA"
	Private aArrayAE:={}
EndIf
Private cCadastro:= OemToAnsi("Liberação de Crédito")    //"Libera‡„o de Cr‚dito"
Private aRotina   := {  {"Pesquisar","PesqBrw", 0 , 1},;       //"Pesquisar"
{"Manual","U_UA450LibMan(Alias())", 0 , 0},;     //"Manual"
{"Legenda","U_UA450Legend()", 0 , 3}}      //"Legenda"
Private cPorta  := Left(Upper(AllTrim(GETMV("MV_LPT_PRE"))),4) // MCVN 20/01/2006 
Private cCaminho:= Upper(AllTrim(GETMV("MV_LPT_PRE"))) // MCVN 20/01/2006
Private cPerg := "MTA451"

U_DIPPROC(ProcName(0),U_DipUsr()) // JBS 05/10/2005 - Gravando o nome do Programa no SZU

// TESTANDO ISPRINTER("LPT4")  ERIBERTO 27-06-2005
/*
If !ISPRINTER(cPorta) // JBS 18/10/2005
	MSGBOX(cPorta+" DESCONECTADA"+chr(13)+chr(13)+"Por favor Fale com o Sr. Eriberto","ATENCAO!")  // JBS 18/10/2005
EndIf 
*/ 

    // Emite normalmente a Pré-Nota
    WaitRun("NET USE "+cPorta+" /DELETE YES")  // MCVN 20/01/2006
  	WaitRun("NET USE "+cCaminho)  // MCVN 20/01/2006

   
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ So Ped. Bloqueados   mv_par01          Sim Nao               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
           
// Para ajustar a pergunta ao tamanho do campo do SX1 - Por Sandro em 19/11/09. 
DbselectArea("SX1")
DbSetOrder(1)
cPerg := PADR(cPerg, len(SX1->X1_GRUPO), " ")             

IF Pergunte(cPerg,.T.)

	IF (Existblock("M450FIL"))
		cFilSC9 := ExecBlock("M450FIL",.f.,.f.)
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³EXECUTAR CHAMADA DE FUNCAO p/ integracao com sistema de Distribuicao - NAO REMOVER ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If GetMV("MV_FATDIST") == "S" // Apenas quando utilizado pelo modulo de Distribuicao
		D450LibCg(@cFilSC9)
	EndIf
	If ( MV_PAR01 == 1 .Or. !Empty(cFilSC9) )
		If ( mv_par01 == 1 )
			cFilSC9  := If(Empty(cFilSC9),".T.",cFilSC9)
			cCondicao:='C9_BLCRED2=="01".And.'
			cCondicao+='C9_BLCRED<>"10".And.'
			cCondicao+='C9_PARCIAL<>"N".And.'
			cCondicao+='C9_FILIAL=="'+xFilial("SC9")+'".And.'
			cCondicao+=cFilSC9
		EndIf
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Realiza a Filtragem                                                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	bFiltraBrw := {|| FilBrowse("SC9",@aIndSC9,@cCondicao) }
	Eval(bFiltraBrw)
EndIf
dbSelectArea("SC9")
mBrowse( 7, 4,20,74,"SC9",,,,,,aCores)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Restaura a integridade da rotina                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SC9")
RetIndex("SC9")
dbClearFilter()
aEval(aIndSc9,{|x| Ferase(x[1]+OrdBagExt())})
RestArea(aArea)

Return(.T.)



/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A450LibMan³ Autor ³ Claudinei M. Benzi    ³ Data ³ 10.01.92 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Rotina para gerar liberacoes manuais                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ MATA450                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User FUNCTION UA450LibMan(cAlias)

Local aArea		:= GetArea()
Local aAreaSC5  := SC5->(GetArea())
Local cPedido	:= ""
Local lContinua	:= .T.
Local nCntFor	:= 0
Local cFiltro	:= ""
Local cKey		:= ""

IF (Existblock("MT450MAN"))
	lContinua := ExecBlock("MT450MAN",.f.,.f.)
Endif

/*
//Valida se o usuário pode liberar crédito de pedido acima de R$ 50.000,00.
//FB -  30/08/18
IF (SC9->C9_QTDVEN * SC9->C9_PRCVEN) > Val(GetMV("ES_VALLIB")) //50000.00 
	IF !ALLTRIM(RetCodUsr()) $ ALLTRIM(GetMV("ES_XUSRLIB"))
		ShowHelpDlg("UA450LibMan", {"ES_XUSRLIB-Você não tem permissão para liberar crédito de Pedidos de Venda com Valor (ES_VALLIB) acima de R$ 50.000,00.",""},3,;
		                           {"Selecione um Pedido de Venda com valor menor que R$ 50.000,00.",""},3)    
		Return(.F.)                          
	ENDIF
ENDIF
//FIM FB
*/

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se o registro posicionado eh valido                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ( SC9->C9_BLCRED == "10" .Or. SC9->C9_BLEST == "10" )
	HELP(" ",1,"A450NFISCA")
	lContinua := .F.
EndIf
If ( SC9->C9_BLCRED2 == "  " .And. SC9->C9_BLEST == "  " )
	Help(" ",1,"A450JALIB")
	lContinua := .F.
EndIf
If ( Empty(SC9->C9_BLCRED2) .And. !Empty(SC9->C9_BLEST) )
	Help(" ",1,"A450ESTOQ")
	lContinua := .F.
EndIf
If ( lContinua )
	nOpcA := U_Ua450Tela( @lContinua , .T. , .F.)
	#IFDEF TOP
		IF TcSrvType() == "AS/400"
			dbSelectArea("SC9")
			cFiltro := dbFilter()
			cKey := IndexKey()
			Set Filter to
			dbSetOrder(1)
		Endif
	#ENDIF
	If ( nOpcA == 1 )
		//a450Grava(1,.T.,.F.)
		IF (existblock("MTA450I"))
			ExecBlock("MTA450I",.f.,.f.)
		Endif
	ElseIf nOpcA == 3 // Rejeita o Pedido
		//a450Grava(2,.T.,.F.)
		Ua450Rejeita(SC9->C9_PEDIDO,U_DipUsr())
		IF (existblock("MTA450R"))
			ExecBlock("MTA450R",.f.,.f.)
		Endif
	ElseIf nOpcA == 4 // Libera o Crédito para o Pedido
		cPedido := SC9->C9_PEDIDO
		If !lPedBloq
			dbSelectArea("SC5")
			dbSetOrder(1)
			MsSeek(cFilial+cPedido)
			RecLock("SC5",.F.)
			
			dbSelectArea("SC9")
			dbSetOrder(1)
			MsSeek(cFilial+cPedido)
			While ( !Eof() .And. SC9->C9_FILIAL == xFilial("SC9") .And.	SC9->C9_PEDIDO == cPedido )
				If ( (Empty(SC9->C9_BLCRED) .and. Empty(SC9->C9_BLCRED2) ) .Or. SC9->C9_BLCRED == "10" )
					dbSkip()
					Loop
				EndIf
				//a450Grava(1,.T.,.F.)
				RecLock("SC9",.F.)
				Replace C9_BLCRED2 With Space(2)
				MsUnLock()
				dbSkip()
			EndDo
			
			SC5->(MsUnlock())
			U_DiprKardex(cPedido,U_DipUsr(),"Aqui está o Problema",.T.,"26") // JBS 26/10/2005,26/08/2005 
			// Eriberto
			// vamos imprimir a PRE-NOTA quando liberar credito
			dbSelectArea("SC9")
			dbClearFilter()
			U_prenota_D(cPedido,'DIPMTA450')
			dbSelectArea("SC9")
			//bFiltraBrw := {|| FilBrowse("SC9",@aIndSC9,@cCondicao) }
			Eval(bFiltraBrw)
		Else
			MsgInfo("Este pedido não pode ser liberado!"+chr(13)+chr(10)+;
			"Ele foi bloqueado pelo operador!","Atenção")
		EndIf
	Endif
	#IFDEF TOP
		IF TcSrvType() == "AS/400"
			dbSelectArea("SC9")
			IndRegua("SC9","",cKey,,cFiltro,)
		Endif
	#ENDIF
EndIf

MsUnLockAll()
RestArea(aAreaSC5)
RestArea(aArea)
Return(	lContinua )

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³SomaAtraso³ Autor ³ Wilson                ³ Data ³ 27.12.95 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Somar os titulos em atraso da filial                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ MATA450                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function USomaAtraso(cFilNew)
Local cSalvFil := cFilAnt, nValAtraso := 0, cAlias := Alias()
cFilAnt := cFilNew

dbSelectArea("SE1")
dbSetOrder(8)
MsSeek(cFilial+SA1->A1_COD+SA1->A1_LOJA+"A")
While ( !Eof() .And. SE1->E1_FILIAL == xFilial("SE1") .And. ;
	SE1->E1_CLIENTE+SE1->E1_LOJA == SA1->A1_COD+SA1->A1_LOJA .And.;
	SE1->E1_STATUS == "A" )
	If ( dDataBase > SE1->E1_VENCREA )
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Caso o t¡tulo seja de qualquer natureza credora (-) o saldo  ³
		//³ deve ser abatido. Os t¡tulos tipo RA (Receb.Antecipado),     ³
		//³ NCC (Nota de Cr‚dito) e PR (Provis¢rio) n„o precisam de      ³
		//³ tratamento especial. Bops 00323-A                            ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If SE1->E1_TIPO $ MVABATIM
			nValAtraso += xMoeda( SE1->E1_SALDO , SE1->E1_MOEDA , 1 )
		ElseIF !(SE1->E1_TIPO $ MVRECANT+"/"+MVPROVIS+"/"+MV_CRNEG)
			nValAtraso -= xMoeda( SE1->E1_SALDO , SE1->E1_MOEDA , 1 )
		Endif
	EndIf
	dbSkip()
EndDo
dbSetOrder(1)
cFilAnt := cSalvFil
dbSelectArea(cAlias)
Return (nValAtraso)

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A450F4Con ³ Autor ³ Rosane Luciane Chene  ³ Data ³ 08.02.95 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Rotina para consultar dados clientes                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ MATA450                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function UA450F4Con()

Local aBackRot := aClone(aRotina)
Local cPerg := "FIC010"

DbSelectArea("SA1")
              
// Para ajustar a pergunta ao tamanho do campo do SX1 - Por Sandro em 19/11/09. 
DbselectArea("SX1")
DbSetOrder(1)

cPerg := PADR(cPerg, len(SX1->X1_GRUPO), " ")                          
             

If ( Pergunte(cPerg,.T.) )
	Fc010Con()
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Restaura a integridade dos dados                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aRotina := aClone(aBackRot)

Return(Nil)

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A450ConEst³ Autor ³ Armando Tadeu Buchina ³ Data ³ 23.09.99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Rotina para consultar dados de estoque                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ MATA450                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function Ua450ConEst()

Local aArea		:= GetArea()
Local aAreaSB1  := SB1->(GetArea())
Local aAreaSB2  := SB2->(GetArea())
Local lMta450Con:= (ExistBlock("MTA450CO"))
Local cProduto	:= SC6->C6_PRODUTO
Local cLocal	:= SC6->C6_LOCAL
Local nStok    := 0

If lMta450Con
	
	ExecBlock("MTA450CO",.f.,.f.)

Else
	dbSelectArea("SB1")
	dbSetOrder(1)
	If ( MsSeek(xFilial()+cProduto,.F.) )
		dbSelectArea("SB2")
		dbSetOrder(1)
		If MsSeek(xFilial()+cProduto+cLocal,.F.)
			nStok:= SaldoSb2()
		EndIf
		DEFINE MSDIALOG oDlg FROM  62,1 TO 293,365 TITLE OemToAnsi("POSICAO DO ESTOQUE") PIXEL				//"POSI€AO DO ESTOQUE"
		@ 0, 2 TO 28, 181  //Label ""  //OF oDlg  //PIXEL
		@ 31, 2 TO 91, 181 //Label  "" //OF oDlg // PIXEL
		@ 8, 4 SAY OemToAnsi("Produto :") SIZE 31, 7 //OF oDlg PIXEL			//"Produto :"
		@ 7, 39 SAY cProduto + " /" + Subs(SB1->B1_DESC,1,20) SIZE 140, 7 //OF oDlg PIXEL
		@ 16, 5 SAY OemToAnsi("Local    :") SIZE 31, 7 //OF oDlg PIXEL			//"Local    :"
		@ 16, 39 SAY cLocal SIZE 13, 7 //OF oDlg PIXEL
		@ 37, 9 SAY OemToAnsi("Pedido de Vendas em Aberto") SIZE 92, 7 //OF oDlg PIXEL			//"Pedido de Vendas em Aberto"
		@ 37, 118 SAY B2_QPEDVEN  SIZE 53, 7 //OF oDlg PIXEL
		@ 45, 9 SAY OemToAnsi("Quantidade Empenhada") SIZE 88, 7 //OF oDlg PIXEL			//"Quantidade Empenhada"
		@ 45, 118 SAY B2_QEMP SIZE 53, 7 //OF oDlg PIXEL
		@ 53, 9 SAY OemToAnsi("Qtd.Prevista p/Entrar") SIZE 88, 7 //OF oDlg PIXEL			//"Qtd.Prevista p/Entrar"
		@ 53, 118 SAY B2_SALPEDI SIZE 53, 7 //OF oDlg PIXEL
		@ 61, 9 SAY OemToAnsi("Quantidade Reservada (A)") SIZE 88, 7 //OF oDlg PIXEL			//"Quantidade Reservada (A)"
		@ 61, 118 SAY B2_RESERVA SIZE 53, 7 //OF oDlg PIXEL
		@ 69, 9 SAY OemToAnsi("Saldo Atual (B)") SIZE 53, 7 //OF oDlg PIXEL			//"Saldo Atual (B)"
		@ 69, 118 SAY B2_QATU SIZE 53, 7 //OF oDlg PIXEL
		@ 78, 9 SAY OemToAnsi("Dispon¡vel (B - A)") SIZE 53, 7 //OF oDlg PIXEL			//"Dispon¡vel (B - A)"
		@ 78, 118 SAY nStoK SIZE 53, 7 //OF oDlg PIXEL
		DEFINE SBUTTON FROM 98, 149 TYPE 1 ACTION (oDlg:End()) ENABLE OF oDlg
		ACTIVATE MSDIALOG oDlg CENTERED
	Else
		HELP(" ",1,"C6_PRODUTO")
	EndIf
EndIf
RestArea(aAreaSB1)
RestArea(aAreaSB2)
RestArea(aArea)
Return
/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³A450Legend³Autor  ³ Eduardo Riera         ³ Data ³13.09.2000 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³Demonstra a legenda das cores da mbrowse                     ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                       ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                       ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Esta rotina monta uma dialog com a descricao das cores da    ³±±
±±³          ³Mbrowse.                                                     ³±±
±±³          ³                                                             ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Materiais                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function UA450Legend()
BrwLegenda(cCadastro,"Legenda",{	{"ENABLE","Item Liberado"},;//"Legenda"###"Item Liberado"
{"DISABLE","Item Faturado"},;    //"Item Faturado"
{"BR_AZUL","Item Bloqueado - Credito"},;    //"Item Bloqueado - Credito"
{"BR_PRETO","Item Bloqueado - Estoque"}})   //"Item Bloqueado - Estoque"
Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³a450Tela  ³ Autor ³ Eduardo Riera         ³ Data ³ 31.08.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Exibe a Tela de Liberacao Manual de Credito - Cred/Estoque ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Opcao Selecionada                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±³          ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function Ua450Tela(lContinua , lAvCred , lAvEst)

Local aArea     := GetArea()
Local aAreaSC9  := SC9->(GetArea())
Local dLimLib   := dDataBase
Local nSaldoLC  := 0
Local nValItem  := 0
Local nValPed   := 0
Local nLimCred  := 0
Local nMoeda    := 0
Local nQtdVen   := 0
Local nSalPedL  := 0
Local nSalPed   := 0
Local nSalDup	:= 0
Local nValAtraso:= 0
Local nOpca 	:= 0
Local nSalvEmp  := 0
Local nCntFor   := 0
Local cDescBloq := ""
Local cDescri   := ""
Local cCondSC9  := ""
Local oBtn
Local oDlg
Local bWhile    := Nil
Local nMCusto   := Val(GetMV("MV_MCUSTO"))
Local nMoedaAp  := GetNewPar("MV_APRESLC",1)
Local	nDecs		 := MsDecimais(nMoedaAp)
Local aSaldos
Local lLiberado := .F.
Private cCadastro := OemToAnsi("Consulta Posi‡„o Clientes")      //"Consulta Posi‡„o Clientes"
lPedBloq := .F.  // JBS 04/08/2005
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Posiciona no SC5                                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ( lContinua )
	dbSelectArea("SC5")
	dbSetOrder(1)
	If dbSeek(xFilial()+SC9->C9_PEDIDO)
		If !SoftLock("SC5")
			lContinua := .F.
		EndIf
	EndIf
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica o Tipo de Analize                                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ( SC5->C5_TIPLIB=="2" )
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Quando for por PV deve-se somar todos os SC9 gerados para o item        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SC9")
	dbSetOrder(1)
	dbSeek(xFilial("SC9")+SC9->C9_PEDIDO)
	cCondSC9 := SC9->C9_PEDIDO
	bWhile := {||  xFilial("SC9") == SC9->C9_FILIAL .And.;
	cCondSC9 == SC9->C9_PEDIDO }
Else
	cCondSC9 := SC9->C9_PEDIDO+SC9->C9_ITEM+SC9->C9_SEQUEN
	bWhile   := {||   xFilial("SC9") == SC9->C9_FILIAL .And.;
	cCondSC9 == SC9->C9_PEDIDO+SC9->C9_ITEM+SC9->C9_SEQUEN }
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica o tipo de analise a ser efetuado ( Filial ou Matriz )    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ( GetMv("MV_CREDCLI") == "L" )
	dbSelectArea("SA1")           // Posiciona cliente
	dbSetOrder(1)
	dbSeek(cFilial+SC5->C5_CLIENTE+SC5->C5_LOJACLI)
	nLimCred := xMoeda(SA1->A1_LC,nMCusto,1,dDatabase)
	nSalPed  := xMoeda(SA1->A1_SALPED,nMCusto,1,dDataBase) + xMoeda(SA1->A1_SALPEDB,nMCusto,1,dDataBase)
	nSalPedL := xMoeda(SA1->A1_SALPEDL,nMCusto,1,dDataBase)
	nSalDup  := SA1->A1_SALDUP
Else
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Soma-se Todos os Limites de Credito do Cliente          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SA1")
	dbSetOrder(1)
	dbSeek(xFilial("SA1")+SC5->C5_CLIENTE)
	While ( !Eof() .And. xFilial("SA1") == SA1->A1_FILIAL .And.;
		SC5->C5_CLIENTE ==  SA1->A1_COD )
		nLimCred += xMoeda(SA1->A1_LC,nMCusto,1,dDatabase)
		nSalPed  += xMoeda(SA1->A1_SALPED,nMCusto,1,dDataBase)+xMoeda(SA1->A1_SALPEDB,nMCusto,1,dDataBase)
		nSalPedL += xMoeda(SA1->A1_SALPEDL,nMCusto,1,dDataBase)
		nSalDup  += SA1->A1_SALDUP
		dbSelectArea("SA1")
		dbSkip()
	EndDo
EndIf
nSalvEmp := SM0->(Recno())
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Analisar o atraso de Todas as Filiais do Sistema                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SM0")
dbSeek(cEmpAnt)
While !Eof() .and. M0_CODIGO == cEmpAnt
	If ( GetMv("MV_CREDCLI")=="L" )
		nValAtraso += USomaAtraso(SM0->M0_CODFIL)
	Else
		dbSelectArea("SA1")
		dbSetOrder(1)
		dbSeek(xFilial("SA1")+SC5->C5_CLIENTE)
		While ( !Eof() .And. xFilial("SA1")  == SA1->A1_FILIAL .And.;
			SC5->C5_CLIENTE == SA1->A1_COD )
			nValAtraso += USomaAtraso(SM0->M0_CODFIL)
			dbSelectArea("SA1")
			dbSkip()
		EndDo
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Forca a saida quando o SE1 estiver compartilhado               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ( xFilial("SE1") == Space(2) )
		Exit
	EndIf
	dbSelectArea("SM0")
	dbSkip()
EndDo
dbSelectArea("SM0")
dbGoto(nSalvEmp)
nSaldoLC := ( nLimCred - nSalDup - nSalPedL )
dbSelectArea("SA1")           // Posiciona cliente
dbSetOrder(1)
dbSeek(cFilial+SC5->C5_CLIENTE+SC5->C5_LOJACLI)
dbSelectArea("SC9")
While ( !Eof() .And. Eval(bWhile) .And. lContinua)
	
	If (SC9->C9_BLCRED!="10" .And.	SC9->C9_BLEST!="10" .And.;
		(If(lAvCred,!Empty(SC9->C9_BLCRED2),.F.) .Or.If(lAvEst,!Empty(SC9->C9_BLEST),.F.)	))
		
		lLiberado := .T.
		If !SoftLock("SC9")
			lContinua := .F.
		EndIf
		If ( lContinua )
			dbSelectArea("SC9")
			
			If ( SC5->C5_TIPO $ "DB" )
				Help(" ",1,"A450NCRED")
				lContinua := .F.
			EndIf
		EndIf
		If ( lContinua )
			dbSelectArea("SC6")           // Posiciona item do pedido
			dbSetOrder(1)
			dbSeek(cFilial+SC9->C9_PEDIDO+SC9->C9_ITEM+SC9->C9_PRODUTO)
			
			dbSelectArea("SM2")           // Posiciona moeda da data base
			dbSetOrder(1)
			dbSeek(dDataBase,.T.)
			
			dbSelectArea("SC9")
			nMoeda   := Iif(SC5->C5_MOEDA < 2,1,SC5->C5_MOEDA)
			nValItem := xMoeda((SC6->C6_PRCVEN * SC9->C9_QTDLIB),nMoeda,1,dDataBase)
			nValPed  += nValItem
			nSalPed  -= nValItem
			nSalPed  := IIf( nSalped < 0 , 0 , nSalPed )
			
		EndIf
	EndIf
	dbSelectArea("SC9")
	// Verificando o Bloqueio do Pedido
	If SC9->C9_PARCIAL == "N"
		lPedBloq := .T.  //
	EndIf
	dbSkip()
EndDo
dbSelectArea("SC9")
dbGoto(aAreaSC9[3])
If ( !lLiberado )
	Help(" ",1,"A450JALIB")
Endif
If ( lContinua .And. lLiberado )
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Reposiciona o SA1                                                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SA1")
	dbSetOrder(1)
	dbSeek(cFilial+SC5->C5_CLIENTE+SC5->C5_LOJACLI)
	If ( SC9->C9_BLCRED == "01" )
		cDescBloq := OemToAnsi("Crédito")  //"Crédito"
	ElseIf SC9->C9_BLCRED == "04"
		cDescBloq := OemToAnsi("Limite de Crédito Vencido")  //"Limite de Crédito Vencido"
	ElseIf SC9->C9_BLCRED == "09"
		cDescBloq := OemToAnsi("Rejeitado")  //"Rejeitado"
	ElseIf !Empty(SC9->C9_BLEST)
		cDescBloq := OemToAnsi("Estoque")  //"Estoque"
	EndIf
	cDescri := Substr(SA1->A1_NOME,1,35)
	//Converte os valores para a moeda escolhida pelo parametro MV_APRESLC
	aSaldos		:=	Array(10)
	aSaldos[1]	:=	xMoeda(nLimCred,1,nMoedaAp)
	aSaldos[2]	:=	xMoeda(SA1->A1_SALDUP,1,nMoedaAp)
	aSaldos[3]	:=	xMoeda(nSalPedl,1,nMoedaAp)
	aSaldos[4]	:=	xMoeda(SA1->A1_MCOMPRA,nMCusto,nMoedaAp)
	aSaldos[5]	:=	xMoeda(nSaldoLc,1,nMoedaAp)
	aSaldos[6]	:= xMoeda(SA1->A1_MAIDUPL,nMCusto,nMoedaAp)
	aSaldos[7]	:=	xMoeda((SC9->C9_PRCVEN * SC9->C9_QTDLIB),1,nMoedaAp)
	aSaldos[8]	:=	xMoeda(nValPed,1,nMoedaAp)
	aSaldos[9]	:=	xMoeda(nSalPed,1,nMoedaAp)
	aSaldos[10]	:=	xMoeda(nValAtraso,1,nMoedaAp)
	DEFINE MSDIALOG oDlg FROM  125,3 TO 420,608 TITLE OemToAnsi("Liberação de Crédito") PIXEL    //"Libera‡„o de Cr‚dito"
	
	@ 038, 004  TO 115, 135 //LABEL "" //OF oDlg  PIXEL
	@ 038, 139  TO 115, 295 //LABEL "" //OF oDlg  PIXEL
	@ 003, 004  TO 033, 295 //LABEL "" //OF oDlg  PIXEL
	@ 120, 004  TO 140, 155 //LABEL "" //OF oDlg  PIXEL
	@ 120, 160  TO 140, 240 //LABEL "" //OF oDlg  PIXEL
	
	DEFINE SBUTTON FROM 124, 242 TYPE 1 ACTION (nOpca := 1,oDlg:End()) ENABLE OF oDlg
	DEFINE SBUTTON FROM 124, 272 TYPE 2 ACTION oDlg:End() ENABLE OF oDlg
	
	@ 125, 010 BUTTON OemToAnsi("Consulta")   SIZE 34,11  ACTION (Ua450F4con(),cCadastro:= OemToAnsi("Liberacao de Credito")) // JBS 14/02/2006     //OF oDlg PIXEL     				//"Consulta"
	@ 125, 045 BUTTON OemToAnsi("Cliente")   SIZE 34,11  ACTION (cCadastro:=OemToAnsi("Cliente"),AxVisual("SA1",SA1->(RecNo()),1),cCadastro:= OemToAnsi("Liberacao de Credito")) // JBS 14/02/2006    //OF oDlg PIXEL   	//"Cliente"
	@ 125, 080 BUTTON OemToAnsi("Pedido")   SIZE 34,11  ACTION (cCadastro:=OemToAnsi("Pedido"),a410Visual("SC5",SC5->(RecNo()),1),cCadastro:= OemToAnsi("Liberacao de Credito")) // JBS 14/02/2006    //OF oDlg PIXEL 	//"Pedido"
	@ 125, 115 BUTTON OemToAnsi("Estoque")   SIZE 34, 11 ACTION ( Ua450ConEst()) // JBS 14/02/2006    // OF oDlg PIXEL     					//"Estoque"
	
	@ 125, 165 BUTTON OemToAnsi("Lib.Todos")   SIZE 34,11  ACTION (nOpca := 4,oDlg:End() )  //OF oDlg PIXEL     				//"Lib.Todos"
	@ 125, 200 BUTTON OemToAnsi("Rejeita")   SIZE 34,11  ACTION (nOpca := 3,oDlg:End() )  //OF oDlg PIXEL     				//"Rejeita"
	
	@ 010, 011 SAY OemToAnsi("Pedido :")      SIZE 23, 7 // OF oDlg PIXEL   //"Pedido :"
	@ 010, 040 SAY SC9->C9_PEDIDO          SIZE 26, 7 // OF oDlg PIXEL
	@ 010, 090 SAY OemToAnsi("Cond.Pagto. :")      SIZE 35, 7 // OF oDlg PIXEL   //"Cond.Pagto. :"
	@ 010, 128 SAY SC5->C5_CONDPAG         SIZE 09, 7 // OF oDlg PIXEL
	@ 010, 170 SAY OemToAnsi("Bloqueio :")      SIZE 27, 7 // OF oDlg PIXEL   //"Bloqueio :"
	@ 010, 201 SAY cDescBloq               SIZE 83, 7 // OF oDlg PIXEL
	
	@ 021, 011 SAY OemToAnsi("Cliente :")      SIZE 23, 7 // OF oDlg PIXEL   //"Cliente :"
	@ 021, 040 SAY cDescri                 SIZE 96, 7 // OF oDlg PIXEL
	@ 021, 170 SAY OemToAnsi("Risco :")      SIZE 21, 7 // OF oDlg PIXEL   //"Risco :"
	@ 021, 201 SAY SA1->A1_RISCO           SIZE 11, 7 // OF oDlg PIXEL
	@ 021, 240 SAY OemToAnsi("Valores em "+&("MV_SIMB"+Alltrim(STR(nMoedaAp))))  SIZE 40, 7 // OF oDlg PIXEL //"Valores em "
	
	@ 044, 012 SAY OemToAnsi("Limite de Cr‚dito :")      SIZE 53, 7 // OF oDlg PIXEL   //"Limite de Cr‚dito :"
	@ 044, 071 SAY aSaldos[1]     			SIZE 59, 7 // OF oDlg PIXEL   PICTURE PesqPict("SA1","A1_LC",18,nMoedaAp)
	@ 044, 145 SAY OemToAnsi("Titulos Protestados :")      SIZE 61, 7 // OF oDlg PIXEL   //"Titulos Protestados :"
	@ 044, 212 SAY SA1->A1_TITPROT         SIZE 18, 7 // OF oDlg PIXEL	PICTURE PesqPict("SA1","A1_TITPROT",18)
	@ 044, 240 SAY OemToAnsi("Em")      SIZE 11, 7 // OF oDlg PIXEL   //"Em"
	//	@ 044, 256 SAY SA1->A1_DTULTIT       //  SIZE 33, 7 // OF oDlg PIXEL
	
	@ 053, 012 SAY OemToAnsi("Saldo Duplicatas :")      SIZE 53, 7 // OF oDlg PIXEL   //"Saldo Duplicatas :"
	@ 053, 071 SAY aSaldos[2]					SIZE 59, 7 // OF oDlg PIXEL   PICTURE PesqPict("SA1","A1_SALDUP",18,nMoedaAp)
	@ 053, 145 SAY OemToAnsi("Cheques Devolvidos :")      SIZE 62, 7 // OF oDlg PIXEL   //"Cheques Devolvidos :"
	@ 053, 212 SAY SA1->A1_CHQDEVO         SIZE 18, 7 // OF oDlg PIXEL   PICTURE PesqPict("SA1","A1_CHQDEVO",18)
	@ 053, 240 SAY OemToAnsi("Em")      SIZE 10, 7 // OF oDlg PIXEL   //"Em"
	//	@ 053, 256 SAY SA1->A1_DTULCHQ    //     SIZE 33, 7 // OF oDlg PIXEL
	
	@ 062, 012 SAY OemToAnsi("Pedidos Liberados :")      SIZE 53, 7 // OF oDlg PIXEL   //"Pedidos Liberados :"
	@ 062, 071 SAY aSaldos[3]       			SIZE 59, 7 // OF oDlg PIXEL   PICTURE Tm(aSaldos[4],18,nDecs)
	@ 062, 145 SAY OemToAnsi("Maior Compra :")      SIZE 53, 7 // OF oDlg PIXEL   //"Maior Compra :"
	@ 062, 212 SAY aSaldos[4]					SIZE 59, 7 // OF oDlg PIXEL   PICTURE PesqPict("SA1","A1_MCOMPRA",18,nMoedaAp)
	
	@ 071, 012 SAY OemToAnsi("Saldo Lim.Cr‚dito :")      SIZE 53, 7 // OF oDlg PIXEL   //"Saldo Lim.Cr‚dito :"
	@ 071, 071 SAY aSaldos[5] 					SIZE 59, 7 // OF oDlg PIXEL   PICTURE PesqPict("SA1","A1_LC",18,nMoedaAp)
	@ 071, 145 SAY OemToAnsi("Maior Duplicata :")      SIZE 53, 7 // OF oDlg PIXEL   //"Maior Duplicata :"
	@ 071, 212 SAY aSaldos[6] 					SIZE 59, 7 // OF oDlg PIXEL   PICTURE PesqPict("SA1","A1_MAIDUPL",18,nMoedaAp)
	
	
	@ 079, 012 SAY OemToAnsi("Item Pedido Atual :")      SIZE 53, 7 // OF oDlg PIXEL   //"Item Pedido Atual :"
	@ 079, 071 SAY aSaldos[7]					SIZE 59, 7 // OF oDlg PIXEL PICTURE Tm(aSaldos[7],18,nDecs)
	@ 079, 212 SAY SA1->A1_METR            SIZE 18, 7 // OF oDlg PIXEL	PICTURE PesqPict("SA1","A1_METR",6)
	@ 079, 242 SAY OemToAnsi("dias")      SIZE 25, 7 // OF oDlg PIXEL   //"dias"
	@ 079, 145 SAY OemToAnsi("Média Atrasos :")      SIZE 53, 7 // OF oDlg PIXEL   //"M‚dia Atrasos :"
	
	@ 087, 012 SAY OemToAnsi("Pedido Atual :")      SIZE 53, 7 // OF oDlg PIXEL   //"Pedido Atual :"
	@ 087, 071 SAY aSaldos[8]					SIZE 59, 7 // OF oDlg PIXEL PICTURE Tm(aSaldos[8],18,nDecs)
	@ 087, 145 SAY OemToAnsi("Vencto.Lim.Crédito :")      SIZE 60, 7 // OF oDlg PIXEL   //"Vencto.Lim.Cr‚dito :"
	//	@ 087, 212 SAY SA1->A1_VENCLC      //SIZE 33, 7 // OF oDlg PIXEL
	
	@ 096, 012 SAY OemToAnsi("Saldo de Pedidos :")      SIZE 53, 7 // OF oDlg PIXEL   //"Saldo de Pedidos :"
	@ 096, 071 SAY aSaldos[9]   				SIZE 59, 7 // OF oDlg PIXEL PICTURE PesqPict("SA1","A1_SALPED",18,nMoedaAp)
	@ 096, 145 SAY OemToAnsi("Data Limite Liberação :")      SIZE 64, 7 // OF oDlg PIXEL   //"Data Limite Libera‡Æo :"
	@ 096, 212 GET dLimLib                 SIZE 52, 7 // OF oDlg PIXEL	HASBUTTON
	
	@ 105, 012 SAY OemToAnsi("Atraso Atual :")      SIZE 53, 7 // OF oDlg PIXEL   //"Atraso Atual :"
	@ 105, 071 SAY aSaldos[10]					SIZE 59, 7 // OF oDlg PIXEL   PICTURE Tm(aSaldos[10],18,nDecs)
	ACTIVATE MSDIALOG oDlg CENTERED
EndIf

RestArea(aAreaSC9)
RestArea(aArea)

Return(nOpcA)
*--------------------------------------------------------------------------*
Static Function Ua450Rejeita(cPedido,cUsuario)
// JBS 03/08/2005 - Rejeitar o Crédito de Pedidos
*--------------------------------------------------------------------------*
Local lRetorno := .T.
Local cFilSC9  := xFilial("SC9")
Local cMail
Local cServidor   := GetMV("MV_CIC")     // Servidor para enviar mensagem pelo CIC
Local cOpFatRem   := GetMV("MV_REMETCI") // Usuario do CIC remetente de mensgens no Protheus
Local cOpFatSenha := "123456"
Local cOpFatDest  := ""
Local cGetMotivo  := Space(90)
Local nOpcao      := 0

SC9->(DbSeek(cFilSC9+cPedido))

// Dados do Destinatario da Mensagem CIC
SU7->(dbSetOrder(1))
SU7->(dbSeek(xFilial("SU7")+SC9->C9_OPERADO))
cOpFatDest := SU7->U7_CICNOME

SA1->(dbSetOrder(1))
SA1->(dbSeek(xFilial("SA1") + SC9->C9_CLIENTE + SC9->C9_LOJA))
cObsFin := ""
M->C9_PEDIDO  := SC9->C9_PEDIDO
M->A1_CLIENTE := AllTrim(SC9->C9_CLIENTE)+"-"+SA1->A1_NREDUZ
M->U7_OPERADO := AllTrim(SC9->C9_OPERADO)+"-"+SU7->U7_NREDUZ
cGetMotivo    := Space(90)

Do While .t.
	nOpcao := 0
	
	Define msDialog oDlg Title "Rejeitando Pedido " From 10,10 TO 23,60
	
	@ 001,002 tO 78,196
	
	@ 010,010 say "Pedido  " COLOR CLR_BLACK
	@ 020,010 say "Cliente " COLOR CLR_BLACK
	@ 030,010 say "Operador" COLOR CLR_BLACK
	
	@ 010,050 get M->C9_PEDIDO  when .f. size 050,08
	@ 020,050 get M->A1_CLIENTE when .f. size 120,08
	@ 030,050 get M->U7_OPERADO when .f. size 120,08
	
	@ 050,010 say "Descreva o motivo da Rejeição" COLOR CLR_HBLUE
	@ 060,010 get cGetMotivo valid !empty(cGetMotivo) size 165,08
	
	DEFINE SBUTTON FROM 82,130 TYPE 1 ACTION IF(!empty(cGetMotivo),(nOpcao:=1,oDlg:End()),msgInfo("Motivo da rejeição do pedido não preenchido","Atenção")) ENABLE OF oDlg
	DEFINE SBUTTON FROM 82,160 TYPE 2 ACTION (nOpcao:=0,oDlg:End()) ENABLE OF oDlg
	
	Activate dialog oDlg centered
	
	If nOpcao == 1

		mObsFin := Trim(MSMM(SA1->A1_OBSFINM,60,,,3))
		
		If !empty(mObsFin)
			mObsFin := CR + mObsFin
		EndIf
		
		mObsFin := " Em "+dToc(dDatabase)+" o pedido nro "+Alltrim(M->C9_PEDIDO)+" foi rejeitado. Motivo: "+AllTrim(cGetMotivo)+". " + mObsFin
		
		//Registra a o Motivo do Bloqueio na observação do Cliente.
		SA1->(RecLock("SA1",.F.))
		If empty(SA1->A1_OBSFINM)
			MSMM(,60,,mObsFin ,1,,,"SA1","A1_OBSFINM")
		Else
			MSMM(SA1->A1_OBSFINM,60,,mObsFin,4,,,"SA1","A1_OBSFINM")
		EndIf
		SA1->(MsUnLock("SA1"))
		// Bloqueia o Pedido no SC9
		Do While SC9->(!EOF()).and. SC9->C9_PEDIDO = cPedido .AND. SC9->C9_FILIAL == cFilSC9
			
			SC9->(RecLock("SC9",.F.))
			SC9->C9_PARCIAL := "N"
			SC9->(MsUnLock("SC9"))
			
			SC9->(dbSkip())
		EndDo

		SC5->(Reclock("SC5",.F.))
		SC5->C5_PRENOTA := " "
		SC5->(MsUnLock("SC5"))
	
		// Registrando a ocorrencia na Ficha Kardex
		U_DiprKardex(cPedido,U_DipUsr(),cGetMotivo,.T.,"25")// JBS 29/08/2005

		// Monta a mensagem a ser enviado ao operador
		cMail := "AVISO IMPORTANTE"+CR+CR
		cMail += "O Pedido "   +Alltrim(SZ9->Z9_PEDIDO)
		cMail += " do Cliente "+AllTrim(SA1->A1_COD)+" - "+AllTrim(SA1->A1_NREDUZ)+CR
		cMail += "Foi rejeitado pelo Crédito."+CR+CR
		cMail += "Motivo: "+cGetMotivo +CR+CR
		cMail += U_DipUsr()
		
		// Envia a mensagem ao operador através do CIC
		
		U_DIPCIC(cMail,AllTrim(cOpFatDest))//RBorges 12/03/15
//		WaitRun(cServidor+' '+cOpFatRem+' '+cOpFatSenha+' "'+AllTrim(cOpFatDest)+'" "'+cMail+'" ') //Comentada RBorges 12/03/15
	EndIf
	Exit
EndDo
Return(lRetorno)
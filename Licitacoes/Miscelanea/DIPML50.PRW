#INCLUDE "protheus.ch" 
#INCLUDE "RWMAKE.CH" 
#INCLUDE "COLORS.CH"
#INCLUDE "MSOLE.CH"  

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DIPML50   ºAutor  ³Alexandro Meier     º Data ³  25/03/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Tela para selecionar produtos vencedores, gerar pedido      º±±
±±º          ³e gerar contrato                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function DIPML50(cAlias,nReg,nOpcx)

Local aArea 	:= GetArea()
Local oDlg
Local cCadastro := "Finaliza Edital"
Local aCpoEnch	:= {}
Local aNoEnch	:= {"UA1_FILIAL","UA1_STATUS"}
Local aPos	  	:= {010,000,115,460}
Local aButtons 	:= {}
Local nOpcA		:= 0
Local oOk		:= LoadBitmap( GetResources(), "LBOK" )
Local oNo		:= LoadBitmap( GetResources(), "LBNO" )
Local oChk
Local lMark		:= .F.
Local lRetorno   := .F.

Private lChk	 := .F.
Private aVetor	 := {}
Private oLbx
Private lInverte := .F. 
Private nContLin := 0  
Private lLote    := .F.





U_DIPPROC(ProcName(0),U_DipUsr()) // MCVN 22/01/2009
IF UA4->( !dbSeek(xFilial("UA4") + UA1->UA1_CODIGO))
	Alert("Edital sem nenhum produto cadastrado!")
	Return (.F.)
EndIF

/*If Upper(U_DipUsr()) $ 'ERIBERTO/MAXIMO/CLEIA'
	If UA1->UA1_ACERTO <> 'S'
		If MsgYesNo("Acerto de EDITAL ?","Aten‡„o")
			RecLock("UA1",.F.)
			UA1->UA1_ACERTO := 'S'
			UA1->( MsUnLock()  ) 
		Endif	
	Else     
		If !(MsgYesNo("Este edital está marcado como acerto!! Confirma?","Aten‡„o"))
			RecLock("UA1",.F.)
		   	UA1->UA1_ACERTO := ''
			UA1->( MsUnLock()  ) 		
		Endif
	Endif
Endif      */

//If UA1->UA1_ACERTO <> 'S'
	IF Empty(UA1->UA1_FINANC)
		Alert("Edital ainda não avaliado pelo Departamento Financeiro!")
		Return (.F.)
	EndIF

	IF Empty(UA1->UA1_VENDAS)
		Alert("Edital ainda não avaliado pela Gerencia Comercial!")
		Return (.F.)
	EndIF
//Endif
// Aadd( aButtons, {"PRECO",  {|| U_050PED() }, "Gera Pedido de vendas...", "Pedido" , {|| .T.}} )
Aadd( aButtons, {"RPMDES", {|| U_050CON() }, "Gera Contrato...", "Contrato" , {|| .T.}} )

RegToMemory(cAlias,.F.)
RegToMemory("UA4",.F.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Montagem dos campos da Enchoice 		   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
AADD(aCpoEnch,"NOUSER")
SX3->(dbSetOrder(1))
SX3->(dbSeek("UA1"))
Do While ( !SX3->( Eof() ) .And. SX3->X3_ARQUIVO == "UA1" )
	If ( X3USO(SX3->X3_USADO) .And. cNivel >= SX3->X3_NIVEL .And.;
		ASCAN(aNoEnch,SX3->X3_CAMPO) < 1)
		AADD(aCpoEnch,SX3->X3_CAMPO)
	EndIf
	SX3->(dbSkip())
EndDo

dbSelectArea("UA4")
dbSetOrder(1)
UA4->(dbSeek(xFilial("UA4") + M->UA1_CODIGO))

Do While !Eof() .And. UA4->UA4_FILIAL == xFilial("UA4")
	If UA4->UA4_EDITAL == M->UA1_CODIGO 
	If substr(UA4->UA4_XPEDID,1,3) = "   " //Giovani Zago 29/08/11
		
		If UA4->UA4_VENCEU = "1"
			lMark := .T.
		Else
			lMark := .F.
		EndIf
		If ALLTRIM(UA4->UA4_LOTE) = ""
		lLote := .T.
		EndIf
		aAdd(aVetor,{lMark, UA4->UA4_ITEM,Iif(Empty(UA4->UA4_LOTE),ALLTRIM(UA4->UA4_ITEMAM),ALLTRIM(UA4->UA4_LOTE)+' - '+ALLTRIM(UA4->UA4_ITEMLT)), UA4->UA4_PRODUTO, MSMM(UA4->UA4_PROMEM), UA4->UA4_QUANT, UA4->UA4_PRCVEN, UA4->UA4_PRCMIN })
     nContLin := 1    //Giovani Zago 29/08/11
	EndIf
	EndIf
	dbSkip()
EndDo
 If 	nContLin = 0//Giovani Zago 29/08/11
	MsgInfo("Todos os Itens ja Foram Faturados e Marcados Como Vencidos !!!")//Giovani Zago 29/08/11
 Return(.t.)//Giovani Zago 29/08/11
EndIf

Define msDialog odlg title ccadastro from 178,181 to 590,1100 pixel

//Cria Enchoice
EnChoice( cAlias ,nReg, nOpcx, , , , aCpoEnch, aPos, {}, 3 )

//Cria a listbox com os produtos do edital
@ 115,000 listbox oLbx fields header " ", "Item",Iif(lLote,"Item Edital","Lote - Item"), "Codigo", "Descricao", "Quantidade", "Vlr. Unitario", "Vlr. Minimo"  size 460,090 of oDlg pixel on dbLclick(u_edlista(oLbx:nat))

oLbx:SetArray( aVetor )
oLbx:bLine := {|| {Iif(	aVetor[oLbx:nAt,1],oOk,oNo),;
aVetor[oLbx:nAt,2],;
aVetor[oLbx:nAt,3],;
aVetor[oLbx:nAt,4],;
aVetor[oLbx:nAt,5],;
aVetor[oLbx:nAt,6],;
aVetor[oLbx:nAt,7],;
aVetor[oLbx:nAt,8]}}

//@ 200,005 CHECKBOX oChk VAR lChk PROMPT "Marca/Desmarca" SIZE 60,007 PIXEL OF oDlg ;
//    ON CLICK(aEval(aVetor,{|x| x[1]:=lChk}),oLbx:Refresh())

Activate msDialog oDlg centered on init ;
EnchoiceBar(oDlg, {|| nOpca := 1,oDlg:End()},{|| nOpca := 0,oDlg:End()},,aButtons)

If nOpcA == 1
   lVenceu := .f.
   aeval(aVetor,{|x| If(x[1],lVenceu := .t.,) })

   Begin Transaction

   If lVenceu 
	   UA1->( RecLock("UA1", .F.) )
	   UA1->UA1_STATUS := If(lVenceu, "7","8")
	   UA1->( MsUnLock("UA1") )
   Else
      If TmkOk("Confirma o Encerramento do Edital ?")
	      UA1->( RecLock("UA1", .F.) )
	      UA1->UA1_STATUS := "6" // MCVN - 20/06/2007
	      UA1->( MsUnLock("UA1") )
      EndIf
   EndIf
   
   End Transaction
  
   If __lSX8
       ConfirmSX8()
   EndIf           
   
   
// Cria registro no UA5 - Cadastros de preços e concorrentes
	If UA1->UA1_TIPO <> '1'  // Gera grade exceto para pregão presencial
  		GravaPrecoxConcor()           
	Endif
EndIf

RestArea(aArea)

Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DIPML50   ºAutor  ³Alexandro Meier     º Data ³  28/03/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Abre a tela para editar os campos do ListBox                º±±
±±º          ³apos o duplo clik                                           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function EdLista(nPos)

Local cKey := ""
Local oDlg
Local nOpca		:= 0
Local cCodPro	:= ""
Local cDProdu	:= ""
Local nQtd		:= 0
Local nPrcVen	:= 0
Local nPrcMin	:= 0
Local aButtons	:= {}
Local cCadastro := "Produtos do Edital"    
Local nMultipl  := UA1->UA1_QTDPAR
Local nQtdTot   := 0

cKey := aVetor[nPos,2] //ITEM
U_DIPPROC(ProcName(0),U_DipUsr()) // MCVN 22/01/2009
dbSelectArea("UA4")
dbSetOrder(1)
UA4->(dbSeek(xFilial("UA4") + M->UA1_CODIGO + cKey))

cCodPro := UA4->UA4_PRODUTO
cDProdu	:= MSMM(UA4->UA4_PROMEM)
nQtd	:= UA4->UA4_QUANT
nPrcVen	:= UA4->UA4_PRCVEN
nPrcMin	:= UA4->UA4_PRCMIN   
nQtdTot := 0 

Define msDialog oDlg title cCadastro from 0,0 to 250,550 pixel

@ 030, 010 say "Codigo"                size 070,08 pixel of odlg
@ 042, 010 say "Descricao"             size 070,08 pixel of odlg
@ 054, 010 say "Quantidade contratada" size 070,08 pixel of odlg
@ 066, 010 say "Preço contratado"      size 070,08 pixel of odlg 
If UA1->UA1_CONTRA = "1"  //  MCVN - 05/02/2009
	@ 090, 010 say "EDITAL COM CONTRATO - INFORMAÇÕES DA QUANTIDADE CONTRATADA.
	@ 105, 010 say "Parcelas  "         size 070,08 pixel of odlg    
	@ 105, 130 say "Total contratado  " size 070,08 pixel of odlg 
Endif

@ 029, 080 msget ccodpro when .f.      size 030,10 pixel of odlg
@ 041, 080 msget cdprodu when .f.      size 150,10 pixel of odlg picture "@!"
@ 053, 080 msget nqtd                  size 050,10 pixel of odlg picture "@e 99999999.99"
@ 065, 080 msget nprcven               size 050,10 pixel of odlg picture "@e 999,999,999.9999"
If UA1->UA1_CONTRA = "1"  //  MCVN - 05/02/2009
	@ 0105, 080 msget nMultipl         size 030,10 pixel of odlg picture "@e 999"  valid (nQtdTot := nMultipl*nqtd) When .F.
	@ 0105, 170 msget nQtdTot          size 060,10 pixel of odlg picture "@e 99999999.99" when .f.
Endif

nQtdTot := nMultipl*nqtd
Activate msDialog odlg Center on Init;
Enchoicebar(oDlg, {|| nopca := 1,oDlg:end()},{|| nopca := 0,oDlg:end()},,abuttons)

If nOpca = 1		
	
	Begin Transaction
	
	dbSelectArea("UA4")
	dbSetOrder(1)
	UA4->(dbSeek(xFilial("UA4") + M->UA1_CODIGO + cKey))
	
	RecLock("UA4", .F.)   
	
	UA4->UA4_QUANT		:= nQtd
	UA4->UA4_PRCVEN		:= nPrcVen
	UA4->UA4_PRCMIN		:= nPrcMin
//  UA4->UA4_QTDENT     := 0
	UA4->UA4_SALDO      := nQtd*If(nMultipl = 0,1,nMultipl)  // MCVN 05/01/2009  
	
	If !aVetor[oLbx:nAt,1]
		UA4->UA4_VENCEU		:= '1'
		
	Else
		UA4->UA4_VENCEU		:= '2'
	EndIf
	MsUnLock()
	
	End Transaction

    If __lSX8
	    ConfirmSX8()
    EndIf

	
	aVetor[oLbx:nAt,1]	:= !aVetor[oLbx:nAt,1]
	aVetor[nPos][2]		:= UA4->UA4_ITEM
	aVetor[nPos][3]		:= Iif(Empty(UA4->UA4_LOTE),UA4->UA4_ITEMAM,UA4->UA4_LOTE+' - '+UA4->UA4_ITEMLT)
	aVetor[nPos][4]		:= UA4->UA4_PRODUTO
	aVetor[nPos][5]		:= MSMM(UA4->UA4_PROMEM)
	aVetor[nPos][6]		:= UA4->UA4_QUANT
	aVetor[nPos][7]		:= UA4->UA4_PRCVEN
    aVetor[nPos][8]		:= UA4->UA4_PRCMIN
EndIf

oLbx:Refresh()
Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DIPML50   ºAutor  ³Alexandro Meier     º Data ³  28/03/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Gera o pedido de vendas para o edital                       º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
*----------------------------------------*
User Function 050PED(cNroEmpenho)
*----------------------------------------*
Local aCabec	:= {}
Local aItens	:= {}
Local cMensagem := ""
Local nRegua	:= 0
Local i			:= 1
Local cItem		:= "00"
Local cTes		:= "" // JBS 13/06/2006
Local cDestFrete:= ""
Local cQuemcon	:= U_DipUsr()
Local lFinaliza := .t.
Local cAtividade:= ""
Local cEstado   := ""
Local cNomeCli  := ""
Local cCodCli   := ""
LocaL cLojaCli  := ""  
Local cLicTran  := SPACE(006)
Local cMenNota  := SPACE(120)// MCVN - 20/06/2007
Local cMenDep   := SPACE(120)// MCVN - 20/06/2007
Local cOperador := Posicione("SU7",6,xFilial("SU7")+U_DipUsr(),"U7_COD") // MCVN - 10/07/2007
Local cEstCli   := ""
Local nPicmRet  := 0
Local cGrpSa1	:= GetMV("ES_GRPSA1") //FELIPE DURAN 09/10/19 - GRUPO DE CLIENTES PARA AJUSTE DO VENDEDOR
Local lret		:= .T.
Private lMsHelpAuto := .T. 	// se .T. direciona as mensagens de help para o arq. de log
Private lMsErroAuto := .F. 	//necessario a criacao, pois sera atualizado quando houver erro  
Private _cRetorVer := ".T."
Static cPediGera    := ".T."


If !Empty(M->UA8_PEDIDO)
	Alert("Já existe pedido gerado para este edital !")
	Return(.F.)
EndIf


cCodCli  := M->UA8_CODCL
cLojaCli := M->UA8_LOJA


//  Chama Tela para incluir mensagem para Depósito e Mensagem de Depósito
	Define msDialog oDlg Title "MENSAGENS PARA NOTA FISCAL" From 10,10 TO 30,57
	
	@ 001,002 tO 150,185
	
	@ 010,010 say "Edital  " COLOR CLR_BLACK
	@ 020,010 say "Empenho " COLOR CLR_BLACK
	@ 030,010 say "Cliente " COLOR CLR_BLACK
	
	@ 010,050 get M->UA1_CODIGO  when .f. size 050,08
	@ 020,050 get M->UA8_EMPENHO when .f. size 120,08
	@ 030,050 get M->UA8_CODCL   when .f. size 120,08         
	
	@ 050,010 say "Informe a mensagem para Nota: "  COLOR CLR_HBLUE
	@ 060,010 get cMenNota size 165,08
	                                                                                
    @ 080,010 say "Informe a mensagem para Depósito: "  COLOR CLR_HBLUE
	@ 090,010 get cMenDep  size 165,08                                 
	
    @ 110,010 say "Informe a Transportadora: "  COLOR CLR_HBLUE
	@ 120,010 get cLicTran size 40,08 F3 "SA4" Valid ExistCpo("SA4",cLicTran)
	
	DEFINE SBUTTON FROM 135,148 TYPE 1 ACTION (lSaida:=.T.,nOpcao:=1,oDlg:End()) ENABLE OF oDlg
//	DEFINE SBUTTON FROM 82,160 TYPE 2 ACTION (nOpcao:=0,oDlg:End()) ENABLE OF oDlg
	
	Activate dialog oDlg centered




If cCodCli = M->UA1_CODCLI .And. cLojaCli = M->UA1_LOJA //MCVN 21/06/2007  
	SA1->(dbSetOrder(1))
	SA1->(dbSeek(xfilial("SA1")+M->UA1_CODCLI+M->UA1_LOJA))
	cDestFrete:= U_Mt410Frete('GATILHO')  //Posicione("SA1",1,xFilial("SA1") + M->UA1_CODCLI + M->UA1_LOJA,"A1_EST")+"-TODAS"
	cAtividade:= SA1->A1_SATIV1  //Posicione("SA1",1,xFilial("SA1") + M->UA1_CODCLI + M->UA1_LOJA,"A1_SATIV1")      // MCVN 20/06/2007
	cEstado   := SA1->A1_EST     //Posicione("SA1",1,xFilial("SA1") + M->UA1_CODCLI + M->UA1_LOJA,"A1_EST")         // MCVN 20/06/2007  
	cNomeCli  := Upper(SA1->A1_NOME)  //Upper(Posicione("SA1",1,xFilial("SA1")+ M->UA1_CODCLI + M->UA1_LOJA,"A1_NOME"))  // MCVN 20/06/2007  
Else                               
    SA1->(dbSetOrder(1))
	SA1->(dbSeek(xfilial("SA1")+cCodCli+cLojaCli))                                                            
	cDestFrete:= U_Mt410Frete('GATILHO')  //Posicione("SA1",1,xFilial("SA1") + cCodCli + cLojaCli,"A1_EST")+"-TODAS"
	cAtividade:= SA1->A1_SATIV1  //Posicione("SA1",1,xFilial("SA1") + cCodCli + cLojaCli,"A1_SATIV1")    // MCVN 20/06/2007
	cEstado   := SA1->A1_EST     //Posicione("SA1",1,xFilial("SA1") + cCodCli + cLojaCli,"A1_EST")       // MCVN 20/06/2007  
	cNomeCli  := Upper(SA1->A1_NOME)  //Upper(Posicione("SA1",1,xFilial("SA1")+ cCodCli + cLojaCli,"A1_NOME"))           // MCVN 20/06/
Endif


// Tratando clientes com isenção de ICMS - 48034/03 - Art. 55    -     MCVN 20/06/2007

If cEmpAnt == '01'
	
	If (cAtividade == "1.2.02"  .And. cEstado = "SP")
		If MsgYESNO("Cliente "+cNomeCli+" com Isenção de ICMS de acordo com Decreto 48034/03 - Art. 55. CONFIRMA A ISENÇÃO DE ICMS?  TES -> 569")
			cTes := "569"
		Else
			cTes := ""
		Endif
	Endif
	
	// Tratando ICMS p/ Bec
	If UA1->UA1_TIPO == "6"
		cTes := "569"
	Endif
	
Else
	
	If (cAtividade == "1.2.02"  .And. cEstado = "SP")
		If MsgYESNO("Cliente "+cNomeCli+" com Isenção de ICMS de acordo com Decreto 48034/03 - Art. 55. CONFIRMA A ISENÇÃO DE ICMS?  TES -> 598")
			cTes := "698"
		Else
			cTes := ""
		Endif
	Endif
	
	// Tratando ICMS p/ Bec
	If UA1->UA1_TIPO == "6"
		cTes := "698"
	Endif
	
EndIf




dbSelectArea("UA9")
dbSetOrder(2)
UA9->(dbSeek(xFilial("UA9") + M->UA8_EMPENH + M->UA1_CODIGO ))

//CONTA REGISTROS A SEREM PROCESSADOS
//APARTIR DOS PRODUTOS SELECIONADOS COMO VENCEDORES
Do While UA9->(!EOF()) .And. M->UA1_CODIGO = UA9->UA9_EDITAL
	nRegua ++
	UA9->(dbSkip())
EndDo

ProcRegua(nRegua)

// Valida quanto cliente do empenho é diferente do cliente do edital
If cCodCli = M->UA1_CODCLI .And. cLojaCli = M->UA1_LOJA //MCVN 21/06/2007
	SA1->(dbSeek(xfilial("SA1") + M->UA1_CODCLI + M->UA1_LOJA ))
	M->C5_CLIENTE := M->UA1_CODCLI  // JBS 08/06/2006
	M->C5_LOJACLI := M->UA1_LOJA    // JBS 08/06/2006  
Else                                                            
	SA1->(dbSeek(xfilial("SA1") + cCodCli + cLojaCli ))
	M->C5_CLIENTE := cCodCli  // MCVN 21/06/2007
	M->C5_LOJACLI := cLojaCli // MCVN - 21/06/2007                
Endif       

//M->C5_OPERADO := "000095"     // JBS 13/06/2006
M->C5_OPERADO := Iif(Empty(Alltrim(cOperador)),"000095",cOperador) //MCVN - 10/07/2007
M->C5_CONDPAG := M->UA1_CONDPA  // JBS 13/06/2006
M->C5_TRANSP  := If(!Empty(cLicTran),cLicTran,If(!Empty(SA1->A1_TRANSP),SA1->A1_TRANSP,"100000")) // // MCVN - 12/07/2007
//M->C5_TRANSP  := SA1->A1_TRANSP // MCVN - 09/10/2007
M->C5_VEND1   := IIF(Empty(Alltrim(UA1_XVEND1)) .OR. SA1->A1_GRPVEN $ cGrpSa1 ,SA1->A1_VEND,Alltrim(UA1_XVEND1)) // MCVN 06/08/13 - Felipe Duran 04/10/19
M->C5_VEND2   := ""//SA1->A1_VENDKC // MCVN - 06/09/2007
M->C5_TIPOCLI := SA1->A1_TIPO   // JBS 13/06/2006
//M->C5_DESTFRE := SA1->A1_EST + "-TODAS" // JBS 13/06/2006
M->C5_DESTFRE := cDestFrete
M->C5_TPFRETE := "C" // Frete CIF 
M->C5_MENNOTA := Upper(Alltrim(cMenNota))
M->C5_MENDEP  := Upper(Alltrim(cMenDep))
M->C5_TIPLIB  := "1"    
M->C5_TIPODIP := "1"    
M->C5_TMK     := "1"    
cEstCli       := SA1->A1_EST


Begin Transaction

// Cabecalho do pedidos de venda SC5

aCabec := {}
aadd(aCabec,{"C5_TIPO"   , "N",			  Nil})
aadd(aCabec,{"C5_CLIENTE", M->C5_CLIENTE, Nil}) // JBS 13/06/2006
aadd(aCabec,{"C5_LOJACLI", M->C5_LOJACLI, Nil}) // JBS 13/06/2006
aadd(aCabec,{"C5_OPERADO", M->C5_OPERADO, Nil}) // JBS 13/06/2006
aadd(aCabec,{"C5_VEND1"  , M->C5_VEND1  , Nil}) // JBS 13/06/2006   
aadd(aCabec,{"C5_VEND2"  , M->C5_VEND2  , Nil}) // MCVN - 06/09/2007
aadd(aCabec,{"C5_CONDPAG", M->C5_CONDPAG, Nil}) // JBS 13/06/2006
aadd(aCabec,{"C5_TRANSP" , M->C5_TRANSP , Nil}) // MCVN - 12/07/2007
aadd(aCabec,{"C5_QUEMCON", cQuemcon     , Nil})
aadd(aCabec,{"C5_TIPOCLI", M->C5_TIPOCLI, Nil}) // JBS 13/06/2006
aadd(aCabec,{"C5_DESTFRE", M->C5_DESTFRE, Nil}) // JBS 05/06/2006
aadd(aCabec,{"C5_EDITAL" , M->UA1_CODIGO, Nil}) // JBS 08/06/2006
aadd(aCabec,{"C5_EMPENHO", M->UA8_EMPENH, Nil})
aadd(aCabec,{"C5_TPFRETE", M->C5_TPFRETE, Nil})   
aadd(aCabec,{"C5_MENNOTA", M->C5_MENNOTA, Nil})
aadd(aCabec,{"C5_MENDEP" , M->C5_MENDEP , Nil})
aadd(aCabec,{"C5_TIPLIB" , M->C5_TIPLIB , Nil})
aadd(aCabec,{"C5_TIPODIP" , M->C5_TIPODIP , Nil})
aadd(aCabec,{"C5_TMK" , M->C5_TMK , Nil})

// Itens do pedido de vendas SC6

dbSelectArea("UA4")

UA4->(dbSetOrder(1))
UA9->(dbSetOrder(1))

UA4->(dbSeek(xFilial("UA4") + M->UA1_CODIGO))

Do While !UA4->(EOF()) .And. M->UA1_CODIGO = UA4->UA4_EDITAL
	
	If UA4->UA4_VENCEU = "1"
		
		IncProc()
		
		If UA9->(dbSeek(xfilial("UA9")+M->UA1_CODIGO+UA4->UA4_ITEM + MV_PAR01))
			
			If UA9->UA9_QTDEMP > 0 // Possui Quantidade Empenhada
				
			    //cItem := AllTrim(Str(i))  // Desabilitado   MCVN - 07/04/09 
				//cItem := PadL(cItem, 02, '0')
				
				cItem := Soma1(cItem) // Corrigindo item no pedido   MCVN - 07/04/09 
				If cEmpAnt == '01'
					If cTes <> '569' // MCVN 20/06/2007
						cTes := Posicione("SB1",1,xFilial("SB1") + UA4->UA4_PRODUT,"B1_TS")
					Endif
					
					Else 

					If cTes <> '698' // MCVN 20/06/2007
						cTes := Posicione("SB1",1,xFilial("SB1") + UA4->UA4_PRODUT,"B1_TS")
					Endif
				
				EndIf
				
				// Tratamento para Subst. Tribut. de SP  - MCVN - 30/04/2008 
				nPicmRet := Posicione("SB1",1,xFilial("SB1") + UA4->UA4_PRODUT,"B1_PICMRET")

				// Tratamento para obter o PRODUTO PARA PEDIDO DE VENDAS - Usando campos novos gerados no EDITAL - WCS (DELTA) - 09/03/2021
				If Empty(UA9->UA9_PRODPV) .OR. UA9->UA9_PRODPV = '0'
					_cProduto:= UA9->UA9_PRODUT
				Else
					_cCpoProd:='UA9_PROD' + StrZero(Val(UA9->UA9_PRODPV),2)
					_cProduto:=UA9->(&_cCpoProd)
				End	 				
	
				//			   
				If cEmpant == '01'
					Aadd(aItens,{;
					{"C6_ITEM"   ,	cItem,				Nil},; // Numero do Item
				   	{"C6_PRODUTO", 	_cProduto,	Nil},; // Codigo do Produto
					{"C6_QTDVEN" , 	UA9->UA9_QTDEMP,	Nil},; // Quantidade Empenhada
					{"C6_PRCVEN" , 	UA4->UA4_PRCVEN,	Nil},; // Preço Contratado
					{"C6_TES"    , 	If((cTes == "501" .And. cEstCli == "SP" .And. nPicmRet > 0),"625",cTes) ,				Nil},; // TES do Produto
					{"C6_PRUNIT" , 	UA4->UA4_PRCVEN,	Nil},; // Preço contratado				
					{"C6_VALOR"  , 	Round((UA4->UA4_PRCVEN*UA9->UA9_QTDEMP),2),	Nil},; // Valor total da Mercadoria Empenhada
					{"C6_TIPODIP", "1",	Nil}}) // Tipo do pedido
				
				Else
					Aadd(aItens,{;
					{"C6_ITEM"   ,	cItem,				Nil},; // Numero do Item
				   	{"C6_PRODUTO", 	_cProduto,	Nil},; // Codigo do Produto
					{"C6_QTDVEN" , 	UA9->UA9_QTDEMP,	Nil},; // Quantidade Empenhada
					{"C6_PRCVEN" , 	UA4->UA4_PRCVEN,	Nil},; // Preço Contratado
					{"C6_TES"    , 	If((cTes == "503" .And. cEstCli == "SP" .And. nPicmRet > 0),"654",cTes) ,				Nil},; // TES do Produto
					{"C6_PRUNIT" , 	UA4->UA4_PRCVEN,	Nil},; // Preço contratado				
					{"C6_VALOR"  , 	Round((UA4->UA4_PRCVEN*UA9->UA9_QTDEMP),2),	Nil},; // Valor total da Mercadoria Empenhada
					{"C6_TIPODIP", "1",	Nil}}) // Tipo do pedido
				
				EndIf
				
				i++
			EndIf
		EndIf
		If (UA4->UA4_QUANT + UA4->UA4_XSALAD)  >  UA4->UA4_QTDENT//UA4->UA4_SALDO > 0
			lFinaliza := .f.  // o Edital possui itens ainda aguardando empenho
		EndIf
	EndIf
	UA4->(dbSkip())
EndDo

If i > 1 // Se tiver item, entra para gravar
ConOut("Licitação - ANTES do MSExecAuto   -  Gerando PedidoAntes do MSExecAuto [" +UA1->UA1_CODIGO+ "] ")
	MSExecAuto({|x,y,z| MATA410(x,y,z)},aCabec,aItens,3)                                            
ConOut("Licitação - DEPOIS do MSExecAuto   -  Gerando PedidoAntes do MSExecAuto [" +UA1->UA1_CODIGO+ "] ")
	
	//Se ocorrer erro no MSExecAuto, exibe o mesmo
	If lMsErroAuto
		lret := .F.
		If __lSX8
			RollBackSX8()
		EndIf
		
		cMensagem := "Nao foi possivel gerar pedido."
		Aviso("Erro!!!",cMensagem,{"Ok"},2,"Erro")
		mostraerro()
		DisarmTransaction()
		cPediGera :=".F."
		Return .F.
		
	Else
		If __lSX8
			ConfirmSX8()
		EndIf
	EndIf
	
	SC5->(dbSetOrder(3))
	
/*  If SC5->(dbSeek(xFilial("SC5") + M->UA1_CODCLI + M->UA1_LOJA)) - MCVN - 19/01/2007
	  	Do While !SC5->(EOF()) 
			If SC5->C5_EDITAL = M->UA1_CODIGO */

				UA1->( RecLock("UA1", .F.) )
				UA1->UA1_STATUS := If(lFinaliza, "8","7")
				UA1->UA1_PEDIDO := SC5->C5_NUM
				UA1->( MsUnLock("UA1") )
				
				If UA8->(dbSeek(xFilial("UA8")+UA1->UA1_CODIGO + M->UA8_EMPENH))
				    UA8->( RecLock("UA8",.F.) )
				    UA8->UA8_PEDIDO := SC5->C5_NUM
				    UA8->( MsUnLock("UA8") )
				EndIf          
			/*EndIf
			SC5->(dbSkip())
		EndDo
    EndIf     */     
    
  
	lRetorno := .T. 
	DbSelectArea("SC6")
    SC6->(dbSetOrder(1)) 
    SC6->(dbSeek(xFilial("SC6") + SC5->C5_NUM))
   	Do While !SC6->(EOF()) .And. SC5->C5_NUM = SC6->C6_NUM
     	DbSelectArea("UA4")
		UA4->(dbSetOrder(4)) 
        UA4->(dbSeek(xFilial("UA4") + M->UA1_CODIGO+SC6->C6_PRODUTO))
		If UA4->(dbSeek(xFilial("UA4")+M->UA1_CODIGO+SC6->C6_PRODUTO))
		   	UA4->( RecLock("UA4", .F.) )
	        UA4->UA4_XPEDID := ALLTRIM(UA4->UA4_XPEDID)+ALLTRIM(SC5->C5_NUM)+"/"
	       	UA4->( MsUnLock("UA4"))
		EndIf  
	 	SC6->(dbSkip())
	EndDo 
	
	ApMsgInfo( 'Pedido de Venda gerado com sucesso.      PEDIDO Nº '+UA8->UA8_PEDIDO+'', 'ATENÇÃO' ) // MCVN - 20/06/2007
	U_DiprKardex(UA8->UA8_PEDIDO,U_DipUsr(),"EDITAL-EMP "+UA1->UA1_CODIGO+"-"+M->UA8_EMPENH,.T.,"40")  // MCVN - 20/06/2007
	u_UTmkR03() // MCVN - 20/06/2007
Else            
	ApMsgInfo( 'Não encontrado itens para gerar o pedido.', 'ATENÇÃO' )
EndIf
ConfirmSX8()
End Transaction 
cPediGera :=".T."
Return(lret)        


Static Function ResuPedi()  

_cRetorVer := cPediGera 

 Return(_cRetorVer)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DIPML50   ºAutor  ³Alexandro Meier     º Data ³  28/03/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Gera o contrato no word                                     º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function 050CON()

Local oWord
Local cFile		:= ""
Local nA		:= 0
Local cArqDot	:= ""
Local cCaract	:= ""
Local nCol		:= 1
Local cValid	:= ""
Local cNewFile	:= ""
Local nPos		:= 0

Private cPathEst	:= "" //Diretorio na estacao

If M->UA1_CONTRA = "2" .Or. Empty(M->UA1_NRCONT)
	Alert("Edital nao possui contrato!")
	Return (.F.)
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ABRE JANELA PARA SELEÇAO DO ARQUIVO DE MODELO ".DOT"³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Empty(cFile) .And. At(".DOT",Upper(cFile))>0
	If !MsgYESNO("Deseja utilizar o mesmo arquivo ("+cFile+") usado anteriormente?")
		cTipo :=         "Modelo Word (*.DOT)        | *.DOT | "
		cFile := cGetFile(cTipo,"Selecione o modelo do arquivo",,,.T.,GETF_ONLYSERVER ,.T.)
		If !Empty(cFile)
			Aviso("Arquivo Selecionado",cFile,{"Ok"})
		Else
			Aviso("Cancelada a Selecao!","Voce cancelou a selecao do arquivo.",{"Ok"})
			Return
		Endif
	EndIf
Else
	cTipo :=         "Modelo Word (*.DOT)        | *.DOT | "
	cFile := cGetFile(cTipo ,"Selecione o modelo do arquivo",,,.T.,GETF_ONLYSERVER ,.T.)
	If !Empty(cFile)
		Aviso("Arquivo Selecionado",cFile,{"Ok"})
	Else
		Aviso("Cancelada a Selecao!","Voce cancelou a selecao do arquivo.",{"Ok"})
		Return
	Endif
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Criando link de comunicacao com o word                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

oWord := OLE_CreateLink('TMsOleWord')

For nA := 1  To Len(cFile)
	cCaract := SubStr(cFile,nCol,1)
	If  cCaract == "\"
		cArqDot := ""
	Else
		cArqDot += cCaract
	EndIf
	nCol := nCol + 1
Next

cPathEst := "C:\WINDOWS\Temp\" // PATH DO ARQUIVO A SER ARMAZENADO NA ESTACAO DE TRABALHO
MontaDir(cPathEst)

CpyS2T(cFile,cPathEst,.T.) // Copia do Server para o Remote, eh necessario
//para que o wordview e o proprio word possam preparar o arquivo para impressao e
// ou visualizacao .... copia o DOT que esta no ROOTPATH Protheus para o PATH da
// estacao , por exemplo C:\WORDTMP

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Abre o arquivo e ajusta suas propriedades                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

OLE_NewFile(oWord, cPathEst+cArqDot)
OLE_SetProperty( oWord, oleWdVisible,   .F. )
OLE_SetProperty( oWord, oleWdPrintBack, .T. )

OLE_SetDocumentVar(oWord,"EDITAL"	,AllTrim(M->UA1_CODIGO))
OLE_SetDocumentVar(oWord,"CONTRATO"	,AllTrim(M->UA1_NRCONT))
cValid := DTOS(M->UA1_VCONTR)
cValid := substr(cValid,7,2) + "/" + substr(cValid,5,2) + "/" + substr(cValid,3,2)
OLE_SetDocumentVar(oWord,"VALIDADE"	,cValid)
OLE_SetDocumentVar(oWord,"CODCLI" 	,AllTrim(M->UA1_CODCLI))
OLE_SetDocumentVar(oWord,"NOMECLI"	,AllTrim(M->UA1_NOME))

OLE_UpDateFields(oWord)

//SELECIONA O DIRETORIO ONDE SERA SALVO O ARQUIVO ".DOC"
cNewFile := cGetFile(" | *.* |" , "Salvar em" ,,,.F., GETF_LOCALHARD + GETF_LOCALFLOPPY + GETF_RETDIRECTORY,.F.)

If(Len(cNewFile) < 1)
	Alert("Nome inválido!")
	Return .F.
Else
	nPos := RAT("\",cNewFile)
	cPathEst := SUBSTR(cNewFile, 1, nPos)
	cNewFile := cPathEst
EndIF

cNewFile := cNewFile+"Contrato_" + AllTrim(M->UA1_NRCONT) + ".doc"

//SALVA O ARQUIVO NA ESTACAO
OLE_SaveAsFile(oWord,cNewFile,,,.F.,)

//COPIA O ARQUIVO SALVO NA ESTACAO PARA O SERVIDOR NO DIRETORIO \WORD\ A PARTIR DO ROOTPATH
CpyT2S(cNewFile,"\word\",.T.) // Copia do Remote para o Servidor

OLE_CloseLink(oWord)

Return(.T.)               

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³GravaPrecoxConcor ºAutor  ³Maximo C. V. N. º Dt ³  18/07/07 º±±
±±ºDesc.     ³Cria registro no cadastro de Preços e Concorrentes          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
*/

Static Function GravaPrecoxConcor() 
 
Local cConcor := "DIPROMED COMERCIO E IMPORTAÇÃO"         
Begin Transaction
                                                     
dbSelectArea("UA4")
UA4->(dbSetOrder(1))
UA4->(DbGoTop())

If UA4->(dbSeek(xFilial("UA4") + M->UA1_CODIGO))
	While !EOF() .And. UA4->UA4_EDITAL == M->UA1_CODIGO
   	    SB1->(dbSeek(xFilial("UA5") + UA4->UA4_PRODUT))									

        If UA4->UA4_EDITAL == M->UA1_CODIGO
     
       		DbSelectArea("UA5")
     		UA5->(DbSetOrder(1))                    
			UA5->(DbGoBottom())
			UA5->(Reclock("UA5",.T.))
			UA5->UA5_FILIAL	:= xFilial("UA5")
			UA5->UA5_EDITAL	:= M->UA1_CODIGO
			UA5->UA5_CONCOR	:= cConcor
			UA5->UA5_PRODUT	:= UA4->UA4_PRODUT
			UA5->UA5_MARMOD := Iif(!Empty(AllTrim(SB1->B1_MARCA)) .or. !Empty(AllTrim(SB1->B1_FABRIC)),(AllTrim(SB1->B1_MARCA)+"/"+AllTrim(SB1->B1_FABRIC)),"")
			UA5->UA5_QTDOFE := UA4->UA4_QUANT
			UA5->UA5_PRCVEN	:= UA4->UA4_PRCVEN			
			UA5->UA5_VENCEU	:= Iif(!Empty(Alltrim(UA4->UA4_VENCEU)),UA4->UA4_VENCEU,"2")
			UA5->(MSUnlock("UA5")) 	
		
		EndIf			
	
	UA4->(dbSkip())
  End
Endif
End Transaction

Return(.T.)

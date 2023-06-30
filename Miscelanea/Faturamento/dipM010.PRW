#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "AP5MAIL.CH"
#INCLUDE "COLORS.CH"
#DEFINE CR    chr(13)+chr(10) // Carreage Return (Fim de Linha)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDIPM010   บAutor  ณFabio Rogerio       บ Data ณ  09/25/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRotina para a escolha dos lotes e separacao dos mesmos.     บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function DIPM010()
Local aArea      := GetArea()
Private cCadastro:= OemToAnsi("Separacao de Pedidos")

Private aRotina := { 	{ 'Pesquisa','PesqBrw'			, 0 , 1},;		 	      			//Pesquisa
{ 'Separar'	,'U_DIPM015(1)'		, 0 , 4},;		  					//Separar
{ 'Estorno'	,'U_DIPMEST'		, 0 , 4},;		  					//Estornar
{ 'Fila'	,'U_DIPMFILA'		, 0 , 2},;		  					//Fila de Impressao
{ 'Legenda'	,'BrwLegenda(cCadastro,"Legenda",aCoresLeg)', 0 , 5}}   //Legenda

Private aCores  := {	{"Empty(U_C5PRENOTA()) .And. Empty(C9_NFISCAL) .And. Empty(C9_BLCRED)",'BR_AMARELO' },;  //Pre-Nota Pronta para Imprimir
{"U_C5PRENOTA() == 'S'",'BR_VERDE'},;	  //Pre-Nota Impressa
{"U_C5PRENOTA() == 'U'",'BR_BRANCO'},;	  //Pre-Nota Impressa
{"U_C5PRENOTA() == 'F' .And. C9_BLCRED $ '01/04'",'BR_AZUL'},;	  //Pre-Nota Bloqueada pelo credito
{"U_C5PRENOTA() == 'R' .And. C9_BLCRED == '09'",'BR_MARROM'},;	  //Pre-Nota Rejeitada pelo credito
{"U_C5PRENOTA() == 'O'",'BR_PINK'},;	  //Pre-Nota Bloqueada pelo operador
{"U_C5PRENOTA() == 'E'",'BR_CINZA'},;	  //Pre-Nota Estornada
{"!Empty(C9_NFISCAL)"  ,'BR_VERMELHO'}}	  //Itens com Nota Emitida

Private aCoresLeg := {	{"BR_VERMELHO"	 , "Itens com Nota Emitida"},;
{"BR_VERDE"   , "OS Gerada"},;
{"BR_BRANCO"  , "Sem OS"},;
{"BR_AMARELO" , "Pre-Nota Pronta para Imprimir"},;
{"BR_AZUL"    , "Pre-Nota Bloqueada Credito"},;
{"BR_MARROM"  , "Pre-Nota Rejeitada pelo Credito"},;
{"BR_PINK"    , "Pre-Nota Bloqueada Operador"},;
{"BR_CINZA"   , "Pre-Nota Estornada"}}

U_DIPPROC(ProcName(0),U_DipUsr()) // JBS 05/10/2005 - Gravando o nome do Programa no SZU
mBrowse( 7, 4,20,74,"SC9",,,,,,aCores)

RestArea(aArea)
Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDIPMSEP   บAutor  ณFabio Rogerio       บ Data ณ  09/25/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRotina para a separacao de lotes.                           บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function DIPMSEP(nTipo,aBoxParam)
Local aArea      := GetArea()
Local aAreaSB2	 := SB2->(GetArea())
Local aAreaSBF	 := SBF->(GetArea())
Local aRetParam  := {}
Local aSaldo     := {}
Local aSC9       := {}
Local aProblema  := {}
Local cQuery     := ""
Local cQueryAux  := ""
Local cTmp       := ""
Local cSeq       := ""
Local cPedido    := ""
Local cHora      := ""
Local nI         := 0
Local nPos       := 0
Local lPre       := .F.
Local lRet       := .T.
Local lLock		 := .F.
Local lFlag      := .F.
Local lIniciou   := .T.
Local lSep		 := .T.
Local cSc5Operado:= ""  // MCVN - 04/09/2007
Local cNumSep 	 := ""
Local cNumD3
Local cQueryBF	 := ""
Local cAliasBF	 := GetNextAlias()
Local cSepara	 := GetNewPar("MV_SEPARA1","")
  Local cUsrLibPre := GetNewPar("MV_ULIBPRE","") // Usuแrio com direito de liberar o usuแrio atual da prenota.
Local aChave	 := {}
Local nTotPed	 := 0      
Local cLockSep	 := "SEPARANDO..."
//Local cES_CLIVLOT	:= &(SuperGetMv("ES_CLIVLOT",,"''"))
Local nPosCliVal	:= 0
Local lProblLotCli	:= .F.    //-- indica que o PV contem lote com validade menor que a tolerada pelo cliente
Local lLockTransf 	:= .F.    //-- indica se ocorreu lock por concorr๊ncia com a rotina de transfer๊ncia
Local cLockPV		:= ""
Local cLockPed		:= ""
//-- Novo conceito de separa็ใo - D'Leme 09/08/2011
Local aPed
Local nCntPed
Local nJ            := 1

Local aLotBlq 		:= {}
Local cMsg			:= ""
Local lImpTra		:= .F.              
Local lNaoMovEst    := .F.
Local lTpAlmox      := .F.

Local lMsErroAuto   := .F.

Private aArrayCab 	:= {}
Private aArrayItens := {}

//giovani 04/07/11 Estorno pedido com icms

Private cEmailIcm   :=  ""
Private	cAssuntIcm  :=  " AVISO - Pedido Com Icms InterEstadual - Prioridade na Libera็ใo"
Private	cAttachIcm  :=  "  a"
Private	cDeIcm      :=  Lower(Alltrim(Posicione("SU7",1,xFilial("SU7")+SC5->C5_OPERADO,"U7_EMAIL")))
Private	cSentIcm 	:=  "DIPM010.prw"
Private _aMIcm	    := {}
Private nLen        := 0
Private cValfim     := " "
Private cNomeDes    := " "
Private nTotped     := 0
Private cLibVista   := " "
Private cMSGcIC     := " "    
Private cMenDep     := " "
DEFAULT aBoxParam   := {}
DEFAULT nTipo 		:= 0

If !(UPPER(U_DipUsr()) $ UPPER(cSepara))
	Aviso("Aten็ใo","Usuแrio nใo tem permissใo para executar esta rotina.",{"Ok"},1)
	lRet := .F.
ElseIf !LockByName(cLockSep,.T.,.T.)
	Aviso("Aten็ใo","Nใo foi possํvel ter acesso exclusivo. Tente novamente.",{"Ok"},1) 
	lRet := .F.
EndIf

If !lRet
	Return(lRet)
EndIf         


If DipInvRot()	
	lRet := .F.
EndIf     


If !lRet
	UnlockByName(cLockSep,.T.,.T.)
	Return(lRet)
EndIf

BEGIN TRANSACTION 

aPed 	:= M010Ped() //-- Funcao que retorna array de pedidos para separacao em ordem de prioridade
nCntPed	:= 0

For nCntPed := 1 To Len(aPed)

	If DipPedDup(aPed[nCntPed])	
		Exit
	EndIf
	
	cLockPed := aPed[nCntPed]+"_"+cEmpAnt+cFilAnt	
	
	If Upper(U_DipUsr()) $ 'MCANUTO/DDOMINGOS/VQUEIROZ/VEGON/RBORGES'
		cLockPed := aPed[nCntPed]+"_TI"
	EndIf
		
	If !LockByName(cLockPed, .T., .T.)
		Aviso("Aten็ใo","O Pedido de venda: " + aPed[nCntPed] + " estแ em uso por outra esta็ใo!",{"Ok"},1)  
		dbSelectArea("SC9")
		Conout("DIPM010-LockByName Falhou: Pedido-"+aPed[nCntPed]+" Data-"+DtoC(ddatabase)+" Hora-"+Time()+" User-"+U_DipUsr())
		Exit
	EndIf
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณSomente separa um pedido por vez.ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If (cPedido <> aPed[nCntPed]) .And. !Empty(cPedido) .And. lPre
		Exit
	EndIf
	
	lImpTra := .F.
	
	//-- Verifica bloqueio de Produtos no PV
	cQryAux := " SELECT COUNT(*) NBLOQ FROM " + RetSqlName("SC9") + " C9 "
	cQryAux += " JOIN " + RetSqlName("SB1") + " B1 ON "
	cQryAux += "    B1.B1_FILIAL      = '" + xFilial("SB1") + "'"
	cQryAux += "    AND B1.B1_COD     = C9.C9_PRODUTO"
	cQryAux += "    AND B1.B1_MSBLQL  = '1'"
	cQryAux += "	AND B1.D_E_L_E_T_ = ' '"
	cQryAux += " WHERE  C9.C9_FILIAL  = '" + xFilial("SC9") + "'"
	cQryAux += "	AND C9.C9_PEDIDO  = '" + aPed[nCntPed] + "'"
	cQryAux += "	AND C9.D_E_L_E_T_ = ' '"
	
	DbCommitAll()
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQryAux),"PBLQL",.T.,.T.)
	If PBLQL->(!Eof()) .And. PBLQL->NBLOQ > 0
		PBLQL->(DbCloseArea())
		MsgAlert("O Pedido de venda: " + aPed[nCntPed] + " cont้m produto bloqueado para comercializa็ใo - comunique a Vendedora!","Aten็ใo")
		Exit
	Else
		PBLQL->(DbCloseArea())
	EndIf
	
	//-- Tramamento de Trava por PV - Daniel Leme 28/07/2011
	cLockPV := "SEPARA_" + aPed[nCntPed]
	If !LockByName(cLockPV, .T., .T.)
		MsgAlert("O Pedido de venda: " + aPed[nCntPed] + " estแ bloqueado em separa็ใo por outra esta็ใo!","Aten็ใo")
		Exit
	EndIf
	                 
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณVerifico se existem produtos que o cliente nใo aceita o lote e chamo a fun็ใo para o bloqueio automแtico.ณ
	//ณNeste ponto jแ passaram todaas as valida็๕es da separa็ใo.                                               ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
    aLotBlq 	:= {}
    aRetVldPed 	:= {}
    aLotesBF	:= {}
	aLotBlq 	:= DipVldPed(aPed[nCntPed])

	
	//-- Dado o Pedido, a separa็ใo ้ verificada como antigamente
	cQuery := " SELECT SC9.R_E_C_N_O_ AS C9RECNO,C9_PEDIDO,C9_ITEM,C9_SEQUEN,C9_PRODUTO,C9_LOCAL,C9_QTDLIB,C6_TES,C5_TRANSP"
	cQuery += " ,C5_HORALIB,F4_ESTOQUE,A4_HORACOR,C5_OPERADO,C6_QTDVEN,C6_LOTECTL,C5_TIPO "
	cQuery += " FROM "+RetSqlName("SC9")+" SC9 "
	cQuery += " JOIN "+RetSqlName("SC5")+" SC5 ON"
	cQuery += "     SC5.C5_FILIAL       = '"+xFilial("SC5")+"'"
	cQuery += "     AND SC5.D_E_L_E_T_  = ' '"
	cQuery += "     AND SC5.C5_PARCIAL <> 'N'"
	cQuery += "     AND SC5.C5_NUM      = SC9.C9_PEDIDO"
	cQuery += "     AND SC5.C5_PRENOTA  = ' '"
	cQuery += "     AND SC5.C5_HORALIB <> ' '"
	cQuery += " JOIN "+RetSqlName("SC6")+" SC6 ON"
	cQuery += "     SC6.C6_FILIAL       = '"+xFilial("SC6")+"'"
	cQuery += "     AND SC6.C6_NUM      = SC9.C9_PEDIDO"
	cQuery += "     AND SC6.C6_ITEM     = SC9.C9_ITEM"
	cQuery += "     AND SC6.D_E_L_E_T_  = ' '"
	cQuery += " JOIN "+RetSqlName("SF4")+" SF4 ON"
	cQuery += "     SF4.F4_FILIAL       = '"+xFilial("SF4")+"'"
	cQuery += "     AND SF4.F4_CODIGO   = SC6.C6_TES"
	cQuery += "     AND SF4.D_E_L_E_T_  = ' '"
	cQuery += " JOIN "+RetSqlName("SA4")+" SA4 ON"
	cQuery += "     SA4.A4_FILIAL       = '"+xFilial("SA4")+"'"
	cQuery += "     AND SA4.A4_COD      = SC5.C5_TRANSP "
	cQuery += "     AND SA4.D_E_L_E_T_  = ' '"
	cQuery += " WHERE "
	cQuery += "     SC9.D_E_L_E_T_      = ' '"
	cQuery += "     AND SC9.C9_FILIAL   = '"+xFilial("SC9")+"'"
	cQuery += "     AND SC9.C9_PEDIDO   = '"+aPed[nCntPed]+"'"
	cQuery += "     AND SC9.C9_BLCRED   = ' '"
	cQuery += "     AND SC9.C9_BLEST    = '02'"
	cQuery += "     AND SC9.C9_SALDO    = 0 "
	cQuery += "     AND SC9.C9_NFISCAL  = ' '"
	
	cQuery += " ORDER BY SC9.C9_ITEM"
	
	DbCommitAll()
	If Select("QRY") > 0
		DbSelectArea("QRY")
		dbCloseArea("QRY")
	EndIf
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"QRY",.T.,.T.)
	memowrite('DIPMSEP.SQL',cQuery)
	
	dbSelectArea("QRY")
	While !Eof()
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณTrata o horario de corte da transportadora.ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		If (nTipo == 1)
			MV_PAR02:= IIF(Valtype(MV_PAR02) == "C",MV_PAR02,StrZero(MV_PAR02,1))
			
			If (MV_PAR02 == "2")
				cHoraCor:= QRY->A4_HORACOR //Posicione("SA4",1,xFilial("SA4")+QRY->C5_TRANSP,"A4_HORACOR")
				cHoraLib:= Left(IncTime(QRY->C5_HORALIB,00,03,30),5)
				If (Left(Time(),5) > cHoraCor) .or. (Left(Time(),5) < cHoraLib)
					dbSelectArea("QRY")
					dbSkip()
					Loop
				EndIf
			EndIf
		Else
			cHoraCor:= QRY->A4_HORACOR //Posicione("SA4",1,xFilial("SA4")+QRY->C5_TRANSP,"A4_HORACOR")
			cHoraLib:= Left(IncTime(QRY->C5_HORALIB,00,03,30),5)
			If (Left(Time(),5) > cHoraCor) .or. (Left(Time(),5) < cHoraLib)
				dbSelectArea("QRY")
				dbSkip()
				Loop
			EndIf
		EndIf
		
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณSomente separa um pedido por vez.ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		If (cPedido <> QRY->C9_PEDIDO) .And. !Empty(cPedido) .And. lPre
			Exit
		EndIf
		
		cPedido  := QRY->C9_PEDIDO  //MCVN 10/04/2007
		
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณGrava "P" na Flag de Pre-Nota.ณ    - //MCVN 10/04/2007
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		If  !lFlag
			dbSelectArea("SC5")
			dbSetOrder(1)
			If dbSeek(xFilial("SC5")+cPedido)
				If Empty(SC5->C5_PARCIAL)
					Reclock("SC5",.F.)
						SC5->C5_PRENOTA := "P"    // MCVN - 06/07/2007
						SC5->C5_DT_PRE  := DATE() // MCVN - 04/09/2007
						SC5->C5_HR_PRE  := TIME() // MCVN - 04/09/2007
					SC5->(MsUnLock())
					SC5->(DbCommit())  // Eriberto 24/04/07
					lFlag := .T.
					cSc5Operado := SC5->C5_OPERADO	// MCVN - 04/09/2007
					U_DiprKardex(cPedido,U_DipUsr(),,.T.,"38")  // Grava inํcio da separa็ใo no kardex
					lIniciou := .F.
				Else
					QRY->(DbCloseArea())
					DisarmTransaction()
					Aviso("Atencao","Nao existem pedidos disponiveis para separacao !!!",{"Ok"})
					RestArea(aAreaSB2)
					RestArea(aArea)
					lRet	:= .F.
				Endif
				
			EndIf
		Endif
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณVerifica se o produto tem controle de Rastro ou Endereco.       ณ
		//ณSe nao existir apenas libera o produto porque ja existe reserva.ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		If (Rastro(QRY->C9_PRODUTO) .Or. Localiza(QRY->C9_PRODUTO)) .And. (QRY->F4_ESTOQUE == "S")
					
			// Verifica se havera transferencia
			SB2->(DbSetOrder(1)) // B2_FILIAL+B2_COD+B2_LOCAL
			aArrayItens := {}
			//SB2->(MsSeek(xFilial("SB2")+QRY->(C9_PRODUTO+C9_LOCAL)))
			//If .F.    
			If SB2->(MsSeek(xFilial("SB2")+QRY->(C9_PRODUTO+C9_LOCAL))) .And. !Empty(SB2->B2_LOCALIZ) .And. !Empty(SB2->B2_DIPQMIN)
			
				aLotesBF := DipVldCXF(aPed[nCntPed],QRY->C9_PRODUTO,QRY->C9_ITEM,aLotBlq)   			
				aSaldo := {}

				
				DbCommitAll()
				
				/// Executa a GravaEmp sem atualizar BF/B8 para obter Origem. Executado antes de contar o SBF pois o BF_EMPENHO esta desatualizado
				aSaldo:= GravaEmp(	;
				QRY->C9_PRODUTO,; 	//-- 01.Cขdigo do Produto
				QRY->C9_LOCAL,;   	//-- 02.Local
				SB2->B2_QATU,;		//-- 03.Quantidade
				Nil,;				//-- 04.Quantidade 2UM
				IIf(QRY->C5_TIPO=="N",QRY->C6_LOTECTL,IIf(cEmpAnt=="04" .And. QRY->C5_TIPO$"B",QRY->C6_LOTECTL,NIL)),;  	//-- 05.Lote
				Nil,;  				//-- 06.SubLote
				Nil,;  				//-- 07.Localizaฦo
				Nil,; 				//-- 08.Numero de Srie
				Nil,;         		//-- 09.OP
				QRY->C9_SEQUEN,;	//-- 10.Seq. do Empenho/Liberaฦo do PV (Pedido de Venda)
				QRY->C9_PEDIDO,;   	//-- 11.PV
				QRY->C9_ITEM,;   	//-- 12.Item do PV
				'SC6',;    			//-- 13.Origem do Empenho
				Nil,;         		//-- 14.OP Original
				Nil,;         		//-- 15.Data da Entrega do Empenho
				Nil,;	    		//-- 16.Array para Travamento de arquivos
				.F.,;     			//-- 17.Estorna Empenho?
				Nil,;         		//-- 18.chamada da Projeฦo de Estoques?
				.F.,;         		//-- 19.Empenha no SB2?
				.F.,;         		//-- 20.Grava SD4?
				.T.,;         		//-- 21.Considera Lotes Vencidos?
				.F.,;         		//-- 22.Empenha no SB8/SBF?
				.T.)        		//-- 23.Cria SDC?  ==> IMPORTANTE: NAO CRIA SDC SE O PARAMETRO ANTERIOR (B2/BF) ESTIVER .F.,
				//--               ==> 				POREM, SOMENTE RETORNA OS LOTES SE ESTIVER .T.

				cQueryBF := " SELECT SUM(BF_QUANT) AS BF_QUANT, SUM(BF_EMPENHO) AS BF_EMPENHO"
				cQueryBF += " FROM "+RetSqlName("SBF")
				cQueryBF += " WHERE BF_FILIAL = '"+xFilial("SBF")+"'"
				cQueryBF += " AND BF_PRODUTO = '"+SB2->B2_COD+"'"
				cQueryBF += " AND BF_LOCAL = '"+SB2->B2_LOCAL+"'"
				cQueryBF += " AND BF_LOCALIZ = '"+SB2->B2_LOCALIZ+"'"
				cQueryBF += " AND D_E_L_E_T_ = ' '"
				DbCommitAll()
				dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQueryBF),cAliasBF,.T.,.T.)
				
				If (cAliasBF)->(!Eof()) .And. ((cAliasBF)->(BF_QUANT-BF_EMPENHO)-QRY->C9_QTDLIB) < SB2->B2_DIPQMIN
					//-- Testa a chava de transfer๊ncia, evitando concorrencia com a transferencia entre empresas - DIPA053
					If !LockByName("TRANSFERINDO...",.T.,.F.)
						lLockTransf := .T.
						(cAliasBF)->(DbCloseArea())
						DisarmTransaction()
						U_DiprKardex(cPedido,U_DipUsr(),"PROBLEMA LOCK TRANSF AUTOMATIC",.T.,"37")
						MsgAlert("Rotina de Transfer๊ncia estแ em uso! Tente separar o pedido "+cPedido+" mais tarde!","Aten็ใo")
						QRY->(DbCloseArea())
						Break               
					Else
						lImpTra := .T.
					EndIf
					
					//-- CABECALHO
					// Tratamento para erro de NumDoc no D3
					cNumD3 := "TR"+Substr(cPedido,3,4)
					SD3->(DbSetOrder(8)) // D3_FILIAL+D3_DOC+D3_NUMSEQ
					Do While  SD3->(MsSeek(xFilial("SD3")+cNumD3))
						cNumD3 := Soma1(cNumD3)
					EndDo
					// Fim do Tratamento
					aArrayItens := {{ cNumD3,;    // 01.Numero do Documento
					dDataBase}}  // 02.Data da Transferencia
					
					nTransf 	:= 0
					// ANTES: Trata a Quantidade maxima como quantidade multipla.
					//Do While nTransf < SB2->B2_DIPQMAX - ((cAliasBF)->(BF_QUANT-BF_EMPENHO)-QRY->C9_QTDLIB)
					
					// Verifica, qtos multimos da qtde maxima serao necessarios para o picking ficar superior ao minimo
					Do While (nTransf + ((cAliasBF)->(BF_QUANT-BF_EMPENHO)-QRY->C9_QTDLIB)) < SB2->B2_DIPQMIN
						nTransf += SB2->B2_DIPQMAX
					EndDo
					
					If (Len(aSaldo) > 0)
						/* Estrutura aSaldo
						aSaldo[1] = (cAliasSBF)->BF_LOTECTL
						aSaldo[2] = (cAliasSBF)->BF_NUMLOTE
						aSaldo[3] = (cAliasSBF)->BF_LOCALIZ
						aSaldo[4] = (cAliasSBF)->BF_NUMSERI
						aSaldo[5] = nEmpenho
						aSaldo[6] = nEmpenho2
						aSaldo[7] = (cAliasSB8)->B8_DTVALID
						aSaldo[8] = SB2->(Recno())
						aSaldo[9] = If(lQuery,(cAliasSBF)->SBFRECNO,(cAliasSBF)->(Recno()))
						aSaldo[10]= {{If(lQuery,(cAliasSB8)->SB8RECNO,(cAliasSB8)->(Recno())),nEmpenho,nEmpenho2,(cAliasSBF)->BF_LOCAL,(cAliasSB8)->B8_POTENCI
						*/
						nTotTransf := 0
						For nI:= 1 To Len(aSaldo)
							// Desconsidera a Localizacao de "picking"
							If aSaldo[nI][3] == SB2->B2_LOCALIZ
								Loop
							EndIf
							// Se o primeiro endereco nao atender o suficiente para atingir o minimo, e o segundo for do mesmo lote e atender, busca direto do segundo endereco
							If Len(aArrayItens) == 1  .And. Len(aSaldo) > nI ;
								.And. (aSaldo[nI][5]+((cAliasBF)->(BF_QUANT-BF_EMPENHO)-QRY->C9_QTDLIB)) < SB2->B2_DIPQMIN ;
								.And. aSaldo[nI][1] == aSaldo[nI+1][1];
								.And. (aSaldo[nI+1][5]+((cAliasBF)->(BF_QUANT-BF_EMPENHO)-QRY->C9_QTDLIB)) >= SB2->B2_DIPQMIN
								nI++
							EndIf
							If Empty(cNumSep)
								cNumSep := GetSx8Num("SC9","C9_NUMSEP") // Obtem numero sequencial de separacao caso haja transferencia
							EndIf
							//--DETALHE
							// A transferencia sera sempre de multiplos ou, caso seja menor que o multiplo, transfere o lote inteiro...
							nEndTransf := 0
							Do While aSaldo[nI][5] >0 .And. nTransf > 0 .And. (nTotTransf+((cAliasBF)->(BF_QUANT-BF_EMPENHO)-QRY->C9_QTDLIB)) < SB2->B2_DIPQMIN
								nTransf			-= Iif(aSaldo[nI][5]>=SB2->B2_DIPQMAX,SB2->B2_DIPQMAX,aSaldo[nI][5])
								nTotTransf 		+= Iif(aSaldo[nI][5]>=SB2->B2_DIPQMAX,SB2->B2_DIPQMAX,aSaldo[nI][5])
								nEndTransf 		+= Iif(aSaldo[nI][5]>=SB2->B2_DIPQMAX,SB2->B2_DIPQMAX,aSaldo[nI][5])
								aSaldo[nI][5] 	-= Iif(aSaldo[nI][5]>=SB2->B2_DIPQMAX,SB2->B2_DIPQMAX,aSaldo[nI][5])
							EndDo
							
							aAdd(aArrayItens,{  QRY->C9_PRODUTO,; // 01.Produto Origem
							posicione("SB1",1,xFilial("SB1")+QRY->C9_PRODUTO,"B1_DESC"),; // 02.Descricao
							posicione("SB1",1,xFilial("SB1")+QRY->C9_PRODUTO,"B1_UM"),; // 03.Unidade de Medida
							SB2->B2_LOCAL,; // 04.Local Origem
							aSaldo[nI][3],; // 05.Endereco Origem
							QRY->C9_PRODUTO,; // 06.Produto Destino
							posicione("SB1",1,xFilial("SB1")+QRY->C9_PRODUTO,"B1_DESC"),; // 07.Descricao
							posicione("SB1",1,xFilial("SB1")+QRY->C9_PRODUTO,"B1_UM"),; // 08.Unidade de Medida
							SB2->B2_LOCAL,; // 09.Armazem Destino
							SB2->B2_LOCALIZ,; // 10.Endereco Destino
							CriaVar("D3_NUMSERI",.F.),; // 11.Numero de Serie
							aSaldo[nI][1],; // 12.Lote Origem
							CriaVar("D3_NUMLOTE",.F.),; // 13.Sublote
							aSaldo[ni][7],;//CriaVar("D3_DTVALID",.F.),; // 14.Data de Validade
							CriaVar("D3_POTENCI",.F.),; // 15.Potencia do Lote
							nEndTransf,; // 16.Quantidade
							CriaVar("D3_QTSEGUM",.F.),; // 17.Quantidade na 2 UM
							CriaVar("D3_ESTORNO",.F.),; // 18.Estorno
							CriaVar("D3_NUMSEQ",.F.),; // 19.NumSeq
							aSaldo[nI][1],; // 20.Lote Destino
							aSaldo[ni][7],;//CriaVar("D3_DTVALID",.F.),; // 21.Data de Validade do Destino
							Criavar("D3_ITEMGRD",.F.),; // 22.Item grade MCVN - 16/11/09)
							"X" ,; // 23.Id DCF
							"" ,; // 24.Observa็ใo							
							"Rot. Automatica de Separacao",; // 23.Explicacao
							cNumSep }) // 24. Numero de separacao
							
							// Se nesta transferencia ja foi atingido a qtde suficiente para deixar o picking maior que o mํnimo, para de transferir.
							If nTransf <= 0 .Or. (nTotTransf+((cAliasBF)->(BF_QUANT-BF_EMPENHO)-QRY->C9_QTDLIB)) >= SB2->B2_DIPQMIN
								Exit
							EndIf
						Next nI
						
						// Salva MV's, pois a execauto esta alterando-os
						aMVs := {}
						For nI := 1 To Len(aBoxParam)
							cMV := "MV_PAR"+StrZero(nI,2)
							aAdd(aMVs,&cMV)
						Next nI
						
						// Chama a ExecAuto
						lMsErroAuto := .F.
						If Len(aArrayItens) >1
							MSExecAuto({|x,y| MATA261(x,y)},aArrayItens,3) //Inclusao
						EndIf
						
						// Restaurar MV's da Tela
						For nI := 1 to Len(aMVs)
							cMV := "MV_PAR"	+StrZero(nI,2)
							&cMV := aMVs[nI]
						Next nI
						
						DbCommitAll()
						
						// Testa se ExecAuto detectou algum erro.
						If lMsErroAuto
							DisarmTransaction()
							UnLockByName("TRANSFERINDO...",.T.,.F.) // Libera Lock - mesma Chave do DIPA053
							U_DiprKardex(cPedido,U_DipUsr(),"PROBLEMA NA TRANSF AUTOMATICA ",.T.,"37")
							Alert("Erro ao efetuar Transferencia Automatica do Pedido "+AllTrim(cPedido)+ " Item  "+AllTrim(QRY->C9_PRODUTO) )
							Mostraerro()
							QRY->(DbCloseArea())
							Break
						Endif
					EndIf
					UnLockByName("TRANSFERINDO...",.T.,.F.) // Libera Lock - mesma Chave do DIPA053
				EndIf
				(cAliasBF)->(DbCloseArea())
			EndIf
			
			If Empty(QRY->C6_LOTECTL)
				aLotesBF := DipVldCXF(aPed[nCntPed],QRY->C9_PRODUTO,QRY->C9_ITEM,aLotBlq)   
			EndIf
			
			aSaldo := {}
			
			If Len(aLotesBF)>0 .And. aScan(aLotesBF,{|x| x[1]+x[2]+x[6]==QRY->(C9_PRODUTO+C9_LOCAL+C9_ITEM) })>0
				For nI:=1 to Len(aLotesBF)  
					
					DbCommitAll()  
					aAdd(aSaldo, GravaEmp(	;
					QRY->C9_PRODUTO,; 	//-- 01.Cขdigo do Produto
					QRY->C9_LOCAL,;   	//-- 02.Local
					aLotesBF[nI,5],;	//-- 03.Quantidade
					Nil,;				//-- 04.Quantidade 2UM
					aLotesBF[nI,3],;  	//-- 05.Lote
					Nil,;  				//-- 06.SubLote
					aLotesBF[nI,4],; 	//-- 07.Localizaฦo
					Nil,; 				//-- 08.Numero de Srie
					Nil,;         		//-- 09.OP
					QRY->C9_SEQUEN,;	//-- 10.Seq. do Empenho/Liberaฦo do PV (Pedido de Venda)
					QRY->C9_PEDIDO,;    //-- 11.PV
					QRY->C9_ITEM,;      //-- 12.Item do PV
					'SC6',;    			//-- 13.Origem do Empenho
					Nil,;         		//-- 14.OP Original
					Nil,;         		//-- 15.Data da Entrega do Empenho
					Nil,;	    		//-- 16.Array para Travamento de arquivos
					.F.,;     			//-- 17.Estorna Empenho?
					Nil,;         		//-- 18.chamada da Projeฦo de Estoques?
					.F.,;         		//-- 19.Empenha no SB2?
					.F.,;         		//-- 20.Grava SD4?
					.T.,;         		//-- 21.Considera Lotes Vencidos?
					.T.,;         		//-- 22.Empenha no SB8/SBF?
					.T.))        		//-- 23.Cria SDC?					
				Next nI
			Else
				DbCommitAll()
				aAdd(aSaldo, GravaEmp(	;
				QRY->C9_PRODUTO,; 	//-- 01.Cขdigo do Produto
				QRY->C9_LOCAL,;   	//-- 02.Local
				QRY->C9_QTDLIB,;	//-- 03.Quantidade
				Nil,;				//-- 04.Quantidade 2UM
				IIf(QRY->C5_TIPO=="N",QRY->C6_LOTECTL,IIf(cEmpAnt=="04" .And. QRY->C5_TIPO$"B",QRY->C6_LOTECTL,NIL)),;   	//-- 05.Lote
				Nil,;  				//-- 06.SubLote
				Nil,;  				//-- 07.Localizaฦo
				Nil,; 				//-- 08.Numero de Srie
				Nil,;         		//-- 09.OP
				QRY->C9_SEQUEN,;	//-- 10.Seq. do Empenho/Liberaฦo do PV (Pedido de Venda)
				QRY->C9_PEDIDO,;    //-- 11.PV
				QRY->C9_ITEM,;      //-- 12.Item do PV
				'SC6',;    			//-- 13.Origem do Empenho
				Nil,;         		//-- 14.OP Original
				Nil,;         		//-- 15.Data da Entrega do Empenho
				Nil,;	    		//-- 16.Array para Travamento de arquivos
				.F.,;     			//-- 17.Estorna Empenho?
				Nil,;         		//-- 18.chamada da Projeฦo de Estoques?
				.F.,;         		//-- 19.Empenha no SB2?
				.F.,;         		//-- 20.Grava SD4?
				.T.,;         		//-- 21.Considera Lotes Vencidos?
				.T.,;         		//-- 22.Empenha no SB8/SBF?
				.T.))        		//-- 23.Cria SDC?
			EndIf

			nSldEmp := 0      
			For nI:=1 to Len(aSaldo)
				aEval(aSaldo[nI], { |x| nSldEmp += x[5] })
			Next nI	
						
			If (Len(aSaldo) > 0)
				//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
				//ณRefaz o C9 com base nos lotes.ณ
				//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
				dbSelectArea("SC9")
				dbGoTo(QRY->C9RECNO)
				
				/* Estrutura aSaldo
				aSaldo[1] = (cAliasSBF)->BF_LOTECTL
				aSaldo[2] = (cAliasSBF)->BF_NUMLOTE
				aSaldo[3] = (cAliasSBF)->BF_LOCALIZ
				aSaldo[4] = (cAliasSBF)->BF_NUMSERI
				aSaldo[5] = nEmpenho
				aSaldo[6] = nEmpenho2
				aSaldo[7] = (cAliasSB8)->B8_DTVALID
				aSaldo[8] = SB2->(Recno())
				aSaldo[9] = If(lQuery,(cAliasSBF)->SBFRECNO,(cAliasSBF)->(Recno()))
				aSaldo[10]= {{If(lQuery,(cAliasSB8)->SB8RECNO,(cAliasSB8)->(Recno())),nEmpenho,nEmpenho2,(cAliasSBF)->BF_LOCAL,(cAliasSB8)->B8_POTENCI
				*/
				
				For nI:= 1 To Len(aSaldo)
					For nJ:=1 To Len(aSaldo[nI])
						nPos:= aScan(aSC9,{|x| x[1]+x[2]+x[5]+x[10]+x[11] == SC9->(C9_PEDIDO+C9_ITEM+C9_PRODUTO)+aSaldo[nI,nJ,1]+aSaldo[nI,nJ,2]})
						If (nPos == 0)
							//         1              2            3               4            5               6             7            8               9              10           11           12           13           14              15           16              17             18              19              20           21
							Aadd(aSC9,{SC9->C9_PEDIDO,SC9->C9_ITEM,SC9->C9_CLIENTE,SC9->C9_LOJA,SC9->C9_PRODUTO,SC9->C9_LOCAL,aSaldo[nI,nJ,5],SC9->C9_DATALIB,SC9->C9_PRCVEN,aSaldo[nI,nJ,1],aSaldo[nI,nJ,2],aSaldo[nI,nJ,4],aSaldo[nI,nJ,7],SC9->C9_OPERADO,SC9->C9_VEND,SC9->C9_ITEMSDB,SC9->C9_FORNEC,SC9->C9_PRIRESE,SC9->C9_PRIENTR,aSaldo[nI,nJ,3],SC9->C9_IDENTB6})
						Else
							aSC9[nPos,7]+= aSaldo[nI,nJ,5]
						EndIf
					Next nJ
				Next nI
				
				
				//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
				//ณVerifica a maior sequencia do item.ณ
				//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
				//cTmp:= "SELECT MAX(C9_SEQUEN) AS C9_SEQUEN FROM " + RetSqlName("SC9") + " WHERE D_E_L_E_T_ <> '*' AND C9_FILIAL+C9_PEDIDO+C9_ITEM+C9_PRODUTO = '" + SC9->(C9_FILIAL+C9_PEDIDO+C9_ITEM+C9_PRODUTO) + "'"
				cTmp:= "SELECT MAX(C9_SEQUEN) AS C9_SEQUEN FROM " + RetSqlName("SC9") + " WHERE D_E_L_E_T_ = ' ' AND C9_FILIAL = '"+SC9->C9_FILIAL+"' AND C9_PEDIDO = '"+SC9->C9_PEDIDO+"' AND C9_ITEM = '"+SC9->C9_ITEM+"' AND C9_PRODUTO = '" + SC9->C9_PRODUTO + "'"
				DbCommitAll()
				dbUseArea(.T.,"TOPCONN",TcGenQry(,,cTmp),"TMP",.T.,.T.)
				cSeq:= Iif(TMP->C9_SEQUEN=='01','00',TMP->C9_SEQUEN)
				TMP->(dbCloseArea())
				
				//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
				//ณDeleta do C9 para criar de acordo com os saldos dos lotes.ณ
				//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
				RecLock("SC9",.F.,.T.)
				dbDelete()
				SC9->(MsUnLock())
				
				//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
				//ณCria o C9 a partir dos saldos.ณ
				//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
				For nI:= 1 To Len(aSC9)
					cSeq:= Soma1(cSeq,2)
					RecLock("SC9",.T.)
					Replace C9_FILIAL  With xFilial("SC9")
					Replace C9_PEDIDO  With aSC9[nI,1]
					Replace C9_ITEM    With aSC9[nI,2]
					Replace C9_CLIENTE With aSC9[nI,3]
					Replace C9_LOJA    With aSC9[nI,4]
					Replace C9_PRODUTO With aSC9[nI,5]
					Replace C9_LOCAL   With aSC9[nI,6]
					Replace C9_QTDLIB  With aSC9[nI,7]
					Replace C9_DATALIB With aSC9[nI,8]
					Replace C9_PRCVEN  With aSC9[nI,9]
					Replace C9_LOTECTL With aSC9[nI,10]
					Replace C9_NUMLOTE With aSC9[nI,11]
					Replace C9_NUMSERI With aSC9[nI,12]
					Replace C9_DTVALID With aSC9[nI,13]
					Replace C9_BLEST   With ""
					Replace C9_SEPARAD With cD10CodSep
					Replace C9_SEQUEN  With cSeq
					
					//Eriberto 02/03/07
					Replace C9_OPERADO With If(Empty(alltrim(aSC9[nI,14])),cSc5Operado,aSC9[nI,14]) // MCVN - 04/09/2007
					Replace C9_VEND    With aSC9[nI,15]
					Replace C9_ITEMSDB With aSC9[nI,16]
					Replace C9_FORNEC  With aSC9[nI,17]
					Replace C9_PRIRESE With aSC9[nI,18]
					Replace C9_PRIENTR With aSC9[nI,19]
					Replace C9_QTDVEN  With SC9->C9_QTDLIB
					Replace C9_QTDORI  With SC9->C9_QTDLIB - SC9->C9_SALDO
					Replace C9_SALDO   With SC9->C9_QTDVEN - SC9->C9_QTDORI
					Replace C9_NUMSEP  With Iif(Len(aArrayItens)>1,cNumSep,'')
					Replace C9_IDENTB6 With aSC9[nI,21]
					SC9->(MsUnLock())
					
					/*					
					//-- Testa se o cliente controla validade do lote: Formato do parametro: <CODCLI>+":NNNN;", onde NNNN eh a qtde de dias da validade e ";" o separador entre os clientes
					If (nPosCliVal := At( SC9->C9_CLIENTE, cES_CLIVLOT) ) > 0
						nPosCliVal += Len(SC9->C9_CLIENTE)
						If 	Substr(cES_CLIVLOT, nPosCliVal, 1) == ":" .And. ;
							Val(Substr(cES_CLIVLOT, nPosCliVal+1, 4)) > (SC9->C9_DTVALID - dDataBase)
							
							Aadd(aProblema,{SC9->C9_PRODUTO,SC9->C9_ITEM,SC9->C9_SEQUEN, 	"Lote c/ validade nao aceita p/ cli"})
							lProblLotCli := .T.
						EndIf
					EndIf
					*/
					aAdd(aChave,{SC9->C9_QTDLIB,SC9->C9_PRCVEN})
					
					//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
					//ณAjustando os campos DC_TRT e DC_SEQณ
					//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
					dbSelectArea("SDC")
					dbSetOrder(5)
					//				dbSeek(xFilial("SDC")+SC9->C9_LOCAL+SC9->C9_PEDIDO+SC9->C9_ITEM+SC9->C9_PRODUTO+SC9->C9_LOTECTL+aSC9[nI,20])
					dbSeek(xFilial("SDC")+SC9->C9_LOCAL+SC9->C9_PEDIDO+SC9->C9_ITEM+SC9->C9_PRODUTO+SC9->C9_LOTECTL)
					Do While SDC->(!EOF()) .And. ;
						xFilial("SC9")+SC9->C9_LOCAL+SC9->C9_PEDIDO+SC9->C9_ITEM+SC9->C9_PRODUTO+SC9->C9_LOTECTL ==;   // MCVN - ACHO QUE O ERRO ESTม AQUI 31/08/2007 AS 18:17
						xFilial("SDC")+SDC->DC_LOCAL+SDC->DC_PEDIDO+SDC->DC_ITEM+SDC->DC_PRODUTO+SDC->DC_LOTECTL
						
						
						//xFilial("SC9")+SC9->C9_LOCAL+SC9->C9_PEDIDO+SC9->C9_ITEM+SC9->C9_PRODUTO+SC9->C9_LOTECTL+aSC9[nI,20] ==;   //ACHO QUE O ERRO ESTม AQUI 31/08/2007 AS 18:17
						//xFilial("SDC")+SDC->DC_LOCAL+SDC->DC_PEDIDO+SDC->DC_ITEM+SDC->DC_PRODUTO+SDC->DC_LOTECTL+SDC->DC_LOCALIZ
						
						If Empty(SDC->DC_ESTFIS)
							RecLock("SDC",.F.)
							SDC->DC_ESTFIS := SDC->DC_TRT+" "+SDC->DC_SEQ
							SDC->DC_TRT := SC9->C9_SEQUEN
							SDC->DC_SEQ := SC9->C9_SEQUEN
							SDC->(MsUnLock())
						EndIf
						SDC->(dbSkip())
					EndDo
					
				Next nI
				
				If nSldEmp != QRY->C9_QTDLIB
					Aadd(aProblema,{SC9->C9_PRODUTO,SC9->C9_ITEM,SC9->C9_SEQUEN,"Saldo Empenhado dif. Qtde Liberada"})
					
				ElseIf QRY->C6_QTDVEN != QRY->C9_QTDLIB .And. SuperGetMv("ES_VSC9SEP",,.T.)
					
					cTmp := " SELECT SUM(C9_QTDLIB) AS C9_QTDLIB"
					cTmp += " FROM " + RetSqlName("SC9") + " C9"
					cTmp += " WHERE "
					cTmp += "    C9_FILIAL = '" + SC9->C9_FILIAL + "'"
					cTmp += "    AND C9_PEDIDO  = '" + SC9->C9_PEDIDO  + "'"
					cTmp += "    AND C9_ITEM    = '" + SC9->C9_ITEM    + "'"
					cTmp += "    AND D_E_L_E_T_ = ' '"
					DbCommitAll()
					dbUseArea(.T.,"TOPCONN",TcGenQry(,,cTmp),"TMP",.T.,.T.)
					If QRY->C6_QTDVEN != TMP->C9_QTDLIB
						Aadd(aProblema,{SC9->C9_PRODUTO,SC9->C9_ITEM,SC9->C9_SEQUEN,"Qtde Lib. dif. Pedido de Venda"})
					EndIf
					TMP->(dbCloseArea())
				EndIf
				
				aSC9 := {}
				lPre := .T.
			Else
				lPre := .T.      // VER DEPOIS
				Aadd(aProblema,{QRY->C9_PRODUTO,QRY->C9_ITEM,QRY->C9_SEQUEN,"Nใo conseguiu empenhar - Sem Saldo"})
			EndIf                 
		Else
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณApenas libera o estoque.ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			dbSelectArea("SC9")
			dbGoTo(QRY->C9RECNO)
			RecLock("SC9",.F.)
			Replace C9_BLEST   With ""
			Replace C9_SEPARAD With cD10CodSep
			Replace C9_OPERADO With cSc5Operado  // MCVN - 04/09/2007
			SC9->(MsUnLock())
			
			aAdd(aChave,{SC9->C9_QTDLIB,SC9->C9_PRCVEN})
			
			lPre:= .T.
			
		EndIf
		DbCommitAll()
		dbSelectArea("QRY")
		dbSkip()
	End
	QRY->(dbCloseArea())
	
	If Len(aLotBlq) > 0
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณCodigo provisorio para monitorar a melhoria... Retirar apos estabilizada. 22/11/2012ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		//INICIO
		cMsg := "BLOQUEIO DE LOTE AUTOMมTICO - DIPM010"+CHR(10)+CHR(13)
		cMsg += "Acompanhar o pedido: "+AllTrim(aPed[nCntPed])
		U_DIPCIC(cMsg,"MAXIMO.CANUTO,DIEGO.DOMINGOS")
		//FIM
		
		U_DipDBlPrd(aLotBlq)
	EndIf
	
	UnLockByName(cLockPV, .T., .T.) //-- Libera Lock do PV - D'Leme: 28/07/2011
	UnLockByName(cLockPed, .T., .T.)
	
Next nCntPed

//Bloqueia a separa็ใo do pedido se a separa็ใo estiver com problema 
If Len(aProblema) > 0
    SC5->(RecLock("SC5",.F.))
    	SC5->C5_XBLQNF := "S"
    SC5->(MsUnLock())
EndIf 

//-- Grava o Kardex de Problema com Limite de Validade do Lote
If Len(aProblema) > 0 .And. lProblLotCli
	U_DiprKardex(SC5->C5_NUM,U_DipUsr(),"LOTE(S) FORA DA VALIDADE CLIEN",.T.,"37")
EndIf                             

//-- Grava o Kardex
If !Empty(cPedido) .And. lPre
	aEval(aChave,{ |x|   nTotPed += NoRound(x[1]*x[2],2)  })
	//-- Aten็ใo nใo altere a descricao-"SEPARACAO OK - "  sem alterar sua busca no PE M461VTOT
	U_DiprKardex(cPedido,U_DipUsr(),"SEPARACAO OK - "+AllTrim(Transform(Val(Embaralha(StrZero(Int(nTotPed),9),0)),"@E 999,999,999")),.T.,"39")
EndIf

If !Empty(cLockPV)
	UnLockByName(cLockPV, .T., .T.) //-- Libera Lock do PV - D'Leme: 28/07/2011
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณChama a Impressao da Pre-Nota.ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Conout(cPedido+" - "+IIf(lPre,"T","F")+" - "+IIf(lLockTransf,"T","F")+" - "+IIf(lMsErroAuto,"T","F"))

cMenDep := AllTrim(SC5->C5_MENDEP)

If !Empty(cPedido) .And. lPre .And. !lLockTransf .And. !lMsErroAuto

	DipmSepCIC(cPedido,lIniciou,aProblema) // Cic da separa็ใo
    
    If cEmpAnt == '01' // Somente para Dipromed
	    lNaoMovEst := NaoMovEst(cPedido,cMenDep)             // Verifica se nใo movimenta estoque e dispara CIC e e-mail 
	    lTpAlmox   := TpAlmox(cPedido,cMenDep) 	           // Verifica se almoxarifado ้ diferente de 01 e dispara CIC e e-mail 
    Endif

	Conout(cPedido+" - Entrou IF 1")
	
	
	If GetNewPar("ES_IMPPREN","0") == "1" // .Or. (cEmpAnt=="04" .And. SC5->C5_TIPO=="B") //RBorges 28/11/18 - Solicita็ใo Carol
    	
    	Conout(cPedido+" - Entrou IF 2")        
    	
		U_PRENOTA(cPedido,.T.,aProblema,cD10CodSep)

    	Conout(cPedido+" - Imprimiu prenota - C5_PRENOTA = "+SC5->C5_PRENOTA)		
    	
		If SC5->C5_PRENOTA == 'P'
	    	Conout(cPedido+" - Gravou S")		
			SC5->(RecLock("SC5",.F.))
				SC5->C5_PRENOTA := "S"
			SC5->(MsUnLock())
		EndIf  
		                            
	ElseIf !lNaoMovEst .And. !lTpAlmox
	
		U_GeraOs(nil,nil,cPedido)     
		
		If lImpTra .And. !Empty(cNumSep)
			U_TRANSFAUTO(cNumSep,.T.,.T.,cPedido)
		EndIf                  
		
		If SC5->C5_PRENOTA == 'P'
			SC5->(RecLock("SC5",.F.))
				SC5->C5_PRENOTA := "U"
			SC5->(MsUnLock())
		EndIf                
		
	EndIf
	
	If	SC5->C5_PRENOTA == "S" // Envia e-mail de ST ou Suframa    
		
		U_CICMailAV(cPedido)
		u_DipICMSCF(cPedido)				     
						
	Endif

Else
	If Empty(cPedido)
		Aviso("Atencao","Nao existem pedidos disponiveis para separacao !!!",{"Ok"})
	ElseIf lPre
		Aviso("Atencao","O Pedido " + AllTrim(cPedido) + " nao foi totalmente processado! Verifique a necessidade de Estorno!",{"OK"})
	EndIf
	lRet:= .F.
EndIf


END TRANSACTION // Eriberto 22/03/2007

RestArea(aAreaSB2)
RestArea(aArea)

UnLockByName(cLockSep, .T., .T.)

Return (lRet)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDIPMEST   บAutor  ณFabio Rogerio       บ Data ณ  09/25/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRotina para estorno da separacao de lotes.                  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function DIPMEST(cAlias,nReg,nOpc)
Local aArea        	:= GetArea()
Local aBoxParam    	:= {}
Local aRetParam    	:= {}
Local aSaldo       	:= {}
Local aMsg         	:= {}
Local cPedido      	:= SC9->C9_PEDIDO
Local nI           	:= 0
Local lFoiSeparado 	:= .F.
Local NomeCli      	:= ""
Local EmailOper    	:= ""
Local cSuframa     	:= ""
Local cLockPV 		:= ""
Local _aRet			:= {}
Local cMsgOS		:= ""

Private cEmailIc    := ""
Private	cAssuntoIc  :=  " CANCELAMENTO - Estorno de Pedido Com Icms InterEstadual"
Private	cAttachIc   :=  "  a"
Private	cDeIc       :=  Lower(Alltrim(Posicione("SU7",1,xFilial("SU7")+SC5->C5_OPERADO,"U7_EMAIL")))
Private	cFuncSentIc :=  "MT460EST.prw"
Private _aMsgIcm    := {}
Private nLen        := 0
Private cValfim     := " "
Private cNomeDes    := " "
Private nTotped     := 0
Private cLibVista   := "  "
Private cMSGcIC     := " "

If !Empty(GetNewPar("ES_DIPMEST","")) .And. !Upper(u_DipUsr())$GetNewPar("ES_DIPMEST","")
	Aviso("Aten็ใo","Voc๊ nใo tem permissใo para estornar pedidos.",{"Ok"})	 
	Return
EndIf

dbSelectArea("SC9")
dbSetOrder(1)
dbSeek(xFilial("SC9")+cPedido,.T.)
While !Eof() .And. (xFilial("SC9")+cPedido == SC9->(C9_FILIAL+C9_PEDIDO))
	
	If Empty(SC9->C9_BLEST) .And. !Empty(SC9->C9_SEPARAD) .And. !lFoiSeparado
		lFoiSeparado := .T.
	EndIf
	
	dbSkip()
EndDo

If !lFoiSeparado
	Aviso("Atencao","O estorno somente e possivel para pedidos ja separados !!!",{"Ok"})
	Aviso("Atencao","Se deu erro na separa็ใo do pedido  e s๓ tem um item, avise a informแtica !!!",{"Ok"})
	Return
EndIf                

CB7->(dbSetOrder(2))
If CB7->(dbSeek(xFilial("CB7")+cPedido))  
	cMsgOS := ""
	While !CB7->(Eof()) .And. CB7->CB7_PEDIDO = cPedido
		If Empty(CB7->CB7_NOTA)
			cMsgOS += CB7->CB7_ORDSEP+"/"		
		EndIf
		CB7->(dbSkip())
	EndDo    
	If !Empty(cMsgOS)
		Aviso("Atencao","Este pedido possui ordem de separa็ใo gerada. "+CHR(10)+CHR(13)+;
						"Estorne a ordem de separa็ใo antes de prosseguir."+CHR(10)+CHR(13)+;
						"OS(s): "+SubStr(cMsgOS,1,Len(cMsgOS)-1),{"Ok"})	
		Return
	EndIf
EndIf

SC5->(dbSetOrder(1))       
If SC5->(dbSeek(xFilial("SC5")+AllTrim(cPedido))) .And.;
	Aviso("Atencao","Confirma o estorno da separacao do pedido " + cPedido + " ?",{"Ok","Cancela"}) == 1
    
	If SC5->(FieldPos("C5_XCHVPRE"))>0 .And. !Empty(SC5->C5_XCHVPRE)
		_aRet := U_TelaPSW(AllTrim(SC5->C5_NUM)) 
	    
		While _aRet[1] .And. _aRet[2] <> SC5->C5_XCHVPRE                                      
			Aviso("Aten็ใo","Senha digitada nใo confere. Verifique a prenota.",{"Ok"},1)
			_aRet := U_TelaPSW(SC5->C5_NUM) 	
		EndDo
		 
		If !_aRet[1]
			RestArea(aArea)
			Return				                      		
		EndIf
	EndIf
	
	//-- Tramamento de Trava por PV - Daniel Leme 28/07/2011
	cLockPV := "SEPARA_" + cPedido
	If !LockByName(cLockPV, .T., .T.)
		MsgAlert("O Pedido de venda: " + cPedido + " estแ bloqueado em separa็ใo por outra esta็ใo!","Aten็ใo")
	Else
		
		BEGIN TRANSACTION // Eriberto 22/03/2007
		
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณVerifica os pedidos que devem ser separados.ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		dbSelectArea("SC9")
		dbSetOrder(1)
		dbSeek(xFilial("SC9")+cPedido,.T.)
		While !Eof() .And. (xFilial("SC9")+cPedido == SC9->(C9_FILIAL+C9_PEDIDO))
			
			If !Empty(SC9->C9_BLEST)
				
				RecLock("SC9",.F.)               // MCVN 10/05/2007
				If  Empty(SC9->C9_NFISCAL)       // MCVN 10/08/2010
					Replace C9_PARCIAL With "N"  // MCVN 10/05/2007
				Endif							 // MCVN 10/08/2010
				SC9->(MsUnLock())                // MCVN 10/05/2007
				
				dbSelectArea("SC9")
				dbSkip()
				Loop
			EndIf
			
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณVerifica se o produto tem controle de Rastro ou Endereco.       ณ
			//ณSe nao existir apenas libera o produto porque ja existe reserva.ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			If Rastro(SC9->C9_PRODUTO) .Or. Localiza(SC9->C9_PRODUTO)
				SB2->(dbSetOrder(1))
				SB2->(dbSeek(xFilial("SB2")+SC9->C9_PRODUTO+SC9->C9_LOCAL))
				
				dbSelectArea("SDC")
				dbSetOrder(1)
				dbSeek(xFilial("SDC")+SC9->C9_PRODUTO+SC9->C9_LOCAL+"SC6"+SC9->C9_PEDIDO+SC9->C9_ITEM+SC9->C9_SEQUEN,.T.)
				While !Eof() .And. (xFilial("SDC")+SC9->C9_PRODUTO+SC9->C9_LOCAL+"SC6"+SC9->C9_PEDIDO+SC9->C9_ITEM+SC9->C9_SEQUEN ==;
					SDC->(DC_FILIAL+DC_PRODUTO+DC_LOCAL+DC_ORIGEM+DC_PEDIDO+DC_ITEM+DC_SEQ))
					
					GravaEmp(	SDC->DC_PRODUTO,; 	//-- 01.Cขdigo do Produto
					SDC->DC_LOCAL,;   	//-- 02.Local
					SDC->DC_QUANT,;		//-- 03.Quantidade
					Nil,;				//-- 04.Quantidade 2UM
					SDC->DC_LOTECTL,;  	//-- 05.Lote
					SDC->DC_NUMLOTE,;  	//-- 06.SubLote
					SDC->DC_LOCALIZ,;  	//-- 07.Localizaฦo
					SDC->DC_NUMSERI,; 	//-- 08.Numero de Srie
					Nil,;         		//-- 09.OP
					SDC->DC_SEQ,;		//-- 10.Seq. do Empenho/Liberaฦo do PV (Pedido de Venda)
					SDC->DC_PEDIDO,;    //-- 11.PV
					SDC->DC_ITEM,;      //-- 12.Item do PV
					'SC6',;    			//-- 13.Origem do Empenho
					Nil,;         		//-- 14.OP Original
					Nil,;         		//-- 15.Data da Entrega do Empenho
					Nil,;	    		//-- 16.Array para Travamento de arquivos
					.T.,;     			//-- 17.Estorna Empenho?
					Nil,;         		//-- 18.chamada da Projeฦo de Estoques?
					.F.,;         		//-- 19.Empenha no SB2?
					.F.,;         		//-- 20.Grava SD4?
					.T.,;         		//-- 21.Considera Lotes Vencidos?
					.T.,;         		//-- 22.Empenha no SB8/SBF?
					.T.)        		//-- 23.Cria SDC?
					
					dbSelectArea("SDC")
					dbSkip()
				End
				
				
				RecLock("SC9",.F.)
				Replace C9_LOTECTL With ""
				Replace C9_NUMLOTE With ""
				Replace C9_NUMSERI With ""
				Replace C9_BLEST   With "02"
				Replace C9_SEPARAD With ""
				Replace C9_PARCIAL With "N"  // MCVN 10/05/2007
				SC9->(MsUnLock())
			Else
				//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
				//ณApenas bloqueia o estoque.ณ
				//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
				RecLock("SC9",.F.)
				Replace C9_BLEST   With "02"
				Replace C9_SEPARAD With ""
				Replace C9_PARCIAL With "N"  // MCVN 10/05/2007
				SC9->(MsUnLock())
				
			EndIf
			
			dbSelectArea("SC9")
			dbSkip()
		End
		
		
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณLibera a Flag de Pre-Nota.ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		dbSelectArea("SC5")
		dbSetOrder(1)
		If dbSeek(xFilial("SC5")+cPedido)
			Reclock("SC5",.F.)
			SC5->C5_PRENOTA := "E"
			SC5->C5_DT_PRE  := Ctod("")
			SC5->C5_HR_PRE  := ""
			SC5->C5_PARCIAL := "N" // MCVN 10/05/2007 
			If SC5->(FieldPos("C5_XCHVPRE"))>0
				SC5->C5_XCHVPRE := ""
			EndIf                                       
			If SC5->(FieldPos("C5_XTIPPRE"))>0
				SC5->C5_XTIPPRE := ""
			EndIf
			SC5->C5_XBLQNF := ""
			SC5->(MsUnLock())
			SC5->(DbCommit())  // Eriberto 24/04/07
			
			U_DiprKardex(cPedido,U_DipUsr(),"Estorno da pre-nota",.T.,"36")
			If !("HEALTH" $ SM0->M0_NOMECOM)  // MCVN  - 10/08/2009
				DipmEstCIC(cPedido) // Envia CIC para operador   MCVN - 30/04/2007
			Else
				//	DipmEstCIC(cPedido) // Envia CIC para operador   MCVN - 30/04/2007
			Endif
			
			
			//-- giovani email - cic do estorno 05/07/2011
			If SC5->C5_TIPODIP = "1" .And. substr(SC5->C5_XRECOLH,1,3) $ "ACR"
				
				//-- e-mail
				EmailOper := Alltrim(Posicione("SU7",1,xFilial("SU7")+SC5->C5_OPERADO,"U7_EMAIL"))
				NomeCli   := Posicione("SA1",1,xFilial("SA1")+SC5->C5_CLIENTE+SC5->C5_LOJACLI,"A1_NREDUZ")
				cEmail    := Getmv("ES_DIPV4_6")+" ,"+EmailOper
				cAssunto  := EncodeUTF8("ESTORNO DA SEPARAวรO - Pedido com Icms-Interestadual - PV-" + SC5->C5_NUM,"cp1252")
				aadd(aMsg,{SC5->C5_NUM, EmailOper, SC5->C5_CLIENTE, SC5->C5_LOJACLI, NomeCli})
				EMail(cEmail,cAssunto,aMsg)
				
				//-- manda cic do pedido
				cMSGcIC       := " EMPRESA:_______" + Capital( AllTrim( GetAdvFVal( "SM0", "M0_NOME", cEmpAnt + cFilAnt, 1, "" ) ) ) +"/"+ Capital( AllTrim( GetAdvFVal( "SM0", "M0_FILIAL" , cEmpAnt + cFilAnt, 1, "" ) ) )   + CR + CR
				cMSGcIC       += "Pedido:   "+SC5->C5_NUM +CR
				//................1 2 3 4 5 6 7 8 9 0
				cMSGcIC       += "Operador:   "+EmailOper +CR
				//................1 2 3 4 5 6 7 8 9 0
				cMSGcIC       += "Cliente:   "+SC5->C5_CLIENTE+" - "+NomeCli +CR+CR
				//................1 2 3 4 5 6 7 8 9 0
				
				cMSGcIC       += "CANCELAMENTO: Estorno de Pedido com Icms-Interestadual" +CR
				//................1 2 3 4 5 6 7 8 9 0
				
				U_DiprKardex(SC5->C5_NUM,U_DipUsr(),"ESTORNO DA PRE-NOTA COM ICMS INTER-ESTADUAL",.t.,"57") // GIOVANI 29/08/2005
				
				//manda CIC
				If !("totvsrmt.ini" $ GetRemoteIniName()) // Nใo envia cic se o acesso for via RemoteActvex - MCVN 01/07/11
					M410CIC()
				EndIf
				
			EndIf
			
			/*====================================================================================\
			| ENVIO DO E-MAIL DE ESTORNO DE PEDIDO COM SUBST. TRIBUTมRIA INCLUอDA NA DESPESA      |
			\====================================================================================*/
			//MCVN - 25/05/2007
			If SubStr(SC5->C5_MENNOTA,AT('=',SC5->C5_MENNOTA),5) == "=ST=D"  .AND.  Val(Left(SC5->C5_MENNOTA,4)) > 0 /// VERIFICA SE SUBST. TRIBUTมRIA ESTม INCLUSO NO VALOR DA DESPESA - TRATANDO ST COM VALOR 0 - MCVN 12/11/09.
				EmailOper := Alltrim(Posicione("SU7",1,xFilial("SU7")+SC5->C5_OPERADO,"U7_EMAIL"))
				NomeCli   := Posicione("SA1",1,xFilial("SA1")+SC5->(C5_CLIENTE+C5_LOJACLI),"A1_NOME")
				cEmail    := "maximo@dipromed.com.br"
				cAssunto  := EncodeUTF8("ESTORNO DA SEPARAวรO - Substitui็ใo Tributแria - PV-" + SC5->C5_NUM,"cp1252")
				aadd(aMsg,{SC5->C5_NUM, EmailOper, SC5->C5_CLIENTE, SC5->C5_LOJACLI, NomeCli})
				EMail(cEmail,cAssunto,aMsg)
			Endif
			
			///////////////////////////////////////////
			///// FIM DA ROTINA DE ENVIO DE E-MAIL ////
			///////////////////////////////////////////
			
			//MCVN  18/01/2008
			/*====================================================================================\
			| ENVIO DO E-MAIL DE ESTORNO DE PEDIDO DE CLIENTE COM SUFRAMA                         |
			\====================================================================================*/
			
			// ENVIA EMAIL SE CLIENTE TIVER SUFRAMA (PIN-PROTOCOLO DE INTERNAวรO DE NOTA FISCAL)  17/01/2008
			cSuframa := Posicione('SA1', 1, xFilial('SA1') + SC5->C5_CLIENTE + SC5->C5_LOJACLI, 'A1_SUFRAMA')
			If  !Empty(cSuframa)
				aMsg := {}
				EmailOper := Alltrim(Posicione("SU7",1,xFilial("SU7")+SC5->C5_OPERADO,"U7_EMAIL"))
				NomeCli   := Posicione("SA1",1,xFilial("SA1")+SC5->(C5_CLIENTE+C5_LOJACLI),"A1_NOME")
				//			cEmail    := "magda@dipromed.com.br;william.pereira@dipromed.com.br"
				cEmail    := GetNewPar("ES_MAILSUF","magda.teixeira@dipromed.com.br;sirlene.creatto@dipromed.com.br;deoclecio.santos@dipromed.com.br")
				cAssunto  := EncodeUTF8("ESTORNO DA SEPARAวรO - Cliente com Suframa - PV-" + SC5->C5_NUM,"cp1252")
				aadd(aMsg,{SC5->C5_NUM, EmailOper, SC5->C5_CLIENTE, SC5->C5_LOJACLI, NomeCli})
				EMail(cEmail,cAssunto,aMsg)
			EndIf
			
		EndIf
		
		UnLockByName(cLockPV, .T., .T.)
		END TRANSACTION // Eriberto 22/03/2007
		
	EndIf //-- D'Leme - LockByName
EndIf

RestArea(aArea)

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณC5PRENOTA บAutor  ณFabio Rogerio       บ Data ณ  10/09/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRotina para retornar o conteudo do campo C5_PRENOTA         บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function C5PRENOTA()
Local cRet := ""
Local aArea:= GetArea()

cRet:= Posicione("SC5",1,xFilial("SC5")+C9_PEDIDO,"C5_PRENOTA")

RestArea(aArea)
Return(cRet)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDIPM015   บAutor  ณMicrosiga           บ Data ณ  10/09/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRotina para executar tela de separacao sem browse           บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function DIPM015(nTipo,cPedido)

Local aBoxParam    := {}
Local aRetParam    := {}   
Local aMVs         := {}  
Local cMV          := ""              
Local nI           :=  1  
Local lSep         := .T.
Local lRet	  	   := .T.
Local nPedSol	   :=  0
Local nPedSep	   :=  0  
Private cD10CodSep := ""

DEFAULT nTipo:= 2
                     
If lRet .And. nPedSol == nPedSep  // Verifica se o retorno ้ verdadeiro e se a quantidade de pedidos solicitados foi separado  
	Aadd(aBoxParam,{1,"Separador",Space(2),"@!","ExistCpo('SZC',MV_PAR01)","SZC","",2,.F.})
	
	If (nTipo == 1)
		Aadd(aBoxParam,{2,"Ignora Horario Transp.","2",{"1=Sim","2=Nao"},100,"",.F.})
		Aadd(aBoxParam,{1,"Quantidade de Pedido. ",SPACE(2),"99","Val(MV_PAR03) > 0","","",2,.T.})	
	EndIf
	
	If !ParamBox(aBoxParam,"Informe os Parametros",@aRetParam,,,,,,,,.F.)
		lRet := .F.
	EndIf          
	
EndIf

nPedSol    := Val(MV_PAR03)
cD10CodSep := MV_PAR01

While lRet .And. lSep .And. nPedSol > nPedSep
	LjMsgRun("Selecionando Pedidos...","Atencao",{||lSep:= U_DIPMSEP(nTipo,aBoxParam)})
	nPedSep++
End

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDIPMFILA  บAutor  ณMicrosiga           บ Data ณ  02/14/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Fila de Impressao de Pre-Nota                             บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function DIPMFILA()
Local cQuery 	  := ""
Local cPedido	  := ""
Local aFila  	  := {}
Local aSize       := {}
Local aInfo       := {}
Local aObjects    := {}
Local aPosObj     := {}
Local oDlg
Local oFila
Local cFila
Local aButtons  := {	{"CARGA"   ,{|| M010Pri(@aFila,@oFila)},"Altera Prioridade"},;
{"PENDENTE",{|| aFila:=M010Atual(),	;
oFila:SetArray(aFila),;
oFila:bLine := { || {;
aFila[oFila:nAT,2]	,;	
aFila[oFila:nAT,3]	,;
aFila[oFila:nAT,4]	,;
aFila[oFila:nAT,5]	,;
aFila[oFila:nAT,6]	,;
aFila[oFila:nAT,7]	,;
aFila[oFila:nAT,8]	,;
aFila[oFila:nAT,9]	,;
aFila[oFila:nAT,10]	,;
aFila[oFila:nAT,11]	,;
aFila[oFila:nAT,12] ,;
aFila[oFila:nAT,13] ,;
aFila[oFila:nAT,14] ,;
aFila[oFila:nAT,15] ,;
aFila[oFila:nAT,16] ,;
aFila[oFila:nAT,17] ,;
aFila[oFila:nAT,18] ,;
aFila[oFila:nAT,19] ,;
aFila[oFila:nAT,20] ,;
aFila[oFila:nAT,21] ,;
aFila[oFila:nAT,22] ,;
aFila[oFila:nAT,23] ,;
aFila[oFila:nAT,24] ,;
aFila[oFila:nAT,25]}},;
},"Refaz fila"}}

aFila := M010Atual()  // roda a query e atualiza o array

If (Len(aFila) > 0)
	aSize    := MsAdvSize(.F.)
	aInfo    := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ] , 1, 1 }
	
	aAdd( aObjects, { 100, 085, .T., .T., .T.} )
	aAdd( aObjects, { 100, 015, .T., .T., .T.} )
	aPosObj := MsObjSize( aInfo, aObjects , .T. )
	
	DEFINE MSDIALOG oDlg TITLE "Fila de Impressao" FROM aSize[7],0 TO aSize[6],aSize[5]-5  OF oMainWnd PIXEL
	
	@ aPosObj[1,1],aPosObj[1,2] LISTBOX oFila VAR cFila FIELDS ;
	HEADER ;  
	"Ordem",;   
	"Priori",;
	"Pedido",;
	"Itens",;
	"Transp.",;
	"Nome Transp.",;
	"Dt.Lib.Ope",;
	"Hr.Lib.Ope",;
	"Dt.Lib.Cre",;
	"Hr.Lib.Cre",;
	"Rec.Dif.ICM",; 
	"Mens.Dep๓sito",;
	"Obs.Cliente",;
	"Cliente",;
	"Loja",;
	"Nome",;
	"Mun. Entrega",;
	"Est. Entrega",;
	"Operador",;
	"Nome",;
	"Vendedor",;
	"Nome",;
	"At. Estoque",;
	"CEP Entrega";
	SIZE aPosObj[1,4],aPosObj[1,3] NOSCROLL OF oDlg PIXEL
	
	oFila:Align := CONTROL_ALIGN_ALLCLIENT
	oFila:SetArray(aFila)
	oFila:bLine := { || {;
	aFila[oFila:nAT,2]	,;
	aFila[oFila:nAT,3]	,;
	aFila[oFila:nAT,4]	,;
	aFila[oFila:nAT,5]	,;
	aFila[oFila:nAT,6]	,;
	aFila[oFila:nAT,7]	,;
	aFila[oFila:nAT,8]	,;
	aFila[oFila:nAT,9]	,;
	aFila[oFila:nAT,10]	,;
	aFila[oFila:nAT,11]	,;
	aFila[oFila:nAT,12]	,;
	aFila[oFila:nAT,13] ,;
	aFila[oFila:nAT,14] ,;
	aFila[oFila:nAT,15] ,;
	aFila[oFila:nAT,16] ,;
	aFila[oFila:nAT,17] ,;
	aFila[oFila:nAT,18] ,;
	aFila[oFila:nAT,19] ,;
	aFila[oFila:nAT,20] ,;
	aFila[oFila:nAT,21] ,;
	aFila[oFila:nAT,22] ,;
	aFila[oFila:nAT,23] ,;
	aFila[oFila:nAT,24] ,;
	aFila[oFila:nAT,25] }}
	
	ACTIVATE MSDIALOG oDlg CENTERED  ON INIT EnchoiceBar( oDlg,{ || oDlg:End() }, { || oDlg:End() },,aButtons)
	
Else
	Aviso("Atencao","Nao existem Pre-Notas na fila de impressao !!!",{"Ok"})
EndIf

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณM010PRI   บAutor  ณMicrosiga           บ Data ณ  02/23/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Rotina para altercao da prioridade de entrega              บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function M010PRI(aFila,oFila)
Local aBoxParam		:= {}
Local aRetParam		:= {}
Local aAux 			:= RetSx3Box(Posicione("SX3",2,"A4_PRIENTR","X3_CBOX"),,,14)
Local aBoxEnt		:= {}
Local cPriAtual		:= aFila[oFila:nAT,3]
Local cLockPV		:= ""
Local l

aEval(aAux,{|x| aAdd(aBoxEnt,x[1]) })

Aadd(aBoxParam,{2,"Prioridade Entrega",cPriAtual,aBoxEnt,100,"",.F.})

If ParamBox(aBoxParam,"Informe os Parametros",@aRetParam,,,,,,,,.F.)
	If (Aviso("Atencao","Confirma a Alteracao da Prioridade de Entrega ?",{"Sim","Nao"}) == 1)
		aRetParam[1]:= IIF(Valtype(aRetParam[1]) == "C",aRetParam[1],StrZero(aRetParam[1],1))
		aFila[oFila:nAT,3]:= aRetParam[1]
		
		//-- Tramamento de Trava por PV - Daniel Leme 28/07/2011
		cLockPV := "SEPARA_" + aFila[oFila:nAT,4]
		If !LockByName(cLockPV, .T., .T.)
			MsgAlert("O Pedido de venda: " + aFila[oFila:nAT,4] + " estแ bloqueado em separa็ใo por outra esta็ใo!","Aten็ใo")
		Else
			dbSelectArea("SC9")
			dbSetOrder(1)
			dbSeek(xFilial("SC9")+aFila[oFila:nAT,4],.T.)
			
			While !Eof() .And. (xFilial("SC9")+aFila[oFila:nAT,4] == SC9->(C9_FILIAL+C9_PEDIDO))
				If Empty(SC9->C9_NFISCAL)
					RecLock("SC9",.F.)
					Replace C9_PRIENTR With aRetParam[1]
					SC9->(MsUnLock())
				EndIf
				
				dbSkip()
			End
			
			U_DiprKardex(aFila[oFila:nAT,4],U_DipUsr(),"Prioridade Entrega "+aRetParam[1],.T.,"33")
			
			aFila:= aSort(aFila,,,{|x,y| x[3] < y[3]})
			ee := Len(aFila)
			For l := 1 to Len(afila)
				aFila[l,2] := Str(l,3,0)
				aFila[l,1] := Str(ee,3,0)
				ee--
			Next
			oFila:Refresh()
			UnLockByName( cLockPv, .T., .T. )
		EndIf
	EndIf
EndIf

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณM010Ped   บAutor  ณDaniel Leme         บ Data ณ  08/09/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Retorna array com os pedidos para separa็ใo, ordenando-os  บฑฑ
ฑฑบ          ณ por prioridade de entrega.                                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ DIPM010 - Dipromed                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function M010Ped()
Local aArea		:= GetArea()
Local aPed		:= {}
Local aPedAux	:= {}
Local cQuery	:= ""
Local cAlias	:= GetNextAlias()
Local nI

//-- Traz apenas o pedido, para evitar o BookMark Lookup no Banco de Dados - Verificar performance antes de mexer!!!
cQuery   := " SELECT"
cQuery   += "     DISTINCT C9_PEDIDO"  //-- Nao alterar a clausula "select" sem verificar performance. Utilize a query de ordena็ใo para implementa็๕es
cQuery   += " FROM " + RetSqlName("SC9") +" SC9    "
cQuery   += " JOIN " + RetSqlName("SC5") +" SC5 ON "
cQuery   += "     SC5.C5_FILIAL       = '"+xFilial("SC5")+"' "
cQuery   += "     AND SC5.D_E_L_E_T_  = ' ' "
cQuery   += "     AND SC5.C5_PARCIAL <> 'N' "
cQuery   += "     AND SC5.C5_NUM      = SC9.C9_PEDIDO "
cQuery   += "     AND SC5.C5_PRENOTA  = ' ' "
cQuery   += "     AND SC5.C5_HORALIB  > ' ' "
If cEmpAnt=="04" .And. Upper(u_DipUsr())$GetNewPar("ES_HQSEPRO","BPARISE/FCOUTINHO")
	cQuery   += " AND SC5.C5_CLIENTE IN('"+StrTran(GetNewPar("ES_HQCLPRO","110087/019433"),"/","','")+"') "
EndIf
cQuery   += " WHERE"
cQuery   += " 	  SC9.D_E_L_E_T_     = ' ' "
cQuery   += " 	  AND SC9.C9_FILIAL  = '"+xFilial("SC9")+"' "
cQuery   += " 	  AND SC9.C9_BLCRED  = ' ' "
cQuery   += " 	  AND SC9.C9_BLEST   = '02' "
cQuery   += " 	  AND SC9.C9_SALDO   = 0 "
cQuery   += " 	  AND SC9.C9_NFISCAL = ' ' "
DbCommitAll()
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.T.,.T.)

(cAlias)->(DbEval({|| aAdd(aPed,C9_PEDIDO)  } ))
(cAlias)->(DbCloseArea())

//-- Ordena array de pedidos
If Len(aPed) > 1
	//-- Obtem a prioridade de entrega do pedido
	For nI := 1 To Len(aPed)
		cQuery   := " SELECT TOP 1 C9_PRIENTR "
		cQuery   += " FROM " + RetSqlName("SC9") +" SC9    "
		cQuery   += " WHERE"
		cQuery   += " 	  SC9.D_E_L_E_T_     = ' ' "
		cQuery   += " 	  AND SC9.C9_FILIAL  = '"+xFilial("SC9")+"' "
		cQuery   += " 	  AND SC9.C9_PEDIDO  = '"+aPed[nI]+"'"
		DbCommitAll()
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.T.,.T.)
		
		aAdd(aPedAux,{aPed[nI],(cAlias)->C9_PRIENTR})
		(cAlias)->(DbCloseArea())
	Next nI
	
	//-- Ordena o Array Auxiliar por Prioridade de Entrega + Pedido
	aPedAux := aSort(aPedAux,,,{|x,y| x[2]+x[1] < y[2]+y[1] })
	
	//-- Refaz o Array de Retorno, com a ordem selecionada
	aPed := {}
	aEval(aPedAux,{ |x| aAdd( aPed, x[1] ) })
	
EndIf
RestArea(aArea)

Return aPed
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณM010mostra บAutor  ณ Eriberto Elias    บ Data ณ  16/03/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Mostra Fila de Impressao de Pre-Nota                       บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบHist๓rico ณ 													          นฑฑ
ฑฑบMaximo    ณ 05/11/2009 Incluindo Municํpio e Estado de entrega         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function M010Atual()
Local cQuery   	:= ""
Local cQueryPv 	:= ""
Local aFila    	:= {}
Local eeX       
Local aPed		:= M010Ped() //-- retorna os pedidos jแ Ordenados
Local nI        := 0                  
Local aRetSZ9	:= {}
Local lAtuEst	:= .F.
Local cRecolh   := ""

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณVerifica os pedidos que devem ser separados.ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
cQuery:= "SELECT TOP 1 C9_PRIENTR, C9_PEDIDO, C9_ITEM, C5_TRANSP, A4_NOME, C5_CLIENTE, C5_LOJACLI, A1_NOME, C5_OPERADO, U7_NOME, C5_VEND1, A3_NOME, C5_MUNE, "
cQuery+= "C5_HORA, C5_MENDEP, C5_ESTE, C5_CEPE, C5_XRECOLH, "// MCVN 05/11/2009 Incluindo Municํpio e Estado de entrega
cQuery+= "   (select count(*)"
cQuery+= "    from " + RetSqlName("SC9") + " SC9C "
cQuery+= "       inner join " + RetSqlName("SC5") + " SC5C"
cQuery+= "          on SC5C.D_E_L_E_T_ <> '*'"
cQuery+= "    where SC9C.D_E_L_E_T_ <> '*'"
cQuery+= "       and SC9.C9_FILIAL = SC9C.C9_FILIAL"
cQuery+= "       and SC9.C9_PEDIDO = SC9C.C9_PEDIDO"
cQuery+= "       and SC9C.C9_FILIAL = SC5C.C5_FILIAL"
cQuery+= "       and SC9C.C9_PEDIDO = SC5C.C5_NUM"
cQuery+= "       and SC9C.C9_BLCRED = ' '"
cQuery+= "       and SC9C.C9_BLEST = '02'"
cQuery+= "       and SC9C.C9_SALDO = 0"
cQuery+= "       and SC9C.C9_NFISCAL = ' '"
cQuery+= "       and SC5C.C5_PARCIAL <> 'N'"
cQuery+= "       and SC5C.C5_PRENOTA = ' '"
cQuery+= "   ) ITENS"
cQuery+= " FROM " + RetSqlName("SC9") + " SC9 "
cQuery+= "    INNER JOIN " + RetSqlName("SC5") + " SC5" 
cQuery+= "       ON SC5.D_E_L_E_T_ <> '*' "
cQuery+= "       AND SC9.C9_FILIAL = SC5.C5_FILIAL "
cQuery+= "       AND SC9.C9_PEDIDO = SC5.C5_NUM "
cQuery+= "       AND SC5.C5_PARCIAL <> 'N'"
cQuery+= "       AND SC5.C5_PRENOTA = ''"
cQuery+= "    INNER JOIN " + RetSqlName("SA4") + " SA4" 
cQuery+= "       ON SA4.D_E_L_E_T_ <> '*' "
cQuery+= "       AND SC5.C5_TRANSP  = SA4.A4_COD"
cQuery+= "    LEFT JOIN " + RetSqlName("SA1") + " SA1" 
cQuery+= "       ON SA1.D_E_L_E_T_ <> '*' "
cQuery+= "       AND SC5.C5_CLIENTE = SA1.A1_COD"
cQuery+= "       AND SC5.C5_LOJACLI = SA1.A1_LOJA"
cQuery+= "    INNER JOIN " + RetSqlName("SU7") + " SU7" 
cQuery+= "       ON SU7.D_E_L_E_T_ <> '*' "
cQuery+= "       AND SC5.C5_OPERADO= SU7.U7_COD"
cQuery+= "    INNER JOIN " + RetSqlName("SA3") + " SA3"
cQuery+= "       ON SA3.D_E_L_E_T_ <> '*' "
cQuery+= "       AND SC5.C5_VEND1  = SA3.A3_COD"
cQuery+= " WHERE SC9.D_E_L_E_T_ <> '*'"
cQuery+= "    AND SC9.C9_BLCRED   = ''"
cQuery+= "    AND SC9.C9_BLEST    = '02'"
cQuery+= "    AND SC9.C9_SALDO    = 0"
cQuery+= "    AND SC9.C9_NFISCAL  = ''"
cQuery+= "    AND SC9.C9_FILIAL   = '" + xFilial("SC9") + "'"

For nI := 1 To Len(aPed)
	cQueryPv := cQuery
	cQueryPv += " AND SC9.C9_PEDIDO = '"+aPed[nI]+"'"
	
	cQueryPv := ChangeQuery(cQueryPv)
	
	DbCommitAll()
	If Select("QRYGI") > 0 //Giovani Zago 09/09/11
		DbSelectArea("QRYGI")//Giovani Zago 09/09/11
		dbCloseArea("QRYGI")//Giovani Zago 09/09/11
	EndIf//Giovani Zago 09/09/11
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQueryPv),"QRYGI",.T.,.T.)//Giovani Zago 09/09/11
	memowrite('DIPM010FILA.SQL',cQueryPv)        
	
	If QRYGI->(!Eof())//Giovani Zago 09/09/11

	    cRecolh := ""

	    aRetSZ9 := HoraLibPV(QRYGI->C9_PEDIDO)          
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ Retorno aRetSZ9     ณ
		//ณ  01 - cDtLib        ณ		
		//ณ  02 - cHrLib        ณ
		//ณ  03 - cDtLibCred    ณ
		//ณ  04 - cHrLibCred    ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

		lAtuEst := U_DipAtuEst(QRYGI->C9_PEDIDO)
	
		If (substr(QRYGI->C5_XRECOLH,1,3)) $ "ACR/GUI"		   
			cRecolh:="Pedido com Prioridade de Liberacao!"	
 		EndIf
          
		//MCVN - 05/11/2009 Incluindo Municํpio e Estado de entrega//Giovani Zago 09/09/11	
		aAdd(aFila,{"",;						//01
					Str(Len(aFila)+1,3,0),;		//02
					QRYGI->C9_PRIENTR,;			//03
					QRYGI->C9_PEDIDO,;			//04
					QRYGI->Itens,;				//05
					QRYGI->C5_TRANSP,;			//06
					AllTrim(QRYGI->A4_NOME),;	//07					
					aRetSZ9[1],;       			//08
					aRetSZ9[2],;       			//09
					aRetSZ9[3],;       			//10
					aRetSZ9[4],;       			//11
					cRecolh,;                	//12 RBORGES  24/05/2013					
					QRYGI->C5_MENDEP,;			//13                                      
					POSICIONE("SA1",1,xFilial("SA1")+QRYGI->C5_CLIENTE,"A1_OBSPRE"),;//14
					QRYGI->C5_CLIENTE,;			//15
					QRYGI->C5_LOJACLI,;			//16
					QRYGI->A1_NOME,;			//17
					QRYGI->C5_MUNE,;			//18
					QRYGI->C5_ESTE,;			//19
					QRYGI->C5_OPERADO,;			//20
					QRYGI->U7_NOME,;			//21
					QRYGI->C5_VEND1,;			//22
					QRYGI->A3_NOME,;			//23
					IIf(lAtuEst,"Sim","Nao"),; 	//24
					Left(AllTrim(QRYGI->C5_CEPE),5)+"-"+Right(AllTrim(QRYGI->C5_CEPE),3);           	//25
					})					
	EndIf
	QRYGI->(dbCloseArea())//Giovani Zago 09/09/11
Next nI

ee := Len(aFila)
For eeX:=1 To Len(aFila)
	aFila[eeX,1] := Str(ee,3,0)
	ee--
Next
 
	If Select("QRYGI") > 0 //Giovani Zago 09/09/11
		DbSelectArea("QRYGI")
		dbCloseArea("QRYGI")
	EndIf
Return(aFila)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDIPM010   บAutor  ณMicrosiga           บ Data ณ  07/11/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ  MCVN 23/03/2007 - Pr้-nota estornado                      บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function DipmEstCIC(cPedido)

Local lRetorno := .T.
Local cFilSC9  := xFilial("SC9")
Local cMail
Local cServidor   := GetMV("MV_CIC")     // Servidor para enviar mensagem pelo CIC
Local cOpFatRem   := GetMV("MV_REMETCI") // Usuario do CIC remetente de mensgens no Protheus
Local cOpFatSenha := "123456"
Local cOpFatDest  := ""
Local cGetMotivo  := Space(90)
Local nOpcao      := 0
Local lSaida := .f.

If Upper(U_DipUsr()) = 'ERIBERTO/EELIAS'
	cGetMotivo := "Eriberto - testando melhorias no Protheus."+space(44)
EndIf

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

Do While !lSaida
	nOpcao := 0
	
	Define msDialog oDlg Title "Estornando pr้-nota" From 10,10 TO 23,60
	
	@ 001,002 tO 78,196
	
	@ 010,010 say "Pedido  " COLOR CLR_BLACK
	@ 020,010 say "Cliente " COLOR CLR_BLACK
	@ 030,010 say "Operador" COLOR CLR_BLACK
	
	@ 010,050 get M->C9_PEDIDO  when .f. size 050,08
	@ 020,050 get M->A1_CLIENTE when .f. size 120,08
	@ 030,050 get M->U7_OPERADO when .f. size 120,08
	
	@ 050,010 say "Descreva o motivo do estorno: "  COLOR CLR_HBLUE
	@ 060,010 get cGetMotivo valid !empty(cGetMotivo) size 165,08
	
	DEFINE SBUTTON FROM 82,130 TYPE 1 ACTION IF(!empty(cGetMotivo),(lSaida:=.T.,nOpcao:=1,oDlg:End()),msgInfo("Motivo do estorno nใo preenchido","Aten็ใo")) ENABLE OF oDlg
	//	DEFINE SBUTTON FROM 82,160 TYPE 2 ACTION (nOpcao:=0,oDlg:End()) ENABLE OF oDlg
	
	Activate dialog oDlg centered
	
EndDo

If nOpcao == 1
	
	// Monta a mensagem a ser enviado ao operador
	cMail := "AVISO IMPORTANTE"+CR+CR
	cMail += "O Pedido " +M->C9_PEDIDO
	cMail += " do Cliente "+AllTrim(SA1->A1_COD)+" - "+AllTrim(SA1->A1_NREDUZ)+CR
	cMail += "Pr้-nota estornada. Seus produtos continuam reservados."+CR+CR
	cMail += "Motivo: "+cGetMotivo +CR+CR
	cMail += U_DipUsr()
	
	// Envia a mensagem ao operador atrav้s do CIC
	U_DIPCIC(cMail,AllTrim(cOpFatDest))// RBorges 12/03/15
//	WaitRun(cServidor+' '+cOpFatRem+' '+cOpFatSenha+' "'+AllTrim(cOpFatDest)+'" "'+cMail+'" ') // Comentada 12/03/15
EndIf
Return(lRetorno)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDIPM010   บAutor  ณMicrosiga           บ Data ณ  07/11/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ  MCVN 23/03/2007 - Separacao			                     บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function DipmSepCIC(cPedido,lIniciou,aProblema)
Local lRetorno := .F.
Local cFilSC9  := xFilial("SC9")
Local cMail
Local cServidor   := GetMV("MV_CIC")     // Servidor para enviar mensagem pelo CIC
Local cOpFatRem   := GetMV("MV_REMETCI") // Usuario do CIC remetente de mensgens no Protheus
Local cOpFatSenha := "123456"
Local cOpFatDest  := ""
Local cGetMotivo  := Space(90)
Local nOpcao      := 0
Local lSaida      := .f.
Local ni

Default lIniciou  := .T.

cOpFatDest := GetNewPar("ES_ERROSEP","MAXIMO.CANUTO,EXPEDICAOCD,LOURIVAL.NUNES,DIEGO.DOMINGOS")

SA1->(dbSetOrder(1))
SA1->(dbSeek(xFilial("SA1") + SC9->C9_CLIENTE + SC9->C9_LOJA))
cObsFin := ""


If !lIniciou .and. Len(aProblema) > 0
	// Monta a mensagem a ser enviado ao operador
	cMail := "AVISO IMPORTANTE - ERRO DE SEPARAวรO"+CR+CR
	cMail += "O Pedido " +cPedido
	cMail += " do Cliente "+AllTrim(SA1->A1_COD)+" - "+AllTrim(SA1->A1_NREDUZ)+CR
	cMail += "FOI SEPARADO COM ERROS !"+CR+CR
	cMail += "Environment:"+GetEnvServer()+CR+CR
	For ni := 1 to Len(aProblema)
		If Len(aProblema[nI]) > 3
			cMail += aProblema[ni,1]+" - "+aProblema[ni,2]+" - "+ aProblema[ni,3] +" - "+ aProblema[ni,4]+CR
		Else
			cMail += aProblema[ni,1]+" - "+aProblema[ni,2]+" - "+ aProblema[ni,3] +CR
		EndIf
	Next ni
	cMail += CR+U_DipUsr()
	
	// Envia a mensagem ao operador atrav้s do CIC
	U_DIPCIC(cMail,AllTrim(cOpFatDest))// RBorges 12/03/15
//	WaitRun(cServidor+' '+cOpFatRem+' '+cOpFatSenha+' "'+AllTrim(cOpFatDest)+'" "'+cMail+'" ') // RBorges 12/03/15
Endif

Return(lRetorno)
/*==========================================================================\
|Programa  |EMail   | Autor | Rafael de Campos Falco  | Data ณ 13/01/2005   |
|===========================================================================|
|Desc.     | Envio de EMail                                                 |
|===========================================================================|
|Sintaxe   | EMail                                                          |
|===========================================================================|
|Uso       | Especifico DIPROMED                                            |
\==========================================================================*/
Static Function EMail(cEmail,cAssunto,aMsg,aAttach)

Local cAccount  := Lower(Alltrim(GetMv("MV_RELACNT")))
Local cFrom     := Lower(Alltrim(GetMv("MV_RELACNT")))
Local cPassword := Alltrim(GetMv("MV_RELPSW"))
Local cServer   := Alltrim(GetMv("MV_RELSERV"))
Local cEmailTo  := ""
Local cEmailCc  := Lower(aMsg[1,2])
Local cEmailBcc := ""
Local lResult   := .F.
Local cError    := ""
Local cMsg      := ""     
LOCAL lSmtpAuth := GetNewPar("MV_RELAUTH",.F.)
LOCAL lAutOk	:= .F.

/*=============================================================================*/
/*Definicao do cabecalho do email                                              */
/*=============================================================================*/
cMsg := ""
cMsg += '<html>'
cMsg += '<head>'
cMsg += '<title>' + cAssunto + '</title>'
cMsg += '</head>'
cMsg += '<body>'
cMsg += '<HR Width=85% Size=3 Align=Centered Color=Red> <P>'
cMsg += '<Table Align=Center BorderColor=#000000 CELLPADDING=4 CELLSPACING=0 Width=60%>'

/*=============================================================================*/
/*Definicao do cabecalho do relat๓rio                                          */
/*=============================================================================*/
cMsg += '<table width="100%">'
cMsg += '<tr>'
cMsg += '<td>===============================================================================================================</td>'
cMsg += '</tr>'
cMsg += '</table>'

cMsg += '<table width="100%">'
cMsg += '<tr>'
cMsg += '<td width="100%"><font size="4" color="red">Pedido - ' + aMsg[1,1] + '</font></td>'
cMsg += '</tr>'
cMsg += '<tr>'
cMsg += '<td width="100%"><font size="2" color="blue">Cliente: ' + aMsg[1,3] + '-' + aMsg[1,4] + '-' + aMsg[1,5] + '</font></td>'
cMsg += '</tr>'
cMsg += '<tr>'
cMsg += '<td width="80%" align="center"><font size="4" color="RED">ATENวรO A SEPARAวรO DO PEDIDO FOI ESTORNADA !</font></td>'
cMsg += '</tr>'
cMsg += '</table>'

cMsg += '<table width="100%">'
cMsg += '<tr>'
cMsg += '<td>===============================================================================================================</td>'
cMsg += '</tr>'
cMsg += '</table>'

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Definicao do rodape do email                                                ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
cMsg += '</Table>'
cMsg += '<HR Width=85% Size=3 Align=Centered Color=Red> <P>'
cMsg += '<table width="100%" Align="Center" border="0">'
cMsg += '<tr align="center">'
cMsg += '<td colspan="10"><font color="BLUE" size="2">Mensagem enviada automaticamente pelo sistema PROTHEUS - <font color="BLUE" size="1">(DIPM010.PRW)</td>'
cMsg += '</tr>'
cMsg += '</table>'
cMsg += '</body>'
cMsg += '</html>'

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณEnvia o mail para a lista selecionada. Envia como BCC para que a pessoa penseณ
//ณque somente ela recebeu aquele email, tornando o email mais personalizado.   ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
IF At(";",cEmail) > 0
	cEmailTo := SubStr(cEmail,1,At(";",cEmail)-1)
	cEmailCc := SubStr(cEmail,At(";",cEmail)+1,Len(cEmail))
Else
	cEmailTo := Alltrim(cEmail)
EndIF

CONNECT SMTP SERVER cServer ACCOUNT cAccount PASSWORD cPassword RESULT lResult

If !lAutOk
	If ( lSmtpAuth )
		lAutOk := MailAuth(cAccount,cPassword)
	Else
		lAutOk := .T.
	EndIf
EndIf

If lResult .And. lAutOk
	SEND MAIL FROM cFrom ;
	TO      	Lower(cEmailTo);
	CC      	Lower(cEmailCc);
	BCC     	Lower(cEmailBcc);
	SUBJECT 	cAssunto;
	BODY    	cMsg;
	RESULT lResult
	
	If !lResult
		//Erro no envio do email
		GET MAIL ERROR cError
		
		MsgInfo(cError,OemToAnsi("Aten็ใo"))
	EndIf
	
	DISCONNECT SMTP SERVER
Else
	//Erro na conexao com o SMTP Server
	GET MAIL ERROR cError
	MsgInfo(cError,OemToAnsi("Aten็ใo"))
EndIf

Return(.T.)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑณFuncao    ณ TRANSFAUTO  ณ Autor ณ Rodrigo Franco     ณ Data ณ 14.02.2002  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescricao ณ Relatorio de Libera็ใo de Senha                            ณฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function TRANSFAUTO(cNumSep, lSepara,lDireto, cPedido)
LOCAL wnrel
LOCAL tamanho:="P"
LOCAL titulo:="Relatorio transfer๊ncia Automแtica"
LOCAL cDesc1:="Relatorio transfer๊ncia Automแtica,de acordo com"
LOCAL cDesc2:="intervalo informado na opcao do Parametros."
LOCAL cDesc3:=" "
LOCAL nRegistro:= 0
LOCAL cKey,nIndex,cIndex  //&& Variaveis para a criacao de Indices Temp.
LOCAL cCondicao
Local aBoxParam:= {}
Local aRetParam:= {}
Local lRet:= .T. 
PRIVATE aReturn  := { "Zebrado", 1,"Administracao", 2, 2, 1, "",0 }
PRIVATE nomeprog := "TRANSFAUTO",nLastKey := 0,nBegin:=0,aLinha:={ }
PRIVATE li:=90,limite:=220,lRodape:=.F.,cPictQtd:=""
PRIVATE nTotQtd:=nTotVal:=0
PRIVATE aPedCli:= {}
Private PG := 0
Private lTransfAut := GetNewPar("ES_TRANSFE",.T.)
Default cNumSep := ""
Default lSepara := .F.
Default lDireto := .F.
Default cPedido := ""

wnrel    := "TRANSFAUTO"
cString  := "SD3"
PRIVATE nNItem := 0
U_DIPPROC(ProcName(0),U_DipUsr()) // JBS 05/10/2005 - Gravando o nome do Programa no SZU
//ณ Verifica as perguntas selecionadas                          ณ

If !lSepara
	Aadd(aBoxParam,{1,"NUM DE TRANSF." ,Space(6) ,"@!","","","",6,.F.})
	
	If !ParamBox(aBoxParam,"Informe os Parametros",@aRetParam,,,,,,,,.F.)
		lRet:= .F.
		Return(lRet)
	EndIf
	
	cNumSep := MV_PAR01
Endif

//ณ Variaveis utilizadas para parametros		                ณ
//ณ mv_par01	     	  Da Data			                    ณ
//ณ mv_par02	     	  Ate a Data			                ณ

If !lSepara  .Or.  !lDireto
	wnrel:=SetPrint(cString,wnrel,,@Titulo,cDesc1,cDesc2,cDesc3,.F.,,,Tamanho)
	If nLastKey==27
		Set Filter to
		Return( NIL )
	Endif
	SetDefault(aReturn,cString)
	If nLastKey==27
		Set Filter to
		Return( NIL )
	Endif
Else
	
	If lTransfAut //Se for .T., nใo imprimir o relatorio de transferencia automatica - RBORGES 28/01/2015
   		// Imprime via Spool direto na impressora padrใo sem a intera็ใo do usuแrio
		wnrel := SetPrint(cString,wnrel,,@Titulo,cDesc1,cDesc2,cDesc3,.F.,,,Tamanho,,.F.,,"DEFAULT.DRV",.T.,.F.,)
	
		aReturn[5] := 2
	
		If nLastKey == 27
			Return
		Endif
	
		SetDefault(aReturn,cString)
	EndIf
	If nLastKey == 27
		Return
	Endif
Endif
RptStatus({|lEnd| RODATRANSF(@lEnd,wnRel,cString, cNumSep, cPedido)},Titulo)
Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑณFun…o    ณ DIPR02I  ณ Autor ณ Maximo Canuto       ณ Data ณ 03/10/2007 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ TRANSFERสNCIA AUTOMATICA                                   ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ Dipromed                                                   ณฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function RODATRANSF(lEnd,WnRel,cString,cNumSep,cPedido)

//ณ Define Variaveis                                             ณ
LOCAL tamanho:= "P"
LOCAL titulo:="Relatorio Transferencia automatica"
LOCAL cDesc1:="Relatorio de transferencia automatica"
LOCAL cDesc2:="."
LOCAL cDesc3:=" "
LOCAL nRegistro:= 0
LOCAL cKey,nIndex,cIndex  && Variaveis para a criacao de Indices Temp.
LOCAL cCondicao
LOCAL aMsg1 := {}
LOCAL aMsg  := {}

QRY1 :=        "SELECT D3_TM, D3_COD, D3_QUANT, D3_LOCALIZ, D3_LOTECTL, D3_NUMSEP, D3_DOC, D3_EMISSAO"
QRY1 := QRY1 + " FROM " + RetSQLName("SD3")
QRY1 := QRY1 + " WHERE "
QRY1 := QRY1 + RetSQLName('SD3')+".D3_FILIAL = '"+xFilial('SD3')+"' and "
QRY1 := QRY1 + RetSQLName('SD3')+".D_E_L_E_T_ <> '*' and "
QRY1 := QRY1 + RetSQLName('SD3')+".D3_ESTORNO =  '' AND "
QRY1 := QRY1 + RetSQLName('SD3')+".D3_NUMSEP = '"+cNumSep+"' "
QRY1 := QRY1 + "order BY D3_COD, D3_NUMSEQ, D3_TM"

#xcommand TCQUERY <sql_expr>                          ;
[ALIAS <a>]                                           ;
[<new: NEW>]                                          ;
[SERVER <(server)>]                                   ;
[ENVIRONMENT <(environment)>]                         ;
=> dbUseArea(                                         ;
<.new.>,                                              ;
"TOPCONN",                                            ;
TCGENQRY(<(server)>,<(environment)>,<sql_expr>),      ;
<(a)>, .F., .T.)

// Processa Query SQL
DbCommitAll()
TcQuery QRY1 NEW ALIAS "QRY1"         // Abre uma workarea com o resultad

@ 0,0 psay AvalImp(Limite)
DbSelectArea("QRY1")

cNum := cPedido
While !Eof()
	cProduto  := QRY1->D3_COD
	cDocumento:= QRY1->D3_DOC
	cEmissao  := QRY1->D3_EMISSAO
	cNSepara  := QRY1->D3_NUMSEP
	cDestino  := QRY1->D3_LOCALIZ
	nQuantdes := QRY1->D3_QUANT
	dbSKIP()
	cProduto := QRY1->D3_COD
	cOrigem := QRY1->D3_LOCALIZ
	cLotectl := QRY1->D3_LOTECTL
	nQuant:= QRY1->D3_QUANT
	ImpCabec()                   
 	aadd(aMsg1,{cNum,cNSepara,cEmissao,cProduto,cOrigem,cDestino,cLotectl,nQuant,cDocumento})
			//	 1	    2        3         4      5         6       7        8       9

	DBSELECTAREA("QRY1")
	DBSKIP()
Enddo

   If Len(aMsg1) > 0 // SE NรO POSSUIR NENHUMA LINHA NO ARRAY NรO ENVIA NADA  -  RBORGES 06/11/14
    	cEmail := GetNewPar("ES_EMTRAT","reginaldo.borges@dipromed.com.br")   //Usuแrios que receberใo e-mails - RBORGES 06/11/14
		cAssunto:= EncodeUTF8('TRANSFERสNCIA AUTOMมTICA ENTRE ENDEREวOS - PEDIDO: ' + cNum +" - "+AllTrim(SM0->M0_NOME)+"/"+AllTrim(SM0->M0_FILIAL),"cp1252")
	    U_EMailTa(cEmail,cAssunto,aMsg1) //RBORGES 06/11/14 - Dispara E-mail das transferencias automaticas 
    	AVCicTA() //RBORGES 06/11/14 - Disparar CIC das transferencias automaticas       
   EndIf 

dbSelectArea("QRY1")
QRY1->(dbCloseArea())
If lTransfAut //Se for .T., nใo imprimir o relatorio de transferencia automatica - RBORGES 28/01/2015
	If aReturn[5] = 1
		Set Printer To
		dbCommitAll()
		OurSpool(wnrel)
	Endif
	MS_FLUSH()
EndIf

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑณFun…o    ณ ImpCabec ณ Autor ณ Maximo Canuto       ณ Data ณ 03/10/2007 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤ  ฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ Relatorio de Libera็ใo de Senha                            ณฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ImpCabec()

IF li > 60
	li := 0
	
	@ li,000 psay CHR(18)
	li++
	@ li,000 psay Replicate("-",80)
	li++
	@ li,024 psay "DIPROMED COMERCIO E IMPORTACAO LTDA."
	li++
	@ li,000 psay Replicate("-",80)
	li++
	@ li,015 psay "*** Relatorio transfer๊ncia automแtica*** "
	li++
	@ li,000 psay Replicate("-",80)
	li++
	@ li,000 psay "Pedido: "+cNum+"   Num. Transf:  "+cNSepara + "    Emissใo: "+ SubStr(cEmissao,7,2) + '/' + SubStr(cEmissao,5,2) + '/' + SubStr(cEmissao,1,4)
	li++
	@ li,000 psay Replicate("-",80)
	li := li + 1
	@ li,000 psay Replicate("-",80)
	li++
	@ li,000 psay "PRODUTO | ORIGEM    | DESTINO   | LOTE          | QUANT        | DOCUMENTO"
	li++
	@ li,000 psay Replicate("-",80)
	li++
Endif
li++
@ li,000 psay Alltrim(cProduto )+ "    " +Alltrim(cOrigem) + "   " +Alltrim(cDestino)+ "     "+Alltrim(cLoteCTL) //+ "  " +Str(nQuant)
@ li,045 Psay nQuant Picture "@E 999,999,999"
//@ li,048 Psay nQuant Picture "@E 99,999,999,999"
@ li,065 Psay cDocumento
li++
@ li,000 psay Replicate("-",80)

Pg := Pg + 1
Return   



/*------------------------------------------------------------------------+
+ Funcao:AVCicTA()    |  Autor: RBORGES     |      Data: 04/11/14         +                                                     
+ Farแ tratamento para enviar CIC de aviso de todas as transfer๊ncias     +
+ automแtica para o operador do armazenamento.		                      +
-------------------------------------------------------------------------*/

*--------------------------------------------------------------------------*
Static Function AVCicTA()
*--------------------------------------------------------------------------*
	
	Local aArea       := GetArea()
	Local cDeIc       := Lower(Alltrim(GetMv("MV_RELACNT")))
    Local cCICDest    := Upper(GetNewPar("ES_CIC_TA","REGINALDO.BORGES")) // Usuแrios que receberใo CICดs
	Local cAttachIc   :=  "  a"
	Local cFuncSentIc :=   "DIPM010.PRW "
 	
		dbSelectArea("SM0")
		
	_aMsgIc := {}
	cMSGcIC       := " EMPRESA:__ " + Capital( AllTrim( GetAdvFVal( "SM0", "M0_NOME", cEmpAnt + cFilAnt, 1, "" ) ) ) +"/"+ Capital( AllTrim( GetAdvFVal( "SM0", "M0_FILIAL" , cEmpAnt + cFilAnt, 1, "" ) ) )   +CHR(13)+CHR(10)+CHR(13)+CHR(10)
    cMSGcIC       += "TRANSFERENCIA AUTOMATICA ENTRE ENDEREวOS - VERIFICAR E-MAIL!"	+CHR(13)+CHR(10)+CHR(13)+CHR(10)
    cMSGcIC       += " PEDIDO:______  "+ cNum +" - "+" EMISSAO: "+SubStr(cEmissao,7,2) + '/' + SubStr(cEmissao,5,2) + '/' + SubStr(cEmissao,1,4) +CHR(13)+CHR(10)+CHR(13)+CHR(10)
	cMSGcIC       += " DOCUMENTO:_ " +cDocumento +" - "+ " NUM. TRANSF.: " +cNSepara 
                      
  	
   	U_DIPCIC(cMSGcIC,cCICDest)
   	  	
	
    RestArea(aArea)	
return() 


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDIPM010   บAutor  ณMicrosiga           บ Data ณ  07/11/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function M410CIC()

Local cServidor   := GetMV("MV_CIC")     // Servidor para enviar mensagem pelo CIC
Local cOpFatRem   := GetMV("MV_REMETCI") // Usuario do CIC remetente de mensgens no Protheus
Local cOpFatSenha := "123456"
Local cOpFatDest  := GetMV("ES_DIPV4_7")
Local cGetMotivo  := Space(90)

U_DIPCIC(cMSGcIC,AllTrim(cOpFatDest))// RBorges 12/03/15
//WaitRun(cServidor+' '+cOpFatRem+' '+cOpFatSenha+' "'+AllTrim(cOpFatDest)+'" "'+cMSGcIC+'" ') // Comentada 12/03/15
cMSGcIC   := " "
Return()
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDIPM010   บAutor  ณMicrosiga           บ Data ณ  07/11/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ValorPedido(cPedido)
*--------------------------------------------------------------------------*
Local aArea      := GetArea()
Local aAreaSC61   := SC6->( GetArea() )
Local aAreaSC51   := SC5->( GetArea() )
Local nVlrPed    := 0

DbSelectArea("SC6")
DbSetOrder(1)
SC6->(DbSeek(xFilial("SC6")+cPedido))
While SC6->C6_NUM == cPedido
	If SC6->C6_NUM == cPedido
		nVlrPed += SC6->C6_VALOR
	Endif
	SC6->(DbSkip())
Enddo
SC6->(DbCloseArea())    

nVlrPed := (nVlrPed + SC5->C5_DESPESA + SC5->C5_SEGURO + SC5->C5_FRETE)

RestArea( aAreaSC51 )
RestArea( aAreaSC61 )
RestArea( aArea )

Return(nVlrPed)                 
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHoraLibPV บAutor  ณMicrosiga           บ Data ณ  08/11/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Busca informacoes do Z9 para exibir na fila de separacao   บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function HoraLibPV(cPV)
Local cDtLib     := ""
Local cHrLib     := ""
Local cDtLibCred := ""
Local cHrLibCred := ""
Local cQuery	 := ""
DEFAULT cPV := ""

cQuery := "SELECT "
cQuery += " Z9_DATAMOV, "
cQuery += " Z9_HORAMOV, "
cQuery += " Z9_OCORREN "
cQuery += " FROM  "+RetSQLName('SZ9')
cQuery += " WHERE "+RetSQLName("SZ9")+".D_E_L_E_T_ <> '*'"
cQuery += " AND Z9_FILIAL = '" + xFilial('SZ9') + "'"
cQuery += " AND Z9_PEDIDO = '"+ cPV + "'"
cQuery += " AND Z9_OCORREN IN ('10','16','26')"
cQuery += " ORDER BY Z9_DATAMOV, Z9_HORAMOV, Z9_PEDIDO,Z9_OCORREN

cQuery := ChangeQuery(cQuery)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"QRYSZ9",.T.,.T.)

TcSetField("QRYSZ9","Z9_DATAMOV","D",8,0)

While QRYSZ9->(!EOF())
	
	If QRYSZ9->Z9_OCORREN = "10" .OR. QRYSZ9->Z9_OCORREN = "16"
		cDtLib := DTOC(QRYSZ9->Z9_DATAMOV)
		cHrLib := Left(QRYSZ9->Z9_HORAMOV,5)
	EndIf
	
	If QRYSZ9->Z9_OCORREN = "26"
		cDtLibCred := DTOC(QRYSZ9->Z9_DATAMOV)
		cHrLibCred := Left(QRYSZ9->Z9_HORAMOV,5)
	EndIf
	
	QRYSZ9->(dbSkip())
Enddo

QRYSZ9->(dbCloseArea())

Return({cDtLib,cHrLib,cDtLibCred,cHrLibCred})
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDIPM010   บAutor  ณMicrosiga           บ Data ณ  11/01/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function DipVldPed(cPedido) 
Local aAreaSC5 := SC5->(GetArea())   
Local aAreaSC6 := SC6->(GetArea()) 
Local nQtdDias := 0  
Local aLotes   := {}   

SC5->(dbSetOrder(1))
If SC5->(dbSeek(xFilial('SC5')+cPedido)) .And. SC5->C5_XPRXLOT == '1'
	SC6->(dbSetOrder(1))	
	If SC6->(dbSeek(xFilial('SC6')+cPedido))	
		While !SC6->(Eof()) .And. SC6->C6_NUM == cPedido
			If SC6->C6_XPRXLOT == '1'             
				nQtdDias := U_ValidCli(SC6->C6_CLI,SC6->C6_LOJA)
				aLotes 	 := U_ValidProd(SC6->C6_PRODUTO,nQtdDias,SC6->C6_QTDVEN,.T.)
			EndIf
			SC6->(dbSkip())
		EndDo
	EndIf
EndIf
	
RestArea(aAreaSC6)
RestArea(aAreaSC5)

Return aLotes 

//RBORGES 21/06/2013 - Fun็ใo abaixo foi comentada, pois serแ usada nas fun็๕es:
// MT450FIM / FT210LIB / M410STTS
//
            
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDIPM010   บAutor  ณMicrosiga           บ Data ณ  05/03/13   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Rotina para enviar CIC e EMAIL da prenota                  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿

Static Function CICMailPN(cPedido)
Local aAreaSC5  := SC5->(GetArea())
Local aMsg		:= {}
Local cEmail	:= ""
Local cAssunto	:= ""
Local cQuery 	:= ""
Local cVal_STD 	:= ""
Local aMsg1 	:= {}
Local cSuframa 	:= ""
Local cDescIcm 	:= ""
Local cNomeCliente:= ""
Local cFrom 	:= ""
Local aMsgSuf 	:= {}
Local cDescIcm	:= ""
Local nTotped   := 0
Local cTituV    := "ATENวรO PEDIDO TEM PRIORIDADE NA LIBERAวรO"

SC5->(dbSetOrder(1))
SC5->(dbSeek(xFilial("SC5")+cPedido))

cDeIcm       :=  Lower(Alltrim(Posicione("SU7",1,xFilial("SU7")+SC5->C5_OPERADO,"U7_EMAIL")))
cEmailIcm    :=  GetMv("ES_DIPV4_6")+","+cDeIcm

If !Empty(SC5->C5_SENHCID) .or. !Empty(SC5->C5_SENHPAG) .or. !Empty(SC5->C5_SENHMAR) .or. !Empty(SC5->C5_SENHTES)
	/*====================================================================================\
	|SELECIONANDO ITENS DO PEDIDO QUE POSSUI SENHA GRAVADA PARA ENVIAR AO ERICH           |
	\====================================================================================*
	
	cQuery := " SELECT C5_CLIENTE, C5_LOJACLI, A1_NOME, C5_NUM, C5_EMISSAO, C5_OPERADO, C5_MARGATU, C5_MARGLIB, C5_SENHCID, C5_SENHTES, C5_SENHMAR, C5_SENHPAG, C5_EXPLSEN, C5_DATA1, C5_PARC1, C5_DATA2, C5_PARC2, C5_DATA3, C5_PARC3, C5_DATA4, C5_PARC4, C6_PRODUTO, C6_MARGATU, C6_MARGITE, C6_QTDVEN, C6_PRCVEN, C6_CUSTO, C6_PRCMIN, C6_NOTA, C6_VALOR, B1_DESC, B1_UCOM, B1_UPRC+(B1_UPRC*B1_IPI/100) B1_UPRC, B1_PRVMINI, B1_PRVSUPE, B1_ALTPREC, U7_NREDUZ, U7_EMAIL, E4_DESCRI, C5_DATA1, C5_DATA2, C5_DATA3, C5_DATA4 "
	cQuery += " FROM " + RetSQLName("SC6") + ", " + RetSQLName("SC5") + ", " + RetSQLName("SA1") + ", " + RetSQLName("SU7") + ", " + RetSQLName("SB1") + ", " + RetSQLName("SE4")
	cQuery += " WHERE C6_FILIAL = '"+xFilial("SC6")+"'" // JBS 09/11/2005
	cQuery += "   AND C5_FILIAL = '"+xFilial("SC5")+"'" // JBS 09/11/2005
	cQuery += "   AND A1_FILIAL = '"+xFilial("SA1")+"'" // JBS 09/11/2005
	cQuery += "   AND U7_FILIAL = '"+xFilial("SU7")+"'" // JBS 09/11/2005
	cQuery += "   AND B1_FILIAL = '"+xFilial("SB1")+"'" // JBS 09/11/2005
	cQuery += "   AND E4_FILIAL = '"+xFilial("SE4")+"'" // JBS 09/11/2005
	cQuery += "   AND C6_NUM = '" + SC5->C5_NUM + "'" // JBS 09/11/2005
	cQuery += "   AND C5_NUM = C6_NUM"
	cQuery += "   AND C6_CLI = A1_COD"
	cQuery += "   AND C6_LOJA = A1_LOJA"
	cQuery += "   AND C5_OPERADO = U7_COD"
	cQuery += "   AND E4_CODIGO = C5_CONDPAG"
	cQuery += "   AND B1_COD = C6_PRODUTO"
	cQuery += "   AND " + RetSQLName("SC6") + ".D_E_L_E_T_ <> '*'"
	cQuery += "   AND " + RetSQLName("SC5") + ".D_E_L_E_T_ <> '*'"
	cQuery += "   AND " + RetSQLName("SA1") + ".D_E_L_E_T_ <> '*'"
	cQuery += "   AND " + RetSQLName("SU7") + ".D_E_L_E_T_ <> '*'"
	cQuery += "   AND " + RetSQLName("SB1") + ".D_E_L_E_T_ <> '*'"
	cQuery += "   AND " + RetSQLName("SE4") + ".D_E_L_E_T_ <> '*'"
	cQuery += " ORDER BY C6_NUM"

	cQuery := ChangeQuery(cQuery)
	
	DbCommitAll()
	DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"QRY1",.T.,.T.)
	
	DbSelectArea("QRY1")
	QRY1->(dbGotop())
	
	Do While QRY1->(!EOF())
		aadd(aMsg,{QRY1->C5_CLIENTE, QRY1->C5_LOJACLI, QRY1->A1_NOME, QRY1->C5_NUM, QRY1->C5_EMISSAO, QRY1->C5_OPERADO, QRY1->C5_MARGATU, QRY1->C5_MARGLIB, QRY1->C5_SENHMAR, QRY1->C5_SENHPAG, QRY1->C5_SENHTES, QRY1->C5_SENHCID, QRY1->C5_EXPLSEN, QRY1->C5_DATA1, QRY1->C5_PARC1, QRY1->C5_DATA2, QRY1->C5_PARC2, QRY1->C5_DATA3, QRY1->C5_PARC3, QRY1->C5_DATA4, QRY1->C5_PARC4, QRY1->C6_PRODUTO, QRY1->C6_MARGATU, QRY1->C6_MARGITE, QRY1->C6_QTDVEN, QRY1->C6_PRCVEN, QRY1->C6_CUSTO, QRY1->C6_PRCMIN, QRY1->C6_NOTA, QRY1->C6_VALOR, QRY1->B1_DESC, QRY1->B1_UCOM, QRY1->B1_UPRC, QRY1->B1_PRVMINI, QRY1->B1_PRVSUPE, QRY1->B1_ALTPREC, QRY1->U7_NREDUZ, QRY1->U7_EMAIL, QRY1->E4_DESCRI, QRY1->C5_DATA1, QRY1->C5_DATA2, QRY1->C5_DATA3, QRY1->C5_DATA4})
		QRY1->(DbSkip())
	EndDo
	
	
	If Len(aMsg) > 0 // SE NรO POSSUIR NENHUMA LINHA NO ARRAY NรO ENVIA NADA
		cEmail := 'erich@dipromed.com.br'
		If '02' $ Posicione("SU7",1,xFilial("SU7")+SC5->C5_OPERADO,"U7_POSTO")
			cEmail := cEmail +" ; andreia.pires@dipromed.com.br "
		EndIf
		cAssunto := 'Pedido de venda liberado por senha - ' + SC5->C5_NUM
		If substr(SC5->C5_XRECOLH,5,1) $ "-"
			cAssunto := cAssunto + " - Item com Valor Menor que Pre็o de Lista."
		EndIf
		U_EMail2(cEmail,cAssunto,aMsg)
	Endif
	
	
	DBCLOSEAREA("QRY1")
EndIf

If SubStr(SC5->C5_MENNOTA,AT('=',SC5->C5_MENNOTA),5) == "=ST=D"  .AND. Val(Left(SC5->C5_MENNOTA,4)) > 0/// VERIFICA SE SUBST. TRIBUTมRIA ESTม INCLUSO NO VALOR DA DESPESA. TRATANDO ST COM VALOR 0 - MCVN 12/11/09.
	/*====================================================================================\
	|SELECIONANDO ITENS DO PEDIDO QUE POSSUI SUBSTITUIวรO TRIBUTมRIA NA DESPESA           |
	\====================================================================================*
	
	cQuery := "SELECT C6_NUM, C6_ITEM, C6_PRODUTO, C6_QTDVEN, C6_UM, C6_DESCRI, C6_VALOR, C6_CLI, C6_LOJA, C5_MENNOTA, A1_NOME, A1_EST, U7_EMAIL, C5_FRETE, C5_DESPESA "
	cQuery += " FROM " + RetSQLName("SC6") + ", " + RetSQLName("SC5") + ", " + RetSQLName("SA1") + ", " + RetSQLName("SU7")
	cQuery += " WHERE C5_FILIAL = '"+xFilial("SC5")+"'" // JBS 09/11/2005
	cQuery += "   AND C6_FILIAL = '"+xFilial("SC6")+"'" // JBS 09/11/2005
	cQuery += "   AND A1_FILIAL = '"+xFilial("SA1")+"'" // JBS 09/11/2005
	cQuery += "   AND U7_FILIAL = '"+xFilial("SU7")+"'" // JBS 09/11/2005
	cQuery += "   AND C6_NUM = '" + SC5->C5_NUM + "'" // JBS 09/11/2005
	cQuery += "   AND C5_NUM = C6_NUM"
	cQuery += "   AND C6_CLI = A1_COD"
	cQuery += "   AND C6_LOJA = A1_LOJA"
	cQuery += "   AND C5_OPERADO = U7_COD"
	cQuery += "   AND " + RetSQLName("SC6") + ".D_E_L_E_T_ <> '*'"
	cQuery += "   AND " + RetSQLName("SC5") + ".D_E_L_E_T_ <> '*'"
	cQuery += "   AND " + RetSQLName("SA1") + ".D_E_L_E_T_ <> '*'"
	cQuery += "   AND " + RetSQLName("SU7") + ".D_E_L_E_T_ <> '*'"
	cQuery += " ORDER BY C6_NUM"
	
	cQuery := ChangeQuery(cQuery)
	
	DbCommitAll()
	DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"QRY2",.T.,.T.)
	
	dbSelectArea("QRY2")
	dbGotop()
	
	Do While QRY2->(!EOF())
		cVal_STD := SubStr(QRY2->C5_MENNOTA,1,AT("=",QRY2->C5_MENNOTA)-1)
		aadd(aMsg1,{QRY2->C6_NUM, QRY2->C6_ITEM, QRY2->C6_PRODUTO, QRY2->C6_DESCRI, QRY2->C6_UM, QRY2->C6_QTDVEN, QRY2->C6_VALOR, QRY2->C6_CLI, QRY2->C6_LOJA, QRY2->A1_NOME, QRY2->A1_EST, Val(cVal_STD), QRY2->U7_EMAIL, QRY2->C5_FRETE, QRY2->C5_DESPESA})
		//			                 1             2             3                 4                5             6               7               8             9              10             11               12          13              14              15
		QRY2->(DbSkip())
	EndDo
	QRY2->(dbCloseArea())
	
	If Len(aMsg1) > 0 // SE NรO POSSUIR NENHUMA LINHA NO ARRAY NรO ENVIA NADA
		cEmail := GetNewPar("ES_DIP_STP","reginaldo.borges@dipromed.com.br")//'magda.teixeira@dipromed.com.br;william.pereira@dipromed.com.br;sirlene.creatto@dipromed.com.br'
		cAssunto := 'AVISO - Substitui็ใo Tributแria - PV-' + SC5->C5_NUM
	   //	AVCicST()
		U_EMailPre(cEmail,cAssunto,aMsg1)
	Endif
EndIf

// ENVIA EMAIL SE CLIENTE TIVER SUFRAMA (PIN-PROTOCOLO DE INTERNAวรO DE NOTA FISCAL)  17/01/2008
cSuframa := Posicione('SA1', 1, xFilial('SA1') + SC5->C5_CLIENTE + SC5->C5_LOJACLI, 'A1_SUFRAMA')
If  !Empty(cSuframa)
	cDescIcm     := SA1->A1_CALCSUF
	cNomeCliente := SA1->A1_NOME
	cFrom        := Lower(Alltrim(Posicione("SU7",1,xFilial("SU7")+SC5->C5_OPERADO,"U7_EMAIL")))
	
	Aadd( aMsgSuf , { "Cliente: "             , SC5->C5_CLIENTE + " - " + cNomeCliente} )
	Aadd( aMsgSuf , { "Numero Pedido: "       , SC5->C5_NUM } )
	Aadd( aMsgSuf , { "Operador: "            , SC5->C5_OPERADO +" - " + Alltrim(Posicione("SU7",1,xFilial("SU7")+SC5->C5_OPERADO,"U7_NOME")) } )
	Aadd( aMsgSuf , { "Transportadora: "      , SC5->C5_TRANSP + " - " + Alltrim(Posicione("SA4",1,xFilial("SA4")+SC5->C5_TRANSP,"A4_NOME" )) } )
	Aadd( aMsgSuf , { "Destino do Pedido:  "  , SC5->C5_ESTE +" - "+ SC5->C5_MUNE } )
	Aadd( aMsgSuf , { "C๓digo Suframa: "      , Posicione('SA1', 1, xFilial('SA1') + SC5->C5_CLIENTE + SC5->C5_LOJACLI, 'A1_SUFRAMA') } )
	If cDescIcm == "S"
		Aadd( aMsgSuf , { "Desconto Icms:  "  , "SIM" } )
	Endif
	
	If Len(aMsgSuf) > 0
		cEmail := 'magda.teixeira@dipromed.com.br;william.pereira@dipromed.com.br;sirlene.creatto@dipromed.com.br'
		cAssunto := 'AVISO - Cliente com SUFRAMA - PV-' + SC5->C5_NUM
		U_UEnvMail(cEmail,cAssunto,aMsgSuf,"",cFrom,"Prenota.prw")
	Endif
EndIf

//giovani reposicionamento do e-mail do cic e do e-mail a vista sem para no financeiro. 12/07/11

SA1->(dbSetOrder(1))
SA1->(dbSeek(xFilial("SA1") + SC5->C5_CLIENTE + SC5->C5_LOJACLI))


If SC5->C5_TIPODIP = "1" .And. substr(SC5->C5_XRECOLH,1,3) $ "ACR/GUI"
	
	aAdd( _aMIcm , { "EMPRESA"      , + Capital( AllTrim( GetAdvFVal( "SM0", "M0_NOMECOM", cEmpAnt + cFilAnt, 1, "" ) ) )  } )
	aAdd( _aMIcm , { "FILIAL"       , + Capital( AllTrim( GetAdvFVal( "SM0", "M0_FILIAL" , cEmpAnt + cFilAnt, 1, "" ) ) ) } )
	aAdd( _aMIcm , { "PEDIDO"       , ""+SC5->C5_NUM+""  } )
	aAdd( _aMIcm , { "CLIENTE"      , ""+AllTrim(SA1->A1_COD)+" - "+AllTrim(SA1->A1_NREDUZ)+""  } )
	aAdd( _aMIcm , { "E-Mail"       , ""+Lower(Alltrim(Posicione("SA1",1,xFilial("SA1")+SC5->C5_CLIENTE+SC5->C5_LOJACLI,"A1_EMAIL")))+""} ) //giovani 19/07/11
	aAdd( _aMIcm , { "OPERADOR"      ,""+SC5->C5_OPERADO+"-"+Posicione("SU7",1,xFilial("SU7")+SC5->C5_OPERADO,"U7_NOME") })
	aAdd( _aMIcm , { "VENDEDOR"      ,""+SC5->C5_VEND1+"-"+Posicione("SA3",1,xFilial("SA3")+SC5->C5_VEND1,"A3_NOME") })
	aAdd( _aMIcm , { "TRANSPORTADORA", ""+SC5->C5_TRANSP+" - " + AllTrim(FDesc("SA4",SC5->C5_TRANSP,"SA4->A4_NREDUZ"))+" "  } )
	If substr(SC5->C5_XRECOLH,1,3) $ "ACR"
		aAdd( _aMIcm , { "OPวรO"        , "1- Acrescimo no Valor do Pedido."  } )
	EndIf
	        	
	U_MailPedi(cEmailIcm,cAssuntIcm,_aMIcm,cAttachIcm,cDeIcm,cSentIcm,cTituV)
	
	//manda cic do pedido
	
	cMSGcIC       := " EMPRESA:_______" + Capital( AllTrim( GetAdvFVal( "SM0", "M0_NOME", cEmpAnt + cFilAnt, 1, "" ) ) ) +"/"+ Capital( AllTrim( GetAdvFVal( "SM0", "M0_FILIAL" , cEmpAnt + cFilAnt, 1, "" ) ) )   + CR + CR
	cMSGcIC       += _aMIcm[3][1]+":____________" +_aMIcm[3][2] +CR
	//................1 2 3 4 5 6 7 8 9 0
	cMSGcIC       += _aMIcm[4][1]+":___________" +_aMIcm[4][2] +CR
	//................1 2 3 4 5 6 7 8 9 0
	cMSGcIC       += _aMIcm[6][1]+":_________" +_aMIcm[6][2] +CR
	//................1 2 3 4 5 6 7 8 9 0
	cMSGcIC       += _aMIcm[8][1]+":__" +_aMIcm[8][2] +CR
	//................1 2 3 4 5 6 7 8 9 0
	If substr(SC5->C5_XRECOLH,1,3) $ "ACR"
		cMSGcIC       += _aMIcm[9][1]+":_____________" +_aMIcm[9][2] +CR
		//................1 2 3 4 5 6 7 8 9 0
	EndIf
	cMSGcIC       += "AVISO: Pedido com Prioridade de libera็ใo -(Icms-Interestadual)" +CR
	//................1 2 3 4 5 6 7 8 9 0
	
	//manda CIC
	U_DIPCIC(cMSGcIC,GetMV("ES_DIPV4_7"))
	
	//giovani msg do cic na libera็ใo do pedido a vista  e nao ficou parado no financeiro
	
	If SC5->C5_CONDPAG $ "001/002"
		If	SC5->C5_TIPODIP = "1"
			cMSGcIC   := " "
			nTotped := ValorPedido(SC5->C5_NUM)
			
			// Monta a mensagem a ser enviado ao operador
			cMSGcIC := "PEDIDO A VISTA"+CR+CR
			cMSGcIC += "O Pedido A VISTA   "   +Alltrim(SC5->C5_NUM)+CR+CR
			cMSGcIC += " do Cliente   "+AllTrim(SA1->A1_COD)+" - "+AllTrim(SA1->A1_NREDUZ)+CR+CR
			cMSGcIC += " Valor total "+AllTrim(Transform(nTotped,"@E 999,999,999.99"))+CR +CR+CR      // Incluido por Sandro em 10/11/09
			
			cMSGcIC += "Operador:  "+SC5->C5_OPERADO+"-"+Posicione("SU7",1,xFilial("SU7")+SC5->C5_OPERADO,"U7_NOME")
			
			
			
			U_DIPCIC(cMSGcIC,GetMV("ES_DIPV4_5"))
		EndIf
	Endif
EndIf

U_DipCicCli()

RestArea(aAreaSC5)      

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDIPM010   บAutor  ณMicrosiga           บ Data ณ  05/09/13   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function NaoMovEst(cPedido,cMenDep)
Local lRet     := .F.    
Local cSQL     := ""
Local cMsg     := "" 
Local cDeIc      := Lower(Alltrim(GetMv("MV_RELACNT")))
Local cAssuntoIc := EncodeUTF8("AVISO - PEDIDO "+cPedido+" NรO MOVIMENTOU ESTOQUE!","cp1252")
Local cAttachIc  := "  a"
Local cFuncSentIc:= " DIPM010.prw "
Local cEmailIc   := GetNewPar("ES_DIPMALE","reginaldo.borges@dipromed.com.br;lourival.nunes@dipromed.com.br;edvan.matias@dipromed.com.br;expedicao@dipromed.com.br")        //Usuแrios que receberใo e-mails 
Local cUserTpE := GetNewPar("ES_DIPMALM","REGINALDO.BORGES,MAXIMO.CANUTO,DIEGO.DOMINGOS,LOURIVAL.NUNES,EDVAN.MATIAS,EXPEDICAOCD,NOTAFISCAL,NOTAFISCAL2")
DEFAULT cPedido:= ""
DEFAULT cMenDep := ""

cSQL := " SELECT "
cSQL += " 	F4_ESTOQUE"
cSQL += " 	FROM "
cSQL += " 	  "+RetSQlName("SC6")+", "+RetSQLName("SF4")
cSQL += " 		WHERE "
cSQL += " 			C6_FILIAL = '"+xFilial("SC6")+"' "
cSQL += " 			AND F4_FILIAL = '"+xFilial("SF4")+"' "
cSQL += " 			AND C6_TES = F4_CODIGO "
cSQL += " 			AND C6_NUM = '"+cPedido+"' "
cSQL += " 			AND F4_ESTOQUE = 'S' "
cSQL += " 			AND "+RetSQlName("SC6")+".D_E_L_E_T_ = ' ' "
cSQL += " 			AND "+RetSQlName("SF4")+".D_E_L_E_T_ = ' ' "

cSQL := ChangeQuery(cSQL)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),"QRYSC6",.T.,.T.)

lRet := QRYSC6->(Eof())

QRYSC6->(dbCloseArea())  

If lRet
	cMsg := "ATENวรO"+CHR(10)+CHR(13)
	cMsg += "Pedido "+cPedido+" nใo movimentou estoque."+CHR(10)+CHR(13)
	cMsg += "Este pedido deverแ ser faturado pela rotina Faturamento/Documento de Saํda."+CHR(10)+CHR(13)+CHR(10)+CHR(13)
	cMsg += "MENSAGEM DEP.: "+cMenDep 
	
_aMsgIc := {}
	 
aAdd(_aMsgIc , { "PEDIDO        ", +cPedido+" nใo movimentou estoque."})
aAdd(_aMsgIc , { "ATENวรO       ", +"Este pedido deverแ ser faturado pela rotina Faturamento/Documento de Saํda."})
aAdd(_aMsgIc , { "MENS.DEPOSITO ", +cMenDep})


	U_UEnvMail(cEmailIc,cAssuntoIc,_aMsgIc,cAttachIc,cDeIc,cFuncSentIc)
	U_DIPCIC(cMsg,cUserTpE)
EndIf

Return lRet 


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDIPM010   บAutor  ณMicrosiga           บ Data ณ  05/23/13   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/


Static Function TpAlmox(cPedido,cMenDep)

Local lRet       := .F.    
Local cSQL       := ""
Local cMsg       := ""
Local cDeIc      := Lower(Alltrim(GetMv("MV_RELACNT")))
Local cAssuntoIc := EncodeUTF8("AVISO - PEDIDO "+cPedido+" NรO ESTOQUE 01!","cp1252")
Local cAttachIc  := "  a"
Local cFuncSentIc:= " DIPM010.prw "
Local cEmailIc   := GetNewPar("ES_DIPMALE","reginaldo.borges@dipromed.com.br;lourival.nunes@dipromed.com.br;edvan.matias@dipromed.com.br;expedicao@dipromed.com.br")        //Usuแrios que receberใo e-mails 
Local cUserTpA   := GetNewPar("ES_DIPMALM","REGINALDO.BORGES,MAXIMO.CANUTO,DIEGO.DOMINGOS,LOURIVAL.NUNES,EDVAN.MATIAS,EXPEDICAOCD,NOTAFISCAL,NOTAFISCAL2")

DEFAULT cPedido  := ""
DEFAULT cMenDep  := ""

cSQL := " SELECT "
cSQL += " 	C6_LOCAL"
cSQL += " 	FROM "
cSQL += " 	  "+RetSQlName("SC6")
cSQL += " 		WHERE "
cSQL += " 			C6_FILIAL     = '"+xFilial("SC6")+"' "
cSQL += " 			AND C6_NUM    = '"+cPedido+"' "
cSQL += " 			AND C6_LOCAL  IN ('01','20') "
cSQL += " 			AND "+RetSQlName("SC6")+".D_E_L_E_T_ = ' '"


cSQL := ChangeQuery(cSQL)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),"xQRYSC6",.T.,.T.)

lRet := xQRYSC6->(Eof())

xQRYSC6->(dbCloseArea())  

If lRet
	cMsg := "ATENวรO!"+CHR(10)+CHR(13)
	cMsg += "Pedido "+cPedido+"nใo ้ estoque 01."+CHR(10)+CHR(13)
	cMsg += "Este pedido deverแ ser faturado pela rotina Faturamento/Documento de Saํda."+CHR(10)+CHR(13)+CHR(10)+CHR(13)
	cMsg += "MENSAGEM DEP.: "+cMenDep	          
	
_aMsgIc := {}
	 
aAdd(_aMsgIc , { "PEDIDO        ", +cPedido+" nใo ้ estoque 01."})
aAdd(_aMsgIc , { "ATENวรO       ", +"Este pedido deverแ ser faturado pela rotina Faturamento/Documento de Saํda."})
aAdd(_aMsgIc , { "MENS.DEPOSITO ", +cMenDep})


	U_UEnvMail(cEmailIc,cAssuntoIc,_aMsgIc,cAttachIc,cDeIc,cFuncSentIc)
	U_DIPCIC(cMsg,cUserTpA)
EndIf

Return lRet 
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDIPM010   บAutor  ณMicrosiga           บ Data ณ  08/13/14   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function DipPedDup(cPedido)   
Local cSQL := "" 
Local cMsg := ""
Local lRet := .F.

cSQL := " SELECT "
cSQL += " 	CB7_ORDSEP, CB7_CLIENT, CB7_STATUS, CB7_STATPA "
cSQL += " 	FROM "
cSQL += 		RetSQLName("CB7")
cSQL += " 		WHERE "
cSQL += " 			CB7_FILIAL = '"+xFilial("CB7")+"' AND "
cSQL += " 			CB7_PEDIDO = '"+cPedido+"' AND "
cSQL += "			CB7_NOTA   = ' ' AND "
cSQL += " 			CB7_STATUS < '4' AND "
cSQL += " 			D_E_L_E_T_ = ' ' "

cSQL := ChangeQuery(cSQL)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),"QRYCB7",.T.,.T.)

If !QRYCB7->(Eof())
	cMsg += "Pedido "+cPedido+" nใo pode ser separado."+CHR(10)+CHR(13)
	cMsg += "Jแ existe ordem de separa็ใo para este c๓digo."+CHR(10)+CHR(13)
	cMsg += "### AVISE O TI COM URGสNCIA ###"+CHR(10)+CHR(13)
	While !QRYCB7->(Eof())
		cMsg += "O.S.  : "+QRYCB7->CB7_ORDSEP+CHR(10)+CHR(13)   
		cMSg += "Status: "+RetStatOS(QRYCB7->CB7_STATUS,QRYCB7->CB7_STATPA)+CHR(10)+CHR(13)
		
		QRYCB7->(dbSkip())
	EndDo  
	Aviso("Aten็ใo",cMsg,{"Ok"},3)
	lRet := .T.             
EndIf                   
QRYCB7->(dbCloseArea())

Return lRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDIPM010   บAutor  ณMicrosiga           บ Data ณ  08/13/14   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function RetStatOS(cStatus,cStatPa)     
Local cRet := ""        

Do Case
	Case cStatus == "0"  
		cRet := "Nใo iniciado"
	Case cStatus == "1" .And. cStatPa == "1"
		cRet := "Separa็ใo em pausa"
	Case cStatus == "1"             
		cRet := "Separa็ใo iniciada"
	Case cStatus == "2"             
		cRet := "Separa็ใo finalizada"
	Case cStatus == "3" .And. cStatPa == "1"
		cRet := "Confer๊ncia em pausa"
	Case cStatus == "3"               
		cRet := "Confer๊ncia iniciada"
	Case cStatus == "4"   
		cRet := "Confer๊ncia finalizada"
End Case   

Return cRet   
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDIPM010   บAutor  ณMicrosiga           บ Data ณ  08/25/14   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function DipInvRot()
Local lRet := .T.
Local cSQL := ""
           
cSQL := " SELECT "
cSQL += " 	R_E_C_N_O_ "
cSQL += " 	FROM "
cSQL += 		RetSQLName("ZZC")
cSQL += " 		WHERE "
cSQL += " 			ZZC_FILIAL = '"+xFilial("ZZC")+"' AND "
cSQL += " 			ZZC_STATUS < '4' AND "
cSQL += " 			D_E_L_E_T_ = ' ' "      

cSQL := ChangeQuery(cSQL)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),"QRYZZC",.T.,.T.)

lRet := !QRYZZC->(Eof())
If lRet
	Aviso("Aten็ใo","Existem endere็os nใo finalizados no processo de inventแrio rotativo",{"Ok"},1)
EndIf
QRYZZC->(dbCloseArea())

Return lRet
/*-------------------------------------------------------------------------
+ RBORGES - 21/06/2013 ----- Static Funcion: AVCicST()                    +                                                     
+ Farแ o tratamento para enviar CIC ao gerar a ordem de separa็ใo ou      +
+ pr้-nota, mas apenas para quem estiver no parโmetro.                    +
-------------------------------------------------------------------------

*--------------------------------------------------------------------------*
	Static Function AVCicST()
*--------------------------------------------------------------------------*
	
	Local aArea       := GetArea()
	Local cDeIc       := "protheus@dipromed.com.br"
    Local cCICDest    := Upper(GetNewPar("ES_CIC_STP","REGINALDO.BORGES")) // Usuแrios que receberใo CICดs
	Local cAttachIc   :=  "  a"
	Local cFuncSentIc :=   " DIPM010.prw "
 	
		dbSelectArea("SM0")
		
	_aMsgIc := {}
    	cMSGcIC       := 'AVISO - Substitui็ใo Tributแria - PV-' + SC5->C5_NUM +CR +CR
	
	
	cMSGcIC       += " EMPRESA:_______    " + Capital( AllTrim( GetAdvFVal( "SM0", "M0_NOME", cEmpAnt + cFilAnt, 1, "" ) ) ) +"/"+ Capital( AllTrim( GetAdvFVal( "SM0", "M0_FILIAL" , cEmpAnt + cFilAnt, 1, "" ) ) )   + CR														
  	cMSGcIC       += " PEDIDO:________    " + SC5->C5_NUM +CR
	cMSGcIC       += " CLIENTE:________   " + SC5->C5_CLIENTE+" - "+Posicione("SA1",1,XFILIAL("SA1")+SC5->C5_CLIENTE,'A1_NREDUZ') +CR
	cMSGcIC       += " COND.PAG:__________" + SC5->C5_CONDPAG+" - "+Posicione("SE4",1,XFILIAL("SE4")+SC5->C5_CONDPAG,'E4_DESCRI') +CR
   	cMSGcIC       += " OPERADOR:_______   " + SC5->C5_OPERADO+"-"+Posicione("SU7",1,xFilial("SU7")+SC5->C5_OPERADO,"U7_NREDUZ") +CR
	cMSGcIC       += " TRANSP.:_______    " + SC5->C5_TRANSP+" - " + AllTrim(FDesc("SA4",SC5->C5_TRANSP,"SA4->A4_NREDUZ")) +CR
   	
   	U_DIPCIC(cMSGcIC,cCICDest)
   	  	
	
    RestArea(aArea)	
	return() 
*/  

/*------------------------------------------------------------------------+
+ Funcao:EMailTa()    |  Autor: RBORGES     |      Data: 07/11/14         +                                                     
+ Farแ tratamento para enviar E-mail de aviso de todas as transfer๊ncias  +
+ automแtica para o operador do armazenamento.		                      +
-------------------------------------------------------------------------*/

User Function EMailTa(cEmail,cAssunto,aMsg1)

Local cAccount  := Lower(Alltrim(GetMv("MV_RELACNT")))
Local cFrom     := Lower(Alltrim(GetMv("MV_RELACNT")))
Local cPassword := Alltrim(GetMv("MV_RELPSW"))
Local cServer   := Alltrim(GetMv("MV_RELSERV"))
Local cEmailTo  := ""
Local cEmailCc  := ""
Local cEmailBcc := ""
Local lResult   := .F.
Local cError    := ""
Local cMsg      := ""
Local nI               
LOCAL lSmtpAuth := GetNewPar("MV_RELAUTH",.F.)
LOCAL lAutOk	:= .F.

/*=============================================================================*/
/*Definicao do cabecalho do email                                              */
/*=============================================================================*/
cMsg := ""
cMsg += '<html>'
cMsg += '<head>'                         
cMsg += '<title>' + cAssunto + '</title>'
cMsg += '</head>'
cMsg += '<body>'
cMsg += '<HR Width=85% Size=3 Align=Centered Color=Red> <P>'
cMsg += '<Table Align=Center BorderColor=#000000 CELLPADDING=4 CELLSPACING=0 Width=60%>'

/*=============================================================================*/
/*Definicao do cabecalho do relat๓rio                                          */
/*=============================================================================*/

cMsg += '<table width="100%">'
cMsg += '<tr>'
cMsg += '<td width="100%" colspan="2"><font size="4" color="red">Pedido - ' + aMsg1[1,1] + '</font></td>'
cMsg += '</tr>'
cMsg += '<tr>'
cMsg += '<td width="50%"><font size="2" color="blue">Num. Transf: ' + aMsg1[1,2]  + '</font></td>'
cMsg += '<td width="50%"><font size="2" color="blue">Emissใo: '     + SubStr(aMsg1[1,3],7,2)+'/'+ SubStr(aMsg1[1,3],5,2)+'/'+ SubStr(aMsg1[1,3],1,4) + '</font></td>
cMsg += '</tr>'
cMsg += '</table>'


cMsg += '<table width="100%" cellspacing="0" cellpadding="0"><font size="2" color="blue">'
cMsg += '<tr>'
cMsg += '<td>===============================================================================================================</td>'
cMsg += '</tr>'
cMsg += '</font></table>'

cMsg += '<table width="100%" cellspacing="0" cellpadding="0"><font size="2" color="blue">'
cMsg += '<td width="16%">Produto</td>'
cMsg += '<td width="16%">Origem</td>'
cMsg += '<td width="16%">Destino</td>'
cMsg += '<td width="20%">Lote</td>'
cMsg += '<td width="16%">Quant</td>'
cMsg += '<td width="16%">Documento</td>'
cMsg += '</tr>'
cMsg += '</font></table>'

cMsg += '<table width="100%" cellspacing="0" cellpadding="0"><font size="2" color="blue">'
cMsg += '<tr>'
cMsg += '<td>===============================================================================================================</td>'
cMsg += '</tr>'
cMsg += '</font></table>'

/*=============================================================================*/
/*Definicao do texto/detalhe do email                                          */
/*=============================================================================*/


For nI := 1 to Len(aMsg1)
	nLin:= nI
	If Mod(nLin,2) == 0
		cMsg += '<table width="100%" border="0" cellspacing="0" cellpadding="0">'
		cMsg += '<tr bgcolor="#B0E2FF">'
		cMsg += '<td width="16%"><font size="2">' +aMsg1[nLin,4]+ '</font></td>'
		cMsg += '<td width="16%"><font size="2">' +aMsg1[nLin,5]+ '</font></td>'
		cMsg += '<td width="16%"><font size="2">' +aMsg1[nLin,6]+ '</font></td>'
		cMsg += '<td width="20%"><font size="2">' +aMsg1[nLin,7]+ '</font></td>'
		cMsg += '<td width="16%"><font size="2">' +cValToChar(aMsg1[nLin,8])+ '</font></td>'
		cMsg += '<td width="16%"><font size="2">' +aMsg1[nLin,9]+ '</font></td>'
		cMsg += '</tr>'
		cMsg += '</table>'
	Else
		cMsg += '<table width="100%" border="0" cellspacing="0" cellpadding="0">'
		cMsg += '<tr bgcolor="#c0c0c0">'
		cMsg += '<td width="16%"><font size="2">' +aMsg1[nLin,4]+ '</font></td>'
		cMsg += '<td width="16%"><font size="2">' +aMsg1[nLin,5]+ '</font></td>'
		cMsg += '<td width="16%"><font size="2">' +aMsg1[nLin,6]+ '</font></td>'
		cMsg += '<td width="20%"><font size="2">' +aMsg1[nLin,7]+ '</font></td>'
		cMsg += '<td width="16%"><font size="2">' +cValToChar(aMsg1[nLin,8])+ '</font></td>'
		cMsg += '<td width="16%"><font size="2">' +aMsg1[nLin,9]+ '</font></td>'
		cMsg += '</tr>'
		cMsg += '</table>'	
	EndIf	
Next

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Definicao do rodape do email                                                ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
cMsg += '</Table>'
cMsg += '<HR Width=85% Size=3 Align=Centered Color=Red> <P>'
cMsg += '<table width="100%" Align="Center" border="0">'
cMsg += '<tr align="center">'
cMsg += '<td colspan="10"><font color="BLUE" size="2">Mensagem enviada automaticamente pelo sistema PROTHEUS - <font color="BLUE" size="1">(DIPM010.PRW)</td>'
cMsg += '</tr>'
cMsg += '</table>'
cMsg += '</body>'
cMsg += '</html>'

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณEnvia o mail para a lista selecionada. Envia como BCC para que a pessoa penseณ
//ณque somente ela recebeu aquele email, tornando o email mais personalizado.   ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
IF At(";",cEmail) > 0
	cEmailTo := SubStr(cEmail,1,At(";",cEmail)-1)
	cEmailCc := SubStr(cEmail,At(";",cEmail)+1,Len(cEmail))
Else
	cEmailTo := Alltrim(cEmail)
EndIF

CONNECT SMTP SERVER cServer ACCOUNT cAccount PASSWORD cPassword RESULT lResult

If !lAutOk
	If ( lSmtpAuth )
		lAutOk := MailAuth(cAccount,cPassword)
	Else
		lAutOk := .T.
	EndIf
EndIf

If lResult .And. lAutOk
	SEND MAIL FROM cFrom ;
	TO      	Lower(cEmailTo);
	CC      	Lower(cEmailCc);
	BCC     	Lower(cEmailBcc);
	SUBJECT 	cAssunto;
	BODY    	cMsg;
	RESULT lResult
	
	If !lResult
		//Erro no envio do email
		GET MAIL ERROR cError
		
		MsgInfo(cError,OemToAnsi("Aten็ใo"))
	EndIf
	
	DISCONNECT SMTP SERVER
Else
	//Erro na conexao com o SMTP Server
	GET MAIL ERROR cError
	MsgInfo(cError,OemToAnsi("Aten็ใo"))
EndIf

Return(.T.)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDIPM010   บAutor  ณMicrosiga           บ Data ณ  05/13/16   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function DipVldCXF(cPedido,cProduto,cItem,aLotBlq)
Local aLotesSBF := {}
Local aAreaSC5 	:= SC5->(GetArea())
Local aAreaSC6 	:= SC6->(GetArea())

SC5->(dbSetOrder(1))

If cEmpAnt <> "04" 
	If SC5->(dbSeek(xFilial('SC5')+cPedido)) .And. SC5->C5_CLIENTE$GetNewPar("ES_DCLICXF","000665")
		SC6->(dbSetOrder(1))	
		If SC6->(dbSeek(xFilial('SC6')+cPedido+cItem+cProduto))	
			While !SC6->(Eof()) .And. SC6->(C6_NUM+C6_ITEM+C6_PRODUTO) == cPedido+cItem+cProduto
				aLotesSBF := u_VldCxEmb(SC6->C6_QTDVEN,aLotBlq,SC6->C6_PRODUTO,.T.,SC6->C6_ITEM)
				SC6->(dbSkip())
			EndDo
		EndIf
	EndIf
Else
	cGPRCXF := Posicione("SA1",1,xFilial("SA1")+SC5->C5_CLIENTE,'A1_GRPVEN')
	If SC5->(dbSeek(xFilial('SC5')+cPedido)) .And. (SC5->C5_CLIENTE$GetNewPar("ES_DCLICXF","000665") .Or. cGPRCXF$GetNewPar("ES_DGRPCXF","000175")) .And. !U_AmostrasHQ()
		SC6->(dbSetOrder(1))	
		If SC6->(dbSeek(xFilial('SC6')+cPedido+cItem+cProduto))	
			While !SC6->(Eof()) .And. SC6->(C6_NUM+C6_ITEM+C6_PRODUTO) == cPedido+cItem+cProduto
				aLotesSBF := u_VldCxEmb(SC6->C6_QTDVEN,aLotBlq,SC6->C6_PRODUTO,.T.,SC6->C6_ITEM)
				SC6->(dbSkip())
			EndDo
		EndIf
	EndIf
	cGPRCXF := ""
EndIf

RestArea(aAreaSC5)
RestArea(aAreaSC6)

Return aLotesSBF

#include "Protheus.ch"
#include "TopConn.ch"
#INCLUDE "APVT100.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "msgraphi.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ORDSEP11  ³ Autor ³ Emerson Leal Bruno    ³ Data ³          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Geração ordem de separacao dipromed 	                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAACD //{"Gerar O.S."		,"U_GeraOsDip"	,0,3},;       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function ORDSEP11(cPedido)           

PRIVATE aRecno	:={}

PRIVATE aRotina := {	{"Pesquisar"		,"AxPesqui"		,0,1},;   
						{"Visualizar"		,"ACDA100Vs"	,0,2},;  
						{"Gerar O.S."		,"U_GeraOsDip"	,0,3},; 
						{"Estornar"			,"U_DIPESTOS"	,0,4},;     
						{"Impressao"		,"ACDA100Re"	,0,5},;   
						{"Legenda"			,"U_DIPA100Lg"	,0,6},;
						{"Alt.Priorid."		,"U_DIPAltPri"	,0,6},;
						{"Contr. de Tarefa"	,"CBMONRF"	    ,0,6}}
						 
						
PRIVATE cCadastro := OemtoAnsi( "Ordens de separacao" ) //"Ordens de separacao"

aCores := {		{ "CB7->CB7_STATUS == '0'"									, "BR_VERMELHO" },;
				{ "CB7->CB7_STATUS == '1' .And. CB7->CB7_STATPA = '1'"		, "BR_PRETO_1"  },;
				{ "CB7->CB7_STATUS == '1'"									, "BR_LARANJA"  },;
				{ "CB7->CB7_STATUS == '2'"									, "BR_AMARELO" 	},;
				{ "CB7->CB7_STATUS == '3' .And. CB7->CB7_STATPA = '1'"		, "BR_PRETO_2"  },;
				{ "CB7->CB7_STATUS == '3'"									, "BR_BRANCO"  	},; 
				{ "CB7->CB7_STATUS == '4' .And. !Empty(CB7->CB7_NOTA)"		, "BR_PINK"  	},;
				{ "CB7->CB7_STATUS == '4'"	   								, "BR_VIOLETA" 	},;
				{ "CB7->CB7_STATUS == '8' .And. CB7->CB7_STATPA = '1'"		, "BR_PRETO_3"  },;
				{ "CB7->CB7_STATUS == '8'"									, "BR_AZUL"   	},;
				{ "CB7->CB7_STATUS == '9'"	   								, "BR_VERDE"   	} } 
			
If !(Alltrim(Upper(U_DipUsr()))$Upper(GetNewPar("ES_ORDSEP","")))
	Return(Aviso("Atenção","Usuário sem acesso para acessar a rotina",{"Ok"},1))
EndIf

mBrowse( 6, 1, 22, 75, "CB7", , , , , , aCores, , , ,) //{|x|TimerBrw(x)}

Return()

/*
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
*/

User Function GeraOsDip(cPedido)
Local aRotBack  := {}
Local cArqInd   := ""
Local cChaveInd := ""
Local cCondicao := ""
Local lMark     := .T.			//.F.
Local aNewFil   := {}
Local cFilSC9   := ".T."
Local cFilSD2   := ".T."
Local cFilSC2   := ".T."
PRIVATE nIndice    	:= 0
PRIVATE nOrigExp   	:= ""
PRIVATE cSeparador 	:= Space(6)	//variavel utilizada para armazenar o separador da pergunte AIA102, pois o mesmo estava sendo sobreposto por outra pergunte, ao precionar F12 na tela de geracao
Private cOrdSepTerr	:= ''
Private cOrdSepMeza	:= ''                  
Private aLogOS		:= {}

If "DIPM010"$Funname()
	U_AjustaSX1("ACDR001")
	If !Pergunte("ACDR001",.F.)	
	//	Return Nil
	Endif
	MV_PAR01 := cPedido
Else
	U_AjustaSX1("ACDR001")
	If !Pergunte("ACDR001",.T.)	
		Return Nil
	Endif
End

aRotBack := aClone( aRotina )
aRotina  := {{"Gerar","U_GravaInf",0,1} } //"Gerar"

dbSelectArea("SC9")
dbSetOrder(1)
cArqInd   := CriaTrab(, .F.)
cChaveInd := IndexKey()
cCondicao := 'C9_PEDIDO = "'+mv_par01+'" .And. Empty(C9_ORDSEP) .And. C9_QTDORI > 0'

IndRegua("SC9", cArqInd, cChaveInd, , cCondicao, "Criando indice de trabalho" ) //"Criando indice de trabalho"
nIndice := RetIndex("SC9") + 1

#IFNDEF TOP
	dbSetIndex(cArqInd + OrdBagExt())
#ENDIF

dbSetOrder(nIndice)
SC9->(MsSeek(xFilial("SC9")))
MarkBrow("SC9","C9_OK","SC9->C9_BLEST+SC9->C9_BLCRED", ,lMark,GetMark(,"SC9","C9_OK") )
SC9->(DbClearFil())
RetIndex("SC9")

aRotina := aClone( aRotBack )
Return( Nil )

/*
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
*/

User Function GravaInf(cAlias,cCampo,nOpcE,cMarca,lInverte,lNoDupl)
Local aArea := GetArea()

Processa( { || U_GeraOS(cMarca,lInverte ) } )

RestArea(aArea)

If FunName()=="DIPM010"
	CloseBrowse()
EndIf

Return

/*
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
*/

User Function GeraOS(cMarca,lInverte,cPedido)

Local aTerreo		:= {}
Local aMezan		:= {}
Local aRecSC91		:= {}
Local aRecSC92		:= {}
Local cCliente		:= ''
Local cLoja			:= ''
Local cLocal		:= ''
Local nItem			:= 0                  
Local aEtiq			:= {}
Local cTransp		:= ''
Local cMenDep       := ''
Local cPrior		:= ''
Local lDireto 		:= "DIPM010"$Funname()
Local cArqInd 		:= ""
Local cChaveInd 	:= ""
Local cCondicao 	:= ""
Local cImpTpTer		:= ""
Local cImpTpMez		:= ""
Local _lCxFech		:= .F.

Private _oDLG                               
DEFAULT cPedido := ""

DEFINE FONT oBold   NAME "Arial" SIZE 0, -12 BOLD   //fonte
DEFINE FONT oBold2  NAME "Arial" SIZE 0, -20 BOLD   //fonte 

SC5->(DbSetOrder(1))
SC6->(DbSetOrder(1))
SDC->(DbSetOrder(1))
CB7->(DbSetOrder(2))
CB8->(DbSetOrder(2))
         
If lDireto
	
	nIndice    	:= 0
	nOrigExp   	:= ""
	cSeparador 	:= Space(6)
	cOrdSepTerr	:= ''
	cOrdSepMeza	:= ''                  
	aLogOS		:= {}

	dbSelectArea("SC9")
	dbSetOrder(1)
	cArqInd   := CriaTrab(, .F.)
	cChaveInd := IndexKey()
	cCondicao := 'C9_PEDIDO = "'+cPedido+'" .And. Empty(C9_ORDSEP) .And. C9_QTDORI > 0'
	
	IndRegua("SC9", cArqInd, cChaveInd, , cCondicao, "Criando indice de trabalho" ) //"Criando indice de trabalho"
	
	nIndice := RetIndex("SC9") + 1
	
	#IFNDEF TOP
		dbSetIndex(cArqInd + OrdBagExt())
	#ENDIF
	
	dbSetOrder(nIndice)
	SC9->(MsSeek(xFilial("SC9")))
EndIf

_lCxFech := u_DpCxFACD(cPedido,.T.)

SC9->(dbGoTop())

While !SC9->(Eof())   
    If !lDireto
		If ! SC9->(IsMark("C9_OK",ThisMark(),ThisInv()))
			SC9->(DbSkip())
			IncProc()
			Loop
		EndIf
	EndIf
	
	If !Empty(SC9->(C9_BLEST+C9_BLCRED+C9_BLOQUEI))
		SC9->(DbSkip())
		IncProc()
		Loop
	EndIf
/*	
	//pesquisa se este item tem saldo a separar, caso tenha, nao gera ordem de separacao
	If CB8->(DbSeek(xFilial('CB8')+SC9->C9_PEDIDO+SC9->C9_ITEM+SC9->C9_SEQUEN+SC9->C9_PRODUTO)) .and. CB8->CB8_SALDOS > 0
		//Grava o historico das geracoes:
		aadd(aLogOS,{"2","Pedido",SC9->C9_PEDIDO,SC9->C9_CLIENTE,SC9->C9_LOJA,SC9->C9_ITEM,SC9->C9_PRODUTO,SC9->C9_LOCAL,"Existe saldo a separar deste item","NAO_GEROU_OS",SC9->C9_LOTECTL}) //"Pedido"###"Existe saldo a separar deste item"
		SC9->(DbSkip())
		IncProc()
		Loop
	EndIf
*/	
	If SC5->(DbSeek(xFilial('SC5')+SC9->C9_PEDIDO))
		cTransp := SC5->C5_TRANSP
	Else
		// neste caso a base tem sc9 e nao tem sc5, problema de incosistencia de base
		//Grava o historico das geracoes:
		aadd(aLogOS,{"2","Pedido",SC9->C9_PEDIDO,SC9->C9_CLIENTE,SC9->C9_LOJA,SC9->C9_ITEM,SC9->C9_PRODUTO,SC9->C9_LOCAL,"Inconsistencia de base (SC5 x SC9)","NAO_GEROU_OS",SC9->C9_LOTECTL}) //"Pedido"###"Inconsistencia de base (SC5 x SC9)"
		SC9->(DbSkip())
		IncProc()
		Loop
	EndIf
	If ! SC6->(DbSeek(xFilial("SC6")+SC9->C9_PEDIDO+SC9->C9_ITEM+SC9->C9_PRODUTO))
		// neste caso a base tem sc9,sc5 e nao tem sc6,, problema de incosistencia de base
		//Grava o historico das geracoes:
		aadd(aLogOS,{"2","Pedido",SC9->C9_PEDIDO,SC9->C9_CLIENTE,SC9->C9_LOJA,SC9->C9_ITEM,SC9->C9_PRODUTO,SC9->C9_LOCAL,"Inconsistencia de base (SC6 x SC9)","NAO_GEROU_OS",SC9->C9_LOTECTL}) //"Pedido"###"Inconsistencia de base (SC6 x SC9)"
		SC9->(DbSkip())
		IncProc()
		Loop
	EndIf
	
	If Localiza(SC9->C9_PRODUTO)
		If ! SDC->( dbSeek(xFilial("SDC")+SC9->C9_PRODUTO+SC9->C9_LOCAL+"SC6"+SC9->C9_PEDIDO+SC9->C9_ITEM+SC9->C9_SEQUEN))
			// neste caso nao existe composicao de empenho
			//Grava o historico das geracoes:
			aadd(aLogOS,{"2","Pedido",SC9->C9_PEDIDO,SC9->C9_CLIENTE,SC9->C9_LOJA,SC9->C9_ITEM,SC9->C9_PRODUTO,SC9->C9_LOCAL,"Nao existe composicao de empenho (SDC)","NAO_GEROU_OS",SC9->C9_LOTECTL}) //"Pedido"###"Nao existe composicao de empenho (SDC)"
			SC9->(DbSkip())
			IncProc()
			Loop
		EndIf
	EndIf
	
	//Inicia regra para gravar item CB8
	If Localiza(SC9->C9_PRODUTO)
		
		cPedido			:= SC9->C9_PEDIDO
		cCliente  		:= SC9->C9_CLIENTE
		cLoja			:= SC9->C9_LOJA
		cLocal			:= SC9->C9_LOCAL        
		cPrior			:= SC9->C9_PRIENTR
		
		While SDC->(! Eof() .and. DC_FILIAL+DC_PRODUTO+DC_LOCAL+DC_ORIGEM+DC_PEDIDO+DC_ITEM+DC_SEQ == xFilial("SDC")+SC9->(C9_PRODUTO+C9_LOCAL+"SC6"+C9_PEDIDO+C9_ITEM+C9_SEQUEN))
			
			SB1->(DBSetOrder(1))
			If SB1->(DbSeek(xFilial("SB1")+SDC->DC_PRODUTO)) .AND. Alltrim(SB1->B1_TIPO) == "MO"
				SDC->(DbSkip())
				Loop
			Endif
			               
			//Verifica regra do endereço T / M
			SBE->(DbSetOrder(1))	//BE_FILIAL+BE_LOCAL+BE_LOCALIZ
			If SBE->( dbSeek(xFilial("SBE")+SDC->DC_LOCAL+SDC->DC_LOCALIZ))
				//TERREO
				If SBE->BE_XPISO == 'T' .Or. cTransp$GetNewPar("ES_TRATERR","000235/000236") .Or. _lCxFech
					//gera OS para terreo
				   	If Empty(cOrdSepTerr)
						cOrdSepTerr :=  CB7->(GetSX8Num("CB7","CB7_ORDSEP")) //CB_SXESXF("CB7","CB7_ORDSEP",,1)
						ConfirmSX8()
					EndIf				
				
					aAdd(aTerreo, {xFilial("CB8"),SC9->C9_ITEM,SC9->C9_PEDIDO,SDC->DC_PRODUTO,SDC->DC_LOCAL,SDC->DC_QUANT,SDC->DC_LOCALIZ,SC9->C9_SEQUEN,SC9->C9_LOTECTL,cOrdSepTerr,SBE->BE_XCODRUA} )
					aadd(aRecSC91,{SC9->(Recno()),SC9->C9_PEDIDO,SDC->DC_PRODUTO,SC9->C9_LOTECTL,cOrdSepTerr}) //pega o recno do sc9 para depois gravar a OS no SC9
				//MEZANINO
				Else
					//gera OS para mezanino
				   	If Empty(cOrdSepMeza)
						cOrdSepMeza :=  CB7->(GetSX8Num("CB7","CB7_ORDSEP")) //CB_SXESXF("CB7","CB7_ORDSEP",,1)
						ConfirmSX8()
					EndIf								
				
					aAdd(aMezan, {xFilial("CB8"),SC9->C9_ITEM,SC9->C9_PEDIDO,SDC->DC_PRODUTO,SDC->DC_LOCAL,SDC->DC_QUANT,SDC->DC_LOCALIZ,SC9->C9_SEQUEN,SC9->C9_LOTECTL,cOrdSepMeza,SBE->BE_XCODRUA} )
					aadd(aRecSC92,{SC9->(Recno()),SC9->C9_PEDIDO,SDC->DC_PRODUTO,SC9->C9_LOTECTL,cOrdSepMeza}) //pega o recno do sc9 para depois gravar a OS no SC9
				EndIf
			EndIf
			
			SDC->( dbSkip() )
		EndDo
	EndiF
	
	IncProc()
	SC9->( dbSkip() )
EndDo
     
//Gera OS par ao Mezanino se necessario.
If Len(aMezan) > 0 .AND. len(aLogOS) == 0
	                
	BEGIN TRANSACTION
	/*
	cOrdSepMeza :=  CB7->(GetSX8Num("CB7","CB7_ORDSEP")) //CB_SXESXF("CB7","CB7_ORDSEP",,1)
	ConfirmSX8()
	*/
	
	CB7->(RecLock( "CB7",.T.))
	CB7->CB7_FILIAL := xFilial( "CB7" )
	CB7->CB7_ORDSEP := cOrdSepMeza
	CB7->CB7_PEDIDO := cPedido		//cPedido
	CB7->CB7_CLIENT := cCliente		//cCliente
	CB7->CB7_LOJA   := cLoja		//cLoja
	CB7->CB7_COND   := ""			//cCondPag
	CB7->CB7_LOJENT := ""			//cLojaEnt
	CB7->CB7_LOCAL  := cLocal		//cArm
	CB7->CB7_DTEMIS := dDataBase
	CB7->CB7_HREMIS := Time()
	CB7->CB7_STATUS := "0"
	CB7->CB7_CODOPE := ""
	CB7->CB7_PRIORI := "1"
	CB7->CB7_ORIGEM := "1"
	CB7->CB7_TIPEXP := "00*02*06*10*"//cTipExp
	CB7->CB7_TRANSP := SC5->C5_TRANSP		//SC5->C5_TRANSP
	CB7->CB7_AGREG  := ""					//cAgreg                 
	CB7->CB7_XTM	:= "M"				//OS. MEZANINO                 	
	CB7->CB7_XPRIOR := cPrior
		         
	If Len(aTerreo) > 0 .and. Len(aMezan) > 0
		CB7->CB7_XTOUM  := "T/M"
		cImpTpMez := "T/M (M)"
	ElseIf Len(aMezan) > 0
		CB7->CB7_XTOUM  := "M"	
		cImpTpMez := "M"
	Else
		CB7->CB7_XTOUM  := "T"			
	EndIf		
			
	CB7->(MsUnlock())
	
	nItem  := '00' 	  //intens do pedido
	For ix := 1 to len(aMezan)
		
		nItem   := Soma1(nItem)
		
		CB8->(RecLock("CB8",.T.))     
		CB8->CB8_FILIAL := xFilial("CB8")
		CB8->CB8_ORDSEP := cOrdSepMeza				//CB7->CB7_ORDSEP
		CB8->CB8_ITEM   := PADR(nItem,02)			//SC9->C9_ITEM
		CB8->CB8_PEDIDO := cPedido	   				//SC9->C9_PEDIDO
		CB8->CB8_PROD   := PADR(aMezan[ix,4],15)	//SDC->DC_PRODUTO
		CB8->CB8_LOCAL  := PADR(aMezan[ix,5],02)	//SDC->DC_LOCAL
		CB8->CB8_QTDORI := aMezan[ix,6]				//SDC->DC_QUANT
		CB8->CB8_SLDPRE := 0 						//SDC->DC_QUANT
		CB8->CB8_SALDOS := aMezan[ix,6]				//SDC->DC_QUANT
		CB8->CB8_SALDOE := aMezan[ix,6]				//0 //(aPalet[x,5]*aPalet[x,6])	//SDC->DC_QUANT
		CB8->CB8_LCALIZ := PADR(aMezan[ix,7],15)	//SDC->DC_LOCALIZ
		CB8->CB8_NUMSER := PADR("",20)				//SDC->DC_NUMSERI
		CB8->CB8_SEQUEN := aMezan[ix,8]				//SC9->C9_SEQUEN
		CB8->CB8_LOTECT := PADR(aMezan[ix,9],10)	//SC9->C9_LOTECTL
		CB8->CB8_NUMLOT := PADR("",06)				//SC9->C9_NUMLOTE
		CB8->CB8_CFLOTE := "1"						//If("10*" $ cTipExp,"1"," ")
		CB8->CB8_TIPSEP := ""						//If("09*" $ cTipExp,"1"," ")                                     
		//Mezanino não será alterado por enquanto.
		//CB8->CB8_XLCALI := aMezan[ix,11]+CB8->(SubStr(CB8_LCALIZ,4,2)+SubStr(CB8_LCALIZ,1,2)+SubStr(CB8_LCALIZ,7,2))
		CB8->CB8_XLCALI := CB8->CB8_LCALIZ
		CB8->(MsUnLock())
		
		//Atualizacao do controle do numero de itens a serem impressos
		RecLock("CB7",.F.)
		CB7->CB7_NUMITE++
		CB7->(MsUnLock())
     
	Next     
	END TRANSACTION
EndIf                  

//Gera OS para o Terreo se necessario.
If Len(aTerreo) > 0 .AND. len(aLogOS) == 0
	
	BEGIN TRANSACTION             
	/*
	cOrdSepTerr :=  CB7->(GetSX8Num("CB7","CB7_ORDSEP")) //CB_SXESXF("CB7","CB7_ORDSEP",,1)
	ConfirmSX8()
	*/
	
	CB7->(RecLock( "CB7",.T.))
	CB7->CB7_FILIAL := xFilial( "CB7" )
	CB7->CB7_ORDSEP := cOrdSepTerr
	CB7->CB7_PEDIDO := cPedido		//cPedido
	CB7->CB7_CLIENT := cCliente		//cCliente
	CB7->CB7_LOJA   := cLoja		//cLoja
	CB7->CB7_COND   := ""			//cCondPag
	CB7->CB7_LOJENT := ""			//cLojaEnt
	CB7->CB7_LOCAL  := cLocal		//cArm
	CB7->CB7_DTEMIS := dDataBase
	CB7->CB7_HREMIS := Time()
	CB7->CB7_STATUS := "0"
	CB7->CB7_CODOPE := ""
	CB7->CB7_PRIORI := "1"
	CB7->CB7_ORIGEM := "1"
	CB7->CB7_TIPEXP := "00*02*06*10*"//cTipExp
	CB7->CB7_TRANSP := SC5->C5_TRANSP		//SC5->C5_TRANSP
	CB7->CB7_AGREG  := ""					//cAgreg          
	CB7->CB7_XTM  	:= "T"					//OS. TERREO
	CB7->CB7_XPRIOR := cPrior
	
	If Len(aTerreo) > 0 .and. Len(aMezan) > 0
		CB7->CB7_XTOUM  := "T/M"
		cImpTpTer := "T/M (T)"
	ElseIf Len(aTerreo) > 0
		CB7->CB7_XTOUM  := "T"	
		cImpTpTer := "T"
	Else
		CB7->CB7_XTOUM  := "M"			
	EndIf				
	
	CB7->(MsUnlock())
	
	nItem  := '00' 	  //intens do pedido
	For ix := 1 to len(aTerreo)
			
		nItem   := Soma1(nItem)
		
		CB8->(RecLock("CB8",.T.))
		CB8->CB8_FILIAL := xFilial("CB8")
		CB8->CB8_ORDSEP := cOrdSepTerr		//CB7->CB7_ORDSEP
		CB8->CB8_ITEM   := nItem			//SC9->C9_ITEM
		CB8->CB8_PEDIDO := cPedido			//SC9->C9_PEDIDO
		CB8->CB8_PROD   := aTerreo[ix,4]	//SDC->DC_PRODUTO
		CB8->CB8_LOCAL  := aTerreo[ix,5]	//SDC->DC_LOCAL
		CB8->CB8_QTDORI := aTerreo[ix,6]	//SDC->DC_QUANT
		CB8->CB8_SLDPRE := 0 				//SDC->DC_QUANT
		CB8->CB8_SALDOS := aTerreo[ix,6]	//SDC->DC_QUANT
		CB8->CB8_SALDOE := aTerreo[ix,6]	//0 //(aPalet[x,5]*aPalet[x,6])	//SDC->DC_QUANT
		CB8->CB8_LCALIZ := aTerreo[ix,7]	//SDC->DC_LOCALIZ
		CB8->CB8_NUMSER := ""				//SDC->DC_NUMSERI
		CB8->CB8_SEQUEN := aTerreo[ix,8]	//SC9->C9_SEQUEN
		CB8->CB8_LOTECT := aTerreo[ix,9]	//SC9->C9_LOTECTL
		CB8->CB8_NUMLOT := ""				//SC9->C9_NUMLOTE
		CB8->CB8_CFLOTE := "1"				//If("10*" $ cTipExp,"1"," ")
		CB8->CB8_TIPSEP := ""				//If("09*" $ cTipExp,"1"," ")
		CB8->CB8_XLCALI := aTerreo[ix,11]+CB8->(SubStr(CB8_LCALIZ,4,2)+SubStr(CB8_LCALIZ,1,2)+SubStr(CB8_LCALIZ,7,2))
		CB8->(MsUnLock())
		
		//Atualizacao do controle do numero de itens a serem impressos
		RecLock("CB7",.F.)
		CB7->CB7_NUMITE++
		CB7->(MsUnLock())
		
	Next
	END TRANSACTION
EndIf

cTransp := SC5->C5_TRANSP
cMenDep := SC5->C5_MENDEP 
              
If !('DIPM010' $ FUNNAME())

	If !Empty(cOrdSepTerr) .or. !Empty(cOrdSepMeza)

		DEFINE MSDIALOG _oDlg TITLE "Confirmação da ordem de separação!" FROM 280,197 TO 433,551 PIXEL         
	
			@ 006,007 TO 070,172 PROMPT "Orden(s) de separação gerada(s) com sucesso !"  PIXEL OF _oDlg 	// Contorno Acima	
	
		//	@ 007,010 Say "Orden(s) de separação gerada(s) com sucesso !" 		Size 200,008 PIXEL OF _oDlg
			@ 025,010 Say " * Ordem Térreo:    "+ALLTRIM(cOrdSepTerr)  	Size 200,009 PIXEL OF _oDlg FONT oBold COLOR CLR_HBLUE
			@ 040,010 Say " * Ordem Mezanino:  "+ALLTRIM(cOrdSepMeza)  	Size 200,009 PIXEL OF _oDlg FONT oBold COLOR CLR_HBLUE
		
			@ 050,125 Button "Ok..." 		Size 037,012 PIXEL OF _oDlg Action( _oDlg:End() ) //007
			//@ 055,130 Button "Cancelar" 	Size 037,012 PIXEL OF _oDlg Action( _oDlg:End() )
		
		ACTIVATE MSDIALOG _oDlg CENTERED
		
	Endif
	
EndIf

If Len(aLogOS)==0     
	U_DipHistOS(Len(aTerreo)>0,Len(aMezan)>0,cPedido,IIf(Empty(cOrdSepTerr),cOrdSepMezan,cOrdSepTerr))	
									    
	If !Empty(cOrdSepTerr) .And. GetNewPar("ES_IMPORDT",.F.)
		CB5SetImp("000004",.T.)
		ImpEtiOS(cOrdSepTerr,cPedido,cTransp,IIf(cEmpAnt+cFilAnt=='0101','MTZ','CD'),cImpTpTer)
		MSCBCLOSEPRINTER() 
	EndIf
	
    If !Empty(cOrdSepMeza) .And. GetNewPar("ES_IMPORDM",.T.)
	    CB5SetImp("000003",.T.)
		ImpEtiOS(cOrdSepMeza,cPedido,cTransp,IIf(cEmpAnt+cFilAnt=='0101','MTZ','CD'),cImpTpMez)
		MSCBCLOSEPRINTER() 
	EndIf
EndIf  

	If (!Empty(cOrdSepTerr) .Or. !Empty(cOrdSepMeza)) .And. !Empty(cMenDep)
	
	 	U_AVCicMD()     
	
	EndIf
                                                   	
                                   
cOrdSepTerr := ""
cOrdSepMeza := ""      
cMenDep     := ""

SC5->(RecLock("SC5",.F.))
	SC5->C5_PRENOTA := 'S'
SC5->(MsUnlock())
                           
//Grava no sc9 a OS referente ao terreo                   
If Len(aRecSC91) > 0 .and. len(aLogOS) == 0             
	For nI := 1 to len(aRecSC91)
		SC9->(DbGoto(aRecSC91[nI,1]))
		SC9->(RecLock("SC9"))
		SC9->C9_ORDSEP := aRecSC91[nI,5]
		SC9->(MsUnlock())
	Next         
EndIf

//Grava no sc9 a OS referente ao mezanino
If Len(aRecSC92) > 0 .and. len(aLogOS) == 0             
	For nI := 1 to len(aRecSC92)
		SC9->(DbGoto(aRecSC92[nI,1]))
		SC9->(RecLock("SC9"))
		SC9->C9_ORDSEP := aRecSC92[nI,5]
		SC9->(MsUnlock())
	Next         
EndIf

//Bloqueia a separação do pedido se a separação estiver com problema            
If !(u_VldSepOK(SC5->C5_NUM))
    SC5->(RecLock("SC5",.F.))
    	SC5->C5_XBLQNF := "S"
    SC5->(MsUnLock())
EndIf

If !Empty(aLogOS)
	u_LogOsss()
Endif

Return

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
User Function AjustaSX1(cPerg)
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
Local aHelp	:= {}

PutSx1(cPerg, '01', 'Pedido    ?', '', '', 'mv_ch1', 'C',06, 0, 0, 'G', '', 'SC5', '', '', 'mv_par01', ''       , ''       , ''     , '', ''           , ''           , ''           ,'','','','','','','','','','','','')
//PutSx1(cPerg, '02', 'Lote      	?', '', '', 'mv_ch2', 'C',10, 0, 0, 'G', '', '   ', '', '', 'mv_par02', ''       , ''       , ''     , '', ''           , ''           , ''           ,'','','','','','','','','', '','','')

Return Nil

/*
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
*/

User Function LogOsss()
Local i, j, k
Local cChaveAtu, cPedCli, cOPAtual

//Cabecalho do Log de processamento:
AutoGRLog(Replicate("=",75))
AutoGRLog("                         I N F O R M A T I V O") //"                         I N F O R M A T I V O"
AutoGRLog("               H I S T O R I C O   D A S   G E R A C O E S") //"               H I S T O R I C O   D A S   G E R A C O E S"

//Detalhes do Log de processamento:
AutoGRLog(Replicate("=",75))
AutoGRLog("I T E N S   P R O C E S S A D O S :") //"I T E N S   P R O C E S S A D O S :"
AutoGRLog(Replicate("=",75))
If aLogOS[1,2] == "Pedido" //"Pedido"
	aLogOS := aSort(aLogOS,,,{|x,y| x[01]+x[10]+x[03]+x[04]+x[05]+x[06]+x[07]+x[08]<y[01]+y[10]+y[03]+y[04]+y[05]+y[06]+y[07]+y[08]})
	// Status Ord.Sep(1=Gerou;2=Nao Gerou) + Ordem Separacao + Pedido + Cliente + Loja + Item + Produto + Local
	cChaveAtu := ""
	cPedCli   := ""
	For i:=1 to len(aLogOs)
		If aLogOs[i,10] <> cChaveAtu .OR. (aLogOs[i,03]+aLogOs[i,04] <> cPedCli)
			If !Empty(cChaveAtu)
				AutoGRLog(Replicate("-",75))
			Endif
			j:=0
			k:=i  //Armazena o conteudo do contador do laco logico principal (i) pois o "For" j altera o valor de i;
			cChaveAtu := aLogOs[i,10]
			For j:=k to len(aLogOs)
				If aLogOs[j,10] <> cChaveAtu
					Exit
				Endif
				If Empty(aLogOs[j,08]) //Aglutina Armazem
					AutoGRLog("Pedido: "+aLogOs[j,03]+" - Cliente: "+aLogOs[j,04]+"-"+aLogOs[j,05]) //"Pedido: "###" - Cliente: "
				Else
					AutoGRLog("Pedido: "+aLogOs[j,03]+" - Cliente: "+aLogOs[j,04]+"-"+aLogOs[j,05]+" - Local: "+aLogOs[j,08]) //"Pedido: "###" - Cliente: "###" - Local: "
				Endif
				cPedCli := aLogOs[j,03]+aLogOs[j,04]
				If aLogOs[j,10] == "NAO_GEROU_OS"
					Exit
				Endif
				i:=j
			Next
			AutoGRLog("Ordem de Separacao: "+If(aLogOs[i,01]=="1",aLogOs[i,10],"N A O  G E R A D A")) //"Ordem de Separacao: "###"N A O  G E R A D A"
			If aLogOs[i,01] == "2"  //Ordem Sep. NAO gerada
				AutoGRLog("Motivo: ") //"Motivo: "
			Endif
		Endif
		If aLogOs[i,01] == "2"  //Ordem Sep. NAO gerada
			AutoGRLog("Item: "+aLogOs[i,06]+" - Produto: "+AllTrim(aLogOs[i,07])+" - Lote: "+aLogOs[i,11]+" - Local: "+aLogOs[i,08]+" ---> "+aLogOs[i,09]) //"Item: "###" - Produto: "###" - Local: "
		Endif
	Next
Endif
MostraErro()    

Return       

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
User Function ACDA100(cAlias,nReg,nOpcx)

Local oDlg
Local oGet
Local aPos     := { 15, 1, 57, 315 }
Local cSeekCB8 := xFilial("CB8") + CB7->CB7_ORDSEP
Local nI
Local cItem
Local cSequen
Local cProd
Local nOpca := 0
Local cOP
Local lContinua := .T.

Local aSize     := {}
Local aInfo     := {}
Local aObjects  := {}
Local aObj      := {}

Private Altera  := .F.
Private Inclui  := .F.
Private aHeader := {}
Private aCols   := {}
Private aTela   := {},aGets := {}

CB8->(DbSetOrder(1)) // Forca a utilizacao do indice de ordem 1, pois o programa estava se perdendo (by Erike)
CB9->(DbSetOrder(1))
If CB7->CB7_STATUS # "0" .and. Empty(CB7->CB7_STATPA)
	MsgAlert("Esta Ordem de separacao nao pode ser estornada pois a mesma esta sendo executada neste momento","Aviso") //"Esta Ordem de separacao nao pode ser estornada pois a mesma esta sendo executada neste momento"###"Aviso"
	Return
ElseIf CB7->CB7_STATUS # "0" .and. CB9->(DbSeek(xFilial("CB9")+CB7->CB7_ORDSEP))
	MsgAlert( "A Ordem de Separacao nao pode ter nenhuma movimentacao para ser estornada.", "Aviso" ) //"A Ordem de Separacao nao pode ter nenhuma movimentacao para ser estornada."###"Aviso"
	Return
EndIf
                                                    
If !Empty(CB7->CB7_NOTA) 
	MsgAlert("Ordem de separação ja foi faturada! Não será possivel estorna-la!", "Aviso" ) //"A Ordem de Separacao nao pode ter nenhuma movimentacao para ser estornada."###"Aviso"
	Return
End
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se existe algum dado no arquivo de Itens            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If ! CB8->( dbSeek( cSeekCB8 ) )
	Return .T.
EndIf

RegToMemory("CB7")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta o cabecalho                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

dbSelectArea("SX3")
dbSeek( "CB8" )
While !Eof() .And. ( x3_arquivo == "CB8" )
	If X3USO(x3_usado) .And. cNivel >= x3_nivel .And. AllTrim( x3_campo ) <> "CB8_ORDSEP"
		AAdd(aHeader,{ TRIM(x3_titulo), x3_campo, x3_picture,;
		x3_tamanho, x3_decimal, x3_valid,;
		x3_usado, x3_tipo, x3_arquivo, x3_context } )
	EndIf
	dbSkip()
EndDo

U_MonCols(cSeekCB8)

aSize   := MsAdvSize()
aAdd(aObjects, {100, 130, .T., .F.})
aAdd(aObjects, {100, 200, .T., .T.})
aInfo   := {aSize[1], aSize[2], aSize[3], aSize[4], 2, 2}
aPosObj := MsObjSize(aInfo, aObjects)

If CB7->CB7_ORIGEM <> "3" //Não alterar funcionalidade já existente para empresa 01 - (desnecessario para empresa 04)

	DEFINE MSDIALOG oDlg TITLE OemToAnsi("Ordens de separacao - Estorno") From aSize[7],0 to aSize[6],aSize[5] OF oMainWnd PIXEL //"Ordens de separacao - Estorno"
	oEnc:=MsMget():New(cAlias,nReg,nOpcx,,,,,{aPosObj[1,1],aPosObj[1,2],aPosObj[1,3],aPosObj[1,4]},,3,,,,,,.t.)
	oGet:=MSGetDados():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,3],aPosObj[2,4], nOpcx,"AllWaysTrue","AllWaysTrue", ,.F.)
	
	
	DEFINE TIMER oTimer INTERVAL 1000 ACTION U_MonCols(cSeekCB8,oGet) OF oDlg
	oTimer:Activate()
	
	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||nOpca:=1,oDlg:End()},{||oDlg:End()})

	dbSelectArea( cAlias )
	
	If nOpca == 1
		
		Begin Transaction
	
	//	SC9->(DbSetOrder(1))
		CB8->(DbSetOrder(1))
		
		DbSelectArea("CB7")
		ZZ5->(dbSetOrder(1))
		For nI := 1 to Len(aCols)
			CB8->(DbGoto(aRecno[nI]))
	
			If CB7->CB7_ORIGEM == "1"  
	
				DbSelectArea("SC9")		
	//			DbSetOrder(1)     //filial+pedido+ordem separação+produto+lote
				DBOrderNickname("SC9_I")
				If dbSeek(xFilial("SC9")+aCols[nI][3]+CB7->CB7_ORDSEP+aCols[nI][4]+aCols[nI][11]) //			If dbSeek( xFilial("SC9")+CB8->CB8_PEDIDO+CB8->CB8_ITEM+CB8->CB8_SEQUEN+CB8->CB8_PROD)
					If ! Empty(SC9->C9_ORDSEP)
						SC9->(RecLock("SC9",.F.))
						SC9->C9_ORDSEP := ""
						SC9->(MsUnlock())
					Endif
				EndIf
		
			EndIf
			
			//Excluir quando for ordem de producao 
			If CB7->CB7_ORIGEM == "3"
			
				dbSelectArea("SC2")
				dbSetOrder(1)
				
				If MsSeek(xFilial("SC2")+Substr(CB8->CB8_OP,1,6) )
					
					While SC2->(!Eof) .And. SC2->C2_NUM == Substr(CB8->CB8_OP,1,6)
					
						If Alltrim(SC2->C2_ORDSEP)  == Alltrim(CB7->CB7_ORDSEP)
							SC2->(RecLock("SC2",.F.))
							SC2->C2_ORDSEP := ""
							SC2->(MsUnLock())
						Endif
					
						SC2->(dbSkip())
					EndDo
									
				EndIf
				
			EndIf
			
			CB8->(RecLock( "CB8",.F.))
			CB8->(dbDelete())
			CB8->(MsUnLock())             
			
			If ZZ5->(dbSeek(xFilial("ZZ5")+CB7->(CB7_PEDIDO+CB7_ORDSEP)))
				ZZ5->(RecLock("ZZ5",.F.))
					ZZ5->(dbDelete())
				ZZ5->(MsUnLock())
			EndIf
			
			ZZ8->(dbSetOrder(1))
			If ZZ8->(dbSeek(xFilial("ZZ8")+CB7->CB7_XREQMT))
				ZZ8->(RecLock("ZZ8",.F.))
					ZZ8->ZZ8_XSTCB7 := ""
					ZZ8->ZZ8_XORSEP := ""
					ZZ8->ZZ8_XEXPED := ""				 
				ZZ8->(MsUnlock())
			EndIf
		Next nI
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Exclui linha da tabela CB7 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
		CB7->(RecLock("CB7", .F.))
		CB7->(dbDelete())
		CB7->(MsUnlock())  
	
		End Transaction
	
	EndIf

EndIf
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³MonCols ³ Autor ³ Eduardo Motta         ³ Data ³ 06/04/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Funcao para montagem do aCols na GetDados                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cSeekCB8 -> Chave de pesquisa no CB8                       ³±±
±±³          ³ oGet     -> objeto getdados a dar refresh (opcional)       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T.                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGAACD                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function MonCols(cSeekCB8,oGet)
Local nCnt,nUsado

If Type("oTimer") == "O"
	oTimer:Deactivate()
EndIf

aCols := {}
aRecno:={}

nCnt := 0
CB8->(DbSetOrder(1))
CB8->( dbSeek( cSeekCB8 ) )
While !CB8->( Eof() ) .And. cSeekCB8 == CB8->CB8_FILIAL + CB8->CB8_ORDSEP

	nCnt++
	nUsado := 0
	aadd(aCols,Array(Len(aHeader)+1))
	aadd(aRecno,CB8->(Recno()))
	dbSelectArea("SX3")
	dbSeek( "CB8" )

	While !Eof() .And. SX3->x3_arquivo == "CB8"
		If X3USO(SX3->x3_usado) .And. cNivel >= SX3->x3_nivel .And. AllTrim( SX3->x3_campo ) <> "CB8_ORDSEP" .And.;
																AllTrim( SX3->x3_campo ) <> "CB8_CLIENT" .And.;
																AllTrim( SX3->x3_campo ) <> "CB8_PEDIDO"
																
			nUsado++
			If SX3->x3_context # "V"
				cField := SX3->X3_CAMPO
				dbSelectArea("CB8")
				aCols[ nCnt, nUsado ] := FieldGet( FieldPos( cField ) )
				dbSelectArea("SX3")
			/*ElseIf x3_context == "V"
			
				alert(SX3->x3_campo)
				
				aCols[ nCnt, nUsado ] := CriaVar( AllTrim( SX3->x3_campo ) )
				// Processa Gatilhos
				EvalTrigger()*/
			Endif
		Endif

		aCols[ nCnt, nUsado + 1 ] := .f.

		dbSelectArea("SX3")
		dbSkip()

	EndDo

	dbSelectArea( "CB8" )
	dbSkip()

EndDo
If oGet # Nil
	oGet:oBrowse:Refresh()
EndIf
If Type("oTimer") = "O"
	oTimer:Activate()
EndIf                

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ORDSEP11  ºAutor  ³Microsiga           º Data ³  12/17/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Rotina reservada para implementar o novo modelo de estorno º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function DIPESTOS(cAlias,nReg,nOpcx)               

dbSelectArea("SC7") 
Return U_ACDA100(cAlias,nReg,nOpcx)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ORDSEP11  ºAutor  ³Microsiga           º Data ³  04/26/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function DIPAltPri()
Local oDlg
Local nOpca		:= 0
Local cPrior	:= Space(1)
Local aButtons	:= {}
Local cCadastro := "Alt. Prioridade"

Define msDialog oDlg title cCadastro from 0,0 to 100,350 pixel

@ 020, 010 say "Prioridade"	size 070,08 pixel of odlg
@ 019, 080 get cPrior 	    size 030,10 pixel of odlg

Activate msDialog odlg Center on Init;
Enchoicebar(oDlg, {|| nopca := 1,oDlg:end()},{|| nopca := 0,oDlg:end()},,abuttons)

If nOpca = 1	
	CB7->(RecLock("CB7",.F.))
		CB7->CB7_XPRIOR := cPrior	
	CB7->(MsUnLock())
EndIf

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ORDSEP11  ºAutor  ³Microsiga           º Data ³  04/30/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±                               DDDD
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ImpEtiOS(cOrdSep,cPedido,cTransp,cDipEmp,cImpTp)
DEFAULT cOrdSep := ""
DEFAULT cPedido := ""
DEFAULT cTransp := ""
DEFAULT cDipEmp := ""
DEFAULT cImpTp	:= ""

MSCBInfoEti("OS: "+cOrdSep,"VOLUME")       	      

MSCBBEGIN(1,4)      

MSCBSAY(03,04,'ORDEM DE SEP.: '					,"N", "C", "25")
MSCBSAY(03,10,alltrim(cOrdSep)					,"N", "C", "80")

MSCBLineV(50/*x*/,03/*y*/,20/*y*/,3)

MSCBSAY(53,04,'PEDIDO: '						,"N", "C", "25")
MSCBSAY(53,10,alltrim(cPedido)					,"N", "C", "80")

MSCBLineH(03/*x*/,20/*y*/,97/*x*/,3)

MSCBSAY(03,25,'Filial: '+cDipEmp+" "+cImpTp 	,"N", "C", "30")
MSCBSAY(53,25,'Transp.: '+cTransp				,"N", "C", "30")

MSCBEND()    
	
Return


/*------------------------------------------------------------------------+
+ RBORGES - 13/08/2014 ----- User Funcion: AVCicMD()                      +                                                     
+ Fará o tratamento para enviar CIC de aviso de dos pedidos               +
+ com mensagem para depósito.							                  +
-------------------------------------------------------------------------*/

*--------------------------------------------------------------------------*
	User Function AVCicMD()
*--------------------------------------------------------------------------*
	
	Local aArea       := GetArea()
	Local cDeIc       := "protheus@dipromed.com.br"
    Local cCICDest    := Upper(GetNewPar("ES_CIC_MD","REGINALDO.BORGES")) // Usuários que receberão CIC´s
	Local cAttachIc   :=  "  a"
	Local cFuncSentIc :=   "ORDSEP11.PRW "
 	
		dbSelectArea("SM0")
		
	_aMsgIc := {}
    cMSGcIC       := 'ATENÇÃO! PEDIDO DE VENDAS,'+SC5->C5_NUM+', TEM MENSAGEM PARA DEPÓSITO. ' +CHR(13)+CHR(10)+CHR(13)+CHR(10)
	cMSGcIC       += " MENS.DEP.: " + SC5->C5_MENDEP +CHR(13)+CHR(10)+CHR(13)+CHR(10)
	cMSGcIC       += " EMPRESA:__ " + Capital( AllTrim( GetAdvFVal( "SM0", "M0_NOME", cEmpAnt + cFilAnt, 1, "" ) ) ) +"/"+ Capital( AllTrim( GetAdvFVal( "SM0", "M0_FILIAL" , cEmpAnt + cFilAnt, 1, "" ) ) )   +CHR(13)+CHR(10)														
  	cMSGcIC       += " PEDIDO:____ " + SC5->C5_NUM +CHR(13)+CHR(10)
	cMSGcIC       += " CLIENTE:___  " + SC5->C5_CLIENTE+" - "+Posicione("SA1",1,XFILIAL("SA1")+SC5->C5_CLIENTE,'A1_NREDUZ') +CHR(13)+CHR(10)
	cMSGcIC       += " OPERADOR:-  " + SC5->C5_OPERADO+" - "+Posicione("SU7",1,xFilial("SU7")+SC5->C5_OPERADO,"U7_NREDUZ")   +CHR(13)+CHR(10)
	cMSGcIC       += " TRANSP.:___ " + SC5->C5_TRANSP+ " - " + AllTrim(FDesc("SA4",SC5->C5_TRANSP,"SA4->A4_NREDUZ"))        +CHR(13)+CHR(10)

   	
   	U_DIPCIC(cMSGcIC,cCICDest)
   	  	
	
    RestArea(aArea)	
	return() 
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ORDSEP11  ºAutor  ³Microsiga           º Data ³  04/16/15   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function VldSepOK(cPedido)
Local cSQL 		:= ""
Local aMsg 	 	:= {}     
Local cFrom 	:= "protheus@dipromed.com.br"                                                
Local cFuncSent := "VldSepOK(ORDSEP11)"
Local cMsgCic   := ""
Local cAssunto	:= EncodeUTF8("PROBLEMA NA SEPARAÇÃO","cp1252")
Local cEnd 		:= CHR(13)+CHR(10)
Local lRetBlq   := .T.
DEFAULT cPedido := ""
                
cSQL := " SELECT "
cSQL += " 	* "
cSQL += " 	FROM "
cSQL += 		RetSQlName("SC9")
cSQL += " 		WHERE "
cSQL += " 			C9_FILIAL  = '"+xFilial("SC9")+"' AND "
cSQL += " 			C9_PEDIDO  = '"+cPedido+"' AND "
cSQL += " 			C9_NFISCAL = ' ' AND "
cSQL += " 			C9_ORDSEP  = ' ' AND "
cSQL += " 			C9_QTDORI  > 0 	 AND "
cSQL += " 			D_E_L_E_T_ = ' ' "

cSQL := ChangeQuery(cSQL)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),"VLDSC9",.T.,.T.)

If !VLDSC9->(Eof())     

    lRetBlq := .F.

	Aviso("Atenção","Separação com problema."+cEnd+"Não proseguir com o processo."+cEnd+"Avise o TI.",{"Ok"},1)
	
	cMsgCic += "ATENÇÃO!!!"+cEnd
	cMsgCic += "SEPARAÇÃO COM PROBLEMA - PEDIDO: "+cPedido+cEnd
	cMsgCic += cEnd
	cMsgCic += "Usuário: "+U_DipUsr()
	
	Aadd(aMsg,{"Pedido:    ",cPedido})
	Aadd(aMsg,{"Usuário:   ",U_DipUsr()})		
			        
	U_DIPCIC(cMsgCic,GetNewPar("ES_CICORDS","DIEGO.DOMINGOS"))
	U_UEnvMail(GetNewPar("ES_MAIORDS","diego.domingos@dipromed.com.br"),cAssunto,aMsg,"",cFrom,cFuncSent)
	
EndIf
VLDSC9->(dbCloseArea())

Return(lRetBlq)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ACD167OS  ºAutor  ³Microsiga           º Data ³  05/31/17   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function DpCxFACD(cPedido,lCIC)  
Local cSQL  := ""         
Local lRet  := .T.
Local aArea :=  GetArea()                           

DEFAULT cPedido  := ""                         
DEFAULT lCIC     := .F.

/*
If cEmpAnt=="04"
	Return .F.
EndIf
*/

cSQL := " SELECT "     
cSQL += "  	DC_PRODUTO, DC_LOTECTL, "
cSQL += "  	SUM(DC_QUANT) DC_QTD, "
cSQL += "	CASE WHEN B1_XTPEMBC='3' THEN B1_XQTDEMB ELSE "
cSQL += "	(CASE WHEN B1_XTPEMBC='2' THEN B1_XQTDSEC ELSE "
cSQL += "	(CASE WHEN B1_XTPEMBC='1' THEN 1 ELSE 0 END) END) END B1_QTD "
cSQL += " 	FROM "
cSQL +=  		RetSQLName("SDC")+" WITH(NOLOCK) "
cSQL += " 		INNER JOIN "
cSQL +=  			RetSQLName("SB1")+" WITH(NOLOCK) "
cSQL += " 			ON "
cSQL += " 				B1_FILIAL = DC_FILIAL AND "
cSQL += " 				B1_COD = DC_PRODUTO AND "  
cSQL +=  				RetSQLName("SB1")+".D_E_L_E_T_ = ' ' "
cSQL += " 		WHERE "                       
cSQL += " 	   		DC_FILIAL = '"+xFilial("CB8")+"' AND "
cSQL += " 			DC_PEDIDO = '"+cPedido+"' AND "
cSQL +=  			RetSQLName("SDC")+".D_E_L_E_T_  = ' ' "
cSQL += " GROUP BY DC_PRODUTO, DC_LOTECTL, B1_XTPEMBC, B1_XQTDEMB, B1_XQTDSEC "

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),"SB1SDC",.T.,.T.)

While !SB1SDC->(Eof()) .And. lRet
	If SB1SDC->B1_QTD==0 //Fracionado
		lRet := .F.
	ElseIf Mod(SB1SDC->DC_QTD,SB1SDC->B1_QTD)<>0
		lRet := .F.
	EndIf          
	SB1SDC->(dbSkip())
EndDo
SB1SDC->(dbCloseArea())
           
If lRet .And. lCIC
	U_DIPCIC("Pedido 100% caixa fechada: "+cPedido,"DIEGO.DOMINGOS,EDVAN.MATIAS")//envia cic
EndIf

RestArea(aArea)

Return lRet
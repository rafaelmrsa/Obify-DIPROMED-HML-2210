#include "rwmake.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Fun‡…o    ³ DIPA015 ³ Autor ³    Rodrigo Franco      ³ Data ³ 04.03.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Mostra posicao do pedidos de venda.                        ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
±±³Retirada analise de crédito customizada 								  ³±±
±±³Fernando R. Assunção - 08/06/06										  ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function DIPA015()
//³ Define Variaveis
Local aArea     := GetArea()
Local cCondicao 
Local _aRadio   
Local aIndSC9
Local oTempTable

U_DIPPROC(ProcName(0),U_DipUsr()) // JBS 05/10/2005 - Gravando o nome do Programa no SZU
xBotaoSai       := .T.
_stru           := {}
_aTrb           := {}
_cCodPro        := "      "
_aCamp          := {}
_cFlag          := "o"
_cIndex         := ""
_cChave         := ""
_cAlias         := ""
_cNesc          := ""
cArq            := ""
aCampos         := {}
_cFla           := 0
_par01          := Space(6)
_par02          := "ZZZZZZ"
_par03          := Space(6)
_par04          := "ZZZZZZ"
_par05          := Space(6)
_par06          := "ZZZZZZ"
_par07          := Space(6)
_par08          := "ZZZZZZ"
_par09          := Space(6)
_par10          := "ZZZZZZ"
_par11          := Space(6)
_par12          := "ZZZZZZ"
_loj1           := _loj2 := _loj3 := _loj4 := Space(2)
_cCombo         := "Pendente"
_aItems         := {"Pendente","Atendida"}
_cDatRec        := dDatabase
_cHorRec        := time()
aCols           := {}
aHeader         := {}
_nRadio         := 1
_cDatBac        := CTOD("  /  /  ")
_cNomBro        := SPACE(40)
_cZonBro        := SPACE(1)
cString         := ''
_cTexto         := ""
_cDivBro        := SPACE(6)
_nUsado         := 0
_nPosCod        := ""
_nPosDes        := ""
_nPosQua        := ""
aIndSC9         := {}
_nRecRb         := 0
_nVlrTot        := 0
cCondicao := ""
_aRadio   := {"Todos","Liberados","Faturados","Bloqueados por Credito",;
"Bloqueados Parcialmente","Com Saldos a Liberar","Bloqueados por Estoque"}
aIndSC9   := {}
Private bFiltraBrw := {|| Nil}
Private aRotina := { { 'Pesquisa','PesqBrw', 0 , 1},;		 	      //Pesquisa
{ 'Reavalia Pedido','A455LIBAUT', 0 , 2},;         			      //Reavaliacao do pedido
{ 'Legenda','BrwLegenda(cCadastro,"Legenda",_aCoresLeg)', 0 , 3}}    //Legenda

CriaTemp()
CriaTem2()
@ 0,0 To 480,780 Dialog oDlg1 Title OemToAnsi("Saldos")
xBotaoSai := .T.           
@ 007,005 RADIO _aRadio VAR _nRadio //Valid Back()
@ 007,087 say "Do Vendedor"
@ 007,127 say "Do Operador"
@ 007,167 say "Do Fornecedor"
@ 007,225 say "Do Produto"
@ 007,265 say "Do Cliente"
@ 007,323 say "Do Pedido"
@ 016,087 Get _par01 F3 "SA3"    
@ 016,127 Get _par03 F3 "SU7"   
@ 016,167 Get _par05 F3 "SA2" 
@ 016,197 Get _loj3  Picture "@!" When .F. SIZE 10,05
@ 016,225 Get _par07 F3 "SB1"
@ 016,265 Get _par09 F3 "SA1"
@ 016,297 Get _loj1  Picture "@!" When .F. SIZE 10,05
@ 016,323 Get _par11
@ 033,087 say "Ate o Vendedor"
@ 033,127 say "Ate o Operador"
@ 033,167 say "Ate o Fornecedor"  
@ 033,225 say "Ate o Produto"
@ 033,265 say "Ate o Cliente"
@ 033,323 say "Ate o Pedido"
@ 042,087 Get _par02 F3 "SA3"
@ 042,127 Get _par04 F3 "SU7"
@ 042,167 Get _par06 F3 "SA2" 
@ 042,197 Get _loj4  Picture "@!" When .F. SIZE 15,10
@ 042,225 Get _par08 F3 "SB1"
@ 042,265 Get _par10 F3 "SA1"
@ 042,297 Get _loj2  Picture "@!" When .F. SIZE 15,10
@ 042,323 Get _par12 
@ 055,087 BUTTON "_1 Repete" SIZE 28,10 ACTION (Rept(1),oDlg1:End()) // JBS 14/02/2006   
@ 055,127 BUTTON "_2 Repete" SIZE 28,10 ACTION (Rept(2),oDlg1:End()) // JBS 14/02/2006   
@ 055,177 BUTTON "_3 Repete" SIZE 28,10 ACTION (Rept(3),oDlg1:End()) // JBS 14/02/2006   
@ 055,225 BUTTON "_4 Repete" SIZE 28,10 ACTION (Rept(4),oDlg1:End()) // JBS 14/02/2006   
@ 055,275 BUTTON "_5 Repete" SIZE 28,10 ACTION (Rept(5),oDlg1:End()) // JBS 14/02/2006   
@ 055,323 BUTTON "_6 Repete" SIZE 28,10 ACTION (Rept(6),oDlg1:End()) // JBS 14/02/2006   
@ 055,365 BUTTON "_Todos"    SIZE 22,10 ACTION (Rept(7),oDlg1:End()) // JBS 14/02/2006   
@ 070,005 BUTTON "_Atualizar Informacoes" SIZE 55,10 ACTION (Analizar(),oDlg1:End()) // JBS 14/02/2006       
@ 070,117 BUTTON "_Caract. Produto" SIZE 45,10 ACTION (U_DIPA004("SLDTMP",.F.),oDlg1:End()) // JBS 14/02/2006       
@ 070,229 BUTTON "_Visualiza Pedido" SIZE 45,10 ACTION (VerPed(),oDlg1:End()) // JBS 14/02/2006       
@ 070,335 BUTTON "_Bloqueia Parcial" SIZE 50,10 ACTION (GrvParcial(),,oDlg1:End()) // JBS 14/02/2006        
@ 001,003 To 067,389
@ 001,003 To 240,389
@ 085,008 TO 220,383 BROWSE "TRB" FIELDS _aTrb Object oBro                
@ 223,355 BmpButton Type 1 Action (OK(),Close(oDlg1))
@ 225,008 say "Valor Total da Pesquisa: "
@ 225,080 Get _nVlrTot Picture "@E 9,999,999,999.9999" When .F. SIZE 75,10
Activate Dialog oDlg1 Center

RestArea(aArea)
Return

********************
Static Function Analizar()

dbSelectArea("SC9")
RetIndex("SC9")
dbClearFilter()
aEval(aIndSc9,{|x| Ferase(x[1]+OrdBagExt())})
aIndSC9   := {}
dbSelectArea("SC9")
dbSetOrder(1)

//³ Inicializa variavel com a condicao padrao do Filtro, ou quando Mv_par01=="1". ³
cCondicao := "C9_FILIAL=='"+xFilial("SC9")+"' "

IF _nRadio == 2

	//³ Somente Itens Liberados									     ³
	cCondicao += ".AND. C9_BLEST=='  ' .And. C9_BLCRED2=='  '.AND. SC9->C9_PARCIAL==' ' "
ElseIF _nRadio == 3

	//³ Somente Itens Faturados									     ³
	cCondicao += ".AND. SC9->C9_BLCRED=='10'.And.SC9->C9_BLEST=='10' "
ElseIF _nRadio == 4

	//³ Somente Itens Bloqueados por Credito					     ³
	cCondicao += ".AND. SC9->C9_BLCRED2=='01'.And.SC9->C9_BLCRED<>'10'"
ElseIF _nRadio == 5

	//³ Somente Itens Bloqueados Parcialmente					     ³
	cCondicao += ".AND. SC9->C9_PARCIAL=='N' "
ElseIF _nRadio == 6

	//³ Somente Itens com Saldo a Liberar						     ³
	cCondicao := "U_USALDSB2()> 0 .And. SC9->C9_SALDO > 0 "
	cCondicao += ".AND. C9_BLEST<>'  '.And.C9_BLEST<>'10'"
ElseIF _nRadio == 7

	//³ Somente Itens com Bloqueados por Estoque     			     ³
	cCondicao += ".AND. SC9->C9_BLEST=='02' .AND. SC9->C9_SALDO == 0 .AND. SC9->C9_PARCIAL==' '"
EndIF

//³ Variaveis para o complemento do Filtro, ou quando Mv_par01=="1" ³
cCondicao += ".AND. SC9->C9_VEND    >= '"+_par01+"' .And. SC9->C9_VEND    <= '"+_par02+"'"
cCondicao += ".AND. SC9->C9_OPERADO >= '"+_par03+"' .And. SC9->C9_OPERADO <= '"+_par04+"'" 
cCondicao += ".AND. SC9->C9_FORNEC  >= '"+_par05+"' .And. SC9->C9_FORNEC  <= '"+_par06+"'"
cCondicao += ".And. SC9->C9_PRODUTO >= '"+_par07+"' .And. SC9->C9_PRODUTO <= '"+_par08+"'"
cCondicao += ".AND. SC9->C9_CLIENTE >= '"+_par09+"' .And. SC9->C9_CLIENTE <= '"+_par10+"'"
cCondicao += ".AND. SC9->C9_PEDIDO  >= '"+_par11+"' .And. SC9->C9_PEDIDO  <= '"+_par12+"'"
bFiltraBrw := {|| FilBrowse("SC9",@aIndSC9,@cCondicao) }
Eval(bFiltraBrw)

//³ Endereca a funcao de BROWSE                                  ³
_nVlrTot := 0
IF ( Eof() )
	MsgInfo("Nao há Informações para esta consulta")
	DBSELECTAREA("TRB")
	DBCLOSEAREA()
	FERASE(cArq+".DBF")
	FERASE(_cIndex+ordbagext())
	CriaTemp()
	CriaTem2()
	oBro:oBrowse:Refresh()
Else
	If _nRecRb == 1
		DBSELECTAREA("TRB")
		DBCLOSEAREA()
		FERASE(cArq+".DBF")
		FERASE(_cIndex+ordbagext())
		CriaTemp()
		CriaTem2()
	Endif
	dbSelectArea("SC9")
	While !Eof()
		DbSelectArea("SA1")
		DbSetOrder(1)
		DbSeek(xFilial("SA1")+SC9->C9_CLIENTE+SC9->C9_LOJA)
		_cNomeCli := SUBSTR(SA1->A1_NOME,1,30)
		DbSelectArea("SB1")
		DbSetOrder(1)
		DbSeek(xFilial("SB1")+SC9->C9_PRODUTO)
		_cDescPro := SUBSTR(SB1->B1_DESC,1,30)
		DBSELECTAREA("TRB")
		RECLOCK("TRB",.T.)
		TRB->RB_STATUS   := U_STATUSC9()
		TRB->RB_PEDIDO   := SC9->C9_PEDIDO
		TRB->RB_ITEM     := SC9->C9_ITEM
		TRB->RB_SEQUEN   := SC9->C9_SEQUEN
		TRB->RB_CLIENTE  := SC9->C9_CLIENTE
		TRB->RB_NOMECLI  := _cNomeCli
		TRB->RB_PARCIAL  := SC9->C9_PARCIAL
		TRB->RB_PRODUTO  := SC9->C9_PRODUTO
		TRB->RB_DESCPRO  := _cDescPro
		TRB->RB_QTDVEN   := SC9->C9_QTDVEN
		TRB->RB_QTDORI   := SC9->C9_QTDORI
		TRB->RB_SALDO    := SC9->C9_SALDO
		TRB->RB_QATU     := U_USALDSB2()
		TRB->RB_OPERADO  := SC9->C9_OPERADO
		TRB->RB_NFISCAL  := SC9->C9_NFISCAL
		TRB->RB_SERIENF  := SC9->C9_SERIENF
		TRB->RB_DATALIB  := SC9->C9_DATALIB
		TRB->RB_PRCVEN   := SC9->C9_PRCVEN
		TRB->RB_LOTECTL  := SC9->C9_LOTECTL
		TRB->RB_NUMLOTE  := SC9->C9_NUMLOTE
		TRB->RB_DTVALID  := SC9->C9_DTVALID
		TRB->RB_LOCAL    := SC9->C9_LOCAL
		TRB->RB_VEND     := SC9->C9_VEND  
		TRB->RB_FORNEC   := SC9->C9_FORNEC
		MSUNLOCK()
		_nRecRb := 1 		
		_nVlrTot := _nVlrTot + (SC9->C9_PRCVEN)
		dbSelectArea("SC9")
		DbSkip()
	END	
	_cIndex:=Criatrab(Nil,.F.)
	_cChave:="RB_PEDIDO+RB_ITEM+RB_SEQUEN"
	Indregua("TRB",_cIndex,_cchave,,,"Selecionando Registros...")
	dBSETINDEX(_cIndex+ordbagext())
	oBro:oBrowse:Refresh()
EndIF

//³Restaura a integridade da rotina                                ³
Return
************************

************************
Static Function CriaTemp()

_stru:={}
AADD(_stru,{"RB_STATUS","C",15,0})
AADD(_stru,{"RB_PEDIDO","C",06,0})
AADD(_stru,{"RB_ITEM","C",02,0})
AADD(_stru,{"RB_SEQUEN","C",02,0})
AADD(_stru,{"RB_CLIENTE","C",06,0})
AADD(_stru,{"RB_NOMECLI","C",30,0})
AADD(_stru,{"RB_PARCIAL","C",01,0})
AADD(_stru,{"RB_PRODUTO","C",15,0})
AADD(_stru,{"RB_DESCPRO","C",30,0})
AADD(_stru,{"RB_QTDVEN","N",09,2})
AADD(_stru,{"RB_QTDORI","N",09,2})
AADD(_stru,{"RB_SALDO","N",09,2})
AADD(_stru,{"RB_QATU","N",09,2})
AADD(_stru,{"RB_OPERADO","C",06,0})
AADD(_stru,{"RB_NFISCAL","C",06,0})
AADD(_stru,{"RB_SERIENF","C",03,0})
AADD(_stru,{"RB_DATALIB","D",08,0})
AADD(_stru,{"RB_PRCVEN","N",18,4})
AADD(_stru,{"RB_LOTECTL","C",10,0})
AADD(_stru,{"RB_NUMLOTE","C",06,0})
AADD(_stru,{"RB_DTVALID","D",08,0})
AADD(_stru,{"RB_LOCAL","C",02,0})
AADD(_stru,{"RB_VEND","C",06,0}) 
AADD(_stru,{"RB_FORNEC","C",06,0}) 
/*
cArq:=Criatrab(_stru,.T.)
DBUSEAREA(.T.,,cArq,"TRB")
*/
	If(oTempTable <> NIL)
		oTempTable:Delete()
		oTempTable := NIL
	EndIf
	oTempTable := FWTemporaryTable():New("TRB")
	oTempTable:SetFields( _stru )
	//oTempTable:AddIndex("1", {"RB_STATUS", "RB_PEDIDO","RB_ITEM"} )
	oTempTable:Create()

Return
************************

************************
Static Function CriaTem2()

_aTrb := {}
AADD(_aTrb,{"RB_STATUS","Status","@!"})
AADD(_aTrb,{"RB_PEDIDO","Pedido","@!"})
AADD(_aTrb,{"RB_ITEM","Item","@!"})
AADD(_aTrb,{"RB_SEQUEN","Seq.","@!"})
AADD(_aTrb,{"RB_CLIENTE","Cliente","@!"})
AADD(_aTrb,{"RB_NOMECLI","Nome do Cliente","@!"})
AADD(_aTrb,{"RB_PARCIAL","Parcial","@!"})
AADD(_aTrb,{"RB_PRODUTO","Produto","@!"})
AADD(_aTrb,{"RB_DESCPRO","Descricao","@!"})
AADD(_aTrb,{"RB_QTDVEN","Quant.","@E 99,999.99"})
AADD(_aTrb,{"RB_QTDORI","Qt. Liberada","@E 99,999.99"})
AADD(_aTrb,{"RB_SALDO","Saldo","@E 99,999.99"})
AADD(_aTrb,{"RB_QATU","Sld. Estoque","@E 99,999.99"})
AADD(_aTrb,{"RB_OPERADO","Operado","@!"})
AADD(_aTrb,{"RB_NFISCAL","Nota Fiscal","@!"})
AADD(_aTrb,{"RB_SERIENF","Serie N.F.","@!"})
AADD(_aTrb,{"RB_DATALIB","Dt. Liberacao","@!"})
AADD(_aTrb,{"RB_PRCVEN","Preco Venda","@E 9,999,999,999.9999"})
AADD(_aTrb,{"RB_LOTECTL","Lote","@!"})
AADD(_aTrb,{"RB_NUMLOTE","Num. Lote","@!"})
AADD(_aTrb,{"RB_DTVALID","Data Valid.","@!"})
AADD(_aTrb,{"RB_LOCAL","Almoxarifado","@!"})
AADD(_aTrb,{"RB_VEND","Vendedor","@!"})    
AADD(_aTrb,{"RB_FORNEC","Fornecedor","@!"})

Return
**************

**************
Static Function VerPed()

Local _xAlias  := GetArea()
Private Altera:=.t.,Inclui:=.t.,lRefresh:=.t.,aTELA:=Array(0,0),aGets:=Array(0),;
bCampo:={|nCPO|Field(nCPO)},nPosAnt:=9999,nColAnt:=9999
DbSelectArea("SC6")
DbSetOrder(1)
IF DbSeek(xFilial("SC6")+TRB->RB_PEDIDO)
	
	DbSelectArea("SC5")
	DbSetOrder(1)
	IF DbSeek(xFilial("SC5")+TRB->RB_PEDIDO)
		A410Visual("SC5",Recno(),2)
	EndIF
	
EndIF

RestArea(_xAlias)
Return        
*******************

*******************
Static Function GrvParcial()
Local _cNumPed := ""
_GrPar := 09999
_cNumPed := TRB->RB_PEDIDO
SC5->(DbSetOrder(1))
IF SC5->(DbSeek(xFilial("SC5")+_cNumPed))
	IF SC5->C5_PRENOTA == "S"
		_cMsg := "A Pre-Nota deste pedido ja foi impressa." + Chr(13) + Chr(13)
		_cMsg := _cMsg + "Este Pedido nao pode ser Alterado !!!"
		MsgBox(_cMsg,"Atencao","ALERT")
	Else
		DbSelectArea("SC9")
		DbSetOrder(1)
		IF DbSeek(xFilial("SC9")+_cNumPed)
			While .T.
				_cParcial := IIF(MsgBox("Libera pedido para Faturamento ?","Atencao","YESNO")==.T.,"","N")
				IF Empty(_cParcial)
					IF MsgBox("Este Pedido sera Liberado para Faturamento, Confirma ?","Atencao","YESNO")
						Exit
					Else
						Loop
					EndIF
				Else
					IF MsgBox("Este Pedido Nao sera liberado para Faturamento, Confirma ?","Atencao","YESNO")
						Exit
					Else
						Loop
					EndIF
				EndIF
			EndDo
			_GrPar := 0
			While !Eof() .And. SC9->C9_FILIAL == xFilial("SC9");
				.And. SC9->C9_PEDIDO == _cNumPed
				IF SC9->C9_BLCRED <> "10" .And. SC9->C9_BLEST <> "10"
					RecLock("SC9",.F.)
					Replace C9_PARCIAL With _cParcial
					MsUnLock()
					_GrPar := 1
				Endif
				DbSkip()
			EndDo
		EndIF
	EndIF
EndIF
If _GrPar == 1
	Analizar()
Endif
Return                        
***************

***************    
Static Function OK()

Local _xAlias  := GetArea()

// Eriberto 13/02/2006 close(oDlg1)
DBSELECTAREA("TRB")
DBCLOSEAREA()
FERASE(cArq+".DBF")
FERASE(_cIndex+ordbagext())

RestArea(_xAlias) 

Return           
**************

**************    
Static Function Rept(_cRept)

Local _xAlias  := GetArea()

If _cRept == 1
	_par02 := _par01 
Elseif _cRept == 2
	_par04 := _par03   
Elseif _cRept == 3
	_par06 := _par05 
	_loj4  := _loj3 
Elseif _cRept == 4
	_par08 := _par07   
Elseif _cRept == 5
	_par10 := _par09
	_loj2  := _loj1	
Elseif _cRept == 6
	_par12 := _par11 
Elseif _cRept == 7
	_par02 := _par01   
	_par04 := _par03  
	_par06 := _par05 
	_loj4  := _loj3 
	_par08 := _par07 
	_par10 := _par09
	_loj2  := _loj1		 
	_par12 := _par11
Endif	

RestArea(_xAlias) 

Return

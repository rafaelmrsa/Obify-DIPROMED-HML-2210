#INCLUDE "RWMAKE.CH"
#include "protheus.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MTA41OT   ºAutor  ³Fabio Rogerio       º Data ³  09/04/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Rotina para a inclusao/exclusao de reserva                  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function MTA410T(_lPe)

Local aArea       := GetArea()
Local aAreaSC5    := SC5->(GetArea())
Local aAreaSC6    := SC6->(GetArea())
Local aAreaSC9    := SC9->(GetArea())
Local aSaldo      := {}
Local cQuery      := ""
Local cExplBloq   := CriaVar("C5_EXPLBLO")
Local _lTravouB2  := .F.
Local _cProErroSb2:= ""
Local _aMsg       := {}
Local mm
Local _uRet

Local _nPosQtdLib := aScan(aHeader, { |x| Alltrim(x[2]) == "C6_QTDLIB"})
Local _nPosQtdVen := aScan(aHeader, { |x| Alltrim(x[2]) == "C6_QTDVEN"})

Private _cQry0    := " "
Private nTotalPedi:= 0
Private nMinimoPed:= 0
Private nResulPor := 0
Private cTabela      := "1Z"
Private cChave       := " "
Private cX5Chave     := " "
Private cMsgDecr     := " "
Private cCliIsento   := " "
Private nMsgLeveSpn  := 0
Private nMsgPesaIng  := 0
Private cLevePesa    := " "
Private cNomeDes     := " "
Private _cPorcenRes  := " "
Private _aErroSb2 := {}
Private _lCorrige := .T.
Private _lNeedCorrect := If("TMK"$FUNNAME(),If(M->UA_PARCIAL = 'T',.T.,.F.),If(M->C5_PARCIAL = 'T',.T.,.F.))
Private _InvalidTES := .F. // MCVN - 21/05/09

//-- Variavel estática para passar variáveis para o PE M410STTS
STATIC  _aAux
DEFAULT _aAux := {}

//-- Chamada padrão é como PE
DEFAULT _lPe := .T.


If ISINCALLSTACK("LOJA901A") .Or. ISINCALLSTACK("LOJA901")
	Return .T.
EndIf


If "MATA310"$Upper(FunName())
	Return .T.
EndIf

U_DIPPROC(ProcName(0),U_DipUsr()) // JBS 05/10/2005 - Gravando o nome do Programa no SZU

//-- Somente processa reserva quando é chamado por PE
If _lPE
	If "TMK"$FUNNAME()
		M->UA_PARCIAL := ''
	Else
		M->C5_PARCIAL := ''
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Executa rotina para a reserva dos itens liberados para posterior faturamento.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	U_DIPXRESE("REST_NEW",SC5->C5_NUM)
	U_DIPXRESE("L",SC5->C5_NUM,"","","","","","","","","","")

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica se existem produtos com Saldo.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cQuery:= " SELECT C6_ITEM,C6_PRODUTO,B1_DESC,C6_QTDVEN,C6_TES,C6_ERROSB2,C6_QTDVEN-SUM(C9_SALDO) AS C9_QTDLIB,SUM(C9_SALDO) AS C9_SALDO,SUM(B2_QATU-B2_RESERVA-B2_QACLASS) AS B2_QATU "
	cQuery+= " FROM " + RetSqlName("SC6")+ " SC6, " + RetSqlName("SB1") + " SB1, " + RetSqlName("SC9") + " SC9, " + RetSqlName("SB2") + " SB2 "
	cQuery+= " WHERE  "
	cQuery+= " 		SC6.D_E_L_E_T_ = ' ' "
	cQuery+= " 		AND SB1.D_E_L_E_T_ = ' ' "
	cQuery+= " 		AND SC9.D_E_L_E_T_ = ' ' "
	cQuery+= " 		AND SB2.D_E_L_E_T_ = ' ' "
	cQuery+= " 		AND SB1.B1_FILIAL  = '" + xFilial("SB1") + "'"
	cQuery+= " 		AND SB2.B2_FILIAL  = '" + xFilial("SB2") + "'"
	cQuery+= " 		AND SC9.C9_FILIAL  = '" + xFilial("SC9") + "'"
	cQuery+= " 		AND SC6.C6_FILIAL  = '" + xFilial("SC6") + "'"
	cQuery+= " 		AND SC6.C6_NUM     = '" + SC5->C5_NUM + "'"
	cQuery+= " 		AND SB2.B2_LOCAL   = SC6.C6_LOCAL "
	cQuery+= " 		AND SC6.C6_PRODUTO = SB1.B1_COD "
	cQuery+= " 		AND SC6.C6_PRODUTO = SB2.B2_COD "
	cQuery+= " 		AND SC6.C6_NUM     = SC9.C9_PEDIDO "
	cQuery+= " 		AND SC6.C6_ITEM    = SC9.C9_ITEM "
	cQuery+= " 		AND SC6.C6_PRODUTO = SC9.C9_PRODUTO "
	cQuery+= " 		AND SC9.C9_NFISCAL = ' '"
	cQuery+= " GROUP BY C6_ITEM,C6_ERROSB2,C6_PRODUTO,B1_DESC,C6_QTDVEN,C6_TES"
	
	cQuery := ChangeQuery(cQuery)
	
	DbCommitAll()
	DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"QRY",.T.,.T.)
	
	dbSelectArea("QRY")
	dbGoTop()
	While !Eof()
		
		If !(SF4->(dbSeek(xFilial("SF4")+QRY->C6_TES))) //MCVN 21/05/09 - Bloqueia Pedido caso tenha TES inválida
			_InvalidTES := .T.
		Endif
		
		If QRY->C9_SALDO = 0 .And. Empty(QRY->C6_ERROSB2) //MCVN 21/05/09 - Skip qdo não existe saldo e nem erro de SB2
			DbSkip()
			Loop
		Endif
		
		_lTravouB2	:= (_lTravouB2 .Or. !Empty(QRY->C6_ERROSB2))
		
		// Grava no array o produto com problema de SB2
		If aScan(_aErroSb2, { |x| x[1] == QRY->C6_PRODUTO }) == 0 .And. !Empty(QRY->C6_ERROSB2)
			AADD(_aErroSb2, {QRY->C6_PRODUTO,.F.} )
		Endif
		
		aAdd(aSaldo,{QRY->C6_ITEM,QRY->C6_PRODUTO,QRY->B1_DESC,QRY->C6_QTDVEN,QRY->C9_QTDLIB,QRY->C9_SALDO,QRY->B2_QATU})
		
		dbSelectArea("QRY")
		dbSkip()
	End
	QRY->(dbCloseArea())
	
	If (Len(aSaldo) > 0)  .And. SC5->C5_TIPODIP <> '2' .And. SC5->C5_TIPODIP <> '3'
		If _lTravouB2 // Chama rotina que corrige SB2 - MCVN - 03/12/04
			
			For mm := 1 to Len(_aErroSb2)
				_cProErroSb2 := _aErroSb2[mm,1]
				
				Processa({|| U_DIPM022(_cProErroSb2) })
				
				_aErroSb2[mm,2] := _lCorrige
				If !_aErroSb2[mm,2]
					_lCorrige := .F.
				Endif
				
				Aadd( _aMsg , { "Produto: "      , _aErroSb2[mm,1] } )  // Atualiza informação para e-mail
			Next
			
			_lTravouB2 := !_lCorrige
			
		EndIf
		
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Grava o campo parcial do SC5.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	RecLock("SC5",.F.)
	Replace C5_PARCIAL With 'N'
	If SC5->C5_TIPODIP $ '2/3'
		Replace C5_PRENOTA With 'O'
		Replace C5_HORALIB With Time()
		Replace C5_DTPEDID With CTOD("")
	Endif
	SC5->(MsUnLock())
	SC5->(DbCommit())
EndIf

//-- Tratamento para armazenar/passar parâmetros para o PE M410STTS
If _lPE
	_aAux :={	SC5->(Recno()),;		//-- [1]
	_lTravouB2,;			//-- [2]
	_lNeedCorrect,;			//-- [3]
	_InvalidTES,;			//-- [4]
	aSaldo,;				//-- [5]
	_aMsg }					//-- [6]
	
	_uRet := .T.
Else
	_uRet := aClone(_aAux)
EndIf

RestArea(aAreaSC9)
RestArea(aAreaSC6)
RestArea(aAreaSC5)
RestArea(aArea)

Return(_uRet)
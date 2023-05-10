/*
PONTO.......: SF2520E           PROGRAMA....: MATA520
DESCRIÇÄO...: ANTES DA EXCLUSAO
UTILIZAÇÄO..: Este P.E. esta localizado na funcao A520Dele();
E chamado antes da exclusao dos dados nos arquivos.
PARAMETROS..: Nenhum.
RETORNO.....: Nenhum.
OBSERVAÇÖES.: <NENHUM>
*/
/*====================================================================================\
|Programa  | SF2520E       | Autor | Rodrigo Franco             | Data | 24/01/2002   |
|=====================================================================================|
|Descrição | Gerar Requisicao para Produtos que nao atualizam estoque na              |
|          | exclusao conforme Get respondido pelo usuario                            |
|=====================================================================================|
|Sintaxe   | SF2520E                                                                  |
|=====================================================================================|
|Uso       | Especifico DIPROMED                                                      |
|=====================================================================================|
|........................................Histórico....................................|
|Eriberto  | 04/01/2005 - ajuste na chave do SD2 estava com 01 no final               |
|Rafael    | DD/MM/AAAA - DESCRICAO                                                   |
\====================================================================================*/
#include "rwmake.ch"

User Function SF2520E()
Local _nValor := 0
Local _cSituacao := ''
Local _nValDev := 0
Local _nQtdDev := 0
Local _d3doc := ""

SetPrvt("_CALIAS,_NRECNO,_NORDEM,_LRET,_CCHAVE,_NQUAN,_NCUSTO,_CLOC,_cCod,_nQtdsg")
SetPrvt("_CNOTA,_CSERIE,_dataValid,_cGERA,_cEST,_SUBLOTE,cNumSC5,_cPedido")

_cAlias    :=GetArea()
_cAliasSF2 :=SF2->(GetArea())
_cAliasSD2 :=SD2->(GetArea())
_cAliasSF4 :=SF4->(GetArea())
_cAliasSB1 :=SB1->(GetArea())
_cAliasSB2 :=SB2->(GetArea())
_cAliasSB8 :=SB8->(GetArea())
_cAliasSBF :=SBF->(GetArea())
_cAliasSBE :=SBE->(GetArea())
_cAliasSDB :=SDB->(GetArea())
_cAliasSD3 :=SD3->(GetArea())
_cAliasSD5 :=SD5->(GetArea())
_cAliasSE1 :=SE1->(GetArea())

Public _ZD_Explic

U_DIPPROC(ProcName(0),U_DipUsr()) // JBS 05/10/2005 - Gravando o nome do Programa no SZU

//  Verifica se titulo em carteira ou recebido
Dbselectarea("SE1")
Dbsetorder(1)
If Dbseek(xfilial("SE1")+SF2->F2_SERIE+SF2->F2_DOC)
	
//	Do While SE1->(!EOF()) .and. SE1->E1_PREFIXO == SF2->F2_SERIE .and. SE1->E1_NUM == SF2->F2_DOC
	Do While SE1->(!EOF()) .and. SE1->E1_PREFIXO == SF2->F2_PREFIXO .and. SE1->E1_NUM == SF2->F2_DOC// Alterado de F2_SERIE PARA F2_PREFIXO
		_nValor += SE1->E1_SALDO - SE1->E1_VALOR
		_cSituacao += SE1->E1_SITUACAO
		SE1->(DbSkip())
	EndDo
	
	If Val(_cSituacao) <> 0 .and. _nValor == 0
		// ESTOU VOLTANDO SEM FAZER NADA!
		// O TITULO NAO ESTA EM CARTEIRA OU FOI RECEBIDO.
		RestArea(_cAliasSE1)
		RestArea(_cAlias)
		Return
	EndIf
EndIf

// Verifica se tem nota de devolucao
Dbselectarea("SD2")
Dbsetorder(3)
If Dbseek(xfilial("SD2")+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA)
	
	Do While SD2->(!EOF()) .and. SD2->D2_SERIE == SF2->F2_SERIE .and. SD2->D2_DOC == SF2->F2_DOC
		_nValDev += SD2->D2_QTDEDEV
		_nQtdDev += SD2->D2_VALDEV
		SD2->(DbSkip())
	EndDo
	
	If _nValDev <> 0 .or. _nQtdDev <> 0
		// ESTOU VOLTANDO SEM FAZER NADA!
		// TEM NOTA DE DEVOLUCAO
		
		RestArea(_cAliasSD2)
		RestArea(_cAlias)
		Return
	EndIf
EndIf

_ZD_Explic := U_D3_EXPLIC(SF2->F2_DOC,"EXPLICACAO DA EXCLUSAO")   // chama explicacao

_lret      := .T.
_cChave    := SF2->F2_DOC + SF2->F2_SERIE
_cNota     := SF2->F2_DOC
_cSerie    := SF2->F2_SERIE
_dataValid := ctod("  /  /  ")
_cGera     := space(03)
_cEST      := space(1)
cNumSC5     := space(06)
_cLocaliz  := ''

//³ Cria Consulta no SQL                                         ³
cQuery0 :=           " SELECT * FROM"
cQuery0 := cQuery0 + " "+ RetSqlName("SD2")+ " " 
cQuery0 := cQuery0 + "  WHERE "
cQuery0 := cQuery0 + "D_E_L_E_T_ <> '*'" + " AND "
cQuery0 := cQuery0 + "D2_DOC = '"+_cNota+"'  AND "
cQuery0 := cQuery0 + "D2_SERIE = '"+_cSerie+"' "
cQuery0 := cQuery0 + "ORDER BY D2_DOC+D2_SERIE"

#xcommand TCQUERY <sql_expr>                             ;
[ALIAS <a>]                                           ;
[<new: NEW>]                                          ;
[SERVER <(server)>]                                   ;
[ENVIRONMENT <(environment)>]                         ;
;
=> dbUseArea(                                       ;
<.new.>,                                            ;
"TOPCONN",                                          ;
TCGENQRY(<(server)>,<(environment)>,<sql_expr>),    ;
<(a)>, .F., .T.)

//³ Processa Query SQL                                           ³
DbCommitAll()
TcQuery cQuery0 NEW ALIAS "QUERY0"         // Abre uma workarea com o resultado da query
DbSelectArea("QUERY0")
DBGOTOP()
_cPedido := QUERY0->D2_PEDIDO
///////////////////////////////////////////////////////////////////////////////////////////////////////
// JBS 26/07/2010 - O Eriberto mudou o conceito, então nao precisa mais da pergunta.                 //
// _Eriberto := .F.                                                                                  //
// If AllTrim(Upper(U_DipUsr())) $ 'ERIBERTO/EELIAS/MCANUTO'                                //
//    _Eriberto := MsgBox("Vamos gerar SD3?","Atencao","YESNO")                                      //
// EndIf                                                                                             //
///////////////////////////////////////////////////////////////////////////////////////////////////////

Do while !EOF()

	_cNumseq := ProxNum()
	
	Dbselectarea("SF4")
	Dbsetorder(1)
	If Dbseek(xfilial("SF4")+QUERY0->D2_TES)
		_cGera := SF4->F4_GER_EST
		_cEST  := SF4->F4_ESTOQUE
	Endif

	//---------------------------------------------------------------------------------------------
	// JBS 26/07/2010 - Quando a rotina for chamada a partir da avaliacao de 
	// processo de cancelamento de NFS e a mercadoria da nota fiscal que esta
	// sendo devolvida estiver no cliente.
	//---------------------------------------------------------------------------------------------
	If Type("lDip46GrD3") <> "U" .And. lDip46GrD3 
	    _cGera := 'N'
	Else   
		_cGera := ' '
	EndIf

	If _cGera == "N" .AND. _cEst == 'S'
		// Atualiza SB2 (Saldos em Estoque)
		Dbselectarea("SB2")
		Dbsetorder(1)
		If Dbseek(xFilial()+QUERY0->D2_COD+QUERY0->D2_LOCAL)
			Reclock("SB2",.F.)
			Replace SB2->B2_QATU    WITH SB2->B2_QATU - QUERY0->D2_QUANT
			Replace SB2->B2_QTSEGUM WITH SB2->B2_QTSEGUM - QUERY0->D2_QTSEGUM
			_nRetSb2 := SB2->B2_CM1 * QUERY0->D2_QUANT
			Replace SB2->B2_VATU1   WITH SB2->B2_VATU1 - _nRetSb2
			_nAtuCm1 := SB2->B2_VATU1 / SB2->B2_QATU
			Replace SB2->B2_CM1   WITH _nAtuCm1
			SB2->(MsUnlock())
			SB2->(DbCommit())
		Else
			MsgBox("Nao existe o produto " + AllTrim(_cCod) + " no almoxarifado " + AllTrim(_cLocOrig) + ". O sistema ira criar automaticamente.","Atencao")
			Reclock("SB2",.T.)
			SB2->B2_FILIAL  := Substr(cNumEmp,3,2)
			SB2->B2_COD     := QUERY0->D2_COD
			SB2->B2_LOCAL   := QUERY0->D2_LOCAL
			//SB2->B2_QATU    := SB2->B2_QATU - QUERY0->D2_QUANT
			//SB2->B2_QTSEGUM := SB2->B2_QTSEGUM - QUERY0->D2_QTDSEGUM
			SB2->(MsUnlock())
			SB2->(DbCommit())
		Endif
		
		// Atualiza SB8 (Saldos por Lote) e SD5 (Movimentos por Lote)
		Dbselectarea("SB1")
		Dbsetorder(1)
		If Dbseek(xFilial("SB1")+QUERY0->D2_COD)
			If SB1->B1_RASTRO == "L" .OR. SB1->B1_RASTRO == "S"
				
				Dbselectarea("SD5")
				Dbsetorder(3)
				If Dbseek(xFilial("SD5")+QUERY0->D2_NUMSEQ+QUERY0->D2_COD+QUERY0->D2_LOCAL+QUERY0->D2_LOTECTL)
					
					Do While !Eof() .and. SD5->D5_NUMSEQ+SD5->D5_PRODUTO == QUERY0->D2_NUMSEQ+QUERY0->D2_COD
						_nReg := Recno()
						_NumLote := SD5->D5_NUMLOTE
						_DtValid := SD5->D5_DTVALID
						_nQuant  := SD5->D5_QUANT
						_nQtSegum:= SD5->D5_QTSEGUM
						
						Dbselectarea("SB8")
						Dbsetorder(3)
						If Dbseek(xFilial()+QUERY0->D2_COD+QUERY0->D2_LOCAL+QUERY0->D2_LOTECTL+_NumLote)
							Reclock("SB8",.F.)
							Replace SB8->B8_SALDO    WITH  SB8->B8_SALDO - _nQuant
							Replace SB8->B8_SALDO2   WITH  SB8->B8_SALDO2 - _nQtSegum
							SB8->(MsUnlock())
							SB8->(DbCommit())
						EndIf
						
						Dbselectarea("SD5")
						Reclock("SD5",.T.)
						_demissao := subs(QUERY0->D2_EMISSAO,7,2) +"/"+subs(QUERY0->D2_EMISSAO,5,2)+"/"+subs(QUERY0->D2_EMISSAO,3,2)
						Replace SD5->D5_FILIAL    WITH xFilial("SD5")
						Replace SD5->D5_PRODUTO   WITH QUERY0->D2_COD
						Replace SD5->D5_LOCAL     WITH QUERY0->D2_LOCAL
						Replace SD5->D5_DATA      WITH CTOD(_demissao)
						Replace SD5->D5_ORIGLAN   WITH QUERY0->D2_TES
						Replace SD5->D5_NUMSEQ    WITH _CNUMSEQ
						Replace SD5->D5_QUANT     WITH _nQuant
						Replace SD5->D5_LOTECTL   WITH QUERY0->D2_LOTECTL
						Replace SD5->D5_NUMLOTE   WITH _NumLote
						Replace SD5->D5_DTVALID   WITH _DtValid
						Replace SD5->D5_QTSEGUM   WITH _nQtSegum
						Replace SD5->D5_CLIFOR    WITH QUERY0->D2_CLIENTE
						Replace SD5->D5_LOJA      WITH QUERY0->D2_LOJA
						Replace SD5->D5_DOC       WITH QUERY0->D2_DOC
						Replace SD5->D5_SERIE     WITH QUERY0->D2_SERIE
						SD5->(MsUnlock())
						SD5->(DbCommit())
						
						DbGoto(_nReg)
						DbSkip()
					EndDo
				EndIf
				
			Endif
		Endif
		
		// Atualiza SBF (Saldos por Localizacao) e Atualiza SDB (Movimentos por Localizacao)
		Dbselectarea("SB1")
		Dbsetorder(1)
		If Dbseek(xFilial("SB1")+QUERY0->D2_COD)
			If SB1->B1_LOCALIZ == "S"
				Dbselectarea("SDB")
				DbSetOrder(1)
				IF DbSeek(xFilial("SDB")+QUERY0->D2_COD+QUERY0->D2_LOCAL+QUERY0->D2_NUMSEQ)
					Do While !Eof() .and. SDB->DB_PRODUTO+SDB->DB_LOCAL+SDB->DB_NUMSEQ == QUERY0->D2_COD+QUERY0->D2_LOCAL+QUERY0->D2_NUMSEQ
						_nReg := Recno()
						_cLocaliz := SDB->DB_LOCALIZ
						_nQuant   := SDB->DB_QUANT
						_nQtSegum := SDB->DB_QTSEGUM
						
						Dbselectarea("SBF")
						DbSetOrder(1)
						IF DbSeek(xFilial("SBF")+QUERY0->D2_LOCAL+_cLocaliz+QUERY0->D2_COD+QUERY0->D2_NUMSERI+QUERY0->D2_LOTECTL+QUERY0->D2_NUMLOTE)
							RecLock("SBF",.F.)
							Replace SBF->BF_QUANT   With SBF->BF_QUANT   - _nQuant
							Replace SBF->BF_QTSEGUM With SBF->BF_QTSEGUM - _nQtSegum
							SBF->(MsUnLock())
							SBF->(DbCommit())
						Else
							Dbselectarea("SBE")
							DbSetOrder(1)
							IF DbSeek(xFilial("SBE")+SDB->DB_LOCAL+SDB->DB_LOCALIZ)
								_Prior := SBE->BE_PRIOR
							Else
								_Prior := 'ZZZ'
							EndIf
							
							RecLock("SBF",.T.)
							Replace SBF->BF_FILIAL  With xFILIAL('SBF')
							Replace SBF->BF_PRODUTO With SDB->DB_PRODUTO
							Replace SBF->BF_LOCAL   With SDB->DB_LOCAL
							Replace SBF->BF_PRIOR   With _PRIOR
							Replace SBF->BF_LOCALIZ With SDB->DB_LOCALIZ
							Replace SBF->BF_NUMSERI With SDB->DB_NUMSERI
							Replace SBF->BF_LOTECTL With SDB->DB_LOTECTL
							Replace SBF->BF_NUMLOTE With SDB->DB_NUMLOTE
							Replace SBF->BF_QUANT   With 0 - _nQuant
							Replace SBF->BF_EMPENHO With 0
							Replace SBF->BF_QEMPPRE With 0
							Replace SBF->BF_QTSEGUM With 0 - _nQtSegum
							Replace SBF->BF_EMPEN2  With 0
							Replace SBF->BF_QEPRE2  With 0
							SBF->(MsUnLock())
							SBF->(DbCommit())
						EndIf
						
						Dbselectarea("SDB")
						DbSetOrder(1)
						Reclock("SDB",.T.)
						Replace SDB->DB_FILIAL    WITH xFilial("SDB")
						Replace SDB->DB_ITEM      WITH '001'
						Replace SDB->DB_PRODUTO   WITH QUERY0->D2_COD
						Replace SDB->DB_LOCAL     WITH QUERY0->D2_LOCAL
						Replace SDB->DB_DATA      WITH CTOD(subs(QUERY0->D2_EMISSAO,7,2) +"/"+subs(QUERY0->D2_EMISSAO,5,2)+"/"+subs(QUERY0->D2_EMISSAO,3,2))
						Replace SDB->DB_ORIGEM    WITH 'SC6'
						Replace SDB->DB_NUMSEQ    WITH _CNUMSEQ
						Replace SDB->DB_QUANT     WITH _nQuant
						Replace SDB->DB_LOTECTL   WITH QUERY0->D2_LOTECTL
						Replace SDB->DB_QTSEGUM   WITH _nQtSegum
						Replace SDB->DB_CLIFOR    WITH QUERY0->D2_CLIENTE
						Replace SDB->DB_LOJA      WITH QUERY0->D2_LOJA
						Replace SDB->DB_DOC       WITH QUERY0->D2_DOC
						Replace SDB->DB_SERIE     WITH QUERY0->D2_SERIE
						Replace SDB->DB_TIPO      WITH 'M'
						Replace SDB->DB_TM        WITH QUERY0->D2_TES
						Replace SDB->DB_LOCALIZ   WITH _cLocaliz
						SDB->(MsUnlock())
						SDB->(DbCommit())
						
						DbGoto(_nReg)
						DbSkip()
						
					EndDo
				EndIf
			EndIf
		EndIf
		
		////////////////////////////////////////////////////////////////////
		//³ Gera SD3 (REQUISICAO)                                        ³
		Dbselectarea("SD3")
		Reclock("SD3",.T.)
		_demissao := subs(QUERY0->D2_EMISSAO,7,2) +"/"+subs(QUERY0->D2_EMISSAO,5,2)+"/"+subs(QUERY0->D2_EMISSAO,3,2)
		cNumSC5    := QUERY0->D2_PEDIDO
		Replace SD3->D3_FILIAL  WITH xFilial("SD3")
		Replace SD3->D3_TM      WITH QUERY0->D2_TES  //"501"
		Replace SD3->D3_COD     WITH QUERY0->D2_COD
		Replace SD3->D3_UM      WITH QUERY0->D2_UM
		Replace SD3->D3_QUANT   WITH QUERY0->D2_QUANT
		Replace SD3->D3_CF      WITH "RE0"
		Replace SD3->D3_LOCAL   WITH QUERY0->D2_LOCAL
		Replace SD3->D3_EMISSAO WITH CTOD(_demissao)
		Replace SD3->D3_CUSTO1  WITH QUERY0->D2_CUSTO1
		Replace SD3->D3_NUMSEQ  WITH _cNumseq
		Replace SD3->D3_SEGUM   WITH QUERY0->D2_SEGUM
		Replace SD3->D3_QTSEGUM WITH QUERY0->D2_QTSEGUM
		Replace SD3->D3_TIPO    WITH QUERY0->D2_TP
		Replace SD3->D3_CHAVE   WITH "E0"
		Replace SD3->D3_LOTECTL WITH QUERY0->D2_LOTECTL
		Replace SD3->D3_NUMLOTE WITH QUERY0->D2_NUMLOTE
		Replace SD3->D3_DTVALID WITH _datavalid
		Replace SD3->D3_DOC     WITH QUERY0->D2_DOC
		Replace SD3->D3_IDENT   WITH QUERY0->D2_SERIE
		Replace SD3->D3_CONTA   WITH QUERY0->D2_CONTA
		Replace SD3->D3_LOCALIZ WITH _cLocaliz
		Replace SD3->D3_USUARIO WITH Upper(U_DipUsr())
		Replace SD3->D3_EXPLIC  WITH _ZD_Explic
		SD3->(MsUnlock())
		SD3->(DbCommit())
		PutMv("MV_DOCSEQ",_cNumSeq)
	Endif
	DBSELECTAREA("QUERY0")
	dbSkip()
Enddo

// Envia Email informando que a Nota Fiscal foi Excluida.
If CNUMEMP <> '0301'// Não envia e-mail se a empresa for EMOVERE  MCVN - 13/01/2009
	U_SF2EnvEMail(_ZD_Explic)    

	If SF2->F2_TIPO $ 'DB'
		U_NfSEmail(2)
	Endif                            
Endif
//--------------------------------------------------------------------------------------------------------------------
// JBS 26/05/2010 - Exclui o Pedido de Vendas, se o usuario o solicitou, no cancelamento da nota fiscal.
//--------------------------------------------------------------------------------------------------------------------
//If SZL->ZL_MATAPED == '2' // Mata Pedido de Venda = Sim 
//	MSExecAuto({|x,y,z| Mata410(x,y,z)},{{"C5_NUM",cNumSC5,NIL}},{},5)
//ElseIf !EMPTY(cNumSC5)
//   Aviso('Atenção','Será necessário a exclusão do pedido ' + cNumSC5 +' para que o mesmo nao fique em aberto. Só o cancelamento da NF não retornou os materiais para o estoque.',{'OK'})
//Endif

// Registra na ficha Kardex
U_DiprKardex(_cPedido ,U_DipUsr(),"NF "+SF2->F2_DOC,.t.,"18") // JBS 29/08/2005
DbSelectArea("QUERY0")
DBCLOSEAREA("QUERY0")

//³ Efetua o Estorno da transferencia entre os almoxarIFados quando o pedido ³
//³ e' estornado.            							 				     ³
//IF FunName(0) != "MATA410"
//	U_DIPA013(,,cNumSC5,.F.)
//EndIF

RestArea(_cAliasSF2)
RestArea(_cAliasSD2)
RestArea(_cAliasSF4)
RestArea(_cAliasSB1)
RestArea(_cAliasSB2)
RestArea(_cAliasSB8)
RestArea(_cAliasSBF)
RestArea(_cAliasSBE)
RestArea(_cAliasSDB)
RestArea(_cAliasSD3)
RestArea(_cAliasSD5)
RestArea(_cAlias)

RETURN(.T.)

/*====================================================================================\
|Programa  | SF2EnvEMail   | Autor | Alexandro Dias             | Data | 27/02/2002   |
|=====================================================================================|
|Descrição | Envia Email informando que a Nota Fiscal foi Excluida.                   |
|=====================================================================================|
|Sintaxe   | SF2EnvEMail                                                              |
|=====================================================================================|
|Uso       | Especifico DIPROMED                                                      |
|=====================================================================================|
|........................................Histórico....................................|
|Rafael    | 13/01/2005 - Adicionar ao envio de e-mail de nf cancel. Joel e Alexandre |
|Eriberto  | DD/MM/AAAA - DESCRICAO                                                   |
\====================================================================================*/
User Function SF2EnvEMail(cExplic)

Local _aArea    := GetArea()
Local _aAreaSA1 := SA1->(GetArea())
Local _aAreaSD2 := SD2->(GetArea())
Local _aAreaSC5 := SC5->(GetArea())
Local cEnd_Env	:= ""
Local _aMsg     := {}
Local _cFuncSent:="SF2520E.PRW"

DbSelectArea("SD2")
DbSetOrder(3)
IF DbSeek(xFilial("SD2")+SF2->F2_DOC + SF2->F2_SERIE)
	DbSelectArea("SC5")
	DbSetorder(1)
	IF DbSeek(xFilial("SC5")+SD2->D2_PEDIDO)
		DbSelectArea("SU7")
		DbSetorder(1)
		IF DbSeek(xFilial("SU7")+SC5->C5_OPERADO)
			IF !Empty(SU7->U7_EMAIL)
				SA1->(DbSetorder(1))
				Aadd( _aMsg , { "Explicação:" , cExplic } )
				IF SA1->( DbSeek(xFilial("SA1")+SF2->F2_CLIENTE+SF2->F2_LOJA) )
					Aadd( _aMsg , { "Cliente:" , AllTrim(SA1->A1_COD)+'-'+SA1->A1_NOME } )
				EndIF
				Aadd( _aMsg , { "Nota Fiscal/Serie:" , SF2->F2_DOC +"/"+ SF2->F2_SERIE } )
				Aadd( _aMsg , { "Valor Nota Fiscal:" , TransForm(SF2->F2_VALMERC+SF2->F2_VALIPI+SF2->F2_SEGURO+SF2->F2_FRETE,"@E 999,999,999.99") } )
				Aadd( _aMsg , { "Numero Pedido:" , SC5->C5_NUM } )
				Aadd( _aMsg , { "TES usada(s):" , SF2Sd2TES() } )
				SA3->(DbSetorder(1))
				IF SA3->( DbSeek(xFilial("SA3")+SC5->C5_VEND1) )
					Aadd( _aMsg ,{ "Vendedor:" , SA3->A3_NOME } )
				EndIF
				Aadd( _aMsg , { "Operador:" , SU7->U7_NOME } )
				SE4->(DbSetorder(1))
				IF SE4->( DbSeek(xFilial("SE4")+SC5->C5_CONDPAG) )
					Aadd( _aMsg ,{ "Condicao Pagto:" , SE4->E4_DESCRI } )
				EndIF
				SA4->(DbSetorder(1))
				IF SA4->( DbSeek(xFilial("SA4")+SC5->C5_TRANSP) )
					Aadd( _aMsg ,{ "Transportadora:" , SA4->A4_NOME } )
				EndIF
				Aadd( _aMsg , { "Data Emissao:" , Dtoc(SF2->F2_EMISSAO) } )
				Aadd( _aMsg , { "Data Exclusao:" , Dtoc(dDataBase) } )
				Aadd( _aMsg , { "Hora da Exclusao:" , TIME() } )
				cEnd_Env := SU7->U7_EMAIL + ";sac@dipromed.com.br"
				cEnd_Env += "contabil@dipromed.com.br"
				U_UEnvMail(Alltrim(cEnd_Env),;
				"Notificacao de Exclusao da Nota Fiscal Referente ao Pedido "+SC5->C5_NUM,;
				_aMsg,"","",_cFuncSent)
			EndIF
		EndIF
	EndIF
EndIF

RestArea(_aAreaSD2)
RestArea(_aAreaSC5)
RestArea(_aAreaSA1)

RestArea(_aArea)

Return(.T.)
/*====================================================================================\
|Programa  | SF2Sd2TES   | Autor | Jailton B Santos, JBS        | Data | 27/10/2005   |
|=====================================================================================|
|Descrição |  Retorna as TES usadas na NF de Saida na var 'cSD2_TS'                   |
|=====================================================================================|
|Sintaxe   | SF2Sd2TES()                                                              |
|=====================================================================================|
|Uso       | Especifico DIPROMED - DIPA046                                            |
|=====================================================================================|
|........................................Histórico....................................|
|          |                                                                          |
|          |                                                                          |
\====================================================================================*/
Static Function SF2Sd2TES()

Local cSd2_TS:=''
Local cFilSD2:=SD2->(xFilial("SD2"))
Local nSd2Rec:=SD2->(Recno())

Do While SD2->(!eof()).and.;
	     SD2->D2_FILIAL==cFilSD2.and.;
	     SD2->D2_DOC   ==SF2->F2_DOC.and.;
	     SD2->D2_SERIE ==SF2->F2_SERIE

	If !AllTrim(SD2->D2_TES) $ cSd2_TS                    
	     cSd2_TS += AllTrim(SD2->D2_TES)
	EndIf

	SD2->(dbSkip())     

EndDo

SD2->(dbGoto(nSd2Rec))

RETURN(cSd2_TS)

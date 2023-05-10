#INCLUDE "Protheus.ch"
#INCLUDE "RWMAKE.CH"
#DEFINE CR    chr(13)+chr(10)

/*====================================================================================\
|Programa  | DIPG027       | Autor | GIOVANI.ZAGO               | Data | 13/12/2011   |
|=====================================================================================|
|Descrição | Produtos AMCOR                                                           |
|          |                                                                          |
|          |                                                                          |
|=====================================================================================|
|Sintaxe   | DIPG027                                                                  |
|=====================================================================================|
|Uso       | Especifico DIPROMED-Licitação                                            |
|=====================================================================================|
|........................................Histórico....................................|
\====================================================================================*/
*--------------------------------------------------------------------------*
User Function DIPG027()
*--------------------------------------------------------------------------*
Local _aArea          	 := GetArea()
Local _nPosFor     		 := aScan(aHeader, { |x| Alltrim(x[2]) == "C6_FORNEC" })
Local _nPosProd    	     := aScan(aHeader, { |x| Alltrim(x[2]) == "C6_PRODUTO"})
Local _nPosDes    		 := aScan(aHeader, { |x| Alltrim(x[2]) == "C6_DESCRI" })
Local _nPosTs    	     := aScan(aHeader, { |x| Alltrim(x[2]) == "C6_TES"})
Local _x 			     := n
Local _cForn 		     := "" // codigo fornecedor AMCOR
Local _cRet              := aCols[_x,_nPosProd]
Local _clientIsen        := GetMv("ES_DIPG4_2")// EXCEÇÃO
Local _cQuery            := " "
Local _cDipro            := "DIPROMED"
Local _lRet              := .F.
Local _cForc             := " "
Local _cGrupoIsen        := GetMv("ES_DIPG4_1") 
Local _cGrpVen           := ""
Local _cEstCli			 := "" 
Local lVdAMCOR			 := .F. // Permitido vender AMCOR
Local _cCLINVHQ          := GetNewPar("ES_CLINVHQ","")+GetNewPar("ES_CLINVH2","/001152") // Não permitido vender HQ
    
If !(M->C5_TIPO$"D/B") 
	SA1->(dbSetOrder(1))
	If SA1->(dbSeek(xFilial("SA1")+M->C5_CLIENTE+M->C5_LOJACLI))
		_cGrpVen := SA1->A1_GRPVEN
		_cEstCli := SA1->A1_EST
		lVdAMCOR := (SA1->A1_XVAMCOR == "S")
	Else
		Aviso("Atenção","Cliente não encontrado no cadastro",{"Ok"},1)
		_cRet := ""
		RestArea(_aArea)
		Return (_cRet)
	EndIf
Else
	RestArea(_aArea)
	Return (_cRet)	                                                             
EndIf

If  aCols[_x,_nPosFor] = _cForn  .And.  dDataBase >= GetMv("ES_DIPG4_3") .And. !("TMK"$FunName())  .And. !("DIPAL10"$FunName())

	If lVdAMCOR
		RestArea(_aArea)
		Return (_cRet)
	EndIf     
	
	If M->C5_CLIENTE $ _clientIsen   .Or. 	_cGrpVen $ _cGrupoIsen
		RestArea(_aArea)
		Return (_cRet)
	EndIf
	
	If _cEstCli <> "SP"
		MsgInfo("Produto AMCOR Não Pode ser vendido para esta Região !!!","Atenção!")
		_cRet := ""
		aCols[_x,_nPosDes]:=""
		aCols[_x,_nPosTs] :="" 
    	oGetDad:oBrowse:Refresh()
		RestArea(_aArea)
		Return (_cRet)
	Else	
		_cQuery := " SELECT             "
		_cQuery += " ISNULL(RTRIM(LTRIM(TZM.ZM_XPCG)),'A')    AS 'PGC',  "
		_cQuery += " ISNULL(RTRIM(LTRIM(TZN.ZN_XPGC)),'A')    AS 'PGCCLI', "
		_cQuery += " ISNULL(RTRIM(LTRIM(TZM.ZM_XLIMPEZ)),'A') AS 'LIMPEZA',   "
		_cQuery += " ISNULL(RTRIM(LTRIM(TZN.ZN_XLIMPEZ)),'A') AS 'LIMPEZACLI',   "
		_cQuery += " ISNULL(RTRIM(LTRIM(TZM.ZM_XESTERE)),'A') AS 'ESTERELIZACAO',  "
		_cQuery += " ISNULL(RTRIM(LTRIM(TZN.ZN_XESTERE)),'A') AS 'ESTERELIZACAOCLI', "
		_cQuery += " ISNULL(RTRIM(LTRIM(TZM.ZM_XCREPAD)),'A') AS 'CREPADO',   "
		_cQuery += " ISNULL(RTRIM(LTRIM(TZN.ZN_XCREPAD)),'A') AS 'CREPADOCLI', "
		_cQuery += " SB1.B1_XTPAMCO              		     AS 'AMCOR'   "
		_cQuery += " FROM "+RetSqlName('SB1')+" SB1 "
		_cQuery += " INNER JOIN(SELECT * FROM "+RetSqlName('SA1')+" SA1 "
		_cQuery += " WHERE SA1.D_E_L_E_T_    = ' ' )TA1 "
		_cQuery += " ON    TA1.A1_FILIAL     = ' '   "
		_cQuery += " AND   TA1.A1_COD        = '"+M->C5_CLIENTE+"'"
		_cQuery += " LEFT JOIN(SELECT * FROM "+RetSqlName('SZN')+" SZN "
		_cQuery += " WHERE SZN.D_E_L_E_T_ = ' ' )TZN  "
		_cQuery += " ON TZN.ZN_FILIAL = '' "
		_cQuery += " AND RTRIM(LTRIM(TZN.ZN_XCNPJ)) = RTRIM(LTRIM(TA1.A1_CGC)) "
		_cQuery += " LEFT JOIN(SELECT * FROM "+RetSqlName('SZM')+" SZM "
		_cQuery += " WHERE SZM.D_E_L_E_T_ = ' ' )TZM   "
		_cQuery += " ON TZM.ZM_FILIAL = ''  "
		_cQuery += " AND TZM.ZM_XESTADO = TA1.A1_EST   "
		_cQuery += " AND RTRIM(LTRIM(TZM.ZM_XCIDADE)) = RTRIM(LTRIM(TA1.A1_MUN))  "
		//_cQuery += " AND TZM.ZM_FILIAL  = SB1.B1_FILIAL "
		_cQuery += " WHERE SB1.D_E_L_E_T_  = ' '  "
		_cQuery += " AND SB1.B1_FILIAL     = '"+xFilial('SB1')+"'"
		_cQuery += " AND SB1.B1_COD        = '"+aCols[_x,_nPosProd]+"'"
		_cQuery += " AND SB1.B1_PROC       = '000183' "
		_cQuery += " AND SB1.B1_LOJPROC    = '01'   "
		
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQuery),'TMP1',.T.,.F.)
		
		TMP1->(dbgotop())
		If !EMPTY ("TMP1")
			DbSelectArea("TMP1")
			TMP1->(dbgotop())
			While TMP1->(!EOF())
				Do case
					Case TMP1->AMCOR = "1"
						If _cDipro $ TMP1->PGCCLI
							_lRet := .T.
						ElseIf _cDipro $ TMP1->PGC .And. (alltrim(TMP1->PGCCLI) = "A"   .Or.  Empty(TMP1->PGCCLI))
							_lRet := .T.
						Else
							If TMP1->PGCCLI  = "A"
								_cForc := TMP1->PGC
							Else
								_cForc := TMP1->PGCCLI
							EndIf
							If Empty(_cForc )
								_cForc := "A"
							Endif
							_lRet := .F.     
						EndIf
					Case TMP1->AMCOR = "2"
						If _cDipro $ TMP1->LIMPEZACLI
							_lRet := .T.
						ElseIf _cDipro $ TMP1->LIMPEZA .And. (alltrim(TMP1->LIMPEZACLI) = "A"   .Or.  Empty(TMP1->LIMPEZACLI))
							_lRet := .T.
						Else
							If TMP1->PGCCLI  = "A"
								_cForc := TMP1->LIMPEZA
							Else
								_cForc := TMP1->LIMPEZACLI
							EndIf            
							If Empty(_cForc )
								_cForc := "A"
							Endif
							_lRet := .F.
						EndIf
					Case TMP1->AMCOR = "3"
						If _cDipro $ TMP1->ESTERELIZACAOCLI
							_lRet := .T.
						ElseIf _cDipro $ TMP1->ESTERELIZACAO .And. (alltrim(TMP1->ESTERELIZACAOCLI) = "A"   .Or.  Empty(TMP1->ESTERELIZACAOCLI))
							_lRet := .T.
						Else
							If TMP1->PGCCLI  = "A"
								_cForc := TMP1->ESTERELIZACAO
							Else
								_cForc := TMP1->ESTERELIZACAOCLI
							EndIf
							If Empty(_cForc )
								_cForc := "A"
							Endif							
							_lRet := .F.
						EndIf
					Case TMP1->AMCOR = "4"
						If _cDipro $ TMP1->CREPADOCLI
							_lRet := .T.
						ElseIf _cDipro $ TMP1->CREPADO .And. (alltrim(TMP1->CREPADOCLI) = "A"   .Or.  Empty(TMP1->CREPADOCLI))
							_lRet := .T.
						Else
							If TMP1->PGCCLI  = "A"
								_cForc := TMP1->CREPADO
							Else
								_cForc := TMP1->CREPADOCLI
							EndIf
							If Empty(_cForc )
								_cForc := "A"
							Endif							
							_lRet := .F.
						EndIf
					Case Empty(TMP1->AMCOR)
						_lRet  := .F.
						_cForc := ""
				EndCase
				TMP1->( dbSkip())
			END
		EndIf		
		TMP1->(DBCloseArea())		
	EndIf
	
	If _lRet
		_cRet:= aCols[_x,_nPosProd]
	ElseIf  !(_lRet) .And. Empty(_cForc)
		MsgInfo("Produto AMCOR sem Classificação, Entrar em Contato com o Departamento de Compras !!!","Atenção!")
		_cRet:= " "
	ElseIf  !(_lRet) .And. !Empty(_cForc)
		MsgInfo("Produto AMCOR Não Pode ser vendido para este Cliente ou Região, Apenas o Fornecedor: "+ALLTRIM(_cForc)+" Pode Vender !!!","Atenção!")
		_cRet:= " "
	EndIf                     
//Desativada a regra que bloqueia a venda de produtos HQ para Clientes no Espírito Santo - Solicitado pelo Alvaro 17/07/2019 - COnfirmado pelo Erich e Carol pelo WhatsApp. 
//ElseIf !M->C5_CLIENTE$GetNewPar("ES_CLIPVHQ","") .And. aCols[_x,_nPosFor]$'000851/051508/000847'  .And. _cEstCli == "ES" .And. !("TMK"$FunName())  .And. !("DIPAL10"$FunName())	 
//	MsgInfo("Produto não pode ser vendido para esta Região.","Atenção!")
//	_cRet := ""
//ElseIf M->C5_CLIENTE$GetNewPar("ES_CLINVHQ","020230/020320/020360/019799") .And. aCols[_x,_nPosFor]$'000851/051508/000847'  .And.  !("TMK"$FunName())  .And. !("DIPAL10"$FunName())	
ElseIf M->C5_CLIENTE $ _cCLINVHQ .And. aCols[_x,_nPosFor]$'000851/051508/000847' .And. !("TMK"$FunName())  .And. !("DIPAL10"$FunName())	
	MsgInfo("Produto não pode ser vendido para este Cliente.","Atenção!")
	_cRet := ""
EndIf

If Empty(_cRet)
	aCols[_x,_nPosDes]:=" "
	aCols[_x,_nPosTs] :=" "
	oGetDad:oBrowse:Refresh()
EndIf

RestArea(_aArea)
Return (_cRet)
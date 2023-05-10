#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#Include "TopConn.ch"

User Function MAAVCRED()

Local cQuery  	:= ''
Local cQueryE1	:= ''
Local _cAlias 	:= ''
Local cCodCli 	:= ParamIxb[1]
Local cLoja   	:= ParamIxb[2]
Local lRet	  	:= .F.    
Local nTotal  	:= 0
Local nValor  	:= 0
Local nTipoDip	:= ''
Local nTes	  	:= ''
Local cDuplic 	:= ''
Local _cGrupo	:= ''
//Local _cNumPV	:= SC6->C6_NUM
//Local _cItemPV	:= SC6->C6_ITEM
Local _nSA1	 	:= 0
Local _nSA1LC	:= 0
Local nI

If ("MATA410" $ UPPER(Alltrim(FUNNAME())))
  
	//_cNumPV	:= Ascan(aHeader,{|x|Alltrim(X[2])=="C6_NUM"})		//Rafael Moraes Rosa Obify - 21/07/2022
	//_cItemPV	:= Ascan(aHeader,{|x|Alltrim(X[2])=="C6_ITEM"})		//Rafael Moraes Rosa Obify - 21/07/2022
	nValor	:= Ascan(aHeader,{|x|Alltrim(X[2])=="C6_VALOR"})	//busca a posição do campo C6_VALOR
	nTipoDip:= Ascan(aHeader,{|x|Alltrim(X[2])=="C6_TIPODIP"})
	nTes    := Ascan(aHeader,{|x|Alltrim(X[2])=="C6_TES"})
	
	dbSelectArea("SA1")
	dbSeek(xFilial("SA1") + cCodCli + cLoja)

	//Rafael Moraes Rosa Obify - 20/07/2022
	//Linha comentada pois a somatoria do LC e feita na funcao GrpCli()
	//Linha adicionada no bloco do processo de cliente individual (Grupo Financeiro - _nSA1 = 1)
	//_nSA1LC := SA1->A1_LC
	

	//Rafael Moraes Rosa Obify - 15/07/2022 - REGRA LIBERADA (INICIO)
	If !Empty(SA1->A1_XGRPCLI)
		_cGrupo	:= GrpCli(SA1->A1_XGRPCLI, SA1->A1_ZSOMLC,cCodCli,cLoja,@_nSA1, @_nSA1LC, 1)
	Else
		_cGrupo	:= GrpCli(SA1->A1_CGC,SA1->A1_ZSOMLC,cCodCli,cLoja,@_nSA1, @_nSA1LC, 2)
	Endif
	//Rafael Moraes Rosa Obify - 15/07/2022 - REGRA LIBERADA (FIM)
	
	//Rafael Moraes Rosa Obify - 15/07/2022 - REGRA COMENTADA
	/*
	If Empty(_cGrupo)
		_cGrupo	+="'"+SA1->A1_COD+"'"
	Endif
	*/

	If _nSA1 = 1
		//Rafael Moraes Rosa Obify - 15/07/2022 - REGRA ADICIONADA 
		//_cGrupo	+="'"+SA1->A1_COD+"'"
		cA1_RISCO 	:= SA1->A1_RISCO
		_nSA1LC 	:= SA1->A1_LC
	else
		cA1_RISCO = 'B'
	Endif

	If cA1_RISCO == 'B'

		cQueryE1 := "SELECT E1_VENCREA FROM "+RetSqlName("SE1")+" SE1 " + CRLF
		cQueryE1 += "WHERE SE1.D_E_L_E_T_ ='' " + CRLF
		
		IF (_nSA1 = 1) //Rafael Moraes Rosa Obify - 15/07/2022 - REGRA LIBERADA
			cQueryE1 += "AND E1_CLIENTE ='"+cCodCli+"' " + CRLF
			cQueryE1 += "AND E1_LOJA ='"+cLoja+"' " + CRLF
		
		//Rafael Moraes Rosa Obify - 15/07/2022 - REGRA LIBERADA (INICIO)
		Else
			cQueryE1 += "AND E1_CLIENTE IN ("+_cGrupo+") " + CRLF

		Endif
		//Rafael Moraes Rosa Obify - 15/07/2022 - REGRA LIBERADA (FIM)
		
		//Rafael Moraes Rosa Obify - 20/07/2022 - Linha comentada (Teste)
		//cQueryE1 += "AND E1_EMISSAO <> E1_VENCREA " + CRLF
		cQueryE1 += "AND E1_SALDO > 0 " + CRLF
		cQueryE1 += "AND E1_TIPO IN('NF','JP','FT','NDC','JUR') " + CRLF
		cQueryE1 += "AND SE1.E1_VENCREA < CONVERT(VARCHAR(8),GETDATE(),112) " + CRLF
		cQueryE1 := ChangeQuery(cQueryE1)
		_cAlias:= GetNextAlias() 	
		
		If Select(_cAlias) > 0;( _cAlias )->( dbCloseArea() );EndIf

		dbUseArea(.t., "TOPCONN", TCGenQry(,,cQueryE1), _cAlias, .t., .t.)
		( _cAlias )->( dbGoTop() )
		
		If ( ( _cAlias )->( !Eof() ) )     
			lRet := .F.

			SC6->(RecLock("SC6",.F.))
				SC6->C6_ZHISIFI	:= "BLOQUEIOS POR TITULOS EM ATRASO."	
			SC6->(MsUnlock())
			//U_GERHISC9(_cNumPV,_cItemPV,"BLOQUEIOS POR TITULOS EM ATRASO.") //Rafael Moraes Rosa Obify - 21/07/2022

		Else
			//peccore os itens de venda para somar o valor
			//Rafael Moraes Rosa Obify - 15/07/2022 - REGRA REPOSICIONADA (INICIO)
			/*
			For nI:=1 To Len(aCols)
				cDuplic := GetAdvfVal("SF4","F4_DUPLIC",xFilial("SF4")+aCols[nI][nTes],1)
				//verifica se a linha não esta deletada
				If !aCols[nI][Len(aHeader)+1] .and. aCols[nI][nTipoDip] == '1' .and. cDuplic == 'S'
					nTotal := nTotal + aCols[nI][nValor]     
				EndIf
			Next nI
			*/
			//Rafael Moraes Rosa Obify - 15/07/2022 - REGRA REPOSICIONADA (FIM)

			//QUERY PARA CONSULTA DE CREDITO DO CLIENTE
			
						
			//Rafael Moraes Rosa Obify - 08/12/2022
			cQueryE1 := "SELECT SUM(E1_SALDO) TOTAL_E1 FROM "+RetSqlName("SE1")+" SE1 " + CRLF
			cQueryE1 += "WHERE SE1.D_E_L_E_T_ ='' " + CRLF
			
			IF (_nSA1 = 1)
				cQueryE1 += "AND E1_CLIENTE ='"+cCodCli+"' " + CRLF
				cQueryE1 += "AND E1_LOJA ='"+cLoja+"' " + CRLF
			
			Else
				cQueryE1 += "AND E1_CLIENTE IN ("+_cGrupo+") " + CRLF

			Endif

			cQueryE1 += "AND E1_SALDO > 0 " + CRLF
			cQueryE1 += "AND E1_TIPO IN('NF','JP','FT','NDC','JUR') " + CRLF
			cQueryE1 += "GROUP BY E1_CLIENTE,E1_LOJA" + CRLF
			cQueryE1 := ChangeQuery(cQueryE1)
			_cAlias:= GetNextAlias() 	
			
			If Select(_cAlias) > 0;( _cAlias )->( dbCloseArea() );EndIf

			dbUseArea(.t., "TOPCONN", TCGenQry(,,cQueryE1), _cAlias, .t., .t.)
			( _cAlias )->( dbGoTop() )
			
			IF ( ( _cAlias )->( !Eof() ) )
				_nSA1LC		:= _nSA1LC - (_cAlias)->TOTAL_E1

			ENDIF
			//Rafael Moraes Rosa Obify - 08/12/2022 - FIM
			

			//If Empty(SA1->A1_XGRPCLI) //Rafael Moraes Rosa Obify - 15/07/2022 - CONDICAO ADICIONADA (INICIO)

			cQuery := "SELECT A1_RISCO FROM "+RetSqlName("SA1")+" SA1 " + CRLF
			cQuery += "WHERE SA1.D_E_L_E_T_ ='' " + CRLF

			//Rafael Moraes Rosa Obify - 20/07/2022 - Linha abaixo comentada
			IF (_nSA1 = 1)
				cQuery += "AND A1_COD ='"+cCodCli+"' " + CRLF
				cQuery += "AND A1_LOJA ='"+cLoja+"' " + CRLF
			
			//Rafael Moraes Rosa Obify - 20/07/2022 - REGRA BLOQUEADA (INICIO)
			
			else
				cQuery += "AND A1_COD IN ("+_cGrupo+") " + CRLF
			Endif
			
			//Rafael Moraes Rosa Obify - 20/07/2022 - REGRA BLOQUEADA (FIM)

				//cQuery += "AND A1_VENCLC >= CONVERT(VARCHAR(8),GETDATE(),112) " + CRLF
				cQuery += "AND "+Transform(_nSA1LC, "@R 9999999999.99")+" >  " + CRLF
				cQuery += "	(ISNULL((SELECT SUM(C9_QTDORI*C9_PRCVEN) TOTAL_C9 " + CRLF
				cQuery += "		FROM "+RetSqlName("SC9")+" C9 " + CRLF
				//cQuery += "		INNER JOIN "+RetSqlName("SC6")+" C6 ON C6_FILIAL = C9_FILIAL AND C6_NUM = C9_PEDIDO AND C6_PRODUTO = C9_PRODUTO AND C9_ITEM = C6_ITEM" + CRLF
				cQuery += "		INNER JOIN "+RetSqlName("SC5")+" C5 ON C5_FILIAL = C9_FILIAL AND C5_NUM = C9_PEDIDO " + CRLF
				cQuery += "		WHERE C9.D_E_L_E_T_='' " + CRLF
				//cQuery += "		AND C6.D_E_L_E_T_='' " + CRLF
				
				//=======================================================================
				// NÃO CONSIDERAR GRUPO, POIS A LIBERAÇÃO É POR PEDIDO - TEO - 14/09/2021
				//=======================================================================
				IF (_nSA1 = 1)
					cQuery += "AND C9_CLIENTE ='"+cCodCli+"' " + CRLF
					cQuery += "AND C9_LOJA ='"+cLoja+"' " + CRLF
			
				//Rafael Moraes Rosa Obify - 20/07/2022 - REGRA BLOQUEADA (INICIO)
			
				else
					cQuery += "AND C9_CLIENTE IN ("+_cGrupo+") " + CRLF
				Endif
				
				//cQuery += "		AND C9_CLIENTE ='"+cCodCli+"' AND C9_LOJA ='"+cLoja+"' " + CRLF
				cQuery += "		AND C9_NFISCAL ='' " + CRLF
				cQuery += "		AND C9_BLCRED ='' " + CRLF
				cQuery += "		AND C5_PRENOTA IN('','S') " + CRLF
				cQuery += "		AND C5_PARCIAL ='' " + CRLF
				//cQuery += "		GROUP BY C9_FILIAL,C9_CLIENTE,C9_LOJA " + CRLF
				cQuery += "		),0) " + CRLF
				/*cQuery += "		+ ISNULL((SELECT SUM(E1_SALDO) TOTAL_E1 FROM "+RetSqlName("SE1")+" SE1 " + CRLF
				cQuery += "		WHERE " + CRLF
				
				//Rafael Moraes Rosa Obify - 20/07/2022 - Linha abaixo comentada
				IF (_nSA1 = 1) //Rafael Moraes Rosa Obify - 15/07/2022 - REGRA LIBERADA
					cQuery += "			SE1.E1_CLIENTE='"+cCodCli+"' " + CRLF
					cQuery += "		AND SE1.E1_LOJA='"+cLoja+"' " + CRLF
				
				//Rafael Moraes Rosa Obify - 15/07/2022 - REGRA LIBERADA (INICIO)
				//Rafael Moraes Rosa Obify - 20/07/2022 - REGRA BLOQUEADA (INICIO)
				
				else
					cQuery += "			SE1.E1_CLIENTE IN ("+_cGrupo+") " + CRLF
				Endif
				
				//Rafael Moraes Rosa Obify - 20/07/2022 - REGRA BLOQUEADA (INICIO)
				//Rafael Moraes Rosa Obify - 15/07/2022 - REGRA LIBERADA (FIM)

				cQuery += "	    AND E1_TIPO IN('NF','FT') " + CRLF
				cQuery += "		AND SE1.E1_SALDO > 0 " + CRLF
				cQuery += "		AND E1_EMISSAO <> E1_VENCREA " + CRLF
				cQuery += "		AND SE1.D_E_L_E_T_='' " + CRLF
				cQuery += "		GROUP BY E1_CLIENTE,E1_LOJA),0)*/

				//Rafael Moraes Rosa Obify - 15/07/2022 - REGRA REPOSICIONADA (INICIO)
				For nI:=1 To Len(aCols)
					cDuplic := GetAdvfVal("SF4","F4_DUPLIC",xFilial("SF4")+aCols[nI][nTes],1)
					//verifica se a linha não esta deletada
					If !aCols[nI][Len(aHeader)+1] .and. aCols[nI][nTipoDip] == '1' .and. cDuplic == 'S'
						nTotal := nTotal + aCols[nI][nValor]     
					EndIf
				Next nI
				//Rafael Moraes Rosa Obify - 15/07/2022 - REGRA REPOSICIONADA (FIM)

				cQuery += "		+ ISNULL("+STR(nTotal)+",0)) " + CRLF
			
			//ENDIF //Rafael Moraes Rosa Obify - 15/07/2022 - CONDICAO ADICIONADA (FIM)

			cQuery := ChangeQuery(cQuery)
			_cAlias:= GetNextAlias() 	
			If Select(_cAlias) > 0;( _cAlias )->( dbCloseArea() );EndIf
			memowrite('\query\MAAVCRED.SQL',cQuery)
			dbUseArea(.t., "TOPCONN", TCGenQry(,,cQuery), _cAlias, .t., .t.)
			( _cAlias )->( dbGoTop() )
			If ( ( _cAlias )->( !Eof() ) )			     
				lRet := .T.
			
			ELSE //Rafael Moraes Rosa Obify - 21/07/2022
				lRet	:= .F.
				
				SC6->(RecLock("SC6",.F.))
					SC6->C6_ZHISIFI	:= "BLOQUEIOS POR LC EXCEDIDO."	
				SC6->(MsUnlock())
				//U_GERHISC9(_cNumPV,_cItemPV,"BLOQUEIO POR SALDO INSUFICIENTE NO LIMITE DE CREDITO.") //Rafael Moraes Rosa Obify - 21/07/2022

			EndIf
		EndIf

	ElseIf SA1->A1_RISCO =='A'
		lRet := .T.
	Else
		lRet := .F.
		SC6->(RecLock("SC6",.F.))
			SC6->C6_ZHISIFI	:= "BLOQUEIOS POR RISCO ELEVADO."	
		SC6->(MsUnlock())
	EndIf	
Else
	lRet := .T.	
EndIf

Return lRet


//_cGrupo	:= GrpCli(SA1->A1_XGRPCLI, @_nSA1, @_nSA1LC, 1)
//=====================================================
Static Function GrpCli(cAgrup,cSomLC,cCodCli,cLoja,_nSA1, _nSA1LC, nTipo)
//=====================================================
Local cQryAux   := GetNextAlias()
Local cCampo	:= ""
Local lGRP		:= .F.//Rafael Moraes Rosa - 15/09/2022 - INICIO

	//Rafael Moraes Rosa - 15/09/2022 - INICIO
	cQuery := "SELECT SA1.A1_CGC, SA1.A1_COD, SA1.A1_LOJA, SA1.A1_RISCO, SA1.A1_LC, SA1.A1_VENCLC, SA1.A1_ZSOMLC FROM "+RetSQLName("SA1")+" SA1 WHERE SA1.D_E_L_E_T_ <> '*' "

	If nTipo = 1
		cQuery	+= "AND A1_XGRPCLI = '"+cAgrup+"' "
		lGRP	:= .T.
	ELSEIF  nTipo = 2
		cQuery	+= "AND SUBSTRING(SA1.A1_CGC, 1, 8) = '"+Substr(cAgrup,1,8)+"' "
		lGRP	:= .T.
	ENDIF

	//Rafael Moraes Rosa - 06/10/2022 - INICIO
	//Tratamento para considerar a seguinte condicao
	//Se o cliente corresponder ao Grupo de Clientes, sera somado o LC quando for A1_ZSOMLC = Sim(1)
	IF nTipo = 1
		IF cSomLC = "1" .AND. lGRP	= .T.
				cQuery += "AND SA1.A1_ZSOMLC = '1' "
		ELSEIF cSomLC <> "1" .OR. lGRP	= .F.
			cQuery += "AND A1_COD = '" + cCodCli + "' AND A1_LOJA = '" + cLoja + "' "
		ENDIF
	ENDIF
	//Rafael Moraes Rosa - 06/10/2022 - FIM

	//Rafael Moraes Rosa - 06/10/2022 - INICIO
	//Tratamento para considerar a seguinte condicao
	//Se o cliente corresponder a CNPJ Raiz, sera somado o LC quando for A1_ZSOMLC = Sim(1) ou Vazio
	IF nTipo = 2
		IF cSomLC <> "2" .AND. lGRP	= .T.
				cQuery += "AND SA1.A1_ZSOMLC <> '2' "
		ELSEIF cSomLC = "2" .OR. lGRP	= .F.
			cQuery += "AND A1_COD = '" + cCodCli + "' AND A1_LOJA = '" + cLoja + "' "
		ENDIF
	ENDIF
	//Rafael Moraes Rosa - 06/10/2022 - FIM

	cQuery += "ORDER BY SA1.A1_CGC "
	//Rafael Moraes Rosa - 15/09/2022 - INICIO

cQuery := ChangeQuery(cQuery)
TcQuery cQuery NEW Alias &cQryAux
While (cQryAux)->(!Eof())
	If (cQryAux)->A1_RISCO <> 'B'
		_nSA1	:= 1 //Rafael Moraes Rosa - Correcao aplicada em 15/12/2022
		(cQryAux)->(DBSkip())
		Loop
	Endif
	If !Empty(cCampo)
		cCampo += ","
	Endif
	cCampo 	+="'"+(cQryAux)->A1_COD+"'"	 
	 //Rafael Moraes Rosa Obify - 15/07/2022 - REGRA AJUSTADA
	 //If (cQryAux)->A1_VENCLC > dtos(ddatabase)

		If (cQryAux)->A1_VENCLC > dtos(ddatabase)

		//Regra para realizar a somatoria do limite de credito de todos os cadastros
		//ESTA REGRA NAO ESTA EM USO NO MOMENTO (COMENTARIO DE Rafael Moraes Rosa Obify - 20/07/2022)
		//Verificar pois a referencia da SA1->A1_LC esta pegando do primeiro registro e nao do LC dos demais clientes Raiz
			_nSA1LC	+= (cQryAux)->A1_LC
		
		ENDIF

	_nSA1++
	(cQryAux)->(DBSkip())
Enddo
(cQryAux)->(dbCloseArea())
Return (cCampo)

/*
User Function GERHISC9(_cNumPV,_cItemPV,_cHistC9)

DbSelectArea("SC9")
SC9->(DbSetOrder(1))
MSGALERT("SC9. PV " + SC9->C9_NUM)
SC9->(dbSeek(xFilial("SC9")+_cNumPV + _cItemPV))
	SC9->(RecLock("SC9", .F.))
		SC9->C9_ZHISIFI	:= _cHistC9
SC9->(MsUnlock())
SC9->(dbSkip())

Return()
*/

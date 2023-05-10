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
Local _nSA1	 	:= 0
Local _nSA1LC	:= 0
Local nI

If ("MATA410" $ UPPER(Alltrim(FUNNAME())))
  
	nValor	:= Ascan(aHeader,{|x|Alltrim(X[2])=="C6_VALOR"}) //busca a posição do campo C6_VALOR
	nTipoDip:= Ascan(aHeader,{|x|Alltrim(X[2])=="C6_TIPODIP"})
	nTes    := Ascan(aHeader,{|x|Alltrim(X[2])=="C6_TES"})
	
	dbSelectArea("SA1")
	dbSeek(xFilial("SA1") + cCodCli + cLoja)

	_nSA1LC := SA1->A1_LC
	/*
	If !Empty(SA1->A1_XGRPCLI)
		_cGrupo	:= GrpCli(SA1->A1_XGRPCLI, @_nSA1, @_nSA1LC, 1)
	Else
		_cGrupo	:= GrpCli(SA1->A1_CGC	 , @_nSA1, @_nSA1LC, 2)
	Endif
	*/
	If Empty(_cGrupo)
		_cGrupo	+="'"+SA1->A1_COD+"'"
	Endif
	
	If _nSA1 = 1
		cA1_RISCO 	= SA1->A1_RISCO
	else
		cA1_RISCO = 'B'
	Endif

	If cA1_RISCO == 'B'

		cQueryE1 := "SELECT E1_VENCREA FROM "+RetSqlName("SE1")+" SE1 " + CRLF
		cQueryE1 += "WHERE SE1.D_E_L_E_T_ ='' " + CRLF
		//IF (_nSA1 = 1)
			cQueryE1 += "AND E1_CLIENTE ='"+cCodCli+"' " + CRLF
			cQueryE1 += "AND E1_LOJA ='"+cLoja+"' " + CRLF
		//Else
		//	cQueryE1 += "AND E1_CLIENTE IN ("+_cGrupo+") " + CRLF
		//Endif
		cQueryE1 += "AND E1_EMISSAO <> E1_VENCREA " + CRLF
		cQueryE1 += "AND E1_SALDO >0 " + CRLF
		cQueryE1 += "AND E1_TIPO IN('NF','JP','FT','NDC','JUR') " + CRLF
		cQueryE1 += "AND SE1.E1_VENCREA < CONVERT(VARCHAR(8),GETDATE(),112) " + CRLF
		cQueryE1 := ChangeQuery(cQueryE1)
		_cAlias:= GetNextAlias() 	
		If Select(_cAlias) > 0;( _cAlias )->( dbCloseArea() );EndIf
		dbUseArea(.t., "TOPCONN", TCGenQry(,,cQueryE1), _cAlias, .t., .t.)
		( _cAlias )->( dbGoTop() )
		If ( ( _cAlias )->( !Eof() ) )     
			lRet := .F.
		Else
			//peccore os itens de venda para somar o valor
			For nI:=1 To Len(aCols)
				cDuplic := GetAdvfVal("SF4","F4_DUPLIC",xFilial("SF4")+aCols[nI][nTes],1)
				//verifica se a linha não esta deletada
				If !aCols[nI][Len(aHeader)+1] .and. aCols[nI][nTipoDip] == '1' .and. cDuplic == 'S'
					nTotal := nTotal + aCols[nI][nValor]     
				EndIf
			Next nI

			//QUERY PARA CONSULTA DE CREDITO DO CLIENTE

			cQuery := "SELECT A1_RISCO FROM "+RetSqlName("SA1")+" SA1 " + CRLF
			cQuery += "WHERE SA1.D_E_L_E_T_ ='' " + CRLF
			IF (_nSA1 = 1)
				cQuery += "AND A1_COD ='"+cCodCli+"' " + CRLF
				cQuery += "AND A1_LOJA ='"+cLoja+"' " + CRLF
			else
				cQuery += "AND A1_COD IN ("+_cGrupo+") " + CRLF
			Endif
			cQuery += "AND A1_VENCLC >= CONVERT(VARCHAR(8),GETDATE(),112) " + CRLF
			cQuery += "AND "+Transform(_nSA1LC, "@R 9999999999.99")+" >  " + CRLF
			cQuery += "	(ISNULL((SELECT SUM(C9_QTDORI*C9_PRCVEN) TOTAL_C9 " + CRLF
			cQuery += "		FROM "+RetSqlName("SC9")+" C9 " + CRLF
			cQuery += "		INNER JOIN "+RetSqlName("SC6")+" C6 ON C6_FILIAL = C9_FILIAL AND C6_NUM = C9_PEDIDO AND C6_PRODUTO = C9_PRODUTO AND C9_ITEM = C6_ITEM" + CRLF
			cQuery += "		INNER JOIN "+RetSqlName("SC5")+" C5 ON C5_FILIAL = C9_FILIAL AND C5_NUM = C9_PEDIDO " + CRLF
			cQuery += "		WHERE C9.D_E_L_E_T_='' " + CRLF
			cQuery += "		AND C6.D_E_L_E_T_='' " + CRLF
			
			//=======================================================================
			// NÃO CONSIDERAR GRUPO, POIS A LIBERAÇÃO É POR PEDIDO - TEO - 14/09/2021
			//=======================================================================
			cQuery += "		AND C9_CLIENTE ='"+cCodCli+"' AND C9_LOJA ='"+cLoja+"' " + CRLF
			//
			cQuery += "		AND C9_NFISCAL ='' " + CRLF
			cQuery += "		AND C9_BLCRED ='' " + CRLF
			cQuery += "		AND C5_PRENOTA IN('','S') " + CRLF
			cQuery += "		AND C5_PARCIAL ='' " + CRLF
			cQuery += "		GROUP BY C9_FILIAL,C9_CLIENTE,C9_LOJA),0)+ISNULL((SELECT SUM(E1_SALDO) TOTAL_E1 " + CRLF
			cQuery += "		FROM "+RetSqlName("SE1")+" SE1 " + CRLF
			cQuery += "		WHERE " + CRLF
			//IF (_nSA1 = 1)		
				cQuery += "			SE1.E1_CLIENTE='"+cCodCli+"' " + CRLF
				cQuery += "		AND SE1.E1_LOJA='"+cLoja+"' " + CRLF
			//else
			//	cQuery += "			SE1.E1_CLIENTE IN ("+_cGrupo+") " + CRLF
			//Endif
			cQuery += "	    AND E1_TIPO IN('NF','FT') " + CRLF
			cQuery += "		AND SE1.E1_SALDO > 0 " + CRLF
			cQuery += "		AND E1_EMISSAO <> E1_VENCREA " + CRLF
			cQuery += "		AND SE1.D_E_L_E_T_='' " + CRLF
			cQuery += "		GROUP BY E1_CLIENTE,E1_LOJA),0) + ISNULL("+STR(nTotal)+",0)) " + CRLF
			cQuery := ChangeQuery(cQuery)
			_cAlias:= GetNextAlias() 	
			If Select(_cAlias) > 0;( _cAlias )->( dbCloseArea() );EndIf
			memowrite('\query\MAAVCRED.SQL',cQuery)
			dbUseArea(.t., "TOPCONN", TCGenQry(,,cQuery), _cAlias, .t., .t.)
			( _cAlias )->( dbGoTop() )
			If ( ( _cAlias )->( !Eof() ) )			     
				lRet := .T.
			EndIf
		EndIf

	ElseIf SA1->A1_RISCO =='A'
		lRet := .T.
	Else
		lRet := .F.
	EndIf	
Else
	lRet := .T.	
EndIf

Return lRet

//=====================================================
Static Function GrpCli(cAgrup, _nSA1, _nSA1LC, nTipo)
//=====================================================
Local cQryAux   := GetNextAlias()
Local cCampo	:= ""
If nTipo = 1
	cQuery := "SELECT SA1.A1_CGC, SA1.A1_COD, SA1.A1_LOJA, SA1.A1_RISCO, SA1.A1_LC, SA1.A1_VENCLC FROM "+RetSQLName("SA1")+" SA1 WHERE A1_XGRPCLI = '"+cAgrup+"' AND SA1.D_E_L_E_T_ <> '*' ORDER BY SA1.A1_CGC "
else
	cQuery := "SELECT SA1.A1_CGC, SA1.A1_COD, SA1.A1_LOJA, SA1.A1_RISCO, SA1.A1_LC, SA1.A1_VENCLC FROM "+RetSQLName("SA1")+" SA1 WHERE SUBSTRING(SA1.A1_CGC, 1, 8) = '"+Substr(cAgrup,1,8)+"' AND SA1.D_E_L_E_T_ <> '*' ORDER BY SA1.A1_CGC "
Endif
cQuery := ChangeQuery(cQuery)
TcQuery cQuery NEW Alias &cQryAux
While (cQryAux)->(!Eof())
	If (cQryAux)->A1_RISCO <> 'B'
		(cQryAux)->(DBSkip())
		Loop
	Endif
	If !Empty(cCampo)
		cCampo += ","
	Endif
	cCampo 	+="'"+(cQryAux)->A1_COD+"'"
	If (cQryAux)->A1_VENCLC > dtos(ddatabase)
		_nSA1LC	+= SA1->A1_LC
	Endif
	_nSA1++
	(cQryAux)->(DBSkip())
Enddo
(cQryAux)->(dbCloseArea())
Return (cCampo)


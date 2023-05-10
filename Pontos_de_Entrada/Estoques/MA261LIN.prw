#INCLUDE "Protheus.ch"
/*====================================================================================\
|Programa  | MA261LIN                       | Autor | GIOVANI.ZAGO| Data | 15/09/2011 |
|=====================================================================================|
|Descrição | ponto  de entrada para validar linha da transferencia                    |
|          |                                                                          |
|          |                                                                          |
|=====================================================================================|
|Sintaxe   |                                                                          |
|=====================================================================================|
|Uso       | Especifico DIPROMED                                                      |
|=====================================================================================|
|........................................Histórico....................................|
\====================================================================================*/

*---------------------------------------------------*
User Function MA261LIN ( )
*---------------------------------------------------*

Local lRet      := .T.
Local _cQuery   := " "
Local nCont     := 0
Local nQuaAcols := aCols[n,16]
Local _nConAc   := 0
Local _nValor   := 0
Local CCodProd  := aCols[n,1]

If ("MATA261") $ FunName() .or. ("MATA260") $ FunName()
	If  nQuaAcols >  0  .and. aCols[n,9] <> aCols[n,4]    .and. "MATA261" $ FunName()   //verifica se possui qtd no acols
		
		
		_cQuery := " SELECT B2_QATU - B2_RESERVA AS 'QUANTIDADE'  "
		_cQuery += " FROM "+ RetSqlName("SB2")
		_cQuery += " WHERE B2_FILIAL = '"+xFilial("SB2")+"'"
		_cQuery += " AND B2_COD = '"+aCols[n,1]+"'  "
		_cQuery += " AND B2_LOCAL = '"+aCols[n,4]+"'  "
		_cQuery += " AND D_E_L_E_T_ = ' '  "
		
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQuery),'TB2',.T.,.T.)
		
		If !Empty("TB2")
			For _nConAc := 1 to Len(aCols)
				If 	!aCols[_nConAc,Len(aHeader)+1]    .and. aCols[_nConAc,1] = CCodProd
					_nValor := _nValor + aCols[_nConAc,16]
					
				EndIf
				
			next _nConAc
			
			TB2->(DbGoTop())
			Do While TB2->(!Eof())
				nCont :=    nCont+1
				TB2->(DbSkip())
			EndDo
			
			If nCont = 1
				TB2->(DbGoTop())
				If ( TB2->QUANTIDADE  ) < _nValor
					MsgInfo("Produto possui quantidade reservada o saldo disponível para esta operação é  "+(cvaltochar( TB2->QUANTIDADE - (_nValor-nQuaAcols))),"Atencao!")
					lRet := .F.
				Endif
			ElseIf nCont > 1
				MsgInfo("Produto com erro avisar departamento de T.I. ","Atencao!")
				lRet := .F.
			Endif
		Endif
		TB2->(DbCloseArea())
	Endif
	
	If  aCols[n,12] <> aCols[n,20]  .And.	aCols[n,14] > aCols[n,21]
		alert("Data de Validade Incorreta, Ajuste a Data de Validade do Lote de Destino")
		lRet := .F.
	Endif
	
	If Empty(aCols[n,23])
		alert("Preencha o Campo de Explicação !!!!!!!!!")
		lRet := .F.
	ElseIf len(alltrim(aCols[n,23]))< 25 .and. !Empty(aCols[n,23])
		alert("Explicação Invalida!!!!!!!!!")
		lRet := .F.
	Endif
Endif
Return(lRet)



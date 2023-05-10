/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³ DIPA013  º Autor ³   Alexandro Dias   º Data ³  20/02/02   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Efetua a transferencia entre almoxarIFados do produto para º±±
±±º          ³ atender a quantidade do pedido.				      			  º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

#Include "RwMake.ch"

User Function DIPA013(aCols,aHeader,_cPedido,Inclui)

Local _nPosQtdVen
Local _nPosProd  
Local _nPosQtdLib
Local _nPosEmpenho
Local _nPosLocal  
Local _aArea         := GetArea()
Local _aAreaSB1      := SB1->(GetArea())
Local _aAreaSB2      := SB2->(GetArea())
Local _aAreaSB8      := SB8->(GetArea())
Local _aAreaSBF      := SBF->(GetArea())
Local _aAreaSC9      := SC9->(GetArea())
Local _aAreaSD3      := SD3->(GetArea())
Local _aAreaSD5      := SD5->(GetArea())
Local _aAreaSDB      := SDB->(GetArea())
Local _aAreaSDA      := SDA->(GetArea())
Local _nEstoqSB2     := 0
Local _nQuantInicial := 0
Local _aSldLotes     := {}
Local _nQtReserva    := 0
Local cCodOrig,cCodDest,cUmOrig,cUmDest,cLocOrig,cLocDest,nQuant260,;
nQuant260D,cDocto,dEmis260,cLoteDigi,dDtValid,cLoclzOrig,cLoclzDest,;
cNumLote,cNumSerie,nRecOrig,nRecDest,cNumSeq,_nRecSB8,_nQtEmpenh
U_DIPPROC(ProcName(0),U_DipUsr()) // JBS 05/10/2005 - Gravando o nome do Programa no SZU
IF FunName(0) == "MATA410"
	_nPosQtdVen    := aScan(aHeader, { |x| Alltrim(x[2]) == "C6_QTDVEN"  })
	_nPosProd      := aScan(aHeader, { |x| Alltrim(x[2]) == "C6_PRODUTO" })
	_nPosQtdLib    := aScan(aHeader, { |x| Alltrim(x[2]) == "C6_QTDLIB"  })
	_nPosEmpenho   := aScan(aHeader, { |x| Alltrim(x[2]) == "C6_SLDEMPE" })
	_nPosLocal     := aScan(aHeader, { |x| Alltrim(x[2]) == "C6_LOCAL"   })
EndIF

PRIVATE cCusMed  := GetMv("MV_CUSMED")
IF cCusMed == "O"
	PRIVATE nHdlPrv // Endereco do arquivo de contra prova dos lanctos cont.
	PRIVATE lCriaHeader := .T. // Para criar o header do arquivo Contra Prova
	PRIVATE cLoteEst 	// Numero do lote para lancamentos do estoque
	
	//³ Posiciona numero do Lote para Lancamentos do Faturamento     ³
	dbSelectArea("SX5")
	dbSeek(xFilial()+"09EST")
	cLoteEst:=IIF(Found(),Trim(X5Descri()),"EST ")
	PRIVATE nTotal := 0 	// Total dos lancamentos contabeis
	PRIVATE cArquivo	// Nome do arquivo contra prova
EndIF

//³ Efetua o Estorno da transferencia entre os almoxarIFados quando o pedido ³
//³ e' alterado ou Excluido 								 				 ³
IF ( !Inclui )
	DbSelectArea("SC9")
	DbSetOrder(1)
	IF DbSeek(xFilial("SC9")+_cPedido)
		IF ( SC9->C9_BLCRED != "10" .and. SC9->C9_BLEST != "10" )
			
			//³Efetua o estorno das movimentacoes internas                        ³
			IF !Rastro(SC9->C9_PRODUTO)
				U_TranfLocal(SC9->C9_PRODUTO, , , ,"M"+Substr(_cPedido,2,5),.T.)
			Else
				DbSelectArea("SD3")
				DbSetOrder(2)
				SD3->(DbSeek( xFilial("SD3") + "M"+Substr(_cPedido,2,5) + SC9->C9_PRODUTO ) )
				While !Eof() .And. xFilial("SD3") == SD3->D3_FILIAL ;
					.And. SD3->D3_DOC == "M"+Substr(_cPedido,2,5) ;
					.And. SD3->D3_COD == SC9->C9_PRODUTO
					IF SD3->D3_ESTORNO != "S"
						DbSetOrder(4)
						cNumSeq := SD3->D3_NUMSEQ
						SD3->(DbSeek(xFilial("SD3")+cNumSeq) )
						nRecOrig := RecNo()
						cCodOrig := SD3->D3_COD
						cUmOrig  := SD3->D3_UM
						cLocOrig := SD3->D3_LOCAL
						cLoclzOrig := SD3->D3_LOCALIZ
						cNumLote := SD3->D3_NUMLOTE
						cNumSerie:= SD3->D3_NUMSERI
						SD3->(dbSkip())
						nRecDest  := RecNo()
						cCodDest  := SD3->D3_COD
						cUmDest   := SD3->D3_UM
						cLocDest  := SD3->D3_LOCAL
						cLoclzDest:= SD3->D3_LOCALIZ
						nQuant260 := SD3->D3_QUANT
						_nQtEmpenh:= SD3->D3_QUANT
						nQuant260D:= SD3->D3_QTSEGUM
						cLoteDigi := SD3->D3_LOTECTL
						dDtValid  := SD3->D3_DTVALID
						cDocto    := SD3->D3_DOC
						dEmis260  := SD3->D3_EMISSAO
						
						DbSelectArea("SB8")
						DbSetOrder(3)
						SB8->(DbSeek( xFilial("SB8") + cCodDest +  cLocDest + cLoteDigi ) )
						While !Eof() .And. xFilial("SB8") == SB8->B8_FILIAL ;
							.And. SB8->B8_PRODUTO  == cCodDest ;
							.And. SB8->B8_LOCAL    == cLocDest ;
							.And. SB8->B8_LOTECTL  == cLoteDigi
							
							RecLock("SB8",.F.)
							IF SB8->B8_EMPENHO >= _nQtEmpenh
								Replace B8_EMPENHO With SB8->B8_EMPENHO //- nQuant260
								_nQtReserva := _nQtReserva + nQuant260
							Else
								_nQtEmpenh := _nQtEmpenh - SB8->B8_EMPENHO
								_nQtReserva := _nQtReserva + SB8->B8_EMPENHO
								Replace B8_EMPENHO With 0
							EndIF
							SB8->(MsUnLock())
							DbSkip()
						EndDo
						
						//³ Verifica se o produto destino tem saldo p/ estornar ³
						If !MatVldEst(cCodDest,	cLocDest,cLoteDigi,	SD3->D3_NUMLOTE,;
							cLocLzDest,cNumSerie,cNumSeq,cDocto,nQuant260)
							Return(.T.)
						EndIf
						a260Processa(cCodOrig,cLocOrig,nQuant260,cDocto,dEmis260,nQuant260D,;
						cNumLote,cLoteDigi,dDtValid,cNumSerie,cLoclzOrig,cCodDest,cLocDest,;
						cLocLzDest,.T.,nRecOrig,nRecDest,"MATA260")
						DbSelectArea("SB2")
						DbSetOrder(1)
						IF SB2->(DbSeek( xFilial("SB2")+SC9->C9_PRODUTO+SC9->C9_LOCAL ))
 							RecLock("SB2",.F.)
							IF SB2->B2_RESERVA >= nQuant260
								Replace B2_RESERVA With B2_RESERVA //- nQuant260
							Else
								Replace B2_RESERVA With 0
							EndIF
							SB2->(MsUnlock())
						EndIF
					EndIF
					DbSelectArea("SD3")
					DbSkip()
				EndDo
			EndIF
		EndIF
	ENDIF
EndIF

//³ Efetua a leitura do aCols para avaliar a necessidade de transferencia entre os almoxarIFados ³
IF FunName(0) == "MATA410"
	For _nLin := 1 to Len(aCols)
		
		//³ Avalia somente quando e' informada a quantidade a ser liberada ³
		IF aCols[_nLin,_nPosQtdLib] > 0
			
			//³ Armazena a quantidade requisitada do almoxarifado 02.          ³
			SB1->(DbSetOrder(1))
			IF SB1->(DbSeek( xFilial("SB1") + aCols[_nLin,_nPosProd] ))
				_nQuantInicial := aCols[_nLin,_nPosQtdVen]
				SB2->(DbSetOrder(1))
				IF SB2->(DbSeek( xFilial("SB2") + aCols[_nLin,_nPosProd] + "01" ))
					
					//³ Avalia o saldo em estoque do produto (Local 01) inclusive a quantidade ja empenhada ³
					//³ no pedido.(A quantidade ja empenhada somente e' considerada na alteracao do pedido)	³
					_nEstoqSB2 := SaldoSb2() + ( aCols[_nLin,_nPosEmpenho] - _nQtReserva )
					IF _nEstoqSB2 < _nQuantInicial
						_nQuantInicial := _nQuantInicial - _nEstoqSB2
						
						//³ Avalia o saldo em estoque do produto (Local 02)  ³
						SB2->(DbSetOrder(1))
						IF SB2->(DbSeek( xFilial("SB2") + aCols[_nLin,_nPosProd] + "02" ))
							_nEstoqSB2 := SaldoSb2()
							IF _nEstoqSB2 > 0
								
								//³ Gera as movimentacoes de requisicao/devolucao entre os almoxarIFados ³
								IF !Rastro(aCols[_nLin,_nPosProd])
									
									_cDoc := "M"+Substr(_cPedido,2,5)
									MaTrfLocal(aCols[_nLin,_nPosProd],"02","01",IIF(_nQuantInicial>=_nEstoqSB2,_nEstoqSB2,_nQuantInicial),"M"+Substr(_cPedido,2,5),.F.)
									_cSeq := 0
									dbSelectArea("SD3")
									dbSetOrder(2)
									If SD3->(DbSeek(xFilial("SD3")+_cDoc+SB1->B1_COD))
										While (!Eof() .And. _cDoc == SD3->D3_DOC .And. aCols[_nLin,_nPosProd] == SD3->D3_COD)
											If (SD3->D3_ESTORNO==" ")
												_cSeq := SD3->D3_NUMSEQ
												EXIT
											EndIf
											dbSelectArea("SD3")
											dbSkip()
										EndDo
									ENDIF
									DbSelectArea("SDA")
									DbSetOrder(1)
									IF DbSeek( xFilial("SDA")+aCols[_nLin,_nPosProd]+"01"+_cSeq+_cDoc)
										RecLock("SDA",.F.)
										SDA->DA_SALDO := 0
										SDA->(MsUnLock())
										
										DbSelectArea("SDB")
										RecLock("SDB",.T.)
										SDB->DB_FILIAL   := SDA->DA_FILIAL
										SDB->DB_ITEM     := "001"
										SDB->DB_PRODUTO  := SDA->DA_PRODUTO
										SDB->DB_QUANT    := SDA->DA_QTDORI
										SDB->DB_DATA     := SDA->DA_DATA
										SDB->DB_LOTECTL  := SDA->DA_LOTECTL
										SDB->DB_NUMLOTE  := SDA->DA_NUMLOTE
										SDB->DB_LOCAL    := SDA->DA_LOCAL
										SDB->DB_LOCALIZ  := "      EXPEDICAO"
										SDB->DB_DOC      := SDA->DA_DOC
										SDB->DB_SERIE    := SDA->DA_SERIE
										SDB->DB_CLIFOR   := SDA->DA_CLIFOR
										SDB->DB_LOJA     := SDA->DA_LOJA
										SDB->DB_TIPONF   := SDA->DA_TIPONF
										SDB->DB_TM       := "499"
										SDB->DB_ORIGEM   := SDA->DA_ORIGEM
										SDB->DB_NUMSEQ   := SDA->DA_NUMSEQ
										SDB->DB_TIPO     := "M"
										SDB->DB_EMPENHO  := SDA->DA_EMPENHO
										SDB->DB_QTSEGUM  := SDA->DA_QTSEGUM
										SDB->DB_EMP2     := SDA->DA_EMP2
										SDB->(MsUnLock())
										
										DbSelectArea("SBF")
										DbSetOrder(6)
										IF DbSeek( xFilial("SBF")+aCols[_nLin,_nPosProd]+"01"+"      EXPEDICAO")
											RecLock("SBF",.F.)
											SBF->BF_QUANT := SBF->BF_QUANT + SDA->DA_QTDORI
											SBF->(MsUnLock())
										ELSE
											RecLock("SBF",.T.)
											SBF->BF_FILIAL   := SDA->DA_FILIAL
											SBF->BF_PRODUTO  := SDA->DA_PRODUTO
											SBF->BF_LOCAL    := SDA->DA_LOCAL
											SBF->BF_PRIOR    := ""
											SBF->BF_LOCALIZ  := "      EXPEDICAO"
											SBF->BF_NUMSERI  := ""
											SBF->BF_LOTECTL  := SDA->DA_LOTECTL
											SBF->BF_NUMLOTE  := ""
											SBF->BF_QUANT    := SDA->DA_QTDORI
											SBF->BF_EMPENHO  := 0
											SBF->BF_QEMPPRE  := 0
											SBF->BF_QTSEGUM  := 0
											SBF->BF_EMPEN2   := 0
											SBF->BF_QEPRE2   := 0
											SBF->(MsUnLock())
										ENDIF
									ENDIF
									DbSelectArea("SB2")
									DbSetOrder(1)
									IF DbSeek( xFilial("SB2")+aCols[_nLin,_nPosProd]+"01")
										RecLock("SB2",.F.)
										SB2->B2_QACLASS := SB2->B2_QACLASS - SDA->DA_QTDORI
										SB2->(MsUnlock())
									ENDIF
									
									//³ Armazena a quantidade requisitada do almoxarifado 02.          ³
								Else
									_cDoc := "M"+Substr(_cPedido,2,5)
									DbSelectArea("SB8")
									DbSetOrder(1)
									SB8->(DbSeek( xFilial("SB8") + aCols[_nLin,_nPosProd] + "02" ))
									While SB8->(!Eof()) .And. xFilial("SB8") == SB8->B8_FILIAL ;
										.And. SB8->B8_PRODUTO == aCols[_nLin,_nPosProd] ;
										.And. SB8->B8_LOCAL == "02"
										_nRecSB8 := Recno()
										IF SB8->B8_SALDO >= _nQuantInicial
											a260Processa(aCols[_nLin,_nPosProd],"02",	_nQuantInicial,;
											"M"+Substr(_cPedido,2,5),dDataBase,0,"",SB8->B8_LOTECTL,;
											SB8->B8_DTVALID,SB8->B8_SERIE,"",aCols[_nLin,_nPosProd],"01",;
											"",	.F.,NIL,NIL,"MATA260")
											Exit
										Else
											IF SB8->B8_SALDO > 0
												a260Processa(aCols[_nLin,_nPosProd],"02",	SB8->B8_SALDO,;
												"M"+Substr(_cPedido,2,5),dDataBase,0,"",SB8->B8_LOTECTL,;
												SB8->B8_DTVALID,SB8->B8_SERIE,"",aCols[_nLin,_nPosProd],"01",;
												"",	.F.,NIL,NIL,"MATA260")
											EndIF
											_nQuantInicial := _nQuantInicial - SB8->B8_SALDO
										EndIF
										IF _nQuantInicial <= 0
											Exit
										EndIF
										DbSelectArea("SB8")
										DbGoto(_nRecSB8)
										SB8->(DbSkip())
									EndDo
									_cSeq := 0
									dbSelectArea("SD3")
									SD3->(dbSetOrder(2))
									If SD3->(DbSeek(xFilial("SD3")+_cDoc+SB1->B1_COD))
										While (SD3->(!Eof()) .And. _cDoc == SD3->D3_DOC .And. aCols[_nLin,_nPosProd] == SD3->D3_COD)
											If (SD3->D3_ESTORNO==" ")
												_cSeq := SD3->D3_NUMSEQ
												EXIT
											EndIf
											dbSelectArea("SD3")
											SD3->(dbSkip())
										EndDo
									ENDIF
									DbSelectArea("SDA")
									SDA->(DbSetOrder(1))
									IF SDA->(DbSeek( xFilial("SDA")+aCols[_nLin,_nPosProd]+"01"+_cSeq+_cDoc))
										RecLock("SDA",.F.)
										SDA->DA_SALDO := 0
										SDA->(MsUnLock())
										
										DbSelectArea("SDB")
										RecLock("SDB",.T.)
										SDB->DB_FILIAL   := SDA->DA_FILIAL
										SDB->DB_ITEM     := "001"
										SDB->DB_PRODUTO  := SDA->DA_PRODUTO
										SDB->DB_QUANT    := SDA->DA_QTDORI
										SDB->DB_DATA     := SDA->DA_DATA
										SDB->DB_LOTECTL  := SDA->DA_LOTECTL
										SDB->DB_NUMLOTE  := SDA->DA_NUMLOTE
										SDB->DB_LOCAL    := SDA->DA_LOCAL
										SDB->DB_LOCALIZ  := "      EXPEDICAO"
										SDB->DB_DOC      := SDA->DA_DOC
										SDB->DB_SERIE    := SDA->DA_SERIE
										SDB->DB_CLIFOR   := SDA->DA_CLIFOR
										SDB->DB_LOJA     := SDA->DA_LOJA
										SDB->DB_TIPONF   := SDA->DA_TIPONF
										SDB->DB_TM       := "499"
										SDB->DB_ORIGEM   := SDA->DA_ORIGEM
										SDB->DB_NUMSEQ   := SDA->DA_NUMSEQ
										SDB->DB_TIPO     := "M"
										SDB->DB_EMPENHO  := SDA->DA_EMPENHO
										SDB->DB_QTSEGUM  := SDA->DA_QTSEGUM
										SDB->DB_EMP2     := SDA->DA_EMP2
										SDB->(MsUnLock())
										
										DbSelectArea("SBF")
										SBF->(DbSetOrder(6))
										IF SBF->(DbSeek( xFilial("SBF")+aCols[_nLin,_nPosProd]+"01"+"      EXPEDICAO"))
											RecLock("SBF",.F.)
											SBF->BF_QUANT := SBF->BF_QUANT + SDA->DA_QTDORI
											SBF->(MsUnLock())
										ELSE
											RecLock("SBF",.T.)
											SBF->BF_FILIAL   := SDA->DA_FILIAL
											SBF->BF_PRODUTO  := SDA->DA_PRODUTO
											SBF->BF_LOCAL    := SDA->DA_LOCAL
											SBF->BF_PRIOR    := ""
											SBF->BF_LOCALIZ  := "      EXPEDICAO"
											SBF->BF_NUMSERI  := ""
											SBF->BF_LOTECTL  := SDA->DA_LOTECTL
											SBF->BF_NUMLOTE  := ""
											SBF->BF_QUANT    := SDA->DA_QTDORI
											SBF->BF_EMPENHO  := 0
											SBF->BF_QEMPPRE  := 0
											SBF->BF_QTSEGUM  := 0
											SBF->BF_EMPEN2   := 0
											SBF->BF_QEPRE2   := 0
											SBF->(MsUnLock())
										ENDIF
										DbSelectArea("SB2")
										SB2->(DbSetOrder(1))
										IF SB2->(DbSeek( xFilial("SB2")+aCols[_nLin,_nPosProd]+"01"))
											RecLock("SB2",.F.)
											SB2->B2_QACLASS := SB2->B2_QACLASS - SDA->DA_QTDORI
											SB2->(MsUnlock())
										ENDIF
									ENDIF
								EndIF
							EndIF
						EndIF
					EndIF
				EndIF
			EndIF
		EndIF
	Next
EndIF

//³ Restaura os ponteiros dos arquivos
RestArea(_aAreaSB1)
RestArea(_aAreaSB2)
RestArea(_aAreaSB8)
RestArea(_aAreaSBF)
RestArea(_aAreaSC9)
RestArea(_aAreaSD3)
RestArea(_aAreaSD5)
RestArea(_aAreaSDB)
RestArea(_aAreaSDA)

RestArea(_aArea)

Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Funcao    ³MaTrfLocal³ Autor ³Eduardo Riera          ³ Data ³19.03.99  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Efetua a transferencia de Locais                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: Produto                                              ³±±
±±³          ³ExpC2: Local de Origem                                      ³±±
±±³          ³ExpC3: Local de Destino                                     ³±±
±±³          ³ExpN4: Quantidade                                           ³±±
±±³          ³ExpC5: Documento                                            ³±±
±±³          ³ExpL6: Indica se eh um estorno                              ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
USER Function TranfLocal(cCodPro,cOrigem,cDestino,nQuant,cDocumento,lEstorno)

Local aArea		:= GetArea()
Local aAreaSB1	:= SB1->(GetArea())
Local aAreaSB2	:= SB2->(GetArea())
Local aAreaSD3	:= SD3->(GetArea())
Local aAreaSDB	:= SDB->(GetArea())
Local cNumSeq	:= ProxNum()
Local aCm		:= {}
Local aSd3		:= {}
Local nCntFor	:= 0
Local nCntFor2	:= 0
_cSeq := "0"
_cD3 := 0
dbSelectArea("SB1")
dbSetOrder(1)
MsSeek(xFilial("SB1")+cCodPro)
If !lEstorno
	
	//³Requisicao do produto e local de origem                                 ³
	dbSelectArea("SB2")
	dbSetOrder(1)
	If ( !MsSeek(xFilial("SB2")+SB1->B1_COD+cOrigem) )
		CriaSB2( SB1->B1_COD,cOrigem )
	EndIf

	// Tirei Eriberto 10/03/2003 RecLock("SB2",.F.)

	aCM := PegaCMAtu(SB1->B1_COD,cOrigem)
	
	RecLock("SD3",.T.)
	SD3->D3_FILIAL  := xFilial("SD3")
	SD3->D3_COD     := SB1->B1_COD
	SD3->D3_QUANT   := nQuant
	SD3->D3_CF      := "RE4"
	SD3->D3_CHAVE   := "E0"
	SD3->D3_LOCAL   := cOrigem
	SD3->D3_DOC     := cDocumento
	SD3->D3_EMISSAO := dDatabase
	SD3->D3_UM      := SB1->B1_UM
	SD3->D3_GRUPO   := SB1->B1_GRUPO
	SD3->D3_TIPO    := SB1->B1_TIPO
	SD3->D3_NUMSEQ  := cNumSeq
	SD3->D3_QTSEGUM := ConvUm(SB1->B1_COD,nQuant,0,2)
	SD3->D3_SEGUM   := SB1->B1_SEGUM
	SD3->D3_PARCTOT := ""
	SD3->D3_TM      := "999"
	SD3->(MsUnlock())
	
	aCusto := GravaCusD3(aCM)
	
	B2AtuComD3(aCusto)
	
	//³Cria almoxarifado de destino                                            ³
	dbSelectArea("SB2")
	dbSetOrder(1)
	If ( !MsSeek(xFilial("SB2")+SB1->B1_COD+cDestino) )
		CriaSB2( SB1->B1_COD,cDestino )
	EndIf
	
	// Tirei Eriberto 10/03/2003 RecLock("SB2",.F.)
	
	RecLock("SD3",.T.)
	SD3->D3_FILIAL  := xFilial("SD3")
	SD3->D3_COD     := SB1->B1_COD
	SD3->D3_QUANT   := nQuant
	SD3->D3_CF      := "DE4"
	SD3->D3_CHAVE   := "E9"
	SD3->D3_LOCAL   := cDestino
	SD3->D3_DOC     := cDocumento
	SD3->D3_EMISSAO := dDatabase
	SD3->D3_UM      := SB1->B1_UM
	SD3->D3_GRUPO   := SB1->B1_GRUPO
	SD3->D3_TIPO    := SB1->B1_TIPO
	SD3->D3_NUMSEQ  := cNumSeq
	SD3->D3_QTSEGUM := ConvUm(SB1->B1_COD,nQuant,0,2)
	SD3->D3_SEGUM   := SB1->B1_SEGUM
	SD3->D3_PARCTOT := ""
	SD3->D3_TM      := "499"
	SD3->(MsUnlock())
	
	aCusto := GravaCusD3(aCM)
	
	B2AtuComD3(aCusto)
	
Else
	dbSelectArea("SD3")
	dbSetOrder(2)
	if dbSeek(xFilial("SD3")+cDocumento+cCodPro)
		While ( !Eof() .And. cDocumento== SD3->D3_DOC .And. cCodPro == SD3->D3_COD )
			If ( SD3->D3_ESTORNO==" " )
				aadd(aSd3,{})
				For nCntFor := 1 To SD3->(FCount())
					aadd(aSD3[Len(aSD3)],SD3->(FieldGet(nCntFor)))
				Next nCntFor
				_cSeq := SD3->D3_NUMSEQ
				_cD3 := 1
				RecLock("SD3",.F.)
				SD3->D3_ESTORNO := "S"
				SD3->(MsUnlock())
			EndIf
			dbSelectArea("SD3")
			dbSkip()
		EndDo
	endif
	For nCntFor := 1 To Len(aSd3)
		RecLock("SD3",.T.)
		
		For nCntFor2 := 1 To Len(aSd3[nCntFor])
			SD3->(FieldPut(nCntFor2,aSd3[nCntFor][nCntFor2]))
		Next nCntFor2
		
		aCm	:= PegaCMAtu(SD3->D3_COD,SD3->D3_LOCAL)
		
		If ( SD3->D3_CF == "DE4" )
			SD3->D3_CF 		:= "RE4"
			SD3->D3_CHAVE	:= "E0"
			SD3->D3_TM		:= "999"
			SD3->D3_ESTORNO:= "S"
			SD3->D3_EMISSAO:= dDataBase
		Else
			SD3->D3_CF 		:= "DE4"
			SD3->D3_CHAVE	:= "E9"
			SD3->D3_TM		:= "499"
			SD3->D3_ESTORNO:= "S"
			SD3->D3_EMISSAO:= dDataBase
		EndIf
		
		aCusto := GravaCusD3(aCm)
		B2AtuComD3(aCusto)
		
		SD3->(MsUnlock())
	Next nCntFor
EndIf
If _cD3 == 1 
	DbSelectArea("SDB")
	DbSetOrder(1)
	IF DbSeek( xFilial("SDB")+cCodPro+"01"+_cSeq+cDocumento)
		_cFilial1  := SDB->DB_FILIAL
		_cItem1    := SDB->DB_ITEM
		_cProd1    := SDB->DB_PRODUTO
		_cQuant1   := SDB->DB_QUANT
		_cData1    := SDB->DB_DATA
		_cLote1    := SDB->DB_LOTECTL
		_cNumLo1   := SDB->DB_NUMLOTE
		_cLocal1   := SDB->DB_LOCAL
		_cLocaliz1 := SDB->DB_LOCALIZ
		_cDoc1     := SDB->DB_DOC
		_cSerie1   := SDB->DB_SERIE
		_cCliFor1  := SDB->DB_CLIFOR
		_cLoja1    := SDB->DB_LOJA
		_cTipoNf1  := SDB->DB_TIPONF
		_cTM1      := SDB->DB_TM
		_cOrig1    := SDB->DB_ORIGEM
		_cNumSeq1  := SDB->DB_NUMSEQ
		_cTipo1    := SDB->DB_TIPO
		_cEmpe1    := SDB->DB_EMPENHO
		_cQtdSeg1  := SDB->DB_QTSEGUM
		_cEmp21    := SDB->DB_EMP2
		RecLock("SDB",.F.)
		SDB->DB_ESTORNO := "S"
		SDB->(MsUnlock())
	ENDIF
	DbSelectArea("SDB")
	DbSetOrder(1)
	IF DbSeek( xFilial("SDB")+cCodPro+"02"+_cSeq+cDocumento)
		_cFilial2  := SDB->DB_FILIAL
		_cItem2    := SDB->DB_ITEM
		_cProd2    := SDB->DB_PRODUTO
		_cQuant2   := SDB->DB_QUANT
		_cData2    := SDB->DB_DATA
		_cLote2    := SDB->DB_LOTECTL
		_cNumLo2   := SDB->DB_NUMLOTE
		_cLocal2   := SDB->DB_LOCAL
		_cLocaliz2 := SDB->DB_LOCALIZ
		_cDoc2     := SDB->DB_DOC
		_cSerie2   := SDB->DB_SERIE
		_cCliFor2  := SDB->DB_CLIFOR
		_cLoja2    := SDB->DB_LOJA
		_cTipoNf2  := SDB->DB_TIPONF
		_cTM2      := SDB->DB_TM
		_cOrig2    := SDB->DB_ORIGEM
		_cNumSeq2  := SDB->DB_NUMSEQ
		_cTipo2    := SDB->DB_TIPO
		_cEmpe2    := SDB->DB_EMPENHO
		_cQtdSeg2  := SDB->DB_QTSEGUM
		_cEmp22    := SDB->DB_EMP2
		RecLock("SDB",.F.)
		SDB->DB_ESTORNO := "S"
		SDB->(MsUnlock())
	ENDIF
	DbSelectArea("SDB")
	RecLock("SDB",.T.)
	SDB->DB_FILIAL   := _cFilial2
	SDB->DB_ITEM     := _cItem2
	SDB->DB_PRODUTO  := _cProd2
	SDB->DB_QUANT    := _cQuant2
	SDB->DB_DATA     := _cData2
	SDB->DB_LOTECTL  := _cLote2
	SDB->DB_NUMLOTE  := _cNumLo2
	SDB->DB_LOCAL    := _cLocal2
	SDB->DB_LOCALIZ  := _cLocaliz2
	SDB->DB_DOC      := _cDoc2
	SDB->DB_SERIE    := _cSerie2
	SDB->DB_CLIFOR   := _cCliFor2
	SDB->DB_LOJA     := _cLoja2
	SDB->DB_TIPONF   := _cTipoNf2
	SDB->DB_TM       := _cTM1
	SDB->DB_ORIGEM   := _cOrig2
	SDB->DB_NUMSEQ   := cNumSeq
	SDB->DB_TIPO     := _cTipo2
	SDB->DB_EMPENHO  := _cEmpe2
	SDB->DB_QTSEGUM  := _cQtdSeg2
	SDB->DB_EMP2     := _cEmp22
	SDB->(MsUnlock())
	DbSelectArea("SDB")
	RecLock("SDB",.T.)
	SDB->DB_FILIAL   := _cFilial1
	SDB->DB_ITEM     := _cItem1
	SDB->DB_PRODUTO  := _cProd1
	SDB->DB_QUANT    := _cQuant1
	SDB->DB_DATA     := _cData1
	SDB->DB_LOTECTL  := _cLote1
	SDB->DB_NUMLOTE  := _cNumLo1
	SDB->DB_LOCAL    := _cLocal1
	SDB->DB_LOCALIZ  := _cLocaliz1
	SDB->DB_DOC      := _cDoc1
	SDB->DB_SERIE    := _cSerie1
	SDB->DB_CLIFOR   := _cCliFor1
	SDB->DB_LOJA     := _cLoja1
	SDB->DB_TIPONF   := _cTipoNf1
	SDB->DB_TM       := _cTM2
	SDB->DB_ORIGEM   := _cOrig1
	SDB->DB_NUMSEQ   := cNumSeq
	SDB->DB_TIPO     := _cTipo1
	SDB->DB_EMPENHO  := _cEmpe1
	SDB->DB_QTSEGUM  := _cQtdSeg1
	SDB->DB_EMP2     := _cEmp21
	SDB->(MsUnlock())
	DbSelectArea("SBF")
	DbSetOrder(6)
	IF DbSeek( xFilial("SBF")+cCodPro+"01"+"      EXPEDICAO")
		RecLock("SBF",.F.)
		SBF->BF_QUANT := SBF->BF_QUANT - _cQuant1
		SBF->(MsUnlock())
	endif
	DbSelectArea("SBF")
	DbSetOrder(6)
	IF DbSeek( xFilial("SBF")+cCodPro+"02"+_cLocaliz2)
		RecLock("SBF",.F.)
		SBF->BF_QUANT := SBF->BF_QUANT + _cQuant1
		SBF->(MsUnlock())
	endif
Endif

//³Restaura a entrada da rotina                                            ³
RestArea(aAreaSB1)
RestArea(aAreaSB2)
RestArea(aAreaSD3)
RestArea(aAreaSDB)
RestArea(aArea)

Return(.T.)
#include "protheus.ch"
#include "ap5mail.ch"

Static _cPvRese
Static _aSvCols
Static _aSvExc
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDIPXRESE  บAutor  ณFabio Rogerio       บ Data ณ  09/04/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRotina para a inclusao/exclusao de reserva                  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function DIPXRESE(cOrigem,cPedido,cItem,cProduto,cLocal,cSeq,nQtdLib,cLoteCtl,cNumLote,cNumSeri,cLocaliz,cChaveSDB)
Local aArea       := GetArea()
Local aAreaSC6    := SC6->(GetArea())
Local aEnvEmail   := {}
Local aItems      := {}
Local nPsProd     := 0
Local nPsLocal    := 0
Local nPsQtdLib   := 0
Local nPsItem     := 0
Local nPsTes      := 0
Local nY          := 0
Local nPos        := 0
Local nLibEst     := 0
Local nLibNo      := 0
Local nLibAux     := nQtdLib
Local lBloqUsu    := .F.
Local nHdlTrava   := 0 
Local cEmaiHQ     := GetNewPar("ES_DIPXRHQ","vendas@healthquality.ind.br")     

//-- D'Leme - 23/08/2011 - Tipo de Reserva no PV:
//--    *  "1" com libera็ใo pelo sistema, seguida de estorno e nova libera็ใo customizada (mais lenta, no entanto estแvel - Modo utilizado at้ Ago/2011)
//--    *  "2" Sem libera็ใo pelo sistema, a libera็ใo customizada ้ feita sem necessidade de estorno (mais rแpida)
Local lNewResPV   := SuperGetMv("ES_TPRESPV",,"1") == "2"

Private lEnviouSDB:= .F.      

If "MATA310"$Upper(FunName()) .And. cOrigem<>"ISDB"
	Return
EndIf

U_DIPPROC(ProcName(0),U_DipUsr()) // MCVN - 22/01/2009

BEGIN TRANSACTION // Eriberto 21/03/2007

//Sleep(3000)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณVerifica se a origem eh Liberacao de Pedido ou Estorno de Liberacao.ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Do Case

	Case (cOrigem == "SV_EXC_NEW")

		If lNewResPV
			DIPXSvExc(cPedido,cItem,cProduto,cLocal,cSeq,nQtdLib,cLoteCtl,cNumLote,cNumSeri,cLocaliz,cChaveSDB)
		Else
			U_DIPXRESE("EXC",cPedido,cItem,cProduto,cLocal,cSeq,nQtdLib,cLoteCtl,cNumLote,cNumSeri,cLocaliz,cChaveSDB)
		EndIf
		

	Case (cOrigem == "EXC_NEW") //Exclusao

		If lNewResPV
			If _aSvExc != Nil
				For nY := 1 To Len(_aSvExc)
					If DIPXGetExc(nY,cPedido,@cItem,@cProduto,@cLocal,@cSeq,@nQtdLib,@cLoteCtl,@cNumLote,@cNumSeri,@cLocaliz,@cChaveSDB)
						U_DIPXRESE("EXC",cPedido,cItem,cProduto,cLocal,cSeq,nQtdLib,cLoteCtl,cNumLote,cNumSeri,cLocaliz,cChaveSDB)
					Else
						conout("ocorreu aqui um DisarmTransaction"+cPedido)
						DisarmTransaction()
						MsgAlert("Nใo foi possํvel estornar o empenho! Entre em contato com o TI! Erro: EXC_NEW","Aten็ใo")
						Break
					EndIf
				Next nY
			EndIf
			_aSvExc := Nil
		EndIf


	Case (cOrigem == "SV_NEW")

		If lNewResPV
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณSalva o aCols do PV na alteracao, para comparacao na liberacaoณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			DIPXSVCols(cPedido)
		EndIf


	Case (cOrigem == "ALT_NEW")

		If lNewResPV
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณManipula a Qtde Lib p/ o sistema padrao nao gerar SC9 no PV   ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			nPsQtdLib   := aScan(aHeader,{|x| AllTrim(x[2])=="C6_QTDLIB"})
			aEval( aCols, {|x| Iif(!aTail(x),x[nPsQtdLib] := 0,Nil) })
		EndIf

	Case (cOrigem == "REST_NEW")

		If lNewResPV
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณRestaura o aCols apos a alteracao                             ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			aCols := aClone(DIPXGetCols(cPedido))
		EndIf

		
	Case (cOrigem == "L")
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณAnalisa os produtos a serem reservados e liberados.           ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		If (FunName() == "TMKA271")
			cItem       := "00"
			nPsProd     := aScan(aHeader,{|x| AllTrim(x[2])=="UB_PRODUTO"})
			nPsLocal    := aScan(aHeader,{|x| AllTrim(x[2])=="UB_LOCAL"})
			nPsQtdLib   := aScan(aHeader,{|x| AllTrim(x[2])=="UB_QUANT"})
			nPsTes      := aScan(aHeader,{|x| AllTrim(x[2])=="UB_TES"})
		Else
			nPsProd     := aScan(aHeader,{|x| AllTrim(x[2])=="C6_PRODUTO"})
			nPsLocal    := aScan(aHeader,{|x| AllTrim(x[2])=="C6_LOCAL"})
			nPsQtdLib   := aScan(aHeader,{|x| AllTrim(x[2])=="C6_QTDLIB"})
			nPsItem     := aScan(aHeader,{|x| AllTrim(x[2])=="C6_ITEM"})
			nPsTes      := aScan(aHeader,{|x| AllTrim(x[2])=="C6_TES"})
		EndIf
		
		For nY := 1 to Len(aCols)
			If !aCols[nY,Len(aHeader)+1]
				
				SF4->(dbSetOrder(1))
				SF4->(dbSeek(xFilial("SF4")+aCols[nY,nPsTes]))
				
				cProduto:= aCols[nY,nPsProd]
				cLocal  := aCols[nY,nPsLocal]
				nQtdLib := aCols[nY,nPsQtdLib]
				If (FunName() == "TMKA271")
					cItem   := Soma1(cItem,2)
				Else
					cItem   := aCols[nY,nPsItem]
				EndIf
				
				If (SF4->F4_ESTOQUE == "S")
					
					If (nQtdLib > 0)
						
						//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
						//ณ Estorna item do SC9.                                ณ
						//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
						dbSelectArea("SC9")
						dbSetOrder(1)
						MsSeek(xFilial("SC9")+cPedido+cItem,.T.)
						While !Eof() .And. (xFilial("SC9")+cPedido+cItem == SC9->(C9_FILIAL+C9_PEDIDO+C9_ITEM))
							If Empty(SC9->C9_NFISCAL)
								If (SC9->C9_DATALIB == dDatabase)
									SC9->(a460Estorna(.T.))
								EndIf
							EndIf
							
							dbSelectArea("SC9")
							dbSkip()
						End
						
						dbSelectArea("SB2")
						dbSetOrder(1)
						If dbSeek(xFilial("SB2")+cProduto+cLocal)
							If (nQtdLib <= SaldoSB2())
								nLibEst:= nQtdLib
								nLibNo := 0
							Else
								nLibEst:= SaldoSB2()
								nLibNo := nQtdLib - nLibEst
							EndIf
							
							//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
							//ณ Inclui a reserva do produto.                        ณ
							//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
							DIPXLIB(cOrigem,cPedido,cItem,cProduto,cLocal,nLibEst,nLibNo,"")
						EndIf	
					EndIf
				Else
					
					//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
					//ณSe o pedido so gera financeiro apena atualiza os dados do SC9.ณ
					//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
					dbSelectArea("SC9")
					dbSetOrder(1)
					If !MsSeek(xFilial("SC9")+cPedido+cItem+"01"+cProduto,.T.)
						SC6->(dbSetOrder(1))
						SC6->(dbSeek(xFilial("SC6")+cPedido+cItem+cProduto))
						If SC6->(!Eof())
							//MaLibDoFat(SC6->(RecNo()),nQtdLib,.F.,.F.,.T.,.F.,.T.,.T.,,,,,,,)
							DbCommitAll()
							MaLibDoFat(SC6->(RecNo()),nQtdLib,.F.,.F.,.T.,.F.,.T.,.T.,,;
							{|| SC9->C9_OPERADO := Iif("TMK"$FunName(),SUA->UA_OPERADO,SC5->C5_OPERADO),;
							SC9->C9_PARCIAL := "N",;
							SC9->C9_VEND    := Iif("TMK"$FunName(),SUA->UA_VEND,SC5->C5_VEND1),;
							SC9->C9_FORNEC  := Posicione("SB1",1,xFilial("SB1")+SC9->C9_PRODUTO,"B1_PROC"),;
							SC9->C9_PRIRESE := Posicione("SU7",1,xFilial("SU7")+SC9->C9_OPERADO,"U7_PRIRESE"),;
							SC9->C9_PRIENTR := u_PriSepTran(SC5->C5_TRANSP);
							},,,,,)

							RecLock("SC6",.F.)
							SC6->C6_QTDLIB := SC6->C6_QTDVEN
							SC6->(MsUnLock())
							SC6->(DbCommit())
						EndIf
					Else
						// Utilizado quando o pedido ้ gerado pelo faturamento  MCVN - 06/12/2007					
						While !Eof() .And. (xFilial("SC9")+cPedido+cItem+"01"+cProduto) == SC9->(C9_FILIAL+C9_PEDIDO+C9_ITEM+C9_LOCAL+C9_PRODUTO)
						If Empty(SC9->C9_NFISCAL)
							If (SC9->C9_DATALIB == dDatabase)
								RecLock("SC9",.F.)			
								Replace C9_OPERADO With  Iif("TMK"$FunName(),SUA->UA_OPERADO,SC5->C5_OPERADO)
								Replace C9_PARCIAL With  "N"    
								Replace C9_BLEST   With  "02"    							
								Replace C9_VEND    With  Iif("TMK"$FunName(),SUA->UA_VEND,SC5->C5_VEND1)
								Replace C9_FORNEC  With  Posicione("SB1",1,xFilial("SB1")+SC9->C9_PRODUTO,"B1_PROC")
								Replace C9_PRIRESE With  Posicione("SU7",1,xFilial("SU7")+SC9->C9_OPERADO,"U7_PRIRESE")
								Replace C9_PRIENTR With  u_PriSepTran(SC5->C5_TRANSP)
								SC9->(MsUnLock())
								SC9->(DbCommit())
							EndIf
						EndIf					
						dbSelectArea("SC9")
						dbSkip()
						End
					EndIf
				EndIf
			EndIf
		Next
		DIPXLIBOK(cPedido,cOrigem)
		
	Case (cOrigem == "EXC") //Exclusao
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ Exclui a reserva do produto.                        ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		SC5->(dbSetOrder(1))
		SC5->(dbSeek(xFilial("SC5")+cPedido))
		
		SC6->(dbSetOrder(1))
		SC6->(dbSeek(xFilial("SC5")+cPedido+cItem+cProduto))
		
		SF4->(dbSetOrder(1))
		SF4->(dbSeek(xFilial("SF4")+SC6->C6_TES))
		
		If (SF4->F4_ESTOQUE == "S")
			DIPXLIB(cOrigem,cPedido,cItem,cProduto,cLocal,nQtdLib,0,"")
		EndIf


	Case (cOrigem == "ISDB") //Inclusao Enderecamento
		
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณSeleciono os items que precisam ser liberados.ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		cQuery:= " SELECT * "     
		cQuery+= " FROM " + RetSqlName("SC9") + " SC9 "
		cQuery+= " WHERE SC9.D_E_L_E_T_ = ' ' "
		cQuery+= " AND SC9.C9_NFISCAL = ' ' "
		cQuery+= " AND SC9.C9_BLEST   = '02' "
		cQuery+= " AND SC9.C9_SALDO   > 0 "
		cQuery+= " AND Left(ltrim(SC9.C9_ITEMSDB),2) <> 'OK'  " // MCVN 27/02/07
		cQuery+= " AND SC9.C9_PRODUTO = '" + cProduto + "'"
		cQuery+= " AND SC9.C9_LOCAL = '" + cLocal + "'"
		If cEmpAnt<>'01'
			cQuery+= " AND SC9.C9_FILIAL IN('01','02') " // Daniel Leme 03/06/2011
		Endif
		
		cQuery+= " ORDER BY SC9.C9_PRIRESE,SC9.C9_PEDIDO"
		
		cQuery := ChangeQuery(cQuery)
		
		DbCommitAll()
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"QRY",.T.,.T.)
		dbSelectArea("QRY")
		While !Eof()
			
			If (nLibAux > 0)
				//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
				//ณApenas manda o email devido a problemas na utilizacaoณ
				//ณdo C5_PRENOTA em liberacoes/reservas parciais.       ณ
				//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
				/*
				//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
				//ณ Estorna item do SC9.                                ณ
				//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
				dbSelectArea("SC9")
				dbSetOrder(1)
				dbGoTo(QRY->R_E_C_N_O_)
				SC9->(a460Estorna(.T.))
				
				nLibEst:= IIf(QRY->C9_SALDO <= nLibAux,QRY->C9_SALDO,nLibAux)
				nLibNo := IIf(QRY->C9_SALDO <= nLibAux,0,QRY->C9_SALDO-nLibAux)
				nLibAux-= nLibEst
				
				//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
				//ณ Inclui a reserva do produto.                        ณ
				//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
				DIPXLIB(cOrigem,QRY->C9_PEDIDO,QRY->C9_ITEM,cProduto,cLocal,nLibEst,nLibNo,cChaveSDB)
				*/
				
				nLibEst:= IIf(QRY->C9_SALDO-(If(!Empty(QRY->C9_ITEMSDB) .And. !("OK" $ QRY->C9_ITEMSDB),Val(QRY->C9_ITEMSDB),0)) <= nLibAux,QRY->C9_SALDO-(If(!Empty(QRY->C9_ITEMSDB) .And. !("OK" $ QRY->C9_ITEMSDB),Val(QRY->C9_ITEMSDB),0)),nLibAux)
				nLibNo := IIf(QRY->C9_SALDO-(If(!Empty(QRY->C9_ITEMSDB) .And. !("OK" $ QRY->C9_ITEMSDB),Val(QRY->C9_ITEMSDB),0)) <= nLibAux,0,(QRY->C9_SALDO-(If(!Empty(QRY->C9_ITEMSDB) .And. !("OK" $ QRY->C9_ITEMSDB),Val(QRY->C9_ITEMSDB),0)))-nLibAux)
				nLibAux-= nLibEst
				
				SA1->(dbSetOrder(1))
				SA1->(dbSeek(xFilial("SA1",QRY->C9_FILIAL)+QRY->(C9_CLIENTE+C9_LOJA)))
				
				SB1->(dbSetOrder(1))
				SB1->(dbSeek(xFilial("SB1",QRY->C9_FILIAL)+QRY->C9_PRODUTO))
				
				SA3->(dbSetOrder(1))
				SA3->(dbSeek(xFilial("SA3",QRY->C9_FILIAL)+QRY->C9_VEND))
				
				SU7->(dbSetOrder(1))
				SU7->(dbSeek(xFilial("SU7",QRY->C9_FILIAL)+QRY->C9_OPERADO))    
				
				SC9->(dbSetOrder(1))
				If SC9->(dbSeek(xFilial("SC9",QRY->C9_FILIAL)+QRY->C9_PEDIDO+QRY->C9_ITEM+QRY->C9_SEQUEN+QRY->C9_PRODUTO))
				
					aEnvEMail:= {{QRY->C9_CLIENTE, QRY->C9_LOJA, SA1->A1_NOME, SA1->A1_END, SA1->A1_BAIRRO, SA1->A1_CEP, SA1->A1_MUN, SA1->A1_EST, SA1->A1_CGC, SA1->A1_INSCR, SA1->A1_TEL, QRY->C9_PEDIDO, QRY->C9_PRODUTO, SB1->B1_DESC, nLibEst, QRY->C9_VEND, SA3->A3_NOME}}
					
					If !("OK" $ QRY->C9_ITEMSDB) // MCVN 14/04/08
					   
						If cEmpAnt == "04" .And. Substr(QRY->C9_PRODUTO,1,1) == "2"
							//If "MATA310"$Upper(FunName()) .And. cFilAnt == "01" - RBorges - 06/09/2019 - As entradas voltaram a ser no local 01 da Matriz
								EnvEmail(SU7->U7_EMAIL+";"+cEmaiHQ,"Chegou produto "+Alltrim(QRY->C9_PRODUTO)+" do Pedido "+QRY->C9_PEDIDO,aEnvEmail,,QRY->C9_OPERADO,,QRY->C9_FILIAL)
							//EndIf
						Else	
				        	EnvEmail(SU7->U7_EMAIL,"Chegou produto "+Alltrim(QRY->C9_PRODUTO)+" do Pedido "+QRY->C9_PEDIDO,aEnvEmail,,QRY->C9_OPERADO,,QRY->C9_FILIAL)
				        EndIf
				        
				        // Gravando C9_ITEMSDB para enviar e-mail somente uma Vez	MCVN 14/04/08					
				        If lEnviouSDB
							RecLock("SC9",.F.)					
							Replace C9_ITEMSDB With If(nLibNo = 0,"OK - "+DtoC(ddatabase)+" - "+TIME(),Str(nLibEst+VAL(QRY->C9_ITEMSDB)))
							SC9->(MsUnLock())
							SC9->(DbCommit()) 										
						Endif
					Endif
				Endif
				
				//				U_DiprKardex(QRY->C9_PEDIDO,U_DipUsr(),"Reserva "+QRY->C9_PRODUTO,.T.,"34")
			EndIf
			
			dbSelectArea("QRY")
			dbSkip()
		End
		QRY->(dbCloseArea())
		


	Case (cOrigem == "ESDB") //Estormo Enderecamento
		/* Devido a problemas na utilizacao do C5_PRENOTA para liberacoes/reservas parciais nao sera usado a reserva/estorno automatico
		
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณSeleciono os items que precisam ser liberados.ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		cQuery:= " SELECT R_E_C_N_O_ AS C9RECNO, * "
		cQuery+= " FROM " + RetSqlName("SC9") + " SC9 "
		cQuery+= " WHERE SC9.D_E_L_E_T_ <> '*' AND SC9.C9_NFISCAL = '' AND SC9.C9_PRODUTO = '" + cProduto + "' "
		cQuery+= " AND SC9.C9_ITEMSDB = '" + cChaveSDB + "' "
		cQuery+= " AND SC9.C9_FILIAL  = '" + xFilial("SC9") + "' "
		
		cQuery := ChangeQuery(cQuery)
		
		DbCommitAll()
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"QRY",.T.,.T.)
		dbSelectArea("QRY")
		While !Eof()
		
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ Estorna item do SC9.                                ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		dbSelectArea("SC9")
		dbGoTo(QRY->C9RECNO)
		If Empty(SC9->C9_NFISCAL)
		//				SC9->(a460Estorna(.T.))
		
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ Exclui a reserva do produto.                        ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		If (SC9->C9_SALDO == 0)
		RecLock("SC9",.F.)
		Replace C9_SALDO With QRY->C9_QTDLIB
		Replace C9_QTDORI With 0          // MCVN 28/02/07
		Replace C9_ITEMSDB With ''        // MCVN 28/02/07
		SC9->(MsUnLock())
		SC9->(DbCommit())
		DIPXLIB(cOrigem,QRY->C9_PEDIDO,QRY->C9_ITEM,QRY->C9_PRODUTO,QRY->C9_LOCAL,QRY->C9_QTDLIB,0,cChaveSDB)
		EndIf
		
		SA1->(dbSetOrder(1))
		SA1->(dbSeek(xFilial("SA1")+QRY->(C9_CLIENTE+C9_LOJA)))
		
		SB1->(dbSetOrder(1))
		SB1->(dbSeek(xFilial("SB1")+QRY->C9_PRODUTO))
		
		SA3->(dbSetOrder(1))
		SA3->(dbSeek(xFilial("SA3")+QRY->C9_VEND))
		
		SU7->(dbSetOrder(1))
		SU7->(dbSeek(xFilial("SU7")+QRY->C9_OPERADO))
		
		aEnvEMail:= {{QRY->C9_CLIENTE, QRY->C9_LOJA, SA1->A1_NOME, SA1->A1_END, SA1->A1_BAIRRO, SA1->A1_CEP, SA1->A1_MUN, SA1->A1_EST, SA1->A1_CGC, SA1->A1_INSCR, SA1->A1_TEL, QRY->C9_PEDIDO, QRY->C9_PRODUTO, SB1->B1_DESC, SC9->C9_QTDLIB,QRY->C9_VEND, SA3->A3_NOME}}
		
		EnvEmail(SU7->U7_EMAIL,"Estorno de Reserva de Produtos do Pedido "+QRY->C9_PEDIDO,aEnvEmail)
		
		U_DiprKardex(QRY->C9_PEDIDO,U_DipUsr(),"Estorno Reserva "+QRY->C9_PRODUTO,.T.,"35")
		EndIf
		
		dbSelectArea("QRY")
		dbSkip()
		End
		QRY->(dbCloseArea())
		*/
		
	Case (cOrigem == "ATU")
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณAnalisa os produtos a serem reservados e liberados.           ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		
		dbSelectArea("SC6")
		dbSetOrder(1)
		dbSeek(xFilial("SC6")+cPedido)
		While !Eof() .And. (xFilial("SC6")+cPedido == SC6->(C6_FILIAL+C6_NUM))
			aAreaSC6:= SC6->(GetArea())
			
			If SC6->(C6_QTDVEN > C6_QTDENT)
				
				SF4->(dbSetOrder(1))
				SF4->(dbSeek(xFilial("SF4")+SC6->C6_TES))
				
				If (SF4->F4_ESTOQUE == "S")
					
					cProduto:= SC6->C6_PRODUTO
					cLocal  := SC6->C6_LOCAL
					nQtdLib := SC6->C6_QTDVEN - SC6->C6_QTDENT
					cItem   := SC6->C6_ITEM
					
					If (nQtdLib > 0)
						
						dbSelectArea("SB2")
						dbSetOrder(1)
						If dbSeek(xFilial("SB2")+cProduto+cLocal)
							
							If (nQtdLib <= SaldoSB2())
								nLibEst:= nQtdLib
								nLibNo := 0
							Else
								nLibEst:= SaldoSB2()
								nLibNo := nQtdLib - nLibEst
							EndIf
							
							//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
							//ณ Inclui a reserva do produto.                        ณ
							//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
							DIPXLIB(cOrigem,cPedido,cItem,cProduto,cLocal,nLibEst,nLibNo,"")
						EndIf						
					EndIF
				EndIf
			EndIf
			
			RestArea(aAreaSC6)
			
			dbSelectArea("SC6")
			dbSkip()
		End
		
	Case (cOrigem == "EST")
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณAnalisa os produtos a serem reservados e liberados.           ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		
		dbSelectArea("SC6")
		dbSetOrder(1)
		dbSeek(xFilial("SC6")+cPedido)
		While !Eof() .And. (xFilial("SC6")+cPedido == SC6->(C6_FILIAL+C6_NUM))
			aAreaSC6:= SC6->(GetArea())
			
			If SC6->(C6_QTDVEN > C6_QTDENT)
				
				SF4->(dbSetOrder(1))
				SF4->(dbSeek(xFilial("SF4")+SC6->C6_TES))
				
				If (SF4->F4_ESTOQUE == "S")
					
					cProduto:= SC6->C6_PRODUTO
					cLocal  := SC6->C6_LOCAL
					nQtdLib := SC6->C6_QTDVEN - SC6->C6_QTDENT
					cItem   := SC6->C6_ITEM
					
					If (nQtdLib > 0)
						
						//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
						//ณ Estorna item do SC9.                                ณ
						//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
						dbSelectArea("SC9")
						dbSetOrder(1)
						MsSeek(xFilial("SC9")+cPedido+cItem,.T.)
						While !Eof() .And. (xFilial("SC9")+cPedido+cItem == SC9->(C9_FILIAL+C9_PEDIDO+C9_ITEM))
							If Empty(SC9->C9_NFISCAL)
								SC9->(a460Estorna(.T.))
							EndIf
							
							dbSelectArea("SC9")
							dbSkip()
						End
					EndIF
				EndIf
			EndIf
			
			RestArea(aAreaSC6)
			
			dbSelectArea("SC6")
			dbSkip()
		End
		
EndCase


END TRANSACTION // Eriberto 21/03/2007

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDIPXLIBOK บAutor  ณFabio Rogerio       บ Data ณ  09/25/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRotina para verificar se o pedido esta todo liberado        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function DIPXLIBOK(cPedido,cOrigem)
Local nTotLib := 0
Local nTotVen := 0
Local lRet    := .T.
Local lCredito:= .T.

dbSelectArea("SC6")
dbSetOrder(1)
dbSeek(xFilial("SC6")+cPedido,.T.)
While !Eof() .And. (xFilial("SC6")+cPedido == SC6->(C6_FILIAL+C6_NUM))
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณPesquisa todas as liberacoes de cada produto. ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	nTotVen:= SC6->C6_QTDVEN
	nTotLib:= 0
	dbSelectArea("SC9")
	dbSetOrder(1)
	dbSeek(xFilial("SC9")+SC6->(C6_NUM+C6_ITEM),.T.)
	While !Eof() .And. (xFilial("SC9")+SC6->(C6_NUM+C6_ITEM) == SC9->(C9_FILIAL+C9_PEDIDO+C9_ITEM))
		nTotLib+= SC9->C9_QTDLIB
		
		lCredito:= IIF(SC9->C9_BLCRED $ "01/04/09",.F.,lCredito)
		dbSelectArea("SC9")
		dbSkip()
	End
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณVerifica se a quantidade vendida eh diferente da quantidade liberada.ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If (nTotVen <> nTotLib)    //Acho que o problema estแ aqui  - 19/04/07 as 18:50
		GrvLog("ERRO LIBOK;"+cPedido+";"+SC6->C6_PRODUTO+";"+AllTrim(Str(nTotLib))+";"+AllTrim(Str(nTotVen)))
		lRet:= .F.
		Exit
	EndIf
	
	dbSelectArea("SC6")
	dbSkip()
End

dbSelectArea("SC5")
dbSetOrder(1)
If dbSeek(xFilial("SC5")+cPedido)
	RecLock("SC5",.F.)
	Replace C5_LIBEROK With IIf(lRet,"S",SC5->C5_LIBEROK)
	
	If (cOrigem == "ISDB") 	// MCVN 07/03/07
		Replace C5_PRENOTA With "O"
		Replace C5_PARCIAL With "N"
	Else
		Replace C5_PRENOTA With IIf(lCredito,SC5->C5_PRENOTA,"F")
	Endif
	SC5->(MsUnLock())
	SC5->(DbCommit())
	
	
	/* MCVN - 20/08/2007-Rotina desnecessแria pois o C9_PARCIAL ษ CRIADO COM O CONTEฺDO "N" E Sำ ษ TRATADO NA DEFINIวรO SE BLOQUEIA OU NรO O PEDIDO.
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณAtualiza o C9_PARCIAL por causa do filtro na Lib. de Credito.ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	dbSelectArea("SC9")
	dbSetOrder(1)
	dbSeek(xFilial("SC9")+SC5->C5_NUM,.T.)
	While !Eof() .And. (xFilial("SC9")+SC5->C5_NUM == SC9->(C9_FILIAL+C9_PEDIDO))
	If Empty(SC9->C9_NFISCAL)
	RecLock("SC9",.F.)
	Replace C9_PARCIAL With SC5->C5_PARCIAL
	SC9->(MsUnLock())
	SC9->(DbCommit())
	EndIf
	
	dbSelectArea("SC9")
	dbSkip()
	End
	*/
	
EndIf



Return(lRet)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDIPXLIB   บAutor  ณFabio Rogerio       บ Data ณ  10/04/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRotina para a liberacao dos itens do pedido e se necessario บฑฑ
ฑฑบ          ณreserva.                                                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/Static Function DIPXLIB(cOrigem,cPedido,cItem,cProduto,cLocal,nLibEst,nLibNo,cChaveSDB)
Local aAreaB2:= {}
Local lTrava := .F.

If (cOrigem == "L_NEW")
ElseIf (cOrigem $ "L/ATU/ISDB")
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤLฟ
	//ณExecuta a liberacao analisando o credito e bloqueando o estoque.ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤLู
	If (nLibEst > 0)
		SC6->(dbSetOrder(1))
		SC6->(dbSeek(xFilial("SC6")+cPedido+cItem+cProduto))
		If SC6->(!Eof())
			//MaLibDoFat(SC6->(RecNo()),nLibEst,.F.,.F.,.T.,.F.,.T.,.T.,,,,,,,)
			DbCommitAll()

			MaLibDoFat(SC6->(RecNo()),nLibEst,.F.,.F.,.T.,.F.,.T.,.T.,,;
			{|| SC9->C9_OPERADO := Iif("TMK"$FunName(),SUA->UA_OPERADO,SC5->C5_OPERADO),;
			SC9->C9_PARCIAL := "N",;
			SC9->C9_VEND    := Iif("TMK"$FunName(),SUA->UA_VEND,SC5->C5_VEND1),;
			SC9->C9_ITEMSDB := IIf(SC9->C9_QTDLIB == nLibEst,cChaveSDB,SC9->C9_ITEMSDB),;
			SC9->C9_FORNEC  := Posicione("SB1",1,xFilial("SB1")+SC9->C9_PRODUTO,"B1_PROC"),;
			SC9->C9_PRIRESE := Posicione("SU7",1,xFilial("SU7")+SC9->C9_OPERADO,"U7_PRIRESE"),;
			SC9->C9_PRIENTR := u_PriSepTran(SC5->C5_TRANSP),;
			SC9->C9_SALDO   := 0,;
			SC9->C9_QTDORI  := SC9->C9_QTDLIB - SC9->C9_SALDO,;
			SC9->C9_QTDVEN  := SC9->C9_QTDLIB;
			},,,,,)
	
			RecLock("SC6",.F.)
			SC6->C6_QTDLIB := nLibEst
			SC6->(MsUnLock())
			SC6->(DbCommit())
		EndIf
		
		dbSelectArea("SB2")
		dbSetOrder(1)
		If dbSeek(xFilial("SB2")+cProduto+cLocal)
			GrvLog('SC9;'+cOrigem+";"+sb2->b2_cod+";"+cPedido+";"+cItem+";"+Str(SB2->B2_QATU)+";"+Str(SB2->B2_QPEDVEN)+";"+Str(SB2->B2_RESERVA)+";"+Str(nLibEst)+";"+Str(nLibNo)+";"+Str(SC9->C9_QTDLIB))
			lTrava := SB2->(MsRLock())
           
            If lTrava

				aAreaB2:= SB2->(GetArea())
				GrvLog('ANTES;'+cOrigem+";"+sb2->b2_cod+";"+cPedido+";"+cItem+";"+Str(SB2->B2_QATU)+";"+Str(SB2->B2_QPEDVEN)+";"+Str(SB2->B2_RESERVA)+";"+Str(nLibEst)+";"+Str(nLibNo)+";"+Str(SC9->C9_QTDLIB))
				
				//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
				//ณGrava o empenho.ณ
				//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
				DbCommitAll()
				
				GravaEmp(	cProduto,; 				//-- 01.Cขdigo do Produto
							cLocal,;   				//-- 02.Local
							nLibEst,;				//-- 03.Quantidade
							Nil,;					//-- 04.Quantidade 2UM
							Nil,;			  		//-- 05.Lote
							Nil,;  					//-- 06.SubLote
							Nil,;  					//-- 07.Localizaฦo
							Nil,; 					//-- 08.Numero de Srie
							Nil,;         			//-- 09.OP
							Nil,; 	         		//-- 10.Seq. do Empenho/Liberaฦo do PV (Pedido de Venda)
							cPedido,;				//-- 11.PV
							cItem,;  				//-- 12.Item do PV
							'SC6',;       			//-- 13.Origem do Empenho
							Nil,;         			//-- 14.OP Original
							Nil,;         			//-- 15.Data da Entrega do Empenho
							Nil,;	    			//-- 16.Array para Travamento de arquivos
							.F.,;     				//-- 17.Estorna Empenho?
							Nil,;         			//-- 18.chamada da Projeฦo de Estoques?
							.T.,;         			//-- 19.Empenha no SB2?
							.F.,;         			//-- 20.Grava SD4?
							.F.,;         			//-- 21.Considera Lotes Vencidos?
							.F.,;         			//-- 22.Empenha no SB8/SBF?
							.F.)        			//-- 23.Cria SDC?
				

				RestArea(aAreaB2)			
				GrvLog('DEPOIS;'+cOrigem+";"+sb2->b2_cod+";"+cPedido+";"+cItem+";"+Str(SB2->B2_QATU)+";"+Str(SB2->B2_QPEDVEN)+";"+Str(SB2->B2_RESERVA)+";"+Str(nLibEst)+";"+Str(nLibNo)+";"+Str(SC9->C9_QTDLIB))
				dbSelectArea("SB2")
				RecLock("SB2",.F.)
				Replace B2_QPEDVEN With B2_QPEDVEN - nLibEst
				Replace B2_QPEDVE2 With B2_QPEDVE2 - ConvUm(cProduto,nLibEst,0,2)
				SB2->(MsUnLock())
				SB2->(DbCommit())
			Else                    	 	
			    // Grava campo de controle de erro no SC6
				RecLock("SC6",.F.)    
				SC6->C6_ERROSB2 := "SB2"
				SC6->(MsUnLock()) 
				SC6->(DbCommit())
			EndIf
		EndIf
	Else
		GrvLog("Falhou Seek SB2;"+xFilial("SB2")+cProduto+cLocal)
	EndIf
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณLibera a quantidade que falta mas bloqueando o estoque.ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If (nLibNo > 0)
		SC6->(dbSetOrder(1))
		SC6->(dbSeek(xFilial("SC6")+cPedido+cItem+cProduto))
		If SC6->(!Eof())
			/*
			ฑฑณParametrosณExpN1: Registro do SC6                                      ณฑฑ
			ฑฑณ          ณExpN2: Quantidade a Liberar                                 ณฑฑ
			ฑฑณ          ณExpL3: Bloqueio de Credito                                  ณฑฑ
			ฑฑณ          ณExpL4: Bloqueio de Estoque                                  ณฑฑ
			ฑฑณ          ณExpL5: Avaliacao de Credito                                 ณฑฑ
			ฑฑณ          ณExpL6: Avaliacao de Estoque                                 ณฑฑ
			ฑฑณ          ณExpL7: Permite Liberacao Parcial                            ณฑฑ
			ฑฑณ          ณExpL8: Tranfere Locais automaticamente                      ณฑฑ
			ฑฑณ          ณExpA9: Empenhos ( Caso seja informado nao efetua a gravacao ณฑฑ
			ฑฑณ          ณ       apenas avalia ).                                     ณฑฑ
			ฑฑณ          ณExpbA: CodBlock a ser avaliado na gravacao do SC9           ณฑฑ
			ฑฑณ          ณExpAB: Array com Empenhos previamente escolhidos            ณฑฑ
			ฑฑณ          ณ       (impede selecao dos empenhos pelas rotinas)          ณฑฑ
			ฑฑณ          ณExpLC: Indica se apenas esta trocando lotes do SC9          ณฑฑ
			ฑฑณ          ณExpND: Valor a ser adicionado ao limite de credito          ณฑฑ
			ฑฑณ          ณExpNE: Quantidade a Liberar - segunda UM                    ณฑฑ
			*/
			DbCommitAll()
			MaLibDoFat(SC6->(RecNo()),nLibNo,.F.,.F.,.T.,.F.,.T.,.T.,,;
			{|| SC9->C9_OPERADO := Iif("TMK"$FunName(),SUA->UA_OPERADO,SC5->C5_OPERADO),;
			SC9->C9_PARCIAL := "N",;
			SC9->C9_VEND    := Iif("TMK"$FunName(),SUA->UA_VEND,SC5->C5_VEND1),;
			SC9->C9_ITEMSDB := IIf(SC9->C9_QTDLIB == nLibEst,cChaveSDB,SC9->C9_ITEMSDB),;
			SC9->C9_FORNEC  := Posicione("SB1",1,xFilial("SB1")+SC9->C9_PRODUTO,"B1_PROC"),;
			SC9->C9_PRIRESE := Posicione("SU7",1,xFilial("SU7")+SC9->C9_OPERADO,"U7_PRIRESE"),;
			SC9->C9_PRIENTR := u_PriSepTran(SC5->C5_TRANSP),;
			SC9->C9_SALDO   := nLibNo,;
			SC9->C9_QTDORI  := SC9->C9_QTDLIB - SC9->C9_SALDO,;
			SC9->C9_QTDVEN  := SC9->C9_QTDLIB;
			},,,,,)

			RecLock("SC6",.F.)
			SC6->C6_QTDLIB := SC6->C6_QTDVEN
			SC6->(MsUnLock())
			SC6->(DbCommit())
		EndIf
	EndIf
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณGrava as prioridades do pedido nas liberacoes.ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	/*	dbSelectArea("SC9")
	dbSetOrder(1)
	If MsSeek(xFilial("SC9")+cPedido+cItem,.T.)
	While !Eof() .And. (xFilial("SC9")+cPedido+cItem == SC9->(C9_FILIAL+C9_PEDIDO+C9_ITEM))
	If Empty(SC9->C9_NFISCAL) .And. (SC9->C9_DATALIB == dDatabase)
	
	// MCVN 05/03/07
	If (cOrigem $ "ISDB" .And. C9_SALDO = 0 .And. C9_QTDORI > 0 ) 	// MCVN 05/03/07
	dbSkip() 			 									 	// MCVN 05/03/07
	Endif 	     			  										// MCVN 05/03/07
	
	RecLock("SC9",.F.)
	Replace C9_OPERADO With Iif("TMK"$FunName(),SUA->UA_OPERADO,SC5->C5_OPERADO)
	Replace C9_VEND    With Iif("TMK"$FunName(),SUA->UA_VEND,SC5->C5_VEND1)
	Replace C9_ITEMSDB With IIf(SC9->C9_QTDLIB == nLibEst,cChaveSDB,SC9->C9_ITEMSDB)
	Replace C9_FORNEC  With Posicione("SB1",1,xFilial("SB1")+SC9->C9_PRODUTO,"B1_PROC")
	Replace C9_PRIRESE With Posicione("SU7",1,xFilial("SU7")+SC9->C9_OPERADO,"U7_PRIRESE")
	Replace C9_PRIENTR With Posicione("SA4",1,xFilial("SA4")+SC5->C5_TRANSP,"A4_PRIENTR")
	//				Replace C9_SALDO   With IIf(SC9->C9_QTDLIB == nLibEst .AND. SC9->C9_SEQUEN == '01',0,nLibNo)
	Replace C9_QTDORI  With SC9->C9_QTDLIB - SC9->C9_SALDO
	Replace C9_QTDVEN  With SC9->C9_QTDLIB
	SC9->(MsUnLock())
	SC9->(DbCommit())
	EndIf
	
	dbSelectArea("SC9")
	SC9->(dbSkip())
	End
	EndIf
	*/
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณVerifica se todos os itens foram liberados.ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If cOrigem != "L"
		DIPXLIBOK(cPedido,cOrigem)
	EndIf	
	
ElseIf (cOrigem $ "EST/EXC/ESDB")
	
	dbSelectArea("SB2")
	dbSetOrder(1)
	If dbSeek(xFilial("SB2")+cProduto+cLocal)
		GrvLog('SC9;'+cOrigem+";"+sb2->b2_cod+";"+cPedido+";"+cItem+";"+Str(SB2->B2_QATU)+";"+Str(SB2->B2_QPEDVEN)+";"+Str(SB2->B2_RESERVA)+";"+Str(nLibEst)+";"+Str(nLibNo)+";"+Str(SC9->C9_QTDLIB))
		lTrava := SB2->(MsRLock())
        If lTrava

			aAreaB2:= SB2->(GetArea())
			GrvLog('ANTES;'+cOrigem+";"+sb2->b2_cod+";"+cPedido+";"+cItem+";"+Str(SB2->B2_QATU)+";"+Str(SB2->B2_QPEDVEN)+";"+Str(SB2->B2_RESERVA)+";"+Str(nLibEst)+";"+Str(nLibNo)+";"+Str(SC9->C9_QTDLIB))
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณ Exclui o empenho do produto.                        ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			DbCommitAll()
			GravaEmp(	cProduto,; 	//-- 01.Cขdigo do Produto
						cLocal,;	//-- 02.Local
						nLibEst,;	//-- 03.Quantidade
						Nil,;		//-- 04.Quantidade 2UM
						"",;	  	//-- 05.Lote
						"",;	  	//-- 06.SubLote
						"",;	  	//-- 07.Localizaฦo
						"",; 	  	//-- 08.Numero de Srie
						Nil,;       //-- 09.OP
						"",;		//-- 10.Seq. do Empenho/Liberaฦo do PV (Pedido de Venda)
						cPedido,;   //-- 11.PV
						cItem,;		//-- 12.Item do PV
						'SC6',;     //-- 13.Origem do Empenho
						Nil,;       //-- 14.OP Original
						Nil,;       //-- 15.Data da Entrega do Empenho
						Nil,;	    //-- 16.Array para Travamento de arquivos
						.T.,;     	//-- 17.Estorna Empenho?
						Nil,;       //-- 18.chamada da Projeฦo de Estoques?
						.T.,;       //-- 19.Empenha no SB2?
						.F.,;       //-- 20.Grava SD4?
						.F.,;       //-- 21.Considera Lotes Vencidos?
						.F.,;       //-- 22.Empenha no SB8/SBF?
						.F.)        //-- 23.Cria SDC?
						
			RestArea(aAreaB2)
			GrvLog('DEPOIS;'+cOrigem+";"+sb2->b2_cod+";"+cPedido+";"+cItem+";"+Str(SB2->B2_QATU)+";"+Str(SB2->B2_QPEDVEN)+";"+Str(SB2->B2_RESERVA)+";"+Str(nLibEst)+";"+Str(nLibNo)+";"+Str(SC9->C9_QTDLIB))
			dbSelectArea("SB2")
			RecLock("SB2",.F.)
			Replace B2_QPEDVEN With B2_QPEDVEN + nLibEst
			Replace B2_QPEDVE2 With B2_QPEDVE2 + ConvUm(cProduto,nLibEst,0,2)
			SB2->(MsUnLock()) 
			SB2->(DbCommit())

			RecLock("SC6",.F.)    
			SC6->C6_ERROSB2 := ""
			SC6->(MsUnLock()) 	
			SC6->(DbCommit())

		Else
		    // Grava campo de controle de erro no SC6
			RecLock("SC6",.F.)    
			SC6->C6_ERROSB2 := "SB2"
			SC6->(MsUnLock())
			SC6->(DbCommit()) 
		EndIf 
	Else
		GrvLog("Falhou Seek SB2;"+xFilial("SB2")+cProduto+cLocal)
	EndIf	
EndIf
Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDIPATURES บAutor  ณMicrosiga           บ Data ณ  10/09/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณAtualiza a Reserva na Migracao.                             บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function DIPATURES()                    
	If (AllTrim(Upper(U_DipUsr()))$'MCANUTO/DDOMINGOS/VQUEIROZ/VEGON/RBORGES')  	
		Processa({||ATURES()},"Gerando Novas Reservas...")
	Else 
		Aviso('Aten็ใo',"Usuแrio sem autoriza็ใo para executar esta rotina!",{'Ok'}) 
	Endif
Return

Static Function AtuRes()
Local cQuery   := ""
Local cPedido  := ""
Local aBoxParam:= {}
Local aRetParam:= {}
Local nTotRec  := 0

Aadd(aBoxParam,{2,"Quais Pedidos",2,{"1 - Todos Liberados","2 - Pedido Especifico"},100,"",.F.})
Aadd(aBoxParam,{1,"Pedido"		 ,Space(TamSX3("C5_NUM")[1]),"@!","","","",50,.F.})
Aadd(aBoxParam,{2,"Estorna/Reserva",0,{"1 - Estorna","2 - Reserva"},100,"",.F.})

If ParamBox(aBoxParam,"Informe os Parametros",@aRetParam)
	
	MV_Par01:= IIf(ValType(Mv_Par01) == "N",StrZero(Mv_Par01,1),Left(Mv_Par01,1))
	MV_Par03:= IIf(ValType(Mv_Par03) == "N",StrZero(Mv_Par03,1),Left(Mv_Par03,1))
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณSeleciono os items que precisam ser liberados.ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	cQuery:= " SELECT C5_NUM "
	cQuery+= " FROM " + RetSqlName("SC5") + " SC5 "
	
	IF (MV_PAR01=="1")
		If (Mv_Par03 == "1")
			cQuery+= " WHERE D_E_L_E_T_ = ' ' AND C5_NOTA='' AND C5_TIPO = 'N' AND C5_LIBEROK = 'S' AND C5_EMISSAO >= '20060101' AND C5_FILIAL = '" + xFilial("SC5") + "' "
		Else
			cQuery+= " WHERE D_E_L_E_T_ = ' ' AND C5_NOTA='' AND C5_TIPO = 'N' AND C5_LIBEROK <> 'S' AND C5_EMISSAO >= '20060101' AND C5_FILIAL = '" + xFilial("SC5") + "' "
		EndIf
	ELSE
		cQuery+= " WHERE D_E_L_E_T_ = ' ' AND C5_NUM = '" + MV_PAR02 + "' AND C5_FILIAL = '" + xFilial("SC5") + "' "
	ENDIF
	
	cQuery+= " ORDER BY C5_NUM "
	cQuery := ChangeQuery(cQuery)
	
	DbCommitAll()
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"QRY",.T.,.T.)
	Count To nTotRec
	
	dbSelectArea("QRY")
	dbGoTop()
	ProcRegua(nTotRec)
	
	While !Eof()
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณExecuta rotina para a reserva dos itens liberados para posterior faturamento.ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		If !Empty(cPedido)
			cPedido+= ","
		EndIf
		
		cPedido+= "'"+QRY->C5_NUM+"'"
		
		
		If (Mv_Par03 == "1")
			IncProc("Estornando Reservas para o Pedido "+QRY->C5_NUM)
			U_DIPXRESE("EST",QRY->C5_NUM,"","","","","","","","","","")
		Else
			IncProc("Gerando Reservas para o Pedido "+QRY->C5_NUM)
			U_DIPXRESE("ATU",QRY->C5_NUM,"","","","","","","","","","")
		EndIf
		
		dbSelectArea("QRY")
		dbSkip()
	End
	QRY->(dbCloseArea())
EndIf

cPedido:= "(" + cPedido + ")"
MemoWrite("C:\DIPROMED.TXT",cPedido)
Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณENVEMAIL  บAutor  ณFabio Rogerio       บ Data ณ  02/11/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRotina para o envio de email ao operador.                   บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function ENVEMAIL(cEmail,cAssunto,aEnv_STD,aAttach,Operad,cFilPar)

Local cAccount  := Lower(Alltrim(GetMv("MV_RELACNT")))
Local cFrom     := Lower(Alltrim(GetMv("MV_RELACNT")))
Local cPassword := Alltrim(GetMv("MV_RELPSW"))
Local cServer   := Alltrim(GetMv("MV_RELSERV"))
Local cEmailTo  := ""
Local cEmailCc  := ""
Local cEmailBcc := If(Alltrim(Posicione("SU7",1,xFilial("SU7",Iif(cFilPar==Nil,cFilAnt,cFilPar))+OPERAD,"U7_POSTO"))=='01',';elizabete@dipromed.com.br','')
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
cMsg += '<table width="100%" cellspacing="0" cellpadding="0"><font size="2" color="blue">'
cMsg += '<tr>'
cMsg += '<td>'+ If(cEmpAnt=="04","HQ","DIPROMED"+'-'+SM0->M0_FILIAL)+'</td>'
cMsg += '</tr>'
cMsg += '</font></table>'
cMsg += '<HR Width=85% Size=3 Align=Centered Color=Red>'
cMsg += '<Table Align=Center BorderColor=#000000 CELLPADDING=4 CELLSPACING=0 Width=100%>'

/*=============================================================================*/
/*Definicao do cabecalho do relat๓rio                                          */
/*=============================================================================*/

If "Estorno" $ cAssunto
	cMsg += '<tr align="Center">'
	cMsg += '<td width="100%" colspan="2"><font size="4" color="blue">Foi necessแrio excluir a reserva automแtica. </font><BR><HR></td><BR><HR>'
	cMsg += '</tr>'
Else
	cMsg += '<tr Align=Center>'
	cMsg += '<td width="100%" colspan="2"><font size="4" color="blue">Os produtos abaixo estao disponiveis, por favor EFETUE a reserva dos itens em seu pedido. Nao sera realizado reserva automatica.</font><BR><HR></td><BR><HR>'
	cMsg += '</tr>'
Endif

cMsg += '<tr>'
cMsg += '<td width="100%"><font size="3" color="red">Pedido - ' + aEnv_STD[1,12] + '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; Vendedor : ' + aEnv_STD[1,16] + '-' + aEnv_STD[1,17] + '</font></td>
cMsg += '</tr>'

cMsg += '<tr>'
cMsg += '<td width="100%" colspan="2"><font size="3" color="red">Cliente: ' + aEnv_STD[1,1] + '-' + aEnv_STD[1,2] + '-' + aEnv_STD[1,3] + '</font></td>'
cMsg += '</tr>'

//cMsg += '<tr>
//cMsg += '<td width="100%" colspan="2"><font size="2" color="blue">End.: ' + aEnv_STD[1,4] + ' - Bairro: ' + aEnv_STD[1,5] +'</font></td>'
//cMsg += '</tr>

//cMsg += '<tr>'
//cMsg += '<td width="100%" colspan="2"><font size="2" color="blue">CEP: ' + aEnv_STD[1, 6] +' - Cidade: '+ aEnv_STD[1, 7] +' - Estado: '+ aEnv_STD[1, 8] + '</font></td>'
//cMsg += '</tr>

//cMsg += '<tr>'
//cMsg += '<td width="100%" colspan="2"><font size="2" color="blue">CNPJ: ' + aEnv_STD[1, 9] +' - I.E.: '+ aEnv_STD[1,10] + ' - Fone: '+ aEnv_STD[1,11] + '</font></td>'
//cMsg += '</tr>'

cMsg += '</table>'


cMsg += '<table width="100%" cellspacing="0" cellpadding="0"><font size="2" color="blue">'
cMsg += '<tr>'
cMsg += '<td>===============================================================================================================</td>'
cMsg += '</tr>'
cMsg += '</font></table>'

cMsg += '<table width="100%" cellspacing="0" cellpadding="0"><font size="2" color="blue">'
cMsg += '<td width="80%">C๓digo - Descri็ใo</td>'
cMsg += '<td width="20%" align="right">Quantidade</td>'
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

For nI := 1 to Len(aEnv_STD)
	nLin := nI
	If Mod(nLin,2) == 0
		cMsg += '<table width="100%" border="0" cellspacing="0" cellpadding="0">'
		cMsg += '<tr BgColor="#B0E2FF">'
		cMsg += '<td width="80%"><font size="2">' + aEnv_STD[nLin,13] + ' - ' + aEnv_STD[nLin,14] + '</font></td>'
		cMsg += '<td width="20%" align="right"><font size="2">' + Transform(aEnv_STD[nLin,15],"@E 999999999") + '</font></td>'
		cMsg += '</tr>'
		cMsg += '</table>'
	Else
		cMsg += '<table width="100%" border="0" cellspacing="0" cellpadding="0">
		cMsg += '<tr bgcolor="#c0c0c0">
		cMsg += '<td width="80%"><font size="2">' + aEnv_STD[nLin,13] + ' - ' + aEnv_STD[nLin,14] + '</font></td>'
		cMsg += '<td width="20%" align="right"><font size="2">' + Transform(aEnv_STD[nLin,15],"@E 999999999") + '</font></td>'
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
cMsg += '<td colspan="10"><font color="BLUE" size="2">Mensagem enviada automaticamente pelo sistema PROTHEUS - <font color="BLUE" size="1">(DIPXRESE.PRW)</td>'
cMsg += '</tr>'

cMsg += '</table>'
cMsg += '</body>'
cMsg += '</html>'

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณEnvia o mail para a lista selecionada. Envia como BCC para que a pessoa penseณ
//ณque somente ela recebeu aquele email, tornando o email mais personalizado.   ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

If GetNewPar("ES_ATIVJOB",.T.)   
	u_UEnvMail(cEmail,cAssunto,nil,"",cFrom,"ENVEMAIL(DIPXRESE.PRW)",cMsg)
Else
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
		lEnviouSDB	:= lResult
		DISCONNECT SMTP SERVER
	Else
		//Erro na conexao com o SMTP Server
		GET MAIL ERROR cError
		MsgInfo(cError,OemToAnsi("Aten็ใo"))
	EndIf
EndIf

Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ GrvLog   บAutor  ณCONSULTORIA         บ Data ณ  20/12/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRotina para gravacao do LOG do SB2                          บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function GrvLog(_cString)
If SuperGetMv("ES_LOGXRES",,.F.)
	If !File("LOG_SB2.LOG")
		nHandle := MsfCreate("LOG_SB2.LOG",0)
	Else
		nHandle := FOpen("LOG_SB2.LOG",2)
		fSeek(nHandle,0,2)
	EndIf
	If nHandle > 0         
		FWrite(nHandle,cUsername+';'+DtoC(dDataBase)+';'+Time()+';'+_cString +Chr(13)+Chr(10)) 
	    FClose(nHandle)
	EndIf
EndIf

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDIPXSVColsบAutor  ณD'Leme              บ Data ณ  10/21/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Armazena aCols, pois a qtde Liberada ้ alterada para o sis-บฑฑ
ฑฑบ          ณ tema nใo gerar o SC9 durante a grava็ใo                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ DIPROMED-Controle de reservas                              บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function DIPXSVCols(cPedido)
_cPvRese := cPedido
_aSvCols := aClone(aCols)
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัอออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDIPXGetColsบAutor  ณD'Leme             บ Data ณ  10/21/11   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯอออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Restaura aCols, pois a qtde Liberada ้ alterada para o sis-บฑฑ
ฑฑบ          ณ tema nใo gerar o SC9 durante a grava็ใo                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ DIPROMED-Controle de reservas                              บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function DIPXGetCols(cPedido)
Local aRet
If _cPvRese != Nil .And. cPedido == _cPvRese .And. _aSvCols != Nil
	aRet := aClone(_aSvCols)
Else
	aRet := aClone(aCols)
EndIf
Return aRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDIPXSvExc บAutor  ณD'Leme              บ Data ณ  10/21/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Armazena parโmetros de exclusใo, para compatibilidade da   บฑฑ
ฑฑบ          ณ execu็ใo desta opera็ใo dentro da transa็ใo                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ DIPROMED-Controle de reservas                              บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function DIPXSvExc(cPedido,cItem,cProduto,cLocal,cSeq,nQtdLib,cLoteCtl,cNumLote,cNumSeri,cLocaliz,cChaveSDB)
If _aSvExc == Nil .Or. _aSvExc[1][1] != cPedido
	_aSvExc := {}
EndIf
aAdd( _aSvExc, {cPedido,cItem,cProduto,cLocal,cSeq,nQtdLib,cLoteCtl,cNumLote,cNumSeri,cLocaliz,cChaveSDB})
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDIPXGetExcบAutor  ณD'Leme              บ Data ณ  10/21/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Restaura parโmetros de exclusใo, para compatibilidade da   บฑฑ
ฑฑบ          ณ execu็ใo desta opera็ใo dentro da transa็ใo                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ DIPROMED-Controle de reservas                              บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function DIPXGetExc(_nI,cPedido,cItem,cProduto,cLocal,cSeq,nQtdLib,cLoteCtl,cNumLote,cNumSeri,cLocaliz,cChaveSDB)
Local _lRet := .F.

If _aSvExc != Nil .And. _nI <= Len(_aSvExc) .And. _aSvExc[1][1] == cPedido
	lRet := .T.

	cPedido 	:= _aSvExc[_nI][01]
	cItem		:= _aSvExc[_nI][02]
	cProduto 	:= _aSvExc[_nI][03]
	cLocal		:= _aSvExc[_nI][04]
	cSeq		:= _aSvExc[_nI][05]
	nQtdLib		:= _aSvExc[_nI][06]
	cLoteCtl	:= _aSvExc[_nI][07]
	cNumLote	:= _aSvExc[_nI][08]
	cNumSeri	:= _aSvExc[_nI][09]
	cLocaliz	:= _aSvExc[_nI][10]
	cChaveSDB	:= _aSvExc[_nI][11]
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHasNwExc  บAutor  ณD'Leme              บ Data ณ  10/21/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Verifica se o Pedido possui exclusao pendente- Utilizado   บฑฑ
ฑฑบ          ณ no PE MAAVSC5                                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ DIPROMED-Controle de reservas                              บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function HasNwExc(cPedido)
Local lNewResPV	:= SuperGetMv("ES_TPRESPV",,"1") == "2"
Local lRet		:= .F.

If lNewResPV .And. _aSvExc != Nil .And. _aSvExc[1][1] == cPedido
	lRet := .T.
EndIf

Return lRet
                                                                       
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPriSepTran  บAutor  ณMaximo Canuto     บ Data ณ  26/02/15   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Verificar a prioridade da transportadora baseada no tipo   บฑฑ
ฑฑบ          ณ de entrega e no horแrio de libera็ใo do Pedido.            บฑฑ
ฑฑบ          ณ cPriTran = 0 (Coleta/Retira/Sedex e Malote)                บฑฑ
ฑฑบ          ณ cPriTran = 1 (Jamef e Utilํssimo)                          บฑฑ
ฑฑบ          ณ cPriTran = 8 (Emovere)                                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ		      ณ DIPROMED-Controle de reservas                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function PriSepTran(cTransport)
//Local cPriTran := Posicione("SA4",1,xFilial("SA4")+cTransport,"A4_PRIENTR")
Local aArea	   := GetArea()
Local aAreaSA1 := SA1->(GetArea())
Local aAreaZZY := ZZY->(GetArea())
Local cPriReal := ""
Local cHoraAtu := Left(Time(),5)
Local cGPRCXF  := ""


If cEmpAnt == '04'
	
	Do Case
		Case !(cTransport $ '000905/003025/100000/000150') //.And. cHoraAtu <= '14:00' //cPriTran = 0 (Coleta/Retira/Sedex e Malote)
			cPriReal := '0'
		Case cTransport  $ '000905/003025' //.And. cHoraAtu <= '16:10' //cPriTran = 1 (Jamef e Utilํssimo)
			cPriReal := '2'
		Case cTransport == '100000'// .And. cHoraAtu <= '16:10' //EMOVERE
			cPriReal := '7'
	EndCase
	
	If cEmpAnt <> "04"
		If SC5->C5_CLIENTE$GetNewPar("ES_DCLICXF","000665")
			cPriReal := '1'
		EndIf
	Else
		cGPRCXF := Posicione("SA1",1,xFilial("SA1")+SC5->C5_CLIENTE,'A1_GRPVEN')
		If (SC5->C5_CLIENTE$GetNewPar("ES_DCLICXF","000665") .Or. cGPRCXF$GetNewPar("ES_DGRPCXF","000175")) .And. !U_AmostrasHQ()
			cPriReal := '1'
		EndIf
		cGPRCXF := ""	
	EndIf	
	
	If SC5->C5_TIPODIP = "1" .And. substr(SC5->C5_XRECOLH,1,3) $ "ACR/GUI"
		cPriReal := '1'
	EndIf
	
	If SubStr(SC5->C5_MENNOTA,AT('=',SC5->C5_MENNOTA),5) == "=ST=D" .AND. Val(Left(SC5->C5_MENNOTA,4)) > 0 .And. !(SC5->C5_ESTE$GetNewPar("ES_ESTNGST","BA"))
		cPriReal := '1'
	EndIf
	
	SA1->(dbSetOrder(1))
	If SA1->(dbSeek(xFilial("SA1")+SC5->(C5_CLIENTE+C5_LOJACLI)))
		If SA1->A1_TIPO=="F" .And. SA1->A1_CONTRIB=="2" .And. !(SC5->C5_ESTE$("SP/"+GetNewPar("ES_ESTNGCF","BA/MG")))
			cPriReal := '1'
		EndIf
	EndIf
	//Inํcio Delta - Gabriel Verํssimo Lakatos 12/11/19
	//Altera conte๚do da variแvel 'cPriReal' caso transportadora seja EMOVERE e esteja dentro do range cadastrado na ZZY
	If AllTrim(cTransport) == "100000" //EMOVERE
		ZZY->(DbSetOrder(1)) //ZZY_FILIAL+ZZY_TRANSP+ZZY_CEPDE+ZZY_CEPATE
		If ZZY->(DbSeek(xFilial("ZZY") + cTransport))
			While !ZZY->(EoF()) .And. AllTrim(ZZY->ZZY_TRANSP) == AllTrim(cTransport)
				If SC5->C5_CEPE >= ZZY->ZZY_CEPDE .And. SC5->C5_CEPE <= ZZY->ZZY_CEPATE
					cPriReal := ZZY->ZZY_PRIORI
					ZZY->(dbSkip())
				Else
					ZZY->(dbSkip())
				EndIf
			End
		EndIf
	EndIf
	//Fim Delta - Gabriel Verํssimo Lakatos 12/11/19
	
Else
	
	Do Case
		Case cTransport == '100000' .And. cHoraAtu <= '16:10' //EMOVERE
			cPriReal := '7'
		Case cTransport == '100000' .And. cHoraAtu >  '16:10' //EMOVERE
			cPriReal := '7' //'1'
		Case cTransport  $ '000150' .And. cHoraAtu >  '15:10' //cPriTran = 1 (Braspress)
			cPriReal := '9'
		Case cTransport  $ '000150' .And. cHoraAtu <= '15:10' //cPriTran = 1 (Braspress)
			cPriReal := '1'
		Case cTransport  $ '000111' .And. cHoraAtu >  '15:00' //cPriTran = 1 (Cliente Retira)
			cPriReal := '9'
		Case cTransport  $ '000111' .And. cHoraAtu <= '15:00' //cPriTran = 1 (Cliente Retira)
			cPriReal := '0'
		Case cTransport  $ '123455/003025' .And. cHoraAtu >  '16:10' //cPriTran = 8 (Ativa e Utilํssimo))
			cPriReal := '9'
		Case cTransport  $ '123455/003025' .And. cHoraAtu <= '16:10' //cPriTran = 1 (Ativa e Utilํssimo))
			cPriReal := '1'					
		Case !(cTransport $ '003025/100000/000150/123455/000111') .And. cHoraAtu <= '14:00' //cPriTran = 0 (Coleta/Retira/Sedex e Malote)
			cPriReal := '1'
		Case !(cTransport $ '003025/100000/000150/123455/000111') .And. cHoraAtu >  '14:00' //cPriTran = 0 (Coleta/Retira/Sedex e Malote)
			cPriReal := '9'
	EndCase
	
	If cEmpAnt <> "04"
		If SC5->C5_CLIENTE$GetNewPar("ES_DCLICXF","000665")
			cPriReal := '0'
		EndIf
	Else
		cGPRCXF := Posicione("SA1",1,xFilial("SA1")+SC5->C5_CLIENTE,'A1_GRPVEN')
		If (SC5->C5_CLIENTE$GetNewPar("ES_DCLICXF","000665") .Or. cGPRCXF$GetNewPar("ES_DGRPCXF","000175")) .And. !U_AmostrasHQ()
			cPriReal := '0'
		EndIf
		
		cGPRCXF := ""	
	EndIf
	
	If SC5->C5_TIPODIP = "1" .And. substr(SC5->C5_XRECOLH,1,3) $ "ACR/GUI"
		cPriReal := '0'
	EndIf
	
	If SubStr(SC5->C5_MENNOTA,AT('=',SC5->C5_MENNOTA),5) == "=ST=D" .AND. Val(Left(SC5->C5_MENNOTA,4)) > 0 .And. !(SC5->C5_ESTE$GetNewPar("ES_ESTNGST","BA"))
		If cHoraAtu <= '14:00' 
			cPriReal := '0'
		Else
			cPriReal := '9'
		EndIf
	EndIf
	
	SA1->(dbSetOrder(1))
	If SA1->(dbSeek(xFilial("SA1")+SC5->(C5_CLIENTE+C5_LOJACLI)))
		If SA1->A1_TIPO=="F" .And. SA1->A1_CONTRIB=="2" .And. !(SC5->C5_ESTE$("SP/"+GetNewPar("ES_ESTNGCF","BA/MG")))
			cPriReal := '0'
		EndIf
	EndIf
	//Inํcio Delta - Gabriel Verํssimo Lakatos 12/11/19
	//Altera conte๚do da variแvel 'cPriReal' caso transportadora seja EMOVERE e esteja dentro do range cadastrado na ZZY
	If AllTrim(cTransport) == "100000" //EMOVERE
		ZZY->(DbSetOrder(1)) //ZZY_FILIAL+ZZY_TRANSP+ZZY_CEPDE+ZZY_CEPATE
		If ZZY->(DbSeek(xFilial("ZZY") + cTransport))
			While !ZZY->(EoF()) .And. AllTrim(ZZY->ZZY_TRANSP) == AllTrim(cTransport)
				If SC5->C5_CEPE >= ZZY->ZZY_CEPDE .And. SC5->C5_CEPE <= ZZY->ZZY_CEPATE
					cPriReal := ZZY->ZZY_PRIORI
					ZZY->(dbSkip())
				Else
					ZZY->(dbSkip())
				EndIf
			End
		EndIf	
	EndIf
	//Fim Delta - Gabriel Verํssimo Lakatos 12/11/19
	
EndIf


RestArea(aAreaSA1)
RestArea(aAreaZZY)
RestArea(aArea)

Return(cPriReal)

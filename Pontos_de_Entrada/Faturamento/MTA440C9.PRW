#Include "Protheus.ch"

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥MTA440C9  ∫Autor  ≥Microsiga           ∫ Data ≥  12/16/09   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥ PE Chamado apÛs geraÁ„o do SC9, para complementaÁ„o        ∫±±
±±∫          ≥                                                            ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ Especifico Dipromed                                        ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
User Function MTA440C9()
Local aArea		:= GetArea()
Local aAreaSF4	:= SF4->(GetArea())
Local aAreaSC6	:= SC6->(GetArea())
Local aAreaSC5	:= SC5->(GetArea())
Local aAreaSB2	:= SB2->(GetArea())

//-- Somente complemento quando for chamado ‡ partir do MATA450
If "MATA450" $ FunName()
	SC5->(dbSetOrder(1))
	If SC5->(dbSeek(xFilial("SC5")+SC9->C9_PEDIDO))
		SC6->(dbSetOrder(1))
		If SC6->(dbSeek(xFilial("SC6")+SC9->(C9_PEDIDO+C9_ITEM+C9_PRODUTO)))
			SF4->(dbSetOrder(1))
			If SF4->(dbSeek(xFilial("SF4")+SC6->C6_TES)) .And. SF4->F4_ESTOQUE == "N"
				RecLock("SC9",.F.)
				SC9->C9_OPERADO	:= SC5->C5_OPERADO
				SC9->C9_PARCIAL	:= " "
				SC9->C9_VEND	:= SC5->C5_VEND1
				SC9->C9_FORNEC	:= Posicione("SB1",1,xFilial("SB1")+SC9->C9_PRODUTO,"B1_PROC")
				SC9->C9_PRIRESE	:= Posicione("SU7",1,xFilial("SU7")+SC9->C9_OPERADO,"U7_PRIRESE")
				SC9->C9_PRIENTR	:= Posicione("SA4",1,xFilial("SA4")+SC5->C5_TRANSP,"A4_PRIENTR")
				SC9->C9_BLEST	:= "02"
				MsUnLock()
			EndIf
		EndIf
	EndIf
ElseIf "MATA410" $ FunName()
	SC5->(dbSetOrder(1))
	If SC5->(dbSeek(xFilial("SC5")+SC9->C9_PEDIDO))
		If   'VISTA' $ Posicione("SE4",1,XFILIAL("SE4")+SC5->C5_CONDPAG,'E4_DESCRI')   .And. SC5->C5_TIPO = 'N'
				SC6->(dbSetOrder(1))
			If SC6->(dbSeek(xFilial("SC6")+SC9->(C9_PEDIDO+C9_ITEM+C9_PRODUTO)))
				SF4->(dbSetOrder(1))
				If SF4->(dbSeek(xFilial("SF4")+SC6->C6_TES)) .And. SF4->F4_DUPLIC == "S" 
				
					RecLock("SC9",.F.)
					SC9->C9_BLCRED	:= " "
					MsUnLock()
				EndIf
			EndIf
		EndIf
	EndIf
ElseIf "MATA310"$Upper(FunName())
	SC5->(dbSetOrder(1))
	If SC5->(dbSeek(xFilial("SC5")+SC9->C9_PEDIDO))
		SC6->(dbSetOrder(1))
		If SC6->(dbSeek(xFilial("SC6")+SC9->(C9_PEDIDO+C9_ITEM+C9_PRODUTO)))
			SC9->(RecLock("SC9",.F.))  
				SC9->C9_BLEST   := " "
				SC9->C9_OPERADO	:= SC5->C5_OPERADO
				SC9->C9_PARCIAL	:= " "
				SC9->C9_VEND	:= SC5->C5_VEND1
				SC9->C9_LOTECTL := SC6->C6_LOTECTL
				SC9->C9_DTVALID := SC6->C6_DTVALID
				SC9->C9_LOCAL   := SC6->C6_LOCAL    
				SC9->C9_QTDVEN  := SC6->C6_QTDVEN
				SC9->C9_QTDORI  := SC6->C6_QTDVEN    
			SC9->(MsUnLock())
			SB2->(dbSetOrder(1))
			If SB2->(dbSeek(xFilial("SB2")+SC9->(C9_PRODUTO+C9_LOCAL)))
				SB2->(RecLock("SB2",.F.))
					SB2->B2_RESERVA := SB2->B2_RESERVA+SC6->C6_QTDVEN  
					SB2->B2_RESERV2 := SB2->B2_RESERV2+ConvUm(SC6->C6_PRODUTO,SC6->C6_QTDVEN,0,2)
					SB2->B2_QPEDVEN := SB2->B2_QPEDVEN-SC6->C6_QTDVEN  
					SB2->B2_QPEDVE2 := SB2->B2_QPEDVE2-ConvUm(SC6->C6_PRODUTO,SC6->C6_QTDVEN,0,2)
				SB2->(MsUnlock())
			EndIf
			GravaEmp(	SC6->C6_PRODUTO,; 	//-- 01.C¢digo do Produto
						SC6->C6_LOCAL,;   	//-- 02.Local
						SC6->C6_QTDVEN,;	//-- 03.Quantidade
						Nil,;				//-- 04.Quantidade 2UM
						SC6->C6_LOTECTL,;  	//-- 05.Lote
						Nil,;  				//-- 06.SubLote
						SC6->C6_LOCALIZ,; 	//-- 07.Localizaá∆o
						Nil,; 				//-- 08.Numero de SÇrie
						Nil,;         		//-- 09.OP
						SC9->C9_SEQUEN,;	//-- 10.Seq. do Empenho/Liberaá∆o do PV (Pedido de Venda)
						SC9->C9_PEDIDO,;    //-- 11.PV
						SC9->C9_ITEM,;      //-- 12.Item do PV
						'SC6',;    			//-- 13.Origem do Empenho
						Nil,;         		//-- 14.OP Original
						Nil,;         		//-- 15.Data da Entrega do Empenho
						Nil,;	    		//-- 16.Array para Travamento de arquivos
						.F.,;     			//-- 17.Estorna Empenho?
						Nil,;         		//-- 18.ê chamada da Projeá∆o de Estoques?
						.F.,;         		//-- 19.Empenha no SB2?
						.F.,;         		//-- 20.Grava SD4?
						.T.,;         		//-- 21.Considera Lotes Vencidos?
						.T.,;         		//-- 22.Empenha no SB8/SBF?
						.T.)        		//-- 23.Cria SDC?					
		EndIf
	EndIf
EndIf

RestArea(aAreaSB2)
RestArea(aAreaSF4)
RestArea(aAreaSC6)
RestArea(aAreaSC5)
RestArea(aArea)   

Return
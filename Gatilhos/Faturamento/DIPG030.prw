#INCLUDE "PROTHEUS.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณNOVO6     บAutor  ณMicrosiga           บ Data ณ  05/16/14   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function DIPG030()
Local nI := 0
Local nPosPrc    := aScan(aHeader, { |x| Alltrim(x[2]) == "C6_PRCVEN" }) 
Local nPosQtd    := aScan(aHeader, { |x| Alltrim(x[2]) == "C6_QTDVEN" })  
Local nPosPro    := aScan(aHeader, { |x| Alltrim(x[2]) == "C6_PRODUTO"})
Local nPosLot    := aScan(aHeader, { |x| Alltrim(x[2]) == "C6_LOTECTL"})
Local nPosTot    := aScan(aHeader, { |x| Alltrim(x[2]) == "C6_VALOR"  })
Local nPosTAB  	 := aScan(aHeader, { |x| Alltrim(x[2]) == "C6_PRUNIT" })
Local nPosUPrc   := aScan(aHeader, { |x| Alltrim(x[2]) == "C6_USERPRC"})
Local nPosCSis   := aScan(aHeader, { |x| Alltrim(x[2]) == "C6_XCALCSI"})
Local nPosMini   := aScan(aHeader, { |x| Alltrim(x[2]) == "C6_PRVMINI"})
Local nPosSupe   := aScan(aHeader, { |x| Alltrim(x[2]) == "C6_PRVSUPE"})
Local nDesCond   := 0
Local nPorcAume	 := 0
Local nFatorRec  := 0

If (Type("l410Auto") == "U" .OR. !l410Auto )
	If M->C5_TPFRETE=="C" .And. M->C5_ESTE<>"SP" .And. DipTemFra()		
		M->C5_TPFRETE := ""
		Return M->C5_TPFRETE
	EndIf
	If Len(aCols) > 0 .And. aCols[1,nPosPrc] > 0 .And. Alltrim(Posicione("SU7",1,xFilial("SU7")+M->C5_OPERADO,"U7_POSTO"))=="02"
		If Aviso("Aten็ใo","Tipo de frete alterado. Confirma o recแlculo dos itens do pedido?",{"Sim","Nใo"},1)==1
			SE4->(DbSetOrder(1))
			If !Empty(M->C5_CONDPAG) .And. SE4->(MsSeek(xFilial("SE4")+M->C5_CONDPAG))
				If SE4->E4_USERDES > 0
					nFatorRec := 1 - (SE4->E4_USERDES/100)
				Else                                      
					nFatorRec := 1 + (SE4->E4_XUSRACR/100)
				EndIf
			Else
				nFatorRec := 1
			EndIf
			
			If substr(M->C5_XRECOLH,1,3) $ "ACR"
				nPorcAume:= 1.16
			ElseIf substr(M->C5_XRECOLH,1,3) $ "ISE"
				nPorcAume:= 1.06
			EndIf
			
			For nI:= 1 to Len(aCols)
				SB1->(dbSetOrder(1))
				If Empty(aCols[nI,nPosLot]) .And. SB1->(dbSeek(xFilial("SB1")+aCols[nI,nPosPro]))
					
					nDesCond := Posicione("SE4",1,xFilial("SE4")+M->C5_CONDPAG,"E4_USERDES")
					nAcrCond := Posicione("SE4",1,xFilial("SE4")+M->C5_CONDPAG,"E4_XUSRACR")
					
					If substr(M->C5_XRECOLH,1,3) $ "ACR/ISE"
						If aCols[nI,nPosSupe] > 0
							aCols[nI,nPosPrc] := Round(NoRound(aCols[nI,nPosSupe]*nPorcAume,4)*nFatorRec,4)
						Else
							aCols[nI,nPosPrc] := Round(NoRound(aCols[nI,nPosMini]*nPorcAume,4)*nFatorRec,4)
						EndIf
					Else
						aCols[nI,nPosPrc] := if(SB1->B1_PRVSUPE>0,SB1->B1_PRVSUPE,SB1->B1_PRVMINI)
					EndIf
					
					aCols[nI,nPosPrc] := u_DipAcrCli(aCols[nI,nPosPrc],M->C5_CLIENTE,M->C5_LOJACLI,SB1->B1_COD)         
					
					If nDesCond > 0
						nValAux := Round(aCols[nI,nPosPrc]*aCols[nI,nPosQtd],4)
						nValDes := Round(nValAux * (nDesCond/100),4)
						nValAux := Round(nValAux - nValDes,4)
						nValAux := Round(nValAux / aCols[nI,nPosQtd],4)
						
						aCols[nI,nPosPrc] := nValAux
						//aCols[nI,nPosPrc] := aCols[nI,nPosPrc]-(aCols[nI,nPosPrc]*nDesCond/100)
					ElseIf nAcrCond > 0
						nValAux := Round(aCols[nI,nPosPrc]*aCols[nI,nPosQtd],4)
						nValDes := Round(nValAux * (nAcrCond/100),4)
						nValAux := Round(nValAux + nValDes,4)
						nValAux := Round(nValAux / aCols[nI,nPosQtd],4)
						
						aCols[nI,nPosPrc] := nValAux
						//aCols[nI,nPosPrc] := aCols[nI,nPosPrc]-(aCols[nI,nPosPrc]*nDesCond/100)
					EndIf
					
					aCols[nI,nPosTAB] := aCols[nI,nPosPrc]
					MaFisAlt("IT_PRCUNI",aCols[nI,nPosPrc],n)
					aCols[nI,nPosUPrc]:= aCols[nI,nPosPrc]
					aCols[nI,nPosTot] := A410Arred(aCols[nI,nPosQtd]*aCols[nI,nPosPrc],"C6_VALOR")
					MaFisAlt("IT_VALMERC",aCols[nI,nPosTot],n)
					
					If u_VldCifRev(M->C5_NUM,"M",.T.) .And. M->C5_TPFRETE == "C"
						ZZB->(dbSetOrder(1))
						If ZZB->(dbSeek(xFilial("ZZB")+M->C5_ESTE))
							If  M->C5_ESTE <> "SP" .Or. (M->C5_ESTE == "SP" .And. "DEMAIS CIDADES"$M->C5_DESTFRE)
								aCols[nI,nPosPrc] += Round(aCols[nI,nPosPrc]*(ZZB->ZZB_PERC/100),4)
								aCols[nI,nPosTAB] := aCols[nI,nPosPrc]
								aCols[nI,nPosTot] := Round(aCols[nI,nPosPrc]*aCols[nI,nPosQtd],2)
							EndIf
						EndIf
					EndIf
					aCols[nI,nPosCSis] := aCols[nI,nPosPrc]
				EndIf
			Next nI
			
			Ma410Rodap(,,0)
			
			If ( Type("l410Auto") == "U" .OR. !l410Auto )
				oGetDad:oBrowse:Refresh()
			EndIf                                                                                                                      
			U_DiprKardex(M->C5_NUM,u_DipUsr(),"TP_FRETE - RECALCULO - SIM",.t.,"62")
		Else
			U_DiprKardex(M->C5_NUM,u_DipUsr(),"TP_FRETE - RECALCULO - NรO",.t.,"62")
		EndIf
	EndIf 
EndIf	

Return M->C5_TPFRETE
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณNOVO6     บAutor  ณMicrosiga           บ Data ณ  05/16/14   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function DipTemFra()
Local lRet := .F.
Local nPosPro    := aScan(aHeader, { |x| Alltrim(x[2]) == "C6_PRODUTO"})

For nI:=1 to Len(aCols)
	If !aCols[nI,len(aHeader)+1]
		lRet := AllTrim(aCols[nI,nPosPro])$GetNewPar("ES_NFORASP","018591,425160,010601,400049,018583,400062,018584,010602,030484,030760,030761,030762,030763")
		If lRet
			MsgInfo("O produto "+AllTrim(aCols[nI,nPosPro])+" nใo pode ser enviado por CIF para fora de SP.","ES_NFORASP")
			Exit
		EndIf
	EndIf
Next nI
 
Return lRet
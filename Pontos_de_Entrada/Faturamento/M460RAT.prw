#INCLUDE "RWMAKE.CH"
#DEFINE RT_PEDIDO   01
#DEFINE RT_ITEM     02
#DEFINE RT_SEQUEN   03
#DEFINE RT_FRETE    04
#DEFINE RT_SEGURO   05
#DEFINE RT_DESPESA  06
#DEFINE RT_FRETAUT	07
#DEFINE RT_DESCONT  08
#DEFINE RT_PRECOIT  09
*----------------------------------------------*
User Function M460RAT()
*----------------------------------------------*
Local nTotal := 0
Local nScan               
Local nCntFor
Local aDipRat := Aclone(PARAMIXB)

U_DIPPROC(ProcName(0),U_DipUsr()) // MCVN - 22/01/2009

For nCntFor := 1 To Len(aDipItens)
	nScan := aScan(aDipPedido,{|x| x[1]==aDipItens[nCntFor][1]})
	If ( aDipItens[nCntFor][5] > 0 )
        aDipRat[nCntFor][1] := aDipItens[nCntFor][1] 	 
        aDipRat[nCntFor][2] := aDipItens[nCntFor][2] 	 
        aDipRat[nCntFor][3] := aDipItens[nCntFor][3] 	 
        aDipRat[nCntFor][4] := 0
        aDipRat[nCntFor][5] := 0
        aDipRat[nCntFor][6] := 0
        aDipRat[nCntFor][7] := 0
        aDipRat[nCntFor][8] := 0
        aDipRat[nCntFor][9] := {}
	
		If ( aDipItens[nCntFor][7] )
			aDipRat[nCntFor][RT_FRETE  ] := 0
			aDipRat[nCntFor][RT_SEGURO ] := 0
			aDipRat[nCntFor][RT_DESPESA] := 0
			aDipRat[nCntFor][RT_FRETAUT] := 0
			aDipRat[nCntFor][RT_DESCONT] := 0
		Else
			If aDipPedido[nScan][17][01] == 1
				aDipRat[nCntFor][RT_FRETE  ] := Round(If(aDipItens[nCntFor][4]==0,1,aDipItens[nCntFor][4])*aDipItens[nCntFor][5]*aDipPedido[nScan][06]/nDipValPed,2)
				aDipRat[nCntFor][RT_FRETAUT] := Round(If(aDipItens[nCntFor][4]==0,1,aDipItens[nCntFor][4])*aDipItens[nCntFor][5]*aDipPedido[nScan][09]/nDipValPed,2)
			Else
				dbSelectArea("SB1")
				dbSetOrder(1)
				MsGoto(aDipItens[nCntFor][12])
				aDipRat[nCntFor][RT_FRETE  ] := Round(If(aDipItens[nCntFor][4]==0,1,aDipItens[nCntFor][4])*SB1->B1_PESO*aDipPedido[nScan][06]/aDipPedido[nScan][16],2)
				aDipRat[nCntFor][RT_FRETAUT] := Round(If(aDipItens[nCntFor][4]==0,1,aDipItens[nCntFor][4])*SB1->B1_PESO*aDipPedido[nScan][09]/aDipPedido[nScan][16],2)
			EndIf
			If aDipPedido[nScan][17][02] == 1
				aDipRat[nCntFor][RT_DESPESA] := Round(If(aDipItens[nCntFor][4]==0,1,aDipItens[nCntFor][4])*aDipItens[nCntFor][5]*aDipPedido[nScan][08]/aDipPedido[nScan][05],2)
			Else
				dbSelectArea("SB1")
				dbSetOrder(1)
				MsGoto(aDipItens[nCntFor][12])
				aDipRat[nCntFor][RT_DESPESA] := Round(If(aDipItens[nCntFor][4]==0,1,aDipItens[nCntFor][4])*SB1->B1_PESO*aDipPedido[nScan][08]/aDipPedido[nScan][16],2)
			EndIf
			If aDipPedido[nScan][17][03] == 1
				aDipRat[nCntFor][RT_SEGURO] := Round(If(aDipItens[nCntFor][4]==0,1,aDipItens[nCntFor][4])*aDipItens[nCntFor][5]*aDipPedido[nScan][07]/aDipPedido[nScan][05],2)
			Else
				dbSelectArea("SB1")
				dbSetOrder(1)
				MsGoto(aDipItens[nCntFor][12])
				aDipRat[nCntFor][RT_SEGURO] := Round(If(aDipItens[nCntFor][4]==0,1,aDipItens[nCntFor][4])*SB1->B1_PESO*aDipPedido[nScan][07]/aDipPedido[nScan][16],2)
			EndIf
			aDipRat[nCntFor][RT_DESCONT] := Round(If(aDipItens[nCntFor][4]==0,1,aDipItens[nCntFor][4])*aDipItens[nCntFor][5]*aDipPedido[nScan][10]/aDipPedido[nScan][05],2)
		EndIf
	Else
        aDipRat[nCntFor][1] := aDipItens[nCntFor][1] 	 
        aDipRat[nCntFor][2] := aDipItens[nCntFor][2] 	 
        aDipRat[nCntFor][3] := aDipItens[nCntFor][3] 	 
        aDipRat[nCntFor][4] := 0
        aDipRat[nCntFor][5] := 0
        aDipRat[nCntFor][6] := 0
        aDipRat[nCntFor][7] := 0
        aDipRat[nCntFor][8] := 0
        aDipRat[nCntFor][9] := {}
	EndIf
Next nCntFor
//--------------------------------------------------------------------------
// Verifica se o ultimo item sera faturado para adicionar a diferenca de   
// arredondamento                                                          
//--------------------------------------------------------------------------
For nCntFor := 1 To Len(aDipPedido)
	nScan := aScan(aDipRat,{|x|   x[1]==aDipPedido[nCntFor][1].And.;
	x[2]==aDipPedido[nCntFor][2].And.;
	x[3]==aDipPedido[nCntFor][3]})
	If ( nScan > 0 )
		aDipRat[nScan][RT_FRETE  ] += aDipPedido[nCntFor][11]
		aDipRat[nScan][RT_SEGURO ] += aDipPedido[nCntFor][12]
		aDipRat[nScan][RT_DESPESA] += aDipPedido[nCntFor][13]
		aDipRat[nScan][RT_FRETAUT] += aDipPedido[nCntFor][14]
		aDipRat[nScan][RT_DESCONT] += aDipPedido[nCntFor][15]
	EndIf
Next nCntFor

//--------------------------------------------------------------------------
// Verifica se ha valores negativos no rateio                              
//--------------------------------------------------------------------------
For nScan := Len(aDipRat) To 2 STEP -1
	If aDipRat[nScan][RT_FRETE   ] < 0
		aDipRat[nScan-1][RT_FRETE  ] += aDipRat[nScan][RT_FRETE]
		aDipRat[nScan  ][RT_FRETE  ] := 0
	EndIf
	If aDipRat[nScan][RT_SEGURO  ] < 0
		aDipRat[nScan-1][RT_SEGURO ] += aDipRat[nScan][RT_SEGURO]
		aDipRat[nScan  ][RT_SEGURO ] := 0
	EndIf
	If aDipRat[nScan][RT_DESPESA ] < 0
		aDipRat[nScan-1][RT_DESPESA] += aDipRat[nScan][RT_DESPESA]
		aDipRat[nScan  ][RT_DESPESA] := 0
	EndIf
	If aDipRat[nScan][RT_FRETAUT ] < 0
		aDipRat[nScan-1][RT_FRETAUT] += aDipRat[nScan][RT_FRETAUT]
		aDipRat[nScan  ][RT_FRETAUT] := 0
	EndIf
	If aDipRat[nScan][RT_DESCONT] < 0
		aDipRat[nScan-1][RT_DESCONT] += aDipRat[nScan][RT_DESCONT]
		aDipRat[nScan][RT_DESCONT  ] := 0
	EndIf
Next nScan

Return(aDipRat)
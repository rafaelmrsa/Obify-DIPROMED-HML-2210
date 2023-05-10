#INCLUDE "Protheus.ch"

/*====================================================================================\
|Programa  | DIPVG022       | Autor | GIOVANI.ZAGO               | Data | 12/07/2011  |
|=====================================================================================|
|Descrição | Gatilho de cliente para consumidor final fora de SP                      |
|          |                                                                          |
|          |                                                                          |
|=====================================================================================|
|Sintaxe   | DIPVG022                                                                 |
|=====================================================================================|
|Uso       | Especifico DIPROMED                                                      |
|=====================================================================================|
|........................................Histórico....................................|
\====================================================================================*/
*-------------------------*
User Function DIPG022 ()
*-------------------------*
Local nFatorRec     := 1
Local nPorcAume     := 0
Local _nPosMrgAtu   := aScan(aHeader, { |x| Alltrim(x[2]) == "C6_MARGATU" })
Local _nPosMrgIte   := aScan(aHeader, { |x| Alltrim(x[2]) == "C6_MARGITE" })
Local _nPosTotItem  := aScan(aHeader, { |x| Alltrim(x[2]) == "C6_VALOR"   })
Local _nPosNota     := aScan(aHeader, { |x| Alltrim(x[2]) == "C6_NOTA"    })
Local _nPosTES      := aScan(aHeader, { |x| Alltrim(x[2]) == "C6_TES"     })
Local _nPosPrcven   := aScan(aHeader, { |x| Alltrim(x[2]) == "C6_PRCVEN"  })
Local _nPosQtdVen	:= aScan(aHeader, { |x| Alltrim(x[2]) == "C6_QTDVEN"  })
Local _nPosUPrc 	:= aScan(aHeader, { |x| Alltrim(x[2]) == "C6_USERPRC" })
Local _nPosUDes 	:= aScan(aHeader, { |x| Alltrim(x[2]) == "C6_USERDES" })
Local _nPosUAcr 	:= aScan(aHeader, { |x| Alltrim(x[2]) == "C6_XUSRACR" })
Local _nPosPrUnit	:= aScan(aHeader, { |x| Alltrim(x[2]) == "C6_PRUNIT"  })
Local _nPosDescont  := aScan(aHeader, { |x| Alltrim(x[2]) == "C6_DESCONT" })
Local _nPosValDesc  := aScan(aHeader, { |x| Alltrim(x[2]) == "C6_VALDESC" })
Local _nPosProd     := aScan(aHeader, { |x| Alltrim(x[2]) == "C6_PRODUTO" })
Local _nPosQtdLib   := aScan(aHeader, { |x| Alltrim(x[2]) == "C6_QTDLIB"  })
Local _nPosQtdEnt   := aScan(aHeader, { |x| Alltrim(x[2]) == "C6_QTDENT"  })
Local _nPosQtdEmp   := aScan(aHeader, { |x| Alltrim(x[2]) == "C6_QTDEMP"  })
Local _nPosCusto    := aScan(aHeader, { |x| Alltrim(x[2]) == "C6_CUSTO"   })
Local _nPosTipoDip  := aScan(aHeader, { |x| Alltrim(x[2]) == "C6_TIPODIP" })
Local _nPosQtdOrc   := aScan(aHeader, { |x| Alltrim(x[2]) == "C6_QTDORC"  })
Private _nPrVend    := _nPosPrcven
Private _nPosMini   := aScan(aHeader, { |x| Alltrim(x[2]) == "C6_PRVMINI"  })
Private _nPosSupe   := aScan(aHeader, { |x| Alltrim(x[2]) == "C6_PRVSUPE"  })

IF !aCols[n,Len(aHeader)+1]
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
	
	If substr(M->C5_XRECOLH,1,3) $ "ACR/REC/ISE"
		If  aCols[n,_nPosSupe] > 0
			aCols[n,_nPosUPrc] := Iif( nFatorRec == 1, 0, (aCols[n,_nPosSupe]*nPorcAume) )
			aCols[n,_nPosPrcVen] := ((aCols[n,_nPosSupe]*nPorcAume)*nFatorRec)		
		ELSE
			aCols[n,_nPosUPrc] := Iif( nFatorRec == 1, 0, (aCols[n,_nPosMini]*nPorcAume) )
			aCols[n,_nPosPrcVen] := ((aCols[n,_nPosMini]*nPorcAume)*nFatorRec)			
		EndIf

		aCols[n,_nPosTotItem] := aCols[n,_nPosPrcVen]*aCols[n,_nPosQtdVen]     
		
		If SE4->E4_USERDES > 0
			aCols[n,_nPosUDes] := Round(aCols[n,_nPosUPrc]*aCols[n,_nPosQtdVen]*((SE4->E4_USERDES)/100),2)
		Else                                                                                                       
			aCols[n,_nPosUAcr] := Round(aCols[n,_nPosUPrc]*aCols[n,_nPosQtdVen]*((SE4->E4_XUSRACR)/100),2)
		EndIf 
	EndIf
EndIf

If ( Type("l410Auto") == "U" .OR. !l410Auto )
	oGetDad:oBrowse:Refresh()
EndIf

U_DIPG006()
Return(aCols[n,_nPosPrcVen])






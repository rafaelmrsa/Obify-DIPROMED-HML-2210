#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'TOTVS.CH'

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TMCALFRE  ºAutor  ³Microsiga           º Data ³  05/16/17   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function TMCALFRE()
	Local aParam   := PARAMIXB
	Local aRet     := nil
	Local nValRet  := 0
	Local nValFre  := 0
	Local nValTx   := 0
	Local nValICM  := 0
	Local nPeso    := 0
	Local nPerTx   := 0
	Local cDipParam:= AllTrim(GetNewPar("ES_TMCALFRE","1.45|12")) //Valor do excedente | Percentual do ICM
	Local nPar01   := Val(SubStr(cDipParam,1,At("|",cDipParam)-1))//Valor do excedente
	Local nPar02   := Val(SubStr(cDipParam,At("|",cDipParam)+1,Len(cDipParam))) //Percentual do ICM
	Local aNf      := aClone(aParam[28])  //-- Vetor aNFCTR
	Default aParam := {}

	If Alltrim(aNf[1,3]) == '011050' .And. Alltrim(aNf[1,4]) == '01'
		Return Nil
	Else
		If Len(aParam)>0
			aRet  	:= {}
			/*
			If aParam[4] > 100 .And. aParam[21]<>"000006"
				nPeso 	:= aParam[4]-100
				nValExc := nPeso*nPar01
				aAdd(aRet,{'12',nValExc})
			EndIf
			*/
			
			For nI:=1 to Len(aParam[1])
				If aParam[1,nI,3]=='05'
					nPerTx := aParam[1,nI,2]/100
				Else
					nValFre += aParam[1,nI,2]
				EndIf
			Next nI

			nValTx := nValFre*nPerTx
			aAdd(aRet,{'05',nValTx})

			/* IMPOSTO CALCULADO PELO PADRAO - DESCONSIDERADA ESTA REGRA
			If aParam[21]<>"000006"
				nValICM := (nValFre+nValTx)/((100-nPar02)/100)-(nValFre+nValTx)
				aAdd(aRet,{'11',nValICM})
			EndIf
			*/
		EndIf
	EndIf

Return aRet

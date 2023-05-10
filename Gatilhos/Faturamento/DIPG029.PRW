#INCLUDE "Protheus.ch"
#INCLUDE "RWMAKE.CH"

/*====================================================================================\
|Programa  | DIPG029       | Autor | GIOVANI.ZAGO               | Data | 17/01/2012   |
|=====================================================================================|
|Descrição | Validação de TES HEALTH QUALITY                                          |
|          |                                                                          |
|          |                                                                          |
|=====================================================================================|
|Sintaxe   | DIPG029                                                                  |
|=====================================================================================|
|Uso       | Especifico DIPROMED-HEALTH QUALITY                                       |
|=====================================================================================|
|........................................Histórico....................................|
\====================================================================================*/
*--------------------------------------------------------------------------*
User Function DIPG029()
*--------------------------------------------------------------------------*

Local _aArea          	 := GetArea()
Local _nPosTES           := aScan(aHeader, { |x| Alltrim(x[2]) == "C6_TES"      })
Local _nPosCF            := aScan(aHeader, { |x| Alltrim(x[2]) == "C6_CF"       })
Local _nPosProdut        := aScan(aHeader, { |x| Alltrim(x[2]) == "C6_PRODUTO"  })
Local aAreaSB1			 := SB1->(GetArea())

If cEmpAnt = "04"
	SA1->(dbSetOrder(1))
	If SA1->(dbSeek(xFilial("SA1")+ M->C5_CLIENTE + M->C5_LOJACLI))
	
		SB1->(dbSetOrder(1))      
		If SB1->(dbSeek(xFilial("SB1")+aCols[n,_nPosProdut]))
		
			If	SA1->A1_TIPO $ "R/S" .And. SA1->A1_CONTRIB <> "2" .And. SA1->A1_PESSOA = "J" 
				If SA1->A1_EST = "SP" .And. SB1->B1_PICMRET > 0 .And. SB1->B1_IPI = 0 .And. (SA1->A1_DREGESP = " " .Or. u_VldNCMHosp(SB1->B1_POSIPI) ) //Não pertence ao regime especial
					                                                                                                        // ou o produto não é Hospitalar
					aCols[n,_nPosTES]:= "654"                                                                          	    //regra passada pela Sirlene 07/10/2014
					aCols[n,_nPosCF] := "5401"
					
				ElseIf SB1->B1_PICMRET == 0 .And. SB1->B1_IPI > 0
					aCols[n,_nPosTES]:= "502"
					
					If SA1->A1_EST = "SP"
						aCols[n,_nPosCF] := "5101"
					Else
						If SA1->A1_CONTRIB = "2" .Or. Empty(SA1->A1_INSCR) .Or. "ISENT" $ SA1->A1_INSCR 
							aCols[n,_nPosCF] := "6107"
						Else
							aCols[n,_nPosCF] := "6101"
						EndIf
					EndIf
				EndIf                         				
			EndIf                             
			
			If Left(SB1->B1_POSIPI,4) == "9018" .And. SA1->A1_TIPO == "F" .And. SA1->A1_CONTRIB <> "1" .And. .F.  //Regra desativada e-mail da MACC
				If SB1->B1_PICM > 0 .And. SB1->B1_IPI > 0
					aCols[n,_nPosTES]:= "706"
				ElseIf SB1->B1_PICM > 0 
					aCols[n,_nPosTES]:= "703" 
				EndIf                      
				If SA1->A1_EST == "SP"
					aCols[n,_nPosCF] := "5101"
				Else 
					aCols[n,_nPosCF] := "6107"                         
				EndIf
			EndIf
		EndIf
	EndIf
EndIf                           

RestArea(aAreaSB1)
RestArea(_aArea)
Return (aCols[n,_nPosTES])
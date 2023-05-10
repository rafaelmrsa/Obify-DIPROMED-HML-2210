/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DIG021        ºAutor  ³Maximo Canuto      º Data ³  09/06/10º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ COMISSÃO QUANDO O PRODUTO ESTÁ EM PROMOÇÃO                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ NA ROTINA MATA241                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
#INCLUDE "TOPCONN.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"


User Function DIPG021()
       
Local _xAlias    := GetArea()
Local aPromoc    := {}
Local nPosPrc    := aScan(aHeader, { |x| Alltrim(x[2]) == "C6_PRCVEN" }) 
Local nPosQtd    := aScan(aHeader, { |x| Alltrim(x[2]) == "C6_QTDVEN" })  
Local nPComis1   := aScan(aHeader, { |x| Alltrim(x[2]) == "C6_COMIS1" })
Local nPosPro    := aScan(aHeader, { |x| Alltrim(x[2]) == "C6_PRODUTO"})
Local nPosST     := aScan(aHeader, { |x| Alltrim(x[2]) == "C6_XICMSRE"})
Local nPosTot    := aScan(aHeader, { |x| Alltrim(x[2]) == "C6_VALOR"  })
Local nPosTAB  	 := aScan(aHeader, { |x| Alltrim(x[2]) == "C6_PRUNIT" })
Local nPosUPrc   := aScan(aHeader, { |x| Alltrim(x[2]) == "C6_USERPRC"})
Local nPosCSis   := aScan(aHeader, { |x| Alltrim(x[2]) == "C6_XCALCSI"})
Local nPosMini   := aScan(aHeader, { |x| Alltrim(x[2]) == "C6_PRVMINI"})
Local nPosSupe   := aScan(aHeader, { |x| Alltrim(x[2]) == "C6_PRVSUPE"})
Local cTipoVen   := Posicione("SA3",1,xFilial("SA3")+M->C5_VEND1,"A3_TIPO")
Local cPosto     := Posicione("SU7",1,xFilial("SU7")+M->C5_OPERADO,"U7_POSTO")
Local nComis1    := Acols[n,nPComis1]
Local _nQtdVen	 := Acols[n,nPosQtd]
Local _nPrcVen	 := Acols[n,nPosPrc]
Local _cCodPro	 := Acols[n,nPosPro]         
Local nDesCond	 := 0
Local nPorcAume	 := 0
Local nFatorRec  := 0



//If Acols[n,nPosPrc] < SB1->B1_PRVSUPE .And. cPosto == '01' .And. cTipoVen == "E"
//Eriberto em 21/07/2010 solicitou a ALTERAÇÃO Da regra da promoção de comissão onde:
//O preço a ser considerado tem que ser menor ou igual o preço de promoção 
//E o preço de promoção usado tem que ser o C6_PRVSUPE E não mais o B1_PRVSUPE

/*
If Acols[n,nPosPrc] <= Acols[n,nPosSup] .And. cPosto == '01' .And. cTipoVen == "E"
	If Alltrim(Acols[n,nPosPro]) $ GetMv("MV_DCOMIS1")
		nComis1 := 0.50
	Else
		nComis1	:= Acols[n,nPComis1]
	Endif
Endif	
*/

//Alterado dia 10/08/10 para buscar o valor do Array e não mais pelo Preço de Promoção

//Tabela Referente ao Mês de Agosto de 2010
aPromoc :=   {{'010306', 4.970 },;
			  {'030373', 7.770 },;
  			  {'010788',28.200},;
			  {'013103', 0.790 },;
			  {'013104', 0.790 },;
			  {'013106', 0.790 },;
			  {'013107', 0.790 },;
			  {'013141', 2.140 },;
			  {'032130', 5.590 },;
			  {'010342', 8.480 },;
			  {'010684', 0.253 },;
			  {'030409', 0.393 },;
			  {'026053', 0.370 },;
			  {'010140', 0.615 },;
			  {'015042', 6.230 },;			
			  {'010601', 0.370 },;
			  {'010785', 8.590 },;
			  {'010784', 8.590 },;			  
			  {'080310', 8.590}}

If Alltrim(Acols[n,nPosPro]) $ GetMv("MV_DCOMIS1")			  
	If Acols[n,nPosPrc] <= aPromoc[aScan(aPromoc, { |x| Alltrim(x[1]) == Alltrim(Acols[n,nPosPro])}),2] .And. cPosto == '01' .And. cTipoVen == "E"	
		nComis1 := 0.50
	Else
		nComis1	:= Acols[n,nPComis1]
	Endif
Endif	
/* COMENTADO POR TIAGO STOCCO - OBIFY 07/06/2021  
If nPosST > 0 .And. Type("M->C5_ESTE")<>"U" .And. cEmpAnt == '01' .And. M->C5_TIPO=="N"
	Acols[n,nPosST] := U_M460SOLI(nil,nil,.T.,_nQtdVen,_cCodPro,_nPrcVen,M->C5_ESTE)[2]
EndIf
*/                         
If !aCols[n,Len(aHeader)+1] .And. cEmpAnt == '01' .And. M->C5_TIPO=="N" .And. (ReadVar()=="M->C6_QTDVEN" .Or. (ReadVar()=="M->C6_PRODUTO" .And. _nQtdVen>0 ))
	SE4->(DbSetOrder(1))
	If !Empty(M->C5_CONDPAG) .And. SE4->(MsSeek(xFilial("SE4")+M->C5_CONDPAG))
		If SE4->E4_USERDES > 0
			nFaorRec := 1-(SE4->E4_USERDES/100)
		Else
			nFaorRec := 1+(SE4->E4_XUSRACR/100)
		EndIf
	Else
		nFatorRec := 1
	EndIf
	
	If substr(M->C5_XRECOLH,1,3) $ "ACR"
		nPorcAume:= 1.16
	ElseIf substr(M->C5_XRECOLH,1,3) $ "ISE"
		nPorcAume:= 1.06
	EndIf
	
	SB1->(dbSetOrder(1))
	If SB1->(dbSeek(xFilial("SB1")+aCols[n,nPosPro]))
   		
	   	nDesCond := Posicione("SE4",1,xFilial("SE4")+M->C5_CONDPAG,"E4_USERDES")
	   	nAcrCond := Posicione("SE4",1,xFilial("SE4")+M->C5_CONDPAG,"E4_XUSRACR")
	   	
	   	If SubStr(M->C5_XRECOLH,1,3) $ "ACR/ISE"
			If  aCols[n,nPosSupe] > 0
				aCols[n,nPosPrc] := Round(NoRound(aCols[n,nPosSupe]*nPorcAume,4)*nFatorRec,4)
			Else
				aCols[n,nPosPrc] := Round(NoRound(aCols[n,nPosMini]*nPorcAume,4)*nFatorRec,4)
			EndIf
		Else
			aCols[n,nPosPrc] := if(SB1->B1_PRVSUPE>0,SB1->B1_PRVSUPE,SB1->B1_PRVMINI)
		EndIf      
		
		aCols[n,nPosPrc] := u_DipAcrCli(aCols[n,nPosPrc],M->C5_CLIENTE,M->C5_LOJACLI,SB1->B1_COD)
		
		If nDesCond > 0		                                                       
			nValAux := Round(aCols[n,nPosPrc]*_nQtdVen,4)
			nValDes := Round(nValAux * (nDesCond/100),4)
			nValAux := Round(nValAux - nValDes,4)
			nValAux := Round(nValAux /_nQtdVen,4)   
		                        
			aCols[n,nPosPrc] := nValAux				
			//aCols[n,nPosPrc] := aCols[n,nPosPrc]-(aCols[n,nPosPrc]*nDesCond/100)
		ElseIf nAcrCond > 0                         
			nValAux := Round(aCols[n,nPosPrc]*_nQtdVen,4)
			nValDes := Round(nValAux * (nAcrCond/100),4)
			nValAux := Round(nValAux + nValDes,4)
			nValAux := Round(nValAux /_nQtdVen,4)   
		                        
			aCols[n,nPosPrc] := nValAux							
		EndIf                                         
		
		aCols[n,nPosTAB] := aCols[n,nPosPrc]
		
		MaFisAlt("IT_PRCUNI",aCols[n,nPosPrc],n)
		aCols[n][nPosUPrc] := Acols[n,nPosPrc]      
		aCols[n][nPosTot]:= A410Arred(aCols[n,nPosQtd]*aCols[n,nPosPrc],"C6_VALOR")
		MaFisAlt("IT_VALMERC",aCols[n,nPosTot],n)	
		        
		If Alltrim(Posicione("SU7",1,xFilial("SU7")+M->C5_OPERADO,"U7_POSTO"))=="02"   
			If u_VldCifRev(M->C5_NUM,"M",.T.) .And. M->C5_TPFRETE == "C"
				ZZB->(dbSetOrder(1))
				If ZZB->(dbSeek(xFilial("ZZB")+M->C5_ESTE))			
					If  M->C5_ESTE <> "SP" .Or. (M->C5_ESTE == "SP" .And. "DEMAIS CIDADES"$M->C5_DESTFRE)      
						aCols[n,nPosPrc] += Round(aCols[n,nPosPrc]*(ZZB->ZZB_PERC/100),4)
						aCols[n,nPosTAB] := aCols[n,nPosPrc]      
						aCols[n,nPosTot] := Round(aCols[n,nPosPrc]*aCols[n,nPosQtd],2)
					EndIf                                         				
				EndIf			                                  
			EndIf
		EndIf
		
		aCols[n,nPosCSis] := aCols[n,nPosPrc]      
	EndIf

EndIf
			   
RestArea(_xAlias)
Return(nComis1)  

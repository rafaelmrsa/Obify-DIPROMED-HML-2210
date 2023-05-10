
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DIPG018   ºAutor  ³MAXIMO         º Data ³  13/04/09        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Corrige calculo da ST de SP nos ped. de compra efetuados a º±±
±±º          ³ fornecedores de fora do estado de SP.                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/


#Include "RwMake.ch"

User Function DIPG018(cGatilho)
Local _xAlias := GetArea()
Local _lRet   := .F.                                                                    
Local nPosProd:= aScan(aHeader,{|x| AllTrim(x[2]) == 'C7_PRODUTO'}) //MCVN - 13/04/2009
Local nPosVDes:= aScan(aHeader,{|x| AllTrim(x[2]) == 'C7_VLDESC'})  //MCVN - 13/04/2009
Local nPosTot := aScan(aHeader,{|x| AllTrim(x[2]) == 'C7_TOTAL'})   //MCVN - 13/04/2009
Local nPosIpi := aScan(aHeader,{|x| AllTrim(x[2]) == 'C7_VALIPI'})  //MCVN - 13/04/2009
Local nPosVIcm:= aScan(aHeader,{|x| AllTrim(x[2]) == 'C7_VALICM'})  //MCVN - 13/04/2009
Local nPosPIcm:= aScan(aHeader,{|x| AllTrim(x[2]) == 'C7_PICM'})    //MCVN - 13/04/2009
Local nPosVSt := aScan(aHeader,{|x| AllTrim(x[2]) == 'C7_ICMSRET'}) //MCVN - 13/04/2009
Local nPosBSt := aScan(aHeader,{|x| AllTrim(x[2]) == 'C7_BASESOL'}) //MCVN - 13/04/2009
Local nIvaAjust  := 0// MCVN - 13/04/2009
Local nPBaseReduz:= 0// MCVN - 13/04/2009
Local nBaseSolid := 0// MCVN - 13/04/2009
Local nValSolid  := 0// MCVN - 13/04/2009
   

U_DIPPROC(ProcName(0),U_DipUsr()) // MCVN 29/09/08 - Gravando o nome do Programa no SZU

If l120Auto 
	RestArea(_xArea)
	Return(_lRet)
Endif  

// Atualizando ICMS-ST SP - MCVN 13/04/09
If SA2->A2_EST <> 'SP' .AND. Posicione("SB1",1,xFilial("SB1")+aCols[n][nPosProd],"SB1->B1_PICMENT")> 0
	//Zerando Variáveis	
	nIvaAjust  := 0
	nPBaseReduz:= 0
	nBaseSolid := 0
	nValSolid  := 0                                                              

	// Incluído Recalculo do ST somente se ja existir ST 13/04/2009
	nIvaAjust  := Iif(Posicione("SB1",1,xFilial("SB1")+aCols[n][nPosProd],"SB1->B1_PICMENT")=0,0,(((1+Posicione("SB1",1,xFilial("SB1")+aCols[n][nPosProd],"SB1->B1_PICMENT")/100)*(1-aCols[n][nPosPIcm]/100)/(1-Posicione("SB1",1,xFilial("SB1")+aCols[n][nPosProd],"SB1->B1_PICM")/100))-1)*100)
	nPBaseReduz:= Posicione("SF4",1,xFilial('SF4')+SB1->B1_TE,"F4_BASEICM")
	nBaseSolid := (IIf(nPBaseReduz > 0,(aCols[n][nPosTot]-aCols[n][nPosVdes])*SF4->F4_BASEICM/100,(aCols[n][nPosTot]-aCols[n][nPosVDes])))+aCols[n][nPosIpi]
	nBaseSolid := (nBaseSolid+(nBaseSolid*nIvaAjust/100))
	nValSolid  := ((((nBaseSolid*Posicione("SB1",1,xFilial("SB1")+aCols[n][nPosProd],"SB1->B1_PICM")/100)-aCols[n][nPosVIcm])))
		
	// Atualizando valores ICMS-ST
	If cGatilho == 'ST'
		aCols[n][nPosVST] := nValSolid	            
		MAFISREF("IT_VALSOL","MT120",aCols[n][nPosVST])                                                                                     
	Else
		//aCols[n][nPosBST] := nBaseSolid
		MaFisRef("IT_BASESOL","MT120",nBaseSolid)					       
	Endif

	

	RestArea(_xAlias)
	Return(If(cGatilho == 'ST',nValSolid,nBaseSolid)) 
Endif

RestArea(_xAlias)
Return(If(cGatilho == 'ST',M->C7_ICMSRET,M->C7_BASESOL)) 

#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ DIPLotCTL     บAutor  ณRafael Rosa    บ Data ณ  28/12/22   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Valida o lote de control digitado pelo usuario.		      บฑฑ
ฑฑบ          								                              บฑฑ
ฑฑฬอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso     ณ Especifico DIPROMED                                          บฑฑ
ฑฑ         ณ ณ Funcao copiada da A103LotCTL, fonte MATA103x.              บฑฑ
ฑฑ         ณ ณ Novo programa U_DIPLotCTL configurado no campo D1_LOTECTL. บฑฑ
ฑฑ         ณ ณ Chamada pelo X3_VALID como U_DIPLotCTL().  				  บฑฑ
ฑฑ            													          บฑฑ
ฑฑ         ณ ณ Identificado o campo D1_NUMLOTE, porem nao foi modificado  บฑฑ
ฑฑ         ณ ณ por nao ser utilizado nos novos processos personalizados.  บฑฑ
ฑฑ            														      บฑฑ
ฑฑ         ณ ณ Fontes envolvidos nesta personalizacao:					  บฑฑ
ฑฑ         ณ ณ MT100LOK, MT103FIM e DIPVLD010					          บฑฑ
ฑฑ             													          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function DIPLotCTL()

Local cVar			:= ReadVar()
Local cConteudo		:= &(ReadVar())
Local cCod			:= aCols[n][aScan(aHeader,{|x|Alltrim(x[2])=="D1_COD"})]
Local nPosLote		:= aScan(aHeader,{|x|Alltrim(x[2])=="D1_NUMLOTE"})
Local nPosLotCTL	:= aScan(aHeader,{|x|Alltrim(x[2])=="D1_LOTECTL"})
Local nPosDvalid	:= aScan(aHeader,{|x|Alltrim(x[2])=="D1_DTVALID"})
Local nPosLocal		:= aScan(aHeader,{|x|AllTrim(x[2])=="D1_LOCAL"} )
Local nPosTes		:= aScan(aHeader,{|x|AllTrim(x[2])=="D1_TES"})
Local aAreaAnt		:= GetArea()
Local aAreaSB8		:= {}
Local lRet			:= .T.
Local lRotAuto      := Type("l103Auto") == "L" .And. l103Auto
Local lSublPD3Ok    := .F.
Local cLoteCtlA  	:= ''
Local cBuscaSF4		:= ""
Local cBuscaSB8		:= ""
Local nPosTipoNF 	:= aScan(aHeader,{|x|Alltrim(x[2])=="D1_TIPO_NF"})
Local lEasy		    := SuperGetMV("MV_EASY") == "S"

//รรรรรรรรรรรรรรรรรรรรรรรรรรรรรรรรรรรรรรรรรรรรรรรรรรรรรรรรรรรรรรรยฟ
//ยณ COMPATIBILIZACAO !!Verifica se e utilizado a rotina MATA100  ยณ
//ร€รรรรรรรรรรรรรรรรรรรรรรรรรรรรรรรรรรรรรรรรรรรรรรรรรรรรรรรรรรรรรรร
If Type('l100') <> 'U' .And. l100
	Return A100LotCTL()
EndIf

If !(Type('cLoteCtl')=='C')
	cLoteCtlA := CriaVar('D1_LOTECTL')
Else
	cLoteCtlA := cLoteCtl
EndIf

If (!Rastro(cCod) .And. cVar == "M->D1_NUMLOTE" .And. !Empty(cConteudo)) .Or. (!Rastro(cCod) .And. cVar == "M->D1_LOTECTL" .And. !Empty(cConteudo))
	If nPosLote > 0
		aCols[n, nPosLote]   := CriaVar("D1_NUMLOTE")
	EndIf
	aCols[n, nPosLotCTL] := CriaVar("D1_LOTECTL")
	aCols[n, nPosDValid] := CriaVar("D1_DTVALID")
	Help(" ",1,"NAORASTRO")
	lRet     := .F.
ElseIf !A103VlStr()
	lRet := .F.
ElseIf cVar == "M->D1_NUMLOTE" .And. !Empty(cConteudo)
	If cTipo == 'D' //-- NF Devolu??o
		dbSelectArea("SB8")
		aAreaSB8 := GetArea()
		dbSetOrder(2)
		If MsSeek(xFilial("SB8")+cConteudo+cLoteCtlA, .F.) .And. B8_PRODUTO+B8_Local == cCod+cLocal
			aAreaSB8[3]          := Recno()
			M->D1_LOTECTL        := SB8->B8_LOTECTL
			aCols[n, nPosLotCTL] := SB8->B8_LOTECTL
			If nPosLote > 0
				aCols[n, nPosLote]   := cConteudo
			EndIf
		Else
			M->D1_LOTECTL        := CriaVar("D1_LOTECTL")
			M->D1_DTVALID        := CriaVar("D1_DTVALID")
			If nPosLote > 0
				M->D1_NUMLOTE      := CriaVar("D1_NUMLOTE")
				aCols[n, nPosLote] := CriaVar("D1_NUMLOTE")
			EndIf
			aCols[n, nPosLotCTL] := CriaVar("D1_LOTECTL")
			aCols[n, nPosDValid] := CriaVar("D1_DTVALID")
		EndIf
		RestArea(aAreaSB8)
	Else
		// Valida sublote informado na rotina automatica de devolucao de poder de terceiros, se for valido mantem o sublote
		If lRotAuto .And. nPosTes > 0 .And. !Empty(aCols[n, nPosTes])
			cBuscaSF4 := xFilial("SF4") + aCols[n, nPosTes]
			If Posicione("SF4", 1, cBuscaSF4, "F4_PODER3") == "D"
				cBuscaSB8 := xFilial("SB8") + cConteudo + aCols[n, nPosLotCTL] + cCod + aCols[n, nPosLocal]
				If Posicione("SB8", 2, cBuscaSB8, "B8_NUMLOTE") == cConteudo
					lSublPD3Ok := .T.
				EndIf
			EndIf
		EndIf
		If !lSublPD3Ok
			M->D1_DTVALID        := CriaVar("D1_DTVALID")
			If nPosLote > 0
				M->D1_NUMLOTE        := CriaVar("D1_NUMLOTE")
				aCols[n, nPosLote]   := CriaVar("D1_NUMLOTE")
			EndIf
			aCols[n, nPosDValid] := CriaVar("D1_DTVALID")
		EndIf
	EndIf
ElseIf cVar == "M->D1_LOTECTL" .And. !Empty(cConteudo) 
	aAreaSB8 := GetArea()
	SB8->(dbSetOrder(3))
	If SB8->(dbSeek(xFilial("SB8")+cCod+aCols[n,nPosLocal]+cConteudo+IF(Rastro(cCod,"S"),aCols[n,nPosLote],"")))
		If aCols[n, nPosDValid] # SB8->B8_DTVALID 
			//Rafael Moraes Rosa - 28/12/2022 - INICIO
			//Instrucao adaptada para validacao das rotinas MATA103	e MATA140	
			IF "MATA103" <> FunName() .AND. "MATA140" <> FunName()
				If Type('lMSErroAuto') <> 'L'
					Help(" ",1,"A240DTVALI")
				EndIf	
			
				M->D1_DTVALID := SB8->B8_DTVALID
				aCols[n,nPosDvalid] := SB8->B8_DTVALID
			ENDIF
			//Instrucao adaptada para validacao das rotinas MATA103	e MATA140				
			//Rafael Moraes Rosa - 28/12/2022 - FIM

		EndIf			
	Endif		
	RestArea(aAreaSB8)
EndIf

RestArea(aAreaAnt)

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ DIPLtDtVld    บAutor  ณRafael Rosa    บ Data ณ  28/12/22   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ So permite digitar a data de validade do lote apos usuario บฑฑ
ฑฑบ    		   digitar o Lote de Controle.       	                      บฑฑ
ฑฑบ          								                              บฑฑ
ฑฑฬอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso     ณ Especifico DIPROMED                                          บฑฑ
ฑฑ         ณ ณ Funcao copiada da A103DtVld, fonte MATA103x.               บฑฑ
ฑฑ         ณ ณ Novo programa U_DIPLtDtVld configurado no campo D1_DTVALID.บฑฑ
ฑฑ         ณ ณ Chamada pelo X3_VALID como U_DIPLtDtVld(M->D1_DTVALID).    บฑฑ
ฑฑ            													          บฑฑ
ฑฑ         ณ ณ Fontes envolvidos nesta personalizacao:					  บฑฑ
ฑฑ         ณ ณ MT100LOK, MT103FIM e DIPVLD010							  บฑฑ
ฑฑ            														      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function DIPLtDtVld(dDtValid)
Local lRet		 :=.T.
Local aAreaAnt   := GetArea()
Local aAreaSB8   := SB8->(GetArea())
Local nPosCodigo := aScan(aHeader,{|x|AllTrim(x[2])=='D1_COD'})
Local nPosLocal	 := aScan(aHeader,{|x|AllTrim(x[2])=="D1_LOCAL"} )
Local nPosLote	 := aScan(aHeader,{|x|Alltrim(x[2])=="D1_NUMLOTE"})
Local nPosLotCTL := aScan(aHeader,{|x|Alltrim(x[2])=="D1_LOTECTL"})
Local nPosDvalid := aScan(aHeader,{|x|Alltrim(x[2])=="D1_DTVALID"})
Local nPosTipoNF := aScan(aHeader,{|x|Alltrim(x[2])=="D1_TIPO_NF"})
Local nPosLotFor := aScan(aHeader,{|x|Alltrim(x[2])=="D1_LOTEFOR"})
Local lEasy 	 := SuperGetMV("MV_EASY") == "S"
Local lLoteVenc	 := SuperGetMV("MV_LOTVENC") == "S"

//รรรรรรรรรรรรรรรรรรรยฟ
//ยณ POSICIONA A SB1  ยณ
//ร€รรรรรรรรรรรรรรรรรรร
DbSelectArea("SB1")
MsSeek(xFilial("SB1")+aCols[n,nPosCodigo])         

//รรรรรรรรรรรรรรรรรรรรรรรรรรรรรรรรรรรรรรรรรรรรรรรรรรรรรรรรรรรรรรรยฟ
//ยณ COMPATIBILIZACAO !!Verifica se e utilizado a rotina MATA100  ยณ
//ร€รรรรรรรรรรรรรรรรรรรรรรรรรรรรรรรรรรรรรรรรรรรรรรรรรรรรรรรรรรรรรรร
If Type('l100') <> 'U' .And. l100
	Return A100DtVld()
EndIf

If !( Type('l103Auto') <> 'U' .And. l103Auto ) .And. !Rastro(aCols[n,nPosCodigo]) .And. !Empty(aCols[n,nPosLote]) .And. !Empty(aCols[n,nPosLotCtl]) 
	Help(" ",1,"NAORASTRO")
	lRet:=.F.
EndIf

If lRet .And.  !Empty(dDtValid)
	If Empty(aCols[n,nPosLotFor]) .And. Empty(aCols[n,nPosLote]) .And. Empty(aCols[n,nPosLotCtl]) .And. !Empty(dDtValid) .And. !Rastro(aCols[n,nPosCodigo])
		M->D1_DTVALID := CTOD("  /  /  ")
		lRet:=.T.
	ElseIF lRet .And. dDtValid < dDataBase 
		//-- Verifica se permite a digitacao de datas de validade vencidas.
		If lLoteVenc 
			//-- Avisa ao usuario que a data de validade esta 
			//-- vencida, porem permite a movimentacao.
			If !(Type('l103Auto') <> 'U' .And. l103Auto)
				Help(" ",1,"LOTEVENC")
			EndIf	
		Else
			Help(" ",1,"DTVALIDINV")
			lRet:=.F.
		EndIf	
	EndIf
	
	SB8->(dbSetOrder(3))
	If lRet .And. SB8->(dbSeek(xFilial("SB8")+aCols[n,nPosCodigo]+aCols[n,nPosLocal]+aCols[n,nPosLotCTL]+IF(Rastro(aCols[n,nPosCodigo],"S"),aCols[n,nPosLote],"")))
		If dDtValid # SB8->B8_DTVALID
			
			//Rafael Moraes Rosa - 28/12/2022 - INICIO
			//Instrucao adaptada para validacao das rotinas MATA103	e MATA140
			IF  "MATA103" <> FunName() .AND. "MATA140" <> FunName()
					If !( Type('l103Auto') <> 'U' .And. l103Auto )
						Help(" ",1,"A240DTVALI")
					EndIf	
					M->D1_DTVALID := SB8->B8_DTVALID               
					aCols[n,nPosDvalid] := SB8->B8_DTVALID
			ENDIF
			//Instrucao adaptada para validacao das rotinas MATA103	e MATA140			
			//Rafael Moraes Rosa - 28/12/2022 - FIM

		EndIf		
	Endif		
Endif
	
RestArea(aAreaSB8)
RestArea(aAreaAnt)                      

Return lRet

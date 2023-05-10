#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"      

Static cDipAtend := ''
Static cDipClien := ''
Static cDipSubAt := .f.      

/*====================================================================================\
|Programa  | DIPA025       | Autor | Eriberto Elias             | Data | 21/07/2004   |
|=====================================================================================|
|Descri็ใo | Calcula o valor da substituicao tributaria                               |
|=====================================================================================|
|Sintaxe   | DIPA025(SA1->A1_EST) ou DIPA025(SA1->A1_EST)                             |
|=====================================================================================|
|Uso       | Especifico DIPROMED                                                      |
|=====================================================================================|
|........................................Hist๓rico....................................|
|RAFAEL    | 13/12/04 - altera็ใoo feita para identificar qual das duas aliquotas     |
|          | serใo usadas no caso do estado do Rio de Janeiro                         |
+----------+--------------------------------------------------------------------------+
|ERIBERTO  | 17/01/05 - Nใo vai calcular mais para o estado PR conforme decreto n.1942|
|          | Antes estava com indice 0.11175                                          |
+----------+--------------------------------------------------------------------------+
|RAFAEL    | 18/01/05 - Adicionado IF para evitar pergunta quando valor da ST for     |
|          |            igual a 0                                                     |
+----------+--------------------------------------------------------------------------+
|MAXIMO    | 03/07/08 - Alterado para calcular St baseado na Classifica็ใo Fiscal     |
|          |            do produto.                                                   |
+----------+--------------------------------------------------------------------------+
|          |   /  /   -                                                               |
|          |                                                                          |
\====================================================================================*/
User Function DIPA025(_cQEst,_aPesoItem)
Local _xAlias   := GetArea()          
Local _xAliasB1 := SB1->(GetArea())
Local _xAliasX6 := SX6->(GetArea())
Local _cFilSB1  := xFilial("SB1")
Local _cAliasCab:= Iif("TMK"$FunName(),'UA','C5')
Local _cAliasIte:= Iif("TMK"$FunName(),'UB','C6')
Local _nDespesa := &(Iif("TMK"$FunName(),'aVALORES[5]','M->C5_DESPESA'))-Iif(AT('=ST=D',&('M->'+_cAliasCab+'_MENNOTA'))==0,0,Val(Subs(&('M->'+_cAliasCab+'_MENNOTA'),1,AT('=ST=D',&('M->'+_cAliasCab+'_MENNOTA'))-1)))
Local _nSTmens  := Iif(AT('=ST=D',&('M->'+_cAliasCab+'_MENNOTA'))==0,0,Val(Subs(&('M->'+_cAliasCab+'_MENNOTA'),1,AT('=ST=D',&('M->'+_cAliasCab+'_MENNOTA'))-1)))
Local _nST      := 0
Local _nValST   := 0
Local _nIndiceA := _nIndiceB := 0        
local _cNcmSB1  := ""              
Local _cNcmStEst:= ""  
Local _cExcecao := ""
Local _nSubs	:= 0
Local _nValICMS := 0
Local _nBaseST	:= 0
Local _nItemST	:= 0
Local _aRet 	:= {}
Local _nPos		:= 0
Local _nValCalc := 0
Local _nPICM	:= 0
Local _cAliqICM := GetNewPar("MV_ESTICM","")
Local _nAliqInt := 0
Local _cLogST	:= "Produto;NCM;Vlr_Prod;Peso;Vlr_Frete;Vlr_Tot;UF;Aliq_Int;Origem;Iva Ori;Iva Ajus;% ICMS;Vlr_ICMS;Vlr_ST;Vlr_ST - Vlr_ICMS"+CHR(10)+CHR(13)        
Local _nPosPro  := 0                                                    
Local _cPedVen 	:= &('M->'+_cAliasCab+'_NUM')
Local _nPosIte  := 0  
Local _nPosQtd  := 0
Local _nQtdVen	:= 0 
Local _nPesoIte := 0                                                  
Local _nPosTes	:= 0
Local _nPosCfo  := 0
Local _aItemST  := {}
Local _nVlrTot  := u_DipRetVlP(&('M->'+_cAliasCab+'_NUM'))
Local _nPerRed  := 0      
Local _lDipAmo  := .F.
Local _nTtoPed 	:= 0
Local _ee		:= 1
U_DIPPROC(ProcName(0),U_DipUsr()) // Gravando o nome do Programa no SZU

//Nใo passar mais para HQ
If AllTrim(FWCodEmp())=="04"
	Return
EndIf
DbSelectArea("SA1")
DbSetOrder(1)
DbSeek(xFilial("SA1")+M->C5_CLIENTE+M->C5_LOJACLI)
nItem := 1
_nTtoPed:=CALCPED(M->C5_NUM)
IniImp() 				//INICIO DAS INFORMACOES PARA CALCULO DOS IMPOSTOS
SB1->(DbSetOrder(1))
For _ee := 1 TO Len(aCols)                          
	_nItemST := 0
    _aRet 	 := {}
    _nPosTes := aScan(aHeader, { |x| Alltrim(x[2]) == _cAliasIte+'_TES'})
    _nPosCfo := aScan(aHeader, { |x| Alltrim(x[2]) == _cAliasIte+'_CF'})
	_nPosPro := aScan(aHeader, { |x| Alltrim(x[2]) == _cAliasIte+'_PRODUTO'})
	_nPosIte := aScan(aHeader, { |x| Alltrim(x[2]) == _cAliasIte+'_ITEM'})
	_nPosQtd := aScan(aHeader, { |x| Alltrim(x[2]) == Iif("TMK"$FunName(),'UB_QUANT','C6_QTDVEN')})
	_nPosVal := aScan(aHeader, { |x| Alltrim(x[2]) == Iif("TMK"$FunName(),'UB_VLRITEM','C6_VALOR')})
	_nPosPrc := aScan(aHeader, { |x| Alltrim(x[2]) == Iif("TMK"$FunName(),'UB_VLRITEM','C6_PRCVEN')})
	If cEmpAnt =="04" .And. _nPosCfo>0 .And. SubStr(aCols[_ee,_nPosCfo],2,3)$"911/912"
		_lDipAmo := .T.
	EndIf

	If !GdDeleted(_ee) .And. _nPosIte>0 .And. _nPosPro>0 .And. _nPosQtd>0 .And. !_lDipAmo
	
		nVal_Fre := &('M->'+_cAliasCab+'_FRETE')

		If nVal_Fre >0
			_nValItem := aCols[_ee,_nPosVal] + Round((aCols[_ee,_nPosQtd] * aCols[_ee,_nPosPrc] * nVal_Fre)/_nTtoPed,2)
		Else
			_nValItem := aCols[_ee,_nPosVal]
		EndIf
		ADDImp(_nValItem, aCols[_ee,_nPosQtd], aCols[_ee,_nPosPrc], M->C6_CLI, M->C6_LOJA, aCols[_ee,_nPosPro], aCols[_ee,_nPosTes])//Adicao os Itens para Imposto
		_nItemST := MaFisRet(nItem,"IT_VALSOL")//+MaFisRet(nItem,"IT_VFECPST")
		_nST += MaFisRet(nItem,"IT_VALSOL")//+MaFisRet(nItem,"IT_VFECPST")
		
		If _nItemST > 0
			aAdd(_aItemST, aCols[_ee,_nPosIte])
		EndIf
		/*            
		If _nPosTes > 0 
			SF4->(dbSetOrder(1))
			If SF4->(dbSeek(xFilial("SF4")+AllTrim(aCols[_ee,_nPosTes])))
				If SF4->F4_ESTOQUE == "S" .And. SC5->C5_TIPODIP = "1"
					_aRet := U_DipVldItem(_cPedVen,aCols[_ee,_nPosIte])
				Else                                                   
					_aRet := {.T.,aCols[_ee,_nPosQtd]}
				EndIf  
				
				If SF4->F4_BSICMST>0
					_nPerRed := (100-SF4->F4_BSICMST)/100
				EndIf						
			Else      
				Aviso("Aten็ใo","Erro no calculo do ST. TES Nใo encontrada.",{"Ok"},1)
				Return
			EndIf
		EndIf
				
		If _aRet[1]		   
			_nQtdVen := _aRet[2]
			_aRet := {}
		
			If SB1->(DbSeek(_cFilSB1+aCols[_ee,_nPosPro]))
			    
				If M->C5_CLIENTE$GetNewPar("ES_STESPBA","010154") .And. Left(SB1->B1_POSIPI,4)<>"3005"
					Loop
				EndIf

				// Calculando ST
				_aRet := U_VldNCM(AllTrim(SB1->B1_POSIPI),_cQest)
				
				If !(AllTrim(SB1->B1_COD)$GetNewPar("ES_DIPNCST","")) .And.;
					_aRet[1] .And.;
					IIf(Left(AllTrim(SB1->B1_POSIPI),8) = "39269090" .And. !"DIU" $ SB1->B1_DESC,.F.,.T.) .And.;
					SB1->B1_PICM>0
												
					If "ALGODAO"$SB1->B1_DESC .And. Left(SB1->B1_POSIPI,4)=="3005"
						If _cQest=="MG"
							_aRet[2] := 0.45
						ElseIf _cQest=="RJ"
							//_aRet[2] := 0.2882  Regra retirada em 30/08/2016 (e-mail da Sirlene)
						EndIf
					EndIf
					
					If "ABSORVENTE"$SB1->B1_DESC .And. Left(SB1->B1_POSIPI,4)=="9619"
						If _cQest=="SC"
							_aRet[2] := 0.6537
						 ElseIf _cQest=="RJ"
						 	_aRet[2] := 0.5222
						 EndIf
					EndIf
					
					If _cQest=="RJ" .And. "FRALDA"$SB1->B1_DESC .And. Left(SB1->B1_POSIPI,4)=="9619"
						_aRet[2] := 0.3130
					EndIf
					
					aAdd(_aItemST, aCols[_ee,_nPosIte])
												
					_cLogST += AllTrim(SB1->B1_COD)+";"
					
					_cLogST += AllTrim(SB1->B1_POSIPI)+";"
					
					_nPos := aScan(aHeader, { |x| Alltrim(x[2]) == Iif("TMK"$FunName(),'UB_VLRITEM','C6_VALOR')})
					
					If _nPos > 0
						If _nQtdVen < aCols[_ee,_nPosQtd]
							_nValcalc := Round((_nQtdVen*aCols[_ee,_nPos])/aCols[_ee,_nPosQtd],2)
						Else		         
							_nValCalc := aCols[_ee,_nPos]
						EndIf
					Else
						_nValCalc := 0
					EndIf
					
					_cLogST += AllTrim(Str(_nValCalc))+";"

					_cLogST += AllTrim(Str(_nVlrTot))+";"
										
					_nValFrete := (_nValCalc*&('M->'+_cAliasCab+'_FRETE'))/_nVlrTot
					
					_cLogST += AllTrim(Str(_nValFrete))+";"
					
					_nValCalc +=_nValFrete
					
					_cLogST += AllTrim(Str(_nValCalc))+";"
					
					_nAliqInt := Val(Subs(_cAliqICM,AT(_cQest,_cAliqICM)+2,2))
					
					_nAliqInt := u_DipAvaFCP(_cQest,_nAliqInt) 
					
					_cLogST += AllTrim(_cQest)+";"
					
					_cLogST += AllTrim(Str(_nAliqInt))+";"
					
					_cLogST += AllTrim(SB1->B1_ORIGEM)+";"
					
					If _cQest == "MT"
						If SB1->B1_ORIGEM $ "1/2/3/6/7/8"
							_nPICM := 4
						Else	
							_nPICM := 7
						EndIf
						_nBaseST  	:= _nValCalc
						_nValICMS := Round((_nValCalc*_nPICM)/100,2)
						_nBaseST 	+= Round(_nValCalc*(GetNewPar("ES_DIPSTMT",15)/100),2)
						_nValST   	:= Round(_nBaseST*(_nAliqInt/100),2)
						_nST   	  	+= _nValST - _nValICMS
					ElseIf _cQest=="AL" .And. M->C5_CLIENTE$GetNewPar("ES_CLIALAG","001752") .And.; 
							(Left(SB1->B1_POSIPI,4)=="3005" .Or. Left(SB1->B1_POSIPI,6)=="901831" .Or. Left(SB1->B1_POSIPI,7)=="9018321")
						_nST += Round(_nValCalc*GetNewPar("ES_PERALAG",0.06),2)
					Else
						//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
						//ณ Percentual informado, conforme regra passada pela Sirlene:        ณ
						//ณ                                                                   ณ
						//ณ12% e somente para RJ, MG, PR, RS e SC. Os demais Estados vai a 7% ณ
						//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
						If SB1->B1_ORIGEM $ "1/2/3/6/7/8"
							_nPICM := 4
						ElseIf _cQest  $ "RJ/MG/PR/RS/SC"
							_nPICM := 12
						Else
							_nPICM := 7
						EndIf
						
						_nValICMS := Round((_nValCalc*_nPICM)/100,2)
						
						_nBaseST  := _nValCalc*U_CalcIVA(_aRet[2],_nPICM,_nAliqInt)
						
						If _nPerRed>0
							_nBaseST := _nBaseST-_nBaseST*_nPerRed
						EndIf
						
						_nValST   := Round(_nBaseST*(_nAliqInt/100),2)
						
						_nST      += _nValST - _nValICMS
					EndIf
					 
					_cLogST += AllTrim(Str(_aRet[2]))+";"
					_cLogST += AllTrim(Str(U_CalcIVA(_aRet[2],_nPICM,_nAliqInt)))+";"
					_cLogST += AllTrim(Str(_nPICM))+";"
					_cLogST += AllTrim(Str(_nValICMS))+";"
					_cLogST += AllTrim(Str(_nValST))+";"
					_cLogST += AllTrim(Str(_nValST-_nValICMS))+";"
					_cLogST += CHR(10)+CHR(13)
					
				Endif
			EndIf
		EndIf
		*/	
		nItem++
	EndIf
Next
EndImp()//Encerra Impostos
/*       
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ    Grava arquivo .csv com os detalhes do cแlculo ST     ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If _nST > 0 .And. Alltrim(Upper(U_DipUsr()))$Upper(GetNewPar("ES_CARQST","DDOMINGOS/MCANUTO/VQUEIROZ/VEGON/RBORGES"))
	_cLogST := StrTran(_cLogST,".",",")
	GrvArqDip(_cLogST,&('M->'+_cAliasCab+'_NUM')) 
EndIf
*/
If _nST != 0
	cDipClien := Iif("TMK"$FunName(),M->UA_CLIENTE,Alltrim(M->C5_CLIENTE))
	//**** ALTERADO TIAGO STOCCO - OBIFY - 14/06/2021	
	//	If _cQest == "MG"  .Or. (cDipClien $ GetNewPar("ES_AUTOST","014651"))
	If _cQest == "RJ" .and. cDipClien $ GetNewPar("ES_AUTOST","001991")
		cDipSubAt := MsgBox("Valor: "+Transform(_nST,"@E 999,999.99")+Chr(13)+Chr(13)+"Inclui no pedido?","SUBSTITUICAO TRIBUTARIA","YESNO")
	Else
		MsgBox("A ST no Valor: "+Transform(_nST,"@E 999,999.99")+ " Foi incluํda automaticamente!","SUBSTITUICAO TRIBUTARIA","OK")	
		cDipSubAt := .T.
	EndIf
	cDipAtend := Iif("TMK"$FunName(),M->UA_NUM,M->C5_NUM)
EndIf

_nSubs := AT('=ST=',&('M->'+_cAliasCab+'_MENNOTA'))  

If "TMK"$FunName()
	If cDipSubAt    
		_nSubs += IiF(_nSubs==0,1,6)	   		
		aVALORES[5] := _nST + _nDespesa
		SUA->(RecLock("SUA",.F.))
			SUA->UA_MENNOTA := AllTrim(Str(_nST,12,2))+'=ST=D '+SubStr(SUA->UA_MENNOTA,_nSubs,120-_nSubs)
		SUA->(MsUnlock())
	ElseIf _nST != 0     
		_nSubs += IiF(_nSubs==0,1,5)   		
		aVALORES[5] := _nDespesa
		SUA->(RecLock("SUA",.F.))
			SUA->UA_MENNOTA := AllTrim(Str(_nST,12,2))+'=ST= '+SubStr(SUA->UA_MENNOTA,_nSubs,120-_nSubs)
		SUA->(MsUnlock())
	Else                                                                                                                           
		_nSubs += IiF(_nSubs==0,1,5)  
		aVALORES[5] := _nDespesa
		SUA->(RecLock("SUA",.F.))
			SUA->UA_MENNOTA := Alltrim(SubStr(SUA->UA_MENNOTA,_nSubs,120-_nSubs))
			SUA->UA_MENNOTA := Alltrim(SUA->UA_MENNOTA) + space(AvSx3("UA_MENNOTA",3) - len(Alltrim(SUA->UA_MENNOTA)))
		SUA->(MsUnlock())
	EndIf	
Else
	If cDipSubAt    
		_nSubs += IiF(_nSubs==0,1,6)	   
		SC5->(RecLock("SC5",.F.))
			//SC5->C5_DESPESA := IIf(_nDespesa > 0, _nDespesa, 0)
			SC5->C5_MENNOTA := AllTrim(Str(_nST,12,2))+'=ST=D '+ SubStr(SC5->C5_MENNOTA,_nSubs,120-_nSubs)
		SC5->(MsUnlock())  
		SC6->(dbSetOrder(1))
		If SC6->(dbSeek(xFilial("SC6")+SC5->C5_NUM))
			While !SC6->(Eof()) .And. SC6->(C6_FILIAL+C6_NUM) == xFilial("SC6")+SC5->C5_NUM
				If aScan(_aItemST, {|x| x == SC6->C6_ITEM }) > 0
					SC6->(RecLock("SC6"),.F.)                   
						If cEmpAnt=="01"
							If SC6->C6_TES == "501"
								SC6->C6_TES := "801" 
								SC6->C6_CF	:= "6403"					
								SC6->C6_CLASFIS := Left(SC6->C6_CLASFIS,1)+POSICIONE("SF4",1,xFilial("SF4")+"801","F4_SITTRIB")
							ElseIf SC6->C6_TES == "505"
								SC6->C6_TES := "802"
								SC6->C6_CF  := "6403" 
								SC6->C6_CLASFIS := Left(SC6->C6_CLASFIS,1)+POSICIONE("SF4",1,xFilial("SF4")+"802","F4_SITTRIB")
							ElseIf SC6->C6_TES == "703"
								SC6->C6_TES := "805" 
								SC6->C6_CF	:= "6403"					
								SC6->C6_CLASFIS := Left(SC6->C6_CLASFIS,1)+POSICIONE("SF4",1,xFilial("SF4")+"805","F4_SITTRIB")
							EndIf
						ElseIf cEmpAnt=="04"
							If SC6->C6_TES == "503"
								SC6->C6_TES := "654" 
								SC6->C6_CF	:= "6401"					
								SC6->C6_CLASFIS := Left(SC6->C6_CLASFIS,1)+POSICIONE("SF4",1,xFilial("SF4")+"654","F4_SITTRIB")
							ElseIf SC6->C6_TES == "703"
								SC6->C6_TES := "854" 
								SC6->C6_CF	:= "6401"					
								SC6->C6_CLASFIS := Left(SC6->C6_CLASFIS,1)+POSICIONE("SF4",1,xFilial("SF4")+"854","F4_SITTRIB")
							EndIf
						EndIf	
					SC6->(MsUnlock())
				EndIf
				SC6->(dbSkip())
			EndDo
		EndIf
	ElseIf _nST != 0     
		_nSubs += IIf(_nSubs==0,1,5)   		
		SC5->(RecLock("SC5",.F.))
			//SC5->C5_DESPESA := _nDespesa
			SC5->C5_MENNOTA := AllTrim(Str(_nST,12,2))+'=ST= '+SubStr(SC5->C5_MENNOTA,_nSubs,120-_nSubs)
		SC5->(MsUnlock())			
		
		SC6->(dbSetOrder(1))
		If SC6->(dbSeek(xFilial("SC6")+SC5->C5_NUM))
			While !SC6->(Eof()) .And. SC6->(C6_FILIAL+C6_NUM) == xFilial("SC6")+SC5->C5_NUM
				If aScan(_aItemST, {|x| x == SC6->C6_ITEM }) > 0
					SC6->(RecLock("SC6"),.F.)   
						If cEmpAnt == "01"
							If SC6->C6_TES == "801"
								SC6->C6_TES := "501" 
								SC6->C6_CF	:= "6102"	  
								SC6->C6_CLASFIS := Left(SC6->C6_CLASFIS,1)+POSICIONE("SF4",1,xFilial("SF4")+"501","F4_SITTRIB")				
							ElseIf SC6->C6_TES == "802"
								SC6->C6_TES := "505"
								SC6->C6_CF  := "6102"                                                                          
								SC6->C6_CLASFIS := Left(SC6->C6_CLASFIS,1)+POSICIONE("SF4",1,xFilial("SF4")+"505","F4_SITTRIB")
							ElseIf SC6->C6_TES == "805"
								SC6->C6_TES := "703"
								SC6->C6_CF  := "6102"                                                                          
								SC6->C6_CLASFIS := Left(SC6->C6_CLASFIS,1)+POSICIONE("SF4",1,xFilial("SF4")+"703","F4_SITTRIB")							
							EndIf
						ElseIf cEmpAnt == "04"
							If SC6->C6_TES == "654"
								SC6->C6_TES := "503"
								SC6->C6_CF  := "6101"                                                                          
								SC6->C6_CLASFIS := Left(SC6->C6_CLASFIS,1)+POSICIONE("SF4",1,xFilial("SF4")+"503","F4_SITTRIB")
							ElseIf SC6->C6_TES == "854"
								SC6->C6_TES := "703"
								SC6->C6_CF  := "6101"                                                                          
								SC6->C6_CLASFIS := Left(SC6->C6_CLASFIS,1)+POSICIONE("SF4",1,xFilial("SF4")+"703","F4_SITTRIB")																
							EndIf
						EndIf
					SC6->(MsUnlock())
				EndIf
				SC6->(dbSkip())
			EndDo
		EndIf
	Else                                                                                                                           
		_nSubs += IiF(_nSubs==0,1,5)  
		
		SC5->(RecLock("SC5",.F.))
			//SC5->C5_DESPESA := _nDespesa
			SC5->C5_MENNOTA := Alltrim(SubStr(SC5->C5_MENNOTA,_nSubs,120-_nSubs))
			SC5->C5_MENNOTA := Alltrim(SC5->C5_MENNOTA) + space(AvSx3("C5_MENNOTA",3) - len(Alltrim(SC5->C5_MENNOTA)))
		SC5->(MsUnlock())	
		
		SC6->(dbSetOrder(1))
		If SC6->(dbSeek(xFilial("SC6")+SC5->C5_NUM))
			While !SC6->(Eof()) .And. SC6->(C6_FILIAL+C6_NUM) == xFilial("SC6")+SC5->C5_NUM
				If aScan(_aItemST, {|x| x == SC6->C6_ITEM }) > 0
					SC6->(RecLock("SC6"),.F.)
						If SC6->C6_TES == "801"
							SC6->C6_TES := "501" 
							SC6->C6_CF	:= "6102"  
							SC6->C6_CLASFIS := Left(SC6->C6_CLASFIS,1)+POSICIONE("SF4",1,xFilial("SF4")+"501","F4_SITTRIB")												
						ElseIf SC6->C6_TES == "802"
							SC6->C6_TES := "505"
							SC6->C6_CF  := "6102"
							SC6->C6_CLASFIS := Left(SC6->C6_CLASFIS,1)+POSICIONE("SF4",1,xFilial("SF4")+"505","F4_SITTRIB")
						ElseIf SC6->C6_TES == "805"
							SC6->C6_TES := "703"
							SC6->C6_CF  := "6102"                                                                          
							SC6->C6_CLASFIS := Left(SC6->C6_CLASFIS,1)+POSICIONE("SF4",1,xFilial("SF4")+"703","F4_SITTRIB")							
						EndIf
					SC6->(MsUnlock())
				Endif
				SC6->(dbSkip())
			EndDo
		EndIf
	EndIf                   
EndIf
	
RestArea(_xAliasB1)
RestArea(_xAliasX6)
RestArea(_xAlias)

Return                                                     
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ  VldNCM  บAutor  ณMicrosiga           บ Data ณ  02/26/13   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function VldNCM(cCodNCM,cEst) 
Local lRet 		:= .F.   
Local aRet		:= {.F.}                  
Local cExcec    := GetNewPar("MV_STEXCEC","")
DEFAULT cCodNCM := ""
DEFAULT cEst    := ""

If Len(cCodNCM) > 1
	SZQ->(dbSetOrder(1))
	SZQ->(dbSeek(xFilial("SZQ")+cEst+cCodNCM))
		
	lRet := (AllTrim(SZQ->ZQ_POSIPI)==AllTrim(cCodNCM))

	aRet := {lRet,(SZQ->ZQ_IVA/100)}
	
	If cEst+cCodNCM $ cExcec
		aRet := {.F.,0}	
	ElseIf !lRet   
		If Left(cCodNCM,1) == "G"                               
			cCodNCM := Left(Alltrim(cCodNCM),Len(cCodNCM)-1)
		Else
			cCodNCM := "G"+Left(Alltrim(cCodNCM),Len(cCodNCM)-1)
		EndIf
		
		aRet := U_VldNCM(cCodNCM,cEst) //Chamada recursiva para procurar os grupos de NCM 	
	EndIf
	
EndIf
	
Return aRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDIPA025   บAutor  ณMicrosiga           บ Data ณ  02/26/13   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function CalcIVA(nIva,nICM,nAIn)
Local nIvaAju := 0
DEFAULT nIva  := 0
DEFAULT nICM  := 0  
DEFAULT nAIn  := 0

nIvaAju :=  (1+nIva)*(1-nICM/100)/(1-nAIn/100)-1

Return(nIvaAju+1)     
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDIPA025   บAutor  ณMicrosiga           บ Data ณ  03/04/13   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function GrvArqDip(cLog,cPedido)
Local nH 	  := 0    
Local cDir	  := "C:\Arquivos_ST"
Local cNomArq := cDir+"\"+cPedido+".csv"

If !ExistDir(cDir)
	If Makedir(cDir) <> 0
		Return
	Endif
Endif

If File(cNomArq)
	FErase(cNomArq)
EndIf

If !File(cNomArq)
	nH := MSFCreate(Upper(cNomArq),0)
Endif 

If nH > 0
	FWrite(nH,cLog)
	FClose(nH)
EndIf

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDIPA025   บAutor  ณMicrosiga           บ Data ณ  03/15/13   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function DipVldItem(cPedido,cItem,cSequen)
Local aArea := GetArea()
Local lRet  := .F.	
Local cSQL  := ""
Local nQtd  := 0   
DEFAULT cPedido := ""
DEFAULT cItem   := ""
DEFAULT cSequen := ""

cSQL := " SELECT SUM(C9_QTDORI) QTD "
cSQL += " FROM "+RetSQLName("SC9")
cSQL += " WHERE C9_FILIAL = '"+xFilial("SC9")+"' AND "
cSQL += " C9_PEDIDO = '"+cPedido+"' AND "
cSQL += " C9_ITEM = '"+cItem+"' AND "
If !Empty(cSequen)
	cSQL += " C9_SEQUEN = '"+cSequen+"' AND "
EndIf
cSQL += " C9_NFISCAL = ' ' AND "     
cSQL += " C9_QTDORI > 0 AND "
cSQL += " D_E_L_E_T_ = ' ' "

cSQL := ChangeQuery(cSQL)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),"QRYSC9",.T.,.T.)

TCSETFIELD("QRYSC9","QTD","N",17,2)

If !QRYSC9->(Eof()) .And. QRYSC9->QTD > 0  
	nQtd := QRYSC9->QTD
	lRet := .T.
EndIf

QRYSC9->(dbCloseArea())

RestArea(aArea)
	
Return {lRet,nQtd}
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDIPA025   บAutor  ณMicrosiga           บ Data ณ  03/15/13   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function DipRetVlP(cPedido,cNumDoc)
Local aArea 	:= GetArea()              
Local aAreaSC9 	:= SC9->(GetArea())
Local cSQL  	:= ""
Local nVlr  	:= 0   
Local nPosVlr  	:= 0
Local nI		:= 0
DEFAULT cPedido := ""                  
DEFAULT cNumDoc := ""

SC9->(dbSetOrder(1))
If SC9->(dbSeek(xFilial("SC9")+cPedido))
	cSQL := " SELECT SUM(C9_PRCVEN*C9_QTDORI) VLR "
	cSQL += " FROM "+RetSQLName("SC9")
	cSQL += " WHERE C9_FILIAL = '"+xFilial("SC9")+"' AND "
	cSQL += " C9_PEDIDO = '"+cPedido+"' AND "
	cSQL += " (C9_NFISCAL = ' ' OR C9_NFISCAL = '"+cNumDoc+"') AND "     
	cSQL += " C9_QTDORI > 0 AND "
	cSQL += " D_E_L_E_T_ = ' ' "	
	
	cSQL := ChangeQuery(cSQL)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),"QRYVLR",.T.,.T.)
	
	If !QRYVLR->(Eof()) .And. QRYVLR->VLR > 0  
		nVlr := QRYVLR->VLR
	EndIf
	QRYVLR->(dbCloseArea())
Else                
	nPosVlr := aScan(aHeader, { |x| Alltrim(x[2]) == "C6_VALOR" })
	For nI:=1 to Len(aCols)                                              
		If !aCols[nI,Len(aHeader)+1]
			nVlr+=aCols[nI,nPosVlr]
		EndIf
	Next nI
EndIf           

RestArea(aAreaSC9)
RestArea(aArea)

Return nVlr
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDIPA025   บAutor  ณMicrosiga           บ Data ณ  05/04/16   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function DipAvaFCP(_cQest,_nVlrRet)
Local cSQL 		:= ""
DEFAULT _cQest 	:= ""
DEFAULT _nVlrRet:= 0

cSQL := " SELECT "
cSQL += " 	CFC_ALQFCP "
cSQL += " 	FROM "
cSQL += 		RetSQLName("CFC")
cSQL += " 		WHERE "
cSQL += " 			CFC_FILIAL = '"+xFilial("CFC")+"' AND "
cSQL += " 			CFC_UFDEST = '"+_cQest+"' AND "
cSQL += " 			CFC_ALQFCP > 0 AND "
cSQL += " 			D_E_L_E_T_ = ' ' "

cSQL := ChangeQuery(cSQL)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),"QRYCFC",.T.,.T.)

TCSETFIELD("QRYCFC","CFC_ALQFCP","N",7,4)  

If !QRYCFC->(Eof())
	_nVlrRet += QRYCFC->CFC_ALQFCP
EndIf
QRYCFC->(dbCloseArea())

Return _nVlrRet

/*
|-----------------------------------------------------------------------------------|
|  Programa : IniImp                                       Data : 07/06/2021        |
|-----------------------------------------------------------------------------------|
|  Cliente  : DIPROMED                                        						|
|-----------------------------------------------------------------------------------|
|  Uso      : Rotina de calculo dos impostos atrav้s da MATXFIS 		            |
|-----------------------------------------------------------------------------------|
*/
Static Function IniImp()
Local aArea		:= GetArea()
Local aAreaSA1	:= SA1->(GetArea())
Local nPrcLista := 0
Local nValMerc  := 0
Local nDesconto := 0
Local nQtdPeso  := 0
Local nPosEntr  := 0
Local cProduto  := ""
Local nTotDesc  := 0
Local lSaldo    := .F.
Local nQtdEnt   := 0
Local aSolid	:= {}
Local nLancAp	:=	0
Local aTransp	:= {"",""}
Local aSaldos	:= {}
Local nValRetImp:= 0
Local cImpRet 	:= ""
Local cCliAux   := ""
Local cLjAux    := ""
Local cProsp    := ""
Local nTotal	:= 0
Private oLogApICMS
Private _nTotOper_ := 0		//total de operacoes (vendas) realizadas com um cliente - calculo de IB - Argentina
Private _aValItem_ := {}
Private cTpCli	   := SA1->A1_TIPO
MaFisSave()
MaFisEnd()
MaFisIni(SA1->A1_COD,SA1->A1_LOJA,"C","N",cTpCli,Nil,Nil,Nil,Nil,"MATA461",Nil,Nil,cProsp,Nil,Nil,Nil,Nil,aTransp)
/*
MaFisIni(SA1->A1_COD,;	// 1-Codigo Cliente/Fornecedor
		 SA1->A1_LOJA,;	// 2-Loja do Cliente/Fornecedor
		"C",;			// 3-C:Cliente , F:Fornecedor
		"N",;			// 4-Tipo da NF
		cTpCli,;		// 5-Tipo do Cliente/Fornecedor
		Nil,;
		Nil,;
		Nil,;
		Nil,;
		"MATA461",;
		Nil,;
		Nil,;
		Nil,;
		Nil,;
		Nil,;
		Nil,;
		Nil,;
		aTransp,;
		Nil,;
		Nil,;
		Nil,;
		Nil,;
		Nil,;
		nTotal,;
		Nil,;
		_cTipFre)
*/
Return

/*
|-----------------------------------------------------------------------------------|
|  Programa : ADDImp                                       Data : 07/06/2021        |
|-----------------------------------------------------------------------------------|
|  Cliente  : DIPROMED                                         						|
|-----------------------------------------------------------------------------------|
|  Uso      : Rotina de calculo dos impostos atrav้s da MATXFIS 		            |
|-----------------------------------------------------------------------------------|
*/
Static Function ADDImp(_nVALOR, _nQTDVEN, _nPRCVEN, _cCLIENT, _cLOJA, _cPRODUT, _cTES)
Local nRecOri   := 0
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณAgrega os itens para a funcao fiscal         ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
nQtdPeso := 0

cProduto := _cPRODUT
SB1->(dbSetOrder(1))
If SB1->(MsSeek(xFilial("SB1")+cProduto))
	nQtdPeso := SB1->B1_PESO
EndIf

SB2->(dbSetOrder(1))
SB2->(MsSeek(xFilial("SB2")+SB1->B1_COD+SB1->B1_LOCPAD))

SF4->(dbSetOrder(1))
SF4->(MsSeek(xFilial("SF4")+_cTES))

cNfOri     := Nil
cSeriOri   := Nil
nRecnoSD1  := Nil
nDesconto  := 0
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณCalcula o preco de lista                     ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

nValMerc  := _nVALOR
nPrcLista := _nPRCVEN
nQtd  	  := _nQTDVEN

If (nPrcLista == 0)
	nPrcLista := NoRound(nValMerc/nQtd,TamSX3("C6_PRCVEN")[2])
EndIf

nAcresFin := 0 //A410Arred(SCK->CK_PRCVEN*SCJ->CJ_ACRSFIN/100,"D2_PRCVEN")
nValMerc  += A410Arred(nQtd*nAcresFin,"D2_TOTAL")		
nDesconto := a410Arred(nPrcLista*nQtd,"D2_DESCON")-nValMerc
nDesconto := Max(0,nDesconto)
nPrcLista += nAcresFin
nValMerc  += nDesconto

//nPrcLista := SC6->C6_PRCVEN
//nValMerc  := SC6->C6_PRCVEN*SC6->C6_QTDVEN

dDataCnd  := dDatabase

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณAgrega os itens para a funcao fiscal         ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
MaFisAdd(cProduto,;	      // 1-Codigo do Produto ( Obrigatorio )
		 _cTES,; 		 // 2-Codigo do TES ( Opcional )
		 nQtd,;  		 // 3-Quantidade ( Obrigatorio )
		 nPrcLista,;     // 4-Preco Unitario ( Obrigatorio )
		 nDesconto,;     // 5-Valor do Desconto ( Opcional )
		 cNfOri,;        // 6-Numero da NF Original ( Devolucao/Benef )
		 cSeriOri,;      // 7-Serie da NF Original ( Devolucao/Benef )
		 nRecOri,;        // 8-RecNo da NF Original no arq SD1/SD2
		 0,;              // 9-Valor do Frete do Item ( Opcional )
		 0,;              // 10-Valor da Despesa do item ( Opcional )
		 0,;              // 11-Valor do Seguro do item ( Opcional )
		 0,;              // 12-Valor do Frete Autonomo ( Opcional )
		 nValMerc,;       // 13-Valor da Mercadoria ( Obrigatorio )
		 0,;              // 14-Valor da Embalagem ( Opiconal )
		 ,;               // 15
		 ,;               // 16
		 "",;             // 17
		 0,;              // 18-Despesas nao tributadas - Portugal
		 0,;              // 19-Tara - Portugal
		 SF4->F4_CF)      // 20-CFO

MaFisWrite(1)
Return

/*
|-----------------------------------------------------------------------------------|
|  Programa : EndImp                                       Data : 18/08/2020        |
|-----------------------------------------------------------------------------------|
|  Cliente  : DIPROMED                                         						|
|-----------------------------------------------------------------------------------|
|  Uso      : Rotina de calculo dos impostos atrav้s da MATXFIS 		            |
|-----------------------------------------------------------------------------------|
*/
Static Function EndImp()
MaFisEnd()
MaFisRestore()
Return

/*
|-----------------------------------------------------------------------------------|
|  Programa : CALCPED                                       Data : 18/08/2020       |
|-----------------------------------------------------------------------------------|
|  Cliente  : DIPROMED                                         						|
|-----------------------------------------------------------------------------------|
|  Uso      : Rotina de calculo total do pedido							            |
|-----------------------------------------------------------------------------------|
*/
Static Function CALCPED(cNumPed)
Local _cQry 	:= "" 
Local _nTotPed	:= 0
Local nI		:= 1

SC5->(dbSetOrder(1))
If SC5->(dbSeek(xFilial("SC5")+cNumPed))
	_cQry :=" SELECT ISNULL(SUM(C6_VALOR),0) AS 'TOT'   "
	_cQry +=" FROM "+RETSQLNAME ("SC6") + " SC6 "
	_cQry +=" WHERE C6_NUM       =  '"+cNumPed+"' "
	_cQry +=" AND SC6.D_E_L_E_T_ = ' '       "
	_cQry +=" AND C6_FILIAL      =  '"+XFILIAL("SC6")+"' "
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQry),'TMP2A',.T.,.F.)
	DbSelectArea("TMP2A")
	TMP2A->(dbgotop())
	_nTotPed:=TMP2A->TOT
	TMP2A->(DbCloseArea())
ELSE
	nPosVlr := aScan(aHeader, { |x| Alltrim(x[2]) == "C6_VALOR" })
	For nI:=1 to Len(aCols)                                              
		If !aCols[nI,Len(aHeader)+1]
			nVlr+=aCols[nI,nPosVlr]
		EndIf
	Next nI
EndIf
Return(_nTotPed)

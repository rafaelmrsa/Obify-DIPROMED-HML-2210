#INCLUDE "PROTHEUS.CH"
#INCLUDE 'APVT100.CH'
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³NOVO13    ºAutor  ³Microsiga           º Data ³  11/20/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function V167EMBALA()
Local aAreaCB9	:= CB9->(GetArea())      
Local aAreaCB7	:= CB7->(GetArea())
Local cExped 	:= Space(120)
Local cSQL		:= ""                       
Local nQtd		:= 0
Local cPedido   := CB7->CB7_PEDIDO 
Local cOrdSep   := CB7->CB7_ORDSEP
Local _lDipConf	:= .T.                                    
Local cConf		:= ""
Local aAreaSA1  := SA1->(GetArea())      
Local lImpPL	:= .F.

dbSelectArea("ZZ5")
SET FILTER TO Empty(ZZ5_NOTA) .And. Empty(ZZ5_SERIE)

cSQL := " SELECT COUNT(DISTINCT CB9_VOLUME) QTD FROM "+RetSQLName("CB9")
cSQL += " WHERE CB9_FILIAL = '"+xFilial("CB9")+"' AND "
cSQL += " CB9_PEDIDO = '"+cPedido+"' AND "  
cSQL += " CB9_VOLUME <> ' ' AND "
cSQL += " CB9_XNOTA  = ' ' AND "
cSQL += " CB9_XSERIE = ' ' AND "
cSQL += " D_E_L_E_T_ = ' ' "

cSQL := ChangeQuery(cSQL)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),"QRYCB9",.F.,.T. )

If !QRYCB9->(Eof())              
	nQtd := QRYCB9->QTD
EndIf	
QRYCB9->(dbCloseArea())                                                

ZZ5->(dbSetOrder(1))
If ZZ5->(dbSeek(xFilial("ZZ5")+cPedido))

	If !(StrTran(CB7->CB7_XTOUM,' ','') == "T/M" .And. CB7->CB7_XTM == "M")
		aTela   := VTSave()
		VTClear()
		
		If !VTYesNo("Confirma a expedição?"+chr(10)+chr(13)+AllTrim(ZZ5->ZZ5_EXPED1),"Atenção",.T.)
			While Empty(cExped)
				@ 0,0 VTSay "Expedicao"
				@ 1,0 VtSay "Informe a nova 
				@ 2,0 VtSay "expedicao"
				@ 4,0 VtGet cExped Pict "@!"
				VTRead
			EndDo   
		EndIf
				
		SA1->(dbSetOrder(1))	           
		If SA1->(dbSeek(xFilial("SA1")+CB7->CB7_CLIENT)) .And. SA1->A1_XCXDIPR == "S"
			aTela   := VTSave()
			VTClear()
				
			@ 0,0 VTSay "Cliente tipo A"
			@ 1,0 VtSay "Enviar fracionados"
			@ 2,0 VtSay "na caixa DIPROMED "
			@ 4,0 VTPause "Enter para continuar"
		EndIf
		
		BEGIN TRANSACTION
			ZZ5->(RecLock("ZZ5",.F.))
				cConf := POSICIONE("CB9",1,xFilial("CB9")+cOrdSep,"CB9_CODEMB")                            
				ZZ5->ZZ5_CONFER := POSICIONE("CB1",1,xFilial("CB1")+cConf,"CB1_XCODSC") 
				If !Empty(cExped)
					ZZ5->ZZ5_EXPED2 := ZZ5->ZZ5_EXPED1
					ZZ5->ZZ5_EXPED1 := cExped				
				EndIf
			ZZ5->(MsUnlock())
		END TRANSACTION		
	EndIf
	
	CB7->(dbSetOrder(2))
	If CB7->(dbSeek(xFilial("CB7")+cPedido))
		
		While !CB7->(Eof()) .And. CB7->CB7_PEDIDO = cPedido
						
			If _lDipConf
				_lDipConf := (CB7->CB7_STATUS >= "3")
			EndIf
							
			CB7->(dbSkip())
		EndDo
		
	EndIf

	BEGIN TRANSACTION   
		ZZ5->(RecLock("ZZ5",.F.))	
			If _lDipConf 
				ZZ5->ZZ5_STATUS := "4"                       		
				lImpPL := .T.                    		
			EndIf
			ZZ5->ZZ5_VOLUME := AllTrim(Str(nQtd))
		ZZ5->(MsUnlock())
	END TRANSACTION	                             

EndIf
   
If lImpPL	  
	U_ImpPL(cPedido,ZZ5->ZZ5_EXPED1,cOrdSep,ZZ5->ZZ5_CONFER)
EndIf

SET FILTER TO 
		 	 
RestArea(aAreaCB7)   
RestArea(aAreaCB9)
RestArea(aAreaSA1)

Return  
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³V167EMBALAºAutor  ³Microsiga           º Data ³  12/05/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function ImpPL(cPedido,cExped,cOrdSep,cConf)                   
Local cSQL 		:= ""     
Local lAdd 		:= .F.
Local nPos 		:= 0
Local aPackList := {}
Local cVolume 	:= ""
Local nLIn 		:= 2
Local nI 		:= 0
Local cUM		:= ""  
Local nCount 	:= 0
Local nTotPag   := 0  
Local nAux		:= 0 
Local nQtdReg	:= 0  
Local nCount 	:= 0
Local cVolume   := ""
DEFAULT cPedido := ""       
DEFAULT cExped  := ""
DEFAULT cOrdSep := ""      
DEFAULT cConf	:= ""

cSQL := " SELECT CB9_VOLUME, CB9_PROD, CB9_LOTECT, SUM(CB9_QTEEMB) QTD "    
cSQL += " FROM "+RetSQLName("CB9")
cSQL += " WHERE CB9_FILIAL = '"+xFilial("CB9")+"' " 
cSQL += " AND CB9_PEDIDO = '"+cPedido+"' "  
//cSQL += " AND CB9_ORDSEP = '"+cOrdSep+"' "
cSQL += " AND CB9_XNOTA  = ' ' "
cSQL += " AND CB9_XVOLOK = ' ' "
cSQL += " AND D_E_L_E_T_ = ' ' " 
cSQL += " GROUP BY CB9_VOLUME, CB9_PROD, CB9_LOTECT "         
cSQL += " ORDER BY CB9_VOLUME "

cSQL := ChangeQuery(cSQL)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),"CB9TRB",.T.,.T.)
TCSETFIELD("CB9TRB","QTD","N",8,0)

//CB9TRB->(dbEval({|| aAdd(aPackList,{CB9TRB->CB9_VOLUME,CB9TRB->CB9_PROD,CB9TRB->CB9_LOTECT,StrZero(CB9TRB->QTEEMB,8)})},{|| CB9TRB}))

While !CB9TRB->(Eof())                       
    
    lAdd := .F.    
    
    If CB9TRB->CB9_VOLUME <> cVolume .And. !Empty(cVolume)
   		nCount := 0 	
	EndIf
	
	If nCount == 0	
		cSQL := " SELECT CB9_VOLUME, CB9_PROD "
		cSQL += " FROM "+RetSQLName("CB9")
		cSQL += " WHERE CB9_FILIAL = '"+xFilial("CB9")+"' " 
		cSQL += " AND CB9_PEDIDO = '"+cPedido+"' "
		cSQL += " AND CB9_VOLUME = '"+CB9TRB->CB9_VOLUME+"' "
		cSQL += " AND D_E_L_E_T_ = ' ' " 
		cSQL += " GROUP BY CB9_VOLUME, CB9_PROD "         
			
		cSQL := ChangeQuery(cSQL)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),"COUNT",.T.,.T.)
		
		While !COUNT->(Eof())
			nCount++
			COUNT->(dbSkip())
		EndDo
		COUNT->(dbCloseArea())
	EndIf
	
	If nCount > 1
		lAdd := .T.		
	EndIf
	
	SB1->(dbSetOrder(1))
	If SB1->(dbSeek(xFilial("SB1")+CB9TRB->CB9_PROD))
		cUM := SB1->B1_UM 
		If SB1->B1_XTPEMBC == '2' .And. SB1->B1_XQTDSEC > CB9TRB->QTD
			lAdd := .T.
			cUM := SB1->B1_SEGUM
		ElseIf SB1->B1_XTPEMBC == '3' .And. SB1->B1_XQTDEMB > CB9TRB->QTD
			lAdd := .T.
		EndIf
	EndIf
	
	If lAdd
		aAdd(aPackList,{CB9TRB->CB9_VOLUME,CB9TRB->CB9_PROD,CB9TRB->QTD,cUM,CB9TRB->CB9_LOTECT})
	EndIf 
	
	cVolume := CB9TRB->CB9_VOLUME
	
	CB9TRB->(dbSkip())
EndDo

If Len(aPackList) > 0
	
	//VTAlert("Imprimindo PACK LIST DIPROMED","Aviso",.t.,4000,3)  
	nCount := 1      
	
	//cConf := POSICIONE("CB1",1,xFilial("CB1")+cConf,"CB1_XCODSC")       
	
	dbSelectArea("CB5")  	
	CB5SetImp("000007",.T.)
	
	cVolume := aPackList[1,1]
	
	aEval(aPackList,{|x| IIf(x[1]==cVolume,nAux++,nil)})
	
	nTotPag := Int(nAux/26)+IIf((nAux%26)>0,1,0)

	MSCBInfoEti("Vol: "+cVolume,"PACKLIST")
	MSCBBEGIN(1,4)
	
	MSCBBOX(02,01,99,98)  
	MSCBBOX(02,01,99,05,,'B')

	MSCBSAY(05,nLin,IIf(cEmpAnt=='01','DIPROMED','   H.Q.')				,"N", "C", "25") 

	MSCBLineV(20,01,05)
	MSCBSAY(23,nLin,'PEDIDO: '+AllTrim(cPedido)							,"N", "C", "25")

	MSCBLineV(45,01,05)
	MSCBSAY(47,nLin,'O.S.: '+AllTrim(cOrdSep)							,"N", "C", "25")
	
	MSCBLineV(67,01,05)
    MSCBSAY(70,nLin,'Exp.: '+SubStr(AllTrim(cExped),1,3)				,"N", "C", "25")

	MSCBLineV(87,01,05)
	//MSCBSAY(90,nLin,StrZero(nCount,2)+'/'+StrZero(nTotPag,2)			,"N", "C", "25") 
	MSCBSAY(90,nLin,AllTrim(cConf)										,"N", "C", "25") 
	
	nLin+=5
	
	MSCBSAY(06,nLin,'CONTEUDO DO VOLUME '+AllTrim(cVolume)				,"N", "C", "27")
	nLin+=5
	
	MSCBLineH(02,nLin,99) 	
	nLin+=2                                        

	MSCBSAY(03,nLin,'Produto ' 						,"N", "C", "26")
	MSCBSAY(85,nLin,'UM ' 							,"N", "C", "26")        
	MSCBSAY(93,nLin,'QTD ' 							,"N", "C", "26")
	nLin+=4
	
	For nI:=1 to Len(aPackList)
		If cVolume <> aPackList[nI,1] .Or. nQtdReg > 25 
	
			MSCBEND()    
			MSCBCLOSEPRINTER()
            
            nQtdReg := 0
            
			If nQtdReg > 25	.And. cVolume == aPackList[nI,1]			
				nCount++
			ElseIf cVolume <> aPackList[nI,1]            
				nCount:=1                                                                      
	            cVolume := aPackList[nI,1]
				aEval(aPackList,{|x| IIf(x[1]==cVolume,nAux++,nil)})
				nTotPag := Int(nAux/26)+IIf((nAux%26)>0,1,0)			
			EndIf
			            
			nLin := 2
			MSCBInfoEti("Vol: "+cVolume,"PACKLIST")
			MSCBBEGIN(1,4)   
			
			MSCBBOX(02,01,99,98)  
			MSCBBOX(02,01,99,05,,'B')
		
			MSCBSAY(05,nLin,IIf(cEmpAnt=='01','DIPROMED','   H.Q.')				,"N", "C", "25") 
		
			MSCBLineV(20,01,05)
			MSCBSAY(23,nLin,'PEDIDO: '+AllTrim(cPedido)							,"N", "C", "25")
		
			MSCBLineV(45,01,05)
			MSCBSAY(47,nLin,'O.S.: '+AllTrim(cOrdSep)							,"N", "C", "25")
			
			MSCBLineV(67,01,05)
		    MSCBSAY(70,nLin,'Exp.: '+SubStr(AllTrim(cExped),1,3)				,"N", "C", "25")
		
			MSCBLineV(87,01,05)
			//MSCBSAY(90,nLin,StrZero(nCount,2)+'/'+StrZero(nTotPag,2)			,"N", "C", "25") 
			MSCBSAY(90,nLin,AllTrim(cConf)										,"N", "C", "25")
			nLin+=5
			
			MSCBSAY(06,nLin,'CONTEUDO DO VOLUME '+AllTrim(cVolume)				,"N", "C", "27")
			nLin+=5
			
			MSCBLineH(02,nLin,99) 	
			nLin+=2                                        
		
			MSCBSAY(03,nLin,'Produto ' 						,"N", "C", "26")
			MSCBSAY(85,nLin,'UM ' 							,"N", "C", "26")        
			MSCBSAY(93,nLin,'QTD ' 							,"N", "C", "26")
			nLin+=4
		EndIf
		
		MSCBSAY(03,nLin,AllTrim(aPackList[nI,2])+"-"+PADR(POSICIONE("SB1",1,xFilial("SB1")+aPackList[nI,2],"B1_DESC"),45),"N", "C", "25")
		MSCBSAY(85,nLin,AllTrim(aPackList[nI,4])					,"N", "C", "25")                                                        
		MSCBSAY(92,nLin,PADL(AllTrim(Str(aPackList[nI,3])),4)		,"N", "C", "25")
		nLin+=3
		
		MSCBSAY(03,nLin,"LOTE: "+AllTrim(aPackList[nI,5])			,"N", "C", "25")   
		nLin+=3
		
		nQtdReg+=2
	Next nI
	MSCBEND() 
	MSCBCLOSEPRINTER()
EndIf

CB9TRB->(dbCloseArea())
	
Return

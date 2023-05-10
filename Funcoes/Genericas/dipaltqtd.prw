#INCLUDE "PROTHEUS.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDIPALTQTD บAutor  ณMicrosiga           บ Data ณ  08/26/14   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function DipAltQTD()     
Local cPerg 	:= "DALTQT"
Local cSQL  	:= ""
Local lRet  	:= .T.      
Local lConf		:= .T.
Local cPedido  	:= ""
Local cProduto 	:= ""
Local cLote	 	:= ""     
Local cLocal 	:= "01" //Local Padrใo
Local cLocaliz  := ""
Local nQtdDif   := 0
Local nQtdDif2  := 0

AjustaSX1(cPerg)                       

If !Pergunte(cPerg,.T.)
	Return		
EndIf  
            
cPedido  := MV_PAR01
cProduto := MV_PAR02
cLoteCt	 := MV_PAR03
cLocaliz := MV_PAR04
nQtdDif  := MV_PAR05             
nQtdDif2 := ConvUm(cProduto,nQtdDif,0,2)

Begin Transaction      
	
	cSQL := " SELECT "
	cSQL += " 	R_E_C_N_O_ REC "
	cSQL += " 	FROM "
	cSQL += 		RetSQLName("SC6")
	cSQL += " 		WHERE "
	cSQL += " 			C6_FILIAL 	= '"+xFilial("SC6")+"' AND "
	cSQL += " 			C6_NUM 		= '"+cPedido+"'  AND "
	cSQL += " 			C6_PRODUTO 	= '"+cProduto+"' AND "
	cSQL += " 			D_E_L_E_T_ 	= ' ' "   
	
	cSQL := ChangeQuery(cSQL)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),"QRYSC6",.T.,.T.)
	
	If !QRYSC6->(Eof())
		SC6->(dbGoTo(QRYSC6->REC))	                      
		SC6->(RecLock("SC6",.F.))
			SC6->C6_QTDVEN := (SC6->C6_QTDVEN-nQtdDif)
			SC6->C6_QTDLIB := (SC6->C6_QTDLIB-nQtdDif)     
			SC6->C6_VALOR  := Round(SC6->(C6_QTDVEN*C6_PRCVEN),2)
			If SC6->C6_QTDEMP > 0
				SC6->C6_QTDEMP  := (SC6->C6_QTDEMP-nQtdDif)
			EndIf
			If SC6->C6_SLDEMPE > 0
				SC6->C6_SLDEMPE := (SC6->C6_SLDEMPE-nQtdDif)
			EndIf
			If SC6->C6_QTDEMP2 > 0
				SC6->C6_QTDEMP2 := (SC6->C6_QTDEMP2-nQtdDif2)				
			EndIf
		SC6->(MsUnLock()) 
	Else
		Aviso("Aten็ใo","Dados nใo encontrados com os parโmetros informados",{"Ok"},1)			
		lRet := .F.
	EndIf
	QRYSC6->(dbCloseArea())
	
	If lRet
		cSQL := " SELECT "
		cSQL += " 	R_E_C_N_O_ REC "
		cSQL += " 	FROM "
		cSQL += 		RetSQLName("SC9")
		cSQL += " 		WHERE "
		cSQL += " 			C9_FILIAL 	= '"+xFilial("SC9")+"' AND "
		cSQL += " 			C9_PEDIDO 	= '"+cPedido+"'  AND "
		cSQL += " 			C9_PRODUTO 	= '"+cProduto+"' AND "
		cSQL += " 			C9_LOCAL 	= '"+cLocal+"' AND "
		cSQL += " 			C9_LOTECTL 	= '"+cLoteCt+"' AND "
		cSQL += " 			D_E_L_E_T_ 	= ' ' "
	
		cSQL := ChangeQuery(cSQL)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),"QRYSC9",.T.,.T.)
		
		If !QRYSC9->(Eof())
			SC9->(dbGoTo(QRYSC9->REC))	                      
			SC9->(RecLock("SC9",.F.))
				SC9->C9_QTDVEN := (SC9->C9_QTDVEN-nQtdDif)
				SC9->C9_QTDORI := (SC9->C9_QTDORI-nQtdDif)
				SC9->C9_QTDLIB := (SC9->C9_QTDLIB-nQtdDif)
				If SC9->C9_QTDLIB2 > 0 
					SC9->C9_QTDLIB2 := (SC9->C9_QTDLIB2-nQtdDif2)
				EndIf
			SC9->(MsUnLock()) 
		Else
			Aviso("Aten็ใo","Dados nใo encontrados com os parโmetros informados",{"Ok"},1)			
			lRet := .F.
		EndIf
		QRYSC9->(dbCloseArea())
	EndIf
	
	If lRet			
		cSQL := " SELECT "
		cSQL += " 	R_E_C_N_O_ REC "
		cSQL += " 	FROM "
		cSQL += 		RetSQLName("SDC")
		cSQL += " 		WHERE "
		cSQL += " 			DC_FILIAL 	= '"+xFilial("SDC")+"' AND "
		cSQL += " 			DC_PRODUTO 	= '"+cProduto+"' AND "
		cSQL += " 			DC_PEDIDO 	= '"+cPedido+"'  AND "
		cSQL += " 			DC_LOCAL 	= '"+cLocal+"'   AND "
		cSQL += " 			DC_LOTECTL 	= '"+cLoteCt+"' AND "
		cSQL += " 			D_E_L_E_T_ 	= ' ' "
		
		cSQL := ChangeQuery(cSQL)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),"QRYSDC",.T.,.T.)
		
		If !QRYSDC->(Eof())
			SDC->(dbGoTo(QRYSDC->REC))	                      
			SDC->(RecLock("SDC",.F.))
				SDC->DC_QUANT := (SDC->DC_QUANT-nQtdDif)
				If SDC->DC_QTSEGUM > 0
					SDC->DC_QTSEGUM := (SDC->DC_QTSEGUM-nQtdDif2)
				EndIf
			SDC->(MsUnLock()) 
		Else
			Aviso("Aten็ใo","Dados nใo encontrados com os parโmetros informados",{"Ok"},1)			
			lRet := .F.
		EndIf
		QRYSDC->(dbCloseArea())
	EndIf
	
	If lRet	
		cSQL := " SELECT "
		cSQL += " 	R_E_C_N_O_ REC "
		cSQL += " 	FROM "
		cSQL +=  		RetSQLName("SBF")
		cSQL += " 		WHERE "
		cSQL += " 			BF_FILIAL 	= '"+xFilial("SBF")+"' AND "
		cSQL += " 			BF_PRODUTO 	= '"+cProduto+"' AND "
		cSQL += " 			BF_LOTECTL 	= '"+cLoteCt+"' AND "
		cSQL += " 			BF_LOCAL 	= '"+cLocal+"'   AND "
		cSQL += " 			BF_LOCALIZ 	= '"+cLocaliz+"' AND "
		cSQL += " 			D_E_L_E_T_ 	= ' ' "
		
		cSQL := ChangeQuery(cSQL)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),"QRYSBF",.T.,.T.)
		
		If !QRYSBF->(Eof())
			SBF->(dbGoTo(QRYSBF->REC))	                      
			SBF->(RecLock("SBF",.F.)) 
				SBF->BF_EMPENHO := (SBF->BF_EMPENHO-nQtdDif)			
				If SBF->BF_EMPEN2 > 0
					SBF->BF_EMPEN2 := (SBF->BF_EMPEN2-nQtdDif2)
				EndIf
			SBF->(MsUnLock()) 
		Else
			Aviso("Aten็ใo","Dados nใo encontrados com os parโmetros informados",{"Ok"},1)			
			lRet := .F.
		EndIf
		QRYSBF->(dbCloseArea())
	EndIf	
	
	If lRet
		cSQL := " SELECT "
		cSQL += " 	R_E_C_N_O_ REC "
		cSQL += " 	FROM "
		cSQL +=  		RetSQLName("SB8") 
		cSQL += " 		WHERE "
		cSQL += " 			B8_FILIAL 	= '"+xFilial("SB8")+"' AND "
		cSQL += " 			B8_PRODUTO 	= '"+cProduto+"' AND "
		cSQL += " 			B8_LOCAL 	= '"+cLocal+"'   AND "
		cSQL += " 			B8_LOTECTL 	= '"+cLoteCt+"' AND "
		cSQL += " 			D_E_L_E_T_ 	= ' ' "
		cSQL := ChangeQuery(cSQL)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),"QRYSB8",.T.,.T.)
		
		If !QRYSB8->(Eof())
			SB8->(dbGoTo(QRYSB8->REC)) 
			SB8->(RecLock("SB8",.F.)) 
				SB8->B8_EMPENHO := (SB8->B8_EMPENHO-nQtdDif)
				If SB8->B8_EMPENH2 > 0
					SB8->B8_EMPENH2 := (SB8->B8_EMPENH2-nQtdDif2)
				EndIf
			SB8->(MsUnLock()) 
		Else
			Aviso("Aten็ใo","Dados nใo encontrados com os parโmetros informados",{"Ok"},1)			
			lRet := .F.
		EndIf
		QRYSB8->(dbCloseArea())
	EndIf                                                   
	
	If lRet 
		cSQL := " SELECT "
		cSQL += " 	R_E_C_N_O_ REC "
		cSQL += " 	FROM "
		cSQL +=  		RetSQLName("CB8")
		cSQL += " 		WHERE "
		cSQL += " 			CB8_FILIAL = '"+xFilial("CB8")+"' AND "
		cSQL += " 			CB8_PEDIDO = '"+cPedido+"' AND "
		cSQL += " 			CB8_PROD   = '"+cProduto+"' AND "
		cSQL += " 			CB8_LOCAL  = '"+cLocal+"' AND "
		cSQL += " 			CB8_LOTECT = '"+cLoteCT+"' AND "
		cSQL += " 			CB8_LCALIZ = '"+cLocaliz+"' AND "
		cSQL += " 			D_E_L_E_T_ = ' ' "   
		  
		cSQL := ChangeQuery(cSQL)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),"QRYCB8",.T.,.T.)
	
		If !QRYCB8->(Eof())
			CB8->(dbGoTo(QRYCB8->REC)) 
			CB8->(RecLock("CB8",.F.)) 				 
				If CB8->CB8_SALDOS == CB8->CB8_QTDORI
					lConf := .F.
				EndIf            				
				CB8->CB8_QTDORI  := (CB8->CB8_QTDORI-nQtdDif)	
				If (CB8->CB8_SALDOS-nQtdDif) >= 0
					CB8->CB8_SALDOS  := (CB8->CB8_SALDOS-nQtdDif)
				EndIf				
				If (CB8->CB8_SALDOE-nQtdDif) >= 0
					CB8->CB8_SALDOE := (CB8->CB8_SALDOE-nQtdDif)			
				EndIf
			CB8->(MsUnLock()) 
		Else
			Aviso("Aten็ใo","Dados nใo encontrados com os parโmetros informados",{"Ok"},1)			
			lRet := .F.
		EndIf
		QRYCB8->(dbCloseArea())
	EndIf	
	
	If lRet .And. lConf
		cSQl := " SELECT "
		cSQl += " 	R_E_C_N_O_ REC "
		cSQl += " 	FROM "
		cSQl += 		RetSQLName("CB9")
		cSQl += " 		WHERE "
		cSQl += " 			CB9_FILIAL = '"+xFilial("CB9")+"' AND "
		cSQl += " 			CB9_PEDIDO = '"+cPedido+"' AND "
		cSQl += " 			CB9_PROD   = '"+cProduto+"' AND "
		cSQl += " 			CB9_LOCAL  = '"+cLocal+"' AND "
		cSQl += " 			CB9_LOTECT = '"+cLoteCt+"' AND "
		cSQl += " 			CB9_LCALIZ = '"+cLocaliz+"' AND "
		cSQl += " 			D_E_L_E_T_ = ' ' "
			  
		cSQL := ChangeQuery(cSQL)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),"QRYCB9",.T.,.T.)
	
		If !QRYCB9->(Eof())
			CB9->(dbGoTo(QRYCB9->REC)) 
			CB9->(RecLock("CB9",.F.))  
				CB9->CB9_QTESEP := (CB9->CB9_QTESEP-nQtdDif)
			CB9->(MsUnLock()) 
		Else
			Aviso("Aten็ใo","Dados nใo encontrados com os parโmetros informados",{"Ok"},1)			
			lRet := .F.
		EndIf
		QRYCB9->(dbCloseArea())
	EndIf	
	                     
	
	If lRet 
		cSQL := " SELECT "
		cSQL += " 	R_E_C_N_O_ REC "
		cSQL += " 	FROM "
		cSQL += 		RetSQLName("SB2") 
		cSQL += " 		WHERE "
		cSQL += " 			B2_FILIAL  = '"+xFilial("SB2")+"' AND "
		cSQL += " 			B2_COD 	   = '"+cProduto+"' AND "
		cSQL += " 			B2_LOCAL   = '"+cLocal+"' AND "
		cSQL += " 			B2_RESERVA > 0 AND "	
		cSQL += " 			D_E_L_E_T_ = ' ' "
				  
		cSQL := ChangeQuery(cSQL)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),"QRYSB2",.T.,.T.)
	
		If !QRYSB2->(Eof())
			SB2->(dbGoTo(QRYSB2->REC)) 
			SB2->(RecLock("SB2",.F.))  
				SB2->B2_RESERVA := (SB2->B2_RESERVA-nQtdDif)
				If SB2->B2_RESERV2 > 0 
					SB2->B2_RESERV2 := (SB2->B2_RESERV2-nQtdDif2)
				EndIf
			SB2->(MsUnLock()) 
		Else
			Aviso("Aten็ใo","Dados nใo encontrados com os parโmetros informados",{"Ok"},1)			
			lRet := .F.
		EndIf
		QRYSB2->(dbCloseArea())
	EndIf
		
	If !lRet
		If InTransact()
			DisarmTransaction()
		EndIf
		Break
	EndIf
	
End Transaction
	
If lRet
	Aviso("Aten็ใo","Quantidade alterada e estoque liberado para dar a baixa.",{"Ok"},1)
EndIf                     

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDIPALTQTD บAutor  ณMicrosiga           บ Data ณ  08/26/14   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function AjustaSX1(cPerg)
Local aRegs 	:= {}
DEFAULT cPerg 	:= ""

dbSelectArea("SX1")
dbSetOrder(1)

aAdd(aRegs,{cPerg,"01","Pedido      ?","","","mv_ch1","C", 6,0,0,"G","naovazio","MV_PAR01","","","","","","","","","","","","","","","","","","","","","","","","",''})
aAdd(aRegs,{cPerg,"02","Produto     ?","","","mv_ch2","C",15,0,0,"G","naovazio","MV_PAR02","","","","","","","","","","","","","","","","","","","","","","","","",''})
aAdd(aRegs,{cPerg,"03","Lote        ?","","","mv_ch3","C",10,0,0,"G","naovazio","MV_PAR03","","","","","","","","","","","","","","","","","","","","","","","","",''})
aAdd(aRegs,{cPerg,"04","Endere็o    ?","","","mv_ch4","C",15,0,0,"G","naovazio","MV_PAR04","","","","","","","","","","","","","","","","","","","","","","","","",''})
aAdd(aRegs,{cPerg,"05","Qtd a Baixar?","","","mv_ch5","N",10,0,0,"G","naovazio","MV_PAR05","","","","","","","","","","","","","","","","","","","","","","","","",''})

PlsVldPerg( aRegs )       

Return
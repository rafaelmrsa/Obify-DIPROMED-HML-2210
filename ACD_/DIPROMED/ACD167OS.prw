#INCLUDE "ACDV167.CH" 
#INCLUDE "PROTHEUS.CH"
#INCLUDE "APVT100.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ACD167OS  ºAutor  ³Microsiga           º Data ³  11/05/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Ponto de entrada para alterar a impressora e imprimir os volº±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/                                                                        
User Function ACD167OS()    
Local aArea	  := GetArea()    
LOCAL aAreaSA1:= SA1->(GetArea())
LOCAL cOrdSep := PARAMIXB[1]
LOCAL _lSepCxF:= PARAMIXB[2]
LOCAL lRet    := .T.

If cEmpAnt=="01"
	lRet := Dip167OS(cOrdSep,_lSepCxF)
Else
	lRet := u_HQ_167OS(cOrdSep,_lSepCxF)
EndIf

RestArea(aAreaSA1)
RestArea(aArea)   

Return lRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ACD167OS  ºAutor  ³Microsiga           º Data ³  06/27/17   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Dip167OS(cOrdSep,_lSepCxF)
LOCAL nI  	  := 0
LOCAL nQtd 	  := 0                                               
LOCAL cCodVol := ""         
LOCAL cSQL 	  := ""       
LOCAL cTipo   := ""
LOCAL cPedido := ""
LOCAL cTransp := ""
LOCAL cOSReqMt:= ""  
LOCAL aEtiq	  := {}   

LOCAL cExped  := ""          
LOCAL lRet 	  := .T.
LOCAL aDipJaImp := {}  
LOCAL lDipJaImp := .F.

PRIVATE _nDipVFra := 0 //Volumes Fracionados
PRIVATE _nDipVCxF := 0 //Volumes Caixa Fechada
Public __aDiproOS := {}   

DEFAULT cOrdSep   := ""                  
DEFAULT _lSepCxF  := .F.

If AllTrim(CB7->CB7_XTOUM)=="T/M" .And. CB7->CB7_XTM == "M"
	lRet := DipVldTerr(CB7->CB7_PEDIDO)
EndIf
                                     
If lRet
	ZZ5->(dbSetOrder(1))       
	If ZZ5->(dbSeek(xFilial("ZZ5")+CB7->CB7_PEDIDO)) .And. !_lSepCxF
		If CB7->CB7_XTM == "M"
			cExped := ZZ5->ZZ5_EXPEDM
		Else                         
			cExped := ZZ5->ZZ5_EXPED1
		EndIf
	
		aTela   := VTSave()
		VTClear()
			
		@ 0,0 VTSay "Expedicao"
		@ 1,0 VtSay "Va para a expedicao"
		@ 2,0 VtSay AllTrim(cExped)  
		@ 4,0 VTPause "Enter para continuar"		
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
	
	cTipo := CB7->CB7_XTM
	cImp  := '000004'
	
	cPedido := CB7->CB7_PEDIDO                        
	cTransp := CB7->CB7_TRANSP
	cOSReqMt:= CB7->CB7_XREQMT   

	aTela   := VTSave()
	VTClear()

	CB8->(dbSetOrder(1))
	CB8->(dbSeek(xFilial("CB8")+cOrdSep))                                             

	While !CB8->(Eof()) .And. CB8->CB8_ORDSEP == cOrdSep   
	
		lDipJaImp := .F.
		If aScan(aDipJaImp,{|x| x==CB8->(CB8_PROD+CB8_LOTECT)})==0
			aAdd(aDipJaImp,CB8->(CB8_PROD+CB8_LOTECT))
		Else
			lDipJaImp := .T.
		EndIf			
		
		If ACDVldCxF(CB8->CB8_ORDSEP,CB8->CB8_PROD,CB8->CB8_LOTECT,lDipJaImp) 
			aAdd(aEtiq, {CB8->CB8_PROD,CB8->CB8_LOTECT,cTipo,cPedido,cOrdSep,CB8->CB8_LCALIZ,POSICIONE("SB1",1,xFilial("SB1")+CB8->CB8_PROD,"B1_DESC")})  
		EndIf                         
	
		CB8->(dbSkip())
	EndDo
	
	aSort(aEtiq,,,{|x,y| x[7]>y[7]})
		  
	aTela   := VTSave()
	VTClear()

	nQtd := _nDipVCxF 
	If _nDipVFra > 0 
		nQtd += Int(_nDipVFra/3)
		If Mod(_nDipVFra,3)<>0
			nQtd ++
		EndIf
	EndIf
	
	If CB7->CB7_STATUS>"2" .Or. !Empty(CB7->CB7_STATPA)
		nQtd  := 0		
		
		If !VTYesNo("Deseja imprimir etiquetas de produto?","Atenção",.T.)	
			aEtiq := {}
		EndIf		
		
		If VTYesNo("Deseja imprimir etiquetas de volume?","Atenção",.T.)
			@ 0,0 VTSay "Volume"
			@ 1,0 VtSay "Informe a quantidade"
			@ 2,0 VtSay "prevista de volumes"
			@ 3,0 VtSay "para impressao"
			@ 5,0 VtGet nQtd Pict "@E 99999"
			
			VTRead
			
			If nQtd > 200                           
				While !VTYesNo("Confirma a quantidade?"+chr(10)+chr(13)+AllTrim(Str(nQtd)),"Atenção",.T.) 
					aTela   := VTSave()
					VTClear()
					nQtd := 1
					@ 0,0 VTSay "Volume"
					@ 1,0 VtSay "Informe a quantidade"
					@ 2,0 VtSay "prevista de volumes"
					@ 3,0 VtSay "para impressao"
					@ 5,0 VtGet nQtd Pict "@E 99999"   
			
					VTRead
				EndDo	
			EndIf
	    EndIf             
	EndIf	    
	    
	If nQtd > 0
		VTAlert("Imprimindo "+cValToChar(nQtd)+" etiqueta(s) de volume(s) ","Aviso",.T.,2000)
	
		CB5SetImp(cImp,.t.)
	
		For nI := 1 to nQtd
		    
		    cCodVol := CB6->(GetSX8Num("CB6","CB6_VOLUME"))
			ConfirmSX8()
		
			ExecBlock("IMG05",.f.,.f.,{cCodVol,CB7->CB7_PEDIDO,CB7->CB7_NOTA,CB7->CB7_SERIE})
			
			CB6->(RecLock("CB6",.T.))
				CB6->CB6_FILIAL := xFilial("CB6")
				CB6->CB6_VOLUME := cCodVol
				CB6->CB6_PEDIDO := CB7->CB7_PEDIDO
				CB6->CB6_NOTA   := CB7->CB7_NOTA
				CB6->CB6_SERIE  := CB7->CB7_SERIE
				CB6->CB6_TIPVOL := CB3->CB3_CODEMB
				CB6->CB6_STATUS := "1"   // ABERTO
			CB6->(MsUnlock())
		Next nI
	
		MSCBCLOSEPRINTER()              
		               
	EndIf          
	
	For nI:=1 to Len(aEtiq)     
		If CB5SetImp(cImp,.T.)  
			U_GERAETIQ(aEtiq[nI,1],nil,nil,1,nil,aEtiq[nI,2],nil,nil,nil,aEtiq[nI,4],aEtiq[nI,5],.T.,cTransp,aEtiq[nI,7],cOSReqMt)  
			MSCBCLOSEPRINTER() 
		EndIf  
	Next nI	                                    
	       
	If VtLastKey() == 27 .And. CB7->CB7_STATUS < "4" //Se STATUS=4 é estorno pode liberar a saída
		CB7->(RecLock("CB7",.F.))
			CB7->CB7_STATUS := "3"
			CB7->CB7_STATPA := "1"
			CB7->CB7_XOPCON := cCodOpe
		CB7->(MsUnLock())      
	EndIf
Else
	VTAlert("Conferência do Térreo ainda não foi finalizada.","Aviso",.T.,2000)
EndIf

Return lRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ACD167OS  ºAutor  ³Microsiga           º Data ³  06/27/17   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function HQ_167OS(cOrdSep,_lSepCxF)
LOCAL nI  	  := 0
LOCAL _nQtdVol:= 0                                               
LOCAL cCodVol := ""         
LOCAL cSQL 	  := ""       
LOCAL cTipo   := ""
LOCAL cPedido := ""
LOCAL cTransp := ""  
LOCAL aEtiq	  := {}   
LOCAL cExped  := ""          
LOCAL lRet 	  := .T.
LOCAL aDipJaImp := {}  
LOCAL lDipJaImp := .F.
LOCAL cForBenec := GetNewPar("MV_UINDBEN","019433,110087,091835")
LOCAL cOSReqMt  := ""
PRIVATE _nDipVFra := 0 //Volumes Fracionados
PRIVATE _nDipVCxF := 0 //Volumes Caixa Fechada
Public __aDiproOS := {} 

DEFAULT cOrdSep := ""
DEFAULT _lSepCxF  := .F.

If AllTrim(CB7->CB7_XTOUM)=="T/M" .And. CB7->CB7_XTM == "M"
	lRet := DipVldTerr(CB7->CB7_PEDIDO)
EndIf
                                     
If lRet
	If !Empty(CB7->CB7_XREQMT)
		ZZ8->(dbSetOrder(1))
		If ZZ8->(dbSeek(xFilial("ZZ8")+CB7->CB7_XREQMT))
			cExped := ZZ8->ZZ8_XEXPED
			
			aTela   := VTSave()
			VTClear()
				
			@ 0,0 VTSay "Expedicao"
			@ 1,0 VtSay "Va para a expedicao"
			@ 2,0 VtSay AllTrim(cExped)  
			@ 4,0 VTPause "Enter para continuar"	
		EndIf
	Else	
	   ZZ5->(dbSetOrder(1))       
	If ZZ5->(dbSeek(xFilial("ZZ5")+CB7->CB7_PEDIDO)) .And. !_lSepCxF
			If CB7->CB7_XTM == "M"
				cExped := ZZ5->ZZ5_EXPEDM
			Else                         
				cExped := ZZ5->ZZ5_EXPED1
			EndIf
		
			aTela   := VTSave()
			VTClear()
				
			@ 0,0 VTSay "Expedicao"
			@ 1,0 VtSay "Va para a expedicao"
			@ 2,0 VtSay AllTrim(cExped)  
			@ 4,0 VTPause "Enter para continuar"		
		EndIf
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
		
	cTipo := CB7->CB7_XTM
	cImp  := '000004'
	
	If !Empty(CB7->CB7_XREQMT)
		cPedido := CB7->CB7_XREQMT
		cOSReqMt:= CB7->CB7_XREQMT                        
		cTransp := ""
	Else
		cPedido := CB7->CB7_PEDIDO                        
		cTransp := CB7->CB7_TRANSP   
	EndIf
	
	aTela   := VTSave()
	VTClear()
	
		CB8->(dbSetOrder(1))
		CB8->(dbSeek(xFilial("CB8")+cOrdSep))
		While !CB8->(Eof()) .And. CB8->CB8_ORDSEP == cOrdSep
		lDipJaImp := .F.
		If aScan(aDipJaImp,{|x| x==CB8->(CB8_PROD+CB8_LOTECT)})==0
			aAdd(aDipJaImp,CB8->(CB8_PROD+CB8_LOTECT))
		Else
			lDipJaImp := .T.
		EndIf			
		If ACDVldCxF(CB8->CB8_ORDSEP,CB8->CB8_PROD,CB8->CB8_LOTECT,lDipJaImp) 
			aAdd(aEtiq, {CB8->CB8_PROD,CB8->CB8_LOTECT,cTipo,cPedido,cOrdSep,CB8->CB8_LCALIZ,POSICIONE("SB1",1,xFilial("SB1")+CB8->CB8_PROD,"B1_DESC")})  
		EndIf                         
			CB8->(dbSkip())
		EndDo
		
		aSort(aEtiq,,,{|x,y| x[7]>y[7]})
	  
	aTela   := VTSave()
	VTClear()
	_nQtdVol := _nDipVCxF
	
	If _nDipVFra > 0 
		_nQtdVol += Int(_nDipVFra/3)
		If Mod(_nDipVFra,3)<>0
			_nQtdVol ++
		EndIf
	EndIf
	
	If CB7->CB7_STATUS>"2" .Or. !Empty(CB7->CB7_STATPA)
		_nQtdVol  := 0		
		
		If !VTYesNo("Deseja imprimir etiquetas de produto?","Atenção",.T.)	
			aEtiq := {}
		EndIf		
		
		If VTYesNo("Deseja imprimir etiquetas de volume?","Atenção",.T.)
			@ 0,0 VTSay "Volume"
			@ 1,0 VtSay "Informe a quantidade"
			@ 2,0 VtSay "prevista de volumes"
			@ 3,0 VtSay "para impressao"
			@ 5,0 VtGet _nQtdVol Pict "@E 99999"
			
			VTRead
			
			If _nQtdVol > 200                           
				While !VTYesNo("Confirma a quantidade?"+chr(10)+chr(13)+AllTrim(Str(_nQtdVol)),"Atenção",.T.) 
					aTela   := VTSave()
					VTClear()
					_nQtdVol := 1
					@ 0,0 VTSay "Volume"
					@ 1,0 VtSay "Informe a quantidade"
					@ 2,0 VtSay "prevista de volumes"
					@ 3,0 VtSay "para impressao"
					@ 5,0 VtGet _nQtdVol Pict "@E 99999"   
			
					VTRead
				EndDo	
			EndIf
	    EndIf             
	EndIf	    

	If CB7->CB7_CLIENT $ cForBenec
	   VTAlert("Etiquetas Produtos BNs!","Aviso",.T.,2000)
		cImp  := '000002'// Local de impressao producao HQ		
	EndIf

	If _nQtdVol > 0
		VTAlert("Imprimindo "+cValToChar(_nQtdVol)+" etiqueta(s) de volume(s) ","Aviso",.T.,2000)

		CB5SetImp(cImp,.t.)
	
		For nI := 1 to _nQtdVol
		    
		    cCodVol := CB6->(GetSX8Num("CB6","CB6_VOLUME"))
			ConfirmSX8()
		
			ExecBlock("IMG05",.f.,.f.,{cCodVol,CB7->CB7_PEDIDO,CB7->CB7_NOTA,CB7->CB7_SERIE})
			
			CB6->(RecLock("CB6",.T.))
				CB6->CB6_FILIAL := xFilial("CB6")
				CB6->CB6_VOLUME := cCodVol
				CB6->CB6_PEDIDO := cPedido
				CB6->CB6_NOTA   := CB7->CB7_NOTA
				CB6->CB6_SERIE  := CB7->CB7_SERIE
				CB6->CB6_TIPVOL := CB3->CB3_CODEMB
				CB6->CB6_STATUS := "1"   // ABERTO
			CB6->(MsUnlock())
		Next nI
	
		MSCBCLOSEPRINTER()              
		               
	EndIf          
	
	For nI:=1 to Len(aEtiq)     
		If CB5SetImp(cImp,.T.)  
			U_GERAETIQ(aEtiq[nI,1],nil,nil,1,nil,aEtiq[nI,2],nil,nil,nil,aEtiq[nI,4],aEtiq[nI,5],.T.,cTransp,aEtiq[nI,7],cOSReqMt)  
			MSCBCLOSEPRINTER() 
		EndIf  
	Next nI	                                    
	       
	If VtLastKey() == 27 .And. CB7->CB7_STATUS < "4" //Se STATUS=4 é estorno pode liberar a saída
		CB7->(RecLock("CB7",.F.))
			CB7->CB7_STATUS := "3"
			CB7->CB7_STATPA := "1"
			CB7->CB7_XOPCON := cCodOpe
		CB7->(MsUnLock())      
	EndIf
Else
	VTAlert("Conferência do Térreo ainda não foi finalizada.","Aviso",.T.,2000)
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ACD167OS  ºAutor  ³Microsiga           º Data ³  10/14/16   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function DipVldTerr(cPedido)                                
Local aArea:= GetArea()
Local lRet := .F.
Local cSQL := ""          
DEFAULT cPedido := ""

cSQL := " SELECT "
cSQL += " 	CB7_STATUS "
cSQL += " 	FROM "
cSQL +=  		RetSQLName("CB7")
cSQL += " 		WHERE "
cSQL += " 			CB7_FILIAL = '"+xFilial("CB7")+"'AND "
cSQL += " 			CB7_PEDIDO = '"+cPedido+"' AND "
cSQL += " 			CB7_XTM = 'T' AND "
cSQL += " 			D_E_L_E_T_ = ' ' "

cSQL := ChangeQuery(cSQL)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),"DIPCB7",.T.,.T.)

If !DIPCB7->(Eof())
	lRet := DIPCB7->CB7_STATUS >= "4"
EndIf
DIPCB7->(dbCloseArea())

RestArea(aArea)

Return lRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ACD167OS  ºAutor  ³Microsiga           º Data ³  05/31/17   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ACDVldCxF(cOrdSep,cProduto,cLoteCTL,lDipJaImp)  
Local cSQL  := ""         
Local lRet  := .F.
Local aArea :=  GetArea()                           

DEFAULT cOrdSep   := ""    
DEFAULT cProduto  := ""    
DEFAULT lDipJaImp := .F.  

cSQL := " SELECT "
cSQL += "  	SUM(CB8_QTDORI) CB8_QTD, "
cSQL += "	CASE WHEN B1_XTPEMBC='3' THEN B1_XQTDEMB ELSE "
cSQL += "	(CASE WHEN B1_XTPEMBC='2' THEN B1_XQTDSEC ELSE "
cSQL += "	(CASE WHEN B1_XTPEMBC='1' THEN 1 ELSE 0 END) END) END B1_QTD "
cSQL += " 	FROM "
cSQL +=  		RetSQLName("CB8")
cSQL += " 		INNER JOIN "
cSQL +=  			RetSQLName("SB1")
cSQL += " 			ON "
cSQL += " 				B1_FILIAL = CB8_FILIAL AND "
cSQL += " 				B1_COD = CB8_PROD AND "
cSQL +=  				RetSQLName("SB1")+".D_E_L_E_T_ = ' ' "
cSQL += " 		WHERE "                       
cSQL += " 			CB8_FILIAL = '"+xFilial("CB8")+"' AND "
cSQL += " 			CB8_ORDSEP = '"+cOrdSep+"' AND "
cSQL += " 			CB8_PROD   = '"+cProduto+"' AND "  
cSQL += " 			CB8_LOTECT = '"+cLoteCTL+"' AND "
cSQL +=  			RetSQLName("CB8")+".D_E_L_E_T_  = ' ' "
cSQL += " GROUP BY B1_XTPEMBC, B1_XQTDEMB, B1_XQTDSEC "

cSQL := ChangeQuery(cSQL)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),"SB1CB8",.T.,.T.)

If !SB1CB8->(Eof())
	If SB1CB8->B1_QTD==0 // Fracionado
		lRet := .T.
		If !lDipJaImp
			_nDipVFra ++                   
		EndIf
	ElseIf Mod(SB1CB8->CB8_QTD,SB1CB8->B1_QTD)<>0
		lRet := .T.
		If !lDipJaImp
			_nDipVFra ++
			_nDipVCxF += Int(SB1CB8->CB8_QTD/SB1CB8->B1_QTD)		
		EndIf
	ElseIf !lDipJaImp
		_nDipVCxF += SB1CB8->CB8_QTD/SB1CB8->B1_QTD
	EndIf          
EndIf
SB1CB8->(dbCloseArea())

RestArea(aArea)

Return lRet
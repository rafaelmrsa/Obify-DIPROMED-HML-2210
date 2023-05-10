#INCLUDE "PROTHEUS.CH"     
#INCLUDE "TBICONN.CH"
#INCLUDE "TCBROWSE.CH"
#INCLUDE "RWMAKE.CH"  
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DIPLISREP ºAutor  ³Microsiga           º Data ³  11/16/16   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function DipLisRep()    
Local nRow 			:= 08	   		   	   					//coordenada vertical.
Local nCol      	:= 05 	   		   	   					//coordenada horizontal.
Local nWidth    	:= 150  			   					//largura em pixels do objeto.
Local nHeight   	:= 150		  	    	 			    //altura em pixels do objeto.
Local uParam20 		:= .F.    								//Compatibilidade.
Local lPixel    	:= .T.    								//considera as coordenadas passadas em pixels.
Local uParam24  	:= .F.    								//Compatibilidade.
Local cDelFunc 		:= "AllwaysTrue"
Local _aCampos 		:= {}
Local _aStrut 		:= {}
Local cCadastro 	:= "Lista de Preço"
Local _cArq			:= ""
Local _cIndex		:= ""
Local _cChave		:= ""       
Local _cObs1		:= ""  
Local _cObs2		:= ""
Local _cObs3		:= ""
Local _cObs4		:= ""
Local _cObs5		:= ""          
Local cFiltro 		:= Space(60)
Local nPerc1		:= 51.81
Local nPerc2		:= 64.5
Local nReduz1		:= 0
Local nReduz2		:= 0                        
Private aRotina 	:= {{"Exportar","Alert('Ok')",0,4}}                     
Private aCpos	  	:= {} 							        
Private aCols  		:= {} 	            				   
Private aSize       := GETSCREENRES()
Private oBrowse                                                                          
Private oProcess
Private aColSizes 	:= Array(15)           			    // largura das colunas.


PREPARE ENVIRONMENT EMPRESA "01" FILIAL "04" FUNNAME "DipLisRep" TABLES "SX3","SB1"

If !DipVldChv()	
	RESET ENVIRONMENT
	Return .F.
EndIf
                           
aCpos  :=  	   {"CODIGO",;
				"PRODUTO",;
				"UM",;
				"ALTERADO",;
				"LISTA",;
				"C",;
				"D",;
				"PROMOCAO",;
				"ESTOQUE",;
				"MENSAGEM",;
				"OBS1",;
				"OBS2",;
				"OBS3",;
				"OBS4",;
				"OBS5" } 
                                                        
//MsgStop(Str(aSize[1])+" x "+Str(aSize[2])) resolução

nReduz1 := nPerc1*aSize[1]/100
nReduz2 := nPerc2*aSize[2]/100

oDlg := MSDialog():New(0,0,aSize[2]-170,aSize[1]-50,"Lista de Preços",,,.F.,,,,,,.T.,,,.T. )
oDlg:bInit := {||EnchoiceBar(oDlg,{||oDlg:End()},{|| oDlg:End()},,)}
	
	aItens1 := {'Código','Produto'}        
	cCombo1 := aItens1[1]
	oCombo1 := TComboBox():New(39,02,{|u| IIf(PCount()>0,cCombo1:=u,cCombo1)},aItens1,50,20,oDlg,,,,,,.T.,,,,,,,,,'cCombo1')
	
	aItens2 := {'Igual','Contém'}
	cCombo2 := aItens2[1]
	oCombo2 := TComboBox():New(39,55,{|u| IIf(PCount()>0,cCombo2:=u,cCombo2)},aItens2,50,20,oDlg,,,,,,.T.,,,,,,,,,'cCombo2')	
	
	oGet := TGet():New(40,108,{|u| IIf(PCount()>0,cFiltro:=u,cFiltro)},oDlg,150,009,"@!",,,,,,,.T.,,,,,,,,,,"cFiltro",,,, )
	
	oPesquisa	:= TButton():New(039,260,'Pesquisa',oDlg,{|| DipFilLis(AllTrim(cFiltro))},37,12,,,,.T.)
	oExporta	:= TButton():New(039,300,'Download',oDlg,{||	MsgRun("Aguarde...","Exportando os Registros...",{||ExpLista(aCols)}) },37,12,,,,.T.)
	    
			
	oBrowse := TCBrowse():New(055,002,aSize[1]-nReduz1,aSize[2]-nReduz2,/*bLine*/,aCpos,aColSizes,;
	oDlg,/*cField*/,/*uValue1*/,/*uValue2*/,/*bChange*/,/*bLDblClick*/,;
	/*bRClick*/,/*oFont*/,/*oCursor*/,/*nClrFore*/,/*nClrBack*/,/*cMsg*/,;
	uParam20,/*cAlias*/,lPixel,/*bWhen*/,uParam24,/*bValid*/,/*lHScroll*/,/*lVScroll*/)
	
	oProcess := MsNewProcess():New({|| DipProcFil() },"Aguarde","Processando...") 
	oProcess:Activate()
	 
	If Len(aCols) > 0 .And. Type("oBrowse") <> "U"
		aSort(aCols,,,{|x,y| x[2]<y[2]})  
	
		oBrowse:SetArray(aCols)
		
		oBrowse:bLine := {||{ aCols[oBrowse:nAt,01],;
		                      aCols[oBrowse:nAt,02],;
		                      aCols[oBrowse:nAt,03],;
		                      aCols[oBrowse:nAt,04],;
		                      aCols[oBrowse:nAt,05],;
		                      aCols[oBrowse:nAt,06],;
		                      aCols[oBrowse:nAt,07],;
		                      aCols[oBrowse:nAt,08],;
		                      aCols[oBrowse:nAt,09],;
		                      aCols[oBrowse:nAt,10],;
		                      aCols[oBrowse:nAt,11],;
		                      aCols[oBrowse:nAt,12],;
		                      aCols[oBrowse:nAt,13],;
		                      aCols[oBrowse:nAt,14],;
		                      aCols[oBrowse:nAt,15]}}
	EndIf
	
oDlg:Activate(,,,.T.)


RESET ENVIRONMENT

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DIPLISREP ºAutor  ³Microsiga           º Data ³  11/17/16   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static function DipFilLis(cFiltro)
oProcess := MsNewProcess():New({|| DipProcFil(cFiltro) },"Aguarde","Processando") 
oProcess:Activate()
Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DIPLISREP ºAutor  ³Microsiga           º Data ³  11/18/16   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function DipProcFil(cFiltro)
Local lRet 		:= .T.
Local cSQL 		:= ""
Local cSQL1 	:= ""
Local cSQL2 	:= ""
Local _cObs1	:= ""  
Local _cObs2	:= ""
Local _cObs3	:= ""
Local _cObs4	:= ""
Local _cObs5	:= ""          
Local _cObserva := ""
Local cCaract 	:= ""
Local nCount    := 0      
Local nLenReg   := 0
DEFAULT cFiltro := ""
        
cSQL1 := " SELECT "
cSQL1 += " 	B1_COD CODIGO, "
cSQL1 += " 	B1_DESC PRODUTO, "
cSQL1 += " 	B1_UM UM, "
cSQL1 += " 	B1_ALTPREC ALTERADO, "
cSQL1 += " 	B1_PRV1 LISTA, "
cSQL1 += " 	B1_PRVMINI C, "
cSQL1 += " 	B1_PRVPROM D, "
cSQL1 += " 	B1_PRVSUPE PROMOCAO, "
cSQL1 += " 	B1_MEN_HAB MENSAGEM, "
cSQL1 += " 	B1_CODOBS OBS "          

cSQL2:= " SELECT COUNT(1) QTD "

cSQL := " 	FROM "
cSQL +=  		RetSQLName("SB1")
cSQL += " 		WHERE
cSQL += " 			B1_FILIAL = '"+xFilial("SB1")+"' AND "
cSQL += " 			B1_PRV1 > 0 AND "
cSQL += " 			B1_HABILIT NOT IN('N','O','L') AND "
cSQL += " 			B1_TIPO = 'PA' AND "
cSQL += " 			LEFT(B1_DESC,1) NOT IN('.','Z') AND "    

If !Empty(cFiltro)
	If oCombo1:nAt==1 //Código
		If oCombo2:nAt==1 //Igual
			cSQL += " 	B1_COD = '"+cFiltro+"' AND "
		Else //Contém
			cSQL += " 	B1_COD LIKE '%"+cFiltro+"%' AND "
		EndIf
	Else //Descrição 
		If oCombo2:nAt==1 //Igual
			cSQL += " 	B1_DESC LIKE '"+cFiltro+"%' AND "	
		Else //Contém
			cSQL += " 	B1_DESC LIKE '%"+cFiltro+"%' AND "
		EndIf	
	EndIf
EndIf	

cSQL +=	RetSQLName("SB1")+".D_E_L_E_T_ = ' ' "

cSQL1 := ChangeQuery(cSQL1+cSQL)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL1),"QRYFIL",.T.,.T.)     

TCSETFIELD("QRYFIL","ALTERADO","D",08,0)
TCSETFIELD("QRYFIL","LISTA"	  ,"N",12,4)
TCSETFIELD("QRYFIL","C"		  ,"N",12,4)
TCSETFIELD("QRYFIL","D"		  ,"N",12,4)
TCSETFIELD("QRYFIL","PROMOCAO","N",12,4)                            

cSQL2 := ChangeQuery(cSQL2+cSQL)                                
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL2),"QRYQTD",.T.,.T.)     

If !QRYQTD->(Eof()) .And. QRYQTD->QTD > 0 
	nLenReg := QRYQTD->QTD
EndIf
QRYQTD->(dbCloseArea())

dbSelectArea("QRYFIL") 
If !QRYFIL->(Eof())

	aCols := {}
	
	oProcess:SetRegua1(100)
	oProcess:SetRegua2(nLenReg)
	
	While !QRYFIL->(Eof())                  
	
		nCount++                                     
	                             
		If Mod(nCount,100)==0
			oProcess:SetRegua1(100)
		EndIf
		oProcess:IncRegua1("Filtrando registros "+AllTrim(Str(nCount))+" de "+AllTrim(Str(nLenReg)))
	
		oProcess:IncRegua2(AllTrim(Str(Int((nCount*100)/nLenReg)))+"% concluído")
	
	
	    _cObserva  := MSMM(QRYFIL->OBS,,,,3) 
	    
		If Len(AllTrim(_cObserva)) <= 200
		   _cObs1 := _cObserva
		ElseIf Len(AllTrim(_cObserva)) > 200 .and. Len(AllTrim(_cObserva)) <= 400
		   _cObs1 := Subs(_cObserva,1,200)
		   _cObs2 := Subs(_cObserva,201,Len(AllTrim(_cObserva))-201)
		ElseIf Len(AllTrim(_cObserva)) > 400 .and. Len(AllTrim(_cObserva)) <= 600
		   _cObs1 := Subs(_cObserva,1,200)
		   _cObs2 := Subs(_cObserva,201,Len(AllTrim(_cObserva))-201)
		   _cObs3 := Subs(_cObserva,401,Len(AllTrim(_cObserva))-401)
		ElseIf Len(AllTrim(_cObserva)) > 600 .and. Len(AllTrim(_cObserva)) <= 800
		   _cObs1 := Subs(_cObserva,1,200)
		   _cObs2 := Subs(_cObserva,201,Len(AllTrim(_cObserva))-201)
		   _cObs3 := Subs(_cObserva,401,Len(AllTrim(_cObserva))-401)
		   _cObs4 := Subs(_cObserva,601,Len(AllTrim(_cObserva))-601)
		ElseIf Len(AllTrim(_cObserva)) > 800
		   _cObs1 := Subs(_cObserva,1,200)
		   _cObs2 := Subs(_cObserva,201,Len(AllTrim(_cObserva))-201)
		   _cObs3 := Subs(_cObserva,401,Len(AllTrim(_cObserva))-401)
		   _cObs4 := Subs(_cObserva,601,Len(AllTrim(_cObserva))-601)
		   _cObs5 := Subs(_cObserva,801,Len(AllTrim(_cObserva))-801)
		EndIf		
	
		aAdd(aCols 	 , {QRYFIL->CODIGO,;
						QRYFIL->PRODUTO,;
	                	QRYFIL->UM,;
		                QRYFIL->ALTERADO,;
		                Transform(QRYFIL->LISTA		,"@E 999,999.9999"),;
		                Transform(QRYFIL->C			,"@E 999,999.9999"),;
		                Transform(QRYFIL->D			,"@E 999,999.9999"),;  
		                Transform(QRYFIL->PROMOCAO	,"@E 999,999.9999"),;
		                U_DIPSALDSB2(QRYFIL->CODIGO,.T.,''),;
		                QRYFIL->MENSAGEM,;
		                _cObs1,;
		                _cObs2,;
		                _cObs3,;
		                _cObs4,;
		                _cObs5} )
	    
		QRYFIL->(dbSkip())
	EndDo                  
	
	If Type("oBrowse")<>"U"           
		aSort(aCols,,,{|x,y| x[2]<y[2]})  
		oBrowse:SetArray(aCols)
		oBrowse:ResetLen()
		oBrowse:GoTop()
		oBrowse:bLine := {||{ aCols[oBrowse:nAt,01],;
	                   		  aCols[oBrowse:nAt,02],;
	                      	  aCols[oBrowse:nAt,03],;
		                      aCols[oBrowse:nAt,04],;
		                      aCols[oBrowse:nAt,05],;
	    	                  aCols[oBrowse:nAt,06],;
	        	              aCols[oBrowse:nAt,07],;
	            	          aCols[oBrowse:nAt,08],;
	                	      aCols[oBrowse:nAt,09],;
		                      aCols[oBrowse:nAt,10],;
		                      aCols[oBrowse:nAt,11],;
	    	                  aCols[oBrowse:nAt,12],;
	        	              aCols[oBrowse:nAt,13],;
	            	          aCols[oBrowse:nAt,14],;
	                	      aCols[oBrowse:nAt,15]}}                            
		oBrowse:Refresh()  
	EndIf
Else
	MsgStop("Dados não encontrados")
EndIf
QRYFIL->(dbCloseArea())

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DIPLISREP ºAutor  ³Microsiga           º Data ³  11/18/16   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ExpLista(aCols)   
Local _aStrut  	:= {}
Local _cArqTrb 	:= ""
Local _cChave  	:= ""                       
Local nI       	:= 0   
Local cArqExcell:= "\Excell-DBF\Lista_"+DtoS(Date())+"_"+StrTran(Time(),":","")
Local cDestino 	:= "C:\EXCELL-DBF\" 
Local aTamSX3 	:= {}  
Local aTmpDir   := {}
DEFAULT aCols  	:= {}

If Len(aCols) > 0
		
	_aTamSX3 := TamSX3("B1_COD")
	aAdd(_aStrut ,{"CODIGO","C",_aTamSX3[1],_aTamSX3[2]})
	_aTamSX3 := TamSX3("B1_DESC")
	aAdd(_aStrut ,{"PRODUTO","C",_aTamSX3[1],_aTamSX3[2]})
	_aTamSX3 := TamSX3("B1_UM")
	aAdd(_aStrut ,{"UM","C",_aTamSX3[1],_aTamSX3[2]})
	_aTamSX3 := TamSX3("B1_ALTPREC")
	aAdd(_aStrut ,{"ALTERADO","D",_aTamSX3[1],_aTamSX3[2]})
	_aTamSX3 := TamSX3("B1_PRV1")
	aAdd(_aStrut ,{"LISTA","N",_aTamSX3[1],_aTamSX3[2]})
	_aTamSX3 := TamSX3("B1_PRVMINI")
	aAdd(_aStrut ,{"C","N",_aTamSX3[1],_aTamSX3[2]})
	_aTamSX3 := TamSX3("B1_PRVPROM")
	aAdd(_aStrut ,{"D","N",_aTamSX3[1],_aTamSX3[2]})
	_aTamSX3 := TamSX3("B1_PRV1")
	aAdd(_aStrut ,{"PROMOCAO","N",_aTamSX3[1],_aTamSX3[2]})
	_aTamSX3 := TamSX3("B2_QATU")
	aAdd(_aStrut ,{"ESTOQUE","N",_aTamSX3[1],_aTamSX3[2]})
	_aTamSX3 := TamSX3("B1_MEN_HAB")
	aAdd(_aStrut ,{"MENSAGEM","C",_aTamSX3[1],_aTamSX3[2]})
	aAdd(_aStrut ,{"OBS1","C",200,0})
	aAdd(_aStrut ,{"OBS2","C",200,0})
	aAdd(_aStrut ,{"OBS3","C",200,0})
	aAdd(_aStrut ,{"OBS4","C",200,0})
	aAdd(_aStrut ,{"OBS5","C",200,0})
	
	_cArqTrb := CriaTrab(_aStrut,.T.)
	DbUseArea(.T.,,_cArqTrb,"TRBREL",.F.,.F.)
	
	_cChave  := 'PRODUTO'
	IndRegua("TRBREL",_cArqTrb,_cChave,,,"Criando Indice...")
	
	For nI:=1 to Len(aCols)
	
	    TRBREL->(RecLock("TRBREL",.T.))
			TRBREL->CODIGO     := aCols[nI,01]
			TRBREL->PRODUTO    := aCols[nI,02]
			TRBREL->UM         := aCols[nI,03]
			TRBREL->ALTERADO   := aCols[nI,04]
			TRBREL->LISTA      := Val(StrTran(StrTran(aCols[nI,05],".",""),",","."))
			TRBREL->C          := Val(StrTran(StrTran(aCols[nI,06],".",""),",","."))
			TRBREL->D          := Val(StrTran(StrTran(aCols[nI,07],".",""),",","."))
			TRBREL->PROMOCAO   := Val(StrTran(StrTran(aCols[nI,08],".",""),",","."))
		    TRBREL->ESTOQUE    := aCols[nI,09]
		    TRBREL->MENSAGEM   := aCols[nI,10]
		   	TRBREL->OBS1 	   := aCols[nI,11]
		   	TRBREL->OBS2	   := aCols[nI,12]
		   	TRBREL->OBS3 	   := aCols[nI,13]
		   	TRBREL->OBS4 	   := aCols[nI,14]
			TRBREL->OBS5 	   := aCols[nI,15]
		TRBREL->(MsUnLock())	
		
	Next nI
	
	DbSelectArea("TRBREL")	
	COPY TO &cArqExcell VIA "DBFCDX"          
	
	FRename(cArqExcell+".dtc",cArqExcell+".xls")
	
	MakeDir(cDestino)
	CpyS2T(cArqExcell+".xls",cDestino,.T.)
	//CpyS2TW(cArqExcell+".xls",.T.)
	
	aTmpDir := Directory( cDestino+"*.tmp" )
	For nI:= 1 to Len(aTmpDir)
		fErase(cDestino+aTmpDir[nI,1])
	Next nI 
	TRBREL->(dbCloseArea())
	
	u_GDToExcel(_aStrut,aCols,Alltrim(FunName()))
	
Else 
	MsgStop("Não existem dados para download")
EndIf                     

Return      
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DIPLISREP ºAutor  ³Microsiga           º Data ³  11/24/16   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function DipVldChv()
Local lRet 	  := .F.
Local cHora	  := SubStr(Time(),1,2)
Local cMinuto := SubStr(Time(),4,2)
Local nDia    := Day(Date())      
Local cChave  := ""                  
Local nMult   := 1
Local cTexto  := Space(15)   
Local nOpcao  := 0
           
oDlg := MSDialog():New(0,0,100,350,"Chave de Acesso",,,.F.,,,,,,.T.,,,.T. )
oDlg:bInit := {||EnchoiceBar(oDlg,{|| (nOpcao := 1,oDlg:End())},{|| (nOpcao := 0,oDlg:End())},,)}
	oSay :=	TSay():New(39,15,{|| OemToAnsi("Chave: ")},oDlg,,,,,, .T.,,, 250,100,,,,,,)
	oGet := TGet():New(37,35,{|u| IIf(PCount()>0,cTexto:=u,cTexto)},oDlg,130,009,"@!",,,,,,,.T.,,,,,,,,,,"cTexto",,,, )	
oDlg:Activate(,,,.T.)	          

If nOpcao == 1   
	Do Case 
		Case cMinuto <= "05"
			cChave +=  "U"
			nMult  := 5
		Case cMinuto <= "15"
			cChave +=  "I"
			nMult  := 15
		Case cMinuto <= "25"
			cChave +=  "S"
			nMult  := 25
		Case cMinuto <= "35"
			cChave +=  "N"
			nMult  := 35
		Case cMinuto <= "45"
			cChave +=  "P"
			nMult  := 45
		Case cMinuto <= "55"
			cChave +=  "F"
			nMult  := 55
		Case cMinuto <= "59"
			cChave +=  "O"
			nMult  := 59
	End Do
	
	Do Case 
		Case cHora <= "04"
			cChave +=  "T"
		Case cHora <= "08"
			cChave +=  "B"
		Case cHora <= "12"
			cChave +=  "C"
		Case cHora <= "16"
			cChave +=  "R"
		Case cHora <= "20"
			cChave +=  "J"
		Case cHora <= "23"
			cChave +=  "K"
	End Do	  
		
	Do Case 
		Case cMinuto <= "10"
			cChave +=  "X"
			nMult  := 10
		Case cMinuto <= "20"
			cChave +=  "Q"
			nMult  := 20
		Case cMinuto <= "30"
			cChave +=  "L"
			nMult  := 30
		Case cMinuto <= "40"
			cChave +=  "H"
			nMult  := 40
		Case cMinuto <= "50"
			cChave +=  "E"
			nMult  := 50
		Case cMinuto <= "60"
			cChave +=  "W"
			nMult  := 60
	End Do
	
	Do Case 
		Case nDia <= 5
			cChave +=  "A"
		Case nDia <= 10
			cChave +=  "Z"
		Case nDia <= 15
			cChave +=  "D"
		Case nDia <= 20
			cChave +=  "G"
		Case nDia <= 25
			cChave +=  "M"
		Case nDia <= 31
			cChave +=  "Y"
	End Do
	
	cChave += AllTrim(Str(Val(cHora)*nDia+nMult))
	cChave += AllTrim(Str(Val(cHora)+nDia*nMult))
	
	If AllTrim(cTexto) == cChave
		lRet := .T.
	Else
		MsgStop("A chave digitada não confere. "+CHR(10)+CHR(13)+"Atualize <F5> a página do site Dipromed para gerar um novo código e tente novamente.")
	EndIf	
Else
	MsgStop("Operação cancelada pelo usuário.")
EndIf
                     
Return lRet
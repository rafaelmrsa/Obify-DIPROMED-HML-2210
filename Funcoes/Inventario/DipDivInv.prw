#INCLUDE 'PROTHEUS.CH' 
#INCLUDE 'RWMAKE.CH'
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDIPINVENT บAutor  ณMicrosiga           บ Data ณ  01/17/13   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function DipDivInv()
Local aAreaCBA  := CBA->(GetArea())
Local cSQL 		:= ""                                            
Local aLogSB2 	:= {}
Local nPos		:= 0
Local cPerg     := "DIPINV14"
Local nLin		:= 0
Local nI 		:= 0
Local lFlag		:= .F.
Local nPerc 	:= 0	
Local lTudoOk	:= .F.
Local lDipEle	:= .F.
Local aOk    	:= {}
Local aDiverg	:= {}
Local lPriCon 	:= .T.            
Local lTudoOk 	:= .T.      
Local nCntPro 	:= 0
Local nCntOk	:= 0
Local nCntDiv 	:= 0
Local aPriCon 	:= {}  
Local aRecCBA  	:= {}
Local aRecCBC  	:= {}             
Local aTudoOk	:= {}
Local aDipEle	:= {}

PRIVATE nBar	:= 0
PRIVATE oPrint  := TMSPrinter():New("Inconsist. SB2 X SC9")
PRIVATE titulo 	:= "Inconsist. SB2 X SC9"                         
PRIVATE oFont09 := TFont():New("Arial",9,09,.T.,.F.,5,.T.,5,.T.,.F.)
PRIVATE oFont10 := TFont():New("Arial",9,10,.T.,.F.,5,.T.,5,.T.,.F.)
PRIVATE oFont12 := TFont():New("Arial",9,12,.T.,.F.,5,.T.,5,.T.,.F.)
PRIVATE oFont12n:= TFont():New("Arial",9,12,.T.,.T.,5,.T.,5,.T.,.F.)
PRIVATE oFont15n:= TFont():New("Arial",9,15,.T.,.T.,5,.T.,5,.T.,.F.)
PRIVATE oFont28n:= TFont():New("Arial",9,28,.T.,.T.,5,.T.,5,.T.,.F.)

If !(oPrint:IsPrinterActive())
	oPrint:Setup()
	Return (.F.)
EndIf

oPrint:SetPortrait()

AjustaSX1(cPerg)

If !Pergunte(cPerg)
	Return .F.
EndIf

cTipoRel	:= StrZero(mv_par01,1)
cContagem	:= StrZero(mv_par02,1)
cEndDe		:= mv_par03
cEndAte		:= mv_par04
cOperador	:= mv_par05
lAnalitico	:= (mv_par06==1)
lCompleto	:= (mv_par07==1)
lNaoMosRec	:= (mv_par08==2)
lAtualiza   := (mv_par09==1)

cSQL := " SELECT "
cSQL += " 	CBA_CODINV, CBA_LOCALI, CBA_XCONT1, CBA_XCONT2, R_E_C_N_O_ REC "
cSQL += " 	FROM "
cSQL += 		RetSQLName("CBA")
cSQL += " 		WHERE "
cSQL += " 			CBA_FILIAL = '"+xFilial("CBA")+"' AND " 

If cContagem == '1'
	cSQL += " 		CBA_CONTR  = '1' AND "				
	cSQL += " 		CBA_STATUS = '3' AND "				
	If lNaoMosRec
		cSQL += " 		CBA_AUTREC = '2' AND "				
	EndIf
Else 
	cSQL += " 		CBA_STATUS < '4' AND "
	cSQL += " 		CBA_CONTR = '2' AND "				                                                       
	cSQL += "		CBA_XCONTB = ' ' AND "
EndIf        

If !Empty(cEndDe) .Or. !Empty(cEndAte)
	cSQL += " 		CBA_LOCALI BETWEEN '"+cEndDe+"' AND '"+cEndAte+"' AND "	
EndIf                                                   

If !Empty(cOperador)
	If cContagem=='1'
		cSQL += " 		CBA_XCONT1 = '"+cOperador+"' AND "		
	Else
		cSQL += " 		CBA_XCONT2 = '"+cOperador+"' AND "		
	EndIf
EndIf                                   

cSQL += " 			D_E_L_E_T_ = ' ' "
cSQL += " ORDER BY CBA_LOCALI "

cSQL := ChangeQuery(cSQL)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),"QRYCBA",.T.,.T.)
			
While !QRYCBA->(Eof())    
	                                                                      
	aDadosCab := {	QRYCBA->CBA_CODINV,;
					QRYCBA->CBA_LOCALI,;
					POSICIONE("CB1",1,xFilial("CB1")+QRYCBA->CBA_XCONT1,"CB1_NOME"),;
					POSICIONE("CB1",1,xFilial("CB1")+QRYCBA->CBA_XCONT2,"CB1_NOME")}  
					
	aAdd(aRecCBA,QRYCBA->REC)
	
	cSQL := " SELECT "
	cSQL += " 	*, R_E_C_N_O_ REC  "
	cSQL += " 	FROM "
	cSQL += 		RetSQLName("CBC")
	cSQL += " 		WHERE "
	cSQL += " 			CBC_FILIAL = '"+xFilial("CBC")+"' AND "
	cSQL += " 			CBC_CODINV = '"+QRYCBA->CBA_CODINV+"' AND "
	cSQL += " 			D_E_L_E_T_ = ' ' "
	cSQL += " ORDER BY CBC_NUM "
	cSQL := ChangeQuery(cSQL)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),"QRYCBC",.T.,.T.)
	
	TCSETFIELD("QRYCBC","CBC_QUANT","N",12,4)
	
	cNum := ""
	lPriCon := .T.            
	lTudoOk := .T. 
	lDipEle	:= .F.     
	nCntPro := 0
	nCntOk	:= 0
	nCntDiv := 0
	aPriCon := {}
	aOk		:= {}
	aDiverg := {}
	
	While !QRYCBC->(Eof())                
		
		If cNum <> QRYCBC->CBC_NUM .And. !Empty(cNum) .And. lPriCon
			lPriCon := .F.
		EndIf                  
		
		If cContagem=='1' .Or. !lPriCon
					
			cSQL := "	SELECT "
			cSQL += "		BF_QUANT " 
			cSQL += "		FROM 
			cSQL += 			RetSQLName("SBF") 
			cSQL += "			WHERE       
			cSQL += "				BF_FILIAL  = '"+xFilial("SBF")+"' AND "
			cSQL += "				BF_LOCAL   = '"+QRYCBC->CBC_LOCAL +"' AND "
			cSQL += "				BF_LOCALIZ = '"+QRYCBC->CBC_LOCALI+"' AND "
			cSQL += "				BF_PRODUTO = '"+QRYCBC->CBC_COD   +"' AND "
			cSQL += "				BF_LOTECTL = '"+QRYCBC->CBC_LOTECT+"' AND "
			cSQL += "				BF_QUANT   > 0 AND "     
			cSQL += "				D_E_L_E_T_ = ' ' "
		
			cSQL := ChangeQuery(cSQL)
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),"QRYSBF",.T.,.T.)
			
			TCSETFIELD("QRYSBF","BF_QUANT","N",12,4)
		EndIf        
		
		If cContagem=='1'			       
			nQtdSBF := 0
			If !QRYSBF->(Eof())
				nQtdSBF := QRYSBF->BF_QUANT
			EndIf                                     
			
			Do Case
				Case QRYCBC->CBC_CONTOK == '1'
					nCntOk++
					aAdd(aOk,  {    QRYCBC->CBC_COD,;
									QRYCBC->CBC_LOCAL,;
									QRYCBC->CBC_LOCALI,;
									QRYCBC->CBC_LOTECT,;
									QRYCBC->CBC_QUANT,;
									QRYSBF->BF_QUANT})						
					aAdd(aRecCBC, QRYCBC->REC)									
				Case QRYSBF->BF_QUANT == QRYCBC->CBC_QUANT  //Para garantir comparo o campo CONTOK e as qtds BF e CBC
					nCntOk++
					aAdd(aOk,  {    QRYCBC->CBC_COD,;
									QRYCBC->CBC_LOCAL,;
									QRYCBC->CBC_LOCALI,;
									QRYCBC->CBC_LOTECT,;
									QRYCBC->CBC_QUANT,;
									QRYSBF->BF_QUANT})						
					aAdd(aRecCBC, QRYCBC->REC)
				OtherWise 
					nCntDiv++
					aAdd(aDiverg, { QRYCBC->CBC_COD,;
									QRYCBC->CBC_LOCAL,;
									QRYCBC->CBC_LOCALI,;
									QRYCBC->CBC_LOTECT,;
									QRYCBC->CBC_QUANT,;
									QRYSBF->BF_QUANT})						
					lTudoOk := .F.
			EndCase								

		ElseIf lPriCon              
		
			aAdd(aPriCon, { QRYCBC->CBC_COD,;
							QRYCBC->CBC_LOCAL,;
							QRYCBC->CBC_LOCALI,;
							QRYCBC->CBC_LOTECT,;
							QRYCBC->CBC_QUANT,;
							QRYCBC->CBC_CONTOK})							
							
		Else                                            
			nPos := aScan(aPriCon, {|X| x[1]+x[2]+x[3]+x[4]==QRYCBC->(CBC_COD+CBC_LOCAL+CBC_LOCALI+CBC_LOTECT)})
			
			nQtdSBF := 0
			
			If !QRYSBF->(Eof())			
				nQtdSBF := QRYSBF->BF_QUANT
			EndIf
				
			If nPos > 0                     
			    Do Case
			    	Case aPriCon[nPos,6] == '1' //A primeira bateu com o estoque
						nCntOk++
						aAdd(aOk,	  {	QRYCBC->CBC_COD,;
										QRYCBC->CBC_LOCAL,;
										QRYCBC->CBC_LOCALI,;
										QRYCBC->CBC_LOTECT,;
										aPriCon[nPos,5],;
										"",;										
										nQtdSBF })	
					Case QRYCBC->CBC_QUANT <> QRYCBC->CBC_QTDORI //Qtd Eleita
						lDipEle := .T.
						nCntOk++
						aAdd(aOk,	  {	QRYCBC->CBC_COD,;
										QRYCBC->CBC_LOCAL,;
										QRYCBC->CBC_LOCALI,;
										QRYCBC->CBC_LOTECT,;             
										aPriCon[nPos,5],;
										QRYCBC->CBC_QUANT,;
										nQtdSBF,;
										"E"})	     										                      										
			    	Case QRYCBC->CBC_QUANT==aPriCon[nPos,5] // Duas contagens batidas
						nCntOk++
						aAdd(aOk,	  {	QRYCBC->CBC_COD,;
										QRYCBC->CBC_LOCAL,;
										QRYCBC->CBC_LOCALI,;
										QRYCBC->CBC_LOTECT,;             
										aPriCon[nPos,5],;
										QRYCBC->CBC_QUANT,;
										nQtdSBF })	     
					Case QRYCBC->CBC_QUANT == nQtdSBF //A Segunda bateu com o estoque
						nCntOk++
						aAdd(aOk,	  {	QRYCBC->CBC_COD,;
										QRYCBC->CBC_LOCAL,;
										QRYCBC->CBC_LOCALI,;
										QRYCBC->CBC_LOTECT,;             
										aPriCon[nPos,5],;
										QRYCBC->CBC_QUANT,;
										nQtdSBF })	     
					Otherwise
						lTudoOk := .F.     
						nCntDiv++
						aAdd(aDiverg, { QRYCBC->CBC_COD,;
										QRYCBC->CBC_LOCAL,;
										QRYCBC->CBC_LOCALI,;
										QRYCBC->CBC_LOTECT,;
										aPriCon[nPos,5],;
										QRYCBC->CBC_QUANT,;
										nQtdSBF })
				EndCase
				
			Else 
				If QRYCBC->CBC_QUANT <> QRYCBC->CBC_QTDORI //Qtd Eleita
						lDipEle := .T.
						nCntOk++
						aAdd(aOk, {	QRYCBC->CBC_COD,;
									QRYCBC->CBC_LOCAL,;
									QRYCBC->CBC_LOCALI,;
									QRYCBC->CBC_LOTECT,;             
									0,;
									QRYCBC->CBC_QUANT,;
									nQtdSBF,;
									"E" })	     										                      									                    
				ElseIf QRYCBC->CBC_QUANT == nQtdSBF //A Segunda bateu com o estoque
					nCntOk++
					aAdd(aOk,	  {	QRYCBC->CBC_COD,;
									QRYCBC->CBC_LOCAL,;
									QRYCBC->CBC_LOCALI,;
									QRYCBC->CBC_LOTECT,;
									'0',;
									QRYCBC->CBC_QUANT,;
									nQtdSBF })	       
									
			
				Else
					lTudoOk := .F.     
					nCntDiv++
					aAdd(aDiverg, { QRYCBC->CBC_COD,;
									QRYCBC->CBC_LOCAL,;
									QRYCBC->CBC_LOCALI,;
									QRYCBC->CBC_LOTECT,;
									'0',;
									QRYCBC->CBC_QUANT,;
									nQtdSBF })    
				EndIf
			EndIf
		EndIf           
		
		If cContagem=='1' .Or. !lPriCon
			QRYSBF->(dbCloseArea())		
		EndIf
		
		cNum := QRYCBC->CBC_NUM							
		QRYCBC->(dbSkip())
	EndDo
	QRYCBC->(dbCloseArea())  
    
    nPerc := (nCntOk*100)/(nCntDiv+nCntOk)               
    
    If cContagem=='2' .And. lTudoOk .And. !lDipEle
    	aAdd(aTudoOk, QRYCBA->REC)
    EndIf
	                                                    
    If cContagem=='2' .And. lTudoOk .And. lDipEle
    	aAdd(aDipEle, QRYCBA->REC)
    EndIf

    If cContagem=='1' .And. ((cTipoRel<>'2' .And. !lTudoOk) .Or. (cTipoRel<>'1' .And. lTudoOk))
   		ImpLin(@nLin,aDadosCab,aDiverg,aOk,nPerc)
   	ElseIf cContagem == '2' .And. ((cTipoRel<>'2' .And. !lTudoOk) .Or. (cTipoRel<>'1' .And. lTudoOk))
		ImpLin2(@nLin,aDadosCab,aDiverg,aOk,nPerc)       
	EndIf
        
	QRYCBA->(dbSkip())
EndDo
QRYCBA->(dbCloseArea())                                                                                                             

oPrint:EndPage()             

oPrint:Preview()

MS_FLUSH()                   

If lAtualiza .And. cContagem=='1' .And. Len(aRecCBA)>0
	If Aviso("Aten็ใo","Autoriza recontagem para este(s) endere็o(s)?",{"Sim","Nใo"},1)==1    
		_cOperad := Space(06)
		
		@ 100,150 To 250,530 Dialog oDlg Title OemToAnsi("Informe o Operador da Segunda Contagem.")
		@ 020,020 SAY "Informe o Operador"
		@ 040,020 Say OemToAnsi("C๓digo:") 	Size 040,020
		@ 040,060 Get _cOperad Size 060,020 F3 "DIPCB1" Valid (ExistCpo("CB1") .And. _cOperad<>cOperador)
		@ 055,100 BmpButton Type 1 Action (_nOpca:=1,Close(oDlg))
		@ 055,130 BmpButton Type 2 Action (_nOpca:=2,Close(oDlg))
		Activate Dialog oDlg Centered
		
		If _nOpca==1 .And. !Empty(_cOperad)	
			For nI:=1 to Len(aRecCBA)
				CBA->(dbGoTo(aRecCBA[nI]))
				CBA->(RecLock("CBA",.F.))
					CBA->CBA_AUTREC := '1'      
					CBA->CBA_XCONT2 := _cOperad
				CBA->(MsUnLock())
			Next nI              
			          
			For nI:=1 to Len(aRecCBC)     
				CBC->(dbGoTo(aRecCBC[nI]))
				CBC->(RecLock("CBC",.F.))
					CBC->CBC_CONTOK := '1'
				CBC->(MsUnLock())
			Next nI                              
			
			Aviso("Aviso","Opera็ใo realizada com sucesso.",{"Ok"},1)
		Else 
			Aviso("Erro","Opera็ใo cancelada.",{"Ok"},1)
		EndIf
	EndIf
EndIf
    
If Len(aTudoOk)>0
	If lAtualiza .And. Len(aTudoOk)>0 .And. (Aviso("Aten็ใo","Deseja atualizar o campo de duas contagens batidas?",{"Sim","Nใo"},1))==1    
		For nI:=1 to Len(aTudoOk)
			CBA->(dbGoTo(aTudoOk[nI]))
			CBA->(RecLock("CBA",.F.)) 
				CBA->CBA_XCONTB := "OK"				
			CBA->(MsUnLock())
		Next nI
	EndIf
EndIf
	
If Len(aDipEle)>0
	If lAtualiza .And. Len(aDipEle)>0 .And. (Aviso("Aten็ใo","Deseja atualizar a qtd eleita?",{"Sim","Nใo"},1))==1    
		For nI:=1 to Len(aDipEle)
			CBA->(dbGoTo(aDipEle[nI]))
			CBA->(RecLock("CBA",.F.)) 
				CBA->CBA_XCONTB := "E"				
			CBA->(MsUnLock())
		Next nI
	EndIf
EndIf

RestArea(aAreaCBA)

Return     
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDIPINV14  บAutor  ณMicrosiga           บ Data ณ  04/22/14   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ImpLin(nLin,aDadosCab,aDiverg,aOk,nPerc)

	If nLin > 3000  
		oPrint:EndPage()  
		nLin:=0
		oPrint:StartPage()
	ElseIf nLin == 0
		oPrint:StartPage()
	EndIf
	
	If !lAnalitico //Se for sint้tico s๓ imprime uma vez o cabe็alho
		If nLin==0
			nLin := InvtCab(nLin)		
		EndIf
	Else                     
		nLin := InvtCab(nLin)
	EndIf    
	
	oPrint:Say(nLin,0100,aDadosCab[1] 					,oFont12)    //Inventario
	If lCompleto
		oPrint:Say(nLin,0400,Transform(nPerc,"@E 999")+"%"	,oFont12)    //Percentual
	EndIf
	oPrint:Say(nLin,0650,aDadosCab[2] 					,oFont12)    //Endere็o
	If lCompleto
		oPrint:Say(nLin,1000,PadR(aDadosCab[3],20) 			,oFont12)    //Contador 1
	EndIf
   
	If lAnalitico
		nLin+=50
		If Len(aDiverg)>0 .Or. Len(aOk)>0
			nLin:=InvtCab2(nLin)	
		EndIf
				
        If cTipoRel<>'1'
			For nI:=1 To Len(aOk)	
				oPrint:Say(nLin,0800,aOk[nI,1] 		  			  		 	,oFont12)     //Codigo
				oPrint:Say(nLin,1000,aOk[nI,4]					  		 	,oFont12)     //Lote
				If lCompleto
					oPrint:Say(nLin,1300,Transform(aOk[nI,6],"@E 99999999")	,oFont12)  	  //Quant SBF
					oPrint:Say(nLin,1600,Transform(aOk[nI,5],"@E 99999999")	,oFont12) 	  //Quant CBC
					If Len(aOk[nI])>7 .And. aOk[nI,8]=="E"                                                                    
						oPrint:Say(nLin,1900,"E"								,oFont12)  	  //Ok
					Else
						oPrint:Say(nLin,1900,"Ok"								,oFont12)  	  //Ok
					EndIF
				EndIf
				nLin+=50
			Next nI			
		EndIf
				       
		If cTipoRel <> '2'		
			For nI:=1 To Len(aDiverg)	
				oPrint:Say(nLin,0800,aDiverg[nI,1] 		  		 			   ,oFont12)   //Codigo
				oPrint:Say(nLin,1000,aDiverg[nI,4]				 			   ,oFont12)   //Lote
				If lCompleto
					oPrint:Say(nLin,1300,Transform(aDiverg[nI,6],"@E 99999999"),oFont12)   //Quant SBF
					oPrint:Say(nLin,1600,Transform(aDiverg[nI,5],"@E 99999999"),oFont12)   //Quant CBC
					oPrint:Say(nLin,1900,"X"								   ,oFont12)   //Ok
				EndIf
				nLin+=50
			Next nI		
		EndIf
	EndIf
	
	nLin+=50			
		
	If nLin > 3000  
		oPrint:EndPage()
		nLin := 0
		oPrint:StartPage()
	EndIf

Return .T.
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDIPINV14  บAutor  ณMicrosiga           บ Data ณ  04/22/14   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ImpLin2(nLin,aDadosCab,aDiverg,aOk,nPerc)

	If nLin > 3000  
		oPrint:EndPage()
		nLin:=0
		oPrint:StartPage()
	ElseIf nLin == 0
		oPrint:StartPage()
	EndIf
	
	If !lAnalitico //Se for sint้tico s๓ imprime uma vez o cabe็alho
		If nLin==0
			nLin := InvtCab(nLin)		
		EndIf
	Else                     
		nLin := InvtCab(nLin)
	EndIf    
	
	oPrint:Say(nLin,0100,aDadosCab[1] ,oFont12)    //Inventario
	If lCompleto
		oPrint:Say(nLin,0400,Transform(nPerc,"@E 999")+"%",oFont12)    //Percentual
	EndIf
	oPrint:Say(nLin,0650,aDadosCab[2] 			,oFont12)    //Endere็o
	If lCompleto
		oPrint:Say(nLin,1000,PadR(aDadosCab[3],20)  ,oFont12)    //Contador 1
		oPrint:Say(nLin,1600,PadR(aDadosCab[4],20)  ,oFont12)    //Contador 2
	EndIf
   
	If lAnalitico
		nLin+=50
		If Len(aDiverg)>0 .Or. Len(aOk)>0
			nLin:=InvtCab3(nLin)	
		EndIf
		If cTipoRel<>'1'
			For nI:=1 To Len(aOk)	        	
				oPrint:Say(nLin,0800,aOk[nI,1] 		  				 	,oFont12)     //Codigo
				oPrint:Say(nLin,1000,aOk[nI,4]						 	,oFont12)     //Lote
				oPrint:Say(nLin,1300,Transform(aOk[nI,7],"@E 99999999")	,oFont12)  	  //Quant SBF
				oPrint:Say(nLin,1550,Transform(aOk[nI,5],"@E 99999999")	,oFont12) 	  //Primeira Cont
				oPrint:Say(nLin,1800,Transform(aOk[nI,6],"@E 99999999")	,oFont12)  	  //Segunda Cont
				If Len(aOk[nI])>7 .And. aOk[nI,8]=="E"
					oPrint:Say(nLin,2050,"E"								,oFont12)  	  //Ok
				Else
					oPrint:Say(nLin,2050,"Ok"								,oFont12)  	  //Ok
				EndIF				
				nLin+=50
			Next nI			
	    EndIf
	    If cTipoRel<>'2'
			For nI:=1 To Len(aDiverg)	
				oPrint:Say(nLin,0800,aDiverg[nI,1] 		  				   ,oFont12)   //Codigo
				oPrint:Say(nLin,1000,aDiverg[nI,4]						   ,oFont12)   //Lote
				oPrint:Say(nLin,1300,Transform(aDiverg[nI,7],"@E 99999999"),oFont12)   //Quant SBF
				oPrint:Say(nLin,1550,Transform(aDiverg[nI,5],"@E 99999999"),oFont12)   //Primeira Cont
				oPrint:Say(nLin,1800,Transform(aDiverg[nI,6],"@E 99999999"),oFont12)   //Segunda Cont
				oPrint:Say(nLin,2050,"X"								   ,oFont12)   //Ok
				nLin+=50
			Next nI		
		EndIf
	EndIf
	
	nLin+=50			
		
	If nLin > 3000  
		oPrint:EndPage()
		nLin := 0
		oPrint:StartPage()
	EndIf

Return .T.
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDIPINVENT บAutor  ณMicrosiga           บ Data ณ  01/17/13   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function InvtCab(nLin)              
DEFAULT nLin := 0

If nLin == 0
	nLin :=100
	oPrint:Line(nLin,0100,nLin,2200) 	

	nLin+=10	
	oPrint:Say(nLin,0800,"### INVENTARIOS DIVERGENTES ###"	   		,oFont15n)    //Codigo do produto
	nLin+=60
	
	oPrint:Line(nLin,0100,nLin,2200) 	
	nLin+=100		
EndIf
	

oPrint:Say(nLin,0100,"INVENTARIO"	,oFont12n)    //Codigo do produto

If lCompleto
	oPrint:Say(nLin,0400,"ACERTO"  		,oFont12n)    //Local
EndIf

oPrint:Say(nLin,0650,"ENDEREวO"		,oFont12n)    //Qtd a Classf.

If lCompleto
	oPrint:Say(nLin,1000,"CONTADOR 1."	,oFont12n)    //Qtd a Classf.                    
EndIf

If cContagem=='2' .And. lCompleto
	oPrint:Say(nLin,1600,"CONTADOR 2"	,oFont12n)    //QPedVen (Saldo SC9)
EndIf

nLin+=50
oPrint:Line(nLin,0100,nLin,2200) 
nLin+=10

Return nLIn
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDIPINVENT บAutor  ณMicrosiga           บ Data ณ  01/17/13   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function InvtCab2(nLin)
DEFAULT nLin := 0

nLin+=10
oPrint:Say(nLin,0800,"PROD."	  	,oFont12n)
oPrint:Say(nLin,1000,"LOTE"			,oFont12n)

If lCompleto
	oPrint:Say(nLin,1300,"QTD EST."		,oFont12n)
	oPrint:Say(nLin,1600,"QTD CONT."	,oFont12n)
	oPrint:Say(nLin,1900,"STATUS"		,oFont12n)
EndIf

nLin+=50
oPrint:Line(nLin,0800,nLin,2200) 
nLin+=10

Return nLin
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDIPINVENT บAutor  ณMicrosiga           บ Data ณ  01/17/13   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function InvtCab3(nLin)
DEFAULT nLin := 0

nLin+=10
oPrint:Say(nLin,0800,"PROD."	  	,oFont12n)
oPrint:Say(nLin,1000,"LOTE"			,oFont12n)
oPrint:Say(nLin,1300,"QTD EST."		,oFont12n)
oPrint:Say(nLin,1550,"QTD PRI."		,oFont12n)
oPrint:Say(nLin,1800,"QTD SEG."		,oFont12n)
oPrint:Say(nLin,2050,"STATUS"		,oFont12n)

nLin+=50
oPrint:Line(nLin,0800,nLin,2200) 
nLin+=10

Return nLin
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDIPR099   บAutor  ณMicrosiga           บ Data ณ  10/08/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function AjustaSX1(cPerg)
Local aRegs 	:= {}
DEFAULT cPerg 	:= ""

dbSelectArea("SX1")
dbSetOrder(1)                                                                                                                                                                       

aAdd(aRegs,{cPerg,"01","Tipo        ?","","","mv_ch1","N",01,0,0,"C","","MV_PAR01","Divergencia" ,"","","","","Ok"		,"","","","","Ambos","","","","","","","","","","","","","",''		})
aAdd(aRegs,{cPerg,"02","Contagem    ?","","","mv_ch2","N",01,0,0,"C","","MV_PAR02","Primeira"	 ,"","","","","Segunda"	,"","","","",""		,"","","","","","","","","","","","","",''		})
aAdd(aRegs,{cPerg,"03","Endere็o De ?","","","mv_ch3","C",15,0,0,"G","","MV_PAR03",""			 ,"","","","",""		,"","","","",""		,"","","","","","","","","","","","","",''		})
aAdd(aRegs,{cPerg,"04","Endere็o At้?","","","mv_ch4","C",15,0,0,"G","","MV_PAR04",""			 ,"","","","",""		,"","","","",""		,"","","","","","","","","","","","","",''		})
aAdd(aRegs,{cPerg,"05","Operador    ?","","","mv_ch5","C",06,0,0,"G","","MV_PAR05",""			 ,"","","","",""		,"","","","",""		,"","","","","","","","","","","","","",'DIPCB1'})
aAdd(aRegs,{cPerg,"06","Analitico   ?","","","mv_ch6","N",01,0,0,"C","","MV_PAR06","Sim"		 ,"","","","","Nใo"		,"","","","",""		,"","","","","","","","","","","","","",''		})
aAdd(aRegs,{cPerg,"07","Completo    ?","","","mv_ch7","N",01,0,0,"C","","MV_PAR07","Sim"		 ,"","","","","Nใo"		,"","","","",""		,"","","","","","","","","","","","","",''		})
aAdd(aRegs,{cPerg,"08","Recont. Aut.?","","","mv_ch8","N",01,0,0,"C","","MV_PAR08","Mostra"		 ,"","","","","ั mostra","","","","",""		,"","","","","","","","","","","","","",''		})
aAdd(aRegs,{cPerg,"09","Atual. Dados?","","","mv_ch9","N",01,0,0,"C","","MV_PAR09","Sim"		 ,"","","","","Nใo"		,"","","","",""		,"","","","","","","","","","","","","",''		})

PlsVldPerg( aRegs )       

Return
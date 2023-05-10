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
User Function DipInEnd()
Local aAreaCBA  := CBA->(GetArea())
Local cSQL 		:= ""                                            
Local aLogSB2 	:= {}
Local nPos		:= 0
Local cPerg     := "DIPINVEN"
Local nLin		:= 0
Local nI 		:= 0
Local lFlag		:= .F.
Local nPerc1 	:= 0	
Local nPerc2 	:= 0	
Local lTudoOk	:= .F.
Local aOk    	:= {}
Local aDiverg	:= {}
Local lPriCon 	:= .T.            
Local lTudoOk 	:= .T.      
Local nCntPro 	:= 0
Local nCntOk	:= 0
Local nCntOk1	:= 0
Local nCntOk2	:= 0
Local nCntDiv 	:= 0
Local nCntDiv1 	:= 0
Local nCntDiv2 	:= 0
Local aPriCon 	:= {}  
Local aRecCBA  	:= {}
Local aRecCBC  	:= {}             
Local aTudoOk	:= {}
Local dDtInvet  := StoD("")                       

PRIVATE nBar	:= 0
PRIVATE oPrint  := TMSPrinter():New("Inventแrio X Endere็os")
PRIVATE titulo 	:= "Inventแrio X Endere็os"                      
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

cEndDe		:= mv_par01
cEndAte		:= mv_par02
cOperador	:= mv_par03
dDtInvent   := mv_par04

cSQL := " SELECT "
cSQL += " 	CBA_CODINV, CBA_LOCALI, CBA_XCONT1, CBA_XCONT2, CBA_STATUS, CBA_CONTR, CBA_AUTREC, CBA_XCONTB, R_E_C_N_O_ REC "
cSQL += " 	FROM "
cSQL += 		RetSQLName("CBA")
cSQL += " 		WHERE "
cSQL += " 			CBA_FILIAL = '"+xFilial("CBA")+"' AND " 
cSQL += "			CBA_DATA = '"+DtoS(dDtInvent)+"' AND "

If !Empty(cEndDe) .Or. !Empty(cEndAte)
	cSQL += " 		CBA_LOCALI BETWEEN '"+cEndDe+"' AND '"+cEndAte+"' AND "	
EndIf                                                   

If !Empty(cOperador)
	cSQL += " 	   (CBA_XCONT1 = '"+cOperador+"' OR "		
	cSQL += " 		CBA_XCONT2 = '"+cOperador+"') AND "		
EndIf                                   

cSQL += " 			D_E_L_E_T_ = ' ' "  
cSQL += " ORDER BY CBA_STATUS "

cSQL := ChangeQuery(cSQL)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),"QRYCBA",.T.,.T.)
			
While !QRYCBA->(Eof())    
	                                                                      
	aDadosCab := {	QRYCBA->CBA_CODINV,;
					QRYCBA->CBA_LOCALI,;
					POSICIONE("CB1",1,xFilial("CB1")+QRYCBA->CBA_XCONT1,"CB1_NOME"),;
					POSICIONE("CB1",1,xFilial("CB1")+QRYCBA->CBA_XCONT2,"CB1_NOME"),;
					QRYCBA->CBA_STATUS}  
					
	                                                        
	ImpLin2(@nLin,aDadosCab)
        
	QRYCBA->(dbSkip())
EndDo
QRYCBA->(dbCloseArea())                                                                                                             

oPrint:EndPage()             

oPrint:Preview()

MS_FLUSH()                   

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
Static Function ImpLin2(nLin,aDadosCab,aDiverg,aOk,nPerc1,nPerc2)

	If nLin > 3200  
		oPrint:EndPage()    
		nLin := 0
		oPrint:StartPage()
	ElseIf nLin == 0
		oPrint:StartPage()
	EndIf
	

	If nLin==0
		nLin := InvtCab(nLin)		
	EndIf
	
	oPrint:Say(nLin,0100,aDadosCab[1] 									,oFont12)
	oPrint:Say(nLin,0400,aDadosCab[2] 									,oFont12)
	oPrint:Say(nLin,0600,ConvStat(aDadosCab[5],QRYCBA->CBA_CONTR,'1')	,oFont12)
	oPrint:Say(nLin,0850,PadR(aDadosCab[3],20)  						,oFont12)

	If QRYCBA->CBA_CONTR >= 1
		oPrint:Say(nLin,1400,ConvStat(aDadosCab[5],QRYCBA->CBA_CONTR,'2',QRYCBA->CBA_XCONTB)		,oFont12)
	EndIf                                                               
	
	oPrint:Say(nLin,1650,PadR(aDadosCab[4],20)  		,oFont12)
   	
	nLin+=50			
		
	If nLin > 3200  
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

oPrint:Say(nLin,0100,"INVENTARIO"	,oFont12n)
oPrint:Say(nLin,0400,"ENDER." 		,oFont12n)

oPrint:Say(nLin,0600,"STATUS 1"		,oFont12n)
oPrint:Say(nLin,0850,"CONTADOR 1"	,oFont12n)

oPrint:Say(nLin,1400,"STATUS 2"		,oFont12n)
oPrint:Say(nLin,1650,"CONTADOR 2"	,oFont12n)

nLin+=50
oPrint:Line(nLin,0100,nLin,2200) 
nLin+=10

Return nLIn
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

aAdd(aRegs,{cPerg,"01","Endere็o De ?","","","mv_ch1","C",15,0,0,"G","","MV_PAR01",""			 ,"","","","",""		,"","","","",""		,"","","","","","","","","","","","","",''		})
aAdd(aRegs,{cPerg,"02","Endere็o At้?","","","mv_ch2","C",15,0,0,"G","","MV_PAR02",""			 ,"","","","",""		,"","","","",""		,"","","","","","","","","","","","","",''		})
aAdd(aRegs,{cPerg,"03","Operador    ?","","","mv_ch3","C",06,0,0,"G","","MV_PAR03",""			 ,"","","","",""		,"","","","",""		,"","","","","","","","","","","","","",'DIPCB1'})
aAdd(aRegs,{cPerg,"04","Dt.Inventar.?","","","mv_ch4","D",08,0,0,"G","","MV_PAR04",""			 ,"","","","",""		,"","","","",""		,"","","","","","","","","","","","","",''		})

PlsVldPerg( aRegs )       

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDIPINEND  บAutor  ณMicrosiga           บ Data ณ  04/28/14   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ConvStat(cStatus,nCont,cCont,cOk)
DEFAULT cStatus := ""                           
DEFAULT cOk		:= ""

If cCont == '1'                                                           
	If nCont==0
		Do Case
			Case cStatus=='0'
				cStatus := "ั Inic."
			Case cStatus=='1'
				cStatus := "Em Andam."
			Case cStatus=='2'
				cStatus := "Pausa"  
			Case cStatus=='6'
				cStatus := "S/Saldo"  				
			OtherWise
				cStatus := "Desconh"
		End Case
	ElseIf nCont==1
		Do Case                     
			Case cStatus=='1'
				cStatus := "Contado"
			Case cStatus=='2'
				cStatus := "Contado"  
			Case cStatus=='3'
				cStatus := "Contado"
			Case cStatus=='4'
				cStatus := "Finaliz."  		
			Case cStatus=='5'
				cStatus := "Process." 
			Case cStatus=='6'
				cStatus := "S/Saldo"
			OtherWise
				cStatus := "Desconh"
		End Case	
	ElseIf nCont==2
		cStatus := "Contado"	
	EndIf	
Else 
	If nCont==1
		Do Case                     
			Case cStatus=='1'
				cStatus := "Em Andam."
			Case cStatus=='2'
				cStatus := "Pausa"  
			Case cStatus=='3'
				cStatus := "ั Inic."
			OtherWise
				cStatus := ""
		End Case	
	ElseIf nCont==2
		Do Case      
			Case cOk=='OK'
				cStatus := "Cont.Bat"
			Case cStatus=='3'
				cStatus := "Contado"
			Case cStatus=='4'
				cStatus := "Finaliz"  		
			Case cStatus=='5'
				cStatus := "Process." 
			Case cStatus=='6'
				cStatus := "S/Saldo"
			OtherWise
				cStatus := "Desconh"
		End Case	
	Else 
		cStatus := "Contado"
	EndIf	
EndIf	

Return cStatus
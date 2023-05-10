#INCLUDE 'PROTHEUS.CH' 
#INCLUDE 'RWMAKE.CH'
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDIPR080   บAutor  ณMicrosiga           บ Data ณ  01/17/13   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function DIPR080()
Local cSQL 		:= ""                                            
Local cPerg     := "DIPR080"
Local nLin		:= 0   
Local nTotEst	:= 0

Private nTotCus := 0
Private nTotUPR	:= 0
Private nTotal  := 0

PRIVATE oPrint  := TMSPrinter():New("Margem do Or็amento")
PRIVATE titulo 	:= "Margem do Or็amento"  
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

oPrint:SetLandScape()

AjustaSX1(cPerg)

If !Pergunte(cPerg,.T.)
	Return
EndIf                    

cSQL := " SELECT "
cSQL += "	* " 
cSQL += "	FROM "
cSQL += 		RetSQLName("SC6")
cSQL += "		WHERE "
cSQL += "			C6_FILIAL = '"+xFilial("SC5")+"' AND "
cSQL += "			C6_NUM = '"+MV_PAR01+"' AND "
cSQL += "			C6_TIPODIP = '2' AND "
cSQL += "			D_E_L_E_T_ = ' ' "

cSQL := ChangeQuery(cSQL)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),"QRYSC6",.T.,.T.)

While !QRYSC6->(Eof())     
    
	If nLin > 2200  
		oPrint:EndPage()  
		nLin:=0
		oPrint:StartPage()
	ElseIf nLin == 0
		oPrint:StartPage()
	EndIf
	
	If nLin==0
		nLin := DipCab(nLin)		
	EndIf
	
	nTotEst := DipRetEst(QRYSC6->C6_PRODUTO)                                                                         
	                                                                         
	oPrint:Say(nLin,0100,QRYSC6->C6_PRODUTO				   		   						,oFont12)
	oPrint:Say(nLin,0250,QRYSC6->C6_DESCRI							  					,oFont12)
	oPrint:Say(nLin,1600,Transform(QRYSC6->C6_QTDVEN				,"@E 99999999") 	,oFont12)
	oPrint:Say(nLin,1800,Transform(QRYSC6->C6_CUSDIP				,"@E 99,999,999.99"),oFont12)
	oPrint:Say(nLin,2000,Transform(QRYSC6->(C6_QTDVEN*C6_CUSDIP)	,"@E 99,999,999.99"),oFont12)
	oPrint:Say(nLin,2200,Transform(QRYSC6->C6_LISFOR				,"@E 99,999,999.99"),oFont12)
	oPrint:Say(nLin,2400,Transform(QRYSC6->(C6_QTDVEN*C6_LISFOR)	,"@E 99,999,999.99"),oFont12)
	oPrint:Say(nLin,2600,Transform(QRYSC6->C6_PRCVEN				,"@E 99,999,999.99"),oFont12)
	oPrint:Say(nLin,2800,Transform(QRYSC6->(C6_QTDVEN*C6_PRCVEN)	,"@E 99,999,999.99"),oFont12)
	oPrint:Say(nLin,3000,PADR(Transform(nTotEst						,"@E 9999999999"),10)	,oFont12)
		
	nTotCus += QRYSC6->(C6_QTDVEN*C6_CUSDIP)
	nTotUPR	+= QRYSC6->(C6_QTDVEN*C6_LISFOR)	
	nTotal  += QRYSC6->(C6_QTDVEN*C6_PRCVEN)
	
	nLin += 50   
	                                                                      
	QRYSC6->(dbSkip())
EndDo
QRYSC6->(dbCloseArea())                                                                                                             
         
If nLin+250 > 2200  
	oPrint:EndPage()  
	nLin:=0
	oPrint:StartPage()
ElseIf nLin == 0
	oPrint:StartPage()
EndIf

DipRoda(nLin)		

oPrint:EndPage()             

oPrint:Preview()

MS_FLUSH()                   

Return     
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDIPINVENT บAutor  ณMicrosiga           บ Data ณ  01/17/13   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function DipCab(nLin)              
DEFAULT nLin := 0

If nLin == 0
	nLin :=100
	oPrint:Line(nLin,0100,nLin,3200) 	

	nLin+=10	
	oPrint:Say(nLin,1400,"MARGEM DO ORวAMENTO"   		,oFont15n)    //Codigo do produto
	nLin+=60
	
	oPrint:Line(nLin,0100,nLin,3200) 	
	nLin+=100		
EndIf
	
oPrint:Say(nLin,0100,"COD"			,oFont12n)
oPrint:Say(nLin,0250,"DESCRIวรO"	,oFont12n)
oPrint:Say(nLin,1600,"QTD."			,oFont12n)
oPrint:Say(nLin,1800,"CUSTO" 		,oFont12n)
oPrint:Say(nLin,2000,"TOTAL"		,oFont12n)
oPrint:Say(nLin,2200,"PRC"			,oFont12n)
oPrint:Say(nLin,2400,"TOTAL"		,oFont12n)
oPrint:Say(nLin,2600,"VL VENDA" 	,oFont12n)
oPrint:Say(nLin,2800,"TOTAL"		,oFont12n)
oPrint:Say(nLin,3000,"ESTOQUE"		,oFont12n)

nLin+=50
oPrint:Line(nLin,0100,nLin,3200) 
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
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function DipRoda(nLin)              
DEFAULT nLin := 0

nLin+=50		

oPrint:Line(nLin,0100,nLin,3200) 	

nLin+=10	
oPrint:Say(nLin,1400,"TOTAL GERAL"   	,oFont12n)    //Codigo do produto
oPrint:Say(nLin,2000,"TOTAL CUSTO"		,oFont12n)
oPrint:Say(nLin,2400,"TOTAL PRC"		,oFont12n)
oPrint:Say(nLin,2800,"TOTAL VENDA"		,oFont12n)

nLin+=50
oPrint:Line(nLin,0100,nLin,3200) 	
nLin+=10

oPrint:Say(nLin,2000,TransForm(nTotCus,"@E 99,999,999.99")	,oFont12n)
oPrint:Say(nLin,2400,TransForm(nTotUPR,"@E 99,999,999.99")	,oFont12n)
oPrint:Say(nLin,2800,TransForm(nTotal ,"@E 99,999,999.99")	,oFont12n)

nLin+=50
oPrint:Line(nLin,0100,nLin,3200) 
nLin+=10

oPrint:Say(nLin,1400,"MARGEM PELO CUSTO: "+TransForm(nTotal/nTotCus-1,"@E 99,999,999.99")+" %"	,oFont12n)    //Codigo do produto
nLin+=50
oPrint:Say(nLin,1400,"MARGEM PELO PRC.....: "+TransForm(nTotal/nTotUPR-1,"@E 99,999,999.99")+" %"	,oFont12n)    //Codigo do produto


Return nLIn
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
Static Function DipRetEst(cCodPro)
Local cSQL 	  := ""
Local nQtdAux := 0       

cSQL := " SELECT "
cSQL += " 	(B2_QATU-B2_QEMP-B2_RESERVA) QTD"
cSQL += " 	FROM "
cSQL += " 		SB2010 "
cSQL += " 			WHERE "
cSQL += " 				B2_FILIAL = '"+xFilial("SB2")+"' AND "
cSQL += " 				B2_COD = '"+cCodPro+"' AND "
cSQL += " 				B2_LOCAL = '01' AND "
cSQL += " 				D_E_L_E_T_ = ' ' "

cSQL := ChangeQuery(cSQL)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),"QRYSB2",.T.,.T.)

If !QRYSB2->(Eof())
	nQtdAux := QRYSB2->QTD
EndIf	
QRYSB2->(dbCloseArea())

Return nQtdAux
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

PlsVldPerg( aRegs )       

Return
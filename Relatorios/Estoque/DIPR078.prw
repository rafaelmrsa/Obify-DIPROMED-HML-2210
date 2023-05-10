#INCLUDE 'PROTHEUS.CH' 
#INCLUDE 'RWMAKE.CH'
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DIPINVENT ºAutor  ³Microsiga           º Data ³  01/17/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function DIPR078()
Local cSQL 		:= ""                                            
Local aLogSB2 	:= {}
Local nPos		:= 0
Local cPerg     := "DIPR078"
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
PRIVATE oPrint  := TMSPrinter():New("Divergência Invententário Rotativo")
PRIVATE titulo 	:= "Divergência Invententário Rotativo"  
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

cSQL := " SELECT "
cSQL += " 	ZZD_LOCAL, ZZD_LOCALI, ZZD_PRODUT, ZZD_LOTECT, ZZD_QUANT, ZZD_QTCONT, ZZD_QTELEI "
cSQL += " 	FROM "
cSQL += 		RetSQLName("ZZD")
cSQL += " 		WHERE "             
cSQL += "			ZZD_FILIAL = '"+xFilial("ZZD")+"' AND "
cSQL += " 			ZZD_LOCAL  = '"+ZZC->ZZC_LOCAL+"' AND "
cSQL += " 			ZZD_LOCALI = '"+ZZC->ZZC_LOCALI+"' AND "
cSQL += " 			ZZD_DATA   = '"+DtoS(ZZC->ZZC_DATA)+"' AND "
cSQL += " 			(ZZD_TIPREG = 'I' OR "
cSQL += " 			(ZZD_TIPREG = 'A' AND ZZD_QUANT <> ZZD_QTCONT)) AND "
cSQL += " 			D_E_L_E_T_ = ' ' "

cSQL := ChangeQuery(cSQL)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),"QRYZZD",.T.,.T.)

While !QRYZZD->(Eof())     
    
	If nLin > 3000  
		oPrint:EndPage()  
		nLin:=0
		oPrint:StartPage()
	ElseIf nLin == 0
		oPrint:StartPage()
	EndIf
	
	If nLin==0
		nLin := InvtCab(nLin)		
	EndIf
	                                                                         
	oPrint:Say(nLin,0100,QRYZZD->ZZD_PRODUT							,oFont12)
	oPrint:Say(nLin,0500,QRYZZD->ZZD_LOTECT							,oFont12)
	oPrint:Say(nLin,0900,Transform(QRYZZD->ZZD_QUANT ,"@E 99999999")	,oFont12)
	oPrint:Say(nLin,1300,Transform(QRYZZD->ZZD_QTCONT,"@E 99999999")	,oFont12)
	oPrint:Say(nLin,1700,Transform(QRYZZD->ZZD_QTELEI,"@E 99999999")	,oFont12)

	nLin += 50   
	                                                                      
	QRYZZD->(dbSkip())
EndDo
QRYZZD->(dbCloseArea())                                                                                                             

oPrint:EndPage()             

oPrint:Preview()

MS_FLUSH()                   

Return     
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DIPINVENT ºAutor  ³Microsiga           º Data ³  01/17/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function InvtCab(nLin)              
DEFAULT nLin := 0

If nLin == 0
	nLin :=100
	oPrint:Line(nLin,0100,nLin,2200) 	

	nLin+=10	
	oPrint:Say(nLin,0800,"### DIVERGENCIAS ###"	   		,oFont15n)    //Codigo do produto
	nLin+=60
	
	oPrint:Line(nLin,0100,nLin,2200) 	
	nLin+=100		
EndIf
	

oPrint:Say(nLin,0100,"LOCAL - ENDERECO"	,oFont12n)
oPrint:Say(nLin,0600,"OPERADOR"  		,oFont12n)
oPrint:Say(nLin,1100,"DATA" 	 		,oFont12n)

nLin+=50
oPrint:Line(nLin,0100,nLin,2200) 
nLin+=10

oPrint:Say(nLin,0170,QRYZZD->(ZZD_LOCAL+" - "+ZZD_LOCALI)		,oFont12)
oPrint:Say(nLin,0600,ZZC->ZZC_USUARI							,oFont12)
oPrint:Say(nLin,1100,DtoC(ZZC->ZZC_DATA)						,oFont12)
        
nLin+=50


oPrint:Say(nLin,0100,"PRODUTO"		,oFont12n)
oPrint:Say(nLin,0500,"LOTE"			,oFont12n)
oPrint:Say(nLin,0900,"ESTOQUE"		,oFont12n)
oPrint:Say(nLin,1300,"QTD. CONTADA"	,oFont12n)
oPrint:Say(nLin,1700,"QTD. ELEITA"	,oFont12n)

nLin+=50
oPrint:Line(nLin,0100,nLin,2200) 
nLin+=10

Return nLIn



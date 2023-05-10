#INCLUDE 'PROTHEUS.CH' 
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
User Function DipInvent()
Local cSQL 		:= ""                                            
Local aLogSB2 	:= {}
Local nPos		:= 0

If !(Upper(U_DipUsr()) $ 'MCANUTO/DDOMINGOS/VQUEIROZ/VEGON/RBORGES')
	Aviso("Aten็a๕","Usuแrio sem permissใo para executar a rotina.",{"Ok"},1)
	Return .F.	
EndIf

cSQL := " SELECT B2_LOCAL, B2_COD, B2_QACLASS, B2_QPEDVEN, B2_QEMP, B2_RESERVA "
cSQL += " FROM "+RetSQLName("SB2")
cSQL += " WHERE B2_FILIAL = '"+xFilial("SB2")+"' "                                
cSQL += " AND B2_LOCAL = '01' "
cSQL += " AND (B2_QACLASS <> 0 OR B2_QPEDVEN <> 0 OR B2_QEMP <> 0 OR B2_RESERVA <> 0) "
cSQL += " AND D_E_L_E_T_ = ' ' "  
cSQL += " ORDER BY B2_COD, B2_LOCAL "
cSQL := ChangeQuery(cSQL)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),"QRYSB2",.T.,.T.)

While !QRYSB2->(Eof())    
	
	cSQL := " SELECT C9_PEDIDO, C9_PRODUTO, C9_LOCAL, C9_ITEM, C9_SALDO, C9_QTDORI "
	cSQL += " FROM "+RetSQLName("SC9") 
	cSQL += " WHERE C9_FILIAL = '"+xFilial("SC9")+"' "
	cSQL += " AND C9_PRODUTO  = '"+AllTrim(QRYSB2->B2_COD)  +"' " 
	cSQL += " AND C9_LOCAL    = '"+AllTrim(QRYSB2->B2_LOCAL)+"' "
	cSQL += " AND C9_NFISCAL  = ' ' "
	cSQL += " AND (C9_SALDO > 0 OR C9_QTDORI > 0) "
	cSQL += " AND  D_E_L_E_T_ = ' ' "           
	
	cSQL := ChangeQuery(cSQL)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),"QRYSC9",.T.,.T.)
	
	If !QRYSC9->(Eof()) 	
		While !QRYSC9->(Eof())                     
			If (nPos := aScan(aLogSB2, {|x| x[1]==QRYSC9->C9_PRODUTO .And. x[2]==QRYSC9->C9_LOCAL})) > 0
				aAdd(aLogSB2[nPos,7], {QRYSC9->C9_PEDIDO,;  	//7,?,1
								 		QRYSC9->C9_PRODUTO,;  	//7,?,2
								 		QRYSC9->C9_LOCAL,;		//7,?,3   
								 		QRYSC9->C9_ITEM,;		//7,?,4
								 		QRYSC9->C9_SALDO,; 		//7,?,5
								 		QRYSC9->C9_QTDORI}; 	//7,?,6
										)	
			Else	
				aAdd(aLogSB2, {	QRYSB2->B2_COD,; 	  	//1
								QRYSB2->B2_LOCAL,;    	//2
								QRYSB2->B2_QACLASS,;  	//3
								QRYSB2->B2_QPEDVEN,; 	//4					
								QRYSB2->B2_QEMP,;    	//5
								QRYSB2->B2_RESERVA,;	//6
								{{QRYSC9->C9_PEDIDO,;  	//7,?,1
								 QRYSC9->C9_PRODUTO,;  	//7,?,2
								 QRYSC9->C9_LOCAL,;		//7,?,3   
								 QRYSC9->C9_ITEM,;		//7,?,4
								 QRYSC9->C9_SALDO,; 	//7,?,5
								 QRYSC9->C9_QTDORI}; 	//7,?,6
								}}) 													
			EndIf
			QRYSC9->(dbSkip())
		EndDo                 
	Else 
		aAdd(aLogSB2, {QRYSB2->B2_COD, QRYSB2->B2_LOCAL, QRYSB2->B2_QACLASS, QRYSB2->B2_QPEDVEN, QRYSB2->B2_QEMP, QRYSB2->B2_RESERVA})	
	EndIf                     
	QRYSC9->(dbCloseArea())  

	QRYSB2->(dbSkip())
EndDo
QRYSB2->(dbCloseArea())                                                                                                             

If Len(aLogSB2)>0                                                                              
	ImpIncons(aLogSB2)
Else                                                                                            
	Aviso("Aten็a๕","Nใo foram encontradas incosist๊ncias no relacionamento SB2 X SC9",{"Ok"},2)
EndIf

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
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ImpIncons(aImp)
PRIVATE oPrint  := TMSPrinter():New("Inconsist. SB2 X SC9")
PRIVATE titulo 	:= "Inconsist. SB2 X SC9"                         
PRIVATE oFont09 := TFont():New("Arial",9,09,.T.,.F.,5,.T.,5,.T.,.F.)
PRIVATE oFont10 := TFont():New("Arial",9,10,.T.,.F.,5,.T.,5,.T.,.F.)
PRIVATE oFont12 := TFont():New("Arial",9,12,.T.,.F.,5,.T.,5,.T.,.F.)
PRIVATE oFont12n:= TFont():New("Arial",9,12,.T.,.T.,5,.T.,5,.T.,.F.)
PRIVATE oFont15n:= TFont():New("Arial",9,15,.T.,.T.,5,.T.,5,.T.,.F.)
PRIVATE oFont28n:= TFont():New("Arial",9,28,.T.,.T.,5,.T.,5,.T.,.F.)
DEFAULT aImp := {}

Processa({|| DIPInvtImp(aImp)},"Imprimindo...")	

Return
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
Static Function DIPInvtImp(aImp)
Local nLin		:= 0
Local nI 		:= 0
Local lFlag		:= .F.
PRIVATE nBar	:= 0
DEFAULT aImp 	:= {}

If !(oPrint:IsPrinterActive())
	oPrint:Setup()
	Return (.F.)
EndIf

oPrint:SetPortrait()

For nI := 1 to Len(aImp)
	
	IncProc( "Processando...")
		
	If nLin > 3200  
		oPrint:EndPage()
		oPrint:StartPage()
		nLin := InvtCab(nLin)
	ElseIf nLin == 0
		oPrint:StartPage()
		nLin := InvtCab()
	EndIf
	
	If Len(aImp[nI]) > 6 
		//oPrint:Line(nLin,0100,nLin,2200) 
		//nLin+=10
	EndIf
	
	oPrint:Say(nLin,0100,aImp[nI,1]	   		,oFont12)                                //Codigo do produto
	oPrint:Say(nLin,0300,aImp[nI,2]  		,oFont12)                                //Local
	oPrint:Say(nLin,0500,Transform(aImp[nI,3],"@E 99999999")			,oFont12)    //Qtd a Classf.
	oPrint:Say(nLin,0900,Transform(aImp[nI,4],"@E 99999999")			,oFont12)    //QPedVen (Saldo SC9)
	oPrint:Say(nLin,1300,Transform(aImp[nI,5],"@E 99999999")			,oFont12)    //QEmp (Saldo Bloqueado))
	oPrint:Say(nLin,1700,Transform(aImp[nI,6],"@E 99999999")			,oFont12)    //Reserva (Reserva SC9)
	
	nLin+=50
	                              
	If Len(aImp[nI]) > 6
		nLIn := InvtCab2(nLin)
		For nJ := 1 to Len(aImp[nI,7])
			oPrint:Say(nLin,0800,aImp[nI,7,nJ,1]	   		,oFont12)       		//Pedido
			oPrint:Say(nLin,1000,aImp[nI,7,nJ,2]	  		,oFont12)               //Produto
			oPrint:Say(nLin,1200,aImp[nI,7,nJ,3]			,oFont12)               //Local
			oPrint:Say(nLin,1500,aImp[nI,7,nJ,4]			,oFont12)               //Item
			oPrint:Say(nLin,1700,Transform(aImp[nI,7,nJ,5],"@E 99999999"),oFont12) //Saldo
			oPrint:Say(nLin,1900,Transform(aImp[nI,7,nJ,6],"@E 99999999"),oFont12)	 //Reserva		
			
			nLin+=50			
			
			If nLin > 3200  
				oPrint:EndPage()
				oPrint:StartPage()
				nLin := InvtCab(nLin)
			ElseIf nLin == 0
				oPrint:StartPage()
				nLin := InvtCab()
			EndIf
		
		Next nJ	
		nLin := InvtCab3(nLin)
	EndIf	
Next nI

oPrint:EndPage()             

oPrint:Preview()

MS_FLUSH()

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

nLin :=100
oPrint:Line(nLin,0100,nLin,2200) 	
nLin+=10	

oPrint:Say(nLin,0600,"### RELATORIO DE INCONSISTสNCIAS SB2 X SC9 ###"	   		,oFont15n)    //Codigo do produto
nLin+=60

oPrint:Line(nLin,0100,nLin,2200) 	
nLin+=100	

oPrint:Say(nLin,0100,"PRODUTO"	   		,oFont12n)    //Codigo do produto
oPrint:Say(nLin,0300,"LOCAL"  			,oFont12n)    //Local
oPrint:Say(nLin,0500,"QTD A CLASSF."	,oFont12n)    //Qtd a Classf.
oPrint:Say(nLin,0900,"SALDO SC9"		,oFont12n)    //QPedVen (Saldo SC9)
oPrint:Say(nLin,1300,"SLD BLOQ"			,oFont12n)    //QEmp (Saldo Bloqueado))
oPrint:Say(nLin,1700,"RESERVADO"		,oFont12n)    //Reserva (Reserva SC9)

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
oPrint:Say(nLin,0800,"PEDIDO"  	,oFont12n)       		//Pedido
oPrint:Say(nLin,1000,"PRODUTO"	,oFont12n)               //Produto
oPrint:Say(nLin,1200,"LOCAL"	,oFont12n)               //Local
oPrint:Say(nLin,1500,"ITEM"		,oFont12n)               //Item
oPrint:Say(nLin,1700,"SALDO"	,oFont12n) 				//Saldo
oPrint:Say(nLin,1900,"RESERVA"	,oFont12n)	 			//Reserva		
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

nLin+=100 

If nLin > 3100  
	oPrint:EndPage()
	oPrint:StartPage()
	nLin := InvtCab(nLin)
ElseIf nLin == 0
	oPrint:StartPage()
	nLin := InvtCab()
EndIf

oPrint:Say(nLin,0100,"PRODUTO"	   		,oFont12n)    //Codigo do produto
oPrint:Say(nLin,0300,"LOCAL"  			,oFont12n)    //Local
oPrint:Say(nLin,0500,"QTD A CLASSF."	,oFont12n)    //Qtd a Classf.
oPrint:Say(nLin,0900,"SALDO"			,oFont12n)    //QPedVen (Saldo SC9)
oPrint:Say(nLin,1300,"SLD BLOQ"			,oFont12n)    //QEmp (Saldo Bloqueado))
oPrint:Say(nLin,1700,"RESERVADO"		,oFont12n)    //Reserva (Reserva SC9)

nLin+=50
oPrint:Line(nLin,0100,nLin,2200) 
nLin+=10

Return nLin
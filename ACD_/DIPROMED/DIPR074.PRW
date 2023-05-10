#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "RWMAKE.CH"  
#INCLUDE "AP5MAIL.CH"        
#INCLUDE "COLORS.CH"
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
User Function DIPR074()                

LOCAL cPerg		:= "DIPR99"
//PRIVATE oPrint  := TMSPrinter():New("Prenota de Entrada")
PRIVATE titulo 	:= "Prenota de Recebimento"                         
PRIVATE oFont14 := TFont():New("Arial",9,12,.T.,.F.,5,.T.,5,.T.,.F.)
PRIVATE oFont15 := TFont():New("Arial",9,13,.T.,.F.,5,.T.,5,.T.,.F.)
PRIVATE oFont20n:= TFont():New("Arial",9,13,.T.,.T.,5,.T.,5,.T.,.F.)
PRIVATE oFont17 := TFont():New("Arial",9,15,.T.,.F.,5,.T.,5,.T.,.F.)
PRIVATE oFont17n:= TFont():New("Arial",9,15,.T.,.T.,5,.T.,5,.T.,.F.)
PRIVATE oFont20n:= TFont():New("Arial",9,18,.T.,.T.,5,.T.,5,.T.,.F.)
PRIVATE oFont33n:= TFont():New("Arial",9,31,.T.,.T.,5,.T.,5,.T.,.F.) 
PRIVATE cPrefixo := "PN_"+DTOS(dDatabase)+"-"+(SubStr(Time(),4,2))


//RBorges 21/01/2014 - alterada a forma de impressใo de imagem para PDF
// Antes era usado o TMSPrint, agora FWMSPrint

AjustaSX1(cPerg)   

	If Pergunte(cPerg,.T.)  

	   	oPrint := FWMSPrinter():New(cPrefixo,6,.T.,,.T.)
		oPrint :SetLandScape() //paisagem
		oPrint :Setup() 
		MakeDir("C:\PRENOTA\")
		oPrint :cPathPDF:="C:\PRENOTA\"
		
		U_DIPPROC(ProcName(0),U_DipUsr())
		
		Processa({|| DIP99IMP(cPerg)},"Prenota de entrada...")	
	   
	Endif   
	
	
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
Static Function DIP99IMP(cPerg)
Local cSQL  	:= ""  
Local nLin		:= 0          
Local lFlag		:= .F.
PRIVATE nBar	:= 0             
DEFAULT cPerg 	:= ""


cSQL  := " SELECT F1_DOC, F1_SERIE, F1_FORNECE, F1_LOJA " 
cSQL  += " FROM " + RetSQLName("SF1")
cSQL  += " WHERE F1_FILIAL = '" + xFilial('SF1') + "' "
cSQL  += " AND " + RetSQLName("SF1") + ".D_E_L_E_T_ = ' ' "
cSQL  += " AND F1_DTDIGIT  	BETWEEN '"+DtoS(MV_PAR01)+"' AND '"+DtoS(MV_PAR02)+"' " 
cSQL  += " AND F1_SERIE  	BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"' " 
cSQL  += " AND F1_DOC  		BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR06+"' " 
cSQL  += " AND F1_FORNECE  	BETWEEN '"+MV_PAR07+"' AND '"+MV_PAR08+"' " 
cSQL  += " AND F1_LOJA  	BETWEEN '"+MV_PAR09+"' AND '"+MV_PAR10+"' " 
cSQL  += " ORDER BY F1_SERIE, F1_DOC "

cSQL := ChangeQuery(cSQL)
dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSQL),"QRYSF1",.F.,.T.)

ProcRegua( QRYSF1->(RecCount()) )

SD1->(dbSetOrder(1))                  
 
If !(oPrint:IsPrinterActive())
     Aviso("Impressora","As configura็๕es da impressora nใo foram encontradas. Por favor, verifique as configura็๕es para utilizar este relat๓rio. ",{"OK"})
     oPrint:Setup()    
     QRYSF1->(dbCloseArea())
     Return (.F.)
EndIf
      
oPrint:SetLandscape()

While !QRYSF1->(Eof())

	IncProc( "Imprimindo Nota: "+QRYSF1->(F1_DOC+F1_SERIE))
	
	If SD1->(dbSeek(xfilial("SD1")+QRYSF1->(F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA)))	
		             
		oPrint:StartPage()      
		nLin := R99Cab(QRYSF1->F1_DOC)
		nLin := R99Cab1(nLin)
        
		oPrint:Say(nLin,0200,QRYSF1->F1_DOC	   		,oFont17)
		oPrint:Say(nLin,0500,QRYSF1->F1_SERIE  		,oFont17)
		oPrint:Say(nLin,0650,QRYSF1->F1_FORNECE		,oFont17)
		oPrint:Say(nLin,0900,QRYSF1->F1_LOJA		,oFont17)
		oPrint:Say(nLin,1000,POSICIONE("SA2",1,xFilial("SA2")+QRYSF1->(F1_FORNECE+F1_LOJA),"A2_NOME")	,oFont17)
		
 		nBar:= 7.2
		
		oPrint:FWMSBAR("CODE128",nBar,42,QRYSF1->(F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA),oPrint,/*lCheck*/,/*Color*/,/*lHorz*/,0.02960,0.6,/*lBanner*/,/*cFont*/,NIL,.F. ,0.02960,0.6,.F.)

        oPrint:Line(nLin+0070,0050,nLin+0070,2800)
		
		//nBar+=5.2
		nBar+=4.2

		nLin  := R99Cab2(nLin)
		lFlag := .F.		
		
		While !SD1->(Eof()) .And. SD1->(D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA) == QRYSF1->(F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA)
            
            If nLin>=2200
            	oPrint:EndPage()
            	oPrint:StartPage()
            	nLin := R99Cab(QRYSF1->F1_DOC)
            	nLin := R99Cab2(nLin,.T.)
				nBar := 7.0   
            EndIf
        	
        	oPrint:Say(nLin,0100,SD1->D1_COD	   												,oFont14)
			oPrint:Say(nLin,0230,POSICIONE("SB1",1,xFilial("SB1")+SD1->D1_COD,"B1_DESC")   		,oFont14)
			oPrint:Say(nLin,1350,POSICIONE("SB1",1,xFilial("SB1")+SD1->D1_COD,"B1_REG_ANV")   	,oFont14)
			oPrint:Say(nLin,1650,SD1->D1_UM 	   												,oFont14)
            
            nLin+=110
            			
			oPrint:Say(nLin,0100,"Qtd. Cx. Embarque: "											,oFont17n)
			oPrint:Say(nLin,0450,AllTrim(Str(POSICIONE("SB1",1,xFilial("SB1")+SD1->D1_COD,"B1_XQTDEMB")))	,oFont14)
			oPrint:Say(nLin,0600,"Qtd. Cx. Secundแria: "									   	,oFont17n           )
			oPrint:Say(nLin,0960,AllTrim(Str(POSICIONE("SB1",1,xFilial("SB1")+SD1->D1_COD,"B1_XQTDSEC")))	,oFont14)		
			oPrint:Say(nLin,1100,"Tp Venda: "									   	,oFont17n           )
			
			If	   AllTrim(POSICIONE("SB1",1,xFilial("SB1")+SD1->D1_COD,"B1_XTPEMBV")) == '1'
				oPrint:Say(nLin,1270, " Embarque " ,oFont14)
			ElseIf AllTrim(POSICIONE("SB1",1,xFilial("SB1")+SD1->D1_COD,"B1_XTPEMBV")) == '2'
				oPrint:Say(nLin,1270, " Secundaria " ,oFont14)
			Else
				oPrint:Say(nLin,1270, " Nenhuma " ,oFont14)							
			EndIf
			
			//Adicionado Tiago - 21/10/22
			oPrint:Say(nLin,1570,"Cod.Emb: "									,oFont17n)
			oPrint:Say(nLin,1770,cValToChar(AllTrim(POSICIONE("SB1",1,xFilial("SB1")+SD1->D1_COD,"B1_CODBAR")))	,oFont14)
			
			oPrint:Say(nLin,2100,"Cod.GTIN: "									,oFont17n)
			oPrint:Say(nLin,2300,cValToChar(AllTrim(POSICIONE("SB1",1,xFilial("SB1")+SD1->D1_COD,"B1_CODGTIN"))),oFont14)
		
			If lFlag							
				     // MSBAR3("CODE128",nBar,16,SD1->D1_COD,oPrint,/*lCheck*/,/*Color*/,/*lHorz*/,0.02960,0.7,/*lBanner*/,/*cFont*/,nil,.F.)			
		        oPrint:FWMSBAR("CODE128",nBar,40,SD1->D1_COD,oPrint,/*lCheck*/,/*Color*/,/*lHorz*/,0.02960,0.6,/*lBanner*/,/*cFont*/,NIL,.F. ,0.02960,0.6,.F.)
				//oPrint:FWMSBAR("CODE128",nLin-20,40,SD1->D1_COD,oPrint,/*lCheck*/,/*Color*/,/*lHorz*/,0.02960,0.6,/*lBanner*/,/*cFont*/,NIL,.F. ,0.02960,0.6,.F.)
			Else
        			 // MSBAR3("CODE128",nBar,19.5,SD1->D1_COD,oPrint,/*lCheck*/,/*Color*/,/*lHorz*/,0.02960,0.7,/*lBanner*/,/*cFont*/,nil,.F.)	
				oPrint:FWMSBAR("CODE128",nBar,45,SD1->D1_COD,oPrint,/*lCheck*/,/*Color*/,/*lHorz*/,0.02960,0.6,/*lBanner*/,/*cFont*/,NIL,.F. ,0.02960,0.6,.F.)		
				//oPrint:FWMSBAR("CODE128",nLin-20,45,SD1->D1_COD,oPrint,/*lCheck*/,/*Color*/,/*lHorz*/,0.02960,0.6,/*lBanner*/,/*cFont*/,NIL,.F. ,0.02960,0.6,.F.)		
			EndIf          
			                                                                                                                         
			lFlag := !lFlag
	        
	        oPrint:Line(nLin+10,0050,nLin+10,2800)

			nLin+=78
	        //nBar+=3.5
			nBar+=3.8
			SD1->(dbSkip())
	
		EndDo 
		
	EndIf
	oPrint:EndPage()
	QRYSF1->(dbSkip())
EndDo
QRYSF1->(dbCloseArea())
 
oPrint:Preview() 

MS_FLUSH()


Return .T.     
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDIPR099   บAutor  ณMicrosiga           บ Data ณ  10/09/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function R99Cab(cDoc)
Local cLogo  := ""          
DEFAULT cDoc := ""                      

oPrint:Box(0100,0050,2450,2800)   
oPrint:Box(0100,0050,0248,0450) 

cLogo := GetSrvProfString("Startpath","") + "lgrl" + cEmpAnt + cFilAnt + ".BMP"

If !File(cLogo)
	cLogo := GetSrvProfString("Startpath","") + "lgrl" + cEmpAnt + ".BMP"
EndIf	

oPrint:SayBitmap(0150,0070,cLogo,0300,0050)
	
oPrint:Say(0200,00850,"PRENOTA DE ENTRADA - "+AllTrim(cDoc)+IIf(cFilAnt=='01'," - MTZ"," - CD"),oFont33n)

oPrint:Line(0250,0050,0250,2800)           

nBar := 8
	
Return 300
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDIPR099   บAutor  ณMicrosiga           บ Data ณ  10/09/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function R99Cab1(nLin)
                   
nLin -= 5         
oPrint:Say(nLin,0200,"Documento"	,oFont17n)
oPrint:Say(nLin,0500,"S้rie"		,oFont17n)
oPrint:Say(nLin,0650,"Fornecedor"	,oFont17n)
oPrint:Say(nLin,0900,"Loja"			,oFont17n)
oPrint:Say(nLin,1000,"Nome Fornec."	,oFont17n)

nLin+=20         

oPrint:Line(nLin,0050,nLin,2800)

nLin+=0100

Return nLin 
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDIPR099   บAutor  ณMicrosiga           บ Data ณ  10/09/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function R99Cab2(nLin,lNewPage)
DEFAULT nLin 	:= 0	                 
DEFAULT lNewPage:= .F.

If !lNewPage
	nLin+=110
EndIf
        
oPrint:Say(nLin,0110,"Prod."			,oFont17n)
oPrint:Say(nLin,0240,"Descri็ใo"		,oFont17n)
oPrint:Say(nLin,1360,"Anvisa"	    	,oFont17n)
oPrint:Say(nLin,1660,"Unid."			,oFont17n)

nLin+=20

oPrint:Line(nLin,0050,nLin,2800)       

nLin+=070     

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

aAdd(aRegs,{cPerg,"01","Data De     ?","","","mv_ch1","D", 8,0,0,"G","","MV_PAR01","","","","","","","","","","","","","","","","","","","","","","","","",''})
aAdd(aRegs,{cPerg,"02","Data At้    ?","","","mv_ch2","D", 8,0,0,"G","","MV_PAR02","","","","","","","","","","","","","","","","","","","","","","","","",''})
aAdd(aRegs,{cPerg,"03","Serie De    ?","","","mv_ch3","C", 3,0,0,"G","","MV_PAR03","","","","","","","","","","","","","","","","","","","","","","","","",''})
aAdd(aRegs,{cPerg,"04","Serie At้   ?","","","mv_ch4","C", 3,0,0,"G","","MV_PAR04","","","","","","","","","","","","","","","","","","","","","","","","",''})
aAdd(aRegs,{cPerg,"05","Doc De      ?","","","mv_ch5","C", 9,0,0,"G","","MV_PAR05","","","","","","","","","","","","","","","","","","","","","","","","",''})
aAdd(aRegs,{cPerg,"06","Doc At้     ?","","","mv_ch6","C", 9,0,0,"G","","MV_PAR06","","","","","","","","","","","","","","","","","","","","","","","","",''})
aAdd(aRegs,{cPerg,"07","Fornec. De  ?","","","mv_ch7","C", 6,0,0,"G","","MV_PAR07","","","","","","","","","","","","","","","","","","","","","","","","",''})
aAdd(aRegs,{cPerg,"08","Fornec. At้ ?","","","mv_ch8","C", 6,0,0,"G","","MV_PAR08","","","","","","","","","","","","","","","","","","","","","","","","",''})
aAdd(aRegs,{cPerg,"09","Loja. De    ?","","","mv_ch9","C", 2,0,0,"G","","MV_PAR09","","","","","","","","","","","","","","","","","","","","","","","","",''})
aAdd(aRegs,{cPerg,"10","Loja. At้   ?","","","mv_cha","C", 2,0,0,"G","","MV_PAR10","","","","","","","","","","","","","","","","","","","","","","","","",''})

PlsVldPerg( aRegs )       

Return

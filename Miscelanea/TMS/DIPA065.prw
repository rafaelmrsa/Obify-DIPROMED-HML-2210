#INCLUDE "PROTHEUS.CH" 
#INCLUDE "RWMAKE.CH" 
#INCLUDE "TBICONN.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDIPA065   บAutor  ณMicrosiga           บ Data ณ  04/07/14   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function DIPA065()
Private cPerg    := "DIPA65"

AjustaSX1(cPerg)

If !Pergunte(cPerg,.T.)
	Return .F.
EndIf

RptStatus({|lEnd| DIPA65Sel(mv_par01,mv_par02,mv_par03,mv_par04,mv_par05,mv_par06)},"Exportando...")

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDIPA065   บAutor  ณMicrosiga           บ Data ณ  04/08/14   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Dipa65Sel(cViaDe,cViaAte,dDtViag,nTipo,nEmp,nDev)
Local oDlg                                 
Local oMark                                
Local aStrut	:= {}
Local lOK		:= .F.
Local cSQL 		:= ""                                                     
Local lInverte 	:= .F.
Local cDocAnt   := ""
Private lReenv	:= (nTipo==2)
Private lDev	:= (nDev==2)
Private lDipro	:= (nEmp==1)
Private lEmove	:= (nEmp==3)
Private cMarca 	:= GetMark()  
Private nDipVal1 	:= 0
Private nDipVal2 	:= 0
Private oDipVal1
Private oDipVal2
Private oMark     

aObjects := {}

aSize   := MsAdvSize()
aAdd(aObjects, {100, 100, .T., .T.})

aInfo   := {aSize[1], aSize[2], aSize[3], aSize[4], 2, 2}
aPosObj := MsObjSize(aInfo, aObjects)

aadd(aStrut,{"OK"    	 	, "C" ,2,0})
aadd(aStrut,{"ALLOK"   	 	, "C" ,2,0})  
aadd(aStrut,{"DUD_FILORI"   , AvSx3("DUD_FILORI",2),AvSx3("DUD_FILORI",3),AvSx3("DUD_FILORI",4)})
aadd(aStrut,{"DUD_VIAGEM"   , AvSx3("DUD_VIAGEM",2),AvSx3("DUD_VIAGEM",3),AvSx3("DUD_VIAGEM",4)})
aadd(aStrut,{"DTC_DOC"   	, AvSx3("DTC_DOC" 	,2),AvSx3("DTC_DOC"	  ,3),AvSx3("DTC_DOC"   ,4)})
aadd(aStrut,{"DTC_SERIE"   	, AvSx3("DTC_SERIE" ,2),AvSx3("DTC_SERIE" ,3),AvSx3("DTC_SERIE" ,4)})
aadd(aStrut,{"DTC_CLIDES"   , AvSx3("DTC_CLIDES",2),AvSx3("DTC_CLIDES",3),AvSx3("DTC_CLIDES",4)})
aadd(aStrut,{"DTC_LOJDES"   , AvSx3("DTC_LOJDES",2),AvSx3("DTC_LOJDES",3),AvSx3("DTC_LOJDES",4)})
aadd(aStrut,{"DTC_FILORI"   , AvSx3("DTC_FILORI",2),AvSx3("DTC_FILORI",3),AvSx3("DTC_FILORI",4)})
aadd(aStrut,{"DTC_NUMNFC"   , AvSx3("DTC_NUMNFC",2),AvSx3("DTC_NUMNFC",3),AvSx3("DTC_NUMNFC",4)})
aadd(aStrut,{"DTC_SERNFC"  	, AvSx3("DTC_SERNFC",2),AvSx3("DTC_SERNFC",3),AvSx3("DTC_SERNFC",4)})
aadd(aStrut,{"DTC_VALOR"	, AvSx3("DTC_VALOR" ,2),AvSx3("DTC_VALOR" ,3),AvSx3("DTC_VALOR" ,4)})
aadd(aStrut,{"DTC_EMINFC"   , AvSx3("DTC_EMINFC",2),AvSx3("DTC_EMINFC",3),AvSx3("DTC_EMINFC",4)})
aadd(aStrut,{"DTC_CLIREM"	, AvSx3("DTC_CLIREM",2),AvSx3("DTC_CLIREM",3),AvSx3("DTC_CLIREM",4)})
aadd(aStrut,{"DTC_LOJREM"   , AvSx3("DTC_LOJREM",2),AvSx3("DTC_LOJREM",3),AvSx3("DTC_LOJREM",4)})
aadd(aStrut,{"REC"   		,"N",15,0})

cArqTRB := CriaTrab(aStrut, .T.)
dbUseArea(.T.,,cArqTRB,"TRB_NF")

cIndTRB := CriaTrab(Nil,.F.)

TRB_NF->(DbCreateIndex(cIndTRB,"DUD_FILORI+DUD_VIAGEM+DTC_NUMNFC+DTC_SERNFC" ,{|| DUD_FILORI+DUD_VIAGEM+DTC_NUMNFC+DTC_SERNFC },.F.))
TRB_NF->(DbClearInd())
TRB_NF->(DbSetIndex(cIndTRB))
TRB_NF->(DbSetOrder(1))

cSQL := " SELECT "
cSQL += "  	DUD_FILORI, DUD_VIAGEM,DTC_DOC, DTC_SERIE, DTC_CLIDES, DTC_LOJDES, DTC_FILORI, DTC_NUMNFC, DTC_SERNFC, DTC_VALOR, "
cSQL += "	DTC_EMINFC, DTC_CLIREM, DTC_LOJREM,"+RetSQLName("DTC")+".R_E_C_N_O_ REC " 
cSQL += " 	FROM "
cSQL += 		RetSQLName("DUD")+", "+RetSQLName("DT6")+", "+RetSQLName("DTC")
cSQL += " 		WHERE "
cSQL += " 			DUD_FILIAL = '"+xFilial("DUD")+"' AND "
cSQL += " 			DUD_VIAGEM BETWEEN '"+cViaDe+"' AND '"+cViaAte+"' AND "
cSQL += " 			DUD_VIAGEM <> ' ' AND "
cSQL += " 			DT6_FILIAL = DUD_FILIAL AND "
cSQL += " 			DT6_FILDOC = DUD_FILDOC AND "
cSQL += " 			DT6_DOC    = DUD_DOC    AND "
cSQL += " 			DT6_SERIE  = DUD_SERIE  AND "
cSQL += " 			DT6_DOCTMS IN('2','5')  AND "
cSQL += " 			DTC_DOC	   = DT6_DOC	AND "
cSQL += " 			DTC_SERIE  = DT6_SERIE	AND "
cSQL += " 			DTC_FILDOC = DT6_FILDOC AND "  

If !lEmove
	If lDipro	 
		cSQL += " 		DTC_CLIREM = '000804' AND "
	Else                                               
		cSQL += " 		DTC_CLIREM = '011050' AND "
	EndIf
EndIf

If !Empty(DtoS(dDtViag))
	cSQL += "			DTC_DATENT = '"+DtoS(dDtViag)+"' AND "
EndIf                            

If lEmove
	If lReenv .Or. lDev              
		cSQL += " 		DTC_XAVERE = 'S' AND "
	Else
		cSQL += " 		DTC_XAVERE = ' ' AND "
	EndIf	
Else
	If lReenv .Or. lDev              
		cSQL += " 		DTC_XAVERB = 'S' AND "
	Else
		cSQL += " 		DTC_XAVERB = ' ' AND "
	EndIf
EndIf
cSQL += 			RetSQLName("DUD")+".D_E_L_E_T_ = ' ' AND "
cSQL += 			RetSQLName("DT6")+".D_E_L_E_T_ = ' ' AND "
cSQL += 			RetSQLName("DTC")+".D_E_L_E_T_ = ' ' "
cSQL += " ORDER BY DUD_VIAGEM, DTC_DOC, DTC_SERIE, DTC_FILORI, DTC_NUMNFC, DTC_SERNFC "

cSQL := ChangeQuery(cSQL)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),"QRYDUD",.T.,.F.)      

TCSETFIELD("QRYDUD","DTC_EMINFC","D",8,0)
TCSETFIELD("QRYDUD","DTC_VALOR" ,"N",10,2)     

While !QRYDUD->(Eof())
	
	If lEmove .And. cDocAnt == QRYDUD->DTC_DOC
		TRB_NF->DTC_VALOR += QRYDUD->DTC_VALOR
	Else			
		TRB_NF->(dbAppend())  
		TRB_NF->OK		   := ' '
		TRB_NF->ALLOK	   := ' '
		TRB_NF->DUD_FILORI := QRYDUD->DUD_FILORI
		TRB_NF->DUD_VIAGEM := QRYDUD->DUD_VIAGEM
		TRB_NF->DTC_DOC    := QRYDUD->DTC_DOC
		TRB_NF->DTC_SERIE  := QRYDUD->DTC_SERIE
		TRB_NF->DTC_CLIDES := QRYDUD->DTC_CLIDES
		TRB_NF->DTC_LOJDES := QRYDUD->DTC_LOJDES
		TRB_NF->DTC_FILORI := QRYDUD->DTC_FILORI     
		TRB_NF->DTC_NUMNFC := QRYDUD->DTC_NUMNFC
		TRB_NF->DTC_SERNFC := QRYDUD->DTC_SERNFC
		TRB_NF->DTC_VALOR  := QRYDUD->DTC_VALOR
		TRB_NF->DTC_EMINFC := QRYDUD->DTC_EMINFC
		TRB_NF->DTC_CLIREM := QRYDUD->DTC_CLIREM
		TRB_NF->DTC_LOJREM := QRYDUD->DTC_LOJREM
		TRB_NF->REC		   := QRYDUD->REC
	EndIf             
	cDocAnt := QRYDUD->DTC_DOC
	
	QRYDUD->(dbSkip())
EndDo
QRYDUD->(dbCloseArea())

TRB_NF->(DbGoTop())                  
	
DEFINE MSDIALOG oDlg TITLE "Doctos para Averba็ใo" From aSize[7],005 TO aSize[6],aSize[5] OF oMainWnd PIXEL    

	@ 035,005 SAY "Valor Total" 		  SIZE 100,008 			OF oDlg PIXEL
	@ 042,005 MSGET oDipVal1 VAR nDipVal1 SIZE 100,010 WHEN .F. OF oDlg PIXEL  PICTURE "@E 99,999,999.99"

	@ 035,135 SAY "Selecionados:"   	  SIZE 100,008 			OF oDlg PIXEL
	@ 042,135 MSGET oDipVal2 VAR nDipVal2 SIZE 100,010 WHEN .F. OF oDlg PIXEL  PICTURE "@E 999999"



	aCpos := { 	{"OK"    	 	, "" , ""					 , ""},;
				{"DUD_VIAGEM"   , "" , AvSx3("DUD_VIAGEM",5) , ""},;
				{"DTC_DOC"   	, "" , AvSx3("DTC_DOC"   ,5) , ""},;
				{"DTC_SERIE"   	, "" , AvSx3("DTC_SERIE" ,5) , ""},;
				{"DTC_CLIDES"   , "" , AvSx3("DTC_CLIDES",5) , ""},;
				{"DTC_LOJDES"   , "" , AvSx3("DTC_LOJDES",5) , ""},;
				{"DTC_FILORI"   , "" , AvSx3("DTC_FILORI",5) , ""},;
				{"DTC_NUMNFC"   , "" , AvSx3("DTC_NUMNFC",5) , ""},;
				{"DTC_SERNFC"  	, "" , AvSx3("DTC_SERNFC",5) , ""},;
				{"DTC_VALOR"	, "" , AvSx3("DTC_VALOR" ,5) , ""},;
				{"DTC_EMINFC"   , "" , AvSx3("DTC_EMINFC",5) , ""} }

	
	oMark 						:= MsSelect():New( "TRB_NF","OK",, aCpos, lInverte, cMarca, {aPosObj[1,1]+30,aPosObj[1,2],aPosObj[1,3],aPosObj[1,4]} )
	oMark:oBrowse:lCanAllMark	:= .T.                        
    oMark:baval 				:= {|| TRBMarca()}
	oMark:oBrowse:bAllMark 		:= {|| TRBMkAll()}

ACTIVATE MSDIALOG oDlg ON INIT (EnchoiceBar(oDlg,{|| DipExpArq(lDipro,lReenv,lEmove,lDev),oDlg:End()},{|| oDlg:End()}))

TRB_NF->(dbCloseArea())

Return                                        
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDIPA065   บAutor  ณMicrosiga           บ Data ณ  04/09/14   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function DipExpArq(lDipro,lReenv,lEmove,lDev)    
Local cRegEmb	:= "E"
Local cLinha	:= ""              
Local cLinAux	:= ""
Local cSQL 		:= ""    
Local cPlaca	:= Space(20)
Local aPlacaAux := {}
Local aDadosCli := {}            
Local nVlrAux	:= 0      
Local cTipAux	:= ""
Private _nH     := 0    

DipCriArq(lDipro,lReenv,lEmove,lDev)

If _nH > 0
	TRB_NF->(DbGoTop())
	
	cViaAux := ""	
	cRegiao := ""
	Do While TRB_NF->(!Eof())
		If !Empty(TRB_NF->OK)                                        
			DTR->(dbSetOrder(1))
			If DTR->(dbSeek(xFilial("DTR")+TRB_NF->(DUD_FILORI+DUD_VIAGEM)))
				DA3->(dbSetOrder(1))
				If DA3->(dbSeek(xFilial("DA3")+DTR->DTR_CODVEI))
					cPlaca := DA3->DA3_PLACA
					cPlaca := StrTran(cPlaca," ","")
					cPlaca := PadR(StrTran(cPlaca,"-",""),20)
				EndIf			
			EndIf

			// _________________________________________________________
			//|  aDadosCli    											|
			//|  [1] ENDERECO                                           |
			//|  [2] MUNICIPIO                                          |
			//|  [3] CEP                                                |
			//|  [4] ESTADO                                             |
			//|  [5] BAIRRO                                             |
			// ---------------------------------------------------------
			
			aDadosCli := DadosCli(	TRB_NF->DTC_NUMNFC,;
									TRB_NF->DTC_SERNFC,;
									TRB_NF->DTC_CLIDES,;
									TRB_NF->DTC_LOJDES,;
									TRB_NF->DTC_CLIREM,;
									TRB_NF->DTC_LOJREM)		
			If Len(aDadosCli) > 0                                                                           
				
				If TRB_NF->DUD_VIAGEM <> cViaAux .Or. nVlrAux >= 150000					  
			    	nVlrAux  := 0                                           
			    	lFlag1	 := .T.
			    	lFlag2	 := .T.
			    	
			    	If !Empty(cLinAux)
						cLinha += cLinAux                                   
						cLinAux := ""
					EndIf					
				EndIf					
				
			 	If Left(aDadosCli[3],1) == "0"                                
					If lFlag1				 		
						nTotViag := 0  
						aAdd(aPlacaAux, cPlaca) 
				    	aEval(aPlacaAux,{|x| IIf(x==cPlaca,nTotViag++,nil)})
				 		cLinha += DipCriaLin("E",lDipro,cPlaca,nTotViag,aDadosCli)
				 		lFlag1 := .F.
				 	EndIf
			    	cLinha += DipCriaLin("A",lDipro,cPlaca,nTotViag,aDadosCli,lReenv)
			 	Else       
			 		If lFlag2                                          
				 		nTotViag := 0  
		 				aAdd(aPlacaAux, cPlaca) 
				    	aEval(aPlacaAux,{|x| IIf(x==cPlaca,nTotViag++,nil)})
				 		cLinAux += DipCriaLin("E",lDipro,cPlaca,nTotViag,aDadosCli)
				 		lFlag2 := .F.
				 	EndIf
			 		cLinAux += DipCriaLin("A",lDipro,cPlaca,nTotViag,aDadosCli,lReenv)
			 	EndIf
				
				nVlrAux += TRB_NF->DTC_VALOR				
			Endif                      
			DTC->(dbGoTo(TRB_NF->REC))
			DTC->(RecLock("DTC",.F.))				
				If lEmove         
					DTC->DTC_XAVERE := "S" //Averba็ใo EMOVERE                            
				Else
					DTC->DTC_XAVERB := "S"  
				EndIf
			DTC->(MsUnLock())				
	
			cViaAux := TRB_NF->DUD_VIAGEM                          
			cTipAux := Left(aDadosCli[3],1)
		EndIf             		
		TRB_NF->(dbSkip())
	EndDo

  	If !Empty(cLinAux)
		cLinha += cLinAux                                   
	EndIf

	FWrite(_nH,cLinha)	
	FClose(_nH)   
	       
	Aviso("Aten็ใo","Arquivo Gerado com sucesso em C:\Averbacao\",{"Ok"},1)

EndIf

Return                   
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDIPA065   บAutor  ณMicrosiga           บ Data ณ  04/09/14   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static function DadosCli(cDoc,cSer,cCli,cLoj,cCliRem,cLojRem)
Local aArea := GetArea()
Local aRet := {}
Local cSQL := ""

cCodEmp := U_fTmsCodEmp(cCliRem+cLojRem)

cSQL := " SELECT "
cSQL += "	C5_ENDENT, C5_MUNE, C5_CEPE, C5_ESTE, C5_BAIRROE "
cSQL += "   FROM 
cSQL += "		SC5" + SubStr(cCodEmp,1,3) + " SC5, SD2" + SubStr(cCodEmp,1,3) + " SD2 "
cSQL += "  		WHERE "
cSQL += "    		D2_FILIAL      = '"+SubStr(cCodEmp,4,2)+"' AND "
cSQL += "    		D2_DOC         = '"+cDoc+"' AND "
cSQL += "    		D2_SERIE       = '"+cSer+"' AND "
cSQL += "    		D2_CLIENTE     = '"+cCli+"' AND "
cSQL += "    		C5_FILIAL      = D2_FILIAL AND " 
cSQL += "    		C5_NUM         = D2_PEDIDO AND " 
cSQL += "    		D2_ITEM        = '01' AND "
cSQL += "    		SC5.D_E_L_E_T_ = ' ' AND "
cSQL += "    		SD2.D_E_L_E_T_ = ' ' "    

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),"QRYSC5",.T.,.F.)      

If !QRYSC5->(Eof())  
	aRet :=   {	QRYSC5->C5_ENDENT,;
				QRYSC5->C5_MUNE,;
				QRYSC5->C5_CEPE,;
				QRYSC5->C5_ESTE,;
				QRYSC5->C5_BAIRROE }
EndIf
QRYSC5->(dbCloseArea())

RestArea(aArea)
Return aRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDIPA065   บAutor  ณMicrosiga           บ Data ณ  04/09/14   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function DipCriArq(lDipro,lReenv,lEmove,lDev)
Local cDir	    := "C:\Averbacao"
Local cNomArq   := ""

cNomArq += cDir+"\Avb_"
cNomArq += IIf(lDipro,"DIP_",IIf(lEmove,"EMO_","HQ_"))
cNomArq += IIf(lReenv,"REE_","")
cNomArq += IIf(lDev,"DEV_","")
cNomArq += SubStr(DtoS(dDataBase),7,2)+SubStr(DtoS(dDataBase),5,2)+SubStr(DtoS(dDataBase),1,4)
cNomArq += SubStr(Time(),4,2)+SubStr(Time(),7,2)
cNomArq += ".txt"

//cNomArq   := cDir+"\Averbacao.txt"

If !ExistDir(cDir)
	If Makedir(cDir) <> 0
		Return
	Endif
Endif

If File(cNomArq)
	FErase(cNomArq)
EndIf

If !File(cNomArq)
	_nH := FCreate(Upper(cNomArq))
Endif 

Return _nH
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDIPA065   บAutor  ณMicrosiga           บ Data ณ  04/09/14   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function TRBMarca()
Local cAtual := TRB_NF->OK       

TRB_NF->(RecLock("TRB_NF",.F.))
	If cAtual == cMarca
	   TRB_NF->OK := Space(3)  
	   nDipVal1 -= TRB_NF->DTC_VALOR
	   nDipVal2 --
	Else                          
	   TRB_NF->OK := cMarca
	   nDipVal1 += TRB_NF->DTC_VALOR
	   nDipVal2 ++
	EndIf    
TRB_NF->(MsUnLock())                   

oDipVal1:Refresh()
oDipVal2:Refresh()

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDIPA065   บAutor  ณMicrosiga           บ Data ณ  04/09/14   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function TRBMkAll()
Local nRecTRB 	:= TRB_NF->(Recno())
Local cMarkAux	:= If(TRB_NF->ALLOK==cMarca,Space(2),cMarca)             

nDipVal1 := 0
nDipVal2 := 0
 
TRB_NF->(DbGoTop())

Do While TRB_NF->(!Eof())
	TRB_NF->(RecLock("TRB_NF",.F.))
		TRB_NF->ALLOK 	:= cMarkAux 
		TRB_NF->OK		:= cMarkAux
	
		If !Empty(cMarkAux)
			nDipVal1 += TRB_NF->DTC_VALOR
			nDipVal2 ++
	    EndIf                      
	    
	TRB_NF->(MsUnlock())                  	
	TRB_NF->(DbSkip())
EndDo

TRB_NF->(DbGoTo(nRecTRB))

oDipVal1:Refresh()
oDipVal2:Refresh()

Return                                            



/*                                                                                  


ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno    ณRTMSR09Impณ Autor ณ Antonio C Ferreira    ณ Data ณ24.06.2002ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescrio ณ Chamada do Relatขrio                                       ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ RTMSR09			                                            ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ          ณ        ณ                                                   ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function DIPA65Exp(cViaDe,cViaAte)
Local cRegEmb	:= "E"
Local cCNPJPV	:= "47869078000100"
Local cDatEmb	:= ""
Local cPlaVei	:= ""
Local cViagem   := ""
Local cMeiTra	:= ""
Local cLocOri	:= ""
Local cTraUrb	:= ""
Local cEmbarc	:= ""
Local cCNPJPE	:= ""
Local cRegAve	:= ""
Local cLocDes	:= ""
Local cTipMer	:= ""
Local cSerie	:= ""
Local cSubSer	:= ""
Local cTipo		:= ""
Local cNumDoc	:= ""
Local cValMer	:= ""              
Local cSQL 		:= ""

SM0->(dbSeek(cEmpAnt+cFilAnt, .T.))
/*
cSQL := " SELECT "
cSQL += " 	DUD_FILDOC, DT6_FILIAL, * "
cSQL += " 	FROM "
cSQL += 		RetSQLName("DUD")+","+RetSQLName("DT6")+","+RetSQLName("DTC")
cSQL += " 		WHERE "
cSQL += " 			DUD_FILIAL = '"+xFilial("DUD")+"' AND "
cSQL += " 			DUD_VIAGEM BETWEEN '"+cViaDe+"' AND '"+cViaAte+"' AND "
cSQL += " 			DT6_FILIAL = DUD_FILIAL AND "
cSQL += " 			DT6_FILDOC = DUD_FILDOC AND "
cSQL += " 			DT6_DOC    = DUD_DOC    AND "
cSQL += " 			DT6_SERIE  = DUD_SERIE  AND "
cSQL += " 			DT6_DOCTMS IN('2','5')  AND "
cSQL += " 			DUD030.D_E_L_E_T_ = ' ' AND "
cSQL += " 			DT6030.D_E_L_E_T_ = ' ' "
*/

cSQL := " SELECT "
cSQL += "  	DUD_VIAGEM,DTC_DOC, DTC_SERIE, DTC_CLIDES, DTC_LOJDES, DTC_FILORI, DTC_NUMNFC, DTC_SERNFC, DTC_VALOR, DTC_EMINFC "
cSQL += " 	FROM "
cSQL += 		RetSQLName("DUD")+", "+RetSQLName("DT6")+", "+RetSQLName("DTC")
cSQL += " 		WHERE "
cSQL += " 			DUD_FILIAL = '"+xFilial("DUD")+"' AND "
cSQL += " 			DUD_VIAGEM BETWEEN '"+cViaDe+"' AND '"+cViaAte+"' AND "
cSQL += " 			DT6_FILIAL = DUD_FILIAL AND "
cSQL += " 			DT6_FILDOC = DUD_FILDOC AND "
cSQL += " 			DT6_DOC    = DUD_DOC    AND "
cSQL += " 			DT6_SERIE  = DUD_SERIE  AND "
cSQL += " 			DT6_DOCTMS IN('2','5')  AND "
cSQL += " 			DTC_DOC	   = DT6_DOC	AND "
cSQL += " 			DTC_SERIE  = DT6_SERIE	AND "
cSQL += " 			DTC_FILDOC = DT6_FILDOC AND "
cSQL += 			RetSQLName("DUD")+".D_E_L_E_T_ = ' ' AND "
cSQL += 			RetSQLName("DT6")+".D_E_L_E_T_ = ' ' AND "
cSQL += 			RetSQLName("DTC")+".D_E_L_E_T_ = ' ' "
cSQL += " ORDER BY DUD_VIAGEM, DTC_DOC, DTC_SERIE, DTC_FILORI, DTC_NUMNFC, DTC_SERNFC "

cSQL := ChangeQuery(cSQL)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),'QRYDUD',.T.,.F.)      

While !QRYDUD->(Eof())

	cViagem := QRYDUD->DUD_VIAGEM
	aNFCli := {}

	IncRegua()
	If Interrupcao(@lEnd)
		Exit
	Endif
	
	If !(QRYDUD->DT6_DOCTMS $ "25")  // Somente 2-CTRC e 5-Nota Fiscal.
		dbSkip()
		Loop
	EndIf

	aNFCli := FindNFCli(QRYDUD->DT6_DOC,QRYDUD->DT6_SERIE)
	For nI := 1 to Len(aNFCli)
		aAdd(aReg,{})
	Next nI	

	QRYDUD->(dbSkip())
EndDo
QRYDUD->(dbCloseArea())

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno    ณFindNFCli ณ Autor ณMaximo Canuto V. Neto  ณ Data ณ18.02.2002ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescrio ณImprime as notas do cliente contidas nos ctrc's             ณฑฑ
ฑฑณ Uso      ณ RTMSR09			                                          ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FindNFCli(cDoc,cSerie)
Local cSQL 	 := ""               
Local aNFCli := ""              

cSQL := " SELECT DTC_NUMNFC, DTC_SERNFC, DTC_VALOR "
cSQL += " FROM " + RetSQLName("DTC") 
cSQL += " WHERE DTC_DOC         = '"+cDoc+"' "
cSQL += "    AND DTC_SERIE      = '"+cSerie+"' "
cSQL += "    AND DTC_FILIAL     = '"+xFilial('DTC') + "' "
cSQL += "    AND "+RetSQLName("DTC")+".D_E_L_E_T_ = ' ' "
cSQL += " ORDER BY DTC_NUMNFC "

cSQL := ChangeQuery(cSQL)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),'QRYDTC',.T.,.F.)      

While !QRYDTC->(Eof())
	aadd(aNFCli,{QRYDTC->DTC_NUMNFC,QRYDTC->DTC_SERNFC,QRYDTC->DTC_VALOR})
	QRYDTC->(DbSkip())
Enddo
QRYDTC->(DbCloseArea())

Return aNFCli
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDIPA065   บAutor  ณMicrosiga           บ Data ณ  06/05/14   บฑฑ
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

aAdd(aRegs,{cPerg,"01","Viagem De   ?","","","mv_ch1","C", 6,0,0,"G","","MV_PAR01","","","","","","","","","","","","","","","","","","","","","","","","",'DTQ'})
aAdd(aRegs,{cPerg,"02","Viagem At้  ?","","","mv_ch2","C", 6,0,0,"G","","MV_PAR02","","","","","","","","","","","","","","","","","","","","","","","","",'DTQ'})
aAdd(aRegs,{cPerg,"03","Data	    ?","","","mv_ch3","D", 8,0,0,"G","","MV_PAR03","","","","","","","","","","","","","","","","","","","","","","","","",''})   
aAdd(aRegs,{cPerg,"04","Reenvio     ?","","","mv_ch4","N", 1,0,0,"C","","MV_PAR04","1-Nใo","","","","","2-Sim","","","","","","","","","","","","","","","","","","",''})
aAdd(aRegs,{cPerg,"05","Empresa     ?","","","mv_ch5","N", 1,0,0,"C","","MV_PAR05","1-Dipromed","","","","","2-HQ","","","","","3-Emovere","","","","","","","","","","","","","",''})
aAdd(aRegs,{cPerg,"06","Devolucao   ?","","","mv_ch6","N", 1,0,0,"C","","MV_PAR06","1-Nใo","","","","","2-Sim","","","","","","","","","","","","","","","","","","",''})

PlsVldPerg( aRegs )

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDIPA065   บAutor  ณMicrosiga           บ Data ณ  06/27/14   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function DipCriaLin(cTipo,lDipro,cPlaca,nTotViag,aDadosCli,lReenv)
Local cLinha 	 := ""        
Local cCNPJ		 := ""
DEFAULT cTipo 	 := ""
DEFAULT lDipro 	 := .F.
DEFAULT cPlaca 	 := ""
DEFAULT nTotViag := 0
DEFAULT aDadosCli:= {}
DEFAULT lReenv   := .F.

If cTipo == "E"
	cLinha += cTipo
	
	If lDipro
		cCNPJ := "47869078000100"
	ElseIf lEmove                 
		cCNPJ := "10245270000116"
	Else
		cCNPJ := "05150878000127"
	EndIf        
	
	cLinha += cCNPJ
	cLinha += SubStr(DtoS(dDataBase),7,2)+"/"+SubStr(DtoS(dDataBase),5,2)+"/"+SubStr(DtoS(dDataBase),1,4)
	cLinha += cPlaca//Placa
	cLinha += PadR(IIf(nTotViag>0,nTotViag,1),10)
	cLinha += PadR("20",4)
	cLinha += PadR("SP",8)
	cLinha += PadR(IIf(Left(aDadosCli[3],1)=="0","S","N"),2) //Transporte Urbano
	cLinha += IIf(lEmove," ","S")//Embarcador
	If cCNPJ == "05150878000127"
		cLinha += "47869078000100"
	Else               
		cLinha += cCNPJ
	EndIf
	cLinha += CHR(13)+CHR(10)
	cRegiao := Left(aDadosCli[3],1)

Else
	//Registro A
	cLinha += cTipo
	cLinha += PadR(aDadosCli[4],4) 	//Local Destino
	cLinha += PadR("1",4)			//Tipo Mercadoria
	If lEmove           
		If lReenv
			cLinha += PadR("REE",5)
			cLinha += PadR("694",4)				
		ElseIf lDev                             
			cLinha += PadR("DEV",5)
			cLinha += PadR("693",4)				
		Else
			cLinha += PadR("UELET",5)
			cLinha += PadR("540",4)		
		EndIf				
		cLinha += PadL(TRB_NF->DTC_DOC,10,"0")
	Else
		If lReenv
			cLinha += PadR("UREEN",5)
			cLinha += PadR("481",4)				
		ElseIf TRB_NF->DTC_CLIREM == '000804' .And. TRB_NF->DTC_LOJREM = '04'
			cLinha += PadR("FIL1",5)			
			cLinha += PadR("1399",4)
		Else
			cLinha += PadR("U",5)
			cLinha += PadR("282",4)
		EndIf				
		cLinha += PadL(TRB_NF->DTC_NUMNFC,10,"0")
	EndIf
	cLinha += StrTran(StrZero(TRB_NF->DTC_VALOR,13,2),".",",")
	cLinha += CHR(13)+CHR(10)       
EndIf

Return cLinha
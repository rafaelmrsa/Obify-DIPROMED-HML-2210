#INCLUDE "PROTHEUS.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DIPA059   ºAutor  ³Microsiga           º Data ³  09/10/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function DIPA059()  
Local oDlg
Local oFornec
Local oLoja     
Local oBOTAOOK
Local oBOTAOFECHAR
Local lCancel 		:= .F.            
Private cFornec 	:= Space(6)
Private cLoja	  	:= Space(2)
Private cNF  		:= Space(9)
Private cSerie  	:= Space(3)
Private cRegcert  	:= Space(20)
Private dEmissao	:= StoD("")
Private dEmisreg	:= StoD("")
Private nVlServ 	:= 0                 
Private cCondP		:= Space(3) 
Private _cUser      := Upper(U_DipUsr())

DEFINE MSDIALOG oDlg TITLE "Fornecedor" FROM 100,380 TO 600,650 PIXEL 
	
	@ 005,010 SAY "Cód. Fornecedor:" 				 SIZE 120,020 PIXEL OF oDLG
	@ 013,010 MSGET oFornec VAR cFornec F3 "SA2" 	 SIZE 070,010 PIXEL OF oDLG VALID cLoja:=SA2->A2_LOJA
	                                                       
	@ 030,010 SAY "Loja:"   						 SIZE 120,020 PIXEL OF oDLG
	@ 038,010 MSGET oLoja VAR cLoja 				 SIZE 070,010 PIXEL OF oDLG
	
	@ 055,010 SAY "NF:" 	  						 SIZE 120,020 PIXEL OF oDLG
	@ 063,010 MSGET oNF VAR cNF 					 SIZE 070,010 PIXEL OF oDLG PICTURE "@E 999999999"

	@ 080,010 SAY "Série:"   						 SIZE 120,020 PIXEL OF oDLG
	@ 088,010 MSGET oSerie VAR cSerie 				 SIZE 070,010 PIXEL OF oDLG 

	@ 105,010 SAY "Emissao:"   						 SIZE 120,020 PIXEL OF oDLG
	@ 113,010 MSGET oEmissao VAR dEmissao			 SIZE 070,010 PIXEL OF oDLG 

	@ 130,010 SAY "Valor do Serviço:"  				 SIZE 120,020 PIXEL OF oDLG
	@ 138,010 MSGET oVLServ VAR nVLServ 			 SIZE 070,010 PIXEL OF oDLG PICTURE "@E 99,999,999.99" VALID !Empty(nVLServ)

	@ 155,010 SAY "Cond. Pagto:"  	 				 SIZE 120,020 PIXEL OF oDLG
	@ 163,010 MSGET oCondP VAR cCondP F3 "SE4" 		 SIZE 070,010 PIXEL OF oDLG VALID !Empty(cCondP)
                                                                                                    
	@ 180,010 SAY "Dt.Reg.Cert.:"  	 				 SIZE 120,020 PIXEL OF oDLG
	@ 188,010 MSGET odEmisreg VAR dEmisreg     		 SIZE 070,010 PIXEL OF oDLG 
                                                                                                    
	@ 205,010 SAY "Regist. Cert.:"  				 SIZE 120,020 PIXEL OF oDLG
	@ 213,010 MSGET oRegcert VAR cRegcert     		 SIZE 070,010 PIXEL OF oDLG 

	@ 235,010 BUTTON oBOTAOOK     PROMPT   "&OK"   	 SIZE 030,010 PIXEL OF oDLG ACTION (ImpNF(),oDLG:END())
	@ 235,045 BUTTON oBOTAOFECHAR PROMPT   "&Fechar" SIZE 030,010 PIXEL OF oDLG ACTION (lCancel:=.T.,oDLG:END())

ACTIVATE MSDIALOG oDlg CENTERED 

If lCancel
	Aviso("Atenção","Importação cancelada pelo usuário",{"Ok"},1)
EndIf                

Return .T.    
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MA103OPC  ºAutor  ³Microsiga           º Data ³  09/10/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ImpNF()                                 
Local oDlg                                 
Local oMark                                
Local aStrut	:= {}
Local lOK		:= .F.
Local cSQL 		:= ""                                                     
Local lInverte 	:= .F.
Private cMarca 	:= GetMark()  
Private nVal1 	:= 0
Private nVal2 	:= 0
Private oVal1
Private oVal2
Private oMark     

aObjects := {}

aSize   := MsAdvSize()
aAdd(aObjects, {100, 100, .T., .T.})

aInfo   := {aSize[1], aSize[2], aSize[3], aSize[4], 2, 2}
aPosObj := MsObjSize(aInfo, aObjects)

SF1->(dbSetOrder(1))                 
If SF1->(dbSeek(xFilial("SF1")+cNF+cSerie+cFornec+cLoja))
	Aviso("Atenção","NF já existe na base de dados."+CHR(10)+CHR(13)+"Confira as informações digitadas.",{"Ok"},1)
	Return .F.
EndIf

aadd(aStrut,{"OK"    	 , "C" ,2,0})
aadd(aStrut,{"ALLOK"   	 , "C" ,2,0})
aadd(aStrut,{"F2_DOC"    , AvSx3("F2_DOC" ,2)     ,AvSx3("F2_DOC" ,3)     ,AvSx3("F2_DOC"    ,4)})
aadd(aStrut,{"F2_SERIE"  , AvSx3("F2_SERIE" ,2)   ,AvSx3("F2_SERIE" ,3)   ,AvSx3("F2_SERIE"  ,4)})
aadd(aStrut,{"F2_EMISSAO", AvSx3("F2_EMISSAO" ,2) ,AvSx3("F2_EMISSAO" ,3) ,AvSx3("F2_EMISSAO",4)})
aadd(aStrut,{"F2_CLIENTE", AvSx3("F2_CLIENTE" ,2) ,AvSx3("F2_CLIENTE" ,3) ,AvSx3("F2_CLIENTE",4)})
aadd(aStrut,{"F2_LOJA"   , AvSx3("F2_LOJA" ,2)    ,AvSx3("F2_LOJA" ,3)    ,AvSx3("F2_LOJA"   ,4)})
aadd(aStrut,{"F2_VALBRUT", AvSx3("F2_VALBRUT" ,2) ,AvSx3("F2_VALBRUT" ,3) ,AvSx3("F2_VALBRUT",4)})
aadd(aStrut,{"REC"		 , "N",12,0})

cArqTRB := CriaTrab(aStrut, .T.)
DBUSEAREA(.T.,,cArqTRB,"TRB_NF")

cIndTRB := CriaTrab(Nil,.F.)

TRB_NF->(DbCreateIndex(cIndTRB,"F2_DOC+F2_SERIE+DTOS(F2_EMISSAO)" ,{|| F2_DOC+F2_SERIE+DTOS(F2_EMISSAO) },.F.))
TRB_NF->(DbClearInd())
TRB_NF->(DbSetIndex(cIndTRB))
TRB_NF->(DbSetOrder(1))

cSQL := "SELECT "
cSQL +=	"	F2_DOC, F2_SERIE, F2_EMISSAO, F2_CLIENTE, F2_LOJA, F2_VALBRUT, R_E_C_N_O_ REC"
cSQL += " 	FROM "
cSQL += 		RetSQLName("SF2")	
cSQL += " 		WHERE "
cSQL += "			F2_FILIAL = '"+xFilial("SF2")+"' AND "
cSQL += "			F2_CLIENTE = '"+cFornec+"' AND "
cSQL += "			F2_LOJA = '"+cLoja+"' AND "            	
cSQL += "			F2_TIPO = 'B' AND "
cSQL += "			F2_XIMPHQ <> 'S' AND "
cSQL += " 			D_E_L_E_T_ = ' ' "                    
cSQL += "ORDER BY F2_DOC,F2_SERIE,F2_EMISSAO,F2_CLIENTE,F2_LOJA "

cSQL := ChangeQuery(cSQL)          
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),"TRBSF2",.T.,.T.)

TCSETFIELD("TRBSF2","F2_EMISSAO","D",08,0)     
TCSETFIELD("TRBSF2","F2_VALBRUT","N",14,2)     

While !TRBSF2->(Eof())
	TRB_NF->(dbAppend())  
	TRB_NF->OK		   := ' '
	TRB_NF->ALLOK	   := ' '
	TRB_NF->F2_DOC     := TRBSF2->F2_DOC
	TRB_NF->F2_SERIE   := TRBSF2->F2_SERIE
	TRB_NF->F2_EMISSAO := TRBSF2->F2_EMISSAO
	TRB_NF->F2_CLIENTE := TRBSF2->F2_CLIENTE
	TRB_NF->F2_LOJA    := TRBSF2->F2_LOJA
	TRB_NF->F2_VALBRUT := TRBSF2->F2_VALBRUT
	TRB_NF->REC		   := TRBSF2->REC
		
	TRBSF2->(dbSkip())
EndDo
TRBSF2->(dbCloseArea())

TRB_NF->(DbGoTop())                  
	
DEFINE MSDIALOG oDlg TITLE "Doctos de Saída" From aSize[7],005 TO aSize[6],aSize[5] OF oMainWnd PIXEL    

	@ 005,005 SAY "Valor Total" 	SIZE 100,008 			OF oDlg PIXEL
	@ 012,005 MSGET oVal1 VAR nVal1 SIZE 100,010 WHEN .F. 	OF oDlg PIXEL  PICTURE "@E 99,999,999.99"

	@ 005,135 SAY "Selecionados:"   SIZE 100,008 			OF oDlg PIXEL
	@ 012,135 MSGET oVal2 VAR nVal2	SIZE 100,010 WHEN .F. 	OF oDlg PIXEL  PICTURE "@E 999999"

	
	aCpos := {	{ "OK"    		, "", ""						 , "" },;
				{ "F2_DOC"		, "", A093RetDescr( "F2_DOC" 	), "" },;
				{ "F2_SERIE"  	, "", A093RetDescr( "F2_SERIE" 	), "" },;
				{ "F2_EMISSAO"  , "", A093RetDescr( "F2_EMISSAO"), "" },;
				{ "F2_CLIENTE"	, "", A093RetDescr( "F2_CLIENTE"), "" },;
				{ "F2_LOJA"		, "", A093RetDescr( "F2_CLIENTE"), "" },;
				{ "F2_VALBRUT"	, "", A093RetDescr( "F2_VALBRUT"), "" } }

	
	oMark 						:= MsSelect():New( "TRB_NF","OK",, aCpos, lInverte, cMarca, {aPosObj[1,1]+30,aPosObj[1,2],aPosObj[1,3],aPosObj[1,4]} )
	oMark:oBrowse:lCanAllMark	:= .T.                        
    oMark:baval 				:= {|| TRBMarca()}
	oMark:oBrowse:bAllMark 		:= {|| TRBMkAll()}

ACTIVATE MSDIALOG oDlg ON INIT (EnchoiceBar(oDlg,{|| GravaNF(),oDlg:End()},{|| oDlg:End()}))

TRB_NF->(dbCloseArea())

Return 
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MA103OPC  ºAutor  ³Microsiga           º Data ³  09/11/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function TRBMarca()
Local cAtual := TRB_NF->OK       

TRB_NF->(RecLock("TRB_NF",.F.))
	If cAtual == cMarca
	   TRB_NF->OK := Space(3)  
	   nVal1 -= TRB_NF->F2_VALBRUT
	   nVal2 --
	Else                          
	   TRB_NF->OK := cMarca
	   nVal1 += TRB_NF->F2_VALBRUT
	   nVal2 ++
	EndIf    
TRB_NF->(MsUnLock())                   

oVal1:Refresh()
oVal2:Refresh()

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TRBAllMark	ºAutor³	Microsiga  		   ºData³  12/09/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcao desenvolvida para marcar todos os Conhecimentos de   º±±
±±º          ³embarques                                                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³FAT - Dipromed                                              º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function TRBMkAll()
Local nRecTRB 	:= TRB_NF->(Recno())
Local cMarkAux	:= If(TRB_NF->ALLOK==cMarca,Space(2),cMarca)             

nVal1 := 0
nVal2 := 0
 
TRB_NF->(DbGoTop())

Do While TRB_NF->(!Eof())
	TRB_NF->(RecLock("TRB_NF",.F.))
		TRB_NF->ALLOK 	:= cMarkAux 
		TRB_NF->OK		:= cMarkAux
	
		If !Empty(cMarkAux)
			nVal1 += TRB_NF->F2_VALBRUT
			nVal2 ++
	    EndIf                      
	    
	TRB_NF->(MsUnlock())                  	
	TRB_NF->(DbSkip())
EndDo

TRB_NF->(DbGoTo(nRecTRB))

oVal1:Refresh()
oVal2:Refresh()

Return                                            
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MA103OPC  ºAutor  ³Microsiga           º Data ³  09/12/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function GravaNF()
Local lRet 		:= .T.    
Local lTemReg   := .F.
Local cChave 	:= ''
Local nRec   	:= 70  
Local cFornece 	:= ""
Local cLojaFor 	:= ""
Local aNfeCAB	:= {}
Local aNfeIte	:= {}
Private lQbgImpNF := .T.

TRB_NF->( DbGotop() )  

While !TRB_NF->(Eof())
	
	If !Empty(TRB_NF->OK)
	                     
		If Len(aNfeCAB)==0
			aNfeCAB := {{"F1_TIPO"    , "N"				   , Nil},;
			            {"F1_FORMUL"  , "N"                , Nil},;
			            {"F1_DOC"     , cNF  			   , Nil},;
			            {"F1_SERIE"   , cSerie			   , Nil},;
			            {"F1_EMISSAO" , dEmissao		   , Nil},;
			            {"F1_FORNECE" , TRB_NF->F2_CLIENTE , Nil},;
						{"F1_LOJA"    , TRB_NF->F2_LOJA    , Nil},;
						{"F1_COND"    , cCondP 			   , Nil},;
			            {"F1_ESPECIE" , 'NFE'              , Nil},;
   						{"F1_XDTRECE" , dEmisreg		   , Nil},;
						{"F1_XREGCER" , cRegcert		   , Nil},;
			            {"F1_XUSRECE" , _cUser             , Nil}}			            						
   						
		EndIf
	    
	    SD2->(dbSetOrder(3))
	    If SD2->(dbSeek(xFilial("SD2")+TRB_NF->(F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA)))
	    	While !SD2->(Eof()) .And. SD2->(D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA)==xFilial("SD2")+TRB_NF->(F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA)
		        AAdd(aNfeIte,{{"D1_COD"     , SD2->D2_COD     , NIL},;
		                      {"D1_QUANT"   , SD2->D2_QUANT   , NIL},;
		                      {"D1_VUNIT"   , SD2->D2_PRCVEN  , NIL},;
		                      {"D1_TOTAL"   , SD2->D2_TOTAL   , NIL},;
		   	                  {"D1_TES"     , "032"           , NIL},;
		                      {"D1_VALICM"  , SD2->D2_VALICM  , NIL},;
		                      {"D1_PICM"    , SD2->D2_PICM    , NIL},;
		                      {"D1_NFORI"   , SD2->D2_DOC	  , NIL},;
		                      {"D1_SERIORI" , SD2->D2_SERIE	  , NIL},;
		                      {"D1_LOTECTL" , SD2->D2_LOTECTL , NIL},;
		                      {"D1_DTVALID" , SD2->D2_DTVALID , NIL},;
		                      {"D1_BASEICM" , SD2->D2_BASEICM , NIL}})
	    		
	    		lTemReg := .T.
	    		SD2->(dbSkip())
	    	EndDo
	 	EndIf                    
	 	
	 	SF2->(dbGoTo(TRB_NF->REC))
	 	SF2->(RecLock("SF2",.F.))
	 		SF2->F2_XIMPHQ := "S"
	 	SF2->(MsUnlock())
	 	
	EndIf
	TRB_NF->(dbSkip())
EndDo            
	
If lTemReg
	AAdd(aNfeIte,{	{"D1_COD"     , "SERV01"	, NIL},;
					{"D1_QUANT"   , 1   		, NIL},;
					{"D1_VUNIT"   , nVLServ		, NIL},;
					{"D1_TOTAL"   , nVLServ 	, NIL},;
					{"D1_TES"     , "033"       , NIL},;
					{"D1_VALICM"  , 0  			, NIL},;
					{"D1_PICM"    , 0    		, NIL},;
					{"D1_BASEICM" , 0 			, NIL}})
					
	Begin Transaction
		lMsErroAuto := .F.
	
		MSExecAuto({|x,y,z| Mata103(x,y,z)},aNfeCab,aNfeIte,3)	
	
		If lMsErroAuto 
		   DisarmTransaction()
		   lRet := .F.
		   MostraErro()
		Endif
	
	End Transaction
EndIf
	
Return(lRet) 
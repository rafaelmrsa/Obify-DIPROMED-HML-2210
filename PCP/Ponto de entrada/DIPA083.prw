#INCLUDE "PROTHEUS.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณNOVO30    บAutor  ณMicrosiga           บ Data ณ  04/07/17   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function DIPA083()
Local cChave := cFilAnt+"_TRANSF_FILIAIS"     

AjustaSX1()                      

If Upper(u_DipUsr())$GetNewPar("ES_DIPA083","DDOMINGOS")
	If LockByName(cChave,.T.,.F.)				
		SetFunName("MATA310")  
		PutMv("ES_TRAVA83",.T.)
		MATA310()	 		
		PROCESSA ({|| Dip083End()},"Endere็ando Produtos","Aguarde Processando....",.T.)
		UnLockByName(cChave,.T.,.F.)
	Else 
		Aviso("Aten็ใo","Outro processo de movimenta็ใo de estoque estแ impedindo a execu็ใo desta rotina. Tente novamente mais tarde.",{"Ok"})
	EndIf
Else
	Aviso("Aten็ใo","Usuแrio sem acesso.",{"Ok"})
EndIf          
	  
Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDIPA083   บAutor  ณMicrosiga           บ Data ณ  04/13/17   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Dip083End()
Local cSQL 		 := ""      
Local aIteDipSDB := {}
   
cSQL := " SELECT TOP 1"
cSQL += " 	ZZU_NOTA DOC "
cSQL += "	FROM "
cSQL += 		RetSQLName("ZZU")
cSQL += "		WHERE "
cSQL += "			ZZU_FILIAL = '"+xFilial("ZZU")+"' AND "
cSQL += "			ZZU_STATUS = '1' AND " 
cSQL += "			ZZU_NOTA <> ' ' AND "
cSQL += "			D_E_L_E_T_ = ' ' "
cSQL += " ORDER BY R_E_C_N_O_ DESC " 

cSQL := ChangeQuery(cSQL)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),"QRYZZU",.T.,.T.)
           
If !QRYZZU->(Eof())		
	cSQL := " SELECT "
	cSQL += "		DB_DOC, DB_SERIE, DB_PRODUTO, DB_LOCAL, DB_LOTECTL, DB_LOCALIZ, DB_QUANT "
	cSQL += "		FROM "
	cSQL += 			RetSQLName("SDB")
	cSQL += "			WHERE "
	cSQL += "				DB_FILIAL  = '"+xFilial("SDB")+"' AND "
	cSQL += "				DB_DOC 	   = '"+QRYZZU->DOC+"' AND "
	cSQL += "				D_E_L_E_T_ = ' ' "
	cSQL += " ORDER BY DB_PRODUTO, DB_LOCAL, DB_LOTECTL "  

	cSQL := ChangeQuery(cSQL)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),"DIPSDB",.T.,.T.)
		
	While !DIPSDB->(Eof())
	
		aAdd(aIteDipSDB,{DIPSDB->DB_DOC,;					
						 DIPSDB->DB_SERIE,;
						 DIPSDB->DB_PRODUTO,;
						 IIf(DIPSDB->DB_LOCAL=="02","01",DIPSDB->DB_LOCAL),;
						 DIPSDB->DB_LOTECTL,;
						 DIPSDB->DB_LOCALIZ,;
						 DIPSDB->DB_QUANT})				
						
		DIPSDB->(dbSkip())
	EndDo
	DIPSDB->(dbCloseArea())				
EndIf
QRYZZU->(dbCloseArea())				
		
If Len(aIteDipSDB)>0
	DipEnd083(aIteDipSDB)
EndIf

Return                
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDIPA083   บAutor  ณMicrosiga           บ Data ณ  04/13/17   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function DipEnd083(aIteDipSDB)
Local aArea    := GetArea()
Local lRet     := .T.
Local cSeek    := ''
Local cLoteSDA := ''
Local lRastro  := ''
Local cItens   := '0000'                    
Local cLocaliz := ""
Local cTime    := SubStr(Time(),1,2)+"_"+SubStr(Time(),4,2)
Local sDate    := dtos(Date())
Local cMsgCic  := ""
Local cEnd     := CHR(10)+CHR(13)+CHR(10)+CHR(13)    
Local _cUPD	   := "" 
Local _lProx   := ""

Private aCabec:= {}
Private aItem := {}
Private aItens := {}   

DEFAULT aIteDipSDB := {}
       
cDocSDA := aIteDipSDB[1,1]  

If cEmpAnt+cFilAnt=="0401"
	GetEmpr('0402')							
Else 
	GetEmpr('0401')							
EndIf				

BEGIN TRANSACTION				
	    
	SDA->(dbSetFilter({|| SDA->DA_FILIAL==xFilial("SDA") .And. SDA->DA_DOC==cDocSDA},"SDA->DA_FILIAL==xFilial('SDA') .And. SDA->DA_DOC==cDocSDA"))	
	                                                          
	For nI:=1 to Len(aIteDipSDB)                               
		
		_lProx := .F.
		
		SDA->( DbSetOrder(2) )          
		If SDA->(dbSeek(xFilial("SDA")+aIteDipSDB[nI,3]+aIteDipSDB[nI,4]+aIteDipSDB[nI,5]))      	
			
			SB2->(dbSetFilter({|| SB2->B2_FILIAL==xFilial("SB2") .And. SB2->B2_COD    ==SDA->DA_PRODUTO},"SB2->B2_FILIAL==xFilial('SB2') .And. SB2->B2_COD    ==SDA->DA_PRODUTO"))
			SBF->(dbSetFilter({|| SBF->BF_FILIAL==xFilial("SBF") .And. SBF->BF_PRODUTO==SDA->DA_PRODUTO},"SBF->BF_FILIAL==xFilial('SBF') .And. SBF->BF_PRODUTO==SDA->DA_PRODUTO"))
			SB8->(dbSetFilter({|| SB8->B8_FILIAL==xFilial("SB8") .And. SB8->B8_PRODUTO==SDA->DA_PRODUTO},"SB8->B8_FILIAL==xFilial('SB8') .And. SB8->B8_PRODUTO==SDA->DA_PRODUTO"))
			
			While !SDA->(Eof()) .And. SDA->(DA_FILIAL+DA_PRODUTO+DA_LOCAL+DA_LOTECTL)==xFilial("SDA")+aIteDipSDB[nI,3]+aIteDipSDB[nI,4]+aIteDipSDB[nI,5]
			
				If SDA->DA_DOC<>aIteDipSDB[nI,1] .Or. SDA->DA_SALDO==0 .Or. SDA->DA_SALDO <> aIteDipSDB[nI,7] .Or. _lProx
					SDA->(dbSkip())
					Loop                        
				EndIf    			
				
				aCabec := {}
				aItem  := {}
				
				Aadd(aCabec, {"DA_PRODUTO"  , SDA->DA_PRODUTO  , nil})
				Aadd(aCabec, {"DA_QTDORI"   , SDA->DA_QTDORI   , nil})
				Aadd(aCabec, {"DA_SALDO"    , SDA->DA_SALDO    , nil})
				Aadd(aCabec, {"DA_DATA"     , SDA->DA_DATA     , nil})	
				Aadd(aCabec, {"DA_LOTECTL"  , SDA->DA_LOTECTL  , nil})
				Aadd(aCabec, {"DA_NUMLOTE"  , SDA->DA_NUMLOTE  , nil})	
				Aadd(aCabec, {"DA_LOCAL"    , SDA->DA_LOCAL    , nil})
				Aadd(aCabec, {"DA_DOC"      , SDA->DA_DOC      , nil})
				Aadd(aCabec, {"DA_SERIE"    , SDA->DA_SERIE    , nil})
				Aadd(aCabec, {"DA_CLIFOR"   , SDA->DA_CLIFOR   , nil})
				Aadd(aCabec, {"DA_LOJA"     , SDA->DA_LOJA     , nil})
				Aadd(aCabec, {"DA_TIPONF"   , SDA->DA_TIPONF   , nil})
				Aadd(aCabec, {"DA_ORIGEM"   , SDA->DA_ORIGEM   , nil})
				Aadd(aCabec, {"DA_NUMSEQ"   , SDA->DA_NUMSEQ   , nil})
				Aadd(aCabec, {"DA_QTSEGUM"  , SDA->DA_QTSEGUM  , nil})
				Aadd(aCabec, {"DA_QTDORI2"  , SDA->DA_QTDORI2  , nil})
				
				cItens  := '0'
				aITens  := {}	
				aNfeITE := {}
				
				cItens := STRZERO(VAL(cItens)+1,4)
			
				AAdd(aNfeIte,{	{"DB_ITEM"     	, cItens        								, NIL},;
								{"DB_LOCALIZ"  	, aIteDipSDB[nI,6]								, NIL},;
								{"DB_NUMSERI"  	, ''            	   							, NIL},;
								{"DB_QUANT"    	, aIteDipSDB[nI,7]  							, NIL},;
								{"DB_HRINI"    	, Time()        	 							, NIL},;
								{"DB_DATA"		, ddatabase     								, NIL},;
								{"DB_ESTORNO"  	, ''            								, NIL},;
								{"DB_QTSEGUMD"  , ConvUm(aIteDipSDB[nI,3],aIteDipSDB[nI,7],0,2)	, NIL} } )
			
				lMsErroAuto := .F.
	
				MsExecAuto({|x,y,z| mata265(x,y,z)},aCabec,aNfeITE,3) // 3-Distribui, 4-Estorna
				
				If lMsErroAuto
					DisarmTransaction()
					MostraErro()
					lRet := .F.
				Else
					u_DIPXRESE("ISDB",nil,nil,SDA->DA_PRODUTO,SDA->DA_LOCAL,nil,aIteDipSDB[nI,7])
					_lProx := .T.
				Endif
				
				SDA->(dbSkip())  
			EndDo	
			
			SB2->(dbSetFilter({|| .t.},".t."))
			SBF->(dbSetFilter({|| .t.},".t."))
			SB8->(dbSetFilter({|| .t.},".t."))					
		EndIf		
		
	Next nI
	
	SDA->(dbSetFilter({|| .t.},".t.")) 
	
	If cEmpAnt+cFilAnt=="0401"
		GetEmpr('0402')							
	Else 
		GetEmpr('0401')							
	EndIf		  
	
	_cUPD := " UPDATE "+RetSQLName("ZZU")+" SET ZZU_STATUS = '2' WHERE ZZU_STATUS <> '2' AND D_E_L_E_T_ = ' ' "
	TcSqlExec(_cUPD)						
	                                    
	// Provis๓rio
	cMsgCic := "TRANSFERสNCIA ENTRE FILIAIS - "+cDocSDA+cEnd
	cMsgCic += "Usuแrio: "+U_DipUsr()	
	U_DIPCIC(cMsgCic,"CAROLINA.SOSSOLOTE")

END TRANSACTION
	
RestArea(aArea)

Return(lRet)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDIPA083   บAutor  ณMicrosiga           บ Data ณ  04/20/17   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function AjustaSX1()
Local aArea		:= GetArea()
Local nDipTam 	:= 0

dbSelectArea("SX1")
dbSetOrder(1)   

nDipTam := Len( SX1->X1_GRUPO )

If SX1->(DbSeek(PadR("MTA310",nDipTam)+"13"))
	If SX1->X1_GSC <> "S" .Or. SX1->X1_CNT01 <> "785"
		SX1->(RecLock("SX1",.F.))
			Replace	SX1->X1_GSC   With "S"
			Replace SX1->X1_CNT01 With "785"
		SX1->(MsUnlock())
	EndIf
EndIf

If SX1->(DbSeek(PadR("MTA310",nDipTam)+"15"))
	If SX1->X1_GSC <> "S" .Or. SX1->X1_CNT01 <> "060"
		SX1->(RecLock("SX1",.F.))
			Replace	SX1->X1_GSC   With "S"    
			Replace SX1->X1_CNT01 With "060"
		SX1->(MsUnlock())
	EndIf
EndIf

RestArea(aArea)

Return
#INCLUDE "PROTHEUS.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGERASF6   บAutor  ณMicrosiga           บ Data ณ  06/18/15   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function GeraSF6() 
Local cSQL  := ""
Local cPerg := "GERSF6"                         
Local cCodRec := ""

If !Upper(u_DipUsr())$GetNewPar("ES_GERASF6","DDOMINGOS/MCANUTO/SCREATTO")
	Aviso("Aten็ใo","Usuแrio sem acesso a esta fun็ใo.",{"Ok"},1)
	Return
EndIf

AjustaSX1(cPerg)     

If !Pergunte(cPerg,.T.)
	Return
EndIf

If MV_PAR02 > MV_PAR01 .And. !Empty(MV_PAR01) .And. !Empty(MV_PAR02)
	
	cSQL := " SELECT "
	cSQL += "	* "
	cSQL += " 	FROM "
	cSQL += 		RetSQLName("SF2")
	cSQL += "		WHERE "
	cSQL += "			F2_FILIAL = '"+xFilial("SF2")+"' AND "
	cSQL += "			F2_TIPO IN ('N','I') AND "
	cSQL += "			F2_EMISSAO BETWEEN '"+DTOS(MV_PAR01)+"' AND '"+DTOS(MV_PAR02)+"' AND "
	cSQL += "			F2_ICMSRET > 0  AND "
	cSQL += "			D_E_L_E_T_ = ' ' AND "
	cSQL += "			F2_CHVNFE <> ' ' "
	
	cQuery := ChangeQuery(cSQL)                                
	dbUseArea( .T., "TOPCONN", TCGenQry(,,cSQL), "TRBSF2", .F., .T.)
	
	TcSetField("TRBSF2","F2_EMISSAO","D",08,0)
	
	While !TRBSF2->(Eof())       
		If !TRBSF2->F2_EST$GetNewPar("MV_SUBTRIB","")                    
			SF6->(dbSetOrder(1))
			If !SF6->(dbSeek(xFilial("SF6")+TRBSF2->(F2_EST+F2_DOC)))
				SF6->(RecLock("SF6",.T.))
					SF6->F6_FILIAL  := xFilial("SF6")
					SF6->F6_EST     := TRBSF2->F2_EST
					SF6->F6_NUMERO  := TRBSF2->F2_DOC
					SF6->F6_VALOR 	:= TRBSF2->F2_ICMSRET
					SF6->F6_DTARREC := TRBSF2->F2_EMISSAO
					SF6->F6_DTVENC	:= TRBSF2->F2_EMISSAO
					SF6->F6_MESREF	:= Val(SubStr(DtoS(TRBSF2->F2_EMISSAO),5,2))
					SF6->F6_ANOREF	:= Val(SubStr(DtoS(TRBSF2->F2_EMISSAO),1,4))
					SF6->F6_TIPOIMP := '3'
					SF6->F6_CODREC  := '100099'
					SF6->F6_DOC    	:= TRBSF2->F2_DOC
					SF6->F6_SERIE  	:= TRBSF2->F2_SERIE
					SF6->F6_CLIFOR 	:= TRBSF2->F2_CLIENTE
					SF6->F6_LOJA   	:= TRBSF2->F2_LOJA				
					SF6->F6_OPERNF  := '2'
				SF6->(MsUnlock())
				
				CDC->(dbSetOrder(2))
				If !CDC->(dbSeek(xFilial("CDC")+TRBSF2->(F2_DOC+F2_EST)))
					CDC->(RecLock("CDC",.T.))
						CDC->CDC_FILIAL := xFilial("CDC")
						CDC->CDC_TPMOV  := 'S'
						CDC->CDC_DOC    := TRBSF2->F2_DOC
						CDC->CDC_SERIE  := TRBSF2->F2_SERIE
						CDC->CDC_CLIFOR := TRBSF2->F2_CLIENTE
						CDC->CDC_LOJA   := TRBSF2->F2_LOJA
						CDC->CDC_GUIA   := TRBSF2->F2_DOC
						CDC->CDC_UF     := TRBSF2->F2_EST
						CDC->CDC_IFCOMP := '000001'
					CDC->(MsUnlock())
				EndIf
			EndIf
		EndIf		
		TRBSF2->(dbSkip())
	EndDo
	TRBSF2->(dbCloseArea())
	
	cSQL := " SELECT "
	cSQL += "	SUM(D2_DIFAL) D2_DIFAL, SUM(D2_VFCPDIF) D2_VFCPDIF, D2_FILIAL, D2_EST, D2_DOC, D2_SERIE, D2_EMISSAO, D2_CLIENTE, D2_LOJA "
	cSQL += " 	FROM "
	cSQL += 		RetSQLName("SD2")
	cSQL += "		WHERE "
	cSQL += "			D2_FILIAL IN ('01','04') AND "
	cSQL += "			D2_TIPO IN ('N','I') AND "
	cSQL += "			D2_EMISSAO BETWEEN '"+DTOS(MV_PAR01)+"' AND '"+DTOS(MV_PAR02)+"' AND "
	cSQL += "			D2_DIFAL > 0  AND "
	cSQL += "			D_E_L_E_T_ = ' ' "
	cSQL += " GROUP BY D2_FILIAL, D2_EST, D2_DOC, D2_SERIE, D2_EMISSAO, D2_CLIENTE, D2_LOJA "   
	cSQL += " ORDER BY D2_FILIAL, D2_EST, D2_DOC, D2_SERIE "
		
	cQuery := ChangeQuery(cSQL)                                
	dbUseArea( .T., "TOPCONN", TCGenQry(,,cSQL), "TRBSD2", .F., .T.)
	
	TcSetField("TRBSD2","D2_EMISSAO","D",08,0)
	TcSetField("TRBSD2","D2_DIFAL"  ,"N",14,2)	
	
	While !TRBSD2->(Eof())                      
		If !TRBSD2->D2_EST$GetNewPar("MV_SUBTRIB","")

			If TRBSD2->D2_EST == "DF"
				cCodRec := "1575"
			ElseIf TRBSD2->D2_EST == "ES"
				cCodRec := "386-7"
			Else 
				cCodRec := "100102"
			EndIf

			SF6->(dbSetOrder(3))
			If !SF6->(dbSeek(TRBSD2->D2_FILIAL+'2 '+TRBSD2->(D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA)))
				SF6->(RecLock("SF6",.T.))
					SF6->F6_FILIAL  := TRBSD2->D2_FILIAL
					SF6->F6_EST     := TRBSD2->D2_EST
					SF6->F6_NUMERO  := TRBSD2->D2_DOC
					SF6->F6_VALOR 	:= TRBSD2->(D2_DIFAL+D2_VFCPDIF)
					SF6->F6_DTARREC := TRBSD2->D2_EMISSAO
					SF6->F6_DTVENC	:= TRBSD2->D2_EMISSAO
					SF6->F6_MESREF	:= Val(SubStr(DtoS(TRBSD2->D2_EMISSAO),5,2))
					SF6->F6_ANOREF	:= Val(SubStr(DtoS(TRBSD2->D2_EMISSAO),1,4))
					SF6->F6_TIPOIMP := 'B'
					SF6->F6_CODREC  := cCodRec
					SF6->F6_DOC    	:= TRBSD2->D2_DOC
					SF6->F6_SERIE  	:= TRBSD2->D2_SERIE
					SF6->F6_CLIFOR 	:= TRBSD2->D2_CLIENTE
					SF6->F6_LOJA   	:= TRBSD2->D2_LOJA				
					SF6->F6_OPERNF  := '2'
					SF6->F6_COBREC  := '003' 
					SF6->F6_PROCESS := '2'					
				SF6->(MsUnlock())
				
				CDC->(dbSetOrder(1))
				If !CDC->(dbSeek(TRBSD2->D2_FILIAL+'S'+TRBSD2->(D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA)))
					CDC->(RecLock("CDC",.T.))
						CDC->CDC_FILIAL := TRBSD2->D2_FILIAL
						CDC->CDC_TPMOV  := 'S'
						CDC->CDC_DOC    := TRBSD2->D2_DOC
						CDC->CDC_SERIE  := TRBSD2->D2_SERIE
						CDC->CDC_CLIFOR := TRBSD2->D2_CLIENTE
						CDC->CDC_LOJA   := TRBSD2->D2_LOJA
						CDC->CDC_GUIA   := TRBSD2->D2_DOC
						CDC->CDC_UF     := TRBSD2->D2_EST
						CDC->CDC_IFCOMP := '000003'
					CDC->(MsUnlock())
				EndIf
			EndIf
		EndIf
		TRBSD2->(dbSkip())
	EndDo
	TRBSD2->(dbCloseArea())
	
	Aviso("Aten็ใo","Processo finalizado com sucesso.",{"Ok"},1)
Else 
	Aviso("Aten็ใo","Parโmetros invแlidos",{"Ok"},1)
EndIf
	
Return()
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGERASF6   บAutor  ณMicrosiga           บ Data ณ  06/18/15   บฑฑ
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
Local aRegs := {}

aAdd(aRegs,{cPerg,"01","Data De     ?","","","mv_ch1","D", 8,0,0,"G","","MV_PAR01","","","","","","","","","","","","","","","","","","","","","","","","",''})
aAdd(aRegs,{cPerg,"02","Data At้    ?","","","mv_ch2","D", 8,0,0,"G","","MV_PAR02","","","","","","","","","","","","","","","","","","","","","","","","",''})

PlsVldPerg( aRegs )       

Return 

#INCLUDE "PROTHEUS.CH"        
#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"  
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³NOVO23    ºAutor  ³Microsiga           º Data ³  04/06/17   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function MTA310OK()
Local aItens := ParamIXB[1]
Local lRet   := .T.

lRet := DipVldPed()

cNextCod := NextCodZU()                            

For nI:=1 to Len(aItens)    
	If VldPriVez(aItens[nI,02],aItens[nI,03],aItens[nI,17],aItens[nI,20],aItens[nI,04])                             	
		ZZU->(RecLock("ZZU",.T.))
			ZZU->ZZU_FILIAL := xFilial("ZZU") 
			ZZU->ZZU_CODIGO := cNextCod
			ZZU->ZZU_CODPRO := aItens[nI,02]
			ZZU->ZZU_LOCAL  := aItens[nI,03]
			ZZU->ZZU_LOTECT := aItens[nI,17]
			ZZU->ZZU_LOCALI := aItens[nI,20]
			ZZU->ZZU_QUANT  := aItens[nI,04]
			ZZU->ZZU_STATUS := "1"
			ZZU->ZZU_DATA   := dDataBase
			ZZU->ZZU_USUARI := u_DipUsr()
			ZZU->ZZU_HORA   := Left(Time(),5)
		ZZU->(MsUnlock())
	EndIf
Next nI          

Return lRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MTA310OK  ºAutor  ³Microsiga           º Data ³  04/10/17   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function NextCodZU() 
Local cNextCod := ""
Local cSQL := ""

cSQL := " SELECT "
cSQL += " 	MAX(ZZU_CODIGO) CODIGO "
cSQL += " 	FROM "
cSQL +=  		RetSQLName("ZZU")
cSQL += " 		WHERE "
cSQL += " 			ZZU_FILIAL = '"+xFilial("ZZU")+"' AND "
cSQL += " 			D_E_L_E_T_ = ' ' "          

cSQL := ChangeQuery(cSQL)          
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),"ZZUTRB",.T.,.T.)    

If !ZZUTRB->(Eof())
	cNextCod := SOMA1(ZZUTRB->CODIGO)
Else
	cNextCod := "000001"
EndIf
ZZUTRB->(dbCloseArea())

Return cNextCod
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MTA310OK  ºAutor  ³Microsiga           º Data ³  04/13/17   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function VldPriVez(cCodigo,cLocal,cLoteCTL,cLocaliz,nQuant)
Local lRet := .T.
Local cSQL := ""

cSQL := " SELECT "
cSQL += " 	ZZU_CODIGO "
cSQL += " 	FROM "
cSQL +=  		RetSQLName("ZZU")
cSQL += " 		WHERE "
cSQL += " 			ZZU_FILIAL = '"+xFilial("ZZU")+"' AND "  
cSQL += " 			ZZU_CODPRO = '"+cCodigo+"' AND "
cSQL += " 			ZZU_LOCAL  = '"+cLocal+"' AND "
cSQL += " 			ZZU_LOTECT = '"+cLoteCTL+"' AND "
cSQL += " 			ZZU_LOCALI = '"+cLocaliz+"' AND "
cSQL += " 			ZZU_QUANT  = '"+AllTrim(Str(nQuant))+"' AND "
cSQL += " 			ZZU_USUARI = '"+U_DipUsr()+"' AND "
cSQL += " 			ZZU_STATUS = '1' AND "
cSQL += " 			ZZU_NOTA   = ' ' AND "
cSQL += " 			ZZU_DATA   = '"+DtoS(dDataBase)+"' AND "
cSQL += " 			D_E_L_E_T_ = ' ' "

cSQL := ChangeQuery(cSQL)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),"QRYZZU",.T.,.T.)	  

If !QRYZZU->(Eof())
	lRet := .F.
EndIf
QRYZZU->(dbCloseArea())					

Return lRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MTA310OK  ºAutor  ³Microsiga           º Data ³  04/20/17   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function DipVldPed() 
Local lRet      := .T.
Local cSQL 		:= ""
Local cCLiente 	:= IIf(cFilAnt=="01","019170","011050")  
Local nMinutos  := GetNewPar("ES_NHQMINU",5)           
Local nMinAux   := 0 
                         
If GetMV("ES_TRAVA83")
	cSQL := " SELECT TOP 1 "
	cSQL += "	C5_HR_PRE "
	cSQL += "	FROM "
	cSQL += 		RetSQLName("SC5")
	cSQL += "		WHERE "
	cSQL += "			C5_FILIAL  = '"+xFilial("SC5")+"' AND "
	cSQL += "			C5_CLIENTE = '"+cCLiente+"' AND "
	cSQL += "			C5_LOJACLI = '01' AND "   
	cSQL += "			C5_QUEMCON = 'TRANSFERENCIA ENTRE FILIAIS' AND "   
	cSQL += "			C5_DT_PRE  = '"+DtoS(dDataBase)+"' AND "
	cSQL += "			D_E_L_E_T_ = ' ' "
	cSQL += " ORDER BY R_E_C_N_O_ DESC "             
	
	cSQL := ChangeQuery(cSQL)          
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),"DIPSC5",.T.,.T.)          
	
	If !DIPSC5->(Eof())  
		If Left(DIPSC5->C5_HR_PRE,2)==Left(Time(),2) 
			nMinAux := (Val(SubStr(DIPSC5->C5_HR_PRE,4,2))-Val(SubStr(Time(),4,2)))
			If nMinAux < 0
				nMinAux := nMinAux*-1   
			EndIf
			If nMinAux <= nMinutos     
				Aviso("Atenção","Foi encontrada outra transferência em menos de "+cValToChar(nMinutos)+" minutos."+CHR(13)+CHR(10)+;
								"Não será permitido confirmar novamente."+CHR(13)+CHR(10)+;
								"Clique no botão fechar.",{"Ok"},2)
				PutMv("ES_TRAVA83",.F.)				
				lRet := .F.
			EndIf
		EndIf
	EndIf
	DIPSC5->(dbCloseArea())
Else 
	Aviso("Atenção","Transferência duplicada."+CHR(13)+CHR(10)+;
					"Não será permitido confirmar."+CHR(13)+CHR(10)+;
					"Clique no botão fechar.",{"Ok"},2)
	lRet := .F.
EndIf
Return lRet
#INCLUDE "PROTHEUS.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DIPHISGOS ºAutor  ³Microsiga           º Data ³  11/19/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function DipHistOS(lTerreo,lMezan,cPedido,cOrdSep) 
Local aAreaSC9	:= SC9->(GetArea())
Local aAreaSC5	:= SC5->(GetArea())
Local aAreaSA1	:= SA1->(GetArea())    
Local lAtuEst	:= .F.
Local aLibPed	:= U_DIPDatLib(cPedido)
DEFAULT lTerreo := .F.
DEFAULT lMezan  := .F.
DEFAULT cPedido := ""    
DEFAULT cOrdSep := ""

//Enviar cic para notafiscal e valdo
lAtuEst := U_DipAtuEst(cPedido)    

SC5->(dbSetOrder(1))
If !SC5->(dbSeek(xFilial("SC5")+cPedido))  
	Return(Aviso("Atenção","Pedido ("+AllTrim(cPedido)+") não encontrado.",{"Ok"},1))
EndIf

If lAtuEst
	BEGIN TRANSACTION
		ZZ5->(RecLock("ZZ5",.T.))    
			ZZ5->ZZ5_FILIAL := xFilial("ZZ5")  
			ZZ5->ZZ5_STATUS := "1"
			ZZ5->ZZ5_TRANSP := SC5->C5_TRANSP
			ZZ5->ZZ5_PEDIDO := SC5->C5_NUM
			If Len(aLibPed) > 0 
				ZZ5->ZZ5_DTPEDI := aLibPed[1]
				ZZ5->ZZ5_HORLIB := aLibPed[2]
			EndIf
			ZZ5->ZZ5_MENDEP := SC5->C5_MENDEP
			ZZ5->ZZ5_OBSPRE := POSICIONE("SA1",1,xFilial("SA1")+SC5->(C5_CLIENTE+C5_LOJACLI),"A1_OBSPRE") 
			ZZ5->ZZ5_ORDSEP := cOrdSep     
			ZZ5->ZZ5_CLIENT := SC5->C5_CLIENTE
			ZZ5->ZZ5_LOJA   := SC5->C5_LOJACLI
			Do Case
				Case lTerreo .And. lMezan 
					ZZ5->ZZ5_TIPOTM  := "Térreo/Mezanino"
				Case lTerreo     
					ZZ5->ZZ5_TIPOTM  := "Térreo"	
				Case lMezan
					ZZ5->ZZ5_TIPOTM  := "Mezanino"
			EndCase			
		ZZ5->(MsUnlock())  
	END TRANSACTION   
EndIf
	
RestArea(aAreaSA1)
RestArea(aAreaSC5)
RestArea(aAreaSC9)

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DIPHISTOS ºAutor  ³Microsiga           º Data ³  12/05/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function DipAtuEst(cPedido)
Local cSQL := ""
Local lRet := .F.
DEFAULT cPedido := ""
	
cSQL := " SELECT COUNT(1) COUNT "
cSQL += " FROM "+RetSQLName("SC6")+", "+RetSQLName("SF4")
cSQL += " WHERE C6_FILIAL = '"+xFilial("SC6")+"' " 
cSQL += " AND C6_NUM = '"+cPedido+"' "
cSQL += " AND F4_FILIAL = '"+xFilial("SF4")+"' "
cSQL += " AND F4_CODIGO = C6_TES "
cSQL += " AND F4_ESTOQUE = 'S' "
cSQL += " AND "+RetSQLName("SF4")+".D_E_L_E_T_ = ' ' "
cSQL += " AND "+RetSQLName("SC6")+".D_E_L_E_T_ = ' ' "

cSQL := ChangeQuery(cSQL)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),"ATUEST",.T.,.T.)

TCSETFIELD("ATUEST","COUNT","N",12,0)

lRet := (ATUEST->COUNT > 0)

ATUEST->(dbCloseArea())

Return lRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DIPHISTOS ºAutor  ³Microsiga           º Data ³  05/22/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function DIPDatLib(cPedido)  // MCVN 05/03/07
Local cSQL 		 := ""
Local dDtLib     := StoD("")
Local cHrLib     := ""
Local dDtLibCred := StoD("")
Local cHrLibCred := ""           
DEFAULT cPedido  := ""

cSQL := "SELECT Z9_PEDIDO, Z9_DATAMOV, Z9_HORAMOV, Z9_OCORREN "
cSQL += " FROM  "+RetSQLName('SZ9')
cSQL += " WHERE D_E_L_E_T_ = ' ' "
cSQL += " AND Z9_FILIAL = '"+xFilial('SZ9')+"'"
cSQL += " AND Z9_PEDIDO = '"+cPedido+"'"
cSQL += " AND Z9_OCORREN IN ('10','16','26')"
cSQL += " ORDER BY Z9_DATAMOV, Z9_HORAMOV, Z9_PEDIDO,Z9_OCORREN

cSQL := ChangeQuery(cSQL)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),"QRYSZ9",.T.,.T.)

TCSETFIELD("QRYSZ9","Z9_DATAMOV","D",8,0)

While !QRYSZ9->(Eof())

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Faço o While e uso as comparações de data de liberação e liberação do crédito para previnir um possível erro na gravação do kardex SZ9.³
	//³Se por um acaso gravar a liberação do crédito em data/hora menor esta comparação vai corrigir a gravação da ZZ5                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	If QRYSZ9->Z9_OCORREN = "10" .OR. QRYSZ9->Z9_OCORREN = "16"
		dDtLib := QRYSZ9->Z9_DATAMOV
		cHrLib := Left(QRYSZ9->Z9_HORAMOV,5)
	EndIf
	
	If QRYSZ9->Z9_OCORREN = "26"
		dDtLibCred := QRYSZ9->Z9_DATAMOV
		cHrLibCred := Left(QRYSZ9->Z9_HORAMOV,5)
	EndIf
	
	QRYSZ9->(dbSkip())
Enddo
QRYSZ9->(dbCloseArea())

If Empty(dDtLibCred) .OR. dDtLibCred = NiL
	dDtLibCred := dDtLib
	cHrLibCred := cHrLib
EndIf

If Empty(dDtLibCred) .OR. dDtLibCred = NiL
	dDtLibCred := SC5->(POSICIONE("SC5",1,xFilial("SC5")+cPedido,"C5_DTPEDID"))
	cHrLibCred := SC5->(POSICIONE("SC5",1,xFilial("SC5")+cPedido,"C5_HORALIB"))
EndIf

Return({dDtLibCred,cHrLibCred})
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DIPM033   ºAutor  ³Microsiga           º Data ³  01/06/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function DIPM033(aWork)
Local cSQL    := ""  

If ValType(aWork)=="A"
	PREPARE ENVIRONMENT EMPRESA aWork[1] FILIAL aWork[2] FUNNAME "DIPM033"      
	Conout("DIPM033 - Inicio em: "+DtoC(dDataBase)+" - "+SubStr(Time(),1,2)+":"+SubStr(Time(),4,2)+" Emp:"+aWork[1]+" Fil:"+aWork[2])
EndIf

cSQL := " SELECT "
cSQL += " 	B2_FILIAL, B2_COD, B2_LOCAL, B2_RESERVA, B2_QPEDVEN "
cSQL += " 	FROM "
cSQL += " 		SB2010 B2, SB1010 B1 "
cSQL += " 		WHERE "   
cSQL += " 			B1_FILIAL 	  = '"+aWork[2]+"' AND "
cSQL += " 			B1_TIPO 	  = 'PA' AND "
cSQL += " 			B2_FILIAL 	  = B1_FILIAL AND "
cSQL += " 			B2_COD 		  = B1_COD AND "
cSQL += " 			B2_LOCAL 	  = '01' AND "
cSQL += " 			B2.D_E_L_E_T_ = ' ' AND "
cSQL += " 			B1.D_E_L_E_T_ = ' ' "
cSQL += " ORDER BY  B2_FILIAL, B2_COD "

cSQL := ChangeQuery(cSQL)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),"QRYSB2",.T.,.T.)

While !QRYSB2->(Eof())
	cSQL := " SELECT "
	cSQL += " 	ISNULL(SUM(C9_QTDLIB),0) C9_QTDLIB, ISNULL(SUM(C9_SALDO),0) C9_SALDO "
	cSQL += "	FROM "
	cSQL += " 		SC9010 C9, SC6010 C6, SF4010 F4 "
	cSQL += " 		WHERE "
	cSQL += " 			C9_FILIAL 	  = '"+QRYSB2->B2_FILIAL+"' AND "
	cSQL += " 			C9_PRODUTO 	  = '"+QRYSB2->B2_COD+"' AND "
	cSQL += "  			C9_LOCAL 	  = '"+QRYSB2->B2_LOCAL+"' AND "
	cSQL += "  			C9_BLEST 	  <> '10' AND "
	cSQL += "  			C9_BLCRED 	  <> '10' AND "
	cSQL += "  			C6.C6_FILIAL  = C9.C9_FILIAL AND " 
	cSQL += "  			C6.C6_NUM 	  = C9.C9_PEDIDO AND " 
	cSQL += "  			C6.C6_ITEM 	  = C9.C9_ITEM AND " 
	cSQL += "  			F4.F4_FILIAL  = C9.C9_FILIAL AND " 
	cSQL += "  			F4.F4_CODIGO  = C6.C6_TES AND " 
	cSQL += "  			F4.F4_ESTOQUE = 'S' AND "
	cSQL += "  			C9.D_E_L_E_T_ = ' ' AND "
	cSQL += "  			C6.D_E_L_E_T_ = ' ' AND "
	cSQL += "  			F4.D_E_L_E_T_ = ' ' "              
	
	cSQL := ChangeQuery(cSQL)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),"QRYSC9",.T.,.T.)
	
	If !QRYSC9->(Eof())   
		If (QRYSB2->B2_RESERVA-(QRYSC9->C9_QTDLIB-QRYSC9->C9_SALDO))<>0
			u_Ajusta(QRYSB2->B2_COD)
		Else
			cSQL := " SELECT "
			cSQL += " 	  ISNULL(SUM(C6_QTDVEN-C6_QTDENT),0) C6_NENTREGUE "
			cSQL += "     FROM "
			cSQL += " 		SC6010 C6, SF4010 F4 "
			cSQL += " 		WHERE "
			cSQL += " 			C6_FILIAL 	  = '"+QRYSB2->B2_FILIAL+"' AND "
			cSQL += " 			C6_PRODUTO 	  = '"+QRYSB2->B2_COD+"' AND "
			cSQL += " 			C6_LOCAL 	  = '"+QRYSB2->B2_LOCAL+"' AND "
			cSQL += " 			C6.C6_TIPODIP NOT IN ('2','3') AND "
			cSQL += " 			C6.C6_PEDCLI  NOT LIKE 'TMK%' AND "   
			cSQL += " 			C6.C6_QTDVEN <> C6.C6_QTDENT AND "
			cSQL += " 			C6_QTDEMP = 0  AND "
			cSQL += " 			F4.F4_FILIAL  = C6.C6_FILIAL AND "
			cSQL += " 			F4.F4_CODIGO  = C6.C6_TES AND "
			cSQL += " 			F4.F4_ESTOQUE = 'S' AND "
			cSQL += " 			C6.D_E_L_E_T_ = ' ' AND "
			cSQL += " 			F4.D_E_L_E_T_ = ' ' "
			
			cSQL := ChangeQuery(cSQL)
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),"QRYSC6",.T.,.T.)

			If !QRYSC6->(Eof())   			
				If (QRYSB2->B2_QPEDVEN-(QRYSC6->C6_NENTREGUE+QRYSC9->C9_SALDO))<>0     
					u_Ajusta(QRYSB2->B2_COD)
				EndIf
			EndIf   
			QRYSC6->(dbCloseArea())	
					
		EndIf
	EndIf
	QRYSC9->(dbCloseArea())
	
	QRYSB2->(dbSkip())
EndDo                 
QRYSB2->(dbCloseArea())

If ValType(aWork)=="A"
	RESET ENVIRONMENT
	Conout("DIPM033 - Fim em: "+DtoC(dDataBase)+" - "+SubStr(Time(),1,2)+":"+SubStr(Time(),4,2)+" Emp:"+aWork[1]+" Fil:"+aWork[2])
EndIf

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DIPM033   ºAutor  ³Microsiga           º Data ³  01/07/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function Ajusta(cProd)
Local nSC6Qpedven := 0
Local nSC6Qqtdemp := 0
Local nSC9Saldo   := 0
Local nSC9Qtdori  := 0 
Local cSQL		  := ""
DEFAULT cProd	  := ""

If !Empty(cProd)
	dbSelectArea("SB2")
	SB2->(dbSetOrder(1))

	If SB2->(dbSeek(xFilial("SB2")+cProd+'01'))
	
		cSQL := "SELECT "
		cSQL += " SUM( CASE WHEN C6_QTDVEN <> C6_QTDENT AND C6_QTDEMP = 0  AND C6_TIPODIP <> '2'  THEN C6_QTDVEN - C6_QTDENT ELSE 0 END) AS nSC6Qpedven, " 	//28/07/09  -  MCVN
		cSQL += " SUM( CASE WHEN C6_QTDVEN <> C6_QTDENT AND C6_QTDEMP > 0  THEN C6_QTDVEN - C6_QTDENT ELSE 0 END) AS nSC6Qqtdemp "
		cSQL += " FROM " + RetSQLName("SC6")
		cSQL += " WHERE C6_FILIAL = '" + xFILIAL("SC6") + "'"
		cSQL += " AND C6_PRODUTO = '" + cProd + "'"
		cSQL += " AND C6_LOCAL = '01'"
		cSQL += " AND "  + RetSQLName("SC6")+".D_E_L_E_T_ = ' '"
		
		cSQL := ChangeQuery(cSQL)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),"TRBSC6",.T.,.T.)
		
		If !TRBSC6->(Eof())
			nSC6Qpedven := TRBSC6->nSC6Qpedven
			nSC6Qqtdemp := TRBSC6->nSC6Qqtdemp
		EndIf		
		TRBSC6->(dbCloseArea())
				
		cSQL := "SELECT "
		cSQL += " SUM( CASE WHEN C9_QTDORI > 0 THEN C9_QTDORI ELSE 0 END) AS nSC9Qtdori, "
		cSQL += " SUM( CASE WHEN C9_SALDO  > 0 THEN C9_SALDO  ELSE 0 END) AS nSC9Saldo "
		cSQL += " FROM " + RetSQLName("SC9")
		cSQL += " WHERE C9_FILIAL = '" + xFILIAL("SC9") + "'"
		cSQL += " AND C9_PRODUTO  = '" + cProd + "'"
		cSQL += " AND C9_LOCAL    = '01'"
		cSQL += " AND C9_NFISCAL  = ' '"
		cSQL += " AND "  + RetSQLName("SC9")+".D_E_L_E_T_ = ' '"
		
		cSQL := ChangeQuery(cSQL)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),"TRBSC9",.T.,.T.)
		
		If !TRBSC9->(Eof())
			nSC9Qtdori := TRBSC9->nSC9Qtdori
			nSC9Saldo  := TRBSC9->nSC9Saldo
		EndIf		
		TRBSC9->(dbCloseArea())
		
		If (nSC9Qtdori + nSC9Saldo) == nSC6Qqtdemp .And. (SB2->B2_QATU-SB2->B2_QACLASS) >= nSC9Qtdori
			Conout("DIPM033 ("+IIf(xFilial("SB2")=='01','MTZ','CD')+") - Produto: "+AllTrim(cProd)+" corrigido em "+DtoC(dDataBase)+" - "+SubStr(Time(),1,2)+":"+SubStr(Time(),4,2))
			SB2->(RecLock("SB2",.F.))
				SB2->B2_QPEDVEN := (nSC9Saldo + nSC6Qpedven)    
				SB2->B2_QPEDVE2 := ConvUm(SB2->B2_COD,(nSC9Saldo + nSC6Qpedven),0,2)
				SB2->B2_RESERVA := nSC9Qtdori     
				SB2->B2_RESERV2 := ConvUm(SB2->B2_COD,nSC9Qtdori,0,2)
			SB2->(MsUnlock())
			SB2->(Dbcommit())                           
		Endif
	EndIf
EndIf

Return
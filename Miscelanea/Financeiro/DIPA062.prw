#INCLUDE "TBICONN.CH"
#INCLUDE "PROTHEUS.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DIPA062   ºAutor  ³Microsiga           º Data ³  11/13/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/                                           
User Function DIPA062(aWork)                                                                        
	If ValType(aWork)=="A"
		PREPARE ENVIRONMENT EMPRESA aWork[1] FILIAL  aWork[2] FUNNAME "DIPA062"                   
	    Conout("DIPA062 - Inicio em: "+DtoC(dDataBase)+" - "+SubStr(Time(),1,2)+":"+SubStr(Time(),4,2)+" Emp:"+aWork[1]+" Fil:"+aWork[2])
	EndIf
	
	Processa({|| DIP62PROC()} )   
		    
	If ValType(aWork)=="A"	
		Conout("DIPA062 - Fim em: "+DtoC(dDataBase)+" - "+SubStr(Time(),1,2)+":"+SubStr(Time(),4,2)+" Emp:"+aWork[1]+" Fil:"+aWork[2])
		RESET ENVIRONMENT
	EndIf	
Return                           
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DIPA062   ºAutor  ³Microsiga           º Data ³  11/13/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function DIP62PROC()
Local cSQL := ""
Local cEnd := CHR(10)+CHR(13)
    
cSQL := " SELECT "+RetSQLName("SA1")+".R_E_C_N_O_ REC, ROUND(COALESCE((SELECT SUM(E1_SALDO) FROM "+RetSQLName("SE1")+" WHERE  E1_FILIAL = '"+xFilial("SE1")+"' AND E1_CLIENTE = A1_COD AND E1_LOJA = A1_LOJA AND E1_TIPO NOT IN('NCC','RA') AND E1_SALDO > 0 AND D_E_L_E_T_ = ' '),0)- "
cSQL += "     						          COALESCE((SELECT SUM(E1_SALDO) FROM "+RetSQLName("SE1")+" WHERE  E1_FILIAL = '"+xFilial("SE1")+"' AND E1_CLIENTE = A1_COD AND E1_LOJA = A1_LOJA AND E1_TIPO     IN('NCC','RA') AND E1_SALDO > 0 AND D_E_L_E_T_ = ' '),0),2) SALDO "
cSQL += " 	FROM "
cSQL +=     RetSQLName("SA1")
cSQL += "		WHERE "
cSQL += "			ROUND(A1_SALDUPM,2)<>ROUND(COALESCE((SELECT SUM(E1_SALDO) FROM "+RetSQLName("SE1")+" WHERE  E1_FILIAL = '"+xFilial("SE1")+"' AND E1_CLIENTE = A1_COD AND E1_LOJA = A1_LOJA AND E1_TIPO NOT IN('NCC','RA') AND E1_SALDO > 0 AND D_E_L_E_T_ = ' '),0)- "
cSQL += "     						           COALESCE((SELECT SUM(E1_SALDO) FROM "+RetSQLName("SE1")+" WHERE  E1_FILIAL = '"+xFilial("SE1")+"' AND E1_CLIENTE = A1_COD AND E1_LOJA = A1_LOJA AND E1_TIPO     IN('NCC','RA') AND E1_SALDO > 0 AND D_E_L_E_T_ = ' '),0),2) OR "
cSQL += "			ROUND(A1_SALDUP,2) <>ROUND(COALESCE((SELECT SUM(E1_SALDO) FROM "+RetSQLName("SE1")+" WHERE  E1_FILIAL = '"+xFilial("SE1")+"' AND E1_CLIENTE = A1_COD AND E1_LOJA = A1_LOJA AND E1_TIPO NOT IN('NCC','RA') AND E1_SALDO > 0 AND D_E_L_E_T_ = ' '),0)- "
cSQL += "     						           COALESCE((SELECT SUM(E1_SALDO) FROM "+RetSQLName("SE1")+" WHERE  E1_FILIAL = '"+xFilial("SE1")+"' AND E1_CLIENTE = A1_COD AND E1_LOJA = A1_LOJA AND E1_TIPO     IN('NCC','RA') AND E1_SALDO > 0 AND D_E_L_E_T_ = ' '),0),2) "
                       
cSQL := ChangeQuery(cSQL)
dbUseArea(.T., "TOPCONN", TCGenQry(,,cSQL), "QRYSA1", .F., .T.)

ProcRegua(QRYSA1->(LastRec()))                          

While !QRYSA1->(Eof()) 	     
	SA1->(dbGoTo(QRYSA1->REC))
	SA1->(RecLock("SA1",.F.))
		SA1->A1_SALDUP  := QRYSA1->SALDO
		SA1->A1_SALDUPM := QRYSA1->SALDO
	SA1->(MsUnLock())                   
	   
	QRYSA1->(dbSkip())
EndDo

QRYSA1->(dbCloseArea())

Begin Transaction
	cSQL := " SELECT "
	cSQL += "	COALESCE(SUM(C9_QTDLIB*C9_PRCVEN),0)  "
	cSQL += "	FROM "
	cSQL += "		"+RetSQLName("SA1")+" SA1 "
	cSQL += "		INNER JOIN( "
	cSQL += "					SELECT "
	cSQL += "						* "
	cSQL += "						FROM "
	cSQL += "							"+RetSQLName("SC5")+"  SC5 "
	cSQL += "							WHERE "
	cSQL += "								C5_TIPO = 'N' "
	cSQL += "								AND SC5.D_E_L_E_T_ = ' ' "
	cSQL += "								AND C5_TIPODIP = 1 "
	cSQL += "								AND C5_PRENOTA NOT IN ('O','R','F') "
	cSQL += "								AND C5_CONDPAG NOT IN ('001','002') " 
	cSQL += "								AND C5_FILIAL IN  ('04','01') "
	cSQL += "					)TC5 "
	cSQL += "					ON "
	cSQL += "						TC5.C5_CLIENTE = SA1.A1_COD "
	cSQL += "		INNER JOIN( "
	cSQL += "					SELECT "
	cSQL += "						* "
	cSQL += "						FROM "
	cSQL += "							"+RetSQLName("SC9")+"  SC9 "
	cSQL += "							WHERE "
	cSQL += "								SC9.D_E_L_E_T_ = '' "
	cSQL += "								AND C9_BLCRED  = '' "
	cSQL += "								AND C9_NFISCAL = '' "
	cSQL += "					)TC9"
	cSQL += "					ON "
	cSQL += "						TC9.C9_CLIENTE = TC5.C5_CLIENTE "
	cSQL += "						AND TC9.C9_LOJA = TC5.C5_LOJACLI "
	cSQL += "						AND TC9.C9_FILIAL = TC5.C5_FILIAL "
	cSQL += "						AND TC9.C9_PEDIDO = TC5.C5_NUM "
	cSQL += "		WHERE "
	cSQL += "			SA1.D_E_L_E_T_ = ' ' "
	cSQL += "			AND A1_FILIAL = '"+xFilial("SA1")+"' "
	cSQL += "			AND A1_COD = A1.A1_COD "
	cSQL += " GROUP BY SA1.A1_COD "
	                    
	cUPD := " UPDATE "
	cUPD += 	RetSQLName("SA1")
	cUPD += "	SET "
	cUPD += "		A1_SALPEDL = COALESCE(("+cSQL+"),0) "
	cUPD += "		FROM "
	cUPD += "			"+RetSQLName("SA1")+" A1 "
	cUPD += "			WHERE "
	cUPD += "				A1.D_E_L_E_T_ = ' ' "
	cUPD += "				AND A1_ULTCOM > '"+DtoS(dDataBase-120)+"' "
	//cUPD += "				AND A1_SALPEDL < 0  "
	
	TCSQLExec(cUPD)
End Transaction

Begin Transaction               
	cSQL := " SELECT "
	cSQL += "	COALESCE(SUM((TC6.C6_QTDVEN-TC6.C6_QTDENT)*TC6.C6_PRCVEN),0) - COALESCE(SUM(TC9.C9_QTDLIB*TC9.C9_PRCVEN),0) "
	cSQL += "	FROM "
	cSQL += "		"+RetSQLName("SA1")+" SA1 "
	cSQL += "		INNER JOIN( "
	cSQL += "					SELECT "
	cSQL += "						* "
	cSQL += "						FROM "
	cSQL += "							"+RetSQLName("SC5")+"  SC5 "
	cSQL += "							WHERE "
	cSQL += "								C5_TIPO = 'N' "
	cSQL += "								AND SC5.D_E_L_E_T_ = ' ' "
	cSQL += "								AND C5_FILIAL IN  ('04','01') "
	cSQL += "					)TC5 "
	cSQL += "					ON "
	cSQL += "						TC5.C5_CLIENTE = SA1.A1_COD "
	cSQL += "		INNER JOIN( "
	cSQL += "					SELECT "
	cSQL += "						* "
	cSQL += "						FROM "
	cSQL += "							"+RetSQLName("SC6")+"  SC6 "
	cSQL += "							WHERE "
	cSQL += "								SC6.D_E_L_E_T_ = ' ' "
	cSQL += "								AND (C6_QTDVEN - C6_QTDENT) <> 0 "
	cSQL += "								AND C6_TIPODIP = 1 "
	cSQL += "					) TC6 "
	cSQL += "					ON "
	cSQL += "						TC6.C6_CLI = TC5.C5_CLIENTE "
	cSQL += "						AND TC6.C6_LOJA = TC5.C5_LOJACLI "
	cSQL += "						AND TC6.C6_FILIAL = TC5.C5_FILIAL "
	cSQL += "						AND TC6.C6_NUM = TC5.C5_NUM "
	cSQL += "		LEFT JOIN( "
	cSQL += "					SELECT "
	cSQL += " 						* "
	cSQL += "						FROM "
	cSQL += "							"+RetSQLName("SC9")+"  SC9 "
	cSQL += "							WHERE "
	cSQL += "								SC9.D_E_L_E_T_ = ' ' "
	cSQL += "								AND C9_BLCRED <> '10' "
	cSQL += "					) TC9 "
	cSQL += "					ON "
	cSQL += "						TC9.C9_CLIENTE = TC5.C5_CLIENTE "
	cSQL += "						AND TC9.C9_LOJA = TC5.C5_LOJACLI "
	cSQL += "						AND TC9.C9_FILIAL = TC5.C5_FILIAL "
	cSQL += "						AND TC9.C9_PEDIDO = TC5.C5_NUM "
	cSQL += "		WHERE "
	cSQL += "			SA1.D_E_L_E_T_ = ' ' "
	cSQL += "			AND A1_FILIAL = '"+xFilial("SA1")+"' "
	cSQL += "			AND A1_COD = A1.A1_COD "
	cSQL += " GROUP BY SA1.A1_COD "
	      
	cUPD := " UPDATE "
	cUPD += 	RetSQLName("SA1")
	cUPD += "	SET "
	cUPD += "		A1_SALPED = COALESCE(("+cSQL+"),0) "
	cUPD += "		FROM "
	cUPD += "			"+RetSQLName("SA1")+" A1 "
	cUPD += "			WHERE "
	cUPD += "				A1.D_E_L_E_T_ = ' ' "
	cUPD += "				AND A1_SALPED < 0  "
	
	TCSQLExec(cUPD)
End Transaction                 

Return
#INCLUDE "RWMAKE.CH"
#INCLUDE "TBICONN.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDIPA063   บAutor  ณMicrosiga           บ Data ณ  12/26/13   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ EXECUTA ROTINA AJUSTA SALPEDI VIA WORKFLOW                 บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function DIPA063(aWork)                                                                        
	If ValType(aWork)=="A"
		PREPARE ENVIRONMENT EMPRESA aWork[1] FILIAL aWork[2] FUNNAME "DIPA063" TABLES "SB2","SC7"
		Conout("DIPA063 - Inicio em: "+DtoC(dDataBase)+" - "+SubStr(Time(),1,2)+":"+SubStr(Time(),4,2)+" Emp:"+aWork[1]+" Fil:"+aWork[2])
	EndIf
	
	Processa({|| DIP63PROC(aWork)} )                                                                    
	
	If ValType(aWork)=="A"	
		RESET ENVIRONMENT
		Conout("DIPA063 - Fim em: "+DtoC(dDataBase)+" - "+SubStr(Time(),1,2)+":"+SubStr(Time(),4,2)+" Emp:"+aWork[1]+" Fil:"+aWork[2])		
	EndIf	
Return                           
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDIP63PROC บAutor  ณMicrosiga           บ Data ณ  12/26/13   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function DIP63PROC(aWork)
Local nRet 		:= 0
Local cUPD 		:= ""
Local aLocais 	:= {"01","02","03","04","05","06","07","08","09","10","11","12","13","98"}       
Local nI 	  	:= 0

For nI := 1 to Len(aLocais)
	Begin Transaction  
	
		Conout("DIPA063 - Inicio transaction: "+DtoC(dDataBase)+" - "+SubStr(Time(),1,2)+":"+SubStr(Time(),4,2)+" Emp:"+aWork[1]+" Fil:"+aWork[2])
	
		cUPD := " UPDATE "
		cUPD +=  	RetSQLName("SB2")
		cUPD += " 	SET "
		cUPD += "		B2_SALPEDI = (ISNULL(( SELECT "
		cUPD += "									SUM(C7_QUANT - C7_QUJE) AS SALPED_VALIDO "
		cUPD += "									FROM "
		cUPD += 										RetSQLName("SB2")+" AS SB2, "+RetSQLName("SC7") 
		cUPD += "										WHERE "
		cUPD += "											SB2.D_E_L_E_T_ 	    = ' ' "
		cUPD += "											AND "+RetSQLName("SC7")+".D_E_L_E_T_ = ' ' "
		cUPD += "											AND C7_PRODUTO    = B2_COD "		
		cUPD += "											AND B2_LOCAL      = '"+aLocais[nI]+"' "   
		cUPD += "											AND C7_LOCAL      = B2_LOCAL "   		
		cUPD += "											AND B2_FILIAL     = '"+xFilial("SB2")+"' "
		cUPD += "											AND C7_FILIAL     = '"+xFilial("SC7")+"' "
		cUPD += "						   					AND C7_QUJE       < C7_QUANT "
		cUPD += "						  					AND C7_CONAPRO   <> 'B' "
//		cUPD += "					  						AND C7_QTDACLA    = 0 "
		cUPD += "					 						AND C7_RESIDUO    = ' ' "
		cUPD += "					 						AND SB2.B2_COD    = "+RetSQLName("SB2")+".B2_COD "
		cUPD += "						 					AND SB2.B2_LOCAL  = "+RetSQLName("SB2")+".B2_LOCAL "
		cUPD += "											AND SB2.B2_FILIAL = "+RetSQLName("SB2")+".B2_FILIAL "
		cUPD += "								GROUP BY C7_PRODUTO),0)) "      
		cUPD += "		FROM "
		cUPD += 			RetSQLName("SB2")+", "+RetSQLName("SB1")
		cUPD += "				WHERE "
		cUPD += 					RetSQLName("SB1")+".D_E_L_E_T_ = ' ' "
		cUPD += "					AND "+RetSQLName("SB2")+".D_E_L_E_T_ = ' ' "
		cUPD += "					AND B1_COD      = B2_COD "
		cUPD += "					AND B2_LOCAL    = '"+aLocais[nI]+"' "
		cUPD += "					AND B2_FILIAL   = '"+xFilial("SB2")+"' "
		cUPD += "					AND B2_FILIAL   = B1_FILIAL "
		cUPD += "					AND B2_SALPEDI <> (ISNULL((	SELECT "
		cUPD += "													SUM(C7_QUANT - C7_QUJE) AS SALPED_VALIDO "
		cUPD += "													FROM "                       
		cUPD += 														RetSQLName("SB2")+" AS SB2_1, "+RetSQLName("SC7") 
		cUPD += "														WHERE "
		cUPD += "															SB2_1.D_E_L_E_T_ 	= ' ' "
		cUPD += "															AND "+RetSQLName("SC7")+".D_E_L_E_T_ = ' ' "
		cUPD += "															AND C7_PRODUTO 	    = B2_COD "
		cUPD += "															AND B2_LOCAL   	    = '"+aLocais[nI]+"' "
		cUPD += "															AND C7_LOCAL        = B2_LOCAL "   				
		cUPD += "															AND B2_FILIAL  	    = '"+xFilial("SB2")+"' "
		cUPD += "															AND C7_FILIAL  	    = '"+xFilial("CB7")+"' "
		cUPD += "															AND C7_QUJE    	    < C7_QUANT "
		cUPD += "															AND C7_CONAPRO 	   <> 'B' "
//		cUPD += "															AND C7_QTDACLA 	    = 0 "
		cUPD += "															AND C7_RESIDUO 	    = ' ' "
		cUPD += "															AND SB2_1.B2_COD 	= "+RetSQLName("SB2")+".B2_COD "
		cUPD += "															AND SB2_1.B2_LOCAL  = "+RetSQLName("SB2")+".B2_LOCAL "
		cUPD += "															AND SB2_1.B2_FILIAL = "+RetSQLName("SB2")+".B2_FILIAL "
		cUPD += "												GROUP BY C7_PRODUTO),0)) "
		
		Conout("DIPA063 - Fim transaction: "+DtoC(dDataBase)+" - "+SubStr(Time(),1,2)+":"+SubStr(Time(),4,2)+" Emp:"+aWork[1]+" Fil:"+aWork[2])
		
		TCSQLExec(cUPD)	
		
		If nRet==0  
			Conout("DIPA063 - UPD executado: "+DtoC(dDataBase)+" - "+SubStr(Time(),1,2)+":"+SubStr(Time(),4,2)+" Emp:"+aWork[1]+" Fil:"+aWork[2])
		Else  
			Conout("DIPA063 - Erro UPD: "+DtoC(dDataBase)+" - "+SubStr(Time(),1,2)+":"+SubStr(Time(),4,2)+" Emp:"+aWork[1]+" Fil:"+aWork[2]+" Erro:"+TcSqlError())
		EndIf
		
	End Transaction
Next nI
	
Return(.T.)
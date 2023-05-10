#INCLUDE "PROTHEUS.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณNOVO19    บAutor  ณMicrosiga           บ Data ณ  08/17/16   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function DipNVen3M()
Local aCabec := {}
Local aDetal := {}     
Local cSeqRV := ""
Local cSQL   := ""                                        
Local cPerg  := "RELVEN" 
LOcal cDataHor := ""                  
            
cSQL := " SELECT "
cSQL += " 	A3_NOME, A3_CGC, A3_SUPER, A3_GEREN, A3_COD "
cSQL += " 	FROM "
cSQL +=   		RetSQLName("SD2")
cSQL += "  		INNER JOIN "
cSQL +=   			RetSQLName("SF2")
cSQL += "  			ON "
cSQL += "  				F2_FILIAL = D2_FILIAL AND "
cSQL += "  				F2_DOC  = D2_DOC AND "
cSQL += "  				F2_SERIE = D2_SERIE AND "
cSQL += "  				F2_CLIENTE = D2_CLIENTE AND "
cSQL += "  				F2_LOJA = D2_LOJA AND "
cSQL +=   				RetSQLName("SF2")+".D_E_L_E_T_ = ' ' "
cSQL += " 		INNER JOIN "
cSQL +=   			RetSQLName("SA3")
cSQL += " 			ON "
cSQL += " 				A3_FILIAL = '"+xFilial("SA3")+"' AND "
cSQL += " 				A3_COD = F2_VEND1 AND "
cSQL +=  				RetSQLName("SA3")+".D_E_L_E_T_ = ' ' "
cSQL += " 		INNER JOIN "
cSQL +=   			RetSQLName("SB1")
cSQL += " 			ON "
cSQL += " 				B1_FILIAL = '"+xFilial("SB1")+"' AND "
cSQL += " 				B1_COD = D2_COD AND "
cSQL += "  				B1_TIPO = 'PA' AND "
cSQL +=  				RetSQLName("SB1")+".D_E_L_E_T_ = ' ' "
cSQL += " 		WHERE "
cSQL += " 			D2_FILIAL = '"+xFilial("SD2")+"' AND "
cSQL += " 			D2_EMISSAO = '"+DtoS(dDataBase-1)+"' AND "
cSQL += " 			D2_TIPO = 'N' AND "
cSQL += " 			D2_FORNEC = '000041' AND "
cSQL +=   			RetSQLName("SD2")+".D_E_L_E_T_ = ' ' "
cSQL += " GROUP BY A3_NOME, A3_CGC, A3_SUPER, A3_GEREN, A3_COD "

cSQL := ChangeQuery(cSQL)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),"QRYVEN",.T.,.T.)  
   
If !QRYVEN->(Eof())                

	cDataHor := DtoS(dDataBase-1)+StrTran(Left(Time(),5),":","")
	cNomArq  := "RELVEN_"+IIf(cFilAnt=="01","47869078000100","47869078000453")+"_"+cDataHor+".txt"
	
	cSeqRV := U_DipSeqZT("RELVEN")
	
	aAdd(aCabec,{	"01",;	   		   		  								//Tipo de Registro - 02
					"RELVEN",;  	  	  	 								//Identifica็ใo - 06
					"050",;													//Versใo - 03
					cSeqRV,;												//N๚mero Relat๓rio - 20
					cDataHor,; 	   											//Data - Hora de Emissใo do Documento - 12
					IIf(cFilAnt=="01","47869078000100","47869078000453"),; 	//CNPJ do Emissor do Relat๓rio - 14
					"03887830009046"}) 										//CNPJ do Destinatแrio do Relat๓rio - 14

	While !QRYVEN->(Eof())					                                    
		cCodVen := ""                 
		cCodVen := IIf(Empty(QRYVEN->A3_CGC),QRYVEN->A3_COD,QRYVEN->A3_CGC) 	//Retira caracter especial
		cCodVen := StrTran(u_DipRetCE(cCodVen)," ","")							//Retira Espa็o em Branco
		
		aAdd(aDetal,{	"02",; 													//Tipo de Registro - 02
						u_DipRetCE(QRYVEN->A3_NOME),;                           //Nome Vendedor - 50
						u_DipRetCE(cCodVen),;									//C๓digo Vendedor - 20
						"NAO INFORMADO",;                 		                //Nome Supervisor - 50
						"999",;           						                //C๓digo Supervisor - 20
						"NAO INFORMADO",; 				                        //Nome Gerente - 50
						"999",; 					          				    //C๓digo Gerente - 50
						"A",;                           					 	//Status Vendedor - 01
						DtoS(dDataBase-1) })										//Data de Desligamento Vendedor - 08
		QRYVEN->(dbSkip())					
	EndDo
	QRYVEN->(dbCloseArea())	 	
	
EndIf

cSQL := " SELECT "
cSQL += " 	A3_NOME, A3_CGC, A3_SUPER, A3_GEREN, A3_COD "
cSQL += " 	FROM "
cSQL +=   		RetSQLName("SD1")
cSQL += "  		INNER JOIN "
cSQL +=   			RetSQLName("SF2")
cSQL += "  			ON "
cSQL += "  				D1_FILIAL = F2_FILIAL AND "
cSQL += "  				D1_NFORI  = F2_DOC AND "
cSQL += "  				D1_SERIORI = F2_SERIE AND "
cSQL += "  				D1_FORNECE = F2_CLIENTE AND "
cSQL += "  				D1_LOJA = F2_LOJA AND "
cSQL +=   				RetSQLName("SF2")+".D_E_L_E_T_ = ' ' "
cSQL += " 		INNER JOIN "
cSQL +=   			RetSQLName("SA3")
cSQL += " 			ON "
cSQL += " 				A3_FILIAL = '"+xFilial("SA3")+"' AND "
cSQL += " 				A3_COD = F2_VEND1 AND "
cSQL +=  				RetSQLName("SA3")+".D_E_L_E_T_ = ' ' "
cSQL += " 		INNER JOIN "
cSQL +=   			RetSQLName("SB1")
cSQL += " 			ON "
cSQL += " 				B1_FILIAL = '"+xFilial("SB1")+"' AND "
cSQL += " 				B1_COD = D1_COD AND "
cSQL += "  				B1_TIPO = 'PA' AND "
cSQL += "  				LEFT(B1_DESC,1) NOT IN('.','Z') AND "
cSQL += "  				B1_PROC = '000041' AND "
cSQL +=  				RetSQLName("SB1")+".D_E_L_E_T_ = ' ' "
cSQL += " 		WHERE "
cSQL += " 			D1_FILIAL = '"+xFilial("SD1")+"' AND "
cSQL += " 			D1_DTDIGIT = '"+DtoS(dDataBase-1)+"' AND "
cSQL += " 			D1_TIPO = 'D' AND "
cSQL +=   			RetSQLName("SD1")+".D_E_L_E_T_ = ' ' "
cSQL += " GROUP BY A3_NOME, A3_CGC, A3_SUPER, A3_GEREN, A3_COD "

cSQL := ChangeQuery(cSQL)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),"QRYVEN2",.T.,.T.)  

If !QRYVEN2->(Eof())                

	While !QRYVEN2->(Eof())					                                    
		cCodVen := ""                 
		cCodVen := IIf(Empty(QRYVEN2->A3_CGC),QRYVEN2->A3_COD,QRYVEN2->A3_CGC) 	//Retira caracter especial
		cCodVen := StrTran(u_DipRetCE(cCodVen)," ","")							//Retira Espa็o em Branco

		If aScan(aDetal, {|x| x[3]==u_DipRetCE(cCodVen)})==0
			aAdd(aDetal,{	"02",; 													//Tipo de Registro - 02
							u_DipRetCE(QRYVEN2->A3_NOME),;                          //Nome Vendedor - 50
							u_DipRetCE(cCodVen),;									//C๓digo Vendedor - 20
							"NAO INFORMADO",;                 		                //Nome Supervisor - 50
							"999",;           						                //C๓digo Supervisor - 20
							"NAO INFORMADO",; 				                        //Nome Gerente - 50
							"999",; 					          				    //C๓digo Gerente - 50
							"A",;                           					 	//Status Vendedor - 01
							DtoS(dDataBase-1) })									//Data de Desligamento Vendedor - 08
		EndIf
		
		QRYVEN2->(dbSkip())					
	EndDo
	QRYVEN2->(dbCloseArea())	 	
	
EndIf

If Len(aCabec)>0 .And. Len(aDetal)>0
	u_DipGerN3M(aCabec,aDetal,cNomArq)		
EndIf

Return 
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDIPNCLI3M บAutor  ณMicrosiga           บ Data ณ  08/18/16   บฑฑ
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

aAdd(aRegs,{cPerg,"01","Data De  ?","","","mv_ch1","D",8,0,0,"G","","MV_PAR01","","","","","","","","","","","","","","","","","","","","","","","","",''})
aAdd(aRegs,{cPerg,"02","Data Ate ?","","","mv_ch2","D",8,0,0,"G","","MV_PAR02","","","","","","","","","","","","","","","","","","","","","","","","",''})
aAdd(aRegs,{cPerg,"03","Versใo   ?","","","mv_ch3","C",3,0,0,"G","","MV_PAR03","","","","","","","","","","","","","","","","","","","","","","","","",''})

PlsVldPerg( aRegs )

Return
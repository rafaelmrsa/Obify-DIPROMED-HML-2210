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
User Function DipNVend()
Local aCabec 	:= {}
Local aDetal 	:= {}     
Local cSeqRE 	:= ""
Local cSQL   	:= ""                                        
Local cPerg  	:= "VENDAS" 
Local cDataHor 	:= ""
Local cCodVen 	:= ""
Local cCodCli 	:= ""
Local cDocOld   := ""                         
            
cSQL := " SELECT "
cSQL += " 	A3_CGC, "
cSQL += " 	A3_COD, "

cSQL += " 	A1_TIPO, "
cSQL += " 	A1_CGC, "
cSQL += " 	A1_COD, "
cSQL += " 	A1_LOJA, "
cSQL += " 	A1_ESTE, "
cSQL += " 	A1_CEPE, "

cSQL += " 	F2_TPFRETE, "
cSQL += " 	F2_COND, "
cSQL += " 	F2_DOC, "
cSQL += " 	F2_SERIE, "

cSQL += " 	D2_EMISSAO, "
cSQL += " 	D2_QUANT, "
cSQL += " 	D2_PRCVEN, "
cSQL += " 	D2_VALBRUT, "
cSQL += " 	D2_TOTAL, "
cSQL += " 	D2_VALIPI, "
cSQL += " 	D2_VALIMP5, "
cSQL += " 	D2_VALIMP6, "
cSQL += " 	D2_ICMSRET, "
cSQL += " 	D2_VALICM, "
cSQL += " 	D2_DESC, "
cSQL += " 	D2_DOC, "
cSQL += " 	D2_COD, "
cSQL += " 	D2_SERIE, "
cSQL += "	A5_CODPRF "
cSQL += " 	FROM "
cSQL +=  		RetSQLName("SF2")
cSQL += " 		INNER JOIN "
cSQL +=  			RetSQLName("SD2")
cSQL += " 			ON "
cSQL += " 				D2_FILIAL 	= F2_FILIAL AND "
cSQL += " 				D2_DOC 		= F2_DOC AND "
cSQL += " 				D2_SERIE 	= F2_SERIE  AND "
cSQL += " 				D2_CLIENTE 	= F2_CLIENTE  AND "
cSQL += " 				D2_LOJA 	= F2_LOJA  AND "
cSQL +=  				RetSQLName("SD2")+".D_E_L_E_T_ = ' ' "
cSQL += " 		INNER JOIN "
cSQL +=  			RetSQLName("SA1")
cSQL += " 			ON "
cSQL += " 				A1_FILIAL 	= '"+xFilial("SA1")+"' AND "
cSQL += " 				A1_COD 		= D2_CLIENTE AND "
cSQL += " 				A1_LOJA 	= D2_LOJA AND "
cSQL +=  				RetSQLName("SA1")+".D_E_L_E_T_ = ' ' "
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
cSQL += "  				B1_COD NOT IN('"+GetNewPar("ES_SEMCD3M","011705")+"') AND "                  
cSQL +=  				RetSQLName("SB1")+".D_E_L_E_T_ = ' ' "   
cSQL += " 		INNER JOIN "
cSQL +=  			RetSQLName("SF4")
cSQL += " 			ON "
cSQL += " 				F4_FILIAL = D2_FILIAL AND "
cSQL += " 				F4_CODIGO = D2_TES AND "
cSQL += " 				F4_DUPLIC = 'S' AND "
cSQL +=  				RetSQLName("SF4")+".D_E_L_E_T_ = ' ' "
cSQL += " 		LEFT JOIN "
cSQL +=  			RetSQLName("SA5")
cSQL += " 			ON "
cSQL += " 				A5_FILIAL = '"+xFilial("SA5")+"' AND "
cSQL += " 				A5_FORNECE = B1_PROC AND "
cSQL += " 				A5_PRODUTO = B1_COD AND "
cSQL +=  				RetSQLName("SA5")+".D_E_L_E_T_ = ' ' "   
cSQL += " 		WHERE "
cSQL += " 			F2_FILIAL = '"+xFilial("SF2")+"' AND "
cSQL += " 			F2_EMISSAO = '"+DtoS(dDataBase-1)+"' AND "
cSQL += " 			F2_TIPO = 'N' AND "
cSQL += " 			D2_FORNEC = '000041' AND "
cSQL += " 			D2_LOCAL = '01' AND "
cSQL +=  			RetSQLName("SF2")+".D_E_L_E_T_ = ' ' "
cSQL += " ORDER BY D2_DOC, D2_SERIE, A1_COD, A1_LOJA "
						
cSQL := ChangeQuery(cSQL)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),"QRYVEND",.T.,.T.)  
                         
TCSETFIELD("QRYVEND","D2_EMISSAO","D",8,0)
   
If !QRYVEND->(Eof())                

	cDataHor := DtoS(dDataBase-1)+StrTran(Left(Time(),5),":","")
	cNomArq  := "VENDAS_"+IIf(cFilAnt=="01","47869078000100","47869078000453")+"_"+cDataHor+".txt"
	cSeqRE 	 := U_DipSeqZT("VENDAS")
	
	aAdd(aCabec,{	"01",;	   		   		  								//Tipo de Registro - 02
					"VENDAS",;  	  	  	 								//Identifica็ใo - 06
					"050",;													//Versใo - 03
					cSeqRE,;												//N๚mero Relat๓rio - 20
					cDataHor,; 	   											//Data - Hora de Emissใo do Documento - 12
					DtoS(dDataBase-1),;										//Data Inicial do Perํodo de Venda - 08
					DtoS(dDataBase-1),;                                     //Data Final do Perํodo de Venda - 08
					IIf(cFilAnt=="01","47869078000100","47869078000453"),; 	//CNPJ do Emissor do Relat๓rio - 14
					"45985371000108"}) 										//CNPJ do Destinatแrio do Relat๓rio - 14

	While !QRYVEND->(Eof())					                     
		
		If Empty(QRYVEND->A5_CODPRF)
			Aviso("Anten็ใo","O produto "+AllTrim(QRYVEND->D2_COD)+" nใo possui c๓digo 3M. A Gera็ใo do arquivo serแ interrompida.",{"Ok"})
			//QRYVEND->(dbCloseArea())
			//Return
		EndIf		

		If QRYVEND->(F2_DOC+F2_SERIE) <> cDocOld
			cCodVen := IIf(!Empty(QRYVEND->A3_CGC),QRYVEND->A3_CGC,QRYVEND->A3_COD)
			cCodCli := IIf(!Empty(QRYVEND->A1_CGC),QRYVEND->A1_CGC,QRYVEND->A1_COD)
	
			aAdd(aDetal,{	"02",; 												//Tipo de Registro - 02
							IIf(QRYVEND->A1_TIPO=="F","01","02"),;				//Tipo de Faturamento - 02
							QRYVEND->D2_DOC,;                               	//N๚mero NF - 20
							QRYVEND->D2_SERIE,;									//S้rie NF - 03
							"01",;				                            	//Tipo NF - 02
							DtoS(QRYVEND->D2_EMISSAO),;							//Data Emissใo NF - 12
							StrTran(u_DipRetCE(cCodVen)," ",""),;				//C๓digo do Vendedor - 20
							u_DipRetCE(cCodCli),;								//C๓digo Cliente - 20
							"SP",;												//UF Emissor Mercadoria - 02
							"06278010",;										//CEP Emissor Mercadoria - 08
							QRYVEND->A1_ESTE,;									//UF Destinatแrio Mercadoria - 02
							QRYVEND->A1_CEPE,;									//CEP Destinatแrio Mercadoria - 08
							IIf(QRYVEND->F2_TPFRETE=="C","CIF","FOB"),;			//Condi็ใo de Entrega (tipo de frete) - 03
							DipRetDP(QRYVEND->F2_COND) })						//Dias de Pagamento - 03
		EndIf
		
		aAdd(aDetal,{	"03",; 													//Tipo de Registro - 02
						QRYVEND->D2_DOC,;                              		 	//N๚mero NF - 20
						QRYVEND->D2_SERIE,;							 			//S้rie NF - 03
						"01",;				                         		   	//Tipo NF - 02
						QRYVEND->D2_COD,;							 			//C๓digo do Item - 30
						u_DipPadDec(QRYVEND->D2_QUANT,10,5),;		 			//Quantidade Vendida - 10.05
						u_DipPadDec(QRYVEND->D2_PRCVEN,10,2),;		 			//Pre็o Unitแrio Bruto Praticado - 10.02
						"N",;										 			//Bonifica็ใo - 01
						u_DipPadDec(QRYVEND->D2_VALBRUT,10,2),;		 			//Valor Total Bruto - 10.02
						u_DipPadDec(QRYVEND->D2_TOTAL,10,2),;		 			//Valor Total Lํquido - 10.02
						u_DipPadDec(QRYVEND->D2_VALIPI,10,2),;		 			//Valor IPI - 10.02
						u_DipPadDec(QRYVEND->(D2_VALIMP5+D2_VALIMP6),10,2),;	//Valor PIS \ CONFINS - 10.02
						u_DipPadDec(QRYVEND->D2_ICMSRET,10,2),;			  		//Valor Substitui็ใo Tributแria - 10.02
						u_DipPadDec(QRYVEND->D2_VALICM,10,2),;					//Valor ICMS - 10.02 
						u_DipPadDec(QRYVEND->D2_DESC,10,2) })					//Valor Descontos - 10.02
						
		
		cDocOld := QRYVEND->(F2_DOC+F2_SERIE)
		
		QRYVEND->(dbSkip())					
	EndDo
	QRYVEND->(dbCloseArea())	 	
	
	cSQL := " SELECT "
	cSQL += " 	F1_DOC, "
	cSQL += " 	F1_SERIE, "
	cSQL += " 	F1_TPFRETE, "
	cSQL += " 	F1_COND, "

	cSQL += " 	D1_DOC, "
	cSQL += " 	D1_SERIE, "
	cSQL += " 	D1_DTDIGIT, "

	cSQL += " 	A1_ESTE, "
	cSQL += " 	A1_CEPE, "
	cSQL += " 	A1_COD, "   
	cSQL += "	A1_LOJA, "
	cSQL += " 	A1_TIPO, "
	cSQL += " 	A1_CGC, "

	cSQL += " 	A3_COD, "
	cSQL += " 	A3_CGC, "

	cSQL += " 	D1_COD, "
	cSQL += " 	D1_QUANT, "
	cSQL += " 	D1_VUNIT, "
	cSQL += " 	D1_TOTAL, "
	cSQL += " 	D1_VALIPI, "
	cSQL += " 	D1_VALIMP5, "
	cSQL += " 	D1_VALIMP6, "
	cSQL += " 	D1_ICMSRET, "
	cSQL += " 	D1_VALICM, "
	cSQL += " 	D1_DESC "

	cSQL += " 	FROM "
	cSQL +=  		RetSQLName("SF1")
	cSQL += " 		INNER JOIN "
	cSQL +=  			RetSQLName("SD1")
	cSQL += " 			ON "
	cSQL += " 				D1_FILIAL	= F1_FILIAL AND "
	cSQL += " 				D1_DOC 		= F1_DOC AND "
	cSQL += " 				D1_SERIE	= F1_SERIE AND "
	cSQL += " 				D1_FORNECE	= F1_FORNECE AND "
	cSQL += " 				D1_LOJA		= F1_LOJA AND "
	cSQL +=  				RetSQLName("SD1")+".D_E_L_E_T_ = ' ' "
	cSQL += " 		INNER JOIN "
	cSQL +=  			RetSQLName("SD2")
	cSQL += " 			ON "
	cSQL += " 				D1_FILIAL	= D2_FILIAL AND "
	cSQL += " 				D1_NFORI	= D2_DOC AND "
	cSQL += " 				D1_SERIORI	= D2_SERIE AND "  
	cSQL += " 				D1_ITEMORI = D2_ITEM AND "
	cSQL += " 				D1_FORNECE	= D2_CLIENTE AND "
	cSQL += " 				D1_LOJA		= D2_LOJA AND "
	cSQL += " 				D2_FORNEC	= '000041' AND "
	cSQL +=  				RetSQLName("SD2")+".D_E_L_E_T_ = ' ' "
	cSQL += " 		INNER JOIN "
	cSQL +=  			RetSQLName("SF2")
	cSQL += " 			ON "
	cSQL += " 				D2_FILIAL 	= F2_FILIAL AND "
	cSQL += " 				D2_DOC 		= F2_DOC AND "
	cSQL += " 				D2_SERIE 	= F2_SERIE AND "
	cSQL += " 				D2_CLIENTE  = F2_CLIENTE AND "
	cSQL += " 				D2_LOJA 	= F2_LOJA AND "
	cSQL +=  				RetSQLName("SF2")+".D_E_L_E_T_ = ' ' "	
	cSQL += " 		INNER JOIN "
	cSQL +=  			RetSQLName("SF4")
	cSQL += " 			ON "
	cSQL += " 				F4_FILIAL = D1_FILIAL AND "
	cSQL += " 				F4_CODIGO = D1_TES AND "
	cSQL += " 				F4_DUPLIC = 'S' AND "
	cSQL +=  				RetSQLName("SF4")+".D_E_L_E_T_ = ' ' "       
	cSQL += " 		INNER JOIN "
	cSQL +=  			RetSQLName("SA1")
	cSQL += " 			ON "
	cSQL += " 				A1_FILIAL 	= '"+xFilial("SA1")+"' AND "
	cSQL += " 				A1_COD 		= D1_FORNECE AND "
	cSQL += " 				A1_LOJA 	= D1_LOJA AND "
	cSQL +=  				RetSQLName("SA1")+".D_E_L_E_T_ = ' ' "
	cSQL += " 		INNER JOIN "
	cSQL +=   			RetSQLName("SA3")
	cSQL += " 			ON "
	cSQL += " 				A3_FILIAL = '"+xFilial("SA3")+"' AND "
	cSQL += " 				A3_COD = F2_VEND1 AND "
	cSQL +=  				RetSQLName("SA3")+".D_E_L_E_T_ = ' ' "     
	cSQL += " 		WHERE "
	cSQL += " 			F1_FILIAL = '"+xFilial("SF1")+"' AND "
	cSQL += " 			F1_DTDIGIT = '"+DtoS(dDataBase-1)+"' AND "
	cSQL += " 			F1_TIPO = 'D' AND "
	cSQL +=  			RetSQLName("SF1")+".D_E_L_E_T_ = ' ' "
	cSQL += " ORDER BY D1_DOC, D1_SERIE, A1_COD, A1_LOJA "
	
	cSQL := ChangeQuery(cSQL)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),"QRYVEND",.T.,.T.)  

	TCSETFIELD("QRYVEND","D1_DTDIGIT","D",8,0)
	
	While !QRYVEND->(Eof())					             

		If QRYVEND->F1_DOC <> cDocOld
			cCodVen := IIf(!Empty(QRYVEND->A3_CGC),QRYVEND->A3_CGC,QRYVEND->A3_COD)
			cCodCli := IIf(!Empty(QRYVEND->A1_CGC),QRYVEND->A1_CGC,QRYVEND->A1_COD)
	
			aAdd(aDetal,{	"02",; 												//Tipo de Registro - 02
							IIf(QRYVEND->A1_TIPO=="F","01","02"),;				//Tipo de Faturamento - 02
							QRYVEND->D1_DOC,;                               	//N๚mero NF - 20
							IIf(Empty(QRYVEND->D1_SERIE),"1",QRYVEND->D1_SERIE),;//S้rie NF - 03
							"02",;				                            	//Tipo NF - 02
							DtoS(QRYVEND->D1_DTDIGIT),;							//Data Emissใo NF - 12
							u_DipRetCE(cCodVen),;								//C๓digo do Vendedor - 20
							u_DipRetCE(cCodCli),;								//C๓digo Cliente - 20
							"SP",;												//UF Emissor Mercadoria - 02
							"06278010",;										//CEP Emissor Mercadoria - 08
							QRYVEND->A1_ESTE,;									//UF Destinatแrio Mercadoria - 02
							QRYVEND->A1_CEPE,;									//CEP Destinatแrio Mercadoria - 08
							IIf(QRYVEND->F1_TPFRETE=="C","CIF","FOB"),;			//Condi็ใo de Entrega (tipo de frete) - 03
							DipRetDP(QRYVEND->F1_COND) })						//Dias de Pagamento - 03
		EndIf

		aAdd(aDetal,{	"03",; 													//Tipo de Registro - 02
						QRYVEND->D1_DOC,;                              		 	//N๚mero NF - 20
						IIf(Empty(QRYVEND->D1_SERIE),"1",QRYVEND->D1_SERIE),;	//S้rie NF - 03
						"02",;				                         		   	//Tipo NF - 02
						QRYVEND->D1_COD,;							 			//C๓digo do Item - 30
						u_DipPadDec(QRYVEND->D1_QUANT,10,5),;		 			//Quantidade Vendida - 10.05
						u_DipPadDec(QRYVEND->D1_VUNIT,10,2),;		 			//Pre็o Unitแrio Bruto Praticado - 10.02
						"N",;										 			//Bonifica็ใo - 01					
						u_DipPadDec(QRYVEND->(D1_TOTAL+D1_VALIPI),10,2),;		//Valor Total Bruto - 10.02
						u_DipPadDec(QRYVEND->D1_TOTAL,10,2),;		 			//Valor Total Lํquido - 10.02
						u_DipPadDec(QRYVEND->D1_VALIPI,10,2),;		 			//Valor IPI - 10.02
						u_DipPadDec(QRYVEND->(D1_VALIMP5+D1_VALIMP6),10,2),;	//Valor PIS \ CONFINS - 10.02
						u_DipPadDec(QRYVEND->D1_ICMSRET,10,2),;			  		//Valor Substitui็ใo Tributแria - 10.02
						u_DipPadDec(QRYVEND->D1_VALICM,10,2),;					//Valor ICMS - 10.02 
						u_DipPadDec(QRYVEND->D1_DESC,10,2) })					//Valor Descontos - 10.02

						
		cDocOld := QRYVEND->F1_DOC        
				
		QRYVEND->(dbSkip())					
	EndDo
	QRYVEND->(dbCloseArea())	 		
	
	u_DipGerN3M(aCabec,aDetal,cNomArq)			
EndIf

Return 
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDIPNVEND  บAutor  ณMicrosiga           บ Data ณ  09/01/16   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function DipRetDP(cCodPag)
Local cRet 		:= "0"
DEFAULT cCodPag := ""

SE4->(dbSetOrder(1))
If SE4->(dbSeek(xFilial("SE4")+cCodPag))
	cRet := AllTrim(SE4->E4_COND)
	cRet := SubStr(cRet,RAt(",",cRet)+1,Len(cRet))
	cRet := cValToChar(Val(cRet))
EndIf

Return cRet
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
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
User Function DipNCli3M()
Local aCabec := {}
Local aDetal := {}     
Local cSeqRC := ""
Local cSQL   := ""                                        
Local cPerg  := "RELCLI" 
LOcal cDataHor := ""
            
cSQL := " SELECT "
cSQL += " 	A1_CGC, A1_CEP, A1_EST, A1_MUN, A1_END, A1_BAIRRO, A1_NOME, A1_NREDUZ, A1_TEL, A1_CONTATO "
cSQL += " 	FROM "
cSQL +=  		RetSQLName("SD2")
cSQL += " 		INNER JOIN "
cSQL +=  			RetSQLName("SA1")
cSQL += " 			ON "
cSQL += " 				A1_FILIAL = '"+xFilial("SA1")+"' AND "
cSQL += " 				A1_COD = D2_CLIENTE AND "
cSQL += " 				A1_LOJA = D2_LOJA AND "
cSQL +=  				RetSQLName("SA1")+".D_E_L_E_T_ = ' ' "  
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
cSQL +=  			RetSQLName("SD2")+".D_E_L_E_T_ = ' ' "
cSQL += " GROUP BY A1_CGC, A1_CEP, A1_EST, A1_MUN, A1_END, A1_BAIRRO, A1_NOME, A1_NREDUZ, A1_TEL, A1_CONTATO  "

cSQL := ChangeQuery(cSQL)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),"QRYREL",.T.,.T.)  
   
If !QRYREL->(Eof())                

	cDataHor := DtoS(dDataBase-1)+StrTran(Left(Time(),5),":","")
	cNomArq  := "RELCLI_"+IIf(cFilAnt=="01","47869078000100","47869078000453")+"_"+cDataHor+".txt"
	
	cSeqRC := U_DipSeqZT("RELCLI")
	
	aAdd(aCabec,{	"01",;	   		   		  								//Tipo de Registro - 02
					"RELCLI",;  	  	  	 								//Identifica็ใo - 06
					"050",;													//Versใo - 03
					cSeqRC,;												//N๚mero Relat๓rio - 20
					cDataHor,; 	   											//Data - Hora de Emissใo do Documento - 12
					IIf(cFilAnt=="01","47869078000100","47869078000453"),; 	//CNPJ do Emissor do Relat๓rio - 14
					"03887830009046"}) 										//CNPJ do Destinatแrio do Relat๓rio - 14

	While !QRYREL->(Eof())					
		aAdd(aDetal,{	"02",; 													//Tipo de Registro - 02
						QRYREL->A1_CGC,;                                        //C๓digo cliente - 20
						QRYREL->A1_CEP,;                                        //CEP Cliente - 08
						QRYREL->A1_EST,;                                        //UF Cliente - 02
						u_DipRetCE(QRYREL->A1_MUN),;                            //Cidade Cliente - 100
						u_DipRetCE(QRYREL->A1_END),;                            //Endere็o Cliente - 100
						Left(u_DipRetCE(QRYREL->A1_BAIRRO),50),;                //Bairro Cliente - 50
						u_DipRetCE(QRYREL->A1_NOME),;                           //Nome Cliente - 100
						"169",;	//Outros										//C๓digo Segmento Cliente - 03
						"04",;	//Outros										//Frequ๊ncia Visita - 02
						QRYREL->A1_TEL,;                                        //Telefone Cliente - 20
						Left(u_DipRetCE(QRYREL->A1_CONTATO),50)})               //Contato Cliente - 50
		QRYREL->(dbSkip())					
	EndDo
	QRYREL->(dbCloseArea())	 	
	
EndIf

cSQL := " SELECT "
cSQL += " 	A1_CGC, A1_CEP, A1_EST, A1_MUN, A1_END, A1_BAIRRO, A1_NOME, A1_NREDUZ, A1_TEL, A1_CONTATO "
cSQL += " 	FROM "
cSQL +=  		RetSQLName("SD1")
cSQL += " 		INNER JOIN "
cSQL +=  			RetSQLName("SA1")
cSQL += " 			ON "
cSQL += " 				A1_FILIAL = '"+xFilial("SA1")+"' AND "
cSQL += " 				A1_COD = D1_FORNECE AND "
cSQL += " 				A1_LOJA = D1_LOJA AND "
cSQL +=  				RetSQLName("SA1")+".D_E_L_E_T_ = ' ' "  
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
cSQL +=  			RetSQLName("SD1")+".D_E_L_E_T_ = ' ' "
cSQL += " GROUP BY A1_CGC, A1_CEP, A1_EST, A1_MUN, A1_END, A1_BAIRRO, A1_NOME, A1_NREDUZ, A1_TEL, A1_CONTATO  "

cSQL := ChangeQuery(cSQL)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),"QRYREL2",.T.,.T.)  

If !QRYREL2->(Eof())                
	While !QRYREL2->(Eof())					
		aAdd(aDetal,{	"02",; 													//Tipo de Registro - 02
						QRYREL2->A1_CGC,;                                        //C๓digo cliente - 20
						QRYREL2->A1_CEP,;                                        //CEP Cliente - 08
						QRYREL2->A1_EST,;                                        //UF Cliente - 02
						u_DipRetCE(QRYREL2->A1_MUN),;                            //Cidade Cliente - 100
						u_DipRetCE(QRYREL2->A1_END),;                            //Endere็o Cliente - 100
						Left(u_DipRetCE(QRYREL2->A1_BAIRRO),50),;                //Bairro Cliente - 50
						u_DipRetCE(QRYREL2->A1_NOME),;                           //Nome Cliente - 100
						"169",;	//Outros										//C๓digo Segmento Cliente - 03
						"04",;	//Outros										//Frequ๊ncia Visita - 02
						QRYREL2->A1_TEL,;                                        //Telefone Cliente - 20
						Left(u_DipRetCE(QRYREL2->A1_CONTATO),50)})               //Contato Cliente - 50
		QRYREL2->(dbSkip())					
	EndDo
	QRYREL2->(dbCloseArea())	 	
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
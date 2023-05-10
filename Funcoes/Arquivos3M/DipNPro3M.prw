#INCLUDE "PROTHEUS.CH"
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �NOVO19    �Autor  �Microsiga           � Data �  08/17/16   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function DipNPro3M()
Local aCabec := {}
Local aDetal := {}     
Local cSeqRP := ""
Local cSQL   := ""                                        
Local cPerg  := "RELPRO" 
LOcal cDataHor := ""
Local cQryAux1 := ""
Local cQryAux2 := ""    
Local cMsgCIC  := ""
Local cCICDest := ""

cQryAux1 := " SELECT DISTINCT "
cQryAux1 += " 	D2_COD "
cQryAux1 += "	FROM "        
cQryAux1 += 		RetSQLName("SD2")
cQryAux1 += "		WHERE "
cQryAux1 += " 			D2_FILIAL 	= B1_FILIAL AND "
cQryAux1 += " 			D2_EMISSAO  = '"+DtoS(dDataBase-1)+"' AND "
cQryAux1 += " 			D2_COD 		= B1_COD AND "    
cQryAux1 += " 			D2_LOCAL 	= '01' AND "
cQryAux1 +=   			RetSQLName("SD2")+".D_E_L_E_T_ = ' ' "       

cQryAux2 := " SELECT DISTINCT "
cQryAux2 += " 	B2_COD "
cQryAux2 += " 	FROM "
cQryAux2 +=   		RetSQLName("SB2")
cQryAux2 += " 		WHERE "
cQryAux2 += " 			B2_FILIAL = B1_FILIAL AND "
cQryAux2 += " 			B2_COD = B1_COD AND "
cQryAux2 += " 			B2_QATU > 0 AND "
cQryAux2 += " 			B2_LOCAL = '01' AND "
cQryAux2 +=   			RetSQLName("SB2")+".D_E_L_E_T_ = ' ' "
            
cSQL := " SELECT "
cSQL += " 	A2_CGC, B1_COD, A5_CODPRF, A5_QTDUN3M, B1_PRVSUPE, B1_PRVMINI, B1_DESC "
cSQL += "  	FROM "
cSQL +=  		RetSQLName("SB1")
cSQL += "  		INNER JOIN "
cSQL +=  			RetSQLName("SA2")
cSQL += "  			ON "
cSQL += "  				A2_FILIAL = '"+xFilial("SA2")+"' AND "
cSQL += "  				A2_COD = B1_PROC AND "
cSQL +=   				RetSQLName("SA2")+".D_E_L_E_T_ = ' ' "     
cSQL += " 		LEFT JOIN "
cSQL +=  			RetSQLName("SA5")
cSQL += " 			ON "
cSQL += " 				A5_FILIAL = '"+xFilial("SA5")+"' AND "
cSQL += " 				A5_FORNECE = B1_PROC AND "
cSQL += " 				A5_PRODUTO = B1_COD AND "
cSQL +=  				RetSQLName("SA5")+".D_E_L_E_T_ = ' ' "   
cSQL += "  		WHERE "
cSQL += "  			B1_FILIAL = '"+xFilial("SB1")+"' AND "
cSQL += "  			B1_TIPO = 'PA' AND "
cSQL += "  			B1_PROC = '000041' AND "                  
cSQL += "  			(B1_COD IN("+cQryAux1+") OR "
cSQL += "  			B1_COD IN("+cQryAux2+")) AND "                  
cSQL += "  			B1_COD NOT IN('"+GetNewPar("ES_SEMCD3M","011705")+"') AND "                  
cSQL +=   			RetSQLName("SB1")+".D_E_L_E_T_ = ' ' "
cSQL += " GROUP BY A2_CGC, B1_COD, A5_CODPRF, A5_QTDUN3M, B1_PRVSUPE, B1_PRVMINI, B1_DESC "

cSQL := ChangeQuery(cSQL)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),"QRYPRO",.T.,.T.)  

TCSETFIELD("QRYPRO","A5_QTDUN3M","N",09,0)
TCSETFIELD("QRYPRO","BF_PRVMINI","N",12,4)
TCSETFIELD("QRYPRO","BF_PRVSUPE","N",12,4)
   
If !QRYPRO->(Eof())                

	cDataHor := DtoS(dDataBase-1)+StrTran(Left(Time(),5),":","")
	cNomArq  := "RELPRO_"+IIf(cFilAnt=="01","47869078000100","47869078000453")+"_"+cDataHor+".txt"
	
	cSeqRP := U_DipSeqZT("RELPRO")
	
	aAdd(aCabec,{	"01",;	   		   		  								//Tipo de Registro - 02
					"RELPRO",;  	  	  	 								//Identifica��o - 06
					"050",;													//Vers�o - 03
					cSeqRP,;												//N�mero Relat�rio - 20
					cDataHor,; 	   											//Data - Hora de Emiss�o do Documento - 12
					IIf(cFilAnt=="01","47869078000100","47869078000453"),; 	//CNPJ do Emissor do Relat�rio - 14
					"03887830009046"}) 										//CNPJ do Destinat�rio do Relat�rio - 14

	While !QRYPRO->(Eof())	

		If Empty(QRYPRO->A5_CODPRF)
			Conout("Anten��o","O produto "+AllTrim(QRYPRO->B1_COD)+" n�o possui c�digo 3M cadastrado")    
			
			cCICDest:= GetNewPar("ES_CICNE3M","DIEGO.DOMINGOS,MAXIMO.CANUTO,ROSEMEIRE.FERRARIS") 
			
			cMsgCIC := "ATEN��O! PRODUTO 3M SEM CODIGO CADASTRADO." +CHR(13)+CHR(10)+CHR(13)+CHR(10)
			cMsgCIC += " PRODUTO: " + AllTrim(QRYPRO->B1_COD) +CHR(13)+CHR(10)+CHR(13)+CHR(10)
			cMsgCIC += " POR FAVOR, PREENCHA O CADASTRO." +CHR(13)+CHR(10)+CHR(13)+CHR(10)
			
			U_DIPCIC(cMsgCIC,cCICDest)
		EndIf
                   
        nValAux := 0
		nValAux := IIf(QRYPRO->B1_PRVSUPE>0 .And. QRYPRO->B1_PRVSUPE<QRYPRO->B1_PRVMINI,QRYPRO->B1_PRVSUPE,QRYPRO->B1_PRVMINI)
				
		aAdd(aDetal,{	"02",; 													//Tipo de Registro - 02
						PADR(QRYPRO->A2_CGC,20),;                               //C�digo Fornece - 20
						PADR(QRYPRO->B1_COD,20),;                               //C�d. Item - 20
						PADR(IIf(Empty(QRYPRO->A5_CODPRF),"CODIGO"+QRYPRO->B1_COD,QRYPRO->A5_CODPRF),14),;//C�d. Prod. - 14
						"01",;                            						//Tipo Item - 02
						u_DipPadDec(QRYPRO->A5_QTDUN3M,10,5),;                 	//Qtd. Prod. Emb. - 10.05
						u_DipPadDec(nValAux,10,2),; 							//Pre�o Unid. 10.02
						PadR(u_DipRetCE(QRYPRO->B1_DESC),100),;      			//Descricao Interna Item 100
						"01"})             										//Status Produto 02
		QRYPRO->(dbSkip())					
	EndDo          
	QRYPRO->(dbCloseArea())	 	

	u_DipGerN3M(aCabec,aDetal,cNomArq)		
EndIf

Return 
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �DIPNPRO3M �Autor  �Microsiga           � Data �  08/18/16   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function AjustaSX1(cPerg)
Local aRegs 	:= {}
DEFAULT cPerg 	:= ""

dbSelectArea("SX1")
dbSetOrder(1)

aAdd(aRegs,{cPerg,"01","Data De  ?","","","mv_ch1","D",8,0,0,"G","","MV_PAR01","","","","","","","","","","","","","","","","","","","","","","","","",''})
aAdd(aRegs,{cPerg,"02","Data Ate ?","","","mv_ch2","D",8,0,0,"G","","MV_PAR02","","","","","","","","","","","","","","","","","","","","","","","","",''})
aAdd(aRegs,{cPerg,"03","Vers�o   ?","","","mv_ch3","C",3,0,0,"G","","MV_PAR03","","","","","","","","","","","","","","","","","","","","","","","","",''})

PlsVldPerg( aRegs )

Return
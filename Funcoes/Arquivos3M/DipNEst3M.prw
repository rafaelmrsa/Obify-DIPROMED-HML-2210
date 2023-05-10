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
User Function DipNEst3M()
Local aCabec := {}
Local aDetal := {}     
Local cSeqRE := ""
Local cSQL   := ""                                        
Local cPerg  := "RELEST" 
LOcal cDataHor := ""
            
cSQL := " SELECT "
cSQL += " 	B2_QATU, * "
cSQL += " 	FROM "
cSQL +=  		RetSQLName("SB1")
cSQL += " 		INNER JOIN "
cSQL +=  			RetSQLName("SB2")
cSQL += " 			ON "
cSQL += " 				B2_FILIAL = B1_FILIAL AND "
cSQL += " 				B2_COD = B1_COD "     
cSQL += " 		LEFT JOIN "
cSQL +=  			RetSQLName("SA5")
cSQL += " 			ON "
cSQL += " 				A5_FILIAL = '"+xFilial("SA5")+"' AND "
cSQL += " 				A5_FORNECE = B1_PROC AND "
cSQL += " 				A5_PRODUTO = B1_COD AND "
cSQL +=  				RetSQLName("SA5")+".D_E_L_E_T_ = ' ' "   
cSQL += " 		WHERE "
cSQL += " 			B1_FILIAL = '"+xFilial("SB1")+"' AND "
cSQL += " 			B1_PROC = '000041' AND "
cSQL += "  			B1_TIPO = 'PA' AND "
cSQL += "  			B1_COD NOT IN('"+GetNewPar("ES_SEMCD3M","011705")+"') AND "                  
cSQL += " 			B2_QATU > 0 AND "
cSQL += " 			B2_LOCAL = '01' AND "
cSQL +=  			RetSQLName("SB1")+".D_E_L_E_T_ = ' ' AND "
cSQL +=  			RetSQLName("SB2")+".D_E_L_E_T_ = ' ' "

cSQL := ChangeQuery(cSQL)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),"QRYEST",.T.,.T.)  
   
If !QRYEST->(Eof())                

	cDataHor := DtoS(dDataBase-1)+StrTran(Left(Time(),5),":","")
	cNomArq  := "RELEST_"+IIf(cFilAnt=="01","47869078000100","47869078000453")+"_"+cDataHor+".txt"
	
	cSeqRE := U_DipSeqZT("RELEST")
	
	aAdd(aCabec,{	"01",;	   		   		  								//Tipo de Registro - 02
					"RELEST",;  	  	  	 								//Identifica��o - 06
					"050",;													//Vers�o - 03
					cSeqRE,;												//N�mero Relat�rio - 20
					cDataHor,; 	   											//Data - Hora de Emiss�o do Documento - 12
					DtoS(dDataBase-1),;										//Data Inicial do Per�odo de Estoque - 08
					DtoS(dDataBase-1),;                                     //Data Final do Per�odo de Estoque - 08
					IIf(cFilAnt=="01","47869078000100","47869078000453"),; 	//CNPJ do Emissor do Relat�rio - 14
					"45985371000108"}) 										//CNPJ do Destinat�rio do Relat�rio - 14

	While !QRYEST->(Eof())					     
	
		If Empty(QRYEST->A5_CODPRF)
			Conout("Anten��o","O produto "+AllTrim(QRYEST->B1_COD)+" n�o possui c�digo 3M cadastrado")
		EndIf
	
		aAdd(aDetal,{	"02",; 														//Tipo de Registro - 02
						cDataHor,;                                        			//Data � Hora do Estoque - 12
						AllTrim(QRYEST->B1_COD),;                               	//C�digo Item - 08
						u_DipPadDec(QRYEST->(B2_QATU-B2_QACLASS-B2_RESERVA),10,2),;	//Quantidade em Estoque - 10.02
						"0.00" })					                            	//Quantidade Estoque Tr�nsito - 10.02
		QRYEST->(dbSkip())					
	EndDo
	QRYEST->(dbCloseArea())	 	

	u_DipGerN3M(aCabec,aDetal,cNomArq)		
EndIf

Return 
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �DIPNCLI3M �Autor  �Microsiga           � Data �  08/18/16   ���
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

aAdd(aRegs,{cPerg,"01","Vers�o   ?","","","mv_ch1","C",3,0,0,"G","","MV_PAR01","","","","","","","","","","","","","","","","","","","","","","","","",''})

PlsVldPerg( aRegs )

Return
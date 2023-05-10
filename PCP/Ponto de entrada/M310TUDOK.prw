#INCLUDE "PROTHEUS.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณNOVO3     บAutor  ณMicrosiga           บ Data ณ  04/07/17   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function M310TUDOK() 
Local nQtdTran 	:= PARAMIXB[1]
Local cFilOri 	:= PARAMIXB[2]
Local cCodPro 	:= PARAMIXB[3]
Local cLocal  	:= PARAMIXB[4]
Local cFilDes 	:= PARAMIXB[5]
Local cLocDes 	:= PARAMIXB[6]
//Local nQtd2   := PARAMIXB[7]
Local lRet  := .F.     
        
lRet := DipVldCxF(cCodPro,nQtdTran,cFilOri,cFilDes) //Valida caixa de embarque

If lRet
	VldSldB2(cCodPro,cLocal,nQtdTran,cFilOri)
EndIf
                                                                              
  
If cEmpAnt=="04" 
	If !Upper(U_DipUsr())$GetNewPar("ES_MTLOCAL","CSOSSOLOTE")
		If cFilOri=="01" .And. (cLocal<>"02" .Or. cLocDes<>"01")
			If POSICIONE("SB1",1,xFilial("SB1")+cCodPro,"B1_TIPO")=="MP"
				If Aviso("Aten็ใo","Deseja confirmar a transfer๊ncia de MP do local 01 para o CD?",{"Sim","Nใo"})<>1
					lRet := .F.	
				EndIf
			Else
				Aviso("Aten็ใo","HQ Matriz: Obrigat๓rio Local de Origem 02 e Local de Destino 01",{"Ok"})
				lRet := .F.
			EndIf
		ElseIf cFilOri=="02" .And. (cLocal<>"01" .Or. cLocDes<>"01")
			Aviso("Aten็ใo","HQ CD: Obrigat๓rio Local de Origem 01 e Local de Destino 01",{"Ok"})
			lRet := .F.
		EndIf        
	EndIf
	If cFilOri==cFilDes
		Aviso("Aten็ใo","Filial destino informada ้ igual เ filial origem."+CHR(13)+CHR(10)+"Escolha outra filial para o destino.",{"Ok"})
		lRet := .F.
	EndIf
EndIf

Return lRet     
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณM310TUDOK บAutor  ณMicrosiga           บ Data ณ  04/07/17   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function DipVldCxF(cCodPro,nQtdTran,cFilOri,cFilDes)
Local aAreaSB1 	:= SB1->(GetArea())
Local lRet 		:= .T.      
Local nQtdCxEmb := 0  
Local cProblema := ""
DEFAULT cCodPro := ""
DEFAULT nQtdTran:= 0
DEFAULT cFilOri := ""
DEFAULT cFilDes := ""

SB1->(dbSetOrder(1))
If SB1->(dbSeek(cFilOri+cCodPro))            
	cProblema := DipVldSB1(cCodPro,cFilOri,cFilDes)  
	If !Empty(cProblema)
		Aviso("ERRO","ERRO - Corrija o(s) seguinte(s) erro(s) antes de prosseguir: "+CHR(13)+CHR(10)+;
						"............................................................................"+CHR(13)+CHR(10)+;
						cProblema,{"Ok"},3)
		lRet := .F.
	ElseIf SB1->B1_XCXFECH=="1"
		If SB1->B1_XTPEMBV=="1"
			nQtdCxEmb := SB1->B1_XQTDEMB
		ElseIf SB1->B1_XTPEMBV=="2"
			nQtdCxEmb := SB1->B1_XQTDSEC
		Else
			nQtdCxEmb := 1
		EndIf
	
		If Mod(nQtdTran,nQtdCxEmb)<>0
			Aviso("Aten็ใo","Quantidade invแlida. O produto: "+CHR(13)+CHR(10)+;
							""+AllTrim(SB1->B1_COD)+"-"+AllTrim(SB1->B1_DESC)+CHR(13)+CHR(10)+;
							"s๓ poderแ ser movimentado em multiplos de "+AllTrim(Str(nQtdCxEmb)),{"Ok"},2)
			lRet := .F.
		EndIf				
	EndIf
Else 
	Aviso("DIPA071","Produto nใo encontrado. Avise o T.I.",{"Ok"},1)
	lRet := .F.
EndIf        

RestArea(aAreaSB1)

Return lRet 
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณM310TUDOK บAutor  ณMicrosiga           บ Data ณ  04/07/17   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function VldSldB2(cCodPro,cLocal,nQuant,cFilOri)
Local lRet 		:= .F.      
Local nSaldoB2	:= 0
Local aAreaSB2 	:= SB2->(GetArea())
DEFAULT cCodPro := ""
DEFAULT cLocal 	:= ""
DEFAULT nQuant 	:= 0
DEFAULT cFilOri := ""

SB2->(dbSetOrder(1))
If SB2->(dbSeek(cFilOri+cCodPro+cLocal))
	nSaldoB2 := SaldoSB2()
	If nSaldoB2 < nQuant
         Aviso("Aten็ใo","Saldo Insuficiente."+CHR(13)+CHR(10)+"Saldo disponํvel: "+cValtoChar(nSaldoB2),{'Ok'}) 
 	Else
 		lRet := .T.
	Endif        
Else
	Aviso("Aten็ใo","Produto nใo encontrado.",{"Ok"})	                            	
Endif	          
  
RestArea(aAreaSB2)

Return lRet        
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณM310TUDOK บAutor  ณMicrosiga           บ Data ณ  08/25/17   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function DipVldSB1(cCodPro,cFilOri,cFilDes)
Local aArea 	:= GetArea()
Local cSQL  	:= ""
Local cProblema := ""     
DEFAULT cCodPro := ""
DEFAULT cFilOri := ""
DEFAULT cFilDes := ""

cSQL := " SELECT "
cSQL += " 	A.B1_UM UM_M		 , B.B1_UM UM_C, "
cSQL += " 	A.B1_MSBLQL BLQ_M	 , B.B1_MSBLQL BLQ_C, "
cSQL += " 	A.B1_TIPCONV TPCON_M , B.B1_TIPCONV TPCON_C, "
cSQL += " 	A.B1_CONV CON_M		 , B.B1_CONV CON_C, "
cSQL += " 	A.B1_SEGUM SEG_M	 , B.B1_SEGUM SEG_C "
cSQL += " 	FROM "
cSQL +=  		RetSQLName("SB1")+" A, "+RetSQLName("SB1")+" B "
cSQL += " 		WHERE "
cSQL += " 			A.B1_FILIAL  =  '"+cFilOri+"' AND "
cSQL += " 			A.B1_COD 	 =  '"+cCodPro+"' AND "
cSQL += " 			B.B1_FILIAL  =  '"+cFilDes+"' AND "
cSQL += " 			A.B1_COD 	 =  B.B1_COD AND "
cSQL += " 			A.B1_TIPO 	 <> 'MC' AND "
cSQL += " 			B.B1_TIPO 	 <> 'MC' AND "
cSQL += " 			(A.B1_MSBLQL =  '1' OR "
cSQL += " 			B.B1_MSBLQL  =  '1' OR "
cSQL += " 			A.B1_CONV 	 <> B.B1_CONV OR "
cSQL += " 			A.B1_TIPCONV <> B.B1_TIPCONV OR "
cSQL += " 			A.B1_UM 	 <> B.B1_UM OR "
cSQL += " 			A.B1_SEGUM 	 <> B.B1_SEGUM) AND "
cSQL += " 			A.D_E_L_E_T_ =  ' ' AND "
cSQL += " 			B.D_E_L_E_T_ =  ' ' "

cSQL := ChangeQuery(cSQL)
DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSQL),"QRYSB1",.F.,.T.)     

If !QRYSB1->(Eof())   
	If QRYSB1->BLQ_M == "1"
		cProblema += "Produto bloqueado na Matriz;"+CHR(13)+CHR(10)
	EndIf
	If QRYSB1->BLQ_C=="1"                         
		cProblema += "Produto bloqueado no CD;"+CHR(13)+CHR(10)
	EndIf
	If QRYSB1->UM_M <> QRYSB1->UM_C    
		cProblema += "Unidade de medida diferente entre MTZ: "+AllTrim(QRYSB1->UM_M)+" e CD: "+AllTrim(QRYSB1->UM_C)+";"+CHR(13)+CHR(10)
	EndIf                                                  		
	If QRYSB1->TPCON_M <> QRYSB1->TPCON_C                  
		cProblema += "Tipo de conversใo difernete entre MTZ: "+AllTrim(QRYSB1->TPCON_M)+" e CD: "+AllTrim(QRYSB1->TPCON_C)+";"+CHR(13)+CHR(10)
	EndIf
	If QRYSB1->CON_M <> QRYSB1->CON_C                      
		cProblema += "Unidade de conversใo difernete entre MTZ: "+AllTrim(cValToChar(QRYSB1->CON_M))+" e CD: "+AllTrim(cValToChar(QRYSB1->CON_C))+";"+CHR(13)+CHR(10)
	EndIf                                                  	
	If QRYSB1->SEG_M <> QRYSB1->SEG_C                      
		cProblema += "Segunda UM diferente entre MTZ: "+AllTrim(QRYSB1->SEG_M)+" e CD: "+AllTrim(QRYSB1->SEG_C)+";"+CHR(13)+CHR(10)
	EndIf
EndIf
QRYSB1->(dbCloseArea())

RestArea(aArea)

Return cProblema
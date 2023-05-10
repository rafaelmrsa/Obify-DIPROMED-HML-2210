#Include "RwMake.ch"
#Include "Ap5Mail.ch"
#INCLUDE "TBICONN.CH"
#INCLUDE "FILEIO.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DIPENVWF  ºAutor  ³Microsiga           º Data ³  08/06/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function DipEnvWF(aWork)
Local cSQL 		:= ""
Local cWCodEmp  := ""
Local cWCodFil  := "" 
Local _nI		:= 0    

If ValType(aWork) == 'A'
	cWCodEmp  := aWork[1]
	cWCodFil  := aWork[2] 
	PREPARE ENVIRONMENT EMPRESA cWCodEmp FILIAL cWCodFil FUNNAME "DIPENVWF"
EndIf

Conout("Iniciou Relatorios Vendedores Emp "+cWCodEmp+" Fil "+cWCodFil+" - "+DtoC(dDataBase)+" - "+SubStr(Time(),1,2)+":"+SubStr(Time(),4,2))  

cSQL := " SELECT "
cSQL += " 	A3_COD "
cSQL += " 	FROM "
cSQL += 		RetSQLName("SA3")
cSQL += " 		WHERE "     
cSQL += " 			A3_FILIAL  = '"+xFilial("SA3")+"' AND "    
If cWCodEmp == "01"
	cSQL += " 			A3_XENVREL IN ('1','2') AND "
Else 
	cSQL += " 			A3_XENVREL IN ('1','3') AND "
EndIf
cSQL += " 			D_E_L_E_T_ = ' ' "

cSQL := ChangeQuery(cSQL)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),"QRYSA3",.T.,.T.)

While !QRYSA3->(Eof())          
	U_DIPR028({"S",QRYSA3->A3_COD,cWCodEmp,cWCodFil})                                               
	U_DIPR029({"S",QRYSA3->A3_COD,cWCodEmp,cWCodFil})                                               
   	U_DIPR030({"S",QRYSA3->A3_COD,cWCodEmp,cWCodFil})                                               
	U_DIPR031({"S",QRYSA3->A3_COD,cWCodEmp,cWCodFil})                                               
	U_DIPR032({"S",QRYSA3->A3_COD,cWCodEmp,cWCodFil})                                               
	U_DIPR033({"S",QRYSA3->A3_COD,cWCodEmp,cWCodFil})                                               
	U_DIPR063({"S",QRYSA3->A3_COD,cWCodEmp,cWCodFil})                                          	
	QRYSA3->(dbSkip())	
EndDo
QRYSA3->(dbCloseArea())    

Conout("Finalizou Relatorios Vendedores Emp "+cWCodEmp+" Fil "+cWCodFil+" - "+DtoC(dDataBase)+" - "+SubStr(Time(),1,2)+":"+SubStr(Time(),4,2))

If ValType(aWork) == 'A'
	RESET ENVIRONMENT                                       
EndIf

/*
For _nI:=1 to Len(aArray)        
	cWCodEmp := aArray[_nI,1]
	cWCodFil := aArray[_nI,2]
	U_DIPR050({'S','',cWCodEmp,cWCodFil})
Next _nI
*/                                                    
Return 
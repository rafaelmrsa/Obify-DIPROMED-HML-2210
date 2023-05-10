#INCLUDE "PROTHEUS.CH"       
#INCLUDE "TBICONN.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณNOVO25    บAutor  ณMicrosiga           บ Data ณ  12/29/16   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function DIPA081(aWork)
Local cSQL 		:= ""  
Local cDipEmp	:= ""
Local cDipFil	:= ""
Private nRet 	:= 0  

If ValType(aWork)<>'A'
	Conout("ERRO DIPA081 Emp "+cDipEmp+" FIL "+cDipFil+" - "+DtoC(dDataBase)+" - "+SubStr(Time(),1,2)+":"+SubStr(Time(),4,2))  
	Return
EndIf     

cDipEmp  := aWork[1]
cDipFil  := aWork[2] 
PREPARE ENVIRONMENT EMPRESA cDipEmp FILIAL cDipFil FUNNAME "DIPA081"

Conout("INICIOU DIPA081 Emp "+cDipEmp+" Fil "+cDipFil+" - "+DtoC(dDataBase)+" - "+SubStr(Time(),1,2)+":"+SubStr(Time(),4,2))  

Begin Transaction    

	Conout("DIPA081 (1) Inํcio Transaction: "+DtoC(dDataBase)+" - "+SubStr(Time(),1,2)+":"+SubStr(Time(),4,2)+" Emp:"+cDipEmp+" Fil:"+cDipFil)

	cSQL := " UPDATE "
	cSQL +=  	RetSQLName("SA1")
	cSQL += " 	SET "
	//cSQL += " 		A1_RISCO = 'D', A1_XSTATCR = '2', A1_LC = 0, A1_VENCLC = ' ' " - Alterado em 23/07/2019 - Solicitado pela Deise (E-mail)
	cSQL += " 		A1_RISCO = 'D', A1_VENCLC = ' ' "
	cSQL += " 		WHERE "
	cSQL += " 			A1_FILIAL = '"+xFilial("SA1")+"' AND "
	cSQL += " 			A1_ULTCOM <= '"+DtoS(dDataBase-120)+"' AND "
	cSQL += " 			A1_DTALTER<= '"+DtoS(dDataBase-3 )+"' AND "  //Regra incluํda dia 27/08/2019
	cSQL += " 			A1_RISCO IN('A','B','C') AND "
	//cSQL += " 			A1_ULTCOM <> ' ' AND " REGRA AJUSTADA 02/02/2021 PARA ABRANGER OS CLIENTES QUE NUNCA COMPRARAM.
	cSQL += " 			D_E_L_E_T_ = ' ' "     
	
	TCSQLExec(cSQL)	
	
	If nRet==0  
		Conout("DIPA081 (1) UPD executado: "+DtoC(dDataBase)+" - "+SubStr(Time(),1,2)+":"+SubStr(Time(),4,2)+" Emp:"+cDipEmp+" Fil:"+cDipFil)
	Else  
		Conout("DIPA081 (1) Erro UPD: "+DtoC(dDataBase)+" - "+SubStr(Time(),1,2)+":"+SubStr(Time(),4,2)+" Emp:"+cDipEmp+" Fil:"+cDipFil+" Erro:"+TcSqlError())
	EndIf
	
End Transaction

Begin Transaction    

	Conout("DIPA081 (2) Inํcio Transaction: "+DtoC(dDataBase)+" - "+SubStr(Time(),1,2)+":"+SubStr(Time(),4,2)+" Emp:"+cDipEmp+" Fil:"+cDipFil)

	cSQL := " UPDATE "
	cSQL +=  	RetSQLName("SA1")
	cSQL += " 	SET "
	cSQL += " 		A1_VENCLC = "+DtoS(dDataBase+90)+" "
	cSQL += " 		WHERE "
	cSQL += " 			A1_FILIAL = '"+xFilial("SA1")+"' AND "    
	//cSQL += "			A1_VENCLC <> '20010101' AND " - Alterado em 23/07/2019 - Solicitado pela Deise (E-mail)
	cSQL += " 			A1_VENCLC <= '"+DtoS(dDataBase+30)+"' AND "
	cSQL += " 			A1_RISCO IN  ('A','B') AND "
	cSQL += " 			A1_ULTCOM > '"+DtoS(dDataBase-120)+"' AND "
	cSQL += " 			D_E_L_E_T_ = ' ' "
	
	TCSQLExec(cSQL)	
	
	If nRet==0  
		Conout("DIPA081 (2) UPD executado: "+DtoC(dDataBase)+" - "+SubStr(Time(),1,2)+":"+SubStr(Time(),4,2)+" Emp:"+cDipEmp+" Fil:"+cDipFil)
	Else  
		Conout("DIPA081 (2) Erro UPD: "+DtoC(dDataBase)+" - "+SubStr(Time(),1,2)+":"+SubStr(Time(),4,2)+" Emp:"+cDipEmp+" Fil:"+cDipFil+" Erro:"+TcSqlError())
	EndIf
	
End Transaction

RESET ENVIRONMENT                                       

Return

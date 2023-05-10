#INCLUDE "PROTHEUS.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณRepVerb   บAutor  ณMicrosiga           บ Data ณ  07/02/13   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function RepVerb()
Local cPerg := "DIPVRB"    
Local cSQL  := ""
Local cAno  := ""
Local cMes  := ""      
Local cMsg  := "Nenhum registro processado"

/*
If !U_DipUsr()$"mcanuto/ddomingos"
	Aviso("Aten็ใo","Usuแrio sem acesso a rotina",{"Ok"},1)
	Return
EndIf
*/
AjustaSX1(cPerg)

If !Pergunte(cPerg,.T.)
	Return
EndIf                 

cAno := AllTrim(Str(YEAR(MV_PAR01)))
cMes := StrZero(MONTH(MV_PAR01)-2,2)

If cMes == '-1' 
	cAno := Alltrim(Str(Val(cAno)-1))
	cMes := Alltrim(Str(11))
ElseIf cMes == '00'
	cAno := Alltrim(Str(Val(cAno)-1))
	cMes := Alltrim(Str(12))
End
                
If Aviso("Aten็ใo","Deseja replicar a verba "+MV_PAR04+" do m๊s/ano "+cMes+"/"+cAno+" para o m๊s informado?",{"Nใo","Sim"},1) <> 2
	Return
EndIf

cSQL := " SELECT "
cSQL += "	RD_MAT, RD_PD, RD_TIPO1, RD_VALOR, RD_CC, RD_TIPO2 "
cSQL += "	FROM "
cSQL += 		RetSQlName("SRD")
cSQL += "		WHERE "
cSQL += "			RD_FILIAL = '"+xFilial("SRD")+"' AND "
cSQL += "			RD_MAT BETWEEN '"+MV_PAR02+"' AND '"+MV_PAR03+"' AND "
cSQL += "			RD_PD = '"+MV_PAR04+"' AND "
cSQL += "			LEFT(RD_DATPGT,6) = '"+cAno+cMes+"' AND "
cSQL += "			D_E_L_E_T_ = ' ' "      

cSQL := ChangeQuery(cSQL)

DbCommitAll()                

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),"QRYSRD",.T.,.T.)

TCSETFIELD("QRYSRD","RD_VALOR","N",17,2)              

QRYSRD->(dbGoTop())
                      
If !QRYSRD->(Eof())	                     
	cMsg := "Processo finalizado"
EndIf
                              
SRC->(dbSetOrder(1))                      

While !QRYSRD->(Eof())
	If SRC->(dbSeek(xfilial("SRC")+QRYSRD->(RD_MAT+RD_PD)))
		If Aviso("Aten็ใo", "Foram encontrados registros para esta verba na folha atual."+CHR(10)+CHR(13)+;
							"Matrํcula - "+QRYSRD->RD_MAT + CHR(10)+CHR(13) +;
							"Verba -     "+QRYSRD->RD_PD  + CHR(10)+CHR(13) +;
							"Deseja sobrescrever?", {"Nใo","Sim"},2) == 2   
							
			SRC->(RecLock("SRC",.F.))
				SRC->RC_FILIAL 	:= xFilial("SRC")
				SRC->RC_VALOR 	:= QRYSRD->RD_VALOR
				SRC->RC_DATA 	:= MV_PAR01
			SRC->(MsUnlock())  

		EndIf
	Else
		SRC->(RecLock("SRC",.T.))
			SRC->RC_FILIAL 	:= xFilial("SRC")
			SRC->RC_MAT 	:= QRYSRD->RD_MAT
			SRC->RC_PD 		:= QRYSRD->RD_PD
			SRC->RC_TIPO1 	:= QRYSRD->RD_TIPO1
			SRC->RC_VALOR 	:= QRYSRD->RD_VALOR
			SRC->RC_DATA 	:= MV_PAR01
			SRC->RC_CC 		:= QRYSRD->RD_CC
			SRC->RC_TIPO2   := QRYSRD->RD_TIPO2
		SRC->(MsUnlock())  			
	EndIf    			
	QRYSRD->(dbSkip())
EndDo           

QRYSRD->(dbCloseArea())			

Return(Aviso("Fim",cMsg,{"Ok"},1))
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAjustaSX1 บAutor  ณMicrosiga           บ Data ณ  07/02/13   บฑฑ
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

aAdd(aRegs,{cPerg,"01","Data Pgto   ?","","","mv_ch1","D", 8,0,0,"G","","MV_PAR01","","","","","","","","","","","","","","","","","","","","","","","","",''})
aAdd(aRegs,{cPerg,"02","Mat De      ?","","","mv_ch3","C", 6,0,0,"G","","MV_PAR02","","","","","","","","","","","","","","","","","","","","","","","","",'SRA'})
aAdd(aRegs,{cPerg,"03","Mat At้     ?","","","mv_ch4","C", 6,0,0,"G","","MV_PAR03","","","","","","","","","","","","","","","","","","","","","","","","",'SRA'})
aAdd(aRegs,{cPerg,"04","Verba       ?","","","mv_ch5","C", 3,0,0,"G","","MV_PAR04","","","","","","","","","","","","","","","","","","","","","","","","",'SRV'})

PlsVldPerg( aRegs )       

Return
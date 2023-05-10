#INCLUDE "PROTHEUS.CH"
User Function MTA103MNU()         
aAdd(aRotina,{"Desp. Importacao","u_DIPCUSIMP", 0 , 2, 0, nil})

If cEmpAnt == '04'
	aAdd(aRotina,{"Imp. NF HQ", "U_DIPA059", 0 , 3, 0, nil})
	aAdd(aRotina,{"Reg.Cert.Est.", "U_DIPA077", 0 , 3, 0, nil})	
EndIf

Return
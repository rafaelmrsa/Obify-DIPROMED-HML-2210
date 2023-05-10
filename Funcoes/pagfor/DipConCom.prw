#INCLUDE "RWMAKE.CH"
User Function DipConCom()                                                              
Local cConCom := ""

Do Case 
	Case cEmpAnt=='03'
		cConCom := '0006214'
	Case cEmpAnt=='04'
		cConCom := '0009344'
	Case cEmpAnt=='05'
		cConCom := '0001463'
End Case

Return cConCom
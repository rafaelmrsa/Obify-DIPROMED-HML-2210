#include "rwmake.ch"

User Function DIPA016()  
Local cUserAuto := GetMV("MV_SEPCONF") // MCVN 25/11/2008
U_DIPPROC(ProcName(0),U_DipUsr()) // JBS 05/10/2005 - Gravando o nome do Programa no SZU
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบPrograma  ณ DIPA016  บ Autor ณ   Rodrigo Franco   บ Data ณ  28/05/2002 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ AxCadastro da amarracao Separadores x Conferentes.         บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
If AllTrim(Upper(U_DipUsr())) $ cUserAuto  // MCVN 25/11/2008
	AxCadastro("SZC","Separadores x Conferentes.")
Else
	MSGSTOP("Voce nao ้ o MAXIMO","Usuario sem autorizacao!")
	Return
EndIf

Return
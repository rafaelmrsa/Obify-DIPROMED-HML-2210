#include "rwmake.ch"

User Function DIPA016()  
Local cUserAuto := GetMV("MV_SEPCONF") // MCVN 25/11/2008
U_DIPPROC(ProcName(0),U_DipUsr()) // JBS 05/10/2005 - Gravando o nome do Programa no SZU
/*
�����������������������������������������������������������������������������
���Programa  � DIPA016  � Autor �   Rodrigo Franco   � Data �  28/05/2002 ���
�������������������������������������������������������������������������͹��
���Desc.     � AxCadastro da amarracao Separadores x Conferentes.         ���
�����������������������������������������������������������������������������
*/
If AllTrim(Upper(U_DipUsr())) $ cUserAuto  // MCVN 25/11/2008
	AxCadastro("SZC","Separadores x Conferentes.")
Else
	MSGSTOP("Voce nao � o MAXIMO","Usuario sem autorizacao!")
	Return
EndIf

Return
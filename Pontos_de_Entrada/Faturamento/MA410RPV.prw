#include "rwmake.ch" 
#include "Protheus.ch" 

/*
�������������������������������������������������������������������������������
���Programa �MA410RPV  � Autor �   Maximo Canuto  � Data �  27/07/2009      ���
���������������������������������������������������������������������������͹��
���Desc.    �Inibe rentabilidade da planilha financeira                     ���
�������������������������������������������������������������������������������
*/
User Function MA410RPV()
Local _lRetorno := .T.
Local _xAlias   := GetArea()
Local _aRentZero:= {}

If Upper(U_DipUsr()) $ 'MAXIMO/ERIBERTO/DOMINGOS/VICTOR/VANDER/REGINALDO/EELIAS/MCANUTO/DDOMINGOS/VQUEIROZ/VEGON/RBORGES'   //MCVN - 28/07/09
	_aRentZero := paramixb
Else                             
	_aRentZero:={{"",0,0,0,0,0}} 
Endif

U_DIPPROC(ProcName(0),U_DipUsr()) // JBS 05/10/2005 - Gravando o nome do Programa no SZU

RestArea(_xAlias)
Return(_aRentZero)

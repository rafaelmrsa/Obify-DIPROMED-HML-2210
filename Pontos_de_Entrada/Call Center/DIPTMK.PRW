/*
�����������������������������������������������������������������������������
���Programa  � DIPTMK   � Autor � Eriberto Elias     � Data � 14/05/2004  ���
�������������������������������������������������������������������������͹��
���Descricao � Chama agenda no call center                              a ���
�����������������������������������������������������������������������������
*/

#Include "RwMake.ch"

User Function SIGATMK()
U_DIPPROC(ProcName(0),U_DipUsr()) // JBS 05/10/2005 - Gravando o nome do Programa no SZU
/*	If Upper(U_DipUsr()) == 'CARLA' .OR.;
		Upper(U_DipUsr()) == 'ANDREA' .OR.;
		Upper(U_DipUsr()) == 'CAMILA' .OR.;
		Upper(U_DipUsr()) == 'ELIANA' .OR.;
		Upper(U_DipUsr()) == 'ADRIANA' .OR.;
		Upper(U_DipUsr()) == 'CRISTINA RODRIG'
		
		TMKA380()
	EndIf
*/
Return
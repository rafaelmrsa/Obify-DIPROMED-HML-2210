#include "rwmake.ch"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � DIPA001  � Autor �   Alexandro Dias   � Data �  07/08/01   ���
�������������������������������������������������������������������������͹��
���Desc.     � AxCadastro do grupo de desconto.                           ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function DipA001()
U_DIPPROC(ProcName(0),U_DipUsr()) // JBS 05/10/2005 - Gravando o nome do Programa no SZU
If !(Upper(U_DipUsr()) $ 'EELIAS/EPONTOLDIO/APONTOLDIO/MCANUTO/DDOMINGOS/VQUEIROZ/VEGON/RBORGES')
	 Aviso("Atencao",Upper(U_DipUsr()) + ", voc� n�o tem autoriza��o para utilizar esta rotina. Qualquer d�vida falar com Eriberto!",{"Ok"} )
	 Return()
Endif
AxCadastro("SZ1","Grupo de Desconto.")
Return
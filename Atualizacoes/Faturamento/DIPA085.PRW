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
User Function DipA085()

U_DIPPROC(ProcName(0),U_DipUsr()) // JBS 05/10/2005 - Gravando o nome do Programa no SZU

If !(Upper(U_DipUsr())$GetNewPar("ES_PCADCAT","SCREATTO/MTEIXEIRA/MSANTOS/BFERREIRA/MCANUTO/DDOMINGOS/RBORGES"))
	 Aviso("Atencao",Upper(U_DipUsr())+", voc� n�o tem autoriza��o para utilizar esta rotina.",{"Ok"} )
	 Return()
Endif

AxCadastro("ZZX","Cadastro CNPJ para CAT-116.")

Return
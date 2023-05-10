/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �Dipr070() � Autor �Maximo Canuto V. Neto-MCVN � Dt �28/03/11���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Chama relat�rio de Resumo de vendas limitando acesso por   ���
���          � usuarios                                                   ���
�������������������������������������������������������������������������Ĵ��
���Uso       � Especifico Financeiro Dipromed                             ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
���Programador � Data   �  Motivo da Alteracao                            ���
�������������������������������������������������������������������������Ĵ��
���            �        �                                                 ���
���            �        �                                                 ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

User Function Dipr071()

Local cUserAuth := GetNewPar("ES_DIPR071","")
Local aArea  := GetArea()

If Upper(U_DipUsr()) $ cUserAuth
	U_UMATR660()
Else 
	Aviso('Aten��o',Upper(U_DipUsr())+ ' voc� n�o tem autoriza��o para utilizar este relat�rio.',{'Ok'})
Endif                 

RestArea(aArea)
Return(.t.)  
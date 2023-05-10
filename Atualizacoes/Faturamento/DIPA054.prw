/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �DIPA054() � Autor �Maximo Canuto V. Neto-MCVN� Data�06/01/10���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Inclui regras de ICMS-ST FORA DO ESTADO DE SP             ���
�������������������������������������������������������������������������Ĵ��
���Uso       � Especifico De Compras Dipromed                             ���
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
#INCLUDE "RWMAKE.CH"

User Function DIPA054()

Local cUserAces := GetMV("ES_USESTOE") //Ajuste para buscar usu�rios do parametro - Felipe Duran - 21/10/19

If (Upper(U_DipUsr()) $ cUserAces)
	AxCadastro("SZQ","REGRAS DE ICMS-ST FORA DO ESTADO DE SP.")
Else 
	Aviso('Aten��o',Upper(U_DipUsr())+ ' voc� n�o tem autoriza��o para utilizar esta rotina.',{'Ok'})
Endif                                                     

Return()
#Include "RwMake.Ch"

/*
��������������������������������������������������������������������������������
���Programa  �  FIMPFCH �Autor  �   Maximo Canuto   � Data �  18/10/10       ���
����������������������������������������������������������������������������͹��
���Desc.     � Esta rotina e utilizada para recalcular o valor do Frete      ���
���          � Ponto de Entrada para Alterar nome do programa Impressao      ���
��� 		 � da Ficha de registro. alterar nome da variavel "cImpFch"		 ���
��������������������������������������������������������������������������������
*/

User Function FIMPFCH()

Local _xArea := GetArea()

U_DIPPROC(ProcName(0),U_DipUsr()) // JBS 05/10/2005 - Gravando o nome do Programa no SZU

cImpFch := "U_ugper460"

RestArea(_xArea)

Return()

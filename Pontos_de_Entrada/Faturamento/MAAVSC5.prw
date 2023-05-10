#Include "Protheus.ch"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �MAAVSC5   �Autor  �D'Leme              � Data �  10/21/11   ���
�������������������������������������������������������������������������͹��
���Desc.     � Ponto de entrada chamado em v�rios momentos de atualiza��o ���
���          � da tabele SC5                                              ���
�������������������������������������������������������������������������͹��
���Uso       � Dipromed                                                   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function MAAVSC5()
	Local _nEventoSC5 := PARAMIXB[1]
	
	If ISINCALLSTACK("LOJA901A") .Or. ISINCALLSTACK("LOJA901")
		Return.T.
	EndIf
	
	If "MATA310"$Upper(FunName())
		Return .T.
	EndIf

	/*
	���          �PARAMIXB[1]: Codigo do Evento                               ���
	���          �       [1] Implantacao do Pedido de Venda                   ���
	���          �       [2] Estorno do Pedido de Venda                       ���
	���          �       [3] Liberacao do Pedido de Venda                     ���
	���          �       [4] Estorno da Liberacao do Pedido de Venda          ���
	���          �       [5] Preparacao da Nota Fiscal de Saida               ���
	���          �       [6] Exclusao da Nota Fiscal de Saida                 ���
	���          �       [7] Reavaliacao de Credito (Por Pedido)              ���
	���          �       [8] Estorno da Reavalizacao de Credito ( Por Pedido )���
	���          �       [9] Libera��o de regras ou verbas                    ���
	*/

	If U_HasNwExc(SC5->C5_NUM)
		//������������������������������������������
		//�Confirma estorno das reservas anteriores�
		//������������������������������������������
		U_DIPXRESE("EXC_NEW",SC5->C5_NUM)
	EndIf

Return Nil
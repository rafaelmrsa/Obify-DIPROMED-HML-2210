/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �M450FIL   �Autor  �Fernando R.Assun��o � Data �  06/07/06   ���
�������������������������������������������������������������������������͹��
���Desc.     �Filtrar pedidos para a tela de An.credito Pedido, mata450.  ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
*/

User Function M450FIL()
Local cRet:= "C9_PARCIAL <> 'N' .AND. C9_OPERADO <> '' "  // Alterado para verificar se o C9_OPERADO EST� PREENCHIDO E ASSIM S� MOSTRA O C9 CRIADO PELA DIPROMED - MCVN 06/08/09
U_DIPPROC(ProcName(0),U_DipUsr()) // MCVN - 22/01/2009
Return(cRet)

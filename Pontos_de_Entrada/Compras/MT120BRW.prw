/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �MT120BRW()� Autor �Jailton B Santos-JBS   � Data �22/06/2010���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Ponto de Entrada chamado na montagem do antes apresentacao ���
���          � do browse na tela.                                         ���
�������������������������������������������������������������������������Ĵ��
���Objetivo  � Programado para adicionar  a opcao para fazer a manutencao ���
���          � de agendamentos de entregas de Pedidos de compras          ���
�������������������������������������������������������������������������Ĵ��
���Uso       � Especifico Compras  Dipromed.                              ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
���Programador � Data   �  Motivo da Alteracao                            ���
�������������������������������������������������������������������������Ĵ��
���JBS         �17/10/10�Incluido a opcao de agenda                       ���
���            �        �                                                 ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
#INCLUDE "PROTHEUS.CH"

User Function MT120BRW() 
//aadd(aRotina,{ 'Agendamentos',"U_DIPA051", 0 , 8}) 
//aadd(aRotina,{ 'Agenda'      ,"U_DIPR068", 0 , 9})  // JBS 17/07/2010
Return(.T.)
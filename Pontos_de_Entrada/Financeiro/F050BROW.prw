/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �F050BROW()� Autor �Jailton B Santos-JBS   � Data �14/06/2010���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Ponto de Entrada chamado na montagem do antes apresentacao ���
���          � do browse na tela.                                         ���
�������������������������������������������������������������������������Ĵ��
���Objetivo  � Programado para adicionar  a opcao para fazer a manutencao ���
���          � das multiplas naturezas de um titulo.                      ���
�������������������������������������������������������������������������Ĵ��
���Uso       � Especifico Faturamento Dipromed.                           ���
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
/*/
#INCLUDE "TOPCONN.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "COLORS.CH"

User Function F050BROW() 
aadd(aRotina,{ 'Mult.Natureza',"U_DIPA050", 0 , 8}) 
Return(.T.)  

User Function xDIPA050(cAlias,nReg,nOpcx)

RegToMemory(cAlias,.F.)

MultNat(cAlias,,,,.f.)    

SE2->(RecLock('SE2',.f.))
SE2->E2_MULTNAT := '1' 
SE2->(MsUnLock('SE2'))

Return(.T.)
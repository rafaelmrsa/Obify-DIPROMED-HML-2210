#include "PROTHEUS.CH"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � A020DELE  � Autor � Maximo Canuto      � Data � 14/11/2008 ���
�������������������������������������������������������������������������͹��
���Descricao � Faz chamada para fun��o de gravacao do kardex na exclus�o  ���
���          � de fornecedores                                            ���
���          � 															  ���
���          � A rotina mata120 est� com problema                         ���
���          � FNC Gerada: 000000071292008	 - 18/11/2008						      ���
���          � Plano Gerado: 000000069762008                              ���
���          � Tarefa Gerada: AN�LISE DA SOLICITACAO 					  ���
���          � Analista Alocado: PATRICIA ANTAR SALOMAO                   ���
�������������������������������������������������������������������������͹��
���Uso       � ESPECIFICO DIPROMED                                        ���
�����������������������������������������������������������������������������
/*/
User Function A020EOK()
Local _areaSA2    := SA2->(getarea())  

U_DIPPROC(ProcName(0),U_DipUsr()) // MCVN - 22/01/2009

If !Altera .And. !Inclui  .And. XFilial("SF1") = '04'
	U_GravaZG("SA2") // Gravando exclus�o de fornecedores
Endif

	
RestArea(_areaSA2)
Return(.T.)

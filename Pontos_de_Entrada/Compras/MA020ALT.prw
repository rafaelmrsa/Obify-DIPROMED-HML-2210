#include "PROTHEUS.CH"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � M020ALT  � Autor � Maximo Canuto      � Data � 14/11/2008  ���
�������������������������������������������������������������������������͹��
���Descricao � Faz chamada para fun��o de gravacao do kardex na inclus�o  ���
���          � de fornecedores                                            ���
�������������������������������������������������������������������������͹��
���Uso       � ESPECIFICO DIPROMED                                        ���
�����������������������������������������������������������������������������
/*/
User Function MA020ALT()
Local _areaSA2    := SA2->(getarea())

If ALTERA
	U_GravaZG("SA2") // Gravando altera��o de fornecedores
Endif
	
RestArea(_areaSA2)
Return(.T.)

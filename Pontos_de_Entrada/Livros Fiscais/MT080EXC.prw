#include "PROTHEUS.CH"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � MT080GRV  � Autor � Maximo Canuto     � Data � 17/11/2008  ���
�������������������������������������������������������������������������͹��
���Descricao �  Atualizando SZG - Tabela de kardex ���
�������������������������������������������������������������������������͹��
���Uso       � ESPECIFICO DIPROMED                                        ���
�����������������������������������������������������������������������������
/*/
User Function MT080EXC()
Local _areaSF4    := SF4->(getarea())  
U_DIPPROC(ProcName(0),U_DipUsr()) // MCVN - 22/01/2009
U_GravaZG("SF4") // Gravando exclus�o de TES
	
RestArea(_areaSF4)
Return(.T.)

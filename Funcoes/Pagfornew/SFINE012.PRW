#include "rwmake.ch"       

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  � SFINE012 � Autor �NATALINO OLIVEIRA      � Data � 06/06/02 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Gravacao do nosso numero para o Layout CNAB PAGAR          ���
���          � Bradesco - PAGFOR                                          ��� 
���          � RETORNA O NOSSO NUMERO QUANDO COM VALOR NO E2_CODBAR, E    ��� 
���          � ZEROS QUANDO NAO TEM VALOR POSICAO ( 142 - 150 )           ��� 
�������������������������������������������������������������������������Ĵ��
���Uso       � Especifico para Dipromed                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function SFINE012()  


Private _RETNOS

U_DIPPROC(ProcName(0),U_DipUsr()) //MCVN - 22/01/2009

If SUBSTR(SE2->E2_CODBAR,1,3) == "237"

    _RETNOS := SUBS(SE2->E2_CODBAR,28,9)

ElseIf SubStr(SE2->E2_LD,1,3) == "237"

    _RETNOS := SUBS(SE2->E2_LD,14,9)

Else

    _RETNOS := "000000000"

EndIf

Return(_RETNOS)        

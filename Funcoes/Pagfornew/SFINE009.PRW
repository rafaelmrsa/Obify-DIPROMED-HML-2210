#include "rwmake.ch"       
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  � SFINE009 � Autor �   Natalino Oliveira   � Data � 06/06/02 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Gravacao da Conta Corrente no Layout CNAB PAGAR            ���
���          � Bradesco - PAGFOR SEPARAR A C/C DO CODIGO DE BARRA 105-117 ��� 
�������������������������������������������������������������������������Ĵ��
���Uso       � Especifico para Dipromed                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function SFINE009()       

Private _CTACED

U_DIPPROC(ProcName(0),U_DipUsr()) //MCVN - 22/01/2009

_CTACED := "00000000000000"

IF SUBSTR(SE2->E2_CODBAR,1,3) == "237"
    
    _Ctaced  := SUBSTR(SE2->E2_CODBAR,37,7)
	U_CalcDigCC(_Ctaced)
ElseIf SUBSTR(SE2->E2_LD,1,3) == "237"

    _Ctaced  :=  SUBSTR(SE2->E2_LD,24,7)
	U_CalcDigCC(_Ctaced)

ElseIf Empty(SE2->E2_CODBAR) .AND. EMPTY(SE2->E2_LD)

    _Ctaced  :=  U_SFINE018(SA2->A2_NUMCON,14)


EndIf             


Return(_Ctaced)        

User Function CalcDigCC()   
Local Modulo, StrMult, BaseDac, vardac

modulo := 11
strmult := "2765432"
BaseDac := _CtaCed
varDAC  := 0
FOR idac := 1 TO Len(_CtaCed)
	varDAC := VarDac+VAL (SUBSTR (baseDAC, idac, 1)) * VAL (SUBSTR (strmult, idac, 1))
NEXT
varDAC  := modulo - varDAC % modulo
varDAC  := IF (varDAC == 10, "P", IF (varDAC == 11, "0", STR (vardac, 1)))
_CtaCed:= STRZERO(VAL(_Ctaced+vardac),14,0)

Return(_CtaCed)
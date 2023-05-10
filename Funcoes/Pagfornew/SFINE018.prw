#include	"rwmake.ch"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �SFINE018  �Autor  � Jose Novaes Romeu  � Data �  27/02/02   ���
�������������������������������������������������������������������������͹��
���Desc.     � Retira os caracteres nao-numericos do numero da conta.     ���
�������������������������������������������������������������������������͹��
���Uso       � SIGAFIN - Especifico para Dipromed                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function SFINE018(cContaAux,nTamanho)

Local cConta	:= ""
Local nx			:= 0                           

U_DIPPROC(ProcName(0),U_DipUsr()) //MCVN - 22/01/2009

For nx	:= 1 to Len(cContaAux)
	If IsDigit(Subs(cContaAux,nx,1))   .or. UPPER(Subs(cContaAux,nx,1)) == "X"
		cConta	+= Subs(cContaAux,nx,1)
	EndIf
Next

cConta	:= PadL(cConta,nTamanho,"0")

Return(cConta)

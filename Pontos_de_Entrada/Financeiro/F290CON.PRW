#include "rwmake.ch"

/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������ͻ��
���Programa  � F290CON � Autor � Maximo Canuto V. neto � Data �  28/08/2008 ���
���������������������������������������������������������������������������͹��
���Descricao � Transformar cCondicao em vari�vel private para ser utilizada ���
���          � no ponto de entrada FA290.                                   ���
���������������������������������������������������������������������������ͼ��
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/

User Function F290CON()
Local cCondicao    := ''
Private aVenc      := ''  
Public cCpagtFin290:= ''
_area := GETAREA()

U_DIPPROC(ProcName(0),U_DipUsr()) // JBS 05/10/2005 - Gravando o nome do Programa no SZU

cCondicao     := Fa290PedCd()   // Monta tela para pedir condicao de pgto
aVenc         := Condicao(nValor,cCondicao,0)                                         
cCpagtFin290  := cCondicao

RESTAREA(_area)

Return(aVenc)
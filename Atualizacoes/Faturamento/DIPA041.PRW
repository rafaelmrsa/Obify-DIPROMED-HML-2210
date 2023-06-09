/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �DIPA041() �Autor  �Jailton B Santos-JBS� Data � 11/01/2010  ���
�������������������������������������������������������������������������͹��
���Desc.     � Rotina chamada de um botao na tela de cadastro de pedidos  ���
���          � para permitir ao usuario pesquisar e visualizar cliente.   ���
�������������������������������������������������������������������������͹��
���Uso       � SIGAFAT - Dipromed                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

#INCLUDE "PROTHEUS.CH"

User Function DIPA041()

Local cAlias    := "SA1"
Local pString   := cAlias
Local aArea		:= GetArea()
Local aAreaSA1  := SA1->(GetArea())        
Local aIncAlt   := {INCLUI,ALTERA}

Private cCadastro:= "Cadatro de Clientes"
Private cString  := pString
Private aRotina  := {}
Private cFiltra  := ""

DbSelectArea(cAlias)

aAdd(aRotina,{"Pesquisar"    ,"AxPesqui" ,0,1} )
aAdd(aRotina,{"Visualizar"   ,"AxVisual" ,0,2} )

DbSelectArea(cString)
DbSetOrder(1) 

mBrowse(6,1,22,75,cString)

RestArea(aAreaSA1)
RestArea(aArea)

INCLUI := aIncAlt[1]
ALTERA := aIncAlt[2]

Return
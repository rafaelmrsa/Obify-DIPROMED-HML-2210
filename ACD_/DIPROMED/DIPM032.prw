#INCLUDE "PROTHEUS.CH"
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � DIPM032  �Autor  �Microsiga           � Data �  02/19/13   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function DIPM032() 

If AllTrim(Upper(U_DipUsr()))$GetNewPar("ES_DIPM032","")
	CBMONRF()
Else
	Aviso("Aten��o","Usu�rio sem acesso para executar esta rotina.",{"Ok"},1)
EndIf

Return
#INCLUDE "PROTHEUS.CH"
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �DIPA041() �Autor  �Maximo Canuto-MCVN  � Data � 13/04/2010  ���
�������������������������������������������������������������������������͹��
���Desc.     � Rotina chamada de um botao para impress�o de DANFE no menu ���
�������������������������������������������������������������������������͹��
���Uso       � SIGAFAT - Dipromed                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function DIPA044()
Local lRet := .t.
Local cId_Ent := ''    

//�����������������������������������������������������������������������������������������Ŀ
//�Vari�veis declaradas para evitar erro na impress�o do danfe.                             �
//�������������������������������������������������������������������������������������������
Private aFilBrw     := 	aFilBrw := {'SF2',"F2_FILIAL=='"+xFilial("SF2")+"'"}
Private bFiltraBrw

Do Case
	Case SM0->M0_CGC = '47869078000453'
		cId_Ent := '000001'		
	Case SM0->M0_CGC = '05150878000208'
		cId_Ent := '000002'
	Case SM0->M0_CGC = '47869078000100'
		cId_Ent := '000003'
	Case SM0->M0_CGC = '05150878000127'
		cId_Ent := '000004'	
EndCase

If Empty(cId_Ent)
	Aviso('Aten��o','Empresa n�o tem Nota Eletr�nica emitida.',{'OK'})       
	Return()
Endif
//Chama rotina padr�o de impress�o da DANFE
//U_PRTNFESEF(cId_Ent)
SpedDanfe()

Return
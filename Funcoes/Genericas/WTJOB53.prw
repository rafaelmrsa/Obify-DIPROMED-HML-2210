#INCLUDE "PROTHEUS.CH"
/*
�����������������������������������������������������������������������������
���Programa  � WTJOB53() �Autor �Maximo              � Data �   16/10/2015���
�������������������������������������������������������������������������͹��
���Desc.     �Roda enquanto !KillApp e troca de empresa                   ���
�������������������������������������������������������������������������͹��
���Uso       � Especifico Estoques Dipromed.                              ���
�����������������������������������������������������������������������������
*/     
User Function WTJOB53()                                        

RpcSetEnv("01","01",,,'EST',, )

While !KillApp()   
	U_DIPC53TR()
	If cFilAnt == '01'
		GetEmpr('0104')
	Else               
		GetEmpr('0101')
	Endif	         
	Sleep(30000)
EndDo                       
Return()
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
User Function WTDipTran()                                        

RpcSetEnv("01","01",,,'EST',, )

ConOut( dtoc( Date() )+" "+Time()+" Processando Job Transf...." )   

U_DIPC53TR()	

GetEmpr('0104')

U_DIPC53TR()

Return()
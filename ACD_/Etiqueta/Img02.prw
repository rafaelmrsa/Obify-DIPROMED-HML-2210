/*
Padrao Zebra
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �IMG02     �Autor  �Emerson Leal Bruno  � Data �  07/09/12   ���
�������������������������������������������������������������������������͹��
���Desc.     �Ponto de entrada referente a imagem de identificacao da     ���
���          �endereco, Impressora.		                                  ���
�������������������������������������������������������������������������͹��
���Uso       � AP5                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/         

User Function Img02 // imagem de etiqueta de ENDERECO

Local cCodigo
Local cCodID := paramixb[1]

cCodigo :=SBE->(BE_LOCAL+BE_LOCALIZ)
cCodigo := Alltrim(cCodigo)

MSCBInfoEti("Endereco","Endereco")
MSCBBEGIN(1,4)

	MSCBSAY(03,03,'Endereco:',"N","C","30")
	MSCBSAY(35,03,AllTrim(SBE->BE_LOCALIZ)	, "N", "C", "45")
	MSCBSAY(85,03,AllTrim(SBE->BE_LOCAL)	, "N", "C", "45")	                                                       
	
	MSCBSAYBAR(03,12,cCodigo,'N','C',12,.F.,.F.,.F.,  ,4,3) //'B'

MSCBEND() 
	                                             
Return .F.                                       
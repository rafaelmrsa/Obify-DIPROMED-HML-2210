#include "RwMake.ch"
#include "Protheus.ch"
#include "vKey.ch"     

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � MC090BRW  �Autor  �Giovani           � Data �  09/03/2012  ���
�������������������������������������������������������������������������͹��
���Desc.     � Filtro de consultas de nf-saida						      ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � ESPECIFICO DIPROMED                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
User Function MC090BRW()                            
                           
Local cCodUsr    := alltrim(RetCodUsr())
Local cUser      := GetMv("ES_VENDUSE",,"000053" ) 
If Type("cDipVend") == "U" 
	Public cDipVend := alltrim(Posicione("SU7",4,xFilial("SU7") + RetCodUsr(),"U7_CGC"))
EndIf


                                     
     

If cDipVend $ cUser 
	SF2->(dbSetFilter({|| SF2->F2_VEND1 == cDipVend},"SF2->F2_VEND1 == cDipVend"))
EndIf



Return ()
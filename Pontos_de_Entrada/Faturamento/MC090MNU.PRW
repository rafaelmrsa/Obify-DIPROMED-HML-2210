#include "RwMake.ch"
#include "Protheus.ch"
#include "vKey.ch"     

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �MC090MNU  �Autor  �Maximo	             � Data �  22/04/09   ���
�������������������������������������������������������������������������͹��
���Desc.     � Filtra somente notas fiscais do vendedor especificado      ���
���          � no par�metro cOpFilter                                     ���
�������������������������������������������������������������������������͹��
���Uso       � ESPECIFICO DIPROMED                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
User Function MC090MNU()                            
                           
Local cUser  := GetMv("ES_VENDUSE",,"000053" ) 

If !Empty(Alltrim(cUser))

    If Type("cDipVend") == "U" 
	    Public cDipVend := Alltrim(Posicione("SU7",4,xFilial("SU7") + RetCodUsr(),"U7_CGC"))
    EndIf
                                       
    If cDipVend $ cUser 
	    SF2->(dbSetFilter({|| SF2->F2_VEND1 == cDipVend},"SF2->F2_VEND1 == cDipVend"))
    EndIf

    U_DIPPROC(ProcName(0),U_DipUsr()) // MCVN - 22/01/2009

EndIf

Return ""

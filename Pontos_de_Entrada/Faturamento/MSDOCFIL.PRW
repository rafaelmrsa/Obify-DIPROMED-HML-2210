#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �MSDOCFIL  �Autor  �Microsiga           � Data �  09/03/15   ���
�������������������������������������������������������������������������͹��
���Desc.     � LOCALIZA��O: Function MsDocArray - Fun��o do MsDocument    ���
���			   respons�vel pela montagem do acols com os documentos do    ���
���			   banco de conhecimento.                                     ���
���            No in�cio da fun��o dentro do la�o da tabela AC9.          ���
���             � utilizado para filtrar registros.                        ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function MSDOCFIL()

Local aArea   := GetArea()
Local lRet    := .T.
Local nRecno  := PARAMIXB[1]
Local _cValBc := ""   
      
/*dbSelectArea("SX3")
SX3->(dbSetOrder(2))
�
If SX3->(dbSeek("ACB_CODOBJ")) .And. SX3->X3_VALID != _cValBc
	SX3->(RecLock("SX3",.F.))
	SX3->X3_VALID := _cValBc
	SX3->(MsUnLock())
EndIf*/
�
AC9->(dbGoTo(nRecno))

If "TMKA271" $FUNNAME()
	If !Empty(M->UC_CODIGO)
	
		If AC9->AC9_CODOBJ <> M->UC_CODIGO
			lRet := .F.
		EndIf
		
	EndIf
EndIf

RestArea(aArea)

Return(lRet)   

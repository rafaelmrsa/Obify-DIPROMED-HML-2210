/*
�����������������������������������������������������������������������������
���Programa  � DIPA053()�Autor �MAXIMO CANUTO       � Data �  11/11//2010 ���
�������������������������������������������������������������������������͹��
���Desc. Efetua transfer�ncia autom�tica entre cd's                       ���
�������������������������������������������������������������������������͹��
���Uso       � Especifico Estoques Dipromed.                              ���
��------------------------------------------------------------------------���
���Hist�rico � 				                                              ���
���16/02/11  � Tratamento gravando o Status para inibir transf. simult�nea���
���18/02/11  � Alterado tratamento p/ inibir transf. simult�nea usando    ���
��			 � lockByName e UnLockByName 								  ���
�����������������������������������������������������������������������������           
*/
                                 
#INCLUDE "RWMAKE.CH"

                       
User Function DIPA53ESC()                             

If cEmpAnt <> '01'
	
	MsgBox("Op��o desabilita para esta empresa ","Aten��o","OK")

ElseIf cEmpAnt == "01"

	If cFilAnt == '01'
		If MsgBox("CONFIRMA DIPROMED CD COMO DESTINO? ","Aten��o","YESNO")
			U_DIPA053C()     
		Else
			Return()
		Endif
	ElseIf cFilAnt == '04'
		If MsgBox("CONFIRMA DIPROMED MTZ COMO DESTINO? ","Aten��o","YESNO")
			U_DIPA053C()     
		Else
			Return()
		Endif		
	Endif
	      	                                          
Endif

Return()
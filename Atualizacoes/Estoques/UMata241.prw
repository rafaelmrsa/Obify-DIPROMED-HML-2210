#INCLUDE "PROTHEUS.CH"
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �UMATA241  �Autor  �Microsiga           � Data �  04/04/14   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function UMata241()  
Local l240 	 := (Upper(U_DipUsr())$AllTrim(GetNewPar("ES_MATA240","")))
Local cChave := cFilAnt+"_TRANSF_FILIAIS"                           

If l240
	If cEmpAnt=="04" 
		If LockByName(cChave,.T.,.F.)		
			MATA241()
			UnLockByName(cChave,.T.,.F.)
		Else
			Aviso("Aten��o","Outro processo de movimenta��o de estoque est� impedindo a execu��o desta rotina. Tente novamente mais tarde.",{"Ok"})
		EndIf
	Else
		MATA241()
	EndIf
Else
	Aviso("ES_MATA240","Usu�rio sem autoriza��o para realizar esta opera��o.",{"Ok"},1)
EndIf

Return
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �UMATA241  �Autor  �Microsiga           � Data �  04/04/14   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function UMat241A()  
Local l242 := (Upper(U_DipUsr())$AllTrim(GetNewPar("ES_MATA242","")))
Local cChave := cFilAnt+"_TRANSF_FILIAIS"   

If l242      
	If cEmpAnt=="04" 
		If LockByName(cChave,.T.,.F.)		
			MATA261()
			UnLockByName(cChave,.T.,.F.)
		Else
		 	Aviso("Aten��o","Outro processo de movimenta��o de estoque est� impedindo a execu��o desta rotina. Tente novamente mais tarde.",{"Ok"})
		EndIf        
	Else
		MATA261()
	EndIf
Else
	Aviso("ES_MATA242","Usu�rio sem autoriza��o para realizar esta opera��o.",{"Ok"},1)
EndIf

Return
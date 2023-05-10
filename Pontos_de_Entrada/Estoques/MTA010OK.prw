#Include "Protheus.ch"
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �MTA010OK  �Autor  �Microsiga           � Data �  04/20/10   ���
�������������������������������������������������������������������������͹��
���Desc.     � PE antes da exclus�o. Grava as informa��es do produto para ���
���          � replica��o para outras empresas/filiais                    ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function MTA010OK()
Local lRet := .T.

/*
//-- Copia de PA para Health/Cd e Dipromed
If (Type("l010Auto")=="U" .Or. !l010Auto)// .And. cEmpAnt+cFilAnt == "0401" 

	U_ClrMemSB1() //-- Zera Array com variaveis de mem�ria

	If !Inclui .And. !Altera .And. AllTrim(SB1->B1_TIPO) == "PA" 

		RegToMemory("SB1",.F.) //-- Carrega registro para as vari�veis de mem�ria.
		U_SvMemSB1() //-- Guarda Array com vari�veis de Memoria para uso posterior na gravacao
		
    EndIf
    
EndIf   
*/                               

If !U_DipUsr()$"mcanuto/DDOMINGOS/VQUEIROZ/VEGON/RBORGES" 
	lRet := .F.
EndIf

If cEmpAnt=='04' .And. U_DipUsr()=="csossolote"
	lRet := .T.
EndIf
                                                
If !lRet
	MsgAlert("Exclus�o desabilitada!","Aten��o")
EndIf

//Return .T.
Return lRet
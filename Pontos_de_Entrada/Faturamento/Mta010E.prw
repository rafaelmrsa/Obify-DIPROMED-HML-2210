/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �MTA010E   �Autor  �Microsiga           � Data �  01/30/08   ���
�������������������������������������������������������������������������͹��
���Desc.     � PE chamado na exclusao de Produto, para gerar kardex da    ���
���          � Exclusao do Produto                                        ���
�������������������������������������������������������������������������͹��
���Uso       � DIPROMED                                                   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
User Function Mta010E()
U_DIPPROC(ProcName(0),U_DipUsr()) //MCVN - 22/01/2009
U_GravaZG("SB1")

//-- Verifica replica��o do cadastro
/*
If (Type("l010Auto")=="U".Or.!l010Auto) 
	If cEmpAnt+cFilAnt == "0401" 
	  	U_CpySB1("01","01",.T.) //-- Copia para Dipromed/MTZ
	  	U_CpySB1("01","04",.T.) //-- Copia para Dipromed/CD
	ElseIf cEmpAnt+cFilAnt == "0101" 
	  	U_CpySB1("01","04",.T.) //-- Copia para Dipromed/CD
	ElseIf cEmpAnt+cFilAnt == "0104" 
	  	U_CpySB1("01","01",.T.) //-- Copia para Dipromed/MTZ
	EndIf
EndIf
*/
Return .T.
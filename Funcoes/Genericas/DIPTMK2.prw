#INCLUDE "RWMAKE.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �DIPTMK2  �Autor  �Natalia             � Data �  27/09/05   ���
�������������������������������������������������������������������������͹��
���Desc.     �Funcao  chamada atrav�s do inicializador padr�o e browse 	  ���
���          �do campo U5_NOMCLI do cadastro de contatos a fim de 		  ���
���			 �visualizar o cliente relacionado ao contato				  ���
�������������������������������������������������������������������������͹��
�������������������������������������������������������������������������͹��
���Uso       � dipromed														  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function DIPTMK2()
 
Local _aArea := GetArea()  // Salva area corrente
//Local _contat := "" 
//Local _cCodCon := ""  
Local _cCodEnt                        
Local _cliente                          
Local _cCodCon := SU5->U5_CODCONT   
Local _cretorno:=" "

U_DIPPROC(ProcName(0),U_DipUsr()) // MCVN - 22/01/2009

dbSelectArea("AC8")
dbSetOrder(1)
if DbSeek(xFilial("AC8")+ Substr(_cCodCon,1,6)) 
  	_cCodEnt := AC8->AC8_CODENT
	//Posicione("SA1",1, xFilial("SA1")+_cCodcon, "U1_NOME")   
	_cliente := GetAdvFval("SA1","A1_NOME",xFilial("SA1")+_cCodEnt,1)
	_cretorno:= substr(_cCodEnt,1,6) +" - "+alltrim(_cliente) 
endif
RestArea(_aArea)
 
Return (_cretorno)



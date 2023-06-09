#include "RwMake.ch"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �DIPG002   �Autor  �   Alexandro Dias   � Data �  28/12/01   ���
�������������������������������������������������������������������������͹��
���Desc.     � Atualiza campo com o destino do frete.                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function DIPG002()

Local _xAlias    := {Alias(), IndexOrd(), Recno() }
Local _cRet      := ""
U_DIPPROC(ProcName(0),U_DipUsr()) // JBS 05/10/2005 - Gravando o nome do Programa no SZU
DbSelectArea("SZ3")
DbSetorder(2)

IF !Empty(SA1->A1_ESTE)

        IF DbSeek(xFilial("SZ3")+IIF("TMK"$FunName(),M->UA_TRANSP,M->C5_TRANSP)+SA1->A1_ESTE+Alltrim(SA1->A1_MUNE),.T.)
		MsgBox("Verifique se o Destino do Frete esta Correto !!!","Atencao","ALERT")	
		_cRet := SZ3->Z3_EST+"-"+Alltrim(SZ3->Z3_CAP_MUN)
	Else
                IF DbSeek(xFilial("SZ3")+IIF("TMK"$FunName(),M->UA_TRANSP,M->C5_TRANSP)+SA1->A1_EST+Alltrim(SA1->A1_MUN),.T.)
			MsgBox("Verifique se o Destino do Frete esta Correto !!!","Atencao","ALERT")	
			_cRet := SZ3->Z3_EST+"-"+Alltrim(SZ3->Z3_CAP_MUN)
		Else
			_cMsg := "O Destino do Frete nao foi localizado, "+Chr(13)
			_cMsg := _cMsg + "verifique o cadastro do Cliente !!!" 
			MsgBox(_cMsg,"Atencao","ALERT")	
		EndIF
	EndIF

Else

        IF DbSeek(xFilial("SZ3")+IIF("TMK"$FunName(),M->UA_TRANSP,M->C5_TRANSP)+SA1->A1_EST+Alltrim(SA1->A1_MUN))
		_cRet := SZ3->Z3_EST+"-"+Alltrim(SZ3->Z3_CAP_MUN)
	Else
		_cMsg := "O Destino do Frete nao foi localizado, "+Chr(13)
		_cMsg := _cMsg + "verifique o cadastro do Cliente !!!" 
		MsgBox(_cMsg,"Atencao","ALERT")	
	EndIF

EndIF

DbSelectArea(_xAlias[1])
DbSetOrder(_xAlias[2])
DbGoto(_xAlias[3])

Return(_cRet)

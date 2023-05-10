#INCLUDE "PROTHEUS.CH"
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �CBINV03   �Autor  �Microsiga           � Data �  04/22/14   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function CBINV03()   

VTSetKey(101,{|| u_DipEndUsr()},"Endere�os")

Return
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �CBINV03   �Autor  �Microsiga           � Data �  04/24/14   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function DipEndUsr()
Local cSQL 	  := ""
Local aDipEnd := {}

CB1->(dbSetOrder(2))
If CB1->(dbSeek(xFilial("CB1")+RetCodUsr()))
	cSQL := " SELECT "
	cSQL += " 	CBA_LOCALI, CBA_XCONT1 "
	cSQL += " 	FROM "
	cSQL +=			RetSQLName("CBA")
	cSQL += " 		WHERE 
	cSQL += " 			CBA_FILIAL = '"+xFilial("CBA")+"' AND
	cSQL += " 			CBA_DATA   = '"+DtoS(dDataBase)+"' AND
	cSQL += " 		   ((CBA_XCONT1 = '"+CB1->CB1_CODOPE+"' AND CBA_CONTR = 0) OR
	cSQL += " 			(CBA_XCONT2 = '"+CB1->CB1_CODOPE+"' AND CBA_CONTR = 1)) AND
	cSQL += " 			D_E_L_E_T_ = ' '         
	cSQL += " ORDER BY CBA_LOCALI "

	cSQL := ChangeQuery(cSQL)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),"QRYUSU",.T.,.T.)
	
	If !QRYUSU->(Eof())
		QRYUSU->(dbEval({|| aAdd(aDipEnd, {QRYUSU->CBA_LOCALI,IIf(QRYUSU->CBA_XCONT1==CB1->CB1_CODOPE,"PRIMEIRA","SEGUNDA")})}))
	EndIf
	QRYUSU->(dbCloseArea())

	aTela := VtSave()
	VTClear()
	nPos :=VTaBrowse(0,0,7,19,{"Endere�o","Contagem"},aDipEnd,{08,08}) //"Mestre"###"Data"###"Status"
	VtRestore(,,,,aTela)	
EndIf 

Return
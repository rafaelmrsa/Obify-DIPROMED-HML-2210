#INCLUDE "PROTHEUS.CH"

  

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �TK271ABR  �Autor  �Reginaldo Borges    � Data �  09/11/12   ���
�������������������������������������������������������������������������͹��
���Desc.     � Ponto de entrada criado para autorizar os usuarios que     ���
���          �poderam alterar os atendimentos de acordo com o paramentro  ���
���			 | e o status.                                                ���
�������������������������������������������������������������������������͹��
���Uso       � TMK_SAC                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/



User Function TK271ABR()
           



Local _lRet        := .T. 
Local _cUsrSAC1    :=  GetNewPar("ES_SAC_SC" ,"RBORGES")
Local _cUsrSAC2    :=  GetNewPar("ES_SAC_DIR","RBORGES")
Local _cUsrSAC3    :=  GetNewPar("ES_SAC_ENC","RBORGES")
Local _cUsrSAC6    :=  GetNewPar("ES_SAC_TRP","RBORGES")
Local _cUsrSAC7    :=  GetNewPar("ES_SAC_FIS","RBORGES")
Local _cUsrSAC8    :=  GetNewPar("ES_SAC_FIN","RBORGES")
Local _cUsrSAC9    :=  GetNewPar("ES_SAC_QUA","RBORGES")
Local _cUsrSAC10   :=  GetNewPar("ES_SAC_EFI","RBORGES")
Local _cUsrSAC11   :=  GetNewPar("ES_SAC_EST","RBORGES")
Local _cUsrSAC12   :=  GetNewPar("ES_SAC_FOR","RBORGES")
Local _cUsrSAC13   :=  GetNewPar("ES_SAC_CLI","RBORGES")
Local _cUsrSAC14   :=  GetNewPar("ES_SAC_VEN","RBORGES")  
Local _cUsrSAC15   :=  GetNewPar("ES_SAC_REC","RBORGES")  
Local _cUsrSAC16   :=  GetNewPar("ES_SAC_EXP","RBORGES")  
Local _cUsrSAC17   :=  GetNewPar("ES_SAC_COM","RBORGES")  
Local _cUsrSAC18   :=  GetNewPar("ES_SAC_TI","RBORGES")  


Local aArea        := SUC->(GetArea())                                          


U_DIPPROC(ProcName(0),U_DipUsr()) // Gravando o nome do Programa no SZU

If Paramixb[1] == 4
	
		
	IF !UPPER(U_DipUsr()) $ _cUsrSAC1 .AND. (ALLTRIM(SUC->UC_STATUS)) == '1'
		_lRET := .F.
		
		MsgInfo("Altera��o permitida somente para o SAC.!","ATEN��O")
				
	ELSEIF !UPPER(U_DipUsr()) $ _cUsrSAC2 .AND. (ALLTRIM(SUC->UC_STATUS)) == '2'
		_lRET := .F.
		
		MsgInfo("Altera��o permitida somente para SAC e a Diretoria!","ATEN��O")
		
	ELSEIF !UPPER(U_DipUsr()) $ _cUsrSAC3 .AND. (ALLTRIM(SUC->UC_STATUS)) == '3'
		_lRET := .F.
		
		MsgInfo("Altera��o permitida somente para o SAC!","ATEN��O")
				
	ELSEIF !UPPER(U_DipUsr()) $ _cUsrSAC6 .AND. (ALLTRIM(SUC->UC_STATUS)) == '6'
		_lRET := .F.
		
		MsgInfo("Altera��o permitida somente para o SAC e Transporte!","ATEN��O")
				
	ELSEIF !UPPER(U_DipUsr()) $ _cUsrSAC7 .AND. (ALLTRIM(SUC->UC_STATUS)) == '7'
		_lRET := .F.
		
		MsgInfo("Altera��o permitida somente para o SAC e o Fiscal!","ATEN��O")
				
	ELSEIF !UPPER(U_DipUsr()) $ _cUsrSAC8 .AND. (ALLTRIM(SUC->UC_STATUS)) == '8'
		_lRET := .F.
		
		MsgInfo("Altera��o permitida somente para o SAC e o Financeiro!","ATEN��O")
				
	ELSEIF !UPPER(U_DipUsr()) $ _cUsrSAC9 .AND. (ALLTRIM(SUC->UC_STATUS)) == '9'
		_lRET := .F.
		
		MsgInfo("Altera��o permitida somente para o SAC e a Qualidade!","ATEN��O")
				
	ELSEIF !UPPER(U_DipUsr()) $ _cUsrSAC10 .AND. (ALLTRIM(SUC->UC_STATUS)) == '10'
		_lRET := .F.
		
		MsgInfo("Altera��o permitida somente para o SAC e a Escrita Fiscal!","ATEN��O")
				
	ELSEIF !UPPER(U_DipUsr()) $ _cUsrSAC11 .AND. (ALLTRIM(SUC->UC_STATUS)) == '11'
		_lRET := .F.
		
		MsgInfo("Altera��o permitida somente para o SAC e o Estoque!","ATEN��O")
				
	ELSEIF !UPPER(U_DipUsr()) $ _cUsrSAC12 .AND. (ALLTRIM(SUC->UC_STATUS)) == '12'
		_lRET := .F.
		
		MsgInfo("Altera��o permitida somente para o SAC!","ATEN��O")
				
	ELSEIF !UPPER(U_DipUsr()) $ _cUsrSAC13 .AND. (ALLTRIM(SUC->UC_STATUS)) == '13'
		_lRET := .F.
		
		MsgInfo("Altera��o permitida somente para o SAC!","ATEN��O")
	ELSEIF !UPPER(U_DipUsr()) $ _cUsrSAC14 .AND. (ALLTRIM(SUC->UC_STATUS)) == '14'
		_lRET := .F.
		
		MsgInfo("Altera��o permitida somente para o SAC e Vendas!","ATEN��O")	 
			 
	ELSEIF !UPPER(U_DipUsr()) $ _cUsrSAC15 .AND. (ALLTRIM(SUC->UC_STATUS)) == '15'
		_lRET := .F.
		
		MsgInfo("Altera��o permitida somente para o SAC e Recebimento!","ATEN��O")		

	ELSEIF !UPPER(U_DipUsr()) $ _cUsrSAC16 .AND. (ALLTRIM(SUC->UC_STATUS)) == '16'
		_lRET := .F.
		
		MsgInfo("Altera��o permitida somente para o SAC e Expedicao!","ATEN��O")		
	ELSEIF !UPPER(U_DipUsr()) $ _cUsrSAC17 .AND. (ALLTRIM(SUC->UC_STATUS)) == '17'
		_lRET := .F.
		
		MsgInfo("Altera��o permitida somente para o SAC e Compras!","ATEN��O")				
	ELSEIF !UPPER(U_DipUsr()) $ _cUsrSAC18 .AND. (ALLTRIM(SUC->UC_STATUS)) == '18'
		_lRET := .F.
		
		MsgInfo("Altera��o permitida somente para o SAC e TI!","ATEN��O")		
	ENDIF
	
ENDIF  


RestArea(aArea)  

   
RETURN (_lRET)

      
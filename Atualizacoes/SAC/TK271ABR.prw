#INCLUDE "PROTHEUS.CH"

  

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TK271ABR  ºAutor  ³Reginaldo Borges    º Data ³  09/11/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Ponto de entrada criado para autorizar os usuarios que     º±±
±±º          ³poderam alterar os atendimentos de acordo com o paramentro  º±±
±±º			 | e o status.                                                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ TMK_SAC                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
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
		
		MsgInfo("Alteração permitida somente para o SAC.!","ATENÇÃO")
				
	ELSEIF !UPPER(U_DipUsr()) $ _cUsrSAC2 .AND. (ALLTRIM(SUC->UC_STATUS)) == '2'
		_lRET := .F.
		
		MsgInfo("Alteração permitida somente para SAC e a Diretoria!","ATENÇÃO")
		
	ELSEIF !UPPER(U_DipUsr()) $ _cUsrSAC3 .AND. (ALLTRIM(SUC->UC_STATUS)) == '3'
		_lRET := .F.
		
		MsgInfo("Alteração permitida somente para o SAC!","ATENÇÃO")
				
	ELSEIF !UPPER(U_DipUsr()) $ _cUsrSAC6 .AND. (ALLTRIM(SUC->UC_STATUS)) == '6'
		_lRET := .F.
		
		MsgInfo("Alteração permitida somente para o SAC e Transporte!","ATENÇÃO")
				
	ELSEIF !UPPER(U_DipUsr()) $ _cUsrSAC7 .AND. (ALLTRIM(SUC->UC_STATUS)) == '7'
		_lRET := .F.
		
		MsgInfo("Alteração permitida somente para o SAC e o Fiscal!","ATENÇÃO")
				
	ELSEIF !UPPER(U_DipUsr()) $ _cUsrSAC8 .AND. (ALLTRIM(SUC->UC_STATUS)) == '8'
		_lRET := .F.
		
		MsgInfo("Alteração permitida somente para o SAC e o Financeiro!","ATENÇÃO")
				
	ELSEIF !UPPER(U_DipUsr()) $ _cUsrSAC9 .AND. (ALLTRIM(SUC->UC_STATUS)) == '9'
		_lRET := .F.
		
		MsgInfo("Alteração permitida somente para o SAC e a Qualidade!","ATENÇÃO")
				
	ELSEIF !UPPER(U_DipUsr()) $ _cUsrSAC10 .AND. (ALLTRIM(SUC->UC_STATUS)) == '10'
		_lRET := .F.
		
		MsgInfo("Alteração permitida somente para o SAC e a Escrita Fiscal!","ATENÇÃO")
				
	ELSEIF !UPPER(U_DipUsr()) $ _cUsrSAC11 .AND. (ALLTRIM(SUC->UC_STATUS)) == '11'
		_lRET := .F.
		
		MsgInfo("Alteração permitida somente para o SAC e o Estoque!","ATENÇÃO")
				
	ELSEIF !UPPER(U_DipUsr()) $ _cUsrSAC12 .AND. (ALLTRIM(SUC->UC_STATUS)) == '12'
		_lRET := .F.
		
		MsgInfo("Alteração permitida somente para o SAC!","ATENÇÃO")
				
	ELSEIF !UPPER(U_DipUsr()) $ _cUsrSAC13 .AND. (ALLTRIM(SUC->UC_STATUS)) == '13'
		_lRET := .F.
		
		MsgInfo("Alteração permitida somente para o SAC!","ATENÇÃO")
	ELSEIF !UPPER(U_DipUsr()) $ _cUsrSAC14 .AND. (ALLTRIM(SUC->UC_STATUS)) == '14'
		_lRET := .F.
		
		MsgInfo("Alteração permitida somente para o SAC e Vendas!","ATENÇÃO")	 
			 
	ELSEIF !UPPER(U_DipUsr()) $ _cUsrSAC15 .AND. (ALLTRIM(SUC->UC_STATUS)) == '15'
		_lRET := .F.
		
		MsgInfo("Alteração permitida somente para o SAC e Recebimento!","ATENÇÃO")		

	ELSEIF !UPPER(U_DipUsr()) $ _cUsrSAC16 .AND. (ALLTRIM(SUC->UC_STATUS)) == '16'
		_lRET := .F.
		
		MsgInfo("Alteração permitida somente para o SAC e Expedicao!","ATENÇÃO")		
	ELSEIF !UPPER(U_DipUsr()) $ _cUsrSAC17 .AND. (ALLTRIM(SUC->UC_STATUS)) == '17'
		_lRET := .F.
		
		MsgInfo("Alteração permitida somente para o SAC e Compras!","ATENÇÃO")				
	ELSEIF !UPPER(U_DipUsr()) $ _cUsrSAC18 .AND. (ALLTRIM(SUC->UC_STATUS)) == '18'
		_lRET := .F.
		
		MsgInfo("Alteração permitida somente para o SAC e TI!","ATENÇÃO")		
	ENDIF
	
ENDIF  


RestArea(aArea)  

   
RETURN (_lRET)

      
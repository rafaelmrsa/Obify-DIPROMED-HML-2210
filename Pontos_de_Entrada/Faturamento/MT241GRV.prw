/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �MT241GRV()� Autor �Jailton B Santos-JBS   � Data �20/08/2010���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Chamada na requisicao de movimento interno, gravacao.      ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � Nennhum retorno aguardado pelo padrao                      ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Usado para para gravar o numero de serie das notas apos a  ���
���          � gravacao do SD3.                                           ���
�������������������������������������������������������������������������Ĵ��
���Uso       � Especifico Faturamento Dipromed - DIPA046                  ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
���Programador � Data   �  Motivo da Alteracao                            ���
�������������������������������������������������������������������������Ĵ��
���            �        �                                                 ���
���            �        �                                                 ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
#INCLUDE "PROTHEUS.CH"

User Function MT241GRV() 
             
If Type("l241Auto") = "U" .or. l241Auto
	Return(Nil)
EndIf

If fQuerySD3()
    
    DIPA046TRB->( DbGoTop())
    
    Do While DIPA046TRB->(!EOF()) 
    
        SD3->( DbGoTo(DIPA046TRB->R_E_C_N_O_) )
    
        SD3->( RecLock('SD3',.F.) )
        SD3->D3_IDENT :=  SZL->ZL_SERIE 
        SD3->D3_EXPLIC:= SubStr(SD3->D3_EXPLIC,13)
        SD3->( MsUnlock('SD3') )
    
        DIPA046TRB->( DbSkip())
        
    EndDo
EndIf


DIPA046TRB->(DbCloseArea())

If fQuerySD5()
    
    DIPA046TRB->( DbGoTop())
    
    Do While DIPA046TRB->(!EOF()) 
    
        SD5->( DbGoTo(DIPA046TRB->R_E_C_N_O_) )
    
        SD5->( RecLock('SD5',.F.) )
        SD5->D5_SERIE :=  SZL->ZL_SERIE 
        SD5->( MsUnlock('SD5') )
    
        DIPA046TRB->( DbSkip())
        
    EndDo
EndIf
DIPA046TRB->(DbCloseArea())
If fQuerySDB()
    
    DIPA046TRB->( DbGoTop())
    
    Do While DIPA046TRB->(!EOF()) 
    
        SDB->( DbGoTo(DIPA046TRB->R_E_C_N_O_) )
    
        SDB->( RecLock('SDB',.F.) )
        SDB->DB_SERIE :=  SZL->ZL_SERIE 
        SDB->( MsUnlock('SDB') )
    
        DIPA046TRB->( DbSkip())
        
    EndDo
EndIf
DIPA046TRB->(DbCloseArea())

Return(Nil)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �fQuerySD3()�Autor �Jailton B Santos-JBS� Data � 20/08/2010  ���
�������������������������������������������������������������������������͹��
���Desc.     � Busca todos os registros gerados no SD3 para gravar a serie���
�������������������������������������������������������������������������͹��
���Uso       � Especifico Estoque Dipromed                                ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function fQuerySD3()

If Select("DIPA046TRB") > 0
   DIPA046TRB->(DbCloseArea())
EndIf
   
BeginSql Alias "DIPA046TRB"
	
    Select R_E_C_N_O_ 
      from %Table:SD3% SD3
     Where D3_FILIAL = %xFilial:SD3% 
       and LEFT(D3_EXPLIC,12) = %EXP:SZL->ZL_NOTA+SZL->ZL_SERIE%
       and SD3.%notdel%
     Order By R_E_C_N_O_	

EndSql         

Return(!DIPA046TRB->( EOF().and.BOF()))
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �fQuerySD5()�Autor �Jailton B Santos-JBS� Data � 20/08/2010  ���
�������������������������������������������������������������������������͹��
���Desc.     � Busca os registro gerados no SD5  para esta movimentacao e ���
���          � grava o numero de serie                                    ���
�������������������������������������������������������������������������͹��
���Uso       � Especifico Estoque Dipromed                                ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function fQuerySD5()

If Select("DIPA046TRB") > 0
   DIPA046TRB->(DbCloseArea())
EndIf
   
BeginSql Alias "DIPA046TRB"
	
    Select R_E_C_N_O_ 
      from %Table:SD5% SD5
     Where D5_FILIAL = %xFilial:SD5%  
       and D5_DOC    = %EXP:SZL->ZL_NOTA%
       and D5_SERIE  = %EXP:''%
       and D5_DATA   = %EXP:dDataBase% 
       and SD5.%notdel%
     Order By R_E_C_N_O_	

EndSql         

Return(!DIPA046TRB->( EOF().and.BOF()))  
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �fQuerySDB()�Autor �Jailton B Santos-JBS� Data � 20/08/2010  ���
�������������������������������������������������������������������������͹��
���Desc.     � Busca todos os registros gerados no SD3 para gravar a serie���
�������������������������������������������������������������������������͹��
���Uso       � Especifico Estoque Dipromed                                ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function fQuerySDB()

If Select("DIPA046TRB") > 0
   DIPA046TRB->(DbCloseArea())
EndIf
   
BeginSql Alias "DIPA046TRB"
	
    Select R_E_C_N_O_ 
      from %Table:SDB% SDB
     Where DB_FILIAL = %xFilial:SDB%  
       and DB_DOC    = %EXP:SZL->ZL_NOTA%
       and DB_SERIE  = %EXP:''%
       and DB_DATA   = %EXP:dDataBase% 
       and DB_ORIGEM = %EXP:'SD3'%
       and SDB.%notdel%
     Order By R_E_C_N_O_	

EndSql         

Return(!DIPA046TRB->( EOF().and.BOF()))
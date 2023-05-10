/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �MA920BUT()� Autor �Jailton B Santos-JBS   � Data �17/08/2010���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Ponto de entrada na consulta de notas fiscaisa, chamdo an- ���
���          � tes de mostrar os dados do NF na tela.                     ���
�������������������������������������������������������������������������Ĵ��
���Funcao    � Na Consulta de nota fiscal, informa ao usuario se esta NF  ���
���          � esta em processo de cancelamento e respectiva situacao.    ���
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

User Function MA920BUT()

Local cMsg  := ""        // JBS 13/08/2010
Local lRet  := .T.       //
Local aArea := GetArea() //

Private aStatus := {'Aguardando Avalia��o','Aguardando Financeiro','Aprovado o Cancelamento','Cancelada','Reprovado Diretor','Aguardando Nova Avaliacao','Foi devolvida e Gerado N.F.E.'}

Begin Sequence

    If Type("lDipa046Dv") <> "U" .and. lDipa046Dv
	    Return(Nil)  // chamado do DIPA046
    EndIf

    SZL->( DbSetOrder(1) )

    If SZL->(!DbSeek(xFilial('SZL') + SF2->F2_DOC + SF2->F2_SERIE))
        Break
    EndIf
   
    If SZL->ZL_STATUS == '7'.and. fQuery() 
        cMsg +=  'Esta nota fiscal foi devolvida em : '       + Dtoc(DIPA046TRB->D1_DTDIGIT)            + chr(13) + chr(10)  
        cMsg +=  'Foi gerada a nota fiscal de Devolu��o :'    + AllTrim(DIPA046TRB->D1_DOC) +'/'+AllTrim(DIPA046TRB->D1_SERIE)+ chr(13)+chr(10)  
        cMsg +=  'Processo de Cancelamento : '                + AllTrim(SZL->ZL_CODIGO)                 + chr(13) + chr(10) 
        cMsg +=  'Data/Hora de Solicitacao de Cancelamento : '+ Dtoc(SZL->ZL_DATA)+' / '+SZL->ZL_HORA   + chr(13) + chr(10) 
        cMsg +=  'Pelo usuario : '                            + AllTrim(SZL->ZL_USERNAM)                 + chr(13) + chr(10) 
        cMsg +=  'Do Setor de : '                             + Alltrim(SZL->ZL_SETOR)                   + chr(13) + chr(10)  
        cMsg +=  'Motivo da Devolucao : '                     + AllTrim(SZL->ZL_MOTIVO)                  + chr(13)+chr(10) 
    Else    
        cMsg  := 'Esta nota fiscal esta em processo de cancelamento.  ' + aStatus[val(SZL->ZL_STATUS)] + '!'
    EndIf

    If Select("DIPA046TRB") > 0
       DIPA046TRB->( DbCloseArea() )
    EndIf   

    Aviso('Aten��o',cMsg,{'OK'})

End Sequence
RestArea(aArea)
Return(NIL)    

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �fQuery()   �Autor �Jailton B Santos-JBS� Data � 20/08/2010  ���
�������������������������������������������������������������������������͹��
���Desc.     � A Nota Fiscal de Entreda gerada para devolucao da N.F.S.   ���
�������������������������������������������������������������������������͹��
���Uso       � Especifico Estoque Dipromed                                ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function fQuery()

If Select("DIPA046TRB") > 0
   DIPA046TRB->( DbCloseArea() )
EndIf
   
BeginSql Alias "DIPA046TRB"

	COLUMN D1_DTDIGIT AS DATE

    Select Top 1 D1_DOC,D1_SERIE,D1_DTDIGIT 
      from %Table:SD1% SD1 
     where D1_FILIAL  = %xFilial:SD1% 
       and D1_NFORI   = %EXP:SZL->ZL_NOTA% 
       and D1_SERIORI = %EXP:SZL->ZL_SERIE% 
       and SD1.%notdel%

EndSql         

Return(!DIPA046TRB->( EOF().and.BOF()))
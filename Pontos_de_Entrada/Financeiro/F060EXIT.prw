/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �F060EXIT() � Autor �Jailton B Santos-JBS  � Data �24/05/2010���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Ponto de entra chamada na transferencia de titulos.        ���
�������������������������������������������������������������������������Ĵ��
���Funcao    � Se a nota fiscal do titulo estiver em processo de exclusao,���
���          � libera a nota para exclusao e envia e-mail para o usuario  ���
���          � que fez a solicitacao de exclusao.                         ���
���          � Este tratamento serah realizado pelo funcao de usuario:    ���
���          � U_DIPA046('SZL',SZL->(Recno()), 10)                        ���
���          � Todo o processamento ficou concentrado no programa DIA046. ���
���          � A param 10 determina o que serah executado.                ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � Nenhum retorno eh aguardado pelo padrao do Protheus.       ���
�������������������������������������������������������������������������Ĵ��
���Uso       � Especifico Faturamento Dipromed.                           ���
�������������������������������������������������������������������������Ĵ��
���         Atualizacoes Sofridas Desde a Constru�ao Inicial.             ���
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

User Function F060EXIT()

Local lRet := .T. 

/*SZL->( DbSetOrder(1) )
If SZL->( DbSeek(xFilial('SZL')+SE1->E1_NUM + SE1->E1_PREFIXO )) 
    If SZL->ZL_STATUS == '2' .and. Empty(SE1->E1_NUMBCO) .and. SE1->E1_SITUACA = '0' // Aguardando Financeiro
        SZL->(U_DIPA046MA('SZL',SZL->(Recno()),10))
    EndIf
EndIf */

Return(lRet)

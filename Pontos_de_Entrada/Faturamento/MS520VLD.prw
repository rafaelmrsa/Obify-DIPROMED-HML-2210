/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �MS520VLD()� Autor �Jailton B Santos-JBS   � Data �24/05/2010���
�������������������������������������������������������������������������Ĵ��
���Descri��o � So pode liber a exclus�o de uma nota fiscal se a mesma es- ���
���          � tiver liberada pra tal no processo de exclusao.            ���
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

User Function MS520VLD()

Local lRet        := .T.
Local aArea       := GetArea()
Local cExSCNf     := GetNewPar("ES_EX_SCNF","")
Local nHoras      := 0                              
Local lMesFechado := .F.
Local nSpedExc    := GetNewPar("MV_SPEDEXC",72) 
Local lAchou      := .F.
Local cMsg        := ''


//Andre Mendes - Obify - 11/11/2021 - Permitir o cancelamento pela rotina padr�o
/*If !("TMSA200" $ FUNNAME()) .and. !("MATA521A" $ FUNNAME()) // N�o entra se a rotina for chamada pelo TMS  - MCVN 31/08/10
	Private aStatus := {'Aguardando Avalia��o','Aguardando Financeiro','Aprovado o Cancelamento','Cancelada','Reprovado Diretor','Aguardando Nova Avaliacao','Feito Nota de Devolu��o'}

	Begin Sequence

	SZL->( DbSetOrder(1) )

	If SZL->(!DbSeek(xFilial('SZL') + SF2->F2_DOC + SF2->F2_SERIE))
		aviso('Aten��o','Nota Fiscal n�o pode ser cancelada. N�o foi solicitado o cancelamento desta nota fiscal.',{'Ok'})
		lRet := .F.
		break
	EndIf

	If SZL->ZL_STATUS <> '3'
		Aviso('Aten��o','Nota fiscal n�o pode ser cancelada. Nota fiscal ' + aStatus[val(SZL->ZL_STATUS)] + '!',{'OK'})
		lRet := .F.
		break
	EndIf

	End Sequence
EndIf*/




If ("MATA521A" $ FUNNAME()) // Entra se for exclus�o manual

	lRet := Upper(U_DipUsr()) $ Upper((AllTrim(cExSCNf))) 

	If !lRet 
			Aviso('Aten��o','Usu�rio sem autoriza��o para excluir documento de sa�da.' +cExSCNf+ '!',{'OK'})
	Else
		nHoras := nSpedExc - SubtHoras( SF2->F2_EMISSAO, SF2->F2_HORA, dDataBase, substr(Time(),1,2)+":"+substr(Time(),4,2) )
		lMesFechado := If(AnoMes((FirstDay(dDataBase))-1)=AnoMes(GetNewPar("MV_ULMES",cToD(""))) .And. AnoMes(SF2->F2_EMISSAO) <> AnoMes(dDataBase),.T.,.F.)

		SE1->( DbSetOrder(1) ) 
		SE1->( DbGotop() )
	   
		lAchou := SE1->(DbSeek(xFilial('SE1') + SF2->F2_PREFIXO + SF2->F2_DUPL)) //.or.SE1->( DbSeek(xFilial('SE1') + SZL->ZL_SERIE + SZL->ZL_NOTA+' ') )
		
	    Iif(nHoras <= 0                           					 ,cMsg += 'Prazo de Cancelamento dado pelo SEFAZ est� EXPIRADO. ',)
   	    Iif(lMesFechado                      					     ,cMsg += 'M�s de refer�ncia da NF foi fechado. (MV_ULMES). ',)
	   	IIf(nHoras <= 0 .OR. lMesFechado  ,cMsg += 'N�o poder� ser cancelada. ' + CHR(13) + CHR(10),)

		If (nHoras <= 0 .OR.  lMesFechado) 
			Aviso('Aten��o',cMsg,{'OK'})
			lRet := .F.
		Endif

		If ! U_NaoGeraCte(SF2->F2_FILIAL,SF2->F2_DOC,SF2->F2_SERIE,SF2->F2_CLIENTE,SF2->F2_LOJA)
			Aviso('Aten��o','Nota Fiscal j� tem CTe gerado, n�o pode ser cancelada.',{'Ok'})
			lRet := .F.

		EndIf

	Endif

Endif

RestArea(aArea)
Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³MS520VLD()³ Autor ³Jailton B Santos-JBS   ³ Data ³24/05/2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ So pode liber a exclusão de uma nota fiscal se a mesma es- ³±±
±±³          ³ tiver liberada pra tal no processo de exclusao.            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Especifico Faturamento Dipromed - DIPA046                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³  Motivo da Alteracao                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³        ³                                                 ³±±
±±³            ³        ³                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
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


//Andre Mendes - Obify - 11/11/2021 - Permitir o cancelamento pela rotina padrão
/*If !("TMSA200" $ FUNNAME()) .and. !("MATA521A" $ FUNNAME()) // Não entra se a rotina for chamada pelo TMS  - MCVN 31/08/10
	Private aStatus := {'Aguardando Avaliação','Aguardando Financeiro','Aprovado o Cancelamento','Cancelada','Reprovado Diretor','Aguardando Nova Avaliacao','Feito Nota de Devolução'}

	Begin Sequence

	SZL->( DbSetOrder(1) )

	If SZL->(!DbSeek(xFilial('SZL') + SF2->F2_DOC + SF2->F2_SERIE))
		aviso('Atenção','Nota Fiscal não pode ser cancelada. Não foi solicitado o cancelamento desta nota fiscal.',{'Ok'})
		lRet := .F.
		break
	EndIf

	If SZL->ZL_STATUS <> '3'
		Aviso('Atenção','Nota fiscal não pode ser cancelada. Nota fiscal ' + aStatus[val(SZL->ZL_STATUS)] + '!',{'OK'})
		lRet := .F.
		break
	EndIf

	End Sequence
EndIf*/




If ("MATA521A" $ FUNNAME()) // Entra se for exclusão manual

	lRet := Upper(U_DipUsr()) $ Upper((AllTrim(cExSCNf))) 

	If !lRet 
			Aviso('Atenção','Usuário sem autorização para excluir documento de saída.' +cExSCNf+ '!',{'OK'})
	Else
		nHoras := nSpedExc - SubtHoras( SF2->F2_EMISSAO, SF2->F2_HORA, dDataBase, substr(Time(),1,2)+":"+substr(Time(),4,2) )
		lMesFechado := If(AnoMes((FirstDay(dDataBase))-1)=AnoMes(GetNewPar("MV_ULMES",cToD(""))) .And. AnoMes(SF2->F2_EMISSAO) <> AnoMes(dDataBase),.T.,.F.)

		SE1->( DbSetOrder(1) ) 
		SE1->( DbGotop() )
	   
		lAchou := SE1->(DbSeek(xFilial('SE1') + SF2->F2_PREFIXO + SF2->F2_DUPL)) //.or.SE1->( DbSeek(xFilial('SE1') + SZL->ZL_SERIE + SZL->ZL_NOTA+' ') )
		
	    Iif(nHoras <= 0                           					 ,cMsg += 'Prazo de Cancelamento dado pelo SEFAZ está EXPIRADO. ',)
   	    Iif(lMesFechado                      					     ,cMsg += 'Mês de referência da NF foi fechado. (MV_ULMES). ',)
	   	IIf(nHoras <= 0 .OR. lMesFechado  ,cMsg += 'Não poderá ser cancelada. ' + CHR(13) + CHR(10),)

		If (nHoras <= 0 .OR.  lMesFechado) 
			Aviso('Atenção',cMsg,{'OK'})
			lRet := .F.
		Endif

		If ! U_NaoGeraCte(SF2->F2_FILIAL,SF2->F2_DOC,SF2->F2_SERIE,SF2->F2_CLIENTE,SF2->F2_LOJA)
			Aviso('Atenção','Nota Fiscal já tem CTe gerado, não pode ser cancelada.',{'Ok'})
			lRet := .F.

		EndIf

	Endif

Endif

RestArea(aArea)
Return(lRet)

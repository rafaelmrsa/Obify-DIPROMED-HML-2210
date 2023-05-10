/*
PONTO.......: MT119AGR          PROGRAMA....: MATA119
DESCRIÇÄO...: APOS A GRAVACAO DA NF DESP. IMPORTAC.
UTILIZAÇÄO..: Apos a gravacao da nf despesa de importacao
fora da transacao.

PARAMETROS..: UPAR do tipo X : NENHUM


RETORNO.....: URET do tipo X : NENHUM
*/
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³ MT119AGR º Autor ³   Alexandro Dias    º Data ³  30/01/02   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Ponto de entrada para a nf despesa de importacao            º±±
±±º          ³                                                             º±±
±±º          ³                                                             º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

#include "RwMake.ch"

User Function MT119AGR()
Local _xArea	:= GetArea()
Local _xAreaSE2	:= SE2->(GetArea())
Local _xAreaSF1	:= SF1->(GetArea())
Local _cObs		:= Space(120)

U_DIPPROC(ProcName(0),U_DipUsr()) // JBS 05/10/2005 - Gravando o nome do Programa no SZU

@ 126,000 To 230,300 DIALOG oDlg TITLE OemToAnsi(" NF - " + SF1->F1_DOC )
@ 020,010 Say "Observação: "
@ 020,055 Get _cObs Size 93,20 Picture "@S100"
@ 040,050 BMPBUTTON TYPE 1 ACTION Close(odlg)
ACTIVATE DIALOG oDlg Centered

// atualiza a observação (rafael)
Dbselectarea("SF1")
RecLock("SF1",.F.)
SF1->F1_OBS     := _cObs
SF1->(MsUnlock())

DbSelectArea("SE2")
DbSetOrder(6)
IF DbSeek( xFilial("SE2") + SF1->F1_FORNECE+SF1->F1_LOJA+SF1->F1_SERIE+SF1->F1_DOC )
	While SE2->(!Eof()) .and. SE2->E2_FORNECE+SE2->E2_LOJA+SE2->E2_PREFIXO+SE2->E2_NUM == ;
		SF1->F1_FORNECE+SF1->F1_LOJA+SF1->F1_SERIE  +SF1->F1_DOC
		RecLock("SE2",.F.)
		SE2->E2_HIST := SF1->F1_OBS
		SE2->(MsUnLock())
		SE2->(DbSkip())
	EndDo
EndIf

RestArea(_xAreaSE2)
RestArea(_xAreaSF1)

Return

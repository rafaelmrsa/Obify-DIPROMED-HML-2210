/*
PONTO.......: MT240TOK          PROGRAMA....: MATA240
DESCRIÇÄO...: VALIDAR INCLUSAO DE MOVIMENTO
UTILIZAÇÄO..: Na validacao da inclusao do movimento.
Pode ser utilizado para validar a inclusao do movimento pelo usuario.

PARAMETROS..: UPAR do tipo X :

RETORNO.....: URET do tipo X : Logico. Caso verdadeiro prossegue com o
movimento. Caso falso abandona o movimento.

OBSERVAÇÖES.:
======================================================================================

10/12/04 - RAFAEL - COLOCAÇÃO DA VALIDAÇÃO DE LOTE
*/
User Function MT240TOK()
Local _lRetorno := .T.
U_DIPPROC(ProcName(0),U_DipUsr()) // JBS 05/10/2005 - Gravando o nome do Programa no SZU
If Empty(M->D3_DOC)
	MsgInfo("Informe o número do documento !!!","Atenção!")
	_lRetorno := .F.
EndIf

If _lRetorno
	// VERIFICAÇÃO DO LOTE
	DbSelectArea("SB1")
	DbSetOrder(1)
	DbSeek(xFilial("SB1")+M->D3_COD)
	
	If Rastro(SB1->B1_COD) .and. Empty(M->D3_LOTECTL)
		MsgInfo("Preencha o campo Lote.","Atenção!!!")
		_lRetorno := .F.
	EndIf    
	
EndIf


// VERIFICAÇÃO DA DATA DE VALIDADE   MCVN - 03/10/2008
If _lRetorno
	If  SB1->B1_RASTRO+SB1->B1_LOTEDIP='LS' .And. M->D3_DTVALID	< DATE()+180 .And. M->D3_TM < '500' 			
	   _lRetorno := U_SENHA("DTV",0,0,0)	   
	Endif 	                                              
Endif

If _lRetorno
	M->D3_Explic := U_D3_EXPLIC(M->D3_DOC,"EXPLICACAO DO MOVIMENTO")
EndIf

Return(_lRetorno)

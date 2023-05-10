#Include "Protheus.ch"
/*
PONTO.......: MT260TOK          PROGRAMA....: MATA260
DESCRI��O...: Ponto de Entrada localizado na confirmacao
UTILIZA��O..: � executada ao pressionar o botao da EnchoiceBar.

PARAMETROS..: uPar do tipo C : Nenhum

RETORNO.....: uRet do tipo L : .T. ou .F.

OBSERVA��ES.: 
==============================================================================

*/

User Function MT260TOK(_lPe)
Local _uRetorno := .T.

DEFAULT _lPe := .T.
Static _cD3_EXPLIC

If _lPe
	U_DIPPROC(ProcName(0),U_DipUsr()) // JBS 05/10/2005 - Gravando o nome do Programa no SZU
	If Empty(M->cDOCTO)
		MsgInfo("Informe o n�mero do documento !!!","Aten��o!")
		_uRetorno := .F.
	EndIf                  
	
	If _uRetorno //MCVN - 03/06/2008
		If M->dEmis260<>DDataBase
			MSGINFO("Data de emiss�o incorreta, A data deve ser igual a database do sistema!")
			_uRetorno := .f.
		EndIf
	EndIf

	_cD3_EXPLIC := U_D3_EXPLIC(M->cDOCTO,"EXPLICACAO DO MOVIMENTO")
Else
	_uRetorno := _cD3_EXPLIC
EndIf
Return(_uRetorno)
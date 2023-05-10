#include "RwMake.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³ A100DEL  º Autor ³   Alexandro Dias    º Data ³  30/01/02   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Ponto de entrada para verificar se os titulos referentes    º±±
±±º          ³ ao Desdobramento dos titulos foram baixados ou nao.         º±±
±±º          ³ A utilizacao do desdobramento e utilizada conforme o campo  º±±
±±º          ³ A2_DESDOBR Igual a "S".                                     º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function A100DEL()

Local _xAlias    := { Alias(), IndexOrd(), Recno() }
Local _xSA2Alias := { IndexOrd(), Recno() }
Local _lRet      := .T.
Local aAdv:={}
Local bSenha := ''

U_DIPPROC(ProcName(0),U_DipUsr()) // JBS 05/10/2005 - Gravando o nome do Programa no SZU

If SF1->F1_FORMUL=='S'
	aadd(aAdv,'Nota Fiscal '+AllTrim(SF1->F1_DOC)+'-'+AllTrim(SF1->F1_SERIE)+' emitida em '+dtoc(SF1->F1_DTDIGIT))
	aadd(aAdv,'Controle '+Transform(SF1->F1_VALBRUT,'@e 999,999,999,999.99'))
	aadd(aAdv,'Para excluir esta Nota Fiscal informe a senha de autorização')
	_lRet:=U_SENHA("DEL",SF1->F1_VALBRUT,0,0,,aAdv,bSenha)     

	If !_lRet // Corrigindo falha qdo a tela de senha é cancelada. MCVN - 09/04/09
		Return(_lRet)
	Endif        
EndIf     
 
If _lRet
	DbSelectArea('SA2')
	DbSetOrder(1)
	IF DbSeek(xFilial('SA2')+cA100For+cLoja)
		IF SA2->A2_DESDOBR == 'S'
			_lRet := UAvaDesdobra()
		EndIF
	EndIF
	SA2->( DbSetOrder(_xSA2Alias[1]) )
	SA2->( DbGoto(_xSA2Alias[2]) )
	IF !_lRet
		_cMsg := "Os Titulos referentes a Desdobramento ja foram baixados ou enviados ao Banco."+Chr(13)
		_cMsg := _cMsg + "Esta nota nao podera ser Excluida !!!"
		MsgBox(_cMsg,"Atencao","INFO")
	Else
		//³ Cria variavel publica que sera utilizada no ponto de entrada ³
		//³ MT100AGR para excluir os titulos referentes as Desdobramento ³
		Public _lDelDesdobra := .T.
		U_NfeEmail(3) // JBS 20/10/2005 Envia e-mail da NF Excluida para a Diretoria (Erich)
	EndIF
EndIf      

// Solicita senha para exclusão da NFE de fora de SP com ST - MCVN - 08/04/09
If _lRet
	If !Empty(SF1->F1_DTRECST) .AND. SF1->F1_TIPO = 'N'  
		lRet:=U_SENHA("DEL",SF1->F1_VALBRUT,0,0,,aAdv,bSenha)
		If !_lRet
		   Return(_lRet)
		Else
		   U_M100AGRCIC("EXC")	
		Endif        
	Endif        
Endif                  

DbSelectArea(_xAlias[1])
DbSetOrder(_xAlias[2])
DbGoto(_xAlias[3])
Return(_lRet)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³UAvaDesdobraº Autor ³   Alexandro Dias    º Data ³  30/01/02   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Avalia se os titulos referentes a Desdobramento pode ou nao   º±±
±±º          ³ ser excluidos.                                                º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function UAvaDesdobra()

Local _xSE2Alias := { IndexOrd(), Recno() }
Local _aSE2      := {}
Local _lRet      := .T.
DbSelectArea("SE2")
DbSetOrder(6)
DbSeek(xFilial("SE2")+cA100For+cLoja+"999"+cNFiscal)
Do While !Eof() .and. SE2->E2_FORNECE+SE2->E2_LOJA+SE2->E2_PREFIXO+SE2->E2_NUM ;
	== cA100For+cLoja+"999"+cNFiscal
	IF !Empty(SE2->E2_NUMBOR) .Or. !Empty(SE2->E2_BAIXA)
		_lRet := .F.
		Exit
	EndIF
	DbSkip()
EndDo
SE2->( DbSetOrder(_xSE2Alias[1]) )
SE2->( DbGoto(_xSE2Alias[2]) )

Return(_lRet)
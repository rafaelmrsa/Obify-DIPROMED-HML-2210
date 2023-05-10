#include "rwmake.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³ DIPA010  º Autor ³   Rodrigo Franco   º Data ³  15/02/02   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Atualiza SF2->F2_VOLUME                                    º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function DIPA010()   
Local _lWhen := .T. 

U_DIPPROC(ProcName(0),U_DipUsr()) // JBS 05/10/2005 - Gravando o nome do Programa no SZU
_xAlias  := GetArea()

IF !Empty(cMarca)   	                                     

	SF2->(DbOrderNickName("F2OK2"))	// Utilizando DbOrderNickName ao invés de DbSetOrder  devido a virada de versão MCVN - 26/10/2007
	SF2->(DbSeek(xFilial("SF2")+cMarca))	

	ZZ5->(dbSetOrder(1))
	If ZZ5->(dbSeek(xFilial("ZZ5")+Posicione("SD2",3,xFilial("SD2")+SF2->(F2_DOC+F2_SERIE),"D2_PEDIDO")))
		Return(Aviso("Atenção","Não será possível alterar o volume. NF Gerada pelo ACD.",{"Ok"},1))
	EndIf

	_nVolume := 0
	@ 126,000 To 230,180 DIALOG oDlg TITLE OemToAnsi("Informar Volume")
	@ 010,010 Say "Volume: "
	@ 010,035 Get _nVolume size 30,20 Picture "@E 999,999" When _lWhen
	@ 035,027 BMPBUTTON TYPE 1 ACTION Close(odlg)
	ACTIVATE DIALOG oDlg Centered
  /*Dbselectarea("SF2")
	DbSetOrder(8)
	DbSeek(xFilial("SF2")+cMarca)*/
	
	While !Eof() .AND. xFILIAL("SF2") == SF2->F2_FILIAL
		_cNotaSerie := SF2->F2_DOC+SF2->F2_SERIE
	
		SF2->(RecLock("SF2",.F.))
			Replace F2_VOLUME1 With _nVolume
			SF2->F2_OK2 := ''
		SF2->(MsUnlock())

		SF2->(dbSeek(xFilial("SF2")+cMarca))
		//Dbselectarea("SF2")
		//DbSkip()

		// Registrando alteração de separador, conferente, volume e expedição no kardex. MCVN - 10/11/08              
		U_DiprKardex(Posicione("SD2",3,xFilial("SD2") + _cNotaSerie ,"D2_PEDIDO"),U_DipUsr(),Alltrim(Str(_nVolume))+"-DIPA010",.T.,"42")
	EndDo
Else
	MsgInfo("VOCE NAO MARCOU NENHUMA NOTA")
EndIf  

RestArea(_xAlias)

Return
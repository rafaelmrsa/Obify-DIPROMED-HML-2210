#include "rwmake.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³ DIGLOC2  º Autor ³   Rodrigo Franco   º Data ³  15/02/02   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Atualiza SF2->F2_VOLUME                                    º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function DIGLOC2()
U_DIPPROC(ProcName(0),U_DipUsr()) // JBS 05/10/2005 - Gravando o nome do Programa no SZU
_xAlias  := GetArea()
IF !EMPTY(cMarca)
	_nLocaliz  := SUBSTR(D2_localiz,1,8) + space(7) //15//Giovani Zago 20/04/2012
	_nLocaliz2 := SUBSTR(D2_localiz,9,8) + space(7) //15//Giovani Zago 20/04/2012
	_nLocaliz3 := space(15)
	@ 126,000 To 300,250 DIALOG oDlg TITLE OemToAnsi("Informar Localizacoes")       
	@ 010,005 say "Pedido: " + D2_PEDIDO + "  N.F.: " + D2_DOC + "  PRODUTO: " + SUBSTR(D2_COD,1,6)
	@ 025,005 Say "Localizacoes: "
	@ 040,005 Get _nLocaliz F3 "SBE"  SIZE 30,50
	@ 040,074 Get _nLocaliz2 F3 "SBE" SIZE 30,50	
	@ 065,050 BMPBUTTON TYPE 1 ACTION Close(odlg)
	ACTIVATE DIALOG oDlg Centered
	Dbselectarea("SD2")
	DbSetOrder(11)
	DbSeek(xFilial("SD2")+cMarca)
	While !Eof() .AND. xFILIAL("SD2") == SD2->D2_FILIAL .AND. cMarca == SD2->D2_OK
		_nLocaliz3 := SUBSTR(_nLocaliz,1,8) + " " + SUBSTR(_nLocaliz2,1,8)
		RecLock("SD2",.F.)
		Replace D2_LOCALIZ WITH _nLocaliz3  
		Replace D2_OK WITH "  "
		MsUnlock()
		Dbselectarea("SF2")
		DbSkip()
	END
ELSE
	MSGINFO("VOCE NAO MARCOU NENHUM ITEM DE NOTA")
ENDIF     
RestArea(_xAlias)		

Return
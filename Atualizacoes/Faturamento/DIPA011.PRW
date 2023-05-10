#include "rwmake.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³ DIPA011  º Autor ³   Rodrigo Franco   º Data ³  20/02/02   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Atualiza Hora de Saida da empresa da Nota                  º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function DIPA011()
U_DIPPROC(ProcName(0),U_DipUsr()) // JBS 05/10/2005 - Gravando o nome do Programa no SZU
_xAlias  := GetArea()

IF !EMPTY(cMarca)
	_cData  := CTOD("  /  /  ")
	_cHora  := TIME()
	@ 126,000 To 260,180 DIALOG oDlg TITLE OemToAnsi("Informar Saida")
	@ 010,010 Say "Data: "
	@ 010,035 Get _cData  size 40,20
	@ 025,010 Say "Hora: "
	@ 025,035 Get _cHora  size 12,20 Picture "@R 99:99"
	@ 045,030 BMPBUTTON TYPE 1 ACTION Close(odlg)
	ACTIVATE DIALOG oDlg Centered
	
	/*Dbselectarea("SF2")
	DbSetOrder(8)
	DbSeek(xFilial("SF2")+cMarca)*/
	
	SF2->(DbOrderNickName("F2OK2"))	// Utilizando DbOrderNickName ao invés de DbSetOrder  devido a virada de versão MCVN - 26/10/2007
	SF2->(DbSeek(xFilial("SF2")+cMarca))
	While !Eof() .AND. xFILIAL("SF2") == SF2->F2_FILIAL
	// .AND. cMarca == SF2->F2_OK2  
		
		RecLock("SF2",.F.)
		Replace F2_DATASAI WITH _cData
		Replace F2_HORASAI WITH _cHora    
		SF2->F2_OK2 := ''
		SF2->(MsUnlock())
		SF2->(DbSeek(xFilial("SF2")+cMarca))
		
		//Dbselectarea("SF2")
		//DbSkip()
	END 
ELSE
	MSGINFO("VOCE NAO MARCOU NENHUMA NOTA")
ENDIF

RestArea(_xAlias)

Return
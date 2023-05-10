#include "rwmake.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³DIPG005   ºAutor  ³   Alexandro Dias   º Data ³  07/11/01   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Gera numero sequencia para segmento de desconto.           º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function DIPG005()

Local _xAlias := GetArea()
Local _cRet   := 1
U_DIPPROC(ProcName(0),U_DipUsr()) // JBS 05/10/2005 - Gravando o nome do Programa no SZU
DbSelectArea("SZ1")
DbSetOrder(2)
IF DbSeek(xFilial("SZ1")+M->Z1_SEGMENT+M->Z1_FORNEC)
	While !Eof() .And. SZ1->Z1_SEGMENT == M->Z1_SEGMENT .And. SZ1->Z1_FORNEC == M->Z1_FORNEC
		_cRet++
		DbSkip()
	EndDo
ELSE
	DbSelectArea("SZ1")
	DbSetOrder(1)
	IF DbSeek(xFilial("SZ1")+M->Z1_SEGMENT+"      ")
		While !Eof() .And. SZ1->Z1_SEGMENT == M->Z1_SEGMENT .And. SZ1->Z1_FORNEC == "      "
			_cRet++
			DbSkip()
		EndDo
	ENDIF
ENDIF

/*
DbSelectArea("SZ1")
DbSetOrder(1)
DbSeek(xFilial("SZ1")+M->Z1_SEGMENT)
While !Eof() .And. SZ1->Z1_SEGMENT == M->Z1_SEGMENT
_cRet++
DbSkip()
EndDo
*/
RestArea(_xAlias)

Return(StrZero(_cRet,3))
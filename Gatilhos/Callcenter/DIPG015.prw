/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ DIPG015  º Auto  ³ Eriberto Elias     º Data ³ 18/06/2004  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Vamos validar o segmento, se nao tiver obrigo a colocar    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ DIPROMED                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
#include "rwmake.ch"

User Function DIPG015()
Local _xAlias  := GetArea()
Private lSaida := .T.
Private lSaida1 := .T.
U_DIPPROC(ProcName(0),U_DipUsr()) // JBS 05/10/2005 - Gravando o nome do Programa no SZU

If 	M->C5_TIPO $ 'N' //MCVN 11/09/09
	If Empty(SA1->A1_SATIV1) .and. Upper(U_DipUsr()) != 'SHEILA'
		While lSaida
			_cSegm := SPACE(6)
   			@ 126,000 To 270,300 DIALOG oDlg TITLE OemToAnsi(" Cliente sem SEGMENTO ")
  			@ 015,015 Say SA1->A1_COD+" "+SA1->A1_NOME
  			@ 030,015 Say 'Segmento: '
  			@ 030,055 Get _cSegm Size 33,20 F3 "T3" Valid ExistCpo("SX5","T3"+M->_cSegm)
   			@ 050,055 BMPBUTTON TYPE 1 ACTION (Ok(_cSegm),close(oDlg)) // JBS 14/02/2006
   			ACTIVATE DIALOG oDlg Centered
  		End
	EndIf

	If Empty(SA1->A1_ENVMALA)
		While lSaida1
			_cMala := " "
			@ 126,000 To 270,300 DIALOG oDlg1 TITLE OemToAnsi(" Informação sobre a MALA ")
 			@ 015,015 Say SA1->A1_COD+" "+SA1->A1_NOME
 			@ 030,015 Say 'O que recebe?: '
  			@ 030,070 Say 'T=Tudo / I=Institucional / N=Nada'
  			@ 030,055 Get _cMala Size 10,10 Picture "!" Valid _cMala $ 'TIN'
 			@ 050,055 BMPBUTTON TYPE 1 ACTION (Ok1(_cMala),Close(oDlg1))
  			ACTIVATE DIALOG oDlg1 Centered
		End
	EndIf    
Endif

RestArea(_xAlias)
If "TMK" $ FUNNAME()  // MCVN - 04/09/09
	Return(M->UA_CODCONT)
Else 
	Return(M->C5_CLIENTE)
Endif

Static Function Ok(_cSegm)
	RecLock("SA1",.F.)
	SA1->A1_SATIV1 := _cSegm
	SA1->(MsUnlock())
	lSaida := .F.
	// Eriberto 13/02/2006 Close(oDlg)
Return

Static Function Ok1(_cMala)
	RecLock("SA1",.F.)
	SA1->A1_ENVMALA := Iif(_cMala$'TIN',_cMala,'')
	SA1->(MsUnlock())
	lSaida1 := .F.
	// Eriberto 13/02/2006 Close(oDlg1)
Return
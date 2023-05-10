#include "protheus.ch"
#include "rwmake.ch" 
#include "ap5mail.ch"  
#include "Colors.ch"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ DIPM030 ³ Autor ³ Maximo canuto V. Neto ³ Data ³ 25/02/11  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Manutenção nos parâmetros MV_ULMES, MV_DATAFIN, MV_DATAFIS ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Especifico Dipromed                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function DIPM030()

                                                                 
Local _nOpcBco      := 0
Local _cUsuario     := "MCANUTO/MSANTOS/SCREATTO/RRIGO"                             
Local _cMv_Ulmes    := GetMV("MV_ULMES")
Local _cMv_BlQmov   := GetMV("MV_DBLQMOV")
Local _cMv_DtFin    := GetMV("MV_DATAFIN")
Local _cMv_DtFis    := GetMV("MV_DATAFIS")
Local _cOldUlmes    := GetMV("MV_ULMES")
Local _cOldBlQmov   := GetMV("MV_DBLQMOV")
Local _cOldDtFin    := GetMV("MV_DATAFIN")
Local _cOldDtFis    := GetMV("MV_DATAFIS")


@ 126,000 To 400,400 DIALOG oDlg TITLE OemToAnsi("Altera parâmetros de fechamento Fiscal/Financeiro e Estoque!")
@ 010,010 Say "MV_ULMES:  "  COLOR CLR_BLUE
@ 010,060 Get _cMv_Ulmes    Size 20,20
@ 030,010 Say "MV_DATAFIN:" COLOR CLR_BLUE
@ 030,060 Get _cMv_DtFin  Size 20,20 
@ 050,010 say "MV_DATAFIS:" COLOR CLR_BLUE
@ 050,060 get _cMv_DtFis  Size 30,20 
@ 070,010 say "MV_ULMES  : Data do ultimo fechamento do estoque." COLOR CLR_RED
@ 080,010 say "MV_DBLQMOV: Dt Blq dos movtos. no estoque. Alteração, Inclusão e Exclusão ." COLOR CLR_RED
@ 090,010 say "MV_DATAFIS: Ultima data de encerramento de operacoes fiscais."  COLOR CLR_RED
@ 100,010 say "MV_DATAFIN: Data limite p/ realizacao de operacoes financeiras."COLOR CLR_RED
@ 120,100 BMPBUTTON TYPE 1 ACTION (_nOpcBco := 1,Close(odlg))
@ 120,140 BMPBUTTON TYPE 2 ACTION (_nOpcBco := 0,Close(odlg))
ACTIVATE DIALOG oDlg Centered
	
                                                          
If Upper(U_DipUsr()) $ _cUsuario  
_cMv_BlQmov := _cMv_Ulmes                                        
	If _nOpcBco == 1
		If MsgYesNo("Confirma a alteração dos parâmetros?"+chr(13)+chr(10)+chr(13)+chr(10)+ ;			
					"MV_ULMES   de "+dtoc(_cOldUlmes ) +" para " +dtoc(_cMv_Ulmes)+"."+chr(13)+chr(10)+;
					"MV_DBLQMOV de "+dtoc(_cOldBlQmov) +" para " +dtoc(_cMv_BlQmov)+"."+chr(13)+chr(10)+;
					"MV_DATAFIN de "+dtoc(_cOldDtFin ) +" para " +dtoc(_cMv_DtFin)+"."+chr(13)+chr(10)+;
					"MV_DATAFIs de "+dtoc(_cOldDtFis ) +" para " +dtoc(_cMv_DtFis)+"."+chr(13)+chr(10) )
					
			If 'MCANUTO'$_cUsuario
				SetMv("MV_ULMES"  ,_cMv_Ulmes)	                      
				SetMv("MV_DBLQMOV",_cMv_BlQmov)
			EndIF
			SetMv("MV_DATAFIN",_cMv_DtFin)	                      
			SetMv("MV_DATAFIS",_cMv_DtFis)	                      
			
			MsgInfo("Alteração efetuada com sucesso!")
		Endif
	Endif
Else
	MsgInfo("Você não tem autorização para alterar parâmetros de fechamento Fiscal/Financeiro e Estoque. Contate o Administrador!")
Endif

Return()

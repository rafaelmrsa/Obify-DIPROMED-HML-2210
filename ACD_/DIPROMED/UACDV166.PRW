#INCLUDE "ACDV166.CH" 
#INCLUDE "PROTHEUS.CH"
#INCLUDE "APVT100.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ UACDV166()³ Autor ³ ACD                  ³ Data ³ 10/11/15 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Filtra as ordens de separação não iniciadas e por tipo     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAACD                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function UACDV166()
Local lRet
Local aTela	 := VtSave()
Private nOpcx  	 := 0                  

@ 0,0 VTSAY "Ordem tipo T ou M"
@ 1,0 VTSay "Selecione: "
nOpcx:=VTaChoice(3,0,6,VTMaxCol(),{"T-Terreo","M-Mezanino","P-Em Pausa","A-Em Andamento","S-Sem Filtro","E-Sem Expedicao"})

DbSelectArea("CB7")
CB7->(DbGoTop()) 

If nOpcx == 1
	SET FILTER TO (CB7->CB7_STATUS=="0" .And. CB7->CB7_XTM=="T")
ElseIf nOpcx == 2
	SET FILTER TO (CB7->CB7_STATUS=="0" .And. CB7->CB7_XTM=="M")
ElseIf nOpcx == 3
	SET FILTER TO (CB7->CB7_STATUS=='1' .And. CB7->CB7_STATPA == '1')
ElseIf nOpcx == 4
	SET FILTER TO (CB7->CB7_STATUS=='1' .And. Empty(CB7->CB7_STATPA))
ElseIf nOpcx == 5
	SET FILTER TO 
ElseIf nOpcx == 6
	u_DIPA080()
Else
	VtKeyBoard(chr(23))
	Return .f.             
EndIf      

If nOpcx <> 6
	ACDV166() 
	SET FILTER TO
EndIf

Return()       
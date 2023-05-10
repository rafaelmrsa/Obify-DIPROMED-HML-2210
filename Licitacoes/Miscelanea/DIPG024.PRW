#INCLUDE "Protheus.ch"
#INCLUDE "COLORS.CH"
#INCLUDE "RWMAKE.CH"
#DEFINE CR    chr(13)+chr(10)
/*====================================================================================\
|Programa  | DIPG024       | Autor | GIOVANI.ZAGO               | Data | 05/08/2011  |
|=====================================================================================|
|Descrição | Gatilho de calculo de validade e prorrogação de contrato                 |
|          |                                                                          |
|          |                                                                          |
|=====================================================================================|
|Sintaxe   | DIPG024                                                                 |
|=====================================================================================|
|Uso       | Especifico DIPROMED-Licitação                                            |
|=====================================================================================|
|........................................Histórico....................................|
\====================================================================================*/
User Function DIPG024(cOrig)

Local aArea      := GetArea()
Private _lSaida  :=.f.
Private _cDigDat := Space(03)
Private cRetor   := ""



If cOrig = "1".And. "DIPAL10" $ FunName()
	If !Empty(M->UA1_TPVALI)
		Do While !_lSaida
			@ 200,150 To 350,480 Dialog oDlg Title OemToAnsi("Validade do Contrato: ")
			If M->UA1_TPVALI $ "D"
				@ 010,020 SAY "Digite a Quantidade de Dias de Validade do Contrato:"  SIZE 160,020
				@ 040,070 Get _cDigDat Size 07,020 Picture PesqPictQt("UA1_VCONT2")
				@ 045,105 SAY "  Dias" SIZE 160,020 COLOR CLR_HBLUE
			ElseIf M->UA1_TPVALI $ "M"
				@ 010,020 SAY "Digite a Quantidade de Meses de Validade do Contrato:" SIZE 160,020
				@ 040,070 Get _cDigDat Size 07,020 Picture PesqPictQt("UA1_VCONT2")
				@ 045,105 SAY "  Meses" SIZE 160,020 COLOR CLR_HBLUE
			ElseIf M->UA1_TPVALI $ "A"
				@ 010,020 SAY "Digite a Quantidade de Anos de Validade do Contrato:"  SIZE 160,020
				@ 040,070 Get _cDigDat Size 07,020 Picture PesqPictQt("UA1_VCONT2")
				@ 045,105 SAY "  Anos" SIZE 160,020  COLOR CLR_HBLUE
			ElseIf M->UA1_TPVALI $ "E"
				_cDigDat     := Space(08)
				@ 010,020 SAY "Digite a Data de Validade do Contrato:" SIZE 160,020
				@ 040,060 Get _cDigDat Size 017,020 Picture "99/99/99"
				
			EndIf
			@ 055,075 BmpButton Type 1 Action (DataDigit(_cDigDat),Close(oDlg))
			//	@ 055,130 BmpButton Type 2 Action (Saida(),Close(oDlg))
			Activate Dialog oDlg Centered
			
		EndDo
		
		cRetor := M->UA1_TPVALI
		
		
	Else
		Saida()
		
	EndIf
	
Else
	If !Empty(M->UA1_TPVALI)
		DataAssina()
		
	EndIf
	
	cRetor:= M->UA1_ASSCON
EndIf

RestArea(aArea)
return(cRetor)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³  DataAssina ºAutor  ³   Giovani.Zago   º Data ³ 05/08/2011 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ carrega variaveis de acordo com o digitado                 º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function DataDigit(_cDigDat)
If Empty(M->UA1_ASSCON)
	M->UA1_ASSCON:= dDataBase
EndiF


If M->UA1_TPVALI $ "D/M/A"
	M->UA1_VCONT2 := _cDigDat
	
	
ElseIf M->UA1_TPVALI $ "E"
	M->UA1_VCONT2 := CTOD(_cDigDat)
	M->UA1_VCONTR := CTOD(_cDigDat)
	
EndIf
DataAssina()


_lSaida  :=.t.
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³  DataAssina ºAutor  ³   Giovani.Zago   º Data ³ 05/08/2011 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ calcula validade do contrato                               º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function DataAssina()

If Empty(M->UA1_ASSCON)
	M->UA1_ASSCON:= dDataBase
EndiF

If     M->UA1_TPVALI $ "D"
	M->UA1_VCONTR :=  (DaySum(M->UA1_ASSCON,VAL(M->UA1_VCONT2)))
	
ElseIf M->UA1_TPVALI $ "M"
	M->UA1_VCONTR := 	(MonthSUM(M->UA1_ASSCON,VAL(M->UA1_VCONT2)))
	
ElseIf M->UA1_TPVALI $ "A"
	M->UA1_VCONTR := 	(YearSum(M->UA1_ASSCON,VAL(M->UA1_VCONT2)))
EndIf

If 	M->UA1_VCONTR <	M->UA1_ASSCON
	_lSaida  :=.t.
	alert("Data de venvimento menor que a data de assinatura")
EndIf
Return (_lSaida)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³  SAIDA   ºAutor  ³   Giovani.Zago   º Data ³  05/08/2011   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Valida saida da tela.                                      º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Saida()

M->UA1_VCONTR := ""
M->UA1_VCONT2 := ""
M->UA1_TPVALI := ""
_lSaida := .T.



Return (_lSaida)

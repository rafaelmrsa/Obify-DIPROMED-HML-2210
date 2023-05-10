#INCLUDE "Protheus.ch"
#INCLUDE "COLORS.CH"
#INCLUDE "RWMAKE.CH"
#DEFINE CR    chr(13)+chr(10)
/*====================================================================================\
|Programa  | DIPG025       | Autor | GIOVANI.ZAGO               | Data | 08/08/2011   |
|=====================================================================================|
|Descri��o | Gatilho de prorroga��o de contrato                                       |
|          |                                                                          |
|          |                                                                          |
|=====================================================================================|
|Sintaxe   | DIPG025                                                                 |
|=====================================================================================|
|Uso       | Especifico DIPROMED-Licita��o                                            |
|=====================================================================================|
|........................................Hist�rico....................................|
\====================================================================================*/
User Function DIPG025(cOrig)

Local aArea      := GetArea()
Private _lSaida  :=.f.
Private _cDigDat := Space(03)
Private cRetor   := ""
Private aItForm  := {"DIAS","MESES","ANO(S)"}
Private cForm    := Space(08)
Private cDiaPro  :=	M->UA1_XVALPR
Private cTipPro  := M->UA1_XTPPRO




If cOrig = "1"  .And. "DIPAL10" $ FunName()
	If M->UA1_XPRORR $ "S"
		Do While !_lSaida
			@ 200,150 To 350,480 Dialog oDlg Title OemToAnsi("Prorroga��o do Contrato: ")
			@ 010,020 SAY "Digite a Prorroga��o do Contrato:"  SIZE 160,020
			@ 040,040 Get _cDigDat Size 07,020 Picture PesqPictQt("UA1_XVALPR")
			@ 040,080 COMBOBOX cForm ITEMS aItForm SIZE 50,50
			
			@ 055,075 BmpButton Type 1 Action (DataDigit(_cDigDat),Close(oDlg))
			
			Activate Dialog oDlg Centered
			
		EndDo
		
	ElseIf !(M->UA1_XPRORR $ "S") // caso escolha nao prorrogar apaga e recalcula a validade original
		If !Empty(cDiaPro) .AND. M->UA1_TPVALI $ "D/M/A"
			M->UA1_XTPPRO := ""
			M->UA1_XVALPR := 0
			M->UA1_XPRORR := "N"
			
			DataAssina()//recalculo
			
		ElseIf M->UA1_TPVALI $ "E"
			M->UA1_VCONTR :=  M->UA1_VCONT2
			M->UA1_XTPPRO := ""
			M->UA1_XVALPR := 0
			M->UA1_XPRORR := "N"
			
		EndIf
		cRetor := "N"
	EndIf
	
EndIf

RestArea(aArea)
return(cRetor)

/*
�����������������������������������������������������������������������������
���Programa  �  DataDigit �Autor  �   Giovani.Zago   � Data � 05/08/2011 ���
�������������������������������������������������������������������������͹��
���Desc.     � carrega variaveis de acordo com o digitado                 ���
�����������������������������������������������������������������������������
*/
Static Function DataDigit(_cDigDat)



If !Empty(_cDigDat)
	M->UA1_XTPPRO := cForm
	M->UA1_XVALPR := _cDigDat
	DataAssina()
	cRetor := "S"
Else
	Saida()
	cRetor := "N"
EndIf



_lSaida  :=.t.
Return()

/*
�����������������������������������������������������������������������������
���Programa  �  DataAssina �Autor  �   Giovani.Zago   � Data � 05/08/2011 ���
�������������������������������������������������������������������������͹��
���Desc.     � calcula validade do contrato                               ���
�����������������������������������������������������������������������������
*/

Static Function DataAssina()

If     M->UA1_TPVALI $ "D/M/A"
	If     M->UA1_TPVALI $ "D"
		M->UA1_VCONTR :=  (DaySum(M->UA1_ASSCON,VAL(M->UA1_VCONT2)))
		
	ElseIf M->UA1_TPVALI $ "M"
		M->UA1_VCONTR := 	(MonthSUM(M->UA1_ASSCON,VAL(M->UA1_VCONT2)))
		
	ElseIf M->UA1_TPVALI $ "A"
		M->UA1_VCONTR := 	(YearSum(M->UA1_ASSCON,VAL(M->UA1_VCONT2)))
	EndIf
	
	
	If  "DI"  $ M->UA1_XTPPRO
		
		M->UA1_VCONTR :=  (DaySum(M->UA1_VCONTR,VAL(M->UA1_XVALPR)))
		
	ElseIf "ME"  $ M->UA1_XTPPRO
		
		M->UA1_VCONTR := 	(MonthSUM(M->UA1_VCONTR,VAL(M->UA1_XVALPR)))
		
	ElseIf "AN" $ M->UA1_XTPPRO
		
		M->UA1_VCONTR := 	(YearSum(M->UA1_VCONTR,VAL(M->UA1_XVALPR)))
	EndIf
	
	
ElseIf M->UA1_TPVALI $ "E"
	If  "DI"  $ M->UA1_XTPPRO
		
		M->UA1_VCONTR :=  (DaySum(M->UA1_VCONT2,VAL(M->UA1_XVALPR)))
		
	ElseIf "ME"  $ M->UA1_XTPPRO
		
		M->UA1_VCONTR := 	(MonthSUM(M->UA1_VCONT2,VAL(M->UA1_XVALPR)))
		
	ElseIf "AN" $ M->UA1_XTPPRO
		
		M->UA1_VCONTR := 	(YearSum(M->UA1_VCONT2,VAL(M->UA1_XVALPR)))
	EndIf
EndIf

_lSaida  :=.t.

Return (_lSaida)

/*
�����������������������������������������������������������������������������
���Programa  �  SAIDA   �Autor  �   Giovani.Zago   � Data �  05/08/2011   ���
�������������������������������������������������������������������������͹��
���Desc.     � Valida saida da tela.                                      ���
�����������������������������������������������������������������������������
*/
Static Function Saida()

M->UA1_XTPPRO := ""
M->UA1_XVALPR := 0
M->UA1_XPRORR := "N"
_lSaida := .T.



Return (_lSaida)


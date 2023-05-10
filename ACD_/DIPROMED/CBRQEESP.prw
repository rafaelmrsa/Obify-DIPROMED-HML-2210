#include 'protheus.ch'
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CBRQEESP  ºAutor  ³Microsiga           º Data ³  11/08/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function CBRQEESP()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se o retorno do PE for Nil ele assume o valor padrão que o usuário digitou no coletor.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local aAreaSB1	:= SB1->(GetArea())
Local nQtdE
Local nQtdAux   := 0
Local cSQL 		:= ""
Local aAreaCB9  := CB9->(GetArea())   
Local nSomaQtd  := 0

If ProcName(2) == "CBQTDEMB"

	_cTipSald := ""
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³1=Unitaria;                                                                                           ³
	//³2=Secundaria;                                                                                         ³
	//³3=Embarque                                                                                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	SB1->(dbSetOrder(1))
	If SB1->(dbSeek(xFilial("SB1")+Paramixb))
		Do Case
			Case SB1->B1_XTPEMBC == '1'
				nQtdAux := 1
			Case SB1->B1_XTPEMBC == '2'
				nQtdAux :=  SB1->B1_XQTDSEC
			Case SB1->B1_XTPEMBC == '3'
				nQtdAux :=  SB1->B1_XQTDEMB
		EndCase
	EndIf
	
	CB8->(DbSetOrder(1))
	If CB8->(DbSeek(xFilial("CB8")+CB9->CB9_ORDSEP))
		While !CB8->(Eof()) .And. CB8->CB8_ORDSEP == CB9->CB9_ORDSEP
			If CB8->CB8_PROD == CB9->CB9_PROD .And. CB8->CB8_LOTECT == CB9->CB9_LOTECT .And. nQtdAux > 0
				If CB8->CB8_SALDOE >= nQtdAux 
					nQtdE 		:= nQtdAux
					_cTipSald 	:= "1"
				Else
					nSomaQtd += CB8->CB8_SALDOE
					If nSomaQtd >= nQtdAux
						nQtdE 		:= nQtdAux
						_cTipSald 	:= "1"
					EndIf
				EndIf
			EndIf
			CB8->(dbSkip())
		EndDo
	EndIf
EndIf
                            
If Type("_nDipQtde")<>"U" .And. _nDipQtde > 0

	_cTipSald 	:= ""
	
	If nQtdAux > 0
		If _nDipQtde > nQtdAux
			nQtdE := 0 
		ElseIf _nDipQtde < nQtdAux
			nQtdE := Nil 
		Else
			nQtdE := Nil
			_cTipSald := "2" 
		EndIf
	Else
		nQtdE := Nil 		
	EndIf                 

EndIf

RestArea(aAreaSB1)                
RestArea(aAreaCB9)

Return nQtdE
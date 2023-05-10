#include "rwmake.ch"      

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ SFINE015 ³ Autor ³   NATALINO OLIVEIRA   ³ Data ³ 07/06/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Gravacao das posicoes 374 a 398 do Layout CNAB PAGAR       ³±±
±±³          ³ Bradesco - PAGFOR                                          ³±±
±±³          ³ CODIGO DE BARRAS CASO NAO SEJA DOC OU COM O TIPO E ZEROS SE³±±
±±³          ³FOR DOC PAGFOR - POSICOES (105-117)						  ³±±

 ±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Especifico para Dipromed                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function SFINE015()       

Private CALIAS, _DOC, _CLINDIG, _CCAMPO1, _CCAMPO2, _CCAMPO3

U_DIPPROC(ProcName(0),U_DipUsr()) //MCVN - 22/01/2009

cALIAS  :=  Alias()

_Doc  := Space(25)

If Substr(SEA->EA_MODELO,1,2) $ "01"
	If SA2->A2_BANCO == "237"           
	    _Doc   :=  Space(25)
	Else
	    _Doc   :=  "C00000001"+Space(31)
	Endif
ElseIf SubStr(SEA->EA_MODELO,1,2) $ "03"
	If SA2->A2_BANCO == "237"           
	    _Doc   :=  Space(40)
	Else
	    _Doc   :=  "C00000003"+Space(31)
	Endif

ElseIf SubStr(SEA->EA_MODELO,1,2) $ "31"

    If !Empty(SE2->E2_CODBAR)

       _Doc  :=  SUBSTR(SE2->E2_CODBAR,20,25)

    ElseIf !Empty(SE2->E2_LD)

       ExtrLinDig()

    EndIf

EndIf


Return(_DOC)        



////Funcao para extracao do campo livre da linha digitavel
////Deve-se excluir todos os digitos de verificacao do campo livre da linha
////digitavel para envio

Static Function ExtrLinDig()

_cLinDig := SE2->E2_LD
_cCampo1 := SubStr(_cLinDig,05,05)
_cCampo2 := SubStr(_cLinDig,11,10)
_cCampo3 := SubStr(_cLinDig,22,10)
_Doc     := _cCampo1+_cCampo2+_cCampo3


Return(nil)        


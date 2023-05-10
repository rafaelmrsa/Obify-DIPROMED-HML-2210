# include "PROTHEUS.ch"
# include "TOPCONN.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ RPSGFASS ºAutor  ³ Patricia Jawiche   º Data ³  12/06/08	  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Impressao de nota fiscal de telecomunicao Grafica 		  º±±
±±º          ³ Modelo Assist - RPS                                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ A TELECOM - TELEFONICA								  	  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function DIPRl60()

Private oPrint
Private aAreaUA1    := UA1->(GetArea())
Private sCOD_MENS 	:= " "
Private sMENSAGEM1	:= " "
Private SMenNot2 	:= " "
Private xTipoNf		:= " "
Private nTamObs		:=120
Private lImpMen     := .F.
Private nOrdem 		:= 0
Private M			:= 0
Private tamanho		:= "G"
Private limite		:= 220
Private titulo 		:= PADC("ETIQUETA de AMOSTRA",74)
Private cDesc1 		:= PADC("Este programa ira emitir a Etiqueta de amostra",74)
Private cDesc2 		:= ""
Private cDesc3 		:= PADC("Etiqueta",74)
Private aReturn 	:= { "Especial", 1,"Administracao", 1, 2, 1,"",1 }
Private nomeprog	:= "DIPRl60"
Private cPerg		:= "DIPRl60"
Private nLastKey	:= 0
Private lContinua 	:= .T.
Private nLin		:= 0
Private wnrel    	:= "DIPRl60"
Private cMsgDecr       := "Selecione o modelo de Impressaõ."



nChave:= Aviso("Etiquetas",cMsgDecr ,{"Novo","Antigo"})
If nChave <> 1
	u_060Etiq()
Else
	cString:="UA1"
	RptStatus({|| RptDetail()})
EndIf
RestArea(aAreaUA1)
Return

Static Function RptDetail()

Local cTitulo := "ETIQUETA"



oPrint:=TMSPrinter():New(cTitulo)
oPrint:SetPortrait()
Imprime( )				//Funcao de Impressao
oPrint:Preview()  // em video


If Select("PUA4") > 0
	DbSelectArea("PUA4")
	dbCloseArea("PUA4")
EndIf

Return  (.T.)

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçào    ¦ IMPRIME  ¦ Autor ¦   Patricia Jawiche    ¦ Data ¦ 12/06/08¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Imprime a Nota Fiscal de Entrada e de Saida¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Generico RDMAKE¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/
Static Function Imprime()

Private oFonAri09  ,  oFonAri08 ,  oFonAri08b  ,  oFonAri09b ,  oFonAri10b  ,  oFonAri12b
Private aMenFixa := {}
Private nLado   := 0
Private nBaixo  := 0
Private nRegs   := 0
DEFINE FONT oFonAri07  NAME "Arial" SIZE 0, 7 OF oPrint
DEFINE FONT oFonAri07b NAME "Arial" SIZE 0, 7 OF oPrint BOLD
DEFINE FONT oFonAri08b NAME "Arial" SIZE 0, 8 OF oPrint BOLD
DEFINE FONT oFonAri08  NAME "Arial" SIZE 0, 8 OF oPrint
DEFINE FONT oFonAri09  NAME "Arial" SIZE 0, 9 OF oPrint
DEFINE FONT oFonAri09b NAME "Arial" SIZE 0, 9 OF oPrint BOLD
DEFINE FONT oFonAri10b NAME "Arial" SIZE 0,10 OF oPrint BOLD
DEFINE FONT oFonAri11  NAME "Arial" SIZE 0,11 OF oPrint
DEFINE FONT oFonAri11s NAME "Arial" SIZE 0,11 OF oPrint BOLD UNDERLINE
DEFINE FONT oFonAri12b NAME "Arial" SIZE 0,12 OF oPrint BOLD


oPrint:StartPage()    // Inicia uma nova página

dbSelectArea("UA4")
cQuery := " SELECT * "
cQuery += " FROM "+RETSQLNAME ("UA4") + " UA4 "
cQuery += "   WHERE UA4_FILIAL = '"+xFilial("UA4")+"' "
cQuery += "   AND UA4_EDITAL = '"+M->UA1_CODIGO+"' "
cQuery += "   AND UA4.D_E_L_E_T_ = ' ' "
cQuery += "   AND UA4_QAMOST > 0 "

If Select("PUA4") > 0
	DbSelectArea("PUA4")
	dbCloseArea("PUA4")
EndIf

TcQuery cQuery New Alias "PUA4"
If Select("PUA4") > 0
	DbSelectArea("PUA4")
	PUA4->(DbGoTop())
	
	While PUA4->(!eof())
		nRegs := nRegs + 1
		If nRegs > 1 .and. nRegs < 15
			nBaixo := nBaixo+400
		EndIf
		If nRegs = 8
			nBaixo := 0
			nLado  := 1300
		EndIf
		If nRegs   = 15
			nRegs  := 1
			nBaixo :=0
			nLado  :=0
			oPrint :EndPage()
			oPrint :StartPage()
		EndIf
		//"DIPROMED COMÉRIO E IMPORTAÇÃO LTDA"+CR+"CNPJ:47.869.078/0004-53"+CR+CR+Capital(AllTrim(Posicione("SA1",1,XFilial("SA1")+ M->UA1_CODCLI+M->UA1_LOJA,"A1_NOME")))+CR+"PREGÃO  Nº  "+AllTrim(M->UA1_NRCONC)+CR+" PROCESSO Nº  "+AllTrim(M->UA1_PROCES)+CR+CR+"ITEM ")
		oPrint:Say( 0230+nBaixo, 0050+nLado, "DIPROMED COMÉRIO E IMPORTAÇÃO LTDA", oFonAri12b )
		oPrint:Say( 0280+nBaixo, 0050+nLado, "CNPJ:47.869.078/0004-53", oFonAri12b )
		oPrint:Say( 0330+nBaixo, 0050+nLado, Capital(AllTrim(Posicione("SA1",1,XFilial("SA1")+ M->UA1_CODCLI+M->UA1_LOJA,"A1_NOME"))), oFonAri11s )
		oPrint:Say( 0380+nBaixo, 0050+nLado, "PREGÃO  Nº  "+AllTrim(M->UA1_NRCONC), oFonAri10b )
		oPrint:Say( 0430+nBaixo, 0050+nLado, "PROCESSO Nº  "+AllTrim(M->UA1_PROCES), oFonAri10b )
		oPrint:Say( 0500+nBaixo, 0050+nLado, "ITEM "+AllTrim(PUA4->UA4_ITEMAM), oFonAri10b )
		If !Empty(PUA4->UA4_LOTE)
			oPrint:Say( 0550+nBaixo, 0050+nLado, "LOTE:  "+AllTrim(PUA4->UA4_LOTE), oFonAri10b )
			If !Empty(PUA4->UA4_ITEMLT)
				oPrint:Say( 0550+nBaixo, 0300+nLado, "ITEM DO LOTE:  "+AllTrim(PUA4->UA4_ITEMLT), oFonAri10b )
			EndIf
		EndIf
		PUA4->(dbSkip())                      // passa para a proxima etiqueta
	End
	
	oPrint:EndPage()      // Finaliza a página
Else
	alert("Edital Sem Amostras !!!!")
EndIf
Return


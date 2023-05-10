#INCLUDE "PROTHEUS.CH"
#INCLUDE "APVT100.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ A166TELA   ºAutor  ³Emerson Leal Bruno  Data ³  04/10/2012 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Ponto de Entrada para ajustar TELA de separaçao no coletor º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ ACD                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function A166TELA()
                                
Local cProd  	:= CB8->CB8_PROD 
Local nQtdSep	:= ParamIXB[1]
Local aTam		:= ParamIXB[2]
Local cUnidade  := ParamIXB[3] 
     
cUnidade := if(empty(SB1->B1_UM),ParamIXB[3],alltrim(SB1->B1_UM)) 

@ 0,0 VTSay Padr('Separe '+Alltrim(Str(nQtdSep,aTam[1],aTam[2]))+" "+cUnidade,20) // //"Separe "
@ 1,0 VTSay SUBSTR(CB8->CB8_PROD,1,6)+'-'+SUBSTR(SB1->B1_DESC,1,13)	
@ 2,0 VTSay SUBSTR(SB1->B1_DESC,14,20)	
@ 3,0 VTSay SUBSTR(SB1->B1_DESC,34,20)
If Rastro(CB8->CB8_PROD,"L")
	@ 4,0 VTSay 'Lote: '+CB8->CB8_LOTECT //"Lote: "
ElseIf Rastro(CB8->CB8_PROD,"S")
	@ 4,0 VTSay CB8->CB8_LOTECT+"-"+CB8->CB8_NUMLOT
EndIf
If !Empty(CB8->CB8_NUMSER)
	@ 5,0 VTSay CB8->CB8_NUMSER
EndIf

      

Return() 
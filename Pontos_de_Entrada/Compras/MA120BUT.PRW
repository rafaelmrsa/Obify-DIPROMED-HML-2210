#INCLUDE "Protheus.ch"
#include "rwmake.ch"

/*====================================================================================\
|Programa  |  MA120BUT                     | Autor | GIOVANI.ZAGO| Data | 31/10/2011 |
|=====================================================================================|
|Descrição | Adicionado botao para replace na opção de entrega caso seja material de  |
|          | consumo											                      |
|          |                                                                          |
|=====================================================================================|
|Sintaxe   |                                                                          |
|=====================================================================================|
|Uso       | Especifico DIPROMED                                                      |
|=====================================================================================|
|........................................Histórico....................................|
\====================================================================================*/
*---------------------------------------------------*
User Function MA120BUT ()
*---------------------------------------------------*
Private _xArea    := GetArea()
Private lRet      := .T.
Private aButtons  :={}


If Altera .And. cEmpAnt = "01"
	Aadd( aButtons, {"EDIT"    ,{|| U_VerifReg()},"Altera Endereço...  " } )
EndIf

RestArea(_xArea)
Return(aButtons)

User Function VerifReg ()

Private nPosXmc := aScan(aHeader,{|x| AllTrim(x[2]) == 'C7_XMC'}) //Giovani Zago 21/11/11
Private nPosCod := aScan(aHeader,{|x| AllTrim(x[2]) == 'C7_PRODUTO'}) //Giovani Zago 21/11/11
Private i
Private lMcs7  := .T.
Private cChve  :=  " "

If   ALTERA  .And. cEmpAnt = "01"
	For i :=1 To Len( aCols )
		If  "MC" $ Posicione("SB1",1,xFilial("SB1")+aCols[i][nPosCod] ,"B1_TIPO").and. aCols[i,Len(aHeader)+1] == .F.
			lMcs7 := .F.
		EndIf
	Next i
	If !lMcs7
		U_AltEnder()
	Else
		MSGINFO("Opção disponivel apenas Quando houver Mercadorias de Consumo !!!!!!")
	EndIf
EndIf


Return(.t.)

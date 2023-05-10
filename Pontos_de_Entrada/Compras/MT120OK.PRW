/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³ MT120OK º Autor ³ Maximo Canuto        º Data ³  29/09/2008 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Valida o percentual de Acréscimo/Desconto do fornecedor     º±±
±±º          ³                                                             º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

#include "RwMake.ch"
#INCLUDE "Protheus.CH"
#INCLUDE "Topconn.CH"
#Include "MSOLE.CH"
#INCLUDE "AP5MAIL.CH"
#INCLUDE "COLORS.CH"

User Function MT120OK()

Local _xArea    := GetArea()
Local _lRetorno := .T.
Local nPosAcr := aScan(aHeader,{|x| AllTrim(x[2]) == 'C7_ACREFOR'})
Local nPosDes := aScan(aHeader,{|x| AllTrim(x[2]) == 'C7_DESCFOR'})
Local nPosVl1 := aScan(aHeader,{|x| AllTrim(x[2]) == 'C7_XPARC1'})  //Felipe Duran - 13/11/19
Local nPosDt1 := aScan(aHeader,{|x| AllTrim(x[2]) == 'C7_XDATA1'})  //Felipe Duran - 13/11/19
Local nPosVl2 := aScan(aHeader,{|x| AllTrim(x[2]) == 'C7_XPARC2'})  //Felipe Duran - 13/11/19
Local nPosDt2 := aScan(aHeader,{|x| AllTrim(x[2]) == 'C7_XDATA2'})  //Felipe Duran - 13/11/19
Local nPosVl3 := aScan(aHeader,{|x| AllTrim(x[2]) == 'C7_XPARC3'})  //Felipe Duran - 13/11/19
Local nPosDt3 := aScan(aHeader,{|x| AllTrim(x[2]) == 'C7_XDATA3'})  //Felipe Duran - 13/11/19
Local nPosVl4 := aScan(aHeader,{|x| AllTrim(x[2]) == 'C7_XPARC4'})  //Felipe Duran - 13/11/19
Local nPosDt4 := aScan(aHeader,{|x| AllTrim(x[2]) == 'C7_XDATA4'})  //Felipe Duran - 13/11/19
Local nXvalor1:= aCols[1][nPosVl1]  //Felipe Duran - 13/11/19
Local dXdata1 := aCols[1][nPosDt1]  //Felipe Duran - 13/11/19
Local nXvalor2:= aCols[1][nPosVl2]  //Felipe Duran - 13/11/19
Local dXdata2 := aCols[1][nPosDt2]  //Felipe Duran - 13/11/19
Local nXvalor3:= aCols[1][nPosVl3]  //Felipe Duran - 13/11/19
Local dXdata3 := aCols[1][nPosDt3]  //Felipe Duran - 13/11/19
Local nXvalor4:= aCols[1][nPosVl4]  //Felipe Duran - 13/11/19
Local dXdata4 := aCols[1][nPosDt4]  //Felipe Duran - 13/11/19
Local nApliDes:= 0
Local nApliAcr:= 0
Local lValido := .T.
Local nX := 0
Local cCodUsr    := RetCodUsr()// MCVN - 15/01/2009

Private nAcresci := 0
Private nDescont := 0

Private nPosCod := aScan(aHeader,{|x| AllTrim(x[2]) == 'C7_PRODUTO'}) //Giovani Zago 21/11/11
Private nPosXmc := aScan(aHeader,{|x| AllTrim(x[2]) == 'C7_XMC'}) //Giovani Zago 21/11/11
Private i
Private lMcs7  := .T.
Private cChve  :=  " "

U_DIPPROC(ProcName(0),U_DipUsr()) // MCVN 29/09/08 - Gravando o nome do Programa no SZU

If l120Auto
	RestArea(_xArea)
	Return(_lRetorno)
Endif

// Valida usuário na tabela de comprador    // MCVN - 15/01/2009
DbSelectArea("SY1")
SY1->(DbSetOrder(3))
SY1->(DbGoTop())
If !(SY1->(dbSeek(xFilial("SY1")+cCodUsr)))
	Return(_lRetorno)
Endif
SY1->(DbCloseArea())


If Inclui .Or. (Altera .And. aCols[1][nPosDes] = 0 .And. aCols[1][nPosAcr] = 0)
	If SA2->A2_ACRESCI > 0
		nApliAcr := Aviso("Atenção","Existe no fornecedor um percentual de ACRESCIMO no valor de "+;
		AllTrim(Transform(SA2->A2_ACRESCI,"@E 99.99"))+ "% . Deseja aplicar ?" ,{"Aplicar","Alterar","Não Aplicar"})
		If nApliAcr == 1
			For nX :=1 To Len( aCols )
				aCols[nX][nPosAcr] := SA2->A2_ACRESCI
			Next nX
		ElseIf nApliAcr == 2
			DesAcrForn()
		Endif
	ElseIf SA2->A2_DESCONT > 0
		nApliDes := Aviso("Atenção","Existe no fornecedor um percentual de DESCONTO no valor de "+;
		AllTrim(Transform(SA2->A2_DESCONT,"@E 99.99"))+ "% . Deseja aplicar ?" ,{"Aplicar","Alterar","Não Aplicar"})
		If nApliDes == 1
			For nX :=1 To Len( aCols )
				aCols[nX][nPosDes] := SA2->A2_DESCONT
			Next nX
		ElseIf nApliDes == 2
			DesAcrForn()
		Endif
	Endif
ElseIf Altera
	If aCols[1][nPosAcr] > 0
		nAcresci := aCols[1][nPosAcr]
		nExistAcr:= Aviso("Atenção","Existe no pedido um percentual de ACRÉSCIMO no valor de "+;
		AllTrim(Transform(nAcresci,"@E 99.99"))+ "% . Mantem acréscimo ?" ,{"Sim","Não","Alterar"})
		
		
		If nExistAcr = 1 // Corrigindo falha na gravação do acrescimo - MCVN 25/11/2008
			For nX :=1 To Len( aCols )
				aCols[nX][nPosAcr] := nAcresci
			Next nX
		ElseIf nExistAcr = 2
			For nX :=1 To Len( aCols )
				aCols[nX][nPosAcr] := 0
			Next nX
		ElseIf nExistAcr = 3
			DesAcrForn()
		Endif
		
	ElseIf aCols[1][nPosDes] > 0
		nDescont :=	aCols[1][nPosDes]
		nExistDes:= Aviso("Atenção","Existe no pedido um percentual de DESCONTO	 no valor de "+;
		AllTrim(Transform(nDescont,"@E 99.99"))+ "% . Mantém desconto ?" ,{"Sim","Não","Alterar"})
		If nExistDes = 1 // Corrigindo falha na gravação do desconto - MCVN 25/11/2008
			For nX :=1 To Len( aCols )
				aCols[nX][nPosDes] := nDescont
			Next nX
		ElseIf nExistDes = 2
			For nX :=1 To Len( aCols )
				aCols[nX][nPosDes] := 0
			Next nX
		ElseIf nExistDes = 3
			DesAcrForn()
		Endif
	Endif
Endif
//Preencher os campos customizados de data e valor de acordo com o que for informado na primeira linha do Pedido
//Felipe Duran - 13/11/19
If Inclui .Or. (Altera .And. !EMPTY(aCols[1][nPosDt1]))
	For nX :=1 To Len( aCols )
		aCols[nX][nPosVl1] := nXvalor1
		aCols[nX][nPosDt1] := dXdata1
		aCols[nX][nPosVl2] := nXvalor2
		aCols[nX][nPosDt2] := dXdata2
		aCols[nX][nPosVl3] := nXvalor3
		aCols[nX][nPosDt3] := dXdata3
		aCols[nX][nPosVl4] := nXvalor4
		aCols[nX][nPosDt4] := dXdata4
	Next nX
EndIf
//Fim Ajuste - Felipe Duran

//Giovani Zago 21/11/11
If _lRetorno  .And.  Inclui .And. cEmpAnt = "01"
	
	
	For i :=1 To Len( aCols )
		If  "MC" $ Posicione("SB1",1,xFilial("SB1")+aCols[i][nPosCod] ,"B1_TIPO").and. aCols[i,Len(aHeader)+1] == .F.
			lMcs7 := .F.
		EndIf
	Next i
	If !lMcs7
U_AltEnder()
	EndIf
	

ElseIf _lRetorno  .And.  ALTERA  .And. cEmpAnt = "01"
	For i :=1 To Len( aCols ) 
	If "MC" $ Posicione("SB1",1,xFilial("SB1")+aCols[i][nPosCod] ,"B1_TIPO") .and. aCols[i,Len(aHeader)+1] == .F.
		If   !Empty(aCols[i][nPosXmc] )
			lMcs7 := .F.
			cChve:=aCols[i][nPosXmc]
			ElseIf Empty(aCols[i][nPosXmc] )
		cChve:=	U_AltEnder()
			lMcs7 := .F.
		EndIf 
    EndIf
	Next i 
	If !lMcs7
		U_AltC7(cChve)
	Else 
		U_AltC7(" ")
	EndIf
	 
EndIf
RestArea(_xArea)
Return(_lRetorno)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³ DesAcrForn() º Autor ³ Maximo Canuto     Data ³  30/09/2008 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ possibilita alterar o percentual de Acréscimo/Desconto no   º±±
±±º			   no pedido de compra e/ou no fornecedor                      º±±
±±º          ³                                                             º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/


*-------------------------------*
Static Function DesAcrForn()
*-------------------------------*
Local bOk:={|| nOpcao:=1,lSaida := .T.,oDlg:End()}
Local bCancel:={|| (nOpcao := 0,lSaida := .T., oDlg:End())}
Local oDlg
Local oBt1
Local oBt2
Local nOpcao  := 0
Local nX      := 0
Local nPosAcr := aScan(aHeader,{|x| AllTrim(x[2]) == 'C7_ACREFOR'})
Local nPosDes := aScan(aHeader,{|x| AllTrim(x[2]) == 'C7_DESCFOR'})
Local lSaida  := .F.

Private cCodForn   := SA2->A2_COD
Private cNomForn   := SA2->A2_NREDUZ
//Private nAcresci   := If(nAcresci=0,SA2->A2_ACRESCI,nAcresci)
//Private nDescont   := If(nDescont=0,sA2->A2_DESCONT,nDescont)
Private lAltPedCom := .F.
Private lAltFornec := .F.

nAcresci   := If(nAcresci=0,SA2->A2_ACRESCI,nAcresci)
nDescont   := If(nDescont=0,SA2->A2_DESCONT,nDescont)
Do While !lSaida
	nOpcao := 0
	Define msDialog oDlg title OemToAnsi("Alterar perc. Acres/Desc no pedido/fornecedor") From 09,10 TO 25,45
	@ 002,002 to 103,136 pixel
	@ 010,010 say "Fornecedor"      Pixel
	@ 020,010 say "Nome Fornecedor" Pixel
	@ 030,010 say "% Acréscimo"     Pixel
	@ 040,010 say "% Desconto "     Pixel
	@ 060,010 checkbox oAltPedCom var lAltPedCom PROMPT "Altera Pedido" size 60,008
	@ 070,010 checkbox oAltFornec var lAltFornec PROMPT "Altera Fornec" size 60,008
	
	@ 010,060 get oCodForn var cCodForn Size 60,08 pixel
	@ 020,060 get oNomForn var cNomForn Size 60,08 pixel
	@ 030,060 get oAcresci var nAcresci When If(!Empty(SA2->A2_ACRESCI),.T.,.F.) picture "@e 99.99" Size 40,08 pixel
	@ 040,060 get oDescont var nDescont When If(!Empty(SA2->A2_DESCONT),.T.,.F.) picture "@e 99.99" Size 40,08 pixel
	
	Define sbutton oBt1 from 108,079 type 1 action Eval(bOK) enable of oDlg
	Define sbutton oBt2 from 108,109 type 2 action Eval(bCancel) enable of oDlg
	
	Activate Dialog oDlg Centered
EndDo
If nOpcao == 1
	If lAltPedCom
		If nAcresci > 0
			For nX :=1 To Len( aCols )
				aCols[nX][nPosAcr] := nAcresci
			Next nX
			If lAltFornec
				RECLOCK("SA2",.F.)
				SA2->A2_ACRESCI := nAcresci
				SA2->(MsUnLock())
			Endif
		ElseIf nDescont > 0
			For nX :=1 To Len( aCols )
				aCols[nX][nPosDes] := nDescont
			Next nX
			If lAltFornec
				RECLOCK("SA2",.F.)
				SA2->A2_DESCONT := nDescont
				SA2->(MsUnLock())
			EndIf
		EndIf
	Endif
Endif

Return(.t.) 


*-------------------------------*
User Function AltEnder()
*-------------------------------*
Local  lSaida        := .f.
Local oDlg
Local oFont24  	:= TFont():New("Times New Roman",9,24,.T.,.T.,5,.T.,5,.T.,.F.)
Local oFont16  	:= TFont():New("Arial",9,14,.T.,.T.,5,.T.,5,.T.,.F.)
Local oFont25  	:= TFont():New("Arial",9,24,.T.,.T.,5,.T.,5,.T.,.F.)
Local oFont30  	:= TFont():New("Arial",9,28,.T.,.T.,5,.T.,5,.T.,.F.)
Local cChve  :=""

Do While !lSaida
	

	@ 126,000 To 350,350 DIALOG oDlg TITLE OemToAnsi("ENDEREÇO DE ENTREGA" )
	@ 017 ,015 say "Este pedido possui Material de Consumo"  font oFont24  COLOR CLR_BLACK Pixel
	@ 027 ,015 say "Qual será o Endereço de Entrega:"  font oFont24  COLOR CLR_BLACK Pixel
	@ 055 , 45 say "MATRIZ"  font oFont30  COLOR CLR_GREEN Pixel
	DEFINE SBUTTON FROM 070 ,45 type 1   ACTION (u_AltC7("1"), cChve  :="1", lSaida:=.T.,oDlg:End()) ENABLE OF oDlg
	@ 055 ,115 say "CD"  font oFont30  COLOR CLR_RED Pixel
	DEFINE SBUTTON FROM 070 ,113 type 1   ACTION (u_AltC7("2"),cChve  :="2", lSaida:=.T.,oDlg:End()) ENABLE OF oDlg
	
	Activate dialog oDlg centered
	
Enddo

Return (cChve)
          
*-------------------------------*
  User Function AltC7(cChav)
*-------------------------------*  
 local j
Private nPosXmc := aScan(aHeader,{|x| AllTrim(x[2]) == 'C7_XMC'}) //Giovani Zago 21/11/11 
	For j :=1 To Len( aCols )
		aCols[j][nPosXmc] := cChav
	Next j

	
Return ()


/*                                                              Sao Paulo,  21 Jun 2006
---------------------------------------------------------------------------------------
Empresa.......: DIPOMED Comércio e Importação Ltda.
Programa......: DIPM017.PRW
Objetivo......:

Autor.........: Jailton B Santos, JBS
Data..........: 20 Jun 2006

Versão........: 1.0
Consideraçoes.: Função chamada direto do menu ->U_DipM017()

------------------------------------------------------------------------------------
*/
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
*-------------------------------*
User Function DipM017()
*-------------------------------*
Local bOk:={|| If(A031('PEDIDO').and.A031('SERIE'),(nOpcao:=1,oDlg:End()),nOpcao:=0)}
Local bCancel:={|| (nOpcao := 0, oDlg:End())}
Local oDlg
Local oBt1
Local oBt2
Local nOpcao := 0
Local nTotal := 0

Private cNumPed := CriaVar("C5_NUM",.F.)
Private cNumNot := CriaVar("F2_DOC",.F.)
Private cSerNot := "1  "
Private nValPre := CriaVar("F2_VALMERC",.F.)
Private nValNot := CriaVar("F2_VALMERC",.F.)
Private cChaPre := space(20)
Private cChaNot := space(20)

Private cfilSC5 := xFilial('SC5')
Private cfilSC9 := xFilial('SC9')
Private cFilSDC := xFilial('SDC')
Private cFilSF2 := xFilial('SF2')

U_DIPPROC(ProcName(0),U_DipUsr()) // MCVN - 22/01/2009

Define msDialog oDlg title OemToAnsi("Checando a Chave da Nota e Pre-Nota") From 09,10 TO 25,45

@ 002,002 to 103,136 pixel
@ 010,010 say "Numero do Pedido" Pixel
@ 020,010 say "Numero da Nota"   Pixel
@ 030,010 say "Serie da nota"    Pixel
@ 040,010 say "Valor Pre-Nota"   Pixel
@ 050,010 say "Valor Nota Fis"   Pixel
@ 060,010 say "Chave Pre-Nota"   Pixel
@ 070,010 say "Chave Nota"       Pixel

@ 010,060 get oPed var cNumPed valid A031('PEDIDO') Size 40,08 pixel
@ 020,060 get oNot var cNumNot valid A031('NOTA')   Size 40,08 pixel
@ 030,060 get oSer var cSerNot valid A031('SERIE')  Size 10,08 pixel
@ 040,060 get oPre var nValPre when .f. picture "@e 999,999,999.99" Size 40,08 pixel
@ 050,060 get oVNF var nValNot when .f. picture "@e 999,999,999.99" Size 40,08 pixel
@ 060,060 get oChP var cChaPre when .f. Size 40,08 pixel
@ 070,060 get oChN var cChaNot when .f. Size 40,08 pixel

Define sbutton oBt1 from 108,079 type 1 action Eval(bOK) enable of oDlg
Define sbutton oBt2 from 108,109 type 2 action Eval(bCancel) enable of oDlg

Activate Dialog oDlg Centered

Return(.t.)

*---------------------------------------------*
Static Function A031(cCampo)
*---------------------------------------------*
Local lRetorno := .f.

Do Case
	Case cCampo == 'PEDIDO'
		
		SC5->(dbSetOrder(1))
		If !(lRetorno := SC5->(dbSeek(xFilial('SC5')+cNumPed)))
			msgInfo('Pedido não cadastrado','Atenção')
		Else
			SC9->(dbsetOrder(1))
			If SC9->(DbSeek(cfilSC9+SC5->C5_NUM))
				nValPre := 0
				SC9->(dbEval({|| nValPre += NoRound(SC9->C9_QTDLIB * SC9->C9_PRCVEN,2)},,{|| SC9->(!EOF()) .AND. cFilSC9 == SC9->C9_FILIAL .AND. SC9->C9_PEDIDO == SC5->C5_NUM}))
				cChaPre := AllTrim(Transform(Val(Embaralha(StrZero(int(nValPre),9),0)),"@E 999,999,999"))
				oPre:Refresh()
				oChP:Refresh()
			EndIf
		EndIf
		
	Case cCampo == 'NOTA'

		SF2->(dbSetorder(1))

		If !(lRetorno := SF2->(dbseek(xFilial('SF2')+cNumNot)))
			msgInfo('Nota Fiscal não encontrada','Atenção')
		Else
			cChaNot := AllTrim(Transform(Val(Embaralha(StrZero(int(SF2->F2_VALMERC),9),0)),"@E 999,999,999"))
			nValNot := SF2->F2_VALMERC
			oChN:Refresh()
			oVNF:Refresh()
		EndIf
		
	Case cCampo == 'SERIE'
		
		SF2->(dbSetorder(1))
		If !(lRetorno := SF2->(dbseek(xFilial('SF2')+cNumNot+cSerNot)))
			msgInfo('Nota Fiscal não encontrada','Atenção')
		Else
			cChaNot := AllTrim(Transform(Val(Embaralha(StrZero(int(SF2->F2_VALMERC),9),0)),"@E 999,999,999"))
			nValNot := SF2->F2_VALMERC
			oChN:Refresh()
			oVNF:Refresh()
		EndIf
EndCase
Return(lRetorno)

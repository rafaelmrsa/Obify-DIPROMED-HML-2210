/*---------------------------------------------------------------------------------------*

Empresa.......: DIPOMED Comércio e Importação Ltda.
Programa......: DIPA029.PRW
Objetivo......: Permitir que o usuario acerte formulario de notas impressos
incorretamentes.

Autor.........: Jailton B Santos (JBS), Analista de Sistemas.
Data..........: 11 Jul 2005
Versão........: 1.0

*---------------------------------------------------------------------------------------*/
#include "rwmake.ch"

User Function DIPA029()
Local oDlg                                   // JBS 07/07/2005
Local nOpcao := 0                            // JBS 07/07/2005
Local bOK    := {|| If(A029GRVFRM(),(nOpcao := 1, oDlg:End()),)} // JBS 07/07/2005
Local bCancel:= {|| nOpcao := 0, oDlg:End()} // JBS 07/07/2005

Private cNF     := Space(len(SF2->F2_DOC))
Private cSerie  := Space(len(SF2->F2_SERIE))
Private cFormAtI:= Space((len(SF2->F2_NFFORM)-1)/2)// JBS 11/07/2005
Private cFormAtF:= Space((len(SF2->F2_NFFORM)-1)/2)// JBS 11/07/2005
Private cNfFormI:= Space((len(SF2->F2_NFFORM)-1)/2)// JBS 07/07/2005
Private cNfFormF:= Space((len(SF2->F2_NFFORM)-1)/2)// JBS 07/07/2005

U_DIPPROC(ProcName(0),U_DipUsr()) // JBS 05/10/2005 - Gravando o nome do Programa no SZU

Do While .T.
	Define msDialog oDlg Title "Acerto de Formulario de Nota Fiscal" From 10,10 TO 23,51
	
	cNF     := Space(len(SF2->F2_DOC))
	cSerie  := Space(len(SF2->F2_SERIE))
	cNfFormI:= Space((len(SF2->F2_NFFORM)-1)/2)
	cNfFormF:= Space((len(SF2->F2_NFFORM)-1)/2)
	cFormAtI:= Space((len(SF2->F2_NFFORM)-1)/2)
	cFormAtF:= Space((len(SF2->F2_NFFORM)-1)/2)
	
	@ 010,002 to 097,126
	@ 065,002 to 097,126
	
	@ 020,010 say "Nota Fiscal"
	@ 030,010 say "Serie"
	@ 040,010 say "Formulário inicial atual"
	@ 050,010 say "Formulário final atual"
	@ 073,010 say "Novo Formulario Inicial"
	@ 083,010 say "Novo Formulario Final"
	
	@ 065,130 BUTTON "&Grava" SIZE 30,30 ACTION (A029GRVFRM())
	
	@ 020,080 Get cNF      when .t. valid !Empty(cNF) Size 40,08
	@ 030,080 Get cSerie   when .t. valid A029NF() Size 20,08
	@ 040,080 Get cFormAtI when .f. Size 40,08
	@ 050,080 Get cFormAtF when .f. Size 20,08
	@ 073,080 Get cNfFormI when .T. Size 40,08
	@ 083,080 Get cNfFormF when .T. Size 40,08
	
	Activate Dialog oDlg Centered on init EnchoiceBar(oDlg,bOk,bCancel)
	Exit
Enddo
Return
*---------------------------------------------*
Static Function A029NF()
// JBS 11/07/2005 - Posiciona na NF Informada
*---------------------------------------------*
Local lRetorno := .T.
SF2->(dbSetOrder(1))
If SF2->(dbSeek(xFilial("SF2")+cNF+cSerie))
	cFormAtI := SubStr(SF2->F2_NFFORM,1,6)
	cFormAtF := SubStr(SF2->F2_NFFORM,8,6)
Else
	msginfo(;
	"Numero e Serie de Nota Fiscal não" +chr(13)+chr(10)+;
	"encontrados no Banco de Dados."+chr(13)+chr(10)+chr(13)+chr(10)+;
	"Por favor, informe o numero a e serie"+chr(13)+chr(10)+;
	"corretos da Nota Fiscal.          ","Atenção")
	lRetorno := .F.
EndIf
Return(lRetorno)
*---------------------------------------------*
Static Function A029GRVFRM()
// JBS 11/07/2005 - Posiciona na NF Informada
*---------------------------------------------*
Local lRetorno := .T.
Do Case
	Case Empty(cNF)
		MsgInfo("Numero da nota fiscal não informado!","Atenção")
		lRetorno := .F.
		
	Case Empty(cSerie)
		MsgInfo("Serie da nota fiscal não informada!","Atenção")
		lRetorno := .F.
		
	Case Empty(cNfFormI)
		MsgInfo("Nro do formulário inicial não informado!","Atenção")
		lRetorno := .F.
		
	Case Empty(cNfFormF)
		MsgInfo("Nro do formulário final não informado!","Atenção")
		lRetorno := .F.
		
	OtherWise
		SF2->(RecLock("SF2",.F.))
		SF2->F2_NFFORM := cNfFormI+"/"+cNfFormF
		SF2->(MsUnlock("SF2"))
		cNF     := Space(len(SF2->F2_DOC))
		cSerie  := Space(len(SF2->F2_SERIE))
		cNfFormI:= Space((len(SF2->F2_NFFORM)-1)/2)
		cNfFormF:= Space((len(SF2->F2_NFFORM)-1)/2)
		cFormAtI:= Space((len(SF2->F2_NFFORM)-1)/2)
		cFormAtF:= Space((len(SF2->F2_NFFORM)-1)/2)
EndCase
Return(lRetorno)

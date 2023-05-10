#INCLUDE "PROTHEUS.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณORDSEP11  บAutor  ณMicrosiga           บ Data ณ  12/12/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function DIP100Vs(cAlias,nReg,nOpcx)
Local oDlg
Local oGet

Local cSeekCB8  := CB8->(xFilial("CB8")) + CB7->CB7_ORDSEP
Local aSize     := {}
Local aInfo     := {}
Local aObjects  := {}
Local aObj      := {}
Local aButtons  := {}
Local lEmbal    := ("01" $ CB7->CB7_TIPEXP) .OR. ("02" $ CB7->CB7_TIPEXP)

Private oTimer
Private Altera  := .F.
Private Inclui  := .F.
Private aHeader := {}
Private aCols   := {}
Private aTela   := {},aGets := {}

Private cBmp1 := "PMSEDT3" //"PMSDOC"  //"FOLDER5" //"PMSMAIS"  //"SHORTCUTPLUS"
Private cBmp2 := "PMSDOC" //"PMSEDT3" //"FOLDER6" //"PMSMENOS" //"SHORTCUTMINUS"

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Verifica se existe algum dado no arquivo de Itens            ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
SX3->(DbSetOrder(1))
CB8->(DbSetOrder(1))
If ! CB8->( dbSeek( cSeekCB8 ) )
	Return .T.
EndIf

If lEmbal
	aadd(aButtons, {'AVGBOX1',{||MsgRun("Carregando consulta, aguarde...","Ordem de Separa็ใo",{|| DipConEmb(aHeader,aCols) })},"Embalagens","Embalagens"})
Endif
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Adiciona botoes do usuario na EnchoiceBar                              ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If ExistBlock( "ACD100BUT" )
	If ValType( aUsButtons := ExecBlock( "ACD100BUT", .F., .F., {nOpcx} ) ) == "A"
		AEval( aUsButtons, { |x| AAdd( aButtons, x ) } )
	EndIf
EndIf

RegToMemory("CB7")

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Monta o cabecalho                                            ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

dbSelectArea("SX3")
dbSeek( "CB8" )
While !Eof() .And. ( x3_arquivo == "CB8" )
	If X3USO(x3_usado) .And. cNivel >= x3_nivel .And. AllTrim( x3_campo ) <> "CB8_ORDSEP"
		AAdd(aHeader,{ TRIM(x3_titulo), x3_campo, x3_picture,;
		x3_tamanho, x3_decimal, x3_valid,;
		x3_usado, x3_tipo, x3_arquivo, x3_context } )
	EndIf
	dbSkip()
EndDo

U_MonCols(cSeekCB8)

aSize   := MsAdvSize()
aAdd(aObjects, {100, 130, .T., .F.})
aAdd(aObjects, {100, 200, .T., .T.})
aInfo   := {aSize[1], aSize[2], aSize[3], aSize[4], 2, 2}
aPosObj := MsObjSize(aInfo, aObjects)

DEFINE MSDIALOG oDlg TITLE OemToAnsi("Ordens de separacao - Visualizacao") From aSize[7],0 to aSize[6],aSize[5] OF oMainWnd PIXEL
oEnc:=MsMget():New(cAlias,nReg,nOpcx,,,,,{aPosObj[1,1],aPosObj[1,2],aPosObj[1,3],aPosObj[1,4]},,3,,,,,,.t.)
oGet:=MSGetDados():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,3],aPosObj[2,4], nOpcx,"AllWaysTrue","AllWaysTrue", ,.F.)

DEFINE TIMER oTimer INTERVAL 1000 ACTION U_MonCols(cSeekCB8,oGet) OF oDlg
oTimer:Activate()

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||nOpca:=1,oDlg:End()},{||oDlg:End()},,aButtons)

Return
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออออหอออออออัออออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ ConsEmb         บ Autor ณ       Totvs          บ Data ณ  06/06/09   บฑฑ
ฑฑฬออออออออออุอออออออออออออออออสอออออออฯออออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Rotina de consulta de embalagens                                    บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function DipConEmb()

Local oDlgVol
Local aButtons := {}
Local aSize	   := MsAdvSize()
Local lTemVol  := .f.
Local lEncEtap := .T.
Local nI	   := 0
Local oPanEsq
Local oPanDir
Local oPanelCB3
Local oTreeVol
Local oEncCB3
Local oEncCB6
Local oEncCB9

Private aVolumes := {}
Private aSubVols := {}

CB9->(DbSetOrder(1))
CB9->(DbSeek(xFilial("CB9")+CB7->CB7_ORDSEP))
While CB9->(!Eof() .AND. CB9_FILIAL+CB9_ORDSEP == xFilial("CB9")+CB7->CB7_ORDSEP)
	If !Empty(CB9->CB9_VOLUME)
		lTemVol  := .t.
		Exit
	Endif
	CB9->(DbSkip())
Enddo

If !lTemVol
	MsgStop("Volumes nใo encontrados!")
	Return
Endif

DEFINE MSDIALOG oDlgVol TITLE "Consulta de volumes - Ordem de Separa็ใo: "+CB7->CB7_ORDSEP FROM aSize[07],0 TO aSize[06],aSize[05] PIXEL //OF oMainWnd PIXEL //"Consulta de volumes - Ordem de Separa็ใo: "

	@ 000,000 SCROLLBOX oPanEsq  HORIZONTAL SIZE 200,270 OF oDlgVol BORDER
	oPanEsq:Align := CONTROL_ALIGN_LEFT

	oTreeVol := DbTree():New(0, 0, 0, 0, oPanEsq,,,.T.)
	oTreeVol:bChange    := {|| DipAtuEnc(oTreeVol:GetCargo(),oPanelCB3,oEncCB3,oEncCB6,oEncCB9)}
	oTreeVol:blDblClick := {|| DipAtuEnc(oTreeVol:GetCargo(),oPanelCB3,oEncCB3,oEncCB6,oEncCB9)}
	oTreeVol:Align      := CONTROL_ALIGN_ALLCLIENT

	@ 000,000 MsPanel oPanDir  Of oDlgVol
	oPanDir:Align := CONTROL_ALIGN_ALLCLIENT
   
	oPanelCB3 := TPanel():New( 028, 072,,oPanDir, , , , , , 200, 80, .F.,.T. )
	oPanelCB3 :Align:= CONTROL_ALIGN_TOP
	oPanelCB3:Hide()
   
	oEncCB3 := MsMGet():New("CB3",1,2,,,,,{015,002,100,100},,,,,,oPanelCB3,,,.F.,nil,,.T.)
	oEncCB3:oBox:Align := CONTROL_ALIGN_ALLCLIENT
	oEncCB3:Hide()

	oEncCB6 := MsMGet():New("CB6",1,2,,,,,{015,002,100,100},,,,,,oPanDir,,,.F.,nil,,.T.)
	oEncCB6:oBox:Align := CONTROL_ALIGN_ALLCLIENT
	oEncCB6:Hide()

	oEncCB9 := MsMGet():New("CB9",1,2,,,,,{015,002,100,100},,,,,,oPanDir,,,.F.,nil,,.T.)
	oEncCB9:oBox:Align := CONTROL_ALIGN_ALLCLIENT
	oEncCB9:Hide()

	DipAtuTree(oPanelCB3,oTreeVol,oPanelCB3,oEncCB3,oEncCB6,oEncCB9)

ACTIVATE MSDIALOG oDlgVol ON INIT EnchoiceBar(oDlgVol,{||oDlgVol:End()},{||oDlgVol:End()},,aButtons) CENTERED

Return
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออออหอออออออัออออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ AtuTreeVol      บ Autor ณ       Totvs          บ Data ณ  06/06/09   บฑฑ
ฑฑฬออออออออออุอออออออออออออออออสอออออออฯออออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Rotina de atualizacao do Tree de consulta de volumes                บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function DipAtuTree(oPanelCB3,oTreeVol,oPanelCB3,oEncCB3,oEncCB6,oEncCB9)
Local aAreaCB9 := CB9->(GetArea())
Local cDescItem
Local cSubVolAtu
Local nPosVol
Local lFechaTree
Local nX, nY

aVolumes := {}
CB9->(DbSetOrder(1))
CB9->(DbSeek(xFilial("CB9")+CB7->CB7_ORDSEP))
While CB9->(!Eof() .AND. CB9_FILIAL+CB9_ORDSEP == xFilial("CB9")+CB7->CB7_ORDSEP)
	If !Empty(CB9->CB9_VOLUME)
		nPosVol   := Ascan(aVolumes,{|x| x[01] == CB9->CB9_VOLUME})
		cDescItem := CB9->CB9_PROD+If(!Empty(CB9->CB9_LOTECTL)," - Lote: "+CB9->CB9_LOTECTL,"")+If(!Empty(CB9->CB9_NUMLOT)," - SubLote: "+CB9->CB9_NUMLOT,"")+If(!Empty(CB9->CB9_NUMSER)," - Num.Serie: "+CB9->CB9_NUMSER,"")
		If nPosVol == 0
			aadd(aVolumes,{CB9->CB9_VOLUME,{}})
			nPosVol := Len(aVolumes)
		Endif
		aadd(aVolumes[nPosVol,02],{CB9->CB9_SUBVOL,CB9->CB9_PROD,cDescItem,CB9->CB9_LOTECTL,CB9->CB9_NUMLOT,CB9->CB9_NUMSER,StrZero(CB9->(Recno()),10)})
	Endif
	CB9->(DbSkip())
Enddo

//Reorganiza a array de volumes e subvolumes:
aSort(aVolumes,,,{|x,y| x[01]<y[01]})
For nX:=1 to Len(aVolumes)
	aSort(aVolumes[nX,02],,,{|x,y| x[01]+x[04]+x[05]+x[06]<y[01]+y[04]+y[05]+y[06]})
Next

oTreeVol:BeginUpdate()
oTreeVol:Reset()

For nX:=1 to Len(aVolumes)
	oTreeVol:AddTree("Volume: "+aVolumes[nX,01]+Space(70),.F.,cBmp1,cBmp1,,,aVolumes[nX,01]+Space(35))
	cSubVolAtu := ""
	For nY:=1 to Len(aVolumes[nX,02])
		If !Empty(aVolumes[nX,02,nY,01]) .AND. Empty(cSubVolAtu)
			cSubVolAtu := aVolumes[nX,02,nY,01]
		ElseIf !Empty(aVolumes[nX,02,nY,01]) .AND. !Empty(cSubVolAtu) .AND. (cSubVolAtu<>aVolumes[nX,02,nY,01])
			oTreeVol:EndTree()
			cSubVolAtu := aVolumes[nX,02,nY,01]
			lFechaTree := .f.
		Endif
		If Empty(aVolumes[nX,02,nY,01])
			//Adiciona produto no volume:
			oTreeVol:AddTreeItem(aVolumes[nX,02,nY,03],cBmp2,,aVolumes[nX,01]+Space(10)+aVolumes[nX,02,nY,02]+aVolumes[nX,02,nY,07])
		ElseIf !oTreeVol:TreeSeek(AllTrim(aVolumes[nX,01]+aVolumes[nX,02,nY,01]))
			//Adiciona subvolume:
			oTreeVol:AddTree("SubVolume: "+aVolumes[nX,02,nY,01]+Space(60),.F.,cBmp1,cBmp1,,,aVolumes[nX,01]+aVolumes[nX,02,nY,01]+Space(25)) 
			lFechaTree := .t.
			//Adiciona produto no subvolume:
			oTreeVol:AddTreeItem(aVolumes[nX,02,nY,03],cBmp2,,aVolumes[nX,01]+aVolumes[nX,02,nY,01]+aVolumes[nX,02,nY,02]+aVolumes[nX,02,nY,07])
		Else
			//Adiciona produto no subvolume:
			oTreeVol:AddTreeItem(aVolumes[nX,02,nY,03],cBmp2,,aVolumes[nX,01]+aVolumes[nX,02,nY,01]+aVolumes[nX,02,nY,02]+aVolumes[nX,02,nY,07])
		Endif
		oTreeVol:TreeSeek("")
	Next
	If lFechaTree
		oTreeVol:EndTree()
		lFechaTree := .f.
	Endif
	oTreeVol:EndTree()
Next

oTreeVol:EndUpdate()
oTreeVol:Refresh()
oTreeVol:TreeSeek("")

DipAtuEnc(oTreeVol:GetCargo(),oPanelCB3,oEncCB3,oEncCB6,oEncCB9)  //Atualiza enchoice direita

RestArea(aAreaCB9)
Return
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออออหอออออออัออออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ DipAtuEnc       บ Autor ณ       Totvs          บ Data ณ  06/06/09   บฑฑ
ฑฑฬออออออออออุอออออออออออออออออสอออออออฯออออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Funcao de atualizacao da enchoice                                   บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function DipAtuEnc(cCargoAtu,oPanelCB3,oEncCB3,oEncCB6,oEncCB9)
Local nTamVol    := TamSX3("CB9_VOLUME")[01]
Local nTamSubVol := TamSX3("CB9_SUBVOL")[01]
Local cVolume

If Len(AllTrim(cCargoAtu)) == nTamVol .OR. Len(AllTrim(cCargoAtu)) == (nTamVol+nTamSubVol)  //Volume ou Subvolume
	CB6->(DbSetOrder(1))
	cVolume := If(Len(AllTrim(cCargoAtu))==nTamVol,AllTrim(cCargoAtu),SubStr(cCargoAtu,nTamVol+1,nTamSubVol))
	CB6->(DbSeek(xFilial("CB6")+cVolume))
	CB3->(DbSetOrder(1))
	CB3->(DbSeek(xFilial("CB3")+CB6->CB6_TIPVOL))
	oEncCB9:Hide()
	oEncCB3:Refresh()
	oEncCB6:Refresh()
	oPanelCB3:Show()
	oEncCB3:Show()
	oEncCB6:Show()
Else
	CB9->(Dbgoto(Val(Right(cCargoAtu,10))))
	oEncCB3:Hide()
	oEncCB6:Hide()
	oPanelCB3:Hide()
	oEncCB9:Refresh()
	oEncCB9:Show()
Endif

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno    ณACDA100Lg ณ Autor ณ Eduardo Motta         ณ Data ณ 06/04/01 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescrio ณ Legenda para as cores da mbrowse                           ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณRetorno   ณ .T.                                                        ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUso       ณ SIGAACD                                                    ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function DIPA100Lg()
Local aCorDesc         

aCorDesc := {	{ "BR_VERMELHO",	"- Nao iniciado" 			},;     
				{ "BR_LARANJA",		"- Separacao iniciada"		},;
				{ "BR_PRETO_1",		"- Separacao em pausa"		},;
				{ "BR_AMARELO",		"- Separacao finalizada"	},;
				{ "BR_BRANCO",		"- Conferencia iniciada"	},;
				{ "BR_PRETO_2",		"- Conferencia em pausa"	},;
				{ "BR_VIOLETA", 	"- Conferencia finalizada"	},;
				{ "BR_PINK", 		"- NF Gerada"				},;        
				{ "BR_AZUL",   		"- Embarque Iniciado"		},;
				{ "BR_PRETO_3", 	"- Embarque em pausa"		},;
				{ "BR_VERDE", 		"- Embarque Finalizado" 	}}

BrwLegenda( "Legenda - Separacao", "Status", aCorDesc )
Return( .T. )
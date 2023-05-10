#Include "PROTHEUS.CH"
#Include "RWMAKE.CH"
         
#DEFINE	_UA4	1
#DEFINE	_UA1	2

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DIPAL20   ºAutor  ³William Ailton Mafraº Data ³  09/30/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³  Entrada de Valores                                        º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
*--------------------------------------------*
User Function DIPAL20(cAlias,nReg,nOpcx)
*--------------------------------------------*
Local aTitles    := {"Produtos"}
Local aArea 	:= GetArea()
Local oDlg

Local cCadastro := "Entrada de Valores"
Local aObjects  := {}                                	
Local aSize  := MsAdvSize(.T.)
Local nCntFor	:= 1
Local nCntFor2	:= 1
//Altura,Largura da janela
Local nWndAlt	:= 0
Local nWndLar	:= 0
Local aButtons := {}
Local cAux		:=	""
// campos que nao serao mostrados UA1,UA2,UA3,UA4
Local aUnused	:= {{"UA4_EDITAL",  "UA4_DETPRO", "UA4_VALMIN", "UA4_PROCLI", "UA4_ULTPRE", "UA4_ULTCOM", "UA4_VENCEU","UA4_OBS","UA4_SALDO","UA4_QTDENT","UA4_ITEMLT","UA4_LOTE","UA4_ITEMAM"},; //UA4
					{"UA1_FILIAL","UA1_STATUS","UA4_FORNEC","UA4_XPEDID"}}		//UA1

// campos que serao mostrados UA1,UA2,UA3,UA4
Local aUsed		:= {{},; //UA4
					{}}  //UA1

Local nOpcA		:= 0       
Local nOpt		:= GD_UPDATE

//Tab atual
private nTabPos	:= 1

PRIVATE aGETS   := {}
PRIVATE aTELA   := {}

Private oGetDados

private aHeader	:= {}
private aCols	:= {}

U_DIPPROC(ProcName(0),U_DipUsr()) // MCVN 22/01/2009

IF UA4->( !dbSeek(xFilial("UA4") + UA1->UA1_CODIGO))
	Alert("Edital sem nenhum produto cadastrado!")
	Return (.F.)
EndIF

/*If Upper(U_DipUsr()) $ 'ERIBERTO/MAXIMO/CLEIA' 
	If UA1->UA1_ACERTO <> 'S'
		If MsgYesNo("Acerto de EDITAL ?","Aten‡„o")
			RecLock("UA1",.F.)
			UA1->UA1_ACERTO := 'S'
			UA1->( MsUnLock()  ) 
		Endif	
	Else     
		If !(MsgYesNo("Este edital está marcado como acerto!! Confirma?","Aten‡„o"))
			RecLock("UA1",.F.)
			UA1->UA1_ACERTO := ''
			UA1->( MsUnLock()  ) 		
		Endif
	Endif
Endif                      */

//If UA1->UA1_ACERTO <> 'S'
	IF Empty(UA1->UA1_FINANC)
		Alert("Edital ainda não avaliado pelo Departamento Financeiro!")
		Return (.F.)
	EndIF
//Endif
RegToMemory(cAlias,.F.)
RegToMemory("UA4",.F.)

nWndLar := (aSize[5]  - (aSize[5] * 0.15)) - (aSize[5] / 6)
nWndLar /= 2
nWndAlt := (aSize[6]  - aSize[7]) / 2

aAdd( aObjects, { nWndLar - 3 , (nWndAlt  / 2) - (nWndAlt * 0.15) ,.F.,.F. } )
aAdd( aObjects, { nWndLar , nWndAlt - aObjects[1,2] , .F.,.F. } )
aInfo    := { aSize[1],aSize[2],aSize[3],aSize[4], 3, 3 }
aPosObj  := MsObjSize( aInfo, aObjects,.T. )


AADD(aUsed[_UA1],"NOUSER")
SX3->(dbSetOrder(1))
SX3->(dbSeek("UA1"))
While ( !SX3->( Eof() ) .And. SX3->X3_ARQUIVO == "UA1" )
	If ( X3USO(SX3->X3_USADO) .And. cNivel >= SX3->X3_NIVEL .And.;
		ASCAN(aUnused[_UA1],SX3->X3_CAMPO) < 1)
		AADD(aUsed[_UA1],SX3->X3_CAMPO)
	EndIf
	SX3->(dbSkip())
EndDo

DEFINE MSDIALOG oDlg TITLE cCadastro From aSize[7], aSize[5] / 6 To aSize[6] - (aSize[6] * 0.2), aSize[5] - (aSize[5] * 0.15) OF oMainWnd PIXEL
EnChoice( cAlias ,nReg, nOpcx, , , , aUsed[_UA1], aPosObj[1],{} , 3 )

dbSelectArea("UA4")
aHeader 	:= apBuildHeader("UA4",aUnused[_UA4])
UA4->( dbSetOrder(1) )
UA4->( dbSeek(xFilial("UA4") + UA1->UA1_CODIGO) )
Do While !UA4->( EOF()) .And. UA4->(UA4_FILIAL) == xFilial("UA4") .And. UA4->(UA4_EDITAL) == UA1->UA1_CODIGO
	AADD(aCols,Array(Len(aHeader) + 1))
	For nCntFor2 := 1 To Len(aHeader) 
		If ( aHeader[nCntFor2][10] != "V" )
			aCols[Len(aCols)][nCntFor2] := FieldGet(FieldPos(aHeader[nCntFor2][2]))
		Else
			aCols[Len(aCols)][nCntFor2] := CriaVar(aHeader[nCntFor2][2])                      
		EndIf
	
	Next nCntFor2
	aCols[Len(aCols)][Len(aHeader)+1] := .F.
	UA4->( dbSkip() )
EndDo
oGetDados := MSNewGetDados():New (aPosObj[2,1], aPosObj[2,2],;
nWndAlt - (aObjects[1,2] / 2) - (nWndAlt * 0.05), aPosObj[2,4] - 3 , If(nOpcx != 2, nOpt , 0) , , , , {"UA4_PRCVEN", "UA4_QUANT", "UA4_PRCMIN"}, , , , , ,oDlg, aHeader, aCols)

Aadd( aButtons, {"VENDEDOR", {|| u_DIP20Con() }, "Concorrentes", "Concorrentes" , {|| .T.}} )
ACTIVATE MSDIALOG oDlg CENTERED ON INIT (u_DIP20TG(), ;
EnchoiceBar(oDlg, {||nOpcA:=If(Obrigatorio(aGets,aTela), 1,0),If(nOpcA==1,oDlg:End(),Nil)},{||oDlg:End()},,@aButtons))
If ( nOpcx != 2 .And. nOpcA == 1 )
	u_DIP20Grv(nOpcx)
EndIf

RestArea(aArea)
Return(.T.)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DIPA010   ºAutor  ³William Ailton Mafraº Data ³  10/03/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Inclusao/alteracao/exclusao na Base de Dados                º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
*-----------------------------------------------------*
User Function DIP20Grv(nOpc)
*-----------------------------------------------------*
Local aArea     := GetArea()
Local nCntFor   := 0
Local nCntFor2  := 0
Local nUsado    := 0
Local aRegs := { }
     
UA4->( dbSetOrder(1) )
UA4->( dbSeek(xFilial("UA4")+M->UA1_CODIGO) )
Do While ( !UA4->( Eof() ).And. xFilial("UA4") == UA4->UA4_FILIAL .And.;
	M->UA1_CODIGO == UA4->UA4_EDITAL )
	aadd(aRegs,UA4->(RecNo()))
	UA4->( dbSkip() )
EndDo

if nOpc <> 5
	Begin Transaction
	nUsado  := Len(aHeader)
	For nCntFor := 1 To Len(oGetDados:aCols)
		If(!empty(oGetDados:aCols[nCntFor][1]))
			If ( nCntFor > Len(aRegs) )
				If ( !oGetDados:aCols[nCntFor][nUsado+1] )
					RecLock("UA4",.T.)
				EndIf
			Else
				UA4->(dbGoto(aRegs[nCntFor]))
				RecLock("UA4",.F.)
			EndIf
			If ( !oGetDados:aCols[nCntFor][nUsado+1] )
				For nCntFor2 := 1 To nUsado
					If ( aHeader[nCntFor2][10] != "V" )
						FieldPut(FieldPos(aHeader[nCntFor2][2]),oGetDados:aCols[nCntFor][nCntFor2])
					EndIf
				Next nCntFor2
			Else
				If ( nCntFor <= Len(aRegs) )
					UA4->( dbDelete() )
				EndIf
			EndIf
			UA4->( MsUnLock()  )
		EndIF
	Next nCntFor
	End Transaction

    ConfirmSX8()

EndIf   
//If UA1->UA1_ACERTO <> "S"
	u_DIPStat(.f.)
//Else  // Acerto MCVN - 12/03/2009
  //	RecLock("UA1",.F.)
  //	UA1->UA1_WFID   := "ACERTO"
//	UA1->UA1_WFLOW  := '4'
 //	UA1->UA1_STATUS := '4'
 //	UA1->UA1_VENDAS := 'ERICH-ACERTO'
 //	UA1->( MsUnLock()  ) 
//Endif
RestArea(aArea)
Return( .T. )

*-----------------------------------------------*
User Function DIP20TG()                          
*-----------------------------------------------*
Local nHItem
Local nAItem

aHeader := oGetDados:aHeader
aCols	:= oGetDados:aCols

For nAItem := 1 to Len(aCols)
	For nHItem := 1 to Len(aHeader)
		If ExistTrigger(aHeader[nHitem][2])
			RunTrigger(2, nAItem)
		EndIF
	Next nHItem
Next nAItem
oGetDados:ForceRefresh()
Return (.T.)




/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DIPAL20   ºAutor  ³Microsiga           º Data ³  10/25/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function DIP20Con()

Local aTitles    := {"Produtos"}
Local cProdut
Local cDProdu
Local aArea 	:= GetArea()
Local oDlg2
Local oGetDados2 
Local aHeader := {}
Local aCols := {}
Local nCntFor2 
Local nAux

nAux := aScan(oGetDados:aHeader,{|aVal| "PRODUT" $ aVal[2]})
cProdut := oGetDados:aCols[oGetDados:nAt,nAux]
nAux := aScan(oGetDados:aHeader,{|aVal| "DPRODU" $ aVal[2]})
cDProdu := oGetDados:aCols[oGetDados:nAt,nAux]

oDlg2 := MSDialog():New(00,00,385,705,"",,,,,,,,,.T.)

@15,10 To 35,350 Label Pixel OF oDlg2

@22,20 Say "Código do Produto" Pixel Of oDlg2
@20,70 MSGet cProdut Size 35,08 When .F. Pixel Of oDlg2

@22,120 Say "Descrição" Pixel Of oDlg2
@20,150 MSGet cDProdu Size 150,08 When .F. Pixel Of oDlg2

RegToMemory("UA5",.F.)

aHeader	:= apBuildHeader("UA5",{"UA5_PRODUT","UA5_DPRODU"})

DBSelectArea("UA5")
UA5->( dbSetOrder(4) )
UA5->( dbSeek(xFilial("UA5")+ cProdut) )
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³MONTA O ACOLS DA GETDADOS³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Do While UA5->(!EOF()) .And.;
         UA5->(UA5_FILIAL) == xFilial("UA5") .And.;
         UA5->UA5_PRODUT == cProdut
         
	AADD(aCols,Array(Len(aHeader) + 1))
	For nCntFor2 := 1 To Len(aHeader)
		If ( aHeader[nCntFor2][10] != "V" )
			aCols[Len(aCols)][nCntFor2] := FieldGet(FieldPos(aHeader[nCntFor2][2]))
		Else
			aCols[Len(aCols)][nCntFor2] := CriaVar(aHeader[nCntFor2][2])
		EndIf
	Next nCntFor2                        

	aCols[Len(aCols)][7] := aCols[Len(aCols)][4] * aCols[Len(aCols)][6]
	aCols[Len(aCols)][Len(aHeader)+1] := .F.
	UA5->(dbSkip())
EndDo

oGetDados2 := MSNewGetDados():New (40,10,180,350 , 0 , , , , , , , , , ,oDlg2, aHeader, aCols)

ACTIVATE MSDIALOG oDlg2 CENTERED ON INIT (EnchoiceBar(oDlg2, {||oDlg2:End()},{||oDlg2:End()}))

DBSelectArea("UA1")

Return (.T.)
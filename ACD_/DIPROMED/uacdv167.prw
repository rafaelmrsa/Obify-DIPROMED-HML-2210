#INCLUDE "ACDV167.CH" 
#INCLUDE "PROTHEUS.CH"
#INCLUDE "APVT100.CH"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Descri‡…o ³ PLANO DE MELHORIA CONTINUA                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ITEM PMC  ³ Responsavel              ³ Data         |BOPS:             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³      01  ³                          ³              |                  ³±±
±±³      02  ³Erike Yuri da Silva       ³13/03/2006    |00000094643       ³±±
±±³      03  ³                          ³              |                  ³±±
±±³      04  ³                          ³              |                  ³±±
±±³      05  ³                          ³              |                  ³±±
±±³      06  ³                          ³              |                  ³±±
±±³      07  ³                          ³              |                  ³±±
±±³      08  ³                          ³              |                  ³±±
±±³      09  ³                          ³              |                  ³±±
±±³      10  ³Erike Yuri da Silva       ³13/03/2006    |00000094643       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ ACDV167  ³ Autor ³ ACD                   ³ Data ³ 01/03/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Embalagem                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAACD                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/  
User Function UACDV167(_lSepAux)
Local aTela
Local nOpc
Private lDipEst  := .F.
Private _lSepCxF := .F. 
Public _cTipSald := ""  
DEFAULT _lSepAux := .F.

_lSepCxF := _lSepAux

If ACDGet170()
	Return ACDV167X(0)
EndIf
aTela := VtSave()
VTCLear()        
If _lSepCxF     
	nOpc := 1
ElseIf Vtmodelo()=="RF"
	@ 0,0 VTSAY "Embalagem" //"Embalagem"
	@ 1,0 VTSay "Selecione:" //"Selecione:"
	nOpc:=VTaChoice(3,0,6,VTMaxCol(),{"Ordem de Separacao","Pedido de Venda","Nota Fiscal"}) //"Ordem de Separacao"###"Pedido de Venda"###"Nota Fiscal"
ElseIf VtModelo()=="MT44"
	@ 0,0 VTSAY "Embalagem" //"Embalagem"
	@ 1,0 VTSay "Selecione:" //"Selecione:"
	nOpc:=VTaChoice(0,20,1,39,{"Ordem de Separacao","Pedido de Venda","Nota Fiscal"}) //"Ordem de Separacao"###"Pedido de Venda"###"Nota Fiscal"
ElseIf VtModelo()=="MT16"
	@ 0,0 VTSAY "Embalagem Selecione" //"Embalagem Selecione"
	nOpc:=VTaChoice(1,0,1,19,{"Ordem de Separacao","Pedido de Venda","Nota Fiscal"}) //"Ordem de Separacao"###"Pedido de Venda"###"Nota Fiscal"
EndIf

VtRestore(,,,,aTela)
If nOpc == 1 //-- por ordem de separacao
	U_ACDV167A()
ElseIf nOpc == 2 //-- por pedido de venda
	U_ACDV167B()
ElseIf nOpc == 3 //-- por Nota Fiscal
	U_ACDV167C()
EndIf 

Return 1            
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ACDV167A  ºAutor  ³Microsiga           º Data ³  11/07/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function ACDV167A()
ACDV167X(1)
Return  
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ACDV167B  ºAutor  ³Microsiga           º Data ³  11/07/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function ACDV167B()
ACDV167X(2)
Return      
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ACDV167C  ºAutor  ³Microsiga           º Data ³  11/07/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function ACDV167C()
ACDV167X(3)
Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ACDV167X  ºAutor  ³Microsiga           º Data ³  11/07/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ACDV167X(nOpc)
Local ckey09  := VTDescKey(09)
Local ckey22  := VTDescKey(22)
Local ckey24  := VTDescKey(24)
Local bkey09  := VTSetKey(09)
Local bkey22  := VTSetKey(22)
Local bkey24  := VTSetKey(24)
Local cChave  := ""
Private cCodOpe    := CBRetOpe()
Private cImp       := CBRLocImp("MV_IACD01")
Private cPictQtdExp:= PesqPict("CB8","CB8_QTDORI")
Private cVolume    := Space(10)
Private lForcaQtd  := GetMV("MV_CBFCQTD",,"2") =="1"

VTClearBuffer()

If Type('cOrdSep')=='U'
	Private cOrdSep := Space(6)
EndIf

If Empty(cCodOpe)
	VTAlert("Operador nao cadastrado","Aviso",.T.,4000,3) //"Operador nao cadastrado"###"Aviso"
	Return 10 //-- valor necessario para finalizar o acv170
EndIf

CB5->(DbSetOrder(1))
If !CB5->(DbSeek(xFilial("CB5")+cImp))  //-- cadastro de locais de impressao
	VtBeep(3)
	VtAlert("O conteudo informado no parametro MV_IACD01 deve existir na tabela CB5.","Aviso",.t.) //"O conteudo informado no parametro MV_IACD01 deve existir na tabela CB5."###"Aviso"
	Return 10 //-- valor necessario para finalizar o acv170
EndIf

//-- Verifica se foi chamado pelo programa ACDV170 e se ja foi Embalado
If ACDGet170() .AND. CB7->CB7_STATUS >= "4"
	If !A170SLProc() .OR. !("02" $ CB7->CB7_TIPEXP)
		//-- Nao eh necessario  liberar o semaforo pois ainda nao criou nada
		Return 1
	EndIf
	//-- Ativa/Destativa a tecla avanca e retrocesa
	A170ATVKeys(.t.,.f.)	 //-- Ativa tecla avanca e desativa tecla retrocede
ElseIf ACDGet170() .AND. !("02" $ CB7->CB7_TIPEXP)
	Return 1
ElseIf ACDGet170()
	//-- Desativa a  tecla  avanca
	A170ATVKeys(.f.,.t.)
EndIf

VTClear()
If	VtModelo()=="RF"
	@ 0,0 VtSay "Embalagem" //"Embalagem"
EndIf         

If _lSepCxF
	VldCodSep()
Else
	If !DipSolCB7(nOpc,{|| VldCodSep()})
		Return 10
	EndIf
EndIf

//-- Ver se o codigo de separacao devera vir do programa anterior.
If	(ACDGet170() .And. CB7->CB7_STATUS >= "4") .Or. CB7->CB7_STATUS == "4" .Or. ;
	("02" $ CBUltExp(CB7->CB7_TIPEXP) .And. CB7->CB7_STATUS == "9")
	
	cChave := "Fat_"+cEmpAnt+cFilAnt+"_"+AllTrim(CB7->CB7_PEDIDO)
	If LockByName(cChave,.T.,.T.)
		
		VTAlert("Processo de embalagem finalizado","Aviso",.t.,4000) //"Processo de embalagem finalizado"###"Aviso"
		If	VTYesNo("Deseja estornar os produtos embalados ?","Atencao",.T.) //"Deseja estornar os produtos embalados ?"###"Atencao"
			VTSetKey(09,{|| Informa()},"Informacoes") //"Informacoes"
			Estorna()
			VTSetKey(09,bkey09,cKey09)
		EndIf
		
		UnLockByName(cChave,.T.,.T.)
	Else
		VtAlert("Pedido sendo faturado","Aviso",.t.)		
	EndIf
	
	Return FimProcEmb()
EndIf


InicProcEmb()
//-- Informa os volumes
While ! Volume()
	Return FimProcEmb()
EndDo

//-- Ativa teclas de atalho
VTSetKey(09,{|| Informa()},"Informacoes") //"Informacoes"
VTSetKey(24,{|| Estorna()},"Estorna") //"Estorna"
VTSetKey(22,{|| Volume()}, "Volume") //"Volume"

While .T.
	If !Embalagem()
		Exit
	EndIf
	CB9->(DBSetOrder(2))
	If ! CB9->(DBSeek(xFilial("CB9")+cOrdSep+Space(10)))
		If ExistBlock("V167EMBALA")
			ExecBlock("V167EMBALA",.F.,.F.)
		EndIf
		Exit
	EndIf
EndDo

//-- Restaura teclas
VTSetKey(09,bkey09,cKey09)
VTSetKey(22,bkey22,cKey22)
VTSetKey(24,bkey24,cKey24)
Return FimProcEmb()
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³Embalagem ³ Autor ³ ACD                   ³ Data ³ 03/01/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Realiza o Processo de Embalagem                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAACD                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Embalagem()
Local cSubVolume := Space(10)
Local cEtiqProd
Local cProduto
Local lRetAgain :=.f.
Private lEmbala :=.t.
Public _nDipQtde

VTSetKey(09,nil)

CB9->(DBSetOrder(2))
VTClear()
If VtModelo()=="RF"
	@ 0,0 VTSay "Embalagem" //"Embalagem"
	@ 1,0 VTSay "Volume :"+cVolume //"Volume :"
	If '01' $ CB7->CB7_TIPEXP  //-- trabalha com sub-volume
		cSubVolume := Space(10)
		@ 04,00 VtSay "Sub-volume a embalar" //"Sub-volume a embalar"
		@ 05,00 VtGet cSubVolume Picture "@!" Valid VldSubVol(cSubVolume)
	Else
		_nDipQtde := 0
		cProduto   := Space(48)
		If ! Usacb0("01")
			@ 3,0 VTSay "Qtde " VtGet _nDipQtde pict cPictQtdExp valid VldQtde(_nDipQtde) when (lForcaQtd .or. VTLastkey() == 5) //"Qtde "
		EndIf
		@ 4,0 VTSay "Leia o produto" //"Leia o produto"
		@ 5,0 VtSay "a embalar" //"a embalar"
		@ 6,0 VTGet cProduto pict '@!' VALID VTLastkey() == 5 .or. VldProdEmb(cProduto,_nDipQtde,NIL,NIL)
	EndIf
ElseIf VtModelo()=="MT44"
	If '01' $ CB7->CB7_TIPEXP  //-- trabalha com sub-volume
		cSubVolume := Space(10)
		@ 0,0 VTSay "Embalagem Volume:"+cVolume //"Embalagem Volume:"
		@ 1,0 VtSay "Sub-volume a embalar"  VtGet cSubVolume Picture "@!" Valid VldSubVol(cSubVolume) //"Sub-volume a embalar"
	Else
		_nDipQtde := 1
		cProduto   := Space(48)
		@ 0,0 VTSay "Vol:"+cVolume //"Vol:"
		If ! Usacb0("01")
			@ 0,18 VTSay "Qtde " VtGet _nDipQtde pict cPictQtdExp valid VldQtde(_nDipQtde) when (lForcaQtd .or. VTLastkey() == 5) //"Qtde "
		EndIf
		@ 1,0 VTSay "Produto a embalar" VTGet cProduto pict '@!' VALID VTLastkey() == 5 .or. VldProdEmb(cProduto,_nDipQtde,NIL,NIL) //"Produto a embalar"
	EndIf
ElseIf VtModelo()=="MT16"
	If '01' $ CB7->CB7_TIPEXP  //-- trabalha com sub-volume
		cSubVolume := Space(10)
		@ 0,0 VTSay "Volume :"+cVolume //"Volume :"
		@ 1,0 VtSay "Sub-volume"  VtGet cSubVolume Picture "@!" Valid VldSubVol(cSubVolume) //"Sub-volume"
	Else
		_nDipQtde := 1
		cProduto   := Space(48)
		If Usacb0("01")
			@ 0,0 VTSay "Vol.:"+cVolume //"Vol.:"
		Else
			@ 0,0 VTSay "Qtde " VtGet _nDipQtde pict cPictQtdExp valid VldQtde(_nDipQtde) when (lForcaQtd .or. VTLastkey() == 5) //"Qtde "
		EndIf
		@ 1,0 VTSay "Produto" VTGet cProduto pict '@!' VALID VTLastkey() == 5 .or. VldProdEmb(cProduto,_nDipQtde,NIL,NIL) //"Produto"
	EndIf
EndIf
VtRead                           

If DipTemCB9()
	Volume()
EndIf

If VtLastKey() == 27
	Return .f.
EndIf
Return .T.
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³InicProcEmbºAutor  ³Microsiga          º Data ³  11/07/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function InicProcEmb()
CBFlagSC5("2",cOrdSep)  //-- Em processo de embalagem
Reclock('CB7')
CB7->CB7_STATUS := "3"  // Embalando
CB7->CB7_STATPA := " "  // tira pausa
CB7->(MsUnLock())

If !Empty(CB7->CB7_XREQMT)
	ZZ8->(dbSetOrder(1))
	If ZZ8->(dbSeek(xFilial("ZZ8")+CB7->CB7_XREQMT))
		ZZ8->(RecLock("ZZ8",.F.))
			ZZ8->ZZ8_XSTCB7 := "1"
		ZZ8->(MsUnlock())
	EndIf
EndIf

If ExistBlock("ACD167IN")
	ExecBlock("ACD167IN",.F.,.F.)
Endif

Return      
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Estorna   ºAutor  ³Microsiga           º Data ³  11/07/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ //-- Estorna o processo de embalagem                       º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Estorna()
Local ckey22    := VTDescKey(22)
Local bkey22    := VTSetKey(22)
Local cProduto  := Space(48)
Local cIdVol    := Space(10)
Local cVolume   := Space(10)
Local cSubVolume:= Space(10)
Local _nDipQtde     := 0
Local aTela     := VTSave()

lDipEst := .T.
//-- Desabilita tecla de atalho (Volume)
VTSetKey(22,Nil)

CB9->(DBSetOrder(1))
CB9->(DbSeek(xFilial("CB9")+cOrdSep))
While CB9->(! Eof() .and. CB9_FILIAL+CB9_ORDSEP == xFilial("CB9")+cOrdSep)

	If Empty(CB9->CB9_VOLUME)
		CB9->(DbSkip())
		Loop
	EndIf

	VTClear()
	If VtModelo()=="RF"
		@ 0,0 VtSay Padc("Estorno da leitura",VTMaxCol()) //"Estorno da leitura"
		@ 1,0 VTSay "Leia o volume" //"Leia o volume"
		@ 2,0 VTGet cIdVol pict '@!' Valid VldVolEst(cIdVol,@cVolume)
		If '01' $ CB7->CB7_TIPEXP //-- trabalha com sub-volume
			cSubVolume := Space(10)
			@ 04,00 VtSay "Leia o sub-volume" //"Leia o sub-volume"
			@ 05,00 VtGet cSubVolume Picture "@!" Valid VldSubVol(cSubVolume,.t.,cVolume)
		Else
			_nDipQtde := 1
			cProduto   := Space(48)
			If ! USACB0("01")
				@ 3,0 VTSay "Qtde " VtGet _nDipQtde pict cPictQtdExp valid VldQtde(_nDipQtde) when (lForcaQtd .or. VTLastkey() == 5) //"Qtde "
			EndIf
			@ 4,0 VTSay "Leia o produto" //"Leia o produto"
			@ 5,0 VTGet cProduto pict '@!' VALID VTLastkey() == 5 .or. VldProdEmb(cProduto,@_nDipQtde,.t.,cVolume)
		EndIf
		VtRead
	ElseIf VtModelo()=="MT44"
		If '01' $ CB7->CB7_TIPEXP //-- trabalha com sub-volume
			cSubVolume := Space(10)
			@ 0,0 VTSay "Estorno:Volume" VTGet cIdVol pict '@!' Valid VldVolEst(cIdVol,@cVolume) //"Estorno:Volume"
			@ 1,0 VtSay "Sub-volume    " VtGet cSubVolume Picture "@!" Valid VldSubVol(cSubVolume,.t.,cVolume) //"Sub-volume    "
		Else
			_nDipQtde := 1
			cProduto   := Space(48)
			@ 0,0 VTSay "Estorno" //"Estorno"
			@ 1,0 VTSay "Vol:" VTGet cIdVol pict '@!' Valid VldVolEst(cIdVol,@cVolume) //"Vol:"
			If ! USACB0("01")
				@ 0,17 VTSay "Qtde " VtGet _nDipQtde pict cPictQtdExp valid VldQtde(_nDipQtde) when (lForcaQtd .or. VTLastkey() == 5) //"Qtde "
			EndIf
			@ 1,17 VTSay "Produto" VTGet cProduto pict '@!' VALID VTLastkey() == 5 .or. VldProdEmb(cProduto,@_nDipQtde,.t.,cVolume) //"Produto"
		EndIf
		VtRead
	ElseIf VtModelo()=="MT16"
		If '01' $ CB7->CB7_TIPEXP //-- trabalha com sub-volume
			cSubVolume := Space(10)
			@ 0,0 VTSay "Volume" VTGet cIdVol pict '@!' Valid VldVolEst(cIdVol,@cVolume) //"Volume"
			@ 1,0 VtSay "SubVol" VtGet cSubVolume Picture "@!" Valid VldSubVol(cSubVolume,.t.,cVolume)
		Else
			_nDipQtde := 1
			cProduto   := Space(48)
			@ 0,0 VTSay "Estorno" //"Estorno"
			@ 1,0 VTSay "Volume" VTGet cIdVol pict '@!' Valid VldVolEst(cIdVol,@cVolume) //"Volume"
			VtRead
			If VTLastkey() == 27
				Exit
			EndIf
			VtClear()
			If ! USACB0("01")
				@ 0,0 VTSay "Qtde " VtGet _nDipQtde pict cPictQtdExp valid VldQtde(_nDipQtde) when (lForcaQtd .or. VTLastkey() == 5) //"Qtde "
			Else
				@ 0,0 VTSay "Volume "+cVolume //"Volume "
			EndIf
			@ 1,0 VTSay "Produto" VTGet cProduto pict '@!' VALID VTLastkey() == 5 .or. VldProdEmb(cProduto,@_nDipQtde,.t.,cVolume) //"Produto"
		EndIf
		VtRead
	EndIf
	If VTLastkey() == 27
		Exit
	EndIf
EndDo

VTRestore(,,,,aTela)
//-- Restaura Telca
VTSetKey(22,bKey22, cKey22)
Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ Volume   ³ Autor ³ ACD                   ³ Data ³ 01/03/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Geracao de novo Volume                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAACD                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Volume()
Local aTela
Local cVolAnt

cVolAnt := cVolume
aTela   := VTSave()
VTClear()
cVolume := Space(20)
If VtModelo()=="RF"
	@ 0,0 VTSay "Embalagem" //"Embalagem"
	@ 1,0 VtSay "Leia o volume:" //"Leia o volume:"
	@ 2,0 VtGet cVolume Pict "@!" Valid VldVolume()
	@ 4,0 VtSay "Tecle ENTER para" //"Tecle ENTER para"
	@ 5,0 VtSay "novo volume.    " //"novo volume.    "
Else
	If VtModelo()=="MT44"
		@ 0,0 VTSay "Leia o volume ou ENTER p/ novo volume" //"Leia o volume ou ENTER p/ novo volume"
	Else //-- mt16
		@ 0,0 VTSay "Leia o volume" //"Leia o volume"
	EndIf
	@ 1,0 VtGet cVolume Pict "@!" Valid VldVolume()
EndIf
VTRead
VTRestore(,,,,aTela)
cVolume := Padr(cVolume,10)
If VTLastkey() == 27
	cVolume := cVolAnt
	Return .f.
EndIf
//-- Atualiza Display na tela de embalagem
If VtModelo()=="RF"
	@ 1,0 VTSay "Volume :"+cVolume //"Volume :"
ElseIf VtModelo()=="MT44"
	If '01' $ CB7->CB7_TIPEXP
		@ 0,0 VTSay "Embalagem Volume:"+cVolume //"Embalagem Volume:"
	Else
		@ 0,0 VTSay "Vol:"+cVolume //"Vol:"
	EndIf
ElseIf VtModelo()=="MT16"
	If '01' $ CB7->CB7_TIPEXP
		@ 0,0 VTSay "Volume :"+cVolume //"Volume :"
	Else
		If Usacb0("01")
			@ 0,0 VTSay "Vol:"+cVolume //"Vol:"
		EndIf
	EndIf
EndIf
Return .t.
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ FimProcEmb ³ Autor ³ ACD                 ³ Data ³ 01/03/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Finalisa o processo de embalagem                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAACD                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FimProcEmb()
Local  cMsg     := ''
Local  nSai     := 1
Local  lExitEmb := .F.
Local  lVolEmpty:= .F.

CB9->(DBSetOrder(2))
If CB9->(DBSeek(xFilial("CB9")+cOrdSep+Space(10)))
	lVolEmpty := .T.
EndIf

CB9->(DBSeek(xFilial("CB9")+cOrdSep))
While CB9->(!Eof() .AND. CB9_FILIAL+CB9_ORDSEP==xFilial("CB9")+cOrdSep)
	If !Empty(CB9->CB9_VOLUME)
		lExitEmb := .T.
		Exit
	EndIf
	CB9->(DbSkip())
EndDo

Reclock('CB7')
If	lVolEmpty .And. !lExitEmb  //-- Nao existem produtos embalados
	nSai := 0
	If lDipEst
		CB7->CB7_STATUS := "2"  //-- retorna para processo de separacao
		If !Empty(CB7->CB7_XREQMT)
			ZZ8->(dbSetOrder(1))
			If ZZ8->(dbSeek(xFilial("ZZ8")+CB7->CB7_XREQMT))
				ZZ8->(RecLock("ZZ8",.F.))
					ZZ8->ZZ8_XSTCB7 := "0"
				ZZ8->(MsUnlock())
			EndIf
		EndIf
	Else
		CB7->CB7_STATPA := "1" //Pausa
	EndIf
	cMsg := "Processo de embalagem nao finalizado."
ElseIf	!lVolEmpty
	nSai := 1
	If	CB7->CB7_STATUS < "4"
		If	("02" $ CBUltExp(CB7->CB7_TIPEXP))
			CB7->CB7_STATUS := "9"  // embalagem finalizada
			cMsg := "Processo de expedicao finalizado" //"Processo de expedicao finalizado"
		Else
			CB7->CB7_STATUS := "4"  // embalagem finalizada			
			cMsg := "Processo de embalagem finalizado" //"Processo de embalagem finalizado"
			If !Empty(CB7->CB7_XREQMT)
				ZZ8->(dbSetOrder(1))
				If ZZ8->(dbSeek(xFilial("ZZ8")+CB7->CB7_XREQMT))
					ZZ8->(RecLock("ZZ8",.F.))
						ZZ8->ZZ8_XSTCB7 := "2"
					ZZ8->(MsUnlock())
				EndIf
			EndIf
		EndIf
	EndIf
Else
	nSai := 0
	CB7->CB7_STATUS := "3"  // embalagem em andamento
	cMsg := "Processo de embalagem nao finalizado" //"Processo de embalagem nao finalizado"	
EndIf

If	!("02" $ CBUltExp(CB7->CB7_TIPEXP))
	CB7->CB7_STATPA := "1"  // Pausa
EndIf
CB7->(MsUnLock())
VTAlert(cMsg,"Aviso",.t.,4000,3) //"Aviso"

//Verifica se esta sendo chamado pelo ACDV170 e se existe um avanco
//ou retrocesso forcado pelo operador
If ACDGet170() .AND. A170AvOrRet()
	If CB7->CB7_STATUS == "3" //-- Nao efetua saltos com embalagem em andamento
		nSai := 0
	Else
		nSai := A170ChkRet()
	EndIf
ElseIf ACDGet170().AND. ((lVolEmpty .and. !lExitEmb) .OR. CB7->CB7_STATUS == "3") .AND. ;
		VTYesNo("Deseja abandonar o processo de embalagem ?","Atencao",.T.) //"Deseja abandonar o processo de embalagem ?"###"Atencao"
	nSai := 10
EndIf
If	ExistBlock("ACD167FI")
	ExecBlock("ACD167FI",.F.,.F.)
Endif
Return nSai
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ Informa    ³ Autor ³ ACD                 ³ Data ³ 01/03/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Mostra produtos que ja foram lidos/embalados               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAACD                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Informa()
Local ckey22  := VTDescKey(22)
Local bkey22  := VTSetKey(22)
Local aCab,aSize
Local aSave   := VTSAVE()
Local aTemp   :={}
Local nTam

//-- Desabilita tecla de atalho (Volume)
VTSetKey(22,Nil)

VTClear()
If UsaCB0('01')
	aCab  := {"Volume","Produto","Qtde Separada","Qtde embalada","Armazem","Endereco","Lote","Sub-Lote","Sub-volume","Serie","Id Etiqueta"} //"Volume"###"Produto"###"Qtde Separada"###"Qtde embalada"###"Armazem"###"Endereco"###"Lote"###"Sub-Lote"###"Sub-volume"###"Id Etiqueta"
Else
	aCab  := {"Volume","Produto","Qtde Separada","Qtde embalada","Armazem","Endereco","Lote","Sub-Lote","Sub-volume","Serie"} //"Volume"###"Produto"###"Qtde Separada"###"Qtde embalada"###"Armazem"###"Endereco"###"Lote"###"Sub-Lote"###"Sub-volume"
EndIf
nTam := len(aCab[3])
If nTam < len(Transform(0,cPictQtdExp))
	nTam := len(Transform(0,cPictQtdExp))
EndIf
If UsaCB0('01')
	aSize := {10,15,nTam,nTam,7,10,10,8,10,20,12}
Else
	aSize := {10,15,nTam,nTam,7,10,10,8,10,20}
EndIf

CB9->(DbSetOrder(6))
CB9->(DbSeek(xFilial("CB9")+cOrdSep))
While CB9->(! Eof() .and. CB9_FILIAL+CB9_ORDSEP == xFilial("CB9")+cOrdSep)
	If UsaCB0('01')
		aadd(aTemp,{CB9->CB9_VOLUME,CB9->CB9_PROD,Transform(CB9->CB9_QTESEP,cPictQtdExp),Transform(CB9->CB9_QTEEMB,cPictQtdExp),CB9->CB9_LOCAL,CB9->CB9_LCALIZ,CB9->CB9_LOTECT,CB9->CB9_NUMLOT,CB9->CB9_SUBVOL,CB9->CB9_NUMSER,CB9->CB9_CODETI})
	Else
		aadd(aTemp,{CB9->CB9_VOLUME,CB9->CB9_PROD,Transform(CB9->CB9_QTESEP,cPictQtdExp),Transform(CB9->CB9_QTEEMB,cPictQtdExp),CB9->CB9_LOCAL,CB9->CB9_LCALIZ,CB9->CB9_LOTECT,CB9->CB9_NUMLOT,CB9->CB9_SUBVOL,CB9->CB9_NUMSER})
	EndIf
	CB9->(DbSkip())
EndDo
VTaBrowse(,,,,aCab,aTemp,aSize)
VtRestore(,,,,aSave)
//-- Restaura Telca
VTSetKey(22,bKey22, cKey22)
Return

//////////////////////////////////////////////////////////////
// Funcoes de validacao
/////////////////////////////////////////////////////////////
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ VldVolEst³ Autor ³ ACD                   ³ Data ³ 01/03/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Valida o estorno do volume                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAACD                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function VldVolEst(cIDVolume,cVolume)
Local aRet:= {}

If	VtLastkey()== 05
	Return .t.
EndIf

If Empty(cIDVolume)
	Return .f.
EndIf

If UsaCB0("05")
	aRet:= CBRetEti(cIDVolume,"05")
	If Empty(aRet)
		VtAlert("Etiqueta de volume invalida","Aviso",.t.,4000,3) //"Etiqueta de volume invalida"###"Aviso"
		VtKeyboard(Chr(20))  // zera o get
		Return .f.
	Else
		cVolume:= aRet[1]
	EndIf
Else
	cVolume:= cIDVolume
EndIf

CB6->(DBSetOrder(1))
If ! CB6->(DbSeek(xFilial("CB6")+cVolume))
	VtAlert("Codigo de volume nao cadastrado","Aviso",.t.,4000,3) //"Codigo de volume nao cadastrado"###"Aviso"
	VtKeyboard(Chr(20))  // zera o get
	Return .f.
EndIf

CB9->(DBSetOrder(2))
If ! CB9->(DbSeek(xFilial("CB9")+cOrdSep+cVolume))
	VtAlert("Volume pertence a outra ordem de separacao","Aviso",.t.,4000,3) //"Volume pertence a outra ordem de separacao"###"Aviso"
	VtKeyboard(Chr(20))  // zera o get
	Return .f.
EndIf
If	ExistBlock("ACD167VV")                
	lRet := ExecBlock("ACD167VV",.F.,.F.,{cOrdSep,cVolume})
	If ValType(lret) == "L" .and. !lRet
		VtKeyboard(Chr(20))  // zera o get
		Return .f.
	EndIf	
EndIf
Return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³VldSubVol ³ Autor ³ ACD                   ³ Data ³ 01/03/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Funcao auxiliar Chamada pelas Funcoes Estorna e Embalagem   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAACD                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function VldSubVol(cSubVolume,lEstorna,cVolumeEst)
Local aRet := CBRetEti(cSubVolume,"05")
DEFAULT lEstorna:= .f.

If Empty(cSubVolume)
	Return .f.
EndIf
If Empty(aRet)
	VtAlert("Etiqueta invalida","Aviso",.t.,4000,3) //"Etiqueta invalida"###"Aviso"
	VtKeyboard(Chr(20))  // zera o get
	return .f.
EndIf
cCodVol := aRet[1]
CB6->(DBSetOrder(1))
If ! CB6->(DbSeek(xFilial("CB6")+cCodVol))
	VtAlert("Codigo de sub-volume nao cadastrado","Aviso",.t.,4000,3) //"Codigo de sub-volume nao cadastrado"###"Aviso"
	VtKeyboard(Chr(20))  // zera o get
	return .f.
EndIf
If CB7->CB7_ORIGEM == "1"
	If ! CB6->CB6_PEDIDO == CB7->CB7_PEDIDO
		VtAlert("Sub-volume pertence ao pedido "+CB6->CB6_PEDIDO,"Aviso",.t.,4000,3) //"Sub-volume pertence ao pedido "###"Aviso"
		VtKeyboard(Chr(20))  // zera o get
		return .f.
	EndIf
ElseIf CB7->CB7_ORIGEM == "2"
	If ! CB6->(CB6_NOTA+CB6_SERIE) == CB7->(CB7_NOTA+CB7_SERIE)
		VtAlert("Sub-volume pertence a nota "+CB6->(CB6_NOTA+'-'+CB6_SERIE),"Aviso",.t.,4000,3) //"Sub-volume pertence a nota "###"Aviso"
		VtKeyboard(Chr(20))  // zera o get
		return .f.
	EndIf
EndIF

CB9->(DbSetOrder(7))
If ! CB9->(DbSeek(xFilial("CB9")+cOrdSep+cCodVol))
	If lEstorna
		VtAlert("Sub-volume nao pertence esta ordem de separacao","Aviso",.t.,4000) //"Sub-volume nao pertence esta ordem de separacao"###"Aviso"
	Else
		VtAlert("Sub-volume nao separado","Aviso",.t.,4000) //"Sub-volume nao separado"###"Aviso"
	EndIf
	VtKeyboard(Chr(20))  // zera o get
	return .f.
EndIf
If ! lEstorna
	If ! Empty(CB9->CB9_VOLUME)
		VtAlert("Sub-Volume ja embalado","Aviso",.t.,4000) //"Sub-Volume ja embalado"###"Aviso"
		VtKeyboard(Chr(20))  // zera o get
		return .f.
	EndIf
	While CB9->(! EOF() .and. CB9_FILIAL+CB9_ORDSEP+CB9_SUBVOL == ;
			xFilial("CB9")+cOrdSep+cCodVol)
		RecLock("CB9")
		CB9->CB9_VOLUME := cVolume
		CB9->CB9_CODEMB := cCodOpe
		CB9->(MsUnLock())
		CB9->(DBSkip())
	End
Else
	If Empty(CB9->CB9_VOLUME)
		VtAlert("Sub-Volume nao embalado","Aviso",.t.,4000,3) //"Sub-Volume nao embalado"###"Aviso"
		VtKeyboard(Chr(20))  // zera o get
		return .f.
	EndIf
	If CB9->CB9_VOLUME # cVolumeEst
		VtAlert("Sub-Volume pertence ao volume "+CB9->CB9_VOLUME,"Aviso",.t.,4000,3) //"Sub-Volume pertence ao volume "###"Aviso"
		VtKeyboard(Chr(20))  // zera o get
		return .f.
	EndIf
	While CB9->(! EOF() .and. CB9_FILIAL+CB9_ORDSEP+CB9_SUBVOL == ;
			xFilial("CB9")+cOrdSep+cCodVol)
		RecLock("CB9")
		CB9->CB9_VOLUME := " "
		CB9->CB9_CODEMB := " "
		CB9->(MsUnLock())
		CB9->(DBSkip())
	End
EndIf
VtKeyboard(Chr(20))  // zera o get
Return ! lEstorna
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³  VldQtde ³ Autor ³ Anderson Rodrigues    ³ Data ³ 29/06/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Validacao da quantidade informada                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAACD                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function VldQtde(_nDipQtde,lSerie)
Default lSerie:= .f.

If	_nDipQtde <= 0
	Return .f.
EndIf
If	lSerie .and. _nDipQtde > 1
	VTAlert("Quantidade invalida !!!","Aviso",.T.,2000) //"Quantidade invalida !!!"###"Aviso"
	VTAlert("Quando se utiliza numero de serie a quantidade deve ser == 1","Aviso",.T.,4000) //"Quando se utiliza numero de serie a quantidade deve ser == 1"###"Aviso"
	Return .f.
EndIf
Return .t.
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³VldProdEmb³ Autor ³ ACD                   ³ Data ³ 01/03/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Funcao auxiliar chamada pela funcao Embalagem               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAACD                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function VldProdEmb(cEProduto,_nDipQtde,lEstorna,cVolumeEst)
Local cTipo
Local aEtiqueta,aRet
Local cLote    := Space(10)
Local cSLote   := Space(6)
Local cNumSer  := Space(20)
Local nQEConf  :=0
Local nSaldoEmb
Local nRecno,nRecnoCB9
Local cProduto
Local nQtdeSep
Public nQE       :=0
DEFAULT lEstorna := .f.

If Empty(cEProduto)
	Return .f.
EndIf          
   
SC5->(dbSetOrder(1))
If SC5->(dbSeek(xFilial("SC5")+CB7->CB7_PEDIDO)) .And. !Empty(SC5->C5_XBLQNF)
	VtAlert("Foi solicitado o estorno do pedido. Pare a conferencia.","Aviso",.t.,4000,3)
	VtKeyboard(Chr(20))  // zera o get
	Return .F.
EndIf

If !CBLoad128(@cEProduto)
	VtKeyboard(Chr(20))  // zera o get
	Return .F.
EndIf
cTipo :=CbRetTipo(cEProduto)
If cTipo == "01"
	aEtiqueta:= CBRetEti(cEProduto,"01")
	If Empty(aEtiqueta)
		VtAlert("Etiqueta invalida","Aviso",.t.,4000,3) //"Etiqueta invalida"###"Aviso"
		VtKeyboard(Chr(20))  // zera o get
		Return .F.
	EndIf
	CB9->(DbSetorder(1))
	If ! CB9->(DbSeek(xFilial("CB9")+cOrdSep+Left(cEProduto,10)))
		VtAlert("Produto nao separado","Aviso",.t.,4000,3) //"Produto nao separado"###"Aviso"
		VtKeyboard(Chr(20))  // zera o get
		Return .F.
	EndIf
	If ! lEstorna
		If ! Empty(CB9->CB9_VOLUME)
			VtAlert("Produto embalado no volume "+CB9->CB9_VOLUME,"Aviso",.t.,4000,3) //"Produto embalado no volume "###"Aviso"
			VtKeyboard(Chr(20))  // zera o get
			Return .F.
		EndIf
	Else
		If Empty(CB9->CB9_VOLUME)
			VtAlert("Produto nao embalado","Aviso",.t.,4000) //"Produto nao embalado"###"Aviso"
			VtKeyboard(Chr(20))  // zera o get
			Return .F.
		EndIf
		If CB9->CB9_VOLUME # cVolumeEst
			VtAlert("Produto embalado em outro volume "+CB9->CB9_VOLUME,"Aviso",.t.,4000,3) //"Produto embalado em outro volume "###"Aviso"
			VtKeyboard(Chr(20))  // zera o get
			Return .F.
		EndIf
	EndIf
	cProduto:= aEtiqueta[1]
	nQE     := aEtiqueta[2]
	cLote   := aEtiqueta[16]
	cSLote  := aEtiqueta[17]
	If ! lEstorna
		nQEConf:= nQE
		If ! CBProdUnit(aEtiqueta[1]) .and. GetMv("MV_CHKQEMB") =="1"
			nQEConf := CBQtdEmb(aEtiqueta[1])
		EndIf
		If empty(nQEConf) .or. nQE # nQEConf
			VtAlert("Quantidade invalida ","Aviso",.t.,4000,3) //"Quantidade invalida "###"Aviso"
			VtKeyboard(Chr(20))  // zera o get
			Return .f.
		EndIf

		RecLock("CB9")
		CB9->CB9_VOLUME := cVolume
		CB9->CB9_QTEEMB += nQE
		CB9->CB9_CODEMB := cCodOpe
		CB9->CB9_STATUS := "2"  // Embalado
		CB9->(MsUnlock())
		CB8->(DbSetOrder(4))
		CB8->(DbSeek(xFilial("CB8")+CB9->(CB9_ORDSEP+CB9_ITESEP+CB9_PROD+CB9_LOCAL+CB9_LCALIZ+CB9_LOTSUG+CB9_SLOTSU+CB9_NUMSER)))
		RecLock("CB8")
		CB8->CB8_SALDOE -= nQE
		CB8->(MsUnlock())
		SB1->(dbSetOrder(1))
		SB1->(dbSeek(xFilial("SB1")+cProduto))
		If ! CBProdUnit(aEtiqueta[1]) .and. GetMV('MV_REMIEMB') == "S"
			If CB5SetImp(cImp,.T.)
				VTAlert("Imprimindo etiqueta de produto ","Aviso",.T.,2000) //"Imprimindo etiqueta de produto "###"Aviso"
				If ExistBlock('IMG01')
					ExecBlock("IMG01",,,{,,CB9->CB9_CODETI})
				EndIf
				MSCBCLOSEPRINTER()
			EndIf
		EndIf
	Else
		If ! VtYesNo("Confirma o estorno?","Aviso",.t.) //"Confirma o estorno?"###"Aviso"
			VtKeyboard(Chr(20))  // zera o get
			Return .F.
		EndIf
		RecLock("CB9")
		CB9->CB9_VOLUME := ''
		CB9->CB9_QTEEMB -= nQE
		CB9->CB9_CODEMB := ''
		CB9->CB9_STATUS := "1"  // Em Aberto
		CB9->(MsUnlock())
		CB8->(DbSetOrder(4))
		CB8->(DbSeek(xFilial("CB8")+CB9->(CB9_ORDSEP+CB9_ITESEP+CB9_PROD+CB9_LOCAL+CB9_LCALIZ+CB9_LOTSUG+CB9_SLOTSU+CB9_NUMSER)))
		RecLock("CB8")
		CB8->CB8_SALDOE += nQE
		CB8->(MsUnlock())
	EndIf
ElseIf cTipo $ "EAN8OU13-EAN14-EAN128"
	aRet := CBRetEtiEan(cEProduto)
	
	If	Len(aRet)==0
		VtAlert("Etiqueta invalida","Aviso",.t.,4000,3) //"Etiqueta invalida"###"Aviso"
		VtKeyboard(Chr(20))  // zera o get
		Return .F.
	EndIf
	
	cProduto := aRet[1]
	cLote  	 := aRet[3] 
	cNumSer  := aRet[5]                                  

	If	! CBProdUnit(cProduto)
		VtAlert("Etiqueta invalida","Aviso",.t.,4000,3) //"Etiqueta invalida"###"Aviso"
		VtKeyboard(Chr(20))  // zera o get
		Return .F.
	EndIf 
	
	If	! CBRastro(cProduto,@cLote,@cSLote)
		VTKeyBoard(chr(20))
		Return .f.
	EndIf
	
	If lEstorna	
		If	Empty(aRet[2])
			nQE  := _nDipQtde
		Else
			nQE  := _nDipQtde*aRet[2]       
		EndIf  	
	Else    
		CB9->(DbSetorder(8))
		If	! CB9->(DBSeek(xFilial("CB9")+cOrdSep+cProduto+cLote+cSLote+cNumSer+space(10)))
			VtAlert("Produto invalido, ou ja embalado","Aviso",.t.,4000,3)   //"Produto invalido, ou ja embalado"###"Aviso"
			VtKeyboard(Chr(20))  // zera o get
			Return .F.
		EndIf
		  
		//CB8->(DbSetOrder(4))
		//CB8->(DbSeek(xFilial("CB8")+CB9->(CB9_ORDSEP+CB9_ITESEP+CB9_PROD+CB9_LOCAL+CB9_LCALIZ+CB9_LOTSUG+CB9_SLOTSU+CB9_NUMSER)))
	    //O CB8 está sendo posicionado no PE CBRQEESP
	        
		If CBQtdEmb(cProduto,0) > 0  
			nQE := CBQtdEmb(cProduto) 
		Else
			If	Empty(aRet[2])
				nQE  :=CBQtdEmb(cProduto)*_nDipQtde
			Else
				nQE  :=CBQtdEmb(cProduto)*_nDipQtde	*aRet[2]       
			EndIf
		EndIf
	EndIf                                            
		
	If	Empty(nQE)
		VtAlert("Quantidade invalida","Aviso",.t.,4000,3) //"Quantidade invalida"###"Aviso"
		VtKeyboard(Chr(20))  // zera o get
		Return .F.
	EndIf                              

	If	Empty(cNumSer) .and. CBSeekNumSer(cOrdSep,cProduto)
		If	! VldQtde(_nDipQtde,.T.)
			VtKeyboard(Chr(20))  // zera o get
			Return .F.
		EndIf
		If	! CBNumSer(@cNumSer)
			VTKeyBoard(chr(20))
			Return .f.
		EndIf
	EndIf
	
	If ExistBlock("ACD167VE")
		aRet := ExecBlock("ACD167VE",,,{aRet,lEstorna})
		If Empty(aRet)
			Return .f.
		EndIf            
		cLote   := aRet[3]
		cNumSer := aRet[5]
	EndIf

	If	! lEstorna
		CB9->(DbSetorder(8))
		If	! CB9->(DBSeek(xFilial("CB9")+cOrdSep+cProduto+cLote+cSLote+cNumSer+space(10)))
			VtAlert("Produto invalido, ou ja embalado","Aviso",.t.,4000,3)   //"Produto invalido, ou ja embalado"###"Aviso"
			VtKeyboard(Chr(20))  // zera o get
			Return .F.
		EndIf
		nSaldoEmb:=0
		While CB9->(! EOF() .AND. CB9_FILIAL+CB9_ORDSEP+CB9_PROD+CB9_LOTECT+CB9_NUMLOT+CB9_VOLUME ==;
				xFilial("CB9")+cOrdSep+cProduto+cLote+cSLote+space(10))
			nSaldoEmb += CB9->CB9_QTESEP
			CB9->(DbSkip())
		EndDo
		If	nQE > nSaldoEmb
			VtAlert("Quantidade informada maior que disponivel para embalar","Aviso",.t.,4000)   //"Quantidade informada maior que disponivel para embalar"###"Aviso"
			VtKeyboard(Chr(20))  // zera o get
			Return .F.
		EndIf                          
		
		If _cTipSald == "1" .And. !U_DipVldVol(cVolume,cOrdSep)
			VtAlert("Este volume já contém itens. Para caixa fechada, informe um volume vazio.","Aviso",.t.,4000)
			VtKeyboard(Chr(20))
			Return .F.			
		EndIf	 
		
		//-- Atualiza Quantidade Embalagem
		nSaldoEmb := nQE
		CB9->(DbSetorder(8))
		While nSaldoEmb > 0 .And. CB9->(DBSeek(xFilial("CB9")+cOrdSep+cProduto+cLote+cSLote+cNumSer+space(10)))
			If	nSaldoEmb > CB9->CB9_QTESEP
				Begin Transaction
					RecLock("CB9")
					CB9->CB9_VOLUME := cVolume
					CB9->CB9_QTEEMB := CB9->CB9_QTESEP
					CB9->CB9_CODEMB := cCodOpe
					CB9->CB9_STATUS := "2"  // Embalado
					CB9->CB9_XVOLOK := IIf(_cTipSald$"1,2","1","") //Gravo 1 para manter o legado da _lDipSald
					CB9->(MsUnlock())
					//-- Atualiza Itens Ordem da Separacao
					CB8->(DbSetOrder(4)) //-- CB8_FILIAL+CB8_ORDSEP+CB8_ITEM+CB8_PROD+CB8_LOCAL+CB8_LCALIZ+CB8_LOTECT+CB8_NUMLOT+CB8_NUMSER
					CB8->(DbSeek(xFilial("CB8")+CB9->(CB9_ORDSEP+CB9_ITESEP+CB9_PROD+CB9_LOCAL+CB9_LCALIZ+CB9_LOTSUG+CB9_SLOTSU+CB9_NUMSER)))
					RecLock("CB8")
					CB8->CB8_SALDOE -= CB9->CB9_QTESEP
					CB8->(MsUnlock())
				End Transaction
				nSaldoEmb-=CB9->CB9_QTESEP
			Else
				nRecnoCB9:= CB9->(Recno())
				CB9->(DbSetOrder(8))
				If	CB9->(DBSeek(CB9_FILIAL+CB9_ORDSEP+CB9_PROD+CB9_LOTECT+CB9_NUMLOT+CB9_NUMSER+cVolume+CB9_ITESEP+CB9_LOCAL+CB9_LCALIZ))
					Begin Transaction
						RecLock("CB9")
						CB9->CB9_QTEEMB += nSaldoEmb
						CB9->CB9_QTESEP += nSaldoEmb  
						CB9->CB9_XVOLOK := IIf(_cTipSald$"1,2","1","")
						CB9->(MsUnlock())
						//-- Atualiza Itens Ordem da Separacao
						CB8->(DbSetOrder(4)) //-- CB8_FILIAL+CB8_ORDSEP+CB8_ITEM+CB8_PROD+CB8_LOCAL+CB8_LCALIZ+CB8_LOTECT+CB8_NUMLOT+CB8_NUMSER
						CB8->(DbSeek(xFilial("CB8")+CB9->(CB9_ORDSEP+CB9_ITESEP+CB9_PROD+CB9_LOCAL+CB9_LCALIZ+CB9_LOTSUG+CB9_SLOTSU+CB9_NUMSER)))
						RecLock("CB8")
						CB8->CB8_SALDOE -= nSaldoEmb
						CB8->(MsUnlock())
						//--
						CB9->(DbGoto(nRecnoCB9))
						RecLock("CB9")
						CB9->CB9_QTESEP -= nSaldoEmb
						If	Empty(CB9->CB9_QTESEP)
							CB9->(DBDelete())
						EndIf
						CB9->(MsUnlock())
					End Transaction
					nSaldoEmb := 0
				Else
					CB9->(DbGoto(nRecnoCB9))
					nRecno:= CB9->(CBCopyRec({{"CB9_VOLUME","X"}}))
					Begin Transaction
						RecLock("CB9")
						CB9->CB9_VOLUME := cVolume
						CB9->CB9_QTEEMB := nSaldoEmb
						CB9->CB9_QTESEP := nSaldoEmb
						CB9->CB9_CODEMB := cCodOpe
						CB9->CB9_STATUS := "2"  // Embalado       
						CB9->CB9_XVOLOK := IIf(_cTipSald$"1,2","1","")
						CB9->(MsUnlock())
						//-- Atualiza Itens Ordem da Separacao
						CB8->(DbSetOrder(4)) //-- CB8_FILIAL+CB8_ORDSEP+CB8_ITEM+CB8_PROD+CB8_LOCAL+CB8_LCALIZ+CB8_LOTECT+CB8_NUMLOT+CB8_NUMSER
						CB8->(DbSeek(xFilial("CB8")+CB9->(CB9_ORDSEP+CB9_ITESEP+CB9_PROD+CB9_LOCAL+CB9_LCALIZ+CB9_LOTSUG+CB9_SLOTSU+CB9_NUMSER)))
						RecLock("CB8")
						CB8->CB8_SALDOE -= nSaldoEmb
						CB8->(MsUnlock())
						//--
						CB9->(DBGoto(nRecno))
						RecLock("CB9")
						CB9->CB9_VOLUME := Space(10)
						CB9->CB9_QTESEP -= nSaldoEmb
						If	Empty(CB9->CB9_QTESEP)
							CB9->(DBDelete())
						EndIf
						CB9->(MsUnlock())
					End Transaction
					nSaldoEmb := 0
				EndIf
			EndIf
		EndDo
	Else
		CB9->(DbSetorder(8))
		If ! CB9->(DBSeek(xFilial("CB9")+cOrdSep+cProduto+cLote+cSLote+cNumSer+cVolumeEst))
			VtAlert("Produto nao embalado","Aviso",.t.,4000) //"Produto nao embalado"###"Aviso"
			VtKeyboard(Chr(20))  // zera o get
			Return .F.
		EndIf
		nSaldoEmb:=0
		While CB9->(! EOF() .AND. CB9_FILIAL+CB9_ORDSEP+CB9_PROD+CB9_LOTECT+CB9_NUMLOT+CB9_VOLUME ==;
				xFilial("CB9")+cOrdSep+cProduto+cLote+cSLote+cVolumeEst)
			nSaldoEmb += CB9->CB9_QTEEMB
			CB9->(DbSkip())
		EndDo
		If nQE > nSaldoEmb
			VtAlert("Quantidade informada maior que embalado no volume ","Aviso",.t.,4000,3) //"Quantidade informada maior que embalado no volume "###"Aviso"
			VtKeyboard(Chr(20))  // zera o get
			Return .F.
		EndIf
		If ! VtYesNo("Confirma o estorno?","Aviso",.t.) //"Confirma o estorno?"###"Aviso"
			VtKeyboard(Chr(20))  // zera o get
			Return .F.
		EndIf
		//-- Estorna Quantidade Embalagem
		nSaldoEmb := nQE

		ZZ5->(dbSetOrder(1))
		CB9->(DbSetorder(8))

		While nSaldoEmb>0 .And. CB9->(DBSeek(xFilial("CB9")+cOrdSep+cProduto+cLote+cSLote+cNumSer+cVolumeEst))

			If ZZ5->(dbSeek(xFilial("ZZ5")+CB9->(CB9_PEDIDO))) .And. ZZ5->ZZ5_STATUS > "2"
				ZZ5->(RecLock("ZZ5",.F.))					
					ZZ5->ZZ5_STATUS := "2"
				ZZ5->(MsUnlock())
		    EndIf

			If	nSaldoEmb >= CB9->CB9_QTEEMB
				nRecnoCB9:= CB9->(Recno())
				nQtdeSep := CB9->CB9_QTESEP
				Begin Transaction
					CB9->(DbSetOrder(8))
					If	CB9->(DBSeek(CB9_FILIAL+CB9_ORDSEP+CB9_PROD+CB9_LOTECT+CB9_NUMLOT+CB9_NUMSER+Space(10)+CB9_ITESEP+CB9_LOCAL+CB9_LCALIZ))
						RecLock("CB9")
						CB9->CB9_QTESEP += nQtdeSep
						CB9->(MsUnlock())
						CB9->(DbGoto(nRecnoCB9))
						//--
						CB8->(DbSetOrder(4))
						CB8->(DbSeek(xFilial("CB8")+CB9->(CB9_ORDSEP+CB9_ITESEP+CB9_PROD+CB9_LOCAL+CB9_LCALIZ+CB9_LOTSUG+CB9_SLOTSU+CB9_NUMSER)))
						RecLock("CB9")
						CB9->(DbDelete())
						CB9->(MsUnlock())
					Else
						CB9->(DbGoto(nRecnoCB9))
						RecLock("CB9")
						CB9->CB9_VOLUME := ""
						CB9->CB9_QTEEMB := 0
						CB9->CB9_CODEMB := ""
						CB9->CB9_STATUS := "1"  // Em Aberto
						CB9->(MsUnlock())
						CB8->(DbSetOrder(4))
						CB8->(DbSeek(xFilial("CB8")+CB9->(CB9_ORDSEP+CB9_ITESEP+CB9_PROD+CB9_LOCAL+CB9_LCALIZ+CB9_LOTSUG+CB9_SLOTSU+CB9_NUMSER)))
					EndIf
					RecLock("CB8")
					CB8->CB8_SALDOE += nQtdeSep
					CB8->(MsUnlock())
				End Transaction
				nSaldoEmb-=nQtdeSep
			Else
				nRecnoCB9:= CB9->(Recno())
				nQtdeSep := CB9->CB9_QTESEP
			    
				Begin Transaction  
							    
					CB9->(DbSetOrder(8))
					If	CB9->(DBSeek( CB9_FILIAL+CB9_ORDSEP+CB9_PROD+CB9_LOTECT+CB9_NUMLOT+CB9_NUMSER+Space(10)+CB9_ITESEP+CB9_LOCAL+CB9_LCALIZ))
						RecLock("CB9")
						CB9->CB9_QTESEP += nSaldoEmb
						CB9->(MsUnlock())
						//--
						CB9->(DbGoto(nRecnoCB9))
						RecLock("CB9")
						//CB9->CB9_VOLUME := ""
						CB9->CB9_QTEEMB -= nSaldoEmb
						CB9->CB9_QTESEP -= nSaldoEmb
						//CB9->CB9_CODEMB := ''
						//CB9->CB9_STATUS := "1"
						If	Empty(CB9->CB9_QTESEP)
							CB9->(DbDelete())
						EndIf
						CB9->(MsUnlock())
						//--
						CB8->(DbSetOrder(4))
						CB8->(DbSeek(xFilial("CB8")+CB9->(CB9_ORDSEP+CB9_ITESEP+CB9_PROD+CB9_LOCAL+CB9_LCALIZ+CB9_LOTSUG+CB9_SLOTSU+CB9_NUMSER)))
						RecLock("CB8")
						CB8->CB8_SALDOE += nSaldoEmb
						CB8->(MsUnlock())
					Else
						CB9->(DbGoto(nRecnoCB9))
						nRecno:= CB9->(CBCopyRec({{"CB9_VOLUME","X"}}))
						RecLock("CB9")
						CB9->CB9_VOLUME := ""
						CB9->CB9_QTEEMB := 0
						CB9->CB9_QTESEP := nSaldoEmb
						CB9->CB9_CODEMB := ''
						CB9->CB9_STATUS := "1"
						CB9->(MsUnlock())
						//--
						CB8->(DbSetOrder(4))
						CB8->(DbSeek(xFilial("CB8")+CB9->(CB9_ORDSEP+CB9_ITESEP+CB9_PROD+CB9_LOCAL+CB9_LCALIZ+CB9_LOTSUG+CB9_SLOTSU+CB9_NUMSER)))
						RecLock("CB8")
						CB8->CB8_SALDOE += nSaldoEmb
						CB8->(MsUnlock())
						CB9->(DBGoto(nRecno))
						RecLock("CB9")              
						CB9->CB9_VOLUME := cVolumeEst
						CB9->CB9_QTESEP -= nSaldoEmb
						CB9->CB9_QTEEMB -= nSaldoEmb
						If	Empty(CB9->CB9_QTESEP)
							CB9->(DBDelete())
						EndIf
						CB9->(MsUnlock())                           
					EndIf
				End Transaction
				nSaldoEmb := 0
			EndIf
		EndDo
	EndIf
Else
	VtAlert("Etiqueta invalida","Aviso",.t.,4000,3) //"Etiqueta invalida"###"Aviso"
	VtKeyboard(Chr(20))  // zera o get
	Return .F.
EndIf
_nDipQtde:=1
VTGetRefresh('_nDipQtde')
VtKeyboard(Chr(20))  // zera o get
Return ! lEstorna
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ VldVolume³ Autor ³ Anderson Rodrigues    ³ Data ³ 25/11/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Validacao da Geracao do Volume                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAACD                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static function VldVolume()
Local cCodEmb   := Space(3)
Local cVolImp   := Space(10)
Local lRet      := .t.
Local aRet      := {}
Local aTela     := {}
Private cCodVol := ""

If Empty(cVolume) .And. (!_lSepCxF .Or. Upper(AllTrim(u_DipUsr()))$GetNewPar("ES_USRPVOL","EMATIAS/DDOMINGOS/MCANUTO/RBORGES"))
	aTela := VTSave()
	VtClear()
	If VtModelo()=="RF"
		@ 1,0 VtSay "Digite o codigo do"  //"Digite o codigo do"
		@ 2,0 VtSay "tipo de embalagem"  //"tipo de embalagem"
		If ExistBlock("ACD170EB")
			cRet := ExecBlock("ACD170EB")
			If ValType(cRet)=="C"
				cCodEmb := cRet
			EndIf
		EndIf
		@ 3,0 VTGet cCodEmb pict "@!"  Valid VldEmb(cCodEmb) F3 'CB3'
		VTRead
	Else
		@ 0,0 VtSay "Tipo de embalagem"  //"Tipo de embalagem"
		If ExistBlock("ACD170EB")
			cRet := ExecBlock("ACD170EB")
			If ValType(cRet)=="C"
				cCodEmb := cRet
			EndIf
		EndIf
		@ 1,0 VTGet cCodEmb pict "@!"  Valid VldEmb(cCodEmb) F3 'CB3'
		VTRead
	EndIf

	If VTLastkey() == 27
		VtRestore(,,,,aTela)
		VtKeyboard(Chr(20))  // zera o get
		Return .f.
	EndIf
	VtRestore(,,,,aTela)
	If ExistBlock('IMG05') .and. CB5SetImp(cImp,.t.)
		cCodVol := CB6->(GetSX8Num("CB6","CB6_VOLUME"))
		ConfirmSX8()
		VTAlert("Imprimindo etiqueta de volume ","Aviso",.T.,2000) //"Imprimindo etiqueta de volume "###"Aviso"
		ExecBlock("IMG05",.f.,.f.,{cCodVol,CB7->CB7_PEDIDO,CB7->CB7_NOTA,CB7->CB7_SERIE})
		MSCBCLOSEPRINTER()

		CB6->(RecLock("CB6",.T.))
		CB6->CB6_FILIAL := xFilial("CB6")
		CB6->CB6_VOLUME := cCodVol
		CB6->CB6_PEDIDO := CB7->CB7_PEDIDO
		CB6->CB6_NOTA   := CB7->CB7_NOTA
		CB6->CB6_SERIE  := CB7->CB7_SERIE
		CB6->CB6_TIPVOL := CB3->CB3_CODEMB
		CB6->CB6_STATUS := "1"   // ABERTO
		CB6->(MsUnlock())

	EndIf
	Return .f.
Else

	If ExistBlock("ACD167VO")
		lRet:= ExecBlock("ACD167VO",.F.,.F.,{cVolume})
		If ! lRet
			Return .f.
		EndIf
	EndIf

	If UsaCB0("05")
		aRet:= CBRetEti(cVolume)
		If Empty(aRet)
			VtAlert("Etiqueta invalida","Aviso",.t.,4000,3) //"Etiqueta invalida"###"Aviso"
			VtKeyboard(Chr(20))  // zera o get
			Return .f.
		EndIf
		cCodVol:= aRet[1]
	Else
		cCodVol:= cVolume
	EndIf
	CB6->(DBSetOrder(1))
	If ! CB6->(DbSeek(xFilial("CB6")+cCodVol))
		VtAlert("Codigo de volume nao cadastrado","Aviso",.t.,4000,3)    //"Codigo de volume nao cadastrado"###"Aviso"
		VtKeyboard(Chr(20))  // zera o get
		Return .f.
	EndIf
	If CB7->CB7_ORIGEM == "1"
		If ! CB6->CB6_PEDIDO == CB7->CB7_PEDIDO
			VtAlert("Volume pertence ao pedido "+CB6->CB6_PEDIDO,"Aviso",.t.,4000,3)    //"Volume pertence ao pedido "###"Aviso"
			VtKeyboard(Chr(20))  // zera o get
			Return .f.
		EndIf
	ElseIf CB7->CB7_ORIGEM == "2"
		If ! CB6->(CB6_NOTA+CB6_SERIE) == CB7->(CB7_NOTA+CB7_SERIE)
			VtAlert("Volume pertence a nota "+CB6->(CB6_NOTA+'-'+CB6_SERIE),"Aviso",.t.,4000,3)    //"Volume pertence a nota "###"Aviso"
			VtKeyboard(Chr(20))  // zera o get
			Return .f.
		EndIf
	EndIf
EndIf
cVolume:= CB6->CB6_VOLUME
Return .t.
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ VldEmb   ³ Autor ³ ACD                   ³ Data ³ 03/01/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Validacao do Tipo de Embalagem                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAACD                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function VldEmb(cEmb)
Local lRet := .T.
If	Empty(cEmb)
	lRet := .F.
Else
	CB3->(DbSetOrder(1))
	If	! CB3->(DbSeek(xFilial("CB3")+cEmb))
		VtAlert("Embalagem nao cadastrada","Aviso",.t.,4000) //"Embalagem nao cadastrada"###"Aviso"
		VtKeyboard(Chr(20))  // zera o get
		lRet := .F.
	EndIf
EndIf
Return lRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ VldCodSep³ Autor ³ ACD                   ³ Data ³ 17/03/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Validacao da Ordem de Separacao                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAACD                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function VldCodSep()
Local lRet

dbSelectArea("CB7")

If Empty(cOrdSep)    	
	If nOpcx == 1
		SET FILTER TO (CB7->CB7_STATUS=="2" .Or. (CB7->CB7_STATUS=="3" .And. CB7->CB7_STATPA=="1")) .And. (CB7->CB7_XTM=="T" .Or.  CB7->CB7_XTOUM = "M")
	ElseIf nOpcx == 2
		SET FILTER TO (CB7->CB7_STATUS=="2" .Or. (CB7->CB7_STATUS=="3" .And. CB7->CB7_STATPA=="1")) .And. (CB7->CB7_XTM=="M" .And. CB7->CB7_XTOUM<> "M")
	EndIf      
	VtKeyBoard(chr(23))
	Return .f.             
Else
	SET FILTER TO
EndIf

CB7->(DbSetOrder(1))
If !CB7->(DbSeek(xFilial("CB7")+cOrdSep))
	VtAlert("Ordem de separacao nao encontrada.","Aviso",.t.,4000,3) //"Ordem de separacao nao encontrada."###"Aviso"
	VtKeyboard(Chr(20))  // zera o get
	Return .F.    
ElseIf !Empty(CB7->CB7_NOTA)
	VtAlert("Ordem de separacao já faturada.","Aviso",.t.,4000,3)
	VtKeyboard(Chr(20))  // zera o get
	Return .F.    
EndIf

If !("02") $ CB7->CB7_TIPEXP
	VtAlert("Ordem de separacao nao configurada para embalagem","Aviso",.t.,4000,3) //"Ordem de separacao nao configurada para embalagem"###"Aviso"
	VtKeyboard(Chr(20))  // zera o get
	Return .F.
EndIf

If CB7->CB7_STATUS == "0" .OR. CB7->CB7_STATUS == "1"
	VtAlert("Ordem de separacao possui itens nao separados","Aviso",.t.,4000,3) //"Ordem de separacao possui itens nao separados"###"Aviso"
	VtKeyboard(Chr(20))  // zera o get
	Return .F.
EndIf


//0-Inicio;1-Separando;2-Sep.Final;3-Embalando;4-Emb.Final;5-Gera Nota;6-Imp.nota;7-Imp.Vol;8-Embarcado;9-Embarque Finalizado
If "03" $ CB7->CB7_TIPEXP .and. !Empty(CB7->(CB7_NOTA+CB7_SERIE))
	VtAlert("Nota ja gerada para esta Ordem de separacao","Aviso",.t.,4000,3) //"Nota ja gerada para esta Ordem de separacao"###"Aviso"
	VtKeyboard(Chr(20))  // zera o get
	Return .F.
EndIf

If !ACDGet170()
	If CB7->CB7_STATUS == "6"
		VtAlert("NF ja impressa para esta Ordem de separacao. Exclua primeiramente a NF.","Aviso",.t.,4000,3)   //"NF ja impressa para esta Ordem de separacao. Exclua primeiramente a NF."###"Aviso"
		VtKeyboard(Chr(20))  // zera o get
		Return .F.
	EndIf
	If CB7->CB7_STATUS == "7"
		VtAlert("Etiquetas oficiais de volume ja foram impressas.","Aviso",.t.,4000,3) //"Etiquetas oficiais de volume ja foram impressas."###"Aviso"
		VtKeyboard(Chr(20))  // zera o get
		Return .F.
	EndIf
EndIf

If CB7->CB7_STATUS == "8"
	VtAlert("Ordem de separacao em processo de embarque","Aviso",.t.,4000,3) //"Ordem de separacao em processo de embarque"###"Aviso"
	VtKeyboard(Chr(20))  // zera o get
	Return .F.
EndIf

If CB7->CB7_STATUS == "9" .And. !("02" $ CBUltExp(CB7->CB7_TIPEXP))
	VtAlert("Ordem de separacao encerrada","Atencao",.T.) //"Ordem de separacao encerrada"###"Atencao"
	VtKeyboard(Chr(20))  // zera o get
	Return .F.
EndIf

If Empty(CB7->CB7_XOPCON)  
	CB7->(RecLock("CB7",.F.))
		CB7->CB7_XOPCON := cCodOpe
	CB7->(MsUnLock())      
ElseIf CB7->CB7_XOPCON <> cCodOpe
	If VTYesNo("Conferencia iniciada pelo operador -> "+CB7->CB7_XOPCON+". Deseja continuar?","Atenção",.T.)
		CB7->(RecLock("CB7",.F.))
			CB7->CB7_XOPCON := cCodOpe
		CB7->(MsUnLock())      		
	Else
		VtKeyboard(Chr(20))  // zera o get
		Return .F.		
	EndIf
EndIf

If	ExistBlock("ACD167OS")                
	lRet := ExecBlock("ACD167OS",.F.,.F.,{cOrdSep,_lSepCxF}) 
	If ValType(lret) == "L" .and. ! lRet
		Return .f.
	EndIf	
Endif

Return .t. 
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³UACDV167  ºAutor  ³Microsiga           º Data ³  12/18/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Verifica se ainda tem CB9 para embalar					  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function DipTemCB9()
Local aAreaCB9 	:= CB9->(GetArea())
Local lRet 		:= .F.

CB9->(DBSetOrder(2))
lRet := CB9->(DBSeek(xFilial("CB9")+cOrdSep+Space(10)))

RestArea(aAreaCB9)

Return lRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³UACDV167  ºAutor  ³Microsiga           º Data ³  02/07/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function DipSolCB7(nOpc,bBlcVld)
Local cPedido:= ""
Local cNota  := ""
Local cSerie := ""
Local cOP  	 := ""
Local cTM 	 := ""
Local aTela	 := VtSave()
Private nOpcx  	 := 0                  

@ 0,0 VTSAY "Ordem tipo T ou M"
@ 1,0 VTSay "Selecione: "
nOpcx:=VTaChoice(3,0,6,VTMaxCol(),{"T-Terreo","M-Mezanino"})

VTCLear()         

If nOpc == 0
	Return Eval(bBlcVld)
ElseIf nOpc ==1  // por codigo da Ordem de Separacao
   	cOrdSep := Space(6)        
   	@ If(VTModelo()=="RF",2,0),0 VTSay 'Informe o codigo:'
	@ If(VTModelo()=="RF",3,1),0 VTGet cOrdSep PICT "@!" F3 "CB7DIP"  Valid Eval(bBlcVld)
	VTRead                                                                        		
ElseIf nOpc ==2 // por pedido
	cPedido := Space(6)
	@ If(VTModelo()=="RF",2,0),0 VTSay 'Informe o Pedido'
	@ If(VTModelo()=="RF",3,1),0 VTSay 'de venda: ' VTGet cPedido PICT "@!"  F3 "CBL"  Valid (VldGet(cPedido) .and. CBSelCB7(1,cPedido) .and. Eval(bBlcVld))
	VTRead                                                                        		
ElseIf nOpc ==3 // por Nota fiscal    
    cNota  := Space(TamSx3("F2_DOC")[1])
    cSerie := Space(TamSx3("F2_SERIE")[1])
	@ If(VTModelo()=="RF",2,0),00 VTSay 'Informe a NFS'
    @ If(VTModelo()=="RF",3,1),00 VTSAY  'Nota  ' VTGet cNota   pict '@S<20>' F3 "CBM"  Valid VldGet(cNota)
	@ If(VTModelo()=="RF",3,1),14 VTSAY '-' VTGet cSerie  pict '@!'   	  Valid Empty(cSerie) .or. CBSelCB7(2,cNota+cSerie) .and. Eval(bBlcVld)
	VTRead                                                                        	   
ElseIf nOpc ==4 // por OP
    cOP:= Space(13)      
 	If VTModelo()=="RF"   
	   	@ 2,0 VTSay 'Informe a Ordem'
		@ 3,0 VTSay 'de Producao: 
	Else 
	   	@ 0,0 VTSay 'Ordem de Producao:'
	EndIf	
	@ If(VTModelo()=="RF",4,1),0 VTGet cOP Pict "@!" F3 "SC2" Valid (VldGet(cOp) .and. CBSelCB7(3,cOP) .and. Eval(bBlcVld) )
	VTRead                                                                        		
EndIf     

VTRestore(,,,,aTela)

If VTLastKey() == 27
 	Return .f.
EndIf

Return .t.

//Verifica se o conteudo da variavel esta em branco, caso esteja chama consulta F3 da mesma
Static Function VldGet(cVar)
If Empty(cVar)
	VtKeyBoard(chr(23))
	Return .F.
EndIf
Return .T.

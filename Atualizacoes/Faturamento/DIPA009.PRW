#include "rwmake.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Fun‡…o    ³ DIPA009  ³ Autor ³    Alexandro Dias     ³ Data ³ 06.02.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Permite alterar a comissao do Pedido mesmo quando ja foi   ³±±
±±³          ³ faturado.                                                  ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function DIPA009()

Local _aCores := {;
{ "C5_LIBEROK=='S' .And. C5_NOTA<>'      ' " , 'DISABLE'},; // Encerrado
{"C5_LIBEROK=='S'  .And. C5_NOTA=='      ' " , 'ENABLE'},;                     // Liberado
{"C5_LIBEROK==' '  .And. C5_NOTA=='      ' " , 'BR_AMARELO'}}                  // Aberto

Private cCadastro  := OemToAnsi("Manutencao de Comissao")

Private _aCoresLeg := {;
{"ENABLE","Pedido Liberado"},;
{"DISABLE"   , "Pedido Faturado"},;
{"BR_AMARELO", "Pedido em Aberto" }}

Private aRotina := {;
{ "Pesquisa","AxPesqui", 0 , 1},;
{ "Visualiza",'U_UOpcao(2)', 0 , 2},;
{ "Altera",'U_UOpcao(3)', 0 , 4, 20 },;
{ 'LegEnda','BrwLegEnda(cCadastro,"LegEnda",_aCoresLeg)', 0 , 5}}
U_DIPPROC(ProcName(0),U_DipUsr()) // JBS 05/10/2005 - Gravando o nome do Programa no SZU
DbSelectArea("SC5")
DbSetOrder(1)

mBrowse( 7, 4,20,74,"SC5",,,,,,_aCores)

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Fun‡…o    ³ UOpcao   ³ Autor ³    Alexandro Dias     ³ Data ³ 06.02.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Executa a GetDados para alteracao da comissao.             ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function UOpcao(_nOpcao)

Local _xAlias := GetArea()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Tipos das Opcoes						  ³
//³ _nOpcao == 1 -> Incluir					  ³
//³ _nOpcao == 2 -> Visualizar                ³
//³ _nOpcao == 3 -> Alterar                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Local bCampoSC5	:= { |nCPO| Field(nCPO) }
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Arrays de controle dos campos que deverao ser alterados  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local aCposAlt := {"C6_COMIS1 ","C6_COMIS2 "}
Local nCntFor
Local _ni
Private aSize   := MsAdvSize()
Private aInfo   := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 5, 5 }
Private aObjects:= { { 100, 100, .T., .T. } , { 100, 100, .T., .T. } }
Private aPosObj := MsObjSize( aInfo, aObjects,.T.)                      
Private aHeader := {}
Private aCols 	:= {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria variaveis M->????? da Enchoice                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nCntFor := 1 TO FCount()
	M->&(EVAL(bCampoSC5,nCntFor)) := FieldGet(nCntFor)
Next nCntFor

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria aHeader e aCols da GetDados                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nUsado:=0
SX3->(dbSetOrder(1))
If SX3->(dbSeek("SC6"))
	aHeader:={}
	While !SX3->(Eof()) .And.(SX3->X3_ARQUIVO=="SC6")
		If X3USO(SX3->X3_USADO).And.cNivel>=SX3->X3_NIVEL
			nUsado:=nUsado+1
			Aadd(aHeader,{ TRIM(SX3->X3_TITULO),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,;
			SX3->X3_DECIMAL,"AllwaysTrue()",SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_ARQUIVO,SX3->X3_CONTEXT} )
		EndIf
		SX3->(dbSkip())		
	EndDo
EndIf
	
If _nOpcao == 1
	aCols:={Array(nUsado+1)}
	aCols[1,nUsado+1]:=.F.
	For _ni:=1 to nUsado
		aCols[1,_ni]:=CriaVar(aHeader[_ni,2])
	Next
Else
	aCols:={}
	SC6->(dbSetOrder(1))
	If SC6->(dbSeek(xFilial("SC6")+M->C5_NUM))
		While !SC6->(Eof()) .And. SC6->C6_NUM==M->C5_NUM
			AADD(aCols,Array(nUsado+1))
			For _ni:=1 to nUsado
				aCols[Len(aCols),_ni]:=SC6->(FieldGet(FieldPos(aHeader[_ni,2])))
			Next
			aCols[Len(aCols),nUsado+1]:=.F.
			SC6->(dbSkip())
		EndDo              
	EndIf
EndIf

IF Len(aCols)>0
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Executa a Modelo 3                                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cTitulo:=OemToAnsi("Manutencao de Comissao")
	cAliasGetD:="SC6"
	cLinOk:="AllwaysTrue()"
	cTudoOk:="U_UATUCOMISS()"
	aCpoEnchoice:={}
	aAltEnchoice := {"C5_VEND1"} //Andre Mendes - [Obify] - 16/03/2022
	
	Private Altera:=.t.,Inclui:=.t.,lRefresh:=.t.,aTELA:=Array(0,0),aGets:=Array(0),;
	bCampo:={|nCPO|Field(nCPO)},nPosAnt:=9999,nColAnt:=9999
	Private cSavScrVT,cSavScrVP,cSavScrHT,cSavScrHP,CurLen,nPosAtu:=0	
	
	DEFINE MSDIALOG oDlg TITLE cTitulo From aSize[7],0 to aSize[6]-30,aSize[5]-50	of oMainWnd PIXEL
	EnChoice("SC5",SC5->(Recno()),3,,,,aCpoEnchoice,{aPosObj[1,1],aPosObj[1,2],aPosObj[1,3],aPosObj[1,4]-25},aAltEnchoice,3,,,,,,.F.)    
	oGetDados := MsGetDados():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,3]-10,aPosObj[2,4]-25,_nOpcao,cLinOk,cTudoOk,"",,aCPosAlt,1,,Len(aCols))
	ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,{||nOpca:=1,IF(oGetDados:TudoOk(),IF(!obrigatorio(aGets,aTela),nOpca := 0,oDlg:End()),nOpca := 0)},{||oDlg:End()})
	
EndIF

RestArea(_xAlias)

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Fun‡…o    ³UATUCOMISS³ Autor ³    Alexandro Dias     ³ Data ³ 06.02.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Atualiza o percentual de comissao.                         ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function UATUCOMISS()

Processa({|| ProcComis() })

MsgBox("Execute a rotina de Recalculo de Comissoes no Modulo Financeiro"+Chr(13)+"para atualizacao dos valores de Comissao !!!","Atencao","INFO")

Return(.T.)

Static Function ProcComis()                                                                   
Local _nPosItem   := aScan(aHeader,{|x| Alltrim(x[2])=="C6_ITEM"})
Local _nPosProd   := aScan(aHeader,{|x| Alltrim(x[2])=="C6_PRODUTO"})
Local _nPos1Comis := aScan(aHeader,{|x| Alltrim(x[2])=="C6_COMIS1"})
Local _nPos2Comis := aScan(aHeader,{|x| Alltrim(x[2])=="C6_COMIS2"})
Local _cNumPed    := M->C5_NUM
Local _aMsgCom	  := {}
Local _cFrom	  := "protheus@dipromed.com.br"
Local _cAssunto   := EncodeUTF8("Alteração de Comissão","cp1252")
Local _cFuncSent  := "UATUCOMISS(DIPA009)"
Local _cEmail	  := GetNewPar("ES_UATUCOM","maximo.canuto@dipromed.com.br;diego.domingos@dipromed.com.br")
Local _cEnvCIC	  := GetNewPar("ES_UATUCOC","MAXIMO.CANUTO,DIEGO.DOMINGOS")
Local _nLin
Local cExec := ""
ProcRegua(Len(aCols))

SC6->(DbSetOrder(1))
SD2->(DbSetOrder(8))
SF2->(DbSetOrder(1))
SE1->(DbSetOrder(30))

Aadd( _aMsgCom,{ "Pedido: "     , AllTrim(_cNumPed)  } )
Aadd( _aMsgCom,{ "Data/Hora: "	, DtoC(dDataBase)+" - "+SubStr(Time(),1,2)+":"+SubStr(Time(),4,2) } )
//Andre Mendes - [Obify] - 16/03/2022 - gravacao do codigo do vendedor

RecLock("SC5", .f.)
	SC5->C5_VEND1 := M->C5_VEND1
SC5->(MsUnlock())

For _nLin := 1 to Len(aCols)
	If SD2->(DbSeek( xFilial("SD2") + _cNumPed + aCols[_nLin,_nPosItem]))
		cExec := "UPDATE "+RetSQLName("SF2")+" SET F2_VEND1 = '"+M->C5_VEND1+"' WHERE D_E_L_E_T_ = '' AND F2_FILIAL = '"+SD2->D2_FILIAL+"' AND F2_DOC = '"+SD2->D2_DOC+"' AND F2_SERIE = '"+SD2->D2_SERIE+"' AND  F2_CLIENTE = '"+SD2->D2_CLIENTE+"' AND F2_LOJA = '"+SD2->D2_LOJA+"' "
		TCSQLExec(cExec)	
	Endif
Next

cExec :="UPDATE "+RetSQLName("SE1")+" SET E1_VEND1 = '"+M->C5_VEND1+"' WHERE D_E_L_E_T_ = '' AND E1_PEDIDO = '"+_cNumPed+"' and E1_FILORIG = '"+xFilial("SC5")+"'"

TCSQLExec(cExec)


For _nLin := 1 to Len(aCols)

	If SC6->(DbSeek( xFilial("SC6") + _cNumPed + aCols[_nLin,_nPosItem] + aCols[_nLin,_nPosProd] ))	
		If SC6->C6_COMIS1<>aCols[_nLin,_nPos1Comis] .Or. SC6->C6_COMIS2<>aCols[_nLin,_nPos2Comis]
			Aadd(_aMsgCom,{"Produto/Item",AllTrim(aCols[_nLin,_nPosProd])+"/"+AllTrim(aCols[_nLin,_nPosItem])  })
			//Aadd(_aMsgCom,{"COMIS1"      ,"A-("+Alltrim(Str(SC6->C6_COMIS1))+"%) / D-("+Alltrim(Str(aCols[_nLin,_nPos1Comis]))+"%)" })	     
			//Aadd(_aMsgCom,{"COMIS2"      ,"A-("+Alltrim(Str(SC6->C6_COMIS2))+"%) / D-("+Alltrim(Str(aCols[_nLin,_nPos2Comis]))+"%)" })	     

			Aadd(_aMsgCom,{"ANTES"      ,"C1-("+Alltrim(Str(SC6->C6_COMIS1))+"%) / C2-("+Alltrim(Str(SC6->C6_COMIS2))+"%) " })	     
			Aadd(_aMsgCom,{"DEPOIS"     ,"C1-("+Alltrim(Str(aCols[_nLin,_nPos1Comis]))+"%) / C2-("+Alltrim(Str(aCols[_nLin,_nPos2Comis]))+"%)" })	     
			
			SC6->(RecLock("SC6",.F.))
			SC6->C6_COMIS1 := aCols[_nLin,_nPos1Comis]
			SC6->C6_COMIS2 := aCols[_nLin,_nPos2Comis]
			SC6->(MsUnLock("SC6"))
			
			If SD2->(DbSeek( xFilial("SD2") + _cNumPed + aCols[_nLin,_nPosItem]))
				Do while SD2->(!EOF()) .AND. ;
				  ( xFilial("SD2") + _cNumPed + aCols[_nLin,_nPosItem]) == SD2->D2_FILIAL+SD2->D2_PEDIDO+SD2->D2_ITEMPV
					SD2->(RecLock("SD2",.F.))
					SD2->D2_COMIS1 := aCols[_nLin,_nPos1Comis]
					SD2->D2_COMIS2 := aCols[_nLin,_nPos2Comis]
					SD2->(MsUnLock("SD2"))
					SD2->(DbSkip())
				EndDo
			EndIF				
		EndIf
	EndIf
	IncProc("Alterando Comissoes...")	
Next

Aadd( _aMsgCom,{ "Usuário:  "            , U_DipUsr() } )

U_UEnvMail(_cEmail,_cAssunto,_aMsgCom,"",_cFrom,_cFuncSent)       

cMsgCIC := " "	

cMsgCIC := "*ALTERAÇÃO DE COMISSÃO*"+CHR(10)+CHR(13)
cMsgCIC += 'O usuário "'+u_DipUsr()+'" alterou a comissão do pedido:'+CHR(10)+CHR(13)
cMsgCIC += _cNumPed+CHR(10)+CHR(13)
cMsgCIC += 'Foi enviado um e-mail com os detalhes da alteração.'+CHR(10)+CHR(13)
cMsgCIC += " "+CHR(10)+CHR(13)
cMsgCIC += "E-mail enviado para:"+CHR(10)+CHR(13)
cMsgCIC += _cEmail

U_DIPCIC(cMsgCIC,_cEnvCIC)


Return

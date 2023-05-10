/*====================================================================================\
|Programa  | DIPA027       | Autor | Rafael de Campos Falco     | Data | 19/11/2004   |
|=====================================================================================|
|Descrição | Gera entrada de NFE no SD1 e SF1                                         |
|=====================================================================================|
|Sintaxe   | DIPA027                                                                  |
|=====================================================================================|
|Uso       | Especifico DIPROMED                                                      |
|=====================================================================================|
|=====================================================================================|
|Histórico | DD/MM/AA - Descrição da alteração                                        |
+----------+--------------------------------------------------------------------------+
| RAFAEL   | 16/02/05 -                                                               |
+----------+--------------------------------------------------------------------------+
|          |   /  /   -                                                               |
+----------+--------------------------------------------------------------------------+
\====================================================================================*/

#include "rwmake.ch"

User Function DIPA027()
Local _xAlias  := GetArea()
Private lMsHelpAuto := .t.  // se .t. direciona as mensagens de help
Private lMsErroAuto := .f. //necessario a criacao, pois sera
Private aRotina :={{ "Pesquisar" ,"AxPesqui"    , 0 , 1},{ "Gerar"     ,"U_GeraF1D1()" , 0 , 2}}
Private lDipa027:= .T. // MCVN - 28/06/10

U_DIPPROC(ProcName(0),U_DipUsr()) // MCVN - 22/01/2009

/*====================================================================================\
|  Define o cabecalho da tela de atualizacoes                                         |
\====================================================================================*/
cCadastro := "Notas fiscais de Entrada de produtos em poder de terceiros"
cMarca := GetMark()

aCampos  := {}
AADD(aCampos,{"F2_OK3"				,"" ,""})
AADD(aCampos,{"F2_DOC"				,"" ,"Documento"})
AADD(aCampos,{"F2_SERIE"			,"" ,"Série"})
AADD(aCampos,{"F2_CLIENTE"			,"" ,"Cliente"})
AADD(aCampos,{"F2_LOJA"				,"" ,"Loja"})
AADD(aCampos,{"F2_COND"				,"" ,"Condição"})
AADD(aCampos,{"F2_DUPL"				,"" ,"Duplicata"})
AADD(aCampos,{"F2_EMISSAO"			,"" ,"Emissão"})
AADD(aCampos,{"F2_EST"				,"" ,"Estado"})

//MarkBrow("SF2","F2_OK3",,,,cMarca)
MarkBrow("SF2","F2_OK3",,aCampos,,cMarca)
RestArea(_xAlias)

Return


/*====================================================================================\
|Programa  | GeraF1D1         | Autor | Rafael de Campos Falco     | Data | 19/11/2004|
|=====================================================================================|
|Descrição | Gera entrada de NFE no SD1 e SF1                                         |
|=====================================================================================|
|Sintaxe   | GeraF1D1                                                                 |
|=====================================================================================|
|Uso       | Especifico DIPROMED                                                      |
|=====================================================================================|
|........................................Histórico....................................|
|Rafael    | DD/MM/AA - Descrição                                                     |
|Eriberto  | DD/MM/AA - Descrição                                                     |
\====================================================================================*/

User Function GeraF1D1()

Processa({|lEnd| _Gerando()},"Gerando nota fiscal de entrada...")

Return

Static Function _Gerando()
Local _AreaSF2 := SF2->(GetArea())
Local _AreaSD2 := SD2->(GetArea())
Local _AreaSF1 := SF1->(GetArea())
Local _AreaSD1 := SD1->(GetArea())
Local _AreaSB6 := SB6->(GetArea())

Local cPedido := ""
Local _nEE := 1
Local _aAuxiliar:= {}
Local aCab   := {}
Local aItem  := {}
Local aItenS := {}
Local aSaldoB6 := {}
Local _lGeraNF := .T.

// LOCALIZA NF SELECIONADA NO BROWSE
Dbselectarea("SF2")
DbSetOrder(10)
SF2->( DbSeek( xFilial("SF2") + cMarca ) )
While !SF2->(Eof()) .AND. xFILIAL("SF2") == SF2->F2_FILIAL .AND. cMarca == SF2->F2_OK3 // FAZ ENQUANTO FOR NF SELECIONADAS
	
	// DADOS DO CABEÇALHO DA NOTA
	aCab := ;
	{{"F1_TIPO"		,"B"				,NIL},;
	{"F1_FORMUL"	,"N"				,NIL},;
	{"F1_DOC"		,SF2->F2_DOC		,NIL},;
	{"F1_SERIE"		,SF2->F2_SERIE		,NIL},;
	{"F1_EMISSAO"	,SF2->F2_EMISSAO	,NIL},;
	{"F1_FORNECE"	,SF2->F2_CLIENTE	,NIL},;
	{"F1_LOJA"		,SF2->F2_LOJA		,NIL},;
	{"F1_COND"		,"000"				,NIL},;
	{"F1_ESPECIE"	,"NF"				,NIL},;
	{"CONDICAO"		,"000"				,NIL},;
	{"CNATUREZA"	,"R112100"			,NIL}}
	
	ProcRegua(100)
	
	_lGeraNF := .T.
	
	// LOCALIZA ITEM DA NF SELECIONADA
	Dbselectarea("SD2")
	DbSetOrder(3)
	SD2->( DbSeek( xFilial("SD2") + SF2->F2_DOC + SF2->F2_SERIE + SF2->F2_CLIENTE + SF2->F2_LOJA ) )
	cPedido := SD2->D2_PEDIDO
	While !SD2->(Eof()) .AND. SD2->D2_DOC + SD2->D2_SERIE + SD2->D2_CLIENTE + SD2->D2_LOJA == SF2->F2_DOC + SF2->F2_SERIE + SF2->F2_CLIENTE + SF2->F2_LOJA // FAZ ENQUANTO FOR NF SELECIONADAS
		
		IncProc("Nota -> "+SF2->F2_DOC)
		
		// VERIFICA SE NF SELECIONADA É CONSIGNACAO                                                 
		If SD2->D2_TES <> "514" .And. cEmpAnt+cFilAnt == "0401" // Gerar nota de entrada para baixar SB6 na HQ
			MSGINFO("TES "+ SD2->D2_TES +" da nota fiscal " + SF2->F2_DOC + " não pode ser gerada.")
			_lGeraNF := .F.
			Exit
		ElseIf !(SD2->D2_TES$"528/558/728/758") .And. cEmpAnt+cFilAnt <> "0401"
			MSGINFO("TES "+ SD2->D2_TES +" da nota fiscal " + SF2->F2_DOC + " não pode ser gerada.")
			_lGeraNF := .F.
			Exit
		Else
				
			// LOCALIZA PRODUTO NO SB6 PARA VERIFICAR SALDO E IDENT
			Dbselectarea("SB6")
			DbSetOrder(1)
			
			nRestoD2 := SD2->D2_QUANT
			If DbSeek(xFilial("SB6") + SD2->D2_COD + SD2->D2_CLIENTE + SD2->D2_LOJA )
				While SB6->(!EOF()) .AND. (SB6->B6_PRODUTO + SB6->B6_CLIFOR + SB6->B6_LOJA == SD2->D2_COD + SD2->D2_CLIENTE + SD2->D2_LOJA)
					
					// VERIFICA SE SALDO DO SB6 NÃO ESTÁ ZERADO
					If SB6->B6_SALDO > 0
						
						// alimento array auxiliar
						If aScan(aSaldoB6, { |x| Alltrim(x[1]) == SB6->B6_IDENT}) == 0 .OR. ;
					   	(aScan(aSaldoB6, { |x| Alltrim(x[1]) == SB6->B6_IDENT}) <> 0 .AND.  ;
						aSaldoB6[aScan(aSaldoB6, { |x| Alltrim(x[1]) == SB6->B6_IDENT}),3] > 0 .AND.;
						SB6->B6_PRUNIT == SD2->D2_PRCVEN)
						// B6_IDENT, QUANTIDADE, B6_SALDO, B6_CUSTO1, B6_DOC, B6_SERIE, ITEM ????, D2_LOTECTL, D2_NUMLOTE, D2_DTVALID
							AaDd(_aAuxiliar,{	SB6->B6_IDENT,;
												0,;
												SB6->B6_SALDO,;
												SB6->B6_CUSTO1,;
												SB6->B6_DOC,;
												SB6->B6_SERIE,;
												DipRetINF(SB6->B6_DOC,SB6->B6_SERIE,SB6->B6_PRODUTO,SB6->B6_CLIFOR,SB6->B6_LOJA),;
												"",;
												"",;
												CTOD("")})
							AaDd(aSaldoB6,{SB6->B6_IDENT,0,SB6->B6_SALDO})
						Else
							//If aSaldoB6[aScan(aSaldoB6, { |x| Alltrim(x[1]) == SB6->B6_IDENT}),3] <= 0
								SB6->(DbSkip())
								Loop
							//EndIf
						EndIf
						
						// VERIFICA SE PREÇO UNITÁRIO SÃO IGUAIS
						If SB6->B6_PRUNIT <> SD2->D2_PRCVEN
							MSGINFO("O preço unitário da nota fiscal " + SF2->F2_DOC + " está diferente."+Chr(13)+Chr(13)+'Produto: '+SD2->D2_COD+Chr(13)+Chr(13)+'PODER 3o.-> '+Transform(SB6->B6_PRUNIT,"@E 999,999.9999")+Chr(13)+'NA NOTA -> '+Transform(SD2->D2_PRCVEN,"@E 999,999.9999"))
						EndIf
						
						If nRestoD2 <= _aAuxiliar[aScan(_aAuxiliar, { |x| Alltrim(x[1]) == SB6->B6_IDENT}),3]
							_aAuxiliar[aScan(_aAuxiliar, { |x| Alltrim(x[1]) == SB6->B6_IDENT}),2] := nRestoD2
							aSaldoB6[aScan(aSaldoB6, { |x| Alltrim(x[1]) == SB6->B6_IDENT}),3] -= nRestoD2
							nRestoD2 -= nRestoD2
						Else
							_aAuxiliar[aScan(_aAuxiliar, { |x| Alltrim(x[1]) == SB6->B6_IDENT}),2] := SB6->B6_SALDO
							aSaldoB6[aScan(aSaldoB6, { |x| Alltrim(x[1]) == SB6->B6_IDENT}),3] -= SB6->B6_SALDO
							nRestoD2 -= SB6->B6_SALDO
						EndIf
						
						If nRestoD2 <= 0
							Exit
						EndIf
					EndIf
					SB6->(DbSkip())
				EndDo
				
				If nRestoD2 > 0
					MSGINFO("Nao tem saldo suficiente em poder de terceiros " + SD2->D2_COD +Chr(13)+Chr(13)+ " Falta: "+Transform(nRestoD2,"@E 999,999,999"))
					RestArea(_AreaSB6)
					RestArea(_AreaSD1)
					RestArea(_AreaSF1)
					RestArea(_AreaSD2)
					RestArea(_AreaSF2)
					Return
				EndIf
				
				For xi:=1 to Len(_aAuxiliar)
					aItem:={}
					aadd(aItem,{"D1_COD"		,SD2->D2_COD		,NIL})
					aadd(aItem,{"D1_UM"			,SD2->D2_UM			,NIL})
					aadd(aItem,{"D1_QUANT"		,_aAuxiliar[xi,2]	,NIL})
					aadd(aItem,{"D1_VUNIT"		,SD2->D2_PRUNIT		,NIL})
					aadd(aItem,{"D1_TOTAL"		,NoRound(_aAuxiliar[xi,2]*SD2->D2_PRUNIT,2)	,NIL})
					aadd(aItem,{"D1_VALIPI"		,SD2->D2_VALIPI		,NIL})
					aadd(aItem,{"D1_VALICM"		,SD2->D2_VALICM		,NIL})
					aadd(aItem,{"D1_TES"		,"216"				,NIL})
					aadd(aItem,{"D1_CF"			,Posicione("SF4",1,xFilial("SF4") + "216","SF4->F4_CF"),NIL})
					aadd(aItem,{"D1_RATEIO"		,"2"				,NIL})
					aadd(aItem,{"D1_LOCAL"		,SD2->D2_LOCAL		,NIL})
					aadd(aItem,{"D1_IDENTB6"	,_aAuxiliar[xi,1]	,NIL})
					aadd(aItem,{"D1_NFORI"		,_aAuxiliar[xi,5]	,NIL})
					aadd(aItem,{"D1_SERIORI"	,_aAuxiliar[xi,6]	,NIL})
					aadd(aItem,{"D1_ITEMORI"	,_aAuxiliar[xi,7]	,NIL})
					aadd(aItem,{"AUTDELETA"		,"N"				,NIL})
					
					AaDd(aItens,aItem)
				Next
			EndIf
		EndIf
		SD2->(DbSkip())
		_aAuxiliar:= {}
	EndDo
	         
	If _lGeraNF
		lExit=.F.	
		While .T.
			Begin Transaction
			MSExecAuto({|x,y,z| MATA103(x,y,z)},aCab,aItenS,3)
			If lMsErroAuto
				Mostraerro()
				
				DisarmTransaction()
				RestArea(_AreaSB6)
				RestArea(_AreaSD1)
				RestArea(_AreaSF1)
				RestArea(_AreaSD2)
				RestArea(_AreaSF2)
				Return
			Else
				lExit=.T.
			EndIf
			End Transaction
			if lExit
				exit
			Endif
		EndDo
		
		MSGINFO("A nota fiscal " + SF1->F1_DOC + " foi gerada com sucesso.")
		SF2->(DbSkip())
	EndIf	
EndDo

If Len(aCab) == 0
	MSGINFO("Não foi selecionada nenhuma Nota Fiscal.")
EndIf

// APAGA MARCA DE SELECIONADO DIRETO DA BASE DE DADOS (SF2 - F2_OK3)
Dbselectarea("SF2")
DbSetOrder(10)
DbSeek(xFilial("SF2")+cMarca)
While !Eof() .AND. xFILIAL("SF2") == SF2->F2_FILIAL
	RecLock("SF2",.F.)
	SF2->F2_OK3 := ''
	SF2->(MsUnlock())
	SF2->(DbSeek(xFilial("SF2")+cMarca))
EndDo

RestArea(_AreaSB6)
RestArea(_AreaSD1)
RestArea(_AreaSF1)
RestArea(_AreaSD2)
RestArea(_AreaSF2)

Return
/////////////////////////////////




/*====================================================================================\
|Programa  | ValidaErro    | Autor | Rafael de Campos Falco     | Data | 17/12/2004   |
|=====================================================================================|
|Descrição | Valida o Erro para um possível ajuste                                    |
|=====================================================================================|
|Sintaxe   | ValidaErro                                                               |
|=====================================================================================|
|Uso       | Especifico DIPROMED                                                      |
|=====================================================================================|
|=====================================================================================|
|Histórico | DD/MM/AA - Descrição da alteração                                        |
+----------+--------------------------------------------------------------------------+
|          |   /  /   -                                                               |
+----------+--------------------------------------------------------------------------+
|          |   /  /   -                                                               |
+----------+--------------------------------------------------------------------------+
\====================================================================================*/

/*User Static ValidaErro()
Local nNew_Val := 0

For xi=1 To Len(aItens)
@ 126,000 To 230,300 DIALOG oDlg TITLE OemToAnsi(" NF - " + aItens[] )
@ 020,010 Say "Valor Original: " + ALLTRIM(TRANSFORM(aItens[],'@E 999,999,999,999.99'))
@ 020,055 Get nNew_Val Size 93,20 Picture "@E 999,999,999,999.99"
@ 040,050 BMPBUTTON TYPE 1 ACTION Close(odlg)
ACTIVATE DIALOG oDlg Centered
If nNew_Val > 0
aItens[] := nNew_Val
nNew_Val := 0
EndIf
Next

lMsErroAuto := .T.

Return*/

Static Function DipRetINF(cDocNF,cSerie,cCodPro,cCliFor,cLoja)
Local cSQL := ""
Local cRet := ""

cSQL := " SELECT" 
cSQL += " 	D2_ITEM " 
cSQL += " 	FROM " 
cSQL +=  		RetSQLName("SD2") 
cSQL += " 		WHERE " 
cSQL += " 			D2_FILIAL	= '"+xFilial("SD2")+"' AND "
cSQL += " 			D2_DOC 		= '"+cDocNF+"' AND " 
cSQL += " 			D2_SERIE	= '"+cSerie+"' AND "
cSQL += " 			D2_COD 		= '"+cCodPro+"' AND "
cSQL += " 			D2_CLIENTE 	= '"+cCliFor+"' AND " 
cSQL += " 			D2_LOJA 	= '"+cLoja+"' AND " 
cSQL += " 			D_E_L_E_T_ 	= ' ' "

cSQL := ChangeQuery(cSQL)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),"QRYITEM",.T.,.T.)

If !QRYITEM->(Eof())
	cRet := QRYITEM->D2_ITEM
EndIf
QRYITEM->(dbCloseArea())

Return cRet
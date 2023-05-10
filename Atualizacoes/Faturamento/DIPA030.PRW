/*---------------------------------------------------------------------------------------*

Empresa.......: DIPOMED Comércio e Importação Ltda.
Programa......: DIPA030.PRW

Objetivo......: Colocar o numero correto dos formularios de notas
Impressas a partir do dia 01/06/2005.

Autor.........: Jailton B Santos (JBS), Analista de Sistemas.
Data..........: 12 Jul 2005
Versão........: 1.0

*---------------------------------------------------------------------------------------*/

#include "protheus.ch"
//#include "rwmake.ch"
#define f_linha chr(13)+chr(10) // Fim de Linha
*-----------------------------------------------------------------------*
User Function DIPA030()
*-----------------------------------------------------------------------*
Local oDlg
Local nOpcao := 0
Local bOK    := {|| nOpcao := 1, oDlg:End()}
Local bCancel:= {|| nOpcao := 0, oDlg:End()}
Local cMensagens:= ""
Local lNFAjuste := .F.
Local lNFSaida  := .F.
Local lNFEntrada:= .F.
Set Delete OFF

Private cNFi    := Space(len(SF2->F2_DOC))
Private cNFf    := Space(len(SF2->F2_DOC))
Private cSerie  := Space(len(SF2->F2_SERIE))
Private cFormAtI:= Space((len(SF2->F2_NFFORM)-1)/2)
Private cFormAtF:= Space((len(SF2->F2_NFFORM)-1)/2)
Private cNfFormI:= Space((len(SF2->F2_NFFORM)-1)/2)
Private cNfFormF:= Space((len(SF2->F2_NFFORM)-1)/2)
Private aHeader := {}
Private aCampos
Private cFileWork
Private lNfIni
Private lNfFim
Private lCancela:= .F.
U_DIPPROC(ProcName(0),U_DipUsr()) // JBS 05/10/2005 - Gravando o nome do Programa no SZU
aHeader  := {}
aCampos  := {}
cFileWork:= E_CriaTrab(,{;
{"WKFLAG"    ,"C",2,0},;
{"F1_DOC"    ,"C",avsx3("F1_DOC"    ,3),0},;
{"F1_SERIE"  ,"C",avsx3("F1_SERIE"  ,3),0},;
{"F1_NFFORM" ,"C",avsx3("F1_NFFORM" ,3),0},;
{"F1_NFFORMC","C",avsx3("F1_NFFORMC",3),0},;
{"F1_EMISSAO","D",8,0},;
{"WKITENS"   ,"N",5,0},;
{"WKLOTES"   ,"N",5,0},;
{"WKPAG"     ,"N",5,0},;
{"WKCNO"     ,"N",10,0},;
{"WKTIPO"    ,"C",1,0}},"Work_NF",)

IndRegua("Work_NF",cFileWork,"F1_DOC+F1_SERIE+WKTIPO")

Do While .T.
	nOpcao := 0
	Define msDialog oDlg Title "Atualisando Formularios ja impressos" From 10,10 TO 23,55
	
	cNFi    := Space(len(SF2->F2_DOC))
	cNFf    := Space(len(SF2->F2_DOC))
	cSerie  := Space(len(SF2->F2_SERIE))
	cNfFormI:= Space((len(SF2->F2_NFFORM)-1)/2)
	cNfFormF:= Space((len(SF2->F2_NFFORM)-1)/2)
	cFormAtI:= Space((len(SF2->F2_NFFORM)-1)/2)
	cFormAtF:= Space((len(SF2->F2_NFFORM)-1)/2)
	lNfIni  := .f.
	lNfFim  := .f.
	lNFAjuste:= .F.
	lCancela:= .F.
	
	@ 011,002 to 098,178 Pixel
	
	@ 018,010 say "Nota Fiscal Inicial"  Pixel
	@ 030,010 say "Nota Fiscal Final"    Pixel
	@ 042,010 say "Serie da Nota Fiscal" Pixel
	@ 060,010 say "Formulário inicial"   Pixel
	@ 072,010 say "Formulário Final"     Pixel
	
	@ 018,080 Get cNFi     Size 40,08 Pixel
	@ 030,080 Get cNFf     Size 40,08 Pixel
	@ 042,080 Get cSerie   Size 20,08 Pixel
	@ 060,080 Get cNfFormI Size 40,08 Pixel
	@ 072,080 Get cNfFormF Size 40,08 Pixel
	@ 087,010 CheckBox oCancela Var lCancela PROMPT "Cancela Formulario já preenchido" SIZE 110,008 of oDlg
	
	Activate Dialog oDlg Centered on init EnchoiceBar(oDlg,bOk,bCancel)
	
	Do Case
		Case nOpcao == 0
			Exit
		Case nOpcao == 1
			cMensagens:= ""
			Processa({|| lNFSaida  :=NFSaida()}  ,"Selecionando notas de Saida")
			If !lNFSaida
				cMensagens+=;
				"Não foram encontradas notas fiscais  de saida"+f_linha+;
				"que atendam aos dados informados pelo usuario!"+f_linha+f_linha
			EndIf
			Processa({|| lNFEntrada:=NFEntrada()},"Selecionando notas de Entrada")
			If !lNFEntrada
				cMensagens +=;
				"Não foram encontradas notas fiscais de Entrada"+f_linha+;
				"que atendam aos dados informados pelo usuario!"+f_linha+f_linha
			EndIf
			If !Empty(cMensagens)
				msgInfo(cMensagens+"Por favor Verifique os dados informados.","Atenção")
			EndIf
			If lNFEntrada .or. lNFSaida
				Processa({|| lNFAjuste:=NFAjuste()},"Ajustando o Numero dos Formularios")
			EndIf
			If lNFAjuste
				Processa({|| NFGrava()},"Gravando o Numero do Formulario")
				msgInfo(;
				"Geração do Numero do Formulario da nota fiscal"+f_linha+;
				"Concluida com sucesso!","Operação Finalizada")
			EndIf
	EndCase
	Work_NF->(__dbzap())
EndDo
Work_NF->(E_EraseArq(cFileWork))
Set Delete On
Return(.T.)
*---------------------------------------*
Static Function NFSaida()
//  Notas Fiscais de Saida
*---------------------------------------*
Local nItens   := 0
Local nContLot := 0
Local lRetorno := .F.

ProcRegua(SF2->(RecCount()))

SF2->(dbSetOrder(1))
SF2->(dbSeek(xFilial("SF2")+cNFi+cSerie,.T.))
SD2->(dbSetOrder(3))

Do While SF2->(!EOF()) .and. ;
	xFilial("SF2") == SF2->F2_FILIAL.and.;
	cNFi <= SF2->F2_DOC   .and.;
	cNFf >= SF2->F2_DOC
	
	Incproc("Verificando Nota : "+SF2->F2_DOC+SF2->F2_SERIE)
	
	If SF2->F2_SERIE != cSerie
		SF2->(DbSkip())
		Loop
	Endif
	
	nItens   := 0
	nContLot := 0
	nPag     := 0
	
	If SD2->(dbSeek(xFilial("SD2")+SF2->F2_DOC+SF2->F2_SERIE))
		DO while SD2->(!eof()) .and. xFilial("SD2") == SD2->D2_FILIAL .and. SD2->D2_DOC==SF2->F2_DOC .and. SD2->D2_SERIE==SF2->F2_SERIE
			If SD2->D2_SERIE # cSerie
				SD2->(DbSkip())
				Loop
			Endif
			nItens++
			IF !EMPTY(SD2->D2_LOTECTL)
				nContLot :=	nContLot+1
				nItens++
			ENDIF
			SD2->(Dbskip())
		EndDo
		
		lRetorno:=.T.
		nPag := Int(nItens/20) + If(Int(nItens/20)#nItens/20,1,0)
		_GrvWork("  ",SF2->F2_DOC,SF2->F2_SERIE,SF2->F2_EMISSAO,nItens,nContLot,nPag,SF2->(Recno()),"2")
	EndIf
	SF2->(dbSkip())
EndDo
Return(lRetorno)

*---------------------------------------*
Static Function NFEntrada()
//  Notas Fiscais de Entrada
*---------------------------------------*
Local nItens   := 0
Local nContLot := 0
Local lRetorno := .F.

ProcRegua(SF1->(RecCount()))

SF1->(dbSetOrder(1))
SF1->(dbSeek(xFilial("SF1")+cNFi+cSerie,.T.))
SD1->(dbSetOrder(1))

Do While SF1->(!eof()) .and.;
	xFilial("SF1") == SF1->F1_FILIAL.and.;
	cNFi <= SF1->F1_DOC   .and.;
	cNFf >= SF1->F1_DOC
	
	Incproc("Verificando Nota : "+SF1->F1_DOC+SF1->F1_SERIE)
	
	If SF1->F1_SERIE != cSerie
		SF1->(DbSkip())
		Loop
	Endif
	
	nItens   := 0
	nContLot := 0
	nPag     := 0
	
	If SD1->(dbSeek(xFilial("SD1")+SF1->F1_DOC+SF1->F1_SERIE))
		DO while SD1->(!eof()) .and. xFilial("SD1") == SD1->D1_FILIAL .and. SD1->D1_DOC==SF1->F1_DOC .and. SD1->D1_SERIE==SF1->F1_SERIE
			If SD1->D1_SERIE # cSerie
				SD1->(DbSkip())
				Loop
			Endif
			If SF1->F1_FORMUL # 'S'        // Se nao for formulario proprio
				SD1->(DbSkip())
				Loop
			Endif
			nItens++
			IF !EMPTY(SD1->D1_LOTECTL)
				nContLot :=	nContLot+1
				nItens++
			ENDIF
			SD1->(Dbskip())
		EndDo
		lRetorno := .T.
		nPag := Int(nItens/20) + If(Int(nItens/20)#nItens/20,1,0)
		_GrvWork("  ",SF1->F1_DOC,SF1->F1_SERIE,SF1->F1_EMISSAO,nItens,nContLot,nPag,SF1->(Recno()),"1")
	EndIf
	SF1->(dbSkip())
EndDo

Return(lRetorno)
*------------------------------------------------------------------------------------------------*
Static Function _GrvWork(cWKFLAG,cF2_DOC,cF2_SERIE,dF2_EMISSAO,nItens,nContLot,nPag,nRecno,cTipo)
*------------------------------------------------------------------------------------------------*
if !lNfFim
	lNfFim := cF2_DOC == cNFf
EndIf
if !lNfIni
	lNfIni := cF2_DOC == cNFi
EndIf

Work_NF->(DbAppend())
Work_NF->WKFLAG      := cWKFLAG
Work_NF->F1_DOC      := cF2_DOC
Work_NF->F1_SERIE    := cF2_SERIE
Work_NF->F1_NFFORM   := SPACE(13)
Work_NF->F1_NFFORMC  := SPACE(56)
Work_NF->F1_EMISSAO  := dF2_EMISSAO
Work_NF->WKITENS     := nItens
Work_NF->WKLOTES     := nContLot
Work_NF->WKPAG       := nPag-1
Work_NF->WKCNO       := nRecno
Work_NF->WKTIPO      := cTipo
Return(.T.)

*---------------------------------------*
Static Function NFAjuste()
//  Notas Fiscais de Entrada
*---------------------------------------*
Local cFormAtI := StrZero(val(cNfFormI),6)
Local cFormAtF := StrZero(val(cNfFormI),6)
Local lRetorno := .T.
Local cMensagem:= ""

ProcRegua(Work_NF->(RecCount()))

If !lNfIni
	cMensagem +=;
	"Não foi encontrada a primeira nota fiscal  informada" +f_linha+;
	"pelo usuario. Foi foram pesquisadas as notas fiscais" +f_linha+;
	"de entradas e saidas."+f_linha+f_linha
EndIf
If !lNfFim
	cMensagem +=;
	"Não foi encontrada a ultima nota fiscal  informada"   +f_linha+;
	"pelo usuario. Foi foram pesquisadas as notas fiscais" +f_linha+;
	"de entradas e saidas."+f_linha+f_linha
EndIf
If 	!Empty(cMensagem)
	msgInfo(cMensagem+"Por favor verifique os dados informados.","Atenção")
	return(.f.)
EndIf

Work_NF->(DbGoTop())

Do While Work_NF->(!EOF())
	
	Incproc("Ajustando o formulario da NF : "+Work_NF->F1_DOC)
	
	cFormAtF := strzero(val(cFormAtI)+Work_NF->WKPAG,6)
	Work_NF->F1_NFFORM   := cFormAtI +"/"+cFormAtF
	
	If Work_NF->F1_DOC == cNFf
		If Strzero(val(cNfFormF),6) # cFormAtF
			msgInfo(;
			"O Numero do Formulario não confere com a ultima nota informada!"+f_linha+;
			"Isto pode acontecer por existirem formularios  cancelados no"   +f_linha+;
			"intervalo de notas informadas."                                 +f_linha+f_linha+;
			"Por favor verifique e informe um periodo válido."               +f_linha+f_linha+;
			"OBS: Nenhuma nota fiscal foi alterada!","Atenção")
			lRetorno := .F.
			Exit
		EndIf
	EndIf
	cFormAtI := strzero(val(cFormAtF)+1,6)
	Work_NF->(DbSkip())
EndDo
return(.T.)
*---------------------------------------*
Static Function NFGrava()
//  Notas Fiscais de Entrada
*---------------------------------------*
Local lRetorno := .T.

ProcRegua(Work_NF->(RecCount()))

Work_NF->(DbGoTop())

Do While Work_NF->(!EOF())
	
	Incproc("Gravando Formulario da NF : "+Work_NF->F1_DOC)
	
	If Work_NF->WKTIPO=="1"  // Notas Fiscais de Entrada
		SF1->(DbGoto(Work_NF->WKCNO))
		SF1->(Reclock("SF1",.f.))
		If lCancela .and. !empty(SF1->F1_NFFORM)
			SF1->F1_NFFORMC :=  AllTrim(SF1->F1_NFFORM)+If(!empty(AllTrim(SF1->F1_NFFORMC)),", ","")+AllTrim(SF1->F1_NFFORMC)
		EndIf
		SF1->F1_NFFORM := Work_NF->F1_NFFORM
		SF1->(MsUnlock("SF1"))
	ElseIf Work_NF->WKTIPO=="2"  // Notas Fiscais de Saida
		SF2->(DbGoto(Work_NF->WKCNO))
		SF2->(Reclock("SF2",.f.))
		If  lCancela .and. !empty(SF2->F2_NFFORM)
			SF2->F2_NFFORMC:= AllTrim(SF2->F2_NFFORM)+If(!empty(AllTrim(SF2->F2_NFFORMC)),", ","")+AllTrim(SF2->F2_NFFORMC)
		EndIf
		SF2->F2_NFFORM :=  Work_NF->F1_NFFORM
		SF2->(MsUnlock("SF2"))
	EndIf
	
	Work_NF->(DbSkip())
	
EndDo
return(lRetorno)

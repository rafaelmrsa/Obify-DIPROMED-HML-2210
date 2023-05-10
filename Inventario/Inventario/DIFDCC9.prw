#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 16/02/01
#IFNDEF WINDOWS
	#DEFINE PSAY SAY
#ENDIF

User Function DIFDCC9()        // incluido pelo assistente de conversao do AP5 IDE em 16/02/01

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de variaveis utilizadas no programa atraves da funcao    ³
//³ SetPrvt, que criara somente as variaveis definidas pelo usuario,    ³
//³ identificando as variaveis publicas do sistema utilizadas no codigo ³
//³ Incluido pelo assistente de conversao do AP5 IDE                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

SetPrvt("ARETURN,CBTXT,CDESC1,CDESC2,CCABEC1,CCABEC2")
SetPrvt("CTITULO,CSTRING,CRODATXT,CNOMEPRG,NTIPO,NTAMANHO")
SetPrvt("NLASTKEY,NCNTIMPR,LABORTPRIN,WNREL,AIMP,ALOCAIS")
SetPrvt("ALOTESLOTE,AQUANTSB2T,ACLASSSB2T,AEMPENSB2T,AQUANTSB8T,ACLASSSB8T")
SetPrvt("AEMPENSB8T,AQUANTSBFT,ACLASSSBFT,AEMPENSBFT,CCOD,CLOCAL")
SetPrvt("CLOTECTL,CNUMLOTE,CARQSDA,CFILSB1,CSEEKSB2,CSEEKSB8")
SetPrvt("CSEEKSBF,CSEEKSDA,CPICTQUANT,CTIPODIF,CRASTRO,CLOCALIZA")
SetPrvt("LLOCALIZA,LRASTRO,LRASTROS,LIMPEMP,NX,NINDSDA")
SetPrvt("NQUANTSB2,NCLASSSB2,NEMPENSB2,NQUANTSB8,NCLASSSB8,NEMPENSB8")
SetPrvt("NQUANTSBF,NCLASSSBF,NEMPENSBF,NTOTREGS,NMULT,NPOSANT")
SetPrvt("NPOSATU,NPOSCNT,LI,M_PAG,NQUANTSB8T,NCLASSSB8T")

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ DIFSALDO ³ Autor ³ Fernando Joly Siquini ³ Data ³07/11/2000³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Verifica Diferen‡as de Saldo entre SB2 x SB8 x SBF         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAEST                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ PROGRAMADOR  ³ DATA   ³ BOPS ³  MOTIVO DA ALTERACAO                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³              ³        ³      ³                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
U_DIPPROC(ProcName(0),U_DipUsr()) // JBS 05/10/2005 - Gravando o nome do Programa no SZU
//-- Variaveis Gern‚ricas
aReturn    := {'Zebrado', 1,'Administra‡„o', 2, 2, 1, '',1}
cbTxt      := ''
cDesc1     := 'O objetivo deste relat¢rio ‚ exibir detalhadamente todas as diferen‡as'
cDesc2     := 'de Saldo entre os arquivos SB2 x SB8 x SBF.'
cCabec1    := ''
cCabec2    := ''
cTitulo    := 'RELACAO DE DIFERENCAS SB2xSB8xSBF'
cString    := 'SB1'
cRodaTxt   := ''
cNomePrg   := 'DIFSALDO'
nTipo      := 18
nTamanho   := 'G'
nLastKey   := 0
nCntImpr   := 0
lAbortPrin := .F.
WnRel      := 'DIFSALDO'

//-- Envia o Controle para a funcao SETPRINT
WnRel:=SetPrint(cString,WnRel,,@cTitulo,cDesc1,cDesc2,'',.F.,'')

#IFNDEF WINDOWS
	Inkey()
	nLastKey := LastKey()
#ENDIF
If nLastKey == 27
	Return Nil
Endif
SetDefault(aReturn,cString)
#IFNDEF WINDOWS
	Inkey()
	nLastKey := LastKey()
#ENDIF
If nLastKey == 27
	Return Nil
Endif

#IFDEF WINDOWS
	RptStatus({|| _DIFSALDO()},cTitulo)// Substituido pelo assistente de conversao do AP5 IDE em 16/02/01 ==> 	RptStatus({|| Execute(_DIFSALDO)},cTitulo)
	
	Return        // incluido pelo assistente de conversao do AP5 IDE em 16/02/01
	
	Static Function _DIFSALDO()
	
#ENDIF

//-- Variaveis Especificas
aImp       := {}
aLocais    := {}
aLoteSLote := {}
aQuantSB2t := {}
aClassSB2t := {}
aEmpenSB2t := {}
aQuantSB8t := {}
aClassSB8t := {}
aEmpenSB8t := {}
aQuantSBFt := {}
aClassSBFt := {}
aEmpenSBFt := {}
cCod       := ''
cLocal     := ''
cLoteCtl   := ''
cNumLote   := ''
cArqSDA    := ''
cFilSB1    := xFilial('SDC')
cSeekSB2   := ''
cSeekSB8   := ''
cSeekSBF   := ''
cSeekSDA   := ''
cPictQuant := PesqPict('SB2','B2_QATU',12)

//-- Variaveis de Controle de Impressao
nTotRegs   := 0
nMult      := 1
nPosAnt    := 4
nPosAtu    := 4
nPosCnt    := 0
Li         := 80
m_Pag      := 01
nTipo      := If(aReturn[4]==1,15,18)

cArqSDC := CriaTrab('', .F.)
IndRegua('SDC', cArqSDA, 'DC_FILIAL+DC_PEDIDO+DC_PRODUTO',,, 'Selecionando Registros...')
nIndSDC := RetIndex('SDC')
#IFNDEF TOP
	dbSetIndex(cArqSDC+OrdBagExt())
#ENDIF
dbSetOrder(nIndSDC+1)
dbGoTop()

cArqSC9 := CriaTrab('', .F.)
IndRegua('SC9', cArqSC9, 'C9_FILIAL+C9_PEDIDO+C9_PRODUTO',,, 'Selecionando Registros...')
nIndSC9 := RetIndex('SC9')
#IFNDEF TOP
	dbSetIndex(cArqSC9+OrdBagExt())
#ENDIF
dbSetOrder(nIndSC9+1)
dbGoTop()

dbSelectArea('SDC')
_lFirst := .T.

Do While !SDC->(Eof()) .And. SDC->DC_FILIAL==cFilSDC
	
	if _lFirst
		_TTSDC := 0
		_PEDIDO := SDC->DC_PEDIDO
		_PRODUTO := SDC->DC_PRODUTO
		_lFirst := .F.
	endif
	
	IF !(SDC->DC_PEDIDO+SDC->DC_PRODUTO == _PEDIDO+_PRODUTO)
		
		dbSelectArea('SC9')
		dbSetOrder(1)
		Dbseek(xFilial("SC9")+_PEDIDO+_PRODUTO)
		_ttSC9 := 0
		
		Do While !SC9->(Eof()) .And. SC9->C9_FILIAL==xFilial("SC9") .AND. SC9->C9_PEDIDO+SC9->C9_PRODUTO == _PEDIDO+_PRODUTO
			if EMPTY(ALLTRIM(SC9->C9_BLEST)) .AND. EMPTY(ALLTRIM(SC9->C9_BLCRED)) .AND. EMPTY(ALLTRIM(SC9->C9_NFISCAL))
				_ttSC9 += SC9->C9_QTDLIB
			ENDIF
		ENDDO
		
		IF !(_TTSC9 == _TTSDC)
			HELP("ERRO")
		ENDIF
		
		_TTSDC := 0
		_PEDIDO := SDC->DC_PEDIDO
		_PRODUTO := SDC->DC_PRODUTO
		
	ENDIF
	
	_ttsdc += SDC->DC_QUANT
	
	dbSelectArea('SDC')
	dbSkip()
EndDo

fErase(cArqSDC+OrdBagExt())
fErase(cArqSC9+OrdBagExt())

RETURN

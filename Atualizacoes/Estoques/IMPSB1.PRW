#include 'rwmake.ch'
#include 'protheus.ch'
#include 'topconn.ch'

#define CMD_OPENWORKBOOK			1
#define CMD_CLOSEWORKBOOK		   	2
#define CMD_ACTIVEWORKSHEET  		3
#define CMD_READCELL				4

/*============================================================================
|Programa:  |	IMPSB1 							Data ³ 09/06/20				 |
|=============================================================================
|Desc:		|   Efetuar Importação de Dados do Cadastro de Produto			 |
|===========================================================================*/


User Function IMPSB1()

Local oDlg     		:= Nil
Local oGet     		:= Nil
Local nOpcao        := 0
Private cPerg		:= "IMPSB1"
Private nOpca 		:= 0

ValidPerg() // Ajusta as Perguntas do SX1
Pergunte(cPerg,.T.) // Carrega as Perguntas do SX1

DEFINE MSDIALOG oDlg FROM  96,9 TO 310,592 TITLE OemToAnsi("Importar SB1 ") PIXEL
@ 18, 6 TO 66, 287 LABEL "" OF oDlg  PIXEL
@ 29, 15 SAY OemToAnsi("Esta rotina irá importar dados de Excel para a Tabela de Cadastro de Produtos") SIZE 268, 8 OF oDlg PIXEL
@ 38, 15 SAY OemToAnsi("utilizando os itens existentes na planilha.") SIZE 268, 8 OF oDlg PIXEL
@ 48, 15 SAY OemToAnsi("Para isto, o caminho de  localização da Planilha deve ser informado nos Parametros") SIZE 268, 8 OF oDlg PIXEL
DEFINE SBUTTON FROM 80, 196 TYPE 5 ACTION pergunte(cPerg,.T.) ENABLE OF oDlg
DEFINE SBUTTON FROM 80, 223 TYPE 1 ACTION (oDlg:End(),nOpca:=1) ENABLE OF oDlg
DEFINE SBUTTON FROM 80, 250 TYPE 2 ACTION oDlg:End() ENABLE OF oDlg
ACTIVATE MSDIALOG oDlg CENTER

If nOpca == 1
	MsAguarde({|| Implan()},OemtoAnsi("Processando itens da Planilha"))
Endif

Return

/*============================================================================
|Programa:  |	Implan 														 |
|=============================================================================
|Desc:		|   															 |
|===========================================================================*/

Static Function Implan()

Local cCamDLL := "C:\readexcel.dll"
Local nHdl	  := ExecInDLLOpen(cCamDLL)
Local cBuffer := ''
Local cDir	  := Alltrim(MV_PAR01)
Local cArq	  := Alltrim(MV_PAR02)

//Local  _cCODANT:= ''
Local  _cDESC:= ''
Local  _cTIPO:= ''
Local  _cUM:= ''
Local  _cLOCPAD:= ''
Local  _cGRUPO:= ''
Local  _nIPI:= 0
Local  _cPOSIPI:= ''
Local  _cESPECIE:= ''
Local  _cEXNCM:= ''
Local  _cEXNBM:= ''
Local  _nALIQISS:= 0
Local  _cCODISS:= ''
Local  _cTE:= ''
Local  _cTS:= ''
Local  _cGRTRIB:= ''
Local  _cIMPZFRC:= ''
Local  _cSEGUM:= ''
Local  _nCONV:= 0
Local  _cTIPCONV:= ''
Local  _nQE:= 0  
Local  _nPRV1:= ''
Local  _nEMIN:= ''
Local  _nCUSTD:= ''
Local  _cMCUSTD:= ''
Local  _nPESO:= 0
Local  _nLE:= ''
Local  _nLM:= ''
Local  _cCONTA:= ''
Local  _nTOLER:= ''
Local  _cCC:= ''
Local  _cITEMCC:= ''
Local  _cPROC:= ''
Local  _cAPROPRI:= ''
Local  _cORIGEM:= ''
Local  _cCLASFIS:= ''
Local  _cRASTRO:= ''
Local  _cLOCALIZ:= ''
Local  _cCONTRAT:= ''
Local  _nPCSLL:= ''
Local  _nPCOFINS:= 0
Local  _nPPIS:= 0
Local  _cCLVL:= ''
Local  _nPESBRU:= 0
Local  _cTNATREC:= ''
Local  _cTPREG:= ''
Local  _cGRPNATR:= ''
Local  _cTRIBMUN:= ''
Local  _cMARCA:= ''
Local  _cANUENTE:= ''
Local  _cFABRIC:= ''
Local  _cIRRF:= ''
Local  _cINSS:= ''
Local  _cPIS:= ''
Local  _cCOFINS:= ''
Local  _cCSLL:= ''
Local  _cCNAE:= ''
Local  _cLOJPROC:= ''
Local  _cTIPOCQ:= ''
Local  _cGARANT:= ''
Local  _cLOTEDIP:= ''

Public _cCOD:= ''
Private _aCelulas		:= {}
Private _aGeraSb1 		:= {}
Private _aStru	        := {}
// Montagem das Celulas                   
AADD(_aCelulas,{'B1_COD ',"B",2,'C',15,0})
AADD(_aCelulas,{'B1_DESC ',"C",2,'C',30,0})
AADD(_aCelulas,{'B1_TIPO ',"D",2,'C',2,0})
AADD(_aCelulas,{'B1_UM ',"E",2,'C',2,0})
AADD(_aCelulas,{'B1_LOTEDIP ',"F",2,'C',1,0})
AADD(_aCelulas,{'B1_GRUPO ',"G",2,'C',4,0})
AADD(_aCelulas,{'B1_IPI ',"H",2,'N',5,2})
AADD(_aCelulas,{'B1_POSIPI ',"I",2,'C',10,0})
AADD(_aCelulas,{'B1_ESPECI ',"L",2,'C',2,0})
AADD(_aCelulas,{'B1_EX_NCM ',"K",2,'C',3,0})
AADD(_aCelulas,{'B1_EX_NBM ',"L",2,'C',3,0})
AADD(_aCelulas,{'B1_ALIQIS ',"M",2,'N',5,0})
AADD(_aCelulas,{'B1_CODISS ',"N",2,'C',8,0})
AADD(_aCelulas,{'B1_TE ',"O",2,'C',3,0})
AADD(_aCelulas,{'B1_TS ',"P",2,'C',3,0})
AADD(_aCelulas,{'B1_GRTRIB ',"Q",2,'C',3,0})
AADD(_aCelulas,{'B1_IMPZFR ',"R",2,'C',1,0})
AADD(_aCelulas,{'B1_SEGUM ',"S",2,'C',2,0})
AADD(_aCelulas,{'B1_CONV ',"T",2,'N',5,0})
AADD(_aCelulas,{'B1_TIPCON ',"U",2,'C',1,0})
AADD(_aCelulas,{'B1_XQE ',"V",2,'N',9,2})
AADD(_aCelulas,{'B1_PRV1 ',"W",2,'N',12,2})
AADD(_aCelulas,{'B1_EMIN ',"X",2,'N',12,2})
AADD(_aCelulas,{'B1_CUSTD ',"Y",2,'N',12,2})
AADD(_aCelulas,{'B1_MCUSTD ',"Z",2,'C',1,0})
AADD(_aCelulas,{'B1_PESO ',"AA",2,'N',11,0})
AADD(_aCelulas,{'B1_LE ',"AB",2,'N',12,2})
AADD(_aCelulas,{'B1_LM ',"AC",2,'N',12,2})
AADD(_aCelulas,{'B1_CONTA ',"AD",2,'C',20,0})
AADD(_aCelulas,{'B1_TOLER ',"AE",2,'N',3,0})
AADD(_aCelulas,{'B1_CC ',"AF",2,'C',9,0})
AADD(_aCelulas,{'B1_ITEMCC ',"AG",2,'C',9,0})
AADD(_aCelulas,{'B1_PROC ',"AH",2,'C',6,0})
AADD(_aCelulas,{'B1_APROPRI ',"AI",2,'C',1,0})
AADD(_aCelulas,{'B1_ORIGEM ',"AJ",2,'C',1,0})
AADD(_aCelulas,{'B1_CLASFI ',"AK",2,'C',2,0})
AADD(_aCelulas,{'B1_RASTRO ',"AL",2,'C',1,0})
AADD(_aCelulas,{'B1_LOCALI ',"AM",2,'C',1,0})
AADD(_aCelulas,{'B1_CONTRAT ',"AN",2,'C',1,0})
AADD(_aCelulas,{'B1_PCSLL ',"AO",2,'N',5,2})
AADD(_aCelulas,{'B1_PCOFIN ',"AP",2,'N',5,2})
AADD(_aCelulas,{'B1_PPIS ',"AQ",2,'N',5,2})
AADD(_aCelulas,{'B1_CLVL ',"AR",2,'C',9,0})
AADD(_aCelulas,{'B1_PESBRU ',"AS",2,'N',11,2})
AADD(_aCelulas,{'B1_TNATRE ',"AT",2,'C',4,0})
AADD(_aCelulas,{'B1_TPREG ',"AU",2,'C',1,0})
AADD(_aCelulas,{'B1_GRPNAT ',"AV",2,'C',2,0})
AADD(_aCelulas,{'B1_TRIBMUN ',"AW",2,'C',20,0})
AADD(_aCelulas,{'B1_MARCA ',"AX",2,'C',30,0})
AADD(_aCelulas,{'B1_ANUENTE ',"AY",2,'C',1,0})
AADD(_aCelulas,{'B1_FABRIC ',"AZ",2,'C',20,0})
AADD(_aCelulas,{'B1_IRRF ',"BA",2,'C',1,0})
AADD(_aCelulas,{'B1_INSS ',"BB",2,'C',1,0})
AADD(_aCelulas,{'B1_PIS ',"BC",2,'C',1,0})
AADD(_aCelulas,{'B1_COFINS ',"BD",2,'C',1,0})
AADD(_aCelulas,{'B1_CSLL ',"BE",2,'C',1,0})
AADD(_aCelulas,{'B1_CNAE ',"BF",2,'C',9,0})
AADD(_aCelulas,{'B1_LOJPROC ',"BG",2,'C',2,0})
AADD(_aCelulas,{'B1_TIPOCQ ',"BH",2,'C',1,0})
AADD(_aCelulas,{'B1_GARANT ',"BI",2,'C',1,0})

If Right(Alltrim(cDir),1) <>'\'
	cDir := Alltrim(cDir)+"\"
Endif

// Efetua Ajuste na Variavel de Nome do Arquivo
If Right(Alltrim(cArq),4) <>'.XLS'
	cArq := Alltrim(cArq)+".XLS"
Endif

cFile   := cDir+cArq

// Verifica se Conseguiu efetuar a Abertura do Arquivo
If ( nHdl >= 0 )
	
	// Carrega o Excel e Abre o arquivo
	cBuffer := cFile + Space(512)
	nBytes  := ExeDLLRun2(nHdl, CMD_OPENWORKBOOK, @cBuffer)
	
	If ( nBytes < 0 )
		// Erro critico na abertura do arquivo sem msg de erro
		MsgStop('Não foi possível abrir o arquivo : ' + cFile)
		Return
	ElseIf ( nBytes > 0 )
		// Erro critico na abertura do arquivo com msg de erro
		MsgStop(Subs(cBuffer, 1, nBytes))
		Return
	EndIf
	
	// Seleciona a worksheet
	cBuffer := "IMPORTAR" + Space(512)
	ExeDLLRun2(nHdl, CMD_ACTIVEWORKSHEET, @cBuffer)
	_nSomaLin	:= 0
	
	For _nElemx		:= 1 To 5000
		
		_cCOD:= VERDADOS(nHdl,'_aCelulas',01,_nSomaLin)
		MsProcTxt("Proc.Registro: "+StrZero(_nElemx,7) + " - " + _cCOD)
		CONOUT("Importando produto - " + _cCOD) 
		_cDESC:= VERDADOS(nHdl,'_aCelulas',02,_nSomaLin)
		_cTIPO:= VERDADOS(nHdl,'_aCelulas',03,_nSomaLin)
		_cUM:= VERDADOS(nHdl,'_aCelulas',04,_nSomaLin)
		_cLOTEDIP:= VERDADOS(nHdl,'_aCelulas',05,_nSomaLin)
		_cGRUPO:= VERDADOS(nHdl,'_aCelulas',06,_nSomaLin)
		_nIPI:= VERDADOS(nHdl,'_aCelulas',07,_nSomaLin)
		_cPOSIPI:= VERDADOS(nHdl,'_aCelulas',08,_nSomaLin)
		_cESPECIE:= VERDADOS(nHdl,'_aCelulas',09,_nSomaLin)
		_cEXNCM:= VERDADOS(nHdl,'_aCelulas',10,_nSomaLin)
		_cEXNBM:= VERDADOS(nHdl,'_aCelulas',11,_nSomaLin)
		_nALIQISS:= VERDADOS(nHdl,'_aCelulas',12,_nSomaLin)
		_cCODISS:= VERDADOS(nHdl,'_aCelulas',13,_nSomaLin)
		_cTE:= VERDADOS(nHdl,'_aCelulas',14,_nSomaLin)
		_cTS:= VERDADOS(nHdl,'_aCelulas',15,_nSomaLin)
		_cGRTRIB:= VERDADOS(nHdl,'_aCelulas',16,_nSomaLin)
		_cIMPZFRC:= VERDADOS(nHdl,'_aCelulas',17,_nSomaLin)
		_cSEGUM:= VERDADOS(nHdl,'_aCelulas',18,_nSomaLin)
		_nCONV:= VERDADOS(nHdl,'_aCelulas',19,_nSomaLin)
		_cTIPCONV:= VERDADOS(nHdl,'_aCelulas',20,_nSomaLin)
		_nQE:= VERDADOS(nHdl,'_aCelulas',21,_nSomaLin)
		_nPRV1:= VERDADOS(nHdl,'_aCelulas',22,_nSomaLin)
        _nEMIN:= VERDADOS(nHdl,'_aCelulas',23,_nSomaLin)
  		_nCUSTD:= VERDADOS(nHdl,'_aCelulas',24,_nSomaLin)
  		_cMCUSTD:= VERDADOS(nHdl,'_aCelulas',25,_nSomaLin)
		_nPESO:= VERDADOS(nHdl,'_aCelulas',26,_nSomaLin)
		_nLE:= VERDADOS(nHdl,'_aCelulas',27,_nSomaLin)
	    _nLM:= VERDADOS(nHdl,'_aCelulas',28,_nSomaLin)
		_cCONTA:= VERDADOS(nHdl,'_aCelulas',29,_nSomaLin)
        _nTOLER:= VERDADOS(nHdl,'_aCelulas',30,_nSomaLin)
		_cCC:= VERDADOS(nHdl,'_aCelulas',31,_nSomaLin)
		_cITEMCC:= VERDADOS(nHdl,'_aCelulas',32,_nSomaLin)
		_cPROC:= VERDADOS(nHdl,'_aCelulas',33,_nSomaLin)
        _cAPROPRI:= VERDADOS(nHdl,'_aCelulas',34,_nSomaLin)
		_cORIGEM:= VERDADOS(nHdl,'_aCelulas',35,_nSomaLin)
		_cCLASFIS:= VERDADOS(nHdl,'_aCelulas',36,_nSomaLin)
		_cRASTRO:= VERDADOS(nHdl,'_aCelulas',37,_nSomaLin)
		_cLOCALIZ:= VERDADOS(nHdl,'_aCelulas',38,_nSomaLin)
		_cCONTRAT:= VERDADOS(nHdl,'_aCelulas',39,_nSomaLin)
		_nPCSLL:= VERDADOS(nHdl,'_aCelulas',40,_nSomaLin)
		_nPCOFINS:= VERDADOS(nHdl,'_aCelulas',41,_nSomaLin)
		_nPPIS:= VERDADOS(nHdl,'_aCelulas',42,_nSomaLin)
		_cCLVL:= VERDADOS(nHdl,'_aCelulas',43,_nSomaLin)
		_nPESBRU:= VERDADOS(nHdl,'_aCelulas',44,_nSomaLin)
		_cTNATREC:= VERDADOS(nHdl,'_aCelulas',45,_nSomaLin)
		_cTPREG:= VERDADOS(nHdl,'_aCelulas',46,_nSomaLin)
		_cGRPNATR:= VERDADOS(nHdl,'_aCelulas',47,_nSomaLin)
		_cTRIBMUN:= VERDADOS(nHdl,'_aCelulas',48,_nSomaLin)
		_cMARCA:= VERDADOS(nHdl,'_aCelulas',49,_nSomaLin)
		_cANUENTE:= VERDADOS(nHdl,'_aCelulas',50,_nSomaLin)
		_cFABRIC:= VERDADOS(nHdl,'_aCelulas',51,_nSomaLin)
		_cIRRF:= VERDADOS(nHdl,'_aCelulas',52,_nSomaLin)
		_cINSS:= VERDADOS(nHdl,'_aCelulas',53,_nSomaLin)
		_cPIS:= VERDADOS(nHdl,'_aCelulas',54,_nSomaLin)
		_cCOFINS:= VERDADOS(nHdl,'_aCelulas',55,_nSomaLin)
		_cCSLL:= VERDADOS(nHdl,'_aCelulas',56,_nSomaLin)
		_cCNAE:= VERDADOS(nHdl,'_aCelulas',57,_nSomaLin)
		_cLOJPROC:= VERDADOS(nHdl,'_aCelulas',58,_nSomaLin)
		_cTIPOCQ:= VERDADOS(nHdl,'_aCelulas',59,_nSomaLin)
		_cGARANT:= VERDADOS(nHdl,'_aCelulas',60,_nSomaLin)
		                                          
		If Empty(_cCOD)
			Exit
		Endif
		
		_lAchouSB1 := .F.
		dbSelectArea("SB1")
		SB1->(dbSetOrder(1))
		SB1->(dbGoTop())
		If SB1->(dbSeek(xFilial("SB1") + _cCOD))
			_lAchouSB1 := .T.
		EndIf
		
		_aGeraSb1:= {}
		                           
		AADD(_aGeraSb1,{"B1_COD",_cCOD,nIL})
		AADD(_aGeraSb1,{"B1_DESC",_cDESC,nIL})
		AADD(_aGeraSb1,{"B1_TIPO",_cTIPO,nIL})
		AADD(_aGeraSb1,{"B1_UM",_cUM,nIL})
		AADD(_aGeraSb1,{"B1_LOTEDIP",_cLOTEDIP,nIL})
		AADD(_aGeraSb1,{"B1_GRUPO",_cGRUPO,nIL})
		AADD(_aGeraSb1,{"B1_IPI",_nIPI,nIL})
		AADD(_aGeraSb1,{"B1_POSIPI",_cPOSIPI,nIL})
		AADD(_aGeraSb1,{"B1_ESPECIE",_cESPECIE,nIL})
		AADD(_aGeraSb1,{"B1_EX_NCM",_cEXNCM,nIL})
		AADD(_aGeraSb1,{"B1_EX_NBM",_cEXNBM,nIL})
		AADD(_aGeraSb1,{"B1_ALIQISS",_nALIQISS,nIL})
		AADD(_aGeraSb1,{"B1_CODISS",_cCODISS,nIL})
		AADD(_aGeraSb1,{"B1_TE",_cTE,nIL})
		AADD(_aGeraSb1,{"B1_TS",_cTS,nIL})
		AADD(_aGeraSb1,{"B1_GRTRIB",_cGRTRIB,nIL})
		AADD(_aGeraSb1,{"B1_IMPZFRC",_cIMPZFRC,nIL})
		AADD(_aGeraSb1,{"B1_SEGUM",_cSEGUM,nIL})
		AADD(_aGeraSb1,{"B1_CONV",_nCONV,nIL})
		AADD(_aGeraSb1,{"B1_TIPCONV",_cTIPCONV,nIL})
		AADD(_aGeraSb1,{"B1_XQE",_nQE,nIL})
        AADD(_aGeraSb1,{"B1_PRV1",_nPRV1,nIL})
        AADD(_aGeraSb1,{"B1_EMIN",_nEMIN,nIL})
        AADD(_aGeraSb1,{"B1_CUSTD",_nCUSTD,nIL})
        AADD(_aGeraSb1,{"B1_MCUSTD",_cMCUSTD,nIL})
		AADD(_aGeraSb1,{"B1_PESO",_nPESO,nIL})
		AADD(_aGeraSb1,{"B1_LE",_nLE,nIL})
		AADD(_aGeraSb1,{"B1_LM",_nLM,nIL})
		AADD(_aGeraSb1,{"B1_CONTA",_cCONTA,nIL})
		AADD(_aGeraSb1,{"B1_TOLER",_nTOLER,nIL})
		AADD(_aGeraSb1,{"B1_CC",_cCC,nIL})
		AADD(_aGeraSb1,{"B1_ITEMCC",_cITEMCC,nIL})
		AADD(_aGeraSb1,{"B1_PROC",_cPROC,nIL})
		AADD(_aGeraSb1,{"B1_APROPRI",_cAPROPRI,nIL})
		AADD(_aGeraSb1,{"B1_ORIGEM",_cORIGEM,nIL})
		AADD(_aGeraSb1,{"B1_CLASFIS",_cCLASFIS,nIL})
		AADD(_aGeraSb1,{"B1_RASTRO",_cRASTRO,nIL})
		AADD(_aGeraSb1,{"B1_LOCALIZ",_cLOCALIZ,nIL})
		AADD(_aGeraSb1,{"B1_CONTRAT",_cCONTRAT,nIL})
		AADD(_aGeraSb1,{"B1_PCSLL",_nPCSLL,nIL})
		AADD(_aGeraSb1,{"B1_PCOFINS",_nPCOFINS,nIL})
		AADD(_aGeraSb1,{"B1_PPIS",_nPPIS,nIL})
		AADD(_aGeraSb1,{"B1_CLVL",_cCLVL,nIL})
		AADD(_aGeraSb1,{"B1_PESBRU",_nPESBRU,nIL})
		AADD(_aGeraSb1,{"B1_TNATREC",_cTNATREC,nIL})
		AADD(_aGeraSb1,{"B1_TPREG",_cTPREG,nIL})
		AADD(_aGeraSb1,{"B1_GRPNATR",_cGRPNATR,nIL})
		AADD(_aGeraSb1,{"B1_TRIBMUN",_cTRIBMUN,nIL})
		AADD(_aGeraSb1,{"B1_MARCA",_cMARCA,nIL})
		AADD(_aGeraSb1,{"B1_ANUENTE",_cANUENTE,nIL})
		AADD(_aGeraSb1,{"B1_FABRIC",_cFABRIC,nIL})
		AADD(_aGeraSb1,{"B1_IRRF",_cIRRF,nIL})
		AADD(_aGeraSb1,{"B1_INSS",_cINSS,nIL})
		AADD(_aGeraSb1,{"B1_PIS",_cPIS,nIL})
		AADD(_aGeraSb1,{"B1_COFINS",_cCOFINS,nIL})
		AADD(_aGeraSb1,{"B1_CSLL",_cCSLL,nIL})
		AADD(_aGeraSb1,{"B1_CNAE",_cCNAE,nIL})
		AADD(_aGeraSb1,{"B1_LOJPROC",_cLOJPROC,nIL})
		AADD(_aGeraSb1,{"B1_TIPOCQ",_cTIPOCQ,nIL})
		AADD(_aGeraSb1,{"B1_GARANT",_cGARANT,nIL})
		
		If 	len(_aGeraSb1) > 0
			If _lAchouSB1
				Processa({|| u_GerImpB1() },"Efetuando o Movimento...")
			Else
				Processa({|| u_GerImpB2() },"Efetuando o Movimento...")
			Endif
		EndIf
		
		_nSomaLin++
	Next _nElemx
	// Fecha o arquivo e remove o excel da memoria
	cBuffer := Space(512)
	ExeDLLRun2(nHdl, CMD_CLOSEWORKBOOK, @cBuffer)
	ExecInDLLClose(nHdl)
	
	
Else
	MsgStop('Nao foi possivel carregar a DLL')
EndIf


Return


//Desc. Retorna o Conteudo de Uma celula na planilha Excel

Static Function VERDADOS(_nArq,_cMatriz,_nElemento,_nSoma,_lExtrai)

Local _cRetorno	:= ''
Local _cBufferPl:= ''
Local _nBytesPl	:= 0
Local _cCelula	:=''
Local _cDescCam	:=''
Local _cColuna	:=''
Local _cLinha	:=''
Local _cTipo	:=''
Local _cTamanho	:=''
Local _cDecimal	:=''
Local _cString	:=''

If _lExtrai == Nil
	_lExtrai := .F.
Endif
_cDescCam		:=   _cMatriz+"["+Alltrim(STR(_nElemento))+",1]"
_cColuna		:=   _cMatriz+"["+Alltrim(STR(_nElemento))+",2]"
_cLinha			:=   _cMatriz+"["+Alltrim(STR(_nElemento))+",3]"
_cTipo   		:=   _cMatriz+"["+Alltrim(STR(_nElemento))+",4]"
_cTamanho		:=   _cMatriz+"["+Alltrim(STR(_nElemento))+",5]"
_cDecimal		:=   _cMatriz+"["+Alltrim(STR(_nElemento))+",6]"

_cDescCam		:= &_cDescCam
_cColuna		:= &_cColuna
_cLinha			:= Alltrim(Str(&_cLinha+_nSoma))
_cTipo   		:= Upper(&_cTipo)
_cTamanho		:= &_cTamanho
_cDecimal		:= &_cDecimal
_cCelula		:= _cColuna+_cLinha


// Efetua Leitura da Planilha
_cBufferPl := _cCelula + Space(1024)
_nBytesPl  := ExeDLLRun2(_nArq, CMD_READCELL, @_cBufferPl)
_cRetorno  := Subs(_cBufferPl, 1, _nBytesPl)
_cRetorno  := Alltrim(_cRetorno)

// Realiza tratamento do campo  de acordo com o Tipo

If _cTipo =='N' // Numerico
	_cString	:=''
	_cNewRet :=''
	For _nElem	:= 1 To Len(_cRetorno)
		_cString := SubStr(_cRetorno,_nElem,1)
		If _cString ==','
			_cString :='.'
		Endif
		_cNewRet	:=Alltrim(_cNewRet)+_cString
	Next _nElem
	_cNewRet		:= Val(_cNewRet)
	_cRetorno    := Round(_cNewRet,_cDecimal)
Endif

If _cTipo =='D' // Data 21/01/2006
	_cRetorno 	:= Alltrim(_cRetorno)
	_cNewRet 	:= Left(_cRetorno,6)+Right(_cRetorno,2)
	_cRetorno    := CtoD(_cNewRet)
Endif

If _cTipo =='C' .AND. _lExtrai // Caracter e extraçào de caracteres
	_cString	:=''
	_cNewRet :=''
	For _nElem	:= 1 To Len(_cRetorno)
		_cString := SubStr(_cRetorno,_nElem,1)
		If _cString $ '#/#,#.#-'
			Loop
		Endif
		_cNewRet	:=Alltrim(_cNewRet)+_cString
	Next _nElem
	_cRetorno    := _cNewRet
Endif

// Ajusta O Tamanho da variavel

If _cTipo =='C'
	_cRetorno := Alltrim(_cRetorno)
	_cRetorno := _cRetorno+Space(_cTamanho-Len(_cRetorno))
Endif

Return _cRetorno




User Function GerImpB1()  

Local nOpc     := 4
Local _MostSN  := .T.
Public l030Auto := .T.

Private lMsErroAuto := .f.

MSExecAuto({|x,y| mata010(x,y)},_aGeraSb1,4)
	
If lMsErroAuto
	If _MostSN
		Mostraerro()
		If !MSGyesno("Continua?")
			Return
		Else
			If !MSGYESNO("Continua mostrando (Continua?)")
				_MostSN := .f.
			endif
		EndIF
	EndIf
EndIf


/*============================================================================
|Programa:  |	GeraImp2 													 |
|=============================================================================
|Desc:		|   Efetua transferencia dos produtos							 |
|===========================================================================*/

User Function GerImpB2()
Local nOpc     := 3
Local _MostSN  := .t.
Public l030Auto := .T.

Private lMsErroAuto := .f.

MSExecAuto({|x,y| mata010(x,y)},_aGeraSb1,3)
	
If lMsErroAuto
	rollbacksx8()
	If _MostSN
		Mostraerro()
		If !MSGyesno("Continua?")
			Return
		Else
			If !MSGYESNO("Continua mostrando (Continua?)")
				_MostSN := .f.
			endif
		EndIF
	EndIf
EndIf

Return


/*============================================================================
|Programa:  |	VALIDPERG 													 |
|=============================================================================
|Desc:		|   Pergunte													 |
|===========================================================================*/

Static Function VALIDPERG()
Local aHelpPor := {}
Local aHelpEng := {}
Local aHelpSpa := {}
cPerg        := PADR(cPerg,len(sx1->x1_grupo))

AAdd(aHelpPor,"Diretorio ( Pasta ) que se encontra ")
AAdd(aHelpPor,"a Planilha Excel")
PutSx1(cPerg,"01","Diretorio do arquivo ","Diretorio do arquivo","Diretorio do arquivo","mv_ch1","C",30,0,0,"G","","","","","MV_PAR01","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)

aHelpPor :={}
AAdd(aHelpPor,"Nome do Arquivo Excel a Ser Importado")
PutSx1(cPerg,"02","Nome do Arquivo ","Nome do Arquivo","Nome do Arquivo","mv_ch2","C",30,0,0,"G","","","","","MV_PAR02","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)

Return

#include "rwmake.ch"
#include "protheus.ch"
#include "tbiconn.ch"
#include "shell.ch"
#include "fileio.ch"
#include "totvs.ch"

//#default _clrf chr(13)+chr(10)

User Function RCTBI001()

	local   _aSavArea    := GetArea()
	local   cTitulo      := "Correção de Lançamentos fiscais / contábeis relacionados ao PIS/COFINS."

	private _nOpc        := 0
	private _cRotina     := "RCTBI0010"
	private cPerg        := _cRotina
	private _cArqOri     := ""
	private _lExec       := .F.
	private _clrf        := chr(13)+chr(10)
	private bOk          := { || _nOpc := IIF(!Empty(_cArqOri),1,0), IIF(!Empty(_cArqOri),oDlg:End(),MsgStop("Informe o arquivo CSV antes de prosseguir!",_cRotina+"_012")) }
	private bCancel      := { || oDlg:End()                                                               }
	private bDir         := { || _cArqOri := Lower(AllTrim(Lower(SelDirArq())))                           }
	private cDrive, cDir, cNome, cExt, oSButton1, oSButton2, oSButton3, oSay1, oSay2, oSay3, oGroup1

	validperg()
	If !Pergunte(cPerg,.T.)
		return
	EndIf

	Static oDlg

	  DEFINE MSDIALOG oDlg TITLE "["+_cRotina+"] "+cTitulo FROM 000, 000  TO 220, 750 COLORS 0, 16777215 PIXEL

	    @ 004, 003 GROUP oGroup1 TO 104, 371 PROMPT " AJUSTES FISCAIS E CONTÁBEIS (PIS/COFINS) " OF oDlg COLOR 0, 16777215 PIXEL
	    @ 025, 010 SAY oSay1 PROMPT "Esta rotina é utilizada para a importação de arquivo para os ajustes fiscais/contábeis relacionados ao PIS/COFINS, do período selecionado. " SIZE 350, 007 OF oDlg COLORS 0, 16777215 PIXEL
	    @ 038, 010 SAY oSay2 PROMPT "Selecione o arquivo em formato CSV para que possa ser processado. Não esqueça de informar o parâmetro de/até data a ser processado.        " SIZE 350, 007 OF oDlg COLORS 0, 16777215 PIXEL
	    @ 050, 010 SAY oSay3 PROMPT "Após selecionar o arquivo, clique em confirmar.                                                                                            " SIZE 350, 007 OF oDlg COLORS 0, 16777215 PIXEL
	    DEFINE SBUTTON oSButton1 FROM 087, 237 TYPE 14 OF oDlg ENABLE  ACTION Eval(bDir   )
	    DEFINE SBUTTON oSButton2 FROM 087, 280 TYPE 01 OF oDlg ENABLE  ACTION Eval(bOk    )
	    DEFINE SBUTTON oSButton3 FROM 087, 320 TYPE 02 OF oDlg ENABLE  ACTION Eval(bCancel)

	  ACTIVATE MSDIALOG oDlg CENTERED

	If _nOpc == 1
		If (cFilAnt == "01" .OR. cFilAnt == "04") //.AND. (AllTrim(UPPER(CUSERNAME)) <> "MCANUTO" .OR. __cUserId == "000000")
			If File(_cArqOri)
				SplitPath(_cArqOri, @cDrive, @cDir, @cNome, @cExt)
				If UPPER(AllTrim(cExt)) == ".CSV"
					Processa( {|lEnd| ProcRotina(@lEnd)}, "["+_cRotina+"_P001] "+cTitulo, "Processando importação da planilha e adequação das informações...",.T.)
					If _lExec
						Processa( {|lEnd| ProcScript(@lEnd)}, "["+_cRotina+"_P002] "+cTitulo, "Preparando atualização do banco de dados...",.T.)
					EndIf
				Else
					MsgStop("Formato inválido para o arquivo selecionado ('"+AllTrim(_cArqOri)+"'). Processamento abortado!",_cRotina+"_001")
				EndIf
			Else
				MsgStop("Arquivo não encontrado ('"+AllTrim(_cArqOri)+"')!",_cRotina+"_002")
			EndIf
		Else
			MsgStop("Atenção! Esta rotina foi preparada para ser executada apenas nas filiais '01' e/ou '04' e você está tentando a executar na filial '"+cFilAnt+"'. Operação não permitida!",_cRotina+"_010")
		EndIf
	Else
		MsgAlert("Processamento abortado pelo usuário!",_cRotina+"_003")
	EndIf
	restarea(_aSavArea)
return
static function SelDirArq()
	local _cTipo := "Arquivos Excel do tipo CSV | *.CSV"
//	_cArqOri     := cGetFile(_cTipo, "Selecione o arquivo CSV a ser importado ",0,"C:\",.T.,GETF_NETWORKDRIVE+GETF_LOCALHARD+GETF_LOCALFLOPPY)
	_cArqOri     := cGetFile(_cTipo, "Selecione o arquivo CSV a ser importado ",0,"C:\",   ,GETF_NETWORKDRIVE+GETF_LOCALHARD+GETF_LOCALFLOPPY)
return(_cArqOri)
static function ProcRotina(lEnd)
	local   _x     := 0
	local   _nLin  := 0
	local   _nPos  := 0

	private _cLin  := ""
	private _cIns  := ""
	private _cITm  := ""
	private _aLin  := {}
						//CAMPO   , TIPO , POSIÇÃO , CONTEÚDO DEFAULT               , Zeros a Esquerda
	private _aCol  := {	{"FILIAL" , "C"  , 0       , Space(TamSx3("F1_FILIAL" )[01]), TamSx3("F1_FILIAL" )[01]     },;
						{"TES_DE" , "C"  , 0       , Space(TamSx3("F4_CODIGO" )[01]), TamSx3("F4_CODIGO" )[01]     },;
						{"TES_ATE", "C"  , 0       , Space(TamSx3("F4_CODIGO" )[01]), TamSx3("F4_CODIGO" )[01]     },;
						{"NCM"    , "C"  , 0       , Space(TamSx3("B1_POSIPI" )[01]), 0                            },;
						{"TIPO"   , "C"  , 0       , Space(1)                       , 0                            },;
						{"DT"     , "C"  , 0       , Space(TamSx3("F1_DTDIGIT")[01]), TamSx3("F1_DTDIGIT")[01]     },;
						{"NF"     , "N"  , 0       , "0"                            , 0                            },;
						{"CFOP"   , "C"  , 0       , Space(TamSx3("F4_CF"     )[01]), 0                            } }
	FT_FUSE(_cArqOri)
	ProcRegua(FT_FLASTREC())
	FT_FGOTOP()
	If !FT_FEOF()
		While !FT_FEOF() .AND. !lEnd
			_nLin++
			IncProc("Lendo linha " + cValToChar(_nLin) + " do arquivo " + AllTrim(_cArqOri) + "...")
			_cLin  := FT_FREADLN()
			If ";" $ _cLin
				_aLin  := Separa(_cLin,";",.T.)		//Estrutura do array gerado: _aLin[_x]
			ElseIf "," $ _cLin
				_aLin  := Separa(_cLin,",",.T.)		//Estrutura do array gerado: _aLin[_x]
			Else
				MsgStop("Atenção! Para que o arquivo seja importado, é importante que as colunas sejam separadas por vírgula ou ponto e vírgula. Processamento abortado!",_cRotina+"_004")
				lEnd := .T.
				Exit
			EndIf
			If _nLin == 1 .AND. !lEnd		//Se refere ao cabeçalho
				for _x := 1 to len(_aLin)
					If !Empty(_aLin[_x])
						_nPos := aScan(_aCol,{|x| AllTrim(UPPER(x[01])) == AllTrim(UPPER(_aLin[_x]))})
						If _nPos == 0
							MsgInfo("Atenção! A coluna '"+AllTrim(UPPER(_aLin[_x]))+"' foi encontrada no arquivo, mas não faz parte da estrutura prevista para este. Sendo assim, a importação será continuada, mas esta coluna desprezada!",_cRotina+"_005")
						ElseIf _aCol[_nPos][03] > 0
							MsgStop("Atenção! A coluna '"+AllTrim(UPPER(_aLin[_x]))+"' está duplicada no arquivo que está importando. Processamento abortado!",_cRotina+"_006")
							lEnd := .T.
							Exit
						Else
							_aCol[_nPos][03] := _x
						EndIf
					EndIf
				next
/*
				_cIns := 	" SET ANSI_NULLS ON "+_clrf
				_cIns += 	" GO "+_clrf
				_cIns += 	" SET QUOTED_IDENTIFIER ON "+_clrf
				_cIns += 	" GO "+_clrf
				_cIns += 	" SET ANSI_PADDING ON "+_clrf
				_cIns += 	" GO "+_clrf
				_cIns += 	" CREATE TABLE [dbo.][DEPARATES] ( "+_clrf
				for _x := 1 to len(_aCol)
					If _x > 1
						_cIns += ", "
					EndIf
					If _aCol[_x][02] == "C"
						_cIns += " ["+AllTrim(UPPER(_aCol[_x][01]))+"] [varchar]("+cValToChar(len(_aCol[_x][04]))+") NOT NULL CONSTRAINT [DEPARATES_"+AllTrim(UPPER(_aCol[_x][01]))+"_DF]  DEFAULT ('"+_aCol[_x][04]+"') "+_clrf
					ElseIf _aCol[_x][02] == "N"
						_cIns += " ["+AllTrim(UPPER(_aCol[_x][01]))+"] [float] NOT NULL CONSTRAINT [DEPARATES_"+AllTrim(UPPER(_aCol[_x][01]))+"_DF]  DEFAULT (("+_aCol[_x][04]+")) "+_clrf
					Else
						MsgAlert("Atenção! Tipo '"+_aCol[_x][02]+"' definido para a coluna '"+AllTrim(UPPER(_aCol[_x][01]))+"', não tratado pela rotina. Informe o administrador do sistema!",_cRotina+"_006")
						lEnd := .T.
						Exit
					EndIf
				next
				_cIns += 	", [D_E_L_E_T_]   [varchar](1) NOT NULL CONSTRAINT [DEPARATES_D_E_L_E_T__DF]    DEFAULT (' ') "+_clrf
				_cIns += 	", [R_E_C_N_O_]   [int]        NOT NULL CONSTRAINT [DEPARATES_R_E_C_N_O__DF]    DEFAULT ((0)) "+_clrf
				_cIns += 	", [R_E_C_D_E_L_] [int]        NOT NULL CONSTRAINT [DEPARATES_R_E_C_D_E_L__DF]  DEFAULT ((0)) "+_clrf
				_cIns += 	" CONSTRAINT [DEPARATES_PK] PRIMARY KEY CLUSTERED "+_clrf
				_cIns += 	" ( "+_clrf
				_cIns += 	"	[R_E_C_N_O_] ASC "+_clrf
				_cIns += 	" )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY] "+_clrf
				_cIns += 	" ) ON [PRIMARY] "+_clrf
				_cIns += 	" GO "+_clrf
				_cIns += 	" SET ANSI_PADDING OFF "+_clrf
				_cIns += 	" GO "+_clrf
*/
				_cIns := 	" CREATE TABLE DEPARATES ( "+_clrf
				for _x := 1 to len(_aCol)
					If _x > 1
						_cIns += ", "
					EndIf
					If _aCol[_x][02] == "C"
						_cIns += " ["+AllTrim(UPPER(_aCol[_x][01]))+"] varchar("+cValToChar(len(_aCol[_x][04]))+") "+_clrf
					ElseIf _aCol[_x][02] == "N"
						_cIns += " ["+AllTrim(UPPER(_aCol[_x][01]))+"] float "+_clrf
					Else
						MsgAlert("Atenção! Tipo '"+_aCol[_x][02]+"' definido para a coluna '"+AllTrim(UPPER(_aCol[_x][01]))+"', não tratado pela rotina. Informe o administrador do sistema!",_cRotina+"_006")
						lEnd := .T.
						Exit
					EndIf
				next
				_cIns += 	", [D_E_L_E_T_]   varchar(1) "+_clrf
				_cIns += 	", [R_E_C_N_O_]   int        "+_clrf
				_cIns += 	", [R_E_C_D_E_L_] int        "+_clrf
				_cIns += 	" ); "+_clrf
				TcSqlExec(" DROP TABLE DEPARATES ")
				If !lEnd .AND. TcSqlExec(_cIns) < 0
					MsgStop("[TCSQLError - CREATE TABLE 'DEPARATES'] " + TCSQLError(),_cRotina+"_007B")
					lEnd := .T.
					Exit
				EndIf
			Else							//Se refere aos itens
				_cIns  := " INSERT INTO DEPARATES "+_clrf
				_cITm  := "" 
				for _x := 1 to len(_aCol)
					If _x == 1
						_cIns  += " ( "
						_cITm  += " ( "
					Else
						_cIns  += " , "
						_cITm  += " , "
					EndIf
					_cIns  += " ["+AllTrim(UPPER(_aCol[_x][01]))+"] "+_clrf
					If _aCol[_x][05] > 0
						_cITm  += "'"+StrZero(Val(StrTran(StrTran(StrTran(StrTran(StrTran(StrTran(StrTran(StrTran(StrTran(StrTran(StrTran(StrTran(StrTran(StrTran(StrTran(StrTran(StrTran(StrTran(StrTran(StrTran(StrTran(StrTran(StrTran(StrTran(StrTran(StrTran(StrTran(UPPER(_aLin[_aCol[_x][03]]),'A',''),'B',''),'C',''),'D',''),'E',''),'F',''),'G',''),'H',''),'I',''),'J',''),'K',''),'L',''),'M',''),'N',''),'O',''),'P',''),'Q',''),'T',''),'U',''),'V',''),'W',''),'X',''),'Y',''),'Z',''),'.',''),'-',''),'_','')),_aCol[_x][05])+"'"+_clrf
					ElseIf _aCol[_x][02] == "C"
						_cITm  += "'"+AllTrim(_aLin[_aCol[_x][03]])+"'"+_clrf
					Else
						_cITm  += AllTrim(_aLin[_aCol[_x][03]])+_clrf
					EndIf
				next
				_cIns += " , [D_E_L_E_T_] "+_clrf
				_cIns += " , [R_E_C_N_O_] "+_clrf
				_cIns += " , [R_E_C_D_E_L_] ) "+_clrf
				_cIns += _clrf
				_cIns += " VALUES "+_clrf
				_cIns += _clrf
				_cIns += _cITm
				_cIns += " , '' "+_clrf
				_cIns += " , "+cValToChar(_nLin-1)+_clrf
				_cIns += " , 0 )"+_clrf
//				_cIns += " GO "
				If TcSqlExec(_cIns) < 0
					MsgStop("[TCSQLError - INSERT 'DEPARATES'] " + TCSQLError(),_cRotina+"_007")
					lEnd := .T.
					Exit
				EndIf
			EndIf
			FT_FSKIP()
		EndDo
	Else
		MsgStop("Arquivo '" + AllTrim(_cArqOri) + "' vazio. Nada a importar!",_cRotina+"_008")
		lEnd := .T.
	EndIf
	FT_FUSE()
	If !lEnd
		_lExec := .T.
		//MsgRun("["+_cRotina+"_P002] Aguarde, atualizando banco de dados...","Scripts de Atualização via Banco de Dados", {|| ProcScript(@lEnd) })
	Else
		MsgStop("Processamento não realizado!",_cRotina+"_009")
	EndIf
return
static function ProcScript(lEnd)
	local _cQry := ""
	local _cRef := DTOS(Date())+StrTran(Time(),":","")

	//Computo do numero de processos a executar
	If MV_PAR03 == 1
		ProcRegua(21)
	ElseIf MV_PAR03 == 2
		ProcRegua(12)
	ElseIf MV_PAR03 == 3
		ProcRegua(13)
	EndIf

//	_cQry := " -----------------------------------------------------------------------ENTRADAS-------------------------------------------------------------------------------------- "+_clrf
	If MV_PAR03 <> 3			//Entradas ou Ambos
		IncProc("Backup "+RetSqlName("SD1")+"...")
		_cQry := " SELECT * INTO "+RetSqlName("SD1")+"_"+_cRef+" FROM "+RetSqlName("SD1")+" WHERE D1_DTDIGIT BETWEEN '"+DTOS(MV_PAR01)+"' AND '"+DTOS(MV_PAR02)+"' "+_clrf
		If TcSqlExec(_cQry) < 0
			MsgStop("[TCSQLError - SCRIPTS GERAIS] " + TCSQLError(),_cRotina+"_101")
			lEnd := .T.
			TcRefresh("CT2")
			TcRefresh("SF1")
			TcRefresh("SF2")
			TcRefresh("SD1")
			TcRefresh("SD2")
			TcRefresh("SF3")
			TcRefresh("SFT")
			TcRefresh("SF4")
			MsgAlert("Processamento abortado!",_cRotina+"_E01")
			return !lEnd
		EndIf
		IncProc("Backup "+RetSqlName("SF1")+"...")
		_cQry := " SELECT * INTO "+RetSqlName("SF1")+"_"+_cRef+" FROM "+RetSqlName("SF1")+" WHERE F1_DTDIGIT BETWEEN '"+DTOS(MV_PAR01)+"' AND '"+DTOS(MV_PAR02)+"' "+_clrf
		If TcSqlExec(_cQry) < 0
			MsgStop("[TCSQLError - SCRIPTS GERAIS] " + TCSQLError(),_cRotina+"_102")
			lEnd := .T.
			TcRefresh("CT2")
			TcRefresh("SF1")
			TcRefresh("SF2")
			TcRefresh("SD1")
			TcRefresh("SD2")
			TcRefresh("SF3")
			TcRefresh("SFT")
			TcRefresh("SF4")
			MsgAlert("Processamento abortado!",_cRotina+"_E02")
			return !lEnd
		EndIf
	EndIf
	IncProc("Backup "+RetSqlName("SFT")+"...")
	_cQry := " SELECT * INTO "+RetSqlName("SFT")+"_"+_cRef+" FROM "+RetSqlName("SFT")+" WHERE FT_ENTRADA BETWEEN '"+DTOS(MV_PAR01)+"' AND '"+DTOS(MV_PAR02)+"' "+_clrf
	If TcSqlExec(_cQry) < 0
		MsgStop("[TCSQLError - SCRIPTS GERAIS] " + TCSQLError(),_cRotina+"_103")
		lEnd := .T.
		TcRefresh("CT2")
		TcRefresh("SF1")
		TcRefresh("SF2")
		TcRefresh("SD1")
		TcRefresh("SD2")
		TcRefresh("SF3")
		TcRefresh("SFT")
		TcRefresh("SF4")
		MsgAlert("Processamento abortado!",_cRotina+"_E03")
		return !lEnd
	EndIf
	IncProc("Backup "+RetSqlName("SF3")+"...")
	_cQry := " SELECT * INTO "+RetSqlName("SF3")+"_"+_cRef+" FROM "+RetSqlName("SF3")+" WHERE F3_ENTRADA BETWEEN '"+DTOS(MV_PAR01)+"' AND '"+DTOS(MV_PAR02)+"' "+_clrf
	If TcSqlExec(_cQry) < 0
		MsgStop("[TCSQLError - SCRIPTS GERAIS] " + TCSQLError(),_cRotina+"_104")
		lEnd := .T.
		TcRefresh("CT2")
		TcRefresh("SF1")
		TcRefresh("SF2")
		TcRefresh("SD1")
		TcRefresh("SD2")
		TcRefresh("SF3")
		TcRefresh("SFT")
		TcRefresh("SF4")
		MsgAlert("Processamento abortado!",_cRotina+"_E04")
		return !lEnd
	EndIf
	IncProc("Backup "+RetSqlName("CT2")+"...")
	_cQry := " SELECT * INTO "+RetSqlName("CT2")+"_"+_cRef+" FROM "+RetSqlName("CT2")+" WHERE CT2_DATA   BETWEEN '"+DTOS(MV_PAR01)+"' AND '"+DTOS(MV_PAR02)+"' "+_clrf
	If TcSqlExec(_cQry) < 0
		MsgStop("[TCSQLError - SCRIPTS GERAIS] " + TCSQLError(),_cRotina+"_105")
		lEnd := .T.
		TcRefresh("CT2")
		TcRefresh("SF1")
		TcRefresh("SF2")
		TcRefresh("SD1")
		TcRefresh("SD2")
		TcRefresh("SF3")
		TcRefresh("SFT")
		TcRefresh("SF4")
		MsgAlert("Processamento abortado!",_cRotina+"_E05")
		return !lEnd
	EndIf
	IncProc("Backup "+RetSqlName("SF4")+"...")
	_cQry := " SELECT * INTO "+RetSqlName("SF4")+"_"+_cRef+" FROM "+RetSqlName("SF4")+_clrf
	If TcSqlExec(_cQry) < 0
		MsgStop("[TCSQLError - SCRIPTS GERAIS] " + TCSQLError(),_cRotina+"_106")
		lEnd := .T.
		TcRefresh("CT2")
		TcRefresh("SF1")
		TcRefresh("SF2")
		TcRefresh("SD1")
		TcRefresh("SD2")
		TcRefresh("SF3")
		TcRefresh("SFT")
		TcRefresh("SF4")
		MsgAlert("Processamento abortado!",_cRotina+"_E06")
		return !lEnd
	EndIf
	If MV_PAR03 <> 3			//Entradas ou Ambos
		IncProc("Apagando "+RetSqlName("CT2")+" (entradas)...")
		_cQry := " UPDATE "+RetSqlName("CT2")+" SET CT2_FILIAL = 'XX', D_E_L_E_T_ = '*', R_E_C_D_E_L_ = R_E_C_N_O_ WHERE CT2_FILIAL = '' AND CT2_LOTE = '008810' AND CT2_DATA BETWEEN '"+DTOS(MV_PAR01)+"' AND '"+DTOS(MV_PAR02)+"' AND D_E_L_E_T_ = '' "+_clrf
		If TcSqlExec(_cQry) < 0
			MsgStop("[TCSQLError - SCRIPTS GERAIS] " + TCSQLError(),_cRotina+"_107")
			lEnd := .T.
			TcRefresh("CT2")
			TcRefresh("SF1")
			TcRefresh("SF2")
			TcRefresh("SD1")
			TcRefresh("SD2")
			TcRefresh("SF3")
			TcRefresh("SFT")
			TcRefresh("SF4")
			MsgAlert("Processamento abortado!",_cRotina+"_E07")
			return !lEnd
		EndIf
		IncProc("Ajustando F3_REPROC (entradas)...")
		_cQry := " UPDATE SF3 SET F3_REPROC = 'S' "+_clrf
		_cQry += " FROM "+RetSqlName("SF1")+" SF1 WITH (NOLOCK) "+_clrf
		_cQry += " 	INNER JOIN "+RetSqlName("SD1")+" SD1 WITH (NOLOCK) ON SF1.F1_FILIAL = SD1.D1_FILIAL AND SF1.F1_DOC = SD1.D1_DOC AND SF1.F1_SERIE = SD1.D1_SERIE AND SF1.F1_FORNECE = SD1.D1_FORNECE AND SF1.F1_LOJA = SD1.D1_LOJA AND SD1.D_E_L_E_T_ = '' "+_clrf
		_cQry += " 	INNER JOIN "+RetSqlName("SB1")+" SB1 WITH (NOLOCK) ON SB1.B1_FILIAL = SD1.D1_FILIAL AND SB1.B1_COD = SD1.D1_COD AND SB1.D_E_L_E_T_ = '' "+_clrf
		_cQry += " 	INNER JOIN DEPARATES XXX WITH (NOLOCK) ON XXX.TIPO = 'E' "+_clrf
		_cQry += " 	                                                 AND XXX.FILIAL = SD1.D1_FILIAL "+_clrf
		_cQry += " 	                                                 AND XXX.DT = SD1.D1_DTDIGIT  "+_clrf
		_cQry += " 													 AND XXX.NF = CAST(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(UPPER(SD1.D1_DOC),'A',''),'B',''),'C',''),'D',''),'E',''),'F',''),'G',''),'H',''),'I',''),'J',''),'K',''),'L',''),'M',''),'N',''),'O',''),'P',''),'Q',''),'T',''),'U',''),'V',''),'W',''),'X',''),'Y',''),'Z',''),'.',''),'-',''),'_','') AS FLOAT)  "+_clrf
		_cQry += " 													 AND XXX.TES_DE = SD1.D1_TES  "+_clrf
		_cQry += " 													 AND (XXX.NCM = SB1.B1_POSIPI OR (XXX.NCM IN ('remessa','consumo','frete','comunicacao','locacao') AND SUBSTRING(XXX.CFOP,2,3) = SUBSTRING(D1_CF,2,3) ))  "+_clrf
		_cQry += " 													 AND XXX.D_E_L_E_T_ = '' "+_clrf
		_cQry += " 	INNER JOIN "+RetSqlName("SF3")+" SF3 WITH (NOLOCK) ON F3_REPROC = 'N' AND F3_FILIAL = D1_FILIAL AND F3_ENTRADA = D1_DTDIGIT AND F3_NFISCAL = D1_DOC AND F3_SERIE = D1_SERIE AND F3_CLIEFOR = D1_FORNECE AND F3_LOJA = D1_LOJA AND F3_FORMUL = D1_FORMUL AND SF3.D_E_L_E_T_ = '' "+_clrf
		_cQry += " WHERE (SF1.F1_FILIAL = '01' OR SF1.F1_FILIAL = '04') "+_clrf
		_cQry += "   AND SF1.F1_DTDIGIT BETWEEN '"+DTOS(MV_PAR01)+"' AND '"+DTOS(MV_PAR02)+"' "+_clrf
		_cQry += "   AND SF1.D_E_L_E_T_ = '' "+_clrf
		If TcSqlExec(_cQry) < 0
			MsgStop("[TCSQLError - SCRIPTS GERAIS] " + TCSQLError(),_cRotina+"_108")
			lEnd := .T.
			TcRefresh("CT2")
			TcRefresh("SF1")
			TcRefresh("SF2")
			TcRefresh("SD1")
			TcRefresh("SD2")
			TcRefresh("SF3")
			TcRefresh("SFT")
			TcRefresh("SF4")
			MsgAlert("Processamento abortado!",_cRotina+"_E08")
			return !lEnd
		EndIf
		IncProc("Reabrindo flag ctb. "+RetSqlName("SF1")+"...")
		_cQry := " UPDATE SF1 SET F1_DTLANC = '' "+_clrf
		_cQry += " FROM "+RetSqlName("SF1")+" SF1 WITH (NOLOCK) "+_clrf
		_cQry += " WHERE (SF1.F1_FILIAL = '01' OR SF1.F1_FILIAL = '04') "+_clrf
		_cQry += "   AND SF1.F1_DTDIGIT BETWEEN '"+DTOS(MV_PAR01)+"' AND '"+DTOS(MV_PAR02)+"' "+_clrf
		_cQry += "   AND F1_DTLANC <> '' "+_clrf
		_cQry += "   AND SF1.D_E_L_E_T_ = '' "+_clrf
		If TcSqlExec(_cQry) < 0
			MsgStop("[TCSQLError - SCRIPTS GERAIS] " + TCSQLError(),_cRotina+"_109")
			lEnd := .T.
			TcRefresh("CT2")
			TcRefresh("SF1")
			TcRefresh("SF2")
			TcRefresh("SD1")
			TcRefresh("SD2")
			TcRefresh("SF3")
			TcRefresh("SFT")
			TcRefresh("SF4")
			MsgAlert("Processamento abortado!",_cRotina+"_E09")
			return !lEnd
		EndIf
		IncProc("Ajustando "+RetSqlName("SD1")+"...")
		_cQry := " UPDATE SD1 SET D1_TES = XXX.TES_ATE "+_clrf
		_cQry += " 			 , D1_CF = ((CASE WHEN F1_EST = 'EX' THEN '3' WHEN F1_EST = 'SP' THEN '1' ELSE '2' END)+SUBSTRING(SF4A.F4_CF,2,3)) "+_clrf
		_cQry += " 			 , D1_BASIMP6 = (CASE WHEN SF4A.F4_CSTPIS = '74' THEN 0 ELSE (CASE WHEN ISNULL(D1_BASIMP6,0) = 0 THEN D1_TOTAL ELSE ISNULL(D1_BASIMP6,0) END) END) "+_clrf
		_cQry += " 			 , D1_BASIMP5 = (CASE WHEN SF4A.F4_CSTCOF = '74' THEN 0 ELSE (CASE WHEN ISNULL(D1_BASIMP5,0) = 0 THEN D1_TOTAL ELSE ISNULL(D1_BASIMP5,0) END) END) "+_clrf
		_cQry += " 			 , D1_VALIMP6 = ROUND((CASE WHEN SF4A.F4_PISCOF = '4' OR SF4A.F4_CSTPIS IN ('71','72','73','74') THEN 0 ELSE (CASE WHEN D1_VALIMP6 = 0 THEN ((CASE WHEN SF4A.F4_CSTPIS = '74' THEN 0 ELSE (CASE WHEN ISNULL(D1_BASIMP6,0) = 0 THEN D1_TOTAL ELSE ISNULL(D1_BASIMP6,0) END) END) * ((CASE WHEN SF4A.F4_PISCOF = '4' OR SF4A.F4_CSTPIS IN ('71','72','73','74') THEN 0 ELSE (CASE WHEN D1_ALQIMP6 = 0 THEN 1.65 ELSE D1_ALQIMP6 END) END) / 100)) ELSE D1_VALIMP6 END) END),2) "+_clrf
		_cQry += " 			 , D1_VALIMP5 = ROUND((CASE WHEN SF4A.F4_PISCOF = '4' OR SF4A.F4_CSTCOF IN ('71','72','73','74') THEN 0 ELSE (CASE WHEN D1_VALIMP5 = 0 THEN ((CASE WHEN SF4A.F4_CSTCOF = '74' THEN 0 ELSE (CASE WHEN ISNULL(D1_BASIMP5,0) = 0 THEN D1_TOTAL ELSE ISNULL(D1_BASIMP5,0) END) END) * ((CASE WHEN SF4A.F4_PISCOF = '4' OR SF4A.F4_CSTCOF IN ('71','72','73','74') THEN 0 ELSE (CASE WHEN D1_ALQIMP5 = 0 THEN 7.60 ELSE D1_ALQIMP5 END) END) / 100)) ELSE D1_VALIMP5 END) END),2) "+_clrf
		_cQry += " 			 , D1_ALQIMP6 = (CASE WHEN SF4A.F4_PISCOF = '4' OR SF4A.F4_CSTPIS IN ('71','72','73','74') THEN 0 ELSE (CASE WHEN D1_ALQIMP6 = 0 THEN 1.65 ELSE D1_ALQIMP6 END) END) "+_clrf
		_cQry += " 			 , D1_ALQIMP5 = (CASE WHEN SF4A.F4_PISCOF = '4' OR SF4A.F4_CSTCOF IN ('71','72','73','74') THEN 0 ELSE (CASE WHEN D1_ALQIMP5 = 0 THEN 7.60 ELSE D1_ALQIMP5 END) END) "+_clrf
		_cQry += " FROM "+RetSqlName("SD1")+" SD1 WITH (NOLOCK)	 "+_clrf
		_cQry += " 	INNER JOIN "+RetSqlName("SF1")+" SF1 WITH (NOLOCK) ON SF1.F1_FILIAL = SD1.D1_FILIAL AND SF1.F1_DOC = SD1.D1_DOC AND SF1.F1_SERIE = SD1.D1_SERIE AND SF1.F1_FORNECE = SD1.D1_FORNECE AND SF1.F1_LOJA = SD1.D1_LOJA AND SF1.D_E_L_E_T_ = '' "+_clrf
		_cQry += " 	INNER JOIN "+RetSqlName("SB1")+" SB1 WITH (NOLOCK) ON SB1.B1_FILIAL = SD1.D1_FILIAL AND SB1.B1_COD = SD1.D1_COD AND SB1.D_E_L_E_T_ = '' "+_clrf
		_cQry += " 	INNER JOIN DEPARATES XXX WITH (NOLOCK) ON XXX.TIPO = 'E' "+_clrf
		_cQry += " 	                                                 AND XXX.FILIAL = SD1.D1_FILIAL "+_clrf
		_cQry += " 													 AND XXX.DT = SD1.D1_DTDIGIT  "+_clrf
		_cQry += " 													 AND XXX.NF = CAST(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(UPPER(SD1.D1_DOC),'A',''),'B',''),'C',''),'D',''),'E',''),'F',''),'G',''),'H',''),'I',''),'J',''),'K',''),'L',''),'M',''),'N',''),'O',''),'P',''),'Q',''),'R',''),'S',''),'T',''),'U',''),'V',''),'W',''),'X',''),'Y',''),'Z',''),'.',''),'-',''),'_',''),' ','') AS FLOAT) "+_clrf
		_cQry += " 													 AND XXX.TES_DE = SD1.D1_TES  "+_clrf
		_cQry += " 													 AND (XXX.NCM = SB1.B1_POSIPI OR (XXX.NCM IN ('remessa','consumo','frete','comunicacao','locacao') AND SUBSTRING(XXX.CFOP,2,3) = SUBSTRING(D1_CF,2,3) ))  "+_clrf
		_cQry += " 													 AND XXX.D_E_L_E_T_ = '' "+_clrf
		_cQry += " 	INNER JOIN "+RetSqlName("SF4")+" SF4D WITH (NOLOCK) ON SF4D.F4_FILIAL = SD1.D1_FILIAL AND SF4D.F4_CODIGO = XXX.TES_DE AND SF4D.D_E_L_E_T_ = '' "+_clrf
		_cQry += " 	INNER JOIN "+RetSqlName("SF4")+" SF4A WITH (NOLOCK) ON SF4A.F4_FILIAL = SD1.D1_FILIAL AND SF4A.F4_CODIGO = XXX.TES_ATE AND SF4A.D_E_L_E_T_ = '' "+_clrf
		_cQry += " WHERE (SD1.D1_FILIAL = '01' OR SD1.D1_FILIAL = '04') "+_clrf
		_cQry += "   AND SD1.D1_DTDIGIT BETWEEN '"+DTOS(MV_PAR01)+"' AND '"+DTOS(MV_PAR02)+"' "+_clrf
		_cQry += "   AND SD1.D_E_L_E_T_ = '' "+_clrf
		If TcSqlExec(_cQry) < 0
			MsgStop("[TCSQLError - SCRIPTS GERAIS] " + TCSQLError(),_cRotina+"_110")
			lEnd := .T.
			TcRefresh("CT2")
			TcRefresh("SF1")
			TcRefresh("SF2")
			TcRefresh("SD1")
			TcRefresh("SD2")
			TcRefresh("SF3")
			TcRefresh("SFT")
			TcRefresh("SF4")
			MsgAlert("Processamento abortado!",_cRotina+"_E10")
			return !lEnd
		EndIf
		IncProc("Ajustando "+RetSqlName("SD1")+"...")
		_cQry := " UPDATE SD1 SET D1_BASIMP6 = (CASE WHEN SF4.F4_CSTPIS = '74' THEN 0 ELSE (CASE WHEN ISNULL(D1_BASIMP6,0) = 0 THEN D1_TOTAL ELSE ISNULL(D1_BASIMP6,0) END) END) "+_clrf
		_cQry += " 			 , D1_BASIMP5 = (CASE WHEN SF4.F4_CSTCOF = '74' THEN 0 ELSE (CASE WHEN ISNULL(D1_BASIMP5,0) = 0 THEN D1_TOTAL ELSE ISNULL(D1_BASIMP5,0) END) END) "+_clrf
		_cQry += " 			 , D1_VALIMP6 = ROUND((CASE WHEN SF4.F4_PISCOF = '4' OR SF4.F4_CSTPIS IN ('71','72','73','74') THEN 0 ELSE (CASE WHEN D1_VALIMP6 = 0 THEN ((CASE WHEN SF4.F4_CSTPIS = '74' THEN 0 ELSE (CASE WHEN ISNULL(D1_BASIMP6,0) = 0 THEN D1_TOTAL ELSE ISNULL(D1_BASIMP6,0) END) END) * ((CASE WHEN SF4.F4_PISCOF = '4' OR SF4.F4_CSTPIS IN ('71','72','73','74') THEN 0 ELSE (CASE WHEN D1_ALQIMP6 = 0 THEN 1.65 ELSE D1_ALQIMP6 END) END) / 100)) ELSE D1_VALIMP6 END) END),2) "+_clrf
		_cQry += " 			 , D1_VALIMP5 = ROUND((CASE WHEN SF4.F4_PISCOF = '4' OR SF4.F4_CSTCOF IN ('71','72','73','74') THEN 0 ELSE (CASE WHEN D1_VALIMP5 = 0 THEN ((CASE WHEN SF4.F4_CSTCOF = '74' THEN 0 ELSE (CASE WHEN ISNULL(D1_BASIMP5,0) = 0 THEN D1_TOTAL ELSE ISNULL(D1_BASIMP5,0) END) END) * ((CASE WHEN SF4.F4_PISCOF = '4' OR SF4.F4_CSTCOF IN ('71','72','73','74') THEN 0 ELSE (CASE WHEN D1_ALQIMP5 = 0 THEN 7.60 ELSE D1_ALQIMP5 END) END) / 100)) ELSE D1_VALIMP5 END) END),2) "+_clrf
		_cQry += " 			 , D1_ALQIMP6 = (CASE WHEN SF4.F4_PISCOF = '4' OR SF4.F4_CSTPIS IN ('71','72','73','74') THEN 0 ELSE (CASE WHEN D1_ALQIMP6 = 0 THEN 1.65 ELSE D1_ALQIMP6 END) END) "+_clrf
		_cQry += " 			 , D1_ALQIMP5 = (CASE WHEN SF4.F4_PISCOF = '4' OR SF4.F4_CSTCOF IN ('71','72','73','74') THEN 0 ELSE (CASE WHEN D1_ALQIMP5 = 0 THEN 7.60 ELSE D1_ALQIMP5 END) END) "+_clrf
		_cQry += " FROM "+RetSqlName("SD1")+" SD1 WITH (NOLOCK)	 "+_clrf
		_cQry += " 	INNER JOIN "+RetSqlName("SF4")+" SF4 WITH (NOLOCK) ON SF4.F4_FILIAL = SD1.D1_FILIAL AND SF4.F4_CODIGO = SD1.D1_TES AND SF4.D_E_L_E_T_ = '' "+_clrf
		_cQry += " WHERE (SD1.D1_FILIAL = '01' OR SD1.D1_FILIAL = '04') "+_clrf
		_cQry += "   AND SD1.D1_DTDIGIT BETWEEN '"+DTOS(MV_PAR01)+"' AND '"+DTOS(MV_PAR02)+"' "+_clrf
		_cQry += "   AND SD1.D_E_L_E_T_ = '' "+_clrf
		If TcSqlExec(_cQry) < 0
			MsgStop("[TCSQLError - SCRIPTS GERAIS] " + TCSQLError(),_cRotina+"_111")
			lEnd := .T.
			TcRefresh("CT2")
			TcRefresh("SF1")
			TcRefresh("SF2")
			TcRefresh("SD1")
			TcRefresh("SD2")
			TcRefresh("SF3")
			TcRefresh("SFT")
			TcRefresh("SF4")
			MsgAlert("Processamento abortado!",_cRotina+"_E11")
			return !lEnd
		EndIf
		IncProc("Recalculando "+RetSqlName("SF1")+"...")
		_cQry := " UPDATE ATU SET F1_BASIMP6 = KKK.D1_BASIMP6, F1_BASIMP5 = KKK.D1_BASIMP5, F1_VALIMP6 = KKK.D1_VALIMP6, F1_VALIMP5 = KKK.D1_VALIMP5, F1_DTLANC = '' "+_clrf
		_cQry += " FROM ( "+_clrf
		_cQry += " 		SELECT SF1.R_E_C_N_O_ RECSF1, F1_FILIAL, F1_DOC, F1_SERIE, F1_FORNECE, F1_LOJA, F1_FORMUL, F1_BASIMP6, SUM(D1_BASIMP6) D1_BASIMP6, F1_BASIMP5, SUM(D1_BASIMP5) D1_BASIMP5, F1_VALIMP6, SUM(D1_VALIMP6) D1_VALIMP6, F1_VALIMP5, SUM(D1_VALIMP5) D1_VALIMP5 "+_clrf
		_cQry += " 		FROM "+RetSqlName("SD1")+" SD1 WITH (NOLOCK)	 "+_clrf
		_cQry += " 			INNER JOIN "+RetSqlName("SF1")+" SF1 WITH (NOLOCK) ON SF1.F1_FILIAL = SD1.D1_FILIAL AND SF1.F1_DOC = SD1.D1_DOC AND SF1.F1_SERIE = SD1.D1_SERIE AND SF1.F1_FORNECE = SD1.D1_FORNECE AND SF1.F1_LOJA = SD1.D1_LOJA AND SF1.D_E_L_E_T_ = '' "+_clrf
		_cQry += " 		WHERE (SD1.D1_FILIAL = '01' OR SD1.D1_FILIAL = '04') "+_clrf
		_cQry += " 		  AND SD1.D1_DTDIGIT BETWEEN '"+DTOS(MV_PAR01)+"' AND '"+DTOS(MV_PAR02)+"' "+_clrf
		_cQry += " 		  AND SD1.D_E_L_E_T_ = '' "+_clrf
		_cQry += " 		GROUP BY SF1.R_E_C_N_O_, F1_FILIAL, F1_DOC, F1_SERIE, F1_FORNECE, F1_LOJA, F1_FORMUL, F1_BASIMP6, F1_BASIMP5, F1_VALIMP6, F1_VALIMP5 "+_clrf
		_cQry += " 	) KKK "+_clrf
		_cQry += " 	INNER JOIN "+RetSqlName("SF1")+" ATU ON ATU.R_E_C_N_O_ = KKK.RECSF1 AND (ATU.F1_BASIMP6 <> D1_BASIMP6 OR ATU.F1_BASIMP5 <> D1_BASIMP5 OR ATU.F1_VALIMP6 <> D1_VALIMP6 OR ATU.F1_VALIMP5 <> D1_VALIMP5) "+_clrf
		If TcSqlExec(_cQry) < 0
			MsgStop("[TCSQLError - SCRIPTS GERAIS] " + TCSQLError(),_cRotina+"_112")
			lEnd := .T.
			TcRefresh("CT2")
			TcRefresh("SF1")
			TcRefresh("SF2")
			TcRefresh("SD1")
			TcRefresh("SD2")
			TcRefresh("SF3")
			TcRefresh("SFT")
			TcRefresh("SF4")
			MsgAlert("Processamento abortado!",_cRotina+"_E12")
			return !lEnd
		EndIf
	EndIf
	If MV_PAR03 <> 2			//Saidas ou Ambos
		//	_cQry += " -----------------------------------------------------------------------SAIDAS-------------------------------------------------------------------------------------- "+_clrf
		IncProc("Backup "+RetSqlName("SD2")+"...")
		_cQry := " SELECT * INTO "+RetSqlName("SD2")+"_"+_cRef+" FROM "+RetSqlName("SD2")+" WHERE D2_EMISSAO BETWEEN '"+DTOS(MV_PAR01)+"' AND '"+DTOS(MV_PAR02)+"' "+_clrf
		If TcSqlExec(_cQry) < 0
			MsgStop("[TCSQLError - SCRIPTS GERAIS] " + TCSQLError(),_cRotina+"_113")
			lEnd := .T.
			TcRefresh("CT2")
			TcRefresh("SF1")
			TcRefresh("SF2")
			TcRefresh("SD1")
			TcRefresh("SD2")
			TcRefresh("SF3")
			TcRefresh("SFT")
			TcRefresh("SF4")
			MsgAlert("Processamento abortado!",_cRotina+"_E13")
			return !lEnd
		EndIf
		IncProc("Backup "+RetSqlName("SF2")+"...")
		_cQry := " SELECT * INTO "+RetSqlName("SF2")+"_"+_cRef+" FROM "+RetSqlName("SF2")+" WHERE F2_EMISSAO BETWEEN '"+DTOS(MV_PAR01)+"' AND '"+DTOS(MV_PAR02)+"' "+_clrf
		If TcSqlExec(_cQry) < 0
			MsgStop("[TCSQLError - SCRIPTS GERAIS] " + TCSQLError(),_cRotina+"_114")
			lEnd := .T.
			TcRefresh("CT2")
			TcRefresh("SF1")
			TcRefresh("SF2")
			TcRefresh("SD1")
			TcRefresh("SD2")
			TcRefresh("SF3")
			TcRefresh("SFT")
			TcRefresh("SF4")
			MsgAlert("Processamento abortado!",_cRotina+"_E14")
			return !lEnd
		EndIf
		IncProc("Apagando "+RetSqlName("CT2")+" (saídas)...")
		_cQry := " UPDATE "+RetSqlName("CT2")+" SET CT2_FILIAL = 'XX', D_E_L_E_T_ = '*', R_E_C_D_E_L_ = R_E_C_N_O_ WHERE CT2_FILIAL = '' AND CT2_LOTE = '008820' AND CT2_DATA BETWEEN '"+DTOS(MV_PAR01)+"' AND '"+DTOS(MV_PAR02)+"' AND D_E_L_E_T_ = '' "+_clrf
		If TcSqlExec(_cQry) < 0
			MsgStop("[TCSQLError - SCRIPTS GERAIS] " + TCSQLError(),_cRotina+"_115")
			lEnd := .T.
			TcRefresh("CT2")
			TcRefresh("SF1")
			TcRefresh("SF2")
			TcRefresh("SD1")
			TcRefresh("SD2")
			TcRefresh("SF3")
			TcRefresh("SFT")
			TcRefresh("SF4")
			MsgAlert("Processamento abortado!",_cRotina+"_E15")
			return !lEnd
		EndIf
		IncProc("Ajustando F3_REPROC (saídas)...")
		_cQry := " UPDATE SF3 SET F3_REPROC = 'S' "+_clrf
		_cQry += " FROM "+RetSqlName("SF2")+" SF2 WITH (NOLOCK) "+_clrf
		_cQry += " 	INNER JOIN "+RetSqlName("SD2")+" SD2 WITH (NOLOCK) ON SF2.F2_FILIAL = SD2.D2_FILIAL AND SF2.F2_DOC = SD2.D2_DOC AND SF2.F2_SERIE = SD2.D2_SERIE AND SF2.F2_CLIENTE = SD2.D2_CLIENTE AND SF2.F2_LOJA = SD2.D2_LOJA AND SD2.D_E_L_E_T_ = '' "+_clrf
		_cQry += " 	INNER JOIN "+RetSqlName("SB1")+" SB1 WITH (NOLOCK) ON SB1.B1_FILIAL = SD2.D2_FILIAL AND SB1.B1_COD = SD2.D2_COD AND SB1.D_E_L_E_T_ = '' "+_clrf
		_cQry += " 	INNER JOIN DEPARATES XXX WITH (NOLOCK) ON XXX.TIPO = 'S' "+_clrf
		_cQry += " 	                                                 AND XXX.FILIAL = SD2.D2_FILIAL "+_clrf
		_cQry += " 	                                                 AND XXX.DT = SD2.D2_EMISSAO "+_clrf
		_cQry += " 													 AND XXX.NF = CAST(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(UPPER(SD2.D2_DOC),'A',''),'B',''),'C',''),'D',''),'E',''),'F',''),'G',''),'H',''),'I',''),'J',''),'K',''),'L',''),'M',''),'N',''),'O',''),'P',''),'Q',''),'R',''),'S',''),'T',''),'U',''),'V',''),'W',''),'X',''),'Y',''),'Z',''),'.',''),'-',''),'_',''),' ','') AS FLOAT) "+_clrf
		_cQry += " 													 AND XXX.TES_DE = SD2.D2_TES  "+_clrf
		_cQry += " 													 AND (XXX.NCM = SB1.B1_POSIPI OR (XXX.NCM IN ('remessa','consumo','frete','comunicacao','locacao') AND SUBSTRING(XXX.CFOP,2,3) = SUBSTRING(D2_CF,2,3) ))  "+_clrf
		_cQry += " 													 AND XXX.D_E_L_E_T_ = '' "+_clrf
		_cQry += " 	INNER JOIN "+RetSqlName("SF3")+" SF3 WITH (NOLOCK) ON F3_REPROC = 'N' AND F3_FILIAL = D2_FILIAL AND F3_ENTRADA = D2_EMISSAO AND F3_NFISCAL = D2_DOC AND F3_SERIE = D2_SERIE AND F3_CLIEFOR = D2_CLIENTE AND F3_LOJA = D2_LOJA AND SF3.D_E_L_E_T_ = '' "+_clrf
		_cQry += " WHERE (F2_FILIAL = '01' OR F2_FILIAL = '04') "+_clrf
		_cQry += "   AND F2_EMISSAO BETWEEN '"+DTOS(MV_PAR01)+"' AND '"+DTOS(MV_PAR02)+"' "+_clrf
		_cQry += "   AND SF2.D_E_L_E_T_ = '' "+_clrf
		If TcSqlExec(_cQry) < 0
			MsgStop("[TCSQLError - SCRIPTS GERAIS] " + TCSQLError(),_cRotina+"_116")
			lEnd := .T.
			TcRefresh("CT2")
			TcRefresh("SF1")
			TcRefresh("SF2")
			TcRefresh("SD1")
			TcRefresh("SD2")
			TcRefresh("SF3")
			TcRefresh("SFT")
			TcRefresh("SF4")
			MsgAlert("Processamento abortado!",_cRotina+"_E16")
			return !lEnd
		EndIf
		IncProc("Reabrindo flag ctb. "+RetSqlName("SF2")+"...")
		_cQry := " UPDATE SF2 SET F2_DTLANC = '' "+_clrf
		_cQry += " FROM "+RetSqlName("SF2")+" SF2 WITH (NOLOCK) "+_clrf
		_cQry += " WHERE (F2_FILIAL = '01' OR F2_FILIAL = '04') "+_clrf
		_cQry += "   AND F2_EMISSAO BETWEEN '"+DTOS(MV_PAR01)+"' AND '"+DTOS(MV_PAR02)+"' "+_clrf
		_cQry += "   AND F2_DTLANC <> '' "+_clrf
		_cQry += "   AND SF2.D_E_L_E_T_ = '' "+_clrf
		If TcSqlExec(_cQry) < 0
			MsgStop("[TCSQLError - SCRIPTS GERAIS] " + TCSQLError(),_cRotina+"_117")
			lEnd := .T.
			TcRefresh("CT2")
			TcRefresh("SF1")
			TcRefresh("SF2")
			TcRefresh("SD1")
			TcRefresh("SD2")
			TcRefresh("SF3")
			TcRefresh("SFT")
			TcRefresh("SF4")
			MsgAlert("Processamento abortado!",_cRotina+"_E17")
			return !lEnd
		EndIf
		IncProc("Ajustando "+RetSqlName("SD2")+"...")
		_cQry := " UPDATE SD2 SET D2_TES = XXX.TES_ATE "+_clrf
		//_cQry += " 			 , D2_CF = ((CASE WHEN F2_EST = 'EX' THEN '7' WHEN F2_EST = 'SP' THEN '5' ELSE '6' END)+SUBSTRING(SF4A.F4_CF,2,3)) "+_clrf
		//_cQry += " 			 , D2_CF = ((CASE WHEN F2_EST = 'EX' THEN '7' WHEN F2_EST = 'SP' THEN '5' ELSE '6' END)+CASE WHEN (A1_CONTRIB = '2' OR A1_PESSOA = 'F') THEN '108' ELSE SUBSTRING(SF4A.F4_CF,2,3) END) "+_clrf  --
		_cQry += " 			 , D2_CF = ((CASE WHEN F2_EST = 'EX' THEN '7' WHEN F2_EST = 'SP' THEN '5' ELSE '6' END)+CASE WHEN (A1_EST <> 'SP' AND (A1_CONTRIB = '2' OR A1_PESSOA = 'F') ) THEN '108' ELSE SUBSTRING(SF4A.F4_CF,2,3) END) "+_clrf
		_cQry += " 			 , D2_BASIMP6 = (CASE WHEN SF4A.F4_CSTPIS = '08' THEN 0 ELSE (CASE WHEN ISNULL(D2_BASIMP6,0) = 0 THEN D2_TOTAL ELSE ISNULL(D2_BASIMP6,0) END) END) "+_clrf
		_cQry += " 			 , D2_BASIMP5 = (CASE WHEN SF4A.F4_CSTCOF = '08' THEN 0 ELSE (CASE WHEN ISNULL(D2_BASIMP5,0) = 0 THEN D2_TOTAL ELSE ISNULL(D2_BASIMP5,0) END) END) "+_clrf
		_cQry += " 			 , D2_VALIMP6 = ROUND((CASE WHEN SF4A.F4_PISCOF = '4' OR SF4A.F4_CSTPIS IN ('06','07','08','09') THEN 0 ELSE (CASE WHEN D2_VALIMP6 = 0 THEN ((CASE WHEN SF4A.F4_CSTPIS = '08' THEN 0 ELSE (CASE WHEN ISNULL(D2_BASIMP6,0) = 0 THEN D2_TOTAL ELSE ISNULL(D2_BASIMP6,0) END) END) * ((CASE WHEN SF4A.F4_PISCOF = '4' OR SF4A.F4_CSTPIS IN ('06','07','08','09') THEN 0 ELSE (CASE WHEN D2_ALQIMP6 = 0 THEN 1.65 ELSE D2_ALQIMP6 END) END) / 100)) ELSE D2_VALIMP6 END) END),2) "+_clrf
		_cQry += " 			 , D2_VALIMP5 = ROUND((CASE WHEN SF4A.F4_PISCOF = '4' OR SF4A.F4_CSTCOF IN ('06','07','08','09') THEN 0 ELSE (CASE WHEN D2_VALIMP5 = 0 THEN ((CASE WHEN SF4A.F4_CSTCOF = '08' THEN 0 ELSE (CASE WHEN ISNULL(D2_BASIMP5,0) = 0 THEN D2_TOTAL ELSE ISNULL(D2_BASIMP5,0) END) END) * ((CASE WHEN SF4A.F4_PISCOF = '4' OR SF4A.F4_CSTCOF IN ('06','07','08','09') THEN 0 ELSE (CASE WHEN D2_ALQIMP5 = 0 THEN 7.60 ELSE D2_ALQIMP5 END) END) / 100)) ELSE D2_VALIMP5 END) END),2) "+_clrf
		_cQry += " 			 , D2_ALQIMP6 = (CASE WHEN SF4A.F4_PISCOF = '4' OR SF4A.F4_CSTPIS IN ('06','07','08','09') THEN 0 ELSE (CASE WHEN D2_ALQIMP6 = 0 THEN 1.65 ELSE D2_ALQIMP6 END) END) "+_clrf
		_cQry += " 			 , D2_ALQIMP5 = (CASE WHEN SF4A.F4_PISCOF = '4' OR SF4A.F4_CSTCOF IN ('06','07','08','09') THEN 0 ELSE (CASE WHEN D2_ALQIMP5 = 0 THEN 7.60 ELSE D2_ALQIMP5 END) END) "+_clrf
		_cQry += " FROM "+RetSqlName("SD2")+" SD2 WITH (NOLOCK)	 "+_clrf
		_cQry += " 	INNER JOIN "+RetSqlName("SF2")+" SF2 WITH (NOLOCK) ON SF2.F2_FILIAL = SD2.D2_FILIAL AND SF2.F2_DOC = SD2.D2_DOC AND SF2.F2_SERIE = SD2.D2_SERIE AND SF2.F2_CLIENTE = SD2.D2_CLIENTE AND SF2.F2_LOJA = SD2.D2_LOJA AND SF2.D_E_L_E_T_ = '' "+_clrf
		_cQry += " 	INNER JOIN "+RetSqlName("SB1")+" SB1 WITH (NOLOCK) ON SB1.B1_FILIAL = SD2.D2_FILIAL AND SB1.B1_COD = SD2.D2_COD AND SB1.D_E_L_E_T_ = '' "+_clrf
		_cQry += " 	INNER JOIN DEPARATES XXX WITH (NOLOCK) ON XXX.TIPO = 'S' "+_clrf
		_cQry += " 	                                                 AND XXX.FILIAL = SD2.D2_FILIAL "+_clrf
		_cQry += " 	                                                 AND XXX.DT = SD2.D2_EMISSAO "+_clrf
		_cQry += " 													 AND XXX.NF = CAST(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(UPPER(SD2.D2_DOC),'A',''),'B',''),'C',''),'D',''),'E',''),'F',''),'G',''),'H',''),'I',''),'J',''),'K',''),'L',''),'M',''),'N',''),'O',''),'P',''),'Q',''),'T',''),'U',''),'V',''),'W',''),'X',''),'Y',''),'Z',''),'.',''),'-',''),'_','') AS FLOAT)  "+_clrf
		_cQry += " 													 AND XXX.TES_DE = SD2.D2_TES  "+_clrf
		_cQry += " 													 AND (XXX.NCM = SB1.B1_POSIPI OR (XXX.NCM IN ('remessa','consumo','frete','comunicacao','locacao') AND SUBSTRING(XXX.CFOP,2,3) = SUBSTRING(D2_CF,2,3) ))  "+_clrf
		_cQry += " 													 AND XXX.D_E_L_E_T_ = '' "+_clrf
		_cQry += " 	INNER JOIN "+RetSqlName("SF4")+" SF4D WITH (NOLOCK) ON SF4D.F4_FILIAL = SD2.D2_FILIAL AND SF4D.F4_CODIGO = XXX.TES_DE AND SF4D.D_E_L_E_T_ = '' "+_clrf
		_cQry += " 	INNER JOIN "+RetSqlName("SF4")+" SF4A WITH (NOLOCK) ON SF4A.F4_FILIAL = SD2.D2_FILIAL AND SF4A.F4_CODIGO = XXX.TES_ATE AND SF4A.D_E_L_E_T_ = '' "+_clrf
		_cQry += " 	INNER JOIN SA1010 SA1 ON SA1.A1_COD		= SF2.F2_CLIENTE AND SA1.A1_LOJA = SF2.F2_LOJA AND SA1.D_E_L_E_T_ = '' "+_clrf
		_cQry += " WHERE (SD2.D2_FILIAL = '01' OR SD2.D2_FILIAL = '04') "+_clrf
		_cQry += "   AND SD2.D2_EMISSAO BETWEEN '"+DTOS(MV_PAR01)+"' AND '"+DTOS(MV_PAR02)+"' "+_clrf
		_cQry += "   AND SD2.D_E_L_E_T_ = '' "+_clrf
		If TcSqlExec(_cQry) < 0
			MsgStop("[TCSQLError - SCRIPTS GERAIS] " + TCSQLError(),_cRotina+"_118")
			lEnd := .T.
			TcRefresh("CT2")
			TcRefresh("SF1")
			TcRefresh("SF2")
			TcRefresh("SD1")
			TcRefresh("SD2")
			TcRefresh("SF3")
			TcRefresh("SFT")
			TcRefresh("SF4")
			MsgAlert("Processamento abortado!",_cRotina+"_E18")
			return !lEnd
		EndIf
		IncProc("Ajustando "+RetSqlName("SD2")+"...")
		_cQry := " UPDATE SD2 SET D2_BASIMP6 = (CASE WHEN SF4.F4_CSTPIS = '08' THEN 0 ELSE (CASE WHEN ISNULL(D2_BASIMP6,0) = 0 THEN D2_TOTAL ELSE ISNULL(D2_BASIMP6,0) END) END) "+_clrf
		_cQry += " 			 , D2_BASIMP5 = (CASE WHEN SF4.F4_CSTCOF = '08' THEN 0 ELSE (CASE WHEN ISNULL(D2_BASIMP5,0) = 0 THEN D2_TOTAL ELSE ISNULL(D2_BASIMP5,0) END) END) "+_clrf
		_cQry += " 			 , D2_VALIMP6 = ROUND((CASE WHEN SF4.F4_PISCOF = '4' OR SF4.F4_CSTPIS IN ('06','07','08','09') THEN 0 ELSE (CASE WHEN D2_VALIMP6 = 0 THEN ((CASE WHEN SF4.F4_CSTPIS = '08' THEN 0 ELSE (CASE WHEN ISNULL(D2_BASIMP6,0) = 0 THEN D2_TOTAL ELSE ISNULL(D2_BASIMP6,0) END) END) * ((CASE WHEN SF4.F4_PISCOF = '4' OR SF4.F4_CSTPIS IN ('06','07','08','09') THEN 0 ELSE (CASE WHEN D2_ALQIMP6 = 0 THEN 1.65 ELSE D2_ALQIMP6 END) END) / 100)) ELSE D2_VALIMP6 END) END),2) "+_clrf
		_cQry += " 			 , D2_VALIMP5 = ROUND((CASE WHEN SF4.F4_PISCOF = '4' OR SF4.F4_CSTCOF IN ('06','07','08','09') THEN 0 ELSE (CASE WHEN D2_VALIMP5 = 0 THEN ((CASE WHEN SF4.F4_CSTCOF = '08' THEN 0 ELSE (CASE WHEN ISNULL(D2_BASIMP5,0) = 0 THEN D2_TOTAL ELSE ISNULL(D2_BASIMP5,0) END) END) * ((CASE WHEN SF4.F4_PISCOF = '4' OR SF4.F4_CSTCOF IN ('06','07','08','09') THEN 0 ELSE (CASE WHEN D2_ALQIMP5 = 0 THEN 7.60 ELSE D2_ALQIMP5 END) END) / 100)) ELSE D2_VALIMP5 END) END),2) "+_clrf
		_cQry += " 			 , D2_ALQIMP6 = (CASE WHEN SF4.F4_PISCOF = '4' OR SF4.F4_CSTPIS IN ('06','07','08','09') THEN 0 ELSE (CASE WHEN D2_ALQIMP6 = 0 THEN 1.65 ELSE D2_ALQIMP6 END) END) "+_clrf
		_cQry += " 			 , D2_ALQIMP5 = (CASE WHEN SF4.F4_PISCOF = '4' OR SF4.F4_CSTCOF IN ('06','07','08','09') THEN 0 ELSE (CASE WHEN D2_ALQIMP5 = 0 THEN 7.60 ELSE D2_ALQIMP5 END) END) "+_clrf
		_cQry += " FROM "+RetSqlName("SD2")+" SD2 WITH (NOLOCK)	"+_clrf
		_cQry += " 	INNER JOIN "+RetSqlName("SF4")+" SF4 WITH (NOLOCK) ON SF4.F4_FILIAL = SD2.D2_FILIAL AND SF4.F4_CODIGO = SD2.D2_TES AND SF4.D_E_L_E_T_ = '' "+_clrf
		_cQry += " WHERE (SD2.D2_FILIAL = '01' OR SD2.D2_FILIAL = '04') "+_clrf
		_cQry += "   AND SD2.D2_EMISSAO BETWEEN '"+DTOS(MV_PAR01)+"' AND '"+DTOS(MV_PAR02)+"' "+_clrf
		_cQry += "   AND SD2.D_E_L_E_T_ = '' "+_clrf
		If TcSqlExec(_cQry) < 0
			MsgStop("[TCSQLError - SCRIPTS GERAIS] " + TCSQLError(),_cRotina+"_119")
			lEnd := .T.
			TcRefresh("CT2")
			TcRefresh("SF1")
			TcRefresh("SF2")
			TcRefresh("SD1")
			TcRefresh("SD2")
			TcRefresh("SF3")
			TcRefresh("SFT")
			TcRefresh("SF4")
			MsgAlert("Processamento abortado!",_cRotina+"_E19")
			return !lEnd
		EndIf
		IncProc("Recalculando "+RetSqlName("SF2")+"...")
		_cQry := " UPDATE ATU SET F2_BASIMP6 = KKK.D2_BASIMP6, F2_BASIMP5 = KKK.D2_BASIMP5, F2_VALIMP6 = KKK.D2_VALIMP6, F2_VALIMP5 = KKK.D2_VALIMP5, F2_DTLANC = '' "+_clrf
		_cQry += " FROM ( "+_clrf
		_cQry += " 		SELECT SF2.R_E_C_N_O_ RECSF2, F2_FILIAL, F2_DOC, F2_SERIE, F2_CLIENTE, F2_LOJA, F2_FORMUL, F2_BASIMP6, SUM(D2_BASIMP6) D2_BASIMP6, F2_BASIMP5, SUM(D2_BASIMP5) D2_BASIMP5, F2_VALIMP6, SUM(D2_VALIMP6) D2_VALIMP6, F2_VALIMP5, SUM(D2_VALIMP5) D2_VALIMP5 "+_clrf
		_cQry += " 		FROM "+RetSqlName("SD2")+" SD2 WITH (NOLOCK)	 "+_clrf
		_cQry += " 			INNER JOIN "+RetSqlName("SF2")+" SF2 WITH (NOLOCK) ON SF2.F2_FILIAL = SD2.D2_FILIAL AND SF2.F2_DOC = SD2.D2_DOC AND SF2.F2_SERIE = SD2.D2_SERIE AND SF2.F2_CLIENTE = SD2.D2_CLIENTE AND SF2.F2_LOJA = SD2.D2_LOJA AND SF2.D_E_L_E_T_ = '' "+_clrf
		_cQry += " 		WHERE (SD2.D2_FILIAL = '01' OR SD2.D2_FILIAL = '04') "+_clrf
		_cQry += " 		  AND SD2.D2_EMISSAO BETWEEN '"+DTOS(MV_PAR01)+"' AND '"+DTOS(MV_PAR02)+"' "+_clrf
		_cQry += " 		  AND SD2.D_E_L_E_T_ = '' "+_clrf
		_cQry += " 		GROUP BY SF2.R_E_C_N_O_, F2_FILIAL, F2_DOC, F2_SERIE, F2_CLIENTE, F2_LOJA, F2_FORMUL, F2_BASIMP6, F2_BASIMP5, F2_VALIMP6, F2_VALIMP5 "+_clrf
		_cQry += " 	) KKK "+_clrf
		_cQry += " 	INNER JOIN "+RetSqlName("SF2")+" ATU ON ATU.R_E_C_N_O_ = KKK.RECSF2 AND (ATU.F2_BASIMP6 <> D2_BASIMP6 OR ATU.F2_BASIMP5 <> D2_BASIMP5 OR ATU.F2_VALIMP6 <> D2_VALIMP6 OR ATU.F2_VALIMP5 <> D2_VALIMP5) "+_clrf
		If TcSqlExec(_cQry) < 0
			MsgStop("[TCSQLError - SCRIPTS GERAIS] " + TCSQLError(),_cRotina+"_120")
			lEnd := .T.
			TcRefresh("CT2")
			TcRefresh("SF1")
			TcRefresh("SF2")
			TcRefresh("SD1")
			TcRefresh("SD2")
			TcRefresh("SF3")
			TcRefresh("SFT")
			TcRefresh("SF4")
			MsgAlert("Processamento abortado!",_cRotina+"_E20")
			return !lEnd
		EndIf
	EndIf
	IncProc("Finalizando...")
	TcRefresh("CT2")
	TcRefresh("SF1")
	TcRefresh("SF2")
	TcRefresh("SD1")
	TcRefresh("SD2")
	TcRefresh("SF3")
	TcRefresh("SFT")
	TcRefresh("SF4")
	MsgInfo("Termino de processamento!",_cRotina+"_011")
return
static function ValidPerg()
	//local  _aAlias := Alias()
	local  aRegs   := {}
	local  i       := 0
	local  j       := 0

	dbSelectArea("SX1")
	SX1->(dbSetOrder(1))
	cPerg := PADR(cPerg,len(SX1->X1_GRUPO))

	AADD(aRegs,{cPerg,"01","De Data?"                   ,"","","mv_ch1","D",08,0,0,"G","","mv_par01",""     ,"","","","",""        ,"","","","",""      ,"","","","","","","","","","","","","",""		,""})
	AADD(aRegs,{cPerg,"02","Até Data?"                  ,"","","mv_ch2","D",18,0,0,"G","","mv_par02",""     ,"","","","",""        ,"","","","",""      ,"","","","","","","","","","","","","",""		,""})
	AADD(aRegs,{cPerg,"03","Tipo a Processar?"          ,"","","mv_ch3","N",01,0,0,"C","","mv_par03","Ambos","","","","","Entradas","","","","","Saídas","","","","","","","","","","","","","",""		,""})
	for i := 1 to len(aRegs)
		If !SX1->(dbSeek(cPerg+aRegs[i,2]))
			while !RecLock("SX1",.T.) ; enddo
				for j := 1 to FCount()
					If j <= Len(aRegs[i])
						FieldPut(j,aRegs[i,j])
					Else
						Exit
					EndIf
				next
			SX1->(MsUnLock())
		EndIf
	next
	//RestArea(_aAlias)
return

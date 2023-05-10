#INCLUDE "PROTHEUS.CH"
#INCLUDE "FILEIO.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "AP5MAIL.CH"

//-- Diretivas indicando as colunas dos documentos da viagem
#define CTSTATUS	 1
#define CTSTROTA	 2
#define CTMARCA	 	 3
#define CTSEQUEN	 4
#define CTARMAZE	 5
#define CTLOCALI	 6
#define CTFILDOC	 7
#define CTDOCTO	 	 8
#define CTSERIE	 	 9
#define CTREGDES	10
#define CTDATEMI	11
#define CTPRZENT	12
#define CTNOMREM	13
#define CTNOMDES	14
#define CTQTDVOL	15
#define CTVOLORI	16
#define CTPLIQUI	17
#define CTPESOM3	18
#define CTVALMER	19
#define CTVIAGEM	20
#define CTSEQDA7	21
#define CTSOLICI	22			//-- DUE_NOME
#define CTENDERE	23			//-- DUE_END
#define CTBAIRRO	24			//-- DUE_BAIRRO
#define CTMUNICI	25			//-- DUE_MUN
#define CTDATSOL	26			//-- DT5_DATSOL
#define CTHORSOL	27			//-- DT5_HORSOL
#define CTDATPRV	28			//-- DT5_DATPRV
#define CTHORPRV	29			//-- DT5_HORPRV
#define CTDOCROT	30			//-- Codigo que identifica a q rota pertence o documento
#define CTBLQDOC	31			//-- Tipos de bloqueio do documento
#define CTNUMAGE	32			//-- Numero do Agendamento( Carga Fechada ).
#define CTITEAGE	33			//-- Item do Agendamento( Carga Fechada ).
#define CTSERTMS	34			//-- Tipo do Servico.
#define CTDESSVT	35			//-- Descricao do Servico.
#define CTESTADO	36
#define CTDATENT	37

/*/{Protheus.doc} JLCadCli
Importação CT-e
@author DLeme
@type User function
@since Dez/2021
@version 1.0
/*/

User Function JLCadCli(aDadosSA1,aErro,_cCadCli)

	Local _lOk		 := .T.
	Local cTpCod 	 := SuperGetMV("ES_CODCLI",,"1") //--Define como sera o codigo e loja do cliente
	Local nPosCod 	 := Ascan(aDadosSA1, { |x| x[1] == "A1_COD" } )
	Local nPosLoj 	 := Ascan(aDadosSA1, { |x| x[1] == "A1_LOJA"} )
	Local nPosCgc 	 := Ascan(aDadosSA1, { |x| x[1] == "A1_CGC" } )
	Local lCodCli 	 := ExistBlock("EXPCDCL")
	Local aRet 		 := {}
	Local _cAlias   := ""
	Local _cQuery 	 := ""

	Local bPre   := {}
	Local bOk    := {}
	Local bTTS   := {}
	Local bNoTTS := {}
	Local aParam := {}

	Default _cCadCli  := SuperGetMv( "ES_CADCLI", .F., '1' )
//-- 1 - Cadastro cliente não encontrado automaticamente
//-- 2 - Não cadastra cliente não encontrado
//-- 3 - Cadastra cliente não encontrado, a partir da tela de cadastro

	Private __aCpos        := {}
	Private lMsErroAuto 	  := .F.
	Private lAutoErrNoFile := .T.
	Private INCLUI         := .T.
	Private ALTERA         := .F.

	If cTpCod == "1" //--Autonumeracao
		aDadosSA1[nPosCod][02] := GETSXENUM("SA1","A1_COD")
		ConfirmSX8()

		//--Pesquisa a ultima loja daquele codigo de cliente
		_cAlias  := GetNextAlias()
		_cQuery	:=  " SELECT MAX(SA1.A1_LOJA) AS A1_LOJA "
		_cQuery 	+=  "  FROM " + RetSqlName("SA1") + " SA1 "
		_cQuery 	+=  " WHERE SA1.A1_FILIAL  = '" + xFilial("SA1") + "' "
		_cQuery 	+=  "   AND SA1.A1_COD     = '" + aDadosSA1[nPosCod][02] + "' "
		_cQuery 	+=  "   AND SA1.D_E_L_E_T_ = ' ' "
		_cQuery 	+=  " GROUP BY SA1.A1_COD "
		_cQuery 	:= ChangeQuery(_cQuery)

		dbUseArea( .T., "TOPCONN", TCGENQRY(, ,_cQuery), _cAlias, .F., .T.)

		If (_cAlias)->( !Eof() )
			aDadosSA1[nPosLoj][02] := StrZero(Val(Soma1((_cAlias)->A1_LOJA)), TamSX3("A1_LOJA")[1])
		Else
			aDadosSA1[nPosLoj][02] := StrZero(1, TamSX3("A1_LOJA")[1])
		EndIf
		(_cAlias)->( DbCloseArea() )

	ElseIf cTpCod == "2" //--CNPJ ou CPF

		aDadosSA1[nPosCod][02] := Left(aDadosSA1[nPosCgc][02],TamSX3("A1_COD")[1])
		aDadosSA1[nPosLoj][02] := Substr(aDadosSA1[nPosCgc][02],9,TamSX3("A1_LOJA")[1])

	ElseIf cTpCod == "3" //--Especifico por PE

		If lCodCli
			aRet := ExecBlock("EXPCDCL",.F.,.F.)
			If ValType(aRet) == "A" .And. Len(aRet) == 2
				aDadosSA1[nPosCod][02] := aRet[01]
				aDadosSA1[nPosLoj][02] := aRet[02]
			EndIf
		EndIf

	ElseIf cTpCod == "4" //-- Dicionario
		//-- Codigo determinado a partir da configuracao do dicionario de dados
	EndIf

	If _cCadCli == "1"
		// MSExecAuto({|x,y| MATA030(x,y)},aDadosSA1,3)
		MSExecAuto({|x,y| CRMA980(x,y)},aDadosSA1,3)
		If lMsErroAuto
			aErro := GetAutoGRLog()
			//-- Retirar enter para exibir mensagem completa
			Aeval(aErro,{ | e, nI | aErro[nI] := Iif(At(Chr(13)+Chr(10),e) > 0,StrTran(e,Chr(13)+Chr(10)," "),e) })
			_lOk := .F.
		EndIf
	ElseIf _cCadCli == "3"

		SaveInter()

		__aCpos   := AClone(aDadosSA1)
		cCadastro := "Clientes - Incluir"

		bPre   := {|| Aeval(__aCpos,{ | e | M->&(e[1]) := e[2] }) }
		bOk    := {|| .T.}
		bTTS   := {|| .T.}
		bNoTTS := {|| .T.}

		aParam := { bPre, bOk, bTTS, bNoTTS }

		If AxInclui("SA1",0,3,,,,,/*lF3*/,/*cTransact*/,,aParam) <> 1
			_lOk := .F.
		EndIf

		RestInter()
	EndIf


Return(_lOk)


/*/{Protheus.doc} GBRetID
Importação CT-e
@author DLeme
@type User function
@since Dez/2021
@version 1.0
/*/

User Function JLRetID(cProcess, cChave)

	Local cRet		:= ""
	Local cQry		:= ""
	Local aArea     := GetArea()
	Local cAliasPA0	:= GetNextAlias()

	Default cProcess := ''
	Default cChave   := ''

	cQry += " SELECT PA0_ID "
	cQry += "   FROM " + RetSqlName("PA0") + " PA0 (NOLOCK) "
	cQry += "  WHERE PA0.D_E_L_E_T_ <> '*' "
	cQry += "    AND PA0_STATUS = '2' " //-- Processado com sucesso
	cQry += "  AND PA0_CHAVE    = '" + cChave + "' "
	cQry += "  AND PA0_ORIGEM = '" + cProcess + "' "

	cQry   := ChangeQuery(cQry)

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),cAliasPA0)

	If (cAliasPA0)->(!Eof())
		cRet := (cAliasPA0)->PA0_ID
	EndIf

	(cAliasPA0)->( dbCloseArea() )

	RestArea(aArea)

Return cRet

/*/{Protheus.doc} fGrvLog
//TODO Função fGrvLog   
@since Mai/2020  
@version 1.0
@return Objeto, oViewGBINCPA0

@type static function
/*/

User Function JLGrvLog(aLogImp)

	Local aArea 	:= GetArea()
	Local aAreaPA0 	:= PA0->(GetArea())
	Local cQuery	:= ""
	Local cItem		:= ""
	Local cCodUser	:= RetCodUsr()
	Local cNomUser	:= UsrRetName( cCodUser )
	Local nX
	Local cAliasPA0 := GetNextAlias()

	Default aLogImp := {}

	//BEGIN TRANSACTION

		If !Empty(aLogImp)

			For nX := 1 To Len(aLogImp)

				If Alltrim(aLogImp[nX][04]) != 'GB43I001'
					cQuery	:= "SELECT MAX(PA1_SEQ) PA1_SEQ "
					cQuery	+= "FROM " + RetSqlName("PA1") + " PA1 (NOLOCK) "
					cQuery	+= "WHERE PA1_FILIAL = '" + xFilial("PA1") + "' "
					cQuery	+= "AND PA1_ID = '" + aLogImp[nX][01] + "' "
					cQuery	+= "AND PA1.D_E_L_E_T_ = ' ' "

					dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasPA0, .T., .T. )

					If (cAliasPA0)->(!Eof())
						cItem := soma1(StrZero(val((cAliasPA0)->PA1_SEQ ),3))
					EndIf

					(cAliasPA0) ->(DbCloseArea())
				Else 
					cItem := '001'
				EndIf

				RecLock("PA1",.T.)
				PA1->PA1_FILIAL := xFilial("PA0")
				PA1->PA1_ID     := aLogImp[nX][01]
				PA1->PA1_SEQ 	:= cItem
				PA1->PA1_DATA   := IIF(!Empty(aLogImp[nX][02]),aLogImp[nX][02],Date()) 
				PA1->PA1_HORA   := IIF(!Empty(aLogImp[nX][03]),aLogImp[nX][03],Time())
				PA1->PA1_ORIGEM := aLogImp[nX][04]
				PA1->PA1_MSGRET	:= IIF(!Empty(aLogImp[nX][05]),aLogImp[nX][05],aLogImp[nX][09]) //aLogImp[nX][05]
				//PA1->PA1_INFXML	:= aLogImp[nX][06]
				//PA1->PA1_INFSF3	:= aLogImp[nX][07]
				//PA1->PA1_TES	:= aLogImp[nX][08]
				PA1->PA1_RETPRC	:= IIF(!Empty(aLogImp[nX][09]),aLogImp[nX][09],aLogImp[nX][05]) 
				PA1->PA1_USRID  := cCodUser
				PA1->PA1_USRNOM := cNomUser
				PA1->(MsUnLock())
			Next nX

		EndIf

	//END TRANSACTION
	RestArea(aAreaPA0)
	RestArea(aArea)

Return


/*/{Protheus.doc} GBINCPA0
//TODO Função GBINCPA0   
@since Mai/2020  
@version 1.0
@return Objeto, oView
@type static function
/*/

User Function JLINCPA0(aInfo,cMsgProc)

	Local nI      := 0
	Local aArea	  := GetArea()
	Local cIDPA0  := GetSx8Num("PA0","PA0_ID")
	Local aRet    := {.F.,cIDPA0}

	Default aInfo := {}

	If !Empty(aInfo)
		RecLock("PA0",.T.)
		PA0->PA0_FILIAL := xFilial("PA0")
		PA0->PA0_ID     := cIDPA0

		For nI := 1 To Len(aInfo)
			PA0->&(aInfo[nI,1])  := aInfo[nI,2]
		Next nI

		PA0->PA0_DATA   := Date()
		PA0->PA0_HORA   := Time()
		ConfirmSx8()

		PA0->(MsUnLock())

		ConOut("[JLCAD010] Inclusão realizada com sucesso!")
		aRet[1] := .T.
		aRet[2] := cIDPA0

		AADD(aLogImp,{cIDPA0,'','', Funname(),cMsgProc,'','','',cRetProc})
		u_JLGrvLog(aLogImp)

	Else
		ConOut("[JLCAD010] Informações não foram passadas para inclusão!")
		aRet[1] := .F.

	EndIf

	RestArea(aArea)

Return aRet

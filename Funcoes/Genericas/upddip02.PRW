#INCLUDE "PROTHEUS.CH"

#DEFINE SIMPLES Char( 39 )
#DEFINE DUPLAS  Char( 34 )

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫ Programa ≥ UPDFST   ∫ Autor ≥ TOTVS Protheus     ∫ Data ≥  13/07/12   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫ Descricao≥ Funcao de update dos dicion·rios para compatibilizaÁ„o     ≥±±
±±∫          ≥                                                            ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±≥ Uso      ≥ UPDFST     - Gerado por EXPORDIC / Upd. V.4.10.4 EFS       ≥±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
User Function UPDDIP02( cEmpAmb, cFilAmb, aMarcadas )

Local   aSay      := {}
Local   aButton   := {}
Local   cTitulo   := "ATUALIZA«√O DE DICION¡RIOS E TABELAS"
Local   cDesc1    := "Esta rotina tem como funÁ„o fazer  a atualizaÁ„o  dos dicion·rios do Sistema ( SX?/SIX )"
Local   cDesc2    := "Este processo deve ser executado em modo EXCLUSIVO, ou seja n„o podem haver outros"
Local   cDesc3    := "usu·rios  ou  jobs utilizando  o sistema.  … extremamente recomendavÈl  que  se  faÁa um"
Local   cDesc4    := "BACKUP  dos DICION¡RIOS  e da  BASE DE DADOS antes desta atualizaÁ„o, para que caso "
Local   cDesc5    := "ocorra eventuais falhas, esse backup seja ser restaurado."
Local   cDesc6    := ""
Local   cDesc7    := ""
Local   lOk       := .F.
Local   lAuto     := ( cEmpAmb <> NIL .or. cFilAmb <> NIL )

Private oMainWnd  := NIL
Private oProcess  := NIL

#IFDEF TOP
    TCInternal( 5, "*OFF" ) // Desliga Refresh no Lock do Top
#ENDIF

__cInterNet := NIL
__lPYME     := .F.

Set Dele On

// Mensagens de Tela Inicial
aAdd( aSay, cDesc1 )
aAdd( aSay, cDesc2 )
aAdd( aSay, cDesc3 )
aAdd( aSay, cDesc4 )
aAdd( aSay, cDesc5 )
//aAdd( aSay, cDesc6 )
//aAdd( aSay, cDesc7 )

// Botoes Tela Inicial
aAdd(  aButton, {  1, .T., { || lOk := .T., FechaBatch() } } )
aAdd(  aButton, {  2, .T., { || lOk := .F., FechaBatch() } } )

If lAuto
	lOk := .T.
Else
	lOk := .T.
EndIf

If lOk

	If !Empty( aMarcadas )
	
		oProcess := MsNewProcess():New( { | lEnd | lOk := FSTProc( @lEnd, aMarcadas ) }, "Atualizando", "Aguarde, atualizando ...", .F. )
		oProcess:Activate()

		If lAuto
			If lOk
				MsgStop( "AtualizaÁ„o Realizada.", "UPDFST" )
				dbCloseAll()
			Else
				MsgStop( "AtualizaÁ„o n„o Realizada.", "UPDFST" )
				dbCloseAll()
			EndIf
		Else
			If lOk
				Final( "AtualizaÁ„o ConcluÌda." )
			Else
				Final( "AtualizaÁ„o n„o Realizada." )
			EndIf
		EndIf
	Else
		MsgStop( "AtualizaÁ„o n„o Realizada.", "UPDFST" )

	EndIf

EndIf

Return NIL


/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫ Programa ≥ FSTProc  ∫ Autor ≥ TOTVS Protheus     ∫ Data ≥  13/07/12   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫ Descricao≥ Funcao de processamento da gravaÁ„o dos arquivos           ≥±±
±±∫          ≥                                                            ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±≥ Uso      ≥ FSTProc    - Gerado por EXPORDIC / Upd. V.4.10.4 EFS       ≥±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Static Function FSTProc( lEnd, aMarcadas )
Local   aInfo     := {}
Local   aRecnoSM0 := {}
Local   cAux      := ""
Local   cFile     := ""
Local   cFileLog  := ""
Local   cMask     := "Arquivos Texto" + "(*.TXT)|*.txt|"
Local   cTCBuild  := "TCGetBuild"
Local   cTexto    := ""
Local   cTopBuild := ""
Local   lOpen     := .F.
Local   lRet      := .T.
Local   nI        := 0
Local   nPos      := 0
Local   nRecno    := 0
Local   nX        := 0
Local   oDlg      := NIL
Local   oFont     := NIL
Local   oMemo     := NIL

Private aArqUpd   := {}

If ( lOpen := MyOpenSm0(.T.) )

	dbSelectArea( "SM0" )
	dbGoTop()

	While !SM0->( EOF() )
		// So adiciona no aRecnoSM0 se a empresa for diferente
		If aScan( aRecnoSM0, { |x| x[2] == SM0->M0_CODIGO } ) == 0 ;
		   .AND. aScan( aMarcadas, { |x| x[1] == SM0->M0_CODIGO } ) > 0
			aAdd( aRecnoSM0, { Recno(), SM0->M0_CODIGO } )
		EndIf
		SM0->( dbSkip() )
	End

	SM0->( dbCloseArea() )

	If lOpen

		For nI := 1 To Len( aRecnoSM0 )

			If !( lOpen := MyOpenSm0(.F.) )
				MsgStop( "AtualizaÁ„o da empresa " + aRecnoSM0[nI][2] + " n„o efetuada." )
				Exit
			EndIf

			SM0->( dbGoTo( aRecnoSM0[nI][1] ) )

			RpcSetType( 3 )
			RpcSetEnv( SM0->M0_CODIGO, SM0->M0_CODFIL )

			lMsFinalAuto := .F.
			lMsHelpAuto  := .F.

			cTexto += Replicate( "-", 128 ) + CRLF
			cTexto += "Empresa : " + SM0->M0_CODIGO + "/" + SM0->M0_NOME + CRLF + CRLF

			oProcess:SetRegua1( 8 )                         

			//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
			//≥Atualiza o dicion·rio SX2         ≥
			//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
			oProcess:IncRegua1( "Dicion·rio de arquivos" + " - " + SM0->M0_CODIGO + " " + SM0->M0_NOME + " ..." )
			FSAtuSX2( @cTexto )

			//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
			//≥Atualiza o dicion·rio SX3         ≥
			//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
			FSAtuSX3( @cTexto )

			oProcess:IncRegua1( "Dicion·rio de dados" + " - " + SM0->M0_CODIGO + " " + SM0->M0_NOME + " ..." )
			oProcess:IncRegua2( "Atualizando campos/Ìndices" )

			// Alteracao fisica dos arquivos
			__SetX31Mode( .F. )

			If FindFunction(cTCBuild)
				cTopBuild := &cTCBuild.()
			EndIf

			For nX := 1 To Len( aArqUpd )

				If cTopBuild >= "20090811" .AND. TcInternal( 89 ) == "CLOB_SUPPORTED"
					If ( ( aArqUpd[nX] >= "NQ " .AND. aArqUpd[nX] <= "NZZ" ) .OR. ( aArqUpd[nX] >= "O0 " .AND. aArqUpd[nX] <= "NZZ" ) ) .AND.;
						!aArqUpd[nX] $ "NQD,NQF,NQP,NQT"
						TcInternal( 25, "CLOB" )
					EndIf
				EndIf

				If Select( aArqUpd[nX] ) > 0
					dbSelectArea( aArqUpd[nX] )
					dbCloseArea()
				EndIf

				X31UpdTable( aArqUpd[nX] )

				If __GetX31Error()
					Alert( __GetX31Trace() )
					MsgStop( "Ocorreu um erro desconhecido durante a atualizaÁ„o da tabela : " + aArqUpd[nX] + ". Verifique a integridade do dicion·rio e da tabela.", "ATEN«√O" )
					cTexto += "Ocorreu um erro desconhecido durante a atualizaÁ„o da estrutura da tabela : " + aArqUpd[nX] + CRLF
				EndIf

				If cTopBuild >= "20090811" .AND. TcInternal( 89 ) == "CLOB_SUPPORTED"
					TcInternal( 25, "OFF" )
				EndIf

			Next nX
			
			//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
			//≥Atualiza o dicion·rio SX6         ≥
			//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
			oProcess:IncRegua1( "Dicion·rio de par‚metros" + " - " + SM0->M0_CODIGO + " " + SM0->M0_NOME + " ..." )
			FSAtuSX6( @cTexto )

			//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
			//≥Atualiza o dicion·rio SX5         ≥
			//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
			oProcess:IncRegua1( "Dicion·rio de tabelas sistema" + " - " + SM0->M0_CODIGO + " " + SM0->M0_NOME + " ..." )
			FSAtuSX5( @cTexto )
			
			//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
			//≥Atualiza o dicion·rio SX7         ≥
			//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
			oProcess:IncRegua1( "Dicion·rio de gatilhos" + " - " + SM0->M0_CODIGO + " " + SM0->M0_NOME + " ..." )
			FSAtuSX7( @cTexto )                                                                                     

			//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
			//≥Atualiza o dicion·rio SXB         ≥
			//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
			oProcess:IncRegua1( "Dicion·rio de consultas padr„o" + " - " + SM0->M0_CODIGO + " " + SM0->M0_NOME + " ..." )
			FSAtuSXB( @cTexto )

			//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
			//≥Atualiza o dicion·rio SIX         ≥
			//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
			oProcess:IncRegua1( "Dicion·rio de indices" + " - " + SM0->M0_CODIGO + " " + SM0->M0_NOME + " ..." )
			FSAtuSIX( @cTexto ) 
			
			
			//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
			//≥Atualiza o dicion·rio SX1         ≥
			//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
			oProcess:IncRegua1( "Dicion·rio de indices" + " - " + SM0->M0_CODIGO + " " + SM0->M0_NOME + " ..." )
			FSAtuSX1( @cTexto )
			

			RpcClearEnv()

		Next nI

		If MyOpenSm0(.T.)

			cAux += Replicate( "-", 128 ) + CRLF
			cAux += Replicate( " ", 128 ) + CRLF
			cAux += "LOG DA ATUALIZACAO DOS DICION¡RIOS" + CRLF
			cAux += Replicate( " ", 128 ) + CRLF
			cAux += Replicate( "-", 128 ) + CRLF
			cAux += CRLF
			cAux += " Dados Ambiente" + CRLF
			cAux += " --------------------"  + CRLF
			cAux += " Empresa / Filial...: " + cEmpAnt + "/" + cFilAnt  + CRLF
			cAux += " Nome Empresa.......: " + Capital( AllTrim( GetAdvFVal( "SM0", "M0_NOMECOM", cEmpAnt + cFilAnt, 1, "" ) ) ) + CRLF
			cAux += " Nome Filial........: " + Capital( AllTrim( GetAdvFVal( "SM0", "M0_FILIAL" , cEmpAnt + cFilAnt, 1, "" ) ) ) + CRLF
			cAux += " DataBase...........: " + DtoC( dDataBase )  + CRLF
			cAux += " Data / Hora Inicio.: " + DtoC( Date() )  + " / " + Time()  + CRLF
			cAux += " Environment........: " + GetEnvServer()  + CRLF
			cAux += " StartPath..........: " + GetSrvProfString( "StartPath", "" )  + CRLF
			cAux += " RootPath...........: " + GetSrvProfString( "RootPath" , "" )  + CRLF
			cAux += " Versao.............: " + GetVersao(.T.)  + CRLF
			cAux += " Usuario TOTVS .....: " + __cUserId + " " +  cUserName + CRLF
			cAux += " Computer Name......: " + GetComputerName() + CRLF

			aInfo   := GetUserInfo()
			If ( nPos    := aScan( aInfo,{ |x,y| x[3] == ThreadId() } ) ) > 0
				cAux += " "  + CRLF
				cAux += " Dados Thread" + CRLF
				cAux += " --------------------"  + CRLF
				cAux += " Usuario da Rede....: " + aInfo[nPos][1] + CRLF
				cAux += " Estacao............: " + aInfo[nPos][2] + CRLF
				cAux += " Programa Inicial...: " + aInfo[nPos][5] + CRLF
				cAux += " Environment........: " + aInfo[nPos][6] + CRLF
				cAux += " Conexao............: " + AllTrim( StrTran( StrTran( aInfo[nPos][7], Chr( 13 ), "" ), Chr( 10 ), "" ) )  + CRLF
			EndIf
			cAux += Replicate( "-", 128 ) + CRLF
			cAux += CRLF

			cTexto := cAux + cTexto + CRLF

			cTexto += Replicate( "-", 128 ) + CRLF
			cTexto += " Data / Hora Final.: " + DtoC( Date() ) + " / " + Time()  + CRLF
			cTexto += Replicate( "-", 128 ) + CRLF

			cFileLog := MemoWrite( CriaTrab( , .F. ) + ".log", cTexto )

			Define Font oFont Name "Mono AS" Size 5, 12

			Define MsDialog oDlg Title "Atualizacao concluida." From 3, 0 to 340, 417 Pixel

			@ 5, 5 Get oMemo Var cTexto Memo Size 200, 145 Of oDlg Pixel
			oMemo:bRClicked := { || AllwaysTrue() }
			oMemo:oFont     := oFont

			Define SButton From 153, 175 Type  1 Action oDlg:End() Enable Of oDlg Pixel // Apaga
			Define SButton From 153, 145 Type 13 Action ( cFile := cGetFile( cMask, "" ), If( cFile == "", .T., ;
			MemoWrite( cFile, cTexto ) ) ) Enable Of oDlg Pixel

			Activate MsDialog oDlg Center

		EndIf

	EndIf

Else

	lRet := .F.

EndIf

Return lRet       
/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫ Programa ≥ FSAtuSX2 ∫ Autor ≥ TOTVS Protheus     ∫ Data ≥  22/11/12   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫ Descricao≥ Funcao de processamento da gravacao do SX2 - Arquivos      ≥±±
±±∫          ≥                                                            ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±≥ Uso      ≥ FSAtuSX2   - Gerado por EXPORDIC / Upd. V.4.10.4 EFS       ≥±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Static Function FSAtuSX2( cTexto )
Local aEstrut   := {}
Local aSX2      := {}
Local cAlias    := ""
Local cEmpr     := ""
Local cPath     := ""
Local nI        := 0
Local nJ        := 0

cTexto  += "Inicio da Atualizacao" + " SX2" + CRLF + CRLF

aEstrut := { "X2_CHAVE"  , "X2_PATH"   , "X2_ARQUIVO", "X2_NOME"  , "X2_NOMESPA", "X2_NOMEENG", ;
             "X2_DELET"  , "X2_MODO"   , "X2_TTS"    , "X2_ROTINA", "X2_PYME"   , "X2_UNICO"  , ;
             "X2_MODULO" }

dbSelectArea( "SX2" )
SX2->( dbSetOrder( 1 ) )
SX2->( dbGoTop() )
cPath := SX2->X2_PATH
cPath := IIf( Right( AllTrim( cPath ), 1 ) <> "\", PadR( AllTrim( cPath ) + "\", Len( cPath ) ), cPath )
cEmpr := Substr( SX2->X2_ARQUIVO, 4 )


//
// Tabela ZZC
//
aAdd( aSX2, { ;
	'ZZC'																	, ; //X2_CHAVE
	cPath																	, ; //X2_PATH
	'ZZC'+cEmpr																, ; //X2_ARQUIVO
	'Inventario Rotativo - Header'											, ; //X2_NOME
	'Inventario Rotativo - Header'											, ; //X2_NOMESPA
	'Inventario Rotativo - Header'											, ; //X2_NOMEENG
	0																		, ; //X2_DELET
	'C'																		, ; //X2_MODO
	''																		, ; //X2_TTS
	''																		, ; //X2_ROTINA
	'N'																		, ; //X2_PYME
	'ZZC_FILIAL+ZZC_LOCAL+ZZC_LOCALI+DTOS(ZZC_DATA)'						, ; //X2_UNICO
	0																		} ) //X2_MODULO

//
// Tabela ZZD
//
aAdd( aSX2, { ;
	'ZZD'																	, ; //X2_CHAVE
	cPath																	, ; //X2_PATH
	'ZZD'+cEmpr																, ; //X2_ARQUIVO
	'Inventario Rotativo - Itens'											, ; //X2_NOME
	'Inventario Rotativo - Itens'											, ; //X2_NOMESPA
	'Inventario Rotativo - Itens'											, ; //X2_NOMEENG
	0																		, ; //X2_DELET
	'C'																		, ; //X2_MODO
	''																		, ; //X2_TTS
	''																		, ; //X2_ROTINA
	'N'																		, ; //X2_PYME
	'ZZD_FILIAL+ZZD_PRODUT+ZZD_LOTECT+ZZD_LOCAL+ZZD_LOCALI+DTOS(ZZD_DATA)'		, ; //X2_UNICO
	0																		} ) //X2_MODULO   
	
//	
// Tabela ZZE
//
aAdd( aSX2, { ;
	'ZZE'																	, ; //X2_CHAVE
	cPath																	, ; //X2_PATH
	'ZZE'+cEmpr																, ; //X2_ARQUIVO
	'Cadastro de NCMs           '											, ; //X2_NOME
	'Cadastro de NCMs           '											, ; //X2_NOMESPA
	'Cadastro de NCMs           '											, ; //X2_NOMEENG
	0																		, ; //X2_DELET
	'E'																		, ; //X2_MODO
	''																		, ; //X2_TTS
	''																		, ; //X2_ROTINA
	'N'																		, ; //X2_PYME
	'ZZE_FILIAL+ZZE_POSIPI+DTOS(ZZE_DTPVD+ZZE_DTPVA)'						, ; //X2_UNICO
	0																		} ) //X2_MODULO

//
// Tabela ZZF
//
aAdd( aSX2, { ;
	'ZZF'																	, ; //X2_CHAVE
	cPath																	, ; //X2_PATH
	'ZZF'+cEmpr																, ; //X2_ARQUIVO
	'Precos negociados'														, ; //X2_NOME
	'Precos negociados'														, ; //X2_NOMESPA
	'Precos negociados'														, ; //X2_NOMEENG
	0																		, ; //X2_DELET
	'E'																		, ; //X2_MODO
	''																		, ; //X2_TTS
	''																		, ; //X2_ROTINA
	'N'																		, ; //X2_PYME
	'ZZF_FILIAL+ZZF_CODIGO'													, ; //X2_UNICO
	0																		} ) //X2_MODULO

//
// Tabela ZZG
//
aAdd( aSX2, { ;
	'ZZG'																	, ; //X2_CHAVE
	cPath																	, ; //X2_PATH
	'ZZG'+cEmpr																, ; //X2_ARQUIVO
	'Itens negociados'														, ; //X2_NOME
	'Itens negociados'														, ; //X2_NOMESPA
	'Itens negociados'														, ; //X2_NOMEENG
	0																		, ; //X2_DELET
	'E'																		, ; //X2_MODO
	''																		, ; //X2_TTS
	''																		, ; //X2_ROTINA
	'N'																		, ; //X2_PYME
	'ZZG_FILIAL+ZZG_CODIGO+ZZG_SEQUEN'										, ; //X2_UNICO
	0																		} ) //X2_MODULO
	
//
// Tabela ZZI
//
aAdd( aSX2, { ;
	'ZZI'																	, ; //X2_CHAVE
	cPath																	, ; //X2_PATH
	'ZZI'+cEmpr																, ; //X2_ARQUIVO
	'Mensagens e-mail DIPROMED'												, ; //X2_NOME
	'Mensagens e-mail DIPROMED'												, ; //X2_NOMESPA
	'Mensagens e-mail DIPROMED'												, ; //X2_NOMEENG
	0																		, ; //X2_DELET
	'C'																		, ; //X2_MODO
	''																		, ; //X2_TTS
	''																		, ; //X2_ROTINA
	'N'																		, ; //X2_PYME
	''																		, ; //X2_UNICO
	0																		} ) //X2_MODULO

//
// Tabela ZZJ
//
aAdd( aSX2, { ;
	'ZZJ'																	, ; //X2_CHAVE
	cPath																	, ; //X2_PATH
	'ZZJ'+cEmpr																, ; //X2_ARQUIVO
	'Mensagens CIC DIPROMED'												, ; //X2_NOME
	'Mensagens CIC DIPROMED'												, ; //X2_NOMESPA
	'Mensagens CIC DIPROMED'												, ; //X2_NOMEENG
	0																		, ; //X2_DELET
	'C'																		, ; //X2_MODO
	''																		, ; //X2_TTS
	''																		, ; //X2_ROTINA
	'N'																		, ; //X2_PYME
	''																		, ; //X2_UNICO
	0																		} ) //X2_MODULO
                        
//
// Tabela ZZK
//
aAdd( aSX2, { ;
	'ZZK'																	, ; //X2_CHAVE
	cPath																	, ; //X2_PATH
	'ZZK'+cEmpr																, ; //X2_ARQUIVO
	'Valores Aprovados(apr.digital)'										, ; //X2_NOME
	'Valores Aprovados(apr.digital)'										, ; //X2_NOMESPA
	'Valores Aprovados(apr.digital)'										, ; //X2_NOMEENG
	0																		, ; //X2_DELET
	'E'																		, ; //X2_MODO
	''																		, ; //X2_TTS
	''																		, ; //X2_ROTINA
	'N'																		, ; //X2_PYME
	''																		, ; //X2_UNICO
	0																		} ) //X2_MODULO


//
// Tabela ZZL
//
aAdd( aSX2, { ;
	'ZZL'																	, ; //X2_CHAVE
	cPath																	, ; //X2_PATH
	'ZZL'+cEmpr																, ; //X2_ARQUIVO
	'E-mail e Cic do SAC por Depart'										, ; //X2_NOME
	'E-mail e Cic do SAC por Depart'										, ; //X2_NOMESPA
	'E-mail e Cic do SAC por Depart'										, ; //X2_NOMEENG
	0																		, ; //X2_DELET
	'C'																		, ; //X2_MODO
	''																		, ; //X2_TTS
	''																		, ; //X2_ROTINA
	'N'																		, ; //X2_PYME
	''																		, ; //X2_UNICO
	0																		} ) //X2_MODULO



//
// Tabela ZZN
//
aAdd( aSX2, { ;
	'ZZN'																	, ; //X2_CHAVE
	cPath																	, ; //X2_PATH
	'ZZN'+cEmpr																, ; //X2_ARQUIVO
	'RESP. POR GERAR A OCOR. DO SAC'										, ; //X2_NOME
	'RESP. POR GERAR A OCOR. DO SAC'										, ; //X2_NOMESPA
	'RESP. POR GERAR A OCOR. DO SAC'										, ; //X2_NOMEENG
	0																		, ; //X2_DELET
	'C'																		, ; //X2_MODO
	''																		, ; //X2_TTS
	''																		, ; //X2_ROTINA
	'N'																		, ; //X2_PYME
	''																		, ; //X2_UNICO
	0																		} ) //X2_MODULO


aAdd( aSX2, { ;
	'ZZM'																	, ; //X2_CHAVE
	cPath																	, ; //X2_PATH
	'ZZM'+cEmpr																, ; //X2_ARQUIVO
	'Custo de Importacao'													, ; //X2_NOME
	'Custo de Importacao'													, ; //X2_NOMESPA
	'Custo de Importacao'													, ; //X2_NOMEENG
	0																		, ; //X2_DELET
	'E'																		, ; //X2_MODO
	''																		, ; //X2_TTS
	''																		, ; //X2_ROTINA
	'N'																		, ; //X2_PYME
	''																		, ; //X2_UNICO
	0																		} ) //X2_MODULO
                       
                       
//
// Tabela ZZP
//
aAdd( aSX2, { ;
	'ZZP'																	, ; //X2_CHAVE
	cPath																	, ; //X2_PATH
	'ZZP'+cEmpr																, ; //X2_ARQUIVO
	'INVENTARIO CONTAGENS'													, ; //X2_NOME
	'INVENTARIO CONTAGENS'													, ; //X2_NOMESPA
	'INVENTARIO CONTAGENS'													, ; //X2_NOMEENG
	0																		, ; //X2_DELET
	'C'																		, ; //X2_MODO
	''																		, ; //X2_TTS
	''																		, ; //X2_ROTINA
	'N'																		, ; //X2_PYME
	''																		, ; //X2_UNICO
	0																		} ) //X2_MODULO

//
// Tabela ZZQ
//
aAdd( aSX2, { ;
	'ZZQ'																	, ; //X2_CHAVE
	cPath																	, ; //X2_PATH
	'ZZQ'+cEmpr																, ; //X2_ARQUIVO
	'INVENTARIO CABECALHO'													, ; //X2_NOME
	'INVENTARIO CABECALHO'													, ; //X2_NOMESPA
	'INVENTARIO CABECALHO'													, ; //X2_NOMEENG
	0																		, ; //X2_DELET
	'C'																		, ; //X2_MODO
	''																		, ; //X2_TTS
	''																		, ; //X2_ROTINA
	'N'																		, ; //X2_PYME
	''																		, ; //X2_UNICO
	0																		} ) //X2_MODULO
                       

//
// Tabela ZZR
//
aAdd( aSX2, { ;
	'ZZR'																	, ; //X2_CHAVE
	cPath																	, ; //X2_PATH
	'ZZR'+cEmpr																, ; //X2_ARQUIVO
	'TABELA DE PRECOS x CLIENTES'											, ; //X2_NOME
	'TABELA DE PRECOS x CLIENTES'											, ; //X2_NOMESPA
	'TABELA DE PRECOS x CLIENTES'											, ; //X2_NOMEENG
	0																		, ; //X2_DELET
	'C'																		, ; //X2_MODO
	''																		, ; //X2_TTS
	''																		, ; //X2_ROTINA
	'N'																		, ; //X2_PYME
	''																		, ; //X2_UNICO
	0																		} ) //X2_MODULO


//
// Tabela ZZO
//
aAdd( aSX2, { ;
	'ZZO'																	, ; //X2_CHAVE
	cPath																	, ; //X2_PATH
	'ZZO'+cEmpr																, ; //X2_ARQUIVO
	'Historico de vendas perdidas'											, ; //X2_NOME
	'Historico de vendas perdidas'											, ; //X2_NOMESPA
	'Historico de vendas perdidas'											, ; //X2_NOMEENG
	0																		, ; //X2_DELET
	'E'																		, ; //X2_MODO
	''																		, ; //X2_TTS
	''																		, ; //X2_ROTINA
	'N'																		, ; //X2_PYME
	''																		, ; //X2_UNICO
	0																		} ) //X2_MODULO


//
// Tabela ZZS
//
aAdd( aSX2, { ;
	'ZZS'																	, ; //X2_CHAVE
	cPath																	, ; //X2_PATH
	'ZZS'+cEmpr																, ; //X2_ARQUIVO
	'DIFICIL ACESSO BRASPRESS'												, ; //X2_NOME
	'DIFICIL ACESSO BRASPRESS'												, ; //X2_NOMESPA
	'DIFICIL ACESSO BRASPRESS'												, ; //X2_NOMEENG
	0																		, ; //X2_DELET
	'C'																		, ; //X2_MODO
	''																		, ; //X2_TTS
	''																		, ; //X2_ROTINA
	'N'																		, ; //X2_PYME
	''																		, ; //X2_UNICO
	0																		} ) //X2_MODULO
	
//
// Tabela ZZT
//
aAdd( aSX2, { ;
	'ZZT'																	, ; //X2_CHAVE
	cPath																	, ; //X2_PATH
	'ZZT'+cEmpr																, ; //X2_ARQUIVO
	'HISTORICO RESERVA DE PEDIDOS'											, ; //X2_NOME
	'HISTORICO RESERVA DE PEDIDOS'											, ; //X2_NOMESPA
	'HISTORICO RESERVA DE PEDIDOS'											, ; //X2_NOMEENG
	0																		, ; //X2_DELET
	'E'																		, ; //X2_MODO
	''																		, ; //X2_TTS
	''																		, ; //X2_ROTINA
	'N'																		, ; //X2_PYME
	''																		, ; //X2_UNICO
	0																		} ) //X2_MODULO
	      	                                                                                 
//
// Tabela ZZU
//
aAdd( aSX2, { ;
	'ZZU'																	, ; //X2_CHAVE
	cPath																	, ; //X2_PATH
	'ZZU'+cEmpr																, ; //X2_ARQUIVO
	'TRANSFERIDOS A ENDERECAR'												, ; //X2_NOME
	'TRANSFERIDOS A ENDERECAR'												, ; //X2_NOMESPA
	'TRANSFERIDOS A ENDERECAR'												, ; //X2_NOMEENG
	0																		, ; //X2_DELET
	'E'																		, ; //X2_MODO
	''																		, ; //X2_TTS
	''																		, ; //X2_ROTINA
	'S'																		, ; //X2_PYME
	''																		, ; //X2_UNICO
	0																		} ) //X2_MODULO
		      	
//
// Tabela ZZV
//
aAdd( aSX2, { ;
	'ZZV'																	, ; //X2_CHAVE
	cPath																	, ; //X2_PATH
	'ZZV'+cEmpr																, ; //X2_ARQUIVO
	'CEP TRT TRANSPORTE'													, ; //X2_NOME
	'CEP TRT TRANSPORTE'													, ; //X2_NOMESPA
	'CEP TRT TRANSPORTE'													, ; //X2_NOMEENG
	0																		, ; //X2_DELET
	'C'																		, ; //X2_MODO
	''																		, ; //X2_TTS
	''																		, ; //X2_ROTINA
	''																		, ; //X2_PYME
	''																		, ; //X2_UNICO
	0																		} ) //X2_MODULO
                                                                                           
//
// Tabela ZZW
//

aAdd( aSX2, { ;
	'ZZW'																	, ; //X2_CHAVE
	cPath																	, ; //X2_PATH
	'ZZW'+cEmpr																, ; //X2_ARQUIVO
	'KARDEX DO PEDIDO DE COMPRAS'											, ; //X2_NOME
	'KARDEX DO PEDIDO DE COMPRAS'											, ; //X2_NOMESPA
	'KARDEX DO PEDIDO DE COMPRAS'											, ; //X2_NOMEENG
	0																		, ; //X2_DELET
	'E'																		, ; //X2_MODO
	''																		, ; //X2_TTS
	''																		, ; //X2_ROTINA
	''																		, ; //X2_PYME
	''																		, ; //X2_UNICO
	0																		} ) //X2_MODULO

//
// Tabela ZZX
//
aAdd( aSX2, { ;
	'ZZX'																	, ; //X2_CHAVE
	cPath																	, ; //X2_PATH
	'ZZX'+cEmpr																, ; //X2_ARQUIVO
	'Tabela de clientes para CAT116'										, ; //X2_NOME
	'Tabela de clientes para CAT116'										, ; //X2_NOMESPA
	'Tabela de clientes para CAT116'										, ; //X2_NOMEENG
	0																		, ; //X2_DELET
	'C'																		, ; //X2_MODO
	''																		, ; //X2_TTS
	''																		, ; //X2_ROTINA
	'N'																		, ; //X2_PYME
	''																		, ; //X2_UNICO
	0																		} ) //X2_MODULO


//
// Atualizando dicion·rio
//
oProcess:SetRegua2( Len( aSX2 ) )

dbSelectArea( "SX2" )
dbSetOrder( 1 )

For nI := 1 To Len( aSX2 )

	oProcess:IncRegua2( "Atualizando Arquivos (SX2)..." )

	If !SX2->( dbSeek( aSX2[nI][1] ) )

		If !( aSX2[nI][1] $ cAlias )
			cAlias += aSX2[nI][1] + "/"
			cTexto += "Foi incluÌda a tabela " + aSX2[nI][1] + CRLF
		EndIf

		RecLock( "SX2", .T. )
		For nJ := 1 To Len( aSX2[nI] )
			If FieldPos( aEstrut[nJ] ) > 0
				If AllTrim( aEstrut[nJ] ) == "X2_ARQUIVO"
					FieldPut( FieldPos( aEstrut[nJ] ), SubStr( aSX2[nI][nJ], 1, 3 ) + cEmpAnt +  "0" )
				Else
					FieldPut( FieldPos( aEstrut[nJ] ), aSX2[nI][nJ] )
				EndIf
			EndIf
		Next nJ
		dbCommit()
		MsUnLock()

	Else

		If  !( StrTran( Upper( AllTrim( SX2->X2_UNICO ) ), " ", "" ) == StrTran( Upper( AllTrim( aSX2[nI][12]  ) ), " ", "" ) )
			If MSFILE( RetSqlName( aSX2[nI][1] ),RetSqlName( aSX2[nI][1] ) + "_UNQ"  )
				TcInternal( 60, RetSqlName( aSX2[nI][1] ) + "|" + RetSqlName( aSX2[nI][1] ) + "_UNQ" )
				cTexto += "Foi alterada chave unica da tabela " + aSX2[nI][1] + CRLF
			Else
				cTexto += "Foi criada   chave unica da tabela " + aSX2[nI][1] + CRLF
			EndIf
		EndIf

	EndIf

Next nI

cTexto += CRLF + "Final da Atualizacao" + " SX2" + CRLF + Replicate( "-", 128 ) + CRLF + CRLF

Return NIL
/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫ Programa ≥ FSAtuSX3 ∫ Autor ≥ TOTVS Protheus     ∫ Data ≥  13/07/12   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫ Descricao≥ Funcao de processamento da gravacao do SX3 - Campos        ≥±±
±±∫          ≥                                                            ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±≥ Uso      ≥ FSAtuSX3   - Gerado por EXPORDIC / Upd. V.4.10.4 EFS       ≥±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Static Function FSAtuSX3( cTexto )
Local aEstrut   := {}
Local aSX3      := {}
Local cAlias    := ""
Local cAliasAtu := ""
Local cMsg      := ""
Local cSeqAtu   := ""
Local lTodosNao := .F.
Local lTodosSim := .T.
Local nI        := 0
Local nJ        := 0
Local nOpcA     := 1
Local nPosArq   := 0
Local nPosCpo   := 0
Local nPosOrd   := 0
Local nPosSXG   := 0
Local nPosTam   := 0
Local nSeqAtu   := 0
Local cOrdem	:= 0
Local nTamSeek  := Len( SX3->X3_CAMPO )

DbSelectArea("SX3") 

cTexto  += "Inicio da Atualizacao" + " SX3" + CRLF + CRLF

aEstrut := { "X3_ARQUIVO", "X3_ORDEM"  , "X3_CAMPO"  , "X3_TIPO"   , "X3_TAMANHO", "X3_DECIMAL", ;
             "X3_TITULO" , "X3_TITSPA" , "X3_TITENG" , "X3_DESCRIC", "X3_DESCSPA", "X3_DESCENG", ;
             "X3_PICTURE", "X3_VALID"  , "X3_USADO"  , "X3_RELACAO", "X3_F3"     , "X3_NIVEL"  , ;
             "X3_RESERV" , "X3_CHECK"  , "X3_TRIGGER", "X3_PROPRI" , "X3_BROWSE" , "X3_VISUAL" , ;
             "X3_CONTEXT", "X3_OBRIGAT", "X3_VLDUSER", "X3_CBOX"   , "X3_CBOXSPA", "X3_CBOXENG", ;
             "X3_PICTVAR", "X3_WHEN"   , "X3_INIBRW" , "X3_GRPSXG" , "X3_FOLDER" , "X3_PYME"   }


 
/*..TABELA..SA1 / SUC/ SG1*/ 
If cEmpAnt == '04'
	SX3->(DbSetOrder(2))
	If SX3->(dbSeek("G1_QUANT"))
		
		aAdd( aSX3, { ;
		'SG1'																	, ; //X3_ARQUIVO
		SX3->X3_ORDEM															, ; //X3_ORDEM
		SX3->X3_CAMPO  															, ; //X3_CAMPO
		SX3->X3_TIPO															, ; //X3_TIPO
		SX3->X3_TAMANHO															, ; //X3_TAMANHO
		SX3->X3_DECIMAL															, ; //X3_DECIMAL
		SX3->X3_TITULO															, ; //X3_TITULO
		SX3->X3_TITSPA															, ; //X3_TITSPA
		SX3->X3_TITENG															, ; //X3_TITENG
		SX3->X3_DESCRIC															, ; //X3_DESCRIC
		SX3->X3_DESCSPA															, ; //X3_DESCSPA
		SX3->X3_DESCENG															, ; //X3_DESCENG
		SX3->X3_PICTURE															, ; //X3_PICTURE
		SX3->X3_VALID															, ; //X3_VALID
		SX3->X3_USADO															, ; //X3_USADO
		SX3->X3_RELACAO 														, ; //X3_RELACAO
		SX3->X3_F3																, ; //X3_F3
		SX3->X3_NIVEL															, ; //X3_NIVEL
		SX3->X3_RESERV															, ; //X3_RESERV
		SX3->X3_CHECK															, ; //X3_CHECK
		SX3->X3_TRIGGER															, ; //X3_TRIGGER
		SX3->X3_PROPRI															, ; //X3_PROPRI
		SX3->X3_BROWSE															, ; //X3_BROWSE
		SX3->X3_VISUAL															, ; //X3_VISUAL
		SX3->X3_CONTEXT															, ; //X3_CONTEXT
		SX3->X3_OBRIGAT    														, ; //X3_OBRIGAT
		SX3->X3_VLDUSER                                                         , ; //X3_VLDUSER
		SX3->X3_CBOX															, ; //X3_CBOX
		SX3->X3_CBOXSPA															, ; //X3_CBOXSPA
		SX3->X3_CBOXENG															, ; //X3_CBOXENG
		SX3->X3_PICTVAR															, ; //X3_PICTVAR
		'.F.'																	, ; //X3_WHEN
		SX3->X3_INIBRW															, ; //X3_INIBRW
		SX3->X3_GRPSXG															, ; //X3_GRPSXG
		SX3->X3_FOLDER	  														, ; //X3_FOLDER
		SX3->X3_PYME															} ) //X3_PYME
	EndIf

	SX3->(DbSetOrder(2))
	If SX3->(dbSeek("A1_BOLETHQ"))
		
		aAdd( aSX3, { ;
		'SA1'																	, ; //X3_ARQUIVO
		SX3->X3_ORDEM															, ; //X3_ORDEM
		'A1_BOLETHQ'   															, ; //X3_CAMPO
		SX3->X3_TIPO															, ; //X3_TIPO
		SX3->X3_TAMANHO															, ; //X3_TAMANHO
		SX3->X3_DECIMAL															, ; //X3_DECIMAL
		SX3->X3_TITULO															, ; //X3_TITULO
		SX3->X3_TITSPA															, ; //X3_TITSPA
		SX3->X3_TITENG															, ; //X3_TITENG
		SX3->X3_DESCRIC															, ; //X3_DESCRIC
		SX3->X3_DESCSPA															, ; //X3_DESCSPA
		SX3->X3_DESCENG															, ; //X3_DESCENG
		SX3->X3_PICTURE															, ; //X3_PICTURE
		SX3->X3_VALID															, ; //X3_VALID
		SX3->X3_USADO															, ; //X3_USADO
		SX3->X3_RELACAO 														, ; //X3_RELACAO
		SX3->X3_F3																, ; //X3_F3
		0																		, ; //X3_NIVEL
		SX3->X3_RESERV															, ; //X3_RESERV
		SX3->X3_CHECK															, ; //X3_CHECK
		SX3->X3_TRIGGER															, ; //X3_TRIGGER
		SX3->X3_PROPRI															, ; //X3_PROPRI
		SX3->X3_BROWSE															, ; //X3_BROWSE
		SX3->X3_VISUAL															, ; //X3_VISUAL
		SX3->X3_CONTEXT															, ; //X3_CONTEXT
		SX3->X3_OBRIGAT    														, ; //X3_OBRIGAT
		SX3->X3_VLDUSER                                                         , ; //X3_VLDUSER
		SX3->X3_CBOX															, ; //X3_CBOX
		SX3->X3_CBOXSPA															, ; //X3_CBOXSPA
		SX3->X3_CBOXENG															, ; //X3_CBOXENG
		SX3->X3_PICTVAR															, ; //X3_PICTVAR
		SX3->X3_WHEN															, ; //X3_WHEN
		SX3->X3_INIBRW															, ; //X3_INIBRW
		SX3->X3_GRPSXG															, ; //X3_GRPSXG
		'2'				  														, ; //X3_FOLDER
		SX3->X3_PYME															} ) //X3_PYME
	EndIf

	SX3->(DbSetOrder(2))
	If SX3->(dbSeek("A1_BLTAUTO"))
		
		aAdd( aSX3, { ;
		'SA1'																	, ; //X3_ARQUIVO
		SX3->X3_ORDEM															, ; //X3_ORDEM
		'A1_BLTAUTO'   															, ; //X3_CAMPO
		SX3->X3_TIPO															, ; //X3_TIPO
		SX3->X3_TAMANHO															, ; //X3_TAMANHO
		SX3->X3_DECIMAL															, ; //X3_DECIMAL
		SX3->X3_TITULO															, ; //X3_TITULO
		SX3->X3_TITSPA															, ; //X3_TITSPA
		SX3->X3_TITENG															, ; //X3_TITENG
		SX3->X3_DESCRIC															, ; //X3_DESCRIC
		SX3->X3_DESCSPA															, ; //X3_DESCSPA
		SX3->X3_DESCENG															, ; //X3_DESCENG
		SX3->X3_PICTURE															, ; //X3_PICTURE
		SX3->X3_VALID															, ; //X3_VALID
		SX3->X3_USADO															, ; //X3_USADO
		SX3->X3_RELACAO 														, ; //X3_RELACAO
		SX3->X3_F3																, ; //X3_F3
		9																		, ; //X3_NIVEL
		SX3->X3_RESERV															, ; //X3_RESERV
		SX3->X3_CHECK															, ; //X3_CHECK
		SX3->X3_TRIGGER															, ; //X3_TRIGGER
		SX3->X3_PROPRI															, ; //X3_PROPRI
		SX3->X3_BROWSE															, ; //X3_BROWSE
		SX3->X3_VISUAL															, ; //X3_VISUAL
		SX3->X3_CONTEXT															, ; //X3_CONTEXT
		SX3->X3_OBRIGAT    														, ; //X3_OBRIGAT
		SX3->X3_VLDUSER                                                         , ; //X3_VLDUSER
		SX3->X3_CBOX															, ; //X3_CBOX
		SX3->X3_CBOXSPA															, ; //X3_CBOXSPA
		SX3->X3_CBOXENG															, ; //X3_CBOXENG
		SX3->X3_PICTVAR															, ; //X3_PICTVAR
		SX3->X3_WHEN															, ; //X3_WHEN
		SX3->X3_INIBRW															, ; //X3_INIBRW
		SX3->X3_GRPSXG															, ; //X3_GRPSXG
	    '2'				  														, ; //X3_FOLDER
		SX3->X3_PYME															} ) //X3_PYME
	EndIf
	
	SX3->(DbSetOrder(2))
	If SX3->(dbSeek("C6_PEDCLI"))
		
		aAdd( aSX3, { ;
		'SC6'																	, ; //X3_ARQUIVO
		SX3->X3_ORDEM															, ; //X3_ORDEM
		'C6_PEDCLI'   															, ; //X3_CAMPO
		SX3->X3_TIPO															, ; //X3_TIPO
		SX3->X3_TAMANHO															, ; //X3_TAMANHO
		SX3->X3_DECIMAL															, ; //X3_DECIMAL
		SX3->X3_TITULO															, ; //X3_TITULO
		SX3->X3_TITSPA															, ; //X3_TITSPA
		SX3->X3_TITENG															, ; //X3_TITENG
		SX3->X3_DESCRIC															, ; //X3_DESCRIC
		SX3->X3_DESCSPA															, ; //X3_DESCSPA
		SX3->X3_DESCENG															, ; //X3_DESCENG
		SX3->X3_PICTURE															, ; //X3_PICTURE
		SX3->X3_VALID															, ; //X3_VALID
		SX3->X3_USADO															, ; //X3_USADO
		SX3->X3_RELACAO 														, ; //X3_RELACAO
		SX3->X3_F3																, ; //X3_F3
		SX3->X3_NIVEL   														, ; //X3_NIVEL
		SX3->X3_RESERV															, ; //X3_RESERV
		SX3->X3_CHECK															, ; //X3_CHECK
		SX3->X3_TRIGGER															, ; //X3_TRIGGER
		SX3->X3_PROPRI															, ; //X3_PROPRI
		SX3->X3_BROWSE															, ; //X3_BROWSE
		SX3->X3_VISUAL															, ; //X3_VISUAL
		SX3->X3_CONTEXT															, ; //X3_CONTEXT
		SX3->X3_OBRIGAT    														, ; //X3_OBRIGAT
		'U_C6PEDCLI(M->C6_PEDCLI,M->C5_CLIENTE,M->C5_LOJACLI,GDFIELDGET("C6_PRODUTO"))', ; //X3_VLDUSER
		SX3->X3_CBOX															, ; //X3_CBOX
		SX3->X3_CBOXSPA															, ; //X3_CBOXSPA
		SX3->X3_CBOXENG															, ; //X3_CBOXENG
		SX3->X3_PICTVAR															, ; //X3_PICTVAR
		SX3->X3_WHEN															, ; //X3_WHEN
		SX3->X3_INIBRW															, ; //X3_INIBRW
		SX3->X3_GRPSXG															, ; //X3_GRPSXG
		SX3->X3_FOLDER  														, ; //X3_FOLDER
		SX3->X3_PYME															} ) //X3_PYME
	EndIf	
	
EndIf

If cEmpAnt == '01'
	SX3->(DbSetOrder(2))
	If SX3->(dbSeek("A1_BOLETHQ"))
		
		aAdd( aSX3, { ;
		'SA1'																	, ; //X3_ARQUIVO
		SX3->X3_ORDEM															, ; //X3_ORDEM
		'A1_BOLETHQ'   															, ; //X3_CAMPO
		SX3->X3_TIPO															, ; //X3_TIPO
		SX3->X3_TAMANHO															, ; //X3_TAMANHO
		SX3->X3_DECIMAL															, ; //X3_DECIMAL
		SX3->X3_TITULO															, ; //X3_TITULO
		SX3->X3_TITSPA															, ; //X3_TITSPA
		SX3->X3_TITENG															, ; //X3_TITENG
		SX3->X3_DESCRIC															, ; //X3_DESCRIC
		SX3->X3_DESCSPA															, ; //X3_DESCSPA
		SX3->X3_DESCENG															, ; //X3_DESCENG
		SX3->X3_PICTURE															, ; //X3_PICTURE
		SX3->X3_VALID															, ; //X3_VALID
		SX3->X3_USADO															, ; //X3_USADO
		SX3->X3_RELACAO 														, ; //X3_RELACAO
		SX3->X3_F3																, ; //X3_F3
		9																		, ; //X3_NIVEL
		SX3->X3_RESERV															, ; //X3_RESERV
		SX3->X3_CHECK															, ; //X3_CHECK
		SX3->X3_TRIGGER															, ; //X3_TRIGGER
		SX3->X3_PROPRI															, ; //X3_PROPRI
		SX3->X3_BROWSE															, ; //X3_BROWSE
		SX3->X3_VISUAL															, ; //X3_VISUAL
		SX3->X3_CONTEXT															, ; //X3_CONTEXT
		SX3->X3_OBRIGAT    														, ; //X3_OBRIGAT
		SX3->X3_VLDUSER                                                         , ; //X3_VLDUSER
		SX3->X3_CBOX															, ; //X3_CBOX
		SX3->X3_CBOXSPA															, ; //X3_CBOXSPA
		SX3->X3_CBOXENG															, ; //X3_CBOXENG
		SX3->X3_PICTVAR															, ; //X3_PICTVAR
		SX3->X3_WHEN															, ; //X3_WHEN
		SX3->X3_INIBRW															, ; //X3_INIBRW
		SX3->X3_GRPSXG															, ; //X3_GRPSXG
		'2'				  														, ; //X3_FOLDER
		SX3->X3_PYME															} ) //X3_PYME
	EndIf

	SX3->(DbSetOrder(2))
	If SX3->(dbSeek("A1_BLTAUTO"))
		
		aAdd( aSX3, { ;
		'SA1'																	, ; //X3_ARQUIVO
		SX3->X3_ORDEM															, ; //X3_ORDEM
		'A1_BLTAUTO'   															, ; //X3_CAMPO
		SX3->X3_TIPO															, ; //X3_TIPO
		SX3->X3_TAMANHO															, ; //X3_TAMANHO
		SX3->X3_DECIMAL															, ; //X3_DECIMAL
		SX3->X3_TITULO															, ; //X3_TITULO
		SX3->X3_TITSPA															, ; //X3_TITSPA
		SX3->X3_TITENG															, ; //X3_TITENG
		SX3->X3_DESCRIC															, ; //X3_DESCRIC
		SX3->X3_DESCSPA															, ; //X3_DESCSPA
		SX3->X3_DESCENG															, ; //X3_DESCENG
		SX3->X3_PICTURE															, ; //X3_PICTURE
		SX3->X3_VALID															, ; //X3_VALID
		SX3->X3_USADO															, ; //X3_USADO
		SX3->X3_RELACAO 														, ; //X3_RELACAO
		SX3->X3_F3																, ; //X3_F3
		0																		, ; //X3_NIVEL
		SX3->X3_RESERV															, ; //X3_RESERV
		SX3->X3_CHECK															, ; //X3_CHECK
		SX3->X3_TRIGGER															, ; //X3_TRIGGER
		SX3->X3_PROPRI															, ; //X3_PROPRI
		SX3->X3_BROWSE															, ; //X3_BROWSE
		SX3->X3_VISUAL															, ; //X3_VISUAL
		SX3->X3_CONTEXT															, ; //X3_CONTEXT
		SX3->X3_OBRIGAT    														, ; //X3_OBRIGAT
		SX3->X3_VLDUSER                                                         , ; //X3_VLDUSER
		SX3->X3_CBOX															, ; //X3_CBOX
		SX3->X3_CBOXSPA															, ; //X3_CBOXSPA
		SX3->X3_CBOXENG															, ; //X3_CBOXENG
		SX3->X3_PICTVAR															, ; //X3_PICTVAR
		SX3->X3_WHEN															, ; //X3_WHEN
		SX3->X3_INIBRW															, ; //X3_INIBRW
		SX3->X3_GRPSXG															, ; //X3_GRPSXG
	    '2'				  														, ; //X3_FOLDER
		SX3->X3_PYME															} ) //X3_PYME
	EndIf
	
	SX3->(DbSetOrder(2))
	If SX3->(dbSeek("A1_CONTA"))
		aAdd( aSX3, { ;
		'SA1'																	, ; //X3_ARQUIVO
		SX3->X3_ORDEM															, ; //X3_ORDEM
		'A1_CONTA'   															, ; //X3_CAMPO
		SX3->X3_TIPO															, ; //X3_TIPO
		SX3->X3_TAMANHO															, ; //X3_TAMANHO
		SX3->X3_DECIMAL															, ; //X3_DECIMAL
		SX3->X3_TITULO															, ; //X3_TITULO
		SX3->X3_TITSPA															, ; //X3_TITSPA
		SX3->X3_TITENG															, ; //X3_TITENG
		SX3->X3_DESCRIC															, ; //X3_DESCRIC
		SX3->X3_DESCSPA															, ; //X3_DESCSPA
		SX3->X3_DESCENG															, ; //X3_DESCENG
		SX3->X3_PICTURE															, ; //X3_PICTURE
		SX3->X3_VALID															, ; //X3_VALID
		SX3->X3_USADO															, ; //X3_USADO
		'"112101001"'	 														, ; //X3_RELACAO
		SX3->X3_F3																, ; //X3_F3
		SX3->X3_NIVEL															, ; //X3_NIVEL
		SX3->X3_RESERV															, ; //X3_RESERV
		SX3->X3_CHECK															, ; //X3_CHECK
		SX3->X3_TRIGGER															, ; //X3_TRIGGER
		SX3->X3_PROPRI															, ; //X3_PROPRI
		SX3->X3_BROWSE															, ; //X3_BROWSE
		SX3->X3_VISUAL															, ; //X3_VISUAL
		SX3->X3_CONTEXT															, ; //X3_CONTEXT
		SX3->X3_OBRIGAT    														, ; //X3_OBRIGAT
		SX3->X3_VLDUSER                                                         , ; //X3_VLDUSER
		SX3->X3_CBOX															, ; //X3_CBOX
		SX3->X3_CBOXSPA															, ; //X3_CBOXSPA
		SX3->X3_CBOXENG															, ; //X3_CBOXENG
		SX3->X3_PICTVAR															, ; //X3_PICTVAR
		SX3->X3_WHEN															, ; //X3_WHEN
		SX3->X3_INIBRW															, ; //X3_INIBRW
		SX3->X3_GRPSXG															, ; //X3_GRPSXG
		SX3->X3_FOLDER  														, ; //X3_FOLDER
		SX3->X3_PYME															} ) //X3_PYME
	EndIf
	
	SX3->(DbSetOrder(2))
	If SX3->(dbSeek("B1_PRVSUPE"))
		aAdd( aSX3, { ;
		'SB1'																	, ; //X3_ARQUIVO
		SX3->X3_ORDEM															, ; //X3_ORDEM
		'B1_PRVSUPE'   															, ; //X3_CAMPO
		SX3->X3_TIPO															, ; //X3_TIPO
		SX3->X3_TAMANHO															, ; //X3_TAMANHO
		SX3->X3_DECIMAL															, ; //X3_DECIMAL
		SX3->X3_TITULO															, ; //X3_TITULO
		SX3->X3_TITSPA															, ; //X3_TITSPA
		SX3->X3_TITENG															, ; //X3_TITENG
		SX3->X3_DESCRIC															, ; //X3_DESCRIC
		SX3->X3_DESCSPA															, ; //X3_DESCSPA
		SX3->X3_DESCENG															, ; //X3_DESCENG
		SX3->X3_PICTURE															, ; //X3_PICTURE
		SX3->X3_VALID															, ; //X3_VALID
		SX3->X3_USADO															, ; //X3_USADO
		SX3->X3_RELACAO 														, ; //X3_RELACAO
		SX3->X3_F3																, ; //X3_F3
		SX3->X3_NIVEL															, ; //X3_NIVEL
		SX3->X3_RESERV															, ; //X3_RESERV
		SX3->X3_CHECK															, ; //X3_CHECK
		SX3->X3_TRIGGER															, ; //X3_TRIGGER
		SX3->X3_PROPRI															, ; //X3_PROPRI
		SX3->X3_BROWSE															, ; //X3_BROWSE
		SX3->X3_VISUAL															, ; //X3_VISUAL
		SX3->X3_CONTEXT															, ; //X3_CONTEXT
		SX3->X3_OBRIGAT    														, ; //X3_OBRIGAT
		"Iif(Inclui,.T.,M->B1_PRVSUPE<=M->B1_PRVMINI)"	                        , ; //X3_VLDUSER
		SX3->X3_CBOX															, ; //X3_CBOX
		SX3->X3_CBOXSPA															, ; //X3_CBOXSPA
		SX3->X3_CBOXENG															, ; //X3_CBOXENG
		SX3->X3_PICTVAR															, ; //X3_PICTVAR
		SX3->X3_WHEN															, ; //X3_WHEN
		SX3->X3_INIBRW															, ; //X3_INIBRW
		SX3->X3_GRPSXG															, ; //X3_GRPSXG
		SX3->X3_FOLDER	  														, ; //X3_FOLDER
		SX3->X3_PYME															} ) //X3_PYME
	EndIf	
           	  
	SX3->(DbSetOrder(2))
	If SX3->(dbSeek("B1_XVENREG"))

   		aAdd( aSX3, { ;
		'SB1'																	, ; //X3_ARQUIVO
		SX3->X3_ORDEM															, ; //X3_ORDEM
		'B1_XVENREG'    														, ; //X3_CAMPO
		SX3->X3_TIPO															, ; //X3_TIPO
		SX3->X3_TAMANHO	             											, ; //X3_TAMANHO
		SX3->X3_DECIMAL															, ; //X3_DECIMAL
		SX3->X3_TITULO															, ; //X3_TITULO
		SX3->X3_TITSPA															, ; //X3_TITSPA
		SX3->X3_TITENG															, ; //X3_TITENG
		SX3->X3_DESCRIC															, ; //X3_DESCRIC
		SX3->X3_DESCSPA															, ; //X3_DESCSPA
		SX3->X3_DESCENG															, ; //X3_DESCENG
		SX3->X3_PICTURE															, ; //X3_PICTURE
		SX3->X3_VALID															, ; //X3_VALID
		SX3->X3_USADO															, ; //X3_USADO
		SX3->X3_RELACAO 														, ; //X3_RELACAO
		SX3->X3_F3																, ; //X3_F3
		SX3->X3_NIVEL															, ; //X3_NIVEL
		SX3->X3_RESERV															, ; //X3_RESERV
		SX3->X3_CHECK															, ; //X3_CHECK
		SX3->X3_TRIGGER															, ; //X3_TRIGGER
		SX3->X3_PROPRI															, ; //X3_PROPRI
		SX3->X3_BROWSE															, ; //X3_BROWSE
		SX3->X3_VISUAL															, ; //X3_VISUAL
		SX3->X3_CONTEXT															, ; //X3_CONTEXT
		SX3->X3_OBRIGAT															, ; //X3_OBRIGAT
		SX3->X3_VLDUSER															, ; //X3_VLDUSER
		SX3->X3_CBOX															, ; //X3_CBOX
		SX3->X3_CBOXSPA															, ; //X3_CBOXSPA
		SX3->X3_CBOXENG															, ; //X3_CBOXENG
		SX3->X3_PICTVAR											   				, ; //X3_PICTVAR
		'U_xTRAVSB() .AND. U_XVENREG(M->B1_RANVISA,M->B1_CANVISA)'				, ; //X3_WHEN
		SX3->X3_INIBRW															, ; //X3_INIBRW
		SX3->X3_GRPSXG															, ; //X3_GRPSXG
		SX3->X3_FOLDER  														, ; //X3_FOLDER
		SX3->X3_PYME															} ) //X3_PYME	
	EndIf         

	SX3->(DbSetOrder(2))
	If SX3->(dbSeek("DB_QUANT"))
		aAdd( aSX3, { ;
		'SDB'																	, ; //X3_ARQUIVO
		SX3->X3_ORDEM															, ; //X3_ORDEM
		'DB_QUANT'   															, ; //X3_CAMPO
		SX3->X3_TIPO															, ; //X3_TIPO
		SX3->X3_TAMANHO															, ; //X3_TAMANHO
		SX3->X3_DECIMAL															, ; //X3_DECIMAL
		SX3->X3_TITULO															, ; //X3_TITULO
		SX3->X3_TITSPA															, ; //X3_TITSPA
		SX3->X3_TITENG															, ; //X3_TITENG
		SX3->X3_DESCRIC															, ; //X3_DESCRIC
		SX3->X3_DESCSPA															, ; //X3_DESCSPA
		SX3->X3_DESCENG															, ; //X3_DESCENG
		SX3->X3_PICTURE															, ; //X3_PICTURE
		SX3->X3_VALID															, ; //X3_VALID
		SX3->X3_USADO															, ; //X3_USADO
		SX3->X3_RELACAO 														, ; //X3_RELACAO
		SX3->X3_F3																, ; //X3_F3
		SX3->X3_NIVEL															, ; //X3_NIVEL
		SX3->X3_RESERV															, ; //X3_RESERV
		SX3->X3_CHECK															, ; //X3_CHECK
		SX3->X3_TRIGGER															, ; //X3_TRIGGER
		SX3->X3_PROPRI															, ; //X3_PROPRI
		SX3->X3_BROWSE															, ; //X3_BROWSE
		SX3->X3_VISUAL															, ; //X3_VISUAL
		SX3->X3_CONTEXT															, ; //X3_CONTEXT
		SX3->X3_OBRIGAT    														, ; //X3_OBRIGAT
		"u_DipVldCx()"                                                          , ; //X3_VLDUSER
		SX3->X3_CBOX															, ; //X3_CBOX
		SX3->X3_CBOXSPA															, ; //X3_CBOXSPA
		SX3->X3_CBOXENG															, ; //X3_CBOXENG
		SX3->X3_PICTVAR															, ; //X3_PICTVAR
		SX3->X3_WHEN															, ; //X3_WHEN
		SX3->X3_INIBRW															, ; //X3_INIBRW
		SX3->X3_GRPSXG															, ; //X3_GRPSXG
		SX3->X3_FOLDER  														, ; //X3_FOLDER
		SX3->X3_PYME															} ) //X3_PYME
	EndIf	
EndIf      

	SX3->(DbSetOrder(2))
	If SX3->(dbSeek("B1_REG_ANV"))

   		aAdd( aSX3, { ;
		'SB1'																	, ; //X3_ARQUIVO
		SX3->X3_ORDEM															, ; //X3_ORDEM
		'B1_REG_ANV'    														, ; //X3_CAMPO
		SX3->X3_TIPO															, ; //X3_TIPO
		17				             											, ; //X3_TAMANHO
		SX3->X3_DECIMAL															, ; //X3_DECIMAL
		SX3->X3_TITULO															, ; //X3_TITULO
		SX3->X3_TITSPA															, ; //X3_TITSPA
		SX3->X3_TITENG															, ; //X3_TITENG
		SX3->X3_DESCRIC															, ; //X3_DESCRIC
		SX3->X3_DESCSPA															, ; //X3_DESCSPA
		SX3->X3_DESCENG															, ; //X3_DESCENG
		SX3->X3_PICTURE															, ; //X3_PICTURE
		SX3->X3_VALID															, ; //X3_VALID
		SX3->X3_USADO															, ; //X3_USADO
		SX3->X3_RELACAO 														, ; //X3_RELACAO
		SX3->X3_F3																, ; //X3_F3
		SX3->X3_NIVEL															, ; //X3_NIVEL
		SX3->X3_RESERV															, ; //X3_RESERV
		SX3->X3_CHECK															, ; //X3_CHECK
		SX3->X3_TRIGGER															, ; //X3_TRIGGER
		SX3->X3_PROPRI															, ; //X3_PROPRI
		SX3->X3_BROWSE															, ; //X3_BROWSE
		SX3->X3_VISUAL															, ; //X3_VISUAL
		SX3->X3_CONTEXT															, ; //X3_CONTEXT
		SX3->X3_OBRIGAT															, ; //X3_OBRIGAT
		SX3->X3_VLDUSER															, ; //X3_VLDUSER
		SX3->X3_CBOX															, ; //X3_CBOX
		SX3->X3_CBOXSPA															, ; //X3_CBOXSPA
		SX3->X3_CBOXENG															, ; //X3_CBOXENG
		SX3->X3_PICTVAR											   				, ; //X3_PICTVAR
		SX3->X3_WHEN															, ; //X3_WHEN
		SX3->X3_INIBRW															, ; //X3_INIBRW
		SX3->X3_GRPSXG															, ; //X3_GRPSXG
		SX3->X3_FOLDER  														, ; //X3_FOLDER
		SX3->X3_PYME															} ) //X3_PYME	
	EndIf

	SX3->(DbSetOrder(2))
	If SX3->(dbSeek("B1_ALIQISS"))
		aAdd( aSX3, { ;
		'SB1'																	, ; //X3_ARQUIVO
		SX3->X3_ORDEM															, ; //X3_ORDEM
		'B1_ALIQISS'   															, ; //X3_CAMPO
		SX3->X3_TIPO															, ; //X3_TIPO
		5																		, ; //X3_TAMANHO
		2																		, ; //X3_DECIMAL
		SX3->X3_TITULO															, ; //X3_TITULO
		SX3->X3_TITSPA															, ; //X3_TITSPA
		SX3->X3_TITENG															, ; //X3_TITENG
		SX3->X3_DESCRIC															, ; //X3_DESCRIC
		SX3->X3_DESCSPA															, ; //X3_DESCSPA
		SX3->X3_DESCENG															, ; //X3_DESCENG
		'@E 99.99'																, ; //X3_PICTURE
		SX3->X3_VALID															, ; //X3_VALID
		SX3->X3_USADO															, ; //X3_USADO
		SX3->X3_RELACAO 														, ; //X3_RELACAO
		SX3->X3_F3																, ; //X3_F3
		SX3->X3_NIVEL															, ; //X3_NIVEL
		SX3->X3_RESERV															, ; //X3_RESERV
		SX3->X3_CHECK															, ; //X3_CHECK
		SX3->X3_TRIGGER															, ; //X3_TRIGGER
		SX3->X3_PROPRI															, ; //X3_PROPRI
		SX3->X3_BROWSE															, ; //X3_BROWSE
		SX3->X3_VISUAL															, ; //X3_VISUAL
		SX3->X3_CONTEXT															, ; //X3_CONTEXT
		SX3->X3_OBRIGAT    														, ; //X3_OBRIGAT
		SX3->X3_VLDUSER									                        , ; //X3_VLDUSER
		SX3->X3_CBOX															, ; //X3_CBOX
		SX3->X3_CBOXSPA															, ; //X3_CBOXSPA
		SX3->X3_CBOXENG															, ; //X3_CBOXENG
		SX3->X3_PICTVAR															, ; //X3_PICTVAR
		SX3->X3_WHEN															, ; //X3_WHEN
		SX3->X3_INIBRW															, ; //X3_INIBRW
		SX3->X3_GRPSXG															, ; //X3_GRPSXG
		SX3->X3_FOLDER	  														, ; //X3_FOLDER
		SX3->X3_PYME															} ) //X3_PYME
	EndIf	

	SX3->(DbSetOrder(2))
	If SX3->(dbSeek("A1_EMAILD"))
		aAdd( aSX3, { ;
		'SA1'																	, ; //X3_ARQUIVO
		SX3->X3_ORDEM															, ; //X3_ORDEM
		'A1_EMAILD'   															, ; //X3_CAMPO
		SX3->X3_TIPO															, ; //X3_TIPO
		100																		, ; //X3_TAMANHO
		SX3->X3_DECIMAL															, ; //X3_DECIMAL
		SX3->X3_TITULO															, ; //X3_TITULO
		SX3->X3_TITSPA															, ; //X3_TITSPA
		SX3->X3_TITENG															, ; //X3_TITENG
		SX3->X3_DESCRIC															, ; //X3_DESCRIC
		SX3->X3_DESCSPA															, ; //X3_DESCSPA
		SX3->X3_DESCENG															, ; //X3_DESCENG
		SX3->X3_PICTURE															, ; //X3_PICTURE
		SX3->X3_VALID															, ; //X3_VALID
		SX3->X3_USADO															, ; //X3_USADO
		SX3->X3_RELACAO	 														, ; //X3_RELACAO
		SX3->X3_F3																, ; //X3_F3
		SX3->X3_NIVEL															, ; //X3_NIVEL
		SX3->X3_RESERV															, ; //X3_RESERV
		SX3->X3_CHECK															, ; //X3_CHECK
		SX3->X3_TRIGGER															, ; //X3_TRIGGER
		SX3->X3_PROPRI															, ; //X3_PROPRI
		SX3->X3_BROWSE															, ; //X3_BROWSE
		SX3->X3_VISUAL															, ; //X3_VISUAL
		SX3->X3_CONTEXT															, ; //X3_CONTEXT
		SX3->X3_OBRIGAT    														, ; //X3_OBRIGAT
		SX3->X3_VLDUSER                                                         , ; //X3_VLDUSER
		SX3->X3_CBOX															, ; //X3_CBOX
		SX3->X3_CBOXSPA															, ; //X3_CBOXSPA
		SX3->X3_CBOXENG															, ; //X3_CBOXENG
		SX3->X3_PICTVAR															, ; //X3_PICTVAR
		SX3->X3_WHEN															, ; //X3_WHEN
		SX3->X3_INIBRW															, ; //X3_INIBRW
		SX3->X3_GRPSXG															, ; //X3_GRPSXG
		SX3->X3_FOLDER  														, ; //X3_FOLDER
		SX3->X3_PYME															} ) //X3_PYME
	EndIf
	

	SX3->(DbSetOrder(2))
	If SX3->(dbSeek("A1_EMAIL"))
		aAdd( aSX3, { ;
		'SA1'																	, ; //X3_ARQUIVO
		SX3->X3_ORDEM															, ; //X3_ORDEM
		'A1_EMAIL'   															, ; //X3_CAMPO
		SX3->X3_TIPO															, ; //X3_TIPO
		100																		, ; //X3_TAMANHO
		SX3->X3_DECIMAL															, ; //X3_DECIMAL
		SX3->X3_TITULO															, ; //X3_TITULO
		SX3->X3_TITSPA															, ; //X3_TITSPA
		SX3->X3_TITENG															, ; //X3_TITENG
		SX3->X3_DESCRIC															, ; //X3_DESCRIC
		SX3->X3_DESCSPA															, ; //X3_DESCSPA
		SX3->X3_DESCENG															, ; //X3_DESCENG
		SX3->X3_PICTURE															, ; //X3_PICTURE
		SX3->X3_VALID															, ; //X3_VALID
		SX3->X3_USADO															, ; //X3_USADO
		SX3->X3_RELACAO	 														, ; //X3_RELACAO
		SX3->X3_F3																, ; //X3_F3
		SX3->X3_NIVEL															, ; //X3_NIVEL
		SX3->X3_RESERV															, ; //X3_RESERV
		SX3->X3_CHECK															, ; //X3_CHECK
		SX3->X3_TRIGGER															, ; //X3_TRIGGER
		SX3->X3_PROPRI															, ; //X3_PROPRI
		SX3->X3_BROWSE															, ; //X3_BROWSE
		SX3->X3_VISUAL															, ; //X3_VISUAL
		SX3->X3_CONTEXT															, ; //X3_CONTEXT
		SX3->X3_OBRIGAT    														, ; //X3_OBRIGAT
		SX3->X3_VLDUSER                                                         , ; //X3_VLDUSER
		SX3->X3_CBOX															, ; //X3_CBOX
		SX3->X3_CBOXSPA															, ; //X3_CBOXSPA
		SX3->X3_CBOXENG															, ; //X3_CBOXENG
		SX3->X3_PICTVAR															, ; //X3_PICTVAR
		SX3->X3_WHEN															, ; //X3_WHEN
		SX3->X3_INIBRW															, ; //X3_INIBRW
		SX3->X3_GRPSXG															, ; //X3_GRPSXG
		SX3->X3_FOLDER  														, ; //X3_FOLDER
		SX3->X3_PYME															} ) //X3_PYME
	EndIf	
	
	
	SX3->(DbSetOrder(2))
	If SX3->(dbSeek("A1_ENDCOB"))
		aAdd( aSX3, { ;
		'SA1'																	, ; //X3_ARQUIVO
		SX3->X3_ORDEM															, ; //X3_ORDEM
		'A1_ENDCOB'   															, ; //X3_CAMPO
		SX3->X3_TIPO															, ; //X3_TIPO
		60 																		, ; //X3_TAMANHO
		SX3->X3_DECIMAL															, ; //X3_DECIMAL
		SX3->X3_TITULO															, ; //X3_TITULO
		SX3->X3_TITSPA															, ; //X3_TITSPA
		SX3->X3_TITENG															, ; //X3_TITENG
		SX3->X3_DESCRIC															, ; //X3_DESCRIC
		SX3->X3_DESCSPA															, ; //X3_DESCSPA
		SX3->X3_DESCENG															, ; //X3_DESCENG
		SX3->X3_PICTURE															, ; //X3_PICTURE
		SX3->X3_VALID															, ; //X3_VALID
		SX3->X3_USADO															, ; //X3_USADO
		SX3->X3_RELACAO	 														, ; //X3_RELACAO
		SX3->X3_F3																, ; //X3_F3
		SX3->X3_NIVEL															, ; //X3_NIVEL
		SX3->X3_RESERV															, ; //X3_RESERV
		SX3->X3_CHECK															, ; //X3_CHECK
		SX3->X3_TRIGGER															, ; //X3_TRIGGER
		SX3->X3_PROPRI															, ; //X3_PROPRI
		SX3->X3_BROWSE															, ; //X3_BROWSE
		SX3->X3_VISUAL															, ; //X3_VISUAL
		SX3->X3_CONTEXT															, ; //X3_CONTEXT
		SX3->X3_OBRIGAT    														, ; //X3_OBRIGAT
		'texto() .And. IIf(Len(AllTrim(M->A1_ENDCOB))>40,(Alert("Digite o endereco com no maximo 40 caracteres"),.F.),.T.)', ; //X3_VLDUSER
		SX3->X3_CBOX															, ; //X3_CBOX
		SX3->X3_CBOXSPA															, ; //X3_CBOXSPA
		SX3->X3_CBOXENG															, ; //X3_CBOXENG
		SX3->X3_PICTVAR															, ; //X3_PICTVAR
		SX3->X3_WHEN															, ; //X3_WHEN
		SX3->X3_INIBRW															, ; //X3_INIBRW
		SX3->X3_GRPSXG															, ; //X3_GRPSXG
		SX3->X3_FOLDER  														, ; //X3_FOLDER
		SX3->X3_PYME															} ) //X3_PYME
	EndIf	
         
	SX3->(DbSetOrder(2))
	If SX3->(dbSeek("A1_EE198"))
		aAdd( aSX3, { ;
		'SA1'																	, ; //X3_ARQUIVO
		SX3->X3_ORDEM															, ; //X3_ORDEM
		'A1_EE198'   															, ; //X3_CAMPO
		SX3->X3_TIPO															, ; //X3_TIPO
		SX3->X3_TAMANHO															, ; //X3_TAMANHO
		SX3->X3_DECIMAL															, ; //X3_DECIMAL
		SX3->X3_TITULO															, ; //X3_TITULO
		SX3->X3_TITSPA															, ; //X3_TITSPA
		SX3->X3_TITENG															, ; //X3_TITENG
		SX3->X3_DESCRIC															, ; //X3_DESCRIC
		SX3->X3_DESCSPA															, ; //X3_DESCSPA
		SX3->X3_DESCENG															, ; //X3_DESCENG
		SX3->X3_PICTURE															, ; //X3_PICTURE
		SX3->X3_VALID															, ; //X3_VALID
		SX3->X3_USADO															, ; //X3_USADO
		SX3->X3_RELACAO	 														, ; //X3_RELACAO
		SX3->X3_F3																, ; //X3_F3
		SX3->X3_NIVEL															, ; //X3_NIVEL
		SX3->X3_RESERV															, ; //X3_RESERV
		SX3->X3_CHECK															, ; //X3_CHECK
		SX3->X3_TRIGGER															, ; //X3_TRIGGER
		SX3->X3_PROPRI															, ; //X3_PROPRI
		SX3->X3_BROWSE															, ; //X3_BROWSE
		SX3->X3_VISUAL															, ; //X3_VISUAL
		SX3->X3_CONTEXT															, ; //X3_CONTEXT
		SX3->X3_OBRIGAT    														, ; //X3_OBRIGAT
		SX3->X3_VLDUSER                                                         , ; //X3_VLDUSER
		SX3->X3_CBOX															, ; //X3_CBOX
		SX3->X3_CBOXSPA															, ; //X3_CBOXSPA
		SX3->X3_CBOXENG															, ; //X3_CBOXENG
		SX3->X3_PICTVAR															, ; //X3_PICTVAR
		'Upper(U_DipUsr()) $ "MCANUTO/DDOMINGOS"'								, ; //X3_WHEN
		SX3->X3_INIBRW															, ; //X3_INIBRW
		SX3->X3_GRPSXG															, ; //X3_GRPSXG
		SX3->X3_FOLDER  														, ; //X3_FOLDER
		SX3->X3_PYME															} ) //X3_PYME
	EndIf
	
		SX3->(DbSetOrder(2))
	If SX3->(dbSeek("A1_COD"))
		aAdd( aSX3, { ;
		'SA1'																	, ; //X3_ARQUIVO
		SX3->X3_ORDEM															, ; //X3_ORDEM
		'A1_COD'   																, ; //X3_CAMPO
		SX3->X3_TIPO 															, ; //X3_TIPO
		SX3->X3_TAMANHO															, ; //X3_TAMANHO
		SX3->X3_DECIMAL															, ; //X3_DECIMAL
		SX3->X3_TITULO															, ; //X3_TITULO
		SX3->X3_TITSPA															, ; //X3_TITSPA
		SX3->X3_TITENG															, ; //X3_TITENG
		SX3->X3_DESCRIC															, ; //X3_DESCRIC
		SX3->X3_DESCSPA															, ; //X3_DESCSPA
		SX3->X3_DESCENG															, ; //X3_DESCENG
		SX3->X3_PICTURE															, ; //X3_PICTURE
		SX3->X3_VALID															, ; //X3_VALID
		SX3->X3_USADO															, ; //X3_USADO
		SX3->X3_RELACAO	 														, ; //X3_RELACAO
		SX3->X3_F3																, ; //X3_F3
		SX3->X3_NIVEL															, ; //X3_NIVEL
		SX3->X3_RESERV															, ; //X3_RESERV
		SX3->X3_CHECK															, ; //X3_CHECK
		SX3->X3_TRIGGER															, ; //X3_TRIGGER
		SX3->X3_PROPRI															, ; //X3_PROPRI
		SX3->X3_BROWSE															, ; //X3_BROWSE
		SX3->X3_VISUAL															, ; //X3_VISUAL
		SX3->X3_CONTEXT															, ; //X3_CONTEXT
		SX3->X3_OBRIGAT    														, ; //X3_OBRIGAT
		'IIF(Len(AllTrim(M->A1_COD))<>6,(Alert("Informe um codigo com 6 digitos"),.F.),.T.)' , ; //X3_VLDUSER
		SX3->X3_CBOX															, ; //X3_CBOX
		SX3->X3_CBOXSPA															, ; //X3_CBOXSPA
		SX3->X3_CBOXENG															, ; //X3_CBOXENG
		SX3->X3_PICTVAR															, ; //X3_PICTVAR
		SX3->X3_WHEN															, ; //X3_WHEN
		SX3->X3_INIBRW															, ; //X3_INIBRW
		SX3->X3_GRPSXG															, ; //X3_GRPSXG
		SX3->X3_FOLDER  														, ; //X3_FOLDER
		SX3->X3_PYME															} ) //X3_PYME
	EndIf
         
		SX3->(DbSetOrder(2))
	If SX3->(dbSeek("A2_COD"))
		aAdd( aSX3, { ;
		'SA2'																	, ; //X3_ARQUIVO
		SX3->X3_ORDEM															, ; //X3_ORDEM
		'A2_COD'   																, ; //X3_CAMPO
		SX3->X3_TIPO 															, ; //X3_TIPO
		SX3->X3_TAMANHO															, ; //X3_TAMANHO
		SX3->X3_DECIMAL															, ; //X3_DECIMAL
		SX3->X3_TITULO															, ; //X3_TITULO
		SX3->X3_TITSPA															, ; //X3_TITSPA
		SX3->X3_TITENG															, ; //X3_TITENG
		SX3->X3_DESCRIC															, ; //X3_DESCRIC
		SX3->X3_DESCSPA															, ; //X3_DESCSPA
		SX3->X3_DESCENG															, ; //X3_DESCENG
		SX3->X3_PICTURE															, ; //X3_PICTURE
		SX3->X3_VALID															, ; //X3_VALID
		SX3->X3_USADO															, ; //X3_USADO
		SX3->X3_RELACAO	 														, ; //X3_RELACAO
		SX3->X3_F3																, ; //X3_F3
		SX3->X3_NIVEL															, ; //X3_NIVEL
		SX3->X3_RESERV															, ; //X3_RESERV
		SX3->X3_CHECK															, ; //X3_CHECK
		SX3->X3_TRIGGER															, ; //X3_TRIGGER
		SX3->X3_PROPRI															, ; //X3_PROPRI
		SX3->X3_BROWSE															, ; //X3_BROWSE
		SX3->X3_VISUAL															, ; //X3_VISUAL
		SX3->X3_CONTEXT															, ; //X3_CONTEXT
		SX3->X3_OBRIGAT    														, ; //X3_OBRIGAT
		'IIF(Len(AllTrim(M->A2_COD))<>6,(Alert("Informe um codigo com 6 digitos"),.F.),.T.)' , ; //X3_VLDUSER
		SX3->X3_CBOX															, ; //X3_CBOX
		SX3->X3_CBOXSPA															, ; //X3_CBOXSPA
		SX3->X3_CBOXENG															, ; //X3_CBOXENG
		SX3->X3_PICTVAR															, ; //X3_PICTVAR
		SX3->X3_WHEN															, ; //X3_WHEN
		SX3->X3_INIBRW															, ; //X3_INIBRW
		SX3->X3_GRPSXG															, ; //X3_GRPSXG
		SX3->X3_FOLDER  														, ; //X3_FOLDER
		SX3->X3_PYME															} ) //X3_PYME
	EndIf
    
		SX3->(DbSetOrder(2))
	If SX3->(dbSeek("A3_COD"))
		aAdd( aSX3, { ;
		'SA3'																	, ; //X3_ARQUIVO
		SX3->X3_ORDEM															, ; //X3_ORDEM
		'A3_COD'   																, ; //X3_CAMPO
		SX3->X3_TIPO 															, ; //X3_TIPO
		SX3->X3_TAMANHO															, ; //X3_TAMANHO
		SX3->X3_DECIMAL															, ; //X3_DECIMAL
		SX3->X3_TITULO															, ; //X3_TITULO
		SX3->X3_TITSPA															, ; //X3_TITSPA
		SX3->X3_TITENG															, ; //X3_TITENG
		SX3->X3_DESCRIC															, ; //X3_DESCRIC
		SX3->X3_DESCSPA															, ; //X3_DESCSPA
		SX3->X3_DESCENG															, ; //X3_DESCENG
		SX3->X3_PICTURE															, ; //X3_PICTURE
		SX3->X3_VALID															, ; //X3_VALID
		SX3->X3_USADO															, ; //X3_USADO
		SX3->X3_RELACAO	 														, ; //X3_RELACAO
		SX3->X3_F3																, ; //X3_F3
		SX3->X3_NIVEL															, ; //X3_NIVEL
		SX3->X3_RESERV															, ; //X3_RESERV
		SX3->X3_CHECK															, ; //X3_CHECK
		SX3->X3_TRIGGER															, ; //X3_TRIGGER
		SX3->X3_PROPRI															, ; //X3_PROPRI
		SX3->X3_BROWSE															, ; //X3_BROWSE
		SX3->X3_VISUAL															, ; //X3_VISUAL
		SX3->X3_CONTEXT															, ; //X3_CONTEXT
		SX3->X3_OBRIGAT    														, ; //X3_OBRIGAT
		'IIF(Len(AllTrim(M->A3_COD))<>6,(Alert("Informe um codigo com 6 digitos"),.F.),.T.)' , ; //X3_VLDUSER
		SX3->X3_CBOX															, ; //X3_CBOX
		SX3->X3_CBOXSPA															, ; //X3_CBOXSPA
		SX3->X3_CBOXENG															, ; //X3_CBOXENG
		SX3->X3_PICTVAR															, ; //X3_PICTVAR
		SX3->X3_WHEN															, ; //X3_WHEN
		SX3->X3_INIBRW															, ; //X3_INIBRW
		SX3->X3_GRPSXG															, ; //X3_GRPSXG
		SX3->X3_FOLDER  														, ; //X3_FOLDER
		SX3->X3_PYME															} ) //X3_PYME
	EndIf

		SX3->(DbSetOrder(2))
	If SX3->(dbSeek("A4_COD"))
		aAdd( aSX3, { ;
		'SA4'																	, ; //X3_ARQUIVO
		SX3->X3_ORDEM															, ; //X3_ORDEM
		'A4_COD'   																, ; //X3_CAMPO
		SX3->X3_TIPO 															, ; //X3_TIPO
		SX3->X3_TAMANHO															, ; //X3_TAMANHO
		SX3->X3_DECIMAL															, ; //X3_DECIMAL
		SX3->X3_TITULO															, ; //X3_TITULO
		SX3->X3_TITSPA															, ; //X3_TITSPA
		SX3->X3_TITENG															, ; //X3_TITENG
		SX3->X3_DESCRIC															, ; //X3_DESCRIC
		SX3->X3_DESCSPA															, ; //X3_DESCSPA
		SX3->X3_DESCENG															, ; //X3_DESCENG
		SX3->X3_PICTURE															, ; //X3_PICTURE
		SX3->X3_VALID															, ; //X3_VALID
		SX3->X3_USADO															, ; //X3_USADO
		SX3->X3_RELACAO	 														, ; //X3_RELACAO
		SX3->X3_F3																, ; //X3_F3
		SX3->X3_NIVEL															, ; //X3_NIVEL
		SX3->X3_RESERV															, ; //X3_RESERV
		SX3->X3_CHECK															, ; //X3_CHECK
		SX3->X3_TRIGGER															, ; //X3_TRIGGER
		SX3->X3_PROPRI															, ; //X3_PROPRI
		SX3->X3_BROWSE															, ; //X3_BROWSE
		SX3->X3_VISUAL															, ; //X3_VISUAL
		SX3->X3_CONTEXT															, ; //X3_CONTEXT
		SX3->X3_OBRIGAT    														, ; //X3_OBRIGAT
		'IIF(Len(AllTrim(M->A4_COD))<>6,(Alert("Informe um codigo com 6 digitos"),.F.),.T.)' , ; //X3_VLDUSER
		SX3->X3_CBOX															, ; //X3_CBOX
		SX3->X3_CBOXSPA															, ; //X3_CBOXSPA
		SX3->X3_CBOXENG															, ; //X3_CBOXENG
		SX3->X3_PICTVAR															, ; //X3_PICTVAR
		SX3->X3_WHEN															, ; //X3_WHEN
		SX3->X3_INIBRW															, ; //X3_INIBRW
		SX3->X3_GRPSXG															, ; //X3_GRPSXG
		SX3->X3_FOLDER  														, ; //X3_FOLDER
		SX3->X3_PYME															} ) //X3_PYME
	EndIf

SX3->(DbSetOrder(2))
If SX3->(dbSeek("B1_PESO"))
	aAdd( aSX3, { ;
	'SB1'																	, ; //X3_ARQUIVO
	SX3->X3_ORDEM															, ; //X3_ORDEM
	'B1_PESO'   															, ; //X3_CAMPO
	SX3->X3_TIPO															, ; //X3_TIPO
	SX3->X3_TAMANHO															, ; //X3_TAMANHO
	SX3->X3_DECIMAL															, ; //X3_DECIMAL
	SX3->X3_TITULO															, ; //X3_TITULO
	SX3->X3_TITSPA															, ; //X3_TITSPA
	SX3->X3_TITENG															, ; //X3_TITENG
	SX3->X3_DESCRIC															, ; //X3_DESCRIC
	SX3->X3_DESCSPA															, ; //X3_DESCSPA
	SX3->X3_DESCENG															, ; //X3_DESCENG
	SX3->X3_PICTURE															, ; //X3_PICTURE
	SX3->X3_VALID															, ; //X3_VALID
	SX3->X3_USADO															, ; //X3_USADO
	SX3->X3_RELACAO 														, ; //X3_RELACAO
	SX3->X3_F3																, ; //X3_F3
	SX3->X3_NIVEL															, ; //X3_NIVEL
	SX3->X3_RESERV															, ; //X3_RESERV
	SX3->X3_CHECK															, ; //X3_CHECK
	SX3->X3_TRIGGER															, ; //X3_TRIGGER
	SX3->X3_PROPRI															, ; //X3_PROPRI
	SX3->X3_BROWSE															, ; //X3_BROWSE
	SX3->X3_VISUAL															, ; //X3_VISUAL
	SX3->X3_CONTEXT															, ; //X3_CONTEXT
	'Ä'			    														, ; //X3_OBRIGAT
	SX3->X3_VLDUSER									                        , ; //X3_VLDUSER
	SX3->X3_CBOX															, ; //X3_CBOX
	SX3->X3_CBOXSPA															, ; //X3_CBOXSPA
	SX3->X3_CBOXENG															, ; //X3_CBOXENG
	SX3->X3_PICTVAR															, ; //X3_PICTVAR
	SX3->X3_WHEN															, ; //X3_WHEN
	SX3->X3_INIBRW															, ; //X3_INIBRW
	SX3->X3_GRPSXG															, ; //X3_GRPSXG
	SX3->X3_FOLDER	  														, ; //X3_FOLDER
	SX3->X3_PYME															} ) //X3_PYME
EndIf	

SX3->(DbSetOrder(2))
If SX3->(dbSeek("A1_CONTRIB"))	
	aAdd( aSX3, { ;
	'SA1'																	, ; //X3_ARQUIVO
	SX3->X3_ORDEM															, ; //X3_ORDEM
	'A1_CONTRIB'   															, ; //X3_CAMPO
	SX3->X3_TIPO															, ; //X3_TIPO
	SX3->X3_TAMANHO															, ; //X3_TAMANHO
	SX3->X3_DECIMAL															, ; //X3_DECIMAL
	SX3->X3_TITULO															, ; //X3_TITULO
	SX3->X3_TITSPA															, ; //X3_TITSPA
	SX3->X3_TITENG															, ; //X3_TITENG
	SX3->X3_DESCRIC															, ; //X3_DESCRIC
	SX3->X3_DESCSPA															, ; //X3_DESCSPA
	SX3->X3_DESCENG															, ; //X3_DESCENG
	SX3->X3_PICTURE															, ; //X3_PICTURE
	SX3->X3_VALID															, ; //X3_VALID
	SX3->X3_USADO															, ; //X3_USADO
	SX3->X3_RELACAO 														, ; //X3_RELACAO
	SX3->X3_F3																, ; //X3_F3
	SX3->X3_NIVEL															, ; //X3_NIVEL
	SX3->X3_RESERV															, ; //X3_RESERV
	SX3->X3_CHECK															, ; //X3_CHECK
	SX3->X3_TRIGGER															, ; //X3_TRIGGER
	SX3->X3_PROPRI															, ; //X3_PROPRI
	SX3->X3_BROWSE															, ; //X3_BROWSE
	SX3->X3_VISUAL															, ; //X3_VISUAL
	SX3->X3_CONTEXT															, ; //X3_CONTEXT
	''	 			   														, ; //X3_OBRIGAT
	SX3->X3_VLDUSER                                                         , ; //X3_VLDUSER
	SX3->X3_CBOX															, ; //X3_CBOX
	SX3->X3_CBOXSPA															, ; //X3_CBOXSPA
	SX3->X3_CBOXENG															, ; //X3_CBOXENG
	SX3->X3_PICTVAR															, ; //X3_PICTVAR
	SX3->X3_WHEN															, ; //X3_WHEN
	SX3->X3_INIBRW															, ; //X3_INIBRW
	SX3->X3_GRPSXG															, ; //X3_GRPSXG
	SX3->X3_FOLDER	  														, ; //X3_FOLDER
	SX3->X3_PYME															} ) //X3_PYME
EndIf


SX3->(DbSetOrder(2))
If SX3->(dbSeek("A1_GRPVEN"))	
	aAdd( aSX3, { ;
	'SA1'																	, ; //X3_ARQUIVO
	SX3->X3_ORDEM															, ; //X3_ORDEM
	'A1_GRPVEN'   															, ; //X3_CAMPO
	SX3->X3_TIPO															, ; //X3_TIPO
	SX3->X3_TAMANHO															, ; //X3_TAMANHO
	SX3->X3_DECIMAL															, ; //X3_DECIMAL
	SX3->X3_TITULO															, ; //X3_TITULO
	SX3->X3_TITSPA															, ; //X3_TITSPA
	SX3->X3_TITENG															, ; //X3_TITENG
	SX3->X3_DESCRIC															, ; //X3_DESCRIC
	SX3->X3_DESCSPA															, ; //X3_DESCSPA
	SX3->X3_DESCENG															, ; //X3_DESCENG
	SX3->X3_PICTURE															, ; //X3_PICTURE
	SX3->X3_VALID															, ; //X3_VALID
	SX3->X3_USADO															, ; //X3_USADO
	SX3->X3_RELACAO 														, ; //X3_RELACAO
	SX3->X3_F3																, ; //X3_F3
	SX3->X3_NIVEL															, ; //X3_NIVEL
	SX3->X3_RESERV															, ; //X3_RESERV
	SX3->X3_CHECK															, ; //X3_CHECK
	SX3->X3_TRIGGER															, ; //X3_TRIGGER
	SX3->X3_PROPRI															, ; //X3_PROPRI
	SX3->X3_BROWSE															, ; //X3_BROWSE
	SX3->X3_VISUAL															, ; //X3_VISUAL
	SX3->X3_CONTEXT															, ; //X3_CONTEXT
	SX3->X3_OBRIGAT	   														, ; //X3_OBRIGAT
	SX3->X3_VLDUSER                                                         , ; //X3_VLDUSER
	SX3->X3_CBOX															, ; //X3_CBOX
	SX3->X3_CBOXSPA															, ; //X3_CBOXSPA
	SX3->X3_CBOXENG															, ; //X3_CBOXENG
	SX3->X3_PICTVAR															, ; //X3_PICTVAR
	'U_GRPVEN()'															, ; //X3_WHEN
	SX3->X3_INIBRW															, ; //X3_INIBRW
	SX3->X3_GRPSXG															, ; //X3_GRPSXG
	SX3->X3_FOLDER	  														, ; //X3_FOLDER
	SX3->X3_PYME															} ) //X3_PYME
EndIf

//
//TABELA SUC
//
            
	SX3->(DbSetOrder(2))
	If SX3->(dbSeek("UC_PENDENT"))
		
		aAdd( aSX3, { ;
		'SUC'																	, ; //X3_ARQUIVO
		SX3->X3_ORDEM															, ; //X3_ORDEM
		'UC_PENDENT'   															, ; //X3_CAMPO
		SX3->X3_TIPO															, ; //X3_TIPO
		SX3->X3_TAMANHO															, ; //X3_TAMANHO
		SX3->X3_DECIMAL															, ; //X3_DECIMAL
		SX3->X3_TITULO															, ; //X3_TITULO
		SX3->X3_TITSPA															, ; //X3_TITSPA
		SX3->X3_TITENG															, ; //X3_TITENG
		SX3->X3_DESCRIC															, ; //X3_DESCRIC
		SX3->X3_DESCSPA															, ; //X3_DESCSPA
		SX3->X3_DESCENG															, ; //X3_DESCENG
		SX3->X3_PICTURE															, ; //X3_PICTURE
		SX3->X3_VALID															, ; //X3_VALID
		SX3->X3_USADO															, ; //X3_USADO
		SX3->X3_RELACAO 														, ; //X3_RELACAO
		SX3->X3_F3																, ; //X3_F3
		9																		, ; //X3_NIVEL
		SX3->X3_RESERV															, ; //X3_RESERV
		SX3->X3_CHECK															, ; //X3_CHECK
		SX3->X3_TRIGGER															, ; //X3_TRIGGER
		SX3->X3_PROPRI															, ; //X3_PROPRI
		SX3->X3_BROWSE															, ; //X3_BROWSE
		SX3->X3_VISUAL															, ; //X3_VISUAL
		SX3->X3_CONTEXT															, ; //X3_CONTEXT
		SX3->X3_OBRIGAT    														, ; //X3_OBRIGAT
		SX3->X3_VLDUSER                                                         , ; //X3_VLDUSER
		SX3->X3_CBOX															, ; //X3_CBOX
		SX3->X3_CBOXSPA															, ; //X3_CBOXSPA
		SX3->X3_CBOXENG															, ; //X3_CBOXENG
		SX3->X3_PICTVAR															, ; //X3_PICTVAR
		SX3->X3_WHEN															, ; //X3_WHEN
		SX3->X3_INIBRW															, ; //X3_INIBRW
		SX3->X3_GRPSXG															, ; //X3_GRPSXG
		SX3->X3_FOLDER  														, ; //X3_FOLDER
		SX3->X3_PYME															} ) //X3_PYME
	EndIf

	SX3->(DbSetOrder(2))
	If SX3->(dbSeek("UC_HRPEND"))
		
		aAdd( aSX3, { ;
		'SUC'																	, ; //X3_ARQUIVO
		SX3->X3_ORDEM															, ; //X3_ORDEM
		'UC_HRPEND'   															, ; //X3_CAMPO
		SX3->X3_TIPO															, ; //X3_TIPO
		SX3->X3_TAMANHO															, ; //X3_TAMANHO
		SX3->X3_DECIMAL															, ; //X3_DECIMAL
		SX3->X3_TITULO															, ; //X3_TITULO
		SX3->X3_TITSPA															, ; //X3_TITSPA
		SX3->X3_TITENG															, ; //X3_TITENG
		SX3->X3_DESCRIC															, ; //X3_DESCRIC
		SX3->X3_DESCSPA															, ; //X3_DESCSPA
		SX3->X3_DESCENG															, ; //X3_DESCENG
		SX3->X3_PICTURE															, ; //X3_PICTURE
		SX3->X3_VALID															, ; //X3_VALID
		SX3->X3_USADO															, ; //X3_USADO
		SX3->X3_RELACAO 														, ; //X3_RELACAO
		SX3->X3_F3																, ; //X3_F3
		9																		, ; //X3_NIVEL
		SX3->X3_RESERV															, ; //X3_RESERV
		SX3->X3_CHECK															, ; //X3_CHECK
		SX3->X3_TRIGGER															, ; //X3_TRIGGER
		SX3->X3_PROPRI															, ; //X3_PROPRI
		SX3->X3_BROWSE															, ; //X3_BROWSE
		SX3->X3_VISUAL															, ; //X3_VISUAL
		SX3->X3_CONTEXT															, ; //X3_CONTEXT
		SX3->X3_OBRIGAT    														, ; //X3_OBRIGAT
		SX3->X3_VLDUSER                                                         , ; //X3_VLDUSER
		SX3->X3_CBOX															, ; //X3_CBOX
		SX3->X3_CBOXSPA															, ; //X3_CBOXSPA
		SX3->X3_CBOXENG															, ; //X3_CBOXENG
		SX3->X3_PICTVAR															, ; //X3_PICTVAR
		SX3->X3_WHEN															, ; //X3_WHEN
		SX3->X3_INIBRW															, ; //X3_INIBRW
		SX3->X3_GRPSXG															, ; //X3_GRPSXG
		SX3->X3_FOLDER  														, ; //X3_FOLDER
		SX3->X3_PYME															} ) //X3_PYME
	EndIf

	SX3->(DbSetOrder(2))
	If SX3->(dbSeek("UC_MIDIA"))
		
		aAdd( aSX3, { ;
		'SUC'																	, ; //X3_ARQUIVO
		SX3->X3_ORDEM															, ; //X3_ORDEM
		'UC_MIDIA'   															, ; //X3_CAMPO
		SX3->X3_TIPO															, ; //X3_TIPO
		SX3->X3_TAMANHO															, ; //X3_TAMANHO
		SX3->X3_DECIMAL															, ; //X3_DECIMAL
		SX3->X3_TITULO															, ; //X3_TITULO
		SX3->X3_TITSPA															, ; //X3_TITSPA
		SX3->X3_TITENG															, ; //X3_TITENG
		SX3->X3_DESCRIC															, ; //X3_DESCRIC
		SX3->X3_DESCSPA															, ; //X3_DESCSPA
		SX3->X3_DESCENG															, ; //X3_DESCENG
		SX3->X3_PICTURE															, ; //X3_PICTURE
		SX3->X3_VALID															, ; //X3_VALID
		SX3->X3_USADO															, ; //X3_USADO
		SX3->X3_RELACAO 														, ; //X3_RELACAO
		SX3->X3_F3																, ; //X3_F3
		9																		, ; //X3_NIVEL
		SX3->X3_RESERV															, ; //X3_RESERV
		SX3->X3_CHECK															, ; //X3_CHECK
		SX3->X3_TRIGGER															, ; //X3_TRIGGER
		SX3->X3_PROPRI															, ; //X3_PROPRI
		SX3->X3_BROWSE															, ; //X3_BROWSE
		SX3->X3_VISUAL															, ; //X3_VISUAL
		SX3->X3_CONTEXT															, ; //X3_CONTEXT
		SX3->X3_OBRIGAT    														, ; //X3_OBRIGAT
		SX3->X3_VLDUSER                                                         , ; //X3_VLDUSER
		SX3->X3_CBOX															, ; //X3_CBOX
		SX3->X3_CBOXSPA															, ; //X3_CBOXSPA
		SX3->X3_CBOXENG															, ; //X3_CBOXENG
		SX3->X3_PICTVAR															, ; //X3_PICTVAR
		SX3->X3_WHEN															, ; //X3_WHEN
		SX3->X3_INIBRW															, ; //X3_INIBRW
		SX3->X3_GRPSXG															, ; //X3_GRPSXG
		SX3->X3_FOLDER  														, ; //X3_FOLDER
		SX3->X3_PYME															} ) //X3_PYME
	EndIf

	SX3->(DbSetOrder(2))
	If SX3->(dbSeek("UC_DESCMID"))
		
		aAdd( aSX3, { ;
		'SUC'																	, ; //X3_ARQUIVO
		SX3->X3_ORDEM															, ; //X3_ORDEM
		'UC_DESCMID'   															, ; //X3_CAMPO
		SX3->X3_TIPO															, ; //X3_TIPO
		SX3->X3_TAMANHO															, ; //X3_TAMANHO
		SX3->X3_DECIMAL															, ; //X3_DECIMAL
		SX3->X3_TITULO															, ; //X3_TITULO
		SX3->X3_TITSPA															, ; //X3_TITSPA
		SX3->X3_TITENG															, ; //X3_TITENG
		SX3->X3_DESCRIC															, ; //X3_DESCRIC
		SX3->X3_DESCSPA															, ; //X3_DESCSPA
		SX3->X3_DESCENG															, ; //X3_DESCENG
		SX3->X3_PICTURE															, ; //X3_PICTURE
		SX3->X3_VALID															, ; //X3_VALID
		SX3->X3_USADO															, ; //X3_USADO
		SX3->X3_RELACAO 														, ; //X3_RELACAO
		SX3->X3_F3																, ; //X3_F3
		9																		, ; //X3_NIVEL
		SX3->X3_RESERV															, ; //X3_RESERV
		SX3->X3_CHECK															, ; //X3_CHECK
		SX3->X3_TRIGGER															, ; //X3_TRIGGER
		SX3->X3_PROPRI															, ; //X3_PROPRI
		SX3->X3_BROWSE															, ; //X3_BROWSE
		SX3->X3_VISUAL															, ; //X3_VISUAL
		SX3->X3_CONTEXT															, ; //X3_CONTEXT
		SX3->X3_OBRIGAT    														, ; //X3_OBRIGAT
		SX3->X3_VLDUSER                                                         , ; //X3_VLDUSER
		SX3->X3_CBOX															, ; //X3_CBOX
		SX3->X3_CBOXSPA															, ; //X3_CBOXSPA
		SX3->X3_CBOXENG															, ; //X3_CBOXENG
		SX3->X3_PICTVAR															, ; //X3_PICTVAR
		SX3->X3_WHEN															, ; //X3_WHEN
		SX3->X3_INIBRW															, ; //X3_INIBRW
		SX3->X3_GRPSXG															, ; //X3_GRPSXG
		SX3->X3_FOLDER  														, ; //X3_FOLDER
		SX3->X3_PYME															} ) //X3_PYME
	EndIf

	SX3->(DbSetOrder(2))
	If SX3->(dbSeek("UC_TIPO"))
		
		aAdd( aSX3, { ;
		'SUC'																	, ; //X3_ARQUIVO
		SX3->X3_ORDEM															, ; //X3_ORDEM
		'UC_TIPO'   															, ; //X3_CAMPO
		SX3->X3_TIPO															, ; //X3_TIPO
		SX3->X3_TAMANHO															, ; //X3_TAMANHO
		SX3->X3_DECIMAL															, ; //X3_DECIMAL
		SX3->X3_TITULO															, ; //X3_TITULO
		SX3->X3_TITSPA															, ; //X3_TITSPA
		SX3->X3_TITENG															, ; //X3_TITENG
		SX3->X3_DESCRIC															, ; //X3_DESCRIC
		SX3->X3_DESCSPA															, ; //X3_DESCSPA
		SX3->X3_DESCENG															, ; //X3_DESCENG
		SX3->X3_PICTURE															, ; //X3_PICTURE
		SX3->X3_VALID															, ; //X3_VALID
		SX3->X3_USADO															, ; //X3_USADO
		SX3->X3_RELACAO 														, ; //X3_RELACAO
		SX3->X3_F3																, ; //X3_F3
		9																		, ; //X3_NIVEL
		SX3->X3_RESERV															, ; //X3_RESERV
		SX3->X3_CHECK															, ; //X3_CHECK
		SX3->X3_TRIGGER															, ; //X3_TRIGGER
		SX3->X3_PROPRI															, ; //X3_PROPRI
		SX3->X3_BROWSE															, ; //X3_BROWSE
		SX3->X3_VISUAL															, ; //X3_VISUAL
		SX3->X3_CONTEXT															, ; //X3_CONTEXT
		SX3->X3_OBRIGAT    														, ; //X3_OBRIGAT
		SX3->X3_VLDUSER                                                         , ; //X3_VLDUSER
		SX3->X3_CBOX															, ; //X3_CBOX
		SX3->X3_CBOXSPA															, ; //X3_CBOXSPA
		SX3->X3_CBOXENG															, ; //X3_CBOXENG
		SX3->X3_PICTVAR															, ; //X3_PICTVAR
		SX3->X3_WHEN															, ; //X3_WHEN
		SX3->X3_INIBRW															, ; //X3_INIBRW
		SX3->X3_GRPSXG															, ; //X3_GRPSXG
		SX3->X3_FOLDER  														, ; //X3_FOLDER
		SX3->X3_PYME															} ) //X3_PYME
	EndIf

	SX3->(DbSetOrder(2))
	If SX3->(dbSeek("UC_DESCTIP"))
		
		aAdd( aSX3, { ;
		'SUC'																	, ; //X3_ARQUIVO
		SX3->X3_ORDEM															, ; //X3_ORDEM
		'UC_DESCTIP'   															, ; //X3_CAMPO
		SX3->X3_TIPO															, ; //X3_TIPO
		SX3->X3_TAMANHO															, ; //X3_TAMANHO
		SX3->X3_DECIMAL															, ; //X3_DECIMAL
		SX3->X3_TITULO															, ; //X3_TITULO
		SX3->X3_TITSPA															, ; //X3_TITSPA
		SX3->X3_TITENG															, ; //X3_TITENG
		SX3->X3_DESCRIC															, ; //X3_DESCRIC
		SX3->X3_DESCSPA															, ; //X3_DESCSPA
		SX3->X3_DESCENG															, ; //X3_DESCENG
		SX3->X3_PICTURE															, ; //X3_PICTURE
		SX3->X3_VALID															, ; //X3_VALID
		SX3->X3_USADO															, ; //X3_USADO
		SX3->X3_RELACAO 														, ; //X3_RELACAO
		SX3->X3_F3																, ; //X3_F3
		9																		, ; //X3_NIVEL
		SX3->X3_RESERV															, ; //X3_RESERV
		SX3->X3_CHECK															, ; //X3_CHECK
		SX3->X3_TRIGGER															, ; //X3_TRIGGER
		SX3->X3_PROPRI															, ; //X3_PROPRI
		SX3->X3_BROWSE															, ; //X3_BROWSE
		SX3->X3_VISUAL															, ; //X3_VISUAL
		SX3->X3_CONTEXT															, ; //X3_CONTEXT
		SX3->X3_OBRIGAT    														, ; //X3_OBRIGAT
		SX3->X3_VLDUSER                                                         , ; //X3_VLDUSER
		SX3->X3_CBOX															, ; //X3_CBOX
		SX3->X3_CBOXSPA															, ; //X3_CBOXSPA
		SX3->X3_CBOXENG															, ; //X3_CBOXENG
		SX3->X3_PICTVAR															, ; //X3_PICTVAR
		SX3->X3_WHEN															, ; //X3_WHEN
		SX3->X3_INIBRW															, ; //X3_INIBRW
		SX3->X3_GRPSXG															, ; //X3_GRPSXG
		SX3->X3_FOLDER  														, ; //X3_FOLDER
		SX3->X3_PYME															} ) //X3_PYME
	EndIf


	SX3->(DbSetOrder(2))
	If SX3->(dbSeek("UC_CODOBS"))
		
		aAdd( aSX3, { ;
		'SUC'																	, ; //X3_ARQUIVO
		SX3->X3_ORDEM															, ; //X3_ORDEM
		'UC_CODOBS'   															, ; //X3_CAMPO
		SX3->X3_TIPO															, ; //X3_TIPO
		SX3->X3_TAMANHO															, ; //X3_TAMANHO
		SX3->X3_DECIMAL															, ; //X3_DECIMAL
		SX3->X3_TITULO															, ; //X3_TITULO
		SX3->X3_TITSPA															, ; //X3_TITSPA
		SX3->X3_TITENG															, ; //X3_TITENG
		SX3->X3_DESCRIC															, ; //X3_DESCRIC
		SX3->X3_DESCSPA															, ; //X3_DESCSPA
		SX3->X3_DESCENG															, ; //X3_DESCENG
		SX3->X3_PICTURE															, ; //X3_PICTURE
		SX3->X3_VALID															, ; //X3_VALID
		SX3->X3_USADO															, ; //X3_USADO
		SX3->X3_RELACAO 														, ; //X3_RELACAO
		SX3->X3_F3																, ; //X3_F3
		9																		, ; //X3_NIVEL
		SX3->X3_RESERV															, ; //X3_RESERV
		SX3->X3_CHECK															, ; //X3_CHECK
		SX3->X3_TRIGGER															, ; //X3_TRIGGER
		SX3->X3_PROPRI															, ; //X3_PROPRI
		SX3->X3_BROWSE															, ; //X3_BROWSE
		SX3->X3_VISUAL															, ; //X3_VISUAL
		SX3->X3_CONTEXT															, ; //X3_CONTEXT
		SX3->X3_OBRIGAT    														, ; //X3_OBRIGAT
		SX3->X3_VLDUSER                                                         , ; //X3_VLDUSER
		SX3->X3_CBOX															, ; //X3_CBOX
		SX3->X3_CBOXSPA															, ; //X3_CBOXSPA
		SX3->X3_CBOXENG															, ; //X3_CBOXENG
		SX3->X3_PICTVAR															, ; //X3_PICTVAR
		SX3->X3_WHEN															, ; //X3_WHEN
		SX3->X3_INIBRW															, ; //X3_INIBRW
		SX3->X3_GRPSXG															, ; //X3_GRPSXG
		SX3->X3_FOLDER  														, ; //X3_FOLDER
		SX3->X3_PYME															} ) //X3_PYME
	EndIf
         
	SX3->(DbSetOrder(2))
	If SX3->(dbSeek("UC_CODCAMP"))
		
		aAdd( aSX3, { ;
		'SUC'																	, ; //X3_ARQUIVO
		SX3->X3_ORDEM															, ; //X3_ORDEM
		'UC_CODCAMP'   															, ; //X3_CAMPO
		SX3->X3_TIPO															, ; //X3_TIPO
		SX3->X3_TAMANHO															, ; //X3_TAMANHO
		SX3->X3_DECIMAL															, ; //X3_DECIMAL
		SX3->X3_TITULO															, ; //X3_TITULO
		SX3->X3_TITSPA															, ; //X3_TITSPA
		SX3->X3_TITENG															, ; //X3_TITENG
		SX3->X3_DESCRIC															, ; //X3_DESCRIC
		SX3->X3_DESCSPA															, ; //X3_DESCSPA
		SX3->X3_DESCENG															, ; //X3_DESCENG
		SX3->X3_PICTURE															, ; //X3_PICTURE
		SX3->X3_VALID															, ; //X3_VALID
		SX3->X3_USADO															, ; //X3_USADO
		SX3->X3_RELACAO 														, ; //X3_RELACAO
		SX3->X3_F3																, ; //X3_F3
		9																		, ; //X3_NIVEL
		SX3->X3_RESERV															, ; //X3_RESERV
		SX3->X3_CHECK															, ; //X3_CHECK
		SX3->X3_TRIGGER															, ; //X3_TRIGGER
		SX3->X3_PROPRI															, ; //X3_PROPRI
		SX3->X3_BROWSE															, ; //X3_BROWSE
		SX3->X3_VISUAL															, ; //X3_VISUAL
		SX3->X3_CONTEXT															, ; //X3_CONTEXT
		SX3->X3_OBRIGAT    														, ; //X3_OBRIGAT
		SX3->X3_VLDUSER                                                         , ; //X3_VLDUSER
		SX3->X3_CBOX															, ; //X3_CBOX
		SX3->X3_CBOXSPA															, ; //X3_CBOXSPA
		SX3->X3_CBOXENG															, ; //X3_CBOXENG
		SX3->X3_PICTVAR															, ; //X3_PICTVAR
		SX3->X3_WHEN															, ; //X3_WHEN
		SX3->X3_INIBRW															, ; //X3_INIBRW
		SX3->X3_GRPSXG															, ; //X3_GRPSXG
		SX3->X3_FOLDER  														, ; //X3_FOLDER
		SX3->X3_PYME															} ) //X3_PYME
	EndIf
         
         
	SX3->(DbSetOrder(2))
	If SX3->(dbSeek("UC_DESCCAM"))
		
		aAdd( aSX3, { ;
		'SUC'																	, ; //X3_ARQUIVO
		SX3->X3_ORDEM															, ; //X3_ORDEM
		'UC_DESCCAM'   															, ; //X3_CAMPO
		SX3->X3_TIPO															, ; //X3_TIPO
		SX3->X3_TAMANHO															, ; //X3_TAMANHO
		SX3->X3_DECIMAL															, ; //X3_DECIMAL
		SX3->X3_TITULO															, ; //X3_TITULO
		SX3->X3_TITSPA															, ; //X3_TITSPA
		SX3->X3_TITENG															, ; //X3_TITENG
		SX3->X3_DESCRIC															, ; //X3_DESCRIC
		SX3->X3_DESCSPA															, ; //X3_DESCSPA
		SX3->X3_DESCENG															, ; //X3_DESCENG
		SX3->X3_PICTURE															, ; //X3_PICTURE
		SX3->X3_VALID															, ; //X3_VALID
		SX3->X3_USADO															, ; //X3_USADO
		SX3->X3_RELACAO 														, ; //X3_RELACAO
		SX3->X3_F3																, ; //X3_F3
		9																		, ; //X3_NIVEL
		SX3->X3_RESERV															, ; //X3_RESERV
		SX3->X3_CHECK															, ; //X3_CHECK
		SX3->X3_TRIGGER															, ; //X3_TRIGGER
		SX3->X3_PROPRI															, ; //X3_PROPRI
		SX3->X3_BROWSE															, ; //X3_BROWSE
		SX3->X3_VISUAL															, ; //X3_VISUAL
		SX3->X3_CONTEXT															, ; //X3_CONTEXT
		SX3->X3_OBRIGAT    														, ; //X3_OBRIGAT
		SX3->X3_VLDUSER                                                         , ; //X3_VLDUSER
		SX3->X3_CBOX															, ; //X3_CBOX
		SX3->X3_CBOXSPA															, ; //X3_CBOXSPA
		SX3->X3_CBOXENG															, ; //X3_CBOXENG
		SX3->X3_PICTVAR															, ; //X3_PICTVAR
		SX3->X3_WHEN															, ; //X3_WHEN
		SX3->X3_INIBRW															, ; //X3_INIBRW
		SX3->X3_GRPSXG															, ; //X3_GRPSXG
		SX3->X3_FOLDER  														, ; //X3_FOLDER
		SX3->X3_PYME															} ) //X3_PYME
	EndIf


	SX3->(DbSetOrder(2))
	If SX3->(dbSeek("UC_DESCENT"))
		
		aAdd( aSX3, { ;
		'SUC'																	, ; //X3_ARQUIVO
		SX3->X3_ORDEM															, ; //X3_ORDEM
		'UC_DESCENT'   															, ; //X3_CAMPO
		SX3->X3_TIPO															, ; //X3_TIPO
		SX3->X3_TAMANHO															, ; //X3_TAMANHO
		SX3->X3_DECIMAL															, ; //X3_DECIMAL
		SX3->X3_TITULO															, ; //X3_TITULO
		SX3->X3_TITSPA															, ; //X3_TITSPA
		SX3->X3_TITENG															, ; //X3_TITENG
		SX3->X3_DESCRIC															, ; //X3_DESCRIC
		SX3->X3_DESCSPA															, ; //X3_DESCSPA
		SX3->X3_DESCENG															, ; //X3_DESCENG
		SX3->X3_PICTURE															, ; //X3_PICTURE
		SX3->X3_VALID															, ; //X3_VALID
		SX3->X3_USADO															, ; //X3_USADO
		SX3->X3_RELACAO 														, ; //X3_RELACAO
		SX3->X3_F3																, ; //X3_F3
		9																		, ; //X3_NIVEL
		SX3->X3_RESERV															, ; //X3_RESERV
		SX3->X3_CHECK															, ; //X3_CHECK
		SX3->X3_TRIGGER															, ; //X3_TRIGGER
		SX3->X3_PROPRI															, ; //X3_PROPRI
		SX3->X3_BROWSE															, ; //X3_BROWSE
		SX3->X3_VISUAL															, ; //X3_VISUAL
		SX3->X3_CONTEXT															, ; //X3_CONTEXT
		SX3->X3_OBRIGAT    														, ; //X3_OBRIGAT
		SX3->X3_VLDUSER                                                         , ; //X3_VLDUSER
		SX3->X3_CBOX															, ; //X3_CBOX
		SX3->X3_CBOXSPA															, ; //X3_CBOXSPA
		SX3->X3_CBOXENG															, ; //X3_CBOXENG
		SX3->X3_PICTVAR															, ; //X3_PICTVAR
		SX3->X3_WHEN															, ; //X3_WHEN
		SX3->X3_INIBRW															, ; //X3_INIBRW
		SX3->X3_GRPSXG															, ; //X3_GRPSXG
		SX3->X3_FOLDER  														, ; //X3_FOLDER
		SX3->X3_PYME															} ) //X3_PYME
	EndIf


	SX3->(DbSetOrder(2))
	If SX3->(dbSeek("UC_CHAORIG"))
		
		aAdd( aSX3, { ;
		'SUC'																	, ; //X3_ARQUIVO
		SX3->X3_ORDEM															, ; //X3_ORDEM
		'UC_CHAORIG'   															, ; //X3_CAMPO
		SX3->X3_TIPO															, ; //X3_TIPO
		SX3->X3_TAMANHO															, ; //X3_TAMANHO
		SX3->X3_DECIMAL															, ; //X3_DECIMAL
		SX3->X3_TITULO															, ; //X3_TITULO
		SX3->X3_TITSPA															, ; //X3_TITSPA
		SX3->X3_TITENG															, ; //X3_TITENG
		SX3->X3_DESCRIC															, ; //X3_DESCRIC
		SX3->X3_DESCSPA															, ; //X3_DESCSPA
		SX3->X3_DESCENG															, ; //X3_DESCENG
		SX3->X3_PICTURE															, ; //X3_PICTURE
		SX3->X3_VALID															, ; //X3_VALID
		SX3->X3_USADO															, ; //X3_USADO
		SX3->X3_RELACAO 														, ; //X3_RELACAO
		SX3->X3_F3																, ; //X3_F3
		9																		, ; //X3_NIVEL
		SX3->X3_RESERV															, ; //X3_RESERV
		SX3->X3_CHECK															, ; //X3_CHECK
		SX3->X3_TRIGGER															, ; //X3_TRIGGER
		SX3->X3_PROPRI															, ; //X3_PROPRI
		SX3->X3_BROWSE															, ; //X3_BROWSE
		SX3->X3_VISUAL															, ; //X3_VISUAL
		SX3->X3_CONTEXT															, ; //X3_CONTEXT
		SX3->X3_OBRIGAT    														, ; //X3_OBRIGAT
		SX3->X3_VLDUSER                                                         , ; //X3_VLDUSER
		SX3->X3_CBOX															, ; //X3_CBOX
		SX3->X3_CBOXSPA															, ; //X3_CBOXSPA
		SX3->X3_CBOXENG															, ; //X3_CBOXENG
		SX3->X3_PICTVAR															, ; //X3_PICTVAR
		SX3->X3_WHEN															, ; //X3_WHEN
		SX3->X3_INIBRW															, ; //X3_INIBRW
		SX3->X3_GRPSXG															, ; //X3_GRPSXG
		SX3->X3_FOLDER  														, ; //X3_FOLDER
		SX3->X3_PYME															} ) //X3_PYME
	EndIf

	SX3->(DbSetOrder(2))
	If SX3->(dbSeek("UC_ITCHAOR"))
		
		aAdd( aSX3, { ;
		'SUC'																	, ; //X3_ARQUIVO
		SX3->X3_ORDEM															, ; //X3_ORDEM
		'UC_ITCHAOR'   															, ; //X3_CAMPO
		SX3->X3_TIPO															, ; //X3_TIPO
		SX3->X3_TAMANHO															, ; //X3_TAMANHO
		SX3->X3_DECIMAL															, ; //X3_DECIMAL
		SX3->X3_TITULO															, ; //X3_TITULO
		SX3->X3_TITSPA															, ; //X3_TITSPA
		SX3->X3_TITENG															, ; //X3_TITENG
		SX3->X3_DESCRIC															, ; //X3_DESCRIC
		SX3->X3_DESCSPA															, ; //X3_DESCSPA
		SX3->X3_DESCENG															, ; //X3_DESCENG
		SX3->X3_PICTURE															, ; //X3_PICTURE
		SX3->X3_VALID															, ; //X3_VALID
		SX3->X3_USADO															, ; //X3_USADO
		SX3->X3_RELACAO 														, ; //X3_RELACAO
		SX3->X3_F3																, ; //X3_F3
		9																		, ; //X3_NIVEL
		SX3->X3_RESERV															, ; //X3_RESERV
		SX3->X3_CHECK															, ; //X3_CHECK
		SX3->X3_TRIGGER															, ; //X3_TRIGGER
		SX3->X3_PROPRI															, ; //X3_PROPRI
		SX3->X3_BROWSE															, ; //X3_BROWSE
		SX3->X3_VISUAL															, ; //X3_VISUAL
		SX3->X3_CONTEXT															, ; //X3_CONTEXT
		SX3->X3_OBRIGAT    														, ; //X3_OBRIGAT
		SX3->X3_VLDUSER                                                         , ; //X3_VLDUSER
		SX3->X3_CBOX															, ; //X3_CBOX
		SX3->X3_CBOXSPA															, ; //X3_CBOXSPA
		SX3->X3_CBOXENG															, ; //X3_CBOXENG
		SX3->X3_PICTVAR															, ; //X3_PICTVAR
		SX3->X3_WHEN															, ; //X3_WHEN
		SX3->X3_INIBRW															, ; //X3_INIBRW
		SX3->X3_GRPSXG															, ; //X3_GRPSXG
		SX3->X3_FOLDER  														, ; //X3_FOLDER
		SX3->X3_PYME															} ) //X3_PYME
	EndIf         
	
	SX3->(DbSetOrder(2))
	If SX3->(dbSeek("UC_CLIENTE"))
		
		aAdd( aSX3, { ;
		'SUC'																	, ; //X3_ARQUIVO
		SX3->X3_ORDEM															, ; //X3_ORDEM
		'UC_CLIENTE'   															, ; //X3_CAMPO
		SX3->X3_TIPO															, ; //X3_TIPO
		SX3->X3_TAMANHO															, ; //X3_TAMANHO
		SX3->X3_DECIMAL															, ; //X3_DECIMAL
		SX3->X3_TITULO															, ; //X3_TITULO
		SX3->X3_TITSPA															, ; //X3_TITSPA
		SX3->X3_TITENG															, ; //X3_TITENG
		SX3->X3_DESCRIC															, ; //X3_DESCRIC
		SX3->X3_DESCSPA															, ; //X3_DESCSPA
		SX3->X3_DESCENG															, ; //X3_DESCENG
		SX3->X3_PICTURE															, ; //X3_PICTURE
		SX3->X3_VALID															, ; //X3_VALID
		SX3->X3_USADO															, ; //X3_USADO
		'IIF(!INCLUI,Posicione("SU5",1,xFilial("SU5") + SUC->UC_CODCONT, "U5_CLIENTE"),"")', ; //X3_RELACAO
		SX3->X3_F3																, ; //X3_F3
		1																		, ; //X3_NIVEL
		SX3->X3_RESERV															, ; //X3_RESERV
		SX3->X3_CHECK															, ; //X3_CHECK
		SX3->X3_TRIGGER															, ; //X3_TRIGGER
		SX3->X3_PROPRI															, ; //X3_PROPRI
		SX3->X3_BROWSE															, ; //X3_BROWSE
		'V'																		, ; //X3_VISUAL
		SX3->X3_CONTEXT															, ; //X3_CONTEXT
		SX3->X3_OBRIGAT    														, ; //X3_OBRIGAT
		SX3->X3_VLDUSER                                                         , ; //X3_VLDUSER
		SX3->X3_CBOX															, ; //X3_CBOX
		SX3->X3_CBOXSPA															, ; //X3_CBOXSPA
		SX3->X3_CBOXENG															, ; //X3_CBOXENG
		SX3->X3_PICTVAR															, ; //X3_PICTVAR
		SX3->X3_WHEN															, ; //X3_WHEN
		'Posicione("SU5",1,xFilial("SU5") + SUC->UC_CODCONT, "U5_CLIENTE")' 	, ; //X3_INIBRW
		SX3->X3_GRPSXG															, ; //X3_GRPSXG
		SX3->X3_FOLDER  														, ; //X3_FOLDER
		SX3->X3_PYME															} ) //X3_PYME
	EndIf         	

	SX3->(DbSetOrder(2))
	If SX3->(dbSeek("UC_LOJA"))
		
		aAdd( aSX3, { ;
		'SUC'																	, ; //X3_ARQUIVO
		SX3->X3_ORDEM															, ; //X3_ORDEM
		'UC_LOJA'   															, ; //X3_CAMPO
		SX3->X3_TIPO															, ; //X3_TIPO
		SX3->X3_TAMANHO															, ; //X3_TAMANHO
		SX3->X3_DECIMAL															, ; //X3_DECIMAL
		SX3->X3_TITULO															, ; //X3_TITULO
		SX3->X3_TITSPA															, ; //X3_TITSPA
		SX3->X3_TITENG															, ; //X3_TITENG
		SX3->X3_DESCRIC															, ; //X3_DESCRIC
		SX3->X3_DESCSPA															, ; //X3_DESCSPA
		SX3->X3_DESCENG															, ; //X3_DESCENG
		SX3->X3_PICTURE															, ; //X3_PICTURE
		SX3->X3_VALID															, ; //X3_VALID
		SX3->X3_USADO															, ; //X3_USADO
		'IIF(!INCLUI,Posicione("SU5",1,xFilial("SU5") + SUC->UC_CODCONT, "U5_LOJA"),"")', ; //X3_RELACAO
		SX3->X3_F3																, ; //X3_F3
		1																		, ; //X3_NIVEL
		SX3->X3_RESERV															, ; //X3_RESERV
		SX3->X3_CHECK															, ; //X3_CHECK
		'S'																		, ; //X3_TRIGGER
		SX3->X3_PROPRI															, ; //X3_PROPRI
		SX3->X3_BROWSE															, ; //X3_BROWSE
		'V'																		, ; //X3_VISUAL
		'R'																		, ; //X3_CONTEXT
		SX3->X3_OBRIGAT    														, ; //X3_OBRIGAT
		SX3->X3_VLDUSER                                                         , ; //X3_VLDUSER
		SX3->X3_CBOX															, ; //X3_CBOX
		SX3->X3_CBOXSPA															, ; //X3_CBOXSPA
		SX3->X3_CBOXENG															, ; //X3_CBOXENG
		SX3->X3_PICTVAR															, ; //X3_PICTVAR
		SX3->X3_WHEN															, ; //X3_WHEN
		'Posicione("SU5",1,xFilial("SU5") + SUC->UC_CODCONT, "U5_LOJA")'	 	, ; //X3_INIBRW
		SX3->X3_GRPSXG															, ; //X3_GRPSXG
		SX3->X3_FOLDER  														, ; //X3_FOLDER
		SX3->X3_PYME															} ) //X3_PYME
	EndIf         	
	      

	SX3->(DbSetOrder(2))
	If SX3->(dbSeek("UC_DATA"))
		
		aAdd( aSX3, { ;
		'SUC'																	, ; //X3_ARQUIVO
		SX3->X3_ORDEM															, ; //X3_ORDEM
		'UC_DATA'   															, ; //X3_CAMPO
		SX3->X3_TIPO															, ; //X3_TIPO
		SX3->X3_TAMANHO															, ; //X3_TAMANHO
		SX3->X3_DECIMAL															, ; //X3_DECIMAL
		SX3->X3_TITULO															, ; //X3_TITULO
		SX3->X3_TITSPA															, ; //X3_TITSPA
		SX3->X3_TITENG															, ; //X3_TITENG
		SX3->X3_DESCRIC															, ; //X3_DESCRIC
		SX3->X3_DESCSPA															, ; //X3_DESCSPA
		SX3->X3_DESCENG															, ; //X3_DESCENG
		SX3->X3_PICTURE															, ; //X3_PICTURE
		SX3->X3_VALID															, ; //X3_VALID
		SX3->X3_USADO															, ; //X3_USADO
		SX3->X3_RELACAO 														, ; //X3_RELACAO
		SX3->X3_F3																, ; //X3_F3
		SX3->X3_NIVEL															, ; //X3_NIVEL
		SX3->X3_RESERV															, ; //X3_RESERV
		SX3->X3_CHECK															, ; //X3_CHECK
		SX3->X3_TRIGGER															, ; //X3_TRIGGER
		SX3->X3_PROPRI															, ; //X3_PROPRI
		SX3->X3_BROWSE															, ; //X3_BROWSE
		'V'																		, ; //X3_VISUAL
		SX3->X3_CONTEXT															, ; //X3_CONTEXT
		SX3->X3_OBRIGAT    														, ; //X3_OBRIGAT
		SX3->X3_VLDUSER                                                         , ; //X3_VLDUSER
		SX3->X3_CBOX															, ; //X3_CBOX
		SX3->X3_CBOXSPA															, ; //X3_CBOXSPA
		SX3->X3_CBOXENG															, ; //X3_CBOXENG
		SX3->X3_PICTVAR															, ; //X3_PICTVAR
		SX3->X3_WHEN															, ; //X3_WHEN
		SX3->X3_INIBRW															, ; //X3_INIBRW
		SX3->X3_GRPSXG															, ; //X3_GRPSXG
		SX3->X3_FOLDER  														, ; //X3_FOLDER
		SX3->X3_PYME															} ) //X3_PYME
	EndIf         
	
	SX3->(DbSetOrder(2))
	If SX3->(dbSeek("UC_OPERADO"))
		
		aAdd( aSX3, { ;
		'SUC'																	, ; //X3_ARQUIVO
		SX3->X3_ORDEM															, ; //X3_ORDEM
		'UC_OPERADO'   															, ; //X3_CAMPO
		SX3->X3_TIPO															, ; //X3_TIPO
		SX3->X3_TAMANHO															, ; //X3_TAMANHO
		SX3->X3_DECIMAL															, ; //X3_DECIMAL
		SX3->X3_TITULO															, ; //X3_TITULO
		SX3->X3_TITSPA															, ; //X3_TITSPA
		SX3->X3_TITENG															, ; //X3_TITENG
		SX3->X3_DESCRIC															, ; //X3_DESCRIC
		SX3->X3_DESCSPA															, ; //X3_DESCSPA
		SX3->X3_DESCENG															, ; //X3_DESCENG
		SX3->X3_PICTURE															, ; //X3_PICTURE
		SX3->X3_VALID															, ; //X3_VALID
		SX3->X3_USADO															, ; //X3_USADO
		SX3->X3_RELACAO 														, ; //X3_RELACAO
		SX3->X3_F3																, ; //X3_F3
		SX3->X3_NIVEL															, ; //X3_NIVEL
		SX3->X3_RESERV															, ; //X3_RESERV
		SX3->X3_CHECK															, ; //X3_CHECK
		SX3->X3_TRIGGER															, ; //X3_TRIGGER
		SX3->X3_PROPRI															, ; //X3_PROPRI
		SX3->X3_BROWSE															, ; //X3_BROWSE
		'V'		   																, ; //X3_VISUAL
		SX3->X3_CONTEXT															, ; //X3_CONTEXT
		SX3->X3_OBRIGAT    														, ; //X3_OBRIGAT
		SX3->X3_VLDUSER                                                         , ; //X3_VLDUSER
		SX3->X3_CBOX															, ; //X3_CBOX
		SX3->X3_CBOXSPA															, ; //X3_CBOXSPA
		SX3->X3_CBOXENG															, ; //X3_CBOXENG
		SX3->X3_PICTVAR															, ; //X3_PICTVAR
		SX3->X3_WHEN															, ; //X3_WHEN
		SX3->X3_INIBRW															, ; //X3_INIBRW
		SX3->X3_GRPSXG															, ; //X3_GRPSXG
		SX3->X3_FOLDER  														, ; //X3_FOLDER
		SX3->X3_PYME															} ) //X3_PYME
	EndIf         

	SX3->(DbSetOrder(2))
	If SX3->(dbSeek("UC_CODCONT"))
		
		aAdd( aSX3, { ;
		'SUC'																	, ; //X3_ARQUIVO
		SX3->X3_ORDEM															, ; //X3_ORDEM
		'UC_CODCONT'   															, ; //X3_CAMPO
		SX3->X3_TIPO															, ; //X3_TIPO
		SX3->X3_TAMANHO															, ; //X3_TAMANHO
		SX3->X3_DECIMAL															, ; //X3_DECIMAL
		SX3->X3_TITULO															, ; //X3_TITULO
		SX3->X3_TITSPA															, ; //X3_TITSPA
		SX3->X3_TITENG															, ; //X3_TITENG
		SX3->X3_DESCRIC															, ; //X3_DESCRIC
		SX3->X3_DESCSPA															, ; //X3_DESCSPA
		SX3->X3_DESCENG															, ; //X3_DESCENG
		SX3->X3_PICTURE															, ; //X3_PICTURE
		SX3->X3_VALID															, ; //X3_VALID
		SX3->X3_USADO															, ; //X3_USADO
		SX3->X3_RELACAO 														, ; //X3_RELACAO
		SX3->X3_F3																, ; //X3_F3
		SX3->X3_NIVEL 															, ; //X3_NIVEL
		SX3->X3_RESERV															, ; //X3_RESERV
		SX3->X3_CHECK															, ; //X3_CHECK
		SX3->X3_TRIGGER															, ; //X3_TRIGGER
		SX3->X3_PROPRI															, ; //X3_PROPRI
		SX3->X3_BROWSE															, ; //X3_BROWSE
		SX3->X3_VISUAL															, ; //X3_VISUAL
		SX3->X3_CONTEXT															, ; //X3_CONTEXT
		SX3->X3_OBRIGAT    														, ; //X3_OBRIGAT
		'U_VldCliSuc()'                                                         , ; //X3_VLDUSER
		SX3->X3_CBOX															, ; //X3_CBOX
		SX3->X3_CBOXSPA															, ; //X3_CBOXSPA
		SX3->X3_CBOXENG															, ; //X3_CBOXENG
		SX3->X3_PICTVAR															, ; //X3_PICTVAR
		SX3->X3_WHEN															, ; //X3_WHEN
		SX3->X3_INIBRW															, ; //X3_INIBRW
		SX3->X3_GRPSXG															, ; //X3_GRPSXG
		SX3->X3_FOLDER  														, ; //X3_FOLDER
		SX3->X3_PYME															} ) //X3_PYME
	EndIf						
	
//
//TABELA SUD
//	

	SX3->(DbSetOrder(2))
	If SX3->(dbSeek("UD_NSERIE"))
		
		aAdd( aSX3, { ;
		'SUD'																	, ; //X3_ARQUIVO
		SX3->X3_ORDEM															, ; //X3_ORDEM
		'UD_NSERIE'   															, ; //X3_CAMPO
		SX3->X3_TIPO															, ; //X3_TIPO
		SX3->X3_TAMANHO															, ; //X3_TAMANHO
		SX3->X3_DECIMAL															, ; //X3_DECIMAL
		SX3->X3_TITULO															, ; //X3_TITULO
		SX3->X3_TITSPA															, ; //X3_TITSPA
		SX3->X3_TITENG															, ; //X3_TITENG
		SX3->X3_DESCRIC															, ; //X3_DESCRIC
		SX3->X3_DESCSPA															, ; //X3_DESCSPA
		SX3->X3_DESCENG															, ; //X3_DESCENG
		SX3->X3_PICTURE															, ; //X3_PICTURE
		SX3->X3_VALID															, ; //X3_VALID
		SX3->X3_USADO															, ; //X3_USADO
		SX3->X3_RELACAO 														, ; //X3_RELACAO
		SX3->X3_F3																, ; //X3_F3
		SX3->X3_NIVEL															, ; //X3_NIVEL
		SX3->X3_RESERV															, ; //X3_RESERV
		SX3->X3_CHECK															, ; //X3_CHECK
		SX3->X3_TRIGGER															, ; //X3_TRIGGER
		SX3->X3_PROPRI															, ; //X3_PROPRI
		SX3->X3_BROWSE															, ; //X3_BROWSE
		'V'																		, ; //X3_VISUAL
		SX3->X3_CONTEXT															, ; //X3_CONTEXT
		SX3->X3_OBRIGAT    														, ; //X3_OBRIGAT
		SX3->X3_VLDUSER                                                         , ; //X3_VLDUSER
		SX3->X3_CBOX															, ; //X3_CBOX
		SX3->X3_CBOXSPA															, ; //X3_CBOXSPA
		SX3->X3_CBOXENG															, ; //X3_CBOXENG
		SX3->X3_PICTVAR															, ; //X3_PICTVAR
		SX3->X3_WHEN															, ; //X3_WHEN
		SX3->X3_INIBRW															, ; //X3_INIBRW
		SX3->X3_GRPSXG															, ; //X3_GRPSXG
		SX3->X3_FOLDER  														, ; //X3_FOLDER
		SX3->X3_PYME															} ) //X3_PYME
	EndIf         
	
	SX3->(DbSetOrder(2))
	If SX3->(dbSeek("UD_GRADE"))
		
		aAdd( aSX3, { ;
		'SUD'																	, ; //X3_ARQUIVO
		SX3->X3_ORDEM															, ; //X3_ORDEM
		'UD_GRADE'   															, ; //X3_CAMPO
		SX3->X3_TIPO															, ; //X3_TIPO
		SX3->X3_TAMANHO															, ; //X3_TAMANHO
		SX3->X3_DECIMAL															, ; //X3_DECIMAL
		SX3->X3_TITULO															, ; //X3_TITULO
		SX3->X3_TITSPA															, ; //X3_TITSPA
		SX3->X3_TITENG															, ; //X3_TITENG
		SX3->X3_DESCRIC															, ; //X3_DESCRIC
		SX3->X3_DESCSPA															, ; //X3_DESCSPA
		SX3->X3_DESCENG															, ; //X3_DESCENG
		SX3->X3_PICTURE															, ; //X3_PICTURE
		SX3->X3_VALID															, ; //X3_VALID
		SX3->X3_USADO															, ; //X3_USADO
		SX3->X3_RELACAO 														, ; //X3_RELACAO
		SX3->X3_F3																, ; //X3_F3
		SX3->X3_NIVEL															, ; //X3_NIVEL
		SX3->X3_RESERV															, ; //X3_RESERV
		SX3->X3_CHECK															, ; //X3_CHECK
		SX3->X3_TRIGGER															, ; //X3_TRIGGER
		SX3->X3_PROPRI															, ; //X3_PROPRI
		SX3->X3_BROWSE															, ; //X3_BROWSE
		'V'																		, ; //X3_VISUAL
		SX3->X3_CONTEXT															, ; //X3_CONTEXT
		SX3->X3_OBRIGAT    														, ; //X3_OBRIGAT
		SX3->X3_VLDUSER                                                         , ; //X3_VLDUSER
		SX3->X3_CBOX															, ; //X3_CBOX
		SX3->X3_CBOXSPA															, ; //X3_CBOXSPA
		SX3->X3_CBOXENG															, ; //X3_CBOXENG
		SX3->X3_PICTVAR															, ; //X3_PICTVAR
		SX3->X3_WHEN															, ; //X3_WHEN
		SX3->X3_INIBRW															, ; //X3_INIBRW
		SX3->X3_GRPSXG															, ; //X3_GRPSXG
		SX3->X3_FOLDER  														, ; //X3_FOLDER
		SX3->X3_PYME															} ) //X3_PYME
	EndIf         
	
	SX3->(DbSetOrder(2))
	If SX3->(dbSeek("UD_EVENTO"))
		
		aAdd( aSX3, { ;
		'SUD'																	, ; //X3_ARQUIVO
		SX3->X3_ORDEM															, ; //X3_ORDEM
		'UD_EVENTO'   															, ; //X3_CAMPO
		SX3->X3_TIPO															, ; //X3_TIPO
		SX3->X3_TAMANHO															, ; //X3_TAMANHO
		SX3->X3_DECIMAL															, ; //X3_DECIMAL
		SX3->X3_TITULO															, ; //X3_TITULO
		SX3->X3_TITSPA															, ; //X3_TITSPA
		SX3->X3_TITENG															, ; //X3_TITENG
		SX3->X3_DESCRIC															, ; //X3_DESCRIC
		SX3->X3_DESCSPA															, ; //X3_DESCSPA
		SX3->X3_DESCENG															, ; //X3_DESCENG
		SX3->X3_PICTURE															, ; //X3_PICTURE
		SX3->X3_VALID															, ; //X3_VALID
		SX3->X3_USADO															, ; //X3_USADO
		SX3->X3_RELACAO 														, ; //X3_RELACAO
		SX3->X3_F3																, ; //X3_F3
		SX3->X3_NIVEL															, ; //X3_NIVEL
		SX3->X3_RESERV															, ; //X3_RESERV
		SX3->X3_CHECK															, ; //X3_CHECK
		SX3->X3_TRIGGER															, ; //X3_TRIGGER
		SX3->X3_PROPRI															, ; //X3_PROPRI
		SX3->X3_BROWSE															, ; //X3_BROWSE
		'V'																		, ; //X3_VISUAL
		SX3->X3_CONTEXT															, ; //X3_CONTEXT
		SX3->X3_OBRIGAT    														, ; //X3_OBRIGAT
		SX3->X3_VLDUSER                                                         , ; //X3_VLDUSER
		SX3->X3_CBOX															, ; //X3_CBOX
		SX3->X3_CBOXSPA															, ; //X3_CBOXSPA
		SX3->X3_CBOXENG															, ; //X3_CBOXENG
		SX3->X3_PICTVAR															, ; //X3_PICTVAR
		SX3->X3_WHEN															, ; //X3_WHEN
		SX3->X3_INIBRW															, ; //X3_INIBRW
		SX3->X3_GRPSXG															, ; //X3_GRPSXG
		SX3->X3_FOLDER  														, ; //X3_FOLDER
		SX3->X3_PYME															} ) //X3_PYME
	EndIf         
  
//
//TABELA SU9
// 
            
 	SX3->(DbSetOrder(2))
	If SX3->(dbSeek("U9_TIPOOCO"))
		
		aAdd( aSX3, { ;
		'SU9'																	, ; //X3_ARQUIVO
		SX3->X3_ORDEM															, ; //X3_ORDEM
		'U9_TIPOOCO'															, ; //X3_CAMPO
		SX3->X3_TIPO															, ; //X3_TIPO
		SX3->X3_TAMANHO															, ; //X3_TAMANHO
		SX3->X3_DECIMAL															, ; //X3_DECIMAL
		SX3->X3_TITULO															, ; //X3_TITULO
		SX3->X3_TITSPA															, ; //X3_TITSPA
		SX3->X3_TITENG															, ; //X3_TITENG
		SX3->X3_DESCRIC															, ; //X3_DESCRIC
		SX3->X3_DESCSPA															, ; //X3_DESCSPA
		SX3->X3_DESCENG															, ; //X3_DESCENG
		SX3->X3_PICTURE															, ; //X3_PICTURE
		SX3->X3_VALID															, ; //X3_VALID
		SX3->X3_USADO															, ; //X3_USADO
		SX3->X3_RELACAO 														, ; //X3_RELACAO
		SX3->X3_F3																, ; //X3_F3
		SX3->X3_NIVEL															, ; //X3_NIVEL
		'˛A'																	, ; //X3_RESERV
		SX3->X3_CHECK															, ; //X3_CHECK
		SX3->X3_TRIGGER															, ; //X3_TRIGGER
		SX3->X3_PROPRI															, ; //X3_PROPRI
		SX3->X3_BROWSE															, ; //X3_BROWSE
		SX3->X3_VISUAL															, ; //X3_VISUAL
		SX3->X3_CONTEXT															, ; //X3_CONTEXT
		SX3->X3_OBRIGAT    														, ; //X3_OBRIGAT
		SX3->X3_VLDUSER                                                         , ; //X3_VLDUSER
		SX3->X3_CBOX															, ; //X3_CBOX
		SX3->X3_CBOXSPA															, ; //X3_CBOXSPA
		SX3->X3_CBOXENG															, ; //X3_CBOXENG
		SX3->X3_PICTVAR															, ; //X3_PICTVAR
		SX3->X3_WHEN															, ; //X3_WHEN
		SX3->X3_INIBRW															, ; //X3_INIBRW
		SX3->X3_GRPSXG															, ; //X3_GRPSXG
		SX3->X3_FOLDER  														, ; //X3_FOLDER
		SX3->X3_PYME															} ) //X3_PYME
	EndIf         
 
 	SX3->(DbSetOrder(2))
	If SX3->(dbSeek("U9_DESTPOC"))
		
		aAdd( aSX3, { ;
		'SU9'																	, ; //X3_ARQUIVO
		SX3->X3_ORDEM															, ; //X3_ORDEM
		'U9_DESTPOC'															, ; //X3_CAMPO
		SX3->X3_TIPO															, ; //X3_TIPO
		SX3->X3_TAMANHO															, ; //X3_TAMANHO
		SX3->X3_DECIMAL															, ; //X3_DECIMAL
		SX3->X3_TITULO															, ; //X3_TITULO
		SX3->X3_TITSPA															, ; //X3_TITSPA
		SX3->X3_TITENG															, ; //X3_TITENG
		SX3->X3_DESCRIC															, ; //X3_DESCRIC
		SX3->X3_DESCSPA															, ; //X3_DESCSPA
		SX3->X3_DESCENG															, ; //X3_DESCENG
		SX3->X3_PICTURE															, ; //X3_PICTURE
		SX3->X3_VALID															, ; //X3_VALID
		SX3->X3_USADO															, ; //X3_USADO
		SX3->X3_RELACAO 														, ; //X3_RELACAO
		SX3->X3_F3																, ; //X3_F3
		SX3->X3_NIVEL															, ; //X3_NIVEL
		'˛A'																	, ; //X3_RESERV
		SX3->X3_CHECK															, ; //X3_CHECK
		SX3->X3_TRIGGER															, ; //X3_TRIGGER
		SX3->X3_PROPRI															, ; //X3_PROPRI
		SX3->X3_BROWSE															, ; //X3_BROWSE
		SX3->X3_VISUAL															, ; //X3_VISUAL
		SX3->X3_CONTEXT															, ; //X3_CONTEXT
		SX3->X3_OBRIGAT    														, ; //X3_OBRIGAT
		SX3->X3_VLDUSER                                                         , ; //X3_VLDUSER
		SX3->X3_CBOX															, ; //X3_CBOX
		SX3->X3_CBOXSPA															, ; //X3_CBOXSPA
		SX3->X3_CBOXENG															, ; //X3_CBOXENG
		SX3->X3_PICTVAR															, ; //X3_PICTVAR
		SX3->X3_WHEN															, ; //X3_WHEN
		SX3->X3_INIBRW															, ; //X3_INIBRW
		SX3->X3_GRPSXG															, ; //X3_GRPSXG
		SX3->X3_FOLDER  														, ; //X3_FOLDER
		SX3->X3_PYME															} ) //X3_PYME
	EndIf         

 	SX3->(DbSetOrder(2))
	If SX3->(dbSeek("UQ_CODRESP"))
		
		aAdd( aSX3, { ;
		'SUQ'																	, ; //X3_ARQUIVO
		SX3->X3_ORDEM															, ; //X3_ORDEM
		'UQ_CODRESP'															, ; //X3_CAMPO
		SX3->X3_TIPO															, ; //X3_TIPO
		SX3->X3_TAMANHO															, ; //X3_TAMANHO
		SX3->X3_DECIMAL															, ; //X3_DECIMAL
		SX3->X3_TITULO															, ; //X3_TITULO
		SX3->X3_TITSPA															, ; //X3_TITSPA
		SX3->X3_TITENG															, ; //X3_TITENG
		SX3->X3_DESCRIC															, ; //X3_DESCRIC
		SX3->X3_DESCSPA															, ; //X3_DESCSPA
		SX3->X3_DESCENG															, ; //X3_DESCENG
		SX3->X3_PICTURE															, ; //X3_PICTURE
		SX3->X3_VALID															, ; //X3_VALID
		SX3->X3_USADO															, ; //X3_USADO
		SX3->X3_RELACAO 														, ; //X3_RELACAO
		SX3->X3_F3																, ; //X3_F3
		SX3->X3_NIVEL															, ; //X3_NIVEL
		'CÄ'																	, ; //X3_RESERV
		SX3->X3_CHECK															, ; //X3_CHECK
		SX3->X3_TRIGGER															, ; //X3_TRIGGER
		SX3->X3_PROPRI															, ; //X3_PROPRI
		SX3->X3_BROWSE															, ; //X3_BROWSE
		SX3->X3_VISUAL															, ; //X3_VISUAL
		SX3->X3_CONTEXT															, ; //X3_CONTEXT
		SX3->X3_OBRIGAT    														, ; //X3_OBRIGAT
		SX3->X3_VLDUSER                                                         , ; //X3_VLDUSER
		SX3->X3_CBOX															, ; //X3_CBOX
		SX3->X3_CBOXSPA															, ; //X3_CBOXSPA
		SX3->X3_CBOXENG															, ; //X3_CBOXENG
		SX3->X3_PICTVAR															, ; //X3_PICTVAR
		SX3->X3_WHEN															, ; //X3_WHEN
		SX3->X3_INIBRW															, ; //X3_INIBRW
		SX3->X3_GRPSXG															, ; //X3_GRPSXG
		SX3->X3_FOLDER  														, ; //X3_FOLDER
		SX3->X3_PYME															} ) //X3_PYME
	EndIf         


 
//
//TABELA SU5
//
	     
	SX3->(DbSetOrder(2))
	If SX3->(dbSeek("U5_LOJA"))
		
		aAdd( aSX3, { ;
		'SU5'																	, ; //X3_ARQUIVO
		SX3->X3_ORDEM															, ; //X3_ORDEM
		'U5_LOJA'   															, ; //X3_CAMPO
		SX3->X3_TIPO															, ; //X3_TIPO
		SX3->X3_TAMANHO															, ; //X3_TAMANHO
		SX3->X3_DECIMAL															, ; //X3_DECIMAL
		SX3->X3_TITULO															, ; //X3_TITULO
		SX3->X3_TITSPA															, ; //X3_TITSPA
		SX3->X3_TITENG															, ; //X3_TITENG
		SX3->X3_DESCRIC															, ; //X3_DESCRIC
		SX3->X3_DESCSPA															, ; //X3_DESCSPA
		SX3->X3_DESCENG															, ; //X3_DESCENG
		SX3->X3_PICTURE															, ; //X3_PICTURE
		SX3->X3_VALID															, ; //X3_VALID
		SX3->X3_USADO															, ; //X3_USADO
		SX3->X3_RELACAO 														, ; //X3_RELACAO
		SX3->X3_F3																, ; //X3_F3
		SX3->X3_NIVEL															, ; //X3_NIVEL
		SX3->X3_RESERV															, ; //X3_RESERV
		SX3->X3_CHECK															, ; //X3_CHECK
		SX3->X3_TRIGGER															, ; //X3_TRIGGER
		SX3->X3_PROPRI															, ; //X3_PROPRI
		SX3->X3_BROWSE															, ; //X3_BROWSE
		SX3->X3_VISUAL															, ; //X3_VISUAL
		SX3->X3_CONTEXT															, ; //X3_CONTEXT
		SX3->X3_OBRIGAT    														, ; //X3_OBRIGAT
		SX3->X3_VLDUSER                                                         , ; //X3_VLDUSER
		SX3->X3_CBOX															, ; //X3_CBOX
		SX3->X3_CBOXSPA															, ; //X3_CBOXSPA
		SX3->X3_CBOXENG															, ; //X3_CBOXENG
		SX3->X3_PICTVAR															, ; //X3_PICTVAR
		SX3->X3_WHEN															, ; //X3_WHEN
		SX3->X3_INIBRW															, ; //X3_INIBRW
		SX3->X3_GRPSXG															, ; //X3_GRPSXG
		'1'				  														, ; //X3_FOLDER
		SX3->X3_PYME															} ) //X3_PYME
	EndIf         
         
	SX3->(DbSetOrder(2))
	If SX3->(dbSeek("U5_EMAIL"))
		
		aAdd( aSX3, { ;
		'SU5'																	, ; //X3_ARQUIVO
		SX3->X3_ORDEM															, ; //X3_ORDEM
		'U5_EMAIL'   															, ; //X3_CAMPO
		SX3->X3_TIPO															, ; //X3_TIPO
		100																		, ; //X3_TAMANHO
		SX3->X3_DECIMAL															, ; //X3_DECIMAL
		SX3->X3_TITULO															, ; //X3_TITULO
		SX3->X3_TITSPA															, ; //X3_TITSPA
		SX3->X3_TITENG															, ; //X3_TITENG
		SX3->X3_DESCRIC															, ; //X3_DESCRIC
		SX3->X3_DESCSPA															, ; //X3_DESCSPA
		SX3->X3_DESCENG															, ; //X3_DESCENG
		SX3->X3_PICTURE															, ; //X3_PICTURE
		SX3->X3_VALID															, ; //X3_VALID
		SX3->X3_USADO															, ; //X3_USADO
		SX3->X3_RELACAO 														, ; //X3_RELACAO
		SX3->X3_F3																, ; //X3_F3
		SX3->X3_NIVEL															, ; //X3_NIVEL
		SX3->X3_RESERV															, ; //X3_RESERV
		SX3->X3_CHECK															, ; //X3_CHECK
		SX3->X3_TRIGGER															, ; //X3_TRIGGER
		SX3->X3_PROPRI															, ; //X3_PROPRI
		SX3->X3_BROWSE															, ; //X3_BROWSE
		SX3->X3_VISUAL															, ; //X3_VISUAL
		SX3->X3_CONTEXT															, ; //X3_CONTEXT
		SX3->X3_OBRIGAT    														, ; //X3_OBRIGAT
		SX3->X3_VLDUSER                                                         , ; //X3_VLDUSER
		SX3->X3_CBOX															, ; //X3_CBOX
		SX3->X3_CBOXSPA															, ; //X3_CBOXSPA
		SX3->X3_CBOXENG															, ; //X3_CBOXENG
		SX3->X3_PICTVAR															, ; //X3_PICTVAR
		SX3->X3_WHEN															, ; //X3_WHEN
		SX3->X3_INIBRW															, ; //X3_INIBRW
		SX3->X3_GRPSXG															, ; //X3_GRPSXG
		SX3->X3_FOLDER	  														, ; //X3_FOLDER
		SX3->X3_PYME															} ) //X3_PYME
	EndIf         
         
	SX3->(DbSetOrder(2))
	If SX3->(dbSeek("U5_CONTAT"))
		
		aAdd( aSX3, { ;
		'SU5'																	, ; //X3_ARQUIVO
		SX3->X3_ORDEM															, ; //X3_ORDEM
		'U5_CONTAT'   															, ; //X3_CAMPO
		SX3->X3_TIPO															, ; //X3_TIPO
		SX3->X3_TAMANHO															, ; //X3_TAMANHO
		SX3->X3_DECIMAL															, ; //X3_DECIMAL
		SX3->X3_TITULO															, ; //X3_TITULO
		SX3->X3_TITSPA															, ; //X3_TITSPA
		SX3->X3_TITENG															, ; //X3_TITENG
		SX3->X3_DESCRIC															, ; //X3_DESCRIC
		SX3->X3_DESCSPA															, ; //X3_DESCSPA
		SX3->X3_DESCENG															, ; //X3_DESCENG
		SX3->X3_PICTURE															, ; //X3_PICTURE
		SX3->X3_VALID															, ; //X3_VALID
		SX3->X3_USADO															, ; //X3_USADO
		SX3->X3_RELACAO 														, ; //X3_RELACAO
		SX3->X3_F3																, ; //X3_F3
		SX3->X3_NIVEL															, ; //X3_NIVEL
		SX3->X3_RESERV															, ; //X3_RESERV
		SX3->X3_CHECK															, ; //X3_CHECK
		SX3->X3_TRIGGER															, ; //X3_TRIGGER
		SX3->X3_PROPRI															, ; //X3_PROPRI
		SX3->X3_BROWSE															, ; //X3_BROWSE
		SX3->X3_VISUAL															, ; //X3_VISUAL
		SX3->X3_CONTEXT															, ; //X3_CONTEXT
		SX3->X3_OBRIGAT    														, ; //X3_OBRIGAT
		SX3->X3_VLDUSER                                                         , ; //X3_VLDUSER
		SX3->X3_CBOX															, ; //X3_CBOX
		SX3->X3_CBOXSPA															, ; //X3_CBOXSPA
		SX3->X3_CBOXENG															, ; //X3_CBOXENG
		SX3->X3_PICTVAR															, ; //X3_PICTVAR
		'INCLUI .AND. EMPTY(M->U5_EMAIL)'										, ; //X3_WHEN
		SX3->X3_INIBRW															, ; //X3_INIBRW
		SX3->X3_GRPSXG															, ; //X3_GRPSXG
		SX3->X3_FOLDER	  														, ; //X3_FOLDER
		SX3->X3_PYME															} ) //X3_PYME
	EndIf         
	
//
//TABELA SC2
//
	     
	SX3->(DbSetOrder(2))
	If SX3->(dbSeek("C2_PRODUTO"))
		
		aAdd( aSX3, { ;
		'SC2'																	, ; //X3_ARQUIVO
		SX3->X3_ORDEM															, ; //X3_ORDEM
		'C2_PRODUTO'   															, ; //X3_CAMPO
		SX3->X3_TIPO															, ; //X3_TIPO
		SX3->X3_TAMANHO															, ; //X3_TAMANHO
		SX3->X3_DECIMAL															, ; //X3_DECIMAL
		SX3->X3_TITULO															, ; //X3_TITULO
		SX3->X3_TITSPA															, ; //X3_TITSPA
		SX3->X3_TITENG															, ; //X3_TITENG
		SX3->X3_DESCRIC															, ; //X3_DESCRIC
		SX3->X3_DESCSPA															, ; //X3_DESCSPA
		SX3->X3_DESCENG															, ; //X3_DESCENG
		SX3->X3_PICTURE															, ; //X3_PICTURE
		SX3->X3_VALID															, ; //X3_VALID
		SX3->X3_USADO															, ; //X3_USADO
		SX3->X3_RELACAO 														, ; //X3_RELACAO
		SX3->X3_F3																, ; //X3_F3
		SX3->X3_NIVEL															, ; //X3_NIVEL
		SX3->X3_RESERV															, ; //X3_RESERV
		SX3->X3_CHECK															, ; //X3_CHECK
		'S'																		, ; //X3_TRIGGER
		SX3->X3_PROPRI															, ; //X3_PROPRI
		SX3->X3_BROWSE															, ; //X3_BROWSE
		SX3->X3_VISUAL															, ; //X3_VISUAL
		SX3->X3_CONTEXT															, ; //X3_CONTEXT
		SX3->X3_OBRIGAT    														, ; //X3_OBRIGAT
		SX3->X3_VLDUSER                                                         , ; //X3_VLDUSER
		SX3->X3_CBOX															, ; //X3_CBOX
		SX3->X3_CBOXSPA															, ; //X3_CBOXSPA
		SX3->X3_CBOXENG															, ; //X3_CBOXENG
		SX3->X3_PICTVAR															, ; //X3_PICTVAR
		SX3->X3_WHEN															, ; //X3_WHEN
		SX3->X3_INIBRW															, ; //X3_INIBRW
		SX3->X3_GRPSXG															, ; //X3_GRPSXG
		SX3->X3_FOLDER	  														, ; //X3_FOLDER
		SX3->X3_PYME															} ) //X3_PYME
	EndIf         	
	SX3->(DbSetOrder(2))
	If SX3->(dbSeek("A2_NATUREZ"))
		
		aAdd( aSX3, { ;
		'SA2'																	, ; //X3_ARQUIVO
		SX3->X3_ORDEM															, ; //X3_ORDEM
		'A2_NATUREZ'   															, ; //X3_CAMPO
		SX3->X3_TIPO															, ; //X3_TIPO
		SX3->X3_TAMANHO															, ; //X3_TAMANHO
		SX3->X3_DECIMAL															, ; //X3_DECIMAL
		SX3->X3_TITULO															, ; //X3_TITULO
		SX3->X3_TITSPA															, ; //X3_TITSPA
		SX3->X3_TITENG															, ; //X3_TITENG
		SX3->X3_DESCRIC															, ; //X3_DESCRIC
		SX3->X3_DESCSPA															, ; //X3_DESCSPA
		SX3->X3_DESCENG															, ; //X3_DESCENG
		SX3->X3_PICTURE															, ; //X3_PICTURE
		SX3->X3_VALID															, ; //X3_VALID
		SX3->X3_USADO															, ; //X3_USADO
		SX3->X3_RELACAO 														, ; //X3_RELACAO
		SX3->X3_F3																, ; //X3_F3
		SX3->X3_NIVEL															, ; //X3_NIVEL
		SX3->X3_RESERV															, ; //X3_RESERV
		SX3->X3_CHECK															, ; //X3_CHECK
		SX3->X3_TRIGGER															, ; //X3_TRIGGER
		SX3->X3_PROPRI															, ; //X3_PROPRI
		SX3->X3_BROWSE															, ; //X3_BROWSE
		SX3->X3_VISUAL															, ; //X3_VISUAL
		SX3->X3_CONTEXT															, ; //X3_CONTEXT
		'Ä'				   														, ; //X3_OBRIGAT
		SX3->X3_VLDUSER                                                         , ; //X3_VLDUSER
		SX3->X3_CBOX															, ; //X3_CBOX
		SX3->X3_CBOXSPA															, ; //X3_CBOXSPA
		SX3->X3_CBOXENG															, ; //X3_CBOXENG
		SX3->X3_PICTVAR															, ; //X3_PICTVAR
		SX3->X3_WHEN															, ; //X3_WHEN
		SX3->X3_INIBRW															, ; //X3_INIBRW
		SX3->X3_GRPSXG															, ; //X3_GRPSXG
		SX3->X3_FOLDER	  														, ; //X3_FOLDER
		SX3->X3_PYME															} ) //X3_PYME
	EndIf         		
	
	
aAdd( aSX3, { ;
	'SB1'																	, ; //X3_ARQUIVO
	'01'																	, ; //X3_ORDEM
	'B1_XCXFECH'   															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	1																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Cx.Fechada'															, ; //X3_TITULO
	'Cx.Fechada'   															, ; //X3_TITSPA
	'Cx.Fechada'															, ; //X3_TITENG
	'Solicitou Cx.Fechada'													, ; //X3_DESCRIC
	'Solicitou Cx.Fechada'													, ; //X3_DESCSPA
	'Solicitou Cx.Fechada'													, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, ; //X3_USADO
	''				 														, ; //X3_RELACAO
	''					  													, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''					  													, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''    								   									, ; //X3_OBRIGAT
	''                                				                        , ; //X3_VLDUSER
	'1=Sim,2=N√o'					  										, ; //X3_CBOX
	'1=Sim,2=N√o'					   										, ; //X3_CBOXSPA
	'1=Sim,2=N√o'					   										, ; //X3_CBOXENG
	''									  									, ; //X3_PICTVAR
	'.F.'																	, ; //X3_WHEN
	''													   					, ; //X3_INIBRW
	''												   						, ; //X3_GRPSXG
    ''	  											 						, ; //X3_FOLDER
	'N'											   							} ) //X3_PYME

aAdd( aSX3, { ;
	'SB1'																	, ; //X3_ARQUIVO
	'01'																	, ; //X3_ORDEM
	'B1_XVLDCXE'   															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	1																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Vld.Cx.Emb'															, ; //X3_TITULO
	'Vld.Cx.Emb'   															, ; //X3_TITSPA
	'Vld.Cx.Emb'															, ; //X3_TITENG
	'Cx.Emb Validada'														, ; //X3_DESCRIC
	'Cx.Emb Validada'	 													, ; //X3_DESCSPA
	'Cx.Emb Validada'														, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, ; //X3_USADO
	''				 														, ; //X3_RELACAO
	''																		, ; //X3_F3
	0												  						, ; //X3_NIVEL
	Chr(254) + Chr(65)							 							, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''										   								, ; //X3_TRIGGER
	'U'										   								, ; //X3_PROPRI
	'N'										   								, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''    																	, ; //X3_OBRIGAT
	''                                                          			, ; //X3_VLDUSER
	'1=Sim,2=N√o'															, ; //X3_CBOX
	'1=Sim,2=N√o'															, ; //X3_CBOXSPA
	'1=Sim,2=N√o'															, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	'.F.'																	, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
    ''	  																	, ; //X3_FOLDER
	'N'																		} ) //X3_PYME
	
aAdd( aSX3, { ;
	'SB1'																	, ; //X3_ARQUIVO
	'01'																	, ; //X3_ORDEM
	'B1_XCODORI'   															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	15																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Cod.Orig.'																, ; //X3_TITULO
	'Cod.Orig.'	   															, ; //X3_TITSPA
	'Cod.Orig.'																, ; //X3_TITENG
	'Codigo Origem'															, ; //X3_DESCRIC
	'Codigo Origem'															, ; //X3_DESCSPA
	'Codigo Origem'															, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''														  				, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, ; //X3_USADO
	''				 														, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(65)					   									, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''										   								, ; //X3_TRIGGER
	'U'										   								, ; //X3_PROPRI
	'N'										   								, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''    																	, ; //X3_OBRIGAT
	''                                          			                , ; //X3_VLDUSER
	'1=Sim,2=N√o'								  							, ; //X3_CBOX
	'1=Sim,2=N√o'								 							, ; //X3_CBOXSPA
	'1=Sim,2=N√o'								  							, ; //X3_CBOXENG
	''											 							, ; //X3_PICTVAR
	'.F.'										   							, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''													  					, ; //X3_GRPSXG
    ''	  																	, ; //X3_FOLDER
	'N'											   							} ) //X3_PYME


aAdd( aSX3, { ;
	'SB1'																	, ; //X3_ARQUIVO
	'01'																	, ; //X3_ORDEM
	'B1_XCODDES'   															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	15																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Cod.Dest.'																, ; //X3_TITULO
	'Cod.Dest.'	   															, ; //X3_TITSPA
	'Cod.Dest.'																, ; //X3_TITENG
	'Codigo Destino'														, ; //X3_DESCRIC
	'Codigo Destino'														, ; //X3_DESCSPA
	'Codigo Destino'														, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''														  				, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, ; //X3_USADO
	''				 														, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(65)					   									, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''										   								, ; //X3_TRIGGER
	'U'										   								, ; //X3_PROPRI
	'N'										   								, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''    																	, ; //X3_OBRIGAT
	''                                          			                , ; //X3_VLDUSER
	'1=Sim,2=N√o'								  							, ; //X3_CBOX
	'1=Sim,2=N√o'								 							, ; //X3_CBOXSPA
	'1=Sim,2=N√o'								  							, ; //X3_CBOXENG
	''											 							, ; //X3_PICTVAR
	'.F.'										   							, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''													  					, ; //X3_GRPSXG
    ''	  																	, ; //X3_FOLDER
	'N'											   							} ) //X3_PYME
	
aAdd( aSX3, { ;
	'SB1'																	, ; //X3_ARQUIVO
	'99'																	, ; //X3_ORDEM
	'B1_XQEMB'   															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	15																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Qtde Emb '																, ; //X3_TITULO
	'Qtde Emb '	   															, ; //X3_TITSPA
	'Qtde Emb '																, ; //X3_TITENG
	'Qtde Emb primaria'  													, ; //X3_DESCRIC
	'Qtde Emb primaria'														, ; //X3_DESCSPA
	'Qtde Emb primaria'														, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''														  				, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, ; //X3_USADO
	''				 														, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(65)					   									, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''										   								, ; //X3_TRIGGER
	'U'										   								, ; //X3_PROPRI
	'N'										   								, ; //X3_BROWSE
	'R'																		, ; //X3_VISUAL
	'A'																		, ; //X3_CONTEXT
	''    																	, ; //X3_OBRIGAT
	''                                          			                , ; //X3_VLDUSER
	''											  							, ; //X3_CBOX
	''											 							, ; //X3_CBOXSPA
	''											  							, ; //X3_CBOXENG
	''											 							, ; //X3_PICTVAR
	''											   							, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''													  					, ; //X3_GRPSXG
    ''	  																	, ; //X3_FOLDER
	'N'											   							} ) //X3_PYME	

aAdd( aSX3, { ;
	'SA1'																	, ; //X3_ARQUIVO
	'01'																	, ; //X3_ORDEM
	'A1_XCOBCIF'   															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	1																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Cobra CIF'																, ; //X3_TITULO
	'Cobra CIF'	   															, ; //X3_TITSPA
	'Cobra CIF'																, ; //X3_TITENG
	'Cobra CIF'																, ; //X3_DESCRIC
	'Cobra CIF'		 														, ; //X3_DESCSPA
	'Cobra CIF'																, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, ; //X3_USADO
	''				 														, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''    																	, ; //X3_OBRIGAT
	''                                  	  			                    , ; //X3_VLDUSER
	'1=Sim;2=N√o'															, ; //X3_CBOX
	'1=Sim;2=N√o'															, ; //X3_CBOXSPA
	'1=Sim;2=N√o'															, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	'.F.'																	, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
    ''	  																	, ; //X3_FOLDER
	'N'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SA1'																	, ; //X3_ARQUIVO
	'01'																	, ; //X3_ORDEM
	'A1_XMARBOR'   															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	1																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Marc.Bordero'															, ; //X3_TITULO
	'Marc.Bordero'															, ; //X3_TITSPA
	'Marc.Bordero'															, ; //X3_TITENG
	'Marc.Bordero'															, ; //X3_DESCRIC
	'Marc.Bordero'	 														, ; //X3_DESCSPA
	'Marc.Bordero'															, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128)								, ; //X3_USADO
	''				 														, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''    																	, ; //X3_OBRIGAT
	''                                  	  			                    , ; //X3_VLDUSER
	'1=Sim;2=N√o'															, ; //X3_CBOX
	'1=Sim;2=N√o'															, ; //X3_CBOXSPA
	'1=Sim;2=N√o'															, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	'U_DIPWHEN()'															, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
    '2'	  																	, ; //X3_FOLDER
	'N'																		} ) //X3_PYME
	
aAdd( aSX3, { ;
	'SA1'																	, ; //X3_ARQUIVO
	'01'																	, ; //X3_ORDEM
	'A1_XSTATCR'   															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	1																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Status Cred.'															, ; //X3_TITULO
	'Status Cred.'															, ; //X3_TITSPA
	'Status Cred.'															, ; //X3_TITENG
	'Status do Credito'														, ; //X3_DESCRIC
	'Status do Credito'														, ; //X3_DESCSPA
	'Status do Credito'														, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) 								, ; //X3_USADO
	''				 														, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''    																	, ; //X3_OBRIGAT
	'Pertence("1234")'                     	  			                    , ; //X3_VLDUSER
	'1=Faturado;2=A vista;3=No juridico;4=Em analise'						, ; //X3_CBOX
	'1=Faturado;2=A vista;3=No juridico;4=Em analise'						, ; //X3_CBOXSPA
	'1=Faturado;2=A vista;3=No juridico;4=Em analise'						, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	'U_DIPWHEN()'															, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
    '4'	  																	, ; //X3_FOLDER
	'N'																		} ) //X3_PYME
	
//⁄ƒƒƒƒƒƒƒƒƒƒø
//≥Tabela SA1≥
//¿ƒƒƒƒƒƒƒƒƒƒŸ
SX3->(DbSetOrder(1))
SX3->(MsSeek("SA1"+"ZZ",.T.))
SX3->(DbSkip(-1))

cOrdem := Soma1(SX3->X3_ORDEM)   

aAdd( aSX3, { ;
	'SA1'																	, ; //X3_ARQUIVO
	cOrdem																	, ; //X3_ORDEM
	'A1_OBSSAC'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	120																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Observa. SAC'															, ; //X3_TITULO
	'Observa. SAC'															, ; //X3_TITSPA
	'Observa. SAC'															, ; //X3_TITENG
	'Campo para Observ. do SAC'												, ; //X3_DESCRIC
	'Campo para Observ. do SAC'												, ; //X3_DESCSPA
	'Campo para Observ. do SAC'												, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128)								, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	'U_A1OBSSAC()'															, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	'S'																		} ) //X3_PYME	


cOrdem := Soma1(cOrdem)   

aAdd( aSX3, { ;
	'SA1'																	, ; //X3_ARQUIVO
	cOrdem																	, ; //X3_ORDEM
	'A1_XEMAILF'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	100																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'E-Mail Finan'															, ; //X3_TITULO
	'E-Mail Finan'															, ; //X3_TITSPA
	'E-Mail Finan'															, ; //X3_TITENG
	'E-mail Financiero        '												, ; //X3_DESCRIC
	'E-Mail Financeiro        '												, ; //X3_DESCSPA
	'E-Mail Financeiro        '												, ; //X3_DESCENG
	''																		, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128)								, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	'U_DIPWHEN()'															, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	'1'																		, ; //X3_FOLDER
	'N'																		} ) //X3_PYME	


cOrdem := Soma1(cOrdem)   

aAdd( aSX3, { ;
	'SA1'																	, ; //X3_ARQUIVO
	cOrdem																	, ; //X3_ORDEM
	'A1_XENDEND'   															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	1																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Entrega Dir '															, ; //X3_TITULO
	'Entrega Dir '	   														, ; //X3_TITSPA
	'Entrega Dir '															, ; //X3_TITENG
	'Entreg ender dife diretor'												, ; //X3_DESCRIC
	'Entreg ender dife diretor'												, ; //X3_DESCSPA
	'Entreg ender dife diretor'												, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128)								, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''    																	, ; //X3_OBRIGAT
	''                                  	  			                    , ; //X3_VLDUSER
	'1=Sim;2=N„o'															, ; //X3_CBOX
	'1=Sim;2=N„o'															, ; //X3_CBOXSPA
	'1=Sim;2=N„o'															, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''   																	, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
    '1'	  																	, ; //X3_FOLDER
	'N'																		} ) //X3_PYME     

cOrdem := Soma1(cOrdem)   

aAdd( aSX3, { ;
	'SA1'																	, ; //X3_ARQUIVO
	cOrdem																	, ; //X3_ORDEM
	'A1_XENDENF'   															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	1																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Entrega Fis '															, ; //X3_TITULO
	'Entrega Fis '	   														, ; //X3_TITSPA
	'Entrega Fis '															, ; //X3_TITENG
	'Entrega ender dife fiscal'												, ; //X3_DESCRIC
	'Entrega ender dife fiscal'												, ; //X3_DESCSPA
	'Entrega ender dife fiscal'												, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128)								, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''    																	, ; //X3_OBRIGAT
	''                                  	  			                    , ; //X3_VLDUSER
	'1=Sim;2=N„o'															, ; //X3_CBOX
	'1=Sim;2=N„o'															, ; //X3_CBOXSPA
	'1=Sim;2=N„o'															, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''   																	, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
    '1'	  																	, ; //X3_FOLDER
	'N'																		} ) //X3_PYME      

//⁄ƒƒƒƒƒƒƒƒƒƒø
//≥Tabela UA1≥
//¿ƒƒƒƒƒƒƒƒƒƒŸ
SX3->(DbSetOrder(1))
SX3->(MsSeek("UA1"+"ZZ",.T.))
SX3->(DbSkip(-1))

cOrdem := Soma1(SX3->X3_ORDEM)   

aAdd( aSX3, { ;
	'UA1'																	, ; //X3_ARQUIVO
	cOrdem																	, ; //X3_ORDEM
	'UA1_ENCONT'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	15																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Form Entreg'															, ; //X3_TITULO
	'Form Entreg'															, ; //X3_TITSPA
	'Form Entreg'															, ; //X3_TITENG
	'Forma de entrega contrato'												, ; //X3_DESCRIC
	'Forma de entrega contrato'												, ; //X3_DESCSPA
	'Forma de entrega contrato'												, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128)								, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	'5'																		, ; //X3_FOLDER
	''																		} ) //X3_PYME	

cOrdem := Soma1(cOrdem)   

aAdd( aSX3, { ;
	'UA1'																	, ; //X3_ARQUIVO
	cOrdem																	, ; //X3_ORDEM
	'UA1_CLDESO'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	1																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Cl.Desonera'															, ; //X3_TITULO
	'Cl.Desonera'															, ; //X3_TITSPA
	'Cl.Desonera'															, ; //X3_TITENG
	'Infor.se cliente desonera'												, ; //X3_DESCRIC
	'Infor.se cliente desonera'												, ; //X3_DESCSPA
	'Infor.se cliente desonera'												, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128)								, ; //X3_USADO
	'"2"'																	, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	'1=Sim;2=N„o'															, ; //X3_CBOX
	'1=Sim;2=N„o'															, ; //X3_CBOXSPA
	'1=Sim;2=N„o'															, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	'5'																		, ; //X3_FOLDER
	''																		} ) //X3_PYME	


If cEmpAnt == '04'
	SX3->(DbSetOrder(2))
	If SX3->(dbSeek("B1_XQE"))
		
		aAdd( aSX3, { ;
		'SB1'																	, ; //X3_ARQUIVO
		SX3->X3_ORDEM															, ; //X3_ORDEM
		'B1_XQE' 		   														, ; //X3_CAMPO
		SX3->X3_TIPO															, ; //X3_TIPO
		SX3->X3_TAMANHO															, ; //X3_TAMANHO
		SX3->X3_DECIMAL															, ; //X3_DECIMAL
		SX3->X3_TITULO															, ; //X3_TITULO
		SX3->X3_TITSPA															, ; //X3_TITSPA
		SX3->X3_TITENG															, ; //X3_TITENG
		SX3->X3_DESCRIC															, ; //X3_DESCRIC
		SX3->X3_DESCSPA															, ; //X3_DESCSPA
		SX3->X3_DESCENG															, ; //X3_DESCENG
		SX3->X3_PICTURE															, ; //X3_PICTURE
		SX3->X3_VALID															, ; //X3_VALID
		SX3->X3_USADO															, ; //X3_USADO
		SX3->X3_RELACAO 														, ; //X3_RELACAO
		SX3->X3_F3																, ; //X3_F3
		SX3->X3_NIVEL															, ; //X3_NIVEL
		SX3->X3_RESERV															, ; //X3_RESERV
		SX3->X3_CHECK															, ; //X3_CHECK
		SX3->X3_TRIGGER															, ; //X3_TRIGGER
		SX3->X3_PROPRI															, ; //X3_PROPRI
		SX3->X3_BROWSE															, ; //X3_BROWSE
		SX3->X3_VISUAL															, ; //X3_VISUAL
		SX3->X3_CONTEXT															, ; //X3_CONTEXT
		'Ä'																		, ; //X3_OBRIGAT
		SX3->X3_VLDUSER															, ; //X3_VLDUSER
		SX3->X3_CBOX															, ; //X3_CBOX
		SX3->X3_CBOXSPA															, ; //X3_CBOXSPA
		SX3->X3_CBOXENG															, ; //X3_CBOXENG
		SX3->X3_PICTVAR															, ; //X3_PICTVAR
		SX3->X3_WHEN															, ; //X3_WHEN
		SX3->X3_INIBRW															, ; //X3_INIBRW
		SX3->X3_GRPSXG															, ; //X3_GRPSXG
		SX3->X3_FOLDER  														, ; //X3_FOLDER
		SX3->X3_PYME															} ) //X3_PYME   

	EndIf	
	

	SX3->(DbSetOrder(2))
	If SX3->(dbSeek("A2_COMPRA"))
		
		aAdd( aSX3, { ;
		'SA2'																	, ; //X3_ARQUIVO
		SX3->X3_ORDEM															, ; //X3_ORDEM
		'A2_COMPRA' 		   														, ; //X3_CAMPO
		SX3->X3_TIPO															, ; //X3_TIPO
		SX3->X3_TAMANHO															, ; //X3_TAMANHO
		SX3->X3_DECIMAL															, ; //X3_DECIMAL
		SX3->X3_TITULO															, ; //X3_TITULO
		SX3->X3_TITSPA															, ; //X3_TITSPA
		SX3->X3_TITENG															, ; //X3_TITENG
		SX3->X3_DESCRIC															, ; //X3_DESCRIC
		SX3->X3_DESCSPA															, ; //X3_DESCSPA
		SX3->X3_DESCENG															, ; //X3_DESCENG
		SX3->X3_PICTURE															, ; //X3_PICTURE
		SX3->X3_VALID															, ; //X3_VALID
		SX3->X3_USADO															, ; //X3_USADO
		SX3->X3_RELACAO 														, ; //X3_RELACAO
		SX3->X3_F3																, ; //X3_F3
		SX3->X3_NIVEL															, ; //X3_NIVEL
		SX3->X3_RESERV															, ; //X3_RESERV
		SX3->X3_CHECK															, ; //X3_CHECK
		SX3->X3_TRIGGER															, ; //X3_TRIGGER
		SX3->X3_PROPRI															, ; //X3_PROPRI
		SX3->X3_BROWSE															, ; //X3_BROWSE
		SX3->X3_VISUAL															, ; //X3_VISUAL
		SX3->X3_CONTEXT															, ; //X3_CONTEXT
		'Ä'																		, ; //X3_OBRIGAT
		SX3->X3_VLDUSER															, ; //X3_VLDUSER
		SX3->X3_CBOX															, ; //X3_CBOX
		SX3->X3_CBOXSPA															, ; //X3_CBOXSPA
		SX3->X3_CBOXENG															, ; //X3_CBOXENG
		SX3->X3_PICTVAR															, ; //X3_PICTVAR
		SX3->X3_WHEN															, ; //X3_WHEN
		SX3->X3_INIBRW															, ; //X3_INIBRW
		SX3->X3_GRPSXG															, ; //X3_GRPSXG
		SX3->X3_FOLDER  														, ; //X3_FOLDER
		SX3->X3_PYME															} ) //X3_PYME

	EndIf 
	
	SX3->(DbSetOrder(2))
	If SX3->(dbSeek("D3_TM"))
	
		aAdd( aSX3, { ;
		'SD3'																	, ; //X3_ARQUIVO
		SX3->X3_ORDEM															, ; //X3_ORDEM
		'D3_TM' 		   														, ; //X3_CAMPO
		SX3->X3_TIPO															, ; //X3_TIPO
		SX3->X3_TAMANHO															, ; //X3_TAMANHO
		SX3->X3_DECIMAL															, ; //X3_DECIMAL
		SX3->X3_TITULO															, ; //X3_TITULO
		SX3->X3_TITSPA															, ; //X3_TITSPA
		SX3->X3_TITENG															, ; //X3_TITENG
		SX3->X3_DESCRIC															, ; //X3_DESCRIC
		SX3->X3_DESCSPA															, ; //X3_DESCSPA
		SX3->X3_DESCENG															, ; //X3_DESCENG
		SX3->X3_PICTURE															, ; //X3_PICTURE
		SX3->X3_VALID															, ; //X3_VALID
		SX3->X3_USADO															, ; //X3_USADO
		SX3->X3_RELACAO 														, ; //X3_RELACAO
		SX3->X3_F3																, ; //X3_F3
		SX3->X3_NIVEL															, ; //X3_NIVEL
		SX3->X3_RESERV															, ; //X3_RESERV
		SX3->X3_CHECK															, ; //X3_CHECK
		SX3->X3_TRIGGER															, ; //X3_TRIGGER
		SX3->X3_PROPRI															, ; //X3_PROPRI
		SX3->X3_BROWSE															, ; //X3_BROWSE
		SX3->X3_VISUAL															, ; //X3_VISUAL
		SX3->X3_CONTEXT															, ; //X3_CONTEXT
		SX3->X3_OBRIGAT															, ; //X3_OBRIGAT
		'U_VLDD3TM()'															, ; //X3_VLDUSER
		SX3->X3_CBOX															, ; //X3_CBOX
		SX3->X3_CBOXSPA															, ; //X3_CBOXSPA
		SX3->X3_CBOXENG															, ; //X3_CBOXENG
		SX3->X3_PICTVAR															, ; //X3_PICTVAR
		SX3->X3_WHEN															, ; //X3_WHEN
		SX3->X3_INIBRW															, ; //X3_INIBRW
		SX3->X3_GRPSXG															, ; //X3_GRPSXG
		SX3->X3_FOLDER  														, ; //X3_FOLDER
		SX3->X3_PYME															} ) //X3_PYME

	EndIf	
	SX3->(DbSetOrder(2))
	If SX3->(dbSeek("C2_QUANT"))
	
		aAdd( aSX3, { ;
		'SC2'																	, ; //X3_ARQUIVO
		SX3->X3_ORDEM															, ; //X3_ORDEM
		'C2_QUANT' 		   														, ; //X3_CAMPO
		SX3->X3_TIPO															, ; //X3_TIPO
		SX3->X3_TAMANHO															, ; //X3_TAMANHO
		SX3->X3_DECIMAL															, ; //X3_DECIMAL
		SX3->X3_TITULO															, ; //X3_TITULO
		SX3->X3_TITSPA															, ; //X3_TITSPA
		SX3->X3_TITENG															, ; //X3_TITENG
		SX3->X3_DESCRIC															, ; //X3_DESCRIC
		SX3->X3_DESCSPA															, ; //X3_DESCSPA
		SX3->X3_DESCENG															, ; //X3_DESCENG
		SX3->X3_PICTURE															, ; //X3_PICTURE
		SX3->X3_VALID															, ; //X3_VALID
		SX3->X3_USADO															, ; //X3_USADO
		SX3->X3_RELACAO 														, ; //X3_RELACAO
		SX3->X3_F3																, ; //X3_F3
		SX3->X3_NIVEL															, ; //X3_NIVEL
		SX3->X3_RESERV															, ; //X3_RESERV
		SX3->X3_CHECK															, ; //X3_CHECK
		SX3->X3_TRIGGER															, ; //X3_TRIGGER
		SX3->X3_PROPRI															, ; //X3_PROPRI
		SX3->X3_BROWSE															, ; //X3_BROWSE
		SX3->X3_VISUAL															, ; //X3_VISUAL
		SX3->X3_CONTEXT															, ; //X3_CONTEXT
		SX3->X3_OBRIGAT															, ; //X3_OBRIGAT
		'U_HQQTDOP(M->C2_PRODUTO,M->C2_QUANT)'									, ; //X3_VLDUSER
		SX3->X3_CBOX															, ; //X3_CBOX
		SX3->X3_CBOXSPA															, ; //X3_CBOXSPA
		SX3->X3_CBOXENG															, ; //X3_CBOXENG
		SX3->X3_PICTVAR															, ; //X3_PICTVAR
		SX3->X3_WHEN															, ; //X3_WHEN
		SX3->X3_INIBRW															, ; //X3_INIBRW
		SX3->X3_GRPSXG															, ; //X3_GRPSXG
		SX3->X3_FOLDER  														, ; //X3_FOLDER
		SX3->X3_PYME															} ) //X3_PYME

	EndIf	
	
EndIf


/*..TABELA..SA3*/
SX3->(DbSetOrder(2))
If SX3->(dbSeek("A3_END"))

	aAdd( aSX3, { ;
		'SA3'																	, ; //X3_ARQUIVO
		SX3->X3_ORDEM															, ; //X3_ORDEM
		'A3_END'   												    			, ; //X3_CAMPO
		SX3->X3_TIPO											   				, ; //X3_TIPO
		60          															, ; //X3_TAMANHO
		SX3->X3_DECIMAL															, ; //X3_DECIMAL
		SX3->X3_TITULO															, ; //X3_TITULO
		SX3->X3_TITSPA															, ; //X3_TITSPA
		SX3->X3_TITENG															, ; //X3_TITENG
		SX3->X3_DESCRIC															, ; //X3_DESCRIC
		SX3->X3_DESCSPA															, ; //X3_DESCSPA
		SX3->X3_DESCENG															, ; //X3_DESCENG
		SX3->X3_PICTURE															, ; //X3_PICTURE
		SX3->X3_VALID															, ; //X3_VALID
		SX3->X3_USADO															, ; //X3_USADO
		SX3->X3_RELACAO 														, ; //X3_RELACAO
		SX3->X3_F3																, ; //X3_F3
		SX3->X3_NIVEL															, ; //X3_NIVEL
		SX3->X3_RESERV															, ; //X3_RESERV
		SX3->X3_CHECK															, ; //X3_CHECK
		SX3->X3_TRIGGER															, ; //X3_TRIGGER
		SX3->X3_PROPRI															, ; //X3_PROPRI
		SX3->X3_BROWSE															, ; //X3_BROWSE
		SX3->X3_VISUAL															, ; //X3_VISUAL
		SX3->X3_CONTEXT															, ; //X3_CONTEXT
		SX3->X3_OBRIGAT    														, ; //X3_OBRIGAT
		SX3->X3_VLDUSER                                                         , ; //X3_VLDUSER
		SX3->X3_CBOX															, ; //X3_CBOX
		SX3->X3_CBOXSPA															, ; //X3_CBOXSPA
		SX3->X3_CBOXENG															, ; //X3_CBOXENG
		SX3->X3_PICTVAR															, ; //X3_PICTVAR
        SX3->X3_WHEN															, ; //X3_WHEN
		SX3->X3_INIBRW															, ; //X3_INIBRW
		SX3->X3_GRPSXG															, ; //X3_GRPSXG
		SX3->X3_FOLDER	  														, ; //X3_FOLDER
		SX3->X3_PYME															} ) //X3_PYME	
EndIf

/*..TABELA..SB2*/
SX3->(DbSetOrder(2))
If SX3->(dbSeek("B2_SALPEDI"))

	aAdd( aSX3, { ;
		'SB2'																	, ; //X3_ARQUIVO
		SX3->X3_ORDEM															, ; //X3_ORDEM
		'B2_SALPEDI'											    			, ; //X3_CAMPO
		SX3->X3_TIPO											   				, ; //X3_TIPO
		SX3->X3_TAMANHO															, ; //X3_TAMANHO
		SX3->X3_DECIMAL															, ; //X3_DECIMAL
		SX3->X3_TITULO															, ; //X3_TITULO
		SX3->X3_TITSPA															, ; //X3_TITSPA
		SX3->X3_TITENG															, ; //X3_TITENG
		SX3->X3_DESCRIC															, ; //X3_DESCRIC
		SX3->X3_DESCSPA															, ; //X3_DESCSPA
		SX3->X3_DESCENG															, ; //X3_DESCENG
		SX3->X3_PICTURE															, ; //X3_PICTURE
		SX3->X3_VALID															, ; //X3_VALID
		SX3->X3_USADO															, ; //X3_USADO
		SX3->X3_RELACAO 														, ; //X3_RELACAO
		SX3->X3_F3																, ; //X3_F3
		SX3->X3_NIVEL															, ; //X3_NIVEL
		SX3->X3_RESERV															, ; //X3_RESERV
		SX3->X3_CHECK															, ; //X3_CHECK
		SX3->X3_TRIGGER															, ; //X3_TRIGGER
		SX3->X3_PROPRI															, ; //X3_PROPRI
		'S'																		, ; //X3_BROWSE
		SX3->X3_VISUAL															, ; //X3_VISUAL
		SX3->X3_CONTEXT															, ; //X3_CONTEXT
		SX3->X3_OBRIGAT    														, ; //X3_OBRIGAT
		SX3->X3_VLDUSER                                                         , ; //X3_VLDUSER
		SX3->X3_CBOX															, ; //X3_CBOX
		SX3->X3_CBOXSPA															, ; //X3_CBOXSPA
		SX3->X3_CBOXENG															, ; //X3_CBOXENG
		SX3->X3_PICTVAR															, ; //X3_PICTVAR
        SX3->X3_WHEN															, ; //X3_WHEN
		SX3->X3_INIBRW															, ; //X3_INIBRW
		SX3->X3_GRPSXG															, ; //X3_GRPSXG
		SX3->X3_FOLDER	  														, ; //X3_FOLDER
		SX3->X3_PYME															} ) //X3_PYME	
EndIf
     

/*..TABELA..SY1*/
SX3->(DbSetOrder(2))
If SX3->(dbSeek("Y1_EMAIL"))

	aAdd( aSX3, { ;
		'SY1'																	, ; //X3_ARQUIVO
		SX3->X3_ORDEM															, ; //X3_ORDEM
		'Y1_EMAIL'												    			, ; //X3_CAMPO
		SX3->X3_TIPO											   				, ; //X3_TIPO
		50																		, ; //X3_TAMANHO
		SX3->X3_DECIMAL															, ; //X3_DECIMAL
		SX3->X3_TITULO															, ; //X3_TITULO
		SX3->X3_TITSPA															, ; //X3_TITSPA
		SX3->X3_TITENG															, ; //X3_T—ITENG
		SX3->X3_DESCRIC															, ; //X3_DESCRIC
		SX3->X3_DESCSPA															, ; //X3_DESCSPA
		SX3->X3_DESCENG															, ; //X3_DESCENG
		SX3->X3_PICTURE															, ; //X3_PICTURE
		SX3->X3_VALID															, ; //X3_VALID
		SX3->X3_USADO															, ; //X3_USADO
		SX3->X3_RELACAO 														, ; //X3_RELACAO
		SX3->X3_F3																, ; //X3_F3
		SX3->X3_NIVEL															, ; //X3_NIVEL
		SX3->X3_RESERV															, ; //X3_RESERV
		SX3->X3_CHECK															, ; //X3_CHECK
		SX3->X3_TRIGGER															, ; //X3_TRIGGER
		SX3->X3_PROPRI															, ; //X3_PROPRI
		SX3->X3_BROWSE															, ; //X3_BROWSE
		SX3->X3_VISUAL															, ; //X3_VISUAL
		SX3->X3_CONTEXT															, ; //X3_CONTEXT
		SX3->X3_OBRIGAT    														, ; //X3_OBRIGAT
		SX3->X3_VLDUSER                                                         , ; //X3_VLDUSER
		SX3->X3_CBOX															, ; //X3_CBOX
		SX3->X3_CBOXSPA															, ; //X3_CBOXSPA
		SX3->X3_CBOXENG															, ; //X3_CBOXENG
		SX3->X3_PICTVAR															, ; //X3_PICTVAR
        SX3->X3_WHEN															, ; //X3_WHEN
		SX3->X3_INIBRW															, ; //X3_INIBRW
		SX3->X3_GRPSXG															, ; //X3_GRPSXG
		SX3->X3_FOLDER	  														, ; //X3_FOLDER
		SX3->X3_PYME															} ) //X3_PYME	
EndIf
     
/*..TABELA..SC5*/
SX3->(DbSetOrder(2))
If SX3->(dbSeek("C5_TIPOCLI"))

	aAdd( aSX3, { ;
		'SC5'																	, ; //X3_ARQUIVO
		SX3->X3_ORDEM															, ; //X3_ORDEM
		'C5_TIPOCLI'												    			, ; //X3_CAMPO
		SX3->X3_TIPO											   				, ; //X3_TIPO
		SX3->X3_TAMANHO															, ; //X3_TAMANHO
		SX3->X3_DECIMAL															, ; //X3_DECIMAL
		SX3->X3_TITULO															, ; //X3_TITULO
		SX3->X3_TITSPA															, ; //X3_TITSPA
		SX3->X3_TITENG															, ; //X3_T—ITENG
		SX3->X3_DESCRIC															, ; //X3_DESCRIC
		SX3->X3_DESCSPA															, ; //X3_DESCSPA
		SX3->X3_DESCENG															, ; //X3_DESCENG
		SX3->X3_PICTURE															, ; //X3_PICTURE
		SX3->X3_VALID															, ; //X3_VALID
		SX3->X3_USADO															, ; //X3_USADO
		SX3->X3_RELACAO 														, ; //X3_RELACAO
		SX3->X3_F3																, ; //X3_F3
		SX3->X3_NIVEL															, ; //X3_NIVEL
		SX3->X3_RESERV															, ; //X3_RESERV
		SX3->X3_CHECK															, ; //X3_CHECK
		SX3->X3_TRIGGER															, ; //X3_TRIGGER
		SX3->X3_PROPRI															, ; //X3_PROPRI
		SX3->X3_BROWSE															, ; //X3_BROWSE
		SX3->X3_VISUAL															, ; //X3_VISUAL
		SX3->X3_CONTEXT															, ; //X3_CONTEXT
		SX3->X3_OBRIGAT    														, ; //X3_OBRIGAT
		SX3->X3_VLDUSER                                                         , ; //X3_VLDUSER
		SX3->X3_CBOX															, ; //X3_CBOX
		SX3->X3_CBOXSPA															, ; //X3_CBOXSPA
		SX3->X3_CBOXENG															, ; //X3_CBOXENG
		SX3->X3_PICTVAR															, ; //X3_PICTVAR
        '.F.'																	, ; //X3_WHEN
		SX3->X3_INIBRW															, ; //X3_INIBRW
		SX3->X3_GRPSXG															, ; //X3_GRPSXG
		SX3->X3_FOLDER	  														, ; //X3_FOLDER
		SX3->X3_PYME															} ) //X3_PYME	
EndIf

/*..TABELA..SLQ*/
SX3->(DbSetOrder(2))
If SX3->(dbSeek("LQ_NUM"))

	aAdd( aSX3, { ;
		'SLQ'																	, ; //X3_ARQUIVO
		SX3->X3_ORDEM															, ; //X3_ORDEM
		'LQ_NUM'												    			, ; //X3_CAMPO
		SX3->X3_TIPO											   				, ; //X3_TIPO
		10																		, ; //X3_TAMANHO
		SX3->X3_DECIMAL															, ; //X3_DECIMAL
		SX3->X3_TITULO															, ; //X3_TITULO
		SX3->X3_TITSPA															, ; //X3_TITSPA
		SX3->X3_TITENG															, ; //X3_T—ITENG
		SX3->X3_DESCRIC															, ; //X3_DESCRIC
		SX3->X3_DESCSPA															, ; //X3_DESCSPA
		SX3->X3_DESCENG															, ; //X3_DESCENG
		SX3->X3_PICTURE															, ; //X3_PICTURE
		SX3->X3_VALID															, ; //X3_VALID
		SX3->X3_USADO															, ; //X3_USADO
		SX3->X3_RELACAO 														, ; //X3_RELACAO
		SX3->X3_F3																, ; //X3_F3
		SX3->X3_NIVEL															, ; //X3_NIVEL
		SX3->X3_RESERV															, ; //X3_RESERV
		SX3->X3_CHECK															, ; //X3_CHECK
		SX3->X3_TRIGGER															, ; //X3_TRIGGER
		SX3->X3_PROPRI															, ; //X3_PROPRI
		SX3->X3_BROWSE															, ; //X3_BROWSE
		SX3->X3_VISUAL															, ; //X3_VISUAL
		SX3->X3_CONTEXT															, ; //X3_CONTEXT
		SX3->X3_OBRIGAT    														, ; //X3_OBRIGAT
		SX3->X3_VLDUSER                                                         , ; //X3_VLDUSER
		SX3->X3_CBOX															, ; //X3_CBOX
		SX3->X3_CBOXSPA															, ; //X3_CBOXSPA
		SX3->X3_CBOXENG															, ; //X3_CBOXENG
		SX3->X3_PICTVAR															, ; //X3_PICTVAR
		SX3->X3_WHEN															, ; //X3_WHEN
		SX3->X3_INIBRW															, ; //X3_INIBRW
		SX3->X3_GRPSXG															, ; //X3_GRPSXG
		SX3->X3_FOLDER	  														, ; //X3_FOLDER
		SX3->X3_PYME															} ) //X3_PYME	
EndIf


If cEmpAnt == "04"
	SX3->(DbSetOrder(2))
	If SX3->(dbSeek("C5_TPFRETE"))
	
		aAdd( aSX3, { ;
			'SC5'																	, ; //X3_ARQUIVO
			SX3->X3_ORDEM															, ; //X3_ORDEM
			'C5_TPFRETE'											    			, ; //X3_CAMPO
			SX3->X3_TIPO											   				, ; //X3_TIPO
			SX3->X3_TAMANHO															, ; //X3_TAMANHO
			SX3->X3_DECIMAL															, ; //X3_DECIMAL
			SX3->X3_TITULO															, ; //X3_TITULO
			SX3->X3_TITSPA															, ; //X3_TITSPA
			SX3->X3_TITENG															, ; //X3_T—ITENG
			SX3->X3_DESCRIC															, ; //X3_DESCRIC
			SX3->X3_DESCSPA															, ; //X3_DESCSPA
			SX3->X3_DESCENG															, ; //X3_DESCENG
			SX3->X3_PICTURE															, ; //X3_PICTURE
			'vazio() .or. pertence("CFRIN")'										, ; //X3_VALID
			SX3->X3_USADO															, ; //X3_USADO
			SX3->X3_RELACAO 														, ; //X3_RELACAO
			SX3->X3_F3																, ; //X3_F3
			SX3->X3_NIVEL															, ; //X3_NIVEL
			SX3->X3_RESERV															, ; //X3_RESERV
			SX3->X3_CHECK															, ; //X3_CHECK
			SX3->X3_TRIGGER															, ; //X3_TRIGGER
			SX3->X3_PROPRI															, ; //X3_PROPRI
			SX3->X3_BROWSE															, ; //X3_BROWSE
			SX3->X3_VISUAL															, ; //X3_VISUAL
			SX3->X3_CONTEXT															, ; //X3_CONTEXT
			SX3->X3_OBRIGAT    														, ; //X3_OBRIGAT
			'(vazio() .Or. pertence("CFRIN")) .And. u_DipCIFxUF()'                  , ; //X3_VLDUSER
			"C=CIF;F=FOB;R=RETIRA;I=INCLUSO;N=NOSSO CARRO"							, ; //X3_CBOX
			SX3->X3_CBOXSPA															, ; //X3_CBOXSPA
			SX3->X3_CBOXENG															, ; //X3_CBOXENG
			SX3->X3_PICTVAR															, ; //X3_PICTVAR
	        SX3->X3_WHEN															, ; //X3_WHEN
			SX3->X3_INIBRW															, ; //X3_INIBRW
			SX3->X3_GRPSXG															, ; //X3_GRPSXG
			SX3->X3_FOLDER	  														, ; //X3_FOLDER
			SX3->X3_PYME															} ) //X3_PYME	
	EndIf
EndIf

SX3->(DbSetOrder(2))
If SX3->(dbSeek("C5_TIPO"))
	aAdd( aSX3, { ;
		'SC5'																	, ; //X3_ARQUIVO
		SX3->X3_ORDEM															, ; //X3_ORDEM
		'C5_TIPO'												    			, ; //X3_CAMPO
		SX3->X3_TIPO											   				, ; //X3_TIPO
		SX3->X3_TAMANHO															, ; //X3_TAMANHO
		SX3->X3_DECIMAL															, ; //X3_DECIMAL
		SX3->X3_TITULO															, ; //X3_TITULO
		SX3->X3_TITSPA															, ; //X3_TITSPA
		SX3->X3_TITENG															, ; //X3_T—ITENG
		SX3->X3_DESCRIC															, ; //X3_DESCRIC
		SX3->X3_DESCSPA															, ; //X3_DESCSPA
		SX3->X3_DESCENG															, ; //X3_DESCENG
		SX3->X3_PICTURE															, ; //X3_PICTURE
		SX3->X3_VALID															, ; //X3_VALID
		SX3->X3_USADO															, ; //X3_USADO
		SX3->X3_RELACAO 														, ; //X3_RELACAO
		SX3->X3_F3																, ; //X3_F3
		SX3->X3_NIVEL															, ; //X3_NIVEL
		SX3->X3_RESERV															, ; //X3_RESERV
		SX3->X3_CHECK															, ; //X3_CHECK
		SX3->X3_TRIGGER															, ; //X3_TRIGGER
		SX3->X3_PROPRI															, ; //X3_PROPRI
		SX3->X3_BROWSE															, ; //X3_BROWSE
		SX3->X3_VISUAL															, ; //X3_VISUAL
		SX3->X3_CONTEXT															, ; //X3_CONTEXT
		SX3->X3_OBRIGAT    														, ; //X3_OBRIGAT
		' '				                                                        , ; //X3_VLDUSER
		SX3->X3_CBOX															, ; //X3_CBOX
		SX3->X3_CBOXSPA															, ; //X3_CBOXSPA
		SX3->X3_CBOXENG															, ; //X3_CBOXENG
		SX3->X3_PICTVAR															, ; //X3_PICTVAR
        SX3->X3_WHEN															, ; //X3_WHEN
		SX3->X3_INIBRW															, ; //X3_INIBRW
		SX3->X3_GRPSXG															, ; //X3_GRPSXG
		SX3->X3_FOLDER	  														, ; //X3_FOLDER
		SX3->X3_PYME															} ) //X3_PYME	
EndIf

SX3->(DbSetOrder(2))
If SX3->(dbSeek("D3_COD"))
	
		aAdd( aSX3, { ;
		'SD3'																	, ; //X3_ARQUIVO
		SX3->X3_ORDEM															, ; //X3_ORDEM
		'D3_COD' 		   														, ; //X3_CAMPO
		SX3->X3_TIPO															, ; //X3_TIPO
		SX3->X3_TAMANHO															, ; //X3_TAMANHO
		SX3->X3_DECIMAL															, ; //X3_DECIMAL
		SX3->X3_TITULO															, ; //X3_TITULO
		SX3->X3_TITSPA															, ; //X3_TITSPA
		SX3->X3_TITENG															, ; //X3_TITENG
		SX3->X3_DESCRIC															, ; //X3_DESCRIC
		SX3->X3_DESCSPA															, ; //X3_DESCSPA
		SX3->X3_DESCENG															, ; //X3_DESCENG
		SX3->X3_PICTURE															, ; //X3_PICTURE
		SX3->X3_VALID															, ; //X3_VALID
		SX3->X3_USADO															, ; //X3_USADO
		SX3->X3_RELACAO 														, ; //X3_RELACAO
		SX3->X3_F3																, ; //X3_F3
		SX3->X3_NIVEL															, ; //X3_NIVEL
		SX3->X3_RESERV															, ; //X3_RESERV
		SX3->X3_CHECK															, ; //X3_CHECK
		SX3->X3_TRIGGER															, ; //X3_TRIGGER
		SX3->X3_PROPRI															, ; //X3_PROPRI
		SX3->X3_BROWSE															, ; //X3_BROWSE
		SX3->X3_VISUAL															, ; //X3_VISUAL
		SX3->X3_CONTEXT															, ; //X3_CONTEXT
		SX3->X3_OBRIGAT															, ; //X3_OBRIGAT
		'U_VLDD3TMb()' 															, ; //X3_VLDUSER
		SX3->X3_CBOX															, ; //X3_CBOX
		SX3->X3_CBOXSPA															, ; //X3_CBOXSPA
		SX3->X3_CBOXENG															, ; //X3_CBOXENG
		SX3->X3_PICTVAR															, ; //X3_PICTVAR
		SX3->X3_WHEN															, ; //X3_WHEN
		SX3->X3_INIBRW															, ; //X3_INIBRW
		SX3->X3_GRPSXG															, ; //X3_GRPSXG
		SX3->X3_FOLDER  														, ; //X3_FOLDER
		SX3->X3_PYME															} ) //X3_PYME
EndIf


SX3->(DbSetOrder(2))
If SX3->(dbSeek("D3_LOCAL"))
	
		aAdd( aSX3, { ;
		'SD3'																	, ; //X3_ARQUIVO
		SX3->X3_ORDEM															, ; //X3_ORDEM
		'D3_LOCAL' 		   														, ; //X3_CAMPO
		SX3->X3_TIPO															, ; //X3_TIPO
		SX3->X3_TAMANHO															, ; //X3_TAMANHO
		SX3->X3_DECIMAL															, ; //X3_DECIMAL
		SX3->X3_TITULO															, ; //X3_TITULO
		SX3->X3_TITSPA															, ; //X3_TITSPA
		SX3->X3_TITENG															, ; //X3_TITENG
		SX3->X3_DESCRIC															, ; //X3_DESCRIC
		SX3->X3_DESCSPA															, ; //X3_DESCSPA
		SX3->X3_DESCENG															, ; //X3_DESCENG
		SX3->X3_PICTURE															, ; //X3_PICTURE
		SX3->X3_VALID															, ; //X3_VALID
		SX3->X3_USADO															, ; //X3_USADO
		SX3->X3_RELACAO 														, ; //X3_RELACAO
		SX3->X3_F3																, ; //X3_F3
		SX3->X3_NIVEL															, ; //X3_NIVEL
		SX3->X3_RESERV															, ; //X3_RESERV
		SX3->X3_CHECK															, ; //X3_CHECK
		SX3->X3_TRIGGER															, ; //X3_TRIGGER
		SX3->X3_PROPRI															, ; //X3_PROPRI
		SX3->X3_BROWSE															, ; //X3_BROWSE
		SX3->X3_VISUAL															, ; //X3_VISUAL
		SX3->X3_CONTEXT															, ; //X3_CONTEXT
		SX3->X3_OBRIGAT															, ; //X3_OBRIGAT
		SX3->X3_VLDUSER															, ; //X3_VLDUSER
		SX3->X3_CBOX															, ; //X3_CBOX
		SX3->X3_CBOXSPA															, ; //X3_CBOXSPA
		SX3->X3_CBOXENG															, ; //X3_CBOXENG
		SX3->X3_PICTVAR															, ; //X3_PICTVAR
		'FunName()<>"MATA250"'													, ; //X3_WHEN
		SX3->X3_INIBRW															, ; //X3_INIBRW
		SX3->X3_GRPSXG															, ; //X3_GRPSXG
		SX3->X3_FOLDER  														, ; //X3_FOLDER
		SX3->X3_PYME															} ) //X3_PYME
EndIf       


//
// Tabela ZZC
//
aAdd( aSX3, { ;
	'ZZC'																	, ; //X3_ARQUIVO
	'01'																	, ; //X3_ORDEM
	'ZZC_FILIAL'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	2																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Filial'																, ; //X3_TITULO
	'Filial'																, ; //X3_TITSPA
	'Filial'																, ; //X3_TITENG
	'Filial'																, ; //X3_DESCRIC
	'Filial'																, ; //X3_DESCSPA
	'Filial'																, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	'N'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'ZZC'																	, ; //X3_ARQUIVO
	'02'																	, ; //X3_ORDEM
	'ZZC_STATUS'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	1																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Status'																, ; //X3_TITULO
	'Status'																, ; //X3_TITSPA
	'Status'																, ; //X3_TITENG
	'Status'																, ; //X3_DESCRIC
	'Status'																, ; //X3_DESCSPA
	'Status'																, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	'N'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'ZZC'																	, ; //X3_ARQUIVO
	'03'																	, ; //X3_ORDEM
	'ZZC_LOCAL'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	2																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Local'																	, ; //X3_TITULO
	'Local'																	, ; //X3_TITSPA
	'Local'																	, ; //X3_TITENG
	'Local'																	, ; //X3_DESCRIC
	'Local'																	, ; //X3_DESCSPA
	'Local'																	, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(32)						, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	'N'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'ZZC'																	, ; //X3_ARQUIVO
	'04'																	, ; //X3_ORDEM
	'ZZC_LOCALI'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	15																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Localizacao'															, ; //X3_TITULO
	'Localizacao'															, ; //X3_TITSPA
	'Localizacao'															, ; //X3_TITENG
	'Localizacao'															, ; //X3_DESCRIC
	'Localizacao'															, ; //X3_DESCSPA
	'Localizacao'															, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(32)						, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	'N'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'ZZC'																	, ; //X3_ARQUIVO
	'05'																	, ; //X3_ORDEM
	'ZZC_DATA'																, ; //X3_CAMPO
	'D'																		, ; //X3_TIPO
	8																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Data'																	, ; //X3_TITULO
	'Data'																	, ; //X3_TITSPA
	'Data'																	, ; //X3_TITENG
	'Data'																	, ; //X3_DESCRIC
	'Data'																	, ; //X3_DESCSPA
	'Data'																	, ; //X3_DESCENG
	'@D'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(32)						, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	'N'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'ZZC'																	, ; //X3_ARQUIVO
	'05'																	, ; //X3_ORDEM
	'ZZC_HORA'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	5																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Hora'																	, ; //X3_TITULO
	'Hora'																	, ; //X3_TITSPA
	'Hora'																	, ; //X3_TITENG
	'Hora'																	, ; //X3_DESCRIC
	'Hora'																	, ; //X3_DESCSPA
	'Hora'																	, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(32)						, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	'N'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'ZZC'																	, ; //X3_ARQUIVO
	'06'																	, ; //X3_ORDEM
	'ZZC_USUARI'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	20																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Usuario'																, ; //X3_TITULO
	'Usuario'																, ; //X3_TITSPA
	'Usuario'																, ; //X3_TITENG
	'Usuario'																, ; //X3_DESCRIC
	'Usuario'																, ; //X3_DESCSPA
	'Usuario'																, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(32)						, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	'N'																		} ) //X3_PYME      
	
	
//
// Tabela ZZD
//
aAdd( aSX3, { ;
	'ZZD'																	, ; //X3_ARQUIVO
	'01'																	, ; //X3_ORDEM
	'ZZD_FILIAL'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	2																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Filial'																, ; //X3_TITULO
	'Filial'																, ; //X3_TITSPA
	'Filial'																, ; //X3_TITENG
	'Filial'																, ; //X3_DESCRIC
	'Filial'																, ; //X3_DESCSPA
	'Filial'																, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	'N'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'ZZD'																	, ; //X3_ARQUIVO
	'02'																	, ; //X3_ORDEM
	'ZZD_PRODUT'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	15																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Produto'																, ; //X3_TITULO
	'Produto'																, ; //X3_TITSPA
	'Produto'																, ; //X3_TITENG
	'Produto'																, ; //X3_DESCRIC
	'Produto'																, ; //X3_DESCSPA
	'Produto'																, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(32)						, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	'N'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'ZZD'																	, ; //X3_ARQUIVO
	'03'																	, ; //X3_ORDEM
	'ZZD_LOCAL'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	2																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Local'																	, ; //X3_TITULO
	'Local'																	, ; //X3_TITSPA
	'Local'																	, ; //X3_TITENG
	'Local'																	, ; //X3_DESCRIC
	'Local'																	, ; //X3_DESCSPA
	'Local'																	, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(32)						, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	'N'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'ZZD'																	, ; //X3_ARQUIVO
	'04'																	, ; //X3_ORDEM
	'ZZD_LOCALI'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	15																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Localizacao'															, ; //X3_TITULO
	'Localizacao'															, ; //X3_TITSPA
	'Localizacao'															, ; //X3_TITENG
	'Localizacao'															, ; //X3_DESCRIC
	'Localizacao'															, ; //X3_DESCSPA
	'Localizacao'															, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(32)						, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	'N'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'ZZD'																	, ; //X3_ARQUIVO
	'05'																	, ; //X3_ORDEM
	'ZZD_LOTECT'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	10																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Lote'																	, ; //X3_TITULO
	'Lote'																	, ; //X3_TITSPA
	'Lote'																	, ; //X3_TITENG
	'Lote'																	, ; //X3_DESCRIC
	'Lote'																	, ; //X3_DESCSPA
	'Lote'																	, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(32)						, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	'N'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'ZZD'																	, ; //X3_ARQUIVO
	'06'																	, ; //X3_ORDEM
	'ZZD_QUANT'																, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	12																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Quantidade'															, ; //X3_TITULO
	'Quantidade'															, ; //X3_TITSPA
	'Quantidade'															, ; //X3_TITENG
	'Quantidade'															, ; //X3_DESCRIC
	'Quantidade'															, ; //X3_DESCSPA
	'Quantidade'															, ; //X3_DESCENG
	'@E 9,999,999.99'														, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(32)						, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	'N'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'ZZD'																	, ; //X3_ARQUIVO
	'07'																	, ; //X3_ORDEM
	'ZZD_QTSEGU'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	12																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Quantidade 2'															, ; //X3_TITULO
	'Quantidade 2'															, ; //X3_TITSPA
	'Quantidade 2'															, ; //X3_TITENG
	'Quantidade 2'															, ; //X3_DESCRIC
	'Quantidade 2'															, ; //X3_DESCSPA
	'Quantidade 2'															, ; //X3_DESCENG
	'@E 9,999,999.99'														, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(32)						, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	'N'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'ZZD'																	, ; //X3_ARQUIVO
	'08'																	, ; //X3_ORDEM
	'ZZD_TIPREG'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	1																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Tipo Registr'															, ; //X3_TITULO
	'Tipo Registr'															, ; //X3_TITSPA
	'Tipo Registr'															, ; //X3_TITENG
	'Tipo Registr'															, ; //X3_DESCRIC
	'Tipo Registr'															, ; //X3_DESCSPA
	'Tipo Registr'															, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(32)						, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	'N'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'ZZD'																	, ; //X3_ARQUIVO
	'09'																	, ; //X3_ORDEM
	'ZZD_QTCONT'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	12																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Qtd Contada'															, ; //X3_TITULO
	'Qtd Contada'															, ; //X3_TITSPA
	'Qtd Contada'															, ; //X3_TITENG
	'Qtd Contada'															, ; //X3_DESCRIC
	'Qtd Contada'															, ; //X3_DESCSPA
	'Qtd Contada'															, ; //X3_DESCENG
	'@E 9,999,999.99'														, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(32)						, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	'N'																		} ) //X3_PYME
	
aAdd( aSX3, { ;
	'ZZD'																	, ; //X3_ARQUIVO
	'10'																	, ; //X3_ORDEM
	'ZZD_QTELEI'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	12																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Qtd Eleita '															, ; //X3_TITULO
	'Qtd Eleita '															, ; //X3_TITSPA
	'Qtd Eleita '															, ; //X3_TITENG
	'Qtd Eleita '															, ; //X3_DESCRIC
	'Qtd Eleita '															, ; //X3_DESCSPA
	'Qtd Eleita '															, ; //X3_DESCENG
	'@E 9,999,999.99'														, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(32)						, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	'u_DipExpEle()'															, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	'ZZC->ZZC_STATUS == "2" .And. aCols[n,6] <> aCols[n,9]'					, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	'N'																		} ) //X3_PYME	

aAdd( aSX3, { ;
	'ZZD'																	, ; //X3_ARQUIVO
	'11'																	, ; //X3_ORDEM
	'ZZD_DATA'																, ; //X3_CAMPO
	'D'																		, ; //X3_TIPO
	8																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Data'																	, ; //X3_TITULO
	'Data'																	, ; //X3_TITSPA
	'Data'																	, ; //X3_TITENG
	'Data'																	, ; //X3_DESCRIC
	'Data'																	, ; //X3_DESCSPA
	'Data'																	, ; //X3_DESCENG
	'@D'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(32)						, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	'N'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'ZZD'																	, ; //X3_ARQUIVO
	'12'																	, ; //X3_ORDEM
	'ZZD_DTVAOK'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	1																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Dt Vld Ok'																, ; //X3_TITULO
	'Dt Vld Ok'																, ; //X3_TITSPA
	'Dt Vld Ok'																, ; //X3_TITENG
	'Dt Vld Ok'																, ; //X3_DESCRIC
	'Dt Vld Ok'																, ; //X3_DESCSPA
	'Dt Vld Ok'																, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) 								, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	'1=Sim;2=Nao'															, ; //X3_CBOX
	'1=Sim;2=Nao'															, ; //X3_CBOXSPA
	'1=Sim;2=Nao'															, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	'N'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'ZZD'																	, ; //X3_ARQUIVO
	'13'																	, ; //X3_ORDEM
	'ZZD_EXPLIC'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	255																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Explicacao'															, ; //X3_TITULO
	'Explicacao'															, ; //X3_TITSPA
	'Explicacao'															, ; //X3_TITENG
	'Explicacao'															, ; //X3_DESCRIC
	'Explicacao'															, ; //X3_DESCSPA
	'Explicacao'															, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) 								, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	'N'																		} ) //X3_PYME
                                                                                         
aAdd( aSX3, { ;
	'ZZD'																	, ; //X3_ARQUIVO
	'14'																	, ; //X3_ORDEM
	'ZZD_TRCLOT'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	1  																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Troca Lote'															, ; //X3_TITULO
	'Troca Lote'															, ; //X3_TITSPA
	'Troca Lote'															, ; //X3_TITENG
	'Troca Lote'															, ; //X3_DESCRIC
	'Troca Lote'															, ; //X3_DESCSPA
	'Troca Lote'															, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	'N'																		} ) //X3_PYME
	
aAdd( aSX3, { ;
	'SA3'																	, ; //X3_ARQUIVO
	'11'																	, ; //X3_ORDEM
	'A3_XENVREL'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	8																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Recebe WF'																, ; //X3_TITULO
	'Recebe WF'																, ; //X3_TITSPA
	'Recebe WF'																, ; //X3_TITENG
	'Recebe WF'																, ; //X3_DESCRIC
	'Recebe WF'																, ; //X3_DESCSPA
	'Recebe WF'																, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) 	 							, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	'1=Ambos;2=Dipro;3=HQ'													, ; //X3_CBOX
	'1=Ambos;2=Dipro;3=HQ'													, ; //X3_CBOXSPA
	'1=Ambos;2=Dipro;3=HQ'													, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	'1'																		, ; //X3_FOLDER
	'N'																		} ) //X3_PYME


aAdd( aSX3, { ;
	'SZR'																	, ; //X3_ARQUIVO
	'05'																	, ; //X3_ORDEM
	'ZR_OPEDESC'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	40																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Nome Operad.'															, ; //X3_TITULO
	'Nome Operad.'															, ; //X3_TITSPA
	'Nome Operad.'															, ; //X3_TITENG
	'Nome Operad.'															, ; //X3_DESCRIC
	'Nome Operad.'															, ; //X3_DESCSPA
	'Nome Operad.'															, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) 	 							, ; //X3_USADO
	'SU7->(Posicione("SU7",1,xFilial("SU7")+SZR->ZR_OPERADO, "U7_NOME"))'   , ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'V'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	'SU7->(Posicione("SU7",1,xFilial("SU7")+SZR->ZR_OPERADO, "U7_NOME"))'	, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	'1'																		, ; //X3_FOLDER
	'N'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SZR'																	, ; //X3_ARQUIVO
	'21'																	, ; //X3_ORDEM
	'ZR_OBSOPE2'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	200																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Obs.Operad.2'															, ; //X3_TITULO
	'Obs.Operad.2'															, ; //X3_TITSPA
	'Obs.Operad.2'															, ; //X3_TITENG
	'Obs.Operad.2'															, ; //X3_DESCRIC
	'Obs.Operad.2'															, ; //X3_DESCSPA
	'Obs.Operad.2'															, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) 	 							, ; //X3_USADO
	''   																	, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	'1'																		, ; //X3_FOLDER
	'N'																		} ) //X3_PYME	
//
// Tabela ZZE
//
aAdd( aSX3, { ;
	'ZZE'																	, ; //X3_ARQUIVO
	'01'																	, ; //X3_ORDEM
	'ZZE_FILIAL'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	2																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Filial'																, ; //X3_TITULO
	'Filial'																, ; //X3_TITSPA
	'Filial'																, ; //X3_TITENG
	'Filial'																, ; //X3_DESCRIC
	'Filial'																, ; //X3_DESCSPA
	'Filial'																, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	'N'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'ZZE'																	, ; //X3_ARQUIVO
	'02'																	, ; //X3_ORDEM
	'ZZE_POSIPI'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	10																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'NCM '																	, ; //X3_TITULO
	'NCM '																	, ; //X3_TITSPA
	'NCM '																	, ; //X3_TITENG
	'NCM '																	, ; //X3_DESCRIC
	'NCM '																	, ; //X3_DESCSPA
	'NCM '																	, ; //X3_DESCENG
	'@R 9999.99.99'															, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(32)						, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	'U_xVALNCM(M->ZZE_POSIPI)'												, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	'N'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'ZZE'																	, ; //X3_ARQUIVO
	'03'																	, ; //X3_ORDEM
	'ZZE_DTPVD'																, ; //X3_CAMPO
	'D'																		, ; //X3_TIPO
	8																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Periodo de'															, ; //X3_TITULO
	'Periodo de'															, ; //X3_TITSPA
	'Periodo de'															, ; //X3_TITENG
	'Periodo de'															, ; //X3_DESCRIC
	'Periodo de'															, ; //X3_DESCSPA
	'Periodo de'															, ; //X3_DESCENG
	'@D'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(32)						, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	'N'																		} ) //X3_PYME
	
aAdd( aSX3, { ;
	'ZZE'																	, ; //X3_ARQUIVO
	'04'																	, ; //X3_ORDEM
	'ZZE_DTPVA'																, ; //X3_CAMPO
	'D'																		, ; //X3_TIPO
	8																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Periodo ate'															, ; //X3_TITULO
	'Periodo ate'															, ; //X3_TITSPA
	'Periodo ate'															, ; //X3_TITENG
	'Periodo ate'															, ; //X3_DESCRIC
	'Periodo ate'															, ; //X3_DESCSPA
	'Periodo ate'   														, ; //X3_DESCENG
	'@D'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(32)						, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	'N'																		} ) //X3_PYME


//⁄ƒƒƒƒƒƒƒƒƒƒø
//≥Tabela SUC≥
//¿ƒƒƒƒƒƒƒƒƒƒŸ

If cEmpAnt == '04'
	
	SX3->(DbSetOrder(1))
	SX3->(MsSeek("SUC"+"ZZ",.T.))
	SX3->(DbSkip(-1))
	
	cOrdem := Soma1(SX3->X3_ORDEM)
	
	cOrdem := Soma1(cOrdem)
	
	aAdd( aSX3, { ;
	'SUC'																	, ; //X3_ARQUIVO
	cOrdem																	, ; //X3_ORDEM
	'UC_STATUS'		  														, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	2																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Status '																, ; //X3_TITULO
	'Estatus '																, ; //X3_TITSPA
	'Status '																, ; //X3_TITENG
	'Status '											   					, ; //X3_DESCRIC
	'Estatus '																, ; //X3_DESCSPA
	'Status '									   							, ; //X3_DESCENG
	''					 													, ; //X3_PICTURE
	'Pertence("1236789101112131415161718")'									, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128)								, ; //X3_USADO
	'"1"'																	, ; //X3_RELACAO
	''      																, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	''																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	''																		, ; //X3_VISUAL
	''																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	'1=SAC;2=Dir;3=Encerrada;6=Transp;7=Fisc;8=Fina;9=Qual;10=Esc.Fisc;11=Est;12=Forn;13=Cli;14=Ven;15=Rec;16=Produ;17=Comp;18=TI   ', ; //X3_CBOX
	'1=SAC;2=Dir;3=Encerrada;6=Transp;7=Fisc;8=Fina;9=Qual;10=Esc.Fisc;11=Est;12=Forn;13=Cli;14=Ven;15=Rec;16=Produ;17=Comp;18=TI   ', ; //X3_CBOXSPA
	'1=SAC;2=Dir;3=Encerrada;6=Transp;7=Fisc;8=Fina;9=Qual;10=Esc.Fisc;11=Est;12=Forn;13=Cli;14=Ven;15=Rec;16=Produ;17=Comp;18=TI   ', ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	'U_VLDSUC()'															, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	'S'																		} ) //X3_PYME
	
Else

	SX3->(DbSetOrder(1))
	SX3->(MsSeek("SUC"+"ZZ",.T.))
	SX3->(DbSkip(-1))
	
	cOrdem := Soma1(SX3->X3_ORDEM)
	
	cOrdem := Soma1(cOrdem)
	
	aAdd( aSX3, { ;
	'SUC'																	, ; //X3_ARQUIVO
	cOrdem																	, ; //X3_ORDEM
	'UC_STATUS'		  														, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	2																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Status '																, ; //X3_TITULO
	'Estatus '																, ; //X3_TITSPA
	'Status '																, ; //X3_TITENG
	'Status '											   					, ; //X3_DESCRIC
	'Estatus '																, ; //X3_DESCSPA
	'Status '									   							, ; //X3_DESCENG
	''					 													, ; //X3_PICTURE
	'Pertence("1236789101112131415161718")'									, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128)								, ; //X3_USADO
	'"1"'																	, ; //X3_RELACAO
	''      																, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	''																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	''																		, ; //X3_VISUAL
	''																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	'1=SAC;2=Dir;3=Encerrada;6=Transp;7=Fisc;8=Fina;9=Qual;10=Esc.Fisc;11=Est;12=Forn;13=Cli;14=Ven;15=Rec;16=Exped;17=Comp;18=TI   ', ; //X3_CBOX
	'1=SAC;2=Dir;3=Encerrada;6=Transp;7=Fisc;8=Fina;9=Qual;10=Esc.Fisc;11=Est;12=Forn;13=Cli;14=Ven;15=Rec;16=Exped;17=Comp;18=TI   ', ; //X3_CBOXSPA
	'1=SAC;2=Dir;3=Encerrada;6=Transp;7=Fisc;8=Fina;9=Qual;10=Esc.Fisc;11=Est;12=Forn;13=Cli;14=Ven;15=Rec;16=Exped;17=Comp;18=TI   ', ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	'U_VLDSUC()'															, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	'S'																		} ) //X3_PYME
	
EndIf

cOrdem := Soma1(cOrdem)   

aAdd( aSX3, { ;
	'SUC'																	, ; //X3_ARQUIVO
	cOrdem																	, ; //X3_ORDEM
	'UC_XEMENC'		  														, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	250																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Email Encerr'															, ; //X3_TITULO
	'Email Encerr'															, ; //X3_TITSPA
	'Email Encerr'															, ; //X3_TITENG
	'Emails para sac encerrado'							   					, ; //X3_DESCRIC
	'Emails para sac encerrado'												, ; //X3_DESCSPA
	'Emails para sac encerrado'					   							, ; //X3_DESCENG
	''					 													, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128)								, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''      																, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME 

cOrdem := Soma1(cOrdem)   

aAdd( aSX3, { ;
	'SUC'																	, ; //X3_ARQUIVO
	cOrdem																	, ; //X3_ORDEM
	'UC_XEMENCE'	  														, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	250																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Email Encer2'															, ; //X3_TITULO
	'Email Encer2'															, ; //X3_TITSPA
	'Email Encer2'															, ; //X3_TITENG
	'Emails para sac encerrado'							   					, ; //X3_DESCRIC
	'Emails para sac encerrado'												, ; //X3_DESCSPA
	'Emails para sac encerrado'					   							, ; //X3_DESCENG
	''					 													, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128)								, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''      																, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME 



cOrdem := Soma1(cOrdem)   

aAdd( aSX3, { ;
	'SUC'																	, ; //X3_ARQUIVO
	cOrdem																	, ; //X3_ORDEM
	'UC_XSTAEV'		  														, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	30																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Status Envol'															, ; //X3_TITULO
	'Status Envol'															, ; //X3_TITSPA
	'Status Envol'															, ; //X3_TITENG
	'Status envolvidos no SAC '							   					, ; //X3_DESCRIC
	'Status envolvidos no SAC '												, ; //X3_DESCSPA
	'Status envolvidos no SAC '					   							, ; //X3_DESCENG
	''					 													, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128)								, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''      																, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME 
	
	
cOrdem := Soma1(cOrdem)   

aAdd( aSX3, { ;
	'SUC'																	, ; //X3_ARQUIVO
	cOrdem																	, ; //X3_ORDEM
	'UC_XDATAR'		  														, ; //X3_CAMPO
	'D'																		, ; //X3_TIPO
	8																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Data Retorno'															, ; //X3_TITULO
	'Data Retorno'															, ; //X3_TITSPA
	'Data Retorno'															, ; //X3_TITENG
	'Data retorno do antendime'							   					, ; //X3_DESCRIC
	'Data retorno do antendime'												, ; //X3_DESCSPA
	'Data retorno do antendime'					   							, ; //X3_DESCENG
	''					 													, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128)								, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''      																, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	'U_VLDRET()'															, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME 	
                                                                                            
cOrdem := Soma1(cOrdem)   

aAdd( aSX3, { ;
	'SUC'																	, ; //X3_ARQUIVO
	cOrdem																	, ; //X3_ORDEM
	'UC_XMENRE'		  														, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	40																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Obs.Retorno'															, ; //X3_TITULO
	'Obs. Retorno'															, ; //X3_TITSPA
	'Obs. Retorno'															, ; //X3_TITENG
	'Obs. retorno do antendime'							   					, ; //X3_DESCRIC
	'Obs. retorno do antendime'												, ; //X3_DESCSPA
	'Obs. retorno do antendime'					   							, ; //X3_DESCENG
	''					 													, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128)								, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''      																, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	'U_VLDRET()'															, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME 	

cOrdem := Soma1(cOrdem)   

aAdd( aSX3, { ;
	'SUC'																	, ; //X3_ARQUIVO
	cOrdem																	, ; //X3_ORDEM
	'UC_XRETSN'   															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	1																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Retorno?'		   														, ; //X3_TITULO
	'Retorno?'   															, ; //X3_TITSPA
	'Retorno?'																, ; //X3_TITENG
	'Se ter· retorno'														, ; //X3_DESCRIC
	'Se ter· retorno'														, ; //X3_DESCSPA
	'Se ter· retorno'														, ; //X3_DESCENG
	''																		, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) 								, ; //X3_USADO
	''				 														, ; //X3_RELACAO
	''					  													, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''					  													, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''    								   									, ; //X3_OBRIGAT
	''                                				                        , ; //X3_VLDUSER
	'1=Sim;2=N„o'					  										, ; //X3_CBOX
	'1=Sim;2=N„o'					   										, ; //X3_CBOXSPA
	'1=Sim;2=N„o'					   										, ; //X3_CBOXENG
	''									  									, ; //X3_PICTVAR
	'U_VLDRET()'															, ; //X3_WHEN
	''													   					, ; //X3_INIBRW
	''												   						, ; //X3_GRPSXG
    ''	  											 						, ; //X3_FOLDER
	''											   							} ) //X3_PYME


//
// Tabela SB1
//
SX3->(DbSetOrder(1))
SX3->(MsSeek("SB1"+"ZZ",.T.))
SX3->(DbSkip(-1))

cOrdem := Soma1(SX3->X3_ORDEM) 

aAdd( aSX3, { ;
	'SB1'																	, ; //X3_ARQUIVO
	cOrdem																	, ; //X3_ORDEM
	'B1_XDTATU' 															, ; //X3_CAMPO
	'D'																		, ; //X3_TIPO
	8																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Dt.Atu. Guia'															, ; //X3_TITULO
	'Dt.Atu. Guia'															, ; //X3_TITSPA
	'Dt.Atu. Guia'															, ; //X3_TITENG
	'Dt. ult alteracao na guia'												, ; //X3_DESCRIC
	'Dt. ult alteracao na guia'												, ; //X3_DESCSPA
	'Dt. ult alteracao na guia'												, ; //X3_DESCENG
	'@D'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) 	 							, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	'U_xTRAVSB()'															, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	'9'																		, ; //X3_FOLDER
	'N'																		} ) //X3_PYME



cOrdem := Soma1(cOrdem) 

aAdd( aSX3, { ;
	'SB1'																	, ; //X3_ARQUIVO
	cOrdem																	, ; //X3_ORDEM
	'B1_XUSESB' 															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	15																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Us. Alt.Guia'															, ; //X3_TITULO
	'Us. Alt.Guia'															, ; //X3_TITSPA
	'Us. Alt.Guia'															, ; //X3_TITENG
	'Usuario que alterou guia '												, ; //X3_DESCRIC
	'Usuario que alterou guia '												, ; //X3_DESCSPA
	'Usuario que alterou guia '												, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) 	 							, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	'9'																		, ; //X3_FOLDER
	'N'																		} ) //X3_PYME

cOrdem := Soma1(cOrdem) 
aAdd( aSX3, { ;
	'SB1'																	, ; //X3_ARQUIVO
	cOrdem																	, ; //X3_ORDEM
	'B1_XDTANV' 															, ; //X3_CAMPO
	'D'																		, ; //X3_TIPO
	8																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Dt.Atu. Anvi'															, ; //X3_TITULO
	'Dt.Atu. Anvi'															, ; //X3_TITSPA
	'Dt.Atu. Anvi'															, ; //X3_TITENG
	'Dt. ult alter inf na anvi'												, ; //X3_DESCRIC
	'Dt. ult alter inf na anvi'												, ; //X3_DESCSPA
	'Dt. ult alter inf na anvi'												, ; //X3_DESCENG
	'@D'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) 	 							, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	'U_xTRAVSB()'															, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	'9'																		, ; //X3_FOLDER
	'N'																		} ) //X3_PYME


cOrdem := Soma1(cOrdem) 

aAdd( aSX3, { ;
	'SB1'																	, ; //X3_ARQUIVO
	cOrdem																	, ; //X3_ORDEM
	'B1_XUSEAV' 															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	15																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Us. Alt.Anvi'															, ; //X3_TITULO
	'Us. Alt.Anvi'															, ; //X3_TITSPA
	'Us. Alt.Anvi'															, ; //X3_TITENG
	'Usuario alt campo anvisa '												, ; //X3_DESCRIC
	'Usuario alt campo anvisa '												, ; //X3_DESCSPA
	'Usuario alt campo anvisa '												, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) 	 							, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	'9'																		, ; //X3_FOLDER
	'N'																		} ) //X3_PYME


cOrdem := Soma1(cOrdem) 
aAdd( aSX3, { ;
	'SB1'																	, ; //X3_ARQUIVO
	cOrdem																	, ; //X3_ORDEM
	'B1_XCODFOR' 															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	6																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Cod.Form.Atu'															, ; //X3_TITULO
	'Cod.Form.Atu'															, ; //X3_TITSPA
	'Cod.Form.Atu'															, ; //X3_TITENG
	'CÛd. form. de atualizacao'												, ; //X3_DESCRIC
	'CÛd. form. de atualizacao'												, ; //X3_DESCSPA
	'CÛd. form. de atualizacao'												, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) 	 							, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	'9'																		, ; //X3_FOLDER
	'N'																		} ) //X3_PYME 
	
cOrdem := Soma1(cOrdem) 
aAdd( aSX3, { ;
	'SB1'																	, ; //X3_ARQUIVO
	cOrdem																	, ; //X3_ORDEM
	'B1_XVALSEC'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	1																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Tp embalagem'															, ; //X3_TITULO
	'Tp embalagem'															, ; //X3_TITSPA
	'Tp embalagem'			  												, ; //X3_TITENG
	'Tipo de embalagem'														, ; //X3_DESCRIC
	'Tipo de embalagem'														, ; //X3_DESCSPA
	'Tipo de embalagem'														, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) 								, ; //X3_USADO
	'"4"'																	, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	'1=Embarque;2=Secundaria;3=Ambas;4=Nenhuma'								, ; //X3_CBOX
	'1=Embarque;2=Secundaria;3=Ambas;4=Nenhuma'								, ; //X3_CBOXSPA
	'1=Embarque;2=Secundaria;3=Ambas;4=Nenhuma'								, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	'9'																		, ; //X3_FOLDER
	'N'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SB1'																	, ; //X3_ARQUIVO
	'X6'																	, ; //X3_ORDEM
	'B1_PICM_SN'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	5																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Aliq. ICM SN'															, ; //X3_TITULO
	'Aliq. ICM SN'															, ; //X3_TITSPA
	'Aliq. ICM SN'															, ; //X3_TITENG
	'Aliq. ICM Simples - Atual'												, ; //X3_DESCRIC
	'Aliq. ICM Simples - Atual'												, ; //X3_DESCSPA
	'Aliq. ICM Simples - Atual'												, ; //X3_DESCENG
	'@E 99.99'																, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(172) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	'2'																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SB1'																	, ; //X3_ARQUIVO
	'X7'																	, ; //X3_ORDEM
	'B1_XULTPRC'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	12																		, ; //X3_TAMANHO
	4																		, ; //X3_DECIMAL
	'Ult.Men.Prc'															, ; //X3_TITULO
	'Ult.Men.Prc'															, ; //X3_TITSPA
	'Ult.Men.Prc'															, ; //X3_TITENG
	'Ultimo menor preÁo       '												, ; //X3_DESCRIC
	'Ultimo menor preÁo       '												, ; //X3_DESCSPA
	'Ultimo menor preÁo       '												, ; //X3_DESCENG
	'@E 999,999,999.9999'													, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(172) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SZ3'																	, ; //X3_ARQUIVO
	'43'																	, ; //X3_ORDEM
	'Z3_XVLINT2' 															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	10																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Val Inter. 2'															, ; //X3_TITULO
	'Val Inter. 2'															, ; //X3_TITSPA
	'Val Inter. 2'															, ; //X3_TITENG
	'Valor para o Interior 2  '												, ; //X3_DESCRIC
	'Valor para o Interior 2  '												, ; //X3_DESCSPA
	'Valor para o Interior 2  '												, ; //X3_DESCENG
	'@E 9,999,999.99'														, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) 	 							, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	'N'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SZ3'																	, ; //X3_ARQUIVO
	'44'																	, ; //X3_ORDEM
	'Z3_XEXCED2' 															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	10																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Val Exced 2 '															, ; //X3_TITULO
	'Val Exced 2 '															, ; //X3_TITSPA
	'Val Exced 2 '															, ; //X3_TITENG
	'Valor para o Interior 2  '												, ; //X3_DESCRIC
	'Valor para o Interior 2  '												, ; //X3_DESCSPA
	'Valor para o Interior 2  '												, ; //X3_DESCENG
	'@E 9,999,999.99'														, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) 	 							, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	'N'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SZ3'																	, ; //X3_ARQUIVO
	'43'																	, ; //X3_ORDEM
	'Z3_XVLINT3' 															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	10																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Val Inter. 3'															, ; //X3_TITULO
	'Val Inter. 3'															, ; //X3_TITSPA
	'Val Inter. 3'															, ; //X3_TITENG
	'Valor para o Interior 3  '												, ; //X3_DESCRIC
	'Valor para o Interior 3  '												, ; //X3_DESCSPA
	'Valor para o Interior 3  '												, ; //X3_DESCENG
	'@E 9,999,999.99'														, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) 	 							, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	'N'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SZ3'																	, ; //X3_ARQUIVO
	'44'																	, ; //X3_ORDEM
	'Z3_XEXCED3' 															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	10																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Val Exced 3 '															, ; //X3_TITULO
	'Val Exced 3 '															, ; //X3_TITSPA
	'Val Exced 3 '															, ; //X3_TITENG
	'Valor para o Interior 3  '												, ; //X3_DESCRIC
	'Valor para o Interior 3  '												, ; //X3_DESCSPA
	'Valor para o Interior 3  '												, ; //X3_DESCENG
	'@E 9,999,999.99'														, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) 	 							, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	'N'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SZ3'																	, ; //X3_ARQUIVO
	'43'																	, ; //X3_ORDEM
	'Z3_XADVAL2' 															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	5																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'% AdValor 2 '															, ; //X3_TITULO
	'% AdValor 2 '															, ; //X3_TITSPA
	'% AdValor 2 '															, ; //X3_TITENG
	'% AdValor 2   '		  												, ; //X3_DESCRIC
	'% AdValor 2   '														, ; //X3_DESCSPA
	'% AdValor 2   '														, ; //X3_DESCENG
	'@E 999.99'																, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) 	 							, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	'N'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SZ3'																	, ; //X3_ARQUIVO
	'43'																	, ; //X3_ORDEM
	'Z3_XADVAL3' 															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	5																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'% AdValor 3 '															, ; //X3_TITULO
	'% AdValor 3 '															, ; //X3_TITSPA
	'% AdValor 3 '															, ; //X3_TITENG
	'% AdValor 3   '		  												, ; //X3_DESCRIC
	'% AdValor 3   '														, ; //X3_DESCSPA
	'% AdValor 3   '														, ; //X3_DESCENG
	'@E 999.99'																, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) 	 							, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	'N'																		} ) //X3_PYME	


aAdd( aSX3, { ;
	'SZ3'																	, ; //X3_ARQUIVO
	'49'																	, ; //X3_ORDEM
	'Z3_XVLEMEX' 															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	10																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Val no Emex '															, ; //X3_TITULO
	'Val no Emex '															, ; //X3_TITSPA
	'Val no Emex '															, ; //X3_TITENG
	'Valor para o Emex        '												, ; //X3_DESCRIC
	'Valor para o Emex        '												, ; //X3_DESCSPA
	'Valor para o Emex        '												, ; //X3_DESCENG
	'@E 9,999,999.99'														, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) 	 							, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	'N'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SZ3'																	, ; //X3_ARQUIVO
	'50'																	, ; //X3_ORDEM
	'Z3_XPCEMEX' 															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	5																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'% Perc. Emex'															, ; //X3_TITULO
	'% Perc. Emex'															, ; //X3_TITSPA
	'% Perc. Emex'															, ; //X3_TITENG
	'% Percentual do Emex'		  												, ; //X3_DESCRIC
	'% Percentual do Emex'														, ; //X3_DESCSPA
	'% Percentual do Emex'														, ; //X3_DESCENG
	'@E 999.99'																, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) 	 							, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	'N'																		} ) //X3_PYME 
	
	
aAdd( aSX3, { ;
	'SZ3'																	, ; //X3_ARQUIVO
	'51'																	, ; //X3_ORDEM
	'Z3_VMINTDE' 															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	10																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Vlr Min TDE '															, ; //X3_TITULO
	'Vlr Min TDE '															, ; //X3_TITSPA
	'Vlr Min TDE '															, ; //X3_TITENG
	'Valor Minimo do TDE      '												, ; //X3_DESCRIC
	'Valor Minimo do TDE      '												, ; //X3_DESCSPA
	'Valor Minimo do TDE      '												, ; //X3_DESCENG
	'@E 9,999,999.99'														, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) 	 							, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	'N'																		} ) //X3_PYME
	
	
aAdd( aSX3, { ;
	'SZ3'																	, ; //X3_ARQUIVO
	'52'																	, ; //X3_ORDEM
	'Z3_VMAXTDE' 															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	10																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Vlr Max TDE '															, ; //X3_TITULO
	'Vlr Max TDE '															, ; //X3_TITSPA
	'Vlr Max TDE '															, ; //X3_TITENG
	'Valor Maximo do TDE      '												, ; //X3_DESCRIC
	'Valor Maximo do TDE      '												, ; //X3_DESCSPA
	'Valor Maximo do TDE      '												, ; //X3_DESCENG
	'@E 9,999,999.99'														, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) 	 							, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	'N'																		} ) //X3_PYME		

aAdd( aSX3, { ;
	'SZ3'																	, ; //X3_ARQUIVO
	'53'																	, ; //X3_ORDEM
	'Z3_PVLRTDE' 															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	5																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'% Perc. TDE'															, ; //X3_TITULO
	'% Perc. TDE'															, ; //X3_TITSPA
	'% Perc. TDE'															, ; //X3_TITENG
	'% Percentual do TDE'		  												, ; //X3_DESCRIC
	'% Percentual do TDE'														, ; //X3_DESCSPA
	'% Percentual do TDE'														, ; //X3_DESCENG
	'@E 999.99'																, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) 	 							, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	'N'																		} ) //X3_PYME

SX3->(DbSetOrder(1))
SX3->(MsSeek("SZ3"+"ZZ",.T.))
SX3->(DbSkip(-1))

cOrdem := Soma1(SX3->X3_ORDEM) 

aAdd( aSX3, { ;
	'SZ3'																	, ; //X3_ARQUIVO
	cOrdem																	, ; //X3_ORDEM
	'Z3_XVLINTF' 															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	10																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Val Inter. F'															, ; //X3_TITULO
	'Val Inter. F'															, ; //X3_TITSPA
	'Val Inter. F'															, ; //X3_TITENG
	'Valor para o Interior F  '												, ; //X3_DESCRIC
	'Valor para o Interior F  '												, ; //X3_DESCSPA
	'Valor para o Interior F  '												, ; //X3_DESCENG
	'@E 9,999,999.99'														, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) 	 							, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	'N'																		} ) //X3_PYME

cOrdem := Soma1(cOrdem)

aAdd( aSX3, { ;
	'SZ3'																	, ; //X3_ARQUIVO
	cOrdem																	, ; //X3_ORDEM
	'Z3_XEXCEDF' 															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	10																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Val Exced F '															, ; //X3_TITULO
	'Val Exced F '															, ; //X3_TITSPA
	'Val Exced F '															, ; //X3_TITENG
	'Valor para o Interior F  '												, ; //X3_DESCRIC
	'Valor para o Interior F  '												, ; //X3_DESCSPA
	'Valor para o Interior F  '												, ; //X3_DESCENG
	'@E 9,999,999.99'														, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) 	 							, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	'N'																		} ) //X3_PYME

cOrdem := Soma1(cOrdem)

aAdd( aSX3, { ;
	'SZ3'																	, ; //X3_ARQUIVO
	cOrdem																	, ; //X3_ORDEM
	'Z3_XADVALF' 															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	5																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'% AdValor F '															, ; //X3_TITULO
	'% AdValor F '															, ; //X3_TITSPA
	'% AdValor F '															, ; //X3_TITENG
	'% AdValor F   '		  												, ; //X3_DESCRIC
	'% AdValor F   '														, ; //X3_DESCSPA
	'% AdValor F   '														, ; //X3_DESCENG
	'@E 999.99'																, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) 	 							, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	'N'																		} ) //X3_PYME	

aAdd( aSX3, { ;
	'CC2'																	, ; //X3_ARQUIVO
	'11'																	, ; //X3_ORDEM
	'CC2_XINTER' 															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	1																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Int Jamef   '															, ; //X3_TITULO
	'Int Jamef   '															, ; //X3_TITSPA
	'Int Jamef   '															, ; //X3_TITENG
	'Interior Jamef 2 	 	  '												, ; //X3_DESCRIC
	'Interior Jamef 2 	 	  '												, ; //X3_DESCSPA
	'Interior Jamef 2 	 	  '												, ; //X3_DESCENG
	'@E 9,999,999.99'														, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) 	 							, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	'N'																		} ) //X3_PYME



aAdd( aSX3, { ;
	'CC2'																	, ; //X3_ARQUIVO
	'15'																	, ; //X3_ORDEM
	'CC2_XINTBP' 															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	1																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Int Braspres'															, ; //X3_TITULO
	'Int Braspres'															, ; //X3_TITSPA
	'Int Braspres'															, ; //X3_TITENG
	'Interior Braspress 	  '												, ; //X3_DESCRIC
	'Interior Braspress 	  '												, ; //X3_DESCSPA
	'Interior Braspress 	  '												, ; //X3_DESCENG
	'@E 9,999,999.99'														, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) 	 							, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	'N'																		} ) //X3_PYME

cOrdem := Soma1(cOrdem)   

aAdd( aSX3, { ;
	'SB1'																	, ; //X3_ARQUIVO
	cOrdem																	, ; //X3_ORDEM
	'B1_XVENREG'		  													, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	10																		, ; //X3_TAMANH
	0																		, ; //X3_DECIMAL
	'Ven.Registro'															, ; //X3_TITULO
	'Ven.Registro'															, ; //X3_TITSPA
	'Ven.Registro'															, ; //X3_TITENG
	'Venc. do Registro Anvisa '							   					, ; //X3_DESCRIC
	'Venc. do Registro Anvisa '												, ; //X3_DESCSPA
	'Venc. do Registro Anvisa '					   							, ; //X3_DESCENG
	'@!'			    													, ; //X3_PICTURE
	''								                                        , ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128)								, ; //X3_USADO
	''							                							, ; //X3_RELACAO
	''      																, ; //X3_F3
	 1																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''														   				, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	'U_xTRAVSB() .AND. U_XVENREG(M->B1_RANVISA,M->B1_CANVISA)'				, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
    '9'																		, ; //X3_FOLDER
	'N'																		} ) //X3_PYME
	
cOrdem := Soma1(cOrdem) 
aAdd( aSX3, { ;
	'SB1'																	, ; //X3_ARQUIVO
	cOrdem																	, ; //X3_ORDEM
	'B1_XVLCTL' 															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	2																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Valida. lote'															, ; //X3_TITULO
	'Valida. lote'															, ; //X3_TITSPA
	'Valida. lote'															, ; //X3_TITENG
	'Valid. lote prod em anos '												, ; //X3_DESCRIC
	'Valid. lote prod em anos '												, ; //X3_DESCSPA
	'Valid. lote prod em anos '												, ; //X3_DESCENG
	'99'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) 	 							, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	'3'																		, ; //X3_FOLDER
	''																		} ) //X3_PYME


//
// Tabela ZZF
//
aAdd( aSX3, { ;
	'ZZF'																	, ; //X3_ARQUIVO
	'01'																	, ; //X3_ORDEM
	'ZZF_FILIAL'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	2																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Filial'																, ; //X3_TITULO
	'Filial'																, ; //X3_TITSPA
	'Filial'																, ; //X3_TITENG
	'Filial'																, ; //X3_DESCRIC
	'Filial'																, ; //X3_DESCSPA
	'Filial'																, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	'033'																	, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	'N'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'ZZF'																	, ; //X3_ARQUIVO
	'02'																	, ; //X3_ORDEM
	'ZZF_CODIGO'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	6																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Codigo Negoc'															, ; //X3_TITULO
	'Codigo Negoc'															, ; //X3_TITSPA
	'Codigo Negoc'															, ; //X3_TITENG
	'Codigo Negoc'															, ; //X3_DESCRIC
	'Codigo Negoc'															, ; //X3_DESCSPA
	'Codigo Negoc'															, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	'NaoVazio().And.ExistChav("ZZF")'										, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(32)						, ; //X3_USADO
	'GetSXENum("ZZF","ZZF_CODIGO")'											, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	'N'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'ZZF'																	, ; //X3_ARQUIVO
	'03'																	, ; //X3_ORDEM
	'ZZF_CODCLI'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	6																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Cod Cliente'															, ; //X3_TITULO
	'Cod.Cliente'															, ; //X3_TITSPA
	'Cod.Cliente'															, ; //X3_TITENG
	'Cod.Cliente'															, ; //X3_DESCRIC
	'Cod.Cliente'															, ; //X3_DESCSPA
	'Cod.Cliente'															, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(32)						, ; //X3_USADO
	''																		, ; //X3_RELACAO
	'SA1'																	, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	'S'																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	'Empty(M->ZZF_GRPVEN)'													, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	'N'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'ZZF'																	, ; //X3_ARQUIVO
	'04'																	, ; //X3_ORDEM
	'ZZF_LOJA'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	2																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Loja'																	, ; //X3_TITULO
	'Loja'																	, ; //X3_TITSPA
	'Loja'																	, ; //X3_TITENG
	'Loja'																	, ; //X3_DESCRIC
	'Loja'																	, ; //X3_DESCSPA
	'Loja'																	, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(32)						, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	'N'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'ZZF'																	, ; //X3_ARQUIVO
	'05'																	, ; //X3_ORDEM
	'ZZF_NOMCLI'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	70																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Nome Cliente'															, ; //X3_TITULO
	'Nome Cliente'															, ; //X3_TITSPA
	'Nome Cliente'															, ; //X3_TITENG
	'Nome Cliente'															, ; //X3_DESCRIC
	'Nome Cliente'															, ; //X3_DESCSPA
	'Nome Cliente'															, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(32)						, ; //X3_USADO
	'If(Inclui,"",SA1->(Posicione("SA1",1,xFilial("SA1")+ZZF->(ZZF_CODCLI+ZZF_LOJA),"A1_NOME")))', ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'V'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	'SA1->(Posicione("SA1",1,xFilial("SA1")+ZZF->(ZZF_CODCLI+ZZF_LOJA),"A1_NOME"))', ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	'N'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'ZZF'																	, ; //X3_ARQUIVO
	'06'																	, ; //X3_ORDEM
	'ZZF_CONTRA'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	15																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Contrato'																, ; //X3_TITULO
	'Contrato'																, ; //X3_TITSPA
	'Contrato'																, ; //X3_TITENG
	'Contrato'																, ; //X3_DESCRIC
	'Contrato'																, ; //X3_DESCSPA
	'Contrato'																, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(32)						, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	'N'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'ZZF'																	, ; //X3_ARQUIVO
	'07'																	, ; //X3_ORDEM
	'ZZF_DATAIN'															, ; //X3_CAMPO
	'D'																		, ; //X3_TIPO
	8																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Data Ini'																, ; //X3_TITULO
	'Data Ini'																, ; //X3_TITSPA
	'Data Ini'																, ; //X3_TITENG
	'Data Ini'																, ; //X3_DESCRIC
	'Data Ini'																, ; //X3_DESCSPA
	'Data Ini'																, ; //X3_DESCENG
	'@D'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(32)						, ; //X3_USADO
	'If(Inclui,dDataBase,ZZF->ZZF_DATAIN)'									, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	'N'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'ZZF'																	, ; //X3_ARQUIVO
	'08'																	, ; //X3_ORDEM
	'ZZF_DATAFI'															, ; //X3_CAMPO
	'D'																		, ; //X3_TIPO
	8																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Data Fim'																, ; //X3_TITULO
	'Data Fim'																, ; //X3_TITSPA
	'Data Fim'																, ; //X3_TITENG
	'Data Fim'																, ; //X3_DESCRIC
	'Data Fim'																, ; //X3_DESCSPA
	'Data Fim'																, ; //X3_DESCENG
	'@D'																	, ; //X3_PICTURE
	'M->ZZF_DATAFI >= M->ZZF_DATAIN'										, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(32)					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	Chr(128)																, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	'N'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'ZZF'																	, ; //X3_ARQUIVO
	'09'																	, ; //X3_ORDEM
	'ZZF_USUARI'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	25																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Usuario'																, ; //X3_TITULO
	'Usuario'																, ; //X3_TITSPA
	'Usuario'																, ; //X3_TITENG
	'Usuario'																, ; //X3_DESCRIC
	'Usuario'																, ; //X3_DESCSPA
	'Usuario'																, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(32)						, ; //X3_USADO
	'If(Inclui,UsrFullName(RetCodUsr()),ZZF->ZZF_USUARI)'					, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	'N'																		} ) //X3_PYME
	
aAdd( aSX3, { ;
	'ZZF'																	, ; //X3_ARQUIVO
	'10'																	, ; //X3_ORDEM
	'ZZF_GRPVEN'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	6																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Grp.Clientes'															, ; //X3_TITULO
	'Grp.Clientes'															, ; //X3_TITSPA
	'Grp.Clientes'															, ; //X3_TITENG
	'Grp.Clientes'															, ; //X3_DESCRIC
	'Grp.Clientes'															, ; //X3_DESCSPA
	'Grp.Clientes'															, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(32)					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	'ACY'																	, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	'S'																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	'Empty(M->ZZF_CODCLI)'													, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	'N'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'ZZF'																	, ; //X3_ARQUIVO
	'11'																	, ; //X3_ORDEM
	'ZZF_GRPDES'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	70																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Grp.Descric.'															, ; //X3_TITULO
	'Grp.Descric.'															, ; //X3_TITSPA
	'Grp.Descric.'															, ; //X3_TITENG
	'Grp.Descric.'															, ; //X3_DESCRIC
	'Grp.Descric.'															, ; //X3_DESCSPA
	'Grp.Descric.'															, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(32)					, ; //X3_USADO
	'If(Inclui,"",ACY->(Posicione("ACY",1,xFilial("ACY")+ZZF->ZZF_GRPVEN,"ACY_DESCRI")))', ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'V'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	'ACY->(Posicione("ACY",1,xFilial("ACY")+ZZF->ZZF_GRPVEN,"ACY_DESCRI"))'	, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	'N'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'ZZF'																	, ; //X3_ARQUIVO
	'12'																	, ; //X3_ORDEM
	'ZZF_EXPLIC'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	250																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Explicacao'															, ; //X3_TITULO
	'Explicacao'															, ; //X3_TITSPA
	'Explicacao'															, ; //X3_TITENG
	'Explicacao'															, ; //X3_DESCRIC
	'Explicacao'															, ; //X3_DESCSPA
	'Explicacao'															, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(32)					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	'N'																		} ) //X3_PYME


aAdd( aSX3, { ;
	'ZZF'																	, ; //X3_ARQUIVO
	'13'																	, ; //X3_ORDEM
	'ZZF_ATIVO'														  		, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	1																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Cont. Ativo'															, ; //X3_TITULO
	'Cont. Ativo'															, ; //X3_TITSPA
	'Cont. Ativo'															, ; //X3_TITENG
	'Cont. Ativo'															, ; //X3_DESCRIC
	'Cont. Ativo'															, ; //X3_DESCSPA
	'Cont. Ativo'															, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(32)					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	'S'																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	'1=Ativar;2=Aguardar'													, ; //X3_CBOX
	'1=Ativar;2=Aguardar'													, ; //X3_CBOXSPA
	'1=Ativar;2=Aguardar'													, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	'!Inclui .And. Upper(u_DipUsr())$GetNewPar("ES_USRAPRO","")'			, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	'N'																		} ) //X3_PYME 
	
aAdd( aSX3, { ;
	'ZZF'																	, ; //X3_ARQUIVO
	'14'																	, ; //X3_ORDEM
	'ZZF_USUAPR'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	25																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Aprovador'																, ; //X3_TITULO
	'Aprovador'																, ; //X3_TITSPA
	'Aprovador'																, ; //X3_TITENG
	'Aprovador'																, ; //X3_DESCRIC
	'Aprovador'																, ; //X3_DESCSPA
	'Aprovador'																, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(32)					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	'N'																		} ) //X3_PYME	

//
// Tabela ZZG
//
aAdd( aSX3, { ;
	'ZZG'																	, ; //X3_ARQUIVO
	'01'																	, ; //X3_ORDEM
	'ZZG_FILIAL'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	2																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Filial'																, ; //X3_TITULO
	'Filial'																, ; //X3_TITSPA
	'Filial'																, ; //X3_TITENG
	'Filial'																, ; //X3_DESCRIC
	'Filial'																, ; //X3_DESCSPA
	'Filial'																, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	'033'																	, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	'N'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'ZZG'																	, ; //X3_ARQUIVO
	'02'																	, ; //X3_ORDEM
	'ZZG_CODIGO'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	6																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Codigo Negoc'															, ; //X3_TITULO
	'Codigo Negoc'															, ; //X3_TITSPA
	'Codigo Negoc'															, ; //X3_TITENG
	'Codigo Negoc'															, ; //X3_DESCRIC
	'Codigo Negoc'															, ; //X3_DESCSPA
	'Codigo Negoc'															, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	'N'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'ZZG'																	, ; //X3_ARQUIVO
	'03'																	, ; //X3_ORDEM
	'ZZG_SEQUEN'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	3																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Item'																	, ; //X3_TITULO
	'Item'																	, ; //X3_TITSPA
	'Item'																	, ; //X3_TITENG
	'Item'																	, ; //X3_DESCRIC
	'Item'																	, ; //X3_DESCSPA
	'Item'																	, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(32)						, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	'N'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'ZZG'																	, ; //X3_ARQUIVO
	'04'																	, ; //X3_ORDEM
	'ZZG_PRODUT'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	15																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Produto'																, ; //X3_TITULO
	'Produto'																, ; //X3_TITSPA
	'Produto'																, ; //X3_TITENG
	'Produto'																, ; //X3_DESCRIC
	'Produto'																, ; //X3_DESCSPA
	'Produto'																, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	'Vazio() .Or. ExistCPO("SB1")'											, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(32)						, ; //X3_USADO
	''																		, ; //X3_RELACAO
	'SB1'																	, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	'S'																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	'N'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'ZZG'																	, ; //X3_ARQUIVO
	'05'																	, ; //X3_ORDEM
	'ZZG_DESCRI'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	60																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Descricao'																, ; //X3_TITULO
	'Descricao'																, ; //X3_TITSPA
	'Descricao'																, ; //X3_TITENG
	'Descricao'																, ; //X3_DESCRIC
	'Descricao'																, ; //X3_DESCSPA
	'Descricao'																, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(32)						, ; //X3_USADO
	'If(Inclui,"",SB1->(Posicione("SB1",1,xFilial("SB1")+ZZG->(ZZG_PRODUT),"B1_DESC")))', ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'V'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	'SB1->(Posicione("SB1",1,xFilial("SB1")+ZZG->(ZZG_PRODUT),"B1_DESC"))'		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	'N'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'ZZG'																	, ; //X3_ARQUIVO
	'06'																	, ; //X3_ORDEM
	'ZZG_VALOR'																, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	12																		, ; //X3_TAMANHO
	4																		, ; //X3_DECIMAL
	'Valor'																	, ; //X3_TITULO
	'Valor'																	, ; //X3_TITSPA
	'Valor'																	, ; //X3_TITENG
	'Valor'																	, ; //X3_DESCRIC
	'Valor'																	, ; //X3_DESCSPA
	'Valor'																	, ; //X3_DESCENG
	'@E 99,999,999.9999'													, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(32)						, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	'S'																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	'N'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'DTC'																	, ; //X3_ARQUIVO
	'D2'																	, ; //X3_ORDEM
	'DTC_XAVERE'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	1																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'J· Averb. E'															, ; //X3_TITULO
	'J· Averb. E'															, ; //X3_TITSPA
	'J· Averb. E'															, ; //X3_TITENG
	'J· Averb. Emovere'														, ; //X3_DESCRIC
	'J· Averb. Emovere'														, ; //X3_DESCSPA
	'J· Averb. Emovere'														, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	'N'																		} ) //X3_PYME

/*                       
aAdd( aSX3, { ;
	'SA1'																	, ; //X3_ARQUIVO
	'L3'																	, ; //X3_ORDEM
	'A1_VLDANV'																, ; //X3_CAMPO
	'D'																		, ; //X3_TIPO
	8																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Vld.ANVISA'															, ; //X3_TITULO
	'Vld.ANVISA'															, ; //X3_TITSPA
	'Vld.ANVISA'															, ; //X3_TITENG
	'Validade ANVISA'														, ; //X3_DESCRIC
	'Validade ANVISA'														, ; //X3_DESCSPA
	'Validade ANVISA'														, ; //X3_DESCENG
	''																		, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	'U_DIPWHEN() .OR. INCLUI'												, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	'6'																		, ; //X3_FOLDER
	'N'																		} ) //X3_PYME
 */
                       
aAdd( aSX3, { ;
	'SA1'																	, ; //X3_ARQUIVO
	'L4'																	, ; //X3_ORDEM
	'A1_XCXDIPR'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	1																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Cx. Dipromed'															, ; //X3_TITULO
	'Cx. Dipromed'															, ; //X3_TITSPA
	'Cx. Dipromed'															, ; //X3_TITENG
	'Caixa Dipromed'														, ; //X3_DESCRIC
	'Caixa Dipromed'														, ; //X3_DESCSPA
	'Caixa Dipromed'														, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128)								, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	'S=Sim;N=N„o'															, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	'U_DIPWHEN() .OR. INCLUI'												, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	'4'																		, ; //X3_FOLDER
	'N'																		} ) //X3_PYME


aAdd( aSX3, { ;
	'SA1'																	, ; //X3_ARQUIVO
	'L5'																	, ; //X3_ORDEM
	'A1_XVAMCOR'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	1																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Pd.Vd. AMCOR'															, ; //X3_TITULO
	'Pd.Vd. AMCOR'															, ; //X3_TITSPA
	'Pd.Vd. AMCOR'															, ; //X3_TITENG
	'Pode Vender AMCOR'														, ; //X3_DESCRIC
	'Pode Vender AMCOR'														, ; //X3_DESCSPA
	'Pode Vender AMCOR'														, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128)								, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	'S=Sim;N=N„o'															, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	'U_DIPWHEN() .OR. INCLUI'												, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	'4'																		, ; //X3_FOLDER
	'N'																		} ) //X3_PYME
	                                                                                     
aAdd( aSX3, { ;
	'SA1'																	, ; //X3_ARQUIVO
	'X8'																	, ; //X3_ORDEM
	'A1_AFEVISC'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	10																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'AFE Cosmet  '															, ; //X3_TITULO
	'AFE Cosmet  '															, ; //X3_TITSPA
	'AFE Cosmet  '															, ; //X3_TITENG
	'Afe Cosmet    '														, ; //X3_DESCRIC
	'Afe Cosmet    '														, ; //X3_DESCSPA
	'Afe Cosmet    '														, ; //X3_DESCENG
	'@R 9.99999.9'															, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128)								, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	'U_DIPWHEN() .OR. INCLUI'												, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	'6'																		, ; //X3_FOLDER
	'N'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SA1'																	, ; //X3_ARQUIVO
	'X9'																	, ; //X3_ORDEM
	'A1_SITAFEC'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	7																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Sit  AFE Cos'															, ; //X3_TITULO
	'Sit  AFE Cos'															, ; //X3_TITSPA
	'Sit  AFE Cos'															, ; //X3_TITENG
	'Sit  AFE Cos             '												, ; //X3_DESCRIC
	'Sit  AFE Cos			  '												, ; //X3_DESCSPA
	'Sit  AFE Cos			  '												, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128)								, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	'1=Ativo;2=Inativo'														, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	'U_DIPWHEN() .OR. INCLUI'												, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	'6'																		, ; //X3_FOLDER
	'N'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SA1'																	, ; //X3_ARQUIVO
	'Y0'																	, ; //X3_ORDEM
	'A1_AFEVISS'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	10																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'AFE Saude   '															, ; //X3_TITULO
	'AFE Saude   '															, ; //X3_TITSPA
	'AFE Saude   '															, ; //X3_TITENG
	'AFE Saude     '														, ; //X3_DESCRIC
	'AFE Saude     '														, ; //X3_DESCSPA
	'AFE Saude     '														, ; //X3_DESCENG
	'@R 9.99999.9'															, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128)								, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	'U_DIPWHEN() .OR. INCLUI'												, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	'6'																		, ; //X3_FOLDER
	'N'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SA1'																	, ; //X3_ARQUIVO
	'Y1'																	, ; //X3_ORDEM
	'A1_SITAFES'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	7																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Sit AFE Sau '															, ; //X3_TITULO
	'Sit AFE Sau '															, ; //X3_TITSPA
	'Sit AFE Sau '															, ; //X3_TITENG
	'Sit AFE Sau              '												, ; //X3_DESCRIC
	'Sit AFE Sau 			  '												, ; //X3_DESCSPA
	'Sit AFE Sau 			  '												, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128)								, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	'1=Ativo;2=Inativo'														, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	'U_DIPWHEN() .OR. INCLUI'												, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	'6'																		, ; //X3_FOLDER
	'N'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SA1'																	, ; //X3_ARQUIVO
	'Y2'																	, ; //X3_ORDEM
	'A1_AFEVISN'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	10																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'AFE Sanean	 '															, ; //X3_TITULO
	'AFE Sanean	 '															, ; //X3_TITSPA
	'AFE Sanean	 '															, ; //X3_TITENG
	'AFE Sanean	   '														, ; //X3_DESCRIC
	'AFE Sanean	   '														, ; //X3_DESCSPA
	'AFE Sanean	   '														, ; //X3_DESCENG
	'@R 9.99999.9'															, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128)								, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	'U_DIPWHEN() .OR. INCLUI'												, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	'6'																		, ; //X3_FOLDER
	'N'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SA1'																	, ; //X3_ARQUIVO
	'Y3'																	, ; //X3_ORDEM
	'A1_SITAFEN'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	7																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Sit AFE San '															, ; //X3_TITULO
	'Sit AFE San '															, ; //X3_TITSPA
	'Sit AFE San '															, ; //X3_TITENG
	'Sit AFE San              '												, ; //X3_DESCRIC
	'Sit AFE San 			  '												, ; //X3_DESCSPA
	'Sit AFE San 			  '												, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128)								, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	'1=Ativo;2=Inativo'														, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	'U_DIPWHEN() .OR. INCLUI'												, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	'6'																		, ; //X3_FOLDER
	'N'																		} ) //X3_PYME
	                                                                                     
aAdd( aSX3, { ;
	'SA1'																	, ; //X3_ARQUIVO
	'Y4'																	, ; //X3_ORDEM
	'A1_OBSANV'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	100																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Obs. Anvisa '															, ; //X3_TITULO
	'Obs. Anvisa '															, ; //X3_TITSPA
	'Obs. Anvisa '															, ; //X3_TITENG
	'Obs. Anvisa              '												, ; //X3_DESCRIC
	'Obs. Anvisa 			  '												, ; //X3_DESCSPA
	'Obs. Anvisa 			  '												, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128)								, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	'U_DIPWHEN() .OR. INCLUI'												, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	'6'																		, ; //X3_FOLDER
	'N'																		} ) //X3_PYME
	
//
// Tabela ZZI
//
aAdd( aSX3, { ;
	'ZZI'																	, ; //X3_ARQUIVO
	'01'																	, ; //X3_ORDEM
	'ZZI_FILIAL'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	2																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Filial'																, ; //X3_TITULO
	'Filial'																, ; //X3_TITSPA
	'Filial'																, ; //X3_TITENG
	'Filial'																, ; //X3_DESCRIC
	'Filial'																, ; //X3_DESCSPA
	'Filial'																, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	'N'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'ZZI'																	, ; //X3_ARQUIVO
	'02'																	, ; //X3_ORDEM
	'ZZI_CODMSG'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	6																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Cod.Mensagem'															, ; //X3_TITULO
	'Cod.Mensagem'															, ; //X3_TITSPA
	'Cod.Mensagem'															, ; //X3_TITENG
	'Cod.Mensagem'															, ; //X3_DESCRIC
	'Cod.Mensagem'															, ; //X3_DESCSPA
	'Cod.Mensagem'															, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(32)						, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	'N'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'ZZI'																	, ; //X3_ARQUIVO
	'03'																	, ; //X3_ORDEM
	'ZZI_EMAIL'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	250																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Email'																	, ; //X3_TITULO
	'Email'																	, ; //X3_TITSPA
	'Email'																	, ; //X3_TITENG
	'Email'																	, ; //X3_DESCRIC
	'Email'																	, ; //X3_DESCSPA
	'Email'																	, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(32)						, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	'N'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'ZZI'																	, ; //X3_ARQUIVO
	'04'																	, ; //X3_ORDEM
	'ZZI_ASSUNT'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	250																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Assunto'																, ; //X3_TITULO
	'Assunto'																, ; //X3_TITSPA
	'Assunto'																, ; //X3_TITENG
	'Assunto'																, ; //X3_DESCRIC
	'Assunto'																, ; //X3_DESCSPA
	'Assunto'																, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(32)						, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	'N'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'ZZI'																	, ; //X3_ARQUIVO
	'05'																	, ; //X3_ORDEM
	'ZZI_MSG1'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	250																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Msg 1'																	, ; //X3_TITULO
	'Msg 1'																	, ; //X3_TITSPA
	'Msg 1'																	, ; //X3_TITENG
	'Msg 1'																	, ; //X3_DESCRIC
	'Msg 1'																	, ; //X3_DESCSPA
	'Msg 1'																	, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(32)						, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	'N'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'ZZI'																	, ; //X3_ARQUIVO
	'06'																	, ; //X3_ORDEM
	'ZZI_MSG2'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	250																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Msg 2'																	, ; //X3_TITULO
	'Msg 2'																	, ; //X3_TITSPA
	'Msg 2'																	, ; //X3_TITENG
	'Msg 2'																	, ; //X3_DESCRIC
	'Msg 2'																	, ; //X3_DESCSPA
	'Msg 2'																	, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(32)						, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	'N'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'ZZI'																	, ; //X3_ARQUIVO
	'07'																	, ; //X3_ORDEM
	'ZZI_ANEXO'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	250																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Anexo'																	, ; //X3_TITULO
	'Anexo'																	, ; //X3_TITSPA
	'Anexo'																	, ; //X3_TITENG
	'Anexo'																	, ; //X3_DESCRIC
	'Anexo'																	, ; //X3_DESCSPA
	'Anexo'																	, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(32)						, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	'N'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'ZZI'																	, ; //X3_ARQUIVO
	'08'																	, ; //X3_ORDEM
	'ZZI_MAILDE'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	250																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Email DE'																, ; //X3_TITULO
	'Email DE'																, ; //X3_TITSPA
	'Email DE'																, ; //X3_TITENG
	'Email DE'																, ; //X3_DESCRIC
	'Email DE'																, ; //X3_DESCSPA
	'Email DE'																, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(32)						, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	'N'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'ZZI'																	, ; //X3_ARQUIVO
	'09'																	, ; //X3_ORDEM
	'ZZI_FUNCAO'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	250																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Funcao'																, ; //X3_TITULO
	'Funcao'																, ; //X3_TITSPA
	'Funcao'																, ; //X3_TITENG
	'Funcao'																, ; //X3_DESCRIC
	'Funcao'																, ; //X3_DESCSPA
	'Funcao'																, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(32)						, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	'N'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'ZZI'																	, ; //X3_ARQUIVO
	'10'																	, ; //X3_ORDEM
	'ZZI_DATA'																, ; //X3_CAMPO
	'D'																		, ; //X3_TIPO
	8																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Data'																	, ; //X3_TITULO
	'Data'																	, ; //X3_TITSPA
	'Data'																	, ; //X3_TITENG
	'Data'																	, ; //X3_DESCRIC
	'Data'																	, ; //X3_DESCSPA
	'Data'																	, ; //X3_DESCENG
	'@D'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(32)						, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	'N'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'ZZI'																	, ; //X3_ARQUIVO
	'11'																	, ; //X3_ORDEM
	'ZZI_HORA'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	8																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Hora'																	, ; //X3_TITULO
	'Hora'																	, ; //X3_TITSPA
	'Hora'																	, ; //X3_TITENG
	'Hora'																	, ; //X3_DESCRIC
	'Hora'																	, ; //X3_DESCSPA
	'Hora'																	, ; //X3_DESCENG
	'@R 99:99:99'															, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(32)						, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	'N'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'ZZI'																	, ; //X3_ARQUIVO
	'12'																	, ; //X3_ORDEM
	'ZZI_USUARI'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	25																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Usuario'																, ; //X3_TITULO
	'Usuario'																, ; //X3_TITSPA
	'Usuario'																, ; //X3_TITENG
	'Usuario'																, ; //X3_DESCRIC
	'Usuario'																, ; //X3_DESCSPA
	'Usuario'																, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(32)						, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	'N'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'ZZI'																	, ; //X3_ARQUIVO
	'13'																	, ; //X3_ORDEM
	'ZZI_SEQUEN'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	3																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Sequencia'																, ; //X3_TITULO
	'Sequencia'																, ; //X3_TITSPA
	'Sequencia'																, ; //X3_TITENG
	'Sequencia'																, ; //X3_DESCRIC
	'Sequencia'																, ; //X3_DESCSPA
	'Sequencia'																, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(32)						, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	'N'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'ZZI'																	, ; //X3_ARQUIVO
	'14'																	, ; //X3_ORDEM
	'ZZI_EMAIL2'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	250																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Email 2'																, ; //X3_TITULO
	'Email 2'																, ; //X3_TITSPA
	'Email 2'																, ; //X3_TITENG
	'Email 2'																, ; //X3_DESCRIC
	'Email 2'																, ; //X3_DESCSPA
	'Email 2'																, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(32)						, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	'N'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'ZZI'																	, ; //X3_ARQUIVO
	'15'																	, ; //X3_ORDEM
	'ZZI_HTML'															, ; //X3_CAMPO
	'M'																		, ; //X3_TIPO
	80																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Email html'																, ; //X3_TITULO
	'Email html'																, ; //X3_TITSPA
	'Email html'																, ; //X3_TITENG
	'Email html'																, ; //X3_DESCRIC
	'Email html'																, ; //X3_DESCSPA
	'Email html'																, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) 								, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	'N'																		} ) //X3_PYME

//
// Tabela ZZJ
//
aAdd( aSX3, { ;
	'ZZJ'																	, ; //X3_ARQUIVO
	'01'																	, ; //X3_ORDEM
	'ZZJ_FILIAL'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	2																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Filial'																, ; //X3_TITULO
	'Filial'																, ; //X3_TITSPA
	'Filial'																, ; //X3_TITENG
	'Filial'																, ; //X3_DESCRIC
	'Filial'																, ; //X3_DESCSPA
	'Filial'																, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	'033'																	, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	'N'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'ZZJ'																	, ; //X3_ARQUIVO
	'02'																	, ; //X3_ORDEM
	'ZZJ_CODMSG'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	6																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Cod.Mensagem'															, ; //X3_TITULO
	'Cod.Mensagem'															, ; //X3_TITSPA
	'Cod.Mensagem'															, ; //X3_TITENG
	'Cod.Mensagem'															, ; //X3_DESCRIC
	'Cod.Mensagem'															, ; //X3_DESCSPA
	'Cod.Mensagem'															, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(32)						, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	'N'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'ZZJ'																	, ; //X3_ARQUIVO
	'03'																	, ; //X3_ORDEM
	'ZZJ_CIC'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	250																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Cic'																	, ; //X3_TITULO
	'Cic'																	, ; //X3_TITSPA
	'Cic'																	, ; //X3_TITENG
	'Cic'																	, ; //X3_DESCRIC
	'Cic'																	, ; //X3_DESCSPA
	'Cic'																	, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(32)						, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	'N'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'ZZJ'																	, ; //X3_ARQUIVO
	'04'																	, ; //X3_ORDEM
	'ZZJ_CIC2'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	250																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Cic 2'																	, ; //X3_TITULO
	'Cic 2'																	, ; //X3_TITSPA
	'Cic 2'																	, ; //X3_TITENG
	'Cic 2'																	, ; //X3_DESCRIC
	'Cic 2'																	, ; //X3_DESCSPA
	'Cic 2'																	, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(32)						, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	'N'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'ZZJ'																	, ; //X3_ARQUIVO
	'05'																	, ; //X3_ORDEM
	'ZZJ_MSG'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	250																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Msg'																	, ; //X3_TITULO
	'Msg'																	, ; //X3_TITSPA
	'Msg'																	, ; //X3_TITENG
	'Msg'																	, ; //X3_DESCRIC
	'Msg'																	, ; //X3_DESCSPA
	'Msg'																	, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(32)						, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	'N'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'ZZJ'																	, ; //X3_ARQUIVO
	'06'																	, ; //X3_ORDEM
	'ZZJ_MSG2'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	250																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Msg 2'																	, ; //X3_TITULO
	'Msg 2'																	, ; //X3_TITSPA
	'Msg 2'																	, ; //X3_TITENG
	'Msg 2'																	, ; //X3_DESCRIC
	'Msg 2'																	, ; //X3_DESCSPA
	'Msg 2'																	, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(32)						, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	'N'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'ZZJ'																	, ; //X3_ARQUIVO
	'07'																	, ; //X3_ORDEM
	'ZZJ_DATA'																, ; //X3_CAMPO
	'D'																		, ; //X3_TIPO
	8																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Data'																	, ; //X3_TITULO
	'Data'																	, ; //X3_TITSPA
	'Data'																	, ; //X3_TITENG
	'Data'																	, ; //X3_DESCRIC
	'Data'																	, ; //X3_DESCSPA
	'Data'																	, ; //X3_DESCENG
	'@D'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(32)						, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	'N'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'ZZJ'																	, ; //X3_ARQUIVO
	'08'																	, ; //X3_ORDEM
	'ZZJ_HORA'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	8																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Hora'																	, ; //X3_TITULO
	'Hora'																	, ; //X3_TITSPA
	'Hora'																	, ; //X3_TITENG
	'Hora'																	, ; //X3_DESCRIC
	'Hora'																	, ; //X3_DESCSPA
	'Hora'																	, ; //X3_DESCENG
	'@R 99:99:99'															, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(32)						, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	'N'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'ZZJ'																	, ; //X3_ARQUIVO
	'09'																	, ; //X3_ORDEM
	'ZZJ_USUARI'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	25																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Usuari'																, ; //X3_TITULO
	'Usuari'																, ; //X3_TITSPA
	'Usuari'																, ; //X3_TITENG
	'Usuari'																, ; //X3_DESCRIC
	'Usuari'																, ; //X3_DESCSPA
	'Usuari'																, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(32)						, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	'N'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'ZZJ'																	, ; //X3_ARQUIVO
	'10'																	, ; //X3_ORDEM
	'ZZJ_REMOTE'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	250																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Remote Ini'															, ; //X3_TITULO
	'Remote Ini'															, ; //X3_TITSPA
	'Remote Ini'															, ; //X3_TITENG
	'Remote Ini'															, ; //X3_DESCRIC
	'Remote Ini'															, ; //X3_DESCSPA
	'Remote Ini'															, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	'N'																		} ) //X3_PYME


//
// Tabela ZZK
//
aAdd( aSX3, { ;
	'ZZK'																	, ; //X3_ARQUIVO
	'01'																	, ; //X3_ORDEM
	'ZZK_FILIAL'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	2																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Filial'																, ; //X3_TITULO
	'Filial'																, ; //X3_TITSPA
	'Filial'																, ; //X3_TITENG
	'Filial'																, ; //X3_DESCRIC
	'Filial'																, ; //X3_DESCSPA
	'Filial'																, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	'N'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'ZZK'																	, ; //X3_ARQUIVO
	'02'																	, ; //X3_ORDEM
	'ZZK_PEDIDO'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	6																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Pedido'																, ; //X3_TITULO
	'Pedido'																, ; //X3_TITSPA
	'Pedido'																, ; //X3_TITENG
	'Pedido'																, ; //X3_DESCRIC
	'Pedido'																, ; //X3_DESCSPA
	'Pedido'																, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	'N'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'ZZK'																	, ; //X3_ARQUIVO
	'03'																	, ; //X3_ORDEM
	'ZZK_PRODUT'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	15																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Produto'																, ; //X3_TITULO
	'Produto'																, ; //X3_TITSPA
	'Produto'																, ; //X3_TITENG
	'Produto'																, ; //X3_DESCRIC
	'Produto'																, ; //X3_DESCSPA
	'Produto'																, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	'N'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'ZZK'																	, ; //X3_ARQUIVO
	'04'																	, ; //X3_ORDEM
	'ZZK_QUANTI'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	10																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Quantidade'															, ; //X3_TITULO
	'Quantidade'															, ; //X3_TITSPA
	'Quantidade'															, ; //X3_TITENG
	'Quantidade'															, ; //X3_DESCRIC
	'Quantidade'															, ; //X3_DESCSPA
	'Quantidade'															, ; //X3_DESCENG
	'@E 9,999,999'															, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	'N'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'ZZK'																	, ; //X3_ARQUIVO
	'05'																	, ; //X3_ORDEM
	'ZZK_VLRAPR'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	11																		, ; //X3_TAMANHO
	4																		, ; //X3_DECIMAL
	'Vlr. Aprovad'															, ; //X3_TITULO
	'Vlr. Aprovad'															, ; //X3_TITSPA
	'Vlr. Aprovad'															, ; //X3_TITENG
	'Vlr. Aprovad'															, ; //X3_DESCRIC
	'Vlr. Aprovad'															, ; //X3_DESCSPA
	'Vlr. Aprovad'															, ; //X3_DESCENG
	'@E 99,999,999.9999'													, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	'N'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'ZZK'																	, ; //X3_ARQUIVO
	'06'																	, ; //X3_ORDEM
	'ZZK_ITEM'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	2																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Item'																	, ; //X3_TITULO
	'Item'																	, ; //X3_TITSPA
	'Item'																	, ; //X3_TITENG
	'Item do pedido'														, ; //X3_DESCRIC
	'Item do pedido'														, ; //X3_DESCSPA
	'Item do pedido'														, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	'N'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'ZZK'																	, ; //X3_ARQUIVO
	'07'																	, ; //X3_ORDEM
	'ZZK_VLRSIS'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	11																		, ; //X3_TAMANHO
	4																		, ; //X3_DECIMAL
	'Vlr. Sistema'															, ; //X3_TITULO
	'Vlr. Sistema'															, ; //X3_TITSPA
	'Vlr. Sistema'															, ; //X3_TITENG
	'Vlr. Sistema'															, ; //X3_DESCRIC
	'Vlr. Sistema'															, ; //X3_DESCSPA
	'Vlr. Sistema'															, ; //X3_DESCENG
	'@E 99,999,999.9999'													, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	'N'																		} ) //X3_PYME


aAdd( aSX3, { ;
	'ZZK'																	, ; //X3_ARQUIVO
	'08'																	, ; //X3_ORDEM
	'ZZK_STATUS'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	10																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Status'																, ; //X3_TITULO
	'Status'																, ; //X3_TITSPA
	'Status'																, ; //X3_TITENG
	'Status do pedido'														, ; //X3_DESCRIC
	'Status do pedido'														, ; //X3_DESCSPA
	'Status do pedido'														, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) 								, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	'N'																		} ) //X3_PYME


aAdd( aSX3, { ;
	'ZZK'																	, ; //X3_ARQUIVO
	'09'																	, ; //X3_ORDEM
	'ZZK_SEQUEN'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	3																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Sequencia'																, ; //X3_TITULO
	'Sequencia'																, ; //X3_TITSPA
	'Sequencia'																, ; //X3_TITENG
	'Sequencia'																, ; //X3_DESCRIC
	'Sequencia'																, ; //X3_DESCSPA
	'Sequencia'																, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) 								, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	'N'																		} ) //X3_PYME


aAdd( aSX3, { ;
	'ZZK'																	, ; //X3_ARQUIVO
	'10'																	, ; //X3_ORDEM
	'ZZK_VLRSUP'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	12																		, ; //X3_TAMANHO
	4																		, ; //X3_DECIMAL
	'Promocao'																, ; //X3_TITULO
	'Promocao'																, ; //X3_TITSPA
	'Promocao'																, ; //X3_TITENG
	'Promocao'																, ; //X3_DESCRIC
	'Promocao'																, ; //X3_DESCSPA
	'Promocao'									   							, ; //X3_DESCENG
	'@E 999,999.9999'														, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) 	 							, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	'N'																		} ) //X3_PYME


aAdd( aSX3, { ;
	'ZZK'																	, ; //X3_ARQUIVO
	'11'																	, ; //X3_ORDEM
	'ZZK_VLRMIN'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	12																		, ; //X3_TAMANHO
	4																		, ; //X3_DECIMAL
	'Preco C'																, ; //X3_TITULO
	'Preco C'																, ; //X3_TITSPA
	'Preco C'																, ; //X3_TITENG
	'Preco C'																, ; //X3_DESCRIC
	'Preco C'																, ; //X3_DESCSPA
	'Preco C'																, ; //X3_DESCENG
	'@E 999,999.9999'														, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) 	 							, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	'N'																		} ) //X3_PYME


aAdd( aSX3, { ;
	'ZZK'																	, ; //X3_ARQUIVO
	'12'																	, ; //X3_ORDEM
	'ZZK_CUSDIP'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	12																		, ; //X3_TAMANHO
	4																		, ; //X3_DECIMAL
	'Custo Dip.'															, ; //X3_TITULO
	'Custo Dip.'															, ; //X3_TITSPA
	'Custo Dip.'															, ; //X3_TITENG
	'Custo Dipromed'														, ; //X3_DESCRIC
	'Custo Dipromed'														, ; //X3_DESCSPA
	'Custo Dipromed'														, ; //X3_DESCENG
	'@E 999,999.9999'														, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) 	 							, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	'N'																		} ) //X3_PYME
	
aAdd( aSX3, { ;
	'ZZK'																	, ; //X3_ARQUIVO
	'13'																	, ; //X3_ORDEM
	'ZZK_LISFOR'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	12																		, ; //X3_TAMANHO
	4																		, ; //X3_DECIMAL
	'Prc. Fornece'															, ; //X3_TITULO
	'Prc. Fornece'															, ; //X3_TITSPA
	'Prc. Fornece'															, ; //X3_TITENG
	'Preco Fornece'															, ; //X3_DESCRIC
	'Preco Fornece'															, ; //X3_DESCSPA
	'Preco Fornece'															, ; //X3_DESCENG
	'@E 999,999.9999'														, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) 	 							, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	'N'																		} ) //X3_PYME	

aAdd( aSX3, { ;
	'ZZK'																	, ; //X3_ARQUIVO
	'14'																	, ; //X3_ORDEM
	'ZZK_MARDIP'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	10																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Margem Dip'															, ; //X3_TITULO
	'Margem Dip'															, ; //X3_TITSPA
	'Margem Dip'															, ; //X3_TITENG
	'Margem Dipromed'														, ; //X3_DESCRIC
	'Margem Dipromed'														, ; //X3_DESCSPA
	'Margem Dipromed'														, ; //X3_DESCENG
	'@E 999,999.99 %'														, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) 	 							, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	'N'																		} ) //X3_PYME	
	

aAdd( aSX3, { ;
	'ZZK'																	, ; //X3_ARQUIVO
	'15'																	, ; //X3_ORDEM
	'ZZK_MARFOR'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	10																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Margem PRC'															, ; //X3_TITULO
	'Margem PRC'															, ; //X3_TITSPA
	'Margem PRC'															, ; //X3_TITENG
	'Margem Forneced'														, ; //X3_DESCRIC
	'Margem Forneced'														, ; //X3_DESCSPA
	'Margem Forneced'														, ; //X3_DESCENG
	'@E 999,999.99 %'														, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) 	 							, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	'N'																		} ) //X3_PYME	

aAdd( aSX3, { ;
	'ZZK'																	, ; //X3_ARQUIVO
	'16'																	, ; //X3_ORDEM
	'ZZK_VLRSUG'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	12																		, ; //X3_TAMANHO
	4																		, ; //X3_DECIMAL
	'Prc. Suger.'															, ; //X3_TITULO
	'Prc. Suger.'															, ; //X3_TITSPA
	'Prc. Suger.'															, ; //X3_TITENG
	'Preco Sugerido'														, ; //X3_DESCRIC
	'Preco Sugerido'														, ; //X3_DESCSPA
	'Preco Sugerido'														, ; //X3_DESCENG
	'@E 999,999.9999'														, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) 	 							, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	'N'																		} ) //X3_PYME	
	
aAdd( aSX3, { ;
	'ZZK'																	, ; //X3_ARQUIVO
	'17'																	, ; //X3_ORDEM
	'ZZK_ESTOQU'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	10																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Estoque'																, ; //X3_TITULO
	'Estoque'																, ; //X3_TITSPA
	'Estoque'																, ; //X3_TITENG
	'Total Estoque'										  					, ; //X3_DESCRIC
	'Total Estoque'															, ; //X3_DESCSPA
	'Total Estoque'										 					, ; //X3_DESCENG
	'@E 99,999,999'															, ; //X3_PICTURE
	''													 					, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) 	 							, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	'N'																		} ) //X3_PYME	
		
	
aAdd( aSX3, { ;
	'ZZK'																	, ; //X3_ARQUIVO
	'18'																	, ; //X3_ORDEM
	'ZZK_CONSUM'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	10																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Consumo'																, ; //X3_TITULO
	'Consumo'																, ; //X3_TITSPA
	'Consumo'																, ; //X3_TITENG
	'Consumo'											  					, ; //X3_DESCRIC
	'Consumo'																, ; //X3_DESCSPA
	'Consumo'											 					, ; //X3_DESCENG
	'@E 99,999,999'															, ; //X3_PICTURE
	''													 					, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) 	 							, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	'N'																		} ) //X3_PYME	


aAdd( aSX3, { ;
	'ZZK'																	, ; //X3_ARQUIVO
	'19'																	, ; //X3_ORDEM
	'ZZK_DATA'																, ; //X3_CAMPO
	'D'																		, ; //X3_TIPO
	8																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Data'													   				, ; //X3_TITULO
	'Data'																	, ; //X3_TITSPA
	'Data'																	, ; //X3_TITENG
	'Data'											  						, ; //X3_DESCRIC
	'Data'																	, ; //X3_DESCSPA
	'Data'											 						, ; //X3_DESCENG
	'@D'																	, ; //X3_PICTURE
	''													 					, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) 	 							, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	'N'																		} ) //X3_PYME	
	
aAdd( aSX3, { ;
	'ZZK'																	, ; //X3_ARQUIVO
	'20'																	, ; //X3_ORDEM
	'ZZK_HORA'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	5																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Hora'													   				, ; //X3_TITULO
	'Hora'																	, ; //X3_TITSPA
	'Hora'																	, ; //X3_TITENG
	'Hora'											  						, ; //X3_DESCRIC
	'Hora'																	, ; //X3_DESCSPA
	'Hora'											 						, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''													 					, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) 	 							, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	'N'																		} ) //X3_PYME		

aAdd( aSX3, { ;
	'ZZK'																	, ; //X3_ARQUIVO
	'21'																	, ; //X3_ORDEM
	'ZZK_EXPLIC'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	250																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Explicacao'											   				, ; //X3_TITULO
	'Explicacao'															, ; //X3_TITSPA
	'Explicacao'															, ; //X3_TITENG
	'Explicacao'									  						, ; //X3_DESCRIC
	'Explicacao'															, ; //X3_DESCSPA
	'Explicacao'									 						, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''													 					, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) 	 							, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	'N'																		} ) //X3_PYME		

aAdd( aSX3, { ;
	'ZZK'																	, ; //X3_ARQUIVO
	'22'																	, ; //X3_ORDEM
	'ZZK_USERAP'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	60																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Usuario Ap.'											   				, ; //X3_TITULO
	'Usuario Ap.'															, ; //X3_TITSPA
	'Usuario Ap.'															, ; //X3_TITENG
	'Usuario Ap.'									  						, ; //X3_DESCRIC
	'Usuario Ap.'															, ; //X3_DESCSPA
	'Usuario Ap.'									 						, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''													 					, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) 	 							, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	'N'																		} ) //X3_PYME		

aAdd( aSX3, { ;
	'ZZK'																	, ; //X3_ARQUIVO
	'23'																	, ; //X3_ORDEM
	'ZZK_APROVA'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	60																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Aprovador '											   				, ; //X3_TITULO
	'Aprovador '															, ; //X3_TITSPA
	'Aprovador '															, ; //X3_TITENG
	'Aprovador '									  						, ; //X3_DESCRIC
	'Aprovador '															, ; //X3_DESCSPA
	'Aprovador '									 						, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''													 					, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) 	 							, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	'N'																		} ) //X3_PYME		


//
// Tabela ZZL
//
aAdd( aSX3, { ;
	'ZZL'																	, ; //X3_ARQUIVO
	'01'																	, ; //X3_ORDEM
	'ZZL_FILIAL'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	2																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Filial'																, ; //X3_TITULO
	'Filial'																, ; //X3_TITSPA
	'Filial'																, ; //X3_TITENG
	'Filial'																, ; //X3_DESCRIC
	'Filial'																, ; //X3_DESCSPA
	'Filial'																, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	'N'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'ZZL'																	, ; //X3_ARQUIVO
	'02'																	, ; //X3_ORDEM
	'ZZL_CODIGO'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	6																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Cod.Departam'															, ; //X3_TITULO
	'Cod.Departam'															, ; //X3_TITSPA
	'Cod.Departam'															, ; //X3_TITENG
	'Cod.Departam'															, ; //X3_DESCRIC
	'Cod.Departam'															, ; //X3_DESCSPA
	'Cod.Mensagem'															, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(32)						, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	'N'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'ZZL'																	, ; //X3_ARQUIVO
	'03'																	, ; //X3_ORDEM
	'ZZL_DEPART'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	20																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Departamento'															, ; //X3_TITULO
	'Departamento'															, ; //X3_TITSPA
	'Departamento'															, ; //X3_TITENG
	'Departamento'															, ; //X3_DESCRIC
	'Departamento'															, ; //X3_DESCSPA
	'Departamento'															, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(32)						, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	'N'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'ZZL'																	, ; //X3_ARQUIVO
	'04'																	, ; //X3_ORDEM
	'ZZL_EMAIL' 															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	250																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Email' 																, ; //X3_TITULO
	'Email'																	, ; //X3_TITSPA
	'Email'																	, ; //X3_TITENG
	'Email'																	, ; //X3_DESCRIC
	'Email'																	, ; //X3_DESCSPA
	'Email'																	, ; //X3_DESCENG
	''																		, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(32)						, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	'N'																		} ) //X3_PYME


aAdd( aSX3, { ;
	'ZZL'																	, ; //X3_ARQUIVO
	'05'																	, ; //X3_ORDEM
	'ZZL_CIC'	 															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	250																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'CIC'	 																, ; //X3_TITULO
	'CIC'																	, ; //X3_TITSPA
	'CIC'																	, ; //X3_TITENG
	'CIC'																	, ; //X3_DESCRIC
	'CIC'																	, ; //X3_DESCSPA
	'CIC'																	, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(32)						, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	'N'																		} ) //X3_PYME


aAdd( aSX3, { ;
	'SB1'																	, ; //X3_ARQUIVO
	'01'																	, ; //X3_ORDEM
	'B1_XTPEMBC'		  													, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	1																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Tp Emb Conf. '															, ; //X3_TITULO
	'Tp Emb Conf. '															, ; //X3_TITSPA
	'Tp Emb Conf. '															, ; //X3_TITENG
	'Tipo de embalagem de conf'							   					, ; //X3_DESCRIC
	'Tipo de embalagem de conf'												, ; //X3_DESCSPA
	'Tipo de embalagem de conf'					   							, ; //X3_DESCENG
	''				    													, ; //X3_PICTURE
	''								                                        , ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128)								, ; //X3_USADO
	''							                							, ; //X3_RELACAO
	''      																, ; //X3_F3
	 1																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	''																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	''																		, ; //X3_VISUAL
	''																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	'1=Unitaria; 2=Secundaria; 3=Embarque '									, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	'U_xTRAVSB()'															, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
    '9'																		, ; //X3_FOLDER
	'S'																		} ) //X3_PYME   
	
	
//
// Tabela ZZN
//
aAdd( aSX3, { ;
	'ZZN'																	, ; //X3_ARQUIVO
	'01'																	, ; //X3_ORDEM
	'ZZN_FILIAL'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	2																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Filial'																, ; //X3_TITULO
	'Filial'																, ; //X3_TITSPA
	'Filial'																, ; //X3_TITENG
	'Filial'																, ; //X3_DESCRIC
	'Filial'																, ; //X3_DESCSPA
	'Filial'																, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	'N'																		} ) //X3_PYME     
	
aAdd( aSX3, { ;
	'ZZN'																	, ; //X3_ARQUIVO
	'02'																	, ; //X3_ORDEM
	'ZZN_CODIGO'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	6																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Codigo      '															, ; //X3_TITULO
	'Codigo      '															, ; //X3_TITSPA
	'Codigo      '															, ; //X3_TITENG
	'Codigo      '															, ; //X3_DESCRIC
	'Codigo      '															, ; //X3_DESCSPA
	'Codigo      '															, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(32)						, ; //X3_USADO
	'GETSXENUM("ZZN","ZZN_CODIGO")'											, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME	
	

aAdd( aSX3, { ;
	'ZZN'																	, ; //X3_ARQUIVO
	'03'																	, ; //X3_ORDEM
	'ZZN_NOME'  															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	20																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Nome        '															, ; //X3_TITULO
	'Nome        '															, ; //X3_TITSPA
	'Nome        '															, ; //X3_TITENG
	'Nome        '															, ; //X3_DESCRIC
	'Nome        '															, ; //X3_DESCSPA
	'Nome        '															, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(32)						, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME	
	

aAdd( aSX3, { ;
	'ZZN'																	, ; //X3_ARQUIVO
	'04'																	, ; //X3_ORDEM
	'ZZN_DEPART'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	20																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Departamento'															, ; //X3_TITULO
	'Departamento'															, ; //X3_TITSPA
	'Departamento'															, ; //X3_TITENG
	'Departamento'															, ; //X3_DESCRIC
	'Departamento'															, ; //X3_DESCSPA
	'Departamento'															, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(32)						, ; //X3_USADO
	''																		, ; //X3_RELACAO
	'ZSAC'																	, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME		    

//
// Tabela ZZM
//
aAdd( aSX3, { ;
	'ZZM'																	, ; //X3_ARQUIVO
	'01'																	, ; //X3_ORDEM
	'ZZM_FILIAL'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	2																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Filial'																, ; //X3_TITULO
	'Filial'																, ; //X3_TITSPA
	'Filial'																, ; //X3_TITENG
	'Filial'																, ; //X3_DESCRIC
	'Filial'																, ; //X3_DESCSPA
	'Filial'																, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	'033'																	, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	'N'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'ZZM'																	, ; //X3_ARQUIVO
	'02'																	, ; //X3_ORDEM
	'ZZM_ITEM'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	4																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Item'																	, ; //X3_TITULO
	'Item'																	, ; //X3_TITSPA
	'Item'																	, ; //X3_TITENG
	'Item'																	, ; //X3_DESCRIC
	'Item'																	, ; //X3_DESCSPA
	'Item'																	, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(32)						, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	'N'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'ZZM'																	, ; //X3_ARQUIVO
	'03'																	, ; //X3_ORDEM
	'ZZM_CODPRO'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	15																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Produto'																, ; //X3_TITULO
	'Produto'																, ; //X3_TITSPA
	'Produto'																, ; //X3_TITENG
	'Produto'																, ; //X3_DESCRIC
	'Produto'																, ; //X3_DESCSPA
	'Produto'																, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(32)						, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	'N'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'ZZM'																	, ; //X3_ARQUIVO
	'04'																	, ; //X3_ORDEM
	'ZZM_DESPRO'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	60																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Descricao'																, ; //X3_TITULO
	'Descricao'																, ; //X3_TITSPA
	'Descricao'																, ; //X3_TITENG
	'Descricao'																, ; //X3_DESCRIC
	'Descricao'																, ; //X3_DESCSPA
	'Descricao'																, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	'SB1->(POSICIONE("SB1",1,xFilial("SB1")+ZZM->ZZM_CODPRO,"B1_DESC"))'	, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'V'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	'SB1->(POSICIONE("SB1",1,xFilial("SB1")+ZZM->ZZM_CODPRO,"B1_DESC"))'	, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	'N'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'ZZM'																	, ; //X3_ARQUIVO
	'05'																	, ; //X3_ORDEM
	'ZZM_VALUNI'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	16																		, ; //X3_TAMANHO
	4																		, ; //X3_DECIMAL
	'Vlr. Unit.'															, ; //X3_TITULO
	'Vlr. Unit.'															, ; //X3_TITSPA
	'Vlr. Unit.'															, ; //X3_TITENG
	'Vlr. Unit.'															, ; //X3_DESCRIC
	'Vlr. Unit.'															, ; //X3_DESCSPA
	'Vlr. Unit.'															, ; //X3_DESCENG
	'@E 999,999,999.9999'													, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(32)						, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	'N'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'ZZM'																	, ; //X3_ARQUIVO
	'06'																	, ; //X3_ORDEM
	'ZZM_QUANT'																, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	11																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Quantidade'															, ; //X3_TITULO
	'Quantidade'															, ; //X3_TITSPA
	'Quantidade'															, ; //X3_TITENG
	'Quantidade'															, ; //X3_DESCRIC
	'Quantidade'															, ; //X3_DESCSPA
	'Quantidade'															, ; //X3_DESCENG
	'@E 999,999,999'														, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(32)						, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	'N'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'ZZM'																	, ; //X3_ARQUIVO
	'07'																	, ; //X3_ORDEM
	'ZZM_VALTOT'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	16																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Vlr. Tot'																, ; //X3_TITULO
	'Vlr. Tot'																, ; //X3_TITSPA
	'Vlr. Tot'																, ; //X3_TITENG
	'Vlr. Tot'																, ; //X3_DESCRIC
	'Vlr. Tot'																, ; //X3_DESCSPA
	'Vlr. Tot'																, ; //X3_DESCENG
	'@E 9,999,999,999.99'													, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(32)						, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	'N'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'ZZM'																	, ; //X3_ARQUIVO
	'08'																	, ; //X3_ORDEM
	'ZZM_VALCIF'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	16																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Vlr. M.L.E'															, ; //X3_TITULO
	'Vlr. M.L.E'															, ; //X3_TITSPA
	'Vlr. M.L.E'															, ; //X3_TITENG
	'Vlr. M.L.E'															, ; //X3_DESCRIC
	'Vlr. M.L.E'															, ; //X3_DESCSPA
	'Vlr. M.L.E'															, ; //X3_DESCENG
	'@E 9,999,999,999.99'													, ; //X3_PICTURE
	'NaoVazio()'															, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(32)						, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	'S'																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	'N'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'ZZM'																	, ; //X3_ARQUIVO
	'09'																	, ; //X3_ORDEM
	'ZZM_VALII'																, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	16																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Vlr II'																, ; //X3_TITULO
	'Vlr II'																, ; //X3_TITSPA
	'Vlr II'																, ; //X3_TITENG
	'Vlr II'																, ; //X3_DESCRIC
	'Vlr II'																, ; //X3_DESCSPA
	'Vlr II'																, ; //X3_DESCENG
	'@E 9,999,999,999.99'													, ; //X3_PICTURE
	'NaoVazio()'															, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(32)						, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	'S'																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	'N'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'ZZM'																	, ; //X3_ARQUIVO
	'10'																	, ; //X3_ORDEM
	'ZZM_PERCEN'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	3																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'% Percent.'															, ; //X3_TITULO
	'% Percent.'															, ; //X3_TITSPA
	'% Percent.'															, ; //X3_TITENG
	'% Percent.'															, ; //X3_DESCRIC
	'% Percent.'															, ; //X3_DESCSPA
	'% Percent.'															, ; //X3_DESCENG
	'999'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(32)						, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	'N'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'ZZM'																	, ; //X3_ARQUIVO
	'11'																	, ; //X3_ORDEM
	'ZZM_VALCUS'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	16																		, ; //X3_TAMANHO
	4																		, ; //X3_DECIMAL
	'Custo'																	, ; //X3_TITULO
	'Custo'																	, ; //X3_TITSPA
	'Custo'																	, ; //X3_TITENG
	'Custo'																	, ; //X3_DESCRIC
	'Custo'																	, ; //X3_DESCSPA
	'Custo'																	, ; //X3_DESCENG
	'@E 999,999,999.9999'													, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(32)						, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	'N'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'ZZM'																	, ; //X3_ARQUIVO
	'12'																	, ; //X3_ORDEM
	'ZZM_DOC'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	9																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Documento'																, ; //X3_TITULO
	'Documento'																, ; //X3_TITSPA
	'Documento'																, ; //X3_TITENG
	'Documento'																, ; //X3_DESCRIC
	'Documento'																, ; //X3_DESCSPA
	'Documento'																, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(32)						, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	'N'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'ZZM'																	, ; //X3_ARQUIVO
	'13'																	, ; //X3_ORDEM
	'ZZM_SERIE'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	3																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Serie'																	, ; //X3_TITULO
	'Serie'																	, ; //X3_TITSPA
	'Serie'																	, ; //X3_TITENG
	'Serie'																	, ; //X3_DESCRIC
	'Serie'																	, ; //X3_DESCSPA
	'Serie'																	, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(32)						, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	'N'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'ZZM'																	, ; //X3_ARQUIVO
	'14'																	, ; //X3_ORDEM
	'ZZM_FORNEC'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	6																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Fornecedor'															, ; //X3_TITULO
	'Fornecedor'															, ; //X3_TITSPA
	'Fornecedor'															, ; //X3_TITENG
	'Fornecedor'															, ; //X3_DESCRIC
	'Fornecedor'															, ; //X3_DESCSPA
	'Fornecedor'															, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(32)						, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	'N'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'ZZM'																	, ; //X3_ARQUIVO
	'15'																	, ; //X3_ORDEM
	'ZZM_LOJA'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	2																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Loja'																	, ; //X3_TITULO
	'Loja'																	, ; //X3_TITSPA
	'Loja'																	, ; //X3_TITENG
	'Loja'																	, ; //X3_DESCRIC
	'Loja'																	, ; //X3_DESCSPA
	'Loja'																	, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(32)						, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	'N'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'ZZM'																	, ; //X3_ARQUIVO
	'16'																	, ; //X3_ORDEM
	'ZZM_DATA'																, ; //X3_CAMPO
	'D'																		, ; //X3_TIPO
	8																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Data'																	, ; //X3_TITULO
	'Data'																	, ; //X3_TITSPA
	'Data'																	, ; //X3_TITENG
	'Data'																	, ; //X3_DESCRIC
	'Data'																	, ; //X3_DESCSPA
	'Data'																	, ; //X3_DESCENG
	'@D'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(32)						, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	'N'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'ZZM'																	, ; //X3_ARQUIVO
	'17'																	, ; //X3_ORDEM
	'ZZM_USUARI'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	50																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Usuario'																, ; //X3_TITULO
	'Usuario'																, ; //X3_TITSPA
	'Usuario'																, ; //X3_TITENG
	'Usuario'																, ; //X3_DESCRIC
	'Usuario'																, ; //X3_DESCSPA
	'Usuario'																, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(32)						, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	'N'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SC5'																	, ; //X3_ARQUIVO
	'17'																	, ; //X3_ORDEM
	'C5_XAVARES'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	1																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Aval.Res.'																, ; //X3_TITULO
	'Aval.Res.'																, ; //X3_TITSPA
	'Aval.Res.'																, ; //X3_TITENG
	'Avalia Reserva'														, ; //X3_DESCRIC
	'Avalia Reserva'														, ; //X3_DESCSPA
	'Avalia Reserva'														, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	'N'																		} ) //X3_PYME  
	
	
//⁄ƒƒƒƒƒƒƒƒƒƒø
//≥Tabela SZP≥
//¿ƒƒƒƒƒƒƒƒƒƒŸ
SX3->(DbSetOrder(1))
SX3->(MsSeek("SZP"+"ZZ",.T.))
SX3->(DbSkip(-1))

cOrdem := Soma1(SX3->X3_ORDEM)   

cOrdem := Soma1(cOrdem)   

aAdd( aSX3, { ;
	'SZP'																	, ; //X3_ARQUIVO
	cOrdem																	, ; //X3_ORDEM
	'ZP_LOCAL'		  														, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	2																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Almoxarifado'															, ; //X3_TITULO
	'Almoxarifado'															, ; //X3_TITSPA
	'Almoxarifado'															, ; //X3_TITENG
	'Almoxarifado da transfere'							   					, ; //X3_DESCRIC
	'Almoxarifado da transfere'												, ; //X3_DESCSPA
	'Almoxarifado da transfere'					   							, ; //X3_DESCENG
	'@!'				 													, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128)								, ; //X3_USADO
	'If("MATA410"$Funname(),"01",cLocalTran)'								, ; //X3_RELACAO
	''      																, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	'S'																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	"U_DipCpoWhen('ZP_LOCAL')"												, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME
                                                                                 
cOrdem := Soma1(cOrdem)   

aAdd( aSX3, { ;
	'SZP'																	, ; //X3_ARQUIVO
	cOrdem																	, ; //X3_ORDEM
	'ZP_LOCALIZ'	  														, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	15																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Localizacao '															, ; //X3_TITULO
	'Localizacao '															, ; //X3_TITSPA
	'Localizacao '															, ; //X3_TITENG
	'Localizacao da transferen'							   					, ; //X3_DESCRIC
	'Localizacao da transferen'												, ; //X3_DESCSPA
	'Localizacao da transferen'					   							, ; //X3_DESCENG
	'@!'				 													, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128)								, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''      																, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	'S'																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	'Vazio() .Or. U_DIPC53BF(M->ZP_PRODUTO,cLocalTran)'						, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	"U_DipCpoWhen('ZP_LOCALIZ')"											, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

cOrdem := Soma1(cOrdem)   

aAdd( aSX3, { ;
	'SZP'																	, ; //X3_ARQUIVO
	cOrdem																	, ; //X3_ORDEM
	'ZP_LOTECTL'	  														, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	10																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Lote'																	, ; //X3_TITULO
	'Lote'																	, ; //X3_TITSPA
	'Lote'																	, ; //X3_TITENG
	'Lote da transferencia    '							   					, ; //X3_DESCRIC
	'Lote da transferencia    '												, ; //X3_DESCSPA
	'Lote da transferencia    '					   							, ; //X3_DESCENG
	'@!'				 													, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128)								, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''      																, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	'S'																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	'Vazio() .Or. U_DIPC53B8(M->ZP_PRODUTO,cLocalTran)'						, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	"U_DipCpoWhen('ZP_LOTECTL')"  											, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME


SX3->(DbSetOrder(2))
If SX3->(dbSeek("ZP_PRODUTO"))

	aAdd( aSX3, { ;
		'SZP'																	, ; //X3_ARQUIVO
		SX3->X3_ORDEM															, ; //X3_ORDEM
		'ZP_PRODUTO'															, ; //X3_CAMPO
		SX3->X3_TIPO															, ; //X3_TIPO
		SX3->X3_TAMANHO															, ; //X3_TAMANHO
		SX3->X3_DECIMAL															, ; //X3_DECIMAL
		SX3->X3_TITULO															, ; //X3_TITULO
		SX3->X3_TITSPA															, ; //X3_TITSPA
		SX3->X3_TITENG															, ; //X3_TITENG
		SX3->X3_DESCRIC															, ; //X3_DESCRIC
		SX3->X3_DESCSPA															, ; //X3_DESCSPA
		SX3->X3_DESCENG															, ; //X3_DESCENG
		SX3->X3_PICTURE															, ; //X3_PICTURE
		SX3->X3_VALID															, ; //X3_VALID
		SX3->X3_USADO															, ; //X3_USADO
		SX3->X3_RELACAO 														, ; //X3_RELACAO
		SX3->X3_F3																, ; //X3_F3
		SX3->X3_NIVEL															, ; //X3_NIVEL
		SX3->X3_RESERV															, ; //X3_RESERV
		SX3->X3_CHECK															, ; //X3_CHECK
		SX3->X3_TRIGGER															, ; //X3_TRIGGER
		SX3->X3_PROPRI															, ; //X3_PROPRI
		SX3->X3_BROWSE															, ; //X3_BROWSE
		SX3->X3_VISUAL															, ; //X3_VISUAL
		SX3->X3_CONTEXT															, ; //X3_CONTEXT
		SX3->X3_OBRIGAT															, ; //X3_OBRIGAT
		'ExistCpo("SB1") .And. U_DIP53B2(If("MATA410"$Funname(),M->ZP_PRODUTO,M->ZP_PRODUTO))', ; //X3_VLDUSER
		SX3->X3_CBOX															, ; //X3_CBOX
		SX3->X3_CBOXSPA															, ; //X3_CBOXSPA
		SX3->X3_CBOXENG															, ; //X3_CBOXENG
		SX3->X3_PICTVAR															, ; //X3_PICTVAR
		SX3->X3_WHEN															, ; //X3_WHEN
		SX3->X3_INIBRW															, ; //X3_INIBRW
		SX3->X3_GRPSXG															, ; //X3_GRPSXG
		SX3->X3_FOLDER															, ; //X3_FOLDER
		SX3->X3_PYME															} ) //X3_PYME	
EndIf	


SX3->(DbSetOrder(2))
If SX3->(dbSeek("ZP_QUANT"))

	aAdd( aSX3, { ;
		'SZP'																	, ; //X3_ARQUIVO
		SX3->X3_ORDEM															, ; //X3_ORDEM
		'ZP_QUANT'															, ; //X3_CAMPO
		SX3->X3_TIPO															, ; //X3_TIPO
		SX3->X3_TAMANHO															, ; //X3_TAMANHO
		SX3->X3_DECIMAL															, ; //X3_DECIMAL
		SX3->X3_TITULO															, ; //X3_TITULO
		SX3->X3_TITSPA															, ; //X3_TITSPA
		SX3->X3_TITENG															, ; //X3_TITENG
		SX3->X3_DESCRIC															, ; //X3_DESCRIC
		SX3->X3_DESCSPA															, ; //X3_DESCSPA
		SX3->X3_DESCENG															, ; //X3_DESCENG
		SX3->X3_PICTURE															, ; //X3_PICTURE
		SX3->X3_VALID															, ; //X3_VALID
		SX3->X3_USADO															, ; //X3_USADO
		SX3->X3_RELACAO 														, ; //X3_RELACAO
		SX3->X3_F3																, ; //X3_F3
		SX3->X3_NIVEL															, ; //X3_NIVEL
		SX3->X3_RESERV															, ; //X3_RESERV
		SX3->X3_CHECK															, ; //X3_CHECK
		SX3->X3_TRIGGER															, ; //X3_TRIGGER
		SX3->X3_PROPRI															, ; //X3_PROPRI
		SX3->X3_BROWSE															, ; //X3_BROWSE
		SX3->X3_VISUAL															, ; //X3_VISUAL
		SX3->X3_CONTEXT															, ; //X3_CONTEXT
		SX3->X3_OBRIGAT															, ; //X3_OBRIGAT
		'Positivo() .And. (U_DIPC53B2(M->ZP_PRODUTO,.F.) )'						, ; //X3_VLDUSER
		SX3->X3_CBOX															, ; //X3_CBOX
		SX3->X3_CBOXSPA															, ; //X3_CBOXSPA
		SX3->X3_CBOXENG															, ; //X3_CBOXENG
		SX3->X3_PICTVAR															, ; //X3_PICTVAR
		SX3->X3_WHEN															, ; //X3_WHEN
		SX3->X3_INIBRW															, ; //X3_INIBRW
		SX3->X3_GRPSXG															, ; //X3_GRPSXG
		SX3->X3_FOLDER															, ; //X3_FOLDER
		SX3->X3_PYME															} ) //X3_PYME	
EndIf	


SX3->(DbSetOrder(2))
If SX3->(dbSeek("C5_EMISSAO"))		   
	aAdd( aSX3, { ;
		'SC5'																	, ; //X3_ARQUIVO
		SX3->X3_ORDEM															, ; //X3_ORDEM
		'C5_XDATRES'	   														, ; //X3_CAMPO
		SX3->X3_TIPO															, ; //X3_TIPO
		SX3->X3_TAMANHO															, ; //X3_TAMANHO
		SX3->X3_DECIMAL															, ; //X3_DECIMAL
		'Dt. Reserva'															, ; //X3_TITULO
		'Dt. Reserva'															, ; //X3_TITSPA
		'Dt. Reserva'															, ; //X3_TITENG
		'Data da Reserva'														, ; //X3_DESCRIC
		'Data da Reserva'														, ; //X3_DESCSPA
		'Data da Reserva'														, ; //X3_DESCENG
		'@D'           															, ; //X3_PICTURE
		''           															, ; //X3_VALID
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, ; //X3_USADO
		''              														, ; //X3_RELACAO
		SX3->X3_F3																, ; //X3_F3
		SX3->X3_NIVEL															, ; //X3_NIVEL
		SX3->X3_RESERV															, ; //X3_RESERV
		SX3->X3_CHECK															, ; //X3_CHECK
		SX3->X3_TRIGGER															, ; //X3_TRIGGER
		SX3->X3_PROPRI															, ; //X3_PROPRI
		SX3->X3_BROWSE															, ; //X3_BROWSE
		'V'																		, ; //X3_VISUAL
		SX3->X3_CONTEXT															, ; //X3_CONTEXT
		SX3->X3_OBRIGAT															, ; //X3_OBRIGAT
		SX3->X3_VLDUSER															, ; //X3_VLDUSER
		SX3->X3_CBOX															, ; //X3_CBOX
		SX3->X3_CBOXSPA															, ; //X3_CBOXSPA
		SX3->X3_CBOXENG															, ; //X3_CBOXENG
		SX3->X3_PICTVAR															, ; //X3_PICTVAR
		SX3->X3_WHEN															, ; //X3_WHEN
		SX3->X3_INIBRW															, ; //X3_INIBRW
		SX3->X3_GRPSXG															, ; //X3_GRPSXG
		SX3->X3_FOLDER  														, ; //X3_FOLDER
		SX3->X3_PYME															} ) //X3_PYME   
		
	aAdd( aSX3, { ;
		'SC5'																	, ; //X3_ARQUIVO
		SX3->X3_ORDEM															, ; //X3_ORDEM
		'C5_XDATEXP'	   														, ; //X3_CAMPO
		SX3->X3_TIPO															, ; //X3_TIPO
		SX3->X3_TAMANHO															, ; //X3_TAMANHO
		SX3->X3_DECIMAL															, ; //X3_DECIMAL
		'Dt. Expirar'															, ; //X3_TITULO
		'Dt. Expirar'															, ; //X3_TITSPA
		'Dt. Expirar'															, ; //X3_TITENG
		'Data da ExpiraÁ„o'														, ; //X3_DESCRIC
		'Data da ExpiraÁ„o'														, ; //X3_DESCSPA
		'Data da ExpiraÁ„o'														, ; //X3_DESCENG
		'@D'            														, ; //X3_PICTURE
		''           															, ; //X3_VALID
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, ; //X3_USADO
		''              														, ; //X3_RELACAO
		SX3->X3_F3																, ; //X3_F3
		SX3->X3_NIVEL															, ; //X3_NIVEL
		SX3->X3_RESERV															, ; //X3_RESERV
		SX3->X3_CHECK															, ; //X3_CHECK
		SX3->X3_TRIGGER															, ; //X3_TRIGGER
		SX3->X3_PROPRI															, ; //X3_PROPRI
		SX3->X3_BROWSE															, ; //X3_BROWSE
		'V'																		, ; //X3_VISUAL
		SX3->X3_CONTEXT															, ; //X3_CONTEXT
		SX3->X3_OBRIGAT															, ; //X3_OBRIGAT
		SX3->X3_VLDUSER															, ; //X3_VLDUSER
		SX3->X3_CBOX															, ; //X3_CBOX
		SX3->X3_CBOXSPA															, ; //X3_CBOXSPA
		SX3->X3_CBOXENG															, ; //X3_CBOXENG
		SX3->X3_PICTVAR															, ; //X3_PICTVAR
		SX3->X3_WHEN															, ; //X3_WHEN
		SX3->X3_INIBRW															, ; //X3_INIBRW
		SX3->X3_GRPSXG															, ; //X3_GRPSXG
		SX3->X3_FOLDER  														, ; //X3_FOLDER
		SX3->X3_PYME															} ) //X3_PYME   
		
EndIf       

SX3->(DbSetOrder(2))
If SX3->(dbSeek("C5_HORA"))		   
	aAdd( aSX3, { ;
		'SC5'																	, ; //X3_ARQUIVO
		SX3->X3_ORDEM															, ; //X3_ORDEM
		'C5_XHORRES'	   														, ; //X3_CAMPO
		SX3->X3_TIPO															, ; //X3_TIPO
		SX3->X3_TAMANHO															, ; //X3_TAMANHO
		SX3->X3_DECIMAL															, ; //X3_DECIMAL
		'Hr. Reserva'															, ; //X3_TITULO
		'Hr. Reserva'															, ; //X3_TITSPA
		'Hr. Reserva'															, ; //X3_TITENG
		'Hora da Reserva'														, ; //X3_DESCRIC
		'Hora da Reserva'														, ; //X3_DESCSPA
		'Hora da Reserva'														, ; //X3_DESCENG
		SX3->X3_PICTURE															, ; //X3_PICTURE
		''           															, ; //X3_VALID
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, ; //X3_USADO
		''              														, ; //X3_RELACAO
		SX3->X3_F3																, ; //X3_F3
		SX3->X3_NIVEL															, ; //X3_NIVEL
		SX3->X3_RESERV															, ; //X3_RESERV
		SX3->X3_CHECK															, ; //X3_CHECK
		SX3->X3_TRIGGER															, ; //X3_TRIGGER
		SX3->X3_PROPRI															, ; //X3_PROPRI
		SX3->X3_BROWSE															, ; //X3_BROWSE
		'V'																		, ; //X3_VISUAL
		SX3->X3_CONTEXT															, ; //X3_CONTEXT
		SX3->X3_OBRIGAT															, ; //X3_OBRIGAT
		SX3->X3_VLDUSER															, ; //X3_VLDUSER
		SX3->X3_CBOX															, ; //X3_CBOX
		SX3->X3_CBOXSPA															, ; //X3_CBOXSPA
		SX3->X3_CBOXENG															, ; //X3_CBOXENG
		SX3->X3_PICTVAR															, ; //X3_PICTVAR
		SX3->X3_WHEN															, ; //X3_WHEN
		SX3->X3_INIBRW															, ; //X3_INIBRW
		SX3->X3_GRPSXG															, ; //X3_GRPSXG
		SX3->X3_FOLDER  														, ; //X3_FOLDER
		SX3->X3_PYME															} ) //X3_PYME   
		
	aAdd( aSX3, { ;
		'SC5'																	, ; //X3_ARQUIVO
		SX3->X3_ORDEM															, ; //X3_ORDEM
		'C5_XHOREXP'	   														, ; //X3_CAMPO
		SX3->X3_TIPO															, ; //X3_TIPO
		SX3->X3_TAMANHO															, ; //X3_TAMANHO
		SX3->X3_DECIMAL															, ; //X3_DECIMAL
		'Hr. Expirar'															, ; //X3_TITULO
		'Hr. Expirar'															, ; //X3_TITSPA
		'Hr. Expirar'															, ; //X3_TITENG
		'Hora da ExpiraÁ„o'														, ; //X3_DESCRIC
		'Hora da ExpiraÁ„o'														, ; //X3_DESCSPA
		'Hora da ExpiraÁ„o'														, ; //X3_DESCENG
		SX3->X3_PICTURE															, ; //X3_PICTURE
		''           															, ; //X3_VALID
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, ; //X3_USADO
		''				 														, ; //X3_RELACAO
		SX3->X3_F3																, ; //X3_F3
		SX3->X3_NIVEL															, ; //X3_NIVEL
		SX3->X3_RESERV															, ; //X3_RESERV
		SX3->X3_CHECK															, ; //X3_CHECK
		SX3->X3_TRIGGER															, ; //X3_TRIGGER
		SX3->X3_PROPRI															, ; //X3_PROPRI
		SX3->X3_BROWSE															, ; //X3_BROWSE
		'V'																		, ; //X3_VISUAL
		SX3->X3_CONTEXT															, ; //X3_CONTEXT
		SX3->X3_OBRIGAT															, ; //X3_OBRIGAT
		SX3->X3_VLDUSER															, ; //X3_VLDUSER
		SX3->X3_CBOX															, ; //X3_CBOX
		SX3->X3_CBOXSPA															, ; //X3_CBOXSPA
		SX3->X3_CBOXENG															, ; //X3_CBOXENG
		SX3->X3_PICTVAR															, ; //X3_PICTVAR
		SX3->X3_WHEN															, ; //X3_WHEN
		SX3->X3_INIBRW															, ; //X3_INIBRW
		SX3->X3_GRPSXG															, ; //X3_GRPSXG
		SX3->X3_FOLDER  														, ; //X3_FOLDER
		SX3->X3_PYME															} ) //X3_PYME   
EndIf

aAdd( aSX3, { ;
		'SC5'																	, ; //X3_ARQUIVO
		'G3'																	, ; //X3_ORDEM
		'C5_XOBSRES'	   														, ; //X3_CAMPO
		'M'																		, ; //X3_TIPO
		80																		, ; //X3_TAMANHO
		0																		, ; //X3_DECIMAL
		'Obs.Reserva'															, ; //X3_TITULO
		'Obs.Reserva'															, ; //X3_TITSPA
		'Obs.Reserva'															, ; //X3_TITENG
		'Observacao da Reserva'													, ; //X3_DESCRIC
		'Observacao da Reserva'													, ; //X3_DESCSPA
		'Observacao da Reserva'													, ; //X3_DESCENG
		'@!'																	, ; //X3_PICTURE
		''           															, ; //X3_VALID
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, ; //X3_USADO
		''              														, ; //X3_RELACAO
		''																		, ; //X3_F3
		0																		, ; //X3_NIVEL
		Chr(254) + Chr(65)														, ; //X3_RESERV
		'' 																		, ; //X3_CHECK
		''																		, ; //X3_TRIGGER
		'U'																		, ; //X3_PROPRI
		'N'																		, ; //X3_BROWSE
		'V'																		, ; //X3_VISUAL
		'R'																		, ; //X3_CONTEXT
		''																		, ; //X3_OBRIGAT
		''																		, ; //X3_VLDUSER
		''																		, ; //X3_CBOX
		''																		, ; //X3_CBOXSPA
		''																		, ; //X3_CBOXENG
		''																		, ; //X3_PICTVAR
		''																		, ; //X3_WHEN
		''																		, ; //X3_INIBRW
		''																		, ; //X3_GRPSXG
		'' 																		, ; //X3_FOLDER
		'N'																		} ) //X3_PYME   


aAdd( aSX3, { ;
		'SC5'																	, ; //X3_ARQUIVO
		'01'																	, ; //X3_ORDEM
		'C5_XOBSDIR'	   														, ; //X3_CAMPO
		'M'																		, ; //X3_TIPO
		80																		, ; //X3_TAMANHO
		0																		, ; //X3_DECIMAL
		'Obs.Diretor'															, ; //X3_TITULO
		'Obs.Diretor'															, ; //X3_TITSPA
		'Obs.Diretor'															, ; //X3_TITENG
		'Observacao Diretoria'													, ; //X3_DESCRIC
		'Observacao Diretoria'													, ; //X3_DESCSPA
		'Observacao Diretoria'													, ; //X3_DESCENG
		'@!'																	, ; //X3_PICTURE
		''           															, ; //X3_VALID
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, ; //X3_USADO
		''              														, ; //X3_RELACAO
		''																		, ; //X3_F3
		0																		, ; //X3_NIVEL
		Chr(254) + Chr(65)														, ; //X3_RESERV
		'' 																		, ; //X3_CHECK
		''																		, ; //X3_TRIGGER
		'U'																		, ; //X3_PROPRI
		'N'																		, ; //X3_BROWSE
		'V'																		, ; //X3_VISUAL
		'R'																		, ; //X3_CONTEXT
		''																		, ; //X3_OBRIGAT
		''																		, ; //X3_VLDUSER
		''																		, ; //X3_CBOX
		''																		, ; //X3_CBOXSPA
		''																		, ; //X3_CBOXENG
		''																		, ; //X3_PICTVAR
		''																		, ; //X3_WHEN
		''																		, ; //X3_INIBRW
		''																		, ; //X3_GRPSXG
		'' 																		, ; //X3_FOLDER
		'N'																		} ) //X3_PYME   

SX3->(DbSetOrder(2))
If SX3->(dbSeek("E1_PEDIDO"))		   
	aAdd( aSX3, { ;
		'SE1'																	, ; //X3_ARQUIVO
		SX3->X3_ORDEM															, ; //X3_ORDEM
		'E1_PEDIDO'	   															, ; //X3_CAMPO
		SX3->X3_TIPO															, ; //X3_TIPO
		SX3->X3_TAMANHO															, ; //X3_TAMANHO
		SX3->X3_DECIMAL															, ; //X3_DECIMAL
		SX3->X3_TITULO															, ; //X3_TITULO
		SX3->X3_TITSPA															, ; //X3_TITSPA
		SX3->X3_TITENG															, ; //X3_TITENG
		SX3->X3_DESCRIC  														, ; //X3_DESCRIC
		SX3->X3_DESCSPA 									 					, ; //X3_DESCSPA
		SX3->X3_DESCENG 														, ; //X3_DESCENG
		SX3->X3_PICTURE															, ; //X3_PICTURE
		SX3->X3_VALID     														, ; //X3_VALID
		SX3->X3_USADO															, ; //X3_USADO
		SX3->X3_RELACAO 														, ; //X3_RELACAO
		SX3->X3_F3																, ; //X3_F3
		SX3->X3_NIVEL															, ; //X3_NIVEL
		SX3->X3_RESERV															, ; //X3_RESERV
		SX3->X3_CHECK															, ; //X3_CHECK
		SX3->X3_TRIGGER															, ; //X3_TRIGGER
		SX3->X3_PROPRI															, ; //X3_PROPRI
		'S'																		, ; //X3_BROWSE
		SX3->X3_VISUAL															, ; //X3_VISUAL
		SX3->X3_CONTEXT															, ; //X3_CONTEXT
		SX3->X3_OBRIGAT															, ; //X3_OBRIGAT
		SX3->X3_VLDUSER															, ; //X3_VLDUSER
		SX3->X3_CBOX															, ; //X3_CBOX
		SX3->X3_CBOXSPA															, ; //X3_CBOXSPA
		SX3->X3_CBOXENG															, ; //X3_CBOXENG
		SX3->X3_PICTVAR															, ; //X3_PICTVAR
		SX3->X3_WHEN															, ; //X3_WHEN
		SX3->X3_INIBRW															, ; //X3_INIBRW
		SX3->X3_GRPSXG															, ; //X3_GRPSXG
		SX3->X3_FOLDER  														, ; //X3_FOLDER
		SX3->X3_PYME															} ) //X3_PYME   
EndIf
     
    
SX3->(DbSetOrder(2))
If SX3->(dbSeek("E1_PARCELA"))		   
	aAdd( aSX3, { ;
		'SE1'																	, ; //X3_ARQUIVO
		SX3->X3_ORDEM															, ; //X3_ORDEM
		'E1_PARCELA'   															, ; //X3_CAMPO
		SX3->X3_TIPO															, ; //X3_TIPO
		SX3->X3_TAMANHO															, ; //X3_TAMANHO
		SX3->X3_DECIMAL															, ; //X3_DECIMAL
		SX3->X3_TITULO															, ; //X3_TITULO
		SX3->X3_TITSPA															, ; //X3_TITSPA
		SX3->X3_TITENG															, ; //X3_TITENG
		SX3->X3_DESCRIC  														, ; //X3_DESCRIC
		SX3->X3_DESCSPA 									 					, ; //X3_DESCSPA
		SX3->X3_DESCENG 														, ; //X3_DESCENG
		SX3->X3_PICTURE															, ; //X3_PICTURE
		SX3->X3_VALID     														, ; //X3_VALID
		SX3->X3_USADO															, ; //X3_USADO
		SX3->X3_RELACAO 														, ; //X3_RELACAO
		SX3->X3_F3																, ; //X3_F3
		SX3->X3_NIVEL															, ; //X3_NIVEL
		SX3->X3_RESERV															, ; //X3_RESERV
		SX3->X3_CHECK															, ; //X3_CHECK
		SX3->X3_TRIGGER															, ; //X3_TRIGGER
		SX3->X3_PROPRI															, ; //X3_PROPRI
		sx3->X3_BROWSE															, ; //X3_BROWSE
		SX3->X3_VISUAL															, ; //X3_VISUAL
		SX3->X3_CONTEXT															, ; //X3_CONTEXT
		SX3->X3_OBRIGAT															, ; //X3_OBRIGAT
		SX3->X3_VLDUSER															, ; //X3_VLDUSER
		SX3->X3_CBOX															, ; //X3_CBOX
		SX3->X3_CBOXSPA															, ; //X3_CBOXSPA
		SX3->X3_CBOXENG															, ; //X3_CBOXENG
		SX3->X3_PICTVAR															, ; //X3_PICTVAR
		SX3->X3_WHEN															, ; //X3_WHEN
		SX3->X3_INIBRW															, ; //X3_INIBRW
		SX3->X3_GRPSXG															, ; //X3_GRPSXG
		'1'				  														, ; //X3_FOLDER
		SX3->X3_PYME															} ) //X3_PYME   
EndIf     
     
     
//
//TABELA ACB
//

SX3->(DbSetOrder(2))
If SX3->(dbSeek("ACB_CODOBJ"))		   
	aAdd( aSX3, { ;
		'ACB'																	, ; //X3_ARQUIVO
		SX3->X3_ORDEM															, ; //X3_ORDEM
		'ACB_CODOBJ'   															, ; //X3_CAMPO
		SX3->X3_TIPO															, ; //X3_TIPO
		SX3->X3_TAMANHO															, ; //X3_TAMANHO
		SX3->X3_DECIMAL															, ; //X3_DECIMAL
		SX3->X3_TITULO															, ; //X3_TITULO
		SX3->X3_TITSPA															, ; //X3_TITSPA
		SX3->X3_TITENG															, ; //X3_TITENG
		SX3->X3_DESCRIC  														, ; //X3_DESCRIC
		SX3->X3_DESCSPA 									 					, ; //X3_DESCSPA
		SX3->X3_DESCENG 														, ; //X3_DESCENG
		SX3->X3_PICTURE															, ; //X3_PICTURE
		''			     														, ; //X3_VALID
		SX3->X3_USADO															, ; //X3_USADO
		SX3->X3_RELACAO	 														, ; //X3_RELACAO
		'XSUC'																	, ; //X3_F3
		SX3->X3_NIVEL															, ; //X3_NIVEL
		SX3->X3_RESERV															, ; //X3_RESERV
		SX3->X3_CHECK															, ; //X3_CHECK
		SX3->X3_TRIGGER															, ; //X3_TRIGGER
		SX3->X3_PROPRI															, ; //X3_PROPRI
		SX3->X3_BROWSE															, ; //X3_BROWSE
		'A'																		, ; //X3_VISUAL
		'R'																		, ; //X3_CONTEXT
		SX3->X3_OBRIGAT															, ; //X3_OBRIGAT
		SX3->X3_VLDUSER															, ; //X3_VLDUSER
		SX3->X3_CBOX															, ; //X3_CBOX
		SX3->X3_CBOXSPA															, ; //X3_CBOXSPA
		SX3->X3_CBOXENG															, ; //X3_CBOXENG
		SX3->X3_PICTVAR															, ; //X3_PICTVAR
		SX3->X3_WHEN															, ; //X3_WHEN
		SX3->X3_INIBRW															, ; //X3_INIBRW
		SX3->X3_GRPSXG															, ; //X3_GRPSXG
		SX3->X3_FOLDER  														, ; //X3_FOLDER
		SX3->X3_PYME															} ) //X3_PYME   
EndIf

SX3->(DbSetOrder(2))
If SX3->(dbSeek("C6_VALOR"))		   
	aAdd( aSX3, { ;
		"SC6"																	, ; //X3_ARQUIVO
		SX3->X3_ORDEM															, ; //X3_ORDEM
		"C6_XVLRINF"   															, ; //X3_CAMPO
		SX3->X3_TIPO															, ; //X3_TIPO
		12																		, ; //X3_TAMANHO
		4																		, ; //X3_DECIMAL
		"Sugest„o $"															, ; //X3_TITULO
		"Sugest„o $"															, ; //X3_TITSPA
		"Sugest„o $"															, ; //X3_TITENG
		"Sugest„o $"  															, ; //X3_DESCRIC
		"Sugest„o $" 										 					, ; //X3_DESCSPA
		"Sugest„o $" 															, ; //X3_DESCENG
		"@E 999,999.9999"														, ; //X3_PICTURE
		""			     														, ; //X3_VALID
		"ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ"														, ; //X3_USADO
		""				 														, ; //X3_RELACAO
		""																		, ; //X3_F3
		SX3->X3_NIVEL															, ; //X3_NIVEL
		SX3->X3_RESERV															, ; //X3_RESERV
		SX3->X3_CHECK															, ; //X3_CHECK
		SX3->X3_TRIGGER															, ; //X3_TRIGGER
		SX3->X3_PROPRI															, ; //X3_PROPRI
		SX3->X3_BROWSE															, ; //X3_BROWSE
		"A"																		, ; //X3_VISUAL
		"R"																		, ; //X3_CONTEXT
		""																		, ; //X3_OBRIGAT
		""																		, ; //X3_VLDUSER
		SX3->X3_CBOX															, ; //X3_CBOX
		SX3->X3_CBOXSPA															, ; //X3_CBOXSPA
		SX3->X3_CBOXENG															, ; //X3_CBOXENG
		SX3->X3_PICTVAR															, ; //X3_PICTVAR
		""																		, ; //X3_WHEN
		SX3->X3_INIBRW															, ; //X3_INIBRW
		SX3->X3_GRPSXG															, ; //X3_GRPSXG
		SX3->X3_FOLDER  														, ; //X3_FOLDER
		SX3->X3_PYME															} ) //X3_PYME   
EndIf

SX3->(DbSetOrder(2))
If SX3->(dbSeek("C6_QTDVEN"))		   
	aAdd( aSX3, { ;
		"SC6"																	, ; //X3_ARQUIVO
		SX3->X3_ORDEM															, ; //X3_ORDEM
		"C6_XQTDINF"   															, ; //X3_CAMPO
		SX3->X3_TIPO															, ; //X3_TIPO
		10																		, ; //X3_TAMANHO
		2																		, ; //X3_DECIMAL
		"Qtd. Sug. "															, ; //X3_TITULO
		"Qtd. Sug. "															, ; //X3_TITSPA
		"Qtd. Sug. "															, ; //X3_TITENG
		"Quantidade da Sugestao" 												, ; //X3_DESCRIC
		"Quantidade da Sugestao" 							 					, ; //X3_DESCSPA
		"Quantidade da Sugestao" 												, ; //X3_DESCENG
		"@E 999,999.99"															, ; //X3_PICTURE
		""			     														, ; //X3_VALID
		"ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ"														, ; //X3_USADO
		""				 														, ; //X3_RELACAO
		""																		, ; //X3_F3
		SX3->X3_NIVEL															, ; //X3_NIVEL
		SX3->X3_RESERV															, ; //X3_RESERV
		SX3->X3_CHECK															, ; //X3_CHECK
		SX3->X3_TRIGGER															, ; //X3_TRIGGER
		SX3->X3_PROPRI															, ; //X3_PROPRI
		"N"																		, ; //X3_BROWSE
		"V"																		, ; //X3_VISUAL
		"R"																		, ; //X3_CONTEXT
		""																		, ; //X3_OBRIGAT
		""																		, ; //X3_VLDUSER
		SX3->X3_CBOX															, ; //X3_CBOX
		SX3->X3_CBOXSPA															, ; //X3_CBOXSPA
		SX3->X3_CBOXENG															, ; //X3_CBOXENG
		SX3->X3_PICTVAR															, ; //X3_PICTVAR
		""																		, ; //X3_WHEN
		SX3->X3_INIBRW															, ; //X3_INIBRW
		SX3->X3_GRPSXG															, ; //X3_GRPSXG
		SX3->X3_FOLDER  														, ; //X3_FOLDER
		SX3->X3_PYME															} ) //X3_PYME   
EndIf     

aAdd( aSX3, { ;
	'SC5'																	, ; //X3_ARQUIVO
	'01'																	, ; //X3_ORDEM
	'C5_XCPGINF'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	3																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Pgto Inf.'																, ; //X3_TITULO
	'Pgto Inf.'																, ; //X3_TITSPA
	'Pgto Inf.'																, ; //X3_TITENG
	'Pagamento Informado'													, ; //X3_DESCRIC
	'Pagamento Informado'													, ; //X3_DESCSPA
	'Pagamento Informado'													, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	'N'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'ZZG'																	, ; //X3_ARQUIVO
	'07'																	, ; //X3_ORDEM
	'ZZG_CUSTO'																, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	12																		, ; //X3_TAMANHO
	4																		, ; //X3_DECIMAL
	'Custo'																	, ; //X3_TITULO
	'Custo'																	, ; //X3_TITSPA
	'Custo'																	, ; //X3_TITENG
	'Custo'																	, ; //X3_DESCRIC
	'Custo'																	, ; //X3_DESCSPA
	'Custo'																	, ; //X3_DESCENG
	'@E 99,999,999.9999'													, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(32)						, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	'S'																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	'N'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'ZZG'																	, ; //X3_ARQUIVO
	'08'																	, ; //X3_ORDEM
	'ZZG_PRVSUP'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	12																		, ; //X3_TAMANHO
	4																		, ; //X3_DECIMAL
	'Promocao'																, ; //X3_TITULO
	'Promocao'																, ; //X3_TITSPA
	'Promocao'																, ; //X3_TITENG
	'Promocao'																, ; //X3_DESCRIC
	'Promocao'																, ; //X3_DESCSPA
	'Promocao'																, ; //X3_DESCENG
	'@E 99,999,999.9999'													, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(32)						, ; //X3_USADO
	'If(Inclui,"",SB1->(Posicione("SB1",1,xFilial("SB1")+ZZG->(ZZG_PRODUT),"B1_PRVSUPE")))', ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'V'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	'SB1->(Posicione("SB1",1,xFilial("SB1")+ZZG->(ZZG_PRODUT),"B1_PRVSUPE"))'	, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	'N'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'ZZG'																	, ; //X3_ARQUIVO
	'09'																	, ; //X3_ORDEM
	'ZZG_PRVMIN'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	12																		, ; //X3_TAMANHO
	4																		, ; //X3_DECIMAL
	'C'																		, ; //X3_TITULO
	'C'																		, ; //X3_TITSPA
	'C'																		, ; //X3_TITENG
	'C'																		, ; //X3_DESCRIC
	'C'																		, ; //X3_DESCSPA
	'C'																		, ; //X3_DESCENG
	'@E 99,999,999.9999'													, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(32)						, ; //X3_USADO
	'If(Inclui,"",SB1->(Posicione("SB1",1,xFilial("SB1")+ZZG->(ZZG_PRODUT),"B1_PRVMINI")))', ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'V'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	'SB1->(Posicione("SB1",1,xFilial("SB1")+ZZG->(ZZG_PRODUT),"B1_PRVMINI"))'	, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	'N'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'ZZG'																	, ; //X3_ARQUIVO
	'10'																	, ; //X3_ORDEM
	'ZZG_MARGEM'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	8																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Margem %'																, ; //X3_TITULO
	'Margem %'																, ; //X3_TITSPA
	'Margem %'																, ; //X3_TITENG
	'Margem %'																, ; //X3_DESCRIC
	'Margem %'																, ; //X3_DESCSPA
	'Margem %'																, ; //X3_DESCENG
	'@E 99999.99 %'																, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(32)						, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	'N'																		} ) //X3_PYME 
	

//⁄ƒƒƒƒƒƒƒƒƒƒø
//≥Tabela SD1≥
//¿ƒƒƒƒƒƒƒƒƒƒŸ
SX3->(DbSetOrder(1))
SX3->(MsSeek("SD1"+"ZZ",.T.))
SX3->(DbSkip(-1))

cOrdem := Soma1(SX3->X3_ORDEM)   

cOrdem := Soma1(cOrdem)   

aAdd( aSX3, { ;
	'SD1'																	, ; //X3_ARQUIVO
	cOrdem																	, ; //X3_ORDEM
	'D1_XPOSIPI' 	  														, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	10																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Pos.IPI/NCM '															, ; //X3_TITULO
	'Pos.IPI/NCM '															, ; //X3_TITSPA
	'Pos.IPI/NCM '															, ; //X3_TITENG
	'Nomenclatura Ext.Mercosul'							   					, ; //X3_DESCRIC
	'Nomenclatura Ext.Mercosul'												, ; //X3_DESCSPA
	'Nomenclatura Ext.Mercosul'					   							, ; //X3_DESCENG
	'@R 9999.99.99'		 													, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128)								, ; //X3_USADO
	'IF(INCLUI,"",POSICIONE("SB1",1,xFilial("SB1")+SD1->D1_COD,"B1_POSIPI"))', ; //X3_RELACAO
	''      																, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	'S'																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	""																		, ; //X3_WHEN
	'IF(INCLUI,"",POSICIONE("SB1",1,xFilial("SB1")+SD1->D1_COD,"B1_POSIPI"))', ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME
                                                                                 
cOrdem := Soma1(cOrdem)   

aAdd( aSX3, { ;
	'SD1'																	, ; //X3_ARQUIVO
	cOrdem																	, ; //X3_ORDEM
	'D1_XORIGEM'	  														, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	1																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Origem '																, ; //X3_TITULO
	'Origem '																, ; //X3_TITSPA
	'Origem '																, ; //X3_TITENG
	'Origem do produto '								   					, ; //X3_DESCRIC
	'Origem do produto '													, ; //X3_DESCSPA
	'Origem do produto '						   							, ; //X3_DESCENG
	'@!'				 													, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128)								, ; //X3_USADO
	'IF(INCLUI,"",POSICIONE("SB1",1,XFILIAL("SB1")+SD1->D1_COD,"B1_ORIGEM"))', ; //X3_RELACAO
	''      																, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	'S'																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	'IF(INCLUI,"",POSICIONE("SB1",1,xFilial("SB1")+SD1->D1_COD,"B1_ORIGEM"))', ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME


//
// Tabela SG1
//
SX3->(DbSetOrder(1))
SX3->(MsSeek("SG1"+"ZZ",.T.))
SX3->(DbSkip(-1))

cOrdem := Soma1(SX3->X3_ORDEM) 
aAdd( aSX3, { ;
	'SG1'																	, ; //X3_ARQUIVO
	cOrdem																	, ; //X3_ORDEM
	'G1_X1UM'	 															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	2																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'1™ Unidade  '															, ; //X3_TITULO
	'1™ Unidade  '															, ; //X3_TITSPA
	'1™ Unidade  '															, ; //X3_TITENG
	'Primeira Unidade de Medid'												, ; //X3_DESCRIC
	'Primeira Unidade de Medid'												, ; //X3_DESCSPA
	'Primeira Unidade de Medid'												, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ' 	 													, ; //X3_USADO
	''																		, ; //X3_RELACAO
	'SAH'																	, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	'ExistCpo("SAH")'														, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

cOrdem := Soma1(cOrdem)                                                                    
aAdd( aSX3, { ;
	'SG1'																	, ; //X3_ARQUIVO
	cOrdem																	, ; //X3_ORDEM
	'G1_XQTD2'	 															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	12																		, ; //X3_TAMANHO
	6																		, ; //X3_DECIMAL
	'Qtde. Base  '															, ; //X3_TITULO
	'Qtde. Base  '															, ; //X3_TITSPA
	'Qtde. Base  '															, ; //X3_TITENG
	'Quanidade base do produto'												, ; //X3_DESCRIC
	'Quanidade base do produto'												, ; //X3_DESCSPA
	'Quanidade base do produto'												, ; //X3_DESCENG
	'@E 99,999.999999'														, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) 	 							, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	'S'																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME
                      
cOrdem := Soma1(cOrdem)                                                                    
aAdd( aSX3, { ;
	'SG1'																	, ; //X3_ARQUIVO
	cOrdem																	, ; //X3_ORDEM
	'G1_XQTD1'	 															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	12																		, ; //X3_TAMANHO
	6																		, ; //X3_DECIMAL
	'Qtde 1™ Unid'															, ; //X3_TITULO
	'Qtde 1™ Unid'															, ; //X3_TITSPA
	'Qtde 1™ Unid'															, ; //X3_TITENG
	'Quantidade Primeira Unid'												, ; //X3_DESCRIC
	'Quanttdade Primeira Unid'												, ; //X3_DESCSPA
	'Quantidade Primeira Unid'												, ; //X3_DESCENG
	'@E 99,999.999999'														, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ' 	 													, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	'S'																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME
                     
 
cOrdem := Soma1(cOrdem) 
aAdd( aSX3, { ;
	'SG1'																	, ; //X3_ARQUIVO
	cOrdem																	, ; //X3_ORDEM
	'G1_XQTDCX' 															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	9																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Qtde Por CX '															, ; //X3_TITULO
	'Qtde Por CX '															, ; //X3_TITSPA
	'Qtde Por CX '															, ; //X3_TITENG
	'Qtde. por caixa produzida'												, ; //X3_DESCRIC
	'Qtde. por caixa produzida'												, ; //X3_DESCSPA
	'Qtde. por caixa produzida'												, ; //X3_DESCENG
	'@E 999,999,999'														, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) 	 							, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	'S'																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME  
	                                                                                     
	                                                                                         
cOrdem := Soma1(cOrdem)                                                                    
aAdd( aSX3, { ;
	'SG1'																	, ; //X3_ARQUIVO
	cOrdem																	, ; //X3_ORDEM
	'G1_X2UM'	 															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	2																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'2™ Unidade  '															, ; //X3_TITULO
	'2™ Unidade  '															, ; //X3_TITSPA
	'2™ Unidade  '															, ; //X3_TITENG
	'Segunda Unidade de Medida'												, ; //X3_DESCRIC
	'Segunda Unidade de Medida'												, ; //X3_DESCSPA
	'Segunda Unidade de Medida'												, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ' 	 													, ; //X3_USADO
	''																		, ; //X3_RELACAO
	'SAH'																	, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	'S'																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	'ExistCpo("SAH")'														, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME


//
// Tabela ZZP
//
aAdd( aSX3, { ;
	'ZZP'																	, ; //X3_ARQUIVO
	'01'																	, ; //X3_ORDEM
	'ZZP_FILIAL'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	2																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Filial'																, ; //X3_TITULO
	'Filial'																, ; //X3_TITSPA
	'Filial'																, ; //X3_TITENG
	'Filial'																, ; //X3_DESCRIC
	'Filial'																, ; //X3_DESCSPA
	'Filial'																, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	'033'																	, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	'N'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'ZZP'																	, ; //X3_ARQUIVO
	'02'																	, ; //X3_ORDEM
	'ZZP_STATUS'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	1																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Status'																, ; //X3_TITULO
	'Status'																, ; //X3_TITSPA
	'Status'																, ; //X3_TITENG
	'Status'																, ; //X3_DESCRIC
	'Status'																, ; //X3_DESCSPA
	'Status'																, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	'.F.'																	, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	'N'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'ZZP'																	, ; //X3_ARQUIVO
	'03'																	, ; //X3_ORDEM
	'ZZP_DATA'																, ; //X3_CAMPO
	'D'																		, ; //X3_TIPO
	8																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Data Inv'																, ; //X3_TITULO
	'Data Inv'																, ; //X3_TITSPA
	'Data Inv'																, ; //X3_TITENG
	'Data Inv'																, ; //X3_DESCRIC
	'Data Inv'																, ; //X3_DESCSPA
	'Data Inv'																, ; //X3_DESCENG
	'@D'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, ; //X3_USADO
	'If(Inclui,dDataBase,ZZP->ZZP_DATA)'									, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	'N'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'ZZP'																	, ; //X3_ARQUIVO
	'04'																	, ; //X3_ORDEM
	'ZZP_LOCAL'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	2																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Armazem'																, ; //X3_TITULO
	'Armazem'																, ; //X3_TITSPA
	'Armazem'																, ; //X3_TITENG
	'Armazem'																, ; //X3_DESCRIC
	'Armazem'																, ; //X3_DESCSPA
	'Armazem'																, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	'N'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'ZZP'																	, ; //X3_ARQUIVO
	'05'																	, ; //X3_ORDEM
	'ZZP_LOCALI'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	15																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Endereco'																, ; //X3_TITULO
	'Endereco'																, ; //X3_TITSPA
	'Endereco'																, ; //X3_TITENG
	'Endereco'																, ; //X3_DESCRIC
	'Endereco'																, ; //X3_DESCSPA
	'Endereco'																, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	'N'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'ZZP'																	, ; //X3_ARQUIVO
	'06'																	, ; //X3_ORDEM
	'ZZP_PRODUT'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	15																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Produto'																, ; //X3_TITULO
	'Produto'																, ; //X3_TITSPA
	'Produto'																, ; //X3_TITENG
	'Produto'																, ; //X3_DESCRIC
	'Produto'																, ; //X3_DESCSPA
	'Produto'																, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	'Vazio() .Or. u_VldZZPPro()'											, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(32)						, ; //X3_USADO
	''																		, ; //X3_RELACAO
	'SB1'																	, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	'Ä'																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	'N'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'ZZP'																	, ; //X3_ARQUIVO
	'07'																	, ; //X3_ORDEM
	'ZZP_LOTECT'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	10																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Lote'																	, ; //X3_TITULO
	'Lote'																	, ; //X3_TITSPA
	'Lote'																	, ; //X3_TITENG
	'Lote'																	, ; //X3_DESCRIC
	'Lote'																	, ; //X3_DESCSPA
	'Lote'																	, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(32)						, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	'S'																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	'Ä'																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	'N'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'ZZP'																	, ; //X3_ARQUIVO
	'08'																	, ; //X3_ORDEM
	'ZZP_DTVALI'															, ; //X3_CAMPO
	'D'																		, ; //X3_TIPO
	8																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Validade'																, ; //X3_TITULO
	'Validade'																, ; //X3_TITSPA
	'Validade'																, ; //X3_TITENG
	'Validade'																, ; //X3_DESCRIC
	'Validade'																, ; //X3_DESCSPA
	'Validade'																, ; //X3_DESCENG
	'@D'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(32)						, ; //X3_USADO
	'STOD("")'																, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	'Ä'																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	'N'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'ZZP'																	, ; //X3_ARQUIVO
	'09'																	, ; //X3_ORDEM
	'ZZP_ESTOQU'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	12																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Estoque'																, ; //X3_TITULO
	'Estoque'																, ; //X3_TITSPA
	'Estoque'																, ; //X3_TITENG
	'Estoque'																, ; //X3_DESCRIC
	'Estoque'																, ; //X3_DESCSPA
	'Estoque'																, ; //X3_DESCENG
	'@E 9,999,999.99'														, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(32)						, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	'N'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'ZZP'																	, ; //X3_ARQUIVO
	'10'																	, ; //X3_ORDEM
	'ZZP_CONTA1'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	12																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Contagem 1'															, ; //X3_TITULO
	'Contagem 1'															, ; //X3_TITSPA
	'Contagem 1'															, ; //X3_TITENG
	'Contagem 1'															, ; //X3_DESCRIC
	'Contagem 1'															, ; //X3_DESCSPA
	'Contagem 1'															, ; //X3_DESCENG
	'@E 9,999,999.99'														, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(32)						, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	'u_Dip76When(1)'														, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	'N'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'ZZP'																	, ; //X3_ARQUIVO
	'11'																	, ; //X3_ORDEM
	'ZZP_CONTA2'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	12																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Contagem 2'															, ; //X3_TITULO
	'Contagem 2'															, ; //X3_TITSPA
	'Contagem 2'															, ; //X3_TITENG
	'Contagem 2'															, ; //X3_DESCRIC
	'Contagem 2'															, ; //X3_DESCSPA
	'Contagem 2'															, ; //X3_DESCENG
	'@E 9,999,999.99'														, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(32)						, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	'u_Dip76When(2)'														, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	'N'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'ZZP'																	, ; //X3_ARQUIVO
	'12'																	, ; //X3_ORDEM
	'ZZP_QTDELE'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	12																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Qtd Eleita'															, ; //X3_TITULO
	'Qtd Eleita'															, ; //X3_TITSPA
	'Qtd Eleita'															, ; //X3_TITENG
	'Qtd Eleita'															, ; //X3_DESCRIC
	'Qtd Eleita'															, ; //X3_DESCSPA
	'Qtd Eleita'															, ; //X3_DESCENG
	'@E 9,999,999.99'														, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(32)						, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	'u_Dip76When(3)'														, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	'N'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'ZZP'																	, ; //X3_ARQUIVO
	'13'																	, ; //X3_ORDEM
	'ZZP_USUARI'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	20																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Usuario'																, ; //X3_TITULO
	'Usuario'																, ; //X3_TITSPA
	'Usuario'																, ; //X3_TITENG
	'Usuario'																, ; //X3_DESCRIC
	'Usuario'																, ; //X3_DESCSPA
	'Usuario'																, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(32)						, ; //X3_USADO
	'Upper(u_DipUsr())'														, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	'N'																		} ) //X3_PYME

//
// Tabela ZZQ
//
aAdd( aSX3, { ;
	'ZZQ'																	, ; //X3_ARQUIVO
	'01'																	, ; //X3_ORDEM
	'ZZQ_FILIAL'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	2																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Filial'																, ; //X3_TITULO
	'Filial'																, ; //X3_TITSPA
	'Filial'																, ; //X3_TITENG
	'Filial'																, ; //X3_DESCRIC
	'Filial'																, ; //X3_DESCSPA
	'Filial'																, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	'033'																	, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	'N'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'ZZQ'																	, ; //X3_ARQUIVO
	'02'																	, ; //X3_ORDEM
	'ZZQ_STATUS'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	1																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Status'																, ; //X3_TITULO
	'Status'																, ; //X3_TITSPA
	'Status'																, ; //X3_TITENG
	'Status'																, ; //X3_DESCRIC
	'Status'																, ; //X3_DESCSPA
	'Status'																, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	'N'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'ZZQ'																	, ; //X3_ARQUIVO
	'03'																	, ; //X3_ORDEM
	'ZZQ_LOCAL'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	2																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Local'																	, ; //X3_TITULO
	'Local'																	, ; //X3_TITSPA
	'Local'																	, ; //X3_TITENG
	'Local'																	, ; //X3_DESCRIC
	'Local'																	, ; //X3_DESCSPA
	'Local'																	, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(32)						, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	'Ä'																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	'Empty(M->ZZQ_LOCAL)'													, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	'N'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'ZZQ'																	, ; //X3_ARQUIVO
	'04'																	, ; //X3_ORDEM
	'ZZQ_LOCALI'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	15																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Endereco'																, ; //X3_TITULO
	'Endereco'																, ; //X3_TITSPA
	'Endereco'																, ; //X3_TITENG
	'Endereco'																, ; //X3_DESCRIC
	'Endereco'																, ; //X3_DESCSPA
	'Endereco'																, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	'(Vazio() .Or. ExistCPO("SBE",M->ZZQ_LOCALIZ,9)) .And. u_VldZZQLoc()'		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(32)						, ; //X3_USADO
	''																		, ; //X3_RELACAO
	'SBE'																	, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	'Ä'																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	'Empty(M->ZZQ_LOCALI)'													, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	'N'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'ZZQ'																	, ; //X3_ARQUIVO
	'05'																	, ; //X3_ORDEM
	'ZZQ_DATA'																, ; //X3_CAMPO
	'D'																		, ; //X3_TIPO
	8																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Data Inv'																, ; //X3_TITULO
	'Data Inv'																, ; //X3_TITSPA
	'Data Inv'																, ; //X3_TITENG
	'Data Inv'																, ; //X3_DESCRIC
	'Data Inv'																, ; //X3_DESCSPA
	'Data Inv'																, ; //X3_DESCENG
	'@D'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(32)						, ; //X3_USADO
	'If(Inclui,dDataBase,ZZQ->ZZQ_DATA)'									, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	'N'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'ZZQ'																	, ; //X3_ARQUIVO
	'07'																	, ; //X3_ORDEM
	'ZZQ_DATAFI'															, ; //X3_CAMPO
	'D'																		, ; //X3_TIPO
	8																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Data Encerra'															, ; //X3_TITULO
	'Data Encerra'															, ; //X3_TITSPA
	'Data Encerra'															, ; //X3_TITENG
	'Data Encerra'															, ; //X3_DESCRIC
	'Data Encerra'															, ; //X3_DESCSPA
	'Data Encerra'															, ; //X3_DESCENG
	'@D'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(32)						, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	'N'																		} ) //X3_PYME
	

aAdd( aSX3, { ;
	'ZZQ'																	, ; //X3_ARQUIVO
	'08'																	, ; //X3_ORDEM
	'ZZQ_CODCO1'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	6																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Cod. Cont1'															, ; //X3_TITULO
	'Cod. Cont1'															, ; //X3_TITSPA
	'Cod. Cont1'															, ; //X3_TITENG
	'Cod. Cont1'															, ; //X3_DESCRIC
	'Cod. Cont1'															, ; //X3_DESCSPA
	'Cod. Cont1'															, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	'Vazio() .Or. ExistCPO("SX5","ZX"+M->ZZQ_CODCO1)'																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(32)						, ; //X3_USADO
	''																		, ; //X3_RELACAO
	'ZX'																	, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	'S'																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	'Empty(M->ZZQ_CODCO1)'													, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	'N'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'ZZQ'																	, ; //X3_ARQUIVO
	'09'																	, ; //X3_ORDEM
	'ZZQ_NOMCO1'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	55																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Nome Cont 1'															, ; //X3_TITULO
	'Nome Cont 1'															, ; //X3_TITSPA
	'Nome Cont 1'															, ; //X3_TITENG
	'Nome Cont 1'															, ; //X3_DESCRIC
	'Nome Cont 1'															, ; //X3_DESCSPA
	'Nome Cont 1'															, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(32)						, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	'N'																		} ) //X3_PYME
	
aAdd( aSX3, { ;
	'ZZQ'																	, ; //X3_ARQUIVO
	'10'																	, ; //X3_ORDEM
	'ZZQ_CODCO2'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	6																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Cod. Cont2'															, ; //X3_TITULO
	'Cod. Cont2'															, ; //X3_TITSPA
	'Cod. Cont2'															, ; //X3_TITENG
	'Cod. Cont2'															, ; //X3_DESCRIC
	'Cod. Cont2'															, ; //X3_DESCSPA
	'Cod. Cont2'															, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	'Vazio() .Or. ExistCPO("SX5","ZX"+M->ZZQ_CODCO2)'																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(32)						, ; //X3_USADO
	''																		, ; //X3_RELACAO
	'ZX'																	, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	'S'																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	'Empty(M->ZZQ_CODCO2)'													, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	'N'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'ZZQ'																	, ; //X3_ARQUIVO
	'11'																	, ; //X3_ORDEM
	'ZZQ_NOMCO2'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	55																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Nome Cont 2'															, ; //X3_TITULO
	'Nome Cont 2'															, ; //X3_TITSPA
	'Nome Cont 2'															, ; //X3_TITENG
	'Nome Cont 2'															, ; //X3_DESCRIC
	'Nome Cont 2'															, ; //X3_DESCSPA
	'Nome Cont 2'															, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(32)						, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	'N'																		} ) //X3_PYME
		

//
// Tabela SB8
//
aAdd( aSX3, { ;
	'SB8'																	, ; //X3_ARQUIVO
	'35'																	, ; //X3_ORDEM
	'B8_XSTATUS'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	1																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Status'																, ; //X3_TITULO
	'Status'																, ; //X3_TITSPA
	'Status'																, ; //X3_TITENG
	'Status'																, ; //X3_DESCRIC
	'Status'																, ; //X3_DESCSPA
	'Status'																, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(32)						, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	'S'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SB8'																	, ; //X3_ARQUIVO
	'36'																	, ; //X3_ORDEM
	'B8_XDATVAL'															, ; //X3_CAMPO
	'D'																		, ; //X3_TIPO
	8																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Data Avaliac'															, ; //X3_TITULO
	'Data Avaliac'															, ; //X3_TITSPA
	'Data Avaliac'															, ; //X3_TITENG
	'Data Avaliacao'														, ; //X3_DESCRIC
	'Data Avaliacao'														, ; //X3_DESCSPA
	'Data Avaliacao'														, ; //X3_DESCENG
	'@D'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(32)						, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	'S'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SB8'																	, ; //X3_ARQUIVO
	'37'																	, ; //X3_ORDEM
	'B8_XUSAVAL'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	50																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Usuario Aval'															, ; //X3_TITULO
	'Usuario Aval'															, ; //X3_TITSPA
	'Usuario Aval'															, ; //X3_TITENG
	'Usuario Avaliador'														, ; //X3_DESCRIC
	'Usuario Avaliador'														, ; //X3_DESCSPA
	'Usuario Avaliador'														, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(32)						, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	'S'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SB8'																	, ; //X3_ARQUIVO
	'38'																	, ; //X3_ORDEM
	'B8_XSALPRO'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	12																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Saldo Promo'															, ; //X3_TITULO
	'Saldo Promo'															, ; //X3_TITSPA
	'Saldo Promo'															, ; //X3_TITENG
	'Saldo Promocional'														, ; //X3_DESCRIC
	'Saldo Promocional'														, ; //X3_DESCSPA
	'Saldo Promocional'														, ; //X3_DESCENG
	'@E 9,999,999.99'														, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(32)						, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	'S'																		} ) //X3_PYME		

aAdd( aSX3, { ;
	'SB8'																	, ; //X3_ARQUIVO
	'38'																	, ; //X3_ORDEM
	'B8_XPERPRO'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	3																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Saldo Promo'															, ; //X3_TITULO
	'Saldo Promo'															, ; //X3_TITSPA
	'Saldo Promo'															, ; //X3_TITENG
	'Saldo Promocional'														, ; //X3_DESCRIC
	'Saldo Promocional'														, ; //X3_DESCSPA
	'Saldo Promocional'														, ; //X3_DESCENG
	'@E 999'																, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(32)						, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	'S'																		} ) //X3_PYME		

//⁄ƒƒƒƒƒƒƒƒƒƒø
//≥Tabela SA2≥
//¿ƒƒƒƒƒƒƒƒƒƒŸ
SX3->(DbSetOrder(1))
SX3->(MsSeek("SA2"+"ZZ",.T.))
SX3->(DbSkip(-1))

cOrdem := Soma1(SX3->X3_ORDEM)   

aAdd( aSX3, { ;
	'SA2'																	, ; //X3_ARQUIVO
	cOrdem																	, ; //X3_ORDEM
	'A2_XQTDMES'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	3																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Qtd de Meses'															, ; //X3_TITULO
	'Qtd de Meses'															, ; //X3_TITSPA
	'Qtd de Meses'															, ; //X3_TITENG
	'Meses p calcular pto pedi'												, ; //X3_DESCRIC
	'Meses p calcular pto pedi'												, ; //X3_DESCSPA
	'Meses p calcular pto pedi'												, ; //X3_DESCENG
	'@E 999'																, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	''																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
    ''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	'1'																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

cOrdem := Soma1(cOrdem)   

aAdd( aSX3, { ;
	'SA2'																	, ; //X3_ARQUIVO
	cOrdem																	, ; //X3_ORDEM
	'A2_XQTDIMES'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	3																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Qtd.Dias Mes'															, ; //X3_TITULO
	'Qtd.Dias Mes'															, ; //X3_TITSPA
	'Qtd.Dias Mes'															, ; //X3_TITENG
	'Dias mes calcular pto ped'												, ; //X3_DESCRIC
	'Dias mes calcular pto ped'												, ; //X3_DESCSPA
	'Dias mes calcular pto ped'												, ; //X3_DESCENG
	'@E 999'																, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	''																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
    ''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	'1'																		, ; //X3_FOLDER
	''																		} ) //X3_PYME
	
cOrdem := Soma1(cOrdem)   

aAdd( aSX3, { ;
	'SA2'																	, ; //X3_ARQUIVO
	cOrdem																	, ; //X3_ORDEM
	'A2_XESTQMES'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	3																		, ; //X3_TAMANHO
	0		 																, ; //X3_DECIMAL
	'Est.Qtd.Dias'															, ; //X3_TITULO
	'Est.Qtd.Dias'															, ; //X3_TITSPA
	'Est.Qtd.Dias'															, ; //X3_TITENG
	'Estoque para quantos dias'												, ; //X3_DESCRIC
	'Estoque para quantos dias'												, ; //X3_DESCSPA
	'Estoque para quantos dias'												, ; //X3_DESCENG
	'@E 999'																, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	''																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
    ''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	'1'																		, ; //X3_FOLDER
	''																		} ) //X3_PYME
         
//⁄ƒƒƒƒƒƒƒƒƒƒø
//≥Tabela SCP≥
//¿ƒƒƒƒƒƒƒƒƒƒŸ
SX3->(DbSetOrder(1))
SX3->(MsSeek("SCP"+"ZZ",.T.))
SX3->(DbSkip(-1))

cOrdem := Soma1(SX3->X3_ORDEM)   

aAdd( aSX3, { ;
	'SCP'																	, ; //X3_ARQUIVO
	cOrdem																	, ; //X3_ORDEM
	'CP_XLOTECT'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	10																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Lote PCP'																, ; //X3_TITULO
	'Lote PCP'																, ; //X3_TITSPA
	'Lote PCP'																, ; //X3_TITENG
	'Lote gravado movimentacao'												, ; //X3_DESCRIC
	'Lote gravado movimentacao'												, ; //X3_DESCSPA
	'Lote gravado movimentacao'												, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
    ''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

cOrdem := Soma1(cOrdem)   

aAdd( aSX3, { ;
	'SCP'																	, ; //X3_ARQUIVO
	cOrdem																	, ; //X3_ORDEM
	'CP_XDTVALI'															, ; //X3_CAMPO
	'D'																		, ; //X3_TIPO
	8																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Valid Lote  '															, ; //X3_TITULO
	'Valid Lote  '															, ; //X3_TITSPA
	'Valid Lote  '															, ; //X3_TITENG
	'Validade do lote da movin'												, ; //X3_DESCRIC
	'Validade do lote da movin'												, ; //X3_DESCSPA
	'Validade do lote da movin'												, ; //X3_DESCENG
	''																		, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
    ''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME
	
cOrdem := Soma1(cOrdem)   

aAdd( aSX3, { ;
	'SCP'																	, ; //X3_ARQUIVO
	cOrdem																	, ; //X3_ORDEM
	'CP_XLOCAL' 															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	2																		, ; //X3_TAMANHO
	0		 																, ; //X3_DECIMAL
	'Almoxarifado'															, ; //X3_TITULO
	'Almoxarifado'															, ; //X3_TITSPA
	'Almoxarifado'															, ; //X3_TITENG
	'Local da movim do produto'												, ; //X3_DESCRIC
	'Local da movim do produto'												, ; //X3_DESCSPA
	'Local da movim do produto'												, ; //X3_DESCENG
	'@!'																, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
    ''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME


cOrdem := Soma1(cOrdem)   

aAdd( aSX3, { ;
	'SCP'																	, ; //X3_ARQUIVO
	cOrdem																	, ; //X3_ORDEM
	'CP_XLOCALI' 															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	15																		, ; //X3_TAMANHO
	0		 																, ; //X3_DECIMAL
	'Localizacao'															, ; //X3_TITULO
	'Localizacao'															, ; //X3_TITSPA
	'Localizacao'															, ; //X3_TITENG
	'Localizacao do produto   '												, ; //X3_DESCRIC
	'Localizacao do produto   '												, ; //X3_DESCSPA
	'Localizacao do produto   '												, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
    ''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME
cOrdem := Soma1(cOrdem)   

aAdd( aSX3, { ;
	'SCP'																	, ; //X3_ARQUIVO
	cOrdem																	, ; //X3_ORDEM
	'CP_XDOC'	 															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	9																		, ; //X3_TAMANHO
	0		 																, ; //X3_DECIMAL
	'Documentacao'															, ; //X3_TITULO
	'Documentacao'															, ; //X3_TITSPA
	'Documentacao'															, ; //X3_TITENG
	'Documento da movimentacao'												, ; //X3_DESCRIC
	'Documento da movimentacao'												, ; //X3_DESCSPA
	'Documento da movimentacao'												, ; //X3_DESCENG
	'@!'																, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
    ''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME





//
// Tabela SF1
//
SX3->(DbSetOrder(1))
SX3->(DbSeek("SF1"+"ZZ",.T.))
SX3->(DbSkip(-1))

cOrdem := Soma1(SX3->X3_ORDEM) 

aAdd( aSX3, { ;
	'SF1'																	, ; //X3_ARQUIVO
	cOrdem																	, ; //X3_ORDEM
	'F1_OK2'	 															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	2																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Entrada N.F.'															, ; //X3_TITULO
	'Entrada N.F.'															, ; //X3_TITSPA
	'Entrada N.F.'															, ; //X3_TITENG
	'Entrada N.F.			  '												, ; //X3_DESCRIC
	'Entrada N.F.			  '												, ; //X3_DESCSPA
	'Entrada N.F.			  '												, ; //X3_DESCENG
	''																		, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) 	 							, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	1																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	'S'																		} ) //X3_PYME    

cOrdem := Soma1(cOrdem)   

aAdd( aSX3, { ;
	'SF1'																	, ; //X3_ARQUIVO
	cOrdem																	, ; //X3_ORDEM
	'F1_XREGCER' 															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	20																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Regist. Cert'															, ; //X3_TITULO
	'Regist. Cert'															, ; //X3_TITSPA
	'Regist. Cert'															, ; //X3_TITENG
	'Regist. Cert			  '												, ; //X3_DESCRIC
	'Regist. Cert			  '												, ; //X3_DESCSPA
	'Regist. Cert			  '												, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) 	 							, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	1																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	'S'																		} ) //X3_PYME    

cOrdem := Soma1(cOrdem)   

aAdd( aSX3, { ;
	'SF1'																	, ; //X3_ARQUIVO
	cOrdem																	, ; //X3_ORDEM
	'F1_XDTRECE' 															, ; //X3_CAMPO
	'D'																		, ; //X3_TIPO
	8																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Dt. Reg.Cert'															, ; //X3_TITULO
	'Dt. Reg.Cert'															, ; //X3_TITSPA
	'Dt. Reg.Cert'															, ; //X3_TITENG
	'Dt. Reg.Cert			  '												, ; //X3_DESCRIC
	'Dt. Reg.Cert			  '												, ; //X3_DESCSPA
	'Dt. Reg.Cert			  '												, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) 	 							, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	1																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	'S'																		} ) //X3_PYME    

cOrdem := Soma1(cOrdem)   

aAdd( aSX3, { ;
	'SF1'																	, ; //X3_ARQUIVO
	cOrdem																	, ; //X3_ORDEM
	'F1_XUSRECE' 															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	20																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Usu Reg.Cert'															, ; //X3_TITULO
	'Usu Reg.Cert'															, ; //X3_TITSPA
	'Usu Reg.Cert'															, ; //X3_TITENG
	'Usu Reg.Cert			  '												, ; //X3_DESCRIC
	'Usu Reg.Cert			  '												, ; //X3_DESCSPA
	'Usu Reg.Cert			  '												, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) 	 							, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	1																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	'S'																		} ) //X3_PYME    


SX3->(DbSetOrder(2))
If SX3->(dbSeek("C6_QTDVEN"))
	aAdd( aSX3, { ;
	'SC6'																	, ; //X3_ARQUIVO
	SX3->X3_ORDEM															, ; //X3_ORDEM
	'C6_QTDVEN'   															, ; //X3_CAMPO
	SX3->X3_TIPO															, ; //X3_TIPO
	SX3->X3_TAMANHO															, ; //X3_TAMANHO
	SX3->X3_DECIMAL															, ; //X3_DECIMAL
	SX3->X3_TITULO															, ; //X3_TITULO
	SX3->X3_TITSPA															, ; //X3_TITSPA
	SX3->X3_TITENG															, ; //X3_TITENG
	SX3->X3_DESCRIC															, ; //X3_DESCRIC
	SX3->X3_DESCSPA															, ; //X3_DESCSPA
	SX3->X3_DESCENG															, ; //X3_DESCENG
	SX3->X3_PICTURE															, ; //X3_PICTURE
	SX3->X3_VALID															, ; //X3_VALID
	SX3->X3_USADO															, ; //X3_USADO
	SX3->X3_RELACAO	 														, ; //X3_RELACAO
	SX3->X3_F3																, ; //X3_F3
	SX3->X3_NIVEL															, ; //X3_NIVEL
	SX3->X3_RESERV															, ; //X3_RESERV
	SX3->X3_CHECK															, ; //X3_CHECK
	SX3->X3_TRIGGER															, ; //X3_TRIGGER
	SX3->X3_PROPRI															, ; //X3_PROPRI
	SX3->X3_BROWSE															, ; //X3_BROWSE
	SX3->X3_VISUAL															, ; //X3_VISUAL
	SX3->X3_CONTEXT															, ; //X3_CONTEXT
	SX3->X3_OBRIGAT    														, ; //X3_OBRIGAT
	'positivo() .And. u_VldQtdDig()'                                        , ; //X3_VLDUSER
	SX3->X3_CBOX															, ; //X3_CBOX
	SX3->X3_CBOXSPA															, ; //X3_CBOXSPA
	SX3->X3_CBOXENG															, ; //X3_CBOXENG
	SX3->X3_PICTVAR															, ; //X3_PICTVAR
	'!Empty(M->C5_CLIENTE)'					   								, ; //X3_WHEN
	SX3->X3_INIBRW															, ; //X3_INIBRW
	SX3->X3_GRPSXG															, ; //X3_GRPSXG
	SX3->X3_FOLDER  														, ; //X3_FOLDER
	SX3->X3_PYME															} ) //X3_PYME
EndIf

SX3->(DbSetOrder(2))
If SX3->(dbSeek("C6_PRODUTO"))
	aAdd( aSX3, { ;
	'SC6'																	, ; //X3_ARQUIVO
	SX3->X3_ORDEM															, ; //X3_ORDEM
	'C6_PRODUTO'   															, ; //X3_CAMPO
	SX3->X3_TIPO															, ; //X3_TIPO
	SX3->X3_TAMANHO															, ; //X3_TAMANHO
	SX3->X3_DECIMAL															, ; //X3_DECIMAL
	SX3->X3_TITULO															, ; //X3_TITULO
	SX3->X3_TITSPA															, ; //X3_TITSPA
	SX3->X3_TITENG															, ; //X3_TITENG
	SX3->X3_DESCRIC															, ; //X3_DESCRIC
	SX3->X3_DESCSPA															, ; //X3_DESCSPA
	SX3->X3_DESCENG															, ; //X3_DESCENG
	SX3->X3_PICTURE															, ; //X3_PICTURE
	SX3->X3_VALID															, ; //X3_VALID
	SX3->X3_USADO															, ; //X3_USADO
	SX3->X3_RELACAO	 														, ; //X3_RELACAO
	IIf(cFilAnt=="01",'SB1DIP',"DIPSB1")									, ; //X3_F3
	SX3->X3_NIVEL															, ; //X3_NIVEL
	SX3->X3_RESERV															, ; //X3_RESERV
	SX3->X3_CHECK															, ; //X3_CHECK
	SX3->X3_TRIGGER															, ; //X3_TRIGGER
	SX3->X3_PROPRI															, ; //X3_PROPRI
	SX3->X3_BROWSE															, ; //X3_BROWSE
	SX3->X3_VISUAL															, ; //X3_VISUAL
	SX3->X3_CONTEXT															, ; //X3_CONTEXT
	SX3->X3_OBRIGAT    														, ; //X3_OBRIGAT
	SX3->X3_VLDUSER                                                         , ; //X3_VLDUSER
	SX3->X3_CBOX															, ; //X3_CBOX
	SX3->X3_CBOXSPA															, ; //X3_CBOXSPA
	SX3->X3_CBOXENG															, ; //X3_CBOXENG
	SX3->X3_PICTVAR															, ; //X3_PICTVAR
	'!Empty(M->C5_CLIENTE)'													, ; //X3_WHEN
	SX3->X3_INIBRW															, ; //X3_INIBRW
	SX3->X3_GRPSXG															, ; //X3_GRPSXG
	SX3->X3_FOLDER  														, ; //X3_FOLDER
	SX3->X3_PYME															} ) //X3_PYME
EndIf

aAdd( aSX3, { ;
	'SC6'																	, ; //X3_ARQUIVO
	'01'																	, ; //X3_ORDEM
	'C6_XEMPENH'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	1																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'J· Empenhou '															, ; //X3_TITULO
	'J· Empenhou '															, ; //X3_TITSPA
	'J· Empenhou '															, ; //X3_TITENG
	'J· Empenhou Lote '														, ; //X3_DESCRIC
	'J· Empenhou Lote '														, ; //X3_DESCSPA
	'J· Empenhou Lote '														, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(32) 					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	'N'																		} ) //X3_PYME

//
// Tabela ZZR
//
aAdd( aSX3, { ;
	'ZZR'																	, ; //X3_ARQUIVO
	'01'																	, ; //X3_ORDEM
	'ZZR_FILIAL'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	2																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Filial'																, ; //X3_TITULO
	'Filial'																, ; //X3_TITSPA
	'Filial'																, ; //X3_TITENG
	'Filial'																, ; //X3_DESCRIC
	'Filial'																, ; //X3_DESCSPA
	'Filial'																, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	'033'																	, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	'N'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'ZZR'																	, ; //X3_ARQUIVO
	'02'																	, ; //X3_ORDEM
	'ZZR_CODCLI'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	6																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Cod Cliente'															, ; //X3_TITULO
	'Cod Cliente'															, ; //X3_TITSPA
	'Cod Cliente'															, ; //X3_TITENG
	'Cod Cliente'															, ; //X3_DESCRIC
	'Cod Cliente'															, ; //X3_DESCSPA
	'Cod Cliente'															, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(32)						, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	'N'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'ZZR'																	, ; //X3_ARQUIVO
	'03'																	, ; //X3_ORDEM
	'ZZR_TIPCLI'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	1																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Tipo Cliente'															, ; //X3_TITULO
	'Tipo Cliente'															, ; //X3_TITSPA
	'Tipo Cliente'															, ; //X3_TITENG
	'Tipo Cliente'															, ; //X3_DESCRIC
	'Tipo Cliente'															, ; //X3_DESCSPA
	'Tipo Cliente'															, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(32)						, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	'N'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'ZZR'																	, ; //X3_ARQUIVO
	'04'																	, ; //X3_ORDEM
	'ZZR_ESTADO'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	2																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Estado'																, ; //X3_TITULO
	'Estado'																, ; //X3_TITSPA
	'Estado'																, ; //X3_TITENG
	'Estado'																, ; //X3_DESCRIC
	'Estado'																, ; //X3_DESCSPA
	'Estado'																, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(32)						, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	'N'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'ZZR'																	, ; //X3_ARQUIVO
	'05'																	, ; //X3_ORDEM
	'ZZR_PERACR'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	5																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'% Acrescimo'															, ; //X3_TITULO
	'% Acrescimo'															, ; //X3_TITSPA
	'% Acrescimo'															, ; //X3_TITENG
	'% Acrescimo'															, ; //X3_DESCRIC
	'% Acrescimo'															, ; //X3_DESCSPA
	'% Acrescimo'															, ; //X3_DESCENG
	'@E 999.99 %'															, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(32)						, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	'N'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'ZZR'																	, ; //X3_ARQUIVO
	'06'																	, ; //X3_ORDEM
	'ZZR_PERIMP'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	5																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'% Acresc.Imp'															, ; //X3_TITULO
	'% Acresc.Imp'															, ; //X3_TITSPA
	'% Acresc.Imp'															, ; //X3_TITENG
	'% Acresc.Imp'															, ; //X3_DESCRIC
	'% Acresc.Imp'															, ; //X3_DESCSPA
	'% Acresc.Imp'															, ; //X3_DESCENG
	'@E 999.99 %'															, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(32)						, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	'N'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'ZZR'																	, ; //X3_ARQUIVO
	'07'																	, ; //X3_ORDEM
	'ZZR_GRPVEN'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	6																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Grp Vendas'															, ; //X3_TITULO
	'Grp Vendas'															, ; //X3_TITSPA
	'Grp Vendas'															, ; //X3_TITENG
	'Grp Vendas'															, ; //X3_DESCRIC
	'Grp Vendas'															, ; //X3_DESCSPA
	'Grp Vendas'															, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(32)						, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	'N'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'ZZR'																	, ; //X3_ARQUIVO
	'08'																	, ; //X3_ORDEM
	'ZZR_CONTRI'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	1																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Contribuinte'															, ; //X3_TITULO
	'Contribuinte'															, ; //X3_TITSPA
	'Contribuinte'															, ; //X3_TITENG
	'Contribuinte'															, ; //X3_DESCRIC
	'Contribuinte'															, ; //X3_DESCSPA
	'Contribuinte'															, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(32)						, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	'N'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'ZZR'																	, ; //X3_ARQUIVO
	'09'																	, ; //X3_ORDEM
	'ZZR_ORIPRO'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	10																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Orig.Produto'															, ; //X3_TITULO
	'Orig.Produto'															, ; //X3_TITSPA
	'Orig.Produto'															, ; //X3_TITENG
	'Orig.Produto'															, ; //X3_DESCRIC
	'Orig.Produto'															, ; //X3_DESCSPA
	'Orig.Produto'															, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(32)						, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	'N'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'ZZB'																	, ; //X3_ARQUIVO
	'04'																	, ; //X3_ORDEM
	'ZZB_VALMIN'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Vlr. Minimo'															, ; //X3_TITULO
	'Vlr. Minimo'															, ; //X3_TITSPA
	'Vlr. Minimo'															, ; //X3_TITENG
	'Vlr. Minimo'															, ; //X3_DESCRIC
	'Vlr. Minimo'															, ; //X3_DESCSPA
	'Vlr. Minimo'															, ; //X3_DESCENG
	'@ 999,999,999.99'														, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(32)						, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	'N'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'CB8'																	, ; //X3_ARQUIVO
	'27'																	, ; //X3_ORDEM
	'CB8_XLCALI'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	15																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Ordem Separ.'															, ; //X3_TITULO
	'Ordem Separ.'															, ; //X3_TITSPA
	'Ordem Separ.'															, ; //X3_TITENG
	'Ordem Separ.'															, ; //X3_DESCRIC
	'Ordem Separ.'															, ; //X3_DESCSPA
	'Ordem Separ.'															, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(32)						, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	'N'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SBE'																	, ; //X3_ARQUIVO
	'36'																	, ; //X3_ORDEM
	'BE_XCODRUA'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	2																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Cod. Rua'																, ; //X3_TITULO
	'Cod. Rua'																, ; //X3_TITSPA
	'Cod. Rua'																, ; //X3_TITENG
	'Cod. Rua'																, ; //X3_DESCRIC
	'Cod. Rua'					 											, ; //X3_DESCSPA
	'Cod. Rua'					   											, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	'N'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SBE'																	, ; //X3_ARQUIVO
	'36'																	, ; //X3_ORDEM
	'BE_XUSUROT'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	30																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Usr. Rotativo'															, ; //X3_TITULO
	'Usr. Rotativo'															, ; //X3_TITSPA
	'Usr. Rotativo'															, ; //X3_TITENG
	'Usr. Rotativo'															, ; //X3_DESCRIC
	'Usr. Rotativo'				 											, ; //X3_DESCSPA
	'Usr. Rotativo'				   											, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	'N'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SBE'																	, ; //X3_ARQUIVO
	'37'																	, ; //X3_ORDEM
	'BE_XNRCONT'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	1																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Nro. Contagem'															, ; //X3_TITULO
	'Nro. Contagem'															, ; //X3_TITSPA
	'Nro. Contagem'															, ; //X3_TITENG
	'Nro. Contagem'															, ; //X3_DESCRIC
	'Nro. Contagem'				 											, ; //X3_DESCSPA
	'Nro. Contagem'				   											, ; //X3_DESCENG
	''																		, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	'N'																		} ) //X3_PYME


aAdd( aSX3, { ;
	'SBE'																	, ; //X3_ARQUIVO
	'38'																	, ; //X3_ORDEM
	'BE_XDATCONT'															, ; //X3_CAMPO
	'D'																		, ; //X3_TIPO
	8																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Data. Contag.'															, ; //X3_TITULO
	'Data. Contag.'															, ; //X3_TITSPA
	'Data. Contag.'															, ; //X3_TITENG
	'Data. Contag.'															, ; //X3_DESCRIC
	'Data. Contag.'				 											, ; //X3_DESCSPA
	'Data. Contag.'				   											, ; //X3_DESCENG
	'@D'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	'N'																		} ) //X3_PYME

//
// Tabela ZZO
//
aAdd( aSX3, { ;
	'ZZO'																	, ; //X3_ARQUIVO
	'01'																	, ; //X3_ORDEM
	'ZZO_FILIAL'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	2																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Filial'																, ; //X3_TITULO
	'Filial'																, ; //X3_TITSPA
	'Filial'																, ; //X3_TITENG
	'Filial'																, ; //X3_DESCRIC
	'Filial'																, ; //X3_DESCSPA
	'Filial'																, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT    
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	'N'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'ZZO'																	, ; //X3_ARQUIVO
	'02'																	, ; //X3_ORDEM
	'ZZO_PEDIDO'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	6																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Pedido'																, ; //X3_TITULO
	'Pedido'																, ; //X3_TITSPA
	'Pedido'																, ; //X3_TITENG
	'Pedido'																, ; //X3_DESCRIC
	'Pedido'																, ; //X3_DESCSPA
	'Pedido'																, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(32)						, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	'N'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'ZZO'																	, ; //X3_ARQUIVO
	'03'																	, ; //X3_ORDEM
	'ZZO_OPERAD'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	6																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Operador'																, ; //X3_TITULO
	'Operador'																, ; //X3_TITSPA
	'Operador'																, ; //X3_TITENG
	'Operador'																, ; //X3_DESCRIC
	'Operador'																, ; //X3_DESCSPA
	'Operador'																, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(32)						, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	'N'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'ZZO'																	, ; //X3_ARQUIVO
	'04'																	, ; //X3_ORDEM
	'ZZO_CLIENT'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	6																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Cliente'																, ; //X3_TITULO
	'Cliente'																, ; //X3_TITSPA
	'Cliente'																, ; //X3_TITENG
	'Cliente'																, ; //X3_DESCRIC
	'Cliente'																, ; //X3_DESCSPA
	'Cliente'																, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(32)						, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	'N'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'ZZO'																	, ; //X3_ARQUIVO
	'05'																	, ; //X3_ORDEM
	'ZZO_LOJA'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	2																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Loja'																	, ; //X3_TITULO
	'Loja'																	, ; //X3_TITSPA
	'Loja'																	, ; //X3_TITENG
	'Loja'																	, ; //X3_DESCRIC
	'Loja'																	, ; //X3_DESCSPA
	'Loja'																	, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(32)						, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	'N'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'ZZO'																	, ; //X3_ARQUIVO
	'06'																	, ; //X3_ORDEM
	'ZZO_PRODUT'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	15																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Produto'																, ; //X3_TITULO
	'Produto'																, ; //X3_TITSPA
	'Produto'																, ; //X3_TITENG
	'Produto'																, ; //X3_DESCRIC
	'Produto'																, ; //X3_DESCSPA
	'Produto'																, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	'u_VldPrdZZO()'															, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(32)						, ; //X3_USADO
	''																		, ; //X3_RELACAO
	'DIPSB1'																, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	'S'																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT     
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	'N'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'ZZO'																	, ; //X3_ARQUIVO
	'07'																	, ; //X3_ORDEM
	'ZZO_DESCRI'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	60																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Descricao'																, ; //X3_TITULO
	'Descricao'																, ; //X3_TITSPA
	'Descricao'																, ; //X3_TITENG
	'Descricao'																, ; //X3_DESCRIC
	'Descricao'																, ; //X3_DESCSPA
	'Descricao'																, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(32)						, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'V'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT   
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	'N'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'ZZO'																	, ; //X3_ARQUIVO
	'08'																	, ; //X3_ORDEM
	'ZZO_QUANT'																, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	10																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Quantidade'															, ; //X3_TITULO
	'Quantidade'															, ; //X3_TITSPA
	'Quantidade'															, ; //X3_TITENG
	'Quantidade'															, ; //X3_DESCRIC
	'Quantidade'															, ; //X3_DESCSPA
	'Quantidade'															, ; //X3_DESCENG
	'@E 99,999,999'															, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(32)						, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	'S'																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT   
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	'N'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'ZZO'																	, ; //X3_ARQUIVO
	'09'																	, ; //X3_ORDEM
	'ZZO_VLRUNI'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	12																		, ; //X3_TAMANHO
	4																		, ; //X3_DECIMAL
	'Vlr Unitario'															, ; //X3_TITULO
	'Vlr Unitario'															, ; //X3_TITSPA
	'Vlr Unitario'															, ; //X3_TITENG
	'Vlr Unitario'															, ; //X3_DESCRIC
	'Vlr Unitario'															, ; //X3_DESCSPA
	'Vlr Unitario'															, ; //X3_DESCENG
	'@E 999,999.9999'														, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(32)						, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT  
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	'N'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'ZZO'																	, ; //X3_ARQUIVO
	'10'																	, ; //X3_ORDEM
	'ZZO_VLRTOT'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	12																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Vlr Total'																, ; //X3_TITULO
	'Vlr Total'																, ; //X3_TITSPA
	'Vlr Total'																, ; //X3_TITENG
	'Vlr Total'																, ; //X3_DESCRIC
	'Vlr Total'																, ; //X3_DESCSPA
	'Vlr Total'																, ; //X3_DESCENG
	'@E 9,999,999.99'														, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(32)						, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT  
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	'N'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'ZZO'																	, ; //X3_ARQUIVO
	'11'																	, ; //X3_ORDEM
	'ZZO_ESTOQU'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	10																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Estoque'																, ; //X3_TITULO
	'Estoque'																, ; //X3_TITSPA
	'Estoque'																, ; //X3_TITENG
	'Estoque'																, ; //X3_DESCRIC
	'Estoque'																, ; //X3_DESCSPA
	'Estoque'																, ; //X3_DESCENG
	'@E 99,999,999'															, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(32)						, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT   
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	'N'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'ZZO'																	, ; //X3_ARQUIVO
	'12'																	, ; //X3_ORDEM
	'ZZO_EXPLIC'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	1																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Explicacao'															, ; //X3_TITULO
	'Explicacao'															, ; //X3_TITSPA
	'Explicacao'															, ; //X3_TITENG
	'Explicacao'															, ; //X3_DESCRIC
	'Explicacao'															, ; //X3_DESCSPA
	'Explicacao'															, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(32)						, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT   
	''																		, ; //X3_VLDUSER	
	'P=Perda Parcial;T=Perda Total;C=Cotacao;F=Caixa Fechada'				, ; //X3_CBOX
	'P=Perda Parcial;T=Perda Total;C=Cotacao;F=Caixa Fechada'				, ; //X3_CBOXSPA
	'P=Perda Parcial;T=Perda Total;C=Cotacao;F=Caixa Fechada'				, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	'N'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'ZZO'																	, ; //X3_ARQUIVO
	'13'																	, ; //X3_ORDEM
	'ZZO_DATA'																, ; //X3_CAMPO
	'D'																		, ; //X3_TIPO
	8																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Data'																	, ; //X3_TITULO
	'Data'																	, ; //X3_TITSPA
	'Data'																	, ; //X3_TITENG
	'Data'																	, ; //X3_DESCRIC
	'Data'																	, ; //X3_DESCSPA
	'Data'																	, ; //X3_DESCENG
	'@D'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(32)						, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	'N'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SA4'																	, ; //X3_ARQUIVO
	'01'																	, ; //X3_ORDEM
	'A4_MSBLQL' 															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	1																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Bloqueado?'															, ; //X3_TITULO
	'Bloqueado?'															, ; //X3_TITSPA
	'Bloqueado?'															, ; //X3_TITENG
	'Registro bloqueado'													, ; //X3_DESCRIC
	'Registro bloqueado'													, ; //X3_DESCSPA
	'Registro bloqueado'													, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, ; //X3_USADO
	'"2"'																	, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'S'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	'1=Sim;2=Nao'															, ; //X3_CBOX
	'1=Sim;2=Nao'															, ; //X3_CBOXSPA
	'1=Sim;2=Nao'															, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	'S'																		} ) //X3_PYME

SX3->(DbSetOrder(2))
If SX3->(dbSeek("D1_FCICOD"))	
	aAdd( aSX3, { ;
	'SD1'																	, ; //X3_ARQUIVO
	SX3->X3_ORDEM															, ; //X3_ORDEM
	'D1_FCICOD'   															, ; //X3_CAMPO
	SX3->X3_TIPO															, ; //X3_TIPO
	SX3->X3_TAMANHO															, ; //X3_TAMANHO
	SX3->X3_DECIMAL															, ; //X3_DECIMAL
	SX3->X3_TITULO															, ; //X3_TITULO
	SX3->X3_TITSPA															, ; //X3_TITSPA
	SX3->X3_TITENG															, ; //X3_TITENG
	SX3->X3_DESCRIC															, ; //X3_DESCRIC
	SX3->X3_DESCSPA															, ; //X3_DESCSPA
	SX3->X3_DESCENG															, ; //X3_DESCENG
	SX3->X3_PICTURE															, ; //X3_PICTURE
	SX3->X3_VALID															, ; //X3_VALID
	SX3->X3_USADO															, ; //X3_USADO
	SX3->X3_RELACAO 														, ; //X3_RELACAO
	SX3->X3_F3																, ; //X3_F3
	SX3->X3_NIVEL															, ; //X3_NIVEL
	SX3->X3_RESERV															, ; //X3_RESERV
	SX3->X3_CHECK															, ; //X3_CHECK
	SX3->X3_TRIGGER															, ; //X3_TRIGGER
	SX3->X3_PROPRI															, ; //X3_PROPRI
	SX3->X3_BROWSE															, ; //X3_BROWSE
	SX3->X3_VISUAL															, ; //X3_VISUAL
	SX3->X3_CONTEXT															, ; //X3_CONTEXT
	SX3->X3_OBRIGAT    														, ; //X3_OBRIGAT
	"u_DipVldFCI()"                                                         , ; //X3_VLDUSER
	SX3->X3_CBOX															, ; //X3_CBOX
	SX3->X3_CBOXSPA															, ; //X3_CBOXSPA
	SX3->X3_CBOXENG															, ; //X3_CBOXENG
	SX3->X3_PICTVAR															, ; //X3_PICTVAR
	SX3->X3_WHEN															, ; //X3_WHEN
	SX3->X3_INIBRW															, ; //X3_INIBRW
	SX3->X3_GRPSXG															, ; //X3_GRPSXG
	SX3->X3_FOLDER  														, ; //X3_FOLDER
	SX3->X3_PYME															} ) //X3_PYME
EndIf

SX3->(DbSetOrder(2))
If SX3->(dbSeek("D1_NOMPROD"))	
	aAdd( aSX3, { ;
	'SD1'																	, ; //X3_ARQUIVO
	SX3->X3_ORDEM															, ; //X3_ORDEM
	'D1_NOMPROD'   															, ; //X3_CAMPO
	SX3->X3_TIPO															, ; //X3_TIPO
	SX3->X3_TAMANHO															, ; //X3_TAMANHO
	SX3->X3_DECIMAL															, ; //X3_DECIMAL
	SX3->X3_TITULO															, ; //X3_TITULO
	SX3->X3_TITSPA															, ; //X3_TITSPA
	SX3->X3_TITENG															, ; //X3_TITENG
	SX3->X3_DESCRIC															, ; //X3_DESCRIC
	SX3->X3_DESCSPA															, ; //X3_DESCSPA
	SX3->X3_DESCENG															, ; //X3_DESCENG
	SX3->X3_PICTURE															, ; //X3_PICTURE
	SX3->X3_VALID															, ; //X3_VALID
	SX3->X3_USADO															, ; //X3_USADO
	'FDESC("SB1",SD1->D1_COD,"SB1->B1_DESC")' 								, ; //X3_RELACAO
	SX3->X3_F3																, ; //X3_F3
	SX3->X3_NIVEL															, ; //X3_NIVEL
	SX3->X3_RESERV															, ; //X3_RESERV
	SX3->X3_CHECK															, ; //X3_CHECK
	SX3->X3_TRIGGER															, ; //X3_TRIGGER
	SX3->X3_PROPRI															, ; //X3_PROPRI
	SX3->X3_BROWSE															, ; //X3_BROWSE
	SX3->X3_VISUAL															, ; //X3_VISUAL
	SX3->X3_CONTEXT															, ; //X3_CONTEXT
	SX3->X3_OBRIGAT    														, ; //X3_OBRIGAT
	SX3->X3_VLDUSER                                                         , ; //X3_VLDUSER
	SX3->X3_CBOX															, ; //X3_CBOX
	SX3->X3_CBOXSPA															, ; //X3_CBOXSPA
	SX3->X3_CBOXENG															, ; //X3_CBOXENG
	SX3->X3_PICTVAR															, ; //X3_PICTVAR
	SX3->X3_WHEN															, ; //X3_WHEN
	SX3->X3_INIBRW															, ; //X3_INIBRW
	SX3->X3_GRPSXG															, ; //X3_GRPSXG
	SX3->X3_FOLDER  														, ; //X3_FOLDER
	SX3->X3_PYME															} ) //X3_PYME
EndIf

aAdd( aSX3, { ;
	'ZZ5'																	, ; //X3_ARQUIVO
	'11'																	, ; //X3_ORDEM
	'ZZ5_EXPEDM'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	120																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Expedicao M'															, ; //X3_TITULO
	'Expedicao M'															, ; //X3_TITSPA
	'Expedicao M'															, ; //X3_TITENG
	'Expedicao Mezanino'													, ; //X3_DESCRIC
	'Expedicao Mezanino'													, ; //X3_DESCSPA
	'Expedicao Mezanino'													, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SE4'																	, ; //X3_ARQUIVO
	'10'																	, ; //X3_ORDEM
	'E4_XUSRACR'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	5																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Acresc. DIP.'															, ; //X3_TITULO
	'Acresc. DIP.'															, ; //X3_TITSPA
	'Acresc. DIP.'															, ; //X3_TITENG
	'Acresc. DIP.'															, ; //X3_DESCRIC
	'Acresc. DIP.'															, ; //X3_DESCSPA
	'Acresc. DIP.'															, ; //X3_DESCENG
	'@E 99.99'																, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(32)						, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT  
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	'N'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SC6'																	, ; //X3_ARQUIVO
	'10'																	, ; //X3_ORDEM
	'C6_XUSRACR'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	5																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Acresc. DIP.'															, ; //X3_TITULO
	'Acresc. DIP.'															, ; //X3_TITSPA
	'Acresc. DIP.'															, ; //X3_TITENG
	'Acresc. DIP.'															, ; //X3_DESCRIC
	'Acresc. DIP.'															, ; //X3_DESCSPA
	'Acresc. DIP.'															, ; //X3_DESCENG
	'@E 99.99'																, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(32)						, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT  
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	'N'																		} ) //X3_PYME

//
// Tabela ZZS
//
aAdd( aSX3, { ;
	'ZZS'																	, ; //X3_ARQUIVO
	'01'																	, ; //X3_ORDEM
	'ZZS_FILIAL'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	2																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Filial'																, ; //X3_TITULO
	'Filial'																, ; //X3_TITSPA
	'Filial'																, ; //X3_TITENG
	'Filial'																, ; //X3_DESCRIC
	'Filial'																, ; //X3_DESCSPA
	'Filial'																, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'ZZS'																	, ; //X3_ARQUIVO
	'02'																	, ; //X3_ORDEM
	'ZZS_CGC'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'CPF / CNPJ'															, ; //X3_TITULO
	'CPF / CNPJ'															, ; //X3_TITSPA
	'CPF / CNPJ'															, ; //X3_TITENG
	'CPF / CNPJ'															, ; //X3_DESCRIC
	'CPF / CNPJ'															, ; //X3_DESCSPA
	'CPF / CNPJ'															, ; //X3_DESCENG
	''																		, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(32)						, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'ZZS'																	, ; //X3_ARQUIVO
	'03'																	, ; //X3_ORDEM
	'ZZS_FILCLI'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	3																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Fil. Cliente'															, ; //X3_TITULO
	'Fil. Cliente'															, ; //X3_TITSPA
	'Fil. Cliente'															, ; //X3_TITENG
	'Fil. Cliente'															, ; //X3_DESCRIC
	'Fil. Cliente'															, ; //X3_DESCSPA
	'Fil. Cliente'															, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(32)						, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'ZZS'																	, ; //X3_ARQUIVO
	'04'																	, ; //X3_ORDEM
	'ZZS_NOME'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	60																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Nome'																	, ; //X3_TITULO
	'Nome'																	, ; //X3_TITSPA
	'Nome'																	, ; //X3_TITENG
	'Nome'																	, ; //X3_DESCRIC
	'Nome'																	, ; //X3_DESCSPA
	'Nome'																	, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(32)						, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'ZZS'																	, ; //X3_ARQUIVO
	'05'																	, ; //X3_ORDEM
	'ZZS_TIPO'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	1																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Tipo'																	, ; //X3_TITULO
	'Tipo'																	, ; //X3_TITSPA
	'Tipo'																	, ; //X3_TITENG
	'Tipo'																	, ; //X3_DESCRIC
	'Tipo'																	, ; //X3_DESCSPA
	'Tipo'																	, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(32)						, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'ZZS'																	, ; //X3_ARQUIVO
	'06'																	, ; //X3_ORDEM
	'ZZS_VIGINI'															, ; //X3_CAMPO
	'D'																		, ; //X3_TIPO
	8																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Vigencia Ini'															, ; //X3_TITULO
	'Vigencia Ini'															, ; //X3_TITSPA
	'Vigencia Ini'															, ; //X3_TITENG
	'Vigencia Ini'															, ; //X3_DESCRIC
	'Vigencia Ini'															, ; //X3_DESCSPA
	'Vigencia Ini'															, ; //X3_DESCENG
	'@D'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(32)						, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'ZZS'																	, ; //X3_ARQUIVO
	'07'																	, ; //X3_ORDEM
	'ZZS_VIGFIN'															, ; //X3_CAMPO
	'D'																		, ; //X3_TIPO
	8																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Vigencia Fin'															, ; //X3_TITULO
	'Vigencia Fin'															, ; //X3_TITSPA
	'Vigencia Fin'															, ; //X3_TITENG
	'Vigencia Fin'															, ; //X3_DESCRIC
	'Vigencia Fin'															, ; //X3_DESCSPA
	'Vigencia Fin'															, ; //X3_DESCENG
	'@D'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(32)						, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'ZZS'																	, ; //X3_ARQUIVO
	'08'																	, ; //X3_ORDEM
	'ZZS_PERCEN'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	1																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Percentual ?'															, ; //X3_TITULO
	'Percentual ?'															, ; //X3_TITSPA
	'Percentual ?'															, ; //X3_TITENG
	'Percentual ?'															, ; //X3_DESCRIC
	'Percentual ?'															, ; //X3_DESCSPA
	'Percentual ?'															, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(32)						, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'ZZS'																	, ; //X3_ARQUIVO
	'09'																	, ; //X3_ORDEM
	'ZZS_PERCTX'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	3																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Perc. Taxa'															, ; //X3_TITULO
	'Perc. Taxa'															, ; //X3_TITSPA
	'Perc. Taxa'															, ; //X3_TITENG
	'Perc. Taxa'															, ; //X3_DESCRIC
	'Perc. Taxa'															, ; //X3_DESCSPA
	'Perc. Taxa'															, ; //X3_DESCENG
	'@E 999 %'																, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(32)						, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'ZZS'																	, ; //X3_ARQUIVO
	'10'																	, ; //X3_ORDEM
	'ZZS_VALTX'																, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	10																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Valor Taxa'															, ; //X3_TITULO
	'Valor Taxa'															, ; //X3_TITSPA
	'Valor Taxa'															, ; //X3_TITENG
	'Valor Taxa'															, ; //X3_DESCRIC
	'Valor Taxa'															, ; //X3_DESCSPA
	'Valor Taxa'															, ; //X3_DESCENG
	'@E 999.999,99'															, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(32)						, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'ZZS'																	, ; //X3_ARQUIVO
	'11'																	, ; //X3_ORDEM
	'ZZS_CATEGO'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	10																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Categoria'																, ; //X3_TITULO
	'Categoria'																, ; //X3_TITSPA
	'Categoria'																, ; //X3_TITENG
	'Categoria'																, ; //X3_DESCRIC
	'Categoria'																, ; //X3_DESCSPA
	'Categoria'																, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(32)						, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'ZZS'																	, ; //X3_ARQUIVO
	'12'																	, ; //X3_ORDEM
	'ZZS_MODAL'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	1																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Modal'																	, ; //X3_TITULO
	'Modal'																	, ; //X3_TITSPA
	'Modal'																	, ; //X3_TITENG
	'Modal'																	, ; //X3_DESCRIC
	'Modal'																	, ; //X3_DESCSPA
	'Modal'																	, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(32)						, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'ZZS'																	, ; //X3_ARQUIVO
	'13'																	, ; //X3_ORDEM
	'ZZS_CIDADE'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	60																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Cidade'																, ; //X3_TITULO
	'Cidade'																, ; //X3_TITSPA
	'Cidade'																, ; //X3_TITENG
	'Cidade'																, ; //X3_DESCRIC
	'Cidade'																, ; //X3_DESCSPA
	'Cidade'																, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(32)						, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'ZZS'																	, ; //X3_ARQUIVO
	'14'																	, ; //X3_ORDEM
	'ZZS_ESTADO'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	2																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Estado'																, ; //X3_TITULO
	'Estado'																, ; //X3_TITSPA
	'Estado'																, ; //X3_TITENG
	'Estado'																, ; //X3_DESCRIC
	'Estado'																, ; //X3_DESCSPA
	'Estado'																, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(32)						, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

//
// Tabela ZZT
//
aAdd( aSX3, { ;
	'ZZT'																	, ; //X3_ARQUIVO
	'01'																	, ; //X3_ORDEM
	'ZZT_FILIAL'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	2																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Filial'																, ; //X3_TITULO
	'Filial'																, ; //X3_TITSPA
	'Filial'																, ; //X3_TITENG
	'Filial'																, ; //X3_DESCRIC
	'Filial'																, ; //X3_DESCSPA
	'Filial'																, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'ZZT'																	, ; //X3_ARQUIVO
	'02'																	, ; //X3_ORDEM
	'ZZT_PEDIDO'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	6																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Pedido'																, ; //X3_TITULO
	'Pedido'																, ; //X3_TITSPA
	'Pedido'																, ; //X3_TITENG
	'Pedido'																, ; //X3_DESCRIC
	'Pedido'																, ; //X3_DESCSPA
	'Pedido'																, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(32)						, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'ZZT'																	, ; //X3_ARQUIVO
	'03'																	, ; //X3_ORDEM
	'ZZT_ITEM'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	3																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Item'																	, ; //X3_TITULO
	'Item'																	, ; //X3_TITSPA
	'Item'																	, ; //X3_TITENG
	'Item'																	, ; //X3_DESCRIC
	'Item'																	, ; //X3_DESCSPA
	'Item'																	, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(32)						, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'ZZT'																	, ; //X3_ARQUIVO
	'04'																	, ; //X3_ORDEM
	'ZZT_EXPLIC'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	255																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Explicacao'															, ; //X3_TITULO
	'Explicacao'															, ; //X3_TITSPA
	'Explicacao'															, ; //X3_TITENG
	'Explicacao'															, ; //X3_DESCRIC
	'Explicacao'															, ; //X3_DESCSPA
	'Explicacao'															, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(32)						, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'ZZT'																	, ; //X3_ARQUIVO
	'05'																	, ; //X3_ORDEM
	'ZZT_DATA'																, ; //X3_CAMPO
	'D'																		, ; //X3_TIPO
	8																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Data'																	, ; //X3_TITULO
	'Data'																	, ; //X3_TITSPA
	'Data'																	, ; //X3_TITENG
	'Data'																	, ; //X3_DESCRIC
	'Data'																	, ; //X3_DESCSPA
	'Data'																	, ; //X3_DESCENG
	'@D'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(32)						, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'ZZT'																	, ; //X3_ARQUIVO
	'06'																	, ; //X3_ORDEM
	'ZZT_HORA'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	5																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Hora'																	, ; //X3_TITULO
	'Hora'																	, ; //X3_TITSPA
	'Hora'																	, ; //X3_TITENG
	'Hora'																	, ; //X3_DESCRIC
	'Hora'																	, ; //X3_DESCSPA
	'Hora'																	, ; //X3_DESCENG
	'@R 99:99'																, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(32)						, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'ZZT'																	, ; //X3_ARQUIVO
	'07'																	, ; //X3_ORDEM
	'ZZT_USUARI'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	10																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Usuario'																, ; //X3_TITULO
	'Usuario'																, ; //X3_TITSPA
	'Usuario'																, ; //X3_TITENG
	'Usuario'																, ; //X3_DESCRIC
	'Usuario'																, ; //X3_DESCSPA
	'Usuario'																, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(32)						, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SC2'																	, ; //X3_ARQUIVO
	'D5'																	, ; //X3_ORDEM
	'C2_XCODREQ'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	6																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'CÛd.Req'																, ; //X3_TITULO
	'CÛd.Req'																, ; //X3_TITSPA
	'CÛd.Req'																, ; //X3_TITENG
	'CÛdigo da RequisiÁ„o'													, ; //X3_DESCRIC
	'CÛdigo da RequisiÁ„o'													, ; //X3_DESCSPA
	'CÛdigo da RequisiÁ„o'													, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SC2'																	, ; //X3_ARQUIVO
	'D6'																	, ; //X3_ORDEM
	'C2_XLOTECT'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	10																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Lote '																	, ; //X3_TITULO
	'Lote '																	, ; //X3_TITSPA
	'Lote '																	, ; //X3_TITENG
	'Numero d lote gerado'													, ; //X3_DESCRIC
	'Numero d lote gerado'													, ; //X3_DESCSPA
	'Numero d lote gerado'													, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME


SX3->(DbSetOrder(2))
If SX3->(dbSeek("C2_BATCH"))
	aAdd( aSX3, { ;
	'SC2'																	, ; //X3_ARQUIVO
	SX3->X3_ORDEM															, ; //X3_ORDEM
	'C2_BATCH'   															, ; //X3_CAMPO
	SX3->X3_TIPO															, ; //X3_TIPO
	SX3->X3_TAMANHO															, ; //X3_TAMANHO
	SX3->X3_DECIMAL															, ; //X3_DECIMAL
	SX3->X3_TITULO															, ; //X3_TITULO
	SX3->X3_TITSPA															, ; //X3_TITSPA
	SX3->X3_TITENG															, ; //X3_TITENG
	SX3->X3_DESCRIC															, ; //X3_DESCRIC
	SX3->X3_DESCSPA															, ; //X3_DESCSPA
	SX3->X3_DESCENG															, ; //X3_DESCENG
	SX3->X3_PICTURE															, ; //X3_PICTURE
	SX3->X3_VALID															, ; //X3_VALID
	SX3->X3_USADO															, ; //X3_USADO
	'"S"'			 														, ; //X3_RELACAO
	SX3->X3_F3																, ; //X3_F3
	SX3->X3_NIVEL															, ; //X3_NIVEL
	SX3->X3_RESERV															, ; //X3_RESERV
	SX3->X3_CHECK															, ; //X3_CHECK
	SX3->X3_TRIGGER															, ; //X3_TRIGGER
	SX3->X3_PROPRI															, ; //X3_PROPRI
	SX3->X3_BROWSE															, ; //X3_BROWSE
	SX3->X3_VISUAL															, ; //X3_VISUAL
	SX3->X3_CONTEXT															, ; //X3_CONTEXT
	SX3->X3_OBRIGAT    														, ; //X3_OBRIGAT
	SX3->X3_VLDUSER                                                         , ; //X3_VLDUSER
	SX3->X3_CBOX															, ; //X3_CBOX
	SX3->X3_CBOXSPA															, ; //X3_CBOXSPA
	SX3->X3_CBOXENG															, ; //X3_CBOXENG
	SX3->X3_PICTVAR															, ; //X3_PICTVAR
	SX3->X3_WHEN															, ; //X3_WHEN
	SX3->X3_INIBRW															, ; //X3_INIBRW
	SX3->X3_GRPSXG															, ; //X3_GRPSXG
	SX3->X3_FOLDER  														, ; //X3_FOLDER
	SX3->X3_PYME															} ) //X3_PYME
EndIf


//
// Tabela ZZU
//
aAdd( aSX3, { ;
	'ZZU'																	, ; //X3_ARQUIVO
	'01'																	, ; //X3_ORDEM
	'ZZU_FILIAL'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	2																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Filial'																, ; //X3_TITULO
	'Filial'																, ; //X3_TITSPA
	'Filial'																, ; //X3_TITENG
	'Filial'																, ; //X3_DESCRIC
	'Filial'																, ; //X3_DESCSPA
	'Filial'																, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	'S'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'ZZU'																	, ; //X3_ARQUIVO
	'02'																	, ; //X3_ORDEM
	'ZZU_CODPRO'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	15																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Produto'																, ; //X3_TITULO
	'Produto'																, ; //X3_TITSPA
	'Produto'																, ; //X3_TITENG
	'Produto'																, ; //X3_DESCRIC
	'Produto'																, ; //X3_DESCSPA
	'Produto'																, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(32)						, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	'S'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'ZZU'																	, ; //X3_ARQUIVO
	'03'																	, ; //X3_ORDEM
	'ZZU_LOCAL'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	2																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Local'																	, ; //X3_TITULO
	'Local'																	, ; //X3_TITSPA
	'Local'																	, ; //X3_TITENG
	'Local'																	, ; //X3_DESCRIC
	'Local'																	, ; //X3_DESCSPA
	'Local'																	, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(32)						, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	'S'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'ZZU'																	, ; //X3_ARQUIVO
	'04'																	, ; //X3_ORDEM
	'ZZU_LOTECT'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	10																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Lote'																	, ; //X3_TITULO
	'Lote'																	, ; //X3_TITSPA
	'Lote'																	, ; //X3_TITENG
	'Lote'																	, ; //X3_DESCRIC
	'Lote'																	, ; //X3_DESCSPA
	'Lote'																	, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(32)						, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	'S'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'ZZU'																	, ; //X3_ARQUIVO
	'05'																	, ; //X3_ORDEM
	'ZZU_LOCALI'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	15																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Endereco'																, ; //X3_TITULO
	'Endereco'																, ; //X3_TITSPA
	'Endereco'																, ; //X3_TITENG
	'Endereco'																, ; //X3_DESCRIC
	'Endereco'																, ; //X3_DESCSPA
	'Endereco'																, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(32)						, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	'S'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'ZZU'																	, ; //X3_ARQUIVO
	'06'																	, ; //X3_ORDEM
	'ZZU_QUANT'																, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	12																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Quantidade'															, ; //X3_TITULO
	'Quantidade'															, ; //X3_TITSPA
	'Quantidade'															, ; //X3_TITENG
	'Quantidade'															, ; //X3_DESCRIC
	'Quantidade'															, ; //X3_DESCSPA
	'Quantidade'															, ; //X3_DESCENG
	'@E 9.999.999,99'														, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(32)						, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	'S'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'ZZU'																	, ; //X3_ARQUIVO
	'07'																	, ; //X3_ORDEM
	'ZZU_STATUS'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	1																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Status'																, ; //X3_TITULO
	'Status'																, ; //X3_TITSPA
	'Status'																, ; //X3_TITENG
	'Status'																, ; //X3_DESCRIC
	'Status'																, ; //X3_DESCSPA
	'Status'																, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(32)						, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	'S'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'ZZU'																	, ; //X3_ARQUIVO
	'08'																	, ; //X3_ORDEM
	'ZZU_DATA'																, ; //X3_CAMPO
	'D'																		, ; //X3_TIPO
	8																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Data'																	, ; //X3_TITULO
	'Data'																	, ; //X3_TITSPA
	'Data'																	, ; //X3_TITENG
	'Data'																	, ; //X3_DESCRIC
	'Data'																	, ; //X3_DESCSPA
	'Data'																	, ; //X3_DESCENG
	'@D'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(32)						, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	'S'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'ZZU'																	, ; //X3_ARQUIVO
	'09'																	, ; //X3_ORDEM
	'ZZU_USUARI'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	30																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Usuario'																, ; //X3_TITULO
	'Usuario'																, ; //X3_TITSPA
	'Usuario'																, ; //X3_TITENG
	'Usuario'																, ; //X3_DESCRIC
	'Usuario'																, ; //X3_DESCSPA
	'Usuario'																, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(32)						, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	'S'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'ZZU'																	, ; //X3_ARQUIVO
	'10'																	, ; //X3_ORDEM
	'ZZU_CODIGO'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	6																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Codigo'																, ; //X3_TITULO
	'Codigo'																, ; //X3_TITSPA
	'Codigo'																, ; //X3_TITENG
	'Codigo'																, ; //X3_DESCRIC
	'Codigo'																, ; //X3_DESCSPA
	'Codigo'																, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(32)						, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	'S'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'ZZU'																	, ; //X3_ARQUIVO
	'11'																	, ; //X3_ORDEM
	'ZZU_HORA'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	5																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Hora'																	, ; //X3_TITULO
	'Hora'																	, ; //X3_TITSPA
	'Hora'																	, ; //X3_TITENG
	'Hora'																	, ; //X3_DESCRIC
	'Hora'																	, ; //X3_DESCSPA
	'Hora'																	, ; //X3_DESCENG
	'@R 99:99'																, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(32)						, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	'S'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'ZZU'																	, ; //X3_ARQUIVO
	'12'																	, ; //X3_ORDEM
	'ZZU_NOTA'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	9																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Nota Fiscal'															, ; //X3_TITULO
	'Nota Fiscal'															, ; //X3_TITSPA
	'Nota Fiscal'															, ; //X3_TITENG
	'Nota Fiscal'															, ; //X3_DESCRIC
	'Nota Fiscal'															, ; //X3_DESCSPA
	'Nota Fiscal'															, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(32)						, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	'S'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'ZZU'																	, ; //X3_ARQUIVO
	'13'																	, ; //X3_ORDEM
	'ZZU_SERIE'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	3																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Serie'																	, ; //X3_TITULO
	'Serie'																	, ; //X3_TITSPA
	'Serie'																	, ; //X3_TITENG
	'Serie'																	, ; //X3_DESCRIC
	'Serie'																	, ; //X3_DESCSPA
	'Serie'																	, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(32)						, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	'S'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SC5'																	, ; //X3_ARQUIVO
	'H1'																	, ; //X3_ORDEM
	'C5_XBLQAUT'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	1																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Bloq.Aut.'																, ; //X3_TITULO
	'Bloq.Aut.'																, ; //X3_TITSPA
	'Bloq.Aut.'																, ; //X3_TITENG
	'Bloqueio Automatico'													, ; //X3_DESCRIC
	'Bloqueio Automatico'													, ; //X3_DESCSPA
	'Bloqueio Automatico'													, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	'N'																		} ) //X3_PYME


//
// Tabela ZZ8
//

aAdd( aSX3, { ;
	'ZZ8'																	, ; //X3_ARQUIVO
	'12'																	, ; //X3_ORDEM
	'ZZ8_HRINCL' 															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	5																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Hr. Inclusao'															, ; //X3_TITULO
	'Hr. Inclusao'															, ; //X3_TITSPA
	'Hr. Inclusao'															, ; //X3_TITENG
	'Hora da Inclus„o         '												, ; //X3_DESCRIC
	'Hora da Inclus„o         '												, ; //X3_DESCSPA
	'Hora da Inclus„o         '												, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(32)						, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	'N'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'ZZ8'																	, ; //X3_ARQUIVO
	'13'																	, ; //X3_ORDEM
	'ZZ8_USUAR4'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	15																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Gerou Empenh'															, ; //X3_TITULO
	'Gerou Empenh'															, ; //X3_TITSPA
	'Gerou Empenh'															, ; //X3_TITENG
	'Usuario do Empenho  '													, ; //X3_DESCRIC
	'Usuario do Empenho  '													, ; //X3_DESCSPA
	'Usuario do Empenho  '													, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(32)						, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME


aAdd( aSX3, { ;
	'ZZ8'																	, ; //X3_ARQUIVO
	'14'																	, ; //X3_ORDEM
	'ZZ8_DATEMP'															, ; //X3_CAMPO
	'D'																		, ; //X3_TIPO
	8																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Dt Empenho  '															, ; //X3_TITULO
	'Dt Empenho  '															, ; //X3_TITSPA
	'Dt Empenho  '															, ; //X3_TITENG
	'Data do Empenho          '												, ; //X3_DESCRIC
	'Data do Empenho          '												, ; //X3_DESCSPA
	'Data do Empenho          ' 											, ; //X3_DESCENG
	'@D'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(32)						, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME
	

aAdd( aSX3, { ;
	'ZZ8'																	, ; //X3_ARQUIVO
	'15'																	, ; //X3_ORDEM
	'ZZ8_HREMPE' 															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	5																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Hr Empenho  '															, ; //X3_TITULO
	'Hr Empenho  '															, ; //X3_TITSPA
	'Hr Empenho  '															, ; //X3_TITENG
	'Hora do Empenho          '												, ; //X3_DESCRIC
	'Hora do Empenho          '												, ; //X3_DESCSPA
	'Hora do Empenho          '												, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(32)						, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	'N'																		} ) //X3_PYME
                                                                                         

aAdd( aSX3, { ;
	'ZZ8'																	, ; //X3_ARQUIVO
	'16'																	, ; //X3_ORDEM
	'ZZ8_HRFINA' 															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	5																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Hr Finalizac'															, ; //X3_TITULO
	'Hr Finalizac'															, ; //X3_TITSPA
	'Hr Finalizac'															, ; //X3_TITENG
	'Hora da Finalizacao      '												, ; //X3_DESCRIC
	'Hora da Finalizacao      '												, ; //X3_DESCSPA
	'Hora da Finalizacao      '												, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(32)						, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	'N'																		} ) //X3_PYME


aAdd( aSX3, { ;
	'ZZ8'																	, ; //X3_ARQUIVO
	'17'																	, ; //X3_ORDEM
	'ZZ8_USUAR5'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	15																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Estornou    '															, ; //X3_TITULO
	'Estornou    '															, ; //X3_TITSPA
	'Estornou    '															, ; //X3_TITENG
	'Usuario que Estonou'													, ; //X3_DESCRIC
	'Usuario que Estornou'													, ; //X3_DESCSPA
	'Usuario que Estornou'													, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(32)						, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME


aAdd( aSX3, { ;
	'ZZ8'																	, ; //X3_ARQUIVO
	'18'																	, ; //X3_ORDEM
	'ZZ8_DATEST'															, ; //X3_CAMPO
	'D'																		, ; //X3_TIPO
	8																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Data Estorno'															, ; //X3_TITULO
	'Data Estorno'															, ; //X3_TITSPA
	'Data Estorno'															, ; //X3_TITENG
	'Data do Estorno          '												, ; //X3_DESCRIC
	'Data do Estorno          '												, ; //X3_DESCSPA
	'Data do Estorno          ' 											, ; //X3_DESCENG
	'@D'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(32)						, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME
	
aAdd( aSX3, { ;
	'ZZ8'																	, ; //X3_ARQUIVO
	'19'																	, ; //X3_ORDEM
	'ZZ8_HRESTO' 															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	5																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Hr Estorno  '															, ; //X3_TITULO
	'Hr Estorno  '															, ; //X3_TITSPA
	'Hr Estorno  '															, ; //X3_TITENG
	'Hora do Estorno          '												, ; //X3_DESCRIC
	'Hora do Estorno          '												, ; //X3_DESCSPA
	'Hora do Estorno          '												, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(32)						, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	'N'																		} ) //X3_PYME


aAdd( aSX3, { ;
	'ZZ8'																	, ; //X3_ARQUIVO
	'20'																	, ; //X3_ORDEM
	'ZZ8_USUAR6'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	15																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Excluiu     '															, ; //X3_TITULO
	'Excluiu     '															, ; //X3_TITSPA
	'Excluiu     '															, ; //X3_TITENG
	'Usuario da Exclusao '													, ; //X3_DESCRIC
	'Usuario da Exclusao '													, ; //X3_DESCSPA
	'Usuario da Exclusao '													, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(32)						, ; //X3_USADO
	''															, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME


aAdd( aSX3, { ;
	'ZZ8'																	, ; //X3_ARQUIVO
	'21'																	, ; //X3_ORDEM
	'ZZ8_DATEXC'															, ; //X3_CAMPO
	'D'																		, ; //X3_TIPO
	8																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Dt Exclusao '															, ; //X3_TITULO
	'Dt Exclusao '															, ; //X3_TITSPA
	'Dt Exclusao '															, ; //X3_TITENG
	'Data da Exclusao         '												, ; //X3_DESCRIC
	'Data da Exclusao         '												, ; //X3_DESCSPA
	'Data da Exclusao         ' 											, ; //X3_DESCENG
	'@D'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(32)						, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME
	

aAdd( aSX3, { ;
	'ZZ8'																	, ; //X3_ARQUIVO
	'22'																	, ; //X3_ORDEM
	'ZZ8_HREXCL' 															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	5																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Hr Exclusao '															, ; //X3_TITULO
	'Hr Exclusao '															, ; //X3_TITSPA
	'Hr Exclusao '															, ; //X3_TITENG
	'Hora da Exclusao         '												, ; //X3_DESCRIC
	'Hora da Exclusao         '												, ; //X3_DESCSPA
	'Hora da Exclusao         '												, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(32)						, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	'N'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'ZZ8'																	, ; //X3_ARQUIVO
	'01'																	, ; //X3_ORDEM
	'ZZ8_XSTCB7' 															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	1																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Status CB7'															, ; //X3_TITULO
	'Status CB7'															, ; //X3_TITSPA
	'Status CB7'															, ; //X3_TITENG
	'Status CB7     	    '												, ; //X3_DESCRIC
	'Status CB7 	        '												, ; //X3_DESCSPA
	'Status CB7	        	'												, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	'N'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'ZZ8'																	, ; //X3_ARQUIVO
	'01'																	, ; //X3_ORDEM
	'ZZ8_XORSEP' 															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	6																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Ordem Sep.'															, ; //X3_TITULO
	'Ordem Sep.'															, ; //X3_TITSPA
	'Ordem Sep.'															, ; //X3_TITENG
	'Ordem Sep.     	    '												, ; //X3_DESCRIC
	'Ordem Sep. 	        '												, ; //X3_DESCSPA
	'Ordem Sep.	        	'												, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	'N'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'ZZ8'																	, ; //X3_ARQUIVO
	'01'																	, ; //X3_ORDEM
	'ZZ8_XEXPED'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	120																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Expedicao '															, ; //X3_TITULO
	'Expedicao '															, ; //X3_TITSPA
	'Expedicao '															, ; //X3_TITENG
	'Expedicao MP'															, ; //X3_DESCRIC
	'Expedicao MP'															, ; //X3_DESCSPA
	'Expedicao MP'															, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME
		
aAdd( aSX3, { ;
	'CB7'																	, ; //X3_ARQUIVO
	'01'																	, ; //X3_ORDEM
	'CB7_XREQMT' 															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	6																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Req. Mat. '															, ; //X3_TITULO
	'Req. Mat. '															, ; //X3_TITSPA
	'Req. Mat. '															, ; //X3_TITENG
	'Req. Mat.      	    '												, ; //X3_DESCRIC
	'Req. Mat.  	        '												, ; //X3_DESCSPA
	'Req. Mat. 	        	'												, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	'N'																		} ) //X3_PYME
	
SX3->(DbSetOrder(2))
If SX3->(dbSeek("C2_TPOP"))
	aAdd( aSX3, { ;
	'SC2'																	, ; //X3_ARQUIVO
	SX3->X3_ORDEM															, ; //X3_ORDEM
	'C2_TPOP'																, ; //X3_CAMPO
	SX3->X3_TIPO															, ; //X3_TIPO
	SX3->X3_TAMANHO															, ; //X3_TAMANHO
	SX3->X3_DECIMAL															, ; //X3_DECIMAL
	SX3->X3_TITULO															, ; //X3_TITULO
	SX3->X3_TITSPA															, ; //X3_TITSPA
	SX3->X3_TITENG															, ; //X3_TITENG
	SX3->X3_DESCRIC															, ; //X3_DESCRIC
	SX3->X3_DESCSPA															, ; //X3_DESCSPA
	SX3->X3_DESCENG															, ; //X3_DESCENG
	SX3->X3_PICTURE															, ; //X3_PICTURE
	SX3->X3_VALID															, ; //X3_VALID
	SX3->X3_USADO															, ; //X3_USADO
	'"P"'			 														, ; //X3_RELACAO
	SX3->X3_F3																, ; //X3_F3
	SX3->X3_NIVEL															, ; //X3_NIVEL
	SX3->X3_RESERV															, ; //X3_RESERV
	SX3->X3_CHECK															, ; //X3_CHECK
	SX3->X3_TRIGGER															, ; //X3_TRIGGER
	SX3->X3_PROPRI															, ; //X3_PROPRI
	SX3->X3_BROWSE															, ; //X3_BROWSE
	SX3->X3_VISUAL															, ; //X3_VISUAL
	SX3->X3_CONTEXT															, ; //X3_CONTEXT
	SX3->X3_OBRIGAT    														, ; //X3_OBRIGAT
	SX3->X3_VLDUSER                                                         , ; //X3_VLDUSER
	SX3->X3_CBOX															, ; //X3_CBOX
	SX3->X3_CBOXSPA															, ; //X3_CBOXSPA
	SX3->X3_CBOXENG															, ; //X3_CBOXENG
	SX3->X3_PICTVAR															, ; //X3_PICTVAR
	'.F.'																	, ; //X3_WHEN
	SX3->X3_INIBRW															, ; //X3_INIBRW
	SX3->X3_GRPSXG															, ; //X3_GRPSXG
	SX3->X3_FOLDER  														, ; //X3_FOLDER
	SX3->X3_PYME															} ) //X3_PYME
EndIf
     

SX3->(DbSetOrder(2))
If SX3->(dbSeek("C2_LOCAL"))
	aAdd( aSX3, { ;
	'SC2'																	, ; //X3_ARQUIVO
	SX3->X3_ORDEM															, ; //X3_ORDEM
	'C2_LOCAL'																, ; //X3_CAMPO
	SX3->X3_TIPO															, ; //X3_TIPO
	SX3->X3_TAMANHO															, ; //X3_TAMANHO
	SX3->X3_DECIMAL															, ; //X3_DECIMAL
	SX3->X3_TITULO															, ; //X3_TITULO
	SX3->X3_TITSPA															, ; //X3_TITSPA
	SX3->X3_TITENG															, ; //X3_TITENG
	SX3->X3_DESCRIC															, ; //X3_DESCRIC
	SX3->X3_DESCSPA															, ; //X3_DESCSPA
	SX3->X3_DESCENG															, ; //X3_DESCENG
	SX3->X3_PICTURE															, ; //X3_PICTURE
	SX3->X3_VALID															, ; //X3_VALID
	SX3->X3_USADO															, ; //X3_USADO
    SX3->X3_RELACAO 														, ; //X3_RELACAO
	SX3->X3_F3																, ; //X3_F3
	SX3->X3_NIVEL															, ; //X3_NIVEL
	SX3->X3_RESERV															, ; //X3_RESERV
	SX3->X3_CHECK															, ; //X3_CHECK
	SX3->X3_TRIGGER															, ; //X3_TRIGGER
	SX3->X3_PROPRI															, ; //X3_PROPRI
	SX3->X3_BROWSE															, ; //X3_BROWSE
	SX3->X3_VISUAL															, ; //X3_VISUAL
	SX3->X3_CONTEXT															, ; //X3_CONTEXT
	SX3->X3_OBRIGAT    														, ; //X3_OBRIGAT
	SX3->X3_VLDUSER                                                         , ; //X3_VLDUSER
	SX3->X3_CBOX															, ; //X3_CBOX
	SX3->X3_CBOXSPA															, ; //X3_CBOXSPA
	SX3->X3_CBOXENG															, ; //X3_CBOXENG
	SX3->X3_PICTVAR															, ; //X3_PICTVAR
	'.F.'																	, ; //X3_WHEN
	SX3->X3_INIBRW															, ; //X3_INIBRW
	SX3->X3_GRPSXG															, ; //X3_GRPSXG
	SX3->X3_FOLDER  														, ; //X3_FOLDER
	SX3->X3_PYME															} ) //X3_PYME
EndIf


//TABELA SD4

SX3->(DbSetOrder(2))
If SX3->(dbSeek("D4_LOTECTL"))
	aAdd( aSX3, { ;
	'SD4'																	, ; //X3_ARQUIVO
	SX3->X3_ORDEM															, ; //X3_ORDEM
	'D4_LOTECTL'															, ; //X3_CAMPO
	SX3->X3_TIPO															, ; //X3_TIPO
	SX3->X3_TAMANHO															, ; //X3_TAMANHO
	SX3->X3_DECIMAL															, ; //X3_DECIMAL
	SX3->X3_TITULO															, ; //X3_TITULO
	SX3->X3_TITSPA															, ; //X3_TITSPA
	SX3->X3_TITENG															, ; //X3_TITENG
	SX3->X3_DESCRIC															, ; //X3_DESCRIC
	SX3->X3_DESCSPA															, ; //X3_DESCSPA
	SX3->X3_DESCENG															, ; //X3_DESCENG
	SX3->X3_PICTURE															, ; //X3_PICTURE
	SX3->X3_VALID															, ; //X3_VALID
	SX3->X3_USADO															, ; //X3_USADO
	SX3->X3_RELACAO	 														, ; //X3_RELACAO
	SX3->X3_F3																, ; //X3_F3
	SX3->X3_NIVEL															, ; //X3_NIVEL
	SX3->X3_RESERV															, ; //X3_RESERV
	SX3->X3_CHECK															, ; //X3_CHECK
	SX3->X3_TRIGGER															, ; //X3_TRIGGER
	SX3->X3_PROPRI															, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	SX3->X3_VISUAL															, ; //X3_VISUAL
	SX3->X3_CONTEXT															, ; //X3_CONTEXT
	SX3->X3_OBRIGAT    														, ; //X3_OBRIGAT
	SX3->X3_VLDUSER                                                         , ; //X3_VLDUSER
	SX3->X3_CBOX															, ; //X3_CBOX
	SX3->X3_CBOXSPA															, ; //X3_CBOXSPA
	SX3->X3_CBOXENG															, ; //X3_CBOXENG
	SX3->X3_PICTVAR															, ; //X3_PICTVAR
	SX3->X3_WHEN															, ; //X3_WHEN
	SX3->X3_INIBRW															, ; //X3_INIBRW
	SX3->X3_GRPSXG															, ; //X3_GRPSXG
	SX3->X3_FOLDER  														, ; //X3_FOLDER
	SX3->X3_PYME															} ) //X3_PYME
EndIf

SX3->(DbSetOrder(2))
If SX3->(dbSeek("D4_DTVALID"))
	aAdd( aSX3, { ;
	'SD4'																	, ; //X3_ARQUIVO
	SX3->X3_ORDEM															, ; //X3_ORDEM
	'D4_DTVALID'															, ; //X3_CAMPO
	SX3->X3_TIPO															, ; //X3_TIPO
	SX3->X3_TAMANHO															, ; //X3_TAMANHO
	SX3->X3_DECIMAL															, ; //X3_DECIMAL
	SX3->X3_TITULO															, ; //X3_TITULO
	SX3->X3_TITSPA															, ; //X3_TITSPA
	SX3->X3_TITENG															, ; //X3_TITENG
	SX3->X3_DESCRIC															, ; //X3_DESCRIC
	SX3->X3_DESCSPA															, ; //X3_DESCSPA
	SX3->X3_DESCENG															, ; //X3_DESCENG
	SX3->X3_PICTURE															, ; //X3_PICTURE
	SX3->X3_VALID															, ; //X3_VALID
	SX3->X3_USADO															, ; //X3_USADO
	SX3->X3_RELACAO	 														, ; //X3_RELACAO
	SX3->X3_F3																, ; //X3_F3
	SX3->X3_NIVEL															, ; //X3_NIVEL
	SX3->X3_RESERV															, ; //X3_RESERV
	SX3->X3_CHECK															, ; //X3_CHECK
	SX3->X3_TRIGGER															, ; //X3_TRIGGER
	SX3->X3_PROPRI															, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	SX3->X3_VISUAL															, ; //X3_VISUAL
	SX3->X3_CONTEXT															, ; //X3_CONTEXT
	SX3->X3_OBRIGAT    														, ; //X3_OBRIGAT
	SX3->X3_VLDUSER                                                         , ; //X3_VLDUSER
	SX3->X3_CBOX															, ; //X3_CBOX
	SX3->X3_CBOXSPA															, ; //X3_CBOXSPA
	SX3->X3_CBOXENG															, ; //X3_CBOXENG
	SX3->X3_PICTVAR															, ; //X3_PICTVAR
	SX3->X3_WHEN															, ; //X3_WHEN
	SX3->X3_INIBRW															, ; //X3_INIBRW
	SX3->X3_GRPSXG															, ; //X3_GRPSXG
	SX3->X3_FOLDER  														, ; //X3_FOLDER
	SX3->X3_PYME															} ) //X3_PYME
EndIf 

//⁄ƒƒƒƒƒƒƒƒƒƒø
//≥Tabela SZV≥
//¿ƒƒƒƒƒƒƒƒƒƒŸ
SX3->(DbSetOrder(2))
If SX3->(dbSeek("ZV_TIMEATE"))
	aAdd( aSX3, { ;
	'SZV'																	, ; //X3_ARQUIVO
	SX3->X3_ORDEM															, ; //X3_ORDEM
	'ZV_TIMEATE'															, ; //X3_CAMPO
	SX3->X3_TIPO															, ; //X3_TIPO
	9																		, ; //X3_TAMANHO
	SX3->X3_DECIMAL															, ; //X3_DECIMAL
	SX3->X3_TITULO															, ; //X3_TITULO
	SX3->X3_TITSPA															, ; //X3_TITSPA
	SX3->X3_TITENG															, ; //X3_TITENG
	SX3->X3_DESCRIC															, ; //X3_DESCRIC
	SX3->X3_DESCSPA															, ; //X3_DESCSPA
	SX3->X3_DESCENG															, ; //X3_DESCENG
	SX3->X3_PICTURE															, ; //X3_PICTURE
	SX3->X3_VALID															, ; //X3_VALID
	SX3->X3_USADO															, ; //X3_USADO
	SX3->X3_RELACAO	 														, ; //X3_RELACAO
	SX3->X3_F3																, ; //X3_F3
	SX3->X3_NIVEL															, ; //X3_NIVEL
	SX3->X3_RESERV															, ; //X3_RESERV
	SX3->X3_CHECK															, ; //X3_CHECK
	SX3->X3_TRIGGER															, ; //X3_TRIGGER
	SX3->X3_PROPRI															, ; //X3_PROPRI
	SX3->X3_BROWSE															, ; //X3_BROWSE
	SX3->X3_VISUAL															, ; //X3_VISUAL
	SX3->X3_CONTEXT															, ; //X3_CONTEXT
	SX3->X3_OBRIGAT    														, ; //X3_OBRIGAT
	SX3->X3_VLDUSER                                                         , ; //X3_VLDUSER
	SX3->X3_CBOX															, ; //X3_CBOX
	SX3->X3_CBOXSPA															, ; //X3_CBOXSPA
	SX3->X3_CBOXENG															, ; //X3_CBOXENG
	SX3->X3_PICTVAR															, ; //X3_PICTVAR
	SX3->X3_WHEN															, ; //X3_WHEN
	SX3->X3_INIBRW															, ; //X3_INIBRW
	SX3->X3_GRPSXG															, ; //X3_GRPSXG
	SX3->X3_FOLDER  														, ; //X3_FOLDER
	SX3->X3_PYME															} ) //X3_PYME
EndIf


SX3->(DbSetOrder(2))
If SX3->(dbSeek("D1_TES"))
	aAdd( aSX3, { ;
	'SD1'																	, ; //X3_ARQUIVO
	SX3->X3_ORDEM															, ; //X3_ORDEM
	'D1_TES'    															, ; //X3_CAMPO
	SX3->X3_TIPO															, ; //X3_TIPO
	SX3->X3_TAMANHO															, ; //X3_TAMANHO
	SX3->X3_DECIMAL															, ; //X3_DECIMAL
	SX3->X3_TITULO															, ; //X3_TITULO
	SX3->X3_TITSPA															, ; //X3_TITSPA
	SX3->X3_TITENG															, ; //X3_TITENG
	SX3->X3_DESCRIC															, ; //X3_DESCRIC
	SX3->X3_DESCSPA															, ; //X3_DESCSPA
	SX3->X3_DESCENG															, ; //X3_DESCENG
	SX3->X3_PICTURE															, ; //X3_PICTURE
	SX3->X3_VALID															, ; //X3_VALID
	SX3->X3_USADO															, ; //X3_USADO
	SX3->X3_RELACAO	 														, ; //X3_RELACAO
	'DIPSF4'																, ; //X3_F3
	SX3->X3_NIVEL															, ; //X3_NIVEL
	SX3->X3_RESERV															, ; //X3_RESERV
	SX3->X3_CHECK															, ; //X3_CHECK
	SX3->X3_TRIGGER															, ; //X3_TRIGGER
	SX3->X3_PROPRI															, ; //X3_PROPRI
	SX3->X3_BROWSE															, ; //X3_BROWSE
	SX3->X3_VISUAL															, ; //X3_VISUAL
	SX3->X3_CONTEXT															, ; //X3_CONTEXT
	SX3->X3_OBRIGAT    														, ; //X3_OBRIGAT
	SX3->X3_VLDUSER                                                         , ; //X3_VLDUSER
	SX3->X3_CBOX															, ; //X3_CBOX
	SX3->X3_CBOXSPA															, ; //X3_CBOXSPA
	SX3->X3_CBOXENG															, ; //X3_CBOXENG
	SX3->X3_PICTVAR															, ; //X3_PICTVAR
	SX3->X3_WHEN															, ; //X3_WHEN
	SX3->X3_INIBRW															, ; //X3_INIBRW
	SX3->X3_GRPSXG															, ; //X3_GRPSXG
	SX3->X3_FOLDER  														, ; //X3_FOLDER
	SX3->X3_PYME															} ) //X3_PYME
EndIf



SX3->(DbSetOrder(2))
If SX3->(dbSeek("D7_DATA"))
	aAdd( aSX3, { ;
	'SD7'																	, ; //X3_ARQUIVO
	SX3->X3_ORDEM															, ; //X3_ORDEM
	'D7_DATA'    															, ; //X3_CAMPO
	SX3->X3_TIPO															, ; //X3_TIPO
	SX3->X3_TAMANHO															, ; //X3_TAMANHO
	SX3->X3_DECIMAL															, ; //X3_DECIMAL
	SX3->X3_TITULO															, ; //X3_TITULO
	SX3->X3_TITSPA															, ; //X3_TITSPA
	SX3->X3_TITENG															, ; //X3_TITENG
	SX3->X3_DESCRIC															, ; //X3_DESCRIC
	SX3->X3_DESCSPA															, ; //X3_DESCSPA
	SX3->X3_DESCENG															, ; //X3_DESCENG
	SX3->X3_PICTURE															, ; //X3_PICTURE
	SX3->X3_VALID															, ; //X3_VALID
	SX3->X3_USADO															, ; //X3_USADO
	'dDataBase'		 														, ; //X3_RELACAO
	SX3->X3_F3																, ; //X3_F3
	SX3->X3_NIVEL															, ; //X3_NIVEL
	SX3->X3_RESERV															, ; //X3_RESERV
	SX3->X3_CHECK															, ; //X3_CHECK
	SX3->X3_TRIGGER															, ; //X3_TRIGGER
	SX3->X3_PROPRI															, ; //X3_PROPRI
	SX3->X3_BROWSE															, ; //X3_BROWSE
	SX3->X3_VISUAL															, ; //X3_VISUAL
	SX3->X3_CONTEXT															, ; //X3_CONTEXT
	SX3->X3_OBRIGAT    														, ; //X3_OBRIGAT
	SX3->X3_VLDUSER                                                         , ; //X3_VLDUSER
	SX3->X3_CBOX															, ; //X3_CBOX
	SX3->X3_CBOXSPA															, ; //X3_CBOXSPA
	SX3->X3_CBOXENG															, ; //X3_CBOXENG
	SX3->X3_PICTVAR															, ; //X3_PICTVAR
	SX3->X3_WHEN															, ; //X3_WHEN
	SX3->X3_INIBRW															, ; //X3_INIBRW
	SX3->X3_GRPSXG															, ; //X3_GRPSXG
	SX3->X3_FOLDER  														, ; //X3_FOLDER
	SX3->X3_PYME															} ) //X3_PYME
EndIf


SX3->(DbSetOrder(2))
If SX3->(dbSeek("C5_CONDPAG"))
	aAdd( aSX3, { ;
	'SC5'																	, ; //X3_ARQUIVO
	SX3->X3_ORDEM															, ; //X3_ORDEM
	'C5_CONDPAG'   															, ; //X3_CAMPO
	SX3->X3_TIPO															, ; //X3_TIPO
	SX3->X3_TAMANHO															, ; //X3_TAMANHO
	SX3->X3_DECIMAL															, ; //X3_DECIMAL
	SX3->X3_TITULO															, ; //X3_TITULO
	SX3->X3_TITSPA															, ; //X3_TITSPA
	SX3->X3_TITENG															, ; //X3_TITENG
	SX3->X3_DESCRIC															, ; //X3_DESCRIC
	SX3->X3_DESCSPA															, ; //X3_DESCSPA
	SX3->X3_DESCENG															, ; //X3_DESCENG
	SX3->X3_PICTURE															, ; //X3_PICTURE
	SX3->X3_VALID															, ; //X3_VALID
	SX3->X3_USADO															, ; //X3_USADO
	SX3->X3_RELACAO	 														, ; //X3_RELACAO
	'4SE'																	, ; //X3_F3
	SX3->X3_NIVEL															, ; //X3_NIVEL
	SX3->X3_RESERV															, ; //X3_RESERV
	SX3->X3_CHECK															, ; //X3_CHECK
	SX3->X3_TRIGGER															, ; //X3_TRIGGER
	SX3->X3_PROPRI															, ; //X3_PROPRI
	SX3->X3_BROWSE															, ; //X3_BROWSE
	SX3->X3_VISUAL															, ; //X3_VISUAL
	SX3->X3_CONTEXT															, ; //X3_CONTEXT
	SX3->X3_OBRIGAT    														, ; //X3_OBRIGAT
	SX3->X3_VLDUSER                                                         , ; //X3_VLDUSER
	SX3->X3_CBOX															, ; //X3_CBOX
	SX3->X3_CBOXSPA															, ; //X3_CBOXSPA
	SX3->X3_CBOXENG															, ; //X3_CBOXENG
	SX3->X3_PICTVAR															, ; //X3_PICTVAR
	SX3->X3_WHEN															, ; //X3_WHEN
	SX3->X3_INIBRW															, ; //X3_INIBRW
	SX3->X3_GRPSXG															, ; //X3_GRPSXG
	SX3->X3_FOLDER  														, ; //X3_FOLDER
	SX3->X3_PYME															} ) //X3_PYME
EndIf

SX3->(DbSetOrder(2))
If SX3->(dbSeek("C7_COND"))
	aAdd( aSX3, { ;
	'SC7'																	, ; //X3_ARQUIVO
	SX3->X3_ORDEM															, ; //X3_ORDEM
	'C7_COND'   															, ; //X3_CAMPO
	SX3->X3_TIPO															, ; //X3_TIPO
	SX3->X3_TAMANHO															, ; //X3_TAMANHO
	SX3->X3_DECIMAL															, ; //X3_DECIMAL
	SX3->X3_TITULO															, ; //X3_TITULO
	SX3->X3_TITSPA															, ; //X3_TITSPA
	SX3->X3_TITENG															, ; //X3_TITENG
	SX3->X3_DESCRIC															, ; //X3_DESCRIC
	SX3->X3_DESCSPA															, ; //X3_DESCSPA
	SX3->X3_DESCENG															, ; //X3_DESCENG
	SX3->X3_PICTURE															, ; //X3_PICTURE
	SX3->X3_VALID															, ; //X3_VALID
	SX3->X3_USADO															, ; //X3_USADO
	SX3->X3_RELACAO	 														, ; //X3_RELACAO
	'S4E'																	, ; //X3_F3
	SX3->X3_NIVEL															, ; //X3_NIVEL
	SX3->X3_RESERV															, ; //X3_RESERV
	SX3->X3_CHECK															, ; //X3_CHECK
	SX3->X3_TRIGGER															, ; //X3_TRIGGER
	SX3->X3_PROPRI															, ; //X3_PROPRI
	SX3->X3_BROWSE															, ; //X3_BROWSE
	SX3->X3_VISUAL															, ; //X3_VISUAL
	SX3->X3_CONTEXT															, ; //X3_CONTEXT
	SX3->X3_OBRIGAT    														, ; //X3_OBRIGAT
	SX3->X3_VLDUSER                                                         , ; //X3_VLDUSER
	SX3->X3_CBOX															, ; //X3_CBOX
	SX3->X3_CBOXSPA															, ; //X3_CBOXSPA
	SX3->X3_CBOXENG															, ; //X3_CBOXENG
	SX3->X3_PICTVAR															, ; //X3_PICTVAR
	SX3->X3_WHEN															, ; //X3_WHEN
	SX3->X3_INIBRW															, ; //X3_INIBRW
	SX3->X3_GRPSXG															, ; //X3_GRPSXG
	SX3->X3_FOLDER  														, ; //X3_FOLDER
	SX3->X3_PYME															} ) //X3_PYME
EndIf


SX3->(DbSetOrder(2))
If SX3->(dbSeek("BC_LOCDEST"))
	aAdd( aSX3, { ;
	'SBC'																	, ; //X3_ARQUIVO
	SX3->X3_ORDEM															, ; //X3_ORDEM
	'BC_LOCDEST'   															, ; //X3_CAMPO
	SX3->X3_TIPO															, ; //X3_TIPO
	SX3->X3_TAMANHO															, ; //X3_TAMANHO
	SX3->X3_DECIMAL															, ; //X3_DECIMAL
	SX3->X3_TITULO															, ; //X3_TITULO
	SX3->X3_TITSPA															, ; //X3_TITSPA
	SX3->X3_TITENG															, ; //X3_TITENG
	SX3->X3_DESCRIC															, ; //X3_DESCRIC
	SX3->X3_DESCSPA															, ; //X3_DESCSPA
	SX3->X3_DESCENG															, ; //X3_DESCENG
	SX3->X3_PICTURE															, ; //X3_PICTURE
	SX3->X3_VALID															, ; //X3_VALID
	SX3->X3_USADO															, ; //X3_USADO
	"'PERDA'"																, ; //X3_RELACAO
	SX3->X3_F3																, ; //X3_F3
	SX3->X3_NIVEL															, ; //X3_NIVEL
	SX3->X3_RESERV															, ; //X3_RESERV
	SX3->X3_CHECK															, ; //X3_CHECK
	SX3->X3_TRIGGER															, ; //X3_TRIGGER
	SX3->X3_PROPRI															, ; //X3_PROPRI
	SX3->X3_BROWSE															, ; //X3_BROWSE
	SX3->X3_VISUAL															, ; //X3_VISUAL
	SX3->X3_CONTEXT															, ; //X3_CONTEXT
	SX3->X3_OBRIGAT    														, ; //X3_OBRIGAT
	SX3->X3_VLDUSER                                                         , ; //X3_VLDUSER
	SX3->X3_CBOX															, ; //X3_CBOX
	SX3->X3_CBOXSPA															, ; //X3_CBOXSPA
	SX3->X3_CBOXENG															, ; //X3_CBOXENG
	SX3->X3_PICTVAR															, ; //X3_PICTVAR
	SX3->X3_WHEN															, ; //X3_WHEN
	SX3->X3_INIBRW															, ; //X3_INIBRW
	SX3->X3_GRPSXG															, ; //X3_GRPSXG
	SX3->X3_FOLDER  														, ; //X3_FOLDER
	SX3->X3_PYME															} ) //X3_PYME
EndIf


SX3->(DbSetOrder(2))
If SX3->(dbSeek("B1_RASTRO"))
	aAdd( aSX3, { ;
	'SB1'																	, ; //X3_ARQUIVO
	SX3->X3_ORDEM															, ; //X3_ORDEM
	'B1_RASTRO'   															, ; //X3_CAMPO
	SX3->X3_TIPO															, ; //X3_TIPO
	SX3->X3_TAMANHO															, ; //X3_TAMANHO
	SX3->X3_DECIMAL															, ; //X3_DECIMAL
	SX3->X3_TITULO															, ; //X3_TITULO
	SX3->X3_TITSPA															, ; //X3_TITSPA
	SX3->X3_TITENG															, ; //X3_TITENG
	SX3->X3_DESCRIC															, ; //X3_DESCRIC
	SX3->X3_DESCSPA															, ; //X3_DESCSPA
	SX3->X3_DESCENG															, ; //X3_DESCENG
	SX3->X3_PICTURE															, ; //X3_PICTURE
	SX3->X3_VALID															, ; //X3_VALID
	SX3->X3_USADO															, ; //X3_USADO
	"'L'"																, ; //X3_RELACAO
	SX3->X3_F3																, ; //X3_F3
	SX3->X3_NIVEL															, ; //X3_NIVEL
	SX3->X3_RESERV															, ; //X3_RESERV
	SX3->X3_CHECK															, ; //X3_CHECK
	SX3->X3_TRIGGER															, ; //X3_TRIGGER
	SX3->X3_PROPRI															, ; //X3_PROPRI
	SX3->X3_BROWSE															, ; //X3_BROWSE
	SX3->X3_VISUAL															, ; //X3_VISUAL
	SX3->X3_CONTEXT															, ; //X3_CONTEXT
	SX3->X3_OBRIGAT    														, ; //X3_OBRIGAT
	SX3->X3_VLDUSER                                                         , ; //X3_VLDUSER
	SX3->X3_CBOX															, ; //X3_CBOX
	SX3->X3_CBOXSPA															, ; //X3_CBOXSPA
	SX3->X3_CBOXENG															, ; //X3_CBOXENG
	SX3->X3_PICTVAR															, ; //X3_PICTVAR
	SX3->X3_WHEN															, ; //X3_WHEN
	SX3->X3_INIBRW															, ; //X3_INIBRW
	SX3->X3_GRPSXG															, ; //X3_GRPSXG
	SX3->X3_FOLDER  														, ; //X3_FOLDER
	SX3->X3_PYME															} ) //X3_PYME
EndIf


SX3->(DbSetOrder(2))
If SX3->(dbSeek("E2_NATUREZ"))
	aAdd( aSX3, { ;
	'SE2'																	, ; //X3_ARQUIVO
	SX3->X3_ORDEM															, ; //X3_ORDEM
	'E2_NATUREZ'   															, ; //X3_CAMPO
	SX3->X3_TIPO															, ; //X3_TIPO
	SX3->X3_TAMANHO															, ; //X3_TAMANHO
	SX3->X3_DECIMAL															, ; //X3_DECIMAL
	SX3->X3_TITULO															, ; //X3_TITULO
	SX3->X3_TITSPA															, ; //X3_TITSPA
	SX3->X3_TITENG															, ; //X3_TITENG
	SX3->X3_DESCRIC															, ; //X3_DESCRIC
	SX3->X3_DESCSPA															, ; //X3_DESCSPA
	SX3->X3_DESCENG															, ; //X3_DESCENG
	SX3->X3_PICTURE															, ; //X3_PICTURE
	SX3->X3_VALID															, ; //X3_VALID
	SX3->X3_USADO															, ; //X3_USADO
	SX3->X3_RELACAO															, ; //X3_RELACAO
	SX3->X3_F3																, ; //X3_F3
	SX3->X3_NIVEL															, ; //X3_NIVEL
	SX3->X3_RESERV															, ; //X3_RESERV
	SX3->X3_CHECK															, ; //X3_CHECK
	SX3->X3_TRIGGER															, ; //X3_TRIGGER
	SX3->X3_PROPRI															, ; //X3_PROPRI
	SX3->X3_BROWSE															, ; //X3_BROWSE
	SX3->X3_VISUAL															, ; //X3_VISUAL
	SX3->X3_CONTEXT															, ; //X3_CONTEXT
	SX3->X3_OBRIGAT    														, ; //X3_OBRIGAT
	SX3->X3_VLDUSER                                                         , ; //X3_VLDUSER
	SX3->X3_CBOX															, ; //X3_CBOX
	SX3->X3_CBOXSPA															, ; //X3_CBOXSPA
	SX3->X3_CBOXENG															, ; //X3_CBOXENG
	SX3->X3_PICTVAR															, ; //X3_PICTVAR
	"IIF(INCLUI,.T.,.F.)"													, ; //X3_WHEN
	SX3->X3_INIBRW															, ; //X3_INIBRW
	SX3->X3_GRPSXG															, ; //X3_GRPSXG
	SX3->X3_FOLDER  														, ; //X3_FOLDER
	SX3->X3_PYME															} ) //X3_PYME
EndIf

//⁄ƒƒƒƒƒƒƒƒƒƒø
//≥Tabela CC3≥
//¿ƒƒƒƒƒƒƒƒƒƒŸ
SX3->(DbSetOrder(1))
SX3->(MsSeek("CC3"+"ZZ",.T.))
SX3->(DbSkip(-1))

cOrdem := Soma1(SX3->X3_ORDEM)   

aAdd( aSX3, { ;
	'CC3'																	, ; //X3_ARQUIVO
	cOrdem																	, ; //X3_ORDEM
	'CC3_XCEVS'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	1																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'CEVS        '															, ; //X3_TITULO
	'CEVS        '															, ; //X3_TITSPA
	'CEVS        '															, ; //X3_TITENG
	'Cadastro Est de Vig Sanit'												, ; //X3_DESCRIC
	'Cadastro Est de Vig Sanit'												, ; //X3_DESCSPA
	'Cadastro Est de Vig Sanit'												, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128)								, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	'S'																		} ) //X3_PYME	
                                                                                            

//⁄ƒƒƒƒƒƒƒƒƒƒø
//≥Tabela SZV≥
//¿ƒƒƒƒƒƒƒƒƒƒŸ
SX3->(DbSetOrder(1))
SX3->(MsSeek("SZV"+"ZZ",.T.))
SX3->(DbSkip(-1))

cOrdem := Soma1(SX3->X3_ORDEM)   

aAdd( aSX3, { ;
	'SZV'																	, ; //X3_ARQUIVO
	cOrdem																	, ; //X3_ORDEM
	'ZV_XTRT'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	1																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'TRT 1=S/2=N '															, ; //X3_TITULO
	'TRT 1=S/2=N '															, ; //X3_TITSPA
	'TRT 1=S/2=N '															, ; //X3_TITENG
	'TRT na Regiao 1=S / 2=N  '												, ; //X3_DESCRIC
	'TRT na Regiao 1=S / 2=N  '												, ; //X3_DESCSPA
	'TRT na Regiao 1=S / 2=N  '												, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128)								, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	'S'																		} ) //X3_PYME	

cOrdem := Soma1(cOrdem)   

aAdd( aSX3, { ;
	'SZV'																	, ; //X3_ARQUIVO
	cOrdem																	, ; //X3_ORDEM
	'ZV_XEMEX'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	1																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'EMEX 1=S/2=N'															, ; //X3_TITULO
	'EMEX 1=S/2=N'															, ; //X3_TITSPA
	'EMEX 1=S/2=N'															, ; //X3_TITENG
	'EMEX na Regiao 1=S / 2=N '												, ; //X3_DESCRIC
	'EMEX na Regiao 1=S / 2=N '												, ; //X3_DESCSPA
	'EMEX na Regiao 1=S / 2=N '												, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128)								, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	'S'																		} ) //X3_PYME	                                                                                            
                                                                                            


//⁄ƒƒƒƒƒƒƒƒƒƒø
//≥Tabela SCB≥
//¿ƒƒƒƒƒƒƒƒƒƒŸ
SX3->(DbSetOrder(1))
SX3->(MsSeek("SBC"+"ZZ",.T.))
SX3->(DbSkip(-1))

cOrdem := Soma1(SX3->X3_ORDEM)   

aAdd( aSX3, { ;
	'SBC'																	, ; //X3_ARQUIVO
	cOrdem																	, ; //X3_ORDEM
	'BC_CODLAN'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	6																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Cod.Cat83   '															, ; //X3_TITULO
	'Cod.Cat83   '															, ; //X3_TITSPA
	'Cod.Cat83   '															, ; //X3_TITENG
	'Cod.Cat83    			  '												, ; //X3_DESCRIC
	'Cod.Cat83    			  '												, ; //X3_DESCSPA
	'Cod.Cat83    			  '												, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	'Vazio() .Or. ExistCpo("CDZ")'									    	, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128)								, ; //X3_USADO
	''																		, ; //X3_RELACAO
	'CDZ'																		, ; //X3_F3
	1																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'S'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	'S'																		} ) //X3_PYME	

//
// Tabela ZZV
//
aAdd( aSX3, { ;
	'ZZV'																	, ; //X3_ARQUIVO
	'01'																	, ; //X3_ORDEM
	'ZZV_FILIAL'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	2																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'FILIAL'																, ; //X3_TITULO
	'FILIAL'																, ; //X3_TITSPA
	'FILIAL'																, ; //X3_TITENG
	'FILIAL'																, ; //X3_DESCRIC
	'FILIAL'																, ; //X3_DESCSPA
	'FILIAL'																, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'ZZV'																	, ; //X3_ARQUIVO
	'02'																	, ; //X3_ORDEM
	'ZZV_TRANSP'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	6																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Cod. Transp.'															, ; //X3_TITULO
	'Cod. Transp.'															, ; //X3_TITSPA
	'Cod. Transp.'															, ; //X3_TITENG
	'Codigo da transportadora'												, ; //X3_DESCRIC
	'Codigo da transportadora'												, ; //X3_DESCSPA
	'Codigo da transportadora'												, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'ZZV'																	, ; //X3_ARQUIVO
	'03'																	, ; //X3_ORDEM
	'ZZV_CEPINI'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	8																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'CEP INICIAL'															, ; //X3_TITULO
	'CEP INICIAL'															, ; //X3_TITSPA
	'CEP INICIAL'															, ; //X3_TITENG
	'CEP INICIAL'															, ; //X3_DESCRIC
	'CEP INICIAL'															, ; //X3_DESCSPA
	'CEP INICIAL'															, ; //X3_DESCENG
	'@R 99999999'															, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'ZZV'																	, ; //X3_ARQUIVO
	'04'																	, ; //X3_ORDEM
	'ZZV_CEPFIM'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	8																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'CEP FINAL'																, ; //X3_TITULO
	'CEP FINAL'																, ; //X3_TITSPA
	'CEP FINAL'																, ; //X3_TITENG
	'CEP FINAL'																, ; //X3_DESCRIC
	'CEP FINAL'																, ; //X3_DESCSPA
	'CEP FINAL'																, ; //X3_DESCENG
	'@R 99999999'															, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME
//
// Tabela ZZW
//
aAdd( aSX3, { ;
	'ZZW'																	, ; //X3_ARQUIVO
	'01'																	, ; //X3_ORDEM
	'ZZW_FILIAL'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	2																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Filial'																, ; //X3_TITULO
	'Sucursal'																, ; //X3_TITSPA
	'Branch'																, ; //X3_TITENG
	'Filial do Sistema'														, ; //X3_DESCRIC
	'Sucursal'																, ; //X3_DESCSPA
	'Branch of the System'													, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	1																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'ZZW'																	, ; //X3_ARQUIVO
	'02'																	, ; //X3_ORDEM
	'ZZW_PEDIDO'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	6																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Pedido'																, ; //X3_TITULO
	'Pedido'																, ; //X3_TITSPA
	'Pedido'																, ; //X3_TITENG
	'Pedido'																, ; //X3_DESCRIC
	'Pedido'																, ; //X3_DESCSPA
	'Pedido'																, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'ZZW'																	, ; //X3_ARQUIVO
	'03'																	, ; //X3_ORDEM
	'ZZW_TIPMOV'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	30																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Tp Movimento'															, ; //X3_TITULO
	'Tp Movimento'															, ; //X3_TITSPA
	'Tp Movimento'															, ; //X3_TITENG
	'Tp Movimento'															, ; //X3_DESCRIC
	'Tp Movimento'															, ; //X3_DESCSPA
	'Tp Movimento'															, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'ZZW'																	, ; //X3_ARQUIVO
	'04'																	, ; //X3_ORDEM
	'ZZW_DATAMO'															, ; //X3_CAMPO
	'D'																		, ; //X3_TIPO
	8																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Data Movimen'															, ; //X3_TITULO
	'Data Movimen'															, ; //X3_TITSPA
	'Data Movimen'															, ; //X3_TITENG
	'Data Movimen'															, ; //X3_DESCRIC
	'Data Movimen'															, ; //X3_DESCSPA
	'Data Movimen'															, ; //X3_DESCENG
	''																		, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'ZZW'																	, ; //X3_ARQUIVO
	'05'																	, ; //X3_ORDEM
	'ZZW_HORAMO'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	8																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Hora Movimen'															, ; //X3_TITULO
	'Hora Movimen'															, ; //X3_TITSPA
	'Hora Movimen'															, ; //X3_TITENG
	'Hora Movimen'															, ; //X3_DESCRIC
	'Hora Movimen'															, ; //X3_DESCSPA
	'Hora Movimen'															, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'ZZW'																	, ; //X3_ARQUIVO
	'06'																	, ; //X3_ORDEM
	'ZZW_USUARI'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	15																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Usuario'																, ; //X3_TITULO
	'Usuario'																, ; //X3_TITSPA
	'Usuario'																, ; //X3_TITENG
	'Usuario'																, ; //X3_DESCRIC
	'Usuario'																, ; //X3_DESCSPA
	'Usuario'																, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'ZZW'																	, ; //X3_ARQUIVO
	'07'																	, ; //X3_ORDEM
	'ZZW_OCORRE'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	2																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Tipo de Ocor'															, ; //X3_TITULO
	'Tipo de Ocor'															, ; //X3_TITSPA
	'Tipo de OcoS'															, ; //X3_TITENG
	'Tipo de Ocorrencia'													, ; //X3_DESCRIC
	'Tipo de Ocorrencia'													, ; //X3_DESCSPA
	'Tipo de Ocorrencia'													, ; //X3_DESCENG
	''																		, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'ZZW'																	, ; //X3_ARQUIVO
	'08'																	, ; //X3_ORDEM
	'ZZW_DESOCO'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	50																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Ocorrencia'															, ; //X3_TITULO
	'Ocorrencia'															, ; //X3_TITSPA
	'Ocorrencia'															, ; //X3_TITENG
	'Ocorrencia'															, ; //X3_DESCRIC
	'Ocorrencia'															, ; //X3_DESCSPA
	'Ocorrencia'															, ; //X3_DESCENG
	''																		, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME


aAdd( aSX3, { ;
	'ZZV'																	, ; //X3_ARQUIVO
	'05'																	, ; //X3_ORDEM
	'ZZV_CGCCLI'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'CNPJ/CPF'																, ; //X3_TITULO
	'CNPJ/CPF'																, ; //X3_TITSPA
	'CNPJ/CPF'																, ; //X3_TITENG
	'CNPJ/CPF'																, ; //X3_DESCRIC
	'CNPJ/CPF'																, ; //X3_DESCSPA
	'CNPJ/CPF'																, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME
                                                                                            
aAdd( aSX3, { ;
	'SA1'																	, ; //X3_ARQUIVO
	'01'																	, ; //X3_ORDEM
	'A1_XMINCIF'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	12																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Vl.Min.CIF'															, ; //X3_TITULO
	'Vl.Min.CIF'															, ; //X3_TITSPA
	'Vl.Min.CIF'															, ; //X3_TITENG
	'Vl.Min.CIF'															, ; //X3_DESCRIC
	'Vl.Min.CIF'															, ; //X3_DESCSPA
	'Vl.Min.CIF'															, ; //X3_DESCENG
	'@E 9,999,999.99'														, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(32)						, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	'N'																		} ) //X3_PYME

If cEmpAnt=="04"
	SX3->(DbSetOrder(2))
	If SX3->(dbSeek("B1_XQTDEMB"))	
	   	aAdd( aSX3, { ;
			'SB1'																	, ; //X3_ARQUIVO
			SX3->X3_ORDEM															, ; //X3_ORDEM
			'B1_XQTDEMB'    														, ; //X3_CAMPO
			SX3->X3_TIPO															, ; //X3_TIPO
			10																		, ; //X3_TAMANHO
			2																		, ; //X3_DECIMAL
			SX3->X3_TITULO															, ; //X3_TITULO
			SX3->X3_TITSPA															, ; //X3_TITSPA
			SX3->X3_TITENG															, ; //X3_TITENG
			SX3->X3_DESCRIC															, ; //X3_DESCRIC
			SX3->X3_DESCSPA															, ; //X3_DESCSPA
			SX3->X3_DESCENG															, ; //X3_DESCENG
			"@E 999,999.99"															, ; //X3_PICTURE
			SX3->X3_VALID															, ; //X3_VALID
			SX3->X3_USADO															, ; //X3_USADO
			SX3->X3_RELACAO 														, ; //X3_RELACAO
			SX3->X3_F3																, ; //X3_F3
			SX3->X3_NIVEL															, ; //X3_NIVEL
			SX3->X3_RESERV															, ; //X3_RESERV
			SX3->X3_CHECK															, ; //X3_CHECK
			SX3->X3_TRIGGER															, ; //X3_TRIGGER
			SX3->X3_PROPRI															, ; //X3_PROPRI
			SX3->X3_BROWSE															, ; //X3_BROWSE
			SX3->X3_VISUAL															, ; //X3_VISUAL
			SX3->X3_CONTEXT															, ; //X3_CONTEXT
			SX3->X3_OBRIGAT															, ; //X3_OBRIGAT
			SX3->X3_VLDUSER															, ; //X3_VLDUSER
			SX3->X3_CBOX															, ; //X3_CBOX
			SX3->X3_CBOXSPA															, ; //X3_CBOXSPA
			SX3->X3_CBOXENG															, ; //X3_CBOXENG
			SX3->X3_PICTVAR															, ; //X3_PICTVAR
	        SX3->X3_WHEN															, ; //X3_WHEN
			SX3->X3_INIBRW															, ; //X3_INIBRW
			SX3->X3_GRPSXG															, ; //X3_GRPSXG
			SX3->X3_FOLDER  														, ; //X3_FOLDER
			SX3->X3_PYME															} ) //X3_PYME	
	EndIf
	
	SX3->(DbSetOrder(2))
	If SX3->(dbSeek("B1_XQTDSEC"))
	   	aAdd( aSX3, { ;
			'SB1'																	, ; //X3_ARQUIVO
			SX3->X3_ORDEM															, ; //X3_ORDEM
			'B1_XQTDSEC'    														, ; //X3_CAMPO
			SX3->X3_TIPO															, ; //X3_TIPO
			10																		, ; //X3_TAMANHO
			2																		, ; //X3_DECIMAL
			SX3->X3_TITULO															, ; //X3_TITULO
			SX3->X3_TITSPA															, ; //X3_TITSPA
			SX3->X3_TITENG															, ; //X3_TITENG
			SX3->X3_DESCRIC															, ; //X3_DESCRIC
			SX3->X3_DESCSPA															, ; //X3_DESCSPA
			SX3->X3_DESCENG															, ; //X3_DESCENG
			"@E 999,999.99"															, ; //X3_PICTURE
			SX3->X3_VALID															, ; //X3_VALID
			SX3->X3_USADO															, ; //X3_USADO
			SX3->X3_RELACAO 														, ; //X3_RELACAO
			SX3->X3_F3																, ; //X3_F3
			SX3->X3_NIVEL															, ; //X3_NIVEL
			SX3->X3_RESERV															, ; //X3_RESERV
			SX3->X3_CHECK															, ; //X3_CHECK
			SX3->X3_TRIGGER															, ; //X3_TRIGGER
			SX3->X3_PROPRI															, ; //X3_PROPRI
			SX3->X3_BROWSE															, ; //X3_BROWSE
			SX3->X3_VISUAL															, ; //X3_VISUAL
			SX3->X3_CONTEXT															, ; //X3_CONTEXT
			SX3->X3_OBRIGAT															, ; //X3_OBRIGAT
			SX3->X3_VLDUSER															, ; //X3_VLDUSER
			SX3->X3_CBOX															, ; //X3_CBOX
			SX3->X3_CBOXSPA															, ; //X3_CBOXSPA
			SX3->X3_CBOXENG															, ; //X3_CBOXENG
			SX3->X3_PICTVAR															, ; //X3_PICTVAR
	        SX3->X3_WHEN															, ; //X3_WHEN
			SX3->X3_INIBRW															, ; //X3_INIBRW
			SX3->X3_GRPSXG															, ; //X3_GRPSXG
			SX3->X3_FOLDER  														, ; //X3_FOLDER
			SX3->X3_PYME															} ) //X3_PYME	
	EndIf
EndIf


//
// Campos Tabela ZZX
//
aAdd( aSX3, { ;
	'ZZX'																	, ; //X3_ARQUIVO
	'01'																	, ; //X3_ORDEM
	'ZZX_FILIAL'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	2																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Filial'																, ; //X3_TITULO
	'Filial'																, ; //X3_TITSPA
	'Filial'																, ; //X3_TITENG
	'Filial'																, ; //X3_DESCRIC
	'Filial'																, ; //X3_DESCSPA
	'Filial'																, ; //X3_DESCENG
	''																		, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	1																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	'N'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'ZZX'																	, ; //X3_ARQUIVO
	'02'																	, ; //X3_ORDEM
	'ZZX_CNPJ'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'CNPJ'																	, ; //X3_TITULO
	'CNPJ'																	, ; //X3_TITSPA
	'CNPJ'																	, ; //X3_TITENG
	'CNPJ'																	, ; //X3_DESCRIC
	'CNPJ'																	, ; //X3_DESCSPA
	'CNPJ'																	, ; //X3_DESCENG
	'@R 99.999.999/9999-99'													, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	1																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	'N'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'ZZX'																	, ; //X3_ARQUIVO
	'03'																	, ; //X3_ORDEM
	'ZZX_NOME'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	61																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Nome'																	, ; //X3_TITULO
	'Nome'																	, ; //X3_TITSPA
	'Nome'																	, ; //X3_TITENG
	'Nome'																	, ; //X3_DESCRIC
	'Nome'																	, ; //X3_DESCSPA
	'Nome'																	, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	1																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	'N'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'ZZX'																	, ; //X3_ARQUIVO
	'04'																	, ; //X3_ORDEM
	'ZZX_CNAE'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	9																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'CNAE'																	, ; //X3_TITULO
	'CNAE'																	, ; //X3_TITSPA
	'CNAE'																	, ; //X3_TITENG
	'CNAE'																	, ; //X3_DESCRIC
	'CNAE'																	, ; //X3_DESCSPA
	'CNAE'																	, ; //X3_DESCENG
	'@R 9999-9/99'															, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	1																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	'N'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'ZZX'																	, ; //X3_ARQUIVO
	'05'																	, ; //X3_ORDEM
	'ZZX_REGESPT'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	20																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Reg.Especial'															, ; //X3_TITULO
	'Reg.Especial'															, ; //X3_TITSPA
	'Reg.Especial'															, ; //X3_TITENG
	'Reg.Especial'															, ; //X3_DESCRIC
	'Reg.Especial'															, ; //X3_DESCSPA
	'Reg.Especial'															, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	1																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	'N'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'ZZX'																	, ; //X3_ARQUIVO
	'06'																	, ; //X3_ORDEM
	'ZZX_HABILI'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	1																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Habilitado'															, ; //X3_TITULO
	'Habilitado'															, ; //X3_TITSPA
	'Habilitado'															, ; //X3_TITENG
	'Habilitado'															, ; //X3_DESCRIC
	'Habilitado'															, ; //X3_DESCSPA
	'Habilitado'															, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	1																		, ; //X3_NIVEL
	Chr(254) + Chr(65)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	'1=Sim;2=Nao'															, ; //X3_CBOX
	'1=Sim;2=Nao'															, ; //X3_CBOXSPA
	'1=Sim;2=Nao'															, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	'N'																		} ) //X3_PYME


aAdd( aSX3, { ;
	'ZZX'																	, ; //X3_ARQUIVO
	'07'																	, ; //X3_ORDEM
	'ZZX_USERGI'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	17																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Log de Inclu'															, ; //X3_TITULO
	'Log de Inclu'															, ; //X3_TITSPA
	'Log de Inclu'															, ; //X3_TITENG
	'Log de Inclusao'														, ; //X3_DESCRIC
	'Log de Inclusao'														, ; //X3_DESCSPA
	'Log de Inclusao'														, ; //X3_DESCENG
	''																		, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	9																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'L'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'ZZX'																	, ; //X3_ARQUIVO
	'08'																	, ; //X3_ORDEM
	'ZZX_USERGA'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	17																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Log de Alter'															, ; //X3_TITULO
	'Log de Alter'															, ; //X3_TITSPA
	'Log de Alter'															, ; //X3_TITENG
	'Log de Alteracao'														, ; //X3_DESCRIC
	'Log de Alteracao'														, ; //X3_DESCSPA
	'Log de Alteracao'														, ; //X3_DESCENG
	''																		, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	9																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'L'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

//⁄ƒƒƒƒƒƒƒƒƒƒø
//≥Tabela SU7≥
//¿ƒƒƒƒƒƒƒƒƒƒŸ
SX3->(DbSetOrder(1))
SX3->(MsSeek("SU7"+"ZZ",.T.))
SX3->(DbSkip(-1))

cOrdem := Soma1(SX3->X3_ORDEM)   

aAdd( aSX3, { ;
	'SU7'																	, ; //X3_ARQUIVO
	cOrdem																	, ; //X3_ORDEM
	'U7_XSENHA'  															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	15																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Senha  Email'															, ; //X3_TITULO
	'Senha  Email'															, ; //X3_TITSPA
	'Senha  Email'															, ; //X3_TITENG
	'Senha da conta do email  '												, ; //X3_DESCRIC
	'Senha da conta do email  '												, ; //X3_DESCSPA
	'Senha da conta do email  '												, ; //X3_DESCENG
	''																		, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
    ''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	'1'																		, ; //X3_FOLDER
	''																		} ) //X3_PYME


//FinalSX3
//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥Inicio da atualizaÁ„o                                               ≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
	
nPosArq := aScan( aEstrut, { |x| AllTrim( x ) == "X3_ARQUIVO" } )
nPosOrd := aScan( aEstrut, { |x| AllTrim( x ) == "X3_ORDEM"   } )
nPosCpo := aScan( aEstrut, { |x| AllTrim( x ) == "X3_CAMPO"   } )
nPosTam := aScan( aEstrut, { |x| AllTrim( x ) == "X3_TAMANHO" } )
nPosSXG := aScan( aEstrut, { |x| AllTrim( x ) == "X3_GRPSXG"  } )

aSort( aSX3,,, { |x,y| x[nPosArq]+x[nPosOrd]+x[nPosCpo] < y[nPosArq]+y[nPosOrd]+y[nPosCpo] } )

oProcess:SetRegua2( Len( aSX3 ) )

dbSelectArea( "SX3" )
dbSetOrder( 2 )
cAliasAtu := ""

For nI := 1 To Len( aSX3 )

	//
	// Verifica se o campo faz parte de um grupo e ajsuta tamanho
	//
	If !Empty( aSX3[nI][nPosSXG] )
		SXG->( dbSetOrder( 1 ) )
		If SXG->( MSSeek( aSX3[nI][nPosSXG] ) )
			If aSX3[nI][nPosTam] <> SXG->XG_SIZE
				aSX3[nI][nPosTam] := SXG->XG_SIZE
				cTexto += "O tamanho do campo " + aSX3[nI][nPosCpo] + " nao atualizado e foi mantido em ["
				cTexto += AllTrim( Str( SXG->XG_SIZE ) ) + "]" + CRLF
				cTexto += "   por pertencer ao grupo de campos [" + SX3->X3_GRPSXG + "]" + CRLF + CRLF
			EndIf
		EndIf
	EndIf

	SX3->( dbSetOrder( 2 ) )

	If !( aSX3[nI][nPosArq] $ cAlias )
		cAlias += aSX3[nI][nPosArq] + "/"
		aAdd( aArqUpd, aSX3[nI][nPosArq] )
	EndIf

	If !SX3->( dbSeek( PadR( aSX3[nI][nPosCpo], nTamSeek ) ) )

		//
		// Busca ultima ocorrencia do alias
		//
		If ( aSX3[nI][nPosArq] <> cAliasAtu )
			cSeqAtu   := "00"
			cAliasAtu := aSX3[nI][nPosArq]

			dbSetOrder( 1 )
			SX3->( dbSeek( cAliasAtu + "ZZ", .T. ) )
			dbSkip( -1 )

			If ( SX3->X3_ARQUIVO == cAliasAtu )
				cSeqAtu := SX3->X3_ORDEM
			EndIf

			nSeqAtu := Val( RetAsc( cSeqAtu, 3, .F. ) )
		EndIf

		nSeqAtu++
		cSeqAtu := RetAsc( Str( nSeqAtu ), 2, .T. )

		RecLock( "SX3", .T. )
		For nJ := 1 To Len( aSX3[nI] )
			If     nJ == nPosOrd  // Ordem
				FieldPut( FieldPos( aEstrut[nJ] ), cSeqAtu )

			ElseIf FieldPos( aEstrut[nJ] ) > 0
				FieldPut( FieldPos( aEstrut[nJ] ), aSX3[nI][nJ] )

			EndIf
		Next nJ

		dbCommit()
		MsUnLock()

		cTexto += "Criado o campo " + aSX3[nI][nPosCpo] + CRLF

	Else

		//
		// Verifica se o campo faz parte de um grupo e ajsuta tamanho
		//
		If !Empty( SX3->X3_GRPSXG ) .AND. SX3->X3_GRPSXG <> aSX3[nI][nPosSXG]
			SXG->( dbSetOrder( 1 ) )
			If SXG->( MSSeek( SX3->X3_GRPSXG ) )
				If aSX3[nI][nPosTam] <> SXG->XG_SIZE
					aSX3[nI][nPosTam] := SXG->XG_SIZE
					cTexto +=  "O tamanho do campo " + aSX3[nI][nPosCpo] + " nao atualizado e foi mantido em ["
					cTexto += AllTrim( Str( SXG->XG_SIZE ) ) + "]"+ CRLF
					cTexto +=  "   por pertencer ao grupo de campos [" + SX3->X3_GRPSXG + "]" + CRLF + CRLF
				EndIf
			EndIf
		EndIf

		//
		// Verifica todos os campos
		//
		For nJ := 1 To Len( aSX3[nI] )

			//
			// Se o campo estiver diferente da estrutura
			//
			If aEstrut[nJ] == SX3->( FieldName( nJ ) ) .AND. ;
				PadR( StrTran( AllToChar( SX3->( FieldGet( nJ ) ) ), " ", "" ), 250 ) <> ;
				PadR( StrTran( AllToChar( aSX3[nI][nJ] )           , " ", "" ), 250 ) .AND. ;
				AllTrim( SX3->( FieldName( nJ ) ) ) <> "X3_ORDEM"

				If nOpcA == 1
					cTexto += "Alterado o campo " + aSX3[nI][nPosCpo] + CRLF
					cTexto += "   " + PadR( SX3->( FieldName( nJ ) ), 10 ) + " de [" + AllToChar( SX3->( FieldGet( nJ ) ) ) + "]" + CRLF
					cTexto += "            para [" + AllToChar( aSX3[nI][nJ] )          + "]" + CRLF + CRLF

					RecLock( "SX3", .F. )
					FieldPut( FieldPos( aEstrut[nJ] ), aSX3[nI][nJ] )
					dbCommit()
					MsUnLock()
				EndIf

			EndIf

		Next

	EndIf

	oProcess:IncRegua2( "Atualizando Campos de Tabelas (SX3)..." )

Next nI

cTexto += CRLF + "Final da Atualizacao" + " SX3" + CRLF + Replicate( "-", 128 ) + CRLF + CRLF

Return NIL                                   
/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫ Programa ≥ FSAtuSX6 ∫ Autor ≥ TOTVS Protheus     ∫ Data ≥  13/07/12   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫ Descricao≥ Funcao de processamento da gravacao do SX6 - Par‚metros    ≥±±
±±∫          ≥                                                            ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±≥ Uso      ≥ FSAtuSX6   - Gerado por EXPORDIC / Upd. V.4.10.4 EFS       ≥±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Static Function FSAtuSX6( cTexto )
Local aEstrut   := {}
Local aSX6      := {}
Local cAlias    := ""
Local cMsg      := ""
Local lContinua := .T.
Local lReclock  := .T.
Local lTodosNao := .F.
Local lTodosSim := .T.
Local nI        := 0
Local nJ        := 0
Local nOpcA     := 1
Local nTamFil   := Len( SX6->X6_FIL )
Local nTamVar   := Len( SX6->X6_VAR )

cTexto  += "Inicio da Atualizacao" + " SX6" + CRLF + CRLF

aEstrut := { "X6_FIL"    , "X6_VAR"  , "X6_TIPO"   , "X6_DESCRIC", "X6_DSCSPA" , "X6_DSCENG" , "X6_DESC1"  , "X6_DSCSPA1",;
             "X6_DSCENG1", "X6_DESC2", "X6_DSCSPA2", "X6_DSCENG2", "X6_CONTEUD", "X6_CONTSPA", "X6_CONTENG", "X6_PROPRI" , "X6_PYME" }


aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'ES_CIC_MD' 															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Usuarios que receber„o CIC dos pedidos com '       					, ; //X6_DESCRIC
	'Usuarios que receber„o CIC dos pedidos com '							, ; //X6_DSCSPA
	'Usuarios que receber„o CIC dos pedidos com '							, ; //X6_DSCENG
	'mensagem para depÛsito.                    '							, ; //X6_DESC1
	'mensagem para depÛsito.                    '							, ; //X6_DSCSPA1
	'mensagem para depÛsito.                    '							, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'EXPEDICAOCD,LOURIVAL.NUNES'											, ; //X6_CONTEUD
	'EXPEDICAOCD,LOURIVAL.NUNES'											, ; //X6_CONTSPA
	'EXPEDICAOCD,LOURIVAL.NUNES'											, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME
	
aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'ES_D008LIC' 															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Usu·rios de licitaÁ„o que podem calcular margem'     					, ; //X6_DESCRIC
	'Usu·rios de licitaÁ„o que podem calcular margem'						, ; //X6_DSCSPA
	'Usu·rios de licitaÁ„o que podem calcular margem'						, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'FBESSA/DARRUDA/SROSA/JLIMA/PMENDONCA/ACAMPOS/CTODARO'					, ; //X6_CONTEUD
	'FBESSA/DARRUDA/SROSA/JLIMA/PMENDONCA/ACAMPOS/CTODARO'					, ; //X6_CONTSPA
	'FBESSA/DARRUDA/SROSA/JLIMA/PMENDONCA/ACAMPOS/CTODARO'					, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME	 


aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'MV_URELCON'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Usuarios que podem gerar o relatorio EE_SF3'							, ; //X6_DESCRIC
	'Usuarios que podem gerar o relatorio EE_SF3'							, ; //X6_DSCSPA
	'Usuarios que podem gerar o relatorio EE_SF3'							, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'ASANTOS/MCANUTO/DDOMINGOS/MTEIXEIRA/RBORGES/RLOPES/MSANTOS/SCREATTO'	, ; //X6_CONTEUD
	'ASANTOS/MCANUTO/DDOMINGOS/MTEIXEIRA/RBORGES/RLOPES/MSANTOS/SCREATTO'	, ; //X6_CONTSPA
	'ASANTOS/MCANUTO/DDOMINGOS/MTEIXEIRA/RBORGES/RLOPES/MSANTOS/SCREATTO'	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME     

	
aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'ES_CIC_TA' 															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Usu·rios que receberam CIC da Tranf. Automatica'     					, ; //X6_DESCRIC
	'Usu·rios que receberam CIC da Tranf. Automatica'						, ; //X6_DSCSPA
	'Usu·rios que receberam CIC da Tranf. Automatica'						, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''												    					, ; //X6_DSCENG2
	'ARMAZENAMENTO,REGINALDO.BORGES,MAXIMO.CANUTO'    	 					, ; //X6_CONTEUD
	'ARMAZENAMENTO,REGINALDO.BORGES,MAXIMO.CANUTO'	   						, ; //X6_CONTSPA
	'ARMAZENAMENTO,REGINALDO.BORGES,MAXIMO.CANUTO'							, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME	
	
	
aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'ES_EMTRAT' 															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Usu·rios receberam E-Mail da Tranf. Automatica '     					, ; //X6_DESCRIC
	'Usu·rios receberam E-Mail da Tranf. Automatica '						, ; //X6_DSCSPA
	'Usu·rios receberam E-Mail da Tranf. Automatica '						, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'armazenamento@dipromed.com.br;maximo.canuto@dipromed.com.br;reginaldo.borges@dipromed.com.br', ; //X6_CONTEUD
	'armazenamento@dipromed.com.br;maximo.canuto@dipromed.com.br;reginaldo.borges@dipromed.com.br', ; //X6_CONTSPA
	'armazenamento@dipromed.com.br;maximo.canuto@dipromed.com.br;reginaldo.borges@dipromed.com.br', ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME	
	
aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'ES_FORBEHQ' 															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Fornecedores HQ com pedido Tipo B usar B1_UPRC '     					, ; //X6_DESCRIC
	'Fornecedores HQ com pedido Tipo B usar B1_UPRC '						, ; //X6_DSCSPA
	'Fornecedores HQ com pedido Tipo B usar B1_UPRC '						, ; //X6_DSCENG
	'ao inves de usar o preco de venda'										, ; //X6_DESC1
	'ao inves de usar o preco de venda'										, ; //X6_DSCSPA1
	'ao inves de usar o preco de venda'										, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	"019433','110087"														, ; //X6_CONTEUD
	"019433','110087"														, ; //X6_CONTSPA
	"019433','110087"														, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME	
	
aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'ES_TRANSFE' 															, ; //X6_VAR
	'L'																		, ; //X6_TIPO
	'Se imprimira a prenota da transf. automatica   '     					, ; //X6_DESCRIC
	'Se imprimira a prenota da transf. automatica   '						, ; //X6_DSCSPA
	'Se imprimira a prenota da transf. automatica   '						, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'.T.'																	, ; //X6_CONTEUD
	'.T.'																	, ; //X6_CONTSPA
	'.T.'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME	


aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'ES_USRERIR' 															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Usuarios com acesso a rotina de inventario no  '     					, ; //X6_DESCRIC
	'Usuarios com acesso a rotina de inventario no  '						, ; //X6_DSCSPA
	'Usuarios com acesso a rotina de inventario no  '						, ; //X6_DSCENG
	'coletor de dados.                              '    					, ; //X6_DESC1
	'coletor de dados.                              '   					, ; //X6_DSCSPA1
	'coletor de dados.                              '	     				, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'DDOMINGOS,RBORGES,MCANUTO,HSOUSA,JANTONIO'								, ; //X6_CONTEUD
	'DDOMINGOS,RBORGES,MCANUTO,HSOUSA,JANTONIO'								, ; //X6_CONTSPA
	'DDOMINGOS,RBORGES,MCANUTO,HSOUSA,JANTONIO'  							, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME	

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'ES_EMINVRO' 															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Usuarios que receberao email do inventario     '     					, ; //X6_DESCRIC
	'Usuarios que receberao email do inventario     '						, ; //X6_DSCSPA
	'Usuarios que receberao email do inventario     '						, ; //X6_DSCENG
	'rotativo.			                            '    					, ; //X6_DESC1
	'rotativo.          		                    '   					, ; //X6_DSCSPA1
	'rotativo.                  		            '	     				, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'reginaldo.borges@dipromed.com.br;edvan.matias@dipromed.com.br;lourival.nunes@dipromed.com.br', ; //X6_CONTEUD
	'reginaldo.borges@dipromed.com.br;edvan.matias@dipromed.com.br;lourival.nunes@dipromed.com.br', ; //X6_CONTSPA
	'reginaldo.borges@dipromed.com.br;edvan.matias@dipromed.com.br;lourival.nunes@dipromed.com.br', ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME	
	
aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'ES_EMNFDEV' 															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Usuarios que receberao emails NFs Entrada SAC  '     					, ; //X6_DESCRIC
	'Usuarios que receberao emails NFs Entrada SAC  '						, ; //X6_DSCSPA
	'Usuarios que receberao emails NFs Entrada SAC  '						, ; //X6_DSCENG
	'e demais devoluÁıes.                           '    					, ; //X6_DESC1
	'e demais devoluÁıes. 		                    '   					, ; //X6_DSCSPA1
	'e demais devoluÁıes.          		            '	     				, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	''																		, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME	
                                                                                            

aAdd( aSX6, { ;
	'  '	   																, ; //X6_FIL
	'ES_AUTOST' 															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Clientes com ST calculados e incluÌdos         '     					, ; //X6_DESCRIC
	'Clientes com ST calculados e incluÌdos         '						, ; //X6_DSCSPA
	'Clientes com ST calculados e incluÌdos         '						, ; //X6_DSCENG
	'automaticamente no pedido.                     '    					, ; //X6_DESC1
	'automaticamente no pedido.                     '   					, ; //X6_DSCSPA1
	'automaticamente no pedido.                     '	     				, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'014651'																, ; //X6_CONTEUD
	'014651'																, ; //X6_CONTSPA
	'014651'																, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME	
     
aAdd( aSX6, { ;
	'  '	   																, ; //X6_FIL
	'ES_USERTM' 															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Usuarios que podem usar a rotina TM maior que 499'    					, ; //X6_DESCRIC
	'Usuarios que podem usar a rotina TM maior que 499'						, ; //X6_DSCSPA
	'Usuarios que podem usar a rotina TM maior que 499'						, ; //X6_DSCENG
	''												    					, ; //X6_DESC1
	''													   					, ; //X6_DSCSPA1
	''													     				, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'RBORGES/MCANUTO/DDOMINGOS'												, ; //X6_CONTEUD
	'RBORGES/MCANUTO/DDOMINGOS'												, ; //X6_CONTSPA
	'RBORGES/MCANUTO/DDOMINGOS'												, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME	
     

aAdd( aSX6, { ;
	'  '	   																, ; //X6_FIL
	'ES_DIPR035' 															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Usuarios com acesso total ao DIPR035             '    					, ; //X6_DESCRIC
	'Usuarios com acesso total ao DIPR035             '						, ; //X6_DSCSPA
	'Usuarios com acesso total ao DIPR035             '						, ; //X6_DSCENG
	''												    					, ; //X6_DESC1
	''													   					, ; //X6_DSCSPA1
	''													     				, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'RBORGES/MCANUTO/DDOMINGOS'												, ; //X6_CONTEUD
	'RBORGES/MCANUTO/DDOMINGOS'												, ; //X6_CONTSPA
	'RBORGES/MCANUTO/DDOMINGOS'												, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME	

aAdd( aSX6, { ;
	'  '	   																, ; //X6_FIL
	'ES_MT360CP' 															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Usuarios com acesso a incluir Cond Pagto dif de C'    					, ; //X6_DESCRIC
	'Usuarios com acesso a incluir Cond Pagto dif de C'						, ; //X6_DSCSPA
	'Usuarios com acesso a incluir Cond Pagto dif de C'						, ; //X6_DSCENG
	''												    					, ; //X6_DESC1
	''													   					, ; //X6_DSCSPA1
	''													     				, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'RBORGES/MCANUTO/DDOMINGOS'												, ; //X6_CONTEUD
	'RBORGES/MCANUTO/DDOMINGOS'												, ; //X6_CONTSPA
	'RBORGES/MCANUTO/DDOMINGOS'												, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME	
 
aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'ES_SAC_VEN'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Usuarios com permissao para alterar o Status'							, ; //X6_DESCRIC
	'Usuarios com permissao para alterar o Status'							, ; //X6_DSCSPA
	'Usuarios com permissao para alterar o Status'							, ; //X6_DSCENG
	'do SAC pendente Vendas'												, ; //X6_DESC1
	'do SAC pendente Vendas'												, ; //X6_DSCSPA1
	'do SAC pendente Vendas'												, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'RBORGES/LPEREIRA/JNOGUEIRA/RBEAZIN'									, ; //X6_CONTEUD
	'RBORGES/LPEREIRA/JNOGUEIRA/RBEAZIN'									, ; //X6_CONTSPA
	'RBORGES/LPEREIRA/JNOGUEIRA/RBEAZIN'									, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'ES_SAC_REC'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Usuarios com permissao para alterar o Status'							, ; //X6_DESCRIC
	'Usuarios com permissao para alterar o Status'							, ; //X6_DSCSPA
	'Usuarios com permissao para alterar o Status'							, ; //X6_DSCENG
	'do SAC pendente Recebimento'											, ; //X6_DESC1
	'do SAC pendente Recebimento' 											, ; //X6_DSCSPA1
	'do SAC pendente Recebimento'											, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'RBORGES/LPEREIRA/JNOGUEIRA/RBEAZIN'									, ; //X6_CONTEUD
	'RBORGES/LPEREIRA/JNOGUEIRA/RBEAZIN'									, ; //X6_CONTSPA
	'RBORGES/LPEREIRA/JNOGUEIRA/RBEAZIN'									, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME
	
aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'ES_SAC_EXP'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Usuarios com permissao para alterar o Status'							, ; //X6_DESCRIC
	'Usuarios com permissao para alterar o Status'							, ; //X6_DSCSPA
	'Usuarios com permissao para alterar o Status'							, ; //X6_DSCENG
	'do SAC pendente Expedicao'												, ; //X6_DESC1
	'do SAC pendente Expedicao'												, ; //X6_DSCSPA1
	'do SAC pendente Expedicao'												, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'RBORGES/LPEREIRA/JNOGUEIRA/RBEAZIN'									, ; //X6_CONTEUD
	'RBORGES/LPEREIRA/JNOGUEIRA/RBEAZIN'									, ; //X6_CONTSPA
	'RBORGES/LPEREIRA/JNOGUEIRA/RBEAZIN'									, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME		
	                                                                                            
aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'ES_SAC_COM'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Usuarios com permissao para alterar o Status'							, ; //X6_DESCRIC
	'Usuarios com permissao para alterar o Status'							, ; //X6_DSCSPA
	'Usuarios com permissao para alterar o Status'							, ; //X6_DSCENG
	'do SAC pendente Compras'												, ; //X6_DESC1
	'do SAC pendente Compras'												, ; //X6_DSCSPA1
	'do SAC pendente Compras'												, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'RBORGES/JNOGUEIRA/RBEAZIN/RFERRARIS'  									, ; //X6_CONTEUD
	'RBORGES/JNOGUEIRA/RBEAZIN/RFERRARIS'									, ; //X6_CONTSPA
	'RBORGES/JNOGUEIRA/RBEAZIN/RFERRARIS'									, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME			 

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'ES_SAC_TI'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Usuarios com permissao para alterar o Status'							, ; //X6_DESCRIC
	'Usuarios com permissao para alterar o Status'							, ; //X6_DSCSPA
	'Usuarios com permissao para alterar o Status'							, ; //X6_DSCENG
	'do SAC pendente na TI'													, ; //X6_DESC1
	'do SAC pendente na TI'													, ; //X6_DSCSPA1
	'do SAC pendente na TI'													, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'RBORGES/JNOGUEIRA/RBEAZIN/MCANUTO/DDOMINGOS'							, ; //X6_CONTEUD
	'RBORGES/JNOGUEIRA/RBEAZIN/MCANUTO/DDOMINGOS' 							, ; //X6_CONTSPA
	'RBORGES/JNOGUEIRA/RBEAZIN/MCANUTO/DDOMINGOS'							, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME			 
	 
aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'ES_RELCCO'									 							, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Usuarios que receberao copia oculta do 	 '							, ; //X6_DESCRIC
	'Usuarios que receberao copia oculta do 	 '							, ; //X6_DSCSPA
	'Usuarios que receberao copia oculta do 	 '							, ; //X6_DSCENG
	'pedido de compras'														, ; //X6_DESC1
	'pedido de compras'														, ; //X6_DSCSPA1
	'pedido de compras'														, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'rosemeire.ferraris@dipromed.com.br'			, ; //X6_CONTEUD
	'rosemeire.ferraris@dipromed.com.br'			, ; //X6_CONTSPA
	'rosemeire.ferraris@dipromed.com.br'			, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME    
	
aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'ES_SUDCLD'									 							, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Responsavel do transporte, o qual recebera	 '							, ; //X6_DESCRIC
	'Responsavel do transporte, o qual recebera	 '							, ; //X6_DSCSPA
	'Responsavel do transporte, o qual recebera	 '							, ; //X6_DSCENG
	'a copia dos e-mails dos SACs do centro logis'							, ; //X6_DESC1
	'a copia dos e-mails dos SACs do centro logis'							, ; //X6_DSCSPA1
	'a copia dos e-mails dos SACs do centro logis'							, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'lourival.nunes@dipromed.com.br'										, ; //X6_CONTEUD
	'lourival.nunes@dipromed.com.br'										, ; //X6_CONTSPA
	'lourival.nunes@dipromed.com.br'										, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME	 
	
                                                                                  
aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'ES_SUDTLV'									 							, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Responsavel do televendas, o qual recebera	 '							, ; //X6_DESCRIC
	'Responsavel do televendas, o qual recebera	 '							, ; //X6_DSCSPA
	'Responsavel do televendas, o qual recebera	 '							, ; //X6_DSCENG
	'a copia dos e-mails dos SACs de televendas  '							, ; //X6_DESC1
	'a copia dos e-mails dos SACs de televendas  '							, ; //X6_DSCSPA1
	'a copia dos e-mails dos SACs de televendas  '							, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'marcia.ornellas@dipromed.com.br'										, ; //X6_CONTEUD
	'marcia.ornellas@dipromed.com.br'										, ; //X6_CONTSPA
	'marcia.ornellas@dipromed.com.br'										, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME	 
                                                                                         
aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'ES_SUDAPO'									 							, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Responsavel do Apoio, o qual recebera  	 '							, ; //X6_DESCRIC
	'Responsavel do Apoio, o qual recebera  	 '							, ; //X6_DSCSPA
	'Responsavel do Apoio, o qual recebera  	 '							, ; //X6_DSCENG
	'a copia dos e-mails dos SACs do apoio		 '							, ; //X6_DESC1
	'a copia dos e-mails dos SACs do apoio       '							, ; //X6_DSCSPA1
	'a copia dos e-mails dos SACs do apoio       '							, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'patricia.mendonca@dipromed.com.br'										, ; //X6_CONTEUD
	'patricia.mendonca@dipromed.com.br'										, ; //X6_CONTSPA
	'patricia.mendonca@dipromed.com.br'										, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'ES_SUDLIC'									 							, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Responsavel de Licitacoes, o qual recebera  '							, ; //X6_DESCRIC
	'Responsavel do Apoio, o qual recebera  	 '							, ; //X6_DSCSPA
	'Responsavel do Apoio, o qual recebera  	 '							, ; //X6_DSCENG
	'a copia dos e-mails dos SACs de licitacoes  '							, ; //X6_DESC1
	'a copia dos e-mails dos SACs de licitacoes  '							, ; //X6_DSCSPA1
	'a copia dos e-mails dos SACs de licitacoes  '							, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'patricia.mendonca@dipromed.com.br'										, ; //X6_CONTEUD
	'patricia.mendonca@dipromed.com.br'										, ; //X6_CONTSPA
	'patricia.mendonca@dipromed.com.br'										, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'ES_UCTATUS'								 							, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Usuarios que nao precisarao alterar o status'							, ; //X6_DESCRIC
	'Usuarios que nao precisarao alterar o status'							, ; //X6_DSCSPA
	'Usuarios que nao precisarao alterar o status'							, ; //X6_DSCENG
	'ao confirmar o reg do sac para o destino SAC'							, ; //X6_DESC1
	'ao confirmar o reg do sac para o destino SAC'							, ; //X6_DSCSPA1
	'ao confirmar o reg do sac para o destino SAC'							, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'EPONTOLDIO'															, ; //X6_CONTEUD
	'EPONTOLDIO'															, ; //X6_CONTSPA
	'EPONTOLDIO'															, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'ES_DIPM27_'								 							, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Controle de emissao de Cte para clientes Licitacao'   					, ; //X6_DESCRIC
	'Controle de emissao de Cte para clientes Licitacao'    				, ; //X6_DSCSPA
	'Controle de emissao de Cte para clientes Licitacao'	    			, ; //X6_DSCENG
	'com carta de vale.                                '    				, ; //X6_DESC1
	'com carta de vale.                                '					, ; //X6_DSCSPA1
	'com carta de vale.                                '    				, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'020411'												  				, ; //X6_CONTEUD
	'020411'																, ; //X6_CONTSPA
	'020411'																, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME
	
aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'ES_DIPMALM'								 							, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Usuarios que receberao CIC quando o pedido n„o    '   					, ; //X6_DESCRIC
	'Usuarios que receberao CIC quando o pedido n„o    '    				, ; //X6_DSCSPA
	'Usuarios que receberao CIC quando o pedido n„o    '	    			, ; //X6_DSCENG
	'movimentar Estoque ou for Estoque diferente do 01 '    				, ; //X6_DESC1
	'movimentar Estoque ou for Estoque diferente do 01 '					, ; //X6_DSCSPA1
	'movimentar Estoque ou for Estoque diferente do 01 '    				, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'REGINALDO.BORGES,MAXIMO.CANUTO,DIEGO.DOMINGOS,LOURIVAL.NUNES,EDVAN.MATIAS,EXPEDICAOCD,NOTAFISCAL,NOTAFISCAL2', ; //X6_CONTEUD
	'REGINALDO.BORGES,MAXIMO.CANUTO,DIEGO.DOMINGOS,LOURIVAL.NUNES,EDVAN.MATIAS,EXPEDICAOCD,NOTAFISCAL,NOTAFISCAL2', ; //X6_CONTSPA
	'REGINALDO.BORGES,MAXIMO.CANUTO,DIEGO.DOMINGOS,LOURIVAL.NUNES,EDVAN.MATIAS,EXPEDICAOCD,NOTAFISCAL,NOTAFISCAL2', ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME	                                         
	
	

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'ES_DIPMALE'								 							, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Usuarios que receberao Email quando o pedido n„o  '   					, ; //X6_DESCRIC
	'Usuarios que receberao Email quando o pedido n„o  '    				, ; //X6_DSCSPA
	'Usuarios que receberao Email quando o pedido n„o  '	    			, ; //X6_DSCENG
	'movimentar Estoque ou for Estoque diferente do 01 '    				, ; //X6_DESC1
	'movimentar Estoque ou for Estoque diferente do 01 '					, ; //X6_DSCSPA1
	'movimentar Estoque ou for Estoque diferente do 01 '    				, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'reginaldo.borges@dipromed.com.br;lourival.nunes@dipromed.com.br;edvan.matias@dipromed.com.br;expedicao@dipromed.com.br', ; //X6_CONTEUD
	'reginaldo.borges@dipromed.com.br;lourival.nunes@dipromed.com.br;edvan.matias@dipromed.com.br;expedicao@dipromed.com.br', ; //X6_CONTSPA
	'reginaldo.borges@dipromed.com.br;lourival.nunes@dipromed.com.br;edvan.matias@dipromed.com.br;expedicao@dipromed.com.br', ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME	
    

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'ES_LIBDTFT'								 							, ; //X6_VAR
	'L'																		, ; //X6_TIPO
	'Desabilita validaÁ„o de data na entrada do mÛdulo '  					, ; //X6_DESCRIC
	'Desabilita validaÁ„o de data na entrada do mÛdulo '    				, ; //X6_DSCSPA
	'Desabilita validaÁ„o de data na entrada do mÛdulo '	    			, ; //X6_DSCENG
	'do faturamento                                    '    				, ; //X6_DESC1
	'do faturamento                                    '					, ; //X6_DSCSPA1
	'do faturamento                                    '    				, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'F'																		, ; //X6_CONTEUD
	'F'																		, ; //X6_CONTSPA
	'F'																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME	
	
aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'ES_CTBVAUT'	 								 							, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Horario para rodar contabilizazao Off Line'	   						, ; //X6_DESCRIC
	'Horario para rodar contabilizazao Off Line'    						, ; //X6_DSCSPA
	'Horario para rodar contabilizazao Off Line'	    					, ; //X6_DSCENG
	''													    				, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	'' 														   				, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'"23:59|10:00"'															, ; //X6_CONTEUD
	'"23:59|10:00"'															, ; //X6_CONTSPA
	'"23:59|10:00"'															, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME		
                                                                                                
aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'ES_GeNFCTE'	 								 							, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Usuarios com permiss„o para gerar NF p CTE'	   						, ; //X6_DESCRIC
	'Usuarios com permiss„o para gerar NF p CTE'    						, ; //X6_DSCSPA
	'Usuarios com permiss„o para gerar NF p CTE'	    					, ; //X6_DSCENG
	''													    				, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	'' 														   				, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'EELIAS/MCANUTO/LNUNES/RBORGES/RRODRIGUES/MAUGUSTO/DDOMINGOS/GNUNES/PALMEIDA', ; //X6_CONTEUD
	'EELIAS/MCANUTO/LNUNES/RBORGES/RRODRIGUES/MAUGUSTO/DDOMINGOS/GNUNES/PALMEIDA', ; //X6_CONTSPA
	'EELIAS/MCANUTO/LNUNES/RBORGES/RRODRIGUES/MAUGUSTO/DDOMINGOS/GNUNES/PALMEIDA', ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME		
	
aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'ES_TESDOAC' 								 							, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Os TES usados em produtos para doacao     '	   						, ; //X6_DESCRIC
	'Os TES usados em produtos para doacao     '    						, ; //X6_DSCSPA
	'Os TES usados em produtos para doacao     '	    					, ; //X6_DSCENG
	''													    				, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	'' 														   				, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'548/631/677'															, ; //X6_CONTEUD
	'548/631/677'															, ; //X6_CONTSPA
	'548/631/677'															, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME		

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'ES_A261TFM'								 							, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Destinatarios dos emails das transferencias mod02 '   					, ; //X6_DESCRIC
	'Destinatarios dos emails das transferencias mod02 '    				, ; //X6_DSCSPA
	'Destinatarios dos emails das transferencias mod02 '	    			, ; //X6_DSCENG
	''													    				, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''													    				, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'reginaldo.borges@dipromed.com.br;lourival.nunes@dipromed.com.br;edvan.matias@dipromed.com.br', ; //X6_CONTEUD
	'reginaldo.borges@dipromed.com.br;lourival.nunes@dipromed.com.br;edvan.matias@dipromed.com.br', ; //X6_CONTSPA
	'reginaldo.borges@dipromed.com.br;lourival.nunes@dipromed.com.br;edvan.matias@dipromed.com.br', ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME	

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'ES_CIC_TM'									 							, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Destinatarios dos Cics das transferencias mod02 '   					, ; //X6_DESCRIC
	'Destinatarios dos Cics das transferencias mod02 '	    				, ; //X6_DSCSPA
	'Destinatarios dos Cics das transferencias mod02 '		    			, ; //X6_DSCENG
	''													    				, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''													    				, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'REGINALDO.BORGES,LOURIVAL.NUNES,EDVAN.MATIAS'							, ; //X6_CONTEUD
	'REGINALDO.BORGES,LOURIVAL.NUNES,EDVAN.MATIAS'							, ; //X6_CONTSPA
	'REGINALDO.BORGES,LOURIVAL.NUNES,EDVAN.MATIAS'							, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME			
		                                                                                            
aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'ES_EMTRAQ'									 							, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Envia Email pra qualidade na rejeicao prod CQ 06'   					, ; //X6_DESCRIC
	'Envia Email pra qualidade na rejeicao prod CQ 06'	    				, ; //X6_DSCSPA
	'Envia Email pra qualidade na rejeicao prod CQ 06'		    			, ; //X6_DSCENG
	''													    				, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''													    				, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'reginaldo.borges@dipromed.com.br;qualidade@dipromed.com.br'			, ; //X6_CONTEUD
	'reginaldo.borges@dipromed.com.br;qualidade@dipromed.com.br'			, ; //X6_CONTSPA
	'reginaldo.borges@dipromed.com.br;qualidade@dipromed.com.br'			, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME					

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'ES_CIC_TQ'									 							, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Envia CIC pra qualidade na rejeicao prod CQ 06'  	 					, ; //X6_DESCRIC
	'Envia CIC pra qualidade na rejeicao prod CQ 06'	    				, ; //X6_DSCSPA
	'Envia CIC pra qualidade na rejeicao prod CQ 06'		    			, ; //X6_DSCENG
	''													    				, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''													    				, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'REGINALDO.BORGES,RAFAELA.BEAZIN'										, ; //X6_CONTEUD
	'REGINALDO.BORGES,RAFAELA.BEAZIN'										, ; //X6_CONTSPA
	'REGINALDO.BORGES,RAFAELA.BEAZIN'										, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME					
                                                                                            
aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'ES_EMTRAQ'									 							, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Envia Email pra qualid. classificao da Nf pro 06'   					, ; //X6_DESCRIC
	'Envia Email pra qualid. classificao da Nf pro 06'	    				, ; //X6_DSCSPA
	'Envia Email pra qualid. classificao da Nf pro 06'		    			, ; //X6_DSCENG
	''													    				, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''													    				, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'reginaldo.borges@dipromed.com.br;qualidade@dipromed.com.br'			, ; //X6_CONTEUD
	'reginaldo.borges@dipromed.com.br;qualidade@dipromed.com.br'			, ; //X6_CONTSPA
	'reginaldo.borges@dipromed.com.br;qualidade@dipromed.com.br'			, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME					

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'ES_CIC_TQ'									 							, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Envia CIC pra qualid. classificao da Nf pro 06'  	 					, ; //X6_DESCRIC
	'Envia CIC pra qualid. classificao da Nf pro 06'	    				, ; //X6_DSCSPA
	'Envia CIC pra qualid. classificao da Nf pro 06'		    			, ; //X6_DSCENG
	''													    				, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''													    				, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'REGINALDO.BORGES,RAFAELA.BEAZIN'										, ; //X6_CONTEUD
	'REGINALDO.BORGES,RAFAELA.BEAZIN'										, ; //X6_CONTSPA
	'REGINALDO.BORGES,RAFAELA.BEAZIN'										, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME	

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'ES_TMKALCL'								 							, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Usuarios que podem alterar cliente a partir '  	 					, ; //X6_DESCRIC
	'Usuarios que podem alterar cliente a partir '		    				, ; //X6_DSCSPA
	'Usuarios que podem alterar cliente a partir '			    			, ; //X6_DSCENG
	'do atendimento do SAC'								    				, ; //X6_DESC1
	'do atendimento do SAC'													, ; //X6_DSCSPA1
	'do atendimento do SAC'								    				, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'RBORGES/ASANTOS/AALMEIDA'												, ; //X6_CONTEUD
	'RBORGES/ASANTOS/AALMEIDA'												, ; //X6_CONTSPA
	'RBORGES/ASANTOS/AALMEIDA'												, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME		
		                                                                                        
aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'ES_DIPML40'								 							, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Email para avaliacao de credito de licitacao'  	 					, ; //X6_DESCRIC
	'Email para avaliacao de credito de licitacao'		    				, ; //X6_DSCSPA
	'Email para avaliacao de credito de licitacao'			    			, ; //X6_DSCENG
	''													    				, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''													    				, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'maximo.canuto@dipromed.com.br;reginaldo.borges@dipromed.com.br'		, ; //X6_CONTEUD
	'maximo.canuto@dipromed.com.br;reginaldo.borges@dipromed.com.br'		, ; //X6_CONTSPA
	'maximo.canuto@dipromed.com.br;reginaldo.borges@dipromed.com.br'		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME				
		                                                                                    
aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'ES_C6PEDCL'								 							, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Clientes para os quais se deve informar     '  	 					, ; //X6_DESCRIC
	'Clientes para os quais se deve informar     '		    				, ; //X6_DSCSPA
	'Clientes para os quais se deve informar     '			    			, ; //X6_DSCENG
	'o pedido de compra no C6_PEDCLI			 '		    				, ; //X6_DESC1
	'o pedido de compra no C6_PEDCLI			 '							, ; //X6_DSCSPA1
	'o pedido de compra no C6_PEDCLI			 '   	    				, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	''																		, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME	
	
aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'ES_CICBOLH'								 							, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Usu·rios que receberao CIC de boleto c/ ERRO'  	 					, ; //X6_DESCRIC
	'Usu·rios que receberao CIC de boleto c/ ERRO'		    				, ; //X6_DSCSPA
	'Usu·rios que receberao CIC de boleto c/ ERRO'			    			, ; //X6_DSCENG
	',validacao ocorre no faturamento  da NF     '		    				, ; //X6_DESC1
	',validacao ocorre no faturamento  da NF     '							, ; //X6_DSCSPA1
	',validacao ocorre no faturamento  da NF     '   	    				, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'MAXIMO.CANUTO,REGINALDO.BORGES,JULIANA.NUNES'							, ; //X6_CONTEUD
	'MAXIMO.CANUTO,REGINALDO.BORGES,JULIANA.NUNES'							, ; //X6_CONTSPA
	'MAXIMO.CANUTO,REGINALDO.BORGES,JULIANA.NUNES'							, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME	
	
aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'ES_MAIBOLH'								 							, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Usu·rios que receberao EMAIL boleto c/ ERRO '  	 					, ; //X6_DESCRIC
	'Usu·rios que receberao EMAIL boleto c/ ERRO '		    				, ; //X6_DSCSPA
	'Usu·rios que receberao EMAIL boleto c/ ERRO '			    			, ; //X6_DSCENG
	',validacao ocorre no faturamento  da NF     '		    				, ; //X6_DESC1
	',validacao ocorre no faturamento  da NF     '							, ; //X6_DSCSPA1
	',validacao ocorre no faturamento  da NF     '   	    				, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'maximo.canuto@dipromed.com.br;reginaldo.borges@dipromed.com.br;financeiro@healthquality.ind.br', ; //X6_CONTEUD
	'maximo.canuto@dipromed.com.br;reginaldo.borges@dipromed.com.br;financeiro@healthquality.ind.br', ; //X6_CONTSPA
	'maximo.canuto@dipromed.com.br;reginaldo.borges@dipromed.com.br;financeiro@healthquality.ind.br', ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME	

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'ES_C6PEDCL'								 							, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Clientes para validar o C6_PEDCLI na inclusao'  	 					, ; //X6_DESCRIC
	'Clientes para validar o C6_PEDCLI na inclusao'		    				, ; //X6_DSCSPA
	'Clientes para validar o C6_PEDCLI na inclusao'			    			, ; //X6_DSCENG
	'do orcamento ou pedido de vendas.            '		    				, ; //X6_DESC1
	'do orcamento ou pedido de vendas.            '							, ; //X6_DSCSPA1
	'do orcamento ou pedido de vendas.            '   	    				, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	''																		, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME	
						                                                                    
aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'ES_LOTE650'								 							, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Usuarios autorizados a gerar lotes nas OPs   '  	 					, ; //X6_DESCRIC
	'Usuarios autorizados a gerar lotes nas OPs   '		    				, ; //X6_DSCSPA
	'Usuarios autorizados a gerar lotes nas OPs   '			    			, ; //X6_DSCENG
	''													    				, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''   	    															, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	''																		, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME							
			

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'MV_UINDBEN'								 							, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Fornecedores beneficiamento/industrializacao '  	 					, ; //X6_DESCRIC
	'Fornecedores beneficiamento/industrializacao '		    				, ; //X6_DSCSPA
	'Fornecedores beneficiamento/industrializacao '			    			, ; //X6_DSCENG
	''													    				, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''   	    															, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'110087,019433'															, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME							
					
aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'MV_EINDBEN'								 							, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Usuarios para receber emails das entradas de '  	 					, ; //X6_DESCRIC
	'Usuarios para receber emails das entradas de '		    				, ; //X6_DSCSPA
	'Usuarios para receber emails das entradas de '			    			, ; //X6_DSCENG
	'beneficiamento e industrializaÁ„o'					    				, ; //X6_DESC1
	'beneficiamento e industrializaÁ„o'										, ; //X6_DSCSPA1
	'beneficiamento e industrializaÁ„o'										, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'reginaldo.borges@dipromed.com.br;juraci.rocha@dipromed.com.br;financeiro@healthquality.ind.br', ; //X6_CONTEUD
	'reginaldo.borges@dipromed.com.br;juraci.rocha@dipromed.com.br;financeiro@healthquality.ind.br', ; //X6_CONTSPA
	'reginaldo.borges@dipromed.com.br;juraci.rocha@dipromed.com.br;financeiro@healthquality.ind.br', ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME							

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'ES_CLIDFAA'								 							, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Clientes de dificil acesso na entrega ATIVA '  	 					, ; //X6_DESCRIC
	'Clientes de dificil acesso na entrega ATIVA '		    				, ; //X6_DSCSPA
	'Clientes de dificil acesso na entrega ATIVA '			    			, ; //X6_DSCENG
	''								    									, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''   	    															, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	''																		, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME	
                                                                                            
If cEmpAnt == "04"
	aAdd( aSX6, { ;
		'  '																	, ; //X6_FIL
		'ES_DIPR072'								 							, ; //X6_VAR
		'C'																		, ; //X6_TIPO
		'Usuarios com acesso ao relatorio de FRETE CIF     ' 					, ; //X6_DESCRIC
		'Usuarios com acesso ao relatorio de FRETE CIF     '    				, ; //X6_DSCSPA
		'Usuarios com acesso ao relatorio de FRETE CIF     '  	    			, ; //X6_DSCENG
		''								    									, ; //X6_DESC1
		''																		, ; //X6_DSCSPA1
		''   	    															, ; //X6_DSCENG1
		''																		, ; //X6_DESC2
		''																		, ; //X6_DSCSPA2
		''																		, ; //X6_DSCENG2
		'EPONTOLDIO/LMARTINS/LSANTOS/MCANUTO/DDOMINGOS/RBORGES/LLOPES'			, ; //X6_CONTEUD
		'EPONTOLDIO/LMARTINS/LSANTOS/MCANUTO/DDOMINGOS/RBORGES/LLOPES'			, ; //X6_CONTSPA
		'EPONTOLDIO/LMARTINS/LSANTOS/MCANUTO/DDOMINGOS/RBORGES/LLOPES'  		, ; //X6_CONTENG
		'U'																		, ; //X6_PROPRI
		''																		} ) //X6_PYME	
Else
	aAdd( aSX6, { ;
		'  '																	, ; //X6_FIL
		'ES_DIPR072'								 							, ; //X6_VAR
		'C'																		, ; //X6_TIPO
		'Usuarios com acesso ao relatorio de FRETE CIF     ' 					, ; //X6_DESCRIC
		'Usuarios com acesso ao relatorio de FRETE CIF     '    				, ; //X6_DSCSPA
		'Usuarios com acesso ao relatorio de FRETE CIF     '  	    			, ; //X6_DSCENG
		''								    									, ; //X6_DESC1
		''																		, ; //X6_DSCSPA1
		''   	    															, ; //X6_DSCENG1
		''																		, ; //X6_DESC2
		''																		, ; //X6_DSCSPA2
		''																		, ; //X6_DSCENG2
		'EPONTOLDIO/LMARTINS/LSANTOS/MCANUTO/PMENDONCA/DDOMINGOS/RBORGES/JMAMEDE', ; //X6_CONTEUD	
		'EPONTOLDIO/LMARTINS/LSANTOS/MCANUTO/PMENDONCA/DDOMINGOS/RBORGES/JMAMEDE', ; //X6_CONTSPA
		'EPONTOLDIO/LMARTINS/LSANTOS/MCANUTO/PMENDONCA/DDOMINGOS/RBORGES/JMAMEDE', ; //X6_CONTENG
		'U'																		, ; //X6_PROPRI
		''																		} ) //X6_PYME	
EndIf

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'ES_CICVBOL'								 							, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Usuarios que receberao o CIC da Validacao   '  	 					, ; //X6_DESCRIC
	'Usuarios que receberao o CIC da Validacao   '		    				, ; //X6_DSCSPA
	'Usuarios que receberao o CIC da Validacao   '			    			, ; //X6_DSCENG
	'dos boletos Dipromed'			    									, ; //X6_DESC1
	'dos boletos Dipromed'													, ; //X6_DSCSPA1
	'dos boletos Dipromed'  												, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'SIDNEIA.DOMINGOS,MAXIMO.CANUTO,REGINALDO.BORGES'						, ; //X6_CONTEUD
	'SIDNEIA.DOMINGOS,MAXIMO.CANUTO,REGINALDO.BORGES'						, ; //X6_CONTSPA
	'SIDNEIA.DOMINGOS,MAXIMO.CANUTO,REGINALDO.BORGES'						, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME	

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'ES_MAIVBOL'								 							, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Usuarios que receberao o Email da Validacao '  	 					, ; //X6_DESCRIC
	'Usuarios que receberao o Email da Validacao '		    				, ; //X6_DSCSPA
	'Usuarios que receberao o Email da Validacao '			    			, ; //X6_DSCENG
	'dos boletos Dipromed'			    									, ; //X6_DESC1
	'dos boletos Dipromed'													, ; //X6_DSCSPA1
	'dos boletos Dipromed'													, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'sidneia.domingos@dipromed.com.br;maximo.canuto@dipromed.com.br;reginaldo.borges@dipromed.com.br', ; //X6_CONTEUD
	'sidneia.domingos@dipromed.com.br;maximo.canuto@dipromed.com.br;reginaldo.borges@dipromed.com.br', ; //X6_CONTSPA
	'sidneia.domingos@dipromed.com.br;maximo.canuto@dipromed.com.br;reginaldo.borges@dipromed.com.br', ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME	
                                                                                         
aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'ES_CICBOLH'								 							, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Usuarios que receberao o CIC da Validacao   '  	 					, ; //X6_DESCRIC
	'Usuarios que receberao o CIC da Validacao   '		    				, ; //X6_DSCSPA
	'Usuarios que receberao o CIC da Validacao   '			    			, ; //X6_DSCENG
	'dos boletos Health Quality'	    									, ; //X6_DESC1
	'dos boletos Health Quality'											, ; //X6_DSCSPA1
	'dos boletos Health Quality'											, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'JULIANA.NUNES,CAROLINA.SOSSOLOTE,ANA.SANTOS,MAXIMO.CANUTO,REGINALDO.BORGES', ; //X6_CONTEUD
	'JULIANA.NUNES,CAROLINA.SOSSOLOTE,ANA.SANTOS,MAXIMO.CANUTO,REGINALDO.BORGES', ; //X6_CONTSPA
	'JULIANA.NUNES,CAROLINA.SOSSOLOTE,ANA.SANTOS,MAXIMO.CANUTO,REGINALDO.BORGES', ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME	

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'ES_MAIBOLH'								 							, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Usuarios que receberao o Email da Validacao '  	 					, ; //X6_DESCRIC
	'Usuarios que receberao o Email da Validacao '		    				, ; //X6_DSCSPA
	'Usuarios que receberao o Email da Validacao '			    			, ; //X6_DSCENG
	'dos boletos Health Quality'	    									, ; //X6_DESC1
	'dos boletos Health Quality'											, ; //X6_DSCSPA1
	'dos boletos Health Quality'											, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'financeiro@healthquality.ind.br;vendas@healthquality.ind.br;ana.paula@healthquality.ind.br;maximo.canuto@dipromed.com.br;reginaldo.borges@dipromed.com.br', ; //X6_CONTEUD
	'financeiro@healthquality.ind.br;vendas@healthquality.ind.br;ana.paula@healthquality.ind.br;maximo.canuto@dipromed.com.br;reginaldo.borges@dipromed.com.br', ; //X6_CONTSPA
	'financeiro@healthquality.ind.br;vendas@healthquality.ind.br;ana.paula@healthquality.ind.br;maximo.canuto@dipromed.com.br;reginaldo.borges@dipromed.com.br', ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME


aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'ES_USERLOC'								 							, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Usuarios que nao executam gatilho C6_LOCAL  '  	 					, ; //X6_DESCRIC
	'Usuarios que nao executam gatilho C6_LOCAL  '		    				, ; //X6_DSCSPA
	'Usuarios que nao executam gatilho C6_LOCAL  '			    			, ; //X6_DSCENG
	''								    									, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'JNOGUEIRA/RSANTOS/RBEAZIN/WANDRADE'									, ; //X6_CONTEUD
	'JNOGUEIRA/RSANTOS/RBEAZIN/WANDRADE'									, ; //X6_CONTSPA
	'JNOGUEIRA/RSANTOS/RBEAZIN/WANDRADE'									, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME


aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'ES_PEDREEM'								 							, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Usuarios que receberao o Email dos Pedidos  '  	 					, ; //X6_DESCRIC
	'Usuarios que receberao o Email dos Pedidos  '		    				, ; //X6_DSCSPA
	'Usuarios que receberao o Email dos Pedidos  '			    			, ; //X6_DSCENG
	'com pre nota n„o faturados ha mais de 48 hor'							, ; //X6_DESC1
	'com pre nota n„o faturados ha mais de 48 hor'							, ; //X6_DSCSPA1
	'com pre nota n„o faturados ha mais de 48 hor'							, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'edvan.matias@dipromed.com.br;lourival.nunes@dipromed.com.br;expedicao@dipromed.com.br;reginaldo.borges@dipromed.com.br', ; //X6_CONTEUD
	'edvan.matias@dipromed.com.br;lourival.nunes@dipromed.com.br;expedicao@dipromed.com.br;reginaldo.borges@dipromed.com.br', ; //X6_CONTSPA
	'edvan.matias@dipromed.com.br;lourival.nunes@dipromed.com.br;expedicao@dipromed.com.br;reginaldo.borges@dipromed.com.br', ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME


aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'ES_PEDRECI'								 							, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Usuarios que receberao o CIC dos Pedidos    '  	 					, ; //X6_DESCRIC
	'Usuarios que receberao o CIC dos Pedidos    '		    				, ; //X6_DSCSPA
	'Usuarios que receberao o CIC dos Pedidos    '			    			, ; //X6_DSCENG
	'com pre nota n„o faturados ha mais de 48 hor'							, ; //X6_DESC1
	'com pre nota n„o faturados ha mais de 48 hor'							, ; //X6_DSCSPA1
	'com pre nota n„o faturados ha mais de 48 hor'							, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'EDVAN.MATIAS,LOURIVAL.NUNES,EXPEDICAOCD,REGINALDO.BORGES'				, ; //X6_CONTEUD
	'EDVAN.MATIAS,LOURIVAL.NUNES,EXPEDICAOCD,REGINALDO.BORGES'				, ; //X6_CONTSPA
	'EDVAN.MATIAS,LOURIVAL.NUNES,EXPEDICAOCD,REGINALDO.BORGES'				, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'ES_C5COND'								 								, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Condicao de pagamentoa vista para DIPR092   '  	 					, ; //X6_DESCRIC
	'Condicao de pagamentoa vista para DIPR092   '		    				, ; //X6_DSCSPA
	'Condicao de pagamentoa vista para DIPR092	 '			    			, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	"001','002"																, ; //X6_CONTEUD
	"001','002"																, ; //X6_CONTSPA
	"001','002"																, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'ES_M030CIC'								 								, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Usuarios que serao notificados por CIC da   '  	 					, ; //X6_DESCRIC
	'Usuarios que serao notificados por CIC da   '		    				, ; //X6_DSCSPA
	'Usuarios que serao notificados por CIC da   '			    			, ; //X6_DSCENG
	'inclusao de um novo cliente.'											, ; //X6_DESC1
	'inclusao de um novo cliente.'											, ; //X6_DSCSPA1
	'inclusao de um novo cliente.' 											, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'RAFAELA.BEAZIN,REGINALDO.BORGES'										, ; //X6_CONTEUD
	'RAFAELA.BEAZIN,REGINALDO.BORGES'										, ; //X6_CONTSPA
	'RAFAELA.BEAZIN,REGINALDO.BORGES'										, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'ES_M030EMA'								 							, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Usuarios que serao notificados por Email da '  	 					, ; //X6_DESCRIC
	'Usuarios que serao notificados por Email da '		    				, ; //X6_DSCSPA
	'Usuarios que serao notificados por Email da '			    			, ; //X6_DSCENG
	'inclusao de um novo cliente.'											, ; //X6_DESC1
	'inclusao de um novo cliente.'											, ; //X6_DSCSPA1
	'inclusao de um novo cliente.'											, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'qualidade@dipromed.com.br;reginaldo.borges@dipromed.com.br'			, ; //X6_CONTEUD
	'qualidade@dipromed.com.br;reginaldo.borges@dipromed.com.br'			, ; //X6_CONTSPA
	'qualidade@dipromed.com.br;reginaldo.borges@dipromed.com.br'			, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'ES_GRPVEN'									 							, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Usuario que podem alterar ou incluir        '  	 					, ; //X6_DESCRIC
	'Usuario que podem alterar ou incluir        '		    				, ; //X6_DSCSPA
	'Usuario que podem alterar ou incluir        '			    			, ; //X6_DSCENG
	'grupo de clientes.'													, ; //X6_DESC1
	'grupo de clientes.'													, ; //X6_DSCSPA1
	'grupo de clientes.'													, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'MCANUTO/PMENDONCA/BRODRIGUES'											, ; //X6_CONTEUD
	'MCANUTO/PMENDONCA/BRODRIGUES'											, ; //X6_CONTSPA
	'MCANUTO/PMENDONCA/BRODRIGUES'											, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'ES_XUSRLIB'								 							, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Usuarios p aprovacao de PV com valor sup 50k'  			 			, ; //X6_DESCRIC
	'Usuarios p aprovacao de PV com valor sup 50k'		    				, ; //X6_DSCSPA
	'Usuarios p aprovacao de PV com valor sup 50k'			    			, ; //X6_DSCENG
	'grupo de clientes.'													, ; //X6_DESC1
	'grupo de clientes.'													, ; //X6_DSCSPA1
	'grupo de clientes.'													, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'000001/000019/000354'													, ; //X6_CONTEUD
	'000001/000019/000354'													, ; //X6_CONTSPA
	'000001/000019/000354'													, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME


//
// Atualizando dicion·rio
//
oProcess:SetRegua2( Len( aSX6 ) )

dbSelectArea( "SX6" )
dbSetOrder( 1 )

For nI := 1 To Len( aSX6 )
	lContinua := .F.
	lReclock  := .F.

	If !SX6->( dbSeek( PadR( aSX6[nI][1], nTamFil ) + PadR( aSX6[nI][2], nTamVar ) ) )
		lContinua := .T.
		lReclock  := .T.
		cTexto += "Foi incluÌdo o par‚metro " + aSX6[nI][1] + aSX6[nI][2] + " Conte˙do [" + AllTrim( aSX6[nI][13] ) + "]"+ CRLF
	EndIf

	If lContinua
		If !( aSX6[nI][1] $ cAlias )
			cAlias += aSX6[nI][1] + "/"
		EndIf

		RecLock( "SX6", lReclock )
		For nJ := 1 To Len( aSX6[nI] )
			If FieldPos( aEstrut[nJ] ) > 0
				FieldPut( FieldPos( aEstrut[nJ] ), aSX6[nI][nJ] )
			EndIf
		Next nJ
		dbCommit()
		MsUnLock()
	EndIf

	oProcess:IncRegua2( "Atualizando Arquivos (SX6)..." )

Next nI

cTexto += CRLF + "Final da Atualizacao" + " SX6" + CRLF + Replicate( "-", 128 ) + CRLF + CRLF

Return NIL
/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫ Programa ≥ FSAtuSX5 ∫ Autor ≥ TOTVS Protheus     ∫ Data ≥  13/07/12   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫ Descricao≥ Funcao de processamento da gravacao do SX5 - Indices       ≥±±
±±∫          ≥                                                            ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±≥ Uso      ≥ FSAtuSX5   - Gerado por EXPORDIC / Upd. V.4.10.4 EFS       ≥±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Static Function FSAtuSX5( cTexto )
Local aEstrut   := {}
Local aSX5      := {}
Local cAlias    := ""
Local nI        := 0
Local nJ        := 0

cTexto  += "Inicio Atualizacao SX5" + CRLF + CRLF

aEstrut := { "X5_FILIAL", "X5_TABELA", "X5_CHAVE", "X5_DESCRI", "X5_DESCSPA", "X5_DESCENG" }

 
//
// Tabela 01ZS
//
aAdd( aSX5, { ;
	'01'																	, ; //X5_FILIAL
	'ZS'																	, ; //X5_TABELA
	'000001'																, ; //X5_CHAVE
	'TELEVENDAS'	 														, ; //X5_DESCRI
	'TELEVENDAS'  															, ; //X5_DESCSPA
	'TELEVENDAS'															} ) //X5_DESCENG

aAdd( aSX5, { ;
	'01'																	, ; //X5_FILIAL
	'ZS'																	, ; //X5_TABELA
	'000002'																, ; //X5_CHAVE
	'APOIO'																	, ; //X5_DESCRI
	'APOIO'																	, ; //X5_DESCSPA
	'APOIO'																	} ) //X5_DESCENG
                        	
aAdd( aSX5, { ;
	'01'																	, ; //X5_FILIAL
	'ZS'																	, ; //X5_TABELA
	'000003'																, ; //X5_CHAVE
	'LICITACOES'															, ; //X5_DESCRI
	'LICITACOES'															, ; //X5_DESCSPA
	'LICITACOES'															} ) //X5_DESCENG

aAdd( aSX5, { ;
	'01'																	, ; //X5_FILIAL
	'ZS'																	, ; //X5_TABELA
	'000004'																, ; //X5_CHAVE
	'CLIENTES'																, ; //X5_DESCRI
	'CLIENTES'																, ; //X5_DESCSPA
	'CLIENTES'																} ) //X5_DESCENG

aAdd( aSX5, { ;
	'01'																	, ; //X5_FILIAL
	'ZS'																	, ; //X5_TABELA
	'000005'																, ; //X5_CHAVE
	'TRANSPORTE'															, ; //X5_DESCRI
	'TRANSPORTE'															, ; //X5_DESCSPA
	'TRANSPORTE'															} ) //X5_DESCENG

aAdd( aSX5, { ;
	'01'																	, ; //X5_FILIAL
	'ZS'																	, ; //X5_TABELA
	'000006'																, ; //X5_CHAVE
	'RECEBIMENTO-CD'														, ; //X5_DESCRI
	'RECEBIMENTO-CD'														, ; //X5_DESCSPA
	'RECEBIMENTO-CD'														} ) //X5_DESCENG
aAdd( aSX5, { ;
	'01'																	, ; //X5_FILIAL
	'ZS'																	, ; //X5_TABELA
	'000007'																, ; //X5_CHAVE
	'ARMAZENAMENTO-CD'														, ; //X5_DESCRI
	'ARMAZENAMENTO-CD'														, ; //X5_DESCSPA
	'ARMAZENAMENTO-CD'														} ) //X5_DESCENG
aAdd( aSX5, { ;
	'01'																	, ; //X5_FILIAL
	'ZS'																	, ; //X5_TABELA
	'000008'																, ; //X5_CHAVE
	'EXPEDICAO-CD'															, ; //X5_DESCRI
	'EXPEDICAO-CD'															, ; //X5_DESCSPA
	'EXPEDICAO-CD'															} ) //X5_DESCENG
aAdd( aSX5, { ;
	'01'																	, ; //X5_FILIAL
	'ZS'																	, ; //X5_TABELA
	'000009'																, ; //X5_CHAVE
	'FORNECEDOR'															, ; //X5_DESCRI
	'FORNECEDOR'															, ; //X5_DESCSPA
	'FORNECEDOR'															} ) //X5_DESCENG
	
 
//
// Tabela 04ZS
//
aAdd( aSX5, { ;
	'04'																	, ; //X5_FILIAL
	'ZS'																	, ; //X5_TABELA
	'000001'																, ; //X5_CHAVE
	'TELEVENDAS'	 														, ; //X5_DESCRI
	'TELEVENDAS'  															, ; //X5_DESCSPA
	'TELEVENDAS'															} ) //X5_DESCENG

aAdd( aSX5, { ;
	'04'																	, ; //X5_FILIAL
	'ZS'																	, ; //X5_TABELA
	'000002'																, ; //X5_CHAVE
	'APOIO'																	, ; //X5_DESCRI
	'APOIO'																	, ; //X5_DESCSPA
	'APOIO'																	} ) //X5_DESCENG
                        	
aAdd( aSX5, { ;
	'04'																	, ; //X5_FILIAL
	'ZS'																	, ; //X5_TABELA
	'000003'																, ; //X5_CHAVE
	'LICITACOES'															, ; //X5_DESCRI
	'LICITACOES'															, ; //X5_DESCSPA
	'LICITACOES'															} ) //X5_DESCENG

aAdd( aSX5, { ;
	'04'																	, ; //X5_FILIAL
	'ZS'																	, ; //X5_TABELA
	'000004'																, ; //X5_CHAVE
	'CLIENTES'																, ; //X5_DESCRI
	'CLIENTES'																, ; //X5_DESCSPA
	'CLIENTES'																} ) //X5_DESCENG

aAdd( aSX5, { ;
	'04'																	, ; //X5_FILIAL
	'ZS'																	, ; //X5_TABELA
	'000005'																, ; //X5_CHAVE
	'TRANSPORTE'															, ; //X5_DESCRI
	'TRANSPORTE'															, ; //X5_DESCSPA
	'TRANSPORTE'															} ) //X5_DESCENG

aAdd( aSX5, { ;
	'04'																	, ; //X5_FILIAL
	'ZS'																	, ; //X5_TABELA
	'000006'																, ; //X5_CHAVE
	'RECEBIMENTO-CD'														, ; //X5_DESCRI
	'RECEBIMENTO-CD'														, ; //X5_DESCSPA
	'RECEBIMENTO-CD'														} ) //X5_DESCENG
aAdd( aSX5, { ;
	'04'																	, ; //X5_FILIAL
	'ZS'																	, ; //X5_TABELA
	'000007'																, ; //X5_CHAVE
	'ARMAZENAMENTO-CD'														, ; //X5_DESCRI
	'ARMAZENAMENTO-CD'														, ; //X5_DESCSPA
	'ARMAZENAMENTO-CD'														} ) //X5_DESCENG
aAdd( aSX5, { ;
	'04'																	, ; //X5_FILIAL
	'ZS'																	, ; //X5_TABELA
	'000008'																, ; //X5_CHAVE
	'EXPEDICAO-CD'															, ; //X5_DESCRI
	'EXPEDICAO-CD'															, ; //X5_DESCSPA
	'EXPEDICAO-CD'															} ) //X5_DESCENG
aAdd( aSX5, { ;
	'04'																	, ; //X5_FILIAL
	'ZS'																	, ; //X5_TABELA
	'000009'																, ; //X5_CHAVE
	'FORNECEDOR'															, ; //X5_DESCRI
	'FORNECEDOR'															, ; //X5_DESCSPA
	'FORNECEDOR'															} ) //X5_DESCENG
		
	

//
// Atualizando dicion·rio
//
oProcess:SetRegua2( Len( aSX5 ) )

dbSelectArea( "SX5" )
SX5->( dbSetOrder( 1 ) )

For nI := 1 To Len( aSX5 )

	oProcess:IncRegua2( "Atualizando tabelas..." )

	If !SX5->( dbSeek( aSX5[nI][1] + aSX5[nI][2] + aSX5[nI][3]) )
		cTexto += "Item da tabela criado. Tabela " + AllTrim( aSX5[nI][1] ) + aSX5[nI][2] + "/" + aSX5[nI][3] + CRLF
		RecLock( "SX5", .T. )
	Else
		cTexto += "Item da tabela alterado. Tabela " + AllTrim( aSX5[nI][1] ) + aSX5[nI][2] + "/" + aSX5[nI][3] + CRLF
		RecLock( "SX5", .F. )
	EndIf

	For nJ := 1 To Len( aSX5[nI] )
		If FieldPos( aEstrut[nJ] ) > 0
			FieldPut( FieldPos( aEstrut[nJ] ), aSX5[nI][nJ] )
		EndIf
	Next nJ

	MsUnLock()

	aAdd( aArqUpd, aSX5[nI][1] )

	If !( aSX5[nI][1] $ cAlias )
		cAlias += aSX5[nI][1] + "/"
	EndIf

Next nI

cTexto += CRLF + "Final da Atualizacao" + " SX5" + CRLF + Replicate( "-", 128 ) + CRLF + CRLF

Return NIL
/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫ Programa ≥ FSAtuSX7 ∫ Autor ≥ TOTVS Protheus     ∫ Data ≥  17/07/12   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫ Descricao≥ Funcao de processamento da gravacao do SX7 - Gatilhos      ≥±±
±±∫          ≥                                                            ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±≥ Uso      ≥ FSAtuSX7   - Gerado por EXPORDIC / Upd. V.4.10.4 EFS       ≥±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Static Function FSAtuSX7( cTexto )
Local aEstrut   := {}
Local aSX7      := {}
Local cAlias    := ""
Local nI        := 0
Local nJ        := 0
Local nTamSeek  := Len( SX7->X7_CAMPO )

cTexto  += "Inicio da Atualizacao" + " SX7" + CRLF + CRLF

aEstrut := { "X7_CAMPO", "X7_SEQUENC", "X7_REGRA", "X7_CDOMIN", "X7_TIPO", "X7_SEEK", ;
             "X7_ALIAS", "X7_ORDEM"  , "X7_CHAVE", "X7_PROPRI", "X7_CONDIC" }


//
// Atualizando dicion·rio
//
                       

//
// Campo ZZF_CODCLI
//
aAdd( aSX7, { ;
	'ZZF_CODCLI'															, ; //X7_CAMPO
	'001'																	, ; //X7_SEQUENC
	'IIf(Empty(SA1->A1_LOJA),"01",SA1->A1_LOJA)'							, ; //X7_REGRA
	'ZZF_LOJA'																, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'N'																		, ; //X7_SEEK
	''																		, ; //X7_ALIAS
	0																		, ; //X7_ORDEM
	''																		, ; //X7_CHAVE
	'U'																		, ; //X7_PROPRI
	''																		} ) //X7_CONDIC

aAdd( aSX7, { ;
	'ZZF_CODCLI'															, ; //X7_CAMPO
	'002'																	, ; //X7_SEQUENC
	'SA1->A1_NOME'															, ; //X7_REGRA
	'ZZF_NOMCLI'															, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'S'																		, ; //X7_SEEK
	'SA1'																	, ; //X7_ALIAS
	1																		, ; //X7_ORDEM
	'xFilial("SA1")+M->(ZZF_CODCLI+ZZF_LOJA)'								, ; //X7_CHAVE
	'U'																		, ; //X7_PROPRI
	''																		} ) //X7_CONDIC

aAdd( aSX7, { ;
	'ZZF_GRPVEN'															, ; //X7_CAMPO
	'001'																	, ; //X7_SEQUENC
	'ACY->ACY_DESCRI'														, ; //X7_REGRA
	'ZZF_GRPDES'															, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'S'																		, ; //X7_SEEK
	'ACY'																	, ; //X7_ALIAS
	1																		, ; //X7_ORDEM
	'xFilial("ACY")+ZZF->ZZF_GRPVEN'										, ; //X7_CHAVE
	'U'																		, ; //X7_PROPRI
	''																		} ) //X7_CONDIC

aAdd( aSX7, { ;
	'ZZF_ATIVO'				  												, ; //X7_CAMPO
	'001'																	, ; //X7_SEQUENC
	'UsrFullName(RetCodUsr())'												, ; //X7_REGRA
	'ZZF_USUAPR'															, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'N'																		, ; //X7_SEEK
	''																		, ; //X7_ALIAS
	0																		, ; //X7_ORDEM
	''																		, ; //X7_CHAVE
	'U'																		, ; //X7_PROPRI
	'Empty(M->ZZF_USUAPR)'													} ) //X7_CONDIC	
	
aAdd( aSX7, { ;
	'ZZG_PRODUT'															, ; //X7_CAMPO
	'001'																	, ; //X7_SEQUENC
	'SB1->B1_DESC'															, ; //X7_REGRA
	'ZZG_DESCRI'															, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'S'																		, ; //X7_SEEK
	'SB1'									 								, ; //X7_ALIAS
	1																		, ; //X7_ORDEM
	'xFilial("SB1")+AllTrim(M->ZZG_PRODUT)'									, ; //X7_CHAVE
	'U'																		, ; //X7_PROPRI
	''																		} ) //X7_CONDIC   
	
aAdd( aSX7, { ;
	'C6_PRODUTO'															, ; //X7_CAMPO
	'030'																	, ; //X7_SEQUENC
	'U_C6PrcCust(M->C5_CLIENTE,M->C6_PRCVEN)'								, ; //X7_REGRA
	'C6_PRCVEN'																, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'N'																		, ; //X7_SEEK
	''																		, ; //X7_ALIAS
	0																		, ; //X7_ORDEM
	''																		, ; //X7_CHAVE
	'U'																		, ; //X7_PROPRI
	''																		} ) //X7_CONDIC	
	
//
// Campo ZZM_VALCIF
//
aAdd( aSX7, { ;
	'ZZM_VALCIF'															, ; //X7_CAMPO
	'001'																	, ; //X7_SEQUENC
	'u_DipCalCus()'															, ; //X7_REGRA
	'ZZM_VALCUS'															, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'N'																		, ; //X7_SEEK
	''																		, ; //X7_ALIAS
	0																		, ; //X7_ORDEM
	''																		, ; //X7_CHAVE
	'U'																		, ; //X7_PROPRI
	''																		} ) //X7_CONDIC

//
// Campo ZZM_VALII
//
aAdd( aSX7, { ;
	'ZZM_VALII'																, ; //X7_CAMPO
	'002'																	, ; //X7_SEQUENC
	'u_DipCalCus()'															, ; //X7_REGRA
	'ZZM_VALCUS'															, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'N'																		, ; //X7_SEEK
	''																		, ; //X7_ALIAS
	0																		, ; //X7_ORDEM
	''																		, ; //X7_CHAVE
	'U'																		, ; //X7_PROPRI
	''																		} ) //X7_CONDIC

If SX7->(dbSeek("C5_TPFRETE001"))
	aAdd( aSX7, { ;
		SX7->X7_CAMPO															, ; //X7_CAMPO
		SX7->X7_SEQUENC															, ; //X7_SEQUENC
		SX7->X7_REGRA															, ; //X7_REGRA
		SX7->X7_CDOMIN															, ; //X7_CDOMIN
		SX7->X7_TIPO															, ; //X7_TIPO
		SX7->X7_SEEK															, ; //X7_SEEK
		SX7->X7_ALIAS															, ; //X7_ALIAS
		SX7->X7_ORDEM															, ; //X7_ORDEM
		SX7->X7_CHAVE															, ; //X7_CHAVE
		SX7->X7_PROPRI															, ; //X7_PROPRI
		'(!"DIPAL10"$FUNNAME()) .And. u_DipV410()'								} ) //X7_CONDIC
EndIf

If SX7->(dbSeek("C5_TRANSP 001"))
	aAdd( aSX7, { ;
		SX7->X7_CAMPO															, ; //X7_CAMPO
		SX7->X7_SEQUENC															, ; //X7_SEQUENC
		SX7->X7_REGRA															, ; //X7_REGRA
		SX7->X7_CDOMIN															, ; //X7_CDOMIN
		SX7->X7_TIPO															, ; //X7_TIPO
		SX7->X7_SEEK															, ; //X7_SEEK
		SX7->X7_ALIAS															, ; //X7_ALIAS
		SX7->X7_ORDEM															, ; //X7_ORDEM
		SX7->X7_CHAVE															, ; //X7_CHAVE
		SX7->X7_PROPRI															, ; //X7_PROPRI
		'(!"DIPAL10"$FUNNAME()) .And. u_DipV410()'								} ) //X7_CONDIC
EndIf

If SX7->(dbSeek("C6_QTDVEN 002"))
	aAdd( aSX7, { ;
		SX7->X7_CAMPO															, ; //X7_CAMPO
		SX7->X7_SEQUENC															, ; //X7_SEQUENC
		SX7->X7_REGRA															, ; //X7_REGRA
		SX7->X7_CDOMIN															, ; //X7_CDOMIN
		SX7->X7_TIPO															, ; //X7_TIPO
		SX7->X7_SEEK															, ; //X7_SEEK
		SX7->X7_ALIAS															, ; //X7_ALIAS
		SX7->X7_ORDEM															, ; //X7_ORDEM
		SX7->X7_CHAVE															, ; //X7_CHAVE
		SX7->X7_PROPRI															, ; //X7_PROPRI
		'(!"DIPAL10"$FUNNAME()) .And. u_DipV410()'								} ) //X7_CONDIC
EndIf

If SX7->(dbSeek("C6_QTDVEN 007"))
	aAdd( aSX7, { ;
		SX7->X7_CAMPO															, ; //X7_CAMPO
		SX7->X7_SEQUENC															, ; //X7_SEQUENC
		SX7->X7_REGRA															, ; //X7_REGRA
		SX7->X7_CDOMIN															, ; //X7_CDOMIN
		SX7->X7_TIPO															, ; //X7_TIPO
		SX7->X7_SEEK															, ; //X7_SEEK
		SX7->X7_ALIAS															, ; //X7_ALIAS
		SX7->X7_ORDEM															, ; //X7_ORDEM
		SX7->X7_CHAVE															, ; //X7_CHAVE
		SX7->X7_PROPRI															, ; //X7_PROPRI
		'(!"DIPAL10"$FUNNAME()) .And. u_DipV410()'								} ) //X7_CONDIC
EndIf

//
// Campo ZZG_CUSTO
//
aAdd( aSX7, { ;
	'ZZG_CUSTO'																, ; //X7_CAMPO
	'002'																	, ; //X7_SEQUENC
	'(M->ZZG_VALOR/M->ZZG_CUSTO-1)*100'										, ; //X7_REGRA
	'ZZG_MARGEM'															, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'N'																		, ; //X7_SEEK
	''																		, ; //X7_ALIAS
	0																		, ; //X7_ORDEM
	''																		, ; //X7_CHAVE
	'U'																		, ; //X7_PROPRI
	'M->ZZG_VALOR>0'														} ) //X7_CONDIC

//
// Campo ZZG_PRODUT
//
aAdd( aSX7, { ;
	'ZZG_PRODUT'															, ; //X7_CAMPO
	'002'																	, ; //X7_SEQUENC
	'SB1->B1_PRVSUPE'														, ; //X7_REGRA
	'ZZG_PRVSUP'															, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'S'																		, ; //X7_SEEK
	'SB1'																	, ; //X7_ALIAS
	1																		, ; //X7_ORDEM
	'xFilial("SB1")+AllTrim(M->ZZG_PRODUT)'									, ; //X7_CHAVE
	'U'																		, ; //X7_PROPRI
	''																		} ) //X7_CONDIC

aAdd( aSX7, { ;
	'ZZG_PRODUT'															, ; //X7_CAMPO
	'003'																	, ; //X7_SEQUENC
	'SB1->B1_PRVMINI'														, ; //X7_REGRA
	'ZZG_PRVMIN'															, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'S'																		, ; //X7_SEEK
	'SB1'																	, ; //X7_ALIAS
	1																		, ; //X7_ORDEM
	'xFilial("SB1")+AllTrim(M->ZZG_PRODUT)'									, ; //X7_CHAVE
	'U'																		, ; //X7_PROPRI
	''																		} ) //X7_CONDIC

aAdd( aSX7, { ;
	'ZZG_PRODUT'															, ; //X7_CAMPO
	'004'																	, ; //X7_SEQUENC
	'SB1->B1_LISFOR'														, ; //X7_REGRA
	'ZZG_CUSTO'			  													, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'S'																		, ; //X7_SEEK
	'SB1'																	, ; //X7_ALIAS
	1																		, ; //X7_ORDEM
	'xFilial("SB1")+AllTrim(M->ZZG_PRODUT)'									, ; //X7_CHAVE
	'U'																		, ; //X7_PROPRI
	'SB1->B1_PROC$"000996/000997"'											} ) //X7_CONDIC

//
// Campo ZZG_VALOR
//
aAdd( aSX7, { ;
	'ZZG_VALOR'																, ; //X7_CAMPO
	'001'																	, ; //X7_SEQUENC
	'(M->ZZG_VALOR/M->ZZG_CUSTO-1)*100'										, ; //X7_REGRA
	'ZZG_MARGEM'															, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'N'																		, ; //X7_SEEK
	''																		, ; //X7_ALIAS
	0																		, ; //X7_ORDEM
	''																		, ; //X7_CHAVE
	'U'																		, ; //X7_PROPRI
	'M->ZZG_CUSTO>0'														} ) //X7_CONDIC


//
// Campo G1_COMP
//
aAdd( aSX7, { ;
	'G1_COMP'																, ; //X7_CAMPO
	'001'																	, ; //X7_SEQUENC
	'POSICIONE("SB1", 1, xFilial("SB1") + M->G1_COMP, "B1_UM")'				, ; //X7_REGRA
	'G1_X1UM'																, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'N'																		, ; //X7_SEEK
	''																		, ; //X7_ALIAS
	0																		, ; //X7_ORDEM
	''																		, ; //X7_CHAVE
	'U'																		, ; //X7_PROPRI
	''																		} ) //X7_CONDIC

aAdd( aSX7, { ;
	'G1_COMP'																, ; //X7_CAMPO
	'002'																	, ; //X7_SEQUENC
	'POSICIONE("SB1", 1, xFilial("SB1") + M->G1_COMP, "B1_SEGUM")'			, ; //X7_REGRA
	'G1_X2UM'																, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'N'																		, ; //X7_SEEK
	''																		, ; //X7_ALIAS
	0																		, ; //X7_ORDEM
	''																		, ; //X7_CHAVE
	'U'																		, ; //X7_PROPRI
	''																		} ) //X7_CONDIC

//
// Campo G1_QUANT
/*/
aAdd( aSX7, { ;
	'G1_QUANT'																, ; //X7_CAMPO
	'001'																	, ; //X7_SEQUENC
	'iif(ALLTRIM(SB1->B1_TIPCONV)=="M",(M->G1_QUANT*SB1->B1_CONV),0)'		, ; //X7_REGRA
	'G1_XQTD2'																, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'N'																		, ; //X7_SEEK
	''																		, ; //X7_ALIAS
	0																		, ; //X7_ORDEM
	''																		, ; //X7_CHAVE
	'U'																		, ; //X7_PROPRI
	'ALLTRIM(SB1->B1_TIPCONV)=="M"'										} ) //X7_CONDIC

aAdd( aSX7, { ;
	'G1_QUANT'																, ; //X7_CAMPO
	'002'																	, ; //X7_SEQUENC
	'iif(SB1->B1_TIPCONV=="D",M->G1_QUANT/SB1->B1_CONV,0)'				, ; //X7_REGRA
	'G1_XQTD2'																, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'N'																		, ; //X7_SEEK
	''																		, ; //X7_ALIAS
	0																		, ; //X7_ORDEM
	''																		, ; //X7_CHAVE
	'U'																		, ; //X7_PROPRI
	'ALLTRIM(SB1->B1_TIPCONV)=="D"'										} ) //X7_CONDIC

*/
//
// Campo G1_XQTD2
//                           

aAdd( aSX7, { ;
	'G1_XQTD2'																, ; //X7_CAMPO
	'001'																	, ; //X7_SEQUENC
	'U_G1PCP(SG1->G1_COD,@0)'												, ; //X7_REGRA
	'G1_QUANT'																, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'N'																		, ; //X7_SEEK
	''																		, ; //X7_ALIAS
	0																		, ; //X7_ORDEM
	''																		, ; //X7_CHAVE
	'U'																		, ; //X7_PROPRI
	''																		} ) //X7_CONDIC
	
//
// Campo ZZP_LOTECT
//
aAdd( aSX7, { ;
	'ZZP_LOTECT'															, ; //X7_CAMPO
	'001'																	, ; //X7_SEQUENC
	'SB8->B8_DTVALID'														, ; //X7_REGRA
	'ZZP_DTVALI'															, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'S'																		, ; //X7_SEEK
	'SB8'																	, ; //X7_ALIAS
	5																		, ; //X7_ORDEM
	'xFilial("SB8")+(M->ZZP_PRODUT+M->ZZP_LOTECT)'							, ; //X7_CHAVE
	'U'																		, ; //X7_PROPRI
	''																		} ) //X7_CONDIC

aAdd( aSX7, { ;
	'ZZQ_CODCO1'															, ; //X7_CAMPO
	'001'																	, ; //X7_SEQUENC
	'SX5->X5_DESCRI'														, ; //X7_REGRA
	'ZZQ_NOMCO1'															, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'S'																		, ; //X7_SEEK
	'SX5'																	, ; //X7_ALIAS
	1																		, ; //X7_ORDEM
	'xFilial("SX5")+"ZX"+M->ZZQ_CODCO1'										, ; //X7_CHAVE
	'U'																		, ; //X7_PROPRI
	''																		} ) //X7_CONDIC

aAdd( aSX7, { ;
	'ZZQ_CODCO2'															, ; //X7_CAMPO
	'001'																	, ; //X7_SEQUENC
	'SX5->X5_DESCRI'														, ; //X7_REGRA
	'ZZQ_NOMCO2'															, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'S'																		, ; //X7_SEEK
	'SX5'																	, ; //X7_ALIAS
	1																		, ; //X7_ORDEM
	'xFilial("SX5")+"ZX"+M->ZZQ_CODCO2'										, ; //X7_CHAVE
	'U'																		, ; //X7_PROPRI
	''																		} ) //X7_CONDIC

aAdd( aSX7, { ;
	'UC_CODCONT'															, ; //X7_CAMPO
	'004'																	, ; //X7_SEQUENC
	'SU5->U5_LOJA'															, ; //X7_REGRA
	'UC_LOJA'																, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'S'																		, ; //X7_SEEK
	'SU5'																	, ; //X7_ALIAS
	1																		, ; //X7_ORDEM
	'xFilial("SU5")+M->UC_CODCONT'											, ; //X7_CHAVE
	'U'																		, ; //X7_PROPRI
	'!Empty(M->UC_CODCONT)'													} ) //X7_CONDIC
	
aAdd( aSX7, { ;
	'D1_COD'																, ; //X7_CAMPO
	'005'																	, ; //X7_SEQUENC
	'SB1->B1_POSIPI'														, ; //X7_REGRA
	'D1_XPOSIPI'															, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'S'																		, ; //X7_SEEK
	'SB1'																	, ; //X7_ALIAS
	1																		, ; //X7_ORDEM
	'xFilial("SB1")+M->D1_COD'												, ; //X7_CHAVE
	'U'																		, ; //X7_PROPRI
	'!Empty(M->D1_COD)'														} ) //X7_CONDIC	

aAdd( aSX7, { ;
	'D1_COD'																, ; //X7_CAMPO
	'006'																	, ; //X7_SEQUENC
	'SB1->B1_ORIGEM'														, ; //X7_REGRA
	'D1_XORIGEM'															, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'S'																		, ; //X7_SEEK
	'SB1'																	, ; //X7_ALIAS
	1																		, ; //X7_ORDEM
	'xFilial("SB1")+M->D1_COD'												, ; //X7_CHAVE
	'U'																		, ; //X7_PROPRI
	'!Empty(M->D1_COD)'														} ) //X7_CONDIC	


//
// Campo ZZO_PRODUT
//
aAdd( aSX7, { ;
	'ZZO_PRODUT'															, ; //X7_CAMPO
	'001'																	, ; //X7_SEQUENC
	'SB1->B1_DESC'															, ; //X7_REGRA
	'ZZO_DESCRI'															, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'S'																		, ; //X7_SEEK
	'SB1'																	, ; //X7_ALIAS
	1																		, ; //X7_ORDEM
	'xFilial("SB1")+M->ZZO_PRODUT'											, ; //X7_CHAVE
	'U'																		, ; //X7_PROPRI
	''																		} ) //X7_CONDIC

aAdd( aSX7, { ;
	'ZZO_PRODUT'															, ; //X7_CAMPO
	'002'																	, ; //X7_SEQUENC
	'IIf(SB1->B1_PRVSUPE>0,SB1->B1_PRVSUPE,SB1->B1_PRVMINI)'				, ; //X7_REGRA
	'ZZO_VLRUNI'															, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'S'																		, ; //X7_SEEK
	'SB1'																	, ; //X7_ALIAS
	1																		, ; //X7_ORDEM
	'xFilial("SB1")+M->ZZO_PRODUT'											, ; //X7_CHAVE
	'U'																		, ; //X7_PROPRI
	''																		} ) //X7_CONDIC

//
// Campo ZZO_QUANT
//
aAdd( aSX7, { ;
	'ZZO_QUANT'																, ; //X7_CAMPO
	'003'																	, ; //X7_SEQUENC
	'ROUND(M->ZZO_QUANT*M->ZZO_VLRUNI,2)'									, ; //X7_REGRA
	'ZZO_VLRTOT'															, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'N'																		, ; //X7_SEEK
	''																		, ; //X7_ALIAS
	0																		, ; //X7_ORDEM
	''																		, ; //X7_CHAVE
	'U'																		, ; //X7_PROPRI
	''																		} ) //X7_CONDIC

If cEmpAnt=="01"
	aAdd( aSX7, { ;
		'C6_QTDVEN'																, ; //X7_CAMPO
		'012'																	, ; //X7_SEQUENC     
		'IF(SB1->B1_PICMRET <> 0 .AND. SA1->A1_EST = "SP","625",M->C6_TES)'		, ; //X7_REGRA
		'C6_TES'																, ; //X7_CDOMIN
		'P'																		, ; //X7_TIPO
		'N'																		, ; //X7_SEEK
		''																		, ; //X7_ALIAS
		0																		, ; //X7_ORDEM
		''																		, ; //X7_CHAVE
		'U'																		, ; //X7_PROPRI
		''																		} ) //X7_CONDIC
	                                                                                       
	aAdd( aSX7, { ;
		'C6_QTDVEN'																, ; //X7_CAMPO
		'013'																	, ; //X7_SEQUENC
		'IF(SB1->B1_PICMRET <> 0 .AND. SA1->A1_EST = "SP","5405",M->C6_CF)'		, ; //X7_REGRA
		'C6_CF'																	, ; //X7_CDOMIN
		'P'																		, ; //X7_TIPO
		'N'																		, ; //X7_SEEK
		''																		, ; //X7_ALIAS
		0																		, ; //X7_ORDEM
		''																		, ; //X7_CHAVE
		'U'																		, ; //X7_PROPRI
		''																		} ) //X7_CONDIC
ElseIf cEmpAnt=="04"
	aAdd( aSX7, { ;
		'C6_QTDVEN'																, ; //X7_CAMPO
		'012'																	, ; //X7_SEQUENC     
		'M->C6_TES'																, ; //X7_REGRA
		'C6_TES'																, ; //X7_CDOMIN
		'P'																		, ; //X7_TIPO
		'N'																		, ; //X7_SEEK
		''																		, ; //X7_ALIAS
		0																		, ; //X7_ORDEM
		''																		, ; //X7_CHAVE
		'U'																		, ; //X7_PROPRI
		''																		} ) //X7_CONDIC
	                                                                                       
	aAdd( aSX7, { ;
		'C6_QTDVEN'																, ; //X7_CAMPO
		'013'																	, ; //X7_SEQUENC
		'M->C6_CF'																, ; //X7_REGRA
		'C6_CF'																	, ; //X7_CDOMIN
		'P'																		, ; //X7_TIPO
		'N'																		, ; //X7_SEEK
		''																		, ; //X7_ALIAS
		0																		, ; //X7_ORDEM
		''																		, ; //X7_CHAVE
		'U'																		, ; //X7_PROPRI
		''																		} ) //X7_CONDIC
EndIf
		
aAdd( aSX7, { ;
	'C6_QTDVEN'																, ; //X7_CAMPO
	'015'																	, ; //X7_SEQUENC
	'U_VldTesCF(M->C6_TES)'													, ; //X7_REGRA
	'C6_TES'																, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'N'																		, ; //X7_SEEK
	''																		, ; //X7_ALIAS
	0																		, ; //X7_ORDEM
	''																		, ; //X7_CHAVE
	'U'																		, ; //X7_PROPRI
	''																		} ) //X7_CONDIC

aAdd( aSX7, { ;
	'C6_PRODUTO'															, ; //X7_CAMPO
	'031'																	, ; //X7_SEQUENC
	'U_VldTesCF(M->C6_TES)'													, ; //X7_REGRA
	'C6_TES'													  			, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'N'																		, ; //X7_SEEK
	''																		, ; //X7_ALIAS
	0																		, ; //X7_ORDEM
	''																		, ; //X7_CHAVE
	'U'																		, ; //X7_PROPRI
	''																		} ) //X7_CONDIC

aAdd( aSX7, { ;
	'C6_TES'										  						, ; //X7_CAMPO
	'019'																	, ; //X7_SEQUENC
	'U_VldTesCF(M->C6_TES)'													, ; //X7_REGRA
	'C6_TES'													  			, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'N'																		, ; //X7_SEEK
	''																		, ; //X7_ALIAS
	0																		, ; //X7_ORDEM
	''																		, ; //X7_CHAVE
	'U'																		, ; //X7_PROPRI
	''																		} ) //X7_CONDIC
	
aAdd( aSX7, { ;
	'C5_CLIENTE'															, ; //X7_CAMPO
	'026'																	, ; //X7_SEQUENC
	'IIf(SA1->A1_GRPVEN$"000099/000001/000076/000079/000118/000119/000120/000134","BB2","")', ; //X7_REGRA
	'C5_MENPAD'													  			, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'N'																		, ; //X7_SEEK
	''																		, ; //X7_ALIAS
	0																		, ; //X7_ORDEM
	''																		, ; //X7_CHAVE
	'U'																		, ; //X7_PROPRI
	'INCLUI .AND. cEmpAnt=="01"'											} ) //X7_CONDIC

aAdd( aSX7, { ;
	'D1_COD'																, ; //X7_CAMPO
	'007'																	, ; //X7_SEQUENC
	'U_VldTesD1(M->D1_TES)'													, ; //X7_REGRA
	'D1_TES'																, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'N'																		, ; //X7_SEEK
	''																		, ; //X7_ALIAS
	0																		, ; //X7_ORDEM
	''																		, ; //X7_CHAVE
	'U'																		, ; //X7_PROPRI
	'!(AllTrim(FUNNAME())$"NFAC003/MATA140")'								} ) //X7_CONDIC

aAdd( aSX7, { ;
	'D1_QUANT'																, ; //X7_CAMPO
	'005'																	, ; //X7_SEQUENC
	'U_VldTesD1(M->D1_TES)'													, ; //X7_REGRA
	'D1_TES'																, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'N'																		, ; //X7_SEEK
	''																		, ; //X7_ALIAS
	0																		, ; //X7_ORDEM
	''																		, ; //X7_CHAVE
	'U'																		, ; //X7_PROPRI
	'!(AllTrim(FUNNAME())$"NFAC003/MATA140")'								} ) //X7_CONDIC

aAdd( aSX7, { ;
	'D1_TES'																, ; //X7_CAMPO
	'004'																	, ; //X7_SEQUENC
	'U_VldTesD1(M->D1_TES)'													, ; //X7_REGRA
	'D1_TES'																, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'N'																		, ; //X7_SEEK
	''																		, ; //X7_ALIAS
	0																		, ; //X7_ORDEM
	''																		, ; //X7_CHAVE
	'U'																		, ; //X7_PROPRI
	'!(AllTrim(FUNNAME())$"NFAC003/MATA140")'								} ) //X7_CONDIC

aAdd( aSX7, { ;
	'D1_VUNIT'																, ; //X7_CAMPO
	'006'																	, ; //X7_SEQUENC
	'U_VldTesD1(M->D1_TES)'													, ; //X7_REGRA
	'D1_TES'																, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'N'																		, ; //X7_SEEK
	''																		, ; //X7_ALIAS
	0																		, ; //X7_ORDEM
	''																		, ; //X7_CHAVE
	'U'																		, ; //X7_PROPRI
	'!(AllTrim(FUNNAME())$"NFAC003/MATA140")'								} ) //X7_CONDIC			
	
aAdd( aSX7, { ;
	'D1_COD'																, ; //X7_CAMPO
	'008'																	, ; //X7_SEQUENC
	'"02"'																	, ; //X7_REGRA
	'D1_LOCAL'																, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'N'																		, ; //X7_SEEK
	''																		, ; //X7_ALIAS
	0																		, ; //X7_ORDEM
	''																		, ; //X7_CHAVE
	'U'																		, ; //X7_PROPRI
	'cEmpAnt+cFilAnt=="0401"'												} ) //X7_CONDIC		
	
//
//TABELA SC2
//	
	
aAdd( aSX7, { ;
	'C2_PRODUTO'															, ; //X7_CAMPO
	'001'																	, ; //X7_SEQUENC
	'"02"'																	, ; //X7_REGRA
	'C2_LOCAL'																, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'N'																		, ; //X7_SEEK
	''																		, ; //X7_ALIAS
	0																		, ; //X7_ORDEM
	''																		, ; //X7_CHAVE
	'U'																		, ; //X7_PROPRI
	'Substr(C2_PRODUTO,1,1)=="2"'											} ) //X7_CONDIC			

	
aAdd( aSX7, { ;
	'C2_PRODUTO'															, ; //X7_CAMPO
	'002'																	, ; //X7_SEQUENC
	'"04"'																	, ; //X7_REGRA
	'C2_LOCAL'																, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'N'																		, ; //X7_SEEK
	''																		, ; //X7_ALIAS
	0																		, ; //X7_ORDEM
	''																		, ; //X7_CHAVE
	'U'																		, ; //X7_PROPRI
	'Substr(C2_PRODUTO,1,1)=="7"'											} ) //X7_CONDIC			
	
	
aAdd( aSX7, { ;
	'C2_PRODUTO'															, ; //X7_CAMPO
	'003'																	, ; //X7_SEQUENC
	'"06"'																	, ; //X7_REGRA
	'C2_LOCAL'																, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'N'																		, ; //X7_SEEK
	''																		, ; //X7_ALIAS
	0																		, ; //X7_ORDEM
	''																		, ; //X7_CHAVE
	'U'																		, ; //X7_PROPRI
	'Substr(C2_PRODUTO,1,1)=="8"'											} ) //X7_CONDIC			
             
If cEmpAnt=="01"
	aAdd( aSX7, { ;
		'C6_TES'																, ; //X7_CAMPO
		'003'																	, ; //X7_SEQUENC     
		'SB1->B1_LOCPAD'														, ; //X7_REGRA
		'C6_LOCAL'																, ; //X7_CDOMIN
		'P'																		, ; //X7_TIPO
		'N'																		, ; //X7_SEEK
		''																		, ; //X7_ALIAS
		0																		, ; //X7_ORDEM
		''																		, ; //X7_CHAVE
		'U'																		, ; //X7_PROPRI
		'!(Upper(u_DipUsr())$GetMV("ES_USERLOC"))'								} ) //X7_CONDIC
ElseIf cEmpAnt=="04"
	aAdd( aSX7, { ;
		'C6_TES'																, ; //X7_CAMPO
		'003'																	, ; //X7_SEQUENC     
		''																		, ; //X7_REGRA
		'C6_LOCAL'																, ; //X7_CDOMIN
		'P'																		, ; //X7_TIPO
		'N'																		, ; //X7_SEEK
		''																		, ; //X7_ALIAS
		0																		, ; //X7_ORDEM
		''																		, ; //X7_CHAVE
		'U'																		, ; //X7_PROPRI
		'.F.'																	} ) //X7_CONDIC
EndIf

If SX7->(dbSeek("D1_COD    005"))
	aAdd( aSX7, { ;
		SX7->X7_CAMPO															, ; //X7_CAMPO
		SX7->X7_SEQUENC															, ; //X7_SEQUENC
		SX7->X7_REGRA															, ; //X7_REGRA
		SX7->X7_CDOMIN															, ; //X7_CDOMIN
		SX7->X7_TIPO															, ; //X7_TIPO
		SX7->X7_SEEK															, ; //X7_SEEK
		SX7->X7_ALIAS															, ; //X7_ALIAS
		1																		, ; //X7_ORDEM
		SX7->X7_CHAVE															, ; //X7_CHAVE
		SX7->X7_PROPRI															, ; //X7_PROPRI
		SX7->X7_CONDIC															} ) //X7_CONDIC
EndIf
	
oProcess:SetRegua2( Len( aSX7 ) )

dbSelectArea( "SX7" )
dbSetOrder( 1 )

For nI := 1 To Len( aSX7 )

	If !SX7->( dbSeek( PadR( aSX7[nI][1], nTamSeek ) + aSX7[nI][2] ) )

		If !( aSX7[nI][1] $ cAlias )
			cAlias += aSX7[nI][1] + "/"
			cTexto += "Foi incluÌdo o gatilho " + aSX7[nI][1] + "/" + aSX7[nI][2] + CRLF
		EndIf

		RecLock( "SX7", .T. )
		For nJ := 1 To Len( aSX7[nI] )
			If FieldPos( aEstrut[nJ] ) > 0
				FieldPut( FieldPos( aEstrut[nJ] ), aSX7[nI][nJ] )
			EndIf
		Next nJ

		dbCommit()
		MsUnLock()
	Else           
		lAtu := .F.		
		For nJ := 1 To Len(aSX7[nI])
			If FieldPos(aEstrut[nJ])>0 .And. AllTrim(&("SX7->"+aEstrut[nJ]))<>AllTrim(aSX7[nI][nJ])
				lAtu := .T.
			EndIf          
			If lAtu
				Exit
			EndIf
		Next nJ

		If lAtu
			RecLock( "SX7", .F. )
			For nJ := 1 To Len( aSX7[nI] )
				If FieldPos( aEstrut[nJ] )>0 .And. AllTrim(&("SX7->"+aEstrut[nJ]))<>AllTrim(aSX7[nI][nJ])
					FieldPut( FieldPos( aEstrut[nJ] ), aSX7[nI][nJ] )
				EndIf
			Next nJ
			dbCommit()
			MsUnLock()
		EndIf
	EndIf
	oProcess:IncRegua2( "Atualizando Arquivos (SX7)..." )

Next nI

cTexto += CRLF + "Final da Atualizacao" + " SX7" + CRLF + Replicate( "-", 128 ) + CRLF + CRLF

Return NIL
/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫ Programa ≥ FSAtuSXB ∫ Autor ≥ TOTVS Protheus     ∫ Data ≥  27/08/12   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫ Descricao≥ Funcao de processamento da gravacao do SXB - Consultas Pad ≥±±
±±∫          ≥                                                            ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±≥ Uso      ≥ FSAtuSXB   - Gerado por EXPORDIC / Upd. V.4.10.4 EFS       ≥±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Static Function FSAtuSXB( cTexto )
Local aEstrut   := {}
Local aSXB      := {}
Local cAlias    := ""
Local cMsg      := ""
Local lTodosNao := .F.
Local lTodosSim := .T.
Local nI        := 0
Local nJ        := 0
Local nOpcA     := 1

cTexto  += "Inicio da Atualizacao" + " SXB" + CRLF + CRLF

aEstrut := { "XB_ALIAS",  "XB_TIPO"   , "XB_SEQ"    , "XB_COLUNA" , ;
             "XB_DESCRI", "XB_DESCSPA", "XB_DESCENG", "XB_CONTEM" }

aAdd( aSXB, { ;
	'APRSU7'																, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'DB'																	, ; //XB_COLUNA
	' '																		, ; //XB_DESCRI
	' '																		, ; //XB_DESCSPA
	' '																		, ; //XB_DESCENG
	'SU7'																	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'APRSU7'																, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Codigo'																, ; //XB_DESCRI
	'Codigo'																, ; //XB_DESCSPA
	'Codigo'																, ; //XB_DESCENG	
	' '																		} ) //XB_CONTEM

aAdd( aSXB, { ;
	'APRSU7'																, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'CNPJ'																	, ; //XB_DESCRI
	'CNPJ'																	, ; //XB_DESCSPA
	'CNPJ'																	, ; //XB_DESCENG	
	' '																		} ) //XB_CONTEM

aAdd( aSXB, { ;
	'APRSU7'																, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'03'																	, ; //XB_SEQ
	'03'																	, ; //XB_COLUNA
	'Nome'																	, ; //XB_DESCRI
	'Nome'																	, ; //XB_DESCSPA
	'Nome'																	, ; //XB_DESCENG	
	' '																		} ) //XB_CONTEM

aAdd( aSXB, { ;
	'APRSU7'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Codigo'																, ; //XB_DESCRI
	'Codigo'																, ; //XB_DESCSPA
	'Codigo'																, ; //XB_DESCENG	
	'U7_COD'																} ) //XB_CONTEM
                                                                                                
aAdd( aSXB, { ;
	'APRSU7'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Nome'																	, ; //XB_DESCRI
	'Nome'																	, ; //XB_DESCSPA
	'Nome'																	, ; //XB_DESCENG	
	'U7_NOME'																} ) //XB_CONTEM     
	
aAdd( aSXB, { ;
	'APRSU7'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'03'																	, ; //XB_COLUNA
	'CNPJ'										  							, ; //XB_DESCRI
	'CNPJ'										   							, ; //XB_DESCSPA
	'CNPJ'										  							, ; //XB_DESCENG	
	'U7_CGC'																} ) //XB_CONTEM
                                                                                                
aAdd( aSXB, { ;
	'APRSU7'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'04'																	, ; //XB_COLUNA
	'Nome'																	, ; //XB_DESCRI
	'Nome'																	, ; //XB_DESCSPA
	'Nome'																	, ; //XB_DESCENG	
	'U7_NOME'																} ) //XB_CONTEM	    
	
aAdd( aSXB, { ;
	'APRSU7'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'03'																	, ; //XB_SEQ
	'05'																	, ; //XB_COLUNA
	'Nome'																	, ; //XB_DESCRI
	'Nome'																	, ; //XB_DESCSPA
	'Nome'																	, ; //XB_DESCENG	
	'U7_NOME'																} ) //XB_CONTEM		
	
aAdd( aSXB, { ;
	'APRSU7'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'03'																	, ; //XB_SEQ
	'06'																	, ; //XB_COLUNA
	'Codigo'																, ; //XB_DESCRI
	'Codigo'																, ; //XB_DESCSPA
	'Codigo'																, ; //XB_DESCENG	
	'U7_COD'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'APRSU7'																, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	' '																		, ; //XB_COLUNA
	' '																		, ; //XB_DESCRI
	' '																		, ; //XB_DESCSPA
	' '																		, ; //XB_DESCENG	
	'SU7->U7_NOME'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'APRSU7'																, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	' '																		, ; //XB_COLUNA
	' '																		, ; //XB_DESCRI
	' '																		, ; //XB_DESCSPA
	' '																		, ; //XB_DESCENG	
	'SU7->U7_NREDUZ'														} ) //XB_CONTEM
	
aAdd( aSXB, { ;
	'APRSU7'																, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'03'																	, ; //XB_SEQ
	' '																		, ; //XB_COLUNA
	' '																		, ; //XB_DESCRI
	' '																		, ; //XB_DESCSPA
	' '																		, ; //XB_DESCENG	
	'SU7->U7_POSTO'															} ) //XB_CONTEM
	
aAdd( aSXB, { ;
	'APRSU7'																, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'04'																	, ; //XB_SEQ
	' '																		, ; //XB_COLUNA
	' '																		, ; //XB_DESCRI
	' '																		, ; //XB_DESCSPA
	' '																		, ; //XB_DESCENG	
	'SU7->U7_CODUSU'														} ) //XB_CONTEM
	
aAdd( aSXB, { ;
	'APRSU7'																, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'05'																	, ; //XB_SEQ
	' '																		, ; //XB_COLUNA
	' '																		, ; //XB_DESCRI
	' '																		, ; //XB_DESCSPA
	' '																		, ; //XB_DESCENG	
	'SU7->U7_CICNOME'														} ) //XB_CONTEM
	
aAdd( aSXB, { ;
	'APRSU7'																, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'06'																	, ; //XB_SEQ
	' '																		, ; //XB_COLUNA
	' '																		, ; //XB_DESCRI
	' '																		, ; //XB_DESCSPA
	' '																		, ; //XB_DESCENG	
	'SU7->U7_EMAIL'															} ) //XB_CONTEM
	
aAdd( aSXB, { ;
	'APRSU7'																, ; //XB_ALIAS
	'6'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	' '																		, ; //XB_COLUNA
	' '																		, ; //XB_DESCRI
	' '																		, ; //XB_DESCSPA
	' '																		, ; //XB_DESCENG	
	'SU7->U7_FILIAL == @#xFilial("SU7") .AND. SU7->U7_VALIDO=="1"'			} ) //XB_CONTEM
	

aAdd( aSXB, { ;
	'ZZN'																	, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'DB'																	, ; //XB_COLUNA
	'Resp por ocorr sac'													, ; //XB_DESCRI
	'Resp por ocorr sac'													, ; //XB_DESCSPA
	'Resp por ocorr sac'													, ; //XB_DESCENG	
	'ZZN'																	} ) //XB_CONTEM	
                                                                                            
aAdd( aSXB, { ;
	'ZZN'																	, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Codigo'																, ; //XB_DESCRI
	'Codigo'																, ; //XB_DESCSPA
	'Codigo'																, ; //XB_DESCENG	
	''																		} ) //XB_CONTEM
	
aAdd( aSXB, { ;
	'ZZN'																	, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Nome'																	, ; //XB_DESCRI
	'Nome'																	, ; //XB_DESCSPA
	'Nome'																	, ; //XB_DESCENG	
	''																		} ) //XB_CONTEM	
	
aAdd( aSXB, { ;
	'ZZN'																	, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'03'																	, ; //XB_SEQ
	'03'																	, ; //XB_COLUNA
	'Departamento' 															, ; //XB_DESCRI
	'Departamento'															, ; //XB_DESCSPA
	'Departamento'															, ; //XB_DESCENG	
	''																		} ) //XB_CONTEM
	
aAdd( aSXB, { ;
	'ZZN'																	, ; //XB_ALIAS
	'3'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Cadastra Novo'															, ; //XB_DESCRI
	'Incluye Nuevo'															, ; //XB_DESCSPA
	'Add New'																, ; //XB_DESCENG	
	'01'																	} ) //XB_CONTEM
	
aAdd( aSXB, { ;
	'ZZN'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Codigo'																, ; //XB_DESCRI
	'Codigo'																, ; //XB_DESCSPA
	'Codigo'																, ; //XB_DESCENG	
	'ZZN_CODIGO'															} ) //XB_CONTEM
	
aAdd( aSXB, { ;
	'ZZN'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Nome'																	, ; //XB_DESCRI
	'Nome'																	, ; //XB_DESCSPA
	'Nome'																	, ; //XB_DESCENG	
	'ZZN_NOME'																} ) //XB_CONTEM
	
aAdd( aSXB, { ;
	'ZZN'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'03'																	, ; //XB_COLUNA
	'Departamento'															, ; //XB_DESCRI
	'Departamento'															, ; //XB_DESCSPA
	'Departamento'															, ; //XB_DESCENG	
	'ZZN_DEPART'															} ) //XB_CONTEM
	
aAdd( aSXB, { ;
	'ZZN'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Nome'																	, ; //XB_DESCRI
	'Nome'																	, ; //XB_DESCSPA
	'Nome'																	, ; //XB_DESCENG	
	'ZZN_NOME'																} ) //XB_CONTEM						
	
aAdd( aSXB, { ;
	'ZZN'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Codigo'																, ; //XB_DESCRI
	'Codigo'																, ; //XB_DESCSPA
	'Codigo'																, ; //XB_DESCENG	
	'ZZN_CODIGO'															} ) //XB_CONTEM	
	
aAdd( aSXB, { ;
	'ZZN'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'03'																	, ; //XB_COLUNA
	'Departamento'															, ; //XB_DESCRI
	'Departamento'															, ; //XB_DESCSPA
	'Departamento'															, ; //XB_DESCENG	
	'ZZN_DEPART'															} ) //XB_CONTEM	
	
aAdd( aSXB, { ;
	'ZZN'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'03'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Departamento'															, ; //XB_DESCRI
	'Departamento'															, ; //XB_DESCSPA
	'Departamento'															, ; //XB_DESCENG	
	'ZZN_DEPART'															} ) //XB_CONTEM	
	
aAdd( aSXB, { ;
	'ZZN'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'03'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Codigo'																, ; //XB_DESCRI
	'Codigo'																, ; //XB_DESCSPA
	'Codigo'																, ; //XB_DESCENG	
	'ZZN_CODIGO'															} ) //XB_CONTEM	
	
aAdd( aSXB, { ;
	'ZZN'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'03'																	, ; //XB_SEQ
	'03'																	, ; //XB_COLUNA
	'Nome'																	, ; //XB_DESCRI
	'Nome'																	, ; //XB_DESCSPA
	'Nome'																	, ; //XB_DESCENG	
	'ZZN_NOME'																} ) //XB_CONTEM	
	
aAdd( aSXB, { ;
	'ZZN'																	, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG	
	'ZZN->ZZN_NOME'															} ) //XB_CONTEM						
	   

aAdd( aSXB, { ;
	'ZSAC'																	, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'DB'																	, ; //XB_COLUNA
	'DEPARTAMENTOS SAC'														, ; //XB_DESCRI
	'DEPARTAMENTOS SAC'														, ; //XB_DESCSPA
	'DEPARTAMENTOS SAC'														, ; //XB_DESCENG	
	'SX5'																	} ) //XB_CONTEM	
	
aAdd( aSXB, { ;
	'ZSAC'																	, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Tabela + Chave'														, ; //XB_DESCRI
	'Tabla + Clave'															, ; //XB_DESCSPA
	'Table + Key'															, ; //XB_DESCENG	
	''																		} ) //XB_CONTEM	
	
aAdd( aSXB, { ;
	'ZSAC'																	, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Tabela+descricao'														, ; //XB_DESCRI
	'Tabla+descripcion'														, ; //XB_DESCSPA
	'Table+descripcion'														, ; //XB_DESCENG	
	''																		} ) //XB_CONTEM	
	
aAdd( aSXB, { ;
	'ZSAC'																	, ; //XB_ALIAS
	'3'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Cadastra Novo'															, ; //XB_DESCRI
	'Incluye Nuevo'															, ; //XB_DESCSPA
	'Add New'																, ; //XB_DESCENG	
	'01'																	} ) //XB_CONTEM	
	
aAdd( aSXB, { ;
	'ZSAC'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Chave'																	, ; //XB_DESCRI
	'Clave'																	, ; //XB_DESCSPA
	'Key'																	, ; //XB_DESCENG	
	'X5_CHAVE'																} ) //XB_CONTEM	
	
aAdd( aSXB, { ;
	'ZSAC'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Descricao'																, ; //XB_DESCRI
	'Descripcion'															, ; //XB_DESCSPA
	'Description'															, ; //XB_DESCENG	
	'X5_DESCRI'																} ) //XB_CONTEM	
	
aAdd( aSXB, { ;
	'ZSAC'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Descricao'																, ; //XB_DESCRI
	'Descripcion'															, ; //XB_DESCSPA
	'Description'															, ; //XB_DESCENG	
	'X5_DESCRI'																} ) //XB_CONTEM	
	
aAdd( aSXB, { ;
	'ZSAC'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Chave'																	, ; //XB_DESCRI
	'Clave'																	, ; //XB_DESCSPA
	'Key'																	, ; //XB_DESCENG	
	'X5_CHAVE'																} ) //XB_CONTEM	
	
aAdd( aSXB, { ;
	'ZSAC'																	, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG	
	'SX5->X5_DESCRI'														} ) //XB_CONTEM	
	
	
aAdd( aSXB, { ;
	'ZSAC'																	, ; //XB_ALIAS
	'6'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG	
	'ZS5->X5_TABELA = "ZS"'													} ) //XB_CONTEM	

aAdd( aSXB, { ;
	'DIPSB1'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'ESTOQUE TOTAL'															, ; //XB_DESCRI
	'ESTOQUE TOTAL'															, ; //XB_DESCSPA
	'ESTOQUE TOTAL'															, ; //XB_DESCENG	
	"U_DIPSaldSB2(SB1->B1_COD,.T.,' ')"										} ) //XB_CONTEM	
		                                                                                                
aAdd( aSXB, { ;
	'ACY'																	, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'03'																	, ; //XB_COLUNA
	'Descricao  '															, ; //XB_DESCRI
	'Descripcion'															, ; //XB_DESCSPA
	'Description'															, ; //XB_DESCENG	
	''																		} ) //XB_CONTEM	
aAdd( aSXB, { ;
	'ACY'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Descricao  '															, ; //XB_DESCRI
	'Descripcion'															, ; //XB_DESCSPA
	'Description'															, ; //XB_DESCENG	
	'ACY_DESCRI '															} ) //XB_CONTEM	

aAdd( aSXB, { ;
	'ACY'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Grupo '																, ; //XB_DESCRI
	'Grupo '															, ; //XB_DESCSPA
	'Group '															, ; //XB_DESCENG	
	'ACY_GRPVEN'															} ) //XB_CONTEM	


aAdd( aSXB, { ;
	'DIPA61'																, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'DB'																	, ; //XB_COLUNA
	'Banco '																, ; //XB_DESCRI
	'Banco '																, ; //XB_DESCSPA
	'Banco '																, ; //XB_DESCENG	
	'SA6'																	} ) //XB_CONTEM	

aAdd( aSXB, { ;
	'DIPA61'																, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Codigo'																, ; //XB_DESCRI
	'Codigo'																, ; //XB_DESCSPA
	'Codigo'																, ; //XB_DESCENG	
	' '																		} ) //XB_CONTEM	

aAdd( aSXB, { ;
	'DIPA61'																, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Nome '																	, ; //XB_DESCRI
	'Nome '																	, ; //XB_DESCSPA
	'Nome '																	, ; //XB_DESCENG	
	' '																		} ) //XB_CONTEM	

aAdd( aSXB, { ;
	'DIPA61'																, ; //XB_ALIAS
	'3'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Cadastra Novo'															, ; //XB_DESCRI
	'Cadastra Novo'															, ; //XB_DESCSPA
	'Cadastra Novo'															, ; //XB_DESCENG	
	'01'																	} ) //XB_CONTEM			                                                                                                
	
aAdd( aSXB, { ;
	'DIPA61'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Codigo'																, ; //XB_DESCRI
	'Codigo'																, ; //XB_DESCSPA
	'Codigo'																, ; //XB_DESCENG	
	'A6_COD'																} ) //XB_CONTEM
	
aAdd( aSXB, { ;
	'DIPA61'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Agencia'																, ; //XB_DESCRI
	'Agencia'																, ; //XB_DESCSPA
	'Agencia'																, ; //XB_DESCENG	
	'A6_AGENCIA'															} ) //XB_CONTEM	

aAdd( aSXB, { ;
	'DIPA61'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'03'																	, ; //XB_COLUNA
	'Conta'																	, ; //XB_DESCRI
	'Conta'																	, ; //XB_DESCSPA
	'Conta'																	, ; //XB_DESCENG	
	'A6_NUMCON'																} ) //XB_CONTEM		

aAdd( aSXB, { ;
	'DIPA61'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'04'																	, ; //XB_COLUNA
	'Nome'																	, ; //XB_DESCRI
	'Nome'																	, ; //XB_DESCSPA
	'Nome'																	, ; //XB_DESCENG	
	'A6_NREDUZ'																} ) //XB_CONTEM	

aAdd( aSXB, { ;
	'DIPA61'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Codigo'																, ; //XB_DESCRI
	'Codigo'																, ; //XB_DESCSPA
	'Codigo'																, ; //XB_DESCENG	
	'A6_COD'																} ) //XB_CONTEM
	
aAdd( aSXB, { ;
	'DIPA61'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Agencia'																, ; //XB_DESCRI
	'Agencia'																, ; //XB_DESCSPA
	'Agencia'																, ; //XB_DESCENG	
	'A6_AGENCIA'															} ) //XB_CONTEM	
	
aAdd( aSXB, { ;
	'DIPA61'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'03'																	, ; //XB_COLUNA
	'Conta'																	, ; //XB_DESCRI
	'Conta'																	, ; //XB_DESCSPA
	'Conta'																	, ; //XB_DESCENG	
	'A6_NUMCON'																} ) //XB_CONTEM		

aAdd( aSXB, { ;
	'DIPA61'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'04'																	, ; //XB_COLUNA
	'Nome'																	, ; //XB_DESCRI
	'Nome'																	, ; //XB_DESCSPA
	'Nome'																	, ; //XB_DESCENG	
	'A6_NREDUZ'																} ) //XB_CONTEM	

aAdd( aSXB, { ;
	'DIPA61'																, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG	
	'SA6->A6_AGENCIA'														} ) //XB_CONTEM	
		

aAdd( aSXB, { ;
	'DIPA62'																, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'DB'																	, ; //XB_COLUNA
	'Banco '																, ; //XB_DESCRI
	'Banco '																, ; //XB_DESCSPA
	'Banco '																, ; //XB_DESCENG	
	'SA6'																	} ) //XB_CONTEM	

aAdd( aSXB, { ;
	'DIPA62'																, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Codigo'																, ; //XB_DESCRI
	'Codigo'																, ; //XB_DESCSPA
	'Codigo'																, ; //XB_DESCENG	
	' '																		} ) //XB_CONTEM	

aAdd( aSXB, { ;
	'DIPA62'																, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Nome '																	, ; //XB_DESCRI
	'Nome '																	, ; //XB_DESCSPA
	'Nome '																	, ; //XB_DESCENG	
	' '																		} ) //XB_CONTEM	

aAdd( aSXB, { ;
	'DIPA62'																, ; //XB_ALIAS
	'3'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Cadastra Novo'															, ; //XB_DESCRI
	'Cadastra Novo'															, ; //XB_DESCSPA
	'Cadastra Novo'															, ; //XB_DESCENG	
	'01'																	} ) //XB_CONTEM			                                                                                                
	
aAdd( aSXB, { ;
	'DIPA62'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Codigo'																, ; //XB_DESCRI
	'Codigo'																, ; //XB_DESCSPA
	'Codigo'																, ; //XB_DESCENG	
	'A6_COD'																} ) //XB_CONTEM
	
aAdd( aSXB, { ;
	'DIPA62'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Agencia'																, ; //XB_DESCRI
	'Agencia'																, ; //XB_DESCSPA
	'Agencia'																, ; //XB_DESCENG	
	'A6_AGENCIA'															} ) //XB_CONTEM	

aAdd( aSXB, { ;
	'DIPA62'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'03'																	, ; //XB_COLUNA
	'Conta'																	, ; //XB_DESCRI
	'Conta'																	, ; //XB_DESCSPA
	'Conta'																	, ; //XB_DESCENG	
	'A6_NUMCON'																} ) //XB_CONTEM		

aAdd( aSXB, { ;
	'DIPA62'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'04'																	, ; //XB_COLUNA
	'Nome'																	, ; //XB_DESCRI
	'Nome'																	, ; //XB_DESCSPA
	'Nome'																	, ; //XB_DESCENG	
	'A6_NREDUZ'																} ) //XB_CONTEM	

aAdd( aSXB, { ;
	'DIPA62'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Codigo'																, ; //XB_DESCRI
	'Codigo'																, ; //XB_DESCSPA
	'Codigo'																, ; //XB_DESCENG	
	'A6_COD'																} ) //XB_CONTEM
	
aAdd( aSXB, { ;
	'DIPA62'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Agencia'																, ; //XB_DESCRI
	'Agencia'																, ; //XB_DESCSPA
	'Agencia'																, ; //XB_DESCENG	
	'A6_AGENCIA'															} ) //XB_CONTEM	
	
aAdd( aSXB, { ;
	'DIPA62'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'03'																	, ; //XB_COLUNA
	'Conta'																	, ; //XB_DESCRI
	'Conta'																	, ; //XB_DESCSPA
	'Conta'																	, ; //XB_DESCENG	
	'A6_NUMCON'																} ) //XB_CONTEM		

aAdd( aSXB, { ;
	'DIPA62'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'04'																	, ; //XB_COLUNA
	'Nome'																	, ; //XB_DESCRI
	'Nome'																	, ; //XB_DESCSPA
	'Nome'																	, ; //XB_DESCENG	
	'A6_NREDUZ'																} ) //XB_CONTEM	

aAdd( aSXB, { ;
	'DIPA62'																, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG	
	'SA6->A6_NUMCON'														} ) //XB_CONTEM	   
	
//TABELA SC9

aAdd( aSXB, { ;
	'SCP'																, ; //XB_ALIAS
	'1'																	, ; //XB_TIPO
	'01'																, ; //XB_SEQ
	'DB'																, ; //XB_COLUNA
	'Solicitacao Armazem '												, ; //XB_DESCRI
	'Solicitacao Armazem '												, ; //XB_DESCSPA
	'Solicitacao Armazem '	 											, ; //XB_DESCENG	
	'SCP'																} ) //XB_CONTEM		
	                                                                                        
aAdd( aSXB, { ;
	'SCP'																, ; //XB_ALIAS
	'2'																	, ; //XB_TIPO
	'01'																, ; //XB_SEQ
	'01'																, ; //XB_COLUNA
	'Nr.s.a. + Item S.a. '												, ; //XB_DESCRI
	'Nro. S.a. + Item R d'												, ; //XB_DESCSPA
	'W.r.no. + W.r.item +'	 											, ; //XB_DESCENG	
	''																	} ) //XB_CONTEM			
		                                                                                        
aAdd( aSXB, { ;
	'SCP'																, ; //XB_ALIAS
	'4'																	, ; //XB_TIPO
	'01'																, ; //XB_SEQ
	'01'																, ; //XB_COLUNA
	'Numero da SA        '												, ; //XB_DESCRI
	'Nro. S.A.           '												, ; //XB_DESCSPA
	'W.R.No.             '	 											, ; //XB_DESCENG	
	'CP_NUM'															} ) //XB_CONTEM					
	
aAdd( aSXB, { ;
	'SCP'																, ; //XB_ALIAS
	'4'																	, ; //XB_TIPO
	'01'																, ; //XB_SEQ
	'02'																, ; //XB_COLUNA
	'Produto             '												, ; //XB_DESCRI
	'Producto            '												, ; //XB_DESCSPA
	'Product             '	 											, ; //XB_DESCENG	
	'CP_PRODUTO'														} ) //XB_CONTEM						
		                                                                                                    
aAdd( aSXB, { ;
	'SCP'																, ; //XB_ALIAS
	'4'																	, ; //XB_TIPO
	'01'																, ; //XB_SEQ
	'03'																, ; //XB_COLUNA
	'Quantidade          '												, ; //XB_DESCRI
	'Cantidad            '												, ; //XB_DESCSPA
	'Quantity            '	 											, ; //XB_DESCENG	
	'CP_QUANT'															} ) //XB_CONTEM								

aAdd( aSXB, { ;
	'SCP'																, ; //XB_ALIAS
	'4'																	, ; //XB_TIPO
	'01'																, ; //XB_SEQ
	'04'																, ; //XB_COLUNA
	'Unid Medida         '												, ; //XB_DESCRI
	'Unid. Medida        '												, ; //XB_DESCSPA
	'Unit of Meas        '	 											, ; //XB_DESCENG	
	'CP_UM'																} ) //XB_CONTEM								
	                                                                                                                
aAdd( aSXB, { ;
	'SCP'																, ; //XB_ALIAS
	'4'																	, ; //XB_TIPO
	'01'																, ; //XB_SEQ
	'05'																, ; //XB_COLUNA
	'Qtd. 2a UM          '												, ; //XB_DESCRI
	'Ctd. 2a UM          '												, ; //XB_DESCSPA
	'2nd Unit Mea        '	 											, ; //XB_DESCENG	
	'CP_QTSEGUM'														} ) //XB_CONTEM									
	                                                                                                                    
aAdd( aSXB, { ;
	'SCP'																, ; //XB_ALIAS
	'4'																	, ; //XB_TIPO
	'01'																, ; //XB_SEQ
	'06'																, ; //XB_COLUNA
	'Segunda UM          '												, ; //XB_DESCRI
	'Segunda UM          '												, ; //XB_DESCSPA
	'2nd U.Meas.         '	 											, ; //XB_DESCENG	
	'CP_SEGUM'															} ) //XB_CONTEM									
	                                                                                                                    
aAdd( aSXB, { ;
	'SCP'																, ; //XB_ALIAS
	'4'																	, ; //XB_TIPO
	'01'																, ; //XB_SEQ
	'07'																, ; //XB_COLUNA
	'Solicitante         '												, ; //XB_DESCRI
	'Solicitante         '												, ; //XB_DESCSPA
	'Petitioner          '	 											, ; //XB_DESCENG	
	'CP_SOLICIT'														} ) //XB_CONTEM									
	                                                                                                                    
aAdd( aSXB, { ;
	'SCP'																, ; //XB_ALIAS
	'5'																	, ; //XB_TIPO
	'01'																, ; //XB_SEQ
	''																	, ; //XB_COLUNA
	''																	, ; //XB_DESCRI
	''																	, ; //XB_DESCSPA
	''						 											, ; //XB_DESCENG	
	'SCP->CP_NUM'														} ) //XB_CONTEM										
	
//                                                                                                                  
// Atualizando dicion·rio
//
oProcess:SetRegua2( Len( aSXB ) )

dbSelectArea( "SXB" )
dbSetOrder( 1 )

For nI := 1 To Len( aSXB )

	If !Empty( aSXB[nI][1] )

		If !SXB->( dbSeek( PadR( aSXB[nI][1], Len( SXB->XB_ALIAS ) ) + aSXB[nI][2] + aSXB[nI][3] + aSXB[nI][4] ) )

			If !( aSXB[nI][1] $ cAlias )
				cAlias += aSXB[nI][1] + "/"
				cTexto += "Foi incluÌda a consulta padr„o " + aSXB[nI][1] + CRLF
			EndIf

			RecLock( "SXB", .T. )

			For nJ := 1 To Len( aSXB[nI] )
				If !Empty( FieldName( FieldPos( aEstrut[nJ] ) ) )
					FieldPut( FieldPos( aEstrut[nJ] ), aSXB[nI][nJ] )
				EndIf
			Next nJ

			dbCommit()
			MsUnLock()

		Else

			//
			// Verifica todos os campos
			//
			For nJ := 1 To Len( aSXB[nI] )

				//
				// Se o campo estiver diferente da estrutura
				//
				If aEstrut[nJ] == SXB->( FieldName( nJ ) ) .AND. ;
					!StrTran( AllToChar( SXB->( FieldGet( nJ ) ) ), " ", "" ) == ;
					 StrTran( AllToChar( aSXB[nI][nJ]            ), " ", "" )

					If nOpcA == 1
						RecLock( "SXB", .F. )
						FieldPut( FieldPos( aEstrut[nJ] ), aSXB[nI][nJ] )
						dbCommit()
						MsUnLock()

						If !( aSXB[nI][1] $ cAlias )
							cAlias += aSXB[nI][1] + "/"
							cTexto += "Foi Alterada a consulta padrao " + aSXB[nI][1] + CRLF
						EndIf

					EndIf

				EndIf

			Next

		EndIf

	EndIf

	oProcess:IncRegua2( "Atualizando Consultas Padroes (SXB)..." )

Next nI

cTexto += CRLF + "Final da Atualizacao" + " SXB" + CRLF + Replicate( "-", 128 ) + CRLF + CRLF

Return   
/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  | FSAtuSX1 ∫Autor  ≥TOTVS Protheus      ∫ Data ≥  11/09/12   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥  Funcao de processamento da gravacao do SX1 - Cadastro     ∫±±
±±∫          ≥  de Perguntas.                                             ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ FSAtuSX1	   - Gerado por EXPORDIC / Upd. V.4.10.4 EFS       ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
  
Static Function FSAtuSX1( cTexto )
Local aEstrut   := {}
Local aSX1      := {}
Local aStruDic  := SX1->( dbStruct() )
Local cAlias    := ""
Local nI        := 0
Local nJ        := 0
Local nTam1     := Len( SX1->X1_GRUPO )
Local nTam2     := Len( SX1->X1_ORDEM )

cTexto  += '0131' + cAlias + CRLF + CRLF //"Inicio Atualizacao "

aEstrut := { "X1_GRUPO"  , "X1_ORDEM"  , "X1_PERGUNT", "X1_PERSPA" , "X1_PERENG" , "X1_VARIAVL", "X1_TIPO"   , ;
             "X1_TAMANHO", "X1_DECIMAL", "X1_PRESEL" , "X1_GSC"    , "X1_VALID"  , "X1_VAR01"  , "X1_DEF01"  , ;
             "X1_DEFSPA1", "X1_DEFENG1", "X1_CNT01"  , "X1_VAR02"  , "X1_DEF02"  , "X1_DEFSPA2", "X1_DEFENG2", ;
             "X1_CNT02"  , "X1_VAR03"  , "X1_DEF03"  , "X1_DEFSPA3", "X1_DEFENG3", "X1_CNT03"  , "X1_VAR04"  , ;
             "X1_DEF04"  , "X1_DEFSPA4", "X1_DEFENG4", "X1_CNT04"  , "X1_VAR05"  , "X1_DEF05"  , "X1_DEFSPA5", ;
             "X1_DEFENG5", "X1_CNT05"  , "X1_F3"     , "X1_PYME"   , "X1_GRPSXG" , "X1_HELP"   , "X1_PICTURE", ;
             "X1_IDFIL"   }
                                                                                                                                                                                                
SX1->(dbSetOrder(1))             
If SX1->(dbSeek(PadR("FIN210",nTam1)+PadR("03",nTam2)))     
	aAdd(aSX1,{	SX1->X1_GRUPO  ,; 
				SX1->X1_ORDEM  ,; 
				SX1->X1_PERGUNT,; 
				SX1->X1_PERSPA ,; 
				SX1->X1_PERENG ,; 
				SX1->X1_VARIAVL,; 
				SX1->X1_TIPO   ,; 
				SX1->X1_TAMANHO,; 
				SX1->X1_DECIMAL,; 
				SX1->X1_PRESEL ,; 
				SX1->X1_GSC    ,; 
				SX1->X1_VALID  ,; 
				SX1->X1_VAR01  ,; 
				SX1->X1_DEF01  ,; 
				SX1->X1_DEFSPA1,; 
				SX1->X1_DEFENG1,; 
				SX1->X1_CNT01  ,; 
				SX1->X1_VAR02  ,; 
				SX1->X1_DEF02  ,; 
				SX1->X1_DEFSPA2,; 
				SX1->X1_DEFENG2,; 
				SX1->X1_CNT02  ,; 
				SX1->X1_VAR03  ,; 
				SX1->X1_DEF03  ,; 
				SX1->X1_DEFSPA3,; 
				SX1->X1_DEFENG3,; 
				SX1->X1_CNT03  ,; 
				SX1->X1_VAR04  ,; 
				SX1->X1_DEF04  ,; 
				SX1->X1_DEFSPA4,; 
				SX1->X1_DEFENG4,; 
				SX1->X1_CNT04  ,; 
				SX1->X1_VAR05  ,; 
				SX1->X1_DEF05  ,; 
				SX1->X1_DEFSPA5,; 
				SX1->X1_DEFENG5,; 
				SX1->X1_CNT05  ,; 
				"DIPA61" 	   ,; 
				SX1->X1_PYME   ,; 
				SX1->X1_GRPSXG ,; 
				SX1->X1_HELP   ,; 
				SX1->X1_PICTURE,; 
				SX1->X1_IDFIL  })
EndIf

SX1->(dbSetOrder(1))             
If SX1->(dbSeek(PadR("FIN210",nTam1)+PadR("04",nTam2))) 
	aAdd(aSX1,{	SX1->X1_GRUPO  ,; 
				SX1->X1_ORDEM  ,; 
				SX1->X1_PERGUNT,; 
				SX1->X1_PERSPA ,; 
				SX1->X1_PERENG ,; 
				SX1->X1_VARIAVL,; 
				SX1->X1_TIPO   ,; 
				SX1->X1_TAMANHO,; 
				SX1->X1_DECIMAL,; 
				SX1->X1_PRESEL ,; 
				SX1->X1_GSC    ,; 
				SX1->X1_VALID  ,; 
				SX1->X1_VAR01  ,; 
				SX1->X1_DEF01  ,; 
				SX1->X1_DEFSPA1,; 
				SX1->X1_DEFENG1,; 
				SX1->X1_CNT01  ,; 
				SX1->X1_VAR02  ,; 
				SX1->X1_DEF02  ,; 
				SX1->X1_DEFSPA2,; 
				SX1->X1_DEFENG2,; 
				SX1->X1_CNT02  ,; 
				SX1->X1_VAR03  ,; 
				SX1->X1_DEF03  ,; 
				SX1->X1_DEFSPA3,; 
				SX1->X1_DEFENG3,; 
				SX1->X1_CNT03  ,; 
				SX1->X1_VAR04  ,; 
				SX1->X1_DEF04  ,; 
				SX1->X1_DEFSPA4,; 
				SX1->X1_DEFENG4,; 
				SX1->X1_CNT04  ,; 
				SX1->X1_VAR05  ,; 
				SX1->X1_DEF05  ,; 
				SX1->X1_DEFSPA5,; 
				SX1->X1_DEFENG5,; 
				SX1->X1_CNT05  ,; 
				"DIPA61" 	   ,; 
				SX1->X1_PYME   ,; 
				SX1->X1_GRPSXG ,; 
				SX1->X1_HELP   ,; 
				SX1->X1_PICTURE,; 
				SX1->X1_IDFIL  })
EndIf     

SX1->(dbSetOrder(1))             
If SX1->(dbSeek(PadR("FIN210",nTam1)+PadR("05",nTam2))) 
	aAdd(aSX1,{	SX1->X1_GRUPO  ,; 
				SX1->X1_ORDEM  ,; 
				SX1->X1_PERGUNT,; 
				SX1->X1_PERSPA ,; 
				SX1->X1_PERENG ,; 
				SX1->X1_VARIAVL,; 
				SX1->X1_TIPO   ,; 
				SX1->X1_TAMANHO,; 
				SX1->X1_DECIMAL,; 
				SX1->X1_PRESEL ,; 
				SX1->X1_GSC    ,; 
				SX1->X1_VALID  ,; 
				SX1->X1_VAR01  ,; 
				SX1->X1_DEF01  ,; 
				SX1->X1_DEFSPA1,; 
				SX1->X1_DEFENG1,; 
				SX1->X1_CNT01  ,; 
				SX1->X1_VAR02  ,; 
				SX1->X1_DEF02  ,; 
				SX1->X1_DEFSPA2,; 
				SX1->X1_DEFENG2,; 
				SX1->X1_CNT02  ,; 
				SX1->X1_VAR03  ,; 
				SX1->X1_DEF03  ,; 
				SX1->X1_DEFSPA3,; 
				SX1->X1_DEFENG3,; 
				SX1->X1_CNT03  ,; 
				SX1->X1_VAR04  ,; 
				SX1->X1_DEF04  ,; 
				SX1->X1_DEFSPA4,; 
				SX1->X1_DEFENG4,; 
				SX1->X1_CNT04  ,; 
				SX1->X1_VAR05  ,; 
				SX1->X1_DEF05  ,; 
				SX1->X1_DEFSPA5,; 
				SX1->X1_DEFENG5,; 
				SX1->X1_CNT05  ,; 
				"DIPA62" 	   ,; 
				SX1->X1_PYME   ,; 
				SX1->X1_GRPSXG ,; 
				SX1->X1_HELP   ,; 
				SX1->X1_PICTURE,; 
				SX1->X1_IDFIL  })
EndIf

SX1->(dbSetOrder(1))             
If SX1->(dbSeek(PadR("FIN210",nTam1)+PadR("06",nTam2))) 
	aAdd(aSX1,{	SX1->X1_GRUPO  ,; 
				SX1->X1_ORDEM  ,; 
				SX1->X1_PERGUNT,; 
				SX1->X1_PERSPA ,; 
				SX1->X1_PERENG ,; 
				SX1->X1_VARIAVL,; 
				SX1->X1_TIPO   ,; 
				SX1->X1_TAMANHO,; 
				SX1->X1_DECIMAL,; 
				SX1->X1_PRESEL ,; 
				SX1->X1_GSC    ,; 
				SX1->X1_VALID  ,; 
				SX1->X1_VAR01  ,; 
				SX1->X1_DEF01  ,; 
				SX1->X1_DEFSPA1,; 
				SX1->X1_DEFENG1,; 
				SX1->X1_CNT01  ,; 
				SX1->X1_VAR02  ,; 
				SX1->X1_DEF02  ,; 
				SX1->X1_DEFSPA2,; 
				SX1->X1_DEFENG2,; 
				SX1->X1_CNT02  ,; 
				SX1->X1_VAR03  ,; 
				SX1->X1_DEF03  ,; 
				SX1->X1_DEFSPA3,; 
				SX1->X1_DEFENG3,; 
				SX1->X1_CNT03  ,; 
				SX1->X1_VAR04  ,; 
				SX1->X1_DEF04  ,; 
				SX1->X1_DEFSPA4,; 
				SX1->X1_DEFENG4,; 
				SX1->X1_CNT04  ,; 
				SX1->X1_VAR05  ,; 
				SX1->X1_DEF05  ,; 
				SX1->X1_DEFSPA5,; 
				SX1->X1_DEFENG5,; 
				SX1->X1_CNT05  ,; 
				"DIPA62" 	   ,; 
				SX1->X1_PYME   ,; 
				SX1->X1_GRPSXG ,; 
				SX1->X1_HELP   ,; 
				SX1->X1_PICTURE,; 
				SX1->X1_IDFIL  })
EndIf

//---------------------   AFI150

SX1->(dbSetOrder(1))             
If SX1->(dbSeek(PadR("AFI150",nTam1)+PadR("03",nTam2))) 
	aAdd(aSX1,{	SX1->X1_GRUPO  ,; 
				SX1->X1_ORDEM  ,; 
				SX1->X1_PERGUNT,; 
				SX1->X1_PERSPA ,; 
				SX1->X1_PERENG ,; 
				SX1->X1_VARIAVL,; 
				SX1->X1_TIPO   ,; 
				SX1->X1_TAMANHO,; 
				SX1->X1_DECIMAL,; 
				SX1->X1_PRESEL ,; 
				SX1->X1_GSC    ,; 
				"u_VldArqHQ()"  ,; 
				SX1->X1_VAR01  ,; 
				SX1->X1_DEF01  ,; 
				SX1->X1_DEFSPA1,; 
				SX1->X1_DEFENG1,; 
				SX1->X1_CNT01  ,; 
				SX1->X1_VAR02  ,; 
				SX1->X1_DEF02  ,; 
				SX1->X1_DEFSPA2,; 
				SX1->X1_DEFENG2,; 
				SX1->X1_CNT02  ,; 
				SX1->X1_VAR03  ,; 
				SX1->X1_DEF03  ,; 
				SX1->X1_DEFSPA3,; 
				SX1->X1_DEFENG3,; 
				SX1->X1_CNT03  ,; 
				SX1->X1_VAR04  ,; 
				SX1->X1_DEF04  ,; 
				SX1->X1_DEFSPA4,; 
				SX1->X1_DEFENG4,; 
				SX1->X1_CNT04  ,; 
				SX1->X1_VAR05  ,; 
				SX1->X1_DEF05  ,; 
				SX1->X1_DEFSPA5,; 
				SX1->X1_DEFENG5,; 
				SX1->X1_CNT05  ,; 
				SX1->X1_F3 	   ,; 
				SX1->X1_PYME   ,; 
				SX1->X1_GRPSXG ,; 
				SX1->X1_HELP   ,; 
				SX1->X1_PICTURE,; 
				SX1->X1_IDFIL  })
EndIf


SX1->(dbSetOrder(1))             
If SX1->(dbSeek(PadR("AFI150",nTam1)+PadR("05",nTam2))) 
	aAdd(aSX1,{	SX1->X1_GRUPO  ,; 
				SX1->X1_ORDEM  ,; 
				SX1->X1_PERGUNT,; 
				SX1->X1_PERSPA ,; 
				SX1->X1_PERENG ,; 
				SX1->X1_VARIAVL,; 
				SX1->X1_TIPO   ,; 
				SX1->X1_TAMANHO,; 
				SX1->X1_DECIMAL,; 
				SX1->X1_PRESEL ,; 
				SX1->X1_GSC    ,; 
				"u_VldArqHQ()"  ,; 
				SX1->X1_VAR01  ,; 
				SX1->X1_DEF01  ,; 
				SX1->X1_DEFSPA1,; 
				SX1->X1_DEFENG1,; 
				SX1->X1_CNT01  ,; 
				SX1->X1_VAR02  ,; 
				SX1->X1_DEF02  ,; 
				SX1->X1_DEFSPA2,; 
				SX1->X1_DEFENG2,; 
				SX1->X1_CNT02  ,; 
				SX1->X1_VAR03  ,; 
				SX1->X1_DEF03  ,; 
				SX1->X1_DEFSPA3,; 
				SX1->X1_DEFENG3,; 
				SX1->X1_CNT03  ,; 
				SX1->X1_VAR04  ,; 
				SX1->X1_DEF04  ,; 
				SX1->X1_DEFSPA4,; 
				SX1->X1_DEFENG4,; 
				SX1->X1_CNT04  ,; 
				SX1->X1_VAR05  ,; 
				SX1->X1_DEF05  ,; 
				SX1->X1_DEFSPA5,; 
				SX1->X1_DEFENG5,; 
				SX1->X1_CNT05  ,; 
				SX1->X1_F3 	   ,; 
				SX1->X1_PYME   ,; 
				SX1->X1_GRPSXG ,; 
				SX1->X1_HELP   ,; 
				SX1->X1_PICTURE,; 
				SX1->X1_IDFIL  })
EndIf

//
// Atualizando dicion·rio
//
oProcess:SetRegua2( Len( aSX1 ) )

dbSelectArea( "SX1" )
SX1->( dbSetOrder( 1 ) )

For nI := 1 To Len( aSX1 )

            oProcess:IncRegua2( "Atualizando perguntas..." ) //"Atualizando perguntas..."

            If !SX1->( dbSeek( PadR( aSX1[nI][1], nTam1 ) + PadR( aSX1[nI][2], nTam2 ) ) )
                        cTexto +=  "Pergunta Criada. Grupo/Ordem "  + aSX1[nI][1] + "/" + aSX1[nI][2] + CRLF //"Pergunta Criada. Grupo/Ordem "
                        RecLock( "SX1", .T. )
            Else
                        cTexto +=  "Pergunta Alterada. Grupo/Ordem " + aSX1[nI][1] + "/" + aSX1[nI][2] + CRLF //"Pergunta Alterada. Grupo/Ordem "
                        RecLock( "SX1", .F. )
            EndIf

            For nJ := 1 To Len( aSX1[nI] )
                        If aScan( aStruDic, { |aX| PadR( aX[1], 10 ) == PadR( aEstrut[nJ], 10 ) } ) > 0
                                   SX1->( FieldPut( FieldPos( aEstrut[nJ] ), aSX1[nI][nJ] ) )
                        EndIf
            Next nJ

            MsUnLock()

Next nI

cTexto += CRLF + "Final da Atualizacao" + " SX1" + CRLF + Replicate( "-", 128 ) + CRLF + CRLF //"Final da Atualizacao"

Return aClone( aSX1 ) 
/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕ"±±
±±∫ Programa ≥ FSAtuSIX ∫ Autor ≥ Microsiga          ∫ Data ≥  22/06/09   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫ Descricao≥ Funcao de processamento da gravacao do SIX - Indices       ≥±±
±±∫          ≥                                                            ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±≥ Uso      ≥ FSAtuSIX - V.3.0                                           ≥±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Static Function FSAtuSIX()
Local cTexto    := 'Inicio da Atualizacao do SIX' + CRLF + CRLF
Local cAlias    := ''
Local lDelInd   := .F.
Local aSIX      := {}
Local aEstrut   := {}
Local nI        := 0
Local nJ        := 0
Local lAlt      := .F.

aEstrut := { 'INDICE' , 'ORDEM' , 'CHAVE', 'DESCRICAO', 'DESCSPA'  , ;
             'DESCENG', 'PROPRI', 'F3'   , 'NICKNAME' , 'SHOWPESQ' }

//
// Tabela ZZC
//
aAdd( aSIX, { ;
	'ZZC'																	, ; //INDICE
	'1'																		, ; //ORDEM
	'ZZC_FILIAL+ZZC_LOCAL+ZZC_LOCALI+DTOS(ZZC_DATA)'						, ; //CHAVE
	'Local + Localiz + Data'												, ; //DESCRICAO
	'Local + Localiz + Data'												, ; //DESCSPA
	'Local + Localiz + Data'												, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

//
// Tabela ZZD
//
aAdd( aSIX, { ;
	'ZZD'																	, ; //INDICE
	'1'																		, ; //ORDEM
	'ZZD_FILIAL+ZZD_LOCAL+ZZD_LOCALI+DTOS(ZZD_DATA)'						, ; //CHAVE
	'Local + Localiz + Data'												, ; //DESCRICAO
	'Local + Localiz + Data'												, ; //DESCSPA
	'Local + Localiz + Data'												, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

aAdd( aSIX, { ;
	'ZZD'																	, ; //INDICE
	'2'																		, ; //ORDEM
	'ZZD_FILIAL+ZZD_PRODUT+ZZD_LOTECT+ZZD_LOCAL+ZZD_LOCALI+DTOS(ZZD_DATA)'		, ; //CHAVE
	'Produto + Lote + Local + Localiz + Data'								, ; //DESCRICAO
	''																		, ; //DESCSPA
	''																		, ; //DESCENG
	''																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	''																		} ) //SHOWPESQ    
	
	
aAdd( aSIX, { ;
	'ZZE'																	, ; //INDICE
	'1'																		, ; //ORDEM
	'ZZE_FILIAL+ZZE_POSIPI+DTOS(ZZE_DTPVD)+DTOS(ZZE_DTPVA)'					, ; //CHAVE
	'NCM + Periodo de + Periodo ate'	  									, ; //DESCRICAO
	''																		, ; //DESCSPA
	''																		, ; //DESCENG
	''																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	''																		} ) //SHOWPESQ



//
// Tabela ZZF
//
aAdd( aSIX, { ;
	'ZZF'																	, ; //INDICE
	'1'																		, ; //ORDEM
	'ZZF_FILIAL+ZZF_CODIGO+ZZF_CODCLI+ZZF_LOJA+DTOS(ZZF_DATAIN)+DTOS(ZZF_DATAFI)', ; //CHAVE
	'Cod + Cliente + Loja + Data In + Data Fim'								, ; //DESCRICAO
	'Cod + Cliente + Loja + Data In + Data Fim'							, ; //DESCSPA
	'Cod + Cliente + Loja + Data In + Data Fim'							, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'N'																		} ) //SHOWPESQ

aAdd( aSIX, { ;
	'ZZF'																	, ; //INDICE
	'2'																		, ; //ORDEM
	'ZZF_FILIAL+ZZF_CODCLI+ZZF_LOJA+DTOS(ZZF_DATAIN)+DTOS(ZZF_DATAFI)', 	; //CHAVE
	'Cliente + Loja + Data In + Data Fim'									, ; //DESCRICAO
	'Cliente + Loja + Data In + Data Fim'						  			, ; //DESCSPA
	'Cliente + Loja + Data In + Data Fim'						 			, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ
	
aAdd( aSIX, { ;
	'ZZF'																	, ; //INDICE
	'3'																		, ; //ORDEM
	'ZZF_FILIAL+ZZF_GRPVEN'													, ; //CHAVE
	'Grupo Cliente'															, ; //DESCRICAO
	'Grupo Cliente'															, ; //DESCSPA
	'Grupo Cliente'															, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

aAdd( aSIX, { ;
	'ZZF'																	, ; //INDICE
	'4'																		, ; //ORDEM
	'ZZF_FILIAL+ZZF_CONTRA'													, ; //CHAVE
	'Contrato'																, ; //DESCRICAO
	'Contrato'																, ; //DESCSPA
	'Contrato'																, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ
	

//
// Tabela ZZG
//
aAdd( aSIX, { ;
	'ZZG'																	, ; //INDICE
	'1'																		, ; //ORDEM
	'ZZG_FILIAL+ZZG_CODIGO+ZZG_SEQUEN+ZZG_PRODUT'							, ; //CHAVE
	'Cod + Sequen + Produto'												, ; //DESCRICAO
	'Cod + Sequen + Produto'												, ; //DESCSPA
	'Cod + Sequen + Produto'												, ; //DESCENG
	'S'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

//
// Tabela ZZI
//
aAdd( aSIX, { ;
	'ZZI'																	, ; //INDICE
	'1'																		, ; //ORDEM
	'ZZI_FILIAL+ZZI_CODMSG+ZZI_SEQUEN'										, ; //CHAVE
	'Codigo + Sequen'														, ; //DESCRICAO
	'Codigo + Sequen'														, ; //DESCSPA
	'Codigo + Sequen'														, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	''																		} ) //SHOWPESQ

//
// Tabela ZZJ
//
aAdd( aSIX, { ;
	'ZZJ'																	, ; //INDICE
	'1'																		, ; //ORDEM
	'ZZJ_FILIAL+ZZJ_CODMSG'													, ; //CHAVE
	'Codigo'																, ; //DESCRICAO
	'Codigo'																, ; //DESCSPA
	'Codigo'																, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	''																		} ) //SHOWPESQ

//
// Tabela ZZK
//
aAdd( aSIX, { ;
	'ZZK'																	, ; //INDICE
	'1'																		, ; //ORDEM
	'ZZK_FILIAL+ZZK_PEDIDO+ZZK_PRODUT+ZZK_ITEM'								, ; //CHAVE
	'Pedido + Produto + Item'												, ; //DESCRICAO
	'Pedido + Produto + Item'												, ; //DESCSPA
	'Pedido + Produto + Item'												, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	''																		} ) //SHOWPESQ

aAdd( aSIX, { ;
	'ZZK'																	, ; //INDICE
	'2'																		, ; //ORDEM
	'ZZK_FILIAL+ZZK_PEDIDO+ZZK_SEQUEN'		 								, ; //CHAVE
	'Pedido + Produto + Sequen'												, ; //DESCRICAO
	'Pedido + Produto + Sequen'												, ; //DESCSPA
	'Pedido + Produto + Sequen'												, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	''																		} ) //SHOWPESQ
	
//
// Tabela ZZL
//
aAdd( aSIX, { ;
	'ZZL'																	, ; //INDICE
	'1'																		, ; //ORDEM
	'ZZL_FILIAL+ZZL_CODIGO'													, ; //CHAVE
	'Codigo'																, ; //DESCRICAO
	'Codigo'																, ; //DESCSPA
	'Codigo'																, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	''																		} ) //SHOWPESQ

aAdd( aSIX, { ;
	'CB7'																	, ; //INDICE
	'A'																		, ; //ORDEM
	'CB7_FILIAL+CB7_XPRIOR+CB7_ORDSEP'									  	, ; //CHAVE
	'Prioridade + Ord Sep.'							 						, ; //DESCRICAO
	'Prioridade + Ord Sep.'													, ; //DESCSPA
	'Prioridade + Ord Sep.'													, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	'CB7DIP10'																, ; //NICKNAME
	'S'																		} ) //SHOWPESQ                	

aAdd( aSIX, { ;
	'SB1'																	, ; //INDICE
	'E'																		, ; //ORDEM
	'B1_FILIAL+B1_XCODORI'												  	, ; //CHAVE
	'Prioridade + Ord Sep.'							 						, ; //DESCRICAO
	'Prioridade + Ord Sep.'													, ; //DESCSPA
	'Prioridade + Ord Sep.'													, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	'SB1DIP14'																, ; //NICKNAME
	'S'																		} ) //SHOWPESQ


//
// Tabela ZZN
//
aAdd( aSIX, { ;
	'ZZN'																	, ; //INDICE
	'1'																		, ; //ORDEM
	'ZZN_FILIAL+ZZN_CODIGO'													, ; //CHAVE
	'Codigo'																, ; //DESCRICAO
	'Codigo'																, ; //DESCSPA
	'Codigo'																, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

aAdd( aSIX, { ;
	'ZZN'																	, ; //INDICE
	'2'																		, ; //ORDEM
	'ZZN_FILIAL+ZZN_NOME'													, ; //CHAVE
	'Nome' 																	, ; //DESCRICAO
	'Nome'																	, ; //DESCSPA
	'Nome'																	, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ
	
aAdd( aSIX, { ;
	'ZZN'																	, ; //INDICE
	'3'																		, ; //ORDEM
	'ZZN_FILIAL+ZZN_DEPART'													, ; //CHAVE
	'Departamento'															, ; //DESCRICAO
	'Departamento'															, ; //DESCSPA
	'Departamento'															, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

aAdd( aSIX, { ;
	'ZZM'																	, ; //INDICE
	'1'																		, ; //ORDEM
	'ZZM_FILIAL+ZZM_DOC+ZZM_SERIE+ZZM_FORNEC+ZZM_LOJA'						, ; //CHAVE
	'Documento+Serie+Fornecedor+Loja'										, ; //DESCRICAO
	'Documento+Serie+Fornecedor+Loja'										, ; //DESCSPA
	'Documento+Serie+Fornecedor+Loja'										, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

aAdd( aSIX, { ;
	'ZZM'																	, ; //INDICE
	'2'																		, ; //ORDEM
	'ZZM_FILIAL+ZZM_DOC+ZZM_SERIE+ZZM_FORNEC+ZZM_LOJA+ZZM_CODPRO+ZZM_ITEM'		, ; //CHAVE
	'Documento+Serie+Fornecedor+Loja+Produto+Item'							, ; //DESCRICAO
	'Documento+Serie+Fornecedor+Loja+Produto+Item'							, ; //DESCSPA
	'Documento+Serie+Fornecedor+Loja+Produto+Item'							, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ


//
// Tabela SE1
//
aAdd( aSIX, { ;
	'SE1'																	, ; //INDICE
	'U'																		, ; //ORDEM
	'E1_FILORIG+E1_PEDIDO'													, ; //CHAVE
	'Pedido'																, ; //DESCRICAO
	'Pedido'																, ; //DESCSPA
	'Pedido'																, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	'PEDIDO'																, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

//
// Tabela ZZP
//
aAdd( aSIX, { ;
	'ZZP'																	, ; //INDICE
	'1'																		, ; //ORDEM
	'ZZP_FILIAL+ZZP_LOCAL+ZZP_LOCALI+DTOS(ZZP_DATA)'						, ; //CHAVE
	'Local + Localiz + Data'												, ; //DESCRICAO
	'Local + Localiz + Data'												, ; //DESCSPA
	'Local + Localiz + Data'												, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

aAdd( aSIX, { ;
	'ZZP'																	, ; //INDICE
	'2'																		, ; //ORDEM
	'ZZP_FILIAL+ZZP_LOCAL+ZZP_LOCALI+ZZP_PRODUT+ZZP_LOTECT+DTOS(ZZP_DATA)'		, ; //CHAVE
	'Local + Localiz + Produto + Lote + Data'								, ; //DESCRICAO
	''																		, ; //DESCSPA
	''																		, ; //DESCENG
	''																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	''																		} ) //SHOWPESQ

//
// Tabela ZZQ
//
aAdd( aSIX, { ;
	'ZZQ'																	, ; //INDICE
	'1'																		, ; //ORDEM
	'ZZQ_FILIAL+ZZQ_LOCAL+ZZQ_LOCALI+DTOS(ZZQ_DATA)'						, ; //CHAVE
	'Local + Localiz + Data'												, ; //DESCRICAO
	'Local + Localiz + Data'												, ; //DESCSPA
	'Local + Localiz + Data'												, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

//
// Tabela ZZR
//
aAdd( aSIX, { ;
	'ZZR'																	, ; //INDICE
	'1'																		, ; //ORDEM
	'ZZR_FILIAL+ZZR_CODCLI+ZZR_TIPCLI+ZZR_ESTADO'							, ; //CHAVE
	'Codigo+Tipo+Estado'													, ; //DESCRICAO
	'Codigo+Tipo+Estado'													, ; //DESCSPA
	'Codigo+Tipo+Estado'													, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

//
// Tabela CB8
//
aAdd( aSIX, { ;
	'CB8'																	, ; //INDICE
	'8'																		, ; //ORDEM
	'CB8_FILIAL+CB8_ORDSEP+CB8_LOCAL+CB8_XLCALI+CB8_PROD+CB8_LOTECT'		, ; //CHAVE
	'Numero Ordem + Armazem + Endereco + Produto + Lote'					, ; //DESCRICAO
	'Numero Ordem + Armazem + Endereco + Produto + Lote'					, ; //DESCSPA
	'Numero Ordem + Armazem + Endereco + Produto + Lote'					, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	'CB8XLOCALI'															, ; //NICKNAME
	'S'																		} ) //SHOWPESQ


//
// Tabela ZZO
//
aAdd( aSIX, { ;
	'ZZO'																	, ; //INDICE
	'1'																		, ; //ORDEM
	'ZZO_FILIAL+ZZO_PEDIDO+ZZO_OPERAD+ZZO_CLIENT+ZZO_LOJA+ZZO_PRODUT+DTOS(ZZO_DATA)', ; //CHAVE
	'Pedido + Operador + CLiente + Loja + Produto + Data'					, ; //DESCRICAO
	'Pedido + Operador + CLiente + Loja + Produto + Data'					, ; //DESCSPA
	'Pedido + Operador + CLiente + Loja + Produto + Data'					, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ
 
//
// Tabela SF1
//
aAdd( aSIX, { ;
	'SF1'																	, ; //INDICE
	'A'																		, ; //ORDEM
	'F1_FILIAL+F1_OK2'														, ; //CHAVE
	'Entrada N.F.                                       '					, ; //DESCRICAO
	'Entrada N.F.                                       '					, ; //DESCSPA
	'Entrada N.F.                                       '					, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	'F1OK2'																	, ; //NICKNAME
	''																		} ) //SHOWPESQ
                                                                                          
//
// Tabela SD1
//
aAdd( aSIX, { ;
	'SD1'																	, ; //INDICE
	'E'																		, ; //ORDEM
	'D1_FILIAL+D1_OP'														, ; //CHAVE
	'Ord Producao                                       '					, ; //DESCRICAO
	'Ord Producci										'					, ; //DESCSPA
	'Prod. order										'					, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	'D1OP'																	, ; //NICKNAME
	'N'																		} ) //SHOWPESQ    
                                                                                              

//
// Tabela SC6
//
aAdd( aSIX, { ;
	'SC6'																	, ; //INDICE
	'C'																		, ; //ORDEM
	'C6_FILIAL+C6_PEDCLI+C6_CLI+C6_LOJA+C6_PRODUTO'							, ; //CHAVE
	'Ped Cliente+Cliente+Loja+Produto                   '					, ; //DESCRICAO
	'Ped Cliente+Cliente+Tienda+Producto				'					, ; //DESCSPA
	'Custom.Order+Cliente+Tienda+Producto				'					, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	'C6PEDCLI'																, ; //NICKNAME
	'N'																		} ) //SHOWPESQ                                                                                                
    
    
//
// Tabela ZZS
//
aAdd( aSIX, { ;
	'ZZS'																	, ; //INDICE
	'1'																		, ; //ORDEM
	'ZZS_FILIAL+ZZS_CGC'													, ; //CHAVE
	'CNPJ'																	, ; //DESCRICAO
	'CNPJ'																	, ; //DESCSPA
	'CNPJ'																	, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	''																		} ) //SHOWPESQ    


//
// Tabela ZZT
//
aAdd( aSIX, { ;
	'ZZT'																	, ; //INDICE
	'1'																		, ; //ORDEM
	'ZZT_FILIAL+ZZT_PEDIDO+ZZT_ITEM'										, ; //CHAVE
	'PEDIDO + ITEM'															, ; //DESCRICAO
	''																		, ; //DESCSPA
	''																		, ; //DESCENG
	''																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	''																		} ) //SHOWPESQ    

//
// Tabela ZZU
//
aAdd( aSIX, { ;
	'ZZU'																	, ; //INDICE
	'1'																		, ; //ORDEM
	'ZZU_FILIAL+ZZU_CODPRO+ZZU_LOTECT+ZZU_LOCALI'							, ; //CHAVE
	'Produto+Lote+Locali'													, ; //DESCRICAO
	'Produto+Lote+Locali'													, ; //DESCSPA
	'Produto+Lote+Locali'													, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	''																		} ) //SHOWPESQ
        
//
// Tabela ZZV
//
aAdd( aSIX, { ;
	'ZZV'																	, ; //INDICE
	'1'																		, ; //ORDEM
	'ZZV_FILIAL+ZZV_TRANSP'													, ; //CHAVE
	'Cod. Transp.'															, ; //DESCRICAO
	'Cod. Transp.'															, ; //DESCSPA
	'Cod. Transp.'															, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

//
// Tabela ZZW
//
aAdd( aSIX, { ;
	'ZZW'																	, ; //INDICE
	'1'																		, ; //ORDEM
	'ZZW_FILIAL+ZZW_PEDIDO'													, ; //CHAVE
	'PEDIDO'																, ; //DESCRICAO
	'PEDIDO'																, ; //DESCSPA
	'PEDIDO'																, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	''																		} ) //SHOWPESQ

//
// Tabela ZZX
//
aAdd( aSIX, { ;
	'ZZX'																	, ; //INDICE
	'1'																		, ; //ORDEM
	'ZZX_FILIAL+ZZX_NOME'													, ; //CHAVE
	'Nome'																	, ; //DESCRICAO
	'Nome'																	, ; //DESCSPA
	'Nome'																	, ; //DESCENG
	'S'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ



aAdd( aSIX, { ;
	'ZZX'																	, ; //INDICE
	'2'																		, ; //ORDEM
	'ZZX_FILIAL+ZZX_CNPJ'													, ; //CHAVE
	'CNPJ'																	, ; //DESCRICAO
	'CNPJ'																	, ; //DESCSPA
	'CNPJ'																	, ; //DESCENG
	'S'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ


//
// Atualizando dicion·rio
//
oProcess:SetRegua2( Len( aSIX ) )

dbSelectArea( 'SIX' )
SIX->( dbSetOrder( 1 ) )

For nI := 1 To Len( aSIX )

                lAlt := .F.

                If !SIX->( dbSeek( aSIX[nI][1] + aSIX[nI][2] ) )
                               RecLock( 'SIX', .T. )
                               lDelInd := .F.
                               cTexto += 'Õndice criado ' + aSIX[nI][1] + '/' + aSIX[nI][2] + ' - ' + aSIX[nI][3] + CRLF
                Else
                               lAlt := .T.
                               RecLock( 'SIX', .F. )
                EndIf

                If StrTran( Upper( AllTrim( CHAVE )       ), ' ', '') <> ;
                   StrTran( Upper( AllTrim( aSIX[nI][3] ) ), ' ', '' )
                               aAdd( aArqUpd, aSIX[nI][1] )

                               If lAlt
                                               lDelInd := .T.  // Se for alteracao precisa apagar o indice do banco
                                               cTexto += 'Õndice alterado ' + aSIX[nI][1] + '/' + aSIX[nI][2] + ' - ' + aSIX[nI][3] + CRLF
                               EndIf

                               For nJ := 1 To Len( aSIX[nI] )
                                               If FieldPos( aEstrut[nJ] ) > 0
                                                               FieldPut( FieldPos( aEstrut[nJ] ), aSIX[nI][nJ] )
                                               EndIf
                               Next nJ

                               If lDelInd
                                               TcInternal( 60, RetSqlName( aSIX[nI][1] ) + '|' + RetSqlName( aSIX[nI][1] ) + aSIX[nI][2] ) // Exclui sem precisar baixar o TOP
                               EndIf

                EndIf

                dbCommit()
                MsUnLock()

                oProcess:IncRegua2( 'Atualizando Ìndices...' )

Next nI

cTexto += CRLF + 'Final da Atualizacao do SIX' + CRLF + Replicate( '-', 128 ) + CRLF + CRLF

Return cTexto
/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Rotina    ≥ESCEMPRESA∫Autor  ≥ Ernani Forastieri  ∫ Data ≥  27/09/04   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Descricao ≥ Funcao Generica para escolha de Empresa, montado pelo SM0_ ∫±±
±±∫          ≥ Retorna vetor contendo as selecoes feitas.                 ∫±±
±±∫          ≥ Se nao For marcada nenhuma o vetor volta vazio.            ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ Generico                                                   ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Static Function EscEmpresa()
//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥ Parametro  nTipo                           ≥
//≥ 1  - Monta com Todas Empresas/Filiais      ≥
//≥ 2  - Monta so com Empresas                 ≥
//≥ 3  - Monta so com Filiais de uma Empresa   ≥
//≥                                            ≥
//≥ Parametro  aMarcadas                       ≥
//≥ Vetor com Empresas/Filiais pre marcadas    ≥
//≥                                            ≥
//≥ Parametro  cEmpSel                         ≥
//≥ Empresa que sera usada para montar selecao ≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
Local   aSalvAmb := GetArea()
Local   aSalvSM0 := {}
Local   aRet     := {}
Local   aVetor   := {}
Local   oDlg     := NIL
Local   oChkMar  := NIL
Local   oLbx     := NIL
Local   oMascEmp := NIL
Local   oMascFil := NIL
Local   oButMarc := NIL
Local   oButDMar := NIL
Local   oButInv  := NIL
Local   oSay     := NIL
Local   oOk      := LoadBitmap( GetResources(), "LBOK" )
Local   oNo      := LoadBitmap( GetResources(), "LBNO" )
Local   lChk     := .F.
Local   lOk      := .F.
Local   lTeveMarc:= .F.
Local   cVar     := ""
Local   cNomEmp  := ""
Local   cMascEmp := "??"
Local   cMascFil := "??"

Local   aMarcadas  := {}


If !MyOpenSm0(.F.)
	Return aRet
EndIf


dbSelectArea( "SM0" )
aSalvSM0 := SM0->( GetArea() )
dbSetOrder( 1 )
dbGoTop()

While !SM0->( EOF() )

	If aScan( aVetor, {|x| x[2] == SM0->M0_CODIGO} ) == 0
		aAdd(  aVetor, { aScan( aMarcadas, {|x| x[1] == SM0->M0_CODIGO .and. x[2] == SM0->M0_CODFIL} ) > 0, SM0->M0_CODIGO, SM0->M0_CODFIL, SM0->M0_NOME, SM0->M0_FILIAL } )
	EndIf

	dbSkip()
End

RestArea( aSalvSM0 )

Define MSDialog  oDlg Title "" From 0, 0 To 270, 396 Pixel

oDlg:cToolTip := "Tela para M˙ltiplas SeleÁıes de Empresas/Filiais"

oDlg:cTitle   := "Selecione a(s) Empresa(s) para AtualizaÁ„o"

@ 10, 10 Listbox  oLbx Var  cVar Fields Header " ", " ", "Empresa" Size 178, 095 Of oDlg Pixel
oLbx:SetArray(  aVetor )
oLbx:bLine := {|| {IIf( aVetor[oLbx:nAt, 1], oOk, oNo ), ;
aVetor[oLbx:nAt, 2], ;
aVetor[oLbx:nAt, 4]}}
oLbx:BlDblClick := { || aVetor[oLbx:nAt, 1] := !aVetor[oLbx:nAt, 1], VerTodos( aVetor, @lChk, oChkMar ), oChkMar:Refresh(), oLbx:Refresh()}
oLbx:cToolTip   :=  oDlg:cTitle
oLbx:lHScroll   := .F. // NoScroll

@ 112, 10 CheckBox oChkMar Var  lChk Prompt "Todos"   Message  Size 40, 007 Pixel Of oDlg;
on Click MarcaTodos( lChk, @aVetor, oLbx )

@ 123, 10 Button oButInv Prompt "&Inverter"  Size 32, 12 Pixel Action ( InvSelecao( @aVetor, oLbx, @lChk, oChkMar ), VerTodos( aVetor, @lChk, oChkMar ) ) ;
Message "Inverter SeleÁ„o" Of oDlg

// Marca/Desmarca por mascara
@ 113, 51 Say  oSay Prompt "Empresa" Size  40, 08 Of oDlg Pixel
@ 112, 80 MSGet  oMascEmp Var  cMascEmp Size  05, 05 Pixel Picture "@!"  Valid (  cMascEmp := StrTran( cMascEmp, " ", "?" ), cMascFil := StrTran( cMascFil, " ", "?" ), oMascEmp:Refresh(), .T. ) ;
Message "M·scara Empresa ( ?? )"  Of oDlg
@ 123, 50 Button oButMarc Prompt "&Marcar"    Size 32, 12 Pixel Action ( MarcaMas( oLbx, aVetor, cMascEmp, .T. ), VerTodos( aVetor, @lChk, oChkMar ) ) ;
Message "Marcar usando m·scara ( ?? )"    Of oDlg
@ 123, 80 Button oButDMar Prompt "&Desmarcar" Size 32, 12 Pixel Action ( MarcaMas( oLbx, aVetor, cMascEmp, .F. ), VerTodos( aVetor, @lChk, oChkMar ) ) ;
Message "Desmarcar usando m·scara ( ?? )" Of oDlg

Define SButton From 111, 125 Type 1 Action ( RetSelecao( @aRet, aVetor ), oDlg:End() ) OnStop "Confirma a SeleÁ„o"  Enable Of oDlg
Define SButton From 111, 158 Type 2 Action ( IIf( lTeveMarc, aRet :=  aMarcadas, .T. ), oDlg:End() ) OnStop "Abandona a SeleÁ„o" Enable Of oDlg
Activate MSDialog  oDlg Center

RestArea( aSalvAmb )
dbSelectArea( "SM0" )
dbCloseArea()

Return  aRet


/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Rotina    ≥MARCATODOS∫Autor  ≥ Ernani Forastieri  ∫ Data ≥  27/09/04   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Descricao ≥ Funcao Auxiliar para marcar/desmarcar todos os itens do    ∫±±
±±∫          ≥ ListBox ativo                                              ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ Generico                                                   ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Static Function MarcaTodos( lMarca, aVetor, oLbx )
Local  nI := 0

For nI := 1 To Len( aVetor )
	aVetor[nI][1] := lMarca
Next nI

oLbx:Refresh()

Return NIL


/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Rotina    ≥INVSELECAO∫Autor  ≥ Ernani Forastieri  ∫ Data ≥  27/09/04   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Descricao ≥ Funcao Auxiliar para inverter selecao do ListBox Ativo     ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ Generico                                                   ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Static Function InvSelecao( aVetor, oLbx )
Local  nI := 0

For nI := 1 To Len( aVetor )
	aVetor[nI][1] := !aVetor[nI][1]
Next nI

oLbx:Refresh()

Return NIL


/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Rotina    ≥RETSELECAO∫Autor  ≥ Ernani Forastieri  ∫ Data ≥  27/09/04   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Descricao ≥ Funcao Auxiliar que monta o retorno com as selecoes        ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ Generico                                                   ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Static Function RetSelecao( aRet, aVetor )
Local  nI    := 0

aRet := {}
For nI := 1 To Len( aVetor )
	If aVetor[nI][1]
		aAdd( aRet, { aVetor[nI][2] , aVetor[nI][3], aVetor[nI][2] +  aVetor[nI][3] } )
	EndIf
Next nI

Return NIL


/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Rotina    ≥ MARCAMAS ∫Autor  ≥ Ernani Forastieri  ∫ Data ≥  20/11/04   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Descricao ≥ Funcao para marcar/desmarcar usando mascaras               ∫±±
±±∫          ≥                                                            ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ Generico                                                   ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Static Function MarcaMas( oLbx, aVetor, cMascEmp, lMarDes )
Local cPos1 := SubStr( cMascEmp, 1, 1 )
Local cPos2 := SubStr( cMascEmp, 2, 1 )
Local nPos  := oLbx:nAt
Local nZ    := 0

For nZ := 1 To Len( aVetor )
	If cPos1 == "?" .or. SubStr( aVetor[nZ][2], 1, 1 ) == cPos1
		If cPos2 == "?" .or. SubStr( aVetor[nZ][2], 2, 1 ) == cPos2
			aVetor[nZ][1] :=  lMarDes
		EndIf
	EndIf
Next

oLbx:nAt := nPos
oLbx:Refresh()

Return NIL


/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Rotina    ≥ VERTODOS ∫Autor  ≥ Ernani Forastieri  ∫ Data ≥  20/11/04   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Descricao ≥ Funcao auxiliar para verificar se estao todos marcardos    ∫±±
±±∫          ≥ ou nao                                                     ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ Generico                                                   ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Static Function VerTodos( aVetor, lChk, oChkMar )
Local lTTrue := .T.
Local nI     := 0

For nI := 1 To Len( aVetor )
	lTTrue := IIf( !aVetor[nI][1], .F., lTTrue )
Next nI

lChk := IIf( lTTrue, .T., .F. )
oChkMar:Refresh()

Return NIL


/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫ Programa ≥ MyOpenSM0∫ Autor ≥ TOTVS Protheus     ∫ Data ≥  13/07/12   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫ Descricao≥ Funcao de processamento abertura do SM0 modo exclusivo     ≥±±
±±∫          ≥                                                            ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±≥ Uso      ≥ MyOpenSM0  - Gerado por EXPORDIC / Upd. V.4.10.4 EFS       ≥±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Static Function MyOpenSM0(lShared)

Local lOpen := .F.
Local nLoop := 0

For nLoop := 1 To 20
	dbUseArea( .T., , "SIGAMAT.EMP", "SM0", lShared, .F. )

	If !Empty( Select( "SM0" ) )
		lOpen := .T.
		dbSetIndex( "SIGAMAT.IND" )
		Exit
	EndIf

	Sleep( 500 )

Next nLoop

If !lOpen
	MsgStop( "N„o foi possÌvel a abertura da tabela " + ;
	IIf( lShared, "de empresas (SM0).", "de empresas (SM0) de forma exclusiva." ), "ATEN«√O" )
EndIf

Return lOpen 

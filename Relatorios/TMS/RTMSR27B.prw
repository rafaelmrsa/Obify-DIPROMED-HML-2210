#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPrintSetup.ch"

#DEFINE VBOX      080
#DEFINE VSPACE    008 
#DEFINE HSPACE    010
#DEFINE SAYVSPACE 008
#DEFINE SAYHSPACE 008
#DEFINE HMARGEM   030
#DEFINE VMARGEM   030
#DEFINE MAXITEM   Max((022-Max(0,Len(aMensagem)-02)),1)
#DEFINE MAXITEMP2 055
#DEFINE MAXMENLIN 070

#DEFINE doDTC_SERNFC	1
#DEFINE doDTC_NUMNFC	2
#DEFINE doDTC_EMINFC	3
#DEFINE doDTC_VALOR		4
#DEFINE doDTC_PESO		5
#DEFINE doDTC_CLIDEV	6
#DEFINE doDTC_LOJDEV	7
#DEFINE doDTC_NFEID		8

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �RTMSR27B  � Autor �Felipe Cunha           � Data �01/10/12  ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Funcao responsavel por imprimir o DACTE.                    ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Nenhum                                                      ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Nenhum                                                      ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���          �               �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
User Function RTMSR27B()
Local nCount		:= 0
Local nSoma			:= 0
Local nCInic		:= 0	// Coluna Inicial
Local cChaveA		:= ''
Local cChaveB		:= ''
Local cTmsAntt		:= SuperGetMv( "MV_TMSANTT", .F., .F. )	//Numero do registro na ANTT com 14 d�gitos
Local cAliasD2		:= ''
Local cAliasDev		:= ''
Local aCab			:= {}
Local aDoc			:= {}
Local oFont07		:= TFont():New("Times New Roman",08,08,,.F.,,,,.T.,.F.)
Local oFont07N		:= TFont():New("Times New Roman",07,07,,.T.,,,,.T.,.F.)
Local oFont08		:= TFont():New("Times New Roman",08,08,,.F.,,,,.T.,.F.)
Local oFont08N		:= TFont():New("Times New Roman",08,08,,.T.,,,,.T.,.F.)
Local oFont10N		:= TFont():New("Times New Roman",10,10,,.T.,,,,.T.,.F.)
Local lControl		:= .F.
Local cAliasInfNF	:= ''
Local cAliasSeg		:= ''
Local cPerg			:= 'RTMSR25'
Local nCont			:= 0
Local lSeqDes		:= .F.
Local lSeqRec		:= .F.
Local cDT6Obs		:= ''
Local cDT6Obs2		:= ''
Local cDT6Obs3		:= ''
Local cDTCObs		:= ''
Local cDTCObs2		:= ''
Local cDTCObs3		:= ''
Local cDTCObs4		:= ''
Local cDTCObs5		:= ''
Local cObsProp		:= ''
Local cObsStat		:= ''
Local nCountObs		:= ''
Local aTagObs		   := ''
Local nLinhaObs      := 0
Local aObsCont		:= ''
Local cTipoNF		:= ''
Local cCtrDpc		:= ''
Local cSerDpc		:= ''
Local cTpDocAnt		:= ''
Local cCTEDocAnt	:= ''
//-- Buscar dados XML
Local aNotas		:= {}
Local aXML			:= {}
Local cAviso		:= ""
Local cErro			:= ""
Local cAutoriza		:= ""
Local cHorAut		:= ""
Local cDatAut		:= ""
Local cModalidade	:= ""
Local cIdEnt		:= ""
Local nX			:= 0
Local nY			:= 0
//-- CFOP - Natureza da Prestacao
Local cCFOP			:= ''
Local cDescCfop		:= ''
//-- Origem Prestacao
Local cOriMunPre	:= ""
Local cOriUFPre		:= ""
//-- Destino Prestacao
Local cDesMunPre	:= ""
Local cDesUFPre		:= ""
//-- Remetente
Local cRemMun		:= ""
Local cRemUF		:= ""
Local cRemNome		:= ""
Local cRemEnd		:= ""
Local cRemNro		:= ""
Local cRemCompl		:= ""
Local cRemBair		:= ""
Local cRemCEP		:= ""
Local cRemCNPJ		:= ""
Local cRemIE		:= ""
Local cRemPais		:= ""
Local cRemFone		:= ""
//-- Destinatario
Local cDesMun		:= ""
Local cDesUF		:= ""
Local cDesNome		:= ""
Local cDesEnd		:= ""
Local cDesNro		:= ""
Local cDesCompl		:= ""
Local cDesBair		:= ""
Local cDesCEP		:= ""
Local cDesCNPJ		:= ""
Local cDesIE		:= ""
Local cDesPais		:= ""
Local cDesFone		:= ""
//-- Expedidor
Local cExpNome		:= ""
Local cExpEnd		:= ""
Local cExpNro		:= ""
Local cExpMun		:= ""
Local cExpBai		:= ""
Local cExpUF		:= ""
Local cExpDoc		:= ""	// CNPJ / CPF
Local cExpPais		:= ""
//-- Recebedor
Local cRecNome		:= ""
Local cRecEnd		:= ""
Local cRecBai		:= ""
Local cRecMun		:= ""
Local cRecUF		:= ""
Local lRecPJ		:= .F.
Local cRecCGC		:= ""
Local cRecCPF		:= ""
Local cRecINSCR		:= ""
Local cRecPais	:= ""
//-- Tomador do Servico
Local cDevMun		:= ""
Local cDevUF		:= ""
Local cDevNome		:= ""
Local cDevEnd		:= ""
Local cDevNro		:= ""
Local cDevCompl		:= ""
Local cDevBair		:= ""
Local cDevCEP		:= ""
Local cDevCNPJ		:= ""
Local cDevIE		:= ""
Local cDevPais		:= ""
Local cDevFone		:= ""
//-- Produto Predominante
Local cPPDesc		:= ""
Local cPPCarga		:= ""
Local cPPVlTot		:= ""
Local cPPPesoB		:= ""
Local cPPPeso3		:= ""
Local cPPMetro3		:= ""
Local cPPQtdVol		:= ""
//-- Dados Seguradora
Local cSegNome		:= ""
Local cSegResp		:= ""
Local cSegDesc		:= ""
Local cSegNrApoli	:= ""
Local cSegNrAverb	:= ""
//-- Documentos Originarios
Local aDocOri		:= {}
//Lota��o
Local lLotacao		:= .F.
Local cPlaca		:= ""
Local cUf			:= ""
Local cRNTRC		:= ""
Local cCodMoto		:= ""
Local cCpfMoto		:= ""
Local cNomeMoto		:= ""
Local cLacre		:= ""
Local nQtdDev		:= 0
Local cDesDocAnt	:= ""
Local cRNLotacao	:= ""
Local cRNDtPrv		:= ""
Local cRNMensagem	:= ""
Local cCliente		:= ""
Local cLoja			:= ""
Local cAliasPeri	:= ""
Local lPerig		:= .F.	//-- Informa se ha produtos perigosos
Local cStartPath
Local aMotoViag		:= {}
Local cTipoDoc		:= ''
Local cNumSol 		:= '' 
Local cFilCFS 		:= ''
Local cDtEntr 		:= ''
Local cTagObs			:= ''
//-- Variaveis Private
Private cAliasCT	:= GetNextAlias()
Private oDacte
Private nLInic		:= 0	// Linha Inicial
Private nLFim		:= 0	// Linha Inicial
Private nDifEsq		:= 0	// Variavel com Diferenca para alinhar os Print da Esquerda com os da Direita
Private cInsRemOpc	:= ''	// Remetente com sequencia de IE
Private nFolhas		:= 0
Private nFolhAtu	:= 1
Private PixelX		:= nil
Private PixelY		:= nil
Private nMM			:= 0
Private lComp		:= .F.	//CTE Complementar
Private cFilVia		:= ""
Private cViagem		:= ""
Private cVersaoCTE	:= ""
Private lUsaColab	:= UsaColaboracao("2")
Private lMultModal := .F.

//-- Verifica se o arquivo sera gerado em Remote Linux
cStartPath := GetTempPath(.T.)

AjustaSX1()

//-- MV_PAR01 - Informe lote inicial.
//-- MV_PAR02 - Informe lote final.
//-- MV_PAR03 - Informe documento inicial.
//-- MV_PAR04 - Informe documento final.
//-- MV_PAR05 - Informe serie do documento inicial.
//-- MV_PAR06 - Informe serie do documento final.
//-- MV_PAR07 - Informe tipo do documento.
//-- MV_PAR08 - Buscar XML do WebService.

If !("DIPM027" $ FunName())
	If !Pergunte(cPerg,.T.)
		Return()
	EndIf
EndIf

cSQL := " SELECT DISTINCT "
cSQL += " 	DT6_CLIREM "
cSQL += " 	FROM "
cSQL += 		RetSQLName("DT6")
cSQL += " 		WHERE "
cSQL += " 			DT6_FILIAL = '"+xFilial("DT6")+"' AND "
cSQL += " 			DT6_LOTNFC BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"' AND "
cSQL += " 			D_E_L_E_T_ = ' ' "  

cSQL := ChangeQuery(cSQL)
DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cSQL),"QRYDT6",.T.,.T.)
   
_cDipCli := ""
While !QRYDT6->(Eof())              
    If Empty(_cDipCli)
		_cDipCli := QRYDT6->DT6_CLIREM
	ElseIf _cDipCli <> QRYDT6->DT6_CLIREM
		Aviso("Aten��o","S� � permitido informar lotes de um mesmo remetente",{"Ok"},1)  
		QRYDT6->(dbCloseArea())
		Return
	EndIf
	QRYDT6->(dbSkip())
EndDo
QRYDT6->(dbCloseArea())

If	!lUsaColab .And. !TMSSpedNFe(@cIdEnt,@cModalidade,@cVersaoCTE,lUsaColab)
	Return()
EndIf

// Cria Arquivo de Trabalho - Documentos de Transporte
cAliasCT := DataSource( 'DT6' )
oDacte := FWMSPrinter():New("DACTE",IMP_PDF,.F.,/*cStartPath*/ , /*.T.*/,,@oDacte,,,,,.T.)
oDacte:SetResolution(72)
oDacte:SetPortrait()
oDacte:SetPaperSize(DMPAPER_A4)
oDacte:SetMargin(60,60,60,60)
oDacte:cPathPDF := cStartPath    

If oDacte:nModalResult <> 1
  oDacte:Cancel()        
EndIf

If oDacte:Canceled()
	oDacte:DeActivate()
	Return(.T.)
EndIf

PixelX  := oDacte:nLogPixelX()
PixelY  := oDacte:nLogPixelY()
nMM     := 0

While !(cAliasCT)->(Eof())

	oDacte:StartPage()
	cLacre := ""
	lLotacao := .F.

	cExpMun		:= ""
	cExpUF		:= ""
	cExpNome	:= ""
	cExpEnd		:= ""
	cExpNro		:= ""
	cExpCompl	:= ""
	cExpBai		:= ""
	cExpCEP		:= ""
	cExpCNPJ	:= ""
	cExpIE		:= ""
	cExpPais	:= ""
	cExpFone	:= ""
	cHorAut		:= ""
	cDatAut		:= ""
	lExped		:= .F.

	//-- Buscar XML do WebService
	aNotas := {}
	aadd(aNotas,{})
	aAdd(Atail(aNotas),.F.)

	aadd(Atail(aNotas),"S") //IIF(MV_PAR04==1,"E","S"))
	aAdd(Atail(aNotas),"")
	aAdd(Atail(aNotas),(cAliasCT)->DT6_SERIE) //SERIE
	aAdd(Atail(aNotas),(cAliasCT)->DT6_DOC) //Documento
	aadd(Atail(aNotas),"")
	aadd(Atail(aNotas),"")

	nX   := 1
	aXml := {}
	If lUsaColab
		//-- TOTVS Colaboracao 2.0
		aXml := TMSColXML(aNotas,@cModalidade,lUsaColab)
	Else
		aXml := TMSGetXML(cIdEnt,aNotas,@cModalidade)
	EndIf
	If !Empty(aXML[nX][2])
		If !Empty(aXml[nX])
			cAutoriza   := aXML[nX][1]
			cCodAutDPEC := aXML[nX][5]
			cHorAut     := IIF(!Empty(aXML[nX][6]),aXML[nX][6],"")		//-- Data autorizacao
			cDatAut     := IIF(!Empty(aXML[nX][7]),DToC(aXML[nX][7]),"")	//-- Hora autorizacao
		Else
			cAutoriza   := ""
			cCodAutDPEC := ""
		EndIf
		cAviso := ""
		cErro  := ""
		oNfe := XmlParser(aXML[nX][2],"_",@cAviso,@cErro)
		oNfeDPEC := XmlParser(aXML[nX][4],"_",@cAviso,@cErro)
		
		If Type( 'oNFE' ) == 'U'
			(cAliasCT)->(DbSkip())
			Loop
		EndIf
		
		If (!Empty(cAutoriza) .Or. !Empty(cCodAutDPEC) .Or. !cModalidade$"1,4,5,6")
			If aNotas[nX][02]=="S"
				dbSelectArea("SF2")
				dbSetOrder(1)
				If MsSeek(xFilial("SF2")+aNotas[nX][05]+aNotas[nX][04]) .And. cModalidade$"1,4,6"
					RecLock("SF2")
					If !SF2->F2_FIMP$"D"
						SF2->F2_FIMP := "S"
					EndIf
					If SF2->(FieldPos("F2_CHVNFE"))>0
						SF2->F2_CHVNFE := SubStr(NfeIdSPED(aXML[nX][2],"Id"),4)
					EndIf
					MsUnlock()
				EndIf
			EndIf
		EndIf
	EndIf
	
	If Type( 'oNFE' ) == 'U'
		(cAliasCT)->(DbSkip())
		Loop 
	EndIf

	//������������������������������������������������������������������������Ŀ
	//� Seleciona a qtde de registros, p/ calcular a qtde de folhas            �
	//��������������������������������������������������������������������������
	cAliasInfNF := DataSource( 'DTC' )
	If (cAliasInfNF)->nTotal > 0
		If (cAliasInfNF)->nTotal <= 10
			nFolhas := 1
		Else
			nFolhas := (cAliasInfNF)->nTotal - 10	//-- Qtde da primeira paginas.
			nFolhas := Int(( nFolhas / 74 ) + 2)	//-- Qtde da outras paginas.
		EndIf
	EndIf
	(cAliasInfNF)->(DbCloseArea())	

	//������������������������������������������������������������������������Ŀ
	//� Controla o documento a ser enviado para montagem do cabecalho.         �
	//��������������������������������������������������������������������������
	nCont += 1
		aAdd(aCab, {;
		AllTrim((cAliasCT)->DT6_DOC),;
		AllTrim(oNfe:_CTE:_INFCTE:_IDE:_SERIE:TEXT),;
		AllTrim(STRTRAN( SUBSTR( oNfe:_CTE:_INFCTE:_IDE:_dhEmi:TEXT, 1, AT('T', oNfe:_CTE:_INFCTE:_IDE:_dhEmi:TEXT) - 1) , '-', '')),;
		AllTrim(STRTRAN( SUBSTR( oNfe:_CTE:_INFCTE:_IDE:_dhEmi:TEXT, AT('T', oNfe:_CTE:_INFCTE:_IDE:_dhEmi:TEXT) + 1, 5) , ':', '')),;
		AllTrim(STRTRAN(UPPER(oNFE:_CTE:_INFCTE:_ID:TEXT),'CTE','')),;
		(cAliasCT)->DT6_PROCTE,"" ,cDatAut, cHorAut})	//-- Nao possui ref. no XML
	
	//������������������������������������������������������������������������Ŀ
	//� Funcao responsavel por montar o cabecalho do relatorio                 �
	//��������������������������������������������������������������������������
	nFolhAtu := 1
	lSeqDes  :=.F.
	lSeqRec  :=.F.
	TMSR27Cab(aCab[nCont],.T.)

	//-- Estrutura da funcao que retorna o logradouro, numero e complemento.
	//-- Logradouro		FisGetEnd(XXXXXXXX)[1]
	//-- Numero			FisGetEnd(XXXXXXXX)[2]
	//-- Complemento	FisGetEnd(XXXXXXXX)[4]

		//-- CFOP
		cCFOP		:= AllTrim(oNfe:_CTE:_INFCTE:_IDE:_CFOP:TEXT)
		cDescCfop	:= AllTrim(oNfe:_CTE:_INFCTE:_IDE:_NATOP:TEXT)

		//-- Origem da Prestacao
		cOriMunPre	:= Iif(Type("oNfe:_CTE:_INFCTE:_IDE:_XMUNINI:TEXT")=="U"," ",oNfe:_CTE:_INFCTE:_IDE:_XMUNINI:TEXT)
		cOriUFPre	:= oNfe:_CTE:_INFCTE:_IDE:_UFINI:TEXT

		//-- Destino da Prestacao
		cDesMunPre	:= oNfe:_CTE:_INFCTE:_IDE:_XMUNFIM:TEXT
		cDesUFPre	:= oNfe:_CTE:_INFCTE:_IDE:_UFFIM:TEXT

		//-- Remetente
		cRemMun   := oNfe:_CTE:_INFCTE:_REM:_ENDERREME:_XMUN:TEXT
		cRemUF    := oNfe:_CTE:_INFCTE:_REM:_ENDERREME:_UF:TEXT
		cRemNome  := oNfe:_CTE:_INFCTE:_REM:_XNOME:TEXT
		cRemEnd   := oNfe:_CTE:_INFCTE:_REM:_ENDERREME:_XLGR:TEXT
		cRemNro   := oNfe:_CTE:_INFCTE:_REM:_ENDERREME:_NRO:TEXT
		cRemCompl := ""
		cRemBair  := oNfe:_CTE:_INFCTE:_REM:_ENDERREME:_XBAIRRO:TEXT
		cRemCEP   := oNfe:_CTE:_INFCTE:_REM:_ENDERREME:_CEP:TEXT
		cRemCNPJ  := Iif(Type("oNfe:_CTE:_INFCTE:_REM:_CNPJ:TEXT")=="U",oNfe:_CTE:_INFCTE:_REM:_CPF:TEXT,oNfe:_CTE:_INFCTE:_REM:_CNPJ:TEXT)
		cRemIE    := Iif(Type("oNfe:_CTE:_INFCTE:_REM:_IE:TEXT"  )=="U"," ",oNfe:_CTE:_INFCTE:_REM:_IE:TEXT)
		cRemPais  := Iif(Type("oNfe:_CTE:_INFCTE:_REM:_ENDERREME:_XPAIS:TEXT")=="U"," ",oNfe:_CTE:_INFCTE:_REM:_ENDERREME:_XPAIS:TEXT)
		cRemFone  := Iif(Type("oNfe:_CTE:_INFCTE:_REM:_FONE:TEXT")=="U"," ",oNfe:_CTE:_INFCTE:_REM:_FONE:TEXT)

		//-- Local de Coleta
		If (Type("oNfe:_CTE:_INFCTE:_REM:_LOCCOLETA")) <> "U"
			cExpMun	:= oNfe:_CTE:_INFCTE:_REM:_LOCCOLETA:_XMUN:TEXT
			cExpUF		:= oNfe:_CTE:_INFCTE:_REM:_LOCCOLETA:_UF:TEXT
			cExpNome	:= oNfe:_CTE:_INFCTE:_REM:_LOCCOLETA:_XNOME:TEXT
			cExpEnd	:= oNfe:_CTE:_INFCTE:_REM:_LOCCOLETA:_XLGR:TEXT
			cExpNro	:= oNfe:_CTE:_INFCTE:_REM:_LOCCOLETA:_NRO:TEXT
			cExpCompl 	:= ""
			cExpBai	:= oNfe:_CTE:_INFCTE:_REM:_LOCCOLETA:_XBAIRRO:TEXT
			cExpCEP   	:= ""
			cExpCNPJ  	:= Iif(Type("oNfe:_CTE:_INFCTE:_REM:_LOCCOLETA:_CNPJ:TEXT")=="U", oNfe:_CTE:_INFCTE:_REM:_LOCCOLETA:_CPF:TEXT , oNfe:_CTE:_INFCTE:_REM:_LOCCOLETA:_CNPJ:TEXT)
			cExpIE    	:= ""
			cExpPais  	:= cRemPais
			cExpFone  	:= ""
		EndIf
		
		//-- Expedidor
		If (Type("oNfe:_CTE:_INFCTE:_EXPED")) <> "U"
			lExped		:= .T.
			cExpMun	:= oNfe:_CTE:_INFCTE:_EXPED:_ENDEREXPED:_XMUN:TEXT
			cExpUF		:= oNfe:_CTE:_INFCTE:_EXPED:_ENDEREXPED:_UF:TEXT
			cExpNome	:= oNfe:_CTE:_INFCTE:_EXPED:_XNOME:TEXT
			cExpEnd	:= oNfe:_CTE:_INFCTE:_EXPED:_ENDEREXPED:_XLGR:TEXT
			cExpNro	:= oNfe:_CTE:_INFCTE:_EXPED:_ENDEREXPED:_NRO:TEXT
			cExpCompl 	:= ""
			cExpBai	:= oNfe:_CTE:_INFCTE:_EXPED:_ENDEREXPED:_XBAIRRO:TEXT
			cExpCEP   := oNfe:_CTE:_INFCTE:_EXPED:_ENDEREXPED:_CEP:TEXT
			cExpCNPJ  := Iif(Type("oNfe:_CTE:_INFCTE:_EXPED:_CNPJ:TEXT")=="U", oNfe:_CTE:_INFCTE:_EXPED:_CPF:TEXT , oNfe:_CTE:_INFCTE:_EXPED:_CNPJ:TEXT)
			cExpIE    := Iif(Type("oNfe:_CTE:_INFCTE:_EXPED:_IE:TEXT"  )=="U"," ",oNfe:_CTE:_INFCTE:_EXPED:_IE:TEXT)
			cExpPais  := Iif(Type("oNfe:_CTE:_INFCTE:_EXPED:_ENDEREXPED:_XPAIS:TEXT")=="U"," ",oNfe:_CTE:_INFCTE:_EXPED:_ENDEREXPED:_XPAIS:TEXT)
			cExpFone  := Iif(Type("oNfe:_CTE:_INFCTE:_EXPED:_FONE:TEXT")=="U"," ",oNfe:_CTE:_INFCTE:_EXPED:_FONE:TEXT)
		EndIf

		//-- Destinatario
		cDesMun   := oNfe:_CTE:_INFCTE:_DEST:_ENDERDEST:_XMUN:TEXT
		cDesUF    := oNfe:_CTE:_INFCTE:_DEST:_ENDERDEST:_UF:TEXT
		cDesNome  := oNfe:_CTE:_INFCTE:_DEST:_XNOME:TEXT
		cDesEnd   := oNfe:_CTE:_INFCTE:_DEST:_ENDERDEST:_XLGR:TEXT
		cDesNro   := oNfe:_CTE:_INFCTE:_DEST:_ENDERDEST:_NRO:TEXT
		cDesCompl := ""
		cDesBair  := oNfe:_CTE:_INFCTE:_DEST:_ENDERDEST:_XBAIRRO:TEXT
		cDesCEP   := oNfe:_CTE:_INFCTE:_DEST:_ENDERDEST:_CEP:TEXT
		cDesCNPJ  := Iif(Type("oNfe:_CTE:_INFCTE:_DEST:_CNPJ:TEXT")=="U",    oNfe:_CTE:_INFCTE:_DEST:_CPF:TEXT, oNfe:_CTE:_INFCTE:_DEST:_CNPJ:TEXT)
		cDesIE    := Iif(Type("oNfe:_CTE:_INFCTE:_DEST:_IE:TEXT"  )=="U"," ",oNfe:_CTE:_INFCTE:_DEST:_IE:TEXT)
		cDesPais  := Iif(Type("oNfe:_CTE:_INFCTE:_DEST:_ENDERDEST:_XPAIS:TEXT")=="U"," ",oNfe:_CTE:_INFCTE:_DEST:_ENDERDEST:_XPAIS:TEXT)
		cDesFone  := Iif(Type("oNfe:_CTE:_INFCTE:_DEST:_FONE:TEXT")=="U"," ",oNfe:_CTE:_INFCTE:_DEST:_FONE:TEXT)

		//-- Local de Entrega

		If (Type("oNfe:_CTE:_INFCTE:_DEST:_LOCENT")) <> "U"
			lSeqDes := .T.
			//Destino Prestacao
			cRecNome	:= oNfe:_CTE:_INFCTE:_DEST:_LOCENT:_XNOME:TEXT
			cRecEnd		:= oNfe:_CTE:_INFCTE:_DEST:_LOCENT:_XLGR:TEXT + ", " + oNfe:_CTE:_INFCTE:_DEST:_LOCENT:_NRO:TEXT
			cRecBai		:= oNfe:_CTE:_INFCTE:_DEST:_LOCENT:_XBAIRRO:TEXT
			cRecMun		:= oNfe:_CTE:_INFCTE:_DEST:_LOCENT:_XMUN:TEXT
			crecUF		:= oNfe:_CTE:_INFCTE:_DEST:_LOCENT:_UF:TEXT
			If Type("oNfe:_CTE:_INFCTE:_DEST:_LOCENT:_CNPJ:TEXT")=="U"
				cRecCPF	:= oNfe:_CTE:_INFCTE:_DEST:_LOCENT:_CPF:TEXT
			Else
				cRecCGC	:= oNfe:_CTE:_INFCTE:_DEST:_LOCENT:_CNPJ:TEXT
				cRecINSCR := oNfe:_CTE:_INFCTE:_DEST:_IE:TEXT
				lRecPJ	:= .T.
			EndIf
		ElseIf (Type("oNfe:_CTE:_INFCTE:_RECEB:_ENDERRECEB")) <> "U"
			lSeqRec := .T.
			//Destino Recebedor
			cRecNome	:= oNfe:_CTE:_INFCTE:_RECEB:_XNOME:TEXT
			cRecEnd		:= oNfe:_CTE:_INFCTE:_RECEB:_ENDERRECEB:_XLGR:TEXT + ", " + oNfe:_CTE:_INFCTE:_RECEB:_ENDERRECEB:_NRO:TEXT
			cRecBai		:= oNfe:_CTE:_INFCTE:_RECEB:_ENDERRECEB:_XBAIRRO:TEXT
			cRecMun		:= oNfe:_CTE:_INFCTE:_RECEB:_ENDERRECEB:_XMUN:TEXT
			crecUF		:= oNfe:_CTE:_INFCTE:_RECEB:_ENDERRECEB:_UF:TEXT
			cRecPais  		:= Iif(Type("oNfe:_CTE:_INFCTE:_RECEB:_ENDERRECEB:_XPAIS:TEXT")=="U"," ",oNfe:_CTE:_INFCTE:_RECEB:_ENDERRECEB:_XPAIS:TEXT)
			If Type("oNfe:_CTE:_INFCTE:_RECEB:_CNPJ:TEXT")=="U"
				cRecCPF	:= oNfe:_CTE:_INFCTE:_RECEB:_CPF:TEXT
			Else
				cRecCGC	:= oNfe:_CTE:_INFCTE:_RECEB:_CNPJ:TEXT
				cRecINSCR := oNfe:_CTE:_INFCTE:_RECEB:_IE:TEXT
				lRecPJ	:= .T.
			EndIf		
		EndIf

		//-- Produto Predominante
		If (Type("oNFE:_CTE:_INFCTE:_INFCTENORM")) <> "U"
			cPPDesc			:= oNFE:_CTE:_INFCTE:_INFCTENORM:_INFCARGA:_PROPRED:TEXT
			cPPCarga		:= oNFE:_CTE:_INFCTE:_INFCTENORM:_INFCARGA:_XOUTCAT:TEXT
			If Type("oNFE:_CTE:_INFCTE:_INFCTENORM:_INFCARGA:_VMERC") <> "U"
				cPPVlTot	:= oNFE:_CTE:_INFCTE:_INFCTENORM:_INFCARGA:_VMERC:TEXT
			Else
				cPPVlTot	:= oNFE:_CTE:_INFCTE:_INFCTENORM:_INFCARGA:_VCARGA:TEXT
			EndIf
			If ValType( oNFE:_CTE:_INFCTE:_INFCTENORM:_INFCARGA:_INFQ ) == 'A'
				For nCount := 1 To Len( oNFE:_CTE:_INFCTE:_INFCTENORM:_INFCARGA:_INFQ )
					Do Case
						Case oNFE:_CTE:_INFCTE:_INFCTENORM:_INFCARGA:_INFQ[ nCount ]:_TPMED:TEXT == "PESO DECLARADO"
							cPPPesoB := oNFE:_CTE:_INFCTE:_INFCTENORM:_INFCARGA:_INFQ[ nCount ]:_QCARGA:TEXT
						Case oNFE:_CTE:_INFCTE:_INFCTENORM:_INFCARGA:_INFQ[ nCount ]:_TPMED:TEXT == "PESO CUBADO"
							cPPPeso3 := oNFE:_CTE:_INFCTE:_INFCTENORM:_INFCARGA:_INFQ[ nCount ]:_QCARGA:TEXT
						Case oNFE:_CTE:_INFCTE:_INFCTENORM:_INFCARGA:_INFQ[ nCount ]:_TPMED:TEXT == "LITRAGEM"
							cPPQtdVol := oNFE:_CTE:_INFCTE:_INFCTENORM:_INFCARGA:_INFQ[ nCount ]:_QCARGA:TEXT
						Case oNFE:_CTE:_INFCTE:_INFCTENORM:_INFCARGA:_INFQ[ nCount ]:_TPMED:TEXT == "VOLUME"
							cPPQtdVol := oNFE:_CTE:_INFCTE:_INFCTENORM:_INFCARGA:_INFQ[ nCount ]:_QCARGA:TEXT
						Case oNFE:_CTE:_INFCTE:_INFCTENORM:_INFCARGA:_INFQ[ nCount ]:_TPMED:TEXT == "METROS CUBICOS"
							cPPMetro3 := oNFE:_CTE:_INFCTE:_INFCTENORM:_INFCARGA:_INFQ[ nCount ]:_QCARGA:TEXT
					EndCase
				Next nCount
			EndIf
		EndIf

		//-- Dados Seguradora
		If (Type("oNFE:_CTE:_INFCTE:_INFCTENORM:_SEG")) <> "U"
			cSegDesc	:= ""
			If (Type("oNFE:_CTE:_INFCTE:_INFCTENORM:_SEG[1]:_XSEG")) <> "U"
				cSegNome	:= oNFE:_CTE:_INFCTE:_INFCTENORM:_SEG[1]:_XSEG:TEXT
			ElseIf (Type("oNFE:_CTE:_INFCTE:_INFCTENORM:_SEG:_XSEG")) <> "U"
				cSegNome	:= oNFE:_CTE:_INFCTE:_INFCTENORM:_SEG:_XSEG:TEXT			
			EndIf
			If (Type("oNFE:_CTE:_INFCTE:_INFCTENORM:_SEG[1]:_RESPSEG")) <> "U"
				cSegResp	:= oNFE:_CTE:_INFCTE:_INFCTENORM:_SEG[1]:_RESPSEG:TEXT
			ElseIf (Type("oNFE:_CTE:_INFCTE:_INFCTENORM:_SEG:_RESPSEG")) <> "U"
				cSegResp	:= oNFE:_CTE:_INFCTE:_INFCTENORM:_SEG:_RESPSEG:TEXT	
			EndIf
			If (Type("oNFE:_CTE:_INFCTE:_INFCTENORM:_SEG[1]:_NAPOL")) <> "U"
				cSegNrApoli	:= oNFE:_CTE:_INFCTE:_INFCTENORM:_SEG[1]:_NAPOL:TEXT
			ElseIf (Type("oNFE:_CTE:_INFCTE:_INFCTENORM:_SEG:_NAPOL")) <> "U"
				cSegNrApoli	:= oNFE:_CTE:_INFCTE:_INFCTENORM:_SEG:_NAPOL:TEXT	
			EndIf
			If (Type("oNFE:_CTE:_INFCTE:_INFCTENORM:_SEG[1]:_NAVER")) <> "U"
				cSegNrAverb	:= oNFE:_CTE:_INFCTE:_INFCTENORM:_SEG[1]:_NAVER:TEXT // Campo nao obrigatorio.
			ElseIf (Type("oNFE:_CTE:_INFCTE:_INFCTENORM:_SEG:_NAVER")) <> "U"
				cSegNrAverb	:= oNFE:_CTE:_INFCTE:_INFCTENORM:_SEG:_NAVER:TEXT // Campo nao obrigatorio.	
			EndIf
			//-- Responsavel pelo Seguro
			If	cSegResp == "0"
				 cSegDesc := "Remetente"
			ElseIf	cSegResp == "1"
				cSegDesc := "Expedidor"
			ElseIf	cSegResp == "2"
				cSegDesc := "Recebedor"
			ElseIf	cSegResp == "3"
				cSegDesc := "Destinatario"
			ElseIf	cSegResp == "4"
				cSegDesc := "Emitente do CT-e"
			ElseIf 	cSegResp == "5"
				cSegDesc := "Tomador de Servico"
			EndIf
		EndIf

		//-- Tomador
		//����������������������������Ŀ
		//� Tomador do Servico         �
		//� 0 - Remetente;             �
		//� 1 - Expedidor;             �
		//� 2 - Recebedor;             �
		//� 3 - Destinatario.          �
		//������������������������������
		If Type("oNfe:_CTE:_INFCTE:_IDE:_TOMA3:_TOMA:TEXT") <> "U"
			If oNfe:_CTE:_INFCTE:_IDE:_TOMA3:_TOMA:TEXT == "0"
				cDevMun   := cRemMun
				cDevUF    := cRemUF
				cDevNome  := cRemNome
				cDevEnd   := cRemEnd
				cDevNro   := cRemNro
				cDevCompl := cRemCompl
				cDevBair  := cRemBair
				cDevCEP   := cRemCEP
				cDevCNPJ  := cRemCNPJ
				cDevIE    := cRemIE
				cDevPais  := cRemPais
				cDevFone  := cRemFone
			Else
				cDevMun   := cDesMun
				cDevUF    := cDesUF
				cDevNome  := cDesNome
				cDevEnd   := cDesEnd
				cDevNro   := cDesNro
				cDevCompl := cDesCompl
				cDevBair  := cDesBair
				cDevCEP   := cDesCEP
				cDevCNPJ  := cDesCNPJ
				cDevIE    := cDesIE
				cDevPais  := cDesPais
				cDevFone  := cDesFone
			EndIf
		ElseIf Type("oNfe:_CTE:_INFCTE:_IDE:_TOMA4:_TOMA:TEXT") <> "U"
			If oNfe:_CTE:_INFCTE:_IDE:_TOMA4:_TOMA:TEXT == "4"
				// Subcontratacao DT6_DEVFRE == "4" - Despachante		
				cDevMun   := oNfe:_CTE:_INFCTE:_IDE:_TOMA4:_ENDERTOMA:_XMUN:TEXT
				cDevUF    := oNfe:_CTE:_INFCTE:_IDE:_TOMA4:_ENDERTOMA:_UF:TEXT
				cDevNome  := oNfe:_CTE:_INFCTE:_IDE:_TOMA4:_XNOME:TEXT
				cDevEnd   := oNfe:_CTE:_INFCTE:_IDE:_TOMA4:_ENDERTOMA:_XLGR:TEXT
				cDevNro   := oNfe:_CTE:_INFCTE:_IDE:_TOMA4:_ENDERTOMA:_NRO:TEXT
				cDevCompl := ""
				cDevBair  := oNfe:_CTE:_INFCTE:_IDE:_TOMA4:_ENDERTOMA:_XBAIRRO:TEXT
				cDevCEP   := oNfe:_CTE:_INFCTE:_IDE:_TOMA4:_ENDERTOMA:_CEP:TEXT
				cDevCNPJ  := Iif(Type("oNfe:_CTE:_INFCTE:_IDE:_TOMA4:_CNPJ:TEXT")=="U",oNfe:_CTE:_INFCTE:_IDE:_TOMA4:_CPF:TEXT,oNfe:_CTE:_INFCTE:_IDE:_TOMA4:_CNPJ:TEXT)
				cDevIE    := Iif(Type("oNfe:_CTE:_INFCTE:_IDE:_TOMA4:_IE:TEXT"  )=="U"," ",oNfe:_CTE:_INFCTE:_IDE:_TOMA4:_IE:TEXT)
				cDevPais  := ""
				cDevFone  := Iif(Type("oNfe:_CTE:_INFCTE:_IDE:_TOMA4:_FONE:TEXT")=="U"," ",oNfe:_CTE:_INFCTE:_IDE:_TOMA4:_FONE:TEXT)
			EndIf
		EndIf
		//-- Documentos Originarios
		aDocOri := {}
		If	( Type( "oNFE:_CTE:_INFCTE:_REM:_INFNFE" ) <> 'U' )
			If ValType( oNFE:_CTE:_INFCTE:_REM:_INFNFE ) == 'A'
				For nCount := 1 To Len( oNFE:_CTE:_INFCTE:_REM:_INFNFE )
					If aScan(aDocOri,{|x|x[8]==oNFE:_CTE:_INFCTE:_REM:_INFNFE[ nCount ]:_CHAVE:TEXT})==0
						AADD(aDocOri, {;
						'',;
						'',;
						'',;
						'',;
						'',;
						'',;
						'',;
						oNFE:_CTE:_INFCTE:_REM:_INFNFE[ nCount ]:_CHAVE:TEXT })
					EndIf
				Next nCount
			ElseIf ValType( oNFE:_CTE:_INFCTE:_REM:_INFNFE ) == 'O'
				If aScan(aDocOri,{|x|x[8]==oNFE:_CTE:_INFCTE:_REM:_INFNFE:_CHAVE:TEXT})==0
					AADD(aDocOri, {;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					oNFE:_CTE:_INFCTE:_REM:_INFNFE:_CHAVE:TEXT }) 
				EndIf
			EndIf
		ElseIf	( Type( "oNFE:_CTE:_INFCTE:_REM:_INFNF" ) <> 'U' ) 
			If ValType( oNFE:_CTE:_INFCTE:_REM:_INFNF ) == 'A'
				For nCount := 1 To Len( oNFE:_CTE:_INFCTE:_REM:_INFNF )
					If aScan(aDocOri,{|x|x[1]+x[2]==oNFE:_CTE:_INFCTE:_REM:_INFNF[ nCount ]:_SERIE:TEXT+oNFE:_CTE:_INFCTE:_REM:_INFNF[ nCount ]:_NDOC:TEXT})==0
						AADD(aDocOri, {;
						oNFE:_CTE:_INFCTE:_REM:_INFNF[ nCount ]:_SERIE:TEXT,;
						oNFE:_CTE:_INFCTE:_REM:_INFNF[ nCount ]:_NDOC:TEXT,;
						STRTRAN(oNFE:_CTE:_INFCTE:_REM:_INFNF[ nCount ]:_DEMI:TEXT,'-'),;
						oNFE:_CTE:_INFCTE:_REM:_INFNF[ nCount ]:_VPROD:TEXT,;
						'',;
						'',;
						'',;
						'' })
					EndIf
				Next nCount
				//-- Local de Retirada
				If (Type("oNfe:_CTE:_INFCTE:_REM:_INFNF[1]:_LOCRET")) <> "U"
					cExpMun	:= oNfe:_CTE:_INFCTE:_REM:_INFNF[1]:_LOCRET:_XMUN:TEXT
					cExpUF		:= oNfe:_CTE:_INFCTE:_REM:_INFNF[1]:_LOCRET:_UF:TEXT
					cExpNome	:= oNfe:_CTE:_INFCTE:_REM:_INFNF[1]:_LOCRET:_XNOME:TEXT
					cExpEnd	:= oNfe:_CTE:_INFCTE:_REM:_INFNF[1]:_LOCRET:_XLGR:TEXT
					cExpNro	:= oNfe:_CTE:_INFCTE:_REM:_INFNF[1]:_LOCRET:_NRO:TEXT
					cExpCompl 	:= ""
					cExpBai	:= oNfe:_CTE:_INFCTE:_REM:_INFNF[1]:_LOCRET:_XBAIRRO:TEXT
					cExpCEP   	:= ""
					cExpCNPJ  	:= Iif(Type("oNfe:_CTE:_INFCTE:_REM:_INFNF[1]:_LOCRET:_CNPJ:TEXT")=="U", oNfe:_CTE:_INFCTE:_REM:_INFNF[1]:_LOCRET:_CPF:TEXT , oNfe:_CTE:_INFCTE:_REM:_INFNF[1]:_LOCRET:_CNPJ:TEXT)
					cExpIE    	:= ""
					cExpPais  	:= cRemPais
					cExpFone  	:= ""
				EndIf
			Else
				If aScan(aDocOri,{|x|x[1]+x[2]==oNFE:_CTE:_INFCTE:_REM:_INFNF:_SERIE:TEXT+oNFE:_CTE:_INFCTE:_REM:_INFNF:_NDOC:TEXT})==0
					AADD(aDocOri, {;
					oNFE:_CTE:_INFCTE:_REM:_INFNF:_SERIE:TEXT,;
					oNFE:_CTE:_INFCTE:_REM:_INFNF:_NDOC:TEXT,;
					STRTRAN(oNFE:_CTE:_INFCTE:_REM:_INFNF:_DEMI:TEXT,'-'),;
					oNFE:_CTE:_INFCTE:_REM:_INFNF:_VPROD:TEXT,;
					'',;
					'',;
					'',;
					'' })
				EndIf
				If (Type("oNfe:_CTE:_INFCTE:_REM:_INFNF:_LOCRET")) <> "U"
					cExpMun	:= oNfe:_CTE:_INFCTE:_REM:_INFNF:_LOCRET:_XMUN:TEXT
					cExpUF		:= oNfe:_CTE:_INFCTE:_REM:_INFNF:_LOCRET:_UF:TEXT
					cExpNome	:= oNfe:_CTE:_INFCTE:_REM:_INFNF:_LOCRET:_XNOME:TEXT
					cExpEnd	:= oNfe:_CTE:_INFCTE:_REM:_INFNF:_LOCRET:_XLGR:TEXT
					cExpNro	:= oNfe:_CTE:_INFCTE:_REM:_INFNF:_LOCRET:_NRO:TEXT
					cExpCompl 	:= ""
					cExpBai	:= oNfe:_CTE:_INFCTE:_REM:_INFNF:_LOCRET:_XBAIRRO:TEXT
					cExpCEP   	:= ""
					cExpCNPJ  	:= Iif(Type("oNfe:_CTE:_INFCTE:_REM:_INFNF:_LOCRET:_CNPJ:TEXT")=="U", oNfe:_CTE:_INFCTE:_REM:_INFNF:_LOCRET:_CPF:TEXT , oNfe:_CTE:_INFCTE:_REM:_INFNF:_LOCRET:_CNPJ:TEXT)
					cExpIE    	:= ""
					cExpPais  	:= cRemPais
					cExpFone  	:= ""
			EndIf
			EndIf
        //Aqui Inicio
		ElseIf  (Type( "oNFE:_CTE:_INFCTE:_INFCTENORM:_INFDOC:_INFNF")) <> 'U'  
				If ValType( oNFE:_CTE:_INFCTE:_INFCTENORM:_INFDOC:_INFNF ) == 'A'
					For nCount := 1 To Len( oNFE:_CTE:_INFCTE:_INFCTENORM:_INFDOC:_INFNF )
						If aScan(aDocOri,{|x|x[1]+x[2]==oNFE:_CTE:_INFCTE:_INFCTENORM:_INFDOC:_INFNF[ nCount ]:_SERIE:TEXT+oNFE:_CTE:_INFCTE:_INFCTENORM:_INFDOC:_INFNF[ nCount ]:_NDOC:TEXT})==0
							AADD(aDocOri, {;
							oNFE:_CTE:_INFCTE:_INFCTENORM:_INFDOC:_INFNF[ nCount ]:_SERIE:TEXT,;
							oNFE:_CTE:_INFCTE:_INFCTENORM:_INFDOC:_INFNF[ nCount ]:_NDOC:TEXT,;
							STRTRAN(oNFE:_CTE:_INFCTE:_INFCTENORM:_INFDOC:_INFNF[ nCount ]:_DEMI:TEXT,'-'),;
							oNFE:_CTE:_INFCTE:_INFCTENORM:_INFDOC:_INFNF[ nCount ]:_VPROD:TEXT,;
							'',;
							'',;
							'',;
							'' })
						EndIf
					Next nCount
				Else
					If aScan(aDocOri,{|x|x[1]+x[2]==oNFE:_CTE:_INFCTE:_INFCTENORM:_INFDOC:_INFNF:_SERIE:TEXT+oNFE:_CTE:_INFCTE:_INFCTENORM:_INFDOC:_INFNF:_NDOC:TEXT})==0
						AADD(aDocOri, {;
						oNFE:_CTE:_INFCTE:_INFCTENORM:_INFDOC:_INFNF:_SERIE:TEXT,;
						oNFE:_CTE:_INFCTE:_INFCTENORM:_INFDOC:_INFNF:_NDOC:TEXT,;
						STRTRAN(oNFE:_CTE:_INFCTE:_INFCTENORM:_INFDOC:_INFNF:_DEMI:TEXT,'-'),;
						oNFE:_CTE:_INFCTE:_INFCTENORM:_INFDOC:_INFNF:_VPROD:TEXT,;
						'',;
						'',;
						'',;
						'' })
					EndIf
				EndIf
	        
	        // Fim
		ElseIf	( Type( "oNFE:_CTE:_INFCTE:_INFCTENORM:_INFDOC:_INFNFE" ) <> 'U' )
			If ValType( oNFE:_CTE:_INFCTE:_INFCTENORM:_INFDOC:_INFNFE ) == 'A'
				For nCount := 1 To Len( oNFE:_CTE:_INFCTE:_INFCTENORM:_INFDOC:_INFNFE )
					If aScan(aDocOri,{|x|x[8]==oNFE:_CTE:_INFCTE:_INFCTENORM:_INFDOC:_INFNFE[ nCount ]:_CHAVE:TEXT})==0
						AADD(aDocOri, {;
						'',;
						'',;
						'',;
						'',;
						'',;
						'',;
						'',;
						oNFE:_CTE:_INFCTE:_INFCTENORM:_INFDOC:_INFNFE[ nCount ]:_CHAVE:TEXT })
					EndIf
				Next nCount
			ElseIf ValType( oNFE:_CTE:_INFCTE:_INFCTENORM:_INFDOC:_INFNFE ) == 'O'
				If aScan(aDocOri,{|x|x[8]==oNFE:_CTE:_INFCTE:_INFCTENORM:_INFDOC:_INFNFE:_CHAVE:TEXT})==0
					AADD(aDocOri, {;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					oNFE:_CTE:_INFCTE:_INFCTENORM:_INFDOC:_INFNFE:_CHAVE:TEXT }) 
				EndIf
			EndIf
		ElseIf	( Type( "oNFE:_CTE:_INFCTE:_REM:_INFOUTROS" ) <> 'U' ) 
			If ValType( oNFE:_CTE:_INFCTE:_REM:_INFOUTROS ) == 'A'
				For nCount := 1 To Len( oNFE:_CTE:_INFCTE:_REM:_INFOUTROS )
					If aScan(aDocOri,{|x|x[1]+x[2]==oNFE:_CTE:_INFCTE:_REM:_INFOUTROS[ nCount ]:_NDOC:TEXT})==0
						AADD(aDocOri, {;
						'',; //SERIE DO DOCUMENTO NAO INFORMADA NO XML QUANDO O DOCUMENTO NAO EH FISCAL
						oNFE:_CTE:_INFCTE:_REM:_INFOUTROS[ nCount ]:_NDOC:TEXT,;
						STRTRAN(oNFE:_CTE:_INFCTE:_REM:_INFOUTROS[ nCount ]:_DEMI:TEXT,'-'),;
						'',; //--VALOR DO PRODUTO NAO INFORMADO NO XML QUANDO O DOCUMENTO NAO EH FISCAL
						'',;
						'',;
						'',;
						'' })
					EndIf
				Next nCount
			Else
				If aScan(aDocOri,{|x|x[1]+x[2]==oNFE:_CTE:_INFCTE:_REM:_INFOUTROS:_SERIE:TEXT+oNFE:_CTE:_INFCTE:_REM:_INFOUTROS:_NDOC:TEXT})==0
					AADD(aDocOri, {;
					'',;//SERIE DO DOCUMENTO NAO INFORMADA NO XML QUANDO O DOCUMENTO NAO EH FISCAL
					oNFE:_CTE:_INFCTE:_REM:_INFOUTROS:_NDOC:TEXT,;
					STRTRAN(oNFE:_CTE:_INFCTE:_REM:_INFOUTROS:_DEMI:TEXT,'-'),;
					'',; //--VALOR DO PRODUTO NAO INFORMADO NO XML QUANDO O DOCUMENTO NAO EH FISCAL
					'',;
					'',;
					'',;
					'' })
				EndIf
			EndIf
		ElseIf	( Type( "oNFE:_CTE:_INFCTE:_INFCTENORM:_INFDOC:_INFOUTROS" ) <> 'U' ) 
			If ValType( oNFE:_CTE:_INFCTE:_INFCTENORM:_INFDOC:_INFOUTROS ) == 'A'
				For nCount := 1 To Len( oNFE:_CTE:_INFCTE:_INFCTENORM:_INFDOC:_INFOUTROS )
					If aScan(aDocOri,{|x|x[1]+x[2]==oNFE:_CTE:_INFCTE:_INFCTENORM:_INFDOC:_INFOUTROS[ nCount ]:_NDOC:TEXT})==0
						AADD(aDocOri, {;
						'',; //SERIE DO DOCUMENTO NAO INFORMADA NO XML QUANDO O DOCUMENTO NAO EH FISCAL
						oNFE:_CTE:_INFCTE:_INFCTENORM:_INFDOC:_INFOUTROS[ nCount ]:_NDOC:TEXT,;
						STRTRAN(oNFE:_CTE:_INFCTE:_INFCTENORM:_INFDOC:_INFOUTROS[ nCount ]:_DEMI:TEXT,'-'),;
						'',; //--VALOR DO PRODUTO NAO INFORMADO NO XML QUANDO O DOCUMENTO NAO EH FISCAL
						'',;
						'',;
						'',;
						'' })
					EndIf
				Next nCount
			Else
				If aScan(aDocOri,{|x|x[1]+x[2]==oNFE:_CTE:_INFCTE:_INFCTENORM:_INFDOC:_INFOUTROS:_SERIE:TEXT+oNFE:_CTE:_INFCTE:_INFCTENORM:_INFDOC:_INFOUTROS:_NDOC:TEXT})==0
					AADD(aDocOri, {;
					'',;//SERIE DO DOCUMENTO NAO INFORMADA NO XML QUANDO O DOCUMENTO NAO EH FISCAL
					oNFE:_CTE:_INFCTE:_INFCTENORM:_INFDOC:_INFOUTROS:_NDOC:TEXT,;
					STRTRAN(oNFE:_CTE:_INFCTE:_INFCTENORM:_INFDOC:_INFOUTROS:_DEMI:TEXT,'-'),;
					'',; //--VALOR DO PRODUTO NAO INFORMADO NO XML QUANDO O DOCUMENTO NAO EH FISCAL
					'',;
					'',;
					'',;
					'' })
				EndIf
			EndIf
		//CTE Multimodal anterior
		ElseIf	( Type( "oNfe:_CTE:_INFCTE:_IDE:_REFCTE" ) <> 'U' ) 
			If aScan(aDocOri,{|x|x[8]==oNfe:_CTE:_INFCTE:_IDE:_REFCTE:TEXT})==0
				AADD(aDocOri, {;
				'',;
				'',;
				'',;
				'',;
				'',;
				'',;
				'',;
				oNfe:_CTE:_INFCTE:_IDE:_REFCTE:TEXT })
			EndIf
		EndIf
		//-- RNTRC
		/*
		If (Type("oNFE:_CTE:_INFCTE:_INFCTENORM")) <> "U"
			If (Type("oNFE:_CTE:_INFCTE:_INFCTENORM:_INFMODAL:_RODO")) <> "U"
				cRNLotacao	:= If( oNfe:_CTE:_INFCTE:_INFCTENORM:_INFMODAL:_RODO:_LOTA:TEXT == '0', "Carga Fracionada", "Lota��o")
				cRNDtPrv	:= oNfe:_CTE:_INFCTE:_INFCTENORM:_INFMODAL:_RODO:_DPREV:TEXT
				cRNDtPrv	:= SubStr(cRNDtPrv,9,2) + '/' + SubStr(cRNDtPrv,6,2) + '/' + SubStr(cRNDtPrv,1,4)
				cRNMensagem	:= "Esse Conhecimento de Transporte atende � Legisla��o de Transporte Rodovi�rio em Vigor"
			Else
				cRNLotacao	:= If( oNfe:_CTE:_INFCTE:_INFCTENORM:_INFMODAL:_RODO:_LOTA:TEXT == '0', "Carga Fracionada", "Lota��o")
				cRNDtPrv	:= oNfe:_CTE:_INFCTE:_INFCTENORM:_INFMODAL:_RODO:_DPREV:TEXT
				cRNDtPrv	:= SubStr(cRNDtPrv,9,2) + '/' + SubStr(cRNDtPrv,6,2) + '/' + SubStr(cRNDtPrv,1,4)
				cRNMensagem	:= "Esse Conhecimento de Transporte atende � Legisla��o de Transporte Rodovi�rio em Vigor"
			EndIf
		EndIf
		*/
	//������������������������������������������������������������������������Ŀ
	//� BOX: CFOP - Natureza da Prestacao                                      �
	//��������������������������������������������������������������������������
	oDacte:Box(0224, 0000, 0241, 0559)
	oDacte:Say(0230, 0003, "CFOP - Natureza da Presta��o",	oFont08N)
	oDacte:Say(0238, 0003, cCFOP + " - " + cDescCfop,		oFont08)

	//������������������������������������������������������������������������Ŀ
	//� BOX: ORIGEM DA PRESTACAO                                               �
	//��������������������������������������������������������������������������
	oDacte:Box(0243, 0000, 0260, 0279)
	oDacte:Say(0249, 0003, "Origem da Presta��o" , oFont08N)
	oDacte:Say(0257, 0003, AllTrim(cOriMunPre) + ' - ' + AllTrim(cOriUFPre), oFont08)	

	//������������������������������������������������������������������������Ŀ
	//� BOX: DESTINO DA PRESTACAO                                              �
	//��������������������������������������������������������������������������
	oDacte:Box(0243, 0281, 0260, 0559)
	oDacte:Say(0249, 0288, "Destino da Presta��o", oFont08N)
	oDacte:Say(0257, 0288, AllTrim(cDesMunPre) + ' - ' + AllTrim(cDesUFPre), oFont08)

	//������������������������������������������������������������������������Ŀ
	//� BOX: Remetente                                                         �
	//� BOX: Destinatario                                                      �
	//��������������������������������������������������������������������������
	oDacte:Box(0262, 0000, 0313, 0279)	//Remetente
	oDacte:Box(0262, 0281, 0313, 0559)	//Destinatario

	oDacte:Say(0268, 0003, "Remetente:", oFont08)
	oDacte:Say(0268, 0043, NoAcentoCte(Substr(cRemNome,1,45)), oFont08N)
	oDacte:Say(0268, 0286, "Destinatario:", oFont08)
	oDacte:Say(0268, 0328, NoAcentoCte(Substr(cDesNome,1,45)), oFont08N)

	cInsRemOpc := AllTrim(cRemIE)
	For nCount := 1 To 5
		Do Case
			Case ( nCount == 1 )
				oDacte:Say(0277, 0003, "Endere�o:", oFont08)
				oDacte:Say(0277, 0043, AllTrim(cRemEnd) + ", " + cRemNro, oFont08)
				oDacte:Say(0277, 0286, "Endere�o:", oFont08)
				oDacte:Say(0277, 0328, AllTrim(cDesEnd) + ", " + cDesNro, oFont08)
			Case ( nCount == 2 )
				oDacte:Say(0284, 0043, AllTrim(cRemCompl) + " - " + AllTrim(cRemBair), oFont08)
				oDacte:Say(0284, 0328, AllTrim(cDesCompl) + " - " + AllTrim(cDesBair), oFont08)
			Case ( nCount == 3 )
				oDacte:Say(0291, 0003, "Municipio:", oFont08)
				oDacte:Say(0291, 0043, AllTrim(cRemMun) + ' - ' + AllTrim(cRemUF)  + ' CEP.: ' + Transform(AllTrim(cRemCEP), "@r 99999-999"), oFont08)
				oDacte:Say(0291, 0286, "Municipio:", oFont08)
				oDacte:Say(0291, 0328, AllTrim(cDesMun) + ' - ' + AllTrim(cDesUF) + ' CEP.: ' + Transform(AllTrim(cDesCEP), "@r 99999-999"), oFont08)
			Case ( nCount == 4 )
				oDacte:Say(0298, 0003, "CNPJ/CPF:", oFont08)
				oDacte:Say(0298, 0043, Transform(AllTrim(cRemCNPJ), "@r 99.999.999/9999-99") + "   Inscri��o Estadual: " +  AllTrim(cInsRemOpc), oFont08)
				oDacte:Say(0298, 0286, "CNPJ/CPF:", oFont08)
				oDacte:Say(0298, 0328, Transform(AllTrim(cDesCNPJ), "@r 99.999.999/9999-99") + "   Inscri��o Estadual: " +  AllTrim(cDesIE),    oFont08)
			Case ( nCount == 5 )
				oDacte:Say(0305, 0003, "Pais:", oFont08)
				oDacte:Say(0305, 0043, AllTrim(cRemPais) + ' Telefone.: ' + Transform(AllTrim(cRemFone),"@r (999) 999999999"),  oFont08)
				oDacte:Say(0305, 0286, "Pais:", oFont08)
				oDacte:Say(0305, 0328, AllTrim(cDesPais) + ' Telefone.: ' + Transform(AllTrim(cDesFone),"@r (999) 999999999"), oFont08)
		EndCase
	Next nCount

	//������������������������������������������������������������������������Ŀ
	//� BOX: Expedidor / BOX: Recebedor                                        �
	//��������������������������������������������������������������������������
	oDacte:Box(0315, 0000, 0366, 0279)	//Expedidor
	oDacte:Box(0315, 0281, 0366, 0559)	//Recebedor

	If lExped .Or. Empty(cExpNome) 		
		oDacte:Say(0322, 0003, "Expedidor:", oFont08)
	Else
		oDacte:Say(0322, 0003, "Local Coleta:", oFont08)
	EndIf
	oDacte:Say(0322, 0043, NoAcentoCte(Substr(cExpNome,1,45))    , oFont08N)

	//-- Sequencia de endereco preenchida, fica como local de entrega.
	
	If lSeqDes
		oDacte:Say(0322, 0286, "Local de Entrega:", oFont08)
		oDacte:Say(0322, 0342,  NoAcentoCte(Substr(cRecNome,1,45)), oFont08N)
	EndIf
	
	If lSeqRec
		oDacte:Say(0322, 0286, "Recebedor:", oFont08)
		oDacte:Say(0322, 0328,  NoAcentoCte(Substr(cRecNome,1,45)), oFont08N)
	EndIf

	If !lSeqDes .And. !lSeqRec
		oDacte:Say(0322, 0286, "Recebedor:", oFont08)
	EndIf

	For nCount := 1 To 5
		Do Case
			Case ( nCount == 1 )
				oDacte:Say(0331, 0003, "Endere�o:", oFont08)
				oDacte:Say(0331, 0043, IIf(!Empty(cExpEnd), AllTrim(cExpEnd) + ", " + cExpNro, " "), oFont08) 
				oDacte:Say(0331, 0286, "Endere�o:", oFont08)
				//-- Sequencia de endereco preenchida, fica como local de entrega.
				oDacte:Say(0331, 0328, If(lSeqDes .or. lSeqRec, AllTrim(FisGetEnd(cRecEnd)[1]) + ", " + Iif(FisGetEnd(cRecEnd)[2]<>0, AllTrim(cValtoChar(FisGetEnd(cRecEnd)[2])),"S/N"),""), oFont08)
			Case ( nCount == 2 )
				oDacte:Say(0338, 0043, IIf(!Empty(cExpCompl), AllTrim(cExpCompl) + " - " + AllTrim(cExpBai), " "), oFont08)
				oDacte:Say(0338, 0328, If(lSeqDes .or. lSeqRec, AllTrim(cValtoChar(FisGetEnd(cRecEnd)[4])) + " - " + AllTrim(cRecBai),""), oFont08)
			Case ( nCount == 3 )
				oDacte:Say(0345, 0003, "Municipio:", oFont08)
				oDacte:Say(0345, 0043, IIf(!Empty(cExpMun),  AllTrim(cExpMun) + ' - ' + AllTrim(cExpUF), " ")  + ' CEP.: ' + IIf(!Empty(cExpCEP), Transform(AllTrim(cExpCEP), "@r 99999-999"), ""), oFont08)
				oDacte:Say(0345, 0286, "Municipio:", oFont08)
				oDacte:Say(0345, 0328, If(lSeqDes .or. lSeqRec, AllTrim(cRecMun) + ' - ' + AllTrim(cRecUF),""), oFont08)
			Case ( nCount == 4 )
				oDacte:Say(0352, 0003, "CNPJ/CPF:", oFont08)
				oDacte:Say(0352, 0043, IIf(!Empty(cExpCNPJ), Transform(AllTrim(cExpCNPJ), "@r 99.999.999/9999-99"), " ") + "   Inscri��o Estadual: " +  AllTrim(cExpIE), oFont08)
				oDacte:Say(0352, 0286, "CNPJ/CPF:", oFont08)
				If lSeqDes .or. lSeqRec
					If lRecPJ
						oDacte:Say(0352, 0328, IIf(!Empty(cRecCGC), Transform(cRecCGC,"@r 99.999.999/9999-99"), " ") + "   Inscri��o Estadual: " +  cRecINSCR, oFont08)
					Else
						oDacte:Say(0352, 0328, Transform(cRecCPF,"@r 999.999.999-99"), oFont08)
					EndIf
				Else
					oDacte:Say(0352, 0328, "", oFont08)
				EndIf

			Case ( nCount == 5 )
				If lExped .Or. Empty(cExpNome)
					oDacte:Say(0359, 0003, "Pais:" , oFont08)
					oDacte:Say(0359, 0043, AllTrim(cExpPais) + ' Telefone.: ' + IIf(!Empty(cExpFone), Transform(AllTrim(cExpFone),"@r (999) 999999999"), " "),  oFont08)
				EndIf
				If !lSeqDes
					oDacte:Say(0359, 0286, "Pais:" , oFont08)
					oDacte:Say(0359, 0328, If(lSeqRec ,AllTrim(cRecPais),""), oFont08)
				EndIf
		EndCase
	Next nCount

	//������������������������������������������������������������������������Ŀ
	//� BOX: Tomador do Servico                                                �
	//��������������������������������������������������������������������������
	oDacte:Box(0368, 0000, 0395, 0559)
	oDacte:Say(0375, 0003, "Tomador do Servi�o:", oFont08)
	oDacte:Say(0375, 0072, NoAcentoCte(SubStr(cDevNome,1,45)), oFont08)
	oDacte:Say(0375, 0328, "Municipio:", oFont08)
	oDacte:Say(0375, 0368, AllTrim(cDevMun) + ' - ' + AllTrim(cDevUF) + ' CEP.: ' + Transform(AllTrim(cDevCEP),"@r 99999-999"), oFont08)

	For nCount := 1 To 2
		Do Case
			Case ( nCount == 1 )
				oDacte:Say(0383, 0003, "Endere�o:", oFont08)
				oDacte:Say(0383, 0043, SubStr(AllTrim(cDevEnd),1,40) + ", " + cDevNro + " - "	+;
				                              AllTrim(cDevCompl) + " - " + AllTrim(cDevBair), oFont08)
				oDacte:Say(0383, 0328, "Pais: ", oFont08)
				oDacte:Say(0383, 0368, AllTrim(cDevPais), oFont08)
			Case ( nCount == 2 )
				oDacte:Say(0391, 0003, "CNPJ/CPF:", oFont08)
				oDacte:Say(0391, 0043, Transform(AllTrim(cDevCNPJ),"@r 99.999.999/9999-99") + "   Inscri��o Estadual: " + AllTrim(cDevIE), oFont08)
				oDacte:Say(0391, 0328, "Telefone:", oFont08)
				oDacte:Say(0391, 0368, Transform(AllTrim(cDevFone),"@r (999) 999999999"), oFont08)
		EndCase
	Next nCount

	If	AllTrim((cAliasCT)->DT6_DOCTMS) == StrZero( 2, Len(DT6->DT6_DOCTMS)) .Or.;
		AllTrim((cAliasCT)->DT6_DOCTMS) == StrZero( 6, Len(DT6->DT6_DOCTMS)) .Or.;
		AllTrim((cAliasCT)->DT6_DOCTMS) == StrZero( 7, Len(DT6->DT6_DOCTMS)) .Or.;
		AllTrim((cAliasCT)->DT6_DOCTMS) == StrZero( 9, Len(DT6->DT6_DOCTMS)) .Or.;
		AllTrim((cAliasCT)->DT6_DOCTMS) == 'A' .Or. AllTrim((cAliasCT)->DT6_DOCTMS) == 'E' .Or. ;
		AllTrim((cAliasCT)->DT6_DOCTMS) == 'M' .Or. ;
		(AllTrim((cAliasCT)->DT6_DOCTMS) == 'B' .Or. AllTrim((cAliasCT)->DT6_DOCTMS) == 'C' .And. ;
		 Empty(Posicione('DUI',1,xFilial('DUI')+(cAliasCT)->DT6_DOCTMS,'DUI_DOCFAT')) )

		//������������������������������������������������������������������������Ŀ
		//� BOX: Prod Predom || Outras Caract || Valor Total da Mercadoria         �
		//��������������������������������������������������������������������������
		oDacte:Box(0397 , 0000, 0414, 0559)
		oDacte:Line(0397, 0189, 0414, 0189) // Linha: Prod.Predominante e Out.Caracteristicas
		oDacte:Line(0397, 0378, 0414, 0378) // Linha: Out.Caracteristicas e Vlr.Total
		oDacte:Say(0403, 0003, "Produto Predominante"           , oFont08N)
		oDacte:Say(0403, 0192, "Outras Caracteristicas da Carga", oFont08N)
		oDacte:Say(0403, 0381, "Valor Total da Mercadoria"      , oFont08N)
		oDacte:Say(0411, 0003, SubStr(cPPDesc,1,40), oFont08)	//Produto Predominante
		oDacte:Say(0411, 0192, AllTrim(cPPCarga)	, oFont08)	//Outras Caracteristicas da Carga
		oDacte:Say(0411, 0381, PadL( Transform( val(cPPVlTot), PesqPict("DT6","DT6_VALMER") ), 20 ), oFont08)	//Valor Total da Mercadoria

		//������������������������������������������������������������������������Ŀ
		//� BOX: QNT. / UNIDADE MEDIDA /                                           �
		//��������������������������������������������������������������������������
		oDacte:Box(0416, 0000, 0443,  0315)		
		oDacte:Say(0423 , 0003, "Peso Bruto (KG)"	, oFont08N)
		oDacte:Say(0423 , 0067, "Peso Cubado    "	, oFont08N)
		oDacte:Say(0423 , 0131, "M�             "	, oFont08N)
		oDacte:Say(0423 , 0195, "Qtd.Volume (Un)"	, oFont08N)
		oDacte:Say(0423 , nCInic, "                ", oFont08N)
		oDacte:Line(0416, 0064, 0443, 0064) // Linha: Separador Peso Bruto (KG) / Peso Cubado		
		oDacte:Line(0416, 0128, 0443, 0128) // Linha: Separador Peso Cubado / M�				
		oDacte:Line(0416, 0192, 0443, 0192) // Linha: Separador M� / Qtd. Volume (Un)			
		oDacte:Line(0416, 0256, 0443, 0256) // Linha: SeparadorQtd. Volume (Un) / 				

		oDacte:Say(0431, 0003, Transform(val(cPPPesoB) ,	PesqPict("DT6","DT6_PESO")   ),	oFont08) 					
		oDacte:Say(0431, 0067, Transform(val(cPPPeso3) ,	PesqPict("DT6","DT6_PESOM3") ),	oFont08)  			
		oDacte:Say(0431, 0131, Transform(val(cPPMetro3),	PesqPict("DT6","DT6_METRO3") ),	oFont08)   				
		oDacte:Say(0431, 0195, Transform(val(cPPQtdVol),	PesqPict("DTC","DTC_QTDVOL") ),	oFont08)    
		
		//-- Zera as variaveis(Peso, Peso Cubado, Metro Cubico e Qtd Volume) depois de impresso no DACTE.
		cPPPesoB  := ""
		cPPPeso3  := ""
		cPPMetro3 := ""
		cPPQtdVol := ""

		//������������������������������������������������������������������������Ŀ
		//� BOX: SEGURADORA                                                        �
		//��������������������������������������������������������������������������
		oDacte:Box(0416 , 0317, 0443,  0559)
		oDacte:Say(0423 , 0324, "Nome da Seguradora:"	, oFont08N)
		oDacte:Say(0423 , 0400, cSegNome				, oFont08N)
		oDacte:Line(0426, 0317, 0426, 0559)							// Linha: Separador Nome da Seguradora / Responsavel
		oDacte:Say(0433 , 0324, "Responsavel"			, oFont08N)
		oDacte:Say(0440 , 0324, cSegDesc				, oFont08N)
		oDacte:Line(0426, 0380, 0443, 0380)							// Linha: Separador Responsavel / N�mero da Apolice
		oDacte:Say(0433 , 0380, "N�mero da Apolice"	, oFont08N)
		oDacte:Say(0440 , 0380, cSegNrApoli			, oFont08N)
		oDacte:Line(0426, 0479, 0443, 0479)							// Linha: Separador N�mero da Apolice / N�mero da Averba��o
		oDacte:Say(0433 , 0482, "N�mero da Averba��o"	, oFont08N)
		oDacte:Say(0440 , 0477, cSegNrAverb			, oFont08N)

		//������������������������������������������������������������������������Ŀ
		//� Conteudo do Box: Componentes do Valor da Prestacao de Servico          �
		//� Conteudo do Box: Informacoes Relativas ao Imposto                      �
		//��������������������������������������������������������������������������
		TMSR27Comp()

		cAliasPeri := DataSource("PRODUTOS_PERIGOSOS")
		If (cAliasPeri)->(!Eof())
			lPerig := .T.
		Else
			lPerig := .F.
		EndIf
		(cAliasPeri)->(DbCloseArea())

		//������������������������������������������������������������������������Ŀ
		//� BOX: DOCUMENTOS ORIGINARIOS                                            �
		//��������������������������������������������������������������������������
		oDacte:Box(0533 , 0000, 0590, 0559)
		If Empty(cCtrDpc)
			oDacte:Say(00539 , 0243, "Documentos Origin�rios",oFont08N)
		Else
			oDacte:Say(00528 , 0243, "Documentos Origin�rios",oFont08N)
			oDacte:Say(00539 , 0443, "Documentos Anteriores ",oFont08N)
		EndIf

		oDacte:Line(0541, 0000, 0541, 0559)	// Linha: Abaixo    DOCUMENTOS ORIGINARIOS
		oDacte:Line(0541, 0283, 0590, 0283)	// Linha: Separador DOCUMENTOS ORIGINARIOS
		
		oDacte:Say(0548 , 0003, "Tp.Doc"            , oFont08N)
		oDacte:Say(0548 , 0033, "CNPJ/CPF Emitente" , oFont08N)
		oDacte:Say(0548 , 0163, "S�rie/Nr.Documento", oFont08N)
		oDacte:Say(0548 , 0286, "Tp.Doc"            , oFont08N)
		oDacte:Say(0548 , 0316, "CNPJ/CPF Emitente" , oFont08N)
		oDacte:Say(0548 , 0448, "S�rie/Nr.Documento", oFont08N)
				
		//������������������������������������������������������������������������Ŀ
		//� Documentos Originarios                                                 �
		//��������������������������������������������������������������������������
		lControl := .F.
		nLInic   := 0556

		nCount := 0
		aDoc   := {}
        cDipDoc := ""
        cDipSer := ""

		For nCount := 1 to Len( aDocOri )
			            
			If !Empty(AllTrim(aDocOri[nCount][doDTC_NFEID]))
				cDipDoc := SubStr(aDocOri[nCount,doDTC_NFEID],23,3) 
				cDipSer := SubStr(aDocOri[nCount,doDTC_NFEID],26,9)
			Else
				cDipDoc := aDocOri[nCount,doDTC_NUMNFC]
				cDipSer := aDocOri[nCount,doDTC_SERNFC]
			EndIf
				
			lControl := !lControl
			If nCount < 11
				If Empty(cCtrDpc)
					If lControl
						//If Empty(AllTrim(aDocOri[nCount][doDTC_NFEID])) .And. !Empty(AllTrim(aDocOri[nCount][doDTC_SERNFC]))
							//-- Imprime a Chave da NF-e, lado esquerdo
							oDacte:Say(nLInic, 0003, "NF", oFont08)
							oDacte:Say(nLInic, 0033, Transform(AllTrim(cRemCNPJ),"@r 99.999.999/9999-99"), oFont08)
							oDacte:Say(nLInic, 0163, cDipSer + " / " + cDipDoc, oFont08)
/*						ElseIf Empty(AllTrim(aDocOri[nCount][doDTC_NFEID]))
							//-- Imprime os dados do documento n�o fiscal do lado esquerdo.
							oDacte:Say(nLInic, 0003, "Outros", oFont08)
							oDacte:Say(nLInic, 0033, Transform(AllTrim(cRemCNPJ),"@r 99.999.999/9999-99"), oFont08)
							oDacte:Say(nLInic, 0163, AllTrim(aDocOri[nCount][doDTC_NUMNFC]), oFont08)						
						Else
							//-- Imprime a Chave da NF-e, lado esquerdo
							cChaveA := AllTrim(aDocOri[nCount][doDTC_NFEID])
							If lMultModal
								oDacte:Say(nLInic, 0003, "CT-E CHAVE:", oFont08)
							Else
								oDacte:Say(nLInic, 0003, "NF-E CHAVE:", oFont08)
							EndIf
							oDacte:Say(nLInic, 0073, cChaveA, oFont08)
							cChaveA := ''
						EndIf
*/					Else
							//-- Imprime a Chave da NF-e, lado direito
//						If Empty(AllTrim(aDocOri[nCount][doDTC_NFEID])) .And. !Empty(AllTrim(aDocOri[nCount][doDTC_SERNFC]))
							oDacte:Say(nLInic, 0286, "NF", oFont08)
							oDacte:Say(nLInic, 0316, Transform(AllTrim(cRemCNPJ),"@r 99.999.999/9999-99"), oFont08)
							oDacte:Say(nLInic, 0448, cDipSer + " / " + cDipDoc, oFont08)
/*						ElseIf Empty(AllTrim(aDocOri[nCount][doDTC_NFEID]))
							//-- Imprime os dados do documento n�o fiscal do lado direito.
							oDacte:Say(nLInic, 0286, "Outros", oFont08)
							oDacte:Say(nLInic, 0316, Transform(AllTrim(cRemCNPJ),"@r 99.999.999/9999-99"), oFont08)
							oDacte:Say(nLInic, 0448, AllTrim(aDocOri[nCount][doDTC_NUMNFC]), oFont08)
						Else
							//-- Imprime a Chave da NF-e, lado direito
							cChaveB := AllTrim(aDocOri[nCount][doDTC_NFEID])
							If lMultModal
								oDacte:Say(nLInic, 0286, "CT-E CHAVE:", oFont08)
							Else
								oDacte:Say(nLInic, 0286, "NF-E CHAVE:", oFont08)
							EndIf
							oDacte:Say(nLInic, 0356, cChaveB, oFont08)
							cChaveB := ''
						EndIf
*/					EndIf
				ElseIf lControl
//					If Empty(AllTrim(aDocOri[nCount][doDTC_NFEID])) .And. !Empty(AllTrim(aDocOri[nCount][doDTC_SERNFC]))
						oDacte:Say(nLInic, 0003, "NF", oFont08)
						oDacte:Say(nLInic, 0033, Transform(AllTrim(cRemCNPJ),"@r 99.999.999/9999-99"), oFont08)
						oDacte:Say(nLInic, 0163, cDipSer + " / " + cDipDoc, oFont08)
/*					ElseIf Empty(AllTrim(aDocOri[nCount][doDTC_NFEID]))
						oDacte:Say(nLInic, 0003, "Outros", oFont08)
						oDacte:Say(nLInic, 0033, Transform(AllTrim(cRemCNPJ),"@r 99.999.999/9999-99"), oFont08)
						oDacte:Say(nLInic, 0163, AllTrim(aDocOri[nCount][doDTC_NUMNFC]), oFont08)					
					Else
						//-- Imprime a Chave da NF-e, lado direito
						cChaveA := AllTrim(aDocOri[nCount][doDTC_NFEID])
						oDacte:Say(nLInic, 0003, "NF-E CHAVE:", oFont08)
						oDacte:Say(nLInic, 0073, cChaveA, oFont08)
						cChaveA := ''
					EndIf
*/					If !Empty(cCtrDpc)
//						If Empty(cCTEDocAnt)
							oDacte:Say(nLInic, 0286, cDesDocAnt, oFont08)
							oDacte:Say(nLInic, 0316, Transform(AllTrim((cAliasCT)->DPC_CNPJ),"@r 99.999.999/9999-99"), oFont08)
							oDacte:Say(nLInic, 0448, AllTrim(cSerDpc) + " / " + AllTrim(cCtrDpc), oFont08)
/*						Else
							//-- Imprime a Chave da NF-e, lado esquerdo
							cChaveB := AllTrim(cCTEDocAnt)
							oDacte:Say(nLInic, 0286, "NF-E CHAVE:", oFont08)
							oDacte:Say(nLInic, 0356, cChaveB, oFont08)
							cChaveB := ''
						EndIf
*/					EndIf
				EndIf
			Else
				cTipoDoc := IIf(Empty(AllTrim(aDocOri[nCount][doDTC_NFEID])) .And. Empty(AllTrim(aDocOri[nCount][doDTC_SERNFC])),'Outros',IIf(Empty(AllTrim(aDocOri[nCount][doDTC_NFEID])),'NF','NF-e'))
				aadd(aDoc,{ AllTrim(cRemCNPJ),;
					cDipSer + " / " + cDipDoc,;
					AllTrim(aDocOri[nCount][doDTC_NFEID]),cTipoDoc})
				 //--Acrescenta o Tipo do Documento no aDoc
			EndIf

			// FORCAR A "QUEBRA" DA LINHA
			If ( (mod(nCount,2)) == 0 )
				If nCount < 11
					If !Empty(cChaveA)
						nLInic += 0008
						oDacte:Say(nLInic, 0003, "NF-E CHAVE:", oFont08)
						oDacte:Say(nLInic, 0073, cChaveA, oFont08)
						cChaveA := ''
					
						If !Empty(cChaveB)
							oDacte:Say(nLInic, 0286, "NF-E CHAVE:", oFont08)
							oDacte:Say(nLInic, 0356, cChaveB, oFont08)
							cChaveB := ''
						EndIf
					EndIf
					
					nLInic += 0008
				EndIf
			EndIf
		Next nCount
		nLInic := 2050
	Else
		TMSR27Cmp()
		TMSR27Comp()
	EndIf

	//������������������������������������������������������������������������Ŀ
	//� BOX: OBSERVACOES                                                       �
	//��������������������������������������������������������������������������
	oDacte:Box(0592,  0000, 0643, 0559)	
	oDacte:Say(0598,  0278, "Observa��es", oFont08N)
	oDacte:Line(0600, 0000, 0600, 0559) // Linha: OBSERVACOES
    nCountObs := 5
	If (cAliasCT)->DT6_AMBIEN == 2 .And. Empty((cAliasCT)->DT6_CHVCTG)
		cObsStat := "DOCUMENTO GERADO EM AMBIENTE DE HOMOLOGA��O"
		nCountObs -= 1
		cTagObs := 'OBSGER1;'
	ElseIf !Empty((cAliasCT)->DT6_CHVCTG) .And. Substr((cAliasCT)->DT6_CHVCTG,3,1) == "5"  //"7-Conting�ncia FS-DA"
		cObsStat := "DACTE em Conting�ncia - impresso em decorr�ncia de problemas t�cnicos"
		nCountObs -= 1
		cTagObs := 'OBSGER1;' 
	EndIf

	//������������������������������������������������������������������������Ŀ
	//� BOX: OBSERVACOES                                                       �
	//��������������������������������������������������������������������������
	dbSelectArea("DT6") //-- Nao retirar
		cDT6Obs := " "
		If Type("oNfe:_CTE:_INFCTE:_IMP:_INFADFISCO:TEXT") == "U"
			cDT6Obs := " "
		Else
			cDT6Obs := oNfe:_CTE:_INFCTE:_IMP:_INFADFISCO:TEXT
		EndIf
		cObsProp := " "
		If Type("oNfe:_CTE:_INFCTE:_INFCTENORM:_INFMODAL:_RODO:_VEIC:_PROP:_XNOME:TEXT") != "U" .And.;
			Type("oNfe:_CTE:_INFCTE:_INFCTENORM:_INFMODAL:_RODO:_VEIC:_TPPROP:TEXT") != "U"
			If oNfe:_CTE:_INFCTE:_INFCTENORM:_INFMODAL:_RODO:_VEIC:_TPPROP:TEXT == 'T'
				cObsProp += " Proprietario : " + AllTrim(oNfe:_CTE:_INFCTE:_INFCTENORM:_INFMODAL:_RODO:_VEIC:_PROP:_XNOME:TEXT)			
			EndIf	
		EndIf
		cDTCObs := " "
		If Type("oNfe:_CTE:_INFCTE:_COMPL:_XOBS:TEXT") != "U"
			cDTCObs += oNfe:_CTE:_INFCTE:_COMPL:_XOBS:TEXT
		EndIf
		If Type("oNfe:_CTE:_INFCTE:_COMPL:_OBSCONT") == "A"
			aObsCont := {}
			For nX := 1 to len(oNfe:_CTE:_INFCTE:_COMPL:_OBSCONT)
				aAdd(aObsCont, oNfe:_CTE:_INFCTE:_COMPL:_OBSCONT[nX]:_XTEXTO:TEXT )
			Next nX
		ElseIf Type("oNfe:_CTE:_INFCTE:_COMPL:_OBSCONT:_XTEXTO:TEXT") == "U"
			aObsCont := {""}
		Else
			aObsCont := {oNfe:_CTE:_INFCTE:_COMPL:_OBSCONT:_XTEXTO:TEXT}
		EndIf
	
	// Agendamento de Entrega
	If AliasIndic("DYD")
		If DYD->(FieldPos("DYD_DIAATR"))>0
			cDT6Obs += (" "+Posicione("DYD",2,xFilial("DYD")+(cAliasCT)->DT6_FILDOC+(cAliasCT)->DT6_DOC+(cAliasCT)->DT6_SERIE,"DYD_MOTAGD"))
		EndIf
	EndIf
			
	cDT6Obs3:= SubStr(cDT6Obs,281,140)
	cDT6Obs2:= SubStr(cDT6Obs,141,140)
	cDT6Obs := SubStr(cDT6Obs,1,140)  
	
	cObsProp:= SubStr(cObsProp,1,150)
	cDTCObs5:= SubStr(cDTCObs,601,150)
	cDTCObs4:= SubStr(cDTCObs,451,150)
	cDTCObs3:= SubStr(cDTCObs,301,150)
	cDTCObs2:= SubStr(cDTCObs,151,150)
	cDTCObs := SubStr(cDTCObs,1,150)	
	
	//������������������������������������������������������������������������Ŀ
	//� Tratamento para aproveitar todo o espaco do quadro observacao          �
	//��������������������������������������������������������������������������
	if !Empty(cDT6Obs)
	  nCountObs -= 1
	  cTagObs += 'OBSDT61;' 
	EndIf
	
	if !Empty(cDT6Obs2)
	  nCountObs -= 1
	  cTagObs += 'OBSDT62;' 
	EndIf
	
	if !Empty(cDTCObs)
	  nCountObs -= 1
	  cTagObs += 'OBSDTC1;' 
	EndIf
	
	if !Empty(cObsProp)
	  nCountObs -= 1
	  cTagObs  += 'OBSPRO1;' 
	EndIf
	
	If (nCountObs > 0) .AND. (!Empty(cDTCObs2))
	  nCountObs -= 1
	  cTagObs += 'OBSDTC2;' 
	EndIf
	
	If (nCountObs > 0) .AND. (!Empty(cDT6Obs3))
	  nCountObs -= 1
	  cTagObs += 'OBSDT63;' 
	EndIf
	
	If (nCountObs > 0) .AND. (!Empty(cDTCObs3))
	  nCountObs -= 1
	  cTagObs += 'OBSDTC3;' 
	EndIf
	
	If (nCountObs > 0) .AND. (!Empty(cDTCObs4))
	  nCountObs -= 1
	  cTagObs += 'OBSDTC4;' 
	EndIf
	
	If (nCountObs > 0) .AND. (!Empty(cDTCObs5))
	  nCountObs -= 1
	  cTagObs += 'OBSDTC5;' 
	EndIf
	
	nLinhaObs := 0608
	if AT('OBSGER1;',cTagObs) > 0
	  oDacte:Say (nLinhaObs, 0003, cObsStat, oFont10N)
	  nLinhaObs += 8  
	End IF
	
	if AT('OBSDT61;',cTagObs) > 0
	  oDacte:Say (nLinhaObs, 0003, cDT6Obs, oFont07)
	  nLinhaObs += 8  
	End IF
	
	if AT('OBSDT62;',cTagObs) > 0
	  oDacte:Say (nLinhaObs, 0003, cDT6Obs2, oFont07)
	  nLinhaObs += 8  
	End IF
	
	if AT('OBSDT63;',cTagObs) > 0
	  oDacte:Say (nLinhaObs, 0003, cDT6Obs3, oFont07)
	  nLinhaObs += 8  
	End IF
	
	if AT('OBSDTC1;',cTagObs) > 0
	  oDacte:Say (nLinhaObs, 0003, cDTCObs, oFont07)
	  nLinhaObs += 8  
	End IF
	
	if AT('OBSDTC2;',cTagObs) > 0
	  oDacte:Say (nLinhaObs, 0003, cDTCObs2, oFont07)
	  nLinhaObs += 8  
	End IF
	
	if AT('OBSDTC3;',cTagObs) > 0
	  oDacte:Say (nLinhaObs, 0003, cDTCObs3, oFont07)
	  nLinhaObs += 8  
	End IF
	
	if AT('OBSDTC4;',cTagObs) > 0
	  oDacte:Say (nLinhaObs, 0003, cDTCObs4, oFont07)
	  nLinhaObs += 8  
	End IF
	
	if AT('OBSDTC5;',cTagObs) > 0
	  oDacte:Say (nLinhaObs, 0003, cDTCObs5, oFont07)
	  nLinhaObs += 8  
	End IF
	
	if AT('OBSPRO1;',cTagObs) > 0
	  oDacte:Say (nLinhaObs, 0003, cObsProp, oFont07)
	  nLinhaObs += 8  
	End IF	
	

	//������������������������������������������������������������������������Ŀ
	//� BOX: INFORMACOES ESPECIFICAS DO MODAL                                  �
	//��������������������������������������������������������������������������
	oDacte:Box(0643, 0000, 0672, 0559)
	oDacte:Say(0650, 0210, "Dados Especificos do Modal Rodovi�rio - " + cRNLotacao, oFont08N) // Titulo nao pode ser "FIXO"
	oDacte:Line(0652, 0000, 0652, 0559)
	oDacte:Say(0660, 0143, "CIOT"                 			, oFont08N)
	oDacte:Say(0660, 0178, "Data Prevista de Entrega"		, oFont08N)
	oDacte:Say(0669, 0003, "RNTRC da Empresa: " + cTmsAntt	, oFont08)
//--oDacte:Say(0619, 0146, cRNLotacao,	oFont08) // Reservar campo para uso de CIOT

	//������������������������������������������������������������������������Ŀ
	//� RNTRC                                                                  �
	//��������������������������������������������������������������������������
	oDacte:Say(0669, 0190, cRNDtPrv,	oFont08)
	oDacte:Say(0669, 0283, cRNMensagem,	oFont07)
	oDacte:Line(0653, 0000, 0653, 0559) // Linha: Horizontal Dados Especificos do Modal Rodovi�rio
	oDacte:Line(0653, 0140, 0672, 0140) // Linha: Separador RNTRC x Lotacao
	oDacte:Line(0653, 0170, 0672, 0170) // Linha: Separador Lotacao x Data Prevista de Entrega
	oDacte:Line(0653, 0280, 0672, 0280) // Linha: Separador Data Prevista de Entrega x Mensagem	

	//������������������������������������������������������������������������Ŀ
	//� BOX: DADOS DE LOTACAO/VALE PEDAGIO                                     �
	//��������������������������������������������������������������������������
	oDacte:Box( 0674, 0000, 0734, 0559)
	oDacte:Line(0674, 0239, 0734, 0239) // Linha Vertical: Separador Informacoes Veiculo x Vale Ped�gio

	oDacte:Say(0680 , 0003, "Identifica�ao do Conjunto Transportador", oFont08N)
	oDacte:Say(0680 , 0246, "Informa��es referentes ao vale-ped�gio",  oFont08N)
	oDacte:Line(0682, 0000, 0682, 0559) // Linha Horizontal

	oDacte:Say(0688, 0003, "Tipo", oFont08N)
	oDacte:Say(0688, 0063, "Placa", oFont08N)
	oDacte:Say(0688, 0105, "UF", oFont08N)
	oDacte:Say(0688, 0125, "RNTRC", oFont08N)
	oDacte:Say(0688, 0246-4, "NRO.REG.ESP", oFont08N)
	oDacte:Say(0688, 0330-4, "Respons�vel", oFont08N)
	oDacte:Say(0688, 0455-4, "Valor Total", oFont08N)
	oDacte:Line(0690, 0000, 0690, 0559) // Linha Horizontal	:

	oDacte:Say(0696, 0246-4, "Empresa credenciada",		oFont08N)
	oDacte:Say(0696, 0330-4, "Vig�ncia",				oFont08N)
	oDacte:Say(0696, 0400-4, "N�mero do Dispositivo",	oFont08N)
	oDacte:Say(0696, 0480-4, "C�digo da Transa��o",		oFont08N)
	oDacte:Line(0698, 0243-4, 0698, 0559)		// Linha Horizontal	:

	oDacte:Line(0690, 0060, 0744, 0060)			//Linha Vertical: Separador Tipo x Placa
	oDacte:Line(0690, 0102, 0744, 0102)			//Linha Vertical: Placa x UF
	oDacte:Line(0690, 0122, 0744, 0122)			//Linha Vertical: UF x RNTRC

	oDacte:Line(0682, 0327-4, 0690, 0327-4)	//Linha Vertical: NRO.REG.ESP x Respons�vel
	oDacte:Line(0682, 0452-4, 0690, 0452-4)	//Linha Vertical: Respons�vel x Valor Total

	oDacte:Line(0698, 0327-4, 0734, 0327-4)	//Linha Vertical: Empresa credenciada x Vigencia
	oDacte:Line(0698, 0397-4, 0734, 0397-4)	//Linha Vertical: Vigencia x Numero do Dispositivo
	oDacte:Line(0698, 0477-4, 0734, 0477-4)	//Linha Vertical: Numero do Dispositivo x Codigo da Transa��o

	nLInic:= 0698
	nSoma := 0
	aMotoViag := {}
	
	//������������������������������������������������������������������������Ŀ
	//� LINHAS: TIPO (VEICULO)                                                 �
	//��������������������������������������������������������������������������
	/*	
		If (Type("oNFE:_CTE:_INFCTE:_INFCTENORM:_INFMODAL:_RODO")) <> "U" .And. (oNfe:_CTE:_INFCTE:_INFCTENORM:_INFMODAL:_RODO:_LOTA:TEXT) == '1'
			If ValType(oNfe:_CTE:_INFCTE:_INFCTENORM:_INFMODAL:_RODO:_VEIC) == "O" //Se a Tag do Ve�culo for um Objeto o mesmo possui apenas um ve�culo
				cTpVei := If(oNfe:_CTE:_INFCTE:_INFCTENORM:_INFMODAL:_RODO:_VEIC:_TPVEIC:TEXT == '0','TRACAO','REBOQUE')
				cPlaca :=  oNfe:_CTE:_INFCTE:_INFCTENORM:_INFMODAL:_RODO:_VEIC:_PLACA:TEXT
				cUF    :=  oNfe:_CTE:_INFCTE:_INFCTENORM:_INFMODAL:_RODO:_VEIC:_UF:TEXT
				cRNTRC :=  IIf((oNfe:_CTE:_INFCTE:_INFCTENORM:_INFMODAL:_RODO:_VEIC:_TPPROP:TEXT) == "P",cTmsAntt,;
				(oNfe:_CTE:_INFCTE:_INFCTENORM:_INFMODAL:_RODO:_VEIC:_PROP:_RNTRC:TEXT))

				oDacte:Say(nLInic + nSoma , 0003, SubStr(AllTrim(cTpVei),1,11), oFont08)
				oDacte:Say(nLInic + nSoma , 0063, cPlaca, oFont08)
				oDacte:Say(nLInic + nSoma , 0105, cUf, oFont08)
				oDacte:Say(nLInic + nSoma , 0125, cRNTRC, oFont08)
			Else //Caso n�o seja um objeto significa que possui mais de um ve�culo
				nY := 1
				While nY <= 4
					If Type("oNfe:_CTE:_INFCTE:_INFCTENORM:_INFMODAL:_RODO:_VEIC["+Str(nY,1)+"]:_TPROD:TEXT") != "U"
						cTpVei := If(oNfe:_CTE:_INFCTE:_INFCTENORM:_INFMODAL:_RODO:_VEIC[nY]:_TPVEIC:TEXT == '0','TRACAO','REBOQUE')
						cPlaca := oNfe:_CTE:_INFCTE:_INFCTENORM:_INFMODAL:_RODO:_VEIC[nY]:_PLACA:TEXT
						cUF    := oNfe:_CTE:_INFCTE:_INFCTENORM:_INFMODAL:_RODO:_VEIC[nY]:_UF:TEXT
						cRNTRC := IIf((oNfe:_CTE:_INFCTE:_INFCTENORM:_INFMODAL:_RODO:_VEIC[nY]:_TPPROP:TEXT) == "P",cTmsAntt,;
						(oNfe:_CTE:_INFCTE:_INFCTENORM:_INFMODAL:_RODO:_VEIC[nY]:_PROP:_RNTRC:TEXT))
					Else
						Exit
					EndIf
					oDacte:Say(nLInic + nSoma , 0003, SubStr(AllTrim(cTpVei),1,11), oFont08)
					oDacte:Say(nLInic + nSoma , 0063, cPlaca, oFont08)
					oDacte:Say(nLInic + nSoma , 0105, cUf, oFont08)
					oDacte:Say(nLInic + nSoma , 0125, cRNTRC, oFont08)
					nSoma += 10 //Caso o ve�culo a ser impresso n�o seja o primeiro pula uma linha no box
					nY += 1
				EndDo
			EndIf
			If	Type("oNfe:_CTE:_INFCTE:_INFCTENORM:_INFMODAL:_RODO:_MOTO") != "U"
				If ValType(oNfe:_CTE:_INFCTE:_INFCTENORM:_INFMODAL:_RODO:_MOTO) == "O"
					cNomeMoto:= oNfe:_CTE:_INFCTE:_INFCTENORM:_INFMODAL:_RODO:_MOTO:_XNOME:TEXT
					cCpfMoto := oNfe:_CTE:_INFCTE:_INFCTENORM:_INFMODAL:_RODO:_MOTO:_CPF:TEXT
					aAdd(aMotoViag,{cNomeMoto, cCPFMoto})
				Else
					For nX := 1 To Len(oNfe:_CTE:_INFCTE:_INFCTENORM:_INFMODAL:_RODO:_MOTO)
						cNomeMoto:= oNfe:_CTE:_INFCTE:_INFCTENORM:_INFMODAL:_RODO:_MOTO[nX]:_XNOME:TEXT
						cCpfMoto := oNfe:_CTE:_INFCTE:_INFCTENORM:_INFMODAL:_RODO:_MOTO[nX]:_CPF:TEXT
						If aScan(aMotoViag,{|x|x[1]+x[2]==cNomeMoto+cCPFMoto}) == 0
							aAdd(aMotoViag,{cNomeMoto, cCPFMoto})
						EndIf
					Next nX
				EndIf
			EndIf
			If	Type("oNfe:_CTE:_INFCTE:_INFCTENORM:_INFMODAL:_RODO:_LACRODO") != "U"
				If ValType(oNfe:_CTE:_INFCTE:_INFCTENORM:_INFMODAL:_RODO:_LACRODO) == "O"
					cLacre += oNfe:_CTE:_INFCTE:_INFCTENORM:_INFMODAL:_RODO:_LACRODO:_NLACRE:TEXT
				Else
					nY := 1
					While nY <= 5
						If Type("oNfe:_CTE:_INFCTE:_INFCTENORM:_INFMODAL:_RODO:_LACRODO["+Str(nY,1)+"]:_NLACRE:TEXT") != "U"
							If !Empty(cLacre)
								cLacre += ' / '
							EndIf
							cLacre += oNfe:_CTE:_INFCTE:_INFCTENORM:_INFMODAL:_RODO:_LACRODO[nY]:_NLACRE:TEXT
						Else
							Exit
						EndIf
						nY ++
					EndDo
				EndIf
			EndIf 
		ElseIf (Type("oNFE:_CTE:_INFCTE:_INFCTENORM:_INFMODAL:_RODO")) <> "U" .And. (oNfe:_CTE:_INFCTE:_INFCTENORM:_INFMODAL:_RODO:_LOTA:TEXT) == '1'
			If Type("oNfe:_CTE:_INFCTE:_INFCTENORM:_INFMODAL:_RODO:_VEIC") == "O" //Se a Tag do Ve�culo for um Objeto o mesmo possui apenas um ve�culo
				cTpVei := If(oNfe:_CTE:_INFCTE:_INFCTENORM:_INFMODAL:_RODO:_VEIC:_TPVEIC:TEXT == '0','TRACAO','REBOQUE')
				cPlaca := oNfe:_CTE:_INFCTE:_INFCTENORM:_INFMODAL:_RODO:_VEIC:_PLACA:TEXT
				cUF    := oNfe:_CTE:_INFCTE:_INFCTENORM:_INFMODAL:_RODO:_VEIC:_UF:TEXT
				cRNTRC := IIf((oNfe:_CTE:_INFCTE:_INFCTENORM:_INFMODAL:_RODO:_VEIC:_TPPROP:TEXT) == "P",cTmsAntt,;
				(oNfe:_CTE:_INFCTE:_INFCTENORM:_INFMODAL:_RODO:_RNTRC:TEXT))
				oDacte:Say(nLInic + nSoma , 0003, SubStr(AllTrim(cTpVei),1,11), oFont08)
				oDacte:Say(nLInic + nSoma , 0063, cPlaca, oFont08)
				oDacte:Say(nLInic + nSoma , 0105, cUf,    oFont08)
				oDacte:Say(nLInic + nSoma , 0125, cRNTRC, oFont08)
			Else //Caso n�o seja um objeto significa que possui mais de um ve�culo
				nY := 1
				While nY <= 4
					If Type("oNfe:_CTE:_INFCTE:_INFCTENORM:_INFMODAL:_RODO:_VEIC["+Str(nY,1)+"]:_TPROD:TEXT") != "U"
						cTpVei := If(oNfe:_CTE:_INFCTE:_INFCTENORM:_INFMODAL:_RODO:_VEIC[nY]:_TPVEIC:TEXT = '0','TRACAO','REBOQUE')
						cPlaca := oNfe:_CTE:_INFCTE:_INFCTENORM:_INFMODAL:_RODO:_VEIC[nY]:_PLACA:TEXT
						cUF    := oNfe:_CTE:_INFCTE:_INFCTENORM:_INFMODAL:_RODO:_VEIC[nY]:_UF:TEXT
						cRNTRC := IIf((oNfe:_CTE:_INFCTE:_INFCTENORM:_INFMODAL:_RODO:_VEIC[nY]:_TPPROP:TEXT) == "P",cTmsAntt,;
						(oNfe:_CTE:_INFCTE:_INFCTENORM:_INFMODAL:_RODO:_VEIC[nY]:_PROP:_RNTRC:TEXT))
					Else
						Exit
					EndIf
			   		oDacte:Say(nLInic + nSoma , 0003, SubStr(AllTrim(cTpVei),1,11), oFont08)
					oDacte:Say(nLInic + nSoma , 0063, cPlaca, oFont08)
					oDacte:Say(nLInic + nSoma , 0105, cUf,    oFont08)
					oDacte:Say(nLInic + nSoma , 0125, cRNTRC, oFont08)
					nSoma += 10 //Caso o ve�culo a ser impresso n�o seja o primeiro pula uma linha no box
					nY += 1
				EndDo
			EndIf
			If	Type("oNfe:_CTE:_INFCTE:_INFCTENORM:_INFMODAL:_RODO:_MOTO") != "U"
				If ValType(oNfe:_CTE:_INFCTE:_INFCTENORM:_INFMODAL:_RODO:_MOTO) == "O"
					cNomeMoto:= oNfe:_CTE:_INFCTE:_INFCTENORM:_INFMODAL:_RODO:_MOTO:_XNOME:TEXT
					cCpfMoto := oNfe:_CTE:_INFCTE:_INFCTENORM:_INFMODAL:_RODO:_MOTO:_CPF:TEXT
				Else
					For nX := 1 To Len(oNfe:_CTE:_INFCTE:_INFCTENORM:_INFMODAL:_RODO:_MOTO)
						cNomeMoto:= oNfe:_CTE:_INFCTE:_INFCTENORM:_INFMODAL:_RODO:_MOTO[nX]:_XNOME:TEXT
						cCpfMoto := oNfe:_CTE:_INFCTE:_INFCTENORM:_INFMODAL:_RODO:_MOTO[nX]:_CPF:TEXT
						If aScan(aMotoViag,{|x|x[1]+x[2]==cNomeMoto+cCPFMoto}) == 0
							aAdd(aMotoViag,{cNomeMoto, cCPFMoto})
						EndIf
					Next nX
				EndIf
			EndIf

			If	Type("oNfe:_CTE:_INFCTE:_INFCTENORM:_INFMODAL:_RODO:_LACRODO") != "U"
				If ValType(oNfe:_CTE:_INFCTE:_INFCTENORM:_INFMODAL:_RODO:_LACRODO) == "O"
					cLacre += oNfe:_CTE:_INFCTE:_INFCTENORM:_INFMODAL:_RODO:_LACRODO:_NLACRE:TEXT
				Else
					nY := 1
					While nY <= 5
						If Type("oNfe:_CTE:_INFCTE:_INFCTENORM:_INFMODAL:_RODO:_LACRODO["+Str(nY,1)+"]:_NLACRE:TEXT") != "U"
							If !Empty(cLacre)
								cLacre += ' / '
							EndIf
							cLacre += oNfe:_CTE:_INFCTE:_INFCTENORM:_INFMODAL:_RODO:_LACRODO[nY]:_NLACRE:TEXT
						Else
							Exit
						EndIf
						nY ++
					EndDo
				EndIf
			EndIf 
		EndIf
	*/
	//������������������������������������������������������������������������Ŀ
	//� BOX:  MOTORISTA                                                        �
	//��������������������������������������������������������������������������
	oDacte:Box(0736 , 0000, 0762, 0559)
	oDacte:Line(0736, 0243, 0762, 0243) // Linha: Nome do Motorista|CPF do Motorista
	oDacte:Line(0736, 0327, 0762, 0327) // Linha: CPF do Motorista|Identifica��o dos lacres em Tr�nsito
	oDacte:Line(0743, 0000, 0743, 0559) // Linha Horizontal
	oDacte:Say(0742 , 0003, "Nome do Motorista", oFont08N)
	oDacte:Say(0742 , 0246, "CPF do Motorista",  oFont08N)
	oDacte:Say(0742 , 0330, "Identifica��o dos lacres em Tr�nsitos", oFont08N)
	nSoma := 0
	For nX := 1 To Len(aMotoViag)
		If nX > 2
			Exit
		EndIf
		oDacte:Say(0750 + nSoma,0003, aMotoViag[nX,1], oFont08)
		oDacte:Say(0750 + nSoma,0246, aMotoViag[nX,2], oFont08)
		If nX == 1
			oDacte:Say(0735 + nSoma,0330, cLacre,    oFont08)
		EndIf
		nSoma += 10
	Next nX

	//������������������������������������������������������������������������Ŀ
	//� BOX: USO EXCLUSIVO DO EMISSOR + RESERVADO AO FISCO                     �
	//��������������������������������������������������������������������������
	oDacte:Box(0764 , 0000, 0810, 0559)
	oDacte:Say(0770 , 0090, "USO EXCLUSIVO DO EMISSOR DO CT-E", oFont08N)
	nSoma := 0
	For nX := 1 to len(aObsCont)
		If nX > 3
			Exit
		EndIf
		oDacte:Say(0780 + nSoma, 0003, aObsCont[nX], oFont08)
		nSoma += 10
	Next
	oDacte:Say(0770 , 0420, "RESERVADO AO FISCO", oFont08N)
	oDacte:Line(0773, 0000, 0773, 0559)	//Linha Horizontal
	oDacte:Line(0764, 0355, 0810, 0355)	//Linha Vertical

	//������������������������������������������������������������������������Ŀ
	//� Atualizar o Status de Impressao no CTe                                 �
	//��������������������������������������������������������������������������
	DT6->(dbSetOrder(1))
	If	DT6->(MsSeek(xFilial('DT6')+(cAliasCT)->DT6_FILDOC+(cAliasCT)->DT6_DOC+(cAliasCT)->DT6_SERIE))
		RecLock('DT6',.F.)
		DT6->DT6_FIMP := StrZero(1, Len(DT6->DT6_FIMP)) //Grava Flag de Impressao
		MsUnLock()
	EndIf
	oDacte:EndPage()

	//-- aDoc > 0, existe mais de uma pagina com Doc a ser impressa.
	//-- lPerig .T. existem produtos perigosos a serem impressos.
	If Len(aDoc) > 0 .Or. lPerig
		//-- Caso de mais de uma pagina, chama a funcao para montar as paginas seguites.
		TMSR27Cont(aDoc, aCab[nCont])
	EndIf
	(cAliasCT)->(DbSkip())
EndDo

//������������������������������������������������������������������������Ŀ
//� TERMINO ROTINA DE IMPRESSAO                                            �
//��������������������������������������������������������������������������
oDacte:Preview()

(cAliasCT)->(dbCloseArea())

Return(.T.)
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  |TMSR27Cont� Autor �Felipe Cunha           � Data �01/10/12  ���
�������������������������������������������������������������������������ĳ��
���Descri��o �Caso de mais de uma pagina, chama a funcao para montar      ���
���          �as paginas seguites.                                        ���
�������������������������������������������������������������������������Ĵ��
���Retorno   |                                                            ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Nenhum                                                      ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���          �               �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function TMSR27Cont(aDoc, aCab, aPerigo, nCnt)
Local oFont08     := TFont():New("Times New Roman",08,08,,.F.,,,,.T.,.F.)
Local oFont08N    := TFont():New("Times New Roman",08,08,,.T.,,,,.T.,.F.)
Local lControl    := .F.
Local nCount      := 0
Local aDoc1       := {}
Local cChaveA     := ''
Local cChaveB     := ''

//Variaveis Produtos Perigosos
Local nCompr		:= 50	//Comprimento Padrao da Primeira Linha
Local nSegLinha		:= 1	//Trecho a ser Impresso para cada linha
Local lVerif		:= .F.	//Evita Repeticao de Impressao
Local lFimPerig		:= .F.

Default nCnt		:= 1
Default aPerigo		:= {}
Default aDoc		:= {}
Default aCab		:= {}

oDacte:StartPage()
oDacte:SetPaperSize(Val(GetProfString(GetPrinterSession(),"PAPERSIZE","1",.T.)))

//������������������������������������������������������������������������Ŀ
//� Funcao responsavel pela montagem do cabecalho do DACTE                 �
//��������������������������������������������������������������������������
TMSR27Cab(aCab,.F.)

//������������������������������������������������������������������������Ŀ
//� BOX: DOCUMENTOS ORIGINARIOS                                            �
//��������������������������������������������������������������������������
oDacte:Box(0224, 0000, 0593, 0559)							
oDacte:Say(0230, 0210, "DOCUMENTOS ORIGINARIOS", oFont08N)

oDacte:Line(0232, 0000, 0232, 0559) 	// Linha: DOCUMENTOS ORIGINARIOS
oDacte:Line(0232, 0280, 0593, 0280) // Linha: Separador DOCUMENTOS ORIGINARIOS
oDacte:Say( 0238, 0003, "Tp.Doc"            , oFont08N)
oDacte:Say( 0238, 0033, "CNPJ/CPF Emitente" , oFont08N)
oDacte:Say( 0238, 0163, "S�rie/Nr.Documento", oFont08N)
oDacte:Say( 0238, 0286, "Tp.Doc"            , oFont08N)
oDacte:Say( 0238, 0316, "CNPJ/CPF Emitente" , oFont08N)
oDacte:Say( 0238, 0448, "S�rie/Nr.Documento", oFont08N)
//������������������������������������������������������������������������Ŀ
//� Imprime as NF                                                          �
//��������������������������������������������������������������������������
lControl := .F.
nLInic := 0244
For nCount := 1 To Len(aDoc)
	lControl := !lControl
	
	If nCount < 75         
		If (lControl == .T.)			
			If Empty(aDoc[nCount,3])
				oDacte:Say(nLInic, 0003, aDoc[nCount,4],										oFont08)
				oDacte:Say(nLInic, 0033, Transform(aDoc[nCount,1],"@r 99.999.999/9999-99"),	oFont08)
				oDacte:Say(nLInic, 0163, aDoc[nCount,2],										oFont08)
			Else
				cChaveA     := aDoc[nCount,3]
				oDacte:Say(nLInic, 0003, "NF-E CHAVE:"	,oFont08)
				oDacte:Say(nLInic, 0073,aDoc[nCount,3],oFont08)
				cChaveA     := ''
			EndIf
			
		Else
			If Empty(aDoc[nCount,3])
				oDacte:Say(nLInic, 0286, aDoc[nCount,4],									    oFont08)
				oDacte:Say(nLInic, 0316, Transform(aDoc[nCount,1],"@r 99.999.999/9999-99"),	oFont08)
				oDacte:Say(nLInic, 0448, aDoc[nCount,2],										oFont08)
			Else
				cChaveB     := aDoc[nCount,3]
				oDacte:Say(nLInic, 0286, "NF-E CHAVE:"	,oFont08)
				oDacte:Say(nLInic, 0356, aDoc[nCount,3],oFont08)
				cChaveB     := ''
			EndIf
			nLInic += 0008
		EndIf		
	Else
		aAdd(aDoc1,{aDoc[nCount,1],;
		aDoc[nCount,2],;
		aDoc[nCount,3],;
		aDoc[nCount,4]})
	EndIf
	
Next nCount

//������������������������������������������������������������������������Ŀ
//�Imprime a ultima Chave.                                                 �
//�FORCAR A "QUEBRA" DA LINHA                                              �
//��������������������������������������������������������������������������
If !Empty(cChaveA)
	nLInic += 0008
	oDacte:Say(nLInic, 0003, "NF-E CHAVE:",	oFont08)
	oDacte:Say(nLInic, 0073,cChaveA ,		oFont08)
	cChaveA := ''

	If !Empty(cChaveB)
		oDacte:Say(nLInic, 0286, "NF-E CHAVE:",	oFont08)
		oDacte:Say(nLInic, 0356, cChaveB,		oFont08)
		cChaveB := ''
	EndIf
EndIf

//������������������������������������������������������������������������Ŀ
//� BOX: Produtos Perigosos                                                �
//��������������������������������������������������������������������������
cAliasPeri := DataSource("PRODUTOS_PERIGOSOS")
nSoma   := 1380
nQtdTotal := 0

If (cAliasPeri)->(!Eof())
	nDifEsq:= 110
	nLInic := 2214
	oDacte:Box(0645 , 0000, 0820, 0559)
	oDacte:Say(0651 , 0200, "Informa��es sobre Produtos Perigosos", oFont08N)
	nSoma  := 12
	oDacte:Line(0653, 0000, 0653, 0559)		// Linha Horizontal
	oDacte:Line(0653, 0032, 0820, 0032 )	// Linha Divisoria Nro. Onu X Nome Apropriado
	oDacte:Line(0653, 0262, 0820, 0262 )	// Linha Divisoria Nome Apropriado X Classe/Subclasse e Risco Subsidi�rio
	oDacte:Line(0653, 0430, 0820, 0430 )	// Linha Divisoria Classe Subclasse e Risco Subsidi�rio X Grupo de Embalagem	
	oDacte:Line(0653, 0501, 0820, 0501 )	// Linha Divisoria Grupo de Embalagem X Qto. Tot. Produto	
	
	oDacte:Say(0659 , 0002, "Nro. Onu"			, oFont08N)			
	oDacte:Say(0659 , 0035, "Nome Apropriado" 	, oFont08N)	
	oDacte:Say(0659 , 0265, "Classe/Subclasse e Risco Subsidi�rio", oFont08N)
	oDacte:Say(0659 , 0433, "Grupo de Embalagem", oFont08N)
	oDacte:Say(0659 , 0504, "Qto. Tot. Produto" , oFont08N)
	nLInic :=  0665
	
	If DTC_PESO == 0
		nQtdTotal := Str(DTC_QTDVOL)
	Else
		nQtdTotal := Str(DTC_PESO)
	EndIf
	
	If Len(aPerigo) <= 0  
		Do While (cAliasPeri)->(!EoF())
			AAdd(aPerigo,{	(cAliasPeri)->DY3_ONU,;
							(cAliasPeri)->DY3_DESCRI,;
							(cAliasPeri)->DY3_CLASSE + ' ' + (cAliasPeri)->DY3_NRISCO, ;
							(cAliasPeri)->DY3_GRPEMB,;
							(cAliasPeri)->(nQtdTotal)})
			(cAliasPeri)->(dbSkip())
		EndDo
	EndIf

	For nCnt := nCnt to Len(aPerigo)														//Verifica tamanho do array
		oDacte:Say(nLInic , 0002,     aPerigo[nCnt][1]   , oFont08)						//Nro. Onu
		For nSegLinha:= nSegLinha To Len(aPerigo[nCnt][2])									//
			oDacte:Say(nLInic , 0035,Substr(aPerigo[nCnt][2],nSegLinha,nCompr), oFont08)	//Nome Apropriado 
			If !lVerif 																		//Nao repete valores a cada quebra de linha
				oDacte:Say(nLInic , 0265,aPerigo[nCnt][3]	, oFont08)						//Classe/Subclasse e Risco Subsidi�rio
				oDacte:Say(nLInic , 0433,aPerigo[nCnt][4] 	, oFont08)						//Grupo de Embalagem
				oDacte:Say(nLInic , 0504,aPerigo[nCnt][5]	, oFont08)						//Qto. Tot. Produto
				lVerif := .T.
			EndIf
			nSegLinha += nCompr -1
			If Len(aPerigo[nCnt][2]) > nSegLinha
				nLInic += 0008
			EndIf
			If nLInic >= 0770		//Verifica se chegou ao fim da pagina
				lFimPerig := .T.
				Exit
			EndIf
		Next
		If lFimPerig
			Exit
		EndIf
		nSegLinha := 1
		lVerif	:= .F. // Reinicia valor para o proximo elemento
	Next
	nCnt++
EndIf
(cAliasPeri)->(DbCloseArea())
//������������������������������������������������������������������������Ŀ
//� Linha de finalizacao.                                                  �
//��������������������������������������������������������������������������
oDacte:EndPage()

//������������������������������������������������������������������������Ŀ
//� Se existir mais doc para outra pagina, chama a mesma funcao.           �
//��������������������������������������������������������������������������
If Len(aDoc1) > 1
	TMSR27Cont(aDoc1,aCab)
EndIf

//������������������������������������������������������������������������Ŀ
//� Se existir mais prod perigoso para outra pagina, chama a mesma funcao. �
//��������������������������������������������������������������������������
If nLInic >= 0820
	TMSR27Cont(,aCab,aPerigo,nCnt)
EndIf

Return
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  � TMSR27Cab� Autor �Felipe Cunha           � Data �01/10/12  ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Funcao responsavel por montar o cabecalho do relatorio      ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Retorno   |                                                            ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Nenhum                                                      ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���          �               �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function TMSR27Cab(aCab, lImpCan)
Local oFont07    := TFont():New("Times New Roman",07,07,,.F.,,,,.T.,.F.)	//Fonte Times New Roman 07
Local oFont07N   := TFont():New("Times New Roman",07,07,,.T.,,,,.T.,.F.)	//Fonte Times New Roman 08 Negrito
Local oFont08    := TFont():New("Times New Roman",08,08,,.F.,,,,.T.,.F.)	//Fonte Times New Roman 08
Local oFont08N   := TFont():New("Times New Roman",08,08,,.T.,,,,.T.,.F.)	//Fonte Times New Roman 08 Negrito
Local cTpServ    := ''
Local cProtocolo := ''
Local cStartPath := GetSrvProfString("Startpath","")
Local cTmsAntt   := SuperGetMv( "MV_TMSANTT", .F., .F. )	//Numero do registro na ANTT com 14 d�gitos
Local cLogoTp	 := cStartPath + "logoCte" + cEmpAnt + ".BMP" //Insira o caminho do Logo da empresa logada, na variavel cLogoTp.

Default lImpCan  := .F.

If	IsSrvUnix() .And. GetRemoteType() == 1
	cLogoTp := StrTran(cLogoTp,"/","\")
Endif

If  !File(cLogoTp)
	cLogoTp    := cStartPath + "logoCte.bmp"
EndIf


//������������������������������������������������������������������������Ŀ
//� BOX: CANHOTO - 0746                                                    �
//��������������������������������������������������������������������������
If	lImpCan

	_cCliDev :=Posicione("DT6",1,xFilial("DT6")+cFILANT+aCab[1]+aCab[2],"DT6_CLIDEV")
	_cLojDev :=Posicione("DT6",1,xFilial("DT6")+cFILANT+aCab[1]+aCab[2],"DT6_LOJDEV")
	_cNomUser:=UsrRetName(Posicione("DT6",1,xFilial("DT6")+cFILANT+aCab[1]+aCab[2],"DT6_USRGER"))
	_cCgcDev :=Posicione("SA1",1,xFilial("SA1")+_cCliDev+_cLojDev,"A1_CGC")
	_cNomDev :=Posicione("SA1",1,xFilial("SA1")+_cCliDev+_cLojDev,"A1_NOME")
	_cMunDev :=Posicione("SA1",1,xFilial("SA1")+_cCliDev+_cLojDev,"A1_MUN")
	_cEstDev :=Posicione("SA1",1,xFilial("SA1")+_cCliDev+_cLojDev,"A1_EST")
	
	oDacte:Box(0020, 0000, 0082, 0559)
	oDacte:Say(026 , 0005, "TOMADOR: " + SPACE(05) +Transform(_cCgcDev, PesqPict("SA1","A1_CGC"))+ '  -  ' + SPACE(05) +;
	_cNomDev + '  -  ' + SPACE(05) + _cMunDev + '  -  '  + _cEstDev + '  -  ' + SPACE(05) + AllTrim(SM0->M0_CIDCOB) + '  -  ' +;
	AllTrim(SM0->M0_ESTCOB) , oFont07)
	
	oDacte:Line(0029, 0000, 0029, 0559) // Linha horizontal
	oDacte:Say(0036 , 0001, "DECLARO QUE RECEBI OS VOLUMES DESTE CONHECIMENTO EM PERFEITO ESTADO PELO QUE DOU POR CUMPRIDO O PRESENTE CONTRATO DE TRANSPORTE", oFont07)
	oDacte:Line(0039, 0000, 0039, 0559) // Linha horizontal
	
	oDacte:Line(0062, 0000, 0062, 0166) // Linha Horizontal: Separador NOME e RG
	oDacte:Line(0062, 0416, 0062, 0513) // Linha Horizontal: Separador CHEGADA e SAIDA
	
	oDacte:Line(0039, 0166, 0082, 0166) // Linha vertical
	oDacte:Line(0039, 0416, 0082, 0416) // Linha vertical
	oDacte:Line(0039, 0513, 0082, 0513) // Linha vertical
	
	oDacte:Say(0047 , 0005, "Nome"               	, oFont07N)
	oDacte:Say(0047 , 0421, "Chegada Data / Hora"	, oFont07N)
	oDacte:Say(0047 , 0530, "CT-e"					, oFont07N)
	oDacte:Say(0057 , 0530, "Nro: " , oFont07N)
	oDacte:Say(0067 , 0518, cValtoChar( Val(aCab[1]))	, oFont07N)
	oDacte:Say(0079 , 0518, "S�rie: "+cValtoChar( Val(aCab[2]))	, oFont07N)
	oDacte:Say(0070 , 0005, "R.G"                	, oFont07N)
	oDacte:Say(0079 , 0241, "Assinatura / Carimbo"  , oFont07N)
	oDacte:Say(0070 , 0421, "Sa�da Data / Hora"  	, oFont07N)
EndIf

//Gabriel Delta
//������������������������������������������������������������������������Ŀ
//� BOX: Empresa + 0050                                                    �
//��������������������������������������������������������������������������
oDacte:Box(0086, 0000, 0150, 0310)
oDacte:SayBitmap(0088, 0005,cLogoTp,0105,0040 )		//Logo
oDacte:Say(0100, 0115, AllTrim(SM0->M0_NOMECOM),oFont08) 	//Nome Comercial
oDacte:Say(0110, 0115, AllTrim(SM0->M0_ENDCOB) ,oFont08)	//Endereco
oDacte:Say(0120, 0115, AllTrim(SM0->M0_BAIRCOB),oFont08)	//Bairro      
oDacte:Say(0120, 0180, " - " + AllTrim(SM0->M0_CIDCOB) + '  -  ' + AllTrim(SM0->M0_ESTCOB) + '  CEP.:  ' + AllTrim(SM0->M0_CEPCOB) ,oFont08)	//Cidade, UF, CEP
oDacte:Say(0130, 0115, 'CNPJ: ' + Transform(AllTrim(SM0->M0_CGC),"@r 99.999.999/9999-99"))
oDacte:Say(0130, 0205, 'Inscri��o Estadual: ' + AllTrim(SM0->M0_INSC)	,oFont08)	//CNPJ e IE
oDacte:Say(0140, 0115, 'Telefone: '           + AllTrim(SM0->M0_TEL)	,oFont08)	//Telefone
oDacte:Say(0140, 0205, 'RNTRC da Empresa: '   + AllTrim(cTmsAntt)		,oFont08)	//RNTRC da Empresa

//������������������������������������������������������������������������Ŀ
//� BOX: DACTE                                                             �
//��������������������������������������������������������������������������
oDacte:Box(0086, 0310, 0103, 0370)					
oDacte:Say(0092, 0326, "DACTE", oFont08N)
oDacte:Say(01000, 340, (Upper("Documento Auxiliar do CT-e")),oFont08)

//������������������������������������������������������������������������Ŀ
//� BOX: MODAL                                                             �
//��������������������������������������������������������������������������
oDacte:Box(0086, 0370, 0103, 0430)
oDacte:Say(0092, 385, "MODAL"     , oFont08N)
oDacte:Say(0100, 382, "Rodovi�rio", oFont08 )

//������������������������������������������������������������������������Ŀ
//�BOX: Modelo / Serie / Numero / Folha / Emis                             �
//��������������������������������������������������������������������������
oDacte:Box(0103, 0310, 0120, 0430)
oDacte:Say(0111, 0315, "Modelo" , oFont08N)	//Modelo
oDacte:Say(0118, 0320, "57",oFont08)
oDacte:Say(0111, 0350, "Serie"  , oFont08N)	//Serie
oDacte:Say(0118, 0355, cValtoChar( Val(aCab[2]) ), oFont08)
oDacte:Say(0111, 0380, "N�mero" , oFont08N)	//Numero
oDacte:Say(0118, 0380, cValtoChar( Val(aCab[1]) ), oFont08)

oDacte:Box(0120, 0310, 0150, 0430)
oDacte:Say(0130, 0317.5, "Folha"  , oFont08N)	//Folha
oDacte:Say(0137, 0320, AllTrim(Str(nFolhAtu)) + " / " + AllTrim(Str(nFolhas)), oFont08)
nFolhAtu ++

oDacte:Say(0130, 0375, "Emiss�o", oFont08N)//Emissao
oDacte:Say(0137, 0355, 	SubStr(AllTrim(aCab[3]), 7, 2) + '/'   +;
						SubStr(AllTrim(aCab[3]), 5, 2) + "/"   +; 
						SubStr(AllTrim(aCab[3]), 1, 4) + " - " +;
						SubStr(AllTrim(aCab[4]), 1, 2) + ":"   +;	
						SubStr(AllTrim(aCab[4]), 3, 2) + ":00")

//In�cio Delta - Gabriel Ver�ssimo Lakatos 12/11/19						
//IMPRESS�O DO QRCODE
cQrCode := "https://nfe.fazenda.sp.gov.br/CTeConsulta/qrCode?chCTe=" + AllTrim(aCab[5]) + "&tpAmb=1"
oDacte:QRCode(211,435,cQrCode, 1)
//Fim Delta - Gabriel Ver�ssimo Lakatos 12/11/19

//������������������������������������������������������������������������Ŀ
//� BOX: Controle do Fisco                                                 �
//��������������������������������������������������������������������������
oDacte:Box(0150, 0150, 0184, 0430) 
If	AllTrim((cAliasCT)->DT6_CHVCTG)<>''
	oDacte:Code128C(179,0160,(cAliasCT)->DT6_CHVCTE, 29)	
	oDacte:Code128C(228.8,0160,(cAliasCT)->DT6_CHVCTG, 29) //49.8
Else
	oDacte:Code128C(179,0160,(cAliasCT)->DT6_CHVCTE, 29)	
EndIf
//oDacte:Line(0153, 0324, 0153, 0559 )	//Linha Separadora
oDacte:Box(0184, 0150, 0218, 0430)
oDacte:Say( 0190, 0160,"Chave de acesso para consulta de autenticidade no site www.cte.fazenda.gov.br",oFont07)
oDacte:Say( 0197, 0160, Transform(AllTrim(aCab[5]),"@r 99.9999.99.999.999/9999-99-99-999-999.999.999.999.999.999.9"), oFont08N) 
//oDacte:Line(0172, 0324, 0172, 0559 )	//Linha Separadora

//������������������������������������������������������������������������Ŀ
//�  BOX: Tipo do CTe                                                      �
//��������������������������������������������������������������������������
oDacte:Box(0150, 0000, 0167 , 0158)
oDacte:Say(0156, 0003, "Tipo do CTe"                 , oFont08N)
oDacte:Say(0156, 0073, "Tipo de Servi�o"             , oFont08N)

oDacte:Box(0167, 0000, 0184 , 0158)
oDacte:Say(0173, 0003, "Tomador do Servi�o"          , oFont08N)
oDacte:Say(0173, 0073, "Forma de Pagamento"          , oFont08N)

oDacte:Box(0184, 0000, 0201 , 0158)
oDacte:Say(0190, 0003, "N�mero do Protocolo"         , oFont08N)

oDacte:Box(0201, 0000, 0218 , 0158)
oDacte:Say(0207, 0003, "Insc.Suframa do Destinat�rio", oFont08N)
oDacte:Line(0150, 0071, 0167 , 0071) // Linha: Divide Tp.CTe e Tp.Servico
//oDacte:Line(0150, 0158, 0167 , 0158) // Linha: Tp.Servico e Tomador
oDacte:Line(0167, 0071, 0184 , 0071) // Linha: Tomador e Forma Pagto
//oDacte:Line(0205, 0322, 0222 , 0322) // Linha: Divide Forma Pagto e Protocolo
//oDacte:Line(0205, 0455, 0222 , 0455) // Linha: Divide Protocolo e Suframa Dest.

//�����������������������������������������������������������������Ŀ
//� Tipo de Conhecimento                                            �
//� 0 - Normal                                                      �
//� 1 - Complemento de Valores                                      �
//� 2 - Emitido em Hipotese de anulacao de Debito                   �
//�������������������������������������������������������������������
If ( AllTrim((cAliasCT)->DT6_DOCTMS) == "8" )
	oDacte:Say(0163,  0003, "COMPLEMENTO"	, oFont08)
ElseIf ( AllTrim((cAliasCT)->DT6_DOCTMS) == "P" )
	oDacte:Say(0163,  0003, "SUBSTITUTO"		, oFont08)	
ElseIf ( AllTrim((cAliasCT)->DT6_DOCTMS) == "M" )
	oDacte:Say(0163,  0003, "ANULACAO"		, oFont08)
Else
	oDacte:Say(0163,  0003, "NORMAL"		, oFont08)
EndIf

//�����������������������������������������������������������������Ŀ
//� Tipo de Servico                                                 �
//� 0 - Normal                                                      �
//� 1 - SubContratacao                                              �
//� 2 - Redespacho                                                  �
//� 3 - Redespacho Intermediario                                    �
//� 4 - Servi�o Vinculado a Multimodal                              �
//�������������������������������������������������������������������
//�����������������������������������������������������������������Ŀ
//� DTC - Notas Fiscais: (Informacao do campo DTC_TIPNFC)           �
//�   0 - Normal                                                    �
//�   1 - Devolucao                                                 �
//�   2 - SubContratacao                                            �
//�   3 - Dcto Nao Fiscal                                           �
//�   4 - Exportacao                                                �
//�   5 - Redespacho                                                �
//�   6 - Dcto Nao Fiscal 1                                         �
//�   7 - Dcto Nao Fiscal 2                                         �
//�������������������������������������������������������������������
cTpServ := oNfe:_CTE:_INFCTE:_IDE:_tpserv:TEXT

If (cTpServ $ '0')
	oDacte:Say(0163, 0073, "NORMAL"				, oFont08)
ElseIf (cTpServ == '1')
	oDacte:Say(0163, 0073, "SUBCONTRATA��O"		, oFont08)
ElseIf (cTpServ == '2')
	oDacte:Say(0163, 0073, "REDESPACHO"			, oFont08)
ElseIf (cTpServ == '3')
	oDacte:Say(0163, 0073, "REDESPACHO INTERM"			, oFont08)	//--Redespacho Intermedi�rio
ElseIf (cTpServ == '4')
	oDacte:Say(0163, 0073, "SERV.VINC.MULTIMODAL"			, oFont08)	//--Servi�o vinculado Multimodal
	lMultModal := .T.
Else
	oDacte:Say(0163, 0073, "NORMAL"				, oFont08)
EndIf

//�����������������������������������������������������������������Ŀ
//� Tomador do Servico                                              �
//� 0 - Remetente;                                                  �
//� 1 - Expedidor;                                                  �
//� 2 - Recebedor;                                                  �
//� 3 - Destinatario;                                               �
//� 4 - Outros. (Consignatario / Despachante)                       �
//�������������������������������������������������������������������
//�����������������������������������������������������������������Ŀ
//� Forma de Pagamento do Servico                                   �
//� 0 - Pago                                                        �
//� 1 - A pagar                                                     �
//� 2 - Outros                                                      �
//�������������������������������������������������������������������
If Type("oNfe:_CTE:_INFCTE:_IDE:_TOMA03:_TOMA:TEXT") <> "U"
	If oNfe:_CTE:_INFCTE:_IDE:_TOMA03:_TOMA:TEXT == "0"
		oDacte:Say(0180,  0003, "REMETENTE"  	, oFont08)	//Tomador do Servico
		oDacte:Say(0180,  0073, "PAGO"       	, oFont08)	//Forma de Pagamento do Servico
	ElseIf oNfe:_CTE:_INFCTE:_IDE:_TOMA03:_TOMA:TEXT == "1"
		oDacte:Say(0180,  0003, "EXPEDIDOR"  	, oFont08)
		oDacte:Say(0180,  0073, "A PAGAR"       , oFont08)
	ElseIf oNfe:_CTE:_INFCTE:_IDE:_TOMA03:_TOMA:TEXT == "2"
		oDacte:Say(0180,  0003, "RECEBEDOR"  	, oFont08)
		oDacte:Say(0180,  0073, "A PAGAR"       , oFont08)
	ElseIf oNfe:_CTE:_INFCTE:_IDE:_TOMA03:_TOMA:TEXT == "3"
		oDacte:Say(0180,  0003, "DESTINAT�RIO"  , oFont08)
		oDacte:Say(0180,  0073, "A PAGAR"       , oFont08)
	EndIf
ElseIf Type("oNfe:_CTE:_INFCTE:_IDE:_TOMA4:_TOMA:TEXT") <> "U"
	If oNfe:_CTE:_INFCTE:_IDE:_TOMA4:_TOMA:TEXT == "4"
		oDacte:Say(0180,  0003, "OUTROS"  	, oFont08)
		oDacte:Say(0180,  0073, "OUTROS"    , oFont08)
	EndIf
EndIf

//�����������������������������������������������������������������Ŀ
//� Numero Protocolo + Data e Hora Autorizacao                      �
//�������������������������������������������������������������������
cProtocolo := aCab[6] + " " + aCab[8] + " " + aCab[9]
oDacte:Say(0197,  0003, cProtocolo, oFont08)

//�����������������������������������������������������������������Ŀ
//� Insc.Suframa do Destinat�rio                                    �
//�������������������������������������������������������������������
oDacte:Say(0214,  0003, AllTrim((cAliasCT)->DES_SUFRAMA), oFont08)

Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �TMSR27Comp� Autor �Felipe Cunha           � Data �01/10/12  ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Funcao responsavel por montar o BOX com as informacoes do   ���
���          �componentes do frete e impostos                             ���
�������������������������������������������������������������������������Ĵ��
���Retorno   |                                                            ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Nenhum                                                      ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���          �               �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function TMSR27Comp()
Local cLabel      	:= ''
Local nCInic      	:= 0			// Coluna Inicial
Local oFont08     	:= TFont():New("Times New Roman",08,08,,.F.,,,,.T.,.F.)
Local oFont08N    	:= TFont():New("Times New Roman",08,08,,.T.,,,,.T.,.F.)
Local oFont10N    	:= TFont():New("Times New Roman",10,10,,.T.,,,,.T.,.F.)
Local lControl    	:= .F.
Local nCount      	:= 0
Local nCount_2    	:= 0
Local cSitTriba		:= "Sit Trib"
Local cBaseIcms		:= ''			//-- Base de Calculo
Local cAliqIcms		:= ''			//-- Aliquota ICMS
Local cValIcms		:= ''			//-- Valor ICMS
Local cRedBcCalc	:= ''			//-- "Red.Bc.Calc."
Local nCount_3		:= 0
Local aComp			:= {}

//������������������������������������������������������������������������Ŀ
//� BOX: COMPONENTES DA PRESTACAO                                          �
//��������������������������������������������������������������������������
If lComp
	nLInic	:= 0505
	nLFim	:= 0563	
Else
	nLInic	:= 0445
	nLFim	:= 0503	
EndIf

oDacte:Box(nLInic, 0000, nLFim, 0559)

nLInic	+= 0008
oDacte:Say(nLInic, 0210, "Componentes do Valor da Presta��o de Servi�o", oFont08N)
	
nLInic	+= 0004
	
oDacte:Line(nLInic, 0000, nLInic, 0559) // Linha: Componentes da Prestacao
oDacte:Line(nLInic, 0070, nLFim, 0070) // Linha: Separador Vertical
oDacte:Line(nLInic, 0140, nLFim, 0140) // Linha: Separador Vertical
oDacte:Line(nLInic, 0210, nLFim, 0210) // Linha: Separador Vertical
oDacte:Line(nLInic, 0280, nLFim, 0280) // Linha: Separador Vertical
oDacte:Line(nLInic, 0350, nLFim, 0350) // Linha: Separador Vertical
oDacte:Line(nLInic, 0420, nLFim, 0420) // Linha: Separador Vertical
	
nLInic	+= 0006
oDacte:Say(nLInic, 0003, "Nome",	oFont08N)
oDacte:Say(nLInic, 0073, "Valor",	oFont08N)
oDacte:Say(nLInic, 0143, "Nome",	oFont08N)
oDacte:Say(nLInic, 0213, "Valor",	oFont08N)
oDacte:Say(nLInic, 0283, "Nome",	oFont08N)
oDacte:Say(nLInic, 0353, "Valor",	oFont08N)
oDacte:Say(nLInic, 0423, "Valor Total do Servi�o", oFont08N)
	
//������������������������������������������������������������������������Ŀ
//� Componentes do Valor da Prestacao de Servico                           �
//��������������������������������������������������������������������������
//������������������������������������������������������������������������Ŀ
//�DT8 - Componentes do Frete                                              �
//��������������������������������������������������������������������������
nLInic		+= 0008
nCInic		:= 0003
lControl	:= .F.

	aComp := TMSGetComp( oNfe )
		
	For nCount_3 := 1 To Len( aComp )
		nCount += 2
		oDacte:Say(nLInic, nCInic, Substr(AllTrim(aComp[nCount_3][1]),1,14), oFont08)	//Descricao do Componente
		nCInic += 0070	//Proxima Coluna

		oDacte:Say(nLInic, nCInic, Transform(Val(AllTrim(aComp[nCount_3][2])),'@E 999,999,999.99'), oFont08)	//Valor do Componente
		nCInic += 0070	//Proxima Coluna


		//������������������������������������������������������������������������Ŀ
		//� FORCAR A "QUEBRA" DA LINHA, SENDO 6 CAMPOS POR LINHA.                  �
		//��������������������������������������������������������������������������
		If ( (mod(nCount,6)) == 0 )
			nCount_2 += 1
			Do Case
				Case ( nCount_2 == 1 )
				cLabel := PadL(Transform(Val(oNFE:_CTE:_INFCTE:_VPREST:_VTPREST:TEXT),'@E 999,999,999.99'),20)
				Case ( nCount_2 == 2 )
				cLabel := ""
				Case ( nCount_2 == 3 )
					oDacte :Line(nLInic - 8, 0420, nLInic - 8, 0559) // Linha: VALOR A RECEBER
					cLabel := "Valor a Receber"
				Case ( nCount_2 == 4 )
					cLabel := PadL(Transform(Val(oNFE:_CTE:_INFCTE:_VPREST:_VREC:TEXT),'@E 999,999,999.99'),20)
			EndCase
				
			oDacte:Say(nLInic , 0423, cLabel, oFont10N)
			nLInic   += 0008
			nCInic   := 0003
		EndIf
	Next nCount_3
	For nCount := (1 + nCount) To 24
		lControl := !lControl
		nCInic   += 0070
		cLabel   := ""
		
		//������������������������������������������������������������������������Ŀ
		//� FORCAR A "QUEBRA" DA LINHA, SENDO 6 CAMPOS POR LINHA.                  �
		//��������������������������������������������������������������������������
		If ( (mod(nCount,6)) == 0 )
			nCount_2 += 1
			Do Case
				Case ( nCount_2 == 1 )
					cLabel := PadL(Transform(Val(oNFE:_CTE:_INFCTE:_VPREST:_VTPREST:TEXT),'@E 999,999,999.99'),20)
				Case ( nCount_2 == 2 )
					cLabel := ""
				Case ( nCount_2 == 3 )
					oDacte :Line(nLInic - 8, 0420, nLInic - 8, 0559) // Linha: VALOR A RECEBER
					cLabel := "Valor a Receber"
				Case ( nCount_2 == 4 )
					cLabel := PadL(Transform(Val(oNFE:_CTE:_INFCTE:_VPREST:_VREC:TEXT),'@E 999,999,999.99'),20)
			EndCase
			
			oDacte:Say(nLInic , 0423, cLabel, oFont10N)
			nLInic   += 0008
			nCInic   := 0003
		EndIf
	Next nCount

//������������������������������������������������������������������������Ŀ
//� BOX: INFORMACOES RELATIVAS AO IMPOSTO                                  �
//��������������������������������������������������������������������������

If !lComp
	nLInic	:= 0505
	nLFim	:= 0531	
Else
	nLInic	:= 0565
	nLFim	:= 0591
EndIf

oDacte:Box(nLInic , 0000, nLFim, 0559)

nLInic += 0006
oDacte:Say(nLInic , 0212, "Informa��es Relativas ao Imposto", oFont08N)

nLInic += 0002
oDacte:Line(nLInic, 0000, nLInic, 0559)	// Linha:
oDacte:Line(nLInic, 0240, nLFim, 0240)	// Linha: Separador Situacao Trib	/ Base de Calculo
oDacte:Line(nLInic, 0350, nLFim, 0350) 	// Linha: Separador Base de Calculo	/ Aliq.ICMS
oDacte:Line(nLInic, 0400, nLFim, 0400) 	// Linha: Separador Aliq.ICMS    	/ Valor ICMS
oDacte:Line(nLInic, 0470, nLFim, 0470) 	// Linha: Separador Valor ICMS    	/ %Red Bc.Calc

nLInic += 0008
oDacte:Say(nLInic , 0003, "Situa��o Tribut�ria", oFont08N)   // Label: Situa��o Tribut�ria
oDacte:Say(nLInic , 0243, "Base de C�lculo"    , oFont08N)   // Label: Base de C�lculo
oDacte:Say(nLInic , 0353, "Aliq.ICMS"          , oFont08N)   // Label: Aliq.ICMS
oDacte:Say(nLInic , 0403, "Valor ICMS"         , oFont08N)   // Label: Valor ICMS
oDacte:Say(nLInic , 0473, "%Red.Bc.Calc."      , oFont08N)   // Label: %Red.Bc.Calc.

	/*�����������������������������������������������������������������Ŀ
	  � Tag <ICMS00>                                                    �
	  �������������������������������������������������������������������*/
	If !Type("oNfe:_CTE:_INFCTE:_IMP:_ICMS:_ICMS00:_CST:TEXT")=="U"

		cAliasD2  := DataSource( 'DESCRSUBSTTRIBUTARIA' )
		
		cSitTriba	:= Iif( Type("oNfe:_CTE:_INFCTE:_IMP:_ICMS:_ICMS00:_CST:TEXT")=="U"," ",;
		oNfe:_CTE:_INFCTE:_IMP:_ICMS:_ICMS00:_CST:TEXT + " - " + SubStr(AllTrim((cAliasD2)->X5_DESCRI),1,40) )

		cBaseIcms	:= Val(oNFE:_CTE:_INFCTE:_IMP:_ICMS:_ICMS00:_VBC:TEXT)
		cAliqIcms	:= Val(oNFE:_CTE:_INFCTE:_IMP:_ICMS:_ICMS00:_PICMS:TEXT)
		cValIcms	:= Val(oNFE:_CTE:_INFCTE:_IMP:_ICMS:_ICMS00:_VICMS:TEXT)
		
		(cAliasD2)->(DbCloseArea())
	/*�����������������������������������������������������������������Ŀ
	  � Tag <ICMS45>                                                    �
	  �������������������������������������������������������������������*/
	ElseIf !Type("oNfe:_CTE:_INFCTE:_IMP:_ICMS:_ICMS45:_CST:TEXT") == "U"

		cAliasD2  := DataSource( 'DESCRSUBSTTRIBUTARIA' )

		cSitTriba	:= Iif( Type("oNfe:_CTE:_INFCTE:_IMP:_ICMS:_ICMS45:_CST:TEXT")=="U"," ",;
		oNfe:_CTE:_INFCTE:_IMP:_ICMS:_ICMS45:_CST:TEXT + " - " + SubStr(AllTrim((cAliasD2)->X5_DESCRI),1,40) )
		
		(cAliasD2)->(DbCloseArea()) 
	/*�����������������������������������������������������������������Ŀ
	  � Tag <ICMS90>                                                    �
	  �������������������������������������������������������������������*/
	ElseIf !Type("oNfe:_CTE:_INFCTE:_IMP:_ICMS:_ICMS90:_CST:TEXT") == "U"

		cAliasD2  := DataSource( 'DESCRSUBSTTRIBUTARIA' )

		cSitTriba	:= Iif( Type("oNfe:_CTE:_INFCTE:_IMP:_ICMS:_ICMS90:_CST:TEXT")=="U"," ",;
		oNfe:_CTE:_INFCTE:_IMP:_ICMS:_ICMS90:_CST:TEXT + " - " + SubStr(AllTrim((cAliasD2)->X5_DESCRI),1,40) )

		cBaseIcms	:= Val(oNFE:_CTE:_INFCTE:_IMP:_ICMS:_ICMS90:_VBC:TEXT)
	   	cAliqIcms	:= Val(oNFE:_CTE:_INFCTE:_IMP:_ICMS:_ICMS90:_PICMS:TEXT)
		cValIcms	:= Val(oNFE:_CTE:_INFCTE:_IMP:_ICMS:_ICMS90:_VICMS:TEXT)
		cRedBcCalc := Val(Iif( Type("oNFE:_CTE:_INFCTE:_IMP:_ICMS:_ICMS90:_pRedBC:TEXT")=="U"," ",(oNFE:_CTE:_INFCTE:_IMP:_ICMS:_ICMS90:_pRedBC:TEXT) ))
		
		(cAliasD2)->(DbCloseArea())
	/*�����������������������������������������������������������������Ŀ
	  � Tag <ICMS20>                                                    �
	  �������������������������������������������������������������������*/
	ElseIf !Type("oNfe:_CTE:_INFCTE:_IMP:_ICMS:_ICMS20:_CST:TEXT") == "U"

		cAliasD2  := DataSource( 'DESCRSUBSTTRIBUTARIA' )

		cSitTriba	:= Iif( Type("oNfe:_CTE:_INFCTE:_IMP:_ICMS:_ICMS20:_CST:TEXT")=="U"," ",;
		oNfe:_CTE:_INFCTE:_IMP:_ICMS:_ICMS20:_CST:TEXT + " - " + SubStr(AllTrim((cAliasD2)->X5_DESCRI),1,40) )

		cBaseIcms	:= Val(oNFE:_CTE:_INFCTE:_IMP:_ICMS:_ICMS20:_VBC:TEXT)
		cAliqIcms	:= Val(oNFE:_CTE:_INFCTE:_IMP:_ICMS:_ICMS20:_PICMS:TEXT)
		cValIcms	:= Val(oNFE:_CTE:_INFCTE:_IMP:_ICMS:_ICMS20:_VICMS:TEXT)
		cRedBcCalc := Val(oNFE:_CTE:_INFCTE:_IMP:_ICMS:_ICMS20:_pRedBC:TEXT)
		
		(cAliasD2)->(DbCloseArea())
	/*�����������������������������������������������������������������Ŀ
	  � Tag <ICMS60>                                                    �
	  �������������������������������������������������������������������*/
	ElseIf !Type("oNfe:_CTE:_INFCTE:_IMP:_ICMS:_ICMS60:_CST:TEXT") == "U"

		cAliasD2  := DataSource( 'DESCRSUBSTTRIBUTARIA' )

		cSitTriba	:= Iif( Type("oNfe:_CTE:_INFCTE:_IMP:_ICMS:_ICMS60:_CST:TEXT")=="U"," ",;
		oNfe:_CTE:_INFCTE:_IMP:_ICMS:_ICMS60:_CST:TEXT + " - " + SubStr(AllTrim((cAliasD2)->X5_DESCRI),1,40) )

		cBaseIcms	:= Val(oNFE:_CTE:_INFCTE:_IMP:_ICMS:_ICMS60:_VBCSTRET:TEXT)
		cCredPres	:= Val(oNFE:_CTE:_INFCTE:_IMP:_ICMS:_ICMS60:_vCred:TEXT)
		
		(cAliasD2)->(DbCloseArea())
	ElseIf !Type("oNfe:_CTE:_INFCTE:_IMP:_ICMS:_ICMSOutraUF:_CST:TEXT") == "U"

		cAliasD2  := DataSource( 'DESCRSUBSTTRIBUTARIA' )

		cSitTriba	:= Iif( Type("oNfe:_CTE:_INFCTE:_IMP:_ICMS:_ICMSOutraUF:_CST:TEXT")=="U"," ",;
		oNfe:_CTE:_INFCTE:_IMP:_ICMS:_ICMSOutraUF:_CST:TEXT + " - " + SubStr(AllTrim((cAliasD2)->X5_DESCRI),1,40) )

		cBaseIcms	:= Val(oNFE:_CTE:_INFCTE:_IMP:_ICMS:_ICMSOutraUF:_vBCOutraUF:TEXT)
		cAliqIcms	:= Val(oNFE:_CTE:_INFCTE:_IMP:_ICMS:_ICMSOutraUF:_pICMSOutraUF:TEXT)
		cValIcms	:= Val(oNFE:_CTE:_INFCTE:_IMP:_ICMS:_ICMSOutraUF:_vICMSOutraUF:TEXT)
		cRedBcCalc := Val(Iif( Type("oNFE:_CTE:_INFCTE:_IMP:_ICMS:_ICMSOutraUF:_pRedBCOutraUF:TEXT")=="U"," ",(oNFE:_CTE:_INFCTE:_IMP:_ICMS:_ICMSOutraUF:_pRedBCOutraUF:TEXT) ))	
		
		(cAliasD2)->(DbCloseArea())
	/*�����������������������������������������������������������������Ŀ
	  � Tag <ICMSSN> Simples Nacional                                   �
	  �������������������������������������������������������������������*/	
	ElseIf !Type("oNfe:_CTE:_INFCTE:_IMP:_ICMS:_ICMSSN:_indSN:TEXT")=="U"		
		cSitTriba	:= Iif( Type("oNfe:_CTE:_INFCTE:_IMP:_ICMS:_ICMSSN:_indSN:TEXT")=="U"," "," Simples Nacional ")		
	EndIf	

nLInic += 0008
oDacte:Say(nLInic , 0003, cSitTriba,								oFont08)
oDacte:Say(nLInic , 0243, Transform(cBaseIcms , '@E 999,999,999.99'),	oFont08)
oDacte:Say(nLInic , 0353, Transform(cAliqIcms , '@E 999,999,999.99'),	oFont08)
oDacte:Say(nLInic , 0403, Transform(cValIcms  , '@E 999,999,999.99'),	oFont08)
oDacte:Say(nLInic , 0473, Transform(cRedBcCalc, '@E 999,999,999.99'),	oFont08)

lComp := .F. //CTE Complementar

Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  � TMSR27Cmp� Autor �Felipe Cunha           � Data �01/10/12  ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Funcao responsavel por montar o BOX relativo as informacoes ���
���          �dos componentes e valores complementados                    ���
�������������������������������������������������������������������������Ĵ��
���Retorno   |                                                            ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Nenhum                                                      ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���          �               �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function TMSR27Cmp()

Local nCount    := 0
Local nCount_2  := 0
Local oFont08   := TFont():New("Times New Roman",08,08,,.F.,,,,.T.,.F.)
Local oFont08N  := TFont():New("Times New Roman",08,08,,.T.,,,,.T.,.F.)
Local lControl  := .F.
Local cAliasChv := ''

lComp := .T.	//CTE Complementar

//������������������������������������������������������������������������Ŀ
//� BOX: COMPONENTES DO VALOR DA PRESTACAO DO SERVICO                      �
//��������������������������������������������������������������������������
nLInic  := 0397
nLFim   := 0503
oDacte:Box(nLInic , 0000, nLFim, 0559)

nLInic += 0006
oDacte:Say(nLInic , 0210, "Componentes do Valor da Presta��o do Servi�o", oFont08N)

nLInic += 0002
oDacte:Line(nLInic, 0000, nLInic, 0559)		// Linha: DOCUMENTOS ORIGINARIOS       
oDacte:Line(nLInic, 0279, nLFim , 0279)	// Linha: Separador DOCUMENTOS ORIGINARIOS

nLInic += 0007
oDacte:Say(nLInic , 0003, "Chave do CT-e Complementado", oFont08N)
oDacte:Say(nLInic , 0205, "Valor Complementado", oFont08N)
oDacte:Say(nLInic , 0281, "Chave do CT-e Complementado", oFont08N)
oDacte:Say(nLInic , 0483, "Valor Complementado", oFont08N)

nLInic   += 0008
nCount   := 0
nCount_2 := 0
lControl := .F.

//-- Query para pesquisar a chave do CTE original
cAliasChv :=  GetNextAlias()
cQuery := ''
cQuery += " SELECT DT6.DT6_CHVCTE " +CRLF
cQuery += "   FROM " + RetSqlName('DT6') + " DT6 " +CRLF
cQuery += "  WHERE DT6.DT6_FILIAL = '" + xFilial('DT6') + "'" +CRLF
cQuery += "    AND DT6.DT6_FILDOC = '" + (cAliasCT)->DT6_FILDCO + "'" +CRLF
cQuery += "    AND DT6.DT6_DOC    = '" + (cAliasCT)->DT6_DOCDCO + "'" +CRLF
cQuery += "    AND DT6.DT6_SERIE  = '" + (cAliasCT)->DT6_SERDCO + "'" +CRLF
cQuery += "    AND DT6.D_E_L_E_T_ = ' '"
cQuery := ChangeQuery(cQuery)
DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAliasChv, .F., .T.)

nCount   := 0
While !(cAliasChv)->(Eof())

	nCount   += 1
	lControl := !lControl

	If nCount < 9

		If (lControl == .T.)
			oDacte:Say(nLInic, 0003, Transform(AllTrim((cAliasChv)->DT6_CHVCTE),"@!")	, oFont08)
			oDacte:Say(nLInic, 0205, PadL(Transform((cAliasCT)->DT6_VALFAT,'@E 9,999,999.9999'),20), oFont08)
		Else
			oDacte:Say(nLInic, 0281, Transform(AllTrim((cAliasChv)->DT6_CHVCTE),"@!")	, oFont08)
		EndIf

	EndIf

	(cAliasChv)->(DbSkip())

EndDo

(cAliasChv)->(dbCloseArea())

Return
/*/
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
����������������������������������������������������������������������������Ŀ��
���Fun��o    �AjustaSX1     � Autor �Felipe Cunha          � Data �01/10/12  ���
����������������������������������������������������������������������������Ĵ��
���Descri��o �Ajusta o X1_GSC                                                ���
����������������������������������������������������������������������������Ĵ��
���Sintaxe   �AjustaSX1()                                                    ���
����������������������������������������������������������������������������Ĵ��
��������������������������������������������������������������������������������
/*/
Static Function AjustaSX1()
Local aArea    := GetArea()
Local cTamLot  := TamSX3("DTP_LOTNFC")[1]
Local cTamDoc  := TamSX3("DT6_DOC")[1]
Local cTamSer  := TamSX3("DT6_SERIE")[1]
Local cTamTip  := TamSX3("DT6_DOCTMS")[1]
Local aHelpPor := {}
Local aHelpEng := {}
Local aHelpEsp := {}

aHelpPor := {"Informe o lote inicial."}
aHelpEng := {"Introduzca el lote inicial."}
aHelpEsp := {"Enter the initial batch."}
PutSx1(	"RTMSR25", "01", "Lote De", "De Lote?", "From Lot?", ;
			"MV_CH1", "C",cTamLot, 0, 0, "G", "", "DTP", "", "", ;
			"MV_PAR01", "", "", "", "", "", "", "", "", ;
			"", "", "", "N", "", "", "", "", ;
			aHelpPor, aHelpEng, aHelpEsp )

aHelpPor := {"Informe o lote final."}
aHelpEng := {"Introduzca la mezcla final."}
aHelpEsp := {"Enter the final blend."}
PutSx1(	"RTMSR25", "02", "Lote Ate", "A Lote?", "To Lot?", ;
			"MV_CH2", "C", cTamLot, 0, 0, "G", "", "DTP", "", "", ;
			"MV_PAR02", "", "", "", "", "", "", "", "", ;
			"", "", "", "N", "", "", "", "", ;
			aHelpPor, aHelpEng, aHelpEsp )


//-- Numero do Documento.
aHelpPor := {"Informe o documento inicial."}
aHelpEng := {"Introduzca el documento de partida."}
aHelpEsp := {"Enter the starting document."}
PutSx1(	"RTMSR25", "03", "Documento De", "De Documento", "From Document", ;
			"MV_CH3", "C", cTamDoc, 0, 0, "G", "", "DT6", "", "", ;
			"MV_PAR03", "", "", "", "", "", "", "", "", ;
			"", "", "", "N", "", "", "", "", ;
			aHelpPor, aHelpEng, aHelpEsp )
			
aHelpPor := {"Informe o documento final."}
aHelpEng := {"Introduzca el documento final."}
aHelpEsp := {"Enter the final document."}
PutSx1(	"RTMSR25", "04", "Documento Ate", "A Documento", "To Document", ;
			"MV_CH4", "C", cTamDoc, 0, 0, "G", "", "DT6", "", "", ;
			"MV_PAR04", "", "", "", "", "", "", "", "", ;
			"", "", "", "N", "", "", "", "", ;
			aHelpPor, aHelpEng, aHelpEsp )


//-- Serie do Documento.
aHelpPor := {"Informe  serie do documento inicial."}
aHelpEng := {"Informe de la serie del documento original."}
aHelpEsp := {"Report series of the original document."}
PutSx1(	"RTMSR25", "05", "Serie De", "De Serie", "From Series", ;
			"MV_CH5", "C", cTamSer, 0, 0, "G", "", "", "", "", ;
			"MV_PAR05", "", "", "", "", "", "", "", "", ;
			"", "", "", "N", "", "", "", "", ;
			aHelpPor, aHelpEng, aHelpEsp )

aHelpPor := {"Informe  serie do documento final."}
aHelpEng := {"La serie de Informes del documento final."}
aHelpEsp := {"Report series of the final document."}
PutSx1(	"RTMSR25", "06", "Serie Ate", "A Serie", "To Series", ;
			"MV_CH6", "C", cTamSer, 0, 0, "G", "", "", "", "", ;
			"MV_PAR06", "", "", "", "", "", "", "", "", ;
			"", "", "", "N", "", "", "", "", ;
			aHelpPor, aHelpEng, aHelpEsp )


//-- Tipo do Documento.
aHelpPor := {"Informe  o tipo do documento."}
aHelpEng := {"Introduzca el tipo de documento."}
aHelpEsp := {"Enter the type of document."}
PutSx1(	"RTMSR25", "07", "Tipo do Documento", "Tipo do Documento", "Document Type", ;
			"MV_CH7", "C", cTamTip, 0, 0, "G", "", "DLC", "", "", ;
			"MV_PAR07", "", "", "", "", "", "", "", "", ;
			"", "", "", "N", "", "", "", "", ;
			aHelpPor, aHelpEng, aHelpEsp )

// Busca XML
SX1->(DbSetOrder(1))
If SX1->(MsSeek(Padr("RTMSR25",Len(SX1->X1_GRUPO))+"08")) 
	RecLock('SX1',.F.)
	dbDelete()
	MsUnLock()
EndIf

RestArea(aArea)
Return Nil
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �RTMSR27   � Autor �Felipe Cunha        � Data �01/10/12     ���
�������������������������������������������������������������������������͹��
���Desc.     � Retorna um Array com a estrutura do campo complemento rel. ���
���          � ao objeto passado por parametro                            ���
�������������������������������������������������������������������������͹��
���Uso       � TMS                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function TMSGetComp( oObject )
Local i			:= 0		// Auxiliar no Incremento da Estrutura de Laco
Local aAuxClone	:= { }		// Copia da propriedade Comp do Objeto passado por parametro
Local aAuxComp	:= { }		// Auxiliar no processamento de aAuxClone
Local aResult	:= { }		// Retorno da Funcao
 If Valtype(XmlChildEx(oObject:_CTE:_INFCTE:_VPREST,"_COMP")) <> "U"
	If	ValType(oObject:_CTE:_INFCTE:_VPREST:_COMP) == "A"
		aAuxClone := ACLONE( oObject:_CTE:_INFCTE:_VPREST:_COMP )
		For i := 1 To Len( aAuxClone )
			AADD( aResult, {AllTrim(aAuxClone[ i ]:_XNOME:TEXT), AllTrim(aAuxClone[ i ]:_VCOMP:TEXT)} )
		Next i
	ElseIf	ValType(oObject:_CTE:_INFCTE:_VPREST:_COMP) == "O"
		AADD( aAuxComp, AllTrim(oObject:_CTE:_INFCTE:_VPREST:_COMP:_XNOME:TEXT) )
		AADD( aAuxComp, AllTrim(oObject:_CTE:_INFCTE:_VPREST:_COMP:_VCOMP:TEXT) )
		AADD( aResult, aAuxComp )
		aAuxComp := {}
	EndIf
 EndIf
Return ( aResult )


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �RTMSR27   � Autor �Felipe Cunha        � Data �01/10/12     ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function DataSource( cSource )
Local cNewArea	:= GetNextAlias()
Local cQuery	:= ""

cQuery := GetSQL( cSource )
DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cNewArea, .F., .T.)

Return ( cNewArea )

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �RTMSR27   � Autor �Felipe Cunha        � Data �01/10/12     ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �  Cria DACTE sem utilizar o XML, utilizando tabela.         ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function GetSQL( cSource )
Local cQuery	:= ""
Local cSitTriba	:= ""
// Verifica se existe filtro por lote especifico
Local lFiltLote := Empty(MV_PAR01) .Or. MV_PAR02 = 'ZZZZZZ' 


If	cSource == 'DT6'
	cQuery += "    SELECT " + CRLF
	cQuery += "    CTRC.DT6_FILDOC,                " +CRLF
	cQuery += "    CTRC.DT6_SERIE,                 " +CRLF
	cQuery += "    CTRC.DT6_DOC,                   " +CRLF
	cQuery += "    CTRC.DT6_DOCTMS,                " +CRLF
	cQuery += "    CTRC.DT6_CHVCTE,                " +CRLF
	cQuery += "    CTRC.DT6_PROCTE,                " +CRLF
	cQuery += "    CTRC.DT6_VALFAT,                " +CRLF
	cQuery += "    CTRC.DT6_FILDCO,                " +CRLF
	cQuery += "    CTRC.DT6_DOCDCO,                " +CRLF
	cQuery += "    CTRC.DT6_SERDCO,                " +CRLF
	cQuery += "    CTRC.DT6_AMBIEN,                " +CRLF
	cQuery += "    CTRC.DT6_DEVFRE,                " +CRLF
	cQuery += "    CTRC.DT6_CHVCTG,                " +CRLF
	
	cQuery += "    CLIDES.A1_SUFRAMA DES_SUFRAMA,  " +CRLF
	
	cQuery += "    CLIDPC.A1_CGC DPC_CNPJ         " +CRLF
	
	cQuery += "   FROM " + RetSqlName('DT6') + " CTRC " + CRLF
	
	cQuery += "        INNER JOIN " + RetSqlName('SA1') + " CLIDES ON (CLIDES.A1_COD = CTRC.DT6_CLIDES AND CLIDES.A1_LOJA = CTRC.DT6_LOJDES AND CLIDES.D_E_L_E_T_ = ' ' ) " + CRLF
	
	cQuery += "        LEFT  JOIN " + RetSqlName('SA1') + " CLIDPC ON (CLIDPC.A1_FILIAL = '" + xFilial('SA1') + "' AND CLIDPC.A1_COD = CTRC.DT6_CLIDPC AND CLIDPC.A1_LOJA = CTRC.DT6_LOJDPC AND CLIDPC.D_E_L_E_T_ = ' ' ) " + CRLF
	
	cQuery += "  WHERE CTRC.DT6_FILIAL  = '" + xFilial('DT6') + "'" + CRLF
	cQuery += "    AND CTRC.DT6_FILORI  = '" + cFilAnt  + "'" + CRLF
	cQuery += "    AND CTRC.DT6_LOTNFC >= '" + MV_PAR01 + "'" + CRLF
	cQuery += "    AND CTRC.DT6_LOTNFC <= '" + MV_PAR02 + "'" + CRLF

	cQuery += "    AND (CTRC.DT6_IDRCTE  = '100' OR CTRC.DT6_IDRCTE  = '136' OR (CTRC.DT6_CHVCTG  <> ' '))" + CRLF

	cQuery += "    AND CTRC.DT6_FILDOC  = '" + cFilAnt + "'" + CRLF
	cQuery += "    AND CTRC.DT6_DOC    >= '" + MV_PAR03 + "'" + CRLF
	cQuery += "    AND CTRC.DT6_DOC    <= '" + MV_PAR04 + "'" + CRLF
	cQuery += "    AND CTRC.DT6_SERIE  >= '" + MV_PAR05 + "'" + CRLF
	cQuery += "    AND CTRC.DT6_SERIE  <= '" + MV_PAR06 + "'" + CRLF
	If !Empty(MV_PAR07)
		cQuery += "    AND CTRC.DT6_DOCTMS  = '" + MV_PAR07 + "'" + CRLF
	EndIf
	cQuery += "    AND CTRC.D_E_L_E_T_  = ' ' " + CRLF

	cQuery += "  AND CLIDES.A1_FILIAL  = '"  + xFilial('SA1') + "'" + CRLF
	cQuery += "  AND CLIDES.D_E_L_E_T_ = ' '" + CRLF
	
	If lFiltLote .And. (Empty(MV_PAR07) .Or. MV_PAR07 == 'M')

		cQuery += " UNION " + CRLF
	
		cQuery += " SELECT SF1.F1_FILORIG DT6_FILDOC, " + CRLF
		cQuery += " 	   SF1.F1_SERIE DT6_SERIE, " + CRLF
		cQuery += " 	   SF1.F1_DOC DT6_DOC, " + CRLF
		cQuery += " 	   'M' DT6_DOCTMS, " + CRLF
		cQuery += " 	   SF1.F1_CHVNFE DT6_CHVCTE, " + CRLF
		cQuery += " 	   ' ' DT6_PROCTE, " + CRLF
		cQuery += " 	   SF1.F1_VALBRUT DT6_VALFAT, " + CRLF
		cQuery += "        SF1.F1_FILORIG DT6_FILDCO, " + CRLF
		cQuery += " 	   SF1.F1_NFORIG DT6_DOCDCO, " + CRLF
		cQuery += " 	   SF1.F1_SERORIG DT6_SERDCO, " + CRLF
		cQuery += " 	   0 DT6_AMBIEN, " + CRLF
		cQuery += " 	   '' DT6_DEVFRE, " + CRLF
		cQuery += " 	   '' DT6_CHVCTG," + CRLF
		cQuery += " 	   '' DES_SUFRAMA, " + CRLF
		cQuery += " 	   '' DPC_CNPJ" + CRLF
							
		cQuery += "   FROM " + RetSqlName('SF1') + " SF1 " + CRLF
	
		cQuery += "  WHERE SF1.F1_FILIAL  = '" + xFilial('SF1') + "'" + CRLF
		cQuery += "    AND SF1.F1_FORMUL = 'S' " + CRLF
		cQuery += "    AND SF1.F1_DOC    >= '" + MV_PAR03 + "'" + CRLF
		cQuery += "    AND SF1.F1_DOC    <= '" + MV_PAR04 + "'" + CRLF
		cQuery += "    AND SF1.F1_SERIE  >= '" + MV_PAR05 + "'" + CRLF
		cQuery += "    AND SF1.F1_SERIE  <= '" + MV_PAR06 + "'" + CRLF
		cQuery += "    AND SF1.F1_TPCTE  = 'A'" + CRLF
		cQuery += "    AND SF1.F1_TIPO   = 'D'" + CRLF
		cQuery += "    AND SF1.D_E_L_E_T_  = ' ' " + CRLF
	EndIf    

	cQuery += "  ORDER BY 1, 2, 3 "

ElseIf cSource == 'DTC'

	cQuery += " SELECT Count(Distinct NF.DTC_NUMNFC) nTotal "
	cQuery += "   FROM " + RetSqlName('DTC') + " NF "
	cQuery += "  WHERE NF.DTC_FILIAL = '" + xFilial("DTC") + "'"
	cQuery += "    AND NF.DTC_FILDOC = '" + AllTrim((cAliasCT)->DT6_FILDOC) + "'"
	cQuery += "    AND NF.DTC_DOC    = '" + AllTrim((cAliasCT)->DT6_DOC)    + "'"
	cQuery += "    AND NF.DTC_SERIE  = '" + AllTrim((cAliasCT)->DT6_SERIE)  + "'"
	cQuery += "    AND NF.D_E_L_E_T_ =' '"

ElseIf cSource == 'DESCRSUBSTTRIBUTARIA'

	cQuery := " SELECT SX5.X5_DESCRI"
	cQuery += " FROM " + RetSqlName("SX5") + " SX5 "
	cQuery += " WHERE SX5.X5_FILIAL ='"  + xFilial("SX5") + "'"
	cQuery += "   AND SX5.X5_TABELA ='S2'"

	If !Type("oNfe:_CTE:_INFCTE:_IMP:_ICMS:_ICMS00:_CST:TEXT")=="U"
		cSitTriba := Iif( Type("oNfe:_CTE:_INFCTE:_IMP:_ICMS:_ICMS00:_CST:TEXT")=="U"," ",;
		oNfe:_CTE:_INFCTE:_IMP:_ICMS:_ICMS00:_CST:TEXT)
	ElseIf !Type("oNfe:_CTE:_INFCTE:_IMP:_ICMS:_ICMS45:_CST:TEXT")=="U"
		cSitTriba := Iif( Type("oNfe:_CTE:_INFCTE:_IMP:_ICMS:_ICMS45:_CST:TEXT")=="U"," ",;
		oNfe:_CTE:_INFCTE:_IMP:_ICMS:_ICMS45:_CST:TEXT)
	ElseIf !Type("oNfe:_CTE:_INFCTE:_IMP:_ICMS:_ICMS90:_CST:TEXT")=="U"
		cSitTriba := Iif( Type("oNfe:_CTE:_INFCTE:_IMP:_ICMS:_ICMS90:_CST:TEXT")=="U"," ",;
		oNfe:_CTE:_INFCTE:_IMP:_ICMS:_ICMS90:_CST:TEXT)
	ElseIf !Type("oNfe:_CTE:_INFCTE:_IMP:_ICMS:_ICMS20:_CST:TEXT")=="U"
		cSitTriba := Iif( Type("oNfe:_CTE:_INFCTE:_IMP:_ICMS:_ICMS20:_CST:TEXT")=="U"," ",;
		oNfe:_CTE:_INFCTE:_IMP:_ICMS:_ICMS20:_CST:TEXT)
	ElseIf !Type("oNfe:_CTE:_INFCTE:_IMP:_ICMS:_ICMS60:_CST:TEXT")=="U"
		cSitTriba := Iif( Type("oNfe:_CTE:_INFCTE:_IMP:_ICMS:_ICMS60:_CST:TEXT")=="U"," ",;
		oNfe:_CTE:_INFCTE:_IMP:_ICMS:_ICMS60:_CST:TEXT)
	ElseIf !Type("oNfe:_CTE:_INFCTE:_IMP:_ICMS:_ICMSOutraUF:_CST:TEXT")=="U"
		cSitTriba := Iif( Type("oNfe:_CTE:_INFCTE:_IMP:_ICMS:_ICMSOutraUF:_CST:TEXT")=="U"," ",;
		oNfe:_CTE:_INFCTE:_IMP:_ICMS:_ICMSOutraUF:_CST:TEXT)
	EndIf

	cQuery += " AND SX5.X5_CHAVE  ='" +cSitTriba+ "'"
	cQuery += " AND SX5.D_E_L_E_T_<>'*'"

ElseIf cSource == "PRODUTOS_PERIGOSOS"

	cQuery := " SELECT DTC.DTC_PESO, DTC.DTC_QTDVOL, DY3.DY3_ONU, DY3.DY3_DESCRI, DY3.DY3_GRPEMB, DY3.DY3_CLASSE, DY3.DY3_NRISCO "
	cQuery += " FROM " + RetSqlName("DTC") + " DTC , " + RetSqlName("SB5") + " SB5 , " + RetSqlName("DY3") + " DY3 "
	cQuery += " WHERE DTC.DTC_FILIAL   = '"  + xFilial("DT6") + "' "
	cQuery += " AND DTC.DTC_FILDOC = '" + (cAliasCT)->DT6_FILDOC + "'"
	cQuery += " AND DTC.DTC_DOC = '" + (cAliasCT)->DT6_DOC + "'"
	cQuery += " AND DTC.DTC_SERIE = '" + (cAliasCT)->DT6_SERIE + "'"
	cQuery += " AND SB5.B5_CARPER = '1' " //-- Carga Perigosa
	cQuery += " AND DTC.DTC_CODPRO = SB5.B5_COD"
	cQuery += " AND DY3.DY3_ONU = SB5.B5_ONU "
	cQuery += " AND DY3.DY3_ITEM = SB5.B5_ITEM "
	cQuery += " AND DTC.D_E_L_E_T_ = ' '"
	cQuery += " AND SB5.D_E_L_E_T_ = ' '"
	cQuery += " AND DY3.D_E_L_E_T_ = ' '"

EndIf

cQuery := ChangeQuery( cQuery )

Return ( cQuery )
static function UsaColaboracao(cModelo)
Local lUsa := .F.

If FindFunction("ColUsaColab")
	lUsa := ColUsaColab(cModelo)
endif
return (lUsa)

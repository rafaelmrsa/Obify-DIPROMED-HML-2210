#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "RESTFUL.CH"

#DEFINE CRLF Chr(13)+Chr(10)

/*/{Protheus.doc} INT001
Importação CT-e
@author DLeme
@type User function
@since Dez/2021
@version 1.0
/*/

User Function JL43IDE5(cID)

	Local aArea 	:= GetArea()
	Local aSays     := {}
	Local aButtons	:= {}
	Local nOpca     := 0
	Local lRet 		:= .T.
	Local cCadastro := "Integração CT-e"
	Local cErro		:= ""
	Local lCancel	:= .F.
	Local cIdProc	:= ""
	Local cProcess	:= ""
	Local oSay
	//Local nOpc := 3
	Default cID 	:= ""
	//cID 	:= PA0->PA0_ID

	If IsBlind()
		ConOut(">> JL43IDE5 - Inicio Importação XML CT-e!")
		ProcXMLCTe(cID,cErro,lCancel,cIdProc,cProcess)
		ConOut(">> JL43IDE5 - Fim Importação XML CT-e!")
	Else

		//SaveInter()
		If Empty(cID)
			Pergunte("JL43IDE5 ",.F.)

			Aadd( aSays, "Este programa tem objetivo de processar os registros com  " )
			Aadd( aSays, "Status conforme informado dos parametros. ")

			Aadd( aButtons, { 1, .T., {|o| nOpca := 1, o:oWnd:End() } } )
			Aadd( aButtons, { 2, .T., {|o| o:oWnd:End() } } )
			Aadd( aButtons, { 5, .T., {|| Pergunte("JL43IDE5 ",.T.) } } )

			FormBatch( cCadastro, aSays, aButtons )
		Else
			nOpca := 1
		EndIf

		If nOpca == 1
			If!Empty(cID)
				PA0->(dbSetOrder(1))
				If PA0->(MsSeek(xFilial("PA0") + PA0_ID))
					If !(PA0->PA0_STATUS $ "1|3|4")
						lRet := .F.
					EndIf
				EndIf
			EndIf

			IF lRet
				FWMsgRun(, {|oSay| ProcXMLCTe(cID,cErro,lCancel,cIdProc,cProcess,oSay) }, "Integração CT-e", "Integrando dados aguarde...")
			EndIf
		EndIf

	EndIf

	RestArea(aArea)

Return

/*/{Protheus.doc} nomeFunction
	(long_description)
	@type  Function
	@author user
	@since 15/12/2022
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	/*/

Static Function ProcXMLCTe(cID,cErro,lCancel,cIdProc,cProcess,oSay)

	Local lRet     	:= .T.
	Local cQry     	:= ''
	Local cMsgErr  	:= ''
	Local aAreas   	:= { SM0->(GetArea()), GetArea() }
	Local aMsgErr  	:= {}
	Local aCgcEmp  	:= {}
	Local cChave   	:= ''	// MH - 24/03/2022
	Local aRecDTC  	:= {}
	Local lExist	:= .F.
	Local cOrigem	:= ""

//-- Cancelamento CTe
	Local aDelDocto	:= {}
	Local lEnd     	:= .F.
	Local lDocto   	:= .F.
	Local cLotEst  	:= ""

	Local nMaxRegJob := SuperGetMv("ES_NREG001",,1000) //-- Nro máximo  de registros processados quando chamado via Job

	Private cStaLog := '3'
	Private cCFOP  	:= ""
	Private aLogImp	:= {}
	Private cRetPrc	:= ""
	Private cRetorno:= ''
	Private cSerie	:= ''
	Private cDoc    := ''

	Default cID    	:= ''
	Default cErro  	:= ''
	Default lCancel	:= .F.
	Default cIdProc	:= ''		// MH 24/03/2022

	//-- Seleciona a Tabela PA0 para o INT001
	cQry   += " SELECT TOP "+ Str(nMaxRegJob) + " R_E_C_N_O_ RECPA0, PA0_CHAVE, PA0_ORIGEM, PA0_NFEID, PA0_CGCREM, PA0_CGCEMI "
	cQry   += "   FROM " + RetSqlName("PA0") + " PA0 (NOLOCK) "
	cQry   += "  WHERE PA0.D_E_L_E_T_ = ' ' "
	cQry   += "    AND PA0_FILIAL = '" + xFilial("PA0") + "' "

	If Empty(cID)
		If IsBlind()
			cQry   += "    AND PA0_STATUS ='1' " //-- Somente em aberto
		Else
			If MV_PAR01 == 1
				cQry   += "    AND PA0_STATUS = '1' " //-- Somente em aberto
			ElseIf MV_PAR01 == 3
				cQry   += "    AND PA0_STATUS = '3' " //-- Processado com erro
			EndIf
		EndIf
	Else
		cQry += "  AND PA0_ID     = '" + cID + "' "
		cQry += "  AND PA0_STATUS IN ('1','3','5') " //-- Somente em aberto
	EndIf

	cQry   := ChangeQuery(cQry)

	If Select("QRYPOS01") > 0
		QRYPOS01->(dbCloseArea())
	EndIf

	TCQUERY cQry NEW Alias "QRYPOS01"

	QRYPOS01->(DbGoTop())

	While QRYPOS01->(!Eof())

		PA0->(dbGoTo(QRYPOS01->RECPA0))
		aLogImp := {}

		//Incrementa a mensagem na régua
		If !IsBlind()
			oSay:SetText("CT-e Chave " + PA0->PA0_CHAVE + "...")
			ProcessMessage()
		EndIf

		If LockByName(QRYPOS01->PA0_ORIGEM + AllTrim(cEmpAnt) + "_"+AllTrim(AllToChar(QRYPOS01->RECPA0)))

			DE5->(DbSetOrder(5))    // DE5_FILIAL, DE5_NFEID
			If !DE5->(MsSeek(xFilial("DE5") + PadR(QRYPOS01->PA0_NFEID, Len(DE5->DE5_NFEID)) ) )
				//-- Jah muda o status para erro para o caso de erro com advpl, banco
				RecLock("PA0",.F.)
				PA0->PA0_STATUS := '5'
				MsUnLock()

				lRet    := .T.
				cChave  := ""
				cRetPrc := ""
				cErro	:= ""
				cMsgErr := ''
				aMsgErr := {}
				cStaLog := '3'
				aCgcEmp := {}
				cRetorno:= ""
				aRecDTC := {}
				cDoc	:= ''
				cSerie	:= ''
				lExist	:= .F.
				cCFOP	:= ""

				aDelDocto:= {}
				lEnd     := .F.
				lDocto   := .F.
				cLotEst  := ""
				cRet     := ""
				cMsgErr  := ""
				cXmlDoc	 := ""
				aMsgErr  := {}

				cCGCFil	 := PA0->PA0_CGCEMI
				cChvDoc	 := PA0->PA0_CHAVE

				If lRet
					cXmlDoc := PA0->PA0_MSGARQ
					If Alltrim(PA0->PA0_ORIGEM) $ 'INT001'
						lRet := u_ImpXML_CTE(cXmlDoc,aMsgErr,@cOrigem)
					EndIf
				EndIf

			Else
				cIdProc	:= U_JLRetID(cProcess, cChave )
				cRetorno := "Id processamento: " + cIdProc
				cRetPrc	 := "NF já importada: " + QRYPOS01->PA0_CGCREM + "/" + QRYPOS01->PA0_NFEID        //"NF/DOC já utilizado no DOC: " + DTC->DTC_FILDOC + '-' + DTC->DTC_DOC + '-' + DTC->DTC_SERIE
				AADD(aLogImp,{PA0->PA0_ID,Date(),Time(),"JL43IDE5",cRetorno,'','','',cRetPrc})
				cRetorno := ""
			EndIf
		EndIf

		//-- Libera Trava/Lock
		UnLockByName(QRYPOS01->PA0_ORIGEM + AllTrim(cEmpAnt) + "_"+AllTrim(AllToChar(QRYPOS01->RECPA0)))

		RecLock("PA0",.F.)
		PA0->PA0_STATUS := cStaLog
		MsUnLock()

		u_JLGrvLog(aLogImp)

		//EndIf
		QRYPOS01->(DbSkip())
	EndDo

	QRYPOS01->(DbCloseArea())

	Aeval(aAreas,{ | e | RestArea(e)})

Return lRet

/*/{Protheus.doc} INT001
Importação CT-e
@author DLeme
@type User function
@since Dez/2021
@version 1.0
/*/

User Function ImpXML_CTE(cXMLOri,aMsgErr,cOrigem)

	Local cXML      := ""
	Local cError    := ""
	Local cWarning  := ""
	Local lFound    := .F.
	Local lProces   := .T.
	Local nX		:= 0
	Local cStrXML	:= ""
	Local aItContrat:= {}
	Local aDadosSA1 := {}
	Local lCgc 		:= .T.
	Local cCodMun 	:= ""
	Local cEst 		:= ""
	Local aErro 	:= {}
	Local cCGCRem 	:= ""
	Local cCGCDes 	:= ""
	Local cCGCEmi  	:= ""
	Local cCGCRec   := ""
	Local cCGCExp   := ""
	Local cCGCCon   := ""
	Local cCGCDev	:= ""
	Local cErro 	:= ""
	Local aHeadDE5 	:= {}
	Local aColsDE5 	:= {}
	Local aItemDE5	:= {}
	Local cLotEDI	:= ""
	Local nPesoL	:= 0
	Local lINSCEDI	:= SuperGetMv( "MV_INSCEDI", .F., .F. )
	Local lTM050NF  := SuperGetMv('MV_TM050NF',,.T.)
	Local lDE5PesLiq:= DE5->(ColumnPos("DE5_PESLIQ")) > 0
	Local lDE5_IDESTR := DE5->(ColumnPos('DE5_IDESTR')) > 0

	Private oFullXML
	Private oAuxXML
	Private oXML
	Private cCliGen := SuperGetMv('MV_CLIGEN',,'')
	Private cCliRem := ''
	Private cLojRem := ''
	Private dDatEmi := ''
	Private cDevFre := ''
	Private cTpServ := ''
	Private cChvNFe := ''
	Private cChvCTe := ''
	Private cCdrOri := ''
	Private cCdrDes := ''
	Private cMunIni := ''
	Private cUfIni  := ''
	Private cMunFim := ''
	Private cUfFim  := ''
	Private cTomSrv := ''
	Private cCodPro := SuperGetMv('ES_PRODINT',,'')
	Private cProGen	:= SuperGetMV('MV_PROGEN',.F.,"")
	Private cCodEmb := ''
	Private nValMer := 0
	Private nPeso   := 0
	Private nQtdVol := 0
	Private nValFre := 0
	Private nValImp := 0
	Private nValBC  := 0
	Private nValTot := 0
	Private nAlqICMS:= 0
	Private cCodPas := ''
	Private cTabFre := ''
	Private cTipTab := ''
	Private cServic := ''
	Private cTipFre := ''
	Private cSerTms := '3'
	Private cTipTra := '1'
	Private lCompl	:= .F.
	Private aDocOri := {}
	Private cCodNeg := SuperGetMv("ES_CODNEG",,"01")
	Private cNumNFC := ''
	Private cSerNFC := ''
	Private cSelOri	:= '2'
	Private xObs	:= ""
	Private cSativ1 := SuperGetMv("ES_SATIV1",,"000069")
	Private cTpCTe	:= '2'//'0'

	Private oICMS
	Private cTagICMS:= ""
	Private cTagCST	:= ""
	Private cCST	:= ""
	Private cTES	:= ""

	Default aMsgErr  := {}

	If !Empty(cXMLOri)
		If SubStr(cXMLOri,1,1) != "<"
			nPosPesq := At("<",cXMLOri)
			cXMLOri  := SubStr(cXMLOri,nPosPesq,Len(cXMLOri))		// Remove caracteres estranhos antes da abertura da tag inicial do arquivo
			cXMLOri  := NoAcentoCTe(cXMLOri)
		EndIf
	EndIf

	cXML := cXMLOri

	// Verifica se o encode ocorreu com sucesso, pois alguns caracteres especiais provocam erro na funcao de encode,
	// neste caso e feito o tratamento pela funcao A140IRemASC
	If Empty(cXML)
		cStrXML := cXMLOri
		cXMLOri := A140IRemASC(cStrXML)
		cXML    := EncodeUtf8(cXMLOri)
		If Empty(cXML)
			lProces := .F.
		EndIf
	EndIf
	If Empty(cXML)
		cXML := cXMLOri
	EndIf

	//-- So processa conhecimentos de transporte
	If !("</CTE>" $ Upper(cXML))
		lProces := .F.
	EndIf

	If lProces
		oFullXML := XmlParser(cXML,"_",@cError,@cWarning)

		//-- Erro na sintaxe do XML
		If Empty(oFullXML) .Or. !Empty(cError)
			AAdd(aMsgErr,{'Erro de sintaxe no arquivo XML: ' + cError,'00',''})
			lProces := .F.
		Else
			oXML    := oFullXML
			oAuxXML := oXML
			While !lFound
				oAuxXML := XmlChildEx(oAuxXML,"_CTE")
				If !(lFound := oAuxXML # NIL)
					For nX := 1 To XmlChildCount(oXML)
						oAuxXML  := XmlChildEx(XmlGetchild(oXML,nX),"_CTE")
						lFound := oAuxXML:_INFCTE# Nil
						If lFound
							oXML := oAuxXML
							Exit
						EndIf
					Next nX
				EndIf
				If lFound
					oXML := oAuxXML
					Exit
				EndIf
			EndDo

			oAuxXml := XmlChildEx(oXml,"_INFCTE")

			If lProces
				aDocOri := {}

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Tomador Serviço        ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If ValType(XmlChildEx(oAuxXml:_IDE,"_TOMA4")) == "O"
					cCGCTom:= oAuxXml:_IDE:_TOMA4:_CNPJ:TEXT
				ElseIf ValType(XmlChildEx(oAuxXml:_IDE,"_TOMA3")) == "O"
					cToma03 := oXML:_INFCTE:_IDE:_TOMA3:_TOMA:TEXT
				EndIf

				cOrigem := "CRMA980"

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Emitente   			   ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

				If Type("oFullXML:_CTEPROC:_CTE:_INFCTE:_EMIT") <> "U"

					If XmlChildEx(oAuxXml:_EMIT,"_CNPJ") # NIL
						cCGCEmi := oAuxXml:_EMIT:_CNPJ:TEXT
						lCgc := .T.
					Else
						cCGCEmi := oAuxXml:_EMIT:_CPF:TEXT
						lCgc := .F.
					EndIf

					SA1->(dbSetOrder(3))
					If SA1->(!dbSeek(xFilial('SA1') + cCGCEmi))
						aErro     := {}
						aDadosSA1 := {}
						Aadd(aDadosSA1, {"A1_FILIAL" , xFilial("SA1"), Nil } )
						Aadd(aDadosSA1, {"A1_COD"	 , "" , Nil } )
						Aadd(aDadosSA1, {"A1_LOJA"	 , "" , Nil } )
						Aadd(aDadosSA1, {"A1_TIPO"	 , "F" , Nil } )
						Aadd(aDadosSA1, {"A1_NOME"	 , Upper(NoAcentoCTe(NoAcento(AllTrim(oAuxXml:_EMIT:_XNOME:TEXT)))) , Nil } )
						Aadd(aDadosSA1, {"A1_NREDUZ" , Upper(NoAcentoCTe(NoAcento(SubStr(AllTrim(oAuxXml:_EMIT:_XNOME:TEXT),1,20)))) , Nil } )
						Aadd(aDadosSA1, {"A1_END"	 , Upper(NoAcento(AllTrim(oAuxXml:_EMIT:_ENDEREMIT:_XLGR:TEXT))) + ', ' + AllTrim(oAuxXml:_EMIT:_ENDEREMIT:_NRO:TEXT), Nil})
						Aadd(aDadosSA1, {"A1_EST"	 , oAuxXml:_EMIT:_ENDEREMIT:_UF:TEXT , Nil } )
						Aadd(aDadosSA1, {"A1_COD_MUN", SubStr(AllTrim(oAuxXml:_EMIT:_ENDEREMIT:_CMUN:TEXT),3,5) , Nil } )
						Aadd(aDadosSA1, {"A1_MUN"	 , Upper(NoAcento(AllTrim(oAuxXml:_EMIT:_ENDEREMIT:_XMUN:TEXT))) , Nil } )
						Aadd(aDadosSA1, {"A1_BAIRRO" , AllTrim(UPPER(oAuxXml:_EMIT:_ENDEREMIT:_XBAIRRO:TEXT)) , Nil } )

						If XmlChildEx(oAuxXml:_EMIT:_ENDEREMIT,'_CEP') <> Nil
							Aadd(aDadosSA1, {"A1_CEP", AllTrim(oAuxXml:_EMIT:_ENDEREMIT:_CEP:TEXT) , Nil } )
						EndIf

						If Type("oAuxXml:_REM:_FONE") <> "U"
							Aadd(aDadosSA1, {"A1_DDD", '0' + SubStr(AllTrim(oAuxXml:_EMIT:_FONE:TEXT),1,2) , Nil } )
							Aadd(aDadosSA1, {"A1_TEL", SubStr(AllTrim(oAuxXml:_EMIT:_FONE:TEXT),3,9) , Nil } )
						EndIf

						cCodMun := SubStr(AllTrim(oAuxXml:_EMIT:_ENDEREMIT:_CMUN:TEXT),3,5)
						cEst	:= oAuxXml:_EMIT:_ENDEREMIT:_UF:TEXT

						Aadd(aDadosSA1, {"A1_NATUREZ", SuperGetMV("MV_NATFAT",,"1000001") , Nil } )
						Aadd(aDadosSA1, {"A1_CDRDES", Posicione("DUY",6,xFilial("DUY") + cEst + cCodMun,"DUY_GRPVEN") , Nil } )
						Aadd(aDadosSA1, {"A1_PAIS", "105" , Nil } )
						Aadd(aDadosSA1, {"A1_CODPAIS", "01058" , Nil } )
						Aadd(aDadosSA1, {"A1_RISCO", "A" , Nil } )
						Aadd(aDadosSA1, {"A1_SATIV1", cSativ1 , Nil } )

						If lCGC //--Se for pessoa juridica
							Aadd(aDadosSA1, {"A1_PESSOA", "J" , Nil } )
							Aadd(aDadosSA1, {"A1_CGC", AllTrim(oAuxXml:_EMIT:_CNPJ:TEXT) , Nil } )

							// 2022-07-13 - MH - Validação da TAG _IE para não gerar error.log qunado não enviada no XML
							If XmlChildEx(oAuxXml:_EMIT,'_IE') <> Nil
								Aadd(aDadosSA1, {"A1_INSCR", AllTrim(oAuxXml:_EMIT:_IE:TEXT) , Nil } )
								Aadd(aDadosSA1, {"A1_CONTRIB", "1" , Nil } )
							Else
								Aadd(aDadosSA1, {"A1_INSCR", "ISENTO" , Nil } )
								Aadd(aDadosSA1, {"A1_CONTRIB", "2" , Nil } )
							EndIf

						Else
							Aadd(aDadosSA1, {"A1_PESSOA", "F" , Nil } )
							Aadd(aDadosSA1, {"A1_CGC", AllTrim(oAuxXml:_EMIT:_CPF:TEXT) , Nil } )
							Aadd(aDadosSA1, {"A1_INSCR", "ISENTO" , Nil } )
							Aadd(aDadosSA1, {"A1_CONTRIB", "2" , Nil } )
						EndIf

						U_JLCadCli(aDadosSA1,@aErro)

						If Len(aErro) > 0
							AAdd(aMsgErr,{'Erro ao incluir cliente remetente: ' + cCGCEmi,'00',''})
							aEval(aErro,{|e| Aadd(aMsgErr,{ e, '00', '' } ) })

							AEval(aMsgErr,{|x| cErro += x[1] + CRLF })
							cRetorno := cErro

							lProces := .F.
						Else	
							cRetorno := "Inclusão cliente remetente " +  cCGCEmi + ' - ' + SA1->A1_NOME
						EndIf

						AADD(aLogImp,{PA0->PA0_ID,Date(),Time(),cOrigem,cRetorno,'','','',cRetPrc})
						cRetorno := ""

					EndIf
					cIEEmi  := SA1->A1_INSCR
					//cTpCTe	:= SA1->A1_TPCTEIM
				EndIf

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Remetente  			   ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If Type("oFullXML:_CTEPROC:_CTE:_INFCTE:_REM") <> "U"

					If XmlChildEx(oAuxXml:_REM,"_CNPJ") # NIL
						cCGCRem := oAuxXml:_REM:_CNPJ:TEXT
						lCgc := .T.
					Else
						cCGCRem := oAuxXml:_REM:_CPF:TEXT
						lCgc := .F.
					EndIf

					SA1->(dbSetOrder(3))
					If SA1->(!dbSeek(xFilial('SA1')+cCGCRem))
						aErro     := {}
						aDadosSA1 := {}
						Aadd(aDadosSA1, {"A1_FILIAL" , xFilial("SA1"), Nil } )
						Aadd(aDadosSA1, {"A1_COD"	 , "" , Nil } )
						Aadd(aDadosSA1, {"A1_LOJA"	 , "" , Nil } )
						Aadd(aDadosSA1, {"A1_TIPO"	 , "F" , Nil } )
						Aadd(aDadosSA1, {"A1_NOME"	 , Upper(NoAcentoCTe(NoAcento(AllTrim(oAuxXml:_REM:_XNOME:TEXT)))) , Nil } )
						Aadd(aDadosSA1, {"A1_NREDUZ" , Upper(NoAcentoCTe(NoAcento(SubStr(AllTrim(oAuxXml:_REM:_XNOME:TEXT),1,20)))) , Nil } )
						Aadd(aDadosSA1, {"A1_END"	 , Upper(NoAcento(AllTrim(oAuxXml:_REM:_ENDERREME:_XLGR:TEXT))) + ', ' + AllTrim(oAuxXml:_REM:_ENDERREME:_NRO:TEXT) , Nil } )
						Aadd(aDadosSA1, {"A1_EST"	 , oAuxXml:_REM:_ENDERREME:_UF:TEXT , Nil } )
						Aadd(aDadosSA1, {"A1_COD_MUN", SubStr(AllTrim(oAuxXml:_REM:_ENDERREME:_CMUN:TEXT),3,5) , Nil } )
						Aadd(aDadosSA1, {"A1_MUN"	 , Upper(NoAcento(AllTrim(oAuxXml:_REM:_ENDERREME:_XMUN:TEXT))) , Nil } )
						Aadd(aDadosSA1, {"A1_BAIRRO" , AllTrim(UPPER(oAuxXml:_REM:_ENDERREME:_XBAIRRO:TEXT)) , Nil } )

						If XmlChildEx(oAuxXml:_REM:_ENDERREME,'_CEP') <> Nil
							Aadd(aDadosSA1, {"A1_CEP", AllTrim(oAuxXml:_REM:_ENDERREME:_CEP:TEXT) , Nil } )
						EndIf

						If Type("oAuxXml:_REM:_FONE") <> "U"
							Aadd(aDadosSA1, {"A1_DDD", '0' + SubStr(AllTrim(oAuxXml:_REM:_FONE:TEXT),1,2) , Nil } )
							Aadd(aDadosSA1, {"A1_TEL", SubStr(AllTrim(oAuxXml:_REM:_FONE:TEXT),3,9) , Nil } )
						EndIf

						cCodMun := SubStr(AllTrim(oAuxXml:_REM:_ENDERREME:_CMUN:TEXT),3,5)
						cEst	:= oAuxXml:_REM:_ENDERREME:_UF:TEXT

						Aadd(aDadosSA1, {"A1_NATUREZ", SuperGetMV("MV_NATFAT",,"1000001") , Nil } )
						Aadd(aDadosSA1, {"A1_CDRDES", Posicione("DUY",6,xFilial("DUY") + cEst + cCodMun,"DUY_GRPVEN") , Nil } )
						Aadd(aDadosSA1, {"A1_PAIS", "105" , Nil } )
						Aadd(aDadosSA1, {"A1_CODPAIS", "01058" , Nil } )
						Aadd(aDadosSA1, {"A1_RISCO", "A" , Nil } )
						Aadd(aDadosSA1, {"A1_SATIV1", cSativ1 , Nil } )

						If lCGC //--Se for pessoa juridica
							Aadd(aDadosSA1, {"A1_PESSOA", "J" , Nil } )
							Aadd(aDadosSA1, {"A1_CGC", AllTrim(oAuxXml:_REM:_CNPJ:TEXT) , Nil } )

							// 2022-07-13 - MH - Validação da TAG _IE para não gerar error.log qunado não enviada no XML
							If XmlChildEx(oAuxXml:_REM,'_IE') <> Nil
								Aadd(aDadosSA1, {"A1_INSCR", AllTrim(oAuxXml:_REM:_IE:TEXT) , Nil } )
								Aadd(aDadosSA1, {"A1_CONTRIB", "1" , Nil } )
							Else
								Aadd(aDadosSA1, {"A1_INSCR", "ISENTO" , Nil } )
								Aadd(aDadosSA1, {"A1_CONTRIB", "2" , Nil } )
							EndIf

						Else
							Aadd(aDadosSA1, {"A1_PESSOA", "F" , Nil } )
							Aadd(aDadosSA1, {"A1_CGC", AllTrim(oAuxXml:_REM:_CPF:TEXT) , Nil } )
							Aadd(aDadosSA1, {"A1_INSCR", "ISENTO" , Nil } )
							Aadd(aDadosSA1, {"A1_CONTRIB", "2" , Nil } )
						EndIf

						U_JLCadCli(aDadosSA1,@aErro)

						If Len(aErro) > 0
							AAdd(aMsgErr,{'Erro ao incluir cliente remetente: ' + cCGCRem,'00',''})
							aEval(aErro,{|e| Aadd(aMsgErr,{ e, '00', '' } ) })

							AEval(aMsgErr,{|x| cErro += x[1] + CRLF })
							cRetorno := cErro

							lProces := .F.
						Else
							cRetorno := "Inclusão cliente remetente " + Transform(AllTrim(cCGCRem), "@r 99.999.999/9999-99") + ' - ' + SA1->A1_NOME
						EndIf

						AADD(aLogImp,{PA0->PA0_ID,Date(),Time(),cOrigem,cRetorno,'','','',cRetPrc})
						cRetorno := ""

					EndIf

					cCliRem := SA1->A1_COD
					cLojRem := SA1->A1_LOJA
					cIERem  := SA1->A1_INSCR
				EndIf

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Destinatario			   ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If Type("oFullXML:_CTEPROC:_CTE:_INFCTE:_DEST") <> "U"

					If XmlChildEx(oAuxXml:_DEST,"_CNPJ") # NIL
						cCGCDes := oAuxXml:_DEST:_CNPJ:TEXT
						lCgc := .T.
					Else
						cCGCDes := oAuxXml:_DEST:_CPF:TEXT
						lCgc := .F.
					EndIf

					If SA1->(!dbSeek(xFilial('SA1') + cCGCDes))

						aErro     := {}
						aDadosSA1 := {}

						Aadd(aDadosSA1, {"A1_FILIAL"	, xFilial("SA1"), Nil } )
						Aadd(aDadosSA1, {"A1_COD"		, "" , Nil } )
						Aadd(aDadosSA1, {"A1_LOJA"		, "" , Nil } )
						Aadd(aDadosSA1, {"A1_TIPO"		, "F" , Nil } )
						Aadd(aDadosSA1, {"A1_NOME"		, AllTrim(UPPER(NoAcentoCTe(oFullXML:_CTEPROC:_CTE:_INFCTE:_DEST:_XNOME:TEXT))) , Nil } )
						Aadd(aDadosSA1, {"A1_NREDUZ"	, SubStr(AllTrim(UPPER(NoAcentoCTe(oFullXML:_CTEPROC:_CTE:_INFCTE:_DEST:_XNOME:TEXT))),1,20) , Nil } )
						Aadd(aDadosSA1, {"A1_END"		, AllTrim(UPPER(oFullXML:_CTEPROC:_CTE:_INFCTE:_DEST:_ENDERDEST:_XLGR:TEXT)) + ', ' + AllTrim(UPPER(oFullXML:_CTEPROC:_CTE:_INFCTE:_DEST:_ENDERDEST:_NRO:TEXT)) , Nil } )
						Aadd(aDadosSA1, {"A1_EST"		, oFullXML:_CTEPROC:_CTE:_INFCTE:_DEST:_ENDERDEST:_UF:TEXT , Nil } )
						Aadd(aDadosSA1, {"A1_COD_MUN"	, SubStr(AllTrim(oFullXML:_CTEPROC:_CTE:_INFCTE:_DEST:_ENDERDEST:_CMUN:TEXT),3,5) , Nil } )
						Aadd(aDadosSA1, {"A1_MUN"		, AllTrim(oFullXML:_CTEPROC:_CTE:_INFCTE:_DEST:_ENDERDEST:_XMUN:TEXT) , Nil } )
						Aadd(aDadosSA1, {"A1_BAIRRO"	, AllTrim(UPPER(oFullXML:_CTEPROC:_CTE:_INFCTE:_DEST:_ENDERDEST:_XBAIRRO:TEXT)) , Nil } )

						If XmlChildEx(oFullXML:_CTEPROC:_CTE:_INFCTE:_DEST:_ENDERDEST,'_CEP') <> Nil
							Aadd(aDadosSA1, {"A1_CEP"	, AllTrim(oFullXML:_CTEPROC:_CTE:_INFCTE:_DEST:_ENDERDEST:_CEP:TEXT) , Nil } )
						EndIf

						If Type("oFullXML:_CTEPROC:_CTE:_INFCTE:_DEST:_FONE") <> "U"
							Aadd(aDadosSA1, {"A1_DDD"	, '0' + SubStr(AllTrim(oFullXML:_CTEPROC:_CTE:_INFCTE:_DEST:_FONE:TEXT),1,2) , Nil } )
							Aadd(aDadosSA1, {"A1_TEL"	, SubStr(AllTrim(oFullXML:_CTEPROC:_CTE:_INFCTE:_DEST:_FONE:TEXT),3,9) , Nil } )
						EndIf	

						cCodMun := SubStr(AllTrim(oFullXML:_CTEPROC:_CTE:_INFCTE:_DEST:_ENDERDEST:_CMUN:TEXT),3,5)
						cEst		:= oFullXML:_CTEPROC:_CTE:_INFCTE:_DEST:_ENDERDEST:_UF:TEXT

						Aadd(aDadosSA1, {"A1_NATUREZ"	, SuperGetMV("MV_NATFAT",,"1000001") , Nil } )
						Aadd(aDadosSA1, {"A1_CDRDES"	, Posicione("DUY",6,xFilial("DUY") + cEst + cCodMun,"DUY_GRPVEN") , Nil } )
						Aadd(aDadosSA1, {"A1_PAIS"		, "105" , Nil } )
						Aadd(aDadosSA1, {"A1_CODPAIS"	, "01058" , Nil } )
						Aadd(aDadosSA1, {"A1_RISCO"		, "A" , Nil } )
						Aadd(aDadosSA1, {"A1_SATIV1"	, cSativ1 , Nil } )

						If lCGC //--Se for pessoa juridica
							Aadd(aDadosSA1, {"A1_PESSOA", "J" , Nil } )
							Aadd(aDadosSA1, {"A1_CGC"	, AllTrim(oFullXML:_CTEPROC:_CTE:_INFCTE:_DEST:_CNPJ:TEXT) , Nil } )

							// 2022-07-13 - MH - Validação da TAG _IE para não gerar error.log qunado não enviada no XML
							If XmlChildEx(oFullXML:_CTEPROC:_CTE:_INFCTE:_DEST,'_IE') <> Nil
								Aadd(aDadosSA1, {"A1_INSCR"		, AllTrim(oFullXML:_CTEPROC:_CTE:_INFCTE:_DEST:_IE:TEXT) , Nil } )
								Aadd(aDadosSA1, {"A1_CONTRIB"	, "1" , Nil } )
							Else
								Aadd(aDadosSA1, {"A1_INSCR", "ISENTO" , Nil } )
								Aadd(aDadosSA1, {"A1_CONTRIB", "2" , Nil } )
							EndIf
						Else
							Aadd(aDadosSA1, {"A1_PESSOA", "F" , Nil } )
							Aadd(aDadosSA1, {"A1_CGC", AllTrim(oFullXML:_CTEPROC:_CTE:_INFCTE:_DEST:_CPF:TEXT) , Nil } )
							Aadd(aDadosSA1, {"A1_INSCR", "ISENTO" , Nil } )
							Aadd(aDadosSA1, {"A1_CONTRIB", "2" , Nil } )
						EndIf

						U_JLCadCli(aDadosSA1,@aErro)

						If Len(aErro) > 0
							AAdd(aMsgErr,{'Erro ao incluir cliente destinatário: ' + cCGCDes,'00',''})
							aEval(aErro,{|e| Aadd(aMsgErr,{ e,'00','' }) })

							AEval(aMsgErr,{|x| cErro += x[1] + CRLF })
							cRetorno := cErro

							lProces := .F.
						Else
							cRetorno := "Inclusão cliente destinatário " + Transform(AllTrim(cCGCDes), "@r 99.999.999/9999-99") + ' / ' + SA1->A1_NOME
						EndIf

						AADD(aLogImp,{PA0->PA0_ID,Date(),Time(),cOrigem,cRetorno,'','','',cRetPrc})
						cRetorno := ""

					EndIf
					cIEDES  := SA1->A1_INSCR
				EndIf

				// Expedidor
				If Type("oFullXML:_CTEPROC:_CTE:_INFCTE:_EXPED") <> "U"

					If XmlChildEx(oAuxXml:_EXPED,"_CNPJ") # NIL
						cCGCExp := oAuxXml:_EXPED:_CNPJ:TEXT
						lCgc := .T.
					Else
						cCGCExp := oAuxXml:_EXPED:_CPF:TEXT
						lCgc := .F.
					EndIf

					If SA1->(!dbSeek(xFilial('SA1') + cCGCExp))
						aErro     := {}
						aDadosSA1 := {}
						Aadd(aDadosSA1, {"A1_FILIAL"    , xFilial("SA1"), Nil } )
						Aadd(aDadosSA1, {"A1_COD"	    , "" , Nil } )
						Aadd(aDadosSA1, {"A1_LOJA"	    , "" , Nil } )
						Aadd(aDadosSA1, {"A1_TIPO"	    , "F" , Nil } )
						Aadd(aDadosSA1, {"A1_NOME"	    , AllTrim(UPPER(NoAcentoCTe(oFullXML:_CTEPROC:_CTE:_INFCTE:_EXPED:_XNOME:TEXT))) , Nil } )
						Aadd(aDadosSA1, {"A1_NREDUZ"    , SubStr(AllTrim(UPPER(NoAcentoCTe(oFullXML:_CTEPROC:_CTE:_INFCTE:_EXPED:_XNOME:TEXT))),1,20) , Nil } )
						Aadd(aDadosSA1, {"A1_END"       , AllTrim(UPPER(oFullXML:_CTEPROC:_CTE:_INFCTE:_EXPED:_ENDEREXPED:_XLGR:TEXT)) + ', ' + AllTrim(UPPER(oFullXML:_CTEPROC:_CTE:_INFCTE:_EXPED:_ENDEREXPED:_NRO:TEXT)) , Nil } )
						Aadd(aDadosSA1, {"A1_EST"       , oFullXML:_CTEPROC:_CTE:_INFCTE:_EXPED:_ENDEREXPED:_UF:TEXT , Nil } )
						Aadd(aDadosSA1, {"A1_COD_MUN"   , SubStr(AllTrim(oFullXML:_CTEPROC:_CTE:_INFCTE:_EXPED:_ENDEREXPED:_CMUN:TEXT),3,5) , Nil } )
						Aadd(aDadosSA1, {"A1_MUN"       , AllTrim(oFullXML:_CTEPROC:_CTE:_INFCTE:_EXPED:_ENDEREXPED:_XMUN:TEXT) , Nil } )
						Aadd(aDadosSA1, {"A1_BAIRRO"    , AllTrim(UPPER(oFullXML:_CTEPROC:_CTE:_INFCTE:_EXPED:_ENDEREXPED:_XBAIRRO:TEXT)) , Nil } )

						If XmlChildEx(oFullXML:_CTEPROC:_CTE:_INFCTE:_EXPED:_ENDEREXPED,'_CEP') <> Nil
							Aadd(aDadosSA1, {"A1_CEP"   , AllTrim(oFullXML:_CTEPROC:_CTE:_INFCTE:_EXPED:_ENDEREXPED:_CEP:TEXT) , Nil } )
						EndIf

						If Type("oFullXML:_CTEPROC:_CTE:_INFCTE:_EXPED:_FONE") <> "U"
							Aadd(aDadosSA1, {"A1_DDD"   , '0' + SubStr(AllTrim(oFullXML:_CTEPROC:_CTE:_INFCTE:_EXPED:_FONE:TEXT),1,2) , Nil } )
							Aadd(aDadosSA1, {"A1_TEL"   , SubStr(AllTrim(oFullXML:_CTEPROC:_CTE:_INFCTE:_EXPED:_FONE:TEXT),3,9) , Nil } )
						EndIf

						cCodMun := SubStr(AllTrim(oFullXML:_CTEPROC:_CTE:_INFCTE:_EXPED:_ENDEREXPED:_CMUN:TEXT),3,5)
						cEst		:= oFullXML:_CTEPROC:_CTE:_INFCTE:_EXPED:_ENDEREXPED:_UF:TEXT

						Aadd(aDadosSA1, {"A1_NATUREZ", SuperGetMV("MV_NATFAT",,"1000001") , Nil } )
						Aadd(aDadosSA1, {"A1_CDRDES", Posicione("DUY",6,xFilial("DUY")+cEst+cCodMun,"DUY_GRPVEN") , Nil } )
						Aadd(aDadosSA1, {"A1_PAIS", "105" , Nil } )
						Aadd(aDadosSA1, {"A1_CODPAIS", "01058" , Nil } )
						Aadd(aDadosSA1, {"A1_RISCO", "A" , Nil } )
						Aadd(aDadosSA1, {"A1_SATIV1", cSativ1 , Nil } )

						If lCGC //--Se for pessoa juridica
							Aadd(aDadosSA1, {"A1_PESSOA", "J" , Nil } )
							Aadd(aDadosSA1, {"A1_CGC", AllTrim(oFullXML:_CTEPROC:_CTE:_INFCTE:_EXPED:_CNPJ:TEXT) , Nil } )

							// 2022-07-13 - MH - Validação da TAG _IE para não gerar error.log qunado não enviada no XML
							If XmlChildEx(oFullXML:_CTEPROC:_CTE:_INFCTE:_EXPED,'_IE') <> Nil
								Aadd(aDadosSA1, {"A1_INSCR", AllTrim(oFullXML:_CTEPROC:_CTE:_INFCTE:_EXPED:_IE:TEXT) , Nil } )
								Aadd(aDadosSA1, {"A1_CONTRIB", "1" , Nil } )
							Else
								Aadd(aDadosSA1, {"A1_INSCR", "ISENTO" , Nil } )
								Aadd(aDadosSA1, {"A1_CONTRIB", "2" , Nil } )
							EndIf
						Else
							Aadd(aDadosSA1, {"A1_PESSOA", "F" , Nil } )
							Aadd(aDadosSA1, {"A1_CGC", AllTrim(oFullXML:_CTEPROC:_CTE:_INFCTE:_EXPED:_CPF:TEXT) , Nil } )
							Aadd(aDadosSA1, {"A1_INSCR", "ISENTO" , Nil } )
							Aadd(aDadosSA1, {"A1_CONTRIB", "2" , Nil } )
						EndIf

						U_JLCadCli(aDadosSA1,@aErro)

						If Len(aErro) > 0
							AAdd(aMsgErr,{'Erro ao incluir cliente expedidor: '+cCGCExp,'00',''})
							aEval(aErro,{|e| Aadd(aMsgErr,{ e,'00','' }) })

							AEval(aMsgErr,{|x| cErro += x[1] + CRLF })
							cRetorno := cErro

							lProces := .F.
						Else
							cRetorno := "Inclusão cliente expedidor " + Transform(AllTrim(cCGCExp), "@r 99.999.999/9999-99") + ' - ' + SA1->A1_NOME

						EndIf

						AADD(aLogImp,{PA0->PA0_ID,Date(),Time(),cOrigem,cRetorno,'','','',cRetPrc})
						cRetorno := ""

					EndIf
					cIEExp  := SA1->A1_INSCR
				EndIf

				// Recebedor
				If Type("oFullXML:_CTEPROC:_CTE:_INFCTE:_RECEB") <> "U"

					If XmlChildEx(oAuxXml:_RECEB,"_CNPJ") # NIL
						cCGCRec := oAuxXml:_RECEB:_CNPJ:TEXT
						lCgc := .T.
					Else
						cCGCRec := oAuxXml:_RECEB:_CPF:TEXT
						lCgc := .F.
					EndIf

					//Rafael Moraes Rosa e Tiago Stocco - trecho elaborado para correcao paliativa - 20/04/2023
					cCGCRec := ""

					If SA1->(!dbSeek(xFilial('SA1') + cCGCRec))
						aErro     := {}
						aDadosSA1 := {}
						Aadd(aDadosSA1, {"A1_FILIAL"    , xFilial("SA1"), Nil } )
						Aadd(aDadosSA1, {"A1_COD"	    , "" , Nil } )
						Aadd(aDadosSA1, {"A1_LOJA"	    , "" , Nil } )
						Aadd(aDadosSA1, {"A1_TIPO"	    , "F" , Nil } )
						Aadd(aDadosSA1, {"A1_NOME"	    , AllTrim(UPPER(NoAcentoCTe(oFullXML:_CTEPROC:_CTE:_INFCTE:_RECEB:_XNOME:TEXT))) , Nil } )
						Aadd(aDadosSA1, {"A1_NREDUZ"    , SubStr(AllTrim(UPPER(NoAcentoCTe(oFullXML:_CTEPROC:_CTE:_INFCTE:_RECEB:_XNOME:TEXT))),1,20) , Nil } )
						Aadd(aDadosSA1, {"A1_END"       , AllTrim(UPPER(oFullXML:_CTEPROC:_CTE:_INFCTE:_RECEB:_ENDERRECEB:_XLGR:TEXT)) + ', ' + AllTrim(UPPER(oFullXML:_CTEPROC:_CTE:_INFCTE:_RECEB:_ENDERRECEB:_NRO:TEXT)) , Nil } )
						Aadd(aDadosSA1, {"A1_EST"       , oFullXML:_CTEPROC:_CTE:_INFCTE:_RECEB:_ENDERRECEB:_UF:TEXT , Nil } )
						Aadd(aDadosSA1, {"A1_COD_MUN"   , SubStr(AllTrim(oFullXML:_CTEPROC:_CTE:_INFCTE:_RECEB:_ENDERRECEB:_CMUN:TEXT),3,5) , Nil } )
						Aadd(aDadosSA1, {"A1_MUN"       , AllTrim(oFullXML:_CTEPROC:_CTE:_INFCTE:_RECEB:_ENDERRECEB:_XMUN:TEXT) , Nil } )
						Aadd(aDadosSA1, {"A1_BAIRRO"    , AllTrim(UPPER(oFullXML:_CTEPROC:_CTE:_INFCTE:_RECEB:_ENDERRECEB:_XBAIRRO:TEXT)) , Nil } )

						If XmlChildEx(oFullXML:_CTEPROC:_CTE:_INFCTE:_RECEB:_ENDERRECEB,'_CEP') <> Nil
							Aadd(aDadosSA1, {"A1_CEP"   , AllTrim(oFullXML:_CTEPROC:_CTE:_INFCTE:_RECEB:_ENDERRECEB:_CEP:TEXT) , Nil } )
						EndIf

						If XmlChildEx(oFullXML:_CTEPROC:_CTE:_INFCTE:_RECEB,'_FONE') <> Nil
							Aadd(aDadosSA1, {"A1_DDD"   , '0' + SubStr(AllTrim(oFullXML:_CTEPROC:_CTE:_INFCTE:_RECEB:_FONE:TEXT),1,2) , Nil } )
							Aadd(aDadosSA1, {"A1_TEL"   , SubStr(AllTrim(oFullXML:_CTEPROC:_CTE:_INFCTE:_RECEB:_FONE:TEXT),3,9) , Nil } )
						EndIf

						cCodMun := SubStr(AllTrim(oFullXML:_CTEPROC:_CTE:_INFCTE:_RECEB:_ENDERRECEB:_CMUN:TEXT),3,5)
						cEst		:= oFullXML:_CTEPROC:_CTE:_INFCTE:_RECEB:_ENDERRECEB:_UF:TEXT

						Aadd(aDadosSA1, {"A1_NATUREZ"   , SuperGetMV("MV_NATFAT",,"1000001") , Nil } )
						Aadd(aDadosSA1, {"A1_CDRDES"    , Posicione("DUY",6,xFilial("DUY")+cEst+cCodMun,"DUY_GRPVEN") , Nil } )
						Aadd(aDadosSA1, {"A1_PAIS"      , "105" , Nil } )
						Aadd(aDadosSA1, {"A1_CODPAIS"   , "01058" , Nil } )
						Aadd(aDadosSA1, {"A1_RISCO"     , "A" , Nil } )
						Aadd(aDadosSA1, {"A1_SATIV1"    , cSativ1 , Nil } )

						If lCGC //--Se for pessoa juridica
							Aadd(aDadosSA1, {"A1_PESSOA", "J" , Nil } )
							Aadd(aDadosSA1, {"A1_CGC", AllTrim(oFullXML:_CTEPROC:_CTE:_INFCTE:_RECEB:_CNPJ:TEXT) , Nil } )

							If XmlChildEx(oFullXML:_CTEPROC:_CTE:_INFCTE:_RECEB,'_IE') <> Nil
								Aadd(aDadosSA1, {"A1_INSCR", AllTrim(oFullXML:_CTEPROC:_CTE:_INFCTE:_RECEB:_IE:TEXT) , Nil } )
								Aadd(aDadosSA1, {"A1_CONTRIB", "1" , Nil } )
							Else
								Aadd(aDadosSA1, {"A1_INSCR", "ISENTO" , Nil } )
								Aadd(aDadosSA1, {"A1_CONTRIB", "2" , Nil } )
							EndIf
						Else
							Aadd(aDadosSA1, {"A1_PESSOA", "F" , Nil } )
							Aadd(aDadosSA1, {"A1_CGC", AllTrim(oFullXML:_CTEPROC:_CTE:_INFCTE:_RECEB:_CPF:TEXT) , Nil } )
							Aadd(aDadosSA1, {"A1_INSCR", "ISENTO" , Nil } )
							Aadd(aDadosSA1, {"A1_CONTRIB", "2" , Nil } )
						EndIf

						U_JLCadCli(aDadosSA1,@aErro)

						If Len(aErro) > 0
							AAdd(aMsgErr,{'Erro ao incluir cliente recebedor: '+cCGCRec,'00',''})
							aEval(aErro,{|e| Aadd(aMsgErr,{ e,'00','' }) })

							AEval(aMsgErr,{|x| cErro += x[1] + CRLF })
							cRetorno := cErro

							lProces := .F.
						Else
							cRetorno := "Inclusão cliente recebedor " + Transform(AllTrim(cCGCRec), "@r 99.999.999/9999-99") +  ' - ' + SA1->A1_NOME

						EndIf

						AADD(aLogImp,{PA0->PA0_ID,Date(),Time(),cOrigem,cRetorno,'','','',cRetPrc})
						cRetorno := ""

					EndIf

					cIERec  := SA1->A1_INSCR

				EndIf

				// Consignatario
				If Type("oFullXML:_CTEPROC:_CTE:_INFCTE:_IDE:_TOMA4") <> "U"

					If XmlChildEx(oAuxXml:_IDE:_TOMA4,"_CNPJ") # NIL
						cCGCCon := oAuxXml:_IDE:_TOMA4:_CNPJ:TEXT
						lCgc := .T.
					Else
						cCGCCon := oAuxXml:_IDE:_TOMA4:_CPF:TEXT
						lCgc := .F.
					EndIf

					If SA1->(!dbSeek(xFilial('SA1') + cCGCCon))

						aErro     := {}
						aDadosSA1 := {}

						Aadd(aDadosSA1, {"A1_FILIAL"    , xFilial("SA1"), Nil } )
						Aadd(aDadosSA1, {"A1_COD"	    , "" , Nil } )
						Aadd(aDadosSA1, {"A1_LOJA"	    , "" , Nil } )
						Aadd(aDadosSA1, {"A1_TIPO"	    , "F" , Nil } )
						Aadd(aDadosSA1, {"A1_NOME"	    , AllTrim(UPPER(NoAcentoCTe(oFullXML:_CTEPROC:_CTE:_INFCTE:_IDE:_TOMA4:_XNOME:TEXT))) , Nil } )
						Aadd(aDadosSA1, {"A1_NREDUZ"    , SubStr(AllTrim(UPPER(NoAcentoCTe(oFullXML:_CTEPROC:_CTE:_INFCTE:_IDE:_TOMA4:_XNOME:TEXT))),1,20) , Nil } )
						Aadd(aDadosSA1, {"A1_END"       , AllTrim(UPPER(oFullXML:_CTEPROC:_CTE:_INFCTE:_IDE:_TOMA4:_ENDERTOMA:_XLGR:TEXT)) + ', ' + AllTrim(UPPER(oFullXML:_CTEPROC:_CTE:_INFCTE:_IDE:_TOMA4:_ENDERTOMA:_NRO:TEXT)), Nil } )
						Aadd(aDadosSA1, {"A1_EST"       , oFullXML:_CTEPROC:_CTE:_INFCTE:_IDE:_TOMA4:_ENDERTOMA:_UF:TEXT , Nil } )
						Aadd(aDadosSA1, {"A1_COD_MUN"   , SubStr(AllTrim(oFullXML:_CTEPROC:_CTE:_INFCTE:_IDE:_TOMA4:_ENDERTOMA:_CMUN:TEXT),3,5) , Nil } )
						Aadd(aDadosSA1, {"A1_MUN"       , AllTrim(oFullXML:_CTEPROC:_CTE:_INFCTE:_IDE:_TOMA4:_ENDERTOMA:_XMUN:TEXT) , Nil } )
						Aadd(aDadosSA1, {"A1_BAIRRO"    , AllTrim(UPPER(oFullXML:_CTEPROC:_CTE:_INFCTE:_IDE:_TOMA4:_ENDERTOMA:_XBAIRRO:TEXT)) , Nil } )

						If XmlChildEx(oFullXML:_CTEPROC:_CTE:_INFCTE:_IDE:_TOMA4:_ENDERTOMA,'_CEP') <> Nil
							Aadd(aDadosSA1, {"A1_CEP"   , AllTrim(oFullXML:_CTEPROC:_CTE:_INFCTE:_IDE:_TOMA4:_ENDERTOMA:_CEP:TEXT) , Nil } )
						EndIf

						If Type("oFullXML:_CTEPROC:_CTE:_INFCTE:_TOMA4:_FONE") <> "U"
							Aadd(aDadosSA1, {"A1_DDD"   , '0' + SubStr(AllTrim(oFullXML:_CTEPROC:_CTE:_INFCTE:_IDE:_TOMA4:_FONE:TEXT),1,2) , Nil } )
							Aadd(aDadosSA1, {"A1_TEL"   , SubStr(AllTrim(oFullXML:_CTEPROC:_CTE:_INFCTE:_IDE:_TOMA4:_FONE:TEXT),3,9) , Nil } )
						EndIf

						cCodMun := SubStr(AllTrim(oFullXML:_CTEPROC:_CTE:_INFCTE:_IDE:_TOMA4:_ENDERTOMA:_CMUN:TEXT),3,5)
						cEst		:= oFullXML:_CTEPROC:_CTE:_INFCTE:_IDE:_TOMA4:_ENDERTOMA:_UF:TEXT

						Aadd(aDadosSA1, {"A1_NATUREZ"   , SuperGetMV("MV_NATFAT",,"1000001") , Nil } )
						Aadd(aDadosSA1, {"A1_CDRDES"    , Posicione("DUY",6,xFilial("DUY")+cEst+cCodMun,"DUY_GRPVEN") , Nil } )
						Aadd(aDadosSA1, {"A1_PAIS"      , "105" , Nil } )
						Aadd(aDadosSA1, {"A1_CODPAIS"   , "01058" , Nil } )
						Aadd(aDadosSA1, {"A1_RISCO"     , "A" , Nil } )
						Aadd(aDadosSA1, {"A1_SATIV1"    , cSativ1 , Nil } )

						If lCGC //--Se for pessoa juridica
							Aadd(aDadosSA1, {"A1_PESSOA", "J" , Nil } )
							Aadd(aDadosSA1, {"A1_CGC"   , AllTrim(oFullXML:_CTEPROC:_CTE:_INFCTE:_IDE:_TOMA4:_CNPJ:TEXT) , Nil } )

							If XmlChildEx(oFullXML:_CTEPROC:_CTE:_INFCTE:_IDE:_TOMA4,'_IE') <> Nil
								Aadd(aDadosSA1, {"A1_INSCR"     , AllTrim(oFullXML:_CTEPROC:_CTE:_INFCTE:_IDE:_TOMA4:_IE:TEXT) , Nil } )
								Aadd(aDadosSA1, {"A1_CONTRIB"   , "1" , Nil } )
							Else
								Aadd(aDadosSA1, {"A1_INSCR"     , "ISENTO" , Nil } )
								Aadd(aDadosSA1, {"A1_CONTRIB"   , "2" , Nil } )
							EndIf
						Else
							Aadd(aDadosSA1, {"A1_PESSOA"    , "F"   , Nil } )
							Aadd(aDadosSA1, {"A1_CGC"       , AllTrim(oFullXML:_CTEPROC:_CTE:_INFCTE:_IDE:_TOMA4:_CPF:TEXT) , Nil } )
							Aadd(aDadosSA1, {"A1_INSCR"     , "ISENTO" , Nil } )
							Aadd(aDadosSA1, {"A1_CONTRIB"   , "2" , Nil } )
						EndIf

						U_JLCadCli(aDadosSA1,@aErro)

						If Len(aErro) > 0
							AAdd(aMsgErr,{'Erro ao incluir cliente consignatário: '+cCGCRec,'00',''})
							aEval(aErro,{|e| Aadd(aMsgErr,{ e,'00','' }) })

							AEval(aMsgErr,{|x| cErro += x[1] + CRLF })
							cRetorno := cErro
							lProces := .F.
						Else
							cRetorno := "Inclusão cliente consignatário " + Transform(AllTrim(cCGCCon), "@r 99.999.999/9999-99") +  ' - ' + SA1->A1_NOME

						EndIf

						AADD(aLogImp,{PA0->PA0_ID,Date(),Time(),cOrigem,cRetorno,'','','',cRetPrc})
						cRetorno := ""

					EndIf
					cIECon  := SA1->A1_INSCR
				EndIf
			EndIf
		EndIf
	EndIf

	If lProces

		cDoc    := StrZero(Val(AllTrim(oXML:_InfCte:_Ide:_nCT:Text)),TamSx3("DT6_DOC")[1])
		cTpServ := oXML:_InfCte:_Ide:_tpServ:Text
		cSerie  := AvKey(StrZero(Val(AllTrim(oXML:_InfCte:_Ide:_Serie:Text)),2),"F2_SERIE")		//TamSX3("DT6_SERIE")[1])
		cMunIni := SubStr(oXML:_InfCte:_Ide:_cMunIni:Text,3,TamSX3("DUY_CODMUN")[1])
		xMunIni := oXML:_InfCte:_Ide:_xMunIni:Text
		cUfIni  := oXML:_InfCte:_Ide:_UfIni:Text
		cMunFim := SubStr(oXML:_InfCte:_Ide:_cMunFim:Text,3,TamSX3("DUY_CODMUN")[1])
		xMunFim := oXML:_InfCte:_Ide:_xMunFim:Text
		cUfFim  := oXML:_InfCte:_Ide:_UfFim:Text
		cCFOP	:= Alltrim(oXML:_InfCte:_Ide:_CFOP:Text)

		cChvCTe	:= oFullXML:_CTEPROC:_PROTCTE:_INFPROT:_CHCTE:TEXT

		If Type("oXML:_InfCte:_Ide:_toma3:_toma") <> "U"
			cTomSrv := oXML:_InfCte:_Ide:_toma3:_toma:Text
		ElseIf Type("oXML:_InfCte:_Ide:_toma4:_toma") <> "U"
			cTomSrv := oXML:_InfCte:_Ide:_toma4:_toma:Text
		EndIf

		dDatEmi := StoD(Padr(StrTran(AllTrim(oXML:_InfCte:_Ide:_dhEmi:Text),"-",""),8))

		If Type('oXML:_INFCTE:_INFCTENORM:_INFCARGA') <> "U"

			If !lCompl
				If ValType(XmlChildEx(oXML:_InfCTe:_InfCTeNorm:_InfCarga,"_VCARGA")) == "O"
					nValMer := Val(oXML:_InfCte:_InfCTeNorm:_InfCarga:_vCarga:Text)
				EndIf
			EndIf

			cCodEmb := "UN"

			If Type('oXML:_INFCTE:_INFCTENORM:_INFCARGA:_INFQ') == "A"
				For nX := 1 To Len(oXML:_INFCTE:_INFCTENORM:_INFCARGA:_INFQ)
					If "01" $ oXML:_INFCTE:_INFCTENORM:_INFCARGA:_INFQ[nX]:_CUNID:TEXT
						nPeso += Val(oXML:_INFCTE:_INFCTENORM:_INFCARGA:_INFQ[nX]:_QCARGA:TEXT)
					ElseIf "03" $ oXML:_INFCTE:_INFCTENORM:_INFCARGA:_INFQ[nX]:_CUNID:TEXT
						nQtdVol += Val(oXML:_INFCTE:_INFCTENORM:_INFCARGA:_INFQ[nX]:_QCARGA:TEXT)
					EndIf
				Next nX
			ElseIf Type('oXML:_INFCTE:_INFCTENORM:_INFCARGA:_INFQ') <> "U"
				nPeso := Val(oXML:_InfCte:_InfCTeNorm:_InfCarga:_InfQ:_qCarga:Text)
			EndIf
		EndIf

		If Type('oXML:_INFCTE:_INFCTENORM:_INFDOC:_INFNFE') == "A"
			cChvNFe := oXML:_INFCTE:_INFCTENORM:_INFDOC:_INFNFE[1]:_CHAVE:TEXT
		ElseIf Type('oXML:_INFCTE:_INFCTENORM:_INFDOC:_INFNFE') <> "U"
			cChvNFe := oXML:_INFCTE:_INFCTENORM:_INFDOC:_INFNFE:_CHAVE:TEXT
		EndIf

		If !Empty(cChvNFe)
			cNumNFC := StrZero(Val(SubStr(cChvNFe,26,9)),TamSX3("DE5_DOC")[1])
			cSerNFC := PadR(SubStr(cChvNFe,23,3),TamSX3("DE5_SERIE")[1])
		Else
			cNumNFC := cDoc
			cSerNFC := cSerie
		EndIf

		If ValType(XmlChildEx(oXML:_INFCTE:_COMPL,"_XOBS")) == "O"
			xObs := oXML:_INFCTE:_COMPL:_XOBS:Text
		EndIf

		If ValType(XmlChildEx(oXML:_InfCTe:_vPrest,"_VTPREST")) == "O"
			nValTot := Val(oXML:_InfCTe:_vPrest:_vTPrest:Text)
		EndIf

		If cTpCTe == '2' .And. Empty(cCGCRec)	// Empty(cCliRec) .And. Empty(cLojRec)
			cCGCCon := cCGCEmi
			cCGCDev := cCGCCon
			cTipFre := '2'
			cTipNFC := '2'
		ElseIf cTomSrv $ '0' //-- Remetente
			cCGCDev := cCGCRem
			cDevFre := '1'
			cTipFre := '1'
		ElseIf cTomSrv $ '1' //-- Expedidor
			cCGCDev := cCGCExp
			cDevFre := '6'
			cTipFre := '1'
		ElseIf cTomSrv $ '2' //-- Recebedor
			cCGCDev := cCGCRec
			cDevFre := '7'
			cTipFre := '2'
		ElseIf cTomSrv $ '3' //-- Destinatario
			cCGCDev := cCGCDes
			cDevFre := '2'
			cTipFre := '2'
		ElseIf cTomSrv $ '4' //-- Consignarario
			cCGCDev := cCGCCon
			cDevFre := '3'
			cTipFre := '2'
		EndIf

		cCodPro := SuperGetMv('MV_PROGEN',,'')      // SuperGetMv('ES_PRODINT',,'')//

		DUY->(dbSetOrder(6))
		If DUY->(!dbSeek(xFilial('DUY') + cUfIni + cMunIni))
			AAdd(aMsgErr,{'Municipio de origem não cadastrado: '+TMS120CdUf(cUfIni)+cMunIni+' '+xMunIni+'/'+cUfIni,'00',''})
			lProces := .F.
		Else
			cCdrOri := DUY->DUY_GRPVEN
		EndIf

		If DUY->(!dbSeek(xFilial('DUY') + cUfFim + cMunFim))
			AAdd(aMsgErr,{'Municipio de destino não cadastrado: ' + TMS120CdUf(cUfFim)+cMunFim+' '+xMunFim+'/'+cUfFim,'00',''})
			lProces := .F.
		Else
			cCdrDes := DUY->DUY_GRPVEN
		EndIf

		SX5->(dbSetOrder(1))

		If SX5->(!dbSeek(xFilial('SX5')+'MG'+cCodEmb))
			AAdd(aMsgErr,{'Código de embalagem não cadastrado: '+cCodEmb,'00',''})
			lProces := .F.
		EndIf

		SA1->(dbSetOrder(3))
		If SA1->(MsSeek(xFilial('SA1') + cCGCDev))
			cCliDev := SA1->A1_COD
			cLojDev := SA1->A1_LOJA
			cSativ1 := SA1->A1_SATIV1
		EndIf

		//	If TMSPesqServ('DTC', cCliDev, cLojDev, cSerTms, cTipTra, @aItContrat,.F.,	cTipFre,.F.,,,,,,,cCdrOri, cCdrDes,,,,,,,,cCodNeg,,.T.)

		//----------------------------------------------------------------------------------
		//³Pesquisa O Serviço e tipo de transporte contratado pelo Tomador do Serviço
		//----------------------------------------------------------------------------------
		If TMSPesqServ('DE5'/*cAlias*/, cCliDev /*cCodCli*/, cLojDev /*cLojCli*/, /*cSerTMS*/,  /*cTipTra */,  @aItContrat /*aItContrat*/;
				,.F.      /*lMostra*/, cTipFre /*cTipFre*/, .F./*lRotAuto*/, /*cDocTms */, /*lChkCliGen*/, /*cTabFre   */;
				,         /*cTipTab*/,         /*cVigCon*/, .F./*lHelp   */, /*cCdrOri */, /*cCdrDes   */, /*lPortalTMS*/;
				,         /*lRateio*/,         /*cBACRAT*/,    /*cCRIRAT */, /*cPRORAT */, /*cTABRAT   */, /*cTIPRAT   */;
				, cCodNeg /*cCodNeg*/,         /*cCampo */, .T./*lEDI*/)

			cCodNeg := ""
			cSerVic := ""

			If !Empty(aItContrat)
				cCodNeg := aItContrat[1,6]
				cSerVic := aItContrat[1,3]
				//cSerTms := Posicione ('DC5',1,xFilial('DC5') + aItContrat[1,3],'DC5_SERTMS')
				cTipTra := DC5->DC5_TIPTRA
			EndIf

			If Empty(cServic)
				AAdd(aMsgErr,{'Erro ao localizar serviço de negociação para o cliente: '+ cCGCDev ,'00',''})
				lProces := .F.
			EndIf
		Else
			AAdd(aMsgErr,{'Erro ao localizar serviço de negociação para o cliente: ' + cCGCDev, '00',''})
			lProces := .F.
		EndIf

		If Empty(cSativ1)	//(Posicione('SA1',1,xFilial('SA1') + cCliDev + cLojDev,'A1_SATIV1'))
			AAdd(aMsgErr,{'Segmento cadastro de cliente não preenchido. ' + cCGCDev ,'00',''})
			cOrigem := "IMPXML_TMS"
			lProces := .F.
		EndIf

		If lProces

			lMsErroAuto    	:= .F.
			lAutoErrNoFile 	:= .T.
			nOpcx			:= 3
			nModulo        	:= 43

			DTC->(DbSetOrder(5)) //-- DTC_FILIAL+DTC_CLIREM+DTC_LOJREM+DTC_NUMNFC+DTC_SERNFC

			If lTM050NF
				If DTC->(MsSeek(xFilial("DTC") + cCliRem + cLojRem + cNumNFC + cSerNFC))
					cOrigem := "IT01GERDOC"
					cRetorno := "Doc.Transporte do cliente já utilizado em outro documento. Parametro MV_TM050NF habilitado."
					cRetPrc	 := "NF/DOC já utilizado no DOC: " + DTC->DTC_FILDOC + '-' + DTC->DTC_DOC + '-' + DTC->DTC_SERIE
					AADD(aLogImp,{PA0->PA0_ID,Date(),Time(),cOrigem,cRetorno,'','','',cRetPrc})
					lProces   := .F.
				EndIf
			EndIf

			aErro := {}
			cRetorno := ""

			If lProces
				lMsErroAuto := .F.

				/*
				tpServ	inteiro	1	sim	informar o tipo de serviço:
				0 - Normal;
				1 - Subcontratação;
				2 - Redespacho;
				3 - Redespacho Intermediário;
				4 - Serviço Vinculado a Multimodal.
				*/

				Aadd(aHeadDE5, {"DE5_CGCREM" , cCGCRem      , Nil})	//CGC Remetente
				Aadd(aHeadDE5, {"DE5_CGCDES" , cCGCDes      , Nil})	//CGC Destinatario
				Aadd(aHeadDE5, {"DE5_CGCCON" , cCGCCon      , Nil})	//CGC Consignatario
				Aadd(aHeadDE5, {"DE5_CGCDEV" , cCGCDev      , Nil})	//CGC Devedor
				Aadd(aHeadDE5, {"DE5_DTAEMB" , dDataBase    , Nil})
				Aadd(aHeadDE5, {"DE5_TIPFRE" , cTipFre      , Nil})
				Aadd(aHeadDE5, {"DE5_DOC"    , cNumNFC      , Nil})
				Aadd(aHeadDE5, {"DE5_SERIE"  , cSerNFC      , Nil})
				Aadd(aHeadDE5, {"DE5_EMINFC" , dDatEmi      , Nil})
				Aadd(aHeadDE5, {"DE5_NFEID"  , cChvNFe      , Nil})
				Aadd(aHeadDE5, {"DE5_CFOPNF" , cCFOP        , Nil})
				Aadd(aHeadDE5, {"DE5_SEQEND" , ""           , Nil})
				Aadd(aHeadDE5, {"DE5_SERTMS" , cSerTms      , Nil})

				If !Empty(cTipTra)
					Aadd(aHeadDE5,{"DE5_TIPTRA"	,cTipTra , Nil }) //Tipo de Transporte
				EndIf

				Aadd(aHeadDE5,{"DE5_CODNEG"	,cCodNeg, Nil }) //Cód de negociacao

				If !Empty(cCGCRem) .And. !Empty(cCGCDes) .And. !Empty(cCGCDev) .And. !Empty(cTipTra) .And. !Empty(cTipFre)
					Aadd(aHeadDE5,{"DE5_SERVIC"	,cSerVic , Nil }) //Servico de Transporte
				EndIf

				If !Empty(cLotEDI)
					Aadd(aHeadDE5,{"DE5_LOTEDI"	,cLotEDI , Nil }) //Lote Edi
				EndIf

				If lINSCEDI .And. DE5->(ColumnPos('DE5_INSCRE')) > 0 .And. DE5->(ColumnPos('DE5_INSDES')) > 0 .And. DE5->(ColumnPos('DE5_INSDEV')) > 0
					Aadd(aHeadDE5,{"DE5_INSCRE"		,cIERem , Nil}) //Inscricao estadual do remetente
					Aadd(aHeadDE5,{"DE5_INSDES"		,cIEDes , Nil}) //Inscricao estadual do destinatario
					Aadd(aHeadDE5,{"DE5_INSDEV"		,cIEDev , Nil}) //Inscricao estadual do devedor
				EndIf

				//-- Adiciona o Expedidor / Recebedor
				If DE5->(ColumnPos("DE5_CGCEXP")) > 0
					Aadd(aHeadDE5,{"DE5_CGCEXP"	, cCGCExp,  Nil  })  // CGC Expedidor
					If !Empty(cCGCExp)
						Aadd(aHeadDE5,{"DE5_SELORI"	,"3", Nil  })  // Local de Coleta ou Expedidor
					Else
						Aadd(aHeadDE5,{"DE5_SELORI"	,cSelOri, Nil  })  // Cliente Remetente
					EndIf
				EndIf

				If DE5->(ColumnPos("DE5_CGCREC")) > 0
					Aadd(aHeadDE5,{"DE5_CGCREC"	,cCGCRec																					, Nil  })  //CGC Destinatário
				EndIf

				If lDE5_IDESTR
					Aadd(aHeadDE5,{"DE5_IDESTR"	,cIDEstrang																					, Nil  })  //ID Estrageiro
				EndIf

				// Dados Documento Anterior
				cDocCTe 	:= SubStr(cChvCTe,26,9)
				cSerCTe 	:= StrZero(Val(SubStr(cChvCTe,23,3)),2)

				Aadd(aHeadDE5, {"DE5_TIPNFC" , "2"          , Nil})
				Aadd(aHeadDE5, {"DE5_TIPANT" , "0"          , Nil})
				Aadd(aHeadDE5, {"DE5_DPCEMI" , dDatEmi	    , Nil})
				Aadd(aHeadDE5, {"DE5_CTEANT" , cChvCTe      , Nil})
				Aadd(aHeadDE5, {"DE5_CTRDPC" , cDocCTe      , Nil})
				Aadd(aHeadDE5, {"DE5_SERDPC" , cSerCTe      , Nil})
				Aadd(aHeadDE5, {"DE5_FRTSUB" , nValTot      , Nil})

				/// Dados mercadoria
				aItemDE5:= {}
				cUM     := Posicione('SB1',1, xFilial('SB1') + cCodPro,'B1_UM')

				Aadd( aItemDE5, {"DE5_CODPRO"	,cCodPro    , Nil	} )  //Produto
				Aadd( aItemDE5, {"DE5_CODEMB"	,cUM	    , Nil	} )  //Embalagem do Primeiro Produto
				Aadd( aItemDE5, {"DE5_VALOR"	,nValMer    , Nil	} )  //Valor da NF-e
				Aadd( aItemDE5, {"DE5_QTDVOL"	,nQtdVol    , Nil	} )  //Qtde de Volumes
				Aadd( aItemDE5, {"DE5_PESO"  	,nPeso      , Nil	} )  //Peso - considera o maior

				If lDE5PesLiq
					Aadd( aItemDE5, {"DE5_PESLIQ"  	,nPesoL, Nil	} )  //DLOGTMS01-748 - Armazenamento do Peso Líquido
				EndIf

				Aadd(aColsDE5,aClone(aItemDE5))
				///

				If lProces
					Begin Transaction
						MSExecAuto({|x,y,z| TMSAE55(x,y,z)},aHeadDE5,nOpcx,aColsDE5)
					End Transaction
				EndIf

				If lMsErroAuto
					AAdd(aMsgErr,{'Erro ao incluir a nota fiscal: ' + cNumNFC  + ' / ' +  cSerNFC,'00',''})
					aErro := GetAutoGRLog()
					//-- Retirar enter para exibir mensagem completa
					Aeval(aErro,{ | e, nI | AAdd(aMsgErr,{ Iif(At(Chr(13)+Chr(10),e) > 0,StrTran(e,Chr(13)+Chr(10)," "),e), '00', '' } ) })

					//AEval(aErro,{|aErro| cErro += AllTrim(x[1])  })
					AEval(aErro,{|x| cErro += AllTrim(x) + CRLF })
					cRetorno := cErro
					cRetPrc := "Erro ao incluir a nota fiscal: " + cNumNFC + ' / ' +  cSerNFC

					lProces := .F.
				Else
					cStaLog := '2'

					cOrigem := "TMSAE55"
					cRetorno := "NF-e processada com sucesso."
					cRetPrc	 := "NF-e processada com sucesso: " + DE5->DE5_DOC + '-' + DE5->DE5_SERIE
					AADD(aLogImp,{PA0->PA0_ID,Date(),Time(),cOrigem,cRetorno,'','','',cRetPrc})
					lProces   := .F.

				EndIf

			//	AADD(aLogImp,{PA0->PA0_ID,Date(),Time(),cOrigem,cRetorno,'','','',cRetPrc})
				cRetorno := ""

			EndIf
		EndIf
	EndIf

// ------------------------------------------------------------------------------------------ //
// Limpa o Objeto: oFullXMl Conforme orientado pelo Framework, se faz necessário a utilização //
// do DesClassIntf para que o Objeto realmente seje limpo.                                    //
// Caso contrário, em situações onde existir um grande numero de XMLS Parseados, ocorrera a   //
// mensagem: XML dynamic Nodes Overflow                                                       //
// Antes de executar o comando: DesClassIntf, coloque o objeto como NIL                       //
// ------------------------------------------------------------------------------------------ //
	oXML	 :=Nil
	oAuxXml  :=Nil
	oFullXML :=Nil
	DelClassIntf()

Return lProces

/*/{Protheus.doc} INT001
Importação CT-e
@author DLeme
@type User function
@since Dez/2021
@version 1.0
/*/

Static Function JLRetNFC(cFildoc,cDoc,cSerie)

	Local aRet	:= {}
	Local cQuery	:= ""
	Local aArea     := GetArea()
	Local cAliDTC	:= GetNextAlias()

	cQuery := " SELECT R_E_C_N_O_ RECNODTC FROM " + RetSqlName("DTC") + " DTC "
	cQuery += "  WHERE DTC_FILIAL = '" + xFilial("DTC") + "' "
	cQuery += "    AND DTC_FILDOC = '" + cFilDoc + "' "
	cQuery += "    AND DTC_DOC    = '" + cDoc + "' "
	cQuery += "    AND DTC_SERIE  = '" + cSerie + "' "
	cQuery += "    AND DTC.D_E_L_E_T_ = ' ' "

	If Select(cAliDTC) > 0
		(cAliDTC)->(dbCloseArea())
	EndIf

	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliDTC)

	While (cAliDTC)->(!Eof())
		AADD(aRet, (cAliDTC)->RECNODTC )
		(cAliDTC)->(DbSkip())
	EndDo
	(cAliDTC)->( dbCloseArea() )

	RestArea(aArea)

Return aRet



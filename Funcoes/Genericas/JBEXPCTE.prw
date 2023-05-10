#include "protheus.ch"
#include 'parmtype.ch'
#INCLUDE "RWMAKE.CH"
#include "TbiConn.ch"
#include "TbiCode.ch"
#INCLUDE "TOTVS.CH"
#INCLUDE "FONT.CH"
#INCLUDE "TOPCONN.ch"
#include "Fileio.ch"

/*====================================================================================\
|Programa  | JBEXPCTE    | Autor | Rafael Rosa               | Data | 25/08/2022      |
|=====================================================================================|
|Descri��o | Exportacao de CTe                                                        |
|          |                                                                          |
|          |                                                                          |
|=====================================================================================|
|Sintaxe   | JBEXPCTE                                                                 |
|=====================================================================================|
|Uso       | Especifico DIPROMED                                                      |
|=====================================================================================|
|........................................Hist�rico....................................|
|Dev       | DD/MM/AA - Descri��o                                                     |
|Rafael    | 25/08/2022 - Fonte elaborado (Em fase de testes)                         |
|Rafael    | 07/09/2022 - Diretorio em \Protheus_Data definido no MV_ZDIEXOM          |
\====================================================================================*/

User Function JBEXPCTE()
//Parametros padroes - Rotina original SpedExp
//cIdEnt,cSerie,cNotaIni,cNotaFim,cDirDest,lEnd,dDataDe,dDataAte,cCnpjDIni,cCnpjDFim,nTipo,lCTe,cSerMax,cOpcExp

//Rafael - Variaveis Adicionadas - INICIO
//---------tratamento personalizado Dipro---------
Local cIdEnt    := "000007" //VALIDAR ENTIDADE
Local cSerie    := ""
Local cSerMax   := "ZZZ"
Local cNotaIni  := "000000001" //VERIFICAR TAMANHO
Local cNotaFim  := "999999999" //VERIFICAR TAMANHO
Local cDirDest	:= GetNewPar("MV_ZDIEXOM","")
//Local lEnd      : .T. //VERIFICAR VARIAVEL
//Local dDataDe   := Date()
//Local dDataAte  := Date()
//Local dDataDe   := CTOD("21/12/2022")
//Local dDataAte  := CTOD("21/12/2022")
//Local dDataDe   := dDatabase //Rafael Moraes Rosa - 22/12/2022 - Linha comentada
//Local dDataAte  := dDatabase //Rafael Moraes Rosa - 22/12/2022 - Linha comentada
Local dDataDe   := STOD(IIF(!Empty(GetMV("MV_ZDTEXOM")),GetMV("MV_ZDTEXOM"),DTOS(dDatabase))) //Rafael Moraes Rosa - 22/12/2022 - Linha adicionada
Local dDataAte  := STOD(IIF(!Empty(GetMV("MV_ZDTEXOM")),GetMV("MV_ZDTEXOM"),DTOS(dDatabase))) //Rafael Moraes Rosa - 22/12/2022 - Linha adicionada
Local cCnpjDIni := "00000000000000"
Local cCnpjDFim := "99999999999999"
Local lCTe      := .T.
Local cOpcExp   := "1"
Local nTipo		:= 1
Local cDestino 	:= cDirDest + "\"
//---------tratamento personalizado Dipro---------
//Rafael - Variaveis Adicionadas - FIM

Local aDeleta  := {}

Local cAlias	:= GetNextAlias()
Local cAnoInut  := ""
Local cAnoInut1 := ""
Local cCanc		:= ""
Local cChvIni  	:= ""
Local cChvFin	:= ""
Local cChvNFe  	:= ""
Local cCNPJDEST := Space(14)
Local cCondicao	:= ""
//Rafael - Variavel Comentada
//Local cDestino 	:= ""
Local cIdflush  := cSerie+cNotaIni
Local cModelo  	:= ""
Local cNFes     := ""
Local cPrefixo 	:= ""
Local cURL     	:= PadR(GetNewPar("MV_SPEDURL","http://"),250)
Local cXmlInut  := ""
Local cXml		:= ""
Local cWhere	:= ""
Local cXmlProt	:= ""
local cTab		  := ""
local cCmpNum	  := ""
local cCmpSer	  := ""
local cCmpTipo  := ""
local cCmpLoja  := ""
local cCmpCliFor:= ""
local cCnpj	  := ""
Local cEventoCTe	:= ""
Local cRetEvento	:= ""
Local cRodapCTe  :=""
local cCabCTe    :=""
Local cIdEven	   := ""
local cVerMDfe		:= ""
local cNumMdfe		:= ""
Local cColTipo	:= ""

Local lOk      	:= .F.
Local lFlush  	:= .T.
Local lFinal   	:= .F.
Local lExporta 	:= .F.
Local lUsaColab	:= .F.
Local lSdoc     := TamSx3("F2_SERIE")[1] == 14
Local lSpedNfe01:= ExistBlock("SPDNFE01")
Local lFisExpnfe:= ExistBlock("FISEXPNFE")

Local nHandle  	:= 0
Local nX        := 0
Local nY		:= 0
local nZ		:= 0
Local cErro		:= ""
Local cAviso	:= ""

Local aInfXml	:= {}

Local oRetorno
Local oWS
Local oXml


Local lOkCanc		:= .f.
local lValidSerie := .F.
Local lAglExp	:= iif(GetNewPar("MV_AGLEXP","0") == "1",.T.,.F.)

local cIdInicial	:= ""

//Default nTipo	:= 1
//Default cNotaIni:= ""
//Default cNotaFim:= ""
//Default dDataDe	:= CtoD("  /  /  ")
//Default dDataAte:= CtoD("  /  /  ")
//Default lCTe	:= IIf(FunName()$"SPEDCTE,TMSA200,TMSAE70,TMSA500,TMSA050",.T.,.F.)
//Default cSerMax := cSerie
//Default cOpcExp	:= "1"

/*--------------------------------------------------
		Corrige diretorio de destino e 
			verifica se � diret�rio v�lido
--------------------------------------------------*/

//Rafael - Comentado - INICIO
/*
If !SpedVldDir(@cDestino, @mv_par04)
	return .T.
EndIf
*/
//Rafael - Comentado - INICIO

If lCte
	cColTipo := "2"
ElseIf nTipo == 5 //MDF-e
	cColTipo := "5"
Else
	cColTipo := "1"
EndIf

lUsaColab := UsaColaboracao( cColTipo )

If nTipo == 3
	If !Empty( GetNewPar("MV_NFCEURL","") )
		cURL := PadR(GetNewPar("MV_NFCEURL","http://"),250)
	Endif
Endif

If IntTMS() .and. lCTe//Altera o conte�do da variavel quando for carta de corre��o para o CTE
	cTipoNfe := "SAIDA"
EndIf
ProcRegua(Val(cNotaFim)-Val(cNotaIni))

//������������������������������������������������������������������������Ŀ
//� Inicia processamento                                                   �
//��������������������������������������������������������������������������
cIdInicial := IIf(nTipo==4,'58'+cIdflush,cIdflush) // cNotaIni
Do While lFlush

	If ( nTipo == 1 .And. !lUsaColab ).Or. nTipo == 3 .Or. (nTipo == 4 .And. !lUsaColab) .Or. (nTipo == 5 .And. !lUsaColab)
		oWS:= WSNFeSBRA():New()
		oWS:cUSERTOKEN        := "TOTVS"
		oWS:cID_ENT           := cIdEnt
		oWS:_URL              := AllTrim(cURL)+"/NFeSBRA.apw"
		oWS:cIdInicial        := cIdInicial
		oWS:cIdFinal          := IIf(nTipo==4,'58'+cSerMax+cNotaFim,cSerMax+cNotaFim)
		oWS:dDataDe           := dDataDe
		oWS:dDataAte          := dDataAte
		oWS:cCNPJDESTInicial  := cCnpjDIni
		oWS:cCNPJDESTFinal    := cCnpjDFim
		oWS:nDiasparaExclusao := 0
		lOk:= oWS:RETORNAFX()
		oRetorno := oWS:oWsRetornaFxResult
		lOk := iif( valtype(lOk) == "U", .F., lOk )

		If lOk
			ProcRegua(Len(oRetorno:OWSNOTAS:OWSNFES3))
			//������������������������������������������������������������������������Ŀ
			//� Exporta as notas                                                       �
			//��������������������������������������������������������������������������

		    For nX := 1 To Len(oRetorno:OWSNOTAS:OWSNFES3)

                //Ponto de Entrada para permitir filtrar as NF
                If lSpedNfe01
                   If !ExecBlock("SPDNFE01",.f.,.f.,{oRetorno:OWSNOTAS:OWSNFES3[nX]})
                      loop
                   Endif
                Endif

		 		oXml    := oRetorno:OWSNOTAS:OWSNFES3[nX]
				oXmlExp := XmlParser(oRetorno:OWSNOTAS:OWSNFES3[nX]:OWSNFE:CXML,"_",@cErro,@cAviso)
				cXML	:= ""
				If ValAtrib("oXmlExp:_NFE:_INFNFE:_DEST:_CNPJ")<>"U"
					cCNPJDEST := AllTrim(oXmlExp:_NFE:_INFNFE:_DEST:_CNPJ:TEXT)
				ElseIF ValAtrib("oXmlExp:_NFE:_INFNFE:_DEST:_CPF")<>"U"
					cCNPJDEST := AllTrim(oXmlExp:_NFE:_INFNFE:_DEST:_CPF:TEXT)
				Else
	    			cCNPJDEST := ""
    			EndIf
    				cVerNfe := IIf(ValAtrib("oXmlExp:_NFE:_INFNFE:_VERSAO:TEXT") <> "U", oXmlExp:_NFE:_INFNFE:_VERSAO:TEXT, '')
	  				cVerCte := Iif(ValAtrib("oXmlExp:_CTE:_INFCTE:_VERSAO:TEXT") <> "U", oXmlExp:_CTE:_INFCTE:_VERSAO:TEXT, '')
	  				cVerMDfe:= Iif(ValAtrib("oXmlExp:_MDFE:_INFMDFE:_VERSAO:TEXT") <> "U", oXmlExp:_MDFE:_INFMDFE:_VERSAO:TEXT, '')

		 		If !Empty(oXml:oWSNFe:cProtocolo)
			    	cNotaIni := oXml:cID
					cIdflush := cNotaIni
			 		cNFes := cNFes+cNotaIni+CRLF
			 		cChvNFe  := NfeIdSPED(oXml:oWSNFe:cXML,"Id")
					cModelo := cChvNFe
					cModelo := StrTran(cModelo,"NFe","")
					cModelo := StrTran(cModelo,"CTe","")
					cModelo := StrTran(cModelo,"MDFe","")
					cModelo := SubStr(cModelo,21,02)

					Do Case
						Case cModelo == "57"
							cPrefixo := "CTe"
						Case cModelo == "65"
							cPrefixo := "NFCe"
						Case cModelo == "58"
							cPrefixo := "MDFe"
						OtherWise
							if '<cStat>301</cStat>' $ oXml:oWSNFe:cxmlPROT .or. '<cStat>302</cStat>' $ oXml:oWSNFe:cxmlPROT
								cPrefixo := "den"
							else
								cPrefixo := "NFe"
							endif
					EndCase

		 			cChvNFe	:= iif( cModelo == "58", SubStr(cChvNFe,5,44), SubStr(cChvNFe,4,44) )
					//--------------------------------------------------
					// Exporta MDFe - (Autorizada)
					//--------------------------------------------------
					if ( (cModelo=="58") .and. alltrim(FunName()) == 'SPEDMDFE' ) .Or. (cModelo == "58" .And. IsIncallStack("TMSAE73"))
						nHandle	:= 0
			 			nHandle := FCreate(cDestino+cChvNFe+"-"+cPrefixo+".xml")
			 			if nHandle > 0
			 				cCab1 := '<?xml version="1.0" encoding="UTF-8"?>'
							cCab1 	+= '<mdfeProc xmlns="http://www.portalfiscal.inf.br/mdfe" versao="'+cVerMDfe+'">'
							cRodap	:= '</mdfeProc>
							FWrite(nHandle,AllTrim(cCab1))
				 			FWrite(nHandle,AllTrim(oXml:oWSNFe:cXML))
				 			FWrite(nHandle,AllTrim(oXml:oWSNFe:cXMLPROT))
							FWrite(nHandle,AllTrim(cRodap))
				 			FClose(nHandle)
				 			aadd(aDeleta,oXml:cID)
				 			cNumMdfe += cIdflush+CRLF
				 		endif
					//--------------------------------------------------
					// Exporta Legado
					//--------------------------------------------------
					elseif alltrim(FunName()) <> 'SPEDMDFE'

			 			nHandle := FCreate(cDestino+cChvNFe+"-"+cPrefixo+".xml")
			 			If nHandle > 0
			 				cCab1 := '<?xml version="1.0" encoding="UTF-8"?>'
			 				If cModelo == "57"
								//cCab1  += '<cteProc xmlns="http://www.portalfiscal.inf.br/cte" xmlns:ds="http://www.w3.org/2000/09/xmldsig#" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.portalfiscal.inf.br/cte procCTe_v'+cVerCte+'.xsd" versao="'+cVerCte+'">'
								cCab1  += '<cteProc xmlns="http://www.portalfiscal.inf.br/cte" versao="'+cVerCte+'">'
								cRodap := '</cteProc>'
							Else
								Do Case
									Case cVerNfe <= "1.07"
										cCab1 += '<nfeProc xmlns="http://www.portalfiscal.inf.br/nfe" xmlns:ds="http://www.w3.org/2000/09/xmldsig#" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.portalfiscal.inf.br/nfe procNFe_v1.00.xsd" versao="1.00">'
									Case cVerNfe >= "2.00" .And. "cancNFe" $ oXml:oWSNFe:cXML
										cCab1 += '<procCancNFe xmlns="http://www.portalfiscal.inf.br/nfe" versao="' + cVerNfe + '">'
									OtherWise
										cCab1 += '<nfeProc xmlns="http://www.portalfiscal.inf.br/nfe" versao="' + cVerNfe + '">'
								EndCase
								cRodap := '</nfeProc>'
							EndIf
							FWrite(nHandle,AllTrim(cCab1))
				 			FWrite(nHandle,AllTrim(oXml:oWSNFe:cXML))
				 			FWrite(nHandle,AllTrim(oXml:oWSNFe:cXMLPROT))
							FWrite(nHandle,AllTrim(cRodap))
				 			FClose(nHandle)
				 			aadd(aDeleta,oXml:cID)

				 			cXML := AllTrim(cCab1)
							cXML += AllTrim(oXml:oWSNFe:cXML)
							cXML += AllTrim(oXml:oWSNFe:cXMLPROT)
							cXML += AllTrim(cRodap)
				 			If !Empty(cXML)
					 			If lFisExpnfe
		                   			ExecBlock("FISEXPNFE",.f.,.f.,{cXML})
		               			Endif
				 			EndIF
				 		EndIf
				 	endif
			 	EndIf

			 	//----------------------------------------
			 	// Exporta MDF-e (Eventos)
			 	//----------------------------------------
				if (alltrim(FunName()) == 'SPEDMDFE') .or. (cModelo == "58" .And. IsIncallStack("TMSAE73"))
					if ( (cModelo=="58") .and. (!empty(cChvNFe)) )
						//----------------------------------------
			 		 	// Executa o metodo NfeRetornaEvento()
						//----------------------------------------
						oWS:= WSNFeSBRA():New()
						oWS:cUSERTOKEN	:= "TOTVS"
						oWS:cID_ENT		:= cIdEnt
						oWS:_URL		:= AllTrim(cURL)+"/NFeSBRA.apw"
						oWS:cEvenChvNFE	:= cChvNFe
						if oWS:NFERETORNAEVENTO()
							if valType(oWS:oWsNfeRetornaEventoResult:oWsNfeRetornaEvento) <> "U"
								aDados := oWS:oWsNfeRetornaEventoResult:oWsNfeRetornaEvento

								for nZ := 1 to len( aDados )
									//Zerando variaveis
									nHandle := 0
									nHandle := FCreate(cDestino + cChvNFe + "-" + cPrefixo + "_evento_" + alltrim(str(nZ)) + ".xml")
					 				if nHandle > 0
					 					cCab1 	:= '<?xml version="1.0" encoding="UTF-8"?>'
										cCab1 	+= '<mdfeProc xmlns="http://www.portalfiscal.inf.br/mdfe" versao="'+cVerMDfe+'">'
										cRodap	:= '</mdfeProc>
										fWrite(nHandle,allTrim(cCab1))
							 			fWrite(nHandle,allTrim(aDados[nZ]:cXML_RET))
							 			fWrite(nHandle,allTrim(aDados[nZ]:cXML_SIG))
										fWrite(nHandle,allTrim(cRodap))
							 			fClose(nHandle)
							 			aAdd(aDeleta,oXml:cID)
							 		endif
							 	next nZ
							endif
						endif
					endif
			 	else
				 	If ( oXml:OWSNFECANCELADA <> Nil .And. !Empty(oXml:oWSNFeCancelada:cProtocolo) )
						cChave 	  := oXml:OWSNFECANCELADA:CXML
						If cModelo == "57" .and. cVerCte >='2.00'
							cChaveCc1 := At("<chCTe>",cChave)+7
						else
				 	   		cChaveCc1 := At("<chNFe>",cChave)+7
				 	   	endif
				 	   	cChaveCan := SubStr(cChave,cChaveCc1,44)

						oWS:= WSNFeSBRA():New()
						oWS:cUSERTOKEN	:= "TOTVS"
						oWS:cID_ENT		:= cIdEnt
						oWS:_URL		:= AllTrim(cURL)+"/NFeSBRA.apw"
						oWS:cID_EVENTO	:= "110111"
						oWS:cChvInicial	:= cChaveCan
						oWS:cChvFinal	:= cChaveCan
						lOkCanc			:= oWS:NFEEXPORTAEVENTO()
						oRetEvCanc 	:= oWS:oWSNFEEXPORTAEVENTORESULT


						if lOkCanc

							ProcRegua(Len(oRetEvCanc:CSTRING))
							//---------------------------------------------------------------------------
							//| Exporta Cancelamento do Evento da Nf-e                                  |
							//---------------------------------------------------------------------------

						    For nY := 1 To Len(oRetEvCanc:CSTRING)
						 		cXml    := SpecCharc(oRetEvCanc:CSTRING[nY])
						 		oXmlExp := XmlParser(cXml,"_",@cErro,@cAviso)
								If cModelo == "57" .and. cVerCte >='2.00'
						 			if ValAtrib("oXmlExp:_PROCEVENTONFE:_RETEVENTO:_CTERECEPCAOEVENTORESULT:_RETEVENTOCTE:_INFEVENTO:_CHCTE")<>"U"
								       	cIdEven	:= 'ID'+oXmlExp:_PROCEVENTONFE:_RETEVENTO:_CTERECEPCAOEVENTORESULT:_RETEVENTOCTE:_INFEVENTO:_CHCTE:TEXT
								  	elseIf ValAtrib("oXmlExp:_PROCEVENTONFE:_RETEVENTO:_RETEVENTOCTE:_INFEVENTO:_CHCTE")<>"U"
								  		cIdEven	:= 'ID'+oXmlExp:_PROCEVENTONFE:_RETEVENTO:_RETEVENTOCTE:_INFEVENTO:_CHCTE:TEXT
									endif

									If (oXmlExp:_PROCEVENTONFE:_EVENTO:_EVENTOCTE<>"U") .and. (oXmlExp:_PROCEVENTONFE:_RETEVENTO:_CTERECEPCAOEVENTORESULT:_RETEVENTOCTE<>"U")
						 				cCabCTe   := '<procEventoCTe xmlns="http://www.portalfiscal.inf.br/cte" versao="'+cVerCte+'">'
						 				cEventoCTe:= XmlSaveStr(oXmlExp:_PROCEVENTONFE:_EVENTO:_EVENTOCTE,.F.)
						 				cRetEvento:= XmlSaveStr(oXmlExp:_PROCEVENTONFE:_RETEVENTO:_CTERECEPCAOEVENTORESULT:_RETEVENTOCTE,.F.)
						 				cRodapCTe := '</procEventoCTe>'
						 				CxML:= cCabCTe+cEventoCTe+cRetEvento+cRodapCTe
									ElseIf (oXmlExp:_PROCEVENTONFE:_EVENTO:_EVENTOCTE<>"U") .and. (oXmlExp:_PROCEVENTONFE:_RETEVENTO:_RETEVENTOCTE:_INFEVENTO<>"U")
						 				cCabCTe   := '<procEventoCTe xmlns="http://www.portalfiscal.inf.br/cte" versao="'+cVerCte+'">'
						 				cEventoCTe:= XmlSaveStr(oXmlExp:_PROCEVENTONFE:_EVENTO:_EVENTOCTE,.F.)
						 				cRetEvento:= XmlSaveStr(oXmlExp:_PROCEVENTONFE:_RETEVENTO:_RETEVENTOCTE,.F.)
						 				cRodapCTe := '</procEventoCTe>'
						 				CxML:= cCabCTe+cEventoCTe+cRetEvento+cRodapCTe
						 			EndIf

						 		else
									if ValAtrib("oXmlExp:_PROCEVENTONFE:_EVENTO:_ENVEVENTO:_EVENTO:_INFEVENTO:_ID")<>"U"
										cIdEven	:= oXmlExp:_PROCEVENTONFE:_EVENTO:_ENVEVENTO:_EVENTO:_INFEVENTO:_ID:TEXT
									else
										if ValAtrib("oXmlExp:_PROCEVENTONFE:_EVENTO:_INFEVENTO:_ID")<>"U"
											cIdEven  := oXmlExp:_PROCEVENTONFE:_EVENTO:_INFEVENTO:_ID:TEXT
										EndIf
									endif
								endif

								//Rafael - Comentado - INICIO
								/*
								nHandle := FCreate(cDestino+SubStr(cIdEven,3)+"-Canc.xml")
					 			if nHandle > 0
									FWrite(nHandle,AllTrim(cXml))
						 			FClose(nHandle)
						 		endIf
								 */
								 //Rafael - Comentado - FIM

						    Next nY
						Else
							cChvNFe  := NfeIdSPED(oXml:oWSNFeCancelada:cXML,"Id")
						 	cNotaIni := oXml:cID
							cIdflush := cNotaIni
					 		cNFes := cNFes+cNotaIni+CRLF
						 	If !"INUT"$oXml:oWSNFeCancelada:cXML
					 			nHandle := FCreate(cDestino+SubStr(cChvNFe,3,44)+"-ped-can.xml")
					 			If nHandle > 0
					 				cCanc := oXml:oWSNFeCancelada:cXML
					 				If cModelo == "57"
					 					oXml:oWSNFeCancelada:cXML := '<procCancCTe xmlns="http://www.portalfiscal.inf.br/cte" versao="' + cVerCte + '">' + oXml:oWSNFeCancelada:cXML + "</procCancCTe>"
					 				Else
					 					oXml:oWSNFeCancelada:cXML := '<procCancNFe xmlns="http://www.portalfiscal.inf.br/nfe" versao="' + cVerNfe + '">' + oXml:oWSNFeCancelada:cXML + "</procCancNFe>"
					 				EndIf
						 			FWrite(nHandle,oXml:oWSNFeCancelada:cXML)
						 			FClose(nHandle)
						 			aadd(aDeleta,oXml:cID)
						 		EndIf
					 			nHandle := FCreate(cDestino+"\"+SubStr(cChvNFe,3,44)+"-can.xml")
					 			If nHandle > 0
						 			If cModelo == "57"
						 				FWrite(nHandle,'<procCancCTe xmlns="http://www.portalfiscal.inf.br/cte" versao="' + cVerCte + '">' + cCanc + oXml:oWSNFeCancelada:cXMLPROT + "</procCancCTe>")
						 			Else
										FWrite(nHandle,'<procCancNFe xmlns="http://www.portalfiscal.inf.br/nfe" versao="' + cVerNfe + '">' + cCanc + oXml:oWSNFeCancelada:cXMLPROT + "</procCancNFe>")
						 			EndIF
						 			FClose(nHandle)
						 		EndIf
							Else


								cXmlInut  := oXml:OWSNFECANCELADA:CXML
								cAnoInut1 := At("<ano>",cXmlInut)+5
								cAnoInut  := SubStr(cXmlInut,cAnoInut1,2)
								cXmlProt  := EncodeUtf8(oXml:oWSNFeCancelada:cXMLPROT)

								//Rafael - Comentado - INICIO
								/*
								If !lAglExp
									nHandle := FCreate(cDestino+SubStr(cChvNFe,3,2)+cAnoInut+SubStr(cChvNFe,5,39)+"-ped-inu.xml")
									If nHandle > 0
										FWrite(nHandle,oXml:OWSNFECANCELADA:CXML)
										FClose(nHandle)
										aadd(aDeleta,oXml:cID)
									EndIf
									
									nHandle := FCreate(cDestino+"\"+cAnoInut+SubStr(cChvNFe,5,39)+"-inu.xml")
									If nHandle > 0
										FWrite(nHandle,cXmlProt)
										FClose(nHandle)
									EndIf
								Else
									nHandle := FCreate(cDestino+SubStr(cChvNFe,3,2)+cAnoInut+SubStr(cChvNFe,5,39)+"-comp-inu.xml")
									If nHandle > 0
										cXmlComp := '<?xml version="1.0" encoding="UTF-8"?><ProcInutNFe versao="4.00" xmlns="http://www.portalfiscal.inf.br/nfe">'
										cXmlComp += cXmlInut
										cXmlComp += cXmlProt
										cXmlComp += '</ProcInutNFe>'
										FWrite(nHandle,cXmlComp)
										FClose(nHandle)
									EndIf
								EndIf
								*/
								//Rafael - Comentado - FIM
						 	EndIf
						EndIf
					EndIf
				endif
				IncProc()
			Next nX

			//������������������������������������������������������������������������Ŀ
			//� Exclui as notas                                                        �
			//��������������������������������������������������������������������������
			If !Empty(aDeleta) .And. GetNewPar("MV_SPEDEXP",0)<>0
				oWS:= WSNFeSBRA():New()
				oWS:cUSERTOKEN        := "TOTVS"
				oWS:cID_ENT           := cIdEnt
				oWS:nDIASPARAEXCLUSAO := GetNewPar("MV_SPEDEXP",0)
				oWS:_URL              := AllTrim(cURL)+"/NFeSBRA.apw"
				oWS:oWSNFEID          := NFESBRA_NFES2():New()
				oWS:oWSNFEID:oWSNotas := NFESBRA_ARRAYOFNFESID2():New()
			    For nX := 1 To Len(aDeleta)
					aadd(oWS:oWSNFEID:oWSNotas:oWSNFESID2,NFESBRA_NFESID2():New())
					Atail(oWS:oWSNFEID:oWSNotas:oWSNFESID2):cID := aDeleta[nX]
			    Next nX
				If !oWS:RETORNANOTAS()
					Aviso("SPED",IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3)),{"STR0046"},3) //"SPED" = "SPED"
					lFlush := .F.
				EndIf
			EndIf
			aDeleta  := {}

			If ( Len(oRetorno:OWSNOTAS:OWSNFES3) == 0 .And. Empty(cNfes) )
				//Rafael - Linha Comentada
			   	//Aviso("SPED","STR0106",{"Ok"})	// "N�o h� dados", "SPED" = "SPED"
				lFlush := .F.
		    EndIf
		Else
			Aviso("SPED",IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3))+CRLF+"STR0046",{"OK"},3) // "SPED" = "SPED"
			lFinal := .T.
		EndIf

		If lSdoc
			cIdflush := AllTrim(Substr(cIdflush,1,14) + Soma1(AllTrim(substr(cIdflush,15))))
		Else
			if IsIncallStack("TMSAE73") .and. len(alltrim(cSerie)) == 2
				cIdflush :=  AllTrim(Substr(cIdflush,1,5) + Soma1(AllTrim(substr(cIdflush,6))))
				lValidSerie := .T.
			else	
				cIdflush :=  AllTrim(Substr(cIdflush,1,3) + Soma1(AllTrim(substr(cIdflush,4))))
			endif
		EndIf
		cIdInicial := cIdflush
		If lOk
			If cIdflush <= AllTrim(cNotaIni) .Or. Len(oRetorno:OWSNOTAS:OWSNFES3) == 0 .Or. Empty(cNfes) .Or. ;
			   cIdflush <= If(lSdoc,Substr(cNotaIni,1,14)+Replicate('0',Len(AllTrim(mv_par02))-Len(Substr(Rtrim(cNotaIni),15)))+Substr(Rtrim(cNotaIni),15),;
										Substr(cNotaIni,1,3)+Replicate('0',Len(AllTrim(mv_par02))-Len(Substr(Rtrim(cNotaIni),4)))+Substr(Rtrim(cNotaIni),4)); // Importou o range completo
										.OR. lValidSerie
				lFlush := .F.
				//Rafael - Comentado - INICIO
				/*
				If !Empty(cNfes)
					If Aviso("SPED","STR0152",{"STR0661","STR0662"}) == 1	//"Solicita��o processada com sucesso.", "SPED" = "SPED", "STR0661" =  "Sim", "STR0662" =  "N�o"
						if alltrim(FunName()) == 'SPEDMDFE'
							if empty(cNumMdfe)
								Aviso("SPED","STR0106",{"Ok"})	// "N�o h� dados", "SPED" = "SPED"
							else
								Aviso("STR0126","STR0151"+" "+Upper(cDestino)+CRLF+CRLF+cNumMdfe,{"Ok"})
							endif
						else
							// Exporta Legado
							Aviso("STR0126","STR0151"+" "+Upper(cDestino)+CRLF+CRLF+cNFes,{"Ok"})//"STR0151"-"XML Exportados para", "XML's Exportados para"
						endif
					EndIf
				else
					Aviso("SPED","STR0106",{"Ok"})	// "N�o h� dados", "SPED" = "SPED"
				EndIf
				*/
				//Rafael - Comentado - FIM
			EndIf
		Else
			lFlush := .F.
		Endif
		delclassintf()
	ElseIf nTipo == 2  .Or. lUsaColab //Carta de Correcao e NF-e(QUANDO FOR TOTVS COLABORA��O 2.0)

	    cWhere := "D_E_L_E_T_=' '"
		If !Empty(cSerie)

			If lSdoc
				If cTipoNfe == "SAIDA"
					cWhere		+= " AND F2_SDOC ='"+SubStr(cSerie,1,3)+"'"
					cCondicao	+= AllTrim("F2_SDOC ='"+SubStr(cSerie,1,3)+"'")
				Else
					cWhere		+= " AND F1_SDOC ='"+SubStr(cSerie,1,3)+"'"
					cCondicao	+= AllTrim("F1_SDOC ='"+SubStr(cSerie,1,3)+"'")
				Endif
			Else
				If cTipoNfe == "SAIDA"
					cWhere		+= " AND F2_SERIE ='"+cSerie+"'"
					cCondicao	+= AllTrim("F2_SERIE ='"+cSerie+"'")
				Else
					cWhere		+= " AND F1_SERIE ='"+cSerie+"'"
					cCondicao	+= AllTrim("F1_SERIE ='"+cSerie+"'")
				Endif
			EndIf

		EndIf
		If !Empty(cNotaIni)
			If cTipoNfe == "SAIDA"
				cWhere		+= " AND F2_DOC >='"+cNotaIni+"'"
				cCondicao 	+= AllTrim(" .AND. F2_DOC >='"+cNotaIni+"'")
			Else
				cWhere		+= " AND F1_DOC >='"+cNotaIni+"'"
				cCondicao 	+= AllTrim(" .AND. F1_DOC >='"+cNotaIni+"'")
			Endif
		EndIf
		If !Empty(cNotaFim)
			If cTipoNfe == "SAIDA"
				cWhere		+= " AND F2_DOC <='"+cNotaFim+"'"
				cCondicao 	+= AllTrim(" .AND. F2_DOC <='"+cNotaFim+"'")
			Else
				cWhere		+= " AND F1_DOC <='"+cNotaFim+"'"
				cCondicao 	+= AllTrim(" .AND. F1_DOC <='"+cNotaFim+"'")
			Endif
		EndIf
		If !Empty(dDataDe)
			If cTipoNfe == "SAIDA"
				cWhere		+= " AND F2_EMISSAO >='"+DtoS(dDataDe)+"'"
				cCondicao 	+= " .AND. DTOS(F2_EMISSAO) >='"+DtoS(dDataDe)+"'"
			Else
				cWhere		+= " AND F1_EMISSAO >='"+DtoS(dDataDe)+"'"
				cCondicao 	+= " .AND. DTOS(F1_EMISSAO) >='"+DtoS(dDataDe)+"'"
			Endif
		EndIf
		If !Empty(dDataAte)
			If cTipoNfe == "SAIDA"
				cWhere		+= " AND F2_EMISSAO <='"+DtoS(dDataAte)+"'"
				cCondicao	+= " .AND. DTOS(F2_EMISSAO) <='"+DtoS(dDataAte)+"'"
			Else
				cWhere		+= " AND F1_EMISSAO <='"+DtoS(dDataAte)+"'"
				cCondicao	+= " .AND. DTOS(F1_EMISSAO) <='"+DtoS(dDataAte)+"'"
			Endif
		EndiF
		cWhere:="%"+cWhere+"%"

		If cTipoNfe == "SAIDA"
			if lUsaColab
				BeginSql Alias cAlias
					SELECT F2_DOC, F2_SERIE, F2_TIPO, F2_CLIENTE, F2_LOJA
					FROM %Table:SF2%
					WHERE F2_FILIAL= %xFilial:SF2%
					AND	%Exp:cWhere%
				EndSql
				lExporta:=!(cAlias)->(Eof())
			else
				BeginSql Alias cAlias
					SELECT MIN(R_E_C_N_O_) AS RECINI,MAX(R_E_C_N_O_) AS RECFIN
					FROM %Table:SF2%
					WHERE F2_FILIAL= %xFilial:SF2%
					AND	%Exp:cWhere%
				EndSql
				SF2->(dbGoTo((cAlias)->RECINI))
				cChvIni := SF2->F2_CHVNFE
				SF2->(dbGoTo((cAlias)->RECFIN))
				cChvFin := SF2->F2_CHVNFE
				lExporta:=!(cAlias)->(Eof())
			endif
		Else
			if lUsaColab
				BeginSql Alias cAlias
					SELECT F1_DOC, F1_SERIE, F1_TIPO, F1_FORNECE, F1_LOJA
					FROM %Table:SF1%
					WHERE F1_FILIAL= %xFilial:SF1%
					AND	%Exp:cWhere%
				EndSql
				lExporta:=!(cAlias)->(Eof())
			else
				BeginSql Alias cAlias
					SELECT MIN(R_E_C_N_O_) AS RECINI,MAX(R_E_C_N_O_) AS RECFIN
					FROM %Table:SF1%
					WHERE F1_FILIAL= %xFilial:SF1%
					AND	%Exp:cWhere%
				EndSql
				SF1->(dbGoTo((cAlias)->RECINI))
				cChvIni := SF1->F1_CHVNFE
				SF1->(dbGoTo((cAlias)->RECFIN))
				cChvFin := SF1->F1_CHVNFE
				lExporta:=!(cAlias)->(Eof())
			endif
		Endif

        If lExporta
        	If lUsaColab

				cCnpjDFim := iif(empty(cCnpjDFim),"99999999999999", cCnpjDFim)

        		(cAlias)->(dbGoTop())

        		While !(cAlias)->(Eof())

					if cTipoNfe == "SAIDA"
	        			cTab := 'F2_'
	        			cCmpCliFor := cTab+'CLIENTE'
	        		else
	        			cTab := 'F1_'
	        			cCmpCliFor := cTab+'FORNECE'
	        		endif

	        		cCmpNum 	:= cTab+'DOC'
	        		cCmpSer 	:= cTab+'SERIE'
	        		cCmpTipo	:= cTab+'TIPO'
	        		cCmpLoja	:= cTab+'LOJA'
	        		cPrefix := iif(nTipo == 1,IIF(lCTe,"CTe","NFe"),"CCe")

	        		//Tratamento para verificar se o CNPJ est� no range inserido pelo usu�rio.
	        		lCnpj :=	.F.

					if cPrefix $ "CCe"
					 	lCnpj := .T.
					else

						If cTipoNfe == "SAIDA"
							if (cAlias)->&cCmpTipo $ 'D|B'
								cCnpj := Posicione("SA2",1,xFilial("SA2")+(cAlias)->&cCmpCliFor+(cAlias)->&cCmpLoja,"A2_CGC")
							else
								cCnpj := Posicione("SA1",1,xFilial("SA1")+(cAlias)->&cCmpCliFor+(cAlias)->&cCmpLoja,"A1_CGC")
							endif
						else
							if (cAlias)->&cCmpTipo $ 'D|B'
								cCnpj := Posicione("SA1",1,xFilial("SA1")+(cAlias)->&cCmpCliFor+(cAlias)->&cCmpLoja,"A1_CGC")
							else
								cCnpj := Posicione("SA2",1,xFilial("SA2")+(cAlias)->&cCmpCliFor+(cAlias)->&cCmpLoja,"A2_CGC")
							endif
						endif

						if cCnpj >= cCnpjDIni .And. cCnpj <= cCnpjDFim
							lCnpj := .T.
						endif
					endif

					If lCnpj
						cXML := ""

						aInfXml	:= {}
						aInfXml := ColExpDoc((cAlias)->&cCmpSer,(cAlias)->&cCmpNum,iif(nTipo == 1,IIF(lCTe,"CTE","NFE"),"CCE"),@cXml)
		 				/*
						 	aInfXml
						 	[1] - Logico se encotra documento .T.
						 	[2] - Chave do documento
						 	[3] - XML autoriza��o - someente se autorizado
						 	[4] - XML Cancelamento Evento- somente se autorizado
						 	[5] - XML Ped. Inutiliza��o - somente se autorizado
						 	[6] - XML Prot. Inutiliza��o - somente se autorizado
						*/
						//Ponto de Entrada para permitir filtrar as NF
						If lSpedNfe01
							If !ExecBlock("SPDNFE01",.f.,.f.,{aInfXml})
								(cAlias)->(dbSkip())
								loop
							Endif
	               		Endif
						//Encontrou documento
						if aInfXMl[1]

							if cPrefix == "CCe" .And. !Empty( aInfXMl[3] )
								nHandle := FCreate(cDestino+SubStr(aInfXMl[2],3)+"-CCe.xml")
								cXML := aInfXMl[3]

								If nHandle > 0
									FWrite(nHandle,AllTrim(cXml))
						 			FClose(nHandle)
					 			EndIf
					 			cNFes+=SubStr((cAlias)->&cCmpSer,1,3)+"/"+(cAlias)->&cCmpNum+CRLF

							elseif cPrefix $ "NFe|CTe"
								//Iinutiliza��o
								if !Empty( aInfXMl[5] )
									cXmlInut  := aInfXMl[5]
									cAnoInut1 := At("<ano>",cXmlInut)+5
									cAnoInut  := SubStr(cXmlInut,cAnoInut1,2)
									cXmlProt  := aInfXMl[6]

									//Rafael - Comentado - INICIO
									/*
							 		nHandle := FCreate(cDestino+SubStr(aInfXMl[2],3,2)+cAnoInut+SubStr(aInfXMl[2],5,39)+"-ped-inu.xml")
						 			If nHandle > 0
							 			FWrite(nHandle,oXml:OWSNFECANCELADA:CXML)
							 			FClose(nHandle)
							 			aadd(aDeleta,oXml:cID)
							 		EndIf
									 */
									 //Rafael - Comentado - FIM

						 			nHandle := FCreate(cDestino+"\"+cAnoInut+SubStr(aInfXMl[2],5,39)+".xml")
						 			If nHandle > 0
							 			FWrite(nHandle,cXmlProt)
							 			FClose(nHandle)
							 		EndIf
							 		cNFes+=SubStr((cAlias)->&cCmpSer,1,3)+"/"+(cAlias)->&cCmpNum+CRLF
								endif
								//Cancelamento
								//Rafael - Comentado - INICIO
								/*
								if !Empty( aInfXMl[4] )
									cXml    := SpecCharc(aInfXMl[4])
						 			nHandle := FCreate(cDestino+SubStr(aInfXMl[2],3)+"-canc.xml")
						 			if nHandle > 0
										FWrite(nHandle,AllTrim(cXml))
							 			FClose(nHandle)
							 		endIf
							 		cNFes+=SubStr((cAlias)->&cCmpSer,1,3)+"/"+(cAlias)->&cCmpNum+CRLF
								endif
								*/
								//Rafael - Comentado - FIM

								if !Empty( aInfXMl[3] )
									cXml    := SpecCharc(aInfXMl[3])

					 				If lFisExpnfe
			                   			ExecBlock("FISEXPNFE",.f.,.f.,{cXML})
						 			EndIF

						 			nHandle := FCreate(cDestino+SubStr(aInfXMl[2],4)+"-"+cPrefix+".xml")
						 			if nHandle > 0
										FWrite(nHandle,AllTrim(cXml))
							 			FClose(nHandle)
							 		endIf

							 		cNFes+=SubStr((cAlias)->&cCmpSer,1,3)+"/"+(cAlias)->&cCmpNum+CRLF
								endif
							endif
							IncProc()
						 endif
					endif
        			(cAlias)->(dbSkip())
        		enddo
        		If !Empty(cNfes)
	        		If Aviso("SPED","STR0152",{"STR0661","STR0662"}) == 1	//"Solicita��o processada com sucesso.", "SPED" = "SPED", "STR0661" =  "Sim". "STR0662" =  "N�o"
						Aviso("STR0126","STR0151"+" "+Upper(cDestino)+CRLF+CRLF+cNFes,{"STR0114"},3)//"STR0151"-"XML Exportados para", "XML's Exportados para"
					EndIf
				endif
				delclassintf()
			else
				//Exportacao de XML e/ou PDF de CCe
				CCeExpoArq(cOpcExp, cDestino, cIdEnt, cChvIni, cChvFin)
				delclassintf()
			endif
		EndIf
		If select (cAlias)>0
			(cAlias)->(dbCloseArea())
		EndIf
		lFlush := .F.
	EndIF
EndDo

Return (.T.)







/*/{Protheus.doc} ValAtrib
Fun��o utilizada para substituir o type onde n�o seja possiv�l a sua retirada para n�o haver  
ocorrencia indevida pelo SonarQube.
/*/
//-----------------------------------------------------------------------
static Function ValAtrib(atributo)
Return (type(atributo) )




//--------------------------------------------------------------------------------------------
/*/{Protheus.doc} SpecCharc
Fun��o que retira os caracteres especiais de um texto

@author Leonardo Kichitaro
@since 01.04.2014
@version 1.00

@param	cTexto			Texto para retirar caracteres especiais

@return	cTexto			Texto sem caracteres especiais

/*/
//--------------------------------------------------------------------------------------------
Static Function SpecCharc(cTexto)

Local nI		:= 0
Local aCarac 	:= {}

Aadd(aCarac,{"�","A"})
Aadd(aCarac,{"�","A"})
Aadd(aCarac,{"�","A"})
Aadd(aCarac,{"�","A"})
Aadd(aCarac,{"�","a"})
Aadd(aCarac,{"�","a"})
Aadd(aCarac,{"�","a"})
Aadd(aCarac,{"�","a"})
Aadd(aCarac,{"�","E"})
Aadd(aCarac,{"�","E"})
Aadd(aCarac,{"�","e"})
Aadd(aCarac,{"�","e"})
Aadd(aCarac,{"�","I"})
Aadd(aCarac,{"�","i"})
Aadd(aCarac,{"�","O"})
Aadd(aCarac,{"�","O"})
Aadd(aCarac,{"�","O"})
Aadd(aCarac,{"�","o"})
Aadd(aCarac,{"�","o"})
Aadd(aCarac,{"�","o"})
Aadd(aCarac,{"�","U"})
Aadd(aCarac,{"�","u"})
Aadd(aCarac,{"�","C"})
Aadd(aCarac,{"�","c"})


// Ignora caracteres Extendidos da tabela ASCII
For nI := 128 To 255
	Aadd(aCarac,{Chr(nI)," "})  // Tab
Next nI

For nI := 1 To Len(aCarac)
	If aCarac[nI, 1] $ cTexto
		cTexto := StrTran(cTexto, aCarac[nI,1], aCarac[nI,2])
	EndIf
Next nI

Return cTexto

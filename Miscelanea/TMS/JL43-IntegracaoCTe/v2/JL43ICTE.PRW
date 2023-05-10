#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.ch'
#INCLUDE 'TOPCONN.CH'
#INCLUDE 'TMSAE80.CH'
#INCLUDE "FWCOMMAND.CH"
#INCLUDE "FILEIO.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "FWLIBVERSION.CH"

/*/{Protheus.doc} User Function nomeFunction
    (long_description)
    @type  Function
    @author user
    @since 28/03/2023
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    /*/

User Function JLI43CTE()

   	Local aArea := GetArea()

	Private oSay := Nil

	If IsBlind()
		ConOut(">> JLI43CTE - Inicio Importação XML CT-e/NFS!")
		ImpXMLTMS()
		ConOut(">> JLI43CTE - Fim Importação XML CT-e/NFS!")
	Else
		FWMsgRun(, {|oSay| ImpXMLCTE(oSay) }, "Importação XML", "Processando arquivos...")
	EndIf

	RestArea(aArea)

Return


/*/{Protheus.doc} ImpXMLCTE
	(long_description)
	@type  Static Function
	@author user
	@since 15/12/2022
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
/*/

Static Function ImpXMLCTE(oSay)

	Local aFiles	:= {}
	Local aFilesPrc := {}
	Local lProc 	:= .T.
	Local nX		:= 1
	Local aEnvPA0	:= {}
	Local aRetPA0	:= {}
	Local cXMLOri	:= ""
	Local nLength	:= 0
	Local cError	:= ""
	Local cWarning	:= ""
	Local lCteCanc	:= .F.
	Local lCte		:= .F.
	Local lCont		:= .F.
	Local lConvAsc	:= FindFunction("ConvAsc")
	Local cCodFil 	:= '01'
	Local cCodEmp 	:= '01'
//	Local cCGCSA1	:= ""
	Local cArqXML	:= ""
	Local nProc		:= 0
	Local cNomRem	:= ''
//	Local lArq		:= .T.
	Local cOrigem	:= ""
	Local cDesc		:= ""
    Local cNFeId    := ""
	Local cCGCRem   := ""

	Private oFullXML
	Private DirXml	:= "XMLCTE\"
	Private DirNew  := DirXml + "NEW\"
	Private DirOld  := DirXml + "OLD\"
	Private DirErr  := DirXml + "ERR\"
	Private aLogImp	:= {}
	Private cMsgProc:= ""
	Private cRetProc:= ""

	Default cCodFil := '01'
	Default cCodEmp := '01'

	If IsBlind()
		RpcSetType(3)
		lCont := RpcSetEnv(cCodEmp,cCodFil,,,"TMS","JL43ICTE")
		If !lCont
			Conout("JL43ICTE-Não foi possivel acessar ambiente. Empresa: " + cCodEmp + " - Filial: " + cCodFil)
			Return
		EndIf
	EndIf

	If !ExistDir(DirXml)
		MakeDir(DirXml)
		MakeDir(DirNew)
		MakeDir(DirOld)
		MakeDir(DirErr)
	EndIf

	//While lArq

		aFilesPrc := {}
		aFiles 	  := Directory("\" + DirNew + "*.xml")

		For nX := 1 To Len(aFiles)

			nProc++

			cCGCRem := ""
			cNomRem	:= ""
			cArqXML := ""
			cXml 	:= ""
			cXMLOri := ""
			lCteCanc:= .F.
			lCte	:= .F.
			lGrvArq := .T.
			cChvDoc := ""
			cStat	:= ""
			cMsgProc:= ""
			aLogImp	:= {}
			lNFS 	:= .F.

			cArqXML := aFiles[nX][1]

			If File(DirNew + cArqXML) .And. MayIUseCode(cArqXML) // LockByName(aFiles[nX,1], .T., .F.)	

				nHandle := FOpen(DirNew + cArqXML) // aFiles[nX,1])
				nLength := FSeek(nHandle,0,FS_END)

				FSeek(nHandle,0)

				If nHandle > 0

					FRead(nHandle, cXMLOri, nLength)
					FClose(nHandle)

					If !Empty(cXMLOri)

						If SubStr(cXMLOri,1,1) != "<"
							nPosPesq := At("<",cXMLOri)
							cXMLOri  := SubStr(cXMLOri,nPosPesq,Len(cXMLOri))	// Remove caracteres estranhos antes da abertura da tag inicial do arquivo
						EndIf

						cXML := DecodeUTF8(cXMLOri)

						If Empty(cXML)
							cXML := cXMLOri

							If lConvAsc
								cXML := ConvAsc(cXML) //remove acentuação
							EndIf

							cXML := u_JLRemASC(cXML)	//remove caracteres especiais não aceitos pelo encode
							cXML := EncodeUtf8(cXML)
						EndIf
					EndIf
				Endif

				If !Empty(cXML)

					TmsLogMsg(,"Leitura Arquivo: " + cArqXML )	// aFiles[nX,1])
					cRetProc := "Arquivo importado com sucesso "

					oFullXML := XmlParser(cXML,"_",@cError,@cWarning)

					//-- Erro na sintaxe do XML
					If Empty(oFullXML) .Or. !Empty(cError)
						cMsgProc := 'Erro de sintaxe no arquivo XML: ' + cArqXML  // cMsgProc
						//Copy File &(DirNew + aFiles[nX,1]) To &(DirErr + aFiles[nX,1])
						Copy File &(DirNew + cArqXML) To &(DirErr + cArqXML)
						Loop
					EndIf

					//-- So processa conhecimentos de transporte
					If ("<CTEPROC" $ Upper(cXML))		/// <cteProc
						lCte := .T.
					EndIf

					If lCte
						If(XmlChildEx ( oFullXML:_CTEPROC:_PROTCTE:_INFPROT,"_CSTAT") # Nil )
							cStat 	:= oFullXML:_CTEPROC:_PROTCTE:_INFPROT:_CSTAT:TEXT
							cChvDoc	:= oFullXML:_CTEPROC:_PROTCTE:_INFPROT:_CHCTE:TEXT
							cCGCEmit:= oFullXML:_CTEPROC:_CTE:_INFCTE:_EMIT:_CNPJ:TEXT
							cCGCRem := oFullXML:_CTEPROC:_CTE:_INFCTE:_REM:_CNPJ:TEXT
							dDatEmi := StoD(Padr(StrTran(AllTrim( oFullXML:_CTEPROC:_CTE:_INFCTE:_IDE:_DHEMI:Text),"-",""),8))
							cDoc 	:= SubStr(cChvDoc,26,9)
							cSerie 	:= StrZero(Val(SubStr(cChvDoc,23,3)),2)
                            cNFeId  := oFullXML:_CTEPROC:_CTE:_INFCTE:_INFCTENORM:_INFDOC:_INFNFE:_CHAVE:TEXT
						EndIf
					EndIf 

					If (!IsBlind())
						oSay:SetText("Arquivos Processados: " + cValToChar(nProc) + ' de ' + cValToChar(Len(aFilesPrc)))
						ProcessMessage()
					EndIf
                    
 					If !Empty(cCGCRem) //.And. cCGCRem != cCGCSA1
						SA1->(dbSetOrder(3))
						If SA1->(MsSeek(xFilial("SA1") + cCGCRem ))
							//cCGCSA1 := SA1->A1_CGC
							cNomRem := SA1->A1_NOME
						EndIf
					EndIf

					If cStat == '100'
						cOrigem := "INT001"
						cDesc	:= "IMPORTACAO CTE"
					EndIf

					PA0->(dbSetOrder(4))	// PA0_FILIA+PA0_CHAVE+PA0_ORIGEM
					If !PA0->(MsSeek(xFilial("PA0") + cChvDoc + cOrigem))

						aAdd(aEnvPA0,{"PA0_STATUS","1"		}) //-- Em aberto
						aAdd(aEnvPA0,{"PA0_TIPO"  ,"R"		})
						aAdd(aEnvPA0,{"PA0_CHAVE" ,cChvDoc	})
						aAdd(aEnvPA0,{"PA0_CGCEMI",cCGCEmit	})
						aAdd(aEnvPA0,{"PA0_FILDOC",cFilAnt	})
						aAdd(aEnvPA0,{"PA0_DOC"	  ,cDoc		})
						aAdd(aEnvPA0,{"PA0_SERIE" ,cSerie	})
						aAdd(aEnvPA0,{"PA0_NOMARQ",cArqXML	}) //aFiles[nX,1]})
						aAdd(aEnvPA0,{"PA0_MSGARQ",cXML		})
						aAdd(aEnvPA0,{"PA0_CGCREM",cCGCRem	})
						aAdd(aEnvPA0,{"PA0_NOMREM",cNomRem	})
						aAdd(aEnvPA0,{"PA0_DATEMI",dDatEmi	})
						aAdd(aEnvPA0,{"PA0_ORIGEM",cOrigem	})
						aAdd(aEnvPA0,{"PA0_DESCRI",cDesc	})
                        aAdd(aEnvPA0,{"PA0_NFEID" ,cNFeId	})

						aRetPA0 := aClone(u_JLINCPA0(aEnvPA0, cRetProc))
						lProc	:= aRetPA0[1]

					EndIf
				EndIf

				If lProc
					Copy File &(DirNew + cArqXML) To &(DirOld + cArqXML)
				else
					Copy File &(DirNew + cArqXML) To &(DirErr + cArqXML)
				EndIf

				FErase(DirNew + cArqXML)

			EndIf

			Leave1Code ( cArqXML )
			//UnLockByName(aFiles[nX,1], .T., .F.)		
			// FreeUsedCode()	

		Next nX
	//EndDo

	If IsBlind()
		RpcClearEnv()
	EndIf

Return 

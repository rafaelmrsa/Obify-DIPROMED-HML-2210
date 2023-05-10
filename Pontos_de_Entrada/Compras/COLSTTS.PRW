#include 'protheus.ch'
#include 'parmtype.ch'
#include "topconn.ch"
#INCLUDE "FWMVCDEF.CH"
#include "TbiConn.ch"


/*/{Protheus.doc} COLSTTS
Ponto de entrada para tratar a gravação das informações do frete nas notas fiscais de saída dos produtos transportados
@author Andre Mendes [Obify]
@since 27/07/2020
@version 1.0
@type function
@obs Chamado #5327 Campos a serem atualizados
    - F2_NROCON - Número do conhecimento
    - F2_PESOCTR - Peso real contido no CTR
    - F2_FRTDIP - Frete incluso valor pago
    - F2_FRETSZ3 - Frete calculo tabela SZ3

 
    
/*/
User function COLSTTS()

/*
    *** DEBUG ***
    Local cFilSDS := '04'
    Local cChaveCTE := '35220910245270000116570010003535281628820794'

    */
    Local cFilSDS := SDS->DS_FILIAL
    Local cChaveCTE := SDS->DS_CHAVENF
    Local nNota
    Local aAreaSF2
    Local aAreaSD2
    Local aAreaSC5
    Local aArea
    Local cFilSF2
    Local cFilSC5
    Local cFilSD2

    

/*
    *** DEBUG ***

    Local aParam := {'01',cFilSDS}
*/
    Private nSF2FretSZ3 := 0
    Private nSF2PesoBr  := 0        
    Private aDipInfNf   := {}
    Private aRecRat := {}
/*
    *** DEBUG ***
    RpcSetType(3)
	RpcSetEnv(aParam[1],aParam[2],,,"FAT")
*/
    aAreaSF2 := SF2->(GetArea())
    aAreaSD2 := SD2->(GetArea())
    aAreaSC5 := SC5->(GetArea())
    aArea := GetArea()
    cFilSF2  := xFilial('SF2') 
    cFilSC5  := xFilial('SC5')
    cFilSD2  := xFilial('SD2') 
  
    //Chave única SDS ===> DS_FILIAL, DS_CHAVENF, R_E_C_D_E_L_
    aDipInfNf := fRetNFs(cFilSDS, cChaveCTE)


    For nNota := 1 to Len(aDipInfNf)	
				
		If SF2->( Dbseek(cFilSF2  + aDipInfNf[nNota][01]) )
            SD2->(DbSetOrder(3))// D2_FILIAL, D2_DOC, D2_SERIE, D2_CLIENTE, D2_LOJA, D2_COD, D2_ITEM
		    SD2->( Dbseek(cFilSD2 + aDipInfNf[nNota][01]) )
		   	SC5->( Dbseek(cFilSC5 + SD2->D2_PEDIDO) )
			//----------------------------------------------------------------------------
			// Calcula o valor do frete proporcional em cada nota agrupada no CTRC e grava
			// este valor no Campo F2_FRETSZ3.
			//----------------------------------------------------------------------------
			U_ClcLimite("NF",SF2->F2_VALBRUT,SF2->F2_PBRUTO,,.t.)        
			//----------------------------------------------------------------------------
			// Acucula o total de Frete Calculado para ratear o desconto
			//----------------------------------------------------------------------------
			nSF2FretSZ3 += SF2->F2_FRETSZ3 
			nSF2PesoBr  += SF2->F2_PBRUTO
		EndIf 

    Next

    fGravaNFS(aDipInfNf)

    
    


    
    RestArea(aArea)
    SF2->(RestArea(aAreaSF2))
    SD2->(RestArea(aAreaSD2))
    SC5->(RestArea(aAreaSC5))
/*
    *** DEBUG ***
    RpcClearEnv()
*/
RETURN


/*/{Protheus.doc} fRetNFs
retorna as notas fiscais relacionadas com a nota de frete
@author Andre Mendes [Obify]
@since 27/07/2020
@version 1.0
@type function
@obs 
 
    
/*/
Static Function fRetNFs(cFilSDS, cChaveCTE)
    Local aRet := {}
    Local oXMLPE
    Local aArea := GetArea()
    Local aAreaSDS := SDS->(GetArea())
    Local aNF :={}
    Local nF
    Local cChaveNF
    Local aDoc :={}
    Local cSerie
    Local cDoc
    Local nPesoCTE
    Local nValorCTE
    Local cNumCTE
    Local nInfo
    Local nValDesc



    SDS->(DbSetOrder(2)) //DS_FILIAL, DS_CHAVENF, R_E_C_N_O_, D_E_L_E_T_

    If SDS->(DbSeek(cFilSDS+cChaveCTE))

        oXMLPE := COMCOLXML(SDS->DS_FILIAL,SDS->DS_DOC,SDS->DS_SERIE,SDS->DS_FORNEC,SDS->DS_LOJA)


        aNF := oXMLPE:_cteProc:_CTe:_infCte:_infCTeNorm:_infDoc:_infNFe

        If Valtype(aNF) == "A"
            For nF := 1 To Len(aNF)
    
                cChaveNF := aNF[nF]:_chave:text

                aDoc := fRetDoc(cChaveNF)
                If Len(aDoc) > 0
                    cSerie := aDoc[01][02]
                    cDoc := aDoc[01][03]

                Endif

                nInfo := aScan( oXMLPE:_cteProc:_CTe:_infCte:_infCTeNorm:_infCarga:_infQ, { | x | x:_tpMed:text =="PESO BASE DE CALCULO" })

                If nInfo    > 0

                    nPesoCTE := Val(oXMLPE:_cteProc:_CTe:_infCte:_infCTeNorm:_infCarga:_infQ[nInfo]:_qCarga:text)
                Endif

                nValorCTE := Val(oXMLPE:_cteProc:_CTe:_infCte:_vPrest:_vTPrest:text)
                nValDesc := 0

                cNumCTE := oXMLPE:_cteProc:_CTe:_infCte:_ide:_nCT:text
                cNumCTE := StrZero(val(cNumCTE),9)



                aAdd(aRet,{cDoc+cSerie, nPesoCTE, nValorCTE, nValDesc, cNumCTE, nPesoCTE})

            Next nF

        elseif Valtype(aNF) == "O"
                cChaveNF := oXMLPE:_cteProc:_CTe:_infCte:_infCTeNorm:_infDoc:_infNFe:_chave:text

                aDoc := fRetDoc(cChaveNF)
                If Len(aDoc) > 0
                    cSerie := aDoc[01][02]
                    cDoc := aDoc[01][03]

                Endif

                nInfo := aScan( oXMLPE:_cteProc:_CTe:_infCte:_infCTeNorm:_infCarga:_infQ, { | x | x:_tpMed:text =="PESO BASE DE CALCULO" })

                If nInfo    > 0

                    nPesoCTE := Val(oXMLPE:_cteProc:_CTe:_infCte:_infCTeNorm:_infCarga:_infQ[nInfo]:_qCarga:text)
                Endif

                nValorCTE := Val(oXMLPE:_cteProc:_CTe:_infCte:_vPrest:_vTPrest:text)
                nValDesc := 0

                cNumCTE := oXMLPE:_cteProc:_CTe:_infCte:_ide:_nCT:text
                cNumCTE := StrZero(val(cNumCTE),9)



                aAdd(aRet,{cDoc+cSerie, nPesoCTE, nValorCTE, nValDesc, cNumCTE, nPesoCTE})


        else
            
            MsgInfo("Nao foi possivel extrair as informacoes do XML CT-e para atualiza os dados das notas.", "Aviso")
        Endif

        //oXMLPE:_CteProc:_CTe:_InfCte:_infCTeNorm:_infDoc:_infNFe:_Chave:text


        /*

        



        select * from SDS010
sp_help CKOCOL
select CKO_XMLRET from CKOCOL where CKO_ARQUIV = '214_cte_000000000000011931.xml                                                  '



select * from SF2010 where F2_CHVNFE  = '35220847869078000100550030003773241223501210'




*/
    Endif
    SDS->(RestArea(aAreaSDS))
    RestArea(aArea)
Return aRet



//-------------------------------------------------------------------
/*/{Protheus.doc} COMCOLXML
Busca XML do documento a ser importado

@author	rodrigo.mpontes
@since		18/05/2021
@version	12.1.17
/*/
//-------------------------------------------------------------------   

Static Function COMCOLXML(cFilSDS,cDoc,cSerie,cFornece,cLoja)

    Local oXMLCKO	:= Nil
    Local aArea		:= GetArea() 
    Local cQry		:= ""
    Local cQXML		:= GetNextAlias()
    Local cXML		:= ""
    Local cXMLEncod	:= ""
    Local cError	:= ""
    Local cWarning	:= ""
    Local nPosPesq	:= 0

    cQry	:= " SELECT DS_ARQUIVO" 
    cQry 	+= " FROM " + RetSqlName("SDS") + " SDS"
    cQry	+= " WHERE SDS.DS_FILIAL = '" + cFilSDS + "' " 
    cQry	+= " AND SDS.DS_DOC = '" + cDoc + "' "
    cQry	+= " AND SDS.DS_SERIE = '" + cSerie + "' "
    cQry	+= " AND SDS.DS_FORNEC = '" + cFornece + "' "
    cQry	+= " AND SDS.DS_LOJA = '" + cLoja + "' "
    cQry	+= " AND SDS.D_E_L_E_T_ = ' '"

    cQry := ChangeQuery(cQry)

    dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQry),cQXML,.T.,.T.)

    If (cQXML)->(!EOF())
        cXML := GetAdvFval("CKO","CKO_XMLRET",alltrim((cQXML)->DS_ARQUIVO),1)

        If !Empty(cXML)
            If !Empty(cXML)
                If SubStr(cXML,1,1) != "<"
                    nPosPesq := At("<",cXML)
                    cXML  := SubStr(cXML,nPosPesq,Len(cXML))		// Remove caracteres estranhos antes da abertura da tag inicial do arquivo
                EndIf
            EndIf

            cXMLEncod := EncodeUtf8(cXML)

            If Empty(cXMLEncod)
                cXMLEncod 	:= cXML
                cXML 		:= A140IRemASC(cXMLEncod)
                cXMLEncod 	:= EncodeUtf8(cXML)
            EndIf

            If !Empty(cXMLEncod)
                oXMLCKO := XmlParser(cXMLEncod,"_",@cError,@cWarning)
            EndIf
        Endif
    Endif

    (cQXML)->(DbCloseArea())

    RestArea(aArea) 

Return oXMLCKO

/*/{Protheus.doc} fRetDoc
retorna filial, série e número da NF referente a uma chave NF
@author Andre Mendes [Obify]
@since 26/10/2022
@version 1.0
@type function
@obs 
 
    
/*/
Static Function fRetDoc(cChaveNF)
    Local aRet := {}
    Local aArea		:= GetArea() 
    Local cQry		:= ""
    Local cAlias		:= GetNextAlias()

    cQry	:= " SELECT F2_FILIAL, F2_SERIE, F2_DOC  from " + RetSqlName("SF2") + " where F2_CHVNFE= '"+cChaveNF+"' AND D_E_L_E_T_ = ''" 

    dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQry),cAlias,.T.,.T.)

    If (cAlias)->(!EOF())
        aAdd(aRet, {(cAlias)->F2_FILIAL,(cAlias)->F2_SERIE,(cAlias)->F2_DOC })
    Endif
    RestArea(aArea) 
Return  aRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³fGravaNFS()ºAutor ³Jailton B Santos-JBSº Data ³ 24/02/2010  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Apos atualizar o valor do frete Calculado na Dipromed, faz º±±
±±º          ³ o rateio do desconto total do frete do CTRC, entre as notasº±±
±±º          ³ que compoem o CTRC.                                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Especifico - FATURAMENTO - Dipromed                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static function fGravaNFS(aDipInfNf)
//--------------------------------------------------------------------------------
Local lRet      := .F.
Local nId       := 0

//--------------------------------------------------------------------------------
SF2->( DbSetOrder(1) )
//--------------------------------------------------------------------------------
For nId:=1 to Len(aDipInfNf)   
	//--------------------------------------------------------------------------------
    // Localiza a nota fiscal
	//--------------------------------------------------------------------------------
	If SF2->( DbSeek(xFilial('SF2') + aDipInfNf[nId][1]) )
	    //--------------------------------------------------------------------------------
		SF2->( Reclock("SF2",.F.))
	    //--------------------------------------------------------------------------------
	    // Rateia o desconto do CTRC entre as notas fiscais que compoem o CTRC.
	    //--------------------------------------------------------------------------------
		If SF2->F2_TPFRETE $ 'CI' .and.; // Só atualiza o Frete se o tipo for CIF ou Incluso.
		   SF2->F2_FRTDIP = 0             // Valor do Frete Ainda não preenchido  
		   SF2->F2_FRTDIP := SF2->F2_FRETSZ3 / nSF2FretSZ3 * (aDipInfNf[nId][3] - aDipInfNf[nId][4])
		
		 AADD(aRecRat,{cValToChar(SF2->(Recno()))})  //Giovani Zago 21/11/11
	   EndIf 
	    //--------------------------------------------------------------------------------
	    // Grava o Numero do Conhecimento, na Nota Fiscal
	    //--------------------------------------------------------------------------------
		SF2->F2_NROCON  := aDipInfNf[nId][5]
		//SF2->F2_PESOCTR := aDipInfNf[nId][6]
        SF2->F2_PESOCTR := If(Len(aDipInfNf)>1,SF2->F2_PBRUTO/nSF2PesoBr*(aDipInfNf[nId][2]),aDipInfNf[nId][2])
	    //--------------------------------------------------------------------------------
		SF2->(MsUnlock("SF2"))
	    //--------------------------------------------------------------------------------
        lRet := .F.
	    //--------------------------------------------------------------------------------
	EndIf
Next nId
Return(lRet)

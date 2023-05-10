#Include "Protheus.ch"
#Include "RwMake.ch"
#Include "TbiConn.ch"

////////////////////////////////////////////////////////////////////////////////
//                                                                            //
//  Programa ...: A140IQTD                             Modulo : SIGACOM       //
//                                                                            //
//  Autor ......: Rafael Rosa				           Data ..: 24/02/23      //
//                                                                            //
//  Descricao ..: PE tratar a segunda unidade de medida personalizada no      //
//                no cadastro Produtos X Fornecedores                         //
//                                                                            //
//  Uso ........: Especifico DIPROMED   	                                  //
//                                                                            //
//  Observacao .: Opera com os campos personalizados em SA5, sendo eles:      //
//                A5_XTIPCON M-Multiplicador D-Divisor      				  //
//                A5_XFATCON Fator de Conversao                               //
//                                                                            //
////////////////////////////////////////////////////////////////////////////////

User Function A140IQTD()

Local cProduto := PARAMIXB[1]
//Local cUM := PARAMIXB[2]
//Local cSEGUM := PARAMIXB[3]
Local nQtSEGUM := PARAMIXB[4]
Local nQtdeIt := PARAMIXB[5]
Local nPrcIt := PARAMIXB[6]
Local nTotIt := PARAMIXB[7]
//Local lConvUM := PARAMIXB[8]

Local cForn := PARAMIXB[9]
Local cLoja := PARAMIXB[10]
//Local cDoc := PARAMIXB[11]
//Local nSerie := PARAMIXB[12]
//Local nTipo := PARAMIXB[13]
//Local lA5A7 := PARAMIXB[14]
//Local oXML := PARAMIXB[15]

Local aRet := Array(4)

dbSelectArea('SA5')
SA5->(dbSetOrder(1))
SA5->(dbSeek(xFilial("SA5")+cForn+cLoja+cProduto))
    IF FOUND()
        IF SA5->A5_UMNFE = "2"
            IF SA5->A5_XTIPCON = "M"
                nQtdeIt := nQtSEGUM * SA5->A5_XFATCON

            ELSEIF SA5->A5_XTIPCON = "D"
                nQtdeIt := nQtSEGUM / SA5->A5_XFATCON
            ENDIF

            nPrcIt      := nTotIt / nQtdeIt
        ENDIF
    ENDIF
SA5->(dbSkip())

aRet[1] := nQtdeIt
aRet[2] := nPrcIt
aRet[3] := nTotIt
aRet[4] := nQtSEGUM

Return aRet

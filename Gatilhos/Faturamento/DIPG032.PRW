#INCLUDE "PROTHEUS.CH"
//GATILHO PARA RETORNAR O VALOR DA ST NO CAMPO CUSTOMIZADO
User Function DIPG032()
Local aArea     := GetArea()
Local nNritem   := 0
Local nItem     := 1
Local nQtde     := 0
Local nVal_Fre  := M->C5_FRETE
Local cEST      := M->C5_ESTE
Local cTPCLI    := M->C5_TIPOCLI
Local nAtu      
Default cNumPed := M->C5_NUM

If Alltrim(cEST) <> "SP" .and. AllTrim(cTPCLI) == "R"

        MaFisIni(M->C5_CLIENTE,;                    // 1-Codigo Cliente/Fornecedor
                M->C5_LOJACLI,;                    // 2-Loja do Cliente/Fornecedor
                If(M->C5_TIPO$'DB',"F","C"),;               // 3-C:Cliente , F:Fornecedor
                M->C5_TIPO,;                                // 4-Tipo da NF
                M->C5_TIPOCLI,;                           // 5-Tipo do Cliente/Fornecedor
                MaFisRelImp("MT100",{"SF2","SD2"}),;        // 6-Relacao de Impostos que suportados no arquivo
                ,;                                               // 7-Tipo de complemento
                ,;                                            // 8-Permite Incluir Impostos no Rodape .T./.F.
                "SB1",;                                        // 9-Alias do Cadastro de Produtos - ("SBI" P/ Front Loja)
                "MATA461")                                    // 10-Nome da rotina que esta utilizando a funcao
        //nNritem := Len(aCols)
        nQtde   := aCols[n][GDFieldPos("C6_QTDVEN")]

        SB1->(DbSeek(xFilial("SB1")+aCols[n][GDFieldPos("C6_PRODUTO")]))
        MaFisAdd(aCols[n][GDFieldPos("C6_PRODUTO")],;                    // 1-Codigo do Produto                 ( Obrigatorio )
                aCols[n][GDFieldPos("C6_TES")],;                         // 2-Codigo do TES                     ( Opcional )
                aCols[n][GDFieldPos("C6_QTDVEN")],;                      // 3-Quantidade                     ( Obrigatorio )
                aCols[n][GDFieldPos("C6_PRCVEN")],;                      // 4-Preco Unitario                 ( Obrigatorio )
                aCols[n][GDFieldPos("C6_VALDESC")],;                     // 5 desconto
                aCols[n][GDFieldPos("C6_NFORI")],;                       // 6-Numero da NF Original             ( Devolucao/Benef )
                aCols[n][GDFieldPos("C6_SERIORI")],;                     // 7-Serie da NF Original             ( Devolucao/Benef )
                0,;                                                      // 8-RecNo da NF Original no arq SD1/SD2
                0,;                                                      // 9-Valor do Frete do Item         ( Opcional )
                0,;                                                      // 10-Valor da Despesa do item         ( Opcional )
                0,;                                                      // 11-Valor do Seguro do item         ( Opcional )
                0,;                                                         // 12-Valor do Frete Autonomo         ( Opcional )
                aCols[n][GDFieldPos("C6_VALOR")],;                       // 13-Valor da Mercadoria             ( Obrigatorio )
                0,;                                                         // 14-Valor da Embalagem             ( Opcional )
                0,;                                                         // 15-RecNo do SB1
                0)                                                          // 16-RecNo do SF4
        //Pegando totais
        //nTotIPI   := MaFisRet(,'NF_VALIPI')
        //nTotICM   := MaFisRet(,'NF_VALICM')
        //nTotNF    := MaFisRet(,'NF_TOTAL')
        //nTotFrete := MaFisRet(,'NF_FRETE')
        //nTotISS   := MaFisRet(,'NF_VALISS')   
        //nValST    := MaFisRet(nAtu,"IT_VALSOL")
        aCols[n][GDFieldPos("C6_XICMSRE")] := MaFisRet(nItem,"IT_VALSOL")
        MaFisEnd()
else
        nQtde   := aCols[n][GDFieldPos("C6_QTDVEN")]
ENDIF
RestArea(aArea)
Return(nQtde)

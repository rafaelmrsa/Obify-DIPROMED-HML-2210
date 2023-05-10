#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ MT103FIM      ºAutor  ³Rafael Rosa    º Data ³  15/12/22   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Atualiza data da validade do lote informado nos itens      º±±
±±º          ³ da nota fiscal de entrada.                                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Especifico DIPROMED                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function MT103FIM()

//Local nOpcao    := PARAMIXB[1]
//Local nConfirma := PARAMIXB[2]
Local cQuery        := ""

If "MATA103" $ FunName()

     cQuery := "SELECT D1_COD, D1_LOCAL, D1_LOTECTL, D1_DTVALID FROM "+RetSqlName("SD1")+" D1 "
     cQuery += "WHERE D1.D_E_L_E_T_ = '' AND D1.D1_FILIAL = '"+XFILIAL("SD1")+"' "
     cQuery += "AND D1.D1_DOC = '"+SF1->F1_DOC+"' AND D1.D1_SERIE = '"+SF1->F1_SERIE+"' AND D1.D1_FORNECE = '"+SF1->F1_FORNECE+"' AND D1.D1_LOJA = '"+SF1->F1_LOJA+"' AND D1_LOTECTL <> ''"
     dbUseArea(.T., 'TOPCONN', TCGenQry(,,cQuery),'TSD1', .F., .T.)
     cQuery := ChangeQuery(cQuery)

    WHILE TSD1->(!EOF())
        //IF Posicione("SF4",1,xFilial("SF4")+TSD1->D1_TES,"F4_DUPLIC") = "S"

            DbSelectArea("SB8")
            SB8->(DbSetOrder(3))
            IF SB8->(dbSeek(xFilial("SB8") + TSD1->D1_COD + TSD1->D1_LOCAL + TSD1->D1_LOTECTL))		
                SB8->(RecLock("SB8", .F.))
                    SB8->B8_DTVALID  := STOD(TSD1->D1_DTVALID)
                SB8->(MsUnlock())
            ENDIF
            SB8->(dbSkip())

        //ENDIF
        TSD1->(DBSKIP())
    ENDDO
    TSD1->(DBCLOSEAREA())

ENDIF

Return

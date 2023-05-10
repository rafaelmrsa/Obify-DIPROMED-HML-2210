#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'TOTVS.CH'
#INCLUDE "RWMAKE.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ TMA050FIM º Autor ³ Marcos Holando    º Data ³ 01/12/2021   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Este Ponto de Entrada, localizado no TMSA050(Notas Fiscais  º±±
±±º          ³ dos Clientes), é utilizado na função A050AtuEDI desta       º±±
±±º          ³ rotina, para atualização de campos de usuário da tabela DTC º±±
±±º          ³ nos casos de notas fiscais EDI.                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Emovere / Dipromed	                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function TMA050FIM()

	Local aArea     := GetArea()
	Local aAreaDTC  := DTC->(GetArea())
	Local aAreaDE5  := DE5->(GetArea())
	Local nOpc 		:= PARAMIXB
	Local cLotNfc 	:= ""
	Local cAliasDUY := ""
	Local cQuery    := ""
	Local cCliRem	:= ""
	Local cLojRem	:= ""
	Local cNumNfc	:= ""
	Local cSerieNfc	:= ""

	Private cFunName:= Upper(AllTrim(FunName()))	

	If IsInCallStack("TMSAE75") .Or. cFunName $ "TMSAE75"


		cAliasDE5 	:= GetNextAlias()
		cLotNfc		:= DTC->DTC_LOTNFC
		cNumNfc		:= DTC->DTC_NUMNFC
		cSerieNfc	:= DTC->DTC_SERNFC

		cQuery := "SELECT DE5_FILIAL, DE5_LOTNFC, DE5_CGCREM, DE5_DOC, DE5_SERIE, DE5_SEQEND, "
		cQuery += "  DE5_TIPNFC, DE5_TIPANT, DE5_DPCEMI, DE5_CTEANT, DE5_CTRDPC, DE5_SERDPC, DE5_FRTSUB "
		cQuery += "  FROM " + RetSqlName("DE5") + " DE5  (NOLOCK) "
		cQuery += "  WHERE DE5_FILIAL = '" + xFilial("DE5") + "' "
		cQuery += "  AND DE5_LOTNFC = '" + cLotNfc + "' "
		//cQuery += "  AND DE5_DOC = '" + cNumNfc + "' "
		//cQuery += "  AND DE5_SERIE = '" + cSerieNfc + "' "
		cQuery += "  AND DE5.D_E_L_E_T_ = ' '"

		cQuery := ChangeQuery(cQuery)
		DBUseArea(.t.,"TOPCONN",TCGENQRY(,,cQuery),cAliasDE5,.t.,.t.)

		While !(cAliasDE5)->(Eof())
		//IF !(cAliasDE5)->(Eof())

			cNumNfc := (cAliasDE5)->DE5_DOC
			cSerNfc	:= (cAliasDE5)->DE5_SERIE

			SA1->(dbSetOrder(3))	// A1_FILIAL+A1_CGC
			If SA1->(MsSeek(xFilial("SA1") + (cAliasDE5)->DE5_CGCREM))

				cCliRem := SA1->A1_COD
				cLojRem	:= SA1->A1_LOJA

				DTC->(dbSetOrder(5))	// DTC_FILIAL+DTC_CLIREM+DTC_LOJREM+DTC_NUMNFC+DTC_SERNFC
				If DTC->(MsSeek(xFilial("DTC") + cCliRem + cLojRem + cNumNfc + cSerNfc  ))
					Reclock("DTC",.F.)
					DTC->DTC_SQEDES := (cAliasDE5)->DE5_SEQEND

						nPos := DTC->(FieldPos("DTC_TIPNFC"))    //Ascan(aHeader,{|x| AllTrim(x[2]) == 'DTC_PLACA'})

						If !Empty(DE5->DE5_TIPNFC)
							DTC->DTC_TIPNFC := (cAliasDE5)->DE5_TIPNFC
						Endif

						If !Empty(DE5->DE5_TIPANT)
							DTC->DTC_TIPANT := (cAliasDE5)->DE5_TIPANT
						Endif

						If !Empty(DE5->DE5_DPCEMI)
							DTC->DTC_DPCEMI := STOD((cAliasDE5)->DE5_DPCEMI)
						Endif

						If !Empty(DE5->DE5_CTEANT)
							DTC->DTC_CTEANT := (cAliasDE5)->DE5_CTEANT
						Endif

						If !Empty(DE5->DE5_CTRDPC)
							DTC->DTC_CTRDPC := (cAliasDE5)->DE5_CTRDPC
						Endif

						If !Empty(DE5->DE5_SERDPC)
							DTC->DTC_SERDPC := (cAliasDE5)->DE5_SERDPC
						Endif

						If !Empty(DE5->DE5_FRTSUB)
							DTC->DTC_FRTSUB := (cAliasDE5)->DE5_FRTSUB
						Endif

					DTC->(MsunLock())
				EndIf
			EndIf
			

			(cAliasDE5)->(dbSkip())
		//Endif
		EndDo

		(cAliasDE5)->(dbCloseArea())

	EndIf

	RestArea(aAreaDTC)
	RestArea(aAreaDE5)
	RestArea(aArea)

Return Nil


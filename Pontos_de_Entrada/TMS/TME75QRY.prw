#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'TOTVS.CH'

User Function TME75QRY()

	Local aArea		:= GetArea()
	Local aAreaDE5	:= DE5->(GetArea())
	Local cCGCRem  	:= PARAMIXB[1]	//	CGC do Remetente
	Local cNumNfc   := PARAMIXB[2]	// 	Número do Documento 
	Local cSerNFc   := PARAMIXB[3]	//	Serie do Documento 
	Local cCodProd  := PARAMIXB[4]	//	Código do Produto 
	Local nRecnoDE5 := PARAMIXB[5]	//	Recno
	Local cAliasQry := PARAMIXB[6]	// 	Alias da query
	Local lRet      := .F.

	If nRecnoDE5 > 0
	
		DE5->(dbSetOrder(1))
		DE5->( DbGoto(nRecnoDE5) )
		
		If DE5->DE5_EMINFC >= MV_PAR06 .AND. DE5->DE5_EMINFC <= MV_PAR07
			lRet      := .T.
		EndIf

	EndIf

	RestArea(aAreaDE5)
	RestArea(aArea)

Return lRet

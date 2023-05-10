/*====================================================================================\
|Programa  | PRENOTA_d     | Autor | Eriberto Elias             | Data | 02/07/2002   |
|=====================================================================================|
|Descrição | Emissao da Pre-Nota DIRETO                                               |
|=====================================================================================|
|Sintaxe   | PRENOTA_d                                                                |
|=====================================================================================|
|Uso       | Especifico DIPROMED                                                      |
|=====================================================================================|
|........................................Histórico....................................|
|Eriberto  | DD/MM/AA - Descrição                                                     |
|Rafael    | 18/01/05 - Adicionado função de envio de e-mail para Subst. Tributária   |
|Rafael    | 06/04/05 - Adicionado função de envio de e-mail para PV lib. por SENHA   |
\====================================================================================*/

#include "rwmake.ch"
#INCLUDE "AP5MAIL.CH"
User Function PreNota_D(cPedido,cProg)

Local aArea		:= GetArea()
Local cVal_STD	:= ""
Local aMsg		:= {}
Local aMsg1		:= {}
Local lParadoFin := .f.

U_DIPPROC(ProcName(0),U_DipUsr()) // JBS 05/10/2005 - Gravando o nome do Programa no SZU
Private cPorta  := Left(Upper(AllTrim(GETMV("MV_LPT_PRE"))),4) // JBS 21/10/2005
Private cCaminho:= Upper(AllTrim(GETMV("MV_LPT_PRE"))) // JBS 21/10/2005
Private _lMenu  := .f.  // JBS 05/01/2006
Private cTime := Time() // JBS 04/07/2006


	// Emite normalmente a Pré-Nota
	WaitRun("NET USE "+cPorta+" /DELETE YES")  // JBS 18/10/2005
	WaitRun("NET USE "+cCaminho)  // JBS 18/10/2005

 
li := 66
nItens := 0
_nValorTotal := 0
lRodape:= .F.
lCred2 := .F.
_lproblema := .f.

DbSelectArea("SDC")
DbSetOrder(4)
nItens := 0
If DbSeek(xFilial("SDC")+cPedido)
	
	nRegistro := RECNO()
	
	Do While !Eof() .And. SDC->DC_PEDIDO == SC5->C5_NUM
		nItens := nItens + 1
		dbSkip()
	EndDo
EndIf
nPags := Iif(nItens<=18,1,Int((nItens+18)/18))
nPag  := 1

aBom = 0

If nItens = 0
	DbSelectArea("SC9")
	DbSetOrder(1)
	If DbSeek(xFilial("SC9")+cPedido)
		Do While !Eof() .And. SC9->C9_PEDIDO == cPedido
			If Empty(SC9->C9_BLEST) .AND. Empty(SC9->C9_BLCRED2) .AND. Empty(SC9->C9_PARCIAL)
				aBom++
			Else  // vamos atualizar lcred2 e lparadofin 
				Iif(!Empty(SC9->C9_BLCRED2),lParadoFin := .t.,)
			EndIF
			DbSkip()
		EndDo
	EndIf
	If aBom > 0
		Set Device To Print
		Set Printer to &cPorta
		PrinterWin(.F.) // Impressao Dos/Windows
		PreparePrint(.F., "", .F., cPorta) // Prepara a impressao na porta especificada
		#IFDEF WINDOWS
			initprint(1) // 1=Impressora cliente e 2=Impressora Server
		#ENDIF
		
		U_ImpCab_D()
		U_ImpItem_D()
		U_ImpRod_D()
		lCred2 := .T.
	EndIf
Else
	DbSelectArea("SDC")
	DbSetOrder(4)
	If DbSeek(xFilial("SDC")+cPedido)
		DbSelectArea("SA4")
		DbSeek(cFilial+SC5->C5_TRANSP)
		DbSelectArea("SA3")
		DbSeek(cFilial+SC5->C5_VEND1)
		DbSelectArea("SE4")
		DbSeek(cFilial+SC5->C5_CONDPAG)
		
		DbSelectArea("SDC")
		Do While !EoF() .AND. xFILIAL("SDC") == SC5->C5_FILIAL .AND. SDC->DC_PEDIDO == SC5->C5_NUM
			nRegistro := Recno()
			
			DbSelectArea("SC9")
			DbSetOrder(1)
			
			If DbSeek(xFilial("SC9")+SDC->DC_PEDIDO+SDC->DC_ITEM+SDC->DC_SEQ)
				If Empty(SC9->C9_BLEST) .AND. Empty(SC9->C9_BLCRED2) .AND. Empty(SC9->C9_PARCIAL)
					
					Set Device To Print
					Set Printer to &cPorta
					PrinterWin(.F.) // Impressao Dos/Windows
					PreparePrint(.F., "", .F., cPorta) // Prepara a impressao na porta especificada
					#IFDEF WINDOWS
						initprint(1)
					#ENDIF
					
					//        MsgBox('Row '+transform(prow(),"9999") +chr(13)+ 'Col '+transform(pcol(),"9999"),"Checando linha e coluna na impressora","YESNO")
					
					DbSelectArea("SDC")
					DbGoTo( nRegistro )
					Do While !Eof() .And. SDC->DC_PEDIDO == SC5->C5_NUM
						IF li > 47
							IF lRodape
								U_ImpRod_D()
							EndIf
							li := 0
							lRodape := U_ImpCab_D()
						EndIf
						U_ImpItem_D()
						DbSelectArea("SDC")
						DbSkip()
					Enddo
					IF lRodape
						U_ImpRod_D()
						lRodape:=.F.
					Endif
					lCred2 := Empty(SC9->C9_BLCRED2)
				ElseIf !Empty(SC9->C9_BLCRED2)
					Iif(!Empty(SC9->C9_BLCRED2),lParadoFin := .t.,)
					lCred2 := .F.
				EndIf
			Else
				_lproblema := .t.
				lRodape := U_ImpCab_D()
				U_ImpItem_D()
				_lproblema := .f.
			EndIf
			
			DbSelectArea("SDC")
			DbSkip()
			
			If !lCred2
				exit
			EndIF
		EndDo
	EndIf
EndIf

SetPgEject(.F.) // JBS 05/01/2005
MS_FLUSH()

If lCred2
	DBSELECTAREA("SC5")
	Reclock("SC5",.F.)
	SC5->C5_PRENOTA := "S"
	SC5->C5_DT_PRE  := DATE()
	SC5->C5_HR_PRE  := TIME()
	MsUnLock()
	// Registra na ficha Kardex
	U_DiprKardex(cPedido,U_DipUsr(),,.t.,Iif(nItens <> 0,"19","20")) // JBS 29/08/2005
	
	MSGINFO('PRE-NOTA IMPRESSA - '+cPedido)
	
	If !Empty(SC5->C5_SENHCID) .or. !Empty(SC5->C5_SENHPAG) .or. !Empty(SC5->C5_SENHMAR) .or. !Empty(SC5->C5_SENHTES) /// VERIFICA SE ALGUM DOS CAMPOS DE SENHA ESTÁ PREENCHIDO.
		/*====================================================================================\
		|SELECIONANDO ITENS DO PEDIDO QUE POSSUI SENHA GRAVADA PARA ENVIAR AO ERICH           |
		\====================================================================================*/
		
		/*
		SELECT C5_CLIENTE, C5_LOJACLI, A1_NOME, C5_NUM, C5_EMISSAO, C5_OPERADO, C5_MARGATU, C5_MARGLIB, C5_SENHMAR, C5_SENHPAG, C5_EXPLSEN, C5_DATA1, C5_PARC1, C5_DATA2, C5_PARC2, C5_DATA3, C5_PARC3, C5_DATA4, C5_PARC4, C6_PRODUTO, C6_MARGATU, C6_MARGITE, C6_QTDVEN, C6_PRCVEN, C6_CUSTO, C6_PRCMIN, C6_NOTA, C6_VALOR, B1_DESC, B1_UCOM, B1_UPRC+(B1_UPRC*B1_IPI/100) B1_UPRC, B1_PRVMINI, B1_PRVSUPE, B1_ALTPREC, U7_NREDUZ, U7_EMAIL, E4_DESCRI
		FROM SC6010, SC5010, SA1010, SU7010, SB1010, SE4010
		WHERE C6_NUM >= '001050' AND C6_NUM >= '009050'
		AND C5_NUM = C6_NUM
		AND C6_CLI = A1_COD
		AND C6_LOJA = A1_LOJA
		AND C5_OPERADO = U7_COD
		AND E4_CODIGO = C5_CONDPAG
		AND B1_COD = C6_PRODUTO
		AND SC6010.D_E_L_E_T_ <> '*'
		AND SC5010.D_E_L_E_T_ <> '*'
		AND SA1010.D_E_L_E_T_ <> '*'
		AND SU7010.D_E_L_E_T_ <> '*'
		AND SB1010.D_E_L_E_T_ <> '*'
		AND SE4010.D_E_L_E_T_ <> '*'
		ORDER BY C6_NUM
		*/
		//Incluido campos de data e parcela 5 e 6
		QRY1 := " SELECT C5_CLIENTE, C5_LOJACLI, A1_NOME, C5_NUM, C5_EMISSAO, C5_OPERADO, C5_MARGATU, C5_MARGLIB, C5_SENHCID, C5_SENHTES, C5_SENHMAR, C5_SENHPAG, C5_EXPLSEN, C5_DATA1, C5_PARC1, C5_DATA2, C5_PARC2, C5_DATA3, C5_PARC3, C5_DATA4, C5_PARC4, C5_DATA5, C5_PARC5, C5_DATA6, C5_PARC6, C6_PRODUTO, C6_MARGATU, C6_MARGITE, C6_QTDVEN, C6_PRCVEN, C6_CUSTO, C6_PRCMIN, C6_NOTA, C6_VALOR, B1_DESC, B1_UCOM, B1_UPRC+(B1_UPRC*B1_IPI/100) B1_UPRC, B1_PRVMINI, B1_PRVSUPE, B1_ALTPREC, U7_NREDUZ, U7_EMAIL, E4_DESCRI, C5_DATA1, C5_DATA2, C5_DATA3, C5_DATA4 "
		QRY1 += " FROM " + RetSQLName("SC6") + ", " + RetSQLName("SC5") + ", " + RetSQLName("SA1") + ", " + RetSQLName("SU7") + ", " + RetSQLName("SB1") + ", " + RetSQLName("SE4")
		QRY1 += " WHERE C6_FILIAL = '"+xFilial("SC6")+"'" // JBS 09/11/2005
		QRY1 += "   AND C5_FILIAL = '"+xFilial("SC5")+"'" // JBS 09/11/2005
		QRY1 += "   AND A1_FILIAL = '"+xFilial("SA1")+"'" // JBS 09/11/2005
		QRY1 += "   AND U7_FILIAL = '"+xFilial("SU7")+"'" // JBS 09/11/2005
		QRY1 += "   AND B1_FILIAL = '"+xFilial("SB1")+"'" // JBS 09/11/2005
		QRY1 += "   AND E4_FILIAL = '"+xFilial("SE4")+"'" // JBS 09/11/2005
		QRY1 += "   AND C6_NUM = '" + cPedido + "'" // JBS 09/11/2005
		QRY1 += "   AND C5_NUM = C6_NUM"
		QRY1 += "   AND C6_CLI = A1_COD"
		QRY1 += "   AND C6_LOJA = A1_LOJA"
		QRY1 += "   AND C5_OPERADO = U7_COD"
		QRY1 += "   AND E4_CODIGO = C5_CONDPAG"
		QRY1 += "   AND B1_COD = C6_PRODUTO"
		QRY1 += "   AND " + RetSQLName("SC6") + ".D_E_L_E_T_ <> '*'"
		QRY1 += "   AND " + RetSQLName("SC5") + ".D_E_L_E_T_ <> '*'"
		QRY1 += "   AND " + RetSQLName("SA1") + ".D_E_L_E_T_ <> '*'"
		QRY1 += "   AND " + RetSQLName("SU7") + ".D_E_L_E_T_ <> '*'"
		QRY1 += "   AND " + RetSQLName("SB1") + ".D_E_L_E_T_ <> '*'"
		QRY1 += "   AND " + RetSQLName("SE4") + ".D_E_L_E_T_ <> '*'"
		QRY1 += " ORDER BY C6_NUM"
		
		#xcommand TCQUERY <sql_expr>                          ;
		[ALIAS <a>]                                           ;
		[<new: NEW>]                                          ;
		[SERVER <(server)>]                                   ;
		[ENVIRONMENT <(environment)>]                         ;
		=> dbUseArea(                                         ;
		<.new.>,                                              ;
		"TOPCONN",                                            ;
		TCGENQRY(<(server)>,<(environment)>,<sql_expr>),      ;
		<(a)>, .F., .T.)
		
		// PROCESSA QUERY SQL
		DbCommitAll()
		TcQuery QRY1 NEW ALIAS "QRY1"         // ABRE UMA WORKAREA COM O RESULTADO DA QUERY
		
		DbSelectArea("QRY1")
		QRY1->(dbGotop())
		
		Do While QRY1->(!EOF())
			aadd(aMsg,{QRY1->C5_CLIENTE, QRY1->C5_LOJACLI, QRY1->A1_NOME, QRY1->C5_NUM, QRY1->C5_EMISSAO, QRY1->C5_OPERADO, QRY1->C5_MARGATU, QRY1->C5_MARGLIB, QRY1->C5_SENHMAR, QRY1->C5_SENHPAG, QRY1->C5_SENHTES, QRY1->C5_SENHCID, QRY1->C5_EXPLSEN, QRY1->C5_DATA1, QRY1->C5_PARC1, QRY1->C5_DATA2, QRY1->C5_PARC2, QRY1->C5_DATA3, QRY1->C5_PARC3, QRY1->C5_DATA4, QRY1->C5_PARC4, QRY1->C5_DATA5, QRY1->C5_PARC5, QRY1->C5_DATA6, QRY1->C5_PARC6, QRY1->C6_PRODUTO, QRY1->C6_MARGATU, QRY1->C6_MARGITE, QRY1->C6_QTDVEN, QRY1->C6_PRCVEN, QRY1->C6_CUSTO, QRY1->C6_PRCMIN, QRY1->C6_NOTA, QRY1->C6_VALOR, QRY1->B1_DESC, QRY1->B1_UCOM, QRY1->B1_UPRC, QRY1->B1_PRVMINI, QRY1->B1_PRVSUPE, QRY1->B1_ALTPREC, QRY1->U7_NREDUZ, QRY1->U7_EMAIL, QRY1->E4_DESCRI, QRY1->C5_DATA1, QRY1->C5_DATA2, QRY1->C5_DATA3, QRY1->C5_DATA4, QRY1->C5_DATA5, QRY1->C5_DATA6})
			QRY1->(DbSkip())
		EndDo
		
		If Len(aMsg) > 0 // SE NÃO POSSUIR NENHUMA LINHA NO ARRAY NÃO ENVIA NADA
			cEmail := 'erich@dipromed.com.br'
			cAssunto := 'Pedido de venda liberado por senha - ' + SC5->C5_NUM
			EMail2(cEmail,cAssunto,aMsg)
		Endif
		DBCLOSEAREA("QRY1")
	EndIf
	
	
	
	If SubStr(SC5->C5_MENNOTA,AT('=',SC5->C5_MENNOTA),5) == "=ST=D"  .And. Val(Left(SC5->C5_MENNOTA,4)) > 0 /// VERIFICA SE SUBST. TRIBUTÁRIA ESTÁ INCLUSO NO VALOR DA DESPESA.
		/*====================================================================================\
		|SELECIONANDO ITENS DO PEDIDO QUE POSSUI SUBSTITUIÇÃO TRIBUTÁRIA NA DESPESA           |
		\====================================================================================*/
		
		/*
		SELECT C6_NUM, C6_ITEM, C6_PRODUTO, C6_QTDVEN, C6_UM, C6_DESCRI, C6_VALOR, C6_CLI, C6_LOJA, C5_MENNOTA, A1_NOME, A1_EST, U7_EMAIL
		FROM SC6010, SC5010, SA1010, SU7010
		WHERE C6_NUM = '999999'
		AND C5_NUM = C6_NUM
		AND C6_CLI = A1_COD
		AND C6_LOJA = A1_LOJA
		AND C5_OPERADO = U7_COD
		AND SC6010.D_E_L_E_T_ <> '*'
		AND SC5010.D_E_L_E_T_ <> '*'
		AND SA1010.D_E_L_E_T_ <> '*'
		AND SU7010.D_E_L_E_T_ <> '*'
		ORDER BY C6_NUM
		*/
		QRY2 := "SELECT C6_NUM, C6_ITEM, C6_PRODUTO, C6_QTDVEN, C6_UM, C6_DESCRI, C6_VALOR, C6_CLI, C6_LOJA, C5_MENNOTA, A1_NOME, A1_EST, U7_EMAIL, C5_FRETE, C5_DESPESA "
		QRY2 += " FROM " + RetSQLName("SC6") + ", " + RetSQLName("SC5") + ", " + RetSQLName("SA1") + ", " + RetSQLName("SU7")
		QRY2 += " WHERE C5_FILIAL = '"+xFilial("SC5")+"'" // JBS 09/11/2005
		QRY2 += "   AND C6_FILIAL = '"+xFilial("SC6")+"'" // JBS 09/11/2005
		QRY2 += "   AND A1_FILIAL = '"+xFilial("SA1")+"'" // JBS 09/11/2005
		QRY2 += "   AND U7_FILIAL = '"+xFilial("SU7")+"'" // JBS 09/11/2005
		QRY2 += "   AND C6_NUM = '" + cPedido + "'" // JBS 09/11/2005
		QRY2 += "   AND C5_NUM = C6_NUM"
		QRY2 += "   AND C6_CLI = A1_COD"
		QRY2 += "   AND C6_LOJA = A1_LOJA"
		QRY2 += "   AND C5_OPERADO = U7_COD"
		QRY2 += "   AND " + RetSQLName("SC6") + ".D_E_L_E_T_ <> '*'"
		QRY2 += "   AND " + RetSQLName("SC5") + ".D_E_L_E_T_ <> '*'"
		QRY2 += "   AND " + RetSQLName("SA1") + ".D_E_L_E_T_ <> '*'"
		QRY2 += "   AND " + RetSQLName("SU7") + ".D_E_L_E_T_ <> '*'"
		QRY2 += " ORDER BY C6_NUM"
		#xcommand TCQUERY <sql_expr>                          ;
		[ALIAS <a>]                                           ;
		[<new: NEW>]                                          ;
		[SERVER <(server)>]                                   ;
		[ENVIRONMENT <(environment)>]                         ;
		=> dbUseArea(                                         ;
		<.new.>,                                              ;
		"TOPCONN",                                            ;
		TCGENQRY(<(server)>,<(environment)>,<sql_expr>),      ;
		<(a)>, .F., .T.)
		
		// PROCESSA QUERY SQL
		DbCommitAll()
		TcQuery QRY2 NEW ALIAS "QRY2"         // ABRE UMA WORKAREA COM O RESULTADO DA QUERY
		
		DbSelectArea("QRY2")
		QRY2->(dbGotop())
		
		Do While QRY2->(!EOF())
			cVal_STD := SubStr(QRY2->C5_MENNOTA,1,AT("=",QRY2->C5_MENNOTA)-1)
			aadd(aMsg1,{QRY2->C6_NUM, QRY2->C6_ITEM, QRY2->C6_PRODUTO, QRY2->C6_DESCRI, QRY2->C6_UM, QRY2->C6_QTDVEN, QRY2->C6_VALOR, QRY2->C6_CLI, QRY2->C6_LOJA, QRY2->A1_NOME, QRY2->A1_EST, Val(cVal_STD), QRY2->U7_EMAIL, QRY2->C5_FRETE, QRY2->C5_DESPESA})
			//			     1             2             3                 4                5             6               7               8             9              10             11               12          13              14              15
			QRY2->(DbSkip())
		EndDo
		
		If Len(aMsg1) > 0 // SE NÃO POSSUIR NENHUMA LINHA NO ARRAY NÃO ENVIA NADA
			cEmail := 'magda@dipromed.com.br'
			cAssunto := 'AVISO - Substituição Tributária - PV-' + SC5->C5_NUM
			EMail(cEmail,cAssunto,aMsg1)
		Endif
		DBCLOSEAREA("QRY2")
	EndIf
	
	
Else
	If cProg <> 'dipmta450'
		If lParadoFIn
			MSGINFO('PEDIDO PARADO NO FINANCEIRO '+cPedido)
			SC5->(Reclock("SC5",.F.))
			SC5->C5_PRENOTA := "F"
			SC5->(MsUnLock("SC5"))
		EndIf
	EndIf
EndIf

RestArea(aArea)

Return


/*==========================================================================\
|Programa  |EMail   | Autor | Rafael de Campos Falco  | Data ³ 13/01/2005   |
|===========================================================================|
|Desc.     | Envio de EMail                                                 |
|===========================================================================|
|Sintaxe   | EMail                                                          |
|===========================================================================|
|Uso       | Especifico DIPROMED                                            |
\==========================================================================*/

Static Function EMail(cEmail,cAssunto,aMsg1,aAttach)

Local cAccount  := Lower(Alltrim(GetMv("MV_RELACNT")))
Local cFrom     := Lower(Alltrim(GetMv("MV_RELACNT")))
Local cPassword := Alltrim(GetMv("MV_RELPSW"))
Local cServer   := Alltrim(GetMv("MV_RELSERV"))
Local cEmailTo  := ""
Local cEmailCc  := ""
Local cEmailBcc := ""
Local lResult   := .F.
Local cError    := ""
Local cMsg      := ""
Local nTot_Ped := 0

/*=============================================================================*/
/*Definicao do cabecalho do email                                              */
/*=============================================================================*/
cMsg := ""
cMsg += '<html>'
cMsg += '<head>'
cMsg += '<title>' + cAssunto + '</title>'
cMsg += '</head>'
cMsg += '<body>'
cMsg += '<HR Width=85% Size=3 Align=Centered Color=Red> <P>'
cMsg += '<Table Align=Center BorderColor=#000000 CELLPADDING=4 CELLSPACING=0 Width=60%>'

/*=============================================================================*/
/*Definicao do cabecalho do relatório                                          */
/*=============================================================================*/

cMsg += '<table width="100%">'
cMsg += '<tr>'
cMsg += '<td width="100%" colspan="2"><font size="4" color="red">Pedido - ' + aMsg1[1,1] + '</font></td>'
cMsg += '</tr>'
cMsg += '<tr>'
cMsg += '<td width="80%"><font size="2" color="blue">Cliente: ' + aMsg1[1,8] + "-" + aMsg1[1,9] + "-" + aMsg1[1,10] + '</font></td>'
cMsg += '<td width="40%" align="right"><font size="3" color="red">Estado: ' + aMsg1[1,11] + '</font></td>'
cMsg += '</tr>'
cMsg += '</table>'


cMsg += '<table width="100%" cellspacing="0" cellpadding="0"><font size="2" color="blue">'
cMsg += '<tr>'
cMsg += '<td>===============================================================================================================</td>'
cMsg += '</tr>'
cMsg += '</font></table>'

cMsg += '<table width="100%" cellspacing="0" cellpadding="0"><font size="2" color="blue">'
cMsg += '<td width="80%">Código - Descrição</td>'
cMsg += '<td width="20%" align="right">Valor</td>'
cMsg += '</tr>'
cMsg += '</font></table>'

cMsg += '<table width="100%" cellspacing="0" cellpadding="0"><font size="2" color="blue">'
cMsg += '<tr>'
cMsg += '<td>===============================================================================================================</td>'
cMsg += '</tr>'
cMsg += '</font></table>'

/*=============================================================================*/
/*Definicao do texto/detalhe do email                                          */
/*=============================================================================*/


For nLin := 1 to Len(aMsg1)
	nTot_Ped += aMsg1[nLin,7]
	If Mod(nLin,2) == 0
		cMsg += '<table width="100%" border="0" cellspacing="0" cellpadding="0">'
		cMsg += '<tr BgColor="#B0E2FF">'
		cMsg += '<td width="80%"><font size="2">' + aMsg1[nLin,3] + ' - ' + aMsg1[nLin,4] + '</font></td>'
		cMsg += '<td width="20%" align="right"><font size="2">' + Transform(aMsg1[nLin,7],"@E 999,999,999.99") + '</font></td>'
		cMsg += '</tr>'
		cMsg += '</table>'
	Else
		cMsg += '<table width="100%" border="0" cellspacing="0" cellpadding="0">'
		cMsg += '<tr bgcolor="#c0c0c0">'
		cMsg += '<td width="80%"><font size="2">' + aMsg1[nLin,3] + ' - ' + aMsg1[nLin,4] + '</font></td>'
		cMsg += '<td width="20%" align="right"><font size="2">' + Transform(aMsg1[nLin,7],"@E 999,999,999.99") + '</font></td>'
		cMsg += '</tr>'
		cMsg += '</table>'
	EndIf
Next

cMsg += '<table width="100%" cellspacing="5" cellpadding="0">'
cMsg += '<tr BgColor=#FFFF80>'
cMsg += '<td width="33%" align="right"><font color="red" size="2">Frete: ' + Transform(aMsg1[1,14],"@E 999,999,999.99") + '</font></td>'
cMsg += '<td width="33%" align="right"><font color="red" size="2">Despesas: ' + Transform( aMsg1[1,15]-aMsg1[1,12],"@E 999,999,999.99") + '</font></td>'
cMsg += '<td width="33%" align="right"><font color="red" size="2">Total dos Produtos: ' + Transform(nTot_Ped,"@E 999,999,999.99") + '</font></td>'
cMsg += '</tr>'
cMsg += '<tr BgColor=#FFFF80>'
cMsg += '<td width="33%" align="right"><font color="red" size="2">Substituição Tributária: ' + Transform(aMsg1[1,12],"@E 999,999,999.99") + '</font></td>'
cMsg += '<td width="33%" align="right"></td>'
cMsg += '<td width="33%" align="right"><font color="red" size="2">Total do Pedido: ' + Transform(aMsg1[1,14]+aMsg1[1,15]+nTot_Ped,"@E 999,999,999.99") + '</font></td>'
cMsg += '</tr>'
cMsg += '</table>'

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Definicao do rodape do email                                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cMsg += '</Table>'
cMsg += '<HR Width=85% Size=3 Align=Centered Color=Red> <P>'
cMsg += '<table width="100%" Align="Center" border="0">'
cMsg += '<tr align="center">'
cMsg += '<td colspan="10"><font color="BLUE" size="2">Mensagem enviada automaticamente pelo sistema PROTHEUS - <font color="BLUE" size="1">(PRENOTA_D.PRW)</td>'
cMsg += '</tr>'
cMsg += '</table>'
cMsg += '</body>'
cMsg += '</html>'

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Envia o mail para a lista selecionada. Envia como BCC para que a pessoa pense³
//³que somente ela recebeu aquele email, tornando o email mais personalizado.   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
IF At(";",cEmail) > 0
	cEmailTo := SubStr(cEmail,1,At(";",cEmail)-1)
	cEmailCc := SubStr(cEmail,At(";",cEmail)+1,Len(cEmail))
Else
	cEmailTo := Alltrim(cEmail)
EndIF

CONNECT SMTP SERVER cServer ACCOUNT cAccount PASSWORD cPassword RESULT lResult

If lResult
	SEND MAIL FROM cFrom ;
	TO      	Lower(cEmailTo);
	CC      	Lower(cEmailCc);
	BCC     	Lower(cEmailBcc);
	SUBJECT 	cAssunto;
	BODY    	cMsg;
	RESULT lResult
	
	If !lResult
		//Erro no envio do email
		GET MAIL ERROR cError
		
		MsgInfo(cError,OemToAnsi("Atenção"))
	EndIf
	
	DISCONNECT SMTP SERVER
Else
	//Erro na conexao com o SMTP Server
	GET MAIL ERROR cError
	MsgInfo(cError,OemToAnsi("Atenção"))
EndIf

Return(.T.)



/*==========================================================================\
|Programa  |EMail2  | Autor | Rafael de Campos Falco  | Data ³ 06/05/2005   |
|===========================================================================|
|Desc.     | Envio de EMail para Erich sobre pedidos que utilizaram senha   |
|===========================================================================|
|Sintaxe   | EMail2                                                         |
|===========================================================================|
|Uso       | Especifico DIPROMED                                            |
\==========================================================================*/

Static Function EMail2(cEmail,cAssunto,aMsg,aAttach)

Local cAccount  := Lower(Alltrim(GetMv("MV_RELACNT")))
Local cFrom     := Lower(Alltrim(GetMv("MV_RELACNT")))
Local cPassword := Alltrim(GetMv("MV_RELPSW"))
Local cServer   := Alltrim(GetMv("MV_RELSERV"))
Local cEmailTo  := ""
Local cEmailCc  := ""
Local cEmailBcc := ""
Local lResult   := .F.
Local cError    := ""
Local cMsg      := ""
Local nTot_Ped := 0

/*=============================================================================*/
/*Definicao do cabecalho do email                                              */
/*=============================================================================*/
cMsg := ""
cMsg += '<html>'
cMsg += '<head>'
cMsg += '<title>' + cAssunto + '</title>'
cMsg += '</head>'
cMsg += '<body>'
cMsg += '<HR Width=85% Size=3 Align=Centered Color=Red> <P>'
cMsg += '<Table Align=Center BorderColor=#000000 CELLPADDING=4 CELLSPACING=0 Width=60%>'

/*=============================================================================*/
/*Definicao do cabecalho do relatório                                          */
/*=============================================================================*/

cMsg += ' <table width="100%">'
cMsg += ' <tr>'
cMsg += ' <td width="100%"><font size="4" color="red">Pedido - ' + aMsg[1,4] + '</font></td>'
cMsg += ' </tr>'
cMsg += ' <tr>'
cMsg += ' <td width="100%"><font size="2" color="blue">Cliente - ' + aMsg[1,1] + "-" + aMsg[1,2] + "-" + aMsg[1,3] + '</font></td>'
cMsg += ' </tr>'
cMsg += ' </table>'


cMsg += ' <table width="100%" cellspacing="0" cellpadding="0">'
cMsg += ' <tr BgColor="#B0E2FF">'
cMsg += ' <td>============================================================================================================</td>'
cMsg += ' </tr>'
cMsg += ' </table>'

cMsg += ' <table width="100%" cellspacing="0" cellpadding="0">'
cMsg += ' <tr BgColor="#B0E2FF">'
cMsg += ' <td width="8%" align="left"><font size="2">Pedido</font></td>'
cMsg += ' <td width="8%" align="left"><font size="2">Emissão</font></td>'
cMsg += ' <td width="8%" align="right"><font size="2">Marg.Atual</font></td>'
cMsg += ' <td width="8%" align="right"><font size="2">Marg.Lib.</font></td>'
cMsg += ' <td width="3%" align="center"></td>'
cMsg += ' <td width="8%" align="left"><font size="2">TES</font></td>'
cMsg += ' <td width="8%" align="left"><font size="2">Margem</font></td>'
cMsg += ' <td width="8%" align="left"><font size="2">Pagamento</font></td>'
cMsg += ' <td width="8%" align="left"><font size="2">Cond.Pgto.</font></td>'
cMsg += ' </tr>'
cMsg += ' <tr BgColor="#B0E2FF">'
cMsg += ' <td colspan="9">============================================================================================================</td>'
//cMsg += ' <td colspan="9">-------------------------------------------------------------------------------------------------------------------------</td>'
cMsg += ' </tr>'
cMsg += ' <tr BgColor="#B0E2FF">'
cMsg += ' <td width="8%" align="left"><font size="2">' + aMsg[1,4] + '</font></td>'
cMsg += ' <td width="8%" align="left"><font size="2">' + SubStr(aMsg[1,5],7,2) + '/' + SubStr(aMsg[1,5],5,2) + '/' + SubStr(aMsg[1,5],1,4) + '</font></td>'
If aMsg[1,7] <= aMsg[1,8]
	cMsg += ' <td width="8%" align="right"><font size="2" color="red">' + Transform(aMsg[1,7],"@E 999.999") + '</font></td>'
Else
	cMsg += ' <td width="8%" align="right"><font size="2">' + Transform(aMsg[1,7],"@E 999.999") + '</font></td>'
EndIf
cMsg += ' <td width="8%" align="right"><font size="2">' + Transform(aMsg[1,8],"@E 999.999") + '</font></td>'
cMsg += ' <td width="3%" align="center"></td>'
cMsg += ' <td width="8%" align="left"><font size="2">' + aMsg[1,11] + '</font></td>'
cMsg += ' <td width="8%" align="left"><font size="2">' + aMsg[1,9] + '</font></td>'
cMsg += ' <td width="8%" align="left"><font size="2">' + aMsg[1,10] + '</font></td>'
cMsg += ' <td width="8%" align="left"><font size="2">' + aMsg[1,39] + '</font></td>'
cMsg += ' </tr>'
cMsg += ' <tr BgColor="#B0E2FF">'
cMsg += ' <td width="100%" colspan="9"><font size="2">Explicação: ' + aMsg[1,13] + '</font></td>'
cMsg += ' </tr>'
if !Empty(aMsg[1,40]) .or.!Empty(aMsg[1,41]) .or.!Empty(aMsg[1,42]) .or.!Empty(aMsg[1,43])
	cMsg += ' <tr BgColor="#B0E2FF">'
	cMsg += ' <td width="100%" colspan="9"><font size="2">Vencimentos: ' + ;
	SubStr(aMsg[1,40],7,2) + '/' + SubStr(aMsg[1,40],5,2) + '/' + SubStr(aMsg[1,40],1,4) + " - " + ;
	SubStr(aMsg[1,41],7,2) + '/' + SubStr(aMsg[1,41],5,2) + '/' + SubStr(aMsg[1,41],1,4) + " - " + ;
	SubStr(aMsg[1,42],7,2) + '/' + SubStr(aMsg[1,42],5,2) + '/' + SubStr(aMsg[1,42],1,4) + " - " + ;
	SubStr(aMsg[1,43],7,2) + '/' + SubStr(aMsg[1,43],5,2) + '/' + SubStr(aMsg[1,43],1,4) + '</font></td>'
	//aMsg[1,40] + " - " + aMsg[1,41] + " - " + aMsg[1,42] + " - " + aMsg[1,43] + '</font></td>'
	cMsg += ' </tr>'
EndIf
cMsg += ' </table>'

cMsg += ' <table width="100%" border="0" cellspacing="0" cellpadding="0">'
cMsg += ' <tr BgColor="#B0E2FF">'
cMsg += ' <td>============================================================================================================</td>'
cMsg += ' </tr>'
cMsg += ' </table>'

//        1                2                3                4                5                6                7                8                9                10                11                12                13              14             15             16                17                18               19              20                21                22              23                24               25                26              27          28                29               30                31           32              33                34                35	            36                 37           38             39
// QRY1->C5_CLIENTE, QRY1->C5_LOJACLI, QRY1->A1_NOME, QRY1->C5_NUM, QRY1->C5_EMISSAO, QRY1->C5_OPERADO, QRY1->C5_MARGATU, QRY1->C5_MARGLIB, QRY1->C5_SENHMAR, QRY1->C5_SENHPAG, QRY1->C5_SENHTES, QRY1->C5_SENHCID, QRY1->C5_EXPLSEN, QRY1->C5_DATA1, QRY1->C5_PARC1, QRY1->C5_DATA2, QRY1->C5_PARC2, QRY1->C5_DATA3, QRY1->C5_PARC3, QRY1->C5_DATA4, QRY1->C5_PARC4, QRY1->C6_PRODUTO, QRY1->C6_MARGATU, QRY1->C6_MARGITE, QRY1->C6_QTDVEN, QRY1->C6_PRCVEN, QRY1->C6_CUSTO, QRY1->C6_PRCMIN, QRY1->C6_NOTA, QRY1->C6_VALOR, QRY1->B1_DESC, QRY1->B1_UCOM, QRY1->B1_UPRC, QRY1->B1_PRVMINI, QRY1->B1_PRVSUPE, QRY1->B1_ALTPREC, QRY1->U7_NREDUZ, QRY1->U7_EMAIL, QRY1->E4_DESCRI

cMsg += ' <table width="100%" border="0" cellspacing="0" cellpadding="0">'
cMsg += ' <tr bgcolor="#c0c0c0">'
cMsg += ' <td width="84%" colspan="6"><font size="2">Produto</font></td>'
cMsg += ' <td width="8%"><font size="2">Últ. Entrada</font></td>'
cMsg += ' <td width="8%"><font size="2">Últ. Alter.</font></td>'
cMsg += ' </tr>'
cMsg += ' <tr bgcolor="#c0c0c0">'
cMsg += ' <td width="8%" align="right"><font size="2">Marg. Atual</font></td>'
cMsg += ' <td width="8%" align="right"><font size="2">Marg. Liber.</font></td>'
cMsg += ' <td width="8%" align="right"><font size="2">Quantidade</font></td>'
cMsg += ' <td width="8%" align="right"><font size="2">Preço</font></td>'
cMsg += ' <td width="8%" align="right"><font size="2">Total</font></td>'
cMsg += ' <td width="8%" align="right"><font size="2">Menor Preço</font></td>'
cMsg += ' <td width="8%" align="right"><font size="2">Custo</font></td>'
cMsg += ' </tr>'
cMsg += ' <tr BgColor="#c0c0c0">'
cMsg += ' <td colspan="8">============================================================================================================</td>'
//	cMsg += ' <td colspan="8">-------------------------------------------------------------------------------------------------------------------------</td>'
cMsg += ' </tr>'
cMsg += ' </table>'

nTot_Ped := 0

For nLin := 1 to Len(aMsg)
	If Mod(nLin,2) == 0
		cMsg += ' <table width="100%" border="0" cellspacing="0" cellpadding="0">'
		cMsg += ' <tr BgColor="#B0E2FF">'
		cMsg += ' <td width="84%" colspan="6"><font size="2">' + aMsg[nLin,22]+'-'+aMsg[nLin,31] + '</font></td>'
		cMsg += ' <td width="8%"><font size="2">' + SubStr(aMsg[nLin,32],7,2) + '/' + SubStr(aMsg[nLin,32],5,2) + '/' + SubStr(aMsg[nLin,32],1,4) + '</font></td>'
		cMsg += ' <td width="8%"><font size="2">' + SubStr(aMsg[nLin,36],7,2) + '/' + SubStr(aMsg[nLin,36],5,2) + '/' + SubStr(aMsg[nLin,36],1,4) + '</font></td>'
		cMsg += ' </tr>'
		cMsg += ' <tr BgColor="#B0E2FF">'
		If aMsg[nLin,23] <= aMsg[nLin,24]
			cMsg += ' <td width="8%" align="right"><font size="2" color="red">' + Transform(aMsg[nLin,23]*20,"@E 999.999") + '</font></td>'
		Else
			cMsg += ' <td width="8%" align="right"><font size="2">' + Transform(aMsg[nLin,23]*20,"@E 999.999") + '</font></td>'
		EndIf
		cMsg += ' <td width="8%" align="right"><font size="2">' + Transform(aMsg[nLin,24]*20,"@E 999.999") + '</font></td>'
		cMsg += ' <td width="8%" align="right"><font size="2">' + Transform(aMsg[nLin,25],"@E 999,999,999") + '</font></td>'
		cMsg += ' <td width="8%" align="right"><font size="2">' + Transform(aMsg[nLin,26],"@E 999,999.9999") + '</font></td>'
		cMsg += ' <td width="8%" align="right"><font size="2">' + Transform(aMsg[nLin,30],"@E 999,999.9999") + '</font></td>'
		cMsg += ' <td width="8%" align="right"><font size="2">' + Transform(Iif(aMsg[nLin,35]==0,aMsg[nLin,34],aMsg[nLin,35]),"@E 999,999.9999") + '</font></td>'
		cMsg += ' <td width="8%" align="right"><font size="2">' + Transform(aMsg[nLin,27],"@E 999,999.9999") + '</font></td>'
		cMsg += ' </tr>'
		cMsg += ' </table>'
	Else
		cMsg += ' <table width="100%" border="0" cellspacing="0" cellpadding="0">'
		cMsg += ' <tr bgcolor="#c0c0c0">'
		cMsg += ' <td width="84%" colspan="6"><font size="2">' + aMsg[nLin,22]+'-'+aMsg[nLin,31] + '</font></td>'
		cMsg += ' <td width="8%"><font size="2">' + SubStr(aMsg[nLin,32],7,2) + '/' + SubStr(aMsg[nLin,32],5,2) + '/' + SubStr(aMsg[nLin,32],1,4) + '</font></td>'
		cMsg += ' <td width="8%"><font size="2">' + SubStr(aMsg[nLin,36],7,2) + '/' + SubStr(aMsg[nLin,36],5,2) + '/' + SubStr(aMsg[nLin,36],1,4) + '</font></td>'
		cMsg += ' </tr>'
		cMsg += ' <tr bgcolor="#c0c0c0">'
		If aMsg[nLin,23] <= aMsg[nLin,24]
			cMsg += ' <td width="8%" align="right"><font size="2" color="red">' + Transform(aMsg[nLin,23]*20,"@E 999.999") + '</font></td>'
		Else
			cMsg += ' <td width="8%" align="right"><font size="2">' + Transform(aMsg[nLin,23]*20,"@E 999.999") + '</font></td>'
		EndIf
		cMsg += ' <td width="8%" align="right"><font size="2">' + Transform(aMsg[nLin,24]*20,"@E 999.999") + '</font></td>'
		cMsg += ' <td width="8%" align="right"><font size="2">' + Transform(aMsg[nLin,25],"@E 999,999,999") + '</font></td>'
		cMsg += ' <td width="8%" align="right"><font size="2">' + Transform(aMsg[nLin,26],"@E 999,999.9999") + '</font></td>'
		cMsg += ' <td width="8%" align="right"><font size="2">' + Transform(aMsg[nLin,30],"@E 999,999.9999") + '</font></td>'
		cMsg += ' <td width="8%" align="right"><font size="2">' + Transform(Iif(aMsg[nLin,35]==0,aMsg[nLin,34],aMsg[nLin,35]),"@E 999,999.9999") + '</font></td>'
		cMsg += ' <td width="8%" align="right"><font size="2">' + Transform(aMsg[nLin,27],"@E 999,999.9999") + '</font></td>'
		cMsg += ' </tr>'
		cMsg += ' </table>'
	EndIf
	
	nTot_Ped += aMsg[nLin,30]
Next

cMsg += ' <table width="100%" border="0" cellspacing="0" cellpadding="0">'
cMsg += ' <tr BgColor="#B0E2FF">'
cMsg += ' <td width="84%" colspan="6"><font size="2"></font></td>'
cMsg += ' <td width="8%"><font size="2"></font></td>'
cMsg += ' <td width="8%"><font size="2"></font></td>'
cMsg += ' </tr>'
cMsg += ' <tr BgColor="#B0E2FF">'
cMsg += ' <td width="8%" align="right"><font size="2"></font></td>'
cMsg += ' <td width="8%" align="right"><font size="2"></font></td>'
cMsg += ' <td width="8%" align="right"><font size="2"></font></td>'
cMsg += ' <td width="8%" align="left"><font size="2">Total do Pedido:</font></td>'
cMsg += ' <td width="8%" align="right"><font size="2">' + Transform(nTot_Ped,"@E 999,999.9999") + '</font></td>'
cMsg += ' <td width="8%" align="right"><font size="2"></font></td>'
cMsg += ' <td width="8%" align="right"><font size="2"></font></td>'
cMsg += ' </tr>'
cMsg += ' </table>'

cMsg += '<table width="100%" border="0" cellspacing="0" cellpadding="0">'
cMsg += '<tr BgColor="#B0E2FF">'
cMsg += '<td>=============================================================================================================</td>'
cMsg += '</tr>'
cMsg += '</table>'


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Definicao do rodape do email                                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cMsg += '</Table>'
cMsg += '<HR Width=85% Size=3 Align=Centered Color=Red> <P>'
cMsg += '<table width="100%" Align="Center" border="0">'
cMsg += '<tr align="center">'
cMsg += '<td colspan="10"><font color="BLUE" size="2">Mensagem enviada automaticamente pelo sistema PROTHEUS - <font color="BLUE" size="1">(PRENOTA_D.PRW)</td>'
cMsg += '</tr>'
cMsg += '</table>'
cMsg += '</body>'
cMsg += '</html>'

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Envia o mail para a lista selecionada. Envia como BCC para que a pessoa pense³
//³que somente ela recebeu aquele email, tornando o email mais personalizado.   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
IF At(";",cEmail) > 0
	cEmailTo := SubStr(cEmail,1,At(";",cEmail)-1)
	cEmailCc := SubStr(cEmail,At(";",cEmail)+1,Len(cEmail))
Else
	cEmailTo := Alltrim(cEmail)
EndIF

CONNECT SMTP SERVER cServer ACCOUNT cAccount PASSWORD cPassword RESULT lResult

If lResult
	SEND MAIL FROM cFrom ;
	TO      	Lower(cEmailTo);
	CC      	Lower(cEmailCc);
	BCC     	Lower(cEmailBcc);
	SUBJECT 	cAssunto;
	BODY    	cMsg;
	RESULT lResult
	
	If !lResult
		//Erro no envio do email
		GET MAIL ERROR cError
		
		MsgInfo(cError,OemToAnsi("Atenção"))
	EndIf
	
	DISCONNECT SMTP SERVER
Else
	//Erro na conexao com o SMTP Server
	GET MAIL ERROR cError
	MsgInfo(cError,OemToAnsi("Atenção"))
EndIf

Return(.T.)

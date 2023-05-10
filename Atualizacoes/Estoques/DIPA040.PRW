/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDIPA040     บAutor  ณMaximo Canuto V. Neto บ Data ณ 11/04/09บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Atualiza Data validade nas tabelas SB8,SD5,SD2,SD3,SD1,SC9 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ DIPROMED                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/                                      

#INCLUDE "RWMAKE.CH"
#INCLUDE "AP5MAIL.CH"
#INCLUDE "TBICONN.CH"  
#DEFINE CR    chr(13)+chr(10) // Carreage Return (Fim de Linha)

User Function DIPA040()

//Declarando Variแveis
Local   cUserAut  := GetMv('MV_DIPA040') 
Local   oDlg      
Local   nOpcao    := 0
Private dNewDtVal := cTod('  /  /  ')
Private dOldDtVal := cTod('  /  /  ')
Private cLoteCtl  := Space(10)
Private cProduto  := Space(06)  
Private cLocal    := '01'    
Private	cRegAlt	  := ""



If !AllTrim(Upper(U_DipUsr())) $ cUserAut
	MSGSTOP(AllTrim(Upper(U_DipUsr()))+", voc๊ nใo tem autoriza็ใo para executar esta rotina!")
	Return
EndIf                                                                                                   

U_DIPPROC(ProcName(0),U_DipUsr()) 

@ 150,000 To 400,400 DIALOG oDlg TITLE OemToAnsi("ATUALIZANDO DATA DE VALIDADE DO LOTE.")

@ 008,010 Say "Informe o c๓digo do Produto "                       
@ 008,120 Get cProduto Size 45,40 F3 "SB1"  Valid ExistCPO("SB1")
@ 028,010 Say "Informe o Lote"
@ 028,120 Get cLoteCtl Size 45,40  Valid If(Alltrim(cLoteCtl)<>'',.T.,.F.)  
@ 058,010 Say "INFORME A NOVA DATA DE VALIDADE "
@ 070,010 Get dNewDtVal Size 33,28 Valid ValDate()
@ 100,100 BMPBUTTON TYPE 1 ACTION (nOpcao :=1 ,Close(oDlg))
@ 100,140 BMPBUTTON TYPE 2 ACTION Close(oDlg)

ACTIVATE DIALOG oDlg Centered

If nOpcao == 1
	If (!MsgBox("Confirma altera็ใo da Data de validade","Atencao","YESNO"))
		Return 
	Else          
	    cProduto := cProduto+Space(09) // Ajustando o tamanho do campo
		Processa({|| AtuDtValid()},"Atualizando Registros...")	
	EndIf
Else 
	Alert("Atualiza็ใo cancelada!")
Endif
Return
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/* Fun็ใo para ravar nova data bas tabelas necessแrias*/

Static Function	AtuDtValid()  

Local QRY1
Local QRY2
Local QRY3
Local QRY4
Local QRY5
Local QRY6

For x:=1 to 11 // Ajustando para buscar em todos os locais - MCVN - 17/11/2009/
    cLocal := StrZero(x,2)
	If !Empty(cProduto)
		SB8->(DbSetOrder(3))
		If !SB8->(DbSeek(xFilial("SB8")+cProduto+cLocal+cLoteCtl))
			Alert("Lote nใo encontrado no almoxarifado! "+cLocal)
			//Return
		ElseIf SB8->B8_DTVALID != dNewDtVal
			dOldDtVal := SB8->B8_DTVALID
			If cLocal = '01'
				If (!MsgBox("Confirma altera็ใo da Data de validade de "+DtoC(dOldDtVal)+" para "+DtoC(dNewDtVal)+;
					" do Produto "+cProduto+" no lote "+cLoteCtl+" no almoxarifado "+cLocal+" ?","Atencao","YESNO"))
					Return
				Endif
			Endif
			
			Begin Transaction
			
			
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณSeleciono os items que precisam ser alterados.ณ
			//ณSB8 - SALDO POR LOTES                         ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			cQuery:= " SELECT R_E_C_N_O_ AS B8RECNO, * "
			cQuery+= " FROM " + RetSqlName("SB8") + " SB8 "
			cQuery+= " WHERE SB8.D_E_L_E_T_ = '' "
			cQuery+= " AND SB8.B8_PRODUTO = '" + cProduto + "' "
			cQuery+= " AND SB8.B8_LOCAL = '" + cLocal + "' "
			cQuery+= " AND SB8.B8_LOTECTL  = '" + cLoteCtl + "' "
			cQuery+= " AND SB8.B8_FILIAL  = '" + xFilial("SB8") + "' "
			
			cQuery := ChangeQuery(cQuery)
			
			DbCommitAll()
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"QRY1",.T.,.T.)
			dbSelectArea("QRY1")
			Do While !Eof()
				dbSelectArea("SB8")
				dbGoTo(QRY1->B8RECNO)
				Reclock("SB8",.F.)
				SB8->B8_DTVALID := dNewDtVal
				SB8->(MsUnlock())
				SB8->(DbSkip())
				dbSelectArea("QRY1")
				dbSkip()
			EndDo
			QRY1->(dbCloseArea())
			
			
			/*  Desabilitado dia 29/09/2011  (Erika CD)
			
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณSeleciono os items que precisam ser alterados.ณ
			//ณSD5 - MOVIMENTAวรO POR LOTES                  ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			cQuery:= " SELECT R_E_C_N_O_ AS D5RECNO, * "
			cQuery+= " FROM " + RetSqlName("SD5") + " SD5 "
			cQuery+= " WHERE SD5.D_E_L_E_T_ = '' "
			cQuery+= " AND SD5.D5_PRODUTO = '" + cProduto + "' "
			cQuery+= " AND SD5.D5_LOCAL = '" + cLocal + "' "
			cQuery+= " AND SD5.D5_LOTECTL  = '" + cLoteCtl + "' "
			cQuery+= " AND SD5.D5_FILIAL  = '" + xFilial("SD5") + "' "
			
			cQuery := ChangeQuery(cQuery)
			
			DbCommitAll()			
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"QRY2",.T.,.T.)
			dbSelectArea("QRY2")
			Do While !Eof()
				dbSelectArea("SD5")
				dbGoTo(QRY2->D5RECNO)
				Reclock("SD5",.F.)
				SD5->D5_DTVALID := dNewDtVal
				SD5->(MsUnlock())
				SD5->(DbSkip())
				dbSelectArea("QRY2")
				dbSkip()
			EndDo
			QRY2->(dbCloseArea())
			
			
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณSeleciono os items que precisam ser alterados.ณ
			//ณSD3 - MOVIMENTAวรO INTERNA                    ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			cQuery:= " SELECT R_E_C_N_O_ AS D3RECNO, * "
			cQuery+= " FROM " + RetSqlName("SD3") + " SD3 "
			cQuery+= " WHERE SD3.D_E_L_E_T_ = '' "
			cQuery+= " AND SD3.D3_COD = '" + cProduto + "' "
			cQuery+= " AND SD3.D3_LOCAL = '" + cLocal + "' "
			cQuery+= " AND SD3.D3_LOTECTL  = '" + cLoteCtl + "' "
			cQuery+= " AND SD3.D3_FILIAL  = '" + xFilial("SD3") + "' "
			
			cQuery := ChangeQuery(cQuery)

			DbCommitAll()			
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"QRY3",.T.,.T.)
			dbSelectArea("QRY3")
			Do While !Eof()
				dbSelectArea("SD3")
				dbGoTo(QRY3->D3RECNO)
				Reclock("SD3",.F.)
				SD3->D3_DTVALID := dNewDtVal
				SD3->(MsUnlock())
				SD3->(DbSkip())
				dbSelectArea("QRY3")
				dbSkip()
			EndDo
			QRY3->(dbCloseArea())
			
			
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณSeleciono os items que precisam ser alterados.ณ
			//ณSD1 - ITENS DE NOTA FISCAL DE ENTRADA         ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			cQuery:= " SELECT R_E_C_N_O_ AS D1RECNO, * "
			cQuery+= " FROM " + RetSqlName("SD1") + " SD1 "
			cQuery+= " WHERE SD1.D_E_L_E_T_ = '' "
			cQuery+= " AND SD1.D1_COD = '" + cProduto + "' "
			cQuery+= " AND SD1.D1_LOCAL = '" + cLocal + "' "
			cQuery+= " AND SD1.D1_LOTECTL  = '" + cLoteCtl + "' "
			cQuery+= " AND SD1.D1_FILIAL  = '" + xFilial("SD1") + "' "
			
			cQuery := ChangeQuery(cQuery)
			
			DbCommitAll()
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"QRY4",.T.,.T.)
			dbSelectArea("QRY4")
			Do While !Eof()
				dbSelectArea("SD1")
				dbGoTo(QRY4->D1RECNO)
				Reclock("SD1",.F.)
				SD1->D1_DTVALID := dNewDtVal
				SD1->(MsUnlock())
				SD1->(DbSkip())
				dbSelectArea("QRY4")
				dbSkip()
			EndDo
			QRY4->(dbCloseArea())
			
			
			//ณSeleciono os items que precisam ser alterados.ณ
			//ณSD2 - ITENS DE NOTA FISCAL DE SAIDA           ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			cQuery:= " SELECT R_E_C_N_O_ AS D2RECNO, * "
			cQuery+= " FROM " + RetSqlName("SD2") + " SD2 "
			cQuery+= " WHERE SD2.D_E_L_E_T_ = '' "
			cQuery+= " AND SD2.D2_COD = '" + cProduto + "' "
			cQuery+= " AND SD2.D2_LOCAL = '" + cLocal + "' "
			cQuery+= " AND SD2.D2_LOTECTL  = '" + cLoteCtl + "' "
			cQuery+= " AND SD2.D2_FILIAL  = '" + xFilial("SD2") + "' "
			
			cQuery := ChangeQuery(cQuery)

			DbCommitAll()
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"QRY5",.T.,.T.)
			dbSelectArea("QRY5")
			Do While !Eof()
				dbSelectArea("SD2")
				dbGoTo(QRY5->D2RECNO)
				Reclock("SD2",.F.)
				SD2->D2_DTVALID := dNewDtVal
				SD2->(MsUnlock())
				SD2->(DbSkip())
				dbSelectArea("QRY5")
				dbSkip()
			EndDo
			QRY5->(dbCloseArea())
			
			//ณSeleciono os items que precisam ser alterados.ณ
			//ณSC9 - PEDIDOS LIBERADOS                       ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			cQuery:= " SELECT R_E_C_N_O_ AS C9RECNO, * "
			cQuery+= " FROM " + RetSqlName("SC9") + " SC9 "
			cQuery+= " WHERE SC9.D_E_L_E_T_ = '' "
			cQuery+= " AND SC9.C9_PRODUTO = '" + cProduto + "' "
			cQuery+= " AND SC9.C9_LOCAL = '" + cLocal + "' "
			cQuery+= " AND SC9.C9_LOTECTL  = '" + cLoteCtl + "' "
			cQuery+= " AND SC9.C9_FILIAL  = '" + xFilial("SC9") + "' "
			
			cQuery := ChangeQuery(cQuery)
			
			DbCommitAll()
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"QRY6",.T.,.T.)
			dbSelectArea("QRY6")
			Do While !Eof()
				dbSelectArea("SC9")
				dbGoTo(QRY6->C9RECNO)
				Reclock("SC9",.F.)
				SC9->C9_DTVALID := dNewDtVal
				SC9->(MsUnlock())
				SC9->(DbSkip())
				dbSelectArea("QRY6")
				dbSkip()
			EndDo
			QRY6->(dbCloseArea())
			
		
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณSeleciono os items que precisam ser alterados.ณ
			//ณSDD - BLOQUEIO DE LOTES                       ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			cQuery:= " SELECT R_E_C_N_O_ AS DDRECNO, * "
			cQuery+= " FROM " + RetSqlName("SDD") + " SDD "
			cQuery+= " WHERE SDD.D_E_L_E_T_ = '' "
			cQuery+= " AND SDD.DD_PRODUTO = '" + cProduto + "' "
			cQuery+= " AND SDD.DD_LOCAL =   '" + cLocal   + "' "
			cQuery+= " AND SDD.DD_LOTECTL = '" + cLoteCtl + "' "
			cQuery+= " AND SDD.DD_FILIAL  = '" + xFilial("SDD") + "' "
			
			cQuery := ChangeQuery(cQuery)

			DbCommitAll()
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"QRY7",.T.,.T.)
			dbSelectArea("QRY7")
			Do While !Eof()
				dbSelectArea("SDD")
				dbGoTo(QRY7->DDRECNO)
				Reclock("SDD",.F.)
				SDD->DD_DTVALID := dNewDtVal
				SDD->(MsUnlock())
				SDD->(DbSkip())
				dbSelectArea("QRY7")
				dbSkip()
			EndDo
			QRY7->(dbCloseArea())   
			
			*/
			End Transaction
			
			// Atualiza Log
			cRegAlt := "C๓digo: "+Alltrim(cProduto)+" Lote: "+cLoteCtl+" Local: "+cLocal+"  Old_Dtvalid: " +dtoC(dOldDtVal)+ " New_DtValid: " +dtoC(dNewDtVal) + " Usuแrio: " + Chr(13) + Chr(10)
			GrvLog(cRegAlt)
		EndIf
	EndIf
Next x


Return
/////////////////////////////////////////////////////////////////////////////////////////////////////////

Static Function ValDate()

Local _lRetorno := .T.

// Pede senha para data de validade menor que seis meses
If dNewDtVal < DATE()
	Alert("A data de validade tem que ser maior que a data atual!")
	_lRetorno := .F.
Endif

If _lRetorno
	If dNewDtVal < DATE()+180
	   _lRetorno := U_SENHA("DTV",0,0,0)
	Endif                                                  
Endif

Return(_lRetorno)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ GrvLog   บAutor  ณCONSULTORIA         บ Data ณ  20/12/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRotina para gravacao do LOG do SB2                          บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function GrvLog(_cString)
If !File("\ajusta-dtvalid\LOG_DTVALID.LOG")
	nHandle := MsfCreate("\ajusta-dtvalid\LOG_DTVALID.LOG",0)
Else
	nHandle := FOpen("\ajusta-dtvalid\LOG_DTVALID.LOG",2)
	fSeek(nHandle,0,2)
EndIf
If nHandle > 0         
	FWrite(nHandle,AllTrim(Upper(U_DipUsr()))+' ; '+DtoC(dDataBase)+' ; '+Time()+ ' ; '+_cString +Chr(13)+Chr(10)) 
    FClose(nHandle)
EndIf
Return
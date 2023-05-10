/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TELATMKB  ºAutor  ³Reginaldo Borges    º Data ³  08/13/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Essa tela sera usada para o envio de e-mail no TMK,         º±±
±±º          |quando registrado ou alterado um atendimento.               º±±                                             
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/


#INCLUDE "PROTHEUS.CH"
#INCLUDE  "Ap5Mail.ch"

#DEFINE DS_MODALFRAME 128

User Function telatmkb() 
 
Local   _nI       := 0
Local   cOrig     := ""
Local   cNcm      := ""
Local   _lRet     := .T.
Local   cEmail    := ""
Local   _cCic     := ""
Local   cQuery    := ''  
Private cPosProd  := aScan(aHeader, { |x| Alltrim(x[2]) == "UD_PRODUTO" })
Private cPosDesc  := aScan(aHeader, { |x| Alltrim(x[2]) == "UD_DESCPRO" })
Private cPosDoc   := aScan(aHeader, { |x| Alltrim(x[2]) == "UD_XNFORI" })
Private _cNusePth := ""
Private _cEusePth := ""
Private _nX
Private aAllusers := FWSFALLUSERS()
Private oLbx
Private _aMsg     := {}
Private oEmail
Private _cEmail   := SPACE(250)
Private oCIC
Private cCIC      := SPACE(250)
Private oMEMO
Private cMEMO     := ""
Private oMEMO1
Private cMEMO1    := ""
Private oFont16   := TFont():New("Times New Roman",9,16,.T.,.T.,5,.T.,5,.T.,.F.)
Private oFont12   := TFont():New("Arial",9,12,.T.,.T.,5,.T.,5,.T.,.F.)
Private _cStaCld  := SUC->UC_STATUS
Private cStatus   := M->UC_STATUS
Private cStatusEv := M->UC_XSTAEV
Private cSUDCld   := GetNewPar("ES_SUDCLD","lourival.nunes@dipromed.com.br")
Private cSUDTlv   := GetNewPar("ES_SUDTLV","marcia.ornellas@dipromed.com.br")
Private cSUDApo   := GetNewPar("ES_SUDAPO","patricia.mendonca@dipromed.com.br")
Private cSUDLic   := GetNewPar("ES_SUDLIC","patricia.mendonca@dipromed.com.br")
Private cCodVend  := Posicione("SA1",1,xFilial("SA1")+SUC->UC_CLIENTE,"A1_VEND")
Private cNomVend  := Posicione("SA3",1,xFilial("SA3")+cCodVend,"A3_NOME")

For nX := 1 To Len(aAllusers)
	If aAllusers[nX][2] == __cUserId
		_cNusePth := Upper(aAllusers[nX][4])
		_cEusePth := AllTrim(aAllusers[nX][5])
	EndIf
Next

ZZL->(DbSelectArea("ZZL"))
ZZL->(DbSetOrder(1))


If !cStatus $ "3/4"
	
	If     AllTrim(cStatus) == "1"
		_cEmail := AllTrim(Posicione("ZZL",1,xFilial("ZZL")+"000001","ZZL_EMAIL"))+Space(200)
		cCIC    := AllTrim(Posicione("ZZL",1,xFilial("ZZL")+"000001","ZZL_CIC"))+Space(200)
		If ! (_cEusePth $ SUC->UC_XEMENC .Or._cEusePth $ SUC->UC_XEMENCE)
			If !LEN(ALLTRIM(SUC->UC_XEMENC )) > 200
				M->UC_XEMENC := AllTrim(SUC->UC_XEMENC)+";"+_cEusePth
			Else
				M->UC_XEMENCE := AllTrim(SUC->UC_XEMENCE)+";"+_cEusePth
			EndIf
		EndIf
	ElseIf AllTrim(cStatus) == "2"
		_cEmail := AllTrim(Posicione("ZZL",1,xFilial("ZZL")+"000002","ZZL_EMAIL"))+Space(200)
		cCIC    := AllTrim(Posicione("ZZL",1,xFilial("ZZL")+"000002","ZZL_CIC"))+Space(200)
		If ! (_cEusePth $ SUC->UC_XEMENC .Or._cEusePth $ SUC->UC_XEMENCE)
			If !LEN(ALLTRIM(SUC->UC_XEMENC )) > 200
				M->UC_XEMENC := AllTrim(SUC->UC_XEMENC)+";"+_cEusePth
			Else
				M->UC_XEMENCE := AllTrim(SUC->UC_XEMENCE)+";"+_cEusePth
			EndIf
		EndIf
	ElseIf AllTrim(cStatus) == "3"
		_cEmail := AllTrim(Posicione("ZZL",1,xFilial("ZZL")+"000003","ZZL_EMAIL"))+Space(200)
		cCIC    := AllTrim(Posicione("ZZL",1,xFilial("ZZL")+"000003","ZZL_CIC"))+Space(200)
		If ! (_cEusePth $ SUC->UC_XEMENC .Or._cEusePth $ SUC->UC_XEMENCE)
			If !LEN(ALLTRIM(SUC->UC_XEMENC )) > 200
				M->UC_XEMENC := AllTrim(SUC->UC_XEMENC)+";"+_cEusePth
			Else
				M->UC_XEMENCE := AllTrim(SUC->UC_XEMENCE)+";"+_cEusePth
			EndIf
		EndIf
	ElseIf AllTrim(cStatus) == "4"
		_cEmail := AllTrim(Posicione("ZZL",1,xFilial("ZZL")+"000004","ZZL_EMAIL"))+Space(200)
		cCIC    := AllTrim(Posicione("ZZL",1,xFilial("ZZL")+"000004","ZZL_CIC"))+Space(200)
		If ! (_cEusePth $ SUC->UC_XEMENC .Or._cEusePth $ SUC->UC_XEMENCE)
			If !LEN(ALLTRIM(SUC->UC_XEMENC )) > 200
				M->UC_XEMENC := AllTrim(SUC->UC_XEMENC)+";"+_cEusePth
			Else
				M->UC_XEMENCE := AllTrim(SUC->UC_XEMENCE)+";"+_cEusePth
			EndIf
		EndIf
	ElseIf AllTrim(cStatus) == "5"
		_cEmail := AllTrim(Posicione("ZZL",1,xFilial("ZZL")+"000005","ZZL_EMAIL"))+Space(200)
		cCIC    := AllTrim(Posicione("ZZL",1,xFilial("ZZL")+"000005","ZZL_CIC"))+Space(200)
		If ! (_cEusePth $ SUC->UC_XEMENC .Or._cEusePth $ SUC->UC_XEMENCE)
			If !LEN(ALLTRIM(SUC->UC_XEMENC )) > 200
				M->UC_XEMENC := AllTrim(SUC->UC_XEMENC)+";"+_cEusePth
			Else
				M->UC_XEMENCE := AllTrim(SUC->UC_XEMENCE)+";"+_cEusePth
			EndIf
		EndIf
	ElseIf AllTrim(cStatus) == "6"
		_cEmail := AllTrim(Posicione("ZZL",1,xFilial("ZZL")+"000006","ZZL_EMAIL"))+Space(200)
		cCIC    := AllTrim(Posicione("ZZL",1,xFilial("ZZL")+"000006","ZZL_CIC"))+Space(200)
		If ! (_cEusePth $ SUC->UC_XEMENC .Or._cEusePth $ SUC->UC_XEMENCE)
			If !LEN(ALLTRIM(SUC->UC_XEMENC )) > 200
				M->UC_XEMENC := AllTrim(SUC->UC_XEMENC)+";"+_cEusePth
			Else
				M->UC_XEMENCE := AllTrim(SUC->UC_XEMENCE)+";"+_cEusePth
			EndIf
		EndIf
	ElseIf AllTrim(cStatus) == "7"
		_cEmail := AllTrim(Posicione("ZZL",1,xFilial("ZZL")+"000007","ZZL_EMAIL"))+Space(200)
		cCIC    := AllTrim(Posicione("ZZL",1,xFilial("ZZL")+"000007","ZZL_CIC"))+Space(200)
		If ! (_cEusePth $ SUC->UC_XEMENC .Or._cEusePth $ SUC->UC_XEMENCE)
			If !LEN(ALLTRIM(SUC->UC_XEMENC )) > 200
				M->UC_XEMENC := AllTrim(SUC->UC_XEMENC)+";"+_cEusePth
			Else
				M->UC_XEMENCE := AllTrim(SUC->UC_XEMENCE)+";"+_cEusePth
			EndIf
		EndIf
	ElseIf AllTrim(cStatus) == "8"
		_cEmail := AllTrim(Posicione("ZZL",1,xFilial("ZZL")+"000008","ZZL_EMAIL"))+Space(200)
		cCIC    := AllTrim(Posicione("ZZL",1,xFilial("ZZL")+"000008","ZZL_CIC"))+Space(200)
		If ! (_cEusePth $ SUC->UC_XEMENC .Or._cEusePth $ SUC->UC_XEMENCE)
			If !LEN(ALLTRIM(SUC->UC_XEMENC )) > 200
				M->UC_XEMENC := AllTrim(SUC->UC_XEMENC)+";"+_cEusePth
			Else
				M->UC_XEMENCE := AllTrim(SUC->UC_XEMENCE)+";"+_cEusePth
			EndIf
		EndIf
	ElseIf AllTrim(cStatus) == "9"
		_cEmail := AllTrim(Posicione("ZZL",1,xFilial("ZZL")+"000009","ZZL_EMAIL"))+Space(200)
		cCIC    := AllTrim(Posicione("ZZL",1,xFilial("ZZL")+"000009","ZZL_CIC"))+Space(200)
		If ! (_cEusePth $ SUC->UC_XEMENC .Or._cEusePth $ SUC->UC_XEMENCE)
			If !LEN(ALLTRIM(SUC->UC_XEMENC )) > 200
				M->UC_XEMENC := AllTrim(SUC->UC_XEMENC)+";"+_cEusePth
			Else
				M->UC_XEMENCE := AllTrim(SUC->UC_XEMENCE)+";"+_cEusePth
			EndIf
		EndIf
	ElseIf AllTrim(cStatus) == "10"
		_cEmail := AllTrim(Posicione("ZZL",1,xFilial("ZZL")+"000010","ZZL_EMAIL"))+Space(200)
		cCIC    := AllTrim(Posicione("ZZL",1,xFilial("ZZL")+"000010","ZZL_CIC"))+Space(200)
		If ! (_cEusePth $ SUC->UC_XEMENC .Or._cEusePth $ SUC->UC_XEMENCE)
			If !LEN(ALLTRIM(SUC->UC_XEMENC )) > 200
				M->UC_XEMENC := AllTrim(SUC->UC_XEMENC)+";"+_cEusePth
			Else
				M->UC_XEMENCE := AllTrim(SUC->UC_XEMENCE)+";"+_cEusePth
			EndIf
		EndIf
	ElseIf AllTrim(cStatus) == "11"
		_cEmail := AllTrim(Posicione("ZZL",1,xFilial("ZZL")+"000011","ZZL_EMAIL"))+Space(200)
		cCIC    := AllTrim(Posicione("ZZL",1,xFilial("ZZL")+"000011","ZZL_CIC"))+Space(200)
		If ! (_cEusePth $ SUC->UC_XEMENC .Or._cEusePth $ SUC->UC_XEMENCE)
			If !LEN(ALLTRIM(SUC->UC_XEMENC )) > 200
				M->UC_XEMENC := AllTrim(SUC->UC_XEMENC)+";"+_cEusePth
			Else
				M->UC_XEMENCE := AllTrim(SUC->UC_XEMENCE)+";"+_cEusePth
			EndIf
		EndIf
	ElseIf AllTrim(cStatus) == "12"
		_cEmail := AllTrim(Posicione("ZZL",1,xFilial("ZZL")+"000012","ZZL_EMAIL"))+Space(200)
		cCIC    := AllTrim(Posicione("ZZL",1,xFilial("ZZL")+"000012","ZZL_CIC"))+Space(200)
		If ! (_cEusePth $ SUC->UC_XEMENC .Or._cEusePth $ SUC->UC_XEMENCE)
			If !LEN(ALLTRIM(SUC->UC_XEMENC )) > 200
				M->UC_XEMENC := AllTrim(SUC->UC_XEMENC)+";"+_cEusePth
			Else
				M->UC_XEMENCE := AllTrim(SUC->UC_XEMENCE)+";"+_cEusePth
			EndIf
		EndIf
	ElseIf AllTrim(cStatus) == "13"
		_cEmail := AllTrim(Posicione("ZZL",1,xFilial("ZZL")+"000013","ZZL_EMAIL"))+Space(200)
		cCIC    := AllTrim(Posicione("ZZL",1,xFilial("ZZL")+"000013","ZZL_CIC"))+Space(200)
		If ! (_cEusePth $ SUC->UC_XEMENC .Or._cEusePth $ SUC->UC_XEMENCE)
			If !LEN(ALLTRIM(SUC->UC_XEMENC )) > 200
				M->UC_XEMENC := AllTrim(SUC->UC_XEMENC)+";"+_cEusePth
			Else
				M->UC_XEMENCE := AllTrim(SUC->UC_XEMENCE)+";"+_cEusePth
			EndIf
		EndIf
	ElseIf AllTrim(cStatus) == "14"
		_cEmail := AllTrim(Posicione("ZZL",1,xFilial("ZZL")+"000014","ZZL_EMAIL"))+Space(200)
		cCIC    := AllTrim(Posicione("ZZL",1,xFilial("ZZL")+"000014","ZZL_CIC"))+Space(200)
		If ! (_cEusePth $ SUC->UC_XEMENC .Or._cEusePth $ SUC->UC_XEMENCE)
			If !LEN(ALLTRIM(SUC->UC_XEMENC )) > 200
				M->UC_XEMENC := AllTrim(SUC->UC_XEMENC)+";"+_cEusePth
			Else
				M->UC_XEMENCE := AllTrim(SUC->UC_XEMENCE)+";"+_cEusePth
			EndIf
		EndIf
	ElseIf AllTrim(cStatus) == "15"
		_cEmail := AllTrim(Posicione("ZZL",1,xFilial("ZZL")+"000015","ZZL_EMAIL"))+Space(200)
		cCIC    := AllTrim(Posicione("ZZL",1,xFilial("ZZL")+"000015","ZZL_CIC"))+Space(200)
		If ! (_cEusePth $ SUC->UC_XEMENC .Or._cEusePth $ SUC->UC_XEMENCE)
			If !LEN(ALLTRIM(SUC->UC_XEMENC )) > 200
				M->UC_XEMENC := AllTrim(SUC->UC_XEMENC)+";"+_cEusePth
			Else
				M->UC_XEMENCE := AllTrim(SUC->UC_XEMENCE)+";"+_cEusePth
			EndIf
		EndIf
	ElseIf AllTrim(cStatus) == "16"
		_cEmail := AllTrim(Posicione("ZZL",1,xFilial("ZZL")+"000016","ZZL_EMAIL"))+Space(200)
		cCIC    := AllTrim(Posicione("ZZL",1,xFilial("ZZL")+"000016","ZZL_CIC"))+Space(200)
		If ! (_cEusePth $ SUC->UC_XEMENC .Or._cEusePth $ SUC->UC_XEMENCE)
			If !LEN(ALLTRIM(SUC->UC_XEMENC )) > 200
				M->UC_XEMENC := AllTrim(SUC->UC_XEMENC)+";"+_cEusePth
			Else
				M->UC_XEMENCE := AllTrim(SUC->UC_XEMENCE)+";"+_cEusePth
			EndIf
		EndIf
	ElseIf AllTrim(cStatus) == "17"
		_cEmail := AllTrim(Posicione("ZZL",1,xFilial("ZZL")+"000018","ZZL_EMAIL"))+Space(200)
		cCIC    := AllTrim(Posicione("ZZL",1,xFilial("ZZL")+"000018","ZZL_CIC"))+Space(200)
		If ! (_cEusePth $ SUC->UC_XEMENC .Or._cEusePth $ SUC->UC_XEMENCE)
			If !LEN(ALLTRIM(SUC->UC_XEMENC )) > 200
				M->UC_XEMENC := AllTrim(SUC->UC_XEMENC)+";"+_cEusePth
			Else
				M->UC_XEMENCE := AllTrim(SUC->UC_XEMENCE)+";"+_cEusePth
			EndIf
		EndIf
	ElseIf AllTrim(cStatus) == "18"
		_cEmail := AllTrim(Posicione("ZZL",1,xFilial("ZZL")+"000019","ZZL_EMAIL"))+Space(200)
		cCIC    := AllTrim(Posicione("ZZL",1,xFilial("ZZL")+"000019","ZZL_CIC"))+Space(200)
		If ! (_cEusePth $ SUC->UC_XEMENC .Or._cEusePth $ SUC->UC_XEMENCE)
			If !LEN(ALLTRIM(SUC->UC_XEMENC )) > 200
				M->UC_XEMENC := AllTrim(SUC->UC_XEMENC)+";"+_cEusePth
			Else
				M->UC_XEMENCE := AllTrim(SUC->UC_XEMENCE)+";"+_cEusePth
			EndIf
		EndIf			
	EndIf
Else                                            	
	
	_cEmail:=(SUC->UC_XEMENC)+(SUC->UC_XEMENCE)

EndIf

If cEmpAnt == '01'
	If _cStaCld $ "10/11/15/16"
		
		_cEmail :=AllTrim(_cEmail)+";"+AllTrim(Posicione("ZZL",1,xFilial("ZZL")+"000017","ZZL_EMAIL"))+Space(200)
		cCIC    :=AllTrim(cCIC)+";"+AllTrim(Posicione("ZZL",1,xFilial("ZZL")+"000017","ZZL_CIC"))+Space(200)
		
	EndIf
EndIf



If ! AllTrim(cStatus) $ cStatusEv
	M->UC_XSTAEV := AllTrim(cStatus+" / "+cStatusEv )
EndIf

If cEmpAnt == '01'
	Dbselectarea("SUD")
	DbSetOrder(1)
	DbSeek(xFilial("SUD")+M->UC_CODIGO)
	
	If     SUD->UD_ASSUNTO $ "000008"
		
		_cEmail:=AllTrim(_cEmail)+";"+AllTrim(cSUDTlv)
		
	ElseIf SUD->UD_ASSUNTO $ "000009/000010"
		
		_cEmail:=AllTrim(_cEmail)+";"+AllTrim(cSUDApo)
		
	ElseIf SUD->UD_ASSUNTO $ "000011"
		
		_cEmail:=AllTrim(_cEmail)+";"+AllTrim(cSUDCld)
		
	EndIf
EndIf


FOR _nI := 1 TO Len(aCols)
	If !Empty(aCols[_nI,cPosProd])
		cOrig    := Posicione("SB1",1,xFilial("SB1")+aCols[_nI,cPosProd],"B1_ORIGEM")
		cNcm     := Posicione("SB1",1,xFilial("SB1")+aCols[_nI,cPosProd],"B1_POSIPI")
		aadd(_aMsg,{aCols[_nI,cPosProd],aCols[_nI,cPosDesc],cNcm,cOrig})
	EndIf
Next


If M->UC_OBS =""
	cMemo1 := "Não há histórico para esse SAC!"
Else
	cMemo1 := M->UC_OBS
EndIf

If	AllTrim(cStatus) == "14"
	
	cQuery := "SELECT C5_NUM, C5_OPERADO, C5_VEND1, U7_NOME, U7_EMAIL, U7_CICNOME, F2_DOC "
	cQuery += " FROM " + RetSQLName("SC5") + ", " + RetSQLName("SF2") + ", " + RetSQLName("SU7")
	cQuery += " WHERE C5_FILIAL  = '"+xFilial("SC5")+"'"
	cQuery += "   AND F2_FILIAL  = '"+xFilial("SF2")+"'"
	cQuery += "   AND U7_FILIAL  = '"+xFilial("SU7")+"'"
	cQuery += "   AND F2_DOC     = '"+acols[1,cPosDoc]+"'"
	cQuery += "   AND F2_SERIE   = '003'"
	cQuery += "   AND C5_NOTA    = F2_DOC"
	cQuery += "   AND C5_SERIE   = F2_SERIE"
	cQuery += "   AND C5_CLIENTE = F2_CLIENTE"
	cQuery += "   AND C5_LOJACLI = F2_LOJA"
	cQuery += "   AND U7_COD     = C5_OPERADO"
	cQuery += "   AND " + RetSQLName("SC5") + ".D_E_L_E_T_ <> '*'"
	cQuery += "   AND " + RetSQLName("SF2") + ".D_E_L_E_T_ <> '*'"
	cQuery += "   AND " + RetSQLName("SU7") + ".D_E_L_E_T_ <> '*'"
	
	cQuery := ChangeQuery(cQuery)
	
	DbCommitAll()
	DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"_QRYOPER",.T.,.T.)
	
	dbSelectArea("_QRYOPER")
	dbGotop()
	
	cEmail := _QRYOPER->U7_EMAIL
	_cCic  := _QRYOPER->U7_CICNOME
	
	_cEmail :=AllTrim(_cEmail)+";"+AllTrim(cEmail)
	cCIC    :=AllTrim(cCIC)+","+AllTrim(_cCic)
	
EndIf

DEFINE MSDIALOG oDlg TITLE "Envio de E-mail e CIC" FROM 000,000 TO 720,580 PIXEL Style DS_MODALFRAME

@ 010,005 SAY "Em-Para:"   SIZE 170,20 PIXEL OF oDLG
@ 010,030 MSGET oEmail VAR _cEmail SIZE 250,10 PIXEL OF oDLG

@ 025,005 SAY "CIC:"   SIZE 200,10 PIXEL OF oDLG
@ 025,030 MSGET oCIC VAR cCIC PICTURE "@!" SIZE 250,010 OF ODLG PIXEL

@ 040,005 SAY "Vendedor:" font oFont16  COLOR CLR_BLUE SIZE 200,15 Pixel
@ 040,045 GET cNomVend WHEN .F. font oFont16  COLOR CLR_RED SIZE 235,10 Pixel

If  Len(_aMsg) > 0
	@ 055,030 LISTBOX oLbx FIELDS HEADER "Codigo", "Produto" SIZE 250,40 OF oDlg PIXEL
	oLbx:SetArray( _aMsg )
	oLbx:bLine := {|| {_aMsg[oLbx:nAt,1],_aMsg[oLbx:nAt,2]}}
EndIf

@ 100,030 SAY "Mensagem:" SIZE 030,010 PIXEL OF ODLG
@ 110,030 GET oMemo VAR cMemo Memo SIZE 200,050 PIXEL OF ODLG

@ 165,030 SAY "Historico:" SIZE 030,010 PIXEL OF ODLG
@ 175,030 GET oMemo1 VAR cMemo1 Memo SIZE 200,180 PIXEL OF ODLG

@ 110,235 BUTTON oBOTAOOK     PROMPT "&OK"              SIZE 040,010 PIXEL OF oDLG ACTION (Grava()     , oDLG:END())
@ 130,235 BUTTON oBOTAOFECHAR PROMPT "&Fechar"          SIZE 040,010 PIXEL OF oDLG ACTION (RetF(@_lRet), oDLG:END())
@ 150,235 BUTTON oBOTAOPROD   PROMPT "&Produtos"        SIZE 040,010 PIXEL OF oDLG ACTION (_Produt())


ACTIVATE MSDIALOG oDlg CENTERED

If	AllTrim(cStatus) == "14"
	_QRYOPER->(dbCloseArea())
EndIf

RETURN (_lRet)  
               
/*-----------------------------------------------------------------------------------
REGINALDO BORGES 13/08/2012
Função........:  GRAVA()                                
Objetivo......: Gravar as informações da MsDialog
-------------------------------------------------------------------------------------*/
STATIC FUNCTION GRAVA()  

Local nI         := 0
Local _aMsgE     := {} 
Local _cMsgCic   := "" 
Local _cMsg      := ""
Local cNomeCli   := ""
Local cTipoCli   := ""
Local cMunCli    := ""
Local cUFCli     := ""
Local _cPedido   := ""
Local _cNfiscal  := ""
Local _cOperador := ""
Local _cVendedor := ""
Local _cTitulos  := ""
Local _cFrom     := "protheus@dipromed.com.br"
Local _cFuncSent := "TELATMKB"
Local  cEnd	  	 := CHR(10)+CHR(13)
Local cHora      := Time()  
Local _cUsuario  := Upper(u_DipUsr())
Local _cAssunto  := If (INCLUI,"INCLUSÃO do SAC: ","OBSERVAÇÃO no SAC: ") +M->UC_CODIGO+"-"+AllTrim(SM0->M0_NOME)+"/"+SM0->M0_FILIAL
Local _cAssuntob := _cAssunto 
Local _cAssunto  := EncodeUTF8(If (INCLUI,"INCLUSÃO do SAC: ","OBSERVAÇÃO no SAC: ") +M->UC_CODIGO+"-"+AllTrim(SM0->M0_NOME)+"/"+SM0->M0_FILIAL,"cp1252")
Private cPosDoc  := aScan(aHeader, { |x| Alltrim(x[2]) == "UD_XNFORI" })

If !Empty(acols[1,cPosDoc])          
	U_C5OPEVEN(@_cPedido,@_cNfiscal,@_cOperador,@_cVendedor,@_cTitulos)
EndIf

cNomeCli := Posicione("SA1",1,xFilial("SA1")+M->UC_CLIENTE,"A1_NOME")
cTipoCli := Posicione("SA1",1,xFilial("SA1")+M->UC_CLIENTE,"A1_TIPO")
cMunCli  := Posicione("SA1",1,xFilial("SA1")+M->UC_CLIENTE,"A1_MUNE")
cUFCli   := Posicione("SA1",1,xFilial("SA1")+M->UC_CLIENTE,"A1_EST")

If Len(cMemo) >= 2
	M->UC_OBS := AllTrim(_cNusePth)+" - "+AllTrim(DTOC(dDataBase))+" - "+AllTrim(cHora)+": "+;
	             CHR(10)+CHR(13)+AllTrim(cMEMO)+CHR(10)+CHR(13)+CHR(10)+CHR(13)+AllTrim(M->UC_OBS)
EndIf             

_cMsgCic += _cAssuntob+cEnd//"OBSERVAÇÃO NO SAC: "+M->UC_CODIGO+"-"+AllTrim(SM0->M0_NOME)+"/"+SM0->M0_FILIAL+cEnd
_cMsgCic += "USUÁRIO:   "+_cNusePth+cEnd
_cMsgCic += "MENSAGEM:  "+cMemo+cEnd
_cMsgCic += cEnd
               
 
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Definicao do cabecalho do email                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   
	cMsg := ""
	cMsg += '<html>'
	cMsg += '<head>'
	cMsg += '<title>' + _cAssunto +'</title>'
	cMsg += '</head>'
	cMsg += '<body>'
	cMsg += '<HR Width=100% Size=3 Align=Centered Color=Red> <P>'
	cMsg += '<Table Border=1 Align=Center BorderColor=#000000 CELLPADDING=4 CELLSPACING=0 Width=100%>'
	cMsg += '<Caption> <FONT COLOR=#000000 FACE= "ARIAL" SIZE=5>' +_cAssuntob+ '</FONT> </Caption></table>'

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Definicao do texto/detalhe do email                                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
     cMsg += '<table width="100%" border="1" cellspacing="0" cellpadding="0"><font size="2" color="blue">'
	 cMsg += '<td width="25%" align=center >Pedido      </td>'
	 cMsg += '<td width="25%" align=center >Nota Fiscal </td>'
	 cMsg += '<td width="25%" align=center >Operador    </td>'	 
	 cMsg += '<td width="25%" align=center >Vendedor    </td>'
	 cMsg += '</table>'
     If !Empty(_cPedido) .Or. !Empty(_cNfiscal) .Or. !Empty(_cOperador) .Or. !Empty(_cVendedor)              
		 cMsg += '<table width="100%" border="1" cellspacing="0" cellpadding="0">'
		 cMsg += '<tr bgcolor="#FFFAFA">'
		 cMsg += '<td width="25%" align=center ><font  size="2">' +_cPedido  + '</font></td>'
		 cMsg += '<td width="25%" align=center ><font  size="2">' +_cNfiscal + '</font></td>'
		 cMsg += '<td width="25%" align=center ><font  size="2">' +_cOperador+ '</font></td>			
		 cMsg += '<td width="25%" align=center ><font  size="2">' +_cVendedor+ '</font></td>
		 cMsg += '</tr>'
		 cMsg += '</table>'
	 EndIf 
     cMsg += '<table width="100%" border="1" cellspacing="0" cellpadding="0"><font size="2" color="blue">'
	 cMsg += '<td width="25%" align=center >Titulos </td>'
	 cMsg += '<td width="75%" align=center   ><font size=2> '+_cTitulos+'</td>'
	 cMsg+= '</font></table>'	    
	   
     cMsg += '<BR>'    
     cMsg += '<TR>'
	 cMsg += '<TD colspan="10"><Font Color=#000000 Size="2" Face="Arial"><B>CLIENTE: </B>' +M->UC_CLIENTE+" - "+cNomeCli+" - "+'<B>TIPO: </B>'+cTipoCli+" - "+'<B>MUNICIPIO ENT: </B>'+cMunCli+" - "+'<B>ESTADO: </B>'+cUFCli+'</Font></TD>'
	 cMsg += '</TR>'                   
     cMsg += '<BR>'
	 cMsg += '<table width="100%" border="1" cellspacing="0" cellpadding="0"><font size="2" color="blue">'
	 cMsg += '<td width="15%" align=center >Produto   </td>'
	 cMsg += '<td width="60%" align=center >Descrição </td>'
	 cMsg += '<td width="15%" align=center >NCM       </td>'	 
	 cMsg += '<td width="10%" align=center >Origem    </td>'
	 cMsg+= '</font></table>'	 
	 For nI := 1 to Len(_aMsg)
		nLin:= nI
		If Mod(nLin,2) == 0
			cMsg += '<table width="100%" border="1" cellspacing="0" cellpadding="0">'
			cMsg += '<tr bgcolor="#FFFAFA">'
			cMsg += '<td width="15%" ><font  size="2">' +_aMsg[nLin,1]+ '</font></td>'
			cMsg += '<td width="60%" ><font  size="2">' +_aMsg[nLin,2]+ '</font></td>'
			cMsg += '<td width="15%" ><font  size="2">' +_aMsg[nLin,3]+ '</font></td>			
			cMsg += '<td width="10%" ><font  size="2">' +_aMsg[nLin,4]+ '</font></td>
			cMsg += '</tr>'
			cMsg += '</table>'
		Else
			cMsg += '<table width="100%" border="1" cellspacing="0" cellpadding="0">'
			cMsg += '<tr bgcolor="#CDC9C9">'
			cMsg += '<td width="15%" ><font  size="2">' +_aMsg[nLin,1]+ '</font></td>'
			cMsg += '<td width="60%" ><font  size="2">' +_aMsg[nLin,2]+ '</font></td>'
			cMsg += '<td width="15%" ><font  size="2">' +_aMsg[nLin,3]+ '</font></td>			
			cMsg += '<td width="10%" ><font  size="2">' +_aMsg[nLin,4]+ '</font></td>
			cMsg += '</tr>'
			cMsg += '</table>'
		EndIf	
	 Next 
	 cMsg += '<table width="100%" border="1" cellspacing="0" cellpadding="0">'
     cMsg += '<tr>'
     cMsg += '<td colspan="2" align="center"><font color="red" size="5">Mensagem</font></td>'
     cMsg += '</tr>'
     cMsg += '<tr>'
	 cMsg += '<td colspan="4"><B><Font Color=#000000 Size="2" Face="Arial">'+_cNusePth+":</B> "+cMemo+ ' </Font></td>'
	 cMsg += '</tr></table>'
	 cMsg += '<table width="100%" border="1" cellspacing="0" cellpadding="0">'
	 cMsg += '<tr>'
	 cMsg += '<td colspan="4" align="center"><font color="red" size="5">Histórico</font></td>'
     cMsg += '</tr>' 
     cMsg += '<tr>'	    
	 cMsg += '<td colspan="10"> <Font Color=#000000 Size="2" Face="Arial">' +cMemo1+ ' </Font></td>'
	 cMsg += '</tr></table>'

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Definicao do rodape do email                                                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ    
	
	cMsg += '</Table>'
	cMsg += '<P>'
	cMsg += '<Table align="center">'
	cMsg += '<tr>'
	cMsg += '<td colspan="10" align="center"><font color="red" size="3">Mensagem enviada automaticamente pelo sistema PROTHEUS - <font color="red" size="1">('+_cFuncSent+')</td>'
	cMsg += '</tr>'
	cMsg += '</Table>'
	cMsg += '<HR Width=85% Size=3 Align=Centered Color=Red> <P>'
	cMsg += '</body>'
	cMsg += '</html>' 

If cEmpAnt+cFilAnt == '0401'
	If AllTrim(cStatus) <> "2"
		If	AllTrim(cStatus) == "14"
			If MsgYesNo("Adicionar E-mail e Cic?","ATENCAO!")
				EmVend(@_cEmail,@cCIC)
			EndIf
		EndIf
	EndIf
EndIf
    
	U_UEnvMail(_cEmail,_cAssunto,nil,"",_cFrom,_cFuncSent,cMsg)
	
If !cStatus $ "3/4"
	U_DIPCIC(_cMsgCic,cCIC)//envia cic
EndIf	
                                          	
RETURN  
 
/*-----------------------------------------------------------------------------------
REGINALDO BORGES 14/08/2015
Função........:  RetF()                                
Objetivo......: Retornar falso no botão confirmar para os usuários contidos no
                parametro.
-------------------------------------------------------------------------------------*/


STATIC FUNCTION RetF(_lRet)                                

Local cUcStatus    := GetNewPar("ES_UCTATUS","EPONTOLDIO")  

   If UPPER(U_DipUsr()) $ cUcStatus
   		_lRet := .F.
   EndIf           

RETURN

/*-----------------------------------------------------------------------------------
REGINALDO BORGES 18/10/2015
Função........:  EmVend()                                
Objetivo......: Incluir e-mail e CIC adicionais ao enviar uma mensagem.
-------------------------------------------------------------------------------------*/ 

STATIC FUNCTION EmVend(_cEmail,cCIC)

Local   oDlg, oEmail, oCic 
Local   cQuery:= ''
Local   cEmail:= Space(160)
Local   _cCic := Space(160)


DEFINE MSDIALOG oDlg FROM 0,0 TO 100,480 PIXEL TITLE 'Email e Cic Adicional'
/*
cQuery := "SELECT C5_NUM, C5_OPERADO, C5_VEND1, U7_NOME, U7_EMAIL, U7_CICNOME, F2_DOC "
cQuery += " FROM " + RetSQLName("SC5") + ", " + RetSQLName("SF2") + ", " + RetSQLName("SU7")
cQuery += " WHERE C5_FILIAL  = '"+xFilial("SC5")+"'"
cQuery += "   AND F2_FILIAL  = '"+xFilial("SF2")+"'"
cQuery += "   AND U7_FILIAL  = '"+xFilial("SU7")+"'"
cQuery += "   AND F2_DOC     = '"+acols[1,2]+"'"
cQuery += "   AND F2_SERIE   = '003'"
cQuery += "   AND C5_NOTA    = F2_DOC"
cQuery += "   AND C5_SERIE   = F2_SERIE"
cQuery += "   AND C5_CLIENTE = F2_CLIENTE"
cQuery += "   AND C5_LOJACLI = F2_LOJA"
cQuery += "   AND U7_COD     = C5_OPERADO"
cQuery += "   AND " + RetSQLName("SC5") + ".D_E_L_E_T_ <> '*'"
cQuery += "   AND " + RetSQLName("SF2") + ".D_E_L_E_T_ <> '*'"
cQuery += "   AND " + RetSQLName("SU7") + ".D_E_L_E_T_ <> '*'"

cQuery := ChangeQuery(cQuery)

DbCommitAll()
DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"_QRYOPER",.T.,.T.)

dbSelectArea("_QRYOPER")
dbGotop()

cEmail := _QRYOPER->U7_EMAIL 
_cCic  := _QRYOPER->U7_CICNOME

*/ 

If cEmpAnt+cFilant == '0401'
	@ 010,10 SAY "Email:" SIZE 020,010 PIXEL OF ODLG
	@ 010,25 MSGET oEmail VAR cEmail SIZE 200,10 OF oDlg PIXEL F3"XU7TMK"
	@ 025,10 SAY "Cic:" SIZE 020,010 PIXEL OF ODLG
	@ 025,25 MSGET oCic   VAR _cCic   SIZE 200,10 OF oDlg PIXEL
	@ 040,110 BUTTON oBOTAOOK PROMPT "&OK" SIZE 030,010 PIXEL OF oDLG ACTION (GravaEm(@_cEmail,@cCIC,cEmail,_cCic), oDLG:END())
	
	ACTIVATE MSDIALOG oDlg CENTERED
	
	//_QRYOPER->(dbCloseArea())
	
	RETURN(_cEmail,cCIC)
EndIf


/*-----------------------------------------------------------------------------------
REGINALDO BORGES 14/08/2015
Função........:  GravaEm()
Objetivo......: Concatenar os e-mails  e Cic´s adicionais aos já existentes.
-------------------------------------------------------------------------------------*/
              
STATIC FUNCTION  GravaEm(_cEmail,cCIC,cEmail,_cCic)

_cEmail :=AllTrim(_cEmail)+AllTrim(cEmail)+";"
cCIC    :=AllTrim(cCIC)+AllTrim(_cCic)+","

Return(_cEmail,cCIC)
 
/*-----------------------------------------------------------------------------------
REGINALDO BORGES 21/10/2015
Função........: _Produt()                                
Objetivo......: Visualizar o cadastro de produtos.
-------------------------------------------------------------------------------------*/

STATIC FUNCTION _Produt()

Local cAlias  := "SB1" 
Local cTitulo := "Cadastro de Produtos" 


dbSelectArea(cAlias) 
dbSetOrder(1) 

AxCadastro(cAlias,cTitulo)            

Return

/*-----------------------------------------------------------------------------------
REGINALDO BORGES 24/10/2015
Função........:  C5OPER()                              
Objetivo......: Mostrar uma janela gerada por uma MsDialog com os dados do operador e
                vendedor do pedido, entre outras informações. 
-------------------------------------------------------------------------------------*/

USER FUNCTION C5OPER()                               

Local cMsg      := ''
Local _aCampos  := {}
Local cQuery    := ''
Local lRet      := .T.
Local cGetNota  := space(9)
Local cNotaInf  := ''
Local _cNota    := ''
Local _cTitulos := '' 
Local _cUsrSAC1 :=  GetNewPar("ES_SAC_SC" ,"RBORGES")
Private oFont24 := TFont():New("Times New Roman",9,24,.T.,.T.,5,.T.,5,.T.,.F.)
Private oFont16 := TFont():New("Arial",9,14,.T.,.T.,5,.T.,5,.T.,.F.)
Private oFont30 := TFont():New("Arial",9,28,.T.,.T.,5,.T.,5,.T.,.F.)
Private cPosDoc := aScan(aHeader, { |x| Alltrim(x[2]) == "UD_XNFORI" })


U_DIPPROC(ProcName(0),U_DipUsr()) // Gravando o nome do Programa no SZU


Define msDialog oDlg Title "NOTA FISCAL" From 10,10 TO 15,040

@ 010,010 say "N. Fiscal "  font oFont24  COLOR CLR_BLUE Pixel
@ 010,045 get cGetNota  	when .t. font oFont16  COLOR CLR_RED SIZE 010,10 Pixel
@ 025,050 BUTTON oBOTAOOK PROMPT "&Confirmar"          SIZE 040,010 PIXEL OF oDLG ACTION (RetNf(cGetNota,@cNotaInf), oDLG:END())

Activate dialog oDlg centered

If !Empty(cNotaInf)
	_cNota := cNotaInf
Else
	_cNota := acols[1,cPosDoc]
EndIf


If INCLUI .Or. UPPER(U_DipUsr()) $ _cUsrSAC1
	
	cQuery := "SELECT C5_NUM, C5_OPERADO, C5_VEND1, U7_NOME, U7_EMAIL, F2_DOC, E1_PARCELA, E1_VENCTO   "
	cQuery += " FROM " + RetSQLName("SC5") + ", " + RetSQLName("SF2") + ", " + RetSQLName("SU7")+ ", " + RetSQLName("SE1")
	cQuery += " WHERE C5_FILIAL  = '"+xFilial("SC5")+"'"
	cQuery += "   AND F2_FILIAL  = '"+xFilial("SF2")+"'"
	cQuery += "   AND U7_FILIAL  = '"+xFilial("SU7")+"'"  
	cQuery += "   AND E1_FILIAL  = '"+xFilial("SE1")+"'"		
	cQuery += "   AND F2_DOC     = '"+_cNota+"'"
	cQuery += "   AND F2_SERIE   = '003'"
	cQuery += "   AND C5_NOTA    = F2_DOC"
	cQuery += "   AND C5_SERIE   = F2_SERIE"
	cQuery += "   AND C5_CLIENTE = F2_CLIENTE"
	cQuery += "   AND C5_LOJACLI = F2_LOJA" 
	cQuery += "   AND E1_NUM     = F2_DOC"
	cQuery += "   AND E1_SERIE   = F2_SERIE"
	cQuery += "   AND E1_CLIENTE = F2_CLIENTE"
	cQuery += "   AND E1_LOJA    = F2_LOJA"	
	cQuery += "   AND U7_COD     = C5_OPERADO"
	cQuery += "   AND " + RetSQLName("SC5") + ".D_E_L_E_T_ <> '*'"
	cQuery += "   AND " + RetSQLName("SF2") + ".D_E_L_E_T_ <> '*'"
	cQuery += "   AND " + RetSQLName("SU7") + ".D_E_L_E_T_ <> '*'"  
	cQuery += "   AND " + RetSQLName("SE1") + ".D_E_L_E_T_ <> '*'"		
	
	cQuery := ChangeQuery(cQuery)
	
	DbCommitAll()
	DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"QRYOPER",.T.,.T.)
             
	dbSelectArea("QRYOPER")
	dbGotop()
	
	While ! QRYOPER->(EOF())
    
  		_cTitulos += QRYOPER->E1_PARCELA+" - "+DTOC(STOD(QRYOPER->E1_VENCTO))+"    "
  
   		QRYOPER->(DbSkip())
	End
	
	dbSelectArea("QRYOPER")
	dbGotop()
	
	Define msDialog oDlg Title "OPERADOR DO PEDIDO" From 10,10 TO 35,100
	
	@ 017,010 say "Pedido   :............"   font oFont24  COLOR CLR_BLUE Pixel
	@ 037,010 say "Operador :........."      font oFont24  COLOR CLR_BLUE Pixel
	@ 057,010 say "Nome Oper:......." 	     font oFont24  COLOR CLR_BLUE Pixel
	@ 077,010 say "E-mail   :............"   font oFont24  COLOR CLR_BLUE Pixel
	@ 097,010 say "Vendedor :........."      font oFont24  COLOR CLR_BLUE Pixel
	@ 117,010 say "Nome Vend:......"         font oFont24  COLOR CLR_BLUE Pixel
	@ 137,010 say "N. Fiscal:............"   font oFont24  COLOR CLR_BLUE Pixel
	@ 157,010 say "Titulos  :............"   font oFont24  COLOR CLR_BLUE Pixel
	
	@ 010,090 get alltrim(QRYOPER->C5_NUM)  	when .f. font oFont16  COLOR CLR_RED SIZE 200,15 Pixel
	@ 030,090 get alltrim(QRYOPER->C5_OPERADO)  when .f. font oFont16  COLOR CLR_RED SIZE 200,15 Pixel
	@ 050,090 get alltrim(QRYOPER->U7_NOME) 	when .f. font oFont16  COLOR CLR_RED SIZE 200,15 Pixel
	@ 070,090 get alltrim(QRYOPER->U7_EMAIL)	when .f. font oFont16  COLOR CLR_RED SIZE 200,15 Pixel
	@ 090,090 get alltrim(QRYOPER->C5_VEND1)  	when .f. font oFont16  COLOR CLR_RED SIZE 200,15 Pixel
	@ 110,090 get alltrim(Posicione("SA3",1,xFilial("SA3")+QRYOPER->C5_VEND1,"A3_NOME")) when .f. font oFont16  COLOR CLR_RED SIZE 200,15 Pixel
	@ 130,090 get alltrim(QRYOPER->F2_DOC)      when .f. font oFont16  COLOR CLR_RED SIZE 200,15 Pixel
	@ 150,090 get alltrim(_cTitulos)            when .t. font oFont16  COLOR CLR_RED SIZE 250,15 Pixel	
	
	Activate dialog oDlg centered
	
	QRYOPER->(dbCloseArea())
	
EndIf


RETURN (lRet)


/*-----------------------------------------------------------------------------------
REGINALDO BORGES 12/11/2015
Função........:  C5OPEVEN()                              
Objetivo......: Carregar as variáveis com o nome do operador e vendedor do pedido.
-------------------------------------------------------------------------------------*/

USER FUNCTION C5OPEVEN(_cPedido,_cNfiscal,_cOperador,_cVendedor,_cTitulos)                               

Local cQuery    := ''
Local _cNota    := ''
Private cPosDoc   := aScan(aHeader, { |x| Alltrim(x[2]) == "UD_XNFORI" })

_cNota := acols[1,cPosDoc]
	
	cQuery := "SELECT C5_NUM, C5_OPERADO, C5_VEND1, U7_NOME, U7_EMAIL, F2_DOC, E1_PARCELA, E1_VENCTO, E1_VALOR  "
	cQuery += " FROM " + RetSQLName("SC5") + ", " + RetSQLName("SF2") + ", " + RetSQLName("SU7")+ ", " + RetSQLName("SE1")
	cQuery += " WHERE C5_FILIAL  = '"+xFilial("SC5")+"'"
	cQuery += "   AND F2_FILIAL  = '"+xFilial("SF2")+"'"
	cQuery += "   AND U7_FILIAL  = '"+xFilial("SU7")+"'"
	cQuery += "   AND E1_FILIAL  = '"+xFilial("SE1")+"'"	
	cQuery += "   AND F2_DOC     = '"+_cNota+"'"
	cQuery += "   AND F2_SERIE   = '003'"
	cQuery += "   AND C5_NOTA    = F2_DOC"
	cQuery += "   AND C5_SERIE   = F2_SERIE"
	cQuery += "   AND C5_CLIENTE = F2_CLIENTE"
	cQuery += "   AND C5_LOJACLI = F2_LOJA"   
	cQuery += "   AND E1_NUM     = F2_DOC"
	cQuery += "   AND E1_SERIE   = F2_SERIE"
	cQuery += "   AND E1_CLIENTE = F2_CLIENTE"
	cQuery += "   AND E1_LOJA    = F2_LOJA"
	cQuery += "   AND U7_COD     = C5_OPERADO"
	cQuery += "   AND " + RetSQLName("SC5") + ".D_E_L_E_T_ <> '*'"
	cQuery += "   AND " + RetSQLName("SF2") + ".D_E_L_E_T_ <> '*'"
	cQuery += "   AND " + RetSQLName("SU7") + ".D_E_L_E_T_ <> '*'"
	cQuery += "   AND " + RetSQLName("SE1") + ".D_E_L_E_T_ <> '*'"	
	
	cQuery := ChangeQuery(cQuery)
	
	DbCommitAll()
	DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"OPERVEN",.T.,.T.)
	
	dbSelectArea("OPERVEN")
	dbGotop() 
  _cPedido	:= OPERVEN->C5_NUM
  _cNfiscal	:= OPERVEN->F2_DOC
  _cOperador:= OPERVEN->U7_NOME
  _cVendedor:= alltrim(Posicione("SA3",1,xFilial("SA3")+OPERVEN->C5_VEND1,"A3_NOME"))
 
  
  While ! OPERVEN->(EOF())
    
  	_cTitulos +="("+OPERVEN->E1_PARCELA+" - "+DTOC(STOD(OPERVEN->E1_VENCTO))+" "+CVALTOCHAR(OPERVEN->E1_VALOR)+")  "
  
  	OPERVEN->(DbSkip())
  End
  
  
   OPERVEN->(dbCloseArea())
		
Return

/*-----------------------------------------------------------------------------------
REGINALDO BORGES 28/01/2016
Função........:  NFDIFAL()                                
Objetivo......: Verificará toda as linhas do acols, caso seja mais de uma, e se os
				produtos, conforme Nfs, têm difencial de ICMS.
				Reginaldo Borges 22/08/2019
				Adicionado o campo D2_ICMSRET para verificar se o item tem ST.
-------------------------------------------------------------------------------------*/

User Function NFDIFAL(_cNota,dEmissao,cProd,nDifal,cEstDifal,nProdSt)

Local cQuery    := ''

cQuery := "SELECT D2_DOC,D2_SERIE,D2_ITEM,D2_COD,D2_ICMSCOM,D2_DIFAL,D2_EST, D2_ICMSRET "
cQuery += " FROM " + RetSQLName("SD2")
cQuery += " WHERE D2_FILIAL  = '"+xFilial("SD2")+"'"
cQuery += "   AND D2_DOC     = '"+_cNota+"'"
cQuery += "   AND D2_SERIE   = '003'"       
cQuery += "   AND D2_EMISSAO = '"+DTOS(dEmissao)+"'"
cQuery += "   AND D2_COD     = '"+cProd+"'"
cQuery += "   AND (D2_DIFAL   > 0 OR D2_ICMSRET > 0)"
cQuery += "   AND D_E_L_E_T_ <> '*' "
cQuery += "ORDER BY D2_DOC,D2_ITEM, D2_COD "

cQuery := ChangeQuery(cQuery)

DbCommitAll()
DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"D2DIFAL",.T.,.T.)

dbSelectArea("D2DIFAL")
dbGotop()

If !D2DIFAL->(Eof())

	cEstDifal := AllTrim(D2DIFAL->D2_EST)
	nDifal    := D2DIFAL->D2_DIFAL
	nProdSt   := D2DIFAL->D2_ICMSRET

EndIf

D2DIFAL->(dbCloseArea())

Return(nDifal,cEstDifal,nProdSt)

/*-----------------------------------------------------------------------------------
REGINALDO BORGES 28/01/2016
Função........:  NFDIFALA()                                
Objetivo......:  Mostrar os produtos da nota fiscal informada pelo usuario que têm
				 Diferenciais de ICMS.	
-------------------------------------------------------------------------------------*/

User Function NFDIFALA()  

Local cQuery   := ''
Local cGetNota := space(9)
Local cNotaInf := ''
Local _cNota   :=''
Local _ADIFALA :={}
Local oFont24  := TFont():New("Times New Roman",9,24,.T.,.T.,5,.T.,5,.T.,.F.)
Local oFont16  := TFont():New("Arial",9,14,.T.,.T.,5,.T.,5,.T.,.F.)
Local oFont30  := TFont():New("Arial",9,28,.T.,.T.,5,.T.,5,.T.,.F.)
Private oLbx     
Private nIcmsCom := 0
Private nVlDifal := 0
Private cPosDoc   := aScan(aHeader, { |x| Alltrim(x[2]) == "UD_XNFORI" })

U_DIPPROC(ProcName(0),U_DipUsr()) // Gravando o nome do Programa no SZU

Define msDialog oDlg Title "NOTA FISCAL" From 10,10 TO 15,040

@ 010,010 say "N. Fiscal "  font oFont24  COLOR CLR_BLUE Pixel
@ 010,045 get cGetNota  	when .t. font oFont16  COLOR CLR_RED SIZE 010,10 Pixel
@ 025,050 BUTTON oBOTAOOK PROMPT "&Confirmar" SIZE 040,010 PIXEL OF oDLG ACTION (RetNf(cGetNota,@cNotaInf), oDLG:END())

Activate dialog oDlg centered

If !Empty(cNotaInf)
	_cNota := cNotaInf
Else
	_cNota := acols[1,cPosDoc]
EndIf

cQuery := "SELECT D2_DOC,D2_SERIE,D2_ITEM,D2_COD,D2_ICMSCOM,D2_DIFAL, D2_ICMSRET "
cQuery += " FROM " + RetSQLName("SD2")
cQuery += " WHERE D2_FILIAL  = '"+xFilial("SD2")+"'"
cQuery += "   AND D2_DOC     = '"+_cNota+"'"
cQuery += "   AND D2_SERIE   = '003'"
cQuery += "   AND (D2_DIFAL  > 0 OR D2_ICMSRET > 0) "
cQuery += "   AND D_E_L_E_T_ <> '*' "
cQuery += "ORDER BY D2_DOC,D2_ITEM, D2_COD "

cQuery := ChangeQuery(cQuery)

DbCommitAll()
DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"D2DIFALA",.T.,.T.)

dbSelectArea("D2DIFALA")
dbGotop()

While ! D2DIFALA->(Eof())

nIcmsCom := Transform(D2DIFALA->D2_ICMSCOM,"@E 999,999.999")
nVlDifal := Transform(D2DIFALA->D2_DIFAL,"@E 999,999.999")
nVlrST   := Transform(D2DIFALA->D2_ICMSRET,"@E 999,999.999")
	*                 1                 3                4                  5                  6       7     8
	aadd(_aDifala,{D2DIFALA->D2_DOC,D2DIFALA->D2_SERIE,D2DIFALA->D2_ITEM, D2DIFALA->D2_COD,nIcmsCom,nVlDifal,nVlrST})
	
	D2DIFALA->(DbSkip())
EndDo

If  Len(_aDifala) > 0

	Define msDialog oDlg Title "Nota Fiscal com Diferencial de ICMS ou ST" From 000,000 TO 015,065
		
	@ 005,005 LISTBOX oLbx FIELDS HEADER "Documento", "Serie", "Item", "Produto", "ICMSCom", "Difal" , "ST" SIZE 250,090 OF oDlg PIXEL
	oLbx:SetArray( _aDifala )
	oLbx:bLine := {|| {_aDifala[oLbx:nAt,1],_aDifala[oLbx:nAt,2],_aDifala[oLbx:nAt,3],_aDifala[oLbx:nAt,4],_aDifala[oLbx:nAt,5],_aDifala[oLbx:nAt,6],_aDifala[oLbx:nAt,7]}}
	@ 100,215 BUTTON oBOTAOFECHAR PROMPT "&Fechar" SIZE 040,010 PIXEL OF oDLG ACTION (oDLG:END())
	
	Activate dialog oDlg centered
	
Else
	MsgInfo("Não há produtos com diferencial de ICMS na NF informada.","ATENÇÃO!")
EndIf


    D2DIFALA->(dbCloseArea())


Return()

/*-----------------------------------------------------------------------------------
REGINALDO BORGES 29/01/2016
Função........:  VALPROD()                                
Objetivo......: Verificará na confirmação do registro do SAC se o produto devolvido 
				pelo Cliente saiu para doação, promoção ou está vencido.
-------------------------------------------------------------------------------------*/

User Function VALPROD(cNota,dEmissao,cProd,dDtValid,cValProd)

Local cQuery   := ''                 
Local cTesDoac :=AllTrim(GetNewPar("ES_TESDOAC","548/631/677"))

cQuery := "SELECT D2_DOC,D2_EMISSAO,D2_COD,D2_TES,D2_LOTECTL, D2_DTVALID, D2_COMIS1,DATEDIFF(DAY,D2_EMISSAO,D2_DTVALID) AS VAL_DIAS "
cQuery += " FROM " + RetSQLName("SD2")
cQuery += " WHERE D2_FILIAL  = '"+xFilial("SD2")+"'"
cQuery += "   AND D2_DOC     = '"+cNota+"'"
cQuery += "   AND D2_SERIE   = '003'"
cQuery += "   AND D2_COD     = '"+AllTrim(cProd)+"'"
cQuery += "   AND DATEDIFF(DAY,D2_EMISSAO,D2_DTVALID) < 180 "
cQuery += "   AND D2_LOTECTL <> ''  "
//cQuery += "   AND   D2_COMIS1 = 10  " 
cQuery += "   AND D_E_L_E_T_ <> '*' "
cQuery += "ORDER BY D2_DOC, D2_COD  "

cQuery := ChangeQuery(cQuery)

DbCommitAll()
DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"D2VALID",.T.,.T.)

dbSelectArea("D2VALID")
dbGotop()

While ! D2VALID->(Eof())
	
	If     ((D2VALID->VAL_DIAS > 90 .And. D2VALID->VAL_DIAS < 180) .And. (D2VALID->D2_COMIS1 == 10))
		cValProd := "P"
	ElseIf (D2VALID->VAL_DIAS > 1 .And. D2VALID->VAL_DIAS < 90) //.And. (D2VALID->D2_TES $ cTesDoac))
		cValProd := "D"
	ElseIf D2VALID->VAL_DIAS < 0
		cValProd := "V"
	EndIf
	
	D2VALID->(DbSkip())
EndDo

D2VALID->(dbCloseArea())

Return(cValProd)
                                                                               

/*-----------------------------------------------------------------------------------
REGINALDO BORGES 24/10/2015
Função........:  RetNF()                                
Objetivo......: Carregar uma derteminada varial com o valor da variavel get digitada
                pelo o usuario.
-------------------------------------------------------------------------------------*/


STATIC FUNCTION RetNf(cGetNota,cNotaInf)                          

cNotaInf := cGetNota

RETURN (cNotaInf) 

/*-----------------------------------------------------------------------------------
REGINALDO BORGES 17/05/2016
Função........:  PRODMULTCX()                                
Objetivo......: Verificará toda as linhas do acols, caso seja mais de uma, e se os
				produtos, conforme Nfs, estão na regra de venda em multiplos de caixa.
-------------------------------------------------------------------------------------*/

User Function PRODMULTCX(_cNota,dEmissao,cProd,aMultCx)

Local cQuery    := ''  
Local nQtdCxEmb := 0

cQuery := "SELECT D2_DOC,D2_SERIE,D2_ITEM,D2_COD,D2_FORNEC,B1_XQTDEMB,B1_XTPEMBV,B1_XQTDSEC "
cQuery += " FROM "+RetSqlname("SD2") +","+ RetSqlname("SB1") 
cQuery += " WHERE D2_FILIAL = '"+xFilial("SD2")+"'"
cQuery += " AND   B1_FILIAL = D2_FILIAL "
cQuery += " AND D2_DOC      = '"+_cNota+"'"
cQuery += " AND D2_SERIE    = '003' "       
cQuery += " AND D2_EMISSAO  = '"+DTOS(dEmissao)+"' "
cQuery += " AND D2_COD      = '"+AllTrim(cProd)+"' "
cQuery += " AND B1_COD      = D2_COD "
cQuery += " AND B1_PROC     = D2_FORNEC "
cQuery += " AND B1_XCXFECH  = '1' "
cQuery += " AND B1_XVLDCXE  = '1' "             
cQuery += " AND "+RetSqlName("SD2")+".D_E_L_E_T_  = ''" 
cQuery += " AND "+RetSqlName("SB1")+".D_E_L_E_T_  = ''" 
cQuery += "ORDER BY D2_DOC,D2_ITEM " 

cQuery := ChangeQuery(cQuery)

DbCommitAll()
DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"D2MCX",.T.,.T.)

dbSelectArea("D2MCX")
dbGotop()

While ! D2MCX->(Eof())
	
	If D2MCX->B1_XTPEMBV=="1"
		nQtdCxEmb := D2MCX->B1_XQTDEMB
	ElseIf D2MCX->B1_XTPEMBV=="2"
		nQtdCxEmb := D2MCX->B1_XQTDSEC
	Else
		nQtdCxEmb := 1
		
	EndIf
	
	*                  1             2               3              4             5              6
	aadd(aMultCx,{D2MCX->D2_DOC,D2MCX->D2_SERIE,D2MCX->D2_ITEM,D2MCX->D2_COD,D2MCX->D2_FORNEC,nQtdCxEmb})
	
	D2MCX->(DbSkip())
EndDo


D2MCX->(dbCloseArea())

Return(aMultCx)

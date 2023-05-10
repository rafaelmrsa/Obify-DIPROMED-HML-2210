/*
+----------+--------+-------+-------------------------+---------------------+
|Programa  |FUNCOES | Autor | Alexandro Dias          | Data | 02/07/01     |
+----------+--------+-------+-------------------------+---------------------+
|Desc.     | Funcoes de uso generico                                        |
+---------------------------------------------------------------------------+
*/
#Include "Protheus.ch"
#Include "RwMake.ch"
#Include "Ap5Mail.ch"

/*****************************************************************************
Funcao pra Retirar caracters de separa็ใo de qualquer string
*****************************************************************************/
User Function PString(_cString)

	Local _cString    := _cString
	Local _cSeparador := "=.,-\|/"
	Local _nPos
	LOCAL _nPosSep

	If ( Type("l410Auto") == "U" .OR. !l410Auto )
		U_DIPPROC(ProcName(0),U_DipUsr()) // JBS 05/10/2005 - Gravando o nome do Programa no SZU
		For _nPosSep := 1 to Len(_cSeparador)

			_nPos := 1

			While _nPos > 0
				_nPos := At(Substr(_cSeparador,_nPosSep,1),_cString)
				IF _nPos > 0
					_cString := Subst(_cString,1,_nPos-1) + Subst(_cString,_nPos+1,Len(_cString) )
				EndIF
			EndDo

		Next
	ENDIF
Return(_cString)

/*********************************************************************************
Funcao de tratamento de CEP, Retorna o Endereco, Bairro e Municipio conforme o
Cep informado -Fornecedores
*********************************************************************************/

User Function CEP_End_SA2(_cTipo,_cCep)

	Local _cRet   := &(ReadVar())
	Local _cCep   := _cCep
	Local _cTipo  := _cTipo
	Local _cCampo := ReadVar()
	Local _xArea  := GetArea()
	
	Private oModelSA2    := FWModelActive()


	If ISINCALLSTACK("LOJA901A") .Or. ISINCALLSTACK("LOJA901")
		Return(_cCep)
	EndIf

	If ( Type("l410Auto") == "U" .OR. !l410Auto )
		U_DIPPROC(ProcName(0),U_DipUsr()) // JBS 05/10/2005 - Gravando o nome do Programa no SZU

		DbSelectArea("SZB")
		Dbsetorder(2)
		IF DbSeek( xFilial("SZB") + _cCep )

			//****************************************************************
			// Pesquisa e retorna o Endereco
			//****************************************************************
			DbSelectArea("SZA")
			Dbsetorder(1)
			DbSeek(xFilial()+SZB->ZB_TIT)


			_cNum := Space(10)
			_cEnd := AllTrim(SZA->ZA_TITULO)+' '+ SZB->ZB_LOGRA

			//****************************************************************
			// Pesquisa e retorna o Bairro
			//****************************************************************
			DbSelectArea("SZ6")
			Dbsetorder(1)

			IF DbSeek(xFilial()+SZB->ZB_CODMUN+SZB->ZB_CODBAI)
				_cBairro := AllTrim(SZ6->Z6_BAIRRO)
			EndIF

			//****************************************************************
			// Pesquisa e retorna o Municipio e o Estado
			//****************************************************************
			DbSelectArea("SZ0")
			Dbsetorder(1)
			IF DbSeek(xFilial()+SZB->ZB_CODMUN)
				_cMun := AllTrim(SZ0->Z0_MUNIC)
				_cEst := SZ0->Z0_UF
			EndIF

			Private _cEsc := .F.

			While !_cEsc

				@ 000,000 TO 210,400 DIALOG oDlg TITLE "Atualizacao de Endereco"

				@ 010,010 SAY "Logradouro:"
				@ 010,044 GET _cEnd PICTURE "@!" When .F. Size 140,020

				@ 025,010 SAY "Complemento:"
				@ 025,044 GET _cNum PICTURE "@!" ValID !Empty(_cNum) Size 100,020

				@ 040,010 SAY "Bairro:"
				@ 040,044 GET _cBairro PICTURE "@!"	When .F. Size 140,020

				@ 055,010 SAY "Municipio:"
				@ 055,044 GET _cMun    PICTURE "@!"	When .F. Size 140,020

				@ 070,010 SAY "Estado:"
				@ 070,044 GET _cEst    PICTURE "@!" When .F. Size 20,020 //VALID ExistCpo("SX5","12"+_cEst) F3 "12" Size 20,020

				@ 090,130 BMPBUTTON TYPE 1 ACTION (_cEsc := .T., Close(oDlg))
				@ 090,160 BMPBUTTON TYPE 2 ACTION (_cEsc := .T.,_cTipo := "", Close(oDlg))

				ACTIVATE DIALOG oDlg CENTER

			EndDo


			_cEndCpo    := Alltrim(_cEnd) + ", " +_cNum+SPACE(60-LEN(Alltrim(_cEnd) + ", " +_cNum))
			_cBairroCpo := _cBairro+SPACE(30-LEN(_cBairro))
			_cMunCpo    := _cMun+SPACE(30-LEN(_cMun))
			_cEstCpo    := _cEst

			IF _cTipo == "1"
				oModelSA2:SetValue("SA2MASTER",Substr(_cCampo,4,3)+"END",AllTrim(_cEndCpo))
				oModelSA2:SetValue("SA2MASTER",Substr(_cCampo,4,3)+"BAIRRO",AllTrim(_cBairroCpo))
				oModelSA2:SetValue("SA2MASTER",Substr(_cCampo,4,3)+"EST",AllTrim(_cEstCpo))
				oModelSA2:SetValue("SA2MASTER",Substr(_cCampo,4,3)+"MUN",AllTrim(_cMunCpo))
			ElseIF _cTipo == "2"
				oModelSA2:SetValue("SA2MASTER",Substr(_cCampo,4,3)+"ENDCOB",AllTrim(_cEndCpo))
				oModelSA2:SetValue("SA2MASTER",Substr(_cCampo,4,3)+"BAIRROC",AllTrim(_cBairroCpo))
				oModelSA2:SetValue("SA2MASTER",Substr(_cCampo,4,3)+"ESTC",AllTrim(_cEstCpo))
				oModelSA2:SetValue("SA2MASTER",Substr(_cCampo,4,3)+"MUNC",AllTrim(_cMunCpo))
			ElseIF _cTipo == "3"
				oModelSA2:SetValue("SA2MASTER",Substr(_cCampo,4,3)+"ENDENT",AllTrim(_cEndCpo))
				oModelSA2:SetValue("SA2MASTER",Substr(_cCampo,4,3)+"BAIRROE",AllTrim(_cBairroCpo))
				oModelSA2:SetValue("SA2MASTER",Substr(_cCampo,4,3)+"ESTE",AllTrim(_cEstCpo))
				oModelSA2:SetValue("SA2MASTER",Substr(_cCampo,4,3)+"MUNE",AllTrim(_cMunCpo))
			EndIF
		Else
			DbSelectArea("SZ0")
			Dbsetorder(2)
			If DbSeek( xFilial("SZ0") + _cCep )
				_cMun := AllTrim(SZ0->Z0_MUNIC)
				_cEst := SZ0->Z0_UF

				_cEnd := Space(60)
				_cBairro := Space(30)
				_cNum := Space(10)

				Private _cEsc := .F.

				While !_cEsc

					@ 000,000 TO 210,400 DIALOG oDlg TITLE "Atualizacao de Endereco"

					@ 010,010 SAY "Logradouro:"
					@ 010,044 GET _cEnd PICTURE "@!" ValID !Empty(_cEnd) Size 140,020

					@ 025,010 SAY "Complemento:"
					@ 025,044 GET _cNum PICTURE "@!" ValID !Empty(_cNum) Size 100,020

					@ 040,010 SAY "Bairro:"
					@ 040,044 GET _cBairro PICTURE "@!"	Size 140,020

					@ 055,010 SAY "Municipio:"
					@ 055,044 GET _cMun    PICTURE "@!"	When .F. Size 140,020

					@ 070,010 SAY "Estado:"
					@ 070,044 GET _cEst    PICTURE "@!" When .F. Size 20,020 //VALID ExistCpo("SX5","12"+_cEst) F3 "12" Size 20,020

					@ 090,130 BMPBUTTON TYPE 1 ACTION (_cEsc := .T., Close(oDlg))
					@ 090,160 BMPBUTTON TYPE 2 ACTION (_cEsc := .T.,_cTipo := "", Close(oDlg))

					ACTIVATE DIALOG oDlg CENTER

				EndDo
				            _cEndCpo    := Alltrim(_cEnd) + ", " +_cNum+SPACE(60-LEN(Alltrim(_cEnd) + ", " +_cNum))
			_cBairroCpo := _cBairro+SPACE(30-LEN(_cBairro))
			_cMunCpo    := _cMun+SPACE(30-LEN(_cMun))
			_cEstCpo    := _cEst

			IF _cTipo == "1"
				oModelSA2:SetValue("SA2MASTER",Substr(_cCampo,4,3)+"END",AllTrim(_cEndCpo))
				oModelSA2:SetValue("SA2MASTER",Substr(_cCampo,4,3)+"BAIRRO",AllTrim(_cBairroCpo))
				oModelSA2:SetValue("SA2MASTER",Substr(_cCampo,4,3)+"EST",AllTrim(_cEstCpo))
				oModelSA2:SetValue("SA2MASTER",Substr(_cCampo,4,3)+"MUN",AllTrim(_cMunCpo))
			ElseIF _cTipo == "2"
				oModelSA2:SetValue("SA2MASTER",Substr(_cCampo,4,3)+"ENDCOB",AllTrim(_cEndCpo))
				oModelSA2:SetValue("SA2MASTER",Substr(_cCampo,4,3)+"BAIRROC",AllTrim(_cBairroCpo))
				oModelSA2:SetValue("SA2MASTER",Substr(_cCampo,4,3)+"ESTC",AllTrim(_cEstCpo))
				oModelSA2:SetValue("SA2MASTER",Substr(_cCampo,4,3)+"MUNC",AllTrim(_cMunCpo))
			ElseIF _cTipo == "3"
				oModelSA2:SetValue("SA2MASTER",Substr(_cCampo,4,3)+"ENDENT",AllTrim(_cEndCpo))
				oModelSA2:SetValue("SA2MASTER",Substr(_cCampo,4,3)+"BAIRROE",AllTrim(_cBairroCpo))
				oModelSA2:SetValue("SA2MASTER",Substr(_cCampo,4,3)+"ESTE",AllTrim(_cEstCpo))
				oModelSA2:SetValue("SA2MASTER",Substr(_cCampo,4,3)+"MUNE",AllTrim(_cMunCpo))
			EndIF

			Else
				MsgBox("Nao existe o Logradouro cadastrado para este CEP, informe manualmente !!!","Atencao","ALERT")
			EndIf

		EndIF

		RestArea(_xArea)
	EndIf
Return (_cRet)


/*********************************************************************************
Funcao de tratamento de CEP, Retorna o Endereco, Bairro e Municipio conforme o
Cep informado - Clientes
*********************************************************************************/

User Function CEP_EndSA1(_cTipo,_cCep)

	Local _cRet   := &(ReadVar())
	Local _cCep   := _cCep
	Local _cTipo  := _cTipo
	Local _cCampo := ReadVar()
	Local _xArea  := GetArea()
	
	Private oModel    := FWModelActive()
	

	If ISINCALLSTACK("LOJA901A") .Or. ISINCALLSTACK("LOJA901")
		Return(_cCep)
	EndIf

	If ( Type("l410Auto") == "U" .OR. !l410Auto )
		U_DIPPROC(ProcName(0),U_DipUsr()) // JBS 05/10/2005 - Gravando o nome do Programa no SZU

		DbSelectArea("SZB")
		Dbsetorder(2)
		IF DbSeek( xFilial("SZB") + _cCep )

			//****************************************************************
			// Pesquisa e retorna o Endereco
			//****************************************************************
			DbSelectArea("SZA")
			Dbsetorder(1)
			DbSeek(xFilial()+SZB->ZB_TIT)

			_cNum := Space(10)
			_cEnd := AllTrim(SZA->ZA_TITULO)+' '+ SZB->ZB_LOGRA

			//****************************************************************
			// Pesquisa e retorna o Bairro
			//****************************************************************
			DbSelectArea("SZ6")
			Dbsetorder(1)

			IF DbSeek(xFilial()+SZB->ZB_CODMUN+SZB->ZB_CODBAI)
				_cBairro := AllTrim(SZ6->Z6_BAIRRO)
			EndIF

			//****************************************************************
			// Pesquisa e retorna o Municipio e o Estado
			//****************************************************************
			DbSelectArea("SZ0")
			Dbsetorder(1)
			IF DbSeek(xFilial()+SZB->ZB_CODMUN)
				_cMun := AllTrim(SZ0->Z0_MUNIC)
				_cEst := SZ0->Z0_UF
			EndIF

			Private _cEsc := .F.

			While !_cEsc

				@ 000,000 TO 210,400 DIALOG oDlg TITLE "Atualizacao de Endereco"

				@ 010,010 SAY "Logradouro:"
				@ 010,044 GET _cEnd PICTURE "@!" When .F. Size 140,020

				@ 025,010 SAY "Complemento:"
				@ 025,044 GET _cNum PICTURE "@!" ValID !Empty(_cNum) Size 100,020

				@ 040,010 SAY "Bairro:"
				@ 040,044 GET _cBairro PICTURE "@!"	When .F. Size 140,020

				@ 055,010 SAY "Municipio:"
				@ 055,044 GET _cMun    PICTURE "@!"	When .F. Size 140,020

				@ 070,010 SAY "Estado:"
				@ 070,044 GET _cEst    PICTURE "@!" When .F. Size 20,020 //VALID ExistCpo("SX5","12"+_cEst) F3 "12" Size 20,020

				@ 090,130 BMPBUTTON TYPE 1 ACTION (_cEsc := .T., Close(oDlg))
				@ 090,160 BMPBUTTON TYPE 2 ACTION (_cEsc := .T.,_cTipo := "", Close(oDlg))

				ACTIVATE DIALOG oDlg CENTER

			EndDo
		
			IF _cTipo == "1"							
				&("M->"+Substr(_cCampo,4,3)+"END")    := Alltrim(_cEnd) + ", " +_cNum+SPACE(60-LEN(Alltrim(_cEnd) + ", " +_cNum))
				&("M->"+Substr(_cCampo,4,3)+"BAIRRO") := _cBairro+SPACE(30-LEN(_cBairro))
				&("M->"+Substr(_cCampo,4,3)+"MUN")    := _cMun+SPACE(30-LEN(_cMun))
				&("M->"+Substr(_cCampo,4,3)+"EST")    := _cEst
			ElseIF _cTipo == "2"
				&("M->"+Substr(_cCampo,4,3)+"ENDCOB") := Alltrim(_cEnd) + ", " +_cNum+SPACE(60-LEN(Alltrim(_cEnd) + ", " +_cNum))
				&("M->"+Substr(_cCampo,4,3)+"BAIRROC"):= _cBairro+SPACE(30-LEN(_cBairro))
				&("M->"+Substr(_cCampo,4,3)+"MUNC")   := _cMun+SPACE(30-LEN(_cMun))
				&("M->"+Substr(_cCampo,4,3)+"ESTC")   := _cEst
			ElseIF _cTipo == "3"
				&("M->"+Substr(_cCampo,4,3)+"ENDENT") := Alltrim(_cEnd) + ", " +_cNum+SPACE(60-LEN(Alltrim(_cEnd) + ", " +_cNum))
				&("M->"+Substr(_cCampo,4,3)+"BAIRROE"):= _cBairro+SPACE(30-LEN(_cBairro))
				&("M->"+Substr(_cCampo,4,3)+"MUNE")   := _cMun+SPACE(30-LEN(_cMun))
				&("M->"+Substr(_cCampo,4,3)+"ESTE")   := _cEst
			EndIF

		Else
			DbSelectArea("SZ0")
			Dbsetorder(2)
			If DbSeek( xFilial("SZ0") + _cCep )
				_cMun := AllTrim(SZ0->Z0_MUNIC)
				_cEst := SZ0->Z0_UF

				_cEnd := Space(60)
				_cBairro := Space(30)
				_cNum := Space(10)

				Private _cEsc := .F.

				While !_cEsc

					@ 000,000 TO 210,400 DIALOG oDlg TITLE "Atualizacao de Endereco"

					@ 010,010 SAY "Logradouro:"
					@ 010,044 GET _cEnd PICTURE "@!" ValID !Empty(_cEnd) Size 140,020

					@ 025,010 SAY "Complemento:"
					@ 025,044 GET _cNum PICTURE "@!" ValID !Empty(_cNum) Size 100,020

					@ 040,010 SAY "Bairro:"
					@ 040,044 GET _cBairro PICTURE "@!"	Size 140,020

					@ 055,010 SAY "Municipio:"
					@ 055,044 GET _cMun    PICTURE "@!"	When .F. Size 140,020

					@ 070,010 SAY "Estado:"
					@ 070,044 GET _cEst    PICTURE "@!" When .F. Size 20,020 //VALID ExistCpo("SX5","12"+_cEst) F3 "12" Size 20,020

					@ 090,130 BMPBUTTON TYPE 1 ACTION (_cEsc := .T., Close(oDlg))
					@ 090,160 BMPBUTTON TYPE 2 ACTION (_cEsc := .T.,_cTipo := "", Close(oDlg))

					ACTIVATE DIALOG oDlg CENTER

				EndDo

				IF _cTipo == "1"
					&("M->"+Substr(_cCampo,4,3)+"END")    := Alltrim(_cEnd) + ", " +_cNum+SPACE(60-LEN(Alltrim(_cEnd) + ", " +_cNum))
					&("M->"+Substr(_cCampo,4,3)+"BAIRRO") := _cBairro+SPACE(30-LEN(_cBairro))
					&("M->"+Substr(_cCampo,4,3)+"MUN")    := _cMun+SPACE(30-LEN(_cMun))
					&("M->"+Substr(_cCampo,4,3)+"EST")    := _cEst
				ElseIF _cTipo == "2"
					&("M->"+Substr(_cCampo,4,3)+"ENDCOB") := Alltrim(_cEnd) + ", " +_cNum+SPACE(60-LEN(Alltrim(_cEnd) + ", " +_cNum))
					&("M->"+Substr(_cCampo,4,3)+"BAIRROC"):= _cBairro+SPACE(30-LEN(_cBairro))
					&("M->"+Substr(_cCampo,4,3)+"MUNC")   := _cMun+SPACE(30-LEN(_cMun))
					&("M->"+Substr(_cCampo,4,3)+"ESTC")   := _cEst
				ElseIF _cTipo == "3"
					&("M->"+Substr(_cCampo,4,3)+"ENDENT") := Alltrim(_cEnd) + ", " +_cNum+SPACE(60-LEN(Alltrim(_cEnd) + ", " +_cNum))
					&("M->"+Substr(_cCampo,4,3)+"BAIRROE"):= _cBairro+SPACE(30-LEN(_cBairro))
					&("M->"+Substr(_cCampo,4,3)+"MUNE")   := _cMun+SPACE(30-LEN(_cMun))
					&("M->"+Substr(_cCampo,4,3)+"ESTE")   := _cEst
				EndIf

			Else
				MsgBox("Nao existe o Logradouro cadastrado para este CEP, informe manualmente !!!","Atencao","ALERT")
			EndIf

		EndIF

		RestArea(_xArea)
	EndIf
Return (_cRet)

/*/
*****************************************************************************
** Funcao     GeraHexa    Autor   Alexandro Dias          Data   23.08.01  **
*****************************************************************************
** Descricao  Gera _cNumero hexadecimal.                                     **
*****************************************************************************
/*/

User Function GeraHexa(_cValor)

	Private _cNumero := Space(06)
	Private _nResto  := 0
	If ( Type("l410Auto") == "U" .OR. !l410Auto )
		U_DIPPROC(ProcName(0),U_DipUsr()) // JBS 05/10/2005 - Gravando o nome do Programa no SZU

		IF "A1_" $ Upper(Readvar())

			IF Len(Alltrim(M->A1_CGC)) > 11
				_nDiv  := Val(Substr(M->A1_CGC,1,8))
			Else
				_nDiv  := Int(Val(Alltrim(M->A1_CGC))/100)
			EndIF

		ElseIF "A2_" $ Upper(Readvar())

			IF Len(Alltrim(M->A2_CGC)) > 11
				_nDiv  := Val(Substr(M->A2_CGC,1,8))
			Else
				_nDiv  := Int(Val(Alltrim(M->A2_CGC))/100)

			EndIF

		Else

			IF Len(_cValor) > 11
				_nDiv  := Val(Substr(_cValor,1,8))
			Else
				_nDiv  := Int(Val(Alltrim(_cValor))/100)
			EndIF

		EndIF

		Retorno_Conv := Space(06)

		While _nDiv >= 35
			_nResto := _nDiv % 35
			_nDiv     := int(_nDiv / 35)
			_cNumero:= ConvHexa(_nResto)+Alltrim(_cNumero)
		End

		_cNumero:= ConvHexa(_nDiv)+Alltrim(_cNumero)

		Retorno_Conv := replicate("0",6-Len(Alltrim(_cNumero)))+Alltrim(_cNumero)

		M->A1_COD:= Retorno_Conv
	ENDIF
Return(Retorno_Conv)

// Funcao que converte _cNumeros em letras(base 35)

Static Function ConvHexa(y)

	Do Case
		Case (y < 10)
		Return(str(Y))
		Case (y ==10)
		Return("A")
		Case y ==11
		Return("B")
		Case y ==12
		Return("C")
		Case y ==13
		Return("D")
		Case y ==14
		Return("E")
		Case y ==15
		Return("F")
		Case y ==16
		Return("G")
		Case y ==17
		Return("H")
		Case y ==18
		Return("I")
		Case y ==19
		Return("J")
		Case y ==20
		Return("K")
		Case y ==21
		Return("L")
		Case y ==22
		Return("M")
		Case y ==23
		Return("N")
		Case y ==24
		Return("O")
		Case y ==25
		Return("P")
		Case y ==26
		Return("Q")
		Case y ==27
		Return("R")
		Case y ==28
		Return("S")
		Case y ==29
		Return("T")
		Case y ==30
		Return("U")
		Case y ==31
		Return("V")
		Case y ==32
		Return("W")
		Case y ==33
		Return("X")
		Case y ==34
		Return("Y")

	EndCase

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ FUNCOES  บ Autor ณ   Alexandro Dias   บ Data ณ  27/02/02   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Envio de email                                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function UEnvMail(cEmail,cAssunto,aMsg,cAttach,cDe,cFuncSent,cHtml)
	Local lAtivJob := GetNewPar("ES_ATIVJOB",.T.)
	DEFAULT cHtml  := ""
	DEFAULT aMsg   := {}

	If lAtivJob
		u_UEnvNew(cEmail,cAssunto,aMsg,cAttach,cDe,cFuncSent,cHtml)
	Else
		u_UEnvOld(cEmail,cAssunto,aMsg,cAttach,cDe,cFuncSent)
	EndIf

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFUNCOES   บAutor  ณMicrosiga           บ Data ณ  03/06/15   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function UEnvOld(cEmail,cAssunto,aMsg,cAttach,cDe,cFuncSent)
	Local cAccount  := Lower(Alltrim(GetMv("MV_RELACNT")))
	Local cFrom     := Lower(Alltrim(GetMv("MV_RELACNT")))
	Local cPassword := Alltrim(GetMv("MV_RELPSW"))
	Local cServer   := Alltrim(GetMv("MV_RELSERV"))
	Local cEmailTo  := ""
	Local cEmailCc  := ""
	Local cEmailBcc := ""
	Local lResult   := .F.
	Local cError    := ""
	Local i         := 0
	Local cArq      := ""
	Local cMsg      := ""
	Local _nLin
	Local lSmtpAuth := GetNewPar("MV_RELAUTH",.F.)
	Local lAutOk	:= .F.
	Local cAssuntob :=DecodeUTF8(cAssunto, "cp1252")

	If ! Alltrim(cDe) $ Lower(Alltrim(GetMv("MV_RELACNT")))
		cEmail := cEmail+";"+cDe
	EndIf

	If ( Type("l410Auto") == "U" .OR. !l410Auto )
		U_DIPPROC(ProcName(0),U_DipUsr()) // JBS 05/10/2005 - Gravando o nome do Programa no SZU

		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ Definicao do cabecalho do email                                             ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		cMsg := ""
		cMsg += '<html>'
		cMsg += '<head>'
		cMsg += '<title>' + cAssunto + " - "+SM0->M0_NOME+"/"+SM0->M0_FILIAL+'</title>'
		cMsg += '</head>'
		cMsg += '<body>'
		//cMsg += '<Img Src="C:/AP5/SIGAADV/LGRL01.BMP"><BR>'
		cMsg += '<HR Width=85% Size=3 Align=Centered Color=Red> <P>'
		cMsg += '<Table Border=1 Align=Center BorderColor=#000000 CELLPADDING=4 CELLSPACING=0 Width=60%>'
		cMsg += '<Caption> <FONT COLOR=#000000 FACE= "ARIAL" SIZE=5>' + cAssuntob +" - "+SM0->M0_NOME+"/"+SM0->M0_FILIAL+ '</FONT> </Caption>'
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ Definicao do texto/detalhe do email                                         ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		For _nLin := 1 to Len(aMsg)
			IF (_nLin/2) == Int( _nLin/2 )
				cMsg += '<TR BgColor=#B0E2FF>'
			Else
				cMsg += '<TR BgColor=#FFFFFF>'
			EndIF
			cMsg += '<TD><B><Font Color=#000000 Size="2" Face="Arial">' + aMsg[_nLin,1] + ' </Font></B></TD>'
			cMsg += '<TD> <Font Color=#000000 Size="2" Face="Arial">' + aMsg[_nLin,2] + ' </Font></TD>'
			cMsg += '</TR>'
		Next
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ Definicao do rodape do email                                                ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		cMsg += '</Table>'
		cMsg += '<P>'
		cMsg += '<Table align="center">'
		cMsg += '<tr>'
		cMsg += '<td colspan="10" align="center"><font color="red" size="3">Mensagem enviada automaticamente pelo sistema PROTHEUS - <font color="red" size="1">('+cFuncSent+')</td>'
		cMsg += '</tr>'
		cMsg += '</Table>'
		cMsg += '<HR Width=85% Size=3 Align=Centered Color=Red> <P>'
		//cMsg += '<B><Font Color=#000000 Size="2" Face="Arial"> Atenciosamente </Font></B><BR>'
		//cMsg += '<B><Font Color=#000000 Size="2" Face="Arial">' + SM0->M0_NOMECOM + '</Font></B><BR>'
		//cMsg += '<Img Src="C:/AP5/SIGAADV/LGRL01.BMP">'
		cMsg += '</body>'
		cMsg += '</html>'

		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณEnvia o mail para a lista selecionada. Envia como BCC para que a pessoa penseณ
		//ณque somente ela recebeu aquele email, tornando o email mais personalizado.   ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		IF At(";",cEmail) > 0
			cEmailTo := SubStr(cEmail,1,At(";",cEmail)-1)
			cEmailCc:= SubStr(cEmail,At(";",cEmail)+1,Len(cEmail))
		Else
			cEmailTo := Alltrim(cEmail)
		EndIF

		CONNECT SMTP SERVER cServer ACCOUNT cAccount PASSWORD cPassword RESULT lResult

		If !lAutOk
			If ( lSmtpAuth )
				lAutOk := MailAuth(cAccount,cPassword)
			Else
				lAutOk := .T.
			EndIf
		EndIf

		If lResult .And. lAutOk
			SEND MAIL FROM cFrom ;
			TO      	Lower(cEmailTo);
			CC      	Lower(cEmailCc);
			BCC     	Lower(cEmailBcc);
			SUBJECT 	cAssunto;
			BODY    	cMsg;
			ATTACHMENT  cAttach;
			RESULT lResult

			If !lResult
				//Erro no envio do email
				GET MAIL ERROR cError

				MsgInfo(cError,OemToAnsi("Ateno"))
			EndIf

			DISCONNECT SMTP SERVER
		Else
			//Erro na conexao com o SMTP Server
			GET MAIL ERROR cError

			MsgInfo(cError,OemToAnsi("Ateno"))
		EndIf
	ENDIF
Return(.T.)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ FUNCOES  บ Autor ณ   Alexandro Dias   บ Data ณ  27/02/02   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Envio de email                                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function UEnvNew(cEmail,cAssunto,aMsg,cAttach,cDe,cFuncSent,cHtml)
	Local aArea	  := GetArea()
	Local nI 	  := 0
	Local cCodigo := ""
	Local cMail1  := ""
	Local cMail2  := ""
	DEFAULT cHtml := ""
	DEFAULT aMsg  := {}
	DEFAULT cDe   :=  ""

	If ! Alltrim(cDe) $ Lower(Alltrim(GetMv("MV_RELACNT")))
		cEmail := cEmail+";"+cDe
		cDe    := Lower(Alltrim(GetMv("MV_RELACNT")))
	EndIf

	dbSelectArea("ZZI")
	cCodigo := ZZI->(GetSX8Num("ZZI","ZZI_CODMSG"))
	ConfirmSX8()

	If Len(cEmail) > 250
		cMail2 := SubStr(cEmail,1,250)
		nPos := Rat(";",cMail2)
		If nPos > 0
			cMail1 := SubStr(cEmail,1,nPos)
			cMail2 := SubStr(cEmail,nPos+1,Len(cEmail))
		EndIf
	Else
		cMail1 := cEmail
	EndIf

	If Len(aMsg)>0
		For nI := 1 to Len(aMsg)
			ZZI->(RecLock("ZZI",.T.))
			ZZI->ZZI_FILIAL := xFilial("ZZI")
			ZZI->ZZI_CODMSG := cCodigo
			ZZI->ZZI_EMAIL	:= AllTrim(StrTran(cMail1," ",""))
			ZZI->ZZI_EMAIL2	:= AllTrim(StrTran(cMail2," ",""))
			ZZI->ZZI_ASSUNT := AllTrim(cAssunto)
			ZZI->ZZI_MSG1	:= AllTrim(aMsg[nI,1])
			ZZI->ZZI_MSG2	:= AllTrim(aMsg[nI,2])
			ZZI->ZZI_ANEXO	:= AllTrim(cAttach)
			ZZI->ZZI_MAILDE	:= AllTrim(StrTran(cDe," ",""))
			ZZI->ZZI_FUNCAO := AllTrim(cFuncSent)
			ZZI->ZZI_DATA 	:= dDataBase
			ZZI->ZZI_HORA	:= Time()
			ZZI->ZZI_USUARI := Upper(u_DipUsr())
			ZZI->ZZI_SEQUEN := StrZero(nI,3)
			ZZI->(MsUnLock())
		Next nI
	ElseIf !Empty(cHtml)
		ZZI->(RecLock("ZZI",.T.))
		ZZI->ZZI_FILIAL := xFilial("ZZI")
		ZZI->ZZI_CODMSG := cCodigo
		ZZI->ZZI_EMAIL	:= AllTrim(StrTran(cMail1," ",""))
		ZZI->ZZI_EMAIL2	:= AllTrim(StrTran(cMail2," ",""))
		ZZI->ZZI_ASSUNT := AllTrim(cAssunto)
		//ZZI->ZZI_MSG1	:= AllTrim(aMsg[nI,1])
		//ZZI->ZZI_MSG2	:= AllTrim(aMsg[nI,2])
		ZZI->ZZI_ANEXO	:= AllTrim(cAttach)
		ZZI->ZZI_MAILDE	:= AllTrim(StrTran(cDe," ",""))
		ZZI->ZZI_FUNCAO := AllTrim(cFuncSent)
		ZZI->ZZI_DATA 	:= dDataBase
		ZZI->ZZI_HORA	:= Time()
		ZZI->ZZI_USUARI := Upper(u_DipUsr())
		ZZI->ZZI_SEQUEN := StrZero(nI,3)
		MSMM(,TamSX3("ZZI_HTML")[1],,cHtml,1,,,"ZZI","ZZI_HTML")
		ZZI->(MsUnLock())
	EndIf

	RestArea(aArea)

Return()
/*/
*****************************************************************************
Funcao tratar o x3_inibrw do campo C9_QATU  e Z1_DESCSEG
*****************************************************************************
/*/

User Function TXTINIBRW(_cCampo)

	Local _cRet   := " "
	Local _cAlias := GetArea()
	If ( Type("l410Auto") == "U" .OR. !l410Auto )
		U_DIPPROC(ProcName(0),U_DipUsr()) // JBS 05/10/2005 - Gravando o nome do Programa no SZU

		If _cCampo=="C9_QATU"
			_cRet := RetField("SB2",1,xFilial("SB2")+SC9->C9_PRODUTO+SC9->C9_LOCAL,"SB2->B2_QATU-SB2->B2_RESERVA")
		Endif

		If _cCampo=="Z1_DESCSEG"
			_cRet := IIF(SZ1->Z1_SEGMENT=="999999","Desconto Geral",RetField("SX5",1,xFilial("SX5")+"T3"+SZ1->Z1_SEGMENT,"SX5->X5_DESCRI"))
		Endif

		RestArea(_cAlias)
	ENDIF
Return(_cRet)
/*====================================================================================\
|FUNวรO    | DipCpoWhen    | Autor | Jailton b Santos - JBS     | Data | 05/04/2006   |
|=====================================================================================|
|Descri็ใo | Esta fun็ใo controla a edi็ใo de alguns campos por parte dos usuarios    |
|          | do protheus.                                                             |
|          | Esta fun็ใo estแ substituindo as fun็๕es _W0001(),_W0002() e _W0003()    |
|=====================================================================================|
|Sintaxe   | U_DipCpoWhen(cCampo)                                                     |
|          | U_DipCpoWhen('A1_VEND')   -> _W0001()                                    |
|          | U_DipCpoWhen('A1_VENDKC')                                                |
|          | U_DipCpoWhen('UA_VEND')   -> _W0002()                                    |
|          | U_DipCpoWhen('UA_VENDKC') -> _W0002()                                    |
|          | U_DipCpoWhen('C5_VEND1')  -> _W0002()                                    |
|          | U_DipCpoWhen('C5_VEND2')  -> _W0002()                                    |
|          | U_DipCpoWhen('C6_COMIS1') -> _W0003()                                    |
|          | U_DipCpoWhen('C6_COMIS2') -> _W0003()                                    |
|          | U_DipCpoWhen('UB_COMIS1') -> _W0003()                                    |
|          | U_DipCpoWhen('UB_COMIS2') -> _W0003()                                    |
|=====================================================================================|
|Uso       | Especifico DIPROMED                                                      |
|=====================================================================================|
|........................................Hist๓rico....................................|
|          |                                                                          |
\====================================================================================*/
User Function DipCpoWhen(cCampo)
	*-------------------------------------------------------------------------------------*
	Local _cAliasSU7
	Local _cAlias    := GetArea()
	Local _lRet      := .F.
	If ( Type("l410Auto") == "U" .OR. !l410Auto )
		//U_DIPPROC(ProcName(0),U_DipUsr()) // JBS 05/10/2005 - Gravando o nome do Programa no SZU

		Do Case

			Case Upper(cCampo) == 'A1_VEND' // Antiga Funcao _W0001()
			_cAliasSU7 := SU7->(GetArea())
			If Upper(U_DipUsr()) $ 'BRODRIGUES/PMENDONCA/MCANUTO/RLOPES/RBORGES' //.or. INCLUI
				_lRet := .T.
			ElseIf Empty(M->A1_VEND)
				_lRet := .T.
			ElseIf Upper(U_DipUsr()) $ 'ANDREIA/APIRES/MCANUTO/RLOPES/RBORGES' .and. M->A1_VEND $ '006750/000353/000357/000356/000359'
				_lRet := .T.
			ElseIf Upper(U_DipUsr()) $ 'ANDREIA/APIRES/MCANUTO/RLOPES/RBORGES'
				SU7->(DBOrderNickname("SU7CODVEN"))
				If SU7->(dbSeek(xFilial('SU7')+M->A1_VEND))
					If SU7->U7_VEND == '1'
						_lRet := .T.
					EndIf
				EndIf
			EndIf
			RestArea(_cAliasSU7)

			Case Upper(cCampo) == 'A1_VENDHQ'  // MCVN - 20/08/09
			If Upper(U_DipUsr()) $ 'MCANUTO/PMENDONCA/BRODRIGUES/RLOPES/RBORGES/CSOSSOLOTE/AFERREIRA/BOLIVEIRA/POLIVEIRA/AMCARVALHO'
				_lRet := .T.
			EndIf

			Case Upper(cCampo) $ ('A1_VENDKC/A1_TECN_3/A1_TECN_R/A1_TECN_A/A1_TECNICO/A1_TECN_C')
			If Upper(U_DipUsr()) $ 'MCANUTO/BRODRIGUES/PMENDONCA/IFERREIRA/CSOSSOLOTE'
				_lRet := .T.
			EndIf

			Case Upper(cCampo) == 'UA_VEND'  .or.; // Antiga Funcao _W0002()
			Upper(cCampo) == 'UA_VENDKC'.or.;
			Upper(cCampo) == 'C5_VEND1' .or.;
			Upper(cCampo) == 'C5_VEND2'

			If Upper(U_DipUsr()) $ 'MCANUTO/DDOMINGOS/RBORGES/PMENDONCA'  // Incluํdo Patrํcia 03/2022
				_lRet := .T.
			EndIf

			Case Upper(cCampo) == 'C6_COMIS1' .or. ; // Antiga Funcao _W0003()
			Upper(cCampo) == 'C6_COMIS2' .or. ;
			Upper(cCampo) == 'UB_COMIS1' .or. ;
			Upper(cCampo) == 'UB_COMIS2'

			If Upper(U_DipUsr()) $ 'MCANUTO/PMENDONCA/DDOMINGOS/RBORGES'
				_lRet := .T.
			EndIf

			Case Upper(cCampo) == 'ZP_LOTECTL' .or. ;
			Upper(cCampo) == 'ZP_LOCALIZ'

			If Upper(U_DipUsr()) $ 'MCANUTO/DDOMINGOS/RBEAZIN/EMATIAS/RBORGES/JNOGUEIRA' .And. !("MATA410"$Funname())
				_lRet := .T.
			EndIf
		EndCase
		RestArea(_cAlias)
	ENDIF
Return(_lRet)

// PARA O WORKFLOW

USER FUNCTION UNITSCHED()
	Local aParams := {"01","01"}
	WFScheduler(aParams)
Return(.T.)

// Nosso cabecalho

User Function MYCABEC(_cTitulo,_cDesc1,_cDesc2,nHandle,cWorkFlow,cNom_For)
	Local cCabec := ""
	Local nPosic := 0
	Local nLinha := 0
	If ( Type("l410Auto") == "U" .OR. !l410Auto )
		U_DIPPROC(ProcName(0),U_DipUsr()) // JBS 05/10/2005 - Gravando o nome do Programa no SZU

		If cWorkFlow == 'N'

			@ 0,0 PSay AvalImp(Limite)
			@ 0,0 PSay Replicate('-',Limite)
			@ 1,0 PSay Alltrim(SM0->M0_NOMECOM)+' - '+Alltrim(SM0->M0_FILIAL)      // Ajustado para buscar dados no SM0 - MCVN - 15/10/09
			@ 1,Limite-LEN('Folha.: ' + Transform(m_pag,"9999")) PSay 'Folha.: ' + Transform(m_pag,"9999")
			@ 2,0 PSay nomeprog+'/'+cversao
			If limite = 220
				@ 2,INT((Limite-Iif(LEN(_cTitulo)>150,150,LEN(_cTitulo)))/2) PSay Iif(LEN(_cTitulo)>150,SubStr(_cTitulo,1,150),_cTitulo)
			ElseIf limite = 132
				@ 2,INT((Limite-Iif(LEN(_cTitulo)>80,80,LEN(_cTitulo)))/2) PSay Iif(LEN(_cTitulo)>80,SubStr(_cTitulo,1,80),_cTitulo)
			Else
				@ 2,INT((Limite-Iif(LEN(_cTitulo)>40,40,LEN(_cTitulo)))/2) PSay Iif(LEN(_cTitulo)>40,SubStr(_cTitulo,1,40),_cTitulo)
			EndIf
			@ 2,Limite-LEN('Data.: '+dTOc(dDataBase)) PSay 'Data.: '+dTOc(dDataBase)
			@ 3,0 PSay 'Hora.: '+Time()
			If !Empty(cNom_For) // impressใo na terceira linha do cabe็alho - (Rafael-11/03/2205)
				If limite = 220
					@ 3,INT((Limite-Iif(LEN(cNom_For)>150,150,LEN(cNom_For)))/2) PSay Iif(LEN(cNom_For)>150,SubStr(cNom_For,1,150),cNom_For)
				ElseIf limite = 132
					@ 3,INT((Limite-Iif(LEN(cNom_For)>80,80,LEN(cNom_For)))/2) PSay Iif(LEN(cNom_For)>80,SubStr(cNom_For,1,80),cNom_For)
				Else
					@ 3,INT((Limite-Iif(LEN(cNom_For)>40,40,LEN(cNom_For)))/2) PSay Iif(LEN(cNom_For)>40,SubStr(cNom_For,1,40),cNom_For)
				EndIf
			EndIf
			@ 3,Limite-LEN('Emissao.: '+dTOc(Date())) PSay 'Emissao.: '+dTOc(Date())

			@ 4,0 PSay Replicate('-',Limite)
			nLinha := 4
			If !Empty(_cDesc1)
				nLinha += 1
				@ nLinha,0 PSay _cDesc1
			EndIf
			If !Empty(_cDesc2)
				nLinha += 1
				@ nLinha,0 PSay _cDesc2
			EndIf
			nLinha += 1
			@ nLinha,0 PSay Replicate('-',Limite)
			nLinha += 2
			m_pag++

		Else
			cCabec += Replicate('-',Limite) + chr(13) + chr(10)
			nPosic := Limite - (Len(Alltrim(SM0->M0_NOMECOM)+' - '+SM0->M0_FILIAL) + LEN('Folha.: ' + Transform(m_pag,"9999")))
			cCabec += Alltrim(SM0->M0_NOMECOM)+' - '+SM0->M0_FILIAL
			cCabec += Space(nPosic) + 'Folha.: ' + Transform(m_pag,"9999") + chr(13) + chr(10)

			nPosic := Int( ( Limite/2 ) - ( Len(Iif(LEN(_cTitulo)>40,SubStr(_cTitulo,1,40),_cTitulo) ) / 2 ) ) + 1
			cCabec += nomeprog+'/'+Left(cversao,8)
			nPosic := nPosic - Len(nomeprog+'/'+Space(8) )
			cCabec += Space(nPosic) + Iif(LEN(_cTitulo)>40,SubStr(_cTitulo,1,40),_cTitulo)

			nPosic := (Limite - (Len(nomeprog+'/'+Space(8)) + nPosic + Iif(LEN(_cTitulo)>40,40,LEN(_cTitulo))))
			nPosic := nPosic - Len('Data.: '+dTOc(dDataBase))
			cCabec += Space(nPosic) + 'Data.: '+dTOc(dDataBase) + chr(13) + chr(10)

			nPosic := Limite - ((Len('Hora.: '+Time())) + Len('Emissao.: '+dTOc(Date())))
			cCabec += 'Hora.: '+Time()
			cCabec += Space(20) + '(AGENDADO)'
			cCabec += Space(17) + 'Emissao.: '+dTOc(Date()) + chr(13) + chr(10)
			cCabec += Replicate('-',Limite) + chr(13) + chr(10)
			nLinha := 4
			If !Empty(_cDesc1)
				cCabec +=  _cDesc1 + chr(13) + chr(10)
				nLinha += 1
			EndIf
			If !Empty(_cDesc2)
				cCabec +=  _cDesc2 + chr(13) + chr(10)
				nLinha += 1
			EndIf
			cCabec +=  Replicate('-',Limite) + chr(13) + chr(10)
			nLinha += 2
			Fwrite(nHandle,cCabec)

			m_pag++
		EndIf
	ENDIF
	Return(nLinha)

	********** ultimo dia do mes *****************
User Function LastDay(dInicio)
	Local    nMes    := Month(dInicio)
	Local    nAno    := Year(dInicio)
	Local    dRetDat    := CtoD("")
	If ( Type("l410Auto") == "U" .OR. !l410Auto )
		U_DIPPROC(ProcName(0),U_DipUsr()) // JBS 05/10/2005 - Gravando o nome do Programa no SZU

		If nMes = 12
			nMes := 01
			nAno ++
		Else
			nMes++
		EndIf
		dDatRet := CtoD( "01/" + StrZero( nMes, 2 ) + "/" + StrZero( nAno,4 ) ) - 1
	ENDIF
Return( dDatRet )

/*==========================================================================\
|Programa  | D3_EXPLIC | Autor | Rafael de Campos Falco  | Data | 07/06/2004|
|===========================================================================|
|Descri็ใo | Digita explica็ใo do movimento do estoque                      |
|===========================================================================|
|Sintaxe   | D3_EXPLIC                                                      |
|===========================================================================|
|Uso       | Especifico DIPROMED                                            |
|===========================================================================|
|Hist๓rico | DD/MM/AA - Descri็ใo da altera็ใo                              |
\==========================================================================*/

User Function D3_EXPLIC(_d3doc,_DEONDE)
	Local cExp_Mov := Space(220)
	Local _xAlias  := GetArea()
	Private lSaida := .T.

	If Upper(U_DipUsr()) $ 'ERIBERTO/EELIAS'
		cExp_Mov := "Departamento de T.I. - testando melhorias no Protheus."+space(144)
	EndIf
	If (Type("lAutoma261")!="U" .And. lAutoma261)
		cExp_Mov := Left("Transferencia Automatica - realizada pelo sistema"+Space(220),220)
	EndIf
	//If ( Type("l410Auto") == "U" .OR. !l410Auto )
	If ( Type("l410Auto") == "U" .OR. !l410Auto ) .And. (Type("lAutoma261")=="U" .Or. !lAutoma261) // tratamento tb p/ transf. mod2 automatica
		U_DIPPROC(ProcName(0),U_DipUsr()) // JBS 05/10/2005 - Gravando o nome do Programa no SZU

		While lSaida
			@ 126,000 To 270,300 DIALOG oDlg TITLE OemToAnsi(_DEONDE)
			@ 015,015 Say "Documento: "+_d3doc
			@ 030,015 Get cExp_Mov Size 120,20 Picture "@S80" Valid !Empty(cExp_Mov)
			@ 050,055 BmpButton Type 1 Action (Ok(cExp_Mov),Close(oDlg))
			ACTIVATE DIALOG oDlg Centered
		End

		RestArea(_xAlias)
	ENDIF
Return(cExp_MoV)

Static Function Ok(cExp_Mov)
	If Len(AllTrim(cExp_Mov)) > 25
		// Eriberto 13/02/2006 Close(oDlg)
		lSaida := .F.
	Else
		MsgBox("Explica็ใo invแlida, explique com mais detalhes !!!","Aten็ใo!","Error")
	EndIf
Return

/*================================================================================\
|Programa  | EmailUsu  | Autor | Rafael de Campos Falco    | Data | 07/07/2004    |
|=================================================================================|
|Desc.     | Fun็ใo que retorna o e-mail de todos usuแrios do SIGA                |
|=================================================================================|
|Sintaxe   | EmailUsu                                                             |
|=================================================================================|
|Uso       | Especifico DIPROMED                                                  |
|=================================================================================|
|Hist๓rico |   /  /   -                                                           |
\================================================================================*/
User Function EmailUsu()

	Local aAllUsers:= AllUsers()
	Local aUser    := {}
	Local aRet    := {}
	LOCAL i
	LOCAL k
	If ( Type("l410Auto") == "U" .OR. !l410Auto )
		U_DIPPROC(ProcName(0),U_DipUsr()) // JBS 05/10/2005 - Gravando o nome do Programa no SZU

		For i:=1 to len(aAllUsers)
			For k := 1 to Len(aAllUsers[i][01][10])
				aAdd(aUser,aAllUsers[i])
			Next
		Next

		/*=================================================================================\
		|  Indexar o ARRAY por ordem de nome de usuแrio                                    |
		\=================================================================================*/
		aSort(aUser,,,{ |aVar1,aVar2| aVar1[1][2] < aVar2[1][2]})

		/*=================================================================================\
		|  SETREGUA -> Indica quantos registros serao processados para a regua             |
		\=================================================================================*/
		SetRegua(Len(aUser))

		/*=================================================================================\
		|  Processa Usuarios                                                               |
		\=================================================================================*/
		For i:=1 to Len(aUser)
			IncRegua()
			//////////     Usuario        Nome Completo     Departamento          Cargo            E-Mail
			AADD(aRet,{aUser[i][01][02], aUser[i][01][04], aUser[i][01][12], aUser[i][01][13], aUser[i][01][14]})
		Next
	ENDIF
Return aRet
/*====================================================================================\
|Programa  | DiprKardex | Autor |Jailton Barbosa dos Santos, JBS | Data | 23/08/2005  |
|=====================================================================================|
|Descri็ใo | Adiciona um novo registro no SZ9 ou Altera o registro jแ posicionado     |
|          | Registrar altera็๕es na Ficha Kardex do Produto                          |
|          |                                                                          |
|=====================================================================================|
|Sintaxe   | DiprKardex(cPedido,cUsuario,cTipoMovimento,lIncluirKardex,cOcorrencia)   |
|=====================================================================================|
|Parametros| cPedido........: Variavel com o codigo do Pedido.                        |
|          | cUsuario.......: Variavel com o Nome do usuario logado no sistema.       |
|          | cTipoMovimento.: String que descreve o movimento executado.              |
|          | lIncluirKardex.: .T./.F. Determina se inclui ou altera um registro.      |
|          | cOcorrencia....: Codigo do movimento executado. Esta na Tabela Z9 no SX5.|
|=====================================================================================|
|Uso       | Especifico DIPROMED                                                      |
|=====================================================================================|
|........................................Hist๓rico....................................|
|Jailton   | 23/08/2005 - Criou a fun็ใo.                                             |               |
|          |                                                                          |
\====================================================================================*/
User Function DiprKardex(cPedido,cUsuario,cTipoMovimento,lIncluirKardex,cOcorrencia)
	If lIncluirKardex
		dbSelectArea("SZ9")
	EndIf
	SZ9->(RecLock("SZ9",lIncluirKardex))
	SZ9->Z9_FILIAL  := xFilial('SZ9')
	SZ9->Z9_PEDIDO  := cPedido
	SZ9->Z9_OCORREN := cOcorrencia
	SZ9->Z9_TIPMOV  := If(cTipoMovimento==Nil,Tabela("Z9",cOcorrencia,.f.),cTipoMovimento)
	SZ9->Z9_DATAMOV := DATE()// Ajustado para DATE() 31-01-13--//dDatabase //DATE()
	SZ9->Z9_HORAMOV := TIME()
	SZ9->Z9_USUARIO := Upper(cUsuario)
	SZ9->(MsUnLock("SZ9"))
RETURN(.T.)
/*================================================================================\
|Programa  | DIPPROC | Autor | Jailton B Santos            | Data | 05/10/2005    |
|=================================================================================|
|Desc.     | Grava o nome do programa executado e o usuario no SZG - Documenta    |
|=================================================================================|
|Sintaxe   | DIPPROC(ProcName(),cUsuario)                                         |
|=================================================================================|
|Uso       | Especifico DIPROMED                                                  |
|=================================================================================|
|Hist๓rico |   /  /   -                                                           |
\================================================================================*/
User Function DIPPROC(cPrograma,cUsuario)
	// Documentar os acessos de cada usuario เs rotinas
	Local cNomUsuario := Upper(cUsuario)
	Local cNomeProg := cPrograma+Space(len(SZU->ZU_PROGRAM)-len(cPrograma))
	If !SZU->(dbseek(xFilial("SZU")+cNomeProg+cNomUsuario))
		SZU->(RecLock("SZU",.t.))
		SZU->ZU_FILIAL  := xFilial('SZU')
		SZU->ZU_PROGRAM := cPrograma
		SZU->ZU_USUARIO := cNomUsuario
		SZU->ZU_DATA    := dDataBase
		SZU->(MsUnLock("SZU"))
	Else
		SZU->(RecLock("SZU",.f.))
		SZU->ZU_DATA:=dDataBase
		SZU->(MsUnLock("SZU"))
	EndIf
RETURN(.T.)
/*                                                              Sao Paulo,  26 Out 2005
---------------------------------------------------------------------------------------
Empresa.......: DIPOMED Com้rcio e Importa็ใo Ltda.
Fun็ใo........: DipWhen()
Objetivo......: Restringir a  edi็ใo do campo de Observa็ใo financeira a apenas  ao
.             : Departamento financeiro.
Autor.........: Jailton B Santos, JBS
Data..........: 26 Out 2005
Versใo........: 1.0
Considera็oes.: Fun็ใo chamada do X3_WHEN do campo A1_OBSFINM.
---------------------------------------------------------------------------------------
*/
User Function DipWhen()
	Local cDipUser := Upper(AllTrim(GetNewPar("MV_DIP_FIN","")))//+"ERIBERTO/JAILTON"
Return(Upper(U_DipUsr()) $ cDipUser)
/*                                                              Sao Paulo,  17 Out 2006

/*                                                             Sao Paulo,31 de Mai 2013
---------------------------------------------------------------------------------------
REGINALDO BORGES 31/05/2013
Fun็ใo........: DipWhenL()
Objetivo......: Restringir a  edi็ใo do campo de Observa็ใo de licita็๕es a apenas  ao
.             : Departamento de licita็๕es.
Considera็oes.: Fun็ใo chamada do X3_WHEN do campo C5_XMENOTA.
---------------------------------------------------------------------------------------
*/

User Function DipWhenL()
	Local cDipUser := Upper(AllTrim(GetNewPar("ES_DIP_LIC","")))
Return(Upper(U_DipUsr()) $ cDipUser)

/*                                                              Sao Paulo,  17 Out 2006
---------------------------------------------------------------------------------------
Empresa.......: DIPOMED Com้rcio e Importa็ใo Ltda.
Fun็ใo........: CLI_PRO
Objetivo......: Tratamento de comissao para determinados fornecedores e produtos
Autor.........: Jailton B Santos, JBS
Data..........: 17 Out 2006
Versใo........: 1.0
---------------------------------------------------------------------------------------
*/
User Function Cli_Pro_3(xCampo)

	Local cMVcli3_:=GetNewPar("MV_CLI3_A","")+'/'+GetNewPar("MV_CLI3_B","")+'/'+GetNewPar("MV_CLI3_C","")
	Local cMVcli1_:=GetNewPar("MV_CLI1_A","")
	Local cMVcli1_1:=GetNewPar("MV_CLI1_1A","")+'/'+GetNewPar("MV_CLI1_1B","")
	Local cMVcli3_1:=GetNewPar("MV_CLI3_1A","")
	Local cMVclifor3:=GetNewPar("MV_CLIFOR3","")
	Local cMVclifor2:=GetNewPar("MV_CLIFOR2","")
	Local cMVprod2:=Upper(AllTrim(GetNewPar("MV_PROD2_A",""))) // Aliquota de 2%
	Local cMVprod3:=Upper(AllTrim(GetNewPar("MV_PROD3_A",""))) // Aliquota de 3%
	Local nPComis01:=aScan(aHeader,{|x| Alltrim(x[2])==Iif("TMK"$FunName(),"UB_COMIS1","C6_COMIS1") })
	Local nPComis02:=aScan(aHeader,{|x| Alltrim(x[2])==Iif("TMK"$FunName(),"UB_COMIS2","C6_COMIS2") })
	Local nPosProd:=aScan(aHeader,{|x| Alltrim(x[2])==Iif("TMK"$FunName(),"UB_PRODUTO","C6_PRODUTO") })
	Local nPosPrC:=aScan(aHeader,{|x| Alltrim(x[2])==Iif("TMK"$FunName(),"UB_VRUNIT","C6_PRCVEN") })
	Local nOrdSB1:=0
	Local nRecSB1:=0
	Local cCliente:=Iif("TMK"$FunName(),M->UA_CLIENTE,M->C5_CLIENTE)
	Local cProduto:=Acols[n,nPosProd]
	Local nPreco:=Acols[n,nPosPrc]

	If ISINCALLSTACK("LOJA901A") .Or. ISINCALLSTACK("LOJA901")
		Return(xCampo)
	EndIf

	If !Empty(cCliente)   //.and.Alltrim(cCliente) $ cMVcli3_

		nOrdSB1:= SB1->(IndexOrd())
		nRecSB1:= SB1->(Recno())

		SB1->(dbSetOrder(1))
		SB1->(dbSeek(xFilial('SB1')+cProduto))

		If AllTrim(cCliente) $ '000271' .And. SB1->(B1_PROC+B1_LOJPROC) == '00099699' .And. SA1->A1_VEND == '000209' // Hospital Samaritano, produtos Steri Packs e Vendedor Barcellos - 30-06-2011
			aCols[n,nPComis01] := 1
			aCols[n,nPComis02] := 0
		ElseIf AllTrim(cCliente) $ cMVcli1_  // Clientes FHEMIG
			aCols[n,nPComis01] := 1
			aCols[n,nPComis02] := 0
		ElseIf AllTrim(SB1->B1_PROC) $ '000366/000446'  // KC 000366  ou  000446
			If AllTrim(cCliente) $ cMVcli3_         // Clientes da SES
				If !Empty(SA1->A1_VENDKC)           // Tem vendedor tecnico
					If nPreco < SB1->B1_PRVMINI    // Preco menor que C
						aCols[n,nPComis01] := 1
					Else
						aCols[n,nPComis01] := 3
					EndIf
					aCols[n,nPComis02] := 1
				Else                                 // Nao tem vendedor tecnico
					// Eriberto 24/09/07	If Alltrim(cProduto) $ cMVprod3  // Produtos das ATAS   // FALTOU ISTO NO IF
					If nPreco < SB1->B1_PRVMINI    // Preco menor que C // Eriberto 25/09/07
						aCols[n,nPComis01] := 1
					Else
						aCols[n,nPComis01] := 4
					EndIf
					aCols[n,nPComis02] := 0
					// else -->quando nใo ้ ata a comissใo original
					// Eriberto 24/09/07	EndIf
				EndIf
			ElseIf AllTrim(cCliente) $ cMVcli1_1        // Clientes da 1 e 1 atualmente do vendedor 006711
				aCols[n,nPComis01] := 1
				aCols[n,nPComis02] := 1
			ElseIf AllTrim(cCliente) $ cMVcli3_1        // Clientes da 3 e 1 atualmente do vendedor 006774
				If nPreco < SB1->B1_PRCMINI    // Preco menor que C
					aCols[n,nPComis01] := 1
				Else
					aCols[n,nPComis01] := 3
				EndIf
				aCols[n,nPComis02] := 1
			EndIf

		ElseIf Alltrim(cProduto) $ cMVprod2 .and.; //'011205' 3M  000041
		AllTrim(SB1->B1_PROC) == cMVclifor2

			aCols[n,nPComis01] := 2
			aCols[n,nPComis02] := 0

		ElseIf Alltrim(cProduto) $ cMVprod3 .and.;  // 081208 / 081206 / 037002
		AllTrim(SB1->B1_PROC) $ cMVclifor3 .and.; // '000183' AMCOR  000183
		AllTrim(cCliente) $ cMVcli3_ // Clientes da SES

			aCols[n,nPComis01] := 6    // 3 passou a 6% em 06/09/10 (data que eu fiz) hoje produtos 011268 e 060109
			aCols[n,nPComis02] := 0

		EndIf

		SB1->(dbSetOrder(nOrdSB1))
		SB1->(dbGoto(nRecSB1))

	EndIf

Return(xCampo)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ ListVend บ Autor ณ CONSULTORIA        บ Data ณ 10/10/2007  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Retorna a lista de vendedores que o usuario pode enxergar  บฑฑ
ฑฑบ          ณ Esta rotina ้ usada nos relat๓rios: DIPR025, DIPR026       บฑฑ
ฑฑบ          ณ DIPR042, DIPR044, UMATR580, DIPR028, DIPR029, DIPR030      บฑฑ
ฑฑบ          ณ DIPR031, DIPR032, DIPR033, DIPR063, DIPR035                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ ESPECIFICO DIPROMED                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
User Function ListVend(cTpRet)
	Local _cAliasTRB

	Default cTpRet := "1" //-- Tipo de Retorno: "1", lista de vendedores; "2"-String com a Query

	Static _cVend
	Static _cTpRetCache
	Static _cQuery

	If Empty(_cTpRetCache) .Or. !(cTpRet $ _cTpRetCache)
		_cAliasTRB := GetNextAlias()
		_cQuery := " SELECT A3_COD FROM "+ RetSqlName("SA3")
		_cQuery += " WHERE "
		_cQuery += "    A3_FILIAL = '"+xFilial("SA3")+"'"
		//_cQuery += " 	AND A3_DESLIG = ' '"
		_cQuery += "	AND D_E_L_E_T_ = ' '"
		_cQuery += "	AND A3_COD <> '006874' "

		If ! (AllTrim(Upper(cUserName)) $ Upper(SuperGetMV("MV_DIPVPUB",,"")))
			If FunName() == "DIPR035" .And. AllTrim(Upper(cUserName)) $ Upper(GetNewPar("ES_DIPR035","IANJOS/CPEREIRA/ALOPES/LSANTANA/DNASCIMENTO"))
				_cQuery += " 	AND A3_TIPO <> 'T' "
			ElseIf AllTrim(Upper(cUserName)) $ Upper(SuperGetMV("MV_DIPVINT",,""))
			
				_cQuery += " 	AND A3_TIPO = 'I' "
				
				If FunName() == "DIPR025"  .Or. FunName() == "DIPR025A"
					If MV_PAR02 $ Upper(SuperGetMV("MV_DIPVINT",,""))  
						_cQuery += "	AND A3_CODUSR = '"+__cuserid+"'   "
					Else
						_cQuery += "	AND A3_CODUSR <> '"+__cuserid+"'   "
					EndIf
				Endif
				If MV_PAR02 $ Upper(SuperGetMV("MV_DIPVINT",,""))
					_cQuery += "	AND A3_CODUSR = '"+__cuserid+"'   "
				Else
					_cQuery += "	AND A3_CODUSR <> '"+__cuserid+"'   "
				EndIf

				If FunName() == "DIPR025" 
					If MV_PAR02 $ Upper(SuperGetMV("MV_DIPVINT",,""))  
						_cQuery += "	AND A3_CODUSR = '"+__cuserid+"'   "
					Else
						_cQuery += "	AND A3_CODUSR <> '"+__cuserid+"'   "
					EndIf
				Endif
				
			ElseIf (AllTrim(Upper(cUserName)) $ Upper(("MV_DIPVEXT",,"")) .Or. AllTrim(Upper(cUserName)) $ Upper(SuperGetMV("MV_DIPR026",,"")) )
				_cQuery += " 	AND A3_TIPO = 'E' "
			ElseIf (AllTrim(Upper(cUserName)) $ Upper(SuperGetMV("MV_URELFAT",,"")))
				_cQuery += " 	AND A3_TIPO <> 'T' "
			Else
				_cQuery += "	AND A3_CODUSR = '"+__cuserid+"'   "
			EndIf
		EndIf

		If cTpRet == "1"
			DbCommitAll()
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQuery),_cAliasTRB,.T.,.T.)

			_cVend := ""
			Do While (_cAliasTRB)->(!Eof())
				_cVend += "'"+(_cAliasTRB)->A3_COD+"',"
				(_cAliasTRB)->(DbSkip())
			EndDo
			(_cAliasTRB)->(DbCloseArea())

			If Len(_cVend)>0
				_cVend := Left(_cVend,Len(_cVend)-1)
				If At(',',_cVend) > 0
					_cVend := " IN ("+_cVend+") "
				Else
					_cVend := " = "+_cVend
				EndIf
			ElseIf !(AllTrim(Upper(cUserName)) $ Upper(SuperGetMV("MV_URELFAT",,""))) .And. "DIPR042"$Funname()
				_cVend := " = 'SEMACESSO' "
			EndIf
		EndIf
		_cTpRetCache := Iif(Empty(_cTpRetCache),"",_cTpRetCache) + cTpRet
	EndIf

Return Iif( cTpRet == "1", _cVend, _cQuery )

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ ValLocal บ Autor ณ Maximo             บ Data ณ 21/11/2007  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Permite alterar local(Almoxarifado) quando for Devolucao e บฑฑ
ฑฑบ          ณ usuario esta informado no parametro MV_ALTLOCA             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑฬHist๓rico ณ                                                            นฑฑ
ฑฑฬ13/02/2008ณ Incluํdo tratamento para que usuแrios contidos dentro do   นฑฑ
ฑฑฬ          ณ paraใmetro MV_ALTQLOC possa alterar o almoxarifado para    นฑฑ
ฑฑฬ          ณ qualquer tipo de pedido - MCVN                             นฑฑ
ฑฑฬ14/02/2008ณ Tratamento para o calcenter - MCVN.                        นฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ ESPECIFICO DIPROMED                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
User Function ValLocal()
	Local _cUser       := GetMV("MV_ALTLOCA")
	Local _cFullUser   := GetMV("MV_ALTQLOC")
	Local _cTipoPedido := ""
	Local _lRetorno    := .F.

	If "TMK" $ Funname()
		If Upper(U_DipUsr()) $ _cFullUser
			_lRetorno := .T.
		Endif
	Else
		_cTipoPedido := M->C5_TIPO
		If Upper(U_DipUsr()) $ _cUser .And. _cTipoPedido $ "BD"
			_lRetorno := .T.
		Endif

		If Upper(U_DipUsr()) $ _cFullUser
			_lRetorno := .T.
		Endif
	Endif
Return(_lRetorno)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ GravaZG  บ Autor ณ CONSULTORIA        บ Data ณ 24/01/2008  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Grava Log de inclusao, alteracao e exclusao de registro    บฑฑ
ฑฑบ          ณ de tabelas que utilizem telas modelo 1, exceto campos Vir  บฑฑ
ฑฑบ          ณ tuais e campos Memo.                                       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ ESPECIFICO DIPROMED                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
User Function GravaZG(_cAlias,_nLogZg)
	Local _aArea	:= GetArea()
	Local _nI, _nRecno, _cTabela, _cFilial, _cTipo, _cAcao, _cHora
	Local _cCampo, _xAntes, _xDepois
	Local _xTitulo
	Local aCampAlt := {}
	Default _nLogZg := 0 // MCVN - 26/01/10

	DbSelectArea(_cAlias)
	_cFilial	:= xFilial("SZG")
	_cTabela	:= RetSqlName(_cAlias)
	_nRecno		:= (_cAlias)->(Recno())
	_cAcao		:= If(Inclui,"I",If(Altera,"A","E"))
	_cHora		:= Time()

	SX3->(DbSetOrder(1))
	SX3->(DbSeek(_cAlias))
	While SX3->(!Eof()) .and. SX3->X3_ARQUIVO == _cAlias
		_cCampo	 := SX3->X3_CAMPO
		_xTitulo := SX3->X3_TITULO
		If Altera
			_cTipo 	:= Type("M->"+_cCampo)
		Else
			_cTipo 	:= SX3->X3_TIPO
		EndIf
		If _cTipo != 'U' .And. (SX3->X3_CONTEXT != 'V' .Or. (SX3->X3_TIPO == 'M' .And. !Inclui))

			If SX3->X3_TIPO == 'M' .And. SX3->X3_CONTEXT == 'V'
				// Verifica se nao existe erro em inicializador padrao..
				_xAntes := SX3->X3_RELACAO
				If !Empty(SX3->X3_RELACAO) .And. Type("&_xAntes") == 'C'
					_xAntes := &(SX3->X3_RELACAO)
				Else
					_xAntes	:= ''
				EndIf
			Else
				_xAntes := (_cAlias)->&_cCampo
			EndIf

			_xDepois 	:= If(!Altera,_xAntes,M->&_cCampo)
			If _cTipo == "C" .And. Len(_xAntes) != Len(_xDepois)
				_xDepois := Left(_xDepois,Len(_xAntes))
			EndIf
			If (Inclui .And. !Empty(_xDepois)) .Or. (!Inclui .And. !Altera .And. !Empty(_xAntes)) .Or. (Altera .And. _xAntes!=_xDepois)
				RecLock("SZG",.T.)
				SZG->ZG_FILIAL 	:= _cFilial
				SZG->ZG_TABELA 	:= _cTabela
				SZG->ZG_RECNO 	:= _nRecno
				SZG->ZG_CAMPO 	:= _cCampo
				SZG->ZG_DATA 	:= dDataBase
				SZG->ZG_HORA 	:= _cHora
				SZG->ZG_ACAO	:= _cAcao
				SZG->ZG_USER 	:= __cUserID
				SZG->ZG_NOMUSER := Upper(U_DipUsr())
				If _cTipo == 'C' .And. SX3->X3_TIPO != 'M'
					SZG->ZG_ANTES 	:= _xAntes
					SZG->ZG_DEPOIS 	:= _xDepois
				ElseIf _cTipo == 'D'
					SZG->ZG_ANTES 	:= Dtoc(_xAntes)
					SZG->ZG_DEPOIS 	:= Dtoc(_xDepois)
				ElseIf _cTipo == 'N'
					SZG->ZG_ANTES 	:= Str(_xAntes)
					SZG->ZG_DEPOIS 	:= Str(_xDepois)
				ElseIf _cTipo == 'L'
					SZG->ZG_ANTES 	:= If(_xAntes,'.T.','.F.')
					SZG->ZG_DEPOIS 	:= If(_xDepois,'.T.','.F.')
				ElseIf _cTipo $ 'C/M' .And. SX3->X3_TIPO == 'M'
					//SZG->ZG_DEPOIS 	:= ''
					MSMM(SZG->ZG_ANTES,,,_xAntes,1,,,"SZG","ZG_ANTES")
					MSMM(SZG->ZG_DEPOIS,,,_xDepois,1,,,"SZG","ZG_DEPOIS")
				EndIf
				SZG->(MsUnLock())
				_nLogZg++ //MCVN - 26/01/10

				If (Altera .And. _xAntes!=_xDepois) .And. SZG->ZG_TABELA = 'SA1010' .AND. SZG->ZG_CAMPO <> 'A1_OBSFINV'
					If SX3->X3_TIPO <> 'M'
						aadd(aCampAlt,{SZG->ZG_DATA,_xTitulo,SZG->ZG_ANTES,SZG->ZG_DEPOIS,Upper(U_DipUsr())})
					Else
						aadd(aCampAlt,{SZG->ZG_DATA,_xTitulo,_xAntes,_xDepois,Upper(U_DipUsr())})
					EndIf
				EndIf

			EndIf
		EndIf
		DbSelectArea("SX3")
		DbSkip()
	EndDo

	If Len(aCampAlt) > 0

		cxAssunto  := EncodeUTF8("Altera็ใo no cadastro do cliente "+SA1->A1_COD+"-"+AllTrim(SA1->A1_NOME),"cp1252")

		If     SA1->A1_VEND $ ('000188/006933/006918/000209/006709/006864/000201/006706') //apoio@dipromed.com.br
			cEmailZG := "apoio@dipromed.com.br;reginaldo.borges@dipromed.com.br"
		ElseIf SA1->A1_VEND $ ('000353/000210/006738/006953/006941/006940/006946/000359/006949/006753')//patricia.mendonca@dipromed.com.br;elizabete.rodrigues@dipromed.com.br
			cEmailZG := "elizabete.rodrigues@dipromed.com.br;reginaldo.borges@dipromed.com.br"
		ElseIf SA1->A1_VEND $ ('006711/006743/006819')//publico@dipromed.com.br
			cEmailZG := "publico@dipromed.com.br;reginaldo.borges@dipromed.com.br"
		Else
			cEmailZG := AllTrim(Posicione("SA3",1,xFilial("SA3")+SA1->A1_VEND,"A3_EMAIL"))//+";"+"rafael.rosa@dtmit.com.br"
		EndIf

		ENV_SZG(aCampAlt,cEmailZG,cxAssunto)
	EndIf

	RestArea(_aArea)

	If "TMK" $ FUNNAME() .Or. "MATA410" $ FUNNAME()
		Return(.T.)
	Else
		Return
	Endif

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ RestrSED บ Autor ณ Maximo             บ Data ณ 28/01/2008  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯอออออออออออออ????ออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Restringe acesso na tabela de Natureza(SED)                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ ESPECIFICO DIPROMED                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
User Function RestrSED(_Origem)
	Local _cUser      := GetMV("MV_USERSED")
	Local _cFilSecr   := GetMV("MV_SECRSED")
	Local _cFilFina   := GetMV("MV_FINASED")
	Local _cFilGerFina:= GetMV("MV_GERFSED")
	Local _cUserGer   := GetMV("MV_UGFISED")
	Local _cUserADM   := GetMV("MV_UADMSED")
	Local _lRetorno   := .F.
	Local _cFiltroSED := ""

	If Upper(U_DipUsr()) $ _cUser
		If 	"CSILVA" $ Upper(U_DipUsr())
			_cFiltroSED := _cFilSecr
		Else
			_cFiltroSED := _cFilFina
		Endif
	ElseIf Upper(U_DipUsr()) $ _cUserGer
		_cFiltroSED := _cFilGerFina
	Else
		If Upper(U_DipUsr()) $ _cUserADM
			//	    If Upper(U_DipUsr()) $ ("MAXIMO/ERIBERTO/ADMINISTRADOR/MAGDA/JOAO LUIZ/EDGLEISON")
			RETURN If(_Origem == "SE2",Alltrim(M->E2_NATUREZ) <> "",Alltrim(SED->ED_CODIGO) <> "" )
		Else
			_cFiltroSED := ""
		EndIf
	Endif

Return If(_Origem == "SE2",Alltrim(M->E2_NATUREZ) $ (_cFiltroSED),Alltrim(SED->ED_CODIGO) $ (_cFiltroSED))

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDIPSALDSB2บ Autor ณ Maximo             บ Data ณ 22/02/2008  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Busca o Saldo no SB2                                       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ ESPECIFICO DIPROMED                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

User Function DIPSALDSB2(_cProduto,lGatilho,cEstFilDip,cLocalTran)

	Local nEstoque := 0
	Local QRY1     := ""
	Local _cLocal  := "01"
	Local _xAlias  := GetArea()
	Local aEstoque :={}

	Default cEstFilDip := ''
	Default lGatilho   := .F.
	Default cLocalTran := '01'

	If cLocalTran <> _cLocal //Tratamento para valida็ใo dos saldos em estoque
		_cLocal := cLocalTran
	Endif

	If lGatilho .And. cEmpAnt == '04'
		QRY1 := "SELECT "
		QRY1 += " SUM((B2_QATU-B2_QACLASS-B2_RESERVA)) AS ESTOQUE "
		QRY1 += " FROM " + RetSQLName("SB2")
		QRY1 += " WHERE B2_FILIAL IN ('01','02') "
		QRY1 += " AND B2_COD = '" + _cProduto + "'"

		If SB1->B1_TIPO  $ 'PA/MP'
			QRY1 += " AND B2_LOCAL IN ('01','02')"
		ElseIf SB1->B1_TIPO == 'BN'
			QRY1 += " AND B2_LOCAL = '06'"
		ElseIf SB1->B1_TIPO == 'PI'
			QRY1 += " AND B2_LOCAL = '04'"
		EndIf

		QRY1 += " AND "  + RetSQLName("SB2")+".D_E_L_E_T_ = ' '"
		QRY1 += " GROUP BY B2_COD "
	ElseIf lGatilho .And. cEmpAnt == '01'
		QRY1 := "SELECT "
		QRY1 += " SUM((B2_QATU-B2_QACLASS-B2_RESERVA)) AS ESTOQUE"
		QRY1 += " FROM " + RetSQLName("SB2")
		QRY1 += " WHERE B2_FILIAL IN ('01','04') "
		QRY1 += " AND B2_COD = '" + _cProduto + "'"
		QRY1 += " AND B2_LOCAL = '" + _cLocal +"'"
		QRY1 += " AND "  + RetSQLName("SB2")+".D_E_L_E_T_ = ' ' "
	ElseIf cEmpAnt == '01'
		QRY1 := "SELECT "
		QRY1 += " B2_QATU, B2_RESERVA, B2_QPEDVEN, B2_SALPEDI, B2_QACLASS, B2_FORNEC "
		QRY1 += " FROM " + RetSQLName("SB2")
		If cEstFilDip == "MTZ"
			QRY1 += " WHERE B2_FILIAL = '01' "
		Else
			QRY1 += " WHERE B2_FILIAL = '04' "
		EndIf
		QRY1 += " AND B2_COD = '" + _cProduto + "'"
		QRY1 += " AND B2_LOCAL = '" + _cLocal +"'"
		QRY1 += " AND "  + RetSQLName("SB2")+".D_E_L_E_T_ = ' '"
	ElseIf cEmpAnt == '04'
		QRY1 := "SELECT "
		QRY1 += " SUM(B2_QATU) B2_QATU, SUM(B2_RESERVA) B2_RESERVA, SUM(B2_QPEDVEN) B2_QPEDVEN, SUM(B2_SALPEDI) B2_SALPEDI, SUM(B2_QACLASS) B2_QACLASS, B2_FORNEC "
		QRY1 += " FROM " + RetSQLName("SB2")
		If cEstFilDip == "MTZ"
			QRY1 += " WHERE B2_FILIAL = '01' "
		Else
			QRY1 += " WHERE B2_FILIAL = '02' "
		EndIf
		QRY1 += " AND B2_COD = '" + _cProduto + "'"

		If SB1->B1_TIPO  $ 'PA/MP'
			QRY1 += " AND B2_LOCAL IN ('01','02')"
		ElseIf SB1->B1_TIPO == 'BN'
			QRY1 += " AND B2_LOCAL = '06'"
		ElseIf SB1->B1_TIPO == 'PI'
			QRY1 += " AND B2_LOCAL = '04'"
		EndIf

		QRY1 += " AND "  + RetSQLName("SB2")+".D_E_L_E_T_ = ' '"
		QRY1 += " GROUP BY B2_FORNEC "
	Endif

	#xcommand TCQUERY <sql_expr>                          ;
	[ALIAS <a>]                                           ;
	[<new: NEW>]                                          ;
	[SERVER <(server)>]                                   ;
	[ENVIRONMENT <(environment)>]                         ;
	=> dbUseArea(                                         ;
	<.new.>,                                              ;
	"TOPCONN",                                           ;
	TCGENQRY(<(server)>,<(environment)>,<sql_expr>),      ;
	<(a)>, .F., .T.)

	// PROCESSA QUERY SQL
	DbCommitAll()
	TcQuery QRY1 NEW ALIAS "QRY1SB2"         // ABRE UMA WORKAREA COM O RESULTADO DA QUERY

	DbSelectArea("QRY1SB2")
	QRY1SB2->(dbGotop())

	If lGatilho
		nEstoque := QRY1SB2->ESTOQUE
	Else
		AADD(aEstoque,{	IIf(QRY1SB2->B2_FORNEC$GetNewPar("ES_NMOSSAL","000996"),QRY1SB2->(B2_QATU-B2_QACLASS),QRY1SB2->B2_QATU),;  	// Estoque          01
		QRY1SB2->B2_RESERVA ,;  							  														// Reserva          02
		IIf(QRY1SB2->B2_FORNEC$GetNewPar("ES_NMOSSAL","000996"),0,QRY1SB2->B2_QACLASS),; 							// A Endere็ar      03
		QRY1SB2->B2_QATU-QRY1SB2->B2_RESERVA-QRY1SB2->B2_QACLASS,; 													// Saldo Disponํvel 04
		QRY1SB2->B2_QPEDVEN ,;     						  															// Saldo            05
		QRY1SB2->B2_SALPEDI })   																           			// A Entrar         06
	Endif

	DBCLOSEAREA("QRY1SB2")
	RestArea(_xAlias)

Return(Iif(lGatilho,nEstoque,aEstoque))
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGetTESICMSบ Autor ณ Maximo             บ Data ณ 12/06/2008  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Gatilho para atualizar TES de ICMS-ST                      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ ESPECIFICO DIPROMED                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

User Function GetTESICMST()

	MaAvalTES("S",aCols[n] [7])
	MaFisRef("IT_TES","TK273",aCols[n] [7])

Return(aCols[n] [7])

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณVerOperad บ Autor ณ Maximo             บ Data ณ 10/11/2008  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Gatilho para verificar operador quando for user de treino  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ ESPECIFICO DIPROMED                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑ  Maximo - 26/03/2009 -> Preencher nome operador e dados do vendedor     ฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

User Function VerOperado()
	Local aBoxParam  := {}
	Local aRetParam  := {}
	Local lRet       := .F.

	Aadd(aBoxParam,{1,"Operador",Space(6),"@!","ExistCpo('SU7',MV_PAR01) .And. !(MV_PAR01 $ '000126/000168/000169')","SU7","",6,.F.})
	If ParamBox(aBoxParam,"Informe seu operador",@aRetParam,,,,,,,,.F.)
		If MsgBox("Voc๊ selecionou o operador "+MV_PAR01+" - "+Posicione("SU7",1,xFilial("SU7")+MV_PAR01,"U7_NOME")+" Confirma operador?","Atencao","YESNO")
			//lRet:=Aviso("Voc๊ selecionou o operador "+MV_PAR01+" - "+Posicione("SU7",1,xFilial("SU7")+MV_PAR01,"U7_NOME")+" Confirma operador?" ,{"Sim","Nใo"})
			M->UA_OPERADO := MV_PAR01
			M->UA_DESCOPE := Posicione("SU7",1,xFilial("SU7")+MV_PAR01,"U7_NOME")
			If M->UA_VEND $ '006750/000353/000357/000356/000359'
				M->UA_VEND := Posicione("SU7",1,xFilial("SU7")+MV_PAR01,"U7_CODVEN")
				M->UA_DESCVEN :=Posicione("SA3",1,xFilial("SA3")+M->UA_VEND,"A3_NOME")
			Endif
			lRet := .T.
		Endif
	Endif
	Return(lRet)

	/*
	+----------+--------+-------+-------------------------+---------------------+
	|Programa  |FUNCOES | Autor | Alexandro Dias          | Data | 02/07/01     |
	+----------+--------+-------+-------------------------+---------------------+
	|Desc.     | Funcoes de uso generico                                        |
	+---------------------------------------------------------------------------+
	*/
	#Include "RwMake.ch"
	#Include "Ap5Mail.ch"

/*****************************************************************************
Funcao para retornar o tamanho de campo com comando PADR
*****************************************************************************/
User Function FPADR(cPerg, cArq, cCampo, cTipo)

	DbSelectArea(cArq)
	DbSetOrder(1)
	cPerg := PADR(cPerg, Len(&cCampo), ctipo)

Return(cPerg)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณM120ENTREGบ Autor ณ Maximo Canuto      บ Data ณ 12/06/2008  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Fun็ใo para validar o When do C7_DATPRF                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ ESPECIFICO DIPROMED                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

User Function M120ENTREG()
	Local _xArea    := SC7->(GetArea())
	Local lRet      := .F.
	Local nPosProd  := aScan(aHeader,{|x| AllTrim(x[2]) == 'C7_PRODUTO'})
	Local nPosSequ  := aScan(aHeader,{|x| AllTrim(x[2]) == 'C7_SEQUEN'})
	Local nPosItem  := aScan(aHeader,{|x| AllTrim(x[2]) == 'C7_ITEM'})
	Local nPosNum   := aScan(aHeader,{|x| AllTrim(x[2]) == 'C7_NUM'})

	If l120Auto
		SC7->(RestArea(_xArea))
		Return(.T.)
	Endif

	If Inclui
		lRet := .T.
	ElseIf Altera
		SC7->(DbSetOrder(4))
		If !(SC7->(DbSeek(xFilial("SC7")+aCols[n][nPosProd]+CA120NUM+aCols[n][nPosItem],.T.)))
			lRet := .T.
		Endif
	Endif
	SC7->(RestArea(_xArea))
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGetZ9     บAutor  ณMicrosiga           บ Data ณ  04/26/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Retorna o Recno do ultimo registro com a ocorrencia em um  บฑฑ
ฑฑบ          ณ Pedido                                                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function GetZ9(_cPedido,_cOcorrencia)
	Local _cAlias	:= GetNextAlias()
	Local _cQuery	:= ""
	Local _nRet		:= 0
	Local _aArea	:= GetArea()

	_cQuery += " SELECT TOP 1 R_E_C_N_O_ RECNOZ9"
	_cQuery += " FROM  "+RetSQLName('SZ9')
	_cQuery += " WHERE "
	_cQuery += " 	Z9_FILIAL = '" + xFilial('SZ9') + "'"
	_cQuery += " 	AND Z9_PEDIDO  = '"+ _cPedido     + "'"
	_cQuery += " 	AND Z9_OCORREN = '"+ _cOcorrencia + "'"
	_cQuery += " 	AND D_E_L_E_T_ = ' '""
	_cQuery += " ORDER BY R_E_C_N_O_ DESC"
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQuery),_cAlias,.T.,.T.)

	If (_cAlias)->(!Eof())
		_nRet := (_cAlias)->RECNOZ9
	EndIf
	(_cAlias)->(DbCloseArea())

	RestArea(_aArea)

Return _nRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPreDipMtz     บAutor  ณMaximo Canuto      บ Data ณ  04/26/10บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Ajusta o prefixo dos tํtulos emitidos na Dipromed-Matriz   บฑฑ
ฑฑบ          ณ Pois o SE1010 ้ compartilhado e a s้rie das notas ้ a mesmaบฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function PreDipMtz()
	Local cNewSer := If(SF2->F2_SERIE = "003",SUBSTR(SF2->F2_SERIE,2,2),SF2->F2_SERIE)
Return(cNewSer)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFINDEMP   บAutor  ณJailton B Santos-JBSบ Data ณ 11/10/2010  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณEsta funcao recebe alguns parametros, que de acordo com     บฑฑ
ฑฑบ          ณeste localiza uma empresa ou filial e retorna algumas infor-บฑฑ
ฑฑบ          ณmacoes determinadas pelo usuario.                           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบSintaxe   ณU_FindEmp(cEmpresa,cFilial,cCGC, cTipo,bTipo})              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ- cEmp: Codigo da Empresa. Opcional, se for informado, deterบฑฑ
ฑฑบde Entradaณ        mina a empresa a deseja                             บฑฑ
ฑฑบ          ณ- cFilial: Codigo da Filial. Opcional, se for informado, de-บฑฑ
ฑฑบ          ณ        termina a filial a ser posicionada.                 บฑฑ
ฑฑบ          ณ- cCGC: Numero de CGC. opcional, se for informadoo, determi-บฑฑ
ฑฑบ          ณ        na empresa e filial pelo CNPJ.                      บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑบ          ณOBS: Pelo menos um dos parametros acima precisa ser informa-บฑฑ
ฑฑบ          ณ     do. Todos eles podem ser informados                    บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ- cTipo: Este parametro determina qual informacao da empre- บฑฑ
ฑฑบ          ณ         sa, o usuario quer retorne:                        บฑฑ
ฑฑบ          ณ         -> 'CODIGO'                                        บฑฑ
ฑฑบ          ณ         -> 'NOME'                                          บฑฑ
ฑฑบ          ณ         -> 'CODFIL'                                        บฑฑ
ฑฑบ          ณ         -> 'FILIAL'                                        บฑฑ
ฑฑบ          ณ         -> 'CGC'                                           บฑฑ
ฑฑบ          ณ         -> 'IE'                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑบ          ณ-bTipo: Atraves deste parametro, o usuario informa campos   บฑฑ
ฑฑบ          ณ      para serem retornado em um array                      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณEspecifico de Consultas Genericas de Empresas Dipromed      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function DIPMEMP()

	Local axDados := {}
	Local cxCodigo := ''
	Local cxNome   := ''
	Local cxCodFil := ''
	Local cxFilial := ''
	Local cxCGC    := ''
	Local cxIE     := ''

	cxCodigo := U_FindEmp(,,,'CODIGO')
	cxCodigo := U_FindEmp("01","04",,'CODIGO')
	cxNome   := U_FindEmp('01','04',,'NOME')
	cxCodFil := U_FindEmp('01','04',,'CODFIL')
	cxFilial := U_FindEmp('01','04',,'FILIAL')
	cxCGC    := U_FindEmp('01','04',,'CGC')
	cxIE     := U_FindEmp('01','04',,'IE')
	axDados  := U_FindEmp(,,cxCGC,,{|| {SM0->M0_CODIGO,SM0->M0_NOMECOM,SM0->M0_CODFIL,SM0->M0_FILIAL,SM0->M0_TEL}})

	x:= 'Teste'
Return(.T.)

User Function FindEmp(__cEmp, __cFil, __cCGC,__cTipRet,__bTipRet)

	Local aArea  := SM0->(GetArea())
	Local lAchou := .F.
	Local uRet   := Nil
	Local bRet   := {|| SM0->M0_NOME}

	Do Case
		case __bTipRet <> Nil     ; bRet := __bTipRet
		case __cTipRet == 'CODIGO'; bRet := {|| SM0->M0_CODIGO}
		case __cTipRet == 'NOME'  ; bRet := {|| SM0->M0_NOMECOM}
		case __cTipRet == 'CODFIL'; bRet := {|| SM0->M0_CODFIL}
		case __cTipRet == 'FILIAL'; bRet := {|| SM0->M0_FILIAL}
		case __cTipRet == 'CGC'   ; bRet := {|| SM0->M0_CGC}
		case __cTipRet == 'IE'    ; bRet := {|| SM0->M0_INSC}
	EndCase

	If __cEmp <> Nil .Or. __cFil <> Nil  .Or. __cCGC <> Nil
		SM0->(DbGoTop())
	Endif

	Do While SM0->( !EOF() )

		Begin Sequence

			Do Case
				case __cEmp <> Nil .and. __cEmp <> SM0->M0_CODIGO  ; Break
				case __cFil <> Nil .and. __cFil <> SM0->M0_CODFIL  ; Break
				case __cCGC <> Nil .and. __cCGC <> SM0->M0_CGC     ; Break
			EndCase

			lAchou := .T.

		End Sequence

		If lAchou
			uRet := Eval(bRet)
			Exit
		EndIf

		SM0->( DbSkip() )

	EndDo

	SM0->( RestArea(aArea) )

Return(uRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ ListOper บ Autor ณ Maximo Canuto Vieira  - MCVN 10/10/2007 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Retorna a lista de operadores que o usuario pode enxergar  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ ESPECIFICO DIPROMED                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
User Function ListOper(cTpRet)
	Static _cOper
	Static _lOper

	Default cTpRet := "1"

	_cQuery2 := " SELECT U7_COD FROM "+ RetSqlName("SU7")
	_cQuery2 += " WHERE "
	_cQuery2 += "    U7_FILIAL = '"+xFilial("SU7")+"'"
	_cQuery2 += "	AND D_E_L_E_T_ = ' '"
	If AllTrim(Upper(cUserName)) $ Upper(SuperGetMV("MV_DIPVINT",,""))
		_cQuery2 += " 	AND U7_POSTO = '02'"
	ElseIf (AllTrim(Upper(cUserName)) $ Upper(SuperGetMV("MV_DIPVEXT",,"")) .Or. AllTrim(Upper(cUserName)) $ Upper(SuperGetMV("MV_DIPR026",,"")) )
		_cQuery2 += " 	AND U7_POSTO = '01'"
	ElseIf AllTrim(Upper(cUserName)) $ Upper(SuperGetMV("MV_DIPVPUB",,""))
		_cQuery2 += " 	AND U7_POSTO = '03'"
		//ElseIf !(AllTrim(Upper(cUserName)) $ Upper(SuperGetMV("MV_URELFAT",,"")))
		//	_cQuery2 += "	AND U7_CODUSU = '"+__cuserid+"'"
	EndIf
	If cTpRet == "1" .And. Empty(_lOper)
		_cAliasTRB := GetNextAlias()
		DbCommitAll()
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQuery2),_cAliasTRB,.T.,.T.)

		_cOper := ""
		Do While (_cAliasTRB)->(!Eof())
			_cOper += "'"+(_cAliasTRB)->U7_COD+"',"
			(_cAliasTRB)->(DbSkip())
		EndDo
		(_cAliasTRB)->(DbCloseArea())

		_lOper := Len(_cOper)>0
		If _lOper
			_cOper := Left(_cOper,Len(_cOper)-1)
			If At(',',_cOper) > 0
				_cOper := " IN ("+_cOper+") "
			Else
				_cOper := " = "+_cOper
			EndIf
		EndIf
	EndIf

Return Iif(cTpRet=="1", _cOper, _cQuery2)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณUFindCIC()บ Autor ณJailton B Santos-JBSบ Data ณ 25/05/2010  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Busca o nome do usuario do CIC para enviar mensagen-lhe    บฑฑ
ฑฑบ          ณ mensagens.                                                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function UFindCic(cCodigo)

	Local aArea   := GetArea()
	Local cQuery  := ""
	Local cUsuCIC := ""

	cQuery := " Select U7_CICNOME CIC "
	cQuery += "   from "+RetSqlName('SU7')+" SU7 "
	cQuery += "  where U7_FILIAL = '" + xFilial('SU7')+ "' "
	cQuery += "    and U7_CODUSU  = '"+ cCodigo + "' "
	cQuery += "    and SU7.D_E_L_E_T_ = '' "
	cQuery += " Union Select Y1_NOMECIC CIC "
	cQuery += "   from " + RetSqlName('SY1')+ " SY1 "
	cQuery += "  where Y1_FILIAL  = '" +xFilial('SY1')+ "' "
	cQuery += "    and Y1_USER  = '"+ cCodigo + "' "
	cQuery += "    and SY1.D_E_L_E_T_ = '' "

	If Select("TRB") > 0
		TRB->(DbCloseArea())
	EndIf

	TcQuery cQuery NEW ALIAS "TRB"

	If !TRB->(BOF() .and. EOF() )
		cUsuCIC := TRB->CIC
	EndIf
	TRB->( DbCloseArea() )
Return(cUsuCIC)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ ValB1Desc2 บ Autor ณ Maximo           บ Data ณ 04/02/2011  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Permite que somente um usuแrio poderแ alterar os campos    บฑฑ
ฑฑบ          ณ B2_DESC2, B2_CODANT										  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ ESPECIFICO DIPROMED                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
User Function ValB1Desc2()
	Local _cUser       := "IFERREIRA"
	Local _lRetorno    := .F.

	If Upper(U_DipUsr()) $ _cUser .And. M->B1_PROC $ '000996'
		_lRetorno := .T.
	Endif

	If !Upper(U_DipUsr()) $ _cUser .And. !M->B1_PROC $ '000996'
		_lRetorno := .T.
	Endif

	If M->B1_CODANT <> '' .AND. M->B1_PROC $ '000996'
		_lRetorno := .T.
	Endif

Return(_lRetorno)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ ENVSENHMAIL บ Autor ณ GIOVANI.ZAGO    บ Data ณ 17/08/2011  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ ENVIA E-MAIL NA LIBERAวรO POR SENHA NA TES E NO LOTE COM   บฑฑ
ฑฑบ          ณ 	VALIDADE MENOR QUE SEIS MESES.                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ ESPECIFICO DIPROMED                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

User Function EnvSenhMail(cChaSen,aMsg)
	LOCAL lSmtpAuth := GetNewPar("MV_RELAUTH",.F.)
	LOCAL lAutOk	:= .F.
	Local _nLin		:= 0
	Private cDe       := " "
	Private cEmail    := GetMv("ES_MT100LO") //grupo de usuarios para recebimento de e-mail do lote  com validade menor que 6 meses
	Private cAssunto  :=  EncodeUTF8("Libera็ใo de Lote","cp1252")
	Private cAttach   := "a"
	Private cFuncSent := "MT100LOK.PRW"
	Private cAccount  := Lower(Alltrim(GetMv("MV_RELACNT")))
	Private cFrom     := If(Empty(Alltrim(cDe)),"protheus@dipromed.com.br",cDe) //protheus@dipromed.com.br
	Private cPassword := Alltrim(GetMv("MV_RELPSW"))
	Private cServer   := Alltrim(GetMv("MV_RELSERV"))
	Private cEmailTo  := ""
	Private cEmailCc  := ""
	Private cEmailBcc := ""
	Private lResult   := .F.
	Private cError    := ""
	Private i         := 0
	Private cArq      := ""
	Private cMsg      := ""
	Private cTiMail   := EncodeUTF8("ATENวรO - LIBERAวรO DE LOTE COM VALIDADE INFERIOR A SEIS MESES  ","cp1252")
	

	If cChaSen == "B"
		cEmail     := "maximo.canuto@dipromed.com.br"   //E-mail exclusivo para receber a senha da libera็ใo do lote
	EndIf
	If cChaSen == "C"
		cEmail     := "maximo.canuto@dipromed.com.br" //E-mail exclusivo para receber a senha da libera็ใo da tes
		cTiMail    := EncodeUTF8(" ATENวรO - LIBERAวรO DE TES POR SENHA  ","cp1252")
		cAssunto  :=  EncodeUTF8(" LIBERAวรO DE TES","cp1252")
	EndIf
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Definicao do cabecalho do email                                             ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	cMsg := ""
	cMsg += '<html>'
	cMsg += '<head>'
	cMsg += '<title>' + cAssunto + " - "+SM0->M0_NOME+"/"+SM0->M0_FILIAL+'</title>'
	cMsg += '</head>'
	cMsg += '<body>'
	//cMsg += '<Img Src="C:/AP5/SIGAADV/LGRL01.BMP"><BR>'
	cMsg += '</Table>'
	cMsg += '<P>'
	cMsg += '<Table align="center">'
	cMsg += '<tr>'
	cMsg += '<td colspan="10" align="center"><font color="red" size="5">'+DecodeUTF8(cTiMail, "cp1252")+'<font color="red" size="1">.</td>'
	cMsg += '</tr>'
	cMsg += '</Table>'

	cMsg += '<HR Width=85% Size=3 Align=Centered Color=Red> <P>'

	cMsg += '<Table Border=1 Align=Center BorderColor=#000000 CELLPADDING=4 CELLSPACING=0 Width=60%>'
	cMsg += '<Caption> <FONT COLOR=#000000 FACE= "ARIAL" SIZE=5>' + cAssunto +" - "+SM0->M0_NOME+"/"+SM0->M0_FILIAL+ '</FONT> </Caption>'
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Definicao do texto/detalhe do email                                         ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	For _nLin := 1 to Len(aMsg)
		IF (_nLin/2) == Int( _nLin/2 )
			cMsg += '<TR BgColor=#B0E2FF>'
		Else
			cMsg += '<TR BgColor=#FFFFFF>'
		EndIF
		cMsg += '<TD><B><Font Color=#000000 Size="2" Face="Arial">' + aMsg[_nLin,1] + ' </Font></B></TD>'
		cMsg += '<TD> <Font Color=#000000 Size="2" Face="Arial">' + aMsg[_nLin,2] + ' </Font></TD>'
		cMsg += '</TR>'
	Next
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Definicao do rodape do email                                                ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	cMsg += '</Table>'
	cMsg += '<P>'
	cMsg += '<Table align="center">'
	cMsg += '<tr>'
	cMsg += '<td colspan="10" align="center"><font color="red" size="3">Mensagem enviada automaticamente pelo sistema PROTHEUS - <font color="red" size="1">('+cFuncSent+')</td>'
	cMsg += '</tr>'
	cMsg += '</Table>'
	cMsg += '<HR Width=85% Size=3 Align=Centered Color=Red> <P>'
	//cMsg += '<B><Font Color=#000000 Size="2" Face="Arial"> Atenciosamente </Font></B><BR>'
	//cMsg += '<B><Font Color=#000000 Size="2" Face="Arial">' + SM0->M0_NOMECOM + '</Font></B><BR>'
	//cMsg += '<Img Src="C:/AP5/SIGAADV/LGRL01.BMP">'
	cMsg += '</body>'
	cMsg += '</html>'

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณEnvia o mail para a lista selecionada. Envia como BCC para que a pessoa penseณ
	//ณque somente ela recebeu aquele email, tornando o email mais personalizado.   ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	IF At(";",cEmail) > 0
		cEmailTo := SubStr(cEmail,1,At(";",cEmail)-1)
		cEmailCc:= SubStr(cEmail,At(";",cEmail)+1,Len(cEmail))
	Else
		cEmailTo := Alltrim(cEmail)
	EndIF

	CONNECT SMTP SERVER cServer ACCOUNT cAccount PASSWORD cPassword RESULT lResult

	If !lAutOk
		If ( lSmtpAuth )
			lAutOk := MailAuth(cAccount,cPassword)
		Else
			lAutOk := .T.
		EndIf
	EndIf

	If lResult .And. lAutOk
		SEND MAIL FROM cFrom ;
		TO      	Lower(cEmailTo);
		CC      	Lower(cEmailCc);
		BCC     	Lower(cEmailBcc);
		SUBJECT 	cAssunto;
		BODY    	cMsg;
		ATTACHMENT  cAttach;
		RESULT lResult

		If !lResult
			//Erro no envio do email
			GET MAIL ERROR cError

			MsgInfo(cError,OemToAnsi("Ateno"))
		EndIf

		DISCONNECT SMTP SERVER
	Else
		//Erro na conexao com o SMTP Server
		GET MAIL ERROR cError

		MsgInfo(cError,OemToAnsi("Ateno"))
	EndIf

Return()

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ M261Email บ Autor ณ GIOVANI.ZAGO    บ Data ณ 24/10/2011  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ ENVIA E-MAIL NA transferencia                              บฑฑ
ฑฑบ          ณ 	                                                          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ ESPECIFICO DIPROMED                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

User Function M261Email(aMsg,cTiMail,cEmail,aMsgIt)
	LOCAL lSmtpAuth := GetNewPar("MV_RELAUTH",.F.)
	LOCAL lAutOk	:= .F.
	Local _nLin		:= 0
	Private cDe       := "protheus@dipromed.com.br"
	Private cAssunto  := "Transferencia Modelo II"
	Private cAttach   := "a"
	Private cFuncSent := "A261TOK.PRW"
	Private cAccount  := Lower(Alltrim(GetMv("MV_RELACNT")))
	Private cFrom     := If(Empty(Alltrim(cDe)),"protheus@dipromed.com.br",cDe) //protheus@dipromed.com.br
	Private cPassword := Alltrim(GetMv("MV_RELPSW"))
	Private cServer   := Alltrim(GetMv("MV_RELSERV"))
	Private cEmailTo  := "protheus@dipromed.com.br"
	Private cEmailCc  := "maximo.canuto@dipromed.com.br"//"maximo.canuto@dipromed.com.br ;  rt@dipromed.com.br"
	Private cEmailBcc := " "
	Private lResult   := .F.
	Private cError    := " "
	Private i         := 0
	Private cArq      := " "
	Private cMsg      := " "
	Private _xAlias   := GetArea()

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Definicao do cabecalho do email                                             ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	cMsg := ""
	cMsg += '<html>'
	cMsg += '<head>'
	cMsg += '<title>' + cAssunto + " - "+SM0->M0_NOME+"/"+SM0->M0_FILIAL+'</title>'
	cMsg += '</head>'
	cMsg += '<body>'
	//cMsg += '<Img Src="C:/AP5/SIGAADV/LGRL01.BMP"><BR>'
	cMsg += '</Table>'
	cMsg += '<P>'
	cMsg += '<Table align="center">'
	cMsg += '<tr>'
	cMsg += '<td colspan="10" align="center"><font color="red" size="5">'+cTiMail+'<font color="red" size="1">.</td>'
	cMsg += '</tr>'
	cMsg += '</Table>'

	cMsg += '<HR Width=85% Size=3 Align=Centered Color=Red> <P>'

	cMsg += '<Table Border=1 Align=Center BorderColor=#000000 CELLPADDING=4 CELLSPACING=0 Width=60%>'
	cMsg += '<Caption> <FONT COLOR=#000000 FACE= "ARIAL" SIZE=5>' + cAssunto +" - "+SM0->M0_NOME+"/"+SM0->M0_FILIAL+ '</FONT> </Caption>'
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Definicao do texto/detalhe do email                                         ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	For _nLin := 1 to Len(aMsg)
		IF (_nLin/2) == Int( _nLin/2 )
			cMsg += '<TR BgColor=#B0E2FF>'
		Else
			cMsg += '<TR BgColor=#FFFFFF>'
		EndIF
		cMsg += '<TD><B><Font Color=#000000 Size="2" Face="Arial">' + aMsg[_nLin,1] + ' </Font></B></TD>'
		cMsg += '<TD> <Font Color=#000000 Size="2" Face="Arial">' + aMsg[_nLin,2] + ' </Font></TD>'
		cMsg += '<TD><Font Color=#000000 Size="2" Face="Arial">  </Font></TD>'
		cMsg += '<TD><Font Color=#000000 Size="2" Face="Arial">  </Font></TD>'
		cMsg += '<TD><Font Color=#000000 Size="2" Face="Arial">  </Font></TD>'
		cMsg += '<TD><Font Color=#000000 Size="2" Face="Arial">  </Font></TD>'
		cMsg += '<TD><Font Color=#000000 Size="2" Face="Arial">  </Font></TD>'
		cMsg += '<TD><Font Color=#000000 Size="2" Face="Arial">  </Font></TD>'
		cMsg += '</TR>'
	Next

	For _nLin := 1 to Len(aMsgIt)
		IF (_nLin/2) == Int( _nLin/2 )
			cMsg += '<TR BgColor=#B0E2FF>'
		Else
			cMsg += '<TR BgColor=#FFFFFF>'
		EndIF
		If _nLin = 1
			cMsg += '<TD><Font color="red" Size="3" Face="Arial">' + aMsgIt[_nLin,1] + ' </Font></TD>'
			cMsg += '<TD> <Font color="red" Size="3" Face="Arial">' + aMsgIt[_nLin,2] + ' </Font></TD>'
			cMsg += '<TD><Font color="red" Size="3" Face="Arial">' + aMsgIt[_nLin,3] + ' </Font></TD>'
			cMsg += '<TD> <Font color="red" Size="3" Face="Arial">' + aMsgIt[_nLin,4] + ' </Font></TD>'
			cMsg += '<TD><Font color="red" Size="3" Face="Arial">' + aMsgIt[_nLin,5] + ' </Font></TD>'
			cMsg += '<TD> <Font color="red" Size="3" Face="Arial">' + aMsgIt[_nLin,6] + ' </Font></TD>'
			cMsg += '<TD><Font color="red" Size="3" Face="Arial">' + aMsgIt[_nLin,7] + ' </Font></TD>'
			cMsg += '<TD><Font color="red" Size="3" Face="Arial">' + aMsgIt[_nLin,8] + ' </Font></TD>'
			cMsg += '</TR>'
		Else
			cMsg += '<TD><Font Color=#000000 Size="2" Face="Arial">' + aMsgIt[_nLin,1] + ' </Font></TD>'
			If substr(aMsgIt[_nLin,2],1,2) <> substr(aMsgIt[_nLin,3],1,2)
				cMsg += '<TD> <Font color="green" Size="2" Face="Arial">' + aMsgIt[_nLin,2] + ' </Font></TD>'
				cMsg += '<TD><Font color="green" Size="2" Face="Arial">' + aMsgIt[_nLin,3] + ' </Font></TD>'
			Else
				cMsg += '<TD> <Font Color=#000000 Size="2" Face="Arial">' + aMsgIt[_nLin,2] + ' </Font></TD>'
				cMsg += '<TD><Font Color=#000000 Size="2" Face="Arial">' + aMsgIt[_nLin,3] + ' </Font></TD>'
			Endif
			If aMsgIt[_nLin,4] <> aMsgIt[_nLin,5]
				cMsg += '<TD> <Font color="green" Size="2" Face="Arial">' + aMsgIt[_nLin,4] + ' </Font></TD>'
				cMsg += '<TD><Font color="green" Size="2" Face="Arial">' + aMsgIt[_nLin,5] + ' </Font></TD>'
			Else
				cMsg += '<TD> <Font Color=#000000 Size="2" Face="Arial">' + aMsgIt[_nLin,4] + ' </Font></TD>'
				cMsg += '<TD><Font Color=#000000 Size="2" Face="Arial">' + aMsgIt[_nLin,5] + ' </Font></TD>'
			Endif
			If aMsgIt[_nLin,6] <> aMsgIt[_nLin,7]
				cMsg += '<TD> <Font color="green" Size="2" Face="Arial">' + aMsgIt[_nLin,6] + ' </Font></TD>'
				cMsg += '<TD><Font color="green" Size="2" Face="Arial">' + aMsgIt[_nLin,7] + ' </Font></TD>'
			Else
				cMsg += '<TD> <Font Color=#000000 Size="2" Face="Arial">' + aMsgIt[_nLin,6] + ' </Font></TD>'
				cMsg += '<TD><Font Color=#000000 Size="2" Face="Arial">' + aMsgIt[_nLin,7] + ' </Font></TD>'
			Endif
			cMsg += '<TD><Font Color=#000000 Size="2" Face="Arial">' + aMsgIt[_nLin,8] + ' </Font></TD>'
			cMsg += '</TR>'
		EndIF
	Next

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Definicao do rodape do email                                                ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	cMsg += '</Table>'
	cMsg += '<P>'
	cMsg += '<Table align="center">'
	cMsg += '<tr>'
	cMsg += '<td colspan="10" align="center"><font color="red" size="3">Mensagem enviada automaticamente pelo sistema PROTHEUS - <font color="red" size="1">('+cFuncSent+')</td>'
	cMsg += '</tr>'
	cMsg += '</Table>'
	cMsg += '<HR Width=85% Size=3 Align=Centered Color=Red> <P>'
	cMsg += '</body>'
	cMsg += '</html>'

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณEnvia o mail para a lista selecionada. Envia como BCC para que a pessoa penseณ
	//ณque somente ela recebeu aquele email, tornando o email mais personalizado.   ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	IF At(";",cEmail) > 0
		cEmailTo := SubStr(cEmail,1,At(";",cEmail)-1)
		cEmailCc:= SubStr(cEmail,At(";",cEmail)+1,Len(cEmail))
	Else
		cEmailTo := Alltrim(cEmail)
	EndIF

	CONNECT SMTP SERVER cServer ACCOUNT cAccount PASSWORD cPassword RESULT lResult

	If !lAutOk
		If ( lSmtpAuth )
			lAutOk := MailAuth(cAccount,cPassword)
		Else
			lAutOk := .T.
		EndIf
	EndIf

	If lResult .And. lAutOk
		SEND MAIL FROM cFrom ;
		TO      	Lower(cEmailTo);
		CC      	Lower(cEmailCc);
		BCC     	Lower(cEmailBcc);
		SUBJECT 	cAssunto;
		BODY    	cMsg;
		ATTACHMENT  cAttach;
		RESULT lResult

		If !lResult
			//Erro no envio do email
			GET MAIL ERROR cError

			MsgInfo(cError,OemToAnsi("Ateno"))
		EndIf

		DISCONNECT SMTP SERVER
	Else
		//Erro na conexao com o SMTP Server
		GET MAIL ERROR cError

		MsgInfo(cError,OemToAnsi("Ateno"))
	EndIf

	RestArea(_xAlias)
Return()
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFUNCOES   บAutor  ณMicrosiga           บ Data ณ  03/06/15   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function DIPCIC(cMail,cOpFatDest) // CIC PADRAO UTILIZADO A PARTI DE 15/12/11  Giovani Zago.
	Local cServidor   := ""                  // Servidor para enviar mensagem pelo CIC
	Local cOpFatRem   := GetMV("MV_REMETCI") // Usuario do CIC remetente de mensagens no Protheus
	Local cOpFatSenha := "123456"
	Local lAtivJob    := GetNewPar("ES_ATIVJOB",.T.)

	cMail:= Substr(cMail,1,424)  // limite max. de caracteres no cic

	If lAtivJob
		u_DipCicNew(cMail,cOpFatDest)
	Else
		If !("totvsrmt.ini" $ GetRemoteIniName())
			cServidor   := GetMV("MV_CIC")
		Else
			cServidor   := GetMV("ES_CICEXTE")    // envia cic se o acesso for via RemoteActivex
		EndIf

		WaitRun(cServidor+' '+cOpFatRem+' '+cOpFatSenha+' "'+AllTrim(cOpFatDest)+'" "'+cMail+'" ')
	EndIf

Return()
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFUNCOES   บAutor  ณMicrosiga           บ Data ณ  03/03/15   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function DipCicNew(cMail,cOpFatDest) // CIC PADRAO UTILIZADO A PARTI DE 15/12/11  Giovani Zago.
	Local cCodMsg := ZZJ->(GetSX8Num("ZZJ","ZZJ_CODMSG"))
	Local cCic1   := ""
	Local cCic2   := ""
	Local cMsg1   := ""
	Local cMsg2   := ""

	ConfirmSX8()

	If Len(cOpFatDest) > 250
		cCic2 := SubStr(cOpFatDest,1,250)
		nPos := Rat(",",cCic2)
		If nPos > 0
			cCic1 := SubStr(cOpFatDest,1,nPos)
			cCic2 := SubStr(cOpFatDest,nPos+1,Len(cOpFatDest))
		EndIf
	Else
		cCic1 := cOpFatDest
	EndIf

	If Len(cMail) > 250
		cMsg1 := SubStr(cMail,1,250)
		cMsg2 := SubStr(cMail,251,Len(cMail))
	Else
		cMsg1 := cMail
	EndIf

	ZZJ->(RecLock("ZZJ",.T.))
	ZZJ->ZZJ_FILIAL := xFilial("ZZJ")
	ZZJ->ZZJ_CODMSG := cCodMsg
	ZZJ->ZZJ_CIC	:= cCic1
	ZZJ->ZZJ_CIC2  	:= cCic2
	ZZJ->ZZJ_MSG	:= cMsg1
	ZZJ->ZZJ_MSG2	:= cMsg2
	ZZJ->ZZJ_DATA	:= dDataBase
	ZZJ->ZZJ_HORA	:= Time()
	ZZJ->ZZJ_USUARI	:= Upper(u_DipUsr())
	//ZZJ->ZZJ_REMOTE := IIf(FunName()=="DIPA072","",GetRemoteIniName())
	ZZJ->(MsUnlock())

Return()
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFUNCOES   บAutor  ณMicrosiga           บ Data ณ  03/03/15   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function DIPEXTENSO(nVal)
	Local cResVal := ""

	If nVal - noround(nVal,2) = 0
		cResVal := Extenso(nVal,.F.,1)
	ElseIf nVal - noround(nVal,3) = 0
		cResVal := Extenso(noround(nVal,0),.T.,1)+Iif(noround(nVal,0) >1," REAIS E ",Iif(nVal<1,""," REAL E "))+ Extenso(VAL(SUBSTR(CVALTOCHAR(nVal-noround(nVal,0)),3,3)),.T.,1)+" MILษSIMO DE REAL"
	ElseIf nVal - noround(nVal,4) = 0
		cResVal := Extenso(noround(nVal,0),.T.,1)+Iif(noround(nVal,0) >1," REAIS E ",Iif(nVal<1,""," REAL E "))+ Extenso(VAL(SUBSTR(CVALTOCHAR(nVal-noround(nVal,0)),3,4)),.T.,1)+" DษCIMOS DE MILษSIMO DE REAL"
	Else
		cResVal := Extenso(nVal,.F.,1)
	EndIf

	Return(cResVal)

	/*====================================================================================\
	|Programa  | CopySB1MAIL       | Autor | GIOVANI.ZAGO            | Data | 26/01/2012  |
	|=====================================================================================|
	|Descri็ใo | Envia e-mail na altera็ใo e na inclusao de produtos na HQ.               |
	|          | 														                  |
	|          |                                                                          |
	|=====================================================================================|
	|Sintaxe   | CopySB1MAIL                                                              |
	|=====================================================================================|
	|Uso       | Especifico DIPROMED                                                      |
	|=====================================================================================|
	|........................................Hist๓rico....................................|
	\====================================================================================*/
	*---------------------------------------------------*
User Function CopySB1MAIL(nChav)
	*---------------------------------------------------*

	Local _xAlias   := GetArea()
	Local _areaSB1  := SB1->(getarea())
	Local cDe       := "protheus@dipromed.com.br"
	Local cEmail    := GetMv("ES_COPYSB1",,"maximo.canuto@dipromed.com.br")        //grupo de usuarios para recebimento de e-mail
	Local cAssunto  := ""
	Local cAttach   := "a"
	Local cFuncSent := "COPYSB1MAIL.PRW"
	Local cAccount  := Lower(Alltrim(GetMv("MV_RELACNT")))
	Local cFrom     := If(Empty(Alltrim(cDe)),"protheus@dipromed.com.br",cDe)     //protheus@dipromed.com.br
	Local cPassword := Alltrim(GetMv("MV_RELPSW"))
	Local cServer   := Alltrim(GetMv("MV_RELSERV"))
	Local cEmailTo  := ""
	Local cEmailCc  := ""// maximo.canuto@dipromed.com.br"
	Local cEmailBcc := ""
	Local lResult   := .F.
	Local cError    := ""
	Local i         := 0
	Local cArq      := ""
	Local cMsg      := ""
	Local cTiMail   := ""
	Local _nLin
	Local nB1       := 0
	Local aMsg      := {}
	Local aSxCam      := {}
	Local cCamx3    := "SB1.B1_FILIAL"
	Local cCamB1    := "SB1.B1_FILIAL"
	Local k
	Local _cQry0  := ""
	Local cNumB1  :="3"
	Local cSisB1  :="4"
	LOCAL lSmtpAuth := GetNewPar("MV_RELAUTH",.F.)
	LOCAL lAutOk	:= .F.

	If  nChav = 1
		cTiMail    :=  " ATENวรO - INCLUSAO DE PRODUTO NA HQ. "
		cAssunto   :=  " INCLUSAO DE PRODUTO NA HQ."

		aAdd( aMsg , { "EMPRESA"      , + Capital( AllTrim( GetAdvFVal( "SM0", "M0_NOMECOM", cEmpAnt + cFilAnt, 1, "" ) ) )  } )
		aAdd( aMsg , { "FILIAL"       , + Capital( AllTrim( GetAdvFVal( "SM0", "M0_FILIAL" , cEmpAnt + cFilAnt, 1, "" ) ) ) } )
		aAdd( aMsg , { "COD. PROD."   , ALLTRIM(SB1->B1_COD)  } )
		aAdd( aMsg , { "DESCRIวรO"    , ALLTRIM(SB1->B1_DESC) } )

	ElseIf  nChav = 2
		cTiMail    := EncodeUTF8( " ATENวรO - ALTERAวรO DE PRODUTO NA HQ. ","cp1252")
		cAssunto   := EncodeUTF8( " ALTERAวรO DE PRODUTO NA HQ.","cp1252")

		aAdd( aMsg , { "EMPRESA"      , + Capital( AllTrim( GetAdvFVal( "SM0", "M0_NOMECOM", cEmpAnt + cFilAnt, 1, "" ) ) )  } )
		aAdd( aMsg , { "FILIAL"       , + Capital( AllTrim( GetAdvFVal( "SM0", "M0_FILIAL" , cEmpAnt + cFilAnt, 1, "" ) ) ) } )
		aAdd( aMsg , { "COD. PROD."   , ALLTRIM(SB1->B1_COD)  } )
		aAdd( aMsg , { "CAMPO "       , "ALTERAวรO" } )

		dbSelectArea("SX3")
		SX3->(dbSetOrder(1))
		SX3->(DbSeek("SB1"))

		While SX3->(!EOF()) .And. SX3->X3_ARQUIVO == 'SB1'
			If !(ALLTRIM(SX3->X3_CAMPO) $ "B1_FILIAL/B1_XTPAMCO/B1_USERLGA") .And. ALLTRIM(SX3->X3_CONTEXT) <> "V"

				aAdd( aSxCam , { ALLTRIM(SX3->X3_CAMPO) ,ALLTRIM(SX3->X3_TITULO) } )
				cCamx3 := cCamx3 +", TB1."+ ALLTRIM(SX3->X3_CAMPO)

			EndIf
			SX3->(DbSkip())
		EndDo

		_cQry0 :=" 	SELECT "+ cCamx3 + " "
		_cQry0 +=" 	FROM SB1040   SB1 "
		_cQry0 +=" 	INNER JOIN(SELECT * 	FROM SB1010   XB1 "
		_cQry0 +=" WHERE  XB1.B1_FILIAL = '01'     "
		_cQry0 +=" AND XB1.D_E_L_E_T_ = ' ')TB1
		_cQry0 +=" ON  TB1.B1_COD = SB1.B1_COD"
		_cQry0 +=" WHERE 	SB1.B1_COD = '"+SB1->B1_COD+"' "
		_cQry0 +=" AND SB1.B1_FILIAL = '01'     "
		_cQry0 +=" AND SB1.D_E_L_E_T_ = ' '  "

		dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQry0),'TMP1',.T.,.F.)

		If !EMPTY ("TMP1")
			DbSelectArea("TMP1")
			TMP1->(	DbGoTop())
			While TMP1->(!EOF())

				For k := 1 To Len(aSxCam)

					If alltrim(TMP1->&(aSxCam[k,1])) <> alltrim(SB1->&(aSxCam[k,1]))
						If type("SB1->"+(aSxCam[k,1])) == "C"
							aAdd( aMsg , { aSxCam[k,2]   , SB1->&(aSxCam[k,1]) } )
							nB1+=1
						ElseIf type("SB1->"+(aSxCam[k,1])) == "N"
							aAdd( aMsg , { aSxCam[k,2]   , cvaltochar(SB1->&(aSxCam[k,1])) } )
							nB1+=1
						ElseIf type("SB1->"+(aSxCam[k,1])) == "D"
							aAdd( aMsg , { aSxCam[k,2]   , DTOC(SB1->&(aSxCam[k,1])) } )
							nB1+=1
						ENDIF

					ENDIF

				Next k

				TMP1->( dbSkip())
			END
		EndIf

		TMP1->(DBCloseArea())

	EndIf

	If nB1 > 0
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ Definicao do cabecalho do email                                             ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		cMsg := ""
		cMsg += '<html>'
		cMsg += '<head>'
		cMsg += '<title>' + cAssunto + " - "+SM0->M0_NOME+"/"+SM0->M0_FILIAL+'</title>'
		cMsg += '</head>'
		cMsg += '<body>'
		//cMsg += '<Img Src="C:/AP5/SIGAADV/LGRL01.BMP"><BR>'
		cMsg += '</Table>'
		cMsg += '<P>'
		cMsg += '<Table align="center">'
		cMsg += '<tr>'
		cMsg += '<td colspan="10" align="center"><font color="red" size="5">'+cTiMail+'<font color="red" size="1">.</td>'
		cMsg += '</tr>'
		cMsg += '</Table>'

		cMsg += '<HR Width=85% Size=3 Align=Centered Color=Red> <P>'

		cMsg += '<Table Border=1 Align=Center BorderColor=#000000 CELLPADDING=4 CELLSPACING=0 Width=60%>'
		cMsg += '<Caption> <FONT COLOR=#000000 FACE= "ARIAL" SIZE=5>' + cAssunto +" - "+SM0->M0_NOME+"/"+SM0->M0_FILIAL+ '</FONT> </Caption>'
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ Definicao do texto/detalhe do email                                         ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		For _nLin := 1 to Len(aMsg)
			IF (_nLin/2) == Int( _nLin/2 )
				cMsg += '<TR BgColor=#B0E2FF>'
			Else
				cMsg += '<TR BgColor=#FFFFFF>'
			EndIF
			cMsg += '<TD><B><Font Color=#000000 Size="2" Face="Arial">' + aMsg[_nLin,1] + ' </Font></B></TD>'
			cMsg += '<TD> <Font Color=#000000 Size="2" Face="Arial">' + aMsg[_nLin,2] + ' </Font></TD>'
			cMsg += '</TR>'
		Next
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ Definicao do rodape do email                                                ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		cMsg += '</Table>'
		cMsg += '<P>'
		cMsg += '<Table align="center">'
		cMsg += '<tr>'
		cMsg += '<td colspan="10" align="center"><font color="red" size="3">Mensagem enviada automaticamente pelo sistema PROTHEUS - <font color="red" size="1">('+cFuncSent+')</td>'
		cMsg += '</tr>'
		cMsg += '</Table>'
		cMsg += '<HR Width=85% Size=3 Align=Centered Color=Red> <P>'
		cMsg += '</body>'
		cMsg += '</html>'

		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณEnvia o mail para a lista selecionada. Envia como BCC para que a pessoa penseณ
		//ณque somente ela recebeu aquele email, tornando o email mais personalizado.   ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		IF At(";",cEmail) > 0
			cEmailTo := SubStr(cEmail,1,At(";",cEmail)-1)
			cEmailCc:= SubStr(cEmail,At(";",cEmail)+1,Len(cEmail))
		Else
			cEmailTo := Alltrim(cEmail)
		EndIF

		CONNECT SMTP SERVER cServer ACCOUNT cAccount PASSWORD cPassword RESULT lResult

		If !lAutOk
			If ( lSmtpAuth )
				lAutOk := MailAuth(cAccount,cPassword)
			Else
				lAutOk := .T.
			EndIf
		EndIf

		If lResult .And. lAutOk
			SEND MAIL FROM cFrom ;
			TO      	Lower(cEmailTo);
			CC      	Lower(cEmailCc);
			BCC     	Lower(cEmailBcc);
			SUBJECT 	cAssunto;
			BODY    	cMsg;
			ATTACHMENT  cAttach;
			RESULT lResult

			If !lResult
				//Erro no envio do email
				GET MAIL ERROR cError

				MsgInfo(cError,OemToAnsi("Ateno"))
			EndIf

			DISCONNECT SMTP SERVER
		Else
			//Erro na conexao com o SMTP Server
			GET MAIL ERROR cError

			MsgInfo(cError,OemToAnsi("Ateno"))
		EndIf
	EndIf
	RestArea(_areaSB1)
	RestArea(_xAlias)
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณxTRAVSB     บAutor  ณReginaldo Borges    บ Data ณ  05/09/13 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Fun็ใo travara os campos da guia fretes/medidas quando o   บฑฑ
ฑฑบ          ณ campo XTPEMBV estiver ativo para baixar cx de embarque     บฑฑ
ฑฑบ          ณ e o usuario nใo etiver no parametro ES_TRAVSB.             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SB1                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function xTRAVSB()//U_xTRAVSB()

Local cDipUser := Upper(AllTrim(GetNewPar("ES_TRAVSB","")))
Local _lRet    := .T.

If Upper(FunName())<>"DIPA071"
	If !(Upper(U_DipUsr()) $ cDipUser)
		_lRet := .F.
	EndIf
EndIF



Return(_lRet)


//fun็๕es para valida็ใo no campo X3_WHEN B1_XQTDEMB
User function xTravS1()
 Local _lRet    := .T.
 
 IF M->B1_XVALSEC <> '3'  .AND.  M->B1_XVALSEC <> '1'    
 _lRet := .F. 
 ENDIF

Return(_lRet)

User function xTravS2()
 Local _lRet    := .T.
 
 IF M->B1_XVALSEC <> '3'  .AND.  M->B1_XVALSEC <> '2'   
 _lRet := .F. 
 ENDIF

Return(_lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณXVENREG   บAutor  ณReginaldo Borges    บ Data ณ  27/10/15  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Fun็ใo retornara falso quando a classifica็ใo anvisa do    บฑฑ
ฑฑบ          ณ produto for III  ou IV.                                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SB1                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function XVENREG(_cClass,_cCanvisa)

	Local _lRet    := .T.

	If (AllTrim(_cClass) == 'I' .Or. AllTrim(_cClass) == 'II') .And.;
	!(AllTrim(_cCanvisa) == 'Cosmetico'.Or. AllTrim(_cCanvisa) == 'Saneante')

		M->B1_XVENREG := "VIGENTE"

	Else
		_lRet := .F.
		M->B1_XVENREG := " "
	EndIf

Return(_lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณXDTVANV   บAutor  ณReginaldo Borges    บ Data ณ  27/10/15  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Fun็ใo retornara falso quando a classifica็ใo anvisa do    บฑฑ
ฑฑบ          ณ produto for I  ou II.                                      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SB1                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function XDTVANV(_cClass,_cCanvisa)

	Local _lRet    := .T.

	If AllTrim(_cClass) == 'III' .Or. AllTrim(_cClass) == 'IV' .Or.;
	AllTrim(_cCanvisa) == 'Cosmetico'.Or. AllTrim(_cCanvisa) == 'Saneante'

		M->B1_XVENREG := " "
	Else
		_lRet := .F.
	EndIf

Return(_lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณxTRAVSB1    บAutor  ณReginaldo Borges    บ Data ณ  05/11/14 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Fun็ใo travara os campos da guia fretes/Anvisa de          บฑฑ
ฑฑบ          ณ embalagens secundarias, caso o campo B1_XVALSEC esteja     บฑฑ
ฑฑบ          ณ marcado como nใo, produto sem embalagem secundaria.        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SB1                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
/*RBORGES 10/11/2014 - FOI ALTERADA POR UMA VALIDAวรO DIRETO NO X3_WHEN
User Function xTRAVSB1()//U_xTRAVSB1()
Local _lReto :=.F.

If SB1->B1_XVALSEC == "1"
_lReto := .T.
EndIf

Return(_lReto)
*/
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณX_A1EMAI X_A1EMAIDบAutor ณReginaldo Borgesบ Data ณ  03/20/13 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณValidar o preenchimento do campo do e-mail da SA1.          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SigaFat SA1                                                บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

USER FUNCTION XA1EMAI()

	LOCAL _lRet := .T.

	IF ALTERA

		IF! '@' $ ALLTRIM(M->A1_EMAIL)
			_lRet := .F.
		ENDIF

		IF! '.' $ ALLTRIM(M->A1_EMAIL)
			_lRet := .F.
		ENDIF

		IF '@dipromed' $ ALLTRIM(M->A1_EMAIL)  .And. cEmpAnt == '01'
			_lRet := .F.
			Alert("NรO ACEITA @dipromed!")
		ENDIF

		IF !_lRet

			Alert("PREENCHER O EMAIL CORRETAMENTE!")

		ENDIF

	ELSE

		IF INCLUI

			IF! '@' $ ALLTRIM(M->A1_EMAIL)
				_lRet := .F.
			ENDIF

			IF! '.' $ ALLTRIM(M->A1_EMAIL)
				_lRet := .F.
			ENDIF

			IF '@dipromed' $ ALLTRIM(M->A1_EMAIL) .And. cEmpAnt == '01'
				_lRet := .F.
				Alert("NรO ACEITA @dipromed!")
			ENDIF

			IF !_lRet

				Alert("PREENCHER O EMAIL CORRETAMENTE!")

			ENDIF

		ENDIF

	ENDIF

RETURN(_lRet)

//Fun็ใo para o A1_EMAILD

USER FUNCTION XA1EMAID()

	LOCAL __lRet := .T.

	IF ALTERA

		IF! '@' $ ALLTRIM(M->A1_EMAILD)
			__lRet := .F.
		ENDIF

		IF! '.' $ ALLTRIM(M->A1_EMAILD)
			__lRet := .F.
		ENDIF

		IF '@dipromed' $ ALLTRIM(M->A1_EMAILD) .And. cEmpAnt == '01'
			__lRet := .F.
			Alert("NรO ACEITA @dipromed!")
		ENDIF

		IF !__lRet

			Alert("PREENCHER O EMAIL CORRETAMENTE!")

		ENDIF

	ELSE

		IF INCLUI

			IF! '@' $ ALLTRIM(M->A1_EMAILD)
				__lRet := .F.
			ENDIF

			IF! '.' $ ALLTRIM(M->A1_EMAILD)
				__lRet := .F.
			ENDIF

			IF '@dipromed' $ ALLTRIM(M->A1_EMAILD) .And. cEmpAnt == '01'
				__lRet := .F.
				Alert("NรO ACEITA @dipromed!")
			ENDIF

			IF !__lRet

				Alert("PREENCHER O EMAIL CORRETAMENTE!")

			ENDIF

		ENDIF

	ENDIF

RETURN(__lRet)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFUNCOES   บAutor  ณMicrosiga           บ Data ณ  06/26/13   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function DipSC9Tran(cCampo)
	Local cRet	   := ""
	DEFAULT cCampo := ""

	cRet := SC5->(POSICIONE("SC5",1,xFilial("SC5")+SC9->C9_PEDIDO,"C5_TRANSP"))

	If cCampo == "C9_XDESTRA"
		cRet := SA4->(POSICIONE("SA4",1,xFilial("SA4")+cRet,"A4_NOME"))
	EndIf

	Return cRet

	/*-------------------------------------------------------------------------
	+ RBORGES - 21/06/2013 ----- User Funcion: AVCicST()                      +
	+ Farแ o tratamento para enviar CIC de aviso de ST                        +
	+ 														                  +
	-------------------------------------------------------------------------*/

	*--------------------------------------------------------------------------*
User Function AVCicST()
	*--------------------------------------------------------------------------*

	Local aArea       := GetArea()
	Local cDeIc       := "protheus@dipromed.com.br"
	Local cCICDest    := Upper(GetNewPar("ES_CIC_STP","REGINALDO.BORGES")) // Usuแrios que receberใo CICดs
	Local cAttachIc   :=  "  a"
	Local cFuncSentIc :=   " FUNCOES.prw "

	dbSelectArea("SM0")

	_aMsgIc := {}
	cMSGcIC       := 'AVISO – PEDIDO DE VENDAS C/ PRIORIDADE – CONCLUIR EM 2H – GUIA DE ST INCLUSO – PV-' + SC5->C5_NUM +CHR(13)+CHR(10)+CHR(13)+CHR(10)

	cMSGcIC       += " EMPRESA:_______    " + Capital( AllTrim( GetAdvFVal( "SM0", "M0_NOME", cEmpAnt + cFilAnt, 1, "" ) ) ) +"/"+ Capital( AllTrim( GetAdvFVal( "SM0", "M0_FILIAL" , cEmpAnt + cFilAnt, 1, "" ) ) )   +CHR(13)+CHR(10)
	cMSGcIC       += " PEDIDO:________    " + SC5->C5_NUM +CHR(13)+CHR(10)
	cMSGcIC       += " CLIENTE:________   " + SC5->C5_CLIENTE+" - "+Posicione("SA1",1,XFILIAL("SA1")+SC5->C5_CLIENTE,'A1_NREDUZ') +CHR(13)+CHR(10)
	cMSGcIC       += " COND.PAG:__________" + SC5->C5_CONDPAG+" - "+Posicione("SE4",1,XFILIAL("SE4")+SC5->C5_CONDPAG,'E4_DESCRI') +CHR(13)+CHR(10)
	cMSGcIC       += " OPERADOR:_______   " + SC5->C5_OPERADO+"-"+Posicione("SU7",1,xFilial("SU7")+SC5->C5_OPERADO,"U7_NREDUZ")   +CHR(13)+CHR(10)
	cMSGcIC       += " TRANSP.:_______    " + SC5->C5_TRANSP+" - " + AllTrim(FDesc("SA4",SC5->C5_TRANSP,"SA4->A4_NREDUZ"))        +CHR(13)+CHR(10)

	U_DIPCIC(cMSGcIC,cCICDest)

	RestArea(aArea)
return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDIPM010   บAutor  ณMicrosiga           บ Data ณ  05/03/13   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Rotina para enviar CIC e EMAIL 				              บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function CICMailAV(cPedido)
	Local aAreaSC5  := SC5->(GetArea())
	Local aMsg		:= {}
	Local cEmail	:= ""
	Local cAssunto	:= ""
	Local cQuery 	:= ""
	Local cVal_STD 	:= ""
	Local aMsg1 	:= {}
	Local cSuframa 	:= ""
	Local cDescIcm 	:= ""
	Local cNomeCliente:= ""
	Local cFrom 	:= ""
	Local aMsgSuf 	:= {}
	Local cDescIcm	:= ""
	Local nTotped   := 0
	Local cTituV    := "ATENวรO PEDIDO TEM PRIORIDADE NA LIBERAวรO"

	Private cEmailIcm   :=  ""
	Private	cAssuntIcm  :=  "AVISO – PEDIDO DE VENDAS C/ PRIORIDADE – CONCLUIR EM 2H – GUIA DE ICMS INTERESTADUAL – PV - " + SC5->C5_NUM
	Private	cAttachIcm  :=  "  a"
	Private	cDeIcm      :=  Lower(Alltrim(Posicione("SU7",1,xFilial("SU7")+SC5->C5_OPERADO,"U7_EMAIL")))
	Private	cSentIcm 	:=  "DIPM010.prw"
	Private _aMIcm	    := {}

	If ISINCALLSTACK("LOJA901A") .Or. ISINCALLSTACK("LOJA901")
		Return(cPedido)
	EndIf

	SC5->(dbSetOrder(1))
	SC5->(dbSeek(xFilial("SC5")+cPedido))

	cDeIcm       :=  Lower(Alltrim(Posicione("SU7",1,xFilial("SU7")+SC5->C5_OPERADO,"U7_EMAIL")))
	cEmailIcm    :=  GetMv("ES_DIPV4_6")+","+cDeIcm

	If !Empty(SC5->C5_SENHCID) .or. !Empty(SC5->C5_SENHPAG) .or. !Empty(SC5->C5_SENHMAR) .or. !Empty(SC5->C5_SENHTES)
		/*====================================================================================\
		|SELECIONANDO ITENS DO PEDIDO QUE POSSUI SENHA GRAVADA PARA ENVIAR AO ERICH           |
		\====================================================================================*/

		cQuery := " SELECT C5_CLIENTE, C5_LOJACLI, A1_NOME, C5_NUM, C5_EMISSAO, C5_OPERADO, C5_MARGATU, C5_MARGLIB, C5_SENHCID, C5_SENHTES, C5_SENHMAR, C5_SENHPAG, C5_EXPLSEN, C5_DATA1, C5_PARC1, C5_DATA2, C5_PARC2, C5_DATA3, C5_PARC3, C5_DATA4, C5_PARC4, C5_PARC5, C5_DATA5, C5_PARC6, C5_DATA6, C6_PRODUTO, C6_MARGATU, C6_MARGITE, C6_QTDVEN, C6_PRCVEN, C6_CUSTO, C6_PRCMIN, C6_NOTA, C6_VALOR, B1_DESC, B1_UCOM, B1_UPRC+(B1_UPRC*B1_IPI/100) B1_UPRC, B1_PRVMINI, B1_PRVSUPE, B1_ALTPREC, U7_NREDUZ, U7_EMAIL, E4_DESCRI, C5_DATA1, C5_DATA2, C5_DATA3, C5_DATA4 "
		cQuery += " FROM " + RetSQLName("SC6") + ", " + RetSQLName("SC5") + ", " + RetSQLName("SA1") + ", " + RetSQLName("SU7") + ", " + RetSQLName("SB1") + ", " + RetSQLName("SE4")
		cQuery += " WHERE C6_FILIAL = '"+xFilial("SC6")+"'" // JBS 09/11/2005
		cQuery += "   AND C5_FILIAL = '"+xFilial("SC5")+"'" // JBS 09/11/2005
		cQuery += "   AND A1_FILIAL = '"+xFilial("SA1")+"'" // JBS 09/11/2005
		cQuery += "   AND U7_FILIAL = '"+xFilial("SU7")+"'" // JBS 09/11/2005
		cQuery += "   AND B1_FILIAL = '"+xFilial("SB1")+"'" // JBS 09/11/2005
		cQuery += "   AND E4_FILIAL = '"+xFilial("SE4")+"'" // JBS 09/11/2005
		cQuery += "   AND C6_NUM = '" + SC5->C5_NUM + "'" // JBS 09/11/2005
		cQuery += "   AND C5_NUM = C6_NUM"
		cQuery += "   AND C6_CLI = A1_COD"
		cQuery += "   AND C6_LOJA = A1_LOJA"
		cQuery += "   AND C5_OPERADO = U7_COD"
		cQuery += "   AND E4_CODIGO = C5_CONDPAG"
		cQuery += "   AND B1_COD = C6_PRODUTO"
		cQuery += "   AND " + RetSQLName("SC6") + ".D_E_L_E_T_ <> '*'"
		cQuery += "   AND " + RetSQLName("SC5") + ".D_E_L_E_T_ <> '*'"
		cQuery += "   AND " + RetSQLName("SA1") + ".D_E_L_E_T_ <> '*'"
		cQuery += "   AND " + RetSQLName("SU7") + ".D_E_L_E_T_ <> '*'"
		cQuery += "   AND " + RetSQLName("SB1") + ".D_E_L_E_T_ <> '*'"
		cQuery += "   AND " + RetSQLName("SE4") + ".D_E_L_E_T_ <> '*'"
		cQuery += " ORDER BY C6_NUM"

		cQuery := ChangeQuery(cQuery)

		DbCommitAll()
		DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"QRY1",.T.,.T.)

		DbSelectArea("QRY1")
		QRY1->(dbGotop())

		Do While QRY1->(!EOF())
			aadd(aMsg,{QRY1->C5_CLIENTE, QRY1->C5_LOJACLI, QRY1->A1_NOME, QRY1->C5_NUM, QRY1->C5_EMISSAO, QRY1->C5_OPERADO, QRY1->C5_MARGATU, QRY1->C5_MARGLIB, QRY1->C5_SENHMAR, QRY1->C5_SENHPAG, QRY1->C5_SENHTES, QRY1->C5_SENHCID, QRY1->C5_EXPLSEN, QRY1->C5_DATA1, QRY1->C5_PARC1, QRY1->C5_DATA2, QRY1->C5_PARC2, QRY1->C5_DATA3, QRY1->C5_PARC3, QRY1->C5_DATA4, QRY1->C5_PARC4, QRY1->C5_DATA5, QRY1->C5_PARC5, QRY1->C5_DATA6, QRY1->C5_PARC6, QRY1->C6_PRODUTO, QRY1->C6_MARGATU, QRY1->C6_MARGITE, QRY1->C6_QTDVEN, QRY1->C6_PRCVEN, QRY1->C6_CUSTO, QRY1->C6_PRCMIN, QRY1->C6_NOTA, QRY1->C6_VALOR, QRY1->B1_DESC, QRY1->B1_UCOM, QRY1->B1_UPRC, QRY1->B1_PRVMINI, QRY1->B1_PRVSUPE, QRY1->B1_ALTPREC, QRY1->U7_NREDUZ, QRY1->U7_EMAIL, QRY1->E4_DESCRI, QRY1->C5_DATA1, QRY1->C5_DATA2, QRY1->C5_DATA3, QRY1->C5_DATA4})
			QRY1->(DbSkip())
		EndDo

		If Len(aMsg) > 0 // SE NรO POSSUIR NENHUMA LINHA NO ARRAY NรO ENVIA NADA
			cEmail := 'erich@dipromed.com.br'
			If '02' $ Posicione("SU7",1,xFilial("SU7")+SC5->C5_OPERADO,"U7_POSTO")
				cEmail := cEmail +" ;patricia.mendonca@dipromed.com.br"
			EndIf
			cAssunto := 'Pedido de venda liberado por senha - ' + SC5->C5_NUM
			If substr(SC5->C5_XRECOLH,5,1) $ "-"
				cAssunto := cAssunto + " - Item com Valor Menor que Pre็o de Lista."
			EndIf
			U_EMail2(cEmail,cAssunto,aMsg)
		Endif

		DBCLOSEAREA("QRY1")
	EndIf

	If SubStr(SC5->C5_MENNOTA,AT('=',SC5->C5_MENNOTA),5) == "=ST=D"  .AND. Val(Left(SC5->C5_MENNOTA,4)) > 0 .And. !(SC5->C5_ESTE$GetNewPar("ES_ESTNGST","BA")) // VERIFICA SE SUBST. TRIBUTมRIA ESTม INCLUSO NO VALOR DA DESPESA. TRATANDO ST COM VALOR 0 - MCVN 12/11/09.
		/*====================================================================================\
		|SELECIONANDO ITENS DO PEDIDO QUE POSSUI SUBSTITUIวรO TRIBUTมRIA NA DESPESA           |
		\====================================================================================*/

		cQuery := "SELECT C6_NUM, C6_ITEM, C6_PRODUTO, C6_QTDVEN, C6_UM, C6_DESCRI, C6_VALOR, C6_CLI, C6_LOJA, C5_MENNOTA, A1_NOME, A1_EST, U7_EMAIL, C5_FRETE, C5_DESPESA, C5_TRANSP, C5_OPERADO "
		cQuery += " FROM " + RetSQLName("SC6") + ", " + RetSQLName("SC5") + ", " + RetSQLName("SA1") + ", " + RetSQLName("SU7")
		cQuery += " WHERE C5_FILIAL = '"+xFilial("SC5")+"'" // JBS 09/11/2005
		cQuery += "   AND C6_FILIAL = '"+xFilial("SC6")+"'" // JBS 09/11/2005
		cQuery += "   AND A1_FILIAL = '"+xFilial("SA1")+"'" // JBS 09/11/2005
		cQuery += "   AND U7_FILIAL = '"+xFilial("SU7")+"'" // JBS 09/11/2005
		cQuery += "   AND C6_NUM = '" + SC5->C5_NUM + "'" // JBS 09/11/2005
		cQuery += "   AND C5_NUM = C6_NUM"
		cQuery += "   AND C6_CLI = A1_COD"
		cQuery += "   AND C6_LOJA = A1_LOJA"
		cQuery += "   AND C5_OPERADO = U7_COD"
		cQuery += "   AND " + RetSQLName("SC6") + ".D_E_L_E_T_ <> '*'"
		cQuery += "   AND " + RetSQLName("SC5") + ".D_E_L_E_T_ <> '*'"
		cQuery += "   AND " + RetSQLName("SA1") + ".D_E_L_E_T_ <> '*'"
		cQuery += "   AND " + RetSQLName("SU7") + ".D_E_L_E_T_ <> '*'"
		cQuery += " ORDER BY C6_NUM"

		cQuery := ChangeQuery(cQuery)

		DbCommitAll()
		DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"QRY2",.T.,.T.)

		dbSelectArea("QRY2")
		dbGotop()

		Do While QRY2->(!EOF())
			cVal_STD := SubStr(QRY2->C5_MENNOTA,1,AT("=",QRY2->C5_MENNOTA)-1)
			aadd(aMsg1,{QRY2->C6_NUM, QRY2->C6_ITEM, QRY2->C6_PRODUTO, QRY2->C6_DESCRI, QRY2->C6_UM, QRY2->C6_QTDVEN, QRY2->C6_VALOR, QRY2->C6_CLI, QRY2->C6_LOJA, QRY2->A1_NOME, QRY2->A1_EST, Val(cVal_STD), QRY2->U7_EMAIL, QRY2->C5_FRETE, QRY2->C5_DESPESA, QRY2->C5_TRANSP+"-"+POSICIONE("SA4",1,xFilial("SA4")+QRY2->C5_TRANSP,"A4_NREDUZ"),QRY2->C5_OPERADO})
			//			 1             2             3                 4                5             6               7               8             9              10             11               12          13              14              15                                                                                 16               17
			QRY2->(DbSkip())
		EndDo
		QRY2->(dbCloseArea())

		If Len(aMsg1) > 0 // SE NรO POSSUIR NENHUMA LINHA NO ARRAY NรO ENVIA NADA
			cEmail := GetNewPar("ES_DIP_STP","reginaldo.borges@dipromed.com.br")//'magda.teixeira@dipromed.com.br;william.pereira@dipromed.com.br;sirlene.creatto@dipromed.com.br'
			cAssunto := 'AVISO – PEDIDO DE VENDAS C/ PRIORIDADE – CONCLUIR EM 2H – GUIA DE ST INCLUSO – PV-' + SC5->C5_NUM

			U_AVCicST()//RBORGES 21/06/2013

			U_EMailPre(cEmail,cAssunto,aMsg1)
		Endif
	EndIf

	// ENVIA EMAIL SE CLIENTE TIVER SUFRAMA (PIN-PROTOCOLO DE INTERNAวรO DE NOTA FISCAL)  17/01/2008
	cSuframa := Posicione('SA1', 1, xFilial('SA1') + SC5->C5_CLIENTE + SC5->C5_LOJACLI, 'A1_SUFRAMA')
	If  !Empty(cSuframa)
		cDescIcm     := SA1->A1_CALCSUF
		cNomeCliente := SA1->A1_NOME
		cFrom        := Lower(Alltrim(Posicione("SU7",1,xFilial("SU7")+SC5->C5_OPERADO,"U7_EMAIL")))

		Aadd( aMsgSuf , { "Cliente: "             , SC5->C5_CLIENTE + " - " + cNomeCliente} )
		Aadd( aMsgSuf , { "Numero Pedido: "       , SC5->C5_NUM } )
		Aadd( aMsgSuf , { "Operador: "            , SC5->C5_OPERADO +" - " + Alltrim(Posicione("SU7",1,xFilial("SU7")+SC5->C5_OPERADO,"U7_NOME")) } )
		Aadd( aMsgSuf , { "Transportadora: "      , SC5->C5_TRANSP + " - " + Alltrim(Posicione("SA4",1,xFilial("SA4")+SC5->C5_TRANSP,"A4_NOME" )) } )
		Aadd( aMsgSuf , { "Destino do Pedido:  "  , SC5->C5_ESTE +" - "+ SC5->C5_MUNE } )
		Aadd( aMsgSuf , { "C๓digo Suframa: "      , Posicione('SA1', 1, xFilial('SA1') + SC5->C5_CLIENTE + SC5->C5_LOJACLI, 'A1_SUFRAMA') } )
		If cDescIcm == "S"
			Aadd( aMsgSuf , { "Desconto Icms:  "  , "SIM" } )
		Endif

		If Len(aMsgSuf) > 0
			cEmail 	 := GetNewPar("ES_MAILSUF","magda.teixeira@dipromed.com.br;sirlene.creatto@dipromed.com.br;deoclecio.santos@dipromed.com.br")
			cAssunto := 'AVISO - Cliente com SUFRAMA - PV-' + SC5->C5_NUM
			U_UEnvMail(cEmail,cAssunto,aMsgSuf,"",cFrom,"Prenota.prw")
		Endif
	EndIf

	//giovani reposicionamento do e-mail do cic e do e-mail a vista sem para no financeiro. 12/07/11

	SA1->(dbSetOrder(1))
	SA1->(dbSeek(xFilial("SA1") + SC5->C5_CLIENTE + SC5->C5_LOJACLI))

	If SC5->C5_TIPODIP = "1" .And. substr(SC5->C5_XRECOLH,1,3) $ "ACR/GUI"

		aAdd( _aMIcm , { "EMPRESA"      , + Capital( AllTrim( GetAdvFVal( "SM0", "M0_NOMECOM", cEmpAnt + cFilAnt, 1, "" ) ) )  } )
		aAdd( _aMIcm , { "FILIAL"       , + Capital( AllTrim( GetAdvFVal( "SM0", "M0_FILIAL" , cEmpAnt + cFilAnt, 1, "" ) ) ) } )
		aAdd( _aMIcm , { "PEDIDO"       , ""+SC5->C5_NUM+""  } )
		aAdd( _aMIcm , { "CLIENTE"      , ""+AllTrim(SA1->A1_COD)+" - "+AllTrim(SA1->A1_NREDUZ)+""  } )
		aAdd( _aMIcm , { "E-Mail"       , ""+Lower(Alltrim(Posicione("SA1",1,xFilial("SA1")+SC5->C5_CLIENTE+SC5->C5_LOJACLI,"A1_EMAIL")))+""} ) //giovani 19/07/11
		aAdd( _aMIcm , { "OPERADOR"      ,""+SC5->C5_OPERADO+"-"+Posicione("SU7",1,xFilial("SU7")+SC5->C5_OPERADO,"U7_NOME") })
		aAdd( _aMIcm , { "VENDEDOR"      ,""+SC5->C5_VEND1+"-"+Posicione("SA3",1,xFilial("SA3")+SC5->C5_VEND1,"A3_NOME") })
		aAdd( _aMIcm , { "TRANSPORTADORA", ""+SC5->C5_TRANSP+" - " + AllTrim(FDesc("SA4",SC5->C5_TRANSP,"SA4->A4_NREDUZ"))+" "  } )
		If substr(SC5->C5_XRECOLH,1,3) $ "ACR"
			aAdd( _aMIcm , { "OPวรO"        , "1- Acrescimo no Valor do Pedido."  } )
		EndIf

		U_MailPedi(cEmailIcm,cAssuntIcm,_aMIcm,cAttachIcm,cDeIcm,cSentIcm,cTituV)

		//manda cic do pedido

		cMSGcIC       := "AVISO – PEDIDO DE VENDAS C/ PRIORIDADE – CONCLUIR EM 2H – GUIA DE ICMS INTERESTADUAL" +CHR(13)+CHR(10)+CHR(13)+CHR(10)
		//................1 2 3 4 5 6 7 8 9 0

		cMSGcIC       += _aMIcm[3][1]+":____________" +_aMIcm[3][2] +CHR(13)+CHR(10)
		//................1 2 3 4 5 6 7 8 9 0
		cMSGcIC       += " EMPRESA:_______" + Capital( AllTrim( GetAdvFVal( "SM0", "M0_NOME", cEmpAnt + cFilAnt, 1, "" ) ) ) +"/"+ Capital( AllTrim( GetAdvFVal( "SM0", "M0_FILIAL" , cEmpAnt + cFilAnt, 1, "" ) ) ) +CHR(13)+CHR(10)
		//................1 2 3 4 5 6 7 8 9 0
		cMSGcIC       += _aMIcm[4][1]+":___________" +_aMIcm[4][2] +CHR(13)+CHR(10)
		//................1 2 3 4 5 6 7 8 9 0
		cMSGcIC       += _aMIcm[6][1]+":_________" +_aMIcm[6][2] +CHR(13)+CHR(10)
		//................1 2 3 4 5 6 7 8 9 0
		cMSGcIC       += _aMIcm[8][1]+":__" +_aMIcm[8][2] +CHR(13)+CHR(10)
		//................1 2 3 4 5 6 7 8 9 0
		If substr(SC5->C5_XRECOLH,1,3) $ "ACR"
			cMSGcIC       += _aMIcm[9][1]+":_____________" +_aMIcm[9][2] +CHR(13)+CHR(10)
			//................1 2 3 4 5 6 7 8 9 0
		EndIf
		//	cMSGcIC       += "AVISO – PEDIDO DE VENDAS C/ PRIORIDADE – CONCLUIR EM 2H – GUIA DE ICMS INTERESTADUAL – PV - " + SC5->C5_NUM +CHR(13)+CHR(10)
		//................1 2 3 4 5 6 7 8 9 0

		//manda CIC
		U_DIPCIC(cMSGcIC,GetMV("ES_DIPV4_7"))

		//giovani msg do cic na libera็ใo do pedido a vista  e nao ficou parado no financeiro

		If SC5->C5_CONDPAG $ "001/002"
			If	SC5->C5_TIPODIP = "1"
				cMSGcIC   := " "
				nTotped := ValorPedido(SC5->C5_NUM)

				// Monta a mensagem a ser enviado ao operador
				cMSGcIC := "PEDIDO A VISTA"+CHR(13)+CHR(10)+CHR(13)+CHR(10)
				cMSGcIC += "O Pedido A VISTA   "   +Alltrim(SC5->C5_NUM)+CHR(13)+CHR(10)+CHR(13)+CHR(10)
				cMSGcIC += " do Cliente   "+AllTrim(SA1->A1_COD)+" - "+AllTrim(SA1->A1_NREDUZ)+CHR(13)+CHR(10)+CHR(13)+CHR(10)
				cMSGcIC += " Valor total "+AllTrim(Transform(nTotped,"@E 999,999,999.99"))+CHR(13)+CHR(10)+CHR(13)+CHR(10)+CHR(13)+CHR(10)      // Incluido por Sandro em 10/11/09

				cMSGcIC += "Operador:  "+SC5->C5_OPERADO+"-"+Posicione("SU7",1,xFilial("SU7")+SC5->C5_OPERADO,"U7_NOME")

				U_DIPCIC(cMSGcIC,GetMV("ES_DIPV4_5"))
			EndIf
		Endif
	EndIf

	U_DipCicCli()

	RestArea(aAreaSC5)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDIPM010   บAutor  ณMicrosiga           บ Data ณ  07/11/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ValorPedido(cPedido)
	*--------------------------------------------------------------------------*
	Local aArea      := GetArea()
	Local aAreaSC61   := SC6->( GetArea() )
	Local aAreaSC51   := SC5->( GetArea() )
	Local nVlrPed    := 0

	DbSelectArea("SC6")
	DbSetOrder(1)
	SC6->(DbSeek(xFilial("SC6")+cPedido))
	While SC6->C6_NUM == cPedido
		If SC6->C6_NUM == cPedido
			nVlrPed += SC6->C6_VALOR
		Endif
		SC6->(DbSkip())
	Enddo
	SC6->(DbCloseArea())

	nVlrPed := (nVlrPed + SC5->C5_DESPESA + SC5->C5_SEGURO + SC5->C5_FRETE)

	RestArea( aAreaSC51 )
	RestArea( aAreaSC61 )
	RestArea( aArea )

Return(nVlrPed)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFUNCOES   บAutor  ณMicrosiga           บ Data ณ  10/16/13   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function VldD3DOC()
	Local lRet := .T.
	If Upper(FunName())=="MATA242"
		If Type("cDocumento")<>"U" .And. cDocumento <> NextNumero("SD3",2,"D3_DOC",.T.)
			Aviso("Aten็ใo","N๚mero de documento invแlido."+CHR(10)+CHR(13)+"N๚mero correto: "+NextNumero("SD3",2,"D3_DOC",.T.),{"Ok"},1)
			lRet := .F.
		EndIf
	EndIf
Return lRet

/*RBorges 25/10/2013 - Fun็ใo criada para verificar se o
pedido atualiza estoque ou nใo.
*/

User Function NaoMovEst(cPedido)
	Local lRet := .F.
	Local cSQL := ""
	Local cMsg := ""
	DEFAULT cPedido := ""

	cSQL := " SELECT "
	cSQL += " 	F4_ESTOQUE"
	cSQL += " 	FROM "
	cSQL += " 	  "+RetSQlName("SC6")+", "+RetSQLName("SF4")
	cSQL += " 		WHERE "
	cSQL += " 			C6_FILIAL = '"+xFilial("SC6")+"' "
	cSQL += " 			AND F4_FILIAL = '"+xFilial("SF4")+"' "
	cSQL += " 			AND C6_TES = F4_CODIGO "
	cSQL += " 			AND C6_NUM = '"+cPedido+"' "
	cSQL += " 			AND F4_ESTOQUE = 'S' "
	cSQL += " 			AND "+RetSQlName("SC6")+".D_E_L_E_T_ = ' ' "
	cSQL += " 			AND "+RetSQlName("SF4")+".D_E_L_E_T_ = ' ' "

	cSQL := ChangeQuery(cSQL)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),"QRYSC6",.T.,.T.)

	lRet := QRYSC6->(Eof())

	QRYSC6->(dbCloseArea())

Return lRet

/*RBorges 31/10/2013 - Fun็ใo criada para verificar se a
a nota fiscal jแ tem Cte gerado.
*/

User Function NaoGeraCte(cFil,cNota,cSerie,cCliD,cLojaD)
	Local   lRet    := .F.
	Local   cSQL    := ""
	DEFAULT cCliD   := ""
	DEFAULT cLojaD   := ""
	DEFAULT cFil    := ""
	DEFAULT cNota   := ""
	DEFAULT cSerie  := ""

	cSQL := " SELECT "
	cSQL += " DISTINCT	DTC_DOC"
	cSQL += " 	FROM "
	cSQL += " 	 DTC030 "
	cSQL += " 		WHERE "
	cSQL += " 			    DTC_LOJREM = '"+cFil+"'"
	cSQL += " 			AND DTC_NUMNFC = '"+cNota+"' "
	cSQL += " 			AND DTC_SERNFC = '"+cSerie+"' "
	cSQL += " 			AND DTC_CLIDES = '"+cCliD+"' "
	cSQL += " 			AND DTC_LOJDES = '"+cLojaD+"' "
	cSQL += " 			AND DTC030.D_E_L_E_T_ = ' ' "

	cSQL := ChangeQuery(cSQL)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),"QRYDTC",.T.,.T.)

	lRet := QRYDTC->(Eof())

	QRYDTC->(dbCloseArea())

Return lRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFUNCOES   บAutor  ณMicrosiga           บ Data ณ  11/19/13   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function DipReport(aDados,aRCampos,lMarca,lSetPrint,nFormat)
	LOCAL cString    := aDados[1]
	LOCAL cDesc1     := aDados[2]
	LOCAL cDesc2     := aDados[3]
	LOCAL cDesc3     := aDados[4]
	LOCAL tamanho    := aDados[5]
	LOCAL limite     := aDados[6]
	LOCAL cabec1     := aDados[7]
	LOCAL cabec2     := aDados[8]
	LOCAL wnrel      := aDados[11]

	LOCAL lPermiteComprimir:=.T.

	PRIVATE titulo   := aDados[9]
	PRIVATE aReturn  := aDados[10]  // 1=formulario
	// 2=no.vias
	// 3=destinatario
	// 4=formato (1-comprimido, 2-normal)
	// 5=midia (1-disco, 2-impressora)
	// 6=porta (1-lpt1, 2-lpt2, 4-com1)
	// 7=expressao do filtro
	// 8=ordem a ser selecionada
	PRIVATE R_Funcoes:= aDados[12]
	PRIVATE R_Campos := aRCampos

	PRIVATE nomeprog := wnrel
	PRIVATE nLastKey := 0
	PRIVATE cPerg    :=NIL
	DEFAULT nFormat  := 1 //Retrato

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤgฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Envia controle para a funcao SETPRINT                        ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	IF lMarca == Nil
		lMarca:= .F.
	ENDIF
	IF lSetPrint == NIL .OR. lSetPrint
		Wnrel := SetPrint(cString,wnrel,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.f.,,lPermiteComprimir,tamanho)
	ENDIF
	//wnrel := SetPrint(cString,wnrel,cPerg,titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,.T.,Tamanho,,.t.)

	If nLastKey == 27
		Return
	Endif

	SetDefault(aReturn,cString,nil,nil,nil,nFormat)

	If nLastKey == 27
		Return
	Endif

	RptStatus({|lEnd| DipImpRel(@lEnd,wnRel,cString,tamanho,limite,cabec1,cabec2,lMarca)},titulo)

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFUNCOES   บAutor  ณMicrosiga           บ Data ณ  11/19/13   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function DipImpRel(lEnd,WnRel,cString,tamanho,limite,cabec1Loc,cabec2Loc,lMarca)
	LOCAL aCampos := {}, nRec:=RecNo(), nAsterisco:=80
	LOCAL aTam:={}, num_campos:=LEN(R_Campos),SpcCol,SpcIni
	LOCAL b_pos :={|valor,ind| T_Len[ind+1,2]:=T_Len[ind,2]+T_Len[ind,1]+SpcCol}
	LOCAL b_lin :={|valor,ind| F_Ler_Tab(R_Campos,ind)}
	LOCAL lRodaPe:=GetNewPar("MV_LOGOREL",.T.)
	PRIVATE TotLen:=0, Linha:=99, l_tag:=0, T_Len[num_campos][2]
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Variaveis utilizadas para Impressao do Cabecalho e Rodape    ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	Linha    := 80
	m_pag    := 1

	PRIVATE cabec1:=cabec1Loc //AWR 05/11/1998
	PRIVATE cabec2:=cabec2Loc //AWR 05/11/1998
	PRIVATE MConta:=MContG:=0

	AEVAL(R_Campos, b_lin)
	Len_Rel:= TotLen+num_campos-1
	SpcCol := INT( ( Len_Rel - TotLen ) / (num_campos-1)  )
	SpcCol := IF(SpcCol<1,1,SpcCol)
	SpcIni := INT( ( Len_Rel - TotLen - SpcCol * ( num_campos - 1 ) ) / 2 )
	SpcIni := IF( SpcIni < 1.OR.SpcIni>=2 , 1 , SpcIni )
	T_Len[1,2]:=SpcIni
	AEVAL(T_Len,b_pos,,num_campos-1)

	DO CASE
		CASE Tamanho == "P"  ; nAsterisco:=80
		CASE Tamanho == "M"  ; nAsterisco:=132
		CASE Tamanho == "G"  ; nAsterisco:=220
	ENDCASE

	DO CASE
		CASE Len_Rel <= 80
		Len_Rel := 80
		CASE Len_Rel > 80 .AND. Len_Rel <= 136
		Len_Rel := 136
		CASE Len_Rel >  136
		Len_Rel := 225
	ENDCASE

	dbGoTop()
	SetRegua(RecCount())   // Total de elementos da regua

	IF VALTYPE(R_Funcoes) == "A" .AND. LEN(R_Funcoes) > 2
		EVAL(R_Funcoes[3])
	ENDIF

	DO While !Eof()

		IF lEnd
			@PROW()+1,001 PSAY "CANCELADO PELO OPERADOR"
			Exit
		Endif

		If lMarca
			IF R_Funcoes # NIL
				IF ! EVAL(R_Funcoes[1])
					DBSKIP() ; LOOP
				ENDIF
			ENDIF
		EndIf

		IF Linha > 55
			Cabec(titulo,cabec1,cabec2,nomeprog,tamanho,GetMv("MV_COMP"))
			If Empty(cabec1) .And. Empty(cabec2)
				@ PROW()+1,T_Len[1,2]-1 PSAY REPLI('*',nAsterisco)
			Endif

			Linha:=PROW()+1 ; l_tag:=1
			AEVAL(R_Campos, b_lin)
			Linha++ ; l_tag:=3
			AEVAL(R_Campos, b_lin)
		Endif

		IncRegua()

		IF R_Funcoes # NIL
			IF ! EVAL(R_Funcoes[1])
				DBSKIP() ; --Linha ; LOOP
			ENDIF
		ENDIF

		Linha++ ; l_tag:=2
		AEVAL(R_Campos, b_lin)   ;    DBSKIP()

	Enddo

	IF R_Funcoes # NIL
		EVAL(R_Funcoes[2])
	ENDIF

	IF Linha != 80 .AND. lRodaPe
		Linha++
		roda(0,"",tamanho)
	Endif
	Set Device To Screen
	Set Filter To

	If aReturn[5] == 1
		Set Printer To
		dbCommit()
		Ourspool(wnrel)
	Endif
	MS_FLUSH()
	DbGoto(nRec)
Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFUNCOES   บAutor  ณMicrosiga           บ Data ณ  01/16/14   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function DipLoadSeg()
	Local cSeg := ""

	SU7->(dbSetOrder(4))
	If SU7->(dbSeek(xFilial("SU7")+AllTrim(RetCodUsr())))
		Do Case
			Case SU7->U7_POSTO == '01' //APOIO
			cSeg := "999993"
			Case SU7->U7_POSTO == '02' //TELEVENDAS
			cSeg := "999991"
			Case SU7->U7_POSTO == '03' //LICITACOES
			cSeg := "999992"
		End Case
	EndIf

Return cSeg
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDIPG029   บAutor  ณMicrosiga           บ Data ณ  10/07/14   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function VldNCMHosp(cNcmProd)
	Local cNCMHosp 	 := GetNewPar("ES_NCMHOSP","3005/40151100/40151900/901831/901832")
	Local nI 		 := 0
	Local nPos 		 := 0
	Local lRet 		 := .T.//.T. se nใo for prod. hospitalar (ES_NCMHOSP) ### .F. se for prod. hospitalar
	DEFAULT cNcmProd := ""

	While Len(cNCMHosp)>0
		nPos := At("/",cNCMHosp)
		If nPos <= 0
			nPos := Len(cNCMHosp)+1
		EndIf

		cNCMAux := SubStr(cNCMHosp,1,nPos-1)
		If Left(cNcmProd,Len(cNCMAux))==cNCMAux
			lRet := .F.
			Exit
		EndIf

		If (Len(cNCMHosp)-nPos)>0
			cNCMHosp := Right(cNCMHosp,Len(cNCMHosp)-nPos)
		Else
			Exit
		EndIf
	EndDo

Return lRet

/*----------------------------------------------------------------------------------
REGINALDO BORGES 21/11/2014
Fun็ใo........: ValCnpj()
Objetivo......: Restringir a inclusใo e altera็ใo de cliente com CNPJ/CPF existente
no cadastro, exceto para os que jแ existem duplicidade.
Considera็oes.: Fun็ใo chamada no X3_VLDUSER.
------------------------------------------------------------------------------------*/

User Function ValCnpj(cCnpjCpf)

	Local aArea := GetArea()
	Local nRec := SA1->(Recno())

	If SA1->(dbSetOrder(3), dbSeek(xFilial("SA1")+cCnpjCPF))
		MsgAlert("Aten็ใo, CNPJ/CPF Jแ Cadastrado!","Aten็ใo!")
		RestArea(aArea)
		SA1->(dbGoTo(nRec))
		Return .F.
	Endif
	RestArea(aArea)
	SA1->(dbGoTo(nRec))

Return .T.

/*----------------------------------------------------------------------------------
REGINALDO BORGES 23/01/2015
Fun็ใo........:  C6PrCust()
Objetivo......: Preencher o campo do valor unitแrio C6_PRCVEN, com o ultimo preco
de compras para os pedidos tipo B e os fornecedores especํficado.
Considera็oes.: Fun็ใo chamada no X3_VLDUSER.
------------------------------------------------------------------------------------*/

User Function C6PrcCust(cFornec,nPrcVen)
	Local nPrcUni   := nPrcVen
	Local _cProd    := ""
	Local cUtiForHQ := GetNewPar("ES_FORBEHQ","")
	Local nPosProd  := aScan(aHeader,{|x| AllTrim(x[2]) == 'C6_PRODUTO'})

	If cEmpAnt == '04'
		If M->C5_TIPO == 'B' .And. cFornec $ cUtiForHQ
			If  SUBSTR(M->C6_PRODUTO,1,1) == "8"
				_cProd  := "2"+SUBSTR(M->C6_PRODUTO,2,6)
				nPrcUni := Posicione("SB1",1,xFilial("SB1")+_cProd,"B1_UPRC")
			Else
				nPrcUni := Posicione("SB1",1,xFilial("SB1")+M->C6_PRODUTO,"B1_UPRC")
			EndIf
		endif
	EndIf

	If cEmpAnt == "01" .And. .F. //Regra Retirada em 11/11/2016
		If cFornec$GetNewPar("ES_CLICOLE","018801") .And. aCols[n,nPosProd]==SB1->B1_COD
			nPrcUni := Round(SB1->B1_PRV1-(SB1->B1_PRV1*(u_DipRetSZ1("999999","E")/100)),4)
		EndIf
	EndIf

Return(nPrcUni)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFUNCOES   บAutor  ณMicrosiga           บ Data ณ  03/13/15   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function XULTPRC()
	Local aAreaSB1 := SB1->(GetArea())
	Local nValAux  := 0
	Local cCodPro  := SB1->B1_COD

	If cEmpAnt == "01"
		If 	SB1->B1_PRVSUPE<SB1->B1_PRVMINI	 .And. SB1->B1_PRVSUPE > 0
			nValAux := SB1->B1_PRVSUPE
		Else
			nValAux := SB1->B1_PRVMINI
		EndIf

		If nValAux > 0
			SB1->(dbSetOrder(1))
			If SB1->(dbSeek(IIf(cFilAnt=="01","04","01")+cCodPro))
				SB1->(RecLock("SB1",.F.))
				SB1->B1_XULTPRC := nValAux
				SB1->(MsUnlock())
			EndIf
			If SB1->(dbSeek(xFilial("SB1")+cCodPro))
				SB1->(RecLock("SB1",.F.))
				SB1->B1_XULTPRC := nValAux
				SB1->(MsUnlock())
			EndIf
		EndIf
	EndIf
	RestArea(aAreaSB1)
	Return

	*----------------------------------------------*
User Function SalEstHQ(_cProduto,lConsolid)
	//RBorges - 10/04/15 - Verifica se existe saldo Poder de Terceiro
	//                     Esteriliza็ใo HQ
	*----------------------------------------------*
	Local _aArea	  := GetArea()
	Local _SdPoder3I  := 0
	Local cQRY        := ""
	Local cFORBEHQ    := GetNewPar("ES_FORBEHQ","")
	DEFAULT _cProduto := ""
	DEFAULT lConsolid := .F.

	//ESTOQUE EM PODE DE TERCEIRO (CBE e QUALITY)
	cQRY1 := "SELECT "
	cQRY1 += " SUM(D2_QUANT) AS SALDO "
	cQRY1 += " FROM "+RetSQLName("SF2")+" SF2, "+RetSQLName("SD2")+" SD2 "
	cQRY1 += " WHERE "
	If lConsolid
		cQRY1 += "	 SF2.F2_FILIAL   IN('01','02') "
	Else
		cQRY1 += "	 SF2.F2_FILIAL   = '"+ xFilial("SF2")+"' "
	EndIf
	cQRY1 += " AND   SD2.D2_FILIAL   = SF2.F2_FILIAL "
	cQRY1 += " AND   SF2.F2_CLIENTE  IN ('" + AllTrim(cFORBEHQ) + "') "
	cQRY1 += " AND   SF2.F2_TIPO     = 'B' "
	cQRY1 += " AND   SF2.F2_XIMPHQ  <> 'S' "
	cQRY1 += " AND   SF2.F2_DOC     = SD2.D2_DOC     "
	cQRY1 += " AND   SF2.F2_SERIE   = SD2.D2_SERIE   "
	cQRY1 += " AND   SF2.F2_CLIENTE = SD2.D2_FORNEC  "
	cQRY1 += " AND   SF2.F2_LOJA    = SD2.D2_LOJA    "
	cQRY1 += " AND   SD2.D2_COD     = '"+_cProduto+"'"
	cQry1 += " AND   SF2.D_E_L_E_T_ = ''             "
	cQry1 += " AND   SD2.D_E_L_E_T_ = ''             "

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
	TcQuery cQRY1 NEW ALIAS "cQRY1"         // ABRE UMA WORKAREA COM O RESULTADO DA QUERY

	DbSelectArea("cQRY1")
	cQRY1->(dbGotop())
	_SdPoder3I := cQRY1->SALDO
	DBCLOSEAREA("cQRY1")

	RestArea(_aArea)

Return(_SdPoder3I)

/*-----------------------------------------------------------------------------------
REGINALDO BORGES 26/05/2015
Fun็ใo........:  VLDD3TM()
Objetivo......: No internos modelo2 permitir apenas entrada manual, liberando somente
TM abaixo de 500 - Regra exclusiva para a HQ.
Considera็oes.: Fun็ใo chamada no X3_VLDUSER.
-------------------------------------------------------------------------------------*/

User Function VLDD3TM()

	Local lRet      := .T.
	Local _cUsuario := u_DipUsr()
	Local _UserTm   := Upper(AllTrim(GetNewPar("ES_USERTM","RBORGES/MCANUTO/DDOMINGOS")))

	If Upper(FunName())=="UMATA241"
		If cEmpAnt == '04'
			If Type("cTm")<>"U" .And. cTm >= '500'
				If ! AllTrim(Upper(_cUsuario)) $ _UserTm
					lRet := .F.
					MsgInfo("Voc๊ nใo tem autoriza็ใo para esse Tipo de Movimento, falar com a TI!")
				EndIf
			EndIf
		EndIf
	EndIf

Return lRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuncao    ณDipFIniPC ณ Autor ณ DIPROMED              ณ Data ณ16/06/2015ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescricao ณ Inicializa as funcoes Fiscais com o Pedido de Compras      ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณSintaxe   ณ DipFIniPC(ExpC1,ExpC2)                                     ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณ ExpC1 := Numero do Pedido                                  ณฑฑ
ฑฑณ          ณ ExpC2 := Item do Pedido                                    ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ MATR110,MATR120,Fluxo de Caixa                             ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function DipFIniPC(cPedido,cItem,cSequen,cFiltro)
	Local aArea		:= GetArea()
	Local aAreaSC7	:= SC7->(GetArea())
	Local cValid		:= ""
	Local nPosRef		:= 0
	Local nItem		:= 0
	Local cItemDe		:= IIf(cItem==Nil,'',cItem)
	Local cItemAte	:= IIf(cItem==Nil,Repl('Z',Len(SC7->C7_ITEM)),cItem)
	Local cRefCols	:= ''

	DEFAULT cSequen	:= ""
	DEFAULT cFiltro	:= ""

	dbSelectArea("SC7")
	dbSetOrder(1)
	If dbSeek(xFilial("SC7")+cPedido+cItemDe+Alltrim(cSequen))
		MaFisEnd()
		MaFisIni(SC7->C7_FORNECE,SC7->C7_LOJA,"F","N","R",{})
		While !Eof() .AND. SC7->C7_FILIAL+SC7->C7_NUM == xFilial("SC7")+cPedido .AND. ;
		SC7->C7_ITEM <= cItemAte .AND. (Empty(cSequen) .OR. cSequen == SC7->C7_SEQUEN)

			// Nao processar os Impostos se o item possuir residuo eliminado
			If &cFiltro
				dbSelectArea('SC7')
				dbSkip()
				Loop
			EndIf

			// Inicia a Carga do item nas funcoes MATXFIS
			nItem++
			MaFisIniLoad(nItem)
			dbSelectArea("SX3")
			dbSetOrder(1)
			dbSeek('SC7')
			While !EOF() .AND. (X3_ARQUIVO == 'SC7') .and. SX3->X3_CONTEXT <> 'V'
				cValid	:= StrTran(UPPER(SX3->X3_VALID)," ","")
				cValid	:= StrTran(cValid,"'",'"')
				If "MAFISREF" $ cValid
					nPosRef  := AT('MAFISREF("',cValid) + 10
					cRefCols := Substr(cValid,nPosRef,AT('","MT120",',cValid)-nPosRef )
					// Carrega os valores direto do SC7.
					MaFisLoad(cRefCols,&("SC7->"+ SX3->X3_CAMPO),nItem)
				EndIf
				dbSkip()
			End
			MaFisEndLoad(nItem,2)
			dbSelectArea('SC7')
			dbSkip()
		End
	EndIf

	RestArea(aAreaSC7)
	RestArea(aArea)

Return .T.
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFUNCOES   บAutor  ณMicrosiga           บ Data ณ  07/06/15   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function DipVldCx()
	Local lRet  := .T.

	If SDA->DA_LOCAL = "01"
		If !u_Dip071Vld(SDA->DA_PRODUTO,M->DB_QUANT,.T.)
			lRet := U_Senha("END")
		EndIf
	EndIf

	Return lRet

	/*
	ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
	ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
	ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
	ฑฑบPrograma  VldCliSuc() บAutor ณReginaldo Borges    บ Data ณ 04/08/2015  บฑฑ
	ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
	ฑฑบDesc.     ณ Programa chamado da validacao Codigo do cliente, para ava- บฑฑ
	ฑฑบ          ณ liar se o cliente fatura pela filial corrente.             บฑฑ
	ฑฑบ          ณ                                                            บฑฑ
	ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
	ฑฑบUso       ณ Especifico SAC- Dipromed                                   บฑฑ
	ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
	ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
	฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
	*/
	#INCLUDE "PROTHEUS.CH"
	#INCLUDE "TOPCONN.CH"

User Function VldCliSuc()

	Local aArea    := GetArea()
	Local cCliente := SU5->U5_CLIENTE
	Local cLojaCli := SU5->U5_LOJA
	Local lRet     := .T.

	If Inclui
		//---------------------------------------------------------------------------
		SA1->( DbSetOrder(1))
		//---------------------------------------------------------------------------
		If SA1->( DbSeek(xFilial('SA1') + cCliente + cLojaCli))
			If cEmpAnt+cFilAnt == '0101'
				If	(SA1->(LEFT(A1_CNAE,2)='84'.OR.'FEDER'$A1_DIPDCNJ.OR.'ESTAD'$A1_DIPDCNJ.OR.'MUNIC'$A1_DIPDCNJ.OR.LEFT(A1_CNAE,6)='8610-1'.OR.(('HOSPITAL'$A1_DESCNES.OR.'PRONTO SOCORRO'$A1_DESCNES).AND.('ESP'$A1_DESCNES.OR.'GER'$A1_DESCNES)) .OR.SA1->A1_EE198="S" .OR.;
				LEFT(A1_CNAE,2)$'72/75/85/86/87/88' .OR. LEFT(A1_CNAE,3)$'943/652/655' .OR. LEFT(A1_CNAE,6)='8640-2' .OR. u_DipVldZZX(A1_CGC)))
					MsgInfo("Cliente fatura pela Filial CD.","ATENCAO!")
					lRet := .F.
				EndIf
			ElseIf cEmpAnt+cFilAnt == '0104'
				If	!(SA1->(LEFT(A1_CNAE,2)='84'.OR.'FEDER'$A1_DIPDCNJ.OR.'ESTAD'$A1_DIPDCNJ.OR.'MUNIC'$A1_DIPDCNJ.OR.LEFT(A1_CNAE,6)='8610-1'.OR.(('HOSPITAL'$A1_DESCNES.OR.'PRONTO SOCORRO'$A1_DESCNES).AND.('ESP'$A1_DESCNES.OR.'GER'$A1_DESCNES)) .OR. A1_EE198="S" .OR.;
				LEFT(A1_CNAE,2)$'72/75/85/86/87/88' .OR. LEFT(A1_CNAE,3)$'943/652/655' .OR. LEFT(A1_CNAE,6)='8640-2' .OR. u_DipVldZZX(A1_CGC)))
					MsgInfo("Cliente fatura pela Filial MTZ.","ATENCAO!")
					lRet := .F.
				EndIf
			EndIf

		Else

			MsgInfo('Cliente nใo cadastrado','Aten็ใo!')
			lRet := .F.

		EndIf
	EndIf

	RestArea(aArea)
Return(lRet)

/*-----------------------------------------------------------------------------------
REGINALDO BORGES 14/08/2015
Fun็ใo........:  VLDSUC()
Objetivo......: Possibilitar a altera็ใo do campo UC_STATUS apenas pelo usuแrios que
estejam contidos no parโmetro.
Considera็oes.: Fun็ใo chamada no X3_WHEN.
-------------------------------------------------------------------------------------*/

User Function VLDSUC()
	Local _lRet     := .T.
	Local _cUsuario := u_DipUsr()
	Local _UserSUC  := Upper(AllTrim(GetNewPar("ES_SAC_SC","RBORGES/RBEAZIN/DDOMINGOS/MCANUTO")))

	If Upper(FunName())=="TMKA271"
		If INCLUI
			If ! AllTrim(Upper(_cUsuario)) $ _UserSUC
				_lRet := .F.
			EndIf
		EndIf
	EndIf

Return _lRet

/*-----------------------------------------------------------------------------------
REGINALDO BORGES 27/04/2016
Fun็ใo........:  VLDRET()
Objetivo......: Possibilitar a altera็ใo dos campos de retorno de atendimento
apenas pelo usuแrios que estejam contidos no parโmetro.
Considera็oes.: Fun็ใo chamada no X3_WHEN.
-------------------------------------------------------------------------------------*/

User Function VLDRET()
	Local _lRet     := .T.
	Local _cUsuario := u_DipUsr()
	Local _UserRet  := Upper(AllTrim(GetNewPar("ES_SAC_SC","RBORGES/RBEAZIN/DDOMINGOS/MCANUTO")))

	If Upper(FunName())=="TMKA271"
		If ! AllTrim(Upper(_cUsuario)) $ _UserRet
			_lRet := .F.
		EndIf
	EndIf

Return _lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFUNCOES   บAutor  ณMicrosiga           บ Data ณ  09/18/15   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function DipAteReg(cTransp,cCodCEP)
	Local cSQL 		:= ""
	Local lRet		:= .F.
	DEFAULT cTransp := ""
	DEFAULT cCodCEP := ""

	cSQL := "SELECT "
	cSQL += "	ZV_TRANSP "
	cSQL += " 	FROM "
	cSQL += 		RetSQLName("SZV")
	cSQL += " 		WHERE "
	cSQL += "   		ZV_FILIAL  = '" + xFilial("SZV")	+ "' AND "
	cSQL += "   		ZV_TRANSP  = '" + cTransp			+ "' AND "
	cSQL += "			ZV_CEPINI <= '" + AllTrim(cCodCEP) 	+ "' AND "
	cSQL += "   		ZV_CEPFIM >= '" + AllTrim(cCodCEP) 	+ "' AND "
	cSQL += 			RetSQLName("SZV")+".D_E_L_E_T_ = ' ' "

	cSQL := ChangeQuery(cSQL)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),"QRYSZV",.T.,.T.)

	lRet := !QRYSZV->(Eof())
	QRYSZV->(dbCloseArea())

Return lRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFUNCOES   บAutor  ณMicrosiga           บ Data ณ  09/21/15   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function VldCifRev(cPedido,cAlias,lVldPerc)
	Local aArea 	:= GetArea()
	Local lRet 		:= .F.
	DEFAULT cPedido := ""
	DEFAULT cAlias  := "SC5"
	DEFAULT lVldPerc:= .F.

	SA1->(dbSetOrder(1))
	If SA1->(dbSeek(xFilial("SA1")+&(cAlias+"->C5_CLIENTE"))) .And. cEmpAnt $ "04"
		If &(cAlias+"->C5_TPFRETE") == "C" .And. SA1->A1_TIPO = "R" .And. !&(cAlias+"->C5_CLIENTE")$GetNewPar("ES_CCIFREV","") 
			Return lRet
		ElseIf &(cAlias+"->C5_TPFRETE") == "C" .And. SA1->A1_TIPO = "R" .And. !&(cAlias+"->C5_CLIENTE")$GetNewPar("ES_CIFREV2","")  	// Novos parametros 2 e 3 para acessar mais clientes
			Return lRet
		ElseIf &(cAlias+"->C5_TPFRETE") == "C" .And. SA1->A1_TIPO = "R" .And. !&(cAlias+"->C5_CLIENTE")$GetNewPar("ES_CIFREV3","")  	// Blandino 23/03/21
			Return lRet
		Else
			lRet := .T.
			Return lRet
		EndIf
	EndIf

	If cEmpAnt $ "01"
		If (&(cAlias+"->C5_TPFRETE") == "C" .Or. lVldPerc)  .And.;
		!("SAO PAULO"$&(cAlias+"->C5_DESTFRE")) .And.;
		(Left(&(cAlias+"->C5_CEPE"),1)<>"0" .Or. u_DipIntSP(&(cAlias+"->C5_MUNE"))).And.;
		Alltrim(Posicione("SU7",1,xFilial("SU7")+&(cAlias+"->C5_OPERADO"),"U7_POSTO"))=="02"

			SA1->(dbSetOrder(1))
			If SA1->(dbSeek(xFilial("SA1")+&(cAlias+"->C5_CLIENTE")))
				If  (SA1->A1_TIPO = "F" .Or.;   							   				//Consumidor Final
				(Empty(&(cAlias+"->C5_TRANSP")) .And. lVldPerc) .Or.;     				//Transportadora vazia e eh regra de percentual de frete
				(SA1->A1_TIPO = "R" .And. &(cAlias+"->C5_TRANSP")=='100000') .Or.; 	// Revendedore e transporadora EMOVERE
				(SA1->A1_TIPO = "R" .And. &(cAlias+"->C5_TRANSP")$'000905/123455' .And. u_DipPerCIF(&(cAlias+"->C5_MUNE"))) .Or.; // Revendedor, Transportadora Jamef, Emovere nใo atende a regiใo
				&(cAlias+"->C5_CLIENTE")$GetNewPar("ES_CCIFREV","009907/014595/003572/018558/008320/016678/018221/013566/015573") .Or.; 	//Cliente autorizado a enviar por CIF
				&(cAlias+"->C5_CLIENTE")$GetNewPar("ES_CIFREV2","009907/014595/003572/018558/008320/016678/018221/013566/015573") .Or.; 	//Criado novos parametros 2 e 3 para maior numero de clientes 
				&(cAlias+"->C5_CLIENTE")$GetNewPar("ES_CIFREV3","009907/014595/003572/018558/008320/016678/018221/013566/015573"))  		//Blandino 24/03/21

					If lVldPerc .And. SA1->A1_XCOBCIF <> "2"
						lRet := .T.
					ElseIf !lVldPerc
						lRet := .T.
					EndIf
				EndIf
			EndIf
		ElseIf !lVldPerc
			lRet := .T.
		EndIf
	ElseIf !lVldPerc
		lRet := .T.
	EndIf

	RestArea(aArea)

	Return lRet

	/*********************************************************
	Programa: LimpAcols()
	Descri็ใo: Essa fun็ใo tem como objetivo limpar os campos
	produto, descricao, valor unitario, quantidade e
	data de validade, os quais sใo carregados com o consulta
	padrao da nota fiscal.marketing.
	Autor: Reginaldo Borges
	Data 22/10/2015
	Uso: SAC - Servico de Atendimento ao Cliente
	/*********************************************************/

	*---------------------------------------------------------*
User Function LimpAcols()
	*---------------------------------------------------------*
	Local cMsg      := ''
	Local cMsg2     := ''
	Local _nI       := 0
	Local _cUsrSAC1 :=  GetNewPar("ES_SAC_SC" ,"RBORGES")

	U_DIPPROC(ProcName(0),U_DipUsr()) // Gravando o nome do Programa no SZU

	cMsg := 'Confirma a limpeza das informa็๕es da'+CHR(13)+CHR(10)+;
	'nota fiscal com exce็ใo da nota, cliente e emissใo?'

	cMsg2:= 'Permitido a limpeza dos campos da'+CHR(13)+CHR(10)+;
	'nota fiscal somente na INCLUSรO!'

	If INCLUI .Or. UPPER(U_DipUsr()) $ _cUsrSAC1

		If MsgYesNo(cMsg,"ATENวรO!")
			For _nI := 1 To Len(Acols)

				aCols[_nI,5] := '' // Produto
				aCols[_nI,6] := '' // Descri็ใo
				aCols[_nI,7] := 0  // Valor unitแrio
				aCols[_nI,8] := 0  // Quantidade
				aCols[_nI,9] := '' // Lote
				aCols[_nI,10]:= CTOD('  /  /  ') // Validade

			Next
		Else
			MsgInfo('Limpeza dos campos cancelada!','ATENวรO!')
		EndIf
	Else

		MsgInfo(cMsg2,'ATENวรO!')

	EndIf

	Return

	/*-----------------------------------------------------------------------------+
	|Autor: REGINALDO BORGES                                      Data: 29/10/2015 |
	+------------------------------------------------------------------------------+
	|Ponto de Entrada: RODACTB()                                                   |
	+------------------------------------------------------------------------------+
	|Objetivo........: Permitir que a contabiliza็ใo off line seja rodada conforme |
	|				  o horario informado no parโmtro.                             |
	+-----------------------------------------------------------------------------*/
	#INCLUDE "RWMAKE.CH"
	#INCLUDE "PROTHEUS.CH"

User Function RODACTB()

	Local   cHorExc := AllTrim(GetNewPar("ES_CTBVAUT","16:00|19:00"))
	Local   cHorMin := SubStr(cHorExc,2,At("|",cHorExc)-2)
	Local   cHorMax := SubStr(cHorExc,At("|",cHorExc)+1,Len(cHorExc)-8)
	Local   cHorAtu := Left(Time(),5)
	Local   cHorMsg := "das "+StrTran(cHorExc,"|"," เs ")
	Local   nOpcao  := 0
	Local   oDlg
	Local   oRadio
	Private oFont24 := TFont():New("Arial",9,24,.T.,.T.,5,.T.,5,.T.,.F.)
	Private aRadio  :={}
	Private nRadio  := 0

	If cHorAtu >= cHorMin .Or. cHorAtu <= cHorMax

		aRadio:={"Financeiro","Faturamento","Compras"}

		@ 000,000 To 150,250 Dialog oDlg Title OemToAnsi("Contabiliza็ใo Off Line")
		@ 005,020 Say "Escolha o M๓dulo!" font oFont24  COLOR CLR_BLUE Pixel
		@ 020,020 RADIO oRadio VAR nRadio ITEMS aRadio[1],aRadio[2],aRadio[3] SIZE 65,8
		@ 060,050 BmpButton Type 1 Action (If(CTBValid('OK'),(nOpcao:=1,Close(oDlg)),nOpcao:=0))
		@ 060,090 BmpButton Type 2 Action (nOpcao:=0,Close(oDlg))

		Activate Dialog oDlg Centered

		If nOpcao==1
			If     nRadio == 1
				SetFunName("FINA370")
				FINA370() //Financeiro
			ElseIf nRadio == 2
				SetFunName("CTBANFS")
				CTBANFS() //Faturamento
			ElseIf nRadio == 3
				SetFunName("CTBANFE")
				CTBANFE() //Compras
			EndIf
		EndIf

	Else
		Aviso("ES_CTBVAUT","Nใo ้ permitido rodar a contabiliza็ใo neste horแrio !!!"+CHR(13)+CHR(10)+;
		"Caso seja necessแrio falar com a TI",{"Ok"},1)
	EndIf

Return

Static Function CTBValid(cCampo)

	Local lRetorno:=.T.

	If cCampo == 'OK' .and. (nRadio < 1 .or. nRadio > 3)
		Aviso('ATENวรO!','Nenhum m๓dulo selecionado!',{'OK'})
		lRetorno := .F.
	EndIf

Return lRetorno
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณMBROWTMP  บAutor  ณMicrosiga           บ Data ณ  12/21/15   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function VldLotPro()
	Local lRet 	  := .F.
	Local nPosLot := aScan(aHeader, {|x|Alltrim(x[2])=="C6_LOTECTL"})
	Local nPosTes := aScan(aHeader, {|x|Alltrim(x[2])=="C6_TES"})
	Local nPosLoc := aScan(aHeader, {|x|Alltrim(x[2])=="C6_LOCAL"})

	If aCols[n,nPosLoc]<>'01' .Or. Empty(aCols[n,nPosLot]) .Or. Posicione("SF4",1,xFilial("SF4")+AllTrim(aCols[n,nPosTes]),"F4_ESTOQUE")<>"S"
		lRet := .T.
	EndIf

Return lRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFUNCOES   บAutor  ณMicrosiga           บ Data ณ  01/04/16   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function VldTesCF(cTes,cProduto)
	Local aAreaSB1 := SB1->(GetArea())
	Local nPosPro  := 0
	Local cDipNCM  := ""
	Local cGrpTrib := SB1->B1_GRTRIB
	Local lST	   := .F.
	Local aDadosCfo:= {}
	DEFAULT cTes   := ""
	DEFAULT cProduto := ""
	If Empty(cProduto)
		cProduto := aCols[n,aScan(aHeader,{|x| x[2]=="C6_PRODUTO"})]
	EndIf
	SB1->(dbSetOrder(1))
	If SB1->(dbSeek(xFilial("SB1")+cProduto))
 													  //"502/505/506/513/526/543/548/556/565/587/620/632/681/682/686/706/714/765/782/795/822/836/881/882"//CD
		If cEmpAnt == "01" .and. !cTes$"502/505/506/513/521/543/548/556/565/583/587/607/617/620/630/631/632/700/702/706/714/765/782/784/795/822/824/830/831/836/841/881/882"
			//alterado por Tiago Stocco - Obify - 12/07/2021
			cDipNCM := GetNewPar("ES_CST06_1","")+"/"+GetNewPar("ES_CST06_2","")+"/"+GetNewPar("ES_CST06_3","")
			
			If SB1->B1_PICM>0 .And. SA1->A1_EST<>"SP" .And. SA1->A1_TIPO=="F" .And. cTes=="501"
				If Dtos(dDatabase) >= '20220401' .and. Dtos(ddatabase) <= '20220404' .and. SA1->A1_EST $ "AM/GO/MG/PE"
					If !ALlTrim(SB1->B1_POSIPI)$cDipNCM //If SA1->A1_CONTRIB == "2"	
						cTes := "870"
					Else
						cTes := "970"//cTes := "754"
					EndIf					
				else
					If !ALlTrim(SB1->B1_POSIPI)$cDipNCM //If SA1->A1_CONTRIB == "2"	
						cTes := "752"
					Else
						cTes := "852"//cTes := "754"
					EndIf
				ENDIF
			EndIf

			If SB1->B1_PICM>0 .And. SA1->A1_EST=="SP" .And. SA1->A1_TIPO=="F" .and. !cTes$"526/527/528/589/509/569/691/633/653/651/728/750/769/779/891"
				If !ALlTrim(SB1->B1_POSIPI)$cDipNCM //If SA1->A1_CONTRIB == "2"	
					cTes := "501"
				Else
					cTes := "703"//cTes := "754"
				EndIf
			EndIf
			If  SB1->B1_TS == "773" .and. !cTes$"526/527/528/589/509/569/633/653/651/691/728/769/891"
				If SA1->A1_EST<>"SP" .and. SA1->A1_TIPO=="F"
					cTes := "774"
				EndIf
			EndIf

			//(SB1->B1_ORIGEM$"0,4,5" .And. AllTrim(SB1->B1_POSIPI)$cDipNCM .And. SA1->A1_PESSOA=="J" .And. SA1->A1_TIPO=="F") .Or.;
            //(cEmpAnt+cFilAnt=='0104' .And. SB1->B1_ORIGEM$"0,4,5" .And. AllTrim(SB1->B1_POSIPI)$cDipNCM) .Or.;
			If ALlTrim(SB1->B1_POSIPI)$cDipNCM  .Or. ;
			   Left(SB1->B1_POSIPI,6)=="902110" .Or. ;
			   Left(SB1->B1_POSIPI,5)=="90213"   .Or. ;
			   Left(SB1->B1_POSIPI,4)=="8713"

				Do Case
					Case cTes == "501";	cTes := "703"
					Case cTes == "513";	cTes := "713"
					Case cTes == "520";	cTes := "720"
					Case cTes == "525";	cTes := "725"
					Case cTes == "528";	cTes := "728"
					Case cTes == "530";	cTes := "730"
					Case cTes == "531";	cTes := "731"
					Case cTes == "532"; cTes := "732"
					Case cTes == "533";	cTes := "733"
					Case cTes == "538";	cTes := "738"
					Case cTes == "558";	cTes := "758"
					Case cTes == "565";	cTes := "765"
					Case cTes == "569";	cTes := "769"
					Case cTes == "575";	cTes := "775"
					Case cTes == "583";	cTes := "783"
					Case cTes == "594";	cTes := "794"
					Case cTes == "598";	cTes := "798"
					Case cTes == "624";	cTes := "824"
					Case cTes == "625";	cTes := "825"
					Case cTes == "636";	cTes := "836"
					Case cTes == "638";	cTes := "838"
					Case cTes == "641";	cTes := "841"
					Case cTes == "644";	cTes := "844"
					Case cTes == "655";	cTes := "855"
					Case cTes == "656";	cTes := "856"
					Case cTes == "671";	cTes := "871"
					Case cTes == "672";	cTes := "872"
					Case cTes == "681";	cTes := "881"
					Case cTes == "682";	cTes := "882"
					Case cTes == "683";	cTes := "883"
					Case cTes == "686";	cTes := "886"
					Case cTes == "690";	cTes := "890"
					Case cTes == "691";	cTes := "891"
					Case cTes == "752";	cTes := "852"
					Case cTes == "754";	cTes := "854"
				EndCase
			EndIf
			/* 
			-- Adicionado regras para tratar o ST via Exce็ใo Fiscal e Grupo Tributario no B1
			-- Todas as Exce็๕es Fiscais novas de ST contem 6 digitos
			-- Essa regra deverแ ser removida com a implanta็ใo do TES Inteligente
			-- Tiago Stocco - Obify - 07/06/2021
			*/
			If !Empty(cGrpTrib) .and. Len(Alltrim(cGrpTrib)) == 6 .and. !cTes$"528/728"
				DbSelectArea("SF7")
				DbSetOrder(1)
				DbSeek(xFilial("SF7")+cGrpTrib)
				While SF7->F7_FILIAL+SF7->F7_GRTRIB==XFILIAL("SF7")+cGrpTrib
					If SF7->F7_EST == SA1->A1_EST .and. SF7->F7_GRPCLI == SA1->A1_GRPTRIB
						lST := .T.
					endif
					SF7->(dbSkip())
				End
			  	If SA1->A1_EST=="SP" .and. Alltrim(SA1->A1_COD)<>"000804"
					Do Case
						Case cTes == "501";	cTes := "625"
						Case cTes == "531";	cTes := "626"
						Case cTes == "532"; cTes := "627"
						Case cTes == "505";	cTes := "630"
						Case cTes == "506";	cTes := "631"
						Case cTes == "526";	cTes := "632"
						Case cTes == "527";	cTes := "633"
						Case cTes == "589";	cTes := "653"
						Case cTes == "509";	cTes := "651"
					EndCase
					If ALlTrim(SB1->B1_POSIPI)$cDipNCM .and. !cTES $ "505/506/526/527/528/589/509/569/630/631/632/633/653/651/691/728/750/769/891"
						cTes := "825" //PIS / COF Zero
					EndIf
				ElseIf SA1->A1_EST=="SP" .and. Alltrim(SA1->A1_COD)=="000804"
					If ALlTrim(SB1->B1_POSIPI)$cDipNCM
						cTes := "883" //PIS / COF Zero
					Else
						cTes := "683" //PIS / COF NORMAL
					EndIf
				Else
					If lST //Outos ESTADOS 
						If ALlTrim(SB1->B1_POSIPI)$cDipNCM
							cTes := "805" //PIS / COF Zero
						Else
							cTes := "801" //PIS / COF NORMAL
						EndIf
					EndIf
				EndIf
			EndIf		
		EndIF
		If cEmpAnt == "01" .and. cFilAnt== "04"
			cDipNCM := GetNewPar("ES_CST06_1","")+"/"+GetNewPar("ES_CST06_2","")+"/"+GetNewPar("ES_CST06_3","")
			
			
			If cTes == "750"
				If AllTrim(SB1->B1_POSIPI)$cDipNCM
					cTes := "770"
				EndIf
			EndIf			
			
			If cTes == "528"
				If AllTrim(SB1->B1_POSIPI)$cDipNCM
					cTes := "728"
				EndIf
			EndIf			
			If cTes == "526" .and. SB1->B1_PICMRET <> 0
				cTes := "632"
			EndIf	

			If SB1->B1_PICMRET <> 0 .and. !cTes$"505/506/513/526/527/528/589/509/569/630/631/632/633/653/651/691/706/713/728/769/770/891"
				If SA1->A1_EST=="SP"
					If ALlTrim(SB1->B1_POSIPI)$cDipNCM
						cTes := "825" //PIS / COF Zero
					Else
						cTes := "625" //PIS / COF NORMAL
					EndIf
				EndIf
			EndIf
			/*
			-- FIM CUSTOMIZACAO PARA ST, REMOVER QDO ENTRAR TES INTELIGENTE
			*/
			
		ElseIf cEmpAnt == "04"
			If SB1->B1_PICM>0 .And. SA1->A1_EST<>"SP" .And. SA1->A1_TIPO=="F" .And. cTes$"503/506"
				//_______________________________________________________________
				//                                                               |
				// 771 - Venda Consumidor Final Nใo Contribuinte com ICMS        |
				// 772 - Venda Consumidor Final Nใo Contribuinte com ICMS e IPI  |
				// 773 - Venda Consumidor Final     Contribuinte com ICMS        |
				// 774 - Venda Consumidor Final     Contribuinte com ICMS e IPI  |
				//_______________________________________________________________|

				If SA1->A1_CONTRIB=="2"
					cTes := IIf(SB1->B1_IPI>0,"772","771")
				Else
					cTes := IIf(SB1->B1_IPI>0,"774","773")
				EndIf
			EndIf

			If SA1->A1_PESSOA=="J" .And. SA1->A1_TIPO=="F" .And.  .F.  //Left(SB1->B1_POSIPI,4)$"9018/3926"
				//Regra desativada em 20/09/2017 (e-mail da MACC)
				Do Case
					Case cTes == "502";	cTes := "702"
					Case cTes == "503"; cTes := "703"
					Case cTes == "504"; cTes := "704"
					Case cTes == "506"; cTes := "706"
					Case cTes == "514";	cTes := "714"
					Case cTes == "554";	cTes := "754"
					Case cTes == "688";	cTes := "788"
					Case cTes == "695";	cTes := "895"
					Case cTes == "761";	cTes := "861"
					Case cTes == "768";	cTes := "868"
					Case cTes == "771";	cTes := "871"
					Case cTes == "772";	cTes := "872"
					Case cTes == "773";	cTes := "873"
					Case cTes == "774";	cTes := "874"
					Case cTes == "795";	cTes := "995"
					Case cTes == "982";	cTes := "983"
				EndCase
			EndIf
		EndIf
	Else
		cTes := ""
	EndIf

	/* INICIO CUSTOMIZACAO MONOFASICO - CST 04
		-----------------------------------------------------------------------------
		| Adicionadas regras para realizar o gatilho do TES com CST Monofแsico,		|
		| conforme regra informada pelo departamento fiscal:						|
		|																			|
		|	MATRIZ: Vendas Internas (SP) c/ ST 	= 716								|
		|	MATRIZ: Vendas Internas (SP) s/ ST 	= 715								|
		|			Vendas Interestaduais 		= 717								|
		|																			|
		|	CD: 	Vendas Internas (SP) 		= 715								|
		|			Vendas Interestaduais 		= 771								|
		|																			|
		| Thais Reis - Obify - 24/04/2023											|
		-----------------------------------------------------------------------------
		*/
			
		If cEmpAnt == "01" .And. cFilAnt == "01" 
		cMonNCM := GetNewPar("ES_CST04_1","")
			
			If cTes == "501" .or. cTes == "625"
				If AllTrim(SB1->B1_POSIPI)$cMonNCM .And. SA1->A1_EST=="SP"
					cTes := "716"
				EndIf
			Endif


			If cTes =="501" .and. !Empty(cGrpTrib) .and. SA1->A1_EST <> "SP"
				DbSelectArea("SF7")
				DbSetOrder(1)
				DbSeek(xFilial("SF7")+cGrpTrib)
				While SF7->F7_FILIAL+SF7->F7_GRTRIB==XFILIAL("SF7")+cGrpTrib
					If SF7->F7_EST <> SA1->A1_EST 
						cTes := "715"
					EndIf
					SF7->(dbSkip())
				END
			EndIf

			If cTes =="501" .and. Empty(cGrpTrib) .and. SA1->A1_EST <> "SP"
				DbSelectArea("SF7")
				DbSetOrder(1)
				DbSeek(xFilial("SF7")+cGrpTrib)
				While SF7->F7_FILIAL+SF7->F7_GRTRIB==XFILIAL("SF7")+cGrpTrib
					If SF7->F7_EST <> SA1->A1_EST 
						cTes := "715"
					EndIf
					SF7->(dbSkip())
				END
			EndIf

			If cTes =="501" .or. cTes="801" .and. !Empty(cGrpTrib) .and. Len(Alltrim(cGrpTrib)) == 6 
				DbSelectArea("SF7")
				DbSetOrder(1)
				DbSeek(xFilial("SF7")+cGrpTrib)
				While SF7->F7_FILIAL+SF7->F7_GRTRIB==XFILIAL("SF7")+cGrpTrib
					If SF7->F7_EST == SA1->A1_EST .and. SF7->F7_GRPCLI == SA1->A1_GRPTRIB
						cTes := "717"
					EndIf
					SF7->(dbSkip())
				END
			EndIf

		Else
		
		If cEmpAnt == "01"  .And. cFilAnt == "04"
			cMonNCM := GetNewPar("ES_CST04_1","")
			
			
			If cTes == "501" .or. cTes == "752"
				If AllTrim(SB1->B1_POSIPI)$cMonNCM .And. SA1->A1_EST=="SP"
					cTes := "715"
				EndIf

				If AllTrim(SB1->B1_POSIPI)$cMonNCM .And. SA1->A1_EST<>"SP"
					cTes := "771"
				EndIf

			Endif
		
		Endif
	Endif
		/* FIM CUSTOMIZACAO MONOFASICO - CST 04 */

RestArea(aAreaSB1)
Return cTes



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDipICMSCF บAutor  ณMicrosiga           บ Data ณ  05/03/13   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Rotina para enviar CIC e EMAIL				              บฑฑ
ฑฑบ          ณ Aviso de guia de ICMS na venda para consumidor final       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function DipICMSCF(cPedido)
	Local aAreaSC5  := SC5->(GetArea())
	Local aAreaSA1  := SA1->(GetArea())
	Local cSQL 		:= ""
	Local cMsgCIC	:= ""
	Local aMsg		:= {}
	Local cEmail	:= GetNewPar("ES_DIPMACF","diego.domingos@dipromed.com.br;maximo.canuto@dipromed.com.br;sirlene.creatto@dipromed.com.br;edvan.matias@dipromed.com.br;expedicao@dipromed.com.br")
	Local cCICEnv	:= GetNewPar("ES_DIPCACF","DIEGO.DOMINGOS,MAXIMO.CANUTO,SIRLENE.CREATTO,EXPEDICAOCD,EDVAN.MATIAS")
	Local cFrom 	:= "protheus@dipromed.com.br"
	Local cAssunto  := EncodeUTF8("ATENวรO! PEDIDO TEM PRIORIDADE (GUIA DE ICMS PARA CONSUMIDOR FINAL)","cp1252")
	Local cTesDif	:= GetNewPar("ES_TICMSCF","752")

	cTesDif := "'"+StrTran(cTesDif,"/","','")+"'"

	SC5->(dbSetOrder(1))
	If SC5->(dbSeek(xFilial("SC5")+cPedido))
		SA1->(dbSetOrder(1))
		If SA1->(dbSeek(xFilial("SA1")+SC5->C5_CLIENTE+SC5->C5_LOJACLI)) .And. SA1->A1_TIPO=="F" .And. SA1->A1_CONTRIB=="2" .And. !(SC5->C5_ESTE$GetNewPar("ES_ESTNGCF","BA/MG"))
			cSQL := " SELECT "
			cSQL += " 	C6_NUM "
			cSQL += " 	FROM "
			cSQL += 		RetSQLName("SC6")
			cSQL += " 		WHERE "
			cSQL += "   		C6_FILIAL = '"+xFilial("SC6")+"' AND " // JBS 09/11/2005
			cSQL += "   		C6_NUM 	  = '"+cPedido+"' AND " // JBS 09/11/2005
			cSQL += "   		C6_TES    IN ("+cTesDif+") AND "
			cSQL +=   			RetSQLName("SC6")+".D_E_L_E_T_ = ' ' "

			cSQL := ChangeQuery(cSQL)
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),"QRYSC6",.T.,.T.)

			If !QRYSC6->(Eof())
				aAdd(aMsg, {"EMPRESA"       ,+Capital(AllTrim(GetAdvFVal("SM0","M0_NOMECOM",cEmpAnt+cFilAnt,1,"")))})
				aAdd(aMsg, {"FILIAL"        ,+Capital(AllTrim(GetAdvFVal("SM0","M0_FILIAL" ,cEmpAnt+cFilAnt,1,"")))})
				aAdd(aMsg, {"PEDIDO"        ,""+SC5->C5_NUM+""})
				aAdd(aMsg, {"CLIENTE"       ,""+AllTrim(SA1->A1_COD)+" - "+AllTrim(SA1->A1_NREDUZ)+""})
				aAdd(aMsg, {"E-Mail"        ,""+Lower(Alltrim(SA1->A1_EMAIL))+""} )
				aAdd(aMsg, {"OPERADOR"      ,""+SC5->C5_OPERADO+"-"+Posicione("SU7",1,xFilial("SU7")+SC5->C5_OPERADO,"U7_NOME") })
				aAdd(aMsg, {"TRANSPORTADORA",""+SC5->C5_TRANSP+" - " + AllTrim(FDesc("SA4",SC5->C5_TRANSP,"SA4->A4_NREDUZ"))+" " })

				U_UEnvMail(cEmail,cAssunto,aMsg,"",cFrom,"DipICMSCF(Funcoes.prw)")

				cMsgCIC := "AVISO – PEDIDO DE VENDAS C/ PRIORIDADE – CONCLUIR EM 2H – GUIA DE ICMS (CONSUMIDOR FINAL)" +CHR(13)+CHR(10)+CHR(13)+CHR(10)
				cMsgCIC += aMsg[3][1]+":_____________" 	+aMsg[3][2] + CHR(13)+CHR(10)
				cMsgCIC += " EMPRESA:___________" 		+aMsg[1][2] + "/" + aMsg[2][2]+CHR(13)+CHR(10)
				cMsgCIC += aMsg[4][1]+":_____________" 	+aMsg[4][2] + CHR(13)+CHR(10)
				cMsgCIC += aMsg[6][1]+":__________" 	+aMsg[6][2] + CHR(13)+CHR(10)
				cMsgCIC += aMsg[7][1]+":___" 			+aMsg[7][2] + CHR(13)+CHR(10)

				U_DIPCIC(cMsgCIC,cCICEnv)
			EndIf

			QRYSC6->(dbCloseArea())
		EndIf
	EndIf

	RestArea(aAreaSA1)
	RestArea(aAreaSC5)
Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDipICMSCF บAutor  ณMicrosiga           บ Data ณ  05/03/13   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Rotina para enviar CIC e EMAIL				              บฑฑ
ฑฑบ          ณ Aviso de guia de ICMS na venda para consumidor final       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function DipICMSNF(cDoc,cSerie,cCliente,cLoja,cTransp,cPedido,cUFDest)
	Local aAreaSA1  := SA1->(GetArea())
	Local cSQL 		:= ""
	Local cMsgCIC	:= ""
	Local aMsg		:= {}
	Local cEmail	:= GetNewPar("ES_DIPMCCF","diego.domingos@dipromed.com.br;maximo.canuto@dipromed.com.br;sirlene.creatto@dipromed.com.br;edvan.matias@dipromed.com.br;expedicao@dipromed.com.br;notafiscal@dipromed.com.br;notafiscal2@dipromed.com.br")
	Local cCICEnv	:= GetNewPar("ES_DIPCCCF","DIEGO.DOMINGOS,MAXIMO.CANUTO,SIRLENE.CREATTO,EXPEDICAOCD,EDVAN.MATIAS,NOTAFISCAL,NOTAFISCAL2")
	Local cFrom 	:= "protheus@dipromed.com.br"
	Local cAssunto  := EncodeUTF8("ATENวรO! CONFIRMACAO - NF NรO PODE SAIR SEM GUIA (ICMS CONSUMIDOR FINAL)","cp1252")
	DEFAULT cDoc    := ""
	DEFAULT cSerie  := ""
	DEFAULT cCliente:= ""
	DEFAULT cLoja   := ""
	DEFAULT cTransp := ""
	DEFAULT cPedido := ""
	DEFAULT cUFDest := ""

	cSQL := " SELECT "
	cSQL += " 	SUM(CD2_VLTRIB) VLTRIB, SUM(CD2_VDDES) VLDEST, SUM(CD2_VFCP) FCP "
	cSQL += " 	FROM "
	cSQL +=  		RetSQLName("CD2")
	cSQL += " 		WHERE "
	cSQL += " 			CD2_FILIAL = '"+xFilial("CD2")+"' AND "
	cSQL += " 			CD2_TPMOV = 'S' AND "
	cSQL += " 			CD2_SERIE = '"+cSerie+"' AND "
	cSQL += " 			CD2_DOC = '"+cDoc+"' AND "
	cSQL += " 			CD2_IMP = 'CMP' AND "
	cSQL += " 			D_E_L_E_T_ = ' ' "

	cSQL := ChangeQuery(cSQL)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),"QRYCD2",.T.,.T.)

	If !QRYCD2->(Eof())
		SA1->(dbSetOrder(1))
		If SA1->(dbSeek(xFilial("SA1")+cCliente+cLoja))
			aAdd(aMsg, {"EMPRESA"       ,+Capital(AllTrim(GetAdvFVal("SM0","M0_NOMECOM",cEmpAnt+cFilAnt,1,"")))})
			aAdd(aMsg, {"FILIAL"        ,+Capital(AllTrim(GetAdvFVal("SM0","M0_FILIAL" ,cEmpAnt+cFilAnt,1,"")))})
			aAdd(aMsg, {"PEDIDO"        ,""+cPedido+""})
			aAdd(aMsg, {"NF/SERIE"      ,""+cDoc+"/"+cSerie+""})
			aAdd(aMsg, {"CLIENTE"       ,""+AllTrim(SA1->A1_COD)+" - "+AllTrim(SA1->A1_NREDUZ)+""})
			aAdd(aMsg, {"E-Mail"        ,""+Lower(Alltrim(SA1->A1_EMAIL))+""} )
			aAdd(aMsg, {"TRANSPORTADORA",""+cTransp+" - " + AllTrim(FDesc("SA4",cTransp,"SA4->A4_NREDUZ"))+" " })
			aAdd(aMsg, {"UF"		,""+cUFDest+" " })
			aAdd(aMsg, {"Vlr. FCP"		,""+Transform(QRYCD2->FCP,"@E 999,999.99")+" " })
			aAdd(aMsg, {"Vlr. destino (GUIA)",""+Transform(QRYCD2->VLDEST,"@E 999,999.99")+" " })
			aAdd(aMsg, {"Vlr. remetente",""+Transform(QRYCD2->VLTRIB,"@E 999,999.99")+" " })

			U_UEnvMail(cEmail,cAssunto,aMsg,"",cFrom,"DipICMSNF(Funcoes.prw)")

			cMsgCIC := "CONFIRMACAO - NF NรO PODE SAIR SEM GUIA (ICMS CONSUMIDOR FINAL)"+CHR(13)+CHR(10)+CHR(13)+CHR(10)
			cMsgCIC += aMsg[03][1]+":______________" 	+aMsg[03][2] + CHR(13)+CHR(10)
			cMsgCIC += aMsg[04][1]+":____________" 		+aMsg[04][2] + CHR(13)+CHR(10)
			cMsgCIC += " EMPRESA:___________"			+aMsg[01][2] + "/" + aMsg[2][2]+CHR(13)+CHR(10)
			cMsgCIC += aMsg[05][1]+":_____________"		+aMsg[05][2] + CHR(13)+CHR(10)
			cMsgCIC += aMsg[07][1]+":___" 				+aMsg[07][2] + CHR(13)+CHR(10)
			cMsgCIC += aMsg[08][1]+":__________________"+aMsg[08][2] + CHR(13)+CHR(10)
			cMsgCIC += aMsg[09][1]+":______________" 	+aMsg[09][2] + CHR(13)+CHR(10)
			cMsgCIC += aMsg[10][1]+":_____" 			+aMsg[10][2] + CHR(13)+CHR(10)
			cMsgCIC += aMsg[11][1]+":_________" 		+aMsg[11][2] + CHR(13)+CHR(10)

			U_DIPCIC(cMsgCIC,cCICEnv)
		EndIf
	EndIf
	QRYCD2->(dbCloseArea())

	RestArea(aAreaSA1)

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFUNCOES   บAutor  ณMicrosiga           บ Data ณ  01/13/16   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ  Acrescenta Percentual Cliente			                  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function DipAcrCli(nValor,cCliente,cLoja,cProduto,nPerCon)
	Local aAreaSA1 	 := SA1->(GetArea())
	Local aAreaSB1 	 := SB1->(GetArea())
	Local cSQL 		 := ""
	Local _cAliqICM  := ""
	Local aParamDifal:= {}
	Local nPos 	 := 0
	Local nPerDIF 	 := 0
	Local nICMInt 	 := 0
	Local nICMEnt 	 := 0
	Local nPerAux 	 := 0
	Local nFCP       := 0
	Local nValAux    := 0
	Local nDIFAL	 := 0
	DEFAULT nValor 	 := 0
	DEFAULT cCliente := ""
	DEFAULT cLoja 	 := ""
	DEFAULT cProduto := ""
	DEFAULT nPerCon  := 0

	SA1->(dbSetOrder(1))
	If SA1->(dbSeek(xFilial("SA1")+cCliente+cLoja))

		If GetNewPar("ES_NEWPDIF",.T.)
			If SA1->A1_TIPO=="F" .And. SA1->A1_ESTE<>"SP" .And. SA1->A1_CONTRIB=="2"
				SB1->(dbSetOrder(1))
				If SB1->(dbSeek(xFilial("SB1")+cProduto)) .And. SB1->B1_PICM>0

					_cAliqICM := GetNewPar("MV_ESTICM","")

					aParamDifal	:= &(SuperGetMV("MV_PPDIFAL", ,"{{2016,40,60},{2017,60,40},{2018,80,20},{2019,100,0}}"))

					If (nPos := aScan(aParamDifal,{|x| x[1]== Year(Date()) }) ) > 0
						nPerDIF:= aParamDifal[nPos,2]/100
					EndIf

					nICMInt := Val(Subs(_cAliqICM,AT(SA1->A1_ESTE,_cAliqICM)+2,2))

					If SB1->B1_ORIGEM$"1/2/3/8"
						nICMEnt := 4
					ElseIf SA1->A1_ESTE$"RJ/MG/PR/RS/SC"
						nICMEnt := 12
					Else
						nICMEnt := 7
					EndIf

					nFCP	:= GetAdvFVal("CFC","CFC_ALQFCP",xFilial("CFC")+"SP"+SA1->A1_ESTE,1)

					nFCP	:= ROUND ((nFCP / 100),4)

					nDIFAL	:= ROUND(((nICMInt-nICMEnt)/100),4)

					nFCP	:= nValor * nFCP

					nDIFAL	:= nValor * nDIFAL

					nValAux := nValor

					nValor	:= nValor + nFCP + nDIFAL

					nPerCon := (nValor*100/nValAux)-100

					//Retirado o DIFAL para RJ e MG e incluํdo um percentual fixo (3% para RJ e 2% para MG) - Solicitado pelo Erich em 03/09/2019
					//Retirado o DIFAL para ES e MG e incluํdo um percentual fixo (2% para RJ) - Solicitado pelo Erich em 01/10/2019
					//Retirado o DIFAL para os demais estados - Solicitado pelo Erich em 02/01/2022
					If SA1->A1_ESTE$"RJ"

						nValor  := nValAux + ROUND((nValAux*2/100),4)
						nPerCon := 2

					Else//If SA1->A1_ESTE$"MG/ES"

						nValor  := nValAux
						nPerCon := 0

					Endif

					/*
					nPerAux := ((nICMInt-nICMEnt)+nFCP)*nPerDIF

					nPerCon := nPerAux

					nPerAux := (100-nPerAux)/100

					nValAux := nValor

					nValor  :=  Round(nValor/nPerAux,4)

					nPerCon := 	(nValor*100/nValAux)-100
					*/
				EndIf

			EndIf
			/*Else
			cSQL := " SELECT "
			cSQL += " 	ZZR_CODCLI,ZZR_GRPVEN,ZZR_PERACR,ZZR_PERIMP  "
			cSQL += " 	FROM "
			cSQL += 		RetSQLName("ZZR")
			cSQL += "		WHERE "
			cSQL += " 			ZZR_FILIAL 	= '"+xFilial("ZZR")+"' AND "
			cSQL += "			(ZZR_CODCLI = '"+cCliente+"' OR "
			cSQL += "			(ZZR_GRPVEN <> ' ' AND ZZR_GRPVEN = '"+SA1->A1_GRPVEN+"') OR
			cSQL += "			(ZZR_TIPCLI = '"+SA1->A1_TIPO+"' AND "
			cSQL += "			ZZR_ESTADO 	= '"+SA1->A1_ESTE+"' AND
			cSQL += "			ZZR_CONTRI 	= '"+SA1->A1_CONTRIB+"')) AND "
			cSQL += "			D_E_L_E_T_ 	= ' ' "
			cSQL += " ORDER BY ZZR_CODCLI DESC,ZZR_GRPVEN DESC "

			cSQL := ChangeQuery(cSQL)
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),"QRYZZR",.T.,.T.)

			If !QRYZZR->(Eof())
			If !Empty(cProduto)
			SB1->(dbSetOrder(1))
			If SB1->(dbSeek(xFilial("SB1")+cProduto)) .And. SB1->B1_PICM>0
			If SB1->B1_ORIGEM$"1/2/3/8"
			nValor += nValor*(QRYZZR->ZZR_PERIMP/100)
			nPerCon := QRYZZR->ZZR_PERIMP
			Else
			nValor += nValor*(QRYZZR->ZZR_PERACR/100)
			nPerCon := QRYZZR->ZZR_PERACR
			EndIf
			EndIf
			Else
			nValor += nValor*(QRYZZR->ZZR_PERACR/100)
			nPerCon := QRYZZR->ZZR_PERACR
			EndIf
			EndIf
			QRYZZR->(dbCloseArea()) */
		EndIf
	EndIf

	RestArea(aAreaSA1)
	RestArea(aAreaSB1)

Return(nValor)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFUNCOES   บAutor  ณMicrosiga           บ Data ณ  01/22/16   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function DipAtuCus(_nValor)
	DEFAULT _nValor := 0

	_nValor := DipRetCon(SA1->A1_COD,SA1->A1_LOJA,SB1->B1_COD,_nValor)

	If SA1->A1_TIPO == "F" .And. SA1->A1_CONTRIB == "2" .And. SA1->A1_ESTE <> "SP" .And. SB1->B1_PICM > 0
		_nPerc  := u_DipAcrCli(1,SA1->A1_COD,SA1->A1_LOJA,SB1->B1_COD)

		_nValor := Round(_nValor*_nPerc,4)
	EndIf

Return _nValor
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFUNCOES   บAutor  ณMicrosiga           บ Data ณ  01/27/16   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function DipRetCon(cCodCli,cCodLoj,cProduto,nValAux)
	Local aAreaSA1 	:= SA1->(GetArea())
	Local aAreaSB1 	:= SB1->(GetArea())
	Local cSQL 		:= ""
	Local cGprVen 	:= ""
	Local cCodAux   := ""
	DEFAULT cCodCli := ""
	DEFAULT cCodLoj := ""
	DEFAULT cProduto:= ""
	DEFAULT nValAux := 0

	SA1->(dbSetOrder(1))
	If SA1->(dbSeek(xFilial("SA1")+AllTrim(cCodCli)+AllTrim(cCodLoj)))
		cGrpVen := AllTrim(SA1->A1_GRPVEN)
	EndIf

	SB1->(dbSetOrder(1))
	If SB1->(dbSeek(xFilial("SB1")+AllTrim(cProduto)))
		If !Empty(SB1->B1_XCODDES)
			cCodAux := SB1->B1_XCODDES
		ElseIf !Empty(SB1->B1_XCODORI)
			cCodAux := SB1->B1_XCODORI
		EndIf
	EndIf

	If Empty(cCodAux)
		cCodAux := AllTrim(cProduto)
	Else
		cCodAux := AllTrim(cProduto)+"','"+AllTrim(cCodAux)
	EndIf

	cSQL := " SELECT "
	cSQL += "   ZZG_CUSTO "
	cSQL += " 	FROM "
	cSQL +=  		RetSQLName("ZZF")+", "+RetSQLName("ZZG")
	cSQL += " 		WHERE "
	cSQL += " 			ZZF_FILIAL = '"+xFilial("ZZF")+"' AND "
	If !Empty(cGrpVen)
		cSQL += " 			(ZZF_GRPVEN = '"+cGrpVen+"' OR "
		cSQL += " 			(ZZF_CODCLI = '"+cCodCli+"' AND "
		cSQL += " 			ZZF_LOJA   = '"+cCodLoj+"' )) AND "
	Else
		cSQL += " 			ZZF_CODCLI = '"+cCodCli+"' AND "
		cSQL += " 			ZZF_LOJA   = '"+cCodLoj+"' AND "
	EndIf
	cSQL += " 			(ZZF_DATAFI >= '"+DtoS(Date())+"' OR ZZF_DATAFI = ' ') AND "
	cSQL += " 			ZZF_ATIVO  = '1' AND "
	cSQL += " 			ZZF_FILIAL = ZZG_FILIAL AND "
	cSQL += " 			ZZF_CODIGO = ZZG_CODIGO AND "
	cSQL += "			ZZG_CUSTO  > 0 AND "
	cSQL += " 			ZZG_PRODUT IN ('"+cCodAux+"') AND "
	cSQL +=  			RetSQLName("ZZF")+".D_E_L_E_T_ = ' ' AND  "
	cSQL +=  			RetSQLName("ZZG")+".D_E_L_E_T_ = ' ' "

	cSQL := ChangeQuery(cSQL)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),'QRYZZF',.T.,.F.)

	TCSETFIELD("QRYZZF","ZZG_CUSTO","N",17,4)

	If !QRYZZF->(Eof())
		nValAux := QRYZZF->ZZG_CUSTO
	EndIf
	QRYZZF->(dbCloseArea())

	RestArea(aAreaSA1)
	RestArea(aAreaSB1)

Return nValAux

/*-----------------------------------------------------------------------------------
REGINALDO BORGES 17/05/2016
Fun็ใo........:  A1OBSSAC()
Objetivo......: Possibilitar a altera็ใo do campo A1_OBSSAC apenas peloS usuแrios
que estejam contidos no parโmetro.
Considera็oes.: Fun็ใo chamada no X3_WHEN.
-------------------------------------------------------------------------------------*/

User Function A1OBSSAC()
	Local _lRet     := .T.
	Local _cUsuario := u_DipUsr()
	Local _UserRet  := Upper(AllTrim(GetNewPar("ES_SAC_SC","RBORGES/RBEAZIN/DDOMINGOS/MCANUTO")))

	If ! AllTrim(Upper(_cUsuario)) $ _UserRet
		_lRet := .F.
	EndIf

Return _lRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFUNCOES   บAutor  ณMicrosiga           บ Data ณ  08/04/16   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function DipVldTPV()
	Local _lRet := .T.

	If cEmpAnt+cFilAnt=="0104" .And. M->C5_TIPO=="B" .And. !(M->C5_NUM$GetNewPar("ES_PEDOKCD",""))
		MsgInfo("CAT 198 - Este tipo de pedido nใo ้ permitido nesta empresa. Fale com o T.I.","ATENวรO!")
		_lRet := .F.
	EndIf

Return _lRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFUNCOES   บAutor  ณMicrosiga           บ Data ณ  08/11/16   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function DipNNItau()
	Local StrMult  := "2765432765432"
	Local BaseDac  := StrZero(Val(SEE->EE_CART),2)+Left(SE1->E1_NUMBCO,8)
	Local VarDac   := 0
	Local iDac	   := 0

	For iDac := 1 To 13
		VarDac := VarDac + Val(Substr(BaseDac, iDac, 1)) * Val(Substr(StrMult, iDac, 1))
	Next iDac

	VarDac  := 11 - VarDac % 11
	VarDac  := Iif (VarDac == 10, "P", Iif (VarDac == 11, "0", Str (VarDac, 1)))

Return VarDac

/*-----------------------------------------------------------------------------------
Fun็ใo........: C6PEDCLI()
Autor:........: REGINALDO BORGES
Data..........: 18/08/2016
Objetivo......: Obrigar o usuแrio a informar a ordem de compras do cliente, caso o
mesmo esteja no parโmetro ES_C6PEDCL, e verificar se o produto e a
ordem de compras do cliente jแ foram utilizados em pedido de venda
anterior. Retornar falso e gerar um alerta para o usuแrio.
Considera็oes.: Fun็ใo chamada no X3_VLDUSER do C6_PEDCLI -Empresa HQ.
------------------------------------------------------------------------------------*/

User Function C6PEDCLI(_PedCli,_cClient,_LojaCli,_cProd)
	Local _lRet     := .T.
	Local _CliRet  := AllTrim(GetNewPar("ES_C6PEDCL",""))

	If cEmpAnt == '04'
		If AllTrim(_cClient) $ _CliRet
			SC6->(DbOrderNickName("C6PEDCLI"))
			If SC6->(DbSeek(xFilial("SC6")+_PedCli+_cClient+_LojaCli+_cProd))
				Aviso("ATENวรO!","Produto "+AllTrim(_cProd)+" e ordem de compra "+AllTrim(_PedCli)+", "+CHR(13)+CHR(10)+;
				"jแ foram utilizados no pedido de venda "+SC6->C6_NUM+".",{"Ok"},1)
				_lRet := .F.
			EndIf
		EndIf
	EndIf

Return _lRet

/*-----------------------------------------------------------------------------------
Fun็ใo........: G1PCP()
Autor:........: REGINALDO BORGES
Data..........: 15/09/2016
Objetivo......: Calcular os valores para estrutura dos produtos PCP na HQ>
Considera็oes.: Fun็ใo chamada Gatilho G1_XQTD2 01
------------------------------------------------------------------------------------*/

User Function G1PCP(_cProd,_nQuant)

	Local _aArea   := GetArea()
	Local cB1Tipo  := ""
	Local cB1TpConv:= ""
	Local nConv    := 0
	Local cPUM     := ""
	Local cPUME    := ""
	Local cSUME    := ""

	If cEmpAnt == '04'

		cb1Tipo     := POSICIONE("SB1",1,xFILIAL("SB1")+"2"+SUBSTR(_cProd,2,6),"B1_TIPO")
		nConv       := POSICIONE("SB1",1,xFILIAL("SB1")+M->G1_COMP, "B1_CONV")

		If nConv == 0 .And. (Substr(M->G1_COMP,1,1) <> "7" .And. Substr(M->G1_COMP,1,1) <> "8")
			Alert("Fator de conversใo estแ ZERADO!","{OK}")
		EndIf

		If     Substr(_cProd,1,1) == "7"

			M->G1_XQTDCX:=0

			If nConv <= 0
				_nQuant := M->G1_XQTD2
			Else
				_nQuant := (M->G1_XQTD2/nConv)
			EndIf

		ElseIf cb1Tipo == "PA" .And. Substr(_cProd,1,1) <> "7"

			M->G1_XQTDCX:= POSICIONE("SB1",1,xFILIAL("SB1")+"2"+SUBSTR(_cProd,2,6), "B1_XQE")
			cB1TpConv   := POSICIONE("SB1",1,xFILIAL("SB1")+M->G1_COMP, "B1_TIPCONV")
			cPUM        := POSICIONE("SB1",1,xFILIAL("SB1")+"2"+SUBSTR(_cProd,2,6), "B1_UM")
			cPUME       := POSICIONE("SB1",1,xFILIAL("SB1")+M->G1_COMP, "B1_UM")
			cSUME       := POSICIONE("SB1",1,xFILIAL("SB1")+M->G1_COMP, "B1_SEGUM")

			If     Substr(M->G1_COMP,1,1) == "7"
				If (cPUM == "UN" .OR. cPUM == "PC")
					_nQuant := M->G1_XQTD2 / M->G1_XQTDCX
				Else
					_nQuant := M->G1_XQTD2
				EndIf

			ElseIf Substr(M->G1_COMP,1,1) == "8"

				_nQuant := M->G1_XQTD2

			Else

				If     cB1TpConv=="M"

					If (cPUM == "UN" .OR. cPUM == "PC")
						If cPUME == cSUME
							_nQuant := (M->G1_XQTD2/M->G1_XQTDCX)
						Else
							_nQuant := ((M->G1_XQTD2/nConv)/M->G1_XQTDCX)
						EndIf
					Else
						If cPUME == cSUME
							_nQuant := M->G1_XQTD2
						Else
							_nQuant := (M->G1_XQTD2/nConv)
						EndIf
					EndIf

				ElseIf cB1TpConv=="D"

					If (cPUM == "UN" .OR. cPUM == "PC")
						If cPUME == cSUME
							_nQuant := (M->G1_XQTD2*M->G1_XQTDCX)
						Else
							_nQuant := ((M->G1_XQTD2*nConv)/M->G1_XQTDCX)
						EndIf
					Else
						If cPUME == cSUME
							_nQuant := M->G1_XQTD2
						Else
							_nQuant := (M->G1_XQTD2*nConv)
						EndIf

					EndIf

				EndIf

			EndIf

		EndIf

	EndIf

	RestArea(_aArea)

	Return (_nQuant)

	*----------------------------------------------*
User Function SalEsPCP(_cProduto,lConsolid)
	//RBorges - 27/09/16 - Verifica se existe saldo
	//					   Poder de Terceiro.
	//                     Esteriliza็ใo HQ
	*----------------------------------------------*
	Local _aArea	  := GetArea()
	Local _SdPoder3I  := 0
	Local cQRY        := ""
	Local cFORBEHQ    := GetNewPar("ES_FORBEHQ","")
	DEFAULT _cProduto := ""
	DEFAULT lConsolid := .F.

	//ESTOQUE EM PODE DE TERCEIRO (CBE e QUALITY)//
	cQRY1 := "SELECT "
	cQRY1 += " SUM(B6_SALDO) AS SALDO "
	cQRY1 += " FROM "+RetSQLName("SF2")+" SF2, "+RetSQLName("SB6")+" SB6 "
	cQRY1 += " WHERE "
	If cEmpAnt=="04" .And. lConsolid
		cQRY1 += " SF2.F2_FILIAL IN('01','02') "
	Else
		cQRY1 += " SF2.F2_FILIAL = '"+ xFilial("SF2")+"' "
	EndIf
	cQRY1 += " AND   SB6.B6_FILIAL   = SF2.F2_FILIAL "
	cQRY1 += " AND   SF2.F2_CLIENTE  IN ('" + AllTrim(cFORBEHQ) + "') "
	cQRY1 += " AND   SF2.F2_TIPO     = 'B' "
	cQRY1 += " AND   SF2.F2_DOC     = SB6.B6_DOC     "
	cQRY1 += " AND   SF2.F2_SERIE   = SB6.B6_SERIE   "
	cQRY1 += " AND   SF2.F2_CLIENTE = SB6.B6_CLIFOR  "
	cQRY1 += " AND   SF2.F2_LOJA    = SB6.B6_LOJA    "
	cQRY1 += " AND   SB6.B6_PRODUTO = '"+_cProduto+"'"
	cQRY1 += " AND   SB6.B6_ATEND   = ''             "
	//cQRY1 += " AND   SB6.B6_UENT    = ''             "
	cQRY1 += " AND   SB6.B6_SALDO   > 0				 "
	cQry1 += " AND   SF2.D_E_L_E_T_ = ''             "
	cQry1 += " AND   SB6.D_E_L_E_T_ = ''             "

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
	TcQuery cQRY1 NEW ALIAS "cQRY1"         // ABRE UMA WORKAREA COM O RESULTADO DA QUERY

	DbSelectArea("cQRY1")
	cQRY1->(dbGotop())
	_SdPoder3I := cQRY1->SALDO
	DBCLOSEAREA("cQRY1")

	RestArea(_aArea)

Return(_SdPoder3I)

/*-------------------------------------------------------------+
| Funcao: HQSALDSB2 | Autor : RBORGES   | Data: 06/10/2016     |
+--------------------------------------------------------------+
|Descri็ใo: Verificar saldo do produto no estoque 99.          |
|           Funcao chamada no cosulta padrใo ZZ9_CODPROD.      |
+--------------------------------------------------------------*/

User Function HQSALDSB2(_cProduto)

	Local nEstoq99 := 0
	Local QRY1     := ""
	Local _cLocal  := "99"
	Local _xAlias  := GetArea()

	QRY1 := "SELECT "
	QRY1 += " SUM((B2_QATU-B2_QACLASS-B2_QEMP)) AS ESTOQUE "
	QRY1 += " FROM " + RetSQLName("SB2")
	QRY1 += " WHERE B2_FILIAL = '" + xFILIAL("SB2") + "'"
	QRY1 += " AND B2_COD = '"+_cProduto + "'"
	QRY1 += " AND B2_LOCAL = '"+_cLocal +"'"
	QRY1 += " AND "  + RetSQLName("SB2")+".D_E_L_E_T_ = ' '"
	QRY1 += " GROUP BY B2_COD "

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
	TcQuery QRY1 NEW ALIAS "QRY1SB2" // ABRE UMA WORKAREA COM O RESULTADO DA QUERY

	DbSelectArea("QRY1SB2")

	If QRY1SB2->ESTOQUE > 0
		nEstoq99 := QRY1SB2->ESTOQUE
	Endif

	DBCLOSEAREA("QRY1SB2")
	RestArea(_xAlias)

Return(nEstoq99)

/*-------------------------------------------------------------+
| Funcao: ValEstPCP() | Autor : RBORGES | Data: 07/10/2016     |
+--------------------------------------------------------------+
|Descri็ใo: Verificar o calculo da estrutura antes da inclusao |
|           da requisicao de material.                         |
+--------------------------------------------------------------*/

User Function ValEstPCP()
	Local lRet 		:= .T.
	Local _nDipOpcx	:= 0
	Local cSQL 		:= ""
	Local aItens    := {}
	Local aCampos   := {}
	Local nI		:= 0
	Private _cDescri	:= Space(60)
	Private _cProduto := Space(15)
	Private _nQuant   := 0
	Private nQtdComp  := 0
	Private cMpDesc   := ""
	Private cTpEmb    := ""
	Private nQtdEmb   := 0

	@ 126,000 To 300,415 DIALOG oDlg TITLE OemToAnsi("Informe o Produto")
	@ 005,005 Say OemToAnsi("Produto: ")
	@ 013,005 Get _cProduto Size 43,20 	F3 "SB1" Valid IIf(ExistCPO("SB1") .And. ExistCPO("SG1"),(_cDescri:=OemToAnsi(POSICIONE("SB1",1,xFilial("SB1")+_cProduto,"B1_DESC")),.T.),.F.)
	@ 025,005 Get _cDescri Size 200,20 When .F.
	@ 040,005 Say OemToAnsi("Quantidade: ")
	@ 048,005 Get _nQuant Size 43,20  Picture "@E 99999999" Valid _nQuant > 0
	@ 068,005 BUTTON OemToAnsi("Confirma")  SIZE 30,15 ACTION (_nDipOpcx := 1, Close(odlg))
	@ 068,040 BUTTON OemToAnsi("Cancela")   SIZE 30,15 ACTION (_nDipOpcx := 0, Close(odlg))
	ACTIVATE DIALOG oDlg Centered

	If _nDipOpcx == 1
		aItens := DipRetSG1(_cProduto)
		If Len(aItens)>0
			For nI:=1 to Len(aItens)
				If aItens[nI,3]
					nQtdComp := aItens[nI,2]*_nQuant
					cMpDesc  := Posicione("SB1",1,xFilial("SB1")+aItens[nI,1],"B1_DESC")
					*               1-Produto  2-Desc  3-Quantidade   4-UM     5-Quantidade 2UM                   6-2UM       7-FatConv
					aadd(aCampos,{aItens[nI,1],cMpDesc, nQtdComp,aItens[nI,6],ConvUm(aItens[nI,1],nQtdComp,0,2 ),aItens[nI,7],aItens[nI,8]})
				EndIf
			Next nI
		EndIf
	Else
		Aviso("Aten็ใo","Processo cancelado pelo operador.",{"Ok"})
	EndIf

	If  Len(aCampos) > 0

		cTpEmb  := Posicione("SB1",1,xFilial("SB1")+"2"+SUBSTR(_cProduto,2,6), "B1_UM")
		nQtdEmb := Posicione("SB1",1,xFilial("SB1")+"2"+SUBSTR(_cProduto,2,6), "B1_XQE")

		Define msDialog oDlg Title "Validando Estrutura do Produto" From 000,000 TO 030,111

		@ 005,005 Get _cProduto Size 40,20 When .F.
		@ 005,045 Get _cDescri Size 200,20 When .F.
		@ 005,250 Get cTpEmb  Size 10,20 When .F.
		@ 005,270 Say OemToAnsi("Qtde.Emb.: ")
		@ 005,310 Get nQtdEmb Size 30,20 Picture "@E 99999999" When .F.
		@ 020,005 Say OemToAnsi("Producao: ")
		@ 020,045 Get _nQuant Size 40,20  Picture "@E 99999999" When .F.
		@ 040,005 LISTBOX oLbx FIELDS HEADER "Produto","Descricao","Quantidade", "UM", "Quant.2UM", "2UM","Fator_Conversao" SIZE 430,165 OF oDlg PIXEL
		oLbx:SetArray( aCampos )
		oLbx:bLine := {|| {aCampos[oLbx:nAt,1],aCampos[oLbx:nAt,2],aCampos[oLbx:nAt,3],aCampos[oLbx:nAt,4],aCampos[oLbx:nAt,5],aCampos[oLbx:nAt,6],aCampos[oLbx:nAt,7]}}
		@ 215,395 BUTTON oBOTAOFECHAR PROMPT "&Fechar" SIZE 040,010 PIXEL OF oDLG ACTION (oDLG:END())

		Activate dialog oDlg centered

	Else
		MsgInfo("Nใo hแ itens na estrutura desse prodtuo.","ATENวรO!")
	EndIf

Return lRet
/*-------------------------------------------------------------+
| Funcao: DipRetSG1() | Autor : RBORGES | Data: 07/10/2016     |
+--------------------------------------------------------------+
|Descri็ใo: Verificar as MPs e as quantidades na estrutura     |
|           do produto.				                           |
+--------------------------------------------------------------*/

Static Function DipRetSG1(cProduto)
	Local lProcura := .T.
	Local aItens   := {}
	Local nI       := 0

	//______________________________
	//                              |
	//  aItens[1] - PRODUTO         |
	//  aItens[2] - QUANTIDADE      |
	//  aItens[3] - REQUISICAO?     |
	//  aItens[4] - LOCAL PADRAO    |
	//  aItens[5] - FLAG CONTROLE   |
	//  aItens[6] - UM  		    |
	//  aItens[7] - SEGUNDA UM      |
	//______________________________|

	SG1->(dbSetOrder(1))
	If SG1->(dbSeek(xFilial("SG1")+cProduto))
		While SG1->G1_COD == cProduto
			SB1->(dbSetOrder(1))
			If SB1->(dbSeek(xFilial("SB1")+SG1->G1_COMP))
				aAdd(aItens,{SG1->G1_COMP,SG1->G1_QUANT,.T.,SB1->B1_LOCPAD,.T.,SB1->B1_UM,SB1->B1_SEGUM,SB1->B1_CONV})
			EndIf
			SG1->(dbSkip())
		EndDo

		While lProcura
			lProcura := .F.
			For nI:=1 to Len(aItens)
				If aItens[nI,5]
					If SG1->(dbSeek(xFilial("SG1")+aItens[nI,1]))
						While SG1->G1_COD == aItens[nI,1]
							SB1->(dbSetOrder(1))
							If SB1->(dbSeek(xFilial("SB1")+SG1->G1_COMP))
								aAdd(aItens,{SG1->G1_COMP,SG1->G1_QUANT,.T.,SB1->B1_LOCPAD,.T.,SB1->B1_UM,SB1->B1_SEGUM,SB1->B1_CONV})
							EndIf
							aItens[nI,3] := .F.
							SG1->(dbSkip())
						EndDo
						lProcura := .T.
					EndIf
					aItens[nI,5] := .F.
				EndIf
			Next nI
			SG1->(dbSkip())
		EndDo

	EndIf

Return aItens
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFUNCOES   บAutor  ณMicrosiga           บ Data ณ  10/14/16   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function DipVldFCI()
	Local lRet 	  	:= .T.
	Local cFciCod 	:= AllTrim(M->D1_FCICOD)
	Local cCaracter := ""
	Local nI
	If ISINCALLSTACK("LOJA901A") .Or. ISINCALLSTACK("LOJA901")
		Return .T.
	EndIf

	If "MATA310"$Upper(FunName())
		Return .T.
	EndIf

	If Len(cFciCod)<36
		lRet := .F.
		Aviso("Aten็ใo","FCI invแlido. O c๓digo FCI digitado ้ menor do que o padrใo.",{"Ok"})
	Else
		For nI:=1 to Len(cFciCod)
			cCaracter := SubStr(cFciCod,nI,1)

			If (nI==9 .Or. nI==14 .Or. nI==19 .Or. nI==24)
				If cCaracter <> "-"
					Aviso("Aten็ใo","FCI invแlido. Confira o c๓digo na NF de entrada.",{"Ok"})
					lRet := .F.
					Exit
				EndIf
			Else
				If IsAlpha(cCaracter)
					If cCaracter>"F"
						Aviso("Aten็ใo","FCI invแlido. A letra "+cCaracter+" nใo ้ permitida.",{"Ok"})
						lRet := .F.
						Exit
					EndIf
				ElseIf StrZero(Val(cCaracter),1) <> cCaracTer
					Aviso("Aten็ใo","FCI invแlido. Confira o c๓digo na NF de entrada.",{"Ok"})
					lRet := .F.
					Exit
				EndIf
			EndIf
		Next nI
	EndIf

Return lRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFUNCOES   บAutor  ณMicrosiga           บ Data ณ  11/10/16   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function DipRetSZ1(cSegMent,cLetra,cFornec)
	Local cSQL := ""
	Local nRet := 0
	DEFAULT cSegMent := ""
	DEFAULT cLetra	 := ""
	DEFAULT cFornec  := ""

	cSQL := " SELECT "
	cSQL += " 	Z1_PERCENT "
	cSQL += " 	FROM "
	cSQL +=  		RetSQLName("SZ1")
	cSQL += " 		WHERE "
	cSQL += " 			Z1_FILIAL  = '"+xFilial("SZ1")+"' AND "
	cSQL += " 			Z1_SEGMENT = '"+cSegMent+"' AND "
	cSQL += " 			Z1_FORNEC  = '"+cFornec+"' AND "
	cSQL += " 			Z1_LETRA   = '"+cLetra+"' AND "
	cSQL += " 			D_E_L_E_T_ = ' ' "

	cSQL := ChangeQuery(cSQL)

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),"QRYSZ1",.T.,.T.)

	If !QRYSZ1->(Eof())
		nRet := QRYSZ1->Z1_PERCENT
	EndIf
	QRYSZ1->(dbCloseArea())

Return nRet
/*-------------------------------------------------------------+
| Funcao: HQQTDOP | Autor : RBORGES   | Data: 13/10/2016       |
+--------------------------------------------------------------+
|Descri็ใo: Na inclusใo da OP valida a quantidade informada.   |
|           A produ็ใo deve ser multiplo do campo B1_XQE       |
+--------------------------------------------------------------+
|Uso: PCP HQ, fun็ใo chamda no X3_VLDUSER DO C2_QUANT          |
+--------------------------------------------------------------*/

User Function HQQTDOP(_cProduto,nQuant)

	Local _xAlias := GetArea()
	Local nQtdEmb := 0
	Local _lRet   := .T.
	Local cTpEmb  := ""
	Local cTpPro  := ""

	cTpPro := Posicione("SB1",1,xFilial("SB1")+_cProduto,"B1_TIPO")

	If cTpPro <> "PI"
		nQtdEmb := Posicione("SB1",1,xFilial("SB1")+"2"+SUBSTR(_cProduto,2,6), "B1_XQE")
		cTpEmb  := Posicione("SB1",1,xFilial("SB1")+"2"+SUBSTR(_cProduto,2,6), "B1_UM")

		If Mod(nQuant,nQtdEmb) <> 0 .And. cTpEmb <> "CX"
			Alert("Produzir Quantidade Multipla de "+cValToChar(nQtdEmb)+".","{OK}")
			_lRet := .F.
		EndIf
	EndIf

	RestArea(_xAlias)

Return(_lRet)

/*-------------------------------------------------------------+
| Funcao: USESU7 | Autor : RBORGES   | Data: 07/02/2017        |
+--------------------------------------------------------------+
|Descri็ใo: Verificar se o usuแrio logado ้ vendedor do        |
|           televendas.							  		       |
+--------------------------------------------------------------*/

User Function USESU7(cCodUser,_CodVen,_cPosto)

	Local QRY1     := ""
	Local _xAlias  := GetArea()

	QRY1 := "SELECT "
	QRY1 += " U7_CODVEN,U7_POSTO "
	QRY1 += " FROM " + RetSQLName("SU7")
	QRY1 += " WHERE U7_FILIAL = '" + xFILIAL("SU7") + "'"
	QRY1 += " AND   U7_POSTO  IN ('02','03')"
	QRY1 += " AND   U7_CODUSU = '"+cCodUser+"'"
	QRY1 += " AND "  + RetSQLName("SU7")+".D_E_L_E_T_ = ' '"

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
	TcQuery QRY1 NEW ALIAS "QRY1U7" // ABRE UMA WORKAREA COM O RESULTADO DA QUERY

	DbSelectArea("QRY1U7")

	_CodVen := QRY1U7->U7_CODVEN
	_cPosto := QRY1U7->U7_POSTO

	DbCloseArea("QRY1U7")
	RestArea(_xAlias)

Return(_CodVen,_cPosto)

/*-------------------------------------------------------------+
| Funcao: GELOTEC2 | Autor : RBORGES   | Data: 21/02/2017      |
+--------------------------------------------------------------+
|Descri็ใo: Gerar o lote na ordem de produ็ใo posicionada, na  |
|           SC2.	 							  		       |
+--------------------------------------------------------------+
|Uso: PCP Health Quality                                       |
+--------------------------------------------------------------*/

User Function GeLoteC2()
	Local cLote := Posicione("SC2",1,xFilial("SC2")+SC2->C2_NUM+SC2->C2_ITEM+"001","SC2->C2_XLOTECT")
	Local cOP   := SC2->C2_NUM+SC2->C2_ITEM+"001"
	Local nRev  := 01
	Local lRet  := U_cConLote(cOP,cLote)

	If !Upper(u_DipUsr())$GetNewPar("ES_LOTE650","DDOMINGOS/RBORGES/MCANUTO/SFSILVA")
		Aviso("ES_LOTE650","Usuแrio sem acesso. Fale com o T.I.",{"Ok"})
		Return
	EndIf

	If Empty(cLote) .Or. !lRet

		If Empty(cLote)
			cLote := SC2->C2_NUM+StrZero(month(Date()),2)+cValToChar(StrZero(nRev,2))
		Else
			nRev := Val(SubStr(SC2->C2_XLOTECT,9,2))+1
			cLote := SC2->C2_NUM+StrZero(month(Date()),2)+cValToChar(StrZero(nRev,2))
		EndIf

		SC2->(RecLock("SC2",.F.))
		SC2->C2_XLOTECT := cLote
		SC2->(MsUnlock())

	Else

		If cLote == SC2->C2_NUM+StrZero(month(Date()),2)+cValToChar(StrZero(nRev,2))
			MsgInfo("Lote atual nใo foi utilizado ainda.","ATENวรO!")
		Else
			If MsgYesNo("Lote atual nใo foi utilizado ainda. Quer gerar NOVO LOTE?","ATENวรO!")
				nRev := Val(SubStr(SC2->C2_XLOTECT,9,2))+1
				cLote := SC2->C2_NUM+StrZero(month(Date()),2)+cValToChar(StrZero(nRev,2))

				SC2->(RecLock("SC2",.F.))
				SC2->C2_XLOTECT := cLote
				SC2->(MsUnlock())

				MsgInfo("Imprimir novas etiquetas para o novo lote "+cLote+" !","ATENวรO!")
			EndIf
		EndIf

	EndIf

Return

User Function cConLote(cOP,cLote)
	Local cSQL := ""
	Local lRet := .T.

	cSQL := " SELECT D3_LOTECTL"
	cSQL += " 	FROM "+ RetSQLName("SD3")
	cSQL += " 	  WHERE D3_FILIAL  = '"+xFilial("SD3")+"'"
	cSQL += " 	    AND D3_OP      = '"+cOP+"'"
	cSQL += " 	    AND D3_LOTECTL = '"+cLote+"'"
	cSQL += " 	    AND D3_TM      = '010'"
	cSQL += " 	    AND D_E_L_E_T_ = ' ' "

	cSQL := ChangeQuery(cSQL)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),"LOTEPCP",.T.,.T.)

	If !LOTEPCP->(Eof())
		lRet := .F.
	EndIf

	LOTEPCP->(dbCloseArea())

Return lRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ??Ü??ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFUNCOES   บAutor  ณMicrosiga           บ Data ณ  01/04/16   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function VldTesD1(cTes,cCodPro)
	Local aAreaSB1 := SB1->(GetArea())
	Local nPosPro  := ""
	Local cDipNCM  := ""
	DEFAULT cTes   := ""
	DEFAULT cCodPro:= ""

	If Empty(cCodPro)
		nPosPro := aScan(aHeader,{|x| AllTrim(x[2])=="D1_COD"})
		cCodPro := aCols[n,nPosPro]
	EndIf

	SB1->(dbSetOrder(1))
	If SB1->(dbSeek(xFilial("SB1")+cCodPro))
		If cEmpAnt == "01"
			cDipNCM := GetNewPar("ES_CST06_1","")+"/"+GetNewPar("ES_CST06_2","")+"/"+GetNewPar("ES_CST06_3","")
			If AllTrim(SB1->B1_POSIPI)$cDipNCM .Or. ;
			Left(SB1->B1_POSIPI,6)=="902110"   .Or. ; 
			Left(SB1->B1_POSIPI,5)=="90213"     .Or. ;
			Left(SB1->B1_POSIPI,4)=="8713"
				Do Case
					Case cTes == "001";	cTes := "320"
					Case cTes == "003";	cTes := "321"
					Case cTes == "005";	cTes := "322"
					Case cTes == "006";	cTes := "323"
					Case cTes == "008";	cTes := "324"
					Case cTes == "010";	cTes := "325"
					Case cTes == "012";	cTes := "326"
					Case cTes == "015"; cTes := "327"
					Case cTes == "017";	cTes := "328"
					Case cTes == "019";	cTes := "329"
					Case cTes == "021";	cTes := "330"
					Case cTes == "022";	cTes := "331"
					Case cTes == "025";	cTes := "332"
					Case cTes == "027";	cTes := "333"
					Case cTes == "035";	cTes := "334"
					Case cTes == "038";	cTes := "335"
					Case cTes == "110";	cTes := "336"
					Case cTes == "114";	cTes := "337"
					Case cTes == "117";	cTes := "338"
					Case cTes == "131";	cTes := "339"
					Case cTes == "133";	cTes := "340"
					Case cTes == "135";	cTes := "341"
					Case cTes == "163";	cTes := "342"
					Case cTes == "179";	cTes := "343"
					Case cTes == "183";	cTes := "344"
					Case cTes == "184";	cTes := "345"
					Case cTes == "222";	cTes := "346"
					Case cTes == "255";	cTes := "347"
					Case cTes == "263";	cTes := "348"
					Case cTes == "302";	cTes := "349"
					Case cTes == "305";	cTes := "350"
				EndCase
			EndIf
		EndIf
	EndIf

	RestArea(aAreaSB1)

Return cTes

/*-----------------------------------------------------------------------------------
REGINALDO BORGES 12/04/2017
Fun็ใo........:  VLDD3TMB()
Objetivo......: No internos modelo2 permitir requisi็ใo manual com o TM 501 para
produtos diferentes de MP e TM 502 somente para MP.
E nใo permitir movimenta็ใo de produtos Z.
Considera็oes.: Fun็ใo chamada no X3_VLDUSER.
-------------------------------------------------------------------------------------*/

User Function VLDD3TMb()

	Local lRet   := .T.
	Local _cTipo := Posicione("SB1",1,xFilial("SB1")+M->D3_COD,"B1_TIPO")

	If Upper(FunName())=="UMATA241"
		lRet := If(SubStr(Posicione("SB1",1,xFilial("SB1")+M->D3_COD,"B1_DESC"),1,1)<>"Z",.T.,(MSGINFO("PRODUTO Z, entrada proibida !"),.F.))
		If cEmpAnt == '04'
			If Type("cTm")<>"U" .And. ((cTm == '501' .And. _cTipo == "MP") .Or. (cTm == '502' .And. _cTipo <> "MP"))
				lRet := .F.
				MsgInfo("Usar TM 502 para MP e 501 para os demais tipos de produtos!")
			EndIf
		EndIf
	EndIf

Return lRet

/*------------------------------------------------------------------------------------
REGINALDO BORGES 16/06/2017
Fun็ใo........:  MENCNAE()
Objetivo......: No preenchimento do CNAE mostrar uma mensagem para quem estแ efetuando
o cadastro, informando se o cliente deve ter licenca de funcionamento
ou nใo.
Considera็oes.: Fun็ใo chamada X3_VLDUSER  dos campos A1_CNAE e A1_LFVISA.
-------------------------------------------------------------------------------------*/

User Function MENCNAE() //U_MENCNAE()
	Local _aArea := GetArea() //FB - 17/08/18
	Local cCevs := ""
	Local lRet := .T.

	If cEmpAnt <> "04"

		If ("MATA410" $ FUNNAME())
			cCevs := Posicione("CC3",1,xFilial("CC3")+SA1->A1_CNAE,"CC3_XCEVS")
		Else
			cCevs := Posicione("CC3",1,xFilial("CC3")+M->A1_CNAE,"CC3_XCEVS")
		EndIf

		IF !IsBlind() //FB - 17/08/18
			If     cCevs == "1"
				MsgInfo('Solicitar a Licen็a de Funcionamento do cliente!','ATENวรO!')
			ElseIf cCevs == "2"
				MsgInfo('Verificar com a qualidade, CNAE do cliente em mais de um ANEXO!','ATENวรO!')
			ElseIf cCevs == "3"
				MsgInfo('Verificar com a qualidade, CNAE do cliente no ANEXO III !','ATENวรO!')
			ElseIf cCevs == " " .And. !(Empty(SA1->A1_CNAE) .Or. Empty(M->A1_CNAE))
				MsgInfo('Verificar com a qualidade, CNAE do cliente fora da NORMA!','ATENวรO!')
			EndIf
		ENDIF

	EndIf

	//Rafael Moraes Rosa - 17/03/2023 - INICIO
	IF RetCodUsr() $ GetNewPar("MV_#USCNAE","000000") .OR. M->A1_CNAE = "    - /  "
		lRet := .T.
	ELSE
		FWAlertWarning("A definicao do CNAE nao e permitida para o seu perfil.", "Edicao CNAE bloqueada")
		lRet := .F.
	ENDIF
	//Rafael Moraes Rosa - 17/03/2023 - INICIO

	RestArea(_aArea) //FB - 17/08/18
Return(lRet)

/*------------------------------------------------------------------------------------
REGINALDO BORGES 16/06/2017
Fun็ใo........:  LICVALID()
Objetivo......: Libera a edi็ใo da data de validade somente se informa็ใo do A1_LFVISA
for Licen็a de Funcionamento CC3_XCEVS = '1'
Considera็oes.: Fun็ใo chamada no X3_WHEN do A1_VLLVISA
-------------------------------------------------------------------------------------*/

User Function LICVALID() //U_LICVALID()

	Local cCevs := Posicione("CC3",1,xFilial("CC3")+M->A1_CNAE,"CC3_XCEVS")
	Local lRet  := .F.

	//If cEmpAnt <> "04"
	If INCLUI .Or. ALTERA
		If ! Empty(cCevs)
			lRet := .T.
		EndIf
		//	EndIf - Retirada a valida็ใo da empresa 04
	EndIf

Return(lRet)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFUNCOES   บAutor  ณMicrosiga           บ Data ณ  07/30/17   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function DipIntSP(cDipMun)
	/*==================================
	-> Lista de municํpios do estado de SP que passaram a cobrar 2% de CIF
	03901 - ARUJA
	15103 - EMBU-GUACU
	15707 - FERRAZ DE VASCONCELOS
	23107 - ITAQUAQUECETUBA
	18305 - GUARAREMA
	28502 - MAIRIPORA
	30607 - MOGI DAS CRUZES
	39806 - POA
	46801 - SANTA ISABEL
	52502 - SUZANO
	43303 - RIBEIRAO PIRES
	44103 - RIO GRANDE DA SERRA
	56453 - VARGEM GRANDE PAULISTA
	====================================*/
	Local aArea   := GetArea()
	Local cMunCIF := StrTran(GetNewPar("ES_RCOBCIF","03901/15103/15707/23107/18305/28502/30607/39806/46801/52502/43303/44103/56453"),"/","','")
	Local cSQL    := ""
	Local lRet    := .F.
	DEFAULT cDipMun := ""

	cSQL := " SELECT "
	cSQL += " 	CC2_CODMUN "
	cSQL += " 	FROM "
	cSQL +=  		RetSQLName("CC2")
	cSQL += " 		WHERE "
	cSQL += " 			CC2_FILIAL 	= '"+xFilial("CC2")+"' AND "
	cSQL += " 			CC2_EST 	= 'SP' AND "
	cSQL += " 			CC2_CODMUN IN('"+cMunCIF+"') AND "
	cSQL += " 			CC2_MUN 	= '"+AllTrim(cDipMun)+"' AND "
	cSQL += " 			D_E_L_E_T_ 	= ' ' "

	cSQL := ChangeQuery(cSQL)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),"QRYCC2",.T.,.T.)

	lRet := !QRYCC2->(Eof())
	QRYCC2->(dbCloseArea())

	RestArea(aArea)

Return lRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFUNCOES   บAutor  ณMicrosiga           บ Data ณ  07/30/17   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function DipPerCIF(cDipMun)
	/*==================================
	-> Lista de Municํpios que a EMOVERE nใo atende, mas podemos enviar CIF pela JAMEF ou ATIVA.

	01608 - AMERICANA
	03307 - ARARAS
	07605 - BRAGANCA PAULISTA
	26902 - LIMEIRA
	30706 - MOGI GUACU
	31100 - MONGAGUA
	38709 - PIRACICABA
	41000 - PRAIA GRANDE
	43907 - RIO CLARO
	45803 - SANTA BARBARA D OESTE
	48500 - SANTOS
	49904 - SAO JOSE DOS CAMPOS
	51009 - SAO VICENTE
	54102 - TAUBATE
	====================================*/
	Local aArea   := GetArea()
	Local cMunCIF := StrTran(GetNewPar("ES_RPERCIF","01608/03307/07605/26902/30706/31100/38709/41000/43907/45803/48500/49904/51009/54102"),"/","','")
	Local cSQL    := ""
	Local lRet    := .F.
	DEFAULT cDipMun := ""

	cSQL := " SELECT "
	cSQL += " 	CC2_CODMUN "
	cSQL += " 	FROM "
	cSQL +=  		RetSQLName("CC2")
	cSQL += " 		WHERE "
	cSQL += " 			CC2_FILIAL 	= '"+xFilial("CC2")+"' AND "
	cSQL += " 			CC2_EST 	= 'SP' AND "
	cSQL += " 			CC2_CODMUN IN('"+cMunCIF+"') AND "
	cSQL += " 			CC2_MUN 	= '"+AllTrim(cDipMun)+"' AND "
	cSQL += " 			D_E_L_E_T_ 	= ' ' "

	cSQL := ChangeQuery(cSQL)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),"QRYCC2",.T.,.T.)

	lRet := !QRYCC2->(Eof()) // Se nใo encontrar ้ por que nessa regiใo nใo podemos enviar CIF para Revendedor.
	QRYCC2->(dbCloseArea())

	RestArea(aArea)

Return lRet
/* Comentando por solicita็ใo da qualidade RBorges 23/06/17
---------------------------------------------------------------------
REGINALDO BORGES 16/06/2017
Fun็ใo........:  AFEWHEN()
Objetivo......: Libera a edi็ใo dos campos AFE no cadastro do cliente
somente quando o campo A1_CNAE estiver preenchido e o
CNAE for for de cliente atacadista.
Considera็oes.: Fun็ใo chamada no X3_WHEN do A1_VLLVISA
-----------------------------------------------------------------------

User Function AFEWHEN() //U_AFEWHEN()

Local cSQL := ""
Local lRet := .F.

cSQL := " SELECT CC3_COD"
cSQL += " 	FROM "+ RetSQLName("CC3")
cSQL += " 	  WHERE CC3_FILIAL = '"+xFilial("CC3")+"'"
cSQL += "       AND CC3_COD    = '"+M->A1_CNAE+"'"
cSQL += " 	    AND CC3_DESC LIKE ('%atacadista%')"
cSQL += " 	    AND D_E_L_E_T_ = ' ' "

cSQL := ChangeQuery(cSQL)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),"SQLAFE",.T.,.T.)

If !SQLAFE->(Eof()) .And. !Empty(M->A1_CNAE)
lRet := .T.
EndIf

SQLAFE->(dbCloseArea())

Return(lRet)
*/

/*====================================================================================\
|Programa  | DipKardexb | Autor |Reginaldo Borges, RSB          | Data | 26/07/2017  |
|=====================================================================================|
|Descri็ใo | Adiciona um novo registro no ZZW ou Altera o registro jแ posicionado     |
|          | Registrar altera็๕es na Ficha Kardex do Produto                          |
|          |                                                                          |
|=====================================================================================|
|Sintaxe   | DipKardexb(cPedido,cUsuario,cTipoMovimento,lIncluirKardex,cOcorrencia)  |
|=====================================================================================|
|Parametros| cPedido........: Variavel com o codigo do Pedido.                        |
|          | cUsuario.......: Variavel com o Nome do usuario logado no sistema.       |
|          | cTipoMovimento.: String que descreve o movimento executado.              |
|          | lIncluirKardex.: .T./.F. Determina se inclui ou altera um registro.      |
|          | cOcorrencia....: Codigo do movimento executado. Esta na Tabela Z9 no SX5.|
|=====================================================================================|
|Uso       | Especifico DIPROMED                                                      |
|=====================================================================================|
|........................................Hist๓rico....................................|
|RBorges   | 26/07/2017 - Criou a fun็ใo.                                             |
|          |                                                                          |
\====================================================================================*/
User Function DipKardexb(cPedido,cUsuario,cTipoMovimento,lIncluirKardex,cOcorrencia)
	If lIncluirKardex
		dbSelectArea("ZZW")
	EndIf
	ZZW->(RecLock("ZZW",lIncluirKardex))
	ZZW->ZZW_FILIAL  := xFilial('ZZW')
	ZZW->ZZW_PEDIDO  := cPedido
	//ZZW->ZZW_OCORRE := cOcorrencia //Codigo da ocorrencia, caso use tabela auxiliar, X5, por exemplo.
	ZZW->ZZW_DESOCO := cOcorrencia //Descricao da ocorrecia.
	ZZW->ZZW_TIPMOV := cTipoMovimento
	ZZW->ZZW_DATAMO := DATE()
	ZZW->ZZW_HORAMO := TIME()
	ZZW->ZZW_USUARI := Upper(cUsuario)
	ZZW->(MsUnLock("ZZW"))
RETURN(.T.)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDipSomaCQ  บAutor  ณMicrosiga           บ Data ณ  12/02/14   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function DipSomaCQ(cProd,cForn,cLoja,lCons)
	Local aArea 	:= GetArea()
	Local cSQL 		:= ""
	Local nQtdAux 	:= 0
	DEFAULT cProd	:= ""
	DEFAULT cForn	:= ""
	DEFAULT cLoja	:= ""
	DEFAULT lCons	:= .F.

	cSQL := " SELECT "
	cSQL += "	SUM(CAST(QEK_TAMAMO AS INT)) QTDCQ "
	cSQL += "	FROM "
	cSQL += 		RetSQLName("QEK")
	cSQL += " 		WHERE "
	If lCons
		cSQL += " 			QEK_FILIAL IN('01','04') AND "
	Else
		cSQL += " 			QEK_FILIAL = '"+xFilial("QEK")+"' AND "
	EndIf
	cSQL += " 			QEK_FORNEC = '"+cForn+"' AND "
	cSQL += " 			QEK_LOJFOR = '"+cLoja+"' AND "
	cSQL += " 			QEK_PRODUT = '"+cProd+"' AND "
	cSQL += " 			QEK_SITENT = '1' AND "
	cSQL += " 			D_E_L_E_T_ = ' ' "

	cSQL := ChangeQuery(cSQL)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),"QRYQEK",.T.,.T.)

	If !QRYQEK->(Eof())
		nQtdAux := QRYQEK->QTDCQ
	EndIf
	QRYQEK->(dbCloseArea())

	RestArea(aArea)

Return nQtdAux

/*-------------------------------------------------------------+
| Funcao: HQEMPSB2 | Autor : RBorges    | Data: 13/11/2017     |
+--------------------------------------------------------------+
|Descri็ใo: Verificar quantidade empenhada do produto MP       |
+--------------------------------------------------------------+
|Uso: Health Quality - Fun็ใo F5 Cadastro de Produtos          |
+--------------------------------------------------------------*/

User Function HQEMPSB2(_cProduto)

	Local nEmp99 := 0
	Local QRY1     := ""
	Local _cLocal  := "99"
	Local _xAlias  := GetArea()

	QRY1 := "SELECT "
	QRY1 += " SUM(B2_QEMP) AS EMPENHO "
	QRY1 += " FROM " + RetSQLName("SB2")
	QRY1 += " WHERE B2_FILIAL = '" + xFILIAL("SB2") + "'"
	QRY1 += " AND B2_COD = '"+_cProduto + "'"
	//QRY1 += " AND B2_LOCAL = '"+_cLocal +"'"
	QRY1 += " AND "  + RetSQLName("SB2")+".D_E_L_E_T_ = ' '"
	QRY1 += " GROUP BY B2_COD "

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
	TcQuery QRY1 NEW ALIAS "QRYEMP" // ABRE UMA WORKAREA COM O RESULTADO DA QUERY

	DbSelectArea("QRYEMP")

	If QRYEMP->EMPENHO > 0
		nEmp99 := QRYEMP->EMPENHO
	Endif

	DBCLOSEAREA("QRYEMP")
	RestArea(_xAlias)

Return(nEmp99)

/*-------------------------------------------------------------+
| Funcao: HQEMPB2C | Autor : RBorges    | Data: 13/11/2017     |
+--------------------------------------------------------------+
|Descri็ใo: Verificar quantidade empenhada do produto MP       |
|           Consolidada.			                           |
+--------------------------------------------------------------+
|Uso: Health Quality - Fun็ใo F5 Cadastro de Produtos          |
+--------------------------------------------------------------*/

User Function HQEMPB2C(_cProduto)

	Local nEmp99 := 0
	Local QRY1     := ""
	Local _cLocal  := "99"
	Local _xAlias  := GetArea()

	QRY1 := "SELECT "
	QRY1 += " SUM(B2_QEMP) AS EMPENHO "
	QRY1 += " FROM " + RetSQLName("SB2")
	QRY1 += " WHERE B2_FILIAL IN ('01','02') "
	QRY1 += " AND B2_COD = '"+_cProduto + "'"
	//QRY1 += " AND B2_LOCAL = '"+_cLocal +"'"
	QRY1 += " AND "  + RetSQLName("SB2")+".D_E_L_E_T_ = ' '"
	QRY1 += " GROUP BY B2_COD "

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
	TcQuery QRY1 NEW ALIAS "QRYEMP" // ABRE UMA WORKAREA COM O RESULTADO DA QUERY

	DbSelectArea("QRYEMP")

	If QRYEMP->EMPENHO > 0
		nEmp99 := QRYEMP->EMPENHO
	Endif

	DBCLOSEAREA("QRYEMP")
	RestArea(_xAlias)

Return(nEmp99)

User Function DipCIFxUF()
	Local _lRet := .T.

	If M->C5_TPFRETE=="C" .And. M->C5_ESTE$GetNewPar("ES_UFBLCIF","PA/RO") .And. !M->C5_NUM$GetNewPar("ES_UFLICIF","")
		Aviso("ES_UFBLCIF","Frete CIF nใo permitido para esta UF ("+M->C5_ESTE+").",{"Ok"},1)
		_lRet := .F.
	EndIf

Return _lRet

/*-------------------------------------------------------------+
| Funcao: GRPVEN() | Autor : RBorges    | Data: 11/01/2018     |
+--------------------------------------------------------------+
|Descri็ใo: Usuแrios com permissใo para alterar o grupo de     |
|           Clientes.				                           |
+--------------------------------------------------------------+
|Uso: Dipromed - X3_WHEN A1_GRPVEN                             |
+--------------------------------------------------------------*/

User Function GRPVEN() // U_GRPVEN()

	Local _lRet     := .T.
	Local _cUsuario := U_DipUsr()
	Local _cUsuAut  := GetNewPar("ES_GRPVEN","MCANUTO/PMENDONCA/BRODRIGUES")

	If cEmpant <> "04"
		If ! Upper(_cUsuario) $ Upper(_cUsuAut)
			_lRet := .F.
		EndIf
	EndIf

Return (_lRet)
/*-------------------------------------------------------------+
| Funcao: VldArqHQ | Autor :            | Data: 13/11/2017     |
+--------------------------------------------------------------+
|Descri็ใo:			              		|                      |
+--------------------------------------------------------------+
|Uso: 													       |
+--------------------------------------------------------------*/
User Function VldArqHQ()
	Local lRet := .T.

	If Type("mv_par05")<>"U" .And. AllTrim(mv_par05)=="341"
		If cEmpAnt=="01"
			lRet := ("ITAU_C_3.REM"$Upper(mv_par03))
			If !lRet
				MsgInfo("Arquivo de configura็ใo ITAฺ invแlido."+CHR(13)+CHR(10)+"Para DIPROMED utilize o arquivo: ITAU_C_3.REM")
			EndIf
		ElseIf cEmpAnt=="04"
			lRet := ("ITAU_C_HQ.REM"$Upper(mv_par03))
			If !lRet
				MsgInfo("Arquivo de configura็ใo ITAฺ invแlido."+CHR(13)+CHR(10)+"Para HQ utilize o arquivo: ITAU_C_HQ.REM")
			EndIf
		EndIf
	EndIf

Return lRet
/*-------------------------------------------------------------+
| Funcao: DipVldZZX| Autor :            | Data: 13/11/2017     |
+--------------------------------------------------------------+
|Descri็ใo:			              		|                      |
+--------------------------------------------------------------+
|Uso: 													       |
+--------------------------------------------------------------*/
User Function DipVldZZX(cCNPJ)
	Local lRet := .F.
	Local aArea := GetArea()

	ZZX->(dbSetOrder(2))
	If ZZX->(dbSeek(xFilial("ZZX")+cCNPJ)) .And. ZZX->ZZX_HABILI=="1"
		lRet := .T.
	EndIf

	RestArea(aArea)
	Return lRet

	/*
	+---------------------------------------------------------------------+
	| RBORGES Data: 24/07/2018                                            |
	+---------------------------------------------------------------------+
	| FUNวรO: VALPED()                                                    |
	+---------------------------------------------------------------------+
	| DESCRIวรO: Essa fun็ใo enviarแ e-mail para os usuแrios contidos no  |
	| parโmetro, quando o valor do pedido for superior a 20 mil.          |
	+---------------------------------------------------------------------+
	|USO: Dipromed - Diretoria e Comercial                                |
	+---------------------------------------------------------------------+
	*/

	#INCLUDE "RWMAKE.CH"
	#INCLUDE 'PROTHEUS.CH'
	#INCLUDE 'PARMTYPE.CH'
	#INCLUDE "AP5MAIL.CH"
	#INCLUDE "TBICONN.CH"

User Function VALPED(_cPedid)

	Local _xArea   := GetArea()
	Local cQRY1    := ""
	Local cCodVend := ""
	Local cNomVend := ""
	Local cCodCli  := ""
	Local cNomCli  := ""
	Local nValor   := 0

	cQRY1 := " SELECT C5_NUM, "
	cQRY1 += " C5_VEND1, UPPER((SELECT A3_NOME FROM "+RetSqlName("SA3")+" WHERE A3_COD = C5_VEND1 AND D_E_L_E_T_ =  '')) NOME_VEND, "
	cQRY1 += " C5_CLIENTE, (SELECT A1_NOME FROM "+RetSqlName("SA1")+" WHERE A1_COD = C5_CLIENTE AND D_E_L_E_T_ =  '') NOME_CLI, "
	cQRY1 += " (SELECT SUM(C9_QTDVEN*C9_PRCVEN) SOMA FROM "+RetSqlName("SC9")+" WHERE C9_FILIAL = '"+xFilial("SC9")+"' AND C9_PEDIDO = '"+C5_NUM+"' AND C9_QTDVEN > 0 AND C9_QTDORI > 0 AND C9_NFISCAL = '' AND D_E_L_E_T_ = '') AS VALOR_TOTAL "
	cQRY1 += " 	FROM "+RetSQLName("SC5")+" SC5, "+RetSqlName('SC6')+" SC6, "
	cQRY1 += " WHERE "
	cQRY1 += " C5_FILIAL  = '"+xFilial("SC5")+"' AND "
	cQRY1 += " C5_NUM     = '"+_cPedid+"' AND   "
	cQRY1 += " C5_TIPO    = 'N'        AND "
	cQRY1 += " C5_LIBEROK = 'S'        AND "
	cQRY1 += " C5_PRENOTA IN (' ','F') AND "
	//cQRY1 += " C5_NOTA    = ''         AND "
	cQRY1 += " C6_FILIAL  = C5_FILIAL  AND "
	cQRY1 += " C6_NUM     = C5_NUM     AND "
	cQRY1 += " C6_CLI     = C5_CLIENTE AND "
	cQRY1 += " C6_LOJA    = C5_LOJACLI AND "
	cQRY1 += " SC5.D_E_L_E_T_ = ''     AND "
	cQRY1 += " SC6.D_E_L_E_T_ = '' "
	cQRY1 += " GROUP BY C5_NUM, C5_VEND1, C5_CLIENTE HAVING (SELECT SUM(C9_QTDVEN*C9_PRCVEN) SOMA FROM "+RetSqlName("SC9")+" WHERE C9_FILIAL = '"+xFilial("SC9")+"' AND C9_PEDIDO = '"+C5_NUM+"' AND C9_QTDVEN > 0 AND C9_QTDORI > 0 AND C9_NFISCAL = '' AND D_E_L_E_T_ = '') >= 20000 "

	cQRY1 := ChangeQuery(cQRY1)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQRY1),"QRY1C5",.T.,.T.)

	If !QRY1C5->(Eof())

		cCodVend := QRY1C5->C5_VEND1
		cNomVend := QRY1C5->NOME_VEND
		cCodCli  := QRY1C5->C5_CLIENTE
		cNomCli  := QRY1C5->NOME_CLI
		nValor   := QRY1C5->VALOR_TOTAL

		VPEDMAIL(QRY1C5->C5_NUM, cCodVend, cNomVend, cCodCli, cNomCli, nValor) //Chamada da fun็ใo que dispara o e-mail

		QRY1C5->(DbSkip())

	EndIf

	QRY1C5->(dbCloseArea())

	RestArea(_xArea)

	Return

	/*
	+--------------------------------------------------------------------+
	|RBORGES - 24/07/2018                                                |
	+--------------------------------------------------------------------+
	|Funcao para dispar o E-mail         						         |
	+--------------------------------------------------------------------+
	*/

	*--------------------------------------------------------------------*
Static Function VPEDMAIL(_cPedido, cCodVend, cNomVend, cCodCli, cNomCli, nValor)
	*--------------------------------------------------------------------*

	Local cDeIc       := "protheus@dipromed.com.br"
	Local cEmailIc    := GetNewPar("ES_VLPEMAI","patricia.mendonca@dipromed.com.br;reginaldo.borges@dipromed.com.br")  //Usuแrios que receberใo e-mails
	Local cAssuntoIc  := "AVISO - PEDIDO COM VALOR SUPERIOR A 20 MIL, "+AllTrim(_cPedido)+ "! "
	Local cAttachIc   :=  "  a"
	Local cFuncSentIc :=   "VALPED_FUNCOES"

	_aMsgIc := {}

	aAdd( _aMsgIc , { "PEDIDO        ", +_cPedido})
	aAdd( _aMsgIc , { "COD. VENDEDOR ", +cCodVend})
	aAdd( _aMsgIc , { "NOME VENDEDOR ", +cNomVend})
	aAdd( _aMsgIc , { "COD. CLIENTE  ", +cCodCli})
	aAdd( _aMsgIc , { "NOME CLIENTE  ", +cNomCli})
	aAdd( _aMsgIc , { "VALOR PEDIDO  ", +Transform(nValor,"@EZ 999,999,999.99")})

	If GetNewPar("ES_ATIVJOB",.T.)
		U_UEnvMail(cEmailIc,cAssuntoIc,_aMsgIc,cAttachIc,cDeIc,cFuncSentIc)
	EndIf

	Return()

	/*
	+--------------------------------------------------------------------+
	|RLOPES - 28/08/2018                                                 |
	+--------------------------------------------------------------------+
	|Funcao para valida็ใo do CEP - Cadastro de Clientes		         |
	+--------------------------------------------------------------------+
	*/
	#INCLUDE "RWMAKE.CH"
	#INCLUDE 'PROTHEUS.CH'

User Function ValidA1CEP()

	Local lRet := .T.

	If ISINCALLSTACK("LOJA901A") .Or. ISINCALLSTACK("LOJA901")
		lRet := .T.
	Elseif LEN(ALLTRIM(M->A1_CEPC)) < 8
		MsgInfo("CEP Incorreto, favor validar.")
		lRet := .F.
	Endif

	Return lRet

	/*
	+--------------------------------------------------------------------+
	|RLOPES - 28/08/2018                                                 |
	+--------------------------------------------------------------------+
	|Funcao para valida็ใo do Telefone - Cadastro de Clientes	         |
	+--------------------------------------------------------------------+
	*/
	#INCLUDE "RWMAKE.CH"
	#INCLUDE 'PROTHEUS.CH'

User Function ValidA1Tel()

	Local lRet := .T.

	If ISINCALLSTACK("LOJA901A") .Or. ISINCALLSTACK("LOJA901")
		lRet := .T.
	Elseif LEN(ALLTRIM(M->A1_TEL)) < 8
		MsgInfo("Telefone Incorreto, favor validar.")
		lRet := .F.
	Endif

Return lRet

/*-------------------------------------------------------------+
| Funcao: SALDECOM | Autor : RBORGES   |  Data: 18/09/2017     |
+--------------------------------------------------------------+
|Descri็ใo: Verificar saldo do produto no estoque 09.          |
|           Cosulta chamada da fun็ใo F5.                      |
+--------------------------------------------------------------*/

User Function SALDECOM(_cProduto,_cLocal)

	Local nEstoq20 := 0
	Local QRY1     := ""
	Local _xAlias  := GetArea()
	DEFAULT _cLocal  := "09"

	QRY1 := "SELECT "
	QRY1 += " SUM((B2_QATU-B2_QACLASS-B2_QEMP)) AS ESTOQUE "
	QRY1 += " FROM " + RetSQLName("SB2")

	If cEmpAnt == '01'
		QRY1 += " WHERE B2_FILIAL IN ('01','04') "
	Else
		QRY1 += " WHERE B2_FILIAL IN ('01','02') "
	EndIf

	QRY1 += " AND B2_COD = '"+_cProduto + "'"
	QRY1 += " AND B2_LOCAL = '"+_cLocal +"'"
	QRY1 += " AND "  + RetSQLName("SB2")+".D_E_L_E_T_ = ' '"
	QRY1 += " GROUP BY B2_COD "

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
	TcQuery QRY1 NEW ALIAS "QRY1SB2" // ABRE UMA WORKAREA COM O RESULTADO DA QUERY

	DbSelectArea("QRY1SB2")

	If QRY1SB2->ESTOQUE > 0
		nEstoq20 := QRY1SB2->ESTOQUE
	Endif

	DBCLOSEAREA("QRY1SB2")
	RestArea(_xAlias)

Return(nEstoq20)

/*-------------------------------------------------------------+
| Funcao: MA040VLD | Autor : RLOPES	   |  Data: 07/01/2019     |
+--------------------------------------------------------------+
|Descri็ใo: Valida usuario para inclusใo, altera็ใo e exclusใo |
|           no cadastro de vendedores						   |
+--------------------------------------------------------------*/

User Function MA040VLD()

	Local _nOpc := PARAMIXB     //3- Inclusใo, 4- Altera็ใo e 5- Exclusใo
	Local _lRet := .T.
	Local _cUsuario := upper(U_DipUsr())
	Local _cUsuAut  := GetNewPar("ES_CADVEN","MCANUTO/PMENDONCA/RBORGES/RLOPES")

	If 		_nOpc == 3 .And. _cUsuario $ _cUsuAut
		_lRet := .T.
	ElseIf 	_nOpc == 4 .And. _cUsuario $ _cUsuAut
		_lRet := .T.
	ElseIf 	_nOpc == 5 .And. _cUsuario $ _cUsuAut
		_lRet := .T.
	Else
		MsgAlert("Usuแrio nใo pode efetuar essa opera็ใo, favor falar com o TI.","ES_CADVEN")
		_lRet := .F.
	EndIf

Return _lRet

/*==========================================================================\
|Programa  | ENV_SZG | Autor | Reginaldo Borges   |      Data ณ 11/02/2019  |
|===========================================================================|
|Desc.     | Envio de EMail dos campos alterados no cadastro de clientes.   |
|===========================================================================|
|Sintaxe   | ENV_SZG                                                        |
|===========================================================================|
|Uso       | Especifico DIPROMED                                            |
\==========================================================================*/

Static Function ENV_SZG(aEnv_SZG,cEmail,cAssunto)

	Local cAccount  := Lower(Alltrim(GetMv("MV_RELACNT")))
	Local cFrom     := Lower(Alltrim(GetMv("MV_RELACNT")))
	Local cPassword := Alltrim(GetMv("MV_RELPSW"))
	Local cServer   := Alltrim(GetMv("MV_RELSERV"))
	Local cEmailTo  := cEmail
	Local cEmailCc  := ""
	Local cEmailBcc := ""
	Local lResult   := .F.
	Local cError    := ""
	Local cMsg      := ""
	Local lSmtpAuth := GetNewPar("MV_RELAUTH",.F.)
	Local lAutOk	:= .F.
	Local CATTACH   := "a"
	Local nI

	/*=============================================================================*/
	/*Definicao do cabecalho do email                                              */
	/*=============================================================================*/
	cMsg := ""
	cMsg += '<html>'
	cMsg += '<head>'
	cMsg += '<title>' +cAssunto+ '</title>'
	cMsg += '</head>'
	cMsg += '<body>'
	cMsg += '<HR Width=100% Size=3 Align=Centered Color=Red><P>'
	cMsg += '<Table Align=Center BorderColor=#000000 CELLPADDING=4 CELLSPACING=0 Width=100%>'

	cMsg += '<table width="100%">'
	cMsg += '<tr>'
	cMsg += '<td width="100%" align="center"><font size="4" color="red">' +DecodeUTF8(cAssunto, "cp1252")+'</font></td>'
	cMsg += '</tr>'
	cMsg += '</table>'

	cMsg += '<hr width="100%" size="3" align="center" color="#000000">'

	cMsg += '<table width="100%" cellspacing="0" cellpadding="0"><font size="3" >'
	cMsg += '<tr>'
	cMsg += '<td Width="6%"  Align="LEFT"  ><B>Data</B></td>'
	cMsg += '<td Width="8%"  Align="LEFT"  ><B>Campo</B></td>'
	cMsg += '<td Width="38%" Align="LEFT"  ><B>Antes</B></td>'
	cMsg += '<td Width="38%" Align="LEFT"  ><B>Depois</B></td>'
	cMsg += '<td Width="10%" Align="LEFT"  ><B>Usuario</B></td>'
	cMsg += '</tr>'
	cMsg += '</font></table>'

	cMsg += '<hr width="100%" size="2" align="center" color="#000000">'

	For nI := 1 to Len(aEnv_SZG)

		nLin := nI

		If Mod(nLin,2) == 0

			cMsg += '<table width="100%" border="0" cellspacing="0" cellpadding="0">'
			cMsg += '<tr bgcolor="#F8F8FF">'
			cMsg += '<td width="6%  " Align="Left"><font  size="2">'+DTOC(aEnv_SZG[nLin,1])+ '</font></td>'
			cMsg += '<td width="8%  " Align="Left"><font  size="2">'+aEnv_SZG[nLin,2]+ '</font></td>'
			cMsg += '<td width="38% " Align="Left"><font  size="2" color="Blue">'+aEnv_SZG[nLin,3]+'</font></td>'
			cMsg += '<td width="38% " Align="Left"><font  size="2" color="Blue">'+aEnv_SZG[nLin,4]+'</font></td>'
			cMsg += '<td width="10%  " Align="Left"><font  size="2">'+aEnv_SZG[nLin,5]+ '</font></td>'
			cMsg += '</tr>'
			cMsg += '</table>'

		Else

			cMsg += '<table width="100%" border="0" cellspacing="0" cellpadding="0">'
			cMsg += '<tr bgcolor="#CCCCCC">'
			cMsg += '<td width="6%  " Align="Left"><font  size="2">'+DTOC(aEnv_SZG[nLin,1])+ '</font></td>'
			cMsg += '<td width="8%  " Align="Left"><font  size="2">'+aEnv_SZG[nLin,2]+ '</font></td>'
			cMsg += '<td width="38% " Align="Left"><font  size="2" color="Blue">'+aEnv_SZG[nLin,3]+'</font></td>'
			cMsg += '<td width="38% " Align="Left"><font  size="2" color="Blue">'+aEnv_SZG[nLin,4]+'</font></td>'
			cMsg += '<td width="10%  " Align="Left"><font  size="2">'+aEnv_SZG[nLin,5]+ '</font></td>'
			cMsg += '</tr>'
			cMsg += '</table>'

		EndIf

		nLin  += 1

	Next

	cMsg += '<table width="100%" cellspacing="0" cellpadding="0"><font size="2" color="blue">'
	cMsg += '<tr>'
	cMsg += '<td>==========================================================================================================================================================================================</td>'
	cMsg += '</tr>'
	cMsg += '</font></table>'

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Definicao do rodape do email                                                ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	cMsg += '</Table>'
	cMsg += '<HR Width=100% Size=3 Align=Centered Color=Red> <P>'
	cMsg += '<table width="100%" Align="Center" border="0">'
	cMsg += '<tr align="center">'
	cMsg += '<td colspan="10"><font color="BLUE" size="2">Mensagem enviada automaticamente pelo sistema PROTHEUS - <font color="BLUE" size="1">(GravaZG(FUNCOES).PRW)</td>'
	cMsg += '</tr>'
	cMsg += '</table>'
	cMsg += '</body>'
	cMsg += '</html>'

	/*
	CONNECT SMTP SERVER cServer ACCOUNT cAccount PASSWORD cPassword RESULT lResult

	If !lAutOk
	If ( lSmtpAuth )
	lAutOk := MailAuth(cAccount,cPassword)
	Else
	lAutOk := .T.
	EndIf
	EndIf

	If lResult .And. lAutOk
	SEND MAIL FROM cFrom ;
	TO      	Lower(cEmailTo);
	CC      	Lower(cEmailCc);
	BCC     	Lower(cEmailBcc);
	SUBJECT 	cAssunto;
	BODY    	cMsg;
	ATTACHMENT  cAttach;
	RESULT lResult

	If !lResult
	//Erro no envio do email
	GET MAIL ERROR cError

	MsgInfo(cError,OemToAnsi("Atencao"))
	EndIf

	DISCONNECT SMTP SERVER
	Else
	//Erro na conexao com o SMTP Server
	GET MAIL ERROR cError

	MsgInfo(cError,OemToAnsi("Atencao"))
	EndIf
	*/

	If GetNewPar("ES_ATIVJOB",.T.)
		u_UEnvMail(AllTrim(cEmailTo),cAssunto,nil,"",cFrom,"ENV_SZG(FUNCOES.prw)",cMsg)
	EndIf

Return(.T.)
/*-------------------------------------------------------------+
| Funcao: GDToExcel | Autor : DELTA	   |  Data: 06/05/2020     |
+--------------------------------------------------------------+
|Descri็ใo: Gera Excel 										   |
+--------------------------------------------------------------*/
User Function GDToExcel(aHeader,aCols,cWorkSheet,cTable,lTotalize,lPicture)

Local oFWMSExcel := FWMSExcel():New()

Local oMsExcel

Local aCells

Local cType
Local cColumn

Local cFile
Local cFileTMP

Local cPicture

Local lTotal

Local nRow
Local nRows
Local nField
Local nFields

Local nAlign
Local nFormat

Local uCell

DEFAULT cWorkSheet := "GETDADOS"
DEFAULT cTable := cWorkSheet
DEFAULT lTotalize := .T.
DEFAULT lPicture := .F.

BEGIN SEQUENCE

	oFWMSExcel:AddworkSheet(cWorkSheet)
	oFWMSExcel:AddTable(cWorkSheet,cTable)
	
	nFields := Len( aHeader )
	For nField := 1 To nFields
		cType := aHeader[nField][2]
		nAlign := IF(cType=="C",1,IF(cType=="N",3,2))
		nFormat := IF(cType=="D",4,IF(cType=="N",2,1))
		cColumn := aHeader[nField][1]
		lTotal := ( lTotalize .and. cType == "N" )
		oFWMSExcel:AddColumn(@cWorkSheet,@cTable,@cColumn,@nAlign,@nFormat,@lTotal)
	Next nField
	
	aCells := Array(nFields)
	
	nRows := Len( aCols )
	For nRow := 1 To nRows
		For nField := 1 To nFields
			uCell := aCols[nRow][nField]
			IF ( lPicture )
				cPicture := aHeader[nField][3]
				IF .NOT.( Empty(cPicture) )
					uCell := Transform(uCell,cPicture)
				EndIF
			EndIF
			aCells[nField] := uCell
		Next nField
		oFWMSExcel:AddRow(@cWorkSheet,@cTable,aClone(aCells))
	Next nRow
	
	oFWMSExcel:Activate()
	
	cFile := ( CriaTrab( NIL, .F. ) + ".xml" )
	
	While File( cFile )
		cFile := ( CriaTrab( NIL, .F. ) + ".xml" )
	End While
	
	oFWMSExcel:GetXMLFile( cFile )
	oFWMSExcel:DeActivate()
	
	IF .NOT.( File( cFile ) )
		cFile := ""
		BREAK
	EndIF
	
	cFileTMP := ( GetTempPath() + cFile )
	IF .NOT.( __CopyFile( cFile , cFileTMP ) )
		fErase( cFile )
		cFile := ""
		BREAK
	EndIF
	
	fErase( cFile )
	
	cFile := cFileTMP
	
	IF .NOT.( File( cFile ) )
		cFile := ""
		BREAK
	EndIF
	
	IF .NOT.( ApOleClient("MsExcel") )
		BREAK
	EndIF
	
	oMsExcel := MsExcel():New()
	oMsExcel:WorkBooks:Open( cFile )
	oMsExcel:SetVisible( .T. )
	oMsExcel := oMsExcel:Destroy()

END SEQUENCE

oFWMSExcel := FreeObj( oFWMSExcel )

Return( cFile )

/*-------------------------------------------------------------+
| Funcao: fRepEnd | Autor : Andre Mendes| Data: 05/08/2021     |
+--------------------------------------------------------------+
|Descri็ใo: Completar e replicar os enderecos obtidos Machups  |
+--------------------------------------------------------------+
|Uso: Dipromed - deve ser chado por gatinho                    |
+--------------------------------------------------------------*/
User Function fRepEnd()
	Local _cRet   := &(ReadVar())
	Local _xArea  := GetArea()
	Local _cCodMun := CriaVar("A1_COD_MUN")
	Local _cMun := CriaVar("A1_MUN")
	Local _cEst := CriaVar("A1_EST")
	Local _cEnd := CriaVar("A1_END")
	Local _cBairro := CriaVar("A1_BAIRRO")
	Local _cNum := Space(10)
	Local _cCep := CriaVar("A1_CEP")
	
	

	_cMun := FwNoAccent(UPPER(M->A1_MUN))
	_cEst := M->A1_EST
	_cCodMun := fRetCM(_cMun, _cEst)
	_cEnd := UPPER(M->A1_END)
	_cBairro := UPPER(M->A1_BAIRRO)
	_cNum := Space(10)
	_cCep := M->A1_CEP

	_cRet := _cMun
	

	@ 000,000 TO 310,400 DIALOG oDlg TITLE "Atualizacao de Endereco"

	@ 010,010 SAY "Logradouro:"
	@ 010,044 GET _cEnd PICTURE "@!" ValID !Empty(_cEnd) Size 140,020

	@ 025,010 SAY "Numero:"
	@ 025,044 GET _cNum PICTURE "@!" ValID !Empty(_cNum) Size 100,020

	@ 040,010 SAY "Bairro:"
	@ 040,044 GET _cBairro PICTURE "@!"	Size 140,020

	@ 055,010 SAY "Cod. Munic.:"
	@ 055,044 GET _cCodMun    PICTURE "@!"	When .F. Size 140,020

	@ 070,010 SAY "Municipio:"
	@ 070,044 GET _cMun    PICTURE "@!"	When .F. Size 140,020

	@ 085,010 SAY "Estado:"
	@ 085,044 GET _cEst    PICTURE "@!" When .F. Size 20,020 

	@ 100,010 SAY "CEP:"
	@ 100,044 GET _cCep    PICTURE "@!" When .F. Size 20,020 

	@ 120,130 BMPBUTTON TYPE 1 ACTION (_cEsc := .T., Close(oDlg))
	@ 120,160 BMPBUTTON TYPE 2 ACTION (_cEsc := .F., Close(oDlg))

	ACTIVATE DIALOG oDlg CENTER



	IF _cEsc

		M->A1_END := Alltrim(_cEnd) + ", " +_cNum+SPACE(60-LEN(Alltrim(_cEnd) + ", " +_cNum))
		M->A1_COD_MUN := _cCodMun
		M->A1_BAIRRO := _cBairro+SPACE(30-LEN(_cBairro))


		M->A1_ENDCOB := Alltrim(_cEnd) + ", " +_cNum+SPACE(60-LEN(Alltrim(_cEnd) + ", " +_cNum))
		M->A1_BAIRROC:= _cBairro+SPACE(30-LEN(_cBairro))
		M->A1_MUNC   := _cMun+SPACE(30-LEN(_cMun))
		M->A1_ESTC   := _cEst
		M->A1_CEPC	 := _cCep

		M->A1_ENDENT := Alltrim(_cEnd) + ", " +_cNum+SPACE(60-LEN(Alltrim(_cEnd) + ", " +_cNum))
		M->A1_BAIRROE:= _cBairro+SPACE(30-LEN(_cBairro))
		M->A1_MUNE   := _cMun+SPACE(30-LEN(_cMun))
		M->A1_ESTE   := _cEst
		M->A1_CEPE	 := _cCep
	EndIf

	RestArea(_xArea)

Return (_cRet)

/*-------------------------------------------------------------+
| Funcao: fRetCM | Autor : Andre Mendes| Data: 05/08/2021     |
+--------------------------------------------------------------+
|Descri็ใo: Obtem o codigo do municipio pela descricao e estado|
+--------------------------------------------------------------+
|Uso: Dipromed - utilizado na funcao a  fRetCM                 |
+--------------------------------------------------------------*/
Static Function fRetCM(cMun, cEst)

Local aArea := GetArea()
Local cRet := ""
Local cAlias := GetNextAlias() 


cQuery := "SELECT  " + CRLF
cQuery += "		CC2_CODMUN " + CRLF
cQuery += "FROM  " + CRLF
cQuery += "	"+RetSqlName("CC2")+" CC2 " + CRLF
cQuery += "WHERE " + CRLF
cQuery += "	CC2.D_E_L_E_T_= '' " + CRLF
cQuery += "AND UPPER(CC2_MUN) = UPPER('"+cMun+"') " + CRLF
cQuery += "AND CC2_EST = '"+cEst+"' " + CRLF

cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.T.,.T.)

DbSelectArea(cAlias)
While !Eof()

	cRet := CC2_CODMUN	

	dbSkip()
End
DbCloseArea()
               

RestArea(aArea)
Return cRet


/*-------------------------------------------------------------+
| Funcao: fCplEnd | Autor : Andre Mendes| Data: 12/08/2021     |
+--------------------------------------------------------------+
|Descri็ใo: Completar os enderecos obtidos Machups no SA2      |
+--------------------------------------------------------------+
|Uso: Dipromed - deve ser chado por gatinho                    |
+--------------------------------------------------------------*/
User Function fCplEnd()
	Local _cRet   := &(ReadVar())
	Local _xArea  := GetArea()
	Local _cCodMun := CriaVar("A2_COD_MUN")
	Local _cMun := CriaVar("A2_MUN")
	Local _cEst := CriaVar("A2_EST")
	Local _cEnd := CriaVar("A2_END")
	Local _cBairro := CriaVar("A2_BAIRRO")
	Local _cNum := Space(10)
	Local _cCep := CriaVar("A2_CEP")
	Local _cEndCpo
	Local _cBairroCpo
	
	If !Empty(M->A2_COD_MUN)
		Return _cRet
	Endif
	Private oModelSA2    := FWModelActive()

	_cMun := FwNoAccent(UPPER(M->A2_MUN))
	_cEst := M->A2_EST
	_cCodMun := fRetCM(_cMun, _cEst)
	_cEnd := UPPER(M->A2_END)
	_cBairro := UPPER(M->A2_BAIRRO)
	_cNum := Space(10)
	_cCep := M->A2_CEP

	_cRet := _cMun
	

	@ 000,000 TO 310,400 DIALOG oDlg TITLE "Atualizacao de Endereco"

	@ 010,010 SAY "Logradouro:"
	@ 010,044 GET _cEnd PICTURE "@!" ValID !Empty(_cEnd) Size 140,020

	@ 025,010 SAY "Numero:"
	@ 025,044 GET _cNum PICTURE "@!" ValID !Empty(_cNum) Size 100,020

	@ 040,010 SAY "Bairro:"
	@ 040,044 GET _cBairro PICTURE "@!"	Size 140,020

	@ 055,010 SAY "Cod. Munic.:"
	@ 055,044 GET _cCodMun    PICTURE "@!"	When .F. Size 140,020

	@ 070,010 SAY "Municipio:"
	@ 070,044 GET _cMun    PICTURE "@!"	When .F. Size 140,020

	@ 085,010 SAY "Estado:"
	@ 085,044 GET _cEst    PICTURE "@!" When .F. Size 20,020 

	@ 100,010 SAY "CEP:"
	@ 100,044 GET _cCep    PICTURE "@!" When .F. Size 20,020 

	@ 120,130 BMPBUTTON TYPE 1 ACTION (_cEsc := .T., Close(oDlg))
	@ 120,160 BMPBUTTON TYPE 2 ACTION (_cEsc := .F., Close(oDlg))

	ACTIVATE DIALOG oDlg CENTER



	IF _cEsc
		_cEndCpo := Alltrim(_cEnd) + ", " +_cNum+SPACE(60-LEN(Alltrim(_cEnd) + ", " +_cNum))
		oModelSA2:SetValue("SA2MASTER","A2_END",AllTrim(_cEndCpo))
		_cBairroCpo := _cBairro+SPACE(30-LEN(_cBairro))
		oModelSA2:SetValue("SA2MASTER","A2_BAIRRO",AllTrim(_cBairroCpo))

		oModelSA2:SetValue("SA2MASTER","A2_COD_MUN",AllTrim(_cCodMun))
		


	EndIf

	RestArea(_xArea)

Return (_cRet)


/*-------------------------------------------------------------+
| Funcao: fCplEnd | Autor : Andre Mendes| Data: 12/08/2021     |
+--------------------------------------------------------------+
|Descri็ใo: Completar os enderecos obtidos Machups no SA2      |
+--------------------------------------------------------------+
|Uso: Dipromed - deve ser chado por gatinho                    |
+--------------------------------------------------------------*/
User Function fRegAnv()

	FwFldPut("F2Q_CODANV",IIf(IsDigit(FwFldGet("B1_REG_ANV")),PadL(alltrim(FwFldGet("B1_REG_ANV")),13,"0"),alltrim(FwFldGet("B1_REG_ANV"))))

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณVldProFrt บAutor  Rafael Moraes Rosa   บ Data ณ  24/04/23   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ  Realizar o tratamento da promocao de fretes para clientes บฑฑ
ฑฑบ          ณ  especificos, bem como o tipo de frete e estado da venda.  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function VldProFrt(cPedido,cAlias)
	
	Local aArea 	:= GetArea()
	Local lRet 		:= .F.
	DEFAULT cAlias  := "SC5"

	SA1->(dbSetOrder(1))
	If SA1->(dbSeek(xFilial("SA1")+&(cAlias+"->C5_CLIENTE")))

		//Rafael Moraes Rosa - 24/03/2023 - INICIO
		//IF &(cAlias+"->C5_TPFRETE") = "C" .AND. SA1->A1_EST = "SP" .AND. SA1->A1_TIPO = "R"
		IF &(cAlias+"->C5_TPFRETE") $ GetNewPar("MV_#PFRTTF","") .AND.;
			SA1->A1_EST $ GetNewPar("MV_#PFRTEC","") .AND. ;
			SA1->A1_TIPO $ GetNewPar("MV_#PFRTTC","") .AND.;
			DATE() >= CTOD(GetNewPar("MV_#PFRTDD","")) .AND. DATE() <= CTOD(GetNewPar("MV_#PFRTDA",""))
				lRet	:= .T.
		ENDIF
		//Rafael Moraes Rosa - 24/03/2023 - FIM
	ENDIF
	RestArea(aArea)

Return lRet

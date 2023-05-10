#Include "RwMake.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ DIPM002  º Autor ³   Alexandro Dias   º Data ³  15/08/01   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Importacao do cadastro de produtos.                        º±±
±±º          ³ Importacao do consumo medio dos produtos.                  º±±
±±º          ³ Importacao do saldo inicial dos produtos.                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function DIPM002()
U_DIPPROC(ProcName(0),U_DipUsr()) // JBS 05/10/2005 - Gravando o nome do Programa no SZU
Processa({|| ProcProd() })
Return

Static Function ProcProd()

Local _nTotReg := 0
Local _nRegAtu := 0

Do While .T.
	
	IF File("\APO\PRV1.DBF")
		DbUseArea (.T.,, "\APO\PRV1.DBF","INFOPRO", .T., .T. )
		If Select ("INFOPRO") == 0
			MsgBox("Nao foi possivel abrir o arquivo de Observacao do Produto!!!","Atencao","INFO")
			Return( Nil )
		Else
			_cIndINFO := CriaTrab(nil,.f.)
			DbSelectArea("INFOPRO")
			IndRegua("INFOPRO",_cIndINFO,"INFOPRO->COD",,,"Criando Indice...")
			DbGotop()
		Endif
	Else
		MsgBox("O Arquivo de Observacao do Produto nao esta no Diretorio !!!","Atencao","INFO")
		Return( Nil )
	EndIF
	
	IF File("\APO\PRV1.DBF")
		DbUseArea (.T.,, "\APO\PRV1.DBF","TRB", .T., .T. )
		If Select ("TRB") == 0
			MsgBox("Nao foi possivel abrir o arquivo de Produtos !!!","Atencao","INFO")
			Return( Nil )
		Endif
	Else
		MsgBox("O Arquivo de Produtos nao esta no Diretorio !!!","Atencao","INFO")
		Return( Nil )
	EndIF
	
	Exit
	
Enddo

_nTotReg := RecCount()

DbGoTop()

ProcRegua(_nTotReg)

While !TRB->( Eof() )
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Importacao do cadastro de produtos.								 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea("SB1")
	DbSetOrder(1)
	
	IF Empty(TRB->COD)
		TRB->( Dbskip() )
		Loop
	EndIF
	
	_cCodigo := TRB->COD
		
	IF DbSeek( xFilial("SB1") + _cCodigo )
		
		Reclock("SB1",.F.)
	   		Replace B1_PRV1    WITH TRB->PRV1
	   		Replace B1_PRVPROM WITH TRB->PRVPROM
	   		Replace B1_PRVMINI WITH TRB->PRVMINI
	   		Replace B1_PRVSUPE WITH TRB->B1_PRVSUPE
		MsUnLock()
		
		/*/
	
		Reclock("SB1",.F.)
		Replace B1_DESC     WITH TRB->PRODUTO
		Replace B1_PRV1     WITH TRB->PRECOLISTA
		Replace B1_UPRC     WITH TRB->CUSTOENTRA
		Replace B1_PRVPROM  WITH TRB->PRECOPROMC
		Replace B1_PRVMINI  WITH TRB->PRECOMIN
		Replace B1_PRVSUPE  WITH TRB->SUPER
		Replace B1_UCOM     WITH TRB->DATAULTENT 
	  //	Replace B1_ORIGEM   WITH TRB->TR
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Importacao da Observacao do produto.							 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		IF Empty(B1_CODOBS)
			Replace B1_CODOBS   WITH ImportObs( LTRIM(STR(TRB->CODIGO)) )
		EndIF
		MsUnLock()
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Importacao do consumo medio dos produtos.						 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		DbSelectArea("SB3")
		DbSetOrder(1)
		
		IF DbSeek( xFilial("SB3") + _cCodigo )
			Reclock("SB3",.F.)
		Else
			Reclock("SB3",.T.)
		EndIF
		
		Replace B3_FILIAL WITH xFilial("SB1")
		Replace B3_COD    WITH _cCodigo
		
//		_cMes := StrZero(Month(dDatabase)-3,2)
		Replace B3_Q10 WITH TRB->QTDSAIDAM1
		
//		_cMes := StrZero(Month(dDatabase)-2,2)
		Replace B3_Q11 WITH TRB->QTDSAIDAM2
		
//		_cMes := StrZero(Month(dDatabase)-1,2)
		Replace B3_Q12 WITH TRB->QTDSAIDAM3
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Importacao do Saldo Inicial dos Produtos.						 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		DbSelectArea("SB9")
		DbSetOrder(1)
		
		IF DbSeek( xFilial("SB9") + _cCodigo )
			Reclock("SB9",.F.)
		Else
			Reclock("SB9",.T.)
		EndIF
		
		Replace B9_FILIAL WITH xFilial("SB9")
		Replace B9_COD    WITH _cCodigo
		Replace B9_LOCAL  WITH SB1->B1_LOCPAD
		Replace B9_QINI   WITH TRB->QTDTOTAL
		
		MsUnLock()    
		
		DbSelectArea("SBD")
		DbSetOrder(1)
		
		IF DbSeek( xFilial("SBD") + _cCodigo )
			Reclock("SBD",.F.)
		Else
			Reclock("SBD",.T.)
		EndIF
		
		Replace BD_FILIAL  WITH xFilial("SBD")
		Replace BD_PRODUTO WITH _cCodigo
		Replace BD_LOCAL   WITH SB1->B1_LOCPAD
		Replace BD_QINI    WITH TRB->QTDTOTAL
		
		MsUnLock()
		
	Else

		Reclock("SB1",.T.)
		Replace B1_FILIAL   WITH xFilial("SB1")
		Replace B1_COD      WITH _cCodigo
		Replace B1_DESC     WITH TRB->PRODUTO
		Replace B1_UM       WITH Substr(TRB->UNIDADE,1,2)
		Replace B1_TIPO     WITH "PA"
		Replace B1_LOCPAD   WITH "01"
		Replace B1_TS       WITH IIF(Empty(SB1->B1_TS),"501",SB1->B1_TS)
		Replace B1_TE       WITH IIF(Empty(SB1->B1_TE),"001",SB1->B1_TE)
		Replace B1_PESO     WITH TRB->PESO
		Replace B1_PICM     WITH IIF(SB1->B1_PICM<=0,18,SB1->B1_PICM)
		Replace B1_IPI      WITH TRB->IPI
		Replace B1_TIPE     WITH "D"
		Replace B1_FORPRZ   WITH ""
		Replace B1_ESTFOR   WITH "001"
		Replace B1_FORPRZ   WITH "002"
		Replace B1_PRV1     WITH TRB->PRECOLISTA
		Replace B1_UPRC     WITH TRB->CUSTOENTRA
		Replace B1_PRVPROM  WITH TRB->PRECOPROMC
		Replace B1_PRVMINI  WITH TRB->PRECOMIN
		Replace B1_PRVSUPE  WITH TRB->SUPER
		Replace B1_UCOM     WITH TRB->DATAULTENT
		Replace B1_ORIGEM   WITH TRB->TR
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Importacao da Observacao do produto.							 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		IF Empty(B1_CODOBS)
			Replace B1_CODOBS   WITH ImportObs( LTRIM(STR(TRB->CODIGO)) )
		EndIF
		
		DbSelectArea("SA2")
		DbOrderNickName("SA2NREDUZ")
		IF DbSeek(xFilial("SA2")+Alltrim(TRB->FORNECEDOR))
			DbSelectArea("SB1")
			Replace B1_PROC    WITH SA2->A2_COD
			Replace B1_LOJPROC WITH SA2->A2_LOJA
		EndIF
		
		MsUnlock()
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Importacao do consumo medio dos produtos.						 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		DbSelectArea("SB3")
		DbSetOrder(1)
		
		IF DbSeek( xFilial("SB3") + _cCodigo )
			Reclock("SB3",.F.)
		Else
			Reclock("SB3",.T.)
		EndIF
		
		Replace B3_FILIAL WITH xFilial("SB1")
		Replace B3_COD    WITH _cCodigo
		
//		_cMes := StrZero(Month(dDatabase)-3,2)
		Replace B3_Q10 WITH TRB->QTDSAIDAM1
		
//		_cMes := StrZero(Month(dDatabase)-2,2)
		Replace B3_Q11 WITH TRB->QTDSAIDAM2
		
 //		_cMes := StrZero(Month(dDatabase)-1,2)
		Replace B3_Q12 WITH TRB->QTDSAIDAM3
		
		MsUnLock()
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Importacao do Saldo Inicial dos Produtos.						 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		DbSelectArea("SB9")
		DbSetOrder(1)
		
		IF DbSeek( xFilial("SB9") + _cCodigo )
			Reclock("SB9",.F.)
		Else
			Reclock("SB9",.T.)
		EndIF
		
		Replace B9_FILIAL WITH xFilial("SB9")
		Replace B9_COD    WITH _cCodigo
		Replace B9_LOCAL  WITH SB1->B1_LOCPAD
		Replace B9_QINI   WITH TRB->QTDTOTAL
		
		MsUnLock() 
		
		DbSelectArea("SBD")
		DbSetOrder(1)
		
		IF DbSeek( xFilial("SBD") + _cCodigo )
			Reclock("SBD",.F.)
		Else
			Reclock("SBD",.T.)
		EndIF
		
		Replace BD_FILIAL  WITH xFilial("SBD")
		Replace BD_PRODUTO WITH _cCodigo
		Replace BD_LOCAL   WITH SB1->B1_LOCPAD
		Replace BD_QINI    WITH TRB->QTDTOTAL
		
		MsUnLock()
	
	/*/	
	EndIF
		_nRegAtu++
	
	IncProc(StrZero(_nRegAtu,6)+"/"+StrZero(_nTotReg,6)+" - "+_cCodigo+"/"+Substr(TRB->COD,1,20))
	
	Dbselectarea("TRB")
	Dbskip()
	
Enddo

DbCloseArea("TRB")
DbCloseArea("INFOPRO")
MsgBox("Fim do Processamento !!!","Atencao","ALERT")

//DbCloseArea("TRB")
//INFOPRO->(E_EraseArq(_cIndINFO)) // JBS 12/12/2005
//DbCloseArea("INFOPRO")

Return


/*/
Static Function ImportObs(_cCodSYP)

Local _xAlias := {Alias(), IndexOrd(), Recno() }
Local _cNumSYP := ""

DbSelectArea("INFOPRO")
DbSetOrder(1)

IF DbSeek(_cCodSYP)
	
	_cNumSYP := GetSX8Num("SYP","YP_CHAVE")
	ConfirmSx8()
	
	DbSelectArea("SYP")
	
	RecLock("SYP",.T.)
	Replace YP_CHAVE With _cNumSYP
	Replace YP_SEQ   With "001"
	Replace YP_TEXTO With Alltrim(INFOPRO->LINHA1)+" "
	Replace YP_CAMPO With "B1_CODOBS"
	MsUnLock()
	
	RecLock("SYP",.T.)
	Replace YP_CHAVE With _cNumSYP
	Replace YP_SEQ   With "002"
	Replace YP_TEXTO With " "+Alltrim(INFOPRO->LINHA2)+" "
	Replace YP_CAMPO With "B1_CODOBS"
	MsUnLock()
	
	RecLock("SYP",.T.)
	Replace YP_CHAVE With _cNumSYP
	Replace YP_SEQ   With "003"
	Replace YP_TEXTO With " "+Alltrim(INFOPRO->LINHA3)+" "
	Replace YP_CAMPO With "B1_CODOBS"
	MsUnLock()
	
	RecLock("SYP",.T.)
	Replace YP_CHAVE With _cNumSYP
	Replace YP_SEQ   With "004"
	Replace YP_TEXTO With " "+Alltrim(INFOPRO->LINHA4)+" "
	Replace YP_CAMPO With "B1_CODOBS"
	MsUnLock()
	
	RecLock("SYP",.T.)
	Replace YP_CHAVE With _cNumSYP
	Replace YP_SEQ   With "005"
	Replace YP_TEXTO With " "+Alltrim(INFOPRO->LINHA5)
	Replace YP_CAMPO With "B1_CODOBS"
	MsUnLock()
	
EndIF

DbSelectArea(_xAlias[1])
DbSetOrder(_xAlias[2])
DbGoto(_xAlias[3])

Return(_cNumSYP)
/*/

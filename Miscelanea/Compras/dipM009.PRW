#Include "RwMake.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ DIPM009  º Autor ³   Rodrigo Franco   º Data ³  27/03/2002 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Importacao do arquivo de Clientes.                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function DIPM009()
U_DIPPROC(ProcName(0),U_DipUsr()) // JBS 05/10/2005 - Gravando o nome do Programa no SZU
Processa({|| ProcCli() })
Return

Static Function ProcCli()

Local _nTotReg := 0
Local _nRegAtu := 0

Do While .T.
	
	IF File("\MIGRACAO\CLIENTE.DBF")
		DbUseArea (.T.,, "\MIGRACAO\CLIENTE.DBF","TRB", .T., .T. )
		If Select ("TRB") == 0
			MsgBox("Nao foi possivel abrir o arquivo de clientes !!!","Atencao","INFO")
			Return( Nil )
		Endif
	Else
		MsgBox("O Arquivo de Clientes nao esta no Diretorio !!!","Atencao","INFO")
		Return( Nil )
	EndIF
	
	Exit
	
Enddo

_nTotReg := RecCount()

DbGoTop()

ProcRegua(_nTotReg)

While !TRB->( Eof() )
	
	IF Empty(TRB->NOME)
		TRB->(DbSkip())
		Loop
	EndIF
	
	_cCodigo := StrZero(Val(TRB->CODIGO),6)	
	
	DbSelectArea("SA1")
	DbSetOrder(1)
	IF !DbSeek( xFilial("SA1") + _cCodigo )
		
		Reclock( "SA1", .T. )
		Replace A1_FILIAL   WITH xFilial("SA1")
		Replace A1_LOJA     WITH "01"
		Replace A1_COD      WITH _cCodigo
		Replace A1_NOME     WITH TRB->NOME
		Replace A1_NREDUZ   WITH TRB->NOME2
		Replace A1_END      WITH TRB->ENDERECO
		Replace A1_BAIRRO   WITH TRB->BAIRRO
		Replace A1_MUN      WITH TRB->MUNICIPIO
		Replace A1_EST      WITH TRB->ESTADOUF
		Replace A1_ENDCOB   WITH IF(ALLTRIM(TRB->MUNICIPIO) $ TRB->PCAPAGTO,TRB->ENDERECO,TRB->PCAPAGTO)
		Replace A1_CGC      WITH U_PString(TRB->CGC)
		Replace A1_INSCR    WITH IIF("ISENTO" $ TRB->INSCRICAO,"",U_PString(TRB->INSCRICAO))
		Replace A1_TEL      WITH TRB->TELEFONE
		Replace A1_FAX      WITH TRB->FAX
		Replace A1_CONTATO  WITH TRB->CONTATO
		Replace A1_ENDENT   WITH TRB->LOCALENTRE
		
		DbSelectArea("SA3")
		DbsetOrder(1)
		Locate For Alltrim(TRB->VENDEDOR)+" " $ SA3->A3_NREDUZ
		IF Found()
			DbSelectArea("SA1")
			Replace A1_VEND  WITH SA3->A3_COD
		Else
			DbSelectArea("SA1")
			Replace A1_VEND  WITH ""
		EndIF
		
		DbSelectArea("SA4")
		DbSetOrder(2)
		IF DbSeek(xFilial("SA4")+Alltrim(TRB->TRANSP))
			DbSelectArea("SA1")
			Replace A1_TRANSP   WITH SA4->A4_COD
		Else
			Locate For Alltrim(TRB->TRANSP)+" " $ SA4->A4_NOME
			IF Found()
				DbSelectArea("SA1")
				Replace A1_TRANSP   WITH SA4->A4_COD
			EndIF
		EndIF
		
		DbSelectArea("SA1")
		
		Replace A1_CEP      WITH U_PString(TRB->CEP)
		Replace A1_CXPOSTA  WITH TRB->CAIXAPOSTA
		Replace A1_TIPO     WITH IF(TRB->COMERCIO=="S","R","F")
		Replace A1_EMAIL    WITH TRB->EMAIL
		Replace A1_LC       WITH TRB->LIMITE
		
		MsUnlock()
	Else  
 /*		
		DbSelectArea("SA3")
		DbsetOrder(1)
		Locate For Alltrim(TRB->VENDEDOR)+" " $ SA3->A3_NREDUZ
		IF Found()
			DbSelectArea("SA1")
			Reclock( "SA1", .F. )
			Replace A1_VEND  WITH SA3->A3_COD
			MsUnlock()
		Else
			DbSelectArea("SA1")
			Reclock( "SA1", .F. )
			Replace A1_VEND  WITH ""
			MsUnlock()
		EndIF
		*/
		IF SUBSTR(SA1->A1_NOME,1,10) == SUBSTR(TRB->NOME,1,10)
			Reclock( "SA1", .F. )
	    	Replace A1_NOME     WITH TRB->NOME 
	    	MsUnlock()
	    ENDIF	
	EndIF
	
	_nRegAtu++	
	
	IncProc(StrZero(_nRegAtu,6)+"/"+StrZero(_nTotReg,6)+" - "+Substr(TRB->NOME,1,20))
	
	Dbselectarea("TRB")
	Dbskip()
	
Enddo

DbCloseArea("TRB")
MsgBox("Fim do Processamento !!!","Atencao","ALERT")

Return
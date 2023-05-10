#include "RwMake.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ DIPM006  º Autor ³  Joseval S. Araujo º Data ³  25/09/01   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Importacao do cadastro de Duplicata                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function DIPM006()
U_DIPPROC(ProcName(0),U_DipUsr()) // JBS 05/10/2005 - Gravando o nome do Programa no SZU
Processa({|| ProssDupli() })

Return

Static Function ProssDupli()

Local _nTotReg := 0
Local _nRegAtu := 0

While .T.
	
	IF File("\MIGRACAO\CDUPLICA.DBF")
		DbUseArea(.T.,, "\MIGRACAO\CDUPLICA.DBF","TRB", .T., .T. )
		If Select ("TRB") == 0
			MsgBox("Nao foi possivel abrir o arquivo de Dupicata !!!","Atencao","INFO")
			Return( Nil )
		Endif
	Else
		MsgBox("O Arquivo de Duplicatas nao esta no Diretorio !!!","Atencao","INFO")
		Return( Nil )
	Endif
	
	Exit
	
Enddo

DbSelectArea("TRB")
DbGoTop()

_nTotReg := RecCount()

ProcRegua(_nTotReg)

While !TRB->( Eof() )
	
	//    If (Year(TRB->DATEMISSAO) == 2002
	//		TRB->(dBSkip())
	//		Loop
	// Endif
	
	//	If Month(TRB->DATAPAGATO) < (Month(dDatabase) - 4)
	//	 	TRB->(dBSkip())
	//		Loop
	//	Endif
	
	//   	If Month(TRB->DATEMISSAO) < (Month(dDatabase)- 6)
	//		TRB->(dBSkip())
	//		Loop
	//	endif
	
	DbSelectArea("SE1")
	DbSetOrder(2)
	
	_cCliente   := StrZero(Val(TRB->NUMEROCLIE),6)
	_cDuplicata := StrZero(Val(Substr(TRB->NDUPLICATA,1,6)),6)
	_cParcela   := Substr(TRB->NDUPLICATA,7,1)
	_xProcura := xFilial("SE1")+_cCLiente+"01"+Space(03)+_cDuplicata+_cParcela
	
	IF !DbSeek(_xProcura)
		Reclock("SE1",.T.)
		
		Replace E1_FILIAL  With "01"
		Replace E1_TIPO    With "NF"
		Replace E1_NUM     With _cDuplicata
		Replace E1_PARCELA With _cParcela
		Replace E1_VALOR   With TRB->VLDUPLICATA
		Replace E1_VLCRUZ  With TRB->VLDUPLICATA
		Replace E1_EMISSAO WIth TRB->DATEMISSAO
		Replace E1_HIST    WIth TRB->TEXT1
		
		If TRB->DATAVENCTO == CTOD("")
			Replace E1_VENCTO  With TRB->DATEMISSAO
			Replace E1_VENCREA With TRB->DATEMISSAO
		Else
			Replace E1_VENCTO  With TRB->DATAVENCTO
			Replace E1_VENCREA With TRB->DATAVENCTO
		Endif
		
		If TRB->DATAPAGATO  != CTOD("  /  /  ")
			Replace E1_BAIXA   With TRB->DATAPAGATO
			Replace E1_VALLIQ With TRB->VLDUPLICATA
			Replace E1_SALDO  With 0.00
		ELSE
			Replace E1_SALDO  With TRB->VLDUPLICATA
			Replace E1_VALLIQ With 0.00
		Endif
		
		Replace E1_CLIENTE With _cCliente
		Replace E1_LOJA    With "01"
		Replace E1_NOMCLI  With TRB->NOMCLIENTE
		Replace E1_VENCORI   With TRB->DATAVENCTO
		Replace E1_MOEDA     With 1
		
		If  TRB->BANCO == "T"
			Replace E1_PORTADO With "341"
			Replace E1_AGEDEP  With "00191"
		ElseIf TRB->BANCO == "A"
			Replace E1_PORTADO With "422"
			replace E1_AGEDEP  With "00004"
		ElseIf TRB->BANCO == "N"
			Replace E1_PORTADO With "291"
			Replace E1_AGEDEP  With "00038"
		ElseIf TRB->BANCO == "P"
			Replace E1_PORTADO With "219"
			Replace E1_AGEDEP  With "00001"
		ElseIf TRB->BANCO == "S"
			Replace E1_PORTADO With "347"
			Replace E1_AGEDEP  With "00710"
		ElseIf TRB->BANCO == "I"
			Replace E1_PORTADO With "244"
			Replace E1_AGEDEP  With "00028"
		ElseIf TRB->BANCO == "L"
			Replace E1_PORTADO With "001"
			Replace E1_AGEDEP  With "00297"
		Elseif TRB->BANCO == "C"
			Replace E1_PORTADO With "CX1"
			Replace E1_AGEDEP  With "00000"
		Elseif TRB->BANCO == " "
			Replace E1_PORTADO With "CX1"
			Replace E1_AGEDEP  With "00000"
		Endif
		
		DbSelectArea("SA1")
		
		DbSetOrder(1)
		
		If DbSeek(xFilial("SA1")+_cCliente+"01")
			DbSelectArea("SE1")
			Replace E1_VEND1 With SA1->A1_VEND
			Replace E1_NATUREZ With SA1->A1_NATUREZ
		Endif
		
		DbSelectArea("SE1")
		
		MsUnLock()
		
		_nRegAtu++
		
		IncProc(StrZero(_nRegAtu,6)+"/"+StrZero(_nTotReg,6)+" - "+_cDuplicata+"/"+Substr(TRB->NDUPLICATA,1,20))
		
		IF (TRB->DATAPAGATO != CTOD("  /  /  ")	)
			
			
			Dbselectarea("SE5")
			Dbsetorder(1)
			RecLock("SE5",.T.)
			Replace E5_FILIAL  With "01"
			Replace E5_DATA    With TRB->DATAPAGATO
			Replace E5_TIPO    With "NF"
			Replace E5_PARCELA With _cParcela
			Replace E5_VALOR   With TRB->VLDUPLICATA
			
			DbSelectArea("SA1")
			DbSetOrder(1)
			If DbSeek(xFilial("SA1")+_cCliente+"01")
				Replace SE5->E5_NATUREZ With SA1->A1_NATUREZ
			Endif
			
			Dbselectarea("SE5")
			
			If  TRB->BANCO == "T"
				Replace E5_BANCO   With "341"
				Replace E5_AGENCIA  With "00191"
			ElseIf TRB->BANCO == "A"
				Replace E5_BANCO  With "422"
				replace E5_AGENCIA  With "00004"
			ElseIf TRB->BANCO == "N"
				Replace E5_BANCO With "291"
				Replace E5_AGENCIA  With "00038"
			ElseIf TRB->BANCO == "P"
				Replace E5_BANCO With "219"
				Replace E5_AGENCIA  With "00001"
			ElseIf TRB->BANCO == "S"
				Replace E5_BANCO With "347"
				Replace E5_AGENCIA  With "00710"
			ElseIf TRB->BANCO == "I"
				Replace E5_BANCO With "244"
				Replace E5_AGENCIA  With "00028"
			ElseIf TRB->BANCO == "L"
				Replace E5_BANCO With "001"
				Replace E5_AGENCIA  With "00297"
			Elseif TRB->BANCO == "C"
				Replace E5_BANCO With "CX1"
				Replace E5_AGENCIA  With "00000"
			Elseif TRB->BANCO == " "
				Replace E5_BANCO With "CX1"
				Replace E5_AGENCIA  With "00000"
			Endif
			
			Replace E5_BENEF   With TRB->NOMCLIENTE
			Replace E5_RECPAG  WIth "R"
			Replace E5_HISTOR  With "Valor Recebido s/ Titulo"
			Replace E5_TIPODOC With "VL"
			Replace E5_NUMERO  With _CDUPLICATA
			Replace E5_LOJA    With "01"
			Replace E5_CLIFOR  With _cCliente
			Replace E5_DTDIGIT With TRB->DATAPAGATO
			Replace E5_MOTBX   With "NOR"
			Replace E5_DTDISPO With TRB->DATAPAGATO
			Replace E5_SEQ     With "01"
			
			MsUnlock()
		Endif
	ELSE  
		Reclock("SE1",.F.)
		If TRB->DATAPAGATO  != CTOD("  /  /  ")
			Replace E1_BAIXA   With TRB->DATAPAGATO
			Replace E1_VALLIQ With TRB->VLDUPLICATA
			Replace E1_SALDO  With 0.00
		ELSE
			Replace E1_SALDO  With TRB->VLDUPLICATA
			Replace E1_VALLIQ With 0.00
		Endif
		MsUnlock()
		IF TRB->PERCENTUAL == 0
			Reclock("SE1",.F.)
			Replace E1_COMIS1  With TRB->COMISSAO1
			MsUnlock()	
		ELSE
			Reclock("SE1",.F.)
			Replace E1_COMIS1  With TRB->PERCENTUAL
			MsUnlock()	
		ENDIF
	ENDIF
	Dbselectarea("TRB")
	Dbskip()
Enddo

DbCloseArea("TRB")

MsgBox("Fim do Processamento !!!","Atencao","ALERT")
Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³ DIPG004  º Autor ³  Rodrigo Franco    º Data ³ 27/12/2001  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Avalia amarracao marca x regioes para permitir venda do    º±±
±±º          ³ produto.                                                   º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

#include "rwmake.ch"

User Function DIPG004()

Local _cResultado := ""
Local _lGrupoDesc := .T.
Local _xAlias     := GetArea()
Local _cRetorno   := ""
Local _cGrupoDesc := IIF(Empty(SA1->A1_GRPDESC),"999999",SA1->A1_GRPDESC)
Local _cGrpVen    := SA1->A1_GRPVEN //Grupo de cliente - 28/09/11
Local _cGrupoIsen :=  GetMv("ES_DIPG4_1")     //'000020'//Pro-Saúde não pedirá mais senha para produtos AMCOR (Autorizado pelo Erich via e-mail) 28/09/11  Giovani Zago 28/11/11
Local _clientIsen :=  GetMv("ES_DIPG4_2")    // Giovani Zago 28/11/11
Local _nPosGerent := _nPosGerent := aScan(aHeader, { |x| Alltrim(x[2]) == IIF("TMK"$FunName(),"UB_COMIS2","C6_COMIS2") })
Local _cFornece   := SB1->B1_PROC
Local _nPosProd   := aScan(aHeader, { |x| Alltrim(x[2]) == IIF("TMK"$FunName(),"UB_PRODUTO","C6_PRODUTO") }) // JBS 14/06/2006
Local _nPosDescr     := aScan(aHeader, { |x| Alltrim(x[2]) == "C6_DESCRI"    })
Local _nPosForne     := aScan(aHeader, { |x| Alltrim(x[2]) == "C6_FORNEC"     })
U_DIPPROC(ProcName(0),U_DipUsr()) // JBS 05/10/2005 - Gravando o nome do Programa no SZU

If ( Type("l410Auto") <> "U" .and. l410Auto ) // JBS 14/06/2006
	_cRetorno :=  aCols[N,_nPosProd]          // JBS 14/06/2006
	Return(_cRetorno)                         // JBS 14/06/2006
EndIf                                         // JBS 14/06/2006

_cRetorno   := &(ReadVar()) // JBS 14/06/2006

DbSelectArea("SZ1")
DbSetOrder(2)
IF !DbSeek(xFilial("SZ1")+_cGrupoDesc+_cFornece)
	DbSelectArea("SZ1")
	DbSetOrder(1)
	IF !DbSeek(xFilial("SZ1")+_cGrupoDesc)
		_lGrupoDesc := .F.
	Else
		DbSelectArea("SZ2")
		DbSetOrder(2)
		IF DbSeek( xFilial("SZ2")+SB1->B1_PROC+AllTrim(SA1->A1_BAIRRO))
			While !eof() .and. xFilial("SZ2") == SZ2->Z2_FILIAL .AND. SB1->B1_PROC == SZ2->Z2_MARCA .AND. Alltrim(SA1->A1_BAIRRO) == Alltrim(SZ2->Z2_BAIRRO)
				IF ALLTRIM(SA1->A1_MUN) == ALLTRIM(SZ2->Z2_MUNICIP)
					IF ALLTRIM(SA1->A1_EST) == ALLTRIM(SZ2->Z2_ESTADO)
						_cResultado := "Bairro " + ALLTRIM(SA1->A1_BAIRRO) + " Cidade " + ALLTRIM(SA1->A1_MUN) + " Estado " + ALLTRIM(SA1->A1_EST)
						EXIT
					ENDIF
				ENDIF
				DbSelectArea("SZ2")
				DBSKIP()
			END
		ELSEIF _lGrupoDesc == .T.
			DbSetOrder(1)
			IF DbSeek( xFilial("SZ2")+SB1->B1_PROC+Alltrim(SA1->A1_MUN) )
				While !eof() .and. xFilial("SZ2") == SZ2->Z2_FILIAL .AND. SB1->B1_PROC == SZ2->Z2_MARCA .AND. Alltrim(SA1->A1_MUN) == ALLTRIM(SZ2->Z2_MUNICIP)
					IF ALLTRIM(SA1->A1_EST) == ALLTRIM(SZ2->Z2_ESTADO) .AND. AllTrim(SZ2->Z2_BAIRRO) == ""
						_cResultado := "Municipio " + ALLTRIM(SA1->A1_MUN) + " Estado " + ALLTRIM(SA1->A1_EST)
						EXIT
					ENDIF
					DbSelectArea("SZ2")
					DBSKIP()
				END
			ELSE
				DbSetOrder(3)
				IF DbSeek( xFilial("SZ2")+SB1->B1_PROC+Alltrim(SA1->A1_EST) )
					While !eof() .and. xFilial("SZ2") == SZ2->Z2_FILIAL .AND. SB1->B1_PROC == SZ2->Z2_MARCA .AND. Alltrim(SA1->A1_EST) == ALLTRIM(SZ2->Z2_ESTADO)
						IF AllTrim(SZ2->Z2_MUNICIP) == "" .AND. AllTrim(SZ2->Z2_BAIRRO) == ""
							_cResultado := "Estado " + ALLTRIM(SA1->A1_EST)
							EXIT
						ENDIF
						DbSelectArea("SZ2")
						DBSKIP()
					END
				ENDIF
			Endif
		ENDIF
	Endif
Else
	DbSelectArea("SZ2")
	DbSetOrder(2)
	IF DbSeek( xFilial("SZ2")+SB1->B1_PROC+AllTrim(SA1->A1_BAIRRO))
		While !eof() .and. xFilial("SZ2") == SZ2->Z2_FILIAL .AND. SB1->B1_PROC == SZ2->Z2_MARCA .AND. Alltrim(SA1->A1_BAIRRO) == Alltrim(SZ2->Z2_BAIRRO)
			IF ALLTRIM(SA1->A1_MUN) == ALLTRIM(SZ2->Z2_MUNICIP)
				IF ALLTRIM(SA1->A1_EST) == ALLTRIM(SZ2->Z2_ESTADO)
					_cResultado := "Bairro " + ALLTRIM(SA1->A1_BAIRRO) + " Cidade " + ALLTRIM(SA1->A1_MUN) + " Estado " + ALLTRIM(SA1->A1_EST)
					EXIT
				ENDIF
			ENDIF
			DbSelectArea("SZ2")
			DBSKIP()
		END
	ELSEIF _lGrupoDesc == .T.
		DbSetOrder(1)
		IF DbSeek( xFilial("SZ2")+SB1->B1_PROC+Alltrim(SA1->A1_MUN) )
			While !eof() .and. xFilial("SZ2") == SZ2->Z2_FILIAL .AND. SB1->B1_PROC == SZ2->Z2_MARCA .AND. Alltrim(SA1->A1_MUN) == ALLTRIM(SZ2->Z2_MUNICIP)
				IF ALLTRIM(SA1->A1_EST) == ALLTRIM(SZ2->Z2_ESTADO) .AND. AllTrim(SZ2->Z2_BAIRRO) == ""
					_cResultado := "Municipio " + ALLTRIM(SA1->A1_MUN) + " Estado " + ALLTRIM(SA1->A1_EST)
					EXIT
				ENDIF
				DbSelectArea("SZ2")
				DBSKIP()
			END
		ELSE
			DbSetOrder(3)
			IF DbSeek( xFilial("SZ2")+SB1->B1_PROC+Alltrim(SA1->A1_EST) )
				While !eof() .and. xFilial("SZ2") == SZ2->Z2_FILIAL .AND. SB1->B1_PROC == SZ2->Z2_MARCA .AND. Alltrim(SA1->A1_EST) == ALLTRIM(SZ2->Z2_ESTADO)
					IF AllTrim(SZ2->Z2_MUNICIP) == "" .AND. AllTrim(SZ2->Z2_BAIRRO) == ""
						_cResultado := "Estado " + ALLTRIM(SA1->A1_EST)
						EXIT
					ENDIF
					DbSelectArea("SZ2")
					DBSKIP()
				END
			ENDIF
		Endif
	ENDIF
Endif


/*
DbSelectArea("SZ1")
DbSetOrder(1)
IF !DbSeek(xFilial("SZ1")+_cGrupoDesc)
_lGrupoDesc := .F.
Else
DbSelectArea("SZ2")
DbSetOrder(2)
IF DbSeek( xFilial("SZ2")+SB1->B1_PROC+AllTrim(SA1->A1_BAIRRO))
While !eof() .and. xFilial("SZ2") == SZ2->Z2_FILIAL .AND. SB1->B1_PROC == SZ2->Z2_MARCA .AND. Alltrim(SA1->A1_BAIRRO) == Alltrim(SZ2->Z2_BAIRRO)
IF ALLTRIM(SA1->A1_MUN) == ALLTRIM(SZ2->Z2_MUNICIP)
IF ALLTRIM(SA1->A1_EST) == ALLTRIM(SZ2->Z2_ESTADO)
_cResultado := "Bairro " + ALLTRIM(SA1->A1_BAIRRO) + " Cidade " + ALLTRIM(SA1->A1_MUN) + " Estado " + ALLTRIM(SA1->A1_EST)
EXIT
ENDIF
ENDIF
DbSelectArea("SZ2")
DBSKIP()
END
ELSEIF _lGrupoDesc == .T.
DbSetOrder(1)
IF DbSeek( xFilial("SZ2")+SB1->B1_PROC+Alltrim(SA1->A1_MUN) )
While !eof() .and. xFilial("SZ2") == SZ2->Z2_FILIAL .AND. SB1->B1_PROC == SZ2->Z2_MARCA .AND. Alltrim(SA1->A1_MUN) == ALLTRIM(SZ2->Z2_MUNICIP)
IF ALLTRIM(SA1->A1_EST) == ALLTRIM(SZ2->Z2_ESTADO) .AND. AllTrim(SZ2->Z2_BAIRRO) == ""
_cResultado := "Municipio " + ALLTRIM(SA1->A1_MUN) + " Estado " + ALLTRIM(SA1->A1_EST)
EXIT
ENDIF
DbSelectArea("SZ2")
DBSKIP()
END
ELSE
DbSetOrder(3)
IF DbSeek( xFilial("SZ2")+SB1->B1_PROC+Alltrim(SA1->A1_EST) )
While !eof() .and. xFilial("SZ2") == SZ2->Z2_FILIAL .AND. SB1->B1_PROC == SZ2->Z2_MARCA .AND. Alltrim(SA1->A1_EST) == ALLTRIM(SZ2->Z2_ESTADO)
IF AllTrim(SZ2->Z2_MUNICIP) == "" .AND. AllTrim(SZ2->Z2_BAIRRO) == ""
_cResultado := "Estado " + ALLTRIM(SA1->A1_EST)
EXIT
ENDIF
DbSelectArea("SZ2")
DBSKIP()
END
ENDIF
Endif
ENDIF
Endif
*/

DbSelectArea("SZ5")
DbSetOrder(1)
IF DbSeek(xFilial("SZ5")+AllTrim(SA1->A1_COD))
	While !eof() .and. xFilial("SZ5") == SZ5->Z5_FILIAL .AND. SA1->A1_COD == SZ5->Z5_CLIENTE
		IF ALLTRIM(_cFornece) == ALLTRIM(SZ5->Z5_FORNECE)
			IF SZ5->Z5_VENDAOK == "S"
				_cResultado := ""
				Exit
			ELSE
				_cResultado := "PRODUTO NAO PODE SER VENDIDO PARA ESTE CLIENTE"
				Exit
			ENDIF
		ENDIF
		DbSelectArea("SZ5")
		DBSKIP()
	END
ENDIF
IF !Empty(_cResultado) .or. !_lGrupoDesc
	IF !_lGrupoDesc
		MsgBox("O Grupo de Desconto "+_cGrupoDesc+" deste cliente, nao esta cadastrado !!!","Atencao","ALERT")
	Else
		IF "TMK"$FUNNAME()
			//Pro-Saúde não pedirá mais senha para produtos AMCOR (Autorizado pelo Erich via e-mail) 28/09/11
			If  dDataBase >= GetMv("ES_DIPG4_3")// Giovani Zago 15/12/11
				_lReto := Iif(!(M->UA_CLIENTE$_clientIsen .Or. _cGrpVen $ _cGrupoIsen),U_Senha("CID",0,0,0),.T.) // Giovani Zago 28/11/11
			ELSE
				_lReto := .T.
			ENDIF
		ELSE
			If  dDataBase < GetMv("ES_DIPG4_3")// Giovani Zago 15/12/11
				_lReto := Iif(M->C5_TIPO=='N'.AND.!(M->C5_CLIENTE$_clientIsen .Or. _cGrpVen $ _cGrupoIsen),U_Senha("CID",0,0,0),.T.)// Giovani Zago 28/11/11
			ELSE
				_lReto := .T.
			ENDIF
		ENDIF
		If _lReto == .t.
			
			//³ Mostra tela do saldo em estoque.                           ³
			// U_Dipa004("",.F.)
			// nao precisa mais, uso agora DENTRO DO DIPG008
			
			//³ Mostra tabela de preco e calculo da margem.                ³
			U_DIPG006()
			
			//³ Avalia comissao para gerente do vendedor do pedido.        ³
			DbSelectArea("SA3")
			DbSetOrder(1)
			IF DbSeek(xFilial("SA3")+IIF("TMK"$FunName(),M->UA_VEND,M->C5_VEND1))
				IF !Empty(SA3->A3_GEREN)
					DbSelectArea("SZ4")
					DbSetOrder(1)
					IF DbSeek(xFilial("SZ4")+SA3->A3_GEREN+SB1->B1_PROC+SB1->B1_LOJPROC)
						aCols[n,_nPosGerent] := SZ4->Z4_COMIS
					Else
						aCols[n,_nPosGerent] := 0
					EndIF
				Else
					aCols[n,_nPosGerent] := 0
				EndIF
			Else
				aCols[n,_nPosGerent] := 0
			EndIF
		ELSE
			For _xL := 2 to Len(aHeader)
				If !(aHeader[_xL,2] $ 'C6_ALI_WT/C6_REC_WT')     // Giovani Zago 29/08/2011 erro na leitura do aheader{alias,recno} nao existem no sx3
					aCols[n,_xL] := CriaVar(aHeader[_xL,2])
				EndIf      //Giovani Zago 29/08/2011
			Next
			_cRetorno := " "
			
			
		Endif
	EndIF
Else
	
	//³ Mostra tela do saldo em estoque.                           ³
	// U_Dipa004("",.F.)
	// nao precisa mais, uso agora DENTRO DO DIPG008
	
	//³ Mostra tabela de preco e calculo da margem.                ³
	U_DIPG006()
	
	//³ Avalia comissao para gerente do vendedor do pedido.        ³
	DbSelectArea("SA3")
	DbSetOrder(1)
	IF DbSeek(xFilial("SA3")+IIF("TMK"$FunName(),M->UA_VEND,M->C5_VEND1))
		IF !Empty(SA3->A3_GEREN)
			DbSelectArea("SZ4")
			DbSetOrder(1)
			IF DbSeek(xFilial("SZ4")+SA3->A3_GEREN+SB1->B1_PROC+SB1->B1_LOJPROC)
				aCols[n,_nPosGerent] := SZ4->Z4_COMIS
			Else
				aCols[n,_nPosGerent] := 0
			EndIF
		Else
			aCols[n,_nPosGerent] := 0
		EndIF
	Else
		aCols[n,_nPosGerent] := 0
	EndIF
EndIF

RestArea(_xAlias)

Return(_cRetorno)

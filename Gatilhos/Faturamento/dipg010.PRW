#include "rwmake.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³ DIPG010  º Autor ³  Rodrigo Franco    º Data ³ 27/12/2001  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Avalia amarracao marca x regioes para permitir venda do    º±±
±±º          ³ produto.                                                   º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function DIPG010(_cOrigem)

Local _cResultado := ""
Local _lGrupoDesc := .T.
Local _xAlias     := GetArea()
Local _areaSB1 := SB1->(getarea())
Local _areaSZ1 := SZ1->(getarea())
Local _cRetorno   := &(ReadVar())      
Local _cGrpVen    := SA1->A1_GRPVEN //Grupo de cliente - 28/09/11
Local _cGrupoIsen :=  GetMv("ES_DIPG4_1")     //'000020'//Pro-Saúde não pedirá mais senha para produtos AMCOR (Autorizado pelo Erich via e-mail) 28/09/11  Giovani Zago 28/11/11
Local _clientIsen :=  GetMv("ES_DIPG4_2")    // Giovani Zago 28/11/11
Local _cGrupoDesc := IIF(Empty(SA1->A1_GRPDESC),"999999",SA1->A1_GRPDESC)

//Local _nPosProdut := aScan(aHeader, { |x| Alltrim(x[2]) == IIF("TMK"$FunName(),"UB_PRODUTO",IIF(_cOrigem=="O","CK","C6")+"_PRODUTO" ) })

//DbSelectArea("SB1")
//DbSetOrder(1)
///DbSeek(xFilial("SB1")+aCols[n,_nPosProdut])
U_DIPPROC(ProcName(0),U_DipUsr()) // JBS 05/10/2005 - Gravando o nome do Programa no SZU
_cFornece   := SB1->B1_PROC  

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
		_lReto := Iif(M->C5_TIPO=='N'.AND.!(M->C5_CLIENTE$_clientIsen .Or. _cGrpVen $ _cGrupoIsen),U_Senha("CID",0,0,0),.T.)
		If _lReto == .t.
			
			//³ Mostra tela do saldo em estoque.                           ³
			U_Dipa004("TMP",.F.)
			
			//³ Mostra tabela de preco e calculo da margem.                ³
			If _cOrigem <> 'PROD'
				U_DIPG006("O")
			EndIf
					
		ELSE
			For _xL := 2 to Len(aHeader)
				M->CK_PRODUTO := " "
			Next
			_cRetorno := ""
		Endif
	EndIF
Else
	
	//³ Mostra tela do saldo em estoque.                           ³
	U_Dipa004("TMP",.F.)
	
	//³ Mostra tabela de preco e calculo da margem.                ³
	If _cOrigem <> 'PROD'
		U_DIPG006("O")
	EndIf

EndIF

RestArea(_areaSB1)
RestArea(_areaSZ1)
RestArea(_xAlias)

Return(_cRetorno)
/*
|=====================================================================================|
|Programa  | TKEVALI       | Autor | Eriberto Elias             | Data | 01/01/2003   |
|=====================================================================================|
|Descrição |                                                                          |
|=====================================================================================|
|UTILIZAÇÄO| Ponto de entrada executado antes da validaçao da linha                   |
|          | atual do atendimento pela rotina de televendas.                          |
|          | O seu objetivo é executar alguma validaçao na linha de itens do          |
|          | televendas.                                                              |
|=====================================================================================|
|RETORNO   | Lógico do tipo Logico:                                                   |
|          | - True (Linha válida)                                                    |
|          | - False (Linha inválida)                                                 |
|=====================================================================================|
|Sintaxe   | TKEVALI                                                                  |
|=====================================================================================|
|Uso       | Especifico DIPROMED                                                      |
|=====================================================================================|
|Histórico | DD/MM/AA - Descrição da alteração                                        |
|=====================================================================================|
*/
#INCLUDE "RWMAKE.CH"
#DEFINE nPProd      aPosicoes[01][2] // Posicao do Produto
#DEFINE nPQtd       aPosicoes[04][2] // Posicao da Quantidade
#DEFINE nPVrUnit    aPosicoes[05][2] // Posicao do Valor Unitario
#DEFINE nPVlrItem   aPosicoes[06][2] // Posicao do Valor do item
#DEFINE nPTes       aPosicoes[11][2] // Posicao do Tes
#DEFINE nPosMargAtu aScan(aHeader,{|x| Alltrim(x[2]) == "UB_MARGATU"})
#DEFINE nPosMargIte aScan(aHeader,{|x| Alltrim(x[2]) == "UB_MARGITE"})
#DEFINE nPosNota    aScan(aHeader,{|x| Alltrim(x[2]) == "UB_NOTA"})
*--------------------------------*
USER FUNCTION TKEVALI()
*--------------------------------*
Local lRet        := .T.
Private _cCliEspecial := GetMV("MV_CLIESPE") // Cliente especial

U_DIPPROC(ProcName(0),U_DipUsr()) // JBS 05/10/2005 - Gravando o nome do Programa no SZU


If !aCols[n,Len(aHeader)+1]
	
	SB1->(DbSetOrder(1))
	SB1->(DbSeek(xFilial("SB1")+aCols[n,nPProd]))

	If SB1->B1_TS <> aCols[n,nPTes]
		lRet := U_SENHA("TES",aCols[n,nPVrUnit]*1313*VAL(aCols[n,nPTes]))
	Else
		lRet := .T.
	EndIf

	If lRet

		If aCols[n,nPosNota] == "      "

			If aCols[n,nPosMargAtu] < aCols[n,nPosMargIte]

				If Empty(M->UA_CONDPG) .Or. ;
				        (!Empty(M->UA_CONDPG) .And. SE4->E4_USERDES = 0) .and.;
				        (Type("lTemTesDoacao") == "U" .or. !lTemTesDoacao) .and.;
				        (Type("lTemTesGerDup") == "U" .or. lTemTesGerDup)

					If !M->UA_CLIENTE $ _cCliEspecial

					    If !U_DipSenha("MA2", aCols[n][nPProd], aCols[n][nPVlrItem], 0,.f.)

							lRet := U_Senha("MA2",aCols[n,nPVlrItem],aCols[n,nPosMargAtu],aCols[n,nPosMargIte])

							If lRet
								U_DipSenha("MA2", aCols[n][nPProd], aCols[n][nPVlrItem], 0,.t.)
							EndIf

						Endif
					Else	
					    lRet := .T.
					EndIf
				Else
					lRet := .T.
				EndIf
			Else
				lRet := .T.
			Endif
		Endif
	Else
		lRet := .F.
	Endif
Else
	If type("lDip271Ok") <> "U" .and. lDip271Ok .and. INCLUI
		If aCols[len(aCols),Len(aHeader)+1]
			Adel(aCols,len(aCols))
			Asize(aCols,len(aCols)-1)
			n:=len(aCols)
		EndIf
	EndIf
EndIf
Return(lRet)
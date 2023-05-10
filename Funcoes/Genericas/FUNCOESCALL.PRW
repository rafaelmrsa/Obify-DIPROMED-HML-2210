#include "rwmake.ch"
#include "tcbrowse.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³  CCMTA410  º Autor ³   Alexandro Dias   º Data ³  23/08/01     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Rotina utilizada para liberacao do pedido de vEnda conforme  º±±
±±º          ³ calculo da margem do pedido. A liberacao do pedido e feita   º±±
±±º          ³ atraves de senha, onde somente o Eric (Dipromed) e pessoas   º±±
±±º          ³ autorizadas por ele devem saber a formula de calculo. Este   º±±
±±º          ³ programa executa a rotina DIPG007() para calculo da margem.	º±±
±±º          ³ Esta rotina tambem atualiza o peso bruto e liquido do pedido.º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
±±³Retirada analise de crédito customizada 								  ³±±
±±³Fernando R. Assunção - 08/06/06										  ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function CCMTA410()

Local _lRetorno := .F.
Local _xAlias   := GetArea()
Local _nPosValor
Local _nValor
Local _nTotInf
U_DIPPROC(ProcName(0),U_DipUsr()) // MCVN - 22/01/2009
//³ Executa rotina para calculo da margem do pedido.           ³
_lRetorno := U_DIPG007("TMKVFIM")

//³ Atualiza o peso liquido e bruto do pedido.         	       ³
IF _lRetorno
	_lRetorno := U_CallFrete()
EndIF

//³ Efetua a transferencia entre almoxarIFados do produto para atender a quantidade do pedido ³
//IF _lRetorno
//	U_DIPA013(aCols,aHeader,M->C5_NUM,Inclui)
//EndIF

//³ Valida Condição de Pagamento Tipo 9.              	       ³
IF _lRetorno == .T.
	If SE4->E4_TIPO == "9"
		_nPosValor := aScan(aHeader, { |x| Alltrim(x[2]) == "UB_VLRITEM" })
		_nValor    := 0
		_nTotInf   := 0
		
		//³ Soma valor total da nota.                           ³
		For _nLin := 1 to Len(aCols)
			IF !aCols[_nLin,Len(aHeader)+1]
				_nValor := _nValor + aCols[_nLin,_nPosValor]
			EndIF
		Next
		_nTotInf := M->UA_PARC1 + M->UA_PARC2 + M->UA_PARC3 + M->UA_PARC4
		IF Round(_nValor,2) <> Round(_nTotInf,2)
			MsgInfo("Valor Total do Pedido não confere com o total das parcelas Informadas ")
			_lRetorno := .F.
		ELSE
			IF !EMPTY(M->UA_PARC1) .AND. !EMPTY(M->UA_DATA1) .Or. EMPTY(M->UA_PARC1) .AND. EMPTY(M->UA_DATA1)
				IF !EMPTY(M->UA_PARC2) .AND. !EMPTY(M->UA_DATA2) .Or. EMPTY(M->UA_PARC2) .AND. EMPTY(M->UA_DATA2)
					IF !EMPTY(M->UA_PARC3) .AND. !EMPTY(M->UA_DATA3) .Or. EMPTY(M->UA_PARC3) .AND. EMPTY(M->UA_DATA3)
						IF !EMPTY(M->UA_PARC4) .AND. !EMPTY(M->UA_DATA4) .Or. EMPTY(M->UA_PARC4) .AND. EMPTY(M->UA_DATA4)
							_lRetorno := .T.
						ELSE
							MsgInfo("Não conformidade na parcela 4")
							_lRetorno := .F.
						ENDIF
					ELSE
						MsgInfo("Não conformidade na parcela 3")
						_lRetorno := .F.
					ENDIF
				ELSE
					MsgInfo("Não conformidade na parcela 2")
					_lRetorno := .F.
				ENDIF
			ELSE
				MsgInfo("Não conformidade na parcela 1")
				_lRetorno := .F.
			ENDIF
		Endif
	ENDIF
ENDIF

// Registrando a ocorrencia na Ficha Kardex
IF _lRetorno                     
 	U_DiprKardex(M->UA_NUM,U_DipUsr(),,.T.,If(Inclui,"11","12")) // JBS 26/08/2005
ENDIF

RestArea(_xAlias)

Return(_lRetorno)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FUNCOESCALLºAutor ³ AP6 IDE            º Data ³  11/09/02   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Codigo gerado pelo AP6 IDE.                                º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP6 IDE                                                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºObs       ³ Este programa tem a mesma finalidade da funcao CalcuFrete  º±±
±±º          ³ do ponto de entrada MTA410, qualquer alteracao na funcao   º±±
±±º          ³ original (MTA410) replicar tambem nesse programa           º±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³CalcuFreteºAutor  ³   Jose Maria       º Data ³  11/09/02   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Atualiza o peso liquido e bruto do pedido.                 º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function CallFrete()

Local _nPesoLi    := 0
Local _nPesoBr    := 0
Local _nVrPesoExc := 0
Local _nVlrTotal  := 0
local _nVlrFrete  := 0
Local _lRetorno   := .T.
Local _xAlias     := GetArea()
Local _nPosVol    := aScan(aHeader, { |x| Alltrim(x[2]) == "UB_UNSVEN" })
Local _nPosQt     := aScan(aHeader, { |x| Alltrim(x[2]) == "UB_QUANT" })
Local _nPosVrTot  := aScan(aHeader, { |x| Alltrim(x[2]) == "UB_VLRITEM" })
Local _nPosProd   := aScan(aHeader, { |x| Alltrim(x[2]) == "UB_PRODUTO" })
Local _nPosValor  := aScan(aHeader, { |x| Alltrim(x[2]) == "UB_VLRITEM" })
Local _nValor    := 0
U_DIPPROC(ProcName(0),U_DipUsr()) // MCVN - 22/01/2009
For _nLin := 1 to Len(aCols)
	IF !aCols[_nLin,Len(aHeader)+1]
		
		//³ Soma peso bruto, liquido e total do pedido. ³
		SB1->(DbSetOrder(1))
		IF SB1->(DbSeek(xFilial("SB1")+aCols[_nLin,_nPosProd]))
			_nPesoBr   := _nPesoBr   + (aCols[_nLin,_nPosQt] * SB1->B1_PESO)
			_nPesoLi   := _nPesoLi   + (aCols[_nLin,_nPosQt] * SB1->B1_PESO)
			_nVlrTotal := _nVlrTotal + aCols[_nLin,_nPosVrTot]
		EndIF
	EndIF
Next

//³ Atualiza variaveis do sistema.                      ³
M->UA_PBRUTO  := ( _nPesoBr )
M->UA_PESOL   := _nPesoLi
IF M->UA_TPFRETE == "I"
	_xDestFret := Substr(M->UA_DESTFRE,1,2) + Substr(M->UA_DESTFRE,4,17)
	SZ3->(DbSetOrder(2)	)
	SZ3->(DbSeek(xFilial("SZ3")+M->UA_TRANSP+Alltrim(_xDestFret) ))
	// acha limite apropriado!
	Do While !EOF() .and. SZ3->Z3_TRANSP+AllTrim(SZ3->Z3_EST+SZ3->Z3_CAP_MUN) == M->UA_TRANSP+Alltrim(_xDestFret)
		If M->UA_PBRUTO <= SZ3->Z3_PESOLIM
			Exit
		Else
			SZ3->(DbSkip())
		EndIf
		If SZ3->Z3_TRANSP+AllTrim(SZ3->Z3_EST+SZ3->Z3_CAP_MUN) <> M->UA_TRANSP+Alltrim(_xDestFret)
			SZ3->(DbSkip(-1))
			Exit
		EndIf
	EndDo
	
	//³ VerIFica se a transportadora esta preenchida.       ³
	IF !Empty(M->UA_TRANSP)
		
		//³ VerIFica se existe a transportadora na tabela de calculo.  ³
		IF M->UA_TRANSP == SZ3->Z3_TRANSP
			
			//³ VerIFica se o destino do frete esta preenchido.     ³
			IF !Empty(M->UA_DESTFRE)
				
				//³ Avalia se o peso do pedido e menor ou igual ao peso limite da transp. ³
				IF M->UA_PBRUTO <= SZ3->Z3_PESOLIM
					M->UA_FRETE := 0
					
					//³ Se o valor calculado do Frete, for menor que o valor minimo, entao ³
					//³ o valor do frete sera igual ao valor minimo cobrado pela transp.   ³
					IF ((( _nVlrTotal * SZ3->Z3_FRETE) /100) <= SZ3->Z3_VALOR)
						M->UA_FRETE := SZ3->Z3_VALOR
					Else
						M->UA_FRETE := (_nVlrTotal * SZ3->Z3_FRETE) /100
					EndIF
				Else
					
					//³ Calcula valor do frete conforme o peso excedente.   ³
					IF SZ3->Z3_EXCEDEN > 0
						_nVrPesoExc := (M->UA_PBRUTO - SZ3->Z3_PESOLIM) * SZ3->Z3_EXCEDEN
						IF (( _nVlrTotal * SZ3->Z3_FRETE) /100) <= SZ3->Z3_VALOR
							M->UA_FRETE := SZ3->Z3_VALOR + _nVrPesoExc
						Else
							M->UA_FRETE := ((_nVlrTotal * SZ3->Z3_FRETE) /100) + _nVrPesoExc
						EndIF
					ELSE
						IF SZ3->Z3_TAXAEXC > 0
							M->UA_FRETE := M->UA_FRETE + SZ3->Z3_TAXAEXC
						EndIF
					EndIF
				EndIF
				
				//³ Soma seguro do frete.
				IF SZ3->Z3_ADVALOR > 0
					M->UA_FRETE := M->UA_FRETE + (_nVlrTotal * SZ3->Z3_ADVALOR/100 )
				EndIF
				
				//³ Soma Pedagio do frete
				IF SZ3->Z3_PEDAGIO > 0
					M->UA_FRETE := M->UA_FRETE + SZ3->Z3_PEDAGIO
				EndIF
			Else
				MsgBox("Informe o Destino do Frete para calcular o Valor do Frete !!!","Atencao","Alert")
				M->UA_FRETE := 0
				_lRetorno  := .F.
			EndIF
		Else
			_cMsg :="O Valor do Frete nao sera calculado, esta Transportadora " + Chr(13)
			_cMsg := _cMsg + "nao possui dados necessarios para o calcular o Frete!!!"   + Chr(13) + Chr(13)
			_cMsg := _cMsg + "Deseja confirmar o pedido mesmo assim ?"
			M->UA_FRETE := 0
			IF !MsgBox(_cMsg,"Atencao","YESNO")
				_lRetorno  := .F.
			EndIF
		EndIF
	Else
		MsgBox("Informe a Transportadora para calculo do Frete !!!","Atencao","Alert")
		M->UA_FRETE := 0
	EndIF
ELSE
	MsgBox("Somente para Tipo de Frete Informado sera calculado o Frete !!!","Atencao","Alert")
	M->UA_FRETE := 0
EndIF
_nPosValor := aScan(aHeader, { |x| Alltrim(x[2]) == "UB_VLRITEM" })
_nValor    := 0

//³ Soma valor total da nota.                           ³
For _nLin := 1 to Len(aCols)
	IF !aCols[_nLin,Len(aHeader)+1]
		_nValor := _nValor + aCols[_nLin,_nPosValor]
	EndIF
Next

IF _lRetorno == .t.
	IF !EMPTY(M->UA_CONDPG) .or. !Empty(M->UA_COND)
		IF _nValor >= SE4->E4_INFER .and. _nValor <= SE4->E4_SUPER .and. _nValor >0
			_lRetorno := .t.
		Else
			_lRetorno := .f.
			MsgInfo("Condicao de Pagamento nao permitida, pelo valor praticado")
		EndIF
	EndIF
	IF _lRetorno == .f.
		
		//³ Solicita senha para liberacao do pedido.
		_lReto := Iif(M->UA_TIPO=='N'.AND.M->UA_CLIENTE<>'000804',U_Senha("PAG",_nVlrTotal,0,0),.T.) //Eriberto
		IF _lReto == .t.
			_lRetorno := .t.
		EndIF
	EndIF
Endif

RestArea(_xAlias)

Return(_lRetorno)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³  M460ICM ºAutor  ³   Alexandro Dias   º Data ³  09/08/01      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Esta rotina e utilizada para recalcular o valor do Frete      º±±
±±º          ³ da nota conforme a tabela de Frete da Dipromed.               º±±
±±º          ³ ************************************************************* º±±
±±º          ³ Originalmente o Microsiga Rateia o Frete, no Caso da Dipromed º±±
±±º          ³ nao e pro do Frete na emissao da nota fiscal.                 º±±
±±º          ³ ************************************************************* º±±
±±º          ³ Qualquer alteracao neste programa tambem e necessario analisarº±±
±±º          ³ esta alteracao no Ponto de Entrada MTA410().                  º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function CALLM460ICM()

Local _nVrFrete  := 0
Local _nQtItens  := 0
Local _nPesoBr   := 0
Local _nVrPesoExc:= 0
Local _nVlrTotal := 0
Local _xArea     := GetArea()
Local _xAliasSC9 := { IndexOrd(), Recno() }    

U_DIPPROC(ProcName(0),U_DipUsr()) // MCVN - 22/01/2009

IF SUA->UA_FLAGFRE == 0
	DbSelectArea("SC9")
	DbSetOrder(1)
	IF DbSeek(xFilial("SC9")+SUA->UA_NUM)       
	
		//³ Soma peso bruto, liquido, volume e total do pedido. ³
		While !Eof() .and. xFilial("SC9") == SC9->C9_FILIAL .And. SC9->C9_PEDIDO == SUA->UA_NUM
			IF Len(SC9->C9_OK) >= 2
				IF Empty(SC9->C9_BLEST) .And. Empty(SC9->C9_BLCRED) .and. Empty(U_C5PARCIAL())
					SB1->(DbSetOrder(1))
					IF SB1->(DbSeek(xFilial("SB1")+SC9->C9_PRODUTO))
						_nPesoBr   := _nPesoBr   + (SC9->C9_QTDLIB * SB1->B1_PESO)
						_nVlrTotal := _nVlrTotal + (SC9->C9_QTDLIB * SC9->C9_PRCVEN)
						_nQtItens  := _nQtItens + 1
					EndIF
				EndIF
			EndIF
			DbSkip()
		EndDo
		IF SUA->UA_TPFRETE == "I"
			
			//³ Verifica se a transportadora esta preenchida.       ³
			IF !Empty(SUA->UA_TRANSP)
				DbSelectArea("SZ3")
				DbSetOrder(2)
				_xDestFret := Substr(SUA->UA_DESTFRE,1,2) + Substr(SUA->UA_DESTFRE,4,17)
				DbSeek(xFilial("SZ3")+SUA->UA_TRANSP+Alltrim(_xDestFret) )
				// acha limite apropriado!
				Do While !EOF() .and. SZ3->Z3_TRANSP+AllTrim(SZ3->Z3_EST+SZ3->Z3_CAP_MUN) == SUA->UA_TRANSP+Alltrim(_xDestFret)
					If SUA->UA_PBRUTO <= SZ3->Z3_PESOLIM
						Exit
					Else
						SZ3->(DbSkip())
					EndIf
					If SZ3->Z3_TRANSP+AllTrim(SZ3->Z3_EST+SZ3->Z3_CAP_MUN) <> SUA->UA_TRANSP+Alltrim(_xDestFret)
						SZ3->(DbSkip(-1))
						Exit
					EndIf
				EndDo
				
				//³ Verifica se existe a transportadora na tabela de calculo.  ³
				IF SUA->UA_TRANSP == SZ3->Z3_TRANSP
					
					//³ Verifica se o destino do frete esta preenchido.     ³
					IF !Empty(SUA->UA_DESTFRE)
						
						//³ Avalia se o peso do pedido e menor ou igual ao peso limite da transp. ³
						IF _nPesoBr <= SZ3->Z3_PESOLIM
							
							//³ Se o valor calculado do Frete, for menor que o valor minimo, entao ³
							//³ o valor do frete sera igual ao valor minimo cobrado pela transp.   ³
							IF ((( _nVlrTotal * SZ3->Z3_FRETE) /100) <= SZ3->Z3_VALOR)
								_nVrFrete := SZ3->Z3_VALOR
							Else
								_nVrFrete := (_nVlrTotal * SZ3->Z3_FRETE) /100
							EndIF
						Else
							
							//³ Calcula valor do frete conforme o peso excedente.   ³
							If SZ3->Z3_EXCEDEN > 0
								_nVrPesoExc := (_nPesoBr - SZ3->Z3_PESOLIM) * SZ3->Z3_EXCEDEN
								IF (( _nVlrTotal * SZ3->Z3_FRETE) /100) <= SZ3->Z3_VALOR
									_nVrFrete := SZ3->Z3_VALOR + _nVrPesoExc
								Else
									_nVrFrete := ((_nVlrTotal * SZ3->Z3_FRETE) /100) + _nVrPesoExc
								EndIF
							ELSE
								If SZ3->Z3_TAXAEXC > 0
									_nVrFrete := _nVrFrete + SZ3->Z3_TAXAEXC
								Endif
							ENDIF
						EndIF
						
						//³ Soma seguro do frete.
						If SZ3->Z3_ADVALOR > 0
							_nVrFrete := _nVrFrete + (_nVlrTotal * SZ3->Z3_ADVALOR/100 )
						Endif
						
						//³ Soma Pedagio do frete
						If SZ3->Z3_PEDAGIO > 0
							_nVrFrete := _nVrFrete + SZ3->Z3_PEDAGIO
						Endif
					EndIF
				EndIF
			EndIF
		EndIF
		_Frete := (_nVrFrete / _nQtItens)
		_ValIcmFrete := (_Frete * 0.18) //_AliqIcm) / 100
		DbSelectArea("SUA")
		RecLock("SUA",.F.)
		Replace UA_FLAGFRE With Round(_Frete,2)
		SUA->(MsUnLock())
		DbSelectArea("SC9")
		DbSetOrder(_xAliasSC9[1])
		DbGoto(_xAliasSC9[2])
	EndIF
Else
	_Frete := SUA->UA_FLAGFRE
	_ValIcmFrete := (_Frete * 0.18 ) //_AliqIcm) / 100
EndIF

RestArea(_xArea)

Return()

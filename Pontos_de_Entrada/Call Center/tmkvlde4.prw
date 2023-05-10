/*
PONTO.......: TMKVLDE4          PROGRAMA....: 6.09
DESCRIÇÄO...: TMKA271E.PRW
UTILIZAÇÄO..: Ponto de entrada executado após a seleçao da condiçao de pagamento.
O seu objetivo é permitir a validaçao da escolha da transportadora.
PARAMETROS..: nOpc do tipo N : Opçao do cadastro (3 - Inclui ; 4 - Altera)
cCodPagto do tipo C : Código da codiçao do pagamento

RETORNO.....: Lógico do tipo L : .T. - Montagem da condiçao de pagamento válida
.F. - Montagem da condiçao de pagamento inválida

*/
/*====================================================================================\
|Programa  | TMKVLDE4      | Autor | Eriberto Elias             | Data | 21/07/2003   |
|=====================================================================================|
|Descrição | Calcula o desconto para condicao a vista                                 |
|          | calcula frete                                                            |
|          | calcula substituicao tributaria                                          |
|          | calcula PRECO para amostras, doacoes e bonificaçoes                      |
|          | calcula PRECO com ICMS para TS 569                                       |
|          | Verifica LIMITES da condicao de pagamento                                |
|=====================================================================================|
|Sintaxe   | TMKVLDE4                                                                 |
|=====================================================================================|
|Uso       | Especifico DIPROMED                                                      |
|=====================================================================================|
|Histórico | DD/MM/AA - Descrição da alteração                                        |
\====================================================================================*/

#INCLUDE "RWMAKE.CH"

User Function TMKVLDE4(_nOpc,_cCondPagto)

Local _xAlias  		:= GetArea()
Local _areaSF4 		:= SF4->(getarea())
Local _areaSE4 		:= SE4->(getarea())
Local _areaSB1 		:= SB1->(getarea())
Local _lRetorno 	:= .T.
Local _nPosUDes		:= AScan(aHeader, { |x| Alltrim(x[2]) == "UB_USERDES"})
Local _nPosUPrc		:= AScan(aHeader, { |x| Alltrim(x[2]) == "UB_USERPRC"})
Local _nPosVrUnit	:= AScan(aHeader, { |x| Alltrim(x[2]) == "UB_VRUNIT"})
Local _nPosVlrItem 	:= AScan(aHeader, { |x| Alltrim(x[2]) == "UB_VLRITEM"})
Local _nPosQuant	:= AScan(aHeader, { |x| Alltrim(x[2]) == "UB_QUANT"})
Local _n			:= 0

Public cEnv_Email 	:= ""   // Mudar para local
Public cVal_STD 	:= ""

If ( Type("l410Auto") == "U" .OR. !l410Auto )
	
	SF4->(Dbsetorder(1))
	
	U_DIPPROC(ProcName(0),U_DipUsr()) // JBS 05/10/2005 - Gravando o nome do Programa no SZU
	
	// calcula desconto
	M->UA_CONDPG := _cCondPagto
	
	If SE4->(MsSeek(xFilial("SE4")+_cCondPagto)) .AND. (SE4->E4_USERDES > 0)  // Se condicao de pagamento tiver desconto
		aValores[1] := 0
		For _n := 1 TO Len(aCols)
			
			If (aCols[_n,_nPosUDes] == 0) .AND. ( aCols[_n,Len(aHeader)+1] == .F.)  // Se o desconto (especifico) = 0
				aCols[_n,_nPosUPrc]		:= NOROUND(aCols[_n,_nPosVrUnit],4)
				aCols[_n,_nPosVlrItem]	:= Round(aCols[_n,_nPosVrUnit] * aCols[_n,_nPosQuant],2)       /////  fernando
				aCols[_n,_nPosUDes]		:= Round(aCols[_n,_nPosVlritem] * ((SE4->E4_USERDES)/100),2)        /////  fernando
				aCols[_n,_nPosVlritem]	:= Round(aCols[_n,_nPosVlritem] - aCols[_n,_nPosUDes],2)       /////  fernando
				aCols[_n,_nPosVrUnit]	:= Round(aCols[_n,_nPosVlritem] / aCols[_n,_nPosQuant],4)       /////  fernando
			Endif		
		
			If aCols[_n,Len(aHeader)+1] == .F.
				aValores[1] 			+= aCols[_n,_nPosVlritem] ////// aCols[_n,_nPosUDes] // Fernando
			EndIf
		Next _n
		
	Else
		// Retorno valor original
		_nDescICMS := 0
		aValores[1] := 0
		
		For _n := 1 to Len(aCols)
			
			If ( aCols[_n,_nPosUDes] > 0 ) .AND. ( aCols[_n,Len(aHeader)+1] == .F. )
				aCols[_n,_nPosVrUnit]	:= NOROUND(aCols[_n,_nPosUPrc],4)
				aCols[_n,_nPosVlrItem]	:= ROUND(aCols[_n,_nPosVrUnit]  * aCols[_n,_nPosQuant],2)
				aCols[_n,_nPosUDes]		:= 0
			EndIf
			If aCols[_n,Len(aHeader)+1] == .F.
				aValores[1] 			+= 	aCols[_n,_nPosVlrItem] //* aCols[_n,_nPosQuant]
			EndIf
			
			// Coloca precos de amostra ou doacao
			If SF4->(MsSeek(xFilial("SF4")+aCols[_n,aScan(aHeader, { |x| Alltrim(x[2]) == "UB_TES"})]))
				If "AMOSTRA" $ Upper(SF4->F4_TEXTO) .OR.;
					"DOACAO" $ Upper(SF4->F4_TEXTO) .OR.;
					"BONIFICACAO" $ Upper(SF4->F4_TEXTO)
					
					aValores[1] -= aCols[_n,aScan(aHeader, { |x| Alltrim(x[2]) == "UB_VLRITEM"})]
					// JBS 16/08/2005 - Quando for quantias abaixo de um centavo, considerar um centavo de real
					If Round(aCols[_n,aScan(aHeader, { |x| Alltrim(x[2]) == "UB_CUSTO"})] * 0.2,2)> 0.01
						aCols[_n,aScan(aHeader, { |x| Alltrim(x[2]) == "UB_VRUNIT"})]  := Round(aCols[_n,aScan(aHeader, { |x| Alltrim(x[2]) == "UB_CUSTO"})] * 0.2,2)
					Else
						aCols[_n,aScan(aHeader, { |x| Alltrim(x[2]) == "UB_VRUNIT"})]  := 0.01
					EndIf // JBS 16/08/2005 - Fim
					aCols[_n,aScan(aHeader, { |x| Alltrim(x[2]) == "UB_VLRITEM"})] := aCols[_n,aScan(aHeader, { |x| Alltrim(x[2]) == "UB_VRUNIT"})] * aCols[_n,aScan(aHeader, { |x| Alltrim(x[2]) == "UB_QUANT"})]
					aValores[1] += aCols[_n,aScan(aHeader, { |x| Alltrim(x[2]) == "UB_VLRITEM"})]
				EndIf
			EndIf
            MaFisAlt("IT_VALMERC",aCols[_n,_nPosVlrItem],_n)
			//calcula PRECO com ICMS para TS 569
			// A FORMULA É: VALOR DO ITEM / (100-ALIQUOTA)%  --> Exemplo: 1008/82% = 1229.27 para alíquota 18%
			If aCols[_n,aScan(aHeader, { |x| Alltrim(x[2]) == "UB_TES"})] $ '569/594'
				_nDescICMS -= aCols[_n,aScan(aHeader, { |x| Alltrim(x[2]) == "UB_VRUNIT"})] * aCols[_n,aScan(aHeader, { |x| Alltrim(x[2]) == "UB_QUANT"})]
				_nDescICMS += Round(aCols[_n,aScan(aHeader, { |x| Alltrim(x[2]) == "UB_VRUNIT"})] /((100-Posicione("SB1",1,xFilial("SB1")+aCols[_n,aScan(aHeader, { |x| Alltrim(x[2]) == 'UB_PRODUTO'})],"B1_PICM"))/100),3) * aCols[_n,aScan(aHeader, { |x| Alltrim(x[2]) == "UB_QUANT"})]
			EndIf
		Next _n
		If _nDescICMS <> 0
			MsgBox("Desconto referente ICMS para Orgaos publico"+Chr(13)+"no estado de Sao Paulo"+Chr(13)+Chr(13)+"Valor.: "+AllTrim(Transform(_nDescICMS,"@E 999,999,999.99")),"Atencao","Alert")
			M->UA_MENNOTA := 'Desc.ICMS R$ '+AllTrim(Transform(_nDescICMS,"@E 999,999,999.99"))+'-/- '+Subs(M->UA_MENNOTA,At('-/- ',M->UA_MENNOTA)+Iif(At('-/- ',M->UA_MENNOTA)==0,1,4),Len(M->UA_MENNOTA)-(At('-/- ',M->UA_MENNOTA)+Iif(At('-/- ',M->UA_MENNOTA)==0,0,3)))
		EndIf
	Endif

	U_DIPG007("TMKVFIM")
	
	MaFisAlt("NF_DESPESA",aValores[5])
	MaFisAlt("NF_VALMERC",aValores[1])
	MaFisAlt("NF_TOTAL",aValores[6])
	
	Eval(bRefresh)
	Eval(bGDRefresh)
	Tk273Refresh(avalores)

EndIf

RestArea(_areaSB1)
RestArea(_areaSE4)
RestArea(_areaSF4)
RestArea(_xAlias)
Return(_lRetorno)

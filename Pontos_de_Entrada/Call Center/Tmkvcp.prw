/*
|=====================================================================================|
|Programa  | TMKVCP        | Autor | Jailton B Santos - JBS     | Data | 02002/2006   |
|=====================================================================================|
|Descrição | Ponto de entrada executado após a confirmação da condição de pagamento   |
|          | e informado a transportadora.                                            |
|=====================================================================================|
|Função    | Recalcular o valor do frete quando a transportadora for trocada na tela  |
|          | onde é informada a condição de pagamento e a transportadora.             |
|          | Se o usuario limpar o codigo da transportadora o sistema lhe mostrara    |
|          | todas as transportadoras que possam atender ao cliente e respectivos     |
|          | valoes de frete.                                                         |
|=====================================================================================|
|Sintaxe   | TMKVCP                                                                   |
|=====================================================================================|
|Uso       | Especifico DIPROMED                                                      |
|=====================================================================================|
|........................................Histórico....................................|
|Rafael    | DD/MM/AA - Descrição                                                     |
|Eriberto  | DD/MM/AA - Descrição                                                     |
|=====================================================================================|
*/
#INCLUDE "RWMAKE.CH"

*-----------------------------------------*
User Function TMKVCP(;
cCodTransp,;
oCodTransp,;
cTransp,;
oTransp,;
cCob,;
oCob,;
cEnt,;
oEnt,;
cCidadeC,;
oCidadeC,;
cCepC,;
oCepC,;
cUfC,;
oUfC,;
cBairroE,;
oBairroE,;
cBairroC,;
oBairroC,;
cCidadeE,;
oCidadeE,;
cCepE,;
oCepE,;
cUfE,;
oUfE,;
nOpc,;
cNumTlv,;
cCliente,;
cLoja,;
cCodPagto,;
aParcelas)
*-----------------------------------------*
Local AreaTmkVCP := Getarea()
Local bkp_lTk271Auto := lTk271Auto // Salvaa posição e restaura na saida do programa
Local lRecalcula := .f.
Local nLiquido := 0
Local oLiquido := ''
Local nTxJuros := 0
Local oTxJuros := ''
Local nTxDescon:= 0
Local oTxDescon:= ''
Local oParcelas:= ''
Local oCodPagto:= ''
Local nEntrada := 0
Local oEntrada := ''
Local nFinanciado:= 0
Local oFinanciado:= ''
Local cDescPagto:= ''
Local oDescPagto:= ''
Local nNumParcelas := 0
Local oNumParcelas := ''
Local nVlrPrazo := 0
Local oVlrPrazo := ''
Local nVlJur := 0
Local cCodAnt := ''
Local lTipo9:= .f.
Local oValNFat := ''
//--------------------------------------------------
// Gravando o nome do Programa no SZU  JBS 05/10/2005
//--------------------------------------------------
U_DIPPROC(ProcName(0),U_DipUsr())

U_CalcuFrete('TMKVLDE4')

If Empty(M->UA_TRANSP)
	If SA4->(dbSeek(xFilial("SA4")+cCodTransp))
		M->UA_TRANSP := cCodTransp
		M->UA_NOMETRA:= SA4->A4_NOME
	EndIf
EndIf
//----------------------------------------------
// Faz com que não sejam executados os refreshs
// dentro da função de calculo das parcelas
//----------------------------------------------
lTk271Auto:=.t. // Ignora refresh na função
//----------------------------------------------
// Grava o novo frete calculado na Array
//----------------------------------------------
aValores[4] := M->UA_FRETE // JBS 27/03/2006
//----------------------------------------------
//Calcula o Valor Nao Faturado
//----------------------------------------------
nLiquido := aValores[6]
nValNFat := Tk273NFatura()
nLiquido := nLiquido - nValNFat
//----------------------------------------------
// Recalcula o valor das parcelas
//----------------------------------------------
Tk273MontaParcela(nOpc,;
cNumTlv,;
@nLiquido,;
oLiquido,;
@nTxJuros,;
oTxJuros,;
@nTxDescon,;
oTxDescon,;
@aParcelas,;
oParcelas,;
@cCodPagto,;
oCodPagto,;
@nEntrada,;
oEntrada,;
@nFinanciado,;
oFinanciado,;
@cDescPagto,;
oDescPagto,;
@nNumParcelas,;
oNumParcelas,;
@nVlrPrazo,;
oVlrPrazo,;
@nVlJur,;
@cCodAnt,;
@lTipo9,;
nValNFat,;
oValNFat)

RestArea(AreaTmkVCP)
lTk271Auto := bkp_lTk271Auto
Return(.T.)
/*
|=====================================================================================|
|Programa  | Tk273NFatura  | Autor | Jailton B Santos - JBS     | Data | 29/03/2006   |
|=====================================================================================|
|Descrição | Retorna o total do Valor Nao Faturado desse atendimento                  |
|          | baseado nas linhas validas e com o TES preenchido                        |
|=====================================================================================|
|Sintaxe   | Tk273NFatura()                                                           |
|=====================================================================================|
|Uso       | Especifico DIPROMED                                                      |
|=====================================================================================|
|........................................Histórico....................................|
|Analista  | DD/MM/AA - Descrição                                                     |
|Analista  | DD/MM/AA - Descrição                                                     |
|=====================================================================================|
*/
Static Function Tk273NFatura()
*-------------------------------------------------------------------------------------*
Local Tk273aArea := GetArea()      // Salva a area atual
Local nI := 0                 	   // Controle de loop
Local nValor := 0                  // Valor Nao Faturado
Local nPTes := aPosicoes[11][2]    // Posicao do TES
Local nPVlrItem := aPosicoes[6][2] // Posicao do Valor do Item
Local nValIpi := 0                 // Valor do IPI para o Item

SF4->(DbsetOrder(1))

For nI:=1 TO Len(aCols)
	If !aCols[nI][Len(aHeader)+1] .AND. !Empty(aCols[nI][nPTes])
		If SF4->(MsSeek(xFilial("SF4")+aCols[nI][nPTes]))
			If SF4->F4_DUPLIC == "N" //Nao Gera Duplicata
				//Considera o valor de IPI pois faz parte do valor total da nota.
				nValIpi:=MaFisRet(nI,'IT_VALIPI')
				nValor += aCols[nI][nPVlrItem]+nValIpi
			Endif
		Endif
	Endif
Next nI

RestArea(Tk273aArea)
Return(nValor)

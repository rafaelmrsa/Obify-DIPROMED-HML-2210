/*
PONTO.......: A261PROD           PROGRAMA....: MATA261
DESCRIÇÄO...: VALIDACAO DO PRODUTO MOD 2
UTILIZAÇÄO..: O ponto sera disparado na chamada da funcao de validacao
              geral dos itens digitados.
              Serve para validar se a transferência somente para o mesmo código


PARAMETROS..: UPAR do tipo X : Nenhum

RETORNO.....: URET do tipo X : Deve retornar um valor logico indicando:

RETORNO .T. - Confirma movimento 
==================================================================================================

27/02/2007- MCVN - Valida o código destino 

                    MATA261
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Atribui valores as variaveis de Posicao utilizado no Siga Pyme   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local nPosCODOri:= 1 					//Codigo do Produto Origem
Local nPosDOri	:= 2					//Descricao do Produto Origem
Local nPosUMOri	:= 3					//Unidade de Medida Origem
Local nPosLOCOri:= 4					//Armazem Origem
Local nPosLcZOri:= 5					//Localizacao Origem
Local nPosCODDes:= Iif(!lPyme,6,5)		//Codigo do Produto Destino
Local nPosDDes	:= Iif(!lPyme,7,6)		//Descricao do Produto Destino
Local nPosUMDes	:= Iif(!lPyme,8,7)		//Unidade de Medida Destino
Local nPosLOCDes:= Iif(!lPyme,9,8)		//Armazem Destino
Local nPosLcZDes:= 10					//Localizacao Destino
Local nPosLoTCTL:= 12					//Lote de Controle
Local nPosNLOTE	:= 13					//Numero do Lote
Local nPosDTVAL	:= 14					//Data Valida
Local nPosPotenc:= 15					//Data Valida
Local nPosDTVALD:= 21					//Data Validade de Destino
Local nPosQUANT	:= Iif(!lPyme,16,9)	//Quantidade
Local nPosQTSEG	:= Iif(!lPyme,17,10)	//Quantidade na 2a. Unidade de Medida

*/

User Function A261PROD()
Local lRetorno := .T.

U_DIPPROC(ProcName(0),U_DipUsr()) // MCVN - 22/01/2009

aCols[n,6] := M->D3_COD 
If  aCols[n,1] <> aCols[n,6] .And. !Empty(aCols[n,6]) .And. !(Upper(U_DipUsr()) $ 'MCANUTO')
	MsgInfo("O produto de destino tem que ser o mesmo de origem!!!","Atencao","Alert")
	aCols[n,6]	:=	SPACE(6)
	M->D3_COD	:=	SPACE(6)
Endif
	
Return(lRetorno)
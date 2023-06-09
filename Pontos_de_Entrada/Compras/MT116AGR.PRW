#INCLUDE "PROTHEUS.CH"
//---------------------------------------------------------------------
/*/{Protheus.doc} MT116AGR
Ponto de Entrada da Nota de Conhecimento de Frete respons�vel 
pela inclus�o de notas de conhecimento de frete.
Ap�s a grava��o da NF de conhecimento de frete fora da transa��o.

@author 	Alessandro Smaha
@since 		02/02/2017
@version 	P11
@return 	Nil
/*/
//---------------------------------------------------------------------
User Function MT116AGR() 
 
// Atualiza o status do xml CT-e ingrado
U_NFAC025(4)

Return Nil     


//---------------------------------------------------------------------
/*/{Protheus.doc} M116ACOL
Este ponto de entrada tem o objetivo de permitir a manipula��o do 
aCols que ser� carregado para cada documento de entrada selecionado 
pela rotina de Conhecimento de Frete.
Ex.: Possibilita identificar o documento que est� sendo processado, 
para adicionar campos customizados pr�-existentes no ambiente com 
seus conte�dos preenchidos no aCols do conhecimento de frete.
LOCALIZA��O: Function A116INCLUI() - Fun��o que preenche o 
conhecimento com as notas de entrada.

@author 	Alessandro Smaha
@since 		02/02/2017
@version 	P11
@return 	Nil
/*/
//---------------------------------------------------------------------
User Function M116ACOL()

U_NFAC036I(ParamIXB)
	
Return                      

#INCLUDE "PROTHEUS.CH"
//---------------------------------------------------------------------
/*/{Protheus.doc} MT116AGR
Ponto de Entrada da Nota de Conhecimento de Frete responsável 
pela inclusão de notas de conhecimento de frete.
Após a gravação da NF de conhecimento de frete fora da transação.

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
Este ponto de entrada tem o objetivo de permitir a manipulação do 
aCols que será carregado para cada documento de entrada selecionado 
pela rotina de Conhecimento de Frete.
Ex.: Possibilita identificar o documento que está sendo processado, 
para adicionar campos customizados pré-existentes no ambiente com 
seus conteúdos preenchidos no aCols do conhecimento de frete.
LOCALIZAÇÃO: Function A116INCLUI() - Função que preenche o 
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

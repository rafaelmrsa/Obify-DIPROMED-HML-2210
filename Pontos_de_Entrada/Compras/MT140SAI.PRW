#INCLUDE "Protheus.CH"
//---------------------------------------------------------------------
/*/{Protheus.doc} MT140SAI
Responsável por controlar a interface de um pre-documento de entrada.
Ponto de entrada disparado antes do retorno da rotina ao browse.
Dessa forma, a tabela SF1 pode ser reposicionada antes do retorno 
ao browse.

@author Alessandro Smaha
@since 02/02/2017
@version P11
@return Nil
/*/
//---------------------------------------------------------------------
User Function MT140SAI()
     
// Verifica se é exclusão
If PARAMIXB[1] == 5  

	// Verifica se foi confirmado (Ok)
	If PARAMIXB[7] == 1
				
		// Atualiza o status do xml ingrado
		U_NFAC025(2)    
		
	EndIf
	
EndIf

Return


//---------------------------------------------------------------------
/*/{Protheus.doc} MT140PC
Ponto de Entrada para o tratamento do parâmetro MV_PCNFE (Nota Fiscal 
tem que ser amarrada a um Pedido de Compra ?)

@author Alessandro Smaha
@since 02/02/2017
@version P11
@return Nil
/*/
//---------------------------------------------------------------------
User Function MT140PC()

Local lRetOk := .T.

// Valida a obrigatoriedade da amarração do pedido de venda
lRetOk := U_NFAC025(3) 

Return lRetOk
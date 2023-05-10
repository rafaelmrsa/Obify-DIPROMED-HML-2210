/*                                                    São Paulo, 02 Jun 2006
----------------------------------------------------------------------------
Empresa....: Dipromed Comercio e Importação Ltda

Execução...: Antes da Ratiar os valores do pedido: Frete, seguro e demais des-
             pesas e outros.

Objetivo...: Permite alterar valores dos do pedido.



Parametros.: PARAMIXB[n,01] : ExpA1: Array com os itens a serem gerados                  
             PARAMIXB[n,02] : ExpC2: Serie da Nota Fiscal                                 
             PARAMIXB[n,03] : ExpL3: Mostra Lct.Contabil                                  
             PARAMIXB[n,04] : ExpL4: Aglutina Lct.Contabil                                
             PARAMIXB[n,05] : ExpL5: Contabiliza On-Line                                  
             PARAMIXB[n,06] : ExpL6: Contabiliza Custo On-Line                            
             PARAMIXB[n,07] : ExpL7: Reajuste de preco na nota fiscal                     
             PARAMIXB[n,08] : ExpN8: Tipo de Acrescimo Financeiro                         
             PARAMIXB[n,09] : ExpN9: Tipo de Arredondamento                               
             PARAMIXB[n,10] : ExpLA: Atualiza Amarracao Cliente x Produto                 
             PARAMIXB[n,11] : ExplB: Cupom Fiscal                                         
             PARAMIXB[n,12] : ExpCC: Numero do Embarque de Exportacao                     
             PARAMIXB[n,13] : ExpBD: Code block para complemento de atualizacao dos titu- 
                                     los financeiros.                                     
             PARAMIXB[n,14] : ExpBE: Code block para complemento de atualizacao dos dados 
                                     apos a geracao da nota fiscal.                       

Retorno....: a array do PARAMIXB com as modificações
             para os itens selecionados.

Autor......: Jailton B Santos (JBS)
Data.......: 20 Fev 2002
---------------------------------------------------------------------
*/

#Include "RwMake.Ch"

User Function M460ITPD()
Local aRetorno := Aclone(PARAMIXB) 
Public aDipItens := Aclone(PARAMIXB)                
U_DIPPROC(ProcName(0),U_DipUsr()) // MCVN - 22/01/2009
Return(aRetorno)
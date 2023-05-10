/*                                                    São Paulo, 02 Jun 2006
----------------------------------------------------------------------------
Empresa....: Dipromed Comercio e Importação Ltda

Execução...: Antes da Ratiar os valores do pedido: Frete, seguro e demais des-
             pesas.

Objetivo...: Alterar valores da capa do pedido

Parâmetros.: PARAMIXB[n,01] : N£mero do Pedido
             PARAMIXB[n,02] : Reservado
             PARAMIXB[n,03] : Reservado
             PARAMIXB[n,04] : Reservado
             PARAMIXB[n,05] : Total do Pedido
             PARAMIXB[n,06] : Valor do Frete
             PARAMIXB[n,07] : Valor do Seguro
             PARAMIXB[n,08] : Valor das despesas acessorias
             PARAMIXB[n,09] : Valor do Frete autonomo
             PARAMIXB[n,10] : Valor da Indeniza‡ao
             PARAMIXB[n,11] : Zerar quando alterado o Frete
             PARAMIXB[n,12] : Zerar quando alterado o Seguro
             PARAMIXB[n,13] : Zerar quando alterado as Despesas Acessorias
             PARAMIXB[n,14] : Zerar quando alterado o Frete autonomo
             PARAMIXB[n,15] : Zerar quando alterado a Indeniza‡ao

Retorno....: a array do PARAMIXB com as modificações
             para os itens selecionados.

Autor......: Jailton B Santos (JBS)
Data.......: 20 Fev 2002
---------------------------------------------------------------------
Observa‡„o, em alguns casos deve-se alterar o valor total do pedido.
Onde N ‚ variavel conforme o n£mero de pedidos a serem gerados
---------------------------------------------------------------------
*/
#Include "RwMake.Ch"

User Function M460RTPD()
Local aRetorno := Aclone(PARAMIXB)   
aRetorno[1][05] := nDipValPed  // Criada no M460Num
aRetorno[1][06] := SC5->C5_FRETE
aRetorno[1][11] := 0
Public aDipPedido := Aclone(aRetorno)
U_DIPPROC(ProcName(0),U_DipUsr()) // MCVN - 22/01/2009
Return(aRetorno)
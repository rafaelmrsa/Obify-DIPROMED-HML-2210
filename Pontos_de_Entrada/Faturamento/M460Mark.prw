/*                                                    S�o Paulo, 02 Jun 2006
----------------------------------------------------------------------------
Empresa....: Dipromed Comercio e Importa��o Ltda

Execu��o...: Ap�s a sele��o dos itens a serem faturados e antes da gera��o
             da nota fiscal.

Objetivo...: Mostra no aCols a quantidade empenhado do produto.
             Este empenho sera utilizado caso exista movimentacao de 
             transferencia entre os almoxarifados para este produto.

Par�metros.: Atrav�s da Vari�vel PARAMIXB pode-se verificar se o item 
             est� marcado ou n�o. PARAMIXB[1] cont�m  o caracter  que 
             corresponde ao "X" e PARAMIXB[2] indica se a opera��o deve
             ser para os iguais ou invertidos.

Retorno....: .T. ou .F.,  sendo  que .F.  n�o permite gerar nota fiscal
             para os itens selecionados.

Autor......: Jailton B Santos (JBS)
Data.......: 20 Fev 2002

----------------------------------------------------------------------------
*/
#include "rwmake.ch"

User Function M460MARK()



If Type("cDipMarca") == "U"
	Public cDipMarca
	Public lDipInverte
EndIf
U_DIPPROC(ProcName(0),U_DipUsr()) // MCVN - 22/01/2009
cDipMarca := PARAMIXB[1]
lDipInverte:= PARAMIXB[2]

Return(.t.)
#include "rwmake.ch"
/*
PONTO.......: A410EXC           PROGRAMA....: MATA410
DESCRIÇÄO...: RETORNA SE DEVE EXCLUIR O PEDIDO DE VEND
UTILIZAÇÄO..: Chamado no programa de exclusao de Pedidos de Venda
PARAMETROS..: <NENHUM>
RETORNO.....: Retorna um valor logico. Se retornar .F. impede a exclusão do Pedido de Venda.
OBSERVAÇÖES.: <NENHUM>
*/
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³  A410EXC  º Autor ³   Rodrigo Franco   º Data ³  16/05/2002  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Utilizado para atualizar Kardex do Pedido na Exclusao        º±±
±±º          ³ Utilizado para limpar o campo C6_PEDCLI do Pedido na Exclusaoº±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function A410EXC()
Local _lRetorno := .T.
Local _xAlias   := GetArea()
/*
U_DIPPROC(ProcName(0),U_DipUsr()) // JBS 05/10/2005 - Gravando o nome do Programa no SZU

IF _lRetorno 
	// Registrando a ocorrencia na Ficha Kardex 
	U_DiprKardex(M->C5_NUM,U_DipUsr(),,.T.,"07") // JBS 26/08/2005
ENDIF
*/
RestArea(_xAlias)
Return(_lRetorno)

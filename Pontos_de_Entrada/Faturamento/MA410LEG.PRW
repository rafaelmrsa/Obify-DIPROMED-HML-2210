#include "rwmake.ch"      
#include "Protheus.ch" 

/*
Este ponto de entrada pertence � rotina de pedidos de venda, MATA410(). 
Usado, em conjunto com o ponto MA410COR, para alterar os textos da legenda,
que representam o �status� do pedido.
*/
/*
�������������������������������������������������������������������������������
���Programa �MA410LEG  � Autor �   Maximo Canuto  � Data �  19/06/2009      ���
�������������������������������������������������������������������������������
*/
User Function MA410LEG()

U_DIPPROC(ProcName(0),U_DipUsr()) // JBS 05/10/2005 - Gravando o nome do Programa no SZU

//ponto de entrada para alterar as cores do status do pedido
_aCores := PARAMIXB        
aCores := {}

aCores := {{'BR_VERDE',"Separa��o Conclu�da"},;    
{'BR_VERMELHO',"Pedido Faturado"},;
{'BR_AZUL',"Bloqueado por Cr�dito"},;
{'BR_MARROM',"Rejeitado pelo Cr�dito"},;
{'BR_PINK',"Bloqueado pelo Operador"},;
{'BR_LARANJA',"Pedido Reservado"},;  // MCVN - 21/06/09
{'BR_CINZA',"Or�amento"},;
{'LIGHTBLU',"Programa��o"},;  
	{"BR_AMARELO"    , "Pedido(a vista) Aguardando Confirma��o "},;//Giovani Zago 09/02/12
{'BR_BRANCO',"Pedido com Problema ou Estornado"}}


Return(ACORES)

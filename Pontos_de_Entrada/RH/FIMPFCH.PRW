#Include "RwMake.Ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบPrograma  ณ  FIMPFCH บAutor  ณ   Maximo Canuto   บ Data ณ  18/10/10       บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออออออออออออนฑฑ
ฑฑบDesc.     ณ Esta rotina e utilizada para recalcular o valor do Frete      บฑฑ
ฑฑบ          ณ Ponto de Entrada para Alterar nome do programa Impressao      บฑฑ
ฑฑบ 		 ณ da Ficha de registro. alterar nome da variavel "cImpFch"		 บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function FIMPFCH()

Local _xArea := GetArea()

U_DIPPROC(ProcName(0),U_DipUsr()) // JBS 05/10/2005 - Gravando o nome do Programa no SZU

cImpFch := "U_ugper460"

RestArea(_xArea)

Return()

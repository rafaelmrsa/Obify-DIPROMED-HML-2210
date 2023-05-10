/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTK271LEG  บAutor  ณReginaldo Borges    บ Data ณ  09/06/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ  Ponto de entrada para alterar as legendas do              บฑฑ
ฑฑบ          ณ  atendimento do Call Center.                               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

#INCLUDE "PROTHEUS.CH" 


USER FUNCTION TK271LEG(cPasta) 
 
Local aCores 	:= {}							


If TkGetTipoAte() == "1" //Telemarketing
	
	/*=========================================================
	---------------------------------------------------
	Setores por orde e legenda
	---------------------------------------------------
	
	
	1 - Pendente Sac
	2 - Pendente Diretoria
	3 - Atendimento Encerrado
	4 - Atendimento Cancelado
	5 - Compartilhado
	6 - Pendente Transporte
	7 - Pendente Fiscal
	8 - Pendente Financeiro
	9 - Pendente Qualidade
	10- Pendente Esc.Fiscal
	11- Pendente Estoque
	12- Pendente Fornecedor
	13- Pendente Cliente
	14- Pendente Vendas
	15- Pendente Recebimento
	16- Pendente Expedi็ใo  
	18- Pendente Compras
	19- Pendente Ti
	

	1=SAC;2=Dir;3=Encerrada;6=Transp;7=Fiscal;8=Financ;9=Quali;10=Esc.Fisc;11=Estoq;12=Fornec;13=Cliente;14=Venda;15=Receb;16=Exped
	1=SAC;2=Dir;3=Encerrada;6=Transp;7=Fisc;8=Fina;9=Qual;10=Esc.Fisc;11=Est;12=Forn;13=Cli;14=Ven;15=Rec;16=Exped;17=Comp;18=TI
	==========================================================*/
	
	
	If cEmpant == "04"
		aCores := {	{"BR_VERMELHO"	  , "Pendente SAC          "},;
		{"BR_AZUL"  	  , "Pendente Diretoria    "},;
		{"BR_VERDE" 	  , "Atendimento Encerrado "},;
		{"BR_CANCEL"	  , "Atendimento Cancelado "},;
		{"BR_CINZA"	      , "Compartilhado         "},;
		{"BR_LARANJA"	  , "Pendente Transporte   "},;
		{"BR_AMARELO"	  , "Pendente Fiscal       "},;
		{"BR_PINK"		  , "Pendente Financeiro   "},;
		{"BR_BRANCO"	  , "Pendente Qualidade    "},;
		{"BR_PRETO_1"     , "Pendente Esc.Fiscal   "},;
		{"BR_PRETO_2"     , "Pendente Recebimento  "},;
		{"BR_PRETO_3"     , "Pendente Estoque      "},;
		{"BR_PRETO_4"     , "Pendente Produ็ใo     "},;
		{"BR_VERDE_ESCURO", "Pendente Fornecedor   "},;
		{"BR_AZUL_CLARO"  , "Pendente Cliente      "},;
		{"BR_VIOLETA"     , "Pendente Vendas       "},;
		{"BR_PRETO_C"     , "Pendente Compras      "},;
		{"BR_PRETO_A"     , "Pendente TI          "}}
		
	Else
		aCores := {	{"BR_VERMELHO"	  , "Pendente SAC "},;
		{"BR_AZUL"  	  , "Pendente Diretoria    "},;
		{"BR_VERDE" 	  , "Atendimento Encerrado "},;
		{"BR_CANCEL"	  , "Atendimento Cancelado "},;
		{"BR_CINZA"	      , "Compartilhado         "},;
		{"BR_LARANJA"	  , "Pendente Transporte   "},;
		{"BR_AMARELO"	  , "Pendente Fiscal       "},;
		{"BR_PINK"		  , "Pendente Financeiro   "},;
		{"BR_BRANCO"	  , "Pendente Qualidade    "},;
		{"BR_PRETO_1"     , "Pendente Esc.Fiscal   "},;
		{"BR_PRETO_2"     , "Pendente Recebimento  "},;
		{"BR_PRETO_3"     , "Pendente Estoque      "},;
		{"BR_PRETO_4"     , "Pendente Expedi็ใo    "},;
		{"BR_VERDE_ESCURO", "Pendente Fornecedor   "},;
		{"BR_AZUL_CLARO"  , "Pendente Cliente      "},;
		{"BR_VIOLETA"     , "Pendente Vendas       "},;
		{"BR_PRETO_C"     , "Pendente Compras      "},;
		{"BR_PRETO_A"     , "Pendente TI           "}}
		
	EndIf
	
EndIf



RETURN (aCores)     
   


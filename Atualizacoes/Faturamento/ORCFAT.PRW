#include "rwmake.ch" 

User Function Orcfat()

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ OrcFat   ³ Autor ³ Eduardo Riera         ³ Data ³ 22/12/97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Demonstrativo de Orcamento                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Especifico para Clientes Microsiga                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis Ambientais                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cbTxt		:= ""
cbCont	:= ""
nOrdem 	:= 0
Tamanho	:= "G" 
Limite	:= 132
cImpri   := ""
nTotal   := 0
Titulo := PadC(OemToAnsi("Or‡amento de Venda"),74)
cDesc1 := PadC(OemToAnsi("Este programa ira emitir o Orcamento de Venda, conforme"),74)
cDesc2 := PadC(OemToAnsi("os parametros solicitados"),74)
cDesc3 := PadC(OemToAnsi(""),74)
aReturn	:= { "Especial", 1,"Administracao", 1, 2, 1,"",1 }
NomeProg	:= "ORCFAT" 
cPerg		:= ""
nLastKey	:= 0 
lContinua:= .T.
nLin 		:= 99
wnrel 	:= "ORCFAT"

U_DIPPROC(ProcName(0),U_DipUsr()) //MCVN - 22/01/2009

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica as perguntas selecionadas, busca o padrao da Nfiscal           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//Pergunte(cPerg,.F.)
cString:="SCK"
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Envia controle para a funcao SETPRINT                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
wnrel:=SetPrint(cString,wnrel,cPerg,Titulo,cDesc1,cDesc2,cDesc3,.F.,,,,,.F.)
If ( nLastKey == 27 .Or. LastKey() == 27 )
   Return(.F.)
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica Posicao do Formulario na Impressora                 ³          
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
SetDefault(aReturn,cString)
If ( nLastKey == 27 .Or. LastKey() == 27 )
   Return(.F.)
Endif


RptStatus({|| RptDetail()})


Static Function RptDetail()

dbSelectArea("SCJ")
dbSetOrder(1)

dbSelectArea("SA1")
dbSetOrder(1)
dbSeek(xFilial()+SCJ->CJ_CLIENTE+SCJ->CJ_LOJA)

dbSelectArea("SE4")
dbSetOrder(1)
dbSeek(xFilial()+SCJ->CJ_CONDPAG)

nLin := 0
@ nLin,000 PSAY Repl("*",Limite)
nLin := nLin + 1
@ nLin,000 PSAY "*"+PadC("",Limite-2)+"*"
nLin := nLin + 1
@ nLin,000 PSAY "*"+PadC("Orcamento de Venda N."+SCJ->CJ_NUM,Limite-2)+"*"
@ nLin,000 PSAY " "+PadC("Orcamento de Venda N."+SCJ->CJ_NUM,Limite-2)+" "
nLin := nLin + 1
@ nLin,000 PSAY "*"+PadC("",Limite-2)+"*"
nLin := nLin + 1
@ nLin,000 PSAY Repl("*",Limite)
nLin := nLin + 1
@ nLin,000 PSAY "*"+PadC("",Limite-2)+"*"
nLin := nLin + 1
cImpri := " Cliente : "+SA1->A1_COD+"/"+SA1->A1_LOJA+" - "+SA1->A1_NOME
@ nLin,000 PSAY "*"+PadR(cImpri,Limite-2)+"*"
nLin := nLin + 1
@ nLin,000 PSAY "*"+PadC("",Limite-2)+"*"
nLin := nLin + 1
cImpri := " Cond.Pag: "+SCJ->CJ_CONDPAG+" - "+SE4->E4_DESCRI
@ nLin,000 PSAY "*"+PadR(cImpri,Limite-2)+"*"
nLin := nLin + 1
@ nLin,000 PSAY "*"+PadC("",Limite-2)+"*"
nLin := nLin + 1
cImpri := " Desconto: "+AllTrim(TransForm(SCJ->CJ_DESC1,X3Picture("CJ_DESC1")))+" + "+;
								AllTrim(TransForm(SCJ->CJ_DESC2,X3Picture("CJ_DESC2")))+" + "+;
								AllTrim(TransForm(SCJ->CJ_DESC3,X3Picture("CJ_DESC3")))+" + "+;
								AllTrim(TransForm(SCJ->CJ_DESC4,X3Picture("CJ_DESC4")))
@ nLin,000 PSAY "*"+PadR(cImpri,Limite-2)+"*"
nLin := nLin + 1
@ nLin,000 PSAY "*"+PadC("",Limite-2)+"*"
nLin := nLin + 1
//         1         2         3         4         5         6         7         8         9        10        11          12        13        14        15        16        17        18
//1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
//* xxxxxxxxxxxxxxx xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx                                  999,999,999.99 999,999,999.99 999,999,999,999.99 *
//                  xxxxxxxxxxxxxxx xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx                    9,999,999.99   9,999,999.99   9,999,999,999.99 *
//* Produto         Descricao                                                           Quantidade    Preco Venda              Total *
//*                 Componente      Descricao do Componente                                                                          *                   
@ nLin,000 PSAY Repl("*",Limite)
nLin := nLin + 1
@ nLin,000 PSAY "* Produto         Descricao                                                           Quantidade    Preco Venda              Total *"
nLin := nLin + 1
@ nLin,000 PSAY "*                 Componente      Descricao do Componente                                                                          *"
nLin := nLin + 1
@ nLin,000 PSAY Repl("*",Limite)

dbSelectArea("SCK")
dbSetOrder(1)
dbSeek(xFilial("SCK")+SCJ->CJ_NUM,.T.)

While ( !Eof() .And. SCK->CK_FILIAL == xFilial("SCK") .And. ;
			SCK->CK_NUM == SCJ->CJ_NUM )
	If ( nLin > 50 )
		nLin := 0
		@ nLin,000 PSAY Repl("*",Limite)
		nLin := nLin + 1
		@ nLin,000 PSAY "*"+PadC(OemToAnsi("Continua‡Æo..."),Limite-2)+"*"
		nLin := nLin + 1
		@ nLin,000 PSAY Repl("*",Limite)
		nLin := nLin + 1
		@ nLin,000 PSAY "* Produto         Descricao                                                           Quantidade    Preco Venda              Total *"
		nLin := nLin + 1
		@ nLin,000 PSAY "*                 Componente      Descricao do Componente                                                                          *"
		nLin := nLin + 1
		@ nLin,000 PSAY Repl("*",Limite)
		nLin := nLin + 1
   EndIf
	nLin := nLin + 1
	@ nLin,000 PSAY "* "+SCK->CK_PRODUTO
	@ nLin,019 PSAY SubStr(SCK->CK_DESCRI,1,30)
	@ nLin,082 PSAY SCK->CK_QTDVEN          PICTURE TM(SCK->CK_QTDVEN,14,2)
	@ nLin,097 PSAY SCK->CK_PRCVEN          PICTURE TM(SCK->CK_PRCVEN,14,2)
	@ nLin,112 PSAY SCK->CK_VALOR           PICTURE TM(SCK->CK_VALOR ,18,2)
	@ nLin,131 PSAY "*"

	nTotal := nTotal + SCK->CK_VALOR
	
	dbSelectArea("SCL")
	dbSetOrder(1)
	dbSeek(xFilial("SCL")+SCK->CK_NUM+SCK->CK_ITEM,.T.)

	While  ( !Eof() .And. xFilial("SCL") == SCL->CL_FILIAL .And. ;
					SCL->CL_NUM == SCK->CK_NUM .And.;
					SCL->CL_ITEMORC == SCK->CK_ITEM )
		If ( nLin > 50 )
			nLin := 0
			@ 000,000 PSAY "*"+PadC(OemToAnsi("Continua‡Æo..."),Limite-2)+"*"
			nLin := nLin + 1			
			@ nLin,000 PSAY Repl("*",Limite)
			nLin := nLin + 1			
			@ nLin,000 PSAY "* Produto         Descricao                                                           Quantidade    Preco Venda              Total *"
			nLin := nLin + 1			
			@ nLin,000 PSAY "*                 Componente      Descricao do Componente                                                                          *"  
			nLin := nLin + 1
			@ nLin,000 PSAY Repl("*",Limite)
			nLin := nLin + 1			
		EndIf
		nLin := nLin + 1			
		@ nLin,000 PSAY "* ----->"
		@ nLin,019 PSAY SCL->CL_PRODUTO
		@ nLin,035 PSAY SubStr(SCL->CL_DESCRI,1,30)
		dbSelectArea("SB1")
		dbSetOrder(1)
		dbSeek(xFilial("SB1")+SCL->CL_PRODUTO)
		dbSelectArea("SF4")
		dbSetOrder(1)
		dbSeek(xFilial("SF4")+SCK->CK_TES)
		
		nQtd := SCL->CL_QUANT*SCK->CK_QTDVEN
		@ nLin,084 PSAY nQtd              PICTURE TM(nQtd,12,2)
		@ nLin,131 PSAY "*"

		dbSelectArea("SCL")
		dbSkip()
	EndDo
	nLin := nLin + 1
	@ nLin,000 PSAY "*"+PadC("",Limite-2)+"*"
	
	dbSelectArea("SCK")
	dbSkip()	
EndDo			
nLin := nLin + 1	
@ nLin,000 PSAY Repl("*",Limite)
nLin := nLin + 1
nTotal := nTotal - (nTotal * SCJ->CJ_DESC1/100)
nTotal := nTotal - (nTotal * SCJ->CJ_DESC2/100)
nTotal := nTotal - (nTotal * SCJ->CJ_DESC3/100)
nTotal := nTotal - (nTotal * SCJ->CJ_DESC4/100)
@ nLin,000 PSAY "* Total do Orcamento -----> "
@ nLin,112 PSAY nTotal PICTURE TM(nTotal,18,2)
@ nLin,131 PSAY "*"
nLin := nLin + 1
@ nLin,000 PSAY Repl("*",Limite)
nLin := nLin + 1
@ nLin,000 PSAY ""

Set Device to Screen
Set Printer To
dbCommitAll()
DbSelectArea("SCJ")
DbSetOrder(1)
DbSelectArea("SCK")
DbSetOrder(1)
DbSelectArea("SCL")
DbSetOrder(1)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se impressao em Disco, chama Spool.                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If aReturn[5] == 1
	ourspool(wnrel)
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Libera relatorio para Spool da Rede.                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
MS_FLUSH()
Return(.T.)
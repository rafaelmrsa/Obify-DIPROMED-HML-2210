  
#include "prtopdef.ch" 
#include "rwmake.ch"    

User Function DIPR021()
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DIPR021   º Autor ³ Natalino Oliveira  º Data ³  17/12/02   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Impressao da Duplicata Dipromed                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Específico Dipromed                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Local _Valor, _cdata

//cPerg := "DUPLIC"
// FPADR(cPerg, cArq, cCampo, cTipo)  - Para ajustar o tamanho das perguntas no SX1- uso generico
PRIVATE cPerg  	:= U_FPADR( "DUPLIC","SX1","SX1->X1_GRUPO"," " ) //Função criada por Sandro em 19/11/09.

U_DIPPROC(ProcName(0),U_DipUsr()) // JBS 05/10/2005 - Gravando o nome do Programa no SZU


If !pergunte(cPerg,.T.)
	Return
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa a regua de processamento                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Processa({|| ImpDuplic()})

Return
      

Static Function ImpDuplic()

ProcRegua(Val(mv_par01))


//Objetos para tamanho e tipo das fontes
oFont1 	:= TFont():New( "Times New Roman",,11,,.T.,,,,,.F.)
oFont2 	:= TFont():New( "Tahoma",,10,,.T.,,,,,.F.)
oFont3	:= TFont():New( "Arial"       ,,11,,.F.,,,,,.F.)
oFont4	:= TFont():New( "Arial"       ,,09,,.F.,,,,,.F.)

oPrn := tAvPrinter():New("Dipromed - Duplicata")


//Inicia uma nova página
oPrn:StartPage()

// startando a impressora
oPrn:Say(0, 0, " ",oFont1,100) 
   

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicio do Processamento da Duplicata                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SA1")				
dbSetOrder(1)
dbSelectArea("SE1")				
dbSetOrder(1)
dbGOTOP()
// Checar a existencia do Titulo

If !dbSeek(xFilial("SE1")+mv_par03+mv_par01+mv_par02,.t.)
	ALERT("Titulo nao encontrado!")
	RETURN
endif

Private _lOkA := .T.

While !eof() .and. SE1->E1_FILIAL == xFILIAL() .and. SE1->E1_NUM  == mv_par01 ;
	.and. SE1->E1_PREFIXO == mv_par03 .and. SE1->E1_PARCELA  == mv_par02 

	IF SE1->E1_NUMBOR != mv_par04
		DbSkip()
		Loop
	EndIF

	If SE1->E1_PREFIXO #mv_par03
		dbSkip()
		Loop
	Endif

	IncProc("Título: "+ SE1->E1_PREFIXO + " " +SE1->E1_NUM)

	//³ Inicio de Levantamento dos Dados da Nota Fiscal              ³
	// * Cabecalho da Nota Fiscal
	xNUM_DUP  := SE1->E1_NUM             // Numero
	xSERIE    := SE1->E1_PREFIXO         // Serie
	xEMISSAO  := SE1->E1_EMISSAO         // Data de Emissao
	xTOT_FAT  := SE1->E1_VALOR           // Valor Total da Duplicata
	xCLIENTE  := SE1->E1_CLIENTE         // Codigo do Cliente
	xLOJA     := SE1->E1_LOJA            // Loja do Cliente
	xPARCELA  := SE1->E1_PARCELA         // Parcela da Duplicata
	xVENCREA  := SE1->E1_VENCTO          // Vencto Real da Duplicata
	xVALJUR   := SE1->E1_VALJUR          // Valor da Taxa de Permanencia
	dbSelectArea("SA1")                // * Cadastro de Clientes
	dbSetOrder(1)
	dbSeek(xFilial("SA1")+xCLIENTE+xLOJA)
	xNOME_CLI := SA1->A1_NOME               // Nome
	xEND_CLI  := SA1->A1_ENDCOB             // Endereco
	xBAIRRO   := SA1->A1_BAIRROC            // Bairro
	xCEP      := SA1->A1_CEPC               // CEP
	xMUN_CLI  := SA1->A1_MUNC               // Municipio
	xEST_CLI  := SA1->A1_ESTC               // Estado
	xCGC_CLI  := SA1->A1_CGC                // CGC
	xTEL      := SA1->A1_TEL                // Telefone
	XINSCR    := SA1->A1_INSCR
	
    If _lOKA
       ImpA()
       SE1->(DbSkip())
       Loop
	Endif

End

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³                         IMPRESSAO                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

//finaliza a pagina
oPrn:EndPage()


//Imprime em tela p/ preview
oPrn:Preview()

oPrn:End()

Return

Static Function ImpA()

DbSelectArea("SE1")
_cData:= Dtoc(SE1->E1_VENCTO)
_valor:= TRANSFORM( SE1->E1_VALOR ,"@E 999,999,999.99") 
xExtenso:=Extenso(SE1->E1_VALOR,.F.,SE1->E1_MOEDA)
xExtenso:=xExtenso + " " + Repl ("*",150-len(xExtenso))
xExtenso1:=subs(xExtenso,001,074)
xExtenso2:=subs(xExtenso,077,073)

oPrn:Say (400, 1530, DTOC(XEMISSAO),oFont3,100)
oPrn:Say (590, 510, xNUM_DUP+IIF(xPARCELA<>" ",'-'+xPARCELA,"") ,oFont3,100)
oPrn:Say (590, 910, _Valor,oFont3,100)
oPrn:Say (590, 1400,xNUM_DUP+IIF(xPARCELA<>" ",'-'+xPARCELA,""),oFont3,100)
oPrn:Say (590, 1740, Dtoc(xVENCREA),oFont3,100)

oPrn:Say (0750, 0800, ALLTRIM(XNOME_CLI),oFont3,100)
oPrn:Say (0830, 0800, alltrim(substr(xEND_CLI,1,42)) + "  -  " + TRANSFORM(xCEP,"@R 99999-999"),oFont4,100)
oPrn:Say (0880, 0800, ALLTRIM(xMUN_CLI) ,oFont3,100)
oPrn:Say (0880, 2000, ALLTRIM(xEST_CLI) ,oFont3,100)
oPrn:Say (0930, 0800, ALLTRIM(xMUN_CLI) ,oFont3,100)

//oPrn:Say (01030,0800, SA1->A1_ENDCOB,oFont4,100)

_cCGC := Transform(XCGC_CLI, "@R 99.999.999/9999-99")
_cInsc:= Transform(XINSCR, "@R 999.999.999.999")

oPrn:Say (00980,0800, _cCGC,oFont3,100)
oPrn:Say (00980,1550, _cInsc,oFont3,100)

oPrn:Say (1060, 0755, xExtenso1,oFont2,100)
oPrn:Say (1120, 0755, xExtenso2,oFont2,100)
        
/* Antigo - MCVN 16/11/09
oPrn:Say (370, 1530, DTOC(XEMISSAO),oFont3,100)
oPrn:Say (540, 510, xNUM_DUP+IIF(xPARCELA<>" ",'-'+xPARCELA,"") ,oFont3,100)
oPrn:Say (540, 910, _Valor,oFont3,100)
oPrn:Say (540, 1400,xNUM_DUP+IIF(xPARCELA<>" ",'-'+xPARCELA,""),oFont3,100)
oPrn:Say (540, 1740, Dtoc(xVENCREA),oFont3,100)

oPrn:Say (0730, 0800, ALLTRIM(XNOME_CLI),oFont3,100)
oPrn:Say (0790, 0800, alltrim(substr(xEND_CLI,1,42)) + "  -  " + TRANSFORM(xCEP,"@R 99999-999"),oFont4,100)
oPrn:Say (0860, 0800, ALLTRIM(xMUN_CLI) ,oFont3,100)
oPrn:Say (0860, 2000, ALLTRIM(xEST_CLI) ,oFont3,100)

//oPrn:Say (01030,0800, SA1->A1_ENDCOB,oFont4,100)

_cCGC := Transform(XCGC_CLI, "@R 99.999.999/9999-99")
_cInsc:= Transform(XINSCR, "@R 999.999.999.999")

oPrn:Say (00950,0800, _cCGC,oFont3,100)
oPrn:Say (00950,1550, _cInsc,oFont3,100)

oPrn:Say (1030, 0755, xExtenso1,oFont2,100)
oPrn:Say (1090, 0755, xExtenso2,oFont2,100)
*/

Return()

/*====================================================================================\
|Programa  | EtiqKimB      | Autor | Eriberto Elias             | Data | 28/10/2004   |
|=====================================================================================|
|Descrição | Impressao de etiquetas para produtos Kimberly                            |
|=====================================================================================|
|Sintaxe   | ETIQKIMB()                                                               |
|=====================================================================================|
|Uso       | Especifico DIPROMED                                                      |
|=====================================================================================|
|........................................Histórico....................................|
|Rafael    | DD/MM/AA - Descrição                                                     |
|Eriberto  | DD/MM/AA - Descrição                                                     |
\====================================================================================*/
#include "rwmake.ch"     

User Function ETIQKIMB()

Local _aProdutos := {}
// Private cPerg   := "ETIQKI"
// FPADR(cPerg, cArq, cCampo, cTipo)  - Para ajustar o tamanho das perguntas no SX1- uso generico
PRIVATE cPerg  	:= U_FPADR( "ETIQKI","SX1","SX1->X1_GRUPO"," " ) //Função criada por Sandro em 19/11/09.

Private mv_par03 := Space(06)

U_DIPPROC(ProcName(0),U_DipUsr()) // JBS 05/10/2005 - Gravando o nome do Programa no SZU

AjustaSX1(cPerg)

If !pergunte(cPerg,.T.)
	Return
EndIf

Processa({|| ImpEtiKimB()})

Return
      
////////////////////////////////////////////////////////////
Static Function ImpEtiKimB()

Private _lOkA := .T.

ProcRegua(Val(mv_par01))


//Objetos para tamanho e tipo das fontes
oFont1 	:= TFont():New( "Times New Roman",,20,,.T.,,,,,.F.)
oFont2 	:= TFont():New( "Tahoma",         ,10,,.T.,,,,,.F.)
oFont3	:= TFont():New( "Arial",          ,11,,.F.,,,,,.F.)
oFont4	:= TFont():New( "Arial",          ,09,,.F.,,,,,.F.)

oPrn := TMSPrinter():New("Dipromed - Duplicata")

//Inicia uma nova página
oPrn:StartPage()

// startando a impressora
oPrn:Say(0, 0, " ",oFont1,100) 
   

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicio do Processamento da Duplicata                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SD2")
dbSetOrder(2)
If !dbSeek(xFilial("SD2") + mv_par01 , .t.)
	ALERT("Nota Fiscal nao encontrada !")
	Return
endif

dbSelectArea("SB1")				
dbSetOrder(1)
dbGoTop()
// Checar a existencia do Titulo

If !dbSeek(xFilial("SB1") + SD2->D2_COD , .t.)
	ALERT("Produto nao localizado !")
	Return
EndIf

xCODIGO	:= SB1->B1_COD        // Numero
xDESCRI	:= SB1->B1_DESC       // Serie
// parei aqui

//D2_LOTECTL
//D2_DTVALID

ImpA()

/*
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

	// Inicio de Levantamento dos Dados da Nota Fiscal
	// Cabecalho da Nota Fiscal
	xNUM_DUP  := SE1->E1_NUM             // Numero
	xSERIE    := SE1->E1_PREFIXO         // Serie
	xEMISSAO  := SE1->E1_EMISSAO         // Data de Emissao
	xTOT_FAT  := SE1->E1_VALOR           // Valor Total da Duplicata
	xCLIENTE  := SE1->E1_CLIENTE         // Codigo do Cliente
	xLOJA     := SE1->E1_LOJA            // Loja do Cliente
	xPARCELA  := SE1->E1_PARCELA         // Parcela da Duplicata
	xVENCREA  := SE1->E1_VENCTO          // Vencto Real da Duplicata
	xVALJUR   := SE1->E1_VALJUR          // Valor da Taxa de Permanencia
	dbSelectArea("SA1")                  // Cadastro de Clientes
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
	SB1->(DbSkip())
	Loop
Endif

End

*/

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³                         IMPRESSAO                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

//finaliza a pagina
oPrn:EndPage()


//Imprime em tela p/ preview
oPrn:Preview()

oPrn:End()

Return





///////////////////////////////////////////////////////////////////////////////////////////
Static Function ImpA()

DbSelectArea("SB1")
_cData:= Dtoc(SE1->E1_VENCTO)
_valor:= TRANSFORM( 100000.00,"@E 999,999,999.99") 
/*
xExtenso:=Extenso(SE1->E1_VALOR,.F.,SE1->E1_MOEDA)
xExtenso:=xExtenso + " " + Repl ("*",150-len(xExtenso))
xExtenso1:=subs(xExtenso,001,074)
xExtenso2:=subs(xExtenso,077,073)
*/

oPrn:Say (001, 010, _cData,oFont3,100)
oPrn:Say (050, 010, xCODIGO,oFont3,100)
oPrn:Say (100, 010, _Valor ,oFont3,100)
oPrn:Say (150, 010, xDESCRI,oFont3,100)
oPrn:Say (200, 010, Dtoc(date()),oFont3,100)

oPrn:Say (250, 010, ALLTRIM(XDESCRI),oFont1,100)
oPrn:Say (350, 010, alltrim(substr("rafael de campos falco",1,42)) + "  -  " + TRANSFORM("06223-150","@R 99999-999"),oFont4,100)
oPrn:Say (400, 010, ALLTRIM("teste de impressão de caracter") ,oFont4,100)
oPrn:Say (450, 010, ALLTRIM("imprimindo etiqueta da Kimberly") ,oFont4,100)

//oPrn:Say (01030,0800, SA1->A1_ENDCOB,oFont4,100)

_cCGC := Transform("99999999999999", "@R 99.999.999/9999-99")
_cInsc:= Transform("999999999999", "@R 999.999.999.999")

oPrn:Say (500,010, _cCGC,oFont1,100)
oPrn:Say (570,010, _cInsc,oFont1,100)

/*
oPrn:Say (1080, 0755, xExtenso1,oFont2,100)
oPrn:Say (1140, 0755, xExtenso2,oFont2,100)
*/

Return()


/////////////////////////////////////////////////////////////////////////////
Static Function AjustaSX1(cPerg)
_sAlias := Alias()
dbSelectArea("SX1")
dbSetOrder(1)

aRegs:={}

//------------ Grupo/Ordem/Pergunta/PERGING/PERGESP/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05/F3
aAdd(aRegs,{cPerg,"01","Nota Fiscal nro. ?","","","mv_ch1","C",15,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","SD2"})
aAdd(aRegs,{cPerg,"02","Informe qtde     ?","","","mv_ch2","N",02,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","",""})

For i:=1 to Len(aRegs)
	If !dbSeek(cPerg+aRegs[i,2])
		RecLock("SX1",.T.)
		For j:=1 to FCount()
			If j <= Len(aRegs[i])
				FieldPut(j,aRegs[i,j])
			Endif
		Next
		SX1->(MsUnlock())
	Endif
Next

dbSelectArea(_sAlias)
Return
///////////////////////////////////////////////////////////////////////////

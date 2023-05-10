#include "rwmake.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Fun‡…o    ³ DUPLICATA ³ Autor ³  Rodrigo Franco    ³ Data ³ 18/12/2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Duplicata Dipromed                                         ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function Dipr006()

//³ Variaveis utilizadas para parametros                         ³
//³ mv_par01             // Da Duplicata                         ³
//³ mv_par02             // Ate a Duplicata                      ³
//³ mv_par03             // Da Serie                             ³
U_DIPPROC(ProcName(0),U_DipUsr()) // JBS 05/10/2005 - Gravando o nome do Programa no SZU
mv_par01	:=Space(6)
mv_par02	:=Space(1)
mv_par03	:=Space(3)
CbTxt:=""
CbCont:=""
nOrdem 	:=0
tamanho	:="M"
limite	:=080
titulo 	:=PADC("Duplicatas",74)
cDesc1	:=PADC("Este programa ira emitir Duplicatas da Dipromed.",74)
cDesc2 	:=""
cDesc3 	:=""
cNatureza:=""
cString:="SE1"
aReturn := { "Especial", 1,"Administracao", 2, 2, 1, "",1 }
nomeprog:="DIPR006"
cPerg:="DUPLIC"
nLastKey:= 0
lContinua := .T.
nLin:=0
wnrel := "DUPLIC"
nTamNf:=32

// FPADR(cPerg, cArq, cCampo, cTipo)
PRIVATE cPerg  	:= U_FPADR( "DUPLIC","SX1","SX1->X1_GRUPO"," " ) //Criado por Sandro em 19/11/09. 
              
//³ Verifica as perguntas selecionadas                          ³
pergunte(cPerg,.F.)

//³ Envia controle para a funcao SETPRINT                       ³
wnrel:=SetPrint(cString,wnrel,cPerg,Titulo,cDesc1,cDesc2,cDesc3,.T.)
If nLastKey == 27
	Return
Endif

SetDefault(aReturn,cString)

VerImp()
RptStatus({|| Duplic()})
Return
Static Function Duplic()

//³ Guarda Empresa que esta sendo emitido nota fiscal            ³
dbSelectArea("SE1")                // * Cabecalho da Nota Fiscal
dbSetOrder(1)
dbSeek(xFilial() + mv_par03 + mv_par01 + mv_par02,.T.)
While !eof() .and. SE1->E1_FILIAL == xFILIAL() .and. SE1->E1_NUM  == mv_par01 ;
	.and. SE1->E1_PREFIXO == mv_par03 .and. SE1->E1_PARCELA  == mv_par02 .and. lContinua == .T.
	IF SE1->E1_NUMBOR != mv_par04
		DbSkip()
		Loop
	EndIF
	If lAbortPrint
		@ 00,01 PSAY "** CANCELADO PELO OPERADOR **"
		lContinua := .F.
		Exit
	Endif
	If SE1->E1_PREFIXO #mv_par03
		dbSkip()
		Loop
	Endif
	nLinIni:=nLin                      // Armazema Linha Inicial da Impressao
	
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
	@ 05, 050 PSAY xEMISSAO
	@ 09, 016 PSAY xNUM_DUP+IIF(xPARCELA<>" ",'-'+xPARCELA,"")
	@ 09, 029 PSAY xTOT_FAT PICTURE "@E 999,999,999.99"
	@ 09, 048 PSAY xNUM_DUP+IIF(xPARCELA<>" ",'-'+xPARCELA,"")
	@ 09, 057 PSAY xVENCREA
	@ 12, 026 PSAY ALLTRIM(xNOME_CLI)                     //+ "  -  C.G.C.: " + TRANSFORM(xCGC_CLI,"@R 99.999.999/9999-99")
	@ 14, 026 PSAY alltrim(substr(xEND_CLI,1,42)) + "  -  " + TRANSFORM(xCEP,"@R 99999-999")
	@ 15, 026 PSAY ALLTRIM(xMUN_CLI) + "             " + ALLTRIM(xEST_CLI)
	@ 17, 026 PSAY TRANSFORM(xCGC_CLI,"@R 99.999.999/9999-99")
	EXTENSO:=EXTENSO(xTOT_FAT,.F.,SE1->E1_MOEDA)
	@ 19,026 PSAY Subs(RTRIM(SUBS(EXTENSO(xTOT_FAT),1,50)) + REPLICATE("*",50),1,50)
	nLin := nLin + 1
	@ 20,26 PSAY Subs(RTRIM(SUBS(EXTENSO(xTOT_FAT),51,50)) + REPLICATE("*",50),1,50)
	@ 26, 00 PSAY ""
	SetPrc(0,0)
	nLin:=nLinIni+nTamNF    // Posiciona proximo formulario
	p_cnt:=nTamNf           //
	dbSelectArea("SE1")
	dbSkip()
End

//³ Fechamento do Programa da Duplicata                          ³
dbCommitAll()
SetPrc(0,0)
dbSelectArea("SE1")
dbSetOrder(1)
Set Device To Screen
If aReturn[5] == 1
	Set Printer TO
	dbcommitAll()
	ourspool(wnrel)
Endif

MS_FLUSH()

Return

********************
Static Function Verimp()
********************
nLin:= 0
nLinIni:=0
If aReturn[5]==2
	nOpc       := 1
	While .T.
		SetPrc(0,0)
		dbCommitAll()
		IF MsgYesNo("Fomulario esta posicionado ? ")
			nOpc := 1
		ElseIF MsgYesNo("Tenta Novamente ? ")
			nOpc := 2
		Else
			nOpc := 3
		Endif
		Do Case
			Case nOpc==1
				lContinua:=.T.
				Exit
			Case nOpc==2
				Loop
			Case nOpc==3
				lContinua:=.F.
				Return
		EndCase
	End
Endif

Return
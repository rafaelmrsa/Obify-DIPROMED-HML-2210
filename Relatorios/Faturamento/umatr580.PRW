#INCLUDE "UMATR580.CH"
#INCLUDE "FIVEWIN.CH"
#INCLUDE "TOPCONN.CH"
/*====================================================================================\
|Programa  | UMATR580.PRW  | Autor | Jailton B Santos, JBS   | Data | 06 Set 2005     |
|=====================================================================================|
|DescriÁ„o | Estatistica de Vendas por Ordem de Vendedor                              |
|          |                                                                          |
|=====================================================================================|
|Objetivo  | Mostrar o volume de vendas por vendedor                                  |
|          |                                                                          |
|=====================================================================================|
|Sintaxe   | UMATTR580()                                                              |
|=====================================================================================|
|Uso       | Especifico DIPROMED                                                      |
|=====================================================================================|
|HistÛrico | 02 Fev 2007 - Incluindo totais por televendas e representantes - MCVN    |
|          | 03 Mai 2007 - Incluindo coluna outros fornecedores - MCVN                |
|          | 25 Mai 2007 - Incluindo coluna com total de pedidos liberados  - MCVN    |
|          | 16 Out 2007 - Tratamento do Filtro de Vendedores                         |
|          |             - Incluido Parametro e Filtro por Grupo de Clientes          |
|          | 06 Ago 2009 - Inclus„o de metas e percentual atingido                    |
|          |             - Possibilitando selecionar outro fornecedor no campo KC     |
\====================================================================================*/
User Function uMatr580()
Local CbTxt  := ""
Local titulo := OemToAnsi(STR0001)	//"Faturamento por Vendedor"
Local cDesc1 := OemToAnsi(STR0002)	//"Este relatorio emite a relacao de faturamento. Podera ser"
Local cDesc2 := OemToAnsi(STR0003)	//"emitido por ordem de Cliente ou por Valor (Ranking).     "
Local CbCont,cabec1,cabec2,wnrel
Local tamanho:="G"
Local limite :=220
Local cString:="SF2"
Local lContinua:=.T.
Local cMoeda,nMoeda
Local cNFiscal
Local cUserAut :=	GetMV("MV_URELFAT")

PRIVATE nVAlor4:=0
PRIVATE nVAlor5:=0
PRIVATE aReturn:= { STR0005, 1,STR0006, 1, 2, 1, "",1 }		//"Zebrado"###"Administracao"
PRIVATE nomeprog:="UMATR580"
PRIVATE aLinha:= { },nLastKey := 0

//PRIVATE cPerg:="MTR580"
// FPADR(cPerg, cArq, cCampo, cTipo)  - Para ajustar o tamanho das perguntas no SX1- uso generico
PRIVATE cPerg  	:= U_FPADR( "MTR580","SX1","SX1->X1_GRUPO"," " ) //FunÁ„o criada por Sandro em 19/11/09.

PRIVATE cFornVend := AllTrim(GETNEWPAR("MV_FORNVEN",""))
PRIVATE aPedLib   :={}
PRIVATE aPedBLoq  :={}
Private cVendInt   := GetMV("MV_DIPVINT")// MCVN - 06/05/09
Private cVendExt   := GetMV("MV_DIPVEXT")// MCVN - 06/05/09
//-------------------------------------------------------------------------------------------------------------------------------
// JBS 14/04/2010: Tratamento para montar a query quando for executado para Health Quality apenas, ou para o Grupo Dipromed.
//-------------------------------------------------------------------------------------------------------------------------------
Private aEmpresa  := {} // Empresa e filial para processar as querys

cFornVend += "\000996" // N„o coloquei no parametro por que ele È utilizado em outras rotinas

If !(Upper(U_DipUsr()) $ cUserAut .Or. Upper(U_DipUsr()) $ cVendInt .or. Upper(U_DipUsr()) $ cVendExt)
	Alert(Upper(U_DipUsr())+", vocÍ n„o tem autorizaÁ„o para utilizar esta rotina. Qualquer d˙vida falar com Eriberto!","AtenÁ„o")
	Return()
Endif
//-------------------------------------------------------------------------------------------------------------------------------
// JBS 15/04/2010
// Se a empresa e filial corrente forem 04 e 01, forÁa o relatorio de forma individual, para n„o mostrar valores 
// para pessoas que n„o possuem a necessidade da informaÁ„o.
// Para as demais, permite o usuario escolher os 4 diferentes tipos da informaÁ„o.
//-------------------------------------------------------------------------------------------------------------------------------
If cEmpAnt == '04' .and. cFilAnt == '01'  // JBS 15/04/2010
	Private nConsolida := 2 
	Private lMatrizHq  := .T. // JBS 18/06/2010 
Else
	Private nConsolida := Aviso('AtenÁ„o','Imprime relatorio consolidando empresas Grupo ?',{'DIPROMED','Individual','Matrizes','Todas'})
	Private lMatrizHq  := .F.  // JBS 18/06/2010  
EndIf

U_DIPPROC(ProcName(0),U_DipUsr()) // JBS 05/10/2005 - Gravando o nome do Programa no SZU
//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥ Verifica as perguntas selecionadas                           ≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
//AjustaSX1(cPerg)      
//-------------------------------------------------------------------------------------------------------------------------------
// Determina quais empresas devem ser processadas  - JBS 14/04/2010
//-------------------------------------------------------------------------------------------------------------------------------
do case
	case nConsolida == 1 ;	aEmpresa  := {{'010','04'},{'010','04'},{"010","01"}}  //
	case nConsolida == 2 ;	aEmpresa  := {{SM0->M0_CODIGO+"0",SM0->M0_CODFIL }}
	case nConsolida == 3 ;	aEmpresa  := {{'010','01'},{'010','01'}}  //
	case nConsolida == 4 ;	aEmpresa  := {{'010','01'},{'010','04'}}//,{'040','01'},{'040','04'}}  //
	OtherWise
		Return(.F.)
endcase

Pergunte(cPerg,.T.)
//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥ Variaveis utilizadas para parametros                         ≥
//≥ mv_par01         // A partir da data                         ≥
//≥ mv_par02         // Ate a data                               ≥
//≥ mv_par03         // Do Vendedor                              ≥
//≥ mv_par04         // Ao Vendedor                              ≥
//≥ mv_par05         // Ordem (decrescente)?                     ≥
//≥ mv_par06         // Moeda                                    ≥
//≥ mv_par07         // Inclui DevoluáÑo                         ≥
//≥ mv_par08         // TES Qto Faturamento                      ≥
//≥ mv_par09         // TES Qto Estoque                          ≥
//≥ MV_PAR14         // Outro Fornecedor ?                       ≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
                                                                         

//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥ Envia controle para a funcao SETPRINT                        ≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
wnrel:="UMATR580"
wnrel:=SetPrint(cString,wnrel,cPerg,@titulo,cDesc1,cDesc2,"",.F.,"",,Tamanho)

If nLastKey==27
	Set Filter to
	Return
Endif

SetDefault(aReturn,cString)

If nLastKey == 27
	Set Filter to
	Return
Endif

RptStatus({|lEnd| C580Imp(@lEnd,wnRel,cString)},Titulo)

Return

/*/
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥FunáÖo    ≥ C580IMP  ≥ Autor ≥ Rosane Luciane Chene  ≥ Data ≥ 09.11.95 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÖo ≥ Chamada do Relatorio                                       ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥ Uso      ≥ MATR580	  	                                              ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
/*/
Static Function C580Imp(lEnd,WnRel,cString)

Local titulo := OemToAnsi(STR0001)		//"Faturamento por Vendedor"
Local cDesc1 := OemToAnsi(STR0002)		//"Este relatorio emite a relacao de faturamento. Podera ser"
Local cDesc2 := OemToAnsi(STR0003)		//"emitido por ordem de Cliente ou por Valor (Ranking).     "
Local CbCont,cabec1,cabec2
Local tamanho:="G"
Local limite :=220
Local lContinua := .T.
Local aCampos := {}
Local aTam	  := {}
Local nAg1:=0,nAg2:=0,nAg3:=0, nAg4:=0,nAg5:=0,nAg6:=0,nAg7:=0,nRank:=0,cVend,cVenTipo,nTotTel:=0,nTotKCTel:=0,nTotFornTel:=0,nTotPedKcTel:=0,nTotMetaTel:=0
Local nAg8:=0         // JBS 17/06/2010
Local nAg9:=0         // RSB 29/12/2014
Local nTotHqCD:=0     // JBS 17/06/2010
Local nTotPedBlTel:=0 // RSB 29/12/2014
Local nTo
Local nMoeda, cMoeda:="", nValor1, nValor2
Local cEstoq := If( (MV_PAR09 == 1),"S",If( (MV_PAR09 == 2),"N","SN" ) )
Local cDupli := If( (MV_PAR08 == 1),"S",If( (MV_PAR08 == 2),"N","SN" ) )
Local nTotalPed  := 0  
Local nTotalPedb := 0

Local cArqExcell := "\Excell-DBF\"+U_DipUsr()+"-UMATR580"
Private cDestino := "C:\EXCELL-DBF\"

Private aTamVal:= { 16, 2 }

Private nDecs:=msdecimais(mv_par06)

nTipo:=IIF(aReturn[4]==1,15,18)

//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥ Variaveis utilizadas para Impressao do Cabecalho e Rodape    ≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
cbtxt := SPACE(10)
cbcont:= 0
li    := 80
m_pag := 1
nMoeda:= mv_par06
cMoeda:= GetMv("MV_MOEDA"+LTrim(STR(nMoeda)))     

//-- Retirado por Daniel em 05/05/2011
//-------------------------------------------------------------------------------------------------------
// Ajustes para consolidar Dipromed Matriz e CD a partir de 01/05/2011   - MCVN 03/05/2011
//If nConsolida == 1 .And. dTos(MV_PAR01) >= '20110501'
//	aEmpresa := {{'010','04'},{'010','01'}}  // Empresa e filial para processar as querys
//Endif
//-------------------------------------------------------------------------------------------------------

IF mv_par05 = 1
	titulo := OemToAnsi(STR0007)+cMoeda	//"FATURAMENTO POR VENDEDOR  (CODIGO) - "
Else
	titulo := OemToAnsi(STR0008)+cMoeda	//"FATURAMENTO POR VENDEDOR  (RANKING) - "
EndIF

cabec1 := Space(00) + "Periodo: "+dtoc(mv_par01)+" Ate "+dtoc(mv_par02)
/*  
     JBS 19/06/2010 - Passou a imprimir o Cabec, na linha de processamento e adminstradr colunas

If      (mv_par05 == 2 .and. !Empty(MV_PAR14) .And. !Empty(mv_par13))
	//	cabec2 := STR0009+"       RANKING          %                META              "+Space(20-Len(Alltrim(Posicione("SA2",1,xFilial("SA2")+mv_par13,"SA2->A2_NREDUZ"))))+Alltrim(Posicione("SA2",1,xFilial("SA2")+mv_par13,"SA2->A2_NREDUZ"))+"                    "+Space(20-Len(Alltrim(Posicione("SA2",1,xFilial("SA2")+MV_PAR14,"SA2->A2_NREDUZ"))))+Alltrim(Posicione("SA2",1,xFilial("SA2")+MV_PAR14,"SA2->A2_NREDUZ"))+"   PV LIBERADOS"
	cabec2 := STR0009+"       RANKING          %                META              "+Posicione("SA2",1,xFilial("SA2")+mv_par13,"SA2->A2_NREDUZ")+"                    "+Posicione("SA2",1,xFilial("SA2")+MV_PAR14,"SA2->A2_NREDUZ")+"   PV LIBERADOS"

ElseIf  (mv_par05 == 2 .and. !Empty(MV_PAR14))

	cabec2 := STR0009+"       RANKING          %                META              "+Posicione("SA2",1,xFilial("SA2")+MV_PAR14,"SA2->A2_NREDUZ")+"          PV LIBERADOS"

ElseIf  (mv_par05 == 2 .and. !Empty(mv_par13))
	cabec2 := STR0009+"       RANKING          %                META              "+Posicione("SA2",1,xFilial("SA2")+mv_par13,"SA2->A2_NREDUZ")+"          PV LIBERADOS"
ElseIf  (mv_par05 == 2 .and.  Empty(MV_PAR14) .and. Empty(mv_par13))
	cabec2 := STR0009+"       RANKING          %                META              PV LIBERADOS"
ElseIf	(mv_par05 <> 2 .and. !Empty(MV_PAR14) .and. !Empty(mv_par13))
	cabec2 := STR0009+"                        %                META              "+Posicione("SA2",1,xFilial("SA2")+mv_par13,"SA2->A2_NREDUZ")+"                    "+Posicione("SA2",1,xFilial("SA2")+MV_PAR14,"SA2->A2_NREDUZ")+"   PV LIBERADOS"
ElseIf	(mv_par05 <> 2 .and. !Empty(MV_PAR14))
	cabec2 := STR0009+"                        %                META              "+Posicione("SA2",1,xFilial("SA2")+MV_PAR14,"SA2->A2_NREDUZ")+"          PV LIBERADOS"
ElseIf	(mv_par05 <> 2 .and. !Empty(mv_par13))
	cabec2 := STR0009+"                        %                META              "+Posicione("SA2",1,xFilial("SA2")+mv_par13,"SA2->A2_NREDUZ")+"          PV LIBERADOS"
Else
	cabec2 := STR0009+"                        %                META              PV LIBERADOS"
Endif
*/
//"CODIGO   NOME DO VENDEDOR                                FATURAMENTO          VALOR DA                 VALOR  RANKING"
//"                                                           SEM ICM           MERCADORIA                TOTAL         "

//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥ Cria array para gerar arquivo de trabalho                    ≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
AADD(aCampos,{ "TB_VEND"    ,"C",AvSx3("F2_VEND1"  ,3),AvSx3("F2_VEND1"  ,4)})
AADD(aCampos,{ "TB_NOME"    ,"C",AvSx3("A3_NREDUZ"  ,3),AvSx3("A3_NREDUZ"  ,4)})
AADD(aCampos,{ "TB_EMISSAO" ,"D",AvSx3("F2_EMISSAO",3),AvSx3("F2_EMISSAO",4)})
AADD(aCampos,{ "TB_VALOR1 " ,"N",AvSx3("F2_VALFAT" ,3),AvSx3("F2_VALFAT" ,4)})
AADD(aCampos,{ "TB_VALOR2 " ,"N",AvSx3("F2_VALFAT" ,3),AvSx3("F2_VALFAT" ,4)})
AADD(aCampos,{ "TB_VALOR3 " ,"N",AvSx3("F2_VALFAT" ,3),AvSx3("F2_VALFAT" ,4)})
AADD(aCampos,{ "TB_VALHQ  " ,"N",AvSx3("F2_VALFAT" ,3),AvSx3("F2_VALFAT" ,4)})
AADD(aCampos,{ "TB_VALKC  " ,"N",AvSx3("F2_VALFAT" ,3),AvSx3("F2_VALFAT" ,4)})
AADD(aCampos,{ "TB_VALFORN" ,"N",AvSx3("F2_VALFAT" ,3),AvSx3("F2_VALFAT" ,4)})
AADD(aCampos,{ "TB_DOC    " ,"C",AvSx3("F2_DOC"    ,3),AvSx3("F2_DOC"    ,4)})


//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥ Cria arquivo de trabalho                                     ≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
cNomArq 	:= CriaTrab(aCampos,.T.)
dbUseArea( .T.,, cNomArq,"TRB", .T. , .F. )
cNomArq1 := Subs(cNomArq,1,7)+"A"
IndRegua("TRB",cNomArq1,"TB_VEND",,,STR0011)		//"Selecionando Registros..."
aTamVal 	:= TamSX3("F2_VALFAT")
cNomArq2 := Subs(cNomArq,1,7)+"B"
IndRegua("TRB",cNomArq2,"(STRZERO(TB_VALOR3,aTamVal[1],aTamVal[2]))",,,STR0011)		//"Selecionando Registros..."
dbClearIndex()
dbSetIndex(cNomArq1+OrdBagExt())
dbSetIndex(cNomArq2+OrdBagExt())

//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥ Chamada da Funcao para gerar arquivo de Trabalho             ≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
Processa({|lEnd|GeraTrab(cEstoq,cDupli)},"Coletando dados de Vendas...",,.t.)

//Totalizando pedidos em aberto
TotPedAberto()
nTotalPed := 0

//Totalizando pedidos bloqueados - RBorges 29/12/14
TotPedBloq()
nTotalPedb:= 0

SetRegua(TRB->(LastRec()))

If ( MV_PAR05 = 2 )
	TRB->(dbSetOrder(2))
Else
	TRB->(dbSetOrder(1))
EndIF

TRB->(dbGoBottom())
cNFiscal := TRB->TB_DOC

Do While TRB->(!Bof())
	
	If lEnd
		@Prow()+1,001 PSAY STR0012		//"CANCELADO PELO OPERADOR"
		Exit
	Endif
	
	IncRegua()
	
	If li > 55
	
		cabec(titulo,cabec1,"",nomeprog,tamanho,nTipo)
		
		li := 8 
		
		@ li,000 psay 'CODIGO NOME' 
		
	    @ li,050 psay Padl('FATURAMENTO',len(Transform(0, tm(TRB->TB_VALOR3,18,nDecs))))
	    @ li,072 psay 'RANKING'
	    @ li,80  psay Padl('%',Len(Transform(0, "@E 999,999,999.99")))
	    @ li,pcol()+2 psay Padl('META',len(Transform(0, tm(TRB->TB_VALOR3,18,nDecs))))

	    IF Empty(MV_PAR14) .And. !Empty(mv_par13)
		    @ li,pCol()+2 PSAY Padl(AllTrim(Posicione("SA2",1,xFilial("SA2")+mv_par13,"SA2->A2_NREDUZ")),len(Transform(0,tm(TRB->TB_VALKC,18,nDecs))))
	    ElseIf !Empty(MV_PAR14) .And. Empty(mv_par13)
		    @ li,pCol()+2 PSAY Padl(AllTrim(Posicione("SA2",1,xFilial("SA2")+MV_PAR14,"SA2->A2_NREDUZ")),len(Transform(0,tm(TRB->TB_VALFORN,18,nDecs))))
	    ElseIf !Empty(MV_PAR14) .And. !Empty(mv_par13)   
		    @ li,pCol()+2 PSAY Padl(AllTrim(Posicione("SA2",1,xFilial("SA2")+mv_par13,"SA2->A2_NREDUZ")),len(Transform(0,tm(TRB->TB_VALKC,18,nDecs))))
		    @ li,pCol()+2 PSAY Padl(AllTrim(Posicione("SA2",1,xFilial("SA2")+MV_PAR14,"SA2->A2_NREDUZ")),len(Transform(0,tm(TRB->TB_VALFORN,18,nDecs))))
	    Endif  
	    @ li,pCol()+2  PSAY Padl('PV LIB',len(Transform(0, tm(TRB->TB_VALKC,18,nDecs))))  
	    @ li,pCol()+2  PSAY Padl('PV BLQ',len(Transform(0, tm(TRB->TB_VALKC,18,nDecs)))) //RBorges 29/12/14 
	    
	    //------------------------------------------------------------------------------------------                         
	    // JBS 17/06/2010 - Vendas dos fornecedores abaixo pelo HQ CD.
        // HQ CD (Informacoes da empresa HQ filial CD, dos fornecedores 000851,0000847 e 051508) 
	    //------------------------------------------------------------------------------------------                         
	    @ li,pCol()+2  PSAY Padl('PRODUTOS HQ no CD',len(Transform(0, tm(TRB->TB_VALKC,18,nDecs))))
		
		li++  
		@ li,000 psay 	Replicate("=",limite)
		li++  

	EndIF
	
	cVend := TRB->TB_VEND
	//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
	//≥ Verifica se Ç venda sem vendedor                             ≥
	//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
	IF !Empty( cVend )
		SA3->(DbSeek(xFilial()+cVend))
		cVenTipo := SA3->A3_TIPO // MCVN 02/02/2007
		@li,00 PSAY SA3->A3_COD + " " +SA3->A3_NOME
	ELSE
		@li,00 PSAY "******" + " " + STR0013	//"Venda Sem Vendedor"
	ENDIF
	
	//@li,50 PSAY TRB->TB_VALOR1 PicTure tm(TRB->TB_VALOR1,18,nDecs)
	//@li,70 PSAY TRB->TB_VALOR2 PicTure tm(TRB->TB_VALOR2,18,nDecs)
	@li,50  PSAY TRB->TB_VALOR3  PicTure tm(TRB->TB_VALOR3,18,nDecs)
	
	IF mv_par05 == 2
		nRank++
		@li,75 PSAY nRank	PicTure "9999"
	EndIF
	
	// Buscando Metas - MCVN - 06/05/09
	SZF->(DbSeek(xFilial()+cVend+SubStr(dtoc(MV_PAR01),4,2)+'/20'+SubStr(dtoc(MV_PAR01),7,2)))
	
	@li,80  PSAY (TRB->TB_VALOR3/SZF->ZF_META)*100  PicTure "@E 999,999,999.99"
	@li,pcol()+2 PSAY SZF->ZF_META PicTure tm(TRB->TB_VALOR3,18,nDecs)

	IF Empty(MV_PAR14) .And. !Empty(mv_par13)
		@li,pCol()+2 PSAY TRB->TB_VALKC   PicTure tm(TRB->TB_VALKC,18,nDecs)
	ElseIf !Empty(MV_PAR14) .And. Empty(mv_par13)
		@li,pCol()+2 PSAY TRB->TB_VALFORN PicTure tm(TRB->TB_VALFORN,18,nDecs)
	ElseIf !Empty(MV_PAR14) .And. !Empty(mv_par13)
		@li,pCol()+2 PSAY TRB->TB_VALKC   PicTure tm(TRB->TB_VALKC,18,nDecs)
		@li,pCol()+2 PSAY TRB->TB_VALFORN PicTure tm(TRB->TB_VALFORN,18,nDecs)
	Endif  
	
	//Imprimindo total de pedidos liberados por vendedor
	If aScan(aPedLib, { |x| x[1] == cVend}) > 0
		nTotalPed := aPedLib[aScan(aPedLib, { |x| x[1] == cVend}),2]
	Else
		nTotalPed := 0
	Endif
	
	IF !Empty(MV_PAR14) .And. Empty(mv_par13)
		@li,pCol()+2  PSAY nTotalPed  PicTure tm(TRB->TB_VALKC,18,nDecs)
	ElseIf Empty(MV_PAR14) .And. !Empty(mv_par13)
		@li,pCol()+2  PSAY nTotalPed  PicTure tm(TRB->TB_VALKC,18,nDecs)
	ElseIf Empty(MV_PAR14) .And. Empty(mv_par13)
		@li,pCol()+2  PSAY nTotalPed  PicTure tm(TRB->TB_VALKC,18,nDecs)
	ElseIf !Empty(MV_PAR14) .And. !Empty(mv_par13)
		@li,pCol()+2  PSAY nTotalPed  PicTure tm(TRB->TB_VALKC,18,nDecs)
	Endif
	
	//RBorges - 26/12/14 - Ser„o impressos os valores dos pedidos bloqueados 
		//Imprimindo total de pedidos bloqueados por vendedor
	If aScan(aPedBloq, { |x| x[1] == cVend}) > 0
		nTotalPedb := aPedBloq[aScan(aPedBloq, { |x| x[1] == cVend}),2]
	Else
		nTotalPedb := 0
	Endif
	IF !Empty(MV_PAR14) .And. Empty(mv_par13)
		@li,pCol()+2  PSAY nTotalPedb  PicTure tm(TRB->TB_VALKC,18,nDecs)
	ElseIf Empty(MV_PAR14) .And. !Empty(mv_par13)
		@li,pCol()+2  PSAY nTotalPedb  PicTure tm(TRB->TB_VALKC,18,nDecs)
	ElseIf Empty(MV_PAR14) .And. Empty(mv_par13)
		@li,pCol()+2  PSAY nTotalPedb  PicTure tm(TRB->TB_VALKC,18,nDecs)
	ElseIf !Empty(MV_PAR14) .And. !Empty(mv_par13)
		@li,pCol()+2  PSAY nTotalPedb  PicTure tm(TRB->TB_VALKC,18,nDecs)
	Endif                                                         
	
	                                                         
	//------------------------------------------------------------------------------------------                         
	// JBS 17/06/2010 - Vendas dos fornecedores abaixo pelo HQ CD.
    // HQ CD (Informacoes da empresa HQ filial CD, dos fornecedores 000851,0000847 e 051508) 
	//------------------------------------------------------------------------------------------                         
	@li,pCol()+2 PSAY TRB->TB_VALHQ   PicTure tm(TRB->TB_VALKC,18,nDecs)

	li++
	
	nAg1 += TRB->TB_VALOR1
	nAg2 += TRB->TB_VALOR2
	nAg3 += TRB->TB_VALOR3
	nAg4 += TRB->TB_VALKC
	nAg5 += TRB->TB_VALFORN
	nAg6 += nTotalPed
	nAg7 += SZF->ZF_META
	nAg8 += TRB->TB_VALHQ
	nAg9 += nTotalPedb //RBorges 29/12/14
	//------------------------------------------------------------------------------------------
	// Totalizando Televendas- MCVN 02/02/2007
	//------------------------------------------------------------------------------------------
	If cVenTipo = "I"
		nTotTel        += TRB->TB_VALOR3
		nTotKCtel      += TRB->TB_VALKC
		nTotFornTel    += TRB->TB_VALFORN
		nTotPedKcTel   += nTotalPed
		nTotPedBlTel   += nTotalPedb //RBorges 29/12/14
		nTotMetaTel    += SZF->ZF_META
		nTotHqCd       += TRB->TB_VALHQ
	Endif
	
	cNFiscal := TRB->TB_DOC
	TRB->(dbSkip(-1))

EndDo

IF li != 80
	@ li, 000 PSAY STR0014		//"T O T A L --->"
	@ li, 050 PSAY nAg3 PicTure tm(nAg3,18,nDecs)
	@ li, 080 PSAY nAg3/nAg7*100 PicTure "@E 999,999,999.99"
	@ li, pCol()+2  PSAY nAg7 PicTure tm(nAg3,18,nDecs)
	
	IF Empty(MV_PAR14) .And. !Empty(mv_par13)
		@ li, pCol()+2 PSAY nAg4 PicTure tm(nAg3,18,nDecs)
	ElseIf !Empty(MV_PAR14) .And. Empty(mv_par13)
		@ li, pCol()+2 PSAY nAg5 PicTure tm(nAg3,18,nDecs)
	ElseIf !Empty(MV_PAR14) .And. !Empty(mv_par13)
		@ li, pCol()+2 PSAY nAg4 PicTure tm(nAg3,18,nDecs)
		@ li, pCol()+2 PSAY nAg5 PicTure tm(nAg3,18,nDecs)
	Endif
	
	
	
	IF !Empty(MV_PAR14) .And. Empty(mv_par13)
		@ li, pCol()+2 PSAY nAg6 PicTure tm(nAg3,18,nDecs)
	ElseIf Empty(MV_PAR14) .And. !Empty(mv_par13)
		@ li, pCol()+2 PSAY nAg6 PicTure tm(nAg3,18,nDecs)
	ElseIf Empty(MV_PAR14) .And. Empty(mv_par13)
		@ li, pCol()+2 PSAY nAg6 PicTure tm(nAg3,18,nDecs)
	ElseIf !Empty(MV_PAR14) .And. !Empty(mv_par13)
		@ li, pCol()+2 PSAY nAg6 PicTure tm(nAg3,18,nDecs)
	Endif  
	
	
	IF !Empty(MV_PAR14) .And. Empty(mv_par13)
		@ li, pCol()+2 PSAY nAg9 PicTure tm(nAg3,18,nDecs)
	ElseIf Empty(MV_PAR14) .And. !Empty(mv_par13)
		@ li, pCol()+2 PSAY nAg9 PicTure tm(nAg3,18,nDecs)
	ElseIf Empty(MV_PAR14) .And. Empty(mv_par13)
		@ li, pCol()+2 PSAY nAg9 PicTure tm(nAg3,18,nDecs)
	ElseIf !Empty(MV_PAR14) .And. !Empty(mv_par13)
		@ li, pCol()+2 PSAY nAg9 PicTure tm(nAg3,18,nDecs)
	Endif
	
	//------------------------------------------------------------------------------------------                         
	// JBS 17/06/2010 - Vendas dos fornecedores abaixo pelo HQ CD.
    // HQ CD (Informacoes da empresa HQ filial CD, dos fornecedores 000851,0000847 e 051508) 
	//------------------------------------------------------------------------------------------                         
	@ li,pCol()+2 PSAY nAg8   PicTure tm(nAg8,18,nDecs)
	
	// Imprimindo totais por tipo de vendedor(I-Interno ou E-Externo - MCVN 02/02/2007
	
	li+=2
	
	If nTotTel > 0

		SZF->(DbSeek(xFilial()+"000002"+SubStr(dtoc(MV_PAR01),4,2)+'/20'+SubStr(dtoc(MV_PAR01),7,2)))

		@ li, 000  PSAY "T E L E V E N D A S--->"
		@ li, 050  PSAY nTotTel        PicTure tm(nAg3,18,nDecs)
		@ li, 080  PSAY nTotTel/SZF->ZF_META*100 PicTure "@E 999,999,999.99"
		@ li, pCol()+2  PSAY SZF->ZF_META   PicTure tm(nAg3,18,nDecs)
		
		IF Empty(MV_PAR14) .And. !Empty(mv_par13)
			@ li, pCol()+2  PSAY nTotKCTel      PicTure tm(nAg3,18,nDecs)
		ElseIf !Empty(MV_PAR14) .And. Empty(mv_par13)
			@ li, pCol()+2  PSAY nTotFornTel      PicTure tm(nAg3,18,nDecs)
		ElseIf !Empty(MV_PAR14) .And. !Empty(mv_par13)
			@ li, pCol()+2  PSAY nTotKCTel      PicTure tm(nAg3,18,nDecs)
			@ li, pCol()+2  PSAY nTotFornTel      PicTure tm(nAg3,18,nDecs)
		Endif
		
		IF !Empty(MV_PAR14) .And. Empty(mv_par13)
			@ li, pCol()+2 PSAY nTotPedKcTel   PicTure tm(nAg3,18,nDecs)
		ElseIf Empty(MV_PAR14) .And. !Empty(mv_par13)
			@ li, pCol()+2 PSAY nTotPedKcTel   PicTure tm(nAg3,18,nDecs)
		ElseIf Empty(MV_PAR14) .And. Empty(mv_par13)
			@ li, pCol()+2 PSAY nTotPedKcTel   PicTure tm(nAg3,18,nDecs)
		ElseIf !Empty(MV_PAR14) .And. !Empty(mv_par13)
			@ li, pCol()+2 PSAY nTotPedKcTel   PicTure tm(nAg3,18,nDecs)
		Endif 
		

		IF !Empty(MV_PAR14) .And. Empty(mv_par13)
			@ li, pCol()+2 PSAY nTotPedBlTel   PicTure tm(nAg3,18,nDecs)
		ElseIf Empty(MV_PAR14) .And. !Empty(mv_par13)
			@ li, pCol()+2 PSAY nTotPedBlTel   PicTure tm(nAg3,18,nDecs)
		ElseIf Empty(MV_PAR14) .And. Empty(mv_par13)
			@ li, pCol()+2 PSAY nTotPedBlTel   PicTure tm(nAg3,18,nDecs)
		ElseIf !Empty(MV_PAR14) .And. !Empty(mv_par13)
			@ li, pCol()+2 PSAY nTotPedBlTel   PicTure tm(nAg3,18,nDecs)
		Endif 

		
		//------------------------------------------------------------------------------------------                         
	    // JBS 17/06/2010 - Vendas dos fornecedores abaixo pelo HQ CD.
        // HQ CD (Informacoes da empresa HQ filial CD, dos fornecedores 000851,0000847 e 051508) 
	    //------------------------------------------------------------------------------------------                         
	    @ li,pCol()+2 PSAY nTotHqCD   PicTure tm(nTotHqCD,18,nDecs)
	
	Endif
	
	If (nAg3 - nTotTel) > 0
	
		li++
		
		SZF->(DbSeek(xFilial()+"000005"+SubStr(dtoc(MV_PAR01),4,2)+'/20'+SubStr(dtoc(MV_PAR01),7,2)))
	
		@ li, 000  PSAY "R E P R E S E N T A N T E S--->"
		@ li, 050  PSAY nAg3 - nTotTel        PicTure tm(nAg3,18,nDecs)
		@ li, 080  PSAY (nAg3 - nTotTel)/SZF->ZF_META*100    PicTure "@E 999,999,999.99"
		@ li, pCol()+2  PSAY SZF->ZF_META    PicTure tm(nAg3,18,nDecs)
		
		IF Empty(MV_PAR14) .And. !Empty(mv_par13)
			@ li, pCol()+2  PSAY nAg4 - nTotKCTel      PicTure tm(nAg3,18,nDecs)
		ElseIf !Empty(MV_PAR14) .And. Empty(mv_par13)
			@ li, pCol()+2  PSAY nAg5 - nTotFornTel      PicTure tm(nAg3,18,nDecs)
		ElseIf !Empty(MV_PAR14) .And. !Empty(mv_par13)
			@ li, pCol()+2  PSAY nAg4 - nTotKCTel      PicTure tm(nAg3,18,nDecs)
			@ li, pCol()+2  PSAY nAg5 - nTotFornTel    PicTure tm(nAg3,18,nDecs)
		Endif
		
		IF !Empty(MV_PAR14) .And. Empty(mv_par13)
			@ li, pCol()+2 PSAY nAg6 - nTotPedKcTel   PicTure tm(nAg3,18,nDecs)
		ElseIf Empty(MV_PAR14) .And. !Empty(mv_par13)
			@ li, pCol()+2 PSAY nAg6 - nTotPedKcTel   PicTure tm(nAg3,18,nDecs)
		ElseIf Empty(MV_PAR14) .And. Empty(mv_par13)
			@ li, pCol()+2 PSAY nAg6 - nTotPedKcTel   PicTure tm(nAg3,18,nDecs)
		ElseIf !Empty(MV_PAR14) .And. !Empty(mv_par13)
			@ li, pCol()+2 PSAY nAg6 - nTotPedKcTel   PicTure tm(nAg3,18,nDecs)
		Endif    
		
		
		IF !Empty(MV_PAR14) .And. Empty(mv_par13)
			@ li, pCol()+2 PSAY nAg9 - nTotPedBlTel   PicTure tm(nAg3,18,nDecs)
		ElseIf Empty(MV_PAR14) .And. !Empty(mv_par13)
			@ li, pCol()+2 PSAY nAg9 - nTotPedBlTel   PicTure tm(nAg3,18,nDecs)
		ElseIf Empty(MV_PAR14) .And. Empty(mv_par13)
			@ li, pCol()+2 PSAY nAg9 - nTotPedBlTel   PicTure tm(nAg3,18,nDecs)
		ElseIf !Empty(MV_PAR14) .And. !Empty(mv_par13)
			@ li, pCol()+2 PSAY nAg9 - nTotPedBlTel   PicTure tm(nAg3,18,nDecs)
		Endif
		//------------------------------------------------------------------------------------------                         
	    // JBS 17/06/2010 - Vendas dos fornecedores abaixo pelo HQ CD.
        // HQ CD (Informacoes da empresa HQ filial CD, dos fornecedores 000851,0000847 e 051508) 
	    //------------------------------------------------------------------------------------------                         
	    @ li,pCol()+2 PSAY nAg8 - nTotHqCD   PicTure tm(nAg8,18,nDecs)
	Endif
	roda(cbcont,cbtxt)
EndIF

DbSelectArea("TRB")
TRB->(dbGotop())
ProcRegua(TRB->(RECCOUNT()))	
aCols := Array(TRB->(RECCOUNT()),Len(aCampos))
nColuna := 0
nLinha := 0
While TRB->(!Eof())
	nLinha++
	IncProc(OemToAnsi("Gerando planilha excel..."))
	For nColuna := 1 to Len(aCampos)
		aCols[nLinha][nColuna] := &("TRB->("+aCampos[nColuna][1]+")")			
	Next nColuna
	TRB->(dbSkip())	
EndDo
u_GDToExcel(aCampos,aCols,Alltrim(FunName()))

dbSelectArea( "TRB" )

COPY TO &cArqExcell VIA "DBFCDX"
MakeDir(cDestino) // CRIA DIRET”RIO CASO N√O EXISTA
CpyS2T(cArqExcell+".dbf",cDestino,.T.) // COPIA ARQUIVO PARA MAQUINA DO USU¡RIO

dbCloseArea()

fErase(cNomArq+GetDBExtension())
fErase(cNomArq1+OrdBagExt())
fErase(cNomArq2+OrdBagExt())

//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥ Restaura a integridade dos dados                             ≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ

dbSelectArea("SF2")
Set Filter To
dbSetOrder(1)

//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥ Se em disco, desvia para Spool                               ≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ

If aReturn[5] == 1    // Se Saida para disco, ativa SPOOL
	Set Printer TO
	dbCommitAll()
	ourspool(wnrel)
Endif

MS_FLUSH()

Return
/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥FunáÖo    ≥GeraTrab  ≥ Autor ≥ Wagner Xavier         ≥ Data ≥ 10.01.92 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÖo ≥Gera arquivo de Trabalho para emissao de Estat.de Fatur.    ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥ Uso      ≥ GeraTrab()                                                 ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
/*/
Static Function GeraTrab(cEstoq,cDupli)

Local nContador  := 0
Local nTOTAL     := 0
Local nVALICM    := 0
Local nVALIPI    := 0
Local nTotKC     := 0
Local nTotForn   := 0
Local cVendedor  := ""
Local aVend      := {}
Local cVend      := ""
Local aImpostos  := {}
Local nImpos     := 0.00
Local lContinua  := .F.
Local nMoedNF    := 1
Local nTaxa      := 0
Local cName      := ""
Local aCampos    := {}
Local nCampo     := 0
Local cCampo     := ""
Local cAliasSD2  := "QRY1"
Local cAliasSD1  := "QRY2"
Local cSD2Old    := ""
Local cSD1Old    := ""
Local aStru      := {}
Local nStru      := 0
Local nPos       := 0
Local nValor     := 0
Local nValor4    := 0
Local nValor5    := 0
Local cQuery     := ""  // JBS 09/04/2010
Local cUniao     := ""  // JBS 09/04/2010
Local lConsidera := .F. // JBS 09/07/2010
Local lConsideraHQ:= .F. // JBS 06/08/2010
Local nEmp,xi

Private nVendedor  := 2//Fa440CntVen() - Desabilitado funÁ„o que busca quantidade de vendedor no F2 - MCVN 06/01/11
Private cCampImp

dbSelectArea("SD2")
dbSetOrder(5)
dbSelectArea("SD1")
dbSetOrder(6)

//cAliasSD2:=	CriaTrab(,.F.)
//-------------------------------------------------------------------------------------------
// JBS 14/04/2010 - Montagem da Query, sao duas querys unidas por empresas.
// Empresa 010 unida a empresa 040.
// Esta primeira consulta os produtos faturados dentro de um periodo e atendendo
// Aos parametros informados pelo usuario.
// A array aEmpresa determina quais empresas/filiais podem ser processadas.
//-------------------------------------------------------------------------------------------

cUniao := ""
cQuery := ""

For nEmp := 1 to len(aEmpresa)
	
	/*If Select('SX2_2') > 0
		SX2_2->( DbCloseArea() )
	EndIf*/
	
	cQuery += cUniao + fQuery01(aEmpresa[nEmp][01],aEmpresa[nEmp][02])
	cUniao  := "  UNION  "
	
Next nEmp

cQuery += " ORDER BY " + SQLORDER (SD2->(INDEXKEY()))

If Select(cAliasSD2) > 0
	(cAliasSD2)->( DbCloseArea() )
EndIf

TcQuery cQuery NEW ALIAS "QRY1"
memowrite('UMATR580_D2.SQL',cQuery)

For xi:=1 to 3500
	IncProc("Apurando Vendas...")
Next

aStru := SD2->(dbStruct())
For nStru := 1 To Len(aStru)
	If aStru[nStru,2] <> "C"
		TcSetField("QRY1",aStru[nStru,1],aStru[nStru,2],aStru[nStru,3],aStru[nStru,4])
	EndIf
Next nStru

aStru	:= SF2->(dbStruct())
aCampos	:= {"F2_EMISSAO","F2_FRETE","F2_SEGURO","F2_DESPESA","F2_FRETAUT","F2_ICMSRET"}

For nCampo := 1 To Len(aCampos)
	nPos := aScan(aStru,{|x|AllTrim(x[1])==aCampos[nCampo]})
	If aStru[nPos,2] <> "C"
		TcSetField("QRY1",aStru[nPos,1],aStru[nPos,2],aStru[nPos,3],aStru[nPos,4])
	EndIf
Next nCampo

nRegua:=500
ProcRegua(nRegua)

//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥Processa Faturamento                                                    ≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
Do While (cAliasSD2)->(!Eof())
	
	IncProc("Calculando o Total Faturado...")
	
	nRegua-- 
	
	If nRegua<0
		nRegua:=500
		ProcRegua(nRegua)
	EndIf
	//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
	//≥Processa Filtro do Usuario para Query                                   ≥
	//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
	If !Empty(aReturn[7]).And.!&(aReturn[7])
		(cAliasSD2)->(dbSkip())
		Loop
	Endif
	
	nTOTAL   := 0
	nVALICM  := 0
	nVALIPI  := 0
	nTotKc   := 0
	nTotForn := 0
	nTotHq   := 0
	nTaxa 	 := IIf((cAliasSD2)->(FieldPos("F2_TXMOEDA"))>0,(cAliasSD2)->F2_TXMOEDA,0)
	nMoedNF	 := IIf((cAliasSD2)->(FieldPos("F2_MOEDA")) > 0,(cAliasSD2)->F2_MOEDA, 0)
	
	If (cAliasSD2)->D2_DOC $ '000010280/000010874' ///000006777/000006779/000006773'
	   wwwww := 000
	EndIf
	
	If (cAliasSD2)->D2_DOC+(cAliasSD2)->D2_SERIE+(cAliasSD2)->D2_CLIENTE+(cAliasSD2)->D2_LOJA != cSD2Old
		lConsidera  := .f.
		lConsideraHQ:= .f.
	EndIf
	
	// Eriberto 30/08/10 If AvalTes((cAliasSD2)->D2_TES,cEstoq,cDupli)
		
		nVALICM += xMoeda((cAliasSD2)->D2_VALICM,1,mv_par06,(cAliasSD2)->D2_EMISSAO,nDecs+1)
		nVALIPI += xMoeda((cAliasSD2)->D2_VALIPI,1,mv_par06,(cAliasSD2)->D2_EMISSAO,nDecs+1)
		nTotal	+= xMoeda(Iif((cAliasSD2)->F4_DUPLIC=='N',(cAliasSD2)->(D2_VALFRE+D2_SEGURO+D2_DESPESA+D2_ICMSRET),(cAliasSD2)->(D2_TOTAL+D2_VALFRE+D2_SEGURO+D2_DESPESA+D2_ICMSRET)),nMoedNF,mv_par06,(cAliasSD2)->D2_EMISSAO,nDecs+1,nTaxa)
		nVALIPI := 0
		// Totaliza por fornecedor - Kimberly
		If (cAliasSD2)->D2_FORNEC $ MV_PAR13
			nTotKc	+= xMoeda(Iif((cAliasSD2)->F4_DUPLIC=='N',(cAliasSD2)->(D2_VALFRE+D2_SEGURO+D2_DESPESA+D2_ICMSRET),(cAliasSD2)->(D2_TOTAL+D2_VALFRE+D2_SEGURO+D2_DESPESA+D2_ICMSRET)),nMoedNF,mv_par06,(cAliasSD2)->D2_EMISSAO,nDecs+1,nTaxa)
		Endif                        
		//--------------------------------------------------------------------------------------------------------
        // JBS 17/06/2010 - HQ CD ('000851','000847','051508')
		//--------------------------------------------------------------------------------------------------------
		If (cAliasSD2)->D2_FORNEC $ '000851/000847/051508' .and. (cAliasSD2)->D2_FILIAL == '04' .and. (cAliasSD2)->D2_CODEMP = '010'
			nTotHq += xMoeda(Iif((cAliasSD2)->F4_DUPLIC=='N',(cAliasSD2)->(D2_VALFRE+D2_SEGURO+D2_DESPESA+D2_ICMSRET),(cAliasSD2)->(D2_TOTAL+D2_VALFRE+D2_SEGURO+D2_DESPESA+D2_ICMSRET)),nMoedNF,mv_par06,(cAliasSD2)->D2_EMISSAO,nDecs+1,nTaxa)
		Endif
	
		// Totaliza por fornecedor - MV_PAR14 (Selecionado pelo Usu·rio)
		If (cAliasSD2)->D2_FORNEC $ MV_PAR14
			nTotForn	+= xMoeda(Iif((cAliasSD2)->F4_DUPLIC=='N',(cAliasSD2)->(D2_VALFRE+D2_SEGURO+D2_DESPESA+D2_ICMSRET),(cAliasSD2)->(D2_TOTAL+D2_VALFRE+D2_SEGURO+D2_DESPESA+D2_ICMSRET)),nMoedNF,mv_par06,(cAliasSD2)->D2_EMISSAO,nDecs+1,nTaxa)
		Endif
		
		If ( nTotal <> 0 ) .or. (cAliasSD2)->F4_DUPLIC=='N'
			
			cVendedor := "1"
			lConsidera := .F.
			
			TRB->(dbSetOrder(1))
			
			For nContador := 1 To nVendedor
				
				cVend := (cAliasSD2)->(FieldGet(FieldPos("F2_VEND"+cVendedor)))
				
				If !Empty(cFornVend).and.!Empty((cAliasSD2)->F2_VEND2) .and.cVendedor == "1" .and. (cAliasSD2)->D2_FORNEC $ cFornVend //"000366/000446"
					cVendedor := Soma1(cVendedor,1)
					Loop
				ElseIf !Empty(cFornVend).and.!Empty((cAliasSD2)->F2_VEND2) .and.cVendedor == "2" .and. !(cAliasSD2)->D2_FORNEC $ cFornVend //"000366/000446"
					cVendedor := Soma1(cVendedor,1)
					Loop
				Else
					cVendedor := Soma1(cVendedor,1)
				EndIf
				
				If cVend >= mv_par03 .And. cVend <= mv_par04
					
					//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
					//≥Se vendedor em branco, considera apenas 1 vez        ≥
					//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
					
					If Empty(cVend) .and. nContador > 1
						Loop
					Endif
					
					If (aScan(aVend,cVend)==0)
						Aadd(aVend,cVend)
					EndIf
					
					If TRB->(dbSeek(cVend ))
						TRB->(RecLock("TRB",.F.))
					Else
						TRB->(RecLock("TRB",.T.))
						TRB->TB_VEND := cVend
						TRB->TB_NOME := GetAdvFVal("SA3","A3_NREDUZ",xFilial("SA3")+cVend,1,"")
					EndIF
					
					TRB->TB_EMISSAO := (cAliasSD2)->F2_EMISSAO 
					TRB->TB_DOC	    := (cAliasSD2)->F2_DOC                                                            
	
					Begin Sequence
					 
				    //--------------------------------------------------------------------------------------------------
					// JBS 18/06/2010 - Tratamento para Fornecedores HQ/Vendas HQ_CD.
                    // Acumula a venda do fornecedor HQ e nao grava os outros campos para evitar duplicidade de valores
					//--------------------------------------------------------------------------------------------------
					
		            If (cAliasSD2)->D2_FORNEC $ '000851/000847/051508' .and. (cAliasSD2)->D2_FILIAL == '04' .and. (cAliasSD2)->D2_CODEMP = '010'
					
						TRB->TB_VALHQ := TRB->TB_VALHQ + nTotHq + nVALIPI 
						lConsideraHQ   := .T.
					
						If (nConsolida == 2 .and. lMatrizHq) .or. nConsolida == 3
					        Break
						EndIf 
						
					Endif
					
					TRB->TB_VALOR2 := TRB->TB_VALOR2 + IIF((cAliasSD2)->F2_TIPO == "P",0,nTOTAL)
					TRB->TB_VALOR1 := TRB->TB_VALOR1 + (nTOTAL-nVALICM)
					TRB->TB_VALOR3 := TRB->TB_VALOR3 + IIF((cAliasSD2)->F2_TIPO == "P",0,nTotal)+nVALIPI
					
					lConsidera := .T.
					
					If (cAliasSD2)->D2_FORNEC $ MV_PAR13
						TRB->TB_VALKC  := TRB->TB_VALKC + IIF((cAliasSD2)->F2_TIPO == "P",0,nTotKc)+nVALIPI
					Endif 
					
					If (cAliasSD2)->D2_FORNEC $ MV_PAR14
						TRB->TB_VALFORN  := TRB->TB_VALFORN+IIF((cAliasSD2)->F2_TIPO == "P",0,nTotForn)+nVALIPI
					Endif
					
			        End Sequence	
					
					TRB->(MsUnlock("TRB"))
					
				Endif       
			    
			Next nContador
		EndIf
	// Eriberto 30/08/10 EndIf
	
	cSD2Old	:= (cAliasSD2)->D2_DOC+(cAliasSD2)->D2_SERIE+(cAliasSD2)->D2_CLIENTE+(cAliasSD2)->D2_LOJA
  
    //--------------------------------------------------------------------------------------------------
    // JBS 06/08/2010 -  Quando for uma nota fiscal de Produto HQ no CD
	//--------------------------------------------------------------------------------------------------
    //If lConsideraHQ 
    //   nTotHq := xMoeda((cAliasSD2)->F2_FRETE+(cAliasSD2)->F2_SEGURO+(cAliasSD2)->F2_DESPESA+(cAliasSD2)->F2_FRETAUT,nMoedNF,mv_par06,(cAliasSD2)->F2_EMISSAO,nDecs+1,nTaxa)
    //EndIf
	
	(cAliasSD2)->(dbSkip())
	
	If (cAliasSD2)->(Eof()) .Or. ((cAliasSD2)->D2_DOC+(cAliasSD2)->D2_SERIE+(cAliasSD2)->D2_CLIENTE+(cAliasSD2)->D2_LOJA != cSD2Old)
	                        
		For nContador := 1 To Len(aVend)
			TRB->(dbSeek(aVend[nContador]))
			
			TRB->( RecLock("TRB",.F.) )
			
			Begin Sequence
			//--------------------------------------------------------------------------------------------------
			// JBS 18/06/2010 - Tratamento para Fornecedores HQ/Vendas HQ_CD.
            // Acumula a venda do fornecedor HQ e nao grava os outros campos para evitar duplicidade de valores
			//--------------------------------------------------------------------------------------------------
		    If lConsideraHQ 
			//	TRB->TB_VALHQ += nTotHq  // JBS 06/08/2010 - Soma despesas acessorias quando tiver
				If (nConsolida == 2 .and. lMatrizHq) .or. nConsolida == 3
			        Break
				EndIf
			Endif

			If (cAliasSD2)->D2_FORNEC $ MV_PAR13
				TRB->TB_VALKC  += nValor4
			EndIf
			
			If (cAliasSD2)->D2_FORNEC $ MV_PAR14    // Fornecedor selecionado pelo Usu·rio
				TRB->TB_VALFORN  += nValor5
			EndIf
				
	        End Sequence	

			TRB->(MsUnLock("TRB"))  
			
		Next nContador
		
		aVend := {}
		nValor4:=0
		nValor5:=0  
		
	EndIf
EndDo
dbCloseArea(cAliasSD2)

//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥Processa Devolucao                                                      ≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
If ( MV_PAR07 == 1 )
	
	//cAliasSD1:=CriaTrab(,.F.)
	//-------------------------------------------------------------------------------------------
	// JBS 14/04/2010 - Montagem da Query, sao duas querys unidas por empresas.
	// Empresa 010 unida a empresa 040.
	// Esta primeira consulta os produtos faturados dentro de um periodo e atendendo
	// Aos parametros informados pelo usuario.
	// A array aEmpresa determina quais empresas/filiais podem ser processadas.
	//-------------------------------------------------------------------------------------------
	cUniao := ""
	cQuery := ""
	
	For nEmp := 1 to len(aEmpresa)
		
		/*If Select('SX2_2') > 0
			SX2_2->( DbCloseArea() )
		EndIf*/
		
		cQuery += cUniao + fQuery02(aEmpresa[nEmp][01],aEmpresa[nEmp][02])
		cUniao  := "  UNION  "
		
	Next nEmp

	cQuery += " ORDER BY " + SQLORDER (SD1->(INDEXKEY()))

    If Select(cAliasSD1) > 0
	    (cAliasSD1)->( DbCloseArea() )
    EndIf

	ProcRegua(5000)
	
	For xi:=1 to 1500
		IncProc("Apurando devoluÁıes...")
	Next

    TcQuery cQuery NEW ALIAS "QRY2"
	memowrite('UMATR580_D1.SQL',cQuery)

	For xi:=1 to 3500
		IncProc("Apurando devoluÁıes...")
	Next
	
	aStru := SD1->(dbStruct())
	For nStru := 1 To Len(aStru)
		If aStru[nStru,2] <> "C"
			TcSetField("QRY2",aStru[nStru,1],aStru[nStru,2],aStru[nStru,3],aStru[nStru,4])
		EndIf
	Next nStru
	
	aStru	:= SF1->(dbStruct())
	aCampos	:= {"F1_EMISSAO","F1_FRETE","F1_DESPESA","F1_SEGURO","F1_ICMSRET","F1_DTDIGIT"}
	For nCampo := 1 To Len(aCampos)
		nPos := aScan(aStru,{|x|AllTrim(x[1])==aCampos[nCampo]})
		If aStru[nPos,2] <> "C"
			TcSetField("QRY2",aStru[nPos,1],aStru[nPos,2],aStru[nPos,3],aStru[nPos,4])
		EndIf
	Next nCampo
	
	nRegua:=500
	ProcRegua(nRegua)
	
	Do While (cAliasSD1)->(!Eof())
		
		IncProc("Apurando devoluÁıes...")
		nRegua--
		If nRegua<0
			nRegua:=500
			Procregua(nRegua)
		EndIf
		
		nTOTAL    := 0
		nVALICM   := 0
		nVALIPI   := 0
		nTOTKC    := 0
		nTotHq    := 0 // JBS 18/06/2010
		nTOTFORN  := 0
		lConsidera:= .F.

		// Eriberto 30/08/10 If AvalTes((cAliasSD1)->D1_TES,cEstoq,cDupli)
			
			nVALICM := xMoeda((cAliasSD1)->D1_VALICM,1,mv_par06,(cAliasSD1)->D1_DTDIGIT,nDecs+1)
			nVALIPI := xMoeda((cAliasSD1)->D1_VALIPI,1,mv_par06,(cAliasSD1)->D1_DTDIGIT,nDecs+1)
			nTOTAL  := xMoeda(Iif((cAliasSD1)->F4_DUPLIC=='N',(cAliasSD1)->(D1_VALFRE+D1_SEGURO+D1_DESPESA),(cAliasSD1)->(D1_TOTAL+D1_VALFRE+D1_SEGURO+D1_DESPESA+D1_ICMSRET)),1,mv_par06,(cAliasSD1)->D1_DTDIGIT,nDecs+1)
			cVendedor := "1"
			nVALIPI := 0
			If (cAliasSD1)->D2_FORNEC $ MV_PAR13 // Kimberly
				nTOTKC  := xMoeda(Iif((cAliasSD1)->F4_DUPLIC=='N',(cAliasSD1)->(D1_VALFRE+D1_SEGURO+D1_DESPESA),(cAliasSD1)->(D1_TOTAL+D1_VALFRE+D1_SEGURO+D1_DESPESA+D1_ICMSRET)),1,mv_par06,(cAliasSD1)->D1_DTDIGIT,nDecs+1)
			Endif
		    //--------------------------------------------------------------------------------------------------------
            // JBS 18/06/2010 - HQ CD ('000851','000847','051508')
		    //--------------------------------------------------------------------------------------------------------
		    If (cAliasSD1)->D2_FORNEC $ '000851/000847/051508'.and.(cAliasSD1)->D1_FILIAL == '04' .and. (cAliasSD1)->D1_CODEMP == '010'
			    nTotHq := xMoeda(Iif((cAliasSD1)->F4_DUPLIC=='N',(cAliasSD1)->(D1_VALFRE+D1_SEGURO+D1_DESPESA),(cAliasSD1)->(D1_TOTAL+D1_VALFRE+D1_SEGURO+D1_DESPESA+D1_ICMSRET)),1,mv_par06,(cAliasSD1)->D1_DTDIGIT,nDecs+1)
		    Endif
			
			If (cAliasSD1)->D2_FORNEC $ MV_PAR14 // Fornecedor escolhido pelo Usu·rio
				nTOTFORN  := xMoeda(Iif((cAliasSD1)->F4_DUPLIC=='N',(cAliasSD1)->(D1_VALFRE+D1_SEGURO+D1_DESPESA),(cAliasSD1)->(D1_TOTAL+D1_VALFRE+D1_SEGURO+D1_DESPESA+D1_ICMSRET)),1,mv_par06,(cAliasSD1)->D1_DTDIGIT,nDecs+1)
			Endif
			
			TRB->(dbSetOrder(1))
			
			For nContador := 1 TO nVendedor
				
				cVend := (cAliasSD1)->(FieldGet((cAliasSD1)->(FieldPos("F2_VEND"+cVendedor))))
				If !Empty(cFornVend).and.!Empty((cAliasSD1)->F2_VEND2) .and.cVendedor == "1" .and. (cAliasSD1)->D2_FORNEC $  cFornVend //"000366/000446"
					cVendedor := Soma1(cVendedor,1)
					Loop
				ElseIf !Empty(cFornVend).and.!Empty((cAliasSD1)->F2_VEND2) .and.cVendedor == "2" .and. !(cAliasSD1)->D2_FORNEC $ cFornVend //"000366/000446"
					cVendedor := Soma1(cVendedor,1)
					Loop
				Else
					cVendedor := Soma1(cVendedor,1)
				EndIf
				
				If cVend >= MV_PAR03 .And. cVend <= MV_PAR04
					
					If Empty(cVend) .and. nContador > 1
						Loop
					EndIf
					
					If ( aScan(aVend,cVend) == 0 )
						AADD(aVend,cVend)
					EndIf
					If nTOTAL > 0
					
						If TRB->(dbSeek(cVend))
							TRB->(RecLock("TRB",.F.))
						Else
							TRB->(RecLock("TRB",.T.))
							TRB->TB_VEND := cVend
							TRB->TB_NOME := GetAdvFVal("SA3","A3_NREDUZ",xFilial("SA3")+cVend,1,"")
						EndIf
					    
						TRB->TB_EMISSAO := (cAliasSD1)->F1_EMISSAO  // JBS 18/06/2010
						TRB->TB_DOC	    := (cAliasSD1)->F1_DOC      // JBS 18/06/2010

					    Begin Sequence
					 
				        //--------------------------------------------------------------------------------------------------
					    // JBS 18/06/2010 - Tratamento para Fornecedores HQ/Vendas HQ_CD.
                        // Acumula a venda do fornecedor HQ e nao grava os outros campos para evitar duplicidade de valores
					    //--------------------------------------------------------------------------------------------------
		                
		                If (cAliasSD1)->D2_FORNEC $ '000851/000847/051508' .and. (cAliasSD1)->D1_FILIAL == '04' .and. (cAliasSD1)->D1_CODEMP = '010'
						    //TRB->TB_VALHQ := TRB->TB_VALHQ - nTotHq - nVALIPI 
						    If (nConsolida == 2 .and. lMatrizHq) .or. nConsolida == 3
					            Break
						    EndIf
					    Endif
					
						TRB->TB_VALOR2 := TRB->TB_VALOR2 - nTOTAL
						TRB->TB_VALOR1 := TRB->TB_VALOR1 - (nTOTAL - nVALICM)
						TRB->TB_VALOR3 := TRB->TB_VALOR3 - nTOTAL - nVALIPI
		                
		                lConsidera := .T.
						
						If (cAliasSD1)->D2_FORNEC $ MV_PAR13
							TRB->TB_VALKC := TRB->TB_VALKC - nTOTKC - nVALIPI
						Endif
						
						If (cAliasSD1)->D2_FORNEC $ MV_PAR14
							TRB->TB_VALFORN := TRB->TB_VALFORN - nTOTFORN - nVALIPI
						Endif
						
						End Sequence
						
						TRB->(MsUnlock("TRB"))      
						
					EndIf
				Endif
			Next nContador
		// Eriberto 30/08/10 Endif
		
		cSD1Old := (cAliasSD1)->D1_DOC+(cAliasSD1)->D1_SERIE+(cAliasSD1)->D1_FORNECE+(cAliasSD1)->D1_LOJA
		
		(cAliasSD1)->(dbSkip())
		
		If (cAliasSD1)->(Eof()) .Or. ( (cAliasSD1)->D1_DOC+(cAliasSD1)->D1_SERIE+(cAliasSD1)->D1_FORNECE+(cAliasSD1)->D1_LOJA != cSD1Old)
			
			FOR nContador := 1 TO Len(aVend)
				
				cVend := aVend[nContador]
				
				TRB->(dbSeek(cVend))
				
				TRB->(RecLock("TRB",.F.))
				
				Begin Sequence

			    //--------------------------------------------------------------------------------------------------
			    // JBS 18/06/2010 - Tratamento para Fornecedores HQ/Vendas HQ_CD.
                // Acumula a venda do fornecedor HQ e nao grava os outros campos para evitar duplicidade de valores
			    //--------------------------------------------------------------------------------------------------

		        If (cAliasSD1)->D2_FORNEC $ '000851/000847/051508' .and. (cAliasSD1)->D1_FILIAL == '04' .and. (cAliasSD1)->D1_CODEMP = '010'
				    //TRB->TB_VALHQ := TRB->TB_VALHQ - nTotHq - nVALIPI 
				    If (nConsolida == 2 .and. lMatrizHq) .or. nConsolida == 3
			            Break
				    EndIf
			    Endif
				
				If (cAliasSD1)->D2_FORNEC $ MV_PAR13
					TRB->TB_VALKC := TRB->TB_VALKC - nValor4
				EndIf
				
				If (cAliasSD1)->D2_FORNEC $ MV_PAR14
					TRB->TB_VALFORN := TRB->TB_VALFORN - nValor5
				EndIf       
				
				End Sequence
				
				nValor4 := 0
				nValor5 := 0
				
				TRB->(MsUnlock("TRB"))
				
			Next nContador 
			lConsidera := .F.
			aVend:={}
		EndIf
	EndDo

	dbCloseArea(cAliasSD1)
EndIf                       

Return .T.
///////////////////////////////////////////////////////////////////////////////////////////
/*/
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥FunáÖo   ≥ TotPedAberto≥ Autor ≥ Maximo Canuto Neto≥ Data ≥  25/05/2007≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÖo≥ Totaliza pedidos em aberto por vendedor                     ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥ Uso     ≥ UMATR580			                                          ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
/*/
Static Function TotPedAberto()

Local nLibPed   := 0
Local cVendedor := ""
Local cPriReg := .T.
Local nEmp,xi,_x

//-------------------------------------------------------------------------------------------
// JBS 14/04/2010 - Montagem da Query, sao duas querys unidas por empresas.
// Empresa 010 unida a empresa 040.
// Esta primeira consulta os produtos faturados dentro de um periodo e atendendo
// Aos parametros informados pelo usuario.
// A array aEmpresa determina quais empresas/filiais podem ser processadas.
//-------------------------------------------------------------------------------------------

cUniao := ""
cQuery := ""

For nEmp := 1 to len(aEmpresa)
	
	/*If Select('SX2_2') > 0
		SX2_2->( DbCloseArea() )
	EndIf*/
	
	cQuery += cUniao + fQuery03(aEmpresa[nEmp][01],aEmpresa[nEmp][02])
	cUniao  := "  UNION  "
	
Next nEmp

cQuery += " ORDER BY C9_VEND"

If Select("QRY3") > 0
	QRY3->( DbCloseArea() )
EndIf

ProcRegua(5000)

For xi:=1 to 1500
	IncProc("Apurando devoluÁıes...")
Next

TcQuery cQuery NEW ALIAS "QRY3"         // Abre uma workarea com o resultado da query
memowrite('Umatr580Ped.SQL',cQuery)

For _x := 1 to 500
	IncProc( "Processando... Dados dos pedidos em aberto")
Next
//
// Posicionando no primeiro registro 
//
DbSelectArea("QRY3")
DbGoTop()

Do While QRY3->(!Eof())
	IncProc( "Processando... Dados dos pedidos em aberto")
	
	If cPriReg    //Tratamento para o primeiro registro
		cVendedor := QRY3->C9_VEND
		cPriReg := .F.
	Endif
	
	
	If QRY3->C9_VEND == cVendedor
		nLibPed += QRY3->C9_VALOR
	Else
		Aadd(aPedLib,{cVendedor,nLibPed})
		nLibPed   := QRY3->C9_VALOR
		cVendedor := QRY3->C9_VEND
	Endif
	
	QRY3->(DbSkip())
	
EndDo  

Aadd(aPedLib,{cVendedor,nLibPed})

QRY3->(DbCloseArea())

Return(aPedLib) 

/*/
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥FunáÖo   ≥ TotPedBloque≥ Autor ≥ Reginaldo Borges≥ Data ≥  29/12/14    ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÖo≥ Totaliza pedidos bloqueados por vendedor                    ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥ Uso     ≥ UMATR580			                                          ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
/*/
Static Function TotPedBloq()

Local nBloqPed   := 0
Local cVendedor := ""
Local cPriReg := .T.
Local nEmp,xi,_x

//-------------------------------------------------------------------------------------------
// RSB 26/12/14 - Montagem da Query, sao duas querys unidas por empresas.
// Empresa 010 unida a empresa 040.
// Esta primeira consulta os produtos faturados dentro de um periodo e atendendo
// Aos parametros informados pelo usuario.
// A array aEmpresa determina quais empresas/filiais podem ser processadas.
//-------------------------------------------------------------------------------------------

cUniao := ""
cQuery := ""

For nEmp := 1 to len(aEmpresa)
	
	/*If Select('SX2_2') > 0
		SX2_2->( DbCloseArea() )
	EndIf*/
	
	cQuery += cUniao + fQuery04(aEmpresa[nEmp][01],aEmpresa[nEmp][02])
	cUniao  := "  UNION  "
	
Next nEmp

cQuery += " ORDER BY C9_VEND"

If Select("QRY4") > 0
	QRY4->( DbCloseArea() )
EndIf

ProcRegua(5000)

For xi:=1 to 1500
	IncProc("Apurando Pedidos Bloqueados...")
Next

TcQuery cQuery NEW ALIAS "QRY4"         // Abre uma workarea com o resultado da query
memowrite('Umatr580Pedb.SQL',cQuery)

For _x := 1 to 500
	IncProc( "Processando... Dados dos pedidos bloqueados")
Next
//
// Posicionando no primeiro registro 
//
DbSelectArea("QRY4")
DbGoTop()

Do While QRY4->(!Eof())
	IncProc( "Processando... Dados dos pedidos bloqueados")
	
	If cPriReg    //Tratamento para o primeiro registro
		cVendedor := QRY4->C9_VEND
		cPriReg := .F.
	Endif
	
	
	If QRY4->C9_VEND == cVendedor
		nBloqPed += QRY4->C9_VALOR
	Else
		Aadd(aPedBloq,{cVendedor,nBloqPed})
		nBloqPed  := QRY4->C9_VALOR
		cVendedor := QRY4->C9_VEND
	Endif
	
	QRY4->(DbSkip())
	
EndDo  

Aadd(aPedBloq,{cVendedor,nBloqPed})

QRY4->(DbCloseArea())

Return(aPedBloq)

/*/
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥FunáÖo    ≥ AjustaSX1≥ Autor ≥ Alexandre Inacio Lemes≥ Data ≥28/04/2003≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÖo ≥ Altera descricao da pergunta no SX1                        ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥ Uso      ≥ MATR580			                                          ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
/*/
/*
Static Function AjustaSX1(cPerg)

Local aPerg:={}
Aadd(aPerg,{"Ordem (decrescente)?","Ordem (decreciente)?", "in decreasing order "})

SX1->(dbSetOrder(1))

If SX1->(dbSeek(cPerg+"05"))
	SX1->(RecLock("SX1",.F.))
	SX1->X1_PERGUNT:=aPerg[1][1]
	SX1->X1_PERSPA :=aPerg[1][2]
	SX1->X1_PERENG :=aPerg[1][3]
	SX1->(MsUnLock("SX1"))
EndIf

PutSx1(cPerg, "12","Grupo Clientes   ?","Grupo Clientes   ?","Grupo Clientes   ?","mv_chG","C",06,0,0,"G",'', "ACY","","","mv_par12"," "," "," ","","","","","","","","","","","",""," ","","","")
PutSx1(cPerg, "13","FORNECEDOR       ?","FORNECEDOR       ?","FORNECEDOR       ?","mv_chH","C",06,0,0,"G",'Vazio() .or. ExistCpo("SA2")', "SA2","","","mv_par13"," "," "," ","","","","","","","","","","","",""," ","","","") //MCVN - 06/05/2009
PutSx1(cPerg, "14","Outro FORNECEDOR ?","Outro FORNECEDOR ?","Outro FORNECEDOR ?","mv_chI","C",06,0,0,"G",'Vazio() .or. ExistCpo("SA2")', "SA2","","","mv_par14"," "," "," ","","","","","","","","","","","",""," ","","","") //MCVN - 03/05/2007

Return*/
/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥fQuery01  ∫Autor  ≥Jailton B Santos-JBS∫ Data ≥ 09/04/2010  ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥ Esta Query apura os falores faturado no pedido pela empresa∫±±
±±∫          ≥ informada como parametro, Retorna Query QRY1.              ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ Especifico - Faturamento - DIPROMED.                       ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Static Function fQuery01( _cEmpresa ,_cFilial)

Local cAddField:= ''
Local cFilter2 := ''
Local cCampo   := ''
Local aStru    := {}
Local cName    := ''
Local nId      := 0
Local cQuery   := ""
Local cNameSD2 := "SD2" + _cEmpresa
Local cNameSF2 := "SF2" + _cEmpresa
Local cNameSF4 := "SF4" + _cEmpresa

Local cFilSD2  := cFilAnt//fFilial(_cEmpresa,'SD2',_cFilial)
Local cFilSF2  := cFilAnt//fFilial(_cEmpresa,'SF2',_cFilial)
Local cFilSF4  := cFilAnt//fFilial(_cEmpresa,'SF4',_cFilial)
Local cFilterQry := ""
Local cQryAd   := ""
Local _x, nCampo, nX

ProcRegua(500)

For _x := 1 to 150
	IncProc( "Processando...VENDAS ")
Next

If SF2->(FieldPos("F2_TXMOEDA")) > 0
	cAddField += ", F2_TXMOEDA"
EndIf

If SF2->(FieldPos("F2_MOEDA")) > 0
	cAddField += ", F2_MOEDA"
EndIf

//cFilterQry += " (F2_VEND1 BETWEEN '"+mv_par03+"' AND '"+mv_par04+"' AND (F2_VEND2 = ' ' OR D2_FORNEC <> '000996') OR "
//cFilterQry += " (F2_VEND2 BETWEEN '"+mv_par03+"' AND '"+mv_par04+"' AND D2_FORNEC IN ('000366','000446','000996'))) "

cFilterQry += " (CASE WHEN F2_VEND2 <> ' ' AND D2_FORNEC IN('000366','000446','000996') THEN F2_VEND2 ELSE F2_VEND1 END) BETWEEN '"+mv_par03+"' AND '"+mv_par04+"' "

If U_ListVend() != '' 
	cFilter2 += " AND (CASE WHEN F2_VEND2 <> ' ' AND D2_FORNEC IN('000366','000446','000996') THEN F2_VEND2 ELSE F2_VEND1 END) IN(" + U_ListVend("2") + ") "
//	cFilter2 += " AND (F2_VEND1 IN(" + U_ListVend("2") + ") AND (F2_VEND2 = ' ' OR D2_FORNEC <> '000996') OR "
//	cFilter2 += " (F2_VEND2 IN(" + U_ListVend("2") + ") AND D2_FORNEC IN ('000366','000446','000996'))) "
//	cFilter2 += " AND ( F2_VEND1 = ' ' OR F2_VEND1 IN(" + U_ListVend("2") + ") ) "   
//	cFilter2 += " OR ( F2_VEND2 = ' ' OR (D2_FORNEC IN('000366','000446','000996') AND F2_VEND2 IN(" + U_ListVend("2") + ") )) "   
EndIf
		
cAddField += ", F2_VEND1, F2_VEND2 "

                 // Inclui F4_DUPLIC - Eriberto 30/08/10
cQuery := " SELECT F4_DUPLIC, SD2.*, F2_EMISSAO, F2_TIPO, F2_DOC, F2_FRETE, F2_SEGURO, F2_DESPESA, F2_FRETAUT, F2_ICMSRET" + cAddField+", '" + _cEmpresa + "' D2_CODEMP" 

//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥Esta Rotina adiciona a cQuery os campos selecionados pelo usuario  |
//≥no filtro do usuario.                                              |
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
aStru := SF2->(dbStruct())
If !Empty(aReturn[7])
	For nX := 1 To SF2->(FCount())
		cName := SF2->(FieldName(nX))
		If AllTrim( cName ) $ aReturn[7]
			If aStru[nX,2] <> "M"
				If !cName $ cQuery .And. !cName $ cQryAd
					cQryAd += ","+cName
				Endif
			EndIf
		EndIf
	Next nX
Endif

cQuery += cQryAd

cQuery += " FROM " + cNameSD2 + " SD2, " + cNameSF4 + " SF4, " + cNameSF2 + " SF2, " + RetSqlName("SA1") + " SA1 "  
//----------------------------------------------------------------------------------------------------------------------------------------------------------
// JBS 17/06/2010 - Vendas HQ Cd dos fornecedores abaixo
// Quando for a empresa 04, traz as vendas dos fornecedores 000851,0000847 e 051508
//----------------------------------------------------------------------------------------------------------------------------------------------------------
If _cEmpresa == "010" .and. aScan(aEmpresa,{|X| x[1] == '010' .and. x[2] == '04'}) == 0
	cQuery += " where (D2_FILIAL  = '" + cFilSD2 + "' or ( D2_FILIAL  = '04' and D2_FORNEC in ('000851','000847','051508'))) "  ///
Else
	cQuery += " where D2_FILIAL  = '" + cFilSD2 + "' "  
EndIf

//----------------------------------------------------------------------------------------------------------------------------------------------------------
cQuery += " and D2_EMISSAO between '" + DTOS(mv_par01) + "' and '" + DTOS(mv_par02) + "' "

//-- Tratamento da HQ-CD: se Dipromed-Mtz, somente listar dados a partir de 01/05/2011 => Daniel Leme: 05/05/2011
If (nConsolida == 1 .Or. nConsolida == 4) .And. _cEmpresa + _cFilial == "0101"
	cQuery +=  " AND D2_EMISSAO >= '20110501'"
EndIf

cQuery += " and D2_TIPO NOT IN ('D', 'B', 'I') "   //  Alterado para filtrar notas com tipo diferente de I - MCVN 11/09/2008
cQuery += " and F2_FILIAL  = D2_FILIAL "  
cQuery += " and (" + cFilterQry + ")"
cQuery += " and D2_DOC     = F2_DOC"
cQuery += " and D2_SERIE   = F2_SERIE"
cQuery += " and D2_CLIENTE = F2_CLIENTE"
cQuery += " and D2_LOJA    = F2_LOJA"

If _cEmpresa == "010" // JBS 11/08/2010   .and. aScan(aEmpresa,{|X| x[1] == '040' .and. x[2] == '04'}) == 0
    cQuery += " and F4_FILIAL  = D2_FILIAL " //'" + cFilSF4 + "' or ( F4_FILIAL  = '04' and D2_FORNEC in ('000851','000847','051508'))) " //
Else
	cQuery += " and F4_FILIAL  = '" + cFilSF4 + "' "  
EndIf
//cQuery += " and F4_FILIAL  = '" + cFilSF4 + "'"
cQuery += " and F4_CODIGO  = D2_TES"
//cQuery += " and (F4_DUPLIC = 'S' OR (D2_VALFRE + D2_SEGURO + D2_DESPESA + D2_ICMSRET) > 0 ) "
cQuery += " and A1_FILIAL  = '" + xFilial("SA1") + "'"
cQuery += " and A1_COD     = F2_CLIENTE"
cQuery += " and A1_LOJA    = F2_LOJA"
cQuery += " and SA1.D_E_L_E_T_ = ' '"
If !Empty(mv_par12)
	cQuery += " and A1_GRPVEN = '"+AllTrim(mv_par12)+"'"
EndIf
If !Empty(cFilter2)
	cQuery += cFilter2
EndIf
cQuery += " and SD2.D_E_L_E_T_ = ' '"
cQuery += " and SF2.D_E_L_E_T_ = ' '"
cQuery += " and SF4.D_E_L_E_T_ = ' '"

Return(cQuery)
/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥fQuery02  ∫Autor  ≥Jailton B Santos-JBS∫ Data ≥ 09/04/2010  ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥ Esta Query apura os falores faturado no pedido pela empresa∫±±
±±∫          ≥ informada como parametro, Retorna Query QRY1.              ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ Especifico - Faturamento - DIPROMED.                       ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Static Function fQuery02( _cEmpresa ,_cFilial)

Local cAddField:= ''
Local cFilter2 := ''
Local cCampo   := ''
Local aStru    := {}
Local cName    := ''
Local nId      := 0
Local cQuery   := ""
Local cFilSD1  := cFilAnt//fFilial(_cEmpresa,'SD1',_cFilial)
Local cFilSD2  := cFilAnt//fFilial(_cEmpresa,'SD2',_cFilial)
Local cFilSF1  := cFilAnt//fFilial(_cEmpresa,'SF1',_cFilial)
Local cFilSF2  := cFilAnt//fFilial(_cEmpresa,'SF2',_cFilial)
Local cFilSF4  := cFilAnt//fFilial(_cEmpresa,'SF4',_cFilial)
Local cFilterQry := ""
Local cQryAd   := ""
Local _x,nCampo

ProcRegua(500)
For _x := 1 to 150
	IncProc( "Processando...VENDAS ")
Next

cNameSD1 := "SD1" + _cEmpresa
cNameSD2 := "SD2" + _cEmpresa
cNameSF1 := "SF1" + _cEmpresa
cNameSF2 := "SF2" + _cEmpresa 
cNameSF4 := "SF4" + _cEmpresa

cAddField:= ""
cFilter2 := ""

//cFilterQry += " (F2_VEND1 BETWEEN '"+mv_par03+"' AND '"+mv_par04+"' AND (F2_VEND2 = ' ' OR D2_FORNEC <> '000996') OR "
//cFilterQry += " (F2_VEND2 BETWEEN '"+mv_par03+"' AND '"+mv_par04+"' AND D2_FORNEC IN ('000366','000446','000996'))) "

cFilterQry += " (CASE WHEN F2_VEND2 <> ' ' AND D2_FORNEC IN('000366','000446','000996') THEN F2_VEND2 ELSE F2_VEND1 END) BETWEEN '"+mv_par03+"' AND '"+mv_par04+"' "

If U_ListVend() != ''
	cFilter2 += " AND (CASE WHEN F2_VEND2 <> ' ' AND D2_FORNEC IN('000366','000446','000996') THEN F2_VEND2 ELSE F2_VEND1 END) IN(" + U_ListVend("2") + ") "
//	cFilter2 += " AND (F2_VEND1 IN(" + U_ListVend("2") + ") AND (F2_VEND2 = ' ' OR D2_FORNEC <> '000996') OR "
//	cFilter2 += " (F2_VEND2 IN(" + U_ListVend("2") + ") AND D2_FORNEC IN ('000366','000446','000996'))) "
//	cFilter2 += " AND ( F2_VEND1 = ' ' OR F2_VEND1 IN(" + U_ListVend("2") + ") ) "   
//	cFilter2 += " OR ( F2_VEND2 = ' ' OR (D2_FORNEC IN('000366','000446','000996') AND F2_VEND2 IN(" + U_ListVend("2") + "))) "   
EndIf
		
cAddField += ", F2_VEND1, F2_VEND2 "

cQuery := " Select F4_DUPLIC, SD1.*, F1_EMISSAO, F1_DOC, F1_SERIE, F1_FORNECE, F1_LOJA, F1_FRETE, F1_DESPESA, F1_SEGURO, F1_ICMSRET, F1_DTDIGIT, D2_FORNEC" + cAddField + ", '" + _cEmpresa + "' D1_CODEMP" 
cQuery += "  from " + cNameSD1 + " SD1, " + cNameSF4 + " SF4, " + cNameSF2 + " SF2, " + cNameSF1 + " SF1, " + cNameSD2 + " SD2, "+RetSqlName("SA1")+ " SA1 "
//----------------------------------------------------------------------------------------------------------------------------------------------------------
// JBS 17/06/2010 - Vendas HQ Cd dos fornecedores abaixo
// Quando for a empresa 04, traz as vendas dos fornecedores 000851,0000847 e 051508
//----------------------------------------------------------------------------------------------------------------------------------------------------------
If _cEmpresa == "010" .and. aScan(aEmpresa,{|X| x[1] == '010' .and. x[2] == '04'}) == 0
	cQuery += " where (D1_FILIAL  = '" + cFilSD1 + "' or ( D1_FILIAL  = '04' and D2_FORNEC in ('000851','000847','051508'))) "  //era/////
Else
	cQuery += " where D1_FILIAL  = '" + cFilSD1 + "' "  
EndIf
//----------------------------------------------------------------------------------------------------------------------------------------------------------
cQuery += " and D1_DTDIGIT between '" + DTOS(mv_par01) + "' and '" + DTOS(mv_par02) + "'"

//-- Tratamento da HQ-CD: se Dipromed-Mtz, somente listar dados a partir de 01/05/2011 => Daniel Leme: 05/05/2011
If (nConsolida == 1 .Or. nConsolida == 4) .And. _cEmpresa + _cFilial == "0101"
	cQuery +=  " AND D1_DTDIGIT >= '20110501'"
EndIf

cQuery += " and D1_TIPO    = 'D'"
If _cEmpresa == "010" // JBS 11/08/2010 .and. aScan(aEmpresa,{|X| x[1] == '040' .and. x[2] == '04'}) == 0
    cQuery += " and F4_FILIAL  = D1_FILIAL "  // JBS 11/08/2010 '" + cFilSF4 + "' or ( F4_FILIAL  = '04' and D2_FORNEC in ('000851','000847','051508'))) " //
Else
	cQuery += " and F4_FILIAL  = '" + cFilSF4 + "' "  
EndIf
//cQuery += " and F4_FILIAL  = '" + cFilSF4 + "'"
cQuery += " and F4_CODIGO  = D1_TES"     
//cQuery += " and (F4_DUPLIC = 'S' OR (D2_VALFRE + D2_SEGURO + D2_DESPESA + D2_ICMSRET) > 0 ) "
cQuery += " and F2_FILIAL  = D1_FILIAL "  
cQuery += " and F2_DOC     = D1_NFORI   "
cQuery += " and F2_SERIE   = D1_SERIORI "
cQuery += " and F2_CLIENTE = D1_FORNECE "
cQuery += " and F2_LOJA    = D1_LOJA "
cQuery += " and F1_FILIAL  = D1_FILIAL "
cQuery += " and F1_DOC     = D1_DOC"
cQuery += " and F1_SERIE   = D1_SERIE"
cQuery += " and F1_FORNECE = D1_FORNECE"
cQuery += " and F1_LOJA    = D1_LOJA"
cQuery += " and SD1.D_E_L_E_T_ = ' '"
cQuery += " and SF4.D_E_L_E_T_ = ' '"
cQuery += " and SF2.D_E_L_E_T_ = ' '"
cQuery += " and SF1.D_E_L_E_T_ = ' '"
// Eriberto 09/02/07
cQuery += " and SD2.D_E_L_E_T_ = ' '"
cQuery += " and D2_FILIAL  = D1_FILIAL  "
cQuery += " and D2_DOC     = D1_NFORI   "
cQuery += " and D2_SERIE   = D1_SERIORI "
cQuery += " and D2_ITEM    = D1_ITEMORI "
cQuery += " and D2_CLIENTE = D1_FORNECE "
cQuery += " and D2_LOJA    = D1_LOJA "
cQuery += " and (" + cFilterQry + ")"

cQuery += " and A1_FILIAL  = '" + xFilial("SA1") + "'"
cQuery += " and A1_COD     = F2_CLIENTE"
cQuery += " and A1_LOJA    = F2_LOJA"
cQuery += " and SA1.D_E_L_E_T_ = ' '"
If !Empty(mv_par12)
	cQuery += " and A1_GRPVEN = '"+AllTrim(mv_par12)+"'"
EndIf
If !Empty(cFilter2)
	cQuery += cFilter2
EndIf
Return(cQuery)
/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  fQuery03   ∫Autor  ≥Jailton B Santos-JBS∫ Data ≥ 14/04/2010  ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥ Esta Query apura os valores faturado no pedido pela empresa∫±±
±±∫          ≥ informada como parametro, Retorna Query QRY1.              ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ Especifico - Faturamento - DIPROMED.                       ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Static Function fQuery03( _cEmpresa ,_cFilial)

Local cAddField:= ''
Local cFilter2 := ''
Local cCampo   := ''
Local aStru    := {}
Local cName    := ''
Local nId      := 0
Local cQuery   := ""
Local cFilSC5 := cFilAnt//fFilial(_cEmpresa,'SC5',_cFilial)
Local cFilSC6 := cFilAnt//fFilial(_cEmpresa,'SC6',_cFilial)
Local cFilSC9 := cFilAnt//fFilial(_cEmpresa,'SC9',_cFilial)
Local cFilSF4 := cFilAnt//fFilial(_cEmpresa,'SF4',_cFilial)
Local cFilterQry := ""
Local cQryAd   := ""
Local _x

ProcRegua(500)
For _x := 1 to 150
	IncProc( "Processando...VENDAS ")
Next

cNameSC5 := "SC5" + _cEmpresa
cNameSC6 := "SC6" + _cEmpresa
cNameSC9 := "SC9" + _cEmpresa
cNameSF4 := "SF4" + _cEmpresa

cAddField:= ""
cFilter2 := ""
/*Query antiga
//********************************** QUERY DOS PEDIDOS LIBERADOS**************************************
cQuery := " SELECT C5_EMISSAO, C9_CLIENTE, C9_OPERADO, U7_CODVEN, C9_VEND, C9_PARCIAL, C9_BLEST, C9_BLCRED, C9_BLCRED2, SUM(C9_QTDLIB*C9_PRCVEN) C9_VALOR"
cQuery += " FROM " +  cNameSC9 + " SC9," + cNameSC6 + " SC6, " + cNameSC5 +" SC5, " + cNameSF4 + " SF4, " + RetSqlName('SU7') + " SU7, " + RetSQLName('SA1')+ " SA1 " 
cQuery += " WHERE C5_TIPO   = 'N' AND "
cQuery += " C9_FILIAL        = C5_FILIAL AND "
cQuery += " C9_PEDIDO        = C5_NUM AND "
cQuery += " C9_FILIAL        = C6_FILIAL AND "
cQuery += " C9_PEDIDO        = C6_NUM AND "
cQuery += " C9_ITEM          = C6_ITEM AND "
cQuery += " C6_TES           = F4_CODIGO AND "
cQuery += " C9_BLCRED        = ' ' AND "
cQuery += " C9_BLEST  IN ('02',' ') AND "
cQuery += " C9_NFISCAL       = ''  AND "
cQuery += " C9_PARCIAL       = ''  AND "
cQuery += " C9_SALDO         = 0   AND "
cQuery += " F4_DUPLIC        = 'S' AND "

//-- Tratamento da HQ-CD: se Dipromed-Mtz, somente listar dados a partir de 01/05/2011 => Daniel Leme: 05/05/2011
If (nConsolida == 1 .Or. nConsolida == 4) .And. _cEmpresa + _cFilial == "0101"
	cQuery +=  " C5_DTPEDID >= '20110501' AND "
EndIf

// Eriberto 02/03/2010
cQuery += " F4_FILIAL = '"+cFilSF4+"' AND "

cQuery += " C5_VEND1 *= U7_CODVEN AND "
cQuery += " A1_FILIAL  = '" + xFilial("SA1") + "' AND "
cQuery += " A1_COD     = C9_CLIENTE AND "
cQuery += " A1_LOJA    = C9_LOJA AND "
cQuery += " SA1.D_E_L_E_T_ = ' ' AND "
If !Empty(mv_par12)
	cQuery += " A1_GRPVEN = '"+AllTrim(mv_par12)+"' AND "
EndIf
If U_ListVend() != ''
	cQuery += " C9_VEND IN(" + U_ListVend("2") + ") AND "
EndIf                                                    
cQuery += " (C5_VEND1 BETWEEN '"+mv_par03+"' AND '"+mv_par04+"' AND (C5_VEND2 = ' ' OR C9_FORNEC <> '000996') OR "
cQuery += " (C5_VEND2 BETWEEN '"+mv_par03+"' AND '"+mv_par04+"' AND C9_FORNEC IN ('000366','000446','000996'))) AND "

cQuery += " SC9.D_E_L_E_T_ <> '*' AND "
cQuery += " SC6.D_E_L_E_T_ <> '*' AND "
cQuery += " SC5.D_E_L_E_T_ <> '*' AND "
cQuery += " SF4.D_E_L_E_T_ <> '*' AND "
cQuery += " SU7.D_E_L_E_T_ <> '*' "
cQuery += " GROUP BY C9_VEND, C9_CLIENTE, C9_OPERADO, U7_CODVEN, C5_EMISSAO, C9_PARCIAL, C9_BLEST, C9_BLCRED, C9_BLCRED2 "
*/

//********************************** QUERY DOS PEDIDOS LIBERADOS**************************************
cQuery := " SELECT C5_EMISSAO, C9_CLIENTE, C9_OPERADO, U7_CODVEN, C9_VEND, C9_PARCIAL, C9_BLEST, C9_BLCRED, C9_BLCRED2, SUM(C9_QTDLIB*C9_PRCVEN) C9_VALOR"
cQuery += " FROM " +  cNameSC9 + " SC9 "
cQuery += " INNER JOIN "+ cNameSC6 + " SC6 ON "
cQuery += " C9_FILIAL        = C6_FILIAL AND "
cQuery += " C9_PEDIDO        = C6_NUM AND "
cQuery += " C9_ITEM          = C6_ITEM AND "
cQuery += " SC6.D_E_L_E_T_ <> '*' "
cQuery += " INNER JOIN "+ cNameSC5 +" SC5 ON "
cQuery += " C9_FILIAL        = C5_FILIAL AND "
cQuery += " C9_PEDIDO        = C5_NUM AND "
cQuery += " SC5.D_E_L_E_T_ <> '*' "
cQuery += " INNER JOIN "+ cNameSF4 + " SF4 ON " 
cQuery += " C6_TES           = F4_CODIGO AND "
cQuery += " SF4.D_E_L_E_T_ <> '*' "
cQuery += " LEFT JOIN " + RetSqlName('SU7') + " SU7 ON " 
cQuery += " C5_VEND1 = U7_CODVEN AND "
cQuery += " SU7.D_E_L_E_T_ <> '*' "
cQuery += " INNER JOIN "+ RetSQLName('SA1')+ " SA1 ON " 
cQuery += " A1_FILIAL  = '" + xFilial("SA1") + "' AND "
cQuery += " A1_COD     = C9_CLIENTE AND "
cQuery += " A1_LOJA    = C9_LOJA AND "
cQuery += " SA1.D_E_L_E_T_ = ' ' "
cQuery += " WHERE C5_TIPO   = 'N' AND "
cQuery += " C9_BLCRED        = ' ' AND "
cQuery += " C9_BLEST  IN ('02',' ') AND "
cQuery += " C9_NFISCAL       = ''  AND "
cQuery += " C9_PARCIAL       = ''  AND "
cQuery += " C9_SALDO         = 0   AND "
cQuery += " F4_DUPLIC        = 'S' AND "
//-- Tratamento da HQ-CD: se Dipromed-Mtz, somente listar dados a partir de 01/05/2011 => Daniel Leme: 05/05/2011
If (nConsolida == 1 .Or. nConsolida == 4) .And. _cEmpresa + _cFilial == "0101"
	cQuery +=  " C5_DTPEDID >= '20110501' AND "
EndIf
// Eriberto 02/03/2010
cQuery += " F4_FILIAL = '"+cFilSF4+"' AND "
If !Empty(mv_par12)
	cQuery += " A1_GRPVEN = '"+AllTrim(mv_par12)+"' AND "
EndIf
If U_ListVend() != ''
	cQuery += " C9_VEND IN(" + U_ListVend("2") + ") AND "
EndIf                                                    
cQuery += " (C5_VEND1 BETWEEN '"+mv_par03+"' AND '"+mv_par04+"' AND (C5_VEND2 = ' ' OR C9_FORNEC <> '000996') OR "
cQuery += " (C5_VEND2 BETWEEN '"+mv_par03+"' AND '"+mv_par04+"' AND C9_FORNEC IN ('000366','000446','000996'))) AND "
cQuery += " SC9.D_E_L_E_T_ <> '*'  "
cQuery += " GROUP BY C9_VEND, C9_CLIENTE, C9_OPERADO, U7_CODVEN, C5_EMISSAO, C9_PARCIAL, C9_BLEST, C9_BLCRED, C9_BLCRED2 "

Return(cQuery)

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa fQuery04 ∫Autor  ≥Reginaldo Borges∫        Data ≥ 29/12/14    ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥ Esta Query apura os valores dos pedidos bloqueados         ∫±±
±±∫          ≥ pela empresa informada como parametro, Retorna Query QRY4. ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ Especifico - Faturamento - DIPROMED.                       ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Static Function fQuery04( _cEmpresa ,_cFilial)

Local cAddField:= ''
Local cFilter2 := ''
Local cCampo   := ''
Local aStru    := {}
Local cName    := ''
Local nId      := 0
Local cQuery   := ""
Local cFilSC5 := cFilAnt//fFilial(_cEmpresa,'SC5',_cFilial)
Local cFilSC6 := cFilAnt//fFilial(_cEmpresa,'SC6',_cFilial)
Local cFilSC9 := cFilAnt//fFilial(_cEmpresa,'SC9',_cFilial)
Local cFilSF4 := cFilAnt//fFilial(_cEmpresa,'SF4',_cFilial)
Local cFilterQry := ""
Local cQryAd   := ""
Local _x

ProcRegua(500)
For _x := 1 to 150
	IncProc( "Processando...Pedidos ")
Next

cNameSC5 := "SC5" + _cEmpresa
cNameSC6 := "SC6" + _cEmpresa
cNameSC9 := "SC9" + _cEmpresa
cNameSF4 := "SF4" + _cEmpresa

cAddField:= ""
cFilter2 := ""

//********************************** QUERY DOS PEDIDOS BLOQUEADOS**************************************
/* query ANTIGA
cQuery := " SELECT C5_EMISSAO, C9_CLIENTE, C9_OPERADO, U7_CODVEN, C9_VEND, C9_PARCIAL, C9_BLEST, C9_BLCRED, C9_BLCRED2, SUM(C9_QTDLIB*C9_PRCVEN) C9_VALOR"
cQuery += " FROM " +  cNameSC9 + " SC9," + cNameSC6 + " SC6, " + cNameSC5 +" SC5, " + cNameSF4 + " SF4, " + RetSqlName('SU7') + " SU7, " + RetSQLName('SA1')+ " SA1 " 
cQuery += " WHERE C5_TIPO   = 'N' AND "                        
//cQuery += " C5_EMISSAO BETWEEN'"+DTOS(MV_PAR01)+"' AND '"+DTOS(MV_PAR02)+"' AND "
cQuery += " C9_FILIAL        = C5_FILIAL AND "
cQuery += " C9_PEDIDO        = C5_NUM AND "
cQuery += " C9_FILIAL        = C6_FILIAL AND "
cQuery += " C9_PEDIDO        = C6_NUM AND "
cQuery += " C9_ITEM          = C6_ITEM AND "
cQuery += " C6_TES           = F4_CODIGO AND "
cQuery += " C9_BLCRED        = ' ' AND "
//cQuery += " C9_BLEST  IN ('02',' ') AND "
cQuery += " C9_NFISCAL       = ''  AND "
cQuery += " C9_PARCIAL       = 'N'  AND "
cQuery += " C9_SALDO         = 0   AND "
cQuery += " F4_DUPLIC        = 'S' AND "

//-- Tratamento da HQ-CD: se Dipromed-Mtz, somente listar dados a partir de 01/05/2011 => Daniel Leme: 05/05/2011
If (nConsolida == 1 .Or. nConsolida == 4) .And. _cEmpresa + _cFilial == "0101"
	cQuery +=  " C5_DTPEDID >= '20110501' AND "
EndIf

// Eriberto 02/03/2010
cQuery += " F4_FILIAL = '"+cFilSF4+"' AND "

cQuery += " C5_VEND1 *= U7_CODVEN AND "
cQuery += " A1_FILIAL  = '" + xFilial("SA1") + "' AND "
cQuery += " A1_COD     = C9_CLIENTE AND "
cQuery += " A1_LOJA    = C9_LOJA AND "
cQuery += " SA1.D_E_L_E_T_ = ' ' AND "
If !Empty(mv_par12)
	cQuery += " A1_GRPVEN = '"+AllTrim(mv_par12)+"' AND "
EndIf
If U_ListVend() != ''
	cQuery += " C9_VEND IN(" + U_ListVend("2") + ") AND "
EndIf                                                    
cQuery += " (C5_VEND1 BETWEEN '"+mv_par03+"' AND '"+mv_par04+"' AND (C5_VEND2 = ' ' OR C9_FORNEC <> '000996') OR "
cQuery += " (C5_VEND2 BETWEEN '"+mv_par03+"' AND '"+mv_par04+"' AND C9_FORNEC IN ('000366','000446','000996'))) AND "

cQuery += " SC9.D_E_L_E_T_ <> '*' AND "
cQuery += " SC6.D_E_L_E_T_ <> '*' AND "
cQuery += " SC5.D_E_L_E_T_ <> '*' AND "
cQuery += " SF4.D_E_L_E_T_ <> '*' AND "
cQuery += " SU7.D_E_L_E_T_ <> '*' "
cQuery += " GROUP BY C9_VEND, C9_CLIENTE, C9_OPERADO, U7_CODVEN, C5_EMISSAO, C9_PARCIAL, C9_BLEST, C9_BLCRED, C9_BLCRED2 "
*/

cQuery := " SELECT C5_EMISSAO, C9_CLIENTE, C9_OPERADO, U7_CODVEN, C9_VEND, C9_PARCIAL, C9_BLEST, C9_BLCRED, C9_BLCRED2, SUM(C9_QTDLIB*C9_PRCVEN) C9_VALOR"
cQuery += " FROM " +  cNameSC9 + " SC9 " 
cQuery += " INNER JOIN "+ cNameSC6 + " SC6 ON "
cQuery += " C9_FILIAL        = C6_FILIAL AND "
cQuery += " C9_PEDIDO        = C6_NUM AND "
cQuery += " C9_ITEM          = C6_ITEM AND "
cQuery += " SC6.D_E_L_E_T_ <> '*' "
cQuery += " INNER JOIN "+ cNameSC5 +" SC5 ON "
cQuery += " C9_FILIAL        = C5_FILIAL AND "
cQuery += " C9_PEDIDO        = C5_NUM AND "
cQuery += " SC5.D_E_L_E_T_ <> '*' "
cQuery += " INNER JOIN "+ cNameSF4 + " SF4 ON "
cQuery += " C6_TES           = F4_CODIGO AND "
cQuery += " SF4.D_E_L_E_T_ <> '*' "
cQuery += " LEFT JOIN "+ RetSqlName('SU7') + " SU7 ON "
cQuery += " C5_VEND1 = U7_CODVEN AND "
cQuery += " SU7.D_E_L_E_T_ <> '*' "
cQuery += " INNER JOIN "+ RetSQLName('SA1')+ " SA1 ON " 
cQuery += " A1_FILIAL  = '" + xFilial("SA1") + "' AND "
cQuery += " A1_COD     = C9_CLIENTE AND "
cQuery += " A1_LOJA    = C9_LOJA AND "
cQuery += " SA1.D_E_L_E_T_ = ' ' "
cQuery += " WHERE C5_TIPO   = 'N' AND "                        
//cQuery += " C5_EMISSAO BETWEEN'"+DTOS(MV_PAR01)+"' AND '"+DTOS(MV_PAR02)+"' AND "
cQuery += " C9_BLCRED        = ' ' AND "
//cQuery += " C9_BLEST  IN ('02',' ') AND "
cQuery += " C9_NFISCAL       = ''  AND "
cQuery += " C9_PARCIAL       = 'N'  AND "
cQuery += " C9_SALDO         = 0   AND "
cQuery += " F4_DUPLIC        = 'S' AND "
//-- Tratamento da HQ-CD: se Dipromed-Mtz, somente listar dados a partir de 01/05/2011 => Daniel Leme: 05/05/2011
If (nConsolida == 1 .Or. nConsolida == 4) .And. _cEmpresa + _cFilial == "0101"
	cQuery +=  " C5_DTPEDID >= '20110501' AND "
EndIf
// Eriberto 02/03/2010
cQuery += " F4_FILIAL = '"+cFilSF4+"' AND "
If !Empty(mv_par12)
	cQuery += " A1_GRPVEN = '"+AllTrim(mv_par12)+"' AND "
EndIf
If U_ListVend() != ''
	cQuery += " C9_VEND IN(" + U_ListVend("2") + ") AND "
EndIf                                                    
cQuery += " (C5_VEND1 BETWEEN '"+mv_par03+"' AND '"+mv_par04+"' AND (C5_VEND2 = ' ' OR C9_FORNEC <> '000996') OR "
cQuery += " (C5_VEND2 BETWEEN '"+mv_par03+"' AND '"+mv_par04+"' AND C9_FORNEC IN ('000366','000446','000996'))) AND "
cQuery += " SC9.D_E_L_E_T_ <> '*' "
cQuery += " GROUP BY C9_VEND, C9_CLIENTE, C9_OPERADO, U7_CODVEN, C5_EMISSAO, C9_PARCIAL, C9_BLEST, C9_BLCRED, C9_BLCRED2 "

Return(cQuery)

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥fFilial() ∫Autor  ≥Jailton B Santos-JBS∫ Data ≥ 09/04/2010  ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥Faz o tratamento para achar a filial para empresa para a    ∫±±
±±∫          ≥qual ira' abrir a tabela informada.                         ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Parametro ≥_cEmpresa: Empresa na qual queremos coletar dados           ∫±±
±±∫          ≥_cTabela : Nome da tabela da qual queremos coletar dados    ∫±±
±±∫          ≥_cFilial : Se a tabela for exclusiva, esta eh a filial da   ∫±±
±±∫          ≥           qual eh preciso coletar dados.                   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ Especifico - Faturamento - DIPROMED                        ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Static Function fFilial(_cEmpresa,_cTabela,_cFilial)

Local _cNewFilial := Space(2)
/*Local _cFile      := 'SX2'+_cEmpresa
Local _cFileIdx   := _cFile

If Select("SX2_2") = 0
	MsOpEndbf(.T.,"DBFCDX",_cFile,"SX2_2",.T.,.F.)
EndIf

SX2_2->( DbSetOrder(1) )
If SX2_2->( DbSeek(_cTabela) )
	If SX2_2->X2_MODO = 'E'
		_cNewFilial := _cFilial
	EndIf
Else
	_cNewFilial := xFilial(_cTabela)
EndIf*/

Return(_cNewFilial)

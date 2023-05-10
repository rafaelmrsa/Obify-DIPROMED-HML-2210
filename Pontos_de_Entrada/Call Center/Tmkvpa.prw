/*                                                    São Paulo, 02 Jun 2006
----------------------------------------------------------------------------
Empresa....: Dipromed Comercio e Importação Ltda

Execução...: Substitui a tela de condição de pagamento

Objetivo...: Substituir a rotina de condição do pagamento do sistema. Mantido
             apenas para compatibilização de versão - o uso dever ser avaliado
             pela equipe suporte autorizada pela Microsiga. 
             
             Retorno Esperado	.T. - Condição válida , .F. - condição inválida



Parametros.:1- Array com os valores dos campos de totais
	        2- Array com os objetos dos campos de totais
	        3- Dados complementares da parcela
            4- Variável para a condição de pagamento
            5- Objeto da condição de pagamento
            6- Descrição da condição de pagamento			
            7- Objeto para a descrição de pagamento
            8- Variável para o objeto do código da transportadora
         	9- Objeto do código da transportadora
         	10-Variável para o objeto da descrição da transportadora
         	11-Objeto para a descrição da transportadora
         	12-Variável para o objeto do endereço de cobrança
         	13-Objeto para o endereço de cobrança
         	14-Variável para o objeto do endereço de entrega
         	15-Objeto para o endereço de entrega
         	16-Variável para o objeto da cidade de cobrança
         	17-Objeto para a cidade de cobrança
         	18-Variável para o objeto do Cep de cobrança
         	19-Objeto para o Cep de cobrança
         	20-Variável para o objeto do estado de cobrança
         	21-Objeto para o Estado de cobrança
         	22-Variável para o objeto do bairro de entrega
         	23-Objeto para o bairro de entrega
         	24-Variável para o objeto do bairro de cobrança
         	25-Objeto para o bairro de cobrança
         	26-Variável para objeto da Cidade de entrega
         	27-Objeto para a Cidade de entrega
         	28-Variável para o objeto do cep de entrega
         	29-Objeto para o cep de entrega
         	30-Variável para o objeto do Estado de entrega
         	31-Objeto para o Estado de entrega
         	32-Valor líquido
         	33-Objeto do valor líquido
         	34-Variável para o Valor percentual dos juros de  condição
         	35-Objeto para os juros da condição
         	36-Variável para o Valor percentual do desconto da   condição
         	37-Objeto para o desconto da condição
         	38-Array com o valor das parcelas  e a forma de pagamento
         	39- Objeto para as parcelas da condição
         	40-Variável para o valor de Entrada
         	41-Objeto do valor da Entrada
         	42-Valor financiado de acordo com a condição
         	43-Objeto para o valor financiado
         	44-Total de parcelas
         	45-Objeto para o total de parcelas
         	46-Valor dos juros da condição de pagamento
         	47-Opção de menu selecionada
         	48-Número do atendimento televendas
         	49-Código do cliente
         	50-Loja do cliente
         	51-Código do contato
         	52-Código do operador 

Retorno Esp: .T. - Condição válida 
             .F. - Condição inválida

Autor......: Jailton B Santos (JBS)
Data.......: 20 Fev 2002
---------------------------------------------------------------------
*/
#INCLUDE "TCBROWSE.CH"
#INCLUDE "TMKA273C.CH"
#INCLUDE "PROTHEUS.CH"

#DEFINE TEF_CLISITEF				"4"		// Utiliza a DLL CLISITEF no TeleVendas
#DEFINE _FORMATEF					"CC" 	// Formas de pagamento que utilizam operação TEF para validação

// VALORES DOS COMBOS TIPO DE LIGACAO
#DEFINE RECEPTIVO		1
#DEFINE ATIVO			2

// VALORES DOS COMBOS STATUS DA LIGACAO
#DEFINE PLANEJADA		1
#DEFINE PENDENTE		2
#DEFINE ENCERRADA		3

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³TMKA273 - TELEVENDAS                         													³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

// VALORES PARA O RODAPE DA ROTINA DE TELEVENDAS
#DEFINE MERCADORIA		1	// Valor total do mercadoria
#DEFINE DESCONTO		2	// Valor total do desconto
#DEFINE ACRESCIMO		3	// Valor do acrescimo financeiro da condicao de pagamento
#DEFINE FRETE   		4	// Valor total do Frete
#DEFINE DESPESA 		5	// Valor total da despesa
#DEFINE TOTAL 			6	// Total do Pedido

// VALORES DOS COMBOS TIPO DE MARKETING
#DEFINE RECEPTIVO		1
#DEFINE ATIVO			2
#DEFINE FAX      		3
#DEFINE REPRESENTANTE  4

// VALORES DOS COMBOS TIPO OPERACAO
#DEFINE FATURAMENTO		1
#DEFINE ORCAMENTO		2
#DEFINE ATENDIMENTO		3

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³APENAS DOS CADASTROS                         													³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

//TMKA070 - CADASTRO DE OPERADORES
#DEFINE TELEMARKETING	1
#DEFINE TELEVENDAS		2
#DEFINE TELECOBRANCA	3
#DEFINE TODOS			4
#DEFINE TMKTLV			5

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ARRAY COM DADOS DO EMAIL A SER ENVIADO³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
#DEFINE EMAIL	  		1	// Descricao do email do destinatario
#DEFINE ASSUNTO  		2	// Assunto do email
#DEFINE MENSAGEM 		3	// Corpo do email
#DEFINE ANEXO  			4	// Anexo do email

//Static cCodAnt	:= '' //cCodPagto


User function TMKVPA(aValores, aObj, aItens, cCodPagto, oCodPagto, cDescPagto, oDescPagto, cCodTransp, oCodTransp,;
cTransp, oTransp, cCob, oCob, cEnt, oEnt, cCidadeC, oCidadeC, cCepC, oCepC, cUfC, oUfC, cBairroE, oBairroE, cBairroC,;
oBairroC, cCidadeE, oCidadeE, cCepE, oCepE, cUfE, oUfE, nLiquido, oLiquido ,nTxJuros, oTxJuros, nTxDescon, oTxDescon,;
aParcelas, oParcelas, nEntrada, oEntrada, nFinanciado, oFinanciado, nNumParcelas, oNumParcelas, nVlJur, nOpc, cNumTlv,;
cCliente, cLoja, cCodCont, cCodOper)

Local lTMKVCPT 	:= FindFunction("T_TMKVCP")				// P.E. para TLV no final da funcao - Para uso exclusivo de Templates
Local lTMKVCP  	:= FindFunction("U_TMKVCP")				// P.E. para TLV no final da funcao
Local lTMKCND  	:= FindFunction("U_TMKCND")	       	    // P.E. para TLV na abertura da tela
Local cTipoOper := ""                                   // Tipo de operacao("1-Faturamento;2-Orcamento;3-Atendimento")
Local cCodAnt	:= If(cCodPagto == '016',cCodPagto,"")
Local oCurTmk                                   // Objeto do CURSOR
Local nVlrPrazo
Local oVlrPrazo					                // Valor do Total do pedido com a condicao
Local oValNFat   				                // Valor dos itens que nao serao faturados
Local lHabilita := IIF(nOpc <> 2,.T.,.F.)       // Habilita/desabilita o get dos objetos - VISUALIZACAO = FALSE
Local lHabilAux := lHabilita                    // Flag auxiliar para habilitar ou nao os objetos da tela de forma de pagamento - para que nao haja conflito com a tela Pai
Local cCliAnt   := cCliente+cLoja
Local lTipo9	:= .t.						    // Flag para controle da venda tipo 9 - para alteracao das parcelas
Local nValNFat                                  // Calcula o Valor Nao Faturado
Local lTefMult	:= SuperGetMV("MV_TEFMULT")	    // Parametro do SX6 que indica se o sistema vai o TEF multiplas transacoes
Local cPictTrans:= PesqPict("SUA","UA_TRANSP")	// Picture "Default" do campo de transportadora
Local nOpca 	:= 0                            // Opcao de escolha OK ou CANCELA
Local oInc
Local oCif
Local oFrete
Local bkp_lTk271Auto := lTk271Auto // Salva a posição e restaura na saida do programa
Local lRet := .f. // JBS 25/05/06 
Local cCondAnt := ""

Private lInc
Private lCif
Private nValFrete
Private cTipoFrete := M->UA_TPFRETE                                                                         
Private _cCliEspecial := GetMV("MV_CLIESPE") // Cliente especial

DEFINE CURSOR oCurTmk HAND		                // Muda o cursor para "Hand"

SE4->(dbSetOrder(1))
If !Empty(cCodPagto) .and. SE4->(MsSeek(xFilial("SE4")+cCodPagto))
	//	lTipo9 := SE4->E4_TIPO == "9"
Endif

U_DIPPROC(ProcName(0),U_DipUsr()) //MCVN - 22/01/2009

U_Dipa025('LIMPA') // JBS 11/05/2006 - Libera marcas da pergunta de Inclusao de Substituição Tributaria

// Calcula Substituicao Tributaria
	// 23/08/2006
	// DF esta fora conforme decreto 21.775 de 28/11/2000
	// AM esta fora conforme decreto 20.390 de 27/09/1999
	// CE esta fora conforme decreto 24.756/97 de 30/12/1997
	// GO esta fora conforme decreto 5.261 de 28/07/2000
    // RN esta fora conforme decreto 19.006 de 22/03/2006
    // SC esta fora conforme decreto 3.666 de 28/10/2006
	
	// PR esta fora conforme decreto 4.927 de 08/06/2006
	// SP esta fora conforme decreto 42.346 de 17/10/1997
	
	/* Alterado dia 22/07/2008 - MCVN
	Calcula Substituicao Tributaria      
    If SA1->A1_EST != 'PR'   .and.; Paraná Aderiu ao Conv. 76/94 A PARTIR DE 01/06/2008
  	SA1->A1_EST != 'SC' 	 .AND.; Santa Catarina Aderiu ao Conv. 76/94 A PARTIR DE 01/06/2008  
  	*/
  	
	If SA1->A1_EST != 'SP'  .and.; 
	   SA1->A1_EST != 'DF' 	.AND.;
	   SA1->A1_EST != 'AM' 	.AND.;
	   SA1->A1_EST != 'CE' 	.AND.;
	   SA1->A1_EST != 'GO' 	.AND.;
	   SA1->A1_EST != 'RN' 	.AND.;
   !Empty(SA1->A1_INSCR) 	.AND.;
   !('ISENT' $ Upper(SA1->A1_INSCR)) .And. ;
   (Empty(SA1->A1_GRPTRIB) .Or. (!Empty(SA1->A1_GRPTRIB) .And. U_ExcFiscal(SA1->A1_EST,SA1->A1_GRPTRIB))) // MCVN - 28/04/2008
	
   U_DIPA025(SA1->A1_EST)
EndIf
aValores[TOTAL] := aValores[MERCADORIA]-aValores[DESCONTO]+aValores[ACRESCIMO]+aValores[FRETE]+aValores[DESPESA]
nVlrPrazo := aValores[MERCADORIA]+aValores[ACRESCIMO]+aValores[FRETE]+aValores[DESPESA]
If ( Type("l410Auto") == "U" .OR. !l410Auto )
	MaFisAlt("NF_FRETE",aValores[FRETE])
	MaFisAlt("NF_DESPESA",aValores[DESPESA])
	MaFisAlt("NF_VALMERC",aValores[MERCADORIA])
	MaFisAlt("NF_TOTAL",aValores[TOTAL])
EndIf

//---------------------------------------------
// Se nao estiver usando a entrada automatica
//---------------------------------------------
U_CalcuFrete('TMKVLDE4')
lInc := M->UA_TPFRETE == "I"
lCif := M->UA_TPFRETE == "C"

lTk271Auto:=.t. // Ignora refresh na função
nLiquido := aValores[TOTAL]
nValNFat := Tk273NFatura()
nVlrPrazo:= aValores[MERCADORIA]+aValores[ACRESCIMO]+aValores[FRETE]+aValores[DESPESA]
nEntrada := nLiquido

//----------------------------------------------
// Recalcula o valor das parcelas
//----------------------------------------------
Tk273MontaParcela(nOpc,;
cNumTlv,;
@nLiquido,;
oLiquido,;
@nTxJuros,;
oTxJuros,;
@nTxDescon,;
oTxDescon,;
@aParcelas,;
oParcelas,;
@cCodPagto,;
oCodPagto,;
@nEntrada,;
oEntrada,;
@nFinanciado,;
oFinanciado,;
@cDescPagto,;
oDescPagto,;
@nNumParcelas,;
oNumParcelas,;
@nVlrPrazo,;
oVlrPrazo,;
@nVlJur,;
@cCodAnt,;
@lTipo9,;
nValNFat,;
oValNFat)

nValFrete  := M->UA_FRETE
cCodTransp := M->UA_TRANSP

SA4->(dbSeek(xFilial('SA4')+cCodTransp))
cTransp := SA4->A4_NOME

lTk271Auto := bkp_lTk271Auto                      '

If !lTk271Auto
	
	DEFINE MSDIALOG oDlgPagto FROM  23,80 TO 431,710 TITLE "Forma de Pagamento" PIXEL STYLE DS_MODALFRAME //"Forma de Pagamento"
	
	@ 003,002 TO 095,310 LABEL "Condi‡”es de Pagamento" OF oDlgPagto  PIXEL //"Condi‡”es de Pagamento"
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Listbox com as parcelas de pagamento conforme a condicao escolhida  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	@09,125 BROWSE oParcelas SIZE 180,82 OF oDlgPagto PIXEL ;
	ON DbLCLICK Tk273Detalhe(	@aParcelas	,oParcelas	,@aItens	,lHabilita,;
	nLiquido	,@nEntrada	,oEntrada	,@nFinanciado,;
	oFinanciado	,cCodPagto	,.t.)
	
	// Visualizacao das parcelas - Funciona no novo tratamento do IA-IL
	oParcelas:SetArray( aParcelas )
	ADD COLUMN TO oParcelas HEADER "Data" OEM DATA {|| DTOC(oParcelas:aArray[oParcelas:nAt,1]) }  					  	ALIGN LEFT SIZE 40 PIXEL //"Data"
	ADD COLUMN TO oParcelas HEADER "Valor" OEM DATA {|| Transform(oParcelas:aArray[oParcelas:nAt,2],"@E 999,999,999.99")}  ALIGN LEFT SIZE 50 PIXEL //"Valor"
	ADD COLUMN TO oParcelas HEADER "Forma" OEM DATA {|| oParcelas:aArray[oParcelas:nAt,3] } 								ALIGN LEFT SIZE 40 PIXEL //"Forma"
	oParcelas:oCursor := oCurTmk 
	
	
	@ 011,004 SAY "Condi‡„o" OF oDlgPagto PIXEL  //"Condi‡„o"
	@ 011,040 MSGET oCodPagto VAR cCodPagto SIZE 30,8 OF oDlgPagto PIXEL F3 X3F3("UA_CONDPG") Picture "@!" ;
	WHEN lHabilita 	VALID VPADipValid(nOpc,cNumTlv	,@nLiquido		,oLiquido,;
	@nTxJuros	,oTxJuros	,@nTxDescon		,oTxDescon,;
	@aParcelas	,oParcelas	,@cCodPagto		,oCodPagto,;
	@nEntrada	,oEntrada	,@nFinanciado	,oFinanciado,;
	@cDescPagto	,oDescPagto	,@nNumParcelas	,oNumParcelas,;
	@nVlrPrazo	,oVlrPrazo	,@nVlJur		,@cCodAnt,;
	@lTipo9		,nValNFat	,oValNFat, aValores)
	oCodPagto:cSX1Hlp := "UA_CONDPG"
	
	@ 011,070 SAY oDescPagto VAR cDescPagto Picture "@!" SIZE 50,8 OF oDlgPagto PIXEL COLOR CLR_BLUE
	
	@ 021,004 SAY "Nao Faturado"  OF oDlgPagto PIXEL  //"Valor Nao Faturado"
	@ 021,040 MSGET oValNFat VAR nValNFat Picture "@E 999,999,999.99" SIZE 40,8  OF oDlgPagto PIXEL When .F. //"Valor Nao Faturado"
	
	@ 031,004 SAY "L¡quido" OF oDlgPagto PIXEL //"L¡quido"
	@ 031,040 MSGET oLiquido VAR nLiquido Picture "@E 999,999,999.99" SIZE 40,8 OF oDlgPagto PIXEL When .F.
	
	@ 041,004 SAY "Entrada" OF oDlgPagto PIXEL //"Entrada"
	@ 041,040 MSGET oEntrada VAR nEntrada Picture "@E 999,999,999.99" SIZE 40,8  OF oDlgPagto PIXEL When .F.
	
	@ 051,004 SAY "Juros" OF oDlgPagto PIXEL //"Juros"
	@ 051,040 MSGET oTxJuros VAR nTxJuros  Picture "@E 999.99" SIZE 15,8 OF oDlgPagto PIXEL When .F.
	
	@ 051,073 SAY "Parcelas" OF oDlgPagto PIXEL //"Parcelas"
	@ 051,095 MSGET oNumParcelas VAR nNumParcelas Picture "99"  SIZE 17,8  OF oDlgPagto PIXEL When .F.
	
	@ 061,004 SAY "Financiado" OF oDlgPagto PIXEL //"Financiado"
	@ 061,040 MSGET oFinanciado VAR nFinanciado Picture "@E 999,999,999.99" SIZE 40,8  OF oDlgPagto PIXEL When .F.
	
	@ 071,004 SAY "Total" OF oDlgPagto PIXEL //"Total"
	@ 071,040 MSGET oVlrPrazo VAR nVlrPrazo Picture "@E 999,999,999.99"  SIZE 40,8  OF oDlgPagto PIXEL When .F.
	
	@ 081,004 SAY "Desconto" OF oDlgPagto PIXEL //"Desconto"
	@ 081,040 MSGET oTxDescon VAR nTxDescon Picture "@E 999.99" SIZE 20,8  OF oDlgPagto PIXEL When .F.
	
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Browse com as parcelas de pagamento (Sintetizada) conforme a condicao escolhida ³
	//³Esta forma de visualizacao sera usada somente quando for TEF com ClisiTef       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If 	lVisuSint 	.AND.;
		lUsaTef 	.AND.;
		cTipTef == TEF_CLISITEF
		
		@09,115 BROWSE oPgtosSint SIZE 190,82 OF oDlgPagto PIXEL ;
		ON DbLCLICK Tk273DetSint(	@aParcelas	,oParcelas	,@aItens	,lHabilita,;
		nLiquido	,@nEntrada	,oEntrada	,@nFinanciado,;
		oFinanciado	,cCodPagto	,lSigaCRD	,oDlgPagto)
		
		oPgtosSint:SetArray( aPgtosSint )
		ADD COLUMN TO oPgtosSint HEADER "Data"		 OEM DATA { || aPgtosSint[oPgtosSint:nAt,5] } ALIGN LEFT  SIZE 40 PIXEL 	//"Data"
		ADD COLUMN TO oPgtosSint HEADER "Forma Pgto" OEM DATA { || aPgtosSint[oPgtosSint:nAt,1] } ALIGN LEFT  SIZE 40 PIXEL 	//"Forma Pgto"
		ADD COLUMN TO oPgtosSint HEADER "Valor"      OEM DATA { || aPgtosSint[oPgtosSint:nAt,3] } ALIGN LEFT  SIZE 40 PIXEL  //"Valor"
		ADD COLUMN TO oPgtosSint HEADER "Parcelas"   OEM DATA { || aPgtosSint[oPgtosSint:nAt,2] } ALIGN LEFT  SIZE 30 PIXEL 	//"Parcelas"
		
		//So inserir a coluna ID Cartao quando o cliente trabalhar com multiplas transacoes TEF
		If lUsaTef .AND. lTefMult
			ADD COLUMN TO oPgtosSint HEADER "ID Cartao" OEM DATA { || aPgtosSint[oPgtosSint:nAt,4] } ALIGN LEFT  SIZE 30 PIXEL  //"ID Cartao"
		Endif
		
		oPgtosSint:oCursor := oCurTmk
	Endif
	
	oEntrada   :Refresh()
	oLiquido   :Refresh()
	oFinanciado:Refresh()
	
	@ 100,002 TO 185,310 LABEL "Dados Complementares" OF oDlgPagto  PIXEL 	// "Dados Complementares"
	
	@ 111,004 SAY "Transportadora" OF oDlgPagto PIXEL 				// "Transportadora"
	@ 111,045 MSGET oCodTransp VAR cCodTransp Picture cPicttrans F3 "SA4" SIZE 40,8 OF oDlgPagto PIXEL ;
	Valid VpaAtuTransp(@cCodTransp	,@oCodTransp	,@cTransp	,@oTransp,;
	@cCob		,@oCob			,@cEnt		,@oEnt,;
	@cCidadeC	,@oCidadeC		,@cCepC		,@oCepC,;
	@cUfC		,@oUfC			,@cBairroE	,@oBairroE,;
	@cBairroC	,@oBairroC		,@cCidadeE	,@oCidadeE,;
	@cCepE		,@oCepE			,@cUfE		,@oUfE,;
	nOpc		,cNumTlv		,cCliente	,cLoja,;
	cCodPagto	,aParcelas,oFrete) When lHabilAux
	oCodTransp:cSX1Hlp := "UA_TRANSP"
	
	@ 112,090 SAY oTransp VAR cTransp Picture "@!" SIZE 150,16 OF oDlgPagto PIXEL COLOR CLR_BLUE
	
	@ 126,004 SAY "Cobranca" OF oDlgPagto PIXEL  //"Cobranca"
	@ 126,045 MSGET oCob VAR cCob  Picture "@!" SIZE 115,8  OF oDlgPagto PIXEL When lHabilAux
	oCob:cSX1Hlp := "UA_ENDCOB"
	
	@ 126,180 SAY "Bairro" OF oDlgPagto PIXEL //"Bairro"
	@ 126,205 MSGET oBairroC VAR cBairroC Picture "@!" SIZE 80,8 OF oDlgPagto PIXEL When lHabilAux
	oBairroC:cSX1Hlp := "UA_BAIRROC"
	
	@ 141,004 SAY "Cidade" OF oDlgPagto PIXEL //"Cidade"
	@ 141,045 MSGET oCidadeC VAR cCidadeC Picture "@!" SIZE 80,8 OF oDlgPagto PIXEL ;
	Valid Tk273CidC(@oCidadeC,@cCidadeC) When lHabilAux
	oCidadeC:cSX1Hlp := "UA_MUNC"
	
	@ 141,150 SAY "CEP" OF oDlgPagto PIXEL //"CEP"
	@ 141,170 MSGET oCepC VAR cCepC Picture "@R 99999-999" SIZE 40,8 OF oDlgPagto PIXEL Valid ;
	Tk273CepC(	@cCepC	,@oCepC	,@cCidadeC	,@oCidadeC,;
	@cUfC	,@oUfC	,@cBairroC	,@oBairroC);
	When lHabilAux
	oCepC:cSX1Hlp := "UA_CEPC"
	
	@ 141,225 SAY "Estado" SIZE 25,8 OF oDlgPagto PIXEL  //"Estado"
	@ 141,250 MSGET oUfC VAR cUfC Picture "@!" F3 "12" SIZE 35,8 OF oDlgPagto PIXEL Valid Tk273Estado(cUfc) When lHabilAux
	oUfC:cSX1Hlp := "UA_ESTC"
	
	@ 156,004 SAY "Entrega" OF oDlgPagto PIXEL  //"Entrega"
	@ 156,045 MSGET oEnt VAR cEnt Picture "@!" SIZE 115,8 OF oDlgPagto PIXEL When lHabilAux
	oEnt:cSX1Hlp := "UA_ENDENT"
	
	@ 156,180 SAY "Bairro" OF oDlgPagto PIXEL  //"Bairro"
	@ 156,205 MSGET oBairroE VAR cBairroE Picture "@!" SIZE 80,8 OF oDlgPagto PIXEL When lHabilAux
	oBairroE:cSX1Hlp := "UA_BAIRROE"
	
	@ 171,004 SAY "Cidade" OF oDlgPagto PIXEL  //"Cidade"
	@ 171,045 MSGET oCidadeE VAR cCidadeE Picture "@!"  SIZE 80,8 OF oDlgPagto PIXEL Valid ;
	Tk273CidE(@oCidadeE,@cCidadeE) When lHabilAux
	oCidadeE:cSX1Hlp := "UA_CEPE"
	
	@ 171,150 SAY "CEP" OF oDlgPagto PIXEL //"CEP"
	@ 171,170 MSGET oCepE VAR cCepE  Picture "@R 99999-999"	SIZE 40,8 OF oDlgPagto PIXEL Valid ;
	Tk273CepE(	@cCepE	,@oCepE	,@cCidadeE	,@oCidadeE,;
	@cUfE	,@oUfE	,@cBairroE	,@oBairroE);
	When lHabilAux
	oCepE:cSX1Hlp := "UA_CEPE"
	
	@ 171,225 SAY "Estado" SIZE 25,8 OF oDlgPagto PIXEL //"Estado"
	@ 171,250 MSGET oUfE VAR cUfE Picture "@!" F3 "12"  SIZE 35,8 OF oDlgPagto PIXEL Valid Tk273Estado(cUfe) When lHabilAux
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Se for VISUALIZACAO nao precisa habilitar o botao de OK - nao havera novas manutencoes³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	@ 187,002 to 204,200 LABEL "Frete" OF oDlgPagto  PIXEL
	@ 193,005 checkbox oInc var lInc PROMPT "Frete Incluso" size 60,008 of oDlgPagto ;                      
	on change VpaSeleFrete(oInc,oCif,1,oFrete,	nOpc	,cNumTlv	,@nLiquido		,oLiquido,;
	@nTxJuros	,oTxJuros	,@nTxDescon		,oTxDescon,;
	@aParcelas	,oParcelas	,@cCodPagto		,oCodPagto,;
	@nEntrada	,oEntrada	,@nFinanciado	,oFinanciado,;
	@cDescPagto	,oDescPagto	,@nNumParcelas	,oNumParcelas,;
	@nVlrPrazo	,oVlrPrazo	,@nVlJur		,@cCodAnt,;
	@lTipo9		,@nValNFat	,oValNFat, @aItens,@lHabilita,oCurTmk,@cCodTransp,@oCodTransp,@cTransp, oTransp) 
  	@ 193,055 checkbox oCif var lCif PROMPT "Frete CIF"     size 60,008 of oDlgPagto ;
	on change VpaSeleFrete(oInc,oCif,2,oFrete,	nOpc		,cNumTlv	,@nLiquido		,oLiquido,;
	@nTxJuros	,oTxJuros	,@nTxDescon		,oTxDescon,;
	@aParcelas	,oParcelas	,@cCodPagto		,oCodPagto,;
	@nEntrada	,oEntrada	,@nFinanciado	,oFinanciado,;
	@cDescPagto	,oDescPagto	,@nNumParcelas	,oNumParcelas,;
	@nVlrPrazo	,oVlrPrazo	,@nVlJur		,@cCodAnt,;
	@lTipo9		,@nValNFat	,oValNFat,@aItens,@lHabilita,oCurTmk,@cCodTransp,@oCodTransp,@cTransp, oTransp)
	@ 193,105 Say "R$" size 10,8 of oDlgPagto pixel COLOR CLR_RED
	@ 193,117 SAY oFrete VAR nValFrete Picture "@KE 999,999.99" SIZE 60,008 OF oDlgPagto PIXEL COLOR CLR_RED
	
	If lHabilita
		
		DEFINE SBUTTON FROM 190,240 TYPE 1 ACTION (nOpcA := 1, lRet := IIF(Tk273ParcelaOk(aParcelas,nEntrada,nFinanciado,nValNFat,cTipoOper).and.;
		U_DIPG007("TMKVPA"),;  // Valida a condição de pagamento
		oDlgPagto:End(),; // Finaliza o objeto
		"")); // Não faz nada
		ENABLE OF oDlgPagto
	Endif
	
	If Type("lDip271Ok") == "U" .or. !lDip271Ok
		DEFINE SBUTTON FROM 190,280 TYPE 2 ACTION (lRet := .f.,oDlgPagto:End()) ENABLE OF oDlgPagto
	EndIf
	
	// Desabilita a tecla ESC
	oDlgPagto:LESCCLOSE := Eval({|| !(Type("lDip271Ok") == "U" .or. lDip271Ok)})
	
	oCodPagto:SetFocus()                 
	
//	cCliAnt := If(Empty(cEnt),"",cCliAnt)

//	IIF(!Empty(Alltrim(cCodPagto)) .And. Alltrim(cCodPagto) == Alltrim(SA1->A1_COND) .And. Empty(Alltrim(cEnt)),"",@cCodPagto) ,; //Tratamento para trazer endereços de cobrança e entrega MCVN - 07/11/2007
	ACTIVATE MSDIALOG oDlgPagto CENTERED ON INIT (Tk273InitPagto(	cNumTlv		,cCliente	,cLoja		,nOpc,;
	IIF(Empty(cEnt),"",@cCodPagto) ,; //Tratamento para trazer endereços de cobrança e entrega MCVN - 07/11/2007
	oCodPagto	,@cDescPagto,oDescPagto,;
	cCodTransp	,oCodTransp	,cTransp	,oTransp,;
	@cCob		,oCob		,@cEnt		,oEnt,;
	@cCidadeC	,oCidadeC	,@cCepC		,oCepC,;
	@cUfC		,oUfC		,@cBairroE	,oBairroE,;
	@cBairroC	,oBairroC	,@cCidadeE	,oCidadeE,;
	@cCepE		,oCepE		,@cUfE		,oUfE,;
	@cCliAnt),;           
	IIF(!Tk273CompVal(@aParcelas,nLiquido,nVlJur,cCodPagto,cCodAnt),;
	Tk273MontaParcela(	nOpc		 ,cNumTlv		,@nLiquido		,oLiquido,;
	@nTxJuros	 ,oTxJuros		,@nTxDescon		,oTxDescon,;
	@aParcelas	 ,oParcelas		,@cCodPagto		,oCodPagto,;
	@nEntrada	 ,oEntrada		,@nFinanciado	,oFinanciado,;
	@cDescPagto	 ,oDescPagto	,@nNumParcelas	,oNumParcelas,;
	@nVlrPrazo	 ,oVlrPrazo		,@nVlJur		,@cCodAnt,;
	@lTipo9		 ,nValNFat		,oValNFat),""),;
	IIF(lTMKCND,;
	U_TMKCND(	cNumTlv		,cCliente		,cLoja			,cCodCont,;
	cCodOper	,@aParcelas		,@cCodPagto		,oCodPagto,;
	@cDescPagto	,@oDescPagto 	,@lHabilAux) ,"") )
Endif

// Confirmou a condicao atualiza o rodape, caso haja acrescimo na condicao  
If nOpcA == 1
	aParcTef	:= AClone(aParcelas)
	M->UA_CONDPG:= cCodPagto
	If lInc .or. lCif
		M->UA_TPFRETE := If(lCif, 'C','I')
	Else
		M->UA_TPFRETE := cTipoFrete
	EndIf
Else
	// Cancelou limpa a condicao escolhida
	cCodPagto 	:= CriaVar("E4_CODIGO",.F.)
	cCodAnt		:= cCodPagto
	aParcelas 	:= {}
	lDip271Ok   := .f.  //  Libera execução do botão OK na tela do televendas
	Return(lRet)
Endif

If lTMKVCP
	If U_TMKVCP(@cCodTransp	,@oCodTransp	,@cTransp	,@oTransp,;
		@cCob		,@oCob			,@cEnt		,@oEnt,;
		@cCidadeC	,@oCidadeC		,@cCepC		,@oCepC,;
		@cUfC		,@oUfC			,@cBairroE	,@oBairroE,;
		@cBairroC	,@oBairroC		,@cCidadeE	,@oCidadeE,;
		@cCepE		,@oCepE			,@cUfE		,@oUfE,;
		nOpc		,cNumTlv		,cCliente	,cLoja,;
		cCodPagto	,aParcelas)
		lRet := .T.
		Return(lRet)
	Else
		Return(lRet)
	Endif
Endif

Return(lRet)

Static function VpaSeleFrete(oInc,oCif,nBt,oFrete, nOpc,cNumTlv,nLiquido,oLiquido,;
nTxJuros	,oTxJuros	,nTxDescon		,oTxDescon,;
aParcelas	,oParcelas	,cCodPagto		,oCodPagto,;
nEntrada	,oEntrada	,nFinanciado	,oFinanciado,;
cDescPagto	,oDescPagto	,nNumParcelas	,oNumParcelas,;
nVlrPrazo	,oVlrPrazo	,nVlJur			,cCodAnt,;
lTipo9		,nValNFat	,oValNFat,aItens,lHabilita,oCurTmk,cCodTransp,oCodTransp,cTransp, oTransp)
*------------------------------------------------------------------------------------
Local nFrete_Ant
Local bkp_lTk271Auto := lTk271Auto // Salvaa posição e restaura na saida do programa
lTk271Auto := .f.
If nBt = 1
	If lInc
		M->UA_TPFRETE := 'I' // Frete Incluso
		lCif:=.f.
		If !empty(M->UA_TRANSP).and. nValFrete = 0
			nFrete_Ant := M->UA_FRETE
			U_CalcuFrete('TMKVLDE4')
			nValFrete  := M->UA_FRETE
		EndIf
	ElseIf lCif
		nFrete_Ant := M->UA_FRETE
		nValFrete  := 0
		M->UA_TPFRETE := 'C' // Frete CIF
		M->UA_FRETE := 0
		M->UA_TRANSP := Space(6)
		cCodTransp	:= space(06)
		cTransp   := space(60)
		lInc:= .f.
	Else
		M->UA_TPFRETE := cTipoFrete
		If cTipoFrete == 'I'
			If !empty(M->UA_TRANSP).and. nValFrete = 0
				nFrete_Ant := M->UA_FRETE
				U_CalcuFrete('TMKVLDE4')
				nValFrete  := M->UA_FRETE
			EndIf
		ElseIf cTipoFrete == 'C'
			nFrete_Ant := M->UA_FRETE
			nValFrete  := 0
			M->UA_FRETE := 0
			M->UA_TRANSP := Space(6)
			cCodTransp	:= space(06)
			cTransp   := space(60)
		Else
			nFrete_Ant := M->UA_FRETE
			nValFrete  := 0
			M->UA_TPFRETE := cTipoFrete
			M->UA_FRETE := 0
			M->UA_TRANSP := Space(6)
			cCodTransp	:= space(06)
			cTransp   := space(60)
		EndIf
	EndIF
Else
	If lCif
		nFrete_Ant := M->UA_FRETE
		nValFrete := 0
		M->UA_FRETE := 0
		M->UA_TPFRETE := 'C' // Frete CIF
		M->UA_TRANSP := Space(6)
		cCodTransp	:= space(06)
		cTransp   := space(60)
		lInc:=.f.
	ElseIf lInc
		nFrete_Ant := M->UA_FRETE
		M->UA_TPFRETE := 'I' // Frete Incluso
		M->UA_TRANSP := Space(6)
		cCodTransp	:= space(06)
		cTransp   := space(60)
		lCif:= .f.
	Else
		M->UA_TPFRETE := cTipoFrete // Frete Incluso
		If cTipoFrete == "C"
			nFrete_Ant := M->UA_FRETE
			nValFrete := 0
			M->UA_FRETE := 0
		ElseIf cTipoFrete == "I"
			nFrete_Ant := M->UA_FRETE
		Else
			nFrete_Ant := M->UA_FRETE
			nValFrete := 0
			M->UA_FRETE := 0
			M->UA_TRANSP := Space(6)
			cCodTransp	:= space(06)
			cTransp   := space(60)
		EndIf
	EndIf
EndIf
aValores[FRETE] := M->UA_FRETE
aValores[TOTAL] := aValores[MERCADORIA]-aValores[DESCONTO]+aValores[ACRESCIMO]+aValores[FRETE]+aValores[DESPESA]
nLiquido := aValores[TOTAL]
nVlrPrazo:= aValores[MERCADORIA]+aValores[ACRESCIMO]+aValores[FRETE]+aValores[DESPESA]
nEntrada := nLiquido

For i:=1 to len(aParcelas)
	If lCif
		aParcelas[i][2] := aParcelas[i][2] - (nFrete_Ant/len(aParcelas))
	ElseIf lInc
		aParcelas[i][2] := aParcelas[i][2] + (M->UA_FRETE/len(aParcelas))
	Else
		If cTipoFrete == "I"
			aParcelas[i][2] := aParcelas[i][2] + (M->UA_FRETE/len(aParcelas))
		Else
			aParcelas[i][2] := aParcelas[i][2] - (nFrete_Ant/len(aParcelas))
		EndIf
	Endif
	//    aParcelas[i][2] := aValores[6] / len(aParcelas)
Next i

If ( Type("l410Auto") == "U" .OR. !l410Auto )
	MaFisAlt("NF_FRETE",aValores[FRETE])
	MaFisAlt("NF_DESPESA",aValores[DESPESA])
	MaFisAlt("NF_VALMERC",aValores[MERCADORIA])
	MaFisAlt("NF_TOTAL",aValores[TOTAL])
EndIf

M->UA_DESPESA := aValores[DESPESA]

oLiquido:Refresh()
oTxJuros:Refresh()
oTxDescon:Refresh()
oParcelas:Refresh()
oCodPagto:Refresh()
oEntrada:Refresh()
oFinanciado:Refresh()
oDescPagto:Refresh()
oNumParcelas:Refresh()
oVlrPrazo:Refresh()
oValNFat:Refresh()
oInc:Refresh()
oCif:Refresh()
oFrete:Refresh()
oCodTransp:Refresh()
oTransp:Refresh()
If Empty(cCodTransp)
	oCodTransp:Setfocus()
EndIf
RETURN(.T.)
*-----------------------------------------------------*
Static Function Tk273CalcAcre(nTxJuros,nVlJur)
*-----------------------------------------------------*
Local cPrcFiscal:= TkPosto(M->UA_OPERADO,"U0_PRECOF") 		//Preco fiscal bruto 1=SIM / 2=NAO
Local cAcrescimo:= TkPosto(M->UA_OPERADO,"U0_ACRESCI") 		//Acrescimo 1=ITEM / 2=NAO
Local lRet 		:= .F.                                      //Retorno da funcao

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se o posto de venda nao recalcula o unitario nao pode dar acrescimo³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ALLTRIM(cAcrescimo) == "2"  	   // Acrescimo = 2 - Nao
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Se nao estiver usando a entrada automatica³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Return(lRet)
ElseIf ALLTRIM(cPrcFiscal) == "1"  // Preco Fiscal Bruto NAO (NAO ALTERA O UNITARIO NAO PODE DAR ACRESCIMO)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Se nao estiver usando a entrada automatica³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Return(lRet)
Endif

If Len(aCols) > 0
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Joga o  ACRESCIMO financeiro calculado no campo "Acrescimo" do rodape da tela             ³
	//³Isso e feito assim para que na emissao da NF o SIGAFAT nao calcule duas vezes o acrescimo ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aValores[ACRESCIMO] := nVlJur
	Tk273RodImposto("NF_DESPESA",aValores[DESPESA]+aValores[ACRESCIMO])
Endif

lRet := .T.

Return(lRet)

*----------------------------------------------------------------------------*
Static Function Tk273CompVal(aParcelas,nLiquido,nVlJur,cCodPagto,cCodAnt)
*----------------------------------------------------------------------------*
Local lRet   := .F.			//Retorno da funcao
Local nTotAux:= 0           //Total das parcelas

If (Len(aParcelas) > 0)
	Aeval(aParcelas,{|aVal|nTotAux+= aVal[2]})	//Soma todas as colunas 2 do aParcelas (valor)
	
	If (nTotAux == nLiquido+nVlJur)
		lRet:= .T.
	Endif
	
	If cCodPagto <> cCodAnt
		aParcelas:= {}
		lRet:= .F.
	Endif
Endif
Return(lRet)
*------------------------------------------------------------------*
Static Function Tk273NFatura()
*------------------------------------------------------------------*
Local aArea		:= GetArea()        		// Guarda a area anterior
Local nI		:= 0                 		// Controle de loop
Local nValor  	:= 0                     	// Valor Nao Faturado
Local nPTes		:= aPosicoes[11][2]        // Posicao do TES
Local nPVlrItem	:= aPosicoes[6][2]         // Posicao do Valor do Item
Local nValIpi	:= 0                       	// Valor do IPI para o Item

For nI:=1 TO Len(aCols)
	If !aCols[nI][Len(aHeader)+1] .AND. !Empty(aCols[nI][nPTes])
		Dbselectarea("SF4")
		DbsetOrder(1)
		If MsSeek(xFilial("SF4")+aCols[nI][nPTes])
			If SF4->F4_DUPLIC == "N" //Nao Gera Duplicata
				//Considera o valor de IPI pois faz parte do valor total da nota.
				nValIpi:=MaFisRet(nI,'IT_VALIPI')
				nValor += aCols[nI][nPVlrItem]+nValIpi
			Endif
		Endif
	Endif
Next nI

RestArea(aArea)
Return(nValor)
*-----------------------------------------------------------------------------------*
Static Function Tk273ParcelaOk( aParcelas  ,nEntrada   ,nFinanciado  ,nValNFat   ,;
cTipoOper  )
*-----------------------------------------------------------------------------------*

Local nCont		:= 0								//Contador
Local nJuros	:= 0								//Total dos juros da condicao escolhida
Local lTmkDados	:= FindFunction("U_TMKDADOS")		//P.E. para TLV
Local lRet		:= .T.                              //Retorno da funcao

If !Empty(aParcelas)
	
	For nCont := 1 To Len(aParcelas)
		
		nJuros += Round(NoRound(aParcelas[nCont][2],4),2)
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica se existe parcela DINHEIRO fora da data     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If ("$" $ aParcelas[nCont][3]) .AND. (nCont > 1) .AND. (aParcelas[nCont][1] > dDataBase)
			Help( " ", 1, "NOPRAZO" )
			lRet  := .F.
			Exit
		Endif
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica se as Datas das parcelas estao corretas     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If nCont > 1
			If aParcelas[nCont][1] < aParcelas[nCont-1][1]
				Help(" ",1,"DATA_INVAL")
				lRet  := .F.
				Exit
			Endif
		Endif
	Next nCont
	
	If lRet
		If NoRound(nJuros,2) <> (aValores[TOTAL] - nValNFat)
			Help( " ", 1, "TK010VALOK" )
			lRet  := .F.
		Endif
	Endif
	
	If lRet .AND. cTipoOper == "1"   //Faturamento
		
		For nCont := 1 To Len(aParcelas)
			If !IsMoney(aParcelas[nCont][3]) .AND. ALLTRIM(aParcelas[nCont][3]) <> "CH"
				
				If lUsaTef .AND. (cTipTef <> NIL)
					//Se o atendimento for com TEF e for CLISITEF nao verifica a Administradora, pois a mesma e informada durante a transacao
					If cTipTef <> TEF_CLISITEF
						
						If Empty(aParcelas[nCont][4]) .OR. SUBSTR(aParcelas[nCont][4],1,1) == "*"
							//"Selecione uma administradora financeira para a parcela "
							MsgStop("Selecione uma administradora financeira para a parcela "+ALLTRIM(STR(nCont))+".")
							lRet  := .F.
							Exit
						Endif
						
					Endif
				Endif
				
			Endif
		Next nCont
		
	Endif
Endif

If lRet .AND. lTMKDADOS
	U_TMKDADOS()
Endif

Return(lRet)
*----------------------------------------------------------*
Static Function VpaAtuTransp(;
cCodTransp,;
oCodTransp,;
cTransp,;
oTransp,;
cCob,;
oCob,;
cEnt,;
oEnt,;
cCidadeC,;
oCidadeC,;
cCepC,;
oCepC,;
cUfC,;
oUfC,;
cBairroE,;
oBairroE,;
cBairroC,;
oBairroC,;
cCidadeE,;
oCidadeE,;
cCepE,;
oCepE,;
cUfE,;
oUfE,;
nOpc,;
cNumTlv,;
cCliente,;
cLoja,;
cCodPagto,;
aParcelas,;
oFrete)
*----------------------------------------------------------*
Local AreaTmkVCP := Getarea()
Local bkp_lTk271Auto := lTk271Auto // Salvaa posição e restaura na saida do programa
Local lRecalcula := .f.
Local nLiquido := 0
Local oLiquido := ''
Local nTxJuros := 0
Local oTxJuros := ''
Local nTxDescon:= 0
Local oTxDescon:= ''
Local oParcelas:= ''
Local oCodPagto:= ''
Local nEntrada := 0
Local oEntrada := ''
Local nFinanciado:= 0
Local oFinanciado:= ''
Local cDescPagto:= ''
Local oDescPagto:= ''
Local nNumParcelas := 0
Local oNumParcelas := ''
Local nVlrPrazo := 0
Local oVlrPrazo := ''
Local nVlJur := 0
Local cCodAnt := If(cCodPagto == '016',cCodPagto,"")
Local lTipo9:= .t.
Local oValNFat := ''
Local lRet := .F.

//aParcelas:={}

cTransp := CRIAVAR("A4_NOME",.F.)

If !empty(cCodTransp)
	//----------------------------------------------
	// Calcula o Frete para esta transportadora
	//----------------------------------------------
	M->UA_TRANSP := cCodTransp
	U_CalcuFrete('TMKVLDE4')
	
Else
	//----------------------------------------------
	// O Usuario limpou a codigo da transportadora:
	// Calcula o frete para todas as transportadoras
	// E o usuario seleciona o que achar conveniente
	//----------------------------------------------
	U_CalcuFrete('TMKVCP')
	
EndIf
nValFrete  := M->UA_FRETE
If Type("oFrete")=="O"
	oFrete:Refresh()
EndIf
cCodTransp := M->UA_TRANSP
lTk271Auto:=.t. // Ignora refresh na função
//----------------------------------------------
// Grava o novo frete calculado na Array
//----------------------------------------------
aValores[4] := M->UA_FRETE // JBS 27/03/2006
//----------------------------------------------
//Calcula o Valor Nao Faturado
//----------------------------------------------
nLiquido := aValores[6]
nValNFat := Tk273NFatura()
nLiquido := nLiquido - nValNFat
nVlrPrazo:= aValores[MERCADORIA]+aValores[ACRESCIMO]+aValores[FRETE]+aValores[DESPESA]
nEntrada := nLiquido
//----------------------------------------------
// Recalcula o valor das parcelas
//----------------------------------------------
Tk273MontaParcela(nOpc,;
cNumTlv,;
@nLiquido,;
oLiquido,;
@nTxJuros,;
oTxJuros,;
@nTxDescon,;
oTxDescon,;
@aParcelas,;
oParcelas,;
@cCodPagto,;
oCodPagto,;
@nEntrada,;
oEntrada,;
@nFinanciado,;
oFinanciado,;
@cDescPagto,;
oDescPagto,;
@nNumParcelas,;
oNumParcelas,;
@nVlrPrazo,;
oVlrPrazo,;
@nVlJur,;
@cCodAnt,;
@lTipo9,;
nValNFat,;
oValNFat)

RestArea(AreaTmkVCP)
lTk271Auto := bkp_lTk271Auto

SA4->(DbSetorder(1))
If SA4->(DbSeek(xFilial("SA4")+cCodTransp))
	cTransp := SA4->A4_NOME
	M->UA_NOMETRA:= SA4->A4_NOME  // Eriberto 31/01/2007
	
	If !lTk271Auto
		oTransp:Refresh()
	Endif
	lRet := .T.
Endif

Return(lRet)
*------------------------------------------------------------------------------------*
Static Function Tk273Detalhe(aParcelas	,oParcelas	,aItens		,lHabilita,;
nLiquido	,nEntrada	,oEntrada	,nFinanciado,;
oFinanciado,cCodPagto	,lSigaCRD)

Local cComplemento 	:= SPACE(80)        				// Obervacao do SL4
Local nPos 			:= 0								// Posicao no APARCELAS
Local aAux 			:= {}                               // Variavel auxiliar
Local nCont			:= 0                                // Contador
Local aMatriz 		:= {}                               // Array com as formas de pagamento
Local aChave  		:= {}								// Array com as formas de pagamento
Local cComboForma 	:= ""								// Combobox para escolhar a forma de pagamento - tabela 24
Local oComboForma										// Objeto COMBO
Local dDtParcela  	:= CTOD("  /  /  ")					// Data de vencimento da parcela - VISUAL
Local oDtParcela										// Objeto GET
Local nVlrParcela 	:= 0								// Valor da parcela - VISUAL
Local oVlrParcela                                       // Objeto GET
Local cTipo			:= ""								// Tipo da forma de pagamento
Local dDataAnt 		:= CTOD("  /  /  ")					// Data anterior
Local nValAnt  		:= 0								// Valor anterior
Local cComboAnt		:= ""                               // Conteudo do combo anterior
Local oDetailDlg										// Tela
Local lOk			:= IIF(GETMV("MV_TMKLOJ") == "I",.T.,.F.)	//Flag que vai controlar a alteracao da data e do valor da parcela
//SOMENTE QUANDO HOUVER INTEGRACAO COM SIGALOJA

Local lRet			:= .F.								// Retorno da funcao

Local cForma		:= ""								// Forma Pagto
Local cFormaId		:= IIf(lVisuSint,Space(TamSX3("L4_FORMAID")[1]),Space(01))	// ID do cartao
Local cFormaIdAnt 	:= cFormaId							// ID anterior do cartao
Local nLinha		:= 0                            	// Linha selecionada no browse
Local nParc			:= 1								// Nr. parcelas
Local oParc 											// Objeto GET nr. parcelas
Local oCart 											// Objeto GET ID do cartao
Local oCheckPag 										// Objeto Checkbox
Local lCheckPag		:= .F.								// indica se utiliza nas prox. parcelas
Local cSx1Hlp		:=""								// Help do objeto selecionado
Local lConfirma		:= .F.								// Indica se confirmou a operacao digitada
Local nX 			:= 1								// variav. auxiliar em lacos for...next
Local lTefMult		:= SuperGetMV("MV_TEFMULT")			// Parametro do SX6 que indica se o sistema vai o TEF multiplas transacoes

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Limpo os dados do complemento da parcela selecionada³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cComplemento := SPACE(80)

If Len(aParcelas) == 0 .OR. Empty(aParcelas[1][1])
	aParcelas := {}
	aParcelas :={{CTOD("  /  /  "),0,SPACE(15),SPACE(80)}}
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Todo refresh de objeto deve considerar se existe ENTRADA AUTOMATICA  ou NAO - no SIGATMK o flag e LTK271AUTO³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !lTk271Auto
		oParcelas:Refresh()
	Endif
	Return(lRet)
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Pega a linha da parcela selecionada ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lVisuSint .AND. Type("oPgtosAna")=="O"
	//Visualizacao sintetica
	nLinha := oPgtosAna:nAt
Else
	//Visualizacao normal
	nLinha := oParcelas:nAt
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Pega o ID do cartao quando esta habilitado o TEF com mult. transacoes ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If	lUsaTef 	.AND.;
	lTefMult 	.AND.;
	lVisuSint
	
	cFormaID 	:= aParcelas[nLinha][6]
	cFormaIdAnt := cFormaID
Endif

dDtParcela 	:= aParcelas[nLinha,1]		//Data
nVlrParcela	:= aParcelas[nLinha,2]		//Valor da parcela

For nCont := 1 To Len(aItens)
	AAdd(aMatriz,aItens[nCont][1])
	AAdd(aChave ,aItens[nCont][2])
Next nCont

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Pesquisa no ARRAY de dados complementares da parcela qual foi a parcela selecionada³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nPos := Ascan(aItens,{|aAux|ALLTRIM(aAux[2]) == ALLTRIM(aParcelas[nLinha,3])})

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Tratamento para proteger o codigo caso os dados da base estejam inconsistentes     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If  nPos < 1
	Help(" ",1,"TK273TAB24" )
	Return(lRet)
Endif

cComboForma	:= aItens[nPos,1]
cTipo	   	:= aItens[nPos,2]

dDataAnt  	:= aParcelas[nLinha,1]
nValAnt   	:= aParcelas[nLinha,2]
cComboAnt 	:= aParcelas[nLinha,3]

DEFINE MSDIALOG oDetailDlg FROM 10,20 TO 235,300 TITLE "Forma de Pagamento da Parcela" PIXEL STYLE DS_MODALFRAME  //"Forma de Pagamento da Parcela"

@ 05,10 SAY "Data" SIZE 30,8 PIXEL OF oDetailDlg  //"Data"

@ 05,37 MSGET oDtParcela VAR dDtParcela SIZE 50,8 PIXEL OF oDetailDlg PICTURE "99/99/99" ;
WHEN lOk VALID Tk273ValData(dDataAnt	,@dDtParcela	,oDtParcela	,aParcelas,;
oParcelas	,aItens			,cComboForma)

@ 20,10 SAY "Valor" SIZE 30,8 PIXEL OF oDetailDlg //"Valor"
@ 20,37 MSGET oVlrParcela VAR nVlrParcela SIZE 30,8 PIXEL OF oDetailDlg PICTURE "@E 9999999.99" WHEN lOk RIGHT

@ 35,10 SAY "Forma" SIZE 50,8 PIXEL OF oDetailDlg //"Forma"
@ 35,37 MSCOMBOBOX oComboForma VAR cComboForma ITEMS aMatriz SIZE 100,50 OF oDetailDlg PIXEL ;
VALID TK273Data(cComboForma,aParcelas,aItens,dDtParcela);
ON CHANGE (cTipo := aChave[oComboForma:nAt]) ;
WHEN lHabilita .AND. (If(nLinha == 0 .OR. (lVisuSint .AND. cTipo$_FORMATEF) ,.F.,.T.))

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Objetos para tratamento de mult. transacoes TEF ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lUsaTef 	.AND.;
	lTefMult	.AND.;
	lVisuSint .AND.;
	cTipTef == TEF_CLISITEF
	
	@ 50,10 Say "ID Cartão" SIZE 50,8 PIXEL OF oDetailDlg 	//"ID Cartão"
	@ 50,37 MSGET oCart VAR cFormaId RIGHT SIZE 15,08 OF oDetailDlg PIXEL PICTURE PesqPict("SL4","L4_FORMAID") ;
	WHEN  TK273WhenID(nLinha,cTipo,@cFormaId,aItens) VALID TK273ValidID(cTipo,@cFormaId,aItens)
	oCart:cSx1Hlp:="L4_FORMAID"
Endif

If lVisuSint .AND. (nLinha == 0 .AND. cTipo $ _FORMATEF )
	@ 65,10 Say "Parcelas" SIZE 10,1 		//"Parcelas"
	@ 65,37 MSGET oParc VAR nParc	RIGHT SIZE 15,08 PICTURE "99" VALID(If (nParc < 1 ,(MsgStop("Valor nao permitido para esse campo"), .F.),.T.)) // Valor nao permitido para esse campo
	oParc:cSx1Hlp:=""
Endif

If nLinha > 0 .AND. nLinha < Len(aParcelas) .AND. !IsMoney(cTipo)
	@ 80,10 CHECKBOX oCheckPag VAR lCheckPag PROMPT "Utiliza nas próximas parcelas" SIZE 90,8 OF oDetailDlg //"Utiliza nas próximas parcelas"
	oCheckPag:cSx1Hlp:=""
Endif

DEFINE SBUTTON FROM 95,070 TYPE 1 ACTION (Tk273Compl(cComboForma	,cTipo		,@aParcelas	,@oParcelas,;
aItens			,lHabilita	,cCodPagto	,lSigaCRD), lConfirma:=.T., oDetailDlg:End()) ENABLE OF oDetailDlg

DEFINE SBUTTON FROM 95,105 TYPE 2 ACTION (lConfirma:=.f., oDetailDlg:End()) ENABLE OF oDetailDlg

// Desabilita a tecla ESC
oDetailDlg:LESCCLOSE := .F.

ACTIVATE MSDIALOG oDetailDlg CENTER

If lConfirma
	If nVlrParcela > 0
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Atualiza os dados da parcela ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aParcelas[nLinha][1] := dDtParcela
		aParcelas[nLinha][2] := nVlrParcela
		aParcelas[nLinha][3] := cTipo
		aParcelas[nLinha][6] := cFormaID
		
		If lCheckPag
			For nX := nLinha+1 To Len(aParcelas)
				//Só alterar as próximas parcelas iguais a originária devido ao controle de datas
				If !IsMoney(cComboAnt) .AND. Alltrim(aParcelas[nX][3]) == Alltrim(cComboAnt) ;
					.AND. Alltrim(aParcelas[nX][6]) == Alltrim(cFormaIdAnt)
					
					aParcelas[nX][3] := aParcelas[nLinha][3]
					aParcelas[nX][6] := aParcelas[nLinha][6]
				Endif
			Next nX
		Endif
		
	Endif
	
	oParcelas:SetArray(aParcelas)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Todo refresh de objeto deve considerar se existe ENTRADA AUTOMATICA  ou NAO - no SIGATMK o flag e LTK271AUTO³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !lTk271Auto
		oParcelas:Refresh()
	Endif
	
	//Atualiza array de parcelas (analitico)
	If Type("oPgtosAna") == "O"
		oPgtosAna:SetArray(aParcelas)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Todo refresh de objeto deve considerar se existe ENTRADA AUTOMATICA  ou NAO - no SIGATMK o flag e LTK271AUTO³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !lTk271Auto
			oPgtosAna:Refresh()
		Endif
	Endif
	
	// Atualiza Array de parcelas (Sintetizado)
	If 	lVisuSint 	.AND. ;
		lUsaTef 	.AND. ;
		cTipTef == TEF_CLISITEF
		
		aPgtosSint := Tk273MontPgt(aParcelas)
		oPgtosSint:SetArray( aPgtosSint )
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Todo refresh de objeto deve considerar se existe ENTRADA AUTOMATICA  ou NAO - no SIGATMK o flag e LTK271AUTO³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !lTk271Auto
			oPgtosSint:Refresh()
		Endif
	Endif
	
Endif

Return(.T.)
*------------------------------------------------------------------*
Static Function TK273Data(cComboForma,aParcelas,aItens,dDtParcela)
*------------------------------------------------------------------*
Local cForma := ""		//Forma de pagamento
Local nPos   := 0		//Contador
Local lRet	 := .T.		//Retorno da funcao

nPos 	:= Ascan(aItens,{|X| ALLTRIM(X[1]) == ALLTRIM(cComboForma) })
If nPos > 0
	cForma 	:= aItens[nPos][2]	//Forma de pagamento no ARRAY
	If ("$" $ SubStr(cForma,1,2)) .AND. ( Len(aParcelas) <> 1 ) .AND. (dDtParcela > dDataBase)
		Help( " ", 1, "NOPRAZO" )
		lRet := .F.
	Endif
Endif

Return(lRet)
*-----------------------------------------------------------------------------*
Static Function Tk273Compl(	cComboForma	,cTipo		,aParcelas	,oParcelas,;
aItens		,lHabilita	,cCodPagto	,lSigaCRD)
*-----------------------------------------------------------------------------*
Local cBanco 	:=SPACE(3),oBanco			//Banco
Local cAgencia	:=SPACE(5),oAgencia			//Agencia
Local cConta 	:=SPACE(10),oConta			//Conta
Local cCheque 	:=SPACE(15),oCheque			//Cheque
Local cRg 		:=SPACE(14),oRg				//RG
Local cFone 	:=SPACE(15),oFone			//Telefone
Local cComboAdm	:=SPACE(20),oComboAdm		//Administradora
Local aSAE    	:={}						//Array com as Administradoras cadastradas
Local cCartao	:=SPACE(20),oCartao			//Dados do cartao
Local dDtValid 	:=CTOD("  /  /  "),oDtValid	//Data de validade
Local cAutor	:=SPACE(6),oAutor			//Codigo de autorizacao
Local oDlg									//Tela
Local nPos 		:= 0                        //Posicao
Local lCheckBox	:=.F.,oCheckBox				//Checkbox
Local cDetalhe	:= SPACE(80)				//Detalhe
Local nOpca 	:= 0						//Opcao de escolha OK ou CANCELA
Local lShowDlg  := .T.						//Flag para exibicao da tela dos dados complementares
Local cFormCRD	:= SuperGetMv("MV_FORMCRD",,"CH/FI") //Formas de pagamento aceitas para analise de credito do SIGACRD
Local nLinha	:= 0  						//Linha selecionada no browse

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se a regra de negocio cadastrada e valida com a tabela de preco escolhida³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ! FtRegraNeg(M->UA_CLIENTE,M->UA_LOJA,M->UA_TABELA,cCodPagto,cTipo)
	//"A parcela ____  difere da regra de negocio definida."Parcela - Regra de Negocio"
	Return(.F.)
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica qual eh a forma de visualizacao das parcelas ³
//³ Sintetica ou analitica                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lVisuSint .AND. Type("oPgtosAna")=="O"
	//Visualizacao sintetica
	nLinha := oPgtosAna:nAt
Else
	//Visualizacao normal
	nLinha := oParcelas:nAt
Endif


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se for a vista n„o tem informa‡”es complementares			    	  ³
//³Se estiver usando TEF nao tem informacoes complementares para CC e CH  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lUsaTef
	If (cTipo == "CC" .OR. cTipo == "CH") .OR. ("$" $ cTipo) .OR. !(cTipo $ "CCVAFICOCH")
		lShowDlg := .F.
	Endif
Endif

cDetalhe := aParcelas[nLinha,4]	//Detalhes da parcela - cartao, cheque, etc

If lShowDlg
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Se for pagamento em CHEQUE					     					  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If (cTipo == "CH")
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Se o valor digitado anteriormente n„o foi em CHEQUE limpo o complemento³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If Substr(cDetalhe,79,2) <> "CH"
			cDetalhe:=SPACE(80)
		Endif
		
		cBanco  := Substr(cDetalhe,1,3)
		cAgencia:= Substr(cDetalhe,4,5)
		cConta  := Substr(cDetalhe,9,10)
		cCheque := Substr(cDetalhe,19,15)
		cRg     := Substr(cDetalhe,34,14)
		cFone   := Substr(cDetalhe,48,15)
		
		DEFINE MSDIALOG oDlg FROM 10,20 TO 210,250 TITLE "Complemento da Parcela" PIXEL STYLE DS_MODALFRAME  //"Complemento da Parcela"
		
		@05,10 SAY "Banco" OF oDlg PIXEL //"Banco"
		@05,47 MSGET oBanco VAR cBanco Picture "999" SIZE 40,8 OF oDlg PIXEL When lHabilita RIGHT
		
		@16,10 SAY "Agencia" OF oDlg PIXEL //"Agencia"
		@16,47 MSGET oAgencia VAR cAgencia Picture "99999" SIZE 40,8 PIXEL OF oDlg When lHabilita RIGHT
		
		@26,10 SAY "Conta" OF oDlg PIXEL //"Conta"
		@26,47 MSGET oConta VAR cConta Picture "9999999999" SIZE 60,8 PIXEL OF oDlg When lHabilita RIGHT
		
		@36,10 SAY "Cheque" OF oDlg PIXEL //"Cheque"
		@36,47 MSGET oCheque VAR cCheque Picture "999999999999999" SIZE 60,8 PIXEL OF oDlg When lHabilita RIGHT
		
		@46,10 SAY "RG" OF oDlg PIXEL //"RG"
		@46,47 MSGET oRg VAR cRg Picture "@R 99.999.999.999" SIZE 60,8 PIXEL OF oDlg When lHabilita RIGHT
		
		@56,10 SAY "Telefone" OF oDlg PIXEL //"Telefone"
		@56,47 MSGET oFone VAR cFone  Picture "@R (999) 9999-9999" SIZE 60,8 PIXEL OF oDlg When lHabilita RIGHT
		
		@68,10 CHECKBOX oCheckBox VAR lCheckBox PROMPT "Aplica em todas as parcelas" SIZE 90,10 OF oDlg PIXEL WHEN (nLinha <> Len(aParcelas))  //"Aplica em todas as parcelas"
		
		DEFINE SBUTTON FROM 85,055 TYPE 1 ACTION (nOpca := 1,oDlg:End()) ENABLE OF oDlg
		
		DEFINE SBUTTON FROM 85,085 TYPE 2 ACTION oDlg:End() ENABLE OF oDlg
		
		// Desabilita a tecla ESC
		oDlg:LESCCLOSE := .F.
		
		ACTIVATE MSDIALOG oDlg CENTER
		
		If nOpcA == 1
			cDetalhe := cBanco + cAgencia + cConta + cCheque + cRg + cFone + SPACE(16) + cTipo
		Endif
		
		nAux := IIF(!Empty(cCheque),VAL(cCheque),0)
		
	ElseIf (cTipo == "CC") .OR. cTipo $ cFormCRD
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Carrega as administradora de cart„o de cr‚dito					      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		DbSelectarea("SAE")
		DbSetorder(1)
		DbSeek(xFilial("SAE"))
		While !Eof() .AND. SAE->AE_FILIAL == xFilial("SAE")
			AADD(aSAE,AE_COD+"-"+AE_DESC)
			DbSkip()
		End
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Se o valor digitado ou gravado anteriormente n„o foi em CARTAO limpo o complemento³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If Substr(cDetalhe,79,2) $ "CH"
			cDetalhe:=SPACE(80)
		Endif
		
		cComboAdm 	:=Substr(cDetalhe,1,AT("*",cDetalhe)-1)
		cCartao 	:=Substr(cDetalhe,AT("*",cDetalhe),16)
		dDtValid	:=CTOD(Substr(cDetalhe,AT("*",cDetalhe)+16,8))
		cAutor 	 	:=Substr(cDetalhe,AT("*",cDetalhe)+16+8,6)
		
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Se o conteudo da administradora nao estiver vazio, seleciona o valor gravado³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		
		If !Empty(cComboAdm)
			nPos:= Ascan(aSAE,{|x| UPPER(x) == UPPER(cComboAdm)})
			If nPos > 0
				cComboAdm:= aSAE[nPos]
			Endif
		Endif
		
		DEFINE MSDIALOG oDlg FROM 10,20 TO 210,300 TITLE "Complemento da Parcela" PIXEL STYLE DS_MODALFRAME  //"Complemento da Parcela"
		
		@05,10 SAY "Administradora" OF oDlg PIXEL //"Administradora"
		@05,57 MSCOMBOBOX oComboAdm VAR cComboAdm ITEMS aSAE SIZE 80,8 PIXEL OF oDlg When lHabilita

		@20,10 SAY "Cartão" OF oDlg PIXEL //"Cart„o"
		@20,57 MSGET oCartao  VAR cCartao Picture "@R XXXXXXXXXXXXXXXX" SIZE 80,8 PIXEL OF oDlg VALID !Empty(cCartao) When lHabilita
		
		@35,10 SAY "Validade" OF oDlg PIXEL  //"Validade"
		@35,57 MSGET oDtValid VAR dDtValid Picture "99/99/99" SIZE 50,8 PIXEL OF oDlg VALID !Empty(dDtValid) When lHabilita
		
		@50,10 SAY "Autorização" OF oDlg PIXEL  //"Autoriza‡„o"
		@50,57 MSGET oAutor  VAR cAutor Picture "@!"  SIZE 40,8 PIXEL OF oDlg When lHabilita
		
		@65,10 CHECKBOX oCheckBox VAR lCheckBox PROMPT "Aplica em todas as parcelas" SIZE 90,10 OF oDlg PIXEL WHEN lHabilita  //"Aplica em todas as parcelas"
		
		//Confirmacao - Botao de Ok
		DEFINE SBUTTON FROM 80,075 TYPE 1 ACTION (nOpca:= 1,oDlg:End()) ENABLE OF oDlg
		
		DEFINE SBUTTON FROM 80,105 TYPE 2 ACTION oDlg:End() ENABLE OF oDlg
		
		// Desabilita a tecla ESC
		oDlg:LESCCLOSE := .F.
		
		ACTIVATE MSDIALOG oDlg CENTER
		
		If nOpcA == 1
			cDetalhe := cComboAdm + "************" + If(!Empty(cCartao),SubStr(cCartao,13,4),"****") + DTOC(dDtValid) + cAutor + SPACE(28) + cTipo
		Endif
	Endif
	
Else
	nOpca := 1
Endif

If nOpca == 1
	If lCheckBox
		
		For nPos := 1 TO Len(aParcelas)
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Verifico se a parcela e igual a parcela preenchida e se nao 			   ³
			//³e a primeira, pois o numero sequencial dos cheques e a partir da segunda³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If (cTipo == "CH")
				If (nPos > 1)
					nAux ++
				Endif
				
				cDetalhe := cBanco + cAgencia + cConta + StrZero(nAux,Len(cCheque)) + cRg + cFone + SPACE(16) + cTipo
			Endif
			
			aParcelas[nPos,3] := cTipo
			aParcelas[nPos,4] := cDetalhe
			
		Next nPos
		
	Else
		
		nPos := Ascan( aItens, { |x| x[1] = cComboForma } )
		If nPos > 0
			aParcelas[nLinha,3] := aItens[nPos][2]	//Forma de pagamento
			aParcelas[nLinha,4] := cDetalhe			//Detalhes
		Endif
		
	Endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Todo refresh de objeto deve considerar se existe ENTRADA AUTOMATICA  ou NAO - no SIGATMK o flag e LTK271AUTO³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !lTk271Auto
		oParcelas:Refresh()
	Endif
	
Else
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Caso nao seja necessario o complemento e a parcela nao      ³
	//³for cheque e nem cartao altera a terceira coluna do aParcelas³
	//³ com a forma de pagto escolhida.                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nPos := Ascan( aItens, { |x| x[1] = cComboForma } )
	If nPos > 0
		aParcelas[nLinha,3] := aItens[nPos][2]		//Forma de Pagamento
		aParcelas[nLinha,4] := cDetalhe				//Detalhes
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Todo refresh de objeto deve considerar se existe ENTRADA AUTOMATICA  ou NAO - no SIGATMK o flag e LTK271AUTO³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !lTk271Auto
		oParcelas:Refresh()
	Endif
	
Endif

Return(.T.)
*------------------------------------------------------------------------*
Static Function VPADipValid(nOpc,cNumTlv	, nLiquido		,oLiquido,;
nTxJuros	,oTxJuros	, nTxDescon		,oTxDescon,;
aParcelas	,oParcelas	, cCodPagto		,oCodPagto,;
nEntrada	,oEntrada	, nFinanciado	,oFinanciado,;
cDescPagto	,oDescPagto	, nNumParcelas	,oNumParcelas,;
nVlrPrazo	,oVlrPrazo	, nVlJur		, cCodAnt,;
lTipo9		,nValNFat	,oValNFat, aValores)
*-----------------------------------------------------------------------*
Local _lRetorno := .f. 
Local _OperLicita := GetMV("MV_OPERLIC") // Operadores de licitação

If !Empty(cCodPagto)
	SE4->(dbSetOrder(1))
	If SE4->(DbSeek(xFilial("SE4")+cCodPagto))
		//		lTipo9 := SE4->E4_TIPO == "9"
	Endif
EndIf

If !Empty(cCodPagto) .and.;
	Tk273MontaParcela(nOpc        ,cNumTlv    ,@nLiquido	,oLiquido,;
	@nTxJuros	  ,oTxJuros   ,@nTxDescon	,oTxDescon,;
	@aParcelas  ,oParcelas  ,@cCodPagto	,oCodPagto,;
	@nEntrada	  ,oEntrada	  ,@nFinanciado	,oFinanciado,;
	@cDescPagto ,oDescPagto ,@nNumParcelas,oNumParcelas,;
	@nVlrPrazo  ,oVlrPrazo  ,@nVlJur		,@cCodAnt,;
	@lTipo9	  ,nValNFat	  ,oValNFat)
	
	SE4->(DbSeek(xFilial("SE4")+cCodPagto))
	
  //If cCodPagto == "167" .AND. M->UA_OPERADO $ '000013/000056/000106/000109/000130' // JBS 25/10/2006 000130
	If cCodPagto == '167' .and. M->UA_OPERADO $ _OperLicita // Buscando no parâmetro os operadores de Licitação MCVN - 09/10/2007
		
		_lRetorno := .t.
		
	ElseIf aValores[6] >= SE4->E4_INFER .AND. aValores[6] <= SE4->E4_SUPER .and.;
		(Empty(SE4->E4_SEGMENT) .OR.;
		(!Empty(SE4->E4_SEGMENT).AND. AllTrim(SA1->A1_SATIV1) $ SE4->E4_SEGMENT))  // verifica se condição está atrelada a segmento
		
		_lRetorno := .t.
		
	ElseIf M->UA_CONDPG == SA1->A1_COND // Caso a condição de pagamento do pedido seja a mesma do cadastro do cliente não pede senha  -  MCVN 09/10/2007

		_lRetorno := .t.		

	ElseIf !(aValores[6] >= SE4->E4_INFER .AND. aValores[6] <= SE4->E4_SUPER)
		
		_lRetorno := .f.
		
		If ( Type("l410Auto") == "U" .OR. !l410Auto ) .and. VAL(M->UA_OPER)=FATURAMENTO  // 1 Faturamento 2 Orçamento
			
			If !M->UA_CLIENTE $ _cCliEspecial
				
				If !U_DipSenha("PAG", M->UA_CONDPG, aValores[6], 0,.f.)
					_lRetorno := U_Senha("PAG",aValores[6],0,0)
					If _lRetorno
						U_DipSenha("PAG", M->UA_CONDPG, aValores[6], 0,.t.)
					EndIf
				Else
					_lRetorno := .t.
				Endif
			Else
				_lRetorno := .t.
			EndIf
		Else
			_lRetorno := .t.
		EndIf
		
	ElseIf !Empty(SE4->E4_SEGMENT) .and. !AllTrim(SA1->A1_SATIV1) $ SE4->E4_SEGMENT
		
		If ( Type("l410Auto") == "U" .OR. !l410Auto )
			
			_lRetorno := .f.
			
			If !M->UA_CLIENTE $ _cCliEspecial .AND. VAL(M->UA_OPER)=FATURAMENTO
				
				If !U_DipSenha("PAG", M->UA_CONDPG, aValores[6], 0,.f.) // Se não possui senha já confirmada
					
					_lRetorno := U_Senha("PAG",aValores[6],0,0,.t.)
					
					If _lRetorno .and. !'ERICH' $ Alltrim(M->UA_SENHPAG)
						
						MsgInfo("Para esta condicao de Pagamento, só é valida a senha do Erich")
						_lRetorno := .f.
						
					EndIf
					
					If _lRetorno
						U_DipSenha("PAG", M->UA_CONDPG, aValores[6], 0,.t.)
					EndIf
					
				Else
					_lRetorno := .t.
				EndIf
				
			Else
				_lRetorno := .t.
			EndIf
		EndIf
	EndIf
EndIf

If _lRetorno
	aDipTipo9 := Aclone(aParcelas)
EndIf

Return(_lRetorno)
/*
*-------------------------------------*
User Function TmkTipo9()
*-------------------------------------*
Local nLinha
Local nOpc := Paramixb[1]
Local nCabeca

If Len(aDipTipo9) > 0
	
	nCabeca := Len(aHeader)+1
	For nLinha := 1 TO LEN(aDipTipo9)
		If !Empty(aDipTipo9[nLinha][1])
			Aadd(aCols,{0,CTOD(""),.F. })
			aCols[nLinha][1] := aDipTipo9[nLinha][2] //,aDipTipo9[nLinha][5])  //Valor, Percentual
			aCols[nLinha][2] := aDipTipo9[nLinha][1] //Data
			aCols[nLinha][3] := .F.
		EndIf
	Next nLinha
	
Else
	
	aCols := Array(1, Len(aHeader) + 1)
	aCols[1][1] := 0
	aCols[1][2] := CTOD("")
	aCols[1][3] := .F.			//Linha de controle de DELECAO
	
Endif

Return(nOpc)
*/

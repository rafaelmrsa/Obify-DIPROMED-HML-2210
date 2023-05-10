/*---------------------------------------------------------------------------------------*

Empresa.......: DIPOMED Comércio e Importação Ltda.
Programa......: NFFATURA.CH

Objetivo......: Constantes para o Programa nffatura.prw

Autor.........: Jailton B Santos (JBS), Analista de Sistemas.
Data..........: 20 Jul 2005
Versão........: 1.0

*---------------------------------------------------------------------------------------*/
#DEFINE f_linha chr(13)+chr(10) // Fim de Linha

*------------------------------------------------*
*        " Posições do array aNfsJaImp "         *
*------------------------------------------------*
#DEFINE  NR_DOC     01  // Numero da Nota Fiscal
#DEFINE  SERIE      02  // Serie da Nota Fiscal
#DEFINE  FORMULARIO 03  // Numero do Formulario da Nota
#DEFINE  OPERACAO   04  // Operação a realizar Marcar para Re-Imp, Cancelar...
#DEFINE  TIPO       06  // Nota de Entrada/Saida
#DEFINE  REGISTRO   07  // Recno da Nota na Tabela
#DEFINE  SITUACAO   08
*------------------------------------------------*
*       " Posições do array aDetalhePed "        *
*------------------------------------------------*
#DEFINE  COD_PRO    01  // Codigo  do Produto
#DEFINE  PED_VEND   02  // Numero do Pedido de Venda
#DEFINE  ITEM_PED   03  // Item do Pedido
#DEFINE  NUM_NFDV   04  // nUMERO QUANDO HOUVER DEVOLUCAO
#DEFINE  PREF_DV    05  // Serie  quando houver devolucao
#DEFINE  ICMS       06  // Porcentagem do ICMS
#DEFINE  QTD_PRO    07  // Peso/Quantidade do Produto
#DEFINE  PRE_UNI    08  // Preco Unitario de Venda
#DEFINE  QTD_SEGUN  09  // Peso/Quantidade do Produto
#DEFINE  PRE_UNI2   10  // Preco Unitario de Venda
#DEFINE  PRE_TAB    11  // Preco Unitario de Tabela
#DEFINE  NUMLOTE    12  // Preco Unitario de Venda
#DEFINE  DTVLOTE    13  // Preco Unitario de Tabel
#DEFINE  IPI        14  // Porcentagem do IPI
#DEFINE  VAL_IPI    15  // Valor do IPI
#DEFINE  DESC       16  // Desconto por Item
#DEFINE  VAL_MERC   17  // Valor da Mercadoria
#DEFINE  TES        18  // TES
#DEFINE  CF         19  // Classificacao quanto natureza da Operacao
#DEFINE  ICM_PROD   20  // ICMS do Produto
#DEFINE  UNID_PRO   21  //
#DEFINE  DESCRICAO  22  //
#DEFINE  COD_TRIB   23  // Subs(SB1->B1_ORIGEM,1,1))
#DEFINE  ISS        24  // Aliquota de ISS
#DEFINE  TIPO_PRO   25
#DEFINE  LUCRO      26
#DEFINE  POSIPI     27  // Posição fiscal em Relação ao IPI
#DEFINE  CLAS_FIS   28  // Classificação fiscal do Item  
#DEFINE  CTLLOTE    29  // Controle de Lote Dipromed
#DEFINE  CCLASSPRO  30  // CLASSE DO PRODUTO /NBM
#DEFINE  COMIS1     31  // COMISSAO 1

#DEFINE  ICMSOL     20  // Base do ICMS Solidario
#DEFINE  VAL_DESC   17  // Valor do Desconto

*----------------------------------------------*
*      " Posições do array aPed "              *
*----------------------------------------------*
#DEFINE  PEDIDO     01  // Codigo do Pedido
#DEFINE  VEND1      02  // Codigo do Vendedor 1
#DEFINE  VEND2      03  // Codigo do Vendedor 2
#DEFINE  VEND3      04  // Codigo do Vendedor 3
#DEFINE  VEND4      05  // Codigo do Vendedor 4
#DEFINE  VEND5      06  // Codigo do Vendedor 5
#DEFINE  DESC1      07  // Desconto Global 1
#DEFINE  DESC2      08  // Desconto Global 2
#DEFINE  DESC3      09  // Desconto Global 3
#DEFINE  DESC4      10  // Desconto Global 4
*----------------------------------------------*
*       " Posições do array aParc_Dup "        *
*----------------------------------------------*
#DEFINE  PARCELA    01  // Parcela do Titulo 
#DEFINE  VENCIMENTO 02  // Data de Vencimento
#DEFINE  VALOR      03  // Valor do Titulo
*----------------------------------------------*
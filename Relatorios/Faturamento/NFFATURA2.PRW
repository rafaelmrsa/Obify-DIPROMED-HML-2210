/*
---------------------------------------------------------------------------------------

Empresa.......: DIPOMED Comércio e Importação Ltda.
Programa......: NF2FATURA.PRW
Objetivo......: Emissao de Notas Fiscais de Entrada e Saida
Autor.........: Rodrigo Franco   º Data ³  29/10/01
Data..........: 29 Out 2001
Versão........: 1.0

---------------------------------------------------------------------------------------
Re-Estruturado:

Auto..........: Jailton B Santos (JBS), Analista de Sistemas.
Data..........: 20 Jul 2005
Versão........: 2.0

---------------------------------------------------------------------------------------
*/
#INCLUDE "RWMAKE.CH"
#INCLUDE "NFFATURA.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "AP5MAIL.CH"
*---------------------------------------------*
User Function NF2FATURA()
*---------------------------------------------*
Local oDlg               // JBS 07/07/2005
Local nOpcao      := 0   // JBS 07/07/2005
Local bOK         := {|| if(NfaValid("FORM"),(nOpcao := 1, oDlg:End()),)} // JBS 07/07/2005
Local bCancel     := {|| nOpcao := 0, oDlg:End()}    // JBS 07/07/2005
Local nReImpressao:= 0   // JBS 11/07/2005
Local nPos        := 0   // JBS 11/07/2005
Local cUser		  := U_DipUsr()
Private cDesc1    := PADC("Este programa ira emitir a Nota Fiscal de Entrada/Saida",74)
Private cDesc2    := ""
Private cDesc3    := ""
Private cNatureza := ""
Private CbTxt     := ""
Private CbCont    := ""
Private aReturn   := { "Especial", 1,"Administracao", 1, 3, 1,"",1 }
Private titulo    := PADC("Nota Fiscal - DIPROMED",74)
Private nomeprog  := "NFFATURA"
Private wnrel     := "NFFATURA"

//Private cPerg     := "DIPRNF" //"NFSIGW"
// FPADR(cPerg, cArq, cCampo, cTipo)  - Para ajustar o tamanho das perguntas no SX1- uso generico
PRIVATE cPerg  	:= U_FPADR( "DIPRNF","SX1","SX1->X1_GRUPO"," " ) //Função criada por Sandro em 19/11/09.

Private tamanho   := "G"
Private nTamNf    := 72
Private limite    := 220
Private nLastKey  := 0
Private Ordem     := 0
Private Alfa      := 0
Private nLin      := 0
Private Z         := 0
Private M         := 0
Private lContinua := .T.
Private nIt       := 1
Private nPag      := 0
Private nPagatu   := 0
Private nContLot  := 0
Private nPagLot   := 0
Private nMv_NfForm:= val(GetMV("MV_NFFORM")) 	     // JBS 07/07/2005 - Nro do ultimo form impresso
Private cNfFormI  := Space((len(SF2->F2_NFFORM)-1)/2)// JBS 07/07/2005
Private cNfFormF  := Space((len(SF2->F2_NFFORM)-1)/2)// JBS 07/07/2005
Private cNFInicial             // JBS 07/07/2005
Private cNFFinal               // JBS 07/07/2005
Private cSerieNF               // JBS 07/07/2005
Private aNfsJaImp := {}        // JBS 08/07/2005
Private lInverte  := .F.       // JBS 08/07/2005
Private cMarca    := GetMark() // JBS 08/07/2005
Private aHeader   := {}        // JBS 08/07/2005
Private aCampos                // JBS 08/07/2005
Private cFileWork              // JBS 08/07/2005
Private lReimpressao := .F.    // JBS 15/07/2005
//----------------------------------------------
// xFilial das Tabelas usadas na Impressão
//----------------------------------------------
Private cFilSA1:=SA1->(xFilial("SA1"))
Private cFilSA2:=SA2->(xFilial("SA2"))
Private cFilSA3:=SA3->(xFilial("SA3"))
Private cFilSA4:=SA4->(xFilial("SA4"))
Private cFilSB1:=SB1->(xFilial("SB1"))
Private cFilSC5:=SC5->(xFilial("SC5"))
Private cFilSC6:=SC6->(xFilial("SC6"))
Private cFilSD1:=SD1->(xFilial("SD1"))
Private cFilSD2:=SD2->(xFilial("SD2"))
Private cFilSE1:=SE1->(xFilial("SE1"))
Private cFilSE4:=SE4->(xFilial("SE4"))
Private cFilSF1:=SF1->(xFilial("SF1"))
Private cFilSF2:=SF2->(xFilial("SF2"))
Private cFilSF3:=SF3->(xFilial("SF3"))
Private cFilSF4:=SF4->(xFilial("SF4"))
Private cPageClasFisc:= ""  // Classificação fiscal impressa na Pagina.
Private aUsuario:={}
cErroIntegridade:='Relação de inconsistencias no ajuste de notas fiscais'+chr(13)+chr(10)
cErroIntegridade+='-----------------------------------------------------'+chr(13)+chr(10)
cErroIntegridade+='                                                     '+chr(13)+chr(10)
MemoWrite('CORRECAO.TXT',cErroIntegridade)   

Alert("Rotina desabilitada, utilize a impressão de DANFE")
Return()

U_DIPPROC(ProcName(0),cUser) // JBS 05/10/2005 - Gravando o nome do Programa no SZU

PswOrder(2)     
If PswSeek(cUser,.T.)
	aUsuario := PswRet()
EndIf

// Variaveis utilizadas para parametros
// MV_PAR01             // Da Nota Fiscal
// MV_PAR02             // Ate a Nota Fiscal
// MV_PAR03             // Da Serie
// MV_PAR04             // Nota Fiscal de Entrada/Saida

// Verifica as perguntas selecionadas, busca o padrao da NFDIP03           ¦

SX1->(AjustaSX1(cPerg)) // Verifica se existe o Pergunte, senão o cria.

If Pergunte(cPerg,.T.) // Pergunta no SX1
	cString:="SF2"
	// JBS 07/07/2005 - Inicio
 
	MV_PAR01    := Padr(MV_PAR01,9) // MCVN - 17/11/2009
	MV_PAR02    := Padr(MV_PAR02,9) // MCVN - 17/11/2009
	cNFInicial  := MV_PAR01 // MCVN - 17/11/2009
	cNFFinal    := MV_PAR02 // MCVN - 17/11/2009
	cSerieNF    := MV_PAR03                     
	
	lReimpressao:= .f.
	//NfaChkNF()  // JBS 08/07/2005 - Checagem se existem notas no intervalo já impressas.
	
	Do While NfaChkNF()
		If !lReimpressao
			Define msDialog oDlg Title "Emissão de Nota Fiscal" From 10,10 TO 22,54
			
			// Radio de Opções de Movimentos do Inventario
			
			@ 011,002 to 091,174
			@ 065,002 to 091,174
			
			@ 020,010 say "Nota Fiscal Inicial"
			@ 032,010 say "Nota Fiscal Final"
			@ 044,010 say "Serie NF"
			
			@ 020,080 Get cNFInicial when .f. Size 40,08
			@ 032,080 Get cNFFinal   when .f. Size 40,08
			@ 044,080 Get cSerieNF   when .f. Size 20,08
			
			@ 075,010 say "Nro do Formulario"
			@ 075,080 Get cNfFormI   when .T. Size 40,08  //valid !Empty(cNfFormI)
			
			Activate Dialog oDlg Centered on init EnchoiceBar(oDlg,bOk,bCancel)
		EndIf
		Do Case
			Case nOpcao == 1 .or. lReimpressao
				//¦ Envia controle para a funcao SETPRINT                        ¦
				wnrel := SetPrint(cString,wnrel,cPerg,Titulo,cDesc1,cDesc2,cDesc3,.T.)
				If nLastKey == 27
					exit
				EndIf
				
				// Verifica Posicao do Formulario na Impressora                 ¦
				SetDefault(aReturn,cString)
				If nLastKey == 27
					exit
				EndIf
				
				// Inicio do Processamento da Nota Fiscal                       ¦
				RptStatus({|| RptDetail()})
				
				If !lReimpressao
					NFImpOK() // Verifica resultado da impressão com o usuario
				EndIf
		EndCase
		Exit
	Enddo
EndIf
Return

*---------------------------------------------------*
Static Function RptDetail()
*---------------------------------------------------*
Local nPrecoUni    := 0
Local nQtdPro      := 0
Local nPreUni2     := 0
Local nQtdSegun    := 0
Local nPicm        := 0
Local nIpi         := 0
Local nVlMerc      := 0
Local nAlicISS     := 0

Private aDetalhePed:= {} // Itens da Nota FiscaPrivate aPed        := {} //
Private aClasItem  := {} // Classificação dos itens por Posição de IPI
Private aParc_Dup  := {} // Titulos de Cobrança
Private aPed_cli   := {} //

//----------------------------------
// Inicializa  regua de impressao                            ¦
//----------------------------------
SetRegua(Val(mv_par02)-Val(mv_par01))
//
nReImpressao := Ascan(aNfsJaImp,{|x| x[4] == "REIMP"  }) // Se Existir ReImpressao não deixa fazer outra coisa.
nCanceladas  := Ascan(aNfsJaImp,{|x| x[4] == "CANCELA"}) // Se Existir Cancelamento e ReImpressao não deixa fazer outra coisa.
//--------------------------------------------------------------
// Define todas as ordens as serem usadadas durante a Impressão
//--------------------------------------------------------------
SA1->(DbSetOrder(1))
SA2->(DbSetOrder(1))
SA4->(dbSetOrder(1))
SB1->(DbSetOrder(1))
SD1->(dbSetOrder(1))
SD2->(dbSetOrder(3))
SE1->(dbSetOrder(1))
SE4->(dbSetOrder(1))
SF1->(dbSetOrder(1))
SF2->(dbSetOrder(1))
SF3->(dbSetOrder(4))
SF4->(DbSetOrder(1))
//----------------------------------------
// Determina a Impressão das Notas Fiscais
//----------------------------------------
If len(aNfsJaImp)>0                       

    // Inicializa e Configura a impressora      

    @ 00,00 psay chr(27)+"@" //	Limapa a Impressora
    @ 00,00 psay chr(27)+'0' // Define espaçamento de 1/8"
    @ 00,00 psay Chr(27)+'M'+Chr(15) // Comprime a letra da nota
    @ 00,00 psay Chr(27)+'C'+Chr(68) // Tamanho da pagina 68 linha
	For nReg:=1 to len(aNfsJaImp)
		If nReImpressao > 0 .and. !aNfsJaImp[nReg,OPERACAO] == "REIMP" // Para re-impressao, pula as outras notas.
			loop
		EndIf
		If aNfsJaImp[nReg,OPERACAO] == "IMPRESSA" // Notas com formulario e que não foram marcadas para nada
			loop
		EndIf
		If aNfsJaImp[nReg,TIPO] == "Saida" // Faz as notas de Saida
			
			SF2->(dbGoTo(aNfsJaImp[nReg][REGISTRO]))
			
			//If SF2->(dbSeek(cFilSF2+aNfsJaImp[nReg,NR_DOC]+aNfsJaImp[nReg,SERIE])) // Posiciona na Capa da Nota.
			
			If SD2->(dbSeek(cFilSD2+SF2->F2_DOC+SF2->F2_SERIE)) // Posiciona os detalhes da Nota.
				nLinIni:=nLin                         // Linha Inicial da Impressao
				
				//¦ Inicio de Levantamento dos Dados da Nota Fiscal              ¦
				// * Cabecalho da Nota Fiscal
				xLocExp      := SF2->F2_LOCEXP          // Localizacao na expedicao
				xNUM_NF      := SF2->F2_DOC             // Numero
				xSERIE       := SF2->F2_SERIE           // Serie
				xEMISSAO     := SF2->F2_EMISSAO         // Data de Emissao
				xTOT_FAT     := SF2->F2_VALBRUT         // Valor Total da Fatura
				xTOT_FAT     := If(xTOT_FAT==0,SF2->F2_VALMERC+SF2->F2_VALIPI+SF2->F2_SEGURO+SF2->F2_FRETE+SF2->F2_DESPESA,xTOT_FAT)
				xLOJA        := SF2->F2_LOJA            // Loja do Cliente
				xFRETE       := SF2->F2_FRETE           // Frete
				xDESPESA     := SF2->F2_DESPESA         // Despesa
				xSEGURO      := SF2->F2_SEGURO          // Seguro
				xBASE_ICMS   := SF2->F2_BASEICM         // Base   do ICMS
				xBASE_IPI    := SF2->F2_BASEIPI         // Base   do IPI
				xVALOR_ICMS  := SF2->F2_VALICM          // Valor  do ICMS
				xICMS_RET    := SF2->F2_ICMSRET         // Valor  do ICMS Retido
				xVALOR_IPI   := SF2->F2_VALIPI          // Valor  do IPI
				xVALOR_MERC  := SF2->F2_VALMERC         // Valor  da Mercadoria
				xNUM_DUPLIC  := SF2->F2_DUPL            // Numero da Duplicata
				xCond_Pag    := SF2->F2_COND            // Condicao de Pagamento
				xTipo        := SF2->F2_TIPO            // Tipo do Cliente
				xESPECIE     := SF2->F2_ESPECI1         // Especie 1 no Pedido
				xVOLUME      := SF2->F2_VOLUME1         // Volume 1 no Pedido
				xPESO_BRUTO  := SF2->F2_PBRUTO          // Peso Bruto
				xPESO_LIQUID := SF2->F2_PLIQUI          // Peso Liquido
				xTOT_FAT    := If(xTipo== "I",0,xTot_Fat)
				xVALOR_MERC := If(xTipo== "I",0,xValor_Merc)
				//-----------------------------------------------
				//   Registra o numero de Impressões da nota
				//-----------------------------------------------
				SF2->(RECLOCK("SF2",.F.))
				SF2->F2_QTDIMP  := SF2->F2_QTDIMP + 1
				SF2->F2_HORANOT := Iif(Empty(SF2->F2_HORANOT),TIME(),SF2->F2_HORANOT)
				SF2->(MSUNLOCK("SF2"))
				
				xQtdImp    := SF2->F2_QTDIMP    // Quantidade de vezes impressa
				nContLot   := 0                 // Quantidade de lotes
				nPagLot    := 0                 //
				cPedAtu    := SD2->D2_PEDIDO    //
				cItemAtu   := SD2->D2_ITEMPV    //
				//----------------------------------------
				//  Inicializa as Arrays para Impressão
				//----------------------------------------
				aDetalhePed:= {} // Detalhes do Pedido
				aPed       := {} // Dados do Vendedor
				aClasItem  := {} // Tabela de Classificação dos Itens
				aPED_CLI   := {} // Numero de Pedido
				aParc_dup  := {} // Titulo de Cobrança - Parcela, Vencimento e Valor xPARC_DUP, xVENC_DUP, xVALOR_DUP
				//---------------------------------------------
				// Posiciona Tabela de Clientes e Fornecedores
				//---------------------------------------------
				SA1->(DbSeek(cFilSA1+SF2->F2_CLIENTE+SF2->F2_LOJA))
				SA2->(dbSeek(cFilSA2+SF2->F2_CLIENTE+SF2->F2_LOJA))
				//--------------------------------------------------------
				// Monta a array aDetalhePed com os itens da Nota Fiscal
				//--------------------------------------------------------
				Do While SD2->(!eof()) .and. cFilSD2 == SD2->D2_FILIAL .and. SD2->D2_DOC==xNUM_NF .and. SD2->D2_SERIE==xSERIE
					//
					// Só permite notas com numero de Serie Informado pelo usuario
					//
					If SD2->D2_SERIE #mv_par03
						SD2->(DbSkip())
						Loop
					EndIf
					
					nPrecoUni := 0
					nQtdPro   := 0
					//
					// Monta array aPed com Pedido, Descrição e Desconto do Item
					//
					If SC6->(DbSeek(cFilSC6+Alltrim(SD2->D2_PEDIDO)+Alltrim(SD2->D2_ITEMPV)))
						If SC6->C6_VALINF > 0
							
							nQtdPro   := SD2->D2_QUANT
							nPrecoUni := If(xTipo == "I",0,SC6->C6_VALINF)
							
							If SA1->A1_DIFEREN == "E" .OR. SA1->A1_DIFEREN == "T"
								nQtdPro   := SD2->D2_QTSEGUM
								nPrecoUni:= If(xTipo == "I",0,SC6->C6_VALINF / (SD2->D2_QTSEGUM/SD2->D2_QUANT))
							EndIf
						EndIf
						AADD(aPED_CLI,{SD2->D2_PEDIDO, SC6->C6_DESCRI, SC6->C6_VALDESC})
					EndIf
					//
					// Posiciona a Tabela de Produtos
					//
					SB1->(DbSeek(cFilSB1+SD2->D2_COD))
					cUniB1  := If(SA1->A1_DIFEREN $ "ET",SB1->B1_SEGUM,SB1->B1_UM)
					cDescB1 := If(SA1->A1_DIFEREN == "E",SB1->B1_DESC2,SB1->B1_DESC)
					cCodTrib:= Subs(SB1->B1_ORIGEM,1,1)
					nAliqISS:= Iif(SB1->B1_ALIQISS > 0,0,SB1->B1_ALIQISS)
					cPosIpi := SB1->B1_POSIPI
				
					nPreUni2 := If(xTipo=="I",0,SD2->D2_PRCVEN)
					nQtdSegun:= SD2->D2_QTSEGUM
					If SA1->A1_DIFEREN == "E" .OR. SA1->A1_DIFEREN == "T"
						nPreUni2 := Iif(xTipo == "I",0,SD2->D2_PRCVEN / (SD2->D2_QTSEGUM/SD2->D2_QUANT))
					Else
						nQtdSegun:= SD2->D2_QUANT
					EndIf
					nPrecoUni := Iif(nPrecoUni=0,nPreUni2,nPreUni)
					nQtdPro   := Iif(nQtdPro  =0,nQtdSegun,nQtdPro)
					
					nPicm   := Iif(Empty(SD2->D2_PICM),0,SD2->D2_PICM)
					nIpi    := Iif(Empty(SD2->D2_IPI) ,0,SD2->D2_IPI)
					nVlMerc := Iif(xTipo== "I"        ,0,SD2->D2_TOTAL)
					nAlicISS:= Iif(SB1->B1_ALIQISS>0  ,0,SB1->B1_ALIQISS)
					//
					// Monta a array aDetalhePed com o dados item que serão impressos
					//
					AADD(aDetalhePed,{;
					SD2->D2_COD      ,;     // COD_PRO    01
					SD2->D2_PEDIDO   ,;     // PED_VEND   02
					SD2->D2_ITEMPV   ,;     // ITEM_PED   03
					SD2->D2_NFORI    ,;     // NUM_NFDV   04
					SD2->D2_SERIORI  ,;     // PREF_DV    05
					nPicm            ,;     // ICMS       06
					nQtdPro          ,;     // QTD_PRO    07
					nPrecoUni        ,;     // PRE_UNI    08
					nQtdSegun        ,;     // QTD_SEGUN  09
					nPreUni2         ,;     // PRE_UNI2   10
					SD2->D2_PRUNIT   ,;     // PRE_TAB    11
					SD2->D2_LOTECTL  ,;     // NUMLOTE    12
					SD2->D2_DTVALID  ,;     // DTVLOTE    13
					nIpi             ,;     // IPI        14
					SD2->D2_VALIPI   ,;     // VAL_IPI    15
					SD2->D2_DESC     ,;     // DESC       16
					nVlMerc          ,;     // VAL_MERC   17
					SD2->D2_TES      ,;     // TES        18
					SD2->D2_CF       ,;     // CF         19
					nPicm            ,;     // ICM_PROD   20
					cUniB1           ,;     // UNID_PRO   21
					cDescB1          ,;     // DESCRICAO  22
					cCodTrib         ,;     // COD_TRIB   23
					nAlicISS         ,;     // ISS        24
					SB1->B1_TIPO     ,;     // TIPO_PRO   25
					SB1->B1_PICMRET  ,;     // LUCRO      26
					cPosIpi          ,;     // POSIPI     27
					cPosIpi        })     // CLAS_FIS   28
					//
					//  Posiciona na Capa do Pedido para Montar a array aPed
					//
					If SC5->(DbSeek(cFilSC5+SD2->D2_PEDIDO))
						If ASCAN(aPed,{|x| x[1] == SD2->D2_PEDIDO})==0
							
							aadd(aPed,{;
							SD2->D2_PEDIDO  ,;              // Codigo do Pedido
							SC5->C5_VEND1   ,;              // Codigo do Vendedor 1
							SC5->C5_VEND2   ,;              // Codigo do Vendedor 2
							SC5->C5_VEND3   ,;              // Codigo do Vendedor 3
							SC5->C5_VEND4   ,;              // Codigo do Vendedor 4
							SC5->C5_VEND5   ,;              // Codigo do Vendedor 5
							SC5->C5_DESC1   ,;              // Desconto Global 1
							SC5->C5_DESC2   ,;              // Desconto Global 2
							SC5->C5_DESC3   ,;              // Desconto Global 3
							SC5->C5_DESC4   ,;              // Desconto Global 4
							NFVend(SC5->C5_VEND1) ,;        // Nome do Vendedor 1
							NFVend(SC5->C5_VEND2) ,;        // Nome do Vendedor 2
							NFVend(SC5->C5_VEND3)})         // Nome do Vendedor 3
							
							xCLIENTE    :=SC5->C5_CLIENTE   // Codigo do Cliente
							xTipo_CLI   :=SC5->C5_TIPOCLI   // Tipo de Cliente
							xCOD_MENS   :=SC5->C5_MENPAD    // Codigo da Mensagem Padrao
							xMENSAGEM   :=SC5->C5_MENNOTA   // Mensagem para a Nota Fiscal
							xTPFRETE    :=SC5->C5_TPFRETE   // Tipo de Entrega
							xPEDSC5     :=SC5->C5_NUM       //
							xCONDPAG    :=SC5->C5_CONDPAG   // Condicao de Pagamento
							xENT_END    :=SC5->C5_ENDENT    // Endereco de Entrega
							xENT_BAI    :=SC5->C5_BAIRROE   // Bairro de Entrega
							xENT_CEP    :=SC5->C5_CEPE      // CEP ENTREGA
							xENT_MUN    :=SC5->C5_MUNE      // Municipio de Entrega
							xENT_EST    :=SC5->C5_ESTE      // Estado de Entrega
						EndIf
					EndIf
					//*--------------------------------------------*
					//          Condição de Pagamento
					//*--------------------------------------------*
					SE4->(dbSeek(cFilSE4+xCond_Pag))
					cDesc_pag := SE4->E4_DESCRI
					
					Iif(!Empty(SD2->D2_LOTECTL),nContLot++,)
					
					SD2->(Dbskip())
				EndDo
				//--------------------------------------------
				// Colhe os dados do Cliente ou do Fornecedor
				//--------------------------------------------
				If xTipo $ 'NCPISTO'
					xCOD_CLI :=SA1->A1_COD             // Codigo do Cliente
					xNOME_CLI:=SA1->A1_NOME            // Nome
					xEND_CLI :=SA1->A1_END             // Endereco
					xBAIRRO  :=SA1->A1_BAIRRO          // Bairro
					xCEP_CLI :=SA1->A1_CEP             // CEP
					xMUN_CLI :=SA1->A1_MUN             // Municipio
					xEST_CLI :=SA1->A1_EST             // Estado
					xCOB_CLI :=SA1->A1_ENDCOB          // Endereco de Cobranca
					xCOB_BAI :=SA1->A1_BAIRROC	       // Bairro de Cobranca
					xCOB_CEP :=SA1->A1_CEPC            // Cep de Cobranca
					xCOB_MUN :=SA1->A1_MUNC            // Municipio de Cobranca
					xCOB_EST :=SA1->A1_ESTC   	       // Estado de Cobranca
					//xENT_END :=SA1->A1_ENDENT        // Endereco de Entrega
					//xENT_BAI :=SA1->A1_BAIRROE       // Bairro de Cobranca
					//xENT_CEP :=SA1->A1_CEPE          // CEP ENTREGA
					//xENT_MUN :=SA1->A1_MUNE          // Municipio de Cobranca
					//xENT_EST :=SA1->A1_ESTE   	   // Estado de Cobranca
					xCGC_CLI :=SA1->A1_CGC             // CGC
					xINSC_CLI:=SA1->A1_INSCR           // Inscricao estadual
					xTRAN_CLI:=SA1->A1_TRANSP          // Transportadora
					xTEL_CLI :=SA1->A1_TEL             // Telefone
					xFAX_CLI :=SA1->A1_FAX             // Fax
					xSUFRAMA :=SA1->A1_SUFRAMA         // Codigo Suframa
					xCALCSUF :=SA1->A1_CALCSUF         // Calcula Suframa
					//----------------------------------------
					//    Alteracao p/ Calculo de Suframa
					//----------------------------------------
					If !empty(xSUFRAMA) .and. xCALCSUF =="S"
						If xTipo == 'D' .OR. xTipo == 'B'
							zFranca := .F.
						else
							zFranca := .T.
						EndIf
					Else
						zfranca:= .F.
					EndIf
				Else
					zFranca:=.F.
					xCOD_CLI :=SA2->A2_COD             // Codigo do Fornecedor
					xNOME_CLI:=SA2->A2_NOME            // Nome Fornecedor
					xEND_CLI :=SA2->A2_END             // Endereco
					xBAIRRO  :=SA2->A2_BAIRRO          // Bairro
					xCEP_CLI :=SA2->A2_CEP             // CEP
					xCOB_CLI :=""                      // Endereco de Cobranca
					xCOB_BAI :=""             		   // Bairro de Cobranca
					xCOB_MUN :=""                      // Municipio de Cobranca
					xCOB_EST :=""          			   // Estado de Cobranca
					xCOB_CEP :=""                      // Cep de Cobranca
					xREC_CLI :=""                      // Endereco de Entrega
					xMUN_CLI :=SA2->A2_MUN             // Municipio
					xEST_CLI :=SA2->A2_EST             // Estado
					xCGC_CLI :=SA2->A2_CGC             // CGC
					xINSC_CLI:=SA2->A2_INSCR           // Inscricao estadual
					xTRAN_CLI:=SA2->A2_TRANSP          // Transportadora
					xTEL_CLI :=subs(SA2->A2_TEL,1,28)  // Telefone
					xFAX_CLI :=SA2->A2_FAX             // Fax
					xENT_END :=""                      // Endereco de Entrega
					xENT_BAI :=""                      // Bairro de Entrega
					xENT_CEP :=""                      // CEP ENTREGA
					xENT_MUN :=""                      // Municipio de Entrega
					xENT_EST :=""                      // Estado de Entrega
				EndIf
				
				xBsIcmRet:=0
				
				If xIcms_Ret >0                          // Apenas se ICMS Retido > 0
					If SF3->(dbSeek(cFilSF3+SA1->A1_COD+SA1->A1_LOJA+SF2->F2_DOC+SF2->F2_SERIE))
						xBsIcmRet := SF3->F3_VALOBSE
					EndIf
				EndIf
			EndIf
			
		ElseIf aNfsJaImp[nReg,TIPO] == "Entrada"
			
			SF1->(dbGoTo(aNfsJaImp[nReg][REGISTRO]))
			If SD1->(dbSeek(cFilSD1+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA)) // Posiciona os detalhes da Nota.
				nLinIni:=nLin   // Linha Inicial da Impressao
				//-------------------------------------
				//  Cabecalho da Nota Fiscal Entrada
				//-------------------------------------
				xPESO_BRUTO := SF1->F1_PESOB     // Peso bruto da Nota Fiscal
				xPESO_LIQUID:= SF1->F1_PESOL     // Peso liquido da Nota Fiscal
				xLocExp     :=''                 //
				xNUM_NF     := SF1->F1_DOC       // Numero
				xSERIE      := SF1->F1_SERIE     // Serie
				xEMISSAO    := SF1->F1_EMISSAO   // Data de Emissao
				xTOT_FAT    := SF1->F1_VALBRUT   // Valor Bruto da Compra
				xLOJA       := SF1->F1_LOJA      // Loja do Cliente
				xFRETE      := SF1->F1_FRETE     // Frete
				xDESPESA    := SF1->F1_DESPESA   // Despesa
				xSEGURO     := SF1->F1_SEGURO    // Seguro
				xBASE_ICMS  := SF1->F1_BASEICM   // Base   do ICMS
				xBASE_IPI   := SF1->F1_BASEIPI   // Base   do IPI
				xVALOR_ICMS := SF1->F1_VALICM    // Valor  do ICMS
				xICMS_RET   := SF1->F1_ICMSRET   // Valor  do ICMS Retido
				xVALOR_IPI  := SF1->F1_VALIPI    // Valor  do IPI
				xVALOR_MERC := SF1->F1_VALMERC   // Valor  da Mercadoria
				xNUM_DUPLIC := SF1->F1_DUPL      // Numero da Duplicata
				xCOND_PAG   := SF1->F1_COND      // Condicao de Pagamento
				xTipo       := SF1->F1_TIPO      // Tipo do Cliente
				
				xFornece    := SF1->F1_FORNECE   // Cliente/Fornecedor
				xBSICMRET   := SF1->F1_BRICMS    // Base do ICMS Retido
				xNFORI      := SF1->F1_NFORI     // NF Original
				xPREF_DV    := SF1->F1_SERIORI   // Serie Original

				// Nas entradas usamos só o nome do usuário que digitou a NFE
				xUsuario := SF1->F1_USUARIO
				
				nContLot    := 0                 // Quantidade de lotes
				nPagLot     := 0                 //
				cPedAtu     := SD1->D1_PEDIDO    //
				cItemAtu    := SD1->D1_ITEMPC    //
				//----------------------------------------
				//  Inicializa as Arrays para Impressão
				//----------------------------------------
				aDetalhePed:= {} // Detalhes do Pedido
				aPed       := {} // Dados do Vendedor
				aClasItem  := {} // Tabela de Classificação dos Itens
				aPED_CLI   := {} // Numero de Pedido
				aParc_dup  := {} // Titulo de Cobrança - Parcela, Vencimento e Valor xPARC_DUP, xVENC_DUP, xVALOR_DUP
				
				//---------------------------------------------
				// Posiciona Tabela de Clientes e Fornecedores
				//---------------------------------------------
				SA1->(DbSeek(cFilSA1+SF1->F1_FORNECE+SF1->F1_LOJA))
				SA2->(dbSeek(cFilSA2+SF1->F1_FORNECE+SF1->F1_LOJA))
				
				If SF1->F1_TIPO $ "DB"
					xCOD_CLI :=SA1->A1_COD             // Codigo do Cliente
					xNOME_CLI:=SA1->A1_NOME            // Nome
					xEND_CLI :=SA1->A1_END             // Endereco
					xBAIRRO  :=SA1->A1_BAIRRO          // Bairro
					xCEP_CLI :=SA1->A1_CEP             // CEP
					xREC_CLI :=SA1->A1_ENDENT          // Endereco de Entrega
					xMUN_CLI :=SA1->A1_MUN             // Municipio
					xEST_CLI :=SA1->A1_EST             // Estado
					xCOB_CLI :=SA1->A1_ENDCOB          // Endereco de Cobranca
					xCOB_BAI :=SA1->A1_BAIRROC	       // Bairro de Cobranca
					xCOB_CEP :=SA1->A1_CEPC            // Cep de Cobranca
					xCOB_MUN :=SA1->A1_MUNC            // Municipio de Cobranca
					xCOB_EST :=SA1->A1_ESTC   	       // Estado de Cobranca
					xCGC_CLI :=SA1->A1_CGC             // CGC
					xINSC_CLI:=SA1->A1_INSCR           // Inscricao estadual
					xTRAN_CLI:=SA1->A1_TRANSP          // Transportadora
					xTEL_CLI :=SA1->A1_TEL             // Telefone
					xFAX_CLI :=SA1->A1_FAX             // Fax
					xENT_END :=SA1->A1_ENDENT          // Endereco de Entrega
					xENT_BAI :=SA1->A1_BAIRROE         // Bairro de Cobranca
					xENT_CEP :=SA1->A1_CEPE            // CEP ENTREGA
					xENT_MUN :=SA1->A1_MUNE            // Municipio de Cobranca
					xENT_EST :=SA1->A1_ESTE   	       // Estado de Cobranca
				Else
					xCOD_CLI :=SA2->A2_COD             // Codigo do Cliente
					xNOME_CLI:=SA2->A2_NOME            // Nome
					xEND_CLI :=SA2->A2_END             // Endereco
					xBAIRRO  :=SA2->A2_BAIRRO          // Bairro
					xCEP_CLI :=SA2->A2_CEP             // CEP
					xCOB_CLI :=""                      // Endereco de Cobranca
					xCOB_BAI :=""             		   // Bairro de Cobranca
					xCOB_MUN :=""                      // Municipio de Cobranca
					xCOB_EST :=""           		   // Estado de Cobranca
					xCOB_CEP :=""                      // Cep de Cobranca
					xREC_CLI :=""                      // Endereco de Entrega
					xMUN_CLI :=SA2->A2_MUN             // Municipio
					xEST_CLI :=SA2->A2_EST             // Estado
					xCGC_CLI :=SA2->A2_CGC             // CGC
					xINSC_CLI:=SA2->A2_INSCR           // Inscricao estadual
					xTRAN_CLI:=SA2->A2_TRANSP          // Transportadora
					xTEL_CLI :=subs(SA2->A2_TEL,1,28)  // Telefone
					xFAX     :=SA2->A2_FAX             // Fax
				EndIf
				//--------------------------------------------------------
				// Monta a array aDetalhePed com os itens da Nota Fiscal
				//--------------------------------------------------------
				Do While SD1->(!eof()) .and. cFilSD1 == SD1->D1_FILIAL .and. SD1->D1_DOC==xNUM_NF .and. SD1->D1_SERIE==xSERIE.and.;
					     SD1->D1_FORNECE == SF1->F1_FORNECE .and. SD1->D1_LOJA == SF1->F1_LOJA
					If SD1->D1_SERIE # mv_par03
						SD1->(DbSkip())
						Loop
					EndIf
					
					SB1->(DbSeek(cFilSB1+SD1->D1_COD))
					cUniB1   := SB1->B1_UM
					cDescB1  := SB1->B1_DESC
					cCodTrib := Subs(SB1->B1_ORIGEM,1,1)
					nAliqISS := Iif(SB1->B1_ALIQISS > 0,0,SB1->B1_ALIQISS)
					
					cPosIpi := SB1->B1_POSIPI
					//
					nPreUni2 := 0 //If(xTipo=="I",0,SD2->D2_PRCVEN)
					nQtdSegun:= 0 //SD2->D2_QTSEGUM
					//
					nPicm    := Iif(Empty(SD1->D1_PICM),0,SD1->D1_PICM)
					nIpi     := Iif(Empty(SD1->D1_IPI) ,0,SD1->D1_IPI)
					nVlMerc  := Iif(xTipo== "I"        ,0,SD1->D1_TOTAL)
					nAlicISS := Iif(SB1->B1_ALIQISS>0  ,0,SB1->B1_ALIQISS)
					//
					AADD(aDetalhePed,{;
					SD1->D1_COD      ,;     // COD_PRO
					SD1->D1_PEDIDO   ,;     // PED_VEND
					SD1->D1_ITEMPC   ,;     // ITEM_PED
					SD1->D1_NFORI    ,;     // NUM_NFDV
					SD1->D1_SERIORI  ,;     // PREF_DV
					nPicm            ,;     // ICMS
					Iif(xEst_Cli='EX',SD1->D1_QTSEGUM,SD1->D1_QUANT),;   // QTD_PRO
					SD1->D1_VUNIT    ,;     // PRE_UNI
					nQtdSegun        ,;     // QTD_SEGUN
					nPreUni2         ,;     // PRE_UNI2
					SD1->D1_VUNIT    ,;     // PRE_TAB
					SD1->D1_LOTECTL  ,;     // NUMLOTE
					SD1->D1_DTVALID  ,;     // DTVLOTE
					nIpi             ,;     // IPI
					SD1->D1_VALIPI   ,;     // VAL_IPI
					SD1->D1_DESC     ,;     // DESC
					SD1->D1_TOTAL    ,;     // VAL_MERC
					SD1->D1_TES      ,;     // TES
					SD1->D1_CF       ,;     // CF
					nPicm            ,;     // ICM_PROD
					cUniB1           ,;     // UNID_PRO
					cDescB1          ,;     // DESCRICAO
					cCodTrib         ,;     // COD_TRIB
					nAlicISS         ,;     // ISS
					SB1->B1_TIPO     ,;     // TIPO_PRO
					SB1->B1_PICMRET  ,;     // LUCRO
					cPosIpi          ,;     // POSIPI
					cPosIpi          })     // CLAS_FIS
					
					//*--------------------------------------------*
					//          Condição de Pagamento
					//*--------------------------------------------*
					SE4->(dbSeek(cFilSE4+xCOND_PAG))
					cDesc_pag := SE4->E4_DESCRI
					
					Iif(!Empty(SD1->D1_LOTECTL),nContLot++,)
					SD1->(Dbskip())
				EndDo
			EndIf 
			// JBS 15/12/2005 - Retidas as declarações abaido de entro do If do SD1
			xTPFRETE     :=SF1->F1_FRETEPO         // Tipo de Frete
			xPEDSC5      :=" "
			xQTDIMP      :=0
			xVOLUME      :=SF1->F1_VOLUMES         // Volume
			xESPECIE     :=SF1->F1_ESPEMB          // Especie
			xCOD_MENS    :=SF1->F1_MENPAD          // Codigo da Mensagem
			xMENSAGEM    :=SF1->F1_OBS
		EndIf
		//-----------------------------------------
		//      Registro da Transportadora
		//-----------------------------------------
		cTransp := Iif(aNfsJaImp[nReg,TIPO]=="Entrada",SF1->F1_TRANSP,SF2->F2_TRANSP)
		SA4->(dbSeek(cFilSA4+cTransp))                               
		xCOD_TRANSP  :=SA4->A4_COD            // Código Transportadora		
		xNOME_TRANSP :=SA4->A4_NOME           // Nome Transportadora
		xEND_TRANSP  :=SA4->A4_END            // Endereco
		xBAI_TRANSP  :="" // SA4->A4_BAIRRO		  // Bairro
		xCEP_TRANSP  :=SA4->A4_CEP            // Cep
		xMUN_TRANSP  :=SA4->A4_MUN            // Municipio
		xEST_TRANSP  :=SA4->A4_EST            // Estado
		xVIA_TRANSP  :=SA4->A4_VIA            // Via de Transporte
		xCGC_TRANSP  :=SA4->A4_CGC            // CGC
		xTEL_TRANSP  :=SA4->A4_TEL            // Fone
		xINS_TRANSP  :=SA4->A4_INSEST         // Incricao Estadual
		//-------------------------------------------
		//  Monta Array com o Titulos Financeiros
		//-------------------------------------------
		lDuplicatas := .T.
		aParc_dup   :={}  // Parcela, Vencimento e Valor xPARC_DUP, xVENC_DUP, xVALOR_DUP]
		If SE1->(dbSeek(cFilSE1+xSerie+xNum_duplic,.T.)) // Flag p/Impressao de Duplicatas
			Do while SE1->(!eof()) .and. cFilSE1         == SE1->E1_FILIAL .and.;
			                             SE1->E1_NUM     == xNum_Duplic .and.;
			                             SE1->E1_PREFIXO == xSerie
				If aNfsJaImp[nReg,TIPO] == "Saida" .and. !("NF" $ SE1->E1_TIPO)
					SE1->(dbSkip())
					Loop
				EndIf
				AADD(aParc_Dup,{SE1->E1_PARCELA,SE1->E1_VENCTO,SE1->E1_VALOR})
				lDuplicatas := .T.
				SE1->(dbSkip())
			EndDo
		EndIf
		//-----------------------------------------------------
		//    Define a Natura da Nota e a Operação Fiscal
		//-----------------------------------------------------
		If SF4->(dbSeek(cFilSF4+aDetalhePed[1][TES])) // Posicionando a TES correta
			
			xCFO      := AllTrim(aDetalhePed[1][CF])
			xNATUREZA := AllTrim(SF4->F4_TEXTO)              // Natureza da Operacao
			xTXTLEGA  := AllTrim(SF4->F4_TXTLEGA)
			
			aDetalhePed[1][COD_TRIB] += SF4->F4_SITTRIB    // Acrescentamos a parte do TES
			
			For I:=2 to Len(aDetalhePed)
				
				SF4->(dbSeek(cFilSF4+aDetalhePed[i][TES]))
				aDetalhePed[i][COD_TRIB] += SF4->F4_SITTRIB    // Acrescentamos a parte do TES
				
				If !(AllTrim(SF4->F4_TXTLEGA) $ xTXTLEGA)
					If Len(AllTrim(xTXTLEGA))<>0 .and. Len(AllTrim(SF4->F4_TXTLEGA))<>0
						xTXTLEGA += ' / '
					EndIf
					xTXTLEGA += AllTrim(SF4->F4_TXTLEGA)
				EndIf
				
				If !(AllTrim(aDetalhePed[i][CF]) $ xCFO)
					If Len(AllTrim(xCFO))<>0 .and. Len(aDetalhePed[i][CF])<>0
						xCFO += ' / '
					EndIf
					xCFO += AllTrim(aDetalhePed[i][CF])
				EndIf
				
				If !(AllTrim(SF4->F4_TEXTO) $ xNATUREZA)
					If Len(AllTrim(xNATUREZA))<>0 .and. Len(AllTrim(SF4->F4_TEXTO))<>0
						xNATUREZA += ' / '
					EndIf
					xNATUREZA += AllTrim(SF4->F4_TEXTO)
				EndIf
				
			Next
		Else
			xCFO      := ""
			xNATUREZA := ""
			xTXTLEGA  := ""
		EndIf
		//-----------------------------------------
		//         Funções de Impressão
		//-----------------------------------------
		_Cabeca(nReg)
		nFormAtual := cNfFormf
		_Corpo(nReg)
		_Pe(nReg)
		//-----------------------------------------
		//     Terminou a impressão da Nota
		//-----------------------------------------
		IncRegua()
		nLin:=0
		If aNfsJaImp[nReg,TIPO] == "Saida"
			//----------------------------------------------------------
			// Registro do Numero do Formulario na Nota Fisc de Saida
			//----------------------------------------------------------
			SF2->(RecLock("SF2",.F.))
			If aNfsJaImp[nReg,OPERACAO] == "CANCELA"  
				SF2->F2_NFFORMC:= AllTrim(SF2->F2_NFFORM)+If(len(AllTrim(SF2->F2_NFFORMC))>0,", ","")+AllTrim(SF2->F2_NFFORMC)
				//
				// Lança o formulario cancelado no historico Kardex.
				//
				U_DiprKardex(cPedAtu,U_DipUsr(),"Form "+AllTrim(SF2->F2_NFFORM)+" NF "+Alltrim(SF2->F2_DOC),.T.,"23")
				//
				// Registra o novo formulario da nota fiscal
				//
				SF2->F2_NFFORM := nFormAtual+"/"+cNfFormf
				SetMv("MV_NFFORM",cNfFormf)
				//
				// Registra o formulario atual no Historico Kardex
				//
				U_DiprKardex(cPedAtu,U_DipUsr(),"NF "+Alltrim(SF2->F2_DOC)+" Form "+nFormAtual+"/"+cNfFormf,.T.,"22")
				
			ElseIf aNfsJaImp[nReg,OPERACAO] == "*"
				//
				// Registra o Formulario da nota fiscal
				//
				SF2->F2_NFFORM := nFormAtual+"/"+cNfFormf
				SetMv("MV_NFFORM",cNfFormf)
				//
				// Registra o formulario atual no Historico Kardex
				//
				U_DiprKardex(cPedAtu,U_DipUsr(),"NF "+Alltrim(SF2->F2_DOC)+" Form "+nFormAtual+"/"+cNfFormf,.T.,"21")
			EndIf
			SF2->(MsUnlock("SF2"))
		ElseIf aNfsJaImp[nReg,TIPO] == "Entrada"
			//----------------------------------------------------------
			// Registro do Numero do Formulario na Nota Fisc de Entrada
			//----------------------------------------------------------
			SF1->(RecLock("SF1",.F.))
			If aNfsJaImp[nReg,OPERACAO] == "CANCELA"
				SF1->F1_NFFORMC:= AllTrim(SF1->F1_NFFORM)+If(len(AllTrim(SF1->F1_NFFORMC))>0,", ","")+AllTrim(SF1->F1_NFFORMC)
				SF1->F1_NFFORM := nFormAtual+"/"+cNfFormf
				SetMv("MV_NFFORM",cNfFormf)
			ElseIf aNfsJaImp[nReg,OPERACAO] == "*"
				SF1->F1_NFFORM := nFormAtual+"/"+cNfFormf
				SetMv("MV_NFFORM",cNfFormf)
			EndIf
			SF1->(MsUnlock("SF1"))
		EndIf
	Next
	//-------------------------------------
	//     Restaura o indice das Tabelas
	//-------------------------------------
	SF2->(Retindex("SF2"))
	SF2->(Retindex("SF1"))
	SD2->(Retindex("SD2"))
	SD1->(Retindex("SD1"))
	
	Set Device To Screen
	
	If aReturn[5] == 1
		Set Printer TO
		dbcommitAll()
		ourspool(wnrel)
	EndIf
EndIf
MS_FLUSH()
*-------------------------------------------*
Static Function _CABECA(nReg)
// Impressao do cabecalho da NF
*-------------------------------------------*
Local cVarAux := ''
Local aDadosAdicionais := {}
Local aColunas := {{67,78,92},{108,120,134},{151,160,175},{191,200,220}}
Local id  := 1
Local nLi := 01 // linha Inicial
Local cDipFormula := FORMULA(xCod_Mens) 
Local cMenFinanc  := GetMV("MV_MSGFINA")
Local cMsgSuframa := ""   
Local cDadosAdicionais := ""
//------------------------------------------
// Endereço de Entrega
//------------------------------------------
If (xTipo=='N'.and.aNfsJaImp[nReg,TIPO]=="Saida").or.(xTipo $ 'BD'.and.aNfsJaImp[nReg,TIPO]=="Entrada")
	aadd(aDadosAdicionais, "ENDERECO DE ENTREGA:")
	aadd(aDadosAdicionais, AllTrim(xEnt_End))
	aadd(aDadosAdicionais, AllTrim(xEnt_Bai))
	aadd(aDadosAdicionais, AllTrim(xEnt_Mun)+" - "+AllTrim(xEnt_Est)+" - CEP " + Transform(xEnt_Cep,"@R 99999-999"))
EndIf
//------------------------------------------
//Impressao Mensagem Padrao da Nota Fiscal
//------------------------------------------
If !Empty(cDipFormula) 
	aadd(aDadosAdicionais, " ")
EndIf
Do While !Empty(cDipFormula) 
   cVarAux := UPPER(SUBSTR(cDipFormula,1,60))                                               
   aadd(aDadosAdicionais,cVarAux)
   If len(cDipFormula) > 60
      cDipFormula := right(cDipFormula,len(cDipFormula)-60) 
   else 
      cDipFormula := ""
   EndIf   
EndDo      
//------------------------------------------
// Impressao Mensagem no Campo Observacao
//------------------------------------------
If !Empty(xMensagem) 
	aadd(aDadosAdicionais, " ")
EndIf
Do While !Empty(xMensagem) 
   cVarAux := UPPER(SUBSTR(xMensagem,1,60))                                               
   aadd(aDadosAdicionais,cVarAux)
   If len(xMensagem) > 60
      xMensagem := right(xMensagem,len(xMensagem)-60) 
   else 
      xMensagem := ""
   EndIf   
EndDo      
//------------------------------------------
// Impressao Texto Legal 
//------------------------------------------
If !Empty(xTxtLega) 
	aadd(aDadosAdicionais, " ")
EndIf
Do While !Empty(xTxtLega) 
   cVarAux := UPPER(SUBSTR(xTxtLega,1,60))                                               
   aadd(aDadosAdicionais,cVarAux)
   If len(xTXTLEGA) > 60
      xTxtLega := right(xTxtLega,len(xTxtLega)-60) 
   else 
      xTxtLega := ""
   EndIf   
EndDo      

//------------------------------------------------------------------------------------------------------------
//Impressao Mensagem do financeiro (Atraso com justificativa do não recebimento de boleto)  MCVN - 29/06/2007
//------------------------------------------------------------------------------------------------------------
cDadosAdicionais := ""
For i:=1 to Len(aDadosAdicionais)
	cDadosAdicionais := cDadosAdiccionais + " " + aDadosAdicionais[i]                      
Next i                

If aNfsjaimp[nReg,TIPO] == "Saida" .And. lDuplicatas .And. Len(aParc_Dup) > 0  .And. !("C/C" $ cDadosAdicionais)
   
	If !Empty(cMenFinanc)  
		aadd(aDadosAdicionais, " ")
	EndIf
	Do While !Empty(cMenFinanc) 
	    cVarAux := UPPER(SUBSTR(cMenFinanc,1,60))                                               
	    aadd(aDadosAdicionais,cVarAux)
   		If len(cMenFinanc) > 60
          cMenFinanc := right(cMenFinanc,len(cMenFinanc)-60) 
	    else 
    	  cMenFinanc := ""
   		EndIf   
	EndDo                                                  

Endif

//------------------------------------------------------------------------------------
//Impressao Mensagem referente ao Desconto - SUFRAMA  MCVN - 02/07/2007
//------------------------------------------------------------------------------------

If xTipo $ 'NCPISTO' .And. aNfsjaimp[nReg,TIPO] == "Saida"
	If !Empty(xSUFRAMA)                                   
	cMsgSuframa := "SUFRAMA N. " + xSuframa
		If xTipo <> 'D' .OR. xTipo <> 'B'
			aadd(aDadosAdicionais, " ")
			aadd(aDadosAdicionais,cMsgSuframa)
    	Endif
	Endif
Endif



cPageClasFisc := ""

nLi := 01

If len(aDadosAdicionais) > 0
    @ nLi, 03 psay aDadosAdicionais[1]  
EndIf
nLi++
If len(aDadosAdicionais) > 1
    @ nLi, 03 psay aDadosAdicionais[2]  
EndIf
nLi++
If len(aDadosAdicionais) > 2
    @ nLi, 03 psay aDadosAdicionais[3]  
EndIf
@ nLi, 212 psay xNum_NF // Numero da Nota Fiscal
nLi++
If len(aDadosAdicionais) > 3
    @ nLi, 03 psay aDadosAdicionais[4]  
EndIf
If aNfsJaImp[nReg,TIPO] == "Entrada"
	@ nLi, 186 psay "X"
Else
	@ nLi, 169 psay "X"
EndIf 
nLi++
If len(aDadosAdicionais) > 4
    @ nLi, 03 psay aDadosAdicionais[5]  
EndIf
nLi++
If len(aDadosAdicionais) > 5
    @ nLi, 03 psay aDadosAdicionais[6]
EndIf
nLi++
If len(aDadosAdicionais) > 6
    @ nLi, 03 psay aDadosAdicionais[7]  
EndIf
nLi++
If len(aDadosAdicionais) > 7
    @ nLi, 03 psay aDadosAdicionais[8]  
EndIf
nLi++
If len(aDadosAdicionais) > 8
    @ nLi, 03 psay aDadosAdicionais[9]  
EndIf
nLi++
If len(aDadosAdicionais) > 9
    @ nLi, 03 psay aDadosAdicionais[10]  
EndIf

@ nLi,067 psay xNatureza   // Texto da Natureza de Operacao
@ nLi,117 psay xCFO 

nLi++
If len(aDadosAdicionais) > 10
    @ nLi, 03 psay aDadosAdicionais[11]  
EndIf

nLi++
If len(aDadosAdicionais) > 11
    @ nLi, 03 psay aDadosAdicionais[12]  
EndIf

nLi++
If len(aDadosAdicionais) > 12
    @ nLi, 03 psay aDadosAdicionais[13]  
EndIf
If aNfsjaimp[nReg,TIPO] == "Saida"
	@ nli, 067 psay alltrim(xcliente)+'-'+alltrim(xnome_cli)  // Codigo e nome do cliente
Else
	@ nli, 067 psay alltrim(xFornece)+'-'+alltrim(xnome_cli)  // Codigo e nome do cliente
EndIf
If !Empty(xcgc_cli)         // Se o c.g.c. do cli/forn nao for vazio
    if len(alltrim(xcgc_cli)) = 14 
	    @ nli, 167 psay xcgc_cli picture "@r 99.999.999/9999-99"  // CNPJ
	else
	    @ nli, 167 psay xcgc_cli picture "@r 999.999.999-99" // cpf
	endif
Else
	@ nli, 167 psay " "    // caso seja vazio
EndIf

@ nli, 210 psay xEmissao   // Data da Emissao do Documento
nLi++
If len(aDadosAdicionais) > 13
    @ nLi, 03 psay aDadosAdicionais[14]  
EndIf
nLi++
If len(aDadosAdicionais) > 14
    @ nLi, 03 psay aDadosAdicionais[15]  
EndIf
@ nLi, 067 psay xEnd_cli   // Endereco
@ nLi, 152 psay xBairro    // Bairro
@ nLi, 184 psay xCep_cli Picture "@R 99999-999"          // CEP
nLi++

If len(aDadosAdicionais) > 15
    @ nLi, 03 psay aDadosAdicionais[16]  
EndIf
nLi++

If len(aDadosAdicionais) > 16
    @ nLi, 03 psay aDadosAdicionais[17]  
EndIf
@ nLi, 067 psay xMun_cli   // Municipio
@ nLi, 133 psay xTel_cli   // Telefone/FAX
@ nLi, 159 psay xEst_cli   // U.F.

If aNfsjaimp[nReg,TIPO] == "Saida"
	@ nLi, 167 psay xInsc_cli // Insc. Estadual
EndIf                                          
nLi++

If len(aDadosAdicionais) > 17
    @ nLi, 03 psay aDadosAdicionais[18]  
EndIf
nLi++

If len(aDadosAdicionais) > 18
    @ nLi, 03 psay aDadosAdicionais[19]  
EndIf
nLi++

If len(aDadosAdicionais) > 19
    @ nLi, 03 psay aDadosAdicionais[20]  
EndIf
nLi++

If len(aDadosAdicionais) > 20
    @ nLi, 03 psay aDadosAdicionais[21]  
EndIf                                  
nLi++ 

@ nLi, 03 psay xLocExp Picture "@E 999" // Local na expedução

nLi++
If aNfsjaimp[nReg,TIPO] == "Saida" 
    @ nLi, 011 psay xPedSC5
	@ nLi, 033 psay aPed[1][VEND1]+'-'+aPed[1][11]  // Vendedor
Else
    @ nLi, 033 psay xUsuario
EndIf
//----------------------------------------
//     Impressao da Fatura/Duplicata
//----------------------------------------

If aNfsJaImp[nReg,TIPO] == "Saida"
	If lDuplicatas.and.Len(aParc_Dup) > 0
		Do While iD < 5
			IF len(aParc_Dup)>Id-1
				@ nLi, aColunas[id][1] psay xNum_Duplic+aParc_Dup[id][PARCELA]
				IF id = 1.and. aParc_Dup[id][VENCIMENTO] == xEmissao
					@ nLi, aColunas[id][2] psay "A VISTA"
				Else
					@ nLi, aColunas[id][2] psay aParc_Dup[iD][VENCIMENTO]
				EndIf
				@ nLi, aColunas[id][3] psay aParc_Dup[id][VALOR] Picture("@E 9,999,999.99")
			EndIf
			id++
			
		EndDo
	EndIf
EndIf
nLi++  // 25
nLi++  // 26
nLi++  // 27

//------------------------------------------------
//     Icrementa o numero do formulario
//------------------------------------------------
If aNfsJaImp[nReg,OPERACAO] $ "CANCELA *"
	cNfFormf := strzero(val(cNfFormF)+1,6)	// JBS 08/07/2005 - Incrementa o Nro do Form Final
EndIf
Return
*-------------------------------------------------*
Static Function _Corpo(nReg)
// Impressao de Linhas de Detalhe da Nota Fiscal
*-------------------------------------------------*
Local _lPeCabeca := .T.  // quando T imprimindo Pe e Cabeca fora do FOR
Local nLi := 28  // Linha inicial do corpo da nota fiscal
Local cDescProd  // Var aux para descrição do produto 
nIt := 1
nPagatu  := 0

nTamDet := 20 // Tamanho da Area de Detalhe
nPag := (Len(aDetalhePed)) / nTamDet

If int(nPag) <> nPag
	nPag := nPag + 1
EndIf

nPag := int(nPag)

xB_ICMS_SOL:=0          // Base  do ICMS Solidario
xV_ICMS_SOL:=0          // Valor do ICMS Solidario

EE := 1
Do While nIt <= (Len(aDetalhePed))
	
	If xTipo <> 'C' // se nota de complemento de preco nao imprime itens
		For I:=EE to nTamDet
			If nIt <= Len(aDetalhePed) 
			
			    cDescProd := aDetalhePed[nIt][DESCRICAO]
			    
			    If !EMPTY(aDetalhePed[nIt][NUMLOTE])                                                 
			        cDescProd += "    Lote: " + aDetalhePed[nIt][NUMLOTE] 
			        cDescProd += " Validade: " + DtoC(aDetalhePed[nIt][DTVLOTE]) 
			    EndIf                                                                                     
				
				@ nLi, 003 psay Alltrim(aDetalhePed[nIt][COD_PRO])
				@ nLi, 013 psay cDescProd
				@ nLi, 124 psay aDetalhePed[nIt][CF]
				@ nLi, 131 psay aDetalhePed[nIt][CLAS_FIS]
				@ nLi, 147 psay aDetalhePed[nIt][COD_TRIB]
				@ nLi, 155 psay aDetalhePed[nIt][UNID_PRO]
				@ nLi, 163 psay aDetalhePed[nIt][QTD_PRO]  Picture "@E 999,999"
				If aNfsJaImp[nReg,TIPO] == "Entrada".and. xEst_Cli = 'EX' // quando é nota de importacao
					@ nLi, 171 psay aDetalhePed[nIt][VAL_MERC]/aDetalhePed[nIt][QTD_PRO] Picture "@E 99,999,999.9999"
				Else
					@ nLi, 171 psay aDetalhePed[nIt][PRE_UNI]  Picture "@E 99,999,999.9999"
				EndIf
				@ nLi, 188 psay aDetalhePed[nIt][VAL_MERC]  Picture "@E 99,999,999.99"
				@ nLi, 205 psay aDetalhePed[nIt][ICM_PROD]  Picture "99"
				@ nLi, 213 psay aDetalhePed[nIt][IPI]       Picture "99"
				@ nLi, 219 psay aDetalhePed[nIt][VAL_IPI]   Picture "@E 9,999,999.99"
				//
				nIt := nIt + 1
			EndIf
			nLi++
		Next
	Else
		nIt := (Len(aDetalhePed))+1
	EndIf	// se nota de complemento de preco nao imprime itens
	
	If nIt > Len(aDetalhePed)
		Return
	Else
		If _lPeCabeca
			_Pe(nReg)
			_Cabeca(nReg)
			EE := 1
		Else
			_lPeCabeca := .T.
			EE := 2
		EndIf
		nLi := 28
	EndIf
end

Return

*------------------------------------------------------*
Static Function _Pe(nReg)
// Impressao Rodape quando nao for ultima nota
*------------------------------------------------------*
Local nLi := 51
IF ++nPagatu = nPag
	@ nLi, 012  psay xBASE_ICMS  Picture "@E@Z 99,999,999.99"  // Valor do ICMS
	@ nLi, 035  psay xVALOR_ICMS Picture "@E@Z 99,999,999.99"  // Valor do ICMS
	@ nLi, 073  psay xBSICMRET   Picture "@E@Z 99,999,999.99"  // Base ICMS Ret.
	@ nLi, 100  psay xICMS_RET   Picture "@E@Z 99,999,999.99"  // Valor  ICMS Ret.
	@ nLi, 130  psay xVALOR_MERC Picture "@E@Z 99,999,999.99"  // Valor Tot. Prod.
	nLi++
	nLi++
	@ nLi, 012  psay xFRETE      Picture "@E@Z 99,999,999.99"  // Valor do Frete
	@ nLi, 035  psay xSEGURO     Picture "@E@Z 99,999,999.99"  // Valor Seguro
	@ nLi, 073  psay xDESPESA    Picture "@E@Z 99,999,999.99"  // Valor Despesa
	@ nLi, 100  psay xVALOR_IPI  Picture "@E@Z 99,999,999.99"  // Valor do IPI
	@ nLi, 130  psay xTOT_FAT    Picture "@E   99,999,999.99"  // Valor Total NF
	//--------------------------------------------------
	//    Impressao dos Dados da Transportadora
	//--------------------------------------------------
	
	nLi := 56
	
//	@ nLi, 003 psay xNOME_TRANSP  // Nome da Transport.
	@ nLi, 003 psay xCOD_TRANSP+" - "+xNOME_TRANSP  // Nome da Transport.
	If xTPFRETE=='C' .OR. xTPFRETE=='N' .OR. xTPFRETE=='R' .OR. xTPFRETE=='I'  // Frete por conta do
		@ nLi, 095 psay "1" // Emitente (1)
	ElseIf xTPFRETE=='F'   //     ou
		@ nLi, 095 psay "2" // Destinatario (2)
	EndIf 
	If !EMPTY(xCGC_TRANSP) // Se C.G.C. Transportador nao for Vazio
		@ nLi, 127 psay xCGC_TRANSP Picture"@R 99.999.999/9999-99"
	Else
		@ nLi, 127 psay " " // Caso seja vazio
	EndIf
	IF aNfsJaImp[nReg,TIPO] == "Saida" //mv_par04 == 2
		xEND_TRANSP := Alltrim(xEND_TRANSP)+" - "+Alltrim(xBAI_TRANSP)+" - "+Alltrim(xCEP_TRANSP)
	EndIf 
	nli := 58
	@ nli, 003 psay Substr(xEND_TRANSP,1,55) // Endereco Transp.
	@ nli, 081 psay xMun_Transp  // Municipio
	@ nli, 117 psay xEst_Transp  // U.F.
	@ nli, 123 psay xIns_Transp  // Insc. Estad.
    nLi := 60
	If xVolume > 0
		@ nLi, 003 psay xVOLUME  Picture"@E@Z 999,999.99" // Quant. Volumes
	EndIf
	@ nli, 026 psay xESPECIE Picture"@!"  // Especie
	@ nLi, 048 psay " "  // Res para Marca
	@ nLi, 082 psay " "  // Res para Numero
	@ nLi, 102 psay xPESO_BRUTO     Picture"@E@Z 99,999,999.999" // Res para Peso Bruto
	@ nLi, 134 psay xPESO_LIQUID    Picture"@E@Z 99,999,999.999" // Res para Peso Liquido
Else
	@ nLi, 012  psay "XXXXXXXXXXXXX"  // Valor do ICMS
	@ nLi, 035  psay "XXXXXXXXXXXXX"  // Valor do ICMS
	@ nLi, 073  psay "XXXXXXXXXXXXX"  // Base ICMS Ret.
	@ nLi, 100  psay "XXXXXXXXXXXXX"  // Valor  ICMS Ret.
	@ nLi, 130  psay "XXXXXXXXXXXXX"  // Valor Tot. Prod.
	nLi++
	nLi++
	@ nLi, 012  psay "XXXXXXXXXXXXX"  // Valor do Frete
	@ nLi, 035  psay "XXXXXXXXXXXXX"  // Valor Seguro
	@ nLi, 073  psay "XXXXXXXXXXXXX"  // Valor Despesas
	@ nLi, 100  psay "XXXXXXXXXXXXX"  // Valor do IPI
	@ nLi, 130  psay "XXXXXXXXXXXXX"  // Valor Total NF
	//--------------------------------------------------
	//    Impressao dos Dados da Transportadora
	//--------------------------------------------------
    nLi := 56
    
//	@ nLi, 003 psay xNOME_TRANSP // Nome da Transport.
	@ nLi, 003 psay xCOD_TRANSP+" - "+xNOME_TRANSP  // Nome da Transport.
	If xTPFRETE=='C' .OR. xTPFRETE=='N' .OR. xTPFRETE=='R' .OR. xTPFRETE=='I'  // Frete por conta do
		@ nLi, 095 psay "1" // Emitente (1)
	ElseIf xTPFRETE=='F'   //     ou
		@ nLi, 095 psay "2" // Destinatario (2)
	EndIf
	If !EMPTY(xCGC_TRANSP) // Se C.G.C. Transportador nao for Vazio
		@ nLi, 127 psay xCGC_TRANSP Picture "@R 99.999.999/9999-99"
	Else
		@ nLi, 127 psay " " // Caso seja vazio
	EndIf
	xEND_TRANSP := Alltrim(xEND_TRANSP)+" - "+Alltrim(xBAI_TRANSP)+" - "+Alltrim(xCEP_TRANSP)
    nLi := 58
	@ nLi, 003 psay Substr(xEND_TRANSP,1,55) // Endereco Transp.
	@ nLi, 081 psay xMUN_TRANSP // Municipio
	@ nLi, 117 psay xEST_TRANSP // U.F.
	@ nLi, 123 psay xINS_TRANSP // Insc. Estad.
	
	nLi := 60
	
	@ nLi, 003 psay "XXXXXX"    // Quant. Volumes
	@ nLi, 102 psay "XXXXXX"    // Res para Peso Bruto
	@ nLi, 134 psay "XXXXXX"    // Res para Peso Liquido
	
EndIf

nLi := 65

@ nLi, 210 psay xNUM_NF  // Numero da Nota Fiscal
@ nLi, 228 psay alltrim(str(nPagatu))+"/"+alltrim(str(nPag))

nLi := 66
@ nLi, 000 psay "-"
Return
*---------------------------------------------*
Static Function NfaValid(cCampo)
// JBS 07/07/2005 - Rotina de Validações
*---------------------------------------------*
Local lRetorno := .T.

Do Case
	Case cCampo == "FORM"
		nReImpressao := Ascan(aNfsJaImp,{|x| x[4] == "REIMP"}) // Se Existir ReImpressao não deixa fazer outra coisa.
		If nReImpressao > 0
			lRetorno := .T.
		ElseIf val(cNfFormI) # nMv_NfForm+1
			msginfo(;
			"O Numero do Formulario informado não" +f_linha+;
			"Corresponde  ao numero    sequencial"+f_linha+;
			"Do ultimo Formulario Impresso.      "+f_linha+f_linha+;
			"Por Favor, verifique no formulario e"+f_linha+;
			"Informe o numero correto.          ","Atenção")
			lRetorno := .F.
		Else
			cNfFormf := strzero(val(cNfFormI)-1,6) // JBS 08/07/2005 - Decrementa o Nro do Form Final em 1
		EndIf
		
Endcase
Return(lRetorno)

*---------------------------------------------*
Static Function NfaChkNF()
// JBS 08/07/2005 - Relaciona NFs já impressas
*---------------------------------------------*
Local oDlg                                     // JBS 08/07/2005
Local nOpcao    := 0                           // JBS 08/07/2005
Local bOK       := {|| nOpcao := 1, oDlg:End()}// JBS 08/07/2005
Local bCancel   := {|| nOpcao := 0, oDlg:End()}// JBS 08/07/2005
Local lRetorno  := .T.
Local lMarcados := .F.

Private aCposSF := {}

lReimpressao    := .F.

AADD(ACPOSSF,{"WKFLAG"    ,,""                   })
AADD(ACPOSSF,{"F1_DOC"    ,,AVSX3("F1_DOC"    ,5)})
AADD(ACPOSSF,{"F1_SERIE"  ,,AVSX3("F1_SERIE"  ,5)})
AADD(ACPOSSF,{"WKTIPO"    ,,"Tipo de NF"         })
AADD(ACPOSSF,{"F1_NFFORM" ,,AVSX3("F1_NFFORM" ,5)})
AADD(ACPOSSF,{"F1_NFFORMC",,AVSX3("F1_NFFORMC",5)})


Processa({|| NFFatSaida()},"Filtrando notas de Saida")
Processa({|| NFFatEntrada()},"Filtrando notas de Entrada")

If len(aNfsJaImp)>0
	//-----------------------------------------------------------
	//  Coloca as Nota de Entrada e Saida em ordem crescente.
	//-----------------------------------------------------------
	aSort(aNfsJaImp,,,{ |x,y| x[1] < y[1] } )
	
	lInverte := .F.
	cMarca   := GetMark()
	aHeader  := {}
	
	aCampos  := {} //Array(SF1->(FCount()))
	cFileWork:= E_CriaTrab(,{;
	{"WKFLAG"   , "C" ,2,0},;
	{"F1_DOC"    , "C" ,avsx3("F1_DOC"    ,3),0},;
	{"F1_SERIE"  , "C" ,avsx3("F1_SERIE"  ,3),0},;
	{"F1_NFFORM" , "C" ,avsx3("F1_NFFORM" ,3),0},;
	{"F1_NFFORMC", "C" ,avsx3("F1_NFFORMC",3),0},;
	{"WKTIPO"    , "C" ,7,0},;
	{"WKPOS"     , "N" ,5,0}},"Work_NF",)
	
	IndRegua("Work_NF",cFileWork,"F1_DOC+F1_SERIE")
	cNFOutrasI:= ""
	cNFOutrasF:= ""
	For x=1 to len(aNfsJaImp)
		If aNfsJaImp[x,OPERACAO] == "IMPRESSA"
			Work_NF->(DbAppend())
			Work_NF->F1_DOC     := aNfsJaImp[x,1]
			Work_NF->F1_SERIE	:= aNfsJaImp[x,2]
			Work_NF->F1_NFFORM  := aNfsJaImp[x,3]
			Work_NF->F1_NFFORMC := aNfsJaImp[x,5]
			Work_NF->WKFLAG     := Space(02)
			Work_NF->WKPOS      := X
			Work_NF->WKTIPO     := aNfsJaImp[x,6]
		Else
			If Empty(cNFOutrasI)
				cNFOutrasI:=aNfsJaImp[x,1]
			EndIf
			cNFOutrasF := aNfsJaImp[x,1]
		EndIf
	Next
	
	Do While !Work_NF->(Bof().and.Eof())
		Work_NF->(DbGoTop())
		
		Define msDialog oDlg Title "Intervalo solicitado: "+MV_PAR01+" a "+MV_PAR02 From 10,10 TO 44,85
		@ 31,02 to 61,295
		
		@ 048,005 BUTTON "&Reimpressão da Nota Fiscal em Papel Comum"                 SIZE 200,15 ACTION (nOpcao:=2,oDlg:End())
		@ 068,005 BUTTON "&Cancela Formulario e Re-imprime a Nota Fiscal em outro"    SIZE 200,15 ACTION (nOpcao:=3,oDlg:End())
		
		@ 035,210 say "ATENÇÃO: Com excessão da Re- impressão de notas em papel comum, as notas fiscais no intervalo de "+MV_PAR01+" a "+MV_PAR02+" também serão impressas, embora não estejam relacionadas na tela." size 85,60 COLOR CLR_RED
		
		oMark:=MsSelect():New("Work_NF","WKFLAG",,aCposSF,lInverte,@cMarca,{92,01,258,297})
		
		Activate Dialog oDlg Centered on init EnchoiceBar(oDlg,bOk,bCancel)
		
		
		Do Case
			Case nOpcao==0
				lRetorno := .F.
				lReimpressao := .F.
				Exit
				
			Case nOpcao==1
				Exit
			Case nOpcao==2 .or. nOpcao==3
				Work_NF->(DbGoTop())
				Do While Work_NF->(!EOF())
					If Work_NF->WKFLAG # Space(02)
						aNfsJaImp[Work_NF->WKPOS,OPERACAO]:=Iif(nOpcao==2,"REIMP","CANCELA")
						lReimpressao := nOpcao==2
						lMarcados := .T.
					EndIf
					Work_NF->(DbSkip())
				EndDo
				If !lMarcados
					msginfo(;
					"Nenhuma nota fiscal foi  selecionada  pelo usuario!"+f_linha+f_linha+;
					"Para executar esta operação marque as notas fiscais"+f_linha+;
					"para as quais será executada esta operação!","Atenção")
				Else
					Exit
				EndIf
		EndCase
	EndDo
	Work_NF->(E_EraseArq(cFileWork))
EndIf
Return(lRetorno)

*---------------------------------------------*
Static Function NFFatSaida()
// JBS 14/07/2005 - Relaciona NFs de Saida-SF2
*---------------------------------------------*
Local lRetorno := .F.
Local cNotaImp := "IMPRESSA"

ProcRegua(SF2->(Reccount()))
SF2->(dbSetOrder(1))
SF2->(dbSeek(cFilSF2+mv_par01+mv_par03,.t.))

Do While SF2->(!eof()) .and. cFilSF2 == SF2->F2_FILIAL .and. SF2->F2_DOC <= mv_par02
	
	Incproc("Verificando NF: "+SF2->F2_DOC+"-"+SF2->F2_SERIE )
	
	If SF2->F2_SERIE != mv_par03
		SF2->(DbSkip())
		Loop
	EndIf
	
	cNotaImp := If(!Empty(SF2->F2_NFFORM),"IMPRESSA","*")
	
	aadd(aNfsJaImp, {SF2->F2_DOC,SF2->F2_SERIE, SF2->F2_NFFORM,cNotaImp, SF2->F2_NFFORMC,"Saida",SF2->(Recno())})
	lRetorno := .T.
	
	SF2->(DbSkip())
	
EndDo
Return(lRetorno)

*-----------------------------------------------*
Static Function NFFatEntrada()
// JBS 14/07/2005 - Relaciona NFs de Entrada-SF1
*-----------------------------------------------*
Local lRetorno := .F.
Local cNotaImp := "IMPRESSA"

ProcRegua(SF1->(Reccount()))
SF1->(DbSetOrder(1))
SF1->(dbSeek(cFilSF1+mv_par01+mv_par03,.t.))

Do While SF1->(!eof()) .and. cFilSF1 == SF1->F1_FILIAL .and. SF1->F1_DOC <= mv_par02
	
	Incproc("Verificando NF: "+SF1->F1_DOC+"-"+SF1->F1_SERIE )
	
	If SF1->F1_SERIE != mv_par03
		SF1->(DbSkip())
		Loop
	EndIf
	If SF1->F1_FORMUL # 'S'        // Se nao for formulario proprio
		SF1->(DbSkip())
		Loop
	EndIf
	
	cNotaImp := If(!Empty(SF1->F1_NFFORM),"IMPRESSA","*")
	
	lRetorno := .T.
	AADD(aNfsJaImp, {SF1->F1_DOC,SF1->F1_SERIE, SF1->F1_NFFORM,cNotaImp, SF1->F1_NFFORMC,"Entrada",SF1->(Recno())})
	
	SF1->(DbSkip())
	
EndDo
Return(lRetorno)

*-----------------------------------------------------*
Static Function NFVend(cVendedor)
// Posiciona na tabela de Vendedor e retorna o Nome.
*-----------------------------------------------------*
Local cNomVend := ""
If !empty(cVendedor)
	If SA3->(dbSeek(cFilSA3+cVendedor))
		cNomVend :=SA3->A3_NREDUZ
	EndIf
EndIf
Return(cNomVend)
*-----------------------------------------------------*
Static Function NFImpOK()
// Verifique se hove problema na Impressao das notas
*-----------------------------------------------------*
Local oDlg
Local nOpcao      := 0
Local lRetorno := .t.

Do While .t.
	Define msDialog oDlg Title "Confirmando o Resultado da Impressão" From 10,10 TO 23,61
	
	@ 001,002 to 99,200
	//	@ 065,002 to 091,200
	
	@ 020,010 say "Por favor aguarde a Impressora terminar a impressão."
	@ 030,010 say "Em seguida responda: "
	@ 050,010 say "Todas as notas fiscais foram impressas corretamente?"
	
	
	@ 080,010 BUTTON "&Sucesso na Impressão"   SIZE 88,15 ACTION (oDlg:End())
	@ 080,108 BUTTON "&Problemas na Impressao" SIZE 88,15 ACTION (NFESTORNO(),oDlg:End())
	
	Activate Dialog oDlg Centered  //on init EnchoiceBar(oDlg,bOk,bCancel)
	
	Exit
	
EndDo
Return(lRetorno)
*-----------------------------------------------------*
Static Function NFESTORNO()
// Faz estorno do Numero de formulario de Notas
// E Limpa o numero de formulario das notas
*-----------------------------------------------------*
Local oDlg
Local nOpcao:=0
Local lRetorno:=.T.
Local bOK:= {|| oDlg:End()}
Local lEntradas:=.F.
Local lSaidas:=.F.
Local nEntradas:= 0
Local nSaidas:= 0
Private cUltimaNF:=Space(len(cNFFinal))
Private cUltimoForm:=Space(Len(cNfFormI))
Private cProxFormBom:=Space(Len(cNfFormI))
Private cForm:=""     
Private cErroEmi:="" 

Do While .t.
	nOpcao := 0
	Define msDialog oDlg Title "Estorno de Formulario" From 10,10 TO 22,60
	@ 011,002 to 89,198
	
	@ 030,010 say "Ultima nota fiscal impressa corretamente:"
	@ 048,010 say "Numero da Nota Fiscal "
	@ 060,010 say "Numero do Formulario"
	@ 072,010 say "Numero do Proximo Formulario bom"
	
	@ 048,100 Get cUltimaNF    valid !empty(cUltimaNF)    Size 40,08
	@ 060,100 Get cUltimoForm  valid !empty(cUltimoForm)  Size 40,08
	@ 072,100 Get cProxFormBom valid !empty(cProxFormBom) Size 40,08
	
	Activate Dialog oDlg Centered  on init EnchoiceBar(oDlg,{|| nOpcao:=1,oDlg:End()},{|| nOpcao:=2,oDlg:End()})
	
	do Case
		Case nOpcao = 2
			If MsgYesNo(;
				"Se abortar  esta operação a impressão  de"+f_linha+;
				"notas fiscais ficara comprometida!"+f_linha+f_linha+;
				"Confirma a saida ?","Atencao")
				Exit
			EndIf
		case nOpcao = 1 
			If Empty(cUltimaNF)
				If MsgYesNo(;
					"Numero da nota fiscal não foi preenchido!"+f_linha+;
					"Se abortar  esta operação a impressão  de"+f_linha+;
					"notas fiscais ficara comprometida!"+f_linha+f_linha+;
					"Confirma a saida ?","Atencao")
					Exit
				EndIf
			ElseIf Empty(cUltimoForm)
				If MsgYesNo(;
					"Numero do formulario não foi preenchido!"+f_linha+;
					"Se abortar esta operação a impressão  de"+f_linha+;
					"notas fiscais ficara comprometida!"+f_linha+f_linha+;
					"Confirma a saida ?","Atencao")
					Exit
				EndIf
			ElseIf Val(cUltimoForm)>Val(GetMV("MV_NFFORM"))
				MsgInfo((cErroEmi:=;
				"O numero do formulario informado está maior que o numero do"+f_linha+;
				"ultimo formulario que o sistema processou! "+f_linha+f_linha+;
				"Por favor verifique o numero correto e informe novamente!"),"Atenção")
			ElseIf Val(cProxFormBom)>Val(GetMV("MV_NFFORM"))+1
				MsgInfo((cErroEmi:=;
				"O numero do formulario bom informado está maior que o numero do"+f_linha+;
				"ultimo formulario que o sistema processou! "+f_linha+f_linha+;
				"Por favor verifique o numero correto e informe novamente!"),"Atenção")
			Else
				cForm := ""
				If SF1->(dbSeek(cFilSF1+cUltimaNF+mv_par03))
					cForm := SF1->F1_NFFORM
				ElseIf SF2->(dbSeek(cFilSF2+cUltimaNF+mv_par03))
					cForm := SF2->F2_NFFORM
				Else
					MsgInfo((cErroEmi:=;
					"O numero de nota fiscal informado não foi encontado"+f_linha+;
					"no banco de dados! "+f_linha+f_linha+;
					"Por favor verifique o numero correto e informe novamente!"),"Atenção")
					EnviaEmailNF()
					Loop
				EndIf
				if cUltimoForm <> SubStr(cForm,8,6)
					MsgInfo((cErroEmi:=;
					"O numero do ultimo formulario desta nota fiscal está"+f_linha+;
					"diferente do numero de formulario informado! "+f_linha+f_linha+;
					"Por favor verifique o numero correto e informe novamente!"),"Atenção")
					EnviaEmailNF()
					Loop
				EndIf
				Processa({|| nEntradas:=NFEstEntradas()},"Estorno de Forms NF Entrada")
				Processa({|| nSaidas  :=NFESTSaidas()  },"Estorno de Forms NF Saida")
				If nEntradas+nSaidas > 0
					SetMv("MV_NFFORM",StrZero(val(cProxFormBom)-1,6)) // Registra numero do Form a ser impresso.
					MsgInfo(;
					"Foram estornadas:" + f_linha +f_linha+;
					" - Notas Fiscais Entrada + Saidas.......: " + Transform(nEntradas+nSaidas,"999") + f_linha +;
					" - Notas Fiscais Entrada......................: " + Transform(nEntradas        ,"999") + f_linha +;
					" - Notas Fiscais Saidas........................: " + Transform(+nSaidas         ,"999") + f_linha + f_linha +;
					"Formularios estornados com SUCESSO!","Resumo informativo")
				Else
					MsgInfo("Não encontrou formulario para estornar!","Atenção")
					Loop
				EndIf
				Exit
			EndIf
			EnviaEmailNF()
	EndCase
EndDo
Return(lRetorno)
*-----------------------------------------------------*
Static Function NFEstEntradas()
// Limpa o formulario das notas fiscais de entrada
*-----------------------------------------------------*
Local lRetorno     := .F.
Local nUltiFormGrv := Val(GetMV("MV_NFFORM"))
Local nEntradas    := 0
Local nFFormIni    := 0
Local nFFormFin    := 0

ProcRegua(SF1->(Reccount()))
SF1->(dbSetOrder(1))
SF1->(dbSeek(cFilSF1+cUltimaNF+mv_par03,.t.))

Do While SF1->(!eof()) .and. cFilSF1 == SF1->F1_FILIAL .and. SF1->F1_DOC <= mv_par02
	
	Incproc("Verificando NF: "+SF1->F1_DOC+"-"+SF1->F1_SERIE )
	
	If SF1->F1_SERIE != mv_par03
		SF1->(DbSkip())
		Loop
	EndIf
	
	nFFormIni := val(SubStr(SF1->F1_NFFORM,1,6))
	nFFormFin := Val(SubStr(SF1->F1_NFFORM,8,6))

	If Val(left(SF1->F1_NFFORM,6)) > Val(cUltimoForm).and. nUltiFormGrv > Val(cUltimoForm)
		SF1->(RecLock("SF1",.F.))
		If val(cProxFormBom)>nFFormIni.and.val(cProxFormBom)<=nFFormFin 
	 	   nFFormFin := val(cProxFormBom)-1
		EndIF
		If val(cProxFormBom)>nFFormIni.and.val(cProxFormBom)>nFFormFin
			SF1->F1_NFFORMC:= StrZero(nFFormIni,6)+"/"+StrZero(nFFormFin,6)+;
			                  If(len(AllTrim(SF1->F1_NFFORMC))>0,", ","")  +;
			                  AllTrim(SF1->F1_NFFORMC)
			                  
		EndIf
		SF1->F1_NFFORM := ""
		SF1->(MsUnlock("SF1"))
		nEntradas++
	EndIf
	
	SF1->(DbSkip())
	
EndDo
Return(nEntradas)
*-----------------------------------------------------*
Static Function NFESTSaidas()
// Limpa o formulario das notas fiscais de Saida
*-----------------------------------------------------*
Local nUltiFormGrv := Val(GetMV("MV_NFFORM"))
Local nSaidas := 0
Local nFFormIni := 0
Local nFFormFin := 0

ProcRegua(SF2->(Reccount()))
SF2->(dbSetOrder(1))
SF2->(dbSeek(cFilSF2+cUltimaNF+mv_par03,.t.))

Do While SF2->(!eof()) .and. cFilSF2 == SF2->F2_FILIAL .and. SF2->F2_DOC <= mv_par02
	
	Incproc("Verificando NF: "+SF2->F2_DOC+"-"+SF2->F2_SERIE )
	
	If SF2->F2_SERIE != mv_par03
		SF2->(DbSkip())
		Loop
	EndIf
	
	nFFormIni := val(SubStr(SF2->F2_NFFORM,1,6))
	nFFormFin := Val(SubStr(SF2->F2_NFFORM,8,6))              
	
	If nFFormIni > Val(cUltimoForm).and. nUltiFormGrv > Val(cUltimoForm)
	
		SF2->(RecLock("SF2",.F.))
		If val(cProxFormBom)>nFFormIni.and.val(cProxFormBom)<=nFFormFin 
	 	   nFFormFin := val(cProxFormBom)-1
		EndIF
		If val(cProxFormBom)>nFFormIni.and.val(cProxFormBom)>nFFormFin
			SF2->F2_NFFORMC:= StrZero(nFFormIni,6)+"/"+StrZero(nFFormFin,6)+;
			                  If(len(AllTrim(SF2->F2_NFFORMC))>0,", ","")  +;
                              AllTrim(SF2->F2_NFFORMC)			                  
		EndIf
		SF2->F2_NFFORM := ""
		SF2->(MsUnlock("SF2"))
		nSaidas++
	EndIf
	
	SF2->(DbSkip())
	
EndDo
Return(nSaidas)


*--------------------------------------------------*                       
Static Function AjustaSX1(cPerg)                   
*--------------------------------------------------*
Local aRegs :={}
dbSetOrder(1)

aAdd(aRegs,{cPerg,"01","Da Nota Fiscal    ?","","","mv_ch1","C",09,0,0,"G","","mv_par01","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"02","Ate a Nota Fiscal ?","","","mv_ch2","C",09,0,0,"G","","mv_par02","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"03","Da Serie          ?","","","mv_ch3","C",03,0,0,"G","","mv_par03","","","","","","","","","","","","","",""})

For i:=1 to Len(aRegs)
    If !dbSeek(cPerg+aRegs[i,2])
        RecLock("SX1",.T.)
        For j:=1 to FCount()
            If j <= Len(aRegs[i])
                FieldPut(j,aRegs[i,j])
            Endif
        Next
        MsUnlock("SX1")
    Endif
Next     

Return(.T.)



*------------------------------*                       
Static Function EnviaEmailNF()
*------------------------------*
Local cAccount:=Lower(Alltrim(GetMv('MV_RELACNT')))
Local cFrom:=Lower(Alltrim(GetMv('MV_RELACNT')))
Local cPassword:=alltrim(GetMv('MV_RELPSW'))
Local cServer:=alltrim(GetMv('MV_RELSERV'))
Local lResult:=.F.
Local cError:=''
Local cMsg:=''
Local nTot_Prod:=0
Local nLinArray:=0
Local aLinCor:={"#B0E2FF","#c0c0c0"}  
Local nLinCor:= 1
Local cAssunto:=EncodeUTF8('Problemas na impressão da NF '+cNFInicial+' a '+cNFFinal+' da serie '+ cSerieNF,"cp1252")
LOCAL lSmtpAuth := GetNewPar("MV_RELAUTH",.F.)
LOCAL lAutOk	:= .F.

cErroEmi:=StrTran(cErroEmi,"/13/10"," ")


//--------------------------------------------------------------------------
// Definicao do cabecalho do email                                            
//--------------------------------------------------------------------------
cMsg := '<html>' 
cMsg += '<head>' 
cMsg += '<title>'+cAssunto+'</title>' 
cMsg += '</head>' 
cMsg += '<body>'
cMsg += '<HR Width=100% Size=4 Align=Centered Color=Red>' 
cMsg += '<Table Align=Center BorderColor=#000000 CELLPADDING=4 CELLSPACING=0 Width=100%>' 
//-------------------------------------------------------------------------
// Definicao do cabecalho do relatório 
//-------------------------------------------------------------------------
cMsg += '<table width="100%">' 
cMsg += '  <tr>' 
cMsg += '     <td width="100%"><font size="5" color="red">'+DecodeUTF8(cAssunto, "cp1252")+'</font></td>' 
cMsg += '  </tr>' 
cMsg += '</table> <P>' 
cMsg += '<table width="100%" cellspacing="0" cellpadding="0"><font size="1" color="blue">' 
//-------------------------------------------------------------------------
// Definicao do texto/detalhe do email                                         
//-------------------------------------------------------------------------
cMsg += '<table width="100%" border="3" cellspacing="0" cellpadding="0">'
cMsg += '   <tr>'
cMsg += '      <td width="100%"><font size="3">Ultima nota fiscal impressa corretamente:</font></td>'
cMsg += '   </tr>'
cMsg += '   <tr>'
cMsg += '      <td width="100%" align="left"><font size="3">Numero da Nota Fiscal...........: ' + cUltimaNF + '</font></td>'
cMsg += '   </tr>'
cMsg += '   <tr>'
cMsg += '      <td width="100%" align="left"><font size="3">Numero do Formulario............: ' + cUltimoForm +'</font></td>'
cMsg += '   </tr>'
cMsg += '   <tr>'
cMsg += '      <td width="100%" align="left"><font size="3">Numero do Proximo Formulario bom: ' + cProxFormBom + '</font></td>'
cMsg += '   </tr>'
cMsg += '   <tr>'
cMsg += '      <td width="100%" align="left"><font size="3">Ultimo form Impresso(SX6).......: ' + GetMV("MV_NFFORM") + '</font></td>'
cMsg += '   </tr> <p>'
cMsg += '   <tr>'
cMsg += '      <td width="100%" align="left"><font size="3">Formularo da NF localizado......: ' + cForm + '</font></td>'
cMsg += '   </tr> <p>'
cMsg += '</table>'
cMsg += '<table width="100%" border="3" cellspacing="0" cellpadding="0">'
cMsg += '   <tr>'
cMsg += '      <td width="100%"><font size="3">Mensagem de Erro apresentada ao usuario:</font></td>'
cMsg += '   </tr> <p>'
cMsg += '   <tr>'
cMsg += '      <td width="100%" align="left"><font size="3">' + cErroEmi + '</font></td>'
cMsg += '   </tr>'
cMsg += '</table>'
//-----------------------------------------------------------------------
// Definicao do rodape do email                                               
//-----------------------------------------------------------------------
cMsg += '<HR Width=100% Size=4 Align=Centered Color=Red> <P>' 
cMsg += '    <table width="100%" Align="Center" border="0">' 
cMsg += '       <tr align="center">' 
cMsg += '           <td colspan="10"><font color="BLUE" size="2">Mensagem enviada automaticamente pelo sistema PROTHEUS - <font color="BLUE" size="1">(NFFATURA.PRW)</td>' 
cMsg += '       </tr>' 
cMsg += '    </table>' 
cMsg += '</body>' 
cMsg += '</html>' 
//-------------------------------------------------------------------------------
// Envia o mail para a lista selecionada. Envia como BCC para que a pessoa pense
// que somente ela recebeu aquele email, tornando o email mais personalizado.   
//-------------------------------------------------------------------------------
CONNECT SMTP SERVER cServer ACCOUNT cAccount PASSWORD cPassword RESULT lResult

If !lAutOk
	If ( lSmtpAuth )
		lAutOk := MailAuth(cAccount,cPassword)
	Else
		lAutOk := .T.
	EndIf
EndIf

	//CC  '' //                      ; 
	//BCC 'relatorios@dipromed.com.br';

If lResult .And. lAutOk
	SEND MAIL FROM cFrom ;
	TO  'jailton@dipromed.com.br'; 
	SUBJECT 	cAssunto;
	BODY    	cMsg;
	RESULT lResult
	If !lResult
		//Erro no envio do email
		GET MAIL ERROR cError
		MsgInfo(cError,OemToAnsi('Atenção'))
	EndIf
	DISCONNECT SMTP SERVER
Else
	//Erro na conexao com o SMTP Server
	GET MAIL ERROR cError
	MsgInfo(cError,OemToAnsi('Atenção'))
EndIf
Return(.T.)
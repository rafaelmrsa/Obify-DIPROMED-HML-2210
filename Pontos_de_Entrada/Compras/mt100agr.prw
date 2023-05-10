/*
PONTO.......: MT100AGR          PROGRAMA....: MATA100
DESCRI«ƒO...: APOS A GRAVACAO DA NF FORA DA TRANSACAO
UTILIZA«ƒO..: O ponto de entrada È chamado apos a inclusao da NF, porem
fora da transacao.
Isto foi feito pois clientes que utilizavam TTS e tinham interface com o
usuario no ponto MATA100 "travavam" os registros utilizados, causando
parada para outros usuarios que estavam acessando a base.


PARAMETROS..: UPAR do tipo X : NENHUM


RETORNO.....: URET do tipo X : NENHUM
*/

/*====================================================================================\
|Programa  | MT100AGR       | Autor | Alexandro Dias            | Data | 30/01/2002   |
|=====================================================================================|
|DescriÁ„o | Ponto de entrada para desdobrar os titulos a pagar dos                   |
|          | Fornecedores que utilizam este tratamento conforme definido              |
|          | no campo especifico A2_DESDOBR.                                          |
|=====================================================================================|
|Sintaxe   | MT100AGR                                                                 |
|=====================================================================================|
|Uso       | Especifico DIPROMED                                                      |
|=====================================================================================|
|=====================================================================================|
|HistÛrico | DD/MM/AA - DescriÁ„o da alteraÁ„o                                        |
+----------+--------------------------------------------------------------------------+
| ERIBERTO | 06/06/03 - Coloquei os GetArea                                           |
|          | Coloquei impressao de PRE-NOTA quando È nota de devolucao com formulario |
|          | proprio                                                                  |
+----------+--------------------------------------------------------------------------+
| ERIBERTO | 06/04/04 - Coloquei get para transportadora quando nota de entrada com   |
|          | nosso formulario                                                         |
+----------+--------------------------------------------------------------------------+
| ERIBERTO | 08/12/04 - Coloque get para: obs, menpad e despesas aduesco para ratear  |
+----------+--------------------------------------------------------------------------+
| RAFAEL   | 16/02/05 - Adicionar gravaÁ„o no Kardex (SZ9) para cada item da NFE-devol|
+----------+--------------------------------------------------------------------------+
+----------+----------------------------------------------------------------------- --+
| MAXIMO   | 23/09/08 - Adicionar envio de e-mail para nota de NFE-devol.             |
+----------+--------------------------------------------------------------------------+
| MAXIMO   | 29/09/08 - FunÁ„o GrvCusDip() adicionada para calcular custo dipromed e  |
|          |            atualizar D1_CUSDIP e B1_UPRC.                                |
|          |            IncluÌdo percentual Desconto/Acrescimo no e-mail.             |
+----------+--------------------------------------------------------------------------+
| MAXIMO   | 29/10/08 - Alterando o calculo do D1_CUSDIP E B1_UPRC                    |
+----------+--------------------------------------------------------------------------+
| MAXIMO   | 04/03/09 - Incluindo D1_ICMSRET NO CALCULO DO CUSDIP                     |
+----------+--------------------------------------------------------------------------+
| MAXIMO   | 13/03/09 - SÛ atualiza B1_CUSDIP qdo a TES atualiza UPRC.                |
+----------+--------------------------------------------------------------------------+
| MAXIMO   | 02/04/09 - Recalcula ICMS-ST com IVA ajustado                            |
+----------+--------------------------------------------------------------------------+
| MAXIMO   | 06/04/09 - Atualiza D1_BRICMS e D1_ICMSRET                               |
+----------+--------------------------------------------------------------------------+
| MAXIMO   | 19/05/09 - Incluido desc., frete, despesa, st e custo nos itens do e-mail|
+----------+--------------------------------------------------------------------------+
| MAXIMO   | 12/09/10 - Incluido dados de agendamento tabela - SZO                    |
+----------+--------------------------------------------------------------------------+
| MAXIMO   | 23/02/11 - Validar campo de volume/peso/espÈcie (Se atualiza estoque)    |
+----------+--------------------------------------------------------------------------+
| GIOVANI  | 12/01/12 - Atualiza D1_CLASFIS										      |
+----------+--------------------------------------------------------------------------+
| GIOVANI  | 26/01/12 - Desabilitado Atualiza D1_CLASFIS						      |
+----------+--------------------------------------------------------------------------+
| GIOVANI  | 26/01/12 - Atualiza B1_CUSDIP E B1_UPRC  da outra filial   		      |
+----------+--------------------------------------------------------------------------+
| AFSOUZA  | 31/01/17 - Adicionadas Rotinas utilizadas no nF·cil         		      |
+----------+--------------------------------------------------------------------------+
| MAXIMO   | 15/10/19 - Ajustando regra de formaÁ„o do CUSDIP            		      |
\====================================================================================*/

#INCLUDE "TBICONN.CH"   // JBS 23/06/2010 - Comandos da query BeginSQL/EndSql.
#INCLUDE "PROTHEUS.CH"
#Include "Ap5Mail.ch"
#INCLUDE "TOPCONN.CH"
#INCLUDE "RWMAKE.CH"
//#INCLUDE "PROTHEUS.CH"

#DEFINE CR    chr(13)+chr(10) // Carreage Return (Fim de Linha)

User Function MT100AGR()

DEFAULT l103Auto := .F. //Rafael Rosa Obify 30/06/2022

Local _xArea	:= GetArea()
Local _xAreaSA2	:= SA2->(GetArea())
Local _xAreaSE2	:= SE2->(GetArea())
Local _xAreaSF1	:= SF1->(GetArea())
Local _xAreaSF4	:= SF4->(GetArea())
Local _xAreaSB1	:= SB1->(GetArea())
Local _xAreaSD1 := SD1->(GetArea())
Local _cObs		:= Space(120)
Local cObs_119	:= Space(120)
Local _aRadio   := {"Utiliza Desdobramento dos Titulos...","Nao Utiliza Desdobramento dos Titulos..."}
Local _nOpcao   := 0
Local bOk       := {|| _nOpcao := 1 , oDlg:End()}
Local bOk       := {|| If((_cAtuEst = "S" .And. !Empty(Alltrim(_cEspEmb)) .And. _nVolume>0 .And. _nPesoL > 0 .And. _nPesoB > 0)  .Or. _cAtuEst = "N",(_nOpcao := 1, oDlg:End()),)}
Local _cAtuEst  := "N"
Local _lObs     := .T.
Local _nCount   := 0
Local xi        := 1
Private _cNFI   := ""
Private _cNFE   := ""
Private _cUsuar := Upper(U_DipUsr())
Private _nRadio     := 0
Private _cCliente   := SA2->A2_COD+SA2->A2_LOJA
Private cPorta      := Left(Upper(AllTrim(GETMV("MV_LPT_PRE"))),4) // JBS 21/10/2005
Private cCaminho    := Upper(AllTrim(GETMV("MV_LPT_PRE"))) // JBS 21/10/2005
Private cTipoPre    := "E"
Private aReturn     := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
Private cPerDesFor  := 0 //Desconto do forcecedor MCVN - 30/09/08
Private cPerAcrFor  := 0 //Acrescimo do fornecedor MCVN - 30/09/08
Private lImport     := SF1->F1_FORMUL $ 'S'
Private _cTransp    := SPACE(06)
Private _cTipofrete := 'CIF'
Private _nVolume    := 0
Private _nPesoL     := 0
Private _nPesoB     := 0
Private _cEspEmb    := Space(25)
Private _cMenPad    := Iif(SF1->F1_EST=='EX','P_C',Space(3))
Private _nAduesco   := 0
Private _cConferente:= Space(Len(SZC->ZC_CODIGO))
Private _dDtChega   := Ctod('')
Private _cHrChega   := "  :  :   "
Private _cHrConIni  := "  :  :   "
Private _cHrConfIN  := "  :  :   "
Private _cCodAgen := SPACE(6)

// Rotinas utilizadas no nF·cil.
If FindFunction("u_NFAC025")// Diego Domingos - FindFunction para compilar o fonte na PRODUCAO 31/01/2017	
	If INCLUI .OR. ALTERA 
		U_NFAC025(1)  //Realiza a manifestaÁ„o        
	ElseIf !INCLUI .AND. !ALTERA	
		U_NFAC025(2) // Atualiza o status do xml ingrado 	
	EndIf
EndIf

If "MATA310"$Upper(FunName())
	Return .T.
EndIf

If l103Class
	Inclui := .T.
EndIf

U_DIPPROC(ProcName(0),U_DipUsr()) // JBS 05/10/2005 - Gravando o nome do Programa no SZU

IF SA2->A2_DESDOBR == "S"  .and. Inclui
	@ 100,150 To 250,530 Dialog _oDlg Title OemToAnsi("Desdobramento - ")+Alltrim(SA2->A2_NOME)
	@ 010,020 say "Escolha a opcao Abaixo..."
	@ 023,050 RADIO _aRadio VAR _nRadio
	@ 055,140 BmpButton Type 1 Action ( IF(_nRadio==1,UDesdobra(),.T.),Close(_oDlg) )
	Activate Dialog _oDlg Centered Valid _nRadio > 0
ElseIF SA2->A2_DESDOBR == "S" .and. !Inclui .and. !Altera
	
	//≥ Quando o usuario seleciona a opcao excluir a rotina abaixo   ≥
	//≥ exclui os titulos referentes a Desdobramento.                ≥
	UDesdobra(_lDelDesdobra)
	_lDelDesdobra := .F.
EndIf

If Inclui
	
	If Type("l103Auto") <> "U" .And. l103Auto .And. Type("lDipM026") <> "U" .And. lDipM026  // JBS 29/12/2009 - Tratamento para rotina automatica
		
		_cObs := Iif(Select('SZY') > 0,"Nome do EDI: " + SZY->ZY_NOMEEDI,"NFE EMITIDA AUTOMATICAMENTE" )
		
	ElseIf Type("l103Auto") <> "U" .And. l103Auto .And. Type("lDipA046Dv") <> "U" .And. lDipA046Dv  // JBS 14/07/2010 - Tratamento para rotina automatica - DIPA046
		
		_cObs := "DevoluÁ„o da NF "+AllTrim(SZL->ZL_NOTA)+"/"+SZL->ZL_SERIE
	
	//Nova regra adicionada - Rafael Rosa Obify 23/06/2022 (FALHA REPRODUZIDA NO PROCESSO DE IMPORTACAO CTE NA FILIAL 0101) - INICIO
	//Importacao TOTVS colaboracao
	Elseif (Type("l103Auto") <> "U" .And. l103Auto) .OR. FunName()=="SCHEDCOMCOL"

		//Rafael Rosa Obify - 01/07/2022 - INICIO
		IF cFilAnt = "01"
			cFilObs	:= "MATRIZ"
		ELSEIF cFilAnt = "04"
			cFilObs	:= "CD"
		ENDIF
		//Rafael Rosa Obify - 01/07/2022 - FIM

		_cObs	:= "Entrada Importacao TOTVS Colaboracao - " + cFilObs
		
	//Nova regra adicionada - Rafael Rosa Obify 23/06/2022 (FALHA REPRODUZIDA NO PROCESSO DE IMPORTACAO CTE NA FILIAL 0101) - INICIO

	

	Else
		
		@ 126,000 To 230,300 DIALOG oDlg TITLE OemToAnsi(" NF - " + SF1->F1_DOC )
		@ 020,010 Say "ObservaÁ„o: "
		@ 020,055 Get _cObs Size 93,20 Picture "@S100"
		@ 040,050 BMPBUTTON TYPE 1 ACTION Close(odlg)
		
		ACTIVATE DIALOG oDlg Centered
	
	Endif
	// atualiza a observaÁ„o (rafael)
	Dbselectarea("SF1")
	
	RecLock("SF1",.F.)
	SF1->F1_OBS     := _cObs
	SF1->F1_USUARIO := U_DipUsr()   // MCVN 19/01/2009
	SF1->F1_HORA    := TIME()   // JBS 17/11/2005 - InformaÁ„o usada em query no DIPR059.
	SF1->(MsUnlock())
          
	DbSelectArea("SD1")
	DbSetOrder(1)

	IF DbSeek( xFilial("SD1")+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA )
		While SD1->(!Eof()) .and. SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA == ;
					   			  SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE+SD1->D1_LOJA
			If SD1->D1_LOCAL $ "06/98"
				_lObs := .F.
			End
			SD1->(DbSkip())
		EndDo
	EndIf

	DbSelectArea("SE2")
	DbSetOrder(6)
	
	IF DbSeek( xFilial("SE2") + SF1->F1_FORNECE+SF1->F1_LOJA+SF1->F1_SERIE+SF1->F1_DOC )
		While SE2->(!Eof()) .and. SE2->E2_FORNECE+SE2->E2_LOJA+SE2->E2_PREFIXO+SE2->E2_NUM == ;
			SF1->F1_FORNECE+SF1->F1_LOJA+SF1->F1_SERIE  +SF1->F1_DOC
			RecLock("SE2",.F.)
			If cEmpAnt <> "04" 
				If _lObs
					SE2->E2_HIST := SF1->F1_OBS
				EndIf
			Else
				SE2->E2_HIST := SF1->F1_OBS			
			EndIf	
			SE2->E2_USUARIO := U_DipUsr()
			SE2->E2_FILORIG := SM0->M0_CODFIL
			SE2->(MsUnLock())
			SE2->(DbSkip())
		EndDo
	EndIf
	
	Begin Sequence
	//------------------------------------------------------------------------------------------------------
	// JBS 14/07/2010
	// Tratamento de geracao de notas de entrada com Excecao de mostrar tela de transportadora e conferencia
	//------------------------------------------------------------------------------------------------------
	do case
		case Type("l103Auto") <> "U" .And. l103Auto ; Break				//Nova regra adicionada - Rafael Rosa Obify 23/06/2022 (FALHA REPRODUZIDA NO PROCESSO DE IMPORTACAO CTE NA FILIAL 0101)
		case FunName()=="SCHEDCOMCOL" ; Break							//Nova regra adicionada - Rafael Rosa Obify 30/06/2022 (FALHA REPRODUZIDA NO PROCESSO DE IMPORTACAO CTE NA FILIAL 0101)
		case Type("lDipM026") <> "U" .and. lDipM026 ; Break				// chamado do DIPM026 - Gerano NFEs de CTRS a pagar
		case Type("lDipa027") <> "U" .and. lDipa027 ; Break				// chamado do DIPA027 -
		case Type("lDipa046Dv") <> "U" .and. lDipa046Dv ; Break			// chamado do DIPA046 - Gerando nota fiscal de Devolucao de cliente
		case Type("lDipa048Dv") <> "U" .and. lDipa048Dv ; Break			// chamado do DIPA048 - Gerando nota fiscal de entrada entre Dipromed
		case ('CTR' $ SF1->F1_ESPECIE) ; Break							// Se for entrada de NF de COnhecimento de frete
		case SF1->F1_FORMUL $ 'N '   .and. SF1->F1_TIPO <> 'N'; Break
	endcase
	//------------------------------------------------------------------------------------------------------
	// JBS 14/07/2010
	// Continua o processamento se nao cair em nenhuma excecao
	//------------------------------------------------------------------------------------------------------
	
	//------------------------------------------------------------------------------------------------------
	// MCVN 23/02/11
	// Verifica se a TES atualiza Estoque
	//------------------------------------------------------------------------------------------------------
	dbSelectArea("SD1")
	dbSetOrder(1)
	dbSeek(xFilial("SD1")+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA)
	//While SD1->(!eof()) .and. xFilial("SD1") == SD1->D1_FILIAL .and. SD1->D1_DOC==SF1->F1_DOC .And. _cAtuEst <> "S"  .And. SF1->F1_FORMUL $ 'S'
	While SD1->(!eof()) .and. xFilial("SD1") == SD1->D1_FILIAL .and. SD1->D1_DOC==SF1->F1_DOC .And. SF1->F1_FORMUL $ 'S'
		
		_cNAtuEst := Posicione("SF4",1,xFilial('SF4')+SD1->D1_TES,"SF4->F4_ESTOQUE")
		
		If 	_cAtuEst <> "S"
			_cAtuEst := _cNAtuEst
		Endif
		
		If _cNAtuEst == "N"
			_nCount++
		EndIf
		
		SD1->(DbSkip())
	End
	
	If _nCount >0
		_cNFI:=SF1->F1_DOC
		CMT100AGR() // RBORGES - 28/11/2013 - DISPARA CIC DA NOTA FISCAL QUE N√O ATUALIZA ESTOQUE
		EMT100AGR() // RBORGES - 28/11/2013 - DISPARA EMAIL DA NOTA FISCAL QUE N√O ATUALIZA ESTOQUE
	EndIf
	
	lImport     := SF1->F1_FORMUL $ 'S'
	
	_cTransp    := SPACE(06)
	_cTipofrete := 'CIF'
	_nVolume    := 0
	_nPesoL     := 0
	_nPesoB     := 0
	_cEspEmb    := Space(25)
	_cMenPad    := Iif(SF1->F1_EST=='EX','P_C',Space(3))
	_nAduesco   := 0
	_cConferente:= Space(Len(SZC->ZC_CODIGO))
	_dDtChega   := Ctod('')
	_cHrChega   := "  :  :   "
	_cHrConIni  := "  :  :   "
	_cHrConfIN  := "  :  :   "
	_cCodAgen   := SPACE(6)
	
	
	Do While _nOpcao = 0
		
		@ 126,000 To 485,300 DIALOG oDlg TITLE OemToAnsi(" NF - " + SF1->F1_DOC )
		
		@ 020,010 Say OemToAnsi("Transportadora: ")
		@ 030,010 Say OemToAnsi("Tipo de frete: ")
		@ 040,010 Say OemToAnsi("Especie Embalagem: ")
		@ 050,010 Say OemToAnsi("Volume: ")
		@ 060,010 Say OemToAnsi("Peso Liquido: ")
		@ 070,010 Say OemToAnsi("Peso Bruto: ")
		@ 020,070 Get _cTransp    Size 33,08 F3 "SA4" Valid ExistCpo("SA4")
		@ 030,070 Get _cTipoFrete Size 10,08 Valid _cTipoFrete $ 'CIF/FOB'
		@ 040,070 Get _cEspEmb    Size 53,20 Valid If(_cAtuEst = "S",!Empty(Alltrim(_cEspEmb)),.T.)
		@ 050,070 Get _nVolume    Size 33,08 Valid If(_cAtuEst = "S",_nVolume > 0,.T.) Picture "@E 999,999"
		@ 060,070 Get _nPesoL     when lImport Size 53,08 Valid If(_cAtuEst = "S",_nPesoL > 0,.T.) Picture "@E 999,999.9999"
		@ 070,070 Get _nPesoB     when lImport Size 53,08 Valid If(_cAtuEst = "S",_nPesoB > 0,.T.) Picture "@E 999,999.9999"
		
		If "MATA119" $ FunName()  // Verifica se vem do programa MATA119
			@ 126,000 To 230,300 DIALOG oDlg TITLE OemToAnsi(" NF - " + SF1->F1_DOC )
			@ 020,010 Say OemToAnsi("ObservaÁ„o: ")
			@ 020,055 Get cObs_119 Size 93,08 Picture "@S100"
			@ 040,050 BMPBUTTON TYPE 1 ACTION Close(odlg)
			ACTIVATE DIALOG oDlg Centered
		EndIf
		
		@ 080,010 Say OemToAnsi("Mensagem padrao: ")
		@ 090,010 Say OemToAnsi("Despesas (ADUESCO): ")
		@ 080,070 Get _cMenPad   Size 33,08 F3 "SM4" when lImport Valid Vazio() .or. ExistCpo("SM4")
		@ 090,070 Get _nAduesco  when lImport Size 53,08 Picture "@E 99,999,999.99"
		
		@ 100,010 Say OemToAnsi("CÛdigo Agendamento:: ")    //MCVN - 12-09-2010
		@ 110,010 Say OemToAnsi("Dt Real da Entrega: ")
		@ 120,010 Say OemToAnsi("Hr Real da Entrega: ")
		@ 130,010 Say OemToAnsi("Conferente: ")
		@ 140,010 Say OemToAnsi("Hr inicio conferÍncia: ")
		@ 150,010 Say OemToAnsi("Hr Final da conferÍncia:: ")
		
		@ 100,070 Get _cCodAgen   F3 'SZO'    Size 40,08 valid Vazio() .Or. ExistCpo("SZO")
		@ 110,070 Get _dDtChega                      Size 40,08 valid !Empty(_dDtChega)
		@ 120,070 Get _cHrChega                      Size 40,08 valid !Empty(_cHrChega) Picture "99:99:99"
		@ 130,070 Get _cConferente F3 'SZC'   Size 30,08 valid ExistCpo("SZC")
		@ 140,070 Get _cHrConIni                      Size 40,08 Picture "99:99:99"
		@ 150,070 Get _cHrConfIN                      Size 40,08 Picture "99:99:99"
		
		@ 170,096 BMPBUTTON TYPE 1 ACTION (Eval(bOk))
		ACTIVATE DIALOG oDlg Centered
		
	EndDo
	
	Processa({|| GrvDadosADC() }) //(rafael)
	
	End Sequence
	
	// GERA LAN«AMENTO NO KARDEX (SZ9) DE CADA ITEM DA NFE DE DEVOLU«√O
	If SF1->F1_TIPO == 'D'
		DbSelectArea("SD2")
		cPedido := SD2->D2_PEDIDO
		DbSelectArea("SZ9")
		For xi:=1 to Len(aCols)
			U_DiprKardex(cPedido,U_DipUsr(),"NF Orig "+AllTrim(aCols[xi][24])+'-'+AllTrim(aCols[xi][25])+ " Prod "+AllTrim(aCols[xi][1]),.T.,"24") // JBS 28/10/2005
		Next
	EndIf
	
	If SF1->F1_TIPO = 'N'   .And. SF1->F1_EST <> 'EX' .And. Type("lDipa048Dv") = "U"
		Processa({|| GrvCusDip() })  // Atualiza Custo Dipromed
	Endif
	/*
	//Giovani Zago 12/01/2012
	dbSelectArea("SD1")
	SD1->(DbGoTop())
	SD1->(dbSetOrder(1))
	SD1->(dbSeek(xFilial("SD1")+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA))
	While SD1->(!eof()) .and. xFilial("SD1") == SD1->D1_FILIAL .and. SD1->D1_DOC == SF1->F1_DOC
	dbSelectArea("SB1")
	SB1->(dbSetOrder(1))
	SB1->(dbSeek(xFilial("SB1")+SD1->D1_COD))
	dbSelectArea("SF4")
	SF4->(dbSetOrder(1))
	SF4->(dbSeek(xFilial("SF4")+SD1->D1_TES))
	RecLock("SD1",.F.)
	SD1->D1_CLASFIS := ALLTRIM(SB1->B1_ORIGEM)+Alltrim(SF4->F4_SITTRIB)
	SD1->(MsUnlock())
	SD1->(DbCommit())
	
	SD1->(DbSkip())
	End
	*/
	
	
	
	
EndIf // inclui
//-----------------------------------------------------------------------------------------
// JBS 14/07/2010
// Tratamento de excecoes para chamada da pre-nota de entrada
//-----------------------------------------------------------------------------------------
Begin Sequence

If Type("lDipa046Dv") <> "U" .and. lDipa046Dv
	U_M100AGRCIC("SPED")  //MCVN - 06/09/2010
	Break           // chamado do DIPA046 - Gerando nota fiscal de Devolucao de cliente
EndIf

If SF1->F1_FORMUL <> 'S'
	Break
EndIf

PreNota_ENT()
U_M100AGRCIC("SPED")  //MCVN - 18/08/10                                                 

End Sequence                

If Inclui
	U_NfeEmail(1) // JBS 20/10/2005 Envia e-mail da NF Incluida para a Diretoria (Erich)
ElseIf Altera
	U_NfeEmail(2) // JBS 20/10/2005 Envia e-mail da NF Alterada para a Diretoria (Erich)
EndIf

If l103Class
	Inclui := .F.
EndIf

_cNFE := SF1->F1_DOC

If !Inclui .And. !Altera
	CMT100EXC() // RBORGES - 28/11/2013 - DISPARA CIC DA NOTA FISCAL EXCLUIDA
	EMT100EXC() // RBORGES - 28/11/2013 - DISPARA EMAIL DA NOTA FISCAL EXCLUIDA
EndIf

If INCLUI .And. SF1->F1_FORMUL == "S" .And. SF1->F1_EST == "EX"
	U_xCompImp()// RBORGES - 27/04/2015 - Rotina para preencher o complemento das NF¥s de importaÁ„o
EndIf

If cEmpAnt <> '04'
	If INCLUI .Or. ALTERA
		U_EMaiClaQ() // RBORGES - 23/03/2016 - Chama a funÁ„o de e-mail para NF¥s com itens para o local 06
	EndIf                        
EndIf

RestArea(_xAreaSB1)
RestArea(_xAreaSE2)
RestArea(_xAreaSA2)
RestArea(_xAreaSF4)
RestArea(_xAreaSF1)
RestArea(_xAreaSD1)
RestArea(_xArea)

Return(.T.)

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±∫Programa  ≥UDesdobra ∫ Autor ≥   Alexandro Dias    ∫ Data ≥  30/01/02   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Descricao ≥ Processa o desdobramento.                                   ∫±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Static Function UDesdobra(_lDelDesdobra)

Local _aSE2      := {}
Local _cPesquisa := _cCliente+cSerie+cNFiscal  //cA100For+cLoja+cSerie+cNFiscal
Local _nLin := 1 
Local _nInc := 1
nVez := 1
IF !Inclui .and. !Altera
	
	//≥ Quando o usuamcanrio seleciona a opcao excluir, atualiza a chave ≥
	//≥ de pesquisa dos titulos referentes a Desdobramento.          ≥
	IF _lDelDesdobra
		_cPesquisa := _cCliente + "999"+cNFiscal //cA100For+cLoja+"999"+cNFiscal
	EndIF
EndIF
DbSelectArea("SE2")
DbSetOrder(6)
IF DbSeek(xFilial("SE2")+_cPesquisa)
	While !Eof() .and. SE2->E2_FORNECE+SE2->E2_LOJA+SE2->E2_PREFIXO+SE2->E2_NUM ;
		== _cPesquisa
		
		RecLock("SE2",.F.)
		IF _lDelDesdobra
			//≥ Exclui os titulos referentes a Desdobramento.   ≥
			DbDelete()
		Else
			//≥ Atualiza os titulos gerados pelo Microsiga  ≥
			//≥	conforme a regra de Desdobramento.  		≥
			IF Mod(E2_VALOR,2) == 0
				Replace E2_VALOR  With ( E2_VALOR  / 2 )
				Replace E2_SALDO  With ( E2_SALDO  / 2 )
				Replace E2_VLCRUZ With ( E2_VLCRUZ / 2 )
			ElseIf nVez == 1
				nVez := nVez +  1
				Replace E2_VALOR  With Round((E2_VALOR/2),2)
				Replace E2_SALDO  With Round((E2_SALDO/2),2)
				Replace E2_VLCRUZ With Round((E2_VLCRUZ/2),2)
			ElseIf nVez == 2
				Replace E2_VALOR  With NoRound((E2_VALOR/2),2)
				Replace E2_SALDO  With NoRound((E2_SALDO/2),2)
				Replace E2_VLCRUZ With NoRound((E2_VLCRUZ/2),2)
				nVez := 1
			Endif
			Aadd( _aSE2 , Array(FCount()) )
			
			For _nLin := 1 To Fcount()
				_aSE2[Len(_aSE2),_nLin] := &(FieldName(_nLin))
			Next
		EndIF
		MsUnLock()
		DbSkip()
	EndDo
	IF Len(_aSE2) > 0 .and. Inclui
		
		//≥ Inclui os titulos referentes a Desdobramento.   ≥
		For _nInc := 1 to Len(_aSE2)
			RecLock("SE2",.T.)
			For _nLin := 1 To Fcount()
				FieldPut(_nLin,_aSE2[_nInc,_nLin])
			Next
			
			//≥ Os titulos referentes a Desdobramento, recebe o prefixo 999. ≥
			Replace E2_PREFIXO With "999"
			MsUnLock()
		Next
	EndIF
EndIF

Return

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±≥FunáÖo    ≥ PRENOTA_Ent ≥ Autor ≥ Eriberto Elias     ≥ Data ≥ 06.06.03 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÖo ≥ Emissao da Pre-Nota DE ENTRADA                             ≥±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Static Function PreNota_ENT()
/*
// TESTANDO ISPRINTER("LPT2")  ERIBERTO 27-06-2005
If !ISPRINTER(cPorta) // JBS 18/10/2005
MSGBOX(cPorta+" DESCONECTADA"+chr(13)+chr(13)+"Por favor Fale com o Sr. Eriberto","ATENCAO!")  // JBS 18/10/2005
EndIf
*/
Local cPrinter     := Upper(AllTrim(GETMV("MV_LPT_PRE"))) // MCVN 25/01/2006


// Emite normalmente a PrÈ-Nota
WaitRun("NET USE "+cPorta+" /DELETE")  // JBS 18/10/2005
WaitRun("NET USE "+cCaminho)  // JBS 18/10/2005

Set Device To Print
Set Printer to &cPorta


/*PrinterWin(.T.)
PreparePrint(.F., "", .F., cPorta)
#IFDEF WINDOWS
initprint(1)
#ENDIF
*/



// Tratanto para imprimir na Laser  MCVN - 05/10/2007

If  "LASER" $ cPrinter
	
	// Imprime via Spool direto na impressora padr„o sem a interaÁ„o do usu·rio
	wnrel := SetPrint("SF1","prenota_ent","","","","","",.F.,"",.F.,"M",,.F.,,"DEFAULT.DRV",.T.,.F.)
	
	aReturn[5] := 2 //MCVN - 13/09/2007
	
	If nLastKey == 27
		Return
	Endif
	
	SetDefault(aReturn,"SF1")
	
	If nLastKey == 27
		Return
	Endif
Else
	
	Set Device To Print
	Set Printer to &cPorta
	
	PrinterWin(.T.)
	PreparePrint(.F., "", .F., cPorta)
	#IFDEF WINDOWS
		initprint(1)
	#ENDIF
	
Endif



// Posiciona registro no cliente do pedido
dbSelectArea("SA2")
DbSetOrder(1)
DbSeek(xFilial("SA2")+_cCliente)   //cA100For+cLoja)
// Verifica o posicionamento da impressora
If Prow() <> 0
	If Prow() = 65  // Se estiver parada na linha 65, vai para a proxima linha, antes de zerar os controles.
		@ Prow()+1,0 psay ""
	EndIf
	SetPrc(0,0)
EndIf

// Faz manualmente porque nao chama a funcao Cabec()
@ 01,000 psay Chr(15)+Replicate("-",220-83)
@ 02,000 psay SM0->M0_NOME

@ 02,041 psay "| "+SA2->A2_COD+"-"+SA2->A2_LOJA+"  "+SA2->A2_NOME
@ 02,100 psay "| NOTA DE ENTRADA N.  "+SF1->F1_DOC
@ 03,041 psay "| "
@ 03,100 psay "| EmitidA em : "+DTOC(SF1->F1_EMISSAO)
li:= 4
@ li,000 psay Replicate("-",220-83)
li++
@ li,000 psay "Impresso dia: " + DTOC(ddatabase) + " as " + SUBSTR(time(),1,5)+'  por: '+Upper(U_DipUsr())
li+=2
_transp := "Transportadora.:  "+SF1->F1_TRANSP+" *** "+ALLTRIM(Posicione("SA4",1,xFilial("SA4")+SF1->F1_TRANSP,"SA4->A4_NOME"))+" ***"
@ li,220-83-len(_transp) psay _transp
li+=2
@ li,000 psay Replicate("-",220-83)
li+=4


IF Inclui
	@ li,000 psay '***** FAVOR  IMPRIMIR NOTA FISCAL DE ENTRADA '+SF1->F1_DOC+' *****'
	li+=2
	@ li,005 psay '***** FAVOR  IMPRIMIR NOTA FISCAL DE ENTRADA '+SF1->F1_DOC+' *****'
	li+=2
	@ li,010 psay '***** FAVOR  IMPRIMIR NOTA FISCAL DE ENTRADA '+SF1->F1_DOC+' *****'
	li+=2
	@ li,015 psay '***** FAVOR  IMPRIMIR NOTA FISCAL DE ENTRADA V'+SF1->F1_DOC+' *****'
	li+=2
	@ li,020 psay '***** FAVOR  IMPRIMIR NOTA FISCAL DE ENTRADA '+SF1->F1_DOC+' *****'
	li+=2
	@ li,025 psay '***** FAVOR  IMPRIMIR NOTA FISCAL DE ENTRADA '+SF1->F1_DOC+' *****'
	li+=5
ElseIF !Inclui .and. !Altera
	@ li,000 psay '***** NOTA FISCAL DE ENTRADA '+SF1->F1_DOC+' EXCLUIDA NAO IMPRIMA *****'
	li+=2
	@ li,000 psay '***** NOTA FISCAL DE ENTRADA '+SF1->F1_DOC+' EXCLUIDA NAO IMPRIMA *****'
	li+=2
	@ li,000 psay '***** NOTA FISCAL DE ENTRADA '+SF1->F1_DOC+' EXCLUIDA NAO IMPRIMA *****'
	li+=2
	@ li,000 psay '***** NOTA FISCAL DE ENTRADA '+SF1->F1_DOC+' EXCLUIDA NAO IMPRIMA *****'
	li+=2
	@ li,000 psay '***** NOTA FISCAL DE ENTRADA '+SF1->F1_DOC+' EXCLUIDA NAO IMPRIMA *****'
	li+=2
	@ li,000 psay '***** NOTA FISCAL DE ENTRADA '+SF1->F1_DOC+' EXCLUIDA NAO IMPRIMA *****'
	li+=5
Endif


@ 52,000 psay Replicate("-",220-83)
U_BigNumber(SF1->F1_DOC)

@ 60,000 psay Replicate("-",220-83)
@ 65,000 psay ""
li := 80
SetPgEject(.F.) // JBS 03/01/2005
MS_FLUSH()

Return


/////////////////////////////////////////////////////////////////////////////
Static Function GrvDadosADC()               

Local _nCusTab    := 0
Local _nUprTab    := 0
Local _cFiTro     := ""
Local _x          := 1 
ProcRegua(50) //(rafael)
For _x := 1 to 25
	IncProc( "Gravando dados...(SF1)" )
Next
//------------------------------------------------------------------------------------------------------
// JBS-23/06/2010 - Inicio da Customizacao de Agendamento de Entregas.
//                  Busca, no Pedido de compras, os dados originais do agendamento de entrega do pedido.
//------------------------------------------------------------------------------------------------------
BeginSql Alias "TRB_AG"
	
	/*	COLUMN C7_DTENTRE AS DATE
	
	Select Top 1 max(C7_DTENTRE) C7_DTENTRE,C7_HRENTRE,C7_CODTRAN,C7_NOMCONT,C7_FONE
	From %Table:SD1% SD1
	
	Inner Join %Table:SC7% SC7 on C7_FILIAL = %xFilial:SC7%
	and C7_NUM = D1_PEDIDO
	and C7_ITEM = D1_ITEMPC
	and SC7.%notdel%
	
	Where D1_FILIAL  = %xFilial:SD1%
	and D1_SERIE   = %Exp:SF1->F1_SERIE%
	and D1_DOC     = %Exp:SF1->F1_DOC%
	and D1_FORNECE = %Exp:SF1->F1_FORNECE%
	and D1_LOJA    = %Exp:SF1->F1_LOJA%
	and SD1.%notdel%
	
	Group By C7_DTENTRE,C7_HRENTRE,C7_CODTRAN,C7_NOMCONT,C7_FONE
	
	Order By C7_DTENTRE Desc
	*/
	
	
	//MCVN - 12-09-10
	COLUMN ZO_DTENTRE AS DATE
	
	Select ZO_CODIGO, ZO_DTENTRE, ZO_HRENTRE, ZO_TRANSP, ZO_CONTATO, ZO_FONECON
	From %Table:SZO% SZO
	
	Where ZO_FILIAL  = %xFilial:SZO%
	and ZO_CODIGO   = %Exp:_cCodAgen%
	and ZO_STATUS   <>  "3"
	and SZO.%notdel%
	
	
EndSql
//------------------------------------------------------------------------------------------------------
// Grava as informacoes de conferencia do recebimento - JBS - 23/06/2010
//------------------------------------------------------------------------------------------------------
Dbselectarea("SF1")
RecLock("SF1",.F.)
SF1->F1_CONFERE  := 	_cConferente
SF1->F1_DTCHEGA :=	_dDtChega
SF1->F1_HRCHEGA :=	_cHrChega
SF1->F1_HRCOINI    :=	_cHrConIni
SF1->F1_HRCOFIN   :=	_cHrConfIN
//------------------------------------------------------------------------------------------------------
// Grava os dados originais do agendamento da entrega, na nota fiscal - JBS - 23/06/2010
//------------------------------------------------------------------------------------------------------
If !TRB_AG->( EOF().and.BOF())
	
	TRB_AG->( DbGoTop() )
	
	SF1->F1_DTENTRE   := TRB_AG->ZO_DTENTRE
	SF1->F1_HRENTRE   := TRB_AG->ZO_HRENTRE
	SF1->F1_NOMCONT   := TRB_AG->ZO_CONTATO
	SF1->F1_FONE      := TRB_AG->ZO_FONECON
	SF1->F1_CODAGEN   := _cCodAgen
	
EndIf

//------------------------------------------------------------------------------------------------------
// JBS - 23/06/2010 Fim da da Customizacao de Gravacao de Agendamentos de entreda e Conferencia
//------------------------------------------------------------------------------------------------------
SF1->F1_TRANSP  := _cTransp
SF1->F1_FRETEPO := _cTipoFrete
SF1->F1_ESPEMB  := _cEspEmb
SF1->F1_VOLUMES := _nVolume
SF1->F1_PESOL   := _nPesoL
SF1->F1_PESOB   := _nPesoB
SF1->F1_MENPAD  := _cMenPad
SF1->F1_II      := _nAduesco
SF1->F1_ESPECI1 := _cEspEmb // JBS 30/04/2010 - Usado no NFESEFAZ.PRW para envio da NFE
SF1->F1_VOLUME1 := _nVolume // JBS 30/04/2010 - Usado no NFESEFAZ.PRW para envio da NFE
SF1->F1_PLIQUI  := _nPesoL  // JBS 30/04/2010 - Usado no NFESEFAZ.PRW para envio da NFE
SF1->F1_PBRUTO  := _nPesoB  // JBS 30/04/2010 - Usado no NFESEFAZ.PRW para envio da NFE

SF1->(MsUnlock())
//------------------------------------------------------------------------------------------------------
// Fecha a Query com os dados do agendamento informado no P.C. - JBS - 23/06/2010
//------------------------------------------------------------------------------------------------------
TRB_AG->( DbCloseArea() )

//----------------------------------------------------------------------------------------------------------
// Atualiza Status do agendamento (Entregue ou parcialmente Entregue - MCVN - 12-09-10
//----------------------------------------------------------------------------------------------------------
If Alltrim(SF1->F1_CODAGEN)<> ""
	Dbselectarea("SZO")
	RecLock("SZO",.F.)
	If MsgYesNo("Existem mais notas para o agendamento selecionado?","AtenáÑo")
		SZO->ZO_STATUS := "2"
	Else
		SZO->ZO_STATUS := "3"
	Endif
	SZO->(MsUnlock())
Endif

//------------------------------------------------------------------------------------------------------
// So nota de importacao
//------------------------------------------------------------------------------------------------------
If SF1->F1_EST == 'EX'
	dbSelectArea("SD1")
	dbSetOrder(1)
	dbSeek(xFilial("SD1")+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA)
	While SD1->(!eof()) .and. xFilial("SD1") == SD1->D1_FILIAL .and. SD1->D1_DOC==SF1->F1_DOC
		IncProc( "Gravando dados...(SD2)" )
		
		If xFilial("SD1") == SD1->D1_FILIAL .And. SD1->D1_DOC==SF1->F1_DOC .And. ;    // MCVN - 27/10/2008
			SD1->D1_SERIE==SF1->F1_SERIE .And. SD1->D1_FORNECE==SF1->F1_FORNECE .And. ;
			SD1->D1_LOJA == SF1->F1_LOJA
			
			// MCVN - Atualiza D1_CUSDIP para NF de importaÁ„o 17/01/2009
			RecLock("SD1",.F.)
			SD1->D1_CUSDIP := (SD1->(D1_TOTAL+D1_VALICM+D1_VALIMP5+D1_VALIMP6+D1_DESPESA+D1_VALIPI)+(SD1->D1_TOTAL/SF1->F1_VALMERC*_nADuesco))/SD1->D1_QUANT //MCVN - 17/01/2009
			SD1->(MsUnlock())
			SD1->(DbCommit())

			
			dbSelectArea("SF4")
			dbSetOrder(1)
			dbSeek(xFilial("SF4")+SD1->D1_TES)
			If SF4->F4_UPRC == 'S'				
				dbSelectArea("SB1")
				dbSetOrder(1)
				dbSeek(xFilial("SB1")+SD1->D1_COD)
				RecLock("SB1",.F.)
				SB1->B1_UPRC   := SD1->D1_VUNIT
				SB1->B1_CUSDIP := (SD1->(D1_TOTAL+D1_VALICM+D1_VALIMP5+D1_VALIMP6+D1_DESPESA+D1_VALIPI)+(SD1->D1_TOTAL/SF1->F1_VALMERC*_nADuesco))/SD1->D1_QUANT //MCVN - 16/01/2009
				SB1->(MsUnlock())
			EndIf
						
			If cEmpAnt = "01"         
				If cFilAnt = "01"
					_cFiTro := "04"
					DbSelectArea("SB1")
					SB1->(DbSetOrder(1))
					SB1->(DbSeek(cFilAnt + SB1->B1_COD ))
					_nCusTab    := SB1->B1_CUSDIP
					_nUprTab    := SB1->B1_UPRC			
					If	SB1->(DbSeek(_cFiTro + SB1->B1_COD ))
						RecLock("SB1",.F.)
					//	SB1->B1_CUSDIP := _nCusTab
						SB1->B1_UPRC   := _nUprTab
						SB1->(MsUnlock())
						SB1->(DbCommit())
					Endif
				ElseIf cFilAnt = "04"
					_cFiTro := "01"
					DbSelectArea("SB1")
					SB1->(DbSetOrder(1))
					SB1->(DbSeek(cFilAnt + SB1->B1_COD ))
					_nCusTab    := SB1->B1_CUSDIP
					_nUprTab    := SB1->B1_UPRC			
					If	SB1->(DbSeek(_cFiTro + SB1->B1_COD ))
						RecLock("SB1",.F.)
					//	SB1->B1_CUSDIP := _nCusTab
						SB1->B1_UPRC   := _nUprTab
						SB1->(MsUnlock())
						SB1->(DbCommit())
					Endif
				Endif				
			EndIf			

		Endif
		SD1->(DbSkip())
	End
EndIf
Return
/////////////////////////////////////////////////////////////////////////////
//GrvCusDip()
//Atualiza D1_CUSDIP e B1_UPRC
//Maximo 29/09/08
Static Function GrvCusDip()

Local nB1_UPRC   := 0
Local nIvaAjust  := 0
Local nPBaseReduz:= 0
Local nBaseSolid := 0
Local nValSolid  := 0
Local nTotBSolid := 0 // Ser· gravado no F1 - MCVN 06/04/09
Local nTotVSolid := 0 // Ser· gravado no F1 - MCVN 06/04/09
Local nCusTab    := 0
Local nUprTab    := 0
Local cFiTro     := ""
Local _cExc      := ""
Local _nCusDip	 := 0
Local _nDifICM	 := 0
Local _x         := 1  

ProcRegua(50)
For _x := 1 to 25
	IncProc( "Atualizando CUSDIP e UPRC...(SD1 e SB1)" )
Next

dbSelectArea("SD1")
dbSetOrder(1)
dbSeek(xFilial("SD1")+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA)
While SD1->(!eof()) .and. xFilial("SD1") == SD1->D1_FILIAL .and. SD1->D1_DOC==SF1->F1_DOC
	
	IncProc( "Gravando dados...(SD1/SB1)" )
	
	nB1_UPRC := 0
	If xFilial("SD1") == SD1->D1_FILIAL .And. SD1->D1_DOC==SF1->F1_DOC .And. ;    // MCVN - 27/10/2008
		SD1->D1_SERIE==SF1->F1_SERIE .And. SD1->D1_FORNECE==SF1->F1_FORNECE .And. ;
		SD1->D1_LOJA == SF1->F1_LOJA
		
		//Zerando Vari·veis
		nB1_UPRC   := 0
		nIvaAjust  := 0
		nPBaseReduz:= 0
		nBaseSolid := 0
		nValSolid  := 0
		_nDifICM   := 0
		
		// IncluÌdo Recalculo do ST somente se ja existir ST 02/04/2009   // Corrigido posicionamento no B1 com o posicione  22/05/09
		If SD1->D1_ICMSRET > 0 .AND. SF1->F1_EST <> 'SP' .AND. SF1->F1_EST <> 'MG' // IncluÌdo MG na regra dia 12/08/09 - MCVN
	     /*	If !(SD1->D1_TES $ '010/015')  // MCVN - 30/09/2009 /DESATIVADO EM 25/11/2016
				nIvaAjust  := Iif(Posicione("SB1",1,xFilial("SB1")+SD1->D1_COD,"SB1->B1_PICMENT")=0,0,(((1+Posicione("SB1",1,xFilial("SB1")+SD1->D1_COD,"SB1->B1_PICMENT")/100)*(1-SD1->D1_PICM/100)/(1-Posicione("SB1",1,xFilial("SB1")+SD1->D1_COD,"SB1->B1_PICM")/100))-1)*100)
			Else
				nIvaAjust  := Iif(Posicione("SB1",1,xFilial("SB1")+SD1->D1_COD,"SB1->B1_PICMENT")=0,0,Posicione("SB1",1,xFilial("SB1")+SD1->D1_COD,"SB1->B1_PICMENT"))
			Endif  */  
			
			nIvaAjust  := Iif(Posicione("SB1",1,xFilial("SB1")+SD1->D1_COD,"SB1->B1_PICMENT")=0,0,(((1+Posicione("SB1",1,xFilial("SB1")+SD1->D1_COD,"SB1->B1_PICMENT")/100)*(1-SD1->D1_PICM/100)/(1-Posicione("SB1",1,xFilial("SB1")+SD1->D1_COD,"SB1->B1_PICM")/100))-1)*100)
			nPBaseReduz:= Posicione("SF4",1,xFilial('SF4')+SD1->D1_TES,"F4_BASEICM")
			nBaseSolid := (IIf(nPBaseReduz > 0,(SD1->D1_TOTAL+SD1->D1_VALFRE-SD1->D1_VALDESC)*SF4->F4_BASEICM/100,(SD1->D1_TOTAL+SD1->D1_VALFRE-SD1->D1_VALDESC)))+SD1->D1_VALIPI
			nBaseSolid := (nBaseSolid+(nBaseSolid*NoRound(nIvaAjust,2)/100))
			nValSolid  := ((((nBaseSolid*Posicione("SB1",1,xFilial("SB1")+SD1->D1_COD,"SB1->B1_PICM")/100)-SD1->D1_VALICM)))
			nTotBSolid := nTotBSolid+nBaseSolid
			nTotVSolid := nTotVSolid+nValSolid  // MCVN - 06/04/09
		Endif
		
		dbSelectArea("SC7")
		dbSetOrder(1)
		dbSeek(xFilial("SC7")+SD1->D1_PEDIDO+SD1->D1_ITEMPC)
		If SD1->D1_PEDIDO == SC7->C7_NUM .AND. SD1->D1_ITEMPC == SC7->C7_ITEM
			If SC7->C7_ACREFOR > 0    // Se existe acrÈscimo no cadastrado do fornecedor
				
				_nCusDip := SD1->D1_TOTAL-SD1->D1_VALDESC         //Valor - desconto
				_nCusDip += SD1->(D1_SEGURO+D1_DESPESA+D1_VALFRE) //Valor bruto
				
				If (!SF1->F1_EST$'SP/EX' .And. SD1->D1_VALICM > 0) .Or. (SD1->D1_VALICM > 0 .AND. SD1->D1_PICM <> SB1->B1_PICM)
					_nDifICM := _nCusDip*(DifICMS(SD1->D1_COD,SD1->D1_PICM)/100)
				EndIf
				
				_nCusDip += (_nCusDip*SD1->D1_IPI/100)			  //Valor + IPI
				_nCusDip += _nDifICM   							  //Valor + dif ICMS
				_nCusDip := _nCusDip/SD1->D1_QUANT				  //Valor de cada item
				_nCusDip := _nCusDip*(1+(SC7->C7_ACREFOR/100))    //Valor + Acrescimo
				_nCusDip += IIf(SF1->F1_EST$'SP/MG',(SD1->D1_ICMSRET/SD1->D1_QUANT),(nValSolid/SD1->D1_QUANT))
				
				SD1->(RecLock("SD1",.F.))
				
				SD1->D1_CUSDIP := _nCusDip
				
				// Grava ICMS-ST quando NF for de fora de SP - MCVN - 06/04/09
				If SD1->D1_ICMSRET > 0 .AND. SF1->F1_EST <> 'SP' .AND. SF1->F1_EST <> 'MG' // IncluÌdo MG na regra dia 12/08/09 - MCVN
					SD1->D1_BRICMS := nBaseSolid
					SD1->D1_ICMSRET:= nValSolid
				Endif
				
				SD1->(MsUnlock())
				SD1->(DbCommit())
				
				If cPerAcrFor == 0
					cPerAcrFor := SC7->C7_ACREFOR
				Endif
				
			ElseIf SC7->C7_DESCFOR > 0 // Se existe desconto no cadastrado do fornecedor
				
				_nCusDip := SD1->D1_TOTAL-SD1->D1_VALDESC         //Valor - desconto
				_nCusDip += SD1->(D1_SEGURO+D1_DESPESA+D1_VALFRE) //Valor bruto
				
				If (!SF1->F1_EST$'SP/EX' .And. SD1->D1_VALICM > 0) .Or. (SD1->D1_VALICM > 0 .AND. SD1->D1_PICM <> SB1->B1_PICM)
					_nDifICM := _nCusDip*(DifICMS(SD1->D1_COD,SD1->D1_PICM)/100)
				EndIf
				
				_nCusDip += (_nCusDip*SD1->D1_IPI/100)			  //Valor + IPI
				_nCusDip += _nDifICM   							  //Valor + dif ICMS
				_nCusDip := _nCusDip/SD1->D1_QUANT				  //Valor de cada item
				_nCusDip := _nCusDip*((100-SC7->C7_DESCFOR)/100)  //Valor - Desconto
				_nCusDip += IIf(SF1->F1_EST$'SP/MG',(SD1->D1_ICMSRET/SD1->D1_QUANT),(nValSolid/SD1->D1_QUANT))
				
				SD1->(RecLock("SD1",.F.))
				
				SD1->D1_CUSDIP := _nCusDip
				
				// Grava ICMS-ST quando NF for de fora de SP - MCVN - 06/04/09
				If SD1->D1_ICMSRET > 0 .AND. SF1->F1_EST <> 'SP' .AND. SF1->F1_EST <> 'MG' // IncluÌdo MG na regra dia 12/08/09 - MCVN
					SD1->D1_BRICMS := nBaseSolid
					SD1->D1_ICMSRET:= nValSolid
				Endif
				
				SD1->(MsUnlock())
				SD1->(DbCommit())
				
				If cPerDesFor == 0
					cPerDesFor := SC7->C7_DESCFOR
				Endif
				
			Else
				
				_nCusDip := SD1->D1_TOTAL-SD1->D1_VALDESC         //Valor - desconto
				_nCusDip += SD1->(D1_SEGURO+D1_DESPESA+D1_VALFRE) //Valor bruto
				
				If (!SF1->F1_EST$'SP/EX' .And. SD1->D1_VALICM > 0) .Or. (SD1->D1_VALICM > 0 .AND. SD1->D1_PICM <> SB1->B1_PICM)
					_nDifICM := _nCusDip*(DifICMS(SD1->D1_COD,SD1->D1_PICM)/100)
				EndIf
				
				_nCusDip += (_nCusDip*SD1->D1_IPI/100)			  //Valor + IPI
				_nCusDip += _nDifICM   							  //Valor + dif ICMS
				_nCusDip := _nCusDip/SD1->D1_QUANT				  //Valor de cada item
				_nCusDip += IIf(SF1->F1_EST$'SP/MG',(SD1->D1_ICMSRET/SD1->D1_QUANT),(nValSolid/SD1->D1_QUANT))
				
				SD1->(RecLock("SD1",.F.))
				SD1->D1_CUSDIP := _nCusDip
				
				// Grava ICMS-ST quando NF for de fora de SP - MCVN - 06/04/09
				If SD1->D1_ICMSRET > 0 .AND. SF1->F1_EST <> 'SP' .AND. SF1->F1_EST <> 'MG' // IncluÌdo MG na regra dia 12/08/09 - MCVN
					SD1->D1_BRICMS := nBaseSolid
					SD1->D1_ICMSRET:= nValSolid
				Endif
				SD1->(MsUnlock())
				SD1->(DbCommit())
			EndIf
			
			// Calculando UPRC e gravando no SB1  (Valor sem acrÈscimo/desconto  29/10/08 - DESABILITADO 05/11/2008 MCVN
			//nB1_UPRC       := ((SD1->D1_TOTAL + (SD1->D1_TOTAL*D1_IPI/100) + SD1->D1_SEGURO  + SD1->D1_DESPESA + SD1->D1_VALFRE)/SD1->D1_QUANT)
			
			
			//DESABILITADO ATUALIZA«√O DO B1_UPRC EM 05/11/2008 MCVN
			
			/*dbSelectArea("SF4")
			dbSetOrder(1)
			dbSeek(xFilial("SF4")+SD1->D1_TES)
			dbSelectArea("SB1")
			dbSetOrder(1)
			dbSeek(xFilial("SB1")+SD1->D1_COD)
			RecLock("SB1",.F.)
			If SF4->F4_UPRC == 'S' .And. SD1->D1_CUSDIP > 0
			SB1->B1_UPRC   := nB1_UPRC        // Atualizando ⁄ltimo preÁo do produto SEM AcrÈscimo/Desconto
			Endif
			SB1->B1_CUSDIP := SD1->D1_CUSDIP  // Atualizando ⁄ltimo preÁo do produto COM AcrÈscimo/Desconto
			SB1->(MsUnlock())
			*/
			
			// Atualiza B1_CUSDIP somente quando a TES atualiza preÁo de compra MCVN - 13/03/2009
			dbSelectArea("SF4")
			dbSetOrder(1)
			dbSeek(xFilial("SF4")+SD1->D1_TES)
			If SF4->F4_UPRC == 'S'
				dbSelectArea("SB1")
				dbSetOrder(1)
				dbSeek(xFilial("SB1")+SD1->D1_COD)
				RecLock("SB1",.F.)
				SB1->B1_CUSDIP := SD1->D1_CUSDIP  // Atualizando ⁄ltimo preÁo do produto COM AcrÈscimo/Desconto/ipi/Frete/Despesa e seguro
				SB1->(MsUnlock())
			EndIf
		Else // Nota fiscal de entrada sem pedido de compra MCVN - 05/03/2009
			If SD1->D1_CUSDIP = 0
				RecLock("SD1",.F.)
				SD1->D1_CUSDIP := (((SD1->D1_TOTAL-SD1->D1_VALDESC) + ((SD1->D1_TOTAL-SD1->D1_VALDESC)*D1_IPI/100) + SD1->D1_SEGURO  + SD1->D1_DESPESA + SD1->D1_VALFRE)/SD1->D1_QUANT)+;
				Iif(SF1->F1_EST <> 'SP' .AND. SF1->F1_EST <> 'MG',(nValSolid/SD1->D1_QUANT),(SD1->D1_ICMSRET/SD1->D1_QUANT))
				// Eriberto 08/09/10 +;// MCVN 04/03/2009
				//Iif(SD1->D1_FORNECE == '000630',(SD1->D1_VALDESC/SD1->D1_QUANT),0) // Acordo comercial para America Medical - Somamos o desconto no custo do produto - MCVN - 06/04/09
				
				// Grava ICMS-ST quando NF for de fora de SP - MCVN - 06/04/09
				If SD1->D1_ICMSRET > 0 .AND. SF1->F1_EST <> 'SP' .AND. SF1->F1_EST <> 'MG' // IncluÌdo MG na regra dia 12/08/09 - MCVN
					SD1->D1_BRICMS := nBaseSolid
					SD1->D1_ICMSRET:= nValSolid
				Endif
				
				SD1->(MsUnlock())
				SD1->(DbCommit())
				// Atualiza B1_CUSDIP somente quando a TES atualiza preÁo de compra MCVN - 13/03/2009
				dbSelectArea("SF4")
				dbSetOrder(1)
				dbSeek(xFilial("SF4")+SD1->D1_TES)
				If SF4->F4_UPRC == 'S'
					dbSelectArea("SB1")
					dbSetOrder(1)
					dbSeek(xFilial("SB1")+SD1->D1_COD)
					RecLock("SB1",.F.)
					SB1->B1_CUSDIP := SD1->D1_CUSDIP  // Atualizando ⁄ltimo preÁo do produto COM AcrÈscimo/Desconto/ipi/Frete/Despesa e seguro
					SB1->(MsUnlock())
				EndIf
			Endif
		Endif
	EndIf
	
	//Giovani Zago 26/01/2012 -  DESBILITADO EM 07-02-2013 SOLICITADO PELA ROSEMEIRE FERRARIS.
	//                           HABILITADO  EM 02-08-2013 SOLICITADO PELA ROSEMEIRE FERRARIS.
	                         
	// Atualizando campo SB1->B1_PICM_SN (Aliq. Atual do Simples Nacional) 19-02-2015
	SA2->(dbSetOrder(1))
	If SA2->(dbSeek(xFilial("SA2")+SD1->(D1_FORNECE+D1_LOJA))) .And. SA2->A2_OPTSIMP == '2'
		dbSelectArea("SB1")
		dbSetOrder(1)
		dbSeek(xFilial("SB1")+SD1->D1_COD)
		RecLock("SB1",.F.)
		SB1->B1_PICM_SN:= SD1->D1_PICM
		SB1->(MsUnlock())
	EndIf
	
	
	// Atualiza B1_UPRC somente quando a TES atualiza preÁo de compra MCVN - 09/01/23
	dbSelectArea("SF4")
	dbSetOrder(1)
	dbSeek(xFilial("SF4")+SD1->D1_TES)
	If SF4->F4_UPRC == 'S'
		If cEmpAnt = "01" 
			If cFilAnt = "01"
				cFiTro := "04"
				DbSelectArea("SB1")
				SB1->(DbSetOrder(1))
				SB1->(DbSeek(cFilAnt + SB1->B1_COD ))
				nCusTab    := SB1->B1_CUSDIP
				nUprTab    := SB1->B1_UPRC			
				If	SB1->(DbSeek(cFiTro + SB1->B1_COD ))
					RecLock("SB1",.F.)
					//SB1->B1_CUSDIP := nCusTab
					SB1->B1_UPRC   := nUprTab
					If SA2->A2_OPTSIMP == '2'// Atualizando campo SB1->B1_PICM_SN (Aliq. Atual do Simples Nacional) 19-02-2015
						SB1->B1_PICM_SN:= SD1->D1_PICM
					Endif
					SB1->(MsUnlock())
					SB1->(DbCommit())
				Endif
			ElseIf cFilAnt = "04"
				cFiTro := "01"
				DbSelectArea("SB1")
				SB1->(DbSetOrder(1))
				SB1->(DbSeek(cFilAnt + SB1->B1_COD ))
				nCusTab    := SB1->B1_CUSDIP
				nUprTab    := SB1->B1_UPRC			
				If	SB1->(DbSeek(cFiTro + SB1->B1_COD ))
					RecLock("SB1",.F.)
					//SB1->B1_CUSDIP := nCusTab
					SB1->B1_UPRC   := nUprTab
					If SA2->A2_OPTSIMP == '2'// Atualizando campo SB1->B1_PICM_SN (Aliq. Atual do Simples Nacional) 19-02-2015
						SB1->B1_PICM_SN:= SD1->D1_PICM
					Endif
					SB1->(MsUnlock())
					SB1->(DbCommit())
				Endif
			Endif
		EndIf
	Endif 
	
	If SD1->(FieldPos("D1_XICMENT")) > 0
		SD1->(RecLock("SD1",.F.))
		SD1->D1_XICMENT := SD1->(Posicione("SB1",1,xFilial("SB1")+SD1->D1_COD,"B1_PICMENT"))
		SD1->(MsUnLock())
	EndIf
	
	SD1->(DbSkip())
End

If (SF1->F1_ICMSRET > 0 .AND. SF1->F1_EST <> 'SP' .AND. SF1->F1_EST <> 'MG') .Or. (SF1->F1_FORNECE == '100630' .AND.  SF1->F1_ICMSRET > 0 )
	
	RecLock("SF1",.F.)
	
	SF1->F1_BRICMS := nTotBSolid
	SF1->F1_ICMSRET:= nTotVSolid
	If SF1->F1_EMISSAO >= CTOD('01/04/2009')   .And. ;
		(SF1->F1_VALMERC + SF1->F1_FRETE + SF1->F1_SEGURO + SF1->F1_DESPESA + SF1->F1_ICMSRET + SF1->F1_VALIPI - SF1->F1_DESCONT) > SF1->F1_VALBRUT
		SF1->F1_DTRECST:= DDataBase
	Endif
	
	SF1->(MsUnlock())
	SF1->(DbCommit())
	//---------------------------------------------------------------------------------
	// MCVN 07/04/2009:
	// Envia CIC para fiscal/cont·bil MCVN - 07/04/09
	//---------------------------------------------------------------------------------
	// JBS 19/02/2009:
	// Avalia se a S.T nao foi recolhida envia uma mensagem de CIC para o usuario de
	// Contabilidade, informando-o que deve-se recolher o valor da S.T. desta NFE
	//---------------------------------------------------------------------------------
	If ((SF1->F1_VALMERC + SF1->F1_FRETE + SF1->F1_SEGURO + SF1->F1_DESPESA + SF1->F1_ICMSRET + SF1->F1_VALIPI - SF1->F1_DESCONT ) > SF1->F1_VALBRUT)  .Or. (SF1->F1_FORNECE == '100630' .AND.  SF1->F1_ICMSRET > 0 ) // IncluÌdo valor do IPI na soma  MCVN - 14-04-10 // Tratado para emitir AmÈrica 29-10-21
		U_M100AGRCIC("INC")
	Endif
	
Endif

Return
/*                                                              Sao Paulo,  20 Out 2005
---------------------------------------------------------------------------------------
Empresa.......: DIPOMED ComÈrcio e ImportaÁ„o Ltda.

FunÁ„o........: NFEEMAIL(nOp)
Objetivo......: Enviar e-mail para ‡ Diretoria quando È incluida, alterada ou excluida
.             : uma nota fiscal de entrada.

Autor.........: Jailton B Santos, JBS

Data..........: 20 Out 2005
Vers„o........: 1.0
ConsideraÁoes.: FunÁ„o chamada dos P.Es. A100DEL.PRW e MT100AGR.PRW
---------------------------------------------------------------------------------------
Parametro nOp: 1 Foi chamada para enviar um e-mail de Aviso de Inclusao de uma NFE
2 Foi chamada para enviar um e-mail de Aviso de AlteraÁ„o de uma NFE
3 Foi chamada para enviar um e-mail de Aviso de Exclus„o de uma NFE
---------------------------------------------------------------------------------------
*/
User Function NfeEmail(nOp)

Local aEnvEmailNFE:={}
Local aTitulo:={}
Local cAssunto:=''
Local cFilSA1:=xFilial('SA1') // MCVN - 23/09/08
Local cFilSE1:=xFilial('SE1') // MCVN - 23/09/08
Local cFilSD2:=xFilial('SD2') // MCVN - 23/09/08
Local cFilSA2:=xFilial('SA2')
Local cFilSD1:=xFilial('SD1')
Local cFilSB1:=xFilial('SB1')
Local cFilSE2:=xFilial('SE2')
Local cBarra:=''
Local cPrzoPag:=''
Local aOp:={{' (INCLUIDA) ',' (ALTERADA) ',' (EXCLUIDA) '},{'MT100AGR.PRW','MT100AGR.PRW','A100DEL.PRW'}}
Local nPreco:=0
Local nCusto:=0
Local nTotal:=0
Local nMrg_C:=0
Local nMrg_P:=0
Local nNfOrig := "" //MCVN - 24/09/08
Local nD1TES  := "" //MCVN - 24/09/08
Local cUser   := U_DipUsr()   
Local cIndBen := GetNewPar("MV_UINDBEN","019433,110087,091835")

Private aUsuario:={}
Private cF1Obs   := "" //MCVN - 24/09/08
Private cOperSd2 := "" //MCVN - 24/09/08
Private cMailOper:= "" //MCVN - 24/09/08
Private cVendSc5 := "" //MCVN - 24/09/08
Private cTipoVend:= "" //MCVN - 24/09/08
private cMailVend:= "" //MCVN - 24/09/08                                
Private _cPosto  := "" //RBorges 19/09/2017  
Private cNfDvAp  := GetNewPar("ES_NFDVAP","elizabete.rodrigues@dipromed.com.br")//RBorges 19/09/2017  
Private cNfDvLi  := GetNewPar("ES_NFDVLI","diana.silva@dipromed.com.br")//RBorges 19/09/2017  

// Registra o usuario que est· usando esta rotina, no SZU.
U_DIPPROC(ProcName(0),U_DipUsr())

// Localiza o usuario para poder usar o seu e-mail para identifica-lo na hora do e-envio.
PswOrder(2)
If PswSeek(cUser,.T.)
	aUsuario := PswRet()
EndIf

SB1->(dbSetOrder(1))
SD1->(dbSetOrder(1))
SE2->(dbSetOrder(6))
SE1->(dbSetOrder(2))
SA2->(dbSetOrder(1))
SA2->(DbSeek(cFilSA2+SF1->F1_FORNECE+SF1->F1_LOJA))
SA1->(dbSetOrder(1))
SA1->(DbSeek(cFilSA1+SF1->F1_FORNECE+SF1->F1_LOJA))

// Monta o Assunto do e-email
cAssunto:='NF '+AllTrim(SA2->A2_NREDUZ)+' - '+AllTrim(SF1->F1_DOC)+' Serie '+SF1->F1_SERIE+aOp[1,nOp]

If SA2->A2_FORPROD == 'P' .and. !SF1->F1_TIPO $ 'DB'
	// Seleciona os prazos e datas de vencimentos de titulos referente a esta NFE.
	SE2->(DbSeek(cFilSE2+SF1->F1_FORNECE+SF1->F1_LOJA+SF1->F1_SERIE+SF1->F1_DOC))
	Do While SE2->(!EOF()).and.;
		SE2->E2_FILIAL  == cFilSE2.and.;
		SE2->E2_FORNECE == SF1->F1_FORNECE.and.;
		SE2->E2_LOJA    == SF1->F1_LOJA.and.;
		SE2->E2_PREFIXO == SF1->F1_SERIE.and.;
		SE2->E2_NUM     == SF1->F1_DOC
		cPrzoPag += cBarra+StrZero(SE2->E2_VENCTO - SE2->E2_EMISSAO,2)
		aAdd(aTitulo,{SE2->E2_PARCELA,Dtoc(SE2->E2_VENCTO),Transform(SE2->E2_VALOR,"@E 999,999,999.99")})
		cBarra := ',  '
		SE2->(DbSkip())
	EndDo
	// Seleciona os itens da NFE e acumula no array aEnvEmailNFE
	SD1->(dbSeek(cFilSD1+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA))
	While SD1->(!eof()) .and.;
		SD1->D1_FILIAL  == cFilSD1 .and.;
		SD1->D1_DOC     == SF1->F1_DOC .and.;
		SD1->D1_SERIE   == SF1->F1_SERIE .and.;// MCVN - 06/01/2009
		SD1->D1_FORNECE == SF1->F1_FORNECE .and.;
		SD1->D1_LOJA    == SF1->F1_LOJA
		IncProc('Selecionando itens da nota fiscal ... ')
		SB1->(DbSeek(cFilSB1+SD1->D1_COD))
		// ApuraÁ„o do Custo Unitario com IPI e Custo Total com IPI
		nCusto:=((SD1->D1_VUNIT*SD1->D1_QUANT)+SD1->D1_VALIPI)/SD1->D1_QUANT
		nTotal:=(SD1->D1_VUNIT*SD1->D1_QUANT)+SD1->D1_VALIPI
		// ApuraÁ„o da Margem de PreÁo Minimo e Promocional
		// nMrg_C:= If(SB1->B1_PRVMINI>0,(SB1->B1_PRVMINI/nCusto-1)*100,0) Alterado calculo da margem- MCVN - 23/07/09
		// nMrg_P:= if(SB1->B1_PRVSUPE>0,(SB1->B1_PRVSUPE/nCusto-1)*100,0) Alterado calculo da margem- MCVN - 23/07/09
		nMrg_C:= If(SB1->B1_PRVMINI>0,(SB1->B1_PRVMINI/SD1->D1_CUSDIP-1)*100,0) //Alterado calculo da margem utilizando D1_CUSDIP- MCVN - 23/07/09
		nMrg_P:= if(SB1->B1_PRVSUPE>0,(SB1->B1_PRVSUPE/SD1->D1_CUSDIP-1)*100,0) //Alterado calculo da margem utilizandoD1_CUSDIP- MCVN - 23/07/09
		// GeraÁ„o da Array de Impress„o
		aAdd(aEnvEmailNFE,{SD1->D1_COD,;      // 01-Codigo do Produto
							SB1->B1_DESC,;    // 02-DescriÁ„o do Produto
							SD1->D1_UM,;      // 03-Unidade de Medida
							SD1->D1_QUANT,;   // 04-Quantidade do Produto
							nCusto,;          // 05-Custo Unitario com IPI
							nTotal,;          // 06-Custo total com IPI
							SB1->B1_PRVMINI,; // 07-PreÁo de minimo de Venda 'C'
							SB1->B1_PRVSUPE,; // 08-ProÁo de PromoÁ„o
							nMrg_C,;          // 09-Margem de PreÁo Minimo
							nMrg_P,;          // 10-Margem de PreÁo PromoÁ„o
							SD1->D1_ICMSRET,; // 11-ST   MCVN - 18/05/09
							If(SC7->C7_ACREFOR>0,(((((SD1->D1_TOTAL-SD1->D1_VALDESC) + SD1->D1_SEGURO  + SD1->D1_DESPESA + SD1->D1_VALFRE))*SC7->C7_ACREFOR)/100),0),; //12-Acre. Fornecedor MCVN - 18/05/09
							If(SC7->C7_DESCFOR>0,(((((SD1->D1_TOTAL-SD1->D1_VALDESC) + SD1->D1_SEGURO  + SD1->D1_DESPESA + SD1->D1_VALFRE))*SC7->C7_DESCFOR)/100),0),; //13-Desc. Fornecedor MCVN - 18/05/09
							SD1->D1_VALDESC,; // 14-Desconto item MCVN - 18/05/09
							SD1->D1_VALFRE,;  // 15-Frete item    MCVN - 18/05/09
							SD1->D1_DESPESA,; // 16-Despesa item  MCVN - 18/05/09
							SD1->D1_SEGURO ,; // 17-Seguro item   MCVN - 18/05/09
							SD1->D1_CUSDIP,;  // 18-Custo Dipromed MCVN - 18/05/09
							SD1->D1_VALIPI,;  // 19-Valor IPI
							SD1->D1_PEDIDO})  // 20-Pedido de Compras
		SD1->(DbSkip())
	EndDo
			// Se achou dados para enviar o e-mail, chama a funÁ„o para montar e enviar o e-mail.
	If Len(aEnvEmailNFE) > 0
		EnvEmailNFE(cAssunto,aEnvEmailNFE,cPrzoPag,aTitulo,aOp[2,nOp],aOp[1,nOp])
	Endif
ElseIf SF1->F1_TIPO == 'D' // Envia email referente as notas fiscais de devoluÁ„o MCVN - 23/09/08
			// Seleciona os prazos e datas de vencimentos das ncc's referente a esta NFE.
	cAssunto:=EncodeUTF8('NF DE DEVOLU«√O '+AllTrim(SA1->A1_NREDUZ)+' - '+AllTrim(SF1->F1_DOC)+' Serie '+SF1->F1_SERIE+aOp[1,nOp],"cp1252")
	SE1->(DbSeek(cFilSE1+SF1->F1_FORNECE+SF1->F1_LOJA+SF1->F1_SERIE+SF1->F1_DOC))
	Do While SE1->(!EOF()).and.;
		SE1->E1_FILIAL  == cFilSE1.and.;
		SE1->E1_CLIENTE == SF1->F1_FORNECE.and.;
		SE1->E1_LOJA    == SF1->F1_LOJA.and.;
		SE1->E1_PREFIXO == SF1->F1_SERIE.and.;
		SE1->E1_NUM     == SF1->F1_DOC
		cPrzoPag += cBarra+StrZero(SE1->E1_VENCTO - SE1->E1_EMISSAO,2)
		aAdd(aTitulo,{SE1->E1_PARCELA,Dtoc(SE1->E1_VENCTO),Transform(SE1->E1_VALOR,"@E 999,999,999.99")})
		cBarra := ',  '
		SE1->(DbSkip())
	EndDo
	// Seleciona os itens da NFE e acumula no array aEnvEmailNFE
	SD1->(dbSeek(cFilSD1+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA))
	Do While SD1->(!eof()) .and.;
		SD1->D1_FILIAL  == cFilSD1 .and.;
		SD1->D1_DOC     == SF1->F1_DOC .and.;
		SD1->D1_SERIE   == SF1->F1_SERIE .and.; // MCVN - 06/01/2009
		SD1->D1_FORNECE == SF1->F1_FORNECE .and.;
		SD1->D1_LOJA    == SF1->F1_LOJA
		IncProc('Selecionando itens da nota fiscal ... ')
		SB1->(DbSeek(cFilSB1+SD1->D1_COD))
		
		//  Buscando observaÁ„o da nfe - MCVN 24/09/08
		If Empty(Alltrim(cF1Obs))
			cF1Obs := SF1->F1_OBS
		Endif
		
		// Buscando operador e vendedor pela nota fiscal original - MCVN 24/09/08
		SD2->(dbSetOrder(3))
		If 	SD2->(DbSeek(cFilSD2+SD1->D1_NFORI+SD1->D1_SERIORI+SD1->D1_FORNECE+SD1->D1_LOJA))
			cOperSd2 := Posicione("SC5",1,xFilial("SC5")+SD2->D2_PEDIDO,"C5_OPERADO")
			cMailOper:= Alltrim(If(Empty(cMailOper),Lower(Alltrim(Posicione("SU7",1,xFilial("SU7")+cOperSd2,"U7_EMAIL"))),";"+;
			Lower(Alltrim(Posicione("SU7",1,xFilial("SU7")+cOperSd2,"U7_EMAIL"))))) // E-mail
			_cPosto := Posicione("SU7",1,xFilial("SU7")+cOperSd2,"U7_POSTO")//RBorges 19/09/2017
			 
			//RBorges 19/09/2017
			If     _cPosto == "01"
				cMailOper := cMailOper+";"+AllTrim(cNfDvAp)
			ElseIf _cPosto == "03" 
				cMailOper := cMailOper+";"+AllTrim(cNfDvLi)
			EndIF
			
			If(Empty(cVendSc5)) // Grava somente uma vez.
				cVendSc5 := Posicione("SC5",1,xFilial("SC5")+SD2->D2_PEDIDO,"C5_VEND1")
				cMailVend:= Alltrim(Posicione("SA3",1,xFilial("SA3")+cVendSc5,"A3_EMAIL"))
				cTipoVend:= Alltrim(Posicione("SA3",1,xFilial("SA3")+cVendSc5,"A3_TIPO"))
			Endif
		Endif

		
		// ApuraÁ„o do Custo Unitario com IPI e Custo Total com IPI
		nCusto:=((SD1->D1_VUNIT*SD1->D1_QUANT)+SD1->D1_VALIPI)/SD1->D1_QUANT
		nTotal:=(SD1->D1_VUNIT*SD1->D1_QUANT)+SD1->D1_VALIPI
		// ApuraÁ„o da Margem de PreÁo Minimo e Promocional
		nMrg_C := If(SB1->B1_PRVMINI>0,(SB1->B1_PRVMINI/nCusto-1)*100,0)
		nMrg_P := if(SB1->B1_PRVSUPE>0,(SB1->B1_PRVSUPE/nCusto-1)*100,0)
		nNfOrig:= SD1->D1_NFORI +" - "+SD1->D1_SERIORI+" - "+SD1->D1_ITEMORI
		nD1TES := SD1->D1_TES
		// GeraÁ„o da Array de Impress„o
		aAdd(aEnvEmailNFE,{SD1->D1_COD,;     // 01-Codigo do Produto
		SB1->B1_DESC,;    // 02-DescriÁ„o do Produto
		SD1->D1_UM,;      // 03-Unidade de Medida
		SD1->D1_QUANT,;   // 04-Quantidade do Produto
		nCusto,;          // 05-Custo Unitario com IPI
		nTotal,;          // 06-Custo total com IPI
		nD1TES,;          // 07-TES
		nNfOrig,;	      // 08-Nota fiscal, sÈrie original e item
		nil,;		      // 09-Reservado
		nil,;		      // 10-Reservado
		nil,;		      // 11-Reservado
		nil,;		      // 12-Reservado
		nil,;		      // 13-Reservado
		nil,;		      // 14-Reservado
		nil,;		      // 15-Reservado
		nil,;		      // 16-Reservado
		nil,;		      // 17-Reservado
		nil,;		      // 18-Reservado
		nil,;		      // 19-Reservado
		SD1->D1_PEDIDO})  // 20-Pedido de Compras 
		SD1->(DbSkip())
	EndDo
	// Se achou dados para enviar o e-mail, chama a funÁ„o para montar e enviar o e-mail.
	If Len(aEnvEmailNFE) > 0
		EnvEmailNFE(cAssunto,aEnvEmailNFE,cPrzoPag,aTitulo,aOp[2,nOp],aOp[1,nOp])
	Endif
	
ElseIf SA2->A2_FORPROD == 'O' .and. !SF1->F1_TIPO $ 'DB' .and. SA2->A2_COD $ cIndBen	

	// Seleciona os itens da NFE e acumula no array aEnvEmailNFE
	SD1->(dbSeek(cFilSD1+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA))
	While SD1->(!eof()) .and.;
		SD1->D1_FILIAL  == cFilSD1 .and.;
		SD1->D1_DOC     == SF1->F1_DOC .and.;
		SD1->D1_SERIE   == SF1->F1_SERIE .and.;// MCVN - 06/01/2009
		SD1->D1_FORNECE == SF1->F1_FORNECE .and.;
		SD1->D1_LOJA    == SF1->F1_LOJA
		IncProc('Selecionando itens da nota fiscal ... ')
		SB1->(DbSeek(cFilSB1+SD1->D1_COD))
		// ApuraÁ„o do Custo Unitario com IPI e Custo Total com IPI
		nCusto:=((SD1->D1_VUNIT*SD1->D1_QUANT)+SD1->D1_VALIPI)/SD1->D1_QUANT
		nTotal:=(SD1->D1_VUNIT*SD1->D1_QUANT)+SD1->D1_VALIPI
		// ApuraÁ„o da Margem de PreÁo Minimo e Promocional
		// nMrg_C:= If(SB1->B1_PRVMINI>0,(SB1->B1_PRVMINI/nCusto-1)*100,0) Alterado calculo da margem- MCVN - 23/07/09
		// nMrg_P:= if(SB1->B1_PRVSUPE>0,(SB1->B1_PRVSUPE/nCusto-1)*100,0) Alterado calculo da margem- MCVN - 23/07/09
		nMrg_C:= If(SB1->B1_PRVMINI>0,(SB1->B1_PRVMINI/SD1->D1_CUSDIP-1)*100,0) //Alterado calculo da margem utilizando D1_CUSDIP- MCVN - 23/07/09
		nMrg_P:= if(SB1->B1_PRVSUPE>0,(SB1->B1_PRVSUPE/SD1->D1_CUSDIP-1)*100,0) //Alterado calculo da margem utilizandoD1_CUSDIP- MCVN - 23/07/09
		// GeraÁ„o da Array de Impress„o
		aAdd(aEnvEmailNFE,{SD1->D1_COD,;      // 01-Codigo do Produto
							SB1->B1_DESC,;    // 02-DescriÁ„o do Produto
							SD1->D1_UM,;      // 03-Unidade de Medida
							SD1->D1_QUANT,;   // 04-Quantidade do Produto
							nCusto,;          // 05-Custo Unitario com IPI
							nTotal,;          // 06-Custo total com IPI
							SB1->B1_PRVMINI,; // 07-PreÁo de minimo de Venda 'C'
							SB1->B1_PRVSUPE,; // 08-ProÁo de PromoÁ„o
							nMrg_C,;          // 09-Margem de PreÁo Minimo
							nMrg_P,;          // 10-Margem de PreÁo PromoÁ„o
							SD1->D1_ICMSRET,; // 11-ST   MCVN - 18/05/09
							If(SC7->C7_ACREFOR>0,(((((SD1->D1_TOTAL-SD1->D1_VALDESC) + SD1->D1_SEGURO  + SD1->D1_DESPESA + SD1->D1_VALFRE))*SC7->C7_ACREFOR)/100),0),; //12-Acre. Fornecedor MCVN - 18/05/09
							If(SC7->C7_DESCFOR>0,(((((SD1->D1_TOTAL-SD1->D1_VALDESC) + SD1->D1_SEGURO  + SD1->D1_DESPESA + SD1->D1_VALFRE))*SC7->C7_DESCFOR)/100),0),; //13-Desc. Fornecedor MCVN - 18/05/09
							SD1->D1_VALDESC,; // 14-Desconto item MCVN - 18/05/09
							SD1->D1_VALFRE,;  // 15-Frete item    MCVN - 18/05/09
							SD1->D1_DESPESA,; // 16-Despesa item  MCVN - 18/05/09
							SD1->D1_SEGURO ,; // 17-Seguro item   MCVN - 18/05/09
							SD1->D1_CUSDIP,;  // 18-Custo Dipromed MCVN - 18/05/09
							SD1->D1_VALIPI,;  // 19-Custo Dipromed MCVN - 23/07/09
							SD1->D1_PEDIDO})  // 20-Pedido de compras RBorges - 22/05/17
		SD1->(DbSkip())
	EndDo
	
	If Len(aEnvEmailNFE) > 0
		EnvEmailNFE(cAssunto,aEnvEmailNFE,cPrzoPag,aTitulo,aOp[2,nOp],aOp[1,nOp])	
	EndIf
		
EndIf	


Return(.t.) 
/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥MT100AGR  ∫Autor  ≥Microsiga           ∫ Data ≥  07/13/15   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥                                                            ∫±±
±±∫          ≥                                                            ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ AP                                                        ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
*-------------------------------------------------------------------------------------*
Static Function EnvEmailNFE(cAssunto,aEnvEmailNFE,cPrzoPag,aTitulo,cDescRot,cOperacao)
// Monta e envia o e-mail para a Diretoria.
*-------------------------------------------------------------------------------------*
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
Local cEmailTo := If(SF1->F1_TIPO == "D",If(cTipoVend == 'I',cMailVend,cMailVend+";"+cMailOper),'erich.pontoldio@dipromed.com.br')        // MCVN - 24/09/08
Local cEmailCc := ""//(RBorges 30/09/2014) - If(SF1->F1_TIPO == "D","sac@dipromed.com.br",GetMv("ES_MT100AG",,"maximo.canuto@dipromed.com.br"))//sac@dipromed.com.br",'rosemeire.ferraris@dipromed.com.br;erica.leal@dipromed.com.br;wilson.silva@dipromed.com.br;silvia.moraes@dipromed.com.br;rt@dipromed.com.br;celia.labao@dipromed.com.br') // MCVN - 24/09/08
Local cEmailBcc:= '' // MCVN - 24/09/08
Local nTotAcrFor := 0
Local nTotDesFor := 0
Local lSmtpAuth := GetNewPar("MV_RELAUTH",.F.)
Local lAutOk	:= .F.           
Local cIndBen   := GetNewPar("MV_UINDBEN","019433,110087")
Local cEmIndben := GetNewPar("MV_EINDBEN","reginaldo.borges@dipromed.com.br;juraci.rocha@dipromed.com.br;financeiro@healthquality.ind.br")
Local i:=1
Local nLin := 1

//RBorges 30/09/2014 - CondiÁ„o para enviar e-mails de NF tipo D para o sac da HQ.
If cEmpAnt == "04"
	cEmailCc := If(SF1->F1_TIPO == "D",GetMv("ES_EMNFDEV",,"sac@healthquality.ind.br"),GetMv("ES_MT100AG",,"maximo.canuto@dipromed.com.br"))
	
	If  SF1->F1_FORNECE $ cIndBen // Se Fornecedor estiver contigo nos fornecedores que Beneficiamento e industrializaÁ„o
		cEmailCc := AllTrim(cEmIndben)
	EndIf
	
Else
	cEmailCc := If(SF1->F1_TIPO == "D",GetMv("ES_EMNFDEV",,"sac@dipromed.com.br"),GetMv("ES_MT100AG",,"maximo.canuto@dipromed.com.br"))//sac@dipromed.com.br",'rosemeire.ferraris@dipromed.com.br;wilson.silva@dipromed.com.br') // MCVN - 24/09/08
EndIf
//--------------------------------------------------------------------------
// Definicao do cabecalho do email
//--------------------------------------------------------------------------
cMsg := '<html>'
cMsg += '<head>'
cMsg += '<title>'+cAssunto+ '</title>'
cMsg += '</head>'
cMsg += '<body>'

cMsg += '<Table Align=Center BorderColor=#000000 CELLPADDING=4 CELLSPACING=0 Width=100%><table width="100%">'
cMsg += '   <tr>'
cMsg += '     <td width="100%" align="Center"><font size="4" color="green">'+SM0->M0_NOME+" / "+SM0->M0_FILIAL+"    -    "+cOperacao+'</font></td>'
cMsg += '   </tr>'
cMsg += '</table> <P>'
cMsg += '<HR Width=100% Size=4 Align=Centered Color=Red>'
If 'EXCLUIDA' $ cOperacao
	cMsg += '<Table Align=Center BorderColor=#000000 CELLPADDING=4 CELLSPACING=0 Width=100%><table width="100%">'
	cMsg += '   <tr>'
	cMsg += '     <td width="100%" align="Center"><font size="4" color="green">'+cOperacao+'</font></td>'
	cMsg += '   </tr>'
	cMsg += '</table> <P>'
EndIf
cMsg += '<Table Align=Center BorderColor=#000000 CELLPADDING=4 CELLSPACING=0 Width=100%>'
//-------------------------------------------------------------------------
// Definicao do cabecalho do relatÛrio
//-------------------------------------------------------------------------
cMsg += '<table width="100%">'
cMsg += '  <tr>'
If(SF1->F1_TIPO == 'D')
	cMsg += '     <td width="60%"><font size="3" color="blue"> ' + SA1->A1_COD + '-' + AllTrim(SA1->A1_NOME) + ' - ' + AllTrim(SA1->A1_EST) +'</font></td>'
Else
	cMsg += '     <td width="60%"><font size="3" color="blue"> ' + SA2->A2_COD + '-' + AllTrim(SA2->A2_NOME) + ' - ' + AllTrim(SA2->A2_EST) +'</font></td>'
Endif

cMsg += '     <td width="40%"><font size="4"  color="blue">Nota Fiscal: ' + Alltrim(SF1->F1_DOC) +' - Serie: '+SF1->F1_SERIE + '</font></td>'
cMsg += '  </tr>'
cMsg += '</table> <P>'

cMsg += '<table width="100%">'
cMsg += '  <tr>'
If(SF1->F1_TIPO == 'D')
	cMsg += '     <td width="50%"><font size="3" color="blue">CGC:  ' + SA1->A1_CGC +'</font></td>'
Else
	cMsg += '     <td width="50%"><font size="3" color="blue">CGC:    ' + SA2->A2_CGC +'</font></td>'
Endif
cMsg += '  </tr>'
cMsg += '</table> <P>'


// OBSERVA«√O PARA NOTA FISCAL DE DEVOLU«√O
If(SF1->F1_TIPO == 'D')
	cMsg += '<table width="100%">'
	cMsg += '  <tr>'
	cMsg += '     <td width="60%"><font size="3" color="red"> ObservaÁ„o:  ' + cF1Obs+'</font></td>'
	cMsg += '  </tr>'
	cMsg += '</table> <P>'
Endif


If(SF1->F1_TIPO == 'N')  // MCVN - 30/09/08
	If !('EXCLUIDA' $ cOperacao)
		If (cPerDesFor > 0 .or. cPerAcrFor > 0)
			cMsg += '<table>'
			cMsg += '  <tr>'
			If cPerAcrFor > 0
				cMsg += '     <td width="100%" align="right" colspan="2"><font size="2" color="red">Percentual de acrÈscimo: ' + Transform(cPerAcrFor,"@E 999,999,999.99") + ' % .</font></td>'
			Else
				cMsg += '     <td width="100%" align="right" colspan="2"><font size="2" color="red">Percentual de desconto : ' + Transform(cPerDesFor,"@E 999,999,999.99") + ' % .</font></td>'
			Endif
			cMsg += '  </tr>'
			cMsg += '</table>'
		EndIf
	Endif
Endif

If !Empty(cPrzoPag)
	cMsg += '<table>'
	cMsg += '  <tr>'
	cMsg += '     <td width="100%" colspan="2"><font size="2" color="blue">CondiÁ„o de Pagamento: ' + cPrzoPag + ' dias.</font></td>'
	cMsg += '  </tr>'
	cMsg += '</table>'
EndIf

If Len(aTitulo)>0
	cMsg += '<table width="22%" border="0" cellspacing="0" cellpadding="0">'
	cMsg += '  <tr>'
	cMsg += '     <td width="5%" align="Left"><font   size="1" color="black">Parcela</font></td>'
	cMsg += '     <td width="15%" align="Center"><font size="1" color="black">Vencimento</font></td>'
	cMsg += '     <td width="15%" align="right"><font  size="1" color="black">Valor do Titulo</font></td>'
	cMsg += '  </tr>'
	cMsg += '</table>'
	For i:=1 to Len(aTitulo)
		cMsg += '<table width="22%" border="0" cellspacing="0" cellpadding="0">'
		cMsg += '  <tr>'
		cMsg += '     <td width="5%"  align="Center"><font size="1" color="black">'+aTitulo[i,1]+'</font></td>'
		cMsg += '     <td width="15%" align="Center"><font size="1" color="black">'+aTitulo[i,2]+'</font></td>'
		cMsg += '     <td width="15%" align="right"><font  size="1" color="black">'+aTitulo[i,3]+'</font></td>'
		cMsg += '  </tr>'
		
		//cMsg += '  <tr>'
		//cMsg += '     <td width="34%"><font size="1" color="black">Vencimento  '+StrZero(i,2)+'</font></td>'
		//cMsg += '     <td width="08%" align="Center"><font size="1" color="black">em</font></td>'
		//cMsg += '     <td width="22%" align="Center"><font size="1" color="black">'+aTitulo[i,1]+'</font></td>'
		//cMsg += '     <td width="08%" align="Center"><font size="1" color="black">R$</font></td>'
		//cMsg += '     <td width="28%" align="right"><font size="1"  color="black">'+aTitulo[i,2]+'</font></td>'
		//cMsg += '   </tr>'
		cMsg += '</table>'
	Next
	cMsg += '<P>'
EndIf
cMsg += '<table width="100%" cellspacing="0" cellpadding="0"><font size="1" color="blue">'
//cMsg += '<tr>'
//cMsg += '<HR Width=100% Size=4 Align=Centered Color=BLACK>'
//cMsg += '</tr>'
cMsg += '</font></table>'
cMsg += '<table width="100%" border="3" cellspacing="0" cellpadding="0">
cMsg += '   <font size="1" color="blue">'
cMsg += '      <tr>'
If(SF1->F1_TIPO <> 'D')
	cMsg += '         <td width="50%">CÛdigo - DescriÁ„o</td>'
Else
	cMsg += '         <td width="50%">CÛdigo - DescriÁ„o - TES</td>'
Endif                                                   
cMsg += '         <td width="6%" align="center">Pedido</td>'
cMsg += '         <td width="5%" align="center">UM</td>'
cMsg += '         <td width="7%" align="right">Quantidade</td>'
cMsg += '         <td width="7%" align="right">Unitario</td>'
cMsg += '         <td width="9%" align="right">Total</td>'
If(SF1->F1_TIPO <> 'D')
	cMsg += '         <td width="8%" align="right">C</td>'
	cMsg += '         <td width="8%" align="right">PromoÁ„o</td>'
Else
	cMsg += '         <td width="16%" align="right">NF. Orig-Serie-Item</td>'
Endif
cMsg += '      </tr>'
cMsg += '   </font>'
cMsg += '</table>'
cMsg += '<table width="100%" cellspacing="0" cellpadding="0">
cMsg += '   <font size="1" color="blue">'
//cMsg += '       <tr>'
//cMsg += '          <HR Width=100% Size=4 Align=Centered Color=BLACK>'
//cMsg += '       </tr>'
cMsg += '   </font>'
cMsg += '</table>'
//-------------------------------------------------------------------------
// Definicao do texto/detalhe do email
//-------------------------------------------------------------------------
nTotAcrFor := 0
nTotDesFor := 0
For nLin := 1 to Len(aEnvEmailNFE)
	nTot_Prod += aEnvEmailNFE[nLin,6]
	cMsg += '<table width="100%" border="1" cellspacing="0" cellpadding="0">'
	cMsg += '   <tr BgColor='+aLinCor[nLinCor]+'>'
	If(SF1->F1_TIPO <> 'D')
		cMsg += '      <td width="50%"><font size="2">' + aEnvEmailNFE[nLin,1] + ' - ' + aEnvEmailNFE[nLin,2] +'</font></td>'
	Else
		cMsg += '      <td width="50%"><font size="1">' + aEnvEmailNFE[nLin,1] + ' - ' + aEnvEmailNFE[nLin,2] + ' - ' + aEnvEmailNFE[nLin,7] +'</font></td>'
	Endif
	If(SF1->F1_TIPO <> 'D')
		cMsg += '      <td width="6%" align="center"><font size="1">' + aEnvEmailNFE[nLin,20] + '</font></td>'
	EndIf	
	cMsg += '      <td width="5%" align="center"><font size="1">' + aEnvEmailNFE[nLin,3] + '</font></td>'
	cMsg += '      <td width="7%" align="right"><font size="1">' + Transform(aEnvEmailNFE[nLin,4],"@E 999,999,999") + '</font></td>'
	cMsg += '      <td width="7%" align="right"><font size="1">' + Transform(aEnvEmailNFE[nLin,5],"@E 999,999,999.9999") + '</font></td>'
	cMsg += '      <td width="9%" align="right"><font size="1">' + Transform(aEnvEmailNFE[nLin,6],"@E 999,999,999.99")   + '</font></td>'
	If(SF1->F1_TIPO <> 'D')
		cMsg += '      <td width="8%" align="right"><font size="1">' + Transform(aEnvEmailNFE[nLin,7],"@E 999,999,999.99")   + '</font></td>'
		cMsg += '      <td width="8%" align="right"><font size="1">' + Transform(aEnvEmailNFE[nLin,8],"@E 999,999,999.99")   + '</font></td>'
	Else
		cMsg += '      <td width="16%" align="right"><font size="1">' + aEnvEmailNFE[nLin,8] + '</font></td>'
	Endif
	cMsg += '   </tr>'
	cMsg += '</table>'
	
	If(SF1->F1_TIPO <> 'D')
		nLinCor++
		cMsg += '<table width="100%" border="1" cellspacing="5" cellpadding="0">'
		cMsg += '   <tr bgcolor='+aLinCor[nLinCor]+'>'
		cMsg += '      <td width="9%"  align="right"><font size="1" color="blue"> IPI: '        + Transform(aEnvEmailNFE[nLin,19],"@E 999,999.99") + '</font></td>'
		cMsg += '      <td width="9%"  align="right"><font size="1" color="blue"> Desconto: '   + Transform(aEnvEmailNFE[nLin,14],"@E 999,999.99") + '</font></td>'
		cMsg += '      <td width="9%"  align="right"><font size="1" color="blue"> Frete:    '   + Transform(aEnvEmailNFE[nLin,15],"@E 999,999.99") + '</font></td>'
		cMsg += '      <td width="9%"  align="right"><font size="1" color="blue"> Despesas: '   + Transform(aEnvEmailNFE[nLin,16],"@E 999,999.99") + '</font></td>'
		cMsg += '      <td width="9%"  align="right"><font size="1" color="blue"> Seguro: '     + Transform(aEnvEmailNFE[nLin,17],"@E 999,999.99") + '</font></td>'
		cMsg += '      <td width="9%"  align="right"><font size="1" color="blue"> Acre.Forn.: ' + Transform(aEnvEmailNFE[nLin,12],"@E 999,999.99") + '</font></td>'
		cMsg += '      <td width="9%"  align="right"><font size="1" color="red">  Desc.Forn.: ' + Transform(aEnvEmailNFE[nLin,13],"@E 999,999.99") + '</font></td>'
		cMsg += '      <td width="9%"  align="right"><font size="1" color="blue"> ST: '         + Transform(aEnvEmailNFE[nLin,11],"@E 999,999.99") + '</font></td>'
		cMsg += '      <td width="9%"  align="right"><font size="1" color="blue"> Custo: '      + Transform(aEnvEmailNFE[nLin,18],"@E 999,999.9999") + '</font></td>'
		cMsg += '      <td width="9%"  align="right"><font size="1" color="black">Margem C: '   + Transform(aEnvEmailNFE[nLin,09],"@E 999,999.99") + '</font></td>'
		cMsg += '      <td width="9%"  align="right"><font size="1" color="black">Margem P: '   + Transform(aEnvEmailNFE[nLin,10],"@E 999,999.99") + '</font></td>'
		cMsg += '   </tr>'
		cMsg += '</table>'
		
		nTotAcrFor += aEnvEmailNFE[nLin,12]
		nTotDesFor += aEnvEmailNFE[nLin,13]
	Endif
	if 	nLinCor<2
		nLinCor++
	Else
		nLinCor:=1
	EndIf
Next
cMsg += '<table width="100%"  border="1" cellspacing="5" cellpadding="0">'
cMsg += '    <tr BgColor=#FFFF80>'
cMsg += '      <td width="9%"  align="right"><font size="1" color="blue"> IPI: '        + Transform(SF1->F1_VALIPI, "@E 999,999.99") + '</font></td>'
cMsg += '      <td width="9%"  align="right"><font size="1" color="blue"> Desconto: '   + Transform(SF1->F1_DESCONT,"@E 999,999.99") + '</font></td>'
cMsg += '      <td width="9%"  align="right"><font size="1" color="blue"> Frete:    '   + Transform(SF1->F1_FRETE, "@E 999,999.99") + '</font></td>'
cMsg += '      <td width="9%"  align="right"><font size="1" color="blue"> Despesas: '   + Transform(SF1->F1_DESPESA,"@E 999,999.99") + '</font></td>'
cMsg += '      <td width="9%"  align="right"><font size="1" color="blue"> Seguro: '     + Transform(SF1->F1_SEGURO, "@E 999,999.99") + '</font></td>'
cMsg += '      <td width="9%"  align="right"><font size="1" color="blue"> Acre.Forn.: ' + Transform(nTotAcrFor,     "@E 999,999.99") + '</font></td>'
cMsg += '      <td width="9%"  align="right"><font size="1" color="red">  Desc.Forn.: ' + Transform(nTotDesFor,     "@E 999,999.99") + '</font></td>'
cMsg += '      <td width="9%"  align="right"><font size="1" color="blue"> ST: '         + Transform(SF1->F1_ICMSRET,"@E 999,999.99") + '</font></td>'
cMsg += '    </tr>'
cMsg += '</table>'
//-----------------------------------------------------------------------
// Definicao do rodape do email
//-----------------------------------------------------------------------
cMsg += '</Table> <P>'
cMsg += '<table width="100%" border="0" cellspacing="0" cellpadding="0">'
cMsg += '    <tr align="right"><P>'
cMsg += '       <td width="100%" align="right"><font color="red" size="3">Total da NF:     ' + Transform(SF1->F1_VALBRUT,"@E 999,999,999.99") + '</font></td>'
cMsg += '    </tr>'
cMsg += '</table> <P>'
cMsg += '<HR Width=100% Size=4 Align=Centered Color=Red> <P>'
cMsg += '    <table width="100%" Align="Center" border="0">'
cMsg += '       <tr align="center">'
cMsg += '           <td colspan="10"><font color="BLUE" size="2">Mensagem enviada automaticamente pelo sistema PROTHEUS - <font color="BLUE" size="1">(' + cDescRot + ')</td>'
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

If lResult .And. lAutOk
	SEND MAIL FROM cFrom ;
	TO  Lower(cEmailTo);
	CC  Lower(cEmailCc);
	BCC Lower(cEmailBcc);
	SUBJECT 	cAssunto;
	BODY    	cMsg;
	RESULT lResult
	If !lResult
		//Erro no envio do email
		GET MAIL ERROR cError
		MsgInfo(cError,OemToAnsi('AtenÁ„o'))
	EndIf
	DISCONNECT SMTP SERVER
Else
	//Erro na conexao com o SMTP Server
	GET MAIL ERROR cError
	MsgInfo(cError,OemToAnsi('AtenÁ„o'))
EndIf
Return(.T.)

//////////////////////////////////////////////////////////////////////////////////////////////////////
*--------------------------------------------------------------------------*
User Function M100AGRCIC(_cOper)
//MCVN - 07/04/09
*--------------------------------------------------------------------------*
Local lRetorno     := .T.
Local cMail
Local cServidor    := GetMV("MV_CIC")     // Servidor para enviar mensagem pelo CIC
Local cOpFatRem    := GetMV("MV_REMETCI") // Usuario do CIC remetente de mensgens no Protheus
Local cOpFatSenha  := "123456"
Local cOpFatDest   := ""
Local cEmailTo     := ''
Local cCicTo       := ''
Local  cNomeUsu    := ''

// Dados do Destinatario da Mensagem CIC
If _cOper == "SPED"
	cNomeUsu := UsrFullName(RetCodUsr())
	PswOrder(2)
	cCicTo   := PswRet(1)[1][01] // Codigo de usuario protheus  do usuario do financeiro
	cOpFatDest := "MAXIMO.CANUTO,NOTAFISCAL,NOTAFISCAL2,"+U_UFindCic(cCicTo)
Else
	cNomeUsu := UsrFullName(RetCodUsr())
	PswOrder(2)
	cCicTo   := PswRet(1)[1][01] // Codigo de usuario protheus  do usuario do financeiro
	cOpFatDest := AllTrim(GetNewPar("ES_CICSTFO","MAXIMO.CANUTO,MAGDA.TEIXEIRA,SIRLENE.CREATTO,MARCELO.SANTOS,BIANCA.FERREIRA,"))+U_UFindCic(cCicTo)
Endif

If _cOper == "INC"
	// Monta a mensagem a ser enviado ao operador
	cMail := SM0->M0_NOME+"/"+SM0->M0_FILIAL+CR+CR
	cMail += "ICMS-ST FORA DE SP. "+CR+CR
	cMail += "A NF "  +SF1->F1_DOC+" sÈrie  "+SF1->F1_SERIE
	cMail += "  do fornecedor  "+AllTrim(SF1->F1_FORNECE)+" - "+AllTrim(Posicione("SA2",1,xFilial("SA2")+SF1->F1_FORNECE,"A2_NREDUZ"))+CR
	cMail += "Foi emitida e tem ICMS-ST a recolher."+CR+CR
	cMail += "Valor Mercadoria: R$   " +Transform(SF1->F1_VALMERC,"@E 999,999,999.99")+CR
	cMail += "Base Icms-St:     R$   " +Transform(SF1->F1_BRICMS ,"@E 999,999,999.99")+CR
	cMail += "ST a recolher:    R$   " +Transform(SF1->F1_ICMSRET,"@E 999,999,999.99")+CR+CR
	cMail += cNomeUsu+CR
	cMail += " PASSE O FAX DA NFE PARA CONTABILIDADE IMEDIATAMENTE!"
ElseIf _cOper == "NREC"
	// Monta a mensagem a ser enviado ao operador
	cMail := SM0->M0_NOME+"/"+SM0->M0_FILIAL+CR+CR
	cMail += "ICMS-ST FORA DE SP - NAO RECOLHER."+CR+CR
	cMail += "A NF "  +SF1->F1_DOC+" sÈrie  "+SF1->F1_SERIE
	cMail += "  do fornecedor  "+AllTrim(SF1->F1_FORNECE)+" - "+AllTrim(Posicione("SA2",1,xFilial("SA2")+SF1->F1_FORNECE,"A2_NREDUZ"))+CR
	cMail += "Foi emitida e tem ICMS-ST."+CR+CR
	cMail += "Valor Mercadoria: R$   " +Transform(SF1->F1_VALMERC,"@E 999,999,999.99")+CR
	cMail += "Base Icms-St:     R$   " +Transform(SF1->F1_BRICMS ,"@E 999,999,999.99")+CR
	cMail += "ST a recolher:    R$   " +Transform(SF1->F1_ICMSRET,"@E 999,999,999.99")+CR+CR
	cMail += U_DipUsr()
ElseIf _cOper == "EXC"
	// Monta a mensagem a ser enviado ao operador
	cMail := SM0->M0_NOME+"/"+SM0->M0_FILIAL+CR+CR
	cMail += "EXCLUS√O DE NFE COM ICMS-ST FORA DE SP."+CR+CR
	cMail += "A NF "  +SF1->F1_DOC+" sÈrie  "+SF1->F1_SERIE
	cMail += "  do fornecedor  "+AllTrim(SF1->F1_FORNECE)+" - "+AllTrim(Posicione("SA2",1,xFilial("SA2")+SF1->F1_FORNECE,"A2_NREDUZ"))+CR
	cMail += "Foi EXCLUIDA e teve ICMS-ST recolhido."+CR+CR
	cMail += "Valor Mercadoria: R$   " +Transform(SF1->F1_VALMERC,"@E 999,999,999.99")+CR
	cMail += "Base Icms-St:     R$   " +Transform(SF1->F1_BRICMS ,"@E 999,999,999.99")+CR
	cMail += "ST recolhido:    R$   " +Transform(SF1->F1_ICMSRET,"@E 999,999,999.99")+CR+CR
	cMail += U_DipUsr()
ElseIf _cOper == "SPED"
	// Monta a mensagem a ser enviado ao operador
	cMail := SM0->M0_NOME+"/"+SM0->M0_FILIAL+CR+CR
	cMail += "ENTRADA DE NFE COM FORMUL¡RIO PR”PRIO."+CR+CR
	cMail += "A NF "  +SF1->F1_DOC+" sÈrie  "+SF1->F1_SERIE
	cMail += "  do "+If(!SF1->F1_TIPO$"DB","Fornecedor " ,"Cliente  ")+AllTrim(SF1->F1_FORNECE)+" - "+If(!SF1->F1_TIPO$"DB",AllTrim(Posicione("SA2",1,xFilial("SA2")+SF1->F1_FORNECE,"A2_NREDUZ")),AllTrim(Posicione("SA1",1,xFilial("SA1")+SF1->F1_FORNECE,"A1_NREDUZ")))  +CR
	cMail += "Foi lanÁada e precisa ser TRANSMITIDA E IMPRESSA."+CR+CR
	cMail += cNomeUsu+CR
	cMail += " Os Departamentos de Faturamento e GerÍncia do CD receberam este CIC. Favor confirmar se a NFE foi transmitida em 30 minutos! "
Endif


// Envia a mensagem ao operador atravÈs do CIC
U_DIPCIC(cMail,AllTrim(cOpFatDest))// RBorges 12/03/15
//		WaitRun(cServidor+' '+cOpFatRem+' '+cOpFatSenha+' "'+AllTrim(cOpFatDest)+'" "'+cMail+'" ') // Comentada 12/03/15
Return(lRetorno)
/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥MT100AGR  ∫Autor  ≥Microsiga           ∫ Data ≥  07/30/13   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥                                                            ∫±±
±±∫          ≥                                                            ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ AP                                                        ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Static Function DifICMS(cProduto,nICMEnt)
Local aAreaSB1 := SB1->(GetArea())
Local nPICM	   := 0
//DEFAULT cProduto := ""
//DEFAULT nICMEnt  := 0



//A partir de 16/10/2019 n„o ser· mais incluso o diferencial de aliq. de ICMS no B1_CUSDIP - Solicitado pelo Erich/Rodrigo

/* ROTINA DEATIVADA Em 16/10/2019
SB1->(dbSetOrder(1))
If SB1->(dbSeek(xFilial("SB1")+cProduto)) .And. SB1->B1_PICMENT = 0 //Alterado para funcionar apenas para produto sem ST na entrada(22/11/16),  //.And. (SB1->B1_ORIGEM$"1/2/3/8" .Or. SA2->A2_OPTSIMP == '2')
	nPICM := SB1->B1_PICM - nICMEnt
EndIf

If  nPICM < 0 // Tratar erro no cadastro de produtos.
	nPICM := 0
EndIf
*/

RestArea(aAreaSB1)

Return(nPICM)

/*-------------------------------------------------------------------------
+ RBORGES - 28/11/2013 ----- User Funcion:  CMT100AGR()                   +
+ Enviar· CIC quando a nota fiscal n„o atualiza  estoque.                 +
-------------------------------------------------------------------------*/

*--------------------------------------------------------------------------*
Static Function CMT100AGR()
*--------------------------------------------------------------------------*

Local aArea       := GetArea()
Local cDeIc       := Lower(Alltrim(GetMv('MV_RELACNT')))
Local cCICDest    := Upper(GetNewPar("ES_MT100CI","reginaldo.borges")) // Usu·rios que receber„o CIC¥s
Local cAttachIc   :=  "  a"
Local cFuncSentIc :=   " MT100AGR.prw "

dbSelectArea("SM0")

_aMsgIc := {}
cMSGcIC       := 'AVISO - NOTA FISCAL ' +_cNFI+ ' N√O ATUALIZA ESTOQUE! ' +CHR(13)+CHR(10)+CHR(13)+CHR(10)+CHR(13)+CHR(10)

cMSGcIC       += " ATEN«√O! H¡ ITEM NA NOTA FISCAL " +_cNFI+ " QUE N√O  ATUALIZOU ESTOQUE. "   +CHR(13)+CHR(10)
cMSGcIC       += "OPERADOR(A): "+_cUsuar

U_DIPCIC(cMSGcIC,cCICDest)

RestArea(aArea)
return()


/*-----------------------------------------------------------------------------
+ RBORGES Data: 28/11/2013 FunÁ„o: EMT100AGR()                                +
+ Essa funÁ„o enviar· e-mail para os usu·rios contidos no par‚metro,          +
+ quando as nota fiscais n„o atualizarem estoque.                             +
-----------------------------------------------------------------------------*/
*--------------------------------------------------------------------------*
Static Function EMT100AGR()
*--------------------------------------------------------------------------*

Local cDeIc       := Lower(Alltrim(GetMv('MV_RELACNT')))
Local cEmailIc    := GetNewPar("ES_MT100EM","reginaldo.borges@dipromed.com.br")        //Usu·rios que receber„o e-mails
Local cAssuntoIc  := EncodeUTF8("NOTA FISCAL " +_cNFI+ " N√O ATUALIZA ESTOQUE! ","cp1252")
Local cAttachIc   :=  "  a"
Local cFuncSentIc :=   " MT100AGR.prw "

_aMsgIc := {}
cMSGcIC       := "NOTA FISCAL " +_cNFI+ " N√O ATUALIZA ESTOQUE " +CHR(13)+CHR(10)+CHR(13)+CHR(10)

aAdd( _aMsgIc , { "NOTA FISCAL  ", +_cNFI})
aAdd( _aMsgIc , { "ATEN«√O      ", +"H¡ ITEM NA NOTA FISCAL QUE N√O ATUALIZOU ESTOQUE! "})
aAdd( _aMsgIc , { "INCLUIDA POR ", +_cUsuar})

U_UEnvMail(cEmailIc,cAssuntoIc,_aMsgIc,cAttachIc,cDeIc,cFuncSentIc)

return()

/*-------------------------------------------------------------------------
+ RBORGES - 28/11/2013 ----- User Funcion:  CMT100EXC()                   +
+ Enviar· CIC quando a nota fiscal for excluida.                          +
-------------------------------------------------------------------------*/

*--------------------------------------------------------------------------*
Static Function CMT100EXC()
*--------------------------------------------------------------------------*

Local aArea       := GetArea()
Local cDeIc       := Lower(Alltrim(GetMv('MV_RELACNT')))
Local cCICDest    := Upper(GetNewPar("ES_MT100CI","reginaldo.borges")) // Usu·rios que receber„o CIC¥s
Local cAttachIc   :=  "  a"
Local cFuncSentIc :=   " MT100AGR.prw "

dbSelectArea("SM0")

_aMsgIc := {}
cMSGcIC       := 'AVISO - EXCLUS√O DA NOTA FISCAL ' +_cNFE+ '! ' +CHR(13)+CHR(10)+CHR(13)+CHR(10)+CHR(13)+CHR(10)

cMSGcIC       += " ATEN«√O! A NOTA FISCAL " +_cNFE+ " DE ENTRADA FOI EXCLUIDA. "   +CHR(13)+CHR(10)
cMSGcIC       += "OPERADOR(A): "+_cUsuar

U_DIPCIC(cMSGcIC,cCICDest)

RestArea(aArea)
return()

/*-----------------------------------------------------------------------------
+ RBORGES Data: 28/11/2013 FunÁ„o: EMT100EXC()                                +
+ Essa funÁ„o enviar· e-mail para os usu·rios contidos no par‚metro,          +
+ quando a nota fiscal for excluida.                                          +
-----------------------------------------------------------------------------*/
*--------------------------------------------------------------------------*
Static Function EMT100EXC()
*--------------------------------------------------------------------------*

Local cDeIc       := Lower(Alltrim(GetMv('MV_RELACNT')))
Local cEmailIc    := GetNewPar("ES_MT100EM","reginaldo.borges@dipromed.com.br")        //Usu·rios que receber„o e-mails
Local cAssuntoIc  := EncodeUTF8("AVISO - EXCLUS√O DA NOTA FISCAL " +_cNFE+ "! ","cp1252")
Local cAttachIc   :=  "  a"
Local cFuncSentIc :=   " MT100AGR.prw "

_aMsgIc := {}
cMSGcIC       := "AVISO - EXCLUS√O DA NOTA FISCAL" +_cNFE+ " " +CHR(13)+CHR(10)+CHR(13)+CHR(10)

aAdd( _aMsgIc , { "NOTA FISCAL  ", +_cNFE})
aAdd( _aMsgIc , { "ATEN«√O      ", +"ATEN«√O! ESSA NOTA FISCAL DE ENTRADA FOI EXCLUIDA. "})
aAdd( _aMsgIc , { "EXCLUIDA POR ", +_cUsuar})


U_UEnvMail(cEmailIc,cAssuntoIc,_aMsgIc,cAttachIc,cDeIc,cFuncSentIc)

return()  

		
/*-----------------------------------------------------------------------------
+ RBORGES Data: 27/04/2015 FunÁ„o: xCompImp()                                 +
+ Essa funÁ„o ser· utilizada para carregar os complementos de importacao      +
+ da nota fiscal de entrada de acordo com as informaÁıes do usu·rio e as      +
+ e as informaÁıes retornadas pela query.                                     + 
-----------------------------------------------------------------------------*/		

User Function xCompImp()

Local     aAreaOld   := GetArea()
Local     cCodFab    := cCodExp:= SF1->F1_FORNECE
Local     dDatDesemb := dDatDI := dDataCof := dDataPis := CTOD(" / / ")
Local     cNumDI     := Space(12)
Local     cUfDesemb  := Space(2)
Local     cDescLocal := Space(30)
Local     lContinua  := .F.


DEFINE MSDIALOG oDlg1 TITLE OemToAnsi("InformaÁıes sobre a DI de ImportaÁ„o!") From 000,000 to 420,500 of oMainWnd PIXEL

@ 005,005 To 195,248 Of oDlg1 Pixel
@ 017,015 Say "Data Pgto Pis" of oDlg1 Pixel
@ 015,075 Msget dDataPis Size 040,11 of oDlg1 Pixel
@ 032,015 Say "Data Pgto Cofins" of oDlg1 Pixel
@ 030,075 Msget dDataCof Size 040,11 of oDlg1 Pixel
@ 047,015 Say "N˙mero da DI" of oDlg1 Pixel
@ 045,075 Msget cNumDI Size 050,11 Picture X3Picture("CD5_NDI") of oDlg1 Pixel
@ 062,015 Say "Data Registro DI" of oDlg1 Pixel
@ 060,075 Msget dDatDI Size 40,11 of oDlg1 Pixel
@ 077,015 Say "DescriÁ„o Local" of oDlg1 Pixel
@ 075,075 Msget cDescLocal Size 70,11 Picture X3Picture("CD5_LOCDES") of oDlg1 Pixel
@ 092,015 Say "UF DesembaraÁo" of oDlg1 Pixel
@ 090,075 Msget cUfDesemb Size 20,11 Picture '@!' of oDlg1 Pixel
@ 107,015 Say "Data DesembaraÁo" of oDlg1 Pixel
@ 105,075 Msget dDatDesemb Size 40,11 of oDlg1 Pixel
@ 122,015 Say "CÛd.Exportador" of oDlg1 Pixel
@ 120,075 Msget cCodExp Size 50,11 F3 "SA2" of oDlg1 Pixel
@ 137,015 Say "CÛd.Fabricante" of oDlg1 Pixel
@ 135,075 Msget cCodFab Size 50,11 F3 "SA2" of oDlg1 Pixel              

@ 197,050 BUTTON "&Confirma" of oDlg1 pixel SIZE 60,12 ACTION (lContinua := .T., oDlg1:End())
//@ 197,120 BUTTON "&Cancela"  of oDlg1 pixel SIZE 60,12 ACTION (oDlg1:End())

ACTIVATE MSDIALOG oDlg1 CENTERED
If lContinua
	
	cQry := "SELECT D1_DOC,D1_SERIE,D1_FORNECE,D1_LOJA,D1_ITEM,D1_BASIMP6,D1_ALQIMP6,D1_VALIMP6,"
	cQry += "       D1_BASIMP5,D1_ALQIMP5,D1_VALIMP5 "
	cQry += " FROM "+RetSqlName("SD1") + " D1 "
	cQry += " WHERE D_E_L_E_T_ = ' ' "
	cQry += "   AND D1_LOJA = '"+SF1->F1_LOJA+"' "
	cQry += "   AND D1_FORNECE = '"+SF1->F1_FORNECE+"' "
	cQry += "   AND D1_SERIE = '"+SF1->F1_SERIE+"' "
	cQry += "   AND D1_DOC = '"+SF1->F1_DOC+"' "
	cQry += "   AND D1_FILIAL = '"+xFilial("SD1")+"' "
	
	TCQUERY cQry NEW ALIAS "QSD1"
	
	While !Eof()
		DbSelectArea("CD5")
		DbSetOrder(4) //CD5_FILIAL, CD5_DOC, CD5_SERIE, CD5_FORNEC, CD5_LOJA, CD5_ITEM
		If DbSeek(xFilial("CD5")+QSD1->D1_DOC+QSD1->D1_SERIE+QSD1->D1_FORNECE+QSD1->D1_LOJA+QSD1->D1_ITEM)
			RecLock("CD5",.F.)
		Else
			RecLock("CD5",.T.)
		Endif
		
		CD5->CD5_NDI      := cNumDI
		CD5->CD5_DTDI     := dDatDI
		CD5->CD5_LOCDES   := cDescLocal
		CD5->CD5_UFDES    := cUfDesemb
		CD5->CD5_DTDES    := dDatDesemb
		CD5->CD5_FILIAL   := xFilial("CD5")
		CD5->CD5_SERIE    := QSD1->D1_SERIE
		CD5->CD5_FORNEC   := QSD1->D1_FORNECE
		CD5->CD5_LOJA     := QSD1->D1_LOJA
		CD5->CD5_TPIMP    := '0'
		CD5->CD5_BSPIS    := QSD1->D1_BASIMP6
		CD5->CD5_ALPIS    := QSD1->D1_ALQIMP6
		CD5->CD5_VLPIS    := QSD1->D1_VALIMP6
		CD5->CD5_BSCOF    := QSD1->D1_BASIMP5
		CD5->CD5_ALCOF    := QSD1->D1_ALQIMP5
		CD5->CD5_VLCOF    := QSD1->D1_VALIMP5
		CD5->CD5_DOC      := QSD1->D1_DOC
		CD5->CD5_DOCIMP   := QSD1->D1_DOC
		CD5->CD5_CODFAB   := cCodFab
		CD5->CD5_LOJFAB   := QSD1->D1_LOJA
		CD5->CD5_DTPPIS   := dDataPis
		CD5->CD5_DTPCOF   := dDataCof
		CD5->CD5_LOCAL    := '0'
		CD5->CD5_CODEXP   := cCodExp
		CD5->CD5_LOJEXP   := QSD1->D1_LOJA
		CD5->CD5_ITEM     := QSD1->D1_ITEM
		CD5->CD5_VTRANS   := '1'
		CD5->CD5_INTERM   := '1'                                 		
		CD5->CD5_CNPJAE   := Iif(cEmpAnt == '01','47869078000453','05150878000127')
		CD5->CD5_UFTERC   := 'SP'
		MsUnlock()
		
		DbSelectArea("QSD1")
		QSD1->(DbSkip())
	Enddo
	QSD1->(dbCloseArea())
Endif

RestArea(aAreaOld)

Return 

/*------------------------------------------------------------------------+
+ Funcao:EMaiClaQ() | Autor: Reginaldo Borges|      Data: 23/03/16        +                                                     
+ Far· tratamento para enviar E-mail dos produtos que na classificaÁ„o    +
+ e entrada das notas fiscais tiverem como destino o estoque 06.          +
+ ESPECÕFICO:Qualidade												      +
-------------------------------------------------------------------------*/

User Function EMaiClaQ()

Local cAccount  := Lower(Alltrim(GetMv("MV_RELACNT")))
Local cFrom     := Lower(Alltrim(GetMv('MV_RELACNT')))
Local cPassword := Alltrim(GetMv("MV_RELPSW"))
Local cServer   := Alltrim(GetMv("MV_RELSERV"))
Local cMail     := ""
Local cEmailTo  := ""
Local cEmailCc  := ""
Local cEmailBcc := ""
Local lResult   := .F.
Local cError    := ""
Local cMsg      := ""
Local nI
Local lSmtpAuth := GetNewPar("MV_RELAUTQ",.F.)
Local lAutOk	:= .F.
Local aCampos   := {}
Local _cProd    := ""

cQRY := "SELECT D1_DOC, D1_COD, D1_QUANT, D1_LOTECTL, D1_LOCAL "
cQRY += " FROM "+RetSqlName("SD1")
cQRY += " WHERE D1_FILIAL  = '"+xFilial("SD1")+"' "
cQRY += " AND   D1_DOC     = '"+SF1->F1_DOC+"' "
cQRY += " AND   D1_SERIE   = '"+SF1->F1_SERIE+"' "
cQRY += " AND   D1_FORNECE = '"+SF1->F1_FORNECE+"' "
cQRY += " AND   D1_LOJA    = '"+SF1->F1_LOJA+"' "
cQRY += " AND   D_E_L_E_T_ = '' "

cQRY := ChangeQuery(cQRY)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQRY),"cQRY",.T.,.T.)

While cQRY->(!Eof())
	
	_cProd := Posicione("SB1",1,xFilial("SB1")+cQRY->D1_COD,"B1_DESC")
	
	If cQRY->D1_LOCAL == "06"
		aadd(aCampos,{cQRY->D1_DOC,cQRY->D1_COD,_cProd,cQRY->D1_QUANT,cQRY->D1_LOTECTL,cQRY->D1_LOCAL,SF1->F1_USUARIO,SF1->F1_OBS})
	EndIf
	
	cQRY->(DbSkip())
	
EndDo

If Len(aCampos) > 0 
	 
    CIClaQ(aCampos[1,1],aCampos[1,7])   // RBORGES - 23/03/2016 - Chama a funÁ„o do CIC para NF¥s com itens para o local 06
	
	cEmail := GetNewPar("ES_EMTRAQ","reginaldo.borges@dipromed.com.br;qualidade@dipromed.com.br")
	cAssunto:= EncodeUTF8('TRANSFER NCIA PARA O LOCAL '+aCampos[1,6]+' - DOCUMENTO: ' + SF1->F1_DOC +" - "+AllTrim(SM0->M0_NOME)+"/"+AllTrim(SM0->M0_FILIAL),"cp1252")
	
	/*=============================================================================*/
	/*Definicao do cabecalho do email                                              */
	/*=============================================================================*/
	cMsg := ""
	cMsg += '<html>'
	cMsg += '<head>'
	cMsg += '<title>' + cAssunto + '</title>'
	cMsg += '</head>'
	cMsg += '<body>'
	cMsg += '<HR Width=100% Size=3 Align=Centered Color=Red> <P>'
	cMsg += '<Table Align=Center BorderColor=#000000 CELLPADDING=4 CELLSPACING=0 Width=100%>'
	
	/*=============================================================================*/
	/*Definicao do cabecalho do relatÛrio                                          */
	/*=============================================================================*/
	
	cMsg += '<table width="100%">'
	cMsg += '<tr>'
	cMsg += '<td width="100%" colspan="2"><font size="4" color="red">Documento - ' + aCampos[1,1] + '</font></td>'
	cMsg += '</tr>'
	cMsg += '<tr>'
	cMsg += '</tr>'
	cMsg += '</table>'
	
	cMsg += '<table width="100%" cellspacing="0" cellpadding="0"><font size="2" color="blue">'
	cMsg += '<tr>'
	cMsg += '<td>==========================================================================================================================================================================================</td>'
	cMsg += '</tr>'
	cMsg += '</font></table>'
	
	cMsg += '<table width="100%" cellspacing="0" cellpadding="0"><font size="2" color="blue">'
	cMsg += '<td width="10%">Produto</td>'
	cMsg += '<td width="50%">Descricao</td>'
	cMsg += '<td width="10%">Quantidade</td>'
	cMsg += '<td width="10%">Lote</td>'
	cMsg += '<td width="10%">Local Dest.</td>'
	cMsg += '<td width="10%">Usuario</td>'
	cMsg += '</tr>'
	cMsg += '</font></table>'
	
	cMsg += '<table width="100%" cellspacing="0" cellpadding="0"><font size="2" color="blue">'
	cMsg += '<tr>'
	cMsg += '<td>==========================================================================================================================================================================================</td>'
	cMsg += '</tr>'
	cMsg += '</font></table>'
	
	/*=============================================================================*/
	/*Definicao do texto/detalhe do email                                          */
	/*=============================================================================*/
	
	For nI := 1 to Len(aCampos)
		nLin:= nI
		If Mod(nLin,2) == 0
			cMsg += '<table width="100%" border="0" cellspacing="0" cellpadding="0">'
			cMsg += '<tr bgcolor="#B0E2FF">'
			cMsg += '<td width="10%"><font size="2">' +aCampos[nLin,2]+ '</font></td>'
			cMsg += '<td width="50%"><font size="2">' +aCampos[nLin,3]+ '</font></td>'
			cMsg += '<td width="10%"><font size="2">' +cValToChar(aCampos[nLin,4])+ '</font></td>'
			cMsg += '<td width="10%"><font size="2">' +aCampos[nLin,5]+ '</font></td>'
			cMsg += '<td width="10%"><font size="2">' +aCampos[nLin,6]+ '</font></td>'
			cMsg += '<td width="10%"><font size="2">' +Upper(aCampos[nLin,7])+ '</font></td>'
			cMsg += '</tr>'   
			cMsg += '</table>'			
			cMsg += '<table width="100%" border="0" cellspacing="0" cellpadding="0">'			
			cMsg += '<tr>'
			cMsg += '<td width="10%"><font size="2">ObservaÁ„o</font></td>'
			cMsg += '<td width="90%"><font size="2">' +aCampos[nLin,8]+ '</font></td>'
			cMsg += '</tr>'									
			cMsg += '</table>'
		Else
			cMsg += '<table width="100%" border="0" cellspacing="0" cellpadding="0">'
			cMsg += '<tr bgcolor="#c0c0c0">'
			cMsg += '<td width="10%"><font size="2">' +aCampos[nLin,2]+ '</font></td>'
			cMsg += '<td width="50%"><font size="2">' +aCampos[nLin,3]+ '</font></td>'
			cMsg += '<td width="10%"><font size="2">' +cValToChar(aCampos[nLin,4])+ '</font></td>'
			cMsg += '<td width="10%"><font size="2">' +aCampos[nLin,5]+ '</font></td>'
			cMsg += '<td width="10%"><font size="2">' +aCampos[nLin,6]+ '</font></td>'
			cMsg += '<td width="10%"><font size="2">' +Upper(aCampos[nLin,7])+ '</font></td>'
			cMsg += '</tr>'
			cMsg += '</table>'
			cMsg += '<table width="100%" border="0" cellspacing="0" cellpadding="0">'			
			cMsg += '<tr>'
			cMsg += '<td width="10%"><font size="2">OBSERVA«√O:</font></td>'
			cMsg += '<td width="90%"><font size="2">' +aCampos[nLin,8]+ '</font></td>'
			cMsg += '</tr>'									
			cMsg += '</table>'
			
		EndIf
	Next
	
	//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
	//≥ Definicao do rodape do email                                                ≥
	//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
	cMsg += '</Table>'
	cMsg += '<HR Width=100% Size=3 Align=Centered Color=Red> <P>'
	cMsg += '<table width="100%" Align="Center" border="0">'
	cMsg += '<tr align="center">'
	cMsg += '<td colspan="10"><font color="BLUE" size="2">Mensagem enviada automaticamente pelo sistema PROTHEUS - <font color="BLUE" size="1">(MT100AGR.PRW)</td>'
	cMsg += '</tr>'
	cMsg += '</table>'
	cMsg += '</body>'
	cMsg += '</html>'
	
	//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
	//≥Envia o mail para a lista selecionada. Envia como BCC para que a pessoa pense≥
	//≥que somente ela recebeu aquele email, tornando o email mais personalizado.   ≥
	//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
	IF At(";",cEmail) > 0
		cEmailTo := SubStr(cEmail,1,At(";",cEmail)-1)
		cEmailCc := SubStr(cEmail,At(";",cEmail)+1,Len(cEmail))
	Else
		cEmailTo := Alltrim(cEmail)
	EndIF
	
	CONNECT SMTP SERVER cServer ACCOUNT cAccount PASSWORD cPassword RESULT lResult
	
	If !lAutOk
		If ( lSmtpAuth )
			lAutOk := MailAuth(cAccount,cPassword)
		Else
			lAutOk := .T.
		EndIf
	EndIf
	
	If lResult .And. lAutOk
		SEND MAIL FROM cFrom ;
		TO      	Lower(cEmailTo);
		CC      	Lower(cEmailCc);
		BCC     	Lower(cEmailBcc);
		SUBJECT 	cAssunto;
		BODY    	cMsg;
		RESULT lResult
		
		If !lResult
			//Erro no envio do email
			GET MAIL ERROR cError
			
			MsgInfo(cError,OemToAnsi("AtenÁ„o"))
		EndIf
		
		DISCONNECT SMTP SERVER
	Else
		//Erro na conexao com o SMTP Server
		GET MAIL ERROR cError
		MsgInfo(cError,OemToAnsi("AtenÁ„o"))
	EndIf
	
EndIf

cQRY->(dbCloseArea())

Return(.T.)                   


/*------------------------------------------------------------------------+
+ Funcao:  CIClaQ()| Autor: Reginaldo Borges  |     Data: 02/03/16        +                                                     
+ Sera disparado um CIC quando o produto classifado for para o local 06   +
+ ESPECIFICO: Qualidade													  +
-------------------------------------------------------------------------*/

*--------------------------------------------------------------------------*
Static Function CIClaQ(_cDoc,_cUser)
*--------------------------------------------------------------------------*
	
	Local aArea       := GetArea()
	Local cDeIc       := Lower(Alltrim(GetMv('MV_RELACNT')))
    Local cCICDest    := Upper(GetNewPar("ES_CIC_TQ","REGINALDO.BORGES,RAFAELA.BEAZIN"))
	Local cAttachIc   :=  "  a"
	Local cFuncSentIc :=   "MT100AGR.PRW "
 	
		dbSelectArea("SM0")
		
	_aMsgIc := {}
	cMSGcIC       := " EMPRESA:__ " + Capital( AllTrim( GetAdvFVal( "SM0", "M0_NOME", cEmpAnt + cFilAnt, 1, "" ) ) ) +"/"+ Capital( AllTrim( GetAdvFVal( "SM0", "M0_FILIAL" , cEmpAnt + cFilAnt, 1, "" ) ) )   +CHR(13)+CHR(10)+CHR(13)+CHR(10)
    cMSGcIC       += "PRODUTO CLASSIFICADO PARA O 06 - VERIFICAR E-MAIL!"	+CHR(13)+CHR(10)+CHR(13)+CHR(10)
	cMSGcIC       += " DOCUMENTO:  " +_cDoc +" - "+ " OPERADOR.: " +Upper(_cUser) 
                        	
   	U_DIPCIC(cMSGcIC,cCICDest)
   	  		
    RestArea(aArea)	

Return() 

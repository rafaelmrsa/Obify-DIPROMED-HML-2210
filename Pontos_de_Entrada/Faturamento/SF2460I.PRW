/*====================================================================================\
|Programa  | MATA460       | Autor | Eriberto Elias             | Data | 10/01/02     |
|=====================================================================================|
|Ponto Ent | SF2460I                                                                  |
|=====================================================================================|
|Descrição | Este P.E. é executado após a atualização de todos os arquivos.           |
|          | Este P.E. esta localizado na função                                      |
|          | A460GERAF2(Gera Registros em SF2 e acumula valores)                      |
|=====================================================================================|
|Parâmetros| Nenhum                                                                   |
|=====================================================================================|
|Retorno   | Nenhum                                                                   |
|=====================================================================================|
|Observ.   | Nenhum                                                                   |
|=====================================================================================|
|Sintaxe   | SF2460I                                                                  |
|=====================================================================================|
|Uso       | Especifico DIPROMED                                                      |
|=====================================================================================|
|........................................Histórico....................................|
|Rafael    | 30/07/04 - Identificação de TES e envio de e-mail das TES <> 501 e 533   |
|Rafael    | 12/01/05 - Envio de e-mail para substituição tributária                  |
|Rafael    | 04/02/05 - Ajuste no arredondamento da despesa (Linha 424)               |
|Rafael    | 14/02/05 - Adicionar o telefone do cliente no e-mail de confirmação      |
|Rafael    | 21/02/05 - Ajustar cliente(SA1) p/ fornecedor(SA2) no e-mail confirmação |
|Maximo    | 10/01/07 - Inclui rotina para impressão das Etiquetas da Braspress       |
|Maximo    | 27/04/07 - Incluir tela para incluir o separador                         |
|Maximo    | 10/10/08 - Incluir rotina para enviar e-mail qdo Tipo = Devol. Compras   |
|Maximo    | 29/10/08 - Alterado valor recebido pelo pelo campo D2_CUSDIP             |
|Maximo    | 30/05/09 - Incluído rotina p/ alteração de transportadora e tipo de frete|
\====================================================================================*/
                    
#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#Include "Ap5Mail.ch"

User Function SF2460I()

Local _xAlias      := GetArea()
Local _xAliasSD2   := SD2->(GetArea())
Local _xAliasSUA   := SUA->(GetArea())
Local _xAliasSC5   := SC5->(GetArea())
Local _xAliasSF2   := SF2->(GetArea())
Local _aAreaSE1    := SE1->(GetArea())
Local _nPesoLi     := 0
Local _cEdital     := ""
Local _cMunE       := ""
Local _cEstE       := ""
Local _aAuxTel     := {}
Local _cZerComis   := GetMV("MV_ZERACOM") // MCVN - 07/07/10 
Local _cTranAnt    := SC5->C5_TRANSP  //Giovani Zago 26/03/2012
Local _cTipFreAnt  := SC5->C5_TPFRETE  //Giovani Zago 26/03/2012
Local _aDocDev     := {}
Local _cPedQbg     := GetNewPar("ES_QBGD56","")
Private lAltTransp := .F.   

If "MATA310"$Upper(FunName())
	RestArea(_xAliasSF2)
	RestArea(_aAreaSE1)
	RestArea(_xAliasSC5)
	RestArea(_xAliasSUA)
	RestArea(_xAliasSD2)
	RestArea(_xAlias)
	Return
EndIf

U_DIPPROC(ProcName(0),U_DipUsr()) // JBS 05/10/2005 - Gravando o nome do Programa no SZU

If SA1->A1_MSALDO > SA1->A1_XMSALD
	SA1->(RecLock("SA1",.F.))
		SA1->A1_XMSALD := SA1->A1_MSALDO
		SA1->A1_XDMSAL := dDataBase
	SA1->(MsUnlock())
EndIf

DbSelectArea("SC5")
DbSetOrder(1)
IF SC5->(DbSeek(xFilial("SC5")+If(Type("lDIPA039") <> "U",SD2->D2_PEDIDO,SC9->C9_PEDIDO)))
	_cEdital := SC5->C5_EDITAL
	_cMunE   := SC5->C5_MUNE
	_cEstE   := SC5->C5_ESTE
	Reclock("SC5",.F.)
	SC5->C5_PRENOTA := " "
	SC5->(MsUnLock())
	SC5->(DbCommit())  // Eriberto 24/04/07
EndIF
           

DbSelectArea("SD2")
DbSetOrder(3)
DbSeek(xFilial("SD2")+SF2->F2_DOC+SF2->F2_SERIE)
While SD2->(!Eof()) .AND. xFilial("SD2") == SD2->D2_FILIAL .AND. SD2->D2_DOC == SF2->F2_DOC .AND. SD2->D2_SERIE == SF2->F2_SERIE
	DbSelectArea("SB1")
	DbSetOrder(1)
	IF DbSeek(xFilial("SB1")+SD2->D2_COD)
		RecLock("SD2",.F.)
		SD2->D2_FORNEC := SB1->B1_PROC
		SD2->D2_CUSDIP := u_DipAtuCus(SB1->B1_CUSDIP)   // MCVN - 02/04/09
		If SF2->F2_VEND1 $ _cZerComis // Zera a comissão dos vendedores contidos no parâmetro MV_ZERACOM  -  MCVN - 07/07/10
			SD2->D2_COMIS1 := 0
		Endif    
		
		If SB1->B1_PROC == '000996' .And. SD2->D2_COMIS2 > 0 
			SD2->D2_COMIS1 := 0 //Zera comissao do item para o vendedor 1 quando o produto for steri pack e tiver vendedor 2 - 17/10/2013
		EndIf
			     
		If SD2->(FieldPos("D2_PRV1")) > 0
			SD2->D2_PRV1	:= SB1->B1_PRV1
			SD2->D2_PRVSUPE	:= SB1->B1_PRVSUPE
			SD2->D2_PRVMINI	:= SB1->B1_PRVMINI
			SD2->D2_PRVPROM	:= SB1->B1_PRVPROM
			SD2->D2_UPRC	:= SB1->B1_UPRC
			SD2->D2_LISFOR	:= u_DipAtuCus(SB1->B1_LISFOR)
		EndIf                                           
	
		If SD2->(FieldPos("D2_XICMRET")) > 0
			SD2->D2_XICMRET := SB1->B1_PICMRET
		EndIf
		
		//Utilizado na geração de nota entre empresas SPED
		If SD2->D2_TIPO == 'D' .And. SD2->D2_CLIENTE == '990064' .And. SD2->D2_LOJA = '01'  
			If SD2->D2_PEDIDO $ _cPedQbg
				_aDocDev := U_fNfOri56()
				SD2->D2_NFORI   := _aDocDev[1][1] 
				SD2->D2_SERIORI := _aDocDev[1][2] 
				SD2->D2_ITEMORI := _aDocDev[1][3] 
				U_AjustaSD256(_aDocDev)
			Endif
		Endif
		
		SD2->(MsUnLock())
	ENDIF
	
	_nPesoLi   := _nPesoLi + (SD2->D2_QUANT * SB1->B1_PESO)
	
	SD2->(DbSkip())
End

If (Type("lDIPA039") <> "U" .OR. ("DIPA012" $ FUNNAME())) // MCVN - 26/08/09
	SD2->(dbSeek(xFilial("SD2")+SF2->F2_DOC+SF2->F2_SERIE))
Endif

If ( !Alltrim(FUNNAME()) == "TMSA200" ) .and. ( !Alltrim(FUNNAME()) == "TMSAE75" ) // Não entra se a rotina for chamada pelo TMS  - MCVN 01/12/2008
	
	//-- DL - 09/02/2010 - a Tela foi movida para fora da transação (PE M460NUM)
	_aAuxTel := U_TelSepar()
	
	_cSeparo 	:= _aAuxTel[1]
	_cConfir 	:= _aAuxTel[2]
	_nVolume 	:= _aAuxTel[3]
	_cTransp 	:= _aAuxTel[4]
	_cLocExp 	:= _aAuxTel[5]
	_cTpFrete	:= _aAuxTel[6]
	lAltTransp	:= _aAuxTel[7]
	//-- DL - 09/02/2010 - Fim
	
	Dbselectarea("SF2")
	RecLock("SF2",.F.)
	F2_SEPAROU := _cSeparo
	F2_CONFERI := _cConfir
	F2_ESPECI1 := 'CX' // MCVN - 26/03/10
	F2_NFFORM  := '0000000000000' // MCVN - 05/04/10
	F2_VOLUME1 := _nVolume
	F2_PLIQUI  := _nPesoLi
	F2_PBRUTO  := _nPesoLi 
	F2_TPFRETE := SC5->C5_TPFRETE
	F2_LOCEXP  := _cLocExp
	If lAltTransp // MCVN - 30/05/09
		F2_TRANSP  := _cTransp
		F2_TPFRETE := _cTpFrete
	Endif
	
	//Giovani Zago
	If	!(SF2->F2_TIPO $ "D/B")
		SF2->F2_XTECNIC :=  SA1->A1_TECNICO
		SF2->F2_XTEC_AM :=  SA1->A1_TECN_A
		SF2->F2_XTEC_3M :=  SA1->A1_TECN_3
		SF2->F2_XTEC_RO :=  SA1->A1_TECN_R
		SF2->F2_XTEC_CO :=  SA1->A1_TECN_C
		SF2->F2_XTEC_HQ :=  SA1->A1_XTEC_HQ
		SF2->F2_XTEC_MA :=  SA1->A1_XTEC_MA
		SF2->F2_XTEC_SP :=  SA1->A1_XTEC_SP
		SF2->F2_XTEC_BB :=  SA1->A1_TECN_B
		SF2->F2_XGRPVEN :=  SA1->A1_GRPVEN 
	EndIf                                          
	
	
	SF2->(MsUnlock())
	SF2->(DbCommit())
	
	
	
	If lAltTransp // MCVN - 30/05/09
		
		// Atualiza SUA - MCVN - 30/05/09
		DbSelectArea("SUA")
		DbSetOrder(8)
		IF DbSeek(xFilial("SUA")+If(Type("lDIPA039") <> "U",SD2->D2_PEDIDO,SC9->C9_PEDIDO))
			RecLock("SUA",.F.)
			Replace UA_TRANSP  With _cTransp
			Replace UA_TPFRETE With _cTpFrete
			SUA->(MsUnLock())
		EndIF
		
		//Atualiza SUB - MCVN - 30/05/09
		DbSelectArea("SC5")
		DbSetOrder(1)
		IF DbSeek(xFilial("SC5")+If(Type("lDIPA039") <> "U",SD2->D2_PEDIDO,SC9->C9_PEDIDO))
			RecLock("SC5",.F.)
			Replace C5_TRANSP  With _cTransp
			Replace C5_TPFRETE With _cTpFrete
			SC5->(MsUnLock())
		EndIF
	Endif
	
	//------------------------------------------
	// Registrando a ocorrencia na Ficha Kardex (Expedição)
	//------------------------------------------   
	U_DiprKardex(SC5->C5_NUM,U_DipUsr(),Alltrim(_cSeparo)+"-"+Alltrim(_cConfir)+"-"+Alltrim(_cLocExp)+"-"+Alltrim(Str(_nVolume))+"-"+Alltrim(_cTranAnt)+"-"+Alltrim(_cTipFreAnt)+"-SF2460i - A ",.T.,"42")//Giovani Zago 26/03/2012
	
	U_DiprKardex(SC5->C5_NUM,U_DipUsr(),Alltrim(_cSeparo)+"-"+Alltrim(_cConfir)+"-"+Alltrim(_cLocExp)+"-"+Alltrim(Str(_nVolume))+"-"+Alltrim(_cTransp)+"-"+Alltrim(_cTpFrete)+"-SF2460i - D",.T.,"42")
	
	
Endif "(!TMS)"
RestArea(_aAreaSE1)

// Gravando nota fiscal no Edital se o pedido foi gerado pelo Licitação  MCVN - 04/10/2007
If !Empty(Alltrim(_cEdital))
	DbSelectArea("UA1")
	DbSetOrder(1)
	IF UA1->(DbSeek(xFilial("UA1")+_cEdital))
		Reclock("UA1",.F.)
		UA1->UA1_NFISCA := SF2->F2_DOC
		UA1->UA1_SERIE  := SF2->F2_SERIE
		UA1->(MsUnLock())
		UA1->(DbCommit())
	EndIF
Endif

//------------------------------------------
//-- DL 23/02/2010 - Funcionalidades movidas (do PE M460FIM) para dentro da transação
//------------------------------------------
If !("TMSA200" $ FUNNAME()) // Não entra se a rotina for chamada pelo TMS  - MCVN 01/12/2008
	SC5->(RecLock("SC5",.F.))
	SC5->C5_FRETE := SC5->C5_FLAGFRE
	SC5->C5_FLAGFRE := 0
	SC5->(MsUnLock("SC5"))
	
	// Eriberto 28/04/06
	SUA->(DbSetOrder(8))
	If SUA->(DbSeek(xFilial("SUA")+SC5->C5_NUM))
		SUA->(RecLock("SUA",.F.))
		SUA->UA_DOC    := SF2->F2_DOC
		SUA->UA_SERIE  := SF2->F2_SERIE
		SUA->UA_EMISNF := SF2->F2_EMISSAO
		SUA->UA_STATUS := "NF."
		SUA->(MsUnLock("SUA"))
	EndIf
EndIf

If "DIPA012" $ Funname() .OR. Type("lDIPA039") <> "U"
	//	WHILE SE1->(!EOF()) .AND. xFILIAL("SE1") == SE1->E1_FILIAL .AND. SE1->E1_PREFIXO == SF2->F2_SERIE .AND. SE1->E1_NUM == SF2->F2_DOC
	WHILE SE1->(!EOF()) .AND. xFILIAL("SE1") == SE1->E1_FILIAL .AND. SE1->E1_PREFIXO == SF2->F2_PREFIXO .AND. SE1->E1_NUM == SF2->F2_DOC // Alterado F2_SERIE por F2_PREFIXO MCVN - 07-06-11
		SE1->(RecLock("SE1",.F.))
		SE1->E1_NOMCLI := SUBSTR(SA1->A1_NOME,1,60)
		SE1->E1_MUNC   := SA1->A1_MUN	//IIF(LEN(ALLTRIM(SA1->A1_MUNC))==0,SA1->A1_MUN,SA1->A1_MUNC)
		SE1->(MsUnLock("SE1"))
		SE1->(DbSkip())
	EndDo
ElseIf !("TMSA200" $ FUNNAME())
	//	WHILE SE1->(!BOF()) .AND. xFILIAL("SE1") == SE1->E1_FILIAL .AND. SE1->E1_PREFIXO == SF2->F2_SERIE .AND. SE1->E1_NUM == SF2->F2_DOC// Alterado F2_SERIE por F2_PREFIXO MCVN - 07-06-11
	WHILE SE1->(!BOF()) .AND. xFILIAL("SE1") == SE1->E1_FILIAL .AND. SE1->E1_PREFIXO == SF2->F2_PREFIXO .AND. SE1->E1_NUM == SF2->F2_DOC// Alterado F2_SERIE por F2_PREFIXO MCVN - 07-06-11
		SE1->(RecLock("SE1",.F.))
		SE1->E1_NOMCLI := SUBSTR(SA1->A1_NOME,1,60)
		SE1->E1_MUNC   := SA1->A1_MUN	//IIF(LEN(ALLTRIM(SA1->A1_MUNC))==0,SA1->A1_MUN,SA1->A1_MUNC)
		SE1->(MsUnLock("SE1"))
		SE1->(DbSkip(-1))
	EndDo
Endif
//------------------------------------------
// Registrando a ocorrencia na Ficha Kardex
//------------------------------------------
If !("TMSA200" $ FUNNAME())
	U_DiprKardex(SC5->C5_NUM,U_DipUsr(),"NF "+SF2->F2_DOC,.T.,"17") // JBS 26/08/2005
EndIf

If "DIPA012" $ Funname() .OR.  Type("lDIPA039") <> "U"
	Do While SZ9->(!BOF()) .and. SC5->C5_NUM == SZ9->Z9_PEDIDO
		If SZ9->Z9_OCORREN == '19' //IMPRES PRE-NOTA     JBS 26/08/2005
			SF2->(RecLock("SF2",.F.))
			SF2->F2_HORAPRE := SZ9->Z9_HORAMOV
			SF2->(MsUnLock("SF2"))
			Exit
		EndIf
		SZ9->(DbSkip())
	EndDo
ElseIf !("TMSA200" $ FUNNAME())
	Do While SZ9->(!BOF()) .and. SC5->C5_NUM == SZ9->Z9_PEDIDO
		If SZ9->Z9_OCORREN == '19' //IMPRES PRE-NOTA     JBS 26/08/2005
			SF2->(RecLock("SF2",.F.))
			SF2->F2_HORAPRE := SZ9->Z9_HORAMOV
			SF2->(MsUnLock("SF2"))
			Exit
		EndIf
		SZ9->(DbSkip(-1))
	EndDo
Endif

RestArea(_xAliasSF2)
RestArea(_aAreaSE1)
RestArea(_xAliasSC5)
RestArea(_xAliasSUA)
RestArea(_xAliasSD2)

//------------------------------------------
//-- DL 23/02/2010 - Fim da Implementação
//------------------------------------------

RestArea(_xAlias)

/*
If "MCANUTO" $ UPPER(U_DipUsr()) .And. !MsgBox("Confirma Teste do sistema? ","Atenção","YESNO")
SE1->(DbCommit())
SF2->(DbCommit())
SD2->(DbCommit())
U_M460FIM()
MSGALERT("VERIFIQUE O TESTE DE ENVIO DE E-MAIL E IMPRESSÃO DE ETIQUETAS. Será efetuado o RollBack....")
DisarmTransaction()
Break
EndIf
*/

Return

/*                                                              Sao Paulo,  20 Out 2005
---------------------------------------------------------------------------------------
Empresa.......: DIPOMED Comércio e Importação Ltda.
Função........: NFSEMAIL(nOp)
Objetivo......: Enviar e-mail para à Diretoria quando é incluida, alterada ou excluida
.             : uma nota fiscal de saida de devolução de compras.
Autor.........: Maximo Canuto, MCVN
Data..........: 10/10/08
Consideraçoes.: Função chamada dos P.Es. MT460EST.PRW e SF2460I.PRW
---------------------------------------------------------------------------------------
Parametro nOp: 1 Foi chamada para enviar um e-mail de Aviso de Inclusao de uma NFE
2 Foi chamada para enviar um e-mail de Aviso de Exclusão de uma NFE
---------------------------------------------------------------------------------------
*/
User Function NfSEmail(nOp)
Local aEnvEmailNFS:={}
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
Local aOp:={{' (INCLUIDA) ',' (ALTERADA) ',' (EXCLUIDA) '},{'SF2460I.PRW','SF2460I.PRW','MT460EST.PRW'}}
Local nPreco:=0
Local nCusto:=0
Local nTotal:=0
Local nMrg_C:=0
Local nMrg_P:=0
Local nNfOrig := "" //MCVN - 24/09/08
Local nD2TES  := "" //MCVN - 24/09/08
Local cUser	  := U_DipUsr()
Private aUsuario:={}
Private cF1Obs   := "" //MCVN - 24/09/08
Private cOperSd2 := "" //MCVN - 24/09/08
Private cMailOper:= "" //MCVN - 24/09/08
Private cVendSc5 := "" //MCVN - 24/09/08
Private cTipoVend:= "" //MCVN - 24/09/08
Private cMailVend:= "" //MCVN - 24/09/08
Private lFinanc  := .f.

// Registra o usuario que está usando esta rotina, no SZU.
U_DIPPROC(ProcName(0),cUser)

// Localiza o usuario para poder usar o seu e-mail para identifica-lo na hora do e-envio.
PswOrder(2)
If PswSeek(cUser,.T.)
	aUsuario := PswRet()    
	Alert(Str(Len(aUsuario)))
EndIf
SD2->(dbSetOrder(3))
SB1->(dbSetOrder(1))
SD1->(dbSetOrder(1))
SE2->(dbSetOrder(6))
SE1->(dbSetOrder(2))
SA2->(dbSetOrder(1))
SA2->(DbSeek(cFilSA2+SF2->F2_CLIENTE+SF2->F2_LOJA))
SA1->(dbSetOrder(1))
SA1->(DbSeek(cFilSA1+SF2->F2_CLIENTE+SF2->F2_LOJA))

If SF2->F2_TIPO $ 'DB' // Envia email referente as notas fiscais de devolução de compras MCVN - 10/10/08
	// Seleciona os prazos e datas de vencimentos das ncc's referente a esta NFE.
	If SF2->F2_TIPO = 'D'
		cAssunto:= 'NF DE DEVOLUCAO DE COMPRAS '+AllTrim(SA2->A2_NREDUZ)+' - '+AllTrim(SF2->F2_DOC)+' Serie '+SF2->F2_SERIE+' - '+AllTrim(SM0->M0_NOME)+"/"+AllTrim(SM0->M0_FILIAL)+aOp[1,nOp]
	Else
		cAssunto:= 'NF DE BENEFICIAMENTO  '+AllTrim(SA2->A2_NREDUZ)+' - '+AllTrim(SF2->F2_DOC)+' Serie '+' - '+AllTrim(SM0->M0_NOME)+"/"+AllTrim(SM0->M0_FILIAL)+aOp[1,nOp]
	Endif
	
	SE2->(DbSeek(cFilSE2+SF2->F2_CLIENTE+SF2->F2_LOJA+SF2->F2_SERIE+SF2->F2_DOC))
	Do While SE2->(!EOF()).and.;
		SE2->E2_FILIAL  == cFilSE2.and.;
		SE2->E2_FORNECE == SF2->F2_CLIENTE.and.;
		SE2->E2_LOJA    == SF2->F2_LOJA.and.;
		SE2->E2_PREFIXO == SF2->F2_SERIE.and.;
		SE2->E2_NUM     == SF2->F2_DOC
		cPrzoPag += cBarra+StrZero(SE2->E2_VENCTO - SE2->E2_EMISSAO,2)
		aAdd(aTitulo,{SE2->E2_PARCELA,Dtoc(SE2->E2_VENCTO),Transform(SE2->E2_VALOR,"@E 999,999,999.99")})
		cBarra := ',  '
		SE2->(DbSkip())
	EndDo
	// Seleciona os itens da NFE e acumula no array aEnvEmailNFE
	SD2->(dbSeek(cFilSD2+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA))
	Do While SD2->(!eof()) .and.;
		SD2->D2_FILIAL  == cFilSD2 .and.;
		SD2->D2_DOC     == SF2->F2_DOC .and.;
		SD2->D2_CLIENTE == SF2->F2_CLIENTE .and.;
		SD2->D2_LOJA    == SF2->F2_LOJA
		IncProc('Selecionando itens da nota fiscal ... ')
		SB1->(DbSeek(cFilSB1+SD2->D2_COD))
		
		
		// Apuração do Custo Unitario com IPI e Custo Total com IPI
		nCusto:=((SD2->D2_PRCVEN*SD2->D2_QUANT)+SD2->D2_VALIPI)/SD2->D2_QUANT
		nTotal:=(SD2->D2_PRCVEN*SD2->D2_QUANT)+SD2->D2_VALIPI
		// Apuração da Margem de Preço Minimo e Promocional
		nMrg_C := If(SB1->B1_PRVMINI>0,(SB1->B1_PRVMINI/nCusto-1)*100,0)
		nMrg_P := if(SB1->B1_PRVSUPE>0,(SB1->B1_PRVSUPE/nCusto-1)*100,0)
		nNfOrig:= SD2->D2_NFORI +" - "+SD2->D2_SERIORI+" - "+SD2->D2_ITEMORI
		nD2TES := SD2->D2_TES
		// Geração da Array de Impressão
		aAdd(aEnvEmailNFS,{SD2->D2_COD,;     // 01-Codigo do Produto
		SB1->B1_DESC,;    // 02-Descrição do Produto
		SD2->D2_UM,;      // 03-Unidade de Medida
		SD2->D2_QUANT,;   // 04-Quantidade do Produto
		nCusto,;          // 05-Custo Unitario com IPI
		nTotal,;          // 06-Custo total com IPI
		nD2TES,;          // 07-TES
		nNfOrig})         // 08-Nota fiscal, série original e item
		If !lFinanc
			lFinanc := If(Posicione("SF4",1,xFilial("SF4")+SD2->D2_TES,"SF4->F4_DUPLIC") == 'S',.T.,.F.)
		Endif
		SD2->(DbSkip())
	EndDo
	// Se achou dados para enviar o e-mail, chama a função para montar e enviar o e-mail.
	If Len(aEnvEmailNFS) > 0
		EnvEmailNFS(cAssunto,aEnvEmailNFS,cPrzoPag,aTitulo,aOp[2,nOp],aOp[1,nOp])
	Endif
EndIf

Return(.t.)
*-------------------------------------------------------------------------------------*
Static Function EnvEmailNFS(cAssunto,aEnvEmailNFS,cPrzoPag,aTitulo,cDescRot,cOperacao)
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
Local cEmailTo := GetNewPar("ES_SF2460I","")//'rosemeire.ferraris@dipromed.com.br;dienifer.avelar@dipromed.com.br;wilson.silva@dipromed.com.br'
Local cEmailCc := GetNewPar("ES_SF246CC","")//'juraci.rocha@dipromed.com.br;alessandra.silva@dipromed.com.br;rt@dipromed.com.br'
Local cEmailBcc:= ''
Local i:=0
Local nLin:=0              
LOCAL lSmtpAuth := GetNewPar("MV_RELAUTH",.F.)
LOCAL lAutOk	:= .F.

If ! Lower(AllTrim(aUsuario[1,14])) $ Lower(Alltrim(GetMv('MV_RELACNT')))
	cEmailTo := cEmailTo+";"+Lower(AllTrim(aUsuario[1,14]))
EndIf



//--------------------------------------------------------------------------
// Definicao do cabecalho do email
//--------------------------------------------------------------------------
cMsg := '<html>'
cMsg += '<head>'
cMsg += '<title>'+cAssunto+ '</title>'
cMsg += '</head>'
cMsg += '<body>'
If 'EXCLUIDA' $ cOperacao
	cMsg += '<Table Align=Center BorderColor=#000000 CELLPADDING=4 CELLSPACING=0 Width=100%><table width="100%">'
	cMsg += '   <tr>'
	cMsg += '     <td width="100%" align="Center"><font size="4" color="green">'+cOperacao+'</font></td>'
	cMsg += '   </tr>'
	cMsg += '</table> <P>'
EndIf
cMsg += '<HR Width=100% Size=4 Align=Centered Color=Red>'
cMsg += '<Table Align=Center BorderColor=#000000 CELLPADDING=4 CELLSPACING=0 Width=100%>'
//-------------------------------------------------------------------------
// Definicao do cabecalho do relatório
//-------------------------------------------------------------------------
cMsg += '<table width="100%">'
cMsg += '  <tr>'
cMsg += '     <td width="60%"><font size="3" color="blue"> ' + SA2->A2_COD + '-' + AllTrim(SA2->A2_NOME) +'</font></td>'
cMsg += '     <td width="40%"><font size="4"  color="blue">Nota Fiscal: ' + Alltrim(SF2->F2_DOC) +' - Serie: '+SF2->F2_SERIE + ' - Tipo: '+If(SF2->F2_TIPO = 'D','DEVOLUÇÃO','BENEFICIAMENTO')+ '</font></td>'
cMsg += '  </tr>'
cMsg += '</table> <P>'


If !Empty(cPrzoPag)
	cMsg += '<table>'
	cMsg += '  <tr>'
	cMsg += '     <td width="100%" colspan="2"><font size="2" color="blue">Condição de Pagamento: ' + cPrzoPag + ' dias.</font></td>'
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
cMsg += '         <td width="50%">Código - Descrição - TES</td>'
cMsg += '         <td width="5%" align="center">UM</td>'
cMsg += '         <td width="9%" align="right">Quantidade</td>'
cMsg += '         <td width="9%" align="right">Unitario</td>'
cMsg += '         <td width="9%" align="right">Total</td>'
cMsg += '         <td width="18%" align="right">NF. Orig-Serie-Item</td>'
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
For nLin := 1 to Len(aEnvEmailNFS)
	nTot_Prod += aEnvEmailNFS[nLin,6]
	cMsg += '<table width="100%" border="1" cellspacing="0" cellpadding="0">'
	cMsg += '   <tr BgColor='+aLinCor[nLinCor]+'>'
	cMsg += '      <td width="50%"><font size="1">' + aEnvEmailNFS[nLin,1] + ' - ' + aEnvEmailNFS[nLin,2] + ' - ' + aEnvEmailNFS[nLin,7] +'</font></td>'
	cMsg += '      <td width="5%" align="center"><font size="1">' + aEnvEmailNFS[nLin,3] + '</font></td>'
	cMsg += '      <td width="9%" align="right"><font size="1">' + Transform(aEnvEmailNFS[nLin,4],"@E 999,999,999") + '</font></td>'
	cMsg += '      <td width="9%" align="right"><font size="1">' + Transform(aEnvEmailNFS[nLin,5],"@E 999,999,999.9999") + '</font></td>'
	cMsg += '      <td width="9%" align="right"><font size="1">' + Transform(aEnvEmailNFS[nLin,6],"@E 999,999,999.99")   + '</font></td>'
	cMsg += '      <td width="18%" align="right"><font size="1">' + aEnvEmailNFS[nLin,8] + '</font></td>'
	cMsg += '   </tr>'
	cMsg += '</table>'
	
	if 	nLinCor<2
		nLinCor++
	Else
		nLinCor:=1
	EndIf
Next
cMsg += '<table width="100%"  border="1" cellspacing="5" cellpadding="0">'
cMsg += '    <tr BgColor=#FFFF80>'
cMsg += '       <td width="15%" align="right"><font color="blue" size="1">Desconto:  ' + Transform(SF2->F2_DESCONT,"@E 999,999,999.99") + '</font></td>'
cMsg += '       <td width="15%" align="right"><font color="blue" size="1">Frete:  '    + Transform(SF2->F2_FRETE  ,"@E 999,999,999.99") + '</font></td>'
cMsg += '       <td width="15%" align="right"><font color="blue" size="1">Despesas:  ' + Transform(SF2->F2_DESPESA,"@E 999,999,999.99") + '</font></td>'
cMsg += '       <td width="15%" align="right"><font color="blue" size="1">Total dos Produtos: ' + Transform(nTot_Prod,"@E 999,999,999.99") + '</font></td>'
cMsg += '    </tr>'
cMsg += '</table>'
//-----------------------------------------------------------------------
// Definicao do rodape do email
//-----------------------------------------------------------------------
cMsg += '</Table> <P>'
cMsg += '<table width="100%" border="0" cellspacing="0" cellpadding="0">'
cMsg += '    <tr align="right"><P>'
cMsg += '       <td width="100%" align="right"><font color="red" size="3">Total da NF:     ' + Transform(SF2->F2_VALBRUT,"@E 999,999,999.99") + '</font></td>'
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
            

If GetNewPar("ES_ATIVJOB",.T.)                              
	cEmailTo+=";"+cEmailCc+";"+cEmailBcc
	u_UEnvMail(cEmailTo,cAssunto,nil,"",cFrom,"EnvEmailNFS(SF2460I.prw)",cMsg)
Else
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
			MsgInfo(cError,OemToAnsi('Atenção'))
		EndIf
		DISCONNECT SMTP SERVER
	Else
		//Erro na conexao com o SMTP Server
		GET MAIL ERROR cError
		MsgInfo(cError,OemToAnsi('Atenção'))
	EndIf
EndIf

Return(.T.)         

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³fNfOri   ºAutor  ³Microsiga           º Data ³  26/05/15    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funcao para obter a NF Original na Nota Fiscal Devolução   º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function fNfOri56()
Local cAliasTrb	:= GetNextAlias()
Local cQuery	:= " "
Local aAreas 	:= {	SD2->(GetArea()),GetArea()}

// Zera Array
_aDocDev   := {}

cQuery := " SELECT TOP 1 D2_DOC, D2_SERIE, D2_ITEM, D2_EMISSAO, D2_FILIAL "

cQuery += " FROM SD2010 SD2"

cQuery += " WHERE"
cQuery += "     SD2.D2_FILIAL      = '01' "
cQuery += "     AND SD2.D_E_L_E_T_ = ' '"
cQuery += "     AND SD2.D2_CLIENTE = '000804'"
cQuery += "     AND SD2.D2_LOJA    = '04'"
cQuery += "     AND SD2.D2_EMISSAO >= '20140601'"
cQuery += "     AND SD2.D2_FCICOD  = ' ' "


cQuery := ChangeQuery( cQuery )
dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),cAliasTrb,.F.,.T.)

//-- Percorre a Query e adiciona o resultado no array de Retorno
(cAliasTrb)->( DbEval( {|| aAdd(_aDocDev,{ D2_DOC, D2_SERIE, D2_ITEM,D2_EMISSAO, D2_FILIAL })  }))
(cAliasTrb)->( DbCloseArea() )

aEval( aAreas, { |xArea| RestArea(xArea) } )

Return (_aDocDev)


//-------------------------------------------------------------------------------------------//
*---------------------------------------------------*
User Function AjustaSD256(_aDocDev)
*---------------------------------------------------*

Private _cExc3

TcCommit(1)

_cExc3:=" UPDATE "+RetSqlName("SD2")
_cExc3+=" SET D2_FCICOD  =  'OKSPED' "
_cExc3+=" WHERE D2_DOC   =  '"+_aDocDev[1][1]+"'"                    
_cExc3+=" AND D2_SERIE   =  '"+_aDocDev[1][2]+"'"                    
_cExc3+=" AND D2_ITEM    =  '"+_aDocDev[1][3]+"'"                    
_cExc3+=" AND D2_EMISSAO =  '"+_aDocDev[1][4]+"'"                    
_cExc3+=" AND D2_FILIAL  =  '"+_aDocDev[1][5]+"'"                    

If  TcSqlExec(_cExc3) < 0
	TcCommit(3)
Else
	TcCommit(2)
	TcCommit(4)
	MsUnlockAll()
EndIf

Return

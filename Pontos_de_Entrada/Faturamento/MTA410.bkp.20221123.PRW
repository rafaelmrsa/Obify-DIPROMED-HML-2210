
/*
|=====================================================================================|
|Programa  | MTA410        | Autor | Alexandro Dias             | Data | 23/08/2001   |
|=====================================================================================|
|DescriÁ„o | Rotina utilizada para liberacao do pedido de vEnda conforme calculo da   |
|          | margem do pedido. A liberacao do pedido e feita atraves de senha, onde   |
|          | somente o Eric (Dipromed) e pessoas autorizadas por ele devem saber a    |
|          | formula de calculo. Este programa executa a rotina DIPG007() para calculo|
|          | da margem. Esta rotina tambem atualiza o peso bruto e liquido do pedido. |
|          | VALIDA TELA TODA DE DIGITACAO DO PV                                      |
|=====================================================================================|
|RETORNO   | Variavel logica que valida (.T.) ou nao (.F.) as alteracoes efetuadas.   |
|=====================================================================================|
|UTILIZA«ƒO| Validacao da tela toda no Pedido de Venda.                               |                                                                          |
|=====================================================================================|
|Sintaxe   | MTA410                                                                   |
|=====================================================================================|
|Uso       | Especifico DIPROMED                                                      |
|=====================================================================================|
|........................................HistÛrico....................................|
|Candisani | 26/01/09 - Inclusao da rotina para verificar se o pedido e compartilhado |
|            entre as empresas Dipromed e Health atraves do campo C5_DIPCOM. se for   |
|            compartilhado, gravar os itens da Health na empresa Health.              |
|            26/01/09 - Inclusao da rotina de tratamento dos itens: campo C6_TIPODIP  |
|            como 1-pedido ou 2-orcamento. Se for pedido - ataulizar campo C6_QTDORC  |
|            com quantidade zero. Se for orcamento atualizar campo C6_QTDORC com a    |
|            quantidade do item                                                       |
|            26/01/09 - Inclusao da rotina para verificar se tipo de pedido e 1-Pedido|
|            2-Orcamento.Se for orcamento atualizar campo da tabela SB2->B2_ORCVEN    |
|            com a quantidade do item em questao.                                     |
|Candisani  | 01/02/09 - Rotina de inclusao em outra empresa os itens da Health       |
|           | 28/02/09 - Inclusao da rotina de pedido de venda sem passar por         |
|           |            orcamento                                                    |
|           | 11/03/09 - Validacao de campos obrigatorios na SC5 antes da rotina de   |
|           |            atualizacao de saldos na Health qdo pedido compartilhado     |
|Maximo     | 24/07/09 - Toda rotina de pedido de venda/orÁamento foi alterada        |
|=====================================================================================|
*/
#Include "Protheus.ch"
#Include "Topconn.ch"
#INCLUDE "RWMAKE.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "TRYEXCEPTION.CH"
#DEFINE TELEMARKETING 1 // JBS 03/11/2005
#DEFINE TELEVENDAS    2 // JBS 03/11/2005
#DEFINE TELECOBRANCA  3 // JBS 03/11/2005
#DEFINE CEND CHR(10)+CHR(13)
#Translate MSGBOX( => IW_MsgBox(

*----------------------------------------*
User Function MTA410()
*----------------------------------------*
Local _lRetorno := .F.
Local _xAlias   := GetArea()
local _areaSB1 := SB1->(getarea())
local _areaSZ3 := SZ3->(getarea())
local _areaSE4 := SE4->(getarea())
Local _nValor
Local _nTotInf
LOCAL _nLin
LOCAL _n
LOCAL _pn
Local _aMsg := {}
Local _cAssunto
Local _cEmail
Local _cDestCli  := ""
Local _cFrom     := ""
Local _cFuncSent := "MTA410.PRW"
Local _nDescICMS := 0
Local _nVlPed    := 0
Local _nVlPedICM := 0
Local _nCont	 := 0
Local _x		 := 0
Local nX		 := 0
Local nY		 := 0
Local aa		 := 0
Local _nClasFis  := 0
Local _Sb1Origem := ""
Local _Sf4SitTri := ""
Local _nAux		 := 0
Local _mInfoCli  := ""
Local _aInfoPro  := {}
Local _mInfoPro  := ""
Local lUsa2Desc  := .F.
Local cMsgProd   := ""          
Local lTemSP	 := .F.
Local cSQL 		 := ""
Local nPosLotCTL := aScan(aHeader, { |x| Alltrim(x[2]) == "C6_LOTECTL"})
Local _nI
Private cEmpa:="04"
//Private cEmpa:="99"
Private cFila:="01"
Private lErroEmpe := .F.

//giovani 21/06/11
Private _cValFrete := " "

If ISINCALLSTACK("LOJA901A") .Or. ISINCALLSTACK("LOJA901")
	Return .T.
EndIf

If "MATA310"$Upper(FunName())
	Return .T.
EndIf

//-- Valida campos do cliente selecionado
// Andre Mendes - [OBIFY] - 23/02/2022 - Ticket 4308
// n„o executa a validaÁ„o se for chamado pelo JOB, pois utiliza elementos visuais que n„o podem ser mais utilizados no JOB
If !IsBlind()
	If !U_DIPV002()
		Return .F.
	EndIf
Endif
/*Chamada alterada para o M410STTS
If INCLUI
	If cEmpAnt <> "04"
		If ("MATA410" $ FUNNAME()) .And. !Empty(SA1->A1_LFVISA) .And. !Empty(SA1->A1_VLLVISA) .And. SA1->A1_VLLVISA < dDATABASE //Reginaldo Borges 04/01/2018
			DIPVCIC(SA1->A1_COD,SA1->A1_NOME,SA1->A1_VEND)
			DIPVEMAIL(SA1->A1_COD,SA1->A1_NOME,SA1->A1_VEND)
			EndIF
	EndIf
EndIf	
*/

//Giovani Zago 09/02/2012
If !("DIPAL10" $ FUNNAME()) .AND. !("TMK"$FunName())
	If  M->C5_TPFRETE $ 'D' .And. M->C5_TIPODIP <> '2' .And. M->C5_TIPODIP <> '3' .And.  'VISTA' $ Posicione("SE4",1,XFILIAL("SE4")+M->C5_CONDPAG,'E4_DESCRI') .And. !(M->C5_XFORPAG $ ('1/2/3'))
		MsgInfo("Forma de Pagamento Deve Ser Selecionado!!!")
		Return(.F.)
	Endif
	If !(M->C5_TPFRETE $ 'D') .And. !Empty(M->C5_XFORPAG).And. M->C5_TIPODIP <> '2' .And. M->C5_TIPODIP <> '3' .And.  'VISTA' $ Posicione("SE4",1,XFILIAL("SE4")+M->C5_CONDPAG,'E4_DESCRI')
		M->C5_XFORPAG := ""
	EndIf
Endif

/*
IF !("TMK"$FunName()) .And. !("DIPAL10" $ Funname()) .And. M->C5_TPFRETE $ "C/I" .And. !(M->C5_TRANSP $ '100000')//GIOVANI ADD "I" 21/07/11  //25/07/11 add validaÁ„o da emovere
	M->C5_TRANSP:= ' '  //giovani 19/07/11 limpa a variavel da transportadora forÁando o recalculo do frete na finalizaÁ„o do pedido
EndIf
*/
// Envia e-mail sempre que o destino de frete for alterado   MCVN - 16/10/2007
/*      Giovani Zago 28/10/11 retirado  solicitaÁ„o do maximo
IF !("TMK"$FunName()) .And. !("DIPAL10" $ Funname())
_cDestCli := Alltrim(U_Mt410Frete('GATILHO'))

If Alltrim(M->C5_DESTFRE) <> _cDestCli .And. M->C5_TPFRETE $ "IC"  .And. (If(Altera,SC5->C5_DESTFRE <> M->C5_DESTFRE,.T.))
IF MsgBox("O DESTINO DO FRETE FOI ALTERADO. CONFIRMA A ALTERA«√O?","Atencao","YESNO")

_cFrom   := Lower(Alltrim(Posicione("SU7",1,xFilial("SU7")+C5_OPERADO,"U7_EMAIL")))
_cEmail  := "maximo@dipromed.com.br"
_cAssunto:= "Destino de FRETE do pedido "+M->C5_NUM+" foi alterado!"
Aadd( _aMsg , { "Numero Pedido: "       , M->C5_NUM } )
Aadd( _aMsg , { "Operador: "            , M->C5_OPERADO +" - "+ M->C5_NOMEOPE } )
Aadd( _aMsg , { "Transportadora: "      , M->C5_TRANSP } )
Aadd( _aMsg , { "Destino do Cliente: "  , _cDestCli + " - " + M->C5_MUNE } )
Aadd( _aMsg , { "Destino do Pedido:  "  , M->C5_DESTFRE } )
Aadd( _aMsg , { "Tipo de Frete: "       , M->C5_TPFRETE } )

U_UEnvMail(_cEmail,_cAssunto,_aMsg,"",_cFrom,_cFuncSent)

//Return(.T.)
Else
M->C5_TRANSP  := Space(06)
M->C5_FRETE   := 0
M->C5_DESTFRE := U_Mt410Frete('GATILHO')

Return(.F.)
Endif
Endif
Endif
*/

// Validando transportadora MCVN - 23/06/2009
If !("DIPAL10" $ FUNNAME()) .AND. !("TMK"$FunName())
	If  !(M->C5_TPFRETE $ 'C/I') .And. M->C5_TIPODIP <> '2' .And. M->C5_TIPODIP <> '3'//MCVN - 24/06/2009
		If (Empty(M->C5_TRANSP) .OR. ;
			(M->C5_TRANSP $ '000001/000851' .AND. M->C5_TPFRETE <> 'N') .OR. ;
			(M->C5_TRANSP $ '000111/000112/000133' .AND. M->C5_TPFRETE <> 'D') .OR. ;
			(!M->C5_TRANSP $ '000111/000112/000133' .AND. M->C5_TPFRETE = 'D') .OR. ;
			((M->C5_TRANSP <> '000001' .And. M->C5_TRANSP <> '000851') .AND. M->C5_TPFRETE = 'N'))
			MsgInfo("Existem divergÍncias com relaÁ„o a transportadora e o tipo de frete ou a transportadora n„o est· preenchida!")
			Return(.F.)		             	
		ElseIf (M->C5_TRANSP $ '000111/000112/000133' .AND. M->C5_TIPO$'D/B') //12/04/16 N„o permite cliente retira para notas  que utilizam fornecedor
			MsgInfo("N„o È possivel utilizar as transportadoras RETIRA em pedidos de devoluÁ„o ou beneficiamento! Utilize PR”PRIO FORNECEDOR.")
			Return(.F.)
		Endif
		
	Endif         

	// Mensagem e bloqueio da utilizaÁ„o da transportadora Nosso Carro  - 03/12/2009
	If ("DIPROMED" $ SM0->M0_NOMECOM)
		If M->C5_TRANSP $ '000001'  .OR. M->C5_TPFRETE = 'N'//03/12/2009
			MsgInfo("N„o È mais permitida a utilizaÁ„o da opÁ„o de frete  NOSSO CARRO, Favor alterar o tipo de frete para CIF e selecionar a transportadora  de codÌgo 100000 (EMOVERE)!")
			Return(.F.)
		EndIf
	Endif
	// Tratamento no cep de entrega do pedido de venda MCVN-11/12/2009
	If ("-" $ Alltrim(M->C5_CEPE))
		MsgInfo("O CEP de entrega est· digitado incorretamente, favor preencher somente com numeros!")
		Return(.F.)
	Endif
	
Endif


// Tratando erro de TES de ICMS-ST fora de S„o Paulo - MCVN - 03/07/2008
IF !("TMK"$FunName())
	For _ncont := 1 to Len(aCols)
		If SA1->A1_EST <> "SP" .And. (aCols[_ncont][aScan(aHeader,  { |x| Alltrim(x[2]) == "C6_TES"})]) $ "625/626/627/630/631/632/633"
			MsgInfo("A TES do produto  "+(aCols[_ncont][aScan(aHeader,  { |x| Alltrim(x[2]) == "C6_PRODUTO"})])+ " est· incorreta, Favor dar ENTER no produto e liberar novamente.",'AtenÁ„o')
			Return(.f.)
		EndIf
		
		/*		If SA1->A1_EST == "SP" .And. ;
		POSICIONE("SB1",1,xFilial("SB1")+(aCols[_ncont][aScan(aHeader,  { |x| Alltrim(x[2]) == "C6_PRODUTO"})]),"B1_PICMRET") <> 0.And. ;
		!((aCols[_ncont][aScan(aHeader,  { |x| Alltrim(x[2]) == "C6_TES"})]) $ "625/626/627/630/631/632/633")
		
		MsgInfo("A TES do produto  "+(aCols[_ncont][aScan(aHeader,  { |x| Alltrim(x[2]) == "C6_PRODUTO"})])+ " est· incorreta, Favor dar ENTER no produto e liberar novamente.",'AtenÁ„o')
		Return(.f.)
		EndIf
		*/
	Next _ncont
EndIf


If  Type("l410Auto") <> "U" .and. l410Auto
	_lRetorno := .t.
	//-- D'Leme - 12/09/2011: AÁteraÁ„o do modo de reserva no PV - CorreÁ„o para LicitaÁıes.
	If _lRetorno
		U_DIPXRESE("SV_NEW", M->C5_NUM)
		U_DIPXRESE("ALT_NEW", M->C5_NUM)
	EndIf
	Return(_lRetorno)
EndIf

Private _nPosPrcven  := aScan(aHeader, { |x| Alltrim(x[2]) == "C6_PRCVEN"})
Private _nPosQtdVen	 := aScan(aHeader, { |x| Alltrim(x[2]) == "C6_QTDVEN"})
Private _nPosUPrc 	 := aScan(aHeader, { |x| Alltrim(x[2]) == "C6_USERPRC"})
Private _nPosUDes 	 := aScan(aHeader, { |x| Alltrim(x[2]) == "C6_USERDES"})
Private _nPosPrUnit	 := aScan(aHeader, { |x| Alltrim(x[2]) == "C6_PRUNIT"})
Private _nPosDescont := aScan(aHeader, { |x| Alltrim(x[2]) == "C6_DESCONT"})
Private _nPosValDesc := aScan(aHeader, { |x| Alltrim(x[2]) == "C6_VALDESC"})
Private _nPosTes     := aScan(aHeader, { |x| Alltrim(x[2]) == "C6_TES"})     // MCVN - 19/10/2007
Private _nPosprod    := aScan(aHeader, { |x| Alltrim(x[2]) == "C6_PRODUTO"}) // MCVN - 19/10/2007
Private _nPosValor   := aScan(aHeader, { |x| Alltrim(x[2]) == IIF("TMK"$FunName(),"UB_VLRITEM","C6_VALOR") })
Private _nPosFor     := aScan(aHeader, { |x| Alltrim(x[2]) == "C6_FORNEC"}) // Candisani - 26/01/2009
Private _nPosQOrc    := aScan(aHeader, { |x| Alltrim(x[2]) == "C6_QTDORC"}) // Candisani - campo de quantidade orcada -26/01/2009
Private _nPosTipo    := aScan(aHeader, { |x| Alltrim(x[2]) == "C6_TIPODIP"}) // Candisani - campo de tipo 1-pedido 2-orcamento 26/01/2009
Private _nPosLoca    := aScan(aHeader, { |x| Alltrim(x[2]) == "C6_LOCAL"}) // Candisani - armazem do produto - candisani - 27/01/09
Private _nPosNum     := aScan(aHeader, { |x| Alltrim(x[2]) == "C6_NUM"}) // Candisani - numero de pedido
Private _nPosItem    := aScan(aHeader, { |x| Alltrim(x[2]) == "C6_ITEM"}) // Candisani - item do produto - candisani - 27/01/09
Private _nPosUm      := aScan(aHeader, { |x| Alltrim(x[2]) == "C6_UM"}) // Candisani - umidade de medida do produto - candisani - 01/02/09
Private _nPosQtdLib  := aScan(aHeader, { |x| Alltrim(x[2]) == "C6_QTDLIB"}) // Maximo - Quantidade liberada - MCVN - 11/03/09
Private _nPosBlq     := aScan(aHeader, { |x| Alltrim(x[2]) == "C6_BLQ"}) // Maximo - Bloqueio de pedido - MCVN - 17/07/09
//Private _nPosDipQEnt := aScan(aHeader, { |x| Alltrim(x[2]) == "C6_DIPQENT"}) // Maximo - campo virtual com a quantidade entregue - MCVN - 17/07/09
Private _nPosComis1  := aScan(aHeader, { |x| Alltrim(x[2]) == "C6_COMIS1"}) // Maximo - COMISS√O - MCVN - 16/08/09
Private _nPosCom2	 := aScan(aHeader, { |x| Alltrim(x[2]) == "C6_COMIS2"}) // Maximo - COMISS√O - MCVN - 16/08/09
Private _nPosClasFi  := aScan(aHeader, { |x| Alltrim(x[2]) == "C6_CLASFIS"}) // Maximo - C6_CLASFIS B1_ORIGEM+F4_SITTRIB - MCVN - 13/09/10
Private _nPosQtdEnt  := aScan(aHeader, { |x| Alltrim(x[2]) == "C6_QTDENT"})
Private _nPosFCI	 := aScan(aHeader, { |x| Alltrim(x[2]) == "C6_FCICOD"})
Private _nPosMini    := aScan(aHeader, { |x| Alltrim(x[2]) == "C6_PRVMINI"})
Private _nPosSupe    := aScan(aHeader, { |x| Alltrim(x[2]) == "C6_PRVSUPE"})
Private _nPosCSis    := aScan(aHeader, { |x| Alltrim(x[2]) == "C6_XCALCSI"})
Private _nPosEmpe    := aScan(aHeader, { |x| Alltrim(x[2]) == "C6_XEMPENH"})


Private aIens		:={}
Private aCabec		:={}
Private nCampo		:=0
Private ePedido		:=.F.

Private _nValLin  	:= 0    //Giovani Zago 12/12/11
//Private _nConLin  	:= 200   //Giovani Zago 12/12/11  quantidade de itens permitida na digitaÁ„o do P.V.

U_DIPPROC(ProcName(0),U_DipUsr()) // JBS 05/10/2005 - Gravando o nome do Programa no SZU

If "TMK"$FunName() .and. nFolder <> TELEVENDAS  // JBS 04/12/2005
	Return(.t.)
EndIf


//--------------------------------------------
// Se o arq temp j· existe o bt foi acionado
// mais de uma vez, ent„o sai da rotina.
//--------------------------------------------
If Select("WORK_FRT") > 0 // JBS 31/01/2006, 10:30
	If (Type("l410Auto") == "U" .OR. !l410Auto)
		MsgInfo('O Calculo do Frete j· est· em execuÁ„o!'+chr(13)+chr(10)+;
		'Por favor aguarde o termino da execuÁ„o!','AtenÁ„o')
	EndIf
	Return(.F.)
EndIf

//≥ Executa rotina para calculo da margem do pedido.
If "TMK"$FunName()
	_lRetorno := U_DIPG007("TMKVFIM")
Else
	_lRetorno := U_DIPG007("MTA410")
	
	//--------------------------------------------------------------------------------
	//DESABILITADO REGRA ABAIXO PARA IDENTIFICAR SE CALCULA OU N√O A ST - MCVN 17/09/10
	//--------------------------------------------------------------------------------
	/* Alterado dia 22/07/2008 - MCVN
	Calcula Substituicao Tributaria
	If SA1->A1_EST != 'PR'   .and.; Paran· Aderiu ao Conv. 76/94 A PARTIR DE 01/06/2008
	SA1->A1_EST != 'SC' 	 .AND.; Santa Catarina Aderiu ao Conv. 76/94 A PARTIR DE 01/06/2008
	
	If SA1->A1_EST != 'SP'  .and.;
	SA1->A1_EST != 'DF' 	.AND.;
	SA1->A1_EST != 'AM' 	.AND.;
	SA1->A1_EST != 'CE' 	.AND.;
	SA1->A1_EST != 'GO' 	.AND.;
	SA1->A1_EST != 'RN' 	.AND.;
	!Empty(SA1->A1_INSCR) .and. ;
	!('ISENT' $ Upper(SA1->A1_INSCR)) .and. ;
	M->C5_TIPO == 'N' .And. ;
	(Empty(SA1->A1_GRPTRIB) .Or. (!Empty(SA1->A1_GRPTRIB) .And. U_ExcFiscal(SA1->A1_EST,SA1->A1_GRPTRIB)))  // MCVN - 28/04/2008
	U_DIPA025(SA1->A1_EST)
	Endif
	*/   
    
	//≥ Atualiza o peso liquido e bruto do pedido.         	       ≥	
	If _lRetorno
		_lRetorno := U_CalcuFrete('MTA410')
	EndIf
	
	//≥ Valida CondiÁ„o de Pagamento Tipo 9.              	       ≥
	IF _lRetorno == .T.
		If SE4->E4_TIPO == "9"
			_nPosValor := aScan(aHeader, { |x| Alltrim(x[2]) == IIF("TMK"$FunName(),"UB_VLRITEM","C6_VALOR") })
			_nValor    := 0
			_nTotInf   := 0
			
			//≥ Soma valor total da nota.                           ≥
			For _nLin := 1 to Len(aCols)
				IF !aCols[_nLin,Len(aHeader)+1]
					_nValor := _nValor + aCols[_nLin,_nPosValor]
				EndIF
			Next
			DBSELECTAREA("SC5")
			IF "TMK"$FunName()
				//			_nTotInf := M->UA_PARC1 + M->UA_PARC2 + M->UA_PARC3 + M->UA_PARC4
				_nTotInf := SC5->C5_PARC1 + SC5->C5_PARC2 + SC5->C5_PARC3 + SC5->C5_PARC4 + SC5->C5_PARC5 + SC5->C5_PARC6 //INCLUIDO PARCELAS 5 E 6
				_nValor  := _nValor + SC5->C5_FRETE
			Else
				_nTotInf := M->C5_PARC1 + M->C5_PARC2 + M->C5_PARC3 + M->C5_PARC4 + M->C5_PARC5 + M->C5_PARC6 //INCLUIDO PARCELAS 5 E 6    
				_nValor  := _nValor + M->C5_FRETE
			Endif
			IF Round(_nValor,2) <> Round(_nTotInf,2)
				
				MsgInfo("Valor Total do Pedido n„o confere com o total das parcelas Informadas ")
				MSGINFO(STR(_NVALOR,15,4),STR(_NTOTINF,15,4))
				_lRetorno := .F.
			ELSE
				
				IF "TMK"$FunName()
					IF !EMPTY(SC5->C5_PARC1) .AND. !EMPTY(SC5->C5_DATA1) .Or. EMPTY(SC5->C5_PARC1) .AND. EMPTY(SC5->C5_DATA1)
						IF !EMPTY(SC5->C5_PARC2) .AND. !EMPTY(SC5->C5_DATA2) .Or. EMPTY(SC5->C5_PARC2) .AND. EMPTY(SC5->C5_DATA2)
							IF !EMPTY(SC5->C5_PARC3) .AND. !EMPTY(SC5->C5_DATA3) .Or. EMPTY(SC5->C5_PARC3) .AND. EMPTY(SC5->C5_DATA3)
								IF !EMPTY(SC5->C5_PARC4) .AND. !EMPTY(SC5->C5_DATA4) .Or. EMPTY(SC5->C5_PARC4) .AND. EMPTY(SC5->C5_DATA4)
									IF !EMPTY(SC5->C5_PARC5) .AND. !EMPTY(SC5->C5_DATA5) .Or. EMPTY(SC5->C5_PARC5) .AND. EMPTY(SC5->C5_DATA5)
										IF !EMPTY(SC5->C5_PARC6) .AND. !EMPTY(SC5->C5_DATA6) .Or. EMPTY(SC5->C5_PARC6) .AND. EMPTY(SC5->C5_DATA6)
											_lRetorno := .T.
										ELSE
											MsgInfo("N„o conformidade na parcela 6")
											_lRetorno := .F.
										ENDIF
									ELSE
										MsgInfo("N„o conformidade na parcela 5")
										_lRetorno := .F.
									ENDIF
								ELSE
									MsgInfo("N„o conformidade na parcela 4")
									_lRetorno := .F.
								ENDIF
							ELSE
								MsgInfo("N„o conformidade na parcela 3")
								_lRetorno := .F.
							ENDIF
						ELSE
							MsgInfo("N„o conformidade na parcela 2")
							_lRetorno := .F.
						ENDIF
					ELSE
						MsgInfo("N„o conformidade na parcela 1")
						_lRetorno := .F.
					ENDIF
				ELSE
					IF !EMPTY(M->C5_PARC1) .AND. !EMPTY(M->C5_DATA1) .Or. EMPTY(M->C5_PARC1) .AND. EMPTY(M->C5_DATA1)
						IF !EMPTY(M->C5_PARC2) .AND. !EMPTY(M->C5_DATA2) .Or. EMPTY(M->C5_PARC2) .AND. EMPTY(M->C5_DATA2)
							IF !EMPTY(M->C5_PARC3) .AND. !EMPTY(M->C5_DATA3) .Or. EMPTY(M->C5_PARC3) .AND. EMPTY(M->C5_DATA3)
								IF !EMPTY(M->C5_PARC4) .AND. !EMPTY(M->C5_DATA4) .Or. EMPTY(M->C5_PARC4) .AND. EMPTY(M->C5_DATA4)
									IF !EMPTY(M->C5_PARC5) .AND. !EMPTY(M->C5_DATA5) .Or. EMPTY(M->C5_PARC5) .AND. EMPTY(M->C5_DATA5)
										IF !EMPTY(M->C5_PARC6) .AND. !EMPTY(M->C5_DATA6) .Or. EMPTY(M->C5_PARC6) .AND. EMPTY(M->C5_DATA6)
											_lRetorno := .T.
										ELSE
											MsgInfo("N„o conformidade na parcela 6")
											_lRetorno := .F.
										ENDIF
									ELSE
										MsgInfo("N„o conformidade na parcela 5")
										_lRetorno := .F.
									ENDIF
								ELSE
									MsgInfo("N„o conformidade na parcela 4")
									_lRetorno := .F.
								ENDIF
							ELSE
								MsgInfo("N„o conformidade na parcela 3")
								_lRetorno := .F.
							ENDIF
						ELSE
							MsgInfo("N„o conformidade na parcela 2")
							_lRetorno := .F.
						ENDIF
					ELSE
						MsgInfo("N„o conformidade na parcela 1")
						_lRetorno := .F.
					ENDIF
				EndIf
			Endif
		ENDIF
	ENDIF
EndIf // eriberto 06/06 Endif

// Ajustando campo C6_CLASFIS COM B1_ORIGEM + F4_SITTRIB  - MCVN 13/09/2010
For _nClasFis := 1 to Len(aCols)
	IF !aCols[_nClasFis,Len(aHeader)+1]
		_Sb1Origem := Alltrim(Posicione("SB1",1,xFilial("SB1")+(aCols[_nClasFis,_nPosProd]),"SB1->B1_ORIGEM")) //29-09-2010  MCVN//Left(aCols[_nClasFis,_nPosClasFi],1)
		_Sf4SitTri := Posicione("SF4",1,xFilial('SF4')+(aCols[_nClasFis,_nPosTes]) ,"F4_SITTRIB")
		
		aCols[_nClasFis,_nPosClasFi] := _Sb1Origem+_Sf4SitTri
	EndIF
Next

//Candisani - 26/01/09
//Verifica se o item e da Dipromed ou Health
//Se for da Health deleta do Acols e grava num outro AcolsH para
//posterior gravacao na empresa Health
//Verificar se e inclusao, alteracao, exclusao
//Alert(str(nOPC0))
//Alert("1")

If !"TMK" $FunName() .And. M->C5_TIPO = "N" .And. !("DIPAL10" $ Funname())
	
	C5DipCom :=M->C5_DIPCOM
	C5TipoDip:=M->C5_TIPODIP
	
	nCabec:=0
	aItens:={}
	nCampo:=0
	aCposSC5:={}
	_n := n
	
	//Inicio da rotina de atualizacao do pedido compartilhado
	
	// Se existir algum Ìtem como pedido o C5_TIPODIP fica como Pedido tambem - MCVN 20/07/2009
	For _x := 1 to Len(aCols)
		If aCols[_x,_nPosTipo] == '1'
			M->C5_TIPODIP := aCols[_x,_nPosTipo]
			C5TipoDip     := aCols[_x,_nPosTipo]			
		Endif                                   
	Next _x
	
	If C5TipoDip == "1" //Pedido
		If inclui
			If !"TMK" $FunName() .And. M->C5_TIPO = "N"
				If C5DipCom == "1"  // pedido e compartilhado
					For _x := 1 to Len(aCols)
						If aCols[_x,_nPosFor] == "000851" //se for fornecedor Health deleta do acols e grava na matriz
							//aCols[_x,Len(aHeader)+1]:=.T. - alterada a rotina para nao deletar da empresa Dipromed o item
							//candisani - 07/02/09
							//Rotina para gravar em matriz para o Startjob na empresa Health
							//Rotina de inclusao dos itens na empresa Health - Candisani - 01/02/09
							//Inclusao direto de pedido compartilhado - candisani - 28/02/09
							//Cabecalho
							If nCabec == 0
								aCabec:={}
								//AADD(aCabec,{FieldName(nX),FieldGet(nX)})
								AADD(aCabec,{"C5_NUM",space(06)})
								AADD(aCabec,{"C5_FILIAL",cFila})
								AADD(aCabec,{"C5_TIPO",M->C5_TIPO})
								AADD(aCabec,{"C5_CLIENTE",M->C5_CLIENTE})
								AADD(aCabec,{"C5_LOJACLI",M->C5_LOJACLI})
								AADD(aCabec,{"C5_OPERADO",M->C5_OPERADO})
								AADD(aCabec,{"C5_CONDPAG",M->C5_CONDPAG})
								AADD(aCabec,{"C5_TRANSP",M->C5_TRANSP})
								AADD(aCabec,{"C5_TPFRETE",M->C5_TPFRETE})
								AADD(aCabec,{"C5_DIPCOM",M->C5_DIPCOM})
								AADD(aCabec,{"C5_TIPODIP",M->C5_TIPODIP})
								AADD(aCabec,{"C5_DESTFRE",M->C5_DESTFRE})
								AADD(aCabec,{"C5_QUEMCON",M->C5_QUEMCON})
								AADD(aCabec,{"C5_EMISSAO",M->C5_EMISSAO})
								AADD(aCabec,{"C5_TIPOCLI",M->C5_TIPOCLI})
								nCabec+=1
							Endif
							//Grava os itens do pedido
							aLinha:={}
							nCampo:=0
							AADD(aLinha,{"C6_NUM",space(06)})
							nCampo+=1
							AADD(aLinha,{"C6_FILIAL",cFila})
							nCampo+=1
							AADD(aLinha,{"C6_PRCVEN",aCols[_x,_nPosPrcven]})
							nCampo+=1
							AADD(aLinha,{"C6_QTDVEN",aCols[_x,_nPosQtdVen]})
							nCampo+=1
							AADD(aLinha,{"C6_USERPRC",aCols[_x,_nPosUPrc]})
							nCampo+=1
							AADD(aLinha,{"C6_USERDES",aCols[_x,_nPosUDes]})
							nCampo+=1
							AADD(aLinha,{"C6_PRUNIT",aCols[_x,_nPosPrUnit]})
							nCampo+=1
							AADD(aLinha,{"C6_DESCONT",aCols[_x,_nPosDescont]})
							nCampo+=1
							AADD(aLinha,{"C6_VALDESC",aCols[_x,_nPosValDesc]})
							nCampo+=1
							AADD(aLinha,{"C6_TES",aCols[_x,_nPosTes]})
							nCampo+=1
							AADD(aLinha,{"C6_PRODUTO",aCols[_x,_nPosProd]})
							nCampo+=1
							AADD(aLinha,{"C6_VALOR",aCols[_x,_nPosValor]})
							nCampo+=1
							AADD(aLinha,{"C6_FORNEC",aCols[_x,_nPosFor]})
							nCampo+=1
							AADD(aLinha,{"C6_QTDORC",aCols[_x,_nPosQOrc]})
							nCampo+=1
							AADD(aLinha,{"C6_TIPODIP",aCols[_x,_nPostipo]})
							nCampo+=1
							AADD(aLinha,{"C6_LOCAL",aCols[_x,_nPosLoca]})
							nCampo+=1
							AADD(aLinha,{"C6_ITEM",aCols[_x,_nPosItem]})
							nCampo+=1
							AADD(aLinha,{"C6_UM",aCols[_x,_nPosUm]})
							nCampo+=1
							AADD(aLinha,{"C6_QTDLIB",aCols[_x,_nPosQtdLib]}) // MCVN - 25/06/09
							AADD(aItens,aLinha)
							ePedido:=.T. //Inclusao direta de Pedido Compartilhado
							//						Elseif aCols[_x,_nPosFor] <> "000002" //Dipromed ou outro fornecedor
						Elseif aCols[_x,_nPosFor] <> "000851" //Dipromed ou outro fornecedor
							//Verificar se e orcamento ou pedido
							If aCols[_x,_nPosTipo] = "2" // Se for orÁamento atualiza atualiza SC6->C6_QTDORC
								aCols[_x,_nPosQOrc]   := aCols[_x,_nPosQtdVen]
								aCols[_x,_nPosBlq]    := "S"
								
								
							ElseIf aCols[_x,_nPosTipo] == "3" //se for programaÁ„o // Atualiza C6_BLQ no C6 - MCVN 17/07/09
								aCols[_x,_nPosBlq] := "S"
							Else //pedido
								aCols[_x,_nPosBlq]    := "N"	// Libera o item no C6_BLQ - MCVN - 17/07/2009
								M->C6_BLQ := "N"
								M->C6_QTDVEN       	  := aCols[_x,_nPosQtdVen]	// Atualiza vari·vel de memÛria
								n:=_x//
								A410QTDGRA()
								A410MultT("M->C6_QTDVEN",aCols[n,_nPosQtdVen]) // Executa rotina para validaÁ„o de campo
								a410Refr("C6_QTDVEN")
								If aCols[_x,_nPosQtdLib] = 0
									lErroEmpe := .t.
								Endif
							Endif
						Endif
					Next
				Elseif  C5DipCom == "2" // pedido nao e compartilhado
					//Alert("Pedido nao e compartilhado")
					//Verificar se e orcamento ou pedido
					// N„o precisa atualizar B2 com informaÁ„o de orÁamento
					For _x := 1 to Len(aCols)
						If aCols[_x,Len(aHeader)+1] == .F.
							If aCols[_x,_nPosTipo] == "2" //se for orcamento // Atualiza QTDORC e C6_BLQ no C6 - MCVN 17/07/09
								aCols[_x,_nPosQOrc]:=aCols[_x,_nPosQtdVen]
								aCols[_x,_nPosBlq] := "S"
							ElseIf aCols[_x,_nPosTipo] == "3" //se for programaÁ„o // Atualiza C6_BLQ no C6 - MCVN 17/07/09
								aCols[_x,_nPosBlq] := "S"
							Else //pedido
								aCols[_x,_nPosBlq]    := "N"	// Libera o item no C6_BLQ - MCVN - 17/07/2009
								M->C6_BLQ := "N"
								M->C6_QTDVEN       	  := aCols[_x,_nPosQtdVen]	// Atualiza vari·vel de memÛria
								n:=_x//
								A410QTDGRA()
								A410MultT("M->C6_QTDVEN",aCols[n,_nPosQtdVen]) // Executa rotina para validaÁ„o de campo
								a410Refr("C6_QTDVEN")
								If aCols[_x,_nPosQtdLib] = 0
									lErroEmpe := .t.
								Endif
							EndIf
						Endif
					Next
				Endif
			Endif
		Elseif altera //Esta alterando um pedido
			cTipoAnt:=Posicione("SC5",1,xFilial("SC5")+M->C5_NUM,"C5_TIPODIP")
			If cTipoAnt <> C5TipoDip
				If !"TMK" $FunName() .And. M->C5_TIPO = "N"
					//Itens que sao da Dipromed alterar a quantidade orcada para a quantidade de venda
					//Itens que sao Health
					If C5DipCom == "1"  // pedido e compartilhado
						For _x := 1 to Len(aCols)
							If aCols[_x,Len(aHeader)+1] == .F.
								If aCols[_x,_nPosFor] <> "000851" //Dipromed ou outro fornecedor
									If aCols[_x,_nPosTipo] == "2" //se for orcamento // Atualiza QTDORC e C6_BLQ no C6 - MCVN 17/07/09
										aCols[_x,_nPosQOrc]:=aCols[_x,_nPosQtdVen]
										aCols[_x,_nPosBlq] := "S"
									ElseIf aCols[_x,_nPosTipo] == "3" //se for programaÁ„o // Atualiza C6_BLQ no C6 - MCVN 17/07/09
										aCols[_x,_nPosBlq] := "S"
									Else //pedido
										aCols[_x,_nPosBlq]    := "N"	// Libera o item no C6_BLQ - MCVN - 17/07/2009
										M->C6_BLQ := "N"
										M->C6_QTDVEN       	  := aCols[_x,_nPosQtdVen]	// Atualiza vari·vel de memÛria
										n:=_x//
										A410QTDGRA()
										A410MultT("M->C6_QTDVEN",aCols[n,_nPosQtdVen]) // Executa rotina para validaÁ„o de campo
										a410Refr("C6_QTDVEN")
										If aCols[_x,_nPosQtdLib] = 0
											lErroEmpe := .t.
										Endif
									Endif
								Elseif aCols[_x,_nPosFor] == "000851" //Health
									//Rotina para inclusao dos itens na empresa Health
									//Posiciona no SC5
									//Candisani - 12/02/09 - Atualizar a quantidade no B2_QORCVEN - conforme email
									Alert("Item Health - Atualiza B2_ORCVEN - 12/02/09")
									
									If nCabec == 0
										DbSelectArea("SC5")
										DbSetOrder(1)
										If dbseek(xFilial("SC5")+M->C5_NUM)
											aCabec:={}
											For nX := 1 To SC5->(fCount())
												AADD(aCabec,{FieldName(nX),FieldGet(nX)})
											Next
											nCabec+=1
										Endif
									Endif
									//Posiciona no SC6
									DbSelectArea("SC6")
									DbSetOrder(1)
									If dbseek(xFilial("SC6")+M->C5_NUM+aCols[_x,_nPosItem])
										aLinha:={}
										For nY := 1 To SC6->(fCount())
											AADD(aLinha,{FieldName(nY),FieldGet(nY)})
										Next
										AADD(aItens,aLinha)
									Endif
									//
								Endif
							Else  // Se for orÁamento para pedido guarda a linha do orÁamento
								If cTipoAnt == '2' .And. C5TipoDip == '1'
									//aCols[_x,Len(aHeader)+1] := .F.
									//aCols[_x,_nPosTipo] := "2"
									//aCols[_x,_nPosBlq]  := "S"
								Endif
							Endif
						Next
					Else
						For _x := 1 to Len(aCols)
							If aCols[_x,Len(aHeader)+1] == .F.
								If aCols[_x,_nPosTipo] == "2" //se for orcamento // Atualiza QTDORC e C6_BLQ no C6 - MCVN 17/07/09
									aCols[_x,_nPosQOrc]:=aCols[_x,_nPosQtdVen]
									aCols[_x,_nPosBlq] := "S"
								ElseIf aCols[_x,_nPosTipo] == "3" //se for programaÁ„o // Atualiza C6_BLQ no C6 - MCVN 17/07/09
									aCols[_x,_nPosBlq] := "S"
								Else //pedido
									aCols[_x,_nPosBlq]    := "N"	// Libera o item no C6_BLQ - MCVN - 17/07/2009
									M->C6_BLQ := "N"
									M->C6_QTDVEN       	  := aCols[_x,_nPosQtdVen]	// Atualiza vari·vel de memÛria
									n:=_x//
									A410QTDGRA()
									A410MultT("M->C6_QTDVEN",aCols[n,_nPosQtdVen]) // Executa rotina para validaÁ„o de campo
									a410Refr("C6_QTDVEN")
									If aCols[_x,_nPosQtdLib] = 0
										lErroEmpe := .t.
									Endif
								Endif
							Else  // Se for orÁamento para pedido guarda a linha do orÁamento
								If cTipoAnt == '2' .And. C5TipoDip == '1'
									//   	aCols[_x,Len(aHeader)+1] := .F.
									//   	aCols[_x,_nPosTipo] := "2"
									//   	aCols[_x,_nPosBlq]  := "S"
								Endif
							Endif
						Next
					Endif
				Endif
			Else
				If !"TMK" $FunName() .And. M->C5_TIPO = "N"
					For _x := 1 to Len(aCols)
						If aCols[_x,Len(aHeader)+1] == .F.
							If aCols[_x,_nPosTipo] == "2" //se for orcamento // Atualiza QTDORC e C6_BLQ no C6 - MCVN 17/07/09
								aCols[_x,_nPosQOrc]:=aCols[_x,_nPosQtdVen]
								aCols[_x,_nPosBlq] := "S"
							ElseIf aCols[_x,_nPosTipo] == "3" //se for programaÁ„o // Atualiza C6_BLQ no C6 - MCVN 17/07/09
								aCols[_x,_nPosBlq] := "S"
							Else //pedido
								aCols[_x,_nPosBlq]    := "N"	// Libera o item no C6_BLQ - MCVN - 17/07/2009
								M->C6_BLQ := "N"
								M->C6_QTDVEN       	  := aCols[_x,_nPosQtdVen]	// Atualiza vari·vel de memÛria
								n:=_x//
								A410QTDGRA()
								A410MultT("M->C6_QTDVEN",aCols[n,_nPosQtdVen]) // Executa rotina para validaÁ„o de campo
								a410Refr("C6_QTDVEN")
								If aCols[_x,_nPosQtdLib] = 0
									lErroEmpe := .t.
								Endif
							Endif
						Endif
					Next
				EndIf
			Endif
		Else
			//	Alert("2")
		Endif
		//Grava startjob na empresa Health
		If C5TipoDip == "1" .and. len(aItens) > 0 .And. C5DipCom == "1"//Pedido compartilhado e itens da empresa Health
			//Alert("Antes do Startjob")
			qout("Antes StartJob")
			STARTJOB("U_GrvHea",getenvserver(),.t.,cEmpa,cFila,aCabec,aItens,nCampo,ePedido)
			qout("Apos StartJob")
			//GrvHea()
		Endif
	Elseif C5TipoDip $ "2/3" //OR«AMENTO OU PROGRAMA«√O
		If Inclui
			For _x := 1 to Len(aCols)
				If aCols[_x,_nPosTipo]    == "2" //se for orcamento // Atualiza QTDORC e C6_BLQ no C6 - MCVN 17/07/09
					aCols[_x,_nPosQOrc]   :=aCols[_x,_nPosQtdVen]
					aCols[_x,_nPosBlq]    := "S"
				ElseIf aCols[_x,_nPosTipo]== "3" //se for programaÁ„o // Atualiza C6_BLQ no C6 - MCVN 17/07/09
					aCols[_x,_nPosBlq]    := "S"
				Endif
			Next _x
		Elseif Altera
			For _x := 1 to Len(aCols)
				If aCols[_x,Len(aHeader)+1]   == .F.
					If aCols[_x,_nPosTipo]    == "2" //se for orcamento // Atualiza QTDORC e C6_BLQ no C6 - MCVN 17/07/09
						aCols[_x,_nPosQOrc]   :=aCols[_x,_nPosQtdVen]
						aCols[_x,_nPosBlq]    := "S"
						/*M->C6_BLQ := "S"
						M->C6_QTDVEN    := aCols[_x,_nPosQtdVen]	// Atualiza vari·vel de memÛria
						n:=_x//
						A410QTDGRA()
						A410MultT("M->C6_QTDVEN",aCols[n,_nPosQtdVen]) // Executa rotina para validaÁ„o de campo
						a410Refr("C6_QTDVEN")*/
					ElseIf aCols[_x,_nPosTipo]== "3" //se for programaÁ„o // Atualiza C6_BLQ no C6 - MCVN 17/07/09
						aCols[_x,_nPosBlq]    := "S"
						/*M->C6_BLQ := "S"
						M->C6_QTDVEN       	  := aCols[_x,_nPosQtdVen]	// Atualiza vari·vel de memÛria
						n:=_x//
						A410QTDGRA()
						A410MultT("M->C6_QTDVEN",aCols[n,_nPosQtdVen]) // Executa rotina para validaÁ„o de campo
						a410Refr("C6_QTDVEN")*/
					Endif
				Elseif aCols[_x,Len(aHeader)+1] == .T. // linha deletada na alteracao
					// N„o faz nada // MCVN - 17/07/09
				Endif
			Next
		Endif
	Endif
	n := _n
Endif

//Candisani
// Fim do tratamento para controle de pedido/orÁamento/programaÁ„o pelo MATA410



// Marcio
//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥Atualiza os preÁos com descontos≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ

If !"TMK" $FunName() .And. M->C5_TIPO = "N"
	For _n := 1 to Len(aCols)
		If aCols[_n,_nPosUDes] > 0
			aCols[_n,_nPosDescont]	:= 0
			aCols[_n,_nPosValDesc]	:= 0
			aCols[_n,_nPosPrcVen] 	:= aCols[_n,_nPosPrUnit]
			aCols[_n,_nPosValor] 	:= aCols[_n,_nPosPrUnit]*aCols[_n,_nPosQtdVen]
			Ma410Rodap(,,0)
		Endif
	Next
	If ( Type("l410Auto") == "U" .OR. !l410Auto ) // JBS 12/04/2006
		oGetDad:oBrowse:Refresh()
	EndIf
Endif

If (!"TMK" $ FunName())
	If !Mta410VerTransp(M->C5_TRANSP)  // MCVN - 17/05/2007
		Return(.f.)
	Endif
Endif

// Mensagem referente a emiss„o da nota fiscal com 2™ descriÁ„o - MCVN 10/04/2008
If !"TMK" $FunName() .And. M->C5_TIPO = "N" .And. !("DIPAL10" $ Funname()) .And. SA1->A1_DIFEREN $ "ET"
	
	For _pn := 1 to Len(aCols)
		// Verificando informaÁıes referente a segunda descriÁ„o dos produtos - MCVN 06/08/08
		If (!aCols[_pn,Len(aHeader)+1])  // N„o verifica os deletados
			If SA1->A1_DIFEREN == "T" .And. (Empty(Posicione("SB1",1,xFilial("SB1")+aCols[_pn,_nPosProd],"B1_SEGUM")) .Or. ;
				Posicione("SB1",1,xFilial("SB1")+aCols[_pn,_nPosProd],"SB1->B1_CONV") = 0)
				Aadd( _aInfoPro,Alltrim(aCols[_pn,_nPosProd]) )
			ElseIf SA1->A1_DIFEREN == "E" .And. (Empty(Posicione("SB1",1,xFilial("SB1")+aCols[_pn,_nPosProd],"B1_SEGUM")) .Or. ;
				Posicione("SB1",1,xFilial("SB1")+aCols[_pn,_nPosProd],"SB1->B1_CONV") = 0 .Or. ;
				Empty(Posicione("SB1",1,xFilial("SB1")+aCols[_pn,_nPosProd],"SB1->B1_DESC2")))
				Aadd( _aInfoPro,Alltrim(aCols[_pn,_nPosProd]) )
			Endif
		Endif
	Next
	
	
	If SA1->A1_DIFEREN == "E"
		_mInfoCli := 'O cliente deste pedido est· marcado como "ERIKA", a nota ser· emitida pela 2a. descriÁ„o, ser· alterado tambÈm: Quantidade, PreÁo Unit·rio e Unidade de medida.'
		If !(MsgBox(_mInfoCli," CONFIRMA EMISS√O DO PEDIDO UTILIZANDO A 2™ DESCRI«√O DOS PRODUTOS?",'YESNO'))
			DbSelectArea("SA1")
			If MsgBox("O cliente ser· alterado para n„o utilizar 2™ descriÁ„o. Confirma AlteraÁ„o? ","Atencao","YESNO")
				RecLock("SA1",.F.)
				SA1->A1_DIFEREN := "N"
				SA1->(MsUnLock())
				lUsa2Desc := .F.
			EndIF
		Else
			lUsa2Desc := .T.
		Endif
		
	ElseIf SA1->A1_DIFEREN == "T"
		_mInfoCli := 'O cliente deste pedido est· marcado como "TAIS", na emiss„o da nota ser· alterado os campos: Quantidade, PreÁo Unit·rio e Unidade de medida.'
		If !(MsgBox(_mInfoCli," CONFIRMA EMISS√O DO PEDIDO UTILIZANDO A 2™ DESCRI«√O DOS PRODUTOS?",'YESNO'))
			DbSelectArea("SA1")
			If MsgBox("O cliente ser· alterado para n„o utilizar 2™ descriÁ„o. Confirma AlteraÁ„o? ","Atencao","YESNO")
				RecLock("SA1",.F.)
				SA1->A1_DIFEREN := "N"
				SA1->(MsUnLock())
				lUsa2Desc := .F.
			EndIF
		Else
			lUsa2Desc := .T.
		Endif
	EndIf
	
	If Len(_aInfoPro) > 0 .And. _lRetorno .And. lUsa2Desc
		For aa := 1 to Len(_aInfoPro)
			_mInfoPro += If(Empty(_mInfoPro),"Produto(s) com problema no cadastro referente a 2™ descriÁ„o, 2™ UM ou Fator de convers„o: Produto(s) "+_aInfoPro[aa]," / "+_aInfoPro[aa])
		Next
		
		MsgBox(_mInfoPro," O PEDIDO FICAR¡ BLOQUEADO, FAVOR SOLICITAR CORRE«√O DO(S) PRODUTO(S)!",'ALERT')
		_aInfoPro := {}
		_mInfoPro := ""
		M->C5_PARCIAL := 'T'
	Endif
	_aInfoPro := {}
	_mInfoPro := ""
	lUsa2Desc := .F.
Endif

//-- D'Leme - 04/Nov/2011: ValidaÁ„o do DDD e Telefone do Cliente.
If _lRetorno .And. !("TMK"$FunName()) .And. !("DIPAL10" $ Funname()) .AND. M->C5_TIPO $ ('N/C/I')
	_cNewTel := ""
	For _pn := 1 To Len(SA1->A1_TEL)
		If Substr(SA1->A1_TEL,_pn,1) $ "0123456789"
			_cNewTel += Substr(SA1->A1_TEL,_pn,1)
		EndIf
	Next _pn
	
	If (Len(AllTrim(SA1->A1_DDD)) != 3 .Or. Len(_cNewTel) < 8 .Or. Len(_cNewTel) > 9)
		MsgAlert("Verifique o DDD e Telefone do Cliente - existe novo padr„o!"+Chr(13)+Chr(10)+;
		"O DDD deve conter 3 dÌgitos (ex:011) e o telefone deve conter 8 ou 9 dÌgitos numÈricos.","AtenÁ„o")
		_lRetorno := .F.
		If Len(_cNewTel) > 9 .And. Len(_cNewTel) < 12 .And. ;
			(Len(AllTrim(SA1->A1_DDD)) != 3 .Or. Right("0"+AllTrim(SA1->A1_DDD),3) == Left(_cNewTel,3))
			_cNewDDD := Right("0"+Substr(_cNewTel,1,Len(_cNewTel)-8),3)
			_cNewTel := Right(_cNewTel,8)
			If MsgBox("Deseja alterar o DDD e Telefone para o novo padr„o? "   +Chr(13)+Chr(10)+Chr(13)+Chr(10)+;
				"DDD + Telefone ser· alterado De   : " + Chr(13) + Chr(10) +;
				"   "+AllTrim(SA1->A1_DDD) + " " + AllTrim(SA1->A1_TEL) +Chr(13)+Chr(10)+ ;
				"   "+Transform(AllTrim("("+AllTrim(SA1->A1_DDD)+") "+AllTrim(SA1->A1_TEL)),"@r (999) 999999999")+ " (Impress„o Nf-e/CT-e)"  +Chr(13)+Chr(10)+Chr(13)+Chr(10)+;
				"DDD + Telefone ser· alterado para : "  + Chr(13) + Chr(10) +;
				"   "+AllTrim(_cNewDDD) + " " + AllTrim(_cNewTel) +Chr(13)+Chr(10)+ ;
				"   "+Transform(AllTrim("("+AllTrim(_cNewDDD)+") "+AllTrim(_cNewTel)),"@r (999) 999999999")+ " (Impress„o Nf-e/CT-e)";
				,"AtenÁ„o","YESNO")
				
				RecLock("SA1",.F.)
				SA1->A1_DDD := _cNewDDD
				SA1->A1_TEL := _cNewTel
				SA1->(MsUnLock())
				_lRetorno := .T.
				
			EndIf
		EndIf
	EndIf
EndIf

// Mostra endereÁo de transportadora para confirmar - 26/07/09
IF !("TMK"$FunName()) .And. !("DIPAL10" $ Funname())

	If M->C5_TRANSP <> "100000" .And. M->C5_TPFRETE$"C/I"
		For _nI := 1 to Len(aCols)
			If !aCols[_nI,Len(aHeader)+1] .And.;
				Alltrim(aCols[_nI,_nPosProd])$GetNewPar("ES_PROSANE","081022/011996/011953/081024/081235/081018/081023/081014") .And.;
				VldQtdEmp(M->C5_NUM,aCols[_nI,_nPosProd])
				Aviso("AtenÁ„o","O Produto "+AllTrim(aCols[_nI,_nPosProd])+" (Item: "+AllTrim(aCols[_nI,_nPosItem])+") sÛ pode ser transportado pela EMOVERE.",{"Ok"},1)
				Return(.f.)
			EndIf
		Next
	EndIf	
	
	// Verifica se existem valores negativos no pedido - MCVN 17/09/09
	If M->C5_FRETE < 0 .OR. M->C5_DESPESA < 0 .OR. M->C5_SEGURO < 0 .Or. M->C5_DESCONTO < 0
		If M->C5_FRETE < 0
			Alert("O FRETE est· com valor negativo. Favor corrigir ou falar com o TI !")
		ElseIf M->C5_DESPESA < 0
			Alert("A DESPESA est· com valor negativo. Favor corrigir ou falar com o TI !")
		ElseIf M->C5_SEGURO < 0
			Alert("o SEGURO est· com valor negativo. Favor corrigir ou falar com o TI !")
		Else
			Alert("O DESCONTO est· com valor negativo. Favor corrigir ou falar com o TI !")
		Endif
		_lRetorno  := .F.
	Endif
	
	If 	lErroEmpe
		//Alert("DivergÍncia no empenho de Produto no estoque, Favor avisar TI.")
		//_lRetorno := .F.
		qout("Erro no pedido "+M->C5_NUM)
	EndIf
	
	If _lRetorno
		
		If M->C5_TIPO = "N"
			U_ConfEndEnt()
		EndIf
		
		u_VldDestFre()  
		
		u_DipRegCom()
		
		// RBorges 13/02/2019 - Chama a funÁ„o de transferÍncia de produto
		If M->C5_TIPODIP == "1" .And. M->C5_TIPO == "N" .And. cEmpAnt == '01' .And. SB1->B1_MALADIR <> 'S'
			U_DIPA053C(.F.)
		EndIf
		
		// RBorges 13/02/2019 - Mostrar uma tela de transferÍncia com os produtos solicitados
		If cEmpAnt == '01'.And. M->C5_TIPODIP == "1"
		 	If cEmpAnt+cFilAnt == '0101'
		 		U_TRANSFE(M->C5_NUM,'1')
			Else
		 		U_TRANSFE(M->C5_NUM,'2')	
			EndIf
		EndIf
		
		If M->C5_TIPODIP == "1"
			_lRetorno := MsgBox("Confirma Pedido? ","Atencao","YESNO") // 29/07/09 MCVN
		ElseIf M->C5_TIPODIP == "2"
				_lRetorno := MsgBox("Confirma OrÁamento? ","Atencao","YESNO") // 29/07/09 MCVN
		Else
			_lRetorno := MsgBox("Confirma ProgramaÁ„o? ","Atencao","YESNO") // 29/07/09 MCVN
		Endif
		
	Endif
	If Empty(M->C5_TRANSP)
		MsgBox("O campo transportadora est· vazio! Favor corrigir.","Atencao","Alert") // 28/04/10 - MCVN
		_lRetorno := .F.
	Endif
Endif

If _lRetorno .And. !("TMK"$FunName()) .And. !("DIPAL10" $ Funname())
	For _nAux := 1 to Len(aCols)			
		If !aCols[_nAux,Len(aHeader)+1] .And. !u_VldPerPro(aCols[_nAux,_nPosprod])
		 	Aviso("AtenÁ„o","Produto "+AllTrim(aCols[_nAux,_nPosprod])+" com promoÁ„o vencida."+CHR(13)+CHR(10)+"Fale com o pessoal de COMPRAS",{"Ok"})
		 	_lRetorno := .F. 
		 	Exit
		EndIf
	Next    
EndIf   

If _lRetorno .And. !("TMK"$FunName()) .And. !("DIPAL10" $ Funname())
	If (M->C5_TPFRETE <> "F" .And. M->C5_TRANSP <> '100000'  .And. M->C5_TRANSP <> '000111')
		For _nAux := 1 to Len(aCols)			
			If !aCols[_nAux,Len(aHeader)+1] .And. AllTrim(aCols[_nAux,_nPosFor])$"100091/000227" .And. !AllTrim(aCols[_nAux,_nPosprod]) $ GetNewPar("ES_PRODEXC","018585")
			 	MsgInfo("O produto "+AllTrim(aCols[_nAux,_nPosprod])+" sÛ pode ser enviado por FOB ou pela EMOVERE.","100091/000227 - ES_PRODEXC")
			 	_lRetorno := .F. 
			 	Exit
			EndIf
		Next
	EndIf    
EndIf   


If _lRetorno .And. !("TMK"$FunName()) //.And. !("DIPAL10" $ Funname()) - RBorges 25/06/2019 - DIPAL10 retirado da validaÁ„o conforme Maximo.
	If M->C5_TRANSP$GetNewPar("ES_TRVTRAN","000204/000905/123455") .And. M->C5_TPFRETE == "C" .And. TRTAtiva(nil,M->C5_TRANSP,M->C5_CLIENTE) .And. !M->C5_CLIENTE $ GetNewPar("ES_TRVTEXC","008512")

		If (M->C5_CLIENTE$GetNewPar("ES_CLIETDE","022992/013434/005943/011373/015301/020224/023382/001648/003791/020156/022438/019435/007300/016209/000068/014138/000273/002564/000012/005249/022903/013527/020731"))

			If MsgYesNo("Cliente com taxa de difÌcil entrega para esta transportadora."+CHR(13)+CHR(10)+CHR(13)+CHR(10)+"Deseja liberar o pedido?","AtenÁ„o!")
				_lRetorno := .T. 	
				U_DiprKardex(M->C5_NUM,U_DipUsr(),,.t.,"69") // JBS 29/08/2005
			Else
				_lRetorno := .F. 	
			EndIf

		Else

			Aviso("ES_TRVTEXC","Cliente com difÌcil entrega para esta transportadora."+CHR(13)+CHR(10)+"N„o ser· permitido enviar frete CIF."+CHR(13)+CHR(10)+"Mude o tipo de frete ou a transportadora.",{"Ok"})
	 		_lRetorno := .F. 

		EndIf
		
	EndIf
	
EndIf

If _lRetorno .And. !("TMK"$FunName()) .And. !("DIPAL10" $ Funname()) .And. M->C5_TIPODIP == '1' 
	If !(M->C5_TRANSP$'000111/000112/000133/100000')		
		cMsgProd := ""
		For _nAux := 1 to Len(aCols)			
			If AllTrim(aCols[_nAux,_nPosprod])$GetNewPar("ES_PRODLIQ","") .Or. AllTrim(aCols[_nAux,_nPosprod])$GetNewPar("ES_PRODLI1","")
				cMsgProd += AllTrim(aCols[_nAux,_nPosprod])+", "
			EndIf
		Next    
		
		If !Empty(cMsgProd)
			Aviso("ES_PRODLIQ","Alguns itens deste pedido sÛ podem ser enviados pela transportadora EMOVERE ou Cliente Retira"+CHR(10)+CHR(13)+;
								"Produtos: "+SubStr(cMsgProd,1,Len(cMsgProd)-2),{"Ok"},2,"Somente EMOVERE ou Cliente Retira")
			_lRetorno := .F.
		EndIf		
	EndIf
EndIf

If _lRetorno .And. !("TMK"$FunName()) .And. !("DIPAL10" $ Funname())
	For _nI := 1 to Len(aCols)
		If !aCols[_nI,Len(aHeader)+1]   			
			_lRetorno := u_VldCxFech(aCols,aHeader,_nI)
			If !_lRetorno
				Exit
			EndIf
		EndIf
	Next _nI			
EndIf


If _lRetorno
	For _nI := 1 to Len(aCols)
		If !aCols[_nI,Len(aHeader)+1]   
			cSQL := " SELECT "
			cSQL += " 	TOP 1 D1_FCICOD FCI "
			cSQL += " 	FROM "
			cSQL += 		RetSQLName("SD1")
			cSQL += " 					WHERE "
			cSQL += " 						D1_FILIAL IN('01','04') AND "
			cSQL += " 						D1_COD = '"+AllTrim(aCols[_nI,_nPosProd])+"' AND "
			cSQL += " 						D1_TIPO = 'N' AND "
			cSQL += " 						D1_FCICOD <> ' ' AND "
			cSQL += " 						D_E_L_E_T_ = ' ' "
			cSQL += " 			ORDER BY R_E_C_N_O_ DESC "
			
			cSQL := ChangeQuery(cSQL)
			dbUseArea(.T.,"TOPCONN",TCGenQry(,,cSQL),"QRYTRB",.F.,.T.)
            
			If !QRYTRB->(Eof())
				aCols[_nI,_nPosFCI] := QRYTRB->FCI		
			EndIf
			QRYTRB->(dbCloseArea())
		EndIf
	Next _nI		
EndIf                                  

If _lRetorno .And. !("TMK"$FunName()) .And. !("DIPAL10"$Funname())
	For _nI := 1 to Len(aCols)                     
		If !aCols[_nI,Len(aHeader)+1]   
			If &(GetNewPar("ES_FORMPED","Val(StrTran(Posicione('SE4',1,XFILIAL('SE4')+M->C5_CONDPAG,'E4_COND'),',',''))>28 .And. AllTrim(aCols[_nI,_nPosProd])$'010684/OP0000' .And. aCols[_nI,_nPosPrcven]<Posicione('SB1',1,xFilial('SB1')+aCols[_nI,_nPosProd],'B1_PRVMINI')"))
				Aviso("AtenÁ„o",GetNewPar("ES_MENSPED","Este produto sÛ pode ser liberado com este valor no pagamento 005 (28 dias)."),{"Ok"})
				_lRetorno := .F.
			EndIf	
		EndIf
	Next _nI
EndIf

//KARDEX
IF _lRetorno
	IF !("TMK"$FunName()) .And. !("DIPAL10" $ Funname())
		If M->C5_TIPODIP == "2"
			U_DiprKardex(M->C5_NUM,U_DipUsr(),,.t.,If(Inclui,"48","43")) // JBS 29/08/2005
		ElseIf  M->C5_TIPODIP == "3"
			U_DiprKardex(M->C5_NUM,U_DipUsr(),,.t.,If(Inclui,"44","45")) // JBS 29/08/2005
		Else
			U_DiprKardex(M->C5_NUM,U_DipUsr(),,.t.,If(Inclui,"05","06")) // JBS 29/08/2005
		Endif
		If !EMPTY(M->C5_SENHPAG) .OR. !EMPTY(M->C5_SENHMAR) .OR. !EMPTY(M->C5_SENHCID)
			U_DiprKardex(M->C5_NUM,U_DipUsr(),,.t.,"27") // JBS 29/08/2005
		EndIf
	ENDIF
ENDIF


RestArea(_areaSE4)
RestArea(_areaSB1)
RestArea(_areaSZ3)
RestArea(_xAlias)

//-- D'Leme - 23/08/2011: AÁteraÁ„o do modo de reserva no PV
If _lRetorno
	U_DIPXRESE("SV_NEW", M->C5_NUM)
	U_DIPXRESE("ALT_NEW", M->C5_NUM)
EndIf
Return(_lRetorno)
/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥MTA410    ∫Autor  ≥Microsiga           ∫ Data ≥  09/25/14   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥                                                            ∫±±
±±∫          ≥                                                            ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ AP                                                        ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
User function ValFrete(_cProFrete)

If _cProFrete = "FRETE"
	_cValFrete := cValFret	
Else
	_cValFrete := " "
EndIf

Return(_cValFrete)
/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±∫Programa  ≥CalcuFrete∫Autor  ≥   Alexandro Dias   ∫ Data ≥  04/08/01   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥ Atualiza o peso liquido e bruto do pedido.                 ∫±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
User Function CalcuFrete(_cPrograma)

Local _nPesoLi		:= 0
Local _nPesoBr		:= 0
Local _nVrPesoExc	:= 0
Local _nVlrTotal	:= 0
local _nVlrFrete	:= 0
Local _lRetorno		:= .T.
Local _lReto   		:= .T.
Local _xAlias		:= GetArea()
Local _nPosVol		:= aScan(aHeader,{|x| Alltrim(x[2])==IIF("TMK"$FunName(),"UB_UNSVEN","C6_UNSVEN") })
Local _nPosQt		:= aScan(aHeader,{|x| Alltrim(x[2])==IIF("TMK"$FunName(),"UB_QUANT","C6_QTDVEN") })
Local _nPosVrTot	:= aScan(aHeader,{|x| Alltrim(x[2])==IIF("TMK"$FunName(),"UB_VLRITEM","C6_VALOR") })
//Local _nPosProd		:= aScan(aHeader,{|x| Alltrim(x[2])==IIF("TMK"$FunName(),"UB_PRODUTO","C6_PRODUTO") })
//Local _nPosValor	:= aScan(aHeader,{|x| Alltrim(x[2])==IIF("TMK"$FunName(),"UB_VLRITEM","C6_VALOR") })
Local _nValor		:= 0
Local _areaSB1		:= SB1->(getarea())
Local _areaSZ3		:= SZ3->(getarea())
Local _cNomeRot 	:= _cPrograma
Local _nLin         := 0
Local _OperLicita 	:= GetMV("MV_OPERLIC") 
Local nI                                    
                                                                         
Private _nPosPrcven  := aScan(aHeader, { |x| Alltrim(x[2]) == "C6_PRCVEN"})
Private _nPosQtdVen	 := aScan(aHeader, { |x| Alltrim(x[2]) == "C6_QTDVEN"})
Private _nPosPrUnit	 := aScan(aHeader, { |x| Alltrim(x[2]) == "C6_PRUNIT"})
Private _nPosprod    := aScan(aHeader, { |x| Alltrim(x[2]) == "C6_PRODUTO"})
Private _nPosValor   := aScan(aHeader, { |x| Alltrim(x[2]) == "C6_VALOR"  })
Private _nPosMini    := aScan(aHeader, { |x| Alltrim(x[2]) == "C6_PRVMINI"})
Private _nPosSupe    := aScan(aHeader, { |x| Alltrim(x[2]) == "C6_PRVSUPE"})
Private _nPosCSis    := aScan(aHeader, { |x| Alltrim(x[2]) == "C6_XCALCSI"})
Private _nPosQtdVen	 := aScan(aHeader, { |x| Alltrim(x[2]) == "C6_QTDVEN"})
Private _nPosUPrc 	 := aScan(aHeader, { |x| Alltrim(x[2]) == "C6_USERPRC"})
Private _nPosNota    := aScan(aHeader, { |x| Alltrim(x[2]) == "C6_NOTA"})

static cValFret 	:= ""        

/*
If ISINCALLSTACK("LOJA901A") .Or. ISINCALLSTACK("LOJA901")
	RestArea(_areaSB1)
	RestArea(_areaSZ3)
	RestArea(_xAlias)
	Return .T.
EndIf
*/

If  (Type("l410Auto") <> "U" .and. l410Auto)  .Or. (readvar()='M->C5_TRANSP' .And. Procname(1)='CHECKSX3')  //JBS/MCVN - 05/05/10
	_lRetorno := .t.
	Return(_lRetorno)
EndIf

U_DIPPROC(ProcName(0),U_DipUsr()) // JBS 03/11/2005 - Gravando o nome do Programa no SZU
Private _cCliEspecial := GetMV("MV_CLIESPE") // Cliente especial

Private cFileWork // JBS 17/01/2006
// Quando esta funÁ„o for chamada do call center
// E n„o estiver no folder de Televendas, dever sair
// sem excutar nada.
If "TMK"$FunName() .and. nFolder <> TELEVENDAS  // JBS 04/12/2005
	Return(.t.)
EndIf
//--------------------------------------------
// Se o arq temp j· existe o bt foi acionado
// mais de uma vez, ent„o sai da rotina.
//--------------------------------------------
If Select("WORK_FRT") > 0 // JBS 31/01/2006, 10:30
	If ( Type("l410Auto") == "U" .OR. !l410Auto )
		MsgInfo('O Calculo do Frete j· est· em execuÁ„o!'+chr(13)+chr(10)+;
		'Por favor aguarde o termino da execuÁ„o!','AtenÁ„o')
	EndIf
	return(.t.)
EndIf

//-----------------------------------------------------
// Calcula:
// - o peso bruto total do pedido
// - o peso liquido total do pedido
// - valor total do pedido
//-----------------------------------------------------
For _nLin := 1 to Len(aCols)
	IF !aCols[_nLin,Len(aHeader)+1]
		SB1->(DbSetOrder(1))
		IF SB1->(DbSeek(xFilial("SB1")+aCols[_nLin,_nPosProd]))
			_nPesoBr+=(aCols[_nLin,_nPosQt]*SB1->B1_PESO)
			_nPesoLi+=(aCols[_nLin,_nPosQt]*SB1->B1_PESO)
			_nVlrTotal+=aCols[_nLin,_nPosVrTot]
		EndIF
	EndIF
Next
//-----------------------------------------------------
//  Calculando o Frete do Pedido
//-----------------------------------------------------
If "TMK"$FunName()
	M->UA_PBRUTO  := ( _nPesoBr )
	M->UA_PESOL   := _nPesoLi
	IF M->UA_TPFRETE $ "IC"
		// Consiste se o destino de entrega est· preenchido
		If !Empty(M->UA_DESTFRE)
			// Chama a funÁ„o que vai calcular o frete
			// para as diversas transportadoras que
			// atendam aos parametros do cliente.
			If (_lRetorno:=U_ClcLimite("TMK",_nVlrTotal,(_nPesoBr),_cNomeRot))
				If FunName(0)$"TMKA271"
					AVALORES[4] := M->UA_FRETE
					aValores[6] := aValores[1]-aValores[2]+aValores[3]+aValores[4]+aValores[5]
					MaFisAlt("NF_FRETE",aValores[4])
					MaFisToCols(aHeader,aCols,,"TMK271")
					Eval(bRefresh)
					Eval(bGDRefresh)
					Tk273Refresh(avalores)
				EndIf
			EndIf
		Else
			MsgBox("Informe o Destino do Frete para calcular o Valor do Frete !!!","Atencao","Alert")
			M->UA_FRETE := 0
			IF FunName(0)$"TMKA271"
				AVALORES[4] := M->UA_FRETE
				aValores[6] := aValores[1]-aValores[2]+aValores[3]+aValores[4]+aValores[5]
				MaFisAlt("NF_FRETE",aValores[4])
				MaFisToCols(aHeader,aCols,,"TMK271")
				Eval(bRefresh)
				Eval(bGDRefresh)
				Tk273Refresh(avalores)
			Endif
			_lRetorno  := .F.
		EndIF
	ELSE
		//	MsgBox("Somente para Tipo de Frete Informado sera calculado o Frete !!!","Atencao","Alert")
		M->UA_FRETE := 0
		IF FunName(0)$"TMKA271"
			AVALORES[4] := M->UA_FRETE
			aValores[6] := aValores[1]-aValores[2]+aValores[3]+aValores[4]+aValores[5]
			MaFisAlt("NF_FRETE",aValores[4])
			MaFisToCols(aHeader,aCols,,"TMK271")
			Eval(bRefresh)
			Eval(bGDRefresh)
			Tk273Refresh(avalores)
		Endif
	EndIF
Else
	U_SetC5Var("M->C5_PBRUTO",_nPesoBr)
	M->C5_PBRUTO:=_nPesoBr
	
	U_SetC5Var("M->C5_PESOL",_nPesoLi)
	M->C5_PESOL:=_nPesoLi
	
	If M->C5_TPFRETE $ "IC"
		// Consiste se o destino de entrega est· preenchido
		If  !Empty(M->C5_DESTFRE)
			// Chama a funÁ„o que vai calcular o frete
			// para as diversas transportadoras que
			// atendam aos parametros do cliente.
			cTranspAnt := M->C5_TRANSP 
			_lRetorno:=U_ClcLimite("PED",_nVlrTotal,_nPesoBr,_cNomeRot)
			If Upper(PROCNAME(1)) == "U_MTA410" .And. cTranspAnt <> M->C5_TRANSP
		   		u_DipCalcCIF()			  
		 	EndIf
		Else
			// Adverte que o destino de entrega no foi informado
			If ( Type("l410Auto") == "U" .OR. !l410Auto )
				MsgBox("Informe o Destino do Frete para calcular o Valor do Frete !!!","Atencao","Alert")
			EndIf
			// Limpa o frete para evitar problemas
			U_SetC5Var("M->C5_FRETE",0)
			M->C5_FRETE := 0
			_lRetorno  := .F.
		EndIF
	Else
		// Adverte o usuario quanto ao tipo do frete
		If ( Type("l410Auto") == "U" .OR. !l410Auto )
			MsgBox("Somente para Tipo de Frete Informado sera calculado o Frete !!!","Atencao","Alert")
		EndIf
		// Limpa o frete para evitar problemas
		U_SetC5Var("M->C5_FRETE",0)
		M->C5_FRETE := 0
		//Valida a transportadora quando for Emovere - Felipe Duran - 25/10/19
		If M->C5_TPFRETE =='F' .AND. M->C5_TRANSP =='100000'
			MsgBox("Para Emovere o Frete n„o pode ser igual a FOB !!!","Atencao","Alert")
			U_SetC5Var("M->C5_TRANSP",'')
			M->C5_TRANSP := ''
		EndIf
		//FIM	
	EndIF
Endif

_nPosValor := aScan(aHeader, { |x| Alltrim(x[2]) == IIF("TMK"$FunName(),"UB_VLRITEM","C6_VALOR") })
_nValor    := 0
//≥ Soma valor total da nota.                           ≥
For _nLin := 1 to Len(aCols)
	IF !aCols[_nLin,Len(aHeader)+1]
		_nValor := _nValor + aCols[_nLin,_nPosValor]
	EndIF
Next
IF _lRetorno == .t.
	IF !"TMK"$FunName()
		IF !EMPTY(M->C5_CONDPAG)
			
			dbSelectArea("SE4")
			dbSeek(xFilial("SE4")+M->C5_CONDPAG)
			
			//If M->C5_CONDPAG == '167' .and. M->C5_OPERADO $ '000013/000056/000106/000109'
			If M->C5_CONDPAG == '167' .and. M->C5_OPERADO $ _OperLicita // Buscando no par‚metro os operadores de LicitaÁ„o MCVN - 09/10/2007
				_lRetorno := .t.
			ElseIf _nValor >= SE4->E4_INFER .and. _nValor <= SE4->E4_SUPER
				_lRetorno := .t.
			ElseIf M->C5_CONDPAG == SA1->A1_COND // Caso a condiÁ„o de pagamento do pedido seja a mesma do cadastro do cliente n„o pede senha  -  MCVN 09/10/2007
				_lRetorno := .t.
			Else
				If ( Type("l410Auto") == "U" .OR. !l410Auto )
					_lRetorno := .f.
					If M->C5_TIPO=='N'.AND.!M->C5_CLIENTE $ _cCliEspecial
						If cEmpAnt<>'01'
							//Desabilitado para testes com AprovaÁ„o Digital							
							If !('MATC090'$FunName()) 
							
								If !U_DipSenha("PAG", M->C5_CONDPAG, _nValor, 0,.f.) // Se n„o possui senha j· confirmada
								
							 		_lRetorno := U_Senha("PAG",_nValor,0,0)
									
									If _lRetorno
										U_DipSenha("PAG", M->C5_CONDPAG, _nValor, 0,.t.)
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
					Else
						_lRetorno := .t.
					Endif
				EndIF
			EndIF
		Endif
	Endif
EndIf 

/*
 +=========================================================================+ 
 |Finalidade da validaÁ„o, n„o permitir a liberaÁ„o do pedido se o mesmo   |
 |n„o estiver dentro da condiÁıes do DO CASE.08/12/2014                    |
 +=========================================================================+ 
 */

For nI := 1 TO Len(aCols)
	If SB1->(DbSeek(xFilial("SB1")+aCols[nI,_nPosProd]))
		If 	!aCols[nI,Len(aHeader)+1] .And.;
			!(SB1->B1_HABILIT == "L" .And. "DIPAL10" $ FunName()) .And.;
			("TMK" $ FunName() .Or. "DIPAL10" $ FunName() .Or. M->C5_TIPO='N') .And.;
			Empty(aCols[nI,_nPosNota])
			
			cMsgAux := ""
			
			Do Case
				Case SB1->B1_PRV1 == 0
					cMsgAux := "Produto "+SB1->B1_COD+" sem preÁo de lista."+Chr(13)+"Fale com o pessoal de compras para que o pedido seja liberado!"+Chr(13)+Chr(13)+"Obrigado."
				Case SB1->B1_UPRC == 0 // N„o libera pedido se o ˙ltimo preÁo de compra for igual a 0(Zero)  MCVN - 03/11/08
					cMsgAux := "Produto "+SB1->B1_COD+" sem O ˙ltimo preÁo de compra."+Chr(13)+"Fale com o pessoal de compras para que o pedido seja liberado!"+Chr(13)+Chr(13)+"Obrigado."
				Case (SB1->B1_RASTRO <> 'L' .Or. SB1->B1_LOCALIZ <> 'S') .AND. SB1->B1_TIPO = 'PA' // N„o libera pedido com produto sem Lote e/ou sem localizaÁ„o
					cMsgAux := "Produto "+SB1->B1_COD+" sem lote e/ou sem localizaÁ„o."+Chr(13)+"Fale com o pessoal de compras para que o pedido seja liberado!"+Chr(13)+Chr(13)+"Obrigado."
				Case (Empty(SB1->B1_POSIPI)) .AND. SB1->B1_TIPO = 'PA'	// N„o libera pedido com produto sem CLASSIFICA«√O FISCAL - MCVN 08/10/2008
					cMsgAux := "Produto "+SB1->B1_COD+" sem NCM/NBM (CLASSIFICA«√O FISCAL)."+Chr(13)+"Fale com o pessoal de compras para que o pedido seja liberado!"+Chr(13)+Chr(13)+"Obrigado."
				Case (SB1->B1_PESO <= 0) .AND. SB1->B1_TIPO = 'PA' // N„o libera pedido com produto sem PESO - MCVN 29/05/2009
					cMsgAux := "Produto "+SB1->B1_COD+" sem PESO."+Chr(13)+"Fale com o pessoal de compras para que o pedido seja liberado!"+Chr(13)+Chr(13)+"Obrigado."
				Case SB1->B1_CUSDIP == 0 // N„o permite faturamento sem preÁo de custo   -  MCVN - 26/08/09
					cMsgAux := "Produto "+SB1->B1_COD+" sem custo."+Chr(13)+"Fale com o pessoal de compras para que o pedido seja liberado!"+Chr(13)+Chr(13)+"Obrigado.
				Case Empty(Alltrim(SB1->B1_DREVFIS))// N„o permite faturamento sem preÁo de custo   -  MCVN - 26/08/09
					cMsgAux := "Produto "+SB1->B1_COD+" bloqueado, falta avaliaÁ„o fiscal."+Chr(13)+"Fale com o pessoal do Departamento respons·vel para que o pedido seja liberado!"+Chr(13)+Chr(13)+"Obrigado."
				Case Empty(Alltrim(SB1->B1_TS))		// N„o permite faturamento sem TES de Saida  -  D'Leme - 10/10/2011
					cMsgAux := "Produto "+SB1->B1_COD+" sem TES padr„o de SaÌda."+Chr(13)+"Fale com o pessoal de compras para que o pedido seja liberado!"+Chr(13)+Chr(13)+"Obrigado."
				Case LEFT(SB1->B1_DESC,1) == "Z"
					cMsgAux := "Produto "+SB1->B1_COD+" iniciado com Z n„o pode ser faturado."+Chr(13)+"Fale com o pessoal de compras para que o pedido seja liberado!"+Chr(13)+Chr(13)+"Obrigado."
			EndCase
			
			If !Empty(cMsgAux)
				MsgBox(cMsgAux)
				If MsgYesNo("DELETAR a linha do produto "+AllTrim(SB1->B1_COD)+"?","AtenÁ„o!")
					aCols[nI,Len(aHeader)+1] := .T. // RBorges 22/10/14 - Deleta a linha e permiti continuar a alteraÁ„o.
				Else
					_lRetorno  := .F.
				EndIf
			EndIf
		EndIf
	EndIf
Next nI

RestArea(_areaSB1)
RestArea(_areaSZ3)
RestArea(_xAlias)

Return(_lRetorno)
/*                                                          JBS, 18 Jan 2006
*---------------------------------------------------------------------------

ApÛs o usuario ter informado o destino da entrega da mercadoria
poder·, ele, solicitar o calculo do frete.

Esta funÁ„o ir· calcular o frete, de acordo com os dados do cliente,
para todas as transportadoras que atendam a regi„o de destino.
TambÈm disponibilizar· todos os calculos em um browse, onde o usuario
ir· assinalar a melhor opÁ„o acordada entre ele e o cliente.

*---------------------------------------------------------------------------*/
User Function ClcLimite(cFuncao,_nVlrTotal,_nPesoBr,_cNomeRot)
*---------------------------------------------------------------------------*
Local cFilSZ3:=xFilial('SZ3')
Local nFreteNota:=0
Local nAdValor:=0
Local nSuframa:=0
Local nAdcFluv:=0
Local nGris:=0
Local nPedagio:=0
Local nFrete:=0
Local nExcedente:=0
Local nFreteTransp:=0
Local nValorFrete:=0
Local nICM:=0
Local nTaxaExc:=0
Local nDCE:=0    // MCVN - 01/10/2009
Local nTAS:=0    // MCVN - 01/10/2009
Local nTRF:=0    // MCVN - 01/10/2009
Local nTaxaAdm:=0// MCVN - 01/10/2009
Local nTRT:=0    // MCVN - 29/09/2010
Local _nTRT:=0
Local nEmex := 0
Local nPesoBruto:=_nPesoBr
Local cLocArq
Local cEstado
Local cMunicipio
Local cQuery:=""
Local aFrete:={}
Local oDlg
Local oInc
Local oCif
Local nOpcao:=0
Local lRetorno:=.T.
Local lMarcados:=.F.
Local cPesoBruto:= ''
Local cUF :=If(!Empty(SA1->A1_ESTE),SA1->A1_ESTE,SA1->A1_EST)
Local cMun:=If(!Empty(SA1->A1_MUNE),SA1->A1_MUNE,SA1->A1_MUN)
Local cCidPolo
Local cCodTransp
Local cTrpUsaCep
Local cCepCli
Local lTela		:= .F.
Local nZ3_VAEMO :=0
Local nZ3_VALOR :=0
Local cEstFr 	:= ""  //Giovani Zago 20/10/2011
Local cMunFr 	:= ""  //Giovani Zago 20/10/2011
Local cSQL 		:= ""   
Local _cAliasAux:= ""
Local cCodCli	:= ""
Local lCodCliAT	:= .F.
Local lCodCepTRT:= .F. 
Local cLojCli	:= ""
Local cPedido 	:= ""
Local cTipInter := ""
Local nVlrMinTDE:= 0
Local nVlrMaxTDE:= 0
Local nVlrPecTDE:= 0

dbSelectArea("SZ3")

If cFuncao=="NF" .Or. cFuncao=="CONSULTA"
	If "DIPM019" $ FUNNAME() .or. "DIPM028" $ FUNNAME()  // Se a rotina for chamada pelo processamento EDI (DIPM019) - MCVN 23/10/2009
		cCodTransp:= SF2->F2_TRANSP
	Else
		cCodTransp:= SC5->C5_TRANSP
	Endif
	
	cEstado   := Substr(SC5->C5_DESTFRE,1,02)
	cMunicipio:= Substr(SC5->C5_DESTFRE,4,20)
	cCepCli   := SC5->C5_CEPE
	SA1->(dbSetOrder(1))
	SA1->(dbSeek(xfilial("SA1")+SC5->C5_CLIENTE+SC5->C5_LOJACLI))
	cUF :=If(!Empty(SC5->C5_ESTE),SC5->C5_ESTE,(If(!Empty(SA1->A1_ESTE),SA1->A1_ESTE,SA1->A1_EST)))
	cMun:=If(!Empty(SC5->C5_MUNE),SC5->C5_MUNE,(If(!Empty(SA1->A1_MUNE),SA1->A1_MUNE,SA1->A1_MUN)))
	cEstFr := ALLTRIM(cUF) //Giovani Zago 20/10/2011
	cMunFr := ALLTRIM(cMun) //Giovani Zago 20/10/2011
	cCodCli:= SC5->C5_CLIENTE
	cPedido := SC5->C5_NUM	            
	cLojCli := SC5->C5_LOJACLI
Else
	
	cCodTransp:= If(cFuncao=="TMK", M->UA_TRANSP,M->C5_TRANSP)
	cEstado   := If(cFuncao=="TMK", Substr(M->UA_DESTFRE,1,02), Substr(M->C5_DESTFRE,1,02))
	cMunicipio:= If(cFuncao=="TMK", Substr(M->UA_DESTFRE,4,20), Substr(M->C5_DESTFRE,4,20))
	cCepCli   := If(cFuncao=="TMK", Alltrim(M->UA_CEPE), Alltrim(M->C5_CEPE))
	If cFuncao <> "TMK" //Giovani Zago 20/10/2011
		SA1->(dbSetOrder(1)) //Giovani Zago 20/10/2011
		SA1->(dbSeek(xfilial("SA1")+ M->C5_CLIENTE+M->C5_LOJACLI)) //Giovani Zago 20/10/2011
		cEstFr :=ALLTRIM(If(!Empty(M->C5_ESTE),M->C5_ESTE,(If(!Empty(SA1->A1_ESTE),SA1->A1_ESTE,SA1->A1_EST)))) //Giovani Zago 20/10/2011
		cMunFr :=ALLTRIM(If(!Empty(M->C5_MUNE),M->C5_MUNE,(If(!Empty(SA1->A1_MUNE),SA1->A1_MUNE,SA1->A1_MUN)))) //Giovani Zago 20/10/2011
		cCodCli:= M->C5_CLIENTE
		cLojCli:= M->C5_LOJACLI
	EndIf //Giovani Zago 20/10/2011
	cPedido := M->C5_NUM	
EndIf




If !Mta410Transp(cCodTransp,_nPesoBr)
	Return(.f.)
ElseIf _nPesoBr = 0
	Return(.t.)
EndIf

//--------------------------------------------
// Se o arq temp j· existe o bt foi acionado
// mais de uma vez, ent„o sai da rotina.
//--------------------------------------------
If  Type("l410Auto") <> "U" .and. l410Auto
	_lRetorno := .t.
	Return(_lRetorno)
EndIf

If Select("WORK_FRT") > 0 // JBS 31/01/2006, 10:30
	If ( Type("l410Auto") == "U" .OR. !l410Auto )
		MsgInfo('O Calculo do Frete j· est· em execuÁ„o!'+chr(13)+chr(10)+;
		'Por favor aguarde o termino da execuÁ„o!','AtenÁ„o')
	EndIf
	return(.t.)
EndIf
Private lInverte:=.F.
Private cMarca:=GetMark()
Private aHeader:={}
Private aCampos
Private lInc
Private lCif
Private aViagem := {} //MCVN - 02/12/09

//--------------------------------------------
// Campos que serao mostrados na dialog
// para o usuario
//--------------------------------------------
Private aCposSF := {}
AADD(ACPOSSF,{"Z3_TRANSP"  ,,AVSX3("Z3_TRANSP",5)})
AADD(ACPOSSF,{"A4_NOME"    ,,AVSX3("A4_NOME",5)})
AADD(ACPOSSF,{"Z3_VALFRET" ,,'Valor do Frete'})
AADD(ACPOSSF,{"Z3_EST"     ,,'UF'})
AADD(ACPOSSF,{"Z3_CAP_MUN" ,,'Municipio'})
AADD(ACPOSSF,{"Z3_PESOLIM" ,,'Limite'})
AADD(ACPOSSF,{"ZV_VIAGEM"  ,,'Viagem'})
//--------------------------------------------
// Campos de Controle da MsSelect
//--------------------------------------------
lInverte := .F.
cMarca   := GetMark()
//--------------------------------------------
// Campos de Controle gerados e_criatrab
//--------------------------------------------
aHeader:={}
aCampos:={}
cFileWork:=E_CriaTrab(,{;
{"Z3_TRANSP", "C" ,avsx3("Z3_TRANSP",3),0},;
{"A4_NOME"  , "C" ,avsx3("A4_NOME"  ,3),0},;
{"Z3_VALOR" , "N" ,avsx3("Z3_VALOR" ,3),avsx3("Z3_VALOR" ,4)},;
{"Z3_VALFRET","C" ,15,0},;
{"Z3_EST"    ,"C" ,avsx3("Z3_EST",3),0},;
{"Z3_CAP_MUN","C" ,avsx3("Z3_CAP_MUN",3),0},;
{"Z3_PESOLIM","N" ,avsx3("Z3_PESOLIM",3),0},;
{"PRIORIDADE","C" ,1,0},;
{"ZV_VIAGEM", "C" ,avsx3("ZV_VIAGEM",3),0}},"WORK_FRT",)

IndRegua("WORK_FRT",cFileWork,"Z3_VALOR")

If cFuncao=="NF" .Or. cFuncao=="CONSULTA"
	If "DIPM019" $ FUNNAME()  .or. "DIPM028" $ FUNNAME()// Se a rotina for chamada pelo processamento EDI (DIPM019) - MCVN 23/10/2009
		lInc := SF2->F2_TPFRETE == "I"
		lCif := SF2->F2_TPFRETE == "C"
	Else
		lInc := SC5->C5_TPFRETE == "I"
		lCif := SC5->C5_TPFRETE == "C"
	Endif
Else
	lInc := If(cFuncao=="TMK",M->UA_TPFRETE == "I",M->C5_TPFRETE == "I")
	lCif := If(cFuncao=="TMK",M->UA_TPFRETE == "C",M->C5_TPFRETE == "C")
EndIF

//---------------------------------------------
// Determino o peso limite do pedido de acordo
// Com tab de cada transp
//---------------------------------------------
cPesoBruto:=Str(_nPesoBr)
//-----------------------------------------------------
// Seleciona todas as transportadoras que atendam aos
// parametros do cliente...
//-----------------------------------------------------
/*
SELECT Z3_TRANSP,A4_NOME,Z3_EST,Z3_SIGLA,Z3_CAP_MUN,Z3_PESOLIM,Z3_VALOR,Z3_EXCEDEN,Z3_FRETE,Z3_GRIS,Z3_PEDAGIO
FROM SZ3010 Z3, SA4010 A4
WHERE Z3.D_E_L_E_T_ <> '*'
AND Z3_FILIAL= '  '
AND Z3_CAP_MUN NOT IN ('SAO PAULO')
AND Z3_EST = 'SP'
AND Z3_TRANSP = A4_COD
AND (Z3_TRANSP+STR(Z3_PESOLIM) IN (
SELECT DISTINCT Z3_TRANSP + (
SELECT TOP 1 STR(Z3_PESOLIM)
FROM SZ3010 ZZZ3
WHERE ZZZ3.D_E_L_E_T_ <> '*'
AND Z3_EST = 'SP'
AND Z3_PESOLIM >= '180'
AND ZZ3.Z3_TRANSP = ZZZ3.Z3_TRANSP
ORDER BY Z3_TRANSP, Z3_PESOLIM)
FROM SZ3010 ZZ3
WHERE ZZ3.D_E_L_E_T_ <> '*'
AND Z3_FILIAL = '  '
AND Z3_CAP_MUN NOT IN ('SAO PAULO')
AND Z3_EST = 'SP'
) or
(Z3_TRANSP+STR(Z3_PESOLIM) IN (
SELECT DISTINCT Z3_TRANSP + (
SELECT TOP 1 STR(Z3_PESOLIM)
FROM SZ3010 ZZZZ3
WHERE ZZZZ3.D_E_L_E_T_ <> '*'
AND Z3_EST = 'SP'
AND Z3_PESOLIM <= '180'
AND ZZZZZ3.Z3_TRANSP = ZZZZ3.Z3_TRANSP
ORDER BY Z3_TRANSP, Z3_PESOLIM DESC)
FROM SZ3010 ZZZZZ3
WHERE ZZZZZ3.D_E_L_E_T_ <> '*'
AND Z3_FILIAL = '  '
AND Z3_CAP_MUN NOT IN ('SAO PAULO')
AND Z3_EST = 'SP'

AND Z3_TRANSP NOT IN (SELECT DISTINCT Z3_TRANSP
FROM SZ3010 ZZ3
WHERE ZZ3.D_E_L_E_T_ <> '*'
AND Z3_FILIAL = '  '
AND Z3_CAP_MUN NOT IN ('SAO PAULO')
AND Z3_EST = 'SP'
AND Z3_PESOLIM >= '180')

)))
ORDER BY Z3_VALOR*/

If GetMV("ES_MTBLOQ", ,"1") $ "1" //chave caso ocorra alguma divergencia nao necessita parar o sistema apenas mudar o parametro - Giovani Zago 20/10/2011
	
	cCidPolo   := "('"+AllTrim(StrTran(Tabela("Z3",cEstado,.f.),"/","','"))+"') "
	
	cQuery := " SELECT Z3_TRANSP,A4_NOME,Z3_EST,Z3_SIGLA,Z3_CAP_MUN,Z3_PESOLIM,Z3_VALOR, Z3_XVLINT2, Z3_XVLINT3, Z3_VALMIN,Z3_EXCEDEN, Z3_XEXCED2, Z3_XEXCED3, Z3_FRETE,Z3_ADVALOR,Z3_XADVAL2,Z3_XADVAL3,Z3_GRIS,Z3_PEDAGIO,Z3_ICM,Z3_TAXAEXC,Z3_GRISMIN, "+CEND
	cQuery += " Z3_ADVAMIN, Z3_SUFRAMA, Z3_ADCFLUV, Z3_ADCFLU2, Z3_FLUVMIN, Z3_LIMGRIS, Z3_GRIS2, Z3_ACREHQ, Z3_ACREDIP, Z3_TXADMIN, Z3_DCE, Z3_TAS, Z3_TRF, Z3_TRF_MIN, Z3_TRT, Z3_TRTMIN, Z3_VMINTDE, Z3_VMAXTDE, Z3_PVLRTDE, Z3_XVLEMEX, Z3_XPCEMEX, Z3_XADVALF, Z3_XVLINTF, Z3_XEXCEDF "+CEND
	cQuery += " FROM "+RetSqlName('SZ3')+" Z3, "+RetSqlName('SA4')+" A4"+CEND
	cQuery += " WHERE Z3.D_E_L_E_T_ = ' '"+CEND
	cQuery += " AND   A4.D_E_L_E_T_ = ' '"+CEND
	cQuery += " AND   Z3_FILIAL= '"+xFilial('SZ3')+"'"+CEND
	If !(cFuncao=="NF") // MCVN - 01/06/2009
		cQuery += " AND Z3_DATAFIN = ''"+CEND
	Endif
	// Possibilita alteraÁ„o do Municipio e solicita uma senha para validar MCVN - 02/08/2007
	If !Empty(cMunicipio).and. Left(cMun,17) <> Left(cMunicipio,17)
		cQuery += " AND Z3_CAP_MUN = '"+cMunicipio+"'"+CEND
	ElseIf !Empty(cMunicipio).and. Left(cMun,17) == Left(cMunicipio,17)
		cQuery += " AND Z3_CAP_MUN = '"+cMunicipio+"'"+CEND
	ElseIf !Empty(cMunicipio)
		cQuery += " AND Z3_CAP_MUN NOT IN "+cCidPolo+CEND
	EndIf
	cQuery += " AND Z3_EST = '"+cEstado+"'"+CEND
	cQuery += " AND Z3_TRANSP = A4_COD"+CEND
	
	// Verifica se existe Emovere para regi„o e se controle CEP - MCVN - 02/12/09
	If !(cFuncao=="NF")  .And. !("DIPM019" $ FUNNAME())  .And. !("DIPM028" $ FUNNAME()) // MCVN - 03/12/2009
		//If M->C5_TPFRETE == 'I' // MCVN - 20/12/2009
		// Verifica se existe Emovere para regi„o e se controle CEP - MCVN - 02/12/09
		cTrpUsaCep := FindCepSzv(cCepCli)// FunÁ„o que verifica CEP no SZV
		cQuery += " AND (A4_USARCEP <> '2' OR (A4_USARCEP = '2' AND A4_COD IN ("+cTrpUsaCep+")))"+CEND
		If '100000' $ cTrpUsaCep  //Se a Emovere entregar no local e data prevista n„o mostra a Braspress
			cQuery += " AND Z3_TRANSP <> '000150' "+CEND
		Endif
		//Endif
	Endif
	
	If cFuncao=="NF" .Or. cFuncao=="CONSULTA"
		//-------------------------------------
		// Foi chamada da da GeraÁ„o da NF
		//-------------------------------------
		If "DIPM019" $ FUNNAME()  .or. "DIPM028" $ FUNNAME()// Se a rotina for chamada pelo processamento EDI (DIPM019) - MCVN 23/10/2009
			cQuery += " AND Z3_TRANSP = '"+SF2->F2_TRANSP+"'"+CEND
		Else
			cQuery += " AND Z3_TRANSP = '"+SC5->C5_TRANSP+"'"+CEND
		Endif
	ElseIf (_cNomeRot $ "TMKVLDE4" .and. !empty(M->UA_TRANSP)).or.;
		(_cNomeRot $ "TMKCBPRO" .and. !empty(M->UA_TRANSP).and.!lCif) // Chamado do Bot„o do Call Center
		//----------------------------------
		// A transportadora foi informada
		//----------------------------------
		cQuery += " AND Z3_TRANSP = '"+M->UA_TRANSP+"'"
	ElseIf (_cNomeRot $ "MTA410" .and. !empty(M->C5_TRANSP)) .or.;
		(_cNomeRot $ "A410CONS" .and. !empty(M->C5_TRANSP).and.!lCif) // Chamado do Bot„o do Faturamento
		//-------------------------------------
		// Foi pressionado o bot„o do frete
		// Para recalcular o frete para a
		// Transportadora informada.
		//-------------------------------------
		cQuery += " AND Z3_TRANSP = '"+M->C5_TRANSP+"'"+CEND
	ElseIf Type("l410Auto") == "L".and. l410Auto
		//-------------------------------------
		// Chamado atraves da geraÁ„o automati-
		// ca do pedido no SC5 e SC6
		//-------------------------------------
		If cFuncao=='TMK' // Call Center
			cQuery += " AND Z3_TRANSP = '"+M->UA_TRANSP+"'"+CEND
		Else // Faturamento
			cQuery += " AND Z3_TRANSP = '"+M->C5_TRANSP+"'"+CEND
		EndIf
	EndIf
	cQuery += " AND (Z3_TRANSP+STR(Z3_PESOLIM) IN ("+CEND
	cQuery += "         SELECT DISTINCT Z3_TRANSP + ("+CEND
	cQuery += "                SELECT TOP 1 STR(Z3_PESOLIM)"+CEND
	cQuery += "                FROM "+RetSqlName('SZ3')+" ZZZ3"+CEND
	cQuery += "                WHERE ZZZ3.D_E_L_E_T_ = ' '"+CEND
	cQuery += "                  AND Z3_FILIAL       = '" + xFilial("SZ3")+"'"+CEND
	cQuery += "                  AND Z3_EST          = '" + cEstado + "'"+CEND
	cQuery += "                  AND Z3_PESOLIM     >= '" + cPesoBruto + "'"+CEND
	cQuery += "                  AND ZZ3.Z3_TRANSP  = ZZZ3.Z3_TRANSP"+CEND
	cQuery += "                ORDER BY Z3_TRANSP, Z3_PESOLIM)"+CEND
	cQuery += "         FROM "+RetSqlName('SZ3')+" ZZ3"+CEND
	cQuery += "         WHERE ZZ3.D_E_L_E_T_ = ' '"+CEND
	cQuery += "         AND Z3_FILIAL = '"+xFilial('SZ3')+"'"+CEND
	
	// Possibilita alteraÁ„o do Municipio e solicita uma senha para validar MCVN - 02/08/2007
	If !Empty(cMunicipio).and. Left(cMun,17) <> Left(cMunicipio,17) // MCVN - 02/08/2007
		cQuery += "         AND Z3_CAP_MUN = '"+cMunicipio+"'"+CEND      // MCVN - 02/08/2007
	ElseIf !Empty(cMunicipio).and. Left(cMun,17) == Left(cMunicipio,17)
		cQuery += "         AND Z3_CAP_MUN = '"+cMunicipio+"'"+CEND
	ElseIf !Empty(cMunicipio)
		cQuery += "         AND Z3_CAP_MUN NOT IN "+cCidPolo+CEND
		
	EndIf
	cQuery += "         AND Z3_EST = '"+cEstado+"'"+CEND
	cQuery += " ) or (Z3_TRANSP+STR(Z3_PESOLIM) IN ("+CEND
	cQuery += "         SELECT DISTINCT Z3_TRANSP + ("+CEND
	cQuery += "                SELECT TOP 1 STR(Z3_PESOLIM)"+CEND
	cQuery += "                FROM "+RetSqlName('SZ3')+" ZZZZ3"+CEND
	cQuery += "                WHERE ZZZZ3.D_E_L_E_T_ = ' '"+CEND
	cQuery += "                  AND Z3_FILIAL        = '" + xFilial("SZ3")+"'"+CEND
	cQuery += "                  AND Z3_EST           = '"+cEstado+"'"+CEND
	cQuery += "                  AND Z3_PESOLIM      <= '"+cPesoBruto+"'"+CEND
	cQuery += "                  AND ZZZZZ3.Z3_TRANSP = ZZZZ3.Z3_TRANSP"+CEND
	cQuery += "                ORDER BY Z3_TRANSP, Z3_PESOLIM DESC)"+CEND
	cQuery += "         FROM "+RetSqlName('SZ3')+" ZZZZZ3"+CEND
	cQuery += "         WHERE ZZZZZ3.D_E_L_E_T_ = ' '"+CEND
	cQuery += "         AND Z3_FILIAL = '"+xFilial('SZ3')+"'"+CEND
	
	// Possibilita alteraÁ„o do Municipio e solicita uma senha para validar MCVN - 02/08/2007
	If !Empty(cMunicipio).and. Left(cMun,17) <> Left(cMunicipio,17) // MCVN - 02/08/2007
		cQuery += "         AND Z3_CAP_MUN = '"+cMunicipio+"'"+CEND      // MCVN - 02/08/2007
	ElseIf !Empty(cMunicipio).and. Left(cMun,17) == Left(cMunicipio,17)
		cQuery += "         AND Z3_CAP_MUN = '"+cMunicipio+"'"+CEND
	ElseIf !Empty(cMunicipio)
		cQuery += "         AND Z3_CAP_MUN NOT IN "+cCidPolo+CEND
	EndIf
	cQuery += "         AND Z3_EST = '"+cEstado+"'"+CEND
	cQuery += " 	    AND Z3_TRANSP NOT IN (SELECT DISTINCT Z3_TRANSP"+CEND
	cQuery += "                               FROM "+RetSqlName('SZ3')+" ZZ3"+CEND
	cQuery += "                               WHERE ZZ3.D_E_L_E_T_ = ' '"+CEND
	cQuery += "                                 AND Z3_FILIAL = '"+xFilial('SZ3')+"'"+CEND
	
	// Possibilita alteraÁ„o do Municipio e solicita uma senha para validar MCVN - 02/08/2007
	If !Empty(cMunicipio).and. Left(cMun,17) <> Left(cMunicipio,17)                      // MCVN - 02/08/2007
		cQuery += "                                 AND Z3_CAP_MUN = '"+cMunicipio+"'"+CEND   // MCVN - 02/08/2007
	ElseIf !Empty(cMunicipio).and. Left(cMun,17) == Left(cMunicipio,17)
		cQuery += "                                 AND Z3_CAP_MUN = '"+cMunicipio+"'"+CEND
	ElseIf !Empty(cMunicipio)
		cQuery += "                                 AND Z3_CAP_MUN NOT IN "+cCidPolo+CEND
	EndIf
	cQuery += "                                 AND Z3_EST = '"+cEstado+"'"+CEND
	cQuery += "                                 AND Z3_PESOLIM >= '"+cPesoBruto+"') "+CEND
	cQuery += " )))"+CEND
	cQuery += " ORDER BY Z3_VALOR "+CEND
	
	
Else//**********************************************************************************************************
	//Giovani Zago 20/10/2011 adequaÁ„o de query para calcular cidades que faze parte da metropole, ex.: guarulho = grande sao paulo, de transportadora cadastradas no sx5 "2Z"
	
	cCidPolo   := "('"+AllTrim(StrTran(Tabela("Z3",cEstado,.f.),"/","','"))+"') "+CEND
	
	cQuery := " SELECT Z3_FRETMIN, Z3_TRANSP,A4_NOME,Z3_EST,Z3_SIGLA,Z3_CAP_MUN,Z3_PESOLIM,Z3_VALOR, Z3_XVLINT2, Z3_XVLINT3, Z3_VALMIN,Z3_EXCEDEN, Z3_XEXCED2,Z3_XEXCED3,Z3_FRETE,Z3_ADVALOR,Z3_XADVAL2,Z3_XADVAL3,Z3_GRIS,Z3_PEDAGIO,Z3_ICM,Z3_TAXAEXC,Z3_GRISMIN, "+CEND
	cQuery += " Z3_ADVAMIN, Z3_SUFRAMA, Z3_ADCFLUV, Z3_ADCFLU2, Z3_FLUVMIN, Z3_LIMGRIS, Z3_GRIS2, Z3_ACREHQ, Z3_ACREDIP, Z3_TXADMIN, Z3_DCE, Z3_TAS, Z3_TRF, Z3_TRF_MIN, Z3_TRT, Z3_TRTMIN, Z3_VMINTDE, Z3_VMAXTDE, Z3_PVLRTDE, Z3_XVLEMEX, Z3_XPCEMEX, Z3_XADVALF, Z3_XVLINTF, Z3_XEXCEDF "+CEND
	cQuery += " FROM "+RetSqlName('SZ3')+" Z3, "+RetSqlName('SA4')+" A4"+CEND
	cQuery += " WHERE Z3.D_E_L_E_T_ = ' '"+CEND
	cQuery += " AND   A4.D_E_L_E_T_ = ' '"+CEND
	cQuery += " AND   Z3_FILIAL= '"+xFilial('SZ3')+"'"+CEND
	If !(cFuncao=="NF") // MCVN - 01/06/2009
		cQuery += " AND Z3_DATAFIN = ''"+CEND
	Endif
	
	// Possibilita alteraÁ„o do Municipio e solicita uma senha para validar MCVN - 02/08/2007
	If !Empty(cMunicipio).and. Left(cMun,17) <> Left(cMunicipio,17)// MCVN - 02/08/2007
		
		
		cQuery += " AND Z3_CAP_MUN =  ISNULL((SELECT X5_DESCENG   "+CEND
		cQuery += " FROM "+RetSqlName('SX5')+" SX5"+CEND
		cQuery += " WHERE X5_FILIAL = '"+xFilial('SX5')+"'"+CEND
		cQuery += " AND X5_TABELA = '2Z'   "+CEND
		cQuery += " AND X5_CHAVE = A4_COD   "+CEND
		cQuery += " AND X5_DESCRI =  '"+cEstFr+"'"+CEND
		cQuery += " AND X5_DESCSPA = '"+cMunFr+"'"+CEND
		cQuery += " AND SX5.D_E_L_E_T_ = ' '),'"+cMunicipio+"') "+CEND
		
	ElseIf !Empty(cMunicipio).and. Left(cMun,17) == Left(cMunicipio,17)
		
		
		
		cQuery += " AND Z3_CAP_MUN =  ISNULL((SELECT X5_DESCENG   "+CEND
		cQuery += " FROM "+RetSqlName('SX5')+" SX5"+CEND
		cQuery += " WHERE X5_FILIAL = '"+xFilial('SX5')+"'"+CEND
		cQuery += " AND X5_TABELA = '2Z'   "+CEND
		cQuery += " AND X5_CHAVE = A4_COD   "+CEND
		cQuery += " AND X5_DESCRI =  '"+cEstFr+"'"+CEND
		cQuery += " AND X5_DESCSPA = '"+cMunFr+"'"+CEND
		cQuery += " AND SX5.D_E_L_E_T_ = ' '),'"+cMunicipio+"') "+CEND
		
	ElseIf !Empty(cMunicipio)
		cQuery += " AND Z3_CAP_MUN NOT IN "+cCidPolo+CEND
	EndIf
	cQuery += " AND Z3_EST = '"+cEstado+"'"+CEND
	cQuery += " AND Z3_TRANSP = A4_COD"+CEND
	
	// Verifica se existe Emovere para regi„o e se controle CEP - MCVN - 02/12/09
	If !(cFuncao=="NF")  .And. !("DIPM019" $ FUNNAME())  .And. !("DIPM028" $ FUNNAME()) // MCVN - 03/12/2009
		//If M->C5_TPFRETE == 'I' // MCVN - 20/12/2009
		// Verifica se existe Emovere para regi„o e se controle CEP - MCVN - 02/12/09
		cTrpUsaCep := FindCepSzv(cCepCli)// FunÁ„o que verifica CEP no SZV
		cQuery += " AND (A4_USARCEP <> '2' OR (A4_USARCEP = '2' AND A4_COD IN ("+cTrpUsaCep+")))"+CEND
		If '100000' $ cTrpUsaCep  //Se a Emovere entregar no local e data prevista n„o mostra a Braspress
			cQuery += " AND Z3_TRANSP <> '000150' "+CEND
		Endif
		//Endif
	Endif
	
	If cFuncao=="NF" .Or. cFuncao=="CONSULTA"
		//-------------------------------------
		// Foi chamada da da GeraÁ„o da NF
		//-------------------------------------
		If "DIPM019" $ FUNNAME()  .or. "DIPM028" $ FUNNAME()// Se a rotina for chamada pelo processamento EDI (DIPM019) - MCVN 23/10/2009
			cQuery += " AND Z3_TRANSP = '"+SF2->F2_TRANSP+"'"+CEND
		Else
			cQuery += " AND Z3_TRANSP = '"+SC5->C5_TRANSP+"'"+CEND
		Endif
	ElseIf (_cNomeRot $ "TMKVLDE4" .and. !empty(M->UA_TRANSP)).or.;
		(_cNomeRot $ "TMKCBPRO" .and. !empty(M->UA_TRANSP).and.!lCif) // Chamado do Bot„o do Call Center
		//----------------------------------
		// A transportadora foi informada
		//----------------------------------
		cQuery += " AND Z3_TRANSP = '"+M->UA_TRANSP+"'"+CEND
	ElseIf (_cNomeRot $ "MTA410" .and. !empty(M->C5_TRANSP)) .or.;
		(_cNomeRot $ "A410CONS" .and. !empty(M->C5_TRANSP).and.!lCif) // Chamado do Bot„o do Faturamento
		//-------------------------------------
		// Foi pressionado o bot„o do frete
		// Para recalcular o frete para a
		// Transportadora informada.
		//-------------------------------------
		cQuery += " AND Z3_TRANSP = '"+M->C5_TRANSP+"'"+CEND
	ElseIf Type("l410Auto") == "L".and. l410Auto
		//-------------------------------------
		// Chamado atraves da geraÁ„o automati-
		// ca do pedido no SC5 e SC6
		//-------------------------------------
		If cFuncao=='TMK' // Call Center
			cQuery += " AND Z3_TRANSP = '"+M->UA_TRANSP+"'"+CEND
		Else // Faturamento
			cQuery += " AND Z3_TRANSP = '"+M->C5_TRANSP+"'"+CEND
		EndIf
	EndIf
	cQuery += " AND (Z3_TRANSP+STR(Z3_PESOLIM) IN ("+CEND
	cQuery += "         SELECT DISTINCT Z3_TRANSP + ("+CEND
	cQuery += "                SELECT TOP 1 STR(Z3_PESOLIM)"+CEND
	cQuery += "                FROM "+RetSqlName('SZ3')+" ZZZ3"+CEND
	cQuery += "                WHERE ZZZ3.D_E_L_E_T_ = ' '"+CEND
	cQuery += "                  AND Z3_FILIAL       = '" + xFilial("SZ3")+"'"+CEND
	cQuery += "                  AND Z3_EST          = '" + cEstado + "'"+CEND
	cQuery += "                  AND Z3_PESOLIM     >= '" + cPesoBruto + "'"+CEND
	cQuery += "                  AND ZZ3.Z3_TRANSP  = ZZZ3.Z3_TRANSP"+CEND

	cQuery += " 				AND Z3_CAP_MUN =  ISNULL((	SELECT X5_DESCENG   "+CEND
	cQuery += " 											FROM "+RetSqlName('SX5')+" SX5"+CEND
	cQuery += " 											WHERE X5_FILIAL = '"+xFilial('SX5')+"'"+CEND
	cQuery += " 											AND X5_TABELA = '2Z'   "+CEND
	cQuery += " 											AND X5_CHAVE = A4_COD   "+CEND
	cQuery += " 											AND X5_DESCRI =  '"+cEstFr+"'"+CEND
	cQuery += " 											AND X5_DESCSPA = '"+cMunFr+"'"+CEND
	cQuery += " 											AND SX5.D_E_L_E_T_ = ' '),'"+cMunicipio+"') " +CEND

	cQuery += "                ORDER BY Z3_TRANSP, Z3_PESOLIM)"+CEND
	cQuery += "         FROM "+RetSqlName('SZ3')+" ZZ3"+CEND
	cQuery += "         WHERE ZZ3.D_E_L_E_T_ = ' '"+CEND
	cQuery += "         AND Z3_FILIAL = '"+xFilial('SZ3')+"'"+CEND
	
	// Possibilita alteraÁ„o do Municipio e solicita uma senha para validar MCVN - 02/08/2007
	If !Empty(cMunicipio).and. Left(cMun,17) <> Left(cMunicipio,17) // MCVN - 02/08/2007
		
		
		cQuery += " AND Z3_CAP_MUN =  ISNULL((SELECT X5_DESCENG   "+CEND
		cQuery += " FROM "+RetSqlName('SX5')+" SX5"+CEND
		cQuery += " WHERE X5_FILIAL = '"+xFilial('SX5')+"'"+CEND
		cQuery += " AND X5_TABELA = '2Z'   "+CEND
		cQuery += " AND X5_CHAVE = A4_COD   "+CEND
		cQuery += " AND X5_DESCRI =  '"+cEstFr+"'"+CEND
		cQuery += " AND X5_DESCSPA = '"+cMunFr+"'"+CEND
		cQuery += " AND SX5.D_E_L_E_T_ = ' '),'"+cMunicipio+"') "+CEND
		
	ElseIf !Empty(cMunicipio).and. Left(cMun,17) == Left(cMunicipio,17)
		
		cQuery += " AND Z3_CAP_MUN =  ISNULL((SELECT X5_DESCENG   "+CEND
		cQuery += " FROM "+RetSqlName('SX5')+" SX5"+CEND
		cQuery += " WHERE X5_FILIAL = '"+xFilial('SX5')+"'"+CEND
		cQuery += " AND X5_TABELA = '2Z'   "+CEND
		cQuery += " AND X5_CHAVE = A4_COD   "+CEND
		cQuery += " AND X5_DESCRI =  '"+cEstFr+"'"+CEND
		cQuery += " AND X5_DESCSPA = '"+cMunFr+"'"+CEND
		cQuery += " AND SX5.D_E_L_E_T_ = ' '),'"+cMunicipio+"') "+CEND
		
	ElseIf !Empty(cMunicipio)
		cQuery += "         AND Z3_CAP_MUN NOT IN "+cCidPolo+CEND
		
	EndIf
	cQuery += "         AND Z3_EST = '"+cEstado+"'"+CEND
	cQuery += " ) or (Z3_TRANSP+STR(Z3_PESOLIM) IN ("+CEND
	cQuery += "         SELECT DISTINCT Z3_TRANSP + ("+CEND
	cQuery += "                SELECT TOP 1 STR(Z3_PESOLIM)"+CEND
	cQuery += "                FROM "+RetSqlName('SZ3')+" ZZZZ3"+CEND
	cQuery += "                WHERE ZZZZ3.D_E_L_E_T_ = ' '"+CEND
	cQuery += "                  AND Z3_FILIAL        = '" + xFilial("SZ3")+"'"+CEND
	cQuery += "                  AND Z3_EST           = '"+cEstado+"'"+CEND
	cQuery += "                  AND Z3_PESOLIM      <= '"+cPesoBruto+"'"+CEND
	cQuery += "                  AND ZZZZZ3.Z3_TRANSP = ZZZZ3.Z3_TRANSP"+CEND
//-----------------
	cQuery += " 				AND Z3_CAP_MUN =  ISNULL((	SELECT X5_DESCENG   "+CEND
	cQuery += " 											FROM "+RetSqlName('SX5')+" SX5"+CEND
	cQuery += " 											WHERE X5_FILIAL = '"+xFilial('SX5')+"'"+CEND
	cQuery += " 											AND X5_TABELA = '2Z'   "+CEND
	cQuery += " 											AND X5_CHAVE = A4_COD   "+CEND
	cQuery += " 											AND X5_DESCRI =  '"+cEstFr+"'"+CEND
	cQuery += " 											AND X5_DESCSPA = '"+cMunFr+"'"+CEND
	cQuery += " 											AND SX5.D_E_L_E_T_ = ' '),'"+cMunicipio+"') "+CEND
	
	cQuery += "                ORDER BY Z3_TRANSP, Z3_PESOLIM DESC)"+CEND
	cQuery += "         FROM "+RetSqlName('SZ3')+" ZZZZZ3"+CEND
	cQuery += "         WHERE ZZZZZ3.D_E_L_E_T_ = ' '"+CEND
	cQuery += "         AND Z3_FILIAL = '"+xFilial('SZ3')+"'"+CEND
	
	// Possibilita alteraÁ„o do Municipio e solicita uma senha para validar MCVN - 02/08/2007
	If !Empty(cMunicipio).and. Left(cMun,17) <> Left(cMunicipio,17) // MCVN - 02/08/2007
		
		
		
		cQuery += " AND Z3_CAP_MUN =  ISNULL((SELECT X5_DESCENG   "+CEND
		cQuery += " FROM "+RetSqlName('SX5')+" SX5"+CEND
		cQuery += " WHERE X5_FILIAL = '"+xFilial('SX5')+"'"+CEND
		cQuery += " AND X5_TABELA = '2Z'   "+CEND
		cQuery += " AND X5_CHAVE = A4_COD   "+CEND
		cQuery += " AND X5_DESCRI =  '"+cEstFr+"'"+CEND
		cQuery += " AND X5_DESCSPA = '"+cMunFr+"'"+CEND
		cQuery += " AND SX5.D_E_L_E_T_ = ' '),'"+cMunicipio+"') "+CEND
		
	ElseIf !Empty(cMunicipio).and. Left(cMun,17) == Left(cMunicipio,17)
		
		
		cQuery += " AND Z3_CAP_MUN =  ISNULL((SELECT X5_DESCENG   "+CEND
		cQuery += " FROM "+RetSqlName('SX5')+" SX5"+CEND
		cQuery += " WHERE X5_FILIAL = '"+xFilial('SX5')+"'"+CEND
		cQuery += " AND X5_TABELA = '2Z'   "+CEND
		cQuery += " AND X5_CHAVE = A4_COD   "+CEND
		cQuery += " AND X5_DESCRI =  '"+cEstFr+"'"+CEND
		cQuery += " AND X5_DESCSPA = '"+cMunFr+"'"+CEND
		cQuery += " AND SX5.D_E_L_E_T_ = ' '),'"+cMunicipio+"') "+CEND
		
	ElseIf !Empty(cMunicipio)
		cQuery += "         AND Z3_CAP_MUN NOT IN "+cCidPolo+CEND
	EndIf
	cQuery += "         AND Z3_EST = '"+cEstado+"'"+CEND
	cQuery += " 	    AND Z3_TRANSP NOT IN (SELECT DISTINCT Z3_TRANSP"+CEND
	cQuery += "                               FROM "+RetSqlName('SZ3')+" ZZ3"+CEND
	cQuery += "                               WHERE ZZ3.D_E_L_E_T_ = ' '"+CEND
	cQuery += "                                 AND Z3_FILIAL = '"+xFilial('SZ3')+"'"+CEND
	
	// Possibilita alteraÁ„o do Municipio e solicita uma senha para validar MCVN - 02/08/2007
	If !Empty(cMunicipio).and. Left(cMun,17) <> Left(cMunicipio,17)                      // MCVN - 02/08/2007
		
		
		
		cQuery += " AND Z3_CAP_MUN =  ISNULL((SELECT X5_DESCENG   "+CEND
		cQuery += " FROM "+RetSqlName('SX5')+" SX5"+CEND
		cQuery += " WHERE X5_FILIAL = '"+xFilial('SX5')+"'"+CEND
		cQuery += " AND X5_TABELA = '2Z'   "+CEND
		cQuery += " AND X5_CHAVE = A4_COD   "+CEND
		cQuery += " AND X5_DESCRI =  '"+cEstFr+"'"+CEND
		cQuery += " AND X5_DESCSPA = '"+cMunFr+"'"+CEND
		cQuery += " AND SX5.D_E_L_E_T_ = ' '),'"+cMunicipio+"') "+CEND
		
	ElseIf !Empty(cMunicipio).and. Left(cMun,17) == Left(cMunicipio,17)
		
		
		
		cQuery += " AND Z3_CAP_MUN =  ISNULL((SELECT X5_DESCENG   "+CEND
		cQuery += " FROM "+RetSqlName('SX5')+" SX5"+CEND
		cQuery += " WHERE X5_FILIAL = '"+xFilial('SX5')+"'"+CEND
		cQuery += " AND X5_TABELA = '2Z'   "+CEND
		cQuery += " AND X5_CHAVE = A4_COD   "+CEND
		cQuery += " AND X5_DESCRI =  '"+cEstFr+"'"+CEND
		cQuery += " AND X5_DESCSPA = '"+cMunFr+"'"+CEND
		cQuery += " AND SX5.D_E_L_E_T_ = ' '),'"+cMunicipio+"') "+CEND
		
	ElseIf !Empty(cMunicipio)
		cQuery += "                                 AND Z3_CAP_MUN NOT IN "+cCidPolo+CEND
	EndIf
	cQuery += "                                 AND Z3_EST = '"+cEstado+"'"+CEND
	cQuery += "                                 AND Z3_PESOLIM >= '"+cPesoBruto+"') "+CEND
	cQuery += " )))"+CEND
	cQuery += " ORDER BY Z3_VALOR "+CEND
	//*****************************************************************************   Giovani Zago 20/10/2011
EndIf

memowrite('frete.SQL',cQuery)

cQuery := ChangeQuery(cQuery)
DbCommitAll()

If Select('TRB') > 0
    TRB->( DbCloseArea() ) 
EndIf

dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'TRB', .F., .T.)

DbSelectArea("TRB")
//---------------------------------------------------
// Verifica se foi encontrada a tabela de calculo do
// frete para o destino informado.
//---------------------------------------------------

If TRB->(Bof().and.Eof()) //.and. !cCodTransp $ '000001/000111/000112/000851'
	
	If 	  !("DIPM019" $ FUNNAME()) .AND. !("DIPM028" $ FUNNAME()) // Faturamento
		If ( Type("l410Auto") == "U" .OR. !l410Auto ) .and. ;
			(cFuncao <> "NF" .or. (_cNomeRot $ "TMKVLDE4" .and. !empty(M->UA_TRANSP)))
			MsgInfo('N„o foi encontrada a tabela de para calculo do'+chr(13)+chr(10)+;
			'frete no destino informado.                   '+chr(13)+chr(10)+chr(13)+chr(10)+;
			'Verique o destino infomado!                   ','AtenÁ„o')
			
			If cFuncao=='TMK' // Call Center
				M->UA_FRETE:=0
				
			ElseIf  !("DIPM019" $ FUNNAME())  // Faturamento
				
				U_SetC5Var("M->C5_FRETE",0)
				U_SetC5Var("M->C5_TPFRETE",'')
				
				M->C5_FRETE:=0
				M->C5_TPFRETE := ''
			EndIf
		Endif
	EndIf
	
EndIf
//---------------------------------------------------
// Calcula o custo do frete em cada transportadora
// que atendeu aos parametros do Cliente
//---------------------------------------------------
TRB->(dbGotop())
Do While TRB->(!EOF())

    nEmex := 0
    
	If TRB->Z3_TRANSP == "123455"
        lCodCepTRT :=TRTAtiva(cCepCli,TRB->Z3_TRANSP)
        If lCodCepTRT 
			_nTRT := TRB->Z3_TRTMIN
		EndIf
	Endif	 
	
	If TRB->Z3_TRANSP == "000204"
        lCodCepTRT :=TRTAtiva(cCepCli,TRB->Z3_TRANSP)
        If lCodCepTRT 
			_nTRT := TRB->Z3_TRTMIN
		EndIf
	Endif	
	
	If TRB->Z3_TRANSP$"000235" .And. _nPesoBr>30
		TRB->(dbSkip())
		Loop
	EndIf

	If TRB->Z3_TRANSP$"000236" .And. _nPesoBr>15
		TRB->(dbSkip())
		Loop
	EndIf                               
	
	nValAuxZ3 := TRB->Z3_VALOR
	nExceden  := TRB->Z3_EXCEDEN    
	nAdValAux := TRB->Z3_ADVALOR

	If TRB->Z3_TRANSP == "000905" 
		cTipInter := DipInter(cEstFr,cMunFr,"000905") 
		If cTipInter == "2"
			nValAuxZ3 := TRB->Z3_XVLINT2 
			nExceden  := TRB->Z3_XEXCED2
		EndIf   
	EndIf
		
	If TRB->Z3_TRANSP == "000150"
		cTipInter := DipInter(cEstFr,cMunFr,"000150")
		If cTipInter == "4"    
			nValAuxZ3 := TRB->Z3_XVLINTF 
			nExceden  := TRB->Z3_XEXCEDF
			If TRB->Z3_XADVALF>0
				nAdValAux := TRB->Z3_XADVALF
			EndIf			
		ElseIf cTipInter == "3"    
			nValAuxZ3 := TRB->Z3_XVLINT3 
			nExceden  := TRB->Z3_XEXCED3
			If TRB->Z3_XADVAL3>0
				nAdValAux := TRB->Z3_XADVAL3
			EndIf
		ElseIf cTipInter == "2"
			nValAuxZ3 := TRB->Z3_XVLINT2 
			nExceden  := TRB->Z3_XEXCED2
			If TRB->Z3_XADVAL2>0
				nAdValAux := TRB->Z3_XADVAL2
			EndIf
		EndIf
	EndIf

	If TRB->Z3_TRANSP == "955917"
		cTipInter := DipInter(cEstFr,cMunFr,"955917")
		If cTipInter == "4"    
			nValAuxZ3 := TRB->Z3_XVLINTF 
			nExceden  := TRB->Z3_XEXCEDF
			If TRB->Z3_XADVALF>0
				nAdValAux := TRB->Z3_XADVALF
			EndIf			
		ElseIf cTipInter == "3"    
			nValAuxZ3 := TRB->Z3_XVLINT3 
			nExceden  := TRB->Z3_XEXCED3
			If TRB->Z3_XADVAL3>0
				nAdValAux := TRB->Z3_XADVAL3
			EndIf
		ElseIf cTipInter == "2"
			nValAuxZ3 := TRB->Z3_XVLINT2 
			nExceden  := TRB->Z3_XEXCED2
			If TRB->Z3_XADVAL2>0
				nAdValAux := TRB->Z3_XADVAL2
			EndIf
		EndIf
	EndIf
		
	_cAliasAux := Alias()
	
	If (TRB->Z3_FRETE == 0 .Or. TRB->Z3_VALMIN == 0) .And. nValAuxZ3 > 0 // PRIMEIRO CASO - FRETE CALCULADO BASEADO NO PESO DOS PRODUTOS
	
		nFrete := nValAuxZ3

		If TRB->Z3_TRANSP == '102000' 
		    If _nPesoBr > TRB->Z3_PESOLIM
				nFrete := _nPesoBr*nValAuxZ3/1000  
				nFrete += _nVlrTotal*nAdValAux/100
				nFrete += TRB->(Z3_DCE+Z3_TAS)
				nFrete += (Int(Iif(_nPesoBr-1<0,0,_nPesoBr-1)/100)+1)*TRB->Z3_PEDAGIO
				nFrete += _nVlrTotal*TRB->Z3_GRIS/100
				nFrete += nFrete*TRB->Z3_ICM/100
	    	Else
	    		nFrete := TRB->Z3_FRETMIN		    		
		    EndIf
		 	
		 	If TRB->Z3_EST = 'PA'
				cSQL := "SELECT ZV_TRANSP, ZV_VIAGEM "
				cSQL += " FROM " + RetSQLName("SZV")
				cSQL += " WHERE ZV_CEPINI <= '" + cCepCli + "'"
				cSQL += "   AND ZV_CEPFIM >= '" + cCepCli + "'"
				cSQL += "   AND ZV_FILIAL  = '" + xFilial("SZV") + "'"
				cSQL += "   AND ZV_TRANSP  = '" + TRB->Z3_TRANSP + "'"
				cSQL += "   AND " + RetSQLName("SZV") + ".D_E_L_E_T_ = ' ' "
		
				cSQL := ChangeQuery(cSQL)
				dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),"QRYSZV",.T.,.T.)
				
				If !QRYSZV->(Eof())    
					nFrete := nFrete*(1+(TRB->Z3_ADCFLU2/100))
				EndIf
				QRYSZV->(dbCloseArea())			
			EndIf                 
			
			nValorFrete := nFrete
			
		Else                			
			
			nAdValor    := Iif((_nVlrTotal * nAdValAux / 100) < TRB->Z3_ADVAMIN,TRB->Z3_ADVAMIN,_nVlrTotal * nAdValAux / 100) //  Frete Nota da Faixa de Peso - ADICIONAL DE VALOR COM VALOR MÕNIMO MCVN 02/08/2007
			nGris       := Iif((_nVlrTotal * TRB->Z3_GRIS  / 100) < TRB->Z3_GRISMIN,TRB->Z3_GRISMIN,_nVlrTotal * TRB->Z3_GRIS  / 100)     //  Gris da Faixa com gris mÌnimo MCVN 25/07/2007
			
			If "DIPM019" $ FUNNAME()  .or. "DIPM028" $ FUNNAME()//MCVN - 01/11/2009 Processamento de EDI
				If TRB->Z3_TRANSP $ '000150/100000/003025/955917' // SE FOR BRASPRESS O PED¡GIO … UMA TAXA FIXA - MCVN 01/10/2009
					nPedagio := (TRB->Z3_PEDAGIO)/Len(aDipInfNf)
				Else
					nPedagio := (Int(Iif(_nPesoBr-1<0,0,_nPesoBr-1)/100)+1)*TRB->Z3_PEDAGIO // Valor dos Pedagios
				Endif

				If TRB->Z3_TRANSP $ '955917/000905'
					If nExceden > 0
						nFrete :=  nExceden * _nPesoBr 
					Endif
					nExcedente := 0
				Else
					nExcedente := Iif(nExceden > 0.and. _nPesoBr > TRB->Z3_PESOLIM,nExceden * (_nPesoBr - TRB->Z3_PESOLIM),0)
				Endif

				nSuframa    := (TRB->Z3_SUFRAMA)/Len(aDipInfNf)  // SUFRAMA  MCVN - 15/08/2007
				nAdcFluv    := (Iif((_nVlrTotal * TRB->Z3_ADCFLUV / 100) < TRB->Z3_FLUVMIN,TRB->Z3_FLUVMIN,_nVlrTotal * TRB->Z3_ADCFLUV / 100))/Len(aDipInfNf)  // ADICIONAL FLUVIAL - MCVN - 15/08/2007
				nTaxaExc    := (TRB->Z3_TAXAEXC)/Len(aDipInfNf)
				nDCE        := (TRB->Z3_DCE)/Len(aDipInfNf) //DCE-Taxa p/ Docum. Eletronica - MCVN - 01/10/2009
				nTAS        := (TRB->Z3_TAS)/Len(aDipInfNf) //Taxa de Admins. da SEFAZ - MCVN - 01/10/2009
				nTRF        := (Iif((_nVlrTotal * TRB->Z3_TRF / 100) < TRB->Z3_TRF_MIN,TRB->Z3_TRF_MIN,_nVlrTotal * TRB->Z3_TRF / 100))/Len(aDipInfNf)  // TRF - MCVN - 01/10/2009
				
				If     TRB->Z3_TRANSP == "123455"
					 
					cSQL := "SELECT ZV_LOCALID "
					cSQL += " FROM " + RetSQLName("SZV")
					cSQL += " WHERE ZV_FILIAL  = '" + xFilial("SZV") + "'"
					cSQL += "   AND ZV_CEPINI <= '" + cCepCli + "'"
					cSQL += "   AND ZV_CEPFIM >= '" + cCepCli + "'"
  					cSQL += "   AND ZV_TRANSP  = '" + TRB->Z3_TRANSP + "'"
					cSQL += "   AND ZV_XEMEX   = '1' "
					cSQL += "   AND " + RetSQLName("SZV") + ".D_E_L_E_T_ = ' ' "
		
					cSQL := ChangeQuery(cSQL)
					dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),"QRYSZV",.T.,.T.)
				
					If !QRYSZV->(Eof())    
						nEmex := ((_nVlrTotal * TRB->Z3_XPCEMEX / 100) + TRB->Z3_XVLEMEX)
					EndIf
					QRYSZV->(dbCloseArea())			
					
				ElseIf TRB->Z3_TRANSP == "000905" 

					cSQL := "SELECT ZV_LOCALID "
					cSQL += " FROM " + RetSQLName("SZV")
					cSQL += " WHERE ZV_FILIAL  = '" + xFilial("SZV") + "'"  
					cSQL += "   AND ZV_CEPINI <= '" + cCepCli + "'"
					cSQL += "   AND ZV_CEPFIM >= '" + cCepCli + "'"
  					cSQL += "   AND ZV_TRANSP  = '" + TRB->Z3_TRANSP + "'"
					cSQL += "   AND ZV_XEMEX   = '1' "
					cSQL += "   AND " + RetSQLName("SZV") + ".D_E_L_E_T_ = ' ' "
		
					cSQL := ChangeQuery(cSQL)
					dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),"QRYSZV",.T.,.T.)
				
					If !QRYSZV->(Eof())    
						nEmex   := If ((_nVlrTotal * TRB->Z3_XPCEMEX / 100) > TRB->Z3_XVLEMEX,(_nVlrTotal * TRB->Z3_XPCEMEX / 100),TRB->Z3_XVLEMEX)
					EndIf
					QRYSZV->(dbCloseArea())			
				
				ElseIf TRB->Z3_TRANSP == "000204" 

					cSQL := "SELECT ZV_LOCALID "
					cSQL += " FROM " + RetSQLName("SZV")
					cSQL += " WHERE ZV_FILIAL  = '" + xFilial("SZV") + "'"  
					cSQL += "   AND ZV_CEPINI <= '" + cCepCli + "'"
					cSQL += "   AND ZV_CEPFIM >= '" + cCepCli + "'"
  					cSQL += "   AND ZV_TRANSP  = '" + TRB->Z3_TRANSP + "'"
					cSQL += "   AND ZV_XEMEX   = '1' "
					cSQL += "   AND " + RetSQLName("SZV") + ".D_E_L_E_T_ = ' ' "
		
					cSQL := ChangeQuery(cSQL)
					dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),"QRYSZV",.T.,.T.)
				
					If !QRYSZV->(Eof())    
						nEmex := (Int(Iif(_nPesoBr-1<0,0,_nPesoBr-1)/100)+1)*TRB->Z3_XVLEMEX // Valor do Emex
						nEmex := nEmex + (_nVlrTotal * TRB->Z3_XPCEMEX / 100)
					EndIf
					QRYSZV->(dbCloseArea())			
				
				EndIf				
				
				nTaxaAdm    := ((nFrete + nAdvalor + nGris + nPedagio + nExcedente + nTaxaExc + nSuframa + nAdcFluv + nDCE + nTAS + nTRF + nTRT + nEmex) * TRB->Z3_TXADMIN /100)/Len(aDipInfNf) // TAXA ADMINISTRATIVA DA BRASPRESS - MCVN - 01/10/2009
				If TRB->Z3_TRANSP == "123455"
					If lCodCepTRT 
						nTRT := _nTRT
					EndIf  					  
				Else
					nTRT        := (Iif(((nFrete + nAdvalor + nGris + nPedagio + nExcedente + nTaxaExc + nSuframa + nAdcFluv + nDCE + nTAS + nTRF + nTaxaAdm) * TRB->Z3_TRT / 100 ) < TRB->Z3_TRTMIN,TRB->Z3_TRTMIN, ;
					(nFrete + nAdvalor + nGris + nPedagio + nExcedente + nTaxaExc + nSuframa + nAdcFluv + nDCE + nTAS + nTRF + nTaxaAdm) * TRB->Z3_TRT / 100))/Len(aDipInfNf)  // TRF - MCVN - 01/10/2009
				EndIf
				//nTRT        := (Iif((((nFrete + nAdvalor + nGris + nPedagio + nExcedente + nTaxaExc + nSuframa + nAdcFluv + nDCE + nTAS + nTRF + nTaxaAdm) * TRB->Z3_TRT / 100);
				//            < TRB->Z3_TRTMIN,TRB->Z3_TRTMIN, (nFrete + nAdvalor + nGris + nPedagio + nExcedente + nTaxaExc + nSuframa + nAdcFluv + nDCE + nTAS + nTRF + nTaxaAdm);
				//            * TRB->Z3_TRT / 100)))/Len(aDipInfNf)  // TRF - MCVN - 01/10/2009
				//  nICM        := ((nFrete + nAdvalor + nGris + nPedagio + nExcedente + nTaxaExc + nSuframa + nAdcFluv + nDCE + nTAS + nTRF + nTaxaAdm) * TRB->Z3_ICM /100)/Len(aDipInfNf)
				nICM        := (((nFrete + nAdvalor + nGris + nPedagio + nExcedente + nTaxaExc + nSuframa + nAdcFluv + nDCE + nTAS + nTRF + nTaxaAdm + nTRT + nEmex) / ((100 - TRB->Z3_ICM) / 100)) -;
				(nFrete + nAdvalor + nGris + nPedagio + nExcedente + nTaxaExc + nSuframa + nAdcFluv + nDCE + nTAS + nTRF + nTaxaAdm + nTRT + nEmex))/Len(aDipInfNf)
			Else
				If TRB->Z3_TRANSP $ '000150/100000/003025/955917' // SE FOR BRASPRESS O PED¡GIO … UMA TAXA FIXA - MCVN 01/10/2009
					nPedagio := TRB->Z3_PEDAGIO
				Else
					nPedagio := (Int(Iif(_nPesoBr-1<0,0,_nPesoBr-1)/100)+1)*TRB->Z3_PEDAGIO // Valor dos Pedagios
				Endif

				If TRB->Z3_TRANSP $ '955917/000905'
					If nExceden > 0
						nFrete :=  nExceden * _nPesoBr 
					Endif
					nExcedente := 0
				Else
					nExcedente  := Iif(nExceden > 0.and. _nPesoBr > TRB->Z3_PESOLIM,nExceden * (_nPesoBr - TRB->Z3_PESOLIM),0)
				Endif
				nSuframa    := TRB->Z3_SUFRAMA  // SUFRAMA  MCVN - 15/08/2007
				nAdcFluv    := Iif((_nVlrTotal * TRB->Z3_ADCFLUV / 100) < TRB->Z3_FLUVMIN,TRB->Z3_FLUVMIN,_nVlrTotal * TRB->Z3_ADCFLUV / 100)  // ADICIONAL FLUVIAL - MCVN - 15/08/2007
				nTaxaExc    := TRB->Z3_TAXAEXC
				nDCE        := TRB->Z3_DCE //DCE-Taxa p/ Docum. Eletronica - MCVN - 01/10/2009
				nTAS        := TRB->Z3_TAS //Taxa de Admins. da SEFAZ - MCVN - 01/10/2009
				nTRF        := Iif((_nVlrTotal * TRB->Z3_TRF / 100) < TRB->Z3_TRF_MIN,TRB->Z3_TRF_MIN,_nVlrTotal * TRB->Z3_TRF / 100)  // TRF - MCVN - 01/10/2009

				If     TRB->Z3_TRANSP == "123455"
					 
					cSQL := "SELECT ZV_LOCALID "
					cSQL += " FROM " + RetSQLName("SZV")
					cSQL += " WHERE ZV_FILIAL  = '" + xFilial("SZV") + "'"   
					cSQL += "   AND ZV_CEPINI <= '" + cCepCli + "'"
					cSQL += "   AND ZV_CEPFIM >= '" + cCepCli + "'"
  					cSQL += "   AND ZV_TRANSP  = '" + TRB->Z3_TRANSP + "'"
					cSQL += "   AND ZV_XEMEX   = '1' "
					cSQL += "   AND " + RetSQLName("SZV") + ".D_E_L_E_T_ = ' ' "
		
					cSQL := ChangeQuery(cSQL)
					dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),"QRYSZV",.T.,.T.)
				
					If !QRYSZV->(Eof())    
						nEmex := ((_nVlrTotal * TRB->Z3_XPCEMEX / 100) + TRB->Z3_XVLEMEX)
					EndIf
					QRYSZV->(dbCloseArea())			
					
				ElseIf TRB->Z3_TRANSP == "000905" 

					cSQL := "SELECT ZV_LOCALID "
					cSQL += " FROM " + RetSQLName("SZV")
					cSQL += " WHERE ZV_FILIAL  = '" + xFilial("SZV") + "'"    
					cSQL += "   AND ZV_CEPINI <= '" + cCepCli + "'"
					cSQL += "   AND ZV_CEPFIM >= '" + cCepCli + "'"					
  					cSQL += "   AND ZV_TRANSP  = '" + TRB->Z3_TRANSP + "'"
					cSQL += "   AND ZV_XEMEX   = '1' "
					cSQL += "   AND " + RetSQLName("SZV") + ".D_E_L_E_T_ = ' ' "
		
					cSQL := ChangeQuery(cSQL)
					dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),"QRYSZV",.T.,.T.)
				
					If !QRYSZV->(Eof())    
						nEmex   := If ((_nVlrTotal * TRB->Z3_XPCEMEX / 100) > TRB->Z3_XVLEMEX,(_nVlrTotal * TRB->Z3_XPCEMEX / 100),TRB->Z3_XVLEMEX)
					EndIf
					QRYSZV->(dbCloseArea())			
				
				ElseIf TRB->Z3_TRANSP == "000204" 

					cSQL := "SELECT ZV_LOCALID "
					cSQL += " FROM " + RetSQLName("SZV")
					cSQL += " WHERE ZV_FILIAL  = '" + xFilial("SZV") + "'"  
					cSQL += "   AND ZV_CEPINI <= '" + cCepCli + "'"
					cSQL += "   AND ZV_CEPFIM >= '" + cCepCli + "'"
  					cSQL += "   AND ZV_TRANSP  = '" + TRB->Z3_TRANSP + "'"
					cSQL += "   AND ZV_XEMEX   = '1' "
					cSQL += "   AND " + RetSQLName("SZV") + ".D_E_L_E_T_ = ' ' "
		
					cSQL := ChangeQuery(cSQL)
					dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),"QRYSZV",.T.,.T.)
				
					If !QRYSZV->(Eof())    
						nEmex := (Int(Iif(_nPesoBr-1<0,0,_nPesoBr-1)/100)+1)*TRB->Z3_XVLEMEX // Valor do Emex
						nEmex := nEmex + (_nVlrTotal * TRB->Z3_XPCEMEX / 100)
					EndIf
					QRYSZV->(dbCloseArea())			
				
				EndIf				

				nTaxaAdm    := (nFrete + nAdvalor + nGris + nPedagio + nExcedente + nTaxaExc + nSuframa + nAdcFluv + nDCE + nTAS + nTRF + 	nTRT + nEmex) * TRB->Z3_TXADMIN /100 // TAXA ADMINISTRATIVA DA BRASPRESS - MCVN - 01/10/2009
				If TRB->Z3_TRANSP == "123455"
					If lCodCepTRT 
						nTRT := _nTRT
					EndIf  					  
				Else
					  nTRT        := Iif(((nFrete + nAdvalor + nGris + nPedagio + nExcedente + nTaxaExc + nSuframa + nAdcFluv + nDCE + nTAS + nTRF + nTaxaAdm) * TRB->Z3_TRT / 100) < TRB->Z3_TRTMIN,TRB->Z3_TRTMIN,;
					  (nFrete + nAdvalor + nGris + nPedagio + nExcedente + nTaxaExc + nSuframa + nAdcFluv + nDCE + nTAS + nTRF + nTaxaAdm) * TRB->Z3_TRT / 100)  // TRF - MCVN - 01/10/2009
				EndIf	  
				//			nICM        := (nFrete + nAdvalor + nGris + nPedagio + nExcedente + nTaxaExc + nSuframa + nAdcFluv + nDCE + nTAS + nTRF + nTaxaAdm) * TRB->Z3_ICM /100
				nICM        := ((nFrete + nAdvalor + nGris + nPedagio + nExcedente + nTaxaExc + nSuframa + nAdcFluv + nDCE + nTAS + nTRF + nTaxaAdm + nTRT + nEmex) / ((100 - TRB->Z3_ICM) / 100)) -;
				(nFrete + nAdvalor + nGris + nPedagio + nExcedente + nTaxaExc + nSuframa + nAdcFluv + nDCE + nTAS + nTRF + nTaxaAdm + nTRT + nEmex)
			Endif
			
			If ("HEALTH" $ SM0->M0_NOMECOM)
				nValAcres   := (nFrete + nAdvalor + nGris + nPedagio + nExcedente + nTaxaExc + nSuframa + nAdcFluv + nDCE + nTAS + nTRF + nTaxaAdm + nTRT + nEmex + nICM) * TRB->Z3_ACREHQ /100
			Else
				nValAcres   := (nFrete + nAdvalor + nGris + nPedagio + nExcedente + nTaxaExc + nSuframa + nAdcFluv + nDCE + nTAS + nTRF + nTaxaAdm + nTRT + nEmex + nICM) * TRB->Z3_ACREDIP /100
			Endif
			nValorFrete :=  nFrete + nAdvalor + nGris + nPedagio + nExcedente + nTaxaExc + nSuframa + nAdcFluv + nDCE + nTAS + nTRF + nTaxaAdm + nICM + nTRT + nEmex + nValAcres
			nValorFrete := Iif(nValorFrete < TRB->Z3_VALMIN,TRB->Z3_VALMIN,nValorFrete)   // MCVN - 14/05/2008
		EndIf			
	ElseIf (TRB->Z3_FRETE <> 0 .AND. TRB->Z3_VALMIN <> 0) .And. nValAuxZ3 = 0   // SEGUNDA CASO - FRETE CALCULADO ATRAV…S DO VALOR DA NOTA (O PESO AQUI N√O … CONSIDERADO)

		If TRB->Z3_TRANSP == '102000' 
		    If _nPesoBr > TRB->Z3_PESOLIM
				nFrete := _nPesoBr*nValAuxZ3/1000  
				nFrete += _nVlrTotal*nAdValAux/100
				nFrete += TRB->(Z3_DCE+Z3_TAS)
				nFrete += (Int(Iif(_nPesoBr-1<0,0,_nPesoBr-1)/100)+1)*TRB->Z3_PEDAGIO
				nFrete += _nVlrTotal*TRB->Z3_GRIS/100
				nFrete += nFrete*TRB->Z3_ICM/100
	    	Else
	    		nFrete := TRB->Z3_FRETMIN		    		
		    EndIf
		 	
		 	If TRB->Z3_EST = 'PA'
				cSQL := "SELECT ZV_TRANSP, ZV_VIAGEM "
				cSQL += " FROM " + RetSQLName("SZV")
				cSQL += " WHERE ZV_CEPINI <= '" + cCepCli + "'"
				cSQL += "   AND ZV_CEPFIM >= '" + cCepCli + "'"
				cSQL += "   AND ZV_FILIAL  = '" + xFilial("SZV") + "'"
				cSQL += "   AND ZV_TRANSP  = '" + TRB->Z3_TRANSP + "'"
				cSQL += "   AND " + RetSQLName("SZV") + ".D_E_L_E_T_ = ' ' "
		
				cSQL := ChangeQuery(cSQL)
				dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),"QRYSZV",.T.,.T.)
				
				If !QRYSZV->(Eof())    
					nFrete := nFrete*(1+(TRB->Z3_ADCFLU2/100))
				EndIf
				QRYSZV->(dbCloseArea())			
			EndIf                 
			
			nValorFrete := nFrete
		Else		
			nFrete      := Iif((_nVlrTotal * TRB->Z3_FRETE / 100) < TRB->Z3_VALMIN,TRB->Z3_VALMIN,_nVlrTotal * TRB->Z3_FRETE / 100)         //  Calculando Frete Minimo  MCVN 14/08/2007
			nPedagio    := (Int(Iif(_nPesoBr-1<0,0,_nPesoBr-1)/100)+1)* TRB->Z3_PEDAGIO // Valor dos Pedagios
			nICM        := (nFrete + nPedagio) * TRB->Z3_ICM /100
			nICM        := ((nFrete + nPedagio) / ((100-TRB->Z3_ICM) /100 ))-(nFrete + nPedagio) //Alterado regra de icms - MCVN 27/08/10
			If ("HEALTH" $ SM0->M0_NOMECOM)
				nValAcres   := (nFrete + nAdvalor + nGris + nPedagio + nExcedente + nTaxaExc + nSuframa + nAdcFluv) * TRB->Z3_ACREHQ /100
			Else
				nValAcres   := (nFrete + nAdvalor + nGris + nPedagio + nExcedente + nTaxaExc + nSuframa + nAdcFluv) * TRB->Z3_ACREDIP /100
			Endif
			nValorFrete := nFrete + nPedagio + nICM + nValAcres
		EndIf
	ElseIf TRB->Z3_LIMGRIS > 0  // TERCEIRO CASO  - FRETE CALCULADO SEM VALOR INICIAL (PESO*VALOR)+IMPOSTOS+PEDAGIOS,GRIS  ETC...  MCVN - 19/05/09

		If TRB->Z3_TRANSP == '102000' 
		    If _nPesoBr > TRB->Z3_PESOLIM
				nFrete := _nPesoBr*nValAuxZ3/1000  
				nFrete += _nVlrTotal*nAdValAux/100
				nFrete += TRB->(Z3_DCE+Z3_TAS)
				nFrete += (Int(Iif(_nPesoBr-1<0,0,_nPesoBr-1)/100)+1)*TRB->Z3_PEDAGIO
				nFrete += _nVlrTotal*TRB->Z3_GRIS/100
				nFrete += nFrete*TRB->Z3_ICM/100
	    	Else
	    		nFrete := TRB->Z3_FRETMIN		    		
		    EndIf
		 	
		 	If TRB->Z3_EST = 'PA'
				cSQL := "SELECT ZV_TRANSP, ZV_VIAGEM "
				cSQL += " FROM " + RetSQLName("SZV")
				cSQL += " WHERE ZV_CEPINI <= '" + cCepCli + "'"
				cSQL += "   AND ZV_CEPFIM >= '" + cCepCli + "'"
				cSQL += "   AND ZV_FILIAL  = '" + xFilial("SZV") + "'"
				cSQL += "   AND ZV_TRANSP  = '" + TRB->Z3_TRANSP + "'"
				cSQL += "   AND " + RetSQLName("SZV") + ".D_E_L_E_T_ = ' ' "
		
				cSQL := ChangeQuery(cSQL)
				dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),"QRYSZV",.T.,.T.)
				
				If !QRYSZV->(Eof())    
					nFrete := nFrete*(1+(TRB->Z3_ADCFLU2/100))
				EndIf
				QRYSZV->(dbCloseArea())			
			EndIf                 
			
			nValorFrete := nFrete
			
		Else				
			nExcedente  := Iif(( nExceden * _nPesoBr) < TRB->Z3_VALMIN,TRB->Z3_VALMIN,nExceden * _nPesoBr)
			nAdValor    := Iif((_nVlrTotal * nAdValAux / 100) < TRB->Z3_ADVAMIN,TRB->Z3_ADVAMIN,_nVlrTotal * nAdValAux / 100) //  Frete Nota da Faixa de Peso - ADICIONAL DE VALOR COM VALOR MÕNIMO MCVN 02/08/2007
			nGris       := Iif(_nVlrTotal < TRB->Z3_LIMGRIS,Iif((_nVlrTotal * TRB->Z3_GRIS  / 100) < TRB->Z3_GRISMIN,TRB->Z3_GRISMIN,_nVlrTotal * TRB->Z3_GRIS  / 100);
			,Iif((_nVlrTotal * TRB->Z3_GRIS2 / 100) < TRB->Z3_GRISMIN,TRB->Z3_GRISMIN,_nVlrTotal * TRB->Z3_GRIS2 /100))     //  Gris da Faixa com gris mÌnimo MCVN 25/07/2007
			nPedagio    := (Int(Iif(_nPesoBr-1<0,0,_nPesoBr-1)/100)+1)* TRB->Z3_PEDAGIO // Valor dos Pedagios
			nSuframa    := TRB->Z3_SUFRAMA  // SUFRAMA  MCVN - 15/08/2007
			nAdcFluv    := Iif((_nVlrTotal * TRB->Z3_ADCFLUV / 100) < TRB->Z3_FLUVMIN,TRB->Z3_FLUVMIN,_nVlrTotal * TRB->Z3_ADCFLUV / 100)  // ADICIONAL FLUVIAL - MCVN - 15/08/2007
			nTaxaExc    := TRB->Z3_TAXAEXC
			//nICM        := (nExcedente + nAdvalor + nGris + nPedagio + nTaxaExc + nSuframa + nAdcFluv) * TRB->Z3_ICM /100
			nICM        := ((nExcedente + nAdvalor + nGris + nPedagio + nTaxaExc + nSuframa + nAdcFluv)/((100-TRB->Z3_ICM)/100))-; //Alterado regra de icms - MCVN 27/08/10
			(nExcedente + nAdvalor + nGris + nPedagio + nTaxaExc + nSuframa + nAdcFluv)
			If ("HEALTH" $ SM0->M0_NOMECOM)
				nValAcres   := (nFrete + nAdvalor + nGris + nPedagio + nExcedente + nTaxaExc + nSuframa + nAdcFluv) * TRB->Z3_ACREHQ /100
			Else
				nValAcres   := (nFrete + nAdvalor + nGris + nPedagio + nExcedente + nTaxaExc + nSuframa + nAdcFluv) * TRB->Z3_ACREDIP /100
			Endif
			nValorFrete :=  nExcedente + nAdvalor + nGris + nPedagio + nTaxaExc + nSuframa + nAdcFluv + nICM + nValAcres
		EndIf		
	Endif
	
	dbSelectArea(_cAliasAux)
	

	//--------------------------------------------------------
	// Grava na Work para mostrar ao usuario as opÁıes de
	// calculo encontradas em cada transportadora
	//--------------------------------------------------------
	//Giovani Zago 10/01/2012 tratameno para nao selecionar braspress=000150 e jamef=000905
	
	If TRB->Z3_TRANSP == "000905" .And. TRTAtiva(nil,TRB->Z3_TRANSP,cCodCli)
		nVlrMinTDE := GetNewPar("ES_VMINJMF",200.00)
		nVlrMaxTDE := GetNewPar("ES_VMAXJMF",3851.86)
		If nValorFrete <  nVlrMinTDE //Valor mÌnimo
			nValorFrete := nValorFrete+nVlrMinTDE
		ElseIf nValorFrete > nVlrMaxTDE //Valor m·ximo
			nValorFrete := nValorFrete+nVlrMaxTDE
		Else
			nValorFrete := nValorFrete*2
		EndIf
	EndIf    
	
	If TRB->Z3_TRANSP == "123455" .And. TRTAtiva(nil,TRB->Z3_TRANSP,cCodCli)
		nVlrMinTDE := TRB->Z3_VMINTDE
		nVlrPecTDE := (nValorFrete*(TRB->Z3_PVLRTDE/100))//Valor do percentual sobre o frete
		If nVlrPecTDE < nVlrMinTDE //Valor mÌnimo
			nValorFrete := nValorFrete+(nVlrMinTDE/((100-TRB->Z3_ICM)/100))
		Else 
			 nValorFrete := nValorFrete+(nVlrPecTDE/((100-TRB->Z3_ICM)/100))
		EndIf
	EndIf    	
	
	If TRB->Z3_TRANSP == "000204" .And. TRTAtiva(nil,TRB->Z3_TRANSP,cCodCli)
		nVlrMinTDE := TRB->Z3_VMINTDE
		nVlrPecTDE := (nValorFrete*(TRB->Z3_PVLRTDE/100))//Valor do percentual sobre o frete
		If nVlrPecTDE < nVlrMinTDE //Valor mÌnimo
			nValorFrete := nValorFrete+(nVlrMinTDE/((100-TRB->Z3_ICM)/100))
		Else 
			 nValorFrete := nValorFrete+(nVlrPecTDE/((100-TRB->Z3_ICM)/100))
		EndIf
	EndIf

/*
	If TRB->Z3_TRANSP == "000204" .And. EXISTDA(cCepCli,TRB->Z3_TRANSP)
		nVlrTDA     := TRB->Z3_VLRTDA
		nVlrPercTDA := (nValorFrete*(TRB->Z3_PRCTDA/100))//Valor do percentual sobre o frete

		If nVlrPercTDA < nVlrTDA //Valor mÌnimo
			nValorFrete := nValorFrete+(nVlrTDA/((100-TRB->Z3_ICM)/100))
		Else 
			 nValorFrete := nValorFrete+(nVlrPercTDA/((100-TRB->Z3_ICM)/100))
		EndIf
	EndIf
*/
		
	If TRB->Z3_TRANSP == "000150" .And. DipVldZZS(cCodCli,cLojCli)
		nValorFrete := (nValorFrete*1.2)+70
	EndIf

	
	If TRB->Z3_TRANSP == "955917" .And. TRTAtiva(nil,TRB->Z3_TRANSP,cCodCli)
		nVlrMinTDE := TRB->Z3_VMINTDE
		nVlrPecTDE := (nValorFrete*(TRB->Z3_PVLRTDE/100))//Valor do percentual sobre o frete
		If nVlrPecTDE < nVlrMinTDE //Valor mÌnimo
			nValorFrete := nValorFrete+(nVlrMinTDE/((100-TRB->Z3_ICM)/100))
		Else 
			 nValorFrete := nValorFrete+(nVlrPecTDE/((100-TRB->Z3_ICM)/100))
		EndIf
	EndIf 

   If  (Upper(U_DipUsr()) $ 'MCANUTO')
		msginfo(;
		"frete    : "+str(nfrete,15,2)+chr(13)+chr(10)+;
		"adicional: "+str(nAdvalor,15,2)+chr(13)+chr(10)+;
		"gris     : "+str(ngris,15,2)+chr(13)+chr(10)+;
		"pedagio  : "+str(npedagio,15,2)+chr(13)+chr(10)+;
		"excedente: "+str(nexcedente,15,2)+chr(13)+chr(10)+;
		"TAS	  : "+str(ntas,15,2)+chr(13)+chr(10)+;
		"taxas    : "+str(ntaxaexc,15,2)+chr(13)+chr(10)+;
		"Trt      : "+str(nTRT,15,2)+chr(13)+chr(10)+;
		"Emex     : "+str(nEmex,15,2)+chr(13)+chr(10)+;
		"icm      : "+str(nicm,15,2)+chr(13)+chr(10)+chr(13)+chr(10)+;
		"Acrescimo: "+str(nValAcres,15,2)+chr(13)+chr(10)+chr(13)+chr(10)+;
		"total    : "+str(nvalorfrete,15,2);
		,TRB->A4_NOME)
	Endif 

	_cAuxAltFrt := AllTrim(GetNewPar("ES_ALTVLFR",""))
	_cTranspAux := ""
	If cPedido$_cAuxAltFrt
		_nPos  		:=  At("|",_cAuxAltFrt) 
		_nPos2 		:= Rat("|",_cAuxAltFrt) 
		nValorFrete := Val(SubStr(_cAuxAltFrt,_nPos+1,_nPos2-1))
		If _nPos2>_nPos
			_cTranspAux  := SubStr(_cAuxAltFrt,_nPos2+1,Len(_cAuxAltFrt))
		EndIf
	EndIf
	
	If  !("DIPM019" $ FUNNAME()) .AND. !("DIPM028" $ FUNNAME()) .and.  cFuncao <>'TMK'   .And. "MATA410" $ FUNNAME() .And. cFuncao <> "NF" .And. cEstado = "RJ"
		
		If M->C5_TPFRETE $ "C" .And. !(TRB->Z3_TRANSP $ '000150/000905')
			
			WORK_FRT->(DbAppend())
			WORK_FRT->Z3_TRANSP  := IIf(!Empty(_cTranspAux),_cTranspAux,TRB->Z3_TRANSP)
			WORK_FRT->A4_NOME    := TRB->A4_NOME
			WORK_FRT->Z3_VALOR   := nValorFrete
			WORK_FRT->Z3_VALFRET := Transform(nValorFrete,"@ek 999,999,999.99")
			WORK_FRT->Z3_EST     := TRB->Z3_EST
			WORK_FRT->Z3_CAP_MUN := TRB->Z3_CAP_MUN
			WORK_FRT->Z3_PESOLIM := TRB->Z3_PESOLIM
			WORK_FRT->PRIORIDADE := IF(TRB->Z3_TRANSP == '100000','1','9')
			WORK_FRT->ZV_VIAGEM  := If(aScan(aViagem, { |x| x[1] == Alltrim(TRB->Z3_TRANSP) }) > 0,aViagem[aScan(aViagem, { |x| x[1] == Alltrim(TRB->Z3_TRANSP) }),2],'')
		ElseIf !(M->C5_TPFRETE $ "C")
			WORK_FRT->(DbAppend())
			WORK_FRT->Z3_TRANSP  := IIf(!Empty(_cTranspAux),_cTranspAux,TRB->Z3_TRANSP)
			WORK_FRT->A4_NOME    := TRB->A4_NOME
			WORK_FRT->Z3_VALOR   := nValorFrete
			WORK_FRT->Z3_VALFRET := Transform(nValorFrete,"@ek 999,999,999.99")
			WORK_FRT->Z3_EST     := TRB->Z3_EST
			WORK_FRT->Z3_CAP_MUN := TRB->Z3_CAP_MUN
			WORK_FRT->Z3_PESOLIM := TRB->Z3_PESOLIM
			WORK_FRT->PRIORIDADE := IF(TRB->Z3_TRANSP == '100000','1','9')
			WORK_FRT->ZV_VIAGEM  := If(aScan(aViagem, { |x| x[1] == Alltrim(TRB->Z3_TRANSP) }) > 0,aViagem[aScan(aViagem, { |x| x[1] == Alltrim(TRB->Z3_TRANSP) }),2],'')
			
		EndIf
	ELSE
		WORK_FRT->(DbAppend())
		WORK_FRT->Z3_TRANSP  := IIf(!Empty(_cTranspAux),_cTranspAux,TRB->Z3_TRANSP)
		WORK_FRT->A4_NOME    := TRB->A4_NOME
		WORK_FRT->Z3_VALOR   := nValorFrete
		WORK_FRT->Z3_VALFRET := Transform(nValorFrete,"@ek 999,999,999.99")
		WORK_FRT->Z3_EST     := TRB->Z3_EST
		WORK_FRT->Z3_CAP_MUN := TRB->Z3_CAP_MUN
		WORK_FRT->Z3_PESOLIM := TRB->Z3_PESOLIM
		WORK_FRT->PRIORIDADE := IF(TRB->Z3_TRANSP == '100000','1','9')
		WORK_FRT->ZV_VIAGEM  := If(aScan(aViagem, { |x| x[1] == Alltrim(TRB->Z3_TRANSP) }) > 0,aViagem[aScan(aViagem, { |x| x[1] == Alltrim(TRB->Z3_TRANSP) }),2],'')
		
	EndIf   
                        
    /* Regra retirada em 28/09/2016
	If Left(SA1->A1_CEP,2)$'11/12' .And. TRB->Z3_TRANSP == '000150'
		WORK_FRT->PRIORIDADE := 'Z'	
	EndIf
	*/
	
	// Ajusta Ordem deixando sempre Emovere como primeira opÁ„o - 31/10/10    - Desabilitado em 21-06-11  MCVN.
	/*If WORK_FRT->Z3_TRANSP == '100000'  .And. If(nZ3_VALOR > 0,nZ3_VALOR < WORK_FRT->Z3_VALOR,.t.)
	IndRegua("WORK_FRT",cFileWork,"DESCEND(STR(Z3_VALOR))")
	nZ3_VAEMO := WORK_FRT->Z3_VALOR
	ElseIf WORK_FRT->Z3_TRANSP <> '100000'	.And. If(nZ3_VAEMO > 0,nZ3_VAEMO > WORK_FRT->Z3_VALOR,.t.)
	IndRegua("WORK_FRT",cFileWork,"Z3_VALOR")
	nZ3_VALOR := WORK_FRT->Z3_VALOR
	Endif
	*/
	IndRegua("WORK_FRT",cFileWork,"PRIORIDADE+STR(Z3_VALOR)")
	//--------------------------------------------------------
	// Se for geraÁ„o da Nota Fiscal (M460NUM)
	//--------------------------------------------------------
	If cFuncao=='NF'
		If "DIPM019" $ FUNNAME() .or. "DIPM028" $ FUNNAME()
			RecLock('SF2',.F.)
			SF2->F2_FRETSZ3:=Round(nValorFrete,2)
			SF2->(MsUnLock())
			SF2->(DbCommit())
		Else
			RecLock('SC5',.F.)
			SC5->C5_FRETE:=Round(nValorFrete,2)
			SC5->(MsUnLock())
			SC5->(DbCommit())
		Endif
		Exit
	ElseIf cFuncao=="CONSULTA"
		WORK_FRT->(E_EraseArq(cFileWork))
		TRB->(dbCloseArea())
		Return(Round(nValorFrete,2))
	ElseIf (_cNomeRot $ "TMKVLDE4" .and. !empty(M->UA_TRANSP)).or.; // AlteraÁ„o de Transportadora
		(_cNomeRot $ "TMKCBPRO" .and. !empty(M->UA_TRANSP).and.!lCif) // Chamado do Bot„o do Call Center
		//-------------------------------------------------------
		// Nesta situaÁ„o o frete precisa ser recalculado para a
		// sem fazer interaÁ„o com o usuario.
		//-------------------------------------------------------
		M->UA_FRETE:=If(lInc,nValorFrete,0)
		M->UA_NOMETRA:=TRB->A4_NOME
		//M->UA_DESTFRE:=TRB->Z3_EST+'-'+TRB->Z3_CAP_MUN MCVN - 02/08/2007 TESTANDO
		Exit
	ElseIf (_cNomeRot $ "MTA410" .and. !empty(M->C5_TRANSP)) .or.; // AlteraÁ„o de Transportadora
		(_cNomeRot $ "A410CONS" .and. !empty(M->C5_TRANSP) .And.;
		!Upper(u_DipUsr())$GetNewPar("ES_UCONCIF","DDOMINGOS,RBEAZIN,JMAMEDE,JNOGUEIRA") ) // Chamado do Bot„o do Faturamento
		//-------------------------------------------------------
		// Nesta situaÁ„o o frete precisa ser recalculado para a
		// sem fazer interaÁ„o com o usuario.
		//-------------------------------------------------------
		
//		If Empty(M->C5_PEDECOM) .and. !("LOJA90"$FunName()) 
			If Type("l410Auto") == "U" .Or. !l410Auto
				U_SetC5Var("M->C5_FRETE",If(lInc,WORK_FRT->Z3_VALOR,0))
				U_SetC5Var("M->C5_NOMETRA",WORK_FRT->A4_NOME)
				U_SetC5Var("M->C5_DESTFRE",WORK_FRT->Z3_EST+'-'+WORK_FRT->Z3_CAP_MUN)
			EndIf
			
			M->C5_FRETE:=If(lInc,WORK_FRT->Z3_VALOR,If(!Empty(M->C5_PEDECOM),M->C5_FRETE:=M->C5_FRETE,0))
			M->C5_NOMETRA:=WORK_FRT->A4_NOME
			M->C5_DESTFRE:=WORK_FRT->Z3_EST+'-'+WORK_FRT->Z3_CAP_MUN
			Exit
//		End If

	ElseIf Type("l410Auto") == "L".and. l410Auto
		//-------------------------------------------------------
		// Nesta situaÁ„o o usuario informou a Transportadora na
		// digitaÁ„o do pedido. Fazer o calculo apenas para esta.
		//-------------------------------------------------------
		If cFuncao=='TMK' // Call Center
			M->UA_FRETE:=If(lInc,nValorFrete,0)
			M->UA_NOMETRA:=TRB->A4_NOME
			M->UA_DESTFRE:=TRB->Z3_EST+'-'+TRB->Z3_CAP_MUN
		Else // Faturamento
			M->C5_FRETE:=If(lInc,WORK_FRT->Z3_VALOR,0)
			M->C5_NOMETRA:=WORK_FRT->A4_NOME
			M->C5_DESTFRE:=WORK_FRT->Z3_EST+'-'+WORK_FRT->Z3_CAP_MUN
		EndIf
		Exit
	EndIf
	
	lTela := .T.
	
	TRB->(dbSkip())
EndDo
TRB->(dbCloseArea())

//------------------------------------------
// Mostra as opÁıes de frete disponifiveis
// para que o usuario posso acordar com o
// cliente a melhor opÁ„o a ser usada.
//------------------------------------------

Do While lTela .And. !WORK_FRT->(Bof().and.Eof())
	WORK_FRT->(DbGoTop())
	
	Define msDialog oDlg Title "OpÁıes de Frete para o Cliente" From 00,00 TO 15,95
	
	oMark:=MsSelect():New("WORK_FRT",,,aCposSF,lInverte,@cMarca,{01,01,99,377})
	// oMark:bAval:={|| nOpcao := 1, oDlg:End()}
	oMark:baval:={|| If(Mta410Transp(WORK_FRT->Z3_TRANSP,_nPesoBr),(nOpcao := 1, oDlg:End()),(nOpcao := 0,lPodeSair:= .t.))}
	
	@ 104,001 checkbox oInc var lInc PROMPT "Frete Incluso" size 60,008 of oDlg on change Mta410SeleFrete(oInc,oCif,1)
	@ 104,050 checkbox oCif var lCif PROMPT "Frete CIF"     size 60,008 of oDlg on change Mta410SeleFrete(oInc,oCif,2)
	@ 104,150 Say "Peso bruto: " + Transform(_nPesoBr,"@KE 999,999.9999") size 60,008 of oDlg pixel
	
	Define Sbutton From 101,350 Type 1  Action (Eval(oMark:baval)) Enable Of oDlg Pixel
	
	Activate Dialog oDlg Centered
	//giovani carregar valor para variavel static ,posteriormente calcular porcentagem do frete em relaÁ„o ao valor do pedido....21/06/11
	cValFret := cvaltochar(WORK_FRT->Z3_VALOR )
	
	Do Case
		Case nOpcao==0  // Bot„o Cancela
			If !lCif .OR. ;
				(cFuncao=='TMK' .AND. !Empty(M->UA_TRANSP)) .OR.;
				(cFuncao<>'TMK' .AND. !Empty(M->C5_TRANSP))
				
				MsgInfo('… obrigatario escolher uma transportadora','AtenÁ„o')
				loop
			Else
				Exit
			Endif
		Case nOpcao==1 // Bot„o OK
			If cFuncao=='TMK' // Quando for Call Center  (MTA410)
				M->UA_FRETE:=If(lInc,WORK_FRT->Z3_VALOR,0)
				M->UA_TRANSP:=WORK_FRT->Z3_TRANSP
				M->UA_NOMETRA:=WORK_FRT->A4_NOME
				M->UA_DESTFRE:=WORK_FRT->Z3_EST+'-'+WORK_FRT->Z3_CAP_MUN
				cTransp:=M->UA_TRANSP
				M->UA_TPFRETE := If(lCif, 'C','I')
				
			Else
				U_SetC5Var("M->C5_FRETE",If(lInc,WORK_FRT->Z3_VALOR,0))
				U_SetC5Var("M->C5_TRANSP",WORK_FRT->Z3_TRANSP)
				U_SetC5Var("M->C5_NOMETRA",WORK_FRT->A4_NOME)
				U_SetC5Var("M->C5_DESTFRE",WORK_FRT->Z3_EST+'-'+WORK_FRT->Z3_CAP_MUN)
				U_SetC5Var("M->C5_TPFRETE",If(lCif, 'C','I'))
				
				M->C5_FRETE:=If(lInc,WORK_FRT->Z3_VALOR,0)
				M->C5_TRANSP:=WORK_FRT->Z3_TRANSP
				M->C5_NOMETRA:=WORK_FRT->A4_NOME
				M->C5_DESTFRE:=WORK_FRT->Z3_EST+'-'+WORK_FRT->Z3_CAP_MUN
				cTransp:=M->C5_TRANSP
				M->C5_TPFRETE := If(lCif, 'C','I')
			EndIf
			
			
			
			
			Exit
	EndCase
EndDo
WORK_FRT->(E_EraseArq(cFileWork))
Return(lRetorno)
*----------------------------------------------------------------
Static function Mta410SeleFrete(oInc,oCif,nBt)
*----------------------------------------------------------------
If nBt = 1
	If lInc
		lCif:=.f.
	ElseIf lCif
		lInc:= .f.
	EndIf
Else
	If lCif
		lInc:=.f.
	ElseIf lCif
		lCif:= .f.
	EndIf
EndIf
oInc:Refresh()
oCif:Refresh()
RETURN(.T.)
*----------------------------------------------------------------
User Function Mt410Frete(cCampo,cUF,cMun,lLoja)
*----------------------------------------------------------------
* U_Mt410Frete('GATILHO')
* U_Mt410Frete('UA_DESTFRE')
*----------------------------------------------------------------
Local Mta410cAlias:= GetArea()
Local aCapitais	:={}
Local cDestFrete:=Space(Len(SA1->A1_EST+'-'+SA1->A1_MUN))
local cFrete	:= ""
Local cQuery	:= ""
DEFAULT cUF     := ""
DEFAULT cMun    := ""
DEFAULT lLoja   := .F.

/*
If (ISINCALLSTACK("LOJA901A") .Or. ISINCALLSTACK("LOJA901")) .And. !lLoja
	RestArea(Mta410cAlias)
	Return ("RJ-DEMAIS CIDADES")
EndIf
*/

If Select("TRB") > 0
	TRB->( DbCloseArea() )
EndIf

// Quando o pedido precisa ser alterado pelo faturamento (Saldo por exemplo)o cliente vem desposicionado  MCVN - 08/07/2007

If !("TMK"$FunName())  .And. !("DIPAL10"$FunName())
	SA1->(dbSetOrder(1))
	If lLoja
		SA1->(dbSeek(xfilial("SA1")+PARAMIXB[3,2,2]+PARAMIXB[3,3,2]))
	Else
		If M->C5_TIPO $"B|D|"
			SA2->(dbSeek(xfilial("SA2")+M->C5_CLIENTE+M->C5_LOJACLI))
		Else
			SA1->(dbSeek(xfilial("SA1")+M->C5_CLIENTE+M->C5_LOJACLI))
		EndIf
	Endif
Endif

If Empty(cUF)

	If !("DIPAL10"$FunName()) .And. !(ISINCALLSTACK("LOJA901A")) .And. !(ISINCALLSTACK("LOJA901"))
		If M->C5_TIPO $"D|B|" 
			cUF := SA2->A2_EST
		Else
			cUF := If(!Empty(SA1->A1_ESTE),SA1->A1_ESTE,SA1->A1_EST)
		EndIf
	Else
			cUF := If(!Empty(SA1->A1_ESTE),SA1->A1_ESTE,SA1->A1_EST)	
	EndIf	
	
EndIf

If Empty(cMun)

	If !("DIPAL10"$FunName()) .And. !(ISINCALLSTACK("LOJA901A")) .And. !(ISINCALLSTACK("LOJA901"))
		If M->C5_TIPO $"D|B|"
			cMun:=SA2->A2_MUN
		Else
			cMun:=If(!Empty(SA1->A1_MUNE),SA1->A1_MUNE,SA1->A1_MUN)
		EndIf
	Else
			cMun:=If(!Empty(SA1->A1_MUNE),SA1->A1_MUNE,SA1->A1_MUN)		
	EndIf
		
EndIf

cQuery := " SELECT DISTINCT Z3_CAP_MUN, Z3_EST"
cQuery += " FROM " + RetSqlName('SZ3') + " SZ3"
cQuery += " WHERE Z3_FILIAL      = '" + xFilial('SZ3') + "'"
cQuery += "   AND Z3_EST         = '" + AllTrim(cUF)   + "'"
cQuery += "   AND Z3_DATAFIN     = ' ' "
cQuery += "   AND SZ3.D_E_L_E_T_ = ' ' "
cQuery += " ORDER BY Z3_CAP_MUN"

cQuery := ChangeQuery(cQuery)
DbCommitAll()
dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'TRB', .F., .T.)

DbSelectArea("TRB")

TRB->(dbGotop())

cFrete := cUf+'-DEMAIS CIDADES'

Do While TRB->(!EOF())
	If Upper(AllTrim(TRB->Z3_CAP_MUN)) == Upper(AllTrim(cMun))
		cFrete := cUf+'-'+TRB->Z3_CAP_MUN
	EndIf
	TRB->(dbSkip())
EndDo

If cCampo == 'GATILHO'
	cDestFrete := cFrete
ElseIf cCampo == 'UA_DESTFRE'
	If Empty(M->UA_DESTFRE)
		cDestFrete := cFrete
	EndIf
EndIf

TRB->(dbCloseArea())
RestArea(Mta410cAlias)

Return(cDestFrete)
*-----------------------------------------------------*
StaTic Function Mta410Transp(cTransportadora,_nPesoBr)
*-----------------------------------------------------*
Local lRetorno := .t.         

	If cTransportadora == '000235'.and._nPesoBr > 30
		MsgInfo('Por Sedex: Peso maximo por NF È de 30 Kg e um volume, com restriÁ„o de liquidos','AtenÁ„o')
		lRetorno := .F.
	EndIf                   
                        
	If cTransportadora == '000236'.and._nPesoBr > 15
		MsgInfo('Por Sedex 10: Peso maximo por NF È de 10 Kg e um volume, com restriÁ„o de liquidos','AtenÁ„o')
		lRetorno := .F.
	EndIf                   

Return(lRetorno)

*-----------------------------------------------------*
StaTic Function Mta410VerTransp(cTransp)
*-----------------------------------------------------*
Local lRetorno := .t.
If Empty(cTransp)
	MsgInfo('… obrigatario escolher uma transportadora','AtenÁ„o')
	lRetorno := .f.
EndIf
Return(lRetorno)

*-----------------------------------------------------*
User Function ExcFiscal(cEstado,cGrptrib)
*-----------------------------------------------------*
Local lRetorno := .f.

QRY1 := " SELECT F7_GRTRIB,F7_EST, F7_GRPCLI, F7_ALIQINT, F7_ALIQEXT"
QRY1 += " FROM " + RetSQLName("SF7")
QRY1 += " WHERE F7_EST = '"  + cEstado  + "'"
QRY1 += " AND F7_GRPCLI = '" + cGrptrib + "'"
QRY1 += " AND F7_FILIAL = '" + xFilial('SF7') +"'"
QRY1 += " AND F7_ALIQINT <> F7_ALIQEXT "
QRY1 += " AND " + RetSQLName("SF7") + ".D_E_L_E_T_ = ' ' "
QRY1 += " ORDER BY F7_GRTRIB"

#xcommand TCQUERY <sql_expr>                          ;
[ALIAS <a>]                                           ;
[<new: NEW>]                                          ;
[SERVER <(server)>]                                   ;
[ENVIRONMENT <(environment)>]                         ;
=> dbUseArea(                                         ;
<.new.>,                                              ;
"TOPCONN",                                            ;
TCGENQRY(<(server)>,<(environment)>,<sql_expr>),      ;
<(a)>, .F., .T.)
// Processa Query SQL
DbCommitAll()
TcQuery QRY1 NEW ALIAS "QRY1"         // Abre uma workarea com o resultado da query

DbSelectArea("QRY1")
QRY1->(dbGotop())

Do While QRY1->(!Eof())
	lRetorno := .t.
	QRY1->(DbSkip())
Enddo

DbSelectArea("QRY1")
QRY1->(dbcloseArea())
Return(lRetorno)

/////////////////////////////////////////////////////////////////////////////////////////////
//Grava na empresa Health
//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//| Abertura do ambiente    - Candisani   24/07/2009                                  |
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ

User Function GrvHea(cEmpa,cFila,aCabec,aItens,nCampo,ePedido)
Local x := 0
Local y := 0
//PREPARE ENVIRONMENT EMPRESA "99" FILIAL "01" MODULO "FAT" TABLES "SC5","SC6","SA1","SA2","SB1","SB2","SF4"
//Mudanca de funcao conforme chamado SAUUMG - 14/01/09 - candisani
//N„o podemos abrir um novo ambiente com a funÁ„o RPCSETENV() pois quando fechamos o ambiente anterior
//perdemos todo o ambiente do remote, e quando voltamos para a outra empresa ocorrem v·rios erros.
//Mudada a funcao para StartJob
//Alert("Antes de abrir ambiente Health")
//RpcClearEnv()

//RPCSetType( 3 )	// N„o consome licensa de uso
//RpcSetEnv("04","01",,,,"TESTES",{"SC5","SC6","SA1","SA2","SB1","SB2","SF3","SF4"})
//Mudanca novamente da rotina pois nao esta gravando atraves do execauto - candisani 16/01/09
Private nOpc        :=  3 // inclusao
Private lMsHelpAuto := .T. // se .t. direciona as mensagens de help para o arq. de log
Private lMsErroAuto := .F. //necessario a criacao, pois sera atualizado quando houver alguma incosistencia nos parametros
Private j := 2
qout("Abrindo empresa Empresa " + cEmpa + " Filial " + cFila )
PREPARE ENVIRONMENT EMPRESA cEmpa Filial cFila modulo 'FAT'
DBSELECTARea("SC5")
DBSELECTAREA("SC6")

//Validar dados antes de gravar - Candisani - 12/02/09
//So poderemos fazer as validacoes aqui no StartJob pois antes nao temos este ambiente aberto - Candisani - 15/02/09
//Validar codigo do produto
//O problema e que neste ponto ja alteramos os dados na Dipromed
//Neste ponto nao convem voltar todo o processo pois estamos posicionados em outro ambiente
//O ideal sera mandar um email ou gravar no console uma mensagem e deixar o processo seguir em frente
//Pecisaremos criar validacoes antes mesmo de gravar a linha do pedido.
//Validar TES
//Verificar Saldo

DbSelectArea("SC5")
DbSetOrder(1)
cNumSC5 := GetSxeNum("SC5","C5_NUM")
ConfirmSX8()
Reclock("SC5",.T.)
If !ePedido
	For x:= 1 to len(aCabec)
		If (aCabec[x][1]) == "C5_NUM"
			Replace &(aCabec[x][1]) with cNumSC5
		Else
			Replace &(aCabec[x][1]) with (aCabec[x][2])
		Endif
	Next
	MsUnlock()
	//Grava os itens na empresa Health
	
	For x:= 1 to len(aItens)
		Reclock("SC6",.T.)
		For y:= 1 to  SC6->(fCount())
			If (aItens[x][y][1])=="C6_NUM"
				Replace &(aItens[x][y][1]) with cNumSC5
			Else
				Replace &(aItens[x][y][1]) with (aItens[x][y][2])
			Endif
		Next y
		MsUnlock()
	Next
	DbCommitAll()
Elseif ePedido //Inclusao direta de pedido compartilhado
	//MSExecAuto({|x,y,z| mata410(x,y,z)},aCabec,aItens,nOpc) //inclusao
	//If lMsErroAuto
	/*
	Se estiver em uma aplicao normal e ocorrer alguma incosistencia nos parametros passados,mostrar na tela o log informando qual coluna teve a incosistencia
	*/
	//	Mostraerro()
	//EndIf
	
	qout("Inclusao de Pedido Compartilhado")
	For x:= 1 to len(aCabec)
		If (aCabec[x][1]) == "C5_NUM"
			Replace &(aCabec[x][1]) with cNumSC5
		Else
			Replace &(aCabec[x][1]) with (aCabec[x][2])
		Endif
	Next
	MsUnlock()
	qout("Inclusao de Pedido "+cNumSC5)
	//Grava os itens na empresa Health
	
	For x:= 1 to len(aItens)
		Reclock("SC6",.T.)
		For y:= 1 to  nCampo
			If (aItens[x][y][1])=="C6_NUM"
				Replace &(aItens[x][y][1]) with cNumSC5
			Else
				Replace &(aItens[x][y][1]) with (aItens[x][y][2])
			Endif
		Next y
		MsUnlock()
	Next
	DbCommitAll()
Endif

RESET environment
qout("Fechando Empresa " + cEmpa + " Filial " + cFila )

Return(.t.)

/*‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥SC5Fil∫ Autor ≥ Maximo Canuto V. Neto ∫ Data ≥     26/07/09 ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Descricao ≥ Filtro pedido/orÁamento no browse do pedido de venda       ∫±±
±±∫          ≥                                                            ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ EspecÌfico Dipromed                                        ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ*/

User Function SC5Fil()
Local cCondicao  := 'C5_FILIAL == xFilial("SC5")'
Local cTempCond  := ""
Local cCodUsr    := alltrim(RetCodUsr())
Local cUser      := GetMv("ES_VENDUSE",,"000053" )
Local oDlg
Private _dDtIni  := dDataBase-30
Private _dDtFin  := dDataBase
Private _cCliente:= Space(6)
Private _loK     := .F.


U_SC5ClearFil()

If Type("lDiprFilF7") == "U" 
	Public lDiprFilF7 := .F.
EndIf

If Type("cDipVend") == "U" 
	Public cDipVend := alltrim(Posicione("SU7",4,xFilial("SU7") + RetCodUsr(),"U7_CGC"))
EndIf
	
If Type('aHeader') = 'U'

	@ 200,150 To 420,520 Dialog oDlg Title OemToAnsi("FILTRO DE PEDIDO - Informe os Parametros")
	
	@ 010,020 Say OemToAnsi("Cliente:")  Size 040,020
	@ 010,060 Get _cCliente F3 "SA1"     Size 040,020
	
	@ 025,020 Say OemToAnsi("Data De:")  Size 040,020
	@ 025,060 Get _dDtIni Size 040,020   Picture "@D"
	
	@ 040,020 Say OemToAnsi("Data AtÈ:") Size 040,020
	@ 040,060 Get _dDtFin Size 040,020   Picture "@D"  Valid !Empty(_dDtFin)
		
	@ 080,120 BmpButton Type 1 Action (_loK:= .T.,Close(oDlg))
	@ 080,150 BmpButton Type 2 Action Close(oDlg)
	
	Activate Dialog oDlg Centered	

	If _loK
		cTempCond := ""
		If cDipVend $ cUser
			cTempCond := cCondicao+' .AND. C5_VEND1 == "'+cDipVend+'" .AND. C5_CLIENTE == "'+(_cCliente)+'" .AND. Dtos(C5_EMISSAO) >= "'+DTOS((_dDtIni))+'" .AND. Dtos(C5_EMISSAO) <= "'+DTOS((_dDtFin))+'"'
		Else
			cTempCond := cCondicao+' .AND. C5_CLIENTE == "'+(_cCliente)+'" .AND. Dtos(C5_EMISSAO) >= "'+DTOS((_dDtIni))+'" .AND. Dtos(C5_EMISSAO) <= "'+DTOS((_dDtFin))+'"' 
		EndIf
		oObjBrowDip:=FWmBrwActive()
		oObjBrowDip:SetFilterDefault(cTempCond)
		oObjBrowDip:ResetLen()
		oObjBrowDip:Refresh()
		lDiprFilF7 := .T.
	EndIf

EndIf 


Return()
/*‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥LimpaFiltro ∫ Autor ≥ Maximo Canuto V. Neto ∫Data ≥26/07/09 ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Descricao ≥ Limpa Filtro                                               ∫±±
±±∫          ≥                                                            ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ EspecÌfico Dipromed                                        ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ*/
User Function SC5ClearFil()
Local lRetorno := .f.
Local cCondicao := 'SC5->C5_FILIAL == xFilial("SC5")'
Local aIndSC5   := {}
Local bFiltraBrw := {|| Nil}
Local cCodUsr    := alltrim(RetCodUsr())
Local cUser      := GetMv("ES_VENDUSE",,"000053" )
Local oError
Local cText 
Local cTitle
Local oObjBrow

If Type("cDipVend") == "U" 
	Public cDipVend := alltrim(Posicione("SU7",4,xFilial("SU7") + RetCodUsr(),"U7_CGC"))
EndIf

If Type('aHeader') = 'U'
	If cDipVend $ cUser//Giovani Zago 27/03/2012
		SC5->(dbSetFilter({|| SC5->C5_VEND1 == cDipVend},"SC5->C5_VEND1 == cDipVend "))//Giovani Zago 27/03/2012
	Else
		SC5->(DbClearFilter())
		SC5->(DbGoTop())
	EndIf
	
	TRY EXCEPTION
		oObjBrow:=FWmBrwActive()
		If ValType(oObjBrow) =="O"
			If ValType(oObjBrow:CCLASSNAME) == "C"
				if oObjBrow:CCLASSNAME == "FWMBROWSE"
					oObjBrow:CleanExFilter()
					oObjBrow:GetFilterDefault()
					oObjBrow:ResetLen()
					oObjBrow:GoTop()
					oObjBrow:Refresh()
				Endif
			Endif
		Endif
	CATCH EXCEPTION USING oError 

		cTitle := "Limpeza de filtro"
		cText := "Ocorreu  uma problema ao executar essa tarefa. Por gentileza, tente executar a aÁ„o novamente. Se o erro persistir, feche a tela de pedidos e abra novamente."
		MsgInfo(cText, cTitle) 
		conout( '(TRY... CATCH -> MTA410.PRW - SC5ClearFil - Processando Empresa/ filial: '+cempant+'/'+cfilant + ' - ' + oError:Description )

	END TRY
EndIf              

If Type("lDiprFilF7") <> "U" 
	lDiprFilF7 := .F.
EndIf

Return()
/*‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥ConfEndEnt ∫ Autor ≥ Maximo Canuto V. Neto ∫Data ≥26/07/09  ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Descricao ≥ Confirma endereÁo de entrada                               ∫±±
±±∫          ≥                                                            ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ EspecÌfico Dipromed                                        ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ*/

User Function ConfEndEnt()

Local lALTEND   := .F.
Local lConfirma := .F.
Local cEndEnt   := If(Empty(M->C5_ENDENT), Space(100),M->C5_ENDENT)
Local cBairroEnt:= If(Empty(M->C5_BAIRROE),Space(035),M->C5_BAIRROE)
Local cMunEnt   := If(Empty(M->C5_MUNE),   Space(035),M->C5_MUNE)
Local cEstEnt   := If(Empty(M->C5_ESTE),   Space(002),M->C5_ESTE)
Local cCepEnt   := If(Empty(M->C5_CEPE),   Space(010),M->C5_CEPE)
Local cObsEnt   := If(Empty(M->C5_HRRECEB),Space(120),M->C5_HRRECEB)

While !lConfirma
	
	@ 126,000 To 450,600 DIALOG oDlg TITLE OemToAnsi("ENDERE«O DE ENTREGA" )
	@ 015,010 Say "EndereÁo: "
	@ 015,060 Get cEndEnt Size     230,20 when lALTEND
	@ 035,010 Say "Bairro: "
	@ 035,060 Get cBairroEnt Size   80,20 when lALTEND
	@ 055,010 Say "MunicÌpio "
	@ 055,060 Get cMunEnt Size      80,20 when lALTEND
	@ 075,010 Say "Estado: "
	@ 075,060 Get cEstEnt Size      15,20 when lALTEND
	@ 095,010 Say "CEP: "
	@ 095,060 Get  cCepEnt Size     30,20 when lALTEND Picture "@R 99999-999"
	@ 115,010 Say "Obs Entrega: "
	@ 115,060 Get  cObsEnt Size    230,20 when lALTEND
	@ 135,100 BUTTON OemToAnsi("CONFIRMA") SIZE 44,15 ACTION (lConfirma := .T.,Close(odlg))
	@ 135,010 BUTTON OemToAnsi("Altera")   SIZE 44,15 ACTION (lALTEND := .T.)
	
	ACTIVATE DIALOG oDlg Centered
	
End

M->C5_ENDENT := Upper(cEndEnt)
M->C5_BAIRROE:= Upper(cBairroEnt)
M->C5_MUNE   := Upper(cMunEnt)
M->C5_ESTE   := Upper(cEstEnt)
M->C5_CEPE   := Upper(cCepEnt)
M->C5_HRRECEB:= Upper(cObsEnt)

Return

/*BEGINDOC
//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ`ø
//≥FunÁ„o para validar CEP do cliente na transportadora - Atualmente usado pela EMOVERE/JAMEF ≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ`Ÿ
ENDDOC
*/
Static Function FindCepSzv(nCepCli)
Local QRY2    := ""
Local cZ3Trp  := "''"
Local _xAlias := GetArea()
Local cAliasTrb := GetNextAlias()
Local aTransp := {}
Local nI

QRY2 := " SELECT A4_COD "
QRY2 += " FROM "+ RetSqlName("SA4") + " A4 "
QRY2 += " WHERE A4_FILIAL     = '"+xFilial("SA4")+"'"
QRY2 += "   AND A4_USARCEP    = '2'"
QRY2 += "   AND A4.D_E_L_E_T_ = ' '"
dbUseArea(.T.,"TOPCONN",TCGenQry(,,QRY2),cAliasTrb,.F.,.T.)

//-- Percorre a Query e adiciona o resultado no array de Retorno
(cAliasTrb)->( DbEval( {|| aAdd(aTransp,A4_COD)  }))
(cAliasTrb)->( DbCloseArea() )

aTransp := aSort(aTransp,,,{|x,y| x < y })	

For nI := 1 To Len( aTransp )
	QRY2 := "SELECT ZV_TRANSP, ZV_TIMEATE, ZV_VIAGEM "
	QRY2 += " FROM " + RetSQLName("SZV")
	QRY2 += " WHERE ZV_CEPINI <= '" + nCepCli + "'"
	QRY2 += "   AND ZV_CEPFIM >= '" + nCepCli + "'"
	QRY2 += "   AND ZV_FILIAL  = '" + xFilial("SZV") + "'"
	QRY2 += "   AND ZV_TRANSP  = '" + aTransp[nI] + "'"
	QRY2 += "   AND " + RetSQLName("SZV") + ".D_E_L_E_T_ = ' ' "
	
	#xcommand TCQUERY <sql_expr>                          ;
	[ALIAS <a>]                                           ;
	[<new: NEW>]                                          ;
	[SERVER <(server)>]                                   ;
	[ENVIRONMENT <(environment)>]                         ;
	=> dbUseArea(                                         ;
	<.new.>,                                              ;
	"TOPCONN",                                            ;
	TCGENQRY(<(server)>,<(environment)>,<sql_expr>),      ;
	<(a)>, .F., .T.)
	
	// Processa Query SQL
	DbCommitAll()
	TcQuery QRY2 NEW ALIAS "QRY2"         // Abre uma workarea com o resultado da query
	memowrite('szvmta410.SQL',QRY2)
	
	DbSelectArea("QRY2")
	QRY2->(dbGotop())
	Do While !EOF()
		// Verifica se a transportadora entrega na regi„o e na data de liberaÁ„o do pedido de venda
		If  'TODOS OS DIAS' $ Alltrim(QRY2->ZV_VIAGEM) .OR.;
			(IIf(Alltrim(UPPER(DIASEMANA(DDATABASE+1)))='SABADO',Alltrim(UPPER(DIASEMANA(DDATABASE+3))),Alltrim(UPPER(DIASEMANA(DDATABASE+1)))) $ Alltrim(QRY2->ZV_VIAGEM)) .OR. ;
			M->C5_TRANSP $ '100000/000905/002179/003025/123455' .OR. (M->C5_TPFRETE == 'C' .OR. QRY2->ZV_TIMEATE <> '')
				cZ3Trp += If(Len(Alltrim(cZ3Trp))<1,"'"+QRY2->ZV_TRANSP+"'",",'"+QRY2->ZV_TRANSP+"'")
				Aadd(aViagem,{QRY2->ZV_TRANSP, Alltrim(QRY2->ZV_TIMEATE+"   "+QRY2->ZV_VIAGEM)})
		Endif
		QRY2->(dbSkip())
	EndDo
	
	DbSelectArea("QRY2")
	QRY2->(DbCloseArea())
Next nI

RestArea(_xAlias)
Return(cZ3Trp)


/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥VldCpoA1  ∫Autor  ≥Microsiga           ∫ Data ≥  03/31/10   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥                                                            ∫±±
±±∫          ≥                                                            ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ AP                                                         ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
User Function VldCpoA1()
Local _cCposVld := AllTrim(SuperGetMV("ES_A1EMPTY",,"A1_TEL,A1_COD_MUN,A1_PESSOA,A1_CEP,A1_BAIRRO,A1_MUN,A1_EST,A1_EMAIL,A1_CNAE"))
Local _aArea	:= GetArea()
Local _aAreaSA1	:= SA1->(GetArea())
Local _nPosCPO	:= 0
Local _nAux		:= 0
Local _cCampo	:= ""
Local _lRet		:= .T.
Local _cCpoErr	:= ""

SA1->(DbSetOrder(1))
If _lRet := SA1->( DbSeek( xFilial("SA1")+M->C5_CLIENTE+If(!Empty(M->C5_LOJACLI),M->C5_LOJACLI,'01')))
	
	//-- Verifica os campos
	_nAux :=  1
	Do While _nPosCpo < Len(_cCposVld)
		_nAux		+= _nPosCPO
		_nPosCPO 	:= If(At(",",Substr(_cCposVld,_nAux))>0,At(",",Substr(_cCposVld,_nAux)),Len(_cCposVld)+1)
		_cCampo		:= Substr(_cCposVld,_nAux,_nPosCPO-1)
		_lRet		:= !Empty(SA1->&(_cCampo))
		
		If _lRet .And. _cCampo == "A1_EMAIL"
			_lRet := "@" $ SA1->&(_cCampo)
		EndIf
		
		If !_lRet
			_cCpoErr += AllTrim(Posicione('SX3', 2, _cCampo, 'X3Titulo()')) + ","
		EndIf
	EndDo
	
	_lRet		:= Empty(_cCpoErr)
	_cCpoErr 	:= If(!Empty(_cCpoErr),Left(_cCpoErr,Len(_cCpoErr)-1),"")
	
	If !_lRet
		MsgAlert("Verifique o Cadastro do Cliente! Campos: "+_cCpoErr,"MTA410")
	EndIf
Else
	MsgAlert("Cliente n„o Encontrado! ","MTA410")
EndIf


RestArea(_aAreaSA1)
RestArea(_aArea)

Return _lRet
/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥MTA410    ∫Autor  ≥Microsiga           ∫ Data ≥  12/16/13   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥ 											                 ∫±±
±±∫          ≥                                                            ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ AP                                         	              ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
User Function VldDestFre()
Local cDestFre := ""
Local cCEP 	   := ""

SA1->(dbSetOrder(1))
If SA1->(dbSeek(xfilial("SA1")+M->C5_CLIENTE+M->C5_LOJACLI))
	cCEP:= AllTrim(If(!Empty(SA1->A1_CEPE),SA1->A1_CEPE,SA1->A1_CEP))
	
	If M->C5_CEPE <> cCEP
		cDestFre := u_Mt410Frete('GATILHO',M->C5_ESTE,M->C5_MUNE)
		If UPPER(AllTrim(cDestFre)) <> UPPER(AllTrim(M->C5_DESTFRE)) .And. !Empty(cDestFre)
			M->C5_DESTFRE := cDestFre      
			Aviso("AtenÁ„o","O destino de frete foi alterado."+CHR(10)+CHR(13)+"O frete ser· recalculado.",{"Ok"})
			U_CalcuFrete('MTA410')
		EndIf
	EndIf	
EndIf
	
Return  
/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥MTA410    ∫Autor  ≥Microsiga           ∫ Data ≥  01/13/14   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥                                                            ∫±±
±±∫          ≥                                                            ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ AP                                                        ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Static Function VldQtdEmp(cPedido,cProduto)
Local cSQL 		 := ""
Local lRet 		 := .F.  
DEFAULT cPedido  := ""
DEFAULT cProduto := ""

cSQL := " SELECT "
cSQL += "	SUM(C6_QTDVEN) QTDVEN, SUM(C6_QTDENT) QTDENT "
cSQL += "	FROM "
cSQL += 		RetSQLName("SC6")
cSQL += "		WHERE "
cSQL += "			C6_FILIAL = '"+xFilial("SC6")+"' AND "
cSQL += "			C6_NUM = '"+cPedido+"' AND "
cSQL += "			C6_PRODUTO = '"+cProduto+"' AND "
cSQL += "			D_E_L_E_T_ = ' ' "

cSQL := ChangeQuery(cSQL)
dbUseArea(.T., "TOPCONN", TCGenQry(,,cSQL), 'TRBSC6', .F., .T.)

If !TRBSC6->(Eof())
	If TRBSC6->QTDVEN <> TRBSC6->QTDENT .Or. TRBSC6->QTDENT == 0
		lRet := .T.
	EndIf
EndIf    
TRBSC6->(dbCloseArea())

Return lRet
/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥MTA410    ∫Autor  ≥Microsiga           ∫ Data ≥  10/31/14   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥                                                            ∫±±
±±∫          ≥                                                            ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ AP                                                        ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Static Function DipInter(cEst,cMun,cTransp)
Local cRet 	:= ""
Local cSQL 	:= ""
Local aArea := GetArea()

cSQL := " SELECT "
cSQL += " 	CC2_EST, CC2_CODMUN, CC2_MUN, CC2_XINTER, CC2_XINTBP, CC2_XINTNT "
cSQL += " 	FROM "
cSQL += 		RetSQLName("CC2")
cSQL += " 		WHERE "
cSQL += " 			CC2_FILIAL = '"+xFilial("CC2")+"' AND "
cSQL += " 			CC2_EST    = '"+cEst+"' AND "
cSQL += " 			CC2_MUN    = '"+cMun+"' AND " 
cSQL += " 			D_E_L_E_T_ = ' ' "

cSQL := ChangeQuery(cSQL)
dbUseArea(.T.,"TOPCONN",TCGenQry(,,cSQL),"QRYCC2",.F.,.T.)

If !QRYCC2->(Eof())   
	If cTransp=="000905" //JAMEF
		cRet := QRYCC2->CC2_XINTER
	ElseIf cTransp=="000150"
		cRet := QRYCC2->CC2_XINTBP
	ElseIf cTransp=="955917"
		cRet := QRYCC2->CC2_XINTNT
	EndIf
EndIf
QRYCC2->(dbCloseArea())

RestArea(aArea)           

Return cRet
/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥MTA410    ∫Autor  ≥Microsiga           ∫ Data ≥  04/23/15   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥                                                            ∫±±
±±∫          ≥                                                            ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ AP                                                        ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
User Function DipCalcCIF()
Local nI := 0
Local nDesCond   := 0
Local nPorcAume	:= 0
Local nFatorRec  	:= 0
Local lRecalc 		:= .F.
Local lAviso		:= .T.
Private _nPosPrcven  := aScan(aHeader, { |x| Alltrim(x[2]) == "C6_PRCVEN"})
Private _nPosQtdVen	 := aScan(aHeader, { |x| Alltrim(x[2]) == "C6_QTDVEN"})
Private _nPosPrUnit	 := aScan(aHeader, { |x| Alltrim(x[2]) == "C6_PRUNIT"})
Private _nPosprod    := aScan(aHeader, { |x| Alltrim(x[2]) == "C6_PRODUTO"})
Private _nPosLot    := aScan(aHeader, { |x| Alltrim(x[2]) == "C6_LOTECTL"})
Private _nPosValor   := aScan(aHeader, { |x| Alltrim(x[2]) == "C6_VALOR"  })
Private _nPosMini    := aScan(aHeader, { |x| Alltrim(x[2]) == "C6_PRVMINI"})
Private _nPosSupe    := aScan(aHeader, { |x| Alltrim(x[2]) == "C6_PRVSUPE"})
Private _nPosCSis    := aScan(aHeader, { |x| Alltrim(x[2]) == "C6_XCALCSI"})
Private _nPosQtdVen	 := aScan(aHeader, { |x| Alltrim(x[2]) == "C6_QTDVEN"})
Private _nPosUPrc 	 := aScan(aHeader, { |x| Alltrim(x[2]) == "C6_USERPRC"})

If Len(aCols) > 0 .And. aCols[1,_nPosPrcven] > 0 .And. u_VldCifRev(M->C5_NUM,"M",.T.)
	SE4->(DbSetOrder(1))
	If !Empty(M->C5_CONDPAG) .And. SE4->(MsSeek(xFilial("SE4")+M->C5_CONDPAG))
		If SE4->E4_USERDES > 0
			nFatorRec := 1 - (SE4->E4_USERDES/100)
		Else 
			nFatorRec := 1 + (SE4->E4_XUSRACR/100)
		EndIf
	Else
		nFatorRec := 1
	EndIf
	
	If substr(M->C5_XRECOLH,1,3) $ "ACR"
		nPorcAume:= 1.16
	ElseIf substr(M->C5_XRECOLH,1,3) $ "ISE"
		nPorcAume:= 1.06
	EndIf        

	For nI:= 1 to Len(aCols)

		SB1->(dbSetOrder(1))
		If Empty(aCols[nI,_nPosLot]) .And. SB1->(dbSeek(xFilial("SB1")+aCols[nI,_nPosprod]))
			
			nDesCond := Posicione("SE4",1,xFilial("SE4")+M->C5_CONDPAG,"E4_USERDES")
			nAcrCond := Posicione("SE4",1,xFilial("SE4")+M->C5_CONDPAG,"E4_XUSRACR")
			
			If substr(M->C5_XRECOLH,1,3) $ "ACR/ISE"
				If  aCols[nI,_nPosSupe] > 0
					nVlrAux := Round(NoRound(aCols[nI,_nPosSupe]*nPorcAume,4)*nFatorRec,4)
				Else
					nVlrAux := Round(NoRound(aCols[nI,_nPosMini]*nPorcAume,4)*nFatorRec,4)
				EndIf
			Else
				nVlrAux := if(SB1->B1_PRVSUPE>0,SB1->B1_PRVSUPE,SB1->B1_PRVMINI)
			EndIf
			
			nVlrAux := u_DipAcrCli(nVlrAux,M->C5_CLIENTE,M->C5_LOJACLI,SB1->B1_COD)          
			
			If nDesCond > 0
				nVlrAux := nVlrAux-(nVlrAux*nDesCond/100)
			ElseIf nAcrCond > 0 
				nVlrAux := nVlrAux-(nVlrAux*nAcrCond/100)
			EndIf
			
			If M->C5_TPFRETE == "C"
				ZZB->(dbSetOrder(1))
				If ZZB->(dbSeek(xFilial("ZZB")+M->C5_ESTE))
					nVlrAux := nVlrAux + Round(nVlrAux*(ZZB->ZZB_PERC/100),4)
				EndIf
			EndIf
			
			If nVlrAux <> aCols[nI,_nPosPrcven] .And. lAviso			
				If (lAviso := Aviso("AtenÁ„o","InformaÁıes de frete alteradas. Confirma o rec·lculo dos itens do pedido?",{"Sim","N„o"},1)==1)
					lRecalc := .T.
					
					aCols[nI,_nPosPrcven]	:= nVlrAux
					
					aCols[nI,_nPosPrUnit] 	:= aCols[nI,_nPosPrcven]
					MaFisAlt("IT_PRCUNI"	,aCols[nI,_nPosPrcven],n)
					aCols[nI,_nPosUPrc]		:= aCols[nI,_nPosPrcven]
					aCols[nI,_nPosValor] 	:= Round(aCols[nI,_nPosPrcven]*aCols[nI,_nPosQtdVen],2)
					MaFisAlt("IT_VALMERC"	,aCols[nI,_nPosValor],n)
					
					aCols[nI,_nPosPrcven]	:= nVlrAux
					aCols[nI,_nPosPrUnit] 	:= aCols[nI,_nPosPrcven]
					aCols[nI,_nPosValor] 	:= Round(aCols[nI,_nPosPrcven]*aCols[nI,_nPosQtdVen],2)
					
					aCols[nI,_nPosCSis] 	:= aCols[nI,_nPosPrcven]
				EndIf				
			EndIf
		EndIf
	Next nI
	If lRecalc .And. FunName()<>"SPEDNFE"
		Aviso("AtenÁ„o","O valor do pedido foi recalculado de acordo com a opÁ„o do FRETE. Confira os valores.",{"Ok"},1)
		
		Ma410Rodap(,,0)
		
		If Type("oGetDad")=="O" .And. (Type("l410Auto") == "U" .Or. !l410Auto)
			oGetDad:oBrowse:Refresh()
		EndIf
	EndIf
EndIf


Return
/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥MTA410    ∫Autor  ≥Microsiga           ∫ Data ≥  01/28/16   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥                                                            ∫±±
±±∫          ≥                                                            ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ AP                                                        ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
User Function DipRegCom()
Local nI   := 0
Local nAux := 0

For nI:=1 to Len(aCols)
	
	// Recalcula comiss„o para pedidos de LicitaÁ„o
	nAux := n
	If !Empty(M->C5_EDITAL) // MCVN - 14/08/09	
		n := nI
		M->C6_PRCVEN := aCols[nI,_nPosPrcVen]
		U_DIPG006("MTA410")		
		U_CLI_PRO_3("") //MCVN - 21/02/11

		// Executando os outros gatilhos  MCVN - 16/08/09                                                                                                               |
		// If M->C5_CLIENTE $ "004303/010231/000874/000871/000233"  .or. M->C5_VEND1 $ "006761"     O Cliente 000874 saiu da regra por solicitaÁ„o do Erich em 18-07-11 |
		// If M->C5_CLIENTE $ "004303/010231/000871/000233"  .or. M->C5_VEND1 $ "006761"     O Cliente 000871 saiu da regra por solicitaÁ„o do Erich em 21-07-11        |

		If M->C5_CLIENTE $     "004303/010231"  .or. M->C5_VEND1 $ "006761"
			aCols[nI,_nPosComis1] := 3
		ElseIf M->C5_CLIENTE $ "000233" // 2% comiss„o para Realm Campinas a partir de 01/08/2018
			aCols[nI,_nPosComis1] := 2
		ElseIf M->C5_VEND1 $   "006837" // FLAVIO HESSE
			aCols[nI,_nPosComis1] := 1
		Endif
	Endif
	n := nAux
	//Giovani.Zago 24/10/2011  Alterar comissao caso produto seja 011268 e grupo de venda seja 000099 (SECRETARIA)
	//If SA1->A1_GRPVEN $ "000099"
	//	If aCols[nI,_nPosprod]  = "011268" .And. Date()<= ctod("01/08/2012") .Or. aCols[nI,_nPosprod]  = "060109" .And. Date()<= ctod("26/09/2012")
	//		aCols[nI,_nPosComis1] := 3
	//	Endif
	//Endif
	
	//Giovani.Zago 24/10/2011  Alterar comissao caso vendedor seja 006909 -- Gustavo
	//If  M->C5_VEND1 $ "006909" .And. DtoS(Date()) <= '20151031'
	//	aCols[nI,_nPosComis1] := 0.5
	//Endif
	
	//Giovani.Zago 24/10/2011  Alterar comissao caso vendedor seja 000209 e fornecedor seja 000996 (Steri Pack) e cliente 000271 (Samaritano) --  Barcelos
	If M->C5_VEND1 $ "000209"  .And. M->C5_CLIENTE = "000271"
		If aCols[nI,_nPosFor]  = "000996"
			aCols[nI,_nPosComis1] := 1
		Endif
	Endif
	
	lTemSP := .F.
	SA1->(dbSetOrder(1))
	If SA1->(dbSeek(xFilial("SA1")+M->(C5_CLIENTE+C5_LOJACLI))) .And. !Empty(SA1->A1_XVENDSP)
	
		IF !aCols[nI,Len(aHeader)+1]
			If aCols[nI,_nPosFor] == "000996"
				If SA1->A1_XVENDSP$GetNewPar("ES_XVENDSP","006924")
					aCols[nI,_nPosCom2  ] := 1
				Else
					aCols[nI,_nPosCom2  ] := aCols[nI,_nPosComis1]
				EndIf
				aCols[nI,_nPosComis1] := 0
				M->C5_VEND2 := SA1->A1_XVENDSP
				lTemSP := .T.
			EndIf
		EndIf
		
		If !lTemSP .And. !Empty(M->C5_VEND2)
			M->C5_VEND2 := ""
		EndIf
	EndIf
	
	/*If M->C5_VEND1 == "006924" .And. // 02/04/2014 -  Regra para incluir 1% para o vendedor PAULO --Desativada em 09/05/2018
		aCols[nI,_nPosComis1] := 1
	EndIf*/
	
	If M->C5_CLIENTE == "000871" // 08/07/2014 -  Regra para incluir 3% para o cliente 000871 - Sta Casa Santos (e-mail PatrÌcia)
		aCols[nI,_nPosComis1] := 3
	EndIf
	
	//Utilizamos o campo de B1_COMIS para definir os acessÛrios e assim direcionar a comiss„o correta. 02/03/2020
	If cEmpAnt=="04" .And. Posicione("SB1",1,xFilial("SB1")+AllTrim(aCols[nI,_nPosProd]),"B1_COMIS") > 0 //Colocar comiss„o informada no produto  para grupo de acessÛrios na HQ - Regra v·lida 01/02/2020
		If aCols[nI,_nPosPrcven] < aCols[nI,_nPosMini]
		
			aCols[nI,_nPosComis1] := 3
			
		ElseIf  aCols[nI,_nPosPrcven] = aCols[nI,_nPosMini] .or. aCols[nI,_nPosPrcven] > aCols[nI,_nPosMini] .and.  aCols[nI,_nPosComis1] < 5
		
			aCols[nI,_nPosComis1] := 5
			
		EndIf
	EndIf
	
	If cEmpAnt=="04" .And. M->C5_CLIENTE$"000418/017875" //19/02/2015 - Colocar comiss„o 3% da HQ  para os clientes 000418  e  017875 (e-mail M·ximo)
		aCols[nI,_nPosComis1] := 3
	EndIf
	
	If cEmpAnt=="04" .And. M->C5_VEND1=="006796" .And.  M->C5_CLIENTE$"007214/018738/019034/06259" //19/02/2015 - Colocar comiss„o 1% da Talita na HQ como autom·tico e fixo (07214,018738,019034,06259) (e-mail M·ximo)
		aCols[nI,_nPosComis1] := 1
	EndIf
	
	If cEmpAnt=="04" .And. M->C5_VEND1=="006819" .And.  M->C5_CLIENTE$"019062/019235" //19/02/2015 - Colocar comiss„o 5% do Renato na HQ como autom·tico e fixo (019062) (e-mail Carolina HQ) - CLiente 019235 incluÌdo em 06/04/20 para fixar 2.5 de comiss„o - Carol por e-mail
		aCols[nI,_nPosComis1] := 2.5  //02/06/2015 alterado para 2.5 e-mail do Lucas HQ
	EndIf
	
	If DtoS(dDataBase)<="20181113" .And. M->C5_VEND1=="006819" .And. AllTrim(aCols[nI,_nPosProd])$"028092/028103".And. M->C5_CLIENTE=="006837" .And. aCols[nI,_nPosPrcven]==33.50 //07/04/2017 - Amarrar a comiss„o de 2% p/Renato ok Sr.Ademir, produto 028103 incluido em 07/11/17 - Prazo alterado para 13/11/2018 em 06/03/2018
		aCols[nI,_nPosComis1] := 2
	EndIf
	            
	If DtoS(dDataBase)<="20230210" .And. M->C5_VEND1=="006819" .And. AllTrim(aCols[nI,_nPosProd])$"028209" .And. M->C5_CLIENTE=="006837" .And. aCols[nI,_nPosPrcven]==34 //01/07/2019 - Amarrar a comiss„o de 2% p/Renato ok Sr.Ademir // Atualizado em 05/11/2020
		aCols[nI,_nPosComis1] := 2
	EndIf
		                                   
	If DtoS(dDataBase)<="20180823" .And. M->C5_VEND1=="006819" .And. AllTrim(aCols[nI,_nPosProd])=="PMSP00" .And. M->C5_CLIENTE=="019615" .And. aCols[nI,_nPosPrcven]==0.33 //07/06/2017 - Amarrar a comiss„o de 2% p/Renato ok Sr.Ademir Prorrogado para 23/08/18 em 07/11/17
		aCols[nI,_nPosComis1] := 2
	EndIf     
	
	If DtoS(dDataBase)<="20180130" .And. M->C5_VEND1=="006819" .And. AllTrim(aCols[nI,_nPosProd])=="028097" .And. M->C5_CLIENTE=="006668" .And. aCols[nI,_nPosPrcven]==34.50 //14/06/2017 - Amarrar a comiss„o de 2% p/Renato ok Sr.Ademir
		aCols[nI,_nPosComis1] := 2
	EndIf

	If DtoS(dDataBase)<="20181221" .And. M->C5_VEND1=="006819" .And. AllTrim(aCols[nI,_nPosProd])$"028097/028104" .And. M->C5_CLIENTE=="006668" .And. aCols[nI,_nPosPrcven]==34.50 //04/04/2018 - Amarrar a comiss„o de 2% p/Renato ok Sr.Ademir
		aCols[nI,_nPosComis1] := 2
	EndIf

	If cEmpAnt=="04" .And. (M->C5_CLIENTE$GetNewPar("ES_ZERCOMI","") .Or. M->C5_CLIENTE$GetNewPar("ES_ZERCOM2","")) //03/07/2015 - Zera comissoes para clientes que estao no parametro ES_ZERCOMI e ES_ZERCOM2
		aCols[nI,_nPosComis1] := 0  //e-mail enviado pela Carol
	EndIf
	
	If cEmpAnt=="04" .And. M->C5_VEND1=="006864" .And.  M->C5_CLIENTE$"001417" // 06/11/2015 - Colocar comiss„o 2.5% para o Keiller na HQ como autom·tico e fixo (HCOR) (e-mail Carol/Lucas)
		aCols[nI,_nPosComis1] := 2.5
	EndIf
	
	If cEmpAnt=="04" .And. M->C5_VEND1=="006864" .And. SA1->A1_GRPVEN$"000023"  // 07/04/2017 - Travar a comiss„o do Keiller para o grupo de clientes 000023 (Einstein) em 3% (e-mail Carol/Lucas)
		aCols[nI,_nPosComis1] := 3
	EndIf
	
	If cEmpAnt=="04" .And. M->C5_CLIENTE$"002347" // 18/11/2015 - Colocar comiss„o 10% fixo para o cliente (002347) / alterado para 5% em 01/08/2016 (e-mail Carol)
		aCols[nI,_nPosComis1] := 5
	EndIf
	
	/* Retirado regra dia 04/08/16 - Solicitado pela Carol por e-mail
	If cEmpAnt=="04" .And. M->C5_CLIENTE$"019120" // 18/11/2015 - Colocar comiss„o  5% fixo para o cliente (019120) (e-mail Carol)
		aCols[nI,_nPosComis1] := 5
	EndIf
	*/
	
	If cEmpAnt=="04" .And. M->C5_CLIENTE$"004096" // 04/12/2015 - Colocar comiss„o  1% fixo para o cliente (004096 ) (e-mail Carol)
		aCols[nI,_nPosComis1] := 1
	EndIf    
	            
	//Regra desativada em 03/05/2019 e solicitado pela Carol por e-email
	/*If cEmpAnt=="04" .And. M->C5_CLIENTE$"014399/001827" .And. AllTrim(aCols[nI,_nPosProd])$"227017/227018/222169/222207/212093/222144/212100/222076" // 04/08/16 - Colocar comiss„o  15% fixo para o cliente ConSa˙de (014399/001827) para os produtos 227017/227018/222169/222207/212093/222144/222076  (e-mail Carol), CÛd. 212100 incluÌdo em 02/09/16,  CÛd. 222076 incluÌdo em 03/11/16
		aCols[nI,_nPosComis1] := 15
	EndIf*/ 
	
	If cEmpAnt=="04" .And. M->C5_VEND1$"000192/006694/006757/006786/006796/006828/006863/006896/006899/006903/006912/006919/006922/006929/006932/006944/006945"  // 08/04/2016 - Colocar comiss„o 1% para Katia/Maura/Talita/Elaine/Ana/Renata
		aCols[nI,_nPosComis1] := 1
	EndIf
	          
	If cEmpAnt=="04" .And. M->C5_CLIENTE$"001860"  .And. AllTrim(aCols[nI,_nPosProd])$"225027/225028/225022" // 07/12/2016 - Colocar comiss„o 3% para cliente 001860  no produto 225027, CÛdigos 225028/225022 incluÌdos em 08/03/2017
		aCols[nI,_nPosComis1] := 3
	EndIf   
	
	If cEmpAnt=="04" .And. M->C5_CLIENTE$"000415"  // 07/06/2017 - Colocar comiss„o 2% para cliente 000415
		aCols[nI,_nPosComis1] := 2
	EndIf
	
	If cEmpAnt=="04" .And. M->C5_CLIENTE$"008238/002313" .And. M->C5_VEND1$"006933" // 02/08/2017 - Colocar comiss„o 2% para cliente 008238 e 002313 
		aCols[nI,_nPosComis1] := 2
	EndIf
	
	If cEmpAnt=="04" .And. M->C5_VEND1$"006955" //23/04/2018 - Colocar comiss„o 10% para vendedor 006955 
		aCols[nI,_nPosComis1] := 10
	EndIf
	                                                
	If SA1->A1_GRPVEN $ "000001"  .And. DtoS(dDataBase) <= "20171130"
		If VldHCAMCOR(AllTrim(aCols[nI,_nPosprod]),aCols[nI,_nPosPrcVen])
			aCols[nI,_nPosComis1] := 4 //Comiss„o alterada de 2 para 4 para todos os novos tÌtulos e para os tÌtulos em aberto ou baixados a partir de 11/2016
		Endif
	Endif    
	
    If SA1->A1_GRPVEN $ "000001"  .And. aCols[nI,_nPosFor] == "000183" .And. DtoS(dDataBase) <= "20191130"
		aCols[nI,_nPosComis1] := 4 //Comiss„o de 4% a partir de 01/09/2018 - Solicitado em 22/10, Alterado em 20/12/18
	Endif  
	
	If SA1->A1_GRPVEN $ "000099" 
		If aCols[nI,_nPosFor]== "000647" .And. DtoS(dDataBase) <= "20161216" .And. AllTrim(aCols[nI,_nPosProd])$"080892/080894/080895/080896/080893"
			aCols[nI,_nPosComis1] := 4
		Endif 
		If aCols[nI,_nPosFor]== "000996" .And. DtoS(dDataBase) <= "20170127" .And. AllTrim(aCols[nI,_nPosProd])=="594124"
			aCols[nI,_nPosComis1] := 4
		EndIf
	Endif
	
	If cEmpAnt=="04" .And. M->C5_CLIENTE$"005388/002329"  // 06/12/2017 - Colocar comiss„o 2% para cliente 005388 - CLIENTE 002329 COM COMISS√O EM 2% DESDE 01/04/2018 COM BAIXAS TB NESTE PERÕODO
		aCols[nI,_nPosComis1] := 2
	EndIf
	
	If cEmpAnt=="04" .And. M->C5_CLIENTE$"019147" .And. M->C5_VEND1$"006924" // 14/06/2018 - Colocar comiss„o 3% para cliente 019147 - Vendedor Paulo
		aCols[nI,_nPosComis1] := 1  //Alterado para 1  - solicitado em 09/2018
	EndIf
	
	If cEmpAnt=="04" .And. SA1->A1_GRPVEN $ "000021" .And. M->C5_VEND1$"006933/006924" .And. AllTrim(aCols[nI,_nPosProd])$"222073/222192/222203/222145/227033/227016/227016/227018/222218/222165/222195/225029/225032/227013/227017/227023/222207/227027/222245/222243/222244"// 16/05/2019 - Colocar comiss„o 0% para grupo amil 000021 - Vendedor Alex
		aCols[nI,_nPosComis1] := 0
	EndIf
	
	If cEmpAnt=="04" .And. M->C5_VEND1=="006938" .And.  M->C5_CLIENTE$"019425/003565" //05/05/2020 - Colocar comiss„o 5% do vINÕCIUS na HQ como autom·tico e fixo (e-mail Carolina HQ)  
		aCols[nI,_nPosComis1] := 5 
	EndIf
		
Next nI

Return
/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥MTA410    ∫Autor  ≥Microsiga           ∫ Data ≥  06/06/16   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥                                                            ∫±±
±±∫          ≥                                                            ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ AP                                                        ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
User Function DipHisPer()
Local oDlg                                 
Local aButtons	:= {}
Local bOk 		:= {|| IIf(GravaZZO(),oDlg:End(),nil)}
Local bCancel 	:= {|| IIf(CancelZZO(),oDlg:End(),nil)}
Local nPosSC6	:= 0
Private oCliente
Private oOperado
Private oData
Private aHeadZZO:= {}
Private aColsZZO:= {}
Private oGetDZZO    
Private aCpoAlt := {"ZZO_PRODUT","ZZO_QUANT","ZZO_EXPLIC"}

If Type("aHeader")=="U"
	MsgStop("A funÁ„o F11 sÛ È permitida dentro do pedido de vendas.")
	Return	
EndIf

If Empty(M->C5_CLIENTE)
	MsgStop("Preencha o cÛdigo do cliente antes de usar a opÁ„o F11")
	Return
EndIf               


nPosSC6 := aScan(aHeader,{|x| Upper(AllTrim(x[2]))=="C6_PRODUTO" })    

If !Empty(aCols[n,nPosSC6]) .And. !VldPrdCli(aCols[n,nPosSC6],M->C5_CLIENTE,M->C5_LOJACLI)
	Return
EndIf

aObjects := {}

aSize   := MsAdvSize()
aAdd(aObjects, {100, 100, .T., .T.})

aInfo   := {aSize[1], aSize[2], aSize[3], aSize[4], 2, 2}
aPosObj := MsObjSize(aInfo, aObjects)          

DipMHead()      
DipMCols(M->C5_NUM,M->C5_OPERADO,M->C5_CLIENTE,M->C5_LOJACLI)

If !Empty(aCols[n,nPosSC6])           		
	nPosPrd  := aScan(aHeadZZO,{|x| Upper(AllTrim(x[2]))=="ZZO_PRODUT" })   
	nPosQtd  := aScan(aHeadZZO,{|x| Upper(AllTrim(x[2]))=="ZZO_QUANT"  })    
	nPosVUn  := aScan(aHeadZZO,{|x| Upper(AllTrim(x[2]))=="ZZO_VLRUNI" })   
	nPosVTo  := aScan(aHeadZZO,{|x| Upper(AllTrim(x[2]))=="ZZO_VLRTOT" })   
	nPosDes  := aScan(aHeadZZO,{|x| Upper(AllTrim(x[2]))=="ZZO_DESCRI" })   
	nPosExp  := aScan(aHeadZZO,{|x| Upper(AllTrim(x[2]))=="ZZO_EXPLIC" })   
	nPosDat  := aScan(aHeadZZO,{|x| Upper(AllTrim(x[2]))=="ZZO_DATA" }) 
	AADD(aColsZZO,Array(Len(aHeadZZO)+1))
	aColsZZO[Len(aColsZZO),nPosPrd] := aCols[n,nPosSC6] 
	aColsZZO[Len(aColsZZO),nPosVUn] := 0
	SB1->(dbSetOrder(1))
	If SB1->(dbSeek(xFilial("SB1")+aCols[n,nPosSC6]))
		aColsZZO[Len(aColsZZO),nPosVUn] := IIf(SB1->B1_PRVSUPE>0,SB1->B1_PRVSUPE,SB1->B1_PRVMINI)
		aColsZZO[Len(aColsZZO),nPosDes] := SB1->B1_DESC	
	EndIf
	aColsZZO[Len(aColsZZO),nPosQtd] := 0	
	aColsZZO[Len(aColsZZO),nPosVTo] := 0
	aColsZZO[Len(aColsZZO),nPosExp] := " "
	aColsZZO[Len(aColsZZO),nPosDat] := dDataBase
	aColsZZO[Len(aColsZZO),Len(aHeadZZO)+1] := .F.
EndIf

DEFINE MSDIALOG oDlg TITLE "HistÛrico de perda de vendas" From aSize[7],005 TO aSize[6],aSize[5] OF oMainWnd PIXEL    
                                        
  	cCliente := M->C5_CLIENTE+"-"+POSICIONE("SA1",1,xFilial("SA1")+M->C5_CLIENTE+M->C5_LOJACLI,"A1_NOME")  	
	@ 005,005 SAY "Cliente" 			 		SIZE 180,008 			OF oDlg PIXEL
	@ 012,005 MSGET oCliente 	VAR cCliente	SIZE 180,010 WHEN .F. 	OF oDlg PIXEL  PICTURE "@!"

	cOperado := M->C5_OPERADO+"-"+POSICIONE("SU7",1,xFilial("SU7")+M->C5_OPERADO,"U7_NOME")
	@ 005,195 SAY "Operador"   	  		  		SIZE 180,008 			OF oDlg PIXEL
	@ 012,195 MSGET oOperado 	VAR cOperado	SIZE 180,010 WHEN .F. 	OF oDlg PIXEL  PICTURE "@!"
	                            
	dData := dDataBase
	@ 005,385 SAY "Data" 			       		SIZE 060,008 		  	OF oDlg PIXEL
	@ 012,385 MSGET oData 		VAR dData  		SIZE 060,010 WHEN .F.	OF oDlg PIXEL  PICTURE "@D"
	

	oGetDZZO:=MsNewGetDados():New(aPosObj[1,1]+30,aPosObj[1,2],aPosObj[1,3],aPosObj[1,4],GD_INSERT+GD_UPDATE+GD_DELETE,'U_ZZOLinOk','AllWaysTrue',,aCpoAlt,/*freeze*/,999,'AllWaysTrue',/*superdel*/,/*delok*/,oDlg,@aHeadZZO,@aColsZZO)

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg, bOk, bCancel,,aButtons)								

Return
/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥MTA410    ∫Autor  ≥Microsiga           ∫ Data ≥  06/06/16   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥                                                            ∫±±
±±∫          ≥                                                            ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ AP                                                        ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Static Function DipMHead()
Local nTamanho := 0

dbSelectArea("SX3")
SX3->(dbSetOrder(1))
SX3->(dbSeek("ZZO"))

While !SX3->(Eof()) .And. (X3_ARQUIVO == "ZZO")
	If X3USO(X3_USADO) .And. cNivel >= X3_NIVEL .And. X3_BROWSE == "S"
		
		AAdd(aHeadZZO,{	TRIM(X3_TITULO),;
						X3_CAMPO,;
						X3_PICTURE,;
						X3_TAMANHO,;
						X3_DECIMAL,; 
						X3_VALID,;
						X3_USADO,;
						X3_TIPO,;
						"",;
						X3_CONTEXT } )
	
	EndIf
	SX3->(dbSkip())
EndDo

Return
/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥DIPCUSIMP ∫Autor  ≥Microsiga           ∫ Data ≥  07/28/15   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥                                                            ∫±±
±±∫          ≥                                                            ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ AP                                                        ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Static Function DipMCols(cPedido,cOperado,cCliente,cLoja)
Local nI
dbSelectArea("ZZO")
ZZO->(dbSetOrder(1))
If ZZO->(dbSeek(xFilial("ZZO")+cPedido+cOperado+cCliente+cLoja))
	While !ZZO->(Eof()) .And. ZZO->(ZZO_FILIAL+ZZO_PEDIDO+ZZO_OPERAD+ZZO_CLIENTE+ZZO_LOJA)==xFilial("ZZO")+cPedido+cOperado+cCliente+cLoja
		AADD(aColsZZO,Array(Len(aHeadZZO)+1))
		For nI := 1 To Len(aHeadZZO) 
			If aHeadZZO[nI,2] == "ZZO_DESCRI"
				aColsZZO[Len(aColsZZO),nI] := Posicione("SB1",1,xFilial("SB1")+ZZO->ZZO_PRODUT,"B1_DESC")      
			ElseIf (aHeadZZO[nI,10] != "V")   
				If aHeadZZO[nI,8] == "C"
					aColsZZO[Len(aColsZZO),nI] := AllTrim(ZZO->(FieldGet(FieldPos(aHeadZZO[nI,2]))))
				Else
					aColsZZO[Len(aColsZZO),nI] := ZZO->(FieldGet(FieldPos(aHeadZZO[nI,2])))
				EndIf
			Else
				aColsZZO[Len(aColsZZO),nI] := CriaVar(aHeadZZO[nI,2])
			EndIf
		Next nI
		aColsZZO[Len(aColsZZO),Len(aHeadZZO)+1] := .F.
		ZZO->(dbSkip())
	EndDo
EndIf

Return 
/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥MTA410    ∫Autor  ≥Microsiga           ∫ Data ≥  06/07/16   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥     Desativada em 15/06/2016                               ∫±±
±±∫          ≥                                                            ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ AP                                                        ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
/*
User Function VldQtdZZO()   
Local nEstoque := 0                      
Local nPos     := aScan(aHeadZZO,{|x| Upper(AllTrim(x[2]))=="ZZO_PRODUT" })    
Local lRet     := .F.
                         
If !Empty(oGetDZZO:aCols[n,nPos])
	nEstoque := U_DIPSALDSB2(oGetDZZO:aCols[n,nPos],.t.,'')
	            
	If &(ReadVar()) > 0 .And. nEstoque <= &(ReadVar())
		lRet := .T.
	Else
		Aviso("AtenÁ„o","Quantidade disponÌvel em estoque."+CHR(10)+CHR(13)+;
						"Utilize a rotina somente para informar produtos que est„o em falta no estoque.",{"Ok"},1)	
		&(ReadVar()) := 0
	EndIf
Else 
	Aviso("AtenÁ„o","Produto n„o informado.",{"Ok"},1)
EndIf	   

Return lRet             
*/
/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥MTA410    ∫Autor  ≥Microsiga           ∫ Data ≥  06/07/16   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥                                                            ∫±±
±±∫          ≥                                                            ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ AP                                                        ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/                               
User Function VldPrdZZO()        
Local aArea	   := GetArea()
Local nEstoque := 0                      
Local nPos     := aScan(aHeadZZO,{|x| Upper(AllTrim(x[2]))=="ZZO_PRODUT" })    
Local lRet     := .T.
Local cSQL 	   := ""                 
Local cProduto := &(ReadVar())
Local nI
                         
If !Empty(cProduto)
	For nI:=1 to Len(oGetDZZO:aCols)
		If !oGetDZZO:aCols[nI,Len(oGetDZZO:aHeader)+1]
			If AllTrim(cProduto) == AllTrim(oGetDZZO:aCols[nI,nPos])
				Aviso("AtenÁ„o","Produto j· informado.",{"Ok"},1)
				lRet := .F.
			EndIf
		EndIf
	Next nI
	
	If lRet
		lRet := VldPrdCli(cProduto,M->C5_CLIENTE,M->C5_LOJACLI)
	EndIf	
Else 
	Aviso("AtenÁ„o","Produto n„o informado.",{"Ok"},1)
EndIf	                   

RestArea(aArea)

Return lRet             
/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥MTA410    ∫Autor  ≥Microsiga           ∫ Data ≥  06/07/16   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥                                                            ∫±±
±±∫          ≥                                                            ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ AP                                                        ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
User Function ZZOLinOk()
Local lRet := .F.
Local nPosQtd := aScan(aHeadZZO,{|x| Upper(AllTrim(x[2]))=="ZZO_QUANT" })    
Local nPosExp := aScan(aHeadZZO,{|x| Upper(AllTrim(x[2]))=="ZZO_EXPLIC"})    
        
If !oGetDZZO:aCols[n,Len(oGetDZZO:aHeader)+1]
	If oGetDZZO:aCols[n,nPosQtd]> 0
		If !Empty(oGetDZZO:aCols[n,nPosExp])
			lRet := .T.
		Else           
			Aviso("AtenÁ„o","Informe a explicaÁ„o.",{"Ok"},1)
		EndIf
	Else
		Aviso("AtenÁ„o","Quantidade n„o informada",{"Ok"},1)
	EndIf	
EndIf

Return lRet
/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥MTA410    ∫Autor  ≥Microsiga           ∫ Data ≥  06/07/16   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥                                                            ∫±±
±±∫          ≥                                                            ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ AP                                                        ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Static Function CancelZZO()
Local lRet := .F.

If Aviso("AtenÁ„o","Tem certeza que deseja cancelar?",{"Sim","N„o"},1)==1
	lRet := .T.
EndIf

Return lRet
/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥MTA410    ∫Autor  ≥Microsiga           ∫ Data ≥  06/07/16   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥                                                            ∫±±
±±∫          ≥                                                            ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ AP                                                        ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Static Function GravaZZO()
Local lRet := .T.
Local nPosPrd  := aScan(aHeadZZO,{|x| Upper(AllTrim(x[2]))=="ZZO_PRODUT" })    
Local nPosQtd  := aScan(aHeadZZO,{|x| Upper(AllTrim(x[2]))=="ZZO_QUANT"  })    
Local nPosVUn  := aScan(aHeadZZO,{|x| Upper(AllTrim(x[2]))=="ZZO_VLRUNI" })    
Local nPosVTo  := aScan(aHeadZZO,{|x| Upper(AllTrim(x[2]))=="ZZO_VLRTOT" })    
Local nPosExp  := aScan(aHeadZZO,{|x| Upper(AllTrim(x[2]))=="ZZO_EXPLIC" })    
Local nPosDat  := aScan(aHeadZZO,{|x| Upper(AllTrim(x[2]))=="ZZO_DATA" 	 })  
Local nI
For nI:=1 to Len(oGetDZZO:aCols)
	If !oGetDZZO:aCols[nI,Len(oGetDZZO:aHeader)+1]
		If Empty(oGetDZZO:aCols[nI,nPosPrd]) .Or.;
			oGetDZZO:aCols[nI,nPosQtd]==0 .Or.;
			oGetDZZO:aCols[nI,nPosVUn]==0 
			Aviso("AtenÁ„o","Existem linhas com dados n„o preenchidos. Confira!",{"Ok"},1)
			lRet := .F.				
		EndIf
	EndIf
Next nI

If lRet .And. Aviso("AtenÁ„o","Confirma a inclus„o/alteraÁ„o dos dados?",{"Sim","N„o"},1)==1
	ZZO->(dbSetOrder(1))           
	For nI:=1 to Len(oGetDZZO:aCols)		
		If ZZO->(dbSeek(xFilial("ZZO")+M->(C5_NUM+C5_OPERADO+C5_CLIENTE+C5_LOJACLI)+PadR(oGetDZZO:aCols[nI,nPosPrd],15)+DtoS(oGetDZZO:aCols[nI,nPosDat])))   
			If oGetDZZO:aCols[nI,Len(oGetDZZO:aHeader)+1]    
				ZZO->(RecLock("ZZO",.F.))
					ZZO->(dbDelete())
				ZZO->(MsUnLock())	
			Else
				If ZZO->ZZO_QUANT <> oGetDZZO:aCols[nI,nPosQtd] .Or.;
					ZZO->ZZO_VLRUNI <> oGetDZZO:aCols[nI,nPosVUn] .Or.;
					ZZO->ZZO_VLRTOT <> oGetDZZO:aCols[nI,nPosVTo] .Or.;
					AllTrim(ZZO->ZZO_EXPLIC) <> AllTrim(oGetDZZO:aCols[nI,nPosExp])
					
					ZZO->(RecLock("ZZO",.F.))
						ZZO->ZZO_QUANT  := oGetDZZO:aCols[nI,nPosQtd]
						ZZO->ZZO_VLRUNI := oGetDZZO:aCols[nI,nPosVUn]
						ZZO->ZZO_VLRTOT := oGetDZZO:aCols[nI,nPosVTo]
						ZZO->ZZO_EXPLIC := oGetDZZO:aCols[nI,nPosExp]
					ZZO->(MsUnLock())
				EndIf
			EndIf
		ElseIf !oGetDZZO:aCols[nI,Len(oGetDZZO:aHeader)+1]    
			ZZO->(RecLock("ZZO",.T.))
				ZZO->ZZO_FILIAL := xFilial("ZZO")
				ZZO->ZZO_PEDIDO := M->C5_NUM 
				ZZO->ZZO_OPERAD := M->C5_OPERADO
				ZZO->ZZO_CLIENT := M->C5_CLIENTE
				ZZO->ZZO_LOJA   := M->C5_LOJACLI
				ZZO->ZZO_PRODUT := oGetDZZO:aCols[nI,nPosPrd]
				ZZO->ZZO_DATA   := dDataBase        
				ZZO->ZZO_QUANT  := oGetDZZO:aCols[nI,nPosQtd]
				ZZO->ZZO_VLRUNI := oGetDZZO:aCols[nI,nPosVUn]
				ZZO->ZZO_VLRTOT := oGetDZZO:aCols[nI,nPosVTo]
				ZZO->ZZO_EXPLIC := oGetDZZO:aCols[nI,nPosExp]
				ZZO->ZZO_ESTOQU := U_DIPSALDSB2(oGetDZZO:aCols[nI,nPosPrd],.t.,'')
			ZZO->(MsUnLock())
		EndIf
	Next nI
EndIf

Return lRet
/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥MTA410    ∫Autor  ≥Microsiga           ∫ Data ≥  06/07/16   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥                                                            ∫±±
±±∫          ≥                                                            ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ AP                                                        ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Static Function VldPrdCli(cProduto,cCliente,cLoja)     
Local cSQL := ""
Local lRet := .T.

cSQL :=  " SELECT "
cSQL +=  " 	COUNT(1) QTD "
cSQL +=  " 	FROM "
cSQL +=   		RetSQLName("ZZO")
cSQL +=  " 		WHERE "
cSQL +=  " 			ZZO_FILIAL = '"+xFilial("ZZO")+"' AND "
cSQL +=  " 			ZZO_PRODUT = '"+cProduto+"' AND "
cSQL +=  " 			ZZO_CLIENT = '"+cCliente+"' AND "
cSQL +=  " 			ZZO_LOJA   = '"+cLoja+"' AND "
cSQL +=  " 			ZZO_DATA   = '"+DtoS(dDataBase)+"' AND "
cSQL +=  " 			D_E_L_E_T_ = ' ' "

cSQL := ChangeQuery(cSQL)
dbUseArea(.T.,"TOPCONN",TCGenQry(,,cSQL),"QRYZZO",.F.,.T.)

If !QRYZZO->(Eof()) .And. QRYZZO->QTD>0
	Aviso("AtenÁ„o","Este produto j· foi informado para este cliente nesta data."+CHR(13)+CHR(10)+;
					"N„o ser· possÌvel inform·-lo novamente.",{"Ok"},1)
	lRet := .F.				
EndIf
QRYZZO->(dbCloseArea())

Return lRet  
/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥MTA410    ∫Autor  ≥Microsiga           ∫ Data ≥  11/07/16   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥                                                            ∫±±
±±∫          ≥                                                            ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ AP                                                        ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Static Function DipVldZZS(cCliente,cLoja)
Local lRet := .F.
Local cSQL := ""
Local aArea := GetArea()                

cSQL := " SELECT "
cSQL += " 	A1_COD " 
cSQL += " 	FROM "
cSQL +=  		RetSQLName("SA1")
cSQL += " 		INNER JOIN "
cSQL +=  			RetSQLName("ZZS")
cSQL += " 			ON "
cSQL += " 				ZZS_FILIAL = '"+xFilial("ZZS")+"' AND "
cSQL += " 				ZZS_CGC = A1_CGC AND "
cSQL += " 				ZZS_VIGINI <= '"+DtoS(dDataBase)+"' AND "
cSQL += " 				(ZZS_VIGFIN = ' ' OR ZZS_VIGFIN >= '"+DtoS(dDataBase)+"') "
cSQL += " 		WHERE "
cSQL += " 			A1_FILIAL = '"+xFilial("SA1")+"' AND "
cSQL += " 			A1_COD = '"+cCliente+"' AND "
cSQL += " 			A1_LOJA = '"+cLoja+"' AND "
cSQL +=  			RetSQLName("SA1")+".D_E_L_E_T_ = ' ' AND "
cSQL +=  			RetSQLName("ZZS")+".D_E_L_E_T_ = ' ' "

cSQL := ChangeQuery(cSQL)
dbUseArea(.T.,"TOPCONN",TCGenQry(,,cSQL),"QRYZZS",.F.,.T.)
              
lRet := !QRYZZS->(Eof())	
QRYZZS->(dbCloseArea())

RestArea(aArea)           

Return lRet
/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥MTA410    ∫Autor  ≥Microsiga           ∫ Data ≥  01/13/17   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥ Valida comiss„o cliente HC x produtos AMCOR                ∫±±
±±∫          ≥                                                            ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ AP                                                        ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Static Function VldHCAMCOR(cProduto,nValor)
Local lRet      := .F.                                               
Local aCondic 	:= ()

aCondic := {{'040381', 36},;
			{'040442', 24},;
			{'081143', 33},;
			{'081202', 58},;
			{'081205',177},;
			{'081206', 60},;
			{'081210',134},;
			{'081318',166},;
			{'081411', 58},;
			{'081412', 83},;
			{'081413',177},;
			{'081414',134},;
			{'081416', 23},;
			{'081417', 33},;
			{'081418', 60},;
			{'081549', 46},;
			{'081637', 46},;
			{'081638', 66},;
			{'081641', 58},;
			{'081645',166},;
			{'081649',177},;
			{'081653', 72},;
			{'081654', 48},;
			{'081655', 46},;
			{'081656', 66},;
			{'081657',116},;
			{'081658',166},;
			{'081659',354}}
			                
lRet := aScan(aCondic,{|x| x[1]==cProduto .And. x[2]<=nValor})>0

Return lRet

/*
+=========================================================+
|Fonte: TdeAtiva | Autor: Reginaldo Borges | Data 09/06/17|
+---------------------------------------------------------+
|Descr.: Calcular o TDE para a Ativa.                     |
+=========================================================+
*/

Static Function TdeAtiva(cCodCli,cCodTransp)
          
Local _aArea:= GetArea()   
Local cQRY := ""
Local lRet := .T.

cQRY :=" SELECT X5_DESCRI FROM " +RetSqlName("SX5")+ " 
cQRY +=" WHERE X5_TABELA = 'ZD' AND "  
cQRY +="       X5_CHAVE  = '"+cCodTransp+"' AND "
cQRY +="       X5_DESCRI = '"+cCodCli+"' AND " 
cQRY +=" "+RetSqlName("SX5")+".D_E_L_E_T_ = '' 
cQRY +=" ORDER BY X5_DESCRI "
       
cQRY := ChangeQuery(cQRY)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQRY),"cQRYATIVA",.T.,.T.)
      
If cQRYATIVA->(Eof())
	lRet := .F.
EndIf

cQRYATIVA->(dbCloseArea())

RestArea(_aArea)
    
Return lRet

/*
+=========================================================+
|Fonte: TRTAtiva | Autor: Reginaldo Borges | Data 13/06/17|
+---------------------------------------------------------+
|Descr.: Verificar os CEPs para calcular TRT.		      |
+=========================================================+
*/
Static Function TRTAtiva(cCepCli,cCodTransp,cCodCli)
Local _xAlias 	   := GetArea()  
Local _xAliasSA1   := SA1->(GetArea())  
Local lRet    	   := .T.
Local QRY2    	   := ""
Local cCNPJCli	   := ""
DEFAULT cCepCli    := ""
DEFAULT cCodTransp := ""
DEFAULT cCodCli    := ""  

If !Empty(cCodCli)
	SA1->(dbSetOrder(1))
	If SA1->(dbSeek(xFilial("SA1")+cCodCli))
		cCNPJCli := cValToChar(Val(SA1->A1_CGC)) //Retirar zeros ‡ esquerda
	Else
		Aviso("ATEN«√O","ERRO - Cliente n„o encontrado para c·lculo de difÌcil acesso. Fale com o TI",{"Ok"})
	EndIf
EndIf
	
QRY2 := "SELECT ZZV_TRANSP"
QRY2 += " FROM " + RetSQLName("ZZV")
QRY2 += " WHERE ZZV_FILIAL  = '" + xFilial("ZZV") + "'"
QRY2 += "   AND ZZV_TRANSP  = '" +cCodTransp+ "'"
If !Empty(cCepCli)
	QRY2 += "   AND ZZV_CEPINI <= '" + cCepCli + "'"
	QRY2 += "   AND ZZV_CEPFIM >= '" + cCepCli + "'"
EndIf
If !Empty(cCNPJCli)
	QRY2 += "   AND CAST(CAST(ZZV_CGCCLI AS BIGINT) AS VARCHAR(14)) = '"+cCNPJCli+"'"
EndIf
QRY2 += "   AND " + RetSQLName("ZZV") + ".D_E_L_E_T_ = ' ' "
#xcommand TCQUERY <sql_expr>                          ;
[ALIAS <a>]                                           ;
[<new: NEW>]                                          ;
[SERVER <(server)>]                                   ;
[ENVIRONMENT <(environment)>]                         ;
=> dbUseArea(                                         ;
<.new.>,                                              ;
"TOPCONN",                                            ;
TCGENQRY(<(server)>,<(environment)>,<sql_expr>),      ;
<(a)>, .F., .T.)

TcQuery QRY2 NEW ALIAS "QRY2"         

If QRY2->(Eof())
	lRet := .F.
EndIf       

If !Empty(cCodCLi) .And. Empty(cCNPJCli) //Se for pesquisa por cliente e n„o achou o CNPJ
	lRet := .T.	
EndIf

QRY2->(DbCloseArea())

RestArea(_xAliasSA1)
RestArea(_xAlias)

Return(lRet)

/*
+=========================================================+
|Fonte: EXISTDA  | Autor: Reginaldo Borges | Data 04/04/19|
+---------------------------------------------------------+
|Descr.: Verificar os CEPs para calcular TDA.		      |
+=========================================================+
*/
/*
Static Function EXISTDA(cCepCli,cCodTransp)
Local _xAlias 	   := GetArea()  
Local lRet    	   := .F.
Local cSQL    	   := ""
	
cSQL := "SELECT ZV_LOCALID "
cSQL += " FROM " + RetSQLName("SZV")
cSQL += " WHERE ZV_FILIAL  = '" + xFilial("SZV") + "'"  
cSQL += "   AND ZV_CEPINI <= '" + cCepCli + "'"
cSQL += "   AND ZV_CEPFIM >= '" + cCepCli + "'"
cSQL += "   AND ZV_TRANSP  = '" + TRB->Z3_TRANSP + "'"
cSQL += "   AND ZV_TDA     = '1' "
cSQL += "   AND " + RetSQLName("SZV") + ".D_E_L_E_T_ = ' ' "

cSQL := ChangeQuery(cSQL)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),"QRYTDA",.T.,.T.)
		
If !QRYTDA->(Eof())
	lRet := .T.
EndIf    
		
QRYTDA->(dbCloseArea())    	
RestArea(_xAlias)

Return(lRet)
*/

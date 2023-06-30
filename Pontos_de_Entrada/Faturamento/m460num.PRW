/*
PONTO.......: M460NUM           PROGRAMA....: MATA460
DESCRIวฤO...: APOS CONFIRMAR O NUMERO DA NF SAIDA
UTILIZAวฤO..: Ao confirmar o numero da NF, podendo o mesmo ser alterado
atraves da variavel cnumero que e Private
PARAMETROS..: UPAR do tipo X : Esta funcao recebe os itens do SC9 em um
array, para acessar utilize:
ParamIxb[n,1] Numero do Pedido
ParamIxb[n,2] Item do Pedido
ParamIxb[n,3] Sequencia da libera็ao
RETORNO.....: URET do tipo X :
OBSERVAวึES.: <NENHUM>
*/
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบPrograma  ณ M460NUM   บ Autor ณ Eriberto Elias s   บ Data ณ 18/11/2003 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Calcula o valor do frete para os itens liberados           บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
ฑฑณRetirada analise de cr้dito customizada 								  ณฑฑ
ฑฑณFernando R. Assun็ใo - 08/06/06										  ณฑฑ
-----------------------------------------------------------------------------
ฑฑณMaximo - Validando finaliza็ใo da ๚ltima NF gerada  - 24/08/09      	  ณฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
#include "Protheus.ch"
#include "rwmake.ch"

User Function M460NUM()
Local _xAlias   := GetArea()
Local _xAliasSC5 := SC5->(GetArea())
Local _xAliasSC9 := SC9->(GetArea())
Local _xAliasSB1 := SB1->(GetArea())
Local _xAliasSA1 := SA1->(GetArea())

///////////////////////// CALCULO
Local _nVrFrete  := 0
Local _nQtItens  := 0
Local _nPesoBr   := 0
Local _nVrPesoExc:= 0
Local _nVlrTotal := 0    
Local lNfAnt  := .F.        
Local lCorrige:= .F.
Local nNumNf := Val(cNumero)
Local cSerNf := cSerie 
Local nCont  := 1 
Private cFilSD2:=SD2->(xFilial("SD2"))
Private cFilSF2:=SF2->(xFilial("SF2")) 
Private lDIPA039 := .F. // MCVN - 25/08/09
Public nDipValPed:= 0  // JBS 03/05/2006 Usada no M460Rat
                  
If Left(FUNNAME(),3)=="TMS" .Or. "MATA310"$Upper(FunName())
	RestArea(_xAliasSB1)
	RestArea(_xAliasSC9)
	RestArea(_xAliasSC5)
	RestArea(_xAlias)	
	Return(ParamIxb)	
EndIf

While !lNfAnt .And. !("TMSA200" $ FUNNAME()) .And. nNumNf > 1  .And. nCont < 50
	SF2->(dbSetOrder(1))
	If SF2->(dbSeek(cFilSF2+PADR(STRZERO(nNumNf-nCont,LEN(cnumero)),9)+cSerNf)) //Ajuste p๓s virada de versใo p/ 10 MCVN - 17/11/2009
		lNfAnt := .T.
        If Empty(Alltrim(SF2->F2_CONFERI)) .OR. Empty(Alltrim(SF2->F2_SEPAROU))
   			lCorrige := .T.	
        Endif
		SD2->(dbSetOrder(3))
		SD2->(dbSeek(cFilSD2+PADR(STRZERO(nNumNf-nCont,LEN(cnumero)),9)+cSerNf))
		
		If SD2->D2_CUSDIP == 0 .Or. U_GetZ9(SD2->D2_PEDIDO,"50") == 0 
			lCorrige := .T.	
		Endif		
     Endif   
     nCont++
EndDo       

If lCorrige  
	lDIPA039 := .T.
	Processa({|| U_DIPA039()},"Corrigindo nota fiscal  "+SF2->F2_DOC+" - "+SF2->F2_SERIE+" . Aguarde!")
EndIf          


If !("TMSA200" $ FUNNAME()) 
	U_DIPPROC(ProcName(0),U_DipUsr()) // JBS 05/10/2005 - Gravando o nome do Programa no SZU

	IF SC5->(DbSeek(xFilial("SC5")+ParamIxb[1,1]))
		RecLock("SC5",.F.)
		SC5->C5_FLAGFRE := SC5->C5_FRETE
		SC5->(MsUnLock())
	EndIf

	SB1->(DbSetOrder(1))

	DbSelectArea("SC9")
	SC9->(DbSetOrder(1))
	IF SC9->(DbSeek(xFilial("SC9")+ParamIxb[1,1]))
	
		//************************ (NOTAFISCAL,Nota Fiscal) ************************
		//Warning - FieldGet error - field number 0 does not exist in file SC5010 - statement ignored (Last FieldPos that returned 0 received parameter: 'C9_OK')
		// ACHO QUE O PROBLEMA ESTม AQUI
		
		// Soma peso bruto, liquido, volume e total do pedido.
		Do While !SC9->(Eof()) .and. xFilial("SC9") == SC9->C9_FILIAL .And. SC9->C9_PEDIDO == ParamIxb[1,1]
	
	     	If !("TMSA200" $ FUNNAME()) // Nใo entra se a rotina for chamada pelo TMS  - MCVN 01/12/2008
	       	    If IsMark("C9_OK",ThisMark(),ThisInv()) 
			    	IF Empty(SC9->C9_BLEST) .and. Empty(SC9->C9_BLCRED) .and. Empty(U_C5PARCIAL())
						IF SB1->(DbSeek(xFilial("SB1")+SC9->C9_PRODUTO))
							_nPesoBr  +=(SC9->C9_QTDLIB * SB1->B1_PESO)
							_nVlrTotal+= NoRound((SC9->C9_QTDLIB * SC9->C9_PRCVEN),2)
							_nQtItens ++
						EndIF
					EndIF
				Endif
			Endif
			SC9->(DbSkip())
		EndDo 
		
		// Calculo o peso bruto
		_nPesoBr  := _nPesoBr 
		nDipValPed:= _nVlrTotal // JBS 03/05/2006 Usada no M460Rat
		//----------------------------------------------------
	    // JBS 31/01/2006 Calcular o Frete na Gera็ใo da Nota                   
	    //----------------------------------------------------
		If SC5->C5_TPFRETE == "I"
		    // Consiste se o destino de entrega estแ preenchido
			If  !Empty(SC5->C5_DESTFRE)
			     // Chama a fun็ใo que vai calcular o frete
			     // para as diversas transportadoras que 
			     // atendam aos parametros do cliente.
				_lRetorno:=U_ClcLimite("NF",_nVlrTotal,_nPesoBr)
			EndIF
		EndIF // JBS 31/01/2006 Fim

		//-- DL 09/02/2010 - Chamada para fun็ใo da tela do separador.
		SC9->(DbSetOrder(1))
		If SC9->(DbSeek(xFilial("SC9")+ParamIxb[1,1])) //-- Reposiciona Tabela SC9
			U_TelSepar(.T.,_nVlrTotal)
		EndIf

		DbSelectArea("SA1")
		If SA1->(MsSeek(xFilial("SA1")+SC5->(C5_CLIENTE+C5_LOJACLI))) .And. SA1->A1_ENVBRIN == "S"
			If MsgBox("Estใo sendo enviados os brindes? ","Aten็ใo","YESNO")
				RecLock("SA1",.F.)
				SA1->A1_ENVBRIN := "N"
				SA1->(MsUnLock())
			EndIF
		EndIf 

	EndIF 
ENDIF
///////////////////////////////

//DipRetNum()

RestArea(_xAliasSB1)
RestArea(_xAliasSC9)
RestArea(_xAliasSC5)
RestArea(_xAlias)

Return(ParamIxb)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTelSepar  บAutor  ณMicrosiga           บ Data ณ  02/09/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Tela de sele็ใo do separador utilizada na gera็ใo da NF.   บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ P10-Dipromed                                               บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function TelSepar(_lTela,_nVlrTotal)
Local _l460Num		:= "M460NUM" $ UPPER(ProcName(1)) // Chamado diretamente pela ProcName
Local _aRet			:= {}     
Local lWhen			:= .T.
Local _cPedid		:= If(!_l460Num,SD2->D2_PEDIDO,SC9->C9_PEDIDO)

DEFAULT _lTela 		:= .F.
DEFAULT _nVlrTotal	:=0

//-- Declara็ใo de Variแveis Estแticas para serem usadas no SF2460I
Static _cSeparo,_cConfir,_nVolume,_cTransp,_cLocExp,_cTpFrete,_lAltTransp
                                           
If ("MATA310"$FUNNAME())                   
	_cTransp  := If(!_l460Num,SF2->F2_TRANSP ,SC5->C5_TRANSP)
	_cTpFrete := If(!_l460Num,SF2->F2_TPFRETE,SC5->C5_TPFRETE)
	
	_aRet := {	"XX",;		//-- [1]
				"XX",;		//-- [2]
				1,;	   		//-- [3]
				_cTransp,;	//-- [4]
				"000",;		//-- [5]
				_cTpFrete,;	//-- [6]
				.F.}		//-- [7]

Else
	If !("TMSA200" $ FUNNAME())// Nใo entra se a rotina for chamada pelo TMS  - MCVN 01/12/2008
	
		If ("DIPA056" $ FUNNAME())
						//-- Se a tela ainda nใo fora chamada anteriormente, for็a a sua apresenta็ใo.
			If !_lTela .And. _cSeparo == Nil
				_lTela := .T.
			EndIf
	
			If _lTela
				_cSeparo := If(!_l460Num,SF2->F2_SEPAROU,SC9->C9_SEPARAD)
		//		_cConfir := If(!_l460Num,SF2->F2_CONFERI,Space(Len(SF2->F2_CONFERI)))
				_cConfir := If(!_l460Num,SF2->F2_CONFERI,Space(2))
				_nVolume := If(!_l460Num,SF2->F2_VOLUME1,SC5->C5_VOLUME1) 
				_cTransp := If(!_l460Num,SF2->F2_TRANSP ,SC5->C5_TRANSP) //MCVN - 30/05/09
				_cLocExp := '000'  
				_cTpFrete:= If(!_l460Num,SF2->F2_TPFRETE,SC5->C5_TPFRETE)// MCVN - 30/05/09

				_lAltTransp	 := .F.         
				
				ZZ5->(dbSetOrder(1))
				If ZZ5->(dbSeek(xFilial("ZZ5")+_cPedid)) 
					While !ZZ5->(Eof()) .And. ZZ5->ZZ5_PEDIDO == _cPedid
						If Empty(ZZ5->ZZ5_NOTA)		
							_cSeparo 	:= 	ZZ5->ZZ5_SEPARA
							_cConfir    :=  ZZ5->ZZ5_CONFER
							_nVolume    :=  U_DipConfVl(ZZ5->ZZ5_PEDIDO,ZZ5->ZZ5_VOLUME)
							_cLocExp    :=  SubStr(AllTrim(ZZ5->ZZ5_EXPED1),1,3)                 
							lWhen 		:= .F.
						EndIf		
						ZZ5->(dbSkip())
					EndDo	
				EndIf
			EndIf
	
			_aRet := {	_cSeparo,;		//-- [1]
						_cConfir,;		//-- [2]
						_nVolume,;		//-- [3]
						_cTransp,;		//-- [4]
						_cLocExp,;		//-- [5]
						_cTpFrete,;		//-- [6]
						_lAltTransp}	//-- [7]
	
			If !_lTela
				_cSeparo := Space(2)
				_cConfir := Space(2)
				_nVolume := 0
				_cTransp := Space(Len(SF2->F2_TRANSP))
				_cLocExp := '000'  
				_cTpFrete:= Space(Len(SF2->F2_TPFRETE))

				_lAltTransp	 := .F.
			EndIf
		
			If _lAltTransp	
				DipGrvTra(_cTransp,_cPedid)
			EndIf
		Else	
			//-- Se a tela ainda nใo fora chamada anteriormente, for็a a sua apresenta็ใo.
			If !_lTela .And. _cSeparo == Nil
				_lTela := .T.
			EndIf
	
			If _lTela
				_cSeparo := If(!_l460Num,SF2->F2_SEPAROU,SC9->C9_SEPARAD)
		//		_cConfir := If(!_l460Num,SF2->F2_CONFERI,Space(Len(SF2->F2_CONFERI)))
				_cConfir := If(!_l460Num,SF2->F2_CONFERI,Space(2))
				_nVolume := If(!_l460Num,SF2->F2_VOLUME1,SC5->C5_VOLUME1) 
				_cTransp := If(!_l460Num,SF2->F2_TRANSP ,SC5->C5_TRANSP) //MCVN - 30/05/09
				_cLocExp := '000'  
				_cTpFrete:= If(!_l460Num,SF2->F2_TPFRETE,SC5->C5_TPFRETE)// MCVN - 30/05/09

				_lAltTransp	 := .F.         
				
				ZZ5->(dbSetOrder(1))
				If ZZ5->(dbSeek(xFilial("ZZ5")+_cPedid)) 
					While !ZZ5->(Eof()) .And. ZZ5->ZZ5_PEDIDO == _cPedid
						If Empty(ZZ5->ZZ5_NOTA)		
							_cSeparo 	:= 	ZZ5->ZZ5_SEPARA
							_cConfir    :=  ZZ5->ZZ5_CONFER
							_nVolume    :=  U_DipConfVl(ZZ5->ZZ5_PEDIDO,ZZ5->ZZ5_VOLUME)
							_cLocExp    :=  SubStr(AllTrim(ZZ5->ZZ5_EXPED1),1,3)                 
							lWhen 		:= .F.
						EndIf		
						ZZ5->(dbSkip())
					EndDo	
				EndIf
	
				@ 126,000 To 450,450 DIALOG oDlg TITLE OemToAnsi(	" PV - " +_cPedid+;
																" / NF - " + If(!_l460Num,SF2->F2_DOC,cNumero) + ;
																'  Chave.: '+ ;
																			AllTrim(Transform(Val(Embaralha(StrZero(int(;
																			If(!_l460Num,SF2->F2_VALMERC,_nVlrTotal);
																			); 		//-- Int
																			,9); 	//-- StrZero
																			,0); 	//-- Embaralha
																			);		//-- Val
																			,"@E 999,999,999"); //-- TransForm
																			);		//-- AllTrim
															) //-- OemToAnsi
				@ 008,010 Say 'Quem?'
				@ 020,010 Say "Separou: "
				@ 020,040 Get _cSeparo Size 33,20 F3 "SZC" Valid ExistCPO("SZC",_cSeparo) When lWhen
				@ 035,010 Say "Conferiu: "
				@ 035,040 Get _cConfir Size 33,20 F3 "SZC" Valid ExistCPO("SZC",_cConfir) When lWhen
				@ 050,010 say 'Expedi็ใo:'
				@ 050,040 get _cLocExp Size 15,20 Picture "999" When lWhen
				@ 065,010 say 'Volumes:'
				@ 065,040 get _nVolume Size 33,20 Picture "@E 999,999" When lWhen  
				@ 090,010 Say "Transportadora: "
				@ 090,060 Get _cTransp Size 33,20 F3 "SA4" Valid ExistCPO("SA4",_cTransp)  When _lAltTransp
				@ 105,010 say 'Tipo de Frete:'
				@ 105,060 get _cTpFrete Size 15,20         Valid _cTpFrete $ "CFINM" When _lAltTransp
			
				@ 130,010 BUTTON OemToAnsi("Alterar Transp") SIZE 44,15 ACTION Eval({|| _lAltTransp := u_DipVldPro(_cPedid,_cTpFrete,_cTransp) })//MCVN - 30/05/09
				@ 130,140 BUTTON OemToAnsi("Confirma")       SIZE 30,15 ACTION Close(odlg)        //MCVN - 30/05/09
				//@ 130,140 BUTTON OemToAnsi("Cancela")        SIZE 30,15 ACTION (_nOpcao := 0, Close(odlg))
				ACTIVATE DIALOG oDlg Centered
			EndIf
	
			_aRet := {	_cSeparo,;		//-- [1]
						_cConfir,;		//-- [2]
						_nVolume,;		//-- [3]
						_cTransp,;		//-- [4]
						_cLocExp,;		//-- [5]
						_cTpFrete,;		//-- [6]
						_lAltTransp}	//-- [7]
	
			If !_lTela
				_cSeparo := Space(2)
				_cConfir := Space(2)
				_nVolume := 0
				_cTransp := Space(Len(SF2->F2_TRANSP))
				_cLocExp := '000'  
				_cTpFrete:= Space(Len(SF2->F2_TPFRETE))

				_lAltTransp	 := .F.
			EndIf
		
			If _lAltTransp	
				DipGrvTra(_cTransp,_cPedid)
			EndIf
		Endif
	EndIf
EndIf

Return _aRet               
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณM460NUM   บAutor  ณMicrosiga           บ Data ณ  12/26/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function DipGrvTra(_cTransp,_cPedid)
DEFAULT _cTransp := ""
DEFAULT _cPedid  := ""

ZZ5->(dbSetOrder(1))
If ZZ5->(dbSeek(xFilial("ZZ5")+_cPedid)) .And. ZZ5->ZZ5_TRANSP <> _cTransp
	ZZ5->(RecLock("ZZ5",.F.))
		ZZ5->ZZ5_TRANSP := _cTransp
	ZZ5->(MsUnlock())
EndIf 

CB7->(dBSetOrder(2))
If CB7->(dBSeek(xFilial("CB7")+_cPedid))   
	While !CB7->(Eof()) .And. CB7->CB7_PEDIDO == _cPedid
		If CB7->CB7_TRANSP <> _cTransp
			CB7->(RecLock("CB7",.F.))
				CB7->CB7_TRANSP := _cTransp
			CB7->(MsUnlock())
		EndIf
		CB7->(dbSkip())
	EndDo
EndIf

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณM460NUM   บAutor  ณMicrosiga           บ Data ณ  04/30/13   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function DipConfVl(cPedido,cVol)
Local nVol := 0                 
Local nQtd := 0
Local cSQl := ""       
DEFAULT cPedido := ""
DEFAULT cVol 	:= ""

nVol := Val(cVol)

cSQL := " SELECT COUNT(DISTINCT CB9_VOLUME) QTD FROM "+RetSQLName("CB9")
cSQL += " WHERE CB9_FILIAL = '"+xFilial("CB9")+"' AND "
cSQL += " CB9_PEDIDO = '"+cPedido+"' AND "  
cSQL += " CB9_VOLUME <> ' ' AND "
cSQL += " CB9_XNOTA  = ' ' AND "
cSQL += " CB9_XSERIE = ' ' AND "
cSQL += " D_E_L_E_T_ = ' ' "

cSQL := ChangeQuery(cSQL)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),"QRYCB9",.F.,.T. )

If !QRYCB9->(Eof())              
	nQtd := QRYCB9->QTD
EndIf	
QRYCB9->(dbCloseArea())                                                

If nVol <> nQtd
	Conout("Alterou o volume: "+cPedido+" De "+AllTrim(Str(nVol))+" Para "+AllTrim(Str(nQtd)) )
	nVol := nQtd
EndIf

Return nVol        
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณM460NUM   บAutor  ณMicrosiga           บ Data ณ  12/17/13   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function DipVldPro(cPedido,cTpFrete,cTransp)
Local aArea:= GetArea()
Local aAreaSC5 := SC5->(GetArea())
Local lRet := .T.
Local cSQL := ""                  
DEFAULT cPedido := ""
DEFAULT cTpFrete:= ""
DEFAULT cTransp := ""

If cTpFrete$"I/C" .And. cTransp=="100000"
	
	cSQL := " SELECT "
	cSQL += " 	C6_PRODUTO "
	cSQL += "	FROM "
	cSQL +=			RetSQLName("SC6")
	cSQL += "		WHERE "
	cSQL += "			C6_FILIAL = '"+xFilial("SC6")+"' AND "
	cSQL += "			C6_NUM = '"+cPedido+"' AND "     

	If FunName()<>"DIPA012"
		cSQL += " 			C6_NOTA = ' ' AND "
	EndIf

	cSQL += "			D_E_L_E_T_ = ' ' "
	
	cSQL += ChangeQuery(cSQL)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),"QRYSC6",.T.,.T.)
	
	While !QRYSC6->(Eof())
		If AllTrim(QRYSC6->C6_PRODUTO)$GetNewPar("ES_PROSANE","081022/011996/011953/081024/081235/081018/081023/081014")
			Aviso("Aten็ใo","Este pedido cont้m itens que s๓ podem ser transportados pela EMOVERE. Nใo serแ permitido alterar a transportadora.",{"Ok"},1)
			lRet := .F.
			Exit
		EndIf
		QRYSC6->(dbSkip())
	EndDo
	QRYSC6->(dbCloseArea())
EndIf

If lRet .And. cTpFrete$"C/F"
	SC5->(dbSetOrder(1))
	If SC5->(dbSeek(xFilial("SC5")+cPedido))
		If Empty(SC5->C5_XCIFSN) .And. u_VldCifRev(SC5->C5_NUM,"SC5") 
			ZZB->(dbSetOrder(1))
			If ZZB->(dbSeek(xFilial("ZZB")+SC5->C5_ESTE)) .And. ZZB->ZZB_PERC>0 
				Aviso("Aten็ใo","Op็ใo de alterar dados do frete desabilitada para este pedido",{"Ok"},1)
				lRet := .F.
			EndIf
		EndIf
	EndIf
EndIf

RestArea(aAreaSC5)
RestArea(aArea)	

Return lRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณM460NUM   บAutor  ณMicrosiga           บ Data ณ  09/25/14   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function DipRetNum()
Local cSQL 	  := ""
Local cEnd 	  := CHR(10)+CHR(13)
Local cMsgCic := ""

cSQL := " SELECT "
cSQL += " 	MAX(NUM) NUM "
cSQL += " 	FROM (	SELECT "
cSQL += " 				MAX(F2_DOC) NUM "
cSQL += " 				FROM "
cSQL += 					RetSQLName("SF2")
cSQL += " 					WHERE "
cSQL += " 						F2_FILIAL  = '"+xFilial("SF2")+"' AND "
cSQL += " 						F2_SERIE   = '"+cSerie+"' "
cSQL += " 			UNION "
cSQL += " 			SELECT "
cSQL += " 				MAX(F1_DOC) NUM "
cSQL += " 				FROM "
cSQL += 					RetSQLName("SF1")
cSQL += " 					WHERE "
cSQL += " 						F1_FILIAL = '"+xFilial("SF1")+"' AND "
cSQL += " 						F1_SERIE  = '"+cSerie+"' AND "
cSQL += " 						F1_FORMUL = 'S') TOTCOL "

cSQL := ChangeQuery(cSQL)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),"QRYNUM",.T.,.T.)

If !QRYNUM->(Eof()) .And. cNumero <> SOMA1(QRYNUM->NUM)
	cMsgCic += "NUMERO DA NF ALTERADO AUTOMATICAMENTE"+cEnd
	cMsgCic += "DE: "+cNumero+" PARA: "+SOMA1(QRYNUM->NUM)+cEnd
	cMsgCic += "Usuแrio: "+U_DipUsr()
	
	cNumero := SOMA1(QRYNUM->NUM)
	
	/*SX5->(DbSetOrder(1))
	If SX5->(DbSeek(xFilial("SX5")+"01"+cSerie)) 
		SX5->(RecLock("SX5",.F.))
			SX5->X5_DESCRI  := Soma1(cNumero)
			SX5->X5_DESCSPA := Soma1(cNumero)
			SX5->X5_DESCENG := Soma1(cNumero)
		SX5->(MsUnLock())
	EndIf*/  
	
	U_DIPCIC(cMsgCic,"DIEGO.DOMINGOS,MAXIMO.CANUTO")
EndIf
QRYNUM->(dbCloseArea())			

Return 

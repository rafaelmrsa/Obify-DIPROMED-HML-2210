#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "TBICONN.CH"
#DEFINE EXPIRADO                '0'   // Prazo para particiapr expirado
#DEFINE FINANCEIRO              '1'   // Foi informado dados basicos do Edital e o Cliente ๑ ้ "A" - Aguar Financeiro
#DEFINE DADOS_LICITACAO         '2'   // Cliente "A" ou jแ aprovado pelo Financeiro, Licita็ใo vai completar as informa็๕es
#DEFINE DIRETOR_COMERCIAL       '3'   // O Diretor Comercial estแ avaliando
#DEFINE GARANTIAS               '4'   // Aguarando ser informadas as garantias solicitadas pelo Dir Comercial
#DEFINE PRECOS_PRA_CONCORRER    '5'   // Aguardando informar pre็os a serem preticados no processo
#DEFINE RESULTADO               '6'   // Todos os dados foram informado, esta aguardando o resultado da Licita็ใo
#DEFINE EMPENHO                 '7'   // Aguardando empenho para Gerar o Pedido de vendas no SC5 e SC6
#DEFINE CONCLUIDO               '8'   // Todos os empenho foram cumpridos e todos os pedido gerados
#DEFINE NAO_PARTICIPAR          '9'   // A Dipromed nใo vai participar deste processo
#DEFINE CR    chr(13)+chr(10)         // Carreage Return (Fim de Linha)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณM410STTS  บAutor  ณAlexandro Meier     บ Data ณ  29/03/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณPonto de entrada onde na exclusao de um pedido,             บฑฑ
ฑฑบ          ณlimpa o campo UA1_PEDIDO ref. ao pedido excluido            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
//*---------------------------------------*
 User Function M410STTS()
//*---------------------------------------*
Local cMsg		  := ""
Local aArea 	  := GetArea()
Local aAreaSC5    := SC5->(GetArea())
Local aAreaSC6    := SC6->(GetArea())
Local aAreaSC9    := SC9->(GetArea())
Local aBoxParam   := {}
Local aRetParam   := {}
Local aSize       := {}
Local aInfo       := {}
Local aObjects    := {}
Local aPosObj     := {}
Local aSaldo      := {}
Local oDlg
Local oSaldo
Local cSaldo
Local cParcial    := ""
Local cExplBloq   := CriaVar("C5_EXPLBLO")
Local lSaida      := .F.
Local _lTravouB2
Local _cProErroSb2:= ""
Local _cFrom      := ""
Local _cEmail     := ""
Local _cAssunto   := ""
Local _cFuncSent  := "M410STTS.PRW"
Local _aMsg       := {}
Local _aAux       := U_MTA410T(.F.)
Local _lContinua  := .T.
Local nVlrPedCE   := 0
Local _cRiscoDCic := ""   
Local _aMsgRiscoD := {}                                                     
Local _cAssRiscoD := ""                                                                                                                   
Local _cFroRiscoD :=  "protheus@dipromed.com.br"
Local _cRiscoDest := GetNewPar("ES_CICRISD","MAXIMO.CANUTO")    //GetNewPar("ES_CICRISD","ANA.PEREIRA,LUCIANA.MATIAZZO,MAXIMO.CANUTO")    
Local _cRiscoDmail:= GetNewPar("ES_MAIRISD","luciana.matiazzo@dipromed.com.br;"+SUPERGETMV("MV_#EMLTI",.F.,"ti@dipromed.com.br")) 
Local cPedLog	  := ""     
Local nVlrZZB	  := 0
Local nVlrCons    := 0
Local cGPRCXF     := ""
Local nX
Local nI
Private _aMsgCIC  := {}
Private _lMsgCIC  := .F.
Private _lNeedCorrect
Private _InvalidTES
//e-mail icms interestadual
private cEmailIc      := " "
private cAssuntoIc    := " "
private cAttachIc     := "  "
private cDeIc         := "  "
private cFuncSentIc   := " "
Private cChave        := " "
Private cMsgDecr      := " "
Private cNomeDes      := " "
Private cValStatFrete := " "
Private cValResult    := " "
Private _cRetorno     := " "
Private cMSGcIC       := " "
Private cuserid       := U_DipUsr()
Private cPedido       := " "
Private nVlrPed       := 0
Private cTipFret      := " "
Private nPorcFrete    := GetMv("ES_DIPV4_2")
Private nValfrete     := 0
Private _lDigital     := .F.
Public  _aMsgIc       := { }
Private nICMSCE       := GetNewPar("ES_ICMSCE",0) 
Private _nValor       := 0
Private nPosQtd       := aScan(aHeader, { |x| Alltrim(x[2]) == "C6_QTDVEN" })
Private nPosNF        := aScan(aHeader, { |x| Alltrim(x[2]) == "C6_NOTA" })
Private lNDelSaldo    := .F.

//************************************************

For nX := 1 To len(aCols)
	If aCols[nX,nPosQtd] > 0 .And.  Empty(aCols[nX,nPosNF]) .And. ! Acols[nX,Len(aHeader)+1]
		lNDelSaldo := .T.
	EndIf
Next nX


If ISINCALLSTACK("LOJA901A") .Or. ISINCALLSTACK("LOJA901")
	Return .T.
EndIf


If "MATA310"$Upper(FunName())
	Return .T.
EndIf

If len(_aAux)>0 .and. ValType(_aAux[1]) == "N"  // JBS 26/05/2010 - Consistencia para testar se a array esta preenchida antes de usa-la
	SC5->(DbGoto(_aAux[1]))
	_lContinua := SC5->(!Eof())   
	cPedLog := SC5->C5_NUM
Else
	_lContinua := .F.
EndIf


If _lContinua
	_lContinua := ValidCod(SC5->C5_NUM)
EndIf

_lContinua := _lContinua .And. 	(INCLUI .Or. ALTERA)
	
U_DIPPROC(ProcName(0),U_DipUsr()) // MCVN - 22/01/2009                                                                

If _lContinua .And. !("DIPAL10" $ FunName()) .And. SC5->C5_TIPODIP=="1" .And. SC5->C5_TIPO == "N"
	_lContinua := DipVldPV(SC5->C5_NUM)
EndIf
  
If _lContinua .And. !(SC5->C5_TIPO$"D/B")
	SA1->(dbSetOrder(1))
	If SA1->(dbSeek(xFilial("SA1")+SC5->(C5_CLIENTE+C5_LOJACLI)))   
		/*
		If cEmpAnt=="01" .And. _lContinua .And. SC5->C5_TIPODIP=="1" .And. SC5->C5_TIPO == "N" .And. !("DIPAL10" $ FunName()) .And. !SA1->A1_GRPVEN$GetNewPar("ES_GRPFUNC","000171")
			_lDigital := u_VldAprDig()
		EndIf
		*/
	Else
		Aviso("Aten็ใo","Cliente nใo encontrado no cadastro. Tente novamente.",{"Ok"},1)
		_lContinua := .F.
	EndIf
EndIf		
	
If _lContinua .And.  !(SC5->C5_TIPO$"D/B") .And. !("DIPAL10" $ FunName()) .And. !u_VldCifRev(SC5->C5_NUM,"SC5") .And. !U_AmostrasHQ()	
	
	IF  !u_VldProFrt(SC5->C5_NUM,"SC5") //Rafael Moraes Rosa - 24/03/2023
		cParcial:= "N"
		cExplBloq:= "Pedido bloqueado pelo sistema, nใo ้ permitido o frete CIF para Revendedor na regiใo informada."
		
		SC5->(RecLock("SC5",.F.))
			SC5->C5_PARCIAL := Iif(Empty(SC5->C5_TRANSP),'N',cParcial)
			SC5->C5_EXPLBLO := Iif(Empty(SC5->C5_TRANSP),'Tipo de frete incompatํvel com o tipo de cliente.............',cExplBloq)
			SC5->C5_PRENOTA := Iif(Empty(SC5->C5_TRANSP),'O',IIf(cParcial == "N","O",Iif(SC5->C5_PRENOTA=='F',SC5->C5_PRENOTA,cParcial)))
			SC5->C5_XBLQAUT := "S"
		SC5->(MsUnLock())
		SC5->(DbCommit())
		
		_lContinua := .F.
		MsgBox("Pedido Ficara Bloqueado. Nใo ้ permitido liberar frete CIF para cliente Revendedor na regiใo informada.","ES_CCIFREV,ES_CIFREV2,ES_CIFREV3","INFO")
	ENDIF
EndIf

If _lContinua .And. !(SC5->C5_TIPO$"D/B") .And. !("DIPAL10" $ FunName()) .And. SC5->C5_TPFRETE="C" .And. SC5->C5_CLIENTE$GetNewPar("ES_CBLQCIF","020351") .And. !u_DipVPerCIF()
	cParcial:= "N"
	cExplBloq:= "Pedido bloqueado pelo sistema. Valor de CIF ultrapassa o permitido."
	
	SC5->(RecLock("SC5",.F.))
		SC5->C5_PARCIAL := Iif(Empty(SC5->C5_TRANSP),'N',cParcial)
		SC5->C5_EXPLBLO := Iif(Empty(SC5->C5_TRANSP),'Valor de CIF ultrapassa o permitido..............',cExplBloq)
		SC5->C5_PRENOTA := Iif(Empty(SC5->C5_TRANSP),'O',IIf(cParcial == "N","O",Iif(SC5->C5_PRENOTA=='F',SC5->C5_PRENOTA,cParcial)))
		SC5->C5_XBLQAUT := "S"
	SC5->(MsUnLock())
	SC5->(DbCommit())
	
	_lContinua := .F.
	MsgBox("Pedido Ficara Bloqueado. "+CHR(10)+CHR(13)+"Frete CIF nใo autorizado. "+CHR(10)+CHR(13)+"Valor ultrapassa o percentual permitido.","ES_CBLQCIF","INFO")
EndIf

If _lContinua .And.  !(SC5->C5_TIPO$"D/B") .And. !("DIPAL10" $ FunName()) .And. u_VldConPen(SC5->C5_NUM)	

	SC5->(RecLock("SC5",.F.))
		SC5->C5_PARCIAL := "N"
		SC5->C5_EXPLBLO := "Pedido bloqueado pelo sistema. Esse pedido possui itens de contrato (valor negociado) que ainda nใo foram aprovados."
		SC5->C5_PRENOTA := "O"
		SC5->C5_XBLQAUT := "S"
	SC5->(MsUnLock())
	SC5->(DbCommit())
	
	_lContinua := .F.
	MsgBox("Pedido Ficara Bloqueado. Esse pedido possui itens de contrato (valor negociado) que ainda nใo foram aprovados. Falar com o aprovador","Valor Negociado","INFO")
EndIf


If _lContinua .And.  !(SC5->C5_TIPO$"D/B") .And. !("DIPAL10" $ FunName()) .And.; 
	SC5->C5_TPFRETE=="C" .And. SC5->C5_ESTE$GetNewPar("ES_UFBLCIF","PA/RO") .And. !SC5->C5_NUM$GetNewPar("ES_UFLICIF","") 
	SU7->(dbSetOrder(1))
	If SU7->(dbSeek(xFilial("SU7")+SC5->C5_OPERADO)) .And. SU7->U7_POSTO == "02"
		cParcial:= "N"
		cExplBloq:= "Pedido bloqueado pelo sistema, CIF nใo permitido para esta UF."
		
		SC5->(RecLock("SC5",.F.))
			SC5->C5_PARCIAL := Iif(Empty(SC5->C5_TRANSP),'N',cParcial)
			SC5->C5_EXPLBLO := Iif(Empty(SC5->C5_TRANSP),'CIF nใo permitido para esta UF.........................',cExplBloq)
			SC5->C5_PRENOTA := Iif(Empty(SC5->C5_TRANSP),'O',IIf(cParcial == "N","O",Iif(SC5->C5_PRENOTA=='F',SC5->C5_PRENOTA,cParcial)))
			SC5->C5_XBLQAUT := "S"
		SC5->(MsUnLock())
		SC5->(DbCommit())
		
		_lContinua := .F.
		MsgBox( "Pedido ficarแ bloqueado."+CHR(13)+CHR(10)+"CIF nใo permitido para esta UF ("+SC5->C5_ESTE+").","ES_UFBLCIF","INFO")
	EndIf
EndIf   

If _lContinua .And.  !(SC5->C5_TIPO$"D/B") .And. !("DIPAL10" $ FunName()) .And. SC5->C5_TPFRETE = "C" .And. SC5->C5_TRANSP <> "100000" .And.;
	SC5->C5_TIPODIP = "1" .And. !SC5->C5_NUM$GetNewPar("ES_AVLRCIF","") .And. u_DipAtuEst(SC5->C5_NUM) .And. !DipVldMin(SC5->C5_NUM,SC5->C5_ESTE,@nVlrZZB,@nVlrCons)
	SU7->(dbSetOrder(1))
	If SU7->(dbSeek(xFilial("SU7")+SC5->C5_OPERADO)) .And. SU7->U7_POSTO == "02" .And. !u_DipVPerCIF() .And. !U_AmostrasHQ()  .And.;
	(cEmpAnt == "01" .Or. (cEmpAnt == "04" .And. !(SA1->A1_GRPVEN $ GetNewPar("ES_GRPCLH","000007/000010/000021/000175"))))  
		cParcial:= "N"
		cExplBloq:= "Pedido bloqueado pelo sistema, valor mํnimo para frete CIF nใo atingido."
		
		SC5->(RecLock("SC5",.F.))
			SC5->C5_PARCIAL := Iif(Empty(SC5->C5_TRANSP),'N',cParcial)
			SC5->C5_EXPLBLO := Iif(Empty(SC5->C5_TRANSP),'Valor mํnimo para frete CIF nใo atingido.............',cExplBloq)
			SC5->C5_PRENOTA := Iif(Empty(SC5->C5_TRANSP),'O',IIf(cParcial == "N","O",Iif(SC5->C5_PRENOTA=='F',SC5->C5_PRENOTA,cParcial)))
			SC5->C5_XBLQAUT := "S"
		SC5->(MsUnLock())
		SC5->(DbCommit())
		
		_lContinua := .F.
		MsgBox( "Pedido ficarแ bloqueado."+CHR(13)+CHR(10)+;
				"Valor mํnimo (R$ "+AllTrim(TransForm(nVlrZZB,"@E 999,999,999.99"))+") de frete CIF para "+SC5->C5_ESTE+" nใo foi atingido."+CHR(13)+CHR(10)+;
				"Valor do pedido considerado para o cแlculo: R$ "+AllTrim(TransForm(nVlrCons,"@E 999,999,999.99"))+"."+CHR(13)+CHR(10)+;
				"Se houver diferen็a entre o valor considerado e o valor do pedido, verifique se existem produtos em saldo.","ES_AVLRCIF","INFO")
	EndIf
EndIf   

If _lContinua .And.  !(SC5->C5_TIPO$"D/B") .And. !("DIPAL10" $ FunName()) .And. SC5->C5_TPFRETE = "C" .And.	SC5->C5_TIPODIP = "1" .And. u_DipAtuEst(SC5->C5_NUM) 
	_nVlrMinCIF := u_DipVlrReal(SC5->C5_NUM)
	If _nVlrMinCIF < SA1->A1_XMINCIF
		SU7->(dbSetOrder(1))
		If SU7->(dbSeek(xFilial("SU7")+SC5->C5_OPERADO)) .And. SU7->U7_POSTO == "02"
			cParcial:= "N"
			cExplBloq:= "Pedido bloqueado pelo sistema, valor mํnimo para frete CIF nใo atingido para este cliente."
			
			SC5->(RecLock("SC5",.F.))
				SC5->C5_PARCIAL := Iif(Empty(SC5->C5_TRANSP),'N',cParcial)
				SC5->C5_EXPLBLO := Iif(Empty(SC5->C5_TRANSP),'Valor mํnimo para frete CIF nใo atingido.............',cExplBloq)
				SC5->C5_PRENOTA := Iif(Empty(SC5->C5_TRANSP),'O',IIf(cParcial == "N","O",Iif(SC5->C5_PRENOTA=='F',SC5->C5_PRENOTA,cParcial)))
				SC5->C5_XBLQAUT := "S"
			SC5->(MsUnLock())
			SC5->(DbCommit())
			
			_lContinua := .F.
			MsgBox( "Pedido ficarแ bloqueado."+CHR(13)+CHR(10)+;
					"Valor mํnimo (R$ "+AllTrim(TransForm(SA1->A1_XMINCIF,"@E 999,999,999.99"))+") de frete CIF para este cliente nใo foi atingido."+CHR(13)+CHR(10)+;
					"Valor do pedido considerado para o cแlculo: R$ "+AllTrim(TransForm(_nVlrMinCIF,"@E 999,999,999.99"))+"."+CHR(13)+CHR(10)+;
					"Se houver diferen็a entre o valor considerado e o valor do pedido, verifique se existem produtos em saldo.","Aten็ใo","INFO")
		EndIf
	EndIf
EndIf

//Giovani Zago 23/01/2012 ajuste para bloquear cliente tipo revendedor sem inscri็ใo estadual
If _lContinua   .And. !("DIPAL10" $ FunName())  .And. SA1->A1_TIPO = "R"  .And.;  
	Empty(SA1->A1_INSCR) .And. !(SC5->C5_TIPODIP $ '2/3') .And. !(SC5->C5_TIPO $ 'D/B') .And. SA1->A1_TPJ <> '3'
	
	cParcial := "N"
	cExplBloq:= "Pedido bloqueado pelo sistema, cliente nao possui I.E. preenchido."
	
	SC5->(RecLock("SC5",.F.))
		SC5->C5_PARCIAL := Iif(Empty(SC5->C5_TRANSP),'N',cParcial)
		SC5->C5_EXPLBLO := Iif(Empty(SC5->C5_TRANSP),'Pedido com o campo de transportadora vazio.............',cExplBloq)
		SC5->C5_PRENOTA := Iif(Empty(SC5->C5_TRANSP),'O',IIf(cParcial == "N","O",Iif(SC5->C5_PRENOTA=='F',SC5->C5_PRENOTA,cParcial)))
		SC5->C5_XBLQAUT := "S"
	SC5->(MsUnLock())
	SC5->(DbCommit())
	
	_lContinua := .F.
	MsgBox("Pedido Ficara Bloqueado Devido o Cliente ser Revendedor e nใo Possuir Inscri็ใo Estadual, Por Favor Arrume Cadastro do Cliente !!","Informacao!","INFO")
EndIf
//***********************************************************************************************

SU7->(dbSetorder(1))	     
If SU7->(dbSeek(xFilial("SU7")+SC5->C5_OPERADO))	
	//Maximo Canuto 19/08/2013 ajuste para bloquear cliente com risco D
	/*If _lContinua   .And. !("DIPAL10" $ FunName()).And. SA1->A1_RISCO = "D" .And. !(SC5->C5_TIPODIP $ '2/3') .And. !(SC5->C5_TIPO $ 'D/B')
		
		cParcial:= "N"
		cExplBloq:= "Pedido bloqueado pelo sistema, cliente com risco D (Inativo)."
		
		SC5->(RecLock("SC5",.F.))
			SC5->C5_PARCIAL := Iif(Empty(SC5->C5_TRANSP),'N',cParcial)
			SC5->C5_EXPLBLO := Iif(Empty(SC5->C5_TRANSP),'Pedido com o campo de transportadora vazio.............',cExplBloq)
			SC5->C5_PRENOTA := Iif(Empty(SC5->C5_TRANSP),'O',IIf(cParcial == "N","O",Iif(SC5->C5_PRENOTA=='F',SC5->C5_PRENOTA,cParcial)))
			SC5->C5_XBLQAUT := "S"
		SC5->(MsUnLock())
		SC5->(DbCommit())
		
		_lContinua := .F.      
		                                                  	    			
	    //Enviando Cic para Financeiro
		_cRiscoDCic := "AVISO IMPORTANTE - PEDIDO DE CLIENTE COM RISCO D (INATIVO)"+CR + CR
		_cRiscoDCic += "Pedido bloqueado pois o cliente tem risco D (Inativo) - Cliente: " +SC5->C5_CLIENTE+CR+CR
		_cRiscoDCic += "Pedido: " +C5_NUM+CR + CR							
		_cRiscoDCic +=CR + "Usuario: "+Upper(U_DipUsr())
		U_DIPCIC(_cRiscoDCic,_cRiscoDest)//envia cic	    			
		
		//Enviando e-mail para Financeiro   
		_cAssRiscoD:= "AVISO IMPORTANTE - PEDIDO DE CLIENTE COM RISCO D (INATIVO)
		Aadd( _aMsgRiscoD , { "Numero Pedido: "  	, SC5->C5_NUM } )
		Aadd( _aMsgRiscoD , { "Operador: "          , SC5->C5_OPERADO  +" - "+ Upper(Alltrim(SU7->U7_NOME)) } )
		Aadd( _aMsgRiscoD , { "Cliente:  "          , SC5->C5_CLIENTE  +" - "+ AllTrim(SA1->A1_NOME) } )
		Aadd( _aMsgRiscoD , { "Usuแrio: "           , U_DipUsr() } )			
		U_UEnvMail(_cRiscoDmail,_cAssRiscoD,_aMsgRiscoD,"",_cFroRiscoD,_cFuncSent)       
	
		MsgBox("Pedido Ficara Bloqueado Devido o Cliente ter risco D (Inativo), Por Favor solicite a avalia็ใo do cliente ao financeiro  !!","Informacao!","INFO")
	EndIf*/
Else 
	Aviso("Aten็ใo","Operador nใo encontrado no cadastro",{"Ok"},1)
	_lContinua := .F. 
EndIf
//***********************************************************************************************

aRet := {}
If _lContinua .And. cEmpAnt+cFilAnt == "0101" .And. (SA1->A1_TIPO == "R" .Or. !Empty(SA1->A1_INSCR)) 
	If GetNewPar("ES_VLDANVI",.F.)
		aRet := u_DipTemAnv()
	Else 
		aRet := {.T.,{""}}
	EndIf
	If Len(aRet)>0
		If !aRet[1]	          
		    
		    cCampos := ""
		    For nI:=1 To Len(aRet[2])
		    	cCampos += " * "+ AvSx3(aRet[2,nI],5)+" ("+aRet[2,nI]+") "+CHR(10)+CHR(13)
			Next nI
		       
			cExplBloq:= "Pedido bloqueado pelo sistema, campo vazio no cadastro do cliente"
			
			SC5->(RecLock("SC5",.F.))
				SC5->C5_PARCIAL := "N"
				SC5->C5_EXPLBLO := cExplBloq
				SC5->C5_PRENOTA := "O"
				SC5->C5_XBLQAUT := "S"
			SC5->(MsUnLock())
			SC5->(DbCommit())
			
			Aviso("Aten็ใo","O pedido ficarแ bloqueado. "+CHR(10)+CHR(13)+;
							"Para liberar preencha o(s) campo(s) no cadastro do cliente:"+CHR(10)+CHR(13)+;
							cCampos,{"Ok"},3)
			
			_lContinua := .F.
		EndIf
	EndIf
EndIf

If _lContinua
	
	_lTravouB2		:= _aAux[2]
	_lNeedCorrect	:= _aAux[3]
	_InvalidTES		:= _aAux[4]
	aSaldo			:= _aAux[5]
	
/* Alterada a chamado da fun็ใo a partir do MTA410	
	// RBorges 08/02/2019 - Mostrar uma tela de transfer๊ncia com os produtos solicitados
	If cEmpAnt == '01'.And. SC5->C5_TIPODIP == "1"
	 	If cEmpAnt+cFilAnt == '0101'
	 		U_TRANSFE(SC5->C5_NUM,'1')
		Else
	 		U_TRANSFE(SC5->C5_NUM,'2')	
		EndIf
	EndIf	
*/	
	If Len(aSaldo) > 0 .And. SC5->C5_TIPODIP <> '2' .And. SC5->C5_TIPODIP <> '3'
		
		If Len(_aAux[6]) > 0
			
			_cFrom   := Lower(Alltrim(SU7->U7_EMAIL))
			_cEmail  := "maximo@dipromed.com.br"
			aAdd( _aMsg , { "Numero Pedido: "    , SC5->C5_NUM } )
			aAdd( _aMsg , { "Operador: "         , SC5->C5_OPERADO } )
			aEval(_aAux[6],{|x| aAdd(_aMsg,aClone(x)) })
			
			If _lTravouB2
				_cAssunto:= "Pedido "+SC5->C5_NUM+ " com erro de SB2!"
				Aviso("Atencao","Nใo foi possivel corrigir o erro. O pedido ficara bloqueado! Favor avisar o CPD",{"Ok"} )
			Else
				_cAssunto:= "Informativo - Corrigido o erro de bloqueio de SB2 do pedido "+SC5->C5_NUM+"!"
			Endif
			
			U_UEnvMail(_cEmail,_cAssunto,_aMsg,"",_cFrom,_cFuncSent) 	// Envia e-mail
			
		EndIf
		
		If !("DIPAL10" $ FunName()) .And. !_lNeedCorrect .And. !_InvalidTES .And. !(SC5->C5_LIBEROK = '' .And. SC5->C5_TIPODIP == '1') // MCVN - 05/06/2007
			/*
			If _lDigital
				Aviso("Aten็ใo",'Pedido necessita de aprova็ใo digital, a op็ใo de "liberar" o pedido foi desabilitada.',{"Ok"},1)
			EndIf                                                                                                                             
			*/
			aSize    := {0,0,316,155,700,350,136}  //   MCVN 02/03/07
			aInfo    := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ] , 1, 1 }
			
			aAdd( aObjects, { 100, 085, .T., .T., .T.} )
			aAdd( aObjects, { 100, 015, .T., .T., .T.} )
			aPosObj := MsObjSize( aInfo, aObjects , .T. )
			
			While !lSaida
				
				DEFINE MSDIALOG oDlg TITLE OemToAnsi("Pedido: " + SC5->C5_NUM + " - Produtos com Saldo.") FROM 0,0 TO aSize[6],aSize[5]  OF oMainWnd PIXEL
				@ aPosObj[1,1],aPosObj[1,2] LISTBOX oSaldo VAR cSaldo FIELDS ;
				HEADER  	"Item",;
				"Produto",;
				"Descricao",;
				"Qtd.Vendida",;
				"Qtd.Liberada",;
				"Saldo",;
				"Estoque",;
				SIZE aPosObj[1,3],aPosObj[1,4] NOSCROLL OF oDlg PIXEL
				
				oSaldo:Align:= CONTROL_ALIGN_ALLCLIENT
				oSaldo:SetArray(aSaldo)
				oSaldo:bLine := { || {	aSaldo[oSaldo:nAT,1] 	,;
				aSaldo[oSaldo:nAT,2]	,;
				aSaldo[oSaldo:nAT,3]	,;
				Transform(aSaldo[oSaldo:nAT,4],"@E 999999999")	,;
				Transform(aSaldo[oSaldo:nAT,5],"@E 999999999")	,;
				Transform(aSaldo[oSaldo:nAT,6],"@E 999999999")	,;
				Transform(aSaldo[oSaldo:nAT,7],"@E 999999999")}}
				
				
				oScro1 := TScrollBox():New( oDlg, aPosObj[2,1], aPosObj[2,2],aPosObj[2,4], aPosObj[2,3], .T., .T., .T.)
				oScro1:Align:= CONTROL_ALIGN_BOTTOM
				
				If !_lTravouB2             
					//If !_lDigital
						@ 04,010  BUTTON "Liberar" 		SIZE 45,12 ACTION (cParcial:= "",oDlg:End(),lSaida:= .T.) OF oScro1 PIXEL
					//EndIf
					@ 04,070  BUTTON "Bloquear" 	SIZE 45,12 ACTION (cParcial:= "N",oDlg:End(),lSaida:= .T.) OF oScro1 PIXEL
					If SC5->C5_PRENOTA == "F"
						@ 04,150 SAY "Este pedido ficara parado no financeiro" SIZE 100,12 COLOR CLR_HRED  OF oScro1 PIXEL
					EndIf
				Else
					@ 04,030 BUTTON "Sair" 	SIZE 45,13 ACTION (cParcial:= "N",oDlg:End(),lSaida:= .T.) OF oScro1 PIXEL
					@ 04,080 SAY "Este pedido ficara Bloqueado. Altere-o para conseguir Reserva!" SIZE 250,14 COLOR CLR_HRED  OF oScro1 PIXEL
				EndIf
				
				ACTIVATE MSDIALOG oDlg CENTERED
				
				If Empty(cParcial) .And. lSaida
					If Aviso("Aten็ใo","Voc๊ estแ liberando um pedido com itens em SALDO."+CHR(13)+CHR(10)+"Os itens em saldo nใo serใo faturados.",{"Cancela","Continua"},1)<>2 
						Aviso("Aten็ใo","Utilize a op็ใo Bloquear.",{"Ok"},1)
						lSaida := .F.
					EndIf
				EndIf
			End
		Else
			
			If _lNeedCorrect
				Aviso("Atencao","Este pedido ficara Bloqueado. Favor corrigir 2ช Descr, 2ช UM e/ou Fator de conv, ou altera o cliente!!",{"Ok"} )
			ElseIf _InvalidTES
				Aviso("Atencao","EXISTEM PRODUTOS STARI PACKS NO PEDIDO ou Este pedido ficara Bloqueado. Existe(m)  TES(s)  invแlida(s) .  Entre novamente no pedido e verifique a(s) TES(s)!!",{"Ok"} )
			ElseIf SC5->C5_LIBEROK = ''.And. SC5->C5_TIPODIP == '1'
				Aviso("Atencao","Este pedido ficara Bloqueado. Existem erros na reserva de produtos.  Entre novamente no pedido e verifique a(s) TES(s)!!",{"Ok"} )
			Endif
			
			cParcial:= "N"
			lSaida:= .T.
			
		EndIf
		
	ElseIf SC5->C5_TIPODIP <> '2' .And. SC5->C5_TIPODIP <> '3'
		
		
		If !("DIPAL10" $ FunName()) .And. !_lNeedCorrect .And. !_InvalidTES .And. !(SC5->C5_LIBEROK = '' .And. SC5->C5_TIPODIP == '1')  // MCVN - 05/06/2007
			
			If (Aviso("Pedido " + SC5->C5_NUM,IIf(SC5->C5_PRENOTA == "F",CHR(10)+CHR(13)+"Este pedido ficara parado no financeiro. "+CHR(10)+CHR(13)+CHR(10)+CHR(13),"")+"Deseja Bloquear ou Liberar ?",{"Liberar","Bloquear"}) == 1)
				cParcial:= ""
			Else
				cParcial:= "N"
			EndIf
		Else          
			
			If _lNeedCorrect
				Aviso("Atencao","Este pedido ficara Bloqueado. Favor corrigir 2ช Descr, 2ช UM e/ou Fator de conv, ou altera o cliente!!",{"Ok"} )
			ElseIf _InvalidTES
				Aviso("Atencao","Este pedido ficarแ Bloqueado. Existe(m)  TES(s)  invแlida(s).  Entre novamente no pedido e verifique a(s) TES(s)!!",{"Ok"} )
			ElseIf SC5->C5_LIBEROK = ''.And. SC5->C5_TIPODIP == '1'
				Aviso("Atencao","Este pedido ficara Bloqueado. Existem erros na reserva de produtos.  Entre novamente no pedido e verifique a(s) TES(s)!!",{"Ok"} )
			//ElseIf _lDigital
			//	Aviso("Aten็ใo","Este pedido ficarแ Bloqueado. O pedido necessita de aprova็ใo digital",{"Ok"},1)
			Endif
			cParcial:= "N"
			
		EndIf
	EndIf

	If (cEmpAnt == "01" .Or. (cEmpAnt == "04" .And. !(SA1->A1_GRPVEN $ GetNewPar("ES_GRPCLH","000007/000010/000021/000175")))) .And. Empty(SC5->C5_PEDECOM) 
		If Empty(cParcial) .And. cEmpAnt $ "01/04" .And. _lContinua .And. SC5->C5_TIPODIP=="1" .And. SC5->C5_TIPO == "N" .And. !("DIPAL10" $ FunName()) //.And. !SA1->A1_GRPVEN$GetNewPar("ES_GRPFUNC","000171") Retirada em 08/06/17 e-mail Erich e Patrํcia
			_lDigital := U_DIPDIG01(_aAux[5],cExplBloq)          
			/*
			If cParcial=="" .And. !_lDigital
				cParcial := "N"
			EndIf
			_lContinua := _lDigital .And.(INCLUI .Or. ALTERA)
			*/                                               
			_lContinua := _lDigital .And.(INCLUI .Or. ALTERA)
			If !_lContinua
				cParcial := "N"
				Aviso("Aten็ใo","Este pedido ficarแ Bloqueado. O pedido necessita de aprova็ใo digital",{"Ok"},1)
			EndIf
		EndIf
	EndIf
		
	//Maximo Canuto 19/08/2013 ajuste para bloquear cliente com risco D - Ajustado em 24/11/21
	If _lContinua   .And. !("DIPAL10" $ FunName()).And. SA1->A1_RISCO = "D" .And. !(SC5->C5_TIPODIP $ '2/3') .And. !(SC5->C5_TIPO $ 'D/B')
		
		cParcial:= "N"
		cExplBloq:= "Pedido bloqueado pelo sistema, cliente com risco D (Inativo)."
		
		SC5->(RecLock("SC5",.F.))
				SC5->C5_PARCIAL := cParcial
				SC5->C5_EXPLBLO := cExplBloq
				SC5->C5_PRENOTA := "O"
				SC5->C5_XBLQAUT := "S"
		SC5->(MsUnLock())
		SC5->(DbCommit())
		
		_lContinua := .F.      
		                                                  	    			
	    //Enviando Cic para Financeiro
		_cRiscoDCic := "AVISO IMPORTANTE - PEDIDO DE CLIENTE COM RISCO D (INATIVO)"+CR + CR
		_cRiscoDCic += "Pedido bloqueado pois o cliente tem risco D (Inativo) - Cliente: " +SC5->C5_CLIENTE+CR+CR
		_cRiscoDCic += "Pedido: " +C5_NUM+CR + CR							
		_cRiscoDCic +=CR + "Usuario: "+Upper(U_DipUsr())
		U_DIPCIC(_cRiscoDCic,_cRiscoDest)//envia cic	    			
		
		//Enviando e-mail para Financeiro   
		_cAssRiscoD:= "AVISO IMPORTANTE - PEDIDO DE CLIENTE COM RISCO D (INATIVO)
		Aadd( _aMsgRiscoD , { "Numero Pedido: "  	, SC5->C5_NUM } )
		Aadd( _aMsgRiscoD , { "Operador: "          , SC5->C5_OPERADO  +" - "+ Upper(Alltrim(SU7->U7_NOME)) } )
		Aadd( _aMsgRiscoD , { "Cliente:  "          , SC5->C5_CLIENTE  +" - "+ AllTrim(SA1->A1_NOME) } )
		Aadd( _aMsgRiscoD , { "Usuแrio: "           , U_DipUsr() } )			
		U_UEnvMail(_cRiscoDmail,_cAssRiscoD,_aMsgRiscoD,"",_cFroRiscoD,_cFuncSent)       
	
		MsgBox("Pedido Ficara Bloqueado Devido o Cliente ter risco D (Inativo), Por Favor solicite a avalia็ใo do cliente ao financeiro  !!","Informacao!","INFO")
	EndIf

	If (cParcial == "N")
		If Upper(U_DipUsr()) $ 'ERIBERTO/EELIAS'
			Aadd(aBoxParam,{1,"Motivo do Bloqueio","Eriberto - testando melhorias no Protheus.","","Len(AllTrim(MV_PAR01))>20","","",120,.T.})
		ElseIf _lTravouB2
			Aadd(aBoxParam,{1,"Motivo do Bloqueio","Pedido bloqueado por problemas na reserva, libere o pedido novamente.","","Len(AllTrim(MV_PAR01))>20","","",120,.T.})
		ElseIf _lNeedCorrect
			Aadd(aBoxParam,{1,"Motivo do Bloqueio","Pedido bloqueado por problemas com 2ช descri็ใo, 2ช UM ou Fator de Conversใo, solicite a corre็ใo ou Altere o Cliente para nใo utilizar a 2ช descri็ใo.","","Len(AllTrim(MV_PAR01))>20","","",120,.T.})
		ElseIf _InvalidTES
			Aadd(aBoxParam,{1,"Motivo do Bloqueio","Pedido bloqueado porque existe(m) TES(s) invแlida(s) .Favor corrigir o pedido.","","Len(AllTrim(MV_PAR01))>20","","",120,.T.})
		ElseIf SC5->C5_LIBEROK = ''.And. SC5->C5_TIPODIP == '1'
			Aadd(aBoxParam,{1,"Motivo do Bloqueio","Pedido bloqueado por problemas na reserva .Favor corrigir o pedido.","","Len(AllTrim(MV_PAR01))>20","","",120,.T.})
		Else
			Aadd(aBoxParam,{1,"Motivo do Bloqueio",SC5->C5_EXPLBLO,"@!","Len(AllTrim(MV_PAR01))>20","","",120,.T.})
		EndIf
		
		Do While .t.
			If ParamBox(aBoxParam,"Informe os Parametros",@aRetParam,,,,,,,,.F.)
				cExplBloq:= aRetParam[1]
			EndIf
			If Empty(cExplBloq)
				Loop
			Else
				Exit
			EndIf
		EndDo
	EndIf
	
EndIf

Begin Transaction

If _lContinua     
	
	If !(SC5->C5_TIPODIP $ '2/3')
		SC5->(RecLock("SC5",.F.))
			SC5->C5_PARCIAL := Iif(Empty(SC5->C5_TRANSP),'N',cParcial)
			SC5->C5_EXPLBLO := Iif(Empty(SC5->C5_TRANSP),'Pedido com o campo de transportadora vazio.............',cExplBloq)
			SC5->C5_PRENOTA := Iif(Empty(SC5->C5_TRANSP),'O',IIf(cParcial == "N","O",Iif(SC5->C5_PRENOTA=='F',SC5->C5_PRENOTA,cParcial)))
			SC5->C5_HORALIB := IIf(SC5->C5_PRENOTA == "F","",Time())
			//DATA DE EMISSรO REAL DO PEDIDO DE VENDA - 21/09/2009
			If SC5->C5_DTPEDID = CTOD("")
				SC5->C5_DTPEDID := DDATABASE
			Endif
		SC5->(MsUnLock())
		SC5->(DbCommit())
	Endif
	
	
	If cParcial <> "N"
		If !("DIPAL10" $ FunName())
			cValResult:=  U_ValFrete("FRETE")
			If !Empty(cValResult) .and. !(SC5->C5_TRANSP $ "000000/000111/000112/100000/000133")   .And. SC5->C5_TPFRETE $ "C/I"
				_aMsgIc := {}
				cMSGcIC := " "
				aAdd( _aMsgIc , { " EMPRESA"  , + Capital( AllTrim( GetAdvFVal( "SM0", "M0_NOME", cEmpAnt + cFilAnt, 1, "" ) ) )  } )
				cMSGcIC       := " EMPRESA:_______" + Capital( AllTrim( GetAdvFVal( "SM0", "M0_NOME", cEmpAnt + cFilAnt, 1, "" ) ) ) +"/"+ Capital( AllTrim( GetAdvFVal( "SM0", "M0_FILIAL" , cEmpAnt + cFilAnt, 1, "" ) ) )   + CR + CR
				//................1 2 3 4 5 6 7 8 9 0
				aAdd( _aMsgIc , { " FILIAL"   , + Capital( AllTrim( GetAdvFVal( "SM0", "M0_FILIAL" , cEmpAnt + cFilAnt, 1, "" ) ) ) } )
				//	cMSGcIC       += " FILIAL:___________" + Capital( AllTrim( GetAdvFVal( "SM0", "M0_FILIAL" , cEmpAnt + cFilAnt, 1, "" ) ) ) + CR+ CR
				//................1 2 3 4 5 6 7 8 9 0
				aAdd( _aMsgIc , { "PEDIDO"    ,+SC5->C5_NUM  } )
				cMSGcIC       += " PEDIDO:________"+SC5->C5_NUM +CR
				//................1 2 3 4 5 6 7 8 9 0
				aAdd( _aMsgIc , { "DATA"    , +dtoc(SC5->C5_EMISSAO) } )                      
				cMSGcIC       += " DATA:__________"+dtoc(SC5->C5_EMISSAO) +CR
				//................1 2 3 4 5 6 7 8 9 0
				aAdd( _aMsgIc , { "ESTADO"    , +SC5->C5_ESTE  } )
				cMSGcIC       += " ESTADO:_______"+SC5->C5_ESTE +CR
				//................1 2 3 4 5 6 7 8 9 0
				aAdd( _aMsgIc , { "MUNICIPIO"    , +SC5->C5_MUNE  } )
				cMSGcIC       += " MUNICIPIO:_____"+SC5->C5_MUNE +CR
				//................1 2 3 4 5 6 7 8 9 0
				aAdd( _aMsgIc , { "CEP."    , +SC5->C5_CEPE  } )
				cMSGcIC       += " CEP.:___________"+SC5->C5_CEPE +CR
				//................1 2 3 4 5 6 7 8 9 0
				aAdd( _aMsgIc , { "PESO"    , +cvaltochar(SC5->C5_PBRUTO)  } )
				cMSGcIC       += " PESO:__________"+cvaltochar(SC5->C5_PBRUTO) +CR
				//................1 2 3 4 5 6 7 8 9 0
				aAdd( _aMsgIc , { "OPERADOR"    ,""+SC5->C5_OPERADO+"-"+SU7->U7_NREDUZ })
				cMSGcIC       += " OPERADOR:_______"+SC5->C5_OPERADO+"-"+SU7->U7_NREDUZ +CR
				//................1 2 3 4 5 6 7 8 9 0
				If SC5->C5_TPFRETE = "C"             //giovani 21/07/11   tratamento para nao chamar u_dipricms se for frete incluso
					U_DIPRICMS(SC5->C5_NUM,0,cValResult)
					
					_cRetorno :=  U_RetFrete()
					
				ElseIf SC5->C5_TPFRETE = "I"
					nVlrped := ValorPedido(SC5->C5_NUM)
					aAdd( _aMsgIc , { "VALOR do PEDIDO"    , ""+cValToChar(nVlrped)+""  } )
					aAdd( _aMsgIc , { "TRANSPORTADORA"     , ""+SC5->C5_TRANSP+" - " + AllTrim(FDesc("SA4",SC5->C5_TRANSP,"SA4->A4_NREDUZ"))+" "  } )
					aAdd( _aMsgIc , { "FRETE"              , " "+cvaltochar(SC5->C5_FRETE)+" "  } )
					aAdd( _aMsgIc , { " % do FRETE"        , " "+cvaltochar(ROUND(SC5->C5_FRETE*100/nVlrped,2))+" "  } )
					nValfrete  :=ROUND(SC5->C5_FRETE*100/nVlrped,2)
					If nValfrete > nPorcFrete
						_cRetorno :=".T."
					Else
						_cRetorno :="  "
					EndIf
					
				EndIf
				
				cMSGcIC       += " VALOR:_________R$ "+_aMsgIc[10][2] +CR
				//................1 2 3 4 5 6 7 8 9 0
				cMSGcIC       += " TRASNPORTADORA:___________ "+_aMsgIc[11][2] +CR
				//................1 2 3 4 5 6 7 8 9 0
				cMSGcIC       += " FRETE:_________R$ "+_aMsgIc[12][2] +CR
				//................1 2 3 4 5 6 7 8 9 0
				cMSGcIC       += " % FRETE:_______"+_aMsgIc[13][2] +"%"+CR +CR
				//................1 2 3 4 5 6 7 8 9 0
				Do Case
					Case SC5->C5_TPFRETE = "C"
						cTipFret:= "CIF"
					Case SC5->C5_TPFRETE = "I"
						cTipFret:= "INCLUSO"
					Case SC5->C5_TPFRETE = "F"
						cTipFret:= "FOB"
					Case SC5->C5_TPFRETE = "T"
						cTipFret:= "TERCEIRO"
					Case SC5->C5_TPFRETE = "S"
						cTipFret:= "SEM FRETE"
				ENDCASE
				aAdd( _aMsgIc , { "TIPO de FRETE "   , ""+cTipFret+"" } )
				//	cMSGcIC       += " TIPO de FRETE:_______"+_aMsgIc[14][2] +"%"+CR +CR
				//................1 2 3 4 5 6 7 8 9 0
				cMSGcIC       += "Problema com o Frete " +CR
				If _cRetorno = ".T." .and. SC5->C5_TRANSP <> '100000'  .And. SC5->C5_TPFRETE $ "C/I" //Exclui emmovere
					If SC5->C5_TIPODIP = "1"
						U_DiprKardex(SC5->C5_NUM,cUserId,"LOG. DE OK NO AVISO DE PORCENTAGEM DO FRETE MAIOR QUE  "+cvaltochar(GetMv("ES_DIPV4_2"))+"%  DO PEDIDO.",.t.,"52") // GIOVANI 29/08/2005
					EndIf
					cDeIc       :=  "protheus@dipromed.com.br" //Lower(Alltrim(SU7->U7_EMAIL))
					cEmailIc    := GetMv("ES_DIPV4_3") + " ; "
					cAssuntoIc  := "AVISO - Frete de Pedido "
					cAttachIc   :=  "  a"
					cFuncSentIc :=   " M410stts.prw "
					If SC5->C5_TIPODIP = "1"   .AND. !(SC5->C5_TRANSP $ "000000/000111/000112/000133") .And. SC5->C5_TPFRETE $ "C/I"
						u_UEnvMail(cEmailIc,cAssuntoIc,_aMsgIc,cAttachIc,cDeIc,cFuncSentIc)
						//manda CIC
						M410CIC()
						
					EndIf
					
					
				EndIf
				_aMsgIc := " "
				nValfrete:=0
			EndIf
			
			
			//CONTROLE DE PEDIDOS A VISTA
			//GIOVANI ZAGO 09/02/2012
			//Maximo - Somente na Dipromed 02/03/2012
			
			If lNDelSaldo
				If 'VISTA' $ Posicione("SE4",1,XFILIAL("SE4")+SC5->C5_CONDPAG,'E4_DESCRI')   .And.  TesPed(SC5->C5_NUM)   //Verifica se tes gera financeiro
					If SC5->C5_TIPODIP = "1" .And. SC5->C5_TIPO = 'N' //Somente se nใo for retira com dinheiro/Somente empresa Dipromed/Somente Pedido
						SC5->(RecLock("SC5",.F.))
							SC5->C5_BLQ := "1"
						SC5->(MsUnLock())
						SC5->(DbCommit())
							// CIC E EMAIL
							CicVista()
					EndIf
				Else              
					SC5->(RecLock("SC5",.F.))
						SC5->C5_BLQ := ""
					SC5->(MsUnLock())
					SC5->(DbCommit())
				EndIf
			EndIf
			
			If !(SC5->C5_TIPODIP $ '2/3')	.And. 5000 <= ValC9(SC5->C5_NUM) .And. TesPed(SC5->C5_NUM) //pedido maior que 5 Mil .............  Giovani Zago  01/03/12
				MilCicMail()
			EndIf
			                           
			If SC5->C5_TIPODIP == '1' .And. SC5->C5_TRANSP == '100000' .And. ValC9(SC5->C5_NUM)>=GetNewPar("ES_VMAXEMO",150000) // .And. TesPed(SC5->C5_NUM)
            	SC5->(RecLock("SC5",.F.))
					SC5->C5_PARCIAL := 'N'
					SC5->C5_EXPLBLO := 'Pedido emovere maior que R$ '+cValToChar(GetNewPar("ES_VMAXEMO",150000))
					SC5->C5_PRENOTA := 'O'   
				SC5->(MsUnLock())
				
				Aviso("Aten็ใo","Pedidos utilizando a transportadora EMOVERE nใo podem ultrapassar o valor de R$ "+cValToChar(GetNewPar("ES_VMAXEMO",150000))+CHR(10)+CHR(13)+;
								"Inclua outro pedido e divida os itens respeitando o valor mแximo por pedido.",{"Ok"},2)
			    
			    cMsg := "TRATAMENTO DE PEDIDO EMOVERE"+CHR(10)+CHR(13)
				cMsg += "O pedido "+AllTrim(SC5->C5_NUM)+" ultrapassou o valor mแximo de R$ "+cValToChar(GetNewPar("ES_VMAXEMO",150000))
				
				U_DIPCIC(cMsg,"MAXIMO.CANUTO,DIEGO.DOMINGOS")
			EndIf
			
		EndIf
		
		//Atualiza C9_PARCIAL
		dbSelectArea("SC9")
		dbSetOrder(1)
		dbSeek(xFilial("SC9")+SC5->C5_NUM,.T.)
		While !Eof() .And. (xFilial("SC9")+SC5->C5_NUM == SC9->(C9_FILIAL+C9_PEDIDO))
			If Empty(SC9->C9_NFISCAL)
				SC9->(RecLock("SC9",.F.))
					SC9->C9_PARCIAL := SC5->C5_PARCIAL
					If SC5->C5_PRENOTA == "F"  // Corrige problema de grava็ใo do BLCRED  -   MCVN 13/12/2007
						SC9->C9_BLCRED := "01"
					Endif
				SC9->(MsUnLock())
				SC9->(DbCommit())
			EndIf
			
			dbSelectArea("SC9")
			SC9->(dbSkip())
		End
		
	EndIf
	
	If !("DIPAL10" $ FunName())  .And. !(FwIsInCallStack("U_DIPEXCRES"))
		SA1->(dbSetOrder(1))
		If SA1->(dbSeek(xFilial("SA1")+SC5->(C5_CLIENTE+C5_LOJACLI)))
			If SA1->A1_EST != 'SP'   			 .AND.;
				SA1->A1_EST != 'DF' 	 		 .AND.;
				SA1->A1_EST != 'AM' 	 		 .AND.;
				SA1->A1_EST != 'CE' 	 		 .AND.;
				SA1->A1_EST != 'GO' 	  		 .AND.;
				SA1->A1_EST != 'RN' 	         .AND.;
				M->C5_TIPO ==  'N'               .AND.;
				SA1->A1_CONTRIB <> '2' 			 .AND.;	 
				(!Empty(SA1->A1_INSCR) .OR. SA1->A1_TPJ = '3') .AND.;
				(EMPTY(ALLTRIM(SA1->A1_DREGESP)) .OR. SA1->A1_COD$GetNewPar("ES_STESPBA","010154"))   //Se o Cliente nใo tem regime especial cadastrado    21/09/2010
				U_DIPA025(SA1->A1_EST)
			EndIf			
		EndIf
	EndIf		

	
	If "TMK" $ FunName()
		
		// Atualiza UA_PARCIAL    -  MCVN 20/08/2007
		SUA->(RecLock("SUA",.F.))
			SUA->UA_PARCIAL := SC5->C5_PARCIAL
			SUA->UA_STATUS  := If(SUA->UA_STATUS == "LIB","SUP",SUA->UA_STATUS)
		SUA->(MsUnlock())
		SUA->(DbCommit())
		
		U_DiprKardex(SC5->C5_NUM,U_DipUsr(),,.t.,If(Empty(cParcial),"16","15")) // JBS 29/08/2005
		
	EndIf
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//Calcula PRECO com ICMS para TS 569
	// A FORMULA ษ: VALOR DO ITEM / (100-ALIQUOTA)%  --> Exemplo: 1008/82% = 1229.27 para alํquota 18%
	// MCVN - 19/10/2007
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	
	If !"TMK" $FunName() .And. SC5->C5_TIPO = "N" .And. !("DIPAL10" $ Funname())
		_nDescICMS := 0
		_nVlPed    := 0
		_nVlPedICM := 0

		SC6->(dbSetOrder(1))
		If SC6->(dbSeek(xFilial("SC6")+SC5->C5_NUM))
			While !SC6->(Eof()) .And. SC6->C6_NUM == SC5->C5_NUM
				If ((SC6->C6_TES $ '569/594/691/692/693/694/769/891' .AND. cEmpAnt = '01') .OR. (SC6->C6_TES$'504' .AND. cEmpAnt = '04'))   
					If Posicione("SF4",1,xFilial("SF4")+SC6->C6_TES, "F4_ESTOQUE") == "S"		
						_nQtdVen   := DipRetQtd(SC5->C5_NUM,SC6->C6_ITEM,SC6->C6_PRODUTO)
					Else 
						_nQtdVen   := SC6->C6_QTDVEN
					EndIf                           
					
					_nVlPed    += SC6->C6_PRUNIT * _nQtdVen
					_nVlPedICM += SC6->C6_PRUNIT /((100-Posicione("SB1",1,xFilial("SB1")+SC6->C6_PRODUTO,"B1_PICM"))/100) * _nQtdVen
		
					_nDescICMS -= SC6->C6_PRUNIT * _nQtdVen
					_nDescICMS += SC6->C6_PRUNIT / ((100-Posicione("SB1",1,xFilial("SB1")+SC6->C6_PRODUTO,"B1_PICM"))/100) * _nQtdVen
				EndIf


				SC6->(DbSkip())
			Enddo
		EndIf

		
		If _nDescICMS <> 0
			If !SC5->C5_CLIENTE$GetNewPar("ES_CLICMSL","000187/015402") 
				MsgBox("Desconto referente ICMS para Orgaos publico"+Chr(13)+"no estado de Sao Paulo"+Chr(13)+Chr(13)+"Valor.: "+AllTrim(Transform(_nDescICMS,"@E 999,999,999.99")),"Atencao","Alert")
				SC5->(RecLock("SC5",.F.))
					SC5->C5_MENNOTA := 'Desc.ICMS R$ '+AllTrim(Transform(_nDescICMS,"@E 999,999,999.99"))+'-/- '+Subs(SC5->C5_MENNOTA,At('-/- ',SC5->C5_MENNOTA)+Iif(At('-/- ',SC5->C5_MENNOTA)==0,1,4),Len(SC5->C5_MENNOTA)-(At('-/- ',SC5->C5_MENNOTA)+Iif(At('-/- ',SC5->C5_MENNOTA)==0,0,3)))
				SC5->(MsUnLock())
			Else
				MsgBox("Desconto referente ICMS para Orgaos publico"+Chr(13)+"no estado de Sao Paulo"+Chr(13)+Chr(13)+"Valor.: "+AllTrim(Transform(_nDescICMS,"@E 999,999,999.99")),"Atencao","Alert")
				SC5->(RecLock("SC5",.F.))
					SC5->C5_XMENOTA := 'PRECO COM ICMS: '+AllTrim(Transform(_nVlPedICM,"@E 999,999,999.99"))+' - DESCONTO ISENCAO ICMS: '+;
														AllTrim(Transform(_nDescICMS,"@E 999,999,999.99"))+' - PRECO TOTAL SEM ICMS: '+;
														AllTrim(Transform(_nVlPed   ,"@E 999,999,999.99"))+ '-/- '+Subs(SC5->C5_MENNOTA,At('-/- ',SC5->C5_MENNOTA)+Iif(At('-/- ',SC5->C5_MENNOTA)==0,1,4),Len(SC5->C5_MENNOTA)-(At('-/- ',SC5->C5_MENNOTA)+Iif(At('-/- ',SC5->C5_MENNOTA)==0,0,3)))
				SC5->(MsUnLock())
			EndIf
		EndIf		
	Endif
	
EndIf


//giovani licita็ใo 26/08/11
If !INCLUI .AND. !ALTERA
	
	If !Empty(SC5->C5_EMPENHO)
		
		//UA9->(dbSetOrder(2))
		UA4->(dbSetOrder(1))
		//	If UA9->(dbSeek(xFilial("UA9")+SC5->C5_EMPENHO + SC5->C5_EDITAL+SC6->C6_PRODUTO))
		
		Begin Transaction
		dbSelectArea("UA9")
		UA9->(dbGOTOP())
		Do While UA9->(!EOF())
			If UA9->UA9_FILIAL == xFilial("UA9") .and. ALLTRIM(UA9->UA9_EDITAL) == ALLTRIM(SC5->C5_EDITAL) .and. ALLTRIM(UA9->UA9_EMPENH) == ALLTRIM(SC5->C5_EMPENHO) .and. ALLTRIM(UA9->UA9_PRODUT) == ALLTRIM(SC6->C6_PRODUTO)
				
				If UA4->(dbSeek(xFilial("UA4")+ALLTRIM(SC5->C5_EDITAL)+UA9->UA9_ITEM))
				
					UA4->(RecLock("UA4",.f.))
						UA4->UA4_QTDENT := UA4->UA4_QTDENT - UA9->UA9_QTDEMP
						UA4->UA4_SALDO  := (UA4->UA4_QUANT + UA4->UA4_XSALAD ) - UA4->UA4_QTDENT  //UA4->UA4_SALDO + UA9->UA9_QTDEMP
						UA4->(MsUnlock("UA4"))
					UA4->(DbCommit())
				EndIf
				
				UA9->( Reclock("UA9",.f.) )
					UA9->( DbDelete() )
				UA9->( MsUnlock("UA9") )
			EndIf
			UA9->( dbSkip() )
			
		EndDo
		
		UA8->(dbSetOrder(1))
		
		If UA8->(dbSeek(xFilial("UA8") + SC5->C5_EDITAL + SC5->C5_EMPENHO))
			UA8->( Reclock("UA8",.f.))
				UA8->( DbDelete() )
			UA8->( MsUnlock("UA8") )
			
			UA1->(dbSetOrder(1))
			If UA1->(dbSeek(xFilial("UA1") + SC5->C5_EDITAL))
				UA1->( RecLock("UA1", .F.) )
					UA1->UA1_STATUS := EMPENHO // Aguardando empenho
				UA1->( MsUnLock("UA1") )
				
			EndIf
			
			If UA8->(dbSeek(xFilial("UA8") + SC5->C5_EDITAL ))
				If UA1->(dbSeek(xFilial("UA1") + SC5->C5_EDITAL))
					UA1->( RecLock("UA1", .F.) )
						UA1->UA1_PEDIDO := UA8->UA8_PEDIDO // Salva o numero do pedido ja gerado antes  da exclusao
					UA1->( MsUnLock("UA1") )
					
				EndIf
			ELSE
				If UA1->(dbSeek(xFilial("UA1") + SC5->C5_EDITAL))
					UA1->( RecLock("UA1", .F.) )
						UA1->UA1_PEDIDO := " " // vazio caso seja o primeiro empenho
					UA1->( MsUnLock("UA1") )
					
				EndIf
			EndIf			
		EndIf
		ConfirmSX8()		
		End Transaction		
	EndIf	
EndIf
   
If cEmpAnt=="01" .And. !("DIPAL10"$FunName()) .And. !("TMK"$FunName())
	u_DipGrvExp()                                                   
EndIf	

If _lContinua .And. !("DIPAL10"$FunName()) .And. !("TMK"$FunName())
	U_DiprKardex(SC5->C5_NUM,U_DipUsr(),,.t.,If(Empty(cParcial),"10","09"))
EndIf
	       
If _lContinua
	SC5->(RecLock("SC5",.F.))
		SC5->C5_XBLQAUT := ""
	SC5->(MsUnlock())
EndIf	
	
End Transaction

//-----------------------------------------------------------------------------------------------------
// JBS 27/05/2010 - Se Foi chamado do programa DIPA046, sai fora sem abrir telas
//-----------------------------------------------------------------------------------------------------
If Type("lDipa046") <> "U" .And. lDipa046
	Return
EndIf

If _lContinua
	If Type("lDipa046") <> "U" .And. lDipa046
		
		//U_DiprKardex(SC5->C5_NUM,U_DipUsr(),,.t.,If(Empty(cParcial),"10","09")) // JBS 27/05/2010
		
	ElseIf !("DIPAL10" $ FunName()) .And. !("TMK" $ FunName())
		If !(Type("l410Auto")<>"U" .And. l410Auto)
			If SC5->C5_TIPODIP $ '2/3' // MCVN - 21/06/09
				u_UTmkR3A()
			Else
				u_UTmkR03()
			Endif
		EndIf		
		//U_DiprKardex(SC5->C5_NUM,U_DipUsr(),,.t.,If(Empty(cParcial),"10","09")) // JBS 29/08/2005
	EndIf
EndIf

If Empty(SC5->C5_TRANSP)
	Alert("O PEDIDO FICARม BLOQUEADO POIS ESTม SEM TRANSPORTADORA. AVISAR O TI POR FAVOR!")
EndIf
// Andre Mendes - [Obify] - 16/03/2022

IF (INCLUI .Or. ALTERA)
	If SA1->A1_VEND == "000353" //000353
		Alert("ESTE CLIENTE ESTA NA CARTEIRA DO DIRETO, caso tenha interesse em colocar na sua carteira, favor solicitar anแlise para PATRICIA.")
	Endif 
Endif 

If _lContinua .And. !("DIPAL10" $ FunName())
		
	If SC5->C5_ESTE == "CE"

		nVlrPedCE := BaseICM(SC5->C5_NUM)   					

		If nVlrPedCE <= nICMSCE
			SC5->(RecLock("SC5",.F.))				
				SC5->C5_XRECOLH := ""					
			SC5->(MsUnLock())
			SC5->(DbCommit())				
		EndIf
	EndIf	
EndIf

If lNDelSaldo
	If _lContinua .And. !("DIPAL10" $ FunName()) .And. cParcial == "" .And. C5_TIPODIP =="1"
	//RBORGES 21/06/2013 - Se o pedido passar direto pelo cr้dito farแ o tratamento abaixo par enviar CIC e E-mail  
		If! SC5->C5_PRENOTA == 'F' .OR. SC5->C5_CONDPAG $ "001/002"   		
 			If !  SC5->C5_TRANSP $ GetNewPar("ES_TRP_COLS","000235") .And. !U_NaoMovEst(SC5->C5_NUM) .And. cEmpAnt == "01"
				ColCicMail()
			Endif		
			U_CICMailAV(SC5->C5_NUM)
 			u_DipICMSCF(SC5->C5_NUM)
 		EndIf 	
	EndIf
EndIf

If cEmpAnt <> '04'
	If _lContinua .And. !("DIPAL10" $ FunName()) .And. cParcial == "" .And. SC5->C5_TIPODIP =="1" .And. SC5->C5_CLIENTE$GetNewPar("ES_DCLICXF","000665")
		If _lMsgCIC
			u_DipCicCxP(SC5->C5_NUM,_aMsgCIC) //Mensagem se a vendedora aceitou caixa fechada
		EndIf
	 	If !SC5->C5_PRENOTA == 'F' .Or. SC5->C5_CONDPAG $ "001/002"
			u_DipCicPri(SC5->C5_NUM)	
		EndIf 	
	EndIf
Else
	cGPRCXF := Posicione("SA1",1,xFilial("SA1")+SC5->C5_CLIENTE,'A1_GRPVEN')
	If _lContinua .And. !("DIPAL10" $ FunName()) .And. cParcial == "" .And. SC5->C5_TIPODIP =="1" .And. (SC5->C5_CLIENTE$GetNewPar("ES_DCLICXF","000415") .Or. cGPRCXF$GetNewPar("ES_DGRPCXF","000175"));
	 					.And. !U_AmostrasHQ()
		If _lMsgCIC
			u_DipCicCxP(SC5->C5_NUM,_aMsgCIC) //Mensagem se a vendedora aceitou caixa fechada
		EndIf
	 	If !SC5->C5_PRENOTA == 'F' .Or. SC5->C5_CONDPAG $ "001/002"
			u_DipCicPri(SC5->C5_NUM)	
		EndIf 	
	EndIf
	cGPRCXF := ""
EndIf

If _lContinua .And. !("DIPAL10" $ FunName()) .And. !Empty(SA1->A1_OBSSAC)
	cObsSAC := SA1->A1_OBSSAC
	Aviso("ATENวรO!"," Hแ observa็ใo de pend๊ncia do SAC para este cliente."+CHR(10)+CHR(13)+;
    cObsSAC,{"Ok"},3)	
EndIf	


If INCLUI
	If cEmpAnt <> "04"
		If ("MATA410" $ FUNNAME()) .And. !Empty(SA1->A1_LFVISA) .And. !Empty(SA1->A1_VLLVISA) .And. SA1->A1_VLLVISA < dDATABASE //Reginaldo Borges 04/01/2018
			DIPVCIC(SA1->A1_COD,SA1->A1_NOME,SA1->A1_VEND)
			DIPVEMAIL(SA1->A1_COD,SA1->A1_NOME,SA1->A1_VEND)
		EndIF
	EndIf
EndIf	

If _lContinua .And. (INCLUI .Or. ALTERA) .And. cEmpAnt <> "04" .And. SC5->C5_TIPODIP=="1" .And. SC5->C5_TIPO == "N" //Reginaldo Borges 24/07/18 - Dispara e-mail para o Erich e a Patricia para pedidos superiores a 20 mil
	U_VALPED(SC5->C5_NUM)
EndIf 

//Chamar janela para informar se o pedido ้ Bionexo - RBorges 29/10/2018
If _lContinua .And. (INCLUI .Or. ALTERA) .And. Empty(SC5->C5_BIONEXO) .And. C5_TIPODIP = '1' .And. cEmpAnt <> "04"  .And. !("DIPAL10" $ FunName())
	U_Bionexo()
EndIf

If ALTERA
	If !Empty(C5_XDATEXP) .And. C5_TIPODIP = '2'
		SC5->(RecLock("SC5",.F.))
			SC5->C5_XDATEXP := CTOD("")
			SC5->(DbCommit())
		SC5->(MsUnlock())
	EndIf
EndIf

If _lContinua .And. INCLUI .And. !("DIPAL10" $ FunName()) .And. SC5->C5_TIPO == "N" .And. SC5->C5_TIPODIP =="1" .And. cEmpAnt <> "04"
	SALDPROD(SC5->C5_NUM)
EndIF

//Elimina Filtro de cliente e posiciona no registro SC5 atual
//If !("DIPAL10" $ FunName()) .And. !("DIPA072" $ FunName())   
//	oObjBrowDip:=FWmBrwActive()
//	oObjBrowDip:GetFilterDefault()
//	oObjBrowDip:Refresh()
//Endif


RestArea(aAreaSC9)
RestArea(aAreaSC6)
RestArea(aAreaSC5)
RestArea(aArea) 

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณM410STTS  บAutor  ณMicrosiga           บ Data ณ  07/29/13   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function M410CIC()

Local lRetorno := .T.
Local cFilSC9  := xFilial("SC9")
Local cServidor   := GetMV("MV_CIC")     // Servidor para enviar mensagem pelo CIC
Local cOpFatRem   := GetMV("MV_REMETCI") // Usuario do CIC remetente de mensgens no Protheus
Local cOpFatSenha := "123456"
Local cOpFatDest  := GetMV("ES_DIPV4_4")
Local cGetMotivo  := Space(90)
Local nOpcao      := 0
Local lSaida := .f.

// Envia a mensagem ao operador atrav้s do CIC
U_DIPCIC(cMSGcIC,AllTrim(cOpFatDest))//Giovani Zago 09/02/12
//WaitRun(cServidor+' '+cOpFatRem+' '+cOpFatSenha+' "'+AllTrim(cOpFatDest)+'" "'+cMSGcIC+'" ')
_aMsgIc := {}
cMSGcIC := " "
Return()
//*--------------------------------------------------------------------------*
//Fun็ใo para enviar Cic para o responsแvel
//*--------------------------------------------------------------------------*
Static Function ValorPedido(cPedido,lDipTot)
//*--------------------------------------------------------------------------*
Local aArea       := GetArea()
Local aAreaSC61   := SC6->( GetArea() )
Local aAreaSC51   := SC5->( GetArea() )
DEFAULT lDipTot   := .T.

nVlrPed := 0

DbSelectArea("SC6")
DbSetOrder(1)
SC6->(DbSeek(xFilial("SC6")+cPedido))
While SC6->C6_NUM == cPedido
	If SC6->C6_NUM == cPedido
		nVlrPed += SC6->C6_VALOR
	Endif
	SC6->(DbSkip())
Enddo
SC6->(DbCloseArea())

If lDipTot
	nVlrPed := (nVlrPed + SC5->C5_DESPESA + SC5->C5_SEGURO + SC5->C5_FRETE)
EndIf

RestArea( aAreaSC51 )
RestArea( aAreaSC61 )
RestArea( aArea )

Return(nVlrPed)

//*--------------------------------------------------------------------------*
Static Function CicVista()
//*--------------------------------------------------------------------------*
Local nVlrped     := 0
Local cDeIc       :=  "protheus@dipromed.com.br"  //Lower(Alltrim(Posicione("SU7",1,xFilial("SU7")+SC5->C5_OPERADO,"U7_EMAIL")))
Local cEmailIc    := GetMv("ES_MSTTS_1",,SUPERGETMV("MV_#EMLTI",.F.,"ti@dipromed.com.br"))+";"+cDeIc
Local cAttachIc   :=  "  a"
Local cFuncSentIc :=   " M410stts.prw "
Local cOpFatDest  := GetMv("ES_MSTTS_2",,"MAXIMO.CANUTO")
Local cTipFret    := ""
Local cAlt        := KarSz9(SC5->C5_NUM)
Local cAssuntoIc  := "AVISO - Pedido A Vista "+cAlt
_aMsgIc := {}
cMSGcIC       := "AVISO DE PEDIDO A VISTA"+cAlt+CR

aAdd( _aMsgIc , { " EMPRESA"  				, + Capital( AllTrim( GetAdvFVal( "SM0", "M0_NOME", cEmpAnt + cFilAnt, 1, "" ) ) )  } )
cMSGcIC       += " EMPRESA:_______" + Capital( AllTrim( GetAdvFVal( "SM0", "M0_NOME", cEmpAnt + cFilAnt, 1, "" ) ) ) +"/"+ Capital( AllTrim( GetAdvFVal( "SM0", "M0_FILIAL" , cEmpAnt + cFilAnt, 1, "" ) ) )   + CR
aAdd( _aMsgIc , { " FILIAL"   	   			, + Capital( AllTrim( GetAdvFVal( "SM0", "M0_FILIAL" , cEmpAnt + cFilAnt, 1, "" ) ) ) } )
aAdd( _aMsgIc , { "PEDIDO"    				,+SC5->C5_NUM  } )
cMSGcIC       += " PEDIDO:________"+SC5->C5_NUM +CR
aAdd( _aMsgIc , { "CLIENTE"    				,+SC5->C5_CLIENTE+" - "+Posicione("SA1",1,XFILIAL("SA1")+SC5->C5_CLIENTE,'A1_NREDUZ') } )
cMSGcIC       += " CLIENTE:________"+SC5->C5_CLIENTE+" - "+Posicione("SA1",1,XFILIAL("SA1")+SC5->C5_CLIENTE,'A1_NREDUZ') +CR
aAdd( _aMsgIc , { "COND.PAG"    	, +SC5->C5_CONDPAG+" - "+Posicione("SE4",1,XFILIAL("SE4")+SC5->C5_CONDPAG,'E4_DESCRI')   } )
cMSGcIC       += "COND.PAG:__________"+SC5->C5_CONDPAG+" - "+Posicione("SE4",1,XFILIAL("SE4")+SC5->C5_CONDPAG,'E4_DESCRI') +CR
If SC5->C5_TPFRETE = "D"
	aAdd( _aMsgIc , { "FORMA de PAGAMENTO"   , ""+Iif(SC5->C5_XFORPAG = '1',"Dinheiro",Iif(SC5->C5_XFORPAG = '2',"Cheque",Iif(SC5->C5_XFORPAG = '3',"Deposito","outros")))+"" } )
EndIf
nVlrped := ValorPedido(SC5->C5_NUM)
aAdd( _aMsgIc , { "VALOR do PEDIDO"    		, ""+Transform(nVlrped,"@EZ 999,999,999.99")+""  } )
cMSGcIC       +=  "VALOR:_________"+Transform(nVlrped,"@EZ 999,999,999.99") +CR
aAdd( _aMsgIc , { "OPERADOR"    			,""+SC5->C5_OPERADO+"-"+Posicione("SU7",1,xFilial("SU7")+SC5->C5_OPERADO,"U7_NREDUZ") })
cMSGcIC       += " OPERADOR:_______"+SC5->C5_OPERADO+"-"+Posicione("SU7",1,xFilial("SU7")+SC5->C5_OPERADO,"U7_NREDUZ") +CR
aAdd( _aMsgIc , { "TRANSPORTADORA"     , ""+SC5->C5_TRANSP+" - " + AllTrim(FDesc("SA4",SC5->C5_TRANSP,"SA4->A4_NREDUZ"))+" "  } )
cMSGcIC       += "Pedido Pode Ser Ser Separado."


Do Case
	Case SC5->C5_TPFRETE = "C"
		cTipFret:= "CIF"
	Case SC5->C5_TPFRETE = "I"
		cTipFret:= "INCLUSO"
	Case SC5->C5_TPFRETE = "F"
		cTipFret:= "FOB"
	Case SC5->C5_TPFRETE = "T"
		cTipFret:= "TERCEIRO"
	Case SC5->C5_TPFRETE = "S"
		cTipFret:= "SEM FRETE"
	Case SC5->C5_TPFRETE = "D"
		cTipFret:= "RETIRA"
ENDCASE
aAdd( _aMsgIc , { "TIPO de FRETE "   , ""+cTipFret+"" } )
aAdd( _aMsgIc , { "SEPARAR PEDIDO :"     , " SIM  "  } )
aAdd( _aMsgIc , { "GERAR NOTA FISCAL : "     , " NรO  "  } )
//GRAVA KARDEX
U_DiprKardex(SC5->C5_NUM,cUserId,"AVISO PEDIDO A VISTA - "+SC5->C5_CONDPAG+" .",.t.,"53","AVISO PEDIDO A VISTA") // GIOVANI ZAGO 09/02/12
//manda EMAIL
u_UEnvMail(cEmailIc,cAssuntoIc,_aMsgIc,cAttachIc,cDeIc,cFuncSentIc)
//manda CIC
U_DIPCIC(cMSGcIC,AllTrim(cOpFatDest))
return()



//*--------------------------------------------------------------------------*
Static Function MilCicMail()
//*--------------------------------------------------------------------------*
Local nVlrped     := 0
Local cDeIc       := "protheus@dipromed.com.br"  //Lower(Alltrim(Posicione("SU7",1,xFilial("SU7")+SC5->C5_OPERADO,"U7_EMAIL")))
Local cEmailIc    := GetMv("ES_MSTTS_3",,SUPERGETMV("MV_#EMLTI",.F.,"ti@dipromed.com.br"))+";"+cDeIc
Local cAssuntoIc  := "AVISO - Pedido Acima 5 Mil "
Local cAttachIc   :=  "  a"
Local cFuncSentIc :=   " M410stts.prw "
Local cOpFatDest  := GetMv("ES_MSTTS_4",,"MAXIMO.CANUTO")
Local cTipFret    := ""
_aMsgIc := {}
cMSGcIC       := "AVISO DE PEDIDO ACIMA DE 5 MIL "+CR

aAdd( _aMsgIc , { " EMPRESA"  				, + Capital( AllTrim( GetAdvFVal( "SM0", "M0_NOME", cEmpAnt + cFilAnt, 1, "" ) ) )  } )
cMSGcIC       += " EMPRESA:_______" + Capital( AllTrim( GetAdvFVal( "SM0", "M0_NOME", cEmpAnt + cFilAnt, 1, "" ) ) ) +"/"+ Capital( AllTrim( GetAdvFVal( "SM0", "M0_FILIAL" , cEmpAnt + cFilAnt, 1, "" ) ) )   + CR + CR
aAdd( _aMsgIc , { " FILIAL"   	   			, + Capital( AllTrim( GetAdvFVal( "SM0", "M0_FILIAL" , cEmpAnt + cFilAnt, 1, "" ) ) ) } )
aAdd( _aMsgIc , { "PEDIDO"    				,+SC5->C5_NUM  } )
cMSGcIC       += " PEDIDO:________"+SC5->C5_NUM +CR
aAdd( _aMsgIc , { "CLIENTE"    				,+SC5->C5_CLIENTE+" - "+Posicione("SA1",1,XFILIAL("SA1")+SC5->C5_CLIENTE,'A1_NREDUZ') } )
cMSGcIC       += " CLIENTE:________"+SC5->C5_CLIENTE+" - "+Posicione("SA1",1,XFILIAL("SA1")+SC5->C5_CLIENTE,'A1_NREDUZ') +CR
aAdd( _aMsgIc , { "COND.PAG"    	, +SC5->C5_CONDPAG+" - "+Posicione("SE4",1,XFILIAL("SE4")+SC5->C5_CONDPAG,'E4_DESCRI')   } )
cMSGcIC       += "COND.PAG:__________"+SC5->C5_CONDPAG+" - "+Posicione("SE4",1,XFILIAL("SE4")+SC5->C5_CONDPAG,'E4_DESCRI') +CR
nVlrped := ValC9(SC5->C5_NUM)
aAdd( _aMsgIc , { "VALOR do PEDIDO"    		, ""+Transform(nVlrped,"@EZ 999,999,999.99")+""  } )
cMSGcIC       +=  "VALOR:_________"+Transform(nVlrped,"@EZ 999,999,999.99") +CR
aAdd( _aMsgIc , { "OPERADOR"    			,""+SC5->C5_OPERADO+"-"+Posicione("SU7",1,xFilial("SU7")+SC5->C5_OPERADO,"U7_NREDUZ") })
cMSGcIC       += " OPERADOR:_______"+SC5->C5_OPERADO+"-"+Posicione("SU7",1,xFilial("SU7")+SC5->C5_OPERADO,"U7_NREDUZ") +CR
	aAdd( _aMsgIc , { "VENDEDOR"      ,""+SC5->C5_VEND1+"-"+Posicione("SA3",1,xFilial("SA3")+SC5->C5_VEND1,"A3_NOME") })
aAdd( _aMsgIc , { "TRANSPORTADORA"     , ""+SC5->C5_TRANSP+" - " + AllTrim(FDesc("SA4",SC5->C5_TRANSP,"SA4->A4_NREDUZ"))+" "  } )
Do Case
	Case SC5->C5_TPFRETE = "C"
		cTipFret:= "CIF"
	Case SC5->C5_TPFRETE = "I"
		cTipFret:= "INCLUSO"
	Case SC5->C5_TPFRETE = "F"
		cTipFret:= "FOB"
	Case SC5->C5_TPFRETE = "T"
		cTipFret:= "TERCEIRO"
	Case SC5->C5_TPFRETE = "S"
		cTipFret:= "SEM FRETE"
	Case SC5->C5_TPFRETE = "D"
		cTipFret:= "RETIRA"
ENDCASE
aAdd( _aMsgIc , { "TIPO de FRETE "   , ""+cTipFret+"" } )
aAdd( _aMsgIc , { "AVALIAวรO DE CRษDITO "   , ""+Iif(SC5->C5_PRENOTA == "F","SIM","NรO")+"" } )

	//manda EMAIL
u_UEnvMail(cEmailIc,cAssuntoIc,_aMsgIc,cAttachIc,cDeIc,cFuncSentIc)
//manda CIC
U_DIPCIC(cMSGcIC,AllTrim(cOpFatDest))
return()


//*--------------------------------------------------------------------------*
Static Function TesPed(cPedido)
//*--------------------------------------------------------------------------*
Local aArea       := GetArea()
Local aAreaSC61   := SC6->( GetArea() )
Local aAreaSC51   := SC5->( GetArea() )
Local _lTesPed    := .F.


DbSelectArea("SC6")
DbSetOrder(1)
SC6->(DbSeek(xFilial("SC6")+cPedido))
While SC6->C6_NUM == cPedido
	If !_lTesPed .And. "S" = Posicione("SF4",1,xFilial("SF4")+SC6->C6_TES,"F4_DUPLIC")
		_lTesPed := .T.
	Endif
	SC6->(DbSkip())
Enddo
SC6->(DbCloseArea())

RestArea( aAreaSC51 )
RestArea( aAreaSC61 )
RestArea( aArea )

Return(_lTesPed)

//*--------------------------------------------------------------------------*
Static Function ValC9(cPedido)
//*--------------------------------------------------------------------------*
Local aArea       := GetArea()
Local aAreaSC91   := SC9->( GetArea() )
Local aAreaSC51   := SC5->( GetArea() )
Local _nValoLib   := 0


DbSelectArea("SC9")
DbSetOrder(1)
SC9->(DbSeek(xFilial("SC9")+cPedido))
While SC9->C9_PEDIDO == cPedido
	If SC9->C9_SALDO = 0 .And. Empty(SC9->C9_NFISCAL)
		_nValoLib +=  (SC9->C9_QTDLIB*SC9->C9_PRCVEN)
	Endif
	SC9->(DbSkip())
Enddo
SC9->(DbCloseArea())

_nValoLib := (_nValoLib + SC5->C5_DESPESA + SC5->C5_SEGURO + SC5->C5_FRETE)

RestArea( aAreaSC51 )
RestArea( aAreaSC91 )
RestArea( aArea )

Return(_nValoLib)


//*--------------------------------------------------------------------------*
Static Function KarSz9(cPedido)
//*--------------------------------------------------------------------------*
Local aArea       := GetArea()
Local aAreaSZ91   := SZ9->( GetArea() )
Local aAreaSC51   := SC5->( GetArea() )
Local _cKarAlt    := ""


DbSelectArea("SZ9")
DbSetOrder(1)
SZ9->(DbSeek(xFilial("SZ9")+cPedido))
While SZ9->Z9_PEDIDO == cPedido
	If SZ9->Z9_OCORREN = "53"
		_cKarAlt :=  " - (ALTERADO)"
	Endif
	SZ9->(DbSkip())
Enddo
SZ9->(DbCloseArea())


RestArea( aAreaSC51 )
RestArea( aAreaSZ91 )
RestArea( aArea )

Return(_cKarAlt)



Static Function ValidCod(cPedido)

Local aArea       := GetArea()
Local aAreaSC61   := SC6->( GetArea() )
Local aAreaSC51   := SC5->( GetArea() )
Local _lCodPed    := .T.


DbSelectArea("SC6")
SC6->(DbSetOrder(1))
SC6->(DbSeek(xFilial("SC6")+cPedido))
While SC6->C6_NUM == cPedido
	If _lCodPed
		DbSelectArea("SB1")
		DbSetOrder(1)
		If SB1->(DbSeek(xFilial("SB1")+SC6->C6_PRODUTO))
			_lCodPed := .T.
		Else
			_lCodPed := .F.
			Aviso("Atencao","Este pedido ficarแ Bloqueado. Existe(m)  PRODUTO(s)  NรO CADASTRADOS(s).  Entre novamente no pedido e verifique o(s) PRODUTO(s)!!",{"Ok"} )
		Endif
	Endif
	SC6->(DbSkip())
Enddo
SC6->(DbCloseArea())

RestArea( aAreaSC51 )
RestArea( aAreaSC61 )
RestArea( aArea )

Return(_lCodPed)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณM410STTS  บAutor  ณMicrosiga           บ Data ณ  10/25/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function DipVldPV(cNumPV)
Local aAreaSC6  := SC6->(GetArea()) 
Local nQtdDias  := 0
Local _aRetProd := {}
Local _aProb	:= {}   
Local _aProb2	:= {}
Local lRet 		:= .T.    
Local lPrxLot	:= .F. 
Local _lProb	:= .F. 
Local cMsg		:= ""
Local _lProbCx	:= .F.
Local _lMesLot  := .T.
Local  cGPRCXF  := ""                   
Private lTransfOk := .F.
DEFAULT cNumPv 	:= ""

nQtdDias := U_ValidCli(SC5->C5_CLIENTE,SC5->C5_LOJACLI)

If cEmpAnt <> "04"
	lCxFech  := (SC5->C5_CLIENTE$GetNewPar("ES_DCLICXF","000665"))
Else
	cGPRCXF := Posicione("SA1",1,xFilial("SA1")+SC5->C5_CLIENTE,'A1_GRPVEN')
	lCxFech := (SC5->C5_CLIENTE$GetNewPar("ES_DCLICXF","000415") .Or. cGPRCXF$GetNewPar("ES_DGRPCXF","000175")) .And. !U_AmostrasHQ()
	cGPRCXF := ""
EndIf	
 
SC6->(dbSetOrder(1))
If SC6->(dbSeek(xFilial('SC6')+cNumPV)) .And. (nQtdDias > 0	 .Or. lCxFech)

	While !SC6->(Eof()) .And. SC6->C6_NUM == cNumPv
	
		_aRetProd := U_ValidProd(SC6->C6_PRODUTO,nQtdDias,SC6->C6_QTDVEN,nil,lCxFech)  
		
		If !_aRetProd[1] 
			If _aRetProd[3]
				SC6->(RecLock('SC6',.F.))
					SC6->C6_XPRXLOT := '1'
					lPrxLot := .T.
				SC6->(MsUnlock())     
			Else
				aAdd(_aProb,{_aRetProd[2],_aRetProd[3]}) 
				_lProb := .T.
			EndIf
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณCodigo provisorio para monitorar a melhoria... Retirar apos estabilizada. 22/11/2012ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			cMsg := "Novo tratamento de PV - M410STTS"+CHR(10)+CHR(13)
			cMsg += "Acompanhar o pedido: "+AllTrim(cNumPv)
			U_DIPCIC(cMsg,"MAXIMO.CANUTO,DIEGO.DOMINGOS")	
		EndIf
		
		If !_aRetProd[4]   
			aAdd(_aProb2,_aRetProd[5])
			_lProbCx := .T.
		EndIf
		
		If !_aRetProd[6]
			_lMesLot := .F.
		EndIf
	
		SC6->(dbSkip())
	EndDo
	
	If lPrxLot
		SC5->(RecLock('SC5',.F.))
			SC5->C5_XPRXLOT := '1'
		SC5->(MsUnlock())
	EndIf	
	
	If _lProb
		If !DipProbLot(SC5->C5_CLIENTE,SC5->C5_LOJACLI,_aProb) 
			SC5->(RecLock('SC5',.F.))
				SC5->C5_PARCIAL := 'N'
				SC5->C5_EXPLBLO := 'Pedido com lote nใo aceito pelo cliente. Recusado'
				SC5->C5_PRENOTA := 'O'   
				SC5->C5_XPRXLOT := '0'
			SC5->(MsUnlock())               
			If SC6->(dbSeek(xFilial('SC6')+cNumPV))
				SC6->(dbEval({|| SC6->(Reclock('SC6',.F.)), SC6->C6_XPRXLOT := '0', SC6->(MsUnlock())},,{|| SC6->(!EOF()) .AND. SC6->C6_NUM == cNumPv}))
			EndIf
			lRet := .F.	   
			U_DiprKardex(cNumPV,U_DipUsr(),"CLI: "+SC5->C5_CLIENTE+" RECUSOU O LOTE",.T.,"55")		             
		Else
			U_DiprKardex(cNumPV,U_DipUsr(),"CLI: "+SC5->C5_CLIENTE+" ACEITOU O LOTE",.T.,"56")
		EndIf
	EndIf  

	If lRet .And. !_lMesLot .And. !lTransfOk
		Alert("Produto com lote diferente recusado."+CHR(10)+CHR(13)+"Este Pedido ficarแ bloqueado.")		 
		SC5->(RecLock('SC5',.F.))
			SC5->C5_PARCIAL := 'N'
			SC5->C5_EXPLBLO := 'Pedido com lote nใo aceito pelo cliente. Recusado'
			SC5->C5_PRENOTA := 'O'   
		SC5->(MsUnlock())  
		lRet := .F.	              			
	EndIf

	If lRet .And. _lProbCx .And. !lTransfOk
		Alert("Problema no envio de produto em caixa fechada."+CHR(10)+CHR(13)+"Clique em OK para verificar os detalhes.")
		If !u_DipProbCxF(SC5->C5_CLIENTE,SC5->C5_LOJACLI,_aProb2) 
			SC5->(RecLock('SC5',.F.))
				SC5->C5_PARCIAL := 'N'
				SC5->C5_EXPLBLO := 'Pedido com cx fracionada nใo aceita pelo cliente. Recusado'
				SC5->C5_PRENOTA := 'O'   
			SC5->(MsUnlock())               			
			lRet := .F.	   
			U_DiprKardex(cNumPV,U_DipUsr(),"CLI: "+SC5->C5_CLIENTE+" RECUSOU CX FRACIONADA",.T.,"55")		             
		Else                 
			U_DiprKardex(cNumPV,U_DipUsr(),"CLI: "+SC5->C5_CLIENTE+" ACEITOU CX FRACIONADA",.T.,"56")
		EndIf
	EndIf  	
EndIf	

RestArea(aAreaSC6)
				
Return lRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณMTA410    บAutor  ณMicrosiga           บ Data ณ  10/18/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Verifica se o cliente tem tratamento especial para a data  บฑฑ
ฑฑบ          ณ de validade do lote  A1_XACELOT                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function ValidCli(cCodCli,cLoja)
Local _aAreaSA1 := SA1->(GetArea())
Local nQtdDias	:= 0
 
SA1->(dbSetOrder(1))
If SA1->(dbSeek(xFilial("SA1")+cCodCli+cLoja)) .And. SA1->(FieldPos("A1_XACELOT"))>0 .And. SA1->A1_XACELOT>0
	nQtdDias:= SA1->A1_XACELOT                           
EndIf

RestArea(_aAreaSA1)

Return nQtdDias
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณMTA410    บAutor  ณMicrosiga           บ Data ณ  10/17/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Verifica se o cliente aceita o pr๓ximo lote do produto     บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function ValidProd(cProd,nQtdDias,nQtdVen,lBloq,lCxFech)
Local _aAreaSB8	:= SB8->(GetArea())
Local lEmpPrev 	:= GetNewPar("MV_QTDPREV","F")== "S"
Local _lRet		:= .T.
Local _lCxEmb	:= .T.
Local cProb2 	:= ""
Local lPrxLot	:= .F.
Local nQtdLot	:= 0         
Local aProb 	:= {}
Local aProb2 	:= {}
Local aProxLot 	:= {}      
Local aLotes	:= {}
Local aLotes	:= {}
Local cNumDoc	:= ""
Local _lMesLot  := .T.
DEFAULT cProd	:= ""
DEFAULT nQtdDias:= ""
DEFAULT nQtdVen := ""                                 
DEFAULT lBloq	:= .F.

SB8->(dbSetOrder(1))
If SB8->(dbSeek(xFilial("SB8")+cProd+"01"))

	While !SB8->(Eof()) .And. SB8->B8_FILIAL == xFilial("SB8") .And. SB8->B8_PRODUTO == cProd .And. SB8->B8_LOCAL == "01"
		
		If SB8SALDO(,,,,,lEmpPrev,,,.T.) == 0
			SB8->(dbSkip())
			Loop					
		EndIf     
		
		If lBloq		
			If nQtdDias > (SB8->B8_DTVALID-dDataBase)                                                
				//Bloqueia e salva os bloqueados no aLotes               
				cNumDoc := u_DipBlqPrd(SB8->B8_PRODUTO,SB8->B8_LOCAL,SB8->B8_LOTECTL,SB8->B8_SALDO) 				
				aAdd(aLotes,{SB8->B8_PRODUTO,SB8->B8_LOCAL,SB8->B8_LOTECTL,SB8->B8_SALDO,cNumDoc})  				
			EndIf 			
		Else
			If _lRet .And. nQtdDias > (SB8->B8_DTVALID-dDataBase)
				aAdd(aProb,{SB8->B8_PRODUTO,SB8->B8_DTVALID,nQtdDias,SB8->B8_LOTECTL,SB8->B8_SALDO})
				_lRet := .F.  
			ElseIf !_lRet .And. nQtdDias <= (SB8->B8_DTVALID-dDataBase)
				nQtdLot += SB8->B8_SALDO   
				If nQtdLot >= nQtdVen                                                                          
					lPrxLot := .T.
					//aAdd(aProxLot,{SB8->B8_PRODUTO,SB8->B8_DTVALID,nQtdDias,SB8->B8_LOTECTL,SB8->B8_SALDO})
				EndIf
			EndIf       
			/*
			If lCxFech .And. nQtdDias <= (SB8->B8_DTVALID-dDataBase)
				aAdd(aLotes,{SB8->B8_PRODUTO,SB8->B8_LOCAL,SB8->B8_LOTECTL,SB8->B8_SALDO})
			EndIf
			*/
		EndIf
		
		SB8->(dbSkip())	
	EndDo  			
EndIf
                       
If !lBloq .And. lCxFech
	aRetCxEmb := u_VldCxEmb(nQtdVen,aProb,cProd)
	If !aRetCxEmb[1] .And. aRetCxEmb[3]
		cProb2 := aRetCxEmb[2]
		_lCxEmb := .F.
	ElseIf !aRetCxEmb[3] 	
		_lMesLot := .F. 
	EndIf
EndIf
	
RestArea(_aAreaSB8)                                  

Return IIf(lBloq,aLotes,{_lRet,aProb,lPrxLot,_lCxEmb,cProb2,_lMesLot})
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณMTA410    บAutor  ณMicrosiga           บ Data ณ  10/18/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Mostra o problema na tela e aguarda pela acao do usuario   บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function DipProbLot(cCliente,cLoja,aProb)     
Local _aAreaSA1 := SA1->(GetArea())                                                                         
Local cEND  := CHR(10)+CHR(13)
Local cMsg1 := ""                                                                                                
Local cMsg2	:= ""
Local _aNextLot := {}
Local _nI

SA1->(dbSetOrder(1))                  
If SA1->(dbSeek(xFilial("SA1")+cCliente+cLoja))

	cMsg1 := ' O cliente/loja "'+cCliente+'/'+cLoja+'" ('+AllTrim(SA1->A1_NOME)+')'                 
			//123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890'

	cMsg1 += ' estแ parametrizado para nใo aceitar lotes com validade inferior a '+AllTrim(Str(SA1->A1_XACELOT))+' dias.'+cEND 
	cMsg1 += ' '+cEND  
	cMsg1 += ' Neste pedido foram encontrados produtos que estใo com o prazo de validade inferior ao aceito pelo cliente.'+cEND
	cMsg1 += ' '+cEND  

	For _nI := 1 to Len(aProb)
		
		cMsg1 += Replicate('-',90)+cEND  
		cMsg1 += ' PRODUTO COM PROBLEMA: '+AllTrim(aProb[_nI,1,1,1])+cEND  
		cMsg1 += Replicate('-',90)+cEND  
		
		cMsg1 += ' * PRODUTO:          '+AllTrim(aProb[_nI,1,1,1])+cEND
		cMsg1 += ' '+AllTrim(POSICIONE('SB1',1,xFilial('SB1')+aProb[_nI,1,1,1],"B1_DESC"))+cEND
		cMsg1 += ' * LOTE:                 '+aProb[_nI,1,1,4]+cEND
		cMsg1 += ' * VALIDADE:         '+DtoC(aProb[_nI,1,1,2])+cEND
		cMsg1 += ' * DIAS PARA VENCER: '+AllTrim(Str(aProb[_nI,1,1,2]-dDataBase))+cEND
		
		/*
		If Len(aProb[_nI,2])>0  
			cMsg1 += Replicate('-',90)+cEND 
			cMsg1 += ' PRำXIMO(S) LOTE(S) DESTE PRODUTO: '+AllTrim(aProb[_nI,1,1,1])+cEND 
			cMsg1 += Replicate('-',90)+cEND 
			For _nJ := 1 to Len(aProb[_nI,2])
		    	cMsg1 += " * PRODUTO:        "+aProb[_nI,2,_nJ,1]+cEND
		    	cMsg1 += " "+AllTrim(POSICIONE('SB1',1,xFilial('SB1')+aProb[_nI,2,_nJ,1],"B1_DESC"))+cEND  
		       	cMsg1 += " * LOTE:               "+aProb[_nI,2,_nJ,4]+cEND
	       		cMsg1 += " * QUANTIDADE:   "+AllTrim(Str(aProb[_nI,2,_nJ,5]))+cEND
		    	cMsg1 += " * VALIDADE:       "+DtoC(aProb[_nI,2,_nJ,2])+cEND
    			cMsg1 += ' * DIAS PARA VENCER: '+AllTrim(Str(aProb[_nI,2,_nJ,2]-dDataBase))+cEND
		    	cMsg1 += " * CLIENTE ACEITA: "+IIf(aProb[_nI,2,_nJ,3]>(aProb[_nI,2,_nJ,2]-dDataBase),"Nใo","Sim")+cEND 
	   			cMsg1 += Replicate('-',90)+cEND 
			Next _nJ 
		Else
			cMsg1 += Replicate('-',90)+cEND 
			cMsg1 += ' ESTE PRODUTO NรO POSSUI OUTROS LOTES COM SALDO. '+cEND 
			cMsg1 += Replicate('-',90)+cEND 	 
		EndIf	
		*/
		
		cMsg1 += ' '+cEND  
		cMsg1 += Replicate('=',70)+cEND 
		cMsg1 += ' '+cEND  
		
	Next _nI 
	
	cMsg1 += ' Antes de liberar o pedido, confirme se o cliente aceitarแ o(s) produto(s) exibido(s) anteriormente.'+cEND
	cMsg1 += ' '+cEND  
	cMsg1 += ' Caso o cliente aceite TODOS os produtos, clique no botใo "Aceitar" e prossiga com a inclusใo do pedido.'+cEND
	cMsg1 += ' '+cEND  
	cMsg1 += ' Se o cliente nใo aceitar um ou mais produtos, clique no botใo "Recusar" (o pedido ficarแ bloqueado), altere o pedido'
	cMsg1 += ' e retire os produtos recusados.'

	/*, verifique nos pr๓ximos lotes '
	cMsg1 += ' se existe quantidade disponํvel em estoque do produto e solicite o bloqueio do lote atual '
	cMsg1 += ' para que seja liberado o pr๓ximo (conforme o procedimento jแ adotado atualmente).'
	cMsg2 := ' Confirme com o cliente a a็ใo a ser tomada.'	
	*/	
Else 
	cMsg1 := ' Este pedido possui problemas relacionados เ validade dos produtos.'
	cMsg2 := ' Entre em contato com o T.I..'	
EndIf	                                                        

RestArea(_aAreaSA1)

Return (Aviso('Aten็ใo',cMsg1,{"Recusar","Aceita"},3,cMsg2)==2)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณM410STTS  บAutor  ณMicrosiga           บ Data ณ  11/01/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function DipBlqPrd(cProduto,cLocal,cLoteCTL,nQtdBlq)
Local aArea		  := GetArea()
Local aAreaSDD	  := SDD->(GetArea())
Local aCpos 	  := {}          
Local lMsErroAuto := .F.
Local cPedBlq	  := SC5->C5_NUM //INFORMAR O NUMERO DO PEDIDO NA TABELA DE BLOQUEIO DE LOTE - FELIPE DURAN 05/03/2020        
Local cMotivo	  := 'Bloqueio automแtico - '+cPedBlq+'!'
Local cSQL 		  := "" 
Local cNumDoc	  := ""

cSQL := "SELECT MAX(DD_DOC) NUMDOC FROM "+RetSQLName('SDD')
cSQL += "WHERE LEFT(DD_DOC,2)= 'AT' AND D_E_L_E_T_ = ' ' "

cSQL := ChangeQuery(cSQL)		
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),"QRY",.T.,.T.) 

If !QRY->(Eof()) .And. !Empty(QRY->NUMDOC)
	cNumDoc := Soma1(QRY->NUMDOC)
Else 
	cNumDoc := "AT0001"
EndIf
QRY->(dbCloseArea())			

aCpos	 := {;                
			{"DD_DOC"		,cNumDoc 	,NIL},;
			{"DD_PRODUTO" 	,cProduto	,NIL},;
			{"DD_LOCAL" 	,cLocal		,NIL},;    
			{"DD_LOTECTL"	,cLoteCTL	,NIL},;    
			{"DD_QUANT"		,nQtdBlq	,NIL},;
			{"DD_MOTIVO"	,'ND'		,NIL},;
			{"DD_OBSERVA"	,cMotivo	,NIL}}                                               	

MSExecAuto({|x, y| mata275(x, y)},aCpos, 3)       


If lMsErroAuto    
	Mostraerro()
Endif
                      
RestArea(aAreaSDD)
RestArea(aArea)

Return cNumDoc  
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณM410STTS  บAutor  ณMicrosiga           บ Data ณ  11/01/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function DipDBlPrd(aLotes)
Local aArea		  := GetArea()
Local nI		  := 0
Local aCpos 	  := {}          
Local lMsErroAuto := .F.
Local cPedBlq	  := SC5->C5_NUM //INFORMAR O NUMERO DO PEDIDO NA TABELA DE BLOQUEIO DE LOTE - FELIPE DURAN 05/03/2020      
Local cMotivo	  := 'Desbloq. automแtico - '+cPedBlq+'!'

For nI := 1 to Len(aLotes)

	aCpos	 := {;                
				{"DD_DOC"		,aLotes[nI,5]	,NIL},;
				{"DD_PRODUTO" 	,aLotes[nI,1]	,NIL},;
				{"DD_LOCAL" 	,aLotes[nI,2]	,NIL},;    
				{"DD_LOTECTL"	,aLotes[nI,3]	,NIL},;    
				{"DD_QUANT"		,aLotes[nI,4]	,NIL},;
				{"DD_MOTIVO"	,'ND'	   		,NIL},;
				{"DD_OBSERVA"	,cMotivo		,NIL}}                                               	
	
	MSExecAuto({|x, y| mata275(x, y)},aCpos, 4)       

	If lMsErroAuto    
		Mostraerro()
		DisarmTransaction()
	Endif   

Next nI
          
RestArea(aArea)

Return
/*-----------------------------------------------------------------------------
+ Reginaldo Borges Data: 25/06/2013 Fun็ใo: ColCicMail()                                                                              
+ Essa fun็ใo enviarแ cic e e-mail para os usuแrios contidos nos parโmetros,
+ quando for necessแrio a solicita็ใo de coleta เ transportadora do pedido. 
-----------------------------------------------------------------------------*/
//*--------------------------------------------------------------------------*
Static Function ColCicMail()
//*--------------------------------------------------------------------------*

Local cDeIc       := "protheus@dipromed.com.br"
Local cEmailIc    := GetMv("ES_MAI_COL")        //Usuแrios que receberใo e-mails
Local cCICDest    := Upper(GetMv("ES_CIC_COL")) // Usuแrios que receberใo CICดs
Local cAssuntoIc  := "AVISO - SOLICITAR COLETA PARA ESSE PEDIDO! " +CR
Local cAttachIc   :=  "  a"
Local cFuncSentIc :=   " MT410STTS.prw "
Local cTrpCol     := GetNewPar("ES_TRP_COLS","000235")

_aMsgIc := {}
cMSGcIC       := "AVISO - SOLICITAR COLETA PARA ESSE PEDIDO! " +CR +CR

aAdd( _aMsgIc , { " EMPRESA"  				, + Capital( AllTrim( GetAdvFVal( "SM0", "M0_NOME", cEmpAnt + cFilAnt, 1, "" ) ) )  } )
cMSGcIC       += " EMPRESA:_______" + Capital( AllTrim( GetAdvFVal( "SM0", "M0_NOME", cEmpAnt + cFilAnt, 1, "" ) ) ) +"/"+ Capital( AllTrim( GetAdvFVal( "SM0", "M0_FILIAL" , cEmpAnt + cFilAnt, 1, "" ) ) )   + CR
aAdd( _aMsgIc , { " FILIAL"   	   			, + Capital( AllTrim( GetAdvFVal( "SM0", "M0_FILIAL" , cEmpAnt + cFilAnt, 1, "" ) ) ) } )
aAdd( _aMsgIc , { "PEDIDO"    				,+SC5->C5_NUM  } )
cMSGcIC       += " PEDIDO:________"+SC5->C5_NUM +CR
aAdd( _aMsgIc , { "CLIENTE"    				,+SC5->C5_CLIENTE+" - "+Posicione("SA1",1,XFILIAL("SA1")+SC5->C5_CLIENTE,'A1_NREDUZ') } )
cMSGcIC       += " CLIENTE:________"+SC5->C5_CLIENTE+" - "+Posicione("SA1",1,XFILIAL("SA1")+SC5->C5_CLIENTE,'A1_NREDUZ') +CR
aAdd( _aMsgIc , { "COND.PAG"    	, +SC5->C5_CONDPAG+" - "+Posicione("SE4",1,XFILIAL("SE4")+SC5->C5_CONDPAG,'E4_DESCRI')   } )
cMSGcIC       += "COND.PAG:__________"+SC5->C5_CONDPAG+" - "+Posicione("SE4",1,XFILIAL("SE4")+SC5->C5_CONDPAG,'E4_DESCRI') +CR
aAdd( _aMsgIc , { "OPERADOR"    			,""+SC5->C5_OPERADO+"-"+Posicione("SU7",1,xFilial("SU7")+SC5->C5_OPERADO,"U7_NREDUZ") })
cMSGcIC       += " OPERADOR:_______"+SC5->C5_OPERADO+"-"+Posicione("SU7",1,xFilial("SU7")+SC5->C5_OPERADO,"U7_NREDUZ") +CR
aAdd( _aMsgIc , { "VENDEDOR"      ,""+SC5->C5_VEND1+"-"+Posicione("SA3",1,xFilial("SA3")+SC5->C5_VEND1,"A3_NOME") })
aAdd( _aMsgIc , { "TRANSPORTADORA"     , ""+SC5->C5_TRANSP+" - " + AllTrim(FDesc("SA4",SC5->C5_TRANSP,"SA4->A4_NREDUZ"))+" "  } )
cMSGcIC       += " TRANSP.:_______"+SC5->C5_TRANSP+" - " + AllTrim(FDesc("SA4",SC5->C5_TRANSP,"SA4->A4_NREDUZ")) +CR

U_DIPCIC(cMSGcIC,cCICDest)

U_UEnvMail(cEmailIc,cAssuntoIc,_aMsgIc,cAttachIc,cDeIc,cFuncSentIc)

return()   
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณM410STTS  บAutor  ณMicrosiga           บ Data ณ  07/29/13   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function BaseICM(cPedido)
Local aArea      := GetArea()
Local cSQL		 := ""
Local nVlrPed 	 := 0
DEFAULT cPedido  := ""

cSQL := " SELECT "
cSQL += " 	SUM(C6_VALOR) BASEICM "
cSQL += " 	FROM "
cSQL +=  		RetSQLName("SC6")+", "+RetSQLName("SF4")+", "+RetSQLName("SB1")
cSQL += " 		WHERE "
cSQL += " 			C6_FILIAL = '"+xFilial("SC6")+"' AND "
cSQL += " 			C6_NUM = '"+cPedido+"' AND "
cSQL += " 			F4_FILIAL = '"+xFilial("SF4")+"' AND "
cSQL += " 			F4_CODIGO = C6_TES AND "
cSQL += " 			F4_ICM = 'S' AND "
cSQL += " 			B1_FILIAL = '"+xFilial("SB1")+"' AND "
cSQL += " 			B1_COD = C6_PRODUTO AND "
cSQL += " 			B1_PICM > 0 AND "
cSQL +=  			RetSQLName("SF4")+".D_E_L_E_T_ = ' ' AND "
cSQL +=  			RetSQLName("SF4")+".D_E_L_E_T_ = ' ' AND "
cSQL +=  			RetSQLName("SF4")+".D_E_L_E_T_ = ' ' "
                                                          
cSQL := ChangeQuery(cSQL)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),"SC6TMP",.T.,.T.)

TCSETFIELD("SC6TMP","BASEICM","N",17,2)

nVlrPed := (SC6TMP->BASEICM + SC5->C5_DESPESA + SC5->C5_SEGURO + SC5->C5_FRETE)

SC6TMP->(dbCloseArea())

RestArea( aArea )

Return(nVlrPed)            
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณM410STTS  บAutor  ณMicrosiga           บ Data ณ  06/20/14   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function DipRetQtd(cPedido,cItem,cProd)
Local nDipQtd := 0                            
Local cSQL 	  := ""

cSQL := " SELECT "
cSQL += " 	C9_QTDORI "
cSQL += " 	FROM "
cSQL += 		RetSQLName("SC9")
cSQL += " 		WHERE "
cSQL += " 			C9_FILIAL  = '"+xFilial("SC9")+"' AND "
cSQL += " 			C9_PEDIDO  = '"+cPedido+"' AND "
cSQL += " 			C9_ITEM	   = '"+cItem+"' AND "
cSQL += " 			C9_PRODUTO = '"+cProd+"' AND "
cSQL += " 			C9_NFISCAL = ' ' AND "
cSQL += " 			C9_QTDORI  > 0 AND "
cSQL += " 			D_E_L_E_T_ = ' ' "

cSQL := ChangeQuery(cSQL)
dbUseArea(.T., "TOPCONN", TCGenQry(,,cSQL), 'QRYSC9', .F., .T.)

If !QRYSC9->(Eof())
	nDipQtd := QRYSC9->C9_QTDORI
EndIf
QRYSC9->(dbCloseArea())

Return nDipQtd
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณM410STTS  บAutor  ณMicrosiga           บ Data ณ  12/18/14   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function DipTemAnv()
Local lRet 		:= .T.
Local cCampos 	:= AllTrim(GetNewPar("ES_CPOSVLD",""))
Local cCampoAux := ""            
Local aCpoVazio := {}
                                   
If "DIPAL10"$FunName()
	Return({.T.,{}})
EndIf

While Len(cCampos)>0
	nPos := At("/",cCampos)  
	If nPos <= 0
		nPos := Len(cCampos)+1
	EndIf           
	
	cCampoAux := SubStr(cCampos,1,nPos-1)        
	                
	If cCampoAux$"A1_LFVISA;A1_VLLVISA" .And. SA1->A1_CNAE$"4689-3/99;4649-4/99;4669-9/99"
		If (Len(cCampos)-nPos)>0
			cCampos := Right(cCampos,Len(cCampos)-nPos)
		Else
			Exit
		EndIf
		Loop
	EndIf
	
	If Empty(&("SA1->"+cCampoAux))
		aAdd(aCpoVazio,cCampoAux)
		lRet := .F.               
	EndIf
		
	If (Len(cCampos)-nPos)>0
		cCampos := Right(cCampos,Len(cCampos)-nPos)
	Else
		Exit
	EndIf
EndDo                   
/*
If GetNewPar("ES_VLDANVI",.F.)
	lRet:= .T.	
EndIf                       
*/
Return({lRet,aCpoVazio})
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณM410STTS  บAutor  ณMicrosiga           บ Data ณ  08/24/15   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function DipGrvExp()
Local _aArea   := GetArea()
Local _aFeriad := {}
Local _dDatExp := StoD("")
Local _cTime   := ""
Local _lRet    := .F.
Local _cPosto  := ""
Local _cGrpVen := ""
Local _cCodCli := ""

SU7->(dbSetOrder(1))
If SU7->(dbSeek(xFilial("SU7")+SC5->C5_OPERADO))    
	_cPosto := SU7->U7_POSTO
EndIf

SA1->(dbSetOrder(1))
If SA1->(dbSeek(xFilial("SA1")+SC5->(C5_CLIENTE+C5_LOJACLI)))    
	_cGrpVen := SA1->A1_GRPVEN
	_cCodCli := SA1->A1_COD
EndIf                                              

lEstoque := u_DipRetEst(SC5->C5_NUM)

If INCLUI .Or. (ALTERA .And. Empty(SC5->C5_XDATEXP))
	If 	lEstoque .And.; 
		SC5->C5_TIPODIP == '1' .And.; 
		SC5->C5_TIPO == 'N' .And.; 
		_cPosto=="02" .And.; 
		!_cGrpVen$GetNewPar("ES_GRPNEXP","000031") .And.; 
		!_cCodCli$GetNewPar("ES_CLINEXP","")
 		      	
		DipRetFer(@_aFeriad)

		_dDatExp := dDataBase+1 	
		
		While !_lRet
			If Ascan(_aFeriad,{|x| x[1] == _dDatExp})>0
				_dDatExp ++
				_lRet    := .F.
			Else
				_lRet    := .T.
            EndIf    
            
			If AllTrim(cDow(_dDatExp)) == "Saturday"
				_dDatExp += 2
				_lRet 	 := .F.
			ElseIf AllTrim(cDow(_dDatExp)) == "Sunday"
				_dDatExp ++
				_lRet 	 := .F.
			EndIf
		EndDo
	                              
	    _cTime := SubStr(Time(),1,2)+":"+SubStr(Time(),4,2)
	    
		SC5->(RecLock("SC5",.F.))
			SC5->C5_XDATRES := dDataBase
			SC5->C5_XDATEXP := _dDatExp
			SC5->C5_XHORRES := _cTime
			SC5->C5_XHOREXP := _cTime
		SC5->(MsUnLock())		
	EndIf
EndIf

RestArea(_aArea)

Return    
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณM410STTS  บAutor  ณMicrosiga           บ Data ณ  08/24/15   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function DipRetFer(_aFeriad)

SX5->(dbSetOrder(1))
If SX5->(dbSeek(xFilial("SX5")+"63"))
	While SX5->X5_TABELA == "63"		
		If Left(SX5->X5_DESCRI,1)<>"*"         
			cTemp := Alltrim(SubStr(SX5->X5_DESCRI,1,8))
			If Len(cTemp) <> 8
				cTemp := cTemp+"/"+Right(AllTrim(Str(year(dDataBase))),2)
			EndIf
			aAdd(_aFeriad,{CtoD(cTemp)})
		EndIf
		SX5->(DbSkip())
	EndDo
EndIf

Return          
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณM410STTS  บAutor  ณMicrosiga           บ Data ณ  08/25/15   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function DipRetEst(cNum)
Local cSQL := ""
Local lRet := .F.

cSQL := " SELECT "
cSQL += " 	C9_PEDIDO " 
cSQL += " 	FROM "
cSQL +=  		RetSQLName("SC9")
cSQL += " 		WHERE "
cSQL += " 			C9_FILIAL = '"+xFilial("SC9")+"' AND "
cSQL += " 			C9_PEDIDO = '"+cNum+"' AND "
cSQL += " 			C9_QTDORI > 0  AND "
cSQL += " 			C9_NFISCAL = ' ' AND "
cSQL += " 			D_E_L_E_T_ = ' ' "

cSQL := ChangeQuery(cSQL)		
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),"QRYSC9",.T.,.T.) 

If !QRYSC9->(Eof())
	lRet := .T.
EndIf          
QRYSC9->(dbCloseArea())

Return lRet      
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณM410STTS  บAutor  ณMicrosiga           บ Data ณ  03/31/16   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
//Rafael Moraes Rosa VERIFICAR
Static Function DipVldMin(cPedido,cEste,nVlrZZB,nVlrCons)
Local _lRet := .T. 
Local _nVlrReal := 0
DEFAULT cPedido := ""
DEFAULT cEste	:= ""
DEFAULT nVlrZZB := 0

_nVlrReal := u_DipVlrReal(cPedido)

ZZB->(dbSetOrder(1))
If ZZB->(dbSeek(xFilial("ZZB")+AllTrim(cEste))) .And. ZZB->ZZB_VALMIN > _nVlrReal
	_lRet := .F.	                                  
	nVlrZZB  := ZZB->ZZB_VALMIN  
	nVlrCons := _nVlrReal
EndIf

Return _lRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณM410STTS  บAutor  ณMicrosiga           บ Data ณ  03/31/16   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function DipVlrReal(cPedido)
Local _cSQL := ""
Local _nVlrReal := 0
DEFAULT cPedido := ""

_cSQL := " SELECT  
_cSQL += " 	SUM(C6_PRCVEN*C9_QTDORI) AS 'VALOR' "
_cSQL += " 	FROM "
_cSQL += 		RetSQLName("SC6") + " SC6,"+RetSQLName("SC9")+" SC9 "
_cSQL += " 		WHERE 
_cSQL += " 			C6_FILIAL  = '"+xFilial("SC6")+"' AND "
_cSQL += " 			C6_NUM 	   = '"+cPedido+"' AND "
_cSQL += " 			C6_FILIAL  = C9_FILIAL AND "
_cSQL += "	 		C6_NUM	   = C9_PEDIDO AND "
_cSQL += " 			C6_PRODUTO = C9_PRODUTO AND "
_cSQL += " 			C6_ITEM	   = C9_ITEM AND "	
_cSQL += " 			C6_CLI 	   = C9_CLIENTE AND "
_cSQL += " 			C6_LOJA    = C9_LOJA AND "
_cSQL += " 			C9_NFISCAL = ' ' AND "	
_cSQL += " 			C9_QTDORI  > 0 AND "	
_cSQL += " 			SC9.D_E_L_E_T_ = ' ' AND "
_cSQL += " 			SC6.D_E_L_E_T_ = ' ' "

_cSQL := ChangeQuery(_cSQL)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cSQL),"QRYVLR",.T.,.T.) 
                              
TCSETFIELD("QRYVLR","VALOR","N",14,2)

If !QRYVLR->(Eof())
	_nVlrReal := QRYVLR->VALOR
EndIf
QRYVLR->(dbCLoseArea())

Return _nVlrReal  
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณM410STTS  บAutor  ณMicrosiga           บ Data ณ  05/05/16   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function VldCxEmb(nQtdVen,aProb,cProd,lBloq,cItemPV)
Local aAreaSB8		:= SB8->(GetArea())
Local aAreaSBF		:= SBF->(GetArea())
Local nQEmbSB1 		:= 0
Local nQSecSB1 		:= 0            
Local nQEmbSC6	 	:= 0
Local nQSecSC6		:= 0
Local nQUniSC6	 	:= 0
Local nQEmbSBF  	:= 0
Local nQSecSBF  	:= 0
Local nQUniSBF		:= 0
Local nQEmbSald		:= 0
Local nQSecSald		:= 0
Local nQUniSald		:= 0
Local nSaldo  		:= 0
Local nJaUsado		:= 0
Local nRestoSal  	:= 0
Local nResto  		:= 0
Local lCxSec 		:= .F.
Local lCxEmb 		:= .F.
Local lUnit  		:= .F.
Local lRet 			:= .F.
Local aLotesSBF		:= {}
Local lEmpPrev 		:= GetNewPar("MV_QTDPREV","F")== "S"
Local nNaoUsad		:= 0
Local aDipQtd		:= Array(3)
Local nQtdTra		:= 0
Local nI
DEFAULT nQtdVen		:= 0
DEFAULT aProb		:= {}
DEFAULT cProd 		:= "" 
DEFAULT lBloq 		:= .F.

SB1->(dbSetOrder(1))
If SB1->(dbSeek(xFilial("SB1")+cProd))  
	         
	If !lBloq
		DipEstCon(cProd)
	EndIf
   	
   	nQEmbSB1 := SB1->B1_XQTDEMB
	nQSecSB1 := SB1->B1_XQTDSEC	
	
	//Anแlise do pedido para ver quantas cxs foi pedido
	
	If lBloq
		nQtdVen := DipRQtdC9(SC5->C5_NUM,cProd,cItemPV,nQtdVen)
	EndIf
	
	If u_DipVCxLot(SB1->B1_COD,nQtdVen,SC6->C6_LOCAL) //Valida se existe produtos do mesmo lote
	   Return IIf(lBloq,{},{.T.,SB1->B1_COD,.T.})	  
	Else
		If !lBloq
			If !MsgYesNo("Nใo exite caixa fechada com o mesmo lote para envio do c๓digo ("+AllTrim(SB1->B1_COD)+"-"+AllTrim(SB1->B1_DESC)+")."+CHR(10)+CHR(13)+" Confirma o envio do produto?")
				U_DiprKardex(SC5->C5_NUM,cUserId,"Recusou o produto "+AllTrim(SB1->B1_COD)+" com lote diferente  ",.t.,"66")
				Return {.T.,SB1->B1_COD,.F.}
			Else				
				U_DiprKardex(SC5->C5_NUM,cUserId,"Aceitou o produto "+AllTrim(SB1->B1_COD)+" com lote diferente  ",.t.,"65")		
			EndIf
		EndIf
		If nQEmbSB1 > 0	    	
			nQEmbSC6 := Int(nQtdVen/nQEmbSB1)    
	
			nResto := Mod(nQtdVen,nQEmbSB1)       
			If nResto>0
				If nQSecSB1>0
					nQSecSC6 := Int(nResto/nQSecSB1)				
				EndIf
				nQUniSC6 := nResto-nQSecSC6*nQSecSB1
			EndIf
		ElseIf nQSecSB1 > 0   
			nQSecSC6 := Int(nQtdVen/nQSecSB1)
	
			nResto := Mod(nQtdVen,nQSecSB1)
			If nResto>0
				nQUniSC6 := nResto-nQSecSC6*nQSecSB1
			EndIf
		Else           
			//Se for unitแrio nใo preciso fazer a regra
			lRet := .T.
		EndIf	 
				   
		If !lRet 
			// Vou comparar o que foi solicitado no PV com o que tenho no estoque                  	
			If nQEmbSB1 > 0
				nQEmbSald := u_RetQtdSBF(nQEmbSB1,cProd,0)			
				If nQEmbSald >= nQEmbSC6   
					lCxEmb := .T.
					nJaUsado := nQEmbSC6*nQEmbSB1								
				ElseIf nQEmbSald > 0 				
					nJaUsado := nQEmbSald*nQEmbSB1   				 
					If !lBloq               
						nQtdTra   := 0
						lTransfOk := .F.
						nQtdTra := DipTrfCxF(nQEmbSB1,cProd,nQEmbSC6-nQEmbSald) 				 
						If ((nJaUsado+nQtdTra)/nQEmbSB1) >= nQEmbSC6
							lTransfOk := .T.
						EndIf
					EndIf
					If nQSecSB1 > 0 
						nQSecSC6 += Int((nQEmbSC6-nQEmbSald)*nQEmbSB1/nQSecSB1)
					Else
						nQUniSC6 += (nQEmbSC6-nQEmbSald)*nQEmbSB1
					EndIf            					
					nQEmbSC6 := nQEmbSald  										
				EndIf            
			Else 
				lCxEmb := .T.	
			EndIf
		   
			If nQSecSB1 > 0 .And. nJaUsado < nQtdVen
				nQSecSald := u_RetQtdSBF(nQSecSB1,cProd,nJaUsado)    
				If nQSecSald >= nQSecSC6
					lCxSec := .T.
					nJaUsado += nQSecSC6*nQSecSB1
				ElseIf nQSecSald > 0
					nJaUsado += nQSecSald*nQSecSB1
					nQUniSC6 += (nQSecSC6-nQSecSald)*nQSecSB1
					nFaltSec := (nQSecSC6-nQSecSald)*nQSecSB1
				EndIf
			Else
				lCxSec := .T.	
			EndIf
			  
			If !lCxEmb .Or. !lCxSec .Or. nJaUsado < nQtdVen
				nQUniSald := u_RetQtdSBF(1,cProd,nJaUsado)      
				If nQUniSald >= nQUniSC6
					lUnit := .T.					
				EndIf   
			Else
				lUnit := .T.
		    EndIf
	        
	        If nQtdVen > nQEmbSC6*nQEmbSB1+nQSecSC6*nQSecSB1+nQUniSC6
	        	nQUniSC6 += nQtdVen-nQEmbSC6*nQEmbSB1-nQSecSC6*nQSecSB1-nQUniSC6
	        EndIf
	        
	    	If lBloq  
		    	nJaUsado:= 0
	    		aDipSld := u_DipSldSBF(cProd)    		
	    		If nQEmbSC6 > 0
					nQEmbAux := nQEmbSC6
					For nI:=1 to Len(aDipSld) 									
						If aDipSld[nI,5] >= nQEmbAux*nQEmbSB1  
							aDipSld[nI,5] -= nQEmbAux*nQEmbSB1                                                         
							nJaUsado += nQEmbAux*nQEmbSB1
							If (nPos := aScan(aLotesSBF,{|x| x[1]+x[2]+x[3]+x[4]+x[6]==aDipSld[nI,1]+aDipSld[nI,2]+aDipSld[nI,3]+aDipSld[nI,4]+cItemPV })) > 0
								aLotesSBF[nPos,5] += nQEmbAux*nQEmbSB1
							Else
								aAdd(aLotesSBF,{aDipSld[nI,1],aDipSld[nI,2],aDipSld[nI,3],aDipSld[nI,4],nQEmbAux*nQEmbSB1,cItemPV})											
							EndIf
						ElseIf aDipSld[nI,5] >= nQEmbSB1 											  
							nQtdAux := Int(aDipSld[nI,5]/nQEmbSB1)*nQEmbSB1						  
							nQEmbAux -= Int(aDipSld[nI,5]/nQEmbSB1)
							aDipSld[nI,5] -= nQtdAux 
							nJaUsado += nQtdAux                                                                      
							If (nPos := aScan(aLotesSBF,{|x| x[1]+x[2]+x[3]+x[4]+x[6]==aDipSld[nI,1]+aDipSld[nI,2]+aDipSld[nI,3]+aDipSld[nI,4]+cItemPV })) > 0
								aLotesSBF[nPos,5] += nQtdAux
							Else
								aAdd(aLotesSBF,{aDipSld[nI,1],aDipSld[nI,2],aDipSld[nI,3],aDipSld[nI,4],nQtdAux,cItemPV})											
							EndIf
						EndIf   
						If nJaUsado >= nQEmbSC6*nQEmbSB1
							Exit
						EndIf
					Next nI     
				EndIf
			   
				If nQSecSC6 > 0 
					nJaUsado := 0
					nQSecAux := nQSecSC6     		       
					For nI:=1 to Len(aDipSld)   					
						If aDipSld[nI,5] >= nQSecAux*nQSecSB1 
							aDipSld[nI,5] -= nQSecAux*nQSecSB1                                                         
							nJaUsado += nQSecAux*nQSecSB1    
							If (nPos := aScan(aLotesSBF,{|x| x[1]+x[2]+x[3]+x[4]+x[6]==aDipSld[nI,1]+aDipSld[nI,2]+aDipSld[nI,3]+aDipSld[nI,4]+cItemPV })) > 0
								aLotesSBF[nPos,5] += nQSecAux*nQSecSB1
							Else
								aAdd(aLotesSBF,{aDipSld[nI,1],aDipSld[nI,2],aDipSld[nI,3],aDipSld[nI,4],nQSecAux*nQSecSB1,cItemPV})											
							EndIf
						ElseIf aDipSld[nI,5] >= nQSecSB1   					
							nQtdAux := Int(aDipSld[nI,5]/nQSecSB1)*nQSecSB1						  
							nQSecAux -= Int(aDipSld[nI,5]/nQSecSB1)
							aDipSld[nI,5] -= nQtdAux  						
							nJaUsado += nQtdAux                                                                      
							If (nPos := aScan(aLotesSBF,{|x| x[1]+x[2]+x[3]+x[4]+x[6]==aDipSld[nI,1]+aDipSld[nI,2]+aDipSld[nI,3]+aDipSld[nI,4]+cItemPV })) > 0
								aLotesSBF[nPos,5] += nQtdAux
							Else
								aAdd(aLotesSBF,{aDipSld[nI,1],aDipSld[nI,2],aDipSld[nI,3],aDipSld[nI,4],nQtdAux,cItemPV})
							EndIf
						EndIf     
						If nJaUsado >= nQSecSC6*nQSecSB1
							Exit
						EndIf
					Next nI
				EndIf
				  
				If nQUniSC6 > 0  
					nJaUsado := 0   
					nQUniAux := nQUniSC6
					For nI:=1 to Len(aDipSld)
						If aDipSld[nI,5] >= nQUniSC6 .And. nJaUsado==0
							nJaUsado += nQUniSC6   
							If (nPos := aScan(aLotesSBF,{|x| x[1]+x[2]+x[3]+x[4]+x[6]==aDipSld[nI,1]+aDipSld[nI,2]+aDipSld[nI,3]+aDipSld[nI,4]+cItemPV })) > 0
								aLotesSBF[nPos,5] += nQUniSC6
							Else
								aAdd(aLotesSBF,{aDipSld[nI,1],aDipSld[nI,2],aDipSld[nI,3],aDipSld[nI,4],nQUniSC6,cItemPV})
							EndIf					
						ElseIf aDipSld[nI,5]>0                    
							nJaUsado += aDipSld[nI,5]	
							nQUniAux -= aDipSld[nI,5]						
							If nJaUsado > nQUniSC6    
								If (nPos := aScan(aLotesSBF,{|x| x[1]+x[2]+x[3]+x[4]+x[6]==aDipSld[nI,1]+aDipSld[nI,2]+aDipSld[nI,3]+aDipSld[nI,4]+cItemPV })) > 0
									aLotesSBF[nPos,5] += aDipSld[nI,5]-(nJaUsado-nQUniSC6)
								Else
									aAdd(aLotesSBF,{aDipSld[nI,1],aDipSld[nI,2],aDipSld[nI,3],aDipSld[nI,4],aDipSld[nI,5]-(nJaUsado-nQUniSC6),cItemPV})											
								EndIf						
							Else     
								If (nPos := aScan(aLotesSBF,{|x| x[1]+x[2]+x[3]+x[4]+x[6]==aDipSld[nI,1]+aDipSld[nI,2]+aDipSld[nI,3]+aDipSld[nI,4]+cItemPV })) > 0
									aLotesSBF[nPos,5] += aDipSld[nI,5]
								Else
									aAdd(aLotesSBF,{aDipSld[nI,1],aDipSld[nI,2],aDipSld[nI,3],aDipSld[nI,4],aDipSld[nI,5],cItemPV})											
								EndIf						
							EndIf								
						EndIf     
						If nJaUsado >= nQUniSC6
							Exit	
						EndIf					
					Next nI
			    EndIf    		
	    	EndIf    
	        lRet := lCxEmb .And. lCxSec .And. lUnit		        
		EndIf
	EndIf	
EndIf

RestArea(aAreaSB8)
RestArea(aAreaSBF)         

Return IIf(lBloq,aLotesSBF,{lRet,SB1->B1_COD,.T.})
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณM410STTS  บAutor  ณMicrosiga           บ Data ณ  05/10/16   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function DipProbCxF(cCliente,cLoja,aProb2)
Local lRet := .F.                              
Local _aAreaSA1 := SA1->(GetArea())
Local cEND  := CHR(10)+CHR(13)
Local cMsg1 := ""                                                                                                
Local cMsg2	:= ""     
Local lRet := .F.
Local _nI
DEFAULT cCliente := ""
DEFAULT cLoja 	 := ""
DEFAULT aProb2 	 := {}

SA1->(dbSetOrder(1))                  
If SA1->(dbSeek(xFilial("SA1")+cCliente+cLoja))

	cMsg1 := ' O cliente/loja "'+cCliente+'/'+cLoja+'" ('+AllTrim(SA1->A1_NOME)+')'                 

	cMsg1 += ' estแ parametrizado para nใo aceitar produtos com caixa fracionada.'+cEND 
	cMsg1 += ' '+cEND  
	cMsg1 += ' Neste pedido foram encontrados produtos que nใo possuem a quantidade solicitada em caixas fechadas.'+cEND
	cMsg1 += ' '+cEND  

	For _nI := 1 to Len(aProb2)
		
		cMsg1 += Replicate('-',90)+cEND  
		cMsg1 += ' PRODUTO COM PROBLEMA: '+AllTrim(aProb2[_nI])+cEND  
		cMsg1 += Replicate('-',90)+cEND  
		
		cMsg1 += ' * PRODUTO:          '+AllTrim(aProb2[_nI])+cEND

		aAdd(_aMsgCic,aProb2[_nI])

		cMsg1 += ' '+AllTrim(POSICIONE('SB1',1,xFilial('SB1')+aProb2[_nI],"B1_DESC"))+cEND
				
		cMsg1 += ' '+cEND  
		cMsg1 += Replicate('=',70)+cEND 
		cMsg1 += ' '+cEND  
		
	Next _nI 
	
	cMsg1 += ' Antes de liberar o pedido, confirme se o cliente aceitarแ o(s) produto(s) exibido(s) anteriormente.'+cEND
	cMsg1 += ' '+cEND  
	cMsg1 += ' Caso o cliente aceite TODOS os produtos, clique no botใo "Aceitar" e prossiga com a inclusใo do pedido.'+cEND
	cMsg1 += ' '+cEND  
	cMsg1 += ' Se o cliente nใo aceitar um ou mais produtos, clique no botใo "Recusar" (o pedido ficarแ bloqueado), altere o pedido'
	cMsg1 += ' e retire os produtos recusados.'
Else 
	cMsg1 := ' Este pedido possui problemas relacionados เ validade dos produtos.'
	cMsg2 := ' Entre em contato com o T.I..'	
EndIf	

If Aviso('Aten็ใo',cMsg1,{"Recusar","Aceita"},3,cMsg2)==2
	_lMsgCIC := .T.
	lRet 	 := .T.
EndIf                                                        

RestArea(_aAreaSA1)

Return(lRet)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณM410STTS  บAutor  ณMicrosiga           บ Data ณ  05/19/16   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function RetQtdSBF(nQtd,cProduto,nJaUsado)
Local cSQL := ""      
Local nRet := 0

cSQL := " SELECT "
cSQL += " 	SUM(ROUND((BF_QUANT-BF_EMPENHO)/"+AllTrim(Str(nQtd))+",0,2)) QTD "
cSQL += " 	FROM "
cSQL += 		RetSQLName("SBF")
cSQL += " 		WHERE "
cSQL += " 			BF_FILIAL = '"+xFilial("SBF")+"' AND "
cSQL += " 			BF_PRODUTO = '"+cProduto+"' AND "
cSQL += " 			BF_QUANT > 0 AND "
cSQL += " 			D_E_L_E_T_ = ' ' "            

cSQL := ChangeQuery(cSQL)		
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),"QRYCXF",.T.,.T.) 

TCSETFIELD("QRYCXF","QTD","N",14,0)

If !QRYCXF->(Eof())
	nRet := QRYCXF->QTD-Int(nJaUsado/nQtd)
EndIf       
QRYCXF->(dbCloseArea())

Return nRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณM410STTS  บAutor  ณMicrosiga           บ Data ณ  05/19/16   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function DipSldSBF(cProduto)
Local cSQL := ""   
Local aDipSld := {}  

cSQL := " SELECT "
cSQL += " 	BF_PRODUTO, BF_LOCAL, BF_LOTECTL, BF_LOCALIZ, BF_QUANT-BF_EMPENHO QTD "
cSQL += " 	FROM "
cSQL += 		RetSQLName("SBF")
cSQL += " 		WHERE "
cSQL += " 			BF_FILIAL = '"+xFilial("SBF")+"' AND "
cSQL += " 			BF_LOCAL = '01' AND "
cSQL += " 			BF_PRODUTO = '"+cProduto+"' AND "
cSQL += " 			D_E_L_E_T_ = ' ' "
cSQL += " ORDER BY BF_PRIOR	"

cSQL := ChangeQuery(cSQL)		
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),"QRYSLD",.T.,.T.) 

TCSETFIELD("QRYSLD","QTD","N",14,0)

If !QRYSLD->(Eof())
	QRYSLD->(dbEval({|| aAdd(aDipSld,{QRYSLD->BF_PRODUTO,QRYSLD->BF_LOCAL,QRYSLD->BF_LOTECTL,QRYSLD->BF_LOCALIZ,QRYSLD->QTD}) }  ))
EndIf       
QRYSLD->(dbCloseArea())

Return aDipSld  
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณM410STTS  บAutor  ณMicrosiga           บ Data ณ  05/25/16   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function DipEstCon(cProd)
Local cMsg 		  := ""
Local cSQL 		  := ""
Local _nQtdTransf := 0
Local aEstLocal   := {}
Local nEstTotal   := 0
Local nQtdJaTran  := 0
Local nQtdTotTran := 0
Local cCodSZP 	  := ""
Local nSldSB2	  := 0

// Se o produto possuir mesmo lote e mesmo endere็o, por้m empresa diferente.
// transfiro tudo para a mesma empresa.

cSQL := " SELECT "
cSQL += " 	CONS.BF_PRODUTO, "
cSQL += " 	CONS.BF_LOCAL, "
cSQL += " 	CONS.BF_LOTECTL, "
cSQL += " 	CONS.BF_LOCALIZ, "
cSQL += " 	SUM(MTZ.BF_QUANT-MTZ.BF_EMPENHO) QTDMTZ, "
cSQL += " 	SUM(CD.BF_QUANT-CD.BF_EMPENHO) QTDCD "
cSQL += " 	FROM "
cSQL +=  		RetSQLName("SBF")+" CONS "
cSQL += " 		LEFT JOIN "
cSQL += 			RetSQLName("SBF")+" MTZ "
cSQL += " 			ON	"
cSQL += " 				MTZ.BF_FILIAL  = '01' AND "
cSQL += " 				MTZ.BF_FILIAL  = CONS.BF_FILIAL AND "
cSQL += " 				MTZ.BF_PRODUTO = CONS.BF_PRODUTO AND "
cSQL += " 				MTZ.BF_LOCAL   = CONS.BF_LOCAL AND "
cSQL += " 				MTZ.BF_LOTECTL = CONS.BF_LOTECTL AND "
cSQL += " 				MTZ.BF_LOCALIZ = CONS.BF_LOCALIZ AND "
cSQL += " 				MTZ.D_E_L_E_T_ = ' ' "
cSQL += " 		LEFT JOIN "
cSQL +=  			RetSQLName("SBF")+" CD "
cSQL += " 			ON "
cSQL += " 				CD.BF_FILIAL  = '04' AND "
cSQL += " 				CD.BF_FILIAL  = CONS.BF_FILIAL AND "
cSQL += " 				CD.BF_PRODUTO = CONS.BF_PRODUTO AND "
cSQL += " 				CD.BF_LOCAL	  = CONS.BF_LOCAL AND "
cSQL += " 				CD.BF_LOTECTL = CONS.BF_LOTECTL AND "
cSQL += " 				CD.BF_LOCALIZ = CONS.BF_LOCALIZ AND "
cSQL += " 				CD.D_E_L_E_T_ = ' ' "
cSQL += " 		WHERE  "
cSQL += " 			CONS.BF_FILIAL IN('01','04') AND  "
cSQL += " 			CONS.BF_PRODUTO = '"+cProd+"' AND "
cSQL += " 			CONS.BF_LOCAL   = '01' AND "
cSQL += " 			CONS.D_E_L_E_T_ = ' ' "
cSQL += " GROUP BY CONS.BF_PRODUTO, CONS.BF_LOCAL, CONS.BF_LOCALIZ, CONS.BF_LOTECTL "
cSQL += " HAVING COUNT(1)>1 "

cSQL := ChangeQuery(cSQL)		
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),"QRYSLD2",.T.,.T.)       

While !QRYSLD2->(Eof())
	If cEmpAnt=="01" .And. QRYSLD2->QTDCD > 0 .And. DipTemQtd("04",cProd,QRYSLD2->QTDCD,@nQtdJaTran)
		_nQtdTransf := QRYSLD2->QTDCD
	ElseIf cEmpAnt=="04" .And. QRYSLD2->QTDMTZ > 0 .And. DipTemQtd("01",cProd,QRYSLD2->QTDMTZ,@nQtdJaTran)
		_nQtdTransf := QRYSLD2->QTDMTZ
	EndIf                             
	
	If _nQtdTransf > 0
		cFilEmpOrig := IIf(cEmpAnt+cFilAnt == '0104','1','2')
	    
		SZP->(dbSetFilter({|| SZP->ZP_EMPORIG == cFilEmpOrig .And. ZP_LOCAL = cLocalTran}, "SZP->ZP_EMPORIG == cFilEmpOrig .And. ZP_LOCAL = cLocalTran"))
	
		nEstTotal   := U_DIPSALDSB2(cProd,.t.,'') 	//Estoque total dispinํvel
		nQtdTotTran := ExistTran(.T.,cProd) 		// Verifica se Existe transfer๊ncia solicitada para este Produto
    	
    	If _nQtdTransf > (nEstTotal-nQtdTotTran) .And. (nEstTotal-nQtdTotTran) > 0
			_nQtdTransf := (nEstTotal-nQtdTotTran)
		EndIf                             
		
		nSldSB2 := U_DIPSALDSB2(cProd,.T.,IIf(cFilAnt=="01","CD","MTZ"))
		If _nQtdTransf > nSldSB2
			_nQtdTransf := nSldSB2
		EndIf
        
		If _nQtdTransf > 0
			cCodSZP := GETSX8NUM("SZP","ZP_CODIGO")   
			ConfirmSX8()                              
			SZP->(RecLock("SZP",.T.))
				SZP->ZP_FILIAL  := xFilial("SZP") 
				SZP->ZP_CODIGO  := cCodSZP                                                                  
				SZP->ZP_DTSOLIT := Date()
				SZP->ZP_EMPORIG := If(cEmpAnt+cFilAnt =='0101',"1","2")
				SZP->ZP_PRODUTO := cProd
				SZP->ZP_QUANT   := _nQtdTransf
				SZP->ZP_USERSOL := Upper(U_DipUsr())             
				SZP->ZP_DTTRANS := DATE()
				SZP->ZP_EXPLIC  := "Pedido "+M->C5_NUM+" (T.A.1)"
				SZP->ZP_STATUS  := '1'
				SZP->ZP_LOCAL   := QRYSLD2->BF_LOCAL			                                                                                        			
				SZP->ZP_LOCALIZ := QRYSLD2->BF_LOCALIZ
				SZP->ZP_LOTECTL := QRYSLD2->BF_LOTECTL
			SZP->(MsUnlock())
			SZP->(DbCommit())    
		EndIf
				
		SZP->(dbSetFilter({|| .t.},".t.")) 
	EndIf
	
	QRYSLD2->(dbSkip())
EndDo
QRYSLD2->(dbCloseArea())

Return 
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณM410STTS  บAutor  ณMicrosiga           บ Data ณ  06/01/16   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ExistTran(lTotSolic,cProduto)     
Local cSQL	      := ""              
Local nQtdTran    := 0
DEFAULT lTotSolic := .F. 
DEFAULT cProduto  := ""


cSQL := " SELECT SUM(ZP_QUANT) ZP_QUANT "
cSQL += "   FROM SZP010 SZP "
cSQL += "   WHERE ZP_FILIAL = '" + xFilial("SZP") + "' " 
cSQL += "   AND ZP_QUANT  > 0 "
cSQL += "   AND ZP_STATUS = '1' "
cSQL += "   AND ZP_LOCAL  = '01' "     
If !lTotSolic 
	cSQL += "   AND ZP_EXPLIC LIKE  '%" + M->C5_NUM + "%' " 
Endif
cSQL += "   AND ZP_PRODUTO=  '" + cProduto + "' " 

If cEmpAnt+cFIlAnt = '0104'
	cSQL += "    AND ZP_EMPORIG = '2' "
ElseIf  cEmpAnt+cFIlAnt = '0101'
	cSQL += "    AND ZP_EMPORIG = '1' "                                                         
Else
	cSQL += "    AND ZP_EMPORIG = '' "
Endif
cSQL += "    AND SZP.D_E_L_E_T_ <> '*' "
cSQL += "  GROUP BY ZP_PRODUTO "

cSQL := ChangeQuery(cSQL)		
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),"TRBEXZP",.T.,.T.) 

TCSETFIELD("TRBEXZP","ZP_QUANT","N",11,00)

If !TRBEXZP->(Eof()) 	
	nQtdTran := TRBEXZP->ZP_QUANT		                                       
EndIf                  
TRBEXZP->(dbCloseArea())

Return(nQtdTran)   
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณM410STTS  บAutor  ณMicrosiga           บ Data ณ  05/19/16   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Transfere Caixa Fechada                                    บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function DipTrfCxF(nQtd,cProduto,nQEmbSC6)
Local cSQL 	  := ""      
Local nRet 	  := 0                     
Local cFilAux := IIf(cFilAnt=="01","04","01")
Local nTransf := 0
Local cCodSZP := ""                
Local nQtdTot := 0
Local nEstTot := 0
Local nSldSB2 := 0

cSQL := " SELECT "
cSQL += " 	BF_PRODUTO, BF_LOCAL, BF_LOTECTL, BF_LOCALIZ, SUM(ROUND((BF_QUANT-BF_EMPENHO)/"+AllTrim(Str(nQtd))+",0,2)) QTD "
cSQL += " 	FROM "
cSQL += 		RetSQLName("SBF")
cSQL += " 		WHERE "
cSQL += " 			BF_FILIAL  = '"+cFilAux +"' AND "
cSQL += " 			BF_PRODUTO = '"+cProduto+"' AND "
cSQL += " 			BF_QUANT > 0 AND "
cSQL += " 			D_E_L_E_T_ = ' ' "            
cSQL += " GROUP BY BF_PRODUTO, BF_LOCAL, BF_LOTECTL, BF_LOCALIZ  "

cSQL := ChangeQuery(cSQL)		
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),"QRYCXF",.T.,.T.) 

TCSETFIELD("QRYCXF","QTD","N",14,0)

While !QRYCXF->(Eof())                

	If nQEmbSC6 <= 0
		Exit
	EndIf

	If QRYCXF->QTD >= nQEmbSC6
		nTransf  := nQEmbSC6*nQtd 
		nQEmbSC6 := 0
	ElseIf QRYCXF->QTD > 0 
		nTransf  := QRYCXF->QTD*nQtd
		nQEmbSC6 -= (QRYCXF->QTD)
	EndIf                        
    
	If !DipTemQtd(cFilAux,cProduto,nTransf)
		nTransf := 0
	EndIf
	  
	If nTransf > 0
		cFilEmpOrig := IIf(cEmpAnt+cFilAnt == '0104','1','2')
	    
		SZP->(dbSetFilter({|| SZP->ZP_EMPORIG == cFilEmpOrig .And. ZP_LOCAL = cLocalTran}, "SZP->ZP_EMPORIG == cFilEmpOrig .And. ZP_LOCAL = cLocalTran"))
	
		nEstTot := U_DIPSALDSB2(cProduto,.t.,'') 	//Estoque total dispinํvel
		nQtdTot := ExistTran(.T.,cProduto) 		// Verifica se Existe transfer๊ncia solicitada para este Produto
    	
    	If nTransf > (nEstTot-nQtdTot) .And. (nEstTot-nQtdTot) > 0
			nTransf := (nEstTot-nQtdTot)
		EndIf
		
		nSldSB2 := U_DIPSALDSB2(cProduto,.T.,IIf(cFilAnt=="01","CD","MTZ"))
		If nTransf > nSldSB2
			nTransf := nSldSB2
		EndIf
        
		If nTransf > 0
			cCodSZP := GETSX8NUM("SZP","ZP_CODIGO")   
			ConfirmSX8()                              
			SZP->(RecLock("SZP",.T.))
				SZP->ZP_FILIAL  := xFilial("SZP") 
				SZP->ZP_CODIGO  := cCodSZP                                                                  
				SZP->ZP_DTSOLIT := Date()
				SZP->ZP_EMPORIG := If(cEmpAnt+cFilAnt =='0101',"1","2")
				SZP->ZP_PRODUTO := cProduto
				SZP->ZP_QUANT   := nTransf
				SZP->ZP_USERSOL := Upper(U_DipUsr())             
				SZP->ZP_DTTRANS := DATE()
				SZP->ZP_EXPLIC  := "Pedido "+M->C5_NUM+" (T.A.2)"
				SZP->ZP_STATUS  := '1'
				SZP->ZP_LOCAL   := QRYCXF->BF_LOCAL			                                                                                        			
				SZP->ZP_LOCALIZ := QRYCXF->BF_LOCALIZ
				SZP->ZP_LOTECTL := QRYCXF->BF_LOTECTL
			SZP->(MsUnlock())
			SZP->(DbCommit())    
		EndIf				
		SZP->(dbSetFilter({|| .t.},".t.")) 
	EndIf
	QRYCXF->(dbSkip())
EndDo       
QRYCXF->(dbCloseArea())

Return nTransf    
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณM410STTS  บAutor  ณMicrosiga           บ Data ณ  06/17/16   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/     
Static Function DipTemQtd(cFil,cProd,nQtd)
Local cSQL 	  := ""
Local lRet    := .F.
DEFAULT cFil  := ""
DEFAULT cProd := ""
DEFAULT nQtd  := 0

cSQL := " SELECT "
cSQL += "	SUM(B8_SALDO-B8_EMPENHO) QTD "
cSQL += "	FROM "
cSQL += 		RetSQLName("SB8")
cSQL += "		WHERE "
cSQL += "			B8_FILIAL  = '"+cFil+"' AND "
cSQL += "			B8_PRODUTO = '"+cProd+"' AND "
cSQL += "			B8_SALDO   > 0 AND "
cSQL += "			D_E_L_E_T_ = ' ' "
       
cSQL := ChangeQuery(cSQL)		
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),"QRYTQTD",.T.,.T.) 

If !QRYTQTD->(Eof())
	If QRYTQTD->QTD >= nQtd
		lRet := .T.
	EndIf
EndIf
QRYTQTD->(dbCloseArea())

Return lRet     
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณM410STTS  บAutor  ณMicrosiga           บ Data ณ  09/13/16   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function DipRQtdC9(cPedido,cProduto,cItem,nQtdVen)
Local cSQL 		:= ""
DEFAULT nQtdVen := 0

cSQL := " SELECT "
cSQL += " 	SUM(C9_QTDORI) QTD "
cSQL += "	FROM "
cSQL += "	  "+RetSQLName("SC9")+" WITH(NOLOCK) "
cSQL += "		WHERE "
cSQL += "			C9_FILIAL	= '"+xFilial("SC9")+"' AND "
cSQL += "			C9_PEDIDO 	= '"+cPedido+"' AND "
cSQL += "			C9_PRODUTO 	= '"+cProduto+"' AND "
cSQL += "			C9_ITEM		= '"+cItem+"' AND "
cSQL += "			D_E_L_E_T_  = ' ' "
	
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),"QQTDC9",.T.,.T.) 
  
If !QQTDC9->(Eof())
	If QQTDC9->QTD<>nQtdVen
		nQtdVen := QQTDC9->QTD
	EndIf
EndIf
QQTDC9->(dbCloseArea())
	
Return nQtdVen
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณM410STTS  บAutor  ณMicrosiga           บ Data ณ  09/16/16   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Verifica se existe contrato pendente para o item do pedido บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function VldConPen(cPedido)
Local cSQL := ""

cSQL := " SELECT "
cSQL += " 	C5_NUM "
cSQL += " 	FROM "
cSQL +=  		RetSQLName("SC5")
cSQL += " 		INNER JOIN "
cSQL +=  			RetSQLName("SC6")
cSQL += " 			ON "
cSQL += " 				C5_FILIAL = C6_FILIAL AND "
cSQL += " 				C5_NUM 	  = C6_NUM "
cSQL += " 		INNER JOIN "
cSQL +=  			RetSQLName("SA1")
cSQL += " 			ON "
cSQL += " 				A1_FILIAL = '"+xFilial("SA1")+"' AND "
cSQL += " 				A1_COD 	  = C5_CLIENTE AND "
cSQL += " 				A1_LOJA   = C5_LOJACLI "
cSQL += " 		INNER JOIN "
cSQL +=  			RetSQLName("ZZF")
cSQL += " 			ON "
cSQL += " 				ZZF_FILIAL   = '"+xFilial("ZZF")+"' AND "
cSQL += "				((A1_GRPVEN  <> ' ' AND "
cSQL += "				ZZF_GRPVEN 	 = A1_GRPVEN) OR "
cSQL += "				(ZZF_CODCLI  = A1_COD AND "
cSQL += "				ZZF_LOJA   	 = A1_LOJA )) "
cSQL += " 		INNER JOIN "
cSQL +=  			RetSQLName("ZZG")
cSQL += " 			ON "
cSQL += " 				ZZG_FILIAL = '"+xFilial("ZZG")+"' AND "
cSQL += " 				ZZG_CODIGO = ZZF_CODIGO AND "
cSQL += " 				ZZG_PRODUT = C6_PRODUTO "
cSQL += " 		WHERE "
cSQL += " 			C5_FILIAL 	 = '"+xFilial("SC5")+"' AND "
cSQL += " 			C5_NUM 		 = '"+cPedido+"' AND "
cSQL += " 			ZZF_ATIVO 	 <> '1' AND "
cSQL += " 			ZZF_DATAFI 	 >= '"+DtoS(dDataBase)+"' AND "
cSQL +=  			RetSQLName("SC5")+".D_E_L_E_T_ = ' ' AND "
cSQL +=  			RetSQLName("SC6")+".D_E_L_E_T_ = ' ' AND "
cSQL +=  			RetSQLName("ZZF")+".D_E_L_E_T_ = ' ' AND "
cSQL +=  			RetSQLName("ZZG")+".D_E_L_E_T_ = ' ' AND "
cSQL +=  			RetSQLName("SA1")+".D_E_L_E_T_ = ' ' "

cSQL := ChangeQuery(cSQL)		
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),"QRYCON",.T.,.T.) 

lRet := !QRYCON->(Eof())  
QRYCON->(dbCloseArea())

Return lRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณM410STTS  บAutor  ณMicrosiga           บ Data ณ  09/19/16   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/    
User Function DipCicPri(cPedido)
Local cMsgCIC 	 := ""
Local _aMsg   	 := {}
Local _cFrom     := "protheus@dipromed.com.br"
Local _cFuncSent := "DipCicPri(M410STTS.PRW)       			
Local _cAssunto  := "PRIORIDADE - CX. FECHADA"
Local _cMsgCICCx := GetNewPar("ES_CICCXFE","DIEGO.DOMINGOS,MAXIMO.CANUTO,EXPEDICAOCD,EDVAN.MATIAS")
Local _cMsgMaiCx := GetNewPar("ES_MAICXFE","diego.domingos@dipromed.com.br;"+SUPERGETMV("MV_#EMLTI",.F.,"ti@dipromed.com.br")+";expedicao@dipromed.com.br;edvan.matias@dipromed.com.br")
DEFAULT cPedido  := ""

cMsgCIC := "PRIORIDADE - CX. FECHADA"+CHR(10)+CHR(13)
cMsgCIC += "PEDIDO: "+AllTrim(cPedido)+CHR(10)+CHR(13)
cMsgCIC += "Pedido com prioridade na gera็ใo de Ordem de Separa็ใo."+CHR(10)+CHR(13)
cMsgCIC += "Cliente nใo aceita fracionados."+CHR(10)+CHR(13)
cMsgCIC += "Favor, agilizar a gera็ใo da O.S."

U_DIPCIC(cMsgCIC,_cMsgCICCx)

Aadd( _aMsg , { "Pedido: "       	, AllTrim(cPedido)  } )
Aadd( _aMsg , { "Data/Hora: "       , DtoC(dDataBase)+" - "+SubStr(Time(),1,2)+":"+SubStr(Time(),4,2) } )
Aadd( _aMsg , { "Usuแrio:  "        , U_DipUsr() } )
	
U_UEnvMail(_cMsgMaiCx,_cAssunto,_aMsg,"",_cFrom,_cFuncSent)       

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณM410STTS  บAutor  ณMicrosiga           บ Data ณ  09/19/16   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/    
User Function DipCicCxP(cPedido,aMsgCIC)
Local cMsgCIC 	 := ""
Local _aMsg   	 := {}
Local _cFrom     := "protheus@dipromed.com.br"
Local _cFuncSent := "DipProbCx(M410STTS.PRW)       			
Local _cAssunto  := "Aceite produto fracionado"
Local _cMsgCICCx := GetNewPar("ES_CICCXFE","DIEGO.DOMINGOS,MAXIMO.CANUTO,EXPEDICAOCD,EDVAN.MATIAS")
Local _cMsgMaiCx := GetNewPar("ES_MAICXFE","diego.domingos@dipromed.com.br;"+SUPERGETMV("MV_#EMLTI",.F.,"ti@dipromed.com.br")+";expedicao@dipromed.com.br;edvan.matias@dipromed.com.br")
Local nI
DEFAULT cPedido  := ""
DEFAULT aMsgCIC  := {}

cMsgCIC := "CX. FECHADA"+CHR(10)+CHR(13)
cMsgCIC += "PEDIDO: "+AllTrim(cPedido)+CHR(10)+CHR(13)
cMsgCIC += "A vendedora aceitou o envio de caixa fracionada para o(s) iten(s):"+CHR(10)+CHR(13)

Aadd( _aMsg , { "Pedido: "     , AllTrim(cPedido)  } )

For nI:=1 to Len(aMsgCIC)
	cMsgCIC += AllTrim(aMsgCIC[nI])+"/"
	Aadd( _aMsg , { "Produto: ", AllTrim(aMsgCIC[nI]) } )
Next nI

Aadd( _aMsg , { "Data/Hora: "  , DtoC(dDataBase)+" - "+SubStr(Time(),1,2)+":"+SubStr(Time(),4,2) } )
Aadd( _aMsg , { "Usuแrio:  "   , U_DipUsr() } )

U_DIPCIC(cMsgCIC,_cMsgCICCx)	
U_UEnvMail(_cMsgMaiCx,_cAssunto,_aMsg,"",_cFrom,_cFuncSent)       

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณM410STTS  บAutor  ณMicrosiga           บ Data ณ  01/02/17   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function DipVPerCIF()
Local cSQL 	 := " "   
Local lRet   := .T.
Local nValor := ValorPedido(SC5->C5_NUM,.F.)
Local nVlrFre:= u_ClcLimite("CONSULTA",nValor,SC5->C5_PBRUTO)

cSQL := " SELECT "
cSQL += " 	ZZB_PERC "
cSQL += " 	FROM "
cSQL +=  		RetSQLName("ZZB")
cSQL += " 		WHERE "
cSQL += " 			ZZB_FILIAL = '"+xFilial("ZZB")+"' AND "
cSQL += " 			ZZB_UF 	   = '"+SC5->C5_ESTE+"'AND "
cSQL += " 			D_E_L_E_T_ = ' ' "

cSQL := ChangeQuery(cSQL)		
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),"QRYZZB",.T.,.T.) 

If !QRYZZB->(Eof())
    If (nVlrFre*100)/nValor > QRYZZB->ZZB_PERC
    	lRet := .F.
    EndIf
EndIf
QRYZZB->(dbCloseArea())

Return lRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณM410STTS  บAutor  ณMicrosiga           บ Data ณ  01/02/17   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function DipVCxLot(cProduto,nQtdVen, _cLocal)
Local cSQL    := ""
Local cSubCon := ""
Local lRet    := .F.   
DEFAULT _cLocal := '01'  

cSubCon := " (SELECT "
cSubCon += " 	SUM(DD_SALDO) "
cSubCon += " 	FROM "
cSubCon +=  		RetSQLName("SDD")
cSubCon += " 		WHERE "
cSubCon += " 			DD_FILIAL = '"+xFilial("SDD")+"' AND "
cSubCon += " 			DD_PRODUTO = '"+cProduto+"' AND "
cSubCon += " 			DD_SALDO > 0 AND "
cSubCon += " 			DD_LOCAL = '"+_cLocal+"' AND  "
cSubCon += 				RetSQLName("SDD")+".D_E_L_E_T_ = ' ') "

cSQL := " SELECT " 
cSQL += " 	BF_PRODUTO, BF_LOTECTL, BF_LOCAL, SUM(BF_QUANT-BF_EMPENHO)-ISNULL("+cSubCon+",0) QUANT "	
cSQL += " 	FROM "
cSQL += 		RetSQLName("SBF")
cSQL += " 		WHERE "
cSQL += " 			BF_FILIAL  = '"+xFilial("SBF")+"' AND "
cSQL += " 			BF_PRODUTO = '"+cProduto+"' AND " 
cSQL += " 			BF_LOCAL   = '"+_cLocal+"' AND " 
cSQL += " 			BF_QUANT   > 0 AND "			
cSQL +=  			RetSQLName("SBF")+".D_E_L_E_T_ = ' ' "
cSQL += " GROUP BY BF_PRODUTO, BF_LOTECTL, BF_LOCAL "		

cSQL := ChangeQuery(cSQL)		
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),"QRYSBF",.T.,.T.)

While !QRYSBF->(Eof())
	If !lRet .And. QRYSBF->QUANT >= nQtdVen .And. QRYSBF->BF_LOCAL == '01'
		SC6->(RecLock("SC6"))
			SC6->C6_LOTECTL := QRYSBF->BF_LOTECTL
		SC6->(MsUnLock())
		lRet := .T.
	EndIf
	QRYSBF->(dbSkip())
EndDo
QRYSBF->(dbCloseArea())

If !lRet .And. !Empty(SC6->C6_LOTECTL)
	SC6->(RecLock("SC6"))
		SC6->C6_LOTECTL := " "
	SC6->(MsUnLock())
EndIf

Return lRet

/*-------------------------------------------------------------------------
+ RBORGES - 05/01/2018 ----- User Funcion: DIPVCIC()                      +
+ Enviarแ CIC quando a validade da licen็a do cliente estiver vencida     +
-------------------------------------------------------------------------*/

//*--------------------------------------------------------------------------*
Static Function DIPVCIC(_cCliente,_cNomeCli,_cVended)
//*--------------------------------------------------------------------------*

Local aArea       := GetArea()
Local cDeIc       := "protheus@dipromed.com.br"
Local cCICDest    := Upper(GetNewPar("ES_M410CIC","MAXIMO.CANUTO")) // Usuแrios que receberใo CICดs
Local cAttachIc   :=  "  a"
Local cVend       := Posicione("SA3",1,xFilial("SA3")+_cVended,"A3_NREDUZ")
Local cCIC        := AllTrim(Posicione("SU7",1,xFilial("SU7")+SC5->C5_OPERADO,"U7_CICNOME"))
Local cOperador   := AllTrim(Posicione("SU7",1,xFilial("SU7")+SC5->C5_OPERADO,"U7_NOME"))

cCICDest:=AllTrim(cCICDest)+","+cCIC

_aMsgIc := {}
cMSGcIC       := " AVISO - CLIENTE COM LICENวA VENCIDA" +CHR(13)+CHR(10)+CHR(13)+CHR(10)+CHR(13)+CHR(10)
cMSGcIC       += " ATENวรO: Solicitar URGENTE a renova็ใo da licen็a sanitแria ao cliente!" +CHR(13)+CHR(10)
cMSGcIC       += " CLIENTE :"+_cCliente+"" +CHR(13)+CHR(10)
cMSGcIC       += " NOME : "+_cNomeCli+""    +CHR(13)+CHR(10)
cMSGcIC       += " PEDIDO : "+SC5->C5_NUM+""    +CHR(13)+CHR(10)
cMSGcIC       += " VENDEDOR: "+_cVended+"-"+cVend+" / "+"OPERADOR: "+SC5->C5_OPERADO+"-"+cOperador

 U_DIPCIC(cMSGcIC,cCICDest)

RestArea(aArea)
return()

/*-----------------------------------------------------------------------------
+ RBORGES Data: 05/01/2018 Fun็ใo: DIPVEMAIL()                                +
+ Essa fun็ใo enviarแ e-mail para os usuแrios contidos no parโmetro,          +
+ quando a validade da licen็a do cliente estiver vencida.                    +
-----------------------------------------------------------------------------*/
//*--------------------------------------------------------------------------*
Static Function DIPVEMAIL(_cCliente,_cNomeCli,_cVended)
//*--------------------------------------------------------------------------*

Local cDeIc       := "protheus@dipromed.com.br"
Local cEmailIc    := GetNewPar("ES_M410EMA",SUPERGETMV("MV_#EMLTI",.F.,"ti@dipromed.com.br"))  //Usuแrios que receberใo e-mails
//Local cAssuntoIc  := EncodeUTF8("AVISO - CLIENTE COM LICENวA VENCIDA, " +_cCliente+ "! ","cp1252")
Local cAssuntoIc  := "AVISO - CLIENTE COM LICENวA VENCIDA, " +_cCliente+ "! "
Local cAttachIc   :=  "  a"
Local cFuncSentIc :=   "M410STTS.PRW"
Local cVend       := Posicione("SA3",1,xFilial("SA3")+_cVended,"A3_NREDUZ")
Local cMail       := AllTrim(Posicione("SU7",1,xFilial("SU7")+SC5->C5_OPERADO,"U7_EMAIL"))
Local cOperador   := AllTrim(Posicione("SU7",1,xFilial("SU7")+SC5->C5_OPERADO,"U7_NOME"))

cEmailIc         :=Alltrim(cEmailIc)+";"+cMail 


_aMsgIc := {}
cMSGcIC       := cAssuntoIc+" - "+_cCliente+ " " +CHR(13)+CHR(10)+CHR(13)+CHR(10)


aAdd( _aMsgIc , { "AVISO:   ","Solicitar URGENTE a renova็ใo da licen็a sanitแria ao cliente!"})
aAdd( _aMsgIc , { "CLIENTE  ", +_cCliente})
aAdd( _aMsgIc , { "NOME     ", +_cNomeCli})
aAdd( _aMsgIc , { "PEDIDO   ", +SC5->C5_NUM})
aAdd( _aMsgIc , { "VENDEDOR ", +_cVended+"-"+cVend+" / "+"OPERADOR: "+SC5->C5_OPERADO+"-"+cOperador})


U_UEnvMail(cEmailIc,cAssuntoIc,_aMsgIc,cAttachIc,cDeIc,cFuncSentIc)

return()  


User Function AmostrasHQ() 
Local lRet := .F.

If !"TMK" $FunName() .And. SC5->C5_TIPO = "N" .And. !("DIPAL10" $ Funname())

	SC6->(dbSetOrder(1))
	If SC6->(dbSeek(xFilial("SC6")+SC5->C5_NUM))
		While !SC6->(Eof()) .And. SC6->C6_NUM == SC5->C5_NUM
			If ((AllTrim(SC6->C6_CF) $ '5911/6911' .AND. cEmpAnt = '04'))   
				lRet := .T.
			EndIf
			SC6->(DbSkip())
			Enddo
		EndIf
Endif

Return lRet 

/*
+----------------------------------------------------------------------------+
|Fun็ใo: BIONEXO()   |         Autor: RBORGES |             Data: 29/10/2018 |
+----------------------------------------------------------------------------+
|Janela com pergunta se o pedido ้ ou nใo bionexo.                           |
+----------------------------------------------------------------------------+
 */

User Function Bionexo()

Local oDlg
Local lRet   := .F.

aRadio := {"Sim       ","Nใo"}

nRadio := 0	

Define MsDialog oDlg From 005,010 To 015,040 title "Pedido Bionexo" style 128
@ 010,020 say "Pedido ้ BIONEXO?"
@ 020,020 RADIO aRadio VAR nRadio
@ 050,020 BmpButton Type 1 Action (IIf(nRadio <> 0 ,U_GrvEsc(nRadio,@lRet), MsgInfo("Escolha uma op็ใo!","Atencao")),(IIf(lRet,Close(oDlg),)))

oDlg:lEscClose := .F.
Activate Dialog oDlg Centered

Return

/*
+----------------------------------------------------------------------------+
|Fun็ใo: GRPESC() |         Autor: RBORGES |                Data: 29/10/2018 |
+----------------------------------------------------------------------------+
|Gravar escolha do usuแrio no campo C5_BIONEXO.                              |
+----------------------------------------------------------------------------+
 */

User Function GrvEsc(nOpcao,lRet)

If     nOpcao == 1
	//Aviso("Aten็ใo","Escolha, SIM!",{"Ok"},1)
	SC5->(RecLock('SC5',.F.))
		SC5->C5_BIONEXO := 'SIM'
	SC5->(MsUnlock())
		lRet := .T.
ElseIf nOpcao == 2
	//Aviso("Aten็ใo","Escolha, NรO!",{"Ok"},1)
	SC5->(RecLock('SC5',.F.))
		SC5->C5_BIONEXO := 'NAO'
	SC5->(MsUnlock())
	lRet := .T.
EndIf

Return(lRet)

/*-----------------------------------------------------------------------------------
REGINALDO BORGES 08/02/2019
Fun็ใo........:  TRANSFE()                                
Objetivo......:  Mostrar os produtos que tiveram solicita็ใo de transfer๊ncia 
				na inclusใo do pedido.	
-------------------------------------------------------------------------------------*/

User Function TRANSFE(_cPedi,_cOrigem)  

Local cQuery   := ''
Local _cNota   :=''
Local aTransf  :={}
Local oFont24  := TFont():New("Times New Roman",9,24,.T.,.T.,5,.T.,5,.T.,.F.)
Local oFont16  := TFont():New("Arial",9,14,.T.,.T.,5,.T.,5,.T.,.F.)
Local oFont30  := TFont():New("Arial",9,28,.T.,.T.,5,.T.,5,.T.,.F.)
Private oLbx     

U_DIPPROC(ProcName(0),U_DipUsr()) // Gravando o nome do Programa no SZU

cQuery := "SELECT ZP_CODIGO  'CODIGO', ZP_PRODUTO 'PRODUTO', ZP_QUANT   'QUANT', ZP_DTSOLIT 'DATA', ZP_USERSOL 'USUARIO',  (CASE WHEN ZP_EMPORIG = '1' THEN 'MTZ' ELSE 'CD' END) 'ORIGEM', ZP_EXPLIC 'PEDIDO', (CASE WHEN ZP_STATUS = '1' THEN 'Pendente' ELSE 'Transferido' END) 'STATUS' "
cQuery += " FROM " + RetSQLName("SZP")
cQuery += " WHERE ZP_EMPORIG = '"+_cOrigem+"'"
cQuery += "   AND SUBSTRING(ZP_EXPLIC,8,14)  = '"+_cPedi+"'"
//cQuery += "   AND ZP_DTSOLIT = '"+DtoS(dDataBase)+"' "
cQuery += "   AND D_E_L_E_T_ = '' "
cQuery += "ORDER BY R_E_C_N_O_ ASC "

cQuery := ChangeQuery(cQuery)

DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"SZPT",.T.,.T.)

dbSelectArea("SZPT")
dbGotop()

While ! SZPT->(Eof())
	*             1             2                       3            4                 5                       6                      7                     8
	aadd(aTransf,{SZPT->CODIGO, AllTrim(SZPT->PRODUTO), SZPT->QUANT, STOD(SZPT->DATA), AllTrim(SZPT->USUARIO), AllTrim(SZPT->ORIGEM), AllTrim(SZPT->PEDIDO),SZPT->STATUS})
	
	SZPT->(DbSkip())
EndDo

If  Len(aTransf) > 0

	Define msDialog oDlg Title "Transfer๊ncia solicitada para o pedido '"+_cPedi+"'" From 000,000 TO 015,085
		
	@ 005,005 LISTBOX oLbx FIELDS HEADER "Status","Codigo", "Produto", "Quantidade", "Data", "Usuario", "Empresa Solic", "Pedido" SIZE 330,090 OF oDlg PIXEL
	oLbx:SetArray( aTransf )
	oLbx:bLine := {|| {aTransf[oLbx:nAt,8],aTransf[oLbx:nAt,1],aTransf[oLbx:nAt,2],aTransf[oLbx:nAt,3],aTransf[oLbx:nAt,4],aTransf[oLbx:nAt,5],aTransf[oLbx:nAt,6],aTransf[oLbx:nAt,7]}}
	@ 100,290 BUTTON oBOTAOFECHAR PROMPT "&Fechar" SIZE 040,010 PIXEL OF oDLG ACTION (oDLG:END())
	
	Activate dialog oDlg centered
	
Else
	MsgInfo("Nใo houve solicita็ใo de transfer๊ncia para este pedido.","ATENวรO!")
EndIf

    SZPT->(dbCloseArea())

Return()


/*-----------------------------------------------------------------------------------
REGINALDO BORGES 15/04/2019
Fun็ใo........:  SALDPROD()                                
Objetivo......:  Montar um array com os produtos do pedido que zeraram o estoque e
                 enviar para compras.
-------------------------------------------------------------------------------------*/

Static Function SALDPROD(_cPedido)

Local aArea     := GetArea()
Local aAreaSC61 := SC6->( GetArea() )
Local aAreaSC51 := SC5->( GetArea() )
Local aProSaldo := {} 
Local cSQL      := ""
Local cEmail    := ""

DbSelectArea("SC6")
DbSetOrder(1)
SC6->(DbSeek(xFilial("SC6")+_cPedido))
While SC6->C6_NUM == _cPedido
	//RETIRADO O B2_FILIAL DA QUERY PARA CONSIDERAR APENAS QUANDO NAO TIVER SALDO NAS DUAS FILIAIS - FELIPE DURAN - 16/11/19
	cSQL :=" SELECT B2_COD, B1_DESC, B1_PROC, (SELECT DISTINCT(A2_NOME) FROM "+RetSqlName("SA2")+" WHERE A2_COD = B1_PROC)'FORNECEDOR', "	
	cSQL +=" (SUM(B2_QATU- B2_RESERVA - B2_QACLASS+B2_SALPEDI)) 'SALDO', CONVERT(CHAR(10), GETDATE(),103) 'DATA' "
	cSQL +=" FROM "+RetSqlName("SB2")+", "+RetSqlName("SB1") 
	cSQL +=" WHERE "
	cSQL +=" B2_FILIAL IN ('01','04') AND "
	cSQL +=" B1_FILIAL = B2_FILIAL    AND "
	cSQL +=" B2_COD    = '"+SC6->C6_PRODUTO+"'     AND "
	cSQL +=" B2_LOCAL  = '01'         AND "
	cSQL +=" B1_COD    = B2_COD       AND "
	//cSQL +=" (B2_QATU-B2_RESERVA-B2_QACLASS) <= 0 AND "
	cSQL +=" "+RetSqlName("SB2")+".D_E_L_E_T_ = '' AND "
	cSQL +=" "+RetSqlName("SB1")+".D_E_L_E_T_ = '' "
	cSQL +=" GROUP BY B2_COD, B1_DESC, B1_PROC HAVING (SUM(B2_QATU- B2_RESERVA - B2_QACLASS+B2_SALPEDI)) <= 0  "
	 
	cSQL := ChangeQuery(cSQL)
	DbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),"SLDB2",.T.,.T.)
	 
	If !SLDB2->(Eof())
	
		aadd(aProSaldo,{SLDB2->B2_COD, SLDB2->B1_DESC, SLDB2->B1_PROC, SLDB2->FORNECEDOR, SLDB2->SALDO, SLDB2->DATA})
		
	EndIf
	
	SC6->(DbSkip())
	SLDB2->(dbCloseArea())
Enddo

If Len(aProSaldo) > 0
	cEmail   := "compras@dipromed.com.br;felipe.duran@dipromed.com.br"
	cAssunto := EncodeUTF8("Estoque zerado na confirma็ใo do pedido "+_cPedido+"!","cp1252") 
	ENV_SLDB2(aProSaldo,cEmail,cAssunto)
EndIf


SC6->(DbCloseArea())

RestArea( aAreaSC51 )
RestArea( aAreaSC61 )
RestArea( aArea )

Return()

/*==========================================================================\
|Programa  | ENV_SLDB2 | Autor | Reginaldo Borges   |    Data ณ 15/04/2019  |
|===========================================================================|
|Desc.     | Envio de EMail na confirmacao do pedido para os produtos que   |
|          |que zeraram o estoque.                                          |  
|===========================================================================|
|Sintaxe   | ENV_SLDB2                                                      |
|===========================================================================|
|Uso       | Especifico DIPROMED                                            |
\==========================================================================*/

Static Function ENV_SLDB2(aProSaldo,cEmail,cAssunto)

Local cAccount  := Lower(Alltrim(GetMv("MV_RELACNT")))
Local cFrom     := Lower(Alltrim(GetMv("MV_RELACNT")))
Local cPassword := Alltrim(GetMv("MV_RELPSW"))
Local cServer   := Alltrim(GetMv("MV_RELSERV"))
Local cEmailTo  := cEmail
Local cEmailCc  := ""
Local cEmailBcc := ""
Local lResult   := .F.
Local cError    := ""
Local cMsg      := ""
Local lSmtpAuth := GetNewPar("MV_RELAUTH",.F.)
Local lAutOk	:= .F.
Local CATTACH   := "a"
Local nI
/*=============================================================================*/
/*Definicao do cabecalho do email                                              */
/*=============================================================================*/
cMsg := ""
cMsg += '<html>'
cMsg += '<head>'
cMsg += '<title>' +cAssunto + '</title>'
cMsg += '</head>'
cMsg += '<body>'
cMsg += '<HR Width=100% Size=3 Align=Centered Color=Red><P>'
cMsg += '<Table Align=Center BorderColor=#000000 CELLPADDING=4 CELLSPACING=0 Width=100%>'

cMsg += '<table width="100%">'
cMsg += '<tr>'
cMsg += '<td width="100%" align="center"><font size="4" color="red"> DIPROMED </font></td>'
cMsg += '</tr>'
cMsg += '</table>'

cMsg += '<hr width="100%" size="3" align="center" color="#000000">'

cMsg += '<table width="100%" cellspacing="0" cellpadding="0"><font size="3" >'
cMsg += '<tr>'
cMsg += '<td Width="8%"  Align="LEFT"  ><B>Produto</B></td>'
cMsg += '<td Width="34%" Align="LEFT"  ><B>Descri็ใo</B></td>'
cMsg += '<td Width="8%"  Align="LEFT"  ><B>Cod_For</B></td>'
cMsg += '<td Width="34%" Align="LEFT"  ><B>Nome Fornecedor</B></td>'
cMsg += '<td Width="9%"  Align="LEFT"  ><B>Est. Disponํvel</B></td>'
cMsg += '<td Width="7%"  Align="LEFT"  ><B>Data</B></td>'
cMsg += '</tr>'
cMsg += '</font></table>'

cMsg += '<hr width="100%" size="2" align="center" color="#000000">'

For nI := 1 to Len(aProSaldo)
	
nLin := nI

	If Mod(nLin,2) == 0
		
		cMsg += '<table width="100%" border="0" cellspacing="0" cellpadding="0">'
		cMsg += '<tr bgcolor="#F8F8FF">'
		cMsg += '<td width="8%  " Align="Left"><font  size="2">'+aProSaldo[nLin,1]+'</font></td>'
		cMsg += '<td width="34% " Align="Left"><font  size="2">'+aProSaldo[nLin,2]+'</font></td>'		
		cMsg += '<td width="8%  " Align="Left"><font  size="2">'+aProSaldo[nLin,3]+'</font></td>'
		cMsg += '<td width="34% " Align="Left"><font  size="2">'+aProSaldo[nLin,4]+'</font></td>'
		cMsg += '<td width="9%  " Align="Left"><font  size="2">'+CVALTOCHAR(aProSaldo[nLin,5])+'</font></td>'
		cMsg += '<td width="7%  " Align="Left"><font  size="2">'+aProSaldo[nLin,6]+'</font></td>'
		cMsg += '</tr>'
		cMsg += '</table>'
		
	Else
		
		cMsg += '<table width="100%" border="0" cellspacing="0" cellpadding="0">'
		cMsg += '<tr bgcolor="#F8F8FF">'
		cMsg += '<td width="8%  " Align="Left"><font  size="2">'+aProSaldo[nLin,1]+'</font></td>'
		cMsg += '<td width="34% " Align="Left"><font  size="2">'+aProSaldo[nLin,2]+'</font></td>'		
		cMsg += '<td width="8%  " Align="Left"><font  size="2">'+aProSaldo[nLin,3]+'</font></td>'
		cMsg += '<td width="34% " Align="Left"><font  size="2">'+aProSaldo[nLin,4]+'</font></td>'
		cMsg += '<td width="9%  " Align="Left"><font  size="2">'+CVALTOCHAR(aProSaldo[nLin,5])+'</font></td>'
		cMsg += '<td width="7%  " Align="Left"><font  size="2">'+aProSaldo[nLin,6]+'</font></td>'
		cMsg += '</tr>'
		cMsg += '</table>'
		
	EndIf

nLin  += 1
	
Next

cMsg += '<table width="100%" cellspacing="0" cellpadding="0"><font size="2" color="blue">'
cMsg += '<tr>'
cMsg += '<td>==========================================================================================================================================================================================</td>'
cMsg += '</tr>'
cMsg += '</font></table>'

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Definicao do rodape do email                                                ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
cMsg += '</Table>'
cMsg += '<HR Width=100% Size=3 Align=Centered Color=Red> <P>'
cMsg += '<table width="100%" Align="Center" border="0">'
cMsg += '<tr align="center">'                  																								
cMsg += '<td colspan="10"><font color="BLUE" size="2">Mensagem enviada automaticamente pelo sistema PROTHEUS - <font color="BLUE" size="1">(SALDPROD(M410STTS).PRW)</td>'
cMsg += '</tr>'
cMsg += '</table>'
cMsg += '</body>'
cMsg += '</html>'

/*
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
		ATTACHMENT  cAttach;
		RESULT lResult
		
		If !lResult
			//Erro no envio do email
			GET MAIL ERROR cError
			
			MsgInfo(cError,OemToAnsi("Atencao"))
		EndIf
		
		DISCONNECT SMTP SERVER
	Else
		//Erro na conexao com o SMTP Server
		GET MAIL ERROR cError
		
		MsgInfo(cError,OemToAnsi("Atencao"))
	EndIf
*/
    
If GetNewPar("ES_ATIVJOB",.T.)   
	u_UEnvMail(AllTrim(cEmailTo),cAssunto,nil,"",cFrom,"ENV_SLDB2(M410STTS.prw)",cMsg)
EndIf


Return(.T.)

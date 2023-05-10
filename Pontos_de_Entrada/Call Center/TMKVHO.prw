/*
Nome do Ponto de Entrada	TMKVHO
Execução	Antes de carregar o atendimento selecionado na consulta de histórico da rotina de Televendas
Parâmetros	Número do atendimento
Objetivo	Uso especifico do usuário
Retorno Esperado	Nenhum
*/

#INCLUDE "RWMAKE.CH"
*-----------------------------------------*
User Function TMKVHO(UA_NUM)
*-----------------------------------------*
Local _cMsg  := ""
Local _lRet  := .T.
Local _xArea := GetArea()
Local lVHORejeita := .f.
Local lVHOEstorno := .f.
Local cFilSUA := xFilial("SUA")
Local cFilSUB := xFilial("SUB") 


Private _cCliEspecial := GetMV("MV_CLIESPE") // Cliente especial

Public _cOut := ""


U_DIPPROC(ProcName(0),U_DipUsr()) // JBS 05/10/2005 - Gravando o nome do Programa no SZU

SUA->(DbSetOrder(1))
SUA->(MsSeek(xFilial("SUA")+UA_NUM))

_status := If(SUA->UA_STATUS = "LIB","SUP",SUA->UA_STATUS)  //MCVN - 13/11/2007
_noper  := SUA->UA_OPER   
_nNota  := SUA->UA_DOC

lDip271Ok   := .f.  // Libera o Botão OK

M->UA_FRETE := SUA->UA_FRETE     // JBS 11/05/2006 - Carrega o Frete para usar no TMKVPA
M->UA_DESPESA := SUA->UA_DESPESA // JBS 06/JUN/2006 - Carrega a Despesae para usar no TMKVPA

SC5->(DbSetOrder(1))
If SC5->(MsSeek(xFilial("SC5")+SUA->UA_NUMSC5))
	If SC5->C5_PRENOTA == "S"
		_lRet := .F.
		_cMsg := "A Pre-Nota do pedido"+SC5->C5_NUM+" ja foi impressa. "
		_cMsg += "Não é permitido ALTERAÇÃO!!!" + Chr(13) + Chr(10)
		_cMsg += "Para alterar solicite o estorno."+ Chr(13) + Chr(10)+ Chr(13) + Chr(10)
		_cMsg += "Deseja solicitar o estorno?"
		lVHOEstorno := MsgYesNo(_cMsg,"Atenção")
	ElseIF SC5->C5_PRENOTA == "F"
		_lRet := .F.
		_cMsg := "O pedido "+SC5->C5_NUM+" está parado no financeiro. "
		_cMsg += "Não é permitido ALTERAÇÃO!!!" + Chr(13) + Chr(10)
		_cMsg += "Para alterar solicite a rejeição."+ Chr(13) + Chr(10)+ Chr(13) + Chr(10)
		_cMsg += "Deseja solicitar a rejeição?"
		lVHORejeita := MsgYesNo(_cMsg,"Atenção") 
	ElseIF SC5->C5_PRENOTA == "P"    //MCVN 06/07/2007 Verifica se o pedido está sendo separado no momento.
		_lRet := .F.
		_cMsg := "O pedido "+SC5->C5_NUM+" está sendo separado neste momento. "
		_cMsg += "Não é permitido ALTERAÇÃO!!!" + Chr(13) + Chr(10)
		_cMsg += "Para alterar solicite a rejeição." + Chr(13) + Chr(10) + Chr(13) + Chr(10)
		_cMsg += "Deseja solicitar a rejeição?"
		lVHOEstorno := MsgYesNo(_cMsg,"Atenção")        		
  	ElseIf !EMPTY(_nNota) // MCVN - 28/02/2007 	  		
  		_lRet := .F.   
		_cMsg := "O pedido "+SC5->C5_NUM+" ja foi faturado, NF:"+_nNota
  		_cMsg += ".  Não é possível alterar!!!" + Chr(13) + Chr(10)
		Alert(_cMsg,"Atenção")      
  	Elseif !BlqAltfPed() .And. Empty(_nNota) // Verifica se o pedido já foi manipulado pelo faturamento MCVN 12/04/2007
		_lRet := .F.
		_cMsg := "O pedido "+SC5->C5_NUM+" foi manipulado através do Faturamento "
		_cMsg += " ou foi faturado parcialmente. "+ Chr(13) + Chr(10)
		_cMsg += "não é mais permitida a ALTERAÇÃO pelo CallCenter!!!" + Chr(13) + Chr(10)
		_cMsg += "Favor alterar o pedido pelo Faturamento."+ Chr(13) + Chr(10)
	    Alert(_cMsg,"Atenção") 
	ElseIf _status="SUP" .and. _noper="1" .and. Empty(SC5->(C5_NOTA))
		SUA->(RecLock("SUA",.F.))
	  	SUA->UA_STATUS := ""
		SUA->(MsUnLock("SUA"))
		SUA->(DbCommit())  // MCVN 25/04/07

		// Salva campo que vamos ALTERAR
		_cOut := SC5->C5_PARCIAL
        
		// Bloqueia pedido no início da alteração - MCVN 10/04/2007
		SC5->(RecLock("SC5",.F.))
		SC5->C5_PARCIAL := "N"
		SC5->(MsUnLock())
		SC5->(DbCommit())  // MCVN 25/04/07
	Endif	
Endif
//----------------------------------------------
// Carrega array de controle de senhas
// JBS 30/05/2006
//----------------------------------------------
aDipSenhas := {}
aDipEndEnt := {}   // JBS 31/07/2006 - Após passar pela edição do Endereço de entrega

SUB->(DbSeek(cFilSUB+M->UA_NUM))
SB1->(DbSetOrder(1))

Do while SUB->(!EOF()).and. SUB->UB_FILIAL == cFilSUB .and. SUB->UB_NUM == M->UA_NUM
	
	If SB1->(DbSeek(xFilial("SB1")+SUB->UB_PRODUTO))
		If SB1->B1_TS <> SUB->UB_TES
			U_DipSenha("TES", SUB->UB_TES, SUB->UB_VRUNIT*1313*VAL(SUB->UB_TES), 0,.t.)
		EndIf
	EndIf
	
	If SUB->UB_MARGATU < SUB->UB_MARGITE
		If Empty(M->UA_CONDPG).or.(!Empty(M->UA_CONDPG) .And. SE4->E4_USERDES = 0)
			If !M->UA_CLIENTE $ _cCliEspecial
				U_DipSenha("MA2", SUB->UB_PRODUTO, SUB->UB_VLRITEM, 0,.t.)
			EndIf
		Endif
	EndIf
	SUB->(dbSkip())
EndDo

If lVHOEstorno                                                            
    //Alterado para o operador informar o motivo da solicitação do estorno  MCVN - 24/09/08
    nMot:=Aviso("Atenção","Qual o motivo da solicitação estorno. CANCELAR OU CORRIGIR O PEDIDO ?" ,{"Cancelar","Corrigir"})
    If nMot == 1
		U_VHOCIC(SC5->C5_NUM, "ESTORNO", "ESTORNO PARA CANCELAMENTO DO PEDIDO !")
    Else                                                                       
	    U_VHOCIC(SC5->C5_NUM, "ESTORNO", "ESTORNO PARA CORREÇÃO DO PEDIDO !")
    Endif
    nMot := 0
EndIf

If lVHORejeita
    //Alterado para o operador informar o motivo da solicitação da rejeição  MCVN - 24/09/08
    nMot:=Aviso("Atenção","Qual o motivo da solicitação estorno. CANCELAR OU CORRIGIR O PEDIDO ?" ,{"Cancelar","Corrigir"})
    If nMot == 1
    	U_VHOCIC(SC5->C5_NUM, "REJEITA", "REJEIÇÃO PARA CANCELAMENTO DO PEDIDO !")
    Else
		U_VHOCIC(SC5->C5_NUM, "REJEITA", "REJEIÇÃO PARA CORREÇÃO DO PEDIDO !")
    Endif
	nMot := 0
EndIf

RestArea(_xArea)
Return(_lRet)

*--------------------------------------------------------------------------*
User Function VHOCIC(cPedido, cTipo, cMotivo)
// JBS 23/05/2006 - Pedido estornado
*--------------------------------------------------------------------------*
Local cMail
Local cServidor   := GetMV("MV_CIC")     // Servidor para enviar mensagem pelo CIC
Local cOpFatRem   := GetMV("MV_REMETCI") // Usuario do CIC remetente de mensgens no Protheus
Local cOpFatSenha := "123456"
Local cOpFatDest  := AllTrim(If(cTipo=="ESTORNO",GetMV("MV_CICEST"),GetMV("MV_CICREJ")))

//
// Dados do Destinatario da Mensagem CIC
//
SA1->(dbSetOrder(1))
IF "TMK" $ FUNNAME()
	SA1->(dbSeek(xFilial("SA1") + M->UA_CLIENTE + M->UA_LOJA))
Else                                                          
	SA1->(dbSeek(xFilial("SA1") + SC5->C5_CLIENTE + SC5->C5_LOJACLI))
Endif

U_DiprKardex(cPedido,U_DipUsr(),,.T.,If(cTipo=="ESTORNO","30","29"))// JBS 29/08/2005
//
// Monta a mensagem a ser enviado ao operador
//
cMail := "IMPORTANTE"+ Chr(13) + Chr(10)+ Chr(13) + Chr(10)
cMail += StrTran(cOpFatDest,',',' ou ')+ Chr(13) + Chr(10)+ Chr(13) + Chr(10)
cMail += "Por favor, "+if(cTipo=="ESTORNO","estorne","rejeite")+" o pedido " +SC5->C5_NUM
cMail += " do Cliente "+AllTrim(SA1->A1_COD)+" - "+AllTrim(SA1->A1_NREDUZ)+"."+ Chr(13) + Chr(10)+ Chr(13) + Chr(10)
cMail += Upper(cMotivo) + Chr(13) + Chr(10)+ Chr(13) + Chr(10)
cMail += U_DipUsr()
//
// Envia a mensagem ao operador através do CIC
//    
U_DIPCIC(cMail,AllTrim(cOpFatDest))// RBorges 12/03/15
//WaitRun(cServidor+' '+cOpFatRem+' '+cOpFatSenha+' "'+AllTrim(cOpFatDest)+'" "'+cMail+'" ') // RBorges 12/03/15
Return() 




//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verificar se o pedido foi manipulado pelo faturamento³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static Function BlqAltfPed()

*--------------------------------------*
Local cFilSC6:=xFilial('SC6')
Local lRetorno:=.t.
Local nRecSC6:=SC6->(Recno())
Local nOrdSC5:=SC6->(IndexOrd())

SC6->(dbSetOrder(1))
SC6->(dbSeek(cFilSC6+SC5->C5_NUM))

Do While SC6->(!EOF()).and.SC6->C6_FILIAL==cFilSC6.and. SC6->C6_NUM == SC5->C5_NUM
	
	If EMPTY(SC6->C6_PEDCLI) .Or. !Empty(SC6->C6_NOTA) // MCVN - 28/02/2007 
		lRetorno := .f.
	Endif	
	
 	SC6->(DbSkip())
EndDo

SC6->(dbSetOrder(nOrdSC5))
SC6->(dbGoto(nRecSC6))

Return(lRetorno)
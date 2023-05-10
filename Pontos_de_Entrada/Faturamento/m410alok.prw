#include "rwmake.ch"
/*
PONTO.......: M410ALOK          PROGRAMA....: MATA410
DESCRIÇÄO...: EXECUTA ANTES DE ALTERAR PEDIDO VENDA
UTILIZAÇÄO..: Executado antes de iniciar a alteracao do pedido de venda
PARAMETROS..: Nenhum
RETORNO.....: Variavel logica, sendo: .T. Prossegue alteracao do Pedido de Venda E .F. Impede alteracao no pedido de venda
OBSERVAÇÖES.: <NENHUM>
*/
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³ M410ALOK º Autor ³   Alexandro Dias   º Data ³  10/01/02   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Nao permite alterar o pedido se a Pre-Nota ja foi Emitida. º±±
±±º          ³ Avisa para o usuario dar enter nas quantidades de todos os º±±
±±º          ³ itens do pedido.                                           º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function M410ALOK()

Local _xArea := GetArea()
Local _cMsg  := ""
Local _lRet  := .T.
Local lVHORejeita     := .f.
Local lVHOEstorno     := .f.  
Local nMot            :=  0
Local cLockPed		  := SC5->C5_NUM+"_"+cEmpAnt+cFilAnt
Private lItemLiber    := .f.
Private	lPodeExcluir  := .f.
Private lItemFaturado := .f.
Public _aABN :=Array(2)

If Type("l410Auto")<>"U" .And. l410Auto
	Return .T.
EndIf                    

If "MATA310"$Upper(FunName())
	Return .T.
EndIf


If !LockByName(cLockPed,.T.,.T.)
	Aviso("Atenção","O Pedido de venda: " + SC5->C5_NUM + " está em uso por outra estação!",{"Ok"},1)
	Conout("M410ALOK-LockByName Falhou: Pedido-"+SC5->C5_NUM+" Data-"+DtoC(ddatabase)+" Hora-"+Time()+" User-"+U_DipUsr())
	Return	
EndIf

//---------------------------------------------------------------------------------------
U_DIPPROC(ProcName(0),U_DipUsr()) // JBS 05/10/2005 - Gravando o nome do Programa no SZU  
//---------------------------------------------------------------------------------------
If ( Type("l410Auto") == "U" .OR. !l410Auto )
	If ALTERA .and. !Empty(SC5->C5_EMPENHO)
		MsgInfo("Pedido de Licitação, só pode ser alterado pelo sistema de licitação!"+;
		        " Para altera-lo, exclua o pedido, volte em licitações, e altere e "+;
		        " gere o pedido novamente","Atenção")
	EndIf
EndIf
If  ALTERA                               // JBS 01/03/2010
     M->C5_CLIENTE := SC5->C5_CLIENTE   // JBS 01/03/2010
     M->C5_LOJACLI := SC5->C5_LOJACLI   // JBS 01/03/2010
     M->C5_TIPO    := SC5->C5_TIPO      // JBS 01/03/2010
     If !U_DipV002()                    // JBS 01/03/2010
         Return(.F.)                    // JBS 01/03/2010
     EndIf                               // JBS 01/03/2010
EndIf                                    // JBS 01/03/2010
If SC5->C5_PRENOTA == "S" 
	_lRet := .F.
	_cMsg := "A Pre-Nota do pedido"+SC5->C5_NUM+" ja foi impressa. "
	_cMsg += "Não é permitido ALTERAÇÃO!!!" + Chr(13) + Chr(10)
	_cMsg += "Para alterar solicite o estorno." + Chr(13) + Chr(10) + Chr(13) + Chr(10)
	_cMsg += "Deseja solicitar o estorno?"
	lVHOEstorno := MsgYesNo(_cMsg,"Atenção")
ElseIF SC5->C5_PRENOTA == "F"
	_lRet := .F.
	_cMsg := "O pedido "+SC5->C5_NUM+" está parado no financeiro. "
	_cMsg += "Não é permitido ALTERAÇÃO!!!" + Chr(13) + Chr(10)
	_cMsg += "Para alterar solicite a rejeição." + Chr(13) + Chr(10) + Chr(13) + Chr(10)
	_cMsg += "Deseja solicitar a rejeição?"
	lVHORejeita := MsgYesNo(_cMsg,"Atenção")   
ElseIF SC5->C5_PRENOTA == "P"    //MCVN 06/07/2007
	_lRet := .F.
	_cMsg := "O pedido "+SC5->C5_NUM+" está sendo separado neste momento. "
	_cMsg += "Não é permitido ALTERAÇÃO!!!" + Chr(13) + Chr(10)
	_cMsg += "Para alterar solicite a rejeição." + Chr(13) + Chr(10) + Chr(13) + Chr(10)
	_cMsg += "Deseja solicitar a rejeição?"
	lVHOEstorno := MsgYesNo(_cMsg,"Atenção")
     
Elseif !ALTERA .and. !INCLUI  

	_lRet := .F.		
	U_LibExcluirPedido() 
		If !lItemLiber .and. !lItemFaturado           
	 		lPodeExcluir := .t.
			_lRet := .t.
			U_LibExcluirPedido() 
       	Endif	
Else    
     
	If Altera
 	
		_cMsg := "E necessario confirmar ( USANDO A TECLA <ENTER> ) a quantidade dos " + Chr(13)
		_cMsg := _cMsg + "itens do Pedido para que o SISTEMA reserve o ESTOQUE!!!"
	   //	MsgBox(_cMsg,"Atencao","ALERT")// Desabilitado  - MCVN  25/07/2009

		// Limpa o Campo C6_PedCli para permitir alterar o pedido ou excluir
		U_LibExcluirPedido()
	
		// Salvando campos que vamos ALTERAR, para ser usado caso o usuário desista da alteração
		_aABN[1] := SC5->C5_PARCIAL
	
		// Limpa as senhas Gravadas no SC5
		RecLock("SC5",.F.)   
		SC5->C5_PARCIAL := "N" // Bloqueia pedido no início da alteração  -  MCVN  10/04/2007
		SC5->(MsUnLock())
		SC5->(DbCommit())  // MCVN 25/04/07
		
 	Endif	
 	
EndIF

If lVHOEstorno                                                            
    //Alterado para o operador informar o motivo da solicitação do estorno  MCVN - 24/09/08
    nMot:=Aviso("Atenção","Qual o motivo da solicitação estorno. CANCELAR OU CORRIGIR O PEDIDO ?" ,{"Cancelar","Corrigir"})
    If nMot == 1
		U_VHOCIC(SC5->C5_NUM, "ESTORNO", "ESTORNO PARA CANCELAMENTO DO PEDIDO !")
    Else                                                                       
	    U_VHOCIC(SC5->C5_NUM, "ESTORNO", "ESTORNO PARA CORREÇÃO DO PEDIDO !")
    Endif         
    SC5->(RecLock("SC5",.F.))
    	SC5->C5_XBLQNF := "S"
    SC5->(MsUnLock())
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
    SC5->(RecLock("SC5",.F.))
    	SC5->C5_XBLQNF := "S"
    SC5->(MsUnLock())
	nMot := 0
EndIf

UnlockByName(cLockPed,.T.,.T.)
RestArea(_xArea)

Return(_lRet)
*--------------------------------------*
User Function LibExcluirPedido()
// JBS 16/01/2006
// A Campo C6_PEDCLI do Pedido antes
// de alterar o pedido.
*--------------------------------------*
Local cFilSC6:=xFilial('SC6')
Local lRetorno:=.t.
Local nRecSC6:=SC6->(Recno())
Local nOrdSC5:=SC6->(IndexOrd())

SC6->(dbSetOrder(1))
SC6->(dbSeek(cFilSC6+SC5->C5_NUM))

Do While SC6->(!EOF()).and.SC6->C6_FILIAL==cFilSC6.and. SC6->C6_NUM == SC5->C5_NUM
	                         
    // Salvando informação que será usada caso o usuário desista da alteração
    If Empty(_aABN[2])
	    _aABN[2] := SC6->C6_PEDCLI
    Endif	                        	
    
	If !ALTERA .and. !INCLUI .and. !lPodeExcluir

	 	If SC6->C6_QTDEMP > 0 
	 		lItemLiber := .t.          
	 		Help(" ",1,"A410LIBER")
	 		Return(.f.)
	 	Endif			 
	 		
	 	If !Empty(SC6->C6_NOTA) 
	 		lItemFaturado := .t.
       		Help(" ",1,"A410REGFAT")
	 		Return(.f.)	
	 	Endif
	Else     
		If Empty(SC6->C6_NOTA)
			SC6->(RecLock('SC6',.f.))
			SC6->C6_PEDCLI := ''
			SC6->(MsUnlock())
			SC6->(DbCommit())  // MCVN 25/04/07
		Endif
	Endif
	SC6->(DbSkip())
EndDo

SC6->(dbSetOrder(nOrdSC5))
SC6->(dbGoto(nRecSC6))

Return(lRetorno)

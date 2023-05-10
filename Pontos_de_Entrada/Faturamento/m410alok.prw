#include "rwmake.ch"
/*
PONTO.......: M410ALOK          PROGRAMA....: MATA410
DESCRI��O...: EXECUTA ANTES DE ALTERAR PEDIDO VENDA
UTILIZA��O..: Executado antes de iniciar a alteracao do pedido de venda
PARAMETROS..: Nenhum
RETORNO.....: Variavel logica, sendo: .T. Prossegue alteracao do Pedido de Venda E .F. Impede alteracao no pedido de venda
OBSERVA��ES.: <NENHUM>
*/
/*
�����������������������������������������������������������������������������
���Programa  � M410ALOK � Autor �   Alexandro Dias   � Data �  10/01/02   ���
�������������������������������������������������������������������������͹��
���Desc.     � Nao permite alterar o pedido se a Pre-Nota ja foi Emitida. ���
���          � Avisa para o usuario dar enter nas quantidades de todos os ���
���          � itens do pedido.                                           ���
�����������������������������������������������������������������������������
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
	Aviso("Aten��o","O Pedido de venda: " + SC5->C5_NUM + " est� em uso por outra esta��o!",{"Ok"},1)
	Conout("M410ALOK-LockByName Falhou: Pedido-"+SC5->C5_NUM+" Data-"+DtoC(ddatabase)+" Hora-"+Time()+" User-"+U_DipUsr())
	Return	
EndIf

//---------------------------------------------------------------------------------------
U_DIPPROC(ProcName(0),U_DipUsr()) // JBS 05/10/2005 - Gravando o nome do Programa no SZU  
//---------------------------------------------------------------------------------------
If ( Type("l410Auto") == "U" .OR. !l410Auto )
	If ALTERA .and. !Empty(SC5->C5_EMPENHO)
		MsgInfo("Pedido de Licita��o, s� pode ser alterado pelo sistema de licita��o!"+;
		        " Para altera-lo, exclua o pedido, volte em licita��es, e altere e "+;
		        " gere o pedido novamente","Aten��o")
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
	_cMsg += "N�o � permitido ALTERA��O!!!" + Chr(13) + Chr(10)
	_cMsg += "Para alterar solicite o estorno." + Chr(13) + Chr(10) + Chr(13) + Chr(10)
	_cMsg += "Deseja solicitar o estorno?"
	lVHOEstorno := MsgYesNo(_cMsg,"Aten��o")
ElseIF SC5->C5_PRENOTA == "F"
	_lRet := .F.
	_cMsg := "O pedido "+SC5->C5_NUM+" est� parado no financeiro. "
	_cMsg += "N�o � permitido ALTERA��O!!!" + Chr(13) + Chr(10)
	_cMsg += "Para alterar solicite a rejei��o." + Chr(13) + Chr(10) + Chr(13) + Chr(10)
	_cMsg += "Deseja solicitar a rejei��o?"
	lVHORejeita := MsgYesNo(_cMsg,"Aten��o")   
ElseIF SC5->C5_PRENOTA == "P"    //MCVN 06/07/2007
	_lRet := .F.
	_cMsg := "O pedido "+SC5->C5_NUM+" est� sendo separado neste momento. "
	_cMsg += "N�o � permitido ALTERA��O!!!" + Chr(13) + Chr(10)
	_cMsg += "Para alterar solicite a rejei��o." + Chr(13) + Chr(10) + Chr(13) + Chr(10)
	_cMsg += "Deseja solicitar a rejei��o?"
	lVHOEstorno := MsgYesNo(_cMsg,"Aten��o")
     
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
	
		// Salvando campos que vamos ALTERAR, para ser usado caso o usu�rio desista da altera��o
		_aABN[1] := SC5->C5_PARCIAL
	
		// Limpa as senhas Gravadas no SC5
		RecLock("SC5",.F.)   
		SC5->C5_PARCIAL := "N" // Bloqueia pedido no in�cio da altera��o  -  MCVN  10/04/2007
		SC5->(MsUnLock())
		SC5->(DbCommit())  // MCVN 25/04/07
		
 	Endif	
 	
EndIF

If lVHOEstorno                                                            
    //Alterado para o operador informar o motivo da solicita��o do estorno  MCVN - 24/09/08
    nMot:=Aviso("Aten��o","Qual o motivo da solicita��o estorno. CANCELAR OU CORRIGIR O PEDIDO ?" ,{"Cancelar","Corrigir"})
    If nMot == 1
		U_VHOCIC(SC5->C5_NUM, "ESTORNO", "ESTORNO PARA CANCELAMENTO DO PEDIDO !")
    Else                                                                       
	    U_VHOCIC(SC5->C5_NUM, "ESTORNO", "ESTORNO PARA CORRE��O DO PEDIDO !")
    Endif         
    SC5->(RecLock("SC5",.F.))
    	SC5->C5_XBLQNF := "S"
    SC5->(MsUnLock())
    nMot := 0
EndIf

If lVHORejeita
    //Alterado para o operador informar o motivo da solicita��o da rejei��o  MCVN - 24/09/08
    nMot:=Aviso("Aten��o","Qual o motivo da solicita��o estorno. CANCELAR OU CORRIGIR O PEDIDO ?" ,{"Cancelar","Corrigir"})
    If nMot == 1
    	U_VHOCIC(SC5->C5_NUM, "REJEITA", "REJEI��O PARA CANCELAMENTO DO PEDIDO !")
    Else
		U_VHOCIC(SC5->C5_NUM, "REJEITA", "REJEI��O PARA CORRE��O DO PEDIDO !")
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
	                         
    // Salvando informa��o que ser� usada caso o usu�rio desista da altera��o
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

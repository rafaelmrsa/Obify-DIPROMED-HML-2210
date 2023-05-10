/*
PONTO.......: M460DEL           PROGRAMA....: FATXFUN
DESCRIÇÄO...: APOS O ESTORNO DA LIBERACAO DO PV.
UTILIZAÇÄO..: Este P.E. e' executado apos o Estorno da Liberacao do Pedido de Vendas.
PARAMETROS..: Nenhum.
RETORNO.....: Nenhum.
OBSERVAÇÖES.: <NENHUM>
*/
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³ M460DEL  º Autor ³ Eriberto Elias     º Data ³  25/11/2003 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Exclui itens no SC9 que foi gerado para mostrar saldos     º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
#include "rwmake.ch"
User Function M460DEL()

Local _xAlias  := GetArea()
Local _areaSC9 := SC9->(GetArea())
Local _areaSC6 := SC6->(GetArea())

Local _cPedido := SC9->C9_PEDIDO
Local _cItem   := SC9->C9_ITEM

Local cInd := "1"

//-- Não executa quando chamado pela liberação de Crédito
If !("MATA450" $ FunName()) .And. !("MATA310"$Upper(FunName()))

	U_DIPPROC(ProcName(0),U_DipUsr()) // JBS 05/10/2005 - Gravando o nome do Programa no SZU
	
	// Permite alteração somente se o estorno for total - MCVN 21/02/08
	dbSelectArea("SDC")
	dbSetOrder(4)
	If !DbSeek(xFilial("SDC")+SC5->C5_NUM)	
		Reclock("SC5",.F.)
		SC5->C5_PRENOTA := "E"
		SC5->(MsUnLock())
		SC5->(DbCommit())  // Eriberto 24/04/07
	Endif
	
	// Vamos abrir o SC9 com outro alias deletar os registros criados por nos
	DbUseArea(.T.,"TOPCONN",RetSQLName('SC9'),"S9C",.T.,.F.)
	While TcCanOpen(RetSQLName('SC9'),RetSQLName('SC9') + cInd)
	   ORDLISTADD(RetSQLName('SC9') + cInd)
	   cInd:= soma1(cInd)
	End
		
	DbSelectArea("S9C")
	DbSetOrder(1)
	If DbSeek(xFilial("SC9")+_cPedido+_cItem)
		
		While !S9C->(Eof()) ;
			.and. S9C->C9_FILIAL == xFilial("SC9") ;
			.and. S9C->C9_PEDIDO == _cPedido ;
			.and. S9C->C9_ITEM == _cItem
			
			If S9C->C9_QTDORI == 0 .AND. S9C->C9_BLEST <> '10' .AND. S9C->C9_BLCRED <> '10'
				DbSelectArea("SC6")
				DbSetOrder(1)
				If DbSeek(xFilial("SC6")+S9C->C9_PEDIDO+S9C->C9_ITEM)
					RecLock("SC6",.F.)
					SC6->C6_QTDEMP -= S9C->C9_QTDLIB
					SC6->C6_QTDEMP2 -= S9C->C9_QTDLIB2
					SC6->(MsUnLock())
				EndIf
				
				DbSelectArea("S9C")
				RecLock("S9C",.F.)
				S9C->(DbDelete())
				S9C->(MsUnLock())
			EndIf
			DbSelectArea("S9C")
			S9C->(DbSkip())
		End
		
	EndIf
	
	DbSelectArea("S9C")
	S9C->(DbCloseArea())

EndIf
	
RestArea(_areaSC6)
RestArea(_areaSC9)
RestArea(_xAlias)

Return

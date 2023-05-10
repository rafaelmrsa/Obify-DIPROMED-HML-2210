#INCLUDE "Protheus.ch"
#DEFINE EXPIRADO                '0'   // Prazo para particiapr expirado
#DEFINE FINANCEIRO              '1'   // Foi informado dados basicos do Edital e o Cliente ñ é "A" - Aguar Financeiro
#DEFINE DADOS_LICITACAO         '2'   // Cliente "A" ou já aprovado pelo Financeiro, Licitação vai completar as informações
#DEFINE DIRETOR_COMERCIAL       '3'   // O Diretor Comercial está avaliando
#DEFINE GARANTIAS               '4'   // Aguarando ser informadas as garantias solicitadas pelo Dir Comercial
#DEFINE PRECOS_PRA_CONCORRER    '5'   // Aguardando informar preços a serem preticados no processo
#DEFINE RESULTADO               '6'   // Todos os dados foram informado, esta aguardando o resultado da Licitação
#DEFINE EMPENHO                 '7'   // Aguardando empenho para Gerar o Pedido de vendas no SC5 e SC6
#DEFINE CONCLUIDO               '8'   // Todos os empenho foram cumpridos e todos os pedido gerados
#DEFINE NAO_PARTICIPAR          '9'   // A Dipromed não vai participar deste processo

*-----------------------------------------*
User Function MTA410E()
*-----------------------------------------*
Local lRetorno := .t.                              

U_DIPPROC(ProcName(0),U_DipUsr()) //MCVN - 22/01/2009

If !Empty(SC5->C5_EMPENHO)

	UA9->(dbSetOrder(2))
	
	If UA9->(dbSeek(xFilial("UA9")+SC5->C5_EMPENHO + SC5->C5_EDITAL+SC6->C6_PRODUTO))

		Begin Transaction

		Do While UA9->(!EOF()) .And.;
			UA9->UA9_FILIAL == xFilial("UA9").and.;
			UA9->UA9_EDITAL == M->C5_EDITAL .and.;
			UA9->UA9_EMPENH == M->C5_EMPENHO.and.;
			UA9->UA9_PRODUT == SC6->C6_PRODUTO
			
			If UA4->(dbSeek(xFilial("UA4")+M->C5_EDITAL+UA9->UA9_ITEM))
				UA4->(RecLock("UA4",.f.))
				UA4->UA4_QTDENT := UA4->UA4_QTDENT - UA9->UA9_QTDEMP // Estorna quantidade entregue no edital
				UA4->UA4_SALDO  := UA4->UA4_SALDO + UA9->UA9_QTDEMP  // Estorno o saldo a entregar
				UA4->(MsUnlock("UA4"))
			EndIf
			
			UA9->( Reclock("UA9",.f.) )
			UA9->( DbDelete() )
			UA9->( MsUnlock("UA9") )
			
			UA9->( dbSkip() )
			
		EndDo
		
		UA1->(dbSetOrder(1))
		If UA1->(dbSeek(xFilial("UA1") + M->C5_EDITAL))
			UA1->( RecLock("UA1", .F.) )
			UA1->UA1_STATUS := EMPENHO // Aguardando empenho
			UA1->( MsUnLock("UA1") )
		EndIf

		ConfirmSX8()

		End Transaction
	EndIf
EndIf

Return(lRetorno)
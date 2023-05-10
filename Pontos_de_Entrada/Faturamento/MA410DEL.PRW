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

*---------------------------------------*
User Function MA410DEL()
*---------------------------------------*
Local lRetorno                                      

U_DIPPROC(ProcName(0),U_DipUsr()) // MCVN - 22/01/2009

//------------------------------------------
// Registrando a ocorrencia na Ficha Kardex
//------------------------------------------
If SC5->C5_TIPODIP =="2"
	U_DiprKardex(M->C5_NUM,U_DipUsr(),,.T.,"46") 
ElseIf SC5->C5_TIPODIP =="3"
	U_DiprKardex(M->C5_NUM,U_DipUsr(),,.T.,"47") 
Else
	U_DiprKardex(M->C5_NUM,U_DipUsr(),,.T.,"07")           
Endif

If !Empty(SC5->C5_EMPENHO)
	
	UA1->(dbSetOrder(1))
	UA8->(dbSetOrder(1))
	
	If UA8->(dbSeek(xFilial("UA8") + M->C5_EDITAL + M->C5_EMPENHO))
		
		Begin Transaction
		
		UA8->( Reclock("UA8",.f.))
		UA8->( DbDelete() )
		UA8->( MsUnlock("UA8") )

		ConfirmSX8()
		
		End Transaction
		
	EndIf
EndIf           

Return(lRetorno)
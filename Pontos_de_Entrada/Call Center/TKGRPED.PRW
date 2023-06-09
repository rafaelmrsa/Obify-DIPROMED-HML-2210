/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � TKGRPED  � Autor � Eriberto Elias     � Data � 06/06/2003  ���
�������������������������������������������������������������������������͹��
���Descricao � Ponto de entrada para validar margens antes de gravar      ���
���          � pedido de venda.                                            ��
�������������������������������������������������������������������������͹��
���Uso       � AP6                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

/*
�PONTO.......: TKGRPED           PROGRAMA....: 6.09
�DESCRI��O...: TMKA271D.PRW
�UTILIZA��O..: Ponto de entrada executado antes da grava�ao do
�atendimento na rotina de televendas.
�O seu objetivo � fazer valida�oes espec�ficas antes da grava�ao do
�atendimento.
�
�PARAMETROS..: nLiquido do tipo N : Valor l�quido
�aParcelas do tipo A : Array com os dados das parcelas de pagamento
�
�UA_OPER do tipo C : Tipo de opera�ao
�UA_NUM do tipo C : C�digo da liga�ao
�UA_CODLIG do tipo C : C�digo da liga��o
�UA_CodPagto do tipo C : C�digo da condi�ao de pagamento
�
�RETORNO.....: L�gico do tipo L : .T. - Continua a grava�ao
�.F. - Cancela a grava�ao
�
�OBSERVA��ES.: <NENHUM>
�

*/

#include "rwmake.ch"

USER FUNCTION TKGRPED()
Local _aAlias   := getarea()
Local _aAliasSUA:= SUA->(GetArea())
Local _lRet     := .F.
Local cFilialSC9:= xFilial("SC9")

U_DIPPROC(ProcName(0),U_DipUsr()) // JBS 05/10/2005 - Gravando o nome do Programa no SZU

//conout(" Entrou no TKGRPED - TIME: "+time())
_lRet := U_MTA410()
//conout(" Saiu do TKGRPED - TIME: "+time())

If _lRet .AND. VAL(M->UA_OPER) == 1 .AND. !INCLUI          // Eriberto 16/02/2007  VERIFICAR CONDI��O
	dbSelectArea("SUA")
	dbSetOrder(1)
	If dbSeek(xFilial("SUA")+M->UA_NUM)
		dbSelectArea("SC9")
		SC9->(DbSetOrder(1))
		SC9->(dbSeek(cFilialSC9+SUA->UA_NUMSC5,.T.))
		While SC9->(!Eof()) .And. cFilialSC9+SUA->UA_NUMSC5 == SC9->(C9_FILIAL+C9_PEDIDO)
			If Empty(SC9->C9_NFISCAL)
				ConOut("TKGRPED - CHAMANDO U_DIPXRESE(EXC...) -> PEDIDO(SC9) "+SC9->C9_PEDIDO+" - "+Alltrim(SC9->C9_PRODUTO)+" - "+SC9->C9_ITEM+;
				"  - Data/Hora: "+ Dtoc(dDatabase)+" - "+time()+"  -  Usuario: "+ U_DipUsr())
			U_DIPXRESE("EXC",SC9->C9_PEDIDO,SC9->C9_ITEM,SC9->C9_PRODUTO,SC9->C9_LOCAL,SC9->C9_SEQUEN,SC9->C9_QTDLIB-SC9->C9_SALDO,SC9->C9_LOTECTL,SC9->C9_NUMLOTE,SC9->C9_NUMSERI,"","","","","")	
			EndIf	
			SC9->(dbSkip())
		End
	EndIf	
EndIf

RestArea(_aAliasSUA)
RestArea(_aAlias)
RETURN(_lRet)

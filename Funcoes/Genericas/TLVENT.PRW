/*                                                    São Paulo, 30 Mai 2006
----------------------------------------------------------------------------
Empresa....: Dipromed Comercio e Importação Ltda

Execução...: Apos carregar um atendimento para alteração na rotina
             de televendas

Objetivo...: Possibilitar a execução de algum procedimento
             apos carregar um atendimento

             "Ponto de Entrada executado após consultar / carregar um
             atendimento do historico. Serve para atribuir conteudo
             ao campo UA_TMK já que o mesmo passou a ser obrigatorio
             evitando a mensagem de erro "Campo Obrigatorio" apos
             carregar os dados do pedido /atendimento que esteja com
             este campo vazio e o mesmo para o campo UA_MIDIA. Solução
             paliativa para os registros anteriores a versao que nao
             possuem conteudo neste campo. Este ponto também é usado
             para    tratar  e   habilitar  a alteração  do  pedido
             liberado."...    ( Natalia da Microsiga)

Retorno....: Nenhum retorno é esperado

Autor......: Natalia (Microsiga)
Data.......: 03 Nov 2005

Alterado em: 30 Mai 2006
Por........: Jailton B Santos (JBS)

----------------------------------------------------------------------------
*/
#INCLUDE "RWMAKE.CH"

#DEFINE FATURAMENTO	1
#DEFINE ORCAMENTO	2
#DEFINE ATENDIMENTO	3

*-------------------------------------------------------*
User Function TlvEnt(UA_NUM,lHabilita,oGetTlv,oEnchTlv)
*-------------------------------------------------------*
Local _lRetorno := .t.     
Local _OperLicita := GetMV("MV_OPERLIC") // Operadores de licitação
Private _cCliEspecial := GetMV("MV_CLIESPE") // Cliente especial

U_DIPPROC(ProcName(0),U_DipUsr()) //MCVN - 22/01/2009

U_Dipg007("TLVENT")

// Eriberto 11/04/2007 
// Limpa as senhas, se pedir senha grava de novo.
M->UA_SENHMAR := ""
M->UA_SENHPAG := ""
M->UA_SENHCID := ""
///////////////////


/*/ verificar isto, compare com M410GET, acho que isto aqui está errado.
If M->UA_CONDPG == "167" .AND. M->UA_OPERADO $ '000013/000056/000106/000109/000130' // JBS 25/10/2006 000130
	_lRetorno := .t.
	
ElseIf SUA->UA_VLRLIQ >= SE4->E4_INFER .AND. SUA->UA_VLRLIQ <= SE4->E4_SUPER .and.;
	(Empty(SE4->E4_SEGMENT) .OR.;
	(!Empty(SE4->E4_SEGMENT).AND. AllTrim(SA1->A1_SATIV1) $ SE4->E4_SEGMENT))  // verifica se condição está atrelada a segmento
	
ElseIf !(SUA->UA_VLRLIQ >= SE4->E4_INFER .AND. SUA->UA_VLRLIQ <= SE4->E4_SUPER)

	If VAL(M->UA_OPER)=FATURAMENTO .and. !M->UA_CLIENTE $ _cCliEspecial
		U_DipSenha("PAG", M->UA_CONDPG, SUA->UA_VLRLIQ, 0,.t.)
	EndIf
	
ElseIf !Empty(SE4->E4_SEGMENT) .and. !AllTrim(SA1->A1_SATIV1) $ SE4->E4_SEGMENT

	If !M->UA_CLIENTE $ _cCliEspecial.AND.VAL(M->UA_OPER)=FATURAMENTO
		U_DipSenha("PAG", M->UA_CONDPG, SUA->UA_VLRLIQ, 0,.t.)
	EndIf

EndIf                                                 
*/
// Eriberto 11/04/2007

If M->UA_CONDPG <> SA1->A1_COND // Caso a condição de pagamento do pedido seja a mesma do cadastro do cliente não pede senha  -  MCVN 09/10/2007
	If (SUA->UA_VLRLIQ <= SE4->E4_INFER .or. SUA->UA_VLRLIQ >= SE4->E4_SUPER) .and.;
   		(Empty(SE4->E4_SEGMENT) .or. !AllTrim(SA1->A1_SATIV1) $ SE4->E4_SEGMENT) .and.;
	    (M->UA_CONDPG <> "167" .or. !M->UA_OPERADO $  _OperLicita /*'000013/000056/000106/000109/000130'*/) .and.;// JBS 25/10/2006 000130
	    !M->UA_CLIENTE $ _cCliEspecial .and. VAL(M->UA_OPER)=FATURAMENTO
 
		U_DipSenha("PAG", M->UA_CONDPG, SUA->UA_VLRLIQ, 0,.t.)
	
	ElseIf !Empty(SE4->E4_SEGMENT) .and. !AllTrim(SA1->A1_SATIV1) $ SE4->E4_SEGMENT .and.;
		!M->UA_CLIENTE $ _cCliEspecial .AND. VAL(M->UA_OPER)=FATURAMENTO
	   
		U_DipSenha("PAG", M->UA_CONDPG, SUA->UA_VLRLIQ, 0,.t.)

	EndIf 
Endif

//////////////////////

If Empty(SUA->UA_TMK)
	M->UA_TMK := "1"
EndIf

If Empty(SUA->UA_MIDIA)
	M->UA_MIDIA := "999999"
EndIf

If Empty(SUA->UA_STATUS) .Or. SUA->UA_STATUS == "LIB"
	SUA->(RecLock("SUA",.F.))
	SUA->UA_STATUS:="SUP"
	SUA->(MsUnLock("SUA"))
EndIf

Return(.t.)

#include "PROTHEUS.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ A020DELE  º Autor ³ Maximo Canuto      º Data ³ 14/11/2008 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Faz chamada para função de gravacao do kardex na exclusão  º±±
±±º          ³ de fornecedores                                            º±±
±±º          ³ 															  º±±
±±º          ³ A rotina mata120 está com problema                         º±±
±±º          ³ FNC Gerada: 000000071292008	 - 18/11/2008						      º±±
±±º          ³ Plano Gerado: 000000069762008                              º±±
±±º          ³ Tarefa Gerada: ANÁLISE DA SOLICITACAO 					  º±±
±±º          ³ Analista Alocado: PATRICIA ANTAR SALOMAO                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ ESPECIFICO DIPROMED                                        º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function A020EOK()
Local _areaSA2    := SA2->(getarea())  

U_DIPPROC(ProcName(0),U_DipUsr()) // MCVN - 22/01/2009

If !Altera .And. !Inclui  .And. XFilial("SF1") = '04'
	U_GravaZG("SA2") // Gravando exclusão de fornecedores
Endif

	
RestArea(_areaSA2)
Return(.T.)

#Include "Protheus.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MAAVSC5   ºAutor  ³D'Leme              º Data ³  10/21/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Ponto de entrada chamado em vários momentos de atualização º±±
±±º          ³ da tabele SC5                                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Dipromed                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function MAAVSC5()
	Local _nEventoSC5 := PARAMIXB[1]
	
	If ISINCALLSTACK("LOJA901A") .Or. ISINCALLSTACK("LOJA901")
		Return.T.
	EndIf
	
	If "MATA310"$Upper(FunName())
		Return .T.
	EndIf

	/*
	±±³          ³PARAMIXB[1]: Codigo do Evento                               ³±±
	±±³          ³       [1] Implantacao do Pedido de Venda                   ³±±
	±±³          ³       [2] Estorno do Pedido de Venda                       ³±±
	±±³          ³       [3] Liberacao do Pedido de Venda                     ³±±
	±±³          ³       [4] Estorno da Liberacao do Pedido de Venda          ³±±
	±±³          ³       [5] Preparacao da Nota Fiscal de Saida               ³±±
	±±³          ³       [6] Exclusao da Nota Fiscal de Saida                 ³±±
	±±³          ³       [7] Reavaliacao de Credito (Por Pedido)              ³±±
	±±³          ³       [8] Estorno da Reavalizacao de Credito ( Por Pedido )³±±
	±±³          ³       [9] Liberação de regras ou verbas                    ³±±
	*/

	If U_HasNwExc(SC5->C5_NUM)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Confirma estorno das reservas anteriores³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		U_DIPXRESE("EXC_NEW",SC5->C5_NUM)
	EndIf

Return Nil
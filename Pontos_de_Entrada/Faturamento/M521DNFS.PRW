/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³M521DNFS()³ Autor ³Jailton B Santos-JBS   ³ Data ³26/05/2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Apos excluir a nota fiscal avali os pedidos e os exclui    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Especifico Faturamento Dipromed - DIPA046                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³  Motivo da Alteracao                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³        ³                                                 ³±±
±±³            ³        ³                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

User Function M521DNFS(aPedidos)

Local lRet   := .T. 
//Local aCabec := {}
//Local aItens := {} 
//Local aLinha := {}

Private lMsErroAuto:= .F.
// JBS 21/08/101 - Nao mostrar tela de log ... Private lMsHelpAuto:= .F.
//----------------------------------------------------------------------------------------------------
// Registra o status do recno: .True. foi excluida com suecesso, .False. Ocorreu alguma critica e 
// ão foi cancelada. 
//----------------------------------------------------------------------------------------------------

If !("TMSA200" $ FUNNAME()) .And. !("TMSA500" $ FUNNAME()) .And. !("MATA521A" $ FUNNAME())// Não entra se a rotina for chamada pelo TMS  - MCVN 31/08/10

	lDelSF2 := SF2->(Deleted()) 
	//----------------------------------------------------------------------------------------------------
	// JBS 18/08/2010 - Tratamento para gerar a requisicao de movimentacao interna de mercadoria (SD3).     
	//----------------------------------------------------------------------------------------------------
	If lDelSF2 .and. len(aCabSD3) > 0

    	lMsErroAuto := .F.
	    //MSExecAuto({|x,y,z| MATA240(x,y,z)},aReg,,3)   
    	MSExecAuto({|x,y,z| MATA241(x,y,z)},aCabSD3,aRegSD3,3) 

		If lMsErroAuto // .or.	lMsHelpAuto
    		MostraErro()
	    EndIf    

    	aCabSD3 := {} // JBS 21/08/2010 - Limpa para nao gerar mais 
	    aRegSD3 := {} // JBS 21/08/2010 - Limpa para nao gerar mais 

	EndIf
	//----------------------------------------------------------------------------------------------------
	// Tratamento para Estornar Pedido de Venda.
	//----------------------------------------------------------------------------------------------------
	If lDelSF2 .and. SZL->ZL_MATAPED == '2' // Mata Pedido de Venda = Sim  
	    Estorna_PV(SZL->ZL_PEDIDO,{{"C5_NUM",SZL->ZL_PEDIDO,NIL}},{})
	Endif

	If lMsErroAuto
		mostraerro()
	EndIf  
	
Endif
Return(lRet)

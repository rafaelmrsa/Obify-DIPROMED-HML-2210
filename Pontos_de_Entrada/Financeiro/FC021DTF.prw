/*
+=====================================================================+
|Funcao: FC021DTF()   |   Autor: Reginaldo Borges   |   Data: 19/05/17|
+---------------------------------------------------------------------+ 
|Descricao: Ponto de entrada que possibilita a escolha de qual data   |
|           será considerada nos pedidos de compra e venda no módulo  |
|           Financeiro, quando  executar a rotina Fluxo de Caixa -    |
|           FINC021.                                                  |
+---------------------------------------------------------------------+
|
+=====================================================================+
*/
#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"

User Function FC021DTF()        
Local aAreaSE4 := SE4->(GetArea())
Local dData     
Local dC7Entreg:=StoD('')
Local QRYSC7   := ""
Local cOpc     := PARAMIXB[1]
Local cAlias   := PARAMIXB[2] 

If cOpc == 'SC7'

	//************** QUERY PARA BUSCAR PEDIDOS DE COMPRA(QUANTIDADE E PRAZO DE ENTREGA) - MCVN - 23/11/
	QRYSC7 :=        "SELECT C7_DENTREG"
	QRYSC7 := QRYSC7 + " FROM " + RetSQLName("SC7")
	QRYSC7 := QRYSC7 + " WHERE "
	QRYSC7 := QRYSC7 + RetSQLName('SC7')+".C7_FILIAL = '"+SC7->C7_FILIAL+"' and "
	QRYSC7 := QRYSC7 + RetSQLName('SC7')+".C7_NUM    = '"+SC7->C7_NUM+"' and "
	QRYSC7 := QRYSC7 + RetSQLName('SC7')+".C7_PRODUTO= '"+SC7->C7_PRODUTO+"' and "
	QRYSC7 := QRYSC7 + RetSQLName('SC7')+".C7_ITEM   = '"+SC7->C7_ITEM+"' and "
	QRYSC7 := QRYSC7 + RetSQLName('SC7')+".C7_FORNECE= '"+SC7->C7_FORNECE+"' and "
	QRYSC7 := QRYSC7 + RetSQLName('SC7')+".C7_LOJA   = '"+SC7->C7_LOJA+"' and "
	QRYSC7 := QRYSC7 + RetSQLName('SC7')+".C7_EMISSAO= '"+Dtos(SC7->C7_EMISSAO)+"' and "
	QRYSC7 := QRYSC7 + RetSQLName('SC7')+".D_E_L_E_T_ = '' " 
	QRYSC7 := QRYSC7 + "ORDER BY C7_DENTREG"

	#xcommand TCQUERY <sql_expr>                          ;
	[ALIAS <a>]                                           ;
	[<new: NEW>]                                          ;
	[SERVER <(server)>]                                   ;
	[ENVIRONMENT <(environment)>]                         ;
	=> dbUseArea(                                         ;
	<.new.>,                                              ;
	"TOPCONN",                                            ;
	TCGENQRY(<(server)>,<(environment)>,<sql_expr>),      ;
	<(a)>, .F., .T.)

	// Processa Query SQL
	TcQuery QRYSC7 NEW ALIAS "QRYSC7"         // Abre uma workarea com o resultado da query
	
	If QRYSC7->(!Eof())	
		dC7Entreg := StoD(QRYSC7->C7_DENTREG)
	Endif	
	QRYSC7->(dbCloseArea())
	
	SE4->(dbSetOrder(1))
	If SE4->(dbSeek(xFilial("SE4")+SC7->C7_COND))
		If "VISTA"$SE4->E4_DESCRI .Or. "APRESENTACAO"$SE4->E4_DESCRI
			dData := dC7Entreg
		Else
			dData := (dC7Entreg-GetNewPar("ES_A2PRAZO",5))
		EndIf
	EndIf
Endif	

RestArea(aAreaSE4)

Return dData
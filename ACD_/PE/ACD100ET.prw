#include 'protheus.ch'
#include 'parmtype.ch'
#include 'topconn.ch'

/*/{Protheus.doc} ACD100ET
//Ponto de entrada para exclusao do empenho no estorno da ordem de separação
@author dfern
@since 01/07/2020
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
user function ACD100ET()

Local cQuery := ""

cQuery := " SELECT R_E_C_N_O_ AS RECSC2 FROM "+RetSqlName("SC2")+" " 
cQuery += " WHERE C2_NUM+C2_ORDSEP = '"+CB7->CB7_OP+"' "
cQuery += " AND C2_FILIAL = '"+xFilial("SC2")+"' " 
cQuery += " AND D_E_L_E_T_ = '' "

If ( Select("TSQL") > 0 )
	TSQL->(DbCloseArea())
Endif

TcQuery cQuery New Alias "TSQL"

dbSelectArea("TSQL")
TSQL->(dbGotop())

While TSQL->(!Eof())

	dbSelectArea("SC2")
	dbGoto( TSQL->RECSC2 ) 
	
	SC2->(RecLock("SC2",.F.))
	SC2->C2_ORDSEP := ""
	SC2->(MsUnLock())
	
	
		
	TSQL->(dbSkip())
EndDo

//Exclusao dos empenhos gerados pela rotina da ordem de separação
cQuery := " SELECT R_E_C_N_O_ AS RECSD4 FROM "+RetSqlName("SD4")+" " 
cQuery += " WHERE D4_XORDSEP = '"+CB7->CB7_ORDSEP+"' "
cQuery += " AND D4_XEMPMAN = 'S' "
cQuery += " AND D4_FILIAL = '"+xFilial("SD4")+"' "
cQuery += " AND D_E_L_E_T_ = '' "

If ( Select("TSQL") > 0 )
	TSQL->(DbCloseArea())
Endif

TcQuery cQuery New Alias "TSQL"

dbSelectArea("TSQL")
TSQL->(dbGotop())

While TSQL->(!Eof())

	dbSelectArea("SD4")
	dbGoto( TSQL->RECSD4 )
	
	aVetor:={{"D4_COD"	,SD4->D4_COD,NIL},;
		{"D4_OP"	,SD4->D4_OP,NIL},;
		{"D4_TRT"	,SD4->D4_TRT,NIL},;
		{"D4_LOCAL"	,SD4->D4_LOCAL,NIL},;
		{"D4_QTDEORI",SD4->D4_QTDEORI,NIL},;
		{"D4_QUANT"	,SD4->D4_QUANT,NIL},;
		{"D4_LOTECTL"	,SD4->D4_LOTECTL,NIL},;
		{"D4_NUMLOTE"	,SD4->D4_NUMLOTE,NIL},;
		{"D4_POTENCI"	,SD4->D4_POTENCI,NIL},;
		{"ZERAEMP"	,"S",NIL}} 
		
		lMSHelpAuto := .T.
		lMSErroAuto := .F.
		MSExecAuto({|x,y| MATA380(x,y)},aVetor,4)
		                	
		If lMSErroAuto  
			lRet := .F.
			MostraErro()
		Else
			SD4->(RecLock("SD4",.F.))
				SD4->(dbDelete())
			SD4->(MsUnLock())
		EndIf	
				 			 			
	TSQL->(dbSkip())
EndDo
	
return

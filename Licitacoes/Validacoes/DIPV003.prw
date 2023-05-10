/*====================================================================================\
|Programa  | DIPV003       | Autor | GIOVANI.ZAGO               | Data | 02/06/2011   |
|=====================================================================================|
|Descrição | Validação de produto - INCUBADORA CLEAN TRACE                              |
|          |                                                                          |
|          |                                                                          |
|=====================================================================================|
|Sintaxe   | DIPV003                                                                 |
|=====================================================================================|
|Uso       | Especifico DIPROMED                                                      |
|=====================================================================================|
|........................................Histórico....................................|
\====================================================================================*/

User Function DIPV003 (cCodPar,cCodCli,cLojaCli)

Local _aArea   	    := GetArea()
Local cCodPro       := GetMv("es_dipv3_1")  //011904 cod do produto
Local cCodInc       := GetMv("es_dipv3_2")  //011329 cod da incubadora 
Local cDatCort      := GetMv("es_dipv3_3")  //20110501 data de corte
Local nConta003     := 0
Local nConta004     := 0
Private _Retorno    := .T. 
Private _cQry0      := ""


//verifica se contem incubadora


_cQry0 :=" SELECT * "
_cQry0 +=" FROM "+RETSQLNAME ("SD2") + " SD2 "
_cQry0 +=" WHERE D2_COD     =  '"+cCodInc+"' "   //produto
_cQry0 +=" AND D2_FILIAL    =  '"+cFilant+"'   " //filial
_cQry0 +=" AND D2_CLIENTE   =  '"+cCodCli+"'  "  //cliente
_cQry0 +=" AND D2_LOJA      =  '"+cLojaCli+"' "  //loja
_cQry0 +=" AND D_E_L_E_T_   <> '*' "  
_cQry0 +=" AND D2_EMISSAO >=  '"+cDatCort+"' "
_cQry0 +=" AND NOT EXISTS ( SELECT * FROM SD1010
_cQry0 +=" WHERE D2_COD     =  D1_COD
_cQry0 +=" AND D2_FILIAL    =  D1_FILIAL
_cQry0 +=" AND D2_CLIENTE   =  D1_FORNECE
_cQry0 +=" AND D2_LOJA      =  D1_LOJA
_cQry0 +=" AND D1_EMISSAO >=  '"+cDatCort+"' "
_cQry0 +=" AND D_E_L_E_T_   <> '*'  )

dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQry0),'TMP1',.T.,.F.)

TMP1->(dbgotop())
If cCodPar = "003"
	If !EMPTY ("TMP1")
		DbSelectArea("TMP1")
		DbGoTop()
		While TMP1->(!EOF())
			
			nConta003 := (nConta003+1)
			
			TMP1->(DbSkip())
			
		End
		If nConta003 > 0
			MsgInfo("ATENCAO CLIENTE JA POSSUI A INCUBADORA CLEAN-TRACE (011329)")  // mensagem caso o cliente ja possua o produto incubadora
		ElseIf  nConta003 = 0
			MsgInfo("ATENCAO CLIENTE NAO POSSUI A INCUBADORA CLEAN-TRACE (011329), FAVOR ENVIÁ-LA.") // mensagem caso o cliente nao possua o produto incubadora
		EndIf
		
	EndIf
	
ElseIf cCodPar = "004"
	
	If !EMPTY ("TMP1")
		DbSelectArea("TMP1")
		DbGoTop()
		While TMP1->(!EOF())
			
			nConta004 := (nConta004+1)
			
			TMP1->(DbSkip())
			End 
			
		If nConta004 > 0
			MsgInfo("ATENCAO CLIENTE JA POSSUI A INCUBADORA CLEAN-TRACE (011329)")   // mensagem caso o cliente ja possua o produto incubadora
			_Retorno := .F.
		ElseIf  nConta003 = 0
		   //	MsgInfo("ATENCAO CLIENTE NAO POSSUI O PRODUTO INCUBADORA CLEAN-TRACE, ENVIÁ-LA AO CLIENTE") // verificar a necessidade de msg
		EndIf
		
	EndIf
EndIf
nConta003   := 0
nConta004   := 0
TMP1->(DBCloseArea())
RestArea(_aArea)
Return(_Retorno)


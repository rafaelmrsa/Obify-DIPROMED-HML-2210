#include "PROTHEUS.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณNOVO42    บAutor  ณMicrosiga           บ Data ณ  01/12/17   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function DIPR088()  
Local titulo      := OemTOAnsi("Produtos em saldo para transfer๊ncia",72)
Local cDesc1      := (OemToAnsi("Este programa tem como objetivo emitir um relatขrio",72))
Local cDesc2      := (OemToAnsi("com os produtos em saldo para transfer๊ncia ",72))
Local cDesc3      := (OemToAnsi("entre filiais.",72))
Local nAviso      := 0
Private aReturn   := {"Bco A4", 1,"Administracao", 1, 2, 1,"",1}
Private li        := 67
Private tamanho   := "M"
Private limite    := 130
Private nomeprog  := "DIPR088"
Private nLastKey  := 0
Private lEnd      := .F.
Private wnrel     := "DIPR088"
Private cString   := "SC9"
Private m_pag     := 1
Private cWorkFlow := ""
Private cWCodEmp  := ""  
Private cWCodFil  := "" 
Private _dDatIni  := ""
Private _dDatFim  := "" 
Private PG := 0

If cEmpAnt+cFilAnt<>"0401"
	Aviso("Aten็ใo","Empresa ou filial incorreta. Este relat๓rio foi desenvolvido para HQ-Matriz (01)",{"Ok"},1)
	Return .F.
EndIf                                                                           

wnrel := SetPrint(cString,wnrel,"",Titulo,cDesc1,cDesc2,cDesc3,.f.,,.f.,tamanho,,.f.,,,,,)

If nLastKey == 27
	Return
Endif

SetDefault(aReturn,cString)

nAviso := Aviso("Aten็ใo","Imprime Saldo de Pedidos ou Requisi็ใo?",{"Pedidos","Requisi็ใo"},1)

If nAviso==1
	RptStatus({|lEnd| RodaRel()},Titulo)
ElseIf nAviso==2                                      
	RptStatus({|lEnd| RodaRel2()},Titulo)
Else 
	Aviso("Aten็ใo","Cancelado pelo usuแrio",{"Ok"},1)
EndIf

Set device to Screen

/*==========================================================================\
| Se em disco, desvia para Spool                                            |
\==========================================================================*/
If aReturn[5] == 1    // Se Saida para disco, ativa SPOOL
	Set Printer TO
	Commit
	ourspool(wnrel)
Endif

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณRODAREL() บAutor  ณMicrosiga           บ Data ณ  01/20/15   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function RodaRel()
Local cSQL 	    := "" 
Local nEst      := 0
Private _cTitulo:= "PRODUTOS EM SALDO - ### PEDIDO ###"                                                 
Private _cDesc1 := " Local Produto   Descri็ใo                                                                Saldo        Estoque (Mtz)    Transferir "
Private _cDesc2 := ""

cSQL := " SELECT "
cSQL += " 	C9_PRODUTO, C9_LOCAL, B1_DESC, SUM(C9_SALDO) SALDO "
cSQL += " 	FROM  "
cSQL +=  		RetSQLName("SC5")
cSQL += " 		INNER JOIN "
cSQL +=  			RetSQLName("SC9")
cSQL += " 			ON "
cSQL += " 				C5_FILIAL = C9_FILIAL AND "
cSQL += " 				C5_NUM = C9_PEDIDO AND "
cSQL += " 				C5_CLIENTE = C9_CLIENTE AND "
cSQL += " 				C9_NFISCAL = ' ' AND "
cSQL += " 				C9_SALDO > 0 AND  "
cSQL += 				RetSQLName("SC9")+".D_E_L_E_T_ = ' ' "
cSQL += " 		INNER JOIN "
cSQL +=  			RetSQLName("SB1") "
cSQL += "			ON "
cSQL += "				B1_FILIAL = C9_FILIAL AND "
cSQL += "				B1_COD = C9_PRODUTO AND "
cSQL += 				RetSQLName("SB1")+".D_E_L_E_T_ = ' ' "
cSQL += " 		WHERE "
cSQL += " 			C5_TIPO = 'N' AND "
cSQL += " 			C5_FILIAL = '"+xFilial("SC5")+"' AND  "
cSQL +=  			RetSQLName("SC5")+".D_E_L_E_T_ = ' ' "
cSQL += " GROUP BY C9_FILIAL, C9_PRODUTO, B1_DESC, C9_LOCAL "
cSQL += " ORDER BY C9_PRODUTO "

cSQL := ChangeQuery(cSQL)      
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),"QRYSAL",.T.,.F.)
                  
SB2->(dbSetOrder(1))
While !QRYSAL->(Eof())
	If lAbortPrint
		@ li+1,00 PSAY "*** CANCELADO PELO OPERADOR ***"
		Exit
	Endif
	
	If li > 65		
		li := Cabec(_cTitulo,_cDesc1,_cDesc2,wnrel,Tamanho)		
		li++
	EndIf
	
	If SB2->(dbSeek(xFilial("SB2")+QRYSAL->(C9_PRODUTO+C9_LOCAL)))		
		nEst := SaldoSB2()		
		If QRYSAL->SALDO > nEst
			@ li,001 PSay AllTrim(QRYSAL->C9_LOCAL)
			@ li,007 PSay AllTrim(QRYSAL->C9_PRODUTO)
			@ li,017 PSay AllTrim(QRYSAL->B1_DESC)
			@ li,084 PSay Transform(QRYSAL->SALDO,"@E 9,999,999.99")
			@ li,100 PSay Transform(nEst  , "@E 9,999,999.99")			
			@ li,116 PSay Transform(QRYSAL->SALDO-nEst, "@E 9,999,999.99")
			li++
		EndIf                                                     
	EndIf
	
	QRYSAL->(dbSkip())
EndDo 
QRYSAL->(dbCloseArea())

Return(.T.)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณRODAREL() บAutor  ณMicrosiga           บ Data ณ  01/20/15   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function RodaRel2()
Local cSQL 	    := "" 
Private _cTitulo:= "PRODUTOS EM SALDO - ### REQUISIวรO ###"                                                 
//Private _cDesc1 := " Local Produto   Descri็ใo                                                                             Saldo        Estoque (Mtz)"
Private _cDesc1 := " Local Produto   Descri็ใo                                                                Saldo        Estoque (Mtz)    Transferir "
Private _cDesc2 := ""

cSQL := " SELECT "
cSQL += " 	ZZ9_LOCAL, ZZ9_CODPRO, B1_DESC, SUM(ZZ9_QTDPRO) SALDO, "
cSQL += " 	(SELECT "
cSQL += " 		ISNULL(SUM(B8_SALDO-B8_EMPENHO),0) "
cSQL += " 		FROM "
cSQL +=  			RetSQLName("SB8")
cSQL += " 			WHERE "
cSQL += " 				B8_FILIAL = ZZ9_FILIAL AND "
cSQL += "  				B8_PRODUTO = ZZ9_CODPRO AND "
cSQL += " 				B8_SALDO > 0 AND "
cSQL += "  				B8_LOCAL = ZZ9_LOCAL AND "
cSQL += 				RetSQLName("SB8")+".D_E_L_E_T_ = ' ')  EST "
cSQL += " 	FROM "
cSQL +=  		RetSQLName("ZZ8")
cSQL += " 		INNER JOIN "
cSQL +=  			RetSQLName("ZZ9")
cSQL += " 			ON "
cSQL += " 				ZZ8_FILIAL = ZZ9_FILIAL AND "
cSQL += " 				ZZ8_REQMAT = ZZ9_REQMAT AND "
cSQL += 				RetSQLName("ZZ9")+".D_E_L_E_T_ = ' '  "
cSQL += " 		INNER JOIN "
cSQL +=  			RetSQLName("SB1")
cSQL += " 			ON "
cSQL += " 				B1_FILIAL = ZZ8_FILIAL AND "
cSQL += " 				B1_COD = ZZ9_CODPRO AND "
cSQL += 				RetSQLName("SB1")+".D_E_L_E_T_ = ' ' "
cSQL += " 		LEFT JOIN "
cSQL +=  			RetSQLName("ZZA")
cSQL += " 			ON "
cSQL += " 				ZZA_FILIAL = ZZ8_FILIAL AND "
cSQL += " 				ZZA_REQMAT = ZZ8_REQMAT AND "
cSQL +=  				RetSQLName("ZZA")+".D_E_L_E_T_ = ' ' "
cSQL += " 		WHERE "
cSQL += " 			ZZ8_FILIAL = '"+xFilial("ZZ8")+"' AND "
cSQL += " 			ZZ8_STATUS = '0' AND "
cSQL += " 			ZZA_FILIAL IS NULL AND "
cSQL +=  			RetSQLName("ZZ8")+".D_E_L_E_T_ = ' ' "
cSQL += " GROUP BY ZZ9_FILIAL, ZZ9_LOCAL, ZZ9_CODPRO, B1_DESC "
cSQL += " ORDER BY ZZ9_CODPRO "

cSQL := ChangeQuery(cSQL)      
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),"QRYSAL",.T.,.F.)

While !QRYSAL->(Eof())
	If lAbortPrint
		@ li+1,00 PSAY "*** CANCELADO PELO OPERADOR ***"
		Exit
	Endif
	
	If li > 65		
		li := Cabec(_cTitulo,_cDesc1,_cDesc2,wnrel,Tamanho)		 
		li++
	EndIf

	If QRYSAL->SALDO > QRYSAL->EST
		@ li,001 PSay AllTrim(QRYSAL->ZZ9_LOCAL)                         	
		@ li,007 PSay AllTrim(QRYSAL->ZZ9_CODPRO)
		@ li,017 PSay AllTrim(QRYSAL->B1_DESC)
		@ li,084 PSay Transform(QRYSAL->SALDO,"@E 9,999,999.99")
		@ li,100 PSay Transform(QRYSAL->EST  , "@E 9,999,999.99")			
		@ li,116 PSay Transform(QRYSAL->SALDO-QRYSAL->EST, "@E 9,999,999.99")
		li++
	EndIf
	
	QRYSAL->(dbSkip())
EndDo 
QRYSAL->(dbCloseArea())

Return(.T.)

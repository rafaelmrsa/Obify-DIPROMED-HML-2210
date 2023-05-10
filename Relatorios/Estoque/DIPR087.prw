#include "PROTHEUS.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDIPR087   บAutor  ณMicrosiga           บ Data ณ  01/12/17   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function DIPR087()  
Local titulo      := OemTOAnsi("Produtos a endere็ar",72)
Local cDesc1      := (OemToAnsi("Este programa tem como objetivo emitir um relatขrio",72))
Local cDesc2      := (OemToAnsi("com os produtos a endere็ar ",72))
Local cDesc3      := (OemToAnsi("",72))
Local nAviso      := 0
Local cPerg       := "DIPR87"
Private aReturn   := {"Bco A4", 1,"Administracao", 1, 2, 1,"",1}
Private li        := 67
Private tamanho   := "M"
Private limite    := 130
Private nomeprog  := "DIPR087"
Private nLastKey  := 0
Private lEnd      := .F.
Private wnrel     := "DIPR087"
Private cString   := "SDB"
Private m_pag     := 1
Private cWorkFlow := ""
Private cWCodEmp  := ""  
Private cWCodFil  := "" 
Private _dDatIni  := ""
Private _dDatFim  := "" 
Private PG := 0            

//Aviso("Aten็ใo","Relat๓rio descontinuado",{"Ok"})

//Return 

AjustaSX1(cPerg)   

If !Pergunte(cPerg,.T.)	
	Return
Endif 

wnrel := SetPrint(cString,wnrel,"",Titulo,cDesc1,cDesc2,cDesc3,.f.,,.f.,tamanho,,.f.,,,,,)

If nLastKey == 27
	Return
Endif

SetDefault(aReturn,cString)

RptStatus({|lEnd| RodaRel()},Titulo)

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
Private _cTitulo:= "PRODUTOS x ENDEREวO ORIGINAL"                                                 
Private _cDesc1 := " Data     Doc/Serie     Produto Descri็ใo                                                    UM       Quant.    Localiz.  Lote "
Private _cDesc2 := ""

cSQL := "  SELECT "
cSQL += " 	DB_DATA, DB_DOC+'/'+DB_SERIE DOC, DB_PRODUTO, B1_DESC, B1_UM, DB_QUANT, DB_LOCALIZ, DB_LOTECTL "
cSQL += " 	FROM "
cSQL +=  		RetSQLName("SDB")  
cSQL += " 		INNER JOIN "
cSQL +=  			RetSQLName("SB1")
cSQL += " 			ON "
cSQL += " 				B1_FILIAL = DB_FILIAL AND "
cSQL += " 				B1_COD = DB_PRODUTO AND "
cSQL +=  				RetSQLName("SB1")+".D_E_L_E_T_ = ' ' "
cSQL += " 		WHERE "
cSQL += " 			DB_FILIAL = '"+xFilial("SDB")+"' AND "
cSQL += " 			DB_DOC BETWEEN '"+mv_par05+"' AND '"+mv_par06+"' AND "
cSQL += " 			DB_SERIE BETWEEN '"+mv_par03+"' AND '"+mv_par04+"' AND "
cSQL += " 			DB_DATA BETWEEN '"+DtoS(mv_par01)+"' AND '"+DtoS(mv_par02)+"' AND "
cSQL += " 			DB_TM > '499' AND "
cSQL +=  			RetSQLName("SDB")+".D_E_L_E_T_ = ' ' "     
cSQL += " ORDER BY DB_DOC, DB_SERIE, DB_PRODUTO, DB_LOTECTL, DB_LOCALIZ "

cSQL := ChangeQuery(cSQL)      
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),"QRYSDB",.T.,.F.)
              
TCSETFIELD("QRYSDB","DB_DATA","D",8,0)

While !QRYSDB->(Eof())
	If lAbortPrint
		@ li+1,00 PSAY "*** CANCELADO PELO OPERADOR ***"
		Exit
	Endif
	
	If li > 65		                                        
		li := Cabec(_cTitulo,_cDesc1,_cDesc2,wnrel,Tamanho)		
		li++
	EndIf
	
	@ li,001 PSay DtoC(QRYSDB->DB_DATA)
	@ li,010 PSay AllTrim(QRYSDB->DOC)
	@ li,024 PSay AllTrim(QRYSDB->DB_PRODUTO)+'-'
	@ li,031 PSay AllTrim(QRYSDB->B1_DESC)  
	@ li,093 PSay AllTrim(QRYSDB->B1_UM)
	@ li,098 PSay Transform(QRYSDB->DB_QUANT,"@E 9,999,999.99")
	@ li,112 PSay AllTrim(QRYSDB->DB_LOCALIZ)
	@ li,122 PSay AllTrim(QRYSDB->DB_LOTECTL)
		
	li++
             
	QRYSDB->(dbSkip())
EndDo 
QRYSDB->(dbCloseArea())

Return(.T.)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDIPR099   บAutor  ณMicrosiga           บ Data ณ  10/08/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function AjustaSX1(cPerg)
Local aRegs 	:= {}
DEFAULT cPerg 	:= ""

dbSelectArea("SX1")
dbSetOrder(1)

aAdd(aRegs,{cPerg,"01","Data De     ?","","","mv_ch1","D", 8,0,0,"G","","MV_PAR01","","","","","","","","","","","","","","","","","","","","","","","","",''})
aAdd(aRegs,{cPerg,"02","Data At้    ?","","","mv_ch2","D", 8,0,0,"G","","MV_PAR02","","","","","","","","","","","","","","","","","","","","","","","","",''})
aAdd(aRegs,{cPerg,"03","Serie De    ?","","","mv_ch3","C", 3,0,0,"G","","MV_PAR03","","","","","","","","","","","","","","","","","","","","","","","","",''})
aAdd(aRegs,{cPerg,"04","Serie At้   ?","","","mv_ch4","C", 3,0,0,"G","","MV_PAR04","","","","","","","","","","","","","","","","","","","","","","","","",''})
aAdd(aRegs,{cPerg,"05","Doc De      ?","","","mv_ch5","C", 9,0,0,"G","","MV_PAR05","","","","","","","","","","","","","","","","","","","","","","","","",''})
aAdd(aRegs,{cPerg,"06","Doc At้     ?","","","mv_ch6","C", 9,0,0,"G","","MV_PAR06","","","","","","","","","","","","","","","","","","","","","","","","",''})

PlsVldPerg( aRegs )       

Return

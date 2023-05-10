#INCLUDE "RWMAKE.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "PROTHEUS.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDIPGERZZO บAutor  ณMicrosiga           บ Data ณ  06/10/16   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function DipGerZZO()
Local cSQL    	:= ""
Local cPerg   	:= "DIPZZ0"               
Local aCampos 	:= {}
Local aTamSX3 	:= {}  
Local aTmpDir   := {}
Local cArqTrb 	:= ""
Local cArqExcell:= "\Excell-DBF\"+U_DipUsr()+"-Vendas_Perdidas"
Local cDestino 	:= "C:\EXCELL-DBF\" 
Local lExcel    := .F.
Local lCompleto := Upper(u_DipUsr())$GetNewPar("ES_DIPGERZ","MCANUTO/RLOPES/PMENDONCA/EPONTOLDIO")
AjustaSX1(cPerg)

If !Pergunte(cPerg,.T.)  
	Return
EndIf

aTamSX3 := TamSX3("B1_COD")
AAdd(aCampos ,{"PRODUTO","C",aTamSX3[1],aTamSX3[2]})

aTamSX3 := TamSX3("B1_DESC")
AAdd(aCampos ,{"NOMEPRO","C",aTamSX3[1],aTamSX3[2]})

If lCompleto
	aTamSX3 := TamSX3("A2_NREDUZ")
	AAdd(aCampos ,{"NOMEFOR","C",aTamSX3[1],aTamSX3[2]})
EndIf

aTamSX3 := TamSX3("ZZO_QUANT")
AAdd(aCampos ,{"QUANT","N",aTamSX3[1],aTamSX3[2]})

aTamSX3 := TamSX3("ZZO_VLRUNI")
AAdd(aCampos ,{"VLRUNI","N",aTamSX3[1],aTamSX3[2]})
                      
aTamSX3 := TamSX3("ZZO_VLRTOT")
AAdd(aCampos ,{"VLRTOT","N",aTamSX3[1],aTamSX3[2]})
             
If lCompleto
	aTamSX3 := TamSX3("ZZO_ESTOQU")
	AAdd(aCampos ,{"ESTOQU","N",aTamSX3[1],aTamSX3[2]})
	
	AAdd(aCampos ,{"PREVISAO","D",8,0})
EndIf

aTamSX3 := TamSX3("ZZO_EXPLIC")
AAdd(aCampos ,{"EXPLIC","C",20,aTamSX3[2]})  

aTamSX3 := TamSX3("U7_NOME")
AAdd(aCampos ,{"NOMEOPE","C",aTamSX3[1],aTamSX3[2]})

aTamSX3 := TamSX3("A1_COD")
AAdd(aCampos ,{"CLIENTE","C",aTamSX3[1],aTamSX3[2]})

aTamSX3 := TamSX3("A1_NREDUZ")
AAdd(aCampos ,{"NOMECLI","C",aTamSX3[1],aTamSX3[2]})

aTamSX3 := TamSX3("ZZO_DATA")
AAdd(aCampos ,{"DATAINC","D",aTamSX3[1],aTamSX3[2]})

If lCompleto
	aTamSX3 := TamSX3("A2_COD")
	AAdd(aCampos ,{"FORNECE","C",aTamSX3[1],aTamSX3[2]})
	
	AAdd(aCampos ,{"CONSUMO","N",10,0})
EndIf
If (Select("TRB") <> 0)        
	DbSelectArea("TRB")    
   DbCloseArea("TRB")          
Endif
cArqTrb := CriaTrab(aCampos,.T.)
DbUseArea(.T.,,cArqTrb,"TRB",.F.,.F.)
                           
If lCompleto
	cChave  := 'NOMEFOR + NOMEPRO + NOMEOPE'
Else 
	cChave  := 'CLIENTE + PRODUTO + DTOS(DATAINC)'	
EndIf
IndRegua("TRB",cArqTrb,cChave,,,"Criando Indice...")

cSQL := " SELECT "
cSQL += " 	CASE WHEN ZZO_FILIAL='01' THEN 'MTZ' ELSE 'CD' END FILIAL, "
cSQL += " 	U7_COD, U7_NOME, "
cSQL += "	B1_COD, B1_DESC, "
cSQL += " 	A2_COD, A2_NREDUZ, "
cSQL += "	A1_COD, A1_NREDUZ, "
cSQL += " 	A3_COD, A3_NOME, "
cSQL += " 	ZZO_QUANT, ZZO_VLRUNI, ZZO_VLRTOT, ZZO_ESTOQU, ZZO_EXPLIC, ZZO_DATA "
cSQL += " 	FROM "
cSQL += 		RetSQLName("ZZO")
cSQL += " 		INNER JOIN "
cSQL +=  			RetSQLName("SB1")
cSQL += " 			ON "
cSQL += " 				ZZO_FILIAL = B1_FILIAL AND "
cSQL += " 				ZZO_PRODUT = B1_COD "
cSQL += " 		INNER JOIN "
cSQL +=  			RetSQLName("SU7")
cSQL += " 			ON "
cSQL += " 				U7_FILIAL = '"+xFilial("SU7")+"' AND "
cSQL += " 				U7_COD = ZZO_OPERAD "
If !lCompleto
	cSQL += "			AND U7_CODUSU = '"+RetCodUsr()+"' "
EndIf
cSQL += " 		INNER JOIN "
cSQL +=  			RetSQLName("SA1")
cSQL += " 			ON "
cSQL += " 				A1_FILIAL = '"+xFilial("SA1")+"' AND "
cSQL += " 				A1_COD = ZZO_CLIENT "
cSQL += " 		INNER JOIN "
cSQL +=  			RetSQLName("SA2")
cSQL += " 			ON "
cSQL += " 				A2_FILIAL = '"+xFilial("SA2")+"' AND "
cSQL += " 				A2_COD = B1_PROC "
cSQL += " 		INNER JOIN "
cSQL +=  			RetSQLName("SA3")
cSQL += " 			ON "
cSQL += " 				A3_FILIAL = '"+xFilial("SA3")+"' AND "
cSQL += " 				A3_COD = A1_VEND "
cSQL += " 		WHERE "                            
cSQL += " 			ZZO_FILIAL IN('01','04') AND "
If !Empty(DtoS(MV_PAR01))
	cSQL += " 		ZZO_DATA 	>='"+DtoS(MV_PAR01)+"' AND "
EndIf
If !Empty(DtoS(MV_PAR02))
	cSQL += "		ZZO_DATA 	<='"+DtoS(MV_PAR02)+"' AND "
EndIf             
If !Empty(MV_PAR03)
	cSQL += " 		ZZO_OPERAD 	= '"+MV_PAR03+"' AND "
EndIf             
If !Empty(MV_PAR04)
	cSQL += " 		A3_COD 		= '"+MV_PAR04+"' AND "
EndIf
If !Empty(MV_PAR05)
	cSQL += " 		B1_PROC 	= '"+MV_PAR05+"' AND "
EndIf
If !Empty(MV_PAR06)
	cSQL += " 		A1_COD	 	= '"+MV_PAR06+"' AND "
EndIf
If !Empty(MV_PAR07)
	cSQL += " 		B1_COD 		>= '"+MV_PAR07+"' AND "
EndIf  
If !Empty(MV_PAR08)
	cSQL += " 		B1_COD	 	<= '"+MV_PAR08+"' AND "
EndIf

cSQL += " 			ZZO010.D_E_L_E_T_ = ' ' AND "
cSQL += " 			SB1010.D_E_L_E_T_ = ' ' AND "
cSQL += " 			SA1010.D_E_L_E_T_ = ' ' AND "
cSQL += " 			SU7010.D_E_L_E_T_ = ' ' "

cSQL := ChangeQuery(cSQL)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),"QRYTRB",.F.,.T.)

TCSETFIELD("QRYTRB","ZZO_DATA","D",8,0)

While QRYTRB->(!Eof())
     TRB->(RecLock("TRB",.T.))
     	TRB->NOMEOPE 	:= QRYTRB->U7_NOME
     	TRB->PRODUTO	:= QRYTRB->B1_COD
     	TRB->NOMEPRO	:= QRYTRB->B1_DESC
     	If lCompleto
	     	TRB->FORNECE	:= QRYTRB->A2_COD
    	 	TRB->NOMEFOR	:= QRYTRB->A2_NREDUZ
    	EndIf
     	TRB->CLIENTE	:= QRYTRB->A1_COD
     	TRB->NOMECLI	:= QRYTRB->A1_NREDUZ
		TRB->QUANT		:= QRYTRB->ZZO_QUANT
		TRB->VLRUNI		:= QRYTRB->ZZO_VLRUNI
		TRB->VLRTOT		:= QRYTRB->ZZO_VLRTOT
		If lCompleto
			TRB->ESTOQU		:= QRYTRB->ZZO_ESTOQU
		EndIf
		TRB->EXPLIC		:= IIf(QRYTRB->ZZO_EXPLIC=="P","PERDA PARCIAL",IIf(QRYTRB->ZZO_EXPLIC=="T","PERDA TOTAL",IIf(QRYTRB->ZZO_EXPLIC=="F","CAIXA FECHADA","COTACAO")))
		TRB->DATAINC	:= QRYTRB->ZZO_DATA	 
		If lCompleto
			TRB->CONSUMO	:= u_DipCalCons(QRYTRB->B1_COD)
			TRB->PREVISAO   := DipRetPrv(QRYTRB->B1_COD)
		EndIf
	TRB->(MsUnLock())                           
	lExcel := .T.
	QRYTRB->(dbSkip())
EndDo
QRYTRB->(dbCloseArea())

DbSelectArea("TRB")
TRB->(dbGotop())
ProcRegua(TRB->(RECCOUNT()))	
aCols := Array(TRB->(RECCOUNT()),Len(aCampos))
nColuna := 0
nLinha := 0
While TRB->(!Eof())
	nLinha++
	IncProc(OemToAnsi("Gerando planilha excel..."))
	For nColuna := 1 to Len(aCampos)
		aCols[nLinha][nColuna] := &("TRB->("+aCampos[nColuna][1]+")")			
	Next nColuna
	TRB->(dbSkip())	
EndDo
u_GDToExcel(aCampos,aCols,Alltrim(FunName()))
	COPY TO &cArqExcell VIA "DBFCDX" //Ajustado chamada do dbfcdxads para dbfcdx - Felipe Duran
	
	FRename(cArqExcell+".dtc",cArqExcell+".xls")
	
	MakeDir(cDestino) // CRIA DIRETำRIO CASO NรO EXISTA
	CpyS2T(cArqExcell+".xls",cDestino,.T.) // COPIA ARQUIVO PARA MAQUINA DO USUมRIO
	
	// Buscando e apagando arquivos temporแrios - MCVN 27/08/10
	aTmp := Directory( cDestino+"*.tmp" )
	For nI:= 1 to Len(aTmp)
		fErase(cDestino+aTmp[nI,1])
	Next nI

DbSelectArea("TRB")
DbCloseArea()
//GeZZOMail()
//Ferase(_cArqTrb+".DTC")
//Ferase(_cArqTrb+OrdBagExt())

If lExcel
	Aviso("Aten็ใo","Arquivo gerado na pasta: c:"+cArqExcell,{"Ok"},1)
	//ShellExecute("Open","Excel",'"'+"C:\"+cArqExcell+".dbf"+'"',"",5)          
Else
	Aviso("Aten็ใo","Nใo foram encontrados dados para gerar o arquivo.",{"Ok"},1)
EndIf

Return 
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDIPGERZZO บAutor  ณMicrosiga           บ Data ณ  06/16/16   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function DipRetPrv(cProduto)
Local cSQL 		:= ""
Local dDatPrv 	:= StoD("") 
DEFAULT cProduto:= ""

cSQL := " SELECT TOP 1 "
cSQL += " 	C7_DENTREG "
cSQL += " 	FROM "
cSQL += 		RetSQLName("SC7")
cSQL += " 		WHERE "
cSQL += " 			C7_FILIAL IN('01','04') AND "
cSQL +=	" 			C7_PRODUTO = '"+cProduto+"' AND "
cSQL +=	" 			C7_ENCER   = ' ' AND "
cSQL +=	" 			C7_RESIDUO = ' ' AND "            
cSQL += " 			D_E_L_E_T_ = ' ' "
cSQL += " ORDER BY C7_DENTREG "

cSQL := ChangeQuery(cSQL)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),"QRYSC7",.T.,.T.)

TCSETFIELD("QRYSC7","C7_DENTREG","D",8,0)

If QRYSC7->(!Eof())
	dDatPrv := QRYSC7->C7_DENTREG
	QRYSC7->(DbSkip())	
EndIf
QRYSC7->(dbCloseArea())

Return dDatPrv    
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDIPGERZZO บAutor  ณMicrosiga           บ Data ณ  06/10/16   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function AjustaSX1(cPerg)
Local aRegs   := {}
DEFAULT cPerg := ""

dbSelectArea("SX1")
dbSetOrder(1)

aAdd(aRegs,{cPerg,"01","Data De     ?","","","mv_ch1","D",08,0,0,"G","","MV_PAR01","","","","","","","","","","","","","","","","","","","","","","","","",''})
aAdd(aRegs,{cPerg,"02","Data At้    ?","","","mv_ch2","D",08,0,0,"G","","MV_PAR02","","","","","","","","","","","","","","","","","","","","","","","","",''})
aAdd(aRegs,{cPerg,"03","Operador(a) ?","","","mv_ch3","C",06,0,0,"G","","MV_PAR03","","","","","","","","","","","","","","","","","","","","","","","","",'SU7'})
aAdd(aRegs,{cPerg,"04","Vendedor(a) ?","","","mv_ch4","C",06,0,0,"G","","MV_PAR04","","","","","","","","","","","","","","","","","","","","","","","","",'SA3'})
aAdd(aRegs,{cPerg,"05","Fornecedor  ?","","","mv_ch5","C",06,0,0,"G","","MV_PAR05","","","","","","","","","","","","","","","","","","","","","","","","",'SA2'})
aAdd(aRegs,{cPerg,"06","Cliente     ?","","","mv_ch6","C",06,0,0,"G","","MV_PAR06","","","","","","","","","","","","","","","","","","","","","","","","",'SA1'})
aAdd(aRegs,{cPerg,"07","Produto De  ?","","","mv_ch7","C",15,0,0,"G","","MV_PAR07","","","","","","","","","","","","","","","","","","","","","","","","",'SB1'})
aAdd(aRegs,{cPerg,"08","Produto At้ ?","","","mv_ch8","C",15,0,0,"G","","MV_PAR08","","","","","","","","","","","","","","","","","","","","","","","","",'SB1'})

PlsVldPerg( aRegs )       

Return 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ ZZOSCH บAutor  ณReginaldo Borges    บ Data ณ  08/01/19     บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function ZZOSCH(aWork)

	If ValType(aWork)=="A"
		PREPARE ENVIRONMENT EMPRESA aWork[1] FILIAL aWork[2] FUNNAME "MATA410"
		Conout("ZZOSCH - Inicio em: "+DtoC(dDataBase)+" - "+SubStr(Time(),1,2)+":"+SubStr(Time(),4,2)+" Emp:"+aWork[1]+" Fil:"+aWork[2])		
	EndIf
	
	Pergunte("DIPZZ0",.f.)
	MV_PAR01 := (ddatabase)-1
	MV_PAR02 := (ddatabase)-1
	MV_PAR03 := ""
	MV_PAR04 := ""
	MV_PAR05 := ""
	MV_PAR06 := ""
	MV_PAR07 := ""
	MV_PAR08 := "Z"
	
	U_GeZZOSCH()      
	
	If ValType(aWork)=="A"	
		RESET ENVIRONMENT
		Conout("ZZOSCH - Fim em: "+DtoC(dDataBase)+" - "+SubStr(Time(),1,2)+":"+SubStr(Time(),4,2)+" Emp:"+aWork[1]+" Fil:"+aWork[2])  
	EndIf
Return 

User Function GeZZOSCH()
Local cSQL    	:= ""
Local cPerg   	:= "DIPZZ0"               
Local aCampos 	:= {}
Local aTamSX3 	:= {}  
Local aTmpDir   := {}
Local cArqTrb 	:= ""
Local cDestino 	:= "C:\EXCELL-DBF\" 
Local lExcel    := .F.
Local lCompleto := .T.
Local cArqExcell:= "\Excell-DBF\Perda_Estoque"+".xls"

aTamSX3 := TamSX3("B1_COD")
AAdd(aCampos ,{"PRODUTO","C",aTamSX3[1],aTamSX3[2]})

aTamSX3 := TamSX3("B1_DESC")
AAdd(aCampos ,{"NOMEPRO","C",aTamSX3[1],aTamSX3[2]})

If lCompleto
	aTamSX3 := TamSX3("A2_NREDUZ")
	AAdd(aCampos ,{"NOMEFOR","C",aTamSX3[1],aTamSX3[2]})
EndIf

aTamSX3 := TamSX3("ZZO_QUANT")
AAdd(aCampos ,{"QUANT","N",aTamSX3[1],aTamSX3[2]})

aTamSX3 := TamSX3("ZZO_VLRUNI")
AAdd(aCampos ,{"VLRUNI","N",aTamSX3[1],aTamSX3[2]})
                      
aTamSX3 := TamSX3("ZZO_VLRTOT")
AAdd(aCampos ,{"VLRTOT","N",aTamSX3[1],aTamSX3[2]})
             
If lCompleto
	aTamSX3 := TamSX3("ZZO_ESTOQU")
	AAdd(aCampos ,{"ESTOQU","N",aTamSX3[1],aTamSX3[2]})
	
	AAdd(aCampos ,{"PREVISAO","D",8,0})
EndIf

aTamSX3 := TamSX3("ZZO_EXPLIC")
AAdd(aCampos ,{"EXPLIC","C",20,aTamSX3[2]})  

aTamSX3 := TamSX3("U7_NOME")
AAdd(aCampos ,{"NOMEOPE","C",aTamSX3[1],aTamSX3[2]})

aTamSX3 := TamSX3("A1_COD")
AAdd(aCampos ,{"CLIENTE","C",aTamSX3[1],aTamSX3[2]})

aTamSX3 := TamSX3("A1_NREDUZ")
AAdd(aCampos ,{"NOMECLI","C",aTamSX3[1],aTamSX3[2]})

aTamSX3 := TamSX3("ZZO_DATA")
AAdd(aCampos ,{"DATAINC","D",aTamSX3[1],aTamSX3[2]})

If lCompleto
	aTamSX3 := TamSX3("A2_COD")
	AAdd(aCampos ,{"FORNECE","C",aTamSX3[1],aTamSX3[2]})
	
	AAdd(aCampos ,{"CONSUMO","N",10,0})
EndIf
//EAP - DELTA 190820
If (Select("TRB") <> 0)        
	DbSelectArea("TRB")    
   DbCloseArea("TRB")          
Endif

cArqTrb := CriaTrab(aCampos,.T.)
DbUseArea(.T.,,cArqTrb,"TRB",.F.,.F.)
                           
If lCompleto
	cChave  := 'NOMEFOR + NOMEPRO + NOMEOPE'
Else 
	cChave  := 'CLIENTE + PRODUTO + DTOS(DATAINC)'	
EndIf
IndRegua("TRB",cArqTrb,cChave,,,"Criando Indice...")

cSQL := " SELECT "
cSQL += " 	CASE WHEN ZZO_FILIAL='01' THEN 'MTZ' ELSE 'CD' END FILIAL, "
cSQL += " 	U7_COD, U7_NOME, "
cSQL += "	B1_COD, B1_DESC, "
cSQL += " 	A2_COD, A2_NREDUZ, "
cSQL += "	A1_COD, A1_NREDUZ, "
cSQL += " 	A3_COD, A3_NOME, "
cSQL += " 	ZZO_QUANT, ZZO_VLRUNI, ZZO_VLRTOT, ZZO_ESTOQU, ZZO_EXPLIC, ZZO_DATA "
cSQL += " 	FROM "
cSQL += 		RetSQLName("ZZO")
cSQL += " 		INNER JOIN "
cSQL +=  			RetSQLName("SB1")
cSQL += " 			ON "
cSQL += " 				ZZO_FILIAL = B1_FILIAL AND "
cSQL += " 				ZZO_PRODUT = B1_COD "
cSQL += " 		INNER JOIN "
cSQL +=  			RetSQLName("SU7")
cSQL += " 			ON "
cSQL += " 				U7_FILIAL = '"+xFilial("SU7")+"' AND "
cSQL += " 				U7_COD = ZZO_OPERAD "
If !lCompleto
	cSQL += "			AND U7_CODUSU = '"+RetCodUsr()+"' "
EndIf
cSQL += " 		INNER JOIN "
cSQL +=  			RetSQLName("SA1")
cSQL += " 			ON "
cSQL += " 				A1_FILIAL = '"+xFilial("SA1")+"' AND "
cSQL += " 				A1_COD = ZZO_CLIENT "
cSQL += " 		INNER JOIN "
cSQL +=  			RetSQLName("SA2")
cSQL += " 			ON "
cSQL += " 				A2_FILIAL = '"+xFilial("SA2")+"' AND "
cSQL += " 				A2_COD = B1_PROC "
cSQL += " 		INNER JOIN "
cSQL +=  			RetSQLName("SA3")
cSQL += " 			ON "
cSQL += " 				A3_FILIAL = '"+xFilial("SA3")+"' AND "
cSQL += " 				A3_COD = A1_VEND "
cSQL += " 		WHERE "                            
cSQL += " 			ZZO_FILIAL IN('01','04') AND "
If !Empty(DtoS(MV_PAR01))
	cSQL += " 		ZZO_DATA 	>='"+DtoS(MV_PAR01)+"' AND "
EndIf
If !Empty(DtoS(MV_PAR02))
	cSQL += "		ZZO_DATA 	<='"+DtoS(MV_PAR02)+"' AND "
EndIf             
If !Empty(MV_PAR03)
	cSQL += " 		ZZO_OPERAD 	= '"+MV_PAR03+"' AND "
EndIf             
If !Empty(MV_PAR04)
	cSQL += " 		A3_COD 		= '"+MV_PAR04+"' AND "
EndIf
If !Empty(MV_PAR05)
	cSQL += " 		B1_PROC 	= '"+MV_PAR05+"' AND "
EndIf
If !Empty(MV_PAR06)
	cSQL += " 		A1_COD	 	= '"+MV_PAR06+"' AND "
EndIf
If !Empty(MV_PAR07)
	cSQL += " 		B1_COD 		>= '"+MV_PAR07+"' AND "
EndIf  
If !Empty(MV_PAR08)
	cSQL += " 		B1_COD	 	<= '"+MV_PAR08+"' AND "
EndIf

cSQL += " 			ZZO010.D_E_L_E_T_ = ' ' AND "
cSQL += " 			SB1010.D_E_L_E_T_ = ' ' AND "
cSQL += " 			SA1010.D_E_L_E_T_ = ' ' AND "
cSQL += " 			SU7010.D_E_L_E_T_ = ' ' "

cSQL := ChangeQuery(cSQL)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),"QRYTRB",.F.,.T.)

TCSETFIELD("QRYTRB","ZZO_DATA","D",8,0)

While QRYTRB->(!Eof())
     TRB->(RecLock("TRB",.T.))
     	TRB->NOMEOPE 	:= QRYTRB->U7_NOME
     	TRB->PRODUTO	:= QRYTRB->B1_COD
     	TRB->NOMEPRO	:= QRYTRB->B1_DESC
     	If lCompleto
	     	TRB->FORNECE	:= QRYTRB->A2_COD
    	 	TRB->NOMEFOR	:= QRYTRB->A2_NREDUZ
    	EndIf
     	TRB->CLIENTE	:= QRYTRB->A1_COD
     	TRB->NOMECLI	:= QRYTRB->A1_NREDUZ
		TRB->QUANT		:= QRYTRB->ZZO_QUANT
		TRB->VLRUNI		:= QRYTRB->ZZO_VLRUNI
		TRB->VLRTOT		:= QRYTRB->ZZO_VLRTOT
		If lCompleto
			TRB->ESTOQU		:= QRYTRB->ZZO_ESTOQU
		EndIf
		TRB->EXPLIC		:= IIf(QRYTRB->ZZO_EXPLIC=="P","PERDA PARCIAL",IIf(QRYTRB->ZZO_EXPLIC=="T","PERDA TOTAL",IIf(QRYTRB->ZZO_EXPLIC=="F","CAIXA FECHADA","COTACAO")))
		TRB->DATAINC	:= QRYTRB->ZZO_DATA	 
		If lCompleto
			TRB->CONSUMO	:= u_DipCalCons(QRYTRB->B1_COD)
			TRB->PREVISAO   := DipRetPr(QRYTRB->B1_COD)
		EndIf
	TRB->(MsUnLock())                           
	lExcel := .T.
	QRYTRB->(dbSkip())
EndDo
QRYTRB->(dbCloseArea())

DbSelectArea("TRB")
TRB->(dbGotop())
ProcRegua(TRB->(RECCOUNT()))	
aCols := Array(TRB->(RECCOUNT()),Len(aCampos))
nColuna := 0
nLinha := 0
While TRB->(!Eof())
	nLinha++
	IncProc(OemToAnsi("Gerando planilha excel..."))
	For nColuna := 1 to Len(aCampos)
		aCols[nLinha][nColuna] := &("TRB->("+aCampos[nColuna][1]+")")			
	Next nColuna
	TRB->(dbSkip())	
EndDo
u_GDToExcel(aCampos,aCols,Alltrim(FunName()))

//EAP DELTA 1908

	COPY TO &cArqExcell VIA "DBFCDX" //Ajustado chamada do dbfcdxads para dbfcdx - Felipe Duran
	
	FRename(cArqExcell+".dtc",cArqExcell+".xls")
	
//	MakeDir(cDestino) // CRIA DIRETำRIO CASO NรO EXISTA
//	CpyS2T(cArqExcell+".xls",cDestino,.T.) // COPIA ARQUIVO PARA MAQUINA DO USUมRIO
	
	// Buscando e apagando arquivos temporแrios - MCVN 27/08/10
	aTmp := Directory( cDestino+"*.tmp" )
	For nI:= 1 to Len(aTmp)
		fErase(cDestino+aTmp[nI,1])
	Next nI

DbSelectArea("TRB")
DbCloseArea()
GeZZOMail()
Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGEZZOSCH บAutor  ณReginaldo Borges    บ Data ณ  08/01/19   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function DipRetPr(cProduto)
Local cSQL 		:= ""
Local dDatPrv 	:= StoD("") 
DEFAULT cProduto:= ""

cSQL := " SELECT TOP 1 "
cSQL += " 	C7_DENTREG "
cSQL += " 	FROM "
cSQL += 		RetSQLName("SC7")
cSQL += " 		WHERE "
cSQL += " 			C7_FILIAL IN('01','04') AND "
cSQL +=	" 			C7_PRODUTO = '"+cProduto+"' AND "
cSQL +=	" 			C7_ENCER   = ' ' AND "
cSQL +=	" 			C7_RESIDUO = ' ' AND "            
cSQL += " 			D_E_L_E_T_ = ' ' "
cSQL += " ORDER BY C7_DENTREG "

cSQL := ChangeQuery(cSQL)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),"QRYSC7",.T.,.T.)

TCSETFIELD("QRYSC7","C7_DENTREG","D",8,0)

If QRYSC7->(!Eof())
	dDatPrv := QRYSC7->C7_DENTREG
	QRYSC7->(DbSkip())	
EndIf
QRYSC7->(dbCloseArea())

Return dDatPrv    


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGeZZOMail บAutor  ณReginaldo Borges   บ Data ณ  08/01/19   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GEZZOSCH                                                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function GeZZOMail()

Local cAccount  := Lower(Alltrim(GetMv("MV_RELACNT")))
Local cFrom     := Lower(Alltrim(GetMv("MV_RELACNT")))
Local cPassword := Alltrim(GetMv("MV_RELPSW"))
Local cServer   := Alltrim(GetMv("MV_RELSERV"))  
Local cCC		:= " "
Local cBCC      := ""
Local cTo		:= GetNewPar("MV_ZZOMAIL","patricia.mendonca@dipromed.com.br;erich.pontoldio@dipromed.com.br;maximo.canuto@dipromed.com.br;reginaldo.borges@dipromed.com.br;compras@dipromed.com.br")
Local cAnexos	:= "\Excell-DBF\perda_estoque"+".xls"
Local lSmtpAuth := GetNewPar("MV_RELAUTH",.F.)
Local lAutOk	:= .F.
Local cSubject  := "Relat๓rio Vendas Perdas Estoque" 
Local cFuncSentIc :=   "DIPGERZZO.PRW"
Local _aMsgIc     := {}

aAdd( _aMsgIc , { "MENSAGEM: ","Anexo Relat๓rio Vendas Perdas Estoque!"})

If GetNewPar("ES_ATIVJOB",.T.)
	U_UEnvMail(cTo,cSubject,_aMsgIc,cAnexos,cFrom,cFuncSentIc)
EndIf


CONNECT SMTP SERVER cServer ACCOUNT cAccount PASSWORD cPassword Result lOk

If !lAutOk
	If ( lSmtpAuth )
		lAutOk := MailAuth(cAccount,cPassword)
	Else
		lAutOk := .T.
	EndIf
EndIf

If lOk .and. lAutOk 
	If !Empty(cCC)
		SEND MAIL FROM cFrom TO cTo CC cCC BCC cBcc SUBJECT Alltrim(cSubject) BODY cBody ATTACHMENT cAnexos Result lOk

	Else
		SEND MAIL FROM cFrom TO cTo SUBJECT Alltrim(cSubject) BODY cBody ATTACHMENT cAnexos Result lOk

	EndIf
	If lOk
		//MsgInfo("Email enviado com sucesso")
	Else
		GET MAIL ERROR cErro
		//MsgStop("Nใo foi possํvel enviar o Email." +Chr(13)+Chr(10)+ cErro,"AVISO")
		Return .f.
	EndIf
Else
	GET MAIL ERROR cErro
	//MsgStop("Erro na conexใo com o SMTP Server." +Chr(13)+Chr(10)+ cErro,"AVISO")
	Return .f.
EndIf
DISCONNECT SMTP SERVER
Return .T.

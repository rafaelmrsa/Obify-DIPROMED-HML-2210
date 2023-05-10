#INCLUDE "RWMAKE.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "PROTHEUS.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDIPGERZZK บAutor  ณMicrosiga           บ Data ณ  06/10/16   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function DipZZKRel()
Local cSQL    	:= ""
Local cPerg   	:= "DIPZZK"               
Local aCampos 	:= {}
Local aTamSX3 	:= {}  
Local aTmpDir   := {}
Local cArqTrb 	:= ""
Local cArqExcell:= "\Excell-DBF\"+U_DipUsr()+"-Perdas"
Local cDestino 	:= "C:\EXCELL-DBF\" 
Local lExcel    := .F.

AjustaSX1(cPerg)

If !Pergunte(cPerg,.T.)  
	Return
EndIf

aTamSX3 := TamSX3("B1_COD")
AAdd(aCampos ,{"COD","C",aTamSX3[1],aTamSX3[2]})

aTamSX3 := TamSX3("B1_DESC")
AAdd(aCampos ,{"PRODUTO","C",aTamSX3[1],aTamSX3[2]})

aTamSX3 := TamSX3("A2_NREDUZ")
AAdd(aCampos ,{"FORNECEDOR","C",aTamSX3[1],aTamSX3[2]})

aTamSX3 := TamSX3("ZZK_QUANTI")
AAdd(aCampos ,{"QTDE","N",aTamSX3[1],aTamSX3[2]})

aTamSX3 := TamSX3("B1_UM")
AAdd(aCampos ,{"UM","C",aTamSX3[1],aTamSX3[2]})

aTamSX3 := TamSX3("ZZK_VLRAPR")
AAdd(aCampos ,{"VLRSOL","N",aTamSX3[1],aTamSX3[2]})                  

aTamSX3 := TamSX3("ZZK_VLRSIS")
AAdd(aCampos ,{"VLRSIS","N",aTamSX3[1],aTamSX3[2]})                  

aTamSX3 := TamSX3("ZZK_VLRSUG")
AAdd(aCampos ,{"VLRSUG","N",aTamSX3[1],aTamSX3[2]})                  

AAdd(aCampos ,{"VLRTOT","N",14,2})                                   

aTamSX3 := TamSX3("ZZK_CUSDIP")
AAdd(aCampos ,{"CUSDIP","N",aTamSX3[1],aTamSX3[2]})

aTamSX3 := TamSX3("ZZK_MARDIP")
AAdd(aCampos ,{"MAR_CUSDIP","N",aTamSX3[1],aTamSX3[2]})

aTamSX3 := TamSX3("ZZK_LISFOR")
AAdd(aCampos ,{"CUSPRC","N",aTamSX3[1],aTamSX3[2]})
                             
aTamSX3 := TamSX3("ZZK_MARFOR")
AAdd(aCampos ,{"MAR_PRC","N",aTamSX3[1],aTamSX3[2]})

aTamSX3 := TamSX3("C5_NUM")
AAdd(aCampos ,{"PEDIDO","C",aTamSX3[1],aTamSX3[2]})

//AAdd(aCampos ,{"PREVISAO","D",8,0})
	                                   
//aTamSX3 := TamSX3("ZZK_ESTOQU")
//AAdd(aCampos ,{"ESTOQU","N",aTamSX3[1],aTamSX3[2]})                  

aTamSX3 := TamSX3("U7_NOME")
AAdd(aCampos ,{"OPERADORA","C",aTamSX3[1],aTamSX3[2]})

//aTamSX3 := TamSX3("A1_COD")
//AAdd(aCampos ,{"CLIENTE","C",aTamSX3[1],aTamSX3[2]})

//aTamSX3 := TamSX3("A1_NOME")
//AAdd(aCampos ,{"NOMECLI","C",aTamSX3[1],aTamSX3[2]})

aTamSX3 := TamSX3("ZZK_DATA")
AAdd(aCampos ,{"DATAINC","D",aTamSX3[1],aTamSX3[2]})

AAdd(aCampos ,{"MES","C",2,0})

//aTamSX3 := TamSX3("ZZK_HORA")
//AAdd(aCampos ,{"HORAINC","C",aTamSX3[1],aTamSX3[2]})

//aTamSX3 := TamSX3("ZZK_USERAP")
//AAdd(aCampos ,{"USRAPR","C",aTamSX3[1],aTamSX3[2]})

aTamSX3 := TamSX3("ZZK_APROVA")
AAdd(aCampos ,{"APROVA","C",aTamSX3[1],aTamSX3[2]})

//aTamSX3 := TamSX3("A2_COD")
//AAdd(aCampos ,{"FORNECE","C",aTamSX3[1],aTamSX3[2]})
	
//AAdd(aCampos ,{"CONSUMO","N",10,0})

AAdd(aCampos ,{"SETOR","C",30,0})

aTamSX3 := TamSX3("ZZK_EXPLIC")
AAdd(aCampos ,{"EXPLIC","C",aTamSX3[1],aTamSX3[2]})  

AAdd(aCampos ,{"CONDPAG","C",30,0})

//EAP - DELTA 190820
If (Select("TRB") <> 0)        
	DbSelectArea("TRB")    
   DbCloseArea("TRB")          
Endif

cArqTrb := CriaTrab(aCampos,.T.)
DbUseArea(.T.,,cArqTrb,"TRB",.F.,.F.)

cChave  := 'FORNECEDOR + STR(VLRTOT)'	

IndRegua("TRB",cArqTrb,cChave,,,"Criando Indice...")

cSQL := " SELECT "
cSQL += "	C5_NUM,B1_COD,B1_DESC,A2_NREDUZ,ZZK_QUANTI,ZZK_VLRAPR,B1_UM,ZZK_QUANTI*ZZK_VLRAPR TOTAL,ZZK_ESTOQU,ZZK_EXPLIC,ZZK_CUSDIP,ZZK_LISFOR,ZZK_MARDIP,ZZK_MARFOR, "
cSQl += "	U7_NOME,A1_COD,A1_NREDUZ,ZZK_DATA,ZZK_HORA,A2_COD,ZZK_USERAP,ZZK_APROVA,ZZK_VLRSUP,ZZK_VLRMIN,ZZK_VLRSUG,U7_POSTO,C5_NOTA,ZZK_VLRSIS,C5_CONDPAG "
cSQL += "	FROM "
cSQL += 		RetSQLName("ZZK")+" A "                       
cSQL += "		INNER JOIN "
cSQL += 			RetSQLName("SC5")
cSQL += "			ON "
cSQL += "				C5_FILIAL IN('01','04') AND "
cSQL += "				C5_NUM = A.ZZK_PEDIDO AND "
//cSQL += "				C5_XDATEXP = ''  AND "
cSQL += 				RetSQLName("SC5")+".D_E_L_E_T_ = ' ' "
cSQL += "		INNER JOIN "
cSQL += 			RetSQLName("SB1")
cSQL += "			ON "
cSQL += "				B1_FILIAL = C5_FILIAL AND "
cSQL += "				B1_COD = A.ZZK_PRODUT AND "
cSQL += 				RetSQLName("SB1")+".D_E_L_E_T_ = ' ' "
cSQL += "		INNER JOIN "
cSQL += 			RetSQLName("SA2")
cSQL += "			ON "
cSQL += "				A2_FILIAL = '"+xFilial("SA2")+"' AND "
cSQL += "				A2_COD = B1_PROC AND "
cSQL += 				RetSQLName("SA2")+".D_E_L_E_T_ = ' ' "
cSQL += "		INNER JOIN "
cSQL += 			RetSQLName("SC6")
cSQL += "			ON "
cSQL += "				C6_FILIAL = C5_FILIAL AND "
cSQL += "				C6_NUM = C5_NUM AND "		
cSQL += "				C6_PRODUTO  = A.ZZK_PRODUT AND "		
cSQL += "				C6_ITEM  = A.ZZK_ITEM AND "		
cSQL += "				((C6_TIPODIP <> '1' AND C6_NOTA = ' ') OR "
cSQL += 				RetSQLName("SC6")+".D_E_L_E_T_ = '*') "
cSQL += "		INNER JOIN "
cSQL += 			RetSQLName("SU7")
cSQL += "			ON "
cSQL += "				U7_FILIAL = '"+xFilial("SU7")+"' AND "
cSQL += "				U7_COD = C5_OPERADO AND "
cSQL += 				RetSQLName("SU7")+".D_E_L_E_T_ = ' ' "      
cSQL += "		INNER JOIN "
cSQL += 			RetSQLName("SA1")
cSQL += "			ON "
cSQL += "				A1_FILIAL = '"+xFilial("SA1")+"' AND "
cSQL += "				A1_COD = C5_CLIENTE AND "
cSQL += "				A1_LOJA = C5_LOJACLI AND "
cSQL += 				RetSQLName("SA1")+".D_E_L_E_T_ = ' ' "
cSQL += "		WHERE "
cSQL += "			ZZK_FILIAL IN('01','04') AND "
cSQL += "			(SELECT TOP 1 "
cSQL += "				RTRIM(B.ZZK_STATUS)+B.ZZK_DATA+B.ZZK_HORA "
cSQL += "				FROM "
cSQL += 					RetSQLName("ZZK")+" B "
cSQL += "					WHERE "
cSQL += "						B.ZZK_FILIAL = A.ZZK_FILIAL AND "
cSQL += "						B.ZZK_PEDIDO = A.ZZK_PEDIDO "
cSQL += "			ORDER BY R_E_C_N_O_ DESC) = 'REPROVADO'+A.ZZK_DATA+A.ZZK_HORA AND "
If !Empty(DtoS(MV_PAR01))
	cSQL += "						A.ZZK_DATA >= '"+DTOS(MV_PAR01)+"' AND "
EndIf
If !Empty(DtoS(MV_PAR02))
	cSQL += "						A.ZZK_DATA <= '"+DTOS(MV_PAR02)+"' AND "
EndIf                                                             
If !Empty(MV_PAR03)
	cSQL += "						C5_OPERADO = '"+MV_PAR03+"' AND "
EndIf
If !Empty(MV_PAR04)
	cSQL += "						C5_VEND1 = '"+MV_PAR04+"' AND "
EndIf
If !Empty(MV_PAR05)
	cSQL += "						A2_COD = '"+MV_PAR05+"' AND "
EndIf
If !Empty(MV_PAR06)
	cSQL += "						C5_CLIENTE = '"+MV_PAR06+"' AND "
EndIf                                                                
If !Empty(MV_PAR07)
	cSQL += "						B1_COD >= '"+MV_PAR07+"' AND "
EndIf
If !Empty(MV_PAR08)
	cSQL += "						B1_COD <= '"+MV_PAR08+"' AND "
EndIf
cSQL += "			A.D_E_L_E_T_ = ' ' "

cSQL := ChangeQuery(cSQL)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),"QRYTRB",.F.,.T.)

TCSETFIELD("QRYTRB","ZZK_DATA","D",8,0)

While QRYTRB->(!Eof())         

	If !Empty(QRYTRB->C5_NOTA) .And. DipJaFat(QRYTRB->C5_NUM,QRYTRB->B1_COD)
		QRYTRB->(dbSkip()) 			
		Loop
	EndIf
	
	If QRYTRB->ZZK_VLRAPR >= QRYTRB->ZZK_VLRSIS
		QRYTRB->(dbSkip())
		Loop
	EndIf
		
     TRB->(RecLock("TRB",.T.))	   
     	TRB->COD		:= QRYTRB->B1_COD
     	TRB->PRODUTO	:= QRYTRB->B1_DESC
     	TRB->UM     	:= QRYTRB->B1_UM  
     	//TRB->FORNECE	:= QRYTRB->A2_COD
   	 	TRB->FORNECEDOR := QRYTRB->A2_NREDUZ
     	//TRB->CLIENTE	:= QRYTRB->A1_COD
     	//TRB->NOMECLI	:= QRYTRB->A1_NOME
		TRB->QTDE		:= QRYTRB->ZZK_QUANTI
		TRB->VLRSOL		:= QRYTRB->ZZK_VLRAPR
		TRB->VLRTOT		:= QRYTRB->TOTAL
		TRB->VLRSIS		:= QRYTRB->ZZK_VLRSIS
		TRB->VLRSUG		:= QRYTRB->ZZK_VLRSUG
		TRB->PEDIDO		:= QRYTRB->C5_NUM
     	TRB->OPERADORA  := QRYTRB->U7_NOME
		//TRB->ESTOQU	:= QRYTRB->ZZK_ESTOQU
		TRB->EXPLIC		:= QRYTRB->ZZK_EXPLIC
		TRB->DATAINC	:= QRYTRB->ZZK_DATA	 
		//TRB->CONSUMO	:= u_DipCalCons(QRYTRB->B1_COD)
		//TRB->PREVISAO := DipRetPrv(QRYTRB->B1_COD)		
		TRB->CUSDIP     := QRYTRB->ZZK_CUSDIP     
		TRB->MAR_CUSDIP := QRYTRB->ZZK_MARDIP     		
		TRB->CUSPRC     := QRYTRB->ZZK_LISFOR
		TRB->MAR_PRC    := QRYTRB->ZZK_MARFOR     
		TRB->SETOR      := IIf(QRYTRB->U7_POSTO=="02","TELEVENDAS",IIf(QRYTRB->U7_POSTO=="01","APOIO","LICITACOES"))
		TRB->MES		:= StrZero(Month(QRYTRB->ZZK_DATA),2)
		//TRB->USRAPR   := QRYTRB->ZZK_USERAP
		TRB->APROVA     := QRYTRB->ZZK_APROVA
		TRB->CONDPAG    := QRYTRB->C5_CONDPAG+"-"+POSICIONE("SE4",1,xFilial("SE4")+AllTrim(QRYTRB->C5_CONDPAG),"E4_DESCRI")
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

//EAP - DELTA 190820
DbSelectArea("TRB")

	COPY TO &cArqExcell VIA "DBFCDX" //Ajustado chamada do dbfcdxads para dbfcdx - Felipe Duran
	
	FRename(cArqExcell+".dtc",cArqExcell+".xls")
	
	MakeDir(cDestino) // CRIA DIRETำRIO CASO NรO EXISTA
	CpyS2T(cArqExcell+".xls",cDestino,.T.) // COPIA ARQUIVO PARA MAQUINA DO USUมRIO
	
	// Buscando e apagando arquivos temporแrios - MCVN 27/08/10
	aTmp := Directory( cDestino+"*.tmp" )
	For nI:= 1 to Len(aTmp)
		fErase(cDestino+aTmp[nI,1])
	Next nI
TRB->(dbCloseArea())  

If lExcel
	Aviso("Aten็ใo","Arquivo gerado na pasta c:"+cArqExcell,{"Ok"},1)
	ShellExecute("Open","Excel",'"'+"C:\"+cArqExcell+".xls"+'"',"",5)          
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
ฑฑบPrograma  ณDIPZZKREL บAutor  ณMicrosiga           บ Data ณ  08/05/16   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function DipJaFat(cPedido,cProduto)
Local cSQL 		 := ""
Local _lRet		 := .F.
DEFAULT cPedido  := ""
DEFAULT cProduto := ""
  
cSQL := " SELECT "
cSQL += " 	* "
cSQL += " 	FROM "
cSQL +=  		RetSQLName("SC6")
cSQL += " 		WHERE "
cSQL += " 			C6_FILIAL = '"+xFilial("SC6")+"' AND "
cSQL += " 			C6_NUM = '"+cPedido+"' AND "
cSQL += " 			C6_PRODUTO = '"+cProduto+"' AND "
cSQL += " 			C6_NOTA <> ' ' AND "
cSQL += " 			D_E_L_E_T_ = ' ' "

cSQL := ChangeQuery(cSQL)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),"QRYSC6",.T.,.T.)

If !QRYSC6->(Eof())
	_lRet := .T.
EndIf
QRYSC6->(dbCloseArea())

Return _lRet
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
ฑฑบPrograma  ณ GEZZKSCH บAutor  ณReginaldo Borges บ Data ณ  08/01/19     บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function ZZKSCH(aWork)

	If ValType(aWork)=="A"
		PREPARE ENVIRONMENT EMPRESA aWork[1] FILIAL aWork[2] FUNNAME "MATA410"
		Conout("GEZZKSCH - Inicio em: "+DtoC(dDataBase)+" - "+SubStr(Time(),1,2)+":"+SubStr(Time(),4,2)+" Emp:"+aWork[1]+" Fil:"+aWork[2])		
	EndIf
	
	Pergunte("DIPZZK",.f.)
	MV_PAR01 := (ddatabase)-1
	MV_PAR02 := (ddatabase)-1
	MV_PAR03 := ""
	MV_PAR04 := ""
	MV_PAR05 := ""
	MV_PAR06 := ""
	MV_PAR07 := ""
	MV_PAR08 := "Z"
	
	U_GeZZKSCH()      
	
	If ValType(aWork)=="A"	
		RESET ENVIRONMENT
		Conout("GEZZKSCH - Fim em: "+DtoC(dDataBase)+" - "+SubStr(Time(),1,2)+":"+SubStr(Time(),4,2)+" Emp:"+aWork[1]+" Fil:"+aWork[2])  
	EndIf
Return 


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGEZZKSCH บAutor  ณReginaldo Borges     บ Data ณ  08/01/19   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function GEZZKSCH()
Local cSQL    	:= ""
Local cPerg   	:= "DIPZZK"               
Local aCampos 	:= {}
Local aTamSX3 	:= {}  
Local aTmpDir   := {}
Local cArqTrb 	:= ""
Local cDestino 	:= "C:\EXCELL-DBF\" 
Local lExcel    := .F.
Local cArqExcell:= "\Excell-DBF\perda_valor"+".xls"

aTamSX3 := TamSX3("B1_COD")
AAdd(aCampos ,{"COD","C",aTamSX3[1],aTamSX3[2]})

aTamSX3 := TamSX3("B1_DESC")
AAdd(aCampos ,{"PRODUTO","C",aTamSX3[1],aTamSX3[2]})

aTamSX3 := TamSX3("A2_NREDUZ")
AAdd(aCampos ,{"FORNECEDOR","C",aTamSX3[1],aTamSX3[2]})

aTamSX3 := TamSX3("ZZK_QUANTI")
AAdd(aCampos ,{"QTDE","N",aTamSX3[1],aTamSX3[2]})

aTamSX3 := TamSX3("B1_UM")
AAdd(aCampos ,{"UM","C",aTamSX3[1],aTamSX3[2]})

aTamSX3 := TamSX3("ZZK_VLRAPR")
AAdd(aCampos ,{"VLRSOL","N",aTamSX3[1],aTamSX3[2]})                  

aTamSX3 := TamSX3("ZZK_VLRSIS")
AAdd(aCampos ,{"VLRSIS","N",aTamSX3[1],aTamSX3[2]})                  

aTamSX3 := TamSX3("ZZK_VLRSUG")
AAdd(aCampos ,{"VLRSUG","N",aTamSX3[1],aTamSX3[2]})                  

AAdd(aCampos ,{"VLRTOT","N",14,2})                                   

aTamSX3 := TamSX3("ZZK_CUSDIP")
AAdd(aCampos ,{"CUSDIP","N",aTamSX3[1],aTamSX3[2]})

aTamSX3 := TamSX3("ZZK_MARDIP")
AAdd(aCampos ,{"MAR_CUSDIP","N",aTamSX3[1],aTamSX3[2]})

aTamSX3 := TamSX3("ZZK_LISFOR")
AAdd(aCampos ,{"CUSPRC","N",aTamSX3[1],aTamSX3[2]})
                             
aTamSX3 := TamSX3("ZZK_MARFOR")
AAdd(aCampos ,{"MAR_PRC","N",aTamSX3[1],aTamSX3[2]})

aTamSX3 := TamSX3("C5_NUM")
AAdd(aCampos ,{"PEDIDO","C",aTamSX3[1],aTamSX3[2]})

//AAdd(aCampos ,{"PREVISAO","D",8,0})
	                                   
//aTamSX3 := TamSX3("ZZK_ESTOQU")
//AAdd(aCampos ,{"ESTOQU","N",aTamSX3[1],aTamSX3[2]})                  

aTamSX3 := TamSX3("U7_NOME")
AAdd(aCampos ,{"OPERADORA","C",aTamSX3[1],aTamSX3[2]})

//aTamSX3 := TamSX3("A1_COD")
//AAdd(aCampos ,{"CLIENTE","C",aTamSX3[1],aTamSX3[2]})

//aTamSX3 := TamSX3("A1_NOME")
//AAdd(aCampos ,{"NOMECLI","C",aTamSX3[1],aTamSX3[2]})

aTamSX3 := TamSX3("ZZK_DATA")
AAdd(aCampos ,{"DATAINC","D",aTamSX3[1],aTamSX3[2]})

AAdd(aCampos ,{"MES","C",2,0})

//aTamSX3 := TamSX3("ZZK_HORA")
//AAdd(aCampos ,{"HORAINC","C",aTamSX3[1],aTamSX3[2]})

//aTamSX3 := TamSX3("ZZK_USERAP")
//AAdd(aCampos ,{"USRAPR","C",aTamSX3[1],aTamSX3[2]})

aTamSX3 := TamSX3("ZZK_APROVA")
AAdd(aCampos ,{"APROVA","C",aTamSX3[1],aTamSX3[2]})

//aTamSX3 := TamSX3("A2_COD")
//AAdd(aCampos ,{"FORNECE","C",aTamSX3[1],aTamSX3[2]})
	
//AAdd(aCampos ,{"CONSUMO","N",10,0})

AAdd(aCampos ,{"SETOR","C",30,0})

aTamSX3 := TamSX3("ZZK_EXPLIC")
AAdd(aCampos ,{"EXPLIC","C",aTamSX3[1],aTamSX3[2]})  

AAdd(aCampos ,{"CONDPAG","C",30,0})

//EAP - DELTA 190820
If (Select("TRB") <> 0)        
	DbSelectArea("TRB")    
   DbCloseArea("TRB")          
Endif

cArqTrb := CriaTrab(aCampos,.T.)
DbUseArea(.T.,,cArqTrb,"TRB",.F.,.F.)

cChave  := 'FORNECEDOR + STR(VLRTOT)'	

IndRegua("TRB",cArqTrb,cChave,,,"Criando Indice...")

cSQL := " SELECT "
cSQL += "	C5_NUM,B1_COD,B1_DESC,A2_NREDUZ,ZZK_QUANTI,ZZK_VLRAPR,B1_UM,ZZK_QUANTI*ZZK_VLRAPR TOTAL,ZZK_ESTOQU,ZZK_EXPLIC,ZZK_CUSDIP,ZZK_LISFOR,ZZK_MARDIP,ZZK_MARFOR, "
cSQl += "	U7_NOME,A1_COD,A1_NREDUZ,ZZK_DATA,ZZK_HORA,A2_COD,ZZK_USERAP,ZZK_APROVA,ZZK_VLRSUP,ZZK_VLRMIN,ZZK_VLRSUG,U7_POSTO,C5_NOTA,ZZK_VLRSIS,C5_CONDPAG "
cSQL += "	FROM "
cSQL += 		RetSQLName("ZZK")+" A "                       
cSQL += "		INNER JOIN "
cSQL += 			RetSQLName("SC5")
cSQL += "			ON "
cSQL += "				C5_FILIAL IN('01','04') AND "
cSQL += "				C5_NUM = A.ZZK_PEDIDO AND "
//cSQL += "				C5_XDATEXP = ''  AND "
cSQL += 				RetSQLName("SC5")+".D_E_L_E_T_ = ' ' "
cSQL += "		INNER JOIN "
cSQL += 			RetSQLName("SB1")
cSQL += "			ON "
cSQL += "				B1_FILIAL = C5_FILIAL AND "
cSQL += "				B1_COD = A.ZZK_PRODUT AND "
cSQL += 				RetSQLName("SB1")+".D_E_L_E_T_ = ' ' "
cSQL += "		INNER JOIN "
cSQL += 			RetSQLName("SA2")
cSQL += "			ON "
cSQL += "				A2_FILIAL = '"+xFilial("SA2")+"' AND "
cSQL += "				A2_COD = B1_PROC AND "
cSQL += 				RetSQLName("SA2")+".D_E_L_E_T_ = ' ' "
cSQL += "		INNER JOIN "
cSQL += 			RetSQLName("SC6")
cSQL += "			ON "
cSQL += "				C6_FILIAL = C5_FILIAL AND "
cSQL += "				C6_NUM = C5_NUM AND "		
cSQL += "				C6_PRODUTO  = A.ZZK_PRODUT AND "		
cSQL += "				C6_ITEM  = A.ZZK_ITEM AND "		
cSQL += "				((C6_TIPODIP <> '1' AND C6_NOTA = ' ') OR "
cSQL += 				RetSQLName("SC6")+".D_E_L_E_T_ = '*') "
cSQL += "		INNER JOIN "
cSQL += 			RetSQLName("SU7")
cSQL += "			ON "
cSQL += "				U7_FILIAL = '"+xFilial("SU7")+"' AND "
cSQL += "				U7_COD = C5_OPERADO AND "
cSQL += 				RetSQLName("SU7")+".D_E_L_E_T_ = ' ' "      
cSQL += "		INNER JOIN "
cSQL += 			RetSQLName("SA1")
cSQL += "			ON "
cSQL += "				A1_FILIAL = '"+xFilial("SA1")+"' AND "
cSQL += "				A1_COD = C5_CLIENTE AND "
cSQL += "				A1_LOJA = C5_LOJACLI AND "
cSQL += 				RetSQLName("SA1")+".D_E_L_E_T_ = ' ' "
cSQL += "		WHERE "
cSQL += "			ZZK_FILIAL IN('01','04') AND "
cSQL += "			(SELECT TOP 1 "
cSQL += "			 	RTRIM(B.ZZK_STATUS)+B.ZZK_DATA+B.ZZK_HORA "
cSQL += "				FROM "
cSQL += 					RetSQLName("ZZK")+" B "
cSQL += "					WHERE "
cSQL += "						B.ZZK_FILIAL = A.ZZK_FILIAL AND "
cSQL += "						B.ZZK_PEDIDO = A.ZZK_PEDIDO "
cSQL += "			ORDER BY R_E_C_N_O_ DESC) = 'REPROVADO'+A.ZZK_DATA+A.ZZK_HORA AND "
If !Empty(DtoS(MV_PAR01))
	cSQL += "						A.ZZK_DATA >= '"+DTOS(MV_PAR01)+"' AND "
EndIf
If !Empty(DtoS(MV_PAR02))
	cSQL += "						A.ZZK_DATA <= '"+DTOS(MV_PAR02)+"' AND "
EndIf                                                             
If !Empty(MV_PAR03)
	cSQL += "						C5_OPERADO = '"+MV_PAR03+"' AND "
EndIf
If !Empty(MV_PAR04)
	cSQL += "						C5_VEND1 = '"+MV_PAR04+"' AND "
EndIf
If !Empty(MV_PAR05)
	cSQL += "						A2_COD = '"+MV_PAR05+"' AND "
EndIf
If !Empty(MV_PAR06)
	cSQL += "						C5_CLIENTE = '"+MV_PAR06+"' AND "
EndIf                                                                
If !Empty(MV_PAR07)
	cSQL += "						B1_COD >= '"+MV_PAR07+"' AND "
EndIf
If !Empty(MV_PAR08)
	cSQL += "						B1_COD <= '"+MV_PAR08+"' AND "
EndIf
cSQL += "			A.D_E_L_E_T_ = ' ' "

cSQL := ChangeQuery(cSQL)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),"QRYTRB",.F.,.T.)

TCSETFIELD("QRYTRB","ZZK_DATA","D",8,0)

While QRYTRB->(!Eof())         

	If !Empty(QRYTRB->C5_NOTA) .And. DipJaFa(QRYTRB->C5_NUM,QRYTRB->B1_COD)
		QRYTRB->(dbSkip()) 			
		Loop
	EndIf
	
	If QRYTRB->ZZK_VLRAPR >= QRYTRB->ZZK_VLRSIS
		QRYTRB->(dbSkip())
		Loop
	EndIf
		
     TRB->(RecLock("TRB",.T.))	   
     	TRB->COD		:= QRYTRB->B1_COD
     	TRB->PRODUTO	:= QRYTRB->B1_DESC
     	TRB->UM     	:= QRYTRB->B1_UM  
     	//TRB->FORNECE	:= QRYTRB->A2_COD
   	 	TRB->FORNECEDOR := QRYTRB->A2_NREDUZ
     	//TRB->CLIENTE	:= QRYTRB->A1_COD
     	//TRB->NOMECLI	:= QRYTRB->A1_NOME
		TRB->QTDE		:= QRYTRB->ZZK_QUANTI
		TRB->VLRSOL		:= QRYTRB->ZZK_VLRAPR
		TRB->VLRTOT		:= QRYTRB->TOTAL
		TRB->VLRSIS		:= QRYTRB->ZZK_VLRSIS
		TRB->VLRSUG		:= QRYTRB->ZZK_VLRSUG
		TRB->PEDIDO		:= QRYTRB->C5_NUM
     	TRB->OPERADORA  := QRYTRB->U7_NOME
		//TRB->ESTOQU	:= QRYTRB->ZZK_ESTOQU
		TRB->EXPLIC		:= QRYTRB->ZZK_EXPLIC
		TRB->DATAINC	:= QRYTRB->ZZK_DATA	 
		//TRB->CONSUMO	:= u_DipCalCons(QRYTRB->B1_COD)
		//TRB->PREVISAO := DipRetPr(QRYTRB->B1_COD)		
		TRB->CUSDIP     := QRYTRB->ZZK_CUSDIP     
		TRB->MAR_CUSDIP := QRYTRB->ZZK_MARDIP     		
		TRB->CUSPRC     := QRYTRB->ZZK_LISFOR
		TRB->MAR_PRC    := QRYTRB->ZZK_MARFOR     
		TRB->SETOR      := IIf(QRYTRB->U7_POSTO=="02","TELEVENDAS",IIf(QRYTRB->U7_POSTO=="01","APOIO","LICITACOES"))
		TRB->MES		:= StrZero(Month(QRYTRB->ZZK_DATA),2)
		//TRB->USRAPR   := QRYTRB->ZZK_USERAP
		TRB->APROVA     := QRYTRB->ZZK_APROVA
		TRB->CONDPAG    := QRYTRB->C5_CONDPAG+"-"+POSICIONE("SE4",1,xFilial("SE4")+AllTrim(QRYTRB->C5_CONDPAG),"E4_DESCRI")
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

DbSelectArea("TRB")

If File(cArqExcell)
	fErase(cArqExcell)
EndIf

COPY TO &cArqExcell VIA "DBFCDX"

//EAP DELTA 1908

	FRename(cArqExcell+".dtc",cArqExcell+".xls")
//MakeDir(cDestino)
//CpyS2T(cArqExcell,cDestino,.T.)

aTmpDir := Directory( cDestino+"*.tmp" )
For nI:= 1 to Len(aTmpDir)
	fErase(cDestino+aTmpDir[nI,1])
Next nI 

GeZZKMail()

TRB->(dbCloseArea())  

Return 
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณZZOSCH บAutor  ณReginaldo Borges       บ Data ณ  08/01/19   บฑฑ
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
ฑฑบPrograma  ณGEZZKSCH บAutor  ณReginaldo Borges     บ Data ณ  08/01/19   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function DipJaFa(cPedido,cProduto)
Local cSQL 		 := ""
Local _lRet		 := .F.
DEFAULT cPedido  := ""
DEFAULT cProduto := ""
  
cSQL := " SELECT "
cSQL += " 	* "
cSQL += " 	FROM "
cSQL +=  		RetSQLName("SC6")
cSQL += " 		WHERE "
cSQL += " 			C6_FILIAL = '"+xFilial("SC6")+"' AND "
cSQL += " 			C6_NUM = '"+cPedido+"' AND "
cSQL += " 			C6_PRODUTO = '"+cProduto+"' AND "
cSQL += " 			C6_NOTA <> ' ' AND "
cSQL += " 			D_E_L_E_T_ = ' ' "

cSQL := ChangeQuery(cSQL)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),"QRYSC6",.T.,.T.)

If !QRYSC6->(Eof())
	_lRet := .T.
EndIf
QRYSC6->(dbCloseArea())

Return _lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGerZZOMail บAutor  ณReginaldo Borges   บ Data ณ  08/01/19   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GERZZOSCH                                                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function GeZZKMail()

Local cAccount  := Lower(Alltrim(GetMv("MV_RELACNT")))
Local cFrom     := Lower(Alltrim(GetMv("MV_RELACNT")))
Local cPassword := Alltrim(GetMv("MV_RELPSW"))
Local cServer   := Alltrim(GetMv("MV_RELSERV"))  
Local cCC		:= " "
Local cBCC      := ""
Local cTo		:= GetNewPar("MV_ZZKMAIL","patricia.mendonca@dipromed.com.br;erich.pontoldio@dipromed.com.br;maximo.canuto@dipromed.com.br;reginaldo.borges@dipromed.com.br;compras@dipromed.com.br")
Local cAnexos	:= "\Excell-DBF\perda_valor"+".dbf"
Local lSmtpAuth := GetNewPar("MV_RELAUTH",.F.)
Local lAutOk	:= .F.
Local cSubject  := "Relat๓rio Vendas Perdas Valor" 
Local cFuncSentIc :=   "DIPZZKREL.PRW"
Local _aMsgIc     := {}

aAdd( _aMsgIc , { "MENSAGEM: ","Anexo relat๓rio Vendas Perdas Valor!"})

If GetNewPar("ES_ATIVJOB",.T.)
	U_UEnvMail(cTo,cSubject,_aMsgIc,cAnexos,cFrom,cFuncSentIc)
EndIf

/*
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
*/

Return .T.

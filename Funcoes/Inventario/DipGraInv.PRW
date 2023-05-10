#include "PROTHEUS.CH"
#include "TOTVS.CH"
#INCLUDE "TBICONN.CH"
#include "MSGRAPHI.CH"
#include "topconn.ch"
#INCLUDE "JPEG.CH"
/*
#Include "MSOLE.CH"
#INCLUDE "AP5MAIL.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "JPEG.CH"
*/

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDIPGRAINVบAutor  ณMicrosiga           บ Data ณ  04/24/14   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function DipGraInv()
Local cSQL 		:= ""             
Local aDipGraf1	:= {}
Local aDipGraf2	:= {}
Local aDipGraf3	:= {}
Local aCores 	:= {}      
Local aPerc1	:= {} 
Local aPerc2	:= {} 
Local aPerc3	:= {} 
Local aAux		:= {}
Local cPerc 	:= ""
Local aSize		:= MsAdvSize()  
Local nPos		:= 0
Local nCor 		:= 0
Local nTotal 	:= 0

Local cVerde1	:= ""
Local cAmare1	:= ""
Local cCinza1	:= ""
Local cLaran1	:= ""
Local cAzul1	:= ""
Local cVerme1	:= ""
Local cPreto1	:= ""
Local cRoxo1	:= ""

Local cVerde2	:= ""
Local cAmare2	:= ""
Local cCinza2	:= ""
Local cLaran2	:= ""
Local cAzul2	:= ""
Local cVerme2	:= ""
Local cPreto2	:= ""
Local cRoxo2	:= ""   

Local cVerde3	:= ""   
Local cAmare3	:= ""
Local cCinza3	:= ""
Local cLaran3	:= ""
Local cAzul3	:= ""
Local cVerme3	:= ""
Local cPreto3	:= ""
Local cRoxo3	:= ""

PRIVATE oFont12n:= TFont():New("Arial",9,12,.T.,.T.,5,.T.,5,.T.,.F.)

/* __________________________
|                            |
|     QUERY CONTAGEM 1       |
|____________________________|
*/

cSQL := " SELECT "
cSQL += " 		CASE "
cSQL += " 			WHEN CBA_STATUS = '0' THEN 'NAO INIC.' "
cSQL += " 			WHEN CBA_STATUS = '1' THEN 'EM ANDAM.' "
cSQL += " 			WHEN CBA_STATUS = '2' THEN 'PAUSA' "
cSQL += " 			WHEN CBA_STATUS = '3' THEN 'CONTADO' "
cSQL += " 			WHEN CBA_STATUS = '4' THEN 'FINALIZADO' "
cSQL += " 			WHEN CBA_STATUS = '5' THEN 'PROCESSADO' "
cSQL += " 			WHEN CBA_STATUS = '6' THEN 'SEM SALDO' "
cSQL += " 		END 'SIT' "
cSQL += " 		,COUNT(*) 'QTD' "
cSQL += " 	FROM "
cSQL += 		RetSQLName("CBA")
cSQL += " 		WHERE "
cSQL += " 			CBA_FILIAL = '04' AND "                                 
cSQL += "		   (CBA_CONTR <= 0 OR (CBA_CONTR=1 AND CBA_STATUS>'2')) AND "
cSQL += " 			D_E_L_E_T_ = ' ' "
cSQL += " GROUP BY CBA_STATUS "
cSQL += " ORDER BY CBA_STATUS "
                                           
cSQL := ChangeQuery(cSQL)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),"QRYGRA1",.T.,.T.)

TCSETFIELD("QRYGRA1","QTD","N",10,0)

If !QRYGRA1->(Eof())
	QRYGRA1->(dbEval({|| aAdd(aDipGraf1, {QRYGRA1->QTD,QRYGRA1->SIT})}))
EndIf
QRYGRA1->(dbCloseArea())

/* __________________________
|                            |
|     QUERY CONTAGEM 2       |
|____________________________|
*/                    

cSQL := " SELECT "
cSQL += " 		CASE "                                        
cSQL += "			WHEN CBA_STATUS = '3' AND CBA_CONTR = '1' THEN 'NAO INIC.' "
cSQL += " 			WHEN CBA_STATUS = '1' THEN 'EM ANDAM.' "
cSQL += " 			WHEN CBA_STATUS = '2' THEN 'PAUSA' "
cSQL += " 			WHEN CBA_STATUS = '3' AND CBA_XCONTB = ' ' THEN 'CONTADO' "
cSQL += " 			WHEN CBA_STATUS = '4' THEN 'FINALIZADO' "
cSQL += " 			WHEN CBA_STATUS = '5' THEN 'PROCESSADO' "
cSQL += " 			WHEN CBA_STATUS = '6' THEN 'SEM SALDO' "
cSQL += " 			WHEN CBA_XCONTB = 'OK' THEN 'CONT. BAT.' "
cSQL += " 			WHEN CBA_XCONTB = 'E' THEN 'QTD.ELEIT.' "
cSQL += " 		END 'SIT' "
cSQL += " 		,COUNT(*) 'QTD' "
cSQL += " 	FROM "
cSQL += 		RetSQLName("CBA")
cSQL += " 		WHERE "
cSQL += " 			CBA_FILIAL = '04' AND "  
cSQL += "		   (CBA_CONTR >= 2 OR (CBA_CONTR=1 AND CBA_STATUS<='3')) AND "
cSQL += " 			D_E_L_E_T_ = ' ' "
cSQL += " GROUP BY CBA_XCONTB, CBA_STATUS, CBA_CONTR "
cSQL += " ORDER BY CBA_XCONTB, CBA_STATUS "

cSQL := ChangeQuery(cSQL)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),"QRYGRA2",.T.,.T.)

TCSETFIELD("QRYGRA2","QTD","N",10,0)    

If !QRYGRA2->(Eof())
	QRYGRA2->(dbEval({|| DipAddGr2(QRYGRA2->QTD,QRYGRA2->SIT,@aDipGraf2)}))
EndIf
QRYGRA2->(dbCloseArea())

/* __________________________
|                            |
|     QUERY CONTAGEM GERAL   |
|____________________________|
*/

cSQL := " SELECT "
cSQL += " 		CASE "
cSQL += "			WHEN CBA_STATUS = '0' THEN 'NAO INIC.' "
cSQL += " 			WHEN CBA_STATUS = '1' THEN 'EM ANDAM.' "
cSQL += " 			WHEN CBA_STATUS = '2' THEN 'PAUSA' "
cSQL += " 			WHEN CBA_STATUS = '3' AND CBA_XCONTB = ' ' THEN 'CONTADO' "
cSQL += " 			WHEN CBA_STATUS = '4' THEN 'FINALIZADO' "
cSQL += " 			WHEN CBA_STATUS = '5' THEN 'PROCESSADO' "
cSQL += " 			WHEN CBA_STATUS = '6' THEN 'SEM SALDO' "  
cSQL += " 			WHEN CBA_XCONTB = 'OK' THEN 'CONT. BAT.' "
cSQL += " 			WHEN CBA_XCONTB = 'E' THEN 'QTD.ELEIT.' "
cSQL += " 		END 'SIT' "
cSQL += " 		,COUNT(*) 'QTD' "
cSQL += " 	FROM "
cSQL += 		RetSQLName("CBA")
cSQL += " 		WHERE "
cSQL += " 			CBA_FILIAL = '04' AND "  
cSQL += " 			D_E_L_E_T_ = ' ' "
cSQL += " GROUP BY CBA_XCONTB, CBA_STATUS "
cSQL += " ORDER BY CBA_XCONTB, CBA_STATUS "

cSQL := ChangeQuery(cSQL)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),"QRYGRA3",.T.,.T.)

TCSETFIELD("QRYGRA3","QTD","N",10,0)    

If !QRYGRA3->(Eof())
	QRYGRA3->(dbEval({|| aAdd(aDipGraf3,{QRYGRA3->QTD,QRYGRA3->SIT}),nTotal+=QRYGRA3->QTD }))
EndIf
QRYGRA3->(dbCloseArea())  


aCores := {	{'NAO INIC.' ,CLR_HGREEN},;
			{'EM ANDAM.' ,CLR_YELLOW},;
			{'PAUSA'	 ,CLR_HGRAY},;
			{'CONTADO'	 ,RGB(255,165,0)},;
			{'FINALIZADO',CLR_HBLUE},;
			{'PROCESSADO',CLR_HRED},;
			{'SEM SALDO' ,CLR_BLACK},;
			{'CONT. BAT.' ,RGB(128,0,128)},;
			{'QTD.ELEIT.' ,CLR_WHITE}}

DEFINE DIALOG oDlg TITLE "Contagens Inventario" FROM aSize[1],aSize[2] TO aSize[6]-50,aSize[5]-10 OF oMainWnd PIXEL

// Cria o grแfico contagem 1
oGraphic1 := TMSGraphic():New( 01,01,oDlg,,,RGB(239,239,239),228,250)
oGraphic1:SetTitle('Contagem 1', "Atualizado em " + dtoc(Date())+" เs "+Time(), CLR_HRED, A_LEFTJUST, GRP_TITLE )
oGraphic1:SetMargins(2,6,6,6)
oGraphic1:SetLegenProp(GRP_SCRRIGHT, CLR_LIGHTGRAY, GRP_AUTO,.T.)     

For nI := 1 to Len(aDipGraf1)       
    nPos := DipRetPos(aDipGraf1[nI,2],aCores)
    If nPos > 0
    	nCor := aCores[nPos,2]
    EndIf
	nSerie := oGraphic1:CreateSerie(GRP_BAR,aDipGraf1[nI,2]) 
	oGraphic1:Add(nSerie,aDipGraf1[nI,1],"Contagem 1",nCor)
    aAdd(aPerc1, {aDipGraf1[nI,2],(aDipGraf1[nI,1]*100)/nTotal})
Next nI

// Cria o grแfico contagem 2
oGraphic2 := TMSGraphic():New(01,222,oDlg,,,RGB(239,239,239),228,250)
oGraphic2:SetTitle('Contagem 2', "Atualizado em " + dtoc(Date())+" เs "+Time(), CLR_HRED, A_LEFTJUST, GRP_TITLE )
oGraphic2:SetMargins(2,6,6,6)
oGraphic2:SetLegenProp(GRP_SCRRIGHT, CLR_LIGHTGRAY, GRP_AUTO,.T.)

For nI := 1 to Len(aDipGraf2)     
	nPos := DipRetPos(aDipGraf2[nI,2],aCores)
	If nPos > 0
		nCor := aCores[nPos,2]
	EndIf
	nSerie := oGraphic2:CreateSerie(GRP_BAR,aDipGraf2[nI,2])
	oGraphic2:Add(nSerie,aDipGraf2[nI,1],"Contagem 2",nCor)
    aAdd(aPerc2, {aDipGraf2[nI,2],(aDipGraf2[nI,1]*100)/nTotal})
Next nI

// Cria o grแfico contagem Geral
oGraphic3 := TMSGraphic():New( 01,443,oDlg,,,RGB(239,239,239),228,250)
oGraphic3:SetTitle('Contagem Geral', "Atualizado em " + dtoc(Date())+" เs "+Time(), CLR_HRED, A_LEFTJUST, GRP_TITLE )
oGraphic3:SetMargins(2,6,6,6)
oGraphic3:SetLegenProp(GRP_SCRRIGHT, CLR_LIGHTGRAY, GRP_AUTO,.T.)     

For nI := 1 to Len(aDipGraf3)     
	nPos := DipRetPos(aDipGraf3[nI,2],aCores)
	If nPos > 0
		nCor := aCores[nPos,2]
	EndIf
	nSerie := oGraphic3:CreateSerie(GRP_BAR,aDipGraf3[nI,2])
	oGraphic3:Add(nSerie,aDipGraf3[nI,1],"Contagem Geral",nCor)
    aAdd(aPerc3, {aDipGraf3[nI,2],(aDipGraf3[nI,1]*100)/nTotal})
Next nI
             
/*

Montagem dinโmica -> Sem tempo para fazer mais testes

nLin := 248
nCol := 005
For nI:=1 to 3		          

	cTipo := Str(nI,1)                    
	If nI==1
		aAux := aPerc1
	ElseIf nI==2
		aAux := aPerc2
	Else              
		aAux := aPerc3
		cTipo := "Geral"
	EndIf

	@ nLin,nCol TO 300,224 LABEL 'Contagem '+cTipo OF oDlg   PIXEL

	nPos :=DipRetPos('NAO INIC.',aAux)
	If nPos > 0   
		&("cPVerde"+Str(nI,1)) := TransForm(aAux[nPos,2],"@E 999.99")+"%"
	Else
		&("cPVerde"+Str(nI,1)) := "0%"
	EndIf
	@ nLin+10,nCol+5  JPEG oBmp RESOURCE "br_verde" 	SIZE 15,15 OF oDlg PIXEL ON CLICK MsgInfo("NAO INIC.") 	BORDER CURSOR oCursor       
	@ nLin+11,nCol+15 SAY &("cPVerde"+Str(nI,1)) SIZE 50,10 PIXEL OF oDlg FONT oFont12n    

	nPos :=DipRetPos('EM ANDAM.',aAux)
	If nPos > 0   
		&("cPAmarelo"+Str(nI,1)) := TransForm(aAux[nPos,2],"@E 999.99")+"%"
	Else
		&("cPAmarelo"+Str(nI,1)) := "0%"
	EndIf
	@ nLin+20,nCol+5  JPEG oBmp RESOURCE "br_amarelo" 	SIZE 15,15 OF oDlg PIXEL ON CLICK MsgInfo("EM ANDAM.") 	BORDER CURSOR oCursor
	@ nLin+21,nCol+15 SAY &("cPAmarelo"+Str(nI,1))  SIZE 50,10 PIXEL OF oDlg FONT oFont12n

	nPos :=DipRetPos('PAUSA',aAux)
	If nPos > 0   
		&("cPCinza"+Str(nI,1)) := TransForm(aAux[nPos,2],"@E 999.99")+"%"
	Else
		&("cPCinza"+Str(nI,1)) := "0%"
	EndIf
	@ nLin+30,nCol+5  JPEG oBmp RESOURCE "br_cinza" 	SIZE 15,15 OF oDlg PIXEL ON CLICK MsgInfo("PAUSA") 		BORDER CURSOR oCursor
	@ nLin+31,nCol+15 SAY &("cPCinza"+Str(nI,1)) SIZE 50,10 PIXEL OF oDlg FONT oFont12n
	                    
	nPos :=DipRetPos('CONTADO',aAux)
	If nPos > 0   
		&("cPLaranja"+Str(nI,1)) := TransForm(aAux[nPos,2],"@E 999.99")+"%"
	Else
		&("cPLaranja"+Str(nI,1)) := "0%"
	EndIf
	@ nLin+40,nCol+5 JPEG oBmp RESOURCE "br_laranja" 	SIZE 15,15 OF oDlg PIXEL ON CLICK MsgInfo("CONTADO") 	BORDER CURSOR oCursor
	@ nLin+41,nCol+15 SAY &("cPLaranja"+Str(nI,1)) SIZE 50,10 PIXEL OF oDlg FONT oFont12n
	                
	nPos :=DipRetPos('FINALIZADO',aAux)
	If nPos > 0   
		&("cPAzul"+Str(nI,1)) := TransForm(aAux[nPos,2],"@E 999.99")+"%"
	Else
		&("cPAzul"+Str(nI,1)) := "0%"
	EndIf
	@ nLin+10,nCol+85 JPEG oBmp RESOURCE "br_azul" 		SIZE 15,15 OF oDlg PIXEL ON CLICK MsgInfo("FINALIZADO") BORDER CURSOR oCursor
	@ nLin+11,nCol+95 SAY &("cPAzul"+Str(nI,1)) SIZE 50,10 PIXEL OF oDlg FONT oFont12n
	                
	nPos :=DipRetPos('PROCESSADO',aAux)
	If nPos > 0   
   		&("cPVermelh"+Str(nI,1)) := TransForm(aAux[nPos,2],"@E 999.99")+"%"
	Else
		&("cPVermelh"+Str(nI,1)) := "0%"
	EndIf
	@ nLin+20,nCol+85 JPEG oBmp RESOURCE "br_vermelho" 	SIZE 15,15 OF oDlg PIXEL ON CLICK MsgInfo("PROCESSADO") BORDER CURSOR oCursor
	@ nLin+21,nCol+95 SAY &("cPVermelh"+Str(nI,1)) SIZE 50,10 PIXEL OF oDlg FONT oFont12n
	                
	nPos :=DipRetPos('SEM SALDO',aAux)
	If nPos > 0   
		&("cPPreto"+Str(nI,1)) := TransForm(aAux[nPos,2],"@E 999.99")+"%"
	Else
		&("cPPreto"+Str(nI,1)) := "0%"
	EndIf
	@ nLin+30,nCol+85 JPEG oBmp RESOURCE "br_preto" 	SIZE 15,15 OF oDlg PIXEL ON CLICK MsgInfo("SEM SALDO") 	BORDER CURSOR oCursor
	@ nLin+31,nCol+95 SAY &("cPPreto"+Str(nI,1)) SIZE 50,10 PIXEL OF oDlg FONT oFont12n	
	
	nCol+=221
		
Next nI	

*/

nLin := 248
nCol := 005
                                                         

@ 248,005 TO 300,224 LABEL 'Contagem 1' 	OF oDlg PIXEL
@ 248,226 TO 300,446 LABEL 'Contagem 2' 	OF oDlg PIXEL
@ 248,448 TO 300,667 LABEL 'Contagem Geral' OF oDlg PIXEL

/* __________________________
|                            |
|    Nใo Iniciado	 	     |
|____________________________|
*/
nPos := DipRetPos('NAO INIC.',aPerc1)
cVerde1 := TransForm(IIf(nPos>0,aPerc1[nPos,2],0),"@E 999.99")+"%" 
@ nLin+10,nCol+5  JPEG oBmp RESOURCE "br_verde" 	SIZE 15,15 OF oDlg PIXEL ON CLICK MsgInfo("NAO INIC.") 	BORDER CURSOR oCursor
@ nLin+11,nCol+15 SAY cVerde1 SIZE 50,10 PIXEL OF oDlg FONT oFont12n

/* __________________________
|                            |
|    Em Andamento 	 	     |
|____________________________|
*/
nPos := DipRetPos('EM ANDAM.',aPerc1)
cAmare1 := TransForm(IIf(nPos>0,aPerc1[nPos,2],0),"@E 999.99")+"%" 
@ nLin+20,nCol+5  JPEG oBmp RESOURCE "br_amarelo" 	SIZE 15,15 OF oDlg PIXEL ON CLICK MsgInfo("EM ANDAM.") 	BORDER CURSOR oCursor
@ nLin+21,nCol+15 SAY cAmare1 SIZE 50,10 PIXEL OF oDlg FONT oFont12n

/* __________________________
|                            |
|    Pausa 				     |
|____________________________|
*/
nPos := DipRetPos('PAUSA',aPerc1)       
cCinza1 := TransForm(IIf(nPos>0,aPerc1[nPos,2],0),"@E 999.99")+"%"
@ nLin+30,nCol+5  JPEG oBmp RESOURCE "br_cinza" 	SIZE 15,15 OF oDlg PIXEL ON CLICK MsgInfo("PAUSA") 		BORDER CURSOR oCursor
@ nLin+31,nCol+15 SAY cCinza1 SIZE 50,10 PIXEL OF oDlg FONT oFont12n

/* __________________________
|                            |
|    Contado		 	     |
|____________________________|
*/
nPos := DipRetPos('CONTADO',aPerc1) 
cLaran1 := TransForm(IIf(nPos>0,aPerc1[nPos,2],0),"@E 999.99")+"%"
@ nLin+40,nCol+5 JPEG oBmp RESOURCE "br_laranja" 	SIZE 15,15 OF oDlg PIXEL ON CLICK MsgInfo("CONTADO") 	BORDER CURSOR oCursor
@ nLin+41,nCol+15 SAY cLaran1 SIZE 50,10 PIXEL OF oDlg FONT oFont12n

/* __________________________
|                            |
|    Finalizado		 	     |
|____________________________|
*/
nPos := DipRetPos('FINALIZADO',aPerc1) 
cAzul1 := TransForm(IIf(nPos>0,aPerc1[nPos,2],0),"@E 999.99")+"%"
@ nLin+10,nCol+85 JPEG oBmp RESOURCE "br_azul" 		SIZE 15,15 OF oDlg PIXEL ON CLICK MsgInfo("FINALIZADO") BORDER CURSOR oCursor
@ nLin+11,nCol+95 SAY cAzul1 SIZE 50,10 PIXEL OF oDlg FONT oFont12n

/* __________________________
|                            |
|    Processado		 	     |
|____________________________|
*/
nPos := DipRetPos('PROCESSADO',aPerc1)   
cVerme1 := TransForm(IIf(nPos>0,aPerc1[nPos,2],0),"@E 999.99")+"%"
@ nLin+20,nCol+85 JPEG oBmp RESOURCE "br_vermelho" 	SIZE 15,15 OF oDlg PIXEL ON CLICK MsgInfo("PROCESSADO") BORDER CURSOR oCursor
@ nLin+21,nCol+95 SAY cVerme1 SIZE 50,10 PIXEL OF oDlg FONT oFont12n

/* __________________________
|                            |
|    Sem Saldo		 	     |
|____________________________|
*/
nPos := DipRetPos('SEM SALDO',aPerc1)  
cPreto1 := TransForm(IIf(nPos>0,aPerc1[nPos,2],0),"@E 999.99")+"%"
@ nLin+30,nCol+85 JPEG oBmp RESOURCE "br_preto" 	SIZE 15,15 OF oDlg PIXEL ON CLICK MsgInfo("SEM SALDO") 	BORDER CURSOR oCursor
@ nLin+31,nCol+95 SAY cPreto1 SIZE 50,10 PIXEL OF oDlg FONT oFont12n

/* __________________________
|                            |
|   2 Contagens Batidas      |
|____________________________|
*/
nPos :=DipRetPos('CONT. BAT.',aPerc1)
cRoxo1 := TransForm(IIf(nPos>0,aPerc1[nPos,2],0),"@E 999.99")+"%"
@ nLin+40,nCol+85 JPEG oBmp RESOURCE "br_violeta" 	SIZE 15,15 OF oDlg PIXEL ON CLICK MsgInfo("CONT. BAT.") 	BORDER CURSOR oCursor
@ nLin+41,nCol+95 SAY cRoxo1 SIZE 50,10 PIXEL OF oDlg FONT oFont12n

nCol+=221

/* __________________________
|                            |
|    Nใo Iniciado	 	     |
|____________________________|
*/                    

nPos := DipRetPos('NAO INIC.',aPerc2)
cVerde2 := TransForm(IIf(nPos>0,aPerc2[nPos,2],0),"@E 999.99")+"%"
@ nLin+10,nCol+5  JPEG oBmp RESOURCE "br_verde" 	SIZE 15,15 OF oDlg PIXEL ON CLICK MsgInfo("NAO INIC.") 	BORDER CURSOR oCursor
@ nLin+11,nCol+15 SAY cVerde2 SIZE 50,10 PIXEL OF oDlg FONT oFont12n

/* __________________________
|                            |
|    Em Andamento 	 	     |
|____________________________|
*/
nPos :=DipRetPos('EM ANDAM.',aPerc2)
cAmare2 := TransForm(IIf(nPos>0,aPerc2[nPos,2],0),"@E 999.99")+"%"
@ nLin+20,nCol+5  JPEG oBmp RESOURCE "br_amarelo" 	SIZE 15,15 OF oDlg PIXEL ON CLICK MsgInfo("EM ANDAM.") 	BORDER CURSOR oCursor
@ nLin+21,nCol+15 SAY cAmare2 SIZE 50,10 PIXEL OF oDlg FONT oFont12n

/* __________________________
|                            |
|    Pausa 				     |
|____________________________|
*/
nPos :=DipRetPos('PAUSA',aPerc2)
cCinza2 := TransForm(IIf(nPos>0,aPerc2[nPos,2],0),"@E 999.99")+"%"
@ nLin+30,nCol+5  JPEG oBmp RESOURCE "br_cinza" 	SIZE 15,15 OF oDlg PIXEL ON CLICK MsgInfo("PAUSA") 		BORDER CURSOR oCursor
@ nLin+31,nCol+15 SAY cCinza2 SIZE 50,10 PIXEL OF oDlg FONT oFont12n

/* __________________________
|                            |
|    Contado		 	     |
|____________________________|
*/
nPos :=DipRetPos('CONTADO',aPerc2)
cLaran2 := TransForm(IIf(nPos>0,aPerc2[nPos,2],0),"@E 999.99")+"%"
@ nLin+40,nCol+5 JPEG oBmp RESOURCE "br_laranja" 	SIZE 15,15 OF oDlg PIXEL ON CLICK MsgInfo("CONTADO") 	BORDER CURSOR oCursor
@ nLin+41,nCol+15 SAY cLaran2 SIZE 50,10 PIXEL OF oDlg FONT oFont12n

/* __________________________
|                            |
|    Finalizado		 	     |
|____________________________|
*/
nPos :=DipRetPos('FINALIZADO',aPerc2)                            
cAzul2 := TransForm(IIf(nPos>0,aPerc2[nPos,2],0),"@E 999.99")+"%"
@ nLin+10,nCol+85 JPEG oBmp RESOURCE "br_azul" 		SIZE 15,15 OF oDlg PIXEL ON CLICK MsgInfo("FINALIZADO") BORDER CURSOR oCursor
@ nLin+11,nCol+95 SAY cAzul2 SIZE 50,10 PIXEL OF oDlg FONT oFont12n

/* __________________________
|                            |
|    Processado		 	     |
|____________________________|
*/
nPos :=DipRetPos('PROCESSADO',aPerc2)
cVerme2 := TransForm(IIf(nPos>0,aPerc2[nPos,2],0),"@E 999.99")+"%" 
@ nLin+20,nCol+85 JPEG oBmp RESOURCE "br_vermelho" 	SIZE 15,15 OF oDlg PIXEL ON CLICK MsgInfo("PROCESSADO") BORDER CURSOR oCursor
@ nLin+21,nCol+95 SAY cVerme2 SIZE 50,10 PIXEL OF oDlg FONT oFont12n

/* __________________________
|                            |
|    Sem Saldo		 	     |
|____________________________|
*/
nPos :=DipRetPos('SEM SALDO',aPerc2)
cPreto2 := TransForm(IIf(nPos>0,aPerc2[nPos,2],0),"@E 999.99")+"%" 
@ nLin+30,nCol+85 JPEG oBmp RESOURCE "br_preto" 	SIZE 15,15 OF oDlg PIXEL ON CLICK MsgInfo("SEM SALDO") 	BORDER CURSOR oCursor
@ nLin+31,nCol+95 SAY cPreto2 SIZE 50,10 PIXEL OF oDlg FONT oFont12n

/* __________________________
|                            |
|   2 Contagens Batidas      |
|____________________________|
*/
nPos :=DipRetPos('CONT. BAT.',aPerc2)
cRoxo2 := TransForm(IIf(nPos>0,aPerc2[nPos,2],0),"@E 999.99")+"%"
@ nLin+40,nCol+85 JPEG oBmp RESOURCE "br_violeta" 	SIZE 15,15 OF oDlg PIXEL ON CLICK MsgInfo("CONT. BAT.") 	BORDER CURSOR oCursor
@ nLin+41,nCol+95 SAY cRoxo2 SIZE 50,10 PIXEL OF oDlg FONT oFont12n

/* __________________________
|                            |
|   2 Qtd Eleita		     |
|____________________________|
*/
nPos :=DipRetPos('QTD.ELEIT.',aPerc2)
cBranco2 := TransForm(IIf(nPos>0,aPerc2[nPos,2],0),"@E 999.99")+"%"
@ nLin+10,nCol+165 JPEG oBmp RESOURCE "br_branco" SIZE 15,15 OF oDlg PIXEL ON CLICK MsgInfo("QTD.ELEIT.") 	BORDER CURSOR oCursor
@ nLin+11,nCol+175 SAY cBranco2 SIZE 50,10 PIXEL OF oDlg FONT oFont12n

nCol+=221
		
/* __________________________
|                            |
|    Nใo Iniciado	 	     |
|____________________________|
*/
nPos :=DipRetPos('NAO INIC.',aPerc3)
cVerde3 := TransForm(IIf(nPos>0,aPerc3[nPos,2],0),"@E 999.99")+"%"
@ nLin+10,nCol+5  JPEG oBmp RESOURCE "br_verde" 	SIZE 15,15 OF oDlg PIXEL ON CLICK MsgInfo("NAO INIC.") 	BORDER CURSOR oCursor
@ nLin+11,nCol+15 SAY cVerde3 SIZE 50,10 PIXEL OF oDlg FONT oFont12n

/* __________________________
|                            |
|    Em Andamento 	 	     |
|____________________________|
*/
nPos :=DipRetPos('EM ANDAM.',aPerc3)   
cAmare3 := TransForm(IIf(nPos>0,aPerc3[nPos,2],0),"@E 999.99")+"%"
@ nLin+20,nCol+5  JPEG oBmp RESOURCE "br_amarelo" 	SIZE 15,15 OF oDlg PIXEL ON CLICK MsgInfo("EM ANDAM.") 	BORDER CURSOR oCursor
@ nLin+21,nCol+15 SAY cAmare3 SIZE 50,10 PIXEL OF oDlg FONT oFont12n

/* __________________________
|                            |
|    Pausa 				     |
|____________________________|
*/
nPos :=DipRetPos('PAUSA',aPerc3)
cCinza3 := TransForm(IIf(nPos>0,aPerc3[nPos,2],0),"@E 999.99")+"%"
@ nLin+30,nCol+5  JPEG oBmp RESOURCE "br_cinza" 	SIZE 15,15 OF oDlg PIXEL ON CLICK MsgInfo("PAUSA") 		BORDER CURSOR oCursor
@ nLin+31,nCol+15 SAY cCinza3 SIZE 50,10 PIXEL OF oDlg FONT oFont12n

/* __________________________
|                            |
|    Contado		 	     |
|____________________________|
*/
nPos :=DipRetPos('CONTADO',aPerc3)
cLaran3 := TransForm(IIf(nPos>0,aPerc3[nPos,2],0),"@E 999.99")+"%"
@ nLin+40,nCol+5 JPEG oBmp RESOURCE "br_laranja" 	SIZE 15,15 OF oDlg PIXEL ON CLICK MsgInfo("CONTADO") 	BORDER CURSOR oCursor
@ nLin+41,nCol+15 SAY cLaran3 SIZE 50,10 PIXEL OF oDlg FONT oFont12n

/* __________________________
|                            |
|    Finalizado		 	     |
|____________________________|
*/
nPos :=DipRetPos('FINALIZADO',aPerc3)
cAzul3 := TransForm(IIf(nPos>0,aPerc3[nPos,2],0),"@E 999.99")+"%"
@ nLin+10,nCol+85 JPEG oBmp RESOURCE "br_azul" 		SIZE 15,15 OF oDlg PIXEL ON CLICK MsgInfo("FINALIZADO") BORDER CURSOR oCursor
@ nLin+11,nCol+95 SAY cAzul3 SIZE 50,10 PIXEL OF oDlg FONT oFont12n

/* __________________________
|                            |
|    Processado		 	     |
|____________________________|
*/
nPos :=DipRetPos('PROCESSADO',aPerc3)
cVerme3 := TransForm(IIf(nPos>0,aPerc3[nPos,2],0),"@E 999.99")+"%"
@ nLin+20,nCol+85 JPEG oBmp RESOURCE "br_vermelho" 	SIZE 15,15 OF oDlg PIXEL ON CLICK MsgInfo("PROCESSADO") BORDER CURSOR oCursor
@ nLin+21,nCol+95 SAY cVerme3 SIZE 50,10 PIXEL OF oDlg FONT oFont12n

/* __________________________
|                            |
|    Sem Saldo		 	     |
|____________________________|
*/
nPos :=DipRetPos('SEM SALDO',aPerc3)
cPreto3 := TransForm(IIf(nPos>0,aPerc3[nPos,2],0),"@E 999.99")+"%"
@ nLin+30,nCol+85 JPEG oBmp RESOURCE "br_preto" 	SIZE 15,15 OF oDlg PIXEL ON CLICK MsgInfo("SEM SALDO") 	BORDER CURSOR oCursor
@ nLin+31,nCol+95 SAY cPreto3 SIZE 50,10 PIXEL OF oDlg FONT oFont12n
                                                

/* __________________________
|                            |
|   2 Contagens Batidas      |
|____________________________|
*/
nPos :=DipRetPos('CONT. BAT.',aPerc3)
cRoxo3 := TransForm(IIf(nPos>0,aPerc3[nPos,2],0),"@E 999.99")+"%"
@ nLin+40,nCol+85 JPEG oBmp RESOURCE "br_violeta" 	SIZE 15,15 OF oDlg PIXEL ON CLICK MsgInfo("CONT. BAT.") 	BORDER CURSOR oCursor
@ nLin+41,nCol+95 SAY cRoxo3 SIZE 50,10 PIXEL OF oDlg FONT oFont12n

/* __________________________
|                            |
|   2 Qtd Eleita		     |
|____________________________|
*/
nPos :=DipRetPos('QTD.ELEIT.',aPerc2)
cBranco3 := TransForm(IIf(nPos>0,aPerc2[nPos,2],0),"@E 999.99")+"%"
@ nLin+10,nCol+165 JPEG oBmp RESOURCE "br_branco" SIZE 15,15 OF oDlg PIXEL ON CLICK MsgInfo("QTD.ELEIT.") 	BORDER CURSOR oCursor
@ nLin+11,nCol+175 SAY cBranco3 SIZE 50,10 PIXEL OF oDlg FONT oFont12n


oTimer := TTimer():New(30000, {|| FreeObj(oGraphic1),FreeObj(oGraphic2),FreeObj(oGraphic3), oDlg:End(), u_DipGraInv() },  oDlg )
oTimer:Activate()
oDlg:Refresh()

ACTIVATE DIALOG oDlg CENTER

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDIPGRAINV บAutor  ณMicrosiga           บ Data ณ  04/25/14   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function DipRetPos(cTexto,aArray,nPos)  
DEFAULT nPos := 1
Return aScan(aArray,{|x| AllTrim(x[nPos])==AllTrim(cTexto) })
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDIPGRAINV บAutor  ณMicrosiga           บ Data ณ  04/28/14   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function DipAddGr2(nQtd,cSit,aDipGraf2)
Local nPos := 0

If (nPos:=DipRetPos(cSit,aDipGraf2,2))>0
	aDipGraf2[nPos,1] += nQtd
Else
	aAdd(aDipGraf2, {nQtd,cSit})
EndIf                         

Return
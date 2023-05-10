#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณNOVO27    บAutor  ณMicrosiga           บ Data ณ  07/27/15   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function DipCusImp()
Local cPerg 	:= "DIPCUSI"
Private cDoc    := ""
Private cSerie	:= ""
Private cFornec	:= ""
Private cLoja 	:= ""
                   
                   
If U_DipUsr()$GetNewPar("ES_DESPIMP","")                       

	AjustaSX1(cPerg) 

	Pergunte(cPerg,.F.)        

	If SF1->F1_EST = 'EX'
		cDoc     := SF1->F1_DOC
		cSerie	 := SF1->F1_SERIE
		cFornec	 := SF1->F1_FORNECE
		cLoja 	 := SF1->F1_LOJA
		mv_par01 := SF1->F1_DOC
		mv_par02 := SF1->F1_SERIE
		mv_par03 := SF1->F1_FORNECE
		mv_par04 := SF1->F1_LOJA
	
		DipMonTel()	
	Else 
		Aviso("Aten็ใo","Essa rotina s๓ pode ser utilizada para notas de importa็ใo!",{"Ok"},1)
	EndIf
Else                                                                
	Aviso("ES_DESPIMP","Usuแrio sem acesso เ rotina."+CHR(10)+CHR(13)+"Entre em contato com o T.I..",{"Ok"},1)	
EndIf




Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDIPCUSIMP บAutor  ณMicrosiga           บ Data ณ  07/27/15   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function DipMonTel()
Local oDlg                                 
Local aButtons	:= {}
Local bOk 		:= {|| IIf(u_ZZMTudOk(),(u_DipGrvCol(),oDlg:End()),nil)}//{|| IIf(u_ZZMTudOk(),.T.,.F.);oDlg:End() }
Local bCancel 	:= {|| oDlg:End()}
Private oNF
Private oSerie
Private oFornece
Private oLoja
Private oData
Private dDataZZM
Private aHeader	:= {}
Private aCols	:= {}
Private oGetDados    
Private aCpoAlt := {"ZZM_VALCIF","ZZM_VALII","ZZM_VALCUS"}

aObjects := {}

aSize   := MsAdvSize()
aAdd(aObjects, {100, 100, .T., .T.})

aInfo   := {aSize[1], aSize[2], aSize[3], aSize[4], 2, 2}
aPosObj := MsObjSize(aInfo, aObjects)          

DipMHead()      
DipMCols()

DEFINE MSDIALOG oDlg TITLE "Custo de Importa็ใo" From aSize[7],005 TO aSize[6],aSize[5] OF oMainWnd PIXEL    
  
	@ 005,005 SAY "NF" 					 		SIZE 100,008 			OF oDlg PIXEL
	@ 012,005 MSGET oNF 	VAR cDoc     		SIZE 100,010 WHEN .F. 	OF oDlg PIXEL  PICTURE "@E 999999999"

	@ 005,135 SAY "Serie"   	  		  		SIZE 100,008 			OF oDlg PIXEL
	@ 012,135 MSGET oSerie 	VAR cSerie     		SIZE 100,010 WHEN .F. 	OF oDlg PIXEL  PICTURE "@E 999"
	
	@ 005,265 SAY "Fornecedor" 		       		SIZE 100,008 		  	OF oDlg PIXEL
	@ 012,265 MSGET oFornec VAR cFornec  		SIZE 100,010 WHEN .F.	OF oDlg PIXEL  PICTURE "@E 999999"
	
	@ 005,395 SAY "Loja" 	  			 		SIZE 100,008 			OF oDlg PIXEL
	@ 012,395 MSGET oLoja	VAR cLoja    		SIZE 100,010 WHEN .F. 	OF oDlg PIXEL  PICTURE "@E 99"
	                                                                                          
	@ 005,525 SAY "Data Custo" 	  		 		SIZE 100,008 			OF oDlg PIXEL
	@ 012,525 MSGET oData	VAR DtoC(dDataZZM) 	SIZE 100,010 WHEN .F. 	OF oDlg PIXEL  PICTURE "@D"

	oGetDados:=MsNewGetDados():New(aPosObj[1,1]+30,aPosObj[1,2],aPosObj[1,3],aPosObj[1,4],GD_UPDATE,'AllWaysTrue','AllWaysTrue',,aCpoAlt,/*freeze*/,999,'AllWaysTrue',/*superdel*/,/*delok*/,oDlg,@aHeader,@aCols)
	oGetDados:oBrowse:bAdd    := {|| .F. } // Nao Permite a inclusao de Linhas
	oGetDados:oBrowse:bDelete := {|| .F. } // Nao Permite a deletar Linhas
	//aadd(aButtons, {'AVGBOX1',{|| u_DipLegIte()},"Legenda","Legenda"})

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg, bOk, bCancel,,aButtons)								

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDIPCUSIMP บAutor  ณMicrosiga           บ Data ณ  07/28/15   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function DipMHead()
Local nTamanho := 0

dbSelectArea("SX3")
SX3->(dbSetOrder(1))
SX3->(dbSeek("ZZM"))

While !SX3->(Eof()) .And. (x3_arquivo == "ZZM")
	If X3USO(x3_usado) .And. cNivel >= x3_nivel
		If !(AllTrim(x3_campo)$"ZZM_DOC/ZZM_SERIE/ZZM_FORNECE/ZZM_LOJA/ZZM_USUARIO/ZZM_DATA")
			nTamanho := x3_tamanho
			If x3_campo == "ZZM_CODPRO"                                 
				nTamanho := 6
			ElseIf x3_campo == "ZZM_DESPRO"
				nTamanho := 50
			EndIf
			
			AAdd(aHeader,{ TRIM(x3_titulo), x3_campo, x3_picture,;
							nTamanho, x3_decimal, x3_valid,;
							x3_usado, x3_tipo, x3_arquivo, x3_context } )
		EndIf
	EndIf
	dbSkip()
EndDo

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDIPCUSIMP บAutor  ณMicrosiga           บ Data ณ  07/28/15   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function DipMCols()

ZZM->(dbSetOrder(1))
If !ZZM->(dbSeek(xFilial("ZZM")+mv_par01+mv_par02+mv_par03+mv_par04))
	DipGrvZZM()
EndIf

dbSelectArea("ZZM")
ZZM->(dbSetOrder(1))
If ZZM->(dbSeek(xFilial("ZZM")+mv_par01+mv_par02+mv_par03+mv_par04))
	dDataZZM := ZZM->ZZM_DATA
	While !ZZM->(Eof()) .And. ZZM->(ZZM_FILIAL+ZZM_DOC+ZZM_SERIE+ZZM_FORNECE+ZZM_LOJA)==xFilial("ZZM")+mv_par01+mv_par02+mv_par03+mv_par04
		AADD(aCols,Array(Len(aHeader)+1))
		For nI := 1 To Len(aHeader) 
			If ( aHeader[nI,10] != "V" )   
				If aHeader[nI,8] == "C"
					aCols[Len(aCols),nI] := AllTrim(ZZM->(FieldGet(FieldPos(aHeader[nI,2]))))
				Else
					aCols[Len(aCols),nI] := ZZM->(FieldGet(FieldPos(aHeader[nI,2])))
				EndIf
			Else
				aCols[Len(aCols),nI] := CriaVar(aHeader[nI,2])
			EndIf
		Next nI
		aCols[Len(aCols),Len(aHeader)+1] := .F.
		ZZM->(dbSkip())
	EndDo
EndIf

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDIPCUSIMP บAutor  ณMicrosiga           บ Data ณ  07/28/15   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function DipGrvZZM()
Local cSQL := ""

cSQL := " SELECT "
cSQL += " 	D1_FILIAL, D1_ITEM, D1_COD, D1_VUNIT, D1_QUANT, D1_TOTAL, D1_DOC, D1_SERIE, D1_FORNECE, D1_LOJA "
cSQL += " 	FROM "
cSQL +=  		RetSQLName("SD1")
cSQL += " 		WHERE "
cSQL += " 			D1_FILIAL 	= '"+xFilial("SD1")+"' AND "
cSQL += " 			D1_DOC 		= '"+mv_par01+"' AND "
cSQL += " 			D1_SERIE 	= '"+mv_par02+"' AND "
cSQL += " 			D1_FORNECE 	= '"+mv_par03+"' AND "
cSQL += " 			D1_LOJA 	= '"+mv_par04+"' AND "
cSQL += " 			D_E_L_E_T_ 	= ' ' "
cSQL += " 			ORDER BY D1_ITEM "

cSQL := ChangeQuery(cSQL)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),"QRYCUS",.T.,.T.)

TCSETFIELD("QRYCUS","D1_VUNIT","N",16,4)
TCSETFIELD("QRYCUS","D1_QUANT","N",11,0)
TCSETFIELD("QRYCUS","D1_TOTAL","N",16,2)

While !QRYCUS->(Eof())   
	ZZM->(RecLock("ZZM",.T.))
		ZZM->ZZM_FILIAL := xFilial("ZZM")
		ZZM->ZZM_ITEM 	:= QRYCUS->D1_ITEM
		ZZM->ZZM_CODPRO := QRYCUS->D1_COD
		ZZM->ZZM_VALUNI := QRYCUS->D1_VUNIT
		ZZM->ZZM_QUANT  := QRYCUS->D1_QUANT
		ZZM->ZZM_VALTOT := QRYCUS->D1_TOTAL
		ZZM->ZZM_PERCEN := GetNewPar("ES_PERCIMP",70)
		ZZM->ZZM_DOC	:= QRYCUS->D1_DOC
		ZZM->ZZM_SERIE  := QRYCUS->D1_SERIE
		ZZM->ZZM_FORNEC := QRYCUS->D1_FORNECE
		ZZM->ZZM_LOJA   := QRYCUS->D1_LOJA
		ZZM->ZZM_DATA   := dDataBase
		ZZM->ZZM_USUARI := Upper(u_DipUsr())
	ZZM->(MsUnLock())	
	QRYCUS->(dbSkip())
EndDo                
QRYCUS->(dbCloseArea())

Return      
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDIPCUSIMP บAutor  ณMicrosiga           บ Data ณ  07/29/15   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function DipCalCus()
Local nVal 		:= 0                                                    
Local nPosVCif 	:= aScan(aHeader, { |x| Alltrim(x[2]) =="ZZM_VALCIF"}) 
Local nPosVII  	:= aScan(aHeader, { |x| Alltrim(x[2]) =="ZZM_VALII"}) 
Local nPosQtd  	:= aScan(aHeader, { |x| Alltrim(x[2]) =="ZZM_QUANT"}) 
Local nPerImp 	:= GetNewPar("ES_PERCIMP",70)

If aCols[n,nPosVCif]>0 .And.aCols[n,nPosVII]>0
	nVal := aCols[n,nPosVCif]/aCols[n,nPosQtd]
	nVal += ((aCols[n,nPosVCif]/aCols[n,nPosQtd])*nPerImp/100)
	nVal += (aCols[n,nPosVII]/aCols[n,nPosQtd])	
EndIf                        

Return nVal
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDIPCUSIMP บAutor  ณMicrosiga           บ Data ณ  07/29/15   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function ZZMLinOk()
Local nPosVCif 	:= aScan(aHeader, { |x| Alltrim(x[2]) =="ZZM_VALCIF"}) 
Local nPosVII  	:= aScan(aHeader, { |x| Alltrim(x[2]) =="ZZM_VALII"}) 
Local lRet  	:= .F.

If !(lRet:=!Empty(aCols[n,nPosVCif]) .And. !Empty(aCols[n,nPosVII]))
	Aviso("Aten็ใo","Erro na linha "+AllTrim(Str(n))+". Preencha os campos corretamente.",{"Ok"},1)	
EndIf                                                                                                        

Return lRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDIPCUSIMP บAutor  ณMicrosiga           บ Data ณ  07/29/15   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function ZZMTudOk()
Local nPosVCif 	:= aScan(aHeader, { |x| Alltrim(x[2]) =="ZZM_VALCIF"}) 
Local nPosVII  	:= aScan(aHeader, { |x| Alltrim(x[2]) =="ZZM_VALII"}) 
Local nI := 0
Local lRet := .F.     

For nI:=1 to Len(oGetDados:aCols)
	lRet := oGetDados:aCols[nI,nPosVCif]>0 .And. oGetDados:aCols[nI,nPosVII]>0
	If !lRet
		Aviso("Aten็ใo","Erro na linha "+AllTrim(Str(nI))+". Preencha os campos corretamente.",{"Ok"},1)
		Exit
	EndIf	
Next nI

Return lRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDIPCUSIMP บAutor  ณMicrosiga           บ Data ณ  07/31/15   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function DipGrvCol()
Local nPosVCif 	 := aScan(aHeader, { |x| Alltrim(x[2]) =="ZZM_VALCIF"}) 
Local nPosVII  	 := aScan(aHeader, { |x| Alltrim(x[2]) =="ZZM_VALII"}) 
Local nPosVCus 	 := aScan(aHeader, { |x| Alltrim(x[2]) =="ZZM_VALCUS"}) 
Local nPosProd 	 := aScan(aHeader, { |x| Alltrim(x[2]) =="ZZM_CODPRO"}) 
Local nPosItem 	 := aScan(aHeader, { |x| Alltrim(x[2]) =="ZZM_ITEM"}) 
Local cProd      := ""
Local cItem		 := ""
Local nI 		 := 0
Local lRet 		 := .F.     
Local nVCif		 := 0
Local nVII		 := 0
Local nVCus      := 0
Local _cFrom     := "protheus@dipromed.com.br"
Local _cFuncSent := "DipGrvCol(DipCusImp.PRW)"    
Local _cAssunto	 := ""
Local _cEmail	 := ""        
Local _cFiTro    := ""
Local _aMsg		 := {}
    
ZZM->(dbSetOrder(2))
SD1->(dbSetOrder(1))
For nI:=1 to Len(oGetDados:aCols)  

	cProd := PadR(oGetDados:aCols[nI,nPosProd],15)
	cItem := oGetDados:aCols[nI,nPosItem]
	nVCif := oGetDados:aCols[nI,nPosVCif]
	nVII  := oGetDados:aCols[nI,nPosVII]
	nVCus := Round(oGetDados:aCols[nI,nPosVCus],4)
	
	If ZZM->(dbSeek(xFilial("ZZM")+cDoc+cSerie+cFornec+cLoja+cProd+cItem))
		ZZM->(RecLock("ZZM",.F.))
			ZZM->ZZM_VALCIF := nVCif
			ZZM->ZZM_VALII  := nVII
			ZZM->ZZM_VALCUS := nVCus
		ZZM->(MsUnLock())
	EndIf    
	If SD1->(dbSeek(xFilial("SD1")+cDoc+cSerie+cFornec+cLoja+cProd+cItem))    
		SD1->(RecLock("SD1",.F.))
			SD1->D1_CUSDIP  := nVCus
		SD1->(MsUnLock())
		
		SF4->(dbSetOrder(1))
		SF4->(dbSeek(xFilial("SF4")+SD1->D1_TES))
		If SF4->F4_UPRC == 'S'						
			SB1->(dbSetOrder(1))
			If SB1->(dbSeek(xFilial("SB1")+SD1->D1_COD))
				SB1->(RecLock("SB1",.F.))
					SB1->B1_CUSDIP := nVCus
				SB1->(MsUnlock())

				If cFilAnt = "01"
					_cFiTro := "04"				
					If SB1->(DbSeek(_cFiTro+SD1->D1_COD))
						SB1->(RecLock("SB1",.F.))
							SB1->B1_CUSDIP := nVCus
						SB1->(MsUnlock())
					Endif
				ElseIf cFilAnt = "04"
					_cFiTro := "01"
					If SB1->(DbSeek(_cFiTro+SD1->D1_COD))
						SB1->(RecLock("SB1",.F.))
							SB1->B1_CUSDIP := nVCus
						SB1->(MsUnlock())
					Endif
				Endif				
				SB1->(dbSeek(xFilial("SB1")+SD1->D1_COD))
			EndIf
		EndIf                                              
	EndIf                                                  	
Next nI

_cEmail    := GetNewPar("ES_MAILIMP","")
       			
_cAssunto:= EncodeUTF8("Recแlculo do custo de Importa็ใo: " +AllTrim(cDoc)+"-"+AllTrim(cSerie),"cp1252")
Aadd( _aMsg , { "Documento: "       	, AllTrim(cDoc)  } )
Aadd( _aMsg , { "Serie: "  	    	 	, AllTrim(cSerie)} )
Aadd( _aMsg , { "Fornecedor: "	  		, AllTrim(cFornec)+" - "+AllTrim(Posicione("SA2",1,xFilial("SA2")+cFornec+cLoja,"A2_NREDUZ")) } )
Aadd( _aMsg , { "Data/Hora: "           , DtoC(dDataBase)+" - "+SubStr(Time(),1,2)+":"+SubStr(Time(),4,2) } )
Aadd( _aMsg , { "Usuแrio:  "            , U_DipUsr() } )
	
U_UEnvMail(_cEmail,_cAssunto,_aMsg,"",_cFrom,_cFuncSent)       

Aviso("Aten็ใo","Valores atualizados com sucesso.",{"Ok"},1)	

Return lRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณNOVO27    บAutor  ณMicrosiga           บ Data ณ  07/27/15   บฑฑ
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
Local aRegs := {}

dbSelectArea("SX1")
dbSetOrder(1)

aAdd(aRegs,{cPerg,"01","NF.Imp.?","","","mv_ch1","C",9,0,0,"G","","MV_PAR01","","","","","","","","","","","","","","","","","","","","","","","","",'SF102'})
aAdd(aRegs,{cPerg,"02","Serie?  ","","","mv_ch2","C",3,0,0,"G","","MV_PAR02","","","","","","","","","","","","","","","","","","","","","","","","",''})
aAdd(aRegs,{cPerg,"03","Fornec.?","","","mv_ch3","C",6,0,0,"G","","MV_PAR03","","","","","","","","","","","","","","","","","","","","","","","","",''})
aAdd(aRegs,{cPerg,"04","Loja?   ","","","mv_ch4","C",2,0,0,"G","","MV_PAR04","","","","","","","","","","","","","","","","","","","","","","","","",''})

PlsVldPerg(aRegs)       

Return
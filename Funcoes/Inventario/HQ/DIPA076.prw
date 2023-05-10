#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณNOVO7     บAutor  ณMicrosiga           บ Data ณ  07/17/14   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function DIPA076()                                   
Local aCores		:= {}                   
Private cEnd		:= CHR(10)+CHR(13)
Private cCadastro 	:= "Inventแrio HQ"
Private aRotina 	:= { ;
{"Pesquisar"  ,"AxPesqui"   ,0,1,0,NIL},;    
{"Visualiza"  ,"U_D76INC"   ,0,2,0,NIL},;  
{"Incluir"    ,"U_D76INC" 	,0,3,0,NIL},;
{"Altera"     ,"U_D76INC" 	,0,4,0,NIL},;
{"Excluir"    ,"U_D76EXC" 	,0,5,0,NIL},;
{"Legenda"    ,"U_D76LEG" 	,0,7,0,NIL},;
{"Processa"   ,"U_D76PRO" 	,0,7,0,NIL}}

aAdd(aCores , {'ZZQ_STATUS = "0"'		,'BR_VERDE'   } )   
aAdd(aCores , {'ZZQ_STATUS = "1"'		,'BR_AMARELO' } )
aAdd(aCores , {'ZZQ_STATUS = "2"'		,'BR_VERMELHO'} )
aAdd(aCores , {'ZZQ_STATUS = "3"'		,'BR_CINZA'   } )
aAdd(aCores , {'ZZQ_STATUS = "4"'		,'BR_BRANCO'  } )
aAdd(aCores , {'!Empty(DtoS(ZZQ_DATAFI))','BR_PRETO'  } )


U_DIPPROC(ProcName(0),U_DipUsr())

dbSelectArea("ZZQ")
                                      
mBrowse( 6, 1,22,75,"ZZQ",,,,,,aCores,,,,,,,,,10000,{|x| DipRef(x)})

Return            
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDIPA056   บAutor  ณMicrosiga           บ Data ณ  11/19/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                         	              บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function D76INC(cAlias,nReg,nOpcx)
Local _xAlias 		:= GetArea()
Local bCampoSC5		:= { |nCPO| Field(nCPO) }
Local cTitulo		:= OemToAnsi("Digita็ใo Inventแrio HQ")
Local cAliasGetD	:="ZZP"
Local cLinOk		:= "AllwaysTrue()"
Local cTudoOk		:= "u_DIP76TDOK()"
Local cMostra 		:= ""
Local cStatus		:= ""
Local aSize  		:= {}
Local aObjects		:= {}
Local aInfo			:= {}
Local aPosObj		:= {}
Local oDlg
Local nOpca			:= 0
Private aHeader 	:= {}
Private aCols		:= {}

If nOpcx==4 .And. ZZQ->ZZQ_STATUS="0" .And. Upper(u_DipUsr())<>"MCANUTO"
	Aviso("Aten็ใo","Este endere็o jแ estแ confirmado e nใo serแ permitido alterแ-lo",{"Ok"},1)
	Return(.F.)
EndIf

aSize   := MsAdvSize()
aAdd(aObjects, {100, 080, .T., .F.})
aAdd(aObjects, {100, 200, .T., .T.})
aInfo   := {aSize[1], aSize[2], aSize[3], aSize[4], 2, 2}
aPosObj := MsObjSize(aInfo, aObjects)

nUsado:=0
SX3->(dbSetOrder(1))
SX3->(dbSeek("ZZP"))

aHeader:={}      
Aadd(aHeader, {" ","cMostra","@BMP",2,0,".F.","","C","","V","","","","V"})

While !SX3->(Eof()) .And. (SX3->X3_ARQUIVO=="ZZP")	
	If !Upper(u_DipUsr())$GetNewPar("ES_AVALINV","MCANUTO/RBORGES/EMATIAS") .And.;
			SX3->X3_CAMPO$"ZZP_ESTOQU" 
		SX3->(dbSkip())
		Loop		
	EndIf	
	If X3USO(SX3->X3_USADO) .And. cNivel>=SX3->X3_NIVEL		
		nUsado++		
		aAdd(aHeader,{	AllTrim(SX3->X3_TITULO),;
						SX3->X3_CAMPO,;
						SX3->X3_PICTURE,;         
						SX3->X3_TAMANHO,;
						SX3->X3_DECIMAL,;
						SX3->X3_VALID,;
						SX3->X3_USADO,;
						SX3->X3_TIPO,;
						SX3->X3_ARQUIVO,;
						SX3->X3_CONTEXT})
	EndIf
	SX3->(dbSkip())
EndDo                                  

If nOpcx==4 .Or. nOpcx==2
	dbSelectArea("ZZP")
	ZZP->(dbSetOrder(1))
	If ZZP->(dbSeek(xFilial("ZZP")+ZZQ->(ZZQ_LOCAL+ZZQ_LOCALI+DTOS(ZZQ_DATA))))
		While !ZZP->(Eof()).And.ZZP->(ZZP_FILIAL+ZZP_LOCAL+ZZP_LOCALI+DTOS(ZZP_DATA))==ZZQ->(ZZQ_FILIAL+ZZQ_LOCAL+ZZQ_LOCALI+DTOS(ZZQ_DATA))		
			aAdd(aCols,Array(Len(aHeader)+1))
			For nI:=1 to Len(aHeader)                                   
			    If aHeader[nI,2] == "cMostra"
			    	If ZZP->ZZP_STATUS=="1"
			    		aCols[Len(aCols),nI] := "BR_VERDE"
			    	Else 
			    		aCols[Len(aCols),nI] := "BR_VERMELHO"
			    	EndIf
			    Else
					aCols[Len(aCols),nI]:=FieldGet(FieldPos(aHeader[nI,2]))			
				EndIf
			Next
			aCols[Len(aCols),Len(aHeader)+1]:=.F.
			ZZP->(dbSkip())
		EndDo
	EndIf    
EndIf	        
     
RegToMemory("ZZQ",Inclui)             

DEFINE MSDIALOG oDlg TITLE cTitulo From aSize[7],0 to aSize[6],aSize[5] of oMainWnd PIXEL
oEnchoice := MsMget():New(cAlias,nReg,nOpcx,,,,,{aPosObj[1,1],aPosObj[1,2],aPosObj[1,3],aPosObj[1,4]},,3,,,,,,.t.)
oGetDados := MsGetDados():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,3],aPosObj[2,4],nOpcx,cLinOk,cTudoOk,,.T.)
ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg, {|| If(u_Dip76TDOK(),(nOpca := 1, oDlg:End()),nil)},{||oDlg:End()})

If nOpca == 1 .And. (nOpcx==3 .Or. nOpcx==4)
	GrvDad()
EndIf

RestArea(_xAlias)

Return  
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDIPA056   บAutor  ณMicrosiga           บ Data ณ  11/19/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                         	              บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function D76LEG()
Local aLegenda:={}

aAdd(aLegenda, {'BR_VERDE'     ,"Endere็o OK" 				} )  // 2   
aAdd(aLegenda, {'BR_AMARELO'   ,"1บ Contagem Divergente"	} )  // 3
aAdd(aLegenda, {'BR_VERMELHO'  ,"2บ Contagem Divergente" 	} )  // 2   
aAdd(aLegenda, {'BR_CINZA'     ,"1บ Contagem Pausa" 		} )  // 2   
aAdd(aLegenda, {'BR_BRANCO'    ,"2บ Contagem Pausa" 		} )  // 2   
aAdd(aLegenda, {'BR_PRETO'     ,"Processado" 				} )  // 2   

BrwLegenda("Status Inventแrio HQ","Status",aLegenda)

Return       
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDIPA067   บAutor  ณMicrosiga           บ Data ณ  08/14/14   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function DipRef(x)
Local oObjBrow  := GetObjBrow()       

oObjBrow:Refresh()            

Return             
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDIPA067   บAutor  ณMicrosiga           บ Data ณ  08/14/14   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function GrvDad()
Local nI 	:= 1 
Local nPosSta := aScan(aHeader,{|x| Upper(AllTrim(x[2]))=="ZZP_STATUS" })
Local nPosPro := aScan(aHeader,{|x| Upper(AllTrim(x[2]))=="ZZP_PRODUT" })
Local nPosLot := aScan(aHeader,{|x| Upper(AllTrim(x[2]))=="ZZP_LOTECT" })
Local nPosVal := aScan(aHeader,{|x| Upper(AllTrim(x[2]))=="ZZP_DTVALI" })
Local nPosEst := aScan(aHeader,{|x| Upper(AllTrim(x[2]))=="ZZP_ESTOQU" })
Local nPosCo1 := aScan(aHeader,{|x| Upper(AllTrim(x[2]))=="ZZP_CONTA1" })
Local nPosCo2 := aScan(aHeader,{|x| Upper(AllTrim(x[2]))=="ZZP_CONTA2" })
Local nPosQEl := aScan(aHeader,{|x| Upper(AllTrim(x[2]))=="ZZP_QTDELE" })
Local nPosUsu := aScan(aHeader,{|x| Upper(AllTrim(x[2]))=="ZZP_UAUARI" })
Local lFinal  := .F.                     
Local nCont   := 0
Local cCont   := ""         

If Empty(M->ZZQ_STATUS) .Or. M->ZZQ_STATUS == "3" 
	nCont := 1
	cCont := "primeira"
ElseIf M->ZZQ_STATUS == "1" .Or. M->ZZQ_STATUS == "4" 
	nCont := 2         
	cCont := "segunda"
Else                  
	nCont := 3        
	cCont := "terceira"
EndIf

If (Aviso("Aten็ใo","Confirma a finaliza็ใo da "+cCont+" contagem deste endere็o ("+AllTrim(M->ZZQ_LOCALIZ)+")?",{"Sim","Nใo"},1)==1)
	lFinal := .T.
EndIf

If lFinal 
	If nCont==1
		u_Grv76SBF(M->ZZQ_LOCAL,M->ZZQ_LOCALI,M->ZZQ_DATA)
	EndIf
EndIf

For nI:=1 To Len(aCols)                                                         	
	ZZP->(dbSetOrder(2))                                                        
	If ZZP->(dbSeek(xFilial("ZZP")+M->ZZQ_LOCAL+M->ZZQ_LOCALI+aCols[nI,nPosPro]+aCols[nI,nPosLot]+DtoS(M->ZZQ_DATA)))		
	    If aCols[nI,Len(aCols[nI])]
   			ZZP->(RecLock("ZZP",.F.))
   				ZZP->(dbDelete())
   			ZZP->(MsUnLock())    
   			ZZP->(dbSkip())
			Loop
	    EndIf
		
		If ZZP->ZZP_STATUS=="1"
			ZZP->(dbSkip())
			Loop
		EndIf
		ZZP->(RecLock("ZZP",.F.))
			If lFinal   
				Do Case
					Case nCont==1
						If aCols[nI,nPosCo1]==ZZP->ZZP_ESTOQU
							ZZP->ZZP_STATUS := "1"
							ZZP->ZZP_QTDELE := aCols[nI,nPosCo1]
						Else
							ZZP->ZZP_STATUS := "2"
						EndIf
						ZZP->ZZP_CONTA1 := aCols[nI,nPosCo1]
					Case nCont==2
						If aCols[nI,nPosCo2]==ZZP->ZZP_ESTOQU .Or. aCols[nI,nPosCo2]==ZZP->ZZP_CONTA1        
							ZZP->ZZP_STATUS := "1"
							ZZP->ZZP_QTDELE := aCols[nI,nPosCo2]
						Else
							ZZP->ZZP_STATUS := "2"          
						EndIf
						ZZP->ZZP_CONTA2 := aCols[nI,nPosCo2]						
					Case nCont==3                
						ZZP->ZZP_STATUS := "1"
						ZZP->ZZP_QTDELE := aCols[nI,nPosQEl]
				End Case
			Else		
				If nCont==1          				
					ZZP->ZZP_CONTA1 := aCols[nI,nPosCo1]				
				ElseIf nCont==2                         
					ZZP->ZZP_CONTA2 := aCols[nI,nPosCo2]
				Elseif nCont==3
					ZZP->ZZP_QTDELE := aCols[nI,nPosQEl]
				EndIf
			EndIf
			ZZP->ZZP_USUARI := Upper(u_DipUsr())
		ZZP->(MsUnLock()) 
	ElseIf !aCols[nI,Len(aCols[nI])]
		ZZP->(RecLock("ZZP",.T.))
			ZZP->ZZP_FILIAL := xFilial("ZZP")	
			ZZP->ZZP_STATUS := "2"
			ZZP->ZZP_DATA   := M->ZZQ_DATA
			ZZP->ZZP_LOCAL  := M->ZZQ_LOCAL
			ZZP->ZZP_LOCALI := M->ZZQ_LOCALI
			ZZP->ZZP_PRODUT := aCols[nI,nPosPro]
			ZZP->ZZP_LOTECT := aCols[nI,nPosLot]
			ZZP->ZZP_DTVALI := aCols[nI,nPosVal]
			If nCont==1          				
				ZZP->ZZP_CONTA1 := aCols[nI,nPosCo1]				
			ElseIf nCont==2                         
				ZZP->ZZP_CONTA2 := aCols[nI,nPosCo2]
			Elseif nCont==3
				ZZP->ZZP_QTDELE := aCols[nI,nPosQEl]
			EndIf
			ZZP->ZZP_USUARI := u_DipUsr()
		ZZP->(MsUnLock()) 
	EndIf
Next nI

ZZQ->(dbSetOrder(1))
If ZZQ->(dbSeek(xFilial("ZZQ")+M->(ZZQ_LOCAL+ZZQ_LOCALI+DTOS(ZZQ_DATA))))
	ZZQ->(RecLock("ZZQ",.F.))
		If Vld76ZZP(M->ZZQ_LOCAL,M->ZZQ_LOCALI,M->ZZQ_DATA)
			ZZQ->ZZQ_STATUS := "0"
		ElseIf lFinal
			If nCont == 1
				ZZQ->ZZQ_STATUS := "1"
			Else 
				ZZQ->ZZQ_STATUS := "2"
			EndIf
		Else                         
			If nCont==1
				ZZQ->ZZQ_STATUS := "3"
			Else 
				ZZQ->ZZQ_STATUS := "4"
			EndIf
		EndIf
		ZZQ->ZZQ_CODCO1 := M->ZZQ_CODCO1
		ZZQ->ZZQ_NOMCO1 := M->ZZQ_NOMCO1
		ZZQ->ZZQ_CODCO2 := M->ZZQ_CODCO2
		ZZQ->ZZQ_NOMCO2 := M->ZZQ_NOMCO2
	ZZQ->(MsUnLock())
Else
	ZZQ->(RecLock("ZZQ",.T.))
		ZZQ->ZZQ_FILIAL := xFilial("ZZQ") 
		If Vld76ZZP(M->ZZQ_LOCAL,M->ZZQ_LOCALI,M->ZZQ_DATA)
			ZZQ->ZZQ_STATUS := "0"
		ElseIf lFinal
			If nCont == 1
				ZZQ->ZZQ_STATUS := "1"
			Else 
				ZZQ->ZZQ_STATUS := "2"
			EndIf
		Else                         
			If nCont==1
				ZZQ->ZZQ_STATUS := "3"
			Else 
				ZZQ->ZZQ_STATUS := "4"
			EndIf
		EndIf
		ZZQ->ZZQ_LOCAL  := M->ZZQ_LOCAL
		ZZQ->ZZQ_LOCALI := M->ZZQ_LOCALI
		ZZQ->ZZQ_DATA   := M->ZZQ_DATA
		ZZQ->ZZQ_CODCO1 := M->ZZQ_CODCO1
		ZZQ->ZZQ_NOMCO1 := M->ZZQ_NOMCO1
		ZZQ->ZZQ_CODCO2 := M->ZZQ_CODCO2
		ZZQ->ZZQ_NOMCO2 := M->ZZQ_NOMCO2
	ZZQ->(MsUnLock())
EndIf	

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDIPA076   บAutor  ณMicrosiga           บ Data ณ  11/18/15   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function VldZZQLoc()
Local aArea := ZZQ->(GetArea())
Local lRet  := .T.

ZZQ->(dbSetOrder(1))
If ZZQ->(dbSeek(xFilial("ZZQ")+M->ZZQ_LOCAL+M->ZZQ_LOCALI+LEFT(DTOS(M->ZZQ_DATA),6)))
	Aviso("Aten็ใo","Jแ existe registro para este endere็o.",{"Ok"},1)
	lRet := .F.
EndIf

RestArea(aArea)
Return lRet                             
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDIPA076   บAutor  ณMicrosiga           บ Data ณ  11/18/15   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function VldZZPPro()
Local lRet 	  := .T.                                                        
Local cTipo   := ""
Local nPosPro := aScan(aHeader,{|x| Upper(AllTrim(x[2]))=="ZZP_PRODUT" })

lRet := ExistCpo("SB1",M->ZZP_PRODUT)
               
If lRet                                       
	cTipo := Posicione("SB1",1,xFilial("SB1")+M->ZZP_PRODUT,"B1_TIPO")
	If M->ZZQ_LOCAL=="01" .And. cTipo=="MP"   
		Aviso("Aten็ใo","Produto MP nใo pode ser digitado para o Local 01. Verifique os dados.",{"Ok"},1)
		lRet := .F.
	ElseIf M->ZZQ_LOCAL=="05" .And. cTipo=="PA"
		Aviso("Aten็ใo","Produto PA nใo pode ser digitado para o Local 05. Verifique os dados.",{"Ok"},1)
		lRet := .F.
	EndIf
EndIf

Return lRet 
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDIPA076   บAutor  ณMicrosiga           บ Data ณ  11/18/15   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function Grv76SBF(cLocal,cLocaliz,dData)
DEFAULT cLocal 	 := ""
DEFAULT cLocaliz := ""
DEFAULT dData 	 := StoD("")
       
cSQL := " SELECT "
cSQL += "	BF_FILIAL, BF_LOCAL, BF_LOCALIZ, BF_PRODUTO, BF_LOTECTL, BF_QUANT, B8_DTVALID "
cSQL += "	FROM "
cSQL += 		RetSQLName("SBF")+", "+RetSQLName("SB8")
cSQL += "		WHERE "
cSQL += "			BF_FILIAL  = '"+xFilial("SBF")+"' AND "
cSQL += "			BF_LOCAL   = '"+cLocal+"' AND "
cSQL += "			BF_LOCALIZ = '"+cLocaliz+"' AND "
cSQL += "			BF_QUANT   > 0  AND "                      
cSQL += "			BF_FILIAL  = B8_FILIAL AND "
cSQL += "			BF_PRODUTO = B8_PRODUTO AND "
cSQL += "			BF_LOCAL   = B8_LOCAL AND "
cSQL += "			BF_LOTECTL = B8_LOTECTL AND "
cSQl += 			RetSQLName("SBF")+".D_E_L_E_T_ = ' ' AND "
cSQl += 			RetSQLName("SB8")+".D_E_L_E_T_ = ' ' "

cSQL := ChangeQuery(cSQL)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),"QRYSBF",.T.,.T.)

TCSETFIELD("QRYSBF","BF_QUANT"  ,"N",12,4)
TCSETFIELD("QRYSBF","B8_DTVALID","D", 8,0)
    
ZZP->(dbSetOrder(2))
While !QRYSBF->(Eof())
	If ZZP->(dbSeek(xFilial("ZZP")+QRYSBF->(BF_LOCAL+BF_LOCALIZ+BF_PRODUTO+BF_LOTECTL+DtoS(dData))))
		ZZP->(RecLock("ZZP",.F.))
			ZZP->ZZP_ESTOQU := QRYSBF->BF_QUANT 
		ZZP->(MsUnLock()) 
	Else
		ZZP->(RecLock("ZZP",.T.))
			ZZP->ZZP_FILIAL := xFilial("ZZP")	
			ZZP->ZZP_DATA   := dData
			ZZP->ZZP_LOCAL  := cLocal
			ZZP->ZZP_LOCALI := cLocaliz
			ZZP->ZZP_PRODUT := QRYSBF->BF_PRODUTO
			ZZP->ZZP_LOTECT := QRYSBF->BF_LOTECTL
			ZZP->ZZP_DTVALI := QRYSBF->B8_DTVALID
			ZZP->ZZP_ESTOQU := QRYSBF->BF_QUANT
			ZZP->ZZP_USUARI := "## SISTEMA ##"
		ZZP->(MsUnLock()) 	
	EndIf	
	QRYSBF->(dbSkip())
EndDo
QRYSBF->(dbCloseArea())

Return      
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDIPA076   บAutor  ณMicrosiga           บ Data ณ  11/18/15   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function Dip76When(nTipo)
Local lRet := .T.   
Local aArea := ZZP->(GetArea())
Local nPosPro := aScan(aHeader,{|x| Upper(AllTrim(x[2]))=="ZZP_PRODUT" })
Local nPosLot := aScan(aHeader,{|x| Upper(AllTrim(x[2]))=="ZZP_LOTECT" })
DEFAULT nTipo := 0
 
If nTipo == 1
	lRet := If(Inclui,.T.,ZZQ->ZZQ_STATUS=="3")                           
Else
	ZZP->(dbSetOrder(2))                          
	If Inclui
		lRet := .F.
	ElseIf ZZP->(dbSeek(xFilial("ZZP")+ZZQ->ZZQ_LOCAL+ZZQ->ZZQ_LOCALI+aCols[n,nPosPro]+aCols[n,nPosLot]+DtoS(ZZQ->ZZQ_DATA)))                  
		If nTipo == 2
			lRet := (ZZQ->ZZQ_STATUS$"1/4" .AND. ZZP->ZZP_STATUS<>"1")                                   
		ElseIf nTipo == 3
			lRet := (ZZQ->ZZQ_STATUS=="2" .AND. ZZP->ZZP_STATUS<>"1")
		EndIf
	EndIf
EndIf                         

RestArea(aArea)
	
Return lRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDIPA076   บAutor  ณMicrosiga           บ Data ณ  11/18/15   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function D76PRO()
Local cSQL 	  := ""
Local cLogEnd := ""       

If !Upper(u_DipUsr())$GetNewPar("ES_AVALINV","MCANUTO/RBORGES/EMATIAS")
    Aviso("Aten็ใo","Voc๊ nใo tem acesso a esta rotina",{"Ok"},1)
    Return(.F.)
EndIf 

cSQL := " SELECT "
cSQL += "	ZZQ_LOCALI " 
cSQL += " 	FROM "
cSQl += 		RetSQLName("ZZQ")
cSQL += "		WHERE "
cSQL += "			ZZQ_FILIAL = '"+xFilial("ZZQ")+"' AND "
cSQL += "			ZZQ_STATUS <> '0' AND "
cSQL += "			ZZQ_DATAFI = ' ' AND "
cSQl += "			D_E_L_E_T_ = ' ' "

cSQL := ChangeQuery(cSQL)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),"QRYZZQ",.T.,.T.)

If !QRYZZQ->(Eof())   
	Aviso("Aten็ใo","Existem endere็os pendentes no inventแrio. Verifique antes de processar o B7",{"Ok"},1)
	QRYZZQ->(dbCLoseArea())
	Return(.F.)
EndIf
QRYZZQ->(dbCLoseArea())			 				

If Aviso("Aten็ใo","Esta rotina encerrarแ o inventแrio criando registros de acerto na tabela SB7. Deseja continuar?",{"Sim","Nใo"},1)<>1
	Return(.F.)
EndIf  

cSQL := " SELECT "
cSQL += "	MAX(B7_NUMDOC) NUMDOC, MAX(B7_DOC) DOC "
cSQL += "	FROM "
cSQL += 		RetSQLName("SB7")
cSQL += "		WHERE "
cSQL += "			B7_FILIAL = '"+xFilial("SB7")+"' AND "
cSQL += "			LEFT(B7_NUMDOC,6)='INVENT' AND "
cSQL += "			D_E_L_E_T_ = ' ' "

cSQL := ChangeQuery(cSQL)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),"QRYSB7",.T.,.T.)

If !QRYSB7->(Eof())
	cNumDoc := "INVENT001"
	cDoc 	:= "000000001"
Else             
	cNumDoc := Soma1(QRYSB7->NUMDOC)
	cDoc	:= Soma1(QRYSB7->DOC)
EndIf
QRYSB7->(dbCLoseArea())
      
cSQL := " SELECT "
cSQL += "	ZZQ_LOCAL, ZZQ_LOCALI, ZZQ_DATA, R_E_C_N_O_ REC " 
cSQL += " 	FROM "
cSQl += 		RetSQLName("ZZQ")
cSQL += "		WHERE "
cSQL += "			ZZQ_FILIAL = '"+xFilial("ZZQ")+"' AND "
cSQL += "			ZZQ_STATUS = '0' AND "
cSQL += "			ZZQ_DATAFI = ' ' AND "
cSQl += "			D_E_L_E_T_ = ' ' "

cSQL := ChangeQuery(cSQL)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),"QRYZZQ",.T.,.T.)

TCSETFIELD("QRYZZQ","ZZQ_DATA","D", 8,0)                                                        

Begin Transaction      

While !QRYZZQ->(Eof())                     
	ZZP->(dbSetOrder(1))
	If ZZP->(dbSeek(xFilial("ZZP")+QRYZZQ->(ZZQ_LOCAL+ZZQ_LOCALI+DTOS(ZZQ_DATA))))                                    
		While !ZZP->(Eof()) .And. ZZP->(ZZP_FILIAL+ZZP_LOCAL+ZZP_LOCALI+DTOS(ZZP_DATA))==xFilial("ZZP")+QRYZZQ->(ZZQ_LOCAL+ZZQ_LOCALI+DTOS(ZZQ_DATA))
			cDoc 	:= Soma1(cDoc)
			cNumDoc := Soma1(cNumDoc)  			
			SB7->(RecLock("SB7",.T.))
				SB7->B7_FILIAL  := xFilial("SB7")
				SB7->B7_COD     := ZZP->ZZP_PRODUT
				SB7->B7_LOCAL   := ZZP->ZZP_LOCAL
				SB7->B7_TIPO    := Posicione("SB1",1,xFilial("SB1")+ZZP->ZZP_PRODUT,"B1_TIPO")
				SB7->B7_DOC     := cDoc
				SB7->B7_QUANT   := ZZP->ZZP_QTDELE    
				SB7->B7_QTSEGUM := ConvUM(ZZP->ZZP_PRODUT,ZZP->ZZP_QTDELE,0,2)
				SB7->B7_DATA    := ZZP->ZZP_DATA
				SB7->B7_LOTECTL := ZZP->ZZP_LOTECT
				SB7->B7_DTVALID := ZZP->ZZP_DTVALI
				SB7->B7_LOCALIZ := ZZP->ZZP_LOCALI
				SB7->B7_NUMDOC  := cNumDoc 
				SB7->B7_STATUS  := "1"
			SB7->(MsUnlock())
			SB7->(DbCommit())
			ZZP->(dbSkip())
		EndDo
	Else 
		cLogEnd += "Endere็o: "+QRYZZQ->(ZZQ_LOCAL+"-"+ZZQ_LOCALI+"-"+DTOC(ZZQ_DATA))+" nใo processado. "+CHR(13)+CHR(10)
	EndIf
	ZZQ->(dbGoTo(QRYZZQ->REC))
	ZZQ->(RecLock("ZZQ",.F.))
		ZZQ->ZZQ_STATUS := "5"
		ZZQ->ZZQ_DATAFI := dDataBase
	ZZQ->(MsUnLock())
	QRYZZQ->(dbSkip())
EndDo            
QRYZZQ->(dbCloseArea())

If !Empty(cLogEnd)
	Aviso("Aten็ใo","Alguns Endere็os nใo foram processados:"+CHR(13)+CHR(10)+cLogEnd,{"Ok"},3)
	Conout(cLogEnd)
EndIf

End Transaction

Aviso("Fim","Inventแrio finalizado com sucesso. Confira os dados gerados na tabela SB7",{"Ok"},1)

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDIPA076   บAutor  ณMicrosiga           บ Data ณ  11/18/15   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Vld76ZZP(cLocal,cLocali,dData)
Local aArea := GetArea()
Local cSQL := ""
Local lRet := .F.                            
DEFAULT cLocal 	:= ""
DEFAULT cLocali := ""
DEFAULT dData 	:= StoD("")

cSQL := " SELECT "
cSQL += "	ZZP_LOCALI " 
cSQL += "	FROM "
cSQL += 		RetSQLName("ZZP")
cSQL += "		WHERE "
cSQL += "			ZZP_FILIAL 	= '"+xFilial("ZZP")+"' AND "
cSQL += "			ZZP_LOCAL 	= '"+cLocal+"' AND "
cSQL += "			ZZP_LOCALI 	= '"+cLocali+"' AND "
cSQL += "			ZZP_DATA 	= '"+DtoS(dData)+"' AND "
cSQL += "			ZZP_STATUS 	<> '1' AND "
cSQL += " 			D_E_L_E_T_ 	= ' ' "

cSQL := ChangeQuery(cSQL)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),"QRYZZP",.T.,.T.)

lRet := QRYZZP->(Eof())      
QRYZZP->(dbCloseArea())           

RestArea(aArea)                        

Return lRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDIPA076   บAutor  ณMicrosiga           บ Data ณ  11/19/15   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function D76EXC()
Local aArea := GetArea()

If !Upper(u_DipUsr())$GetNewPar("ES_AVALINV","MCANUTO/RBORGES/EMATIAS")
    Aviso("Aten็ใo","Voc๊ nใo tem acesso a esta rotina",{"Ok"},1)
    Return(.F.)
EndIf 

If !Empty(DTOS(ZZQ->ZZQ_DATAFI))
	Aviso("Aten็ใo","Endere็o jแ processado. Nใo pode ser excluํdo.",{"Ok"},1)
	Return(.F.)
EndIf
             
If Aviso("Aten็ใo","Tem certeza que deseja excluir o registro ("+AllTrim(ZZQ_LOCALI)+").",{"Sim","Nใo"},1)==1
	ZZP->(dbSetOrder(1))
	If ZZP->(dbSeek(xFilial("ZZP")+ZZQ->(ZZQ_LOCAL+ZZQ_LOCALI+DTOS(ZZQ_DATA))))
		While !ZZP->(Eof()) .And. ZZP->(ZZP_FILIAL+ZZP_LOCAL+ZZP_LOCALI+DTOS(ZZP_DATA))==xFilial("ZZP")+ZZQ->(ZZQ_LOCAL+ZZQ_LOCALI+DTOS(ZZQ_DATA))
			ZZP->(RecLock("ZZP",.F.))
				ZZP->(dbDelete())
			ZZP->(MsUnLock())
			ZZP->(dbSkip())
		EndDo                    
	EndIf	       
	ZZQ->(RecLock("ZZQ",.F.))
		ZZQ->(dbDelete())
	ZZQ->(MsUnLock())   	
EndIf

RestArea(aArea)

Return   
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDIPA076   บAutor  ณMicrosiga           บ Data ณ  11/20/15   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function DIP76TDOK()
Local nPosPro := aScan(aHeader,{|x| Upper(AllTrim(x[2]))=="ZZP_PRODUT" })
Local lRet := .T.

For nI := 1 to Len(aCols)
	lRet := !Empty(aCols[nI,nPosPro]) .Or. aCols[nI,Len(aHeader)+1]
	If !lRet  
		Aviso("Aten็ใo","Preencha o c๓digo do produto."`,{"Ok"},1)
		Exit
	EndIf
Next nI                                 

Return lRet
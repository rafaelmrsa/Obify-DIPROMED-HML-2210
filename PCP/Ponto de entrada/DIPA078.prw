#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณNOVO42    บAutor  ณMicrosiga           บ Data ณ  09/23/16   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function DIPA078()     
Local aArea		 := GetArea()
Local cCadastro  := ""
Local cTRB 		 := ""
Local cIndTRB	 := ""
Local oTempTable
PRIVATE cMarca	 := ""
PRIVATE aStrut 	 := {}
PRIVATE aRotina  := {{ "Confirmar"	,"u_DipReqSC2()", 0 , 2}}
PRIVATE ALTERA 	 := .T.
PRIVATE INCLUI 	 := .F.

//dbSelectArea("SD3")          

U_DIPPROC(ProcName(0),U_DipUsr())

cCadastro := "Requisi็ใo de Produtos - PCP"

AADD(aStrut,{"C2_OK"		,"C",2 }) 
AADD(aStrut,{"C2_NUM"		,"C",6 })
AADD(aStrut,{"C2_ITEM"		,"C",2 })
AADD(aStrut,{"C2_SEQUEN"	,"C",3 })
AADD(aStrut,{"C2_PRODUTO"	,"C",15})
AADD(aStrut,{"C2_DESCRI"	,"C",50})
AADD(aStrut,{"C2_QUANT"		,"N",11,2})
AADD(aStrut,{"C2_RECNO"		,"N",10})

/*
// cria a tabela temporแria              
cTRB := CriaTrab(aStrut, .T.)
dbUseArea(.T.,,cTRB,"TRBSC2")
*/

If(oTempTable <> NIL)
	oTempTable:Delete()
	oTempTable := NIL
EndIf
oTempTable := FWTemporaryTable():New("TRBSC2")
oTempTable:SetFields( aStrut )
oTempTable:AddIndex("1", {"C2_NUM", "C2_ITEM","C2_SEQUEN","C2_PRODUTO"} )
oTempTable:Create()

//DbSelectArea("TRBSC2")
//TRBSC2->(DbSetOrder(1))


aCampos  := {}     	    
AADD(aCampos,{"C2_OK"     , "" ,"" 			 , }) 
AADD(aCampos,{"C2_NUM"     , "" ,"OP"    	 , })
AADD(aCampos,{"C2_ITEM"   , "" ,"Item" 		 , })
AADD(aCampos,{"C2_SEQUEN" , "" ,"Sequen" 	 , })
AADD(aCampos,{"C2_PRODUTO", "" ,"Produto" 	 , })
AADD(aCampos,{"C2_DESCRI" , "" ,"Descri็ใo"	 , AvSx3("B1_DESC",6)  })
AADD(aCampos,{"C2_QUANT"  , "" ,"Quantidade" , AvSx3("C2_QUANT",6) })

If DipMonSC2()             
	dbSelectArea("TRBSC2")
	TRBSC2->(dbGoTop())
	
	/*
	cIndTRB := CriaTrab(Nil,.F.)
	
	TRBSC2->(DbCreateIndex(cIndTRB,"C2_NUM+C2_ITEM+C2_SEQUEN+C2_PRODUTO",{|| C2_NUM+C2_ITEM+C2_SEQUEN+C2_PRODUTO },.F.))
	TRBSC2->(DbClearInd())
	TRBSC2->(DbSetIndex(cIndTRB))
	*/
	TRBSC2->(DbSetOrder(1))
	 
	cMarca := GetMark()
	MarkBrow("TRBSC2","C2_OK",,aCampos,,cMarca,"U_DipMarSC2()")	
EndIf	                     

TRBSC2->(dbCloseArea())
oTempTable:Delete()
RestArea(aArea)        
                       
Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDIPA078   บAutor  ณMicrosiga           บ Data ณ  09/26/16   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function DipMonSC2()          
Local cSQL := ""
Local lRet := .T.

cSQL := " SELECT "
cSQL += "	C2_NUM, C2_ITEM, C2_SEQUEN, C2_PRODUTO, B1_DESC, C2_QUANT, "+RetSQLName("SC2")+".R_E_C_N_O_ "
cSQL += "	FROM "
cSQL += 		RetSQLName("SC2")     
cSQL += " 		INNER JOIN "
cSQL += 			RetSQLName("SB1")
cSQL += "			ON "
cSQL += "				B1_FILIAL = C2_FILIAL AND "
cSQL += "				B1_COD = C2_PRODUTO AND "
cSQL += 				RetSQLName("SB1")+".D_E_L_E_T_ = ' ' "
cSQL += "		WHERE "
cSQL += "			C2_FILIAL = '"+xFilial("SC2")+"' AND "
cSQL += "			C2_QUANT > 0 AND "
cSQL += "			C2_TPOP = 'P' AND "
cSQL += "			C2_SEQPAI = ' ' AND "
cSQL += "			C2_XCODREQ = ' ' AND "
cSQL += 			RetSQLName("SC2")+".D_E_L_E_T_ = ' ' "
cSQL += " ORDER BY C2_NUM, C2_ITEM, C2_SEQUEN, C2_PRODUTO "            

cSQL := ChangeQuery(cSQL)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),"QRYSC2",.T.,.T.)

TCSETFIELD("QRYSC2","D4_QUANT","N",11,2)
                                                           
If !QRYSC2->(Eof())
	While !QRYSC2->(Eof())
	
		TRBSC2->(RecLock("TRBSC2",.T.))
			TRBSC2->C2_OK 	  := ""
			TRBSC2->C2_NUM 	  := QRYSC2->C2_NUM
			TRBSC2->C2_ITEM	  := QRYSC2->C2_ITEM
			TRBSC2->C2_SEQUEN := QRYSC2->C2_SEQUEN
			TRBSC2->C2_PRODUTO:= QRYSC2->C2_PRODUTO
			TRBSC2->C2_DESCRI := QRYSC2->B1_DESC
			TRBSC2->C2_QUANT  := QRYSC2->C2_QUANT
			TRBSC2->C2_RECNO  := QRYSC2->R_E_C_N_O_
		TRBSC2->(MsUnLock())
		
   		QRYSC2->(dbSkip())
	EndDo
Else 
	Aviso("Aten็ใo","Nใo existem OP's PREVISTAS para requisitar material",{"Ok"})
	lRet := .F.
EndIf              
QRYSC2->(dbCloseArea())

Return lRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDIPA078   บAutor  ณMicrosiga           บ Data ณ  09/23/16   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function DipMarSC2()
Local oMark := GetMarkBrow()

TRBSC2->(DbGotop())

While !TRBSC2->(Eof())
	TRBSC2->(RecLock("TRBSC2",.F.))
		TRBSC2->C2_OK := IIf(Empty(TRBSC2->C2_OK),cMarca,"")
	TRBSC2->(MsUnLock())
	TRBSC2->(dbSkip())
Enddo

MarkBRefresh()      
oMark:oBrowse:Gotop()

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDIPA078   บAutor  ณMicrosiga           บ Data ณ  09/26/16   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function DipReqSC2()
Local aRetSG1 := {}  
Local aItens  := {}  
Local cCodOp  := ""   
Local nCount  := 0                                            
Local nQtdReq := 0
Local nReqMat := ""                        
Local aRecno  := {}     
Local cMsgCic := ""                                                      
Local cMsgMail:= ""   
Local cMComSld:= ""
Local cMSemSld:= ""
Local cAssunto:= EncodeUTF8("REQUISIวรO PARCIAL - ","cp1252")
Local cFrom   := "protheus@dipromed.com.br"
Local cEmail  := GetNewPar("ES_MAIL078","diego.domingos@dipromed.com.br")
Local cHora   := SubStr(Time(),1,2)+":"+SubStr(Time(),4,2)

Private aMSemSld := {}
Private aMComSld := {}

//______________________________
//                              |
//  aRetSG1[1] - PRODUTO        |
//  aRetSG1[2] - QUANTIDADE     |
//  aRetSG1[3] - REQUISICAO?    |
//  aRetSG1[4] - LOCAL PADRAO   |
//  aRetSG1[5] - FLAG CONTROLE  |
//  aRetSG1[6] - UM  		    |
//  aRetSG1[7] - SEGUNDA UM     |
//______________________________|
	    
	
TRBSC2->(dbGotop())
While !TRBSC2->(Eof())
	If !Empty(TRBSC2->C2_OK)	
		aRetSG1 := DipRetSG1(TRBSC2->C2_PRODUTO)
		For nI:=1 to Len(aRetSG1)
			If Left(aRetSG1[nI,1],4)=="SERV"
				Loop
			EndIf		
			If aRetSG1[nI,3] 
				aRetSG1[nI,2] := aRetSG1[nI,2]*TRBSC2->C2_QUANT				
				If (nPos:=aScan(aItens,{|x| x[1]==aRetSG1[nI,1]}))==0
					aAdd(aItens,aRetSG1[nI])
				Else
					aItens[nPos,2] += aRetSG1[nI,2]				
				EndIf
			EndIf
		Next nI
		aAdd(aRecno,TRBSC2->C2_RECNO)
	EndIf
	TRBSC2->(dbSkip())
EndDo
		
For nI := 1 to Len(aItens)									
	
	nQtdZZ9 := DipSld099(aItens[nI,1],aItens[nI,2])
	
	If nQtdZZ9 > 0
		If Empty(nReqMat)
			nReqMat := GetSx8Num('ZZ8','ZZ8_REQMAT')
			ConfirmSX8()
			
			ZZ8->(RecLock("ZZ8",.T.))
			ZZ8->ZZ8_STATUS := 0
			ZZ8->ZZ8_FILIAL := xFilial("ZZ8")
			ZZ8->ZZ8_REQMAT := nReqMat
			ZZ8->ZZ8_ORDPRO := "PCP_AT"
			ZZ8->ZZ8_USUARI := Upper(u_DipUsr())
			ZZ8->ZZ8_DATA   := dDataBase
			ZZ8->ZZ8_HRINCL := cHora			
			ZZ8->(MsUnLock())
		EndIf
		
		ZZ9->(RecLock("ZZ9",.T.))
		ZZ9->ZZ9_FILIAL := xFilial("ZZ9")
		ZZ9->ZZ9_REQMAT := nReqMat
		ZZ9->ZZ9_SEQUEN := StrZero(nI,3)
		ZZ9->ZZ9_CODPRO := aItens[nI,1]
		ZZ9->ZZ9_QTDPRO := nQtdZZ9
		ZZ9->ZZ9_UNDPRO := aItens[nI,6]
		ZZ9->ZZ9_QTDPR2 := ConvUm(aItens[nI,1],nQtdZZ9,0,2 )
		ZZ9->ZZ9_UNDPR2 := aItens[nI,7]
		ZZ9->ZZ9_LOCAL  := aItens[nI,4]
		ZZ9->(MsUnLock())
	EndIf
Next nI 

If Empty(nReqMat)
	Aviso("Aten็ใo","Os produtos desta OP jแ estใo disponํveis no armaz้m 99. Nใo serแ necessแrio incluir a requisi็ใo de materiais.",{"Ok"})
	For nI:=1 to Len(aRecno)
		SC2->(dbGoTo(aRecno[nI]))
		SC2->(RecLock("SC2",.F.))
			SC2->C2_XCODREQ := "ESTQOK"
		SC2->(MsUnLock())
	Next nI
Else	       
	For nI:=1 to Len(aMComSld)
		If nI==1
			cMsgCic := "Produtos requisitados parcialmente: "+CHR(13)+CHR(10)
		EndIf
		cMsgCic 	+= "Produto "+AllTrim(aMComSld[nI,1])+" possui apenas "+cValToChar(aMComSld[nI,2])+" em estoque."+CHR(13)+CHR(10)
		cMComSld 	+= "<br/>Produto "+AllTrim(aMComSld[nI,1])+" possui apenas "+cValToChar(aMComSld[nI,2])+" em estoque."
	Next nI
	
	If Len(aMSemSld)>0
		cMsgCic 	+= "............................................................................"+CHR(13)+CHR(10)
		cMComSld 	+= "<br/>............................................................................<br/>"
	EndIf
	
	For nI:=1 to Len(aMSemSld)
		If nI==1
			cMsgCic +="Produtos nใo requisitados: "+CHR(13)+CHR(10)
		EndIf
		cMsgCic 	+= "Produto "+AllTrim(aMSemSld[nI,1])+" sem saldo em estoque."+CHR(13)+CHR(10)
		cMSemSld 	+= "<br/>Produto "+AllTrim(aMSemSld[nI,1])+" sem saldo em estoque."
	Next nI
	  
	If Len(aMSemSld)>0 .Or. Len(aMComSld)>0                       
	          
		Aviso("Aten็ใo",cMsgCic,{"Ok"},3)                         
	
		If (Aviso("Aten็ใo","Requisi็ใo "+nReqMat+" gerada parcialmente. "+CHR(13)+CHR(10)+CHR(13)+CHR(10)+;
							"Clique em CONTINUAR para gerar a requisi็ใo e REMOVER a OP da lista de sele็ใo."+CHR(13)+CHR(10)+CHR(13)+CHR(10)+;
							"OU"+CHR(13)+CHR(10)+CHR(13)+CHR(10)+;
							"Clique em FECHAR para gerar a requisi็ใo e MANTER a OP na lista de sele็ใo.",{"CONTINUAR","FECHAR"},3)==1)			

			For nI:=1 to Len(aRecno)
				SC2->(dbGoTo(aRecno[nI]))
				SC2->(RecLock("SC2",.F.))
					SC2->C2_XCODREQ := nReqMat
				SC2->(MsUnLock())
			Next nI              
		EndIf              
	Else
		Aviso("Aten็ใo","Requisi็ใo "+nReqMat+" gerada com sucesso.",{"Ok"})
		For nI:=1 to Len(aRecno)
			SC2->(dbGoTo(aRecno[nI]))
			SC2->(RecLock("SC2",.F.))
				SC2->C2_XCODREQ := nReqMat
			SC2->(MsUnLock())
		Next nI              	
	EndIf		
EndIf

If !Empty(cMsgCic)
	cMsgCic += CHR(13)+CHR(10)+"Usuแrio: "+AllTrim(U_DipUsr())
	U_DIPCIC("Requisi็ใo: "+nReqMat+CHR(13)+CHR(10)+CHR(13)+CHR(10)+cMsgCic,GetNewPar("ES_CICD078","DIEGO.DOMINGOS"))
	
	cMsgMail := "<html>"
	cMsgMail += " 	<head>"
	cMsgMail += " 	    <title>Requisi็ใo: "+nReqMat+"</title>"
	cMsgMail += " 	</head>"
	cMsgMail += " 	<body>"
	cMsgMail += " 	    <h2>Requisi็ใo: "+nReqMat+"</h2>"
	If Len(aMComSld)>0   		
		cMsgMail += "	<strong>Produtos requisitados parcialmente:</strong>"
		cMsgMail += cMComSld
	EndIf	
	If Len(aMSemSld)>0   	
		cMsgMail += "	<strong>Produtos nใo requisitados:</strong>"
		cMsgMail += cMSemSld
	EndIf
	cMsgMail += "		<br/>"
	cMsgMail += "		<br/>"
	cMsgMail += "		<strong>Usuแrio: "+AllTrim(U_DipUsr())+"</strong>"
	cMsgMail += "	</body>"
	cMsgMail += "</html>"
                                        
	cAssunto += nReqMat
	
	u_UEnvMail(cEmail,cAssunto,nil,"",cFrom,"DipReqSC2(DIPA078.PRW)",cMsgMail)						
EndIf                    

CloseBrowse()

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDIPA060   บAutor  ณMicrosiga           บ Data ณ  09/29/16   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function DipRetSG1(cProduto)
Local lProcura := .T.             
Local aItens   := {}
Local nI       := 0

//______________________________
//                              |
//  aItens[1] - PRODUTO         |
//  aItens[2] - QUANTIDADE      |
//  aItens[3] - REQUISICAO?     |
//  aItens[4] - LOCAL PADRAO    |
//  aItens[5] - FLAG CONTROLE   |
//  aItens[6] - UM  		    |
//  aItens[7] - SEGUNDA UM      |
//______________________________|


SG1->(dbSetOrder(1))
If SG1->(dbSeek(xFilial("SG1")+cProduto)) 	
	While SG1->G1_COD == cProduto         
		SB1->(dbSetOrder(1))
		If SB1->(dbSeek(xFilial("SB1")+SG1->G1_COMP))
			aAdd(aItens,{SG1->G1_COMP,SG1->G1_QUANT,.T.,SB1->B1_LOCPAD,.T.,SB1->B1_UM,SB1->B1_SEGUM}) 			
		EndIf                                                                         
		SG1->(dbSkip())
	EndDo	
			
	While lProcura
		lProcura := .F.
		For nI:=1 to Len(aItens)
			If aItens[nI,5] 
				If SG1->(dbSeek(xFilial("SG1")+aItens[nI,1]))
					While SG1->G1_COD == aItens[nI,1]
						SB1->(dbSetOrder(1))
						If SB1->(dbSeek(xFilial("SB1")+SG1->G1_COMP))
							aAdd(aItens,{SG1->G1_COMP,SG1->G1_QUANT,.T.,SB1->B1_LOCPAD,.T.,SB1->B1_UM,SB1->B1_SEGUM}) 
						EndIf   
						aItens[nI,3] := .F.
						SG1->(dbSkip())
					EndDo	
					lProcura := .T.
				EndIf    		   
				aItens[nI,5] := .F.		
			EndIf
		Next nI   
		SG1->(dbSkip())
	EndDo
	
EndIf

Return aItens
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDIPA078   บAutor  ณMicrosiga           บ Data ณ  05/04/17   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function DipSld099(cProduto,nQuant)
Local cSQL 		 := ""                         
DEFAULT cProduto := ""
DEFAULT nQuant   := ""     

cSQL := " SELECT "
cSQL += " 	B2_QATU-(B2_QACLASS+B2_RESERVA+B2_QEMP) QUANT "
cSQL += " 	FROM "
cSQL +=  		RetSQLName("SB2")
cSQL += " 		WHERE "
cSQL += " 			B2_FILIAL  = '"+xFilial("SB2")+"' AND "
cSQL += " 			B2_COD 	   = '"+cProduto+"' AND "
cSQL += " 			B2_LOCAL   = '99' AND "
cSQL += " 			D_E_L_E_T_ = ' ' "

cSQL := ChangeQuery(cSQL)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),"QRY099",.T.,.T.)

If QRY099->QUANT >= nQuant //Tenho quantidade em estoque
	nQuant := 0
ElseIf QRY099->QUANT > 0
	nQuant := nQuant-QRY099->QUANT   
EndIf                      
QRY099->(dbCloseArea())

If nQuant > 0
	nQuant := DipRetEmb(cProduto,nQuant)
EndIf

cSQL := " SELECT "
cSQL += " 	SUM(B2_QATU-(B2_QACLASS+B2_RESERVA+B2_QEMP)) QUANT "
cSQL += " 	FROM "
cSQL +=  		RetSQLName("SB2")
cSQL += " 		WHERE "
cSQL += " 			B2_FILIAL IN('01','02') AND "
cSQL += " 			B2_COD 	   = '"+cProduto+"' AND "
cSQL += " 			B2_LOCAL   = '01' AND "
cSQL += " 			D_E_L_E_T_ = ' ' "

cSQL := ChangeQuery(cSQL)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),"QRY001",.T.,.T.)

If QRY001->QUANT < nQuant //Tenho quantidade em estoque
	nQuant := QRY001->QUANT                                                    
	If nQuant > 0                                                                                                         
		aAdd(aMComSld,{cProduto,nQuant})
	Else 
		aAdd(aMSemSld,{cProduto})
	EndIf
EndIf                      
QRY001->(dbCloseArea())

Return nQuant
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDIPA078   บAutor  ณMicrosiga           บ Data ณ  05/04/17   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function DipRetEmb(cProduto,nQuant)     
Local aAreaSB1 	 := SB1->(GetArea())    
Local nQtdCxEmb  := 0                 
Local nQtdAux    := 0
DEFAULT cProduto := ""
DEFAULT nQuant   := 0
                                             
SB1->(dbSetOrder(1))
If SB1->(dbSeek(xFilial("SB1")+cProduto))	                                

	nQtdCxEmb := 1	   
	
	If SB1->B1_XTPEMBV == "1"
		If SB1->B1_XQTDEMB > 0
			nQtdCxEmb := SB1->B1_XQTDEMB  
		EndIf
	ElseIf SB1->B1_XTPEMBV == "2"         
		If SB1->B1_XQTDSEC > 0
			nQtdCxEmb := SB1->B1_XQTDSEC
		EndIf	
	EndIf	 
				
	nQtdAux := nQuant/nQtdCxEmb
	
	If nQtdAux > 0
		If Mod(nQuant,nQtdCxEmb)==0
			nQuant := nQtdCxEmb*nQtdAux
		Else   
			nQuant := (nQtdCxEmb*Int(nQtdAux))+nQtdCxEmb
		EndIf
	Else 
		nQuant := nQtdCxEmb
	EndIf             
	
Else 
	Aviso("DIPA071","Produto nใo encontrado. Avise o T.I.",{"Ok"},1)
	lRet := .F.
EndIf            

RestArea(aAreaSB1)    

Return nQuant

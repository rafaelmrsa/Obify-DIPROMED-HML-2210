#INCLUDE "PROTHEUS.CH"
#INCLUDE 'RWMAKE.CH'
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DIPR095 ºAutor  ³Microsiga           º Data ³  08/10/15   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function DIPR095()
Local aArea		 := GetArea()
Local cCadastro  := ""
Local cTRB 		 := ""
Local cIndTRB	 := ""
PRIVATE cMarca	 := ""
PRIVATE aStrut 	 := {}
PRIVATE aRotina  := {{ "Imprimir"	,"u_DipImpSC2()", 0 , 2}}
PRIVATE ALTERA 	 := .T.
PRIVATE INCLUI 	 := .F.

//dbSelectArea("SD3")          

U_DIPPROC(ProcName(0),U_DipUsr())

cCadastro := "Relação de PI"

AADD(aStrut,{"C2_OK"		,"C",2 }) 
AADD(aStrut,{"C2_NUM"		,"C",6 })
AADD(aStrut,{"C2_ITEM"		,"C",2 })
AADD(aStrut,{"C2_SEQUEN"	,"C",3 })
AADD(aStrut,{"C2_PRODUTO"	,"C",15})
AADD(aStrut,{"C2_DESCRI"	,"C",50})
AADD(aStrut,{"C2_QUANT"		,"N",11,2})
AADD(aStrut,{"C2_RECNO"		,"N",10})

// cria a tabela temporária              
cTRB := CriaTrab(aStrut, .T.)
dbUseArea(.T.,,cTRB,"TRB095")

aCampos  := {}     	    
AADD(aCampos,{"C2_OK"     , "" ,"" 			 , }) 
AADD(aCampos,{"C2_NUM"     , "" ,"OP"    	 , })
AADD(aCampos,{"C2_ITEM"   , "" ,"Item" 		 , })
AADD(aCampos,{"C2_SEQUEN" , "" ,"Sequen" 	 , })
AADD(aCampos,{"C2_PRODUTO", "" ,"Produto" 	 , })
AADD(aCampos,{"C2_DESCRI" , "" ,"Descrição"	 , AvSx3("B1_DESC",6)  })
AADD(aCampos,{"C2_QUANT"  , "" ,"Quantidade" , AvSx3("C2_QUANT",6) })

If DipMonSC2()             
	dbSelectArea("TRB095")
	TRB095->(dbGoTop())
	
	cIndTRB := CriaTrab(Nil,.F.)
	
	TRB095->(DbCreateIndex(cIndTRB,"C2_NUM+C2_ITEM+C2_SEQUEN+C2_PRODUTO",{|| C2_NUM+C2_ITEM+C2_SEQUEN+C2_PRODUTO },.F.))
	TRB095->(DbClearInd())
	TRB095->(DbSetIndex(cIndTRB))
	TRB095->(DbSetOrder(1))
	 
	cMarca := GetMark()
	MarkBrow("TRB095","C2_OK",,aCampos,,cMarca,"U_DipMkSC2()")	
EndIf	                     

TRB095->(dbCloseArea()) 
RestArea(aArea)        
                       
Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DIPR095   ºAutor  ³Microsiga           º Data ³  09/26/16   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
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
cSQL += "			LEFT(C2_PRODUTO,1) = '2' AND "
cSQL += 			RetSQLName("SC2")+".D_E_L_E_T_ = ' ' "
cSQL += " ORDER BY C2_NUM, C2_ITEM, C2_SEQUEN, C2_PRODUTO "            

cSQL := ChangeQuery(cSQL)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),"QRYSC2",.T.,.T.)

TCSETFIELD("QRYSC2","D4_QUANT","N",11,2)
                                                           
If !QRYSC2->(Eof())
	While !QRYSC2->(Eof())
	
		TRB095->(RecLock("TRB095",.T.))
			TRB095->C2_OK 	  := ""
			TRB095->C2_NUM 	  := QRYSC2->C2_NUM
			TRB095->C2_ITEM	  := QRYSC2->C2_ITEM
			TRB095->C2_SEQUEN := QRYSC2->C2_SEQUEN
			TRB095->C2_PRODUTO:= QRYSC2->C2_PRODUTO
			TRB095->C2_DESCRI := QRYSC2->B1_DESC
			TRB095->C2_QUANT  := QRYSC2->C2_QUANT
			TRB095->C2_RECNO  := QRYSC2->R_E_C_N_O_
		TRB095->(MsUnLock())
		
   		QRYSC2->(dbSkip())
	EndDo
Else 
	Aviso("Atenção","Não existem OP's PREVISTAS para impressão",{"Ok"})
	lRet := .F.
EndIf              
QRYSC2->(dbCloseArea())

Return lRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DIPR095   ºAutor  ³Microsiga           º Data ³  09/23/16   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function DipMkSC2()
Local oMark := GetMarkBrow()

TRB095->(DbGotop())

While !TRB095->(Eof())
	TRB095->(RecLock("TRB095",.F.))
		TRB095->C2_OK := IIf(Empty(TRB095->C2_OK),cMarca,"")
	TRB095->(MsUnLock())
	TRB095->(dbSkip())
Enddo

MarkBRefresh()      
oMark:oBrowse:Gotop()

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DIPR095   ºAutor  ³Microsiga           º Data ³  09/23/16   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function DipImpSC2()
Local lImpOp    := .F.                                            
Local nPos		:= 0
Local nLin		:= 0
Local nI 		:= 0
Local aRetSG1   := {}
Local aPrint    := {}
Local aPrintOP  := {}

PRIVATE _nCount := 1
PRIVATE nOpcRel := 0
PRIVATE nBar	:= 0
PRIVATE oPrint  := TMSPrinter():New("Impressão de PI")
PRIVATE titulo 	:= "Impressão de PI"  
PRIVATE oFont09 := TFont():New("Arial",9,09,.T.,.F.,5,.T.,5,.T.,.F.)
PRIVATE oFont10 := TFont():New("Arial",9,10,.T.,.F.,5,.T.,5,.T.,.F.)
PRIVATE oFont11n:= TFont():New("Arial",9,11,.T.,.T.,5,.T.,5,.T.,.F.)
PRIVATE oFont12 := TFont():New("Arial",9,12,.T.,.F.,5,.T.,5,.T.,.F.)
PRIVATE oFont12n:= TFont():New("Arial",9,12,.T.,.T.,5,.T.,5,.T.,.F.)
PRIVATE oFont15n:= TFont():New("Arial",9,15,.T.,.T.,5,.T.,5,.T.,.F.)
PRIVATE oFont28n:= TFont():New("Arial",9,28,.T.,.T.,5,.T.,5,.T.,.F.)

If !(oPrint:IsPrinterActive())
	oPrint:Setup()
	Return (.F.)
EndIf

oPrint:SetPortrait()

nOpcRel := Aviso("Atenção","Imprime relatório:",{"PI por OP","OP por PI","Sintético"})

If nLin==0
	nLin := InvtCab(nLin)		
EndIf

TRB095->(dbGotop())
While !TRB095->(Eof())
	If !Empty(TRB095->C2_OK)	
		aRetSG1 := DipRetSG1(TRB095->C2_PRODUTO)
		cCodPrinc := ""
		cOpOld    := ""
		For nI:=1 to Len(aRetSG1)
			If nLin > 3100  
				oPrint:EndPage()  
				nLin:=0
				oPrint:StartPage()
			ElseIf nLin == 0
				oPrint:StartPage()
			EndIf
			
			If nLin==0
				nLin := InvtCab(nLin)		
			EndIf
			
			If Left(aRetSG1[nI,2],4)=="SERV" .Or. Left(aRetSG1[nI,2],1)<>'7'
				Loop
			EndIf
			
			If nOpcRel == 1
				If cOpOld <> TRB095->(C2_NUM+C2_ITEM+C2_SEQUEN+C2_PRODUTO)	
					cDescProd := ""					
					If !Empty(cOpOld)
						nLin += 300
					EndIf					
					SB1->(dbSetOrder(1))
					If SB1->(dbSeek(xFilial("SB1")+TRB095->C2_PRODUTO))
						cDescProd := SB1->B1_DESC 
					EndIf
					oPrint:Say(nLin,0100,"OP - "+TRB095->(C2_NUM+'.'+C2_ITEM+'.'+C2_SEQUEN+' / '+AllTrim(C2_PRODUTO)+' - '+cDescProd),oFont11n)					
					cOpOld := TRB095->(C2_NUM+C2_ITEM+C2_SEQUEN+C2_PRODUTO)				
					nLin += 50
				EndIf
				
				oPrint:Say(nLin,0100,aRetSG1[nI,2]											  ,oFont10)
				oPrint:Say(nLin,0300,aRetSG1[nI,9]											  ,oFont10)
				oPrint:Say(nLin,2000,aRetSG1[nI,7]											  ,oFont10)					
				oPrint:Say(nLin,2300,Transform(aRetSG1[nI,3]*TRB095->C2_QUANT,"@E 999,999.99"),oFont10)					
				nLin += 50								
			ElseIf nOpcRel == 2			
				cDescProd := ""
				SB1->(dbSetOrder(1))
				If SB1->(dbSeek(xFilial("SB1")+TRB095->C2_PRODUTO))
					cDescProd := SB1->B1_DESC 
				EndIf					
				
				If  (nPos:=aScan(aPrint,{|x| x[1]==aRetSG1[nI,2]}))==0				
					aAdd(aPrint,{aRetSG1[nI,2],aRetSG1[nI,9],aRetSG1[nI,7],aRetSG1[nI,3]*TRB095->C2_QUANT,{}})
					aAdd(aPrint[Len(aPrint),5],{"OP - "+TRB095->(C2_NUM+'.'+C2_ITEM+'.'+C2_SEQUEN+' / '+AllTrim(C2_PRODUTO)+' - '+cDescProd),aRetSG1[nI,3]*TRB095->C2_QUANT})
				Else
					aPrint[nPos,4] += (aRetSG1[nI,3]*TRB095->C2_QUANT)					
					aAdd(aPrint[nPos,5],{"OP - "+TRB095->(C2_NUM+'.'+C2_ITEM+'.'+C2_SEQUEN+' / '+AllTrim(C2_PRODUTO))+' - '+cDescProd,aRetSG1[nI,3]*TRB095->C2_QUANT})									
				EndIf
			Else
				If  (nPos:=aScan(aPrint,{|x| x[1]==aRetSG1[nI,2]}))==0
					aAdd(aPrint,{aRetSG1[nI,2],aRetSG1[nI,9],aRetSG1[nI,7],aRetSG1[nI,3]*TRB095->C2_QUANT })
				Else
					aPrint[nPos,4]+= (aRetSG1[nI,3]*TRB095->C2_QUANT)
				EndIf
							
				If cOpOld <> TRB095->(C2_NUM+C2_ITEM+C2_SEQUEN+C2_PRODUTO)	
					cDescProd := ""
					SB1->(dbSetOrder(1))
					If SB1->(dbSeek(xFilial("SB1")+TRB095->C2_PRODUTO))
						cDescProd := SB1->B1_DESC 
					EndIf					
					aAdd(aPrintOP,"OP - "+TRB095->(C2_NUM+'.'+C2_ITEM+'.'+C2_SEQUEN+' / '+AllTrim(C2_PRODUTO))+' - '+cDescProd)
					cOpOld := TRB095->(C2_NUM+C2_ITEM+C2_SEQUEN+C2_PRODUTO)
				EndIf				
			EndIf 		
		Next nI
	EndIf
	TRB095->(dbSkip())
EndDo

If nOpcRel==2
	aSort(aPrint,,,{|x,y| x[1]<y[1]})
	For nI := 1 To Len(aPrint)
		If nLin > 3100  
			oPrint:EndPage()  
			nLin:=0
			oPrint:StartPage()
		ElseIf nLin == 0
			oPrint:StartPage()
		EndIf
		
		If nLin==0
			nLin := InvtCab(nLin)		
		EndIf
		
		nLin += 50                                                                         
		oPrint:Say(nLin,0100,aPrint[nI,1]											,oFont11n)
		oPrint:Say(nLin,0300,aPrint[nI,2]											,oFont11n)
		oPrint:Say(nLin,2000,aPrint[nI,3]											,oFont11n)					
		oPrint:Say(nLin,2300,Transform(aPrint[nI,4],"@E 999,999.99")				,oFont11n)	
		nLin += 50  
		
		For nJ := 1 to Len(aPrint[nI,5])
			oPrint:Say(nLin,0100,aPrint[nI,5,nJ,1] ,oFont10)
			oPrint:Say(nLin,2300,Transform(aPrint[nI,5,nJ,2],"@E 999,999.99"),oFont10)		
			nLin += 50 
		Next nJ
	Next nI
ElseIf nOpcRel==3
	aSort(aPrint,,,{|x,y| x[1]<y[1]})
	For nI := 1 To Len(aPrint)
		If nLin > 3100  
			oPrint:EndPage()  
			nLin:=0
			oPrint:StartPage()
		ElseIf nLin == 0
			oPrint:StartPage()
		EndIf
		
		If nLin==0
			nLin := InvtCab(nLin)		
		EndIf
		                                                                         
		oPrint:Say(nLin,0100,aPrint[nI,1]											,oFont10)
		oPrint:Say(nLin,0300,aPrint[nI,2]											,oFont10)
		oPrint:Say(nLin,2000,aPrint[nI,3]											,oFont10)					
		oPrint:Say(nLin,2300,Transform(aPrint[nI,4],"@E 999,999.99")				,oFont10)					
										
		nLin += 50   
	Next nI
	
	nLin += 100
	aSort(aPrintOP,,,{|x,y| x[1]<y[1]})	
	For nI := 1 to Len(aPrintOP)		
		If nLin > 3100  
			oPrint:EndPage()  
			nLin:=0
			oPrint:StartPage()
		ElseIf nLin == 0
			oPrint:StartPage()
		EndIf
		
		If nLin==0
			nLin := InvtCab(nLin)		
		EndIf
		                                                                         
		oPrint:Say(nLin,0100,aPrintOP[nI] ,oFont11n)
	
		nLin += 50   
	Next nI
EndIf

oPrint:EndPage()             

oPrint:Preview()

MS_FLUSH()                   

Return     
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DIPINVENT ºAutor  ³Microsiga           º Data ³  01/17/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function InvtCab(nLin)              
DEFAULT nLin := 0
Private RootPath := GetSrvProfString("Startpath","") 
If nLin == 0
	nLin :=100
	oPrint:Line(nLin,0100,nLin,2500) 	

	nLin+=10	
	oPrint:SayBitmap(nLin,100,GetSrvProfString("Startpath","")+"logo_hq.bmp",360,75)
	nLin+=60
	
	oPrint:Say(nLin+20	,0100,"DIPR095 - "+IIf(cFilAnt=='01',"HQ-MTZ","HQ-CD")								  		 		,oFont09)
	oPrint:Say(nLin		,0800,"Relação de PI - ("+IIf(nOpcRel==1,"PI por OP",IIf(nOpcRel==2,"OP por PI","Sintético"))+")"	,oFont15n)
	oPrint:Say(nLin-50	,2400,"Pag "+StrZero(_nCount,2)	   																	,oFont09)
	oPrint:Say(nLin+20	,2380,DtoC(dDataBase)	   																	,oFont09) 
	nLin+=20
	
	_nCount++
EndIf

nLin+=50
oPrint:Line(nLin,0100,nLin,2500) 
nLin+=10

oPrint:Say(nLin,0100,"PI"		,oFont12n)
oPrint:Say(nLin,0300,"DESC."	,oFont12n)
oPrint:Say(nLin,2000,"UM"		,oFont12n)
oPrint:Say(nLin,2300,"QUANT"	,oFont12n)

nLin+=50
oPrint:Line(nLin,0100,nLin,2500) 
nLin+=10

Return nLIn

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DIPA060   ºAutor  ³Microsiga           º Data ³  09/29/16   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function DipRetSG1(cProduto)
Local lProcura := .T.             
Local aItens   := {}
Local nI       := 0

//______________________________
//                              |
//  aItens[1] - PRODUTO         |
//  aItens[2] - COMPONENTE      |
//  aItens[3] - QUANTIDADE      |
//  aItens[4] - REQUISICAO?     |
//  aItens[5] - LOCAL PADRAO    |
//  aItens[6] - FLAG CONTROLE   |
//  aItens[7] - UM  		    |
//  aItens[8] - SEGUNDA UM      |
//______________________________|


SG1->(dbSetOrder(1))
If SG1->(dbSeek(xFilial("SG1")+cProduto)) 	
	While SG1->G1_COD == cProduto         
		SB1->(dbSetOrder(1))
		If SB1->(dbSeek(xFilial("SB1")+SG1->G1_COMP))
			aAdd(aItens,{SG1->G1_COD,SG1->G1_COMP,SG1->G1_QUANT,.T.,SB1->B1_LOCPAD,.T.,SB1->B1_UM,SB1->B1_SEGUM,SB1->B1_DESC}) 			
		EndIf                                                                         
		SG1->(dbSkip())
	EndDo	
			
	While lProcura
		lProcura := .F.
		For nI:=1 to Len(aItens)
			If aItens[nI,6] 
				If SG1->(dbSeek(xFilial("SG1")+aItens[nI,2]))
					While SG1->G1_COD == aItens[nI,2]
						SB1->(dbSetOrder(1))
						If SB1->(dbSeek(xFilial("SB1")+SG1->G1_COMP))
							aAdd(aItens,{SG1->G1_COD,SG1->G1_COMP,SG1->G1_QUANT,.T.,SB1->B1_LOCPAD,.T.,SB1->B1_UM,SB1->B1_SEGUM,SB1->B1_DESC}) 
						EndIf   
						aItens[nI,4] := .F.
						SG1->(dbSkip())
					EndDo	
					lProcura := .T.
				EndIf    		   
				aItens[nI,6] := .F.		
			EndIf
		Next nI   
		SG1->(dbSkip())
	EndDo	
	aSort(aItens,,,{|x,y| x[1]+x[2]<y[1]+y[2]})
EndIf

Return aItens

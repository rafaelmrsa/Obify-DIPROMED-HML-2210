#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³NOVO7     ºAutor  ³Microsiga           º Data ³  07/17/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function DIPA067()                                   
Local aCores		:= {}                   
Private cEnd		:= CHR(10)+CHR(13)
Private cCadastro 	:= "Inventário Rotativo"
Private aRotina 	:= { ;
{"Pesquisar"  ,"AxPesqui"   , 0 , 1},;    
{"Visualiza"  ,"AxVisual"   , 0 , 2},;  
{"Monitor"    ,"U_D67MON()" , 0 , 3},;
{"Legenda"    ,"U_D67LEG()" , 0 , 7},;
{"Diverg."    ,"U_DIPR078()", 0 , 7},;
{"Encerrar."  ,"U_D67ENC()" , 0 , 7}}

aAdd(aCores , {'ZZC_STATUS = "1"','BR_VERDE'   } )   
aAdd(aCores , {'ZZC_STATUS = "2"','BR_AMARELO' } )
aAdd(aCores , {'ZZC_STATUS = "3"','BR_CINZA'   } )
aAdd(aCores , {'ZZC_STATUS = "4"','BR_VERMELHO'} )

U_DIPPROC(ProcName(0),U_DipUsr())

dbSelectArea("ZZC")
                                
//SET FILTER TO 
                                      
mBrowse( 6, 1,22,75,"ZZC",,,,,,aCores,,,,,,,,,10000,{|x| DipRef(x)})

//SET FILTER TO 	

Return  
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DIPA056   ºAutor  ³Microsiga           º Data ³  11/19/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                         	              º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function D67MON()
Local _xAlias 		:= GetArea()
Local bCampoSC5		:= { |nCPO| Field(nCPO) }
Local cTitulo		:= OemToAnsi("Monitor - Inventario Rotativo")
Local cAliasGetD	:="ZZD"
Local aCpoEnchoice	:={}
Local aAltEnchoice 	:= {}
Local cLinOk		:= "AllwaysTrue()"
Local cTudoOk		:= "AllwaysTrue()"
Local aCpoEnchoice 	:= {}
Local aAltEnchoice 	:= {}  
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

If !ZZC->ZZC_STATUS$'2/4'
	Aviso("Atenção","Opção permitida somente para contagens finalizadas.",{"Ok"},1)
	RestArea(_xAlias)
	Return
EndIf

aSize   := MsAdvSize()
aAdd(aObjects, {100, 100, .T., .F.})
aAdd(aObjects, {100, 200, .T., .T.})
aInfo   := {aSize[1], aSize[2], aSize[3], aSize[4], 2, 2}
aPosObj := MsObjSize(aInfo, aObjects)


nUsado:=0
SX3->(dbSetOrder(1))
SX3->(dbSeek("ZZD"))

aHeader:={}                                   
Aadd(aHeader, {" ","cMostra","@BMP",2,0,".F.","","C","","V","","","","V"})
While !SX3->(Eof()) .And. (SX3->X3_ARQUIVO=="ZZD")	
	If X3USO(SX3->X3_USADO) .And. cNivel>=SX3->X3_NIVEL		
		nUsado++		
		aAdd(aHeader,{	AllTrim(SX3->X3_TITULO),;
						SX3->X3_CAMPO,;
						SX3->X3_PICTURE,;
						SX3->X3_TAMANHO,;
						SX3->X3_DECIMAL,;
						"AllwaysTrue()",;
						SX3->X3_USADO,;
						SX3->X3_TIPO,;
						SX3->X3_ARQUIVO,;
						SX3->X3_CONTEXT})
	EndIf
	SX3->(dbSkip())
EndDo

dbSelectArea("ZZD")
ZZD->(dbSetOrder(1))
If ZZD->(dbSeek(xFilial("ZZD")+ZZC->(ZZC_LOCAL+ZZC_LOCALI+DTOS(ZZC_DATA))))
	While !ZZD->(Eof()).And.ZZD->(ZZD_FILIAL+ZZD_LOCAL+ZZD_LOCALI+DTOS(ZZD_DATA))==ZZC->(ZZC_FILIAL+ZZC_LOCAL+ZZC_LOCALI+DTOS(ZZC_DATA))		
		
		Do Case 
			Case ZZD->ZZD_QUANT == ZZD->ZZD_QTCONT
				cStatus := "BR_VERDE"
			Case ZZD->ZZD_TIPREG == "A"
				cStatus := "BR_CINZA"
			OtherWise                
				cStatus := "BR_AZUL"
		EndCase                     
		
		aAdd(aCols,Array(Len(aHeader)+1))
		For nI:=1 to Len(aHeader)                                   
			If nI==1                  
				aCols[Len(aCols),nI]:= cStatus
			Else
				aCols[Len(aCols),nI]:=FieldGet(FieldPos(aHeader[nI,2]))
			EndIf
		Next
		aCols[Len(aCols),Len(aHeader)+1]:=.F.
		ZZD->(dbSkip())
	EndDo
EndIf    

IF Len(aCols)>0
	DEFINE MSDIALOG oDlg TITLE cTitulo From aSize[7],0 to aSize[6],aSize[5] of oMainWnd PIXEL
	EnChoice("ZZC",ZZC->(Recno()),2,,,,aCpoEnchoice,{aPosObj[1,1],aPosObj[1,2],aPosObj[1,3],aPosObj[1,4]},nil,3,,,,,,.F.)
	oGetDados := MsGetDados():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,3],aPosObj[2,4],3,cLinOk,cTudoOk,"",,{"ZZD_QTELEI"},1,,Len(aCols))
	ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg, {|| nOpca := 1, oDlg:End()},{||oDlg:End()})
EndIF

If nOpca == 1
	GrvDad()
EndIf

RestArea(_xAlias)

Return  
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DIPA056   ºAutor  ³Microsiga           º Data ³  11/19/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                         	              º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function D67LEG()
Local aLegenda:={}

aAdd(aLegenda, {'BR_VERDE'   ,"Inventario Iniciado"	} )  // 3
aAdd(aLegenda, {'BR_AMARELO' ,"Contagem finalizada"	} )  // 2   
aAdd(aLegenda, {'BR_CINZA'   ,"Endereço em pausa  " } )  // 1
aAdd(aLegenda, {'BR_VERMELHO',"Endereço Processado" } )  // 1
/*
aAdd(aLegenda, {'BR_AZUL'	 ,"Pedido à vista" 		} )  // 1
aAdd(aLegenda, {'BR_CINZA'   ,"Aguardando Consolidacao"} )  // 1
*/
BrwLegenda("Status Inventário Rotativo","Status",aLegenda)

Return       
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DIPA067   ºAutor  ³Microsiga           º Data ³  07/28/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function D67ENC()
Local cDocSD3	  := ""                
Local lRet		  := .T.
Local cDesc		  := "INVENTÁRIO ROTATIVO"
Local lCancel	  := .T.     
Local cCodPro	  := ""
Private aDados498 := {}
Private aDados501 := {}
Private aDadosMtz := {}              
Private aTrocLotM := {}
Private aTrocLotC := {}

If cEmpAnt+cFilAnt == '0104'
	
	If ZZC->ZZC_STATUS == "2"
		If Aviso("Atenção","Deseja finalizar o endereço e fazer os acertos no estoque?",{"Sim","Não"},1) == 1
			ZZD->(dbSetOrder(1))
			If ZZD->(dbSeek(xFilial("ZZD")+ZZC->(ZZC_LOCAL+ZZC_LOCALI+DTOS(ZZC_DATA))))
				While !ZZD->(Eof()).And.ZZD->(ZZD_FILIAL+ZZD_LOCAL+ZZD_LOCALI+DTOS(ZZD_DATA))==ZZC->(ZZC_FILIAL+ZZC_LOCAL+ZZC_LOCALI+DTOS(ZZC_DATA))		
			        
			        SB1->(dbSetOrder(1))                             			        
			        If SB1->(dbSeek(xFilial("SB1")+ZZD->ZZD_PRODUTO)) 
			        	cCodPro := AllTrim(SB1->B1_COD)+" ("+SB1->B1_DESC+")"
			        	
			        	If (lCancel:=VldCxEmb(ZZD->ZZD_QUANT,ZZD->ZZD_QTELEI,SB1->B1_XVLDCXE,SB1->B1_XTPEMBV,SB1->B1_XQTDEMB,SB1->B1_XQTDSEC))
			        		Exit
			        	EndIf

			        	If Empty(ZZD->ZZD_TRCLOT)
			        		If !VldTrcLot(ZZD->ZZD_QUANT,ZZD->ZZD_QTELEI,ZZD->ZZD_LOCAL,ZZD->ZZD_LOCALI,ZZD->ZZD_PRODUTO,ZZD->ZZD_LOTECT)
								VldAjuInv(ZZD->ZZD_QUANT,ZZD->ZZD_QTELEI,ZZD->ZZD_LOCAL,ZZD->ZZD_LOCALI,ZZD->ZZD_PRODUTO,ZZD->ZZD_LOTECT)
							EndIf
						EndIf   

					Else
						Aviso("Atenção","Produto "+AllTrim(ZZD->ZZD_PRODUTO)+" não existe, portanto, não será movimentado.",{"Ok"},1)							
					EndIf
											
					ZZD->(dbSkip())
				EndDo		                  
				
				If !lCancel
					
					Begin Transaction      
						
						u_DipBlqEnd(ZZC->ZZC_LOCAL,ZZC->ZZC_LOCALI,StoD(""))
						
						If Len(aTrocLotM)>0
							GetEmpr('0101')							
							lRet := DipTransf(aTrocLotM,"T")
							GetEmpr('0104')
						EndIf
						
						If lRet
							If Len(aTrocLotC)>0
								lRet := DipTransf(aTrocLotC,"T")
							EndIf                                
						Else 
							If !lRet
								If InTransact()
									DisarmTransaction()
								EndIf
								Break
							EndIf
						EndIF
	
						If lRet
							If Len(aDados498)>0
								lRet := DipGanho(aDados498,cDesc)
							EndIf                                
						Else 
							If !lRet
								If InTransact()
									DisarmTransaction()
								EndIf
								Break
							EndIf
						EndIF
						                  
						If lRet
							If Len(aDados501)>0
								lRet := DipTransf(aDados501,"P")
							EndIf
						Else
							If !lRet
								If InTransact()
									DisarmTransaction()
								EndIf
								Break
							EndIf
						EndIf
			                        
						If lRet
							If Len(aDadosMtz)>0
								GetEmpr('0101')
								lRet := DipTransf(aDadosMtz,"P")
								GetEmpr('0104')
							EndIf
						Else
							If InTransact()
								DisarmTransaction()
							EndIf
							Break
						EndIf
						    
						If lRet  
							ZZC->(RecLock("ZZC",.F.))						
								ZZC->ZZC_STATUS := "4"
							ZZC->(MsUnLock())
							Aviso("Atenção","Finalizado com sucesso"+cEnd+;
											"Confira o estoque para confirmar se as movimentações foram realizadas corretamente.",{"Ok"},1)
						Else
							If InTransact()
								DisarmTransaction()
							EndIf
							Break
						EndIf
					End Transaction					
				Else 
					Aviso("Atenção","Produto "+cCodPro+" só pode ser movimentado em caixa fechada. Esse acerto deverá ser feito manualmente.",{"Ok"},1)
				EndIf
			Else 
				Aviso("Erro","Endereço não encontrado",{"Ok"},1)
			EndIf
		EndIf
	Else
		Aviso("Atenção","Inventário não pode ser finalizado."+cEnd+"Verifique o Status.",{"Ok"},1)	
	EndIf
Else                                                                                                            
	Aviso("Atenção","Função exclusiva para DIPROMED-CD.",{"Ok"},1)	
EndIf
Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DIPA067   ºAutor  ³Microsiga           º Data ³  07/29/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function VldAjuInv(nQuant,nQtdEle,cLocal,cLocali,cProduto,cLoteCt)
Local nQtdDif := 0    
Local nQtdMov := (nQuant-nQtdEle)            

If nQtdEle > nQuant                     
	DipAdd(@aDados498,cProduto,"14",cLoteCt,cLocali,(nQtdEle-nQuant))
ElseIf nQtdEle < nQuant
	nQtdMat := RetQtdMt(cLocal,cLocali,cProduto,cLoteCt)
	If nQtdEle>0
		If nQtdMat >= nQtdMov
			DipAdd(@aDadosMtz,cProduto,cLocal,cLoteCt,cLocali,nQtdMov)
		Else
			If nQtdMat > 0
				DipAdd(@aDadosMtz,cProduto,cLocal,cLoteCt,cLocali,nQtdMat)
			EndIf
			nQtdDif := nQtdMov-nQtdMat
			If nQtdDif > 0
				DipAdd(@aDados501,cProduto,cLocal,cLoteCt,cLocali,nQtdDif)
			EndIf
		EndIf
	Else
		If nQtdMat > 0
			DipAdd(@aDadosMtz,cProduto,cLocal,cLoteCt,cLocali,nQtdMat)
		EndIf
		nQtdDif := (nQtdMov-nQtdMat)
		If nQtdDif > 0
			DipAdd(@aDados501,cProduto,cLocal,cLoteCt,cLocali,nQtdDif)
		EndIf
	EndIf
EndIf

Return     
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DIPA067   ºAutor  ³Microsiga           º Data ³  07/29/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function RetQtdMt(cLocal,cLocali,cProduto,cLoteCt)
Local cSQL := ""
Local nQtd := 0

cSQL := " SELECT "
cSQL += "  	(SUM(BF_QUANT)-SUM(BF_EMPENHO)) BF_QUANT "
cSQL += " 	FROM "
cSQL += 		RetSQLName("SBF")
cSQL += " 		WHERE "
cSQL += " 			BF_FILIAL  = '01' AND "
cSQL += " 			BF_PRODUTO = '"+cProduto+"' AND "
cSQL += " 			BF_LOTECTL = '"+cLoteCt+"' AND "
cSQL += " 			BF_LOCAL   = '"+cLocal+"' AND "
cSQL += " 			BF_LOCALIZ = '"+cLocali+"' AND "
cSQL += " 			BF_QUANT > 0 AND "
cSQL += " 			D_E_L_E_T_ = ' ' "

cSQL := ChangeQuery(cSQL)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),"QRYSBF",.T.,.T.)

TCSETFIELD("QRYSBF","BF_QUANT"  ,"N",12,4)

If !QRYSBF->(Eof())
	nQtd := QRYSBF->BF_QUANT	
EndIf
QRYSBF->(dbCloseArea())

Return nQtd       
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DIPA067   ºAutor  ³Microsiga           º Data ³  07/29/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function RetNumDoc()
Local cSQL 	  := ""
Local cDocSD3 := "IROT00000"

cSQL := " SELECT "
cSQL += " 	ISNULL(MAX(D3_DOC),'IROT00000') DOC "
cSQL += " 	FROM "
cSQL +=  		RetSQLName("SD3")
cSQL += " 		WHERE "
cSQL += " 			D3_FILIAL = '"+xFilial("SD3")+"' AND "
cSQL += " 			LEFT(D3_DOC,4) = 'IROT' AND "
cSQL += " 			D_E_L_E_T_ = ' ' "

cSQL := ChangeQuery(cSQL)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),"QRYSD3",.T.,.T.)

If !QRYSD3->(Eof())	
	cDocSD3 := Soma1(QRYSD3->DOC)	
EndIf
QRYSD3->(dbCloseArea())

Return cDocSD3    
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DIPA067   ºAutor  ³Microsiga           º Data ³  07/30/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function DipAdd(aDados,cProduto,cLocal,cLoteCt,cLocali,nQtd)
Local aAreaSB8 := SB8->(GetArea())
Local dDtVal   := StoD("")

SB8->(dbSetOrder(3))              
If SB8->(dbSeek("04"+cProduto+"01"+cLoteCt))  //Local Padrão 01
	dDtVal := SB8->B8_DTVALID
ElseIf SB8->(dbSeek("01"+cProduto+"01"+cLoteCt))  
	dDtVal := SB8->B8_DTVALID 
EndIf

aAdd(aDados,{cProduto,;
		 	 cLocal,;
			 cLoteCt,;
			 cLocali,;
			 nQtd,;
			 dDtVal,;
			 0})   
			 
RestArea(aAreaSB8)

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DIPA067   ºAutor  ³Microsiga           º Data ³  07/30/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function DipBlqEnd(cLocal,cLocali,dData)
Local cSQL := ""

cSQL := " SELECT " 
cSQL += " 	BE_FILIAL, R_E_C_N_O_  REC "
cSQL += " 	FROM "
cSQL += 		RetSQLName("SBE")
cSQL += " 		WHERE "
cSQL += " 			BE_LOCAL = '"+cLocal+"' AND "
cSQL += " 			BE_LOCALIZ = '"+cLocali+"' AND "
cSQL += " 			D_E_L_E_T_ = ' ' "

cSQL := ChangeQuery(cSQL)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),"QRYSBE",.T.,.T.)

While !QRYSBE->(Eof())
	SBE->(dbGoTo(QRYSBE->REC))
	SBE->(RecLock("SBE",.F.))
		SBE->BE_DTINV := dData
		If QRYSBE->BE_FILIAL == "04" .And. !Empty(dData)
			SBE->BE_XDATCON := dData	
			SBE->BE_XUSUROT := Upper(AllTrim(U_DipUsr()))
			SBE->BE_XNRCONT := SBE->BE_XNRCONT+1
		EndIf
	SBE->(MsUnLock())   
	QRYSBE->(dbSkip())
EndDo	             
QRYSBE->(dbCloseArea())
Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DIPA067   ºAutor  ³Microsiga           º Data ³  07/30/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function DipTransf(aDados,cTipo)  
Local nI		  := 0                     
Local lRet 		  := .T.
Local aDadTrans	  := {}
Local cDocSD3 	  := RetNumDoc()    
Local cMsg		  := ""
Local aMsgMail 	  := {}
Local cLocAux	  := ""
Private aJaBaixa  := {}
Private lMsErroAuto := .F. 
DEFAULT aDados 	  := {}
DEFAULT cTipo     := ""

Do Case
	Case cTipo == "G"        
		cLocAux := "14"
	Case cTipo == "P"
		cLocAux := "15"
	Case cTipo == "T"
		cLocAux := "01"
End Case
	
aAdd(aDadTrans,{ 	cDocSD3														,; // 01.Numero do Documento
					dDataBase													}) // 02.Data da Transferencia    

For nI:=1 to Len(aDados)   
    If u_DipVldRes(aDados[nI,1],aDados[nI,2],aDados[nI,5],cTipo,aJaBaixa)
		SB1->(Dbsetorder(1))	
		If SB1->(Dbseek(xFilial("SB1")+aDados[nI,1]))	
		
			aAdd(aDadTrans,{	SB1->B1_COD													,; // 01.Produto Origem
								SB1->B1_DESC												,; // 02.Descricao
								SB1->B1_UM													,; // 03.Unidade de Medida
								aDados[nI,2]												,; // 04.Local Origem
								aDados[nI,4]												,; // 05.Endereco Origem
								SB1->B1_COD													,; // 06.Produto Destino
								SB1->B1_DESC												,; // 07.Descricao
								SB1->B1_UM													,; // 08.Unidade de Medida
								cLocAux						   								,; // 09.Armazem Destino
								aDados[nI,4]												,; // 10.Endereco Destino
								CriaVar("D3_NUMSERI",.F.)									,; // 11.Numero de Serie
								aDados[nI,3]												,; // 12.Lote Origem
								CriaVar("D3_NUMLOTE",.F.)									,; // 13.Sublote
								aDados[nI,6]												,; // 14.Data de Validade
								CriaVar("D3_POTENCI",.F.)									,; // 15.Potencia do Lote
								aDados[nI,5]												,; // 16.Quantidade
								CriaVar("D3_QTSEGUM",.F.)									,; // 17.Quantidade na 2 UM
								CriaVar("D3_ESTORNO",.F.)									,; // 18.Estorno
								CriaVar("D3_NUMSEQ",.F.)									,; // 19.NumSeq
								IIf(cTipo=="T",aDados[nI,8],aDados[nI,3])					,; // 20.Lote Destino
								aDados[nI,6]												,; // 21.Data de Validade do Destino
								Criavar("D3_ITEMGRD",.F.)									,; // 22.Item grade MCVN - 16/11/09)								
								""									 						,; // 23.Observação
								"Inventário Rotativo"										,; // 24.Explicação
								""															}) // 25.Nro Separação
			If cTipo == "P"
				aAdd(aJaBaixa,{aDados[nI,1],aDados[nI,5]})
			EndIf
		EndIf
	Else 
		u_DipRetPed(aDados[nI,1],aDados[nI,3],@aMsgMail,aDados[nI,5])
		lRet := .F.
	EndIf
Next nI                

//"X"									 						,; // 23.Id DCF

If Len(aMsgMail)>0       
	For nI:=1 to Len(aMsgMail)        
		cMsg += "Produto/Lote: "+aMsgMail[nI,1]+cEnd
		For nJ:=1 to Len(aMsgMail[nI,2])
			cMsg += aMsgMail[nI,2,nJ,1]+" "+aMsgMail[nI,2,nJ,2]+cEnd
		Next nJ
		cMsg += cEnd
	Next nI
	                                               
	Aviso("Atenção","O(s) produto(s) não pode(m) ser movimentado(s), pois possui(em) reserva. "+cEnd+;
					"Verifique a reserva com a vendedora e execute o processo de baixa manual."+cEnd+cEnd+;
					cMsg,{"Ok"},3)
	DipWF(aMsgMail,ZZC->ZZC_LOCALIZ)
EndIf
                   
If lRet .And. Len(aDadtrans)>1
	MSExecAuto({|x,y| MATA261(x,y)},aDadtrans,3)
EndIf                                                        

If lMsErroAuto
	MostraErro()
	lRet := .F.
EndIf

Return lRet    
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DIPA067   ºAutor  ³Microsiga           º Data ³  07/31/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function DipVldRes(cProduto,cLocal,nQuant,cTipo,aJaBaixa)
Local lRet := .T.
Local cSQL := ""
Local nPos := 0           
DEFAULT aJaBaixa := {}

If cTipo$"P"                                                
	nPos := aScan(aJaBaixa,{|X| x[1]==cProduto})
	
	If nPos>0
		nQuant += aJaBaixa[nPos,2]
	EndIf                         
	
	cSQL := " SELECT "
	cSQL += " 	B2_QATU-B2_RESERVA QTD "
	cSQL += " 	FROM "
	cSQL +=  		RetSQLName("SB2")
	cSQL += " 		WHERE "
	cSQL += " 			B2_FILIAL = '"+xFilial("SB2")+"' AND "
	cSQL += " 			B2_COD 	  = '"+cProduto+"' AND "
	cSQL += " 			B2_LOCAL  = '"+cLocal+"' AND "
	cSQL += " 			D_E_L_E_T_ = ' ' "

	cSQL := ChangeQuery(cSQL)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),"QRYSB2",.T.,.T.)
	
	If !QRYSB2->(Eof())
		lRet := (QRYSB2->QTD>=nQuant)
	EndIf       
	QRYSB2->(dbCloseArea())	
EndIf
	
Return lRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DIPA067   ºAutor  ³Microsiga           º Data ³  07/31/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function DipRetPed(cProduto,cLote,aMsgMail,nQuant)
Local cSQL  := ""
Local nLen1 := 0

cSQL := " SELECT "
cSQL += " 	C9_PEDIDO, C9_QTDORI, C9_OPERADO "
cSQL += " 	FROM "
cSQL += 		RetSQLName("SC9")
cSQL += " 		WHERE "
cSQL += " 			C9_FILIAL  = '"+xFilial("SC9")+"' AND "
cSQL += " 			C9_PRODUTO = '"+cProduto+"' AND "
cSQL += " 			C9_NFISCAL = ' ' AND "
cSQL += " 			C9_LOCAL   = '01' AND "    
cSQL += "			C9_QTDORI  > 0 AND "
cSQL += " 			D_E_L_E_T_ = ' ' "

cSQL := ChangeQuery(cSQL)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),"QRYSC9",.T.,.T.)

TCSETFIELD("QRYSC9","C9_QTDORI","N",12,4)

If !QRYSC9->(Eof())
	aAdd(aMsgMail,{"",{}})
	nLen1 := Len(aMsgMail)
	
	aMsgMail[nLen1,1] := AllTrim(cProduto)+"/"+AllTrim(cLote)
	
	While !QRYSC9->(Eof())
		aAdd(aMsgMail[nLen1,2],{"Empresa: "		 ,IIf(cFilAnt=="01","Matriz","CD")})
		aAdd(aMsgMail[nLen1,2],{"Pedido: "		 ,QRYSC9->C9_PEDIDO})
		aAdd(aMsgMail[nLen1,2],{"Vend.:  "		 ,POSICIONE("SU7",1,xFilial("SU7")+QRYSC9->C9_OPERADO,"U7_NOME")})
		aAdd(aMsgMail[nLen1,2],{"Qtd.Reservada: ",Transform(QRYSC9->C9_QTDORI,"@E 999,999.99")})
		aAdd(aMsgMail[nLen1,2],{"Baixar: "		 ,Transform(nQuant		 	 ,"@E 999,999.99")})
		QRYSC9->(dbSkip())                                                              
	EndDo
EndIf
QRYSC9->(dbCloseArea())	
	
Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DIPA067   ºAutor  ³Microsiga           º Data ³  07/31/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function DipWF(aMsgMail,cLocaliz)
Local aMsg 	 	:= {}                                                     
Local cFrom     := "protheus@dipromed.com.br"
Local cFuncSent := "DIPA067(DipWF)"
Local cMsgCic   := ""
Local cAssunto	:= "PRODUTO COM RESERVA-INVETARIO ROTATIVO. "+cLocaliz
DEFAULT aMsgMail := {}


Aadd(aMsg,{"Endereço: ",cLocaliz})

cMsgCic += "ATENÇÃO!!!"+cEnd
cMsgCic += "PRODUTO COM RESERVA-INVETARIO ROTATIVO - "+cLocaliz+cEnd
cMsgCic += "ENTRE EM CONTATO COM A VENDEDORA PARA RETIRAR A RESERVA E FAÇA A TRANSFERENCIA PARA O ESTOQUE 15"+cEnd
cMsgCic += cEnd
For nI:=1 to Len(aMsgMail)
	Aadd(aMsg,{"Produto/Lote: ",aMsgMail[nI,1]})
	
	For nJ:=1 to Len(aMsgMail[nI,2])  	   
		Aadd(aMsg,{aMsgMail[nI,2,nJ,1],aMsgMail[nI,2,nJ,2]})
	Next nJ                    
	
	Aadd(aMsg,{" - "," - "})
Next nI

Aadd(aMsg,{"Usuário:   ",U_DipUsr()})

cMsgCic += cEnd
cMsgCic += "Usuário: "+U_DipUsr()
		
U_DIPCIC(cMsgCic,GetNewPar("ES_CICD067","MAXIMO.CANUTO"))//envia cic

U_UEnvMail(GetNewPar("ES_MAID067",SUPERGETMV("MV_#EMLTI",.F.,"ti@dipromed.com.br")),cAssunto,aMsg,"",cFrom,cFuncSent)

Return      
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DIPA067   ºAutor  ³Microsiga           º Data ³  08/04/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function DipGanho(aDados,cDesc)
Local lRet 		:= .T.
Local cDocSD3	:= RetNumDoc()             
Local nI 		:= 1

For nI:=1 to Len(aDados)
	DipCriaEnd(aDados[nI,1],"14")
Next nI

If lRet
	lRet := u_fGeraSD3("498",aDados,cDocSD3,cDesc)
EndIf

If lRet
	lRet := u_fEnder53(cDocSD3)
EndIf

Return lRet                 
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DIPA067   ºAutor  ³Microsiga           º Data ³  08/04/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function DipCriaEnd(cProduto,cLocal)
Local aArea := GetArea()

SB1->(dbSetOrder(1))
If SB1->(dbSeek(xFilial("SB1")+cProduto))	
	SB2->(dbSetOrder(1))
	If !SB2->(DbSeek(xFilial("SB2")+cProduto+cLocal))
		SB2->(RecLock("SB2",.T.))
			SB2->B2_FILIAL := xFilial("SB2")
			SB2->B2_COD    := cProduto
			SB2->B2_LOCAL  := cLocal
			SB2->B2_FORNEC := SB1->B1_PROC    
			SB2->B2_LOJAFOR:= SB1->B1_LOJPROC 
		SB2->(MsUnLock())
	EndIf
	
	SB3->(DbSetOrder(1))
	If !SB3->(DbSeek(xFilial("SB3")+cProduto))
		SB3->(RecLock("SB3",.T.))
			SB3->B3_FILIAL := xFilial("SB3")
			SB3->B3_COD    := cProduto
			SB3->B3_CLASSE := 'C'
		SB3->(MsUnLock())
	EndIf       
EndIf
	       
RestArea(aArea)
	
Return 
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DIPA067   ºAutor  ³Microsiga           º Data ³  08/14/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function DipRef(x)
Local oObjBrow  := GetObjBrow()       

oObjBrow:Refresh()            

Return             
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DIPA067   ºAutor  ³Microsiga           º Data ³  08/14/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function DipExpEle()
Local lRet 	  := .F.  
Local lSai	  := .F.
Local cExplic := Space(255)           
Local oTela
Local nPosExp := aScan(aHeader,{|x| Upper(AllTrim(x[2]))=="ZZD_EXPLIC" })                                                                       

While !lSai
	@ 100,150 To 200,530 Dialog oTela Title OemToAnsi("Explicacao QTD Eleita")
	@ 010,010 Get cExplic Valid !Empty(cExplic) Picture "@!" SIZE 170,10
	@ 030,120 BmpButton Type 1 Action (SaiTela(@lSai,cExplic),lRet:= .T.,oTela:End())
	@ 030,150 BmpButton Type 2 Action (lSai:=.T.,oTela:End())
	Activate Dialog oTela Centered
EndDo       

If lRet
	aCols[n,nPosExp] := cExplic
EndIf

Return lRet        
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DIPA067   ºAutor  ³Microsiga           º Data ³  08/14/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function SaiTela(lRet,cExplic)
DEFAULT lRet 	:= .F.
DEFAULT cExplic := ""

cExplic := StrTran(cExplic," ","")

If Len(cExplic)>30
	lRet := .T.
EndIf

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DIPA067   ºAutor  ³Microsiga           º Data ³  08/14/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function GrvDad()
Local nI 	:= 1 
Local nPosArm := aScan(aHeader,{|x| Upper(AllTrim(x[2]))=="ZZD_LOCAL"  })
Local nPosLoc := aScan(aHeader,{|x| Upper(AllTrim(x[2]))=="ZZD_LOCALI" })
Local nPosDat := aScan(aHeader,{|x| Upper(AllTrim(x[2]))=="ZZD_DATA"   })
Local nPosQtd := aScan(aHeader,{|x| Upper(AllTrim(x[2]))=="ZZD_QTELEI" })
Local nPosExp := aScan(aHeader,{|x| Upper(AllTrim(x[2]))=="ZZD_EXPLIC" })
Local nPosPro := aScan(aHeader,{|x| Upper(AllTrim(x[2]))=="ZZD_PRODUT" })
Local nPosLot := aScan(aHeader,{|x| Upper(AllTrim(x[2]))=="ZZD_LOTECT" })


For nI:=1 To Len(aCols)
	ZZD->(dbSetOrder(2))
	If ZZD->(dbSeek(xFilial("ZZD")+aCols[nI,nPosPro]+aCols[nI,nPosLot]+aCols[nI,nPosArm]+aCols[nI,nPosLoc]+DtoS(aCols[nI,nPosDat]))) .And.;
	   ZZD->ZZD_QTELEI <> aCols[nI,nPosQtd] 
		ZZD->(RecLock("ZZD",.F.))
			ZZD->ZZD_QTELEI	:= aCols[nI,nPosQtd]  
			ZZD->ZZD_EXPLIC := aCols[nI,nPosExp] 
		ZZD->(MsUnLock())
	EndIf
Next nI

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DIPA067   ºAutor  ³Microsiga           º Data ³  08/22/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function VldTrcLot(nQuant,nQtdEle,cLocal,cLocali,cProduto,cLoteCt)
Local cSQL 		:= ""         
Local lRet 		:= .F.  
Local nQtdAux 	:= nQuant-nQtdEle
Local aAreaZZD  := ZZD->(GetArea())

If nQtdEle == 0
	cSQL := " SELECT "
	cSQL += "   ZZD_LOTECT, R_E_C_N_O_ REC "
	cSQL += " 	FROM "
	cSQL += " 		ZZD010 "
	cSQL += " 		WHERE "
	cSQL += " 			ZZD_FILIAL = '"+xFilial("ZZD")+"' AND "
	cSQL += " 			ZZD_LOCAL  = '"+cLocal+"' AND "
	cSQL += " 			ZZD_LOCALI = '"+cLocali+"' AND "
	cSQL += " 			ZZD_PRODUT = '"+cProduto+"' AND "
	cSQL += " 			ZZD_TIPREG = 'I' AND "
	cSQL += " 			ZZD_QTELEI = '"+AllTrim(Str(nQtdAux))+"' AND "
	cSQL += " 			D_E_L_E_T_ = ' ' "             
	
	cSQL := ChangeQuery(cSQL)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),"QRYZZD",.T.,.T.)
	
	If !QRYZZD->(Eof())               		
		lRet := DipMonBF(cLocal,cLocali,cProduto,cLoteCt,QRYZZD->ZZD_LOTECT)
		If lRet
			ZZD->(dbGoTo(QRYZZD->REC))
			ZZD->(RecLock("ZZD",.F.))
				ZZD->ZZD_TRCLOT := "S"
			ZZD->(MsUnLock())
		EndIf
	EndIf
	QRYZZD->(dbCloseArea())
EndIf

RestArea(aAreaZZD)	          
	
Return lRet     
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DIPA067   ºAutor  ³Microsiga           º Data ³  08/25/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function DipMonBF(cLocal,cLocali,cProduto,cLoteCt,cLoteNew)                  
Local cSQL := ""
Local lRet := .F.

cSQL := " SELECT "
cSQL += "	BF_FILIAL, BF_QUANT-BF_EMPENHO QUANT, BF_LOTECTL "
cSQL += " 	FROM "
cSQL +=  		RetSQLName("SBF")
cSQL += " 		WHERE "
cSQL += " 			BF_LOCAL   = '"+cLocal+"' AND "
cSQL += " 			BF_LOCALIZ = '"+cLocali+"' AND "
cSQL += " 			BF_PRODUTO = '"+cProduto+"' AND " 
cSQL += "			BF_LOTECTL = '"+cLoteCt+"' AND "
cSQL += " 			D_E_L_E_T_ = ' ' "
               
cSQL := ChangeQuery(cSQL)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),"QRYSBF",.T.,.T.)
      
If !QRYSBF->(Eof())
	lRet := .T.
	While !QRYSBF->(Eof())
		If QRYSBF->BF_FILIAL == "01" 
			aAdd(aTrocLotM,{    cProduto,;
								cLocal,;
								cLoteCt,;
								cLocali,;
								QRYSBF->QUANT,;
								Posicione("SB8",3,xFILIAL("SB8")+cProduto+cLocal+cLoteCt,"B8_DTVALID"),;
								0,;
								cLoteNew})
		Else 
			aAdd(aTrocLotC,{    cProduto,;
								cLocal,;
								cLoteCt,;
								cLocali,;
								QRYSBF->QUANT,;
								Posicione("SB8",3,xFILIAL("SB8")+cProduto+cLocal+cLoteCt,"B8_DTVALID"),;
								0,;
								cLoteNew})
		EndIf
		QRYSBF->(dbSkip())
	EndDo
EndIf
QRYSBF->(dbCloseArea())
    
Return lRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DIPA067   ºAutor  ³Microsiga           º Data ³  08/27/15   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function VldCxEmb(nQtd,nQtdEle,cVldCxE,cTpEmbV,nQtdEmb,nQtdSec)
Local lCancel := .F.
Local nQtdAux := 0

If nQtd > nQtdEle
	nQtdAux := nQtd-nQtdEle
Else                       
	nQtdAux := nQtdEle-nQtd
EndIf

If !Empty(cVldCxE)
	If cTpEmbV=="1"
		lCancel := Mod(nQtdAux,nQtdEmb)>0
	ElseIf cTpEmbV=="2"
		lCancel := Mod(nQtdAux,nQtdSec)>0
	EndIf
EndIf

Return lCancel

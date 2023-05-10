#INCLUDE "PROTHEUS.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณNOVO5     บAutor  ณMicrosiga           บ Data ณ  01/18/13   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function RevertInv()
Local cPerg 	:= "DIPSD3"   
Local cSQL  	:= ""
Local _cDipFil  := IIf(cFilAnt=='01','04','01')   
Local lRet 		:= .F.
Local nQtdSB7 	:= 0
Local nQtdZZ6 	:= 0
Private aDadosReq := {}
Private aRegSD3 := {}
Private aCabSD3 := {}
Private aRegSDA := {}                  
Private cDocSD3   := ""      

If !(Upper(U_DipUsr()) $ 'MCANUTO/DDOMINGOS/VQUEIROZ/VEGON/RBORGES')
	Aviso("Aten็a๕","Usuแrio sem permissใo para executar a rotina.",{"Ok"},1)
	Return .F.	
EndIf

If cEmpAnt+cFilAnt<>'0101'
	Aviso("Aten็a๕","Executar a rotina na filial MTZ - 01",{"Ok"},1)
	Return .F.
EndIf

AjustaSX1(cPerg)	

If !Pergunte(cPerg,.T.)
	Return	
EndIf                      

Conout("Estorno do Inventario inicio -> Data-"+DtoC(ddatabase)+" Hora-"+Time())   

cSQL := " SELECT D3_NUMLOTE, D3_LOCAL, D3_LOCALIZ, D3_DOC, D3_COD, D3_NUMSERI, D3_LOTECTL, D3_QUANT "
cSQL += " FROM "+RetSQLName("SD3")
cSQL += " WHERE D3_FILIAL = '"+xFilial("SD3")+"' "
cSQL += " AND D3_DOC = '"+AllTrim(MV_PAR01)+"' "        
cSQL += " AND D3_TM = '501' "
cSQL += " AND D_E_L_E_T_ = ' ' "
cSQL += " ORDER BY D3_LOCALIZ, D3_COD, D3_LOTECTL "

cSQL := ChangeQuery(cSQL)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),"QRYSD3",.T.,.T.)

TCSETFIELD("QRYSD3","D3_QUANT","N",12,2)               

ZZ6->(dbSetOrder(1))    
SB7->(dbSetOrder(1))
While !QRYSD3->(Eof())
	                                                
	If SB7->(dbSeek(_cDipFil+DtoS(mv_par02)+QRYSD3->(D3_COD+D3_LOCAL+D3_LOCALIZ+D3_NUMSERI+D3_LOTECTL+D3_NUMLOTE)))
		If SB7->B7_QUANT > 0
			nQtdSB7 := 0
			nQtdZZ6 := 0
		
			nQtdSB7 := SB7->B7_QUANT
		
			If ZZ6->(dbSeek(_cDipFil+QRYSD3->(D3_LOCAL+D3_LOCALIZ+D3_COD+D3_NUMSERI+D3_LOTECTL)))
				nQtdZZ6 := ZZ6->ZZ6_QUANT //Quantidade que existia no CD antes da transfer๊ncia                                                                           
				                            
				If nQtdSB7 > nQtdZZ6 .And. nQtdSB7-nQtdZZ6 > QRYSD3->D3_QUANT   
					Aadd(aDadosReq,{	QRYSD3->D3_COD,;
										QRYSD3->D3_LOCAL,;
										QRYSD3->D3_LOTECTL,;
										QRYSD3->D3_LOCALIZ,;
										QRYSD3->D3_QUANT ,;
										Posicione("SB8",3,xFILIAL("SB8")+QRYSD3->D3_COD+QRYSD3->D3_LOCAL+QRYSD3->D3_LOTECTL,"B8_DTVALID"),;
										0})				
				ElseIf nQtdSB7 > nQtdZZ6 
					Aadd(aDadosReq,{	QRYSD3->D3_COD,;
										QRYSD3->D3_LOCAL,;
										QRYSD3->D3_LOTECTL,;
										QRYSD3->D3_LOCALIZ,;
										nQtdSB7-nQtdZZ6,;
										Posicione("SB8",3,xFILIAL("SB8")+QRYSD3->D3_COD+QRYSD3->D3_LOCAL+QRYSD3->D3_LOTECTL,"B8_DTVALID"),;
										0})						
				EndIf                                           
				
			Else
			                                                
				Aadd(aDadosReq,{	QRYSD3->D3_COD,;
									QRYSD3->D3_LOCAL,;
									QRYSD3->D3_LOTECTL,;
									QRYSD3->D3_LOCALIZ,;
									nQtdSB7,;
									Posicione("SB8",3,xFILIAL("SB8")+QRYSD3->D3_COD+QRYSD3->D3_LOCAL+QRYSD3->D3_LOTECTL,"B8_DTVALID"),;
									0})						
			EndIf
		EndIf
	Else
		Aadd(aDadosReq,{	QRYSD3->D3_COD,;
							QRYSD3->D3_LOCAL,;
							QRYSD3->D3_LOTECTL,;
							QRYSD3->D3_LOCALIZ,;
							QRYSD3->D3_QUANT,;
							Posicione("SB8",3,xFILIAL("SB8")+QRYSD3->D3_COD+QRYSD3->D3_LOCAL+QRYSD3->D3_LOTECTL,"B8_DTVALID"),;
							0})									
	EndIf		
				
	QRYSD3->(dbSkip())
	
EndDo            
QRYSD3->(dbCloseArea())
                    
aAreaSD3 := SD3->(GetArea())

cDocSD3 := "RETINV000"
SD3->(DbSetOrder(8))
If SD3->(dbSeek(xFilial("SD3")+cDocSD3))
	While !SD3->(Eof()) .And. SD3->(dbSeek(xFilial("SD3")+cDocSD3))
		cDocSD3 := Soma1(cDocSD3)
		SD3->(dbSkip())
	EndDo
EndIf            
          
RestArea(aAreaSD3)

Begin Transaction
Begin Sequence

If cEmpAnt+cFilAnt == '0104'
	GetEmpr('0101')
Else
	GetEmpr('0104')
Endif

Processa({|lEnd| lRet := u_fGeraSD3("501",aDadosReq,cDocSD3)},"Efetuando a requisi็ใo do Produto...")

If cEmpAnt+cFilAnt == '0104'
	GetEmpr('0101')
Else
	GetEmpr('0104')
Endif

If lRet
	Processa({|lEnd| lRet := u_fGeraSD3("497",aDadosReq,cDocSD3)},"Efetuando a entrada do Produto...")
EndIf

If lRet
	Processa({|lEnd| lRet := u_fEnder53(cDocSD3)},"Efetuando o endere็amento do Produto..")
EndIf

If !lRet
	If InTransact()
		DisarmTransaction()
	EndIf
	Break
EndIf

End Sequence
End Transaction

Conout("Estorno do Inventario final -> Data-"+DtoC(ddatabase)+" Hora-"+Time())   

Return
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

aAdd(aRegs,{cPerg,"01","Documento? ","","","mv_ch1","C", 9,0,0,"G","","MV_PAR01","","","","","","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"02","Dt.Invent.?","","","mv_ch2","D", 8,0,0,"G","","MV_PAR02","","","","","","","","","","","","","","","","","","","","","","","","",""})

PlsVldPerg( aRegs )       

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณREVERTINV บAutor  ณMicrosiga           บ Data ณ  01/21/13   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function DipSD3XB(cCod)
Local lRet 	 := .F.
DEFAULT cCod := ""

If aScan(aDocSD3, {|x| x == AllTrim(cCod)}) == 0
	aAdd(aDocSD3, AllTrim(cCod))   
	lRet := .T.
EndIf
 
Return lRet
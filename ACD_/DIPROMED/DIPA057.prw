#INCLUDE "PROTHEUS.CH"
#INCLUDE "APVT100.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณNOVO20    บAutor  ณMicrosiga           บ Data ณ  11/30/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function DIPA057()
Local aTela   := {}           
Local aItens  := {}
Local nPos	  := 0
Local aFields := {"ZZ5_PEDIDO","ZZ5_ORDSEP","ZZ5_EXPED1","ZZ5_TIPOTM"}
Local aSize   := {20,20,20,20}
Local aHeader := {'Pedido','Ordem Sep.','Expedicao',"Tipo Sep."}
Local cExped  := Space(120)
Local cSQL	  := ""            
Local lConf	  := .T.
Local lImpPL  := .F.
dbSelectArea("ZZ5")

aTela := VtSave()

VtClear()
    
cSQL := " SELECT ZZ5_PEDIDO, ZZ5_ORDSEP, ZZ5_EXPED1, ZZ5_TIPOTM "
cSQL += " FROM "+RetSQLName("ZZ5")                              
cSQL += " WHERE ZZ5_FILIAL = '"+xFilial("ZZ5")+"' "
cSQL += " AND ZZ5_CONSOL = ' ' "     
cSQL += " AND ZZ5_NOTA = ' ' "
cSQL += " AND ZZ5_STATUS = '3' 
cSQL += " AND RTRIM(ZZ5_TIPOTM) <> 'T้rreo' "
cSQL += " AND D_E_L_E_T_ = ' ' "

//cCond := '((ZZ5_STATUS$"1/2" .And. !Empty(ZZ5_EXPED1) .And. AllTrim(ZZ5_TIPOTM)="T้rreo/Mezanino" ) .Or. '
//cCond += ' (ZZ5_STATUS$"2/3" .And. AllTrim(ZZ5_TIPOTM)="Mezanino")) .And. Empty(ZZ5_NOTA) .And. Empty(ZZ5_CONSOL)'
cSQL := ChangeQuery(cSQL)          
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),"ZZ5TRB",.T.,.T.)

ZZ5TRB->(dbEval({|| aAdd(aItens, {ZZ5TRB->ZZ5_PEDIDO,ZZ5TRB->ZZ5_ORDSEP,ZZ5TRB->ZZ5_EXPED1,ZZ5TRB->ZZ5_TIPOTM})}))


ZZ5TRB->(dbCloseArea())     


//nRec := VTDBBrowse(0,0,VTMaxRow(),VTMaxCol(),"ZZ5",aHeader,aFields,aSize,nil,cTop,cBottom)
nPos := VTABrowse(0,0,VTMaxRow(),VTMaxCol(),aHeader,aItens,aSize)

If nPos > 0 .And. Len(aItens) > 0
	ZZ5->(dbSetOrder(1))
	If ZZ5->(dbSeek(xFilial("ZZ5")+aItens[nPos,1]+aItens[nPos,2]))
	
		VTClear()  
		
		If AllTrim(aItens[nPos,4]) == 'T้rreo/Mezanino'
			
			@ 0,0 VtSay "Consolide os itens"
			@ 1,0 VtSay "do mezanino na(s)"
			@ 2,0 VtSay "expedicao(oes): "
			@ 3,0 VtSay AllTrim(ZZ5->ZZ5_EXPED1)
			@ 4,0 VTPause "Enter para continuar
			
			If !VTYesNo("Confirma a expedi็ใo?"+chr(10)+chr(13)+AllTrim(ZZ5->ZZ5_EXPED1),"Aten็ใo",.T.)
				If VtLastKey() == 27
					Return .f.
				EndIf		   			
				While Empty(cExped)
					@ 0,0 VtSay "Informe o numero da"
					@ 1,0 VtSay "expedicao. (Se foi "
					@ 2,0 VtSay "utilizada mais de "
					@ 3,0 VtSay "uma expedicao,
					@ 4,0 VtSay	"informe os codigos "
					@ 5,0 VtSay	"separados por /. "
					@ 6,0 VtSay	"Ex.: 001/002)"
					@ 7,0 VtGet cExped Pict "@!"
					
					VTRead

					If VtLastKey() == 27
						Return .f.
					EndIf					
				EndDo
			EndIf
		Else
			While Empty(cExped)
				@ 0,0 VtSay "Informe o numero da"
				@ 1,0 VtSay "expedicao. (Se foi "
				@ 2,0 VtSay "utilizada mais de "
				@ 3,0 VtSay "uma expedicao,
				@ 4,0 VtSay	"informe os codigos "
				@ 5,0 VtSay	"separados por /. "
				@ 6,0 VtSay	"Ex.: 001/002)"
				@ 7,0 VtGet cExped Pict "@!"
				
				VTRead
				
				If VtLastKey() == 27
					Return .f.
				EndIf
			EndDo
		EndIf
		                    
		CB7->(dbSetOrder(2))
		If CB7->(dbSeek(xFilial("CB7")+ZZ5->ZZ5_PEDIDO))
			While !CB7->(Eof()) .And. CB7->CB7_PEDIDO = ZZ5->ZZ5_PEDIDO
				
				If lConf
					lConf := CB7->CB7_STATUS >= "4"
				EndIf
				
				CB7->(dbSkip())
			EndDo
		EndIf
	
		ZZ5->(RecLock("ZZ5",.F.))
			If !Empty(cExped)
				ZZ5->ZZ5_EXPED2 := ZZ5->ZZ5_EXPED1
				ZZ5->ZZ5_EXPED1 := cExped
			EndIf  
			      
			If lConf 
				ZZ5->ZZ5_STATUS := "4"            
				lImpPL := .T.
			Else
				ZZ5->ZZ5_STATUS := "2"
			EndIf         
			
			ZZ5->ZZ5_CONSOL := CB1->(POSICIONE("CB1",2,xFilial("CB1")+RetCodUsr(),"CB1_XCODSC"))

			If Empty(ZZ5->ZZ5_CONSOL)
				ZZ5->ZZ5_CONSOL := "XX"
			EndIf
		ZZ5->(MsUnlock())
	EndIf
EndIf

If lImpPL
	U_ImpPL(ZZ5->ZZ5_PEDIDO,ZZ5->ZZ5_EXPED1,ZZ5->ZZ5_ORDSEP,ZZ5->ZZ5_CONFER)
EndIf

VTClear()

VtRestore(,,,,aTela)

Return
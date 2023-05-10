
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDIPG019   บAutor  ณMAXIMO         บ Data ณ  21/07/09        บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Valida altera็ใo do tipodip (Or็amento/Programa็ใo/Pedido  บฑฑ
ฑฑบ Utilizado no campo C5_TIPODIP para tratamento no MTA410               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/


#Include "RwMake.ch"

User Function DIPG019(cGatilho)
Local _xAlias  := GetArea()                                                                
Local _nPosNF  := aScan(aHeader,{|x| AllTrim(x[2])  == 'C6_NOTA'})    
Local _nPosTipo:= aScan(aHeader,{|x| AllTrim(x[2])  == 'C6_TIPODIP'}) 
Local _nPosBlq := aScan(aHeader,{ |x| Alltrim(x[2]) == "C6_BLQ"}) // Maximo - Bloqueio de pedido - MCVN - 22/07/09 
Local _nPosQtdLib:= aScan(aHeader,{|x| Alltrim(x[2])== "C6_QTDLIB"}) // Maximo - Quantidade liberada - MCVN - 22/07/09 
Local _nPosQOrc:= aScan(aHeader,{|x| Alltrim(x[2])  == "C6_QTDORC"}) // Maximo - campo de quantidade orcada -22/07/2009
Local _nPosQtdVen:= aScan(aHeader,{|x| Alltrim(x[2])== "C6_QTDVEN"}) // Maximo - campo de quantidade orcada -22/07/2009
Local _lRet    := .T.

U_DIPPROC(ProcName(0),U_DipUsr()) // MCVN 29/09/08 - Gravando o nome do Programa no SZU

If !"TMK" $ FUNNAME() 

	If  Type("l410Auto") <> "U" .and. l410Auto
		_lRet := .t.
		Return(_lRet)
	EndIf                                                           

	If Inclui
		aCols[1,_nPosTipo]:="1"
	   	For _x :=1 to Len(aCols)
		   	aCols[_x,_nPosTipo] := M->C5_TIPODIP
			M->C6_TIPODIP       := M->C5_TIPODIP
			If M->C5_TIPODIP == "2" .or. M->C5_TIPODIP == "3"
				aCols[_x,_nPosBlq] := "S" 
				aCols[_x,_nPosQtdLib] := 0
				If M->C5_TIPODIP == "2"
					aCols[_x,_nPosQOrc]:=aCols[_x,_nPosQtdVen]				 
				Endif
			Else                        
				aCols[_x,_nPosBlq] := "N"
				aCols[_x,_nPosQOrc]:=0   // MCVN - 28/07/09
			Endif
		Next	    			
	ElseIf Altera
   		
		If M->C5_TIPODIP <> SC5->C5_TIPODIP .AND. SC5->C5_TIPODIP == "2" .and. Len(acols) > 0   	

			For _x :=1 to Len(aCols)
				aCols[_x,_nPosTipo] := M->C5_TIPODIP
				M->C6_TIPODIP       := M->C5_TIPODIP
			Next	    			
    	
		ElseIf M->C5_TIPODIP <> SC5->C5_TIPODIP .AND. SC5->C5_TIPODIP == "3" .and. Len(acols) > 0
   	
 			For _x :=1 to Len(aCols)
				aCols[_x,_nPosTipo] := M->C5_TIPODIP
				M->C6_TIPODIP       := M->C5_TIPODIP
			Next	    			
       	
		ElseIf M->C5_TIPODIP <> SC5->C5_TIPODIP .AND. SC5->C5_TIPODIP == "1" .and. Len(acols) > 0
			For _x :=1 to Len(aCols)
				If !(Empty(aCols[_x,_nPosNF]))
					MsgBox("Este pedido foi faturado parcialmente, nใo ้ possivel alterar para or็amento ou programa็ใo! ","Atencao","OK")				
					M->C5_TIPODIP := "1"
					RETURN(M->C5_TIPODIP)
				Endif
			Next	    		
		
			If _lRet
	   			For _x :=1 to Len(aCols)
					aCols[_x,_nPosTipo] := M->C5_TIPODIP
					M->C6_TIPODIP       := M->C5_TIPODIP				
				Next	    			
			Endif
	   	ElseIf M->C5_TIPODIP <> SC5->C5_TIPODIP .AND. Empty(SC5->C5_TIPODIP) .and. Len(acols) > 0 
			If MsgBox("Altera os itens com a op็ใo escolhida? ","Atencao","YESNO")
				For _x :=1 to Len(aCols)                                                                                            		
					aCols[_x,_nPosTipo] := M->C5_TIPODIP
					M->C6_TIPODIP       := M->C5_TIPODIP				
				Next
			Endif		
		Else
			For _x :=1 to Len(aCols)                                                                                            		
				aCols[_x,_nPosTipo] := M->C5_TIPODIP
				M->C6_TIPODIP       := M->C5_TIPODIP				
			Next
		Endif         
	Endif
Endif
RestArea(_xAlias)
Return(M->C5_TIPODIP) 

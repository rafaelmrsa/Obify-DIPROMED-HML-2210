
/*
ExecBlock: 	M410ABN	
Ponto: 	Ao abandonar a digita็ใo do Pedido de Venda.
Retorno Esperado: 	Nenhum.	 
                         

ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบPrograma  ณ M410AABN บ Autor ณMaximo Canuto V. Netoบ Dataณ 10/04/07    บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Atualiza SC5 e SC6 caso o usuแrio desista da altera็ใo .   บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User function M410ABN()  

If Type("l410Auto")<>"U" .And. l410Auto
	Return
EndIf      

U_DIPPROC(ProcName(0),U_DipUsr()) // MCVN - 22/01/2009

If Altera
    
	// Voltando valor do C5_PARCIAL
	Reclock("SC5",.F.)
	SC5->C5_PARCIAL := _aABN[1]
	SC5->(MsUnLock())
	SC5->(DbCommit())  // MCVN 25/04/07

	// Voltando valor do C6_PEDCLI
	SC6->(dbSetOrder(1))
	SC6->(dbSeek(xFilial("SC5")+SC5->C5_NUM))
	Do While SC6->(!EOF()) .and. SC6->C6_FILIAL==xFilial("SC5") .and. SC6->C6_NUM == SC5->C5_NUM
	   	SC6->(RecLock('SC6',.f.))
		SC6->C6_PEDCLI := _aABN[2]
		SC6->(MsUnlock())
		SC6->(DbCommit())  // MCVN 25/04/07
	SC6->(DbSkip())
	EndDo
	
	_aABN := {}
	
EndIf
			     
Return()

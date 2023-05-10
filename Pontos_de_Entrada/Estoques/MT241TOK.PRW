/*/                   
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³MT241TOK()³ Autor ³Eriberto Elias-EE      ³ Data ³dd/mm/2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Ponte de entrada chama na confirma de uma requisicao de uma³±±
±±³          ³ movimentacao interna de saida.                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Objetivoo ³ fazer a validacao das informacoes digitada na requisicao   ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³retorno   ³ Retorna verdadeiro ou falso                                ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Especifico Faturamento Dipromed.                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³  Motivo da Alteracao                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Rafael      ³10/12/04³Coloca da Validade lote                          ³±±
±±³Jailton-JBS ³18/08/10³Desenvolvido controle de fluxo, otimizando    o  ³±±
±±³            ³        ³tempo de execucao (Begin Sequence/Break/End Se-  ³±±
±±³            ³        ³quence).                                         ³±±
±±³            ³        ³                                                 ³±±
±±³Jailton-JBS ³18/08/10³Validando quando chamado de forma automatica para³±±
±±³            ³        ³nao executar validacoes                          ³±±
±±³            ³        ³                                                 ³±±
±±³Jailton-JBS ³18/08/10³Nao abrir qet para observacao quando chamado de  ³±±
±±³            ³        ³forma automatica.                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function MT241TOK()

Local _cD3_Explic := ""
Local _lRetorno	  := .T.
   
U_DIPPROC(ProcName(0),U_DipUsr()) // JBS 05/10/2005 - Gravando o nome do Programa no SZU

Begin Sequence
    //-------------------------------------------------------------------------------------------------
    // JBS 18/08/2010 - Se programa MATA241 estiver rodando de forma automatica,
    // ignora as criticas. Pq a rotina automatica ja vai contemplar todas as 
    // situacoes necessarias - DIPA046.
    //-------------------------------------------------------------------------------------------------
	If Type("l241Auto") <> "U" .And. l241Auto
		Break
	EndIf
	
	For ee := 1 to Len(aCols)
		// VERIFICAÇÃO DO LOTE
		DbSelectArea("SB1")
		DbSetOrder(1)
		DbSeek(xFilial("SB1")+aCols[ee,aScan(aHeader, { |x| Alltrim(x[2]) == "D3_COD"})])
		If Rastro(SB1->B1_COD) .and. ;
			Empty(aCols[ee,aScan(aHeader, { |x| Alltrim(x[2]) == "D3_LOTECTL"})]) .AND. CTM <> '497'
			MsgInfo("Preencha o campo Lote. "+SB1->B1_COD,"Atenção!!!")
			_lRetorno := .F. 
			Break  // JBS 18/08/2010
		EndIf
		
		// VERIFICAÇÃO DA DATA DE VALIDADE   MCVN - 03/10/2008
		If _lRetorno .And. SB1->B1_RASTRO+SB1->B1_LOTEDIP='LS' .And. ; // Lote real
			aCols[n,aScan(aHeader, { |x| Alltrim(x[2]) == "D3_DTVALID"})] < DATE()+180 .And. ; // Validade menor que 6 meses
			CTM < '500' // Tipo de movimentação = Devolução
			
			If !(_lRetorno := U_SENHA("DTV",0,0,0)) // JBS 18/08/2010 - Verifica e se for falso, ja aborta tudo e retorna falso
	   			Break  // JBS 18/08/2010
			EndIf   
			
		Endif          
		
		nDipQtd   := aCols[ee,aScan(aHeader, { |x| Alltrim(x[2]) == "D3_QUANT"})]
                                                                                 
		If aCols[ee,aScan(aHeader,{|x|Alltrim(x[2])=="D3_LOCAL"})]=="01"
	        If !u_Dip071Vld(SB1->B1_COD,nDipQtd) 
				_lRetorno := .F. 
				Break
			EndIf		
		EndIf
	Next
	
	If _lRetorno //MCVN - 03/06/2008
		If M->DA241DATA<>DDataBase
			MSGINFO("Data de emissão incorreta, A data deve ser igual a database do sistema!")
			_lRetorno := .f.  
			Break  // JBS 18/08/2010
		EndIf
	EndIf
	
	If _lRetorno
		_cD3_Explic := U_D3_EXPLIC(M->cDOCUMENTO,"EXPLICACAO DO MOVIMENTO")
		For ee := 1 to Len(aCols)
			aCols[ee,aScan(aHeader, { |x| Alltrim(x[2]) == "D3_EXPLIC" })] := _cD3_Explic
		Next
	EndIf
	
End Sequence

Return(_lRetorno)

/*/                   
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �MT241TOK()� Autor �Eriberto Elias-EE      � Data �dd/mm/2002���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Ponte de entrada chama na confirma de uma requisicao de uma���
���          � movimentacao interna de saida.                             ���
�������������������������������������������������������������������������Ĵ��
���Objetivoo � fazer a validacao das informacoes digitada na requisicao   ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���retorno   � Retorna verdadeiro ou falso                                ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Uso       � Especifico Faturamento Dipromed.                           ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
���Programador � Data   �  Motivo da Alteracao                            ���
�������������������������������������������������������������������������Ĵ��
���Rafael      �10/12/04�Coloca da Validade lote                          ���
���Jailton-JBS �18/08/10�Desenvolvido controle de fluxo, otimizando    o  ���
���            �        �tempo de execucao (Begin Sequence/Break/End Se-  ���
���            �        �quence).                                         ���
���            �        �                                                 ���
���Jailton-JBS �18/08/10�Validando quando chamado de forma automatica para���
���            �        �nao executar validacoes                          ���
���            �        �                                                 ���
���Jailton-JBS �18/08/10�Nao abrir qet para observacao quando chamado de  ���
���            �        �forma automatica.                                ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
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
		// VERIFICA��O DO LOTE
		DbSelectArea("SB1")
		DbSetOrder(1)
		DbSeek(xFilial("SB1")+aCols[ee,aScan(aHeader, { |x| Alltrim(x[2]) == "D3_COD"})])
		If Rastro(SB1->B1_COD) .and. ;
			Empty(aCols[ee,aScan(aHeader, { |x| Alltrim(x[2]) == "D3_LOTECTL"})])
			MsgInfo("Preencha o campo Lote. "+SB1->B1_COD,"Aten��o!!!")
			_lRetorno := .F. 
			Break  // JBS 18/08/2010
		EndIf
		
		// VERIFICA��O DA DATA DE VALIDADE   MCVN - 03/10/2008
		If _lRetorno .And. SB1->B1_RASTRO+SB1->B1_LOTEDIP='LS' .And. ; // Lote real
			aCols[n,aScan(aHeader, { |x| Alltrim(x[2]) == "D3_DTVALID"})] < DATE()+180 .And. ; // Validade menor que 6 meses
			CTM < '500' // Tipo de movimenta��o = Devolu��o
			
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
			MSGINFO("Data de emiss�o incorreta, A data deve ser igual a database do sistema!")
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
/*
�����������������������������������������������������������������������������
���Programa  � TM460MNU()� Autor �Maximo Canuto V. Neto� Data� 19/03/09   ���
�������������������������������������������������������������������������͹��
���Desc.     � Altera o STATUS da solicita��o de coleta .                 ���
�����������������������������������������������������������������������������
*/

User function TM460MNU()  
Local _xAlias   := GetArea()
U_DIPPROC(ProcName(0),U_DipUsr()) // MCVN - 22/01/2009

	aadd(aRotina,{"Acerta_Status","U_TMSA460Li2",0,6,0,NIL} )//"Acerta_Status"

RestArea(_xAlias)	     
Return()
/////////////////////////////////////////////////////////////////////////////////////////////////////

/*
�����������������������������������������������������������������������������
���Programa  � TMSA460Li2()� Autor �Maximo Canuto V. Neto� Data� 19/03/09 ���
�������������������������������������������������������������������������͹��
���Desc.     � Altera o STATUS da solicita��o de coleta .                 ���
�����������������������������������������������������������������������������
*/
User Function  TMSA460Li2()
Local _xAlias   := GetArea() 
Local lCalculado := .F.
	
// Verifica se Lote foi calculado
DTP->(DbOrderNickName("SOLCOLETA"))
DTP->(DbSeek(xFilial("DTP")+DT5->DT5_NUMSOL))
If DTP->DTP_NUMSOL == DT5->DT5_NUMSOL .AND. (DTP->DTP_STATUS = "3" .Or. DTP->DTP_STATUS = "4" .Or. DTP->DTP_STATUS = "5")
    lCalculado := .T.
Endif    
DTP->( DbCloseArea() )

If 	!lCalculado
	If DT5->DT5_STATUS == "5"  // Documentos Informados
		If MsgYesNo("Esta solicita��o est� com com o Status de 'Documentos Informados'. Deseja alterar o Status para informar mais documentos(nf. Cliente?")
			RecLock('DT5',.F.)
			DT5->DT5_STATUS := "4"
			DT5->( MsUnLock()  ) 		
		Endif		
	Else
		Aviso("Aten��o","S� � poss�vel alterar o Status de uma solicita��o de coleta quando a mesma est� com o Status de 'DOCUMENTOS INFORMADOS' ",{"Ok"})
	Endif	
Else 
	Aviso("Aten��o","O Lote referente a esta solicita��o de coleta j� foi calculado, n�o � poss�vel alterar o Status!",{"Ok"})
Endif

RestArea(_xAlias)	     	
Return .T.

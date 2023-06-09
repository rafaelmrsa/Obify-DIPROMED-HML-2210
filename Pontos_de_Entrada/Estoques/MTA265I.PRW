
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �MTA265I   �Autor  �Fabio Rogerio       � Data �  09/22/06   ���
�������������������������������������������������������������������������͹��
���Desc.     �Ponto de Entrada para a reserva automatica de itens nao     ���
���          �liberados                                                   ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function MTA265I()
Local aAreaDA:= SDA->(GetArea())
Local aAreaDB:= SDB->(GetArea())
Local nI     := ParamIxb[1]
Local nPQuant:= aScan(aHeader,{|x| AllTrim(x[2]) == "DB_QUANT"})
Local nPItem := aScan(aHeader,{|x| AllTrim(x[2]) == "DB_ITEM"}) 

U_DIPPROC(ProcName(0),U_DipUsr()) //MCVN - 22/01/2009

SDB->(RecLock("SDB",.F.))
	SDB->DB_XCODUS := U_DipUsr()
SDB->(MsUnlock())

//������������������������������������������������������������������Ŀ
//�Verifica se existem pedido pendentes de reserva para cada produto.�
//�Se existir saldo realiza a reserva automatica mediante prioridade.�
//��������������������������������������������������������������������

//����������������������������Ŀ
//�Executa a rotina de Reserva.�
//������������������������������
U_DIPXRESE("ISDB","",aCols[nI,nPItem],M->DA_PRODUTO,M->DA_LOCAL,"",aCols[nI,nPQuant],"","","","",SDA->(DA_PRODUTO+DA_LOCAL+DA_NUMSEQ+DA_DOC+DA_SERIE+DA_CLIFOR+DA_LOJA)+aCols[nI,nPItem])


RestArea(aAreaDA)
RestArea(aAreaDB)

Return
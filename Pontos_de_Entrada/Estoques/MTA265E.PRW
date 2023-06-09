
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �MTA265E   �Autor  �Fabio Rogerio       � Data �  09/22/06   ���
�������������������������������������������������������������������������͹��
���Desc.     �Ponto de Entrada para a exclusao da reserva automatica      ���
���          �de itens liberados                                          ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function MTA265E()
Local aAreaDA:= SDA->(GetArea())
Local aAreaDB:= SDB->(GetArea())
Local nI     := ParamIxb[1]
Local nPQuant:= aScan(aHeader,{|x| AllTrim(x[2]) == "DB_QUANT"})
Local nPItem := aScan(aHeader,{|x| AllTrim(x[2]) == "DB_ITEM"})

U_DIPPROC(ProcName(0),U_DipUsr()) //MCVN - 22/01/2009

//������������������������������������������������������������������Ŀ
//�Verifica se existem reservas amarradas ao produto do Enderecamemto� 
//�Se existir exclui as reservas realizadas.                         �
//��������������������������������������������������������������������
//�����������������������������������Ŀ
//������������������������������Ŀ
//�Executa a exclusao da Reserva.�
//��������������������������������
U_DIPXRESE("ESDB","",aCols[nI,nPItem],M->DA_PRODUTO,M->DA_LOCAL,"",aCols[nI,nPQuant],"","","","",SDA->(DA_PRODUTO+DA_LOCAL+DA_NUMSEQ+DA_DOC+DA_SERIE+DA_CLIFOR+DA_LOJA)+aCols[nI,nPItem])

RestArea(aAreaDA)
RestArea(aAreaDB)
Return
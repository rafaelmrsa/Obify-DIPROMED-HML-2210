#include "protheus.ch"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �DIPAL70   �Autor  �Alexandro Meier     � Data �  09/30/05   ���
�������������������������������������������������������������������������͹��
���Desc.     �Cadastro de documentos                                      ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function DIPAL70()
	
	Private aRotina := {}
	Private cCadastro := "Cadastro de Documentos"
	
	U_DIPPROC(ProcName(0),U_DipUsr()) // MCVN 22/01/2009
	
	aAdd( aRotina, { "Pesquisar"  , "AxPesqui" , 0 , 1 })
	aAdd( aRotina, { "Visualizar" , "AxVisual" , 0 , 2 })
	aAdd( aRotina, { "Incluir"    , "AxInclui" , 0 , 3 })
	aAdd( aRotina, { "Alterar"    , "AxAltera" , 0 , 4 })
	aAdd( aRotina, { "Excluir"    , "u_DIP70Del" , 0 , 5 })
	
	dbSelectArea("UA7")
	dbSetOrder(1)
	dbGoTop()
	
	mBrowse(6,1,22,75,"UA7")

Return Nil        



/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �DIP70Del   �Autor  �William Ailton Mafra� Data �  10/26/05   ���
�������������������������������������������������������������������������͹��
���Desc.     � Faz a exclus�o de um documento                             ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function DIP70Del(cAlias,nReg,nOpcx)
Local cQuery
Local lRet := .T.

	cQuery	:= " SELECT COUNT(UA7.UA7_CODIGO) QUANT FROM "+ RetSQLName("UA7")+" UA7 "
	cQuery	+= " INNER JOIN  "+ RetSQLName("UA3")+" UA3 ON UA3.UA3_DOCTO = UA7.UA7_CODIGO"
	cQuery	+= " INNER JOIN  "+ RetSQLName("UA1")+" UA1 ON UA1.UA1_CODIGO = UA3.UA3_EDITAL"
	cQuery	+= " WHERE "
	cQuery	+= " UA1.D_E_L_E_T_	<> '*'	AND	UA3.D_E_L_E_T_	<> '*' AND	UA7.D_E_L_E_T_	<> '*' AND"
	cQuery	+= " UA1.UA1_FILIAL	= '" + xFilial("UA1") + "' AND UA3.UA3_FILIAL	= '" + xFilial("UA3") + "' AND UA7.UA7_FILIAL	= '" + xFilial("UA7") + "' AND "
	cQuery	+= " UA7.UA7_CODIGO = '"+UA7->UA7_CODIGO+"'"
	
//	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN", TCGENQRY(,,cQuery),"DOCTOS", .F., .T.)
	IF(DOCTOS->QUANT > 0) 
		lRet := .F.
	EndIF
	DOCTOS->( dbCloseArea() )
	DBSelectArea( "UA1" )    
	
	if(nOpcx == 5)
		if(lRet)
			AxDeleta(cAlias,nReg,nOpcx)
		Else
			MsgStop("Documento em uso.","Imposs�vel exclus�o")
		EndIF
	EndIF
Return lRet

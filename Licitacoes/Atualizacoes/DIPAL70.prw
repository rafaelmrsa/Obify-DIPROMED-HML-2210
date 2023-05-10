#include "protheus.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDIPAL70   บAutor  ณAlexandro Meier     บ Data ณ  09/30/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณCadastro de documentos                                      บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
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
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDIP70Del   บAutor  ณWilliam Ailton Mafraบ Data ณ  10/26/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Faz a exclusใo de um documento                             บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
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
			MsgStop("Documento em uso.","Impossํvel exclusใo")
		EndIF
	EndIF
Return lRet

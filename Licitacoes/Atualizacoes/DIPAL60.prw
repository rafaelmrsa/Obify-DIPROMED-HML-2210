#include "protheus.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDIPAL60   บAutor  ณAlexandro Meier     บ Data ณ  09/30/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณCadastro de cartas                                          บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function DIPAL60()

	Private aRotina := {}
	Private cCadastro := "Cadastro de Cartas"
	
	U_DIPPROC(ProcName(0),U_DipUsr()) // MCVN 22/01/2009
	
	aAdd( aRotina, { "Pesquisar"  , "AxPesqui" , 0 , 1 })
	aAdd( aRotina, { "Visualizar" , "AxVisual" , 0 , 2 })
	aAdd( aRotina, { "Incluir"    , "AxInclui" , 0 , 3 })
	aAdd( aRotina, { "Alterar"    , "AxAltera" , 0 , 4 })
	aAdd( aRotina, { "Excluir"    , "u_DIP60Del" , 0 , 5 })
	
	dbSelectArea("UA6")
	dbSetOrder(1)
	dbGoTop()
	
	mBrowse(6,1,22,75,"UA6")

Return Nil


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDIPAL60   บAutor  ณWilliam Ailton Mafraบ Data ณ  10/26/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Faz a exclusใo da carta, caso nใo tenha nenhuma amarra็ใo  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function DIP60Del(cAlias,nReg,nOpcx)
Local cQuery
Local lRet := .T.
U_DIPPROC(ProcName(0),U_DipUsr()) // MCVN 22/01/2009
	cQuery	:= " SELECT COUNT(UA6.UA6_CODIGO) QUANT FROM "+ RetSQLName("UA6")+" UA6 "
	cQuery	+= " INNER JOIN  "+ RetSQLName("UA2")+" UA2 ON UA2.UA2_CARTA = UA6.UA6_CODIGO"
	cQuery	+= " INNER JOIN  "+ RetSQLName("UA1")+" UA1 ON UA1.UA1_CODIGO = UA2.UA2_EDITAL"
	cQuery	+= " WHERE "
	cQuery	+= " UA1.D_E_L_E_T_	<> '*'	AND	UA2.D_E_L_E_T_	<> '*' AND	UA6.D_E_L_E_T_	<> '*' AND"
	cQuery	+= " UA1.UA1_FILIAL	= '" + xFilial("UA1") + "' AND UA2.UA2_FILIAL	= '" + xFilial("UA2") + "' AND UA6.UA6_FILIAL	= '" + xFilial("UA6") + "' AND "
	cQuery	+= " UA6.UA6_CODIGO = '"+UA6->UA6_CODIGO+"'"
	
//	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN", TCGENQRY(,,cQuery),"CARTAS", .F., .T.)
	IF(CARTAS->QUANT > 0) 
		lRet := .F.
	EndIF
	CARTAS->( dbCloseArea() )
	DBSelectArea( "UA1" )    
	
	if(nOpcx == 5)
		if(lRet)
			AxDeleta(cAlias,nReg,nOpcx)
		Else
			MsgStop("Carta em uso.","Impossํvel exclusใo")
		EndIF
	EndIF
Return lRet

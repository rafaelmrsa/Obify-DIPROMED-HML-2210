#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "PRTOPDEF.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} JTCAD10()
@author Dleme
@type function
@since 04/02/2021 
@version 1.0
@obs Rotina Integração Protheus
@return Nil
/*/
//-------------------------------------------------------------------

User Function JL43A002()

	Local oBrowse
	Local aArea     := GetArea()

	Private cAlias 	:= "PA0"
	Private aRotina	:= MenuDef()
	Private cTitulo := "Monitor Integração XML CT-e"
	Private aSetKey	 := {}

	dbSelectArea(cAlias)
	(cAlias)->(dbSetOrder(1)) //-- PA0_FILIAL+PA0_ID
	(cAlias)->(dbGotop())

	dbSelectArea("PA1")
	PA1->(dbSetOrder(1)) //-- PA0_FILIAL+PA0_ID

	dbSelectArea('PA0')
	oBrowse := FWmBrowse():New()
	oBrowse:SetAlias( 'PA0' )
	oBrowse:SetDescription( cTitulo )
	oBrowse:AddLegend( "PA0->PA0_STATUS == '1' ", "GREEN" , "Em Aberto " )
	oBrowse:AddLegend( "PA0->PA0_STATUS == '2' ", "BLUE"  , "Processado c/ Sucesso")
	oBrowse:AddLegend( "PA0->PA0_STATUS == '3' ", "RED"   , "Processado c/ Erro"  )
	oBrowse:AddLegend( "PA0->PA0_STATUS == '5' ", "RED"   , "Processando "  )

	oBrowse:Activate()
	//-- Finaliza as Teclas de Atalhos
	TmsKeyOff(aSetKey)

	RestArea(aArea)

Return Nil

/*/{Protheus.doc} MenuDef
//TODO Função MenuDef   
@since Mai/2020 
@version 1.0
@return Array, aRot
@type static function
/*/

Static Function MenuDef()

	Local aRot    := {}

	ADD OPTION aRot TITLE "Pesquisar"   ACTION 'PesqBrw' 		   		OPERATION 1 ACCESS 0
	ADD OPTION aRot TITLE 'Visualizar' 	ACTION 'VIEWDEF.JL43A002' 		OPERATION MODEL_OPERATION_VIEW   ACCESS 0 //OPERATION 1
	ADD OPTION aRot TITLE 'Processar ID'ACTION 'u_JL43IDE5(PA0->PA0_ID)'OPERATION 6   ACCESS 0 //OPERATION 1

Return aRot

/*/{Protheus.doc} ModelDef
//TODO Função ModelDef   
@author Gustavo Viana
@since Mai/2020 
@version 1.0
@return Objeto, oModel
@type static function 
/*/

Static Function ModelDef()

	Local oModel
	Local oStrPA0 := FWFormStruct(1,"PA0")
	Local oStrPA1 := FWFormStruct(1,"PA1", { |cCampo|  AllTrim( cCampo ) + "|" $ "|PA1_ID|PA1_SEQ|PA1_DATA|PA1_HORA|PA1_ORIGEM|PA1_RETPRC|RECNO|" } )

	oModel:= MPFormModel():New("MD_INTPROTHEUS")
	oModel:SetDescription(cTitulo)

	oModel:addFields('PA0MASTER',,oStrPA0)

	//oModel:AddGrid('PA1DETAIL','PA0MASTER', oStrPA1)
	oModel:AddGrid('PA1DETAIL','PA0MASTER', oStrPA1,,,,,{|oModel,lCopy|LoadGrid(oModel,lCopy,'PA1')} )

	oModel:SetRelation(  'PA1DETAIL' , { { 'PA1_FILIAL', 'xFilial( "PA1" )' },{ 'PA1_ID', 'PA0_ID' }  }, PA1->( IndexKey( 1 ) ) )

	oModel:SetPrimaryKey({'PA0_FILIAL', 'PA0_ID' })

Return oModel


/*/{Protheus.doc} ViewDef
//TODO Função ViewDef   
@since Mai/2020  
@version 1.0
@return Objeto, oView
@type static function
/*/

Static Function ViewDef()

	Local oModel := ModelDef()
	Local oStrPA0:= FWFormStruct(2, 'PA0')
	Local oStrPA1:= FWFormStruct(2, "PA1", { |cCampo|  AllTrim( cCampo ) + "|" $ "|PA1_ID|PA1_SEQ|PA1_DATA|PA1_HORA|PA1_ORIGEM|PA1_RETPRC|RECNO|" } )
	Local bBlock := {|| .T.}
	Local oView

	oStrPA1:RemoveField( 'PA1_ID' )
	//oStrPA1:SetProperty( "PA1_SEQ" , MVC_VIEW_WIDTH, 15 )
	// Cria o objeto de View
	oView := FWFormView():New()

	// Define qual Modelo de dados será utilizado
	oView:SetModel(oModel)

	// Adiciona no nosso View um controle do tipo formulário (antiga Enchoice)
	oView:AddField('VIEW_PA0' , oStrPA0,'PA0MASTER')

	Aadd(aSetKey, { VK_F6 , {|oView| lDetail := JLVisLog(oModel)} } )
	TmsKeyOn(aSetKey)
	oView:AddUserButton( "Detalhes" , '', {|oView|JLVisLog(oModel) } ) //-- Calcula imposto

	// Adiciona no nosso View um controle do tipo FormGrid(antiga newgetdados)
	oView:AddGrid('VIEW_PA1', oStrPA1, 'PA1DETAIL' )

	//oView:EnableTitleView('VwGridSE2',STR0134 ) //-- Títulos
	// Criar um "box" horizontal para receber algum elemento da view
	oView:CreateHorizontalBox( 'CADPA0',40)
	oView:CreateHorizontalBox( 'CADPA1',60)

	// Relaciona o ID da View com o "box" para exibicao
	oView:SetOwnerView('VIEW_PA0','CADPA0')
	oView:SetOwnerView('VIEW_PA1','CADPA1')

	// Define campos que terao Auto Incremento
	//oView:AddIncrementField( 'VIEW_PA1', 'PA1_SEQ' )

	// Liga a identificacao do componente
	//oView:EnableTitleView('VIEW_ZA2')
	oView:EnableTitleView('VIEW_PA1','Historico')
	oView:SetViewProperty('VIEW_PA0','SETCOLUMNSEPARATOR', {10})
	oView:SetCloseOnOk( bBlock )

	//oView:AddUserButton('* Monitor Integração',"",{|oView| u_GBA001MON()})

Return oView


/*/{Protheus.doc} fGetHist
	(long_description)
	@type  Static Function
	@author user
	@since 25/07/2022
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
/*/

//Static Function fGetHist(cIdPA0)

Static Function LoadGrid( oModel , lCopy , cTabela )

	Local aRet 		:= {}
	Local cQuery 	:= ""
	Local cAliasPA1	:= GetNextAlias()

	Default oModel		:= FwModelActive()
	Default lCopy		:= .F.
	Default cTabela		:= "PA1"

	// "|PA1_FILIAL|PA1_ID|PA1_SEQ|PA1_DATA|PA1_HORA|PA1_ORIGEM|PA1_RETPRC|PA1_INFXML|PA1_INFSF3|"

	cQuery := "  SELECT " + CRLF
	cQuery += "    PA1.PA1_FILIAL " + CRLF
	cQuery += "   ,PA1.PA1_ID " + CRLF
	cQuery += "   ,PA1.PA1_SEQ " + CRLF
	cQuery += "   ,PA1.PA1_DATA " + CRLF
	cQuery += "   ,PA1.PA1_HORA " + CRLF
	cQuery += "   ,PA1.PA1_ORIGEM " + CRLF
	cQuery += "   ,PA1.PA1_RETPRC " + CRLF
	cQuery += "   ,PA1.R_E_C_N_O_ RECNO " + CRLF

	cQuery += "   FROM " + RetSqlName("PA1") + " PA1 " + CRLF
	cQuery += "  WHERE PA1.PA1_FILIAL = '" + xFilial("PA1") + "' " + CRLF
	cQuery += "    AND PA1.PA1_ID     = '" + PA0->PA0_ID + "' " + CRLF
	cQuery += "    AND PA1.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "  ORDER BY " + CRLF
	cQuery += "    PA1.PA1_SEQ " + CRLF
	cQuery += "   ,PA1.PA1_DATA " + CRLF
	cQuery += "   ,PA1.PA1_HORA " + CRLF

	If Select(cAliasPA1)
		(cAliasPA1) ->(DbCloseArea())
	EndIf

	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasPA1,.F.,.T.)
	TcSetField(cAliasPA1,"PA1_DATA","D",8,0)

	aRet 	:= FWLoadByAlias( oModel, cAliasPA1 )

	(cAliasPA1)->(dbCloseArea())

Return aRet


/*/{Protheus.doc} fVisLog
//TODO Função fVisLog   
@since Mai/2020  
@version 1.0
@return Objeto, oView
@type static function
/*/

Static Function JLVisLog(oMdl)

//	Local aArea    	:= GetArea()
//	Local aAreaPA1 	:= PA1->(GetArea())
//	Local oView 	:= FWViewActive()
//	Local nOper		:= oMdl:GetOperation()
//	Local oMdlPA0 	:= oMdl:GetModel('PA0MASTER')
	Local oMdlPA1  	:= oMdl:GetModel('PA1DETAIL')
//	Local nAtu 		:= oMdlPA1:GetLine()
	Local cId	    := FwFldGet('PA0_ID')
	Local cSeq 		:= oMdlPA1:GetValue('PA1_SEQ')
	Local lRet 		:= .T.

	SaveInter()
	cCadastro := "TRACKING"

	PA1->(DbSetOrder(1))	// PA1_FILIAL+PA1_ID+PA1_SEQ                                                                                                                                       
	If PA1->(MsSeek(xFilial("PA1") + cId + cSeq))
		AxVisual( 'PA1', PA1->(Recno()), 2, /*<aAcho>*/, /*<nColMens>*/, /*<cMensagem>*/, /*<cFunc>*/, /*<aButtons>*/, .F. /*<lMaximized>*/ )
	EndIf

//	RestInter()
//	RestArea(aAreaPA1)
//	RestArea(aArea)

Return lRet






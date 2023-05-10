#INCLUDE 'PROTHEUS.CH'
#INCLUDE "RWMAKE.CH"
#INCLUDE 'FWMVCDEF.CH'
//-------------------------------------------------------------------
/*/{Protheus.doc} DIPA068
Rotina de cadastro Valores negociados

@author DSD
@since 08/12/14
@version P11
/*/
User Function DIPA068(lFiltro)
Local oBrowse                    
Private aRotina := MenuDef()
DEFAULT lFiltro := .F.

oBrowse := FWmBrowse():New()
oBrowse:SetAlias( 'ZZF' )
oBrowse:SetDescription("Valores Negociados") //'Associação x Classe'

oBrowse:AddLegend( "ZZF_ATIVO <> '1'"							  , "BLACK", "Aguardando Aprovação" )
oBrowse:AddLegend( "ZZF_DATAFI < Date() .And. !Empty(ZZF_DATAFI)" , "RED"  , "Finalizado" )
oBrowse:AddLegend( "ZZF_DATAFI >= Date() .Or. Empty(ZZF_DATAFI)"  , "GREEN", "Ativo" )

If lFiltro
	oBrowse:SetFilterDefault( "Empty(ZZF_ATIVO)" )
EndIf

oBrowse:Activate()

Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Monta o menu

@author DSD
@since 08/12/14
@version P11
/*/
Static Function MenuDef()
Local aRotina := {}

ADD OPTION aRotina Title 'Pesquisar'	  Action 'PesqBrw'          	OPERATION 1 ACCESS 0 //'Pesquisar'
ADD OPTION aRotina Title 'Visualizar'  	  Action 'VIEWDEF.DIPA068' 		OPERATION 2 ACCESS 0 //'Visualizar'
ADD OPTION aRotina Title 'Incluir'  	  Action 'VIEWDEF.DIPA068' 		OPERATION 3 ACCESS 0 //'Incluir'
ADD OPTION aRotina Title 'Alterar' 		  Action 'VIEWDEF.DIPA068'		OPERATION 4 ACCESS 0 //'Alterar'
ADD OPTION aRotina Title 'Renovar' 		  Action 'u_DipRenov'			OPERATION 7 ACCESS 0 //'Alterar'
ADD OPTION aRotina Title 'Excluir'  	  Action 'VIEWDEF.DIPA068' 		OPERATION 5 ACCESS 0 //'Excluir'

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Define o model

@author DSD
@since 08/12/14
@version P11
/*/
Static Function ModelDef()
// Cria a estrutura a ser usada no Modelo de Dados
Local oStruZZF := FWFormStruct( 1, 'ZZF', /*bAvalCampo*/, /*lViewUsado*/ )
Local oStruZZG := FWFormStruct( 1, 'ZZG', /*bAvalCampo*/, /*lViewUsado*/ )
Local oModel

// Cria o objeto do Modelo de Dados
oModel := MPFormModel():New( 'DIPA068MD',/*bPreValidacao*/,Nil,{|oModel| u_68TudoOK(oModel)}/*bTudook*/, /*bCancel*/ )

oModel:SetVldActivate( { |oModel| u_68PreOK( oModel ) } )                                         

// Adiciona ao modelo uma estrutura de formulário de edição por campo
oModel:AddFields( 'ZZFMASTER', /*cOwner*/, oStruZZF )

// Adiciona ao modelo uma estrutura de formulário de edição por grid
oModel:AddGrid( 'ZZGDETAIL', 'ZZFMASTER', oStruZZG,/*bLinePre*/,{|oStruZZG| u_68VldLn("ZZGDETAIL")}/*bLinePost*/, /*bPreVal*/,/*bPreVal*/, /*BLoad*/ )

// Faz relaciomaneto entre os compomentes do model
oModel:SetRelation( 'ZZGDETAIL', { 	{ 'ZZG_FILIAL', 'xFilial( "ZZG" )' },{ 'ZZG_CODIGO', 'ZZF_CODIGO' }},"ZZG_FILIAL+ZZG_CODIGO" )
                                               
// Indica que é opcional ter dados informados na Grid
//oModel:GetModel( 'ZZGDETAIL' ):SetOptional(.F.)

// Liga o controle de nao repeticao de linha
oModel:GetModel( 'ZZGDETAIL' ):SetUniqueLine( {'ZZG_SEQUEN'} )

// Adiciona a descricao do Modelo de Dados
oModel:SetDescription("Valores Negociados")

// Adiciona a descricao do Componente do Modelo de Dados
oModel:GetModel( 'ZZFMASTER' ):SetDescription( 'Master' )
oModel:GetModel( 'ZZGDETAIL' ):SetDescription( 'Detail' )

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Define a view

@author DSD
@since 08/12/14
@version P11
/*/
Static Function ViewDef()
// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
Local oStruZZF := FWFormStruct( 2, 'ZZF' )
Local oStruZZG := FWFormStruct( 2, 'ZZG' )
// Cria a estrutura a ser usada na View
Local oModel   := FWLoadModel( 'DIPA068' )
Local oView
Local nOpc	   := oModel:GetOperation()
           
oModel:lmodify := .T.

// Cria o objeto de View
oView := FWFormView():New()

// Define qual o Modelo de dados será utilizado
oView:SetModel( oModel )

//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
oView:AddField( 'VIEW_ZZF', oStruZZF, 'ZZFMASTER' )

//Adiciona no nosso View um controle do tipo FormGrid(antiga newgetdados)
oView:AddGrid(  'VIEW_ZZG', oStruZZG, 'ZZGDETAIL' )

oView:CreateHorizontalBox( 'SUPERIOR', 38 )
oView:CreateHorizontalBox( 'INFERIOR', 62 )

// Relaciona o ID da View com o "box" para exibicao
oView:SetOwnerView( 'VIEW_ZZF', 'SUPERIOR' )
oView:SetOwnerView( 'VIEW_ZZG', 'INFERIOR' )

// Define campos que terao Auto Incremento
oView:AddIncrementField( 'VIEW_ZZG', 'ZZG_SEQUEN' )

// Forcar o fechamento da tela ao salvar o model
oView:SetCloseOnOk({|| .T.})

Return oView     
//-------------------------------------------------------------------
/*/{Protheus.doc} 68VldLn
Validação da linha Get Dados

@author DSD
@since 08/12/14
@version P11
/*/
User Function 68VldLn(cModel)
Local lRet	 := .T.            
Local oModel := Nil
Local oStru	 := Nil
Local nLine	 := 0
 
// Obtem os dados do model
oModel 	:= FWModelActive()
oStru 	:= oModel:GetModel(cModel)
nLine 	:= oStru:GetLine()

If Empty(FwFldGet('ZZG_PRODUT',nLine)) .Or.;
   FwFldGet('ZZG_VALOR',nLine) == 0
	lRet := .F.                             
	Help( ,, 'Help',, 'Preencha todos os campos antes de adicionar outra linha.', 1, 0 ) 
EndIf                              

Return lRet
//-------------------------------------------------------------------
/*/{Protheus.doc} PreOk
Monta o menu

@author DSD
@since 27/09/13
@version P11
/*/
User Function 68PreOk(oModel)
Local lRet := .T.
Local nOpc := oModel:GetOperation()

If nOpc == 4 .And. !Empty(ZZF->ZZF_DATAFI) .And. ZZF->ZZF_DATAFI < Date()
	Help( ,, 'Help',, 'Negociação já encerrada', 1, 0 )	
	lRet := .F.
EndIf

If lRet	
	lRet := Upper(U_DipUsr())$GetNewPar("ES_DIPA068","DDOMINGOS")
	
	If !lRet
		Help( ,, 'Help',, 'Usuário sem acesso para esta solicitação. ', 1, 0 )	
	EndIf
EndIf

Return lRet       
//-------------------------------------------------------------------
/*/{Protheus.doc} 68TudoOk
Validação no Ok da tela

@author DSD
@since 18/12/14
@version P11
/*/   
User Function 68TudoOk(oModel)
Local lRet 	 := .T.
Local nOpc	 := oModel:GetOperation() 

If lRet .And. nOpc == 4                         
	If !AllTrim(Upper(u_DipUsr()))$GetNewPar("ES_USRAPRO","")     
		
		ZZF->(RecLock("ZZF",.F.))
			ZZF->ZZF_ATIVO  := ""
			ZZF->ZZF_USUAPR := ""
		ZZF->(MsUnLock())
		
		U_Dip068Mail(nOpc,"ALTERAÇÃO DE VALOR NEGOCIADO! ")  //Envio de e-mail/Cic 
	
	EndIf  
EndIf      

If lRet 
	FWFormCommit(oModel)             
EndIf

//Enviar E-mail e CIC 
If lRet .And. (nOpc == 3 ) 
	U_Dip068Mail(nOpc,"INCLUSÃO DE VALOR NEGOCIADO! ")
EndIf 

Return lRet
//-------------------------------------------------------------------
/*/{Protheus.doc} DipRenov
Validação no Ok da tela

@author DSD
@since 18/12/14
@version P11
/*/   
User Function DipRenov()   

Local nOpc := 7 

If ZZF->ZZF_ATIVO == "1" .And. ZZF->ZZF_DATAFI < Date() .And.; 
	(AllTrim(UsrFullName(RetCodUsr())) == ZZF->ZZF_USUARI .Or. Upper(u_DipUsr())$GetNewPar("ES_RENOV68","BRODRIGUES,JLIMA,DDOMINGOS"))
	
	If Aviso("Atenção","Tem certeza que quer renovar este contrato?",{"Sim","Não"},1)==1
	
		ZZF->(RecLock("ZZF",.F.))
			ZZF->ZZF_ATIVO  := ""
			ZZF->ZZF_USUAPR := ""
			ZZF->ZZF_DATAFI := STOD("")
		ZZF->(MsUnLock())

		U_Dip068Mail(nOpc,"RENOVAÇÃO DE VALOR NEGOCIADO! ")  //Envio de e-mail/Cic	

	EndIf



Else
	Aviso("Atenção","Renovação não permitida. Verifique a data e o usuário",{"Ok"},1)
EndIf             

Return 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  Dip068Mail  ºAutor  ³Microsiga           º Data ³  01/07/22  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function Dip068Mail(_nOpc,cAssunt)
Local _cQry0    := " "
Local cPost     := Lower(Alltrim(Posicione("SU7",4,xFilial("SU7") + RetCodUsr(),"U7_POSTO"))) 
Local _aDsMaCic := {}
Local cCicDe    := " "
Local cEmail    := " "
Local nOpc      := _nOpc
Local j
Local aMsg      := {}
Local cTiMail   := EncodeUTF8("VALOR NEGOCIADO","cp1252")
Local cFuncSent := "DIPA068(Dip068Mail)"
Local cDe       := Lower(Alltrim(Posicione("SU7",4,xFilial("SU7") + RetCodUsr(),"U7_EMAIL"))) 
Local cMail     := ""
Local cTipSoli  := "1" 
Local cOperador := Lower(Alltrim(Posicione("SU7",4,xFilial("SU7") + RetCodUsr(),"U7_COD"))) 
#DEFINE CR    chr(13)+chr(10)

_cQry0 :=" SELECT ZS_CIC, ZS_EMAIL "
_cQry0 +=" FROM "+RETSQLNAME ("SZS") + " SZS "
_cQry0 +=" WHERE  '"+cTipSoli+"' = SUBSTRING(ZS_TPAPROV,1,1) "
_cQry0 +=" AND ZS_FILIAL     				 =  '' "
_cQry0 +=" AND RTRIM(LTRIM(ZS_STATUS))       =  'AUTORIZADO' "
_cQry0 +=" AND D_E_L_E_T_    				 =  ' ' "
_cQry0 +=" GROUP BY ZS_CIC, ZS_EMAIL "

dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQry0),'TMP4',.T.,.F.)

While TMP4->(!EOF())
	aAdd(_aDsMaCic,{ALLTRIM(TMP4->ZS_CIC),ALLTRIM(TMP4->ZS_EMAIL)})
	TMP4->( dbSkip())
EndDo
TMP4->(DBCloseArea())
                                                                    
If Len(_aDsMaCic)==0                                               
	aAdd(_aDsMaCic,{"MAXIMO.CANUTO","maximo@dipromed.com.br"})
EndIf

For j := 1 To Len(_aDsMaCic) 
	If Len(_aDsMaCic[j]) > 1
		cCicDe  := _aDsMaCic[j,1]+" , "+ cCicDe
		cEmail  := _aDsMaCic[j,2]+" ; "+cEmail 
	Else 
		cCicDe  := _aDsMaCic[j,1]
	EndIf
Next j

Do Case
	Case "1" $ cPost
		cPost:= cPost+" - APOIO"
	Case "2" $ cPost
		cPost:= cPost+" - TELEVENDAS"
	Case "3" $ cPost
		cPost:= cPost+" - LICITAÇÃO"
	Case "4" $ cPost
		cPost:= cPost+" - SAC"
	Case "5" $ cPost
		cPost:= cPost+" - COBRANÇA"
	Case "6" $ cPost
		cPost:= cPost+" - HQ"
	OtherWise
		cPost:= cPost+" - OUTROS"
EndCase

If !Empty(cEmail)
	// Monta a email a ser enviado ao operador
	aadd(aMsg,{"Operação",cAssunt})	
	aadd(aMsg,{"Numero da SOlicitação",alltrim(ZZF->ZZF_CODIGO)})
	
	If !Empty(alltrim(ZZF->ZZF_CODCLI))
		aadd(aMsg,{"Cliente ",ZZF->ZZF_CODCLI+" - "+alltrim(POSICIONE("SA1", 1, XFILIAL("SA1")+ZZF->ZZF_CODCLI, "A1_NREDUZ"))})
	Else
		aadd(aMsg,{"Grupo ",ZZF->ZZF_GRPVEN+" - "+AllTrim(Posicione('ACY',1,xFilial('ACY')+ZZF->ZZF_GRPVEN,'ACY_DESCRI'))})
	Endif
	aadd(aMsg,{"Contrato ",ZZF->ZZF_CONTRA})
	aadd(aMsg,{"Explicação ",ZZF->ZZF_EXPLIC})
	aadd(aMsg,{"Operador",cOperador+" - "+ALLTRIM(CAPITAL( Posicione("SU7",1,xFilial("SU7") + cOperador, "U7_NOME") ))})
	aadd(aMsg,{"Posto",cPost})

	
	u_UEnvMail(cEmail,cTiMail,aMsg,"",cDe,cFuncSent) //envia e-mail
EndIf

// Monta a mensagem a ser enviado ao operador
cMail := "AVISO IMPORTANTE"+CR+CR

	If nOpc == 3
		cMail += "Inclusão do Valor Negociado!" +CR+CR
	ElseIf nOpc == 4
		cMail += "Alteração do Valor Negociado!" +CR+CR
	ElseIf nOpc == 7
		cMail += "Renovação do Valor Negociado!" +CR+CR
	EndIf

cMail += "O valor negociado : "+alltrim(ZZF->ZZF_CODIGO)+CR+CR
cMail += "Aguarda aprovação digital.!! "+CR+CR
cMail += u_DipUsr()

U_DIPCIC(cMail,AllTrim(cCicDe))

Return()

#INCLUDE 'PROTHEUS.CH'
#INCLUDE "RWMAKE.CH"
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE "FWMBROWSE.CH"
//-------------------------------------------------------------------
/*/{Protheus.doc} DIPA060
Rotina de cadastro Requisição de Materiais

@author DSD
@since 27/09/13
@version P11
/*/
User Function DIPA060()
Local oBrowse

Private nOpcEsp := 0

oBrowse := FWmBrowse():New()
oBrowse:SetAlias( 'ZZ8' )
oBrowse:SetDescription("Requisição de Materiais") //'Associação x Classe'

oBrowse:AddLegend( "ZZ8_STATUS == 0"						 						, "RED"  	, "Aguardando Empenho"		)
oBrowse:AddLegend( "ZZ8_STATUS == 1 .And. ZZ8_IMPRES <> 'S' .And. Empty(ZZ8_XSTCB7)", "BLUE"   	, "Empenho Realizado" 		)
oBrowse:AddLegend( "ZZ8_STATUS == 1 .And. ZZ8_IMPRES == 'S' .And. Empty(ZZ8_XSTCB7)", "ORANGE" 	, "Empenho Impresso " 		)
oBrowse:AddLegend( "ZZ8_STATUS == 1 .And. ZZ8_XSTCB7 == '0' "						, "YELLOW" 	, "Separando " 		  		)
oBrowse:AddLegend( "ZZ8_STATUS == 1 .And. ZZ8_XSTCB7 == '1' "						, "WHITE" 	, "Conferindo " 			)
oBrowse:AddLegend( "ZZ8_STATUS == 1 .And. ZZ8_XSTCB7 == '2' "						, "BLACK" 	, "Pronto para finalizar " 	)
oBrowse:AddLegend( "ZZ8_STATUS == 2"												, "GREEN"	, "Finalizado" 				)

oBrowse:Activate()

Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Monta o menu

@author DSD
@since 27/09/13
@version P11
/*/
Static Function MenuDef()
Local aRotina := {}

ADD OPTION aRotina Title 'Pesquisar'	  Action 'PesqBrw'          	OPERATION 1 ACCESS 0 //'Pesquisar'
ADD OPTION aRotina Title 'Visualizar'  	  Action 'VIEWDEF.DIPA060' 		OPERATION 2 ACCESS 0 //'Visualizar'
ADD OPTION aRotina Title 'Incluir'  	  Action 'VIEWDEF.DIPA060' 		OPERATION 3 ACCESS 0 //'Incluir'
ADD OPTION aRotina Title 'Alterar' 		  Action 'VIEWDEF.DIPA060'		OPERATION 4 ACCESS 0 //'Alterar'
ADD OPTION aRotina Title 'Gera Empenho'   Action 'U_DipGerEmp()'		OPERATION 6 ACCESS 0 //'Gera Empenho'
ADD OPTION aRotina Title 'Finalizar' 	  Action 'U_DipBxEst()'			OPERATION 6 ACCESS 0 //'Finalizar'
ADD OPTION aRotina Title 'Excluir'  	  Action 'U_DipExcOP()' 		OPERATION 5 ACCESS 0 //'Excluir'
ADD OPTION aRotina Title 'Exclui Empenho' Action 'U_DipExcEmp()' 		OPERATION 5 ACCESS 0 //'Exclui '
ADD OPTION aRotina Title 'Imprime'  	  Action 'U_DipImpZZ9(1)' 		OPERATION 6 ACCESS 0 
ADD OPTION aRotina Title 'Requisição PCP' Action 'U_DIPA078()' 	    	OPERATION 4 ACCESS 0 
ADD OPTION aRotina Title 'Gera O.S. MP'   Action 'U_GeraOSMP()' 	   	OPERATION 4 ACCESS 0

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Define o model

@author DSD
@since 27/09/13
@version P11
/*/
Static Function ModelDef()
// Cria a estrutura a ser usada no Modelo de Dados
Local oStruZZ8 := FWFormStruct( 1, 'ZZ8', /*bAvalCampo*/, /*lViewUsado*/ )
Local oStruZZ9 := FWFormStruct( 1, 'ZZ9', /*bAvalCampo*/, /*lViewUsado*/ )
Local oModel

// Cria o objeto do Modelo de Dados
oModel := MPFormModel():New( 'DIPA060MD',/*bPreValidacao*/,Nil,{|oModel| D060TudoOk(oModel)}, /*bCancel*/ )

oModel:SetVldActivate( { |oModel| u_PreOK( oModel ) } )                                         

// Adiciona ao modelo uma estrutura de formulário de edição por campo
oModel:AddFields( 'ZZ8MASTER', /*cOwner*/, oStruZZ8 )

// Adiciona ao modelo uma estrutura de formulário de edição por grid
oModel:AddGrid( 'ZZ9DETAIL', 'ZZ8MASTER', oStruZZ9,/*bLinePre*/,{|oStruZZ9| u_VldLine("ZZ9DETAIL")}/*bLinePost*/, /*bPreVal*/,/*bPreVal*/, /*BLoad*/ )

// Faz relaciomaneto entre os compomentes do model
oModel:SetRelation( 'ZZ9DETAIL', { 	{ 'ZZ9_FILIAL', 'xFilial( "ZZ9" )' },{ 'ZZ9_REQMAT', 'ZZ8_REQMAT' }},"ZZ9_FILIAL+ZZ9_REQMAT" )
                                               
// Indica que é opcional ter dados informados na Grid
oModel:GetModel( 'ZZ9DETAIL' ):SetOptional(.T.)

// Liga o controle de nao repeticao de linha
oModel:GetModel( 'ZZ9DETAIL' ):SetUniqueLine( {'ZZ9_SEQUEN'} )

// Adiciona a descricao do Modelo de Dados
oModel:SetDescription("Requisição de Materiais")

// Adiciona a descricao do Componente do Modelo de Dados
oModel:GetModel( 'ZZ8MASTER' ):SetDescription( 'Master' )
oModel:GetModel( 'ZZ9DETAIL' ):SetDescription( 'Detail' )

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Define a view

@author DSD
@since 27/09/13
@version P11
/*/
Static Function ViewDef()
// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
Local oStruZZ8 := FWFormStruct( 2, 'ZZ8' )
Local oStruZZ9 := FWFormStruct( 2, 'ZZ9' )
// Cria a estrutura a ser usada na View
Local oModel   := FWLoadModel( 'DIPA060' )
Local oView
Local nOpc	   := oModel:GetOperation()
           
oModel:lmodify := .T.

// Cria o objeto de View
oView := FWFormView():New()

// Define qual o Modelo de dados será utilizado
oView:SetModel( oModel )

//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
oView:AddField( 'VIEW_ZZ8', oStruZZ8, 'ZZ8MASTER' )

//Adiciona no nosso View um controle do tipo FormGrid(antiga newgetdados)
oView:AddGrid(  'VIEW_ZZ9', oStruZZ9, 'ZZ9DETAIL' )

oView:CreateHorizontalBox( 'SUPERIOR', 20 )
oView:CreateHorizontalBox( 'INFERIOR', 80 )

// Relaciona o ID da View com o "box" para exibicao
oView:SetOwnerView( 'VIEW_ZZ8', 'SUPERIOR' )
oView:SetOwnerView( 'VIEW_ZZ9', 'INFERIOR' )

// Define campos que terao Auto Incremento
oView:AddIncrementField( 'VIEW_ZZ9', 'ZZ9_SEQUEN' )

// Forcar o fechamento da tela ao salvar o model
oView:SetCloseOnOk({|| .T.})

Return oView     
//-------------------------------------------------------------------
/*/{Protheus.doc} VldLine
Monta o menu

@author DSD
@since 27/09/13
@version P11
/*/
User Function VldLine(cModel)
Local lRet	 := .T.            
Local oModel := Nil
Local oStru	 := Nil
Local nLine	 := 0
 
// Obtem os dados do model
oModel 	:= FWModelActive()
oStru 	:= oModel:GetModel(cModel)
nLine 	:= oStru:GetLine()

If Empty(FwFldGet('ZZ9_CODPRO',nLine)) .Or.;
   FwFldGet('ZZ9_QTDPRO',nLine) == 0  //.Or.;
//   Empty(FwFldGet('ZZ9_LOTECT',nLine)) .Or.;
//   Empty(FwFldGet('ZZ9_LOCALI',nLine)) .Or.;
//   Empty(FwFldGet('ZZ9_LOCAL' ,nLine))  
	lRet := .F.                             
	Help( ,, 'Help',, 'Preencha todos os campos antes de adicionar outra linha.', 1, 0 ) 
EndIf                              

If lRet
	lRet := u_VldSldSB2()
EndIf

Return lRet
//-------------------------------------------------------------------
/*/{Protheus.doc} VldSldSB2
Monta o menu

@author DSD
@since 27/09/13
@version P11
/*/
User Function VldSldSB2()      
Local nSaldo 	:= 0                         
Local lRet	 	:= .T.
Local oModel 	:= Nil
Local oStru	 	:= Nil
Local nLine	 	:= 0

// Obtem os dados do model
oModel := FWModelActive()
oStru  := oModel:GetModel('ZZ9DETAIL')
nLine  := oStru:GetLine()
           
SB2->(dbSetOrder(1))
If SB2->(dbSeek(xFilial("SB2")+FwFldGet('ZZ9_CODPRO',nLine)+FwFldGet('ZZ9_LOCAL',nLine)))   
	nSaldo := U_DIPSALDSB2(FwFldGet('ZZ9_CODPRO',nLine),.T.)
	If nSaldo < FwFldGet('ZZ9_QTDPRO',nLine)                                                             
		Aviso("ATENÇÃO!","Quantidade informada maior que o saldo"+CHR(10)+CHR(13)+"disponível em estoque. Saldo - "+AllTrim(Str(nSaldo)),{"Ok"},1)
		//Comentado devido a transf entre filiais e os ajustes das quantidades que antecedem a transferência - RBorges 20/04/17.
		//Help( ,, "Help",,"Quantidade informada maior que o saldo"+CHR(10)+CHR(13)+"disponível em estoque. Saldo - "+AllTrim(Str(nSaldo)), 1, 0 ) 
		//lRet := .F.
	EndIf          
Else    
	Help( ,, "Help",,"Produto não encontrado no estoque.", 1, 0 ) 
	lRet := .F.
EndIf

Return lRet
//-------------------------------------------------------------------
/*/{Protheus.doc} D060TudoOk
Monta o menu

@author DSD
@since 27/09/13
@version P11
/*/
Static Function D060TudoOk()   
Local lRet 		:= .T.
Local lGrv		:= .F.
Local oModel 	:= Nil
Local oStru	 	:= Nil
Local nLine	 	:= 0        
Local aDipEmp	:= {}
Local nOpc		:= 0
Local cReqMat	:= ""
Local cOP		:= ""
Local lLoc03	:= .F. 
Local _dDat     := dDataBase 
Local _nHora    := SubStr(Time(),1,2)+":"+SubStr(Time(),4,2)
Local _cUsuar   := Upper(U_DipUsr())

// Obtem os dados do model
oModel 	:= FWModelActive()
cReqMat := FwFldGet('ZZ8_REQMAT')
cOP		:= FwFldGet('ZZ8_ORDPRO')

oStru  	:= oModel:GetModel('ZZ9DETAIL')
    
nOpc   	:= oModel:GetOperation()                
    
If (nOpc == 3 .Or. nOpc == 4) .and. nOpcEsp == 0
	If Aviso("Atenção","Confirma a requisição de materiais?",{"Sim","Não"},1)==1                         
		FWFormCommit(oModel)
		ZZ8->(RecLock("ZZ8",.F.))                                                  
			ZZ8->ZZ8_HRINCL := _nHora
		ZZ8->(MsUnlock())
	Else
		lRet := .F.
	EndIf
ElseIf nOpcEsp == 6 .And. ZZ8->ZZ8_STATUS == 0//FwFldGet('ZZ8_STATUS') == 0
	If Aviso("Atenção","Confirma a geração do Empenho?",{"Sim","Não"},1)==1                         
	    lGrv	:= .F.
	    nSaldo 	:= 0
	    
	    Begin Transaction
			For nI := 1 to oStru:GetQtdLine()    
				oStru:GoLine( nI )             
				If !oStru:IsDeleted()          
				
					If SB2->(dbSeek(xFilial("SB2")+FwFldGet('ZZ9_CODPRO',nI)+FwFldGet('ZZ9_LOCAL',nI)))   
						nSaldo := SaldoSB2()   
						
						If nSaldo < FwFldGet('ZZ9_QTDPRO',nI)
							Help( ,, "Help",,"Não existe quantidade suficiente para o empenho."+CHR(10)+CHR(13)+;
											"Produto ("+AllTrim(FwFldGet('ZZ9_CODPRO',nI))+"). "+CHR(10)+CHR(13)+;
											"Qtd disponível em estoque: "+AllTrim(Str(nSaldo)), 1, 0 ) 
							lGrv	:= .F.
							DisarmTransaction()
							Break
						EndIf          
						
						aDipEmp := GravaEmp(FwFldGet('ZZ9_CODPRO',nI),;	//-- 01.C¢digo do Produto
											FwFldGet('ZZ9_LOCAL' ,nI),;	//-- 02.Local
											FwFldGet('ZZ9_QTDPRO',nI),; //-- 03.Quantidade
											Nil,;			   			//-- 04.Quantidade 2UM
											Nil,;					  	//-- 05.Lote
											Nil,;		  				//-- 06.SubLote
											Nil,;  						//-- 07.Localiza‡Æo
											Nil,; 						//-- 08.Numero de S‚rie
											Nil,;      		   			//-- 09.OP
											Nil,;						//-- 10.Seq. do Empenho/Libera‡Æo do PV (Pedido de Venda)
											Nil,;   					//-- 11.PV
											Nil,;      					//-- 12.Item do PV
											'ZZ9',; 		   			//-- 13.Origem do Empenho
											Nil,;    		     		//-- 14.OP Original
											Nil,;     		    		//-- 15.Data da Entrega do Empenho
											Nil,;	 			   		//-- 16.Array para Travamento de arquivos
											.F.,;     					//-- 17.Estorna Empenho?
											Nil,;         				//-- 18.chamada da Proje‡Æo de Estoques?
											.T.,;         				//-- 19.Empenha no SB2?
											.F.,;         				//-- 20.Grava SD4?
											.T.,;         				//-- 21.Considera Lotes Vencidos?
											.T.,;         				//-- 22.Empenha no SB8/SBF?
											.T.)        				//-- 23.Cria SDC?  ==> IMPORTANTE: NAO CRIA SDC SE O PARAMETRO ANTERIOR (B2/BF) ESTIVER .F.,
		
						If FwFldGet('ZZ9_LOCAL',nI) == '03'
							lLoc03 := .T.
						EndIf
						
		                If Len(aDipEmp)>0 
			                lGrv:=.T.                                                 	
							//oModel:SetValue('ZZ8MASTER','ZZ8_STATUS',1)		                                    
							//oModel:SetValue('ZZ8MASTER','ZZ8_USUAR2',Upper(U_DipUsr()))	
		
							For nJ:=1 to Len(aDipEmp)
								ZZA->(RecLock("ZZA",.T.))
									ZZA->ZZA_FILIAL := xFilial("ZZA")
									ZZA->ZZA_REQMAT := FwFldGet('ZZ9_REQMAT',nI)
									ZZA->ZZA_SEQUEN := FwFldGet('ZZ9_SEQUEN',nI)
									ZZA->ZZA_CODPRO := FwFldGet('ZZ9_CODPRO',nI)   
									ZZA->ZZA_QTDPRO := aDipEmp[nJ,05]              
									ZZA->ZZA_QTDPR2 := ConvUm(FwFldGet('ZZ9_CODPRO',nI),aDipEmp[nJ,05],0,2 )
									ZZA->ZZA_UNDPRO := FwFldGet('ZZ9_UNDPRO',nI)   
									ZZA->ZZA_UNDPR2 := FwFldGet('ZZ9_UNDPR2',nI)   
									ZZA->ZZA_LOTECT := aDipEmp[nJ,01]
									ZZA->ZZA_LOCALI := aDipEmp[nJ,03]
									ZZA->ZZA_LOCAL  := aDipEmp[nj,11]
									ZZA->ZZA_DTVALI := aDipEmp[nj,07]
								ZZA->(MsUnlock())
							Next nJ
						EndIf
					EndIf
				EndIf	    
			Next nI  			
			If lGrv         
				//oModel:nOperation := 3 // Volto para 3 para gravar na função commit
				//FWFormCommit(oModel)
				ZZ8->(RecLock("ZZ8",.F.)) 
					ZZ8->ZZ8_STATUS := 1                                                 
					ZZ8->ZZ8_USUAR4 := _cUsuar
					ZZ8->ZZ8_DATEMP := _dDat
					ZZ8->ZZ8_HREMPE := _nHora
				ZZ8->(MsUnlock())
				
				cReqMat := ZZ8->ZZ8_REQMAT
				cOP		:= ZZ8->ZZ8_ORDPRO
			EndIf
		End Transaction
	Else                                
		lRet := .F.
	EndIf                                         
ElseIf nOpcEsp == 6 .And. ZZ8->ZZ8_STATUS == 1//FwFldGet('ZZ8_STATUS') == 1
	DipFinOP(oModel)
ElseIf nOpcEsp==5 .And. ZZ8->ZZ8_STATUS < 2 //FwFldGet('ZZ8_STATUS') < 2
	If ZZ8->ZZ8_STATUS == 1 //FwFldGet('ZZ8_STATUS') == 1
		If Aviso("Atenção","Confirma a exclusão do Empenho?",{"Sim","Não"},1)==1
			oModel:nOperation := 3 // Volto para 3 para gravar na função commit
			ZZA->(dbSetOrder(1))
			If ZZA->(dbSeek(xFilial("ZZA")+ZZ8->ZZ8_REQMAT/*FwFldGet('ZZ8_REQMAT')*/))       
				While !ZZA->(Eof()) .And. ZZA->ZZA_REQMAT == ZZ8->ZZ8_REQMAT //FwFldGet('ZZ8_REQMAT')
				
						aDipEmp := GravaEmp(ZZA->ZZA_CODPRO,;			//-- 01.C¢digo do Produto
											ZZA->ZZA_LOCAL,;			//-- 02.Local
											ZZA->ZZA_QTDPRO,; 			//-- 03.Quantidade
											Nil,;			   			//-- 04.Quantidade 2UM
											ZZA->ZZA_LOTECT,; 			//-- 05.Lote
											Nil,;		  				//-- 06.SubLote
											ZZA->ZZA_LOCALI,;			//-- 07.Localiza‡Æo
											Nil,; 						//-- 08.Numero de S‚rie
											Nil,;      		   			//-- 09.OP
											Nil,;						//-- 10.Seq. do Empenho/Libera‡Æo do PV (Pedido de Venda)
											Nil,;   					//-- 11.PV
											Nil,;      					//-- 12.Item do PV
											'ZZ9',; 		   			//-- 13.Origem do Empenho
											Nil,;    		     		//-- 14.OP Original
											Nil,;     		    		//-- 15.Data da Entrega do Empenho
											Nil,;	 			   		//-- 16.Array para Travamento de arquivos
											.T.,;     					//-- 17.Estorna Empenho?
											Nil,;         				//-- 18.chamada da Proje‡Æo de Estoques?
											.T.,;         				//-- 19.Empenha no SB2?
											.F.,;         				//-- 20.Grava SD4?
											.T.,;         				//-- 21.Considera Lotes Vencidos?
											.T.,;         				//-- 22.Empenha no SB8/SBF?
											.T.,;        				//-- 23.Cria SDC?  ==> IMPORTANTE: NAO CRIA SDC SE O PARAMETRO ANTERIOR (B2/BF) ESTIVER .F.,
											.T.)
											
			        ZZA->(dbSkip())
				EndDo
			EndIf

			//oModel:SetValue('ZZ8MASTER','ZZ8_STATUS',0)		                                    
			//oModel:SetValue('ZZ8MASTER','ZZ8_IMPRES','X')		                                    
			//oModel:SetValue('ZZ8MASTER','ZZ8_USUAR2',"")	
            ZZA->(dbGoTop())
			ZZA->(dbSetOrder(1))                                
			While !ZZA->(Eof()) .And. ZZA->(dbSeek(xFilial("ZZA")+ZZ8->ZZ8_REQMAT/*FwFldGet('ZZ8_REQMAT')*/))
				ZZA->(RecLock("ZZA",.F.))
					ZZA->(dbDelete())      
				ZZA->(MsUnlock())
			EndDo

			//FWFormCommit(oModel)
			//oModel:nOperation := 5			 

			ZZ8->(RecLock("ZZ8",.F.))  
			    ZZ8->ZZ8_STATUS := 0                                          
				ZZ8->ZZ8_USUAR5 := _cUsuar
				ZZ8->ZZ8_DATEST := _dDat
				ZZ8->ZZ8_HRESTO := _nHora 
				ZZ8->ZZ8_IMPRES := ''
			ZZ8->(MsUnlock())

		EndIf
	ElseIf Aviso("Atenção","Confirma a exclusão da RM?",{"Sim","Não"},1)==1
		ZZ9->(dbSetOrder(1))
		If ZZ9->(dbSeek(xFilial("ZZ9")+ZZ8->ZZ8_REQMAT))
			While !ZZ9->(Eof()) .And. ZZ9->(ZZ9_FILIAL+ZZ9_REQMAT)==xFilial("ZZ9")+ZZ8->ZZ8_REQMAT
				ZZ9->(RecLock("ZZ9",.F.))
				ZZ9->(dbDelete())
				ZZ9->(MsUnLock())
				ZZ9->(dbSkip())
			EndDo
			
			ZZ8->(RecLock("ZZ8",.F.))
			ZZ8->(dbDelete())
			ZZ8->(MsUnLock())    

			RollBackSx8()
			
		EndIf

		ZZ8->(RecLock("ZZ8",.F.))                                                  
			ZZ8->ZZ8_USUAR6 := _cUsuar
			ZZ8->ZZ8_DATEXC := _dDat
			ZZ8->ZZ8_HREXCL := _nHora
		ZZ8->(MsUnlock())

	Else
		Help( ,, 'Help',, 'Operação cancelada.', 1, 0 )
		lRet := .F.
	EndIf
Else
	Help( ,, 'Help',, 'Opção não permitida.', 1, 0 ) 
	lRet := .F.
EndIf	

If lGrv
	EnvCicMail(cReqMat,cOp,lLoc03)
	If Aviso("Atenção","Deseja imprimir a requisição de materiais agora?",{"Sim","Não"})==1
		u_DipImpZZ9(1)
	EndIf
EndIf
	
Return lRet             
//-------------------------------------------------------------------
/*/{Protheus.doc} DipImpOp
Monta o menu

@author DSD
@since 27/09/13
@version P11
/*/
User Function DipImpOp(nTp)
Local cReport	:= "DIPR060"
Local cAlias	:= "ZZ9"
Local cTitle	:= ""
Local cDesc		:= "IMPRESSAO DA REQUISIÇÃO DE MATERIAIS"
Local lInd		:= .T.					//Mostra os indices do SIX
Local cFiltro   := ""                               
Local cReqMat	:= ""              
Local cOrdPro	:= ""
Local oModel                       
DEFAULT nTp		:= 0

If nTp == 0 
	oModel  := FWModelActive()  
	cReqMat := FwFldGet('ZZ8_REQMAT')
	cOrdPro := FwFldGet('ZZ8_ORDPRO')
Else                                                       
	cReqMat := ZZ8->ZZ8_REQMAT
	cOrdPro := ZZ8->ZZ8_ORDPRO
EndIf                                               

cTiTle := "| REQUISIÇÃO DE MATERIAIS - "+cReqMat+" | | ORDEM DE PRODUÇÃO - "+cOrdPro+" |"

cFiltro := "@ZZ9_FILIAL = '"+xFilial("ZZ9")+"' AND ZZ9_REQMAT = '"+cReqMat+"'"

DbSelectArea("ZZ9")
ZZ9->(dbSetOrder(1))

SET FILTER TO &cFiltro

MPReport(cReport,cAlias,cTitle,cDesc,,lInd)

SET FILTER TO 

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} DipGerEmp
Monta o menu

@author DSD
@since 27/09/13
@version P11
/*/
User Function DipGerEmp()

Local oModel := FWModelActive()

nOpcEsp := 6

If ZZ8->ZZ8_STATUS == 0

  	nRecno       := ZZ8->(RECNO())
    cTitulo      := "Gera empenho da RM." 
    cPrograma    := 'DIPA060'
    nOperation   := MODEL_OPERATION_VIEW 

    oModel       := FWLoadModel( cPrograma )
    oModel:SetOperation( MODEL_OPERATION_VIEW ) // 
    oModel:Activate(.T.) // Ativa o modelo com os dados posicionados

    nRet         := FWExecView( cTitulo , cPrograma, MODEL_OPERATION_VIEW, /*oDlg*/, {|| .T. } ,/*bOk*/ , /*nPercReducao*/, /*aEnableButtons*/, /*bCancel*/ , /*cOperatId*/, /*cToolBar*/, oModel )
  
    oModel:DeActivate()
    
	//FWExecView('Gera empenho da RM.','DIPA060',6,, { || .T. } ) == 0 
Else
	Help( ,, 'Help',, 'O Empenho já foi gerado para a RM. '+ZZ8->ZZ8_REQMAT, 1, 0 )
EndIf

nOpcEsp := 0

Return 
//-------------------------------------------------------------------
/*/{Protheus.doc} DipBxEst
Monta o menu

@author DSD
@since 27/09/13
@version P11
/*/
User Function DipBxEst()
Local oModel := FWModelActive()
Local _nHora    := SubStr(Time(),1,2)+":"+SubStr(Time(),4,2)


//oModel:GetModel('ZZ9DETAIL'):SetOnlyView (.T.)
                       
If ZZ8->ZZ8_STATUS == 0
	Help( ,, 'Help',, 'Só é permitido finalizar RM empenhada. '+ZZ8->ZZ8_REQMAT, 1, 0 )	
ElseIf !Empty(ZZ8->ZZ8_XSTCB7) .And. ZZ8->ZZ8_XSTCB7 < "2"
	Help( ,, 'Help',, 'RM com ordem de separação pendente: '+ZZ8->ZZ8_XORSEP+'.', 1, 0 )
ElseIf ZZ8->ZZ8_STATUS == 1 .And. Empty(ZZ8->ZZ8_XSTCB7)
	Help( ,, 'Help',, 'RM sem ordem de separação. Gere a O.S. antes de finalizar.', 1, 0 )
ElseIf ZZ8->ZZ8_STATUS == 1                                         
	If AllTrim(ZZ8->ZZ8_ORDPRO)=="PCP_AT" 
		If Upper(u_DipUsr())$GetNewPar("ES_DIPA060","DDOMINGOS/RBORGES/MCANUTO/SFSILVA/FDURAN")
			nOpcEsp := 6
		  	nRecno       := ZZ8->(RECNO())
		    cTitulo      := 'Finaliza RM.' 
		    cPrograma    := 'DIPA060'
		    nOperation   := MODEL_OPERATION_VIEW		
		    oModel       := FWLoadModel( cPrograma )
		    oModel:SetOperation( MODEL_OPERATION_VIEW ) // 
		    oModel:Activate(.T.) // Ativa o modelo com os dados posicionados		
		    nRet         := FWExecView( cTitulo , cPrograma, MODEL_OPERATION_VIEW, /*oDlg*/, {|| .T. } ,/*bOk*/ , /*nPercReducao*/, /*aEnableButtons*/, /*bCancel*/ , /*cOperatId*/, /*cToolBar*/, oModel )
		    If nRet == 0
				//FWExecView('Finaliza RM.','DIPA060',6,, { || .T. } ) == 0 
				ZZ8->(RecLock("ZZ8",.F.))                                                  
					ZZ8->ZZ8_HRFINA := _nHora
				ZZ8->(MsUnlock())
			EndIf
		    oModel:DeActivate()	
			nOpcEsp := 0
		Else
			Help( ,, 'Help',, 'Usuário sem acesso para baixar esse tipo de requisição (PCP). '+ZZ8->ZZ8_REQMAT, 1, 0 )	
		EndIf
	Else
		nOpcEsp := 6
		nRecno       := ZZ8->(RECNO())
		cTitulo      := 'Finaliza RM.' 
		cPrograma    := 'DIPA060'
		nOperation   := MODEL_OPERATION_VIEW		
		oModel       := FWLoadModel( cPrograma )
		oModel:SetOperation( MODEL_OPERATION_VIEW ) // 
		oModel:Activate(.T.) // Ativa o modelo com os dados posicionados		
		nRet         := FWExecView( cTitulo , cPrograma, MODEL_OPERATION_VIEW, /*oDlg*/, {|| .T. } ,/*bOk*/ , /*nPercReducao*/, /*aEnableButtons*/, /*bCancel*/ , /*cOperatId*/, /*cToolBar*/, oModel )
		If nRet == 0
			//FWExecView('Finaliza RM.','DIPA060',6,, { || .T. } ) == 0 
			ZZ8->(RecLock("ZZ8",.F.))                                                  
				ZZ8->ZZ8_HRFINA := _nHora
			ZZ8->(MsUnlock())
		EndIf
		oModel:DeActivate()
		nOpcEsp := 0
	EndIf
ElseIf ZZ8->ZZ8_STATUS == 2
	Help( ,, 'Help',, 'RM já finalizada. '+ZZ8->ZZ8_REQMAT, 1, 0 )	
EndIf
	
Return      
//-------------------------------------------------------------------
/*/{Protheus.doc} DipBxEst
Monta o menu

@author DSD
@since 27/09/13
@version P11
/*/
User Function DipExcOP()
Local lRet	 := .T.

If ZZ8->ZZ8_STATUS == 1                                      
	lRet := .F.
	Help( ,, 'Help',, 'RM já empenhada. '+ZZ8->ZZ8_REQMAT, 1, 0 )	
ElseIf ZZ8->ZZ8_STATUS == 2
	lRet := .F.
	Help( ,, 'Help',, 'RM já finalizada. '+ZZ8->ZZ8_REQMAT, 1, 0 )	
ElseIf !Empty(ZZ8->ZZ8_XSTCB7)
	Help( ,, 'Help',, 'RM com ordem de separação. Estorne a O.S. '+ZZ8->ZZ8_XORSEP+' antes.', 1, 0 )	
	lRet := .F.
Else
	nOpcEsp := 5
	nRecno       := ZZ8->(RECNO())
	cTitulo      := 'Finaliza RM.' 
	cPrograma    := 'DIPA060'
	nOperation   := MODEL_OPERATION_DELETE 		
	oModel       := FWLoadModel( cPrograma )
	oModel:SetOperation( MODEL_OPERATION_DELETE ) // 
	oModel:Activate(.T.) // Ativa o modelo com os dados posicionados		
	nRet         := FWExecView( cTitulo , cPrograma, MODEL_OPERATION_DELETE, /*oDlg*/, {|| .T. } ,/*bOk*/ , /*nPercReducao*/, /*aEnableButtons*/, /*bCancel*/ , /*cOperatId*/, /*cToolBar*/, oModel )
	oModel:DeActivate()
	nOpcEsp := 0
	//FWExecView('Exclusão da RM.','DIPA060', MODEL_OPERATION_DELETE,, { || .T. } ) == 0 
EndIf
	
Return lRet
//-------------------------------------------------------------------
/*/{Protheus.doc} DipFinOP
Monta o menu

@author DSD
@since 27/09/13
@version P11
/*/
Static Function DipFinOP(oModel)      
Local oModel 	:= FWModelActive()
Local oStru  	:= oModel:GetModel('ZZ9DETAIL')
Local nI 	 	:= 1
Local cCodPro   := ""
Local cLocal    := ""
Local cLoteCT   := ""
Local cLocaliz  := ""
Local nQuant	:= 0
Local nQuant2 	:= 0                                           
Local nRetSb2	:= 0
Local nAtuCm1	:= 0                     
Local cNumseq   := ProxNum()
Local cUM   	:= ""
Local cUM2      := ""
Local dDtValid  := StoD("")
Local cCodDoc	:= ""				 
Local cNumIDDB  := ""     
Local aDadTrans := {}            
Local lDipPCP	:= .F.
Private  oDlg		
Private _cSeparo  := Space(2)
Private _cConfer  := Space(2)
Private _dDtSep	  := dDataBase
Private _dDtCon	  := dDataBase
Private _nHrSep   := SubStr(Time(),1,2)+":"+SubStr(Time(),4,2)
Private _nHrConf  := SubStr(Time(),1,2)+":"+SubStr(Time(),4,2)
Private _nOpcao   := 0

Begin Transaction    

cNumIDDB := GetSx8Num('SDB','DB_IDOPERA')

ConfirmSX8()
       
If Upper(u_DipUsr())$GetNewPar("ES_DIPA060","DDOMINGOS/RBORGES/MCANUTO/SFSILVA")
	lDipPCP := (Aviso("PCP","Deseja transferir os produtos para o armazém 99 (Requisição para o PCP)?",{"Sim","Não"})==1)
EndIf

ZZA->(dbSetOrder(1))
If ZZA->(dbSeek(xFilial("ZZA")+ZZ8->ZZ8_REQMAT/*FwFldGet('ZZ8_REQMAT')*/))
	While !ZZA->(Eof()) .And. ZZA->ZZA_REQMAT == ZZ8->ZZ8_REQMAT //FwFldGet('ZZ8_REQMAT')
		
		cCodPro   := ZZA->ZZA_CODPRO
		cLocal    := ZZA->ZZA_LOCAL
		cLoteCT   := ZZA->ZZA_LOTECT
		cLocaliz  := ZZA->ZZA_LOCALI
		nQuant	  := ZZA->ZZA_QTDPRO
		nQuant2   := ZZA->ZZA_QTDPR2
		cReqMat   := ZZA->ZZA_REQMAT
		cUM   	  := ZZA->ZZA_UNDPRO
		cUM2      := ZZA->ZZA_UNDPR2
		dDtValid  := ZZA->ZZA_DTVALI
		cCodDoc   := DipNumDoc()
		
		If lDipPCP
			SB2->(Dbsetorder(1))
			If SB2->(Dbseek(xFilial("SB2")+cCodPro+cLocal))
				SB2->(Reclock("SB2",.F.))
					Replace SB2->B2_QEMP    WITH SB2->B2_QEMP 	 - nQuant
					Replace SB2->B2_QEMP2   WITH SB2->B2_QEMP2 	 - nQuant2
				SB2->(MsUnlock())
				SB2->(DbCommit())
			Endif
			
			SB8->(Dbsetorder(3))
			If SB8->(Dbseek(xFilial("SB8")+cCodPro+cLocal+cLoteCT))
				SB8->(Reclock("SB8",.F.))
					Replace SB8->B8_EMPENHO  WITH  SB8->B8_EMPENHO - nQuant
					Replace SB8->B8_EMPENH2  WITH  SB8->B8_EMPENH2 - nQuant2
				SB8->(MsUnlock())
				SB8->(DbCommit())
			EndIf
			
			SBF->(DbSetOrder(1))
			If SBF->(DbSeek(xFilial("SBF")+cLocal+cLocaliz+cCodPro+Space(TamSx3("BF_NUMSERI")[1])+cLoteCT+Space(TamSx3("BF_NUMLOTE")[1])))
				SBF->(RecLock("SBF",.F.))
					Replace SBF->BF_EMPENHO With SBF->BF_EMPENHO - nQuant
					Replace SBF->BF_EMPEN2  With SBF->BF_EMPEN2  - nQuant2
				SBF->(MsUnLock())
				SBF->(DbCommit())
			EndIf
			
			SDC->(DbSetOrder(3))
			If SDC->(DbSeek(xFilial("SDC")+cCodPro+cLocal+cLoteCT+Space(TamSx3("BF_NUMLOTE")[1])+cLocaliz))
				nQtdAux := nQuant
				nQtdAux2:= nQuant2
				
				While !SDC->(Eof()) .And.;
					SDC->(DC_FILIAL+DC_PRODUTO+DC_LOCAL+DC_LOTECTL+DC_LOCALIZ) == xFilial("SDC")+cCodPro+cLocal+cLoteCT+cLocaliz .And.;
					nQtdAux > 0
					
					If Empty(SDC->DC_PEDIDO)
						If nQtdAux < SDC->DC_QUANT
							SDC->(RecLock("SDC",.F.))
								Replace SDC->DC_QUANT 	With SDC->DC_QUANT   - nQtdAux
								Replace SDC->DC_QTSEGUM With SDC->DC_QTSEGUM - nQtdAux2
							SDC->(MsUnLock())
							
							nQtdAux  := 0
							nQtdAux2 := 0
						Else
							If nQtdAux > SDC->DC_QUANT
								nQtdAux -= SDC->DC_QUANT
								nQtdAux2 -= SDC->DC_QTSEGUM
							Else
								nQtdAux  := 0
								nQtdAux2 := 0
							EndIf
							
							SDC->(RecLock("SDC",.F.))
								SDC->(dbDelete())
							SDC->(MsUnlock())
						EndIf
					EndIf
					
					SDC->(dbSkip())
				EndDo
			EndIf
			
			SB1->(dbSetOrder(1))
			If SB1->(dbSeek(xFilial("SB1")+cCodPro))
				
				If Len(aDadTrans) == 0
					aAdd(aDadTrans,{cCodDoc													,; // 01.Numero do Documento
									dDataBase												}) // 02.Data da Transferencia
				EndIf
				
				aAdd(aDadTrans,{SB1->B1_COD													,; // 01.Produto Origem
								SB1->B1_DESC												,; // 02.Descricao
								SB1->B1_UM													,; // 03.Unidade de Medida
								cLocal														,; // 04.Local Origem
								cLocaliz													,; // 05.Endereco Origem
								SB1->B1_COD													,; // 06.Produto Destino
								SB1->B1_DESC												,; // 07.Descricao
								SB1->B1_UM													,; // 08.Unidade de Medida
								"99"						   								,; // 09.Armazem Destino
								cLocaliz													,; // 10.Endereco Destino
								CriaVar("D3_NUMSERI",.F.)									,; // 11.Numero de Serie
								cLoteCT														,; // 12.Lote Origem
								CriaVar("D3_NUMLOTE",.F.)									,; // 13.Sublote
								dDtValid													,; // 14.Data de Validade
								CriaVar("D3_POTENCI",.F.)									,; // 15.Potencia do Lote
								nQuant														,; // 16.Quantidade
								nQuant2														,; // 17.Quantidade na 2 UM
								CriaVar("D3_ESTORNO",.F.)									,; // 18.Estorno
								cNumSeq														,; // 19.NumSeq
								cLoteCT														,; // 20.Lote Destino
								dDtValid													,; // 21.Data de Validade do Destino
								Criavar("D3_ITEMGRD",.F.)									,; // 22.Item grade MCVN - 16/11/09)
								""									 						,; // 24.Observação
								"Transf. Auto. Requisicao PCP - "+cReqMat					,; // 25.Explicação
								""															}) // 26.Nro Separação							
			EndIf
		Else
			SB2->(Dbsetorder(1))
			If SB2->(Dbseek(xFilial("SB2")+cCodPro+cLocal))
				SB2->(Reclock("SB2",.F.))
					Replace SB2->B2_QATU    WITH SB2->B2_QATU 	 - nQuant
					Replace SB2->B2_QTSEGUM WITH SB2->B2_QTSEGUM - nQuant2
					nRetSb2 := SB2->B2_CM1 * nQuant
					Replace SB2->B2_VATU1   WITH SB2->B2_VATU1 	 - nRetSb2
					nAtuCm1 := SB2->B2_VATU1 / SB2->B2_QATU
					Replace SB2->B2_CM1     WITH nAtuCm1		
					Replace SB2->B2_QEMP    WITH SB2->B2_QEMP 	 - nQuant
					Replace SB2->B2_QEMP2   WITH SB2->B2_QEMP2 	 - nQuant2
				SB2->(MsUnlock())
				SB2->(DbCommit())
			Endif
			
			SB8->(Dbsetorder(3))
			If SB8->(Dbseek(xFilial("SB8")+cCodPro+cLocal+cLoteCT))
				SB8->(Reclock("SB8",.F.))
				Replace SB8->B8_SALDO    WITH  SB8->B8_SALDO   - nQuant
				Replace SB8->B8_SALDO2   WITH  SB8->B8_SALDO2  - nQuant2
				Replace SB8->B8_EMPENHO  WITH  SB8->B8_EMPENHO - nQuant
				Replace SB8->B8_EMPENH2  WITH  SB8->B8_EMPENH2 - nQuant2
				SB8->(MsUnlock())
				SB8->(DbCommit())
			EndIf
			
			SD5->(Reclock("SD5",.T.))
				Replace SD5->D5_FILIAL    WITH xFilial("SD5")
				Replace SD5->D5_PRODUTO   WITH cCodPro
				Replace SD5->D5_DOC		  WITH cCodDoc
				Replace SD5->D5_LOCAL     WITH cLocal
				Replace SD5->D5_DATA      WITH dDatabase
				Replace SD5->D5_ORIGLAN   WITH "501"
				Replace SD5->D5_NUMSEQ    WITH cNumSeq
				Replace SD5->D5_QUANT     WITH nQuant
				Replace SD5->D5_LOTECTL   WITH cLoteCT
				Replace SD5->D5_DTVALID   WITH dDtValid
				Replace SD5->D5_QTSEGUM   WITH nQuant2
			SD5->(MsUnlock())
			SD5->(DbCommit())
			
			
			SBF->(DbSetOrder(1))
			If SBF->(DbSeek(xFilial("SBF")+cLocal+cLocaliz+cCodPro+Space(TamSx3("BF_NUMSERI")[1])+cLoteCT+Space(TamSx3("BF_NUMLOTE")[1])))
				SBF->(RecLock("SBF",.F.))
					Replace SBF->BF_QUANT   With SBF->BF_QUANT   - nQuant
					Replace SBF->BF_QTSEGUM With SBF->BF_QTSEGUM - nQuant2
					Replace SBF->BF_EMPENHO With SBF->BF_EMPENHO - nQuant
					Replace SBF->BF_EMPEN2  With SBF->BF_EMPEN2  - nQuant2
				SBF->(MsUnLock())
				SBF->(DbCommit())
			EndIf
			
			SDC->(DbSetOrder(3))
			If SDC->(DbSeek(xFilial("SDC")+cCodPro+cLocal+cLoteCT+Space(TamSx3("BF_NUMLOTE")[1])+cLocaliz))
				nQtdAux := nQuant
				nQtdAux2:= nQuant2
				
				While !SDC->(Eof()) .And.;
					SDC->(DC_FILIAL+DC_PRODUTO+DC_LOCAL+DC_LOTECTL+DC_LOCALIZ) == xFilial("SDC")+cCodPro+cLocal+cLoteCT+cLocaliz .And.;
					nQtdAux > 0
					
					If Empty(SDC->DC_PEDIDO)
						If nQtdAux < SDC->DC_QUANT
							SDC->(RecLock("SDC",.F.))
							Replace SDC->DC_QUANT 	With SDC->DC_QUANT   - nQtdAux
							Replace SDC->DC_QTSEGUM With SDC->DC_QTSEGUM - nQtdAux2
							SDC->(MsUnLock())
							
							nQtdAux  := 0
							nQtdAux2 := 0
						Else
							If nQtdAux > SDC->DC_QUANT
								nQtdAux -= SDC->DC_QUANT
								nQtdAux2 -= SDC->DC_QTSEGUM
							Else
								nQtdAux  := 0
								nQtdAux2 := 0
							EndIf
							
							SDC->(RecLock("SDC",.F.))
							SDC->(dbDelete())
							SDC->(MsUnlock())
						EndIf
					EndIf
					SDC->(dbSkip())
				EndDo
			EndIf
			
			SDB->(DbSetOrder(1))
			SDB->(Reclock("SDB",.T.))
				Replace SDB->DB_FILIAL    WITH xFilial("SDB")
				Replace SDB->DB_ITEM      WITH '001'
				Replace SDB->DB_DOC		  WITH cCodDoc
				Replace SDB->DB_PRODUTO   WITH cCodPro
				Replace SDB->DB_LOCAL     WITH cLocal
				Replace SDB->DB_DATA      WITH dDatabase
				Replace SDB->DB_ORIGEM    WITH 'ZZ9'
				Replace SDB->DB_NUMSEQ    WITH cNumSeq
				Replace SDB->DB_QUANT     WITH nQuant
				Replace SDB->DB_LOTECTL   WITH cLoteCT
				Replace SDB->DB_QTSEGUM   WITH nQuant2
				Replace SDB->DB_TIPO      WITH 'M'
				Replace SDB->DB_TM        WITH "501"
				Replace SDB->DB_LOCALIZ   WITH cLocaliz
				Replace SDB->DB_SERVIC    WITH "999"
				Replace SDB->DB_ATIVID    WITH "ZZZ"
				Replace SDB->DB_HRINI     WITH Left(Time(),5)
				Replace SDB->DB_ATUEST    WITH "S"
				Replace SDB->DB_ORDATIV   WITH "ZZ"
				Replace SDB->DB_STATUS    WITH "M"
				Replace SDB->DB_IDOPERA   WITH cNumIDDB
			SDB->(MsUnlock())
			SDB->(DbCommit())
			
			SD3->(Reclock("SD3",.T.))
				Replace SD3->D3_FILIAL  WITH xFilial("SD3")
				Replace SD3->D3_TM      WITH "501"
				Replace SD3->D3_DOC		WITH cCodDoc
				Replace SD3->D3_COD     WITH cCodPro
				Replace SD3->D3_UM      WITH cUM
				Replace SD3->D3_QUANT   WITH nQuant
				Replace SD3->D3_CF      WITH "RE0"
				Replace SD3->D3_LOCAL   WITH cLocal
				Replace SD3->D3_EMISSAO WITH dDataBase
				Replace SD3->D3_NUMSEQ  WITH cNumseq
				Replace SD3->D3_SEGUM   WITH cUM2
				Replace SD3->D3_QTSEGUM WITH nQuant2
				Replace SD3->D3_CHAVE   WITH "E0"
				Replace SD3->D3_LOTECTL WITH cLoteCT
				Replace SD3->D3_DTVALID WITH dDtValid
				Replace SD3->D3_LOCALIZ WITH cLocaliz
				Replace SD3->D3_USUARIO WITH Upper(U_DipUsr())
				Replace SD3->D3_EXPLIC  WITH "Movimento rotina automática HQ"
				SB1->(dbSetOrder(1))
				If SB1->(dbSeek(xFilial("SB1")+cCodPro))
					Replace SD3->D3_CONTA   WITH SB1->B1_CONTA
					Replace SD3->D3_CUSTO1	WITH SB1->B1_CUSDIP*nQuant
					Replace SD3->D3_TIPO 	WITH SB1->B1_TIPO
				Endif
			SD3->(MsUnlock())
			SD3->(DbCommit())			
		EndIf
		ZZA->(dbSkip())
	EndDo

	If lDipPCP
		If !u_DipTrReq(aDadTrans)
			If InTransact()
				DisarmTransaction()
			EndIf
			Aviso("Atenção","Processo não finalizado. Não foi possível efetuar a transferência.",{"Ok"})
			Break
		EndIf
		cNumseq := DipMaxD3()
	EndIf
	
	PutMv("MV_DOCSEQ",cNumSeq)
EndIf

While _nOpcao <> 1
	@ 126,000 To 350,250 DIALOG oDlg TITLE OemToAnsi("Informe os Dados")
	@ 020,025 Say OemToAnsi("Separou: ")
	@ 020,060 Get _cSeparo Size 33,20 F3 "SZC" Valid ExistCPO("SZC")  
	@ 035,025 say OemToAnsi('Dt.Separação:')                                                        
	@ 035,060 get _dDtSep Size 15,20 Picture "@D"
	@ 050,025 Say OemToAnsi("Conferiu: ")
	@ 050,060 Get _cConfer Size 33,20 F3 "SZC" Valid ExistCPO("SZC")
	@ 065,025 say OemToAnsi('Dt.Conferen.:')                                      
	@ 065,060 get _dDtCon Size 33,20 Picture "@D"
	@ 080,025 BUTTON OemToAnsi("Confirma")       SIZE 30,15 ACTION (_nOpcao := 1, Close(odlg))
	@ 080,060 BUTTON OemToAnsi("Cancela")        SIZE 30,15 ACTION (_nOpcao := 0, Close(odlg))
	
	ACTIVATE DIALOG oDlg Centered
EndDo

ZZ8->(RecLock("ZZ8",.F.))                                                  
	ZZ8->ZZ8_STATUS := 2
	ZZ8->ZZ8_USUAR2 := _cSeparo
	ZZ8->ZZ8_DATSEP := _dDtSep
	ZZ8->ZZ8_USUAR3 := _cConfer
	ZZ8->ZZ8_DATCON := _dDtCon
ZZ8->(MsUnlock())
	   

End Transaction

Return  
//-------------------------------------------------------------------
/*/{Protheus.doc} DipNumDoc
Monta o menu

@author DSD
@since 27/09/13
@version P11
/*/
Static Function DipNumDoc()
Local cNumDoc 	:= ""
Local cSQl 		:= ""

cSQL := " SELECT "
cSQL += " 	MAX(D5_DOC) DOC "
cSQL += " 	FROM "
cSQL += 		RetSQLName("SD5")
cSQL += " 		WHERE "
cSQL += " 			D5_FILIAL = '"+xFilial("SD5")+"' "
cSQL += " 			AND LEFT(D5_DOC,2) = 'HQ' "
cSQL += " 			AND D_E_L_E_T_ = ' ' " 

cSQL := ChangeQuery(cSQL)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),"QRYSD5",.T.,.T.)

If QRYSD5->(Eof()) .Or. Empty(QRYSD5->DOC)                  
	cNumDoc := "HQ0000001"
Else
	cNumDoc := Soma1(QRYSD5->DOC)
EndIf
QRYSD5->(dbCloseArea())

Return cNumDoc
//-------------------------------------------------------------------
/*/{Protheus.doc} PreOk
Monta o menu

@author DSD
@since 27/09/13
@version P11
/*/
User Function PreOk(oModel)
Local lRet := .T.

/*
Local nOpc := oModel:GetOperation()

If oModel:GetOperation() == 4 .And. ZZ8->ZZ8_STATUS <> 0
	Help( ,, 'Help',, 'RM não pode ser alterada. '+ZZ8->ZZ8_REQMAT, 1, 0 )	
	lRet := .F.
EndIf

If lRet
	If nOpc == 3     
		lRet := U_DipUsr()$GetNewPar("ES_SEPREQM","ddomingos")
	ElseIf nOpc == 4
		lRet := U_DipUsr()$GetNewPar("ES_SEPREQM","ddomingos")
	ElseIf nOpc == 5
		lRet := U_DipUsr()$GetNewPar("ES_SEPREQM","ddomingos")
	ElseIf nOpc == 6 .And. ZZ8->ZZ8_STATUS = 0
		lRet := U_DipUsr()$GetNewPar("ES_SEPREQM","ddomingos")
	ElseIf nOpc == 6 .And. ZZ8->ZZ8_STATUS = 1
		lRet := U_DipUsr()$GetNewPar("ES_CONFREQ","ddomingos;fduran")
	EndIf    
	
	If !lRet
		Help( ,, 'Help',, 'Usuário sem acesso para esta solicitação. ', 1, 0 )	
	EndIf
EndIf
*/
Return lRet          
//-------------------------------------------------------------------
/*/{Protheus.doc} DIPW060
Monta o menu

@author DSD
@since 27/09/13
@version P11
/*/
User Function DIPW060()
Local lRet	   := .T.
Local oModel   :=  FWModelActive()

If oModel:GetOperation() <> 4
	lRet := .F.           
EndIf  

Return lRet
//-------------------------------------------------------------------
/*/{Protheus.doc} DipExcEmp
Monta o menu

@author DSD
@since 27/09/13
@version P11
/*/
User Function DipExcEmp()
Local lRet 	 := .T.

If ZZ8->ZZ8_STATUS == 0
	Help( ,, 'Help',, 'RM ainda não foi empenhada. '+ZZ8->ZZ8_REQMAT, 1, 0 )	
	lRet := .F.
ElseIf ZZ8->ZZ8_STATUS == 2
	Help( ,, 'Help',, 'RM já finalizada. '+ZZ8->ZZ8_REQMAT, 1, 0 )	
	lRet := .F.        
ElseIf !Empty(ZZ8->ZZ8_XSTCB7)    
    Help( ,, 'Help',, 'RM com ordem de separação. Estorne a O.S. '+ZZ8->ZZ8_XORSEP+' antes.', 1, 0 )	
	lRet := .F.
Else
	nOpcEsp := 5
	nRecno       := ZZ8->(RECNO())
	cTitulo      := 'Exclusão do Empenho.' 
	cPrograma    := 'DIPA060'
	nOperation   := MODEL_OPERATION_DELETE 		
	oModel       := FWLoadModel( cPrograma )
	oModel:SetOperation( MODEL_OPERATION_DELETE ) // 
	oModel:Activate(.T.) // Ativa o modelo com os dados posicionados		
	nRet         := FWExecView( cTitulo , cPrograma, MODEL_OPERATION_DELETE, /*oDlg*/, {|| .T. } ,/*bOk*/ , /*nPercReducao*/, /*aEnableButtons*/, /*bCancel*/ , /*cOperatId*/, /*cToolBar*/, oModel )
	oModel:DeActivate()
	nOpcEsp := 0
	//FWExecView('Exclusão do Empenho.','DIPA060', MODEL_OPERATION_DELETE,, { || .T. } ) == 0 	
EndIf

Return lRet
//-------------------------------------------------------------------
/*/{Protheus.doc} EnvCiMail
Monta o menu

@author DSD
@since 27/09/13
@version P11
/*/
Static Function EnvCicMail(cReqMat,cOP,lLoc03)
Local _cMscCic   := ""
Local _cOpRecC 	 := GetNewPar("ES_REQMCIC","MAXIMO.CANUTO")
Local _cOpRecM   := GetNewPar("ES_REQMMAI","maximo.canuto@dipromed.com.br")
Local _cAssunto  := ""
Local _aMsg      := {}
Local _cFrom     := "protheus@dipromed.com.br"
Local _cFuncSent := "DIPA060(EnvCicMail)"
DEFAULT cReqMat  := ""
DEFAULT cOP	 	 := ""
DEFAULT lLoc03   := .F.

If lLoc03
	_cOpRecC := GetNewPar("ES_REQCL03","MAXIMO.CANUTO")	
	_cOpRecM := GetNewPar("ES_REQML03","maximo.canuto@dipromed.com.br")
EndIf       

//Enviando Cic para Financeiro
_cMscCic := "REQUISICAO DE MATERIAIS DISPONÍVEL PARA IMPRESSÃO."+CHR(10)+CHR(13) 
_cMscCic += "REQ " +cReqMat + " / O.P. " +cOP+ CHR(10)+CHR(13)
_cMscCic += "Usuário: "+U_DipUsr()
U_DIPCIC(_cMscCic,_cOpRecC)//envia cic

//Enviando e-mail para Financeiro
_cAssunto:= EncodeUTF8("REQUISICAO DE MATERIAIS DISPONÍVEL. REQ " +cReqMat+ " / O.P. " +cOP,"cp1252")
Aadd( _aMsg , { "Req. Materiais: "     	, cReqMat } )
Aadd( _aMsg , { "Ordem Produção: "     	, cOP	   } )
Aadd( _aMsg , { "Usuário: "             , U_DipUsr() } )
U_UEnvMail(_cOpRecM,_cAssunto,_aMsg,"",_cFrom,_cFuncSent)

Return()
//-------------------------------------------------------------------
/*/{Protheus.doc} DIpImpZZ9
Monta o menu

@author DSD
@since 27/09/13
@version P11
/*/
User Function DipImpZZ9(nTp)                
Local aDados 	:={}
Local lQuery    := .F.
Local oModel
Private aRCampos:={}
Private aReturn := {"Zebrado", 1,"Administracao", 2, 2, 1,"",1}
Private cString :="ZZ8"  
DEFAULT nTp := 0             

If nTp == 0 
	oModel  := FWModelActive()  
	cReqMat := FwFldGet('ZZ8_REQMAT')
	cOrdPro := FwFldGet('ZZ8_ORDPRO')
Else                                                       
	cReqMat := ZZ8->ZZ8_REQMAT
	cOrdPro := ZZ8->ZZ8_ORDPRO
EndIf                                               

aAdd(aDados,"QRYZZ9") 
aAdd(aDados,OemTOAnsi("Imprime a requisição de Materiais da HQ",72)) //Descrição rodape tela de parametros
aAdd(aDados,"")
aAdd(aDados,"")
aAdd(aDados,"M")
aAdd(aDados,132)
aAdd(aDados," SOLICITANTE___________DATA____/____/____      SEPARADOR___________DATA____/____/____      CONFERENTE___________DATA____/____/____")
aAdd(aDados," ")
aAdd(aDados,OemTOAnsi(" REQUISICAO DE MATERIAIS: "+cReqMat+" - ORDEM DE PRODUÇÃO: "+cOrdPro,72)) //Título do relatório
aAdd(aDados,aReturn)
aAdd(aDados,"DIPA060") 
aAdd(aDados,{{||.t.},{||.t.}})
aAdd(aDados,Nil) 

aAdd(aRCampos,{"ZZ9_SEQUEN" ,"",AvSx3("ZZ9_SEQUEN" ,5),AvSx3("ZZ9_SEQUEN" ,6)})
aAdd(aRCampos,{"ZZA_CODPRO" ,"",AvSx3("ZZA_CODPRO" ,5),AvSx3("ZZA_CODPRO" ,6)})
aAdd(aRCampos,{"ZZ9_DESPRO" ,"",AvSx3("ZZ9_DESPRO" ,5),AvSx3("ZZ9_DESPRO" ,6)})
aAdd(aRCampos,{"ZZA_QTDPRO" ,"",AvSx3("ZZA_QTDPRO" ,5),AvSx3("ZZA_QTDPRO" ,6)}) 
aAdd(aRCampos,{"ZZA_UNDPRO" ,"",AvSx3("ZZA_UNDPRO" ,5),AvSx3("ZZA_UNDPRO" ,6)})    
aAdd(aRCampos,{"ZZA_LOTECT" ,"",AvSx3("ZZA_LOTECT" ,5),AvSx3("ZZA_LOTECT" ,6)})  
aAdd(aRCampos,{"ZZA_DTVALI" ,"",AvSx3("ZZA_DTVALI" ,5),AvSx3("ZZA_DTVALI" ,6)})   
aAdd(aRCampos,{"ZZA_LOCAL"  ,"",AvSx3("ZZA_LOCAL"  ,5),AvSx3("ZZA_LOCAL"  ,6)})   
aAdd(aRCampos,{"ZZA_LOCALI" ,"",AvSx3("ZZA_LOCALI" ,5),AvSx3("ZZA_LOCALI" ,6)})   

aRCampos:=E_CriaRCampos(aRCampos,"E")   

aRCampos[2,1] := "AllTrim("+aRCampos[2,1]+")"  
aRCampos[9,1] := "AllTrim("+aRCampos[9,1]+")"  

Processa({|| lQuery := DipQryZZ9(cReqMat)},"Filtrando dados da Requisição...",,.t.)

If !lQuery
	Aviso("Atenção","Não encontrado dados que satisfaçam aos"+CHR(10)+CHR(13)+;
					"parametros informados pelo usuario! ",{"Ok"},1)
	QRYZZ9->(dbCloseArea())
Else
	QRYZZ9->(u_DipReport(aDados,aRCampos,nil,nil,2))
	ZZ8->(RecLock("ZZ8",.F.))                                                  
	ZZ8->ZZ8_IMPRES := 'S'
	ZZ8->(MsUnlock())
	QRYZZ9->(dbCloseArea())	
EndIf   

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} DipQryZZ9
Monta o menu

@author DSD
@since 27/09/13
@version P11
/*/
Static Function DipQryZZ9(cReqMat)
Local cSQL := ""
DEFAULT cReqMat := ""

ProcRegua(0)
                                                                                
cSQL := " SELECT "
cSQL += " 	ZZ9_SEQUEN, LTRIM(RTRIM(ZZA_CODPRO)) ZZA_CODPRO, B1_DESC ZZ9_DESPRO, ZZA_QTDPRO, ZZA_UNDPRO, ZZA_LOTECT, ZZA_DTVALI, ZZA_LOCAL, LTRIM(RTRIM(ZZA_LOCALI)) ZZA_LOCALI " 
cSQL += " 	FROM " 
cSQL +=  		RetSQLName("ZZ9")+", "+RetSQLName("SB1")+", "+RetSQLName("ZZA")
cSQL += " 		WHERE 
cSQL += " 			ZZ9_FILIAL = '"+xFilial('ZZ9')+"' AND "
cSQL += "    		ZZ9_REQMAT = '"+cReqMat+"' AND "            
cSQL += "    		ZZ9_FILIAL = B1_FILIAL AND "            
cSQL += "    		ZZ9_CODPRO = B1_COD AND "
cSQL += "    		ZZA_FILIAL = ZZ9_FILIAL AND "
cSQL += "    		ZZA_REQMAT = ZZ9_REQMAT AND "
cSQL += "    		ZZA_SEQUEN = ZZ9_SEQUEN AND "            
cSQL += "    		ZZA_CODPRO = ZZ9_CODPRO AND "            
cSQL += "    	   "+RetSQLName("ZZ9")+".D_E_L_E_T_ = ' ' AND "       
cSQL += "    	   "+RetSQLName("ZZA")+".D_E_L_E_T_ = ' ' AND "       
cSQL += "    	   "+RetSQLName("SB1")+".D_E_L_E_T_ = ' ' "       

cSQL := ChangeQuery(cSQL)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),"QRYZZ9",.T.,.T.)

TCSETFIELD("QRYZZ9","ZZA_DTVALI","D",8,0)

Return(!QRYZZ9->(Eof()))
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DIPA060   ºAutor  ³Microsiga           º Data ³  09/28/16   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function DipTrReq(aDadTrans)
Local aAreaSB1    :=  SB1->(GetArea())
Local lRet 		  := .T.
Private lMsErroAuto := .F.	
DEFAULT aDadTrans := {}

If Len(aDadTrans)>0           
	
	MSExecAuto({|x,y| MATA261(x,y)},aDadtrans,3)
	
	If lMsErroAuto
		MostraErro()
		lRet := .F.
	EndIf         
Else
	lRet := .F.
EndIf
	           
RestArea(aAreaSB1)

Return lRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DIPA060   ºAutor  ³Microsiga           º Data ³  09/29/16   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function DipReqPCP()
Local lRet 		:= .T.      
Local _nDipOpcx	:= 0
Local cSQL 		:= ""
Local aItens    := {}
Private _cDescri	:= Space(60)
Private _cProduto := Space(15)         
Private _nQuant   := 0 

If !Upper(u_DipUsr())$GetNewPar("ES_DIPA060","DDOMINGOS/RBORGES/MCANUTO/SFSILVA")
	Aviso("ES_DIPA060","Usuário sem acesso. Fale com o T.I.",{"Ok"})
	Return
EndIf

@ 126,000 To 300,415 DIALOG oDlg TITLE OemToAnsi("Informe o Produto")
@ 005,005 Say OemToAnsi("Produto: ")
@ 013,005 Get _cProduto Size 43,20 	F3 "SB1" Valid IIf(ExistCPO("SB1") .And. ExistCPO("SG1"),(_cDescri:=OemToAnsi(POSICIONE("SB1",1,xFilial("SB1")+_cProduto,"B1_DESC")),.T.),.F.)
@ 025,005 Get _cDescri Size 200,20 When .F.
@ 040,005 Say OemToAnsi("Quantidade: ")
@ 048,005 Get _nQuant Size 43,20  Picture "@E 99999999" Valid _nQuant > 0
@ 068,005 BUTTON OemToAnsi("Confirma")  SIZE 30,15 ACTION (_nDipOpcx := 1, Close(odlg))
@ 068,040 BUTTON OemToAnsi("Cancela")   SIZE 30,15 ACTION (_nDipOpcx := 0, Close(odlg))
ACTIVATE DIALOG oDlg Centered

If _nDipOpcx == 1
	aItens := DipRetSG1(_cProduto)
	If Len(aItens)>0       
		nReqMat := GetSx8Num('ZZ8','ZZ8_REQMAT')
		ConfirmSX8()
		
		ZZ8->(RecLock("ZZ8",.T.))
			ZZ8->ZZ8_STATUS := 0
			ZZ8->ZZ8_FILIAL := xFilial("ZZ8")
			ZZ8->ZZ8_REQMAT := nReqMat
			ZZ8->ZZ8_ORDPRO := "PCP_AT"
			ZZ8->ZZ8_USUARI := Upper(u_DipUsr())
			ZZ8->ZZ8_DATA   := dDataBase			
		ZZ8->(MsUnLock())
        
		For nI:=1 to Len(aItens)   	  
			If aItens[nI,3]		
				nQtdZZ9 := aItens[nI,2]*_nQuant			
				ZZ9->(RecLock("ZZ9",.T.))		
					ZZ9->ZZ9_FILIAL := xFilial("ZZ9")
					ZZ9->ZZ9_REQMAT := nReqMat  
					ZZ9->ZZ9_SEQUEN := StrZero(nI,3)
					ZZ9->ZZ9_CODPRO := aItens[nI,1]
					ZZ9->ZZ9_QTDPRO := nQtdZZ9
					ZZ9->ZZ9_UNDPRO := aItens[nI,6]
					ZZ9->ZZ9_QTDPR2 := ConvUm(aItens[nI,1],nQtdZZ9,0,2 )
					ZZ9->ZZ9_UNDPR2 := aItens[nI,7]
					ZZ9->ZZ9_LOCAL  := aItens[nI,4]
				ZZ9->(MsUnLock())
			EndIf
		Next nI
		Aviso("Atenção","Requisição "+nReqMat+" gerada com sucesso.",{"Ok"})
	EndIf	
Else 
	Aviso("Atenção","Processo cancelado pelo operador.",{"Ok"})
EndIf
Return lRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DIPA060   ºAutor  ³Microsiga           º Data ³  09/29/16   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function DipRetSG1(cProduto)
Local lProcura := .T.             
Local aItens   := {}
Local nI       := 0

//______________________________
//                              |
//  aItens[1] - PRODUTO         |
//  aItens[2] - QUANTIDADE      |
//  aItens[3] - REQUISICAO?     |
//  aItens[4] - LOCAL PADRAO    |
//  aItens[5] - FLAG CONTROLE   |
//  aItens[6] - UM  		    |
//  aItens[7] - SEGUNDA UM      |
//______________________________|


SG1->(dbSetOrder(1))
If SG1->(dbSeek(xFilial("SG1")+cProduto)) 	
	While SG1->G1_COD == cProduto         
		SB1->(dbSetOrder(1))
		If SB1->(dbSeek(xFilial("SB1")+SG1->G1_COMP))
			aAdd(aItens,{SG1->G1_COMP,SG1->G1_QUANT,.T.,SB1->B1_LOCPAD,.T.,SB1->B1_UM,SB1->B1_SEGUM}) 			
		EndIf                                                                         
		SG1->(dbSkip())
	EndDo	
			
	While lProcura
		lProcura := .F.
		For nI:=1 to Len(aItens)
			If aItens[nI,5] 
				If SG1->(dbSeek(xFilial("SG1")+aItens[nI,1]))
					While SG1->G1_COD == aItens[nI,1]
						SB1->(dbSetOrder(1))
						If SB1->(dbSeek(xFilial("SB1")+SG1->G1_COMP))
							aAdd(aItens,{SG1->G1_COMP,SG1->G1_QUANT,.T.,SB1->B1_LOCPAD,.T.,SB1->B1_UM,SB1->B1_SEGUM}) 
						EndIf   
						aItens[nI,3] := .F.
						SG1->(dbSkip())
					EndDo	
					lProcura := .T.
				EndIf    		   
				aItens[nI,5] := .F.		
			EndIf
		Next nI   
		SG1->(dbSkip())
	EndDo
	
EndIf

Return aItens
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DIPA060   ºAutor  ³Microsiga           º Data ³  09/30/16   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function DipMaxD3()
Local cMaxSeq := ""
Local cSQL 	  := ""

cSQL := " SELECT "
cSQL += " 	MAX(D3_NUMSEQ) MAX "
cSQL += "	FROM 
cSQL += 		RetSQLName("SD3")
cSQL += "		WHERE "
cSQL += "			D_E_L_E_T_ = ' ' "

cSQL := ChangeQuery(cSQL)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),"QRYSD3",.T.,.T.)

If !QRYSD3->(Eof())
	cMaxSeq := QRYSD3->MAX
EndIf
QRYSD3->(dbCloseArea())

Return cMaxSeq
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DIPA060   ºAutor  ³Microsiga           º Data ³  09/30/16   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function GeraOSMP()
Local aHQOrdSep		:= {}
Local cCliente		:= ""
Local cLoja			:= ""
Local cLocal		:= ""
Local nItem			:= 0                  
Local cTransp		:= ""
Local cNumOrdSep    := ""
Local cNumReqMat    := ""
Private _oDLG                               

If ZZ8_STATUS==1 .And. ZZ8_IMPRES == 'S'

	If ! Empty(ZZ8_XORSEP) 
		Aviso("ATENÇÃO","OS já gerada para essa requisição, OS: "+ZZ8_XORSEP+".",{"Ok"})
		Return
	EndIf
	
	DEFINE FONT oBold   NAME "Arial" SIZE 0, -12 BOLD
	DEFINE FONT oBold2  NAME "Arial" SIZE 0, -20 BOLD 
	
	ZZA->(dbSetOrder(1))
	If ZZA->(dbSeek(xFilial("ZZA")+ZZ8->ZZ8_REQMAT))
		cNumReqMat := ZZ8->ZZ8_REQMAT
		While !ZZA->(Eof()) .And. ZZA->(ZZA_FILIAL+ZZA_REQMAT)==xFilial("ZZA")+ZZ8->ZZ8_REQMAT
		
			If Localiza(ZZA->ZZA_CODPRO)			
				
				SBE->(DbSetOrder(1))
				If SBE->( dbSeek(xFilial("SBE")+ZZA->ZZA_LOCAL+ZZA->ZZA_LOCALI))								
				   	If Empty(cNumOrdSep)
						cNumOrdSep :=  CB7->(GetSX8Num("CB7","CB7_ORDSEP"))
						ConfirmSX8()
					EndIf				
					
					aAdd(aHQOrdSep, {xFilial("CB8"),ZZA->ZZA_SEQUEN,ZZA->ZZA_REQMAT,ZZA->ZZA_CODPRO,ZZA->ZZA_LOCAL,ZZA->ZZA_QTDPRO,ZZA->ZZA_LOCALI,ZZA->ZZA_SEQUEN,ZZA->ZZA_LOTECT,cNumOrdSep,SBE->BE_XCODRUA} )							
				EndIf
			EndiF	
			IncProc()
			ZZA->( dbSkip() )
		EndDo
	EndIf
	
	If Len(aHQOrdSep) > 0
		
		BEGIN TRANSACTION             	
			CB7->(RecLock( "CB7",.T.))
				CB7->CB7_FILIAL := xFilial( "CB7" )
				CB7->CB7_ORDSEP := cNumOrdSep
				CB7->CB7_PEDIDO := cNumReqMat		
				CB7->CB7_CLIENT := cCliente		
				CB7->CB7_LOJA   := cLoja		
				CB7->CB7_COND   := ""			
				CB7->CB7_LOJENT := ""			
				CB7->CB7_LOCAL  := cLocal		
				CB7->CB7_DTEMIS := dDataBase
				CB7->CB7_HREMIS := Time()
				CB7->CB7_STATUS := "0"
				CB7->CB7_CODOPE := ""
				CB7->CB7_PRIORI := "1"
				CB7->CB7_ORIGEM := "1"
				CB7->CB7_TIPEXP := "00*02*06*10*"
				CB7->CB7_TRANSP := ""
				CB7->CB7_AGREG  := ""			          
				CB7->CB7_XTM  	:= "T"			
				CB7->CB7_XPRIOR := ""	
				CB7->CB7_XTOUM  := "T"	
				CB7->CB7_XREQMT := cNumReqMat
				cImpTpTer := "T"	
			CB7->(MsUnlock())
			
			nItem  := '00'
			For ix := 1 to len(aHQOrdSep)			
				nItem   := Soma1(nItem)		
				CB8->(RecLock("CB8",.T.))
					CB8->CB8_FILIAL := xFilial("CB8")
					CB8->CB8_ORDSEP := cNumOrdSep		//CB7->CB7_ORDSEP
					CB8->CB8_ITEM   := nItem			//SC9->C9_ITEM
					CB8->CB8_PEDIDO := cNumReqMat		//SC9->C9_PEDIDO
					CB8->CB8_PROD   := aHQOrdSep[ix,4]	//SDC->DC_PRODUTO
					CB8->CB8_LOCAL  := aHQOrdSep[ix,5]	//SDC->DC_LOCAL
					CB8->CB8_QTDORI := aHQOrdSep[ix,6]	//SDC->DC_QUANT
					CB8->CB8_SLDPRE := 0 				//SDC->DC_QUANT
					CB8->CB8_SALDOS := aHQOrdSep[ix,6]	//SDC->DC_QUANT
					CB8->CB8_SALDOE := aHQOrdSep[ix,6]	//0 //(aPalet[x,5]*aPalet[x,6])	//SDC->DC_QUANT
					CB8->CB8_LCALIZ := aHQOrdSep[ix,7]	//SDC->DC_LOCALIZ
					CB8->CB8_NUMSER := ""				//SDC->DC_NUMSERI
					CB8->CB8_SEQUEN := aHQOrdSep[ix,8]	//SC9->C9_SEQUEN
					CB8->CB8_LOTECT := aHQOrdSep[ix,9]	//SC9->C9_LOTECTL
					CB8->CB8_NUMLOT := ""				//SC9->C9_NUMLOTE
					CB8->CB8_CFLOTE := "1"				//If("10*" $ cTipExp,"1"," ")
					CB8->CB8_TIPSEP := ""				//If("09*" $ cTipExp,"1"," ")
					CB8->CB8_XLCALI := aHQOrdSep[ix,11]+CB8->(SubStr(CB8_LCALIZ,4,2)+SubStr(CB8_LCALIZ,1,2)+SubStr(CB8_LCALIZ,7,2))
				CB8->(MsUnLock())
				
				CB7->(RecLock("CB7",.F.))
					CB7->CB7_NUMITE++
				CB7->(MsUnLock())		
			Next ix
		END TRANSACTION
	EndIf
	              
	If !Empty(cNumOrdSep)
	
		DEFINE MSDIALOG _oDlg TITLE "Confirmação da ordem de separação!" FROM 280,197 TO 433,551 PIXEL         
	
			@ 006,007 TO 070,172 PROMPT "Orden(s) de separação gerada(s) com sucesso !"  PIXEL OF _oDlg		
	
			@ 025,010 Say " * Ordem  "+ALLTRIM(cNumOrdSep)  Size 200,009 PIXEL OF _oDlg FONT oBold COLOR CLR_HBLUE			
		
			@ 050,125 Button "Ok..." Size 037,012 PIXEL OF _oDlg Action( _oDlg:End() )
		
		ACTIVATE MSDIALOG _oDlg CENTERED
		
		ZZ8->(RecLock("ZZ8",.F.))
			ZZ8->ZZ8_XSTCB7 := "0" 
			ZZ8->ZZ8_XORSEP := cNumOrdSep
		ZZ8->(MsUnLock())
	Endif
	
	cNumOrdSep := ""
Else
	Help( ,, 'Help',, 'Gere o empenho e imprima o relatório antes de gerar a Ordem de Separação.', 1, 0 )
EndIf

Return
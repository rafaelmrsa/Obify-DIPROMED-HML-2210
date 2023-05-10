/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³DIPA046() ³ Autor ³Jailton B Santos-JBS   ³ Data ³12/05/2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Manutencao do cadastro de solicitacao de cancelamento de   ³±±
±±³          ³ notas fiscais.                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Especifico Faturamento Dipromed.                           ³±±                            
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±               
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³  Motivo da Alteracao                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³        ³                                                 ³±±
±±³            ³        ³                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
/*--------------------------------------------------------------------------------------------*/
#DEFINE AVALIACAO   '1' // Aguardando Avaliação do Diretor
#DEFINE FINANCEIRO  '2' // Aguardando Financeiro Tirar de Cobrança
#DEFINE AUTORIZADO  '3' // Aurorizado o Cancelamento NF  e Aguardando o cancelamento
#DEFINE CANCELADO   '4' // Nota Fiscal Cancelada
#DEFINE REPROVADO   '5' // Não Autorizado o Cancelamento
#DEFINE REAVALIACAO '6' // Aguardando Nova Avaliação do Diretor
#DEFINE DEVOLVIDA   '7' // Gerada automaticamente a NFE para devolucao
/*--------------------------------------------------------------------------------------------*/
User Function DIPA046(cCampo)

Local cAlias    := "SZL"
Local aCores    := {}
Local pString   := cAlias
Local pCadastro := "Solicitação de Cancelamentos de NF's"
Local aIndex	:= {}
Local bFiltraBrw

Private cCadastro:= "Solicitação de Cancelamentos de NF's"
Private cString  := pString
Private aRotina  := {}
Private cFiltra  := ""
Private aStatus  := {'Aguardando Avaliação','Aguardando Financeiro','Aprovado o Cancelamento','Cancelada','Reprovado Diretor','Aguardando Nova Avaliacao'}
//--------------------------------------------------------------------------------------------
// JBS 19/05/2010:
// Quando a condição abaixo for satisfeita, significa que o programa  DIPA046(x)  foi  chamado
// do X3_VALID de algum  campo da tabela SZL, com a sintaxe:"U_DIPA046("Nome do Campo"). Desta
// forma evita-se criar varios nomes de funções. Contemplando  a condição, a função statica de
// validação eh chamada e em seguida devolvido o resultado, validando ou não a edição do campo
// que está sendo editado pelo usuario.
//--------------------------------------------------------------------------------------------

//MCVN 31/08/10
If !U_DipUsr() $  AllTrim(GetMv("MV_DIPA46G"))
	Aviso('Atenção','Acesso negado temporariamente! ',{'OK'}) 	 
	Return()
Endif                                                         

If cCampo <> NIL
	Return(fValid(cCampo))
EndIf

dbSelectArea(cAlias)

aAdd(aRotina , {"Pesquisar"    ,"AxPesqui"       ,0,1} )
aAdd(aRotina , {"Visualizar"   ,"AxVisual"       ,0,2} )
aAdd(aRotina , {"Incluir"      ,"U_DIPA046MA"    ,0,3} )
aAdd(aRotina , {"Alterar"      ,"U_DIPA046MA"    ,0,4} )
aAdd(aRotina , {"Excluir"      ,"U_DIPA046MA"    ,0,5} )
If U_DipUsr() $ AllTrim(GetMv("MV_DIPA46V"))
	aAdd(aRotina , {"Avaliar"      ,"U_DIPA046MA" ,0,6} )
EndIf

aAdd(aRotina , {"Legenda"      ,"U_DIPA046LE" ,0,7} )

aAdd(aCores , {'ZL_STATUS = "1"','BR_AMARELO' } )
aAdd(aCores , {'ZL_STATUS = "2"','BR_AZUL'    } )
aAdd(aCores , {'ZL_STATUS = "3"','BR_VERDE'   } )
aAdd(aCores , {'ZL_STATUS = "4"','BR_PRETO'   } )
aAdd(aCores , {'ZL_STATUS = "5"','BR_VERMELHO'} )
aAdd(aCores , {'ZL_STATUS = "6"','BR_LARANJA'} )
aAdd(aCores , {'ZL_STATUS = "7"','BR_PINK'} )

dbSelectArea(cString)
dbSetOrder(1)

mBrowse(6,1,22,75,cString,,,,,,aCores)

Return
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³DIPA046LE()³Autor ³Jailton B Santos-JBS   ³ Data ³13/05/2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Funcao chamada quando for usuario de diretoria (Eriberto),  ³±±
±±³          ³para avaliar a solicita~cao de cancelamento e determinar    ³±±
±±³          ³o se pode ou nao cancelar a Nota Fiscal em questao.         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Especifico Faturamento Dipromed.                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function DIPA046LE()

Local aLegenda:={}

aAdd(aLegenda, {'BR_AMARELO' ,"Aguardando Avaliação do Diretor"                            } )  // 1
aAdd(aLegenda, {'BR_AZUL'    ,"Aguardando Financeiro Tirar de Cobrança"                    } )  // 2
aAdd(aLegenda, {'BR_VERDE'   ,"Aurorizado o Canc/to NF e Aguard.Canc/to" } )  // 3
aAdd(aLegenda, {'BR_PRETO'   ,"Nota Fiscal Cancelada"                                      } )  // 4
aAdd(aLegenda, {'BR_VERMELHO',"Não Autorizado o Cancelamento"                              } )  // 5
aAdd(aLegenda, {'BR_LARANJA' ,"Aguardando Nova Avaliação do Diretor"                       } )  // 6
aAdd(aLegenda, {'BR_PINK'    ,"NFS Devolvida com NFE.Fora do Prazo SEFAZ" } )  // 7

BrwLegenda("Nota Fiscal",OemToAnsi("Nota Fiscal"),aLegenda)

Return
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³DIPA046LE()³Autor ³Jailton B Santos-JBS   ³ Data ³13/05/2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Funcao usada para incluir, alterar, excluir e validar       ³±±
±±³          ³o processo de cancelamento da nota fiscal.                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Chamadas: ³1o.mBrowse do proprio Dipa046.PRW (inluir,alterar e excluir)³±±
±±³          ³   e rotina de avaliacao do processo.                       ³±±
±±³          ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³2o.Foi chamada do P.E. Ms520Del(), depois do cancelamento da³±±
±±³          ³   nota fiscal. (Registra a Exclusao da NF no Processo)     ³±±
±±³          ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³3o.foi chamada do P.E. FA060TRAN(), depois da transferencia ³±±
±±³          ³   do titulos de cobranca. (Libera exclusao pelo Financeiro)³±±
±±³          ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³4o.Confirmacao do da inclusao do processo, para enviar email³±±
±±³          ³   e CIC para avaliacao do processo.                        ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Especifico Faturamento Dipromed.                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function DIPA046MA(cAlias,nReg,nOpc) // Avalia tipo de manutenção e a processa.

Local nRet    := 0
Local cMsg    := ''
Local cEmailTo:= ''
Local cCicTo  := ''
Local lRet    := .T.     
Local cUser   := U_DipUsr()                                                                                                   
Local cExSCNf := GetNewPar("ES_EX_SCNF","")//Parâmetro contém usuários autorizados a excluir solicitacao de cancelamento de NF.  RBorges 11/06/2013

Private cDipUsu    := ""
Private cSetor     := ""
Private lDipa046Dv := .T. // Usado do P.E. MT103LDV

PswOrder(2)                       // Ordena pelo nome do usuario (login)
If PswSeek(cUser)
	cDipUsu := PswRet(1)[1][4]   // Nome completo do usuario
	cSetor  := PswRet(1)[1][12]  // Retorna o nome do setor de trabalho do usuario
EndIf
PswOrder(1)

do case
	case nOpc = 3
	
			INCLUI := .T.
			ALTERA := .F.
			
		
		Private cHstrNFE := ""
		AxInclui(cAlias,nReg,nOpc,,,,"U_DIPA046MA(,,8)")
		
	case nOpc = 4
		
		If SZL->ZL_STATUS $ (AVALIACAO + FINANCEIRO + AUTORIZADO + REPROVADO + REAVALIACAO) .and. U_DipUsr()==AllTrim(SZL->ZL_USUARIO)
			
			INCLUI := .F.
			ALTERA := .T.
			
			Private cHstrNFE := ""                             
			nRet := AxAltera(cAlias,nReg,nOpc)
			
			If nRet = 1 .and. Aviso('Atenção','Deseja solicitar uma nova avaliação deste Processo? ',{'Sim','Não'}) == 1
				
				mHistorico :=  '( ' + AllTrim(cDipUsu) + ' ) '
				mHistorico += 'Solicitado Nova avaliação deste processo, em '+dToc(dDataBase)+' as ' + Time() +' Horas.' + Chr(13)+chr(10)
				
				If fHistorico()
					
					SZL->(Reclock('SZL',.F.))
					SZL->ZL_STATUS := '6' // Reavalição da Diretoria, ou seja, do Big Box, ou seja, do Sr Eriberto
					SZL->ZL_HISTORI:= mHistorico + SZL->ZL_HISTORI
					SZL->(MsUnlock('SZL'))
					
					cEmailTo := AllTrim(GetMv('MV_DIPA46A')) // Email do diretor de avaliacao da solicitacao
					cCicTo   := AllTrim(GetMv('MV_DIPA46D')) // CIC do Usuario
					
					If !Empty(cEmailTo)
						fEmail(cEmailTo)
						fCic(cCicTo, mHistorico,.f.) //
					EndIf
				Else
					Aviso('Atenção','Você não confirmou a solicitação de nova avaliação. A Solicitação permanecerá em '+aStatus[Val(SZL->ZL_STATUS)]+'.',{'OK'})
				EndIf
			EndIf
		Else
			Aviso('Atenção','Solicitação não pode ser alterada',{'OK'})
		EndIf
		
	case nOpc = 5  // Exclusão de um processo de cancelamento.
		
	       //lRet := U_DipUsr() == AllTrim(SZL->ZL_USUARIO) //Padrão
			lRet := Upper(U_DipUsr()) $ Upper((AllTrim(SZL->ZL_USUARIO))+"/"+cExSCNf) //RBorges 11/06/2013
		If lRet	
	   		nRet := AxDeleta(cAlias,nReg,nOpc)
		Else
			Aviso('Atenção','Apenas o usuario que gerou a solicitação pode exclui-la!!!!',{'OK'})

		EndIf
	
		
	case nOpc = 6 // Chama a função de avaliação do processo
		
		nRet := fAvalia(cAlias,nReg,nOpc)
		
	case nOpc = 8 // chamada do AxInclui para disparar o e-mail
		
		cMsg := 'O Usuario ' + AllTrim(M->ZL_USERNAM)
		cMsg += ', do Setor de ' + AllTrim(M->ZL_SETOR)
		cMsg += ',  solicitou o cancelamento da nota fiscal ' + M->ZL_NOTA
		cMsg += ' / ' + M->ZL_SERIE
		cMsg += ', em ' + Dtoc(M->ZL_DATA)
		cMsg += ' as '
		cMsg += M->ZL_HORA
		cMsg += ' horas.' + cHstrNFE 
		cMsg += Chr(13) + chr(10)
		
		M->ZL_HISTORI := cMsg + M->ZL_HISTORI 
		//--------------------------------------------------------------------------------------------------------
		// Lê email diretor de avaliação
		//--------------------------------------------------------------------------------------------------------
		cEmailTo := AllTrim(GetMv('MV_DIPA46A')) // Email do diretor de avaliacao da solicitacao
		cCicTo   := AllTrim(GetMv('MV_DIPA46D')) // CIC do Usuario
		//--------------------------------------------------------------------------------------------------------  
		// Busca e-mail e Cic do usuário que incluiu a solicitação de cancelamento   MCVN - 04/03/2011
		PswOrder(2)   
		If PswSeek(cUser)                                                                                              
			cEmailTo += ";"+PswRet(1)[1][14]    
		EndIf
		//--------------------------------------------------------------------------------------------------------  
		If !Empty(cEmailTo)
			fEmail(cEmailTo)
			fCic(cCicTo, cMsg,.f.) //
		EndIf
		
		Aviso('Atenção','Imprima uma cópia da DANFE para arquivar! ',{"OK"})
		
	case nOpc = 9  // JBS 24/05/2010
		//--------------------------------------------------------------------------------------------------------
		// Esta funcionalidade foi chamada do P.E. Ms520Del(), depois do cancelamento da nota fiscal.
		// para registrar o historico de cancelamento da nota fiscal.
		//--------------------------------------------------------------------------------------------------------
		PswOrder(2)
		cDipUsu := ''
		cSetor  := ''
		If PswSeek(cUser) // Busca usuario corrento do sistema.
			cDipUsu := PswRet(1)[1][4]
			cSetor  := PswRet(1)[1][12]
		EndIf
		PswOrder(1)
		//--------------------------------------------------------------------------------------------------------
		cMsg := '( ' + AllTrim(cDipUsu) + ' ) Nota Fiscal cancelada em ' + dtoc(dDataBase) + ' as ' + Time() + ' hora(s), pelo usuario ('+U_DipUsr()+') '+ AllTrim(cDipUsu) + ', do setor de '+cSetor + '. '
		cMsg += chr(13)+chr(10) 
		//--------------------------------------------------------------------------------------------------------
		SZL->( RecLock('SZL', .F.) )
		SZL->ZL_STATUS := '4'
		SZL->ZL_HISTORI:=  cMsg + SZL->ZL_HISTORI 
		SZL->( MsUnloCK('SZL'))
		//--------------------------------------------------------------------------------------------------------
		cEmailTo := ''
		cCicTo   := ''
		PswOrder(2)
		//--------------------------------------------------------------------------------------------------------
		// Busca o e-mail do usuario no cadastro de usuario
		//--------------------------------------------------------------------------------------------------------
		If !Empty(SZL->ZL_USUARIO) .And. PswSeek(SZL->ZL_USUARIO)
			cCicTo   := PswRet(1)[1][01]
			cEmailTo := PswRet(1)[1][14]
		EndIf             
	
		If SZL->ZL_ONDE == '1' //Mercadoria no CD
			cEmailTo += ";"+GetNewPar("ES_DIP46CE","diego.domingos@dipromed.com.br")     
		Endif
		//--------------------------------------------------------------------------------------------------------
		// Envia e-mail para o usuario que solicitou o cancelamento
		//--------------------------------------------------------------------------------------------------------
		If !Empty(cEmailTo)
			fEmail(cEmailTo)
			fCic(cCicTo, "Nota Fiscal " + AllTrim(SZL->ZL_NOTA) + '/'+AllTrim(SZL->ZL_SERIE) + ' foi cancelada em ' + dtoc(dDataBase) + ' as ' + Time() + ' hora(s), conforme a solictação '+SZL->ZL_CODIGO+'.' ,.T.,IIf(SZL->ZL_ONDE == '1',nOpc,0)) //
		EndIf
		
	case nOpc = 10 // JBS 24/05/2010
		//--------------------------------------------------------------------------------------------------------
		// Esta funcionalidade foi chamada do P.E. FA060TRAN(), depois da transferencia do titulos de cobranca
		// para carteira, ou seja, retirado o titulo do banco e liberado o cancelamento da nota pelo financeiro.
		//--------------------------------------------------------------------------------------------------------
		PswOrder(2)
		cDipUsu := ''
		cSetor  := ''
		If PswSeek(cUser) // Busca usuario corrento do sistema.
			cDipUsu := PswRet(1)[1][4]
			cSetor  := PswRet(1)[1][12]
		EndIf
		PswOrder(1)
		//--------------------------------------------------------------------------------------------------------
		cMsg := '( ' + AllTrim(cDipUsu) + ' ) Titulo da nota fiscal retirado da cobrança em ' + dtoc(dDataBase) + ' as ' + Time() + ' hora(s), pelo usuario ('+U_DipUsr()+') '+ AllTrim(cDipUsu) + ', do setor de '+cSetor + '. '
        cMsg += chr(13)+chr(10)		
		//--------------------------------------------------------------------------------------------------------
		SZL->( Reclock('SZL',.F.) )
		SZL->ZL_HISTORI :=  cMsg  + SZL->ZL_HISTORI
		SZL->ZL_STATUS  := '3' // Autoriza o Cancelamento
		SZL->( MsUnLock('SZL') )
		//--------------------------------------------------------------------------------------------------------
		// Lê do departamento fiscal: Dona Magda / Senhor William
		//--------------------------------------------------------------------------------------------------------
		//cEmailTo := AllTrim(GetMv('MV_DIPA46C')) // Enviado para a Pessoa que é responsavel pelo cancelamento
		//cCicTo   := AllTrim(GetMv('MV_DIPA46E')) // CIC do Usuario
		//--------------------------------------------------------------------------------------------------------
		// Envia e-mail para o usuario que solicitou o cancelamento
		//--------------------------------------------------------------------------------------------------------
		//If !Empty(cEmailTo)
		//	fEmail(cEmailTo)
		//	fCic(cCicTo, "Nota Fiscal "+AllTrim(SZL->ZL_NOTA) + '/'+AllTrim(SZL->ZL_SERIE) + ' Autorizado o Cancelamento pelo financeiro em ' + dtoc(dDataBase) + ' as ' + Time() + ' hora(s), conforme a solictação '+SZL->ZL_CODIGO+'.',.f.) //
		//EndIf                            
		
	case nOpc = 11 // JBS 12/08/2010 - Avalia se cria novo endereco para mercadoria  e ou devolve no endereco original
	
	     If type("lDip46GrD3") <> "U"
	         If lDip46GrD3 
	            Return(1)
	         Else
	            Return(0)
	         EndIf
	     Else 
             Return(2)
	     Endif   
		
EndCase

Return(lRet)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³DIPA046AV()³Autor ³Jailton B Santos-JBS   ³ Data ³13/05/2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Funcao chamada quando for usuario de diretoria (Eriberto),  ³±±
±±³          ³para avaliar a solicita~cao de cancelamento e determinar    ³±±
±±³          ³o se pode ou nao cancelar a Nota Fiscal em questao.         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Especifico Faturamento Dipromed.                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function fAvalia()

Local nOpcao      := 0                              
Local nHoras      := 0                              
Local lMesFechado := .F.
Local cMsg        := ''
Local cCicTo      := ''
Local cMsgCIC     := ''
Local cEmailTo    := ''
Local aCabNF      := {}
Local lRet        := .T.                                                                               '
Local lAchou      := .F. 
Local lGerouNFE   := Nil  
Local nSpedExc    := GetNewPar("MV_SPEDEXC",72) 


Local oDlg
Local bOk         := {|| nOpcao := 1 , oDlg:End() }
Local bCancel     := {|| nOpcao := 2 , oDlg:End() }
Local bVisual     := {|| fConsultaNF() }
Local bVoltar     := {|| nOpcao := 3 , oDlg:End() }
Local lTransferiu := .F.
Local cUser		  := U_DipUsr()
Local cLockSep	 := "SEPARANDO..."

Private nPDevLoc  := 0   // JBS 12/08/2010  - 0 = Cria um registro no SDA ( a classificar), 1 = Grava no SDB (Endereco original) 2 = Abre tela.
Private cSetor    := ''
Private cDipUsu   := ''
Private cNroNota  := ''
Private cNroSerie := ''
Private mHistorico:= ''        
Private _ZD_EXPLIC:= SZL->ZL_MOTIVO // Sera usado no P.E. "MSD2520" na gravacao do "SZD".
Private lDip46GrD3:= .F. // JBS 26/07/2010 - Determina se gera ou não o SD3
Private lDelSF2   := .T. //                - Determina se o processo de cancelamento ocorreu com sucesso. 
Private lDipa046  := .T. //                - Determina que algumas rotinas de P.E. foram chamadas a partir deste programa

Private aCabSD3   := {}  // JBS 18/08/2010 - Cabecario para o geracao de SD3 - P.E. MSD2520 preenche-os
Private aRegSD3   := {}  // JBS 18/08/2010 - Itens para a geracao de SD3

PswOrder(2)

If PswSeek(cUser)
	cDipUsu := PswRet(1)[1][4]
	cSetor  := PswRet(1)[1][12]
EndIf

PswOrder(1)

Do case
	case SZL->ZL_STATUS $ (AVALIACAO + REAVALIACAO)
		
		cMsg := ''

		SF2->( DbSeek(xFilial('SF2') + SZL->ZL_NOTA + SZL->ZL_SERIE) )
		nHoras := nSpedExc - SubtHoras( SF2->F2_EMISSAO, SF2->F2_HORA, dDataBase, substr(Time(),1,2)+":"+substr(Time(),4,2) )
		lMesFechado := If(AnoMes((FirstDay(dDataBase))-1)=AnoMes(GetNewPar("MV_ULMES",cToD(""))) .And. AnoMes(SF2->F2_EMISSAO) <> AnoMes(dDataBase),.T.,.F.)

		SE1->( DbSetOrder(1) ) 
		SE1->( DbGotop() )
	   
		lAchou := SE1->(DbSeek(xFilial('SE1') + SF2->F2_PREFIXO + SF2->F2_DUPL +'A')) //.or.SE1->( DbSeek(xFilial('SE1') + SZL->ZL_SERIE + SZL->ZL_NOTA+' ') )
		
	    Iif(nHoras <= 0                           					 ,cMsg += 'Prazo de Cancelamento dado pelo SEFAZ está EXPIRADO. ',)
   	    Iif(lMesFechado                      					     ,cMsg += 'Mês de referência da NF foi fechado. (MV_ULMES). ',)
	    Iif(!Empty(SE1->E1_BAIXA)               					 ,cMsg += 'Esta Nota Fiscal possui titulos pagos. ',)
		IIf(nHoras <= 0 .OR. !Empty(SE1->E1_BAIXA) .or. lMesFechado  ,cMsg += 'Não poderá ser cancelada, será feita uma nota fiscal de devolução. ' + CHR(13) + CHR(10),)

		cMsg += 'Motivo: '
		cMsg += Chr(13) + chr(10)
		cMsg += AllTrim(SZL->ZL_MOTIVO)
		cMsg += Chr(13) + chr(10)
		cMsg += Chr(13) + chr(10)
		cMsg += 'Histórico: '
		cMsg += Chr(13) + chr(10)
		cMsg += AllTrim(SZL->ZL_HISTORI)
		cMsg += Chr(13) + chr(10)
		cMsg += 'Outras Informações: '
		cMsg += Chr(13) + chr(10)
		cMsg += AllTrim(SZL->ZL_DADOS)
		
		nOpcao := 0
		
		Define MsDialog oDlg Title "Avalição do Processo" from 0,0 to 250,600 of oMainWnd pixel
        @ 02,002 Get cMsg Size 250,120 MEMO  when .f. Of oDlg Pixel
        @ 10,256 Button OemToAnsi("Aprovar")      size 40,15 pixel of oDlg action eval(bOk)
        @ 34,256 Button OemToAnsi("Reprovar")     size 40,15 pixel of oDlg action eval(bCancel)
        @ 58,256 Button OemToAnsi("Visualia NF")  size 40,15 pixel of oDlg action eval(bVisual)
        @ 82,256 Button OemToAnsi("Voltar")       size 40,15 pixel of oDlg action eval(bVoltar)
        Activate MsDialog oDlg Centered
		
		//nOpcao := Aviso('Atenção',cMsg, {'Aprovar','Reprovar','Voltar'})
		cEmailTo := ''
		
		Begin Sequence
		
		If nOpcao = 1
			
			If !LockByName(cLockSep,.T.,.T.)
				Aviso("Atenção","Não foi possível ter acesso exclusivo. Tente novamente.",{"Ok"},1) 
                Return .F.
			EndIf
			
			lDip46GrD3 := (SZL->ZL_ONDE == '2') // Quando a Mercadoria no Cliente Gera o SD3  - JBS 26/07/2010
			nPDevLoc   := Iif(SZL->ZL_ONDE == '2' .Or. SF2->F2_TIPO $ 'DB',1,0) // Quando estiver no cliente ou quando for nota de devolução ou beneficiamento JBS 12/08/2010 devolve no endereco original 
			  	
			If nHoras <= 0 .OR. ( lAchou .and. !Empty(SE1->E1_BAIXA) ) .OR. lMesFechado
				
				If Aviso('Atenção','Confirma a Geração automatica da nota fiscal de devolução para esta nota fiscal de saida?',{'Sim','Não'}) == 1 .and. fGeraNFE()
					
					lGerouNFE := .T.
					
					SZL->( Reclock('SZL',.F.) )
					SZL->ZL_HISTORI := '( '+AllTrim(cDipUsu)+' ) Gerado a NFE Nro: '+cNroNota+' da serie: '+cNroSerie+	'. Para efetuar devolução da NF Nro: ' + AllTrim(SZL->ZL_NOTA) + ' da serie: '+AllTrim(SZL->ZL_SERIE) + ' em ' + dToc(dDataBase)+' as '+Time()+' Horas. ' + chr(13)+chr(10)	+ SZL->ZL_HISTORI	
					SZL->ZL_STATUS  := '7' // Gerou nota fiscal de devolucao
					SZL->( MsUnLock('SZL') )
					//--------------------------------------------------------------------------------------------------------
					// Lê do departamento fiscal: Dona Magada / Senhor William
					//--------------------------------------------------------------------------------------------------------
					cEmailTo := AllTrim(GetMv('MV_DIPA46C'))+IIF(SZL->ZL_ONDE == '1',";"+GetNewPar("ES_DIP46CE","diego.domingos@dipromed.com.br"),"")      // Enviado para a Pessoa que é responsavel pelo cancelamento
					cCicTo   := AllTrim(GetMv('MV_DIPA46E'))+IIF(SZL->ZL_ONDE == '1',","+GetNewPar("ES_DIP46CI","DIEGO.DOMINGOS,MAXIMO.CANUTO"),"") // CIC do Usuario
					//--------------------------------------------------------------------------------------------------------
					cMsgCIC := "Gerado a NFE Nro: " + cNroNota + " da serie: " + cNroSerie + ". Para efetuar devolução da NF Nro: " + AllTrim(SZL->ZL_NOTA) + ' da serie: ' + AllTrim(SZL->ZL_SERIE) + " em " + dToc(dDataBase)+" as "+Time()+" Horas. "
					//--------------------------------------------------------------------------------------------------------                                                                                                                          
					U_DiprKardex(SZL->ZL_PEDIDO,U_DipUsr(),"Gerado a NFE: " + cNroNota + " - " + cNroSerie,.t.,"24") /// MCVN 05/01/211                           
 	 		        //--------------------------------------------------------------------------------------------------------
 	 		         	 		        
					If lAchou // SE1->E1_NUMBCO <> '' .and. SE1->E1_SITUACA <> '0'
						
						SZL->( Reclock('SZL',.F.) )
						SZL->ZL_HISTORI := '( '+AllTrim(cDipUsu)+' ) Solicitado ao Dep.Financeiro que faça a consolidação dos titulos da nota de entrada com os da nota fiscal de saida.' + Chr(13)+chr(10) + SZL->ZL_HISTORI
					    SZL->( MsUnLock('SZL') )
						//--------------------------------------------------------------------------------------------------------
						// Lê o e-mail do financeiro
						//--------------------------------------------------------------------------------------------------------
						cEmailTo += ';' + AllTrim(GetMv('MV_DIPA46B'))
						cCicTo   += ',' + AllTrim(GetMv('MV_DIPA46F')) // CIC do Usuario
						//--------------------------------------------------------------------------------------------------------
						cMsgCIC += 'Solicitado ao Dep.Financeiro que faça a consolidação dos titulos da nota de entrada com os da nota fiscal de saida.'
					EndIf
					
					INCLUI := .F.
					
					If !Empty(cMsgCIC)
						fCic(cCicTo,cMsgCIC,.f.) //
					EndIF
					
					If !Empty(cEmailTo)
						fEmail(cEmailTo,nOpcao)
					EndIf
				EndIf

				Break

			EndIf
			//--------------------------------------------------------------------------------------------------------
			// Faz o cancelamento automatico da nota fiscal
			//--------------------------------------------------------------------------------------------------------
		    aCabNF := {}
            aAdd(aCabNF,{"F2_DOC"  , SZL->ZL_NOTA  ,nil})
            aAdd(aCabNF,{"F2_SERIE", SZL->ZL_SERIE ,nil})
			//--------------------------------------------------------------------------------------------------------
			If lAchou 
			
				//--------------------------------------------------------------------------------------------------------
				// Lê do departamento fiscal: Dona Magada / Senhor William
				//--------------------------------------------------------------------------------------------------------
				cEmailTo := AllTrim(GetMv('MV_DIPA46C')) // Enviado para a Pessoa que é responsavel pelo cancelamento
				//--------------------------------------------------------------------------------------------------------
				cDadoTit := ''
				If SE1->E1_NUMBCO <> '' .and. SE1->E1_SITUACA <> '0' 

				    cDadoTit += 'Portador: ' + SE1->E1_PORTADO  
				    cDadoTit += ' Agencia: ' + SE1->E1_AGEDEP   
				    cDadoTit += ' Conta: '   + SE1->E1_CONTA    
				    cDadoTit += ' Codigo Bancario: ' + SE1->E1_NUMBCO 
				    cDadoTit += ' Bordero nro: ' + SE1->E1_NUMBOR 
				    
			        cParcela := ''
			        cSepara  := ''

				    Do While SE1->(!EOF()) .and.;
				             SE1->E1_FILIAL == xFilial('SE1') .and.;
				             SE1->E1_PREFIXO == SZL->ZL_SERIE .and.;
				             SE1->E1_NUM == SZL->ZL_NOTA
				       
				        SE1->( RecLock('SE1',.F.) )       
				        SE1->E1_NUMBCO   := ''
				        SE1->E1_CONTA      := ''			       
				        SE1->E1_AGEDEP    := ''				       
				        SE1->E1_PORTADO := ''
				        SE1->E1_NUMBOR	 := ''			       
				        SE1->E1_SITUACA  := '0'
				        SE1->( MsUnLock('SE1') )  
				        
				        If !Empty(SE1->E1_PARCELA)
				            cParcela += cSepara + "'"+AllTrim(SE1->E1_PARCELA)+"'"
				            cSepara := ', '
				        EndIf   
   				        
   				        lTransferiu := .T.
   				        
   				        SE1->( DbSkip() )
                    
                    EndDo  
                    
                    If !Empty(cParcela) 
                        cDadoTit += ' Parcelas: ' + cParcela + '.' 
                    EndIf    
				
				EndIf 

				SZL->( MsUnLock('SZL') )                                                   
				//---------------------------------------------------------------------------------------
				// Documenta Historico de transferencia de titulo da cobranca para carteira.
				//---------------------------------------------------------------------------------------
				If lTransferiu
			        SZL->(U_DIPA046MA('SZL',SZL->(Recno()),10))
				EndIf
       
                   
				SZL->( Reclock('SZL',.F.) )
				SZL->ZL_HISTORI := '( '+AllTrim(cDipUsu)+' ) Solicitação de Cancelamento Autorizado pelo Diretor em '+dToc(dDataBase)+'  as '+Time()+' Horas. ' + Chr(13) + chr(10) + SZL->ZL_HISTORI
				SZL->ZL_STATUS  := AUTORIZADO // Autoriza direto
				SZL->( MsUnLock('SZL') )

                lDelSF2 := .T.
                U_UMata520(aCabNF) // Transformado em funcao do usuario  - JBS 12/08/2010
                     
                If lDelSF2 
              
                     If !Empty(cDadoTit)
  
				         SZL->( Reclock('SZL',.F.) )
				         SZL->ZL_HISTORI := '( '+AllTrim(cDipUsu)+' ) Informado ao financeiro que a Nota Fiscal ' + SZL->ZL_NOTA + '/' + AllTrim(SZL->ZL_SERIE) + ' foi cancelada. Solicitado ao financeiro retirar o titulo do banco( ' + cDadoTit + ' ) as '+Time()+' Horas, do dia '+dToc(dDataBase)+'.' + Chr(13)+chr(10) + SZL->ZL_HISTORI
				         SZL->ZL_STATUS  := CANCELADO // Autoriza direto
				         SZL->( MsUnLock('SZL') )
				
				         cEmailTo += AllTrim(GetMv('MV_DIPA46B'))
				         cCicTo   := AllTrim(GetMv('MV_DIPA46F')) // CIC do Usuario
				         //--------------------------------------------------------------------------------------------------------
				         fCic(cCicTo, "Nota Fiscal "+AllTrim(SZL->ZL_NOTA) + '/'+AllTrim(SZL->ZL_SERIE) + ' foi Cancelada.  Tirar titulos ( ' + cDadoTit + ' )da Cobrança a partir das '+Time()+' Horas, do dia '+dToc(dDataBase)+'.',.f.) 
			  
				 	 EndIf 
   				     //--------------------------------------------------------------------------------------------------------
				     U_DiprKardex(SZL->ZL_PEDIDO,U_DipUsr(),"NF "+AllTrim(SZL->ZL_NOTA) ,.t.,"18") // MCVN 05/01/211
				     //--------------------------------------------------------------------------------------------------------	 
				Else
				     Aviso('Atenção','Encontrado Problema no cancelamento da NF. Não possivel fazer o cancelameno.',{'OK'})    
				EndIf
				
			Else 
                
                lDelSF2 := .T.
                U_UMata520(aCabNF) // Transformado em funcao do usuario  - JBS 12/08/2010
                
                If lDelSF2   
				    //--------------------------------------------------------------------------------------------------------
				    // Atualiza o Status da solicitacao de cancelamento
				    //--------------------------------------------------------------------------------------------------------
				    SZL->( Reclock('SZL',.F.) )
				    SZL->ZL_HISTORI := '( '+AllTrim(cDipUsu)+' ) Solicitação de Cancelamento Autorizada e NF Cancelada pelo Diretor em '+dToc(dDataBase)+'  as '+Time()+' Horas. ' + Chr(13) + chr(10) + SZL->ZL_HISTORI
				    SZL->ZL_STATUS  := CANCELADO // Autoriza direto
				    SZL->( MsUnLock('SZL') )
				    //--------------------------------------------------------------------------------------------------------
				    // Lê do departamento fiscal: Dona Magda/ Senhor William
				    //--------------------------------------------------------------------------------------------------------
				    cEmailTo := AllTrim(GetMv('MV_DIPA46C')) // Enviado para a Pessoa que é responsavel pelo cancelamento
				    cCicTo   := AllTrim(GetMv('MV_DIPA46F')) // CIC do Usuario
				    //--------------------------------------------------------------------------------------------------------
				    fCic(cCicTo, "Nota Fiscal "+AllTrim(SZL->ZL_NOTA) + '/'+AllTrim(SZL->ZL_SERIE) + ' Solicitação de Cancelamento Autorizado e Cancelado pelo Diretor em '+dToc(dDataBase)+'  as '+Time()+' Horas. ',.f.) //
   				     //--------------------------------------------------------------------------------------------------------
				     U_DiprKardex(SZL->ZL_PEDIDO,U_DipUsr(),"NF "+AllTrim(SZL->ZL_NOTA) ,.t.,"18") // MCVN 05/01/211
				     //--------------------------------------------------------------------------------------------------------	 
				Else
				    Aviso('Atenção','Encontrado Problema no cancelamento da NF. Não possivel fazer o cancelameno.',{'OK'})    
			    EndIf
			EndIf 
			//--------------------------------------------------------------------------------------------------------
  		    // Lê o e-mail do financeiro
			//--------------------------------------------------------------------------------------------------------
			If !Empty(cEmailTo) .and. lDelSF2
				fEmail(cEmailTo,nOpcao)
			EndIf
			
			UnlockByName(cLockSep,.T.,.T.)
				
		ElseIf nOpcao = 2   // Não Autorizou
			
			mHistorico := '( '+AllTrim(cDipUsu)+' ) Solicitação de Cancelamento Reprovada pelo Diretor em '+dToc(dDataBase)+'  as '+Time()+' Horas. ' + Chr(13) + chr(10) + SZL->ZL_HISTORI
			
			If fHistorico()
				SZL->( Reclock('SZL',.F.) )
				SZL->ZL_HISTORI := mHistorico
				SZL->ZL_STATUS  := '5' // Não Autorizado o Cancelamento
				SZL->( MsUnLock('SZL') )
				//--------------------------------------------------------------------------------------------------------
				// Envia e-mail para usuario que incluiu a solicitacao de cancelamento, informando que nao aprovado o
				// cancelamento da nota fiscal.
				//--------------------------------------------------------------------------------------------------------
				cEmailTo := ''
				cCicTo   := ''                                                                            
				PswOrder(2)
				If !Empty(SZL->ZL_USUARIO) .And. PswSeek(SZL->ZL_USUARIO)
					cCicTo   := PswRet(1)[1][01] // Codigo de usuario protheus  do usuario do financeiro
					cEmailTo := PswRet(1)[1][14]
				EndIf
				If !Empty(cEmailTo)
					fEmail(cEmailTo,nOpcao)
					fCic(cCicTo, "Nota Fiscal "+AllTrim(SZL->ZL_NOTA) + '/'+AllTrim(SZL->ZL_SERIE) + ' Solicitação de Cancelamento Reprovada pelo Diretor em '+dToc(dDataBase)+'  as '+Time()+' Horas. ',.t.) //
				EndIf
			Else
				Aviso('Atenção','Você não confirmou a reprovação. A Solicitação permanecerá em aberto.',{'OK'})
			EndIf
		EndIf
		
		End Sequence

	case SZL->ZL_STATUS == FINANCEIRO ; Aviso('Atenção','Aguardando o financeiro retirar o titulo da cobrança.'  ,{'OK'}); lRet := .F.
	case SZL->ZL_STATUS == AUTORIZADO ; Aviso('Atenção','Esta nota fiscal já está Autorizada para cancelamento.' ,{'OK'}); lRet := .F.
	case SZL->ZL_STATUS == CANCELADO  ; Aviso('Atenção','Esta Nota Fiscal já está Cancelada no Sistema.'         ,{'OK'}); lRet := .F.
	case SZL->ZL_STATUS == REPROVADO  ; Aviso('Atenção','Esta Nota Fiscal já foi avaliada e Reprovada.'          ,{'OK'}); lRet := .F.
	case SZL->ZL_STATUS == REAVALIACAO; Aviso('Atenção','Esta Nota Fiscal já foi colocada em estado reavaliação.',{'OK'}); lRet := .F.
		
EndCase

Return(lRet)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ fValid()  ³Autor ³Jailton B Santos-JBS   ³ Data ³12/05/2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Esta funcao foi criada para fazer todas as validacoes de    ³±±
±±³          ³campos da tabela SZL.                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Especifico Faturamento Dipromed.                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function fValid(cCampo)

Local lRet    := .T.
Local nHoras  := 0
Local lMesFechado := .F.
Local nSpedExc:= GetNewPar("MV_SPEDEXC",72)
Local dDataF  := dDataBase
Local cHoraF  := substr(Time(),1,2)+":"+substr(Time(),4,2)

Do Case
	case (cCampo == 'NOTA' .or. cCampo == 'SERIE' ).and. !Empty(M->ZL_NOTA) .and. !Empty(M->ZL_SERIE)
		
		Begin Sequence 
		
			
		SF2->( DbSetOrder(1))
		
		If SF2->( !DbSeek(xFilial('SF2')+M->ZL_NOTA+M->ZL_SERIE) )
			Aviso('Atenção','Nota Fiscal não encontrada. Por favor verifique se o numero e a serie da nota fiscal foram digitados corretamente, e ainda se empresa / filial que você está tentando cancelar a nota, está correto. Se estes dados estiverem corretos entre em contato com o Administrador do Sistema.',{'Ok'})
			lRet := .F.
			Break
			
		EndIf
		
		/*/RBorges - 24/10/2013 - Nãopermitir que a nota fiscal seja cancelada,
		//caso exista CTe para a mesma.
		If SF2->(DbSeek(xFilial('SF2')+M->ZL_NOTA+M->ZL_SERIE) )
			If ! U_NaoGeraCte(SF2->F2_FILIAL,M->ZL_NOTA,M->ZL_SERIE,SF2->F2_CLIENTE,SF2->F2_LOJA)
				Aviso('Atenção','Nota Fiscal já tem CTe gerado, não pode ser cancelada.',{'Ok'})
				lRet := .F.
				Break
			EndIf
		EndIf
		  */
		  
		SZL->( DbSetOrder(1) )
		
		If SZL->( DbSeek(xFilial('SZL')+M->ZL_NOTA+M->ZL_SERIE))
			Aviso('Atenção','Esta nota fiscal já está em processo de cancelamento. Por favor verifique se o numero e a serie da nota fiscal foram digitados corretamente, e ainda se empresa / filial que você está tentando cancelar a nota, está correto. Se estes dados estiverem corretos entre em contato com o Administrador do Sistema.',{'Ok'})
			lRet := .F.
			Break
		EndIf
		
		nHoras := nSpedExc - SubtHoras( SF2->F2_EMISSAO, SF2->F2_HORA, dDataBase, substr(Time(),1,2)+":"+substr(Time(),4,2) )
		lMesFechado := If(AnoMes((FirstDay(dDataBase))-1)=AnoMes(GetNewPar("MV_ULMES",cToD(""))) .And. AnoMes(SF2->F2_EMISSAO) <> AnoMes(dDataBase),.T.,.F.)
		
		
		If nHoras <= 0
			cHstrNFE    := " O prazo para cancelamento já expirou. Não será possível cancelar esta nota, será necessário fazer uma nota fiscal de Entrada (devolução). " + chr(13) + chr(10)
			M->ZL_DADOS := "O Tempo para Cancelar esta nota fiscal, determinado pela SEFAZ, já está expirado. " + Chr(13)+Chr(10) + M->ZL_DADOS
		ElseIf lMesFechado
			cHstrNFE    := " O Mês de referência da NF foi fechado. Não será possível cancelar esta nota, será necessário fazer uma nota fiscal de Entrada (devolução). " + chr(13) + chr(10)
			M->ZL_DADOS := "O O Mês de referência da NF foi fechado. " + Chr(13)+Chr(10) + M->ZL_DADOS
		Else
			SomaDiaHor(@dDataF,@cHoraF,nHoras-1)
			M->ZL_DADOS := 'Tempo restante, a partir da hora da solicitação, para Cancelar esta nota fiscal, determinado pela SEFAZ, é de ' + R855Time(nHoras,'H') +' hora(s), o qual vai expirar em '+dToc(dDataF)+' às  ' + cHoraF+ ' horas. ' + Chr(13)+Chr(10) + M->ZL_DADOS
        //RBorges - 24/10/2013 - Nãopermitir que a nota fiscal seja cancelada,
		//caso exista CTe para a mesma.
		If SF2->(DbSeek(xFilial('SF2')+M->ZL_NOTA+M->ZL_SERIE) )
			If ! U_NaoGeraCte(SF2->F2_FILIAL,M->ZL_NOTA,M->ZL_SERIE,SF2->F2_CLIENTE,SF2->F2_LOJA)
				Aviso('Atenção','Nota Fiscal já tem CTe gerado, não pode ser cancelada.',{'Ok'})
				lRet := .F.
				Break
			EndIf
		EndIf
		
		EndIf
		
		M->ZL_HISTORI := cHstrNFE
		
		SD2->( DbSetOrder(3) )
		SD2->( DbSeek( xFilial('SD2')+M->ZL_NOTA+M->ZL_SERIE) )
		
		If SD2->D2_TIPO <> 'D'
			SA1->( DbSetOrder(1) )
			SA1->( DbSeek(xFilial('SA1') + SF2->F2_CLIENTE + SF2->F2_LOJA) )
			M->ZL_DADOS := 'Cliente: ' + SF2->F2_CLIENTE + '/' + SF2->F2_LOJA + '-' + SA1->A1_NOME + Chr(13)+Chr(10) + M->ZL_DADOS
		Else
			SA2->( DbSetOrder(1) )
			SA2->( DbSeek(xFilial('SA2') + SF2->F2_CLIENTE + SF2->F2_LOJA) )
			M->ZL_DADOS := 'Fornecedor: ' + SF2->F2_CLIENTE + '/' + SF2->F2_LOJA + '-' + SA2->A2_NOME + Chr(13)+Chr(10) +M->ZL_DADOS
		EndIf
		
		cVirgula     := ''
		cTes         := ''
		M->ZL_PEDIDO := SD2->D2_PEDIDO  
		
		ZZ5->( DbSetOrder(1))
		ZZ5->( DbSeek(xFilial('ZZ5')+M->ZL_PEDIDO) )
		
		
		M->ZL_EXPEDIC:=ZZ5->ZZ5_EXPED1 
		
		Do While SD2->(!EOF()) .and. SD2->D2_FILIAL == xFilial('SD2').and. SD2->D2_DOC == M->ZL_NOTA.and.SD2->D2_SERIE == M->ZL_SERIE
			
			If !(SD2->D2_TES $ cTes)
				cTes += cVirgula + SD2->D2_TES
				cVirgula := ','
			EndIf
			  
					
			SD2->( DbSkip() )
			
		EndDo
		
		M->ZL_TES := Padr(cTes,len(SZL->ZL_TES))
		
		End Sequence
		
EndCase

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³fHistorico()ºAutor³Jailton B Santos-JBSº Data ³ 13/05/2010  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Esta função permite que o diretor (Eriberto) faça manutençãoº±±
±±º          ³do historico da solicitação, explicando a reprovação.       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Especifico Faturamento Dipromed                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static function fHistorico()

Local oDlg
Local bOk    := {|| lRet := .T.,oDlg:End()}
Local bCancel:= {|| lRet := .F.,oDlg:End()}
Local lRet   := .F.

Define MsDialog oDlg Title "Historico do Processo" from 0,0 to 250,600 of oMainWnd pixel
//@ 01,001 to 50,100 label 'Explique o Motivo da Reprovação' Of oDlg Pixel
@ 02,002 Get mHistorico Size 250,120 MEMO Of oDlg Pixel
@ 10,256 Button OemToAnsi("Confirma") size 40,15 pixel of oDlg action eval(bOk)
@ 34,256 Button OemToAnsi("Cancela")  size 40,15 pixel of oDlg action eval(bCancel)

Activate MsDialog oDlg Centered

Return(lRet)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³fEmail()  º Autor ³Jailton B Santos-JBSº Data ³  14/05/2010 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³  Funcao desenvolvida para enviar um e-mail para os usuariosº±±
±±º          ³avaliarem, aporvarem ou reprovarem e cancelarem notas fis-  º±±
±±º          ³cais.                                                       º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Especifico Faturamento Dipromed                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function fEmail(cEmailTo,nOpcao)

Local cAccount  := Lower(Alltrim(GetMv("MV_RELACNT")))
Local cFrom     := "protheus@dipromed.com.br"
Local cPassword := Alltrim(GetMv("MV_RELPSW"))
Local cServer   := Alltrim(GetMv("MV_RELSERV"))
//Local cEmailTo  := 'jailtonbarb@ig.com.br'//Alltrim(GetMv("MV_DIPA046"))
Local cError    := ""
Local cMsg      := ""
Local lResult   := .F.
Local cAssunto  := ""
Local cEmailCc  := ""
Local cEmailBcc := ""

If Inclui
	cAssunto := 'Cancelamento da N.F. ' + M->ZL_NOTA + '-' + M->ZL_SERIE + ' em ' + dToc(M->ZL_DATA) + ' as ' + M->ZL_HORA +  ' horas.'
ElseIf nOpcao == Nil
	cAssunto := 'Cancelamento da N.F. ' + SZL->ZL_NOTA + '-' + SZL->ZL_SERIE + ' em ' + dToc(SZL->ZL_DATA) + ' as ' + SZL->ZL_HORA +  ' horas.'
ElseIf nOpcao == 1
	cAssunto := 'Autorizado o cancelamento da N.F. ' + SZL->ZL_NOTA + '-' + SZL->ZL_SERIE + ' em ' + dToc(SZL->ZL_DATA) + ' as ' + SZL->ZL_HORA +  ' horas.'
ElseIf nOpcao == 2	
	cAssunto := EncodeUTF8('Não autorizado o cancelamento da N.F. '  + SZL->ZL_NOTA + '-' + SZL->ZL_SERIE + ' em ' + dToc(SZL->ZL_DATA) + ' as ' + SZL->ZL_HORA +  ' horas.',"cp1252")
EndIf

oProcess := TWFProcess():New("WF-00001",OemToAnsi("Controle de Cancelamento de Notas Fiscais"))
oProcess:NewTask("001","\workflow\modelos\DIPA046a.htm")
oHtml:= oProcess:oHtml
//oProcess:cFrom := cFrom
oProcess:cTo := Lower(cEmailTo)

oProcess:cSubject := cAssunto
oProcess:UserSiga := RetCodUsr()
//oProcess:oHTML:ValByName( "cLogoEmpresa" , cLogoTipo )
oProcess:oHTML:ValByName("xCodigo"    ,Iif(!Inclui,SZL->ZL_CODIGO,M->ZL_CODIGO))
oProcess:oHTML:ValByName("xData"      ,Iif(!Inclui,dToc(SZL->ZL_DATA),dToc(M->ZL_DATA)))
oProcess:oHTML:ValByName("xHora"      ,Iif(!Inclui,SZL->ZL_HORA,M->ZL_HORA))
oProcess:oHTML:ValByName("xPedido"    ,Iif(!Inclui,SZL->ZL_PEDIDO,M->ZL_PEDIDO))
oProcess:oHTML:ValByName("xNota"      ,Iif(!Inclui,SZL->ZL_NOTA+'-'+SZL->ZL_SERIE,M->ZL_NOTA+'-'+M->ZL_SERIE))
oProcess:oHTML:ValByName("xData2"     ,dToc(dDataBase))
oProcess:oHTML:ValByName("xTes"       ,Iif(!Inclui,SZL->ZL_TES,M->ZL_TES))
oProcess:oHTML:ValByName("xExp"       ,Iif(!Inclui,SZL->ZL_EXPEDIC,M->ZL_EXPEDIC))
oProcess:oHTML:ValByName("xMercadoria",Iif(!Inclui,AllTrim(SZL->ZL_ONDE),AllTrim(M->ZL_ONDE)))
//oProcess:oHTML:ValByName("xFaturar"   ,Iif(!Inclui,IIf(SZL->ZL_REFATUR = '1','[X] Sim [ ] Não','[ ] Sim [X] Não'),IIf(M->ZL_REFATUR = '1','[X] Sim [ ] Não','[ ] Sim [X] Não')))
oProcess:oHTML:ValByName("xMataPv"    ,Iif(!Inclui,IIf(SZL->ZL_MATAPED = '2','[ ]-Refaturar  [X]-Excluir','[X]-Refaturar  [ ]-Excluir'),IIf(M->ZL_MATAPED = '2','[ ]-Refaturar  [X]-Excluir','[X]-Refaturar  [ ]-Excluir')))
oProcess:oHTML:ValByName("xMotivo"    ,Iif(!Inclui,StrTran(AllTrim(SZL->ZL_MOTIVO) ,chr(13)+chr(10),'<P>'),StrTran(AllTrim(M->ZL_MOTIVO) ,chr(13)+chr(10),'<P>')))
oProcess:oHTML:ValByName("xHistorico" ,Iif(!Inclui,StrTran(AllTrim(SZL->ZL_HISTORI),chr(13)+chr(10),'<P>'),StrTran(AllTrim(M->ZL_HISTORI),chr(13)+chr(10),'<P>')))
oProcess:oHTML:ValByName("xDados"     ,Iif(!Inclui,StrTran(AllTrim(SZL->ZL_DADOS)  ,chr(13)+chr(10),'<P>'),StrTran(AllTrim(M->ZL_DADOS)  ,chr(13)+chr(10),'<P>')))
oProcess:oHTML:ValByName("xEmpresa"   ,'[' + SM0->M0_CODIGO +']-['+AllTrim(U_FindEmp(SM0->M0_CODIGO,SM0->M0_CODFIL,,'NOME'  )) + ']')
oProcess:oHTML:ValByName("xNomFil"    ,'[' + SM0->M0_CODIGO +']-['+AllTrim(U_FindEmp(SM0->M0_CODIGO,SM0->M0_CODFIL,,'FILIAL'  )) + ']')
oProcess:oHTML:ValByName("xUsuario"   ,Iif(!Inclui,SZL->ZL_USUARIO,M->ZL_USUARIO))
oProcess:oHTML:ValByName("xSetor"     ,Iif(!Inclui,SZL->ZL_SETOR,M->ZL_SETOR))

oProcess:Start()
oProcess:Finish()

Aviso('Sucesso','Enviado e-mail com sucesso.',{"Ok"})

Return(.T.)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³fFindCIC()º Autor ³Jailton B Santos-JBSº Data ³ 25/05/2010  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Busca o nome do usuario do CIC para enviar mensagen-lhe    º±±
±±º          ³ mensagens.                                                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function fFindCic(cCodigo)

Local aArea   := GetArea()
Local cQuery  := ""
Local cUsuCIC := ""

cQuery := " Select U7_CICNOME CIC "
cQuery += "   from "+RetSqlName('SU7')+" SU7 "
cQuery += "  where U7_FILIAL = '" + xFilial('SU7')+ "' "
cQuery += "    and U7_CODUSU  = '"+ cCodigo + "' "
cQuery += "    and SU7.D_E_L_E_T_ = '' "
cQuery += " Union Select Y1_NOMECIC CIC "
cQuery += "   from " + RetSqlName('SY1')+ " SY1 "
cQuery += "  where Y1_FILIAL  = '" +xFilial('SY1')+ "' "
cQuery += "    and Y1_USER  = '"+ cCodigo + "' "
cQuery += "    and SY1.D_E_L_E_T_ = '' "

If Select("TRB") > 0
	TRB->(DbCloseArea())
EndIf

TcQuery cQuery NEW ALIAS "TRB"

If !TRB->(BOF() .and. EOF() )
	cUsuCIC := TRB->CIC
EndIf
TRB->( DbCloseArea() )
Return(cUsuCIC)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ fCic()   ºAutor  ³Jailton B Santos-JBSº Data ³ 25/05/2010  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Esta funcao dispara uma mensagem de CIC para um ou mais    º±±
±±º          ³ usuarios.                                                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Especificos Faturamento Dipromed                           º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function fCic(cOperador, cMsg, lCodigo, _nOpc)

Local lRet := .T.
Local cMail
Local cServidor   := GetMV("MV_CIC")     // Servidor para enviar mensagem pelo CIC
Local cOpFatRem   := GetMV("MV_REMETCI") // Usuario do CIC remetente de mensgens no Protheus
Local cOpFatSenha := "123456"
Local cOpFatDest  := ""                             
Default _nOpc     := 0
//cOpFatDest := "MAXIMO.CANUTO,MAGDA.TEIXEIRA,WILLIAM.PEREIRA,SILVIA.MORAES,BRUNO.JESUS"

If lCodigo
	cOpFatDest := fFindCic(cOperador) //
Else
	cOpFatDest := upper(cOperador)
EndIf
                 
//Maximo 30/07/13           
If _nOpc == 9
	cOpFatDest  += ","+GetNewPar("ES_DIP46CI","DIEGO.DOMINGOS,VANDER.EGON,MAXIMO.CANUTO")
Endif
             
                                                                                                             
U_DIPCIC(cMsg,AllTrim(cOpFatDest))//RBorges 12/03/15
//WaitRun(cServidor+' '+cOpFatRem+' '+cOpFatSenha+' "'+AllTrim(cOpFatDest)+'" "' + cMsg + '" ') //Comentada RBorges 12/03/15

Return(lRet)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³fGeraNFE()ºAutor  ³Jailton B Santos-JBSº Data ³ 13/07/2010  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Gera a Nota fiscal de devolucao                             º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Especifico Faturamento Dipromed                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function fGeraNFE()

Local lRet       := .F. 
Local aArea      := GetArea()
Local aAreaSE1   := SE1->(GetArea())
Local aAreaSF2   := SF2->(GetArea())
local cDocSF2    := ""
Local nReg       := 0
Local nPocx      := 3

Private cCliente := ""
Private cLoja    := ""   
Private cQrDvF2  := ""

SF2->( DbSetOrder(1) )
If SF2->( DbSeek(xFilial('SF2')+SZL->ZL_NOTA + SZL->ZL_SERIE) )
	
	cCliente := SF2->F2_CLIENTE
	cLoja    := SF2->F2_LOJA
	
    SF2->( lRet := fProcDv('SF2',SF2->( Recno() ),3,.F.,cCliente,cLoja,cDocSF2) )
		
	If lRet
		cNroNota  := SF1->F1_DOC
		cNroSerie := SF1->F1_SERIE
	EndIf

EndIf

RestArea(aAreaSF2)
RestArea(aAreaSE1)
RestArea(aArea)

Return(lRet)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³fProcDv() ºAutor  ³Jailton B Santos-JBSº Data ³ 14/07/2010  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Faz nota fiscal de devolucao de forma automatica, sem abrirº±±
±±º          ³ interface com o usuario. Copiado da funcao a103ProcDv.     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±³Parametros³ ExpC1 = Alias do arquivo                                   ³±±
±±³          ³ ExpN1 = Numero do registro                                 ³±±
±±³          ³ ExpN2 = Numero da opcao selecionada                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ºUso       ³ Especifico Faturamento Dipromed                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function fProcDv(cAlias,nReg,nOpcx,lCliente,cCliente,cLoja,cDocSF2)

Local aCab      := {}
Local aLinha    := {}
Local aItens    := {}
Local cTipoNF   := ""
Local lDevolucao:= .T.
Local lPoder3   := .T.
Local aHlpP		:=	{}
Local aHlpE		:=	{}
Local aHlpS		:=	{} 
Local lFlagDev	:= SF2->(FieldPos("F2_FLAGDEV")) > 0  .And. GetNewPar("MV_FLAGDEV",.F.)
Local cIndex	:= ""  
Local lRestDev	:= .T. 
Local lRet      := .F.
Local cSerie    := SZL->ZL_SERIE  
Local cNexNfs   := ""

Private aRecSD2 := {} // JBS 20/08/2010 - Registro validos do SD2 para gerar o SZD

If SF2->(!Eof())

	lDevolucao   := fFilDv(@aLinha,@aItens,cDocSF2,cCliente,cLoja,lCliente,@cTipoNF,@lPoder3)
	
	If lDevolucao
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Montagem do Cabecalho da Nota fiscal de Devolucao/Retorno       ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
		
		AAdd( aCab, { "F1_DOC"    , NxtSX5Nota(cSerie, NIL, '1')	, Nil } )	// Numero da NF : Obrigatorio 
		cNexNfs := aCab[1][2] // MCVN  06/09/10
		AAdd( aCab, { "F1_SERIE"  , cSerie	                        , Nil } )	// Serie da NF  : Obrigatorio
		AAdd( aCab, { "F1_COND"   , '002'	                        , Nil } )	// Cond.de Pag  : Sempre A Vista Sem Desconto
		If !lPoder3
			AAdd( aCab, { "F1_TIPO"   , "D"                  		, Nil } )	// Tipo da NF   : Obrigatorio
		Else
			AAdd( aCab, { "F1_TIPO"   , IIF(cTipoNF=="B","N","B")	, Nil } )	// Tipo da NF   : Obrigatorio		
		EndIf
		AAdd( aCab, { "F1_FORNECE", cCliente    				    , Nil } )	// Codigo do Fornecedor : Obrigatorio
		AAdd( aCab, { "F1_LOJA"   , cLoja    	   			        , Nil } )	// Loja do Fornecedor   : Obrigatorio
		AAdd( aCab, { "F1_EMISSAO", dDataBase           			, Nil } )	// Emissao da NF        : Obrigatorio
		AAdd( aCab, { "F1_FORMUL" , "S"                 			, Nil } )  // Formulario
		AAdd( aCab, { "F1_ESPECIE", If(Empty(CriaVar("F1_ESPECIE",.T.)),;
		PadR("SPED",Len(SF1->F1_ESPECIE)),CriaVar("F1_ESPECIE",.T.)), Nil } )  // Especie
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se ha itens a serem devolvidos                         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If len(aItens) > 0
		    
		    Begin Transaction 
		                                                                    
		        lMsErroAuto := .f.
		        MSExecAuto({|a,b,c,d| Mata103(a,b,c,d)}  ,aCab, aItens , 3 , .F.) 
		        
		        If lMsErroAuto  
		            DisarmTransaction()    
       				Aviso("Atencao","A NF "+cNexNfs+" não foi utilizada, favor ajustar no SX5 ou orientar o CD na utilização!!!",{"Ok"})
	 	        Else                                                                                               
   	               //----------------------------------------------------------------------------------------------
   			       // MCVN 31/08/2010 - Apos gerar a NFE, gera SZD com os itens lidos do SD2.
				   //----------------------------------------------------------------------------------------------
	               fGeraSZD()                                     
	               
   	               //----------------------------------------------------------------------------------------------
   			       // MCVN 31/08/2010 - Apos gerar a NFE, Empenha endereça SDA com os itens lidos do SD1.
				   //----------------------------------------------------------------------------------------------
				   fEndEst()					   
	               
	               //----------------------------------------------------------------------------------------------
   			       // JBS 21/08/2010 - Apos gerar a NFE, gera SD3 com os itens lidos do SD2.
				   //----------------------------------------------------------------------------------------------				  
		  		   fGeraSD3(@lDevolucao) 
		        EndIf       
		        
		    End Transaction
		    
	        lRet := fFilDv(@aLinha,@aItens,cDocSF2,cCliente,cLoja,lCliente,@cTipoNF,@lPoder3,.F.)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Verifica se nao ha mais saldo para devolucao³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lFlagDev
				//lRestDev := fFilDv(@aLinha,@aItens,cDocSF2,cCliente,cLoja,lCliente,@cTipoNF,@lPoder3,.F.)		
				If lRet //!lRestDev
					RecLock("SF2",.F.)
					SF2->F2_FLAGDEV := "1"
					MsUnLock()
				Endif         
			Endif
		Else
			aHlpP	:=	{}
			aHlpE	:=	{}
			aHlpS	:=	{}
			aAdd (aHlpP, "Nota Fiscal de Devolução já gerada ou o")	//"Nota Fiscal de Devolução já gerada ou o"
			aAdd (aHlpP, "saldo devedor em poder de terceiro está")	//"saldo devedor em poder de terceiro está"
			aAdd (aHlpP, "zerado.")                               	//"zerado."
			aAdd (aHlpE, "Nota Fiscal de Devolução já gerada ou o")	//"Nota Fiscal de Devolução já gerada ou o"
			aAdd (aHlpE, "saldo devedor em poder de terceiro está")	//"saldo devedor em poder de terceiro está"
			aAdd (aHlpE, "zerado.")	                                //"zerado."
			aAdd (aHlpS, "Nota Fiscal de Devolução já gerada ou o")	//"Nota Fiscal de Devolução já gerada ou o"
			aAdd (aHlpS, "saldo devedor em poder de terceiro está")	//"saldo devedor em poder de terceiro está"
			aAdd (aHlpS, "zerado.")                              	//"zerado."
			PutHelp ("PNFDGSPTZ", aHlpP, aHlpE, aHlpS, .F.)
			//
			aHlpP	:=	{}
			aHlpE	:=	{}
			aHlpS	:=	{}
			aAdd (aHlpP, "É necessário excluir a NFcorrespondente")	//"É necessário excluir a NFcorrespondente"
			aAdd (aHlpP, "para gerar a devolução novamente ou o")	//"para gerar a devolução novamente ou o"
			aAdd (aHlpP, "saldo devedor em poder de terceiro está")	//"saldo devedor em poder de terceiro está"
			aAdd (aHlpP, "zerado para o item.")	                    //"zerado para o item."
			aAdd (aHlpE, "É necessário excluir a NFcorrespondente")	//"É necessário excluir a NFcorrespondente"
			aAdd (aHlpE, "para gerar a devolução novamente ou o")	//"para gerar a devolução novamente ou o"
			aAdd (aHlpE, "saldo devedor em poder de terceiro está")	//"saldo devedor em poder de terceiro está"
			aAdd (aHlpE, "zerado para o item.")	                    //"zerado para o item."
			aAdd (aHlpS, "É necessário excluir a NFcorrespondente")	//"É necessário excluir a NFcorrespondente"
			aAdd (aHlpS, "para gerar a devolução novamente ou o")	//"para gerar a devolução novamente ou o"
			aAdd (aHlpS, "saldo devedor em poder de terceiro está")	//"saldo devedor em poder de terceiro está"
			aAdd (aHlpS, "zerado para o item.")                   	//"zerado para o item."
			PutHelp ("SNFDGSPTZ", aHlpP, aHlpE, aHlpS, .F.)
			Help(" ",1,"NFDGSPTZ")	//Nota Fiscal de Devolução já gerada ou o saldo devedor em poder de terceiro está zerado.
		
		Endif
	Else 
		lRet := .T. // Ele vai retornar o inverso, no return este valor sera invertido, onde .T. volta .F. e .F. volta .T. - JBS 26/07/2010
	EndIf
	
	MsUnLockAll()
	
Endif
	
Return(!lRet)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³fFilDv()  ºAutor  ³Jailton B Santos-JBSº Data ³ 14/07/2010  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Verifica os itens que podem ser devolvidos do documento    º±±
±±º          ³ selecionado. Copiado do M103FilDv().                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±³Parametros³ ExpA1 = Linhas com os itens de devoluvao                   ³±±
±±³          ³ ExpA2 = Itens de devolucao                                 ³±±
±±³          ³ ExpC3 = Documentos do SF2 a serem processados              ³±±
±±³          ³ ExpC4 = Cliente do filtro                                  ³±±
±±³          ³ ExpC5 = Loja do cliente do filtro                          ³±±
±±³          ³ ExpL6 = Se a tela e por cliente/fornecedor                 ³±±
±±³          ³ ExpL7 = Tipo do documento - normal, devolucao, benefic.    ³±±
±±³          ³ ExpL8 = Se tem controle de terceiros no estoque            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ºUso       ³ AP6                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function fFilDv(aLinha,aItens,cDocSF2,cCliente,cLoja,lCliente,cTipoNF,lPoder3,lHelp)

Local cAliasSD2 := "SD2"
Local cAliasSF4 := "SF4"
Local nSldDev   := 0
Local nCntSD2   := 0  
Local lDevolucao:= .T.
Local lQuery    := .F.
Local lMt103FDV := ExistBlock("MT103FDV")
Local lDevCode	:= .F.
Local cCfop     := ""
Local cFilSX5   := xFilial("SX5")
Local aStruSD2 := {}
Local cQuery   := ""
Local nX       := 0

Default lHelp := .T.

If SoftLock("SF2")
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Montagem dos itens da Nota Fiscal de Devolucao/Retorno          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea("SD2")
	DbSetOrder(3)
	lQuery    := .T.
	cAliasSD2 := "Oms320Dev"
	cAliasSF4 := "Oms320Dev"
	aStruSD2  := SD2->(dbStruct())
	cQuery    := "SELECT SF4.F4_CODIGO,SF4.F4_CF,SF4.F4_PODER3,SD2.*,SD2.R_E_C_N_O_ SD2RECNO "
	cQuery    += "FROM "+RetSqlName("SD2")+" SD2,"
	cQuery    += RetSqlName("SF4")+" SF4 "
	cQuery    += "WHERE SD2.D2_FILIAL='"+xFilial("SD2")+"' AND "
	If !lCliente
		cQuery    += "SD2.D2_DOC = '"+SF2->F2_DOC+"' AND "
		cQuery    += "SD2.D2_SERIE = '"+SF2->F2_SERIE+"' AND "
	Else
		If !Empty(cDocSF2)
			cQuery += " ( "
			cQuery += cDocSF2 + " AND "
		EndIf
	EndIf
	cQuery    += "SD2.D2_CLIENTE = '"+cCliente+"' AND "
	cQuery    += "SD2.D2_LOJA = '"+cLoja+"' AND "
	cQuery    += "((SD2.D2_QTDEDEV < SD2.D2_QUANT) OR "
	cQuery    += "(SD2.D2_VALDEV = 0)) AND "
	cQuery    += "SD2.D_E_L_E_T_=' ' AND "
	cQuery    += "SF4.F4_FILIAL='"+xFilial("SF4")+"' AND "
	cQuery    += "SF4.F4_CODIGO=(SELECT F4_TESDV FROM "+RetSqlName("SF4")+" WHERE "
	cQuery    += "F4_FILIAL='"+xFilial("SF4")+"' AND "
	cQuery    += "F4_CODIGO=SD2.D2_TES AND "
	cQuery    += "D_E_L_E_T_=' ' ) AND "
	cQuery    += "SF4.D_E_L_E_T_=' ' "
	cQuery    += "ORDER BY "+SqlOrder(SD2->(IndexKey()))
	
	cQuery    := ChangeQuery(cQuery)
	
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSD2,.T.,.T.)
	
	For nX := 1 To Len(aStruSD2)
		If aStruSD2[nX][2]<>"C"
			TcSetField(cAliasSD2,aStruSD2[nX][1],aStruSD2[nX][2],aStruSD2[nX][3],aStruSD2[nX][4])
		EndIf
	Next nX
	
	If Eof()
		If lHelp
			Help(" ",1,"DSNOTESDT")
		Endif
		lDevolucao := .F.
	EndIf

	Do While !Eof() .And. (cAliasSD2)->D2_FILIAL == xFilial("SD2") .And.;
			(cAliasSD2)->D2_CLIENTE == cCliente .And.;
			(cAliasSD2)->D2_LOJA == cLoja .And.;
			If(!lCliente,(cAliasSD2)->D2_DOC == SF2->F2_DOC .And.;
			(cAliasSD2)->D2_SERIE == SF2->F2_SERIE,.T.)

		If ((cAliasSD2)->D2_QTDEDEV < (cAliasSD2)->D2_QUANT) .Or. ((cAliasSD2)->D2_VALDEV == 0)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica se existe um tes de devolucao correspondente           ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If !lQuery
				DbSelectArea("SF4")
				DbSetOrder(1)
				If MsSeek(xFilial("SF4")+(cAliasSD2)->D2_TES)
					If Empty(SF4->F4_TESDV) .Or. !(SF4->(MsSeek(xFilial("SF4")+SF4->F4_TESDV)))
						lDevolucao := .F.
						Exit
					EndIf
					If SF4->F4_PODER3<>"D"
						lPoder3 := .F.
					EndIf
				EndIf
			Else
				If (cAliasSD2)->F4_PODER3<>"D"
					lPoder3 := .F.
				EndIf			
			EndIf
			If !lMt103FDV .Or. ExecBlock("MT103FDV",.F.,.F.,{cAliasSD2})

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Calcula o Saldo a devolver                                      ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
				cTipoNF := (cAliasSD2)->D2_TIPO
				Do Case
				Case (cAliasSF4)->F4_PODER3=="D"
					nSldDev := CalcTerc((cAliasSD2)->D2_COD,(cAliasSD2)->D2_CLIENTE,(cAliasSD2)->D2_LOJA,(cAliasSD2)->D2_IDENTB6,(cAliasSD2)->D2_TES,cTipoNF)[1]
				Case cTipoNF == "N"
					nSldDev := (cAliasSD2)->D2_QUANT-(cAliasSD2)->D2_QTDEDEV
				OtherWise
					nSldDev := 0
				EndCase

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Efetua a montagem da Linha                                      ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

				If nSldDev > 0 .Or. (cTipoNF$"CIP" .And. (cAliasSD2)->D2_VALDEV == 0)

					lDevCode := .T.
					
					nCntSD2++
					If nCntSD2 > 900  // No. maximo de Itens
						Exit
					EndIf

					aLinha := {}				
					AAdd( aLinha, { "D1_COD"    , (cAliasSD2)->D2_COD    , Nil } )
					AAdd( aLinha, { "D1_QUANT"  , nSldDev, Nil } )					
					If (cAliasSD2)->D2_QUANT==nSldDev
						If (cAliasSD2)->D2_DESCON+(cAliasSD2)->D2_DESCZFR == 0
							AAdd( aLinha, { "D1_VUNIT"  , (cAliasSD2)->D2_PRCVEN, Nil })
						Else
							AAdd( aLinha, { "D1_VUNIT"  , ((cAliasSD2)->D2_TOTAL+(cAliasSD2)->D2_DESCON+(cAliasSD2)->D2_DESCZFR)/(cAliasSD2)->D2_QUANT, Nil })
						EndIf
						AAdd( aLinha, { "D1_TOTAL"  , (cAliasSD2)->D2_TOTAL+(cAliasSD2)->D2_DESCON+(cAliasSD2)->D2_DESCZFR,Nil } )
						AAdd( aLinha, { "D1_VALDESC", (cAliasSD2)->D2_DESCON+(cAliasSD2)->D2_DESCZFR , Nil } )						
					Else
						AAdd( aLinha, { "D1_VUNIT"  , ((cAliasSD2)->D2_TOTAL+(cAliasSD2)->D2_DESCON+(cAliasSD2)->D2_DESCZFR)/(cAliasSD2)->D2_QUANT, Nil })																
						AAdd( aLinha, { "D1_TOTAL"  , A410Arred(aLinha[2][2]*aLinha[3][2],"D1_TOTAL"),Nil } )
						AAdd( aLinha, { "D1_VALDESC"  , A410Arred((cAliasSD2)->D2_DESCON/(cAliasSD2)->D2_QUANT*aLinha[2][2],"D1_VALDESC"),Nil } )						
					EndIf
					AAdd( aLinha, { "D1_IPI"    , (cAliasSD2)->D2_IPI    , Nil } )	
					AAdd( aLinha, { "D1_LOCAL"  , (cAliasSD2)->D2_LOCAL  , Nil } )
					AAdd( aLinha, { "D1_TES" 	, (cAliasSF4)->F4_CODIGO , Nil } )
					If ("000"$AllTrim((cAliasSF4)->F4_CF) .Or. "999"$AllTrim((cAliasSF4)->F4_CF))
						cCfop := AllTrim((cAliasSF4)->F4_CF)
					Else
                        cCfop := SubStr("123",At(SubStr((cAliasSD2)->D2_CF,1,1),"567"),1)+SubStr((cAliasSD2)->D2_CF,2)
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Verifica se existe CFOP equivalente considerando a CFOP do documento de saida  ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						SX5->( dbSetOrder(1) )
						If !SX5->(MsSeek( cFilSX5 + "13" + cCfop ))
							cCfop := AllTrim((cAliasSF4)->F4_CF)
						EndIf
					EndIf
					AAdd( aLinha, { "D1_CF"		, cCfop, Nil } )
					AAdd( aLinha, { "D1_UM"     , (cAliasSD2)->D2_UM , Nil } )
	  				If Rastro((cAliasSD2)->D2_COD)
						AAdd( aLinha, { "D1_LOTECTL", (cAliasSD2)->D2_LOTECTL, ".T." } )
						If (cAliasSD2)->D2_ORIGLAN == "LO"
							If Rastro((cAliasSD2)->D2_COD,"L") .AND. !Empty((cAliasSD2)->D2_NUMLOTE)
								AAdd( aLinha, { "D1_NUMLOTE", Nil , ".T." } )							
							Else
								AAdd( aLinha, { "D1_NUMLOTE", (cAliasSD2)->D2_NUMLOTE, ".T." } )													
							EndIf
						Else
							AAdd( aLinha, { "D1_NUMLOTE", (cAliasSD2)->D2_NUMLOTE, ".T." } )						
						EndIf

						AAdd( aLinha, { "D1_DTVALID", (cAliasSD2)->D2_DTVALID, ".T." } )
						AAdd( aLinha, { "D1_POTENCI", (cAliasSD2)->D2_POTENCI, ".T." } )
					EndIf
					AAdd( aLinha, { "D1_NFORI"  , (cAliasSD2)->D2_DOC    , Nil } )
					AAdd( aLinha, { "D1_SERIORI", (cAliasSD2)->D2_SERIE  , Nil } )
					AAdd( aLinha, { "D1_ITEMORI", (cAliasSD2)->D2_ITEM   , Nil } )
					AAdd( aLinha, { "D1_ICMSRET", (cAliasSD2)->D2_ICMSRET, Nil } )					
                    AAdd( aLinha, { "D1_CONTA", "113104001"              , Nil } ) 
                    //AAdd( aLinha, { "D1_CONTA",   (cAliasSD2)->D2_CONTA, Nil } )					
					If (cAliasSF4)->F4_PODER3=="D"
						AAdd( aLinha, { "D1_IDENTB6", (cAliasSD2)->D2_NUMSEQ, Nil } )								
					Endif

					AAdd( aLinha, { "D1RECNO",    Iif(lQuery,(cAliasSD2)->SD2RECNO,(cAliasSD2)->(RECNO()) ), Nil } )
					
					AAdd( aLinha, { "D1_SEGURO", (cAliasSD2)->D2_SEGURO   , Nil } )
					AAdd( aLinha, { "D1_VALFRE", (cAliasSD2)->D2_VALFRE   , Nil } )
					AAdd( aLinha, { "D1_DESPESA",(cAliasSD2)->D2_DESPESA  , Nil } )					

					AAdd( aItens, aLinha)  
					//----------------------------------------------------------------------------------------------
					// JBS 20/08/2010 - Guarda os registro do SD2 usados para gerar a devolucao
					//----------------------------------------------------------------------------------------------
					aadd( aRecSD2, Iif(lQuery,(cAliasSD2)->SD2RECNO,(cAliasSD2)->(RECNO())) )
					
				EndIf
			Endif	
		Endif        
		
		DbSelectArea(cAliasSD2)
		dbSkip()
		
	EndDo
	
	If lQuery
		DbSelectArea(cAliasSD2)
		dbCloseArea()
	Else
		If lCliente
			RetIndex( "SD2" )
			FErase( cIndex+OrdBagExt() )
		EndIf
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica se nenhum item foi processado ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !lDevCode
		lDevolucao := .F.
	Endif
	DbSelectArea("SD2")

Endif               

Return lDevolucao
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³fConsultaNFºAutor ³Jailton B Santos-JBSº Data ³  26/07/2010 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Chamado do botao de avaliacao de um processo de cancelamen-º±±
±±º          ³ to, permite ao usuario cancelar uma nota fiscal antes de   º±±
±±º          ³ se decidir pelo para aprovacao ou reprovacao do mesmo.     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Especifico Faturamento Dipromed                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static function fConsultaNF()
Local lRet := .T.                                       
Local aArea:= GetArea()
                                  
Private aRotina := {{ 'Pesquisar' ,"AxPesqui"		,0,1,0,.F.},;	// "Pesquisar"
					{ 'Visualizar',"MC090Visual"	,0,2,0,NIL},;		// "Visualizar"
					{ 'Legenda'   ,"MC090Legend"	,0,5,0,NIL} }	 	// "Legenda"

SF2->( DbSetOrder(1) )
If SF2->( DbSeek(xFilial('SF2')+SZL->ZL_NOTA + SZL->ZL_SERIE) )
    SF2->( Mc090Visual('SF2',SF2->(Recno()),2) )
Else 
    Aviso('Atenção','Erro no processo. Esta nota fiscal não foi encontrada no sistema...',{'Ok'})
    lRet := .F.
EndIf

RestArea(aArea)

Return(lRet)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³fGeraSZD()ºAutor  ³Jailton B Santos-JBSº Data ³ 20/08/2010  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Gera o SZD com as informacoes das notas fiscais excluidas  º±±
±±º          ³ ou devolvidas.                                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Especifico Estoques Dipromed                               º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function fGeraSZD()   

Local _cGera  := " "
Local _cEst   := " "
Local _cFin   := " "
Local lRet    := .T.
Local aAreaSF2:= SF2->( GetArea() )
Local aAreaSF4:= SF4->( GetArea() )

SF4->( Dbsetorder(1) ) 
SF2->( Dbsetorder(1) )
SF2->( Dbseek(xfilial("SF2") + SZL->ZL_NOTA + SZL->ZL_SERIE ))

For nId := 1 to len(aRecSD2)

    SD2->(DbGoTo(aRecSD2[nId]))
	
	SF4->( Dbseek(xfilial("SF4") + StrZero(IIF(Val(SD2->D2_TES)>=500,Val(SD2->D2_TES),Val(SD2->D2_TES)+500),Len(SD2->D2_TES))))
	
	SZD->(RecLock("SZD",.T.))
	SZD->ZD_FILIAL  := xFilial("SZD")
	SZD->ZD_NOTA    := SD2->D2_DOC
	SZD->ZD_SERIE   := SD2->D2_SERIE
	SZD->ZD_DATAEXC := DATE()
	SZD->ZD_HORAEXC := TIME()
	SZD->ZD_USUARIO := Upper(U_DipUsr())
	SZD->ZD_ATUEST  := SF4->F4_ESTOQUE
	SZD->ZD_ATUFIN  := SF4->F4_DUPLIC
	SZD->ZD_ESTEXCL := SF4->F4_GER_EST
	SZD->ZD_CLIENTE := SD2->D2_CLIENTE
	SZD->ZD_COD     := SD2->D2_COD
	SZD->ZD_EMISSAO := SD2->D2_EMISSAO
	SZD->ZD_TES     := SD2->D2_TES
	SZD->ZD_QUANT   := SD2->D2_QUANT 
	SZD->ZD_PRCVEN  := SD2->D2_PRCVEN
	SZD->ZD_TOTAL   := SD2->D2_TOTAL 
	SZD->ZD_COMIS1  := SD2->D2_COMIS1
	SZD->ZD_CUSDIP  := SD2->D2_CUSDIP
	SZD->ZD_CONFERI := SF2->F2_CONFERI
	SZD->ZD_SEPAROU := SF2->F2_SEPAROU
	SZD->ZD_EXPLIC  := SZL->ZL_MOTIVO
	SZD->(MsUnLock())
	
Next nId

SF2->( RestArea(aAreaSF2) )
SF4->( RestArea(aAreaSF4) )

Return(lRet)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³fEndEst() ºAutor  ³Jailton B Santos-JBSº Data ³  21/08/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Apos a geracao da nota fiscal de devolucao faz os endereca-º±±
±±º          ³ mento automatico de todos os itens para o endereco 'AAA01' º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Especifico Estoques dipromed.                              º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function fEndEst()
Local lRet := .F.


//---------------------------------------------------------------------------------------------
// MCVN 31/08/2010 - Quando a rotina for chamada a partir da avaliacao de
// processo de cancelamento de NFS e a mercadoria da nota fiscal que esta
// sendo devolvida estiver no cliente.
//---------------------------------------------------------------------------------------------

Begin Sequence

	If !(Type("lDip46GrD3") <> "U" .And. lDip46GrD3)
		break
	EndIf

	If !fQuery() 
	   Aviso('Atenção','Nao encontrou a nota fiscal.',{'Ok'}) 
	EndIf

	Processa({|| lRet := fEndereca()} )
	If lRet
		Aviso('Sucesso','Produtos Endereçados Com Sucesso ...',{'OK'})
	EndIf

	TRB->( DbCloseArea() )
	
End Sequence

Return(.T.)


Static Function fQuery()

Local lRet   := .F.
Local cQuery := ""

cQuery := " SELECT DA_DATA, "
cQuery += "        DA_PRODUTO, "
cQuery += "        DA_DOC, "
cQuery += "        DA_SERIE, "
cQuery += "        DA_LOTECTL, "
cQuery += "        DA_LOTECTL, "
cQuery += "        DA_PRODUTO, "
cQuery += "        DA_SALDO ,"
cQuery += "        SDA.R_E_C_N_O_"

cQuery += " FROM " + RetSQLName("SDA") + " SDA "

cQuery += " WHERE DA_FILIAL = '" + xFilial('SDA') + "' "
//cQuery += "   AND DA_DOC = '" + SZL->ZL_NOTA + "'"
//cQuery += "   AND DA_SERIE = '" + SZL->ZL_SERIE + "'"
cQuery += "   AND DA_DOC = '" + SF1->F1_DOC +  "'"        // MCVN  30/08/2010
cQuery += "   AND DA_SERIE = '" + SF1->F1_SERIE +  "'"   // MCVN  30/08/2010
cQuery += "   AND DA_SALDO   > 0 "
cQuery += "   AND SDA.D_E_L_E_T_ = '' "
cQuery += "   ORDER BY DA_DOC, DA_PRODUTO "

If Select("TRB") > 0
	TRB->( DbCloseArea() )
EndIf

TCQUERY cQuery NEW ALIAS "TRB"
TCSETFIELD("TRB","DC_QTDORIG"   , "N" , 14 , 02)

lRet := !TRB->( BOF().and.EOF() )

Return(lRet)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³fEndereca()ºAutor ³Microsiga           º Data ³  21/08/2010 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Endereca os itens da nota fiscal devolvida, para o enderecoº±±
±±º          ³ 'AAA01'                                                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Especifico Estoques Dipromed.                              º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function fEndereca()

Local lRet    := .F.
Local nRec    := 70
Local cSeek   := ''
Local cLoteSDA:= ''
Local lRastro := ''
Local cItens  := '0000'

Private aCabec:= {}
Private aItem := {}
Private aItens := {}

ProcRegua(nRec)

TRB->( DbGotop() )
SDA->(dbSetFilter({|| SDA->DA_DOC == TRB->DA_DOC},"SDA->DA_DOC == TRB->DA_DOC"))
Do While TRB->( !EOF() )
	
	IncProc("Distribuindo.. " + TRB->DA_DOC + "-" + TRB->DA_SERIE + " - " + TRB->DA_PRODUTO )
	
	If nRec = 0
		nRec := 70
		ProcRegua(nRec)
	EndIf
	nRec--
	
	SDA->( DbGoTo(TRB->R_E_C_N_O_) )

	SB2->(dbSetFilter({|| SB2->B2_COD    ==SDA->DA_PRODUTO},"SB2->B2_COD    ==SDA->DA_PRODUTO"))
	SBF->(dbSetFilter({|| SBF->BF_PRODUTO==SDA->DA_PRODUTO},"SBF->BF_PRODUTO==SDA->DA_PRODUTO"))	
	SB8->(dbSetFilter({|| SB8->B8_PRODUTO==SDA->DA_PRODUTO},"SB8->B8_PRODUTO==SDA->DA_PRODUTO"))


	
	aCabec := {}
	aItem  := {}

    Aadd(aCabec, {"DA_PRODUTO"     , SDA->DA_PRODUTO          , nil})
	Aadd(aCabec, {"DA_QTDORI"      , SDA->DA_QTDORI           , nil})
	Aadd(aCabec, {"DA_SALDO"       , SDA->DA_SALDO            , nil})
	Aadd(aCabec, {"DA_DATA"        , SDA->DA_DATA             , nil}) 

   	Aadd(aCabec, {"DA_LOTECTL"     , SDA->DA_LOTECTL          , nil})
    Aadd(aCabec, {"DA_NUMLOTE"     , SDA->DA_NUMLOTE          , nil})
    
	Aadd(aCabec, {"DA_LOCAL"       , SDA->DA_LOCAL            , nil})
	Aadd(aCabec, {"DA_DOC"         , SDA->DA_DOC              , nil})
	Aadd(aCabec, {"DA_SERIE"       , SDA->DA_SERIE            , nil})
	Aadd(aCabec, {"DA_CLIFOR"      , SDA->DA_CLIFOR           , nil})
	Aadd(aCabec, {"DA_LOJA"        , SDA->DA_LOJA             , nil})
	Aadd(aCabec, {"DA_TIPONF"      , SDA->DA_TIPONF           , nil})
	Aadd(aCabec, {"DA_ORIGEM"      , SDA->DA_ORIGEM           , nil})
	Aadd(aCabec, {"DA_NUMSEQ"      , SDA->DA_NUMSEQ           , nil})
	Aadd(aCabec, {"DA_QTSEGUM"     , SDA->DA_QTSEGUM          , nil})
	Aadd(aCabec, {"DA_QTDORI2"     , SDA->DA_QTDORI2          , nil})
	
	aITem  := {}     
	aITens := {}     
	cItens := '0'  
	aNfeITE := {}      
	
    cItens := STRZERO(VAL(cItens)+1,4)//Soma1(SDB->DB_ITEM,4)

	AAdd(aNfeIte,{{"DB_ITEM"     , cItens                , NIL},;
	              {"DB_LOCALIZ"  , 'AAA01'                , NIL},;
	              {"DB_NUMSERI"  , ''                    , nil},;
	              {"DB_QUANT"    , SDA->DA_SALDO         , NIL},;
	              {"DB_HRINI"    , Time()                , NIL},;
	              {"DB_DATA"     , ddatabase             , NIL},;
	              {"DB_ESTORNO"  , ''                    , NIL},;
	              {"DB_QTSEGUM"  , 0                     , NIL} } )
	
	lMsErroAuto := .F.
	Begin Transaction
	
	MsExecAuto({|x,y,z| mata265(x,y,z)}, aCabec, aNfeITE, 3 ) // 3-Distribui, 4-Estorna
	
	IF lMsErroAuto
		DisarmTransaction()
		Break
	Endif

	lRet := .T.

	End Transaction
	
	IF lMsErroAuto
		MostraErro()
	Endif

	TRB->( Dbskip() )
	
	SB2->(dbSetFilter({|| .t.},".t.")) 
	SBF->(dbSetFilter({|| .t.},".t.")) 
	SB8->(dbSetFilter({|| .t.},".t.")) 
	
  EndDo
SDA->(dbSetFilter({|| .t.},".t."))  
DbCommitAll()
Return(lRet)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³fGeraSD3()ºAutor  ³Jailton B Santos-JBSº Data ³ 21/08/2010  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Guarda em array as informacoes dos registros do SD2 para    º±±
±±º          ³possivel geracao do SD3.                                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Especifico Faturamento Dipromed                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static function fGeraSD3(lDevolucao)

Local aArea_SDB := SDB->(GetArea())
Local aArea_SD5 := SD5->(GetArea())
Local aArea     := GetArea()

Local cNumseq 
Local _cLocaliz   := ''
Local _NumLote    := ''
Local _cGera      := ''
Local _cEST       := ''
Local _DtValid    := cTod('')                 
Local _TesDev  := ""
For nId := 1 to len(aRecSD2)
	
	SD2->(DbGoTo(aRecSD2[nId]))
	
	Begin Sequence
	
		SF4->(Dbsetorder(1))
   
		If SF4->(Dbseek(xfilial("SF4")+SD2->D2_TES))
			_cGera   := SF4->F4_GER_EST
			_cEST    := SF4->F4_ESTOQUE
			_TesDev  := SF4->F4_TESDV // MCVN  30/08/2010
		Endif
                                
	                                                                                                                              
		//---------------------------------------------------------------------------------------------
		// MCVN  30/08/2010 - Verifica se a TES de devolução atualizou estoque
		//---------------------------------------------------------------------------------------------
		If lDevolucao   
			If SF4->(Dbseek(xfilial("SF4")+_TesDev))
				_cGera := SF4->F4_GER_EST
				_cEST  := SF4->F4_ESTOQUE
			Endif			                                                                      
		EndiF
			
		//---------------------------------------------------------------------------------------------
		// JBS 21/08/2010 - Quando a rotina for chamada a partir da avaliacao de
		// processo de cancelamento de NFS e a mercadoria da nota fiscal que esta
		// sendo devolvida estiver no cliente.
		//---------------------------------------------------------------------------------------------
		If Type("lDip46GrD3") <> "U" .And. lDip46GrD3
			_cGera := 'N'
		Else
			_cGera := ' '
		EndIf
		
		If _cGera <> "N" .or. _cEst <> 'S'
			Break
		EndIf
		
		cNumseq := ProxNum()
		
		SB1->( Dbsetorder(1) )
		If SB1->(Dbseek(xFilial("SB1")+SD2->D2_COD))
			
			If SB1->B1_LOCALIZ == "S"
				If lDevolucao
					_cLocaliz := "AAA01"
				Else
					SDB->(DbSetOrder(1))
					IF SDB->( DbSeek(xFilial("SDB") + SD2->D2_COD + SD2->D2_LOCAL + SD2->D2_NUMSEQ))
						_cLocaliz := SDB->DB_LOCALIZ
					EndIf
				Endif
			EndIf
			
			If SB1->B1_RASTRO == "L" .OR. SB1->B1_RASTRO == "S"
				SD5->( Dbsetorder(3) )
				If SD5->( Dbseek(xFilial("SD5") + SD2->D2_NUMSEQ + SD2->D2_COD + SD2->D2_LOCAL + SD2->D2_LOTECTL))
					_NumLote := SD5->D5_NUMLOTE
					_DtValid := SD5->D5_DTVALID
				EndIf
			EndIf
			
		EndIf
		
		aadd(aRegSD3,{{"D3_ITEM"        , SD2->D2_ITEM                    ,Nil},;
		{"D3_COD"          , SD2->D2_COD                    ,Nil},;
		{"D3_LOCAL"        , SD2->D2_LOCAL                  ,Nil},;
		{"D3_NUMSEQ"       , cNumSeq                        ,Nil},;
		{"D3_QUANT"        , SD2->D2_QUANT                  ,Nil},;
		{"D3_CF"           , "RE0"                          ,NIL},;
		{"D3_UM"           , SD2->D2_UM                     ,NIL},;
		{"D3_TIPO"         , SD2->D2_TP                     ,NIL},;
		{"D3_GRUPO"        , SB1->B1_GRUPO                  ,NIL},;
		{"D3_CHAVE"        , "E0"                           ,Nil},;
		{"D3_USUARIO"      , U_DipUsr()						,NIL},;
		{"D3_ESTCIS"       , "S"                            ,Nil},;
		{"D3_CONTA"        , If(Len(Alltrim(SD2->D2_CONTA)) <> 9,"113104001" ,SD2->D2_CONTA) ,Nil},;
		{"D3_SEGUM"        , SD2->D2_SEGUM                  ,Nil},;
		{"D3_QTSEGUM"      , SD2->D2_QTSEGUM                ,Nil},;
		{"D3_IDENT"        , SD2->D2_SERIE                  ,Nil},;
		{"D3_LOTECTL"      , SD2->D2_LOTECTL                ,Nil},;
		{"D3_NUMLOTE"      , _NumLote                       ,Nil},;
		{"D3_DTVALID"      , _DtValid                       ,Nil},;
		{"D3_LOCALIZ"      , _cLocaliz                      ,Nil},;
		{"D3_EXPLIC"       , SD2->D2_DOC + SD2->D2_SERIE +  _ZD_Explic,Nil}})
		
		//  {"D3_IDENT"        , SD2->D2_SERIE                  ,Nil},;
		
		aCabSD3 :=  {{"D3_FILIAL"       , SD2->D2_FILIAL    ,Nil},;
		{"D3_DOC"          , SD2->D2_DOC                    ,Nil},;
		{"D3_TM"           , If(lDevolucao,"501","532")     ,Nil},;
		{"D3_EMISSAO"      , dDatabase                      ,NIL},;
		{"D3_CC"           , ""                             ,nil}}
		
   End Sequence    
   
Next nId
//---------------------------------------------------------------------------------------------------------
// JBS 21/08/2010 - Se existirem itens para gera SD3, gera o SD3 para os itens da nota fiscal de devolucao.
//---------------------------------------------------------------------------------------------------------
If len(aCabSD3) > 0

    lMsErroAuto := .F.
    //MSExecAuto({|x,y,z| MATA240(x,y,z)},aReg,,3)   
    MSExecAuto({|x,y,z| MATA241(x,y,z)},aCabSD3,aRegSD3,3) 

    If lMsErroAuto 
    	MostraErro()
    EndIf
    aCabSD3 := {} // JBS 21/08/2010 - Limpa para nao gerar mais 
    aRegSD3 := {} // JBS 21/08/2010 - Limpa para nao gerar mais 
EndIf

SDB->(RestArea(aArea_SDB))
SD5->(RestArea(aArea_SD5))

RestArea(aArea)
     
Return
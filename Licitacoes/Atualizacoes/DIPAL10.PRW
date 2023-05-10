#Include "PROTHEUS.CH"
#Include "RWMAKE.CH"
#Include "MSOLE.CH"
#INCLUDE "AP5MAIL.CH"        
#INCLUDE "COLORS.CH"

                                             
#DEFINE	_UA2	1
#DEFINE	_UA3	2
#DEFINE	_UA4	3
#DEFINE	_UA1	4                                                            	
#DEFINE CR    chr(13)+chr(10) // Carreage Return (Fim de Linha)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDIPAL10   บAutor  ณWilliam Ailton Mafraบ Data ณ  30/09/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ  Cadastro de Editais                                       บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Dipromed - Comercio e Importa็ใo Ltda                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
*-------------------------------------------*
User Function DIPAL10()
*-------------------------------------------*
Local aCores     := {}
Local cCodUsr    := alltrim(RetCodUsr())// Giovani Zago 08/03/2012
Local cUser      := GetMv("ES_VENDUSE",,"000053" )  // Giovani Zago 08/03/2012
//Local cVend      := ""         // MCVN - 27/04/09

Private cCadastro := "Cadastro de Editais"
Private aTables	:= {"UA2", "UA3", "UA4","UA1"}
Private aRotina := {}
Private cChaAlt := "B"//giovani 10/08/11
Private nDest   := 0
Static _lAlret  := .t.
Public nChavSx3 := 0
If Type("cDipVend") == "U" // MCVN - 30/11/09
	Public cDipVend := alltrim(Posicione("SU7",4,xFilial("SU7") + RetCodUsr(),"U7_CGC"))// Giovani Zago 08/03/2012
EndIf

aadd(aRotina,{"Pesquisar"   ,"AxPesqui"  ,0,1}) // Pesquisar
aadd(aRotina,{"Visualizar"  ,"U_D010"	 ,0,2}) // Visual
aadd(aRotina,{"Incluir"	    ,"U_D010"	 ,0,3}) // Incluir
aadd(aRotina,{"Alterar"	    ,"U_D010"	 ,0,4}) // Alterar
aadd(aRotina,{"Excluir"	    ,"U_D010"	 ,0,5}) // Excluir
aadd(aRotina,{"Valores"	    ,"U_DIPAL20" ,0,4}) // Valores DIPAL110()
aadd(aRotina,{"Resultado"   ,"U_DIPML50" ,0,4}) // Registro o resultado da concorrencia
aadd(aRotina,{"Empenho"	    ,"U_DIPAL80" ,0,4}) // Registra a chegado do empenho
aadd(aRotina,{"Avaliar"     ,"U_DIP10LIB",0,4}) // Encerra Edital
//aadd(aRotina,{"Or็am/Pedido","U_DIPR061" ,0,4}) // Imprime Or็amento e pedido de licita็ใo
aadd(aRotina,{"Reabrir"     ,"U_D011"    ,0,6}) //Giovani Zago 18/08/11
aadd(aRotina,{"Legenda"	    ,"U_DIP10LEG",0,5}) // Legenda
U_DIPPROC(ProcName(0),U_DipUsr()) // MCVN 22/01/2009
// Define F6 para incluir/alterar SIAFISICO no cadastro de produto(Informa็ใo usada pelo depto. de licita็ใo - MCVN - 31/07/2007

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ 0 - CINZA   -> Prazo para particiapr expirado                                                    ณ
//ณ 1 - LARANJA -> Foi informado dados basicos do Edital e o Cliente ๑ ้ "A" - Aguar Financeiro      ณ
//ณ 2 - AMARELO -> Cliente "A" ou jแ aprovado pelo Financeiro, Licita็ใo vai completar as informa็๕esณ
//ณ 3 - BRANCO  -> O Diretor Comercial estแ avaliando                                                ณ
//ณ 4 - AZUL    -> Aguarando ser informadas as garantias solicitadas pelo Dir Comercial              ณ
//ณ 6 - MARROM" -> Participamos e Perdemos                ณ
//ณ 7 - VERDE"  -> Aguardando empenho para Gerar o Pedido de vendas no SC5 e SC6                     ณ
//ณ 8 - VERMELHO-> Todos os empenho foram cumpridos e todos os pedido gerados                        ณ
//ณ 9 - PRETO   -> A Dipromed nใo vai participar deste processo                                      ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

aAdd(aCores,{"UA1_STATUS == '0'","BR_CINZA"})   // Prazo para particiapr expirado
aAdd(aCores,{"UA1_STATUS == '1'","BR_LARANJA"}) // Foi informado dados basicos do Edital e o Cliente ๑ ้ "A" - Aguar Financeiro
aAdd(aCores,{"UA1_STATUS == '2'","BR_AMARELO"}) // Cliente "A" ou jแ aprovado pelo Financeiro, Licita็ใo vai completar as informa็๕es
aAdd(aCores,{"UA1_STATUS == '3'","BR_BRANCO" }) // O Diretor Comercial estแ avaliando
//aAdd(aCores,{"UA1_STATUS == '4'","BR_AZUL"   }) // Aguarando ser informadas as garantias solicitadas pelo Dir Comercial
aAdd(aCores,{"UA1_STATUS == '5'","BR_PINK" }) // Aguardando informar pre็os a serem preticados no processo
aAdd(aCores,{"UA1_STATUS == '4'","BR_AZUL"   }) // Todos os dados foram informado, esta aguardando o resultado da Licita็ใo
aAdd(aCores,{"UA1_STATUS == '6'","BR_MARROM"  }) // Participamos e Perdemos // MCVN - 20/06/2007
aAdd(aCores,{"UA1_STATUS == '7'","BR_VERDE"  }) // Aguardando empenho para Gerar o Pedido de vendas no SC5 e SC6
aAdd(aCores,{"UA1_STATUS == '8'","BR_VERMELHO"})// Todos os empenho foram cumpridos e todos os pedido gerados
aAdd(aCores,{"UA1_STATUS == '9'","BR_PRETO"})   // A Dipromed nใo vai participar deste processo
UA1->(dbSetOrder(1))


U_DIPPROC(ProcName(0),U_DipUsr())

   /*
// Filtra pedido por operador  MCVN - 22/04/09
DbSelectArea("SU7")
SU7->(DbSetOrder(4))
SU7->(DbGoTop())
If (SU7->(dbSeek(xFilial("SU7")+cCodUsr)))
	cDipVend    := ALLTRIM(SU7->U7_CGC)
Endif    
*/  // Giovani Zago 08/03/2012 alterei e coloquei um posicione pra buscar o cod do vendedor para o filtro

SY1->(DbCloseArea())

If cCodUsr $ cUser
	UA1->(dbSetFilter({|| UA1->UA1_VEND == cDipVend},"UA1->UA1_VEND == cDipVend "))
	SA1->(dbSetFilter({|| SA1->A1_VEND == cDipVend}, "SA1->A1_VEND  == cDipVend "))
EndIf

mBrowse(,,,,aTables[_UA1],,,,,,aCores)
nChavSx3 := 0 
Return(.T.)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDIPAL10   บAutor  ณGiovani Zagoบ Data ณ  25/07/11           บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Reabertura de edital                                         บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Dipromed - Comercio e Importa็ใo Ltda                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function D011(cAlias,nReg,nOpcx)

Local nChave:= 0
//Local cMsgDecr:=
Local lSaida         :=.F.
Local nOpcao 		 := 0
Local  cNomeDes      := Upper(U_DipUsr())
Local cGetMotivo     := Space(90)
Local cMsgDecr       := "Voc๊ selecionou REABRIR este contrato."+CR+CR+"Confirma a REABERTURA ?"

If UA1->UA1_XENCER = "S"
	
	nChave:= Aviso("Reabrir Contrato",cMsgDecr ,{"Sim","Nใo"})
	If nChave == 1
		Do While !lSaida
			
			nOpcao := 0
			
			Define msDialog oDlg Title "Reabrir Contrato " From 10,10 TO 23,60
			
			@ 001,002 tO 78,196
			
			@ 010,010 say "Contrato" COLOR CLR_BLACK
			@ 020,010 say "Cliente " COLOR CLR_BLACK
			@ 030,010 say "Operador" COLOR CLR_BLACK
			
			@ 010,050 get UA1->UA1_CODIGO  when .f. size 050,08
			@ 020,050 get UA1->UA1_CODCLI when .f. size 120,08
			@ 030,050 GET cNomeDes when .f. size 120,08
			
			@ 050,010 say "Descreva o motivo da reabertura: " COLOR CLR_HBLUE
			@ 060,010 get cGetMotivo valid !empty(cGetMotivo) size 165,08
			
			DEFINE SBUTTON FROM 82,130 TYPE 1 ACTION IF(!empty(cGetMotivo),(lSaida:=.T.,nOpcao:=1,oDlg:End()),msgInfo("Motivo da reabertura nใo preenchido","Aten็ใo")) ENABLE OF oDlg
			//	DEFINE SBUTTON FROM 82,160 TYPE 2 ACTION (nOpcao:=0,oDlg:End()) ENABLE OF oDlg
			
			Activate dialog oDlg centered
			
		Enddo
		If nOpcao == 1
			
			RecLock("UA1",.F.)
			Replace UA1_STATUS With "7"
			Replace UA1_XENCER With " "
			Replace UA1_XMOTEN With ("  -- Reaberto: "+ALLTRIM(cGetMotivo)+" -- OPERADOR: "+Upper(U_DipUsr())+" -- "+DTOC(ddatabase))
			UA1->(MsUnLock())
			UA1->(DbCommit())
			
			
		EndIf
		
		
	EndIf
	
EndIf

return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDIPAL10   บAutor  ณWilliam Ailton Mafraบ Data ณ  09/30/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Inclusใo de edital                                         บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Dipromed - Comercio e Importa็ใo Ltda                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
*-------------------------------------------*
User Function D010(cAlias,nReg,nOpcx)
*-------------------------------------------*

Local aTitles:={ "Cartas","Documentos","Produtos"}

Local aArea:=GetArea()
Local oDlg
Local oFolder

Local aButtons:={}
Local oWFlow

Local cCadastro:="Incluir Edital"
Local aObjects:={}
Local aSize   :=MsAdvSize(.T.)
Local nCntFor :=1
Local nCntFor2:=1
//Altura,Largura da janela
Local nWndAlt :=0
Local nWndLar :=0

//posicao inicial do Folder
Local nFolderY:=0
//ja foi separado algo ou um produto teve o pre็o modificado
Local cAux:=""

// campos que nao serao mostrados UA1,UA2,UA3,UA4
Local aUnused:={{"UA2_EDITAL"},; // UA2
{"UA3_EDITAL"},; // UA3
{"UA4_EDITAL", "UA4_PRCVEN", "UA4_TOTAL","UA4_VENCEU","UA4_XPEDID"},;//"UA4_QTDENT","UA4_SALDO","UA4_XPEDID"},;//"UA4_ITEMLT"},; // UA4     //GIOVANI 
{"UA1_FILIAL","UA1_WFID", "UA1_WFLOW", "UA1_MODELO"}}    // UA1


Local cIniCpos:={"","","+UA4_ITEM+" }	// campos que nao serao mostrados UA2, UA3, UA4
Local aUsed:={{},{},{},{}} // campos que serao mostrados UA2, UA3, UA4, UA1
Local nOpcA:=0

Private aMemoFlds:={{{"UA2_OBS", "UA2_OBSMEM"}},; 	// Campos Memo UA2
{{"UA3_OBS", "UA3_OBSMEM"}},; 	// Campos Memo UA3
{{"UA4_DETPRO", "UA4_PROMEM"}, {"UA4_OBS"  , "UA4_OBSMEM"}},; // Campos Memo UA4
{{"UA1_OBS",  "UA1_OBSMEM"}, {"UA1_ORGAO", "UA1_ORGM"}, {"UA1_OBSDIR", "UA1_OBSMDI"}}}	  // Campos Memo UA1

private nTabPos  :=1 //Tab atual
private aGETS    :={}
private aTELA	 :={}
private oGetDados:={{},{},{}}
private aHeaders :={{},{},{}} //aHeader UA2, UA3, UA4
private aColunas :={{},{},{}} // aColunas UA2, UA3, UA4
private aHeader  :={} //auxiliares
private aCols    :={} //auxiliares
Private nOpcao:="0" 
Private oEnchUA1 

nChavSx3 := Nopcx 

IF !EMPTY(UA1_PEDIDO) .AND. nOpcx == 5 // Necessแrio estornar pedido para exluir edital - MCVN - 19/01/2007
	MsgAlert("Edital "+UA1->UA1_CODIGO+" gerou pedido "+UA1->UA1_PEDIDO+" e s๓ pode ser excluํdo se o pedido for excluido!","Atencao!")
	RETURN(.T.)
ENDIF

IF UA1->UA1_PEDIDO <> ' '  .AND. nOpcx == 4 
	MsgAlert("Edital "+UA1->UA1_CODIGO+" gerou pedido "+UA1->UA1_PEDIDO+" e s๓ pode ser alterado os saldos adicionais!","Atencao!")
	cChaAlt := "A"// Giovani Zago 18/08/11 chave para apresenta็ใo de tela de altera็ใo saldos add.
	aTitles:={ "","","Produtos"}
	_lAlret := .f.
	
ENDIF

If nOpcx == 2                  
	cChaAlt := "B"
EndIf
If UA1->UA1_PEDIDO = ' ' 
	cChaAlt := "B"
EndIf

If cEmpAnt == '01'
	IF (nOpcx == 4 .or. nOpcx == 5) .and. UA1->UA1_STATUS $ "9/8"
		MsgAlert("Edital "+UA1->UA1_CODIGO+" Estแ encerrado ou a Dipromed decidiu nใo participar! Nใo ้ permitida a altera็ใo.","Atencao!")
		RETURN(.T.)
	ENDIF
Else 
	IF (nOpcx == 4 .or. nOpcx == 5) .and. UA1->UA1_STATUS $ "9/8"
		MsgAlert("Edital "+UA1->UA1_CODIGO+" Estแ encerrado ou a Health Quality decidiu nใo participar! Nใo ้ permitida a altera็ใo.","Atencao!")
		RETURN(.T.)
	ENDIF
EndIf

IF nOpcx == 5
	MsgAlert("Nใo ้ permitida a exclusใo de editais. Utilize a op็ใo ENCERRAR.","Atencao!")
	RETURN(.T.)
ENDIF



RegToMemory(cAlias,nOpcx == 3)
RegToMemory("UA2",.F.)
RegToMemory("UA3",.F.)
RegToMemory("UA4",.F.)


If nOpcx == 3
	M->UA1_RISCO := space(1)
EndIf

nWndLar := (aSize[5]  - (aSize[5] * 0.15)) - (aSize[5] / 6)
nWndLar /= 2
nWndAlt := (aSize[6]  - aSize[7]) / 2

aAdd( aObjects, { nWndLar - 3 , (nWndAlt  / 2) - (nWndAlt * 0.15) ,.F.,.F. } )
aAdd( aObjects, { nWndLar , nWndAlt - aObjects[1,2] , .F.,.F. } )
aInfo    := { aSize[1],aSize[2],aSize[3],aSize[4], 3, 3 }
aPosObj  := MsObjSize( aInfo, aObjects,.T. )

AADD(aUsed[_UA1],"NOUSER")
SX3->(dbSetOrder(1))
SX3->(dbSeek(aTables[_UA1]))
//Giovani Zago 18/08/11
If cChaAlt = "B"
	Do While ( !SX3->( Eof() ) .And. SX3->X3_ARQUIVO == aTables[_UA1] )
		If ( X3USO(SX3->X3_USADO) .And. cNivel >= SX3->X3_NIVEL .And.;
			ASCAN( aUnused[_UA1], AllTrim(SX3->X3_CAMPO)  ) < 1)
			AADD(aUsed[_UA1],SX3->X3_CAMPO)
		EndIf
		SX3->(dbSkip())
	EndDo
	
	
ElseIf  cChaAlt = "A"
	
	Do While ( !SX3->( Eof() ) .And. SX3->X3_ARQUIVO == aTables[_UA1] )
		If ( X3USO(SX3->X3_USADO).And. SX3->X3_FOLDER = "5" .And. cNivel >= SX3->X3_NIVEL .And.;
			ASCAN( aUnused[_UA1], AllTrim(SX3->X3_CAMPO)  ) < 1)
			AADD(aUsed[_UA1],SX3->X3_CAMPO)
		EndIf
		SX3->(dbSkip())
	EndDo
	
	
EndIf
/*
If Upper(U_DipUsr()) $ 'ERIBERTO/MAXIMO/CLEIA' .And. (nOpcx == 2 .Or. nOpcx == 3 .Or. nOpcx == 4 )
If M->UA1_ACERTO <> 'S'
If MsgYesNo("Acerto de EDITAL ?","Ateno")
M->UA1_ACERTO := 'S'
Endif
Else
Alert("Este edital estแ marcado como acerto!!")
Endif
Endif
*/

//If M->UA1_ACERTO <> "S"
IF(nOpcx == 3)
	///		AADD(aUnused[_UA2],"UA2_SEPARA")
	///		AADD(aUnused[_UA3],"UA3_SEPARA")
Else
	//ja foi enviado p/ workflow, entao nใo permite mais edi็ใo
	If(UA1->UA1_WFLOW == '1')
		if(Empty(Alltrim(UA1->UA1_FINANC)) )
			Alert("Aguardando a Resposta do Financeiro!") // JBS 21/07/2006
		Else
			//Alert("Edital jแ finalizado!")
		EndIF
		// JBS 21/07/2006 -	aUsed[_UA1] := {}
	EndIF
EndIF
//Endif

DEFINE MSDIALOG oDlg TITLE cCadastro From aSize[7], aSize[5] / 6 To aSize[6] - (aSize[6] * 0.2), aSize[5] - (aSize[5] * 0.15) OF oMainWnd PIXEL
//EnChoice( cAlias ,nReg, nOpcx, , , ,aUsed[_UA1] , aPosObj[1],aUsed[_UA1], 3 )
oEnchUA1:= MsMGet():New("UA1", ,nOpcx,,,,aUsed[_UA1],aPosObj[1],aUsed[_UA1])//,,,,,,,,.F.,nil,,.T.)
oFolder := TFolder():New(aPosObj[2,1], aPosObj[2,2],;
aTitles,{"","","",""},oDlg,,,,.T.,.F., aPosObj[2,4] - 3  ,  (nWndAlt / 2) - (aObjects[1,2] / 2) )
//atualiza Tab atual
oFolder:bSetOption:={|nAtu| nTabPos:= nAtu}


If  cChaAlt = "B"
	nDest := Len(aTables) -1
ElseIf  cChaAlt = "A"
	nDest := 1
EndIf

For nCntFor := 1 To nDest
	If  cChaAlt = "A"
		nCntFor := 3
	EndIF
	cAux:=aTables[nCntFor]
	dbSelectArea(aTables[nCntFor])
	aHeaders[nCntFor] 	:= apBuildHeader(aTables[nCntFor],aUnused[nCntFor])
	// JBS 21/06/2006 -	If(UA1->UA1_WFLOW != '1')
	For nCntFor2 := 1 To Len(aHeaders[nCntFor])
		AADD(aUsed[nCntFor],aHeaders[nCntFor][nCntFor2][2])
	Next nCntFor2
	//		Else
	//			aUsed[_UA1] := {}
	//		EndIF
	IF(nOpcx != 3)
		&cAux.->( dbSetOrder(1) )
		&cAux.->( dbSeek(xFilial(aTables[nCntFor]) + UA1->UA1_CODIGO) )
		Do While !&cAux.->( EOF()) .And. &cAux.->(&cAux._FILIAL) == xFilial(aTables[nCntFor]) .And. &cAux.->(&cAux._EDITAL) == UA1->UA1_CODIGO
			AADD(aColunas[nCntFor],Array((Len(aHeaders[nCntFor])) + 1))
			For nCntFor2 := 1 To Len(aHeaders[nCntFor])
				//atualiza vetor de campos MEMO
				If ( aHeaders[nCntFor][nCntFor2][10] != "V" )
					aColunas[nCntFor][Len(aColunas[nCntFor])][nCntFor2] := FieldGet(FieldPos(aHeaders[nCntFor][nCntFor2][2]))
				Else
					aColunas[nCntFor][Len(aColunas[nCntFor])][nCntFor2] := CriaVar(aHeaders[nCntFor][nCntFor2][2])
				EndIf
				if(aHeaders[nCntFor][nCntFor2][8] =='M')
					//encontra posicao do campo no vetor de campos MEMO
					nAux := aScan(aMemoFlds[nCntFor],{|aVal| AllTrim(aHeaders[nCntFor][nCntFor2][2]) == aVal[1]} )
					cRelacao := aMemoFlds[nCntFor,nAux,2]
					aColunas[nCntFor][Len(aColunas[nCntFor])][nCntFor2] :=  MSMM( &(cRelacao) )
				EndIF
			Next nCntFor2
			aColunas[nCntFor][Len(aColunas[nCntFor])][Len(aHeaders[nCntFor])+1] := .F.
			&cAux.->( dbSkip() )
		EndDo
	ELSE  //Inclusao
		AADD(aColunas[nCntFor],Array((Len(aHeaders[nCntFor])+1)))
		For nCntFor2 := 1 To Len(aHeaders[nCntFor])
			AADD(aUsed[nCntFor],aHeaders[nCntFor][nCntFor2][2])
			aColunas[nCntFor][1][nCntFor2] := CriaVar(aHeaders[nCntFor][nCntFor2][2])
		Next nCntFor2
		aColunas[nCntFor][1][Len(aColunas[nCntFor][1])] := .F.
	EndIF
	
	oGetDados[nCntFor] 	:= MSNewGetDados():New (0, 0, (nWndAlt / 2)  - (aObjects[1,2] / 2) - 12, aPosObj[2,4]  - 7 , If(nOpcx != 2,GD_UPDATE+GD_DELETE+GD_INSERT , 0) , "u_DIP010Ln", "u_DIP10OK", cIniCpos[nCntFor], aUsed[nCntFor] , ,999, , , ,oFolder:aDialogs[nCntFor], aHeaders[nCntFor], aColunas[nCntFor])
	
Next nCntFor


if(nOpcx == 2)//visualizacao
	Aadd( aButtons,{"OUTLOOK"   ,{|| if(u_DIPWflow()    ,oDlg:End(),)},"Enviar para o financeiro" ,"WorkFLow"      ,{|| .T.}})
	Aadd( aButtons,{"PRTETQ"    ,{|| u_DIPRL60()}                     ,"Gerar Etiquetas"          ,"Etiquetas"     ,{|| .T.}})
	Aadd( aButtons,{"SALVAR"    ,{|| if(callWord()      ,oDlg:End(),)},"Abrir Modelo"             ,"Word"          ,{|| .T.}})
	Aadd( aButtons,{"PRECO"     ,{|| if(U_060PED()      ,oDlg:End(),)},"Gera Pedido de Amostra...","Pedido Amostra",{|| .T.}})
	Aadd( aButtons,{"RPMDES"    ,{|| if(U_060CON()      ,oDlg:End(),)},"Gera Carta  de Amostra...","Carta Amostra" ,{|| .T.}})
	Aadd( aButtons,{"PROJETPMS" ,{|| if(U_070PROPOSTA() ,oDlg:End(),)},"Gera Proposta do Edital..","Proposta"      ,{|| .T.}})
	Aadd( aButtons,{"SIMULACA"  ,{|| if(U_DIPR061()     ,oDlg:End(),)},"Gera Or็amento/Pedido....","Orcamen/Pedido",{|| .T.}})
	Aadd( aButtons,{"CHAVE2"    ,{|| if(U_DIP10LIB()    ,oDlg:End(),)},"Libera็ใo do Edital......","Libera Edital" ,{|| .T.}})
	Aadd( aButtons,{"CADEADO"   ,{|| if(U_DIP10ENC()    ,oDlg:End(),)},"Encerra o Edital.........","Encerra o Edital" ,{|| .T.}})
	Aadd( aButtons,{"DESTINOS"  ,{|| if(U_DIP10COMER()  ,oDlg:End(),)},"Cancela Libera็ใo comercial do Edital...","Cancela Libera็ใo Comercial" ,{|| .T.}})
	AAdd( aButtons,{"ALTERA"    ,{|| if(U_DIP10GRADE()  ,oDlg:End(),)},"Grade de Concorrencia....","Grade de Concorrencia" ,{|| .T.}})
	
	@ 15,15 BUTTON oWFlow PROMPT "..." SIZE 1,1 PIXEL OF oDlg
	
ElseIF(nOpcx == 3)
	oGetDados[_UA4]:aCols[1,1]  := "001"
EndIF

//Inclusใo de Produto
If (nOpcx == 3) .or. (nOpcx == 4) //MCVN - 27/06/07
	
	//////// Licita็ใo nใo inclui mais produtos a partir de 10/2008 - MCVN - 29/09/2008 \\\\\\
	
	// Aadd( aButtons, {"EDIT"    ,{|| U_DIPAL90()},"Inclusao de Produto...  " } )
	// Ativa a tecla F5 para chamar a inclusใo de produto
	// Set Key VK_F5 TO U_DIPAL90()
	// MsgBox("Utilize a Tecla F5 para incluir"+Chr(13)+Chr(13)+"produto !!!","Informacao.","INFO")
	
	////////-----------------------------------------------------------------------------\\\\\\\\\
	// Ativa a tecla F8 para chamar as caracteristicas do Produto
	Set Key VK_F8 TO U_DIPA004()
	MsgBox("Utilize a Tecla F8 para consultar"+Chr(13)+Chr(13)+"as Caracteristicas do Produto !!!","Informacao.","INFO")
	
Endif




Activate msDialog odlg Centered on init (u_diptg(),;
Enchoicebar(odlg, {||nopca:=if(u_dip10ok() .and. obrigatorio(agets,atela) , 1,0),if(nopca==1,odlg:end(),nil)},{||odlg:end()},,@abuttons))


If ( nOpcx != 2 .And. nOpcA == 1 )
	
	u_DIP10Grv(nOpcx)
	//u_DIPStat(.f.) MCVN - 29/08/2007 Nใo tem necessidade de ser chamada neste local
	If Inclui  .And. UA1->UA1_TIPO <> "6" // Eriberto 21/06/08 - Nใo envia Cic se for BEC - MCVN 18/09/2008
		Dipal10NEW()
	EndIf
	
	If Empty(UA1->UA1_RISCO)                                                               .and.;  // Nใo foi enviado ao financeiro, por isto nใo tem risco
		Empty(UA1->UA1_FINANC)                                                              .and.;  // Nใo foi aprovado pelo fianceiro
		Posicione("SA1",1,xFilial("SA1") + M->UA1_CODCLI + M->UA1_LOJA,"A1_RISCO") <> 'A'   .and.;  // Se nใo for risco "A" solicita avalia็ใo de cr้dito
		UA1->UA1_TIPO <> "6" //.And. UA1->UA1_ACERTO <> "S"
		//
		If  (!Empty(SA1->A1_ULTCOM) .And. SA1->A1_ULTCOM  > Date() - 180) .Or. ;  //Verifica se cliente nunca comprou ou nao compra a mais de 6 meses - MCVN 15/07/2008
			!Empty(UA1->UA1_FORNE1) .And. !Empty(UA1->UA1_FORNE2) .And. !Empty(UA1->UA1_FORNE3)
			lRet := u_DIPML40Financeiro()  // Envia e-mail solicitando aprova็ใo do financeiro
		Else
			MsgBox("O cliente nunca comprou ou nใo compra a mais de 6 meses. Favor preencher campos de fornecedores do cliente !!! ","Atencao ","ALERT")
			UA1->(Reclock("UA1",.f.))
			UA1->UA1_STATUS := '5'
			UA1->UA1_USUDIG := U_DipUsr() //SU7->U7_CICNOME
			UA1->UA1_DTRISC := dDataBase
			UA1->UA1_HRRISC := Time()
			UA1->(MsUnlock("UA1"))
		Endif
		//
	ElseIf (Empty(UA1->UA1_RISCO) .and. SA1->A1_RISCO == 'A') .or.;
		(UA1->UA1_TIPO == "6" .And. (Empty(UA1->UA1_RISCO) .and. SA1->A1_RISCO <> 'A')) //.or. ; // BEC nใo para no Financeiro
		//UA1->UA1_ACERTO = "S" // Qdo acerto grava as informa็๕es liberando o edital da avalia็ใo financeira MCVN - 12/03/2009
		//
		// Localiza o operador para usar o nome do CIC - Nใo funcionou, fica comentado para depois continuar
		//
		//SU7->(dbSetOrder(6))
		//SU7->(dbSeek(xFilial("SU7")+U_DipUsr()))
		//
		// Registra o mnova situa็ใo do cliente
		//
		UA1->(Reclock("UA1",.f.))
		UA1->UA1_RISCO  := SA1->A1_RISCO
		UA1->UA1_DTRISC := dDataBase
		UA1->UA1_HRRISC := Time()
		UA1->UA1_USUDIG := U_DipUsr() //SU7->U7_CICNOME
		UA1->UA1_STATUS := '2'
		UA1->UA1_FINANC := 'Pre-Aprovado Pelo Financeiro'
		UA1->(MsUnlock("UA1"))
	EndIF
EndIf                            // para clientes com classifica็ใo de risco diferente de "A"

If nOpcA != 1
	RollBackSX8()
EndIf

RestArea(aArea)
Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDIPAL10   บAutor  William	Ailton Mafra        ณ  09/30/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ  Verifica se pode incluir nova linha 					  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
*-------------------------------------------*
User Function DIP010Ln()
*-------------------------------------------*
Local oGetDado
Local nX   := 0
Local lRetorno := .T.
Local nCntFor := 0
Local nCntFor2 := 0
Local nCod := 0
Local nUsado := 0
Local nCheck := 1

oGetDado	:= oGetDados[nTabPos]

if(nTabPos == _UA4)
	nCheck := 2
Else
	nCheck := 1
EndIF

nUsado  := Len(oGetDado:aHeader)

if nTabPos == 1
	nCod := aScan(aHeader,{|x| AllTrim(x[2])=="UA2_CARTA"})
ElseIf nTabPos == 2
	nCod := aScan(aHeader,{|x| AllTrim(x[2])=="UA3_DOCTO"})
ElseIf nTabPos == 3
	nCod := aScan(aHeader,{|x| AllTrim(x[2])=="UA4_PRODUT"})
EndIf

If ( !oGetDado:aCols[n][nUsado+1] .And. !Empty( oGetDado:aCols[n][nCheck] ))
	For nX := 1 to Len( oGetDado:aHeader )
		If X3Obrigat( Alltrim(oGetDado:aHeader[nX][2]) ) .And. Empty( oGetDado:aCols[oGetDado:nAt][nX] )
			Help(" ",1,"OBRIGAT")
			lRetorno := .F.
			Exit
		EndIf
	Next nX
	if(lRetorno)
		For nCntFor := 1 To Len(oGetDado:aCols)
			For nCntFor2 := nCntFor To Len(oGetDado:aCols)
				//caso a linha que estแ sendo comparada nใo esteja marcada como deletada
				If(!oGetDado:aCols[nCntFor2,Len(oGetDado:aHeader)+1] .And. !oGetDado:aCols[nCntFor,Len(oGetDado:aHeader)+1] )
					//registro duplicado
					If(nCntFor != nCntFor2 .And. oGetDado:aCols[nCntFor,1] == oGetDado:aCols[nCntFor2,1]) .and. !Empty(oGetDado:aCols[nCntFor2,1])
						// MsgAlert("Existem registros duplicados!","Atencao!")
						// return .F.
					EndIF
				EndIf
				
				If nTabPos == 3 //Somente se estiver na guia de produtos MCVN 27/06/07
					// Validando lote ou item do edital MCVN 27/06/07
					If (Empty(oGetDado:aCols[nCntFor2,12]) .And. Empty(oGetDado:aCols[nCntFor2,13]) .And. Empty(oGetDado:aCols[nCntFor2,22]))
						MsgAlert("Favor informar o Item do edital ou Lote se for o caso!","Atencao!")
						return .F.
					Endif
					// Validando lote ou item + item do lote MCVN 27/06/07
					If (!Empty(oGetDado:aCols[nCntFor2,12]) .And. Empty(oGetDado:aCols[nCntFor2,13]))
						MsgAlert("Favor informar o Item do Lote!","Atencao!")
						return .F.
					ElseIf   Empty(oGetDado:aCols[nCntFor2,12]) .And. !Empty(oGetDado:aCols[nCntFor2,13])
						MsgAlert("Favor informar o Lote!","Atencao!")
						return .F.
					Endif
				Endif
			Next nCntFor2
		Next nCntFor
	EndIf
	
EndIf 

Return(lRetorno)
*--------------------------------------------*
User Function DIP10OK()
*--------------------------------------------*
Local nCntFor := 0
Local nCntFor2 := 0
Local nForTbls := 0
Local nCheck	:= 1
Local oGetDado
Local nDiTa     := 0   

u_CalcInd(.T.)

If  cChaAlt = "B"
	nDiTa := Len(aTables) -1
ElseIf  cChaAlt = "A"
	nDiTa := 1
EndIf         
                      
lEnvMail := .F.
aItens	 := {}

For nForTbls := 1 To nDiTa
	If  cChaAlt = "A"
		nForTbls := 3
	EndIF
	//For nForTbls := 1 To Len(aTables) -1
	if(nForTbls == _UA4)
		nCheck := 2
	Else
		nCheck := 1
	EndIF
	oGetDado := oGetDados[nForTbls]
	If(!Empty(oGetDado:aCols[1][nCheck]))
		For nCntFor := 1 to Len( oGetDado:aHeader )
			If X3Obrigat( Alltrim(oGetDado:aHeader[nCntFor][2]) ) .And. Empty( oGetDado:aCols[oGetDado:nAt][nCntFor] )
				Help(" ",1,"OBRIGAT")
				Return .F.
			EndIf
		Next nCntFor
		
		For nCntFor := 1 To Len(oGetDado:aCols)
			For nCntFor2 := nCntFor To Len(oGetDado:aCols)
				//caso a linha que estแ sendo comparada nใo esteja marcada como deletada
				If(!oGetDado:aCols[nCntFor2,Len(oGetDado:aHeader)+1] .And. !oGetDado:aCols[nCntFor,Len(oGetDado:aHeader)+1] )
					//registro duplicado
					If nCntFor != nCntFor2 .and.;
						oGetDado:aCols[nCntFor,nCheck] == oGetDado:aCols[nCntFor2,nCheck].and.;
						!Empty(oGetDado:aCols[nCntFor2,1])
						//   MsgAlert("Existem registros duplicados!","Atencao!")
						//	return .F.
					EndIF
					If nForTbls == 3 //Somente se estiver na guia de produtos MCVN 27/06/07
						// Validando lote ou item do edital MCVN 27/06/07
						If (Empty(oGetDado:aCols[nCntFor2,12]) .And. Empty(oGetDado:aCols[nCntFor2,13]) .And. Empty(oGetDado:aCols[nCntFor2,22]))
							MsgAlert("Favor informar o Item do edital ou Lote se for o caso!","Atencao!")
							return .F.
						Endif
						
						// Validando lote ou item + item do lote MCVN 27/06/07
						If (!Empty(oGetDado:aCols[nCntFor2,12]) .And. Empty(oGetDado:aCols[nCntFor2,13]))
							MsgAlert("Favor informar o Item do Lote!","Atencao!")
							return .F.
						ElseIf   Empty(oGetDado:aCols[nCntFor2,12]) .And. !Empty(oGetDado:aCols[nCntFor2,13])
							MsgAlert("Favor informar o Lote!","Atencao!")
							return .F.
						Endif               
						
						If !oGetDado:aCols[nCntFor2,Len(oGetDado:aHeader)+1] .And.;
							Alltrim(oGetDado:aCols[nCntFor2,2])$GetNewPar("ES_PROSANE","081022/011996/011953/081024/081235/081018/081023/081014") 
							
							If aScan(aItens,{|x| x==oGetDado:aCols[nCntFor2,2]})==0
								aAdd(aItens,oGetDado:aCols[nCntFor2,2])
							EndIf
							
							If !lEnvMail
								If DipVldTran(M->UA1_CODCLI,M->UA1_LOJA)
									cMsgAviso := "O Produto "+AllTrim(oGetDado:aCols[nCntFor2,2])+" (Item: "+AllTrim(oGetDado:aCols[nCntFor2,1])+") deste Edital s๓ pode ser transportado pela EMOVERE."+CHR(10)+CHR(13)
									cMsgAviso += "Confirma o envio dos pedidos exclusivamente pela EMOVERE?"  
									
									If Aviso("Aten็ใo",cMsgAviso,{"Sim","Nใo"},2)==1                
										lEnvMail := .T.			
									Else  
										lEnvMail := .F.
										aItens := {}  
										Return(.f.)
									EndIf								
								Else      
									cMsgAviso := "Este Edital cont้m itens que s๓ podem ser transportados pela EMOVERE, por้m a EMOVERE nใo atende a regiใo do cliente."+CHR(10)+CHR(13)
									cMsgAviso += "Retire o produto "+AllTrim(oGetDado:aCols[nCntFor2,2])+" (Item: "+AllTrim(oGetDado:aCols[nCntFor2,1])+") do Edital para continuar."
									Aviso("Aten็ใo",cMsgAviso,{"Ok"},2)
									Return.F.
								EndIf
							EndIf							
						EndIf
					Endif
				EndIf
			Next nCntFor2
		Next nCntFor
	EndIF
Next nForTbls               


If lEnvMail .And. Empty(M->UA1_SANEAN)
	_aMsg 		:= {}
	_cFrom      := ""
	_cEmail		:= ""
	_cAssunto	:= ""
	
	cMsg := "ATENวรO!"+CHR(10)+CHR(13)
	cMsg += "Usuแrio(a): "+Upper(U_DipUsr())+" - confirmou o edital "+M->UA1_CODIGO+" com produtos que s๓ podem ser transportados pela EMOVERE."																		
	
	If !("com produtos que s๓ podem ser transportados pela EMOVERE."$M->UA1_OBS)
		M->UA1_OBS += cMsg +CHR(10)+CHR(13)+ DtoC(dDataBase)                                                                                                                            
	EndIf
	
	U_DIPCIC(cMsg,"DIEGO.DOMINGOS")    
		
	_cFrom  	:= "protheus@dipromed.com.br"
    _cEmail  	:= "diego.domingos@dipromed.com.br"                                
    _cAssunto	:= "produto SANEANTE no edital "+M->UA1_CODIGO
    
   	Aadd( _aMsg , { "Edital: " 		        , M->UA1_CODIGO } )
	Aadd( _aMsg , { "Operador: "            , Upper(U_DipUsr()) } )
    
    For nI := 1 to Len(aItens)
		Aadd( _aMsg , { "Produto "+StrZero(nI,2)+": ", aItens[nI]+" - "+Posicione("SB1",1,xFilial("SB1")+aItens[nI],"B1_DESC") } )
	Next nI
			
	U_UEnvMail(_cEmail,_cAssunto,_aMsg,"",_cFrom,"DIPAL10")   
	
	M->UA1_SANEAN := "S"	
EndIf

return .T.
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDIPAL10   บAutor  ณWilliam Ailton Mafraบ Data ณ  10/03/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณInclusao/alteracao/exclusao na Base de Dados                บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
*-------------------------------------------------------*
User Function DIP10Grv(nOpc)
*-------------------------------------------------------*
Local aArea     := GetArea()
Local nCntFor   := 0
Local nCntFor2  := 0
Local nForTbls  := 0
Local cAux		:= ""
Local nUsado    := 0
//verifica se o Edital ja esta com todos os documentos e cartas separados e com todos os pre็os informados
Local lEditalOk	:= .F.
Local aRegs := {{},{},{}}
Local nItem, nItem2
Local nCheck := 1
Local cProduto := ""
Local cDetalhe := ""
Local cLote    := ""
Local nItemLt  := 0 
Local nDiTa    := 0
Local nValPrr  := 0

For nForTbls := 1 To Len(aTables) -1
	cAux	:= aTables[nForTbls]
	dbSelectArea(aTables[nForTbls])
	&cAux.->( dbSetOrder(1) )
	&cAux.->( dbSeek(xFilial(aTables[_UA2])+M->UA1_CODIGO) )
	Do While (&cAux.->(!Eof()).And.;
		xFilial(aTables[nForTbls]) == &cAux.->(&cAux._FILIAL) .And.;
		M->UA1_CODIGO == &cAux.->(&cAux._EDITAL))
		cSepara := "2"
		If nForTbls < 3
			cSepara := &cAux.->(&cAux._SEPARA)
		EndIF
		aadd(aRegs[nForTbls],{&cAux.->(RecNo() ), cSepara})
		&cAux.->( dbSkip() )
	EndDo
Next nForTbls

if nOpc <> 5
	Begin Transaction 
	
			If  cChaAlt = "B"
nDiTa := Len(aTables) -1 
ElseIf  cChaAlt = "A"
nDiTa := 1
	EndIf 
	
For nForTbls := 1 To nDiTa
 If  cChaAlt = "A" 
   nForTbls := 3
   EndIF

	
	
	
   //	For nForTbls := 1 To Len(aTables) -1
		cAux	:= aTables[nForTbls]
		nUsado  := Len(aHeaders[nForTbls])
		if(nForTbls == _UA4)
			nCheck := 2
		Else
			nCheck := 1
		EndIF  
		


		
		For nCntFor := 1 To Len(oGetDados[nForTbls]:aCols)
			If(!empty(oGetDados[nForTbls]:aCols[nCntFor][nCheck]))
				If ( nCntFor > Len(aRegs[nForTbls]) )
					If ( !oGetDados[nForTbls]:aCols[nCntFor][nUsado+1] )
						//Nova Carta
						RecLock(aTables[nForTbls],.T.)
						//	JBS					If nForTbls < 3 .and. m->&(cAux + "_SEPARA") == "1"
						//	JBS						FieldPut(FieldPos(cAux+"_USER"),cUserName)
						//	JBS					EndIF
					EndIf
				Else
					//ATUALIZACAO
					&cAux.->(dbGoto(aRegs[nForTbls,nCntFor,1]))
					RecLock(aTables[nForTbls],.F.)
					//encontra campo SEPARA no aHeader
					nSepaFld := aScan(aHeaders[nForTbls],{|aVal| "_SEPARA" $ aVal[2]} )
					//Se o usuario separou carta ou documento, grava nome do usuario
					//	JBS				If nForTbls < 3 .And. !Empty(aRegs[nForTbls,nCntFor,2]) .And. ;
					//	JBS					oGetDados[nForTbls]:aCols[nCntFor][nSepaFld] != aRegs[nForTbls,nCntFor,2]
					//	JBS					FieldPut(FieldPos(cAux+"_USER"),cUserName)
					//	JBS				EndIF             ?
				EndIf
				//Coloca o numero do Edital
				FieldPut(FieldPos(cAux+"_EDITAL"),M->UA1_CODIGO)
				If ( !oGetDados[nForTbls]:aCols[nCntFor][nUsado+1] )
					For nCntFor2 := 1 To nUsado
						xValue := oGetDados[nForTbls]:aCols[nCntFor][nCntFor2]
						nAux:= aScan(aMemoFlds[nForTbls],{|aVal| AllTrim(aHeaders[nForTbls][nCntFor2][2]) == aVal[1]})
						//Tratamento de campos MEMO
						if(nAux > 0)
							cFldCod := aMemoFlds[nForTbls,nAux,2]
							cExec := cAux+"->"+cFldCod
							MSMM(&cExec,,,xValue,1,,,cAux,cFldCod)
						ElseIf ( aHeaders[nForTbls][nCntFor2][10] != "V" .And. !"_USER" $ aHeaders[nForTbls][nCntFor2][2])
							
							RecLock(aTables[nForTbls],.F.)
ธ							If UA4->(Field(FieldPos(aHeaders[nForTbls][nCntFor2][2]))) != "UA4_ITEMLT"
								&cAux.->( FieldPut(FieldPos(aHeaders[nForTbls][nCntFor2][2]),xValue) )
							EndIf
							If cAux == "UA4"
								If UA4->(Field(FieldPos(aHeaders[nForTbls][nCntFor2][2]))) == "UA4_LOTE"
								   
										If xValue <> cLote
										cLote := xValue
										nItemLt := 0
									EndIf
									If !Empty(xValue)
										nItemLt++
										If !Empty(UA4->UA4_LOTE) 
										UA4->UA4_ITEMLT := StrZero(nItemLt,2)   // - MCVN - 25/02/2008
									Else
										UA4->UA4_ITEMLT := ""
									EndIf
										Else
										UA4->UA4_ITEMLT := ""
									EndIf
								EndIf
							EndIf
							
						EndIf
					Next nCntFor2
				Else
					IF(nOpc == 4)//caso esteja atualizando
						If ( nCntFor <= Len(aRegs[nForTbls]) )
							//exclui campos MEMO
							for nItem := 1 To Len(aMemoFlds[nForTbls])
								cFldCod := aMemoFlds[nForTbls,nItem,2]
								cExec := cAux+"->"+cFldCod
								MSMM(&cExec,,,,2)
							next nItem
							&cAux.->( dbDelete() )
						EndIf
					EndIf
				EndIf
				&cAux.->( MsUnLock() )
				
				IF nForTbls == _UA4
					SA7->( dbSetOrder(1) )
					nAux:= aScan(aHeaders[nForTbls],{|aVal| "_DETPRO" $ aVal[2]} )
					cDetalhe := M->oGetDados[nForTbls]:aCols[nCntFor,nAux]
					nAux:= aScan(aHeaders[nForTbls],{|aVal| "_PRODUT" $ aVal[2]} )
					cProduto := M->oGetDados[nForTbls]:aCols[nCntFor,nAux]
					IF( SA7->( dbSeek( xFilial("SA7")+ M->UA1_CODCLI+M->UA1_LOJA+cProduto ) ) )
						RecLock( "SA7", .F. )
						MSMM(SA7->A7_PROMEM,,,cDetalhe,1,,,"SA7","A7_PROMEM")
						SA7->( MsUnLock() )
					Elseif(Len(AllTrim(M->UA1_CODCLI)) > 0 .And. Len(AllTrim(M->UA1_LOJA)) > 0 .And. Len(AllTrim(cProduto)) > 0 )
						RecLock( "SA7", .T. )
						SA7->A7_FILIAL  := xFilial("SA7")
						SA7->A7_CLIENTE	:= M->UA1_CODCLI
						SA7->A7_LOJA	:= M->UA1_LOJA
						SA7->A7_PRODUTO	:= cProduto //UA4->UA4_PRODUT
						MSMM(SA7->A7_PROMEM,,,cDetalhe,1,,,"SA7","A7_PROMEM")
						SA7->( MsUnLock() )
					EndIF
				EndIF
			EndIF
		Next nCntFor
	Next nForTbls
	   If type("M->UA1_XVALPR") == "C"
        nValPrr := VAL(M->UA1_XVALPR)
            EndIf  
	 
	UA1->( dbSetOrder(1) )
	RecLock( aTables[_UA1], UA1->( !dbSeek( xFilial(aTables[_UA1])+ M->UA1_CODIGO ) ) )
	nItem2 := UA1->( FCount() )
	for nItem := 1 To nItem2
		cFldName := UA1->( FieldName(nItem) )
	   
			if "_FILIAL" $ cFldName
			UA1->( FieldPut( nItem, xFilial(aTables[_UA1]) ) )
		ElseIf UA1->(Field(nItem)) <> "UA1_RISCO"  .and. UA1->(Field(nItem)) <> "UA1_XVALPR"  
			UA1->( FieldPut( nItem, M->&( Field(nItem) ) ) ) 
		Elseif "_XVALPR" $ cFldName
			UA1->UA1_XVALPR := nValPrr
		EndIF
	next nItem
	nTable := _UA1
	cAux := aTables[_UA1]
	
	for nItem := 1 To Len(aMemoFlds[nTable])
		//encontra posicao do campo no vetor de campos MEMO
		cFldMemo := aMemoFlds[nTable,nItem,1]
		cFldCod := aMemoFlds[nTable,nItem,2]
		MSMM(UA1->&(cFldCod ),,,M->&( cFldMemo ),1,,,cAux,cFldCod)
	next nItem
	
	UA1->( MsUnLock()	)
	ConfirmSx8()
	End Transaction
ElseIf(nOpc == 5)
	Begin Transaction
	
	
	UA5->( dbSetOrder(1) )
	UA5->( dbSeek(XFilial("UA5")+UA1->UA1_CODIGO ) )
	While ( !UA5->( Eof() ) .And. UA5->UA5_EDITAL == UA1->UA1_CODIGO )
		RecLock("UA5", .F.)
		UA5->( dbDelete() )
		UA5->( msUnlock() )
		UA5->( dbSkip() )
	EndDo
	
	For nForTbls := 1 To Len(aTables) -1
		cAux	:= aTables[nForTbls]
		For nCntFor := 1 To Len(aRegs[nForTbls])
			&cAux.->( dbGoto(aRegs[nForTbls,nCntFor,1]) )
			RecLock(aTables[nForTbls])
			//exclui campos MEMO
			for nItem := 1 To Len(aMemoFlds[nForTbls])
				cFldCod := aMemoFlds[nForTbls,nItem,2]
				cExec := cAux+"->"+cFldCod
				MSMM(&cExec,,,,2)
			next nItem
			&cAux.->( dbDelete() )
			MsUnLock()
		Next nCntFor
	Next nForTbls
	cAux := aTables[_UA1]
	RecLock(cAux,.F.)
	//TRATAMENTO DE CAMPOS MEMO
	nTable := _UA1
	cAux := aTables[_UA1]
	for nItem := 1 To Len(aMemoFlds[nTable])
		cFldCod := aMemoFlds[nTable,nItem,2]
		MSMM(UA1->&(cFldCod ),,,,2)
	next nItem
	UA1->( dbDelete() )
	&cAux.->( MsUnLock() )
	End Transaction
EndIf



RestArea(aArea)
Return(.T.)

*--------------------------------------*
User Function DIPTG()
*--------------------------------------*
Local nHItem
Local nAItem
Local nForTbls  := 0
Local nDiTa   := 0
RegToMemory("UA4",.F.)


If  cChaAlt = "B"
	nDiTa := Len(aTables) -1
ElseIf  cChaAlt = "A"
	nDiTa := 1
EndIf

For nForTbls := 1 To nDiTa
	If  cChaAlt = "A"
		nForTbls := 3
	EndIF
	
	
	//For nForTbls := 1 To Len(aTables) -1
	aHeader  := oGetDados[nForTbls]:aHeader
	aCols	 := oGetDados[nForTbls]:aCols
	For nAItem := 1 to Len(aCols)
		For nHItem := 1 to Len(aHeader)
			If ExistTrigger(aHeader[nHitem][2])
				RunTrigger(2, nAItem)
			EndIF
		Next nHItem
	Next nAItem
	oGetDados[nForTbls]:ForceRefresh()
Next nForTbls

aHeader := {}
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDIPAL10   บAutor  ณWilliam Ailton Mafraบ Data ณ  10/05/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Verifica se o Edital ja esta com todos os documentos e     บฑฑ
ฑฑบ            cartas separados e com todos os pre็os informados		  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function DIPStat(lRetorno)
Local cQuery
Local lRet := .T.

/*
SELECT
(SELECT COUNT(UA2.UA2_SEPARA)
FROM UA2010 UA2 INNER JOIN UA1010 UA1 ON UA1_CODIGO = UA2.UA2_EDITAL
WHERE UA1.D_E_L_E_T_ <> '*'
AND	UA2.D_E_L_E_T_	<> '*'
AND UA1.UA1_FILIAL	= '  '
AND UA2.UA2_FILIAL	= '  '
AND UA1.UA1_CODIGO = '000047') QCARTAS,

(SELECT COUNT(UA3.UA3_SEPARA)
FROM UA3010 UA3 INNER JOIN UA1010 UA1 ON UA1_CODIGO = UA3.UA3_EDITAL
WHERE UA1.D_E_L_E_T_ <> '*'
AND UA3.D_E_L_E_T_	<> '*'
AND UA1.UA1_FILIAL	= '  '
AND UA3.UA3_FILIAL	= '  '
AND  UA1.UA1_CODIGO = '000047' ) QDOCS,


(SELECT COUNT(UA2.UA2_SEPARA)
FROM UA2010 UA2 INNER JOIN UA1010 UA1 ON UA1_CODIGO = UA2.UA2_EDITAL
WHERE UA1.D_E_L_E_T_ <> '*'
AND	UA2.D_E_L_E_T_	<> '*'
AND UA1.UA1_FILIAL	= '  '
AND UA2.UA2_FILIAL	= '  '
AND UA1.UA1_CODIGO = '000047'
AND UA2.UA2_SEPARA ='1') CARTAS,

(SELECT COUNT(UA3.UA3_SEPARA)
FROM UA3010 UA3 INNER JOIN UA1010 UA1 ON UA1_CODIGO = UA3.UA3_EDITAL
WHERE UA1.D_E_L_E_T_ <> '*'
AND UA3.D_E_L_E_T_	<> '*'
AND UA1.UA1_FILIAL	= '  '
AND UA3.UA3_FILIAL	= '  '
AND  UA1.UA1_CODIGO = '000047'
AND UA3.UA3_SEPARA ='1') DOCS,

(SELECT COUNT(UA4.UA4_TOTAL)
FROM UA4010 UA4 INNER JOIN UA1010 UA1 ON UA1_CODIGO = UA4.UA4_EDITAL
WHERE UA1.D_E_L_E_T_ <> '*'
AND	UA4.D_E_L_E_T_	<> '*'
AND UA1.UA1_FILIAL	= '  '
AND UA4.UA4_FILIAL	= '  '
AND  UA1.UA1_CODIGO = '000047'
AND UA4.UA4_TOTAL = 0.0) PRODUTOS,

(SELECT COUNT(UA4.UA4_PRCVEN)
FROM UA4010 UA4 INNER JOIN UA1010 UA1 ON UA1_CODIGO = UA4.UA4_EDITAL
WHERE UA1.D_E_L_E_T_ <> '*'
AND	UA4.D_E_L_E_T_	<> '*'
AND UA1.UA1_FILIAL	= '  '
AND UA4.UA4_FILIAL	= '  '
AND UA1.UA1_CODIGO = '000047'
AND UA4.UA4_PRCVEN > 0) PRECO,

(SELECT COUNT(UA1.UA1_WFLOW)
FROM UA1010 UA1
WHERE UA1.D_E_L_E_T_ <> '*'
AND UA1.UA1_FILIAL	= '  '
AND UA1.UA1_CODIGO = '000047'
AND UA1.UA1_WFLOW = '2' ) WF
*/
cQuery	:= "SELECT  "
cQuery	+= "    (SELECT COUNT(UA2.UA2_SEPARA)     "
cQuery	+= "            FROM "+ RETSQLNAME("UA2") + " UA2 INNER JOIN " + RETSQLNAME("UA1") + " UA1 ON UA1_CODIGO = UA2.UA2_EDITAL"
cQuery	+= "            WHERE UA1.D_E_L_E_T_ <> '*'	"
cQuery	+= "            AND	UA2.D_E_L_E_T_	<> '*'  "
cQuery	+= "            AND UA1.UA1_FILIAL	= '" + XFILIAL("UA1") + "'  "
cQuery	+= "            AND UA2.UA2_FILIAL	= '" + XFILIAL("UA2") + "'  "
cQuery	+= "            AND UA1.UA1_CODIGO = '" + M->UA1_CODIGO + "') QCARTAS, "

cQuery	+= "    (SELECT COUNT(UA3.UA3_SEPARA)"
cQuery	+= "            FROM "+ RETSQLNAME("UA3") + " UA3 INNER JOIN " + RETSQLNAME("UA1") + " UA1 ON UA1_CODIGO = UA3.UA3_EDITAL "
cQuery	+= "            WHERE UA1.D_E_L_E_T_ <> '*'	"
cQuery	+= "            AND UA3.D_E_L_E_T_	<> '*' "
cQuery	+= "            AND UA1.UA1_FILIAL	= '" + XFILIAL("UA1") + "' "
cQuery	+= "            AND UA3.UA3_FILIAL	= '" + XFILIAL("UA3") + "' "
cQuery	+= "            AND  UA1.UA1_CODIGO = '" + M->UA1_CODIGO + "') QDOCS,"

cQuery	+= "    (SELECT COUNT(UA2.UA2_SEPARA)     "
cQuery	+= "            FROM " + RETSQLNAME("UA2") + " UA2 INNER JOIN " + RETSQLNAME("UA1") + " UA1 ON UA1_CODIGO = UA2.UA2_EDITAL"
cQuery	+= "            WHERE UA1.D_E_L_E_T_ <> '*'	"
cQuery	+= "            AND	UA2.D_E_L_E_T_	<> '*' "
cQuery	+= "            AND UA1.UA1_FILIAL	= '" + XFILIAL("UA1") + "' "
cQuery	+= "            AND UA2.UA2_FILIAL	= '" + XFILIAL("UA2") + "' "
cQuery	+= "            AND UA1.UA1_CODIGO = '" + M->UA1_CODIGO + "' "
cQuery	+= "            AND UA2.UA2_SEPARA ='1') CARTAS, "

cQuery	+= "    (SELECT COUNT(UA3.UA3_SEPARA) "
cQuery	+= "            FROM " + RETSQLNAME("UA3") + " UA3 INNER JOIN " + RETSQLNAME("UA1") + " UA1 ON UA1_CODIGO = UA3.UA3_EDITAL "
cQuery	+= "            WHERE UA1.D_E_L_E_T_ <> '*'	"
cQuery	+= "            AND UA3.D_E_L_E_T_	<> '*' "
cQuery	+= "            AND UA1.UA1_FILIAL	= '" + XFILIAL("UA1") + "' "
cQuery	+= "            AND UA3.UA3_FILIAL	= '" + XFILIAL("UA1") + "' "
cQuery	+= "            AND  UA1.UA1_CODIGO = '" + M->UA1_CODIGO + "' "
cQuery	+= "            AND UA3.UA3_SEPARA ='1') DOCS, "

cQuery	+= "    (SELECT COUNT(UA4.UA4_TOTAL)  "
cQuery	+= "            FROM " + RETSQLNAME("UA4") + " UA4 INNER JOIN " + RETSQLNAME("UA1") + " UA1 ON UA1_CODIGO = UA4.UA4_EDITAL "
cQuery	+= "            WHERE UA1.D_E_L_E_T_ <> '*'	"
cQuery	+= "            AND	UA4.D_E_L_E_T_	<> '*' "
cQuery	+= "            AND UA1.UA1_FILIAL	= '" + XFILIAL("UA1") + "' "
cQuery	+= "            AND UA4.UA4_FILIAL	= '" + XFILIAL("UA1") + "' "
cQuery	+= "            AND UA1.UA1_CODIGO  = '" + M->UA1_CODIGO + "' "
cQuery	+= "            AND UA4.UA4_TOTAL > 0) PRODUTOS, "

cQuery	+= "    (SELECT COUNT(UA4.UA4_PRCVEN) "
cQuery	+= "            FROM " + RETSQLNAME("UA4") + " UA4 INNER JOIN " + RETSQLNAME("UA1") + " UA1 ON UA1_CODIGO = UA4.UA4_EDITAL "
cQuery	+= "            WHERE UA1.D_E_L_E_T_ <> '*'	"
cQuery	+= "            AND	UA4.D_E_L_E_T_	<> '*' "
cQuery	+= "            AND UA1.UA1_FILIAL	= '" + XFILIAL("UA1") + "' "
cQuery	+= "            AND UA4.UA4_FILIAL	= '" + XFILIAL("UA1") + "' "
cQuery	+= "            AND UA1.UA1_CODIGO  = '" + M->UA1_CODIGO + "' "
cQuery	+= "            AND UA4.UA4_PRCVEN  > 0) PRECO, "

cQuery	+= "    (SELECT COUNT(UA1.UA1_WFLOW) "
cQuery	+= "            FROM " + RETSQLNAME("UA1") + " UA1 "
cQuery	+= "            WHERE UA1.D_E_L_E_T_ <> '*'	"
cQuery	+= "            AND UA1.UA1_FILIAL	= '" + XFILIAL("UA1") + "' "
cQuery	+= "            AND UA1.UA1_CODIGO = '" + M->UA1_CODIGO + "' "
cQuery	+= "            AND UA1.UA1_WFLOW = '2' ) WF, "

cQuery	+= "    (SELECT COUNT(UA4.UA4_EDITAL)  "
cQuery	+= "            FROM " + RETSQLNAME("UA4") + " UA4 INNER JOIN " + RETSQLNAME("UA1") + " UA1 ON UA1_CODIGO = UA4.UA4_EDITAL "
cQuery	+= "            WHERE UA1.D_E_L_E_T_ <> '*'	"
cQuery	+= "            AND	UA4.D_E_L_E_T_	<> '*' "
cQuery	+= "            AND UA1.UA1_FILIAL	= '" + XFILIAL("UA1") + "' "
cQuery	+= "            AND UA4.UA4_FILIAL	= '" + XFILIAL("UA1") + "' "
cQuery	+= "            AND UA1.UA1_CODIGO  = '" + M->UA1_CODIGO + "' "
cQuery	+= "            AND UA4.UA4_EDITAL = UA1.UA1_CODIGO ) ED_PRODUTOS "


//	cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN", TCGENQRY(,,cQuery),"TMPCOLOR", .F., .T.)
memowrite('EDITAL-DIPAL10.SQL',cQuery)

If !lRetorno
	
	DBSelectArea( "UA1" )
	
	UA1->(RecLock("UA1",.F.))
	
	If UA1->UA1_DVALID >= dDataBase
		
		If TMPCOLOR->QCARTAS  > 0 .and. TMPCOLOR->QCARTAS  = TMPCOLOR->CARTAS .and.; // Qtde de Cartas = Qtde separadas
			TMPCOLOR->QDOCS    > 0 .and. TMPCOLOR->QDOCS    = TMPCOLOR->DOCS   .and.; // Qtde de Documentos = Qtde de Documentos separados
			TMPCOLOR->PRODUTOS > 0 .and. TMPCOLOR->PRODUTOS = TMPCOLOR->PRECO         // Produtos informados e pre็os jแ informados
			
			u_DIPML40Vendas("Edital Completo: Cartas e Doc Informados e Separados e valores informados")     // Envia e-mail solicitando aprova็ใo do a Gerencia Comercial
			
			
		ElseIf TMPCOLOR->QCARTAS  > 0 .and. TMPCOLOR->QCARTAS  = TMPCOLOR->CARTAS .and.; // Qtde de Cartas = Qtde separadas
			TMPCOLOR->QDOCS    > 0 .and. TMPCOLOR->QDOCS    = TMPCOLOR->DOCS   .and.; // Qtde de Documentos = Qtde de Documentos separados
			TMPCOLOR->PRODUTOS > 0            // Produtos informados e pre็os jแ informados
			
			u_DIPML40Vendas("Edital com cartas e documentos informados e separados")     // Envia e-mail solicitando aprova็ใo da Gerencia Comercial
			
		ElseIf TMPCOLOR->QCARTAS   > 0 .and.;
			TMPCOLOR->QDOCS     > 0 .and.;
			TMPCOLOR->PRODUTOS > 0            // Produtos informados e pre็os jแ informados
			
			u_DIPML40Vendas("Edital com cartas e documentos informados")     // Envia e-mail solicitando aprova็ใo da Gerencia Comercial
			
		ElseIf UA1->UA1_TIPO == "6" .and.;       // Tipo de Edital ้ BEC
			TMPCOLOR->PRODUTOS > 0 .and. TMPCOLOR->PRODUTOS = TMPCOLOR->PRECO     // Produtos informados e pre็os jแ informados
			
			u_DIPML40Vendas("Edital com os produtos e valores informados - BEC")     // Envia e-mail solicitando aprova็ใo da Gerencia Comercial
			
		EndIf
		
	Else
		
		UA1->UA1_STATUS := "0"
		
	EndIF
	
	UA1->(MsUnLock())
	
Else
	lRet:=TMPCOLOR->QCARTAS  > 0 .and. TMPCOLOR->QCARTAS  = TMPCOLOR->CARTAS .and.;  // Qtde de Cartas = Qtde separadas
	TMPCOLOR->QDOCS    > 0 .and. TMPCOLOR->QDOCS    = TMPCOLOR->DOCS    .and.; // Qtde de Documentos = Qtde de Documentos separados
	TMPCOLOR->PRODUTOS > 0 .and. TMPCOLOR->PRODUTOS = TMPCOLOR->PRECO          // Produtos informados e pre็os jแ informados
EndIf

TMPCOLOR->(dbCloseArea())

Return lRet

/*/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDIPAL10   บAutor  ณWilliam Ailton Mafraบ Data ณ  10/07/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Envia WorkFlow                                             บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
*-------------------------------------------*
User Function DIPWflow()
*-------------------------------------------*
Local lRet := .F.
Local cMail
cMail :="giovani.zago@dipromed.com.br"// GetMV("MV_DIPWF")
lRet := u_DIPML40Financeiro()
return (lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDIPAL10   บAutor  ณWilliam Ailton Mafraบ Data ณ  10/25/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Mostra legenda                                             บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
*-------------------------------------------*
User Function DIP10LEG()
*-------------------------------------------*
local aStatus:={}
aadd(aStatus,{"BR_CINZA"   , "Expirado"})             // Prazo para particiapr expirado
aadd(aStatus,{"BR_LARANJA" , "Financeiro"})           // Foi informado dados basicos do Edital e o Cliente ๑ ้ "A" - Aguar Financeiro
aadd(aStatus,{"BR_AMARELO" , "Dados Licita็ใo"})      // Cliente "A" ou jแ aprovado pelo Financeiro, Licita็ใo vai completar as informa็๕es
aadd(aStatus,{"BR_BRANCO"  , "Diretor Comercial"})    // O Diretor Comercial estแ avaliando
aadd(aStatus,{"BR_MARROM"  , "Participamos e Perdemos"}) // Participamos e perdemos MCVN - 20/06/2007
aadd(aStatus,{"BR_AZUL"    , "Resultado"})            // Todos os dados foram informado, esta aguardando o resultado da Licita็ใo
aadd(aStatus,{"BR_VERDE"   , "Empenho"})              // Aguardando empenho para Gerar o Pedido de vendas no SC5 e SC6
aadd(aStatus,{"BR_VERMELHO", "Encerrado"})            // Todos os empenho foram cumpridos e todos os pedido gerados
aadd(aStatus,{"BR_PRETO"   , "Nใo Participar"})       // A Dipromed nใo vai participar deste processo
aadd(aStatus,{"BR_PINK"    , "Aguardando Inf. Fornec."})        // Prazo para particiapr expirado

/*------------------------------------------------
aadd(aStatus,{"BR_VERDE"   	 , "Em andamento"})
aadd(aStatus,{"BR_VERMELHO"  , "Expirado"})
aadd(aStatus,{"BR_AMARELO"   , "Rejeitado"})
aadd(aStatus,{"BR_AZUL"    	 , "Completo"})
aadd(aStatus,{"BR_PRETO"	 , "Finalizado"})
--------------------------------------------------*/

BrwLegenda(cCadastro, "Status", aStatus)       // A Dipromed nใo vai participar deste processo

Return .T.


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDIPAL10   บAutor  ณWilliam Ailton Mafraบ Data ณ  10/25/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ  Abre o arquivo apontado pelo campo modelo do edital       บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

*----------------------------------------------------*
Static Function callWord()
*----------------------------------------------------*
Local cPathEst	:= "C:\WINDOWS\TEMP\"
Local cFile
Local nPos

If(!Empty(UA1->UA1_MODELO))
	nPos := RAT("\",UA1->UA1_MODELO)
	cFile 	:= SUBSTR(UA1->UA1_MODELO, nPos+1,Len(UA1->UA1_MODELO) )
	MontaDir(cPathEst)
	CpyS2T(UA1->UA1_MODELO,cPathEst,.T.) // Copia do Doc Server para o Remote, eh necessario
	ShellExecute("open",cPathEst+cFile, "", "", 1)
EndIf
Return .T.
*---------------------------------------------------------------------*
User Function Dipal10CIC(cMensagem, cUsuDestino, lMensagem, cAssunto)
*---------------------------------------------------------------------*
Local cMail
Local cServidor   := GetMV("MV_CIC")     // Servidor para enviar mensagem pelo CIC
Local cOpFatRem   := GetMV("MV_REMETCI") // Usuario do CIC remetente de mensagens no Protheus
Local cOpFatSenha := "123456"
Local cOpFatDest  := cUsuDestino

Default lMensagem := .t.

cMail := "IMPORTANTE" + Chr(13) + Chr(10)
cMail += Chr(13) + Chr(10)
cMail += cMensagem
cMail += Chr(13) + Chr(10)

If lMensagem
	cMail += "----------------------------------------------" + Chr(13) + Chr(10)
	cMail += "Mensagem enviada automaticamente pelo Protheus" + Chr(13) + Chr(10)
	cMail += "----------------------------------------------" + Chr(13) + Chr(10)
EndIf

cMail += Chr(13) + Chr(10)
ConOut("[" + left(dToc(dDataBase),5)+"] - CIC WorkFlow ... ")
ConOut("     ["+left(time(),5)+"] Servidor......: " + cServidor )
ConOut("     ["+left(time(),5)+"] Remetente.....: " + cOpFatRem )
ConOut("     ["+left(time(),5)+"] Destinatario..: " + cOpFatDest)
ConOut(cMail)

//WaitRun(cServidor+' '+cOpFatRem+' '+cOpFatSenha+' "'+AllTrim(cOpFatDest)+'" "'+cMail+'" ')
WaitRun(cServidor+' '+cOpFatRem+' '+cOpFatSenha+' "'+AllTrim(cOpFatDest)+'" "3'+cMail+'" ',1)
WaitRun(cServidor+' '+cOpFatRem+' '+cOpFatSenha+' "'+AllTrim(cOpFatDest)+'" "4'+cMail+'" ',0)
WaitRun(cServidor+' '+cOpFatRem+' '+cOpFatSenha+' "'+AllTrim(cOpFatDest)+'" "4'+cMail+'" ',3)
Return(.t.)
*----------------------------------------------------------*
User Function Dipal10Mail(cMensagem, aContaUsuarios , cAssunto)
*----------------------------------------------------------*
Local cPontoVirgual:=''
LOCAL lSmtpAuth := GetNewPar("MV_RELAUTH",.F.)
LOCAL lAutOk	:= .F.

Private cBody:=""
private aUsuario  :="", oDlgMail, nOp:=0
private cFrom     :=""
private cServer   :=AllTrim(GetNewPar("MV_RELSERV"," ")) // "mailhost.average.com.br" //Space(50)
private cAccount  :=AllTrim(GetNewPar("MV_RELACNT"," ")) //Space(50)
private cPassword :=AllTrim(GetNewPar("MV_RELPSW" ," "))  //Space(50)
private nTimeOut  :=GetMv("MV_RELTIME",,120) //Tempo de Espera antes de abortar a Conexใo
private lAutentica:=GetMv("MV_RELAUTH",,.F.) //Determina se o Servidor de Email necessita de Autentica็ใo
private cUserAut  :=Alltrim(GetMv("MV_RELAUSR",,cAccount)) //Usuแrio para Autentica็ใo no Servidor de Email
private cPassAut  :=Alltrim(GetMv("MV_RELAPSW",,cPassword)) //Senha para Autentica็ใo no Servidor de Email
private cTo       :=space(200)
private cSubject  := cAssunto
Private aUsuario  :={}
Private cBcc      := ""

begin sequence

PswOrder(2)
For id:=1 to len(aContaUsuarios)
	If PswSeek(AllTrim(aContaUsuarios[id]))
		aUsuario := PswRet(1)
		cTo += cPontoVirgual + AllTrim(aUsuario[1,14])
		cPontoVirgual := '; '
	Else
		ConOut('-----------------------------------------')
		ConOut('Usuario ' + AllTrim(aContaUsuarios[id]) + ' nao encontrado! ')
		ConOut('-----------------------------------------')
	EndIf
Next


//If "encerrado" $ cMensagem  .Or. "rejeitado" $ cMensagem// MCVN - 10/09/2008  // MCVN 24/08/08 tb serแ enviado tb qdo edital for rejeitado
	cTo  := GetNewPar("ES_D10MAIL","publico@dipromed.com.br;erich.pontoldio@dipromed.com.br")+";"+Alltrim(Posicione("SA3",1,xFilial("SA3")+UA1->UA1_VEND,"A3_EMAIL"))
	cBcc := ""
//Else
//	cTo := Alltrim(cTo)
//Endif

If !len(AllTrim(cTo)) > 0
	ConOut('----------------------[ Atencao ]-----------------------')
	ConOut('--   E-Mail nao enviado: Problema com o Destinatario  --')
	ConOut('--------------------------------------------------------')
	break
EndIf
cFrom:="protheus@dipromed.com.br"

cBody := '<html>'
cBody += '<head>'
cBody += '<title>'+cAssunto+'</title>'
cBody += '</head>'
cBody += '<body>'
cBody += '<table width="100%" border="2">'
cBody += '<tr align="center">'
cBody += '<td width="100%" colspan="10"><font color="blue" size="4"></font></td>'
cBody += '</tr>'
cBody += '<tr align="Left">'
If "Licita็ใo - Separar Cartas" $ cAssunto
	cBody += '<td width="100%" colspan="10" align="left"><font color="black" size="2">'+cMensagem+'</td>'
Else
	cBody += '<td width="100%" colspan="10" align="left"><font color="black" size="4">'+cMensagem+'</td>'
Endif

cBody += '</font>'
cBody += '</tr>'
cBody += '<tr align="center">'
cBody += '<td colspan="10"><font color="blue" size="3">Mensagem enviada automaticamente pelo sistema PROTHEUS - <font color="blue" size="1">(DIPAL010.PRW)</td>'
cBody += '</tr>'

CONNECT SMTP SERVER cServer ACCOUNT cAccount PASSWORD cPassword TIMEOUT nTimeOut Result lOk

If !lAutOk
	If ( lSmtpAuth )
		lAutOk := MailAuth(cAccount,cPassword)
	Else
		lAutOk := .T.
	EndIf
EndIf

If lOk .And. lAutOk
	SEND MAIL FROM cFrom TO cTo BCC cBcc SUBJECT cSubject BODY cBody Result lOk
	If !lOk
		GET MAIL ERROR cErrorMsg
		Help("",1,"AVG0001056",,"Error: "+cErrorMsg,2,0)
	EndIf
Else
	GET MAIL ERROR cErrorMsg
	Help("",1,"AVG0001057",,"Error: "+cErrorMsg,2,0)
EndIf
DISCONNECT SMTP SERVER RESULT lOk
If !lOk
	GET MAIL ERROR cErrorMsg
	ConOut('Problemas no envio de e-mails ')
EndIf

End Sequence

Return .T.
/////////////////////////////////////////////////////////////////////////////////////////////////
/*
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณValDataHOra บAutor  ณMaximo  Canuto V. Netoบ Dataณ 10/25/05 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ  Valida Datas e horแrios                                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
*/

User Function ValDataHora()
Local cVal
IF M->UA1_DENCER < M->UA1_DABERT
	
	MSGINFO("Favor informar datas vแlidas!","Atencao!")
	cVal := ""
	Return(cVal)
	
ELSEIF M->UA1_DENCER = M->UA1_DABERT .AND. M->UA1_HABERT >= M->UA1_HENCER
	
	MSGINFO("Favor informar horแrios vแlidos!","Atencao!")
	cVal := ""
	Return(cVal)
ELSE
	cVal := M->UA1_CONDPAG
	Return(cVal)
ENDIF



/*
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDIP10ENC  บAutor  ณMaximo	Canuto V. Netoบ Data ณ 02/06/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ  Encerra edital                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
*/

User Function DIP10ENC()
Local cGetMotivo  := Space(250)
Local nOpcao      := 0
Local lSaida      := .F.
Local cObsMem     := MSMM(UA1->UA1_OBSMEM,,,,3)
Local cUser       := GetMV("MV_LICIENC")
//Local aContaUser  := {UA1->UA1_USUDIG,U_DipUsr(),"Rose","Patricia","Joseni Silva","Helena Souza"}
Local aContaUser  := {UA1->UA1_USUDIG,U_DipUsr(),"Patricia"}
Local cCliente    := Upper(Posicione("SA1",1,xFilial("SA1")+UA1->UA1_CODCLI+UA1->UA1_LOJA,"A1_NOME"))
Local aRetBox1 	  := {}
Local cTipoPreg   := ""

If !Upper(U_DipUsr()) $ AllTrim(Upper(cUser))
	MSGSTOP("Usuario sem autoriza็ใo!")
	Return(.T.)
EndIf

IF UA1->UA1_STATUS $ "9/8"
	MsgAlert("Edital "+UA1->UA1_CODIGO+" jแ encerrado.","Atencao!")
	RETURN(.T.)
ENDIF
       
//Desabilitado em 10/06/13 solicitado por Patrํcia (Possibilitar o encerramento do edital mesmo com saldo)
/*IF !EMPTY(UA1_PEDIDO) // Necessแrio estornar pedido para exluir edital - MCVN - 19/01/2007
	MsgAlert("Edital "+UA1->UA1_CODIGO+" gerou pedido "+UA1->UA1_PEDIDO+" e nใo pode ser encerrado!","Atencao!")
	RETURN(.T.)
ENDIF*/

Do While !lSaida
	nOpcao := 0
	
	Define msDialog oDlg Title "Encerrando Edital "+UA1->UA1_CODIGO From 10,10 TO 17,53
	
	@ 001,002 tO 40,170
	@ 010,010 say "Descreva o motivo do encerramento: "  COLOR CLR_HBLUE
	@ 020,010 get cGetMotivo valid !empty(cGetMotivo) size 154,08
	
	DEFINE SBUTTON FROM 41,108 TYPE 1 ACTION IF(!empty(cGetMotivo) .and. Len(Alltrim(cGetMotivo))>20,(lSaida:=.T.,nOpcao:=1,oDlg:End()),msgInfo("Motivo do encerramento nใo preenchido ou preenchido com informa็ใo insuficiente","Aten็ใo")) ENABLE OF oDlg
	DEFINE SBUTTON FROM 41,143 TYPE 2 ACTION (lSaida:=.T.,nOpcao:=0,oDlg:End()) ENABLE OF oDlg
	
	Activate dialog oDlg centered
	
EndDo

If nOpcao == 1
	
	cObsMem += CR + Upper(AllTrim(cGetMotivo) + CR +" - Encerrado por "+U_DipUsr()+".")
	
	UA1->(Reclock("UA1",.f.))
	UA1->UA1_STATUS := '9'
	If Empty(cObsMem)
		MSMM(UA1->UA1_OBSMEM,60,,cObsMem,2,,,"UA1","UA1_OBSMEM")
		UA1->UA1_OBSMEM := ''
	Else
		If Empty(UA1->UA1_OBSMEM)
			MSMM(UA1->UA1_OBSMEM,60,,cObsMem,1,,,"UA1","UA1_OBSMEM")
		Else
			MSMM(UA1->UA1_OBSMEM,60,,cObsMem,4,,,"UA1","UA1_OBSMEM")
		EndIf
	EndIf
	UA1->(MsUnlock("UA1"))
	
	// BUSCANDO OPวีES NO SX3
	aRetBox1 	:= {}
	aRetBox1 	:= RetSx3Box( Posicione('SX3', 2, 'UA1_TIPO', 'X3CBox()' ),,, 1 )
	cTipoPreg 	:= AllTrim( aRetBox1[ Ascan( aRetBox1, { |x| x[ 2 ] == UA1->UA1_TIPO } ) , 3 ] )
	
	// Preparando envio de e-mail e cic - MCVN 10/09/2008
	ConOut("Licita็ใo - Edital [" +UA1->UA1_CODIGO+ "] Encerrado por "+ U_DipUsr())
	cMensagem := "Licita็ใo - Edital [" + UA1->UA1_CODIGO + "] foi encerrado por "+U_DipUsr()+'!'+;
	CR+CR+'Cliente: '+Upper(UA1->UA1_CODCLI)+" - "+Upper(Alltrim(cCliente))+;
	CR+ cTipoPreg+' - Nบ '+AllTrim(UA1->UA1_NRCONC)+;
	CR+'Data de Encerramento : '+DtoC(UA1->UA1_DENCER)+;
	CR+CR+'Motivo : '+Upper(AllTrim(cGetMotivo))
	
	If UA1->UA1_TIPO <> "6" // Nใo envia e-mail ou cic quando for BEC e Pregใo Eletr๔nico  MCVN - 18/09/08
		Dipal10Enc(cGetMotivo)
	Endif
	u_Dipal10Mail(cMensagem,aContaUser,"Licita็ใo - Edital [" +UA1->UA1_CODIGO+ "]  Encerrado por "+ U_DipUsr()+".")
	
	MsgAlert("Edital "+UA1->UA1_CODIGO+" foi encerrado!","Atencao!")
	
	
Endif

Return(.F.)

/*
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDIP10LIB  บAutor  ณMaximo	Canuto V. Netoบ Data ณ 14/07/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ  Libera Edital                                             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
*/

User Function DIP10LIB()
Local cAssunto   := ""
Local cMensagem  := ""
Local cUser      := GetMV("MV_LICILIB")
Local cAvaliador := AllTrim(Upper(U_DipUsr()))
Local cMail      := ""
Local aProduts   := {}
Local Li         := 010
Local cGetMotivo := Space(90)
Local nOpcao     := 0
Local oDlg
Local cObsDir    := MSMM(UA1->UA1_OBSMDI,,,,3)
Local cObsMem    := MSMM(UA1->UA1_OBSMEM,,,,3)
Local mObsFin
Local aButtons 	 := {}
Local lSaida     := .F.
Local cCliente   := UA1->UA1_CODCLI+"/"+UA1->UA1_LOJA
Local cNomeCli   := Upper(Posicione("SA1",1,xFilial("SA1")+UA1->UA1_CODCLI+UA1->UA1_LOJA,"A1_NOME"))


If !AllTrim(Upper(U_DipUsr())) $ AllTrim(Upper(cUser))
	MSGSTOP("Usuario sem autoriza็ใo!")
	Return(.f.)
EndIf



If UA1->UA1_WFLOW = "2" .And. UA1->UA1_STATUS = "1" .And. Empty(UA1->UA1_FINANC)
	
	
	// Tela de avalia็ใo de cr้dito - MCVN - 12/07/2007
	
	
	Define msDialog oDlg Title "Avalia็ใo de cr้dito do Edital  "+UA1->UA1_CODIGO+" - "+cNomeCli From 10,10 TO 33,66
	
	@ 001,002 to 170,220
	//	@ 065,002 to 091,200
	
	@ 010,010 say "Cliente/Loja"
	@ 010,050 get  cCliente        SIZE  40,15	When .F.
	@ 020,010 say "Cond. Pagto"
	@ 020,050 get  UA1->UA1_CONDPA SIZE  40,15	When .F.
	@ 030,010 say "Fornecedor 1"
	@ 030,050 get  UA1->UA1_FORNE1 SIZE 110,15	When .F.
	@ 030,160 get  UA1->UA1_TFORN1 SIZE  50,15	When .F.
	@ 040,010 say "Fornecedor 2"
	@ 040,050 get  UA1->UA1_FORNE2 SIZE 110,15	When .F.
	@ 040,160 get  UA1->UA1_TFORN2 SIZE  50,15	When .F.
	@ 050,010 say "Fornecedor 3"
	@ 050,050 get  UA1->UA1_FORNE3 SIZE 110,15	When .F.
	@ 050,160 get  UA1->UA1_TFORN3 SIZE  50,15	When .F.
	@ 060,010 say "Observa็ใo"
	@ 060,050 get  cObsMem         SIZE 160,30  MEMO	When .F.
	@ 100,010 say "Observa็ใo Gerente Financeiro."
	@ 110,050 get cGetMotivo valid Iif(nopcao == 2,!empty(cGetMotivo), .T.) SIZE 160,30 MEMO
	@ 150,010 BUTTON "&Pos. Cliente"   SIZE 40,15 ACTION (FINC010())
	@ 150,060 BUTTON "&Corrige"        SIZE 30,15 ACTION (nOpcao := 3,oDlg:End())
	@ 150,100 BUTTON "&Rejeita"        SIZE 30,15 ACTION (nOpcao := 2,oDlg:End())
	@ 150,140 BUTTON "&Libera "        SIZE 30,15 ACTION (nOpcao := 1,oDlg:End())
	@ 150,180 BUTTON "&Cancela"        SIZE 30,15 ACTION (nOpcao := 0,oDlg:End())
	
	Activate Dialog oDlg Centered  //on init EnchoiceBar(oDlg,bOk,bCancel)
	
	
	
	
	If nOpcao == 1
		If MsgBox("Confirma a Libera็ใo do edital "+UA1->UA1_CODIGO+"?","Atencao","YESNO")
			
			cObsDir := cObsDir+" "+cGetMotivo
			UA1->(Reclock("UA1",.f.))
			UA1->UA1_FINANC := cAvaliador
			UA1->UA1_STATUS := '2'
			
			If Empty(cObsDir)
				MSMM(UA1->UA1_OBSMDI,60,,cObsDir,2,,,"UA1","UA1_OBSMDI")
				UA1->UA1_OBSMDI := ''
			Else
				If Empty(UA1->UA1_OBSMDI)
					MSMM(UA1->UA1_OBSMDI,60,,cObsDir,1,,,"UA1","UA1_OBSMDI")
				Else
					MSMM(UA1->UA1_OBSMDI,60,,cObsDir,4,,,"UA1","UA1_OBSMDI")
				EndIf
			EndIf
			
			UA1->(MsUnlock("UA1"))
			UA1->(DbCommit())
			
			// Gravando informa็ใo da libera็ใo do Edital no Cadastro do Cliente  MCVN - 27/11/2020
			SA1->(dbSetOrder(1))
			SA1->(dbSeek(xFilial("SA1") + UA1->UA1_CODCLI + UA1->UA1_LOJA))
			SA1->(Reclock("SA1",.f.))
			
			mObsFin := Trim(MSMM(SA1->A1_OBSFINM,60,,,3))
			
			If !empty(mObsFin)
				mObsFin := CR + mObsFin
			EndIf
			
			mObsFin := " Em "+dToc(dDatabase)+" o edital nro "+Alltrim(UA1->UA1_CODIGO)+" foi liberado pelo Financeiro. " + mObsFin
			
			SA1->(RecLock("SA1",.F.))
			
			If empty(SA1->A1_OBSFINM)
				MSMM(,60,,mObsFin ,1,,,"SA1","A1_OBSFINM")
			Else
				MSMM(SA1->A1_OBSFINM,60,,mObsFin,4,,,"SA1","A1_OBSFINM")
			EndIf
			
			SA1->(MsUnLock("SA1"))
			SA1->(DbCommit())
			//Fim da Grava็ใo no cadastro do cliente

			ConOut("Licita็ใo - Edital [" +UA1->UA1_CODIGO+ "] Cr้dito Liberado por "+ cAvaliador)
			cMensagem := "Licita็ใo - Edital [" + UA1->UA1_CODIGO + "] Cr้dito Liberado por " + cAvaliador
			If cEmpAnt<>"01"
				u_Dipal10Mail(cMensagem, {UA1->UA1_USUDIG},"Licita็ใo - Completar Edital "+UA1->UA1_CODIGO+".")
			EndIf
			MsgAlert("Edital "+UA1->UA1_CODIGO+" liberado com sucesso!","Atencao!")
		Endif
	ElseIF nOpcao == 2
		If MsgBox("Confirma a Rejei็ใo Financeira do edital "+UA1->UA1_CODIGO+"?","Atencao","YESNO")
			
			cObsDir := cObsDir+" "+cGetMotivo
			UA1->(Reclock("UA1",.f.))
			UA1->UA1_WFLOW = '2'
			UA1->UA1_STATUS := '9'
			UA1->UA1_WFID := ""
			
			
			If Empty(cObsDir)
				MSMM(UA1->UA1_OBSMDI,60,,cObsDir,2,,,"UA1","UA1_OBSMDI")
				UA1->UA1_OBSMDI := ''
			Else
				If Empty(UA1->UA1_OBSMDI)
					MSMM(UA1->UA1_OBSMDI,60,,cObsDir,1,,,"UA1","UA1_OBSMDI")
				Else
					MSMM(UA1->UA1_OBSMDI,60,,cObsDir,4,,,"UA1","UA1_OBSMDI")
				EndIf
			EndIf
			
			UA1->(MsUnlock("UA1"))
			UA1->(DbCommit())
			UA1->(DbCommit())
			
			
			// Gravando informa็ใo de rejei็ใo no Cadastro do Cliente  MCVN - 13/07/2007
			SA1->(dbSetOrder(1))
			SA1->(dbSeek(xFilial("SA1") + UA1->UA1_CODCLI + UA1->UA1_LOJA))
			SA1->(Reclock("SA1",.f.))
			
			mObsFin := Trim(MSMM(SA1->A1_OBSFINM,60,,,3))
			
			If !empty(mObsFin)
				mObsFin := CR + mObsFin
			EndIf
			
			mObsFin := " Em "+dToc(dDatabase)+" o edital nro "+Alltrim(UA1->UA1_CODIGO)+" foi rejeitado. Motivo: "+AllTrim(cGetMotivo)+". " + mObsFin
			
			SA1->(RecLock("SA1",.F.))
			
			If empty(SA1->A1_OBSFINM)
				MSMM(,60,,mObsFin ,1,,,"SA1","A1_OBSFINM")
			Else
				MSMM(SA1->A1_OBSFINM,60,,mObsFin,4,,,"SA1","A1_OBSFINM")
			EndIf
			
			SA1->(MsUnLock("SA1"))
			SA1->(DbCommit())
			
			
			ConOut("Licita็ใo - Edital [" +UA1->UA1_CODIGO+ "] Cr้dito Rejeitado por " + cAvaliador)
			u_EnviaEmail(cGetMotivo)
			cMensagem := "Licita็ใo - Edital [" +UA1->UA1_CODIGO+ "] Cr้dito Rejeitado por " + cAvaliador
			ConOut("Licita็ใo - Enviado e-mail para o Eric, Patricia e Vendedor . . .  ")
			u_Dipal10Mail(cMensagem, {UA1->UA1_USUDIG}, "Licita็ใo - Edital "+UA1->UA1_CODIGO+": Credito Rejeitado.")
			MsgAlert("Edital "+UA1->UA1_CODIGO+" rejeitado!","Atencao!")
		Endif
	ElseIF nOpcao == 3
		If MsgBox("Confirma a corre็ใo do edital "+UA1->UA1_CODIGO+"?","Atencao","YESNO")
			
			cObsDir := cObsDir+" "+cGetMotivo
			UA1->(Reclock("UA1",.f.))
			UA1->UA1_STATUS := '2'
			UA1->UA1_RISCO  := ''
			UA1->UA1_DTRISC := CTOD("  /  /  ")
			UA1->UA1_HRRISC := ''
			UA1->UA1_WFID   := ''
			
			If Empty(cObsDir)
				MSMM(UA1->UA1_OBSMDI,60,,cObsDir,2,,,"UA1","UA1_OBSMDI")
				UA1->UA1_OBSMDI := ''
			Else
				If Empty(UA1->UA1_OBSMDI)
					MSMM(UA1->UA1_OBSMDI,60,,cObsDir,1,,,"UA1","UA1_OBSMDI")
				Else
					MSMM(UA1->UA1_OBSMDI,60,,cObsDir,4,,,"UA1","UA1_OBSMDI")
				EndIf
			EndIf
			
			UA1->(MsUnlock("UA1"))
			UA1->(DbCommit())
			
			ConOut("Licita็ใo - Edital [" +UA1->UA1_CODIGO+ "] O financeiro necessita de mais informa็๕es para avalia็ใo de cr้dito "+ cAvaliador)
			cMensagem := "Licita็ใo - Edital [" + UA1->UA1_CODIGO + "] O financeiro necessita de mais informa็๕es para avalia็ใo de cr้dito " + cAvaliador
			u_Dipal10Mail(cMensagem, {UA1->UA1_USUDIG},"Licita็ใo - O Financeiro necessita de mais informa็๕es "+UA1->UA1_CODIGO+".")
			MsgAlert("Edital "+UA1->UA1_CODIGO+" Solicita็ใo efetuada com sucesso!","Atencao!")
			
		Endif
		
	Endif
	
	
ElseIf UA1->UA1_WFLOW = "3" .And. UA1->UA1_STATUS = "3" .And. Empty(UA1->UA1_VENDAS)
	
	//Chama rotina de avalia็ใo do comercial
	U_DIPLIBAV()
	
Else
	MsgAlert("Edital "+UA1->UA1_CODIGO+" nใo necessita de libera็ใo!","Atencao!")
Endif

Return(.F.)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDIPLIBAV   บAutor  ณMaximo    บ Data ณ  10/10/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณVisualiza o registro selecionado no MBrowse                 บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function DIPLIBAV()

Local aArea 	:= GetArea()
Local oDlg
Local cCadastro := "Avaliar Edital"
Local aCpoEnch	:= {}
Local aNoEnch	:= {"UA1_FILIAL","UA1_STATUS"}
Local aPos	  	:= {015,000,110,395}
Local aButtons 	:= {}
Local nOpcA		:= 0
Local oChk
Local lMark		:= .F.
Local lRetorno	:= .F.
Local cAlias    := "UA1"
Local nReg      := 1
Local nOpcx     := 1
Local nPrCusto  := 0
Local nSB1PrcMin:= 0
Local nSB1PrcPro:= 0
Local nSB1Descri:= 0
Local nIPI      := 0
Local cAvaliador := AllTrim(Upper(U_DipUsr()))
Local cGetMotivo  := Space(90)
Local nOpcao      := 0
Local lSaida      := .F.
Local cObsMem     := MSMM(UA1->UA1_OBSMDI,,,,3)
Private lChk	:= .F.
Private aVetor	:= {}
Private oLbx
Private lInverte := .F.

AAdd(aButtons, {"EXCLUIR"  , {|| nOpca := 2,oDlg:End() },"Rejeita Edital..." } )
AAdd(aButtons, {"DBG09"    , {|| nOpca := 3,oDlg:End() },"Corrige Edital..." } )


RegToMemory(cAlias,.F.)
RegToMemory("UA4",.F.)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณMontagem dos campos da Enchoice 		   ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
AADD(aCpoEnch,"NOUSER")
SX3->(dbSetOrder(1))
SX3->(dbSeek("UA1"))
Do While ( !SX3->( Eof() ) .And. SX3->X3_ARQUIVO == "UA1" )
	If ( X3USO(SX3->X3_USADO) .And. cNivel >= SX3->X3_NIVEL .And.;
		ASCAN(aNoEnch,SX3->X3_CAMPO) < 1)
		AADD(aCpoEnch,SX3->X3_CAMPO)
	EndIf
	SX3->(dbSkip())
EndDo


dbSelectArea("UA4")
dbSetOrder(1)
UA4->(dbSeek(xFilial("UA4") + M->UA1_CODIGO))

Do While !Eof() .And. UA4->UA4_FILIAL == xFilial("UA4")
	
	// Buscando informa็๕es no cadastro do produto(SB1)
	nIpi       := Posicione("SB1",1,xFilial("SB1") + UA4->UA4_PRODUT,"B1_IPI")
	//nPrCusto   := Posicione("SB1",1,xFilial("SB1") + UA4->UA4_PRODUT,"B1_UPRC")
	//nPrCusto   := Posicione("SB1",1,xFilial("SB1") + UA4->UA4_PRODUT,"B1_CUSDIP") //MCVN - 30/10/2008
	//nPrCusto   := Posicione("SB1",1,xFilial("SB1") + UA4->UA4_PRODUT,"B1_LISFOR") //MCVN - 26/03/2009
	nPrCusto   := Posicione("SB1",1,xFilial("SB1") + UA4->UA4_PRODUT,"B1_CUSDIP") //MCVN - 02/04/2009
	nPrCusto   := nPrCusto + (nPrCusto*nIpi/100)
	nSB1PrcMin := Posicione("SB1",1,xFilial("SB1") + UA4->UA4_PRODUT,"B1_PRVMINI")
	nSB1PrcPro := Posicione("SB1",1,xFilial("SB1") + UA4->UA4_PRODUT,"B1_PRVSUPE")
	nSB1Descri := Alltrim(Posicione("SB1",1,xFilial("SB1")+UA4->UA4_PRODUT,"B1_DESC"))
	
	If UA4->UA4_EDITAL == M->UA1_CODIGO
		aAdd(aVetor,{Alltrim(UA4->UA4_PRODUTO),Alltrim(nSB1Descri),UA4->UA4_QUANT,UA4->UA4_PRCVEN,;
		UA4->UA4_PRCMIN,Iif(nSB1PrcPro > 0 .and. nSB1PrcPro < nSB1PrcMin,nSB1PrcPro,;
		nSB1PrcMin),nPrCusto})
	EndIf
	dbSkip()
	
EndDo


Define msDialog odlg title ccadastro from 010,010 to 600,800 pixel

//Cria Enchoice
EnChoice( cAlias ,nReg, 3, , , , aCpoEnch, aPos, {}, 3 )

//Cria a listbox com os produtos do edital
@ 110,000 listbox oLbx fields header "Codigo", "Descri็ใo", "Qtd.", "V. Unit", "V. Min.","V. Min Sis.","P. Custo";
size 395,150 of oDlg pixel

oLbx:SetArray( aVetor )
//Iif(	aVetor[oLbx:nAt,1],oOk,oNo),;
oLbx:bLine := {|| {aVetor[oLbx:nAt,1],;
aVetor[oLbx:nAt,2],;
aVetor[oLbx:nAt,3],;
aVetor[oLbx:nAt,4],;
aVetor[oLbx:nAt,5],;
aVetor[oLbx:nAt,6],;
aVetor[oLbx:nAt,7]}}

Activate msDialog oDlg centered on init ;
EnchoiceBar(oDlg, {|| nOpca := 1,oDlg:End()},{|| nOpca := 0,oDlg:End()},,aButtons)


Begin Transaction

If nOpcA == 1
	
	
	
	If MsgBox("Confirma a Libera็ใo Comercial do edital "+UA1->UA1_CODIGO+" ?","Atencao","YESNO")
		
		cGetMotivo := Space(90)
		Do While !lSaida
			nOpcao := 0
			
			Define msDialog oDlg Title "Observa็ใo do Edital "+UA1->UA1_CODIGO From 10,10 TO 17,53
			
			@ 001,002 tO 40,170
			@ 010,010 say "Observa็ใo - (opcional): "  COLOR CLR_HBLUE
			@ 020,010 get cGetMotivo size 154,08
			
			DEFINE SBUTTON FROM 41,108 TYPE 1 ACTION (lSaida:=.T.,nOpcao:=1,oDlg:End()) ENABLE OF oDlg
			
			Activate dialog oDlg centered
			
		EndDo
		
		cMensagem := ""
		UA1->(Reclock("UA1",.f.))
		UA1->UA1_VENDAS := cAvaliador
		UA1->UA1_WFLOW  := '4'
		UA1->UA1_STATUS := '4'
		
		If !Empty(cGetMotivo)
			If Len(cObsMem)>0
				cObsMem := MSMM(UA1->UA1_OBSMEM,,,,3) + CR +cGetMotivo
			Else
				cObsMem := cGetMotivo
			Endif
			If Empty(cObsMem)
				MSMM(UA1->UA1_OBSMDI,60,,cObsMem,2,,,"UA1","UA1_OBSMDI")
				UA1->UA1_OBSMDI := ''
			Else
				If Empty(UA1->UA1_OBSMDI)
					MSMM(UA1->UA1_OBSMDI,60,,cObsMem,1,,,"UA1","UA1_OBSMDI")
				Else
					MSMM(UA1->UA1_OBSMDI,60,,cObsMem,4,,,"UA1","UA1_OBSMDI")
				EndIf
			EndIf
		Endif
		
		UA1->(MsUnlock("UA1"))
		UA1->(DbCommit())
		
		ConOut("Licita็ใo - Edital [" +UA1->UA1_CODIGO+ "] foi autorizado por " + AllTrim(cAvaliador))
		cMensagem := "Licita็ใo - Edital [" +UA1->UA1_CODIGO+ "] foi autorizado por " + AllTrim(cAvaliador)
		u_Dipal10Mail(cMensagem, {UA1->UA1_USUDIG},"Licita็ใo - Edital [" +UA1->UA1_CODIGO+ "] foi autorizado...")//UA1->UA1_USUCIC)
		
		// Cartas do edital
		cQuery	:= "SELECT UA2_CARTA, UA6_DESCRI, UA2_VIAS "
		cQuery	+= "  FROM "+ RETSQLNAME("UA2") + " UA2 ,"+ RETSQLNAME("UA6") + " UA6"
		cQuery	+= "  WHERE UA2.D_E_L_E_T_ <> '*'"
		cQuery	+= "  AND UA2.UA2_EDITAL = '"+ UA1->UA1_CODIGO +"'"
		cQuery	+= "  AND UA2.UA2_CARTA  = UA6.UA6_CODIGO"
		//	cQuery := ChangeQuery(cQuery)
		dbUseArea(.T.,"TOPCONN", TCGENQRY(,,cQuery),"TMPCARTA", .F., .T.)
		
		TMPCARTA->(dbgotop())
		cMensagem := "Licita็ใo - Edital [" +UA1->UA1_CODIGO+ "] Separar Cartas e documentos a seguir: "+chr(13)+chr(10)+chr(13)+chr(10)
		
		Do While TMPCARTA->(!EOF())
			cMensagem += "Carta "+TMPCARTA->UA2_CARTA
			cMensagem += "  "+TMPCARTA->UA6_DESCRI
			cMensagem += "  Vias "+StrZero(TMPCARTA->UA2_VIAS,2)
			cMensagem += Chr(13) + Chr(10)
			TMPCARTA->(dbSkip())
		EndDo
		
		// Documentos do edital
		cQuery	:= "SELECT UA3_DOCTO, UA7_DESCRI, UA3_VIAS, UA3_XEROX, UA3_ASSINA, UA3_AUTENT "
		cQuery	+= "  FROM "+ RETSQLNAME("UA3") + " UA3, " + RETSQLNAME("UA7") + " UA7 "
		cQuery	+= "  WHERE UA3.D_E_L_E_T_ <> '*'"
		cQuery	+= "  AND UA3.UA3_EDITAL = '"+ UA1->UA1_CODIGO +"'"
		cQuery	+= "  AND UA3.UA3_DOCTO  = UA7.UA7_CODIGO"
		
		dbUseArea(.T.,"TOPCONN", TCGENQRY(,,cQuery),"TMPDOC", .F., .T.)
		
		TMPDOC->(dbgotop())
		
		Do While TMPDOC->(!EOF())
			cMensagem += "Doc " + TMPDOC->UA3_DOCTO
			cMensagem += "  "   + TMPDOC->UA7_DESCRI
			cMensagem += "  Vias "+ StrZero(TMPDOC->UA3_VIAS,2)
			cMensagem += "  Copia ["+If(TMPDOC->UA3_XEROX       =="1","Sim","Nใo")+"] "
			cMensagem += "  Autenticar ["+If(TMPDOC->UA3_AUTENT =="1","Sim","Nใo")+"] "
			cMensagem += "  Assinatura ["+If(TMPDOC->UA3_ASSINA =="1","Sim","Nใo")+"] "
			cMensagem += Chr(13) + Chr(10)
			
			TMPDOC->(dbSkip())
		EndDo
		u_Dipal10Mail(cMensagem, U_Dip40Usuario('MV_SEPARA'),"Licita็ใo - Separar Cartas e Documentos para Edital "+UA1->UA1_CODIGO )
		
		// Liberando Query
		TMPDOC->( dbCloseArea() )
		TMPCARTA->( dbCloseArea() )
		
		MsgAlert("Edital "+UA1->UA1_CODIGO+" liberado com sucesso!","Atencao!")
		
	Else
		MsgAlert("Edital "+UA1->UA1_CODIGO+" nใo foi liberado!","Atencao!")
	Endif
	
ElseIf nOpcA == 2
	
	If MsgBox("Confirma a Rejei็ใo do edital "+UA1->UA1_CODIGO+" ?","Atencao","YESNO")
		cGetMotivo := Space(90)
		Do While !lSaida
			nOpcao := 0
			
			Define msDialog oDlg Title "Rejeitando Edital "+UA1->UA1_CODIGO From 10,10 TO 17,53
			
			@ 001,002 tO 40,170
			@ 010,010 say "Descreva o motivo da rejei็ใo: "  COLOR CLR_HBLUE
			@ 020,010 get cGetMotivo valid !empty(cGetMotivo) size 154,08
			
			DEFINE SBUTTON FROM 41,108 TYPE 1 ACTION IF(!empty(cGetMotivo) .and. Len(Alltrim(cGetMotivo))>20,(lSaida:=.T.,nOpcao:=1,oDlg:End()),msgInfo("Motivo da rejei็ใo nใo preenchido ou preenchido com informa็ใo insuficiente","Aten็ใo")) ENABLE OF oDlg
			
			Activate dialog oDlg centered
			
		EndDo
		cMensagem := ""
		If Len(cObsMem)>0
			cObsMem := MSMM(UA1->UA1_OBSMEM,,,,3) +CR+cGetMotivo
		Else
			cObsMem := cGetMotivo
		Endif
		UA1->(Reclock("UA1",.f.))
		UA1->UA1_WFLOW = '4'
		UA1->UA1_STATUS := '9'
		UA1->UA1_WFID := ""
		
		If Empty(cObsMem)
			MSMM(UA1->UA1_OBSMDI,60,,cObsMem,2,,,"UA1","UA1_OBSMDI")
			UA1->UA1_OBSMDI := ''
		Else
			If Empty(UA1->UA1_OBSMDI)
				MSMM(UA1->UA1_OBSMDI,60,,cObsMem,1,,,"UA1","UA1_OBSMDI")
			Else
				MSMM(UA1->UA1_OBSMDI,60,,cObsMem,4,,,"UA1","UA1_OBSMDI")
			EndIf
		EndIf
		
		UA1->(MsUnlock("UA1"))
		UA1->(DbCommit())
		
		ConOut("Licita็ใo - Edital [" +UA1->UA1_CODIGO+ "] foi rejeitado por " + Alltrim(cAvaliador))
		cMensagem := "Licita็ใo - Edital [" +UA1->UA1_CODIGO+ "] foi rejeitado por " + Alltrim(cAvaliador)
		u_Dipal10Mail(cMensagem, {UA1->UA1_USUDIG},"Licita็ใo - Edital [" +UA1->UA1_CODIGO+ "] foi rejeitado ... ")
		
		
		MsgAlert("Edital "+UA1->UA1_CODIGO+" rejeitado!","Atencao!")
		
	Else
		MsgAlert("Edital "+UA1->UA1_CODIGO+" nใo foi rejeitado!","Atencao!")
	Endif
	
ElseIf nOpcA == 3
	
	If MsgBox("Confirma a Corre็ใo do edital "+UA1->UA1_CODIGO+" ?","Atencao","YESNO")
		cGetMotivo := Space(90)
		Do While !lSaida
			nOpcao := 0
			
			Define msDialog oDlg Title "Corre็ใo do Edital "+UA1->UA1_CODIGO From 10,10 TO 17,53
			
			@ 001,002 tO 40,170
			@ 010,010 say "Descreva o que deve ser corrigido: "  COLOR CLR_HBLUE
			@ 020,010 get cGetMotivo valid !empty(cGetMotivo) size 154,08
			
			DEFINE SBUTTON FROM 41,108 TYPE 1 ACTION IF(!empty(cGetMotivo) .and. Len(Alltrim(cGetMotivo))>20,(lSaida:=.T.,nOpcao:=1,oDlg:End()),msgInfo("Descreva com mais detalhes o que deve ser corrigido.","Aten็ใo")) ENABLE OF oDlg
			
			Activate dialog oDlg centered
			
		EndDo
		cMensagem := ""
		If Len(cObsMem)>0
			cObsMem := MSMM(UA1->UA1_OBSMEM,,,,3)+CR+cGetMotivo
		Else
			cObsMem := cGetMotivo
		Endif
		UA1->(Reclock("UA1",.f.))
		UA1->UA1_WFLOW = '2'
		UA1->UA1_STATUS := '2'
		UA1->UA1_VENDAS := ""
		UA1->UA1_WFID := ""
		
		If Empty(cObsMem)
			MSMM(UA1->UA1_OBSMDI,60,,cObsMem,2,,,"UA1","UA1_OBSMDI")
			UA1->UA1_OBSMDI := ''
		Else
			If Empty(UA1->UA1_OBSMDI)
				MSMM(UA1->UA1_OBSMDI,60,,cObsMem,1,,,"UA1","UA1_OBSMDI")
			Else
				MSMM(UA1->UA1_OBSMDI,60,,cObsMem,4,,,"UA1","UA1_OBSMDI")
			EndIf
		EndIf
		
		UA1->(MsUnlock("UA1"))
		UA1->(DbCommit())
		
		ConOut("Licita็ใo - Edital [" +UA1->UA1_CODIGO+ "] necessita de corre็ใo " + Alltrim(cAvaliador))
		cMensagem := "Licita็ใo - Edital [" +UA1->UA1_CODIGO+ "] necessita de corre็ใo " + Alltrim(cAvaliador)
		u_Dipal10Mail(cMensagem, {UA1->UA1_USUDIG},"Licita็ใo - Edital [" +UA1->UA1_CODIGO+ "] necessita de corre็ใo ... ")//UA1->UA1_USUCIC)
		
		
		MsgAlert("Solicita็ใo de corre็ใo do Edital "+UA1->UA1_CODIGO+" enviada com sucesso!","Atencao!")
		
	Else
		MsgAlert("Edital "+UA1->UA1_CODIGO+" nใo foi solicitada a corre็ใo do edital!","Atencao!")
	Endif
	
EndIf

End Transaction

If __lSX8
	ConfirmSX8()
EndIf


RestArea(aArea)

Return(.T.)

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

/*
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDIP10COMER  บAutor ณMaximo Canuto V N.    ณ 02/06/07  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ  Cancela libera็ใo do comercial                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
*/

User Function DIP10COMER()
Local cGetMotivo  := Space(90)
Local nOpcao      := 0
Local lSaida      := .F.
Local cObsMem     := MSMM(UA1->UA1_OBSMEM,,,,3)
Local cUser       := GetMV("MV_LICILIB")

//If !AllTrim(Upper(U_DipUsr())) $ 'ERIBERTO/MAXIMO/SILVIA/Luciane/Helena Souza/William Soares/Tiago Dantas/Tatiane'
If !AllTrim(Upper(U_DipUsr())) $ AllTrim(Upper(cUser))
	MSGSTOP("Usuario sem autoriza็ใo!")
	Return(.T.)
EndIf

IF UA1->UA1_STATUS <> "4"
	MsgAlert("Edital "+UA1->UA1_CODIGO+" nใo foi avaliado pelo comercial ou jแ foi informado o resultado.","Atencao!")
	RETURN(.T.)
ENDIF


Do While !lSaida
	nOpcao := 0
	
	Define msDialog oDlg Title "Cancelando Libera็ใo Comercial do edital!  "+UA1->UA1_CODIGO From 10,10 TO 17,53
	
	@ 001,002 tO 40,170
	@ 010,010 say "Descreva o motivo do cancelamento: "  COLOR CLR_HBLUE
	@ 020,010 get cGetMotivo valid !empty(cGetMotivo) size 154,08
	
	DEFINE SBUTTON FROM 41,108 TYPE 1 ACTION IF(!empty(cGetMotivo) .and. Len(Alltrim(cGetMotivo))>20,(lSaida:=.T.,nOpcao:=1,oDlg:End()),msgInfo("Motivo do encerramento nใo preenchido ou preenchido com informa็ใo insuficiente","Aten็ใo")) ENABLE OF oDlg
	DEFINE SBUTTON FROM 41,143 TYPE 2 ACTION (lSaida:=.T.,nOpcao:=0,oDlg:End()) ENABLE OF oDlg
	
	Activate dialog oDlg centered
	
EndDo

If nOpcao == 1
	
	cObsMem += CR + Upper(AllTrim(cGetMotivo) + CR +"Libera็ใo comercial cancelada "+U_DipUsr()+" dia "+Dtoc(DDataBase)+".")
	
	UA1->(Reclock("UA1",.f.))
	UA1->UA1_STATUS := '2'
	UA1->UA1_WFLOW  := '2'
	UA1->UA1_VENDAS := ''
	If Empty(cObsMem)
		MSMM(UA1->UA1_OBSMEM,60,,cObsMem,2,,,"UA1","UA1_OBSMEM")
		UA1->UA1_OBSMEM := ''
	Else
		If Empty(UA1->UA1_OBSMEM)
			MSMM(UA1->UA1_OBSMEM,60,,cObsMem,1,,,"UA1","UA1_OBSMEM")
		Else
			MSMM(UA1->UA1_OBSMEM,60,,cObsMem,4,,,"UA1","UA1_OBSMEM")
		EndIf
	EndIf
	UA1->(MsUnlock("UA1"))
	MsgAlert("Edital "+UA1->UA1_CODIGO+" teve sua liberacao comercial cancelada com SUCESSO!","Atencao!")
Endif

Return(.F.)

*--------------------------------------------------------------------------*
Static Function Dipal10NEW()
// MCVN 06/07/2007 - AVALIAวรO DE EDITAL
// MCVN 19/02/2009 - Desabilitado
*--------------------------------------------------------------------------*
Local lRetorno := .T.
Local cMail
Local cServidor   := GetMV("MV_CIC")     // Servidor para enviar mensagem pelo CIC
Local cOpFatRem   := GetMV("MV_REMETCI") // Usuario do CIC remetente de mensgens no Protheus
Local cOpFatSenha := "123456"
Local cOpFatDest  := ""
Local nOpcao      := 0
Local lSaida      := .f.

// Monta a mensagem a ser enviado ao operador
//cOpFatDest  := "ROSEMEIRE.FERRARIS,JOSENI.SILVA,PATRICIA.MENDONCA"
cOpFatDest  := "GIOVANI.ZAGO"
cMail := "NOVO EDITAL: " +UA1->UA1_CODIGO +"  -  "+	"Concorrencia: " +UA1->UA1_NRCONC +CR+CR
cMail += "Data encerramento: " +DTOC(UA1->UA1_DENCER) +" - "+ UA1_HENCER +CR+CR
cMail += "Cliente: "+AllTrim(UA1->UA1_CODCLI)+" - "+AllTrim(M->UA1_NOME)+CR
cMail += CR+U_DipUsr()

// Envia a mensagem ao operador atrav้s do CIC
//		WaitRun(cServidor+' '+cOpFatRem+' '+cOpFatSenha+' "'+AllTrim(cOpFatDest)+'" "'+cMail+'" ')

Return(lRetorno)

*--------------------------------------------------------------------------*
Static Function Dipal10Enc(cGetMotivo)
// MCVN 10/09/2008 - ENCERAMENTO DO EDITAL
// MCVN 06/02/2009 - Desabilitado
*--------------------------------------------------------------------------*
Local lRetorno := .T.
Local cMail
Local cServidor   := GetMV("MV_CIC")     // Servidor para enviar mensagem pelo CIC
Local cOpFatRem   := GetMV("MV_REMETCI") // Usuario do CIC remetente de mensgens no Protheus
Local cOpFatSenha := "123456"
Local cOpFatDest  := ""
Local nOpcao      := 0
Local lSaida      := .f.

// Monta a mensagem a ser enviado ao operador
cOpFatDest  := "GIOVANI.ZAGO"
cMail := "EDITAL: " +UA1->UA1_CODIGO+" encerrado por  "+U_DipUsr()+CR+CR
cMail += "Motivo: " +Upper(AllTrim(cGetMotivo))+CR+CR
cMail += "Cliente: "+AllTrim(UA1->UA1_CODCLI)+" - "+AllTrim(M->UA1_NOME)+CR


// Envia a mensagem ao operador atrav้s do CIC
//	WaitRun(cServidor+' '+cOpFatRem+' '+cOpFatSenha+' "'+AllTrim(cOpFatDest)+'" "'+cMail+'" ')

//Return(lRetorno)// nao retorna pra ninguem
Return

*--------------------------------------------------------------------------*
Static Function VisuCampo(cChave)
*--------------------------------------------------------------------------*
local _liot := .f.

If _lAlret
	_liot := .t.
Else
	If cChave ="1"
		_liot := .f.
	Else
		If M->UA1_XPRORR = "S"
			_liot := .t. 
			else
				_liot := .f. 
		EndIf
	EndIf
EndIf


Return (_liot)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ DIP10GRADE   บAutor  ณGiovani Zago     บ Data ณ  29/12/11  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ  Programa de gera็ใo da grade de concorrencia do edital    บฑฑ
ฑฑบ          ณ  					                                      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP7                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
*---------------------------------------------------*
User Function DIP10GRADE ()
*---------------------------------------------------*
Private oPrint
Private oFonAri07,oFonAri07b,oFonAri11b,oFonAri11s,oFonAri09  , oFonAri12, oFonAri08 ,  oFonAri08b  ,oFonAri13s,  oFonAri09b ,  oFonAri10b  ,  oFonAri12b,oFonAri14 ,  oFonAri14b,  oFonAri16 ,  oFonAri16b,  oFonAri18 ,  oFonAri18b
Private cCliLici    := Upper(Posicione("SA1",1,xFilial("SA1")+M->UA1_CODCLI+M->UA1_LOJA,"A1_NOME"))
Private cTipLici    := M->UA1_TIPO
Private cConcoLici  := M->UA1_NRCONC
Private aSeleIten   :={}
Private j
Private l
Private nContIt     := 100
Private h
Private nlin        :=0
Private nConIten    :=0
Private nPge        :=1

DEFINE FONT oFonAri07  NAME "Arial" SIZE 0, 7 OF oPrint
DEFINE FONT oFonAri07b NAME "Arial" SIZE 0, 7 OF oPrint BOLD
DEFINE FONT oFonAri08b NAME "Arial" SIZE 0, 8 OF oPrint BOLD
DEFINE FONT oFonAri08  NAME "Arial" SIZE 0, 8 OF oPrint
DEFINE FONT oFonAri09  NAME "Arial" SIZE 0, 9 OF oPrint
DEFINE FONT oFonAri09b NAME "Arial" SIZE 0, 9 OF oPrint BOLD
DEFINE FONT oFonAri10b NAME "Arial" SIZE 0,10 OF oPrint BOLD
DEFINE FONT oFonAri11  NAME "Arial" SIZE 0,11 OF oPrint
DEFINE FONT oFonAri12  NAME "Arial" SIZE 0,11 OF oPrint
DEFINE FONT oFonAri11s NAME "Arial" SIZE 0,11 OF oPrint BOLD UNDERLINE   
DEFINE FONT oFonAri13s NAME "Arial" SIZE 0,11 OF oPrint BOLD UNDERLINE
DEFINE FONT oFonAri12b NAME "Arial" SIZE 0,12 OF oPrint BOLD
DEFINE FONT oFonAri14  NAME "Arial" SIZE 0,14 OF oPrint
DEFINE FONT oFonAri14s NAME "Arial" SIZE 0,14 OF oPrint  UNDERLINE
DEFINE FONT oFonAri16  NAME "Arial" SIZE 0,16 OF oPrint
DEFINE FONT oFonAri14b NAME "Arial" SIZE 0,14 OF oPrint BOLD
DEFINE FONT oFonAri16b NAME "Arial" SIZE 0,16 OF oPrint BOLD
DEFINE FONT oFonAri18  NAME "Arial" SIZE 0,18 OF oPrint
DEFINE FONT oFonAri18b NAME "Arial" SIZE 0,18 OF oPrint BOLD

IF UA4->( !dbSeek(xFilial("UA4") + M->UA1_CODIGO))
	msginfo("Edital sem nenhum produto cadastrado!")
	Return (.T.)
EndIF

Do Case
	Case cTipLici ="1"
		cTipLici :="PREGรO PRESENCIAL"
	Case cTipLici ="2"
		cTipLici :="PREGรO ELETRิNICO"
	Case cTipLici ="3"
		cTipLici :="TOMADA DE PREวOS"
	Case cTipLici ="4"
		cTipLici :="CONVITE"
	Case cTipLici ="5"
		cTipLici :="REGISTRO DE PREวOS"
	Case cTipLici ="6"
		cTipLici :="BEC"
EndCase

Processa({|| aSeleIten:=DIP10SELECGRADE()}, "Selecionando Itens. Aguarde.....")

For l := 1 To Len(aSeleIten)
	If aSeleIten[l][1] = .T.
		nConIten+=1
	EndIf
Next l
IF nConIten = 0
	msginfo("Nenhum Item Selecionado !")
	Return (.T.)
Else
	nConIten := 0
EndIf
oPrint := TMSPrinter():New("Grade")
oPrint:SetPortrait()
oPrint:Setup()
nlin:=CabecGrad(nPge)//chama cabe็alho

For j := 1 To Len(aSeleIten)
	If aSeleIten[j][1] = .T.
		If nConIten = 5//QTD POR PAGINA
			nlin:= 0
			nConIten:= 0
			nPge+=1
			RodaGrad(oPrint)
			oPrint:EndPage()
			nlin:=CabecGrad(nPge)
		EndIf
		
		// DESCRIวรO DO ITEM
		oPrint:Box(0401+nlin, 0000, 0402+nlin, 2300)
		oPrint:Box(0400+nlin, 0000, 0480+nlin, 2300)
		oPrint:Box(0400+nlin, 0000, 0480+nlin, 0300)
		oPrint:Box(0400+nlin, 0000, 0480+nlin, 1900)
		oPrint:Say( 0420+nlin, 0010, aSeleIten[j][2], oFonAri14b)
		oPrint:Say( 0420+nlin, 0320, alltrim(aSeleIten[j][3])+" - "+SubStr(alltrim(posicione("SB1",1,xFilial("SB1")+aSeleIten[j][3],"B1_DESC")),1,52), oFonAri12b )
		oPrint:Say( 0420+nlin, 1950, cvaltochar(aSeleIten[j][5])+" - "+alltrim(aSeleIten[j][8]), oFonAri14b )
		nlin +=080
		oPrint:Box(0400+nlin, 0300, 0480+nlin, 0700)
		oPrint:Box(0400+nlin, 0700, 0480+nlin, 1100)
		oPrint:Box(0400+nlin, 1100, 0480+nlin, 1500)
		oPrint:Box(0400+nlin, 1500, 0480+nlin, 1900)
		oPrint:Box(0400+nlin, 1900, 0480+nlin, 2300)
		oPrint:Say( 0420+nlin, 0320, "DIPROMED", oFonAri12 )
		oPrint:Say( 0420+nlin, 0720, "EMPRESA 1", oFonAri12 )
		oPrint:Say( 0420+nlin, 1120, "EMPRESA 2", oFonAri12 )
		oPrint:Say( 0420+nlin, 1520, "EMPRESA 3", oFonAri12 )
		oPrint:Say( 0420+nlin, 1920, "EMPRESA 4", oFonAri12 )
		nlin +=080
		oPrint:Box(0400+nlin, 0300, 0480+nlin, 0700)
		oPrint:Box(0400+nlin, 0700, 0480+nlin, 1100)
		oPrint:Box(0400+nlin, 1100, 0480+nlin, 1500)
		oPrint:Box(0400+nlin, 1500, 0480+nlin, 1900)
		oPrint:Box(0400+nlin, 1900, 0480+nlin, 2300)
		nlin +=080
		oPrint:Box(0400+nlin, 0300, 0480+nlin, 0700)
		oPrint:Box(0400+nlin, 0700, 0480+nlin, 1100)
		oPrint:Box(0400+nlin, 1100, 0480+nlin, 1500)
		oPrint:Box(0400+nlin, 1500, 0480+nlin, 1900)
		oPrint:Box(0400+nlin, 1900, 0480+nlin, 2300)
		oPrint:Say( 0420+nlin, 0320, "PI: "+alltrim(cValToChar(TransForm(aSeleIten[j][6]  ,"@E 9,999,999.9999"))), oFonAri12 )
		oPrint:Say( 0420+nlin, 0720, "PI:", oFonAri12 )
		oPrint:Say( 0420+nlin, 1120, "PI:", oFonAri12 )
		oPrint:Say( 0420+nlin, 1520, "PI:", oFonAri12 )
		oPrint:Say( 0420+nlin, 1920, "PI:", oFonAri12 )
		nlin +=080
			oPrint:Box(0400+nlin, 0300, 0480+nlin, 0700)
		oPrint:Box(0400+nlin, 0700, 0480+nlin, 1100)
		oPrint:Box(0400+nlin, 1100, 0480+nlin, 1500)
		oPrint:Box(0400+nlin, 1500, 0480+nlin, 1900)
		oPrint:Box(0400+nlin, 1900, 0480+nlin, 2300)
		oPrint:Say( 0420+nlin, 0320, "PF:", oFonAri12 )
		oPrint:Say( 0420+nlin, 0720, "PF:", oFonAri12 )
		oPrint:Say( 0420+nlin, 1120, "PF:", oFonAri12 )
		oPrint:Say( 0420+nlin, 1520, "PF:", oFonAri12 )
		oPrint:Say( 0420+nlin, 1920, "PF:", oFonAri12 )
		nlin +=080
		oPrint:Box(0400+nlin, 0300, 0480+nlin, 0700)
		oPrint:Box(0400+nlin, 0700, 0480+nlin, 1100)
		oPrint:Box(0400+nlin, 1100, 0480+nlin, 1500)
		oPrint:Box(0400+nlin, 1500, 0480+nlin, 1900)
		oPrint:Box(0400+nlin, 1900, 0480+nlin, 2300)
		oPrint:Say( 0420+nlin, 0320, "M:", oFonAri12 )
		oPrint:Say( 0420+nlin, 0720, "M:", oFonAri12 )
		oPrint:Say( 0420+nlin, 1120, "M:", oFonAri12 )
		oPrint:Say( 0420+nlin, 1520, "M:", oFonAri12 )
		oPrint:Say( 0420+nlin, 1920, "M:", oFonAri12 )
		nlin +=080
		//EMPRESA VENCEDORA
		oPrint:Box(0400+nlin, 0300, 0480+nlin, 2300)
		oPrint:Say( 0420+nlin, 0320, "EMPRESA VENCEDORA:_______________________", oFonAri12b )
		nlin +=0080 // controla espa็amento entre os itens
		
		
		nConIten+=1
	EndIf
Next j
RodaGrad(oPrint)
oPrint:EndPage()
//oPrint:Print()
oPrint:Preview()
Return(.T.)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  RodaGrad บAutor ณGiovani Zago          บ Data ณ 02/01/2012  บฑฑ
ฑฑฬออออออออออุอออออออออออสออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Rodape            						                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ      Dipromed                                              บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
*---------------------------------------------------*
Static Function RodaGrad(oPrint)
*---------------------------------------------------*

oPrint:Say( 3350, 0100, "ษ     OBRIGATำRIO     A     DEVOLUวรO     DESTA     GRADE     APำS     O     TษRMINO     DO     PREGรO.", oFonAri12b )

Return(oPrint)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  CabecGrad บAutor ณGiovani Zago          บ Data ณ 02/01/2012  บฑฑ
ฑฑฬออออออออออุอออออออออออสออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Cabe็alho        						                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ      Dipromed                                              บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
*---------------------------------------------------*
Static Function CabecGrad(nPge,nlan)
*---------------------------------------------------*

Default nlan :=0

oPrint:StartPage()

// BOX EXTERNO
oPrint:Box(0010, 0000, 3400, 2300)


// CABEวALHO
oPrint:Say( 0015, 0030, "GRADE DE CONCORRENCIA", oFonAri14 )
oPrint:Say( 0065, 0030, cCliLici, oFonAri14 )
oPrint:Say( 0115, 0030, cTipLici+" - "+cConcoLici, oFonAri14 )
oPrint:Say( 0165, 0030, "REPRESENTANTE:_____________________"  , oFonAri14 )
oPrint:Say( 0165, 0550, POSICIONE("SA3", 1, XFILIAL("SA3")+M->UA1_VEND, "A3_NREDUZ") , oFonAri14b )
oPrint:Say( 0215, 0030, "DATA:  "+Dtoc(M->UA1_DENCER)+"  HORA:   "+M->UA1_HENCER+" Hs" , oFonAri14 )
// LOGOTIPO
oPrint:SayBitmap( 0015,1550,"\system\Dipromedcon.bmp",690,430 )
//PAGINA
oPrint:Say( 0005, 2100, "Pag. 0"+cvaltochar(nPge), oFonAri12 )
//LEGENDA
If nPge = 1
	oPrint:Say( 0350, 0030, "*PI = Pre็o Inicial; *PF = Pre็o Final; *M = Marca" , oFonAri12 )
EndIf
// CABEวALHO DO ITEM
oPrint:Box(0400, 0000, 0480, 2300)
oPrint:Box(0400, 0000, 0480, 0300)
oPrint:Box(0400, 0000, 0480, 1900)
oPrint:Say( 0420, 0004, "LOTE / ITEM", oFonAri14s )
oPrint:Say( 0420, 0700, "DESCRIวรO DO PRODUTO", oFonAri14s )
oPrint:Say( 0420, 1920, "QUANTIDADE", oFonAri14s )

nlan :=080+nlan

Return(nlan)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  DIP10SELECGRADE บAutor ณGiovani Zago    บ Data ณ 02/01/2012  บฑฑ
ฑฑฬออออออออออุอออออออออออสออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Sele็ใo dos itens 						                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณFAT - Dipromed                                              บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

*---------------------------------------------------*
Static Function DIP10SELECGRADE()
*---------------------------------------------------*

Local aArea 	:= GetArea()
Local oDlg
Local cCadastro := "ITENS DA GRADE"
Local aCpoEnch	:= {}
Local aNoEnch	:= {"UA1_FILIAL","UA1_STATUS"}
Local aPos	  	:= {015,000,110,300}
Local aButtons 	:= {}
Local nOpcA		:= 0
Local oOk		:= LoadBitmap( GetResources(), "LBOK" )
Local oNo		:= LoadBitmap( GetResources(), "LBNO" )
Local oChk
Local lMark		:= .F.
Local lRetorno	:= .F.
Private lChk	:= .F.
Private aVetor	:= {}
Private oLbx
Private lInverte := .F.
Private i
Private cIteLot	:= ""

dbSelectArea("UA4")
UA4->(dbSetOrder(1))
UA4->(dbSeek(xFilial("UA4") + M->UA1_CODIGO))
	

Do While !Eof() .And. UA4->UA4_FILIAL == xFilial("UA4")
	If UA4->UA4_EDITAL == M->UA1_CODIGO
		lMark := .T.
		cIteLot	:=Iif(!Empty(UA4->UA4_LOTE),ALLTRIM(UA4->UA4_LOTE)+"."+ALLTRIM(UA4->UA4_ITEMLT),UA4->UA4_ITEMAM)
		aAdd(aVetor,{lMark,cIteLot , UA4->UA4_PRODUTO, alltrim(posicione("SB1",1,xFilial("SB1")+UA4->UA4_PRODUTO,"B1_DESC")), UA4->UA4_QUANT, UA4->UA4_PRCVEN, UA4->UA4_PRCMIN,UA4->UA4_UM})
	EndIf
	dbSkip()
EndDo

Define msDialog odlg title ccadastro from 178,181 to 790,982 pixel

//Cria a listbox com os produtos do edital
@ 010,000 listbox oLbx fields header " ", "Lote/Item", "Codigo", "Descricao", "Quantidade", "Vlr. Unitario", "Vlr. Minimo";
size 400,400 of oDlg pixel on DBLCLICK (fMarca(oLbx))

oLbx:SetArray( aVetor )
oLbx:bLine := {|| {Iif(	aVetor[oLbx:nAt,1],oOk,oNo),;
aVetor[oLbx:nAt,2],;
aVetor[oLbx:nAt,3],;
aVetor[oLbx:nAt,4],;
aVetor[oLbx:nAt,5],;
aVetor[oLbx:nAt,6],;
aVetor[oLbx:nAt,7]}}

@ 300,005 CHECKBOX oChk VAR lChk PROMPT "Marca/Desmarca" SIZE 60,007 PIXEL OF oDlg ;
ON CLICK(aEval(aVetor,{|x| x[1]:=lChk}),oLbx:Refresh())

Activate msDialog oDlg centered on init ;
EnchoiceBar(oDlg, {|| nOpca := 1,oDlg:End()},{|| nOpca := 0,oDlg:End()},,aButtons)

RestArea(aArea)

Return(aVetor)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณfMarca(X,Y)บAutor ณGiovani Zago         บ Data ณ 02/01/2012  บฑฑ
ฑฑฬออออออออออุอออออออออออสออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Usada para fazer a inversao das marcacoes.                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณFAT - Dipromed                                              บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
*---------------------------------------------------*
Static Function fMarca()
*---------------------------------------------------*
aVetor[oLbx:nAT,1] := !aVetor[oLbx:nAT,1]
oLbx:Refresh()
Return( Nil )
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบPrograma  ณCalcInd   บAutor  ณ   Microsiga   บ Data ณ  04/12/13  	  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.   ณ Calcula margem atual e minima do item e do pedido.           บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑ                            ATUALIZAวีES                                บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบMaximo  ณ 30/10/08 ณ Alterado calculo da margem                        บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/                               
User Function CalcInd(lOk)   
Local _nCustoPed  := 0
Local _nVendaPed  := 0
Local _nCustoMin  := 0
Local _nMargLib   := 0
Local _nMargemMin := 0
Local _nMargAtuPed:= 0
Local _nTotItens  := 0
Local _cMA        := 0
Local _cML        := 0
Local _aPreco     := {}
Local _xAlias     := GetArea()
Local _areaSB1 	  := SB1->(getarea())
Local _nPosProdut := 0
Local _nPosMrgAtu := 0
Local _nPosMrgIte := 0
Local _nPosCusto  := 0
Local _nPosQuant  := 0
Local _nPosPrVend := 0
Local _nPosPrcMin := 0
Local _nPosTES    := 0
Local _nValor     := 0
Local _nFor        
Local _nFatorRecolh := 1    
Local _nPrcMin		:= 0 
Private _cCliEspecial := GetMV("MV_CLIESPE") // Cliente especial
DEFAULT lOk 	  := .F.

If lOk
	aCols 	:= oGetDados[_UA4]:aCols
	aHeader := oGetDados[_UA4]:aHeader	
EndIf

_nPosProdut := aScan(aHeader, { |x| Alltrim(x[2]) == "UA4_PRODUT" })
_nPosMrgAtu := aScan(aHeader, { |x| Alltrim(x[2]) == "UA4_MARGAT" })
_nPosMrgIte := aScan(aHeader, { |x| Alltrim(x[2]) == "UA4_MARGIT" })
_nPosCusto  := aScan(aHeader, { |x| Alltrim(x[2]) == "UA4_CUSTO"  })
_nPosQuant  := aScan(aHeader, { |x| Alltrim(x[2]) == "UA4_QUANT"  })
_nPosPrVend := aScan(aHeader, { |x| Alltrim(x[2]) == "UA4_PRCMIN" })
_nPosPrcMin := aScan(aHeader, { |x| Alltrim(x[2]) == "UA4_PRCMIN" })
_nPosTES    := aScan(aHeader, { |x| Alltrim(x[2]) == "UA4_TES"    })

For _nFor := 1 to Len(aCols)
	IF !aCols[_nFor,Len(aHeader)+1]
		IF !Empty(aCols[_nFor,_nPosProdut])
				
			SB1->(DbSetOrder(1))
			If SB1->(DbSeek(xFilial("SB1")+aCols[_nFor,_nPosProdut]))
		
				If SB1->B1_PROC$GetNewPar("ES_LISFOR","000041/000609/000334/000338/000183/100000/000630/000996/000997")
					_nMargemMin := Round( ((IIF(SB1->B1_PRVSUPE>0,SB1->B1_PRVSUPE,SB1->B1_PRVMINI) / (SB1->B1_LISFOR)) - 1) * 100 ,2)
				Else
					_nMargemMin := Round( ((IIF(SB1->B1_PRVSUPE>0,SB1->B1_PRVSUPE,SB1->B1_PRVMINI) / (SB1->B1_CUSDIP)) - 1) * 100 ,2)
				Endif
				
				//ณ Avalia a tabela para definir a margem minima do produto.   ณ
				IF                            _nMargemMin <= 21
					_nMargemMin := 19.96
				ElseIf _nMargemMin > 21 .and. _nMargemMin <= 22
					_nMargemMin := 20.76
				ElseIf _nMargemMin > 22 .and. _nMargemMin <= 23
					_nMargemMin := 21.76
				ElseIf _nMargemMin > 23 .and. _nMargemMin <= 24
					_nMargemMin := 22.76
				ElseIf _nMargemMin > 24 .and. _nMargemMin <= 25
					_nMargemMin := 23.76
				ElseIf _nMargemMin > 25 .and. _nMargemMin <= 26
					_nMargemMin := 24.76
				ElseIf _nMargemMin > 26 .and. _nMargemMin <= 27
					_nMargemMin := 25.68
				ElseIf _nMargemMin > 27 .and. _nMargemMin <= 28
					_nMargemMin := 26.68
				ElseIf _nMargemMin > 28 .and. _nMargemMin <= 29
					_nMargemMin := 27.68
				ElseIf _nMargemMin > 29 .and. _nMargemMin <= 30
					_nMargemMin := 28.68
				ElseIf _nMargemMin > 30 .and. _nMargemMin <= 32
					_nMargemMin := 29.68
				ElseIf _nMargemMin > 32 .and. _nMargemMin <= 34
					_nMargemMin := 31.62
				ElseIf _nMargemMin > 34 .and. _nMargemMin <= 36
					_nMargemMin := 33.62
				ElseIf _nMargemMin > 36 .and. _nMargemMin <= 38
					_nMargemMin := 35.62
				ElseIf _nMargemMin > 38 .and. _nMargemMin <= 40
					_nMargemMin := 37.54
				ElseIf _nMargemMin > 40 .and. _nMargemMin <= 42
					_nMargemMin := 39.54
				ElseIf _nMargemMin > 42 .and. _nMargemMin <= 44
					_nMargemMin := 41.44
				ElseIf _nMargemMin > 44 .and. _nMargemMin <= 46
					_nMargemMin := 43.40
				ElseIf _nMargemMin > 46 .and. _nMargemMin <= 48
					_nMargemMin := 45.38
				ElseIf _nMargemMin > 48 .and. _nMargemMin <= 50
					_nMargemMin := 47.36
				ElseIf _nMargemMin > 50 .and. _nMargemMin <= 53
					_nMargemMin := 49.40
				ElseIf _nMargemMin > 53 .and. _nMargemMin <= 56
					_nMargemMin := 52.40
				ElseIf _nMargemMin > 56 .and. _nMargemMin <= 59
					_nMargemMin := 55.40
				ElseIf _nMargemMin > 59 .and. _nMargemMin <= 61
					_nMargemMin := 58.30
				ElseIf _nMargemMin > 61 .and. _nMargemMin <= 65
					_nMargemMin := 60.30
				ElseIf _nMargemMin > 65 .and. _nMargemMin <= 69
					_nMargemMin := 64.30
				ElseIf _nMargemMin > 69 .and. _nMargemMin <= 75
					_nMargemMin := 68.20
				ElseIf _nMargemMin > 75 .and. _nMargemMin <= 80
					_nMargemMin := 74.20
				ElseIf _nMargemMin > 80 .and. _nMargemMin <= 88
					_nMargemMin := 79.00
				ElseIf _nMargemMin > 88
					_nMargemMin := 86.00
				EndIf
				
				If SB1->B1_PROC$GetNewPar("ES_LISFOR","000041/000609/000334/000338/000183/100000/000630/000996/000997")
					aCols[_nFor,_nPosMrgAtu] := Round( (( (aCols[_nFor,_nPosPrVend]/_nFatorRecolh) / (SB1->B1_LISFOR)) - 1) * 100 ,2) /20
					aCols[_nFor,_nPosMrgIte] := _nMargemMin /20
					aCols[_nFor,_nPosCusto]  := (SB1->B1_LISFOR)
					_nPrcMin := (SB1->B1_LISFOR) + ((((SB1->B1_LISFOR)) *_nMargemMin ) / 100)
				Else
					aCols[_nFor,_nPosMrgAtu] := Round( (( (aCols[_nFor,_nPosPrVend]/_nFatorRecolh) / (SB1->B1_CUSDIP)) - 1) * 100 ,2) /20
					aCols[_nFor,_nPosMrgIte] := _nMargemMin /20
					aCols[_nFor,_nPosCusto]  := (SB1->B1_CUSDIP)
					_nPrcMin := (SB1->B1_CUSDIP) + ((((SB1->B1_CUSDIP)) *_nMargemMin ) / 100)
				Endif
				
				_nCustoPed := _nCustoPed + ( aCols[_nFor,_nPosQuant] * aCols[_nFor,_nPosCusto])
				_nCustoMin := _nCustoMin + ( aCols[_nFor,_nPosQuant] * _nPrcMin )
				_nVendaPed := _nVendaPed + ( aCols[_nFor,_nPosQuant] * (aCols[_nFor,_nPosPrVend]/_nFatorRecolh))

			EndIf
		EndIF
	EndIF                   
Next _nFor	

M->UA1_MARGATU := ((_nVendaPed / _nCustoPed) -1 ) * 100 /20
M->UA1_MARGLIB := ((_nCustoMin / _nCustoPed) -1 ) * 100 /20
      
If Type("oEnchUA1") <> "U"
	oEnchUA1:Refresh(.T.)
EndIf

RestArea(_areaSB1)
RestArea(_xAlias)

Return(.T.)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDIPAL10   บAutor  ณMicrosiga           บ Data ณ  02/20/14   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function DipVldTran(cCodCli,cLoja)
Local lRet 		:= .F.
Local aAreaSA1 	:= SA1->(GetArea())

SA1->(dbSetOrder(1))                
If SA1->(dbSeek(xFilial("SA1")+cCodCli+cLoja))
	lRet := FindCepSzv(SA1->A1_CEPE)
EndIf

RestArea(aAreaSA1)
Return lRet   
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDIPAL10   บAutor  ณMicrosiga           บ Data ณ  02/20/14   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FindCepSzv(nCepCli)
Local aArea	  := GetArea()
Local cSQL    := ""
Local lRet	  := .F.
Local nI 	  := 0 
Local aTransp := {}
DEFAULT nCepCli := ""

cSQL := " SELECT A4_COD "
cSQL += " FROM "+ RetSqlName("SA4") + " A4 "
cSQL += " WHERE A4_FILIAL     = '"+xFilial("SA4")+"'"
cSQL += "   AND A4_USARCEP    = '2'"
cSQL += "   AND A4.D_E_L_E_T_ = ' '"     
    
cSQL:= ChangeQuery(cSQL)	
dbUseArea(.T.,"TOPCONN",TCGenQry(,,cSQL),"SA4TRB",.F.,.T.)

//-- Percorre a Query e adiciona o resultado no array de Retorno
SA4TRB->( DbEval( {|| aAdd(aTransp,A4_COD)  }))
SA4TRB->( DbCloseArea() )

aTransp := aSort(aTransp,,,{|x,y| x < y })

For nI := 1 To Len( aTransp )
	cSQL := "SELECT ZV_TRANSP, ZV_VIAGEM "
	cSQL += " FROM " + RetSQLName("SZV")
	cSQL += " WHERE ZV_CEPINI <= '" + nCepCli + "'"
	cSQL += "   AND ZV_CEPFIM >= '" + nCepCli + "'"
	cSQL += "   AND ZV_FILIAL  = '" + xFilial("SZV") + "'"
	cSQL += "   AND ZV_TRANSP  = '" + aTransp[nI] + "'"
	cSQL += "   AND " + RetSQLName("SZV") + ".D_E_L_E_T_ = ' ' "   
	
	cSQL:= ChangeQuery(cSQL)	
	dbUseArea(.T.,"TOPCONN",TCGenQry(,,cSQL),"TRBSZV",.F.,.T.)
	
	While !TRBSZV->(Eof())
		If TRBSZV->ZV_TRANSP == '100000'  
			lRet := .T.
			Exit
		EndIf
		TRBSZV->(dbSkip())
	EndDo
	TRBSZV->(DbCloseArea())
Next nI

RestArea(aArea)

Return(lRet)

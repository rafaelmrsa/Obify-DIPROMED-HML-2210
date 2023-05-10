#INCLUDE "rwmake.ch"     
#INCLUDE "PROTHEUS.CH"
#DEFINE CR    chr(13)+chr(10) // Carreage Return (Fim de Linha)   

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Programa   ³ DIPAL91   ³ Autor ³ Maximo Canuto V. Neto ³ Data ³ 08/08/07  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡…o  ³ Cadastro de SiaFisico                                        ³±±
±±³            ³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Parametros ³                                                              ³±±
±±³            ³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Obs        ³                                                              ³±±
±±³            ³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Retorno    ³                                                              ³±±
±±³            ³                                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function DIPAL91()  

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Declaracao de Variaveis                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/ 
Private cCadastro := "Tabela SiaFisico"
Private aRotina   := {	{"Pesquisar" , "AxPesqui"    , 0, 1},;
						{"Visualizar", "AxVisual"    , 0, 2},;
				    	{"Incluir"   , "U_SiaInclui" , 0, 3},;
						{"Alterar"   , "U_SiaAltera" , 0, 4},;
						{"Excluir"   , "U_SiaExclui" , 0, 5}}

Private cDelFunc := ".T."	// Validacao para a exclusao. Pode-se utilizar ExecBlock
Private cAlias   := "UAA"
U_DIPPROC(ProcName(0),U_DipUsr()) 


UAA->(dbSetOrder(1))

mBrowse(6, 1, 22, 80, cAlias, , , , , 2)

Return(.F.) 

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Programa   ³ SiaInclui  ³ Autor ³ Maximo Canuto V. Neto  ³Data ³ 08/08/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡…o  ³ Inclui o registro na tabela SIAFISICO                        ³±±
±±³            ³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Parametros ³                                                              ³±±
±±³            ³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Obs        ³                                                              ³±±
±±³            ³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Retorno    ³                                                              ³±±
±±³            ³                                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/        
User Function SiaInclui() 

Local cUser          := GetMV("MV_LICIPRO")     
Private cSiaFisico := ""
Private cCodCtl    := ""
Private lConfInclusao     := .F.

If !AllTrim(Upper(U_DipUsr())) $ AllTrim(Upper(cUser))
	MSGSTOP("Usuario sem autorização!")
	Return
EndIf      

Begin Transaction
	nOpca := AxInclui("UAA",1,3,,,,"u_GravaMemo(M->UAA_DESCRI,3,M->UAA_CODCTL,.T.)")  
 	   
    // Gravando informação do campo memo no SYP
    If lConfInclusao  
	    UAA->(DbSetOrder(1))
    	UAA->(DbSeek(xFilial("UAA")+cCodCtl))
		UAA->(Reclock("UAA",.F.))
		If Empty(cSiaFisico)
			MSMM(UAA->UAA_CODDES,60,,cSiaFisico,2,,,"UAA","UAA_CODDES")
			UAA->UAA_CODDES := ''					
		Else
			If Empty(UAA->UAA_CODDES)
				MSMM(UAA->UAA_CODDES,60,,cSiaFisico,1,,,"UAA","UAA_CODDES")
			Else
				MSMM(UAA->UAA_CODDES,60,,cSiaFisico,4,,,"UAA","UAA_CODDES")
			EndIf
		EndIf			
		UAA->(MsUnLock("UAA"))  
  	Endif

End Transaction                      


Return
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Programa   ³ SiaAltera  ³ Autor ³ Maximo Canuto V. N  ³ Data ³ 08/08/07   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡…o  ³ Altera registro na tabela SIAFISICO.                         ³±±
±±³            ³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Parametros ³                                                              ³±±
±±³            ³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Obs        ³                                                              ³±±
±±³            ³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Retorno    ³                                                              ³±±
±±³            ³                                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function SiaAltera(cAlias, nReg, nOpc)
Local aArea    := GetArea()
Local aAreaUAA := UAA->(GetArea())
Local cUser          := GetMV("MV_LICIPRO") 
Private cAltSiaFisico := ""
Private lConfAltera   := .F.

If !AllTrim(Upper(U_DipUsr())) $ AllTrim(Upper(cUser))
	MSGSTOP("Usuario sem autorização!")
	Return
EndIf 

Begin Transaction
	nOpca := 0
	nOpca := AxAltera(cAlias, nReg, nOpc, , , , , "u_GravaMemo(M->UAA_DESCRI, nOpc,'',.T.)")
	
    
    // Posicionando registro e gravando informação do campo memo no SYP
	
	If lConfAltera
		UAA->(Reclock("UAA",.F.))
		If Empty(cAltSiaFisico)
			MSMM(UAA->UAA_CODDES,60,,cAltSiaFisico,2,,,"UAA","UAA_CODDES")
			UAA->UAA_CODDES := ''					
		Else
			If Empty(UAA->UAA_CODDES)
				MSMM(UAA->UAA_CODDES,60,,cAltSiaFisico,1,,,"UAA","UAA_CODDES")
			Else
				MSMM(UAA->UAA_CODDES,60,,cAltSiaFisico,4,,,"UAA","UAA_CODDES")
			EndIf
		EndIf			
		UAA->(MsUnLock("UAA"))  
    EndIf    
    
End Transaction

RestArea(aAreaUAA)
RestArea(aArea)

Return       
         
/////////////////////////////////////////////////////////////////////////////////////////////////

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Programa   ³ SiaExclui ³ Autor ³ Maximo Canuto V. N  ³ Data ³ 11/09/07    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡…o  ³ Exclui registro na tabela SIAFISICO.                         ³±±
±±³            ³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Parametros ³                                                              ³±±
±±³            ³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Obs        ³                                                              ³±±
±±³            ³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Retorno    ³                                                              ³±±
±±³            ³                                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function SiaExclui(cAlias, nReg, nOpc)

If MsgBox("Confirma Exclusão do código SIAFISICO.             Produto  "+ UAA->UAA_PRODUTO +" - Código  "+UAA->UAA_SIAFIS +"? ","Atencao","YESNO")  

	Begin Transaction
	RecLock("UAA",.F.)
	dbDelete()
	End Transaction
	
	If __lSX8
		ConfirmSX8()
	EndIf
	
	UAA->( MSUnlock() )  
	
EndIf

Return(.T.)

///////////////////////////////////////////////////////////////////////////
// Prepara variáveis para tratamento do campo memo
User Function GravaMemo(mSiaFisico,nOpc,CodControle,lConfirma)

If  nOpc = 3
	cSiaFisico    := mSiaFisico
	cCodCtl       := CodControle
	lConfInclusao := lConfirma
Else                        
	cAltSiaFisico := mSiaFisico
	lConfAltera   := lConfirma
Endif

Return(.T.) 
///////////////////////////////////////////////////////////////////////////

/*====================================================================================\
|Programa  | VIEWSIAFISICO | Autor | Maximo Canuto Vieira Neto  | Data | 09/08/07     |
|=====================================================================================|
|Descrição | Mostra SIA FISICO                                                        |
|=====================================================================================|
|Uso       | Especifico DIPROMED                                                      |
\====================================================================================*/

User Function ViewSiaFisico()
Local lRetorno := .F.   
Local aArea    := GetArea() 
Local aAreaSB1 := SB1->(GetArea())  
Local aAreaUAA := UAA->(GetArea())  
Private cCondicao := 'UAA->UAA_FILIAL == xFilial("UAA") .AND. UAA_PRODUT == "'+Alltrim(SB1->B1_COD)+'"'
Private bFiltraBrw := {|| Nil}
Private aIndUAA   := {}          

If lProm                
	SB1->(dbSetOrder(1))
	If !SB1->(dbSeek(xFilial("SB1")+TRBSB1->B1_COD))
		Return(.T.)
	EndIf
EndIf                  

cCondicao := 'UAA->UAA_FILIAL == xFilial("UAA") .AND. UAA_PRODUT == "'+Alltrim(SB1->B1_COD)+'"'

UAA->(DbClearFilter())
bFiltraBrw := {|| FilBrowse("UAA",@aIndUAA,@cCondicao) }
Eval(bFiltraBrw)
UAA->(DbGoTop())

U_DIPAL91()  
//AxCadastro("UAA","TABELA SIAFISICO.")


RestArea(aAreaUAA) 
RestArea(aAreaSB1)
RestArea(aArea)

Return(.F.)
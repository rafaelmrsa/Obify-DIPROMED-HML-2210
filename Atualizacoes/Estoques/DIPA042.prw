/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DIPA042() ºAutor  ³Jailton B Santos-JBSº Data ³ 22/01/2010  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Programa desenvolvido para permitir ao usaurio apontar ob- º±±
±±º          ³ servacoes referente as lotes de produtos.                  º±±
±±º          ³                                                            º±±
±±º          ³ Sao duas observacoes:                                      º±±
±±º          ³                                                            º±±
±±º          ³ 1 - OBS Fornecedor: Informacao referente ao fornecedor     º±±
±±º          ³                                                            º±±
±±º          ³ 2 - OBS Tecnica do Lote: Informacao referente ao lote do   º±±
±±º          ³                          do Produto.                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Especifico Estoque - Dipromed                              º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"       
                              
User Function DIPA042()

Local cAlias    := "SB8"   
Local aIndex    := {}

Private aRotina   := {}
Private cCadastro := "APONTAMENTOS TECNICOS DE LOTES/PRODUTOS" 
Private cMv_DIP_RT:= SuperGetMv("MV_DIP_RT")

DbSelectArea(cAlias)

aAdd(aRotina,{"Pesquisar"    ,"AxPesqui"     ,0,1} )
aAdd(aRotina,{"Visualizar"   ,"AxVisual"     ,0,2} )
aAdd(aRotina,{"Alterar"      ,"U_DIPA042MAN" ,0,4} )

DbSelectArea(cAlias)
DbSetOrder(1) 

cFiltra    := "B8_FILIAL = '" + xFilial("SB8") + "' And (B8_SALDO - B8_QACLASS) > 0 "
mBrowse(06,01,22,75,cAlias,,,,,,,,,,,,,,cFiltra)

Return   
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DIPA042MANº Autor ³Jailton B Santos-JBSº Data ³ 28/01/2010  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Rotina para a fazer a edicao dos campos de observacao      º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Especificos - Estoques - Dipromed                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function DIPA042MAN(cAlias,nReg,nOpc)

Local oDlg      
Local nOpca  := 0
Local lRet   := .T.
Local bOk    := {|| fGrava(),oDlg:End()}
Local bCancel:= {|| oDlg:End()}
//-----------------------------------------------------------------------------------------
Private oUm 
Private oDesc   
Private oLote     
Private oForn
Private oLocal 
Private oProduto  
Private oObsForne 
Private oObsTecni
Private oForn
Private	oDtVld
//---------------------------------------------------------------------------------
Private cLote     := SB8->B8_LOTECTL
Private	cDtVld    := SB8->B8_DTVALID
Private cLocal    := SB8->B8_LOCAL
Private cProduto  := SB8->B8_PRODUTO
Private cObsForne := SB8->B8_OBSTROC
Private cObsTecni := SB8->B8_OBSTEC
//---------------------------------------------------------------------------------
SB1->( DbSetOrder(1) )
SB1->( DbSeek( xFilial('SB1')+SB8->B8_PRODUTO) )	
//---------------------------------------------------------------------------------
Private cUM       := SB1->B1_UM
Private cDesc     := SB1->B1_DESC
//---------------------------------------------------------------------------------
SA2->( DbSetOrder(1) )
SA2->( DbSeek(xFilial('SA2') + SB1->B1_PROC + SB1->B1_LOJPROC) )
//---------------------------------------------------------------------------------
cForn     := SB1->B1_PROC + '-' + SB1->B1_LOJPROC + '-' + SA2->A2_NREDUZ
//---------------------------------------------------------------------------------
Define MsDialog oDlg Title "O B S E R V A Ç Ã O   T É C N I C A" from 000,000 to 280,652 of oMainWnd pixel
//---------------------------------------------------------------------------------
@ 016,02 to 137,325 Of oDlg Pixel
//---------------------------------------------------------------------------------
@ 025,015 say "Produto" size 50,08 of oDlg pixel
@ 037,015 say "Lote"    size 50,08 of oDlg pixel
@ 049,015 say "Local"   size 50,08 of oDlg pixel
@ 070,015 say "Obs Fornecedor"  size 70,08 of oDlg pixel
@ 100,015 say "Obs Tecnica"     size 70,08 of oDlg pixel
//---------------------------------------------------------------------------------
@ 025,045 msget oProduto  var cProduto  F3 "SB1"  When .F. size 50,08 of oDlg pixel
@ 036,045 msget oLote     var cLote               When .F. size 50,08 of oDlg pixel
@ 048,045 msget oLocal    var cLocal              When .F. size 50,08 of oDlg pixel
@ 079,015 msget oObsForne var cObsForne When fWhen('01') size 300,08 of oDlg pixel
@ 109,015 msget oObsTecni var cObsTecni When fWhen('02') size 300,08 of oDlg pixel
//---------------------------------------------------------------------------------
// Informacoes Visuais
//---------------------------------------------------------------------------------
@ 025,135 say "Desc. " size 40,08 of oDlg pixel
@ 037,135 say "U.M.  " size 40,08 of oDlg pixel
@ 049,135 say "Fornec" size 40,08 of oDlg pixel
@ 062,135 say "Valid"  size 40,08 of oDlg pixel
//---------------------------------------------------------------------------------
@ 025,162 msget oDesc  var cDesc   When .F. size 150,08 of oDlg pixel
@ 036,162 msget oUM    var cUM     When .F. size 050,08 of oDlg pixel
@ 048,162 msget oForn  var cForn   When .F. size 150,08 of oDlg pixel
@ 061,162 msget oDtVld var cDtVld  When .F. size 050,08 of oDlg pixel
//---------------------------------------------------------------------------------
Activate MsDialog oDlg Centered  on init EnchoiceBar(oDlg, bOk, bCancel)

Return(lRet)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ fGrava() ºAutor  ³Jailton B Santos-JBSº Data ³ 22/01/2010  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Grava a observacao do Fornecedor e do Lote do Produto.     º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Especifico Estoque - Dipromed                              º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function fGrava()
Local lRet := .T.
//-----------------------------------------------
// Grava as Informacoes do SB8
//-----------------------------------------------
SB8->( RecLock('SB8',.F.) )
SB8->B8_OBSTROC := cObsForne
SB8->B8_OBSTEC  := cObsTecni
SB8->( MsUnLock('SB8') ) 
Return(lRet)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ fWhen()  º Autor ³Jailton B Santos-JBSº Data ³ 28/01/2010  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Pelo tipo informado, avalia e faz consistencia para permi- º±±
±±º          ³ tir a edicao dos campo de observacoes dos produtos no SB8. º±±
±±º          ³ Obs Troca: O Usuario precisa esta no cadastro de comprador.º±±
±±º          ³ Obs Tecnica: O usuario precisa esta informado no Parametro º±±
±±º          ³              MV_DIP_RT.                                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Especifico Faturamento - Dipromed                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function fWhen(cTipo)
Local lRet := .T.

do case
case cTipo == '01' // Obs de Compras

    SY1->(DbSetOrder(3))
    SY1->(DbGoTop())

    lRet := .F.
    If SY1->(DbSeek(xFilial("SY1") + __cUserId ))
	    lRet := .T.
	EndIf

case cTipo == '02' // Obs Tecnica  do Formaceutico

    lRet := .F.
	If U_DipUsr() $ cMv_DIP_RT
	    lRet := .T. 
	EndIf

EndCase
Return(lRet)
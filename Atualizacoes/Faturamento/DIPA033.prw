/*                                                              Sao Paulo,  28 Set 2006
---------------------------------------------------------------------------------------
Empresa.......: DIPOMED Comércio e Importação Ltda.
Programa......: DIPA033.PRW
Objetivo......: Permite ao usuario informar os conhecimentos de embarque que fazem parte
                de uma determinada fatura de frete.

Autor.........: Jailton B Santos, JBS
Data..........: 28 Set 2006

Versão........: 1.0
Consideraçoes.: Função chamada direto do menu ->U_DipA033()
                
------------------------------------------------------------------------------------
*/
#INCLUDE "PROTHEUS.CH"
*-------------------------------------------------*
User Function DIPA033()
*-------------------------------------------------*
Local lRetorno
Local oDlg
Local bOK:={|| DIPA033FATURA(),nOpcao := 0, oDlg:End()}
Local bCancel:={|| nOpcao := 0, oDlg:End()}
Local nOpcao:=0 

Private nValFrete:=0
Private nNotas:=0 
Private cCondicao:='SF2->F2_FILIAL == xFilial("SF2")'
Private bFiltraBrw:={|| Nil}
Private cQuery:=''
Private cPerg:="DIPA33"
Private cFileWork
Private aIndSF2:={}
Private aRotina:={}
Private aCposFat:={}
Private aEstruFat:={}
Private cMarca:=GetMark() // JBS 08/07/2005
Private oNotas            // JBS 05/01/2010
Private oValFrete         // JBS 05/01/2010
Private oMark             // JBS 05/01/2010

U_DIPPROC(ProcName(0),U_DipUsr()) // MCVN - 22/01/2009

aAdd(aRotina,{"Pesquisa"        ,"AxPesqui"        ,0,1}) // Pesquisa" 
aAdd(aRotina,{"Inf. Nro Fatura" ,"U_DIPA033FATURA" ,0,3}) // Informar Nro Fatura 
/* 
   ---------------------------------------
   Campos que serao mostrados na dialog
   para o usuario
   --------------------------------------- 
*/ 
aAdd(aCposFat,{"F2_OK2"    ,"","" })
aAdd(aCposFat,{"F2_DOC"    ,"",AvSx3("F2_DOC"    ,5)})
aAdd(aCposFat,{"F2_SERIE"  ,"",AvSx3("F2_SERIE"  ,5)})
aAdd(aCposFat,{"F2_EMISSAO","",AvSx3("F2_EMISSAO",5)})
aAdd(aCposFat,{"F2_NROCON" ,"",AvSx3("F2_NROCON" ,5)})
aAdd(aCposFat,{"F2_FRETE"  ,"",AvSx3("F2_FRETE"  ,5),AvSx3("F2_FRETE", 6)})
aAdd(aCposFat,{"F2_FRTDIP" ,"",AvSx3("F2_FRTDIP" ,5),AvSx3("F2_FRTDIP",6)})
aAdd(aCposFat,{"F2_TRANSP" ,"",AvSx3("F2_TRANSP" ,5)})
aAdd(aCposFat,{"F2_TPFRETE","",AvSx3("F2_TPFRETE",5),AvSx3("F2_TPFRETE",6)})
/*
   --------------------------------------- 
   Campos e estrutura da Work             
   ---------------------------------------
*/
aAdd(aEstruFat,{"F2_OK2"    , "C" ,avsx3("F2_OK2"   ,3),0})
aAdd(aEstruFat,{"F2_DOC"    , "C" ,avsx3("F2_DOC"   ,3),0})
aAdd(aEstruFat,{"F2_SERIE"  , "C" ,avsx3("F2_SERIE" ,3),0})
aAdd(aEstruFat,{"F2_TRANSP" , "C" ,avsx3("F2_TRANSP",3),0})
aAdd(aEstruFat,{"F2_NROCON" , "C" ,avsx3("F2_NROCON",3),0})
aAdd(aEstruFat,{"F2_TPFRETE", "C" ,avsx3("F2_TPFRETE",3),0})
aAdd(aEstruFat,{"F2_EMISSAO", "D" ,08,0})
aAdd(aEstruFat,{"F2_FRETE"  , "N" ,avsx3("F2_FRETE" ,3),avsx3("F2_FRETE" ,4)})
aAdd(aEstruFat,{"F2_FRTDIP" , "N" ,avsx3("F2_FRTDIP",3),avsx3("F2_FRTDIP",4)})
aAdd(aEstruFat,{"F2_RECNO"  , "N" ,12,0}) 

AjustaSX1(cPerg)

lInverte := .F.
/* 
   -------------------------------------
   Campos de Controle gerados e_criatrab
   -------------------------------------
*/   
aHeader:={}
aCampos:={}
cFileWork:=E_CriaTrab(,aEstruFat,"WORK",)
IndRegua("WORK",cFileWork,"F2_OK2") 
WORK->(dbSetOrder(0))

If Pergunte(cPerg,.T.)
	
	Do while .t.
		
		Processa({|| lRetorno := DIPA033GRVWORK()})
		
		If !lRetorno
		    Exit
		EndIf     
		
		If Select("TRBSF2") > 0 //MCVN  02/09/10
		    TRBSF2->(DbCloseArea())
		EndIf
		WORK->(dbGotop())
		
		Define msDialog oDlg Title "Informando número da Fatura de Frete" From 00,00 TO 30,90
		//	@ 11,02 to 61,350
		@ 201,010 say 'Notas selecionadas' size 60,10 pixel  
		@ 201,150 say 'Frete Selecionado'  size 60,10 pixel 
        @ 199,072 get oNotas    var nNotas     Picture "9999"              when .f. size 50,10 pixel
        @ 199,212 get oValFrete var nValFrete  Picture "@E 999,999,999.99" when .f. size 50,10 pixel

		oMark:=MsSelect():New("WORK","F2_OK2",,aCposFat,lInverte,@cMarca,{30,01,198,357})
		oMark:bAval               := {|| DIPA033MARK() }
		oMark:oBrowse:lhasMark    := .T.  // JBS 05/01/2009
        oMark:oBrowse:lCanAllmark := .T.  // JBS 05/01/2009   
        oMark:oBrowse:bAllMark    := { || DIPA033AllMark() } // JBS 05/01/2009
		
		Activate Dialog oDlg Centered on init EnchoiceBar(oDlg,bOk,bCancel)
		
		If nOpcao = 0
		   Exit
		EndIf           
		WORK->(__dbzap())
	EndDo
EndIf
WORK->(E_EraseArq(cFileWork))
Return                                  
*-------------------------------------------------*
Static Function DIPA033MARK()
*-------------------------------------------------*
Local lRet := .T.                                         

If WORK->F2_OK2 == cMarca
   nValFrete-= WORK->F2_FRTDIP
   nNotas--    
   WORK->F2_OK2 := '  '
Else
   nValFrete+= WORK->F2_FRTDIP
   nNotas++
   WORK->F2_OK2 := cMarca
EndIf    
oNotas:Refresh()
oValFrete:Refresh()
Return(lRet)   
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DIPA033AllMarkºAutor³Jailton B Santos-JBSºData³  01/05/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcao desenvolvida para marcar todos os Conhecimentos de   º±±
±±º          ³embarques                                                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³FAT - Dipromed                                              º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function DIPA033AllMark()

Local lRet := .T.                                         
Local nRecWRK := WORK->( Recno() )
Local NewMarc:= If(WORK->F2_OK2 == cMarca, Space(2),cMarca)
 
nValFrete := 0
nNotas    := 0

WORK->( DbGoTop() )

Do While WORK->( !EOF() )

	WORK->F2_OK2 := NewMarc

	If !Empty(NewMarc)
		nValFrete += WORK->F2_FRTDIP
		nNotas ++
    EndIf

	WORK->( DbSkip() )

EndDo
                  
WORK->( DbGoTo(nRecWRK))

oNotas:Refresh()
oValFrete:Refresh()
//oMark:Refresh()

Return(lRet)
*-------------------------------------------------*
Static Function DIPA033GRVWORK()
*-------------------------------------------------*
Local nRegua := 500
Local id
Local lRetorno := .t.

Begin Sequence

ProcRegua(nRegua)

For id:= 1 to 250
	IncProc('Gravando Work ...')'
	nRegua--
Next id

cQuery := " SELECT F2_DOC, F2_SERIE, F2_NROCON, F2_EMISSAO, F2_TRANSP, F2_FRETE, F2_FRTDIP, F2_TPFRETE, SF2.R_E_C_N_O_ as F2_RECNO"
cQuery += " FROM "+RetSqlName('SF2')+" SF2 "
//cQuery += " WHERE SF2.D_E_L_E_T_ <> '*'"
cQuery += " WHERE F2_FILIAL = '"+xFilial('SF2')+"'" //MCVN 02/09/10
cQuery += " AND F2_TRANSP = '"+MV_PAR01+"'
cQuery += " AND F2_FATFRET = ' '"
cQuery += " AND F2_TPFRETE IN ('C','I')"
cQuery += " AND F2_NROCON <> ' '"
//cQuery += " ORDER BY F2_NROCON,F2_SERIE, F2_DOC" 
cQuery += " ORDER BY CONVERT(NUMERIC(10,0),F2_NROCON),F2_SERIE, F2_DOC" 

cQuery := ChangeQuery(cQuery)
DbCommitAll()
dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'TRBSF2', .F., .T.)

TRBSF2->(dbGotop())

If TRBSF2->(BOF().and. EOF())
	Aviso( "Aviso", "Não encontrado conhecimentos para informar fatura desta transportadora", {"OK"} )
	TRBSF2->(dbCloseArea())
	lRetorno:=.f.
	break
EndIf

Do While TRBSF2->(!EOF())
	If nRegua < 1
		nRegua := 500
        ProcRegua(nRegua)
	EndIf
	IncProc('Gravando Work ...')'
	nRegua--            
	
	WORK->(dbAppend())

	WORK->F2_OK2     := '  '
	WORK->F2_DOC     := TRBSF2->F2_DOC
	WORK->F2_SERIE   := TRBSF2->F2_SERIE
	WORK->F2_NROCON  := TRBSF2->F2_NROCON
	WORK->F2_EMISSAO := cTod(SubStr(TRBSF2->F2_EMISSAO,7,2)+"/"+SubStr(TRBSF2->F2_EMISSAO,5,2)+"/"+SubStr(TRBSF2->F2_EMISSAO,1,4))
	WORK->F2_TRANSP  := TRBSF2->F2_TRANSP
	WORK->F2_FRETE   := TRBSF2->F2_FRETE
	WORK->F2_FRTDIP  := TRBSF2->F2_FRTDIP
	WORK->F2_TPFRETE := TRBSF2->F2_TPFRETE
	WORK->F2_RECNO   := TRBSF2->F2_RECNO

	TRBSF2->(dbSkip())

EndDo       

TRBSF2->(dbCloseArea())

End Sequence

Return(lRetorno := .t.)
*-------------------------------------------------*
Static Function DIPA033FATURA()
*-------------------------------------------------*
Local oDlg
Local cSaveArea:=GetArea()
Local nTotalFrete:=0
Local nQtdeNF:=0 

Private cNroFat:=Space(len(SF2->F2_FATFRET))
Private aRegSF2:={}

WORK->(DbSetOrder(1))
WORK->(DbSeek(cMarca))

If WORK->(!EOF()) //!Empty(cMarca)

	Do While WORK->(!Eof())
 
 		nQtdeNF++
		nTotalFrete += WORK->F2_FRTDIP
		aAdd(aRegSF2,WORK->F2_RECNO)

		WORK->(RecLock("WORK",.F.))
		WORK->F2_OK2 := ''
		WORK->(MsUnlock())
		WORK->(DbSeek(cMarca))
		
	EndDo 
	
    WORK->(DbSetOrder(0))

    Define msDialog oDlg title OemToAnsi("Informando Fatura de Frete") From 00,00 TO 14,50
    
    @ 10,010 say 'Quantidade de Notas Fiscais' size 80,10 pixel 
    @ 25,010 say 'Valor do frete selecionando' size 80,10 pixel 
    @ 50,010 say 'Numero da Fatura'            size 80,10 pixel 
    
    @ 10,090 get nQtdeNF     Picture "9999"              when .f. size 50,10 pixel
    @ 25,090 get nTotalFrete Picture "@E 999,999,999.99" when .f. size 50,10 pixel
    @ 50,090 get cNroFat     Picture "@!" Valid !Empty(cNroFat)   size 40,10 pixel

	Define Sbutton from 80,070 type 1 Action (Processa({|| DIPA033Grava(),'Atualizando Fatura de Frete . . .'}), oDlg:End()) enable of oDlg
	Define Sbutton from 80,100 type 2 Action (oDlg:End()) enable of oDlg
    Activate dialog oDlg Centered   
    
    nValFrete:=0
    nNotas:=0
	
Else
	MSGINFO("Você não marcou nenhuma nota!")
EndIf
RestArea(cSaveArea)
Return
*-------------------------------------------------*                                                   
Static Function DIPA033Grava()                                   
*-------------------------------------------------*
Local id
ProcRegua(Len(aRegSF2))
For id :=1 to len(aRegSF2) 
     IncProc('Gravando fatura de frete . . .')
     SF2->(dbGoto(aRegSF2[id])) 
	 SF2->(RecLock("SF2",.F.)) 
	 SF2->F2_FATFRET:=cNroFat
	 SF2->(MsUnlock('SF2'))
Next id     
Return(.t.)      



*----------------------------------------*
Static Function AjustaSX1(cPerg)
*----------------------------------------*
Local _sAlias := Alias()
Local aRegs := {}
Local i,j
dbSelectArea("SX1")
dbSetOrder(1)  

cPerg := PADR(cPerg, Len(SX1->X1_GRUPO)," " ) // Incluido por Sandro em 18/11/09.

aAdd(aRegs,{cPerg,"01","Transportadora  ?","","","mv_ch1","C",6,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","SA4"})
For i:=1 to Len(aRegs)
	If !dbSeek(cPerg+aRegs[i,2])
		RecLock("SX1",.T.)
		For j:=1 to FCount()
			If j <= Len(aRegs[i])
				FieldPut(j,aRegs[i,j])
			Endif
		Next
		MsUnlock()
	Endif
Next
DbSelectArea(_sAlias)
Return

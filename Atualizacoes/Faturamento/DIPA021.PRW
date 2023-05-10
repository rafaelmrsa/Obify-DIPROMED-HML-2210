#include "rwmake.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³ DIPA021  º Autor ³ Eriberto Elias     º Data ³ 16/04/2003  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Colaca ou tira produtos na mala direta                     º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function DIPA021()
Local _xAlias  := GetArea()

PRIVATE aRotina := { { "Pesquisa","AxPesqui"    , 0 , 1},;
                     { "Coloca","U_DIPA021c()"  , 0 , 2},;
                     { "Tira  ","U_DIPA021t()"  , 0 , 3} }

U_DIPPROC(ProcName(0),U_DipUsr()) // JBS 05/10/2005 - Gravando o nome do Programa no SZU

//³ Define o cabecalho da tela de atualizacoes               ³
cCadastro := "Aqui voce pode COLOCAR ou TIRAR produtos da lista de mala direta"
cMarca := GetMark()

_aCampos  := {}
AADD(_aCampos,{"B1_OKMALA" , "" ,""          })
AADD(_aCampos,{"B1_MALADIR", "" ,"MALA?"     })
AADD(_aCampos,{"B1_COD"    , "" ,"Codigo"    })
AADD(_aCampos,{"B1_DESC"   , "" ,"Descricao" })
AADD(_aCampos,{"B1_UM"     , "" ,"UM"        })
AADD(_aCampos,{{|| EXECBLOCK("SALDOATUAL",.F.,.F.,SB1->B1_COD)}  , "" ,"Saldo" , AvSx3("B1_SALDO",6) })
AADD(_aCampos,{"B1_PRV1"   , "" ,"Preco Lista ", AvSx3("B1_PRV1",6) })
AADD(_aCampos,{"B1_PRVSUPE", "" ,"Promocao    ", AvSx3("B1_PRVSUPE",6) })
AADD(_aCampos,{"B1_PRVMINI", "" ,"C"           , AvSx3("B1_PRVMINI",6) })
AADD(_aCampos,{"B1_PRVPROM", "" ,"D"           , AvSx3("B1_PRVPROM",6) })
AADD(_aCampos,{"B1_TIPO"   , "" ,"Tipo" })

MarkBrow("SB1","B1_OKMALA",,_aCampos,,cMarca)

RestArea(_xAlias)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³ DIPA021C º Autor ³ Eriberto Elias     º Data ³ 16/04/2003  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Coloca SIM no campo B1_MALADIR                             º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function DIPA021C()
Local _cAliasSB1 := SB1->(GetArea())

Processa({|| Coloca()},'Colocando produtos na lista de MALA DIRETA...')

RestArea(_cAliasSB1)

Return()
////////////////////////
Static Function Coloca()
IF !EMPTY(cMarca)
	
	Dbselectarea("SB1")
	//DbSetOrder(9)
	SB1->(DbOrderNickName("B1MARLADIR"))
	
	ProcRegua(SB1->(RECCOUNT()))
	
	SB1->(DbSeek(xFilial("SB1")+cMarca))
	
	While !SB1->(Eof()) .AND. xFILIAL("SB1") == SB1->B1_FILIAL .AND. cMarca == SB1->B1_OKMALA
		IncProc(AllTrim(SB1->B1_COD)+'-'+SubSTR(SB1->B1_DESC,30))
		RecLock("SB1",.F.)
		SB1->B1_MALADIR := 'S'
		SB1->(MsUnlock())
		Dbselectarea("SB1")
		SB1->(DbSkip())
	END
ELSE
	MSGINFO("Voce nao marcou nenhum produto")
ENDIF

Return()
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³ DIPA021T º Autor ³ Eriberto Elias     º Data ³ 16/04/2003  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Tira SIM no campo B1_MALADIR                             º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function DIPA021T()
Local _cAliasSB1 := SB1->(GetArea())

Processa({|| Tira()},'Tirando produtos na lista de MALA DIRETA...')

RestArea(_cAliasSB1)

Return()
//////////////////////
Static Function Tira()

cPerg := "DIPM21"

AjustaSX1(cPerg)            // Verifica perguntas. Se nao existe INCLUI.

If Pergunte(cPerg,.T.)      // Solicita parametros
	
	If mv_par01 == 1
		Dbselectarea("SB1")
		DbSetOrder(1)
		
		ProcRegua(SB1->(RECCOUNT()))
		
		SB1->(DbSeek(xFilial("SB1")))
		
		While !SB1->(Eof()) .AND. xFILIAL("SB1") == SB1->B1_FILIAL
			IncProc(AllTrim(SB1->B1_COD)+'-'+SubSTR(SB1->B1_DESC,30))
			If SB1->B1_MALADIR == 'S'
				RecLock("SB1",.F.)
				SB1->B1_MALADIR := ' '
				SB1->(MsUnlock())
			EndIf
			SB1->(DbSkip())
		END
	Else
		IF !EMPTY(cMarca)
			
			Dbselectarea("SB1")
			//DbSetOrder(9)
			SB1->(DbOrderNickName("B1MARLADIR"))
			
			ProcRegua(SB1->(RECCOUNT()))
			
			SB1->(DbSeek(xFilial("SB1")+cMarca))
			
			While !SB1->(Eof()) .AND. xFILIAL("SB1") == SB1->B1_FILIAL .AND. cMarca == SB1->B1_OKMALA
				IncProc(AllTrim(SB1->B1_COD)+'-'+SubSTR(SB1->B1_DESC,30))
				RecLock("SB1",.F.)
				SB1->B1_MALADIR := ' '
				SB1->(MsUnlock())
				SB1->(DbSkip())
			END
		ELSE
			MSGINFO("Voce nao marcou nenhum produto")
		ENDIF
	EndIf
EndIf
Return()

///////////////////////////
Static Function ajustaSX1(cPerg)
_sAlias := GetArea()

dbSelectArea("SX1")
dbSetOrder(1)

cPerg := PADR(cPerg, Len(SX1->X1_GRUPO)," " ) // Incluido por Sandro em 18/11/09.

aRegs:={}

//------------ Grupo/Ordem/Pergunta/PERGING/PERGESP/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05/F3

AADD(aRegs,{cPerg,"01","Tudo ou Marcados  ?","","","mv_ch1","N", 1,0,2,"C","","mv_par01","Tudo","","","","","Marcados","","","","","","","",""})

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

dbSelectArea(_sAlias)
Return
///////////////////////////////////////////////////////////////////////////

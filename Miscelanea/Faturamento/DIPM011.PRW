#include "rwmake.ch"
#INCLUDE "TBICONN.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Funcao    ³ DIPM011  ³ Autor ³ Eriberto Elias     ³ Data ³ 25/09/2002  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Gera arquivo listaprc.dbf para ser usado no EXCEL          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ DIPM011                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Especifico DIPROMED                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
*----------------------------*
User Function DIPM011(aWork)
*----------------------------*
//Tratamento para workflow 

// MCVN - 03/03/2010
Private cWorkFlow	:= ""   
Private cWCodEmp    := ""  
Private cWCodFil    := ""

If ValType(aWork) <> 'A'
	cWorkFlow  := "N"
	cWCodEmp  := cEmpAnt
    cWCodFil  := cFilAnt
    U_DIPPROC(ProcName(0),U_DipUsr()) // JBS 13/12/2005 - Gravando o nome do Programa no SZU
Else
	cWorkFlow := aWork[1]    
	cWCodEmp  := aWork[3]
    cWCodFil  := aWork[4]
EndIf
If cWorkFlow == "S"
//	PREPARE ENVIRONMENT EMPRESA "01" FILIAL "04" FUNNAME "DIPM011" TABLES "SB1","SB2","SCJ", "SCK" 
	PREPARE ENVIRONMENT EMPRESA cWCodEmp FILIAL cWCodFil FUNNAME "DIPM011" TABLES "SB1","SB2","SCJ", "SCK"  // MCVN - 03/03/2010
	ConOut("------------------------")
	ConOut("Iniciando Ambiente " )
	ConOut("------------------------")	
EndIf
_xAlias    := GETAREA()
cPerg      := "DIPM11"
nLastKey   := 0
lContinua  := .T.
lEnd       := .F.
Private _cArqTrb
If cWorkFlow == "N"
	AjustaSX1(cPerg)           // Verifica perguntas. Se nao existe INCLUI.
	
	If Pergunte(cPerg,.T.)     // Solicita parametros
		Processa({|lEnd| RunProc()},'Gerando lista de precos para EXCEL...')

	EndIf

Else          
    MV_PAR01 := 1
    MV_PAR02 := dDatabase
	RunProc()

Endif
Return
*-----------------------------------*
Static Function RunProc()
*-----------------------------------*
//Local cArqExcell:= GetSrvProfString("STARTPATH","")+"Excell-DBF\listaprc" // JBS 12/12/2005
                                                                                           
Local cArqExcell:= If(cWCodEmp+cWCodFil =="0101","\Excell-DBF\DIPROMED_MTZ-LISTAPRC",If(cWCodEmp+cWCodFil =="0401","\Excell-DBF\HQ_Matriz-Listaprc",If(cWCodEmp+cWCodFil =="0104","\Excell-DBF\DIPROMED-LISTAPRC","\Excell-DBF\HQ-LISTAPRC"))) // Alterado para gravar aquuivos no protheus_data - Por Sandro em 19/11/09.

nContador := 0

_aCampos := {}
_aTamSX3 := TamSX3("B1_PROC")
AAdd(_aCampos ,{"FORNECEDOR", "C",_aTamSX3[1],_aTamSX3[2]})
_aTamSX3 := TamSX3("B1_COD")
AAdd(_aCampos ,{"CODIGO","C",_aTamSX3[1],_aTamSX3[2]})
_aTamSX3 := TamSX3("B1_DESC")
AAdd(_aCampos ,{"PRODUTO","C",_aTamSX3[1],_aTamSX3[2]})
_aTamSX3 := TamSX3("B1_UM")
AAdd(_aCampos ,{"UM","C",_aTamSX3[1],_aTamSX3[2]})
_aTamSX3 := TamSX3("B1_ALTPREC")
AAdd(_aCampos ,{"ALTERADO","D",_aTamSX3[1],_aTamSX3[2]})
_aTamSX3 := TamSX3("B1_PRV1")
AAdd(_aCampos ,{"LISTA","N",_aTamSX3[1],_aTamSX3[2]})
_aTamSX3 := TamSX3("B1_PRVMINI")
AAdd(_aCampos ,{"C","N",_aTamSX3[1],_aTamSX3[2]})
_aTamSX3 := TamSX3("B1_PRVPROMO")
AAdd(_aCampos ,{"D","N",_aTamSX3[1],_aTamSX3[2]})
_aTamSX3 := TamSX3("B1_PRV1")
AAdd(_aCampos ,{"PROMOCAO","N",_aTamSX3[1],_aTamSX3[2]})
_aTamSX3 := TamSX3("B2_QATU")
AAdd(_aCampos ,{"ESTOQUE","N",_aTamSX3[1],_aTamSX3[2]})
_aTamSX3 := TamSX3("B1_MEN_HAB")
AAdd(_aCampos ,{"MENSAGEM","C",_aTamSX3[1],_aTamSX3[2]})
AAdd(_aCampos ,{"OBS1","C",200,0})
AAdd(_aCampos ,{"OBS2","C",200,0})
AAdd(_aCampos ,{"OBS3","C",200,0})
AAdd(_aCampos ,{"OBS4","C",200,0})
AAdd(_aCampos ,{"OBS5","C",200,0})

_cArqTrb := CriaTrab(_aCampos,.T.)
DbUseArea(.T.,,_cArqTrb,"TRB",.F.,.F.)

_cChave  := 'PRODUTO+FORNECEDOR'
IndRegua("TRB",_cArqTrb,_cChave,,,"Criando Indice...")

dbSelectArea("SB1")

IF cWorkflow == "N"
	ProcRegua(RecCount())
Else 
	ConOut("------------------------")
	ConOut("Inicio do Processamento "+_cArqTrb)
	ConOut("------------------------")	
Endif

dbGoTop()

Do While SB1->(!Eof())
	IF cWorkflow == "N"
	   IncProc(AllTrim(SB1->B1_COD)+' - '+Subs(SB1->B1_DESC,1,20))
	Endif
    // FILTROS
    If (mv_par01 == 2 .and. mv_par02 <> SB1->B1_ALTPREC) .or. ;
       SB1->B1_PRV1 == 0.0000 .or. ;
       SB1->B1_HABILIT == 'N' .or. ;
       SB1->B1_HABILIT == 'O' .or. ;
       SB1->B1_HABILIT == 'L' .or. ; // MCVN - 12/02/2007   
       If(cWCodEmp=="01",.F.,SB1->B1_FILIAL <> xFilial("SB1")) .or. ;
       SUBS(UPPER(LTRIM(SB1->B1_DESC)),1,2) == 'MC' .Or.;
       SB1->B1_FILIAL <> xFilial("SB1") .Or.;  // MCVN 09-05-2011 ( Ajuste para filial no SB1-CADASTRO DE PRODUTO)
       If(EMPTY(ALLTRIM(MV_PAR03)),.F.,SB1->B1_PROC <> MV_PAR03)
       dbSkip()
       Loop
    EndIf
    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
    //³Calcula as programacoes e saldo do produto. ³
    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    _nQtdProg := 0
    _nStok    := 0
	DbSelectArea("SCK")
	DbSetOrder(3)
	If cWCodEmp =="01" // mcvn - 03/03/2010
		IF DbSeek(xFilial("SCK")+SB1->B1_COD)
			While !Eof() .and. SCK->CK_PRODUTO == SB1->B1_COD
				IF Empty(SCK->CK_NUMPV)
					SCJ->(DbSetorder(1))
					IF SCJ->(DbSeek(xFilial("SCJ")+SCK->CK_NUM))
						IF SCJ->CJ_OPCAO == "P"
							_nQtdProg := _nQtdProg + SCK->CK_QTDVEN
						EndIF
					EndIF
				EndIF
				DbSelectArea("SCK")
				DbSkip()
			EndDo
		EndIf
	 ElseIF cWCodEmp =="04"                  
 		IF DbSeek(xFilial("SB1")+SB1->B1_COD)
			While !Eof() .and. SCK->CK_PRODUTO == SB1->B1_COD
				IF Empty(SCK->CK_NUMPV)
					SCJ->(DbSetorder(1))
					IF SCJ->(DbSeek(xFilial("SCJ")+SCK->CK_NUM))
						IF SCJ->CJ_OPCAO == "P"
							_nQtdProg := _nQtdProg + SCK->CK_QTDVEN
						EndIF
					EndIF
				EndIF
				DbSelectArea("SCK")
				DbSkip()
			EndDo
		EndIf
	Endif
    
    _cOBSERVA  := MSMM(SB1->B1_CODOBS,,,,3)   //Lower(MSMM(SB1->B1_CODOBS,TamSx3("B1_OBS")[1]))
    
    DbSelectArea("TRB")
    RecLock("TRB",.T.)
	FORNECEDOR := SB1->B1_PROC
	CODIGO     := SB1->B1_COD
	PRODUTO    := SB1->B1_DESC
	UM         := SB1->B1_UM
	ALTERADO   := SB1->B1_ALTPREC
	LISTA      := Iif(mv_par02==SB1->B1_ALTPREC,SB1->B1_PRV1*-1,SB1->B1_PRV1)
	C          := Iif(mv_par02==SB1->B1_ALTPREC,SB1->B1_PRVMINI*-1,SB1->B1_PRVMINI)
	D          := Iif(mv_par02==SB1->B1_ALTPREC,SB1->B1_PRVPROMO*-1,SB1->B1_PRVPROMO)
	PROMOCAO   := Iif(mv_par02==SB1->B1_ALTPREC,SB1->B1_PRVSUPE*-1,SB1->B1_PRVSUPE)
    ESTOQUE    := U_DIPSALDSB2(SB1->B1_COD,.T.,'')// - _nQtdprog
    MENSAGEM   := SB1->B1_MEN_HAB  

	If Len(AllTrim(_cOBSERVA)) <= 200
	   OBS1 := _cOBSERVA
	ElseIf Len(AllTrim(_cOBSERVA)) > 200 .and. Len(AllTrim(_cOBSERVA)) <= 400
	   OBS1 := Subs(_cOBSERVA,1,200)
	   OBS2 := Subs(_cOBSERVA,201,Len(AllTrim(_cOBSERVA))-201)
	ElseIf Len(AllTrim(_cOBSERVA)) > 400 .and. Len(AllTrim(_cOBSERVA)) <= 600
	   OBS1 := Subs(_cOBSERVA,1,200)
	   OBS2 := Subs(_cOBSERVA,201,Len(AllTrim(_cOBSERVA))-201)
	   OBS3 := Subs(_cOBSERVA,401,Len(AllTrim(_cOBSERVA))-401)
	ElseIf Len(AllTrim(_cOBSERVA)) > 600 .and. Len(AllTrim(_cOBSERVA)) <= 800
	   OBS1 := Subs(_cOBSERVA,1,200)
	   OBS2 := Subs(_cOBSERVA,201,Len(AllTrim(_cOBSERVA))-201)
	   OBS3 := Subs(_cOBSERVA,401,Len(AllTrim(_cOBSERVA))-401)
	   OBS4 := Subs(_cOBSERVA,601,Len(AllTrim(_cOBSERVA))-601)
	ElseIf Len(AllTrim(_cOBSERVA)) > 800
	   OBS1 := Subs(_cOBSERVA,1,200)
	   OBS2 := Subs(_cOBSERVA,201,Len(AllTrim(_cOBSERVA))-201)
	   OBS3 := Subs(_cOBSERVA,401,Len(AllTrim(_cOBSERVA))-401)
	   OBS4 := Subs(_cOBSERVA,601,Len(AllTrim(_cOBSERVA))-601)
	   OBS5 := Subs(_cOBSERVA,801,Len(AllTrim(_cOBSERVA))-801)
	EndIf
	
    TRB->(MsUnLock())
    
    nContador := nContador + Iif(mv_par02==SB1->B1_ALTPREC,1,0)
    dbSelectArea("SB1")
    SB1->(dbSkip())
    If cWorkflow == "N"
       IncProc(AllTrim(SB1->B1_COD)+' - '+Subs(SB1->B1_DESC,1,20))
    Endif
EndDo

DbSelectArea("TRB")
TRB->(dbGotop())
ProcRegua(TRB->(RECCOUNT()))	
aCols := Array(TRB->(RECCOUNT()),Len(_aCampos))
nColuna := 0
nLinha := 0
While TRB->(!Eof())
	nLinha++
	IncProc(OemToAnsi("Gerando planilha excel..."))
	For nColuna := 1 to Len(_aCampos)
		aCols[nLinha][nColuna] := &("TRB->("+_aCampos[nColuna][1]+")")			
	Next nColuna
	TRB->(dbSkip())	
EndDo
u_GDToExcel(_aCampos,aCols,Alltrim(FunName()))

DbSelectArea("TRB")
// CRIA ARQUIVO PARA ABRIR NO EXCEL
COPY TO &cArqExcell VIA "DBFCDX" // JBS 12/12/2005
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Deleta arquivos temporarios e Retorna Indices padräes ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbCloseArea()                   
Ferase(_cArqTrb+".DBF")
Ferase(_cArqTrb+OrdBagExt())
RestArea(_xAlias)

If cWorkflow == "N"
	MsgBox('Alterados...'+str(nContador,6),'Terminou...')
Else
	ConOut("------------------------")
	ConOut("Alterados" + str(nContador,6) )
	ConOut("------------------------")	
Endif

Return
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³VALIDPERG ³ Autor ³                       ³ Data ³          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Verifica as perguntas inclu¡ndo-as caso n„o existam        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Especifico para Clientes Microsiga                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function AjustaSX1(cPerg)

_sAlias := Alias()
dbSelectArea("SX1")
dbSetOrder(1)

cPerg := PADR(cPerg, Len(SX1->X1_GRUPO)," " ) // Incluido por Sandro em 18/11/09.

aRegs:={}
//------------ Grupo/Ordem/Pergunta/PERGING/PERGESP/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05/F3
AADD(aRegs,{cPerg,"01","Tudo ou da Data    ?","","","mv_ch1","N", 1,0,2,"C","","mv_par01","Tudo","","","","","Data","","","","","","","",""})
AADD(aRegs,{cPerg,"02","Data da alteracao  ?","","","mv_ch2","D", 8,0,0,"G","","mv_par02","","","","","","","","","","","","","",""})
AADD(aRegs,{cPerg,"03","Fornecedor         ?","","","mv_ch3","C",06,0,0,"G","","MV_PAR03","","","","","","","","","","","","","","","","","","","","","","","","","SA2"})

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
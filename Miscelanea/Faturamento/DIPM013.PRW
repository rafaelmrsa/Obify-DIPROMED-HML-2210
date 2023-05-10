#include "rwmake.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Funcao    ³ DIPM013  ³ Autor ³ Eriberto Elias     ³ Data ³ 16/04/2003  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Gera arquivo MALAPROD.dbf para ser usado no EXCEL          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ DIPM013                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Especifico DIPROMED                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function DIPM013()
Local _cAlias    := GetArea()
Local _cAliasSB1 := SB1->(GetArea())      
Private cDestino   := "C:\EXCELL-DBF\"

U_DIPPROC(ProcName(0),U_DipUsr()) // JBS 05/10/2005 - Gravando o nome do Programa no SZU
nLastKey   := 0
lContinua  := .T.
lEnd       := .F.

IF MsgBox("Vamos gerar um arquivo com os produtos para mala direa?","Atencao","YESNO")
	Processa({|lEnd| Gera()},'Gerando arquivo MALA DIRETA... (MALAPROD.DBF)')
EndIF

RestArea(_cAliasSB1)
RestArea(_cAlias)

Return

//////////////////////////////////////////////////////////////////////
Static Function Gera()
Local _cArqTrb
//Local cArqExcell:= GetSrvProfString("STARTPATH","")+"Excell-DBF\MalaProd" // JBS 12/12/2005

 
Local cArqExcell:= "\Excell-DBF\MalaProd" 
  
_aCampos := {}
_aTamSX3 := TamSX3("B1_COD")
AAdd(_aCampos ,{"CODIGO","C",_aTamSX3[1],_aTamSX3[2]})
_aTamSX3 := TamSX3("B1_DESC")
AAdd(_aCampos ,{"PRODUTO","C",_aTamSX3[1],_aTamSX3[2]})
_aTamSX3 := TamSX3("B1_UM")
AAdd(_aCampos ,{"UM","C",_aTamSX3[1],_aTamSX3[2]})
_aTamSX3 := TamSX3("B1_PRV1")
AAdd(_aCampos ,{"LISTA","N",_aTamSX3[1],_aTamSX3[2]})
_aTamSX3 := TamSX3("B1_PRVMINI")
AAdd(_aCampos ,{"C","N",_aTamSX3[1],_aTamSX3[2]})
_aTamSX3 := TamSX3("B1_PRVPROMO")
AAdd(_aCampos ,{"D","N",_aTamSX3[1],_aTamSX3[2]})
_aTamSX3 := TamSX3("B1_PRV1")
AAdd(_aCampos ,{"PROMOCAO","N",_aTamSX3[1],_aTamSX3[2]})   
_aTamSX3 := TamSX3("B1_PROC")
AAdd(_aCampos ,{"FORNEC","C",_aTamSX3[1],_aTamSX3[2]})
_aTamSX3 := TamSX3("A2_NREDUZ")
AAdd(_aCampos ,{"NOMEFOR","C",_aTamSX3[1],_aTamSX3[2]})


_cArqTrb := CriaTrab(_aCampos,.T.)
DbUseArea(.T.,,_cArqTrb,"TRB",.F.,.F.)

_cChave  := 'PRODUTO'
IndRegua("TRB",_cArqTrb,_cChave,,,"Criando Indice...")

dbSelectArea("SB1")

ProcRegua(RecCount())

DbSeek(xFilial("SB1"))	

While !SB1->(Eof()) .and. SB1->B1_FILIAL == xFilial("SB1")

   IncProc(AllTrim(SB1->B1_COD)+' - '+Subs(SB1->B1_DESC,1,20))
	   
   //------- FILTRO
   If SB1->B1_MALADIR <> 'S' .or. ;
      SB1->B1_PRV1 == 0.0000 .or. ;
      SB1->B1_HABILIT == 'N' .or. ;
      SB1->B1_HABILIT == 'L' .or. ; // MCVN - 12/02/2007
      SB1->B1_HABILIT == 'O'
      SB1->(dbSkip())
      Loop
   EndIf
   ////////////////////////////////////// 
   
   DbSelectArea("TRB")
   RecLock("TRB",.T.)
	CODIGO     := SB1->B1_COD
	PRODUTO    := SB1->B1_DESC
	UM         := SB1->B1_UM
	LISTA      := SB1->B1_PRV1
	C          := SB1->B1_PRVMINI
	D          := SB1->B1_PRVPROMO
	PROMOCAO   := SB1->B1_PRVSUPE       
	FORNEC     := SB1->B1_PROC
	NOMEFOR    := AllTrim(Posicione("SA2",1,xFilial("SA2")+SB1->B1_PROC,"A2_NREDUZ"))
   SB1->(MsUnLock())

   dbSelectArea("SB1")
   SB1->(dbSkip())
   
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
COPY TO &cArqExcell VIA "DBFCDX"  

MakeDir(cDestino) // CRIA DIRETÓRIO CASO NÃO EXISTA
CpyS2T(cArqExcell+".dbf",cDestino,.T.) // COPIA ARQUIVO PARA MAQUINA DO USUÁRIO

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Deleta arquivos temporarios e Retorna Indices padräes ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

DbCloseArea()                   

Ferase(_cArqTrb+".DBF")
Ferase(_cArqTrb+OrdBagExt())

Return
/////////////////////////////////////////////////////////////////////////////
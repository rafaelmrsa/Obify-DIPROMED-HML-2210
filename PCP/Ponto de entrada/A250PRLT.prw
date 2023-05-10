/*
+===========================================================+
|Funcao: A250PRLT | Autor: Reginaldo Borges | Data: 17/02/17|
+-----------------------------------------------------------+
|Descricao: Ponto de entrada para alterar o lote do produto |
|           na producao da OP.                              |
+-----------------------------------------------------------+
|Uso: Health Quality - PCP                                  |
+===========================================================+
*/

#INCLUDE "PROTHEUS.CH"

User Function A250PRLT()

Local cLote    := ParamIXB[1]  //-- Lote sugerido pelo sistema
Local dData    := ParamIXB[2]  //-- Data de Validade sugerida pelo sistema
Local lExibeLt := ParamIXB[3]  //-- Exibir a getdados para confirmação da sugestão do lote na tela.
Local aRet     := {}           //-- Customizações do Cliente
Local _nMes    := 0
Local _cMes    := ""
Local _cAno    := ""
Local _cDia    := ""
Local _nValLot := Posicione("SB1",1,xFilial("SB1")+SB1->B1_COD,"B1_XVLCTL")

_cDia :=StrZero(Day(Date()),2)
_nMes := StrZero(month(Date()),2)
_cAno :=SubStr(StrZero( Year(dData),4),3,4)
//_cMes := SubStr(UPPER(MesExtenso(_nMes)),1,3)


SD1->(DbOrderNickName("D1OP"))
SD1->(DbSeek(xFilial("SD1")+SC2->C2_NUM))

If _nValLot > 0
	
	dData := MonthSum(Date(),_nValLot)                                                                                     
	
Else
	
	dData := MonthSum(Date(),36)
	
EndIf

If cEmpant+(SD1->(xFilial("SD1")))==cEmpAnt+cFilAnt .And. AllTrim(SC2->C2_NUM+SC2->C2_ITEM+SC2->C2_SEQUEN)==AllTrim(SD1->D1_OP)
	
	cLote := SD1->D1_LOTECTL
	dData := SD1->D1_DTVALID
	
Else
	
	cLote :=  SC2->C2_XLOTECT
	
EndIf

AADD(aRet,cLote)
AADD(aRet,dData)
AADD(aRet,lExibeLt)

Return (aRet)


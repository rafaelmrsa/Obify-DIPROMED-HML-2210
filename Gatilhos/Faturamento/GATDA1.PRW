#include 'protheus.ch'
/*-------------------------------------------------------------------------------------
{Protheus.doc} GATDA1

@Author  	   Tiago Stocco - Obify
@since		   12/2022
@version	   P12

@description Gatilho do SC6 para buscar o preço da tabela de preço dipromed
*/
User Function GATDA1()
Local _cCli		:= M->C5_CLIENTE
Local _cLjCli	:= M->C5_LOJACLI
Local _cTabPrc	:= M->C5_TABELA
Local _cContrib	:= ""
Local _cEstado	:= ""
Local nPosPro   := aScan(aHeader, { |x| Alltrim(x[2]) == "C6_PRODUTO"})
Local nPosPrC   := aScan(aHeader, { |x| Alltrim(x[2]) == "C6_PRCVEN" })
Local _nvalor   := Acols[n,nPosPrc]
If Type("l410Auto") == "U" .Or. !l410Auto
    _cContrib	:= Posicione("SA1",1,xfilial("SA1")+_cCli+_cLjCli,"A1_CONTRIB")
    cGrp        := Posicione("SA1",1,xfilial("SA1")+_cCli+_cLjCli,"A1_GRPTRIB")
    _cEstado    := Posicione("SA1",1,xfilial("SA1")+_cCli+_cLjCli,"A1_EST")
    
    
    DbSelectArea("SB1")
    SB1->(dbSetOrder(1))
    If SB1->(dbSeek(xFilial("SB1") + aCols[n,nPosPro]))
        _cTabPrc	:= IIF(SB1->B1_ORIGEM=="2","004",_cTabPrc)
    ENDIF

    DA0->(dbSetOrder(1))
    DA0->(dbSeek(xFilial("DA0")+_cTabPrc))
    IF DA0->DA0_ATIVO = "1"
        DA1->(dbSetOrder(1))
        IF DA1->(dbSeek(xFilial("DA1")+_cTabPrc+aCols[n,nPosPro])) //blz.AND. DA1->DA1_XSTENT == 0 //PRODUTOS COM ST NÃO GATILHA
            _nvalor := IIF(_cContrib <> "1".AND. _cEstado <> "SP", DA1->DA1_XPRCDI,DA1->DA1_PRCVEN)
        EndIf
    ELSE
        MSGALERT("Tabela " + _cTabPrc + " bloqueada.")
    ENDIF
    
EndIf

Return _nvalor

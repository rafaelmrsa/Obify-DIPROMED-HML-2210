
#INCLUDE "Protheus.ch"
/*====================================================================================\
|Programa  | MT242TOK       | Autor | GIOVANI.ZAGO               | Data | 13/10/2011  |
|=====================================================================================|
|Descrição | Bloqueio da rotina transferencia                                         |
|          |                                                                          |
|          |                                                                          |
|=====================================================================================|
|Sintaxe   | MT242TOK                                                                  |
|=====================================================================================|
|Uso       | Especifico DIPROMED                                                      |
|=====================================================================================|
|........................................Histórico....................................|
\====================================================================================*/
*---------------------------------------------------*
User Function MT242TOK()
*---------------------------------------------------*
Local _xArea  := GetArea()
Local lRet    :=.t.
Local nPosCod := ''
Local nPosQtd := 0
Local nPosLoc := ''
Local nI      := 1
Local cCodProd:= ""
Local nQtdDesm:= 0


If ("MATA242") $ FunName()

  If !(Upper(U_DipUsr()) $ GetMv("ES_MATA242"))
    alert(Upper(U_DipUsr())+" Voce Nao Possui Acesso A Esta Rotina. !!!!!!! ")
    lRet :=.f.
  EndIf

  If cLocOrig == '01' // Somente Almoxarifado 01
    _lRet := u_Dip071Vld(cProduto,nQtdOrig,.T.)  //Validando caixa fechada da quantidade origem a ser desmontada - MCVN 12/01/23
  EndIf 

  If _lRet // Validando caixa fechada da quantidade destino  - MCVN 12/01/23
	  
    nPosCod := aScan(aHeader,{|x| Alltrim(x[2]) == "D3_COD"})
	  nPosQtd := aScan(aHeader,{|x| Alltrim(x[2]) == "D3_QUANT"})   
	  nPosLoc := aScan(aHeader,{|x| Alltrim(x[2]) == "D3_LOCAL"})   	

	  For nI := 1 to len(acols)
		
      If !aCols[nI,Len(aHeader)+1] .And. _lRet .And. aCols[nI,nPosLoc]=="01"
			  cCodProd  := aCols[nI,nPosCod]
			  nQtdDesm  := aCols[nI,nPosQtd]       
			  _lRet := u_Dip071Vld(cCodProd,nQtdDesm,.T.) 	
      Endif
	  
    next nI

  Endif


EndIf 

RestArea(_xArea)

Return(lRet) 

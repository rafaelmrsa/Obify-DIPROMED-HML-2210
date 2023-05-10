#INCLUDE "Protheus.ch"
#DEFINE CR    chr(13)+chr(10) // Carreage Return (Fim de Linha)
/*====================================================================================\
|Programa  |   MT242LOK                     | Autor | GIOVANI.ZAGO| Data | 15/09/2011 |
|=====================================================================================|
|Descrição | ponto  de entrada para validar linha do desmenbramento                   |
|          | produto origem nao pode ser igual a produto destino                      |
|          |                                                                          |
|=====================================================================================|
|Sintaxe   |                                                                          |
|=====================================================================================|
|Uso       | Especifico DIPROMED                                                      |
|=====================================================================================|
|........................................Histórico....................................|
\====================================================================================*/
*---------------------------------------------------*
User Function MT242LOK ( )
*---------------------------------------------------*
Local _xArea    := GetArea()
Local lRet      := .T.
Local cCodProd  := aCols[n,1]
Local nQtdDesm  := aCols[n,2]
Local nDescOri  := Posicione("SB1",1,xFilial("SB1")+cProduto,"B1_DESC")
Local nUnidOri  := SB1->B1_UM
Local nDescDes  := Posicione("SB1",1,xFilial("SB1")+cCodProd,"B1_DESC")
Local nUnidDes  := SB1->B1_UM

If ("MATA242") $ FunName()
	If  CCodProd = cProduto
		MsgInfo("Produto de Origem Não Pode ser Igual a Produto de Destino ","Atencao!")
		lRet := .F.
 	//Mostrar na tela a descrição dos produtos tratados na movimentação - MCVN 12/01/23
	ElseIf !(MsgYesNo("Confirma a desmontagem de "+ AllTrim(Transform(nQtdOrig,"@E 9,999,999"))+" "+nUnidOri+" do produto: "+CR+ Alltrim(cProduto) +"-"+;
		     Alltrim(nDescOri)+" para "+AllTrim(Transform(nQtdDesm,"@E 9,999,999"))+" "+nUnidDes+ " do produto: "+CR+ Alltrim(cCodProd) +"-"+Alltrim(nDescDes)+ " ?","Atenção"))
		lRet := .F.			
	Endif
Endif 

RestArea(_xArea)
Return(lRet)



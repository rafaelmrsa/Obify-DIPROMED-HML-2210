#include "rwmake.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Funcao    ³ DIPR013  ³ Autor ³ Rodrigo Franco     ³ Data ³ 08.05.2002  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Relatorio de Pedido de Compra                              ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function DIPR013()

//³ Define Variaveis                                             ³
LOCAL wnrel
LOCAL tamanho:="P"
LOCAL titulo:="Relação de Pedidos de Compra"
LOCAL cDesc1:="Relação de Pedidos de Compra de acordo com"
LOCAL cDesc2:="intervalo informado na opcao do Parametros."
LOCAL cDesc3:=" "
LOCAL nRegistro:= 0
LOCAL cKey,nIndex,cIndex  //&& Variaveis para a criacao de Indices Temp.
LOCAL cCondicao

//Local cPerg  := "DIPR13"
// FPADR(cPerg, cArq, cCampo, cTipo)  - Para ajustar o tamanho das perguntas no SX1- uso generico
PRIVATE cPerg  	:= U_FPADR( "DIPR13","SX1","SX1->X1_GRUPO"," " ) //Função criada por Sandro em 19/11/09.

PRIVATE aReturn  := { "Zebrado", 1,"Administracao", 2, 2, 1, "",0 }
PRIVATE nomeprog := "DIPR012",nLastKey := 0,nBegin:=0,aLinha:={ }
PRIVATE li:=90,limite:=80,lRodape:=.F.,cPictQtd:=""
PRIVATE nTotQtd:=nTotVal:=0
PRIVATE aPedCli:= {}
wnrel    := "DIPR013"
cString  := "SC7"
PRIVATE nNItem := 0 

U_DIPPROC(ProcName(0),U_DipUsr()) // JBS 05/10/2005 - Gravando o nome do Programa no SZU

//³ Verifica as perguntas selecionadas                          ³
pergunte(cPerg,.T.)

//³ Variaveis utilizadas para parametros		                ³
//³ mv_par01	     	  DA DATA	    	                    ³
//³ mv_par02	     	  ATE A DATA	    	                ³
//³ mv_par03	     	  DO FORNECEDOR   	                    ³
//³ mv_par04	     	  ATE O FORNECEDOR    	                ³
//³ mv_par05	     	  CONSOLIDADO        	                ³
wnrel:=SetPrint(cString,wnrel,cperg,@Titulo,cDesc1,cDesc2,cDesc3,.F.,,,Tamanho)
If nLastKey==27
	Set Filter to
	Return( NIL )
Endif
SetDefault(aReturn,cString)
If nLastKey==27
	Set Filter to
	Return( NIL )
Endif
RptStatus({|lEnd| DIPR13I(@lEnd,wnRel,cString)},Titulo)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Fun‡…o    ³ DIPR13I  ³ Autor ³ Rodrigo Franco      ³ Data ³ 31.01.2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Chamada do Relatorio                                       ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function DIPR13I(lEnd,WnRel,cString)

//³ Define Variaveis                                             ³
LOCAL tamanho:= "P"
LOCAL titulo:="Relação de Pedidos de Compra"
LOCAL cDesc1:="Relação de Pedidos de Compra de acordo com"
LOCAL cDesc2:="intervalo informado na opcao do Parametros."
LOCAL cDesc3:=" "
LOCAL nRegistro:= 0
LOCAL cKey,nIndex,cIndex  && Variaveis para a criacao de Indices Temp.
LOCAL cCondicao
LOCAL aFiliais := {}
  

//³ Faz manualmente porque nao chama a funcao Cabec()                 ³
@ 0,0 psay AvalImp(Limite)

If cEmpAnt == '01'
	If mv_par05 == 1
		aFiliais := {"01","04"}
	Else
		aFiliais := {cFilAnt}	
	EndIf
Else
	If mv_par05 == 1
		aFiliais := {"01","02"}
	Else
		aFiliais := {cFilAnt}	
	EndIf
EndIf


li := 1
Pg := 51
_cValorT := 0

FOR I := 1 To Len(aFiliais)

	DbSelectArea("SC7")
	DbSetOrder(5)
	DbSeek(aFiliais[I]+Dtos(mv_par01),.T.)
	
	While !Eof() .AND. SC7->C7_EMISSAO <= mv_par02
		IF SC7->C7_FORNECE < mv_par03 .OR. SC7->C7_FORNECE > mv_par04
			DBSKIP()
			LOOP
		EndIf
		_nNumPc  := SC7->C7_NUM
		_dData   := SC7->C7_EMISSAO
		_cForn   := SC7->C7_FORNECE
		_cValor  := 0
		
		DbSelectArea("SA2")
		DbSetOrder(1)
		If DbSeek("  "+_cForn)
			_cNomFor := SA2->A2_NREDUZ
		Endif
		While !EOF() .AND. aFiliais[I] == SC7->C7_FILIAL .AND. _nNumPc == SC7->C7_NUM
			_cValor  := _cValor + SC7->C7_TOTAL
			_cValorT := _cValorT + SC7->C7_TOTAL
			DBSELECTAREA("SC7")
			DBSKIP()
		END
		DBSELECTAREA("SC7")
		DBSKIP(-1)
		ImpCabec()
		DBSELECTAREA("SC7")
		DBSKIP()
		
	Enddo
	
	LOOP
	
Next

ImpTot()
If aReturn[5] = 1
	Set Printer To
	dbCommitAll()
	OurSpool(wnrel)
Endif

MS_FLUSH()

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Fun‡…o    ³ ImpCabec ³ Autor ³ Rodrigo Franco      ³ Data ³ 31.01.2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Relatorio de Saldos                                        ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ImpCabec()

LOCAL cHeader,nPed,cMoeda,cCampo,cComis,cPedCli

IF Pg > 50
	li := 0
	Pg := 1
	@ li,000 psay CHR(18)
	li++
	@ li,000 psay Replicate("-",80)
	li++
	@ li,000 psay "DIPROMED COMERCIO E IMPORTACAO LTDA. "
	cEMISSAO:=DTOC(dDATABASE)+' '+SUBS(TIME(),1,5)
	@ li,080-LEN(cEMISSAO) psay cEMISSAO
	li++
	@ li,000 psay Replicate("-",80)
	li++
	@ li,INT((80-LEN("*** Relatorio de Pedidos de Compra ***"))/2) psay "*** Relatorio de Pedidos de Compra ***"
	li++
	@ li,000 psay Replicate("-",80)
	li := li + 1
	@ li,000 psay Replicate("-",80)
	li++
	@ li,000 psay "                         DE " + DTOC(mv_par01) + " ATE " + DTOC(mv_par02)
	li++
	@ li,000 psay "|Data      |Pedido  |Fornecedor                                    |Valor       |"
	li++      //    15/05/02   075052   080808 - franconsultoria info                  7.112.235,23
	@ li,000 psay Replicate("-",80)
	li++
Endif
li++
@ li,001 psay DTOC(_dData) + "   " + _nNumPc + "   " + _cForn + " - " + _cNomFor + "                  " + TRANSF(_cValor,"@E 9,999,999.99")
Pg := Pg + 1

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Fun‡…o    ³ ImpCabec ³ Autor ³ Rodrigo Franco      ³ Data ³ 31.01.2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Relatorio de Saldos                                        ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ImpTot()

LOCAL cHeader,nPed,cMoeda,cCampo,cComis,cPedCli

IF Pg > 50
	li := 0
	Pg := 1
	@ li,000 psay CHR(18)
	li++
	@ li,000 psay Replicate("-",80)
	li++
	@ li,000 psay "DIPROMED COMERCIO E IMPORTACAO LTDA.  "
	cEMISSAO:=DTOC(dDATABASE)+' '+SUBS(TIME(),1,5)
	@ li,080-LEN(cEMISSAO) psay cEMISSAO
	li++
	@ li,000 psay Replicate("-",80)
	li++
	@ li,INT((80-LEN("*** Relatorio de Pedidos de Compra ***"))/2) psay "*** Relatorio de Pedidos de Compra ***"
	li++
	@ li,000 psay Replicate("-",80)
	li := li + 1
	@ li,000 psay Replicate("-",80)
	li++
	@ li,000 psay "                         DE " + DTOC(mv_par01) + " ATE " + DTOC(mv_par02)
	li++
	@ li,000 psay "|Data      |Pedido  |Fornecedor                                    |Valor       |"
	li++      //    15/05/02   075052   080808 - franconsultoria info                  7.112.235,23
	@ li,000 psay Replicate("-",80)
	li++
Endif
li++
li++
@ li,001 psay "                                                       TOTAL:  R$  " + TRANSF(_cValorT,"@E 99,999,999.99")
Pg := Pg + 1

Return
#include "rwmake.ch"

/*
�����������������������������������������������������������������������������
���Funcao    � DIPR013  � Autor � Rodrigo Franco     � Data � 08.05.2002  ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Relatorio de Pedido de Compra                              ���
�����������������������������������������������������������������������������
*/
User Function DIPR013()

//� Define Variaveis                                             �
LOCAL wnrel
LOCAL tamanho:="P"
LOCAL titulo:="Rela��o de Pedidos de Compra"
LOCAL cDesc1:="Rela��o de Pedidos de Compra de acordo com"
LOCAL cDesc2:="intervalo informado na opcao do Parametros."
LOCAL cDesc3:=" "
LOCAL nRegistro:= 0
LOCAL cKey,nIndex,cIndex  //&& Variaveis para a criacao de Indices Temp.
LOCAL cCondicao

//Local cPerg  := "DIPR13"
// FPADR(cPerg, cArq, cCampo, cTipo)  - Para ajustar o tamanho das perguntas no SX1- uso generico
PRIVATE cPerg  	:= U_FPADR( "DIPR13","SX1","SX1->X1_GRUPO"," " ) //Fun��o criada por Sandro em 19/11/09.

PRIVATE aReturn  := { "Zebrado", 1,"Administracao", 2, 2, 1, "",0 }
PRIVATE nomeprog := "DIPR012",nLastKey := 0,nBegin:=0,aLinha:={ }
PRIVATE li:=90,limite:=80,lRodape:=.F.,cPictQtd:=""
PRIVATE nTotQtd:=nTotVal:=0
PRIVATE aPedCli:= {}
wnrel    := "DIPR013"
cString  := "SC7"
PRIVATE nNItem := 0 

U_DIPPROC(ProcName(0),U_DipUsr()) // JBS 05/10/2005 - Gravando o nome do Programa no SZU

//� Verifica as perguntas selecionadas                          �
pergunte(cPerg,.T.)

//� Variaveis utilizadas para parametros		                �
//� mv_par01	     	  DA DATA	    	                    �
//� mv_par02	     	  ATE A DATA	    	                �
//� mv_par03	     	  DO FORNECEDOR   	                    �
//� mv_par04	     	  ATE O FORNECEDOR    	                �
//� mv_par05	     	  CONSOLIDADO        	                �
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
�����������������������������������������������������������������������������
���Fun��o    � DIPR13I  � Autor � Rodrigo Franco      � Data � 31.01.2002 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Chamada do Relatorio                                       ���
�����������������������������������������������������������������������������
*/
Static Function DIPR13I(lEnd,WnRel,cString)

//� Define Variaveis                                             �
LOCAL tamanho:= "P"
LOCAL titulo:="Rela��o de Pedidos de Compra"
LOCAL cDesc1:="Rela��o de Pedidos de Compra de acordo com"
LOCAL cDesc2:="intervalo informado na opcao do Parametros."
LOCAL cDesc3:=" "
LOCAL nRegistro:= 0
LOCAL cKey,nIndex,cIndex  && Variaveis para a criacao de Indices Temp.
LOCAL cCondicao
LOCAL aFiliais := {}
  

//� Faz manualmente porque nao chama a funcao Cabec()                 �
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
�����������������������������������������������������������������������������
���Fun��o    � ImpCabec � Autor � Rodrigo Franco      � Data � 31.01.2002 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Relatorio de Saldos                                        ���
�����������������������������������������������������������������������������
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
�����������������������������������������������������������������������������
���Fun��o    � ImpCabec � Autor � Rodrigo Franco      � Data � 31.01.2002 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Relatorio de Saldos                                        ���
�����������������������������������������������������������������������������
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
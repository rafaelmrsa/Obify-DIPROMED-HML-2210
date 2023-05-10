#include "rwmake.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Funcao    ³ DIPR012  ³ Autor ³ Rodrigo Franco     ³ Data ³ 14.02.2002  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³                             ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function DIPR012()

//³ Define Variaveis                                             ³
LOCAL wnrel
LOCAL tamanho:="G"
LOCAL titulo:="Relação de Saldos"
LOCAL cDesc1:="Relação de Saldos,de acordo com"
LOCAL cDesc2:="intervalo informado na opcao do Parametros."
LOCAL cDesc3:=" "
LOCAL nRegistro:= 0
LOCAL cKey,nIndex,cIndex  //&& Variaveis para a criacao de Indices Temp.
LOCAL cCondicao

//LOCAL cPerg  := "MTR190"
// FPADR(cPerg, cArq, cCampo, cTipo)  - Para ajustar o tamanho das perguntas no SX1- uso generico
PRIVATE cPerg  	:= U_FPADR( "MTR190","SX1","SX1->X1_GRUPO"," " ) //Função criada por Sandro em 19/11/09.

PRIVATE aReturn  := { "Zebrado", 1,"Administracao", 2, 2, 1, "",0 }
PRIVATE nomeprog := "DIPR012",nLastKey := 0,nBegin:=0,aLinha:={ }
PRIVATE li:=90,limite:=220,lRodape:=.F.,cPictQtd:=""
PRIVATE nTotQtd:=nTotVal:=0
PRIVATE aPedCli:= {}
wnrel    := "DIPR012"
cString  := "SB2"
PRIVATE nNItem := 0

U_DIPPROC(ProcName(0),U_DipUsr()) // JBS 05/10/2005 - Gravando o nome do Programa no SZU


//³ Verifica as perguntas selecionadas                          ³
pergunte(cPerg,.T.)

//³ Variaveis utilizadas para parametros		                ³
//³ mv_par01	     	  DO PRODUTO 			                    ³
//³ mv_par02	     	  ATE PRODUTO			                ³
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

RptStatus({|lEnd| DIPR12I(@lEnd,wnRel,cString)},Titulo)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Fun‡…o    ³ DIPR12I  ³ Autor ³ Rodrigo Franco      ³ Data ³ 31.01.2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Chamada do Relatorio                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                            ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function DIPR12I(lEnd,WnRel,cString)

//³ Define Variaveis                                             ³
LOCAL tamanho:= "P"
LOCAL titulo:="Relação de Saldos"
LOCAL cDesc1:="Relação de Saldos,de acordo com"
LOCAL cDesc2:="intervalo informado na opcao do Parametros."
LOCAL cDesc3:=" "
LOCAL nRegistro:= 0
LOCAL cKey,nIndex,cIndex  && Variaveis para a criacao de Indices Temp.
LOCAL cCondicao

//³ Faz manualmente porque nao chama a funcao Cabec()                 ³
@ 0,0 psay AvalImp(Limite)

DbSelectArea("SB1")
DbSeek(xFilial('SB1')+mv_par01)

li := 1
Pg := 51         

While !Eof()
	IF SB1->B1_COD < mv_par01 .or. SB1->B1_COD > mv_par02
		DBSKIP()
		LOOP
	EndIf   
	
	_cProd   := SB1->B1_COD
	_nQtdB7  := 0
	_nQtdB21 := 0 
	_nQtdB22 := 0 
	_nQtdB23 := 0	
	_nQtdB81 := 0 
	_nQtdB82 := 0
	_nQtdB83 := 0
	_nQtdBF1 := 0 
	_nQtdBF2 := 0
	_nQtdBF3 := 0
	
	DbSelectArea("SB7")
	DbSetOrder(1)
	IF Dbseek(xFilial("SB7")+"20020709"+_cProd)
		While !EOF() .AND. xFilial("SB7") == SB7->B7_FILIAL .AND. _cProd == SB7->B7_COD .AND. "20020709" == DTOS(SB7->B7_DATA)
			_nQtdB7 := _nQtdB7 + SB7->B7_QUANT
			DBSELECTAREA("SB7")
			DBSKIP()
		END
	ENDIF
 	
 	DbSelectArea("SB2")
 	DbSetOrder(1)
 	IF Dbseek(xFilial("SB2")+_cProd+"01")
		_nQtdB21 := SB2->B2_QATU
 	ENDIF	
 	DbSelectArea("SB2")
	DbSetOrder(1)
	IF Dbseek(xFilial("SB2")+_cProd+"02")
		_nQtdB22 := SB2->B2_QATU
	ENDIF
	
	DbSelectArea("SB8")
	DbSetOrder(1)
	IF Dbseek(xFilial("SB8")+_cProd+"01")
		While !EOF() .AND. xFilial("SB8") == SB8->B8_FILIAL .AND. _cProd == SB8->B8_PRODUTO .AND. SB8->B8_LOCAL == "01"
			_nQtdB81 := _nQtdB81 + SB8->B8_SALDO
			DBSELECTAREA("SB8")
			DBSKIP()
		END
	ENDIF 
	DbSelectArea("SB8")
	DbSetOrder(1)
	IF Dbseek(xFilial("SB8")+_cProd+"02")
		While !EOF() .AND. xFilial("SB8") == SB8->B8_FILIAL .AND. _cProd == SB8->B8_PRODUTO .AND. SB8->B8_LOCAL == "02"
			_nQtdB82 := _nQtdB82 + SB8->B8_SALDO
			DBSELECTAREA("SB8")
			DBSKIP()
		END
	ENDIF 
	DbSelectArea("SBF")
	DbSetOrder(2)
	IF Dbseek(xFilial("SBF")+_cProd+"01")
		While !EOF() .AND. xFilial("SBF") == SBF->BF_FILIAL .AND. _cProd == SBF->BF_PRODUTO .AND. SBF->BF_LOCAL == "01"
			_nQtdBF1 := _nQtdBF1 + SBF->BF_QUANT
			DBSELECTAREA("SBF")
			DBSKIP()
		END
	ENDIF  
	DbSelectArea("SBF")
	DbSetOrder(2)
	IF Dbseek(xFilial("SBF")+_cProd+"02")
		While !EOF() .AND. xFilial("SBF") == SBF->BF_FILIAL .AND. _cProd == SBF->BF_PRODUTO .AND. SBF->BF_LOCAL == "02"
			_nQtdBF2 := _nQtdBF2 + SBF->BF_QUANT
			DBSELECTAREA("SBF")
			DBSKIP()
		END
	ENDIF
	_cProd := substr(SB1->B1_COD,1,6)
	ImpCabec()
	DBSELECTAREA("SB1")
	DBSKIP()
Enddo

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
	@ li,000 psay Replicate("-",145)
	li++
	@ li,000 psay "DIPROMED COMERCIO E IMPORTACAO LTDA.  "
	cEMISSAO:=DTOC(dDATABASE)+' '+SUBS(TIME(),1,5)
    @ li,145-LEN(cEMISSAO) psay cEMISSAO
	li++
	@ li,000 psay Replicate("-",145)
	li++
	@ li,INT((145-LEN("*** Relatorio de Saldos ***"))/2) psay "*** Relatorio de Saldos ***"
	li++
	@ li,000 psay Replicate("-",145)
	li := li + 1
	@ li,000 psay Replicate("-",145)
	li++
	@ li,000 psay "        |                                                               SALDOS                                                              | "
	li++
	@ li,000 psay "Produto |    B7     |   B2(1)   |   B2(2)   | B2(Total) |   B8(1)   |   B8(2)   | B8(Total) |   BF(1)   |   BF(2)   | BF(Total) | Dif. B2BF | "
	li++      //   999999   999.999.999 999.999.999 999.999.999 999.999.999 999.999.999 999.999.999 999.999.999 999.999.999 999.999.999 999.999.999 999.999.999
	@ li,000 psay Replicate("-",145)
	li++
Endif

_nQtdB23 := _nQtdB21 + _nQtdB22    
_nQtdB83 := _nQtdB81 + _nQtdB82  
_nQtdBF3 := _nQtdBF1 + _nQtdBF2
_nQtdBX  := Iif(_nQtdB23 <> _nQtdBF3.or._nQtdB23 <> _nQtdB83.or._nQtdB83 <> _nQtdBF3,"xxxxxx",_nQtdBX := "")
	
If _nQtdBx == "xxxxxx"
	li++      
	@ li,000 psay _cProd + "   " + TRANSF(_nQtdB7,"@E 999,999,999") + " " + TRANSF(_nQtdB21,"@E 999,999,999") + " " + TRANSF(_nQtdB22,"@E 999,999,999") + " " + TRANSF(_nQtdB23,"@E 999,999,999") + " " + TRANSF(_nQtdB81,"@E 999,999,999") + " " + TRANSF(_nQtdB82,"@E 999,999,999") + " " + TRANSF(_nQtdB83,"@E 999,999,999") + " " + TRANSF(_nQtdBF1,"@E 999,999,999") + " " + TRANSF(_nQtdBF2,"@E 999,999,999") + " " + TRANSF(_nQtdBF3,"@E 999,999,999")+ " " + TRANSF(_nQtdBX,"@!")
	Pg := Pg + 1
EndIf

Return
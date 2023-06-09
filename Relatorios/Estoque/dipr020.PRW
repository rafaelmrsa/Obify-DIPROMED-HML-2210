#include "rwmake.ch"

/*/
�����������������������������������������������������������������������������
���Fun��o    � DIPR020 � Autor � Eriberto Elias       � Data � 09/07/2002 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Relacao dos produtos a serem transferidos do D2 para o D1 ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Exclussivo da DIPROMED                                     ���
�������������������������������������������������������������������������Ĵ��
/*/
User Function DIPR020()

//� Define Variaveis                                             �
LOCAL wnrel
LOCAL Tamanho  := "P"
LOCAL cDesc1   := "Emite uma relacao com os itens para transferencia do D2 para o D1"
LOCAL cDesc2   := ""
LOCAL cDesc3   := ""

//� Variaveis tipo Private padrao de todos os relatorios         �
PRIVATE nomeprog := "DIPR020"
PRIVATE cString  := "SB1"
PRIVATE aReturn  := { "Zebrado", 1,"Administracao", 1, 2, 1, "",1 }
PRIVATE nLastKey := 0

// PRIVATE cPerg    := "DIPR20"
// FPADR(cPerg, cArq, cCampo, cTipo)  - Para ajustar o tamanho das perguntas no SX1- uso generico
PRIVATE cPerg  	:= U_FPADR( "DIPR20","SX1","SX1->X1_GRUPO"," " ) //Fun��o criada por Sandro em 19/11/09.

PRIVATE titulo   := "Produtos transf.do D2 para D1"
PRIVATE li    := 80
PRIVATE m_pag := 1

//� Verifica as perguntas selecionadas                           �
//� Variaveis utilizadas para parametros                         �
//� mv_par01             // Produto de                           �
//� mv_par02             // Produto ate                          �

//� Verifica as perguntas selecionadas                           �
U_DIPPROC(ProcName(0),U_DipUsr()) // JBS 05/10/2005 - Gravando o nome do Programa no SZU

AjustaSX1(cPerg)

pergunte(cPerg,.f.)

//� Envia controle para a funcao SETPRINT                        �
wnrel:=SetPrint(cString,NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,"",.F.,Tamanho)
If nLastKey = 27
	Set Filter To
	Return
Endif
SetDefault(aReturn,cString)
If nLastKey = 27
	Set Filter To
	Return
Endif
RptStatus({|lEnd| R020Imp(@lEnd,tamanho,wnrel,cString)},Titulo)

Return .T.

/*
�����������������������������������������������������������������������������
���Fun��o    � R020IMP  � Autor � Eriberto Elias      � Data � 09/07/2002 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Chamada do Relatorio                                       ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � DIPR020		                                              ���
�����������������������������������������������������������������������������
*/
Static Function R020Imp(lEnd,tamanho,wnrel,cString)

LOCAL cRodaTxt := "PRODUTO(S)"
LOCAL cabec1,cabec2,cabec3
LOCAL limite   := 80
LOCAL nCntImpr := 0
//� Inicializa os codigos de caracter Comprimido/Normal da impressora �
nTipo  := IIF(aReturn[4]==1,15,18)

//� Monta os Cabecalhos                                          �
cabec1 := "CODIGO  DESCRICAO                                                     QUANTIDADE"
cabec2 := "                                                                                "
*****      123456  1234567890123456789012345678901234567890123456789012345678909999.999.999"
*****      0         1         2         3         4         5         6         7         8         9        10        11        12        13        14        15        16        17        18        19        20        21
*****      0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123
dbSelectArea("SB1")
SetRegua(RecCount())
dbSetOrder(1)
Set SoftSeek On
dbSeek( xFilial('SB1')+mv_par01 )
Set SoftSeek Off

nRegSB1 := RECNO()

While !Eof() .And. B1_FILIAL+B1_COD <= xFilial('SB1')+mv_par02

	If lEnd
		@PROW()+1,001 PSAY "CANCELADO PELO OPERADOR"
		Exit
	Endif

	IncRegua()

	nSALDOBF := 0
	nSALDOd2 := 0
	
	dbSelectArea("SBF")
	dbSetOrder(8)
	dbSeek( xFILIAL('SBF')+SB1->B1_COD )

	While !Eof() .And. SBF->BF_PRODUTO == SB1->B1_COD
		If AllTrim(SBF->BF_LOCALIZ) == 'DEPOSITO 2' 
			nSALDOd2 := SBF->BF_QUANT
			dbSkip()
			Loop
		EndIf
		
		nSALDOBF := nSALDOBF + SBF->BF_QUANT - SBF->BF_EMPENHO
		
		dbSkip()
	EndDo

	dbSelectArea("SB1")
	
	nTRANSF := 0
	If nSALDOBF <= SB1->B1_MIN_D1 .AND. nSALDOd2 > 0
		
		nTRANSF := SB1->B1_MAX_D1 - nSALDOBF

		If li > 55
			Cabec(titulo,cabec1,cabec2,nomeprog,Tamanho,nTipo)
		EndIf
		
		//� Adiciona 1 ao contador de registros impressos         �
		nCntImpr++
		
		@ li,000 PSAY SUBS(B1_COD,1,6)
		@ li,008 PSAY SubStr(B1_DESC,1,60)
		@ li,068 PSAY Iif(nTRANSF <= nSALDOd2,nTRANSF,nSALDOd2) Picture "9999,999,999"
		li++
	Endif

	dbSelectArea("SB1")
	dbSkip()

EndDo
If li != 80
	Li++
	Roda(nCntImpr,cRodaTxt,Tamanho)
EndIf

//� Devolve a condicao original do arquivo principal             �
dbSelectArea(cString)
Set Filter To
Set Order To 1
If aReturn[5] = 1
	Set Printer To
	dbCommitAll()
	OurSpool(wnrel)
Endif
MS_FLUSH()

Return .T.

/*/
�����������������������������������������������������������������������������
���Fun��o    �VALIDPERG � Autor � AP5 IDE            � Data �  08/01/02   ���
�������������������������������������������������������������������������͹��
���Descri��o � Verifica a existencia das perguntas criando-as caso seja   ���
���          � necessario (caso nao existam).                             ���
�����������������������������������������������������������������������������
/*/
Static Function AjustaSX1(cPerg)

Local _sAlias := Alias()
Local aRegs := {}
Local i,j

dbSelectArea("SX1")
dbSetOrder(1)

aAdd(aRegs,{cPerg,"01","Produto de         ?","","","mv_ch3","C",15,0,0,"G","","mv_par03","","",""," ","","","","","","","","","","","","","","","","","","","","","SB1",""})
aAdd(aRegs,{cPerg,"02","Produto ate        ?","","","mv_ch4","C",15,0,0,"G","","mv_par04","","","","Z","","","","","","","","","","","","","","","","","","","","","SB1",""})
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
DbSelectArea(_sAlias)

Return
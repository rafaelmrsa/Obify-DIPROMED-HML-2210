#include "rwmake.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Fun‡…o    ³ DIPA018 ³ Autor ³    Rodrigo Franco      ³ Data ³ 05.06.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Mostra Vendas Por fornecedor.                              ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function DIPA018()

//³ Define Variaveis
Local aArea     := GetArea()
Local cCondicao 
Local _aRadio   
//Local aIndSD2   := {}
xBotaoSai       := .T.
_stru           := {}
_aTrb           := {}
_cCodPro        := "      "
_aCamp          := {}
_cFlag          := "o"
_cIndex         := ""
_cChave         := ""
_cAlias         := ""
_cNesc          := ""
cArq            := ""
aCampos         := {}
_cFla           := 0
_par01          := Space(6)
_par02          := "ZZZZZZ"
_par03          := Space(6)
_par04          := "ZZZZZZ"
_par05          := Space(6)
_par06          := "ZZZZZZ"
_par07          := Space(6)
_par08          := "ZZZZZZ"
_par09          := Space(6)
_par10          := "ZZZZZZ"
_par11          := Space(6)
_par12          := "ZZZZZZ"
_par13          := CTOD("  /  /  ")
_par14          := CTOD("  /  /  ")
_loj1           := _loj2 := _loj3 := _loj4 := Space(2)
_cCombo         := "Pendente"
_aItems         := {"Pendente","Atendida"}
_cDatRec        := dDatabase
_cHorRec        := time()
aCols           := {}
aHeader         := {}
_nRadio         := 1
_cNomBro        := SPACE(40)
_cZonBro        := SPACE(1)
cString         := ''
_cTexto         := ""
_cDivBro        := SPACE(6)
_nUsado         := 0
_nPosCod        := ""
_nPosDes        := ""
_nPosQua        := ""
_nRecRb         := 0  
_cCodFor 		:= space(06)
_cNomeFor 		:= space(40)
_nVezes  		:= 0
_nTotVen 		:= 0
_nTotCus 		:= 0
_nTotMar 		:= 0
_nTotNfe 		:= 0 
_cICodFor 		:= space(06)
_cINomeFor 		:= space(40)
_nIVenda	   	:= 0
_nICusto   		:= 0
_nIMarge	   	:= 0
_nINfEnt   		:= 0  
_nCusto2        := 0
cCondicao := ""
_aRadio   := {"Todos","Liberados","Faturados","Bloqueados por Credito",;
"Bloqueados Parcialmente","Com Saldos a Liberar","Bloqueados por Estoque"}
aIndSD2   := {}
Private bFiltraBrw := {|| Nil}
Private aRotina := { { 'Pesquisa','PesqBrw', 0 , 1},;		 	      //Pesquisa
{ 'Reavalia Pedido','A455LIBAUT', 0 , 2},;         			      //Reavaliacao do pedido
{ 'Legenda','BrwLegenda(cCadastro,"Legenda",_aCoresLeg)', 0 , 3}}    //Legenda
U_DIPPROC(ProcName(0),U_DipUsr()) // JBS 05/10/2005 - Gravando o nome do Programa no SZU

CriaTemp()
CriaTem2()
@ 0,0 To 480,780 Dialog oDlg1 Title OemToAnsi("Faturamento por Fornecedor")
xBotaoSai := .T.
//@ 007,005 RADIO _aRadio VAR _nRadio //Valid Back()
@ 007,007 say "Da Data"
//@ 007,087 say "Do Vendedor"
//@ 007,127 say "Do Operador"
@ 007,052 say "Do Fornecedor"
@ 007,110 say "Do Produto"
@ 007,150 say "Do Cliente"
@ 007,208 say "Do Pedido"
@ 016,005 Get _par13 SIZE 40,10
//@ 016,087 Get _par01 F3 "SA3"
//@ 016,127 Get _par03 F3 "SU7"
@ 016,052 Get _par05 F3 "SA2"
@ 016,082 Get _loj3  Picture "@!" When .F. SIZE 10,05
@ 016,110 Get _par07 F3 "SB1"
@ 016,150 Get _par09 F3 "SA1"
@ 016,182 Get _loj1  Picture "@!" When .F. SIZE 10,05
@ 016,208 Get _par11
@ 033,007 say "Ate a Data"
//@ 033,087 say "Ate o Vendedor"
//@ 033,127 say "Ate o Operador"
@ 033,052 say "Ate o Fornecedor"
@ 033,110 say "Ate o Produto"
@ 033,150 say "Ate o Cliente"
@ 033,208 say "Ate o Pedido"
@ 042,005 Get _par14 SIZE 40,10
//@ 042,087 Get _par02 F3 "SA3"
//@ 042,127 Get _par04 F3 "SU7"
@ 042,052 Get _par06 F3 "SA2"
@ 042,082 Get _loj4  Picture "@!" When .F. SIZE 15,10
@ 042,110 Get _par08 F3 "SB1"
@ 042,150 Get _par10 F3 "SA1"
@ 042,182 Get _loj2  Picture "@!" When .F. SIZE 15,10
@ 042,208 Get _par12
@ 055,007 BUTTON "_0 Repete" SIZE 28,10 ACTION Rept(0)
//@ 055,087 BUTTON "_1 Repete" SIZE 28,10 ACTION Rept(1)
//@ 055,127 BUTTON "_2 Repete" SIZE 28,10 ACTION Rept(2)
@ 055,062 BUTTON "_3 Repete" SIZE 28,10 ACTION Rept(3)
@ 055,110 BUTTON "_4 Repete" SIZE 28,10 ACTION Rept(4)
@ 055,160 BUTTON "_5 Repete" SIZE 28,10 ACTION Rept(5)
@ 055,208 BUTTON "_6 Repete" SIZE 28,10 ACTION Rept(6)
@ 055,250 BUTTON "_Todos"    SIZE 22,10 ACTION Rept(7)
@ 070,005 BUTTON "_Atualizar Informacoes" SIZE 55,10 ACTION Analizar()
@ 070,100 BUTTON "_Relatorio" SIZE 45,10 ACTION Imprimir()
//@ 070,229 BUTTON "_Visualiza Pedido" SIZE 45,10 ACTION VerPed()
//@ 070,335 BUTTON "_Bloqueia Parcial" SIZE 50,10 ACTION GrvParcial()
@ 001,003 To 067,389
@ 001,003 To 240,389
@ 085,008 TO 220,360 BROWSE "TRB" FIELDS _aTrb Object oBro
@ 223,355 BmpButton Type 1 Action (OK(),Close(oDlg1))
@ 225,058 say "Valor Total da Pesquisa: "
@ 225,155 Get _nTotVen Picture "@E 999,999,999.9999" When .F. SIZE 50,10
@ 225,208 Get _nTotCus Picture "@E 999,999,999.9999" When .F. SIZE 50,10
@ 225,260 Get _nTotMar Picture "@E 999,999,999.9999" When .F. SIZE 40,10
@ 225,300 Get _nTotNfe Picture "@E 999,999,999.9999" When .F. SIZE 50,10
Activate Dialog oDlg1 Center

RestArea(aArea)
Return

********************
Static Function Analizar()

_nVezes   := 0
_nTotVen  := 0
_nTotCus  := 0
_nTotNfe  := 0
dbSelectArea("SD2")
RetIndex("SD2")
dbClearFilter()
aEval(aIndSd2,{|x| Ferase(x[1]+OrdBagExt())})
aIndSD2   := {}
dbSelectArea("SD2")
dbSetOrder(9)
dbgotop()        

//³ Inicializa variavel com a condicao padrao do Filtro, ou quando Mv_par01=="1". ³
cCondicao := "D2_FILIAL=='"+xFilial("SD2")+"' "

/*
IF _nRadio == 2

//³ Somente Itens Liberados									     ³
cCondicao += ".AND. D2_BLEST=='  ' .And. D2_BLCRED2=='  '.AND. SC9->C9_PARCIAL==' ' "
ElseIF _nRadio == 3

//³ Somente Itens Faturados									     ³
cCondicao += ".AND. SD2->D2_BLCRED=='10'.And.SD2->D2_BLEST=='10' "
ElseIF _nRadio == 4

//³ Somente Itens Bloqueados por Credito					     ³
cCondicao += ".AND. SD2->D2_BLCRED2=='01'.And.SD2->D2_BLCRED<>'10'"
ElseIF _nRadio == 5

//³ Somente Itens Bloqueados Parcialmente					     ³
cCondicao += ".AND. SD2->D2_PARCIAL=='N' "
ElseIF _nRadio == 6

//³ Somente Itens com Saldo a Liberar						     ³
cCondicao := "U_USALDSB2()> 0 .And. SD2->D2_SALDO > 0 "
cCondicao += ".AND. D2_BLEST<>'  '.And.D2_BLEST<>'10'"
ElseIF _nRadio == 7

//³ Somente Itens com Bloqueados por Estoque     			     ³
cCondicao += ".AND. SD2->D2_BLEST=='02' .AND. SD2->D2_SALDO == 0 .AND. SD2->D2_PARCIAL==' '"
EndIF

*/
//³ Variaveis para o complemento do Filtro, ou quando Mv_par01=="1" ³
//cCondicao += ".AND. SD2->D2_VEND    >= '"+_par01+"' .And. SD2->D2_VEND    <= '"+_par02+"'"
//cCondicao += ".AND. SD2->D2_OPERADO >= '"+_par03+"' .And. SD2->D2_OPERADO <= '"+_par04+"'"
cCondicao += ".AND. SD2->D2_FORNEC  >= '"+_par05+"' .And. SD2->D2_FORNEC  <= '"+_par06+"'"
cCondicao += ".AND. SUBSTR(SD2->D2_CF,2,2)  == '"+"12"+"'"
//cCondicao += ".And. SD2->D2_COD     >= '"+_par07+"' .And. SD2->D2_COD     <= '"+_par08+"'"
//cCondicao += ".AND. SD2->D2_CLIENTE >= '"+_par09+"' .And. SD2->D2_CLIENTE <= '"+_par10+"'"
//cCondicao += ".AND. SD2->D2_PEDIDO  >= '"+_par11+"' .And. SD2->D2_PEDIDO  <= '"+_par12+"'"
cCondicao += ".AND. DTOS(SD2->D2_EMISSAO) >= '"+DTOS(_par13)+"' .And. DTOS(SD2->D2_EMISSAO) <= '"+DTOS(_par14)+"'"
bFiltraBrw := {|| FilBrowse("SD2",@aIndSD2,@cCondicao) }
Eval(bFiltraBrw)

//³ Endereca a funcao de BROWSE                                  ³
_nVlrTot := 0
IF ( Eof() )
	MsgInfo("Nao há Informações para esta consulta")
	DBSELECTAREA("TRB")
	DBCLOSEAREA()
	FERASE(cArq+".DBF")
	FERASE(_cIndex+ordbagext())
	CriaTemp()
	CriaTem2()
	oBro:oBrowse:Refresh()
Else
	If _nRecRb == 1
		DBSELECTAREA("TRB")
		DBCLOSEAREA()
		FERASE(cArq+".DBF")
		FERASE(_cIndex+ordbagext())
		CriaTemp()
		CriaTem2()
	Endif
	dbSelectArea("SD2")
	While !Eof()
		_cCodFor := SD2->D2_FORNEC
		_nCusto   := 0
		_nVenda   := 0
		_nMarge   := 0   	
		While !Eof() .AND. SD2->D2_FORNEC == _cCodFor
			_nCusto := _nCusto + (SD2->D2_QUANT * SD2->D2_CUSDIP) //CUSTO1
			_nVenda := _nVenda + SD2->D2_TOTAL    
			IF _nCusto > 0
				_nMarge := _nMarge + Round(((SD2->D2_TOTAL/(SD2->D2_QUANT * SD2->D2_CUSDIP))-1)*100,4)
			ELSE 
			    DBSELECTAREA("SB1")
			    DBSETORDER(1)
			    DBSEEK(xFilial("SB1")+SD2->D2_COD)
//			    _nCusto2  := (SB1->B1_UPRC+(SB1->B1_UPRC*SB1->B1_IPI/100)) * SD2->D2_QUANT 
//			    _nCusto2  := (SB1->B1_CUSDIP) * SD2->D2_QUANT  // MCVN - 30/10/2008
//              _nCusto2  := (SB1->B1_LISFOR) * SD2->D2_QUANT  // MCVN - 26/03/2009
			    _nCusto2  := (SB1->B1_CUSDIP) * SD2->D2_QUANT  // MCVN - 02/04/2009
				_nMarge   := _nMarge + Round(((SD2->D2_TOTAL/_nCusto2)-1)*100,4)	 
				_nCusto2  := 0			
			ENDIF	
			dbSelectArea("SD2")
			DbSkip()
		END   
		DbSkip(-1) 
		DbSelectArea("SA2")
		DbSetOrder(1)
		DbSeek(xFilial("SA2")+_cCodFor)
		_cNomeFor := SA2->A2_NOME
		DbSelectArea("SD1")
		DbSetOrder(9)
		DbSeek(xFilial("SD1")+_cCodFor)
		_nNfEnt := 0
		While !Eof() .AND. SD1->D1_FORNECE == _cCodFor
			IF dtos(SD1->D1_DTDIGIT) < dtos(_par13) .OR. dtos(SD1->D1_DTDIGIT) > Dtos(_par14)
				DBSKIP()
				LOOP
			EndIf
			IF SD1->D1_COD < _par07 .OR. SD1->D1_COD > _par08
				DBSKIP()
				LOOP
			EndIf
			_nNfEnt := _nNfEnt + SD1->D1_TOTAL
			dbSelectArea("SD1")
			DbSkip()
		END
		DBSELECTAREA("TRB")
		RECLOCK("TRB",.T.)
		TRB->RB_CODFOR   := _cCodFor
		TRB->RB_NOMFOR   := _cNomeFor
		TRB->RB_VENDA    := _nVenda
		TRB->RB_CUSTO    := _nCusto 
		_nMarge := Round(((_nVenda/_nCusto)-1)*100,4)
		IF _nMarge < 9999
			TRB->RB_MARGEM   := _nMarge 
		ELSE 
			TRB->RB_MARGEM   := 0
		ENDIF	
		TRB->RB_NFENTR   := _nNfEnt
		MSUNLOCK()  
		_nRecRb  := 1 
		_nVezes  := _nVezes  + 1
		_nTotVen := _nTotVen + _nVenda		
		_nTotCus := _nTotCus + _nCusto  
		_nTotNfe := _nTotNfe + _nNfEnt		
		dbSelectArea("SD2")
		DbSkip()
	END       
	_nTotMar := Round(((_nTotVen/_nTotCus)-1)*100,4)	
	_cIndex:=Criatrab(Nil,.F.)
	_cChave:="RB_CODFOR"
	Indregua("TRB",_cIndex,_cchave,,,"Selecionando Registros...")
	dBSETINDEX(_cIndex+ordbagext())
	oBro:oBrowse:Refresh()
EndIF

//³Restaura a integridade da rotina                                ³
Return
************************

************************
Static Function CriaTemp()

_stru:={}      

AADD(_stru,{"RB_CODFOR","C",6,0})
AADD(_stru,{"RB_NOMFOR","C",40,0})
AADD(_stru,{"RB_VENDA","N",15,4})
AADD(_stru,{"RB_CUSTO","N",15,4})
AADD(_stru,{"RB_MARGEM","N",09,4})
AADD(_stru,{"RB_NFENTR","N",15,4})
cArq:=Criatrab(_stru,.T.)
DBUSEAREA(.T.,,cArq,"TRB")

Return
************************

************************
Static Function CriaTem2()

_aTrb := {}
AADD(_aTrb,{"RB_CODFOR","Codigo","@!"})
AADD(_aTrb,{"RB_NOMFOR","Nome","@!"})
AADD(_aTrb,{"RB_VENDA","Vendas","@E 99,999,999.9999"})
AADD(_aTrb,{"RB_CUSTO","Custo","@E 99,999,999.9999"})
AADD(_aTrb,{"RB_MARGEM","Margem","@E 9999.9999"})
AADD(_aTrb,{"RB_NFENTR","N.F. Entrada","@E 99,999,999.9999"})

Return
**************

***************
Static Function OK()

Local _xAlias  := GetArea()

// Eriberto 13/02/2006 close(oDlg1)
DBSELECTAREA("TRB")
DBCLOSEAREA()
FERASE(cArq+".DBF")
FERASE(_cIndex+ordbagext())

RestArea(_xAlias)

Return
**************

**************
Static Function Rept(_cRept)

Local _xAlias  := GetArea()

If _cRept == 0
	_par13 := _par14
Elseif _cRept == 1
	_par02 := _par01
Elseif _cRept == 2
	_par04 := _par03
Elseif _cRept == 3
	_par06 := _par05
	_loj4  := _loj3
Elseif _cRept == 4
	_par08 := _par07
Elseif _cRept == 5
	_par10 := _par09
	_loj2  := _loj1
Elseif _cRept == 6
	_par12 := _par11
Elseif _cRept == 7
	_par02 := _par01
	_par04 := _par03
	_par06 := _par05
	_loj4  := _loj3
	_par08 := _par07
	_par10 := _par09
	_loj2  := _loj1
	_par12 := _par11  
	_par14 := _par13
Endif

RestArea(_xAlias)

Return      

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Funcao    ³ Imprimir  ³ Autor ³ Rodrigo Franco    ³ Data ³ 08.05.2002  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Relatorio de Vendas Por fornecedor                         ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Imprimir()

//³ Define Variaveis                                             ³
LOCAL wnrel
LOCAL tamanho:="M"
LOCAL titulo:="Relação de Vendas Por fornecedor"
LOCAL cDesc1:="Relação de Vendas Por fornecedor de acordo com"
LOCAL cDesc2:="intervalo informado na opcao do Parametros."
LOCAL cDesc3:=" "
LOCAL nRegistro:= 0
LOCAL cKey,nIndex,cIndex  //&& Variaveis para a criacao de Indices Temp.
LOCAL cCondicao
//cPerg  := "DIPR13"
PRIVATE aReturn  := { "Zebrado", 1,"Administracao", 2, 2, 1, "",0 }
PRIVATE nomeprog := "DIPA018",nLastKey := 0,nBegin:=0,aLinha:={ }
PRIVATE li:=90,limite:=132,lRodape:=.F.,cPictQtd:=""
PRIVATE nTotQtd:=nTotVal:=0
PRIVATE aPedCli:= {}
wnrel    := "DIPA018"
cString  := "TRB"
PRIVATE nNItem := 0
//³ Verifica as perguntas selecionadas                          ³
//pergunte(cPerg,.T.)

//³ Variaveis utilizadas para parametros		                ³
//³ mv_par01	     	  DA DATA	    	                    ³
//³ mv_par02	     	  ATE A DATA	    	                ³
//³ mv_par03	     	  DO FORNECEDOR   	                    ³
//³ mv_par04	     	  ATE O FORNECEDOR    	                ³
wnrel:=SetPrint(cString,wnrel,,@Titulo,cDesc1,cDesc2,cDesc3,.F.,,,Tamanho)
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

LOCAL tamanho:= "M"
LOCAL titulo:="Relação de Vendas Por fornecedor"
LOCAL cDesc1:="Relação de Vendas Por fornecedor de acordo com"
LOCAL cDesc2:="intervalo informado na opcao do Parametros."
LOCAL cDesc3:=" "
LOCAL nRegistro:= 0
LOCAL cKey,nIndex,cIndex  && Variaveis para a criacao de Indices Temp.
LOCAL cCondicao

//³ Faz manualmente porque nao chama a funcao Cabec()                 ³
@ 0,0 psay AvalImp(Limite)
DbSelectArea("TRB")
li := 1
Pg := 51
_cValorT := 0
While !Eof()    
    _cICodFor  := TRB->RB_CODFOR
	_cINomeFor := TRB->RB_NOMFOR
	_nIVenda   := TRB->RB_VENDA
	_nICusto   := TRB->RB_CUSTO
	_nIMarge   := TRB->RB_MARGEM
	_nINfEnt   := TRB->RB_NFENTR
	ImpCabec()
	DBSELECTAREA("TRB")
	DBSKIP()
End
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
	@ li,000 psay Replicate("-",132)
	li++
	@ li,000 psay "DIPROMED COMERCIO E IMPORTACAO LTDA.  "
	cEMISSAO:=DTOC(dDATABASE)+' '+SUBS(TIME(),1,5)
	@ li,132-LEN(cEMISSAO) psay cEMISSAO
	li++
	@ li,000 psay Replicate("-",132)
	li++
	@ li,INT((132-LEN("*** Relatorio de Vendas Por fornecedor ***"))/2) psay "*** Relatorio de Vendas Por fornecedor ***"
	li++
	@ li,000 psay Replicate("-",132)
	li := li + 1
	@ li,000 psay Replicate("-",132)
	li++
	@ li,INT((132-LEN("DE 01/10/04 ATE 01/11/04"))/2) psay "DE " + DTOC(_par13) + " ATE " + DTOC(_par14)
	li++
	@ li,000 psay Replicate("-",132)
	li++
	@ li,000 psay "|Fornecedor                                          |Venda             |Custo             |Margem     |N.F Entrada       |"
	li++      //    080808 - franconsultoria info                        97.112.235,2399  97.112.235,2399  235,2399  97.112.235,2399
	@ li,000 psay Replicate("-",132)
	li++
Endif
li++
@ li,001 psay _cICodFor + " - " + _cINomeFor + "       " + TRANSF(_nIVenda,"@E 99,999,999.9999") + "    " + TRANSF(_nICusto,"@E 99,999,999.9999") + "    " + TRANSF(_nIMarge,"@E 999.9999") + "    " + TRANSF(_nINfEnt,"@E 99,999,999.9999")
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
	@ li,000 psay Replicate("-",132)
	li++
	@ li,000 psay "DIPROMED COMERCIO E IMPORTACAO LTDA.  "
	cEMISSAO:=DTOC(dDATABASE)+' '+SUBS(TIME(),1,5)
	@ li,132-LEN(cEMISSAO) psay cEMISSAO
	li++
	@ li,000 psay Replicate("-",132)
	li++
	@ li,INT((132-LEN("*** Relatorio de Vendas Por fornecedor ***"))/2) psay "*** Relatorio de Vendas Por fornecedor ***"
	li++
	@ li,000 psay Replicate("-",132)
	li := li + 1
	@ li,000 psay Replicate("-",132)
	li++
	@ li,INT((132-LEN("DE 01/10/04 ATE 01/11/04"))/2) psay "DE " + DTOC(_par13) + " ATE " + DTOC(_par14)
	li++
	@ li,000 psay Replicate("-",132)
	li++
	@ li,000 psay "|Fornecedor                                        |Venda           |Custo           |Margem   |N.F Entrada     |"
	li++      //    080808 - franconsultoria info                      97.112.235,2399  97.112.235,2399  235,2399  97.112.235,2399
	@ li,000 psay Replicate("-",132)
	li++
Endif
li++
li++
@ li,001 psay "TOTAL:                                               R$ " + TRANSF(_nTotVen,"@E 99,999,999.9999")  + " R$ " + TRANSF(_nTotCus,"@E 99,999,999.9999") + "    " + TRANSF(_nTotMar,"@E 999.9999")+ " R$ " + TRANSF(_nTotNfe,"@E 99,999,999.9999")
Pg := Pg + 1

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Funcao    ³ DIPR042 ³ Autor ³Rafael de Campos Falco ³ Data ³ 17/09/2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Relatório Faturamento diário                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ DIPR042                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Especifico DIPROMED                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
#include "Protheus.ch"
#include "rwmake.ch"
#INCLUDE "TOPCONN.CH"

User Function DipR042()
//--------------------------------------------------------------------------------------------------
// JBS 23/03/2010 - Tratamento para trabalhar com as duas versoes do programa:
//--------------------------------------------------------------------------------------------------
// -> fDipR042(): Eh a versao anterior, desenvolvida para processar a aperna uma
//                empresa. Ficar para processar a empresa Health Quality MAtriz
//--------------------------------------------------------------------------------------------------
// -> DIPR042A(): Eh uma versao que trabalha com query, desenvolvidas para trabalhar
//                com o CD Dipromed e o CD Health Quality.                         
//--------------------------------------------------------------------------------------------------
If cEmpAnt == '04' .and. cFilAnt == '01' 
    fDipR042() // Versao Anterior, para rodar apenas para a Health Quality (Matriz)
Else                                                                                 
	If MsgYesNo("Gerar Relatório Gráfico? Sim = Gráfico / Nao = Padrão?","ATENCAO!")
	    U_DIPR042B() 	
	Else
    	U_DipR042a() // Chama a versao MultyEmpresas.
	EndIf    
EndIf

Return(Nil)    
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³fDipR042()ºAutor ³Rafael de Campos FalcoºData ³ 17/09/2003  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Versao do programa para rodar uma empresa, a matriz da     º±±
±±º          ³ Health Quality.                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Especifico - Dipromed - Faturamento                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function fDipR042()

Local oDlg
Local _xArea	:= GetArea()
Local titulo	:= OemTOAnsi("Faturamento Diário",72)
Local cDesc1	:= OemToAnsi("Este programa tem como objetivo emitir um relat¢rio",72)
Local cDesc2	:= OemToAnsi("do faturamento diário separado por",72)
Local cDesc3	:= OemToAnsi("Público, Particular, Prefeitura, Representantes, Televendas.",72)
Local nOpcao    := 0          
Local cCodDip   := '000001' // MCVN - 04/05/09
Local cCodTel   := '000002' // MCVN - 04/05/09  
Local cCodPar   := '000003' // MCVN - 04/05/09  
Local cCodPub   := '000004' // MCVN - 04/05/09  
Local cCodRep   := '000005' // MCVN - 04/05/09    
Local cUserAut  := GetMV("MV_URELFAT")// MCVN - 04/05/09  

Private aReturn    := {"Bco A4", 1,"Financeiro", 1, 2, 1,"",1}
Private li         := 80
Private tamanho    := "G"
Private limite     := 220
Private nomeprog   := "DIPR042"

// Private cPerg      := "DIPR42"
// FPADR(cPerg, cArq, cCampo, cTipo)  - Para ajustar o tamanho das perguntas no SX1- uso generico
PRIVATE cPerg  	:= U_FPADR( "DIPR42","SX1","SX1->X1_GRUPO"," " ) //Função criada por Sandro em 19/11/09.

Private nLastKey   := 0
Private lEnd       := .F.
Private lContinua  := .T.
Private wnrel      := "DIPR042"
Private cString    := "SE1"
Private m_pag      := 1
Private _aEmiFat   := {}
Private _aEmiPed   := {}
Private _aFeriad   := {}
Private _aNaoFatDip:= {}
Private _aAcuFat   := {}
Private _aPedLib   := {} 
Private _aNodia    := {}
Private _nDiasCom  := 0
Private _nDiasSem  := 0
PRIVATE cFornVend  := AllTrim(GETNEWPAR("MV_FORNVEN",""))
Private cMes       := Space(2)
Private cAno       := Space(4)
Private cCodVend   := Space(40)     // Codigos de fornecedores a serem impressos - JBS 06/08/2010
Private cCodForn   := Space(40)     // Codigos de fornecedores a serem impressos - JBS 06/08/2010
Private nMetTel    := 0
Private nMetRep    := 0
Private nMetPar    := 0
Private nMetPub    := 0
Private nMetDip    := 0
Private cOper      := Space(254)
Private _cDiaTot   := CtoD("")      // Eriberto 18/04/2007
Private _nTotDia   := 0             // Eriberto 18/04/2007
Private _lUltDia   := .t.           // Eriberto 18/04/2007 
Private lValor     := .F.          // MCVN - 04/05/09    
Private cVendInt   := GetMV("MV_DIPVINT")// MCVN - 06/05/09
Private cVendExt   := GetMV("MV_DIPVEXT")// MCVN - 06/05/09   
Private cVendPub   := GetMV("MV_DIPVPUB")// MCVN - 19/08/10
//-------------------------------------------------------------------------------------------------- 
Private _aHQ_CD    := {} // Faturamento sintetico HQ CD p/ os fornecedores $ '000851/000847/051508'                          
Private _cDipusr   := U_DipUsr()

cFornVend += "\000996" // Não coloquei no parametro por que ele é utilizado em outras rotinas

// JBS 15/06/2010
//--------------------------------------------------------------------------------------------------
/*If !(Upper(_cDipusr) $ cUserAut .Or. Upper(_cDipusr) $ cVendInt .or. Upper(_cDipusr) $ cVendExt .or. Upper(_cDipusr) $ cVendPub) // MCVN - 19/08/10
	Alert(Upper(_cDipusr)+", você não tem autorização para utilizar esta rotina. Qualquer dúvida falar com Eriberto!","Atenção")	
	Return()
Endif*/

//If (Upper(_cDipusr) $ cUserAut .Or. Upper(_cDipusr) $ cVendInt .or. Upper(_cDipusr) $ cVendExt .or. Upper(_cDipusr) $ cVendPub) // MCVN - 19/08/10
	lValor := MsgBox("Deseja gerar relatórios com valores?","Atenção","YESNO")	
//Endif
     
     
U_DIPPROC(ProcName(0),_cDipusr) // JBS 05/10/2005 - Gravando o nome do Programa no SZU

SX1->(DipPergDiverg(.t.)) // Verifica se existe o no SX1 o "DIPR42". Retorna os Valores ou cria

Define msDialog oDlg title OemToAnsi("Faturamento Diário") From 10,10 TO 22,43

@ 002,002 to 090,130

@ 010,010 say "Informe o mes       "
@ 025,010 say "Informe o ano       "
@ 040,010 say "Informe o Vendedor  "
@ 055,010 say "Informe o Fornecedor"

@ 010,070 get cMes valid cMes>='01'.and.cMes<='12' Size 10,08
@ 025,070 get cAno valid !empty(cAno) size 20,08
@ 040,070 get cCodVend F3 'SA3' Size 30,08
@ 055,070 get cCodForn F3 'SA2' size 30,08


Define sbutton oBt1 from 075,065 type 1 action (nOpcao := 1, oDlg:End()) enable of oDlg
Define sbutton oBt2 from 075,097 type 2 action (nOpcao := 0, oDlg:End()) enable of oDlg

Activate Dialog oDlg Centered

If nOpcao = 0
	Return(.t.)
EndIf
 

SZF->(DbSelectArea("SZF"))// RBorges 11/11/14
SZF->(DbSetOrder(1))      // RBorges 11/11/14

nMetTel    := Posicione("SZF",1,xFilial("SZF")+cCodTel+(cMes+"/"+cAno),"ZF_META")// MCVN - 04/05/09
nMetRep    := Posicione("SZF",1,xFilial("SZF")+cCodRep+(cMes+"/"+cAno),"ZF_META")// MCVN - 04/05/09
nMetPar    := Posicione("SZF",1,xFilial("SZF")+cCodPar+(cMes+"/"+cAno),"ZF_META")// MCVN - 04/05/09
nMetPub    := Posicione("SZF",1,xFilial("SZF")+cCodPub+(cMes+"/"+cAno),"ZF_META")// MCVN - 04/05/09    
nMetDip    := Posicione("SZF",1,xFilial("SZF")+cCodDip+(cMes+"/"+cAno),"ZF_META")// MCVN - 04/05/09
OperadorPub() // MCVN - 06/08/09

SX1->(DipPergDiverg(.f.))

wnrel := SetPrint(cString,wnrel,cPerg,Titulo,cDesc1,cDesc2,cDesc3,.f.,,.f.,tamanho,,.f.,,,,,)

If nLastKey == 27
	Return
Endif

SetDefault(aReturn,cString)

Processa({|lEnd| RunProc()},"Selecionando dados...")

RptStatus({|lEnd| RptDetail()},"Imprimindo...")

RestArea(_xArea)

Return

//////////////////////////////////////////////////////////////////////
Static Function RunProc() 
Local _x
Local xi
_cFim := "31"
_dDatFim := _dEmiAtu := _dEmiIni := ""
_nPar   := _nPub   := _nPre   := _nRep   := _nTel   := _nTot   := 0
_nAcPar := _nAcPub := _nAcPre := _nAcRep := _nAcTel := _nAcTot := 0
_nAcCol := _nAcLib := _nAcFat := _nAcEst := _nAcCre := _nAcOpe := 0
_nColPed:= _nLibPed:= _nFatPed:= _nEstPed:= _nCrePed:= _nOpePed:= 0
_nPVLPar:= _nPVLPub:= _nPVLPre:= _nPVLRep:= _nPVLTel:= _nPVLTot:= 0
_nDIAPar:= _nDIAPub:= _nDIAPre:= _nDIARep:= _nDIATel:= _nDIATot:= 0 


// Montagem do array com feriados
dbSelectArea("SX5")
dbSetOrder(1)
dbSeek(xFilial("SX5")+"63")
While X5_TABELA == "63"
	If SubStr(X5_DESCRI,1,1) != "*"
		If Len(Alltrim(SubStr(X5_DESCRI,1,8))) <> 8
			cTemp := SubStr(X5_DESCRI,1,5)+"/"+AllTrim(cAno)
		Else
			cTemp := SubStr(X5_DESCRI,1,At(" ",X5_DESCRI)-1)
		EndIf
		Aadd(_aFeriad,{cTOD(AllTrim(cTemp))})
	EndIf
	SX5->(DbSkip())
EndDo
                        
//MOnta array com os dias não uteis para efeito de faturamento na HQ
DbSelectArea("SX5")
DbSetOrder(1)
DbSeek(xFilial("SX5")+"Z2")

Do While X5_TABELA == "Z2"	
	If SubStr(X5_DESCRI,1,1) != "*"
		If Len(Alltrim(SubStr(X5_DESCRI,1,8))) <> 8
			cTemp := SubStr(X5_DESCRI,1,5)+"/"+AllTrim(cAno)
		Else
			cTemp := SubStr(X5_DESCRI,1,At(" ",X5_DESCRI)-1)
		EndIf
		Aadd(_aNaoFatDip,{cTOD(AllTrim(cTemp))})
	EndIf
	SX5->(DbSkip())
EndDo


ProcRegua(500)
For _x := 1 to 150
	IncProc( "Processando...VENDAS ")
Next

//*********************** QUERY DO FATURAMENTO GERAL **************************************
//QRY1 := "SELECT DISTINCT F2_DOC, F2_VALFAT, F2_EMISSAO, F2_VEND1, F2_VEND2, C5_OPERADO, U7_CODVEN, F2_CLIENTE"
QRY1 := "SELECT F2_DOC, CASE F4_DUPLIC WHEN 'S' THEN D2_TOTAL + D2_SEGURO + D2_VALFRE + D2_DESPESA + D2_ICMSRET ELSE D2_SEGURO + D2_VALFRE + D2_DESPESA + D2_ICMSRET  END AS F2_VALFAT,F2_EMISSAO,F2_VEND1, F2_VEND2,C5_EMPENHO, C5_EDITAL, C5_OPERADO, U7_CODVEN, F2_CLIENTE, D2_FORNEC "
QRY1 += " FROM " +  RetSQLName('SF2')
QRY1 += " INNER JOIN "+ RetSQLName('SD2') + ' ON '
QRY1 += RetSQLName('SF2') + ".F2_FILIAL = " + RetSQLName('SD2') + ".D2_FILIAL AND "
QRY1 += RetSQLName('SF2') + ".F2_DOC = " + RetSQLName('SD2') + ".D2_DOC AND "
QRY1 += RetSQLName('SF2') + ".F2_SERIE = " + RetSQLName('SD2') + ".D2_SERIE AND "
QRY1 += RetSQLName('SD2') + ".D_E_L_E_T_ = ' '  "
QRY1 += " INNER JOIN "+ RetSQLName('SC5') + ' ON '
QRY1 += RetSQLName('SD2') + ".D2_FILIAL = " + RetSQLName('SC5') + ".C5_FILIAL AND "
QRY1 += RetSQLName('SD2') + ".D2_PEDIDO = " + RetSQLName('SC5') + ".C5_NUM  AND "
QRY1 += RetSQLName('SC5') + ".D_E_L_E_T_ = ' ' "
QRY1 += " LEFT JOIN "+ RetSQLName('SU7') + ' ON '
//QRY1 += RetSQLName('SF2') + ".F2_VEND1 *= " + RetSQLName('SU7') + ".U7_CODVEN AND "
QRY1 += RetSQLName('SF2') + ".F2_VEND1 = " + RetSQLName('SU7') + ".U7_CODVEN AND "
QRY1 += RetSQLName('SU7') + ".D_E_L_E_T_ = ' ' "
QRY1 += " INNER JOIN "+ RetSQLName('SF4') + ' ON '
QRY1 += RetSQLName('SD2') + ".D2_TES = " + RetSQLName('SF4') + ".F4_CODIGO AND "
QRY1 += "( F4_DUPLIC = 'S' OR D2_SEGURO + D2_VALFRE + D2_DESPESA + D2_ICMSRET  > 0 ) AND "
QRY1 += RetSQLName('SF4') + ".F4_FILIAL = '"+xFilial("SF4")+"' AND "
QRY1 += RetSQLName('SF4') + ".D_E_L_E_T_ = ' ' "
QRY1 += " WHERE LEFT("+RetSQLName('SF2') + ".F2_EMISSAO,6) = '" + cAno + cMes + "' AND "
//---------------------------------------------------------------------------------------------------------------------------
// JBS 16/06/2010 - Fornecedores Vendas HQ CD.
// Esta condicao farah com que traga informacoes de vendas dos fornecedores informados na filial HQ_CD.
//---------------------------------------------------------------------------------------------------------------------------
// JBS 21/07/2010 Nao excluir QRY1 += "( F2_FILIAL = '" + xFilial("SF2") + "' or ( F2_FILIAL = '04' and D2_FORNEC in ('000851','000847','051508') )) and "
QRY1 += " F2_FILIAL = '" + xFilial("SF2") + "' and " //or ( F2_FILIAL = '04' and D2_FORNEC in ('000851','000847','051508') )) and "
//---------------------------------------------------------------------------------------------------------------------------
QRY1 += RetSQLName('SF2') + ".F2_TIPO IN ('N','C') AND "
//-----------------------------------------------------------------------------------------
// Tratamento para fazer o filtro por vendedor  - JBS 06/08/2010
//-----------------------------------------------------------------------------------------
If !Empty(cCodVend)
    Qry1 += RetSQLName('SF2') + ".F2_VEND1 = '" + cCodVend + "' AND "
EndIf
//-----------------------------------------------------------------------------------------
//  Tratamento para fazer o filtro por fornecedor - JBS 06/08/2010
//-----------------------------------------------------------------------------------------
If !Empty(cCodForn)
    Qry1 += RetSQLName('SD2') + ".D2_FORNEC = '" + cCodForn + "' AND "
EndIf
// Filtro listven  MCVN - 06/05/09
/*If lValor
	If U_ListVend() != ''   
		If Upper(_cDipusr) $ cVendInt    
			nMetRep     := 0
			nMetPar     := 0
			nMetPub     := 0  
		ElseIf Upper(_cDipusr) $ cVendExt
			nMetTel     := 0
		Endif
		QRY1 += " C5_VEND1 " + U_ListVend()+" AND "
	EndIf
Endif*/

If lValor
	If U_ListVend() != ''   
		If Upper(_cDipusr) $ cVendInt    
			nMetRep     := 0
			nMetPar     := 0
			nMetPub     := 0  
		ElseIf Upper(_cDipusr) $ cVendExt
			nMetTel     := 0
		Endif
//		QRY1 += " C5_VEND1 " + U_ListVend()+" AND "
		QRY1 += " F2_VEND1 " + U_ListVend()+" AND "
	EndIf
	// Filtro ListOper (OPERADOR) MCVN - 19/08/10
	If U_ListOper() != ''   
		If Upper(_cDipusr) $ cVendInt    
			nMetRep     := 0
			nMetPar     := 0
			nMetPub     := 0  
		ElseIf Upper(_cDipusr) $ cVendExt
			nMetTel     := 0  
			nMetPub     := 0  
		ElseIf Upper(_cDipusr) $ cVendPub
			nMetTel     := 0  
			nMetRep     := 0
			nMetPar     := 0
		Endif
		QRY1 += " C5_OPERADO " + U_ListOper()+" AND "
	EndIf
Endif     
QRY1 += RetSQLName('SF2') + ".D_E_L_E_T_ = ' ' "
QRY1 += "ORDER BY F2_EMISSAO"
TcQuery QRY1 NEW ALIAS "QRY1"         // Abre uma workarea com o resultado da query
memowrite('DIPR42SD2' + cEmpAnt+'0'+cFilAnt + '.SQL',QRY1)

For _x := 1 to 150
	IncProc( "Processando... DEVOLUÇÃO")
Next

//********************************** QUERY DAS DEVOLUÇÕES **************************************
//QRY2 := "SELECT D1_DOC, D1_DTDIGIT, D1_TES, C5_OPERADO, U7_CODVEN, C5_VEND1, C5_VEND2, C5_CLIENTE, SUM(D1_TOTAL+D1_VALFRE+D1_SEGURO+D1_DESPESA) D1_TOTAL"
QRY2 := "SELECT D1_DOC, D1_DTDIGIT, D1_TES, C5_EMPENHO, C5_EDITAL,C5_OPERADO, U7_CODVEN, F2_VEND1, F2_VEND2, C5_CLIENTE, "
QRY2 += "  SUM(CASE F4_DUPLIC WHEN 'S' THEN D1_TOTAL+D1_VALFRE+D1_SEGURO+D1_DESPESA+D1_ICMSRET  ELSE D1_VALFRE+D1_SEGURO+D1_DESPESA+D1_ICMSRET  END) AS D1_TOTAL, D2_FORNEC "
QRY2 += " FROM "+  RetSQLName('SD1') + ' ' 
QRY2 += " INNER JOIN "+ RetSQLName('SD2') + ' ON ' 
QRY2 += RetSQLName('SD1') + ".D1_FILIAL = " + RetSQLName('SD2') + ".D2_FILIAL AND "
QRY2 += RetSQLName('SD1') + ".D1_NFORI = " + RetSQLName('SD2') + ".D2_DOC AND "
QRY2 += RetSQLName('SD1') + ".D1_SERIORI = " + RetSQLName('SD2') + ".D2_SERIE AND "
QRY2 += RetSQLName('SD1') + ".D1_ITEMORI = " + RetSQLName('SD2') + ".D2_ITEM AND "
QRY2 += RetSQLName('SD2') + ".D_E_L_E_T_ = ' ' "
QRY2 += " INNER JOIN "+ RetSQLName('SC5') + ' ON '
QRY2 += RetSQLName('SD2') + ".D2_FILIAL = " + RetSQLName('SC5') + ".C5_FILIAL AND "
QRY2 += RetSQLName('SD2') + ".D2_PEDIDO = " + RetSQLName('SC5') + ".C5_NUM AND "
QRY2 += RetSQLName('SC5') + ".D_E_L_E_T_ = ' ' "
QRY2 += " INNER JOIN "+ RetSQLName('SF4') +' ON '
QRY2 += RetSQLName('SD1') + ".D1_TES = " + RetSQLName('SF4') + ".F4_CODIGO AND "
QRY2 += "( F4_DUPLIC = 'S' or D1_VALFRE+D1_SEGURO+D1_DESPESA+D1_ICMSRET  > 0 ) AND "
// Eriberto 02/03/2010
QRY2 += RetSQLName('SF4') + ".F4_FILIAL = '"+xFilial("SF4")+"' AND "
QRY2 += RetSQLName('SF4') + ".D_E_L_E_T_ = ' ' "
QRY2 += " INNER JOIN "+  RetSQLName('SF2') + " ON "
//-----------------------------------------------------------------------------------------
// Tratamento para fazer o filtro por vendedor  - JBS 06/08/2010
//-----------------------------------------------------------------------------------------
Qry2 += RetSQLName('SF2') + ".F2_FILIAL = " + RetSQLName('SD2') + ".D2_FILIAL AND "
Qry2 += RetSQLName('SF2') + ".F2_DOC    = " + RetSQLName('SD2') + ".D2_DOC    AND "
Qry2 += RetSQLName('SF2') + ".F2_SERIE  = " + RetSQLName('SD2') + ".D2_SERIE  "
QRY2 += " LEFT JOIN "+ RetSQLName('SU7') + ' ON ' 
//QRY2 += RetSQLName('SF2') + ".F2_VEND1 *= " + RetSQLName('SU7') + ".U7_CODVEN AND "
QRY2 += RetSQLName('SF2') + ".F2_VEND1 = " + RetSQLName('SU7') + ".U7_CODVEN AND "
QRY2 += RetSQLName('SU7') + ".D_E_L_E_T_ = ' ' "
QRY2 += " WHERE " + RetSQLName('SD1') + ".D1_TIPO = 'D' AND "
QRY2 += " LEFT(" + RetSQLName('SD1') + ".D1_DTDIGIT,6) = '" + cAno + cMes + "' AND "
// Eriberto 02/03/2010                    
// QRY2 += RetSQLName('SD1') + ".D1_FILIAL = '"+xFilial("SD1")+"' AND "
//---------------------------------------------------------------------------------------------------------------------------
// JBS 16/06/2010 - Fornecedores Vendas HQ CD.
// Esta condicao farah com que traga informacoes de vendas dos fornecedores informados na filial HQ_CD.
//---------------------------------------------------------------------------------------------------------------------------
// JBS 21/07/2010 Nao Excluir QRY2 += "( D1_FILIAL = '" + xFilial("SD1") + "' or ( D1_FILIAL = '04' and D2_FORNEC in ('000851','000847','051508') )) and "
QRY2 += " D1_FILIAL = '" + xFilial("SD1") + "' and "//or ( D1_FILIAL = '04' and D2_FORNEC in ('000851','000847','051508') )) and "
//---------------------------------------------------------------------------------------------------------------------------
// Filtro listven  MCVN - 06/05/09
If U_ListVend() != ''
	QRY2 += " F2_VEND1 " + U_ListVend()+" AND "                             
EndIf       
// Filtro listOper  MCVN - 19/08/10
If U_ListOper() != ''
	QRY2 += " C5_OPERADO " + U_ListOper()+" AND "
EndIf
If !Empty(cCodVend)
    Qry2 += RetSQLName('SF2') + ".F2_VEND1 = '" + cCodVend + "' AND "
EndIf
//-----------------------------------------------------------------------------------------
//  Tratamento para fazer o filtro por fornecedor - JBS 06/08/2010
//-----------------------------------------------------------------------------------------
If !Empty(cCodForn)
    Qry2 += " " + RetSQLName('SD2') + ".D2_FORNEC = '" + cCodForn + "' AND "
EndIf
QRY2 += RetSQLName('SD1') + ".D_E_L_E_T_ = ' '  "
QRY2 += "GROUP BY D1_DOC, D1_DTDIGIT, D1_TES, C5_EMPENHO, C5_EDITAL,C5_OPERADO, U7_CODVEN, F2_VEND1, F2_VEND2, C5_CLIENTE, D2_FORNEC "
QRY2 += "ORDER BY D1_DTDIGIT"
TcQuery QRY2 NEW ALIAS "QRY2"         // Abre uma workarea com o resultado da query
memowrite('DIPR42SD1' + cEmpAnt+'0'+cFilAnt + '.SQL',QRY2)

For _x := 1 to 150
	IncProc( "Processando... PEDIDOS")
Next

//********************************** QUERY DOS PEDIDOS **************************************
QRY3 := "SELECT C5_EMISSAO, C5_PARCIAL, C9_CLIENTE, C9_OPERADO, U7_CODVEN, C9_VEND, C9_PARCIAL, C9_BLEST,C9_DATALIB, C9_BLCRED, C9_BLCRED2, SUM(C9_QTDLIB*C9_PRCVEN) C9_VALOR, C9_SALDO, C5_OPERADO"
QRY3 += " FROM " +  RetSQLName('SC9') + ' SC9 ' 
QRY3 += " INNER JOIN "+ RetSQLName('SC6') + ' SC6 ON '
QRY3 += " C9_FILIAL = C6_FILIAL AND "
QRY3 += " C9_PEDIDO = C6_NUM AND "
QRY3 += " C9_ITEM   = C6_ITEM AND "
QRY3 += " SC6.D_E_L_E_T_ = ' '  "
QRY3 += " INNER JOIN "+ RetSQLName('SC5') + ' SC5 ON '
QRY3 += " C9_FILIAL = C5_FILIAL AND "
QRY3 += " C9_PEDIDO = C5_NUM  AND "
QRY3 += " SC5.D_E_L_E_T_ = ' ' "
QRY3 += " INNER JOIN "+ RetSQLName('SF4') + ' SF4 ON '
QRY3 += " C6_TES    = F4_CODIGO AND "
QRY3 += " F4_FILIAL = '"+xFilial("SF4")+"' AND "
QRY3 += " SF4.D_E_L_E_T_ = ' ' "
QRY3 += " LEFT JOIN " + RetSQLName('SU7') +' SU7 ON '
//QRY3 += "C5_VEND1 *= U7_CODVEN AND "
QRY3 += " C5_VEND1 = U7_CODVEN AND "
QRY3 += " SU7.D_E_L_E_T_ = ' ' "
QRY3 += " WHERE (LEFT(C5_EMISSAO,6) = '" + cAno + cMes + "' or ((C9_BLEST = '  ' or C9_BLEST = '02') and C5_PARCIAL = ' ' and C9_SALDO = 0 and C9_BLCRED = '  ' and C9_BLCRED2 = '  ')) AND "
// Eriberto 02/03/2010
//QRY3 += RetSQLName('SC5') + ".C5_FILIAL = '"+xFilial("SC5")+"' AND "
//---------------------------------------------------------------------------------------------------------------------------
// JBS 16/06/2010 - Fornecedores Vendas HQ CD.
// Esta condicao farah com que traga informacoes de vendas dos fornecedores informados na filial HQ_CD.
//---------------------------------------------------------------------------------------------------------------------------
// JBS 21/07/2010  deixado para posterior uso QRY3 += "( C5_FILIAL = '" + xFilial("SC5") + "' or ( C5_FILIAL = '04' and C9_FORNEC in ('000851','000847','051508') )) and "
QRY3 += " C5_FILIAL = '" + xFilial("SC5") + "' and " //or ( C5_FILIAL = '04' and C9_FORNEC in ('000851','000847','051508') )) and "
//---------------------------------------------------------------------------------------------------------------------------
QRY3 += "C5_TIPO   = 'N' AND "
QRY3 += "F4_DUPLIC = 'S' AND "
// Filtro listven  MCVN - 06/05/09
If U_ListVend() != ''
	QRY3 += " C5_VEND1 " + U_ListVend()+" AND "
EndIf         
// Filtro listOper  MCVN - 19/08/10
If U_ListOper() != ''
	QRY3 += " C5_OPERADO " + U_ListOper()+" AND "
EndIf
//-----------------------------------------------------------------------------------------
// Tratamento para fazer o filtro por vendedor  - JBS 06/08/2010
//-----------------------------------------------------------------------------------------
If !Empty(cCodVend)
    Qry3 += " SC5.C5_VEND1 = '" + cCodVend + "' AND "
EndIf
//-----------------------------------------------------------------------------------------
//  Tratamento para fazer o filtro por fornecedor - JBS 06/08/2010
//-----------------------------------------------------------------------------------------
If !Empty(cCodForn)
    Qry3 += " SC9.C9_FORNEC = '" + cCodForn + "' AND "
EndIf
QRY3 += "SC9.D_E_L_E_T_ = ' '  "
QRY3 += "GROUP BY C5_EMISSAO, C5_PARCIAL, C9_CLIENTE, C9_OPERADO, U7_CODVEN, C9_VEND, C9_PARCIAL, C9_BLEST, C9_DATALIB, C9_BLCRED, C9_BLCRED2, C9_SALDO, C5_OPERADO "
QRY3 += "ORDER BY C5_EMISSAO"
TcQuery QRY3 NEW ALIAS "QRY3"         // Abre uma workarea com o resultado da query
memowrite('DIPR42SC9' + cEmpAnt+'0'+cFilAnt + '.SQL',QRY3)

// Preenchendo o array com todos os dias do mês, exceto sábados, domingos e feriados
_dEmiIni := ctod( "01" + "/" + cMes + "/" + Substr(cAno,3,2 ))
// Acha último dia do mês
_dFim := U_LastDay(_dEmiIni)

For xi:=1 to Val(SubStr(dTOc(_dFim),1,2))
	_nPos := Ascan(_aFeriad,{|y| y[1] == _dEmiIni}) // Verifica se data é um Feriado
	
	If _nPos == 0
		_nPos := Ascan(_aNaoFatDip,{|y| y[1] == _dEmiIni})  // Verifica se data não é um dia útil para efeito de faturamento
	Endif
	
	If _nPos == 0 	// Se a data for um feriado despreza o dia
		If (AllTrim(cDow(_dEmiIni)) <> "Saturday") // Descarta qdo. for Sábado
			If (AllTrim(cDow(_dEmiIni)) <> "Sunday")// Descarta qdo. for Domingo
				Aadd(_aEmiFat,{_dEmiIni,0,0,0,0,0,0,0})
				Aadd(_aEmiPed,{_dEmiIni,0,0,0,0,0,0,0})
			EndIf
		EndIf
	EndIf
	_dEmiIni++
Next

ProcRegua(3000)
For _x := 1 to 500
	IncProc( "Processando... Dados vendas")
Next

// Posicionando no primeiro registro
DbSelectArea("QRY1")
DbGoTop()

Do While QRY1->(!Eof())
	IncProc( "Processando... Dados vendas")
	
	_dEmiAtu := Ctod(Substr(QRY1->F2_EMISSAO,7,2)+"/"+Substr(QRY1->F2_EMISSAO,5,2)+"/"+Substr(QRY1->F2_EMISSAO,1,4))
	// Loop para totalizar o dia
	Do While _dEmiAtu == Ctod(Substr(QRY1->F2_EMISSAO,7,2)+"/"+Substr(QRY1->F2_EMISSAO,5,2)+"/"+Substr(QRY1->F2_EMISSAO,1,4))
		// Televendas
		
		If ((Empty(QRY1->F2_VEND2) .OR. ;
			(!Empty(QRY1->F2_VEND2) .AND. !(QRY1->D2_FORNEC $ cFornVend))).AND. ;
			!Empty(QRY1->U7_CODVEN) .and. ;
			QRY1->F2_VEND1 <> '000204') .or. ;
			QRY1->F2_VEND1 $ '006684/000353/000352/000356/000357/000359'
			
			_nTel += QRY1->F2_VALFAT
		Else
			// Representantes
			_nRep += QRY1->F2_VALFAT
			// Público
			If QRY1->C5_OPERADO $ cOper .OR. !Empty(QRY1->C5_EMPENHO) .OR. !Empty(QRY1->C5_EDITAL)
				_nPub += QRY1->F2_VALFAT
			EndIf
			//Prefeitura
			//If QRY1->F2_CLIENTE = '004303'
			//	_nPre += QRY1->F2_VALFAT
			//EndIf
			// Particular
			_nPar := (_nRep - _nPub - _nPre)
		EndIf
		// Total
		_nTot += QRY1->F2_VALFAT
		QRY1->(DbSkip())
		
	EndDo
	
	// Eriberto 05/11/07  
	If Ascan(_aFeriad,{|y| y[1] == _dEmiAtu}) <> 0; // É feriado
	   .or.  Ascan(_aNaoFatDip,{|y| y[1] == _dEmiAtu}) <> 0; // Não é um dia útil para efeito de faturamento
	   .or. (AllTrim(cDow(_dEmiAtu)) = "Saturday"); // É Sábado
	   .or. (AllTrim(cDow(_dEmiAtu)) = "Sunday")    // É Domingo 
	   
	   // MCVN - 04/12/2007	
	   If Ascan(_aFeriad,{|y| y[1] == _dEmiAtu}) <> 0 .Or. Ascan(_aNaoFatDip,{|y| y[1] == _dEmiAtu}) <> 0
		   _dEmiAtu++                
		  If (AllTrim(cDow(_dEmiAtu)) = "Saturday") 	   
   		   	  _dEmiAtu+=2		    
	      	  If Val(cMes) <> Month(_dEmiAtu)
		   		_dEmiAtu-=2		    
	   	   	  Endif
		  Endif
		  If Val(cMes) <> Month(_dEmiAtu)
		   		_dEmiAtu--		    
   	   	  Endif 	      
   	   ElseIf (AllTrim(cDow(_dEmiAtu)) = "Saturday") 
	   	  _dEmiAtu+=2		    
	   	  If Val(cMes) <> Month(_dEmiAtu)
		   		_dEmiAtu-=2		    
	   	  Endif
   	   Else 
	      _dEmiAtu++                
   		  If Val(cMes) <> Month(_dEmiAtu)
		   		_dEmiAtu--		    
   	   	  Endif 	      	      
	   Endif   	   	     	   
	EndIf   
	

	// Adiciona totais dos dias de cada coluna
	_nPos := Ascan(_aEmiFat,{|y| y[1] == _dEmiAtu})
	//	If _nPos == 0
	//		Aadd(_aEmiFat,{_dEmiAtu,_nPar,_nPub,_nPre,_nRep,_nTel,_nTot})
	//	Else
	//		_aEmiFat[_nPos,1] += _dEmiAtu
	_aEmiFat[_nPos,2] += _nPar
	_aEmiFat[_nPos,3] += _nPub
	_aEmiFat[_nPos,4] += _nPre
	_aEmiFat[_nPos,5] += _nRep
	_aEmiFat[_nPos,6] += _nTel
	_aEmiFat[_nPos,7] += _nTot
	//	EndIf
	
	// Acumula totais para montar linha dos totais
	_nAcPar += _nPar
	_nAcPub += _nPub
	_nAcPre += _nPre
	_nAcRep += _nRep
	_nAcTel += _nTel
	_nAcTot += _nTot
	
	// Zera
	_nPar := _nRep := _nTel := _nPub := _nPre := _nTot := 0
	
EndDo

// Posicionando no primeiro registro
DbSelectArea("QRY2")
DbGoTop()

Do While QRY2->(!Eof())
	IncProc( "Processando... Dados devolução")
	
	_dEmiAtu := Ctod(Substr(QRY2->D1_DTDIGIT,7,2)+"/"+Substr(QRY2->D1_DTDIGIT,5,2)+"/"+Substr(QRY2->D1_DTDIGIT,1,4))
	// Loop para totalizar o dia
	Do While _dEmiAtu == Ctod(Substr(QRY2->D1_DTDIGIT,7,2)+"/"+Substr(QRY2->D1_DTDIGIT,5,2)+"/"+Substr(QRY2->D1_DTDIGIT,1,4))
		// Televendas
		If ((Empty(QRY2->F2_VEND2) .OR. ;
			(!Empty(QRY2->F2_VEND2) .AND. !(QRY2->D2_FORNEC $ cFornVend))).AND. ;
			!Empty(QRY2->U7_CODVEN) .and. ;
			QRY2->F2_VEND1 <> '000204') .or. ;
			QRY2->F2_VEND1 $ '006684/000353/000352/000356/000357/000359'
			
			_nTel -= QRY2->D1_TOTAL
		Else
			// Representantes
			_nRep -= QRY2->D1_TOTAL
			// Público
			If QRY2->C5_OPERADO $ cOper .OR. !Empty(QRY2->C5_EMPENHO) .OR. !Empty(QRY2->C5_EDITAL)
				_nPub -= QRY2->D1_TOTAL
			EndIf
			//Prefeitura
			//If QRY2->C5_CLIENTE = '004303'
			//	_nPre -= QRY2->D1_TOTAL
			//EndIf
			// Particular
			_nPar := (_nRep - _nPub - _nPre)
		EndIf
		// Total
		_nTot -= QRY2->D1_TOTAL
		
		QRY2->(DbSkip())
		
	EndDo
	
/*	// Eriberto 05/11/07
	If Ascan(_aFeriad,{|y| y[1] == _dEmiAtu}) <> 0 // É feriado
		_dEmiAtu--
		If (AllTrim(cDow(_dEmiAtu)) = "Saturday") // É Sábado
			_dEmiAtu--
		ElseIf (AllTrim(cDow(_dEmiAtu)) = "Sunday") // É Domingo 
			_dEmiAtu--
			_dEmiAtu--
		EndIf
	ElseIf (AllTrim(cDow(_dEmiAtu)) = "Saturday") // É Sábado
		_dEmiAtu++
		_dEmiAtu++
	ElseIf (AllTrim(cDow(_dEmiAtu)) = "Sunday") // É Domingo 
		_dEmiAtu++
	EndIf */
	
	// Eriberto 05/11/07  
	If Ascan(_aFeriad,{|y| y[1] == _dEmiAtu}) <> 0; // É feriado
	   .or.  Ascan(_aNaoFatDip,{|y| y[1] == _dEmiAtu}) <> 0; // Não é um dia útil para efeito de faturamento
	   .or. (AllTrim(cDow(_dEmiAtu)) = "Saturday"); // É Sábado
	   .or. (AllTrim(cDow(_dEmiAtu)) = "Sunday")    // É Domingo 
	   
	   // MCVN - 04/12/2007	
	   If Ascan(_aFeriad,{|y| y[1] == _dEmiAtu}) <> 0 .Or. Ascan(_aNaoFatDip,{|y| y[1] == _dEmiAtu}) <> 0
		   _dEmiAtu++                
		  If (AllTrim(cDow(_dEmiAtu)) = "Saturday") 	   
   		   	  _dEmiAtu+=2		    
	      	  If Val(cMes) <> Month(_dEmiAtu)
		   		_dEmiAtu-=2		    
	   	   	  Endif
		  Endif
		  If Val(cMes) <> Month(_dEmiAtu)
		   		_dEmiAtu--		    
   	   	  Endif 	      
   	   ElseIf (AllTrim(cDow(_dEmiAtu)) = "Saturday") 
	   	  _dEmiAtu+=2		    
	   	  If Val(cMes) <> Month(_dEmiAtu)
		   		_dEmiAtu-=2		    
	   	  Endif
   	   Else 
	      _dEmiAtu++                
   		  If Val(cMes) <> Month(_dEmiAtu)
		   		_dEmiAtu--		    
   	   	  Endif 	      	      
	   Endif   	   	     	   
	EndIf   
	
	// Adiciona totais dos dias de cada coluna
	_nPos := Ascan(_aEmiFat,{|y| y[1] == _dEmiAtu})
	//	If _nPos == 0
	//		Aadd(_aEmiFat,{_dEmiAtu,_nPar,_nPub,_nPre,_nRep,_nTel,_nTot})
	//	Else
	//		_aEmiFat[_nPos,1] += _dEmiAtu
	_aEmiFat[_nPos,2] += _nPar
	_aEmiFat[_nPos,3] += _nPub
	_aEmiFat[_nPos,4] += _nPre
	_aEmiFat[_nPos,5] += _nRep
	_aEmiFat[_nPos,6] += _nTel
	_aEmiFat[_nPos,7] += _nTot
	//	EndIf
	// Acumula totais para montar linha dos totais
	_nAcPar += _nPar
	_nAcPub += _nPub
	_nAcPre += _nPre
	_nAcRep += _nRep
	_nAcTel += _nTel
	_nAcTot += _nTot
	
	// Zera
	_nPar := _nRep := _nTel := _nPub := _nPre := _nTot := 0
	
EndDo

For _x := 1 to 500
	IncProc( "Processando... Dados dos pedidos")
Next

// Posicionando no primeiro registro
DbSelectArea("QRY3")
DbGoTop()

Do While QRY3->(!Eof())
	IncProc( "Processando... Dados dos pedidos")
	
	_dEmiAtu := Ctod(Substr(QRY3->C5_EMISSAO,7,2)+"/"+Substr(QRY3->C5_EMISSAO,5,2)+"/"+Substr(QRY3->C5_EMISSAO,1,4))
	// Loop para totalizar o dia
	If Substr(QRY3->C5_EMISSAO,5,2) == cMes
		Do While _dEmiAtu == Ctod(Substr(QRY3->C5_EMISSAO,7,2)+"/"+Substr(QRY3->C5_EMISSAO,5,2)+"/"+Substr(QRY3->C5_EMISSAO,1,4))
		
		 If Substr(QRY3->C9_DATALIB,1,6) == (cAno+cMes) .And. Left(QRY3->C9_DATALIB,6) == Left(DTOS(DDATABASE),6)
			// Colocados
			_nColPed += QRY3->C9_VALOR
			// Liberados
			If Empty(QRY3->C5_PARCIAL) .and. ((QRY3->C9_BLEST='02' .or. QRY3->C9_BLEST='  ') .and. QRY3->C9_SALDO = 0 .and. Empty(QRY3->C9_BLCRED) .and. Empty(QRY3->C9_BLCRED2))
				_nLibPed += QRY3->C9_VALOR
				// Estoque
			ElseIf QRY3->C9_BLEST = '02' .and. QRY3->C9_SALDO != 0
				_nEstPed += QRY3->C9_VALOR
				// Pelo Operador
			ElseIf !Empty(QRY3->C5_PARCIAL)
				_nOpePed  += QRY3->C9_VALOR
				// Credito
			ElseIf QRY3->C9_BLCRED $ '01/04/09' //!Empty(QRY3->C9_BLCRED2) Eriberto 12/03/2007
				_nCrePed += QRY3->C9_VALOR
				// Faturado
			ElseIf QRY3->C9_BLEST == '10' .and. QRY3->C9_BLCRED == '10'
				_nFatPed += QRY3->C9_VALOR
			EndIf
			
			// Só para pedidos liberados - vamos separar por area
			If Empty(QRY3->C5_PARCIAL) .and. ((QRY3->C9_BLEST = '02' .or. QRY3->C9_BLEST = '  ') .and. QRY3->C9_SALDO = 0 .and. Empty(QRY3->C9_BLCRED) .and. Empty(QRY3->C9_BLCRED2))
				// Televendas
				If (!Empty(QRY3->U7_CODVEN) .and. QRY3->C9_VEND <> '000204') .or. QRY3->C9_VEND $ '006684/000353/000352/000356/000357/000359'
					_nPVLTel += QRY3->C9_VALOR
				Else
					// Representantes
					_nPVLRep += QRY3->C9_VALOR
					// Público
					If QRY3->C9_OPERADO $ cOper
						_nPVLPub += QRY3->C9_VALOR
					EndIf
					//Prefeitura
					If QRY3->C9_CLIENTE = '004303'
						_nPVLPre += QRY3->C9_VALOR
					EndIf
					// Particular
					_nPVLPar := (_nPVLRep - _nPVLPub - _nPVLPre)
				EndIf
				// Total
				_nPVLTot += QRY3->C9_VALOR
			EndIf
		 EndIf	
			QRY3->(DbSkip())
			
		EndDo
/*	// Eriberto 05/11/07
	If Ascan(_aFeriad,{|y| y[1] == _dEmiAtu}) <> 0 // É feriado
		_dEmiAtu--
		If (AllTrim(cDow(_dEmiAtu)) = "Saturday") // É Sábado
			_dEmiAtu--
		ElseIf (AllTrim(cDow(_dEmiAtu)) = "Sunday") // É Domingo
			_dEmiAtu--
			_dEmiAtu--
		EndIf
	ElseIf (AllTrim(cDow(_dEmiAtu)) = "Saturday") // É Sábado
		_dEmiAtu++
		_dEmiAtu++
	ElseIf (AllTrim(cDow(_dEmiAtu)) = "Sunday") // É Domingo 
		_dEmiAtu++
	EndIf */
	
	// Eriberto 05/11/07  
	If Ascan(_aFeriad,{|y| y[1] == _dEmiAtu}) <> 0; // É feriado
	   .or.  Ascan(_aNaoFatDip,{|y| y[1] == _dEmiAtu}) <> 0; // Não é um dia útil para efeito de faturamento
	   .or. (AllTrim(cDow(_dEmiAtu)) = "Saturday"); // É Sábado
	   .or. (AllTrim(cDow(_dEmiAtu)) = "Sunday")    // É Domingo 
	   
	   // MCVN - 04/12/2007	
	   If Ascan(_aFeriad,{|y| y[1] == _dEmiAtu}) <> 0  .Or. Ascan(_aNaoFatDip,{|y| y[1] == _dEmiAtu}) <> 0
		   _dEmiAtu++                
		  If (AllTrim(cDow(_dEmiAtu)) = "Saturday") 	   
   		   	  _dEmiAtu+=2		    
	      	  If Val(cMes) <> Month(_dEmiAtu)
		   		_dEmiAtu-=2		    
	   	   	  Endif
		  Endif
		  If Val(cMes) <> Month(_dEmiAtu)
		   		_dEmiAtu--		    
   	   	  Endif 	      
   	   ElseIf (AllTrim(cDow(_dEmiAtu)) = "Saturday") 
	   	  _dEmiAtu+=2		    
	   	  If Val(cMes) <> Month(_dEmiAtu)
		   		_dEmiAtu-=2		    
	   	  Endif
   	   Else 
	      _dEmiAtu++                
   		  If Val(cMes) <> Month(_dEmiAtu)
		   		_dEmiAtu--		    
   	   	  Endif 	      	      
	   Endif   	   	     	   
	EndIf   
	
	// Adiciona totais dos dias de cada coluna
	_nPos := Ascan(_aEmiPed,{|y| y[1] == _dEmiAtu})
//	If _nPos == 0
//		Aadd(_aEmiPed,{_dEmiAtu,_nColPed, _nLibPed, _nFatPed, _nEstPed, _nCrePed, _nOpePed})
//	Else
		//		_aEmiPed[_nPos,1] += _dEmiAtu
		_aEmiPed[_nPos,2] += _nColPed
		_aEmiPed[_nPos,3] += _nLibPed
		_aEmiPed[_nPos,4] += _nFatPed
		_aEmiPed[_nPos,5] += _nEstPed
		_aEmiPed[_nPos,6] += _nCrePed
		_aEmiPed[_nPos,7] += _nOpePed
//	EndIf
	
	// Acumula totais para montar linha dos totais
	_nAcCol += _nColPed
	_nAcLib += _nLibPed
	_nAcFat += _nFatPed
	_nAcEst += _nEstPed
	_nAcCre += _nCrePed
	_nAcOpe += _nOpePed
	
	// Zera
	_nColPed:= _nLibPed := _nFatPed:= _nEstPed:= _nCrePed:= _nOpePed:= 0
	
	Else
		// Só para pedidos liberados - vamos separar por area *** DE OUTROS MESES
		If Empty(QRY3->C5_PARCIAL) .and. ((QRY3->C9_BLEST = '02' .or. QRY3->C9_BLEST = '  ') .and. QRY3->C9_SALDO = 0 .and. Empty(QRY3->C9_BLCRED) .and. Empty(QRY3->C9_BLCRED2))
			// Televendas
			If (!Empty(QRY3->U7_CODVEN) .and. QRY3->C9_VEND <> '000204') .or. QRY3->C9_VEND $ '006684/000353/000352/000356/000357/000359'
				_nPVLTel += QRY3->C9_VALOR
			Else
				// Representantes
				_nPVLRep += QRY3->C9_VALOR
				// Público
				If QRY3->C9_OPERADO $ cOper
					_nPVLPub += QRY3->C9_VALOR
				EndIf
				//Prefeitura
				If QRY3->C9_CLIENTE = '004303'
					_nPVLPre += QRY3->C9_VALOR
				EndIf
				// Particular
				_nPVLPar := (_nPVLRep - _nPVLPub - _nPVLPre)
			EndIf
			// Total
			_nPVLTot += QRY3->C9_VALOR
		EndIf
		
		QRY3->(DbSkip())
		
	EndIf
EndDo

//----------------------------------------------------------------------------------------------------
// Adiciona linha de totais
//----------------------------------------------------------------------------------------------------
Aadd(_aAcuFat,{"Acumulado",_nAcPar,_nAcPub,_nAcPre,_nAcRep,_nAcTel,_nAcTot,_nAcCol,_nAcLib,_nAcFat,_nAcEst,_nAcCre,_nAcOpe})
Aadd(_aPedLib,{"PV Liberados",_nPVLPar,_nPVLPub,_nPVLPre,_nPVLRep,_nPVLTel,_nPVLTot}) 
Aadd(_aNoDia ,{"PV Liberados",_nPVLPar,_nPVLPub,_nPVLPre,_nPVLRep,_nPVLTel,_nPVLTot})
//----------------------------------------------------------------------------------------------------
// JBS 16/06/2010 - Buscar o volume faturado para os fornecedores abaixo, dentro da empresa 04/04
//----------------------------------------------------------------------------------------------------
_aHQ_CD := fSintetico("040","04",{|| D2_FORNEC $ "000851/000847/051508"},; // Condicao para query 01
                                  {|| D2_FORNEC $ "000851/000847/051508"},; // Condicao para query 02
                                  {|| C9_FORNEC $ "000851/000847/051508"})  // Condicao para query 03
//----------------------------------------------------------------------------------------------------
Return
///////////////////////////
Static Function RptDetail()

Local nTotAcDia := 0 // JBS 21/07/2010 - Acucluar o total televendas HQ no CD + Ultima linha do acumulado diario
// inicialização das variáveis
_cTitulo := "Faturamento Diário - " + MesExtenso(Val(cMes)) + "/" + cAno
_cDesc1  := "Data               Particular           Público     Representantes         Televendas             Total        Acumulado                           PEDIDOS                                       Bloqueados                "
_cDesc2  := "                          (1)               (2)            (3)=1+2                (4)           (5)=3+4           diario        Colocados          Liberados      Faturados         Estoque         Credito   Pelo Operador"
_nPos    := 0

SetRegua(Len(_aEmiFat))

// Inicializa variáveis de totalização
_nSomRec := 0
_nSomPag := 0
_nFimRec := 0
_nFimPag := 0
_nAcu    := 0

// Impressão do relatório
For xi:=1 to Len(_aEmifat)
	
	IncRegua("Imprimindo: " + DtoC(_aEmifat[xi,1]))
	
	If li > 65
		li := Cabec(_cTitulo,_cDesc1,_cDesc2,nomeprog,tamanho) + 1
	EndIf
	/*
	*                                                                                                   1                                                                                                   2                                                                                                   3
	*         1         2         3         4         5         6         7         8         9         0         1         2         3         4         5         6         7         8         9         0         1         2         3         4         5         6         7         8         9         0         1         2         3         4         5         6
	*1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
	*Data                          Particular                      Público                   Prefeitura               Representantes                   Televendas                        Total                    Acumulado
	*DD/MM/AAAA                 99.999.999,99                99.999.999,99                99.999.999,99                99.999.999,99                99.999.999,99                99.999.999,99                99.999.999,99
	*                                                                                                   1                                                                                                   2                                                                                                   3
	*         1         2         3         4         5         6         7         8         9         0         1         2         3         4         5         6         7         8         9         0         1         2         3         4         5         6         7         8         9         0         1         2         3         4         5         6
	*1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
	*Data            Particular         Público         Representantes        Televendas             Total         Acumulado                           PEDIDOS                                         Bloqueados                *
	*                       (1)             (2)              (4)=1+2+3                (5)          (6)=4+5            diario        Colocados          Liberados       Faturados         Estoque          Credito   Pelo Operador*
	*DD/MM/AAAA   99.999.999,99   99.999.999,99          99.999.999,99     99.999.999,99      9.999.999,99     99.999.999,99    99.999.999,99      99.999.999,99   99.999.999,99   99.999.999,99    99.999.999,99   99.999.999,99                      *
	*/
	
	
	// Impressão das colunas
	If lValor                                        

		Iif(_nAcu + _aEmiFat[xi,7] > nTotAcDia, nTotAcDia := _nAcu + _aEmiFat[xi,7],) // JBS 21/07/2010
		
		@ li,001 PSay Left(dtoc(_aEmiFat[xi,1]),2)+"-"+DiaSemana(_aEmiFat[xi,1])
		@ li,016 PSay _aEmiFat[xi,2] Picture "@E 99,999,999.99"
		@ li,032 PSay _aEmiFat[xi,3] Picture "@E 99,999,999.99"
		//@ li,046 PSay _aEmiFat[xi,4] Picture "@E 99,999,999.99"
		@ li,053 PSay _aEmiFat[xi,5] Picture "@E 99,999,999.99"
		@ li,071 PSay _aEmiFat[xi,6] Picture "@E 99,999,999.99"
		@ li,090 PSay _aEmiFat[xi,7] Picture "@E 99,999,999.99"
		@ li,107 PSay Iif(_aEmiFat[xi,7]==0,0,_nAcu += _aEmiFat[xi,7])      Picture "@E 99,999,999.99"
		@ li,124 PSay _aEmiPed[xi,2] Picture "@E 99,999,999.99"
		@ li,143 PSay _aEmiPed[xi,3] Picture "@E 99,999,999.99"
		@ li,158 PSay _aEmiPed[xi,4] Picture "@E 99,999,999.99"
		@ li,174 PSay _aEmiPed[xi,5] Picture "@E 99,999,999.99"
		@ li,190 PSay _aEmiPed[xi,6] Picture "@E 99,999,999.99"
		@ li,206 PSay _aEmiPed[xi,7] Picture "@E 99,999,999.99"
		li++                                                     
	Else
		@ li,001 PSay Left(dtoc(_aEmiFat[xi,1]),2)+"-"+DiaSemana(_aEmiFat[xi,1])
		@ li,016 PSay Round((_aEmiFat[xi,2]/nMetPar)*100,2) Picture "@E 99,999,999.99"
		@ li,029 PSay '%'
		@ li,032 PSay Round((_aEmiFat[xi,3]/nMetPub)*100,2) Picture "@E 99,999,999.99"
		@ li,045 PSay '%'
		//@ li,046 PSay _aEmiFat[xi,4] Picture "@E 99,999,999.99"
		@ li,053 PSay Round((_aEmiFat[xi,5]/nMetRep)*100,2) Picture "@E 99,999,999.99"
		@ li,066 PSay '%'
		@ li,071 PSay Round((_aEmiFat[xi,6]/nMetTel)*100,2) Picture "@E 99,999,999.99"
		@ li,084 PSay '%'
		@ li,090 PSay Round((_aEmiFat[xi,7]/nMetDip)*100,2) Picture "@E 99,999,999.99"
		@ li,103 PSay '%'
		@ li,107 PSay Round((Iif(_aEmiFat[xi,7]==0,0,_nAcu += _aEmiFat[xi,7])/nMetDip)*100,2) Picture "@E 99,999,999.99"
		@ li,120 PSay '%'
		@ li,124 PSay Round((_aEmiPed[xi,2]/(nMetDip/Len(_aEmiFat)))*100,2) Picture "@E 99,999,999.99"
		@ li,137 PSay '%'
		@ li,143 PSay Round((_aEmiPed[xi,3]/(nMetDip/Len(_aEmiFat)))*100,2) Picture "@E 99,999,999.99"
		@ li,156 PSay '%'
		@ li,158 PSay Round((_aEmiPed[xi,4]/(nMetDip/Len(_aEmiFat)))*100,2) Picture "@E 99,999,999.99"
		@ li,171 PSay '%'
		@ li,174 PSay Round((_aEmiPed[xi,5]/nMetDip)*100,2) Picture "@E 99,999,999.99"
		@ li,187 PSay '%'
		@ li,190 PSay Round((_aEmiPed[xi,6]/nMetDip)*100,2) Picture "@E 99,999,999.99"
		@ li,203 PSay '%'
		@ li,206 PSay Round((_aEmiPed[xi,7]/nMetDip)*100,2) Picture "@E 99,999,999.99"
		@ li,219 PSay '%'
		li++
	Endif
	
	// Calculando total do dia Faturado+pedidos - MCVN 04/12/2007	
	If _aEmiFat[xi,1] == DDatabase
	_aNoDia[1,1] := "No Dia "+DtoC(_aEmiFat[xi,1])
		For y:=2 to 7
			_aNoDia[1,y] := _aNoDia[1,y] + _aEmiFat[xi,y]
		Next
	EndIf
	
	If _aEmiFat[xi,7] == 0 .and. _aEmiFat[xi,1] >= Date()
		_nDiasSem++
	Else
		_nDiasCom++
	EndIf

	If _lUltDia .and. (xi = Len(_aEmiFat) .or. _aEmiPed[xi+1,2] = 0)  // Eriberto 18/04/2007
		_cDiaTot := _aEmiFat[xi,1]
		_nTotDia := _aEmiFat[xi,7]
		_lUltDia := .f.
	EndIf
Next
//-------------------------------------------------------------------------------
// Impressão da linha de totais
//-------------------------------------------------------------------------------
If lValor
	@ li,000 psay Replicate("-",220)
	li++
	@ li,001 PSay _aAcuFat[1,1]
	@ li,016 PSay _aAcuFat[1,2] Picture "@E 99,999,999.99"
	@ li,032 PSay _aAcuFat[1,3] Picture "@E 99,999,999.99"
	//@ li,046 PSay _aAcuFat[1,4] Picture "@E 99,999,999.99"
	@ li,053 PSay _aAcuFat[1,5] Picture "@E 99,999,999.99"
	@ li,071 PSay _aAcuFat[1,6] Picture "@E 99,999,999.99"
	@ li,090 PSay _aAcuFat[1,7] Picture "@E 99,999,999.99"
	@ li,124 PSay _aAcuFat[1,8] Picture "@E 99,999,999.99"
	@ li,143 PSay _aAcuFat[1,9] Picture "@E 99,999,999.99"
	@ li,158 PSay _aAcuFat[1,10] Picture "@E 99,999,999.99"
	@ li,174 PSay _aAcuFat[1,11] Picture "@E 99,999,999.99"
	@ li,190 PSay _aAcuFat[1,12] Picture "@E 99,999,999.99"
	@ li,206 PSay _aAcuFat[1,13] Picture "@E 99,999,999.99"
	li++
	@ li,000 psay Replicate("-",220)
	li++
	@ li,001 PSay "Media Diária("+AllTrim(Str(_nDiasCom,2))+')'
	//RBorges - 17/11/14 - Na HQ será usado somente o Total, por isso o comentário no fonte 
   	/*	
	@ li,017 PSay _aAcuFat[1,2]/_nDiasCom Picture "@E 9,999,999.99"
	@ li,032 PSay _aAcuFat[1,3]/_nDiasCom Picture "@E 99,999,999.99"
	//-@ li,046 PSay _aAcuFat[1,4]/_nDiasCom Picture "@E 99,999,999.99"
	@ li,053 PSay _aAcuFat[1,5]/_nDiasCom Picture "@E 99,999,999.99"
	@ li,071 PSay _aAcuFat[1,6]/_nDiasCom Picture "@E 99,999,999.99"
	*/
	@ li,090 PSay _aAcuFat[1,7]/_nDiasCom Picture "@E 99,999,999.99"
	@ li,124 PSay _aAcuFat[1,8]/_nDiasCom Picture "@E 99,999,999.99"
	li++
	@ li,000 psay Replicate("-",220)
	li++
	@ li,001 PSay "Meta Diária("+AllTrim(Str(_nDiasSem,2))+')'
	//RBorges - 17/11/14 - Na HQ será usado somente o Total, por isso o comentário no fonte 
   	/*	
	@ li,016 PSay (nMetPar - _aAcuFat[1,2])/_nDiasSem Picture "@E 99,999,999.99"
	@ li,032 PSay (nMetPub - _aAcuFat[1,3])/_nDiasSem Picture "@E 99,999,999.99"
	@ li,053 PSay (nMetRep - _aAcuFat[1,5])/_nDiasSem Picture "@E 99,999,999.99"
	@ li,071 PSay (nMetTel - _aAcuFat[1,6])/_nDiasSem Picture "@E 99,999,999.99"
	*/
	@ li,090 PSay ((nMetTel + nMetRep)-_aAcuFat[1,7])/_nDiasSem Picture "@E 99,999,999.99"
	@ li,124 PSay ((nMetTel + nMetRep)-_aAcuFat[1,8])/_nDiasSem Picture "@E 99,999,999.99"
	li++
	@ li,000 psay Replicate("-",220)
	li++
	@ li,001 PSay "Meta Mensal("+Str(Len(_aEmiFat),2)+')'
	//RBorges - 17/11/14 - Na HQ será usado somente o Total, por isso o comentário no fonte 
   	/*	
	@ li,016 PSay nMetPar Picture "@E 99,999,999.99"
	@ li,032 PSay nMetPub Picture "@E 99,999,999.99"
	@ li,053 PSay nMetRep Picture "@E 99,999,999.99"
	@ li,071 PSay nMetTel Picture "@E 99,999,999.99"
	*/
	@ li,090 PSay nMetTel + nMetRep Picture "@E 99,999,999.99"
	li++
	@ li,000 psay Replicate("-",220)
	li++
	@ li,001 PSay "Falta para Meta"
	//RBorges - 17/11/14 - Na HQ será usado somente o Total, por isso o comentário no fonte 
   	/*   
	@ li,016 PSay nMetPar - _aAcuFat[1,2] Picture "@E 99,999,999.99"
	@ li,032 PSay nMetPub - _aAcuFat[1,3] Picture "@E 99,999,999.99"
	@ li,053 PSay nMetRep - _aAcuFat[1,5] Picture "@E 99,999,999.99"
	@ li,071 PSay nMetTel - _aAcuFat[1,6] Picture "@E 99,999,999.99"
	*/
	@ li,090 PSay nMetTel + nMetDip - _aAcuFat[1,7] Picture "@E 99,999,999.99"
    @ li,124 PSay nMetTel + nMetDip - _aAcuFat[1,8] Picture "@E 99,999,999.99"
	li++
	@ li,000 psay Replicate("-",220)
	li++
	@ li,001 PSay "% Atingido" 
	//RBorges - 17/11/14 - Na HQ será usado somente o Total, por isso o comentário no fonte 
   	/*
    @ li,016 PSay Round(_aAcuFat[1,2]/nMetPar*100,2) Picture "@E 99,999,999.99"
	@ li,029 PSay  "%"
	@ li,032 PSay Round(_aAcuFat[1,3]/nMetPub*100,2) Picture "@E 99,999,999.99"
	@ li,045 PSay  "%"
	@ li,053 PSay Round(_aAcuFat[1,5]/nMetRep*100,2) Picture "@E 99,999,999.99"
	@ li,066 PSay  "%"
	@ li,071 PSay Round(_aAcuFat[1,6]/nMetTel*100,2) Picture "@E 99,999,999.99"
	@ li,084 PSay  "%"                                                                   
	*/
	@ li,090 PSay Round(_aAcuFat[1,7]/(nMetTel + nMetRep)*100,2) Picture "@E 99,999,999.99"
	@ li,103 PSay  "%"
	@ li,124 PSay Round(_aAcuFat[1,8]/(nMetTel + nMetRep)*100,2) Picture "@E 99,999,999.99"
	@ li,137 PSay  "%"
	li++
	@ li,000 psay Replicate("-",220)
	li++
	@ li,001 PSay "Participação"
	@ li,016 PSay Round(_aAcuFat[1,2]/_aAcuFat[1,7]*100,2) Picture "@E 99,999,999.99"
	@ li,029 PSay  "%"
	@ li,032 PSay Round(_aAcuFat[1,3]/_aAcuFat[1,7]*100,2) Picture "@E 99,999,999.99"
	@ li,045 PSay  "%"
	//@ li,046 PSay Round(_aAcuFat[1,4]/_aAcuFat[1,7]*100,2) Picture "@E 99,999,999.99"
	//@ li,059 PSay  "%"
	@ li,053 PSay Round(_aAcuFat[1,5]/_aAcuFat[1,7]*100,2) Picture "@E 99,999,999.99"
	@ li,066 PSay  "%"
	@ li,071 PSay Round(_aAcuFat[1,6]/_aAcuFat[1,7]*100,2) Picture "@E 99,999,999.99"
	@ li,084 PSay  "%"
	@ li,097 PSay "100.00%"
	li++
	@ li,000 psay Replicate("-",220)
	li++
	
	If Val(cMes) == Month(DDataBase)
		@ li,000 psay Replicate("=",220)
		li++
		
		@ li,001 PSay _aPedLib[1,1]
		@ li,016 PSay _aPedLib[1,2] Picture "@E 99,999,999.99"
		@ li,032 PSay _aPedLib[1,3] Picture "@E 99,999,999.99"
		//@ li,046 PSay _aPedLib[1,4] Picture "@E 99,999,999.99"
		@ li,053 PSay _aPedLib[1,5] Picture "@E 99,999,999.99"
		@ li,071 PSay _aPedLib[1,6] Picture "@E 99,999,999.99"
		@ li,090 PSay _aPedLib[1,7] Picture "@E 99,999,999.99"
		//@ li,106 PSay "Total "+DtoC(_cDiaTot)+": "+ Alltrim(Transform(_nTotDia+_aPedLib[1,7],"@E 99,999,999.99"))
		li++
		@ li,000 psay Replicate("-",220)
		li++
		@ li,001 PSay _aNoDia[1,1]
		@ li,016 PSay _aNoDia[1,2] Picture "@E 99,999,999.99"
		@ li,032 PSay _aNoDia[1,3] Picture "@E 99,999,999.99"
		//@ li,046 PSay _aPedLib[1,4] Picture "@E 99,999,999.99"
		@ li,053 PSay _aNoDia[1,5] Picture "@E 99,999,999.99"
		@ li,071 PSay _aNoDia[1,6] Picture "@E 99,999,999.99"
		@ li,090 PSay _aNoDia[1,7] Picture "@E 99,999,999.99"
		@ li,107 PSay _aPedLib[1,7]+_aAcuFat[1,7] Picture "@E 99,999,999.99"   // MCVN 15/01/2009
		
		//@ li,106 PSay "Total "+DtoC(_cDiaTot)+": "+ Alltrim(Transform(_NoDia[1,7],"@E 99,999,999.99"))
		li++
		@ li,000 psay Replicate("-",220)
		li++
	Endif
	//------------------------------------------------------------------------------------------------------------------------------
	// JBS 16/06/2010 - Impressao do sintetico de vendas de produtos dos fornecedores '000851', '000847' e '051508'
	//                  de acordo com os paramentros informados pelo usuario.
	//------------------------------------------------------------------------------------------------------------------------------
	@ li,000 psay Replicate("*",220)
	li++
	/*
	@ li,001 PSay 'Produtos HQ no CD'                                         
	//
	@ li,016 psay _aHQ_CD[01] Picture "@E 99,999,999.99"
	@ li,032 PSay _aHQ_CD[02] Picture "@E 99,999,999.99"
	// @ li,032 PSay _aHQ_CD[03] Picture "@E 99,999,999.99"
	@ li,053 PSay _aHQ_CD[04] Picture "@E 99,999,999.99"
	@ li,071 PSay _aHQ_CD[05] Picture "@E 99,999,999.99"
	@ li,090 PSay _aHQ_CD[06] Picture "@E 99,999,999.99"
	@ li,107 PSay nTotAcDia+_aHQ_CD[06] + _aPedLib[1,7] Picture "@E 99,999,999.99" // JBS 28/07/2010 Incluido o total do dia // JBS 21/07/2010 - Total Acumulado dia + Televendas HQ no CD.
	@ li,124 psay _aHQ_CD[07] Picture "@E 99,999,999.99"
	@ li,143 PSay _aHQ_CD[08] Picture "@E 99,999,999.99"
	@ li,158 PSay _aHQ_CD[09] Picture "@E 99,999,999.99"
	@ li,174 PSay _aHQ_CD[10] Picture "@E 99,999,999.99"
	@ li,190 PSay _aHQ_CD[11] Picture "@E 99,999,999.99"
	@ li,206 PSay _aHQ_CD[12] Picture "@E 99,999,999.99"
	li++
	@ li,000 psay Replicate(".",220)
	li++
	*/
Else
	@ li,000 psay Replicate("-",220)
	li++
	@ li,001 PSay _aAcuFat[1,1]
	@ li,016 PSay Round((_aAcuFat[1,2]/nMetPar)*100,2)  Picture "@E 99,999,999.99"
	@ li,029 PSay '%'
	@ li,032 PSay Round((_aAcuFat[1,3]/nMetPub)*100,2)  Picture "@E 99,999,999.99"
	@ li,045 PSay '%'
	//@ li,046 PSay _aAcuFat[1,4] Picture "@E 99,999,999.99"
	@ li,053 PSay Round((_aAcuFat[1,5]/nMetRep)*100,2)  Picture "@E 99,999,999.99"
	@ li,066 PSay '%'
	@ li,071 PSay Round((_aAcuFat[1,6]/nMetTel)*100,2)  Picture "@E 99,999,999.99"
	@ li,084 PSay '%'
	@ li,090 PSay Round((_aAcuFat[1,7]/nMetDip)*100,2)  Picture "@E 99,999,999.99"
	@ li,103 PSay '%'
	@ li,124 PSay Round((_aAcuFat[1,8]/nMetDip)*100,2)  Picture "@E 99,999,999.99"
	@ li,137 PSay '%'
	@ li,143 PSay Round((_aAcuFat[1,9]/(nMetDip/Len(_aEmiFat)))*100,2)  Picture "@E 99,999,999.99"
	@ li,156 PSay '%'
	@ li,158 PSay Round((_aAcuFat[1,10]/(nMetDip/Len(_aEmiFat)))*100,2) Picture "@E 99,999,999.99"
	@ li,171 PSay '%'
	@ li,174 PSay Round((_aAcuFat[1,11]/nMetDip)*100,2) Picture "@E 99,999,999.99"
	@ li,187 PSay '%'
	@ li,190 PSay Round((_aAcuFat[1,12]/nMetDip)*100,2) Picture "@E 99,999,999.99"
	@ li,203 PSay '%'
	@ li,206 PSay Round((_aAcuFat[1,13]/nMetDip)*100,2) Picture "@E 99,999,999.99"
	@ li,219 PSay '%'
	li++
	@ li,000 psay Replicate("-",220)
	li++
	@ li,001 PSay "Media Diária("+AllTrim(Str(_nDiasCom,2))+')'
	@ li,017 PSay Round(((_aAcuFat[1,2]/_nDiasCom)/nMetPar)*100,2) Picture "@E 9,999,999.99"
	@ li,029 PSay '%'
	@ li,032 PSay Round(((_aAcuFat[1,3]/_nDiasCom)/nMetPub)*100,2) Picture "@E 99,999,999.99"
	@ li,045 PSay '%'
	//@ li,046 PSay _aAcuFat[1,4]/_nDiasCom Picture "@E 99,999,999.99"
	@ li,053 PSay Round(((_aAcuFat[1,5]/_nDiasCom)/nMetRep)*100,2) Picture "@E 99,999,999.99"
	@ li,066 PSay '%'
	@ li,071 PSay Round(((_aAcuFat[1,6]/_nDiasCom)/nMetTel)*100,2) Picture "@E 99,999,999.99"
	@ li,084 PSay '%'
	@ li,090 PSay Round(((_aAcuFat[1,7]/_nDiasCom)/nMetDip)*100,2) Picture "@E 99,999,999.99"
	@ li,103 PSay '%'
	@ li,124 PSay Round(((_aAcuFat[1,8]/_nDiasCom)/(nMetDip/Len(_aEmiFat)))*100,2) Picture "@E 99,999,999.99"
	@ li,137 PSay '%'
	li++
	@ li,000 psay Replicate("-",220)
	li++
	@ li,001 PSay "Meta Diária("+AllTrim(Str(_nDiasSem,2))+')'
	@ li,016 PSay Round((((nMetPar - _aAcuFat[1,2])/_nDiasSem)/nMetPar)*100,2) Picture "@E 99,999,999.99"
	@ li,029 PSay '%'
	@ li,032 PSay Round((((nMetPub - _aAcuFat[1,3])/_nDiasSem)/nMetPub)*100,2) Picture "@E 99,999,999.99"
	@ li,045 PSay '%'
	@ li,053 PSay Round((((nMetRep - _aAcuFat[1,5])/_nDiasSem)/nMetRep)*100,2) Picture "@E 99,999,999.99"
	@ li,066 PSay '%'
	@ li,071 PSay Round((((nMetTel - _aAcuFat[1,6])/_nDiasSem)/nMetTel)*100,2) Picture "@E 99,999,999.99"
	@ li,084 PSay '%'
	@ li,090 PSay Round(((((nMetDip)-_aAcuFat[1,7])/_nDiasSem)/nMetDip)*100,2) Picture "@E 99,999,999.99"
	@ li,103 PSay '%'
	@ li,124 PSay Round(((((nMetDip)-_aAcuFat[1,8])/_nDiasSem)/(nMetDip/Len(_aEmiFat)))*100,2) Picture "@E 99,999,999.99"
	@ li,137 PSay '%'
	li++
	@ li,000 psay Replicate("-",220)
	li++

	@ li,001 PSay "Meta Mensal("+Str(Len(_aEmiFat),2)+')'
	@ li,016 PSay 100 Picture "@E 99,999,999.99"
	@ li,029 PSay  "%"
	@ li,032 PSay 100 Picture "@E 99,999,999.99"
	@ li,045 PSay  "%"
	@ li,053 PSay 100 Picture "@E 99,999,999.99"
	@ li,066 PSay  "%"
	@ li,071 PSay 100 Picture "@E 99,999,999.99"
	@ li,084 PSay  "%"
	@ li,090 PSay 100 Picture "@E 99,999,999.99"
	@ li,103 PSay  "%"

	li++
	@ li,000 psay Replicate("-",220)
	li++

	@ li,001 PSay "Falta para Meta"
	@ li,016 PSay Round(((nMetPar - _aAcuFat[1,2])/nMetPar)*100,2) Picture "@E 99,999,999.99"
	@ li,029 PSay  "%"
	@ li,032 PSay Round(((nMetPub - _aAcuFat[1,3])/nMetPub)*100,2) Picture "@E 99,999,999.99"
	@ li,045 PSay  "%"
	@ li,053 PSay Round(((nMetRep - _aAcuFat[1,5])/nMetRep)*100,2) Picture "@E 99,999,999.99"
	@ li,066 PSay  "%"
	@ li,071 PSay Round(((nMetTel - _aAcuFat[1,6])/nMetTel)*100,2) Picture "@E 99,999,999.99"
	@ li,084 PSay  "%"
	@ li,090 PSay Round(((nMetDip - _aAcuFat[1,7])/nMetDip)*100,2) Picture "@E 99,999,999.99"
	@ li,103 PSay  "%"
	@ li,124 PSay Round(((nMetDip - _aAcuFat[1,8])/(nMetDip/_nDiasCom))*100,2) Picture "@E 99,999,999.99"
	@ li,137 PSay  "%"
	
	li++
	@ li,000 psay Replicate("-",220)
	li++
	@ li,001 PSay "% Atingido"
	@ li,016 PSay Round(_aAcuFat[1,2]/nMetPar*100,2) Picture "@E 99,999,999.99"
	@ li,029 PSay  "%"
	@ li,032 PSay Round(_aAcuFat[1,3]/nMetPub*100,2) Picture "@E 99,999,999.99"
	@ li,045 PSay  "%"
	@ li,053 PSay Round(_aAcuFat[1,5]/nMetRep*100,2) Picture "@E 99,999,999.99"
	@ li,066 PSay  "%"
	@ li,071 PSay Round(_aAcuFat[1,6]/nMetTel*100,2) Picture "@E 99,999,999.99"
	@ li,084 PSay  "%"
	@ li,090 PSay Round(_aAcuFat[1,7]/(nMetDip)*100,2) Picture "@E 99,999,999.99"
	@ li,103 PSay  "%"
	@ li,124 PSay Round(_aAcuFat[1,8]/(nMetDip)*100,2) Picture "@E 99,999,999.99"
	@ li,137 PSay  "%"
	li++
	@ li,000 psay Replicate("-",220)
	li++
	@ li,001 PSay "Participação"
	@ li,016 PSay Round(_aAcuFat[1,2]/_aAcuFat[1,7]*100,2) Picture "@E 99,999,999.99"
	@ li,029 PSay  "%"
	@ li,032 PSay Round(_aAcuFat[1,3]/_aAcuFat[1,7]*100,2) Picture "@E 99,999,999.99"
	@ li,045 PSay  "%"
	//@ li,046 PSay Round(_aAcuFat[1,4]/_aAcuFat[1,7]*100,2) Picture "@E 99,999,999.99"
	//@ li,059 PSay  "%"
	@ li,053 PSay Round(_aAcuFat[1,5]/_aAcuFat[1,7]*100,2) Picture "@E 99,999,999.99"
	@ li,066 PSay  "%"
	@ li,071 PSay Round(_aAcuFat[1,6]/_aAcuFat[1,7]*100,2) Picture "@E 99,999,999.99"
	@ li,084 PSay  "%"
	@ li,097 PSay "100.00%"
	li++
	@ li,000 psay Replicate("-",220)
	li++
	
	If Val(cMes) == Month(DDataBase)
		@ li,000 psay Replicate("=",220)
		li++
		
		@ li,001 PSay _aPedLib[1,1]
		@ li,016 PSay Round((_aPedLib[1,2]/nMetPar)*100,2) Picture "@E 99,999,999.99"
		@ li,029 PSay  "%"
		@ li,032 PSay Round((_aPedLib[1,3]/nMetPub)*100,2) Picture "@E 99,999,999.99"
		@ li,045 PSay  "%"
		//@ li,046 PSay _aPedLib[1,4] Picture "@E 99,999,999.99"
		@ li,053 PSay Round((_aPedLib[1,5]/nMetRep)*100,2) Picture "@E 99,999,999.99"
		@ li,066 PSay  "%"
		@ li,071 PSay Round((_aPedLib[1,6]/nMetTel)*100,2) Picture "@E 99,999,999.99"
		@ li,084 PSay  "%"
		@ li,090 PSay Round((_aPedLib[1,7]/nMetDip)*100,2) Picture "@E 99,999,999.99"
		@ li,103 PSay  "%"
		//@ li,106 PSay "Total "+DtoC(_cDiaTot)+": "+ Alltrim(Transform(_nTotDia+_aPedLib[1,7],"@E 99,999,999.99"))
		li++
		@ li,000 psay Replicate("-",220)
		li++
		@ li,001 PSay _aNoDia[1,1]
		@ li,016 PSay Round((_aNoDia[1,2]/nMetPar)*100,2) Picture "@E 99,999,999.99"
		@ li,029 PSay  "%"
		@ li,032 PSay Round((_aNoDia[1,3]/nMetPub)*100,2) Picture "@E 99,999,999.99"
		@ li,045 PSay  "%"
		//@ li,046 PSay _aPedLib[1,4] Picture "@E 99,999,999.99"
		@ li,053 PSay Round((_aNoDia[1,5]/nMetRep)*100,2) Picture "@E 99,999,999.99"
		@ li,066 PSay  "%"
		@ li,071 PSay Round((_aNoDia[1,6]/nMetTel)*100,2) Picture "@E 99,999,999.99"
		@ li,084 PSay  "%"
		@ li,090 PSay Round((_aNoDia[1,7]/nMetDip)*100,2) Picture "@E 99,999,999.99"
		@ li,103 PSay  "%"
		@ li,107 PSay Round(((_aPedLib[1,7]+_aAcuFat[1,7])/nMetDip)*100,2) Picture "@E 99,999,999.99"   // MCVN 15/01/2009
		@ li,120 PSay  "%"
		
		//@ li,106 PSay "Total "+DtoC(_cDiaTot)+": "+ Alltrim(Transform(_NoDia[1,7],"@E 99,999,999.99"))
		li++
		@ li,000 psay Replicate("-",220)
		li++
	Endif
Endif



DbSelectArea("QRY1")
QRY1->(DbCloseArea())

DbSelectArea("QRY2")
QRY2->(DbCloseArea())

DbSelectArea("QRY3")
QRY3->(DbCloseArea())

Set device to Screen

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se em disco, desvia para Spool                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If aReturn[5] == 1    // Se Saida para disco, ativa SPOOL
	Set Printer TO
	Commit
	ourspool(wnrel)
Endif

Return(.T.)
*---------------------------------------*
Static Function DipPergDiverg(lLer)
// Registra alterações no SX1
*---------------------------------------*
Local aRegs:={}
Local lIncluir
Local i,j
SX1->(dbSetOrder(1))
aAdd(aRegs,{cPerg,"01","Informe o Mês      ?","","","MV_CH1","C",002,0,0,"G","","MV_PAR01","","","", cMes,"","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"02","Informe o Ano      ?","","","MV_CH2","C",004,0,0,"G","","MV_PAR02","","","", cAno,"","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"03","Meta Televendas    ?","","","MV_CH3","N",012,2,0,"G","","MV_PAR03","","","", Str(nMetTel),"","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"04","Meta Representante ?","","","MV_CH4","N",012,2,0,"G","","MV_PAR04","","","", Str(nMetRep),"","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"05","Meta Particular    ?","","","MV_CH5","N",012,2,0,"G","","MV_PAR05","","","", Str(nMetPar),"","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"06","Meta Publico       ?","","","MV_CH6","N",012,2,0,"G","","MV_PAR06","","","", Str(nMetPub),"","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"07","Operadores Publico ?","","","MV_CH7","C",040,0,0,"G","","MV_PAR07","","","", Substr(cOper,01,40),"","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"08","Operadores Publico ?","","","MV_CH8","C",040,0,0,"G","","MV_PAR08","","","", Substr(cOper,41,40),"","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"09","Vendedor           ?","","","MV_CH9","C",006,0,0,"G","","MV_PAR09","","","", cCodVend,"","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"10","Fornecedor         ?","","","MV_CHA","C",006,0,0,"G","","MV_PAR10","","","", cCodForn,"","","","","","","","","","",""})
For i:=1 to len(aRegs)
	lIncluir:=!SX1->(dbSeek(cPerg+aRegs[i,2]))
	If !lIncluir.and.lLer
		aRegs[i,17]:=SX1->X1_CNT01
	EndIf
	SX1->(RecLock("SX1",lIncluir))
	For j:=1 to SX1->(FCount())
		If j <= len(aRegs[i])
			SX1->(FieldPut(j,aRegs[i,j]))
		Endif
	Next
	SX1->(MsUnlock("SX1"))
Next
cMes:=Left(aRegs[1,17],2)      // cMes cMes
cAno:=Left(aRegs[2,17],4)      // cAno cAno
nMetTel:=val(aRegs[3,17])      // nMetTel nMetTel
nMetRep:=val(aRegs[4,17])      // nMetRep nMetRep
nMetPar:=val(aRegs[5,17])      // nMetTel nMetTel
nMetPub:=val(aRegs[6,17])      // nMetRep nMetRep
cCodVend:= SubStr(aRegs[09,17],1,6) // Codigo do Vendedor // JBS 06/08/2010
cCodForn:= SubStr(aRegs[10,17],1,6) // Codigo do Fornecedor // JBS 06/08/2010
//cOper:=ALLTRIM(aRegs[7,17])+ALLTRIM(aRegs[8,17])+Space(80-Len(ALLTRIM(aRegs[7,17])+ALLTRIM(aRegs[8,17]))) // cOper cOpe
Return(.t.)             


*---------------------------------------*
Static Function OperadorPub()
// Busca operadores no SU7 com U7_POSTO = "3" (Operadores de licitação - Publico)
//MCVN - 06/08/09
*---------------------------------------*                                        
Local cOpePub  := ""

QRY4 :=        " SELECT U7_COD"
QRY4 := QRY4 + " FROM " + RetSQLName("SU7")
QRY4 := QRY4 + " WHERE "
QRY4 := QRY4 + RetSQLName("SU7")+".D_E_L_E_T_ <> '*'" + " AND "
QRY4 := QRY4 + "U7_POSTO = '03' "
QRY4 := QRY4 + "ORDER BY U7_COD"
// Processa Query SQL
TcQuery QRY4 NEW ALIAS "QRY4"         // Abre uma workarea com o resultado da query

dbSelectArea("QRY4")
While QRY4->(!Eof())
	cOper := If(Empty(cOper),Alltrim(QRY4->U7_COD),cOper+"/"+Alltrim(QRY4->U7_COD))
	QRY4->(DbSkip())
Enddo

QRY4->(DbCloseArea())

Return(cOpePub)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³fQuery01  ºAutor  ³Jailton B Santos-JBSº Data ³ 16/06/2010  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Esta Query apura os falores faturado no pedido pela empresaº±±
±±º          ³ informada como parametro, Retorna Query QRY1.              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Especifico - Faturamento - DIPROMED.                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function fQuery01( _cEmpresa ,_cFilial, lAnalitico)

Local lRet    := .T.
Local cQry1   := ""
Local cFilSF2 := cFilAnt //fFilial(_cEmpresa,'SF2',_cFilial)  // iif(!Empty(xFilial('SF2')),_cFilial,Space(2))
Local cFilSF4 := cFilAnt //fFilial(_cEmpresa,'SF4',_cFilial)  //  iif(!Empty(xFilial('SF4')),_cFilial,Space(2))
Local nId     := 0
//-----------------------------------------------------------------------------------------
// Default lAnalitico:= .T. // JBS 07/04/2010 - Novo tratamento Apuração de valores analiticos
//-----------------------------------------------------------------------------------------
ProcRegua(500)

For _x := 1 to 150
	IncProc( "Processando...VENDAS ")
Next

If lAnalitico
	cQry1 := " SELECT F2_DOC, (D2_TOTAL+D2_SEGURO+D2_VALFRE+D2_DESPESA+D2_ICMSRET ) F2_VALFAT, F2_EMISSAO, F2_VEND1, F2_VEND2, C5_OPERADO, U7_CODVEN, F2_CLIENTE, D2_FORNEC"
Else
	cQry1 := " SELECT SUM(D2_TOTAL+D2_SEGURO+D2_VALFRE+D2_DESPESA+D2_ICMSRET ) F2_VALFAT, F2_VEND1, F2_VEND2, C5_OPERADO, U7_CODVEN, F2_CLIENTE, D2_FORNEC"
EndIf

cQry1 += "  FROM SF2" + _cEmpresa + " SF2"
cQry1 += "     INNER JOIN SC5" + _cEmpresa + " SC5 "
cQry1 += "        on SC5.D_E_L_E_T_ = ' ' "
cQry1 += "        and SD2.D2_FILIAL = SC5.C5_FILIAL "
cQry1 += "        and SD2.D2_PEDIDO = SC5.C5_NUM "
cQry1 += "     LEFT JOIN " + RetSQLName("SU7") + " SU7" 
cQry1 += "        on SU7.D_E_L_E_T_ = ' ' "
cQry1 += "        and SF2.F2_VEND1 = SU7.U7_CODVEN "
cQry1 += "     INNER JOIN SD2" + _cEmpresa + " SD2 "
cQry1 += "        on SD2.D_E_L_E_T_ = ' ' "
cQry1 += "        and SF2.F2_FILIAL = SD2.D2_FILIAL "	// Eriberto 02/03/2010
cQry1 += "        and SF2.F2_DOC    = SD2.D2_DOC "		// Eriberto 02/03/2010
cQry1 += "        and SF2.F2_SERIE  = SD2.D2_SERIE "	// Eriberto 02/03/2010
cQry1 += "     INNER JOIN SF4" + _cEmpresa + " SF4 "
cQry1 += "        on SF4.D_E_L_E_T_ = ' ' "
cQry1 += "        and SD2.D2_TES = SF4.F4_CODIGO "
cQry1 += "        and SF4.F4_DUPLIC = 'S' "
cQry1 += "        and SF4.F4_FILIAL = '" + cFilSF4 + "' "
cQry1 += "  WHERE SF2.D_E_L_E_T_ = ' ' "
cQry1 += "     and LEFT(SF2.F2_EMISSAO,6) = '" + cAno + cMes + "' "
cQry1 += "     and SF2.F2_FILIAL = '" + cFilSF2 + "' "	// Eriberto 02/03/2010
cQry1 += "     and SF2.F2_TIPO IN ('N','C') "			// Eriberto 02/03/2010



//------------------------------------------------------------------------------------
// Filtro listven  MCVN - 06/05/09
//------------------------------------------------------------------------------------
/*If lValor .and. lAnalitico
	If U_ListVend() != ''
		If Upper(_cDipusr) $ cVendInt
			For nId := 1 to len(_aMeta)
				_aMeta[nId][METREP] := 0
				_aMeta[nId][METPAR] := 0
				_aMeta[nId][METPUB] := 0
			Next nId
		ElseIf Upper(_cDipusr) $ cVendExt
			For nId := 1 to len(_aMeta)
				_aMeta[nId][METTEL] := 0
			Next nId
		Endif
		cQry1 += " C5_VEND1 " + U_ListVend() + " AND "
	EndIf
Endif   */
                          
If lValor .and. lAnalitico
	If U_ListVend() != ''   
		If Upper(_cDipusr) $ cVendInt    
			For nId := 1 to len(_aMeta)
				_aMeta[nId][METREP] := 0
				_aMeta[nId][METPAR] := 0
				_aMeta[nId][METPUB] := 0
			Next nId  
		ElseIf Upper(_cDipusr) $ cVendExt
			For nId := 1 to len(_aMeta)
				_aMeta[nId][METTEL] := 0
			Next nId
		Endif
		cQry1 +=" F2_VEND1 " + U_ListVend()+" AND "
	EndIf
	// Filtro ListOper (OPERADOR) MCVN - 19/08/10
	If U_ListOper() != ''   
		If Upper(_cDipusr) $ cVendInt    
			For nId := 1 to len(_aMeta)
				_aMeta[nId][METREP] := 0
				_aMeta[nId][METPAR] := 0
				_aMeta[nId][METPUB] := 0
			Next nId  
		ElseIf Upper(_cDipusr) $ cVendExt
			For nId := 1 to len(_aMeta)
				_aMeta[nId][METTEL] := 0
				_aMeta[nId][METPUB] := 0
			Next nId
		ElseIf Upper(_cDipusr) $ cVendPub
			For nId := 1 to len(_aMeta)
				_aMeta[nId][METREP] := 0
				_aMeta[nId][METPAR] := 0
				_aMeta[nId][METTEL] := 0
			Next nId  
		Endif
		cQry1 += " C5_OPERADO " + U_ListOper()+" AND "
	EndIf                 
Endif	
	


If lAnalitico
	cQry1 += " ORDER BY F2_EMISSAO "
Else
	cQry1 += " GROUP BY F2_VEND1, F2_VEND2, C5_OPERADO, U7_CODVEN, F2_CLIENTE, D2_FORNEC"
EndIf

If Select("QRY1") > 0
	QRY1->( DbCloseArea() )
EndIf

TcQuery cQry1 NEW ALIAS "QRY1"
memowrite('DIPR42_SD2'+_cEmpresa + _cFilial+'.SQL',cQry1)

lRet := !QRY1->( BOF().and.EOF() )
QRY1->( DbGoTop() )

Return(lRet)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³fQuery02  ºAutor  ³Jailton B Santos-JBSº Data ³ 16/06/2010  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Esta Query apura os valores das devolucoes na empresa      º±±
±±º          ³ informada como parametro, Retorna Query QRY2               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Especifico - Faturamento - DIPROMED.                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function fQuery02(_cEmpresa,_cFilial,lAnalitico)

Local lRet    := .T.
Local cQry2   := ""
Local cFilSD1 := cFilAnt //fFilial(_cEmpresa,'SD1',_cFilial)  // iif(!Empty(xFilial('SD1')),_cFilial,Space(2)) // Se nao for compaartilhado, traz a filial informada no _cFilial
Local cFilSF4 := cFilAnt //fFilial(_cEmpresa,'SF4',_cFilial)  // iif(!Empty(xFilial('SF4')),_cFilial,Space(2))

For _x := 1 to 150
	IncProc( "Processando... DEVOLUÇÃO")
Next

If lAnalitico // Processamento Normal
	cQry2 := "SELECT D1_DOC, D1_DTDIGIT, D1_TES, C5_OPERADO, U7_CODVEN, F2_VEND1, F2_VEND2, C5_CLIENTE, SUM(D1_TOTAL+D1_VALFRE+D1_SEGURO+D1_DESPESA+D1_ICMSRET ) D1_TOTAL, D2_FORNEC "
Else // Processamento sintetico de valores
	cQry2 := "SELECT C5_OPERADO, U7_CODVEN, F2_VEND1, F2_VEND2, C5_CLIENTE, SUM(D1_TOTAL+D1_VALFRE+D1_SEGURO+D1_DESPESA+D1_ICMSRET ) D1_TOTAL, D2_FORNEC "
EndIf

cQry2 += " FROM SD1" + _cEmpresa + "  SD1"
cQry1 += "     INNER JOIN SD2" + _cEmpresa + "  SD2"
cQry2 += "        on SD2.D_E_L_E_T_ = ' ' "
cQry2 += "        and SD1.D1_FILIAL  = SD2.D2_FILIAL "
cQry2 += "        and SD1.D1_NFORI   = SD2.D2_DOC "
cQry2 += "        and SD1.D1_SERIORI = SD2.D2_SERIE "
cQry2 += "        and SD1.D1_ITEMORI = SD2.D2_ITEM "
cQry1 += "     INNER JOIN SC5" + _cEmpresa + " SC5"
cQry2 += "        on SC5.D_E_L_E_T_ = ' ' "
cQry2 += "        and SD2.D2_FILIAL = SC5.C5_FILIAL "
cQry2 += "        and SD2.D2_PEDIDO = SC5.C5_NUM    "    
	// Filtro listOper  MCVN - 19/08/10
	If U_ListOper() != ''
		cQry2 += "        and C5_OPERADO " + U_ListOper()+" "
	EndIf

cQry1 += "     INNER JOIN SF4" + _cEmpresa + " SF4 "
cQry2 += "        on SF4.D_E_L_E_T_ = ' ' "
cQry2 += "        and SF4.F4_FILIAL = '" + cFilSF4 + "' "
cQry2 += "        and SD1.D1_TES = SF4.F4_CODIGO "
cQry2 += "        and SF4.F4_DUPLIC = 'S' "
cQry1 += "     INNER JOIN SF2" + _cEmpresa + " SF2 "
cQry2 += "        on SF2.D_E_L_E_T_ = ' ' "
cQry2 += "        and SF2.F2_FILIAL = SD2.D2_FILIAL "
cQry2 += "        and SF2.F2_DOC    = SD2.D2_DOC    "
cQry2 += "        and SF2.F2_SERIE  = SD2.D2_SERIE  "   
cQry2 += "        and SF2.F2_TIPO IN ('N','C')      "
	// Filtro listven  MCVN - 06/05/09
	If U_ListVend() != ''
		cQry2 += "        and F2_VEND1 " + U_ListVend()+" "
	EndIf            

cQry1 += "     LEFT JOIN "+ RetSQLName("SU7") + " SU7"
cQry2 += "        on SU7.D_E_L_E_T_ = ' ' "
cQry2 += "        and SF2.F2_VEND1 = SU7.U7_CODVEN "

cQry2 += " WHERE SD1.D_E_L_E_T_ = ' ' "
cQry2 += "    and SD1.D1_TIPO = 'D'"
cQry2 += "    and LEFT(SD1.D1_DTDIGIT,6) = '" + cAno + cMes + "'"
cQry2 += "    and SD1.D1_FILIAL = '" + cFilSD1 + "'"


If lAnalitico
	cQry2 += " GROUP BY D1_DOC,D1_DTDIGIT,D1_TES,C5_OPERADO,U7_CODVEN,F2_VEND1,F2_VEND2,C5_CLIENTE,D2_FORNEC "
	cQry2 += " ORDER BY D1_DTDIGIT"
Else
	cQry2 += " GROUP BY C5_OPERADO,U7_CODVEN, F2_VEND1, F2_VEND2,C5_CLIENTE,D2_FORNEC "
EndIf

If Select("QRY2") > 0
	QRY2->( DbCloseArea() )
EndIf

TcQuery cQry2 NEW ALIAS "QRY2"
memowrite('DIPR42SD1' + _cEmpresa + _cFilial + '.SQL',cQry2)

lRet := !QRY2->( BOF().and.EOF() )
QRY2->( DbGoTop() )

Return(lRet)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³fQuery03  ºAutor  ³Jailton B Santos-JBSº Data ³ 16/06/2010  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Esta Query apura os valores dos pedidos da empresa infor-  º±±
±±º          ³ mada como parametro. Retorna QRY3.                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Especifico - Faturamento - DIPROMED.                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function fQuery03(_cEmpresa,_cFilial)

Local lRet    := .T.
Local cQry3   := ""
Local cFilSC5 := cFilAnt //fFilial(_cEmpresa,'SC5',_cFilial)  // iif(!Empty(xFilial('SC5')),_cFilial,Space(2))
Local cFilSF4 := cFilAnt //fFilial(_cEmpresa,'SF4',_cFilial)  // iif(!Empty(xFilial('SF4')),_cFilial,Space(2))

For _x := 1 to 150
	IncProc( "Processando... PEDIDOS")
Next

cQry3 := "SELECT C5_EMISSAO, C5_PARCIAL, C9_CLIENTE, C9_OPERADO, U7_CODVEN, C9_VEND, C9_PARCIAL, C9_BLEST, C9_BLCRED, C9_BLCRED2, SUM(C9_QTDLIB*C9_PRCVEN) C9_VALOR, C9_SALDO,C9_FORNEC "
cQry3 += "FROM SC9" + _cEmpresa + " SC9 "
cQry3 += "   INNER JOIN SC6" + _cEmpresa + " SC6 "
cQry3 += "      on SC6.D_E_L_E_T_ = ' ' "
cQry3 += "      and SC9.C9_FILIAL = SC6.C6_FILIAL "
cQry3 += "      and SC9.C9_PEDIDO = SC6.C6_NUM "
cQry3 += "      and SC9.C9_ITEM   = SC6.C6_ITEM "
cQry3 += "   INNER JOIN SC5" + _cEmpresa + " SC5 "
cQry3 += "      on SC5.D_E_L_E_T_ = ' ' "
cQry3 += "      and SC5.C5_FILIAL = '" + cFilSC5 + "' "
cQry3 += "      and SC5.C5_TIPO   = 'N' "
cQry3 += "      and SC9.C9_FILIAL = SC5.C5_FILIAL "
cQry3 += "      and SC9.C9_PEDIDO = SC5.C5_NUM "
	If U_ListVend() != ''
		cQry3 += "      and C5_VEND1 " + U_ListVend()+" "
	EndIf
	// Filtro listOper  MCVN - 19/08/10
	If U_ListOper() != ''
		cQry3 += "      and C5_OPERADO " + U_ListOper()+" "
	EndIf                 

cQry3 += "   INNER JOIN SF4" + _cEmpresa + " SF4 "
cQry3 += "      on SF4.D_E_L_E_T_ = ' ' "
cQry3 += "      and SC6.C6_TES    = SF4.F4_CODIGO "
cQry3 += "      and SF4.F4_DUPLIC = 'S' "
cQry3 += "      and SF4.F4_FILIAL = '" + cFilSF4 + "' "
cQry3 += "   LEFT JOIN " + RetSQLName("SU7") + " SU7 "
cQry3 += "      on SU7.D_E_L_E_T_ = ' ' "
cQry3 += "      and SC5.C5_VEND1 = SU7.U7_CODVEN "

cQry3 += "WHERE SC9.D_E_L_E_T_ = ' ' "
cQry3 += "   and (LEFT(C5_EMISSAO,6) = '" + cAno + cMes + "' or ((C9_BLEST = '  ' or C9_BLEST = '02') and C5_PARCIAL = ' ' and C9_SALDO = 0 and C9_BLCRED = '  ' and C9_BLCRED2 = '  ')) "

cQry3 += "GROUP BY C5_EMISSAO, C5_PARCIAL, C9_CLIENTE, C9_OPERADO, U7_CODVEN, C9_VEND, C9_PARCIAL, C9_BLEST, C9_BLCRED, C9_BLCRED2, C9_SALDO, C9_FORNEC "
cQry3 += "ORDER BY C5_EMISSAO"

If Select("QRY3") > 0
	QRY3->( DbCloseArea() )
EndIf

TcQuery cQry3 NEW ALIAS "QRY3"
memowrite('DIPR42SC9' +_cEmpresa + _cFilial + '.SQL',cQry3)

lRet := !QRY3->( BOF().and.EOF() )
QRY3->( DbGoTop() )

Return(lRet)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³fFilial() ºAutor  ³Jailton B Santos-JBSº Data ³ 16/06/2010  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Faz o tratamento para achar a filial para empresa para a    º±±
±±º          ³qual ira' abrir a tabela informada.                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametro ³_cEmpresa: Empresa na qual queremos coletar dados           º±±
±±º          ³_cTabela : Nome da tabela da qual queremos coletar dados    º±±
±±º          ³_cFilial : Se a tabela for exclusiva, esta eh a filial da   º±±
±±º          ³           qual eh preciso coletar dados.                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Especifico - Faturamento - DIPROMED                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function fFilial(_cEmpresa,_cTabela,_cFilial)

Local _cNewFilial := Space(2)
/*Local _cFile      := 'SX2'+_cEmpresa
Local _cFileIdx   := _cFile

If Select("SX2_2") = 0
	MsOpEndbf(.T.,"DBFCDX",_cFile,"SX2_2",.T.,.F.)
EndIf

SX2_2->( DbSetOrder(1) )
If SX2_2->( DbSeek(_cTabela) )			  //
	If SX2_2->X2_MODO = 'E'
		_cNewFilial := _cFilial
	EndIf
Else
	_cNewFilial := xFilial(_cTabela)
EndIf*/

Return(_cNewFilial)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³fSinteticoºAutor  ³Jailton B Santos-JBSº Data ³  16/06/2010 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Apura os valor sintetico de vendas-devoluções de uma deter-º±±
±±º          ³ minada empresa e uma determinada filial                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Especifico Faturamento Dipromed                           º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function fSintetico(_cEmpresa,_cFilial,_bQry01,_bQry02,_bQry03)

Local _nSPar := 0
Local _nSPub := 0
Local _nSPre := 0
Local _nSRep := 0
Local _nSTel := 0
Local _nSTot := 0
Local nRegua := 1000
//----------------------------------------------------------------------------------------
// Posição de Pedidos - Apuração de subtotais
//----------------------------------------------------------------------------------------
Local _nColPed:= 0
Local _nLibPed:= 0
Local _nFatPed:= 0
Local _nEstPed:= 0
Local _nCrePed:= 0
Local _nOpePed:= 0
//----------------------------------------------------------------------------------------
// Posição de Pedidos - Apuração de Totais
//----------------------------------------------------------------------------------------
Local _nAcCol := 0
Local _nAcLib := 0
Local _nAcFat := 0
Local _nAcEst := 0
Local _nAcCre := 0
Local _nAcOpe := 0 
//----------------------------------------------------------------------------------------
ProcRegua(nRegua)
//----------------------------------------------------------------------------------------
// Le o faturamento do periodo para empresa '040 e filial '01'
//----------------------------------------------------------------------------------------
fQuery01(_cEmpresa,_cFilial,.f.)
//----------------------------------------------------------------------------------------
// Le as Devolucoes do periodo para empresa '040 e filial '01'
//----------------------------------------------------------------------------------------
fQuery02(_cEmpresa,_cFilial,.f.)  // Gerou QRY2
//----------------------------------------------------------------------------------------
// Le os Pedidos do periodo para empresa '0X0 e filial '0Y'
//----------------------------------------------------------------------------------------
fQuery03(_cEmpresa,_cFilial,.f.)  // Gerou QRY3
//----------------------------------------------------------------------------------------
DbSelectArea("QRY1")
DbGoTop()
//----------------------------------------------------------------------------------------
// Classfica as vendas por departamentos de vendas
//----------------------------------------------------------------------------------------
Do While QRY1->(!Eof())
	
	IncProc( "Processando... Sintético de Vendas")
	
	If nRegua = 0
		nRegua := 1000
		ProcRegua(nRegua)
	EndIf
	
	nRegua--
	//----------------------------------------------------------------------------------------
	// Uso da condicao para tornar esta funcao um rotina mais generica e permiir maior uso.  
	// JBS 15/06/2010  - Hoje ha a necessidade de trazer um total de um fornecedor  em  uma 
	// Empresa e filial determinada na condicao vai codeblock com os fornecedores que eu quero. 
	//----------------------------------------------------------------------------------------
	If _bQry01 <> Nil        // 
	    If QRY1->(!Eval(_bQry01))   
	        QRY1->( DbSkip())
	        Loop
	    EndIf    
	EndIf   
	// Comentado em 15/06/2010 - O Eriberto mudou o conceito
	//----------------------------------------------------------------------------------------
	// Exclui do processamento diario o fornecedor  051508'  - JBS 14/05/2010
	// Apenas quando for o CD HQ
	//----------------------------------------------------------------------------------------
	//If _cEmpresa== '040' .and. _cFilial == '04' .and. !AllTrim(QRY1->D2_FORNEC) $ cFornQH
	//	QRY1->(DbSkip())
	//	Loop
	//EndIf
	//----------------------------------------------------------------------------------------
	// Televendas
	//----------------------------------------------------------------------------------------
	If ((Empty(QRY1->F2_VEND2) .OR. (!Empty(QRY1->F2_VEND2) .AND. !(QRY1->D2_FORNEC $ cFornVend))).AND. !Empty(QRY1->U7_CODVEN) .and. QRY1->F2_VEND1 <> '000204') .or. ;
		QRY1->F2_VEND1 $ '006684/000353/000352/000356/000357/000359'
		_nSTel += QRY1->F2_VALFAT
	Else
		//----------------------------------------------------------------------------------------
		// Representantes
		//----------------------------------------------------------------------------------------
		_nSRep += QRY1->F2_VALFAT
		//----------------------------------------------------------------------------------------
		// Publico
		//----------------------------------------------------------------------------------------
		If QRY1->C5_OPERADO $ cOper
			_nSPub += QRY1->F2_VALFAT
		EndIf
		_nSPar := (_nSRep - _nSPub - _nSPre)
	EndIf
	//----------------------------------------------------------------------------------------
	// Total
	//----------------------------------------------------------------------------------------
	_nSTot += QRY1->F2_VALFAT
	
	QRY1->( DbSkip() )
	
EndDo
//----------------------------------------------------------------------------------------
// Classfica as devoluções de vendas por departamentos de vendas, fazendo a devida subtra-
// ção do faturamento aprurado
//----------------------------------------------------------------------------------------
DbSelectArea("QRY2")
DbGoTop()

Do While QRY2->(!Eof())
	
	IncProc( "Processando... Sintético de devolução")
	
	If nRegua = 0
		nRegua := 1000
		ProcRegua(nRegua)
	EndIf
	
	nRegua--
	//----------------------------------------------------------------------------------------
	// Uso da condicao para tornar esta funcao um rotina mais generica e permiir maior uso.  
	// JBS 15/06/2010  - Hoje ha a necessidade de trazer um total de um fornecedor  em  uma 
	// Empresa e filial determinada na condicao vai codeblock com os fornecedores que eu quero. 
	//----------------------------------------------------------------------------------------
	If _bQry02 <> Nil        // 
	    If QRY2->(!Eval(_bQry02))   
	        QRY2->( DbSkip())
	        Loop
	    EndIf    
	EndIf   
	//-------------------------------------------------------------------------------------------------
	// Televendas
	//-------------------------------------------------------------------------------------------------
	If ((Empty(QRY2->F2_VEND2).OR.(!Empty(QRY2->F2_VEND2) .AND. !(QRY2->D2_FORNEC $ cFornVend))).AND.!Empty(QRY2->U7_CODVEN).and.QRY2->F2_VEND1 <> '000204') .or. ;
		QRY2->F2_VEND1 $ '006684/000353/000352/000356/000357/000359'
		_nSTel -= QRY2->D1_TOTAL
	Else
		//-------------------------------------------------------------------------------------------------
		// Representantes
		//-------------------------------------------------------------------------------------------------
		_nSRep -= QR
		Y2->D1_TOTAL
		//-------------------------------------------------------------------------------------------------
		// Público
		//-------------------------------------------------------------------------------------------------
		If QRY2->C5_OPERADO $ cOper
			_nSPub -= QRY2->D1_TOTAL
		EndIf
		//-------------------------------------------------------------------------------------------------
		//Prefeitura
		//-------------------------------------------------------------------------------------------------
		//If QRY2->C5_CLIENTE = '004303'
		//	_nSPre -= QRY2->D1_TOTAL
		//EndIf
		//-------------------------------------------------------------------------------------------------
		// Particular
		//-------------------------------------------------------------------------------------------------
		_nSPar := (_nSRep - _nSPub - _nSPre)
	EndIf
	//-------------------------------------------------------------------------------------------------
	// Total
	//-------------------------------------------------------------------------------------------------
	_nSTot -= QRY2->D1_TOTAL
	//-------------------------------------------------------------------------------------------------
	QRY2->(DbSkip())
	
EndDo

DbSelectArea("QRY3")
DbGoTop()

Do While QRY3->(!Eof())
	
	IncProc( "Processando... Dados dos pedidos")
	//----------------------------------------------------------------------------------------
	// Uso da condicao para tornar esta funcao um rotina mais generica e permiir maior uso.  
	// JBS 15/06/2010  - Hoje ha a necessidade de trazer um total de um fornecedor  em  uma 
	// Empresa e filial determinada na condicao vai codeblock com os fornecedores que eu quero. 
	//----------------------------------------------------------------------------------------
	If _bQry03 <> Nil        // 
	    If QRY3->(!Eval(_bQry03))   
	        QRY3->( DbSkip())
	        Loop
	    EndIf    
	EndIf   

	_nColPed += QRY3->C9_VALOR
	// Liberados
	If Empty(QRY3->C5_PARCIAL) .and. ((QRY3->C9_BLEST='02' .or. QRY3->C9_BLEST='  ') .and. QRY3->C9_SALDO = 0 .and. Empty(QRY3->C9_BLCRED) .and. Empty(QRY3->C9_BLCRED2))
		_nLibPed += QRY3->C9_VALOR
		// Estoque
	ElseIf QRY3->C9_BLEST = '02' .and. QRY3->C9_SALDO != 0
		_nEstPed += QRY3->C9_VALOR
		// Pelo Operador
	ElseIf !Empty(QRY3->C5_PARCIAL)
		_nOpePed  += QRY3->C9_VALOR
		// Credito
	ElseIf QRY3->C9_BLCRED $ '01/04/09'
		_nCrePed += QRY3->C9_VALOR
		// Faturado
	ElseIf QRY3->C9_BLEST == '10' .and. QRY3->C9_BLCRED == '10'
		_nFatPed += QRY3->C9_VALOR
	EndIf
	
	// Só para pedidos liberados - vamos separar por area
	If Empty(QRY3->C5_PARCIAL) .and. ((QRY3->C9_BLEST = '02' .or. QRY3->C9_BLEST = '  ') .and. QRY3->C9_SALDO = 0 .and. Empty(QRY3->C9_BLCRED) .and. Empty(QRY3->C9_BLCRED2))
		// Televendas
		If (!Empty(QRY3->U7_CODVEN) .and. QRY3->C9_VEND <> '000204') .or. QRY3->C9_VEND $ '006684/000353/000352/000356/000357/000359'
			_nPVLTel += QRY3->C9_VALOR
		Else
			// Representantes
			_nPVLRep += QRY3->C9_VALOR
			// Público
			If QRY3->C9_OPERADO $ cOper
				_nPVLPub += QRY3->C9_VALOR
			EndIf
			//Prefeitura
			If QRY3->C9_CLIENTE = '004303'
				_nPVLPre += QRY3->C9_VALOR
			EndIf
			// Particular
			_nPVLPar := (_nPVLRep - _nPVLPub - _nPVLPre)
		EndIf
		// Total
		_nPVLTot += QRY3->C9_VALOR
	EndIf
	//-----------------------------------------------------------------------------------------
	// Acumula totais para montar linha dos totais
	//-----------------------------------------------------------------------------------------
	_nAcCol += _nColPed
	_nAcLib += _nLibPed
	_nAcFat += _nFatPed
	_nAcEst += _nEstPed
	_nAcCre += _nCrePed
	_nAcOpe += _nOpePed
	//-----------------------------------------------------------------------------------------
	// Zera
	//-----------------------------------------------------------------------------------------
	_nColPed:= 0
	_nLibPed:= 0
	_nFatPed:= 0
	_nEstPed:= 0
	_nCrePed:= 0
	_nOpePed:= 0
	//-----------------------------------------------------------------------------------------
	QRY3->(DbSkip())
	
EndDo
//-------------------------------------------------------------------------------------------------
// Retorna os valores apurados dentro de uma array
//-------------------------------------------------------------------------------------------------
Return({_nSPar,_nSPub,_nSPre,_nSRep,_nSTel,_nSTot,_nAcCol,_nAcLib,_nAcFat,_nAcEst,_nAcCre,_nAcOpe})

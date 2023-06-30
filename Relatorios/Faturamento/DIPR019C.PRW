/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDIPR019C  บAutor  ณReginaldo Borgesบ Data ณ 22/09/2014      บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณPrograma desenvolvido para gerar relatorio de faturamento   บฑฑ
ฑฑบ          ณpor fornecedores, na empresa Health Quality em              บฑฑ
ฑฑบ          ณum determinado periodo.                                      บฑฑ
ฑฑฬออออออออออุออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออนฑฑ
ฑฑบOrigem    ณDIPR019   บAutor  ณEriberto Elias      บ Data ณ 01/08/2002  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบVersao    ณVersao do programa DIPR019. Programa 95% reprogramado, tantoบฑฑ
ฑฑบ          ณo processamento do relatorio como a impressใo do relatorio. บฑฑ
ฑฑบ          ณO Processamento foi todo feito por querys e apurados em     บฑฑ
ฑฑบ          ณarrays.                                                     บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑบ          ณ												              บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Especifico - Faturamento - Health Quality.                 บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#include "rwmake.ch"
#INCLUDE "AP5MAIL.CH"
#INCLUDE "TBICONN.CH"
//--------------------------------------------------------------------
#define FONECEDOR    01
#define NOMEFORNECE  02
#define FATURAMENTO  03
#define CUSTO        04
#define MARGEM       05
#define DEVOLUCAO    06
#define CUSTDEV      07
#define FATURALIQUI  08
#define CUSTOLIQUID  09
//--------------------------------------------------------------------
User Function DIPR019C()
//--------------------------------------------------------------------
Local cUserAut := GetMV("MV_URELFAT") // MCVN - 04/05/09
//--------------------------------------------------------------------
Private aAllEmp  := {}
Private aEmpFrete:= {}
Private cPerg    := U_FPADR( "DIPR019c","SX1","SX1->X1_GRUPO"," " ) // Fun็ใo criada por Sandro em 19/11/09.
Private aEmpresa := {	{{'040','04'}},{{'040','01'}} }            // Empresa e filial para processar as querys
Private aOutros  := {{0,0,0,"Frete"},{0,0,0,"Seguro"},{0,0,0,"Despesa"},{0,0,0,"ICMS ST"}}
Private lSoma    := .T.
Private _cArqTrb   := ""
Private _aCampos  :={}
Private cWCodEmp  := cEmpAnt
Private	_aTamSX3 := TamSX3("A2_NREDUZ")
Private _cDipUsr := U_DipUsr()

IF SELECT("TRB")>0
	TRB->(DbCloseArea())
EndIf

AAdd(_aCampos ,{"NomeCD", "C",_aTamSX3[1],_aTamSX3[2]})
_aTamSX3 := TamSX3("D2_FORNEC")
AAdd(_aCampos ,{"CodigoCD", "C",_aTamSX3[1],_aTamSX3[2]})
_aTamSX3 := TamSX3("D2_TOTAL")
AAdd(_aCampos ,{"FaturCD","N",_aTamSX3[1],_aTamSX3[2]})
_aTamSX3 := TamSX3("A2_NREDUZ")
AAdd(_aCampos ,{"NomeMT", "C",_aTamSX3[1],_aTamSX3[2]})
_aTamSX3 := TamSX3("D2_FORNEC")
AAdd(_aCampos ,{"CodigoMT", "C",_aTamSX3[1],_aTamSX3[2]})
_aTamSX3 := TamSX3("D2_TOTAL")                                     
AAdd(_aCampos ,{"FaturMT","N",_aTamSX3[1],_aTamSX3[2]})
_aTamSX3 := TamSX3("A2_NREDUZ")
AAdd(_aCampos ,{"NomeTOTAL", "C",_aTamSX3[1],_aTamSX3[2]})
_aTamSX3 := TamSX3("D2_FORNEC")
AAdd(_aCampos ,{"CodiTOTAL", "C",_aTamSX3[1],_aTamSX3[2]})
_aTamSX3 := TamSX3("D2_TOTAL")
AAdd(_aCampos ,{"FaturTOTAL","N",_aTamSX3[1],_aTamSX3[2]})
_aTamSX3 := TamSX3("D2_TOTAL")
AAdd(_aCampos ,{"Margem","N",_aTamSX3[1],_aTamSX3[2]}) 
_aTamSX3 := TamSX3("D2_TOTAL")
AAdd(_aCampos ,{"Custo","N",_aTamSX3[1],_aTamSX3[2]})
_cArqTrb := CriaTrab(_aCampos,.T.)
DbUseArea(.T.,,_cArqTrb,"TRB",.F.,.F.)

// MCVN - 04/05/09
If !(Upper(_cDipUsr) $ cUserAut)
	Alert(Upper(_cDipUsr)+", voc๊ nใo tem autoriza็ใo para utilizar esta rotina. Qualquer d๚vida falar com Departamento de T.I.!","Aten็ใo")

	Return(Nil)
EndIF

U_DIPPROC(ProcName(0),_cDipUsr) // JBS 05/10/2005 - Gravando o nome do Programa no SZU

tamanho    := "G"
limite     := 220
titulo     := OemTOAnsi("Vendas por FORNECEDOR com margem",72)
cDesc1     := (OemToAnsi("Este programa tem como objetivo emitir um relatขrio",72))
cDesc2     := (OemToAnsi("de Faturamento por FORNECEDOR e VENDEDOR.",72))
cDesc3     := (OemToAnsi("Se deixar VENDEDOR vazio, saira todos.",72))
aReturn    := {"Bco A4", 1,"Faturamento", 1, 2, 1,"",1}
nomeprog   := "DIPR019"
nLastKey   := 0
lContinua  := .T.
lEnd       := .F.
li         := 67
wnrel      := "DIPR019"
M_PAG      := 1
cString    := "SD2"

AjustaSX1(cPerg)             // Verifica perguntas. Se nao existe INCLUI

If !Pergunte(cPerg,.T.)     // Solicita parametros
    TRB->(DbCloseArea()) // Giovani Zago 04/01/12  -- Erro neste momento a area "TRB" ja esta ativa.  
		Return
EndIf


wnrel := SetPrint(cString,wnrel,cPerg,Titulo,cDesc1,cDesc2,cDesc3,.f.,,.f.,tamanho,,.f.,,,,,)

If nLastKey == 27
	Return
Endif

SetDefault(aReturn,cString)

Processa({|lEnd| RunProc()},Titulo)

RptStatus({|lEnd| RptDetail()},Titulo)


Set device to Screen

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Se em disco, desvia para Spool                                            ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If aReturn[5] == 1    // Se Saida para disco, ativa SPOOL
	Set Printer TO
	Commit
	ourspool(wnrel)
Endif

Return
//--------------------------------------------------------------------
Static Function RunProc()
//--------------------------------------------------------------------
Local nFrete  := 0
Local nSeguro := 0
Local nDespesa:= 0                                                                     
Local nICMSRet:= 0
Local cFornec := ''  // JBS 03/08/2010
Local cNReduz := ''  // JBS 03/08/2010
Local aFatEmp := {}
Local nRegua  := 1000
Local nI, nId, nEmp
//--------------------------------------------------------------------
aAllEmp   := {}
aEmpFrete := {}
//--------------------------------------------------------------------
ProcRegua(nRegua)

For nId := 1 to Len(aEmpresa)
	//---------------------------------------------------------------------------------
	// Limpa a Array e variaveis para comecar a apurar os valores da proxima empresa
	//---------------------------------------------------------------------------------
	nFrete  := 0
	nSeguro := 0
	nDespesa:= 0
	nICMSRet:= 0
	
	aFatEmp := {}
	//---------------------------------------------------------------------------------
	// Faz a Leitura das vendas ocorridas dentro do periodo informado e armazena dentro
	// array aFatEmp, para deppois imprimir.
	//---------------------------------------------------------------------------------
	For nEmp := 1 To Len(aEmpresa[nId])
		If fQryFat(aEmpresa[nId][nEmp][01],aEmpresa[nId][nEmp][02])
			
			While TRB_F->(!EOF())
				
				If nRegua = 0
					nRegua := 1000
					ProcRegua(nRegua)
				EndIf
				
				IncProc()
				
				nRegua--
				
				//---------------------------------------------------------------------------------------------------
				// JBS 03/08/2010 - Tratamento para acumular os fornecedores
				//---------------------------------------------------------------------------------------------------
				cFornec := TRB_F->D2_FORNEC
				cNReduz := TRB_F->A2_NREDUZ

				aAdd( aFatEmp, {cFornec,cNReduz,TRB_F->T_FATURAMENTO,TRB_F->T_CUSTO,0,0,0,0,0} )
				
				aOutros[01][nId] += TRB_F->T_FRETE
				aOutros[02][nId] += TRB_F->T_SEGURO
				aOutros[03][nId] += TRB_F->T_DESPESA
				aOutros[04][nId] += TRB_F->T_ICMSRET
				
				aOutros[01][03] += TRB_F->T_FRETE
				aOutros[02][03] += TRB_F->T_SEGURO
				aOutros[03][03] += TRB_F->T_DESPESA 
				aOutros[04][03] += TRB_F->T_ICMSRET
				
				TRB_F->( DbSkip() )
				
			EndDo
		Else
			aAdd(aFatEmp,{" ","Sem Faturamento",0,0,0,0,0,0,0})
			aAdd(aFatEmp,{" ","               ",0,0,0,0,0,0,0})
			aAdd(aFatEmp,{" ","               ",0,0,0,0,0,0,0})
		EndIf
		//---------------------------------------------------------------------------------
		// Faz a Leitura das vendas devolvidas no periodo informado pelo usuario, armazena
		// dentro da ary para depois subtrar do faturamento bruto e gerar o faturamento
		// liquido
		//---------------------------------------------------------------------------------
		If  fQryDev(aEmpresa[nId][nEmp][01],aEmpresa[nId][nEmp][02])
			
			Do While TRB_D->(!EOF())
				
				If nRegua = 0
					nRegua := 1000
					ProcRegua(nRegua)
				EndIf
				
				IncProc()
				
				nRegua--
				//---------------------------------------------------------------------------------------------------
				// JBS 03/08/2010 - Tratamento para acumular os fornecedores
				//---------------------------------------------------------------------------------------------------
				cFornec := TRB_D->D2_FORNEC
				cNReduz := TRB_D->A2_NREDUZ

				If (nPos := Ascan(aFatEmp,{|X| X[1] == cFornec})) > 0   // JBS 03/08/2010 - Valida o fonecedor pela variavel
					aFatEmp[nPos][DEVOLUCAO] += TRB_D->D1_TOTAL * -1
					aFatEmp[nPos][CUSTDEV]   += TRB_D->T_CUSTO * -1
				Else
					aAdd(aFatEmp,{cFornec,cNReduz,0,0,0,TRB_D->D1_TOTAL*-1,TRB_D->T_CUSTO*-1,0,0}) // JBS 03/08/2010 - Pega codigo e nome do fornecedor das variaveis.
				EndIf
				
				aOutros[01][nId] -= TRB_D->T_FRETE
				aOutros[02][nId] -= TRB_D->T_SEGURO
				aOutros[03][nId] -= TRB_D->T_DESPESA
				aOutros[04][nId] -= TRB_D->T_ICMSRET
				
				aOutros[01][03] -= TRB_D->T_FRETE
				aOutros[02][03] -= TRB_D->T_SEGURO
				aOutros[03][03] -= TRB_D->T_DESPESA
				aOutros[04][03] -= TRB_D->T_ICMSRET
				
				TRB_D->( DbSkip() )
				
			EndDo
			
		EndIf
	Next nEmp
	//-------------------------------------------------------------------------------------------------------------
	// Calcula o Valor do Faturamento Liquido e o Valor do Custo Liquido,
	// ou seja, retira as devolucoes do valor faturado
	//-------------------------------------------------------------------------------------------------------------
	aEval(aFatEmp,{|X| X[FATURALIQUI] := X[FATURAMENTO]+X[DEVOLUCAO], X[CUSTOLIQUID] := X[CUSTO] + X[CUSTDEV]})
	//-------------------------------------------------------------------------------------------------------------
	// Ordena a Array por ordem de maior valor liquido apurado
	//-------------------------------------------------------------------------------------------------------------
	aSort(aFatEmp,,,{|X,Y| X[FATURALIQUI] > Y[FATURALIQUI]})
	
	aadd(aAllEmp,aFatEmp)
	
Next nId
//-------------------------------------------------------------------------------------------------------------
// Totaliza os totais por fornecedores
// Faz a Soma dos valores da Empresa 01 com os Valores dos Fornecedores Existentes
//-------------------------------------------------------------------------------------------------------------
aFatEmp := {}

//-- Alterado por Daniel Leme - 12-05-2011
For nI := 1 To Len(aAllEmp)
	For nId := 1 To Len(aAllEmp[nI])
		If (nPos := Ascan(aFatEmp,{|x| x[1] == aAllEmp[nI][nId][FONECEDOR]})) == 0
			aAdd(aFatEmp,{aAllEmp[nI][nId][FONECEDOR]  ,;
			aAllEmp[nI][nId][NOMEFORNECE],;
			0,; //-- FATURAMENTO
			0,; //-- CUSTO
			0,; //-- MARGEM
			0,; //-- DEVOLUCAO
			0,; //-- CUSTDEV
			0,; //-- FATURALIQUI
			0}) //-- CUSTOLIQUID
			nPos := Len(aFatEmp)
		End
		
		aFatEmp[nPos][FATURAMENTO] += aAllEmp[nI][nId][FATURAMENTO]
		aFatEmp[nPos][CUSTO]       += aAllEmp[nI][nId][CUSTO]
		aFatEmp[nPos][MARGEM]      += aAllEmp[nI][nId][MARGEM]
		aFatEmp[nPos][DEVOLUCAO]   += aAllEmp[nI][nId][DEVOLUCAO]
		aFatEmp[nPos][CUSTDEV]     += aAllEmp[nI][nId][CUSTDEV]
		aFatEmp[nPos][FATURALIQUI] += aAllEmp[nI][nId][FATURALIQUI]
		aFatEmp[nPos][CUSTOLIQUID] += aAllEmp[nI][nId][CUSTOLIQUID]
		
	Next nId
Next nI


//-------------------------------------------------------------------------------------------------------------
// Ordena a Array por ordem de maior valor liquido apurado
//-------------------------------------------------------------------------------------------------------------
aSort(aFatEmp,,,{|X,Y| X[FATURALIQUI] > Y[FATURALIQUI]})

aadd(aAllEmp,aFatEmp)

//-- at้ aqui
TRB_F->( DbCloseArea() )
TRB_D->( DbCloseArea() )

Return(.T.)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณRptDetail()บAutor ณJailton B Santos-JBSบ Data ณ 19/03/2010  บฑฑ
ฑฑฬออออออออออุอออออออออออสออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณImpresao do Relatorio                                       บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Especifico Fatutamento - Health Quality                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function RptDetail()

Local cUserAuth := GETMV("MV_DIPR019")
Local aTotais   := {{0,0,0},{0,0,0},{0,0,0}}
Local aTotTres  := {{"",0},{"",0},{"",0}}
Local _nReg     := 0
Local aColunas  := {{000,030,044,058},{076,106,120,134},{152,182,196,210}}
Local nId, nEmp, nDesp       
Local nTotTres	:= 0
Private _lMarg  := .F.

If !Empty(MV_PAR05)
	SA3->( DbSetOrder(1) )
	If SA3->( DbSeek(xFilial("SA3") + MV_PAR05) )
		_cDesc1 := 'Vendedor.: '+AllTrim(SA3->A3_NOME) + ' - ' + MV_PAR05
	Else
		_cDesc1 := 'vendedor nao cadastrado'
	EndIf
Else
	_cDesc1 := 'Todos Vendedores'
EndIf

If !Empty(		MV_PAR06)
	SA1->( DbSetOrder(1) )
	If SA1->( DbSeek(xFilial("SA1")+MV_PAR06) )
		_cDesc1  += ' - Cliente.: ' + MV_PAR06 + ' - ' + AllTrim(SA1->A1_NOME)
	Else
		_cDesc1  += ' Cliente nao cadastrado'
	EndIf
Else
	_cDesc1  += ' Todos Clientes'
EndIf

_cTitulo := "Vendas por fornecedor no periodo de: "+dTOc(MV_PAR01)+' at้ '+dTOc(MV_PAR02)


//0         10        20        30        40        50        60        70        80        90        100       110       120       130       140       150       160
//012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
// Fornecedor                      Faturamento         Custo Margem% Fornecedor                      Faturamento         Custo Margem %
// XXXXXXXXXXXXXXXXXXXX - 999999 99.999.999,99 99.999.999,99 999,99  XXXXXXXXXXXXXXXXXXXX - 999999 99.999.999,99 99.999.999,99 9999,99

_cDesc2  := "Fornecedor                       Faturamento                                Fornecedor                      Faturamento                                 Fornecedor                      Faturamento         Custo Margem %"
//_cDesc3  := "                          D I P R O M E D  ( C D )                                     H E A L T H   Q U A L I T Y   ( C D )                                     T O T A L  D A S  D U A S  E M P R E S A S "
_cDesc3  := "                          H.Q U A L I T Y  ( C D )                                              H.Q U A L I T Y ( M T Z )                                        T O T A L  D A S  D U A S  E M P R E S A S "
																		                                     
																	                                         
//Giovani Zago 03/05/2012
If Upper(_cDipUsr) $ cUserAuth  // MCVN - 16/04/2008
	If MsgYesNo("Deseja Imprimir Margem ?")
		_cDesc2  := "Fornecedor                       Faturamento         Custo Margem%          Fornecedor                      Faturamento         Custo Margem %          Fornecedor                      Faturamento         Custo Margem %"
        _lMarg  :=.T.
	
		Else		
		_cDesc2  := "Fornecedor                       Faturamento                                Fornecedor                      Faturamento                                 Fornecedor                      Faturamento                       "
		_cDesc3  := "                          H.Q U A L I T Y  ( C D )                                              H.Q U A L I T Y( M T Z )                                        T O T A L  D A S  D U A S  E M P R E S A S "
		
	EndIf
EndIf


nLen := Max(Max(Len(aAllEmp[01]),Len(aAllEmp[02])),Len(aAllEmp[03]))

SetRegua((nLen)*3)


RecLock("TRB",.T.)
TRB->CodigoCD       := ""
MsUnlock()
RecLock("TRB",.T.)
TRB->NomeCD       := "H.QUALITY"
TRB->CodigoCD         := "CD"
TRB->NomeMT      := "H.QUALITY"
TRB->CodigoMT         := "MATRIZ"
TRB->NomeTOTAL     := "TOTAL     DA"
TRB->CodiTOTAL      := "CD/MATRIZ"
MsUnlock()
RecLock("TRB",.T.)
TRB->CodigoCD       := ""
MsUnlock()

For nId := 1 to nLen
	
	
	If li > 65
		li := Cabec(_cTitulo,_cDesc1,_cDesc2,nomeprog,tamanho) + 1
		@ li,aColunas[01][01] PSay _cDesc3
		li+=2
	EndIf
	RecLock("TRB",.T.)
	For nEmp := 1 to Len(aAllEmp)
		         
		If nId <= Len(aAllEmp[nEmp])
			
			If nEmp = 1
				TRB->CodigoCD       :=  aAllEmp[nEmp][nId][FONECEDOR]
				TRB->NomeCD         :=  aAllEmp[nEmp][nId][NOMEFORNECE]
				TRB->FaturCD        := aAllEmp[nEmp][nId][FATURALIQUI]
			ElseIf nEmp = 2
				TRB->CodigoMT        :=  aAllEmp[nEmp][nId][FONECEDOR]
				TRB->NomeMT          :=  aAllEmp[nEmp][nId][NOMEFORNECE]
				TRB->FaturMT         := aAllEmp[nEmp][nId][FATURALIQUI]
			ElseIf nEmp = 3
				TRB->CodiTOTAL         :=  aAllEmp[nEmp][nId][FONECEDOR]
				TRB->NomeTOTAL         :=  aAllEmp[nEmp][nId][NOMEFORNECE]
				TRB->FaturTOTAL        := aAllEmp[nEmp][nId][FATURALIQUI]
				
			Endif
			
			@ li,aColunas[nEmp][01] PSay aAllEmp[nEmp][nId][NOMEFORNECE] +' '+ aAllEmp[nEmp][nId][FONECEDOR]
			@ li,aColunas[nEmp][02] PSay aAllEmp[nEmp][nId][FATURALIQUI] Picture "@ez 999,999,999.99"
						
			If Upper(_cDipUsr) $ cUserAuth .and. _lMarg // MCVN - 16/04/2008
					TRB->Custo        := aAllEmp[nEmp][nId][CUSTOLIQUID]
				@ li,aColunas[nEmp][03] PSay aAllEmp[nEmp][nId][CUSTOLIQUID] Picture "@ez 999,999,999.99"
				
				If aAllEmp[nEmp][nId][FATURALIQUI] > 0 .and. aAllEmp[nEmp][nId][CUSTOLIQUID] > 0
				   	TRB->Custo        := ((aAllEmp[nEmp][nId][FATURALIQUI]/aAllEmp[nEmp][nId][CUSTOLIQUID])-1)*100
						@ li,aColunas[nEmp][04] PSay ((aAllEmp[nEmp][nId][FATURALIQUI]/aAllEmp[nEmp][nId][CUSTOLIQUID])-1)*100 Picture '@E 9999.99'
				EndIf
			EndIf
			
			aTotais[nEmp][01] += aAllEmp[nEmp][nId][FATURALIQUI]
			aTotais[nEmp][02] += aAllEmp[nEmp][nId][CUSTOLIQUID]
	
			If nId < 21
				aTotais[nEmp][03] += aAllEmp[nEmp][nId][FATURALIQUI]
			EndIf 
			
			If nEmp == 3 .And. nId < 4
				aTotTres[nId][01] := aAllEmp[nEmp][nId][FONECEDOR]+' '+aAllEmp[nEmp][nId][NOMEFORNECE]
				aTotTres[nId][02] := aAllEmp[nEmp][nId][FATURALIQUI]
			EndIf
			
		EndIf          
		
		If nEmp < 3
			@ li,aColunas[nEmp][04] + 11 PSay  "|"
		EndIf
	Next nEmp
	li++
	_nReg++
	
	MsUnlock()
Next nId

If li > 65
	li := Cabec(_cTitulo,_cDesc1,_cDesc2,nomeprog,tamanho) + 1
	@ li,aColunas[01][01] PSay _cDesc3
	li+=2
EndIf

@ li,000 PSay Replic("*",Limite)
li++
If li > 65
	li := Cabec(_cTitulo,_cDesc1,_cDesc2,nomeprog,tamanho) + 1
	@ li,aColunas[01][01] PSay _cDesc3
	li+=2
EndIf
RecLock("TRB",.T.)
TRB->CodigoCD       := ""
MsUnlock()

@ li,000 PSay "Total: "
RecLock("TRB",.T.)

TRB->NomeCD       := "Total: "
For nEmp := 1 to Len(aAllEmp)
	If nEmp = 1
		TRB->FaturCD        := aTotais[nEmp][01]
	ElseIf nEmp = 2
		TRB->FaturMT        := aTotais[nEmp][01]
	ElseIf nEmp = 3
		TRB->FaturTOTAL        := aTotais[nEmp][01]
	EndIf
	@ li,aColunas[nEmp][02] PSay aTotais[nEmp][01] Picture "@ez 999,999,999.99"
	If Upper(_cDipUsr) $ cUserAuth .and. _lMarg // MCVN - 16/04/2008
	  	TRB->Custo   := aTotais[nEmp][02]
			@ li,aColunas[nEmp][03] PSay aTotais[nEmp][02] Picture "@ez 999,999,999.99"
		If aTotais[nEmp][01] > 0 .and. aTotais[nEmp][02] > 0
		 	TRB->Margem := ((aTotais[nEmp][01]/aTotais[nEmp][02])-1)*100
				@ li,aColunas[nEmp][04] PSay ((aTotais[nEmp][01]/aTotais[nEmp][02])-1)*100 Picture '@Ez 9999.99'
		EndIf
	EndIf
Next
MsUnlock()
li++
RecLock("TRB",.T.)
TRB->NomeCD       := ""
MsUnlock()
If li > 65
	li := Cabec(_cTitulo,_cDesc1,_cDesc2,nomeprog,tamanho) + 1
	@ li,aColunas[01][01] PSay _cDesc3
	li+=2
EndIf
@ li,000 PSay Replic("*",Limite)
li++
If li > 65
	li := Cabec(_cTitulo,_cDesc1,_cDesc2,nomeprog,tamanho) + 1
	@ li,aColunas[01][01] PSay _cDesc3
	li+=2
EndIf

For nDesp := 1 to 4
	
	If li > 65
		li := Cabec(_cTitulo,_cDesc1,_cDesc2,nomeprog,tamanho) + 1
		@ li,aColunas[01][01] PSay _cDesc3
		li+=2
	EndIf
	
	@ li,001 PSay aOutros[nDesp][04]
	RecLock("TRB",.T.)
		
	TRB->NomeCD    :=  aOutros[nDesp][04]
	For nEmp := 1 to 3
		@ li,aColunas[nEmp][02] PSay aOutros[nDesp][nEmp] Picture "@ez 999,999,999.99"  
		
	   	If nEmp = 1
			TRB->FaturCD        := aOutros[nDesp][nEmp]
		ElseIf nEmp = 2
			TRB->FaturMT        := aOutros[nDesp][nEmp]
		ElseIf nEmp = 3
			TRB->FaturTOTAL     := aOutros[nDesp][nEmp]
		EndIf
	

	Next nEmp
	li++ 
	MsUnlock()
		RecLock("TRB",.T.)
TRB->CodigoCD       := ""
MsUnlock()
Next nDesp

@ li,000 PSay Replic("*",Limite)
li++
If li > 65
	li := Cabec(_cTitulo,_cDesc1,_cDesc2,nomeprog,tamanho) + 1
	@ li,aColunas[01][01] PSay _cDesc3
	li+=2
EndIf                       

@ li,aColunas[01][01] PSay "Total Geral: "  
	RecLock("TRB",.T.)
		
		TRB->NomeCD    :=  "Total Geral: " 
for nEmp := 1 to 3
	@ li,aColunas[nEmp][02] PSay aOutros[01][nEmp]+aOutros[02][nEmp]+aOutros[03][nEmp]+aOutros[04][nEmp]+aTotais[nEmp][01] Picture "@ez 999,999,999.99"
	If nEmp = 1
		TRB->FaturCD        := aOutros[01][nEmp]+aOutros[02][nEmp]+aOutros[03][nEmp]+aOutros[04][nEmp] + aTotais[nEmp][01]
	ElseIf nEmp = 2
		TRB->FaturMT        := aOutros[01][nEmp]+aOutros[02][nEmp]+aOutros[03][nEmp]+aOutros[04][nEmp] + aTotais[nEmp][01]
	ElseIf nEmp = 3
		TRB->FaturTOTAL     := aOutros[01][nEmp]+aOutros[02][nEmp]+aOutros[03][nEmp]+aOutros[04][nEmp] + aTotais[nEmp][01]
	EndIf


Next nEmp
MsUnlock()
li++

@ li,000 PSay Replic("*",Limite)
li++
If li > 65
	li := Cabec(_cTitulo,_cDesc1,_cDesc2,nomeprog,tamanho) + 1
	@ li,aColunas[01][01] PSay _cDesc3
	li+=2
EndIf                       

@ li,aColunas[01][01] PSay "20 Primeiros "+Transform(Round((aTotais[03][03]/aTotais[03][01])*100,2),"@E 999.99")+"%"

for nEmp := 1 to 3         
	If nEmp == 1
		@ li,aColunas[nEmp][02] PSay aTotais[nEmp][03] Picture "@ez 999,999,999.99"
	ElseIf nEmp == 2                                                              
		@ li,aColunas[nEmp][02] PSay aTotais[nEmp][03] Picture "@ez 999,999,999.99"
	Else	
		@ li,aColunas[nEmp][02] PSay aTotais[nEmp][03] Picture "@ez 999,999,999.99"
	EndIf
Next nEmp
li++

@ li,000 PSay Replic("*",Limite)
li++
If li > 65
	li := Cabec(_cTitulo,_cDesc1,_cDesc2,nomeprog,tamanho) + 1
	@ li,aColunas[01][01] PSay _cDesc3
	li+=2
EndIf                       

aEval(aTotTres, {|x| nTotTres += x[02]})

@ li,aColunas[01][01] PSay "03 Primeiros "+TransForm(Round((nTotTres/aTotais[03,01])*100,2),"@E 999.99")+"%"
@ li,aColunas[01][02] PSay "C๓digo Nome"
@ li,aColunas[01][04] PSay "Total"
li+=2

For nId := 1 to Len(aTotTres)
	
	@ li,aColunas[01][02] PSay aTotTres[nId][01]
	@ li,aColunas[01][04] PSay TransForm(aTotTres[nId][02],"@E 999,999,999.99")+" -> "+;
								TransForm(Round((aTotTres[nId][02]/aTotais[03,01])*100,2),"@E 999.99")+"%"
	li+=2
		 	
Next nId
li++


If li > 65
	li := Cabec(_cTitulo,_cDesc1,_cDesc2,nomeprog,tamanho) + 1
	@ li,aColunas[01][01] PSay _cDesc3
	li+=2
EndIf

@ li,000 PSay Replic("*",Limite)
li++
If li > 65
	li := Cabec(_cTitulo,_cDesc1,_cDesc2,nomeprog,tamanho) + 1
	@ li,aColunas[01][01] PSay _cDesc3
	li+=2
EndIf

Roda(_nReg,Iif(_nReg=1,'Fornecedor',"Fornecedores"),Tamanho)
RptStatus({|lEnd| GerExcel()},Titulo)
Return(.T.)

/////////////////////////////////////////////////////////////////////////////
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuncao    ณVALIDPERG ณ Autor ณ                       ณ Data ณ          ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescricao ณ Verifica as perguntas incluกndo-as caso no existam        ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUso       ณ Especifico para Clientes Microsiga                         ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function AjustaSX1(cPerg)
Local i,j
_sAlias := Alias()
dbSelectArea("SX1")
dbSetOrder(1)

aRegs:={}

//------------ Grupo/Ordem/Pergunta/PERGING/PERGESP/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05/F3

AADD(aRegs,{cPerg,"01","Da Emissao         ?","","","mv_ch1","D", 8,0,0,"G","","mv_par01","","","","","","","","","","","","","",""})
AADD(aRegs,{cPerg,"02","At a Emissao      ?","","","mv_ch2","D", 8,0,0,"G","","mv_par02","","","","","","","","","","","","","",""})
AADD(aRegs,{cPerg,"03","Do FORNECEDOR      ?","","","mv_ch3","C", 6,0,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","",'SA2'})
AADD(aRegs,{cPerg,"04","At o FORNECEDOR   ?","","","mv_ch4","C", 6,0,0,"G","","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","",'SA2'})
AADD(aRegs,{cPerg,"05","Vendedor           ?","","","mv_ch5","C", 6,0,0,"G","","mv_par05","","","","","","","","","","","","","","","","","","","","","","","","",'SA3'})
AADD(aRegs,{cPerg,"06","Cliente            ?","","","mv_ch6","C", 6,0,0,"G","","mv_par06","","","","","","","","","","","","","","","","","","","","","","","","",'SA1'})
Aadd(aRegs,{cPerg, "07","Departamento ?","Departamento ? ","Departamento ? ","mv_ch7" ,"N",1,0,1,"C","","mv_par07","Apoio","","","","","Licita็ใo","","","","","Televendas","","","","","Representantes","","","","","Todos"})
Aadd(aRegs,{cPerg, "08","Gera Excel ?","Gera Excel ?","Gera Excel ?","mv_ch8" ,"N",1,0,1,"C","","mv_par08","Sim","","","","","Nao","","","","","","","","","","","","","","",""})
AADD(aRegs,{cPerg,"09","Grupo de Cliente de :","","","mv_ch9","C", 6,0,0,"G","","mv_par09","","","","","","","","","","","","","","","","","","","","","","","","",'ACY'})
AADD(aRegs,{cPerg,"10","Grupo de Cliente ate :","","","mv_cha","C", 6,0,0,"G","","mv_par10","","","","","","","","","","","","","","","","","","","","","","","","",'ACY'})

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

dbSelectArea(_sAlias)
Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณfQruFat() บ Autor ณJAilton B Santos-JBSบ Data ณ 16/03/2010  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณQuery para ler o total de faturamento no mes por forncedor  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Especifico Faturamento Health Quality                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function fQryFat(_cEmpresa ,_cFilial)
Local lRet    := .F.
Local cQuery  := ""
Local cFilSD2 := ""
Local cFilSF4 := ""
Local nId     := 0

Local _x
ProcRegua(500)

For _x := 1 to 150
	IncProc( "Processando...Faturamento ")
Next

/*If Select("SX2_2") > 0
	SX2_2->( DbCloseArea() )
EndIf*/

cFilSD2 := cFilAnt //fFilial(_cEmpresa,'SD2',_cFilial)
cFilSF4 := cFilAnt //fFilial(_cEmpresa,'SF4',_cFilial)
cFilSB1 := cFilAnt //fFilial(_cEmpresa,'SB1',_cFilial)

cQuery := "SELECT D2_FORNEC,A2_NREDUZ, SUM(Case F4_DUPLIC  when 'S' then D2_TOTAL else 0 End ) T_FATURAMENTO, "
cQuery += "SUM(D2_QUANT * D2_CUSDIP) T_CUSTO,"
cQuery += "SUM(D2_DESPESA) T_DESPESA, SUM(D2_ICMSRET) T_ICMSRET, SUM(D2_VALFRE) T_FRETE,SUM(D2_SEGURO) T_SEGURO " // JBS 03/08/2010 - Considera o D2_TOTAL apenas quando gerar financeiro.

cQuery += "  FROM SD2"+_cEmpresa+" SD2 "

cQuery += "INNER JOIN SF2"+_cEmpresa+" SF2 ON  SF2.F2_FILIAL  = SD2.D2_FILIAL "
cQuery += "                      AND SF2.F2_TIPO IN ('N','C') "
cQuery += "                      AND SF2.F2_FILIAL  = SD2.D2_FILIAL "
cQuery += "                      AND SF2.F2_DOC     = SD2.D2_DOC "
cQuery += "                      AND SF2.F2_SERIE   = SD2.D2_SERIE "
cQuery += "                      AND SF2.F2_EMISSAO BETWEEN '"+dTos(MV_PAR01)+"' AND '"+dTos(MV_PAR02)+"' "

//-- Tratamento, somente listar dados a partir de 01/05/2011 => Daniel Leme: 05/05/2011
If  _cEmpresa + _cFilial == "01001"
	cQuery +=  " AND SF2.F2_EMISSAO >= '20110501'"
EndIf

cQuery += "                      AND SF2.D_E_L_E_T_ = ' '


If !Empty(MV_PAR05)                                   
	cQuery += "						 AND (SF2.F2_VEND1  = '"+ MV_PAR05+ " "
	cQuery += "						 AND (SF2.F2_VEND1  <> '006874' "
EndIf

 
If U_ListVend() != '' // MCVN 15/04/11
	cQuery +=  " 					 AND SF2.F2_VEND1 "     + U_ListVend()+  "  "
	cQuery += " 				AND (CASE WHEN F2_VEND2 <> ' ' AND D2_FORNEC IN('000366','000446','000996') THEN F2_VEND2 ELSE F2_VEND1 END) "+ U_ListVend()+"  "
EndIf
 

If !Empty(MV_PAR06)
	cQuery += "                      AND SF2.F2_CLIENTE  = '" + MV_PAR06 + "' "
EndIf

cQuery += "                      AND SF2.D_E_L_E_T_ = ' ' "
cQuery += "INNER JOIN SC5"+_cEmpresa+" SC5 ON  SC5.C5_FILIAL  = SD2.D2_FILIAL "
cQuery += "                      AND SC5.C5_NUM     = SD2.D2_PEDIDO "
cQuery += "                      AND SC5.D_E_L_E_T_ = ' ' "

//Giovani Zago 28/09/11 filtro por departamento

cQuery +=" INNER JOIN (SELECT (CASE WHEN U7_POSTO = 01 THEN 'APOIO' WHEN U7_POSTO = 02 THEN 'TELEVENDAS' WHEN U7_POSTO = 03  THEN 'LICITAวรO' WHEN U7_POSTO = 04  THEN 'SAC'WHEN U7_POSTO = 05  THEN 'COBRANวA' WHEN U7_POSTO = 06  THEN 'HQ' ELSE 'OUTROS' END)	AS 'POSTO',U7_COD  "
cQuery +=" FROM SU7010 SU7  "
cQuery +=" WHERE SU7.D_E_L_E_T_ = ' '  "
cQuery +=" AND U7_FILIAL        = ' '  "

If MV_PAR07 = 1
	cQuery +=" AND U7_POSTO = 01)TU7 "
ElseIf MV_PAR07 = 2
	cQuery +=" AND U7_POSTO = 03)TU7 "
ElseIf MV_PAR07 = 3
	cQuery +=" AND U7_POSTO = 02)TU7 "
ElseIf MV_PAR07 = 4
	cQuery +=" AND U7_POSTO IN (01,03))TU7 "
ElseIf MV_PAR07 = 5
	If cWCodEmp = '01'
		cQuery +=" AND U7_POSTO IN (01,02,03))TU7 "
	ELSE
		cQuery +=" AND U7_POSTO IN (01,02,03,04,05,06))TU7 "
	EndIf
EndIf
cQuery +=" ON TU7.U7_COD = SC5.C5_OPERADO "


//***********************************************************************************



cQuery += "INNER JOIN SF4"+_cEmpresa+" SF4 ON  SF4.F4_CODIGO  = SD2.D2_TES "
cQuery += "                      AND ( SF4.F4_DUPLIC  = 'S' OR D2_DESPESA + D2_VALFRE + D2_SEGURO > 0 )" // JBS 03/08/2010 - Filtra os D2 que geram financeiro ou os que possuem despesas acessorias.
cQuery += "                      AND SF4.F4_FILIAL  = '"+cFilSF4+"' "
cQuery += "                      AND SF4.D_E_L_E_T_ = ' ' "

cQuery += "INNER JOIN SB1"+_cEmpresa+" SB1 ON  SB1.B1_COD  = SD2.D2_COD"
cQuery += "                      AND SB1.B1_FILIAL  = '"+cFilSB1+"' "
cQuery += "                      AND SB1.D_E_L_E_T_ = ' ' "

cQuery += "INNER JOIN "+RetSqlName('SA2')+" SA2 ON  SA2.A2_COD  = D2_FORNEC" //B1_PROC"
//cQuery += "                      AND SA2.A2_LOJA = B1_LOJPROC"
cQuery += "                      AND SA2.D_E_L_E_T_ = ' ' "
//Giovani Zago 11/10/2011
cQuery += "INNER JOIN "+RetSqlName('SA1')+" SA1 ON  SA1.A1_COD  = D2_CLIENTE" 
cQuery += "                      AND SA1.A1_LOJA = D2_LOJA "
cQuery += "                      AND SA1.A1_FILIAL = '' "
cQuery += "                      AND SA1.D_E_L_E_T_ = ' ' "  
cQuery += "                      AND SA1.A1_GRPVEN  BETWEEN '" + MV_PAR09 + "' AND '" + MV_PAR10 + "' "

//***********************************************************************************************
cQuery += "WHERE SD2.D2_FILIAL = '" + cFilSD2 + "'"

If MV_PAR03 $ '000851/000847/051508' .or. MV_PAR04 $ '000851/000847/051508'
	cQuery += "  AND SD2.D2_FORNEC IN ('000851','000847','051508')"
Else
	cQuery += "  AND SD2.D2_FORNEC BETWEEN '" + MV_PAR03 + "' AND '" + MV_PAR04 + "' "
EndIf
cQuery += "  AND SD2.D_E_L_E_T_ = ' '"

cQuery += " GROUP BY D2_FORNEC,A2_NREDUZ"
cQuery += " ORDER BY T_FATURAMENTO DESC"

If Select("TRB_F") > 0
	TRB_F->( DbCloseArea() )
EndIf

TcQuery cQuery NEW ALIAS "TRB_F"
MemoWrite('DIPR019FAT.SQL',cQuery)

lRet := !TRB_F->( BOF().and.EOF() )
TRB_F->( DbGoTop() )

If !lRet
	lSoma := .F.
EndIf
Return(lRet)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณfQruDev() บ Autor ณJAilton B Santos-JBSบ Data ณ 16/03/2010  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณQuery para ler o total de devolu็coes de cada fornecedor    บฑฑ
ฑฑบ          ณdentro do mes                                               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Especifico Faturamento Health Quality                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function fQryDev(_cEmpresa ,_cFilial)

Local nId     := 0
Local cQuery  := ""
Local cFilSD1 := ""
Local cFilSD2 := ""
Local cFilSF4 := ""
Local lRet    := .F.
Local _x

ProcRegua(500)

For _x := 1 to 150
	IncProc( "Processando...Devolu็๕es ")
Next

cFilSB1 := cFilAnt //fFilial(_cEmpresa,'SB1',_cFilial)  // JBS 03/08/2010
cFilSD1 := cFilAnt //fFilial(_cEmpresa,'SD1',_cFilial)
cFilSD2 := cFilAnt //fFilial(_cEmpresa,'SD2',_cFilial)
cFilSF4 := cFilAnt //fFilial(_cEmpresa,'SF4',_cFilial)

cQuery := "SELECT D2_FORNEC,A2_NREDUZ,SUM( case F4_DUPLIC when 'S' then D1_TOTAL else 0 End) D1_TOTAL, "

cQuery += "SUM(D1_QUANT * D2_CUSDIP) T_CUSTO,"

cQuery += "SUM(D1_DESPESA) T_DESPESA, SUM(D1_ICMSRET) T_ICMSRET, SUM(D1_VALFRE) T_FRETE,SUM(D1_SEGURO) T_SEGURO " // JBS 03/08/2010 - Soma D1_TOTAL apenas para quem gera financeiro

cQuery += "  FROM SD2"+_cEmpresa+" SD2"

cQuery += " INNER JOIN SB1"+_cEmpresa+" SB1 ON  SB1.B1_COD  = SD2.D2_COD"  // JBS 03/08/2010 Criado relacionamento com o SB1
cQuery += "                       AND SB1.B1_FILIAL  = '"+cFilSB1+"' "
cQuery += "                       AND SB1.D_E_L_E_T_ = ' ' "

cQuery += " INNER JOIN "+RetSqlName('SA2')+" SA2 ON  SA2.A2_COD  = B1_PROC" // JBS 03/08/2010 Criado o relacionamento do produto com o fornecedor
cQuery += "                       AND SA2.A2_LOJA = B1_LOJPROC"
cQuery += "                       AND SA2.D_E_L_E_T_ = ' ' "

cQuery += " INNER JOIN SD1"+_cEmpresa+" SD1 ON  SD1.D1_FILIAL  = SD2.D2_FILIAL "
cQuery += "                       AND SD1.D1_NFORI   = SD2.D2_DOC "
cQuery += "                       AND SD1.D1_SERIORI = SD2.D2_SERIE "
cQuery += "                       AND SD1.D1_ITEMORI = SD2.D2_ITEM "
cQuery += "                       AND SD1.D1_TIPO    = 'D' "
cQuery += "                       AND SD1.D1_DTDIGIT BETWEEN '"+dTos(MV_PAR01)+"' AND '"+dTos(MV_PAR02)+"' "

//-- Tratamento , somente listar dados a partir de 01/05/2011 => Daniel Leme: 05/05/2011
If  _cEmpresa + _cFilial == "01001"
	cQuery +=  " AND SD1.D1_DTDIGIT >= '20110501'"
EndIf

//cQuery += "                       AND SD1.D1_FILIAL  = '04' "
cQuery += "                       AND SD1.D1_FILIAL  = '"+cFilSD1+"'"
cQuery += "                       AND SD1.D_E_L_E_T_ = ' ' "

cQuery += " INNER JOIN SC5"+_cEmpresa+" SC5 ON  SC5.C5_FILIAL = SD2.D2_FILIAL "
cQuery += "                       AND SC5.C5_NUM     = SD2.D2_PEDIDO "
cQuery += "                       AND SC5.D_E_L_E_T_ = ' ' "

//Giovani Zago 28/09/11 filtro por departamento

cQuery +=" INNER JOIN (SELECT (CASE WHEN U7_POSTO = 01 THEN 'APOIO' WHEN U7_POSTO = 02 THEN 'TELEVENDAS' WHEN U7_POSTO = 03  THEN 'LICITAวรO' WHEN U7_POSTO = 04  THEN 'SAC'WHEN U7_POSTO = 05  THEN 'COBRANวA' WHEN U7_POSTO = 06  THEN 'HQ' ELSE 'OUTROS' END)	AS 'POSTO',U7_COD  "
cQuery +=" FROM SU7010 SU7  "
cQuery +=" WHERE SU7.D_E_L_E_T_ = ' '  "
cQuery +=" AND U7_FILIAL        = ' '  "

If MV_PAR07 = 1
	cQuery +=" AND U7_POSTO = 01)TU7 "
ElseIf MV_PAR07 = 2
	cQuery +=" AND U7_POSTO = 03)TU7 "
ElseIf MV_PAR07 = 3
	cQuery +=" AND U7_POSTO = 02)TU7 "
ElseIf MV_PAR07 = 4
	cQuery +=" AND U7_POSTO IN (01,03))TU7 "
ElseIf MV_PAR07 = 5
	If cWCodEmp = '01'
		cQuery +=" AND U7_POSTO IN (01,02,03))TU7 "
	ELSE
		cQuery +=" AND U7_POSTO IN (01,02,03,04,05,06))TU7 "
	EndIf
EndIf
cQuery +=" ON TU7.U7_COD = SC5.C5_OPERADO "


//***********************************************************************************
cQuery += " INNER JOIN SF4"+_cEmpresa+" SF4 ON  SF4.F4_CODIGO = SD1.D1_TES "
cQuery += "                       AND ( SF4.F4_DUPLIC  = 'S' or D1_DESPESA + D1_VALFRE + D1_SEGURO  > 0 ) "   // JBS 03/08/2010 - Filtra quem gera financeiro ou Quem nใo Tem Despesas acessorias > 0
//cQuery += "                       AND SF4.F4_FILIAL  = '  ' "
cQuery += "                       AND SF4.F4_FILIAL  = '"+cFilSF4+"'"
cQuery += "                       AND SF4.D_E_L_E_T_ = ' ' "

cQuery += "INNER JOIN SF2"+_cEmpresa+" SF2 ON  SF2.F2_FILIAL  = SD2.D2_FILIAL "
cQuery += "                      AND SF2.F2_TIPO IN ('N','C') "
cQuery += "                      AND SF2.F2_FILIAL  = SD2.D2_FILIAL "
cQuery += "                      AND SF2.F2_DOC     = SD2.D2_DOC "
cQuery += "                      AND SF2.F2_SERIE   = SD2.D2_SERIE "

If !Empty(MV_PAR05)
	cQuery += "						 AND (SF2.F2_VEND1  = '"+ MV_PAR05+ " "
	cQuery += "						 AND (SF2.F2_VEND1  <> '006874' "
EndIf


If U_ListVend() != '' // MCVN 15/04/11
	cQuery +=  " 					 AND SF2.F2_VEND1 "     + U_ListVend()+  "  "
	cQuery += " 				AND (CASE WHEN F2_VEND2 <> ' ' AND D2_FORNEC IN('000366','000446','000996') THEN F2_VEND2 ELSE F2_VEND1 END) "+U_ListVend()+"  "
EndIf


If !Empty(MV_PAR06)
	cQuery += "                      AND SF2.F2_CLIENTE  = '" + MV_PAR06 + "' "
EndIf
cQuery += "                       AND SF2.D_E_L_E_T_ = ' ' "

//Giovani Zago 11/10/2011
cQuery += "INNER JOIN "+RetSqlName('SA1')+" SA1 ON  SA1.A1_COD  = D2_CLIENTE" 
cQuery += "                      AND SA1.A1_LOJA = D2_LOJA "
cQuery += "                      AND SA1.A1_FILIAL = '' "
cQuery += "                      AND SA1.D_E_L_E_T_ = ' ' "  
cQuery += "                      AND SA1.A1_GRPVEN  BETWEEN '" + MV_PAR09 + "' AND '" + MV_PAR10 + "' "

//***********************************************************************************************

//cQuery += " WHERE D2_FILIAL      = '04'"
cQuery += " WHERE D2_FILIAL      = '"+cFilSD2+"'"

If MV_PAR03 $ '000851/000847/051508' .or. MV_PAR04 $ '000851/000847/051508'
	cQuery += "  AND SD2.D2_FORNEC IN ('000851','000847','051508')"
Else

	cQuery += "  AND SD2.D2_FORNEC BETWEEN '" + MV_PAR03 + "' AND '" + MV_PAR04 + "' "
EndIf
cQuery += "   AND SD2.D2_FORNEC BETWEEN '" + MV_PAR03 + "' AND '" + MV_PAR04 + "' "
cQuery += "   AND SD2.D_E_L_E_T_ = ' '"
cQuery += " GROUP BY D2_FORNEC,A2_NREDUZ"
cQuery += " ORDER BY D1_TOTAL DESC"

If Select("TRB_D") > 0
	TRB_D->( DbCloseArea() )
EndIf

TcQuery cQuery NEW ALIAS "TRB_D"
MemoWrite('DIPR019DEV.SQL',cQuery)

lRet := !TRB_D->( BOF().and.EOF() )
TRB_D->( DbGoTop() )

If !lRet
	lSoma := .F.
EndIf
Return(lRet)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณfFilial() บAutor  ณJailton B Santos-JBSบ Data ณ 16/03/2010  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFaz o tratamento para achar a filial para empresa para a    บฑฑ
ฑฑบ          ณqual ira' abrir a tabela informada.                         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametro ณ_cEmpresa: Empresa na qual queremos coletar dados           บฑฑ
ฑฑบ          ณ_cTabela : Nome da tabela da qual queremos coletar dados    บฑฑ
ฑฑบ          ณ_cFilial : Se a tabela for exclusiva, esta eh a filial da   บฑฑ
ฑฑบ          ณ           qual eh preciso coletar dados.                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Especifico - Faturamento - Health Quality                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function fFilial(_cEmpresa,_cTabela,_cFilial)

Local _cNewFilial := Space(2)
/*Local _cFile      := 'SX2'+_cEmpresa
Local _cFileIdx   := _cFile

If Select("SX2_2") = 0
	MsOpEndbf(.T.,"DBFCDX",_cFile,"SX2_2",.T.,.F.)
EndIf

SX2_2->( DbSetOrder(1) )
If SX2_2->( DbSeek(_cTabela) )
	If SX2_2->X2_MODO = 'E'
		_cNewFilial := _cFilial
	EndIf
Else
	_cNewFilial := xFilial(_cTabela)
EndIf*/

Return(_cNewFilial)


Static Function GerExcel(cDesCh)

Private cDestino   := "C:\EXCELL-DBF\"
Private cArqExcell := ""

If mv_par07 = 1
cArqExcell := "\Excell-DBF\Apoio-"+_cDipUsr+"-DIPR019a"
ElseIf mv_par07 = 2
cArqExcell := "\Excell-DBF\Licita็ใo-"+_cDipUsr+"-DIPR019a"
ElseIf mv_par07 = 3
cArqExcell := "\Excell-DBF\Televendas-"+_cDipUsr+"-DIPR019a"
ElseIf mv_par07 = 4
cArqExcell := "\Excell-DBF\Representantes-"+_cDipUsr+"-DIPR019a"
ElseIf mv_par07 = 5
cArqExcell := "\Excell-DBF\Todos-"+_cDipUsr+"-DIPR019a"
 EndIf




If mv_par08 = 1

	DbSelectArea("TRB")
	TRB->(dbGotop())
	ProcRegua(TRB->(RECCOUNT()))	
	aCols := Array(TRB->(RECCOUNT()),Len(_aCampos))
	nColuna := 0
	nLinha := 0
	While TRB->(!Eof())
		nLinha++
		IncProc(OemToAnsi("Gerando planilha excel..."))
		For nColuna := 1 to Len(_aCampos)
			aCols[nLinha][nColuna] := &("TRB->("+_aCampos[nColuna][1]+")")			
		Next nColuna
		TRB->(dbSkip())	
	EndDo
	u_GDToExcel(_aCampos,aCols,Alltrim(FunName()))
	
	DbSelectArea("TRB")   //Giovani Zago 30/08/2011
	ProcRegua(1000)
	For _x := 1 to 1000
		IncProc("Gerando Arquivo. . . ")
	Next
	COPY TO &cArqExcell VIA "DBFCDX"
	//	MsgInfo("Arquivo gerado com sucesso!") //Giovani Zago 30/08/2011
	
	MakeDir(cDestino) // CRIA DIRETำRIO CASO NรO EXISTA
	CpyS2T(cArqExcell+".dbf",cDestino,.T.) // COPIA ARQUIVO PARA MAQUINA DO USUมRIO
	
	Ferase(_cArqTrb+".DBF")
	Ferase(_cArqTrb+OrdBagExt())
	
EndIf
TRB->(DbCloseArea())
    Return()


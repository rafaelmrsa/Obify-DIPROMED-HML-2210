#include "rwmake.ch"
#INCLUDE "TOPCONN.CH"


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ ANACONT  ³ Autor ³ Edson Estevam       ³ Data ³ 23/10/13   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Lista as Contagens Realizadas via ACD Sintetico e analitico ±±
±±³          ³  											 	           ±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ CMP                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function ANACOUNT()

Local oReport

Private _cQuebra := " "

If TRepInUse()	//verifica se relatorios personalizaveis esta disponivel
	oReport := ReportDef()
	oReport:SetTotalInLine(.F.)
	oReport:PrintDialog()
EndIf
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ REPORTDEF³ Autor ³ Edson Estevam         ³ Data ³ 28/09/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao Principal de Impressao                               ±±
±±³          ³                                                             ±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Estoque CMP                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function ReportDef()

Local oReport
Local oSection
Private cPerg    := "XINV14"

ValPerg(cPerg)
Pergunte(cPerg,.F.)

oReport := TReport():New("ANACOUNT","Analise dos Resultados das Contagens realizados no Inventario",cPerg,{|oReport| PrintReport(oReport)},"Este relatorio ira listar as Contagens de Inventario")

oSection2 := TRSection():New(oReport,OemToAnsi("Analise das Contagens realizadas no Inventario"),{"TRB"})

TRCell():New(oSection2,"Filial"      ,"TRB","Filial","@!",05)
TRCell():New(oSection2,"CODINV"      ,"TRB","Codigo Mestre","@!",15)
TRCell():New(oSection2,"EMISSAO"     ,"TRB","Dt.Inventário" ,,14)
TRCell():New(oSection2,"ARMAZEM"     ,"TRB","Armazem","@!",09)
TRCell():New(oSection2,"ENDER"       ,"TRB","Endereço" ,"@!",10)
TRCell():New(oSection2,"PRODUTO"     ,"TRB","Produto" ,"@!",10)
TRCell():New(oSection2,"DESCPRO"     ,"TRB","Descrição" ,"@!",60)
TRCell():New(oSection2,"QTD1"        ,"TRB","Cont a Realizar" ,"@!",15)
TRCell():New(oSection2,"QTD2"        ,"TRB","Cont Realizadas" ,"@!",15)
TRCell():New(oSection2,"USUARIO"     ,"TRB","Operador" ,"@!",10)
TRCell():New(oSection2,"QTD3"        ,"TRB","Quantidade Contada" ,"@!",10)
TRCell():New(oSection2,"STATU"       ,"TRB","Status" ,"@!",10)
TRCell():New(oSection2,"ANALIS"      ,"TRB","Situação" ,"@!",15)


oSection2:Cell("Filial"):SetHeaderAlign("LEFT")
oSection2:Cell("Filial"):SetAlign("LEFT")
oSection2:Cell("CODINV"):SetHeaderAlign("LEFT")
oSection2:Cell("CODINV"):SetAlign("LEFT")
oSection2:Cell("EMISSAO"):SetHeaderAlign("CENTER")
oSection2:Cell("EMISSAO" ):SetAlign("CENTER")
oSection2:Cell("ARMAZEM" ):SetHeaderAlign("LEFT")
oSection2:Cell("ARMAZEM" ):SetAlign("LEFT")
oSection2:Cell("ENDER" ):SetHeaderAlign("LEFT")
oSection2:Cell("ENDER" ):SetAlign("LEFT")
oSection2:Cell("PRODUTO" ):SetHeaderAlign("LEFT")
oSection2:Cell("PRODUTO" ):SetAlign("LEFT")
oSection2:Cell("DESCPRO" ):SetHeaderAlign("LEFT")
oSection2:Cell("DESCPRO" ):SetAlign("LEFT")
oSection2:Cell("QTD1" ):SetHeaderAlign("CENTER")
oSection2:Cell("QTD1" ):SetAlign("CENTER")
oSection2:Cell("QTD2" ):SetHeaderAlign("CENTER")
oSection2:Cell("QTD2" ):SetAlign("CENTER")
oSection2:Cell("USUARIO" ):SetHeaderAlign("LEFT")
oSection2:Cell("USUARIO" ):SetAlign("LEFT")
oSection2:Cell("QTD3" ):SetHeaderAlign("CENTER")
oSection2:Cell("QTD3" ):SetAlign("CENTER")
oSection2:Cell("STATU" ):SetHeaderAlign("LEFT")
oSection2:Cell("STATU" ):SetAlign("LEFT")
oSection2:Cell("ANALIS" ):SetHeaderAlign("LEFT")
oSection2:Cell("ANALIS" ):SetAlign("LEFT")

oBreak1 := TRBreak():New(oSection2,oSection2:Cell("CODINV"),,.F.)

Return oReport


// Impressao do Relatorio

Static Function PrintReport(oReport)

Local oSection2 := oReport:Section(1)


oSection2:SetTotalInLine(.F.)
oReport:OnPageBreak(,.T.)


// Selecao dos dados a Serem Impressos
MsAguarde({|| fSeleDados()},"Selecionando Itens")

// Impressao da Primeira secao
DbSelectArea("TRB")
DbGoTop()
_cQuebra := TRB->CODINV

oReport:SetMeter(RecCount())
oSection2:Init()


If MV_PAR07 == 1
	
	oSection2:Cell("USUARIO"):Disable()
	oSection2:Cell("QTD3"):Disable()
	
Endif


While  !Eof()
	If oReport:Cancel()
		Exit
	EndIf
	oSection2:PrintLine()
	
	If TRB->CODINV <> _cQuebra
		_cQuebra := TRB->CODINV
	Endif
	
	DbSelectArea("TRB")
	DbSkip()
	oReport:IncMeter()
EndDo
oSection2:Finish()

If Sele("TRB") <> 0
	TRB->(DbCloseArea())
Endif

Return


// Selecao dos dados a serem impressos

Static Function fSeleDados()
// Criacao arquivo de Trabalho
_aStru	:= {}

AADD(_aStru,{"Filial"  ,"C",02,0})
AADD(_aStru,{"CODINV"  ,"C",9,0})
AADD(_aStru,{"EMISSAO" ,"D",8,0})
AADD(_aStru,{"ARMAZEM" ,"C",02,0})
AADD(_aStru,{"ENDER"   ,"C",15,0})
AADD(_aStru,{"PRODUTO" ,"C",15,0})
AADD(_aStru,{"DESCPRO" ,"C",60,0})
AADD(_aStru,{"QTD1"    ,"N",12,2})
AADD(_aStru,{"QTD2"    ,"N",12,2})
AADD(_aStru,{"USUARIO" ,"C",20,0})
AADD(_aStru,{"QTD3"    ,"N",12,2})
AADD(_aStru,{"STATU"  ,"C",10,0})
AADD(_aStru,{"ANALIS"  ,"C",15,0})


_cArq     := CriaTrab(_aStru,.T.)
_cIndice  := CriaTrab(Nil,.F.)

If Sele("TRB") <> 0
	TRB->(DbCloseArea())
Endif
_cChaveInd	:= "Filial+CODINV"

dbUseArea(.T.,,_cArq,"TRB",.F.,.F.)
IndRegua("TRB",_cIndice,_cChaveInd,,,"Selecionando Registros...")

_cCgcEmp := Left(SM0->M0_CGC,8)


_nAnalis := MV_PAR06
_cAnalis := Str(_nAnalis)

If MV_PAR07 == 1 // Se for Sintetico
	
	
	_cQuery := " SELECT * "
	_cQuery += " FROM " + RetSQLName ("CBA")
	_cQuery += " WHERE D_E_L_E_T_ = '' "
	_cQuery += " AND CBA_FILIAL = '"+xFilial("CBA")+"'"
	_cQuery += " AND CBA_DATA = '"+DTOS(MV_PAR01)+"' "
	_cQuery += " AND CBA_LOCAL BETWEEN   '"+MV_PAR08+"'  AND '"+MV_PAR09+"'"
	_cQuery += " AND CBA_CODINV BETWEEN  '"+MV_PAR02+"'  AND '"+MV_PAR03+"'"
	_cQuery += " AND CBA_PROD BETWEEN '"+MV_PAR04+"'  AND '"+MV_PAR05+"'"
	_cQuery += " AND CBA_ANALIS = '"+Alltrim(_cAnalis)+"'"
	
	//* Verifica se a Query Existe, se existir fecha
	If Select("TSQL1") > 0
		dbSelectArea("TSQL1")
		DbCloseArea()
	EndIf
	
	//* Cria a Query e da Um Apelido
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,_cQuery),"TSQL1",.F.,.T.)
	
	TSQL1->(dbGotop())
	
	Do While TSQL1->(!Eof())
		    
		
		
		TRB->(RecLock("TRB",.T.))
		    
			DbSelectArea("SB1")
			DbSetOrder(1)
			Dbseek(xFilial("SB1")+ TSQL1->CBA_PROD,.F.)
					
			TRB->Filial		:= TSQL1->CBA_FILIAL //FILIAL
			TRB->CODINV     := TSQL1->CBA_CODINV  // COIDGO MESTRE DE INVENTARIO
			TRB->EMISSAO   	:= STOD(TSQL1->CBA_DATA)//DATA
			TRB->ARMAZEM    := TSQL1->CBA_LOCAL  // ARMAZEM
			TRB->ENDER 		:= TSQL1->CBA_LOCALI  //ENDEREÇO
			TRB->PRODUTO    := TSQL1->CBA_PROD  // PRODUTO
			TRB->DESCPRO    := SB1->B1_DESC  // DESCRIÇÃO DO PRODUTO
			TRB->QTD1       := TSQL1->CBA_CONTS // CONTAGEM A SER REALIZADA
			
			
			_cQuery2 := "SELECT COUNT(DISTINCT CBC_NUM) AS QTDREG " 
			_cQuery2 += " FROM " + RetSQLName ("CBC") 
			_cQuery2 += " WHERE D_E_L_E_T_ = '' "
			_cQuery2 += " AND CBC_FILIAL = '"+xFilial("CBC")+"'"
			_cQuery2 += " AND CBC_CODINV = '"+TSQL1->CBA_CODINV+"'"
			
			//* Verifica se a Query Existe, se existir fecha
				If Select("TSQL2") > 0
				dbSelectArea("TSQL2")
				DbCloseArea()
				EndIf
	
			//* Cria a Query e da Um Apelido
			dbUseArea(.T.,"TOPCONN",TCGENQRY(,,_cQuery2),"TSQL2",.F.,.T.)
						
			TRB->QTD2       := TSQL2->QTDREG  // CONTAGEM REALIZADA
			
					
		If TSQL1->CBA_STATUS == "4"
			TRB->STATU      := "Finalizado"
		Endif
		
		If TSQL1->CBA_STATUS == "3"
			TRB->STATU      := "Contado"
		Endif
		
		If TSQL1->CBA_STATUS == "5"
			TRB->STATU      := "Processado"
		Endif
		
		
		If TSQL1->CBA_ANALIS == "1"
			TRB->ANALIS     := "OK"
		Else
			TRB->ANALIS     := "Divergente"
		Endif
		
		TRB->(MsUnlock())
		
		TSQL1->(DbSkip())
		
	Enddo
	
ELSE
	_cQuery := " SELECT CBA_FILIAL,CBA_CODINV,CBA_DATA,CBA_LOCAL,CBA_LOCALI,CBA_PROD,CBA_CONTS,CBA_CONTR,CBA_STATUS,CBA_ANALIS,CBB_NUM,CBB_USU,CBC_COD,CBC_QUANT "
	_cQuery += " FROM " + RetSQLName ("CBA") + " CBA, " + RetSQLName ("CBB") + " CBB, " + RetSQLName ("CBC") + " CBC "
	_cQuery += " WHERE CBA.D_E_L_E_T_ = '' "
	_cQuery += " AND CBB.D_E_L_E_T_ = '' "
	_cQuery += " AND CBC.D_E_L_E_T_ = '' "
	_cQuery += " AND CBA_FILIAL = '"+xFilial("CBA")+"'"
	_cQuery += " AND CBA_DATA = '"+DTOS(MV_PAR01)+"' "
	_cQuery += " AND CBA_PROD BETWEEN '"+MV_PAR04+"'  AND '"+MV_PAR05+"'"
	_cQuery += " AND CBA_LOCAL  BETWEEN '"+MV_PAR08+"'  AND '"+MV_PAR09+"'"
	_cQuery += " AND CBA_ANALIS = '"+Alltrim(_cAnalis)+"'"
	_cQuery += " AND CBA_CODINV BETWEEN  '"+MV_PAR02+"'  AND '"+MV_PAR03+"'"
	_cQuery += " AND CBA_FILIAL = CBB_FILIAL "
	_cQuery += " AND CBA_CODINV = CBB_CODINV "
	_cQuery += " AND CBB_FILIAL = CBC_FILIAL "
	_cQuery += " AND CBB_NUM = CBC_NUM "
	_cQuery += " ORDER BY CBC_COD "
	
	
	//* Verifica se a Query Existe, se existir fecha
	If Select("TSQL1") > 0
		dbSelectArea("TSQL1")
		DbCloseArea()
	EndIf
	
	//* Cria a Query e da Um Apelido
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,_cQuery),"TSQL1",.F.,.T.)
	
	TSQL1->(dbGotop())
	
	Do While TSQL1->(!Eof())
		
		
		TRB->(RecLock("TRB",.T.))
		
		
		
		If TSQL1->CBA_LOCALI <> ""
			
			DbSelectArea("SB1")
			DbSetOrder(1)
			Dbseek(xFilial("SB1")+ TSQL1->CBC_COD,.F.)
			
			
			TRB->Filial		:= TSQL1->CBA_FILIAL //FILIAL
			TRB->CODINV     := TSQL1->CBA_CODINV  // COIDGO MESTRE DE INVENTARIO
			TRB->EMISSAO   	:= STOD(TSQL1->CBA_DATA)//DATA
			TRB->ARMAZEM    := TSQL1->CBA_LOCAL  // ARMAZEM
			TRB->ENDER 		:= TSQL1->CBA_LOCALI  //ENDEREÇO
			TRB->PRODUTO    := SB1->B1_COD       // PRODUTO
			TRB->DESCPRO    := SB1->B1_DESC     // DESCRIÇÃO DO PRODUTO
			TRB->QTD1       := TSQL1->CBA_CONTS // CONTAGEM A SER REALIZADA
			TRB->QTD3       := TSQL1->CBC_QUANT // QUANTIDADE CONTADA
			
			
			_cQuery2 := "SELECT COUNT(DISTINCT CBC_NUM)  AS QTDREG " 
			_cQuery2 += " FROM " + RetSQLName ("CBC") 
			_cQuery2 += " WHERE D_E_L_E_T_ = '' "
			_cQuery2 += " AND CBC_FILIAL = '"+xFilial("CBC")+"'"
			_cQuery2 += " AND CBC_CODINV = '"+TSQL1->CBA_CODINV+"'"
			
			//* Verifica se a Query Existe, se existir fecha
				If Select("TSQL2") > 0
				dbSelectArea("TSQL2")
				DbCloseArea()
				EndIf
	
			//* Cria a Query e da Um Apelido
			dbUseArea(.T.,"TOPCONN",TCGENQRY(,,_cQuery2),"TSQL2",.F.,.T.)
						
			TRB->QTD2       := TSQL2->QTDREG  // CONTAGEM REALIZADA
			
				
			
		Else
			
			DbSelectArea("SB1")
			DbSetOrder(1)
			Dbseek(xFilial("SB1")+ TSQL1->CBA_PROD,.F.)
			
			
			TRB->Filial		:= TSQL1->CBA_FILIAL //FILIAL
			TRB->CODINV     := TSQL1->CBA_CODINV  // COIDGO MESTRE DE INVENTARIO
			TRB->EMISSAO   	:= STOD(TSQL1->CBA_DATA)//DATA
			TRB->ARMAZEM    := TSQL1->CBA_LOCAL  // ARMAZEM
			TRB->ENDER 		:= TSQL1->CBA_LOCALI  //ENDEREÇO
			TRB->PRODUTO    := TSQL1->CBA_PROD  // PRODUTO
			TRB->DESCPRO    := SB1->B1_DESC     // DESCRIÇÃO DO PRODUTO
			TRB->QTD1       := TSQL1->CBA_CONTS // CONTAGEM A SER REALIZADA
			TRB->QTD3       := TSQL1->CBC_QUANT // QUANTIDADE CONTADA
			
			
			
			_cQuery2 := "COUNT(DISTINCT CBC_NUM)  AS QTDREG " 
			_cQuery2 += " FROM " + RetSQLName ("CBC") 
			_cQuery2 += " WHERE D_E_L_E_T_ = '' "
			_cQuery2 += " AND CBC_FILIAL = '"+xFilial("CBC")+"'"
			_cQuery2 += " AND CBC_CODINV = '"+TSQL1->CBA_CODINV+"'"
			
			
			//* Verifica se a Query Existe, se existir fecha
				If Select("TSQL2") > 0
				dbSelectArea("TSQL2")
				DbCloseArea()
				EndIf
	
			//* Cria a Query e da Um Apelido
			dbUseArea(.T.,"TOPCONN",TCGENQRY(,,_cQuery2),"TSQL2",.F.,.T.)
						
			TRB->QTD2       := TSQL2->QTDREG  // CONTAGEM REALIZADA
				
			
		Endif
		
		
		DbselectArea("CB1")
		DbsetOrder(1)
		DbSeek(xFilial("CB1")+TSQL1->CBB_USU,.F.)
		
		_cNomeUsu := Substr(CB1_NOME,1,10)
		
		TRB->USUARIO    := _cNomeUsu // USUARIO
		
		
		
		If TSQL1->CBA_STATUS == "4"
			TRB->STATU      := "Finalizado"
		Endif
		
		If TSQL1->CBA_STATUS == "3"
			TRB->STATU      := "Contado"
		Endif
		
		If TSQL1->CBA_STATUS == "5"
			TRB->STATU      := "Processado"
		Endif
		
		
		If TSQL1->CBA_ANALIS == "1"
			TRB->ANALIS     := "OK"
		Else
			TRB->ANALIS     := "Divergente"
		Endif
		
		TRB->(MsUnlock())
		
		TSQL1->(DbSkip())
		
	Enddo
	
	
Endif


If Select("TSQL1") > 0
	dbSelectArea("TSQL1")
	DbCloseArea()
EndIf

If Select("TSQL2") > 0
	dbSelectArea("TSQL2")
	DbCloseArea()
EndIf


Return


Static Function ValPerg(cPerg)
Local aHelp	:= {}


PutSx1(cPerg, '01', 'Dt. Inventario        ?','' ,'' , 'mv_ch1', 'D', 08, 0,0, 'G', '', '', '', '', 'mv_par01',,,'','','','','','','','','','','','','','')
PutSx1(cPerg, '02', 'Mestre de             ?','' ,'' , 'mv_ch2', 'C', 09, 0,0, 'G', '', '', '', '', 'mv_par02',,,'','','','','','','','','','','','','','')
PutSx1(cPerg, '03', 'Mestre Até            ?','' ,'' , 'mv_ch3', 'C', 09, 0,0, 'G', '', '', '', '', 'mv_par03',,,'','','','','','','','','','','','','','')
PutSx1(cPerg, '04', 'Produto de            ?','' ,'' , 'mv_ch4', 'C', 15, 0,0, 'G', '', '', '', '', 'mv_par04',,,'','','','','','','','','','','','','','')
PutSx1(cPerg, '05', 'Produto Até           ?','' ,'' , 'mv_ch5', 'C', 15, 0,0, 'G', '', '', '', '', 'mv_par05',,,'','','','','','','','','','','','','','')
PutSx1(cPerg, '06', 'Situação              ?','' ,'' , 'mv_ch6', 'C', 01, 0,0, 'C', '', '', '', '', 'mv_par06','Ok','Ok','Ok','Divergente','Divergente','Divergente','','','','','','','','','','')
PutSx1(cPerg, '07', 'Tipo                  ?','' ,'' , 'mv_ch7', 'C', 01, 0,0, 'C', '', '', '', '', 'mv_par07','Sintetico','Sintetico','Sintetico','Analitico','Analitico','Analitico','','','','','','','','','','')
PutSx1(cPerg, '08', 'Armazem de            ?','' ,'' , 'mv_ch8', 'C', 02, 0,0, 'G', '', '', '', '', 'mv_par08',,,'','','','','','','','','','','','','','')
PutSx1(cPerg, '09', 'Armazem Até           ?','' ,'' , 'mv_ch9', 'C', 02, 0,0, 'G', '', '', '', '', 'mv_par09',,,'','','','','','','','','','','','','','')


Return

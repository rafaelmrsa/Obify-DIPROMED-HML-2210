#include "rwmake.ch"
#INCLUDE "topconn.ch"
#INCLUDE "protheus.ch"
#INCLUDE "fileio.ch"
#INCLUDE "TBICONN.CH"
#INCLUDE "TBICODE.CH"
#INCLUDE "AP5MAIL.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณXREFAMV บAutor  ณDelta Decisใo	   บ Data ณ  21/10/19     บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณAjuste de Movimentos Internos de Tranfer๊ncia               บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณEspecifico para Dipromed                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function BDIPM035() 

Local lRet		:= .T.

Private nOpca 	:= 0

If cFilAnt <> '01'
	Aviso("Aten็ใo","Esta rotina s๓ pode ser executada na Matriz",{"Ok"},3)
	lRet := .F.
ElseIf !(Retcodusr() $ '000001|000385')
	Aviso("Aten็ใo","Esta rotina s๓ pode ser executada pelo Mแximo",{"Ok"},3)
	lRet := .F.
EndIf	

If lRet

	DEFINE MSDIALOG oDlg FROM  96,9 TO 310,592 TITLE OemToAnsi("Ajuste de Movimentos Internos de Tranfer๊ncia") PIXEL
	@ 18, 6 TO 66, 287 LABEL "" OF oDlg  PIXEL
	@ 29, 15 SAY OemToAnsi("Este programa ira ajustar os movimentos internos de transfer๊ncia") SIZE 268, 8 OF oDlg PIXEL
	@ 38, 15 SAY OemToAnsi("entre filiais com base nas datas informadas nos parโmetros.") SIZE 268, 8 OF oDlg PIXEL
	
	DEFINE SBUTTON FROM 80, 223 TYPE 1 ACTION (oDlg:End(),nOpca:=1) ENABLE OF oDlg
	DEFINE SBUTTON FROM 80, 250 TYPE 2 ACTION oDlg:End() ENABLE OF oDlg
	
	ACTIVATE MSDIALOG oDlg CENTER
	
	If nOpca == 1
		VerFech()
	EndIf

EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณXREFAMV บAutor  ณDelta Decisใo	   บ Data ณ  21/10/19     บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณAjuste de Movimentos Internos de Tranfer๊ncia               บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณEspecifico para Dipromed                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function VerFech()

Local cQuery	:= ""
Local _cAlias	:= ""
Local dDtProc	:= CTOD('  /  /  ')

Private oDlgFech
Private cPerg := PADR("XREFAMV",Len(SX1->X1_GRUPO))
Private nOpcb 	:= 0
	
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Verifica e cria perguntas                                           ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
fPerg()
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Carrega perguntas                                                   ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
pergunte(cPerg,.F.)

cQuery := " SELECT TOP 1 B9_DATA FROM " + RetSqlName("SB9") + " WHERE D_E_L_E_T_ = ' ' AND B9_FILIAL IN ('01','04') AND B9_LOCAL = '01' ORDER BY R_E_C_N_O_ DESC " + CRLF 

cQuery := ChangeQuery(cQuery)
_cAlias:= GetNextAlias() 	
If Select(_cAlias) > 0;( _cAlias )->( dbCloseArea() );EndIf
dbUseArea(.t., "TOPCONN", TCGenQry(,,cQuery), _cAlias, .t., .t.)
( _cAlias )->( dbGoTop() )
If ( ( _cAlias )->( !Eof() ) )
	dDtProc := STOD(( _cAlias )->B9_DATA)
EndIf
If Select(_cAlias) > 0;( _cAlias )->( dbCloseArea() );EndIf

If !Empty(dDtProc)
	
	DEFINE MSDIALOG oDlgFech FROM  96,9 TO 310,592 TITLE OemToAnsi("Data de Fechamento") PIXEL
	@ 18, 6 TO 66, 287 LABEL "" OF oDlgFech  PIXEL
	@ 29, 15 SAY OemToAnsi(DTOC(dDtProc)) SIZE 268, 8 OF oDlgFech PIXEL
	
	DEFINE SBUTTON FROM 80, 196 TYPE 5 ACTION Pergunte(cPerg,.T.) ENABLE OF oDlgFech
	DEFINE SBUTTON FROM 80, 223 TYPE 1 ACTION (oDlgFech:End(),nOpcb:=1) ENABLE OF oDlgFech
	DEFINE SBUTTON FROM 80, 250 TYPE 2 ACTION oDlgFech:End() ENABLE OF oDlgFech
	
	ACTIVATE MSDIALOG oDlgFech CENTER
	
	If nOpcb == 1
		BEGIN TRANSACTION
		MsAguarde({|| Processar(dDtProc)},OemtoAnsi("Aguarde Efetuando o ajuste dos Movimentos Internos..."))
		END TRANSACTION
	EndIf

Else
	Aviso("Aten็ใo","Nใo hแ dados na tabela de fechamento de estoque para encontrar a ๚ltima data de fechamento",{"Ok"},3)
EndIf 

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณXREFAMV บAutor  ณDelta Decisใo	   บ Data ณ  21/10/19     บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณAjuste de Movimentos Internos de Tranfer๊ncia               บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณEspecifico para Dipromed                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Processar(dDtFech)

Local dDataDe	:= DTOS(mv_par01)
Local dDataAte	:= DTOS(mv_par02)
Local cQuery	:= ""
Local _cAlias	:= ""
Local _c1Alias	:= ""
Local _c2Alias	:= ""
Local _c3Alias	:= ""
Local c1Query	:= ""
Local aFil1		:= {}
Local aFil4		:= {}
Local nx		:= 0
Local nPos		:= 0
Local cLog		:= ""
Local aProc		:= {}
Local nQueryRet	:= 0
Local cCF		:= ""
Local nCMedio	:= 0

cQuery := " SELECT SD3.R_E_C_N_O_ AS RECSD3, D3_DOC, D3_COD, D3_TM, D3_QUANT FROM " + RetSqlName("SD3") + " SD3 (NOLOCK) WHERE D_E_L_E_T_ = ' ' " + CRLF 
cQuery += " AND D3_EMISSAO BETWEEN '" + dDataDe + "' AND '" + dDataAte + "' " + CRLF
cQuery += " AND D3_FILIAL = '01' AND LEFT(D3_DOC,3) = 'SZP' AND D3_LOCAL = '01' " + CRLF
cQuery += " ORDER BY D3_DOC, D3_COD "

cQuery := ChangeQuery(cQuery)
_cAlias:= GetNextAlias() 	
If Select(_cAlias) > 0;( _cAlias )->( dbCloseArea() );EndIf
dbUseArea(.t., "TOPCONN", TCGenQry(,,cQuery), _cAlias, .t., .t.)
( _cAlias )->( dbGoTop() )
While ( ( _cAlias )->( !Eof() ) )
    aAdd(aFil1,{( _cAlias )->D3_DOC+( _cAlias )->D3_COD,( _cAlias )->RECSD3,( _cAlias )->D3_DOC,( _cAlias )->D3_COD,( _cAlias )->D3_TM,( _cAlias )->D3_QUANT})               
	
	( _cAlias )->( dbSkip() )
EndDo
If Select(_cAlias) > 0;( _cAlias )->( dbCloseArea() );EndIf

cQuery := " SELECT SD3.R_E_C_N_O_ AS RECSD3, D3_DOC, D3_COD, D3_TM, D3_QUANT FROM " + RetSqlName("SD3") + " SD3 (NOLOCK) WHERE D_E_L_E_T_ = ' ' " + CRLF 
cQuery += " AND D3_EMISSAO BETWEEN '" + dDataDe + "' AND '" + dDataAte + "' " + CRLF
cQuery += " AND D3_FILIAL = '04' AND LEFT(D3_DOC,3) = 'SZP' AND D3_LOCAL = '01' " + CRLF
cQuery += " ORDER BY D3_DOC, D3_COD "

cQuery := ChangeQuery(cQuery)
_cAlias:= GetNextAlias() 	
If Select(_cAlias) > 0;( _cAlias )->( dbCloseArea() );EndIf
dbUseArea(.t., "TOPCONN", TCGenQry(,,cQuery), _cAlias, .t., .t.)
( _cAlias )->( dbGoTop() )
While ( ( _cAlias )->( !Eof() ) )
    aAdd(aFil4,{( _cAlias )->D3_DOC+( _cAlias )->D3_COD,( _cAlias )->RECSD3,( _cAlias )->D3_DOC,( _cAlias )->D3_COD,( _cAlias )->D3_TM,( _cAlias )->D3_QUANT})               
	
	( _cAlias )->( dbSkip() )
EndDo
If Select(_cAlias) > 0;( _cAlias )->( dbCloseArea() );EndIf

For nx := 1 to Len(aFil1)
	nPos := Ascan(aFil4,{|x| x[1] == aFil1[nx][1]})
	If nPos == 0
		cLog += "Documento:	" + Alltrim(aFil1[nx][3]) + "	Produto:	" + Alltrim(aFil1[nx][4]) + "	da Filial 01 nใo encontrado na filial 04." + CRLF
	Else	
		aAdd(aProc,{aFil1[nx][2],aFil1[nx][3],aFil1[nx][4],aFil4[nPos][2],aFil1[nx][5],aFil4[nPos][5],aFil1[nx][6],aFil4[nPos][6]})	
	EndIf
Next nx

For nx := 1 to Len(aFil4)
	nPos := Ascan(aFil1,{|x| x[1] == aFil4[nx][1]})
	If nPos == 0
		cLog += "Documento:	" + Alltrim(aFil4[nx][3]) + "	Produto:	" + Alltrim(aFil4[nx][4]) + "	da Filial 04 nใo encontrado na filial 01." + CRLF
	EndIf
Next nx

For nx := 1 to Len(aProc)

	nCMedio := 0
	
	/*
	cQuery := " SELECT CASE WHEN SUM(B9_CM1) = 0  " + CRLF 
	cQuery += " 							THEN ( CASE WHEN (SUM(B9_QINI) = 0 OR SUM(B9_VINI1) = 0) " + CRLF 
	cQuery += " 									THEN ( CASE WHEN SUM(B2_CM1) = 0 THEN 0 ELSE SUM(B2_CM1) END ) " + CRLF
	cQuery += "										ELSE SUM(B9_VINI1)/SUM(B9_QINI) END )" + CRLF   
	cQuery += " 							ELSE SUM(B9_CM1) " + CRLF   	
	cQuery += " 							END AS CUSTOMEDIO FROM " + RetSqlName("SB9") + " SB9 (NOLOCK) " + CRLF  
	cQuery += " INNER JOIN " + RetSqlName("SB2") + " SB2 (NOLOCK) ON SB2.D_E_L_E_T_ = ' ' AND B2_LOCAL = B9_LOCAL AND B2_FILIAL = B9_FILIAL AND B2_COD = B9_COD " + CRLF  							
	cQuery += " WHERE SB9.D_E_L_E_T_ = ' ' " + CRLF  
	cQuery += " AND B9_DATA = '" + DTOS(dDtFech) + "'  " + CRLF 
	cQuery += " AND B9_FILIAL IN ('01') AND B9_COD = '" + aProc[nx][3] + "' AND B9_LOCAL = '01'  " + CRLF 
	cQuery += " GROUP BY B9_DATA, B9_COD  " + CRLF
	*/
	
	cQuery := " SELECT CASE WHEN SUM(B2_CM1) = 0  " + CRLF 
	cQuery += " 							THEN ( CASE WHEN (SUM(B9_QINI) = 0 OR SUM(B9_VINI1) = 0) " + CRLF 
	cQuery += " 									THEN ( CASE WHEN SUM(B9_CM1) = 0 THEN 0 ELSE SUM(B9_CM1) END ) " + CRLF
	cQuery += "										ELSE SUM(B9_VINI1)/SUM(B9_QINI) END )" + CRLF   
	cQuery += " 							ELSE SUM(B2_CM1) " + CRLF   	
	cQuery += " 							END AS CUSTOMEDIO FROM " + RetSqlName("SB9") + " SB9 (NOLOCK) " + CRLF  
	cQuery += " INNER JOIN " + RetSqlName("SB2") + " SB2 (NOLOCK) ON SB2.D_E_L_E_T_ = ' ' AND B2_LOCAL = B9_LOCAL AND B2_FILIAL = B9_FILIAL AND B2_COD = B9_COD " + CRLF  							
	cQuery += " WHERE SB9.D_E_L_E_T_ = ' ' " + CRLF  
	cQuery += " AND B9_DATA = '" + DTOS(dDtFech) + "'  " + CRLF 
	cQuery += " AND B9_FILIAL IN ('01') AND B9_COD = '" + aProc[nx][3] + "' AND B9_LOCAL = '01'  " + CRLF 
	cQuery += " GROUP BY B9_DATA, B9_COD  " + CRLF 
	
	cQuery := ChangeQuery(cQuery)
	_cAlias:= GetNextAlias() 	
	If Select(_cAlias) > 0;( _cAlias )->( dbCloseArea() );EndIf
	dbUseArea(.t., "TOPCONN", TCGenQry(,,cQuery), _cAlias, .t., .t.)
	( _cAlias )->( dbGoTop() )
	If ( ( _cAlias )->( !Eof() ) )
	
		If ( _cAlias )->CUSTOMEDIO = 0	
			c1Query := " SELECT TOP1 CASE WHEN (SUM(D1_CUSTO) = 0 THEN 0 ELSE SUM(D1_CUSTO)/SUM(D1_QUANT) END AS CUSTOMEDIO )  " + CRLF 
			c1Query += " 		FROM " + RetSqlName("SD1") + " SD1 (NOLOCK) " + CRLF
			c1Query += " INNER JOIN " + RetSqlName("SF4") + " SF4 (NOLOCK) ON SF4.D_E_L_E_T_ = ' ' AND F4_CODIGO = D1_TES AND F4_ESTOQUE = 'S' " + CRLF  										
			c1Query += " WHERE SD1.D_E_L_E_T_ = ' ' " + CRLF  
			c1Query += " AND D1_FILIAL IN ('01') AND D1_COD = '" + aProc[nx][3] + "' AND D1_LOCAL = '01'  " + CRLF 
			c1Query += " ORDER BY SD1.R_E_C_N_O_ DESC " + CRLF 
			
			c1Query := ChangeQuery(c1Query)
			_c2Alias:= GetNextAlias() 	
			If Select(_c2Alias) > 0;( _c2Alias )->( dbCloseArea() );EndIf
			dbUseArea(.t., "TOPCONN", TCGenQry(,,c1Query), _c2Alias, .t., .t.)
			( _c2Alias )->( dbGoTop() )
			If ( ( _c2Alias )->( !Eof() ) )
				nCMedio := ( _c2Alias )->CUSTOMEDIO
			EndIf
			If Select(_c2Alias) > 0;( _c2Alias )->( dbCloseArea() );EndIf
		Else
			nCMedio := ( _cAlias )->CUSTOMEDIO
		EndIf		
		
		cQuery := " SELECT CASE WHEN SUM(B2_CM1) = 0  " + CRLF 
		cQuery += " 							THEN ( CASE WHEN (SUM(B9_QINI) = 0 OR SUM(B9_VINI1) = 0) " + CRLF 
		cQuery += " 									THEN ( CASE WHEN SUM(B9_CM1) = 0 THEN 0 ELSE SUM(B9_CM1) END ) " + CRLF
		cQuery += "										ELSE SUM(B9_VINI1)/SUM(B9_QINI) END )" + CRLF   
		cQuery += " 							ELSE SUM(B2_CM1) " + CRLF   	
		cQuery += " 							END AS CUSTOMEDIO FROM " + RetSqlName("SB9") + " SB9 (NOLOCK) " + CRLF  
		cQuery += " INNER JOIN " + RetSqlName("SB2") + " SB2 (NOLOCK) ON SB2.D_E_L_E_T_ = ' ' AND B2_LOCAL = B9_LOCAL AND B2_FILIAL = B9_FILIAL AND B2_COD = B9_COD " + CRLF
		cQuery += " INNER JOIN " + RetSqlName("SD3") + " SD3 (NOLOCK) ON SD3.D_E_L_E_T_ = ' ' AND D3_LOCAL = B9_LOCAL AND D3_FILIAL = B9_FILIAL AND D3_COD = B9_COD " + CRLF		
		cQuery += " WHERE SB9.D_E_L_E_T_ = ' ' " + CRLF  
		cQuery += " AND B9_DATA = '" + DTOS(dDtFech) + "'  " + CRLF 
		cQuery += " AND B9_FILIAL IN ('04') AND B9_COD = '" + aProc[nx][3] + "' AND B9_LOCAL = '01'  " + CRLF 
		cQuery += " AND D3_CF = 'RE6' AND D3_TM = '501' AND SUBSTRING(D3_DOC,1,3) = 'SZP'  " + CRLF	
		cQuery += " GROUP BY B9_DATA, B9_COD  " + CRLF 
		
		cQuery := ChangeQuery(cQuery)
		_c3Alias:= GetNextAlias() 	
		If Select(_c3Alias) > 0;( _c3Alias )->( dbCloseArea() );EndIf
		dbUseArea(.t., "TOPCONN", TCGenQry(,,cQuery), _c3Alias, .t., .t.)
		( _c3Alias )->( dbGoTop() )
		If ( ( _c3Alias )->( !Eof() ) )		
			nCMedio := ( _c3Alias )->CUSTOMEDIO
		EndIf
		If Select(_c3Alias) > 0;( _c3Alias )->( dbCloseArea() );EndIf

		If nCMedio > 0
			
			cQuery := " SELECT R_E_C_N_O_ AS RECSD3, D3_QUANT, D3_TM FROM " + RetSqlName("SD3") + " SD3 (NOLOCK) " + CRLF 
			cQuery += " WHERE D_E_L_E_T_ = ' ' " + CRLF 
			cQuery += " AND D3_DOC = '" + aProc[nx][2] + "' AND D3_COD = '" + aProc[nx][3] + "' " + CRLF
			cQuery += " AND D3_FILIAL = '01' AND D3_LOCAL = '01' " + CRLF
			
			cQuery := ChangeQuery(cQuery)
			_c1Alias:= GetNextAlias() 	
			If Select(_c1Alias) > 0;( _c1Alias )->( dbCloseArea() );EndIf
			dbUseArea(.t., "TOPCONN", TCGenQry(,,cQuery), _c1Alias, .t., .t.)
			( _c1Alias )->( dbGoTop() )
			While ( ( _c1Alias )->( !Eof() ) )
			
				If Val(( _c1Alias )->D3_TM) < 501
					cCF := "DE6"
				Else
					cCF := "RE6"
				EndIf
				
				If Val(( _c1Alias )->D3_TM) >= 501 
			
					nQueryRet := TcSqlExec("UPDATE " + RetSqlName("SD3") + " SET D3_CUSTO1 = " + Alltrim(Str(nCMedio*( _c1Alias )->D3_QUANT)) + " , D3_CF = '" + cCF + "' WHERE D3_FILIAL = '01' AND R_E_C_N_O_ =  " + cValtoChar(( _c1Alias )->RECSD3))
				
					If nQueryRet < 0					
						cLog += "Erro ao atualizar custo na filial 01 para o produto: " + Alltrim(aProc[nx][3]) + CRLF
					EndIf
				
				EndIf
				
				( _c1Alias )->( dbSkip() )
			EndDo
			If Select(_c1Alias) > 0;( _c1Alias )->( dbCloseArea() );EndIf
			
			cQuery := " SELECT R_E_C_N_O_ AS RECSD3, D3_QUANT, D3_TM FROM " + RetSqlName("SD3") + " SD3 (NOLOCK) " + CRLF 
			cQuery += " WHERE D_E_L_E_T_ = ' ' " + CRLF 
			cQuery += " AND D3_DOC = '" + aProc[nx][2] + "' AND D3_COD = '" + aProc[nx][3] + "' " + CRLF
			cQuery += " AND D3_FILIAL = '04' AND D3_LOCAL = '01' " + CRLF
			
			cQuery := ChangeQuery(cQuery)
			_c1Alias:= GetNextAlias() 	
			If Select(_c1Alias) > 0;( _c1Alias )->( dbCloseArea() );EndIf
			dbUseArea(.t., "TOPCONN", TCGenQry(,,cQuery), _c1Alias, .t., .t.)
			( _c1Alias )->( dbGoTop() )
			While ( ( _c1Alias )->( !Eof() ) )
			
				If Val(( _c1Alias )->D3_TM) < 501
					cCF := "DE6"
				Else
					cCF := "RE6"
				EndIf
				
				If Val(( _c1Alias )->D3_TM) < 501 
			
					nQueryRet := TcSqlExec("UPDATE " + RetSqlName("SD3") + " SET D3_CUSTO1 = " + Alltrim(Str(nCMedio*( _c1Alias )->D3_QUANT)) + " , D3_CF = '" + cCF + "' WHERE D3_FILIAL = '04' AND R_E_C_N_O_ =  " + cValtoChar(( _c1Alias )->RECSD3))
				
					If nQueryRet < 0					
						cLog += "Erro ao atualizar custo na filial 04 para o produto: " + Alltrim(aProc[nx][3]) + CRLF
					EndIf
					
				EndIf
				
				( _c1Alias )->( dbSkip() )
			EndDo
			If Select(_c1Alias) > 0;( _c1Alias )->( dbCloseArea() );EndIf

		EndIf
		
	Else
		cLog += "Produto:	" + Alltrim(aProc[nx][3]) + "	nใo encontrado na tabela de Saldos Iniciais (SB9)." + CRLF
	EndIf
	If Select(_cAlias) > 0;( _cAlias )->( dbCloseArea() );EndIf

Next nx

If !Empty(cLog)
	MostraLog(cLog)
EndIf

/*
Local dDataDe	:= DTOS(mv_par01)
Local dDataAte	:= DTOS(mv_par02)
Local cQuery	:= ""
Local _cAlias	:= ""
Local _c1Alias	:= ""
Local _c2Alias	:= ""
Local c1Query	:= ""
Local aFil1		:= {}
Local aFil4		:= {}
Local nx		:= 0
Local nPos		:= 0
Local cLog		:= ""
Local aProc		:= {}
Local nQueryRet	:= 0
Local cCF		:= ""
Local nCMedio	:= 0

cQuery := " SELECT SD3.R_E_C_N_O_ AS RECSD3, D3_DOC, D3_COD, D3_TM, D3_QUANT, D3_CUSTO1 FROM " + RetSqlName("SD3") + " SD3 (NOLOCK) WHERE D_E_L_E_T_ = ' ' " + CRLF 
cQuery += " AND D3_EMISSAO BETWEEN '" + dDataDe + "' AND '" + dDataAte + "' " + CRLF
cQuery += " AND D3_FILIAL = '01' AND LEFT(D3_DOC,3) = 'SZP' AND D3_LOCAL = '01' " + CRLF
cQuery += " ORDER BY D3_DOC, D3_COD "

cQuery := ChangeQuery(cQuery)
_cAlias:= GetNextAlias() 	
If Select(_cAlias) > 0;( _cAlias )->( dbCloseArea() );EndIf
dbUseArea(.t., "TOPCONN", TCGenQry(,,cQuery), _cAlias, .t., .t.)
( _cAlias )->( dbGoTop() )
While ( ( _cAlias )->( !Eof() ) )
    aAdd(aFil1,{( _cAlias )->D3_DOC+( _cAlias )->D3_COD,( _cAlias )->RECSD3,( _cAlias )->D3_DOC,( _cAlias )->D3_COD,( _cAlias )->D3_TM,( _cAlias )->D3_QUANT,( _cAlias )->D3_CUSTO1})               
	
	( _cAlias )->( dbSkip() )
EndDo
If Select(_cAlias) > 0;( _cAlias )->( dbCloseArea() );EndIf

cQuery := " SELECT SD3.R_E_C_N_O_ AS RECSD3, D3_DOC, D3_COD, D3_TM, D3_QUANT, D3_CUSTO1 FROM " + RetSqlName("SD3") + " SD3 (NOLOCK) WHERE D_E_L_E_T_ = ' ' " + CRLF 
cQuery += " AND D3_EMISSAO BETWEEN '" + dDataDe + "' AND '" + dDataAte + "' " + CRLF
cQuery += " AND D3_FILIAL = '04' AND LEFT(D3_DOC,3) = 'SZP' AND D3_LOCAL = '01' " + CRLF
cQuery += " ORDER BY D3_DOC, D3_COD "

cQuery := ChangeQuery(cQuery)
_cAlias:= GetNextAlias() 	
If Select(_cAlias) > 0;( _cAlias )->( dbCloseArea() );EndIf
dbUseArea(.t., "TOPCONN", TCGenQry(,,cQuery), _cAlias, .t., .t.)
( _cAlias )->( dbGoTop() )
While ( ( _cAlias )->( !Eof() ) )
    aAdd(aFil4,{( _cAlias )->D3_DOC+( _cAlias )->D3_COD,( _cAlias )->RECSD3,( _cAlias )->D3_DOC,( _cAlias )->D3_COD,( _cAlias )->D3_TM,( _cAlias )->D3_QUANT,( _cAlias )->D3_CUSTO1})               
	
	( _cAlias )->( dbSkip() )
EndDo
If Select(_cAlias) > 0;( _cAlias )->( dbCloseArea() );EndIf

For nx := 1 to Len(aFil1)
	nPos := Ascan(aFil4,{|x| x[1] == aFil1[nx][1]})
	If nPos == 0
		cLog += "Documento:	" + Alltrim(aFil1[nx][3]) + "	Produto:	" + Alltrim(aFil1[nx][4]) + "	da Filial 01 nใo encontrado na filial 04." + CRLF
	Else	
		aAdd(aProc,{aFil1[nx][2],aFil1[nx][3],aFil1[nx][4],aFil4[nPos][2],aFil1[nx][5],aFil4[nPos][5],aFil1[nx][6],aFil4[nPos][6],aFil4[nPos][7]})	
	EndIf
Next nx

For nx := 1 to Len(aFil4)
	nPos := Ascan(aFil1,{|x| x[1] == aFil4[nx][1]})
	If nPos == 0
		cLog += "Documento:	" + Alltrim(aFil4[nx][3]) + "	Produto:	" + Alltrim(aFil4[nx][4]) + "	da Filial 04 nใo encontrado na filial 01." + CRLF
	EndIf
Next nx

For nx := 1 to Len(aProc)
			
	cQuery := " SELECT R_E_C_N_O_ AS RECSD3, D3_QUANT, D3_TM FROM " + RetSqlName("SD3") + " SD3 (NOLOCK) " + CRLF 
	cQuery += " WHERE D_E_L_E_T_ = ' ' " + CRLF 
	cQuery += " AND D3_DOC = '" + aProc[nx][2] + "' AND D3_COD = '" + aProc[nx][3] + "' " + CRLF
	cQuery += " AND D3_FILIAL = '01' AND D3_LOCAL = '01' " + CRLF
	
	cQuery := ChangeQuery(cQuery)
	_c1Alias:= GetNextAlias() 	
	If Select(_c1Alias) > 0;( _c1Alias )->( dbCloseArea() );EndIf
	dbUseArea(.t., "TOPCONN", TCGenQry(,,cQuery), _c1Alias, .t., .t.)
	( _c1Alias )->( dbGoTop() )
	While ( ( _c1Alias )->( !Eof() ) )
	
		nQueryRet := TcSqlExec("UPDATE " + RetSqlName("SD3") + " SET D3_CUSTO1 = " + Alltrim(Str(aProc[nx][9])) + " WHERE D3_FILIAL = '01' AND R_E_C_N_O_ =  " + cValtoChar(( _c1Alias )->RECSD3))
	
		If nQueryRet < 0					
			cLog += "Erro ao atualizar custo na filial 01 para o produto: " + Alltrim(aProc[nx][3]) + CRLF
		EndIf
		
		( _c1Alias )->( dbSkip() )
	EndDo
	If Select(_c1Alias) > 0;( _c1Alias )->( dbCloseArea() );EndIf			            

Next nx

If !Empty(cLog)
	MostraLog(cLog)
EndIf
*/

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณXREFAMV บAutor  ณDelta Decisใo	   บ Data ณ  21/10/19     บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณAjuste de Movimentos Internos de Tranfer๊ncia               บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณEspecifico para Dipromed                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function fPerg()

Local aRegs := {}

// Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05
aAdd(aRegs,{ cPerg,'01','Data Mov. De   ?','','','mv_ch1','D',08,0,0,'G','NaoVazio'   		,'mv_par01',''                 ,'','','','',''                 ,'','','','',''                    ,'','','','',''                 ,'','','','',''      ,'','','' ,'   ','' })
aAdd(aRegs,{ cPerg,'02','Data Mov Ate   ?','','','mv_ch2','D',08,0,0,'G','NaoVazio'   		,'mv_par02',''                 ,'','','','',''                 ,'','','','',''                    ,'','','','',''                 ,'','','','',''      ,'','','' ,'   ','' })

dbSelectArea("SX1")
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

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณXREFAMV บAutor  ณDelta Decisใo	   บ Data ณ  21/10/19     บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณAjuste de Movimentos Internos de Tranfer๊ncia               บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณEspecifico para Dipromed                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function MostraLog(cLog)

Local nOpc		:= 0
Local lRet     	:= .T.
Local cBitMap  	:= ""
Local nEst		:= 0
Local n1 		:= 620
Local n2 		:= 380
Local n3 		:= 48
Local n4 		:= 488
Local n5 		:= 25
Local n6 		:= 50
Local n7 		:= 26
Local n8 		:= 500
Local n9 		:= 35
Local n10 		:= 50
Local n11 		:= 125
Local n12 		:= 200
Local n13 		:= 297
Local n14 		:= 120
Local n15 		:= 150
Local n16 		:= 125
Local n17 		:= 50
Local n18 		:= 125
Local n19 		:= 80
Local n20		:= 27
Local n21		:= 117
Local n22		:= 207
Local n24		:= 215
Local n25		:= 305
Local lPrim		:= .T.
	
DEFINE FONT oFont NAME "Arial" SIZE 0, -11

cBitmap := "PROJETOAP"

DEFINE MSDIALOG oDlgMot TITLE OemtoAnsi("Log Nใo Processados") FROM 0,0 TO n1,n2 OF oMainWnd PIXEL 
@ 0 , 0 BITMAP oBmp RESNAME cBitMap OF oDlgMot SIZE n3,n4 NOBORDER WHEN .F. PIXEL
@ n5,n6 TO n7,n8 OF oDlgMot Pixel	

@ n9,n10 GET oMemoMot VAR cLog MEMO SIZE n11,n12 PIXEL OF oDlgMot WHEN .F.	

DEFINE SBUTTON oBut2 FROM n13, n14 TYPE 1 ENABLE OF oDlgMot PIXEL ACTION (nOpc:=1,oDlgMot:End())
DEFINE SBUTTON oBut3 FROM n13, n15 TYPE 2 ENABLE OF oDlgMot PIXEL ACTION (oDlgMot:End())

ACTIVATE MSDIALOG oDlgMot CENTERED

Return
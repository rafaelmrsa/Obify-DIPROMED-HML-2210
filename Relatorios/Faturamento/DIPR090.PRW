/*====================================================================================\
|Programa  | DIPR087       | Autor | Reginaldo Borges           | Data | 12/09/2016   |
|=====================================================================================|
|Descrição | Evolucao de vendas por fornecedor mes a mes e total do ano.              |
|          |                                                                          |
|          |                                                                          |
|=====================================================================================|
|Sintaxe   | DIPR087                                                                  |
|=====================================================================================|
|Uso       | Especifico DIPROMED                                                      |
|=====================================================================================|
|...Nome.................................Histórico....................................|
|		   | 																		  |
\====================================================================================*/

#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#include "RWMAKE.ch"
#INCLUDE "AP5MAIL.CH"
#INCLUDE "TBICONN.CH"
//--------------------------------------------------------------------

User Function DIPR090() 

Local   _xArea	  := GetArea()
Local   oDlg
Local   cUserAut  := GetMV("MV_URELFAT")
Local   titulo	  := OemTOAnsi("Evolução de Vendas",72)
Local   cDesc1	  := OemToAnsi("Este programa tem como objetivo emitir um relatorio",72)
Local   cDesc2	  := OemToAnsi("da eveloucao de vendas de 1 ano por fornecedor.",72)
Local   nOpcao    := 0
Private aFat      := {}
Private aDev      := {}
Private aTotGeral := {}
Private aTotFat   := {}
Private aPercFat  := {}
Private aMarg     := {}
Private aPercMag  := {}
Private li        := 465
Private tamanho   := "G"
Private limite    := 3000
Private nomeprog  := "DIPR090"
Private cPerg     := U_FPADR( "DIPR90","SX1","SX1->X1_GRUPO"," " )
Private nLastKey  := 0
Private wnrel     := "DIPR090"
Private ArialN6   := TFont():New("Arial"          ,,08,,.F.,,,,,.F.)
Private ArialN6B  := TFont():New("Arial"	      ,,08,,.T.,,,,,.F.)
Private ArialN8   := TFont():New("Arial"	      ,,09,,.F.,,,,,.F.)
Private ArialN9   := TFont():New("Arial"	      ,,11,,.F.,,,,,.F.)
Private ArialN8B  := TFont():New("Arial"	      ,,10,,.T.,,,,,.F.)
Private ArialN10  := TFont():New("Arial"          ,,12,,.F.,,,,,.F.)
Private ArialN10B := TFont():New("Arial"	      ,,12,,.T.,,,,,.F.)
Private ArialN12  := TFont():New("Arial"	      ,,14,,.F.,,,,,.F.)
Private ArialN12B := TFont():New("Arial"          ,,14,,.T.,,,,,.F.)
Private ArialN14  := TFont():New("Arial"	      ,,16,,.F.,,,,,.F.)
Private ArialN14B := TFont():New("Arial"          ,,16,,.T.,,,,,.F.)
Private ArialN16  := TFont():New("Arial"	      ,,18,,.F.,,,,,.F.)
Private ArialN16B := TFont():New("Arial"	      ,,18,,.T.,,,,,.F.)
Private ArialN18  := TFont():New("Arial"	      ,,22,,.F.,,,,,.F.)
Private ArialN18B := TFont():New("Arial"	      ,,22,,.T.,,,,,.F.)
Private ArialN20  := TFont():New("Arial"	      ,,22,,.F.,,,,,.F.)
Private ArialN20B := TFont():New("Arial"	      ,,22,,.T.,,,,,.F.)
Private Times14	  := TFont():New("Times New Roman",,16,,.T.,,,,,.F.)
Private Times20   := TFont():New("Times New Roman",,22,,.T.,,,,,.F.)
Private CourN08B  := TFont():New("Courier New"    ,,10,,.T.,,,,.T.,.F.)
Private CourN10B  := TFont():New("Courier New"    ,,12,,.F.,,,,.T.,.F.)
Private _cDipUsr  := U_DipUsr()
Private cPrefixo  := _cDipUsr+"DIPR090"
Private cMes      := Space(2)
Private cAno      := Space(4)
Private cForneI   := Space(6)
Private cForneF   := Space(6)
Private nTotalFat := 0

If !(Upper(_cDipUsr) $ cUserAut)
	Alert(Upper(_cDipUsr)+", você não tem autorização para utilizar esta rotina. Qualquer dúvida falar com Departamento de T.I.!","Atenção")
	Return(Nil)
EndIF

U_DIPPROC(ProcName(0),_cDipUsr)

Define msDialog oDlg title OemToAnsi("Evolução de Vendas") From 10,10 TO 22,43

@ 002,002 to 090,130

@ 010,010 say "Informe o mes       "
@ 025,010 say "Informe o ano       "
@ 040,010 say "Fornecedor de       "
@ 055,010 say "Fornecedro ate      "
@ 010,070 get cMes valid cMes>='01'.and.cMes<='12' Size 10,08
@ 025,070 get cAno valid !empty(cAno) size 20,08
@ 040,070 get cForneI F3 "SA2"
@ 055,070 get cForneF F3 "SA2"

Define sbutton oBt1 from 075,065 type 1 action (nOpcao := 1, oDlg:End()) enable of oDlg
Define sbutton oBt2 from 075,097 type 2 action (nOpcao := 0, oDlg:End()) enable of oDlg

Activate Dialog oDlg Centered

If nOpcao = 0
	Return(.t.)
EndIf


oPrint := FWMSPrinter():New(cPrefixo,6,.T.,,.T.)
oPrint :SetLandScape() //paisagem
oPrint :Setup()
MakeDir("C:\Relatorios\")
oPrint :cPathPDF:="C:\Relatorios\"

Processa({|lEnd| RunProc(cMes,cAno)},"Selecionando dados...")
If len(aTotGeral) > 0
	RptStatus({|lEnd| RptDetail()},"Imprimindo...")
EndIf

Return(Nil)


///////////////////////////
Static Function RunProc(cMes,cAno)

Local _nMesI   := 0
Local _nAnoI   := 0
Local _nMesIni := 0
Local _nAnoIni := 0
Local _nAnoFin := 0
Local nFornecI := Val(cForneI)
Local nFornecF := Val(cForneF)
Local _nPos    := 0
Local nMesMed  := 1
Local cFornecA := "" 
Local cNreduz  := "" 
Local nFatMes  := 0
Local nCutMes  := 0
Local nDevMes  := 0
Local xi       := 0
Local nI       := 0

_nMesIni := Val(cMes)
_nAnoIni := Val(cAno)-1
_nAnoFin := Val(cAno)
nMesMed  := 1


cSQL := " SELECT TOP 28 "
cSQL += " CASE WHEN D2_FORNEC IN('100278','000557','000830','000835') THEN '000835' ELSE ( "
cSQL += " CASE WHEN D2_FORNEC IN('000334','000338','100015','100209') THEN '100209' ELSE ( "
cSQL += " CASE WHEN D2_FORNEC IN('000261','000993','007624') THEN '007624' ELSE( "
cSQL += " CASE WHEN D2_FORNEC IN('000094','000624','000661','548580') THEN '548580' ELSE ( "
cSQL += " CASE WHEN D2_FORNEC IN('000349','000754') THEN '000754' ELSE ( "
cSQL += " CASE WHEN D2_FORNEC IN('100144','100205') THEN '100144' ELSE ( "
//cSQL += " CASE WHEN D2_FORNEC IN('000021','465686') THEN '465686' ELSE ( "
cSQL += " CASE WHEN D2_FORNEC IN('000271','000701','002028','002038') THEN '000701'ELSE ( "
cSQL += " CASE WHEN D2_FORNEC IN('002022','100232') THEN '100232' ELSE ( "
cSQL += " CASE WHEN D2_FORNEC IN('100630','000630') THEN '100630' ELSE ( "
cSQL += " CASE WHEN D2_FORNEC IN('000036') THEN '000036' ELSE "
cSQL += " D2_FORNEC END) END) END) END) END) END) END) END) END) END AS D2_FORNEC, "

cSQL += " CASE WHEN D2_FORNEC IN('100278','000557','000830','000835') THEN 'LABOR IMPORT' ELSE ( "
cSQL += " CASE WHEN D2_FORNEC IN('000334','000338','100015','100209') THEN 'ROCHE' ELSE ( "
cSQL += " CASE WHEN D2_FORNEC IN('000261','000993','007624') THEN 'NIPRO' ELSE( "
cSQL += " CASE WHEN D2_FORNEC IN('000094','000624','000661','548580') THEN 'NEVE' ELSE ( "
cSQL += " CASE WHEN D2_FORNEC IN('000349','000754') THEN 'NATHALIA' ELSE ( "
cSQL += " CASE WHEN D2_FORNEC IN('100144','100205') THEN 'MEDIX' ELSE ( "
//cSQL += " CASE WHEN D2_FORNEC IN('000021','465686') THEN 'LAMEDID' ELSE ( "
cSQL += " CASE WHEN D2_FORNEC IN('000271','000701','002028','002038') THEN 'KOLPLAST' ELSE ( "
cSQL += " CASE WHEN D2_FORNEC IN('002022','100232') THEN 'MARDAM' ELSE ( "
cSQL += " CASE WHEN D2_FORNEC IN('100630','000630') THEN 'AMED' ELSE ( "
cSQL += " CASE WHEN D2_FORNEC IN('000036') THEN 'MUCAMBO' " 
cSQL += " ELSE A2_NREDUZ END) END) END) END) END) END) END) END) END) END AS A2_NREDUZ, "
cSQL += " SUM(D2_TOTAL) T_FATURAMENTO "

cSQL += "FROM "+ RetSQLName("SD2")
cSQL += "	INNER JOIN "+ RetSQLName("SF2") +" SF2 ON F2_FILIAL = D2_FILIAL"
cSQL += "	AND        SF2.F2_DOC     = D2_DOC "
cSQL += "	AND        SF2.F2_SERIE   = D2_SERIE "
cSQL += "	AND        LEFT(SF2.F2_EMISSAO,6) BETWEEN '"+StrZero(_nAnoIni,4)+StrZero(_nMesIni,2)+"' AND '"+StrZero(_nAnoFin,4)+StrZero(_nMesIni,2)+"' "
cSQL += "	AND        SF2.F2_TIPO IN ('N','C') "
cSQL += "	AND        SF2.F2_VEND1 <> '006874'"
cSQL += "	AND        SF2.D_E_L_E_T_ = ' ' 				            "
/*
cSQL += "	INNER JOIN "+ RetSQLName("SC5") +" SC5 ON C5_FILIAL = D2_FILIAL "
cSQL += "	AND        SC5.C5_NUM     = 	D2_PEDIDO "
cSQL += "	AND        SC5.D_E_L_E_T_ = ' ' "
*/
cSQL += "	INNER JOIN "+ RetSQLName("SF4") +" SF4 ON SF4.F4_FILIAL  = D2_FILIAL "
cSQL += "	AND        F4_CODIGO = D2_TES"
cSQL += "	AND        SF4.F4_DUPLIC  ='S' "
cSQL += "	AND        SF4.D_E_L_E_T_ = ' ' "

cSQL += "	INNER JOIN "+ RetSQLName("SA2") +" SA2 ON SA2.A2_COD  =  D2_FORNEC"
//cSQL += "	AND        SA2.A2_LOJA    = D2_LOJA "
cSQL += "	AND        SA2.A2_COMPRA  <> '' "
cSQL += "	AND        SA2.D_E_L_E_T_ = ' '  "

cSQL += "	WHERE D2_FILIAL IN ('01','04')"
cSQL += "	AND        D2_FORNEC BETWEEN '"+cValToChar(StrZero(nFornecI,6))+"' AND '"+cValToChar(StrZero(nFornecF,6))+"' "
cSQL += "	AND        D2_LOJA   = F2_LOJA "
cSQL += "	AND	       LEFT(D2_EMISSAO,6) BETWEEN '"+StrZero(_nAnoIni,4)+StrZero(_nMesIni,2)+"' AND '"+StrZero(_nAnoFin,4)+StrZero(_nMesIni,2)+"' "
cSQL += "	AND        "+RetSqlName("SD2")+".D_E_L_E_T_ = ' ' "
cSQL += "	GROUP BY "
cSQL += "	CASE WHEN D2_FORNEC IN('100278','000557','000830','000835') THEN '000835' ELSE ( "
cSQL += "	CASE WHEN D2_FORNEC IN('000334','000338','100015','100209') THEN '100209' ELSE ( "
cSQL += "	CASE WHEN D2_FORNEC IN('000261','000993','007624') THEN '007624' ELSE( "
cSQL += "	CASE WHEN D2_FORNEC IN('000094','000624','000661','548580') THEN '548580' ELSE ( "
cSQL += "	CASE WHEN D2_FORNEC IN('000349','000754') THEN '000754' ELSE ( "
cSQL += "	CASE WHEN D2_FORNEC IN('100144','100205') THEN '100144' ELSE ( "
//cSQL += "	CASE WHEN D2_FORNEC IN('000021','465686') THEN '465686' ELSE ( "
cSQL += "	CASE WHEN D2_FORNEC IN('000271','000701','002028','002038') THEN '000701' ELSE ( "
cSQL += "	CASE WHEN D2_FORNEC IN('002022','100232') THEN '100232' ELSE ( "
cSQL += "   CASE WHEN D2_FORNEC IN('100630','000630') THEN '100630' ELSE ( "
cSQL += "	CASE WHEN D2_FORNEC IN('000036') THEN '000036' " 
cSQL += "	ELSE D2_FORNEC END) END) END) END) END) END) END) END) END) END, "

cSQL += "	CASE WHEN D2_FORNEC IN('100278','000557','000830','000835') THEN 'LABOR IMPORT' ELSE ( "
cSQL += "	CASE WHEN D2_FORNEC IN('000334','000338','100015','100209') THEN 'ROCHE' ELSE ( "
cSQL += "	CASE WHEN D2_FORNEC IN('000261','000993','007624') THEN 'NIPRO' ELSE( "
cSQL += "	CASE WHEN D2_FORNEC IN('000094','000624','000661','548580') THEN 'NEVE' ELSE ( "
cSQL += "	CASE WHEN D2_FORNEC IN('000349','000754') THEN 'NATHALIA' ELSE ( "
cSQL += "	CASE WHEN D2_FORNEC IN('100144','100205') THEN 'MEDIX' ELSE ( "
//cSQL += "	CASE WHEN D2_FORNEC IN('000021','465686') THEN 'LAMEDID' ELSE ( "
cSQL += "	CASE WHEN D2_FORNEC IN('000271','000701','002028','002038') THEN 'KOLPLAST' ELSE ( "
cSQL += "	CASE WHEN D2_FORNEC IN('002022','100232') THEN 'MARDAM' ELSE ( "
cSQL += "   CASE WHEN D2_FORNEC IN('100630','000630') THEN 'AMED' ELSE ( "
cSQL += "	CASE WHEN D2_FORNEC IN('000036') THEN 'MUCAMBO' " 
cSQL += "	ELSE A2_NREDUZ END) END) END) END) END) END) END) END) END) END "

cSQL += "	ORDER BY T_FATURAMENTO DESC"

#xcommand TCQUERY <sql_expr>                          ;
[ALIAS <a>]                                           ;
[<new: NEW>]                                          ;
[SERVER <(server)>]                                   ;
[ENVIRONMENT <(environment)>]                         ;
=> dbUseArea(                                         ;
<.new.>,                                              ;
"TOPCONN",                                            ;
TCGENQRY(<(server)>,<(environment)>,<sql_expr>),      ;
<(a)>, .F., .T.)

TcQuery cSQL NEW ALIAS "TRB_TO"

TCSETFIELD("TRB_TO","TO_FATURAMENTO ","N",10,2)

DbSelectArea("TRB_TO")
DbGoTop()

ProcRegua(TRB_TO->(RecCount()))

_nMesI  := Val(cMes)
_nAnoI  := Val(cAno)-2

While !TRB_TO->(Eof())
	
	_nMesIni := Val(cMes)
	_nAnoIni := Val(cAno)-1
	_nAnoFin := Val(cAno)
	nMesMed  := 1
	
	IncProc( "Preparando dados do Fat / Dev Forn:" +TRB_TO->D2_FORNEC+" ")
	
	_nPos := 3
	
	For xi:=1 to 13
		
		If _nMesIni > 12
			_nMesIni := 1
			_nAnoIni := Val(cAno)
		Endif
		
		cSQL1 := "SELECT D2_FORNEC, A2_NREDUZ, SUM(Case F4_DUPLIC  when 'S' then D2_TOTAL else 0 End ) T_FATURAMENTO, "
		
		If StrZero(_nAnoIni,4)+StrZero(_nMesIni,2) > '201301'
			cSQL1 +=  "CASE WHEN D2_FORNEC IN('"+StrTran(GetNewPar("ES_LISFOR","000041/000609/000334/000338/000183/100000/000630/000996/000997"),"/","','")+"') THEN "
			cSQL1 +=  "SUM(D2_QUANT * D2_LISFOR) ELSE "
			cSQL1 +=  "SUM(D2_QUANT * D2_CUSDIP) END T_CUSTO,"
		Else
			cSQL1 += "SUM(D2_QUANT * D2_CUSDIP) T_CUSTO,"
		EndIf
		
		cSQL1 += "SUM(D2_DESPESA) T_DESPESA, SUM(D2_ICMSRET) T_ICMSRET, SUM(D2_VALFRE) T_FRETE,SUM(D2_SEGURO) T_SEGURO "
		cSQL1 += "  FROM "+RetSQLName("SD2")"
		cSQL1 += " INNER JOIN "+RetSQLName("SF2")+" SF2 ON  SF2.F2_FILIAL  = D2_FILIAL "
		cSQL1 += "                      AND SF2.F2_TIPO IN ('N','C') "
		cSQL1 += "                      AND SF2.F2_DOC     = D2_DOC "
		cSQL1 += "                      AND SF2.F2_SERIE   = D2_SERIE "
		cSQL1 += "                      AND LEFT(SF2.F2_EMISSAO,6) >= '"+StrZero(_nAnoIni,4)+StrZero(_nMesIni,2)+"' "
		If  cEmpAnt+cFilAnt  == "01001"
			cSQL1 +=  " AND SF2.F2_EMISSAO >= '20110501'"
		EndIf
		cSQL1 += "                   	AND SF2.F2_VEND1 <> '006874'"
		If U_ListVend() != ''
			cSQL1 += "				AND (CASE WHEN F2_VEND2 <> ' ' AND D2_FORNEC IN('000366','000446','000996') THEN F2_VEND2 ELSE F2_VEND1 END) "+U_ListVend()+"  "
		EndIf
		cSQL1 += "                      AND SF2.D_E_L_E_T_ = ' '
        /*
		cSQL1 += "INNER JOIN "+RetSQLName("SC5")+" SC5 ON  SC5.C5_FILIAL  = D2_FILIAL "
		cSQL1 += "                      AND SC5.C5_NUM     = D2_PEDIDO "
		cSQL1 += "                      AND SC5.D_E_L_E_T_ = ' ' "
		*/
		cSQL1 += "INNER JOIN "+RetSQLName("SF4")+" SF4 ON SF4.F4_FILIAL  = D2_FILIAL "
		cSQL1 += "                      AND ( SF4.F4_DUPLIC  = 'S' OR D2_DESPESA + D2_VALFRE + D2_SEGURO > 0 )"
		cSQL1 += "                      AND SF4.F4_CODIGO  = D2_TES "
		cSQL1 += "                      AND SF4.D_E_L_E_T_ = ' '"
		
		cSQL1 += "  INNER JOIN "+ RetSQLName("SB1") +" SB1 ON  SB1.B1_COD  = D2_COD"
		cSQL1 += "                          AND SB1.B1_FILIAL  = D2_FILIAL "
		cSQL1 += "                          AND SB1.D_E_L_E_T_ = ' ' "
	
		cSQL1 += "INNER JOIN "+RetSqlName('SA2')+" SA2 ON  SA2.A2_COD  = D2_FORNEC"
		If TRB_TO->D2_FORNEC = '051508'
			cSQL1 += "                      AND SA2.A2_LOJA = SB1.B1_LOJPROC"
		EndIf	
		cSQL1 += "                      AND SA2.D_E_L_E_T_ = ' ' "
		cSQL1 += "INNER JOIN "+RetSqlName('SA1')+" SA1 ON  SA1.A1_FILIAL = '' "
		cSQL1 += "                      AND SA1.A1_LOJA = D2_LOJA "
		cSQL1 += "                      AND SA1.A1_COD  = D2_CLIENTE"
		cSQL1 += "                      AND SA1.D_E_L_E_T_ = ' ' "
		cSQL1 += "WHERE D2_FILIAL IN ('01','04')"
		cSQL1 += "  AND	LEFT(D2_EMISSAO,6)	= '"+StrZero(_nAnoIni,4)+StrZero(_nMesIni,2)+"' "
		
		If TRB_TO->D2_FORNEC = '000835'      // LABOR IMPORT 		
			cSQL1 += "  AND D2_FORNEC IN('100278','000557','000830','000835') "
			cFornecA := "000835"
			cNreduz  := TRB_TO->A2_NREDUZ			
		ElseIf	TRB_TO->D2_FORNEC = '100209' // ROCHE 		
			cSQL1 += "  AND D2_FORNEC IN('000334','000338','100015','100209') "		
			cFornecA := "100209"			        
			cNreduz  := TRB_TO->A2_NREDUZ			
		ElseIf	TRB_TO->D2_FORNEC = '007624' // NIPRO
			cSQL1 += "  AND D2_FORNEC IN('000261','000993','007624')
			cFornecA := "007624"			        
			cNreduz  := TRB_TO->A2_NREDUZ						
		ElseIf	TRB_TO->D2_FORNEC = '548580' //NEVE
			cSQL1 += "  AND D2_FORNEC IN('000094','000624','000661','548580') "				
			cFornecA := "548580"			        
			cNreduz  := TRB_TO->A2_NREDUZ						
		ElseIf	TRB_TO->D2_FORNEC = '000754' //NATHALYA
			cSQL1 += "  AND D2_FORNEC IN('000349','000754') "		
			cFornecA := "000754"			        
			cNreduz  := TRB_TO->A2_NREDUZ						
		ElseIf	TRB_TO->D2_FORNEC = '100144'//MEDIX
			cSQL1 += "  AND D2_FORNEC IN('100144','100205') "		
			cFornecA := "100144"			        
			cNreduz  := TRB_TO->A2_NREDUZ						
		ElseIf	TRB_TO->D2_FORNEC = '465686' // LAMEDID
			cSQL1 += "  AND D2_FORNEC IN('000021','465686') "		
			cFornecA := "465686"			        
			cNreduz  := TRB_TO->A2_NREDUZ						
		ElseIf	TRB_TO->D2_FORNEC = '000701' // KOLPLAST
			cSQL1 += "  AND D2_FORNEC IN('000271','000701','002028','002038') "
			cFornecA := "000701"			        
			cNreduz  := TRB_TO->A2_NREDUZ						
		ElseIf	TRB_TO->D2_FORNEC = '100232' // MARDAM
			cSQL1 += "  AND D2_FORNEC IN('002022','100232') "
			cFornecA := "100232"			        
			cNreduz  := TRB_TO->A2_NREDUZ	
		ElseIf	TRB_TO->D2_FORNEC = '100630' // AMED
			cSQL1 += "  AND D2_FORNEC IN('100630','000630') "
			cFornecA := "100630"			        
			cNreduz  := TRB_TO->A2_NREDUZ												
		ElseIf	TRB_TO->D2_FORNEC = '100205' // MUCAMBO
			cSQL1 += "  AND D2_FORNEC IN('000036') "
			cFornecA := "000036"			        
			cNreduz  := TRB_TO->A2_NREDUZ						
		Else
			cSQL1 += "  AND D2_FORNEC = '"+TRB_TO->D2_FORNEC+"' "
			cFornecA := TRB_TO->D2_FORNEC           
			cNreduz  := TRB_TO->A2_NREDUZ			
		EndIf
				
		cSQL1 += "  AND "+RetSqlName("SD2")+".D_E_L_E_T_ = ' '"
		cSQL1 += " GROUP BY D2_FORNEC,A2_NREDUZ"
		cSQL1 += " ORDER BY D2_FORNEC"
		
		#xcommand TCQUERY <sql_expr>                          ;
		[ALIAS <a>]                                           ;
		[<new: NEW>]                                          ;
		[SERVER <(server)>]                                   ;
		[ENVIRONMENT <(environment)>]                         ;
		=> dbUseArea(                                         ;
		<.new.>,                                              ;
		"TOPCONN",                                            ;
		TCGENQRY(<(server)>,<(environment)>,<sql_expr>),      ;
		<(a)>, .F., .T.)
		
		TcQuery cSQL1 NEW ALIAS "TRB_F"
		
		TCSETFIELD("TRB_F","T_FATURAMENTO ","N",10,2)
		
		DbSelectArea("TRB_F")
		DbGoTop()
		
		cSQL2 := " SELECT "
		cSQL2 += " SUM(D1_TOTAL)D1_TOTAL, SUM(D1_QUANT * D2_CUSDIP)CUSTO"
		cSQL2 += " FROM "+ RetSQLName("SD1")+" SD1"
		cSQL2 += "	INNER JOIN SB1010 SB1 ON B1_COD  =   SD1.D1_COD"
		cSQL2 += "	    AND        SB1.B1_FILIAL  = D1_FILIAL"
		cSQL2 += "		AND        SB1.D_E_L_E_T_ = ' '"
		cSQL2 += "	INNER JOIN SD2010 SD2 ON SD2.D2_FILIAL = D1_FILIAL"
		
		If TRB_TO->D2_FORNEC = '000835'      // LABOR IMPORT 		
			cSQL2 += "  AND D2_FORNEC IN('100278','000557','000830','000835') "
			cFornecA := "000835"						
		ElseIf	TRB_TO->D2_FORNEC = '100209' // ROCHE 		
			cSQL2 += "  AND D2_FORNEC IN('000334','000338','100015','100209') "		
			cFornecA := "100209"									
		ElseIf	TRB_TO->D2_FORNEC = '007624' // NIPRO
			cSQL2 += "  AND D2_FORNEC IN('000261','000993','007624')
			cFornecA := "007624"									
		ElseIf	TRB_TO->D2_FORNEC = '548580' //NEVE
			cSQL2 += "  AND D2_FORNEC IN('000094','000624','000661','548580') "				
			cFornecA := "548580"									
		ElseIf	TRB_TO->D2_FORNEC = '000754' //NATHALYA
			cSQL2 += "  AND D2_FORNEC IN('000349','000754') "		
			cFornecA := "000754"									
		ElseIf	TRB_TO->D2_FORNEC = '100144'//MEDIX
			cSQL2 += "  AND D2_FORNEC IN('100144','100205') "		
			cFornecA := "100144"									
		ElseIf	TRB_TO->D2_FORNEC = '465686' // LAMEDID
			cSQL2 += "  AND D2_FORNEC IN('000021','465686') "		
			cFornecA := "465686"									
		ElseIf	TRB_TO->D2_FORNEC = '000701' // KOLPLAST
			cSQL2 += "  AND D2_FORNEC IN('000271','000701','002028','002038') "
			cFornecA := "000701"
		ElseIf	TRB_TO->D2_FORNEC = '100232' // MARDAM
			cSQL2 += "  AND D2_FORNEC IN('002022','100232') "
			cFornecA := "100232"
		ElseIf	TRB_TO->D2_FORNEC = '100630' // AMED
			cSQL2 += "  AND D2_FORNEC IN('100630','000630') "
			cFornecA := "100630"
		ElseIf	TRB_TO->D2_FORNEC = '100205' // MUCAMBO
			cSQL1 += "  AND D2_FORNEC IN('000036') "
			cFornecA := "000036"													
		Else
			cSQL2 += "  AND D2_FORNEC = '"+TRB_TO->D2_FORNEC+"' "
			cFornecA := TRB_TO->D2_FORNEC									
		EndIf

		cSQL2 += "		AND        LEFT(D2_EMISSAO,6) >= '"+StrZero(_nAnoI,4)+StrZero(_nMesI,2)+"' "
		cSQL2 += "		AND        D2_DOC  = SD1.D1_NFORI"
		cSQL2 += "		AND        D2_SERIE  = SD1.D1_SERIORI"
		cSQL2 += "		AND        D2_ITEM = SD1.D1_ITEMORI"
		cSQL2 += "		AND        SD2.D_E_L_E_T_ = ' '"
		cSQL2 += "	INNER JOIN SC5010 SC5 ON SC5.C5_FILIAL = D1_FILIAL"
		cSQL2 += "		AND        SC5.C5_NUM     = D2_PEDIDO"
		cSQL2 += "		AND        SC5.D_E_L_E_T_ = ' '"
		cSQL2 += "	INNER JOIN SF4010 SF4 ON F4_CODIGO = D1_TES"
		cSQL2 += "		AND        SF4.F4_DUPLIC  = 'S'"
		cSQL2 += "		AND        SF4.F4_FILIAL  = D1_FILIAL"
		cSQL2 += "		AND        SF4.D_E_L_E_T_ = ' '"
		cSQL2 += "	INNER JOIN SF2010 SF2 ON SF2.F2_FILIAL = D1_FILIAL"
		cSQL2 += "		AND        SF2.F2_TIPO IN ('N','C')"
		cSQL2 += "		AND        SF2.F2_DOC     = D1_NFORI"
		cSQL2 += "		AND        SF2.F2_SERIE   = D1_SERIORI"
		cSQL2 += "		AND        SF2.D_E_L_E_T_ = ' '"
		
		cSQL2 += " WHERE"
		cSQL2 += " 		D1_FILIAL IN ('01','04')  AND"
		cSQL2 += "      D1_TIPO    = 'D' AND"
		cSQL2 += "      LEFT(D1_DTDIGIT,6)	= '"+StrZero(_nAnoIni,4)+StrZero(_nMesIni,2)+"' AND"
		cSQL2 += "      SD1.D1_DTDIGIT >= '20110501'  AND"
		cSQL2 += "      SD1.D_E_L_E_T_ = ' '"
		
		#xcommand TCQUERY <sql_expr>                          ;
		[ALIAS <a>]                                           ;
		[<new: NEW>]                                          ;
		[SERVER <(server)>]                                   ;
		[ENVIRONMENT <(environment)>]                         ;
		=> dbUseArea(                                         ;
		<.new.>,                                              ;
		"TOPCONN",                                            ;
		TCGENQRY(<(server)>,<(environment)>,<sql_expr>),      ;
		<(a)>, .F., .T.)
		
		TcQuery cSQL2 NEW ALIAS "TRB_D"
		
		TCSETFIELD("TRB_D","D1_TOTAL ","N",10,2)
		
		DbSelectArea("TRB_D")
		DbGoTop()

		While !TRB_F->(Eof())
			nFatMes += TRB_F->T_FATURAMENTO
   			nCutMes += TRB_F->T_CUSTO
			TRB_F->(dbSkip())
		End
		While !TRB_D->(Eof())
			nDevMes  += TRB_D->D1_TOTAL
			TRB_D->(dbSkip())
		End
	
		If Len(aTotGeral) <> 1
			aadd(aTotGeral,{"Total",; //1
			"",; // 2
			0,; // 3  - Soma do mes 1
			0,; // 4  - Soma do mes 2
			0,; // 5  - Soma do mes 3
			0,; // 6  - Soma do mes 4
			0,; // 7  - Soma do mes 5
			0,; // 8  - Soma do mes 6
			0,; // 9  - Soma do mes 7
			0,; // 10 - Soma do mes 8
			0,; // 11 - Soma do mes 9
			0,; // 12 - Soma do mes 10
			0,; // 13 - Soma do mes 11
			0,; // 14 - Soma do mes 12
			0,; // 15 - Soma do mes 13
			0,; // 16 - Soma do TOTAL
			0,})// 17 - Soma da MEDIA
		EndIf
		
		If Len(aTotFat) <> 1
			aadd(aTotFat,{"Faturamento",; //1
			"",; // 2
			0,; // 3  - Soma do mes 1
			0,; // 4  - Soma do mes 2
			0,; // 5  - Soma do mes 3
			0,; // 6  - Soma do mes 4
			0,; // 7  - Soma do mes 5
			0,; // 8  - Soma do mes 6
			0,; // 9  - Soma do mes 7
			0,; // 10 - Soma do mes 8
			0,; // 11 - Soma do mes 9
			0,; // 12 - Soma do mes 10
			0,; // 13 - Soma do mes 11
			0,; // 14 - Soma do mes 12
			0,; // 15 - Soma do mes 13
			0,; // 16 - Soma do TOTAL
			0,})// 17 - Soma da MEDIA
		EndIf
		
		If Len(aPercFat) <> 1
			aadd(aPercFat,{"% Sobre Faturamento",; //1
			"",; // 2
			0,; // 3  - % do mes 1
			0,; // 4  - % do mes 2
			0,; // 5  - % do mes 3
			0,; // 6  - % do mes 4
			0,; // 7  - % do mes 5
			0,; // 8  - % do mes 6
			0,; // 9  - % do mes 7
			0,; // 10 - % do mes 8
			0,; // 11 - % do mes 9
			0,; // 12 - % do mes 10
			0,; // 13 - % do mes 11
			0,; // 14 - % do mes 12
			0,; // 15 - % do mes 13
			0,; // 16 - % do TOTAL
			0,})// 17 - % da MEDIA
		EndIf
		If Len(aPercMag) <> 1
			aadd(aPercMag,{"Margem media %",; //1
			"",; // 2
			0,; // 3  - % marg do mes 1
			0,; // 4  - % marg do mes 2
			0,; // 5  - % marg do mes 3
			0,; // 6  - % marg do mes 4
			0,; // 7  - % marg do mes 5
			0,; // 8  - % marg do mes 6
			0,; // 9  - % marg do mes 7
			0,; // 10 - % marg do mes 8
			0,; // 11 - % marg do mes 9
			0,; // 12 - % marg do mes 10
			0,; // 13 - % marg do mes 11
			0,; // 14 - % marg do mes 12
			0,; // 15 - % marg do mes 13
			0,; // 16 - % marg do TOTAL
			0,})// 17 - % marg da MEDIA
		EndIf

		If ALLTRIM(cFornecA) <> " "
			If AScan(aFat,{|aFat|aFat[1]==cFornecA}) ==0
				aadd(aFat,{cFornecA,; //1 - Codigo fornecedor
				cNreduz,;    //2 - Nome fornecedor
				0,; // 3 - Fat mes 1
				0,; // 4  - Fat mes 2
				0,; // 5  - Fat mes 3
				0,; // 6  - Fat mes 4
				0,; // 7  - Fat mes 5
				0,; // 8  - Fat mes 6
				0,; // 9  - Fat mes 7
				0,; // 10 - Fat mes 8
				0,; // 11 - Fat mes 9
				0,; // 12 - Fat mes 10
				0,; // 13 - Fat mes 11
				0,; // 14 - Fat mes 12
				0,; // 15 - Fat mes 13
				0,; // 16 - Total
				0}) // 17 - Media
				
				aadd(aMarg,{cFornecA,; //1 - Codigo fornecedor
				cNreduz,; //2 - Nome fornecedor
				0,; // 3  - Marg mes 1
				0,; // 4  - Marg mes 2
				0,; // 5  - Marg mes 3
				0,; // 6  - Marg mes 4
				0,; // 7  - Marg mes 5
				0,; // 8  - Marg mes 6
				0,; // 9  - Marg mes 7
				0,; // 10 - Marg mes 8
				0,; // 11 - Marg mes 9
				0,; // 12 - Marg mes 10
				0,; // 13 - Marg mes 11
				0,; // 14 - Marg mes 12
				0,; // 15 - Marg mes 13
				0,; // 16 - Total
				0}) // 17 - Media
				
				// Faturamento total do mês por fornecedor menos a devolucao
				aFat[Len(aFat),_nPos]    := nFatMes - nDevMes
				
				// Faturamento total do mês
				If xI == 1
					aTotFat[1,_nPos]:= U_FatTotal(nFornecI,nFornecF,_nAnoIni,_nMesIni,@nTotalFat)
				EndIF
				 // Margem do mês por fornecedor
				If nFatMes > 0
					aMarg[Len(aFat),_nPos]   := Round((((aFat[Len(aFat),_nPos] / nCutMes)-1)*100),2)
				EndIf
				
				If xI >= 2
					//Faturamento total do mes por fornecedor menos a devolucao
					aFat[Len(aFat),16]   := nFatMes - nDevMes
					
					//Margem do mês por fornecedor
					If nFatMes > 0
						aMarg[Len(aFat),16]  := Round((((aFat[Len(aFat),_nPos] / nCutMes)-1)*100),2)
					EndIf
					
					//Calculando a media
					If nFatMes > 0
						aFat[Len(aFat),17] := aFat[Len(aFat),16] / nMesMed
						aMarg[Len(aFat),17]:= aMarg[Len(aFat),16] / nMesMed

						If aTotFat[1,_nPos] == 0
							aTotFat[1,_nPos]:= U_FatTotal(nFornecI,nFornecF,_nAnoIni,_nMesIni,@nTotalFat)
							aTotFat[1,16]   += aTotFat[1,_nPos]
							aTotFat[1,17]   := aTotFat[1,16] / nMesMed
						EndIf
						
						nMesMed++
					EndIf
				EndIf
			Else
				aFat[Len(aFat),_nPos]  := nFatMes - nDevMes
				If nFatMes > 0
					aMarg[Len(aFat),_nPos] := Round((((aFat[Len(aFat),_nPos] / nCutMes)-1)*100),2)
				EndIf
				If xI >= 2
					aFat[Len(aFat),16]   += nFatMes - nDevMes
					If nFatMes > 0
						aMarg[Len(aFat),16]  += Round((((aFat[Len(aFat),_nPos] / nCutMes)-1)*100),2)
					EndIf
					
					If nFatMes > 0
						aFat[Len(aFat),17] := aFat[Len(aFat),16] / nMesMed
						aMarg[Len(aFat),17]:= aMarg[Len(aFat),16] / nMesMed

						If aTotFat[1,_nPos] == 0
							aTotFat[1,_nPos]:= U_FatTotal(nFornecI,nFornecF,_nAnoIni,_nMesIni,@nTotalFat)
							aTotFat[1,16]   += aTotFat[1,_nPos]
							aTotFat[1,17]   := aTotFat[1,16] / nMesMed
						EndIf
						
						nMesMed++
					EndIf
				EndIf
				
			Endif
		EndIf
		
		aTotGeral[1,_nPos]  += nFatMes - nDevMes
		If nFatMes > 0
			aPercMag[1,_nPos]  += Round((((aFat[Len(aFat),_nPos] / nCutMes)-1)*100),2)
		EndIf
		
		_nPos++
		_nMesIni++
		nFatMes := 0
		nDevMes := 0
		nCutMes := 0

		TRB_F->(DbCloseArea())
		TRB_D->(DbCloseArea())
		
	Next xI
	
	aTotGeral[1,16] += aFat[Len(aFat),16]
	aTotGeral[1,17] += aFat[Len(aFat),17]
	aPercMag[1,17]  += aMarg[Len(aFat),17]
	
	TRB_TO->(dbSkip())
				
EndDo

TRB_TO->(DbCloseArea())

If len(aTotGeral) > 0
	For nI := 3 To 17
		aPercFat[1,nI] := Round((aTotGeral[1,nI] / aTotFat[1,nI])*100,2)
	Next nI
EndIf

	
Return


//////////////////////////
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DIPR090   ºAutor  ³Microsiga           º Data ³  02/02/17   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function RptDetail()       

Local _nPag   := 0
Local nCol    := 0200
Local nColAx  := 0500
Local _nMesA  := Val(cMes)
Local nContMes:= 1
Local nSomaMes:= 0
Local nCnLinNu:= 0
Local nTotLin := 0
Local nQtdImpr:= 0
Local nI      := 0
Local nX      := 0

If !(oPrint:IsPrinterActive())
	Aviso("Impressora","As configurações da impressora não foram encontradas. Por favor, verifique as configurações para utilizar este relatório. ",{"OK"})
	oPrint:Setup()
	Return (.F.)
EndIf

oPrint:Startpage()
DIPR090Cab(@li,@_nPag,cMes,cAno)

aSort(aFat,,,{|x,y| x[16]>y[16]})
aSort(aMarg,,,{|x,y| x[17]>y[17]})

If Len(aFat) > 27
	nQtdImpr := 27
Else
	nQtdImpr := Len(aFat)
EndIf


For nI := 1 To nQtdImpr
	
	nCnLinNu := 30
	
	If     nI >= 10
		nCnLinNu:= 20
	ElseIf nI >= 100
		nCnLinNu:= 10
	EndIf
	
	oPrint:SayAlign(Li,nCnLinNu,cValToChar(nI),ArialN8,300,Li,,0,0)
	oPrint:SayAlign(Li,060,afat[nI][1]+" - "+afat[nI][2],ArialN8,500,Li,,0,0)
	
	For nX := 3 To 17
		
		If nX >= 4 .And. nX <= 15
			nCol += 155
		ElseIf nX == 16
			nCol += 185
		ElseIf nX == 17
			nCol += 230
		Else
			nCol += 300
		EndIf
		oPrint:SayAlign(Li,nCol,Transform(afat[nI][nX],"@E 999,999,999.99"),ArialN8,155,Li,,1,0)
	Next nX
	
	Li  += 35
	Colun(nColAx,Li)
	nCol := 200
	
Next nI

Li  += 35
ColunB(nColAx,Li)
nCol := 200

oPrint:SayAlign(Li,260,aTotGeral[1][1],ArialN8,300,Li,,0,0)

For nX := 3 To 17
	
	If nX >= 4 .And. nX <= 15
		nCol += 155
	ElseIf nX == 16
		nCol += 185
	ElseIf nX == 17
		nCol += 230
	Else
		nCol += 300
	EndIf
	
	oPrint:SayAlign(Li,nCol,Transform(aTotGeral[1][nX],"@E 999,999,999.99"),ArialN8,155,Li,,1,0)
	
Next nX

Li  += 35
ColunC(nColAx,Li)
nCol := 200

nCol := 300

oPrint:SayAlign(Li,0260,aTotFat[1][1],ArialN8,300,Li,,0,0)
oPrint:SayAlign(Li+35,260,aPercFat[1][1],ArialN8,300,Li,,0,0)

For nX := 3 To 17
	
	If nX >= 4 .And. nX <= 15
		nCol += 155
	ElseIf nX == 16
		nCol += 185
	ElseIf nX == 17
		nCol += 230
	Else
		nCol += 200
	EndIf
	
	oPrint:SayAlign(Li,nCol,Transform(aTotFat[1][nX],"@E 999,999,999.99"),ArialN8,155,Li,,1,0)
	oPrint:SayAlign(Li+35,nCol,Transform(aPercFat[1][nX],"@E 999,999,999.99")+'%',ArialN8,155,Li,,1,0)
	
Next nX

Li  += 35
ColunC(nColAx,Li)
nCol := 200

Li  += 35
ColunC(nColAx,Li)
nCol := 200

Li += 35

Li := DIPR90CabB(@li,cMes,cAno)

Li += 35
ColunD(nColAx,Li)
nCol := 200

If Len(aMarg) > 27
	nQtdImpr := 27
Else
	nQtdImpr := Len(aMarg)
EndIf

For nI := 1 To nQtdImpr
	
	
	nCnLinNu := 30
	
	If     nI >= 10
		nCnLinNu:= 20
	ElseIf nI >= 100
		nCnLinNu:= 10
	EndIf
	
	oPrint:SayAlign(Li,nCnLinNu,cValToChar(nI),ArialN8,300,Li,,0,0)
	oPrint:SayAlign(Li,060,aMarg[nI][1]+" - "+aMarg[nI][2],ArialN8,500,Li,,0,0)
	
	For nX := 3 To 17
		
		If nX >= 4 .And. nX <= 15
			nCol += 155
		ElseIf nX == 16
			nCol += 185
		ElseIf nX == 17
			nCol += 230
		Else
			nCol += 300
		EndIf
		If nX <> 16
			oPrint:SayAlign(Li,nCol,Transform(aMarg[nI][nX],"@E 99,999,999.99")+"%",ArialN8,155,Li,,1,0)
		EndIf
		
	Next nX
	
	Li  += 35
	
	ColunD(nColAx,Li)
	nCol := 200
	
Next nI

Li  += 40
ColunB(nColAx,Li)
nCol := 300

oPrint:SayAlign(Li,0260,aPercMag[1][1],ArialN8,300,Li,,0,0)

For nX := 3 To 17
	
	If nX >= 4 .And. nX <= 15
		nCol += 155
	ElseIf nX == 16
		nCol += 185
	ElseIf nX == 17
		nCol += 230
	Else
		nCol += 200
	EndIf
	If nX <> 16
		oPrint:SayAlign(Li,nCol,Transform(aPercMag[1][nX] / nQtdImpr,"@E 99,999,999.99")+"%",ArialN8,155,Li,,1,0)
	EndIf
	
Next nX

Li  += 35
ColunC(nColAx,Li)
nCol := 200

oPrint:Preview()

Return


/*====================================================================================\
|Programa  | DIPR090Cab    | Autor | Reginaldo Borges           | Data | 12/09/2016   |
|=====================================================================================|
|Descrição | Cabeçalho do relatorio gerado.								              |
|          |                                                                          |
|          |                                                                          |
|=====================================================================================|
|Sintaxe   | DIPR090Cab                                                               |
|=====================================================================================|
|Uso       | Especifico DIPROMED                                                      |
|=====================================================================================|
|...Nome.................................Histórico....................................|
|		   | 																		  |
\====================================================================================*/

Static Function DIPR090Cab(nlin,_nPag,cMes,cAno)

Local nPagina   := 0
Local _cTitulo  := ""
Local _npag     := 0
Local nLinmes   := 0
Local _cDesc1   := ""
Local _nMesIni  := 0
Local _nAnoIni  := 0
Local _nMesFin  := 0
Local _nAnoFin  := 0
Local nCol      := 0500
Local xI        := 0

_nMesIni := Val(cMes)
_nAnoIni := Val(cAno)-1
_nAnoFin := Val(cAno)

_cTitulo := "EVOLUÇÃO DE VENDAS POR FORNECEDOR - Período  (" +MesExtenso(_nMesIni)+"/"+""+strzero(_nAnoIni,4)+"" +" á "+""+"" +MesExtenso(_nMesIni)+"/"+""+strzero(_nAnoFin,4)+")"


// Box Geral
oPrint:Box(0100,0050,2400,3000)

// Box Meses
oPrint:Box(0150,0050,0190,3000)


oPrint:SayBitmap(0105,0055,"Dipromedcon.BMP",128,040)
oPrint:Say(0135,2860,dToC(Date()),ArialN8,300)
oPrint:Say(0135,2940,SubStr(Time(),1,5),ArialN8,100)

oPrint:SayAlign(0100,060,_cTitulo,ArialN12B,2990,,,2,0)
oPrint:SayAlign(0155,0060,"FORNECEDORES",ArialN8B,400,,CLR_HBLUE,2,0)

For xi:=1 to 13
	
	oPrint:SayAlign(0155,nCol+5,Upper(MesExtenso(_nMesIni)),ArialN8B,190,180,CLR_HBLUE,2,0)
	nCol += 155
	If _nMesIni >= 12
		_nMesIni := 1
		_nAnoIni := Val(Substr((cAno),3,4))
	Else
		_nMesIni++
		_nAnoIni := Val(Substr((cAno),3,4))-1
	EndIf
Next

nCol += 40
oPrint:SayAlign(0155,nCol,"TOTAL",ArialN8B,180,,CLR_HBLUE,2,0) // 2545
nCol += 230
oPrint:SayAlign(0155,nCol,"MEDIA",ArialN8B,180,,CLR_HBLUE,2,0) // 2725

_nPag++
nPagina := _nPag

li:=190


Return(li,_nPag)       

/*====================================================================================\
|Programa  | DIPR90CabB    | Autor | Reginaldo Borges           | Data | 12/09/2016   |
|=====================================================================================|
|Descrição | Cabeçalho do relatorio gerado.								              |
|          |                                                                          |
|          |                                                                          |
|=====================================================================================|
|Sintaxe   | DIPR90CabB                                                               |
|=====================================================================================|
|Uso       | Especifico DIPROMED                                                      |
|=====================================================================================|
|...Nome.................................Histórico....................................|
|		   | 																		  |
\====================================================================================*/

Static Function DIPR90CabB(nlin,cMes,cAno)

Local nLinmes   := 0
Local _cDesc1   := ""
Local _nMesIni  := 0
Local _nAnoIni  := 0
Local _nMesFin  := 0
Local _nAnoFin  := 0
Local nCol      := 0500
Local xI        := 0

_nMesIni := Val(cMes)
_nAnoIni := Val(cAno)-1
_nAnoFin := Val(cAno)

// Box Geral
//oPrint:Box(0100,0050,2400,3000)

// Box Meses
//oPrint:Box(0150,0050,0210,3000)

oPrint:SayAlign(nlin,0060,"FORNECEDORES",ArialN8B,400,,CLR_HBLUE,2,0)

For xi:=1 to 13
	
	oPrint:SayAlign(nlin,nCol+5,Upper(MesExtenso(_nMesIni)),ArialN8B,190,180,CLR_HBLUE,2,0)
	nCol += 155
	If _nMesIni >= 12
		_nMesIni := 1
		_nAnoIni := Val(Substr((cAno),3,4))
	Else
		_nMesIni++
		_nAnoIni := Val(Substr((cAno),3,4))-1
	EndIf
Next

nCol += 40
oPrint:SayAlign(nlin,nCol,"TOTAL",ArialN8B,180,,CLR_HBLUE,2,0) // 2545
nCol += 230
oPrint:SayAlign(nlin,nCol,"MEDIA",ArialN8B,180,,CLR_HBLUE,2,0) // 2725
 
Return(Li)       

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DIPR090   ºAutor  ³Microsiga           º Data ³  02/01/17   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Colun(nColAx,Li)

	//Linhas verticais   
    oPrint:Line (0150,nColAx+25,Li,nColAx+25,CLR_BLACK)
    nColAx += 155
    oPrint:Line (0150,nColAx+25,Li,nColAx+25,CLR_BLACK)	    
    nColAx += 155
    oPrint:Line (0150,nColAx+25,Li,nColAx+25,CLR_BLACK)	    
    nColAx += 155
    oPrint:Line (0150,nColAx+25,Li,nColAx+25,CLR_BLACK)	    
    nColAx += 155
    oPrint:Line (0150,nColAx+25,Li,nColAx+25,CLR_BLACK)	    
    nColAx += 155
    oPrint:Line (0150,nColAx+25,Li,nColAx+25,CLR_BLACK)	
    nColAx += 155
    oPrint:Line (0150,nColAx+25,Li,nColAx+25,CLR_BLACK)
    nColAx += 155
    oPrint:Line (0150,nColAx+25,Li,nColAx+25,CLR_BLACK)		
    nColAx += 155
    oPrint:Line (0150,nColAx+25,Li,nColAx+25,CLR_BLACK)	
    nColAx += 155
    oPrint:Line (0150,nColAx+25,Li,nColAx+25,CLR_BLACK)	
    nColAx += 155
    oPrint:Line (0150,nColAx+25,Li,nColAx+25,CLR_BLACK)
    nColAx += 155
    oPrint:Line (0150,nColAx+25,Li,nColAx+25,CLR_BLACK)
    nColAx += 155	
    oPrint:Line (0150,nColAx+25,Li,nColAx+25,CLR_BLACK)	
    nColAx += 155	
    oPrint:Line (0150,nColAx+25,Li,nColAx+25,CLR_BLACK) 
    nColAx += 200	
    oPrint:Line (0150,nColAx+50,Li,nColAx+50,CLR_BLACK)     
    
    //Linha horizontal
	oPrint:Line(Li,0050,Li,3000,CLR_BLACK)
           
Return     

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DIPR090   ºAutor  ³Microsiga           º Data ³  02/01/17   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ColunB(nColAx,Li) 

    //Linha horizontal
	oPrint:Line(Li,0250,Li,3000,CLR_BLACK)

Return    

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DIPR090   ºAutor  ³Microsiga           º Data ³  02/01/17   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ColunC(nColAx,Li)

	//Linhas verticais                                     
    oPrint:Line (Li-35,nColAx-250,Li,nColAx-250,CLR_BLACK)   
    oPrint:Line (Li-35,nColAx+25,Li,nColAx+25,CLR_BLACK)   
    nColAx += 155
    oPrint:Line (Li-35,nColAx+25,Li,nColAx+25,CLR_BLACK)	    
    nColAx += 155
    oPrint:Line (Li-35,nColAx+25,Li,nColAx+25,CLR_BLACK)	    
    nColAx += 155
    oPrint:Line (Li-35,nColAx+25,Li,nColAx+25,CLR_BLACK)	    
    nColAx += 155
    oPrint:Line (Li-35,nColAx+25,Li,nColAx+25,CLR_BLACK)	    
    nColAx += 155
    oPrint:Line (Li-35,nColAx+25,Li,nColAx+25,CLR_BLACK)	
    nColAx += 155
    oPrint:Line (Li-35,nColAx+25,Li,nColAx+25,CLR_BLACK)
    nColAx += 155
    oPrint:Line (Li-35,nColAx+25,Li,nColAx+25,CLR_BLACK)		
    nColAx += 155
    oPrint:Line (Li-35,nColAx+25,Li,nColAx+25,CLR_BLACK)	
    nColAx += 155
    oPrint:Line (Li-35,nColAx+25,Li,nColAx+25,CLR_BLACK)	
    nColAx += 155
    oPrint:Line (Li-35,nColAx+25,Li,nColAx+25,CLR_BLACK)
    nColAx += 155
    oPrint:Line (Li-35,nColAx+25,Li,nColAx+25,CLR_BLACK)
    nColAx += 155	
    oPrint:Line (Li-35,nColAx+25,Li,nColAx+25,CLR_BLACK)	
    nColAx += 155	
    oPrint:Line (Li-35,nColAx+25,Li,nColAx+25,CLR_BLACK) 
    nColAx += 200	
    oPrint:Line (Li-35,nColAx+50,Li,nColAx+50,CLR_BLACK)     
    
    //Linha horizontal
	oPrint:Line(Li,0250,Li,3000,CLR_BLACK)
           
Return     


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DIPR090   ºAutor  ³Microsiga           º Data ³  02/01/17   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ColunD(nColAx,Li)

    //Linha horizontal
	oPrint:Line(Li-35,50,Li-35,3000,CLR_BLACK)
	
	//Linhas verticais                                     
    //oPrint:Line (Li-35,nColAx-250,Li,nColAx-250,CLR_BLACK)   
    oPrint:Line (Li-35,nColAx+25,Li,nColAx+25,CLR_BLACK)   
    nColAx += 155
    oPrint:Line (Li-35,nColAx+25,Li,nColAx+25,CLR_BLACK)	    
    nColAx += 155
    oPrint:Line (Li-35,nColAx+25,Li,nColAx+25,CLR_BLACK)	    
    nColAx += 155
    oPrint:Line (Li-35,nColAx+25,Li,nColAx+25,CLR_BLACK)	    
    nColAx += 155
    oPrint:Line (Li-35,nColAx+25,Li,nColAx+25,CLR_BLACK)	    
    nColAx += 155
    oPrint:Line (Li-35,nColAx+25,Li,nColAx+25,CLR_BLACK)	
    nColAx += 155
    oPrint:Line (Li-35,nColAx+25,Li,nColAx+25,CLR_BLACK)
    nColAx += 155
    oPrint:Line (Li-35,nColAx+25,Li,nColAx+25,CLR_BLACK)		
    nColAx += 155
    oPrint:Line (Li-35,nColAx+25,Li,nColAx+25,CLR_BLACK)	
    nColAx += 155
    oPrint:Line (Li-35,nColAx+25,Li,nColAx+25,CLR_BLACK)	
    nColAx += 155
    oPrint:Line (Li-35,nColAx+25,Li,nColAx+25,CLR_BLACK)
    nColAx += 155
    oPrint:Line (Li-35,nColAx+25,Li,nColAx+25,CLR_BLACK)
    nColAx += 155	
    oPrint:Line (Li-35,nColAx+25,Li,nColAx+25,CLR_BLACK)	
    nColAx += 155	
    oPrint:Line (Li-35,nColAx+25,Li,nColAx+25,CLR_BLACK) 
    nColAx += 200	
    oPrint:Line (Li-35,nColAx+50,Li,nColAx+50,CLR_BLACK)     
    
    //Linha horizontal
	oPrint:Line(Li,50,Li,3000,CLR_BLACK)
           
Return     

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  FatTotal   ºAutor  ³Microsiga           º Data ³  02/17/17   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function FatTotal(nFornecI,nFornecF,_nAnoIni,_nMesIni,nTotalFat)

cSQL1 := " SELECT ROUND(SUM(D2_TOTAL+D2_VALFRE+D2_SEGURO+D2_DESPESA+D2_ICMSRET),2) - 
cSQL1 += " (SELECT SUM(D1_TOTAL+D1_VALFRE+D1_SEGURO+D1_DESPESA+D1_ICMSRET)T_DEVOLUCAO " 
cSQL1 += "  FROM "+RetSQLName("SD1")+" SD1 "
cSQL1 += " INNER JOIN "+RetSQLName("SD2")+"	SD2 ON SD2.D2_FILIAL = D1_FILIAL "
cSQL1 += " 		AND        D2_FORNEC BETWEEN '"+cValToChar(StrZero(nFornecI,6))+"' AND '"+cValToChar(StrZero(nFornecF,6))+"'"
cSQL1 += "		AND        LEFT(D2_EMISSAO,6) > '201406' "
cSQL1 += "		AND        D2_DOC  = SD1.D1_NFORI "    
cSQL1 += "		AND        D2_SERIE  = SD1.D1_SERIORI "
cSQL1 += "		AND        D2_ITEM = SD1.D1_ITEMORI " 
cSQL1 += "		AND        SD2.D_E_L_E_T_ = ' ' " 
cSQL1 += " INNER JOIN "+RetSqlname("SF4")+" SF4 ON SF4.F4_FILIAL  = D1_FILIAL "
cSQL1 += " 		AND        SF4.F4_DUPLIC  = 'S' "                             
cSQL1 += " 		AND        F4_CODIGO      = D1_TES "           
cSQL1 += " 		AND        SF4.D_E_L_E_T_ = ' ' "                             
cSQL1 += " INNER JOIN "+RetSqlname("SF2")+" SF2 ON SF2.F2_FILIAL = D1_FILIAL "
cSQL1 += " 		AND        SF2.F2_TIPO IN ('N','C') " 
cSQL1 += " 		AND        SF2.F2_DOC     = D1_NFORI " 
cSQL1 += " 		AND        SF2.F2_SERIE   = D1_SERIORI " 
cSQL1 += "		AND        SF2.F2_VEND1   <> '006874' "
cSQL1 += " 	    AND        SF2.D_E_L_E_T_ = ' ' "  
cSQL1 += " WHERE "  
cSQL1 += " 		D1_FILIAL IN ('01','04') "                         
cSQL1 += " 		AND D1_TIPO    = 'D' "                     
cSQL1 += " 		AND LEFT(D1_DTDIGIT,6) = '"+StrZero(_nAnoIni,4)+StrZero(_nMesIni,2)+"'"
cSQL1 += " 		AND SD1.D1_DTDIGIT >= '20110501' "
cSQL1 += " 		AND SD1.D_E_L_E_T_ = ' '  ) T_FATURAMENTO "
cSQL1 += "  FROM "+RetSQLName("SD2")+" SD2 "
cSQL1 += " INNER JOIN "+RetSQLName("SF2")+"	SF2 ON  SF2.F2_FILIAL  = SD2.D2_FILIAL "
cSQL1 += "		AND SF2.F2_TIPO IN ('N','C') "
cSQL1 += "		AND SF2.F2_DOC     = SD2.D2_DOC "
cSQL1 += "		AND SF2.F2_SERIE   = SD2.D2_SERIE "
cSQL1 += "		AND SF2.F2_VEND1   <> '006874' "   
cSQL1 += "		AND LEFT(SF2.F2_EMISSAO,6) = '"+StrZero(_nAnoIni,4)+StrZero(_nMesIni,2)+"'"
cSQL1 += "		AND SF2.D_E_L_E_T_ = ' ' "
cSQL1 += " INNER JOIN "+RetSqlName("SF4")+" SF4 ON  SF4.F4_FILIAL  = D2_FILIAL "
cSQL1 += "		AND SF4.F4_CODIGO  = D2_TES "
cSQL1 += "		AND ( SF4.F4_DUPLIC  = 'S' OR D2_DESPESA + D2_VALFRE + D2_SEGURO > 0 )"
cSQL1 += "		AND SF4.D_E_L_E_T_ = ' ' "
/*
cSQL1 += " INNER JOIN "+RetSqlName("SA1")+" SA1 ON  SA1.A1_FILIAL = '"+xFilial("SA1")+"' " "
cSQL1 += "      AND SA1.A1_COD  = D2_CLIENTE "
cSQL1 += "		AND SA1.A1_LOJA = D2_LOJA "
cSQL1 += "		AND SA1.D_E_L_E_T_ = ''"
*/
cSQL1 += "WHERE D2_FILIAL IN ('01','04') "
cSQL1 += "	AND D2_FORNEC BETWEEN '"+cValToChar(StrZero(nFornecI,6))+"' AND '"+cValToChar(StrZero(nFornecF,6))+"'"
cSQL1 += "	AND LEFT(D2_EMISSAO,6) = '"+StrZero(_nAnoIni,4)+StrZero(_nMesIni,2)+"'"
cSQL1 += "	AND SD2.D_E_L_E_T_ = ' ' "

#xcommand TCQUERY <sql_expr>                          ;
[ALIAS <a>]                                           ;
[<new: NEW>]                                          ;
[SERVER <(server)>]                                   ;
[ENVIRONMENT <(environment)>]                         ;
=> dbUseArea(                                         ;
<.new.>,                                              ;
"TOPCONN",                                            ;
TCGENQRY(<(server)>,<(environment)>,<sql_expr>),      ;
<(a)>, .F., .T.)

TcQuery cSQL1 NEW ALIAS "TRB_FT"

TCSETFIELD("TRB_F","FAT_TOTAL ","N",10,2)

DbSelectArea("TRB_FT")  

nTotalFat := TRB_FT->T_FATURAMENTO

TRB_FT->(DbCloseArea()) 

Return(nTotalFat)

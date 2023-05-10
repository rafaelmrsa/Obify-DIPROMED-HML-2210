/*
�����������������������������������������������������������������������������
���Funcao    � DIPR039  � Autor � Eriberto Elias     � Data � 02/09/2003  ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Curva ABC por volume de vendas                             ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � DIPR039                                                    ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Especifico DIPROMED                                        ���
�������������������������������������������������������������������������Ĵ��
�����������������������������������������������������������������������������
Altera��es:
Eriberto - 25/08/05 - coloquei na query para filtrar local = 01
*/

#include "rwmake.ch"

User Function DIPR039()

Local _xArea   := GetArea()

Local titulo     := OemTOAnsi("Curva ABC por volume de vendas...",72)
Local cDesc1     := OemToAnsi("Este programa tem como objetivo emitir um relat�rio",72)
Local cDesc2     := OemToAnsi("com o curva ABC por volume de vendas.",72)
Local cDesc3     := OemToAnsi("Conforme parametros definidos pelo o usuario.",72)
Local cUserAut    := GetMV("MV_URELFAT") // MCVN - 04/05/09     

Private lRet := .T.    

Private cDestino   := "C:\EXCELL-DBF\" 
Private _cDipUsr   := U_DipUsr()             

Private aReturn    := {"Bco A4", 1,"Faturamento", 1, 2, 1,"",1}
Private li         := 66
Private tamanho    := "G"
Private limite     := 220 
Private nomeprog   := "DIPR039"
Private cPerg      := "DIPR39"
//Private cPerg      := "DIPR24"
// FPADR(cPerg, cArq, cCampo, cTipo)  - Para ajustar o tamanho das perguntas no SX1- uso generico
PRIVATE cPerg  	:= U_FPADR( "DIPR39","SX1","SX1->X1_GRUPO"," " ) //Fun��o criada por Sandro em 19/11/09.

Private nLastKey   := 0
Private lEnd       := .F.
Private wnrel      := "DIPR039"
Private cString    := "SD2"
Private m_pag      := 1

Private _nTotal:= _nTotDev := _nTotalA := _nTotalB := _nTotalC := 0
Private _cCampo := '('
Private _cMes   := 0
Private nCntImpr := 0
Private cRodaTxt := ""
Private _cArqTrb
Private _cChave  

// MCVN - 04/05/09    
If !(Upper(U_DipUsr()) $ cUserAut)
	Alert(Upper(U_DipUsr())+", voc� n�o tem autoriza��o para utilizar esta rotina. Qualquer d�vida falar com Maximo!","Aten��o")	
	Return()
EndIF  

U_DIPPROC(ProcName(0),U_DipUsr()) // JBS 05/10/2005 - Gravando o nome do Programa no SZU  

AjustaSX1(cPerg)             // Verifica perguntas. Se nao existe INCLUI

If !Pergunte(cPerg,.T.)     // Solicita parametro
	Return
EndIf

If MsgYesNo(" Gera Relatorio Consolidado? ", "Consolidado?" )
	lRet := .T.
Else
	lRet := .F.
EndIf

wnrel := SetPrint(cString,wnrel,cPerg,Titulo,cDesc1,cDesc2,cDesc3,.f.,,.f.,tamanho,,.f.,,,,,)

If nLastKey == 27
	Return
Endif

SetDefault(aReturn,cString)

Processa({|lEnd| RodaProc()},Titulo)

RptStatus({|lEnd| RodaRel()},Titulo)

RestArea(_xArea)

Return

//////////////////////////////////////////////////////////////////////
Static Function RodaProc() 


Local cArqExcell:= "\Excell-DBF\"+_cDipUsr+"-DIPR039" 

ProcRegua(15000)
For _x := 1 to 5000
	IncProc( "Preparando os dados... ")
Next

/*     
SELECT D2_FILIAL, B1_FILIAL, B2_FILIAL, B3_FILIAL, D2_COD, B1_DESC, A2_NREDUZ, B1_UM, B2_USAI, B1_PRVMINI, B1_ABC, (B3_Q07+B3_Q06+B3_Q05)/3/30 B3_MEDIA, SUM(D2_TOTAL) D2_TOTAL, SUM(D2_QUANT) D2_QUANT
FROM SD2010, SB1010, SB2010, SB3010, SA2010
WHERE D2_FILIAL = '04'
AND B1_FILIAL = ''
AND B2_FILIAL = '04'
AND B3_FILIAL = ''
AND D2_LOCAL = '01'
AND B2_LOCAL = '01'
AND SA2010.D_E_L_E_T_ <> '*'
AND SB3010.D_E_L_E_T_ <> '*'
AND SB2010.D_E_L_E_T_ <> '*'
AND SB1010.D_E_L_E_T_ <> '*'
AND SD2010.D_E_L_E_T_ <> '*'
AND D2_EMISSAO BETWEEN '20040201' and '20040312'			-- entre MV_PAR01 e MV_PAR02
AND B1_PROC = '000108'												-- MV_PAR09 = 000041
AND D2_COD BETWEEN '' and 'ZZZZZZZ'								-- entre MV_PAR10 e MV_PAR11
AND D2_COD = B1_COD
AND D2_COD = B2_COD
AND D2_COD = B3_COD
AND B1_PROC (*LEFT JOIN) A2_COD
AND B1_LOJPROC (*LEFT JOIN) A2_LOJA
AND B1_TIPO <> 'MC'
GROUP BY D2_FILIAL, B1_FILIAL, B2_FILIAL, B3_FILIAL, D2_COD, B1_DESC, A2_NREDUZ, B1_UM, B2_USAI, B1_PRVMINI, B1_ABC, (B3_Q07+B3_Q06+B3_Q05)/3/30
ORDER BY D2_TOTAL desc
*/

For _x := 1 to 3
	If Month(mv_par01)-_x <= 0
		_cMes := 12 - Month(mv_par01)-_x
	Else
		_cMes := Month(mv_par01)-_x
	EndIf
	_cCampo := _cCampo + 'B3_Q'+StrZero(_cMes,2)+Iif(_x<>3,'+',')/3/30')
Next

//Query dos Faturamentos

QRY1 := " SELECT D2_COD, B1_DESC, A2_NREDUZ, B1_UM, B2_USAI, B1_PRVMINI, B1_ABC, "+_cCampo+" B3_MEDIA, SUM(D2_TOTAL) D2_TOTAL, SUM(D2_QUANT) D2_QUANT"
//QRY1 += " (B2_QATU - B2_RESERVA - B2_QACLASS) B2_QATU"
QRY1 += " FROM " + RetSQLName("SD2") + " SD2 with (nolock) "

QRY1 += " inner join " + RetSQLName("SB1") + " SB1 with (nolock) "
QRY1 += "    on  SB1.D_E_L_E_T_ <> '*'"
QRY1 += "    AND B1_FILIAL = D2_FILIAL"
QRY1 += "    AND D2_COD = B1_COD"
QRY1 += "    AND B1_TIPO  <> 'MC'"
	If !Empty(MV_PAR09)
		QRY1 += "    AND B1_PROC = '" + MV_PAR09 + "'"
	EndIf

QRY1 += " inner join " + RetSQLName("SB2") + " SB2 with (nolock) "
QRY1 += "    on  SB2.D_E_L_E_T_ <> '*'"
QRY1 += "    AND B2_FILIAL = D2_FILIAL"
QRY1 += "    AND B2_LOCAL  = '01'"
QRY1 += "    AND D2_COD = B2_COD"

QRY1 += " inner join " + RetSQLName("SB3") + " SB3 with (nolock) "
QRY1 += "    on  SB3.D_E_L_E_T_ <> '*'"
QRY1 += "    AND B3_FILIAL = D2_FILIAL"
QRY1 += "    AND D2_COD = B3_COD"

QRY1 += " left join " + RetSQLName("SA2") + " SA2 with (nolock) "
QRY1 += "    on  SA2.D_E_L_E_T_ <> '*'"
QRY1 += "    AND B1_PROC = A2_COD"
QRY1 += "    AND B1_LOJPROC = A2_LOJA"

QRY1 += " inner join " + RetSQLName("SF4") + " SF4 with (nolock) "
QRY1 += "    on  SF4.D_E_L_E_T_ <> '*'"
QRY1 += "    AND F4_FILIAL = D2_FILIAL"
QRY1 += "    AND D2_TES = F4_CODIGO"
QRY1 += "    AND F4_DUPLIC = 'S' "

QRY1 += " inner join " + RetSQLName("SC5") + " SC5 with (nolock) "
QRY1 += "    on  SC5.D_E_L_E_T_ <> '*'"
QRY1 += "    AND C5_FILIAL = D2_FILIAL"
QRY1 += "    AND C5_NUM   = D2_PEDIDO"

QRY1 += " inner join " + RetSQLName("SU7") + " SU7 with (nolock) "
QRY1 += "    on  SU7.D_E_L_E_T_ <> '*'"
QRY1 += "    AND U7_FILIAL = ''"
QRY1 += "    AND U7_COD   = C5_OPERADO"
	If     MV_PAR12 == 1
		QRY1 += "    AND U7_POSTO = '01'"      // APOIO
	ElseIf MV_PAR12 == 2
		QRY1 += "    AND U7_POSTO = '02'"         // TELEVENDAS
	ElseIf MV_PAR12 == 3
		QRY1 += "    AND U7_POSTO = '03'"         // LICITA��ES
	Elseif MV_PAR12 == 4
		QRY1 += "    AND U7_POSTO IN ('01','03')" // APOIO E LICITA��ES
	Elseif MV_PAR12 == 5
		QRY1 += "    AND U7_POSTO IN ('01','02','03')" // TODOS
	EndIf

QRY1 += " inner join " + RetSQLName("SF2") + " SF2 with (nolock) "
QRY1 += "    on  SF2.D_E_L_E_T_ <> '*'"
QRY1 += "    AND F2_FILIAL = D2_FILIAL"
QRY1 += "    AND F2_DOC   =  D2_DOC"
QRY1 += "    AND F2_SERIE =  D2_SERIE"
QRY1 += "    AND F2_VEND1 <> '006874' "

QRY1 += " inner join " + RetSQLName("SA3") + " SA3 with (nolock) "
QRY1 += "    on  SA3.D_E_L_E_T_ <> '*'"
QRY1 += "    AND  A3_FILIAL = ''"

QRY1 += " WHERE SD2.D_E_L_E_T_ <> '*'"
QRY1 += "    AND   D2_FILIAL IN ('01','04')"
QRY1 += "    AND D2_EMISSAO BETWEEN '" + DTOS(mv_par01) + "' AND '" + DTOS(mv_par02) + "'"
QRY1 += "    AND D2_COD BETWEEN '" + MV_PAR10 + "' AND '" + MV_PAR11 + "'"
QRY1 += "    AND D2_TIPO <> 'D'" /// RAFAEL 23/02/05

//QRY1 += " AND   D2_LOCAL  = '01'"

QRY1 += "    AND A3_COD IN( SELECT A3_COD FROM SA3010  "
QRY1 += "					WHERE   A3_FILIAL = '  '"	
QRY1 += "					   AND D_E_L_E_T_ = ' '	"
QRY1 += "					   AND A3_COD <> '006874'  "	
QRY1 += "					   AND A3_TIPO <> 'T' )    "

QRY1 += " AND (A3_COD = ( CASE WHEN F2_VEND2 <> ' '  "
QRY1 += "                 AND  D2_FORNEC IN('000366','000446','000996')" 
QRY1 += "                 THEN F2_VEND2 ELSE F2_VEND1 END)  ) "   


QRY1 += " GROUP BY D2_COD, B1_DESC, A2_NREDUZ, B1_UM, B2_USAI, B1_PRVMINI, B1_ABC, " + _cCampo //+ ", B2_QATU - B2_RESERVA - B2_QACLASS"
QRY1 += " ORDER BY D2_TOTAL DESC"

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

// Processa Query SQL
TcQuery QRY1 NEW ALIAS "QRY1"         // Abre uma workarea com o resultado da query

//Query das Devolu��es 


QRY2 := " SELECT ROUND(SUM(D1_TOTAL),0) AS D1_TOTAL "
QRY2 += " FROM " + RetSQLName("SD1")+' SD1, '+ RetSQLName("SD2")+' SD2, '+RetSQLName("SA1")+' SA1, '+RetSQLName("SF2")+' SF2, '
QRY2 += RetSQLName("SA3")+' SA3, '+RetSQLName("SB1")+' SB1, '+RetSQLName("SF4")+' SF4, '+RetSQLName("SC5")+' SC5, '+RetSQLName("SU7")+ ' SU7 ' 
QRY2 += " WHERE D1_FILIAL IN ('01','04')
QRY2 += " AND   D2_FILIAL = D1_FILIAL"
QRY2 += " AND   F2_FILIAL = D1_FILIAL"
QRY2 += " AND   B1_FILIAL = D1_FILIAL"
QRY2 += " AND   F4_FILIAL = D1_FILIAL"
QRY2 += " AND   C5_FILIAL = D1_FILIAL"
QRY2 += " AND   U7_FILIAL = ''" 
QRY2 += " AND   A3_FILIAL = ''"
QRY2 += " AND   A1_FILIAL = ''"
QRY2 += " AND   D1_TIPO   = 'D'"
QRY2 += " AND   D1_DTDIGIT BETWEEN '" + DTOS(mv_par01) + "' AND '" + DTOS(mv_par02) + "'"
QRY2 += " AND D1_COD >= '"+MV_PAR10+"' AND D1_COD <= '"+MV_PAR11+"'"
QRY2 += " AND D2_DOC   = D1_NFORI"
QRY2 += " AND D2_SERIE = D1_SERIORI"
QRY2 += " AND D2_ITEM  = D1_ITEMORI"   
If ! Empty(MV_PAR09)
	QRY2 += " AND D2_FORNEC = '" + MV_PAR09 + "'"
EndIf
QRY2 += " AND F2_DOC = D2_DOC"
QRY2 += " AND F2_SERIE = D2_SERIE"
QRY2 += " AND F2_VEND1 <> '006874'"
QRY2 += " AND A1_COD = D1_FORNECE"
QRY2 += " AND A1_LOJA = D1_LOJA"
QRY2 += " AND A3_COD IN( SELECT A3_COD FROM SA3010" 
QRY2 += "               WHERE     A3_FILIAL = '  '"	
QRY2 += "               AND D_E_L_E_T_ = ' '"	
QRY2 += "               AND A3_COD <> '006874'"  	
QRY2 += "               AND A3_TIPO <> 'T' )"
QRY2 += " AND (A3_COD = (CASE WHEN F2_VEND2 <> ' ' AND D2_FORNEC IN('000366','000446','000996') THEN F2_VEND2 ELSE F2_VEND1 END))"
QRY2 += " AND B1_COD = D2_COD"
QRY2 += " AND SB1.D_E_L_E_T_ =  ''"  
QRY2 += " AND F4_CODIGO = D1_TES"
QRY2 += " AND F4_DUPLIC  = 'S'"
QRY2 += " AND SF4.D_E_L_E_T_ = ''"  
QRY2 += " AND SC5.C5_NUM  = SD2.D2_PEDIDO"
QRY2 += " AND U7_COD      = C5_OPERADO"

If     MV_PAR12 == 1
	QRY2 += " AND U7_POSTO = '01'"      // APOIO
ElseIf MV_PAR12 == 2
	QRY2 += " AND U7_POSTO = '02'"         // TELEVENDAS
ElseIf MV_PAR12 == 3
	QRY2 += " AND U7_POSTO = '03'"         // LICITA��ES
Elseif MV_PAR12 == 4
	QRY2 += " AND U7_POSTO IN ('01','03')" // APOIO E LICITA��ES
Elseif MV_PAR12 == 5
	QRY2 += " AND U7_POSTO IN ('01','02','03')" // TODOS
EndIf

//QRY2 += " AND U7_POSTO IN ('01','02','03')"                          
QRY2 += " AND SU7.D_E_L_E_T_ = ''"
QRY2 += " AND SC5.D_E_L_E_T_ = ''"
QRY2 += " AND SA3.D_E_L_E_T_ = ''"  
QRY2 += " AND SF2.D_E_L_E_T_ = ''" 
QRY2 += " AND SA1.D_E_L_E_T_ = ''"  
QRY2 += " AND SD1.D_E_L_E_T_ = ''"
QRY2 += " AND SD2.D_E_L_E_T_ = ''"

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

// Processa Query SQL
TcQuery QRY2 NEW ALIAS "QRY2"         // Abre uma workarea com o resultado da query

DbSelectArea("QRY2")      

_nTotDev := QRY2->D1_TOTAL

DbSelectArea("QRY1")
Sum QRY1->D2_TOTAL TO _nTotal 
QRY1->(dbGotop())

ProcRegua(15000)
For _x := 1 to 5000
	IncProc( "Classificando... ")
Next

_aCampos := {}
_aTamSX3 := TamSX3("D2_COD")
AAdd(_aCampos ,{"D2_COD", "C",_aTamSX3[1],_aTamSX3[2]})
_aTamSX3 := TamSX3("B1_DESC")
AAdd(_aCampos ,{"B1_DESC", "C",_aTamSX3[1],_aTamSX3[2]})
_aTamSX3 := TamSX3("A2_NREDUZ")
AAdd(_aCampos ,{"A2_NREDUZ", "C",_aTamSX3[1],_aTamSX3[2]})
_aTamSX3 := TamSX3("B1_UM")
AAdd(_aCampos ,{"B1_UM", "C",_aTamSX3[1],_aTamSX3[2]})
_aTamSX3 := TamSX3("B2_USAI")
AAdd(_aCampos ,{"B2_USAI", "C",_aTamSX3[1],_aTamSX3[2]})
_aTamSX3 := TamSX3("B1_PRVMINI")
AAdd(_aCampos ,{"B1_PRVMINI", "N",_aTamSX3[1],_aTamSX3[2]})
_aTamSX3 := TamSX3("B1_ABC")
AAdd(_aCampos ,{"B1_ABC", "C",_aTamSX3[1],_aTamSX3[2]})
_aTamSX3 := TamSX3("B3_MEDIA")
AAdd(_aCampos ,{"B3_MEDIA", "N",_aTamSX3[1],_aTamSX3[2]})
_aTamSX3 := TamSX3("D2_TOTAL")
AAdd(_aCampos ,{"D2_TOTAL", "N",_aTamSX3[1],_aTamSX3[2]})
_aTamSX3 := TamSX3("D2_QUANT")
AAdd(_aCampos ,{"D2_QUANT", "N",_aTamSX3[1],_aTamSX3[2]})
//_aTamSX3 := TamSX3("B2_QATU")
//AAdd(_aCampos ,{"B2_QATU", "N",_aTamSX3[1],_aTamSX3[2]})

_cArqTrb := CriaTrab(_aCampos,.T.)
DbUseArea(.T.,,_cArqTrb,"TRB",.F.,.F.)

SQLtoTRB(QRY1,_aCampos,"TRB")

DbSelectArea("TRB")
_cChave := "D2_TOTAL*-1"
IndRegua("TRB",_cArqTrb,_cChave,,,"Classificando tudo...")
ProcRegua(RecCount())
TRB->(DbGotop())

Do While _nTotalA <= _nTotal*mv_par03/100 .and. TRB->(!Eof())
	IncProc( "Classificando...A ")
	RECLOCK("TRB",.F.)
	TRB->B1_ABC := 'A'
	TRB->(MSUNLOCK())
	_nTotalA+=TRB->D2_TOTAL
	TRB->(DbSkip())
EndDo

Do While _nTotalB <= _nTotal*mv_par04/100 .and. TRB->(!Eof())
	IncProc( "Classificando...B ")
	RECLOCK("TRB",.F.)
	TRB->B1_ABC := 'B'
	TRB->(MSUNLOCK())
	_nTotalB+=TRB->D2_TOTAL
	TRB->(DbSkip())
EndDo

Do While TRB->(!Eof())
	IncProc( "Classificando...C ")
	RECLOCK("TRB",.F.)
	TRB->B1_ABC := 'C'
	TRB->(MSUNLOCK())
	_nTotalC+=TRB->D2_TOTAL
	TRB->(DbSkip())
EndDo 

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

DbSelectArea("TRB")

_cChave := "B1_ABC+ALLTRIM(STR(100000000-D2_TOTAL,12,2))"
IndRegua("TRB",_cArqTrb,_cChave,,,"Classificando TUDO...")

// Gerando arquivo excel - RB 18/10/2013
COPY TO &cArqExcell VIA "DBFCDX"

MakeDir(cDestino) // CRIA DIRET�RIO CASO N�O EXISTA
CpyS2T(cArqExcell+".dbf",cDestino,.T.) // COPIA ARQUIVO PARA MAQUINA DO USU�RIO
	
// Buscando e apagando arquivos tempor�rios - MCVN 27/08/10
aTmp := Directory( cDestino+"*.tmp" )
For nI:= 1 to Len(aTmp)
	fErase(cDestino+aTmp[nI,1])
Next nI 

dbSelectArea("QRY1")     
QRY1->(dbCloseArea())
dbSelectArea("QRY2")     
QRY2->(dbCloseArea())

Return(.T.)



/////////////////////////
Static Function RodaRel()

DbSelectArea("TRB")
TRB->(DbGotop())
SetRegua(RecCount())

_cTitulo := "Curva ABC de produtos por volume de venda - De: "+dTOc(mv_par01)+' ate: '+dTOc(mv_par02)
_cDesc1  := "                                                                                                            Valor                       Saldo       Ultima         Preco   Classificacao"
_cDesc2  := "Produto                                                               Marca                  UM          Faturado    Quantidade         Atual        Saida          (C)    ABC        %"
cRodaTxt := " Produtos  -  Percentuais da curva: "+' A-'+STR(mv_par03,5,2)+'%  B-'+STR(mv_par04,5,2)+'%  C-'+STR(mv_par05,5,2)+'% - Dias para estoque minimo:'+' A-'+STR(mv_par06,2)+'  B-'+STR(mv_par07,2)+'  C-'+STR(mv_par08,2)
_nTotalA := _nTotalB := _nTotalC := 0

Do While TRB->(!Eof())
	
	IncRegua( "Imprimindo... ")
	
	If li > 60
		li := Cabec(_cTitulo,_cDesc1,_cDesc2,nomeprog,tamanho) + 1
	EndIf
	*                                                                                                    1         1         1         1         1         1         1         1         1         1         2         2         2
	*          1         2         3         4         5         6         7         8         9         0         1         2         3         4         5         6         7         8         9         0         1         2
	*01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
	*                                                                                                            Valor                       Saldo       Ultima         Preco   Classificacao
	*Produto                                                               Marca                  UM          Faturado    Quantidade         Atual        Saida          (C)    ABC        %
	*999999 123456789012345678901234567890123456789012345678901234567890   12345678901234567890   UMX   999.999.999,99   999.999.999   999.999.999   XX/XX/XXXX   99.999,9999    A    999,99%
	*                                                                                  TotaL GeraL:   9.999.999.999,99   999,99%
	
	@ li,000 PSay SUBSTR(TRB->D2_COD,1,6)+' '+TRB->B1_DESC
	@ li,070 PSay TRB->A2_NREDUZ
	@ li,093 PSay TRB->B1_UM
	@ li,099 PSay TRB->D2_TOTAL PICTURE "@E 999,999,999.99"
	@ li,116 PSay TRB->D2_QUANT PICTURE "@E 999,999,999"
	
	If lRet == .T.
		@ li,130 PSay cEstoque	:= U_DIPSALDSB2(SUBSTR(TRB->D2_COD,1,6),.T.,,"01") PICTURE "@E 999,999,999"
	Elseif lRet == .F.
		@ li,130 PSay cEstoque	:= (U_DIPSALDSB2(SUBSTR(TRB->D2_COD,1,6),lRet,'')[1][1]) PICTURE "@E 999,999,999"
	EndIf
	
	//@ li,130 PSay TRB->B3_MEDIA * Iif(TRB->B1_ABC=='A',mv_par06,Iif(TRB->B1_ABC=='B',mv_par07,mv_par08)) PICTURE "@E 999,999,999"
	@ li,144 PSay SubStr(TRB->B2_USAI,7,2)+'/'+SubStr(TRB->B2_USAI,5,2)+'/'+SubStr(TRB->B2_USAI,1,4)
	@ li,157 PSay TRB->B1_PRVMINI PICTURE "@E 99,999.9999"
	@ li,172 PSay TRB->B1_ABC
	@ li,177 PSay TRB->D2_TOTAL / _nTotal * 100 PICTURE "@E 999.99"
	@ li,183 PSay "%"
	li++
	
	_nTotalA+=Iif(TRB->B1_ABC=='A',TRB->D2_TOTAL,0)
	_nTotalB+=Iif(TRB->B1_ABC=='B',TRB->D2_TOTAL,0)
	_nTotalC+=Iif(TRB->B1_ABC=='C',TRB->D2_TOTAL,0)
	
	nCntImpr++
	TRB->(DbSkip())
	
EndDo

If li > 60
	li := Cabec(_cTitulo,_cDesc1,_cDesc2,nomeprog,tamanho) + 1
	@ li,082 PSay 'TotaL GeraL:'
	@ li,097 PSay _nTotal PICTURE "@E 9,999,999,999"
	li+=1
	@ li,082 PSay 'TotaL Dev.:'
	@ li,097 PSay _nTotDev PICTURE "@E 9,999,999,999"
	li+=1
	@ li,082 PSay 'TotaL:'
	@ li,097 PSay (_nTotal-_nTotDev) PICTURE "@E 9,999,999,999"	
	li+=2
	@ li,082 PSay 'TotaL A:'
	@ li,097 PSay _nTotalA PICTURE "@E 9,999,999,999"
	@ li,116 PSay _nTotalA/_nTotal*100 PICTURE "@E 999.99"
	@ li,122 PSay "%"
	LI++
	@ li,082 PSay 'TotaL B:'
	@ li,097 PSay _nTotalB PICTURE "@E 9,999,999,999"
	@ li,116 PSay _nTotalC/_nTotal*100 PICTURE "@E 999.99"
	@ li,122 PSay "%"
	LI++
	@ li,082 PSay 'TotaL C:'
	@ li,097 PSay _nTotalC PICTURE "@E 9,999,999,999"
	@ li,116 PSay _nTotalC/_nTotal*100 PICTURE "@E 999.99"
	@ li,122 PSay "%"
	li+=2
	@ li,000 PSay AllTrim(STR(nCntImpr,4,0))+cRodaTxt
	Roda(nCntImpr,cRodaTxt,tamanho)
Else
	@ li,082 PSay 'TotaL GeraL:'
	@ li,097 PSay _nTotal PICTURE "@E 9,999,999,999"
	li+=1
	@ li,082 PSay 'TotaL Dev.:'
	@ li,097 PSay _nTotDev PICTURE "@E 9,999,999,999"
	li+=1
	@ li,082 PSay 'TotaL:'
	@ li,097 PSay (_nTotal-_nTotDev) PICTURE "@E 9,999,999,999"	
	li+=2	
	@ li,082 PSay 'TotaL A:'
	@ li,097 PSay _nTotalA PICTURE "@E 9,999,999,999"
	@ li,116 PSay _nTotalA/_nTotal*100 PICTURE "@E 999.99"
	@ li,122 PSay "%"
	LI++
	@ li,082 PSay 'TotaL B:'
	@ li,097 PSay _nTotalB PICTURE "@E 9,999,999,999"
	@ li,116 PSay _nTotalB/_nTotal*100 PICTURE "@E 999"
	@ li,122 PSay "%"
	LI++
	@ li,082 PSay 'TotaL C:'
	@ li,097 PSay _nTotalC PICTURE "@E 9,999,999,999"
	@ li,116 PSay _nTotalC/_nTotal*100 PICTURE "@E 999.99"
	@ li,122 PSay "%"
	li+=2
	@ li,000 PSay STR(nCntImpr,4,0)+cRodaTxt
	Roda(nCntImpr,cRodaTxt,tamanho)
EndIf

DbSelectArea("TRB")
TRB->(DbCloseArea())
Ferase(_cArqTrb+".*")
//Ferase(_cArqTrb+OrdBagExt())

Set device to Screen

//���������������������������������������������������������������������������Ŀ
//� Se em disco, desvia para Spool                                            �
//�����������������������������������������������������������������������������
If aReturn[5] == 1    // Se Saida para disco, ativa SPOOL
	Set Printer TO
	Commit
	ourspool(wnrel)
Endif

Return(.T.)

/////////////////////////////////////////////////////////////////////////////
Static Function AjustaSX1(cPerg)
_sAlias := Alias()
dbSelectArea("SX1")
dbSetOrder(1)

aRegs:={}

//------------ Grupo/Ordem/Pergunta/PERGING/PERGESP/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05/F3

aAdd(aRegs,{cPerg,"01","Data inicial        ?","","","mv_ch1","D",8, 0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"02","Data final          ?","","","mv_ch2","D",8, 0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"03","% do A              ?","","","mv_ch3","N",5, 2,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","",''})
aAdd(aRegs,{cPerg,"04","% do B              ?","","","mv_ch4","N",5, 2,0,"G","","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","",''})
aAdd(aRegs,{cPerg,"05","% do C              ?","","","mv_ch5","N",5, 2,0,"G","","mv_par05","","","","","","","","","","","","","","","","","","","","","","","","",''})
aAdd(aRegs,{cPerg,"06","Dias est.min. A     ?","","","mv_ch6","N",2, 0,0,"G","","mv_par06","","","","","","","","","","","","","","","","","","","","","","","","",''})
aAdd(aRegs,{cPerg,"07","Dias est.min. B     ?","","","mv_ch7","N",2, 0,0,"G","","mv_par07","","","","","","","","","","","","","","","","","","","","","","","","",''})
aAdd(aRegs,{cPerg,"08","Dias est.min. C     ?","","","mv_ch8","N",2, 0,0,"G","","mv_par08","","","","","","","","","","","","","","","","","","","","","","","","",''})
aAdd(aRegs,{cPerg,"09","Fornecedor          ?","","","mv_ch9","C",6, 0,0,"G","","mv_par09","","","","","","","","","","","","","","","","","","","","","","","","",'SA2'})
aAdd(aRegs,{cPerg,"10","Do Produto          ?","","","mv_chA","C",15,0,0,"G","","mv_par10","","","","","","","","","","","","","","","","","","","","","","","","","SB1"})
aAdd(aRegs,{cPerg,"11","Ate Produto         ?","","","mv_chB","C",15,0,0,"G","","mv_par11","","","","","","","","","","","","","","","","","","","","","","","","","SB1"})
AADD(aRegs,{cPerg,"12","Informe o setor     ?","","","mv_chC","N",1,0,0,"C","","mv_par12","1-Apoio","","","","","2-Call Center","","","","","3-Licitacoes","","","","","4-Apoio_Lic","","","","","5-Todos"})

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
///////////////////////////////////////////////////////////////////////////
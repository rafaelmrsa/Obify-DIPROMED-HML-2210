/*====================================================================================\
|Programa  | DIPR040       | Autor | Rafael de Campos Falco     | Data | 08/09/2003   |
|=====================================================================================|
|Descrição | Rel. de volume(R$) compras de produtos por fornecedor no período de      |
|          | 12 meses                                                                 |
|          |                                                                          |
|=====================================================================================|
|Sintaxe   | DIPR040                                                                  |
|=====================================================================================|
|Uso       | Especifico DIPROMED                                                      |
|=====================================================================================|
|........................................Histórico....................................|
|Maximo    | 03/03/08 - Alterado para buscar informação no SD1  e não mais no SC7     |
|Eriberto  | DD/MM/AA - Descrição                                                     |
\====================================================================================*/

#include "rwmake.ch"
#IFNDEF WINDOWS
	#DEFINE PSay Say
#ENDIF

User Function DIPR040()

Local _xArea	:= GetArea()
Local titulo	:= OemTOAnsi("Relatório mensal de pedido de compras",72)
Local cDesc1	:= OemToAnsi("Este programa tem como objetivo emitir um relat¢rio",72)
Local cDesc2	:= OemToAnsi("do volume de compras do período de 12 meses.(SD1)",72)
Local cDesc3	:= OemToAnsi("Conforme parametros definidos pelo o usuario.",72)

Private tamanho	:= "G"
Private limite		:= 220
Private aReturn	:= {"Bco A4", 1,"Financeiro", 1, 2, 1,"",1}
Private nomeprog	:= "DIPR040"

// Private cPerg		:= "DIPR40"
// FPADR(cPerg, cArq, cCampo, cTipo)  - Para ajustar o tamanho das perguntas no SX1- uso generico
PRIVATE cPerg  	:= U_FPADR( "DIPR40","SX1","SX1->X1_GRUPO"," " ) //Função criada por Sandro em 19/11/09.

Private nLastKey	:= 0
Private lContinua	:= .T.
Private lEnd		:= .F.
Private li			:= 67
Private wnrel		:= "DIPR040"
Private M_PAG		:= 1
Private cString	:= "SD1"
Private _aPosVol	:= {}
Private _aTotal	:= {0,0,0,0,0,0,0,0,0,0,0,0,0}

U_DIPPROC(ProcName(0),U_DipUsr()) // JBS 05/10/2005 - Gravando o nome do Programa no SZU

AjustaSX1(cPerg)             // Verifica perguntas. Se nao existe INCLUI

If !Pergunte(cPerg,.T.)    // Solicita parametros
	Return
EndIf                      

wnrel := SetPrint(cString,wnrel,cPerg,Titulo,cDesc1,cDesc2,cDesc3,.f.,,.f.,tamanho,,.f.,,,,,)

If nLastKey == 27
	Return
Endif

SetDefault(aReturn,cString)

Processa({|lEnd| RunProc()},"Totalizando por fornecedor e mes...")

RptStatus({|lEnd| RptDetail()},"Imprimindo volume de compras...")

RestArea(_xArea)

Return

//////////////////////////////////////////////////////////////////////
Static Function RunProc()

Local yi := 1
Local xi := 1

ProcRegua(15000)
For _x := 1 to 3000
	IncProc( "Processando... ")
Next

// Determina os 12 meses que serão apresentados
_nMesIni := Substr(mv_par01,1,2)
_nAnoIni := Substr(mv_par01,3,4)
If Val(_nMesIni) == 12
	_nMesFim := 1
	_nAnoFim := Val(_nAnoIni)
Else
	_nMesFim := Val(_nMesIni) + 1
	_nAnoFim := Val(_nAnoIni) - 1
EndIf
_nParPer := AllTrim(Str(_nAnoFim))+AllTrim(StrZero(_nMesFim,2))

/*
SELECT C7_FORNECE, A2_LOJA, A2_NREDUZ,sum(C7_TOTAL) C7_TOTAL, left(C7_EMISSAO,6) FROM SC7010,SA2010
WHERE C7_FORNECE = A2_COD
AND left(C7_EMISSAO,6) <= '200310'
AND left(C7_EMISSAO,6) >= '200211'
AND SC7010.D_E_L_E_T_ <> '*'
AND C7_FORNECE = A2_COD
AND C7_LOJA = A2_LOJA
GROUP BY C7_FORNECE, A2_LOJA, A2_NREDUZ, left(C7_EMISSAO,6)
ORDER BY C7_FORNECE, A2_LOJA, A2_NREDUZ, left(C7_EMISSAO,6)
*/

/*   03/03/08 
QRY1 := "SELECT C7_FORNECE, A2_LOJA, A2_NREDUZ, sum(C7_TOTAL) C7_TOTAL,left(C7_EMISSAO,6) C7_EMISSAO"
QRY1 += " FROM " +  RetSQLName('SC7') + ", " + RetSQLName('SA2')
QRY1 += " WHERE " + RetSQLName('SC7') + ".D_E_L_E_T_ <> '*' AND "
QRY1 += " LEFT("  + RetSQLName('SC7') + ".C7_EMISSAO,6) <= '" + Subs(mv_par01,3,4)+Subs(mv_par01,1,2) + "' AND "
QRY1 += " LEFT("  + RetSQLName('SC7') + ".C7_EMISSAO,6) >= '" + _nParPer + "' AND "
QRY1 += RetSQLName('SC7') + ".C7_FORNECE = " + RetSQLName('SA2')+".A2_COD AND "
QRY1 += RetSQLName('SC7') + ".C7_LOJA = " + RetSQLName('SA2')+".A2_LOJA"
QRY1 += " GROUP BY C7_FORNECE, A2_LOJA, A2_NREDUZ, left(C7_EMISSAO,6)"
QRY1 += " ORDER BY C7_FORNECE, A2_LOJA, A2_NREDUZ, left(C7_EMISSAO,6)" */                            


QRY1 := "SELECT D1_FORNECE, D1_LOJA, A2_NREDUZ, SUM(D1_TOTAL) D1_TOTAL,left(D1_DTDIGIT,6) D1_DTDIGIT"
QRY1 += " FROM " +  RetSQLName('SD1') + ", " + RetSQLName('SA2')+ ", " + RetSQLName('SF4')
QRY1 += " WHERE " + RetSQLName('SD1') + ".D_E_L_E_T_ <> '*' AND " 
QRY1 += RetSQLName('SA2') + ".D_E_L_E_T_ <> '*' AND "  
QRY1 += RetSQLName('SF4') + ".D_E_L_E_T_ <> '*' AND "  
QRY1 += RetSQLName('SD1') + ".D1_TIPO = 'N' AND "
//QRY1 += RetSQLName('SD1') + ".D1_PEDIDO <> '' AND "
QRY1 += " LEFT("  + RetSQLName('SD1') + ".D1_DTDIGIT,6) <= '" + Subs(mv_par01,3,4)+Subs(mv_par01,1,2) + "' AND "
QRY1 += " LEFT("  + RetSQLName('SD1') + ".D1_DTDIGIT,6) >= '" + _nParPer + "' AND "
QRY1 += RetSQLName('SD1') + ".D1_FORNECE = " + RetSQLName('SA2')+".A2_COD AND "
QRY1 += RetSQLName('SD1') + ".D1_LOJA = " + RetSQLName('SA2')+".A2_LOJA  AND "
QRY1 += RetSQLName('SD1') + ".D1_TES = " + RetSQLName('SF4')+".F4_CODIGO AND "
QRY1 += RetSQLName('SF4')+".F4_DUPLIC  = 'S' "
QRY1 += " GROUP BY D1_FORNECE, D1_LOJA, A2_NREDUZ, left(D1_DTDIGIT,6)"
QRY1 += " ORDER BY D1_FORNECE, D1_LOJA, A2_NREDUZ, left(D1_DTDIGIT,6)" 

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
memowrite('DIPR040.SQL',QRY1)

DbSelectArea("QRY1")

Do While QRY1->(!Eof())	

	// Inicializa variáveis de controle
	_nSoma	:= 0
	_cCodFor := (QRY1->D1_FORNECE + QRY1->D1_LOJA)
	_nMesIni := Val(Substr(mv_par01,1,2))
	_nAnoIni := Val(Substr(mv_par01,3,4))
	
	// Verifica se mudou de ano
	If _nMesIni >= 12
		_nMesIni := 1
	Else
		_nAnoIni--
		_nMesIni++
	EndIf	
	Aadd(_aPosVol,{AllTrim(QRY1->D1_FORNECE),AllTrim(QRY1->A2_NREDUZ),0,0,0,0,0,0,0,0,0,0,0,0,0})
	yi := 3
	// Loop para armazenar os meses
	Do While (QRY1->D1_FORNECE + QRY1->D1_LOJA == _cCodFor)
	
		// verifica se a data de emissão é ref. a coluna do mês
		If Val(SubStr(QRY1->D1_DTDIGIT,1,4)) == _nAnoIni
			If Val(SubStr(QRY1->D1_DTDIGIT,5,2)) == _nMesIni
				_aPosVol[xi,yi] := QRY1->D1_TOTAL
				_nSoma += QRY1->D1_TOTAL
				_aTotal[yi-2] := _aTotal[yi-2] + QRY1->D1_TOTAL
			QRY1->(DbSkip())
			EndIf
		EndIf	
		yi++
		If _nMesIni >= 12
			_nMesIni := 1
			_nAnoIni++
		Else
			_nMesIni++
		EndIf
	EndDo
	
	// Armazena coluna de média e total
	_aPosVol[xi,15] := (_nSoma/12)
	_aTotal[13] := _aTotal[13] + (_nSoma/12)

	// Inincializa variáveis
	xi++
	yi	:= 0
	 
EndDo
aSort( _aPosVol ,,, {|a,b| a[15] > b[15]} )
Return

///////////////////////////
Static Function RptDetail()
Local _cTitulo := ""
Local _cDesc1  := " Código  Nome" + Space(16)
Local _cDesc2  := ""
Local _cCodFor := ""
Local _nMesIni := Val(Substr(mv_par01,1,2))
Local _nAnoIni := Val(Substr(mv_par01,3,4))
Local _nMesFim := 0
Local _nAnoFim := 0
Local _nCol		:= 0

// Determina os 12 meses que serão apresentados
If _nMesIni >= 12
	_nMesFim := 1
Else
	_nMesFim := _nMesIni + 1
EndIf
_nAnoFim := _nAnoIni - 1
_nParPer := AllTrim(Str(_nAnoFim))+AllTrim(StrZero(_nMesFim,2))

// Monta o cabeçalho com os 12 meses selecionados
For xi:=1 to 12
	_nTamMes := 14 - Len(MesExtenso(_nMesFim))
	_cDesc1 += Space(_nTamMes)+MesExtenso(_nMesFim)

	If _nMesFim >= 12
		_nMesFim := 1
	Else
		_nMesFim++
	EndIf
Next

_cDesc1 += Space(9)+"Média"
_cTitulo := "Volume de compras do período " + SubStr(_nParPer,5,2)+"/"+SubStr(_nParPer,1,4) + " até " + SubStr(mv_par01,1,2)+"/"+SubStr(mv_par01,3,4)

DbSelectArea("QRY1")
SetRegua(Len(_aPosVol))
DbGoTop()

For xi := 1 To Len(_aPosVol)
	IncRegua( "Imprimindo: "+_aPosVol[xi,2])	
	If li > 65
		li := Cabec(_cTitulo,_cDesc1,_cDesc2,nomeprog,tamanho) + 1
	EndIf	
	*                                                                                                   1                                                                                                   2                                                                                                   3
	*         1         2         3         4         5         6         7         8         9         0         1         2         3         4         5         6         7         8         9         0         1         2         3         4         5         6         7         8         9         0         1         2         3         4         5         6
	*1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
	*Código  Nome                       Janeiro     Fevereiro         Marco         Abril          Maio         Junho         Julho        Agosto      Setembro       Outubro      Novembro      Dezembro         Média
	*999999  12345678901234567890 99.999.999,99 99.999.999,99 99.999.999,99 99.999.999,99 99.999.999,99 99.999.999,99 99.999.999,99 99.999.999,99 99.999.999,99 99.999.999,99 99.999.999,99 99.999.999,99 99.999.999,99

	@ li,001 PSay _aPosVol[xi,1] // Código
	@ li,009 PSay _aPosVol[xi,2] // Nome
	_nCol := 30
	// Impressão da linha do fornecedor e dos meses
	For yi := 3 To 15
		@ li,_nCol PSay _aPosVol[xi,yi] Picture "@E 99,999,999.99"
		_nCol += 14
	Next
   li++
Next

// Impressão da linha de totais
li += 2
@ li,000 psay Replicate("-",220)
li += 1
@ li,001 PSay "Total"
_nCol := 30
For nI:=1 To Len(_aTotal)
	@ li,_nCol PSay _aTotal[nI] Picture "@E 99,999,999.99"	
	_nCol += 14
Next
li++
@ li,000 psay Replicate("-",220)

DbSelectArea("QRY1")
QRY1->(DbCloseArea())

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

/////////////////////////////////////////////////////////////////////////////
//
Static Function AjustaSx1(cPerg)
_sAlias := Alias()
dbSelectArea("SX1")
dbSetOrder(1)       

aRegs:={}

//------------ Grupo/Ordem/Pergunta/PERGING/PERGESP/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05/F3

AADD(aRegs,{cPerg,"01","Mes e Ano Final?  ","","","mv_ch1","C",6,0,0,"G","","mv_par01","","","","","","","","","","","","","",""})

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
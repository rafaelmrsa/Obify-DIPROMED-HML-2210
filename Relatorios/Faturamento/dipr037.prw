/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Funcao    ³ DIPR037  ³ Autor ³ Eriberto Elias     ³ Data ³ 18/08/2003  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Eficiencia da expedicao                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ DIPR037                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Especifico DIPROMED                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ MODIFICADO PARA FAZER A LEITURA DOS DADOS DA TABELA                   ³±±
±±³ SZG010(SEPARADOR / CONFERENTE) => RAFAEL DE CAMPOS FALCO - 02/04/04   ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
#include "rwmake.ch"

User Function DIPR037()

Local _xArea   := GetArea()

Local titulo     := OemTOAnsi("Eficiencia da expedicao - SEPARADOR/CONFERENTE",72)
Local cDesc1     := OemToAnsi("Este programa tem como objetivo emitir um relat¢rio",72)
Local cDesc2     := OemToAnsi("com as notas emitidas.",72)
Local cDesc3     := OemToAnsi("Conforme parametros definidos pelo o usuario.",72)

Private aReturn   := {"Bco A4", 1,"Faturamento", 1, 2, 1,"",1}
Private li        := 66
Private tamanho   := "P"
Private limite    := 80
Private nomeprog  := "DIPR037"

// Private cPerg     := "DIPR37"
// FPADR(cPerg, cArq, cCampo, cTipo)
PRIVATE cPerg  	:= U_FPADR( "DIPR37","SX1","SX1->X1_GRUPO"," " ) //Criado por Sandro em 19/11/09. 

Private nLastKey  := 0
Private lEnd      := .F.
Private wnrel     := "DIPR037"
Private cString   := "SF2"
Private m_pag     := 1
Private QRY1 		:= ""                                                             
Private QRY2 		:= ""

U_DIPPROC(ProcName(0),U_DipUsr()) // JBS 05/10/2005 - Gravando o nome do Programa no SZU

AjustaSX1(cPerg)             // Verifica perguntas. Se nao existe INCLUI

If !Pergunte(cPerg,.T.)     // Solicita parametro
	Return
EndIf

wnrel := SetPrint(cString,wnrel,cPerg,Titulo,cDesc1,cDesc2,cDesc3,.f.,,.f.,tamanho,,.f.,,,,,)

If nLastKey == 27
	Return
Endif

SetDefault(aReturn,cString)

RptStatus({|lEnd| RodaRel()},Titulo)

RestArea(_xArea)

Return

//////////////////////////////////////////////////////////////////////
Static Function RodaRel()
Local _nQtdNotas := 0
Local _nQtdItens := 0
Local _nTotDiaN  := 0
Local _nTotDiaI  := 0
Local _nTotSCN   := 0
Local _nTotSCI   := 0
Local _nTotGerN := 0
Local _nTotGerI := 0
Local _cDia := ''
Local _cSC  := ''

SetRegua(15000)
For _x := 1 to 1600
	IncRegua( "Preparando os dados... ")
Next

/*
--MV_PAR01 -> Analitico - NOTA e TOTAL DE ITENS ou Sintetico - TOTAL NOTAS e TOTAL DE ITENS
--MV_PAR02 -> SEPARADOR ou CONFERENTE

select F2_SEPAROU, ZC_NOME, F2_EMISSAO, F2_HORANOT, F2_HORAPRE, D2_DOC, D2_PEDIDO, COUNT(*) QTD_ITENS
--select F2_CONFERI, ZC_NOME, F2_EMISSAO, F2_HORANOT, F2_HORAPRE, D2_DOC, D2_PEDIDO, COUNT(*) QTD_ITENS
from SF2010, SD2010, SZC010
where
SF2010.D_E_L_E_T_ <> '*' and
SD2010.D_E_L_E_T_ <> '*' and
SZC010.D_E_L_E_T_ <> '*' and
SF2010.F2_FILIAL = '04' and
SD2010.D2_FILIAL = '04' and
SF2010.F2_EMISSAO between '20030820' and '20030820' and --MV_PAR03 e MV_PAR04
SF2010.F2_DOC = SD2010.D2_DOC and
SF2010.F2_SERIE = SD2010.D2_SERIE and
--SF2010.F2_SEPAROU = --MV_PAR05
SF2010.F2_SEPAROU = SZC010.ZC_CODIGO
--SF2010.F2_CONFERI = --MV_PAR05
--SF2010.F2_CONFERI = SZC010.ZC_CODIGO

-- MV_PAR02 = SEPAROU
group by F2_SEPAROU, ZC_NOME, F2_EMISSAO, F2_HORANOT, F2_HORAPRE, D2_DOC, D2_PEDIDO
-- MV_PAR02 = CONFERI
--group by F2_CONFERI, ZC_NOME, F2_EMISSAO, F2_HORANOT, F2_HORAPRE, D2_DOC, D2_PEDIDO

order by ZC_NOME, F2_EMISSAO, F2_HORANOT, D2_DOC
*/
If MV_PAR02 = 1
	QRY1 :=  "SELECT F2_SEPAROU,"
Else
	QRY1 :=  "SELECT F2_CONFERI,"
EndIf
QRY1 += " ZC_NOME, F2_EMISSAO, F2_HORANOT, F2_HORAPRE, D2_DOC, D2_PEDIDO, COUNT(*) QTD_ITENS"
QRY1 += " FROM " + RetSQLName("SF2")+', '+RetSQLName("SD2")+', '+RetSQLName("SZC")
QRY1 += " WHERE F2_FILIAL = '"+xFilial('SF2')+"'"
QRY1 += " AND D2_FILIAL = '"+xFilial('SD2')+"'"
QRY1 += " AND " + RetSQLName('SF2')+".D_E_L_E_T_ <> '*'"
QRY1 += " AND " + RetSQLName('SD2')+".D_E_L_E_T_ <> '*'"
QRY1 += " AND " + RetSQLName('SZC')+".D_E_L_E_T_ <> '*'"
QRY1 += " AND F2_EMISSAO BETWEEN '"+DTOS(MV_PAR03)+"' AND '"+DTOS(MV_PAR04)+"'"
QRY1 += " AND F2_DOC = D2_DOC"
QRY1 += " AND F2_SERIE = D2_SERIE"
If mv_par02 == 1
	QRY1 += " AND F2_SEPAROU = ZC_CODIGO "
	If !Empty(mv_par05)
		QRY1 += " AND F2_SEPAROU = '"+mv_par05+"' "
	EndIf
	QRY1 += " GROUP BY F2_SEPAROU, "
Else
	QRY1 += " AND F2_CONFERI = ZC_CODIGO "
	If !Empty(mv_par05)
		QRY1 += " AND F2_CONFERI = '"+mv_par05+"' "
	EndIf
	QRY1 += " GROUP BY F2_CONFERI,"
EndIf
QRY1 += " ZC_NOME, F2_EMISSAO, F2_HORANOT, F2_HORAPRE, D2_DOC, D2_PEDIDO"
QRY1 += " ORDER BY ZC_NOME, F2_EMISSAO, F2_HORANOT"

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


/*
--SELECT DISTINCT ZD_SEPAROU, ZC_NOME, ZD_EMISSAO, D2_DOC, D2_PEDIDO, COUNT(*) QTD_ITENS
SELECT DISTINCT ZD_CONFERI, ZC_NOME, ZD_EMISSAO, D2_DOC, D2_PEDIDO, COUNT(*) QTD_ITENS
FROM SZD010, SZC010, SD2010
WHERE ZD_FILIAL = '04'
AND D2_FILIAL = '04'
AND SZD010.D_E_L_E_T_ <> '*'
--AND SD2010.D_E_L_E_T_ <> '*'
AND SZC010.D_E_L_E_T_ <> '*'
AND ZD_EMISSAO BETWEEN '20030101' AND '20050406'
AND ZD_NOTA = D2_DOC
--AND ZC_CODIGO = ZD_SEPAROU
AND ZC_CODIGO = ZD_CONFERI
--GROUP BY ZD_SEPAROU, ZC_NOME, ZD_EMISSAO, ZD_HORAEXC, D2_DOC, D2_PEDIDO
GROUP BY ZD_CONFERI, ZC_NOME, ZD_EMISSAO, ZD_HORAEXC, D2_DOC, D2_PEDIDO
ORDER BY ZC_NOME, ZD_EMISSAO
*/


If MV_PAR02 = 1
	QRY2 :=  "SELECT DISTINCT ZD_SEPAROU,"
Else
	QRY2 :=  "SELECT DISTINCT ZD_CONFERI,"
EndIf
QRY2 += " ZC_NOME, ZD_EMISSAO, D2_DOC, D2_PEDIDO, COUNT(*) QTD_ITENS"
QRY2 += " FROM " + RetSQLName("SZD")+', '+RetSQLName("SD2")+', '+RetSQLName("SZC")
QRY2 += " WHERE ZD_FILIAL = '"+xFilial('SZD')+"'"
QRY2 += " AND D2_FILIAL = '"+xFilial('SD2')+"'"
QRY2 += " AND " + RetSQLName('SZD')+".D_E_L_E_T_ <> '*'"
QRY2 += " AND " + RetSQLName('SZC')+".D_E_L_E_T_ <> '*'"
QRY2 += " AND ZD_EMISSAO BETWEEN '"+DTOS(MV_PAR03)+"' AND '"+DTOS(MV_PAR04)+"'"
QRY2 += " AND ZD_NOTA = D2_DOC"
If mv_par02 == 1
	QRY2 += " AND ZD_SEPAROU = ZC_CODIGO "
	If !Empty(mv_par05)
		QRY2 += " AND ZD_SEPAROU = '"+mv_par05+"' "
	EndIf
	QRY2 += " GROUP BY ZD_SEPAROU, "
Else
	QRY2 += " AND ZD_CONFERI = ZC_CODIGO "
	If !Empty(mv_par05)
		QRY2 += " AND ZD_CONFERI = '"+mv_par05+"' "
	EndIf
	QRY2 += " GROUP BY ZD_CONFERI,"
EndIf
QRY2 += " ZC_NOME, ZD_EMISSAO, ZD_HORAEXC, D2_DOC, D2_PEDIDO"
QRY2 += " ORDER BY ZC_NOME, ZD_EMISSAO"

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




_cTitulo := "EFICIENCIA EXPEDICAO - "+Iif(mv_par01==1,'Analitico','Sintetico')
If mv_par01 == 1
	_cDesc1  := 'Periodo: '+dTOc(mv_par03)+' - '+dTOc(mv_par04)+"           Quantidade                Horario"
	If mv_par02 == 1
		_cDesc2  := "Separador                Pedido    N.F.         Itens        Pre-nota       Nota"
	Else
		_cDesc2  := "Conferente               Pedido    N.F.         Itens        Pre-nota       Nota"
	EndIf
Else
	_cDesc1  := 'Periodo: '+dTOc(mv_par03)+' - '+dTOc(mv_par04)+"      Quantidades"
	If mv_par02 == 1
		_cDesc2  := "Separador                         Notas         Itens"
	Else
		_cDesc2  := "Conferente                        Notas         Itens"
	EndIf
EndIf

DbSelectArea("QRY2")
QRY2->(dbGotop())

DbSelectArea("QRY1")
QRY1->(dbGotop())

	*                                                                                                    1         1         1         1         1         1         1         1         1         1         2         2         2
	*          1         2         3         4         5         6         7         8         9         0         1         2         3         4         5         6         7         8         9         0         1         2
	*01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
	*Periodo: 99/99/9999 - 99/99/9999           Quantidade              Horario
	*Conferente               Pedido    N.F.         Itens        Pre-nota       Nota
	*99-12345678901234567890  123456  123456    99.999.999        99:99:99   99:99:99
	*            Total 99/99/9999:
	*Total - 12345678901234567890:
	*                 TotaL Geral:99,999,999    99,999,999
	*Periodo: 99/99/9999 - 99/99/9999      Quantidades
	*Conferente                        Notas         Itens
	*99-12345678901234567890      99.999.999    99.999.999
	*                 TotaL GeraL:


_dDia := QRY1->F2_EMISSAO
_cSC  := ''

Do While QRY1->(!Eof())
	
	IncRegua( "Imprimindo... ")
	
	If li > 60
		li := Cabec(_cTitulo,_cDesc1,_cDesc2,nomeprog,tamanho) + 1
	EndIf
	
	If _cSC != QRY1->ZC_NOME
		@ li,000 PSay Subs(Iif(mv_par02==1,QRY1->F2_SEPAROU,QRY1->F2_CONFERI),1,2)+'-'+QRY1->ZC_NOME
		_cSC := QRY1->ZC_NOME
	EndIf
	
	If mv_par01 == 1  	// Analitico notas canceladas
		@ li,025 PSay QRY1->D2_PEDIDO
		@ li,033 PSay QRY1->D2_DOC
		@ li,043 PSay QRY1->QTD_ITENS PICTURE '@E 99,999,999'
		@ li,061 PSay QRY1->F2_HORAPRE
		@ li,072 PSay QRY1->F2_HORANOT		
		li++
		
		_nTotDiaN++
		_nTotDiaI+=QRY1->QTD_ITENS
		_nTotSCN++
		_nTotSCI+=QRY1->QTD_ITENS
		_nTotGerN++
		_nTotGerI+=QRY1->QTD_ITENS

		// IMPRIME RELAÇÃO DE NOTAS CANCELADAS
		If QRY1->F2_EMISSAO == QRY2->ZD_EMISSAO .and. QRY1->ZC_NOME == QRY2->ZC_NOME
			DbSelectArea("QRY2")
			Do While QRY1->F2_EMISSAO == QRY2->ZD_EMISSAO .and. QRY1->ZC_NOME == QRY2->ZC_NOME
				@ li,025 PSay QRY2->D2_PEDIDO
				@ li,033 PSay QRY2->D2_DOC
				@ li,043 PSay QRY2->QTD_ITENS PICTURE '@E 99,999,999'
				li++
				
				_nTotDiaN++
				_nTotDiaI+=QRY2->QTD_ITENS
				_nTotSCN++
				_nTotSCI+=QRY2->QTD_ITENS
				_nTotGerN++
				_nTotGerI+=QRY2->QTD_ITENS
				
				QRY2->(DbSkip())					
			EndDo
		EndIf
		
		QRY1->(DbSkip())
		
		If QRY1->F2_EMISSAO != _dDia .or. QRY1->ZC_NOME != _cSC
			@ li,012 PSay 'Total '+SubStr(_dDia,7,2)+'/'+SubStr(_dDia,5,2)+'/'+SubStr(_dDia,1,4)+':'
			@ li,029 PSay _nTotDiaN PICTURE '@E 99,999,999'
			@ li,043 PSay _nTotDiaI PICTURE '@E 99,999,999'
			_nTotDiaN := 0
			_nTotDiaI := 0
			li++
			_dDia := QRY1->F2_EMISSAO
		EndIf		
		
		If QRY1->ZC_NOME != _cSC
			li++
			@ li,29-Len('Total - '+AllTrim(_cSC)+':') PSay 'Total - '+AllTrim(_cSC)+':'
			@ li,029 PSay _nTotSCN PICTURE '@E 99,999,999'
			@ li,043 PSay _nTotSCI PICTURE '@E 99,999,999'
			_nTotSCN := 0
			_nTotSCI := 0
			li++
		EndIf
		
/*		If QRY1->(Eof())
			li++
			@ li,017 PSay 'Total :'
			@ li,029 PSay _nTotGerN PICTURE '@E 99,999,999'
			@ li,043 PSay _nTotGerI PICTURE '@E 99,999,999'
			li++
		EndIf*/
		
	Else  // Sintetico
		Do While _cSC == QRY1->ZC_NOME
			_nQtdNotas++
			_nQTdItens+=QRY1->QTD_ITENS
			
			// Sintetico das notas canceladas
			Do While _cSC == QRY2->ZC_NOME
				_nQtdNotas++
				_nQTdItens+=QRY2->QTD_ITENS
				QRY2->(DbSkip())
			EndDo
	
			QRY1->(DbSkip())
		EndDo
		
		@ li,029 PSay _nQtdNotas PICTURE '@E 99,999,999'
		@ li,043 PSay _nQtdItens PICTURE '@E 99,999,999'
		
		li++

		_nTotGerN+=_nQtdNotas
		_nTotGerI+=_nQtdItens
		
		_nQtdNotas := 0
		_nQtdItens := 0
		
	EndIf
EndDo

// Totaliza NF e Itens
li++
@ li,017 PSay 'Total Geral:'
@ li,029 PSay _nTotGerN PICTURE '@E 99,999,999'
@ li,043 PSay _nTotGerI PICTURE '@E 99,999,999'
li++                  

Roda(0,"Bom trabalho!",tamanho)

dbSelectArea("QRY1")
QRY1->(dbCloseArea())

dbSelectArea("QRY2")
QRY2->(dbCloseArea())

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
Static Function AjustaSX1(cPerg)
_sAlias := Alias()
dbSelectArea("SX1")
dbSetOrder(1)

cPerg := PADR(cPerg, Len(SX1->X1_GRUPO)," " ) // Incluido por Sandro em 17/11/09.

aRegs:={}

//------------ Grupo/Ordem/Pergunta/PERGING/PERGESP/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05/F3

aAdd(aRegs,{cPerg,"01","Analitico/Sintetico?","","","mv_ch1","N",1, 0,1,"C","","mv_par01","Analitico","","","","","Sintetico","","","","","","","",""})
aAdd(aRegs,{cPerg,"02","Por Separ./Confer. ?","","","mv_ch2","N",1, 0,1,"C","","mv_par02","Separador","","","","","Conferente","","","","","","","",""})
aAdd(aRegs,{cPerg,"03","Data inicial       ?","","","mv_ch3","D",8, 0,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"04","Data final         ?","","","mv_ch4","D",8, 0,0,"G","","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"05","Codigo Separ/Confer?","","","mv_ch5","C",2, 0,0,"G","","mv_par05","","","","","","","","","","","","","","","","","","","","","","","","","SZC"})

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

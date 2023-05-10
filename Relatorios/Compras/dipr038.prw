/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Funcao    ³ DIPR038  ³ Autor ³ Eriberto Elias     ³ Data ³ 28/08/2003  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Curva ABC por volume de compras                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ DIPR038                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Especifico DIPROMED                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
Alterações:
Eriberto - 25/08/05 - coloquei na query para filtrar local = 01
*/
#include "rwmake.ch"

User Function DIPR038()

Local _xArea   := GetArea()

Local titulo     := OemTOAnsi("Curva ABC por volume de compras...",72)
Local cDesc1     := OemToAnsi("Este programa tem como objetivo emitir um relat¢rio",72)
Local cDesc2     := OemToAnsi("com o curva ABC por volume de compras.",72)
Local cDesc3     := OemToAnsi("Conforme parametros definidos pelo o usuario.",72)

Private aReturn    := {"Bco A4", 1,"Faturamento", 1, 2, 1,"",1}
Private li         := 66
Private tamanho    := "G"
Private limite     := 220
Private nomeprog   := "DIPR038"   

//Private cPerg      := "DIPR38"
// FPADR(cPerg, cArq, cCampo, cTipo)  - Para ajustar o tamanho das perguntas no SX1- uso generico
PRIVATE cPerg  	:= U_FPADR( "DIPR38","SX1","SX1->X1_GRUPO"," " ) //Função criada por Sandro em 19/11/09.

Private nLastKey   := 0
Private lEnd       := .F.
Private wnrel      := "DIPR038"
Private cString    := "SD1"
Private m_pag      := 1

Private _nTotal := _nTotalA := _nTotalB := _nTotalC := 0
Private _cCampo := '('
Private _cMes   := 0
Private nCntImpr := 0
Private cRodaTxt := ""
Private _cArqTrb
Private _cChave

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

Processa({|lEnd| RodaProc()},Titulo)

RptStatus({|lEnd| RodaRel()},Titulo)

RestArea(_xArea)

Return

//////////////////////////////////////////////////////////////////////
Static Function RodaProc()

ProcRegua(15000)
For _x := 1 to 5000
	IncProc( "Preparando os dados... ")
Next

/*
select D1_COD, B1_DESC, A2_NREDUZ, B1_UM, B1_UCOM, B1_UPRC+(B1_UPRC*B1_IPI/100) B1_UPRC, B1_ABC, (B3_Q07+B3_Q06+B3_Q05)/3/30 B3_MEDIA, SUM(D1_TOTAL) D1_TOTAL, SUM(D1_QUANT) D1_QUANT
from SD1010, SB1010, SB3010, SA2010
where SD1010.D1_FILIAL = '04'
and SB1010.B1_FILIAL = '  '
and SB3010.B3_FILIAL = '  '
and SD1010.D1_LOCAL = '01'
and SB3010.B2_LOCAL = '01'
and SD1010.D_E_L_E_T_ <> '*'
and SB1010.D_E_L_E_T_ <> '*'
and SB3010.D_E_L_E_T_ <> '*'
and SA2010.D_E_L_E_T_ <> '*'
and SD1010.D1_DTDIGIT between '20030701' and '20030731'           -- entre MV_PAR01 e MV_PAR02
and SB1010.B1_PROC = '000041'                                     -- MV_PAR03 = 000041
and SD1010.D1_COD between '               ' and '123456789012345' -- entre MV_PAR11 e MV_PAR12
and SD1010.D1_COD = SB1010.B1_COD
and SD1010.D1_COD = SB3010.B3_COD
and SB1010.B1_PROC (*LEFT JOIN) SA2010.A2_COD
and SB1010.B1_TIPO <> 'MC'
group by D1_COD, B1_DESC, A2_NREDUZ, B1_UM, B1_UCOM, B1_UPRC+(B1_UPRC*B1_IPI/100), B1_ABC, (B3_Q07+B3_Q06+B3_Q05)/3/30
order by D1_TOTAL desc
*/
For _x := 1 to 3
	If Month(mv_par01)-_x <= 0
		_cMes := 12 - Month(mv_par01)-_x
	Else
		_cMes := Month(mv_par01)-_x
	EndIf
	_cCampo := _cCampo + 'B3_Q'+StrZero(_cMes,2)+Iif(_x<>3,'+',')/3/30')
Next

//QRY1 :=        "SELECT D1_COD, B1_DESC, A2_NREDUZ, B1_UM, B1_UCOM, (B1_CUSDIP) B1_UPRC, B1_ABC, "+_cCampo+" B3_MEDIA, SUM(D1_TOTAL) D1_TOTAL, SUM(D1_QUANT) D1_QUANT"    // MCVN - 30/10/2008
//QRY1 :=        "SELECT D1_COD, B1_DESC, A2_NREDUZ, B1_UM, B1_UCOM, (B1_LISFOR) B1_UPRC, B1_ABC, "+_cCampo+" B3_MEDIA, SUM(D1_TOTAL) D1_TOTAL, SUM(D1_QUANT) D1_QUANT"    // MCVN - 26/03/2009
QRY1 :=          "SELECT D1_COD, B1_DESC, A2_NREDUZ, B1_UM, B1_UCOM, (B1_CUSDIP) B1_UPRC, B1_ABC, "+_cCampo+" B3_MEDIA, SUM(D1_TOTAL) D1_TOTAL, SUM(D1_QUANT) D1_QUANT"    // MCVN - 02/04/2009
QRY1 := QRY1 + " FROM " + RetSQLName("SD1") + " SD1 with (nolock)"

QRY1 := QRY1 + " inner join " + RetSQLName("SB1") + " SB1 with (nolock)"
QRY1 := QRY1 + "    on  SB1.D_E_L_E_T_ <> '*' "
QRY1 := QRY1 + "    and SB1.B1_FILIAL = '"+xFilial('SB1')+"' "
QRY1 := QRY1 + "    and SD1.D1_COD = SB1.B1_COD "
QRY1 := QRY1 + "    and SB1.B1_TIPO <> 'MC'"
	If !Empty(mv_par10)
		QRY1 := QRY1 + "    and SB1.B1_PROC = '"+mv_par10+"' "
	EndIf

QRY1 := QRY1 + " inner join " + RetSQLName("SB3") + " SB3 with (nolock)"
QRY1 := QRY1 + "    on  SB3.D_E_L_E_T_ <> '*' "
QRY1 := QRY1 + "    and SB3.B3_FILIAL = '"+xFilial('SB3')+"' "
QRY1 := QRY1 + "    and SD1.D1_COD = SB3.B3_COD "

QRY1 := QRY1 + " left join " + RetSQLName("SA2") + " SA2 with (nolock)"
QRY1 := QRY1 + "    on  SA2.D_E_L_E_T_ <> '*' "
QRY1 := QRY1 + "    and SB1.B1_PROC = SA2.A2_COD "

QRY1 := QRY1 + " WHERE SD1.D_E_L_E_T_ <> '*' "
QRY1 := QRY1 + "    and SD1.D1_FILIAL = '"+xFilial('SD1')+"' "
QRY1 := QRY1 + "    and SD1.D1_LOCAL = '01' "
QRY1 := QRY1 + "    and SD1.D1_DTDIGIT between '"+DTOS(mv_par01)+"' and '"+DTOS(mv_par02)+"' "
QRY1 := QRY1 + "    and SD1.D1_COD between '"+mv_par11+"' and '"+mv_par12+"' "

//QRY1 := QRY1 + ' group by D1_COD, B1_DESC, A2_NREDUZ, B1_UM, B1_UCOM, B1_CUSDIP, B1_ABC, '+_cCampo    
//QRY1 := QRY1 + ' group by D1_COD, B1_DESC, A2_NREDUZ, B1_UM, B1_UCOM, B1_LISFOR, B1_ABC, '+_cCampo // MCVN - 26/03/2009
QRY1 := QRY1 + ' group by D1_COD, B1_DESC, A2_NREDUZ, B1_UM, B1_UCOM, B1_CUSDIP, B1_ABC, '+_cCampo// MCVN - 02/04/2009
QRY1 := QRY1 + " order by D1_TOTAL desc"

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

DbSelectArea("QRY1")
Sum QRY1->D1_TOTAL TO _nTotal
Sum QRY1->D1_TOTAL TO _nTotalA FOR QRY1->B1_ABC == 'A'
Sum QRY1->D1_TOTAL TO _nTotalB FOR QRY1->B1_ABC == 'B'
Sum QRY1->D1_TOTAL TO _nTotalC FOR QRY1->B1_ABC == 'C'
QRY1->(dbGotop())

ProcRegua(15000)
For _x := 1 to 5000
	IncProc( "Classificando... ")
Next

_aCampos := {}
_aTamSX3 := TamSX3("D1_COD")
AAdd(_aCampos ,{"D1_COD", "C",_aTamSX3[1],_aTamSX3[2]})
_aTamSX3 := TamSX3("B1_DESC")
AAdd(_aCampos ,{"B1_DESC", "C",_aTamSX3[1],_aTamSX3[2]})
_aTamSX3 := TamSX3("A2_NREDUZ")
AAdd(_aCampos ,{"A2_NREDUZ", "C",_aTamSX3[1],_aTamSX3[2]})
_aTamSX3 := TamSX3("B1_UM")
AAdd(_aCampos ,{"B1_UM", "C",_aTamSX3[1],_aTamSX3[2]})
_aTamSX3 := TamSX3("B1_UCOM")
AAdd(_aCampos ,{"B1_UCOM", "C",_aTamSX3[1],_aTamSX3[2]})
_aTamSX3 := TamSX3("B1_UPRC")
AAdd(_aCampos ,{"B1_UPRC", "N",_aTamSX3[1],_aTamSX3[2]})
_aTamSX3 := TamSX3("B1_ABC")
AAdd(_aCampos ,{"B1_ABC", "C",_aTamSX3[1],_aTamSX3[2]})
_aTamSX3 := TamSX3("B3_MEDIA")
AAdd(_aCampos ,{"B3_MEDIA", "N",_aTamSX3[1],_aTamSX3[2]})
_aTamSX3 := TamSX3("D1_TOTAL")
AAdd(_aCampos ,{"D1_TOTAL", "N",_aTamSX3[1],_aTamSX3[2]})
_aTamSX3 := TamSX3("D1_QUANT")
AAdd(_aCampos ,{"D1_QUANT", "N",_aTamSX3[1],_aTamSX3[2]})

_cArqTrb := CriaTrab(_aCampos,.T.)
DbUseArea(.T.,,_cArqTrb,"TRB",.F.,.F.)

SQLtoTRB(QRY1,_aCampos,"TRB")

DbSelectArea("TRB")
_cChave := "D1_TOTAL*-1"
IndRegua("TRB",_cArqTrb,_cChave,,,"Classificando tudo...")
TRB->(DbGotop())
ProcRegua(RecCount())

Do While _nTotalA <= _nTotal*mv_par03/100 .and. TRB->(!Eof())
	IncProc( "Classificando...A ")
	If !(TRB->B1_ABC $ 'ABC')
		RECLOCK("TRB",.F.)
		TRB->B1_ABC := '2'
		TRB->(MSUNLOCK())
		_nTotalA+=TRB->D1_TOTAL
	Else
		RECLOCK("TRB",.F.)
		TRB->B1_ABC := IIF(TRB->B1_ABC=='A','1',IIF(TRB->B1_ABC=='B','3',IIF(TRB->B1_ABC=='C','5',TRB->B1_ABC)))
		TRB->(MSUNLOCK())
	EndIf
	TRB->(DbSkip())
EndDo

Do While _nTotalB <= _nTotal*mv_par04/100 .and. TRB->(!Eof())
	IncProc( "Classificando...B ")
	If !(TRB->B1_ABC $ 'ABC')
		RECLOCK("TRB",.F.)
		TRB->B1_ABC := '4'
		TRB->(MSUNLOCK())
		_nTotalB+=TRB->D1_TOTAL
	Else
		RECLOCK("TRB",.F.)
		TRB->B1_ABC := IIF(TRB->B1_ABC=='A','1',IIF(TRB->B1_ABC=='B','3',IIF(TRB->B1_ABC=='C','5',TRB->B1_ABC)))
		TRB->(MSUNLOCK())
	EndIf
	TRB->(DbSkip())
EndDo

Do While TRB->(!Eof())
	IncProc( "Classificando...C ")
	If !(TRB->B1_ABC $ 'ABC')
		RECLOCK("TRB",.F.)
		TRB->B1_ABC := '6'
		TRB->(MSUNLOCK())
		_nTotalC+=TRB->D1_TOTAL
	Else
		RECLOCK("TRB",.F.)
		TRB->B1_ABC := IIF(TRB->B1_ABC=='A','1',IIF(TRB->B1_ABC=='B','3',IIF(TRB->B1_ABC=='C','5',TRB->B1_ABC)))
		TRB->(MSUNLOCK())
	EndIf
	TRB->(DbSkip())
EndDo

_cChave := "B1_ABC+ALLTRIM(STR(100000000-D1_TOTAL,12,2))"
IndRegua("TRB",_cArqTrb,_cChave,,,"Classificando TUDO...")

dbSelectArea("QRY1")
QRY1->(dbCloseArea())

If mv_par09 == 2
	DbSelectArea("TRB")
	ProcRegua(RecCount())
	TRB->(DbGotop())
	
	Do While TRB->(!EOF())
		IncProc( "Alterando produto: "+TRB->D1_COD)
		DbSelectArea("SB1")
		dbSetOrder(1)
		If DbSeek(xFilial("SB1")+TRB->D1_COD)
			If !(SB1->B1_ABC $ 'ABC')
				RECLOCK("SB1",.F.)
				SB1->B1_ABC := IIF(TRB->B1_ABC=='2','a',IIF(TRB->B1_ABC=='4','b',IIF(TRB->B1_ABC=='6','c',TRB->B1_ABC)))
				SB1->(MSUNLOCK())
			EndIf
		EndIf
		DbSelectArea("TRB")
		TRB->(DbSkip())
	EndDo
EndIf


Return(.T.)

/////////////////////////
Static Function RodaRel()

DbSelectArea("TRB")
TRB->(DbGotop())
SetRegua(RecCount())

_cTitulo := "Curva ABC de produtos por volume de compra - De: "+dTOc(mv_par01)+' ate: '+dTOc(mv_par02)
_cDesc1  := "                                                                                                                                      Estoque       Ultima        Ultimo   Classificacao"
_cDesc2  := "Produto                                                               Marca                  UM             Custo    Quantidade        Minimo      Entrada         Preco   ABC        %"
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
	*                                                                                                                                      Estoque       Ultima        Ultimo   Classificacao
	*Produto                                                               Marca                  UM             Custo    Quantidade        Minimo      Entrada         Preco   ABC        %
	*999999 123456789012345678901234567890123456789012345678901234567890   12345678901234567890   UMX   999.999.999,99   999.999.999   999.999.999   XX/XX/XXXX   99.999,9999    A    999,99%
	*                                                                                  TotaL GeraL:   9.999.999.999,99   999,99%
	
	@ li,000 PSay SUBSTR(TRB->D1_COD,1,6)+' '+TRB->B1_DESC
	@ li,070 PSay TRB->A2_NREDUZ
	@ li,093 PSay TRB->B1_UM
	@ li,099 PSay TRB->D1_TOTAL PICTURE "@E 999,999,999.99"
	@ li,116 PSay TRB->D1_QUANT PICTURE "@E 999,999,999"
	@ li,130 PSay TRB->B3_MEDIA * Iif(TRB->B1_ABC $ '12',mv_par06,Iif(TRB->B1_ABC $ '34',mv_par07,mv_par08)) PICTURE "@E 999,999,999"
	@ li,144 PSay SubStr(TRB->B1_UCOM,7,2)+'/'+SubStr(TRB->B1_UCOM,5,2)+'/'+SubStr(TRB->B1_UCOM,1,4)
	@ li,157 PSay TRB->B1_UPRC PICTURE "@E 99,999.9999"
	@ li,172 PSay Iif(TRB->B1_ABC == '1','A',Iif(TRB->B1_ABC == '2','a',Iif(TRB->B1_ABC == '3','B',Iif(TRB->B1_ABC == '4','b',Iif(TRB->B1_ABC == '5','C','c')))))
	@ li,177 PSay TRB->D1_TOTAL / _nTotal * 100 PICTURE "@E 999.99"
	@ li,183 PSay "%"
	li++
	
	_nTotalA+=Iif(TRB->B1_ABC $ '12',TRB->D1_TOTAL,0)
	_nTotalB+=Iif(TRB->B1_ABC $ '34',TRB->D1_TOTAL,0)
	_nTotalC+=Iif(TRB->B1_ABC $ '56',TRB->D1_TOTAL,0)
	
	nCntImpr++
	TRB->(DbSkip())
	
EndDo

If li > 60
	li := Cabec(_cTitulo,_cDesc1,_cDesc2,nomeprog,tamanho) + 1
	@ li,082 PSay 'TotaL GeraL:'
	@ li,097 PSay _nTotal PICTURE "@E 9,999,999,999.99"
	li+=2
	@ li,082 PSay 'TotaL A:'
	@ li,097 PSay _nTotalA PICTURE "@E 9,999,999,999.99"
	@ li,116 PSay _nTotalA/_nTotal*100 PICTURE "@E 999.99"
	@ li,122 PSay "%"
	LI++
	@ li,082 PSay 'TotaL B:'
	@ li,097 PSay _nTotalB PICTURE "@E 9,999,999,999.99"
	@ li,116 PSay _nTotalC/_nTotal*100 PICTURE "@E 999.99"
	@ li,122 PSay "%"
	LI++
	@ li,082 PSay 'TotaL C:'
	@ li,097 PSay _nTotalC PICTURE "@E 9,999,999,999.99"
	@ li,116 PSay _nTotalC/_nTotal*100 PICTURE "@E 999.99"
	@ li,122 PSay "%"
	li+=2
	@ li,000 PSay AllTrim(STR(nCntImpr,4,0))+cRodaTxt
	Roda(nCntImpr,cRodaTxt,tamanho)
Else
	@ li,082 PSay 'TotaL GeraL:'
	@ li,097 PSay _nTotal PICTURE "@E 9,999,999,999.99"
	li+=2
	@ li,082 PSay 'TotaL A:'
	@ li,097 PSay _nTotalA PICTURE "@E 9,999,999,999.99"
	@ li,116 PSay _nTotalA/_nTotal*100 PICTURE "@E 999.99"
	@ li,122 PSay "%"
	LI++
	@ li,082 PSay 'TotaL B:'
	@ li,097 PSay _nTotalB PICTURE "@E 9,999,999,999.99"
	@ li,116 PSay _nTotalB/_nTotal*100 PICTURE "@E 999.99"
	@ li,122 PSay "%"
	LI++
	@ li,082 PSay 'TotaL C:'
	@ li,097 PSay _nTotalC PICTURE "@E 9,999,999,999.99"
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
aAdd(aRegs,{cPerg,"09","Atualiza Cad.Produto?","","","mv_ch9","N",1, 0,1,"C","","mv_par09","Nao","","","","","Sim","","","","","","","",""})
aAdd(aRegs,{cPerg,"10","Fornecedor          ?","","","mv_chA","C",6, 0,0,"G","","mv_par10","","","","","","","","","","","","","","","","","","","","","","","","",'SA2'})
aAdd(aRegs,{cPerg,"11","Do Produto          ?","","","mv_chB","C",15,0,0,"G","","mv_par11","","","","","","","","","","","","","","","","","","","","","","","","","SB1"})
aAdd(aRegs,{cPerg,"12","Ate Produto         ?","","","mv_chC","C",15,0,0,"G","","mv_par12","","","","","","","","","","","","","","","","","","","","","","","","","SB1"})

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

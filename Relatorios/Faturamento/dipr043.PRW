/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Funcao   ³ DIPR043 ³ Autor ³ Rafael de Campos Falco ³ Data ³ 16/01/2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Relatorio de Faturamento X Compra por fornecedor           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ DIPR043                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Especifico DIPROMED                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

#include "rwmake.ch"
#INCLUDE "TOPCONN.CH"

#IFNDEF WINDOWS
	#DEFINE PSay Say
#ENDIF

User Function DIPR043()

Local _xArea	:= GetArea()
Local titulo	:= OemTOAnsi("Relatório de faturamento e compras por fornecedor",72)
Local cDesc1	:= OemToAnsi("Este programa tem como objetivo emitir um relat¢rio",72)
Local cDesc2	:= OemToAnsi("do volume de faturamento e compras do período por fornecedor de 12 meses.",72)
Local cDesc3	:= OemToAnsi("Conforme parametros definidos pelo o usuario.",72)
Local cUserAut  := GetMV("MV_URELFAT") // MCVN - 04/05/09        

Private tamanho	:= "G"
Private limite		:= 220
Private aReturn	:= {"Bco A4", 1,"Faturamento", 1, 2, 1,"",1}
Private nomeprog	:= "DIPR043"

// Private cPerg		:= "DIPR43"
// FPADR(cPerg, cArq, cCampo, cTipo)  - Para ajustar o tamanho das perguntas no SX1- uso generico
PRIVATE cPerg  	:= U_FPADR( "DIPR43","SX1","SX1->X1_GRUPO"," " ) //Função criada por Sandro em 19/11/09.

Private nLastKey	:= 0
Private lContinua	:= .T.
Private lEnd		:= .F.
Private li			:= 67
Private wnrel		:= "DIPR043"
Private M_PAG		:= 1
Private cString	:= "SD1"
Private _aTotal	:= {}
Private _aCompr	:= {}
Private _aFatur	:= {}    


U_DIPPROC(ProcName(0),U_DipUsr()) // JBS 05/10/2005 - Gravando o nome do Programa no SZU
// MCVN - 04/05/09    
If !(Upper(U_DipUsr()) $ cUserAut)
	Alert(Upper(U_DipUsr())+", você não tem autorização para utilizar esta rotina. Qualquer dúvida falar com Departamento de T.I. !","Atenção")	 //Giovani Zago 16/08/11
	Return()
EndIF  

AjustaSX1(cPerg)             // Verifica perguntas. Se nao existe INCLUI                   

If !Pergunte(cPerg,.T.)    // Solicita parametros
	Return
EndIf                      

wnrel := SetPrint(cString,wnrel,cPerg,Titulo,cDesc1,cDesc2,cDesc3,.f.,,.f.,tamanho,,.f.,,,,,)

If nLastKey == 27
	Return
Endif

SetDefault(aReturn,cString)

Processa({|lEnd| RunProc()},"Totalizando Faturamento X Compra por fornecedor...")

RptStatus({|lEnd| RptDetail()},"Imprimindo Faturamento X Compra por fornecedor...")

RestArea(_xArea)

Return

//////////////////////////////////////////////////////////////////////
Static Function RunProc()
Local zi 		:= 0
Local xi 		:= 1
Local _nSoma	:= 0
Local _cCodFor := ""
Local _cNomFor := ""

ProcRegua(900)
For _x := 1 to 300
	IncProc( "Processando Faturamento... ")
Next

// Determina os 12 meses que serão apresentados
_nMesFim := Substr(mv_par01,1,2)
_nAnoFim := Substr(mv_par01,3,4)
If Val(_nMesFim) == 12
	_nMesIni := 1
	_nAnoIni := Val(_nAnoFim)    // Rafael tive que colocar isto pra funcionar no mês 12. Eriberto
Else
	_nMesIni := Val(_nMesFim) + 1
	_nAnoIni := Val(_nAnoFim) - 1
EndIf
_nParPer := AllTrim(Str(_nAnoIni))+AllTrim(StrZero(_nMesIni,2))

/*
SELECT D2_FORNEC, LEFT(D2_EMISSAO,6) ANO_MES, D2_FILIAL, SUM(D2_TOTAL) D2_TOTAL
FROM SD2010, SF4010
WHERE LEFT(D2_EMISSAO,6) <= '200401'
AND LEFT(D2_EMISSAO,6) >= '200302'
AND D2_TIPO <> 'D'
AND D2_TES = F4_CODIGO
AND F4_DUPLIC = 'S'
AND SD2010.D_E_L_E_T_ <> '*'
AND SF4010.D_E_L_E_T_ <> '*'
GROUP BY LEFT(D2_EMISSAO,6), D2_FORNEC 
ORDER BY D2_FORNEC, LEFT(D2_EMISSAO,6)
*/

QRY1 := " SELECT LEFT(D2_EMISSAO,6) ANO_MES, D2_FORNEC, SUM(D2_TOTAL + D2_VALFRE + D2_SEGURO + D2_DESPESA + D2_ICMSRET) D2_TOTAL"
QRY1 += " FROM " +  RetSQLName('SD2') + ", " + RetSQLName('SF4')
QRY1 += " WHERE LEFT(D2_EMISSAO,6) <= '" + SUBS(MV_PAR01,3,4)+SUBS(MV_PAR01,1,2) + "'"
QRY1 += " AND   LEFT(D2_EMISSAO,6) >= '" + _nParPer + "'"
QRY1 += " AND D2_TIPO <> 'D'" //Giovani Zago 13/09/11
//Giovani Zago 13/09/11
//QRY1 += " AND D2_TIPO = 'NC' "
//Giovani Zago 16/08/11
If cEmpAnt = '01' 
QRY1 += " AND D2_FILIAL  IN ('01','04')"
ElseIf  cEmpAnt = '04'
QRY1 += " AND D2_FILIAL  = '" + xFILIAL("SD2") + "'"
EndIf
QRY1 += " AND D2_FILIAL = F4_FILIAL " 
//**********************************************

QRY1 += " AND D2_TES = F4_CODIGO "
//QRY1 += " AND D2_FORNEC = '000462'"
QRY1 += " AND F4_DUPLIC = 'S'    "
QRY1 += " AND " + RetSQLName('SD2') + ".D_E_L_E_T_ <> '*' "
QRY1 += " AND " + RetSQLName('SF4') + ".D_E_L_E_T_ <> '*' "
QRY1 += " GROUP BY LEFT(D2_EMISSAO,6), D2_FORNEC "
QRY1 += " ORDER BY D2_FORNEC,LEFT(D2_EMISSAO,6)  "

QRY1 := ChangeQuery(QRY1)
dbUseArea(.T., "TOPCONN", TCGenQry(,,QRY1), 'QRY1', .F., .T.)

memowrite('DIPR043F.SQL',QRY1)

DbSelectArea("QRY1")
QRY1->(DbGoTop())

ProcRegua(900)
For _x := 1 to 600
	IncProc( "Montando dados Faturamento... ")
Next

/// MONTAGEM DO ARRAY DE FATURAMENTO DO PERÍODO DE 12 MESES
Do While QRY1->(!Eof())

	DbSelectArea("SA2")
	DbSetOrder(1)
	DbSeek(xFilial("SA2")+QRY1->D2_FORNEC)
	If SA2->A2_FORPROD == 'P'
		Aadd(_aFatur,{"","",0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0})	
		// Inicializa variáveis de controle
		_nSoma	:= 0
		_cCodFor := QRY1->D2_FORNEC
		_cNomFor := AllTrim(SA2->A2_NREDUZ)
		
		_aFatur[xi,1]	:= _cNomFor
		_aFatur[xi,2]	:= _cCodFor
		
		_nMesCon := _nMesIni
		zi	:= 3
		
		Do While QRY1->D2_FORNEC == _cCodFor
			
			If Val(SubStr(QRY1->ANO_MES,5,2)) == _nMesCon
				_aFatur[xi,zi] := QRY1->D2_TOTAL			
			    _nSoma += QRY1->D2_TOTAL // JBS 11/01/2006 - Corrigido problema no total do relatorio
				QRY1->(DbSkip())
			EndIf 
			zi += 1			
			If(_nMesCon == 12)
				_nMesCon := 1
			Else
				_nMesCon += 1
			EndIf				
		EndDo
		_aFatur[xi,15] := _nSoma
		xi++
	Else
		QRY1->(DbSkip())
	EndIf
EndDo      

ProcRegua(900)
For _x := 1 to 900
	IncProc( "Finalizando Faturamento... ")
Next

ProcRegua(900)
For _x := 1 to 300
	IncProc( "Processando Compras... ")
Next

/*
SELECT LEFT(D1_DTDIGIT,6) ANO_MES, D1_FORNECE, SUM(D1_TOTAL) D1_TOTAL
FROM SD1010, SF4010
WHERE LEFT(D1_DTDIGIT,6) <= '200401'
AND   LEFT(D1_DTDIGIT,6) >= '200302'
AND D1_TES = F4_CODIGO
AND F4_DUPLIC = 'S'
AND SD1010.D_E_L_E_T_ <> '*'
AND SF4010.D_E_L_E_T_ <> '*'
GROUP BY LEFT(D1_DTDIGIT,6), D1_FORNECE
ORDER BY D1_FORNECE, LEFT(D1_DTDIGIT,6)
*/

QRY2 := " SELECT LEFT(D1_DTDIGIT,6) ANO_MES, D1_FORNECE, SUM( D1_TOTAL + D1_VALFRE + D1_SEGURO + D1_DESPESA + D1_ICMSRET ) D1_TOTAL "
QRY2 += " FROM " +  RetSQLName('SD1') + ", " + RetSQLName('SF4')
QRY2 += " WHERE LEFT(D1_DTDIGIT,6) <= '" + SUBS(MV_PAR01,3,4)+SUBS(MV_PAR01,1,2) + "'"
QRY2 += " AND   LEFT(D1_DTDIGIT,6) >= '" + _nParPer + "'"
QRY2 += " AND D1_TES = F4_CODIGO"
//Giovani Zago 13/09/11
//QRY2 += " AND D1_TIPO = 'NC' "

//Giovani Zago 16/08/11
If cEmpAnt = '01' 
QRY2 += " AND D1_FILIAL  IN ('01','04')"
ElseIf  cEmpAnt = '04'
QRY2 += " AND D1_FILIAL  = '" + xFILIAL("SD1") + "'"
EndIf
QRY2 += " AND D1_FILIAL = F4_FILIAL " 
//**********************************************
//QRY2 += " AND D1_FORNECE = '000462'"
QRY2 += " AND F4_DUPLIC = 'S'"
QRY2 += " AND " + RetSQLName('SD1') + ".D_E_L_E_T_ <> '*'"
QRY2 += " AND " + RetSQLName('SF4') + ".D_E_L_E_T_ <> '*'"
QRY2 += " GROUP BY LEFT(D1_DTDIGIT,6), D1_FORNECE"
QRY2 += " ORDER BY D1_FORNECE, LEFT(D1_DTDIGIT,6)"

QRY2 := ChangeQuery(QRY2)
dbUseArea(.T., "TOPCONN", TCGenQry(,,QRY2), 'QRY2', .F., .T.)

memowrite('DIPR043C.SQL',QRY2)

DbSelectArea("QRY2")
QRY2->(DbGoTop())

ProcRegua(900)
For _x := 1 to 600
	IncProc( "Montando Dados Compras... ")
Next


/// MONTAGEM DO ARRAY DE COMPRAS DO PERÍODO DE 12 MESES
xi := 1
Do While QRY2->(!Eof())	

	DbSelectArea("SA2")
	DbSetOrder(1)
	DbSeek(xFilial("SA2")+QRY2->D1_FORNECE)
	If SA2->A2_FORPROD == 'P'
		_nPos := Ascan(_aFatur,{|x| x[2] == QRY2->D1_FORNECE})

		// Inicializa variáveis de controle
		_nSoma	:= 0
		_cCodFor := QRY2->D1_FORNECE
		_cNomFor := AllTrim(SA2->A2_NREDUZ)
		
		If _nPos == 0
			Aadd(_aFatur,{_cNomFor,_cCodFor,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0})
			_nPos := Ascan(_aFatur,{|x| x[2] == QRY2->D1_FORNECE})
		EndIf             
		
		_nMesCon := _nMesIni
		zi	:= 16	
		
		Do While QRY2->D1_FORNECE == _cCodFor
			

			If Val(SubStr(QRY2->ANO_MES,5,2)) == _nMesCon
				_aFatur[_nPos,zi] := QRY2->D1_TOTAL			
			    _nSoma += QRY2->D1_TOTAL
				QRY2->(DbSkip())
			EndIf 

			zi += 1			
			
			If(_nMesCon == 12)
				_nMesCon := 1
			Else
				_nMesCon += 1
			EndIf				                   
		EndDo
		_aFatur[_nPos,28] := _nSoma
	Else
		QRY2->(DbSkip())
	EndIf		
EndDo    

ProcRegua(900)
For _x := 1 to 900
	IncProc( "Finalizando Compras... ")
Next
	
QRY1->(DbCloseArea())
QRY2->(DbCloseArea())

Return

///////////////////////////
Static Function RptDetail()
Local _cTitulo := ""
Local _cDesc1  := "Fornecedor " + Space(20)
Local _cDesc2  := ""
Local _cCodFor := ""
Local _nConta	:= 0
Local _nMesFim := 0
Local _nAnoFim := 0
Local _nPos		:= 0
Local _nCol		:= 0
Local _nMesIni := Val(Substr(MV_PAR01,1,2))
Local _nAnoIni := Val(Substr(MV_PAR01,3,4))


/// ORDENA RELATORIO CONFORME INFORMACAO DO OPERADOR
If MV_PAR02 == 1
	aSort( _aFatur ,,, {|a,b| a[15] > b[15]} )
Else
	aSort( _aFatur ,,, {|a,b| a[26] > b[26]} )
EndIf

// DETERMINA OS 12 MESES QUE SERãO APRESENTADOS
If _nMesIni >= 12
	_nMesFim := 1
	_nAnoFim := _nAnoIni
Else
	_nMesFim := _nMesIni + 1
	_nAnoFim := _nAnoIni - 1
EndIf
_nParPer := AllTrim(Str(_nAnoFim))+AllTrim(StrZero(_nMesFim,2))

// MONTA O CABECALHO COM OS 12 MESES SELECIONADOS
For xi:=1 to 12
	_nTamMes := 14 - Len(MesExtenso(_nMesFim))
	_cDesc1 += Space(_nTamMes)+MesExtenso(_nMesFim)

	If _nMesFim >= 12
		_nMesFim := 1
	Else
		_nMesFim++
	EndIf
Next
_cTitulo := "Faturamento X Compras por Fornecedor - de " + SubStr(_nParPer,5,2)+"/"+SubStr(_nParPer,1,4) + " até " + SubStr(mv_par01,1,2)+"/"+SubStr(mv_par01,3,4)
_cDesc1 += Space(11)+"Total"


SetRegua(Len(_aFatur))

*                                                                                                    1                                                                                                   2                                                                                                   3
*          1         2         3         4         5         6         7         8         9         0         1         2         3         4         5         6         7         8         9         0         1         2         3         4         5         6         7         8         9         0         1         2         3         4         5         6
*01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
*Fornecedor                            Janeiro     Fevereiro         Marco         Abril          Maio         Junho         Julho        Agosto      Setembro       Outubro      Novembro      Dezembro           Total
*12345678901234567890-999999 FAT 99.999.999,99 99.999.999,99 99.999.999,99 99.999.999,99 99.999.999,99 99.999.999,99 99.999.999,99 99.999.999,99 99.999.999,99 99.999.999,99 99.999.999,99 99.999.999,99   99.999.999,99
*                            COM 99.999.999,99 99.999.999,99 99.999.999,99 99.999.999,99 99.999.999,99 99.999.999,99 99.999.999,99 99.999.999,99 99.999.999,99 99.999.999,99 99.999.999,99 99.999.999,99   99.999.999,99
*-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*Total Geral Faturamento         99.999.999,99 99.999.999,99 99.999.999,99 99.999.999,99 99.999.999,99 99.999.999,99 99.999.999,99 99.999.999,99 99.999.999,99 99.999.999,99 99.999.999,99 99.999.999,99 99.999.999,99
*Total Geral Compras             99.999.999,99 99.999.999,99 99.999.999,99 99.999.999,99 99.999.999,99 99.999.999,99 99.999.999,99 99.999.999,99 99.999.999,99 99.999.999,99 99.999.999,99 99.999.999,99 99.999.999,99

Aadd(_aTotal,{"FAT","",0,0,0,0,0,0,0,0,0,0,0,0,0})	
Aadd(_aTotal,{"COM","",0,0,0,0,0,0,0,0,0,0,0,0,0})	

For xi := 1 To Len(_aFatur)

	IncRegua( "Imprimindo Faturamento e Compras: " + _aFatur[xi,1] )

	If li > 66
		li := Cabec(_cTitulo,_cDesc1,_cDesc2,nomeprog,tamanho) + 1
	EndIf
		
	// Impressão da linha do faturamento
	@ li,000 PSay _aFatur[xi,1]+'-'+_aFatur[xi,2]  // Fornecedor + codigo
	@ li,028 PSay "FAT"
	_nCol := 32
	For yi := 3 To 15
		@ li,_nCol+Iif(yi==15,2,0) PSay _aFatur[xi,yi] Picture "@E 99,999,999.99"
		_nCol += 14
		_aTotal[1,yi] += _aFatur[xi,yi]
	Next
	li++
		
	If li > 66
		li := Cabec(_cTitulo,_cDesc1,_cDesc2,nomeprog,tamanho) + 1
	EndIf
		
	// Impressão da linha de compras
	@ li,028 PSay "COM"
	_nCol := 32
	For yi := 16 To 28
		@ li,_nCol+Iif(yi==28,2,0) PSay _aFatur[xi,yi] Picture "@E 99,999,999.99"
		_nCol += 14
		_aTotal[2,yi-13] += _aFatur[xi,yi]
	Next
	li+=2
	
Next

If li > 66
	li := Cabec(_cTitulo,_cDesc1,_cDesc2,nomeprog,tamanho) + 1
EndIf

// IMPRESSãO DA LINHA DE TOTAIS
SetRegua(Len(_aTotal))
li += 2
@ li,000 psay Replicate("-",220)
li += 1
@ li,001 PSay "Total Geral Faturamento"
_nCol := 32
For nI:=3 To 15
	IncRegua( "Imprimindo Totais: " + StrZero(ni,3) )
	@ li,_nCol+Iif(ni==15,2,0) PSay _aTotal[1,nI] Picture "@E 99,999,999.99"	
	_nCol += 14
Next
li++

If li > 66
	li := Cabec(_cTitulo,_cDesc1,_cDesc2,nomeprog,tamanho) + 1
EndIf

@ li,001 PSay "Total Geral Compras"
_nCol := 32
For nI:=3 To 15
	IncRegua( "Imprimindo Totais: " + StrZero(ni,3) )
	@ li,_nCol+Iif(ni==15,2,0) PSay _aTotal[2,nI] Picture "@E 99,999,999.99"	
	_nCol += 14
Next
li++
@ li,000 psay Replicate("-",220)

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
Static Function AjustaSX1(cPerg)
_sAlias := Alias()
dbSelectArea("SX1")
dbSetOrder(1)                                                                    

aRegs:={}

//------------ Grupo/Ordem/Pergunta/PERGING/PERGESP/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05/F3

AADD(aRegs,{cPerg,"01","Mes e Ano Final?  ","","","mv_ch1","C",6,0,0,"G","","MV_PAR01","","","","","","","","","","","","","",""})
AADD(aRegs,{cPerg,"02","Informe a ordem?  ","","","mv_ch2","C",6,0,0,"C","","MV_PAR02","Faturamento","","","","","Compras","","","","","","","",""})

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
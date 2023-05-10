/*====================================================================================\
|Programa  | DIPR056       | Autor | Rafael de Campos Falco     | Data | 09/03/2005   |
|=====================================================================================|
|Descrição | Rel. de quantidades de produtos por fornecedor no período de 12 meses    |
|          |                                                                          |
|          |                                                                          |
|=====================================================================================|
|Sintaxe   | DIPR056                                                                  |
|=====================================================================================|
|Uso       | Especifico DIPROMED                                                      |
|=====================================================================================|
|........................................Histórico....................................|
|Rafael    | DD/MM/AA - Descrição                                                     |
|Eriberto  | DD/MM/AA - Descrição                                                     |
\====================================================================================*/

/*====================================================================================\
|COMENTÁRIO EM DESTAQUE                                                               |
\====================================================================================*/

#INCLUDE "RWMAKE.CH"

User Function DIPR056()
Local _xArea	:= GetArea()
Local titulo	:= OemTOAnsi("Relatório de quantidades de produtos por fornecedor no período de 12 meses ",72)
Local cDesc1	:= OemToAnsi("Este programa tem como objetivo emitir um relat¢rio",72)
Local cDesc2	:= OemToAnsi("do volume de compras do período de 12 meses.(SD1)",72)
Local cDesc3	:= OemToAnsi("Conforme parametros definidos pelo o usuario.",72)

Private M_PAG		:= 1
Private nLastKey	:= 0
Private limite		:= 220
Private li			:= 999
Private lContinua	:= .T.
Private lEnd		:= .F.

Private nomeprog	:= "DIPR056"
Private wnrel		:= "DIPR056"

// Private cPerg		:= "DIPR56"
// FPADR(cPerg, cArq, cCampo, cTipo)  - Para ajustar o tamanho das perguntas no SX1- uso generico
PRIVATE cPerg  	:= U_FPADR( "DIPR56","SX1","SX1->X1_GRUPO"," " ) //Função criada por Sandro em 19/11/09.

Private cString		:= "SD1"
Private tamanho		:= "G"
Private cMes_Ini	:= ""
Private cAno_Ini	:= ""
Private cDat_Ini	:= ""
Private QRY1		:= ""
Private _QRed		:= ""
Private aPos_Vol	:= {}
Private aLis_Qtd	:= {}
Private aTot_Pro	:= {0,0,0,0,0,0,0,0,0,0,0,0,0}
Private aReturn		:= {"Bco A4", 1,"Financeiro", 1, 2, 1,"",1}

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

Processa({|lEnd| Proc056()},"Filtrando dados para os parâmetros informados...")

RptStatus({|lEnd| Impr056()},"Imprimindo dados filtrados...")
                                                                         
RestArea(_xArea)

Return

/*====================================================================================\
| PROCESSAMENTO DOS DADOS                                                             |
\====================================================================================*/
Static Function Proc056()

Local cCod_Pro		:= ""

If Val(SubString(MV_PAR01,5,2)) == 12
	cMes_Ini := StrZero(1,2)
	cAno_Ini := SubString(MV_PAR01,1,4)
Else
	cMes_Ini := StrZero(1 + Val(SubString(MV_PAR01,5,2)), 2)
	cAno_Ini := StrZero(Val(SubString(MV_PAR01,1,4)) - 1, 4)
EndIf

cDat_Ini := cAno_Ini + cMes_Ini



/* QUERY PARA FILTRAR QUANTIDADE DOS PRODUTOS POR FORNECEDOR NO PERÍODO DE 12 MESES
SELECT D1_FORNECE, D1_LOJA, A2_NOME, D1_COD, B1_DESC, SUBSTRING(D1_DTDIGIT,1,6) D1_DTDIGIT, D1_TIPO, SUM(D1_QUANT) D1_QUANT 
FROM SD1010, SA2010, SB1010
WHERE D1_FILIAL = '04'
AND SUBSTRING(D1_DTDIGIT,1,6) BETWEEN '200404' AND '200503'
AND D1_TIPO = 'N'
AND D1_FORNECE BETWEEN  '000201' AND '000209'
AND A2_COD = D1_FORNECE
AND A2_LOJA = D1_LOJA
AND B1_COD = D1_COD
AND SD1010.D_E_L_E_T_ = ''
AND SA2010.D_E_L_E_T_ = ''
AND SB1010.D_E_L_E_T_ = ''
GROUP BY D1_FORNECE, D1_LOJA, A2_NOME, D1_COD, B1_DESC, SUBSTRING(D1_DTDIGIT,1,6), D1_TIPO
ORDER BY D1_FORNECE, D1_COD, SUBSTRING(D1_DTDIGIT,1,6)

*/

ProcRegua(300) 
For xi := 1 to 150
	IncProc("Filtrando dados...")
Next

_QRed := " SELECT D1_FORNECE, D1_LOJA, A2_NOME, D1_COD, B1_DESC, SUBSTRING(D1_DTDIGIT,1,6) D1_DTDIGIT, D1_TIPO, SUM(D1_QUANT) D1_QUANT "
_QRed += " FROM " + RetSQLName("SD1")+', '+ RetSQLName("SA2")+', '+ RetSQLName("SB1")
_QRed += " WHERE D1_FILIAL = '" + xFilial("SD1") + "'"
_QRed += " AND SUBSTRING(D1_DTDIGIT,1,6) BETWEEN '" + cDat_Ini + "' AND '" + MV_PAR01 + "'"
_QRed += " AND D1_TIPO = 'N'"
_QRed += " AND D1_FORNECE BETWEEN  '" + MV_PAR02 + "' AND '" + MV_PAR03 + "'"
_QRed += " AND A2_COD = D1_FORNECE"
_QRed += " AND A2_LOJA = D1_LOJA"
_QRed += " AND B1_COD = D1_COD"
_QRed += " AND " + RetSQLName("SD1") + ".D_E_L_E_T_ = ''"
_QRed += " AND " + RetSQLName("SA2") + ".D_E_L_E_T_ = ''"
_QRed += " AND " + RetSQLName("SB1") + ".D_E_L_E_T_ = ''"
_QRed += " GROUP BY D1_FORNECE, D1_LOJA, A2_NOME, D1_COD, B1_DESC, SUBSTRING(D1_DTDIGIT,1,6), D1_TIPO"
_QRed += " ORDER BY D1_FORNECE, D1_COD, SUBSTRING(D1_DTDIGIT,1,6)"

_QRed := ChangeQuery(_QRed)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,_QRed),"QRY1",.F.,.T.)

ProcRegua(300) 
For xi := 1 to 300
	IncProc("Fim do filtro...")
Next

ProcRegua(300) 
For xi := 1 to 150
	IncProc("Criando array com dados...")
Next
DbSelectArea("QRY1")
QRY1->(DbGoTop())
xi := 1
ProcRegua(600) 
While QRY1->(!EOF())
	IncProc("Criando array com dados..."+QRY1->D1_FORNECE)
	Aadd(aLis_Qtd,{"","","","","",0,0,0,0,0,0,0,0,0,0,0,0})
	aLis_Qtd[xi,1] := QRY1->D1_FORNECE
	aLis_Qtd[xi,2] := QRY1->D1_LOJA
	aLis_Qtd[xi,3] := QRY1->A2_NOME
	aLis_Qtd[xi,4] := QRY1->D1_COD
	aLis_Qtd[xi,5] := QRY1->B1_DESC
	
	cCod_Pro := QRY1->D1_COD
	nMes := Val(cMes_Ini)
	yi := 6
    While QRY1->(!EOF()) .and. cCod_Pro == QRY1->D1_COD
		If nMes == Val(SubString(QRY1->D1_DTDIGIT,5,2)) 
		   If yi >17   //Giovani Zago 21/12/11
		   //	alert(cvaltochar(yi))  //verifica o estouro do array Yi estava passando de 17
		    else//Giovani Zago 21/12/11
				aLis_Qtd[xi,yi] := QRY1->D1_QUANT
			yi++
			nMes++
			endif
			QRY1->(DbSkip())
		Else
			yi++
			nMes++
		EndIf
		If nMes > 12
			nMes := 1
		EndIf			
	EndDo
	xi++
EndDo




Return

/*====================================================================================\
| IMPRESSÃO DOS DADOS PROCESSADOS                                                     |
\====================================================================================*/
Static Function Impr056()

Local cCod_Pro	:= ""
Local _cTitulo	:= ""
Local nHandle	:= ""
Local cWorkFlow	:= "N"
Local _cDesc2	:= ""
Local _cDesc1	:= "Código-Descrição" + Space(51)
Local _nCol		:= 0

// Monta o cabeçalho com os 12 meses selecionados
For xi:=1 to 12
	_nTamMes := 11 - Len(MesExtenso(Val(cMes_Ini)))
	_cDesc1 += Space(_nTamMes)+MesExtenso(Val(cMes_Ini))

	If Val(cMes_Ini) >= 12
		cMes_Ini := StrZero(1,2)
	Else
		cMes_Ini := StrZero(Val(cMes_Ini) + 1)
	EndIf
Next

_cDesc1 += Space(11-Len("Total")) + "Total" + Space(10-Len("Média")) + "Média"

	*0                                                                                                   1                                                                                                   2                                                                                                   3
	*0         1         2         3         4         5         6         7         8         9         0         1         2         3         4         5         6         7         8         9         0         1         2         3         4         5         6         7         8         9         0         1         2         3         4         5         6
	*01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
	* 
	* 999999-XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
	* Código-Descrição                                                        Janeiro  Fevereiro      Marco      Abril       Maio      Junho      Julho     Agosto   Setembro    Outubro   Novembro   Dezembro      Total
	* 999999-XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX  99,999,999 99,999,999 99,999,999 99,999,999 99,999,999 99,999,999 99,999,999 99,999,999 99,999,999 99,999,999 99,999,999 99,999,999 99,999,999
	*------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


SetRegua(Len(aLis_Qtd))
aSort( aLis_Qtd ,,, {|a,b| a[5] < b[5]} )
cCod_For := aLis_Qtd[xi,1]
For xi:=1 To Len(aLis_Qtd)

	IncRegua( "Imprimindo: " + AllTrim(aLis_Qtd[xi,5]))	
	
	If aLis_Qtd[xi,1] != cCod_For
		M_PAG := 1
		li := 999
	EndIf
	
	If li > 65
		_cTitulo := "Quantidades compradas no período " + SubString(cDat_Ini,5,2) + "/" + SubString(cDat_Ini,1,4) + " até " + SubString(MV_PAR01,5,2) + "/" + SubString(MV_PAR01,1,4)
		cNom_For := " ( " + AllTrim(aLis_Qtd[xi,1]) + "-" + AllTrim(aLis_Qtd[xi,2]) + " - " + AllTrim(aLis_Qtd[xi,3]) + " )"
		li := U_MYCABEC(_cTitulo,_cDesc1,_cDesc2,nHandle,cWorkFlow,cNom_For)
		cCod_For := aLis_Qtd[xi,1]
	EndIf	

	// Impressão do Código-Descrição (produto)
	@ li,000 PSay AllTrim(aLis_Qtd[xi,4]) + "-" + aLis_Qtd[xi,5]

	// Impressão da linha das quantidades por mês
	yi := 6
	cCod_Pro := aLis_Qtd[xi,4]
	nTot_Pro := 0
	For yi:=6 To 17//giovani acho k e aki
		@ li,Pcol()+1 PSay aLis_Qtd[xi,yi] Picture "@E 99,999,999"
		nTot_Pro += aLis_Qtd[xi,yi]
	Next
	@ li,Pcol()+1 PSay nTot_Pro Picture "@E 99,999,999"
	@ li,Pcol()+1 PSay Iif((nTot_Pro/12) < 1, 0, nTot_Pro/12) Picture "@E 9,999,999"
	li++
	
Next

li += 1
@ li,000 psay Replicate("=",220)

QRY1->(DbCloseArea("QRY1"))

Set device to Screen

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se em disco, desvia para Spool                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If aReturn[5] == 1    // Se Saida para disco, ativa SPOOL
	Set Printer TO
	Commit
	ourspool(wnrel)
Endif

Return



/*====================================================================================\
| VALIDAÇÃO DOS PARÂMETROS SOLICITADOS AO USUÁRIO                                     |
\====================================================================================*/
Static Function AjustaSX1(cPerg)

_sAlias := Alias()

dbSelectArea("SX1")
dbSetOrder(1)

aRegs:={}

//------------ Grupo/Ordem/Pergunta/PERGING/PERGESP/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05/F3
AADD(aRegs,{cPerg,"01","Ano e Mês Final","","","mv_ch1","C",6,0,0,"G","","MV_PAR01","","","","","","","","","","","","","",""})
AADD(aRegs,{cPerg,"02","Fornecedor de  ","","","mv_ch2","C",6,0,0,"G","","MV_PAR02","","","","","","","","","","","","","","","","","","","","","","","","","SA2"})
AADD(aRegs,{cPerg,"03","Fornecedor até ","","","mv_ch3","C",6,0,0,"G","","MV_PAR03","","","","","","","","","","","","","","","","","","","","","","","","","SA2"})

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
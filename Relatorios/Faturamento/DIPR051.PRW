/*====================================================================================\
|Programa  | DIPR051       | Autor | Rafael de Campos Falco     | Data | 13/07/2003   |
|=====================================================================================|
|Descrição | Relatório de Faturamento por vendedor por SEGMENTO                       |
|=====================================================================================|
|Sintaxe   | DIPR051                                                                  |
|=====================================================================================|
|Uso       | Especifico DIPROMED                                                      |
|=====================================================================================|
|Histórico | DD/MM/AA - Descrição da alteração                                        |
\====================================================================================*/

#Include "RwMake.ch"
#INCLUDE "TBICONN.CH"
#INCLUDE "FILEIO.CH"
#INCLUDE "TOPCONN.CH"

#IFNDEF WINDOWS
	#DEFINE PSay Say
#ENDIF

User Function DIPR051()

Local _xArea 		:= GetArea() 
Local cUserAut      := GetMV("MV_URELFAT") // MCVN - 04/05/09      

Private tamanho	:= "M"
Private limite		:= 132
Private titulo		:= OemTOAnsi("Faturamento por SEGMENTO",72)
Private cDesc1		:= (OemToAnsi("Este programa tem como objetivo emitir um relat¢rio",72))
Private cDesc2		:= (OemToAnsi("de Faturamento por SEGMENTO.",72))
Private cDesc3		:= (OemToAnsi(" ",72))
Private aReturn	:= {"Bco A4", 1,"Faturamento", 1, 2, 1,"",1}
Private nomeprog	:= "DIPR051"

// Private cPerg		:= "DIPR51"
// FPADR(cPerg, cArq, cCampo, cTipo)  - Para ajustar o tamanho das perguntas no SX1- uso generico
PRIVATE cPerg  	:= U_FPADR( "DIPR51","SX1","SX1->X1_GRUPO"," " ) //Função criada por Sandro em 19/11/09.

Private nLastKey	:= 0
Private lEnd		:= .F.
Private li			:= 99
Private wnrel		:= "DIPR051"
Private M_PAG		:= 1
Private cString	:= "SF2"
Private _cRanking	:= ''
Private aEmiFat	:= {}
Private aDevFat   := {}
Private aSegTip   := {}
Private aNom_Est	:= {}
Private aRes_Fat	:= {}
Private aRes_Fim	:= {}
Private aTot_Est	:= {}
Private nHandle	:= ""
Private cEst_Ant  := ""
Private cWorkFlow	:= "N"
Private nTot_Fat := 0
Private nTot_Est := 0
Private nTot_Cus := 0
Private nTot_Cli := 0     
Private cSHWCUST := GetMV("MV_SHWCUST")// MCVN - 13/11/09   
Private cVendInt := GetMV("MV_DIPVINT")// MCVN - 06/05/09          
Private _cDipUsr := U_DipUsr()

U_DIPPROC(ProcName(0),_cDipUsr) // JBS 05/10/2005 - Gravando o nome do Programa no SZU

// MCVN - 04/05/09    
If !(Upper(_cDipUsr) $ cUserAut) .AND. !(Upper(_cDipUsr) $ cVendInt)
	Alert(Upper(_cDipUsr)+", você não tem autorização para utilizar esta rotina. Qualquer dúvida falar com Eriberto!","Atenção")	
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

Processa({|lEnd| RunProc()},"Totalizando por segmento...")

RptStatus({|lEnd| RptDetail()},"Imprimindo Faturamento por segmento...")

Set device to Screen
                                                                          

/*==========================================================================\
|Se em disco, desvia para Spool                                             |
\==========================================================================*/	
If aReturn[5] == 1    // Se Saida para disco, ativa SPOOL
	Set Printer TO
	Commit
	ourspool(wnrel)
Endif

DbCloseArea()

RestArea(_xArea)

Return

/*==========================================================================\
|Funcão RunProc()                                                           |
\==========================================================================*/	
Static Function RunProc()
Local nPos	   := 0
Local cSeg_Cod := ""
Local cNom_Est := ""
Local nFat_Val := 0
Local nCus_Val := 0
Local nTot_cDev:= 0
Local nTot_fDev:= 0

/*
*/

ProcRegua(500)
For _x := 1 to 200
	IncProc()
Next

//*********************** QUERY DO FATURAMENTO GERAL **************************************
QRY1 := "SELECT A1_SATIV1, SUM(D2_TOTAL+D2_VALFRE+D2_SEGURO+D2_DESPESA+D2_ICMSRET) D2_TOTAL, SUM(D2_QUANT*D2_CUSDIP) D2_CUSTO, F2_CLIENTE, A1_EST, F2_VEND1"
QRY1 += " FROM " +  RetSQLName('SF2') 
QRY1 += "," + RetSQLName('SD2') 
QRY1 += "," + RetSQLName('SF4') 
QRY1 += "," + RetSQLName('SA1')
QRY1 += "," + RetSQLName('SU7')
QRY1 += "," + RetSQLName('SC5')
QRY1 += " WHERE F2_EMISSAO BETWEEN '" + DTOS(MV_PAR01) + "' AND '" + DTOS(MV_PAR02) +"'"
QRY1 += " AND F2_TIPO = 'N'"
QRY1 += " AND F2_FILIAL = D2_FILIAL"
QRY1 += " AND F2_DOC = D2_DOC"
QRY1 += " AND F2_SERIE = D2_SERIE"
QRY1 += " AND F4_DUPLIC = 'S'"
QRY1 += " AND D2_TES = F4_CODIGO"
QRY1 += " AND F2_LOJA = A1_LOJA"
QRY1 += " AND F2_CLIENTE = A1_COD"
QRY1 += " AND A1_SATIV1 BETWEEN '" + MV_PAR04 + "' AND '" + MV_PAR05 +"'"
QRY1 += " AND D2_FILIAL = C5_FILIAL"
QRY1 += " AND D2_PEDIDO = C5_NUM"
QRY1 += " AND C5_OPERADO = U7_COD"

If !Empty(MV_PAR03) // VENDEDOR
	QRY1 += " AND F2_VEND1 = '"+MV_PAR03+"'"
Else
	If MV_PAR07 == 1 // APOIO
		QRY1 += " AND (U7_VEND = '2' OR U7_COD  = '000015')"
	ElseIf MV_PAR07 == 2 // CALL CENTER
		QRY1 += " AND U7_VEND = '1'"
		QRY1 += " AND U7_COD <> '000015'"
	EndIf
EndIf	

// Filtro listven  MCVN - 06/05/09
If U_ListVend() != ''
	QRY1 += " AND F2_VEND1 " + U_ListVend()+"  "
EndIf

QRY1 += " AND " + RetSQLName('SF2') + ".D_E_L_E_T_ = ''"
QRY1 += " AND " + RetSQLName('SD2') + ".D_E_L_E_T_ = ''"
QRY1 += " AND " + RetSQLName('SF4') + ".D_E_L_E_T_ = ''"
QRY1 += " AND " + RetSQLName('SA1') + ".D_E_L_E_T_ = ''"
QRY1 += " AND " + RetSQLName('SU7') + ".D_E_L_E_T_ = ''"
QRY1 += " AND " + RetSQLName('SC5') + ".D_E_L_E_T_ = ''"
QRY1 += " GROUP BY A1_SATIV1, F2_CLIENTE, A1_EST, F2_VEND1"
If MV_PAR06 = 2
	QRY1 += " ORDER BY A1_SATIV1, F2_CLIENTE"
Else
	QRY1 += " ORDER BY A1_EST, A1_SATIV1, F2_CLIENTE"
EndIf
QRY1 := ChangeQuery(QRY1)
dbUseArea(.T., "TOPCONN", TCGenQry(,,QRY1), 'QRY1', .F., .T.)
memowrite('DIPR51D2.SQL',QRY1)

ProcRegua(1000)
For _x := 1 to 400
	IncProc()
Next

QRY2 := "SELECT A1_SATIV1, SUM(D1_TOTAL) D1_TOTAL, SUM(D1_QUANT*D2_CUSDIP) D1_CUSTO,  F2_CLIENTE, A1_EST, F2_VEND1"
QRY2 += " FROM " +  RetSQLName('SD1') 
QRY2 +=  ',' + RetSQLName('SD2') 
QRY2 +=  ',' + RetSQLName('SF4') 
QRY2 +=  ',' + RetSQLName('SF2') 
QRY2 +=  ',' + RetSQLName('SA1')
QRY2 +=  ',' + RetSQLName('SU7')
QRY2 +=  ',' + RetSQLName('SC5')
QRY2 += " WHERE D1_DTDIGIT BETWEEN '" + DTOS(MV_PAR01) + "' AND '" + DTOS(MV_PAR02) +"'"
QRY2 += " AND D1_TIPO = 'D'"
QRY2 += " AND D1_FILIAL = D2_FILIAL"
QRY2 += " AND D1_NFORI = D2_DOC"
QRY2 += " AND D1_SERIORI = D2_SERIE"
QRY2 += " AND D1_ITEMORI = D2_ITEM"
QRY2 += " AND D1_TES = F4_CODIGO"
QRY2 += " AND F4_DUPLIC = 'S'"
QRY2 += " AND D2_FILIAL = F2_FILIAL"
QRY2 += " AND D2_DOC = F2_DOC"
QRY2 += " AND D2_SERIE = F2_SERIE"
QRY2 += " AND F2_LOJA = A1_LOJA"
QRY2 += " AND F2_CLIENTE = A1_COD"
QRY2 += " AND A1_SATIV1 BETWEEN '" + MV_PAR04 + "' AND '" + MV_PAR05 +"'"
QRY2 += " AND D2_FILIAL = C5_FILIAL"
QRY2 += " AND D2_PEDIDO = C5_NUM"
QRY2 += " AND C5_OPERADO = U7_COD"
If !Empty(MV_PAR03) // VENDEDOR
	QRY2 += " AND F2_VEND1 = '"+MV_PAR03+"'"
Else
	If MV_PAR07 == 1 // APOIO
		QRY2 += " AND (U7_VEND = '2' OR U7_COD  = '000015')"
	ElseIf MV_PAR07 == 2 // CALL CENTER
		QRY2 += " AND U7_VEND = '1'"
		QRY2 += " AND U7_COD <> '000015'"
	EndIf
EndIf	
QRY2 += " AND " + RetSQLName('SD1') + ".D_E_L_E_T_ = ''"
QRY2 += " AND " + RetSQLName('SD2') + ".D_E_L_E_T_ = ''"
QRY2 += " AND " + RetSQLName('SF4') + ".D_E_L_E_T_ = ''"
QRY2 += " AND " + RetSQLName('SF2') + ".D_E_L_E_T_ = ''"
QRY2 += " AND " + RetSQLName('SA1') + ".D_E_L_E_T_ = ''"
QRY2 += " AND " + RetSQLName('SU7') + ".D_E_L_E_T_ = ''"
QRY2 += " AND " + RetSQLName('SC5') + ".D_E_L_E_T_ = ''"
QRY2 += " GROUP BY A1_SATIV1, F2_CLIENTE, A1_EST, F2_VEND1"
QRY2 += " ORDER BY A1_SATIV1"

QRY2 := ChangeQuery(QRY2)
dbUseArea(.T., "TOPCONN", TCGenQry(,,QRY2), 'QRY2', .F., .T.)

memowrite('DIPR51D1.SQL',QRY2)

For _x := 1 to 500
	IncProc()
Next

dbSelectArea("QRY2")
QRY2->(dbGotop())

ProcRegua(500)

// Montando array de devoluções 
Do While QRY2->(!Eof())
	IncProc( "Processando... Devoluções " + QRY2->A1_SATIV1 + "...")
	Aadd(aDevFat,{QRY2->A1_SATIV1, QRY2->D1_TOTAL, QRY2->D1_CUSTO, QRY2->F2_CLIENTE, Iif(MV_PAR06 == 1, AllTrim(QRY2->A1_EST), "XX")})
	QRY2->(DbSkip())	
EndDo

dbSelectArea("QRY1")
QRY1->(dbGotop())
cSeg_Cod := AllTrim(QRY1->A1_SATIV1)
nSom_Cli := 0

ProcRegua(1000)
Do While QRY1->(!Eof())
	IncProc( "Processando... Faturamento Segmento " + QRY1->A1_SATIV1)

	Do While cSeg_Cod == AllTrim(QRY1->A1_SATIV1)
		cNom_Est := Iif(MV_PAR06 == 1, AllTrim(QRY1->A1_EST), "XX")
		nTot_Fat += QRY1->D2_TOTAL
		nTot_Cus += QRY1->D2_CUSTO
		nTot_Cli++
		
		nFat_Val += QRY1->D2_TOTAL
		nCus_Val += QRY1->D2_CUSTO
		nSom_Cli++
		 
		QRY1->(DbSkip())
	EndDo
	Aadd(aEmiFat,{cSeg_Cod, nFat_Val, nCus_Val, nSom_Cli, cNom_Est}) // JBS 16/01/2006
	If !Eof()
		cSeg_Cod := AllTrim(QRY1->A1_SATIV1)
		nFat_Val := 0
		nCus_Val := 0
		nSom_Cli := 0
	EndIf
EndDo	

If MV_PAR06 == 1
	QRY1->(DbGoTop())
	cAnt_Est := AllTrim(QRY1->A1_EST)
	Do While QRY1->(!Eof())
		IncProc( "Processando... Faturamento Segmento por Estado" + QRY1->A1_EST)
		Do While cAnt_Est == AllTrim(QRY1->A1_EST)
			nTot_Est += QRY1->D2_TOTAL
			QRY1->(DbSkip())
		EndDo
		Aadd(aTot_Est,{cAnt_Est, nTot_Est})
		cAnt_Est := AllTrim(QRY1->A1_EST)
		nTot_Est := 0
	EndDo
EndIf		


ProcRegua(30)
// ABATENDO AS DEVOLUÇÕES DO FATURAMENTO
For xi:=1 to Len(aDevFat)
	IncProc( "Processando... Abatendo Devoluções " + aDevFat[xi,1])
	nPos := Ascan(aEmiFat,{|x| x[1] == aDevFat[xi,1] .and. x[5] == aDevFat[xi,5]})
	If nPos != 0
		aEmiFat[nPos,2] := aEmiFat[nPos,2] - aDevFat[xi,2]
		aEmiFat[nPos,3] := aEmiFat[nPos,3] - aDevFat[xi,3]
	Else
		Aadd(aEmiFat,{aDevFat[xi,1], aDevFat[xi,2]*-1, aDevFat[xi,3]*-1,0,aDevFat[xi,5]})

//		nTot_FDev := nTot_FDev - aDevFat[xi,2]
//		nTot_CDev := nTot_CDev - aDevFat[xi,3]
	EndIf
	
	nTot_Fat := nTot_Fat - aDevFat[xi,2]
	nTot_Cus := nTot_Cus - aDevFat[xi,3]

Next	
// ADICIONA DEVOLUÇÕES NÃO ENCONTRADAS
//If nTot_fDev != 0
//	Aadd(aEmiFat,{"DEVOLUÇÃO", nTot_fDev, nTot_cDev,0,"AL" })
//EndIf

// Cria array com tipos de SEGMENTO
Aadd(aSegTip,{"Hospitais","Privados","Públicos",""})
Aadd(aSegTip,{"Distribuidores","","",""})
Aadd(aSegTip,{"Clínicas e Consultórios","","",""})
Aadd(aSegTip,{"Laboratórios","","",""})
Aadd(aSegTip,{"Empresas","Industrias","Serviços",""})
Aadd(aSegTip,{"Consumidor Final","","",""})
Aadd(aSegTip,{"Outros","","",""})

Return

/*==========================================================================\
|Funcão RptDetail()                                                         |
\==========================================================================*/	
Static Function RptDetail()
Local _cTitulo	:= "Vendas por SEGMENTO período:" + DToC(mv_par01) + ' até ' + DToC(mv_par02) 
Local _cDesc2	:= "Segmento                                           Faturamento                             Participação(%)  Clientes"
Local _cDesc1	:= ""
Local cSeg_Ant	:= ""
Local nTot_Rfat := 0
Local nTot_Rcus := 0
Local nTot_Rcli := 0
Local nEst_Fat := 0
Local nEst_Cus := 0
Local nEst_Cli := 0
Local aResAre := {}
Local aResFim := {}

// BLOQUEIA IMPRESSÃO DA COLUNA DE CUSTO
If Upper(_cDipUsr) $ cSHWCUST
	_cDesc2	:= "Segmento                                           Faturamento          Custo  Margem(%)   Participação(%)  Clientes"
EndIf

SetRegua(Len(aEmiFat))

If !Empty(mv_par03)
	_cDesc1	:= "Vendedor: " + MV_PAR03 +'-'+Posicione("SA3",1,xFilial("SA3")+MV_PAR03,"A3_NOME")
Else
	_cDesc1	:= "Todos vendedores"
EndIf

*                                                                                                    1                                                                                                   2                                                                                                   3
*          1         2         3         4         5         6         7         8         9         0         1         2         3         4         5         6         7         8         9         0         1         2         3         4         5         6         7         8         9         0         1         2         3         4         5         6
*01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
*---------------------------------------------------------------------------------------------------------------------------------------
*Vendedor: XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
*Segmento                                           Faturamento          Custo  Margem(%)   Participação(%)  Clientes
*---------------------------------------------------------------------------------------------------------------------------------------
*999999-XXXXXXXXXXXXXXXXXXXXXXXXXXXXX              9,999,999.99   9.999.999,99    999,99          999,99        9.999
*---------------------------------------------------------------------------------------------------------------------------------------
*                                           TotaL  9,999,999.99   9.999.999,99    999,99          999,99        9.999
*---------------------------------------------------------------------------------------------------------------------------------------

If MV_PAR06 == 1 // IMPRESSÃO POR ESTADOS
	aSort( aEmiFat ,,, {|a,b| a[5] + strzero(a[2],12) > b[5] + strzero(b[2],12)} )
	cEst_Ant := aEmiFat[1,5] // ARMAZENA O ESTADO ANTERIOR
Else
	aSort( aEmiFat ,,, {|a,b| a[2] > b[2]} )
	cEst_Ant := aEmiFat[1,5] // ARMAZENA O ESTADO ANTERIOR
EndIf

If Len(aEmiFat) > 0

	For zi:=1 to Len(aEmiFat) // LISTA TUDO QUE ESTIVER DENTRO DO ARRAY

		IncRegua( "Imprimindo: " + aEmiFat[zi,1] )	

		// QUEBRA DE PáGINA
		If li > 70
			u_Pag051(_cTitulo,_cDesc1,_cDesc2,nHandle,cWorkFlow)
			If MV_PAR06 == 1 // IMPRESSÃO POR ESTADOS
				cEst_Ant := aEmiFat[zi,5]
				@ li,000 PSay "TOTAIS REFERENTES AO ESTADO => " + AllTrim(Posicione("SX5",1,xFilial("SX5")+ "12" + aEmiFat[zi,5],"X5_DESCRI"))
				li++
				@ li,000 PSay Replic("-",Limite)
				li++
			EndIf	
		EndIf
		
		// POSICIONANDO ARRAY DE TOTAL DE FATURAMENTO POR ESTADO
		nLin := Ascan(aTot_Est,{|x| x[1] == aEmiFat[zi,5] })		
		
		// MONTAGEM DO ARRAY DE RESUMO DO NIVEL 2
		nPos := Ascan(aRes_Fat,{|x| x[7] == SubStr(aEmiFat[zi,1],1,3) })
		If nPos == 0
			Aadd(aRes_Fat,{AllTrim(Posicione("SX5",1,xFilial("SX5")+ "T3" + aEmiFat[zi,1],"X5_DESCRI")), aEmiFat[zi,2], aEmiFat[zi,3], (((aEmiFat[zi,2]/aEmiFat[zi,3])-1)*100), (aEmiFat[zi,2]/nTot_fat*100), aEmiFat[zi,4], SubStr(aEmiFat[zi,1],1,3) })
		Else
			aRes_Fat[nPos,2] := aRes_Fat[nPos,2] + aEmiFat[zi,2]
			aRes_Fat[nPos,3] := aRes_Fat[nPos,3] + aEmiFat[zi,3]
			aRes_Fat[nPos,4] := aRes_Fat[nPos,4] + (((aEmiFat[zi,2]/aEmiFat[zi,3])-1)*100)
			If MV_PAR06 == 2
				aRes_Fat[nPos,5] := aRes_Fat[nPos,5] + (aEmiFat[zi,2]/nTot_fat*100)
			Else
				//aRes_Fat[nPos,5] := aRes_Fat[nPos,5] + (aEmiFat[zi,2]/nTot_fat*100)
				aRes_Fat[nPos,5] := aRes_Fat[nPos,5] + (aEmiFat[zi,2]/aTot_Est[nLin,2]*100)
			EndIf
			aRes_Fat[nPos,6] := aRes_Fat[nPos,6] + aEmiFat[zi,4]
		EndIf
		
		// MONTAGEM DO ARRAY DE RESUMO DO NIVEL 1
		nPos := Ascan(aRes_Fim,{|x| x[7] == SubStr(aEmiFat[zi,1],1,1) })
		If nPos == 0
			Aadd(aRes_Fim,{AllTrim(Posicione("SX5",1,xFilial("SX5")+ "T3" + aEmiFat[zi,1],"X5_DESCRI")), aEmiFat[zi,2], aEmiFat[zi,3], (((aEmiFat[zi,2]/aEmiFat[zi,3])-1)*100), (aEmiFat[zi,2]/nTot_fat*100), aEmiFat[zi,4], SubStr(aEmiFat[zi,1],1,1)})
		Else
			aRes_Fim[nPos,2] := aRes_Fim[nPos,2] + aEmiFat[zi,2]
			aRes_Fim[nPos,3] := aRes_Fim[nPos,3] + aEmiFat[zi,3]
			aRes_Fim[nPos,4] := aRes_Fim[nPos,4] + (((aEmiFat[zi,2]/aEmiFat[zi,3])-1)*100)
			If MV_PAR06 == 2 
				aRes_Fim[nPos,5] := aRes_Fim[nPos,5] + (aEmiFat[zi,2]/nTot_fat*100)
			Else
				//aRes_Fim[nPos,5] := aRes_Fim[nPos,5] + (aEmiFat[zi,2]/nTot_fat*100)
				aRes_Fim[nPos,5] := aRes_Fim[nPos,5] + (aEmiFat[zi,2]/aTot_Est[nLin,2]*100)
			EndIf
			aRes_Fim[nPos,6] := aRes_Fim[nPos,6] + aEmiFat[zi,4]
		EndIf
		
		// VERIFICA SE É UMA DEVOLUÇÃO NÃO ENCONTRADA NO ARRAY DE FATURAMENTO
		If aEmiFat[zi,1] == "DEVOLUÇÃO"
			@ li,000 PSay aEmiFat[zi,1] + "-" + "00.00"
		Else
			// VERIFICA SE É UM REGISTRO SEM SEGMENTAÇÃO
			If Empty(aEmiFat[zi,1])
				@ li,000 PSay "...............Sem Segmento - 0.0.00"
			Else // IMPRIME REGISTRO COM SEGMENTAÇÃO E CODIGO
				@ li,000 PSay AllTrim(Posicione("SX5",1,xFilial("SX5")+ "T3" + aEmiFat[zi,1],"X5_DESCRI")) + "-" + aEmiFat[zi,1]
			EndIf
		EndIf

		// IMPRIME VALOR DO SEGMENTO LISTADO
		@ li,050 PSay aEmiFat[zi,2] Picture "@E 99,999,999.99"
	
		// BLOQUEIA IMPRESSÃO DA COLUNA DE CUSTO
		If Upper(_cDipUsr) $ cSHWCUST
			@ li,065 PSay aEmiFat[zi,3] Picture "@E 99,999,999.99"
			@ li,081 PSay (((aEmiFat[zi,2]/aEmiFat[zi,3])-1)*100) Picture "@E 9,999.99"
		EndIf

		If MV_PAR06 == 2
			@ li,097 PSay (aEmiFat[zi,2]/nTot_fat*100) Picture "@E 9,999.99"
		Else
			//@ li,097 PSay (aEmiFat[zi,2]/nTot_fat*100) Picture "@E 999.99"
			@ li,097 PSay (aEmiFat[zi,2]/aTot_Est[nLin,2]*100) Picture "@E 9,999.99"
		EndIF
		@ li,111 PSay aEmiFat[zi,4] Picture "@E 99,999"

		// ARMAZENA VALORES PARA TOTALIZAÇÃO
		nEst_Fat += aEmiFat[zi,2]
		nEst_Cus += aEmiFat[zi,3]
		nEst_Cli += aEmiFat[zi,4]
		li++
		
		// IMPRESSÃO DOS RESUMOS QDO. FOR ÚLTIMO REGISTRO DO ARRAY OU SE FOR ESTADO DIFERENTE AO ANTERIOR
		If Len(aEmiFat)== zi .or. AllTrim(cEst_Ant) != AllTrim(aEmiFat[zi+1,5]) // IMPRESSÃO POR ESTADOS

			If cEst_Ant == "MS"
				cEst_Ant := "MS"
			EndIf	
			// IMPRESSÃO DA PÁGINA DE RESUMO
			Imp_Res()

			// IMPRIME LINHA DE TOTAL PARCIAL
			@ li,000 PSay Replic("-",Limite)
			li++
			@ li,043 PSay "TotaL"
			@ li,050 PSay nEst_Fat Picture "@E 99,999,999.99"

			// BLOQUEIA IMPRESSÃO DA COLUNA DE CUSTO
			If Upper(_cDipUsr) $ cSHWCUST
				@ li,065 PSay nEst_Cus Picture "@E 99,999,999.99"
				@ li,081 PSay (((nEst_Fat/nEst_Cus)-1)*100) Picture "@E 9,999.99"
		   EndIf

			@ li,111 PSay nEst_Cli Picture "@E 99,999"
		   li++
			@ li,000 PSay Replic("*",Limite)
			nEst_Fat := 0
			nEst_Cus := 0
			nEst_Cli := 0
			If MV_PAR06 == 1
				li := 99
			EndIf	
			aRes_Fat	:= {}
			aRes_Fim	:= {}
		EndIf
	Next	
Else
	@ li,000 PSay Replic("-",Limite)
	li++
	@ li,000 PSay "Não foi localizado nenhum registro no período de " + SubStr(dtos(mv_par01),7,2) + '/' + SubStr(dtos(mv_par01),5,2) + '/' + SubStr(dtos(mv_par01),1,4) + " até " + SubStr(dtos(mv_par02),7,2) + '/' + SubStr(dtos(mv_par02),5,2) + '/' + SubStr(dtos(mv_par02),1,4)
	li++
	@ li,000 PSay Replic("-",Limite)
	li+=2
	@ li,000 PSAY 'Impresso em '+DtoC(DATE())+' as ' + TIME()

EndIf

QRY1->(dbCloseArea())
QRY2->(dbCloseArea())

Return(.T.)


/*==========================================================================\
|Programa  | Imp_Res | Autor | Rafael de Campos Falco  | Data | 06/10/2004  |
|===========================================================================|
|Desc.     | Impressão do bloco de resumo                                   |
|===========================================================================|
|Sintaxe   | Imp_Res                                                        |
|===========================================================================|
|Uso       | Especifico DIPROMED                                            |
|===========================================================================|
|Histórico | DD/MM/AA - Descrição da alteração                              |
\==========================================================================*/

Static Function Imp_Res()
Local nLin			:= 0
Local nCol			:= 0
Local _cTitulo		:= "Vendas por SEGMENTO período:" + DToC(mv_par01) + ' até ' + DToC(mv_par02) 
Local _cDesc2		:= "Segmento                                           Faturamento                             Participação(%)  Clientes"
Local _cDesc1		:= ""

	///////////////////////////////////// IMPRESSÃO DO BLOCO DE RESUMO ////////////////////////////////////////////
	If Empty(MV_PAR03)
	
		// BLOQUEIA IMPRESSÃO DA COLUNA DE CUSTO
		If Upper(_cDipUsr) $ cSHWCUST
			_cDesc2	:= "Segmento                                           Faturamento          Custo  Margem(%)   Participação(%)  Clientes"
		EndIf
		
		SetRegua(Len(aEmiFat))
		
		// POSICIONANDO ARRAY DE TOTAL DE FATURAMENTO POR ESTADO
		nPos := Ascan(aTot_Est,{|x| x[1] == aEmiFat[zi,5] })		
		
		If !Empty(mv_par03)
			_cDesc1	:= "Vendedor: " + MV_PAR03 +'-'+Posicione("SA3",1,xFilial("SA3")+MV_PAR03,"A3_NOME")
		Else
			_cDesc1	:= "Todos vendedores"
		EndIf
	
		If MV_PAR06 == 2
			li := 99
		EndIf	
		
		aSort(aRes_Fat ,,, {|a,b| a[2] > b[2]})

		@ li,000 PSay Replic("-",Limite)
		li++
		@ li,000 PSay "* Resumo Nível 2 *"  
		li++
		@ li,000 PSay Replic("-",Limite)
		li++
		If li > 70
			u_Pag051(_cTitulo,_cDesc1,_cDesc2,nHandle,cWorkFlow)
			If MV_PAR06 == 1 // IMPRESSÃO POR ESTADOS
				cEst_Ant := aEmiFat[zi,5]  // JBS 13/02/2006
				@ li,000 PSay "TOTAIS REFERENTES AO ESTADO => " + AllTrim(Posicione("SX5",1,xFilial("SX5")+ "12" + cEst_Ant ,"X5_DESCRI"))
				li++
				@ li,000 PSay Replic("-",Limite)
				li++
			EndIf	
		EndIf
		For xi:=1 to Len(aRes_Fat)
  		    nLin := Val(SubStr(aRes_Fat[xi,7],1,1))  // JBS 16/01/2006
			nCol := Val(SubStr(aRes_Fat[xi,7],At(".",aRes_Fat[xi,7])+1,At(".",aRes_Fat[xi,7])+1)) + 1 // JBS 16/01/2006
			If Empty(aRes_Fat[xi,7]) .or. nLin<1 .or. nCol<1 .or. nLin > Len(aSegTip)// JBS 16/01/2006
				@ li,000 PSay "...............Sem Segmento - 0.0.00"
			Else	
				@ li,000 PSay AllTrim(aSegTip[nLin,1]) + "-" + AllTrim(aSegTip[nLin,nCol]) + " - " + aRes_Fat[xi,7]
			EndIf
			@ li,050 PSay aRes_Fat[xi,2] Picture "@E 99,999,999.99"
			// BLOQUEIA IMPRESSÃO DA COLUNA DE CUSTO
			If Upper(_cDipUsr) $ cSHWCUST
				@ li,065 PSay aRes_Fat[xi,3] Picture "@E 99,999,999.99"
				@ li,081 PSay aRes_Fat[xi,4] Picture "@E 9,999.99"
			EndIf
	
			If MV_PAR06 == 2 
				@ li,097 PSay aRes_Fat[xi,5] Picture "@E 9,999.99"
			Else
				//@ li,097 PSay aRes_Fat[xi,5] Picture "@E 999.99"
				@ li,097 PSay (aRes_Fat[xi,2]/aTot_Est[nPos,2])*100 Picture "@E 9,999.99"
			EndIf
			
			@ li,111 PSay aRes_Fat[xi,6] Picture "@E 99,999"
			li++ 

			If li > 70
				u_Pag051(_cTitulo,_cDesc1,_cDesc2,nHandle,cWorkFlow)
				If MV_PAR06 == 1 // IMPRESSÃO POR ESTADOS
					cEst_Ant := aEmiFat[xi,5]
					@ li,000 PSay "TOTAIS REFERENTES AO ESTADO => " + AllTrim(Posicione("SX5",1,xFilial("SX5")+ "12" + cEst_Ant ,"X5_DESCRI"))
					li++
					@ li,000 PSay Replic("-",Limite)
					li++
				EndIf	
			EndIf			
		Next

		@ li,000 PSay Replic("-",Limite)
		li++
		@ li,000 PSay "* Resumo Nível 1 *"  
		li++
		@ li,000 PSay Replic("-",Limite)
		li++
		If li > 70
			u_Pag051(_cTitulo,_cDesc1,_cDesc2,nHandle,cWorkFlow)
			If MV_PAR06 == 1 // IMPRESSÃO POR ESTADOS
				cEst_Ant := aEmiFat[xi,5]
				@ li,000 PSay "TOTAIS REFERENTES AO ESTADO => " + AllTrim(Posicione("SX5",1,xFilial("SX5")+ "12" + cEst_Ant ,"X5_DESCRI"))
				li++
				@ li,000 PSay Replic("-",Limite)
				li++
			EndIf	
		EndIf
		For yi:=1 to Len(aRes_Fim)
			nLin := Val(aRes_Fim[yi,7]) // JBS 16/01/2006
			If Empty(aRes_Fim[yi,7]) .or. nLin<1 .or. nLin > Len(aSegTip) // JBS 16/01/2006
				@ li,000 PSay "...............Sem Segmento - 0.0.00"
			Else	
				@ li,000 PSay AllTrim(aSegTip[nLin,1]) + " - " + aRes_Fim[yi,7]
			EndIf	
			@ li,050 PSay aRes_Fim[yi,2] Picture "@E 99,999,999.99"
			// BLOQUEIA IMPRESSÃO DA COLUNA DE CUSTO
			If Upper(_cDipUsr) $ cSHWCUST
				@ li,065 PSay aRes_Fim[yi,3] Picture "@E 99,999,999.99"
				@ li,081 PSay aRes_Fim[yi,4] Picture "@E 9,999.99"
			EndIf
	
			If MV_PAR06 == 2 
				@ li,097 PSay aRes_Fim[yi,5] Picture "@E 9,999.99"
			Else
				//@ li,097 PSay aRes_Fim[yi,5] Picture "@E 999.99"
				@ li,097 PSay (aRes_Fim[yi,2]/aTot_Est[nPos,2])*100 Picture "@E 9,999.99"
			EndIf


			@ li,111 PSay aRes_Fim[yi,6] Picture "@E 99,999"
			li++ 

			If li > 70
				u_Pag051(_cTitulo,_cDesc1,_cDesc2,nHandle,cWorkFlow)
				If MV_PAR06 == 1 // IMPRESSÃO POR ESTADOS
					@ li,000 PSay "TOTAIS REFERENTES AO ESTADO => " + AllTrim(Posicione("SX5",1,xFilial("SX5")+ "12" + cEst_Ant ,"X5_DESCRI"))
					li++
					@ li,000 PSay Replic("-",Limite)
					li++
				EndIf	
			EndIf			
		Next
		@ li,000 PSay Replic("*",Limite)
	EndIf	
Return

/*==========================================================================\
|Programa  |VALIDPERG| Autor | Rafael de Campos Falco  | Data ³ 04/06/2004  |
|===========================================================================|
|Desc.     | Inclui as perguntas caso nao existam                           |
|===========================================================================|
|Sintaxe   | VALIDPERG                                                      |
|===========================================================================|
|Uso       | Especifico DIPROMED                                            |
|===========================================================================|
|Histórico | DD/MM/AAAA - Descrição da alteração                            |
|Histórico | 16/01/2006 - Solução de erros na impressao do array            |
\==========================================================================*/

Static Function AjustaSX1(cPerg)
_sAlias := Alias()
dbSelectArea("SX1")
dbSetOrder(1)

aRegs:={}

//------------ Grupo/Ordem/Pergunta/PERGING/PERGESP/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05/F3

AADD(aRegs,{cPerg,"01","Da Emissao         ?","","","mv_ch1","D", 8,0,0,"G","","mv_par01","","","","","","","","","","","","","",""})
AADD(aRegs,{cPerg,"02","Até a Emissao      ?","","","mv_ch2","D", 8,0,0,"G","","mv_par02","","","","","","","","","","","","","",""})
AADD(aRegs,{cPerg,"03","Vendedor           ?","","","mv_ch3","C", 6,0,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","",'SA3'})
AADD(aRegs,{cPerg,"04","Segmento de        ?","","","mv_ch4","C", 6,0,0,"G","","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","",'T3'})
AADD(aRegs,{cPerg,"05","Segmento até       ?","","","mv_ch5","C", 6,0,0,"G","","mv_par05","","","","","","","","","","","","","","","","","","","","","","","","",'T3'})
AADD(aRegs,{cPerg,"06","Imprimir por estado?","","","mv_ch6","N", 1,0,0,"C","","MV_PAR06","1-Sim","","","","","2-Não","","","","","","","","","","","","","","","","","","",''})
AADD(aRegs,{cPerg,"07","Informe o setor    ?","","","mv_ch7","N", 1,0,0,"C","","MV_PAR07","1-Apoio","","","","","2-Call Center","","","","","3-Ambos","","",""})

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

// Quebra de página
User Function Pag051(_cTitulo,_cDesc1,_cDesc2,nHandle,cWorkFlow)
	li := U_MYCABEC(_cTitulo,_cDesc1,_cDesc2,nHandle,cWorkFlow)
Return
/*====================================================================================\
|Programa  | DIPM016       | Autor | Jailton B Santos           | Data | 21/09/2005   |
|=====================================================================================|
|Descrição | Monta os dbfs para o Joel de logistica montar a planilha de estatisticas |
|          | de mala direta.                                                          |
|          | Monta os dbfs FatIXXX.dbf - Clientes inativos inativos reativados,       |
|          | FatLXXX.dbf - Ligações do Call center e FatNXXX.dbf novos clientes.      |
|=====================================================================================|
|Sintaxe   | DIPM016()                                                                |
|=====================================================================================|
|Uso       | Especifico DIPROMED                                                      |
|=====================================================================================|
+-------------------------------------------------------------------------------------+
|          |                                                                          |
\====================================================================================*/

#include "rwmake.ch"

User Function DipM016()
Local cPerg  := "DIPM16"
Local nMes   := 0
Local cMes   := ""
Local cAno   := ""

//Local cArqExcell:= GetSrvProfString("STARTPATH","")+"Excell-DBF\" // JBS 12/12/2005 

Local cArqExcell:= "\Excell-DBF\" // Alterado para gravar arquivos no protheus_data - Por Sandro em 19/11/09. 

Private aMes := {}
Private aEst_Trb := {}
Private aEst_Lig := {}
Private aFat_Novo:= {}
Private aFat_Inat:= {}
Private cDtFim := ""
Private cDtIni := ""
Private cFileWork
Private cDestino  := "C:\EXCELL-DBF\"

U_DIPPROC(ProcName(0),U_DipUsr()) // MCVN - 22/01/2009

AAdd(aEst_Lig,{"AREA"      ,"C",15,0})
AAdd(aEst_Lig,{"CODIGO"    ,"C",AvSx3("A1_COD",3)     ,AvSx3("A1_COD",4)})
AAdd(aEst_Lig,{"LOJA"      ,"C",AvSx3("A1_LOJA",3)    ,AvSx3("A1_LOJA",4)})
AAdd(aEst_Lig,{"CLIENTE"   ,"C",AvSx3("A1_NREDUZ",3)  ,AvSx3("A1_NREDUZ",4)})
AAdd(aEst_Lig,{"ULT_COMPR" ,"D",AvSx3("A1_ULTCOM",3)  ,AvSx3("A1_ULTCOM",4)})
AAdd(aEst_Lig,{"MIDIA"     ,"C",AvSx3("UA_MIDIA",3)   ,AvSx3("UA_MIDIA",4)})
AAdd(aEst_Lig,{"COD_OPERA" ,"C",AvSx3("UA_OPER",3)    ,AvSx3("UA_OPER",4)})
AAdd(aEst_Lig,{"OPERADOR"  ,"C",AvSx3("UA_OPERADO",3) ,AvSx3("UA_OPERADO",4)})
AAdd(aEst_Lig,{"NOME_OPER" ,"C",AvSx3("U7_NREDUZ",3)  ,AvSx3("U7_NREDUZ",4)})
AAdd(aEst_Lig,{"VENDEDOR"  ,"C",AvSx3("UA_VEND",3)    ,AvSx3("UA_VEND",4)})
AAdd(aEst_Lig,{"NOME_VEND" ,"C",AvSx3("A3_NREDUZ",3)  ,AvSx3("A3_NREDUZ",4)})

SX1->(AjustaSX1(cPerg)) // Verifica se existe o Pergunte, senão o cria.

DP16AreaArq() // Gera arquivo temporario

Do While .t.
	If Pergunte(cPerg,.T.) // Pergunta no SX1
		// Dados Informados pelo usuario
		cMes := mv_par01
		cAno := mv_par02
		aMes := {}
		aAdd(aMes,{"01","Jan_"})   
		aAdd(aMes,{"02","Fev_"})   
		aAdd(aMes,{"03","Mar_"})
		aAdd(aMes,{"04","Abr_"})
		aAdd(aMes,{"05","Mai_"})
		aAdd(aMes,{"06","Jun_"})
		aAdd(aMes,{"07","Jul_"})
		aAdd(aMes,{"08","Ago_"})
		aAdd(aMes,{"09","Set_"})   
		aAdd(aMes,{"10","Out_"})
		aAdd(aMes,{"11","Nov_"})
		aAdd(aMes,{"12","Dez_"})
		aEst_Trb := {}
		AAdd(aEst_Trb,{"AREA"   ,"C", 15,0})
		AAdd(aEst_Trb,{"CODIGO" ,"C" ,AvSx3("A1_COD",3)  ,AvSx3("A1_COD",4)})
		AAdd(aEst_Trb,{"LOJA"   ,"C" ,AvSx3("A1_LOJA",3) ,AvSx3("A1_LOJA",4)})
		AAdd(aEst_Trb,{"CLIENTE","C" ,AvSx3("A1_NOME",3) ,AvSx3("A1_NOME",4)})
		AAdd(aEst_Trb,{"MIDIA"  ,"C" ,AvSx3("UA_MIDIA",3),AvSx3("UA_MIDIA",4)})
		nMes := Val(cMes)
		nAno := Val(cAno)
		for i:=1 TO 12
			aMes[nMes,1] := StrZero(nAno,4)+aMes[nMes,1]
			aMes[nMes,2] += StrZero(nAno,4)
			nMes--
			If nMes<1
				nAno--
				nMes:=12
			EndIf
		Next i 
		aSort(aMes,,,{|x,y| x[1] < y[1] } )
        For i:= 1 to 12
			AAdd(aEst_Trb,{aMes[i,2],"N",AvSx3("F2_VALFAT",3),AvSx3("F2_VALFAT",4)})
			AAdd(aEst_Lig,{aMes[i,2],"C",10,0}) //,AvSx3("F2_VALFAT",3),AvSx3("F2_VALFAT",4)})
		Next i
		/* Ligações não vai mais precisar
		
		_cArqTrb0 := CriaTrab(aEst_Lig,.T.)
		_cChave0  := 'CODIGO+LOJA+Dtos(ULT_COMPR)'
		DbUseArea(.T.,,_cArqTrb0,"TRB_0",.F.,.F.)
		IndRegua("TRB_0",_cArqTrb0,_cChave0,,,"Criando Indice...")
		*/
		_cArqTrb1 := CriaTrab(aEst_Trb,.T.)
		_cChave1  := 'CODIGO+LOJA+MIDIA'
		DbUseArea(.T.,,_cArqTrb1,"TRB_1",.F.,.F.)
		IndRegua("TRB_1",_cArqTrb1,_cChave1,,,"Criando Indice...")
		_cArqTrb2 := CriaTrab(aEst_Trb,.T.)
		_cChave2  := 'CODIGO+LOJA+MIDIA'
		DbUseArea(.T.,,_cArqTrb2,"TRB_2",.F.,.F.)
		IndRegua("TRB_2",_cArqTrb2,_cChave2,,,"Criando Indice...")
		//------------------
		For i:= 1 to 12
			// Calculo do Periodo de clientes inativos
			cDtFim:=dTos(Ctod("01/"+cMes+"/"+cAno)-1) // Ultimo dia do Mes Anterior ao Informado pelo usuario
			nAno:=Val(cAno)
			nMes:=val(cMes)-4
			If nMes<1
				nAno--
				nMes:=12+(val(cMes)-4)
			EndIf
			cDtIni:=Dtos(Ctod("01/"+StrZero(nMes,2)+"/"+StrZero(nAno,4))) // Primeiro dia do 4o. mes anterior ao mes informado.
			// Selecionando Clientes
			
			/* Nao vai mais precisar 
			Processa({|lEnd| CriaArq1(cMes,cAno,cDtFim,cDtIni)},'Selecionando Ligações do Call Center de '+ Mes(cMes))
			*/
			Processa({|lEnd| CriaArq3(cMes,cAno,cDtFim,cDtIni)},'Selecionando clientes Inativos de '      + Mes(cMes))
			Processa({|lEnd| CriaArq2(cMes,cAno,cDtFim,cDtIni)},'Selecionando clientes Novos de '         + Mes(cMes))
			// Voltando o Mes
			cMes:=StrZero(Val(cMes)-1,2)
			// Voltando o ano
			If Val(cMes) < 1
				cAno:=StrZero(val(cAno)-1,4)
				cMes:="12"
			EndIf
		Next
		/* Não vai mais usar
		
		DbSelectArea("TRB_0")
		nFatLiga := 1
		Do While File("FATL" + StrZero(nFatLiga,3) + ".DBF")
			nFatLiga++
		EndDo
		cFileText := "FATL"+StrZero(nFatLiga,3)+".DBF"
		Copy to &cFileText
		DbCloseArea("TRB_1")
		*/
		
		DbSelectArea("TRB_1")
		TRB_1->(dbGotop())
		ProcRegua(TRB_1->(RECCOUNT()))	
		aCols := Array(TRB_1->(RECCOUNT()),Len(aEst_Trb))
		nColuna := 0
		nLinha := 0
		While TRB_1->(!Eof())
			nLinha++
			IncProc(OemToAnsi("Gerando planilha excel..."))
			For nColuna := 1 to Len(aEst_Trb)
				aCols[nLinha][nColuna] := &("TRB_1->("+aEst_Trb[nColuna][1]+")")			
			Next nColuna
			TRB_1->(dbSkip())	
		EndDo
		u_GDToExcel(aEst_Trb,aCols,Alltrim(FunName()))
		
		DbSelectArea("TRB_1")
		// CRIA ARQUIVO PARA ABRIR NO EXCEL
		nFatNovos := 1
		Do While File(cArqExcell+"FATN" + StrZero(nFatNovos,3) + ".DBF")
			nFatNovos++
		EndDo
		cFileText := cArqExcell+"FATN"+StrZero(nFatNovos,3)+".DBF"
		Copy to &cFileText VIA "DBFCDX"
		
		MakeDir(cDestino) // CRIA DIRETÓRIO CASO NÃO EXISTA
		CpyS2T(cArqExcell+".dbf",cDestino,.T.) // COPIA ARQUIVO PARA MAQUINA DO USUÁRIO
		
		DbSelectArea("TRB_2")
		TRB_2->(dbGotop())
		ProcRegua(TRB_2->(RECCOUNT()))	
		aCols := Array(TRB_2->(RECCOUNT()),Len(aEst_Trb))
		nColuna := 0
		nLinha := 0
		While TRB_2->(!Eof())
			nLinha++
			IncProc(OemToAnsi("Gerando planilha excel..."))
			For nColuna := 1 to Len(aEst_Trb)
				aCols[nLinha][nColuna] := &("TRB_2->("+aEst_Trb[nColuna][1]+")")			
			Next nColuna
			TRB_2->(dbSkip())	
		EndDo
		u_GDToExcel(aEst_Trb,aCols,Alltrim(FunName()))

		DbSelectArea("TRB_2")
		// CRIA ARQUIVO PARA ABRIR NO EXCEL
		nFatInati := 1
		Do While File(cArqExcell+"FATI"+StrZero(nFatInati,3)+".DBF")
			nFatInati++
		EndDo
		cFileText := cArqExcell+"FATI"+StrZero(nFatInati,3)+".DBF"
		Copy to &cFileText VIA "DBFCDX"

		TRB_1->(E_EraseArq(_cArqTrb1))
		TRB_2->(E_EraseArq(_cArqTrb2))
	Else
		Exit
	EndIf
EndDo
Work_Vd->(E_EraseArq(cFileWork))
Return

*------------------------------------------------*
Static Function CriaArq1(cMes,cAno,cDtFim,cDtIni)
*------------------------------------------------*
Local aLis_Cli := {}
Local aLis_Fat := {}
/*
-- Estatística de recebimento de ligações e total de clientes novos por mês (função criaarq1)
SELECT DISTINCT A1_COD, A1_LOJA, A1_NOME, UA_MIDIA
FROM SA1010, SUA010
WHERE SUBSTRING(UA_EMISSAO,1,6) = '200503'
AND A1_LOJA = UA_LOJA
AND A1_COD = UA_CLIENTE
AND SUA010.D_E_L_E_T_ = ''
AND SA1010.D_E_L_E_T_ = ''
ORDER BY UA_MIDIA, A1_COD, A1_LOJA, A1_NOME
*/
ProcRegua(500)
For x:=1 to 150
	IncProc( "Selecionando dados...(SA1)" )
Next

QRY1 := " SELECT DISTINCT  A1_COD, A1_LOJA, A1_NREDUZ, A1_ULTCOM, UA_MIDIA, UA_OPER, UA_OPERADO, UA_VEND, U7_NREDUZ, A3_NREDUZ, A3_COD"
QRY1 += " FROM "
QRY1 +=        RetSQLName('SA1')
QRY1 += ", " + RetSQLName('SA3')
QRY1 += ", " + RetSQLName('SU7')
QRY1 += ", " + RetSQLName('SUA')
QRY1 += " WHERE SUBSTRING(A1_ULTCOM,1,6) = '" + cAno+cMes + "'"
QRY1 += " AND A1_COD = UA_CLIENTE"
QRY1 += " AND A1_LOJA = UA_LOJA"
QRY1 += " AND A1_COD = UA_CLIENTE"
QRY1 += " AND UA_OPERADO = U7_COD"
QRY1 += " AND UA_VEND = A3_COD"
QRY1 += " AND " + RetSQLName('SUA') + ".D_E_L_E_T_ = ''"
QRY1 += " AND " + RetSQLName('SA1') + ".D_E_L_E_T_ = ''"
QRY1 += " ORDER BY A1_ULTCOM, A1_COD"

QRY1 := ChangeQuery(QRY1)
DbCommitAll()
dbUseArea(.T.,"TOPCONN",TcGenQry(,,QRY1),"QRY1",.F.,.T.)

/*
-- QUERY PARA SELECIONAR ÚLTIMOS FATURAMENTOS DOS CLIENTES
SELECT DISTINCT F2_CLIENTE, F2_LOJA, SUBSTRING(F2_EMISSAO,1,6) F2_EMISSAO
FROM SF2010
WHERE SUBSTRING(F2_EMISSAO,1,6) BETWEEN '200405' AND '200410'
AND F2_VALFAT > 0
AND SF2010.D_E_L_E_T_ = ''
ORDER BY F2_EMISSAO, F2_CLIENTE, F2_LOJA
*/

ProcRegua(500)
For x:=1 to 300
	IncProc( "Selecionando dados...(SF2)" )
Next
QRY2 := " SELECT DISTINCT F2_CLIENTE, F2_LOJA, SUBSTRING(F2_EMISSAO,1,6) F2_EMISSAO, F2_VALFAT"
QRY2 += " FROM " + RetSQLName('SF2')
QRY2 += " WHERE SUBSTRING(F2_EMISSAO,1,6) BETWEEN '" + SubStr(cDtIni,1,6) + "' AND '" + SubStr(cDtFim,1,6) + "' "
QRY2 += " AND F2_VALFAT > 0"
QRY2 += " AND " + RetSQLName("SF2") + ".D_E_L_E_T_ = ''"
QRY2 += " ORDER BY F2_CLIENTE, F2_LOJA"

QRY2 := ChangeQuery(QRY2)
DbCommitAll()
dbUseArea(.T.,"TOPCONN",TcGenQry(,,QRY2),"QRY2",.F.,.T.)

ProcRegua(500)
For _x := 1 to 500
	IncProc( "Tabelas Montadas...(QRY1 / QRY2 / TRB)" )
Next

ProcRegua(5000)
DbSelectArea("QRY1")
QRY1->(DbGoTop())
While QRY1->(!EOF())
	IncProc( "Selecionando dados do Cliente" )
	aadd(aLis_Cli,{QRY1->A1_COD, QRY1->A1_LOJA, QRY1->A1_NREDUZ, QRY1->A1_ULTCOM, QRY1->UA_MIDIA, QRY1->UA_OPER, QRY1->UA_OPERADO, QRY1->U7_NREDUZ, QRY1->UA_VEND, QRY1->A3_NREDUZ})
	QRY1->(DbSkip())
EndDo

ProcRegua(10000)
DbSelectArea("QRY2")
QRY2->(DbGoTop())
While QRY2->(!EOF())
	IncProc( "Selecionando faturas no periodo" )
	aadd(aLis_Fat,{QRY2->F2_CLIENTE, QRY2->F2_LOJA, QRY2->F2_EMISSAO, QRY2->F2_VALFAT})
	QRY2->(DbSkip())
EndDo

ProcRegua(Len(aLis_Cli))
cNom_Cpo := Mes(cMes)
For xi := 1 To Len(aLis_Cli)
	IncProc( "Cruzando dados dos clientes com Faturas" )
	nPos := aScan(aLis_Fat, { |x| x[1]+x[2] == aLis_Cli[xi,1]+aLis_Cli[xi,2]})
	If nPos == 0 // .and. !TRB_0->(dbSeek(aLis_Cli[xi,1]+aLis_Cli[xi,2]))
		TRB_0->(RecLock("TRB_0",.T.))
		TRB_0->CODIGO     := aLis_Cli[xi,01]
		TRB_0->LOJA       := aLis_Cli[xi,02]
		TRB_0->CLIENTE    := aLis_Cli[xi,03]
		TRB_0->ULT_COMPR  := cTod(SubStr(aLis_Cli[xi,04],7,2)+"/"+SubStr(aLis_Cli[xi,04],5,2)+"/"+SubStr(aLis_Cli[xi,04],1,4))
		TRB_0->MIDIA      := aLis_Cli[xi,05]
		TRB_0->COD_OPERA  := aLis_Cli[xi,06]
		TRB_0->OPERADOR   := aLis_Cli[xi,07]
		TRB_0->NOME_OPER  := aLis_Cli[xi,08]
		TRB_0->VENDEDOR   := aLis_Cli[xi,09]
		TRB_0->NOME_VEND  := aLis_Cli[xi,10]
		TRB_0->AREA       := DP16BuscArea(TRB_0->OPERADOR)
		TRB_0->&cNom_Cpo  := "Ligou"
		TRB_0->(MsUnLock())
	EndIf
Next

QRY1->(DbCloseArea("QRY1"))
QRY2->(DbCloseArea("QRY2"))

Return
*------------------------------------------------*
Static Function CriaArq2(cMes,cAno,cDtFim,cDtIni)
*------------------------------------------------*
Local aFat_Novo := {}

/*
-- QUERY PARA SELECIONAR VALOR FATURADO DO NOVOS CLIENTES QUE FATURARAM NO PERÍODO INFORMADO
SELECT A1_COD, A1_LOJA, A1_NOME, UA_MIDIA, SUBSTRING(F2_EMISSAO,1,6) F2_EMISSAO, SUM(F2_VALFAT) F2_VALFAT
FROM SA1010, SF2010, SUA010
WHERE SUBSTRING(F2_EMISSAO,1,6) BETWEEN '200411' AND '200502'
AND F2_VALFAT > 0
AND A1_COD = F2_CLIENTE
AND A1_LOJA = F2_LOJA
AND SUBSTRING(A1_PRICOM,1,6) BETWEEN '200411' AND '200502'
AND UA_DOC =* F2_DOC
AND SF2010.D_E_L_E_T_ = ''
AND SA1010.D_E_L_E_T_ = ''
AND SUA010.D_E_L_E_T_ = ''
GROUP BY A1_COD, A1_LOJA, A1_NOME, UA_MIDIA, SUBSTRING(F2_EMISSAO,1,6)
ORDER BY A1_NOME, SUBSTRING(F2_EMISSAO,1,6)
*/

ProcRegua(500)
For x:=1 to 300
	IncProc( "Selecionando dados...(SF2)" )
Next

QRY2 := " SELECT A1_COD, A1_LOJA, A1_NOME, SUBSTRING(F2_EMISSAO,1,6) F2_EMISSAO, SUM(F2_VALFAT) F2_VALFAT, UA_MIDIA, UA_OPERADO"
QRY2 += " FROM " + RetSQLName('SF2') + ", " + RetSQLName('SA1') + ", " + RetSQLName('SUA')
QRY2 += " WHERE SUBSTRING(F2_EMISSAO,1,6)= '" + cAno+cMes + "'"
QRY2 += " AND F2_VALFAT > 0"
QRY2 += " AND A1_COD = F2_CLIENTE"
QRY2 += " AND A1_LOJA = F2_LOJA"
QRY2 += " AND SUBSTRING(A1_PRICOM,1,6)= '" + cAno+cMes + "'"
QRY2 += " AND UA_DOC =* F2_DOC"
QRY2 += " AND " + RetSQLName('SF2') + ".D_E_L_E_T_ = ''"
QRY2 += " AND " + RetSQLName('SA1') + ".D_E_L_E_T_ = ''"
QRY2 += " AND " + RetSQLName('SUA') + ".D_E_L_E_T_ = ''"
QRY2 += " GROUP BY A1_COD, A1_LOJA, A1_NOME, SUBSTRING(F2_EMISSAO,1,6), UA_MIDIA, UA_OPERADO"
QRY2 += " ORDER BY SUBSTRING(F2_EMISSAO,1,6), A1_COD, A1_LOJA"

QRY2 := ChangeQuery(QRY2)
DbCommitAll()
dbUseArea(.T.,"TOPCONN",TcGenQry(,,QRY2),"QRY2",.F.,.T.)

ProcRegua(500)
DbSelectArea("QRY2")
nIncProc:= 500
QRY2->(DbGoTop())
Do While QRY2->(!EOF())
	IncProc( "Selecionando faturamento dos novos clientes" )
	nIncProc--
	If nIncProc<1
		nIncProc:= 500
		ProcRegua(nIncProc)
	EndIf
	aadd(aFat_Novo,{QRY2->A1_COD, QRY2->A1_LOJA, QRY2->A1_NOME, QRY2->F2_EMISSAO, QRY2->F2_VALFAT, IIF(Empty(QRY2->UA_MIDIA),"000000",QRY2->UA_MIDIA),QRY2->UA_OPERADO})
	QRY2->(DbSkip())
EndDo

ProcRegua(Len(aFat_Novo))
cNom_Cpo := Mes(cMes)
For xi := 1 To Len(aFat_Novo)
	
	IncProc( "Gravando informações dos novos clientes" )
	
	If TRB_1->(DbSeek(aFat_Novo[xi,1]+aFat_Novo[xi,2]+aFat_Novo[xi,6]))
		TRB_1->(RecLock("TRB_1",.F.))
		TRB_1->&cNom_Cpo := aFat_Novo[xi,5]
		TRB_1->(MsUnLock())
	Else
		TRB_1->(RecLock("TRB_1",.T.))
		TRB_1->CODIGO   := aFat_Novo[xi,1]
		TRB_1->LOJA	    := aFat_Novo[xi,2]
		TRB_1->CLIENTE  := aFat_Novo[xi,3]
		TRB_1->MIDIA    := aFat_Novo[xi,6]
		TRB_1->&cNom_Cpo:= aFat_Novo[xi,5]
		TRB_1->AREA     := DP16BuscArea(aFat_Novo[xi,7])
		TRB_1->(MsUnLock())
	EndIf
Next

QRY2->(DbCloseArea("QRY2"))

Return

*------------------------------------------------*
Static Function CriaArq3(cMes,cAno,cDtFim,cDtIni)
*------------------------------------------------*
Local aFatMes := {}
/*
--QUERY PARA SELECIONAR TODOS CLIENTES QUE FATURARAM NO PERÍODO INFORMADO
SELECT A1_COD, A1_LOJA, A1_NOME, UA_MIDIA, SUM(F2_VALFAT) F2_VALFAT
FROM SA1010, SF2010, SUA010
WHERE SUBSTRING(F2_EMISSAO,1,6) = '200411'
AND F2_TIPO <> 'D'
AND F2_TIPO <> 'B'
AND F2_VALFAT > 0
AND F2_CLIENTE = A1_COD
AND F2_LOJA = A1_LOJA
AND SUBSTRING(A1_PRICOM,1,6) NOT BETWEEN '200411' AND '200502'
AND UA_DOC =* F2_DOC
AND SUA010.D_E_L_E_T_ = ''
AND SF2010.D_E_L_E_T_ = ''
AND SA1010.D_E_L_E_T_ = ''
GROUP BY A1_COD, A1_LOJA, A1_NOME, UA_MIDIA
ORDER BY A1_NOME
*/

QRY1 := " SELECT A1_COD, A1_LOJA, A1_NOME, UA_MIDIA, SUM(F2_VALFAT) F2_VALFAT, UA_OPERADO"
QRY1 += " FROM "
QRY1 +=        RetSQLName('SA1')
QRY1 += ", " + RetSQLName('SF2')
QRY1 += ", " + RetSQLName('SUA')
QRY1 += " WHERE SUBSTRING(F2_EMISSAO,1,6) = '" + cAno+cMes + "'" //SubStr(cDtIni,1,6)
QRY1 += " AND F2_LOJA = A1_LOJA"
QRY1 += " AND F2_TIPO <> 'D'"
QRY1 += " AND F2_TIPO <> 'B'"
QRY1 += " AND F2_VALFAT > 0"
QRY1 += " AND F2_CLIENTE = A1_COD"

QRY1 += " AND F2_LOJA = A1_LOJA "
QRY1 += " AND SUBSTRING(A1_PRICOM,1,6)  NOT BETWEEN '" + SubStr(cDtIni,1,6) + "' AND '" + SubStr(cDtFim,1,6) + "'"
QRY1 += " AND UA_DOC =* F2_DOC"
QRY1 += " AND " + RetSQLName('SA1') + ".D_E_L_E_T_ = ''"
QRY1 += " AND " + RetSQLName('SF2') + ".D_E_L_E_T_ = ''"
QRY1 += " AND " + RetSQLName('SUA') + ".D_E_L_E_T_ = ''"
QRY1 += " GROUP BY A1_COD, A1_LOJA, A1_NOME, UA_MIDIA, UA_OPERADO"
QRY1 += " ORDER BY A1_NOME"

QRY1 := ChangeQuery(QRY1)
DbCommitAll()
dbUseArea(.T.,"TOPCONN",TcGenQry(,,QRY1),"QRY1",.F.,.T.)

ProcRegua(500)
nIncProc:= 500
DbSelectArea("QRY1")
QRY1->(DbGoTop())
aFat_novo := {}
Do While QRY1->(!EOF())
	IncProc( "Selecionando clientes no periodo" )
	nIncProc--
	If nIncProc<1
		nIncProc:= 500
		ProcRegua(nIncProc)
	EndIf
	aadd(aFat_Novo,{QRY1->A1_COD, QRY1->A1_LOJA, QRY1->A1_NOME, QRY1->F2_VALFAT, QRY1->UA_MIDIA,QRY1->UA_OPERADO})
	QRY1->(DbSkip())
EndDo

ProcRegua(500)
For x:=1 to 300
	IncProc( "Selecionando dados...(SF2)" )
Next
/*
-- QUERY PARA SELECIONAR FATURAMENTO ANTERIOR 4 MESES AO MÊS INFORMADO PARA DESCOBRIR QUAIS SÃO INATIVOS (função criaarq3)
SELECT DISTINCT F2_CLIENTE, F2_LOJA, SUBSTRING(F2_EMISSAO,1,6) F2_EMISSAO
FROM SF2010
WHERE SUBSTRING(F2_EMISSAO,1,6) BETWEEN '200407' AND '200410'
AND F2_VALFAT > 0
AND SF2010.D_E_L_E_T_ = ''
ORDER BY SUBSTRING(F2_EMISSAO,1,6), F2_CLIENTE, F2_LOJA
*/

QRY2 := " SELECT DISTINCT F2_CLIENTE, F2_LOJA, SUBSTRING(F2_EMISSAO,1,6) F2_EMISSAO"
QRY2 += " FROM " + RetSQLName('SF2')
QRY2 += " WHERE SUBSTRING(F2_EMISSAO,1,6) BETWEEN '" + SubStr(cDtIni,1,6) + "' AND '" + SubStr(cDtFim,1,6) + "'"
QRY2 += " AND F2_VALFAT > 0"
QRY2 += " AND " + RetSQLName('SF2') + ".D_E_L_E_T_ = ''"
QRY2 += " ORDER BY SUBSTRING(F2_EMISSAO,1,6), F2_CLIENTE, F2_LOJA"

QRY2 := ChangeQuery(QRY2)
DbCommitAll()
dbUseArea(.T.,"TOPCONN",TcGenQry(,,QRY2),"QRY2",.F.,.T.)

ProcRegua(7000)
DbSelectArea("QRY2")
QRY2->(DbGoTop())
While QRY2->(!EOF())
	IncProc( "Selecionando Faturas dos Clientes" )
	aadd(aFatMes,{QRY2->F2_CLIENTE, QRY2->F2_LOJA, QRY2->F2_EMISSAO})
	QRY2->(DbSkip())
EndDo

cNom_Cpo := Mes(cMes)

For xi := 1 To Len(aFat_Novo)
	IncProc( "Cruzando Faturas com dados dos clientes" )
	nPos := aScan(aFatMes,{|x| x[1]+x[2] == aFat_Novo[xi,1]+aFat_Novo[xi,2]})
	If nPos == 0
		TRB_2->(RecLock("TRB_2",.T.))
		TRB_2->CODIGO	:= AllTrim(aFat_Novo[xi,1])
		TRB_2->LOJA	    := AllTrim(aFat_Novo[xi,2])
		TRB_2->CLIENTE	:= AllTrim(aFat_Novo[xi,3])
		TRB_2->MIDIA	:= AllTrim(aFat_Novo[xi,5])
		TRB_2->AREA     := DP16BuscArea(aFat_Novo[xi,6])
		TRB_2->&cNom_Cpo:= aFat_Novo[xi,4]
		TRB_2->(MsUnLock())
	Else
		TRB_2->(DbSetOrder(1))
		If TRB_2->(DbSeek(AllTrim(aFat_Novo[xi,1])+AllTrim(aFat_Novo[xi,2])))
			TRB_2->(RecLock("TRB_2",.F.))
			TRB_2->&cNom_Cpo:= aFat_Novo[xi,4]
			TRB_2->(MsUnLock())
		EndIf
	EndIf
	nPos := 0
Next

QRY1->(DbCloseArea("QRY1"))
QRY2->(DbCloseArea("QRY2"))

Return
*--------------------------------------------------*
Static Function AjustaSX1(cPerg)
*--------------------------------------------------*
Local aRegs :={}
dbSetOrder(1)  

cPerg := PADR(cPerg, Len(SX1->X1_GRUPO)," " ) // Incluido por Sandro em 18/11/09.

aAdd(aRegs,{cPerg,"01","Mes ?  ","","","mv_ch1","C",02,0,0,"G","","mv_par01","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"02","Ano ?  ","","","mv_ch2","C",04,0,0,"G","","mv_par01","","","","","","","","","","","","","","",""})

For i:=1 to Len(aRegs)
	If !dbSeek(cPerg+aRegs[i,2])
		RecLock("SX1",.T.)
		For j:=1 to FCount()
			If j <= Len(aRegs[i])
				FieldPut(j,aRegs[i,j])
			Endif
		Next
		MsUnlock("SX1")
	Endif
Next
Return(.T.)  


*--------------------------------------------------*
Static Function Mes(cPos)
*--------------------------------------------------*
Local nPos := Ascan(aMes,{|x| SubStr(x[1],5,2) == cPos})
Return(aMes[nPos,2])
*--------------------------------------------------*
Static Function DP16AreaArq()
*--------------------------------------------------*
Local cAliasOld := alias()

//Local cTxt := upper(GetSrvProfString("STARTPATH","")+"INTEG\DIPAREA.TXT") // DIPAREA.TXT

// Alterado para gravar arquivos na pasta protheus_data - Por Sandro em 19/11/09. 
Local cTxt := "\INTEG\DIPAREA.TXT" // DIPAREA.TXT

Private aCposSF := {}
lInverte := .F.
cMarca   := GetMark()
aHeader  := {}
aCampos  := {} //Array(SF1->(FCount()))
cFileWork:= E_CriaTrab(,{;
{"WKVEND","C",06,0},;
{"WKAREA","C",15,0},;
{"WKNOME","C",20,0}},"Work_Vd",)
IndRegua("Work_Vd",cFileWork,"WKVEND")
If File(cTxt)
	dbSelectArea("Work_Vd")
	append from (cTxt) SDF
EndIf
dbSelectArea(cAliasOld)
Return(.T.)
*--------------------------------------------------*
Static Function DP16BuscArea(cVendedor)
*--------------------------------------------------*
Local cNomArea:=Space(15)
If Work_Vd->(dbSeek(cVendedor))
	cNomArea := Work_Vd->WKAREA
EndIf
Return cNomArea

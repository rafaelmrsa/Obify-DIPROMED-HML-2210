/*====================================================================================\
|Programa  | DIPG016      | Autor | Rafael de Campos Falco     | Data | 10/02/2005   |
|=====================================================================================|
|Descrição | Botão para as atendentes verem os 20 produtos mais vendidos do segmento  |
|          |                                                                          |
|          |                                                                          |
|=====================================================================================|
|Sintaxe   | DIPG016                                                                 |
|=====================================================================================|
|Uso       | Especifico DIPROMED                                                      |
|=====================================================================================|
|........................................Histórico....................................|
|Eriberto  | DD/MM/AA - Descrição                                                     |
+-------------------------------------------------------------------------------------+
|Rafael    | DD/MM/AA - Descrição                                                     |
+-------------------------------------------------------------------------------------+
|Rafael    | 21/02/05 - Modificar nome do campo Quantidade para Estoque disponível    |
|Rafael    | 21/02/05 - Adicionar mais uma coluna com o PREÇO C                       |
|Rafael    | 21/02/05 - Adicionar uma coluna para informar a quantidade               |
|Rafael    | 21/02/05 - Adicionar um check box para seleção do ítem desejado          |
|Eriberto  | 26/05/05 - Função para processar a noite e atualizar SZT                 |
|Eriberto  | 27/05/05 - Função para buscar dados da SZT                               |
+-------------------------------------------------------------------------------------+
\====================================================================================*/

#include "rwmake.ch"
#INCLUDE "TBICONN.CH"

User Function DIPG016(cOpc)
Local nHoraEntrada:=Seconds()

U_DIPPROC(ProcName(0),U_DipUsr()) // JBS 05/10/2005 - Gravando o nome do Programa no SZU

If cOpc == 0
	Processa({|| Top20() })  /// LISTA GERADA POR ARQUIVO DBF E QYERY 
ElseIf cOpc == 1
	Processa({|| Top20B() })  /// LISTA GERADA POR ARQUIVO DBF
ElseIf cOpc == 2
	Processa({|| Top20A() }) /// LISTA GERADA POR ARRAY
Else
	Processa({|| CheckEv() }) /// TESTE NÃO ESTÁ SENDO USADO
EndIf

M->UA_TOP20 := PadL( Int( Mod( (Seconds() - nHoraEntrada) / 3600, 24 ) ), 2, "0" ) + ":"  + ;
PadL( Int( Mod( (Seconds() - nHoraEntrada) / 60, 60 ) ), 2, "0" )   + ":"  + ;
PadL( Int( Mod( (Seconds() - nHoraEntrada), 60 ) ), 2, "0" )

Return


/*=====================================================================================\
| FUNÇÃO PARA APRESENTAR LISTA SEM CRIAR ARQUIVO                                       |
\=====================================================================================*/
Static Function Top20A()
/*=====================================================================================\
| Declaracao de Variaveis                                                              |
\=====================================================================================*/
Private cNome		:= Space(30)
Private lCheck		:= .F.
Private aTop_020	:= {}
Private aSegTip		:= {}
Private cLis_Pro	:= ""
Private dDat_Ini	:= DtoS(dDataBase-180)
Private dDat_Fim	:= DtoS(dDataBase)

ProcRegua(100)
For xi := 1 to 20
	IncProc("Gerando lista...")
Next

/*=====================================================================================\
| Criacao da Interface                                                                 |
\=====================================================================================*/
If Len(aCols) > 0
	For xi := 1 to Len(aCols)
		cLis_Pro += Iif(xi==1,"'",",'") + Iif(!aCols[n,Len(aHeader)+1],AllTrim(aCols[xi,1]),'') + "'"
	Next
EndIf

/*
-- PRODUTO POR SEGMENTO (CURVA ABC)
SELECT DISTINCT TOP 20 B1_COD, B1_DESC, A1_SATIV1, X5_DESCRI, B1_PRVMINI, B1_PRVSUPE, (B2_QATU-B2_RESERVA-B2_QACLASS) B2_QATU, SUM(D2_TOTAL) D2_TOTAL
FROM SD2010, SA1010, SB1010, SX5010, SB2010
WHERE B2_FILIAL = '04'
AND D2_EMISSAO BETWEEN '20040801' AND '20050223'
--AND B1_COD NOT IN ('')
AND A1_SATIV1 = '1.1.01'
AND D2_CLIENTE = A1_COD
AND D2_LOJA = A1_LOJA
AND D2_COD = B1_COD
AND D2_TIPO <> 'D'
AND B1_COD = B2_COD
AND B2_QATU-B2_RESERVA-B2_QACLASS > 0
AND B1_LOCPAD = B2_LOCAL
AND X5_TABELA = 'T3'
AND X5_CHAVE = '1.1.02'
AND SD2010.D_E_L_E_T_ = ''
AND SA1010.D_E_L_E_T_ = ''
AND SB1010.D_E_L_E_T_ = ''
AND SB2010.D_E_L_E_T_ = ''
AND SX5010.D_E_L_E_T_ = ''
GROUP BY B1_COD, B1_DESC, A1_SATIV1, X5_DESCRI, B1_PRVMINI, B1_PRVSUPE, B2_QATU-B2_RESERVA-B2_QACLASS
ORDER BY D2_TOTAL DESC
*/

QRY1 := " SELECT DISTINCT TOP 20 B1_COD, B1_DESC, A1_SATIV1, X5_DESCRI, B1_PRVMINI, B1_PRVSUPE, B2_QATU-B2_RESERVA-B2_QACLASS B2_QATU, SUM(D2_TOTAL) D2_TOTAL"
QRY1 += " FROM " + RetSQLName("SD2")+', '+RetSQLName("SA1")+', '+ RetSQLName("SB1")+', '+ RetSQLName("SX5")+', '+ RetSQLName("SB2")
QRY1 += " WHERE " + RetSQLName('SB2') + ".B2_FILIAL = '" + xFilial('SB2') + "'"
QRY1 += " AND D2_EMISSAO BETWEEN '" + dDat_Ini +"' AND '" + dDat_Fim + "'"
If Len(aCols) > 0
	QRY1 += " AND B1_COD NOT IN (" + cLis_Pro + ")"
EndIf
QRY1 += " AND A1_SATIV1 = '" + Posicione('SA1', 1, xFilial('SA1') + M->UA_CLIENTE + M->UA_LOJA, 'A1_SATIV1') + "'"
QRY1 += " AND D2_CLIENTE = A1_COD"
QRY1 += " AND D2_LOJA = A1_LOJA"
QRY1 += " AND D2_COD = B1_COD"
QRY1 += " AND D2_TIPO <> 'D'"
QRY1 += " AND B1_COD = B2_COD"
QRY1 += " AND B2_QATU-B2_RESERVA-B2_QACLASS > 0"
QRY1 += " AND B1_LOCPAD = B2_LOCAL"
QRY1 += " AND X5_TABELA = 'T3'"
QRY1 += " AND X5_CHAVE = '" + Posicione('SA1',1,xFilial('SA1')+M->UA_CLIENTE+M->UA_LOJA,'A1_SATIV1') +"'"
QRY1 += " AND " + RetSQLName("SD2") + ".D_E_L_E_T_ = ''"
QRY1 += " AND " + RetSQLName("SA1") + ".D_E_L_E_T_ = ''"
QRY1 += " AND " + RetSQLName("SB1") + ".D_E_L_E_T_ = ''"
QRY1 += " AND " + RetSQLName("SB2") + ".D_E_L_E_T_ = ''"
QRY1 += " AND " + RetSQLName("SX5") + ".D_E_L_E_T_ = ''"
QRY1 += " GROUP BY B1_COD, B1_DESC, A1_SATIV1, X5_DESCRI, B1_PRVMINI, B1_PRVSUPE, B2_QATU-B2_RESERVA-B2_QACLASS"
QRY1 += " ORDER BY D2_TOTAL DESC"

QRY1 := ChangeQuery(QRY1)

DbCommitAll()
dbUseArea(.T.,"TOPCONN",TcGenQry(,,QRY1),"QRY1",.F.,.T.)

ProcRegua(100)
For xi := 1 to 50
	IncProc("Gerando lista...")
Next

dbSelectArea("QRY1")
If QRY1->(!Eof()) .AND. !Empty(AllTrim(QRY1->A1_SATIV1))
	
	aadd(aTop_020,{AllTrim(QRY1->A1_SATIV1), AllTrim(QRY1->X5_DESCRI)})
	QRY1->(DbGoTop())
	
	
	/*=====================================================================================\
	| Cria array com tipos de SEGMENTO                                                     |
	\=====================================================================================*/
	Aadd(aSegTip,{"Hospitais","Privados","Públicos",""})
	Aadd(aSegTip,{"Distribuidores","","",""})
	Aadd(aSegTip,{"Clínicas e Consultórios","","",""})
	Aadd(aSegTip,{"Laboratórios","","",""})
	Aadd(aSegTip,{"Empresas","Industrias","Serviços",""})
	Aadd(aSegTip,{"Consumidor Final","","",""})
	Aadd(aSegTip,{"Outros","","",""})
	
	_aCpos := {}
	aadd(_aCpos,{"B1_COD", "Código","@!"})
	aadd(_aCpos,{"B1_DESC","Descrição","@!"})
	aadd(_aCpos,{"B2_QATU","Estoque Disp.","@E 999,999,999"})
	aadd(_aCpos,{"B1_PRVMINI","Preco C","@E 999,999,999.9999"})
	
	ProcRegua(100)
	For xi := 1 to 100
		IncProc("Gerando lista...")
	Next
	
	@ 0,0 To 450,900 Dialog oDlg1 Title OemToAnsi("Segmento: " + aTop_020[1,1] + ' - ' + aSegTip[Val(SubStr(aTop_020[1,1],1,1)),1] + ' - ' + aSegTip[Val(SubStr(aTop_020[1,1],1,1)),Val(SubStr(aTop_020[1,1],3,1))+1] + ' - ' + aTop_020[1,2])
	@ 001,001 TO 300,460 BROWSE "QRY1" FIELDS _aCpos Object oBro
	@ 200,200 BmpButton Type 1 Action Close(oDlg1)
	Activate Dialog oDlg1 Center
Else
	MsgInfo("Cliente não está segmentado !!!","Atenção!")
EndIf

QRY1->(DBCLOSEAREA("QRY1"))
Return


/*=====================================================================================\
| FUNÇÃO PARA APRESENTAR LISTA CRIANDO ARQUIVO                                         |
\=====================================================================================*/
Static Function Top20B()
/*=====================================================================================\
| Declaracao de Variaveis                                                              |
\=====================================================================================*/
Private cNome		:= Space(30)
Private lCheck		:= .F.
Private aTop_020	:= {}
Private aSegTip		:= {}
Private cLis_Pro	:= ""
Private dDat_Ini	:= DtoS(dDataBase-180)
Private dDat_Fim	:= DtoS(dDataBase)
Private oTempTable

DbSelectArea("SB1")
DbSelectArea("SB2")

ProcRegua(100)
For xi := 1 to 20
	IncProc("Gerando lista...")
Next
/*=====================================================================================\
| Criacao da Interface                                                                 |
\=====================================================================================*/
If Len(aCols) > 0
	For xi := 1 to Len(aCols)
		cLis_Pro += Iif(xi==1,"'",",'") + Iif(!aCols[n,Len(aHeader)+1],AllTrim(aCols[xi,1]),'') + "'"
	Next
EndIf

/*
-- PRODUTO POR SEGMENTO (CURVA ABC)
SELECT DISTINCT TOP 20 B1_COD, B1_DESC, A1_SATIV1, X5_DESCRI, B1_PRVMINI, B1_PRVSUPE, (B2_QATU-B2_RESERVA-B2_QACLASS) B2_QATU, SUM(D2_TOTAL) D2_TOTAL
FROM SD2010, SA1010, SB1010, SX5010, SB2010
WHERE B2_FILIAL = '04'
AND D2_EMISSAO BETWEEN '20040801' AND '20050223'
--AND B1_COD NOT IN ('')
AND A1_SATIV1 = '1.1.01'
AND D2_CLIENTE = A1_COD
AND D2_LOJA = A1_LOJA
AND D2_COD = B1_COD
AND D2_TIPO <> 'D'
AND B1_COD = B2_COD
AND B2_QATU-B2_RESERVA-B2_QACLASS > 0
AND B1_LOCPAD = B2_LOCAL
AND X5_TABELA = 'T3'
AND X5_CHAVE = '1.1.02'
AND SD2010.D_E_L_E_T_ = ''
AND SA1010.D_E_L_E_T_ = ''
AND SB1010.D_E_L_E_T_ = ''
AND SB2010.D_E_L_E_T_ = ''
AND SX5010.D_E_L_E_T_ = ''
GROUP BY B1_COD, B1_DESC, A1_SATIV1, X5_DESCRI, B1_PRVMINI, B1_PRVSUPE, B2_QATU-B2_RESERVA-B2_QACLASS
ORDER BY D2_TOTAL DESC
*/

QRY1 := " SELECT DISTINCT TOP 20 B1_COD, B1_DESC, A1_SATIV1, X5_DESCRI, B1_PRVMINI, B1_PRVSUPE, B2_QATU-B2_RESERVA-B2_QACLASS B2_QATU, SUM(D2_TOTAL) D2_TOTAL"
QRY1 += " FROM " + RetSQLName("SD2")+', '+RetSQLName("SA1")+', '+ RetSQLName("SB1")+', '+ RetSQLName("SX5")+', '+ RetSQLName("SB2")
QRY1 += " WHERE " + RetSQLName('SB2') + ".B2_FILIAL = '" + xFilial('SB2') + "'"
QRY1 += " AND D2_EMISSAO BETWEEN '" + dDat_Ini +"' AND '" + dDat_Fim + "'"
If Len(aCols) > 0
	QRY1 += " AND B1_COD NOT IN (" + cLis_Pro + ")"
EndIf
QRY1 += " AND A1_SATIV1 = '" + Posicione('SA1', 1, xFilial('SA1') + M->UA_CLIENTE + M->UA_LOJA, 'A1_SATIV1') + "'"
QRY1 += " AND D2_CLIENTE = A1_COD"
QRY1 += " AND D2_LOJA = A1_LOJA"
QRY1 += " AND D2_COD = B1_COD"
QRY1 += " AND D2_TIPO <> 'D'"
QRY1 += " AND B1_COD = B2_COD"
QRY1 += " AND B2_QATU-B2_RESERVA-B2_QACLASS > 0"
QRY1 += " AND B1_LOCPAD = B2_LOCAL"
QRY1 += " AND X5_TABELA = 'T3'"
QRY1 += " AND X5_CHAVE = '" + Posicione('SA1',1,xFilial('SA1')+M->UA_CLIENTE+M->UA_LOJA,'A1_SATIV1') +"'"
QRY1 += " AND " + RetSQLName("SD2") + ".D_E_L_E_T_ = ''"
QRY1 += " AND " + RetSQLName("SA1") + ".D_E_L_E_T_ = ''"
QRY1 += " AND " + RetSQLName("SB1") + ".D_E_L_E_T_ = ''"
QRY1 += " AND " + RetSQLName("SB2") + ".D_E_L_E_T_ = ''"
QRY1 += " AND " + RetSQLName("SX5") + ".D_E_L_E_T_ = ''"
QRY1 += " GROUP BY B1_COD, B1_DESC, A1_SATIV1, X5_DESCRI, B1_PRVMINI, B1_PRVSUPE, B2_QATU-B2_RESERVA-B2_QACLASS"
QRY1 += " ORDER BY D2_TOTAL DESC"

QRY1 := ChangeQuery(QRY1)

DbCommitAll()
dbUseArea(.T.,"TOPCONN",TcGenQry(,,QRY1),"QRY1",.F.,.T.)

dbSelectArea("QRY1")
ProcRegua(100)
For xi := 1 to 40
	IncProc("Gerando lista...")
Next

_aCampos := {}
_aTamSX3 := TamSX3("B1_COD")
AAdd(_aCampos ,{"B1_COD", "C",_aTamSX3[1],_aTamSX3[2]})
_aTamSX3 := TamSX3("B1_DESC")
AAdd(_aCampos ,{"B1_DESC","C",_aTamSX3[1],_aTamSX3[2]})
_aTamSX3 := TamSX3("B2_QATU")
AAdd(_aCampos ,{"B2_QATU","N",_aTamSX3[1],_aTamSX3[2]})
_aTamSX3 := TamSX3("B1_PRVMINI")
AAdd(_aCampos ,{"B1_PRVMINI","N",_aTamSX3[1],_aTamSX3[2]})
AAdd(_aCampos ,{"B1_PRVSUPE","N",_aTamSX3[1],_aTamSX3[2]})

/*
_cArqTrb1 := CriaTrab(_aCampos,.T.)
DbUseArea(.T.,,_cArqTrb1,"TOP1",.F.,.F.)
*/

If(oTempTable <> NIL)
	oTempTable:Delete()
	oTempTable := NIL
EndIf

oTempTable := FWTemporaryTable():New("TOP1")
oTempTable:SetFields( _aCampos )
//oTempTable:AddIndex("1", {"B1_COD"} )
oTempTable:Create()

//DbSelectArea("TOP1")
//TOP1->(DbSetOrder(1))


ProcRegua(100)
For xi := 1 to 60
	IncProc("Gerando lista...")
Next

If QRY1->(!Eof()) .AND. !Empty(AllTrim(QRY1->A1_SATIV1))
	aadd(aTOP_020,{AllTrim(QRY1->A1_SATIV1), AllTrim(QRY1->X5_DESCRI)})
	dbSelectArea("TOP1")
	For ni:=1 to 20
		RecLock("TOP1",.T.)
		TOP1->B1_COD	:= QRY1->B1_COD
		TOP1->B1_DESC	:= QRY1->B1_DESC
		TOP1->B2_QATU	:= QRY1->B2_QATU
		TOP1->B1_PRVMINI:= QRY1->B1_PRVMINI
		TOP1->B1_PRVSUPE:= QRY1->B1_PRVSUPE
		MsUnLock()
		QRY1->(Dbskip())
	Next
	TOP1->(dbGoTop())
	
	/*=====================================================================================\
	| Cria array com tipos de SEGMENTO                                                     |
	\=====================================================================================*/
	Aadd(aSegTip,{"Hospitais","Privados","Públicos",""})
	Aadd(aSegTip,{"Distribuidores","","",""})
	Aadd(aSegTip,{"Clínicas e Consultórios","","",""})
	Aadd(aSegTip,{"Laboratórios","","",""})
	Aadd(aSegTip,{"Empresas","Industrias","Serviços",""})
	Aadd(aSegTip,{"Consumidor Final","","",""})
	Aadd(aSegTip,{"Outros","","",""})
	
	_aCpos := {}
	aadd(_aCpos,{"B1_COD", "Código",        "@!"})
	aadd(_aCpos,{"B1_DESC","Descrição",     "@!"})
	aadd(_aCpos,{"B2_QATU","Estoque Disp.", "@E 999,999,999"})
	aadd(_aCpos,{"B1_PRVMINI","Preco C",    "@E 999,999,999.9999"})
	aadd(_aCpos,{"B1_PRVSUPE","Promoção",   "@E 999,999,999.9999"})
	
	ProcRegua(100)
	For xi := 1 to 100
		IncProc("Gerando lista...")
	Next
	
	@ 0,0 To 450,900 Dialog oDlg1 Title OemToAnsi("Segmento: " + aTOP_020[1,1] + ' - ' + aSegTip[Val(SubStr(aTOP_020[1,1],1,1)),1] + ' - ' + aSegTip[Val(SubStr(aTOP_020[1,1],1,1)),Val(SubStr(aTOP_020[1,1],3,1))+1] + ' - ' + aTOP_020[1,2])
	@ 001,001 TO 300,460 BROWSE "TOP1" FIELDS _aCpos Object oBro
	@ 200,200 BmpButton Type 1 Action Close(oDlg1)
	Activate Dialog oDlg1 Center
Else
	MsgInfo("Cliente não está segmentado !!!","Atenção!")
EndIf

QRY1->(DBCLOSEAREA("QRY1"))
//TOP1->(E_EraseArq(_cArqTrb1)) // JBS 12/12/2005
oTempTable:Delete()
FERASE("TOP020.DBF")
Return


/*=====================================================================================\
| FUNÇÃO PARA ATUALIZAR SZT                                                            |
\=====================================================================================*/
User Function ATUSZT()

// PREPARANDO PARA EXECUTAR PELO SCHEDULE
PREPARE ENVIRONMENT EMPRESA "01" FILIAL "04" FUNNAME "ATUSZT" TABLES "SZT"

// Limpando SZT
dbSelectArea("SZT")
SZT->(DbGotop())
While SZT->(!EOF())
	SZT->(RecLock("SZT",.F.))
		SZT->(DbDelete())
	SZT->(MsUnLock())
	SZT->(DbSkip())
EndDo

// Pegando X5 T3 Para buscar os 50 melhores no D2
QRY1 := " SELECT X5_CHAVE, X5_DESCRI"
QRY1 += " FROM " +RetSQLName("SX5")
QRY1 += " WHERE X5_TABELA = 'T3'"
QRY1 += " AND " + RetSQLName("SX5") + ".D_E_L_E_T_ = ''"
QRY1 += " ORDER BY X5_CHAVE"

QRY1 := ChangeQuery(QRY1)
DbCommitAll()
dbUseArea(.T.,"TOPCONN",TcGenQry(,,QRY1),"QRY1",.F.,.T.)

QRY1->(DbGotop())
While QRY1->(!Eof())
	
	If Len(AllTrim(QRY1->X5_CHAVE))<6
		QRY1->(DbSkip())
		Loop
	EndIf
		
	QRY2 := " SELECT DISTINCT TOP 50 X5_CHAVE, X5_DESCRI, D2_COD, SUM(D2_TOTAL) D2_TOTAL"
	QRY2 += " FROM " + RetSQLName("SD2")+', '+RetSQLName("SA1")+', '+RetSQLName("SX5")
	QRY2 += " WHERE D2_FILIAL IN('01','04') "
	QRY2 += " AND D2_EMISSAO BETWEEN '"+ DTOS(DATE()-180) +"' AND '"+ DTOS(DATE()) +"'"
	QRY2 += " AND D2_TIPO <> 'D' "
	QRY2 += " AND X5_FILIAL = D2_FILIAL "
	QRY2 += " AND X5_TABELA = 'T3'"
	QRY2 += " AND X5_CHAVE = '"+QRY1->X5_CHAVE+"'"
	QRY2 += " AND X5_CHAVE = A1_SATIV1"
	QRY2 += " AND A1_FILIAL = '"+xFilial("SA1")+"' "
	QRY2 += " AND A1_COD = D2_CLIENTE"
	QRY2 += " AND A1_LOJA = D2_LOJA"	
	QRY2 += " AND " + RetSQLName("SD2") + ".D_E_L_E_T_ = ''"
	QRY2 += " AND " + RetSQLName("SA1") + ".D_E_L_E_T_ = ''"
	QRY2 += " AND " + RetSQLName("SX5") + ".D_E_L_E_T_ = ''"
	QRY2 += " GROUP BY X5_CHAVE, X5_DESCRI, D2_COD"
	QRY2 += " ORDER BY D2_TOTAL DESC"
	
	QRY2 := ChangeQuery(QRY2)	
	DbCommitAll()
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,QRY2),"QRY2",.F.,.T.)
	             
	QRY2->(DbGotop())
	While QRY2->(!Eof())
		SZT->(RecLock("SZT",.T.))
			SZT->ZT_SEGCOD := QRY1->X5_CHAVE
			SZT->ZT_SEGNOM := QRY2->X5_DESCRI
			SZT->ZT_PRODUTO:= QRY2->D2_COD
			SZT->ZT_TOTAL  := QRY2->D2_TOTAL
			SZT->ZT_DATA   := DATE()
		SZT->(MsUnLock())
		QRY2->(DbSkip())
	EndDo
	QRY2->(dbCloseArea())
	
	QRY1->(DbSkip())
EndDo
QRY1->(dbCloseArea())

RESET ENVIRONMENT

Return
//////////////


/*=====================================================================================\
| FUNÇÃO PARA APRESENTAR LISTA CRIANDO ARQUIVO e usando SZT                            |
\=====================================================================================*/
Static Function Top20()
/*=====================================================================================\
| Declaracao de Variaveis                                                              |
\=====================================================================================*/
Private cNome		:= Space(30)
Private lCheck		:= .F.
Private aTop_020	:= {}
Private aSegTip		:= {}
Private cLis_Pro	:= ""
Private oTempTable

ProcRegua(100)
For xi := 1 to 20
	IncProc("Gerando lista...")
Next
/*=====================================================================================\
| Criacao da Interface                                                                 |
\=====================================================================================*/
If Len(aCols) > 0
	For xi := 1 to Len(aCols)
		cLis_Pro += Iif(xi==1,"'",",'") + Iif(!aCols[n,Len(aHeader)+1],AllTrim(aCols[xi,1]),'') + "'"
	Next
EndIf

/*
-- PRODUTO POR SEGMENTO (CURVA ABC)
SELECT DISTINCT TOP 20 ZT_SEGCOD, ZT_SEGNOM, ZT_PRODUTO, B1_DESC, B1_PRVMINI, B1_PRVSUPE, (B2_QATU-B2_RESERVA-B2_QACLASS) B2_QATU, ZT_TOTAL
FROM SZT010, SB1010, SB2010
WHERE ZT_SEGCOD = '1.1.01'
AND ZT_PRODUTO = B1_COD
AND ZT_PRODUTO = B2_COD
AND B2_QATU-B2_RESERVA-B2_QACLASS > 0
--AND B1_LOCPAD = B2_LOCAL
AND B2_FILIAL = '04'
AND SB1010.D_E_L_E_T_ = ''
AND SB2010.D_E_L_E_T_ = ''
AND SZT010.D_E_L_E_T_ = ''
ORDER BY ZT_TOTAL DESC
*/

QRY1 := "SELECT DISTINCT TOP 20 ZT_SEGCOD, ZT_SEGNOM, ZT_PRODUTO, B1_DESC, B1_PRVMINI, B1_PRVSUPE, (B2_QATU-B2_RESERVA-B2_QACLASS) B2_QATU, ZT_TOTAL"
QRY1 += " FROM " + RetSQLName("SZT")+', '+RetSQLName("SB1")+', '+ RetSQLName("SB2")
QRY1 += " WHERE " + RetSQLName('SB2') + ".B2_FILIAL = '" + xFilial("SB2") + "'"
If Len(aCols) > 0
	QRY1 += " AND ZT_PRODUTO NOT IN (" + cLis_Pro + ")"
EndIf
QRY1 += " AND ZT_SEGCOD = '" + Posicione('SA1', 1, xFilial('SA1') + M->UA_CLIENTE + M->UA_LOJA, 'A1_SATIV1') + "'"
QRY1 += " AND ZT_PRODUTO = B1_COD"
QRY1 += " AND ZT_PRODUTO = B2_COD"
QRY1 += " AND B2_QATU-B2_RESERVA-B2_QACLASS > 0"
QRY1 += " AND " + RetSQLName("SD2") + ".D_E_L_E_T_ = ''"
QRY1 += " AND " + RetSQLName("SA1") + ".D_E_L_E_T_ = ''"
QRY1 += " AND " + RetSQLName("SZT") + ".D_E_L_E_T_ = ''"
QRY1 += " ORDER BY ZT_TOTAL DESC"

QRY1 := ChangeQuery(QRY1)

DbCommitAll()
dbUseArea(.T.,"TOPCONN",TcGenQry(,,QRY1),"QRY1",.F.,.T.)

dbSelectArea("QRY1")
ProcRegua(100)
For xi := 1 to 40
	IncProc("Gerando lista...")
Next

_aCampos := {}
AAdd(_aCampos ,{"B1_COD", "C",6,0})
_aTamSX3 := TamSX3("B1_DESC")
AAdd(_aCampos ,{"B1_DESC","C",_aTamSX3[1],_aTamSX3[2]})
AAdd(_aCampos ,{"B2_QATU","N",9,0})
AAdd(_aCampos ,{"B1_PRVSUPE","N",10,4})
AAdd(_aCampos ,{"B1_PRVMINI","N",10,4})

/*
_cArqTrb := CriaTrab(_aCampos,.T.)
DbUseArea(.T.,,_cArqTrb,"TRB",.F.,.F.)
*/

If(oTempTable <> NIL)
	oTempTable:Delete()
	oTempTable := NIL
EndIf

oTempTable := FWTemporaryTable():New("TRB")
oTempTable:SetFields( _aCampos )
//oTempTable:AddIndex("1", {"B1_COD"} )
oTempTable:Create()

//DbSelectArea("TRB")
//TRB->(DbSetOrder(1))

ProcRegua(100)
For xi := 1 to 30
	IncProc("Gerando lista...")
Next

If !Empty(AllTrim(QRY1->ZT_SEGCOD))
	aadd(aTOP_020,{AllTrim(QRY1->ZT_SEGCOD), AllTrim(QRY1->ZT_SEGNOM)})
	Do While QRY1->(!Eof())
		dbSelectArea("TRB")
		RecLock("TRB",.T.)
		TRB->B1_COD  	:= QRY1->ZT_PRODUTO
		TRB->B1_DESC	:= QRY1->B1_DESC
		TRB->B2_QATU	:= QRY1->B2_QATU
		TRB->B1_PRVMINI:= QRY1->B1_PRVMINI
		TRB->B1_PRVSUPE:= QRY1->B1_PRVSUPE
		MsUnLock()
		QRY1->(Dbskip())
	EndDo
	TRB->(dbGoTop())
	
	/*=====================================================================================\
	| Cria array com tipos de SEGMENTO                                                     |
	\=====================================================================================*/
	Aadd(aSegTip,{"Hospitais","Privados","Publicos",""})
	Aadd(aSegTip,{"Distribuidores","","",""})
	Aadd(aSegTip,{"Clinicas e Consultorios","","",""})
	Aadd(aSegTip,{"Laboratorios","","",""})
	Aadd(aSegTip,{"Empresas","Industrias","Servicos",""})
	Aadd(aSegTip,{"Consumidor Final","","",""})
	Aadd(aSegTip,{"Outros","","",""})
	
	_aCpos := {}
	aadd(_aCpos,{"B2_QATU","Estoque Disp.", "@E 999,999,999"})
	aadd(_aCpos,{"B1_PRVSUPE","Promoção",   "@E 99,999.9999"})
	aadd(_aCpos,{"B1_PRVMINI","Preco C",    "@E 99,999.9999"})
	aadd(_aCpos,{"B1_DESC","Descrição",     "@!"})
	aadd(_aCpos,{"B1_COD", "Código",        "@!"})
	
	ProcRegua(100)
	For xi := 1 to 40
		IncProc("Gerando lista...")
	Next
	
	@ 0,0 To 450,900 Dialog oDlg1 Title OemToAnsi("Segmento: " + aTOP_020[1,1] + ' - ' + aSegTip[Val(SubStr(aTOP_020[1,1],1,1)),1] + ' - ' + aSegTip[Val(SubStr(aTOP_020[1,1],1,1)),Val(SubStr(aTOP_020[1,1],3,1))+1] + ' - ' + aTOP_020[1,2])
	@ 001,001 TO 300,460 BROWSE "TRB" FIELDS _aCpos Object oBro
	@ 200,200 BmpButton Type 1 Action Close(oDlg1)
	Activate Dialog oDlg1 Center
Else
	MsgInfo("Cliente não está segmentado !!!","Atenção!")
EndIf

QRY1->(DBCLOSEAREA("QRY1"))
//TRB->(E_EraseArq(_cArqTrb)) // JBS 12/12/2005
oTempTable:Delete()

Return
/////////////////////


/*====================================================================================\
|                                                                                     |
|                                                                                     |
|                       TESTE                                                         |
|                                                                                     |
+-------------------------------------------------------------------------------------+
\====================================================================================*/


Static Function CheckEv()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cNome := Space(30)
lCheck := .F.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Criacao da Interface                                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
@ 165,280 To 260,723 Dialog oDlg Title OemToAnsi("Exemplo CheckBox com Evento")

@ 17,9 CheckBox OemToAnsi("Ativa o Get") Var lCheck  OBJECT oCheck
@ 30,9 Say OemToAnsi("Digite Aqui") Size 32,8
@ 29,46 Get cNome Size 115,10  OBJECT oNome

oCheck:bChange:= {|| Marca() }
oNome:Disable()

@ 23,171 Button OemToAnsi("_Fechar") Size 36,15 Action close( oDlg)

Activate Dialog oDlg
Return


Static Function Marca()
aLERT("cLICOU!")
If lCheck
	oNome:Enable()   //oNome:Disable()
Else
	oNome:Disable()
Endif
oNome:Refresh()
oDlg:Refresh()
Return

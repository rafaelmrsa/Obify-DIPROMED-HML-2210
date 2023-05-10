/*====================================================================================\
|Programa  | DIPR081.PRW  | Autor  | Reginaldo Borges, RSB   | Data | 10/12/2014      |
|=====================================================================================|
|Descrição | Gera um relatorio do faturamento de todos os produtos que tenham         |
|          | o NCM desonerado cadastrado na ZZE e NCM onerado cadastrado na ZZH,      |
|          | como também a devolução.		  			                              |
|          |                                                                          |
|=====================================================================================|
|Uso       | Especifico HEALTH QUALITY  - Departamento Financeiro                     |
|=====================================================================================|
|Histórico | 																		  |
\====================================================================================*/
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#DEFINE ENTER CHR(13)+CHR(10)
*-------------------------------------*
User Function DIPR081()                
*-------------------------------------*

Local lQuery1
Local lQuery2
Private aReturn :={"Zebrado", 1,"Administracao", 1, 2, 1,"",1}
Private cDestino   := "C:\EXCELL-DBF\"
Private _cDipUsr   := U_DipUsr()
Private cSQL1
Private cSQL2
Private aReturn:={"Zebrado", 1,"Administracao", 1, 2, 1,"",1}
Private _cArqTrb   := ""
Private _aCampos   :={}
Private _aCampos2  :={}

PRIVATE cPerg  	:= U_FPADR( "DIPR081","SX1","SX1->X1_GRUPO"," " )

U_DIPPROC(ProcName(0),U_DipUsr()) //RSB 10/12/2014

AjustaSX1(cPerg)

If !Pergunte(cPerg,.T.)
	Return
EndIf


Processa({|| lQuery1 := U_FQuery1()},"Processando...",,.t.)
Processa({|| lQuery2 := U_FQuery2()},"Processando...",,.t.)

If !lQuery1
	MsgInfo(;
	"Não encontrado dados que satisfaçam aos"+ENTER+;
	"parametros informados pelo usuario, NCMs Desoneradas! ","Atenção")
	cSQL1->(dbCloseArea())
	Return(.t.)
ElseIf !lQuery2
	MsgInfo(;
	"Não encontrado dados que satisfaçam aos"+ENTER+;
	"parametros informados pelo usuario, NCMs Oneradas! ","Atenção")
	cSQL1->(dbCloseArea())
	Return(.t.)
EndIf

cSQL1->(dbCloseArea())
cSQL2->(dbCloseArea())
cSQL3->(dbCloseArea())
cSQL4->(dbCloseArea())
  TRB->(dbCloseArea())
 TRB2->(dbCloseArea())  

Return


/*BEGINDOC
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³fQuery1 retornara, por ordem de CFOP e NCM,    ³
//³o faturamento e devolucao apenas dos produtos  ³
//³que contenham o NCM da regra de Desoneração.   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ENDDOC*/
*----------------------------------*
USER FUNCTION FQuery1() 
Local _x
Local cArqExcell:= "\Excell-DBF\"+_cDipUsr+"-DIPR081-Desoneradas"+DTOS(MV_PAR01)+"-"+DTOS(MV_PAR02)+""

ProcRegua(15000)
For _x := 1 to 5000
	IncProc( "Preparando dados do faturamento... ")
Next


cSQL1 := " SELECT "
cSQL1 += " D2_CF CFOP, SB1.B1_POSIPI NCM, SUM(Case F4_DUPLIC  when 'S' then D2_TOTAL else 0 End )          TOTAL_FAT  ,"
cSQL1 += "                       		  SUM(D2_VALICM )                                                  T_ICMS  	  ,"
cSQL1 += "								  SUM(D2_VALIPI )                                                  T_IPI      ,"
cSQL1 += "								  SUM(D2_ICMSRET)                                         	       T_ICMSRET  ,"
cSQL1 += "								  SUM(D2_VALFRE )                                          	       T_FRETE    ,"
cSQL1 += "								  SUM(D2_DESPESA)                                         	       T_DESPESA  "
cSQL1 += "FROM "+ RetSQLName("SD2")
cSQL1 += "	INNER JOIN "+ RetSQLName("SF2") +" SF2 ON F2_FILIAL = '"+xFilial("SD2") +"'"
cSQL1 += "	AND        SF2.F2_TIPO IN ('N','C')       					"
cSQL1 += "	AND        SF2.F2_FILIAL  = D2_FILIAL	 					"
cSQL1 += "	AND        SF2.F2_DOC     = D2_DOC    						"
cSQL1 += "	AND        SF2.F2_SERIE   = D2_SERIE  						"
cSQL1 += "	AND        SF2.F2_EMISSAO BETWEEN '"+DTOS(MV_PAR01)+"' AND '"+DTOS(MV_PAR02)+"' "
cSQL1 += "	AND        SF2.D_E_L_E_T_ = ' ' 				            "
cSQL1 += "	INNER JOIN "+ RetSQLName("SC5") +" SC5 ON C5_FILIAL = '"+xFilial("SD2") +"'"
cSQL1 += "	AND        SC5.C5_NUM     = 	D2_PEDIDO                   "
cSQL1 += "	AND        SC5.D_E_L_E_T_ = ' '                             "
cSQL1 += "	INNER JOIN "+ RetSQLName("SF4") +" SF4 ON F4_CODIGO = D2_TES"
cSQL1 += "	AND        SF4.F4_DUPLIC  ='S'                              "
cSQL1 += "	AND        SF4.F4_FILIAL  = '"+xFilial("SD2") +"'           "
cSQL1 += "	AND        SF4.D_E_L_E_T_ = ' '                             "
cSQL1 += "	INNER JOIN "+ RetSQLName("SB1") +" SB1 ON B1_COD  =   D2_COD"
cSQL1 += "	AND        SB1.B1_FILIAL  = '"+xFilial("SD2") +"'           "
cSQL1 += "	AND        SB1.B1_POSIPI  IN (SELECT ZZE_POSIPI FROM "+RetSQLName("ZZE")+" )
cSQL1 += "	AND        SB1.D_E_L_E_T_ = ' '                             "

cSQL1 += "GROUP BY D2_CF, B1_POSIPI "
cSQL1 += "ORDER BY D2_CF, B1_POSIPI "


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

TcQuery cSQL1 NEW ALIAS "cSQL1"

TCSETFIELD("cSQL1","TOTAL_FAT ","N",10,2)
TCSETFIELD("cSQL1","T_ICMS    ","N",10,2)
TCSETFIELD("cSQL1","T_IPI     ","N",10,2)
TCSETFIELD("cSQL1","T_ICMSRET ","N",10,2)
TCSETFIELD("cSQL1","T_FRETE   ","N",10,2)
TCSETFIELD("cSQL1","T_DESPESA ","N",10,2)

ProcRegua(15000)
For _x := 1 to 5000
	IncProc( "Preparando dados da devolucao...")
Next

cSQL2 := " SELECT "
cSQL2 += " D1_CF CFOP, SB1.B1_POSIPI NCM, SUM(Case F4_DUPLIC  when 'S' then D1_TOTAL else 0 End )          TOTAL_DEV  ,"
cSQL2 += "                      		  SUM(D1_VALICM )                                                  T_ICMS  	  ,"
cSQL2 += "								  SUM(D1_VALIPI )                                                  T_IPI      ,"
cSQL2 += "								  SUM(D1_ICMSRET)                                         	       T_ICMSRET  ,"
cSQL2 += "								  SUM(D1_VALFRE )                                          	       T_FRETE    ,"
cSQL2 += "								  SUM(D1_DESPESA)                                         	       T_DESPESA   "
cSQL2 += "FROM "+ RetSQLName("SD1")
cSQL2 += "	INNER JOIN "+ RetSQLName("SF1") +" SF1 ON F1_FILIAL = '"+xFilial("SD1") +"'"
cSQL2 += "	AND        SF1.F1_TIPO    IN ('D')         					"
cSQL2 += "	AND        SF1.F1_FILIAL  = D1_FILIAL	 					"
cSQL2 += "	AND        SF1.F1_DOC     = D1_DOC    						"
cSQL2 += "	AND        SF1.F1_SERIE   = D1_SERIE  						"
cSQL2 += "	AND        SF1.F1_DTDIGIT BETWEEN '"+DTOS(MV_PAR01)+"' AND '"+DTOS(MV_PAR02)+"' "
cSQL2 += "	AND        SF1.D_E_L_E_T_ = ' ' 				            "
cSQL2 += "	INNER JOIN "+ RetSQLName("SF4") +" SF4 ON F4_CODIGO = D1_TES"
cSQL2 += "	AND        SF4.F4_DUPLIC  = 'S'                             "
cSQL2 += "	AND        SF4.F4_FILIAL  = '"+xFilial("SD1") +"'           "
cSQL2 += "	AND        SF4.D_E_L_E_T_ = ' '                             "
cSQL2 += "	INNER JOIN "+ RetSQLName("SB1") +" SB1 ON B1_COD  =   D1_COD"
cSQL2 += "	AND        SB1.B1_FILIAL  = '"+xFilial("SD1") +"'           "
cSQL2 += "	AND        SB1.B1_POSIPI  IN (SELECT ZZE_POSIPI FROM "+RetSQLName("ZZE")+" )
cSQL2 += "	AND        SB1.D_E_L_E_T_ = ' '                             "

cSQL2 += "GROUP BY D1_CF, B1_POSIPI "
cSQL2 += "ORDER BY D1_CF, B1_POSIPI "


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

TcQuery cSQL2 NEW ALIAS "cSQL2"

TCSETFIELD("cSQL2","TOTAL_DEV ","N",10,2)
TCSETFIELD("cSQL2","T_ICMS    ","N",10,2)
TCSETFIELD("cSQL2","T_IPI     ","N",10,2)
TCSETFIELD("cSQL2","T_ICMSRET ","N",10,2)
TCSETFIELD("cSQL2","T_FRETE   ","N",10,2)
TCSETFIELD("cSQL2","T_DESPESA ","N",10,2)


ProcRegua(15000)
For _x := 1 to 5000
	IncProc( "Classificando Faturamento/Devolucao... ")
Next

AAdd(_aCampos ,{"FATURADOS","C",15,0})
_aTamSX3 := TamSX3("D2_CF"  )
AAdd(_aCampos ,{"CFOP_FAT","C", _aTamSX3[1], _aTamSX3[2]})
_aTamSX3 := TamSX3("B1_POSIPI"  )
AAdd(_aCampos ,{"NCM_FAT","C", _aTamSX3[1], _aTamSX3[2]})
_aTamSX3 := TamSX3("D2_TOTAL"  )
AAdd(_aCampos ,{"PROD_FATUR","N", _aTamSX3[1], _aTamSX3[2]})
//_aTamSX3 := TamSX3("D2_VALICM" )
//AAdd(_aCampos ,{"ICMS_FAT","N", _aTamSX3[1], _aTamSX3[2]})
_aTamSX3 := TamSX3("D2_VALIPI" )
AAdd(_aCampos ,{"IPI_FAT ","N", _aTamSX3[1], _aTamSX3[2]})
_aTamSX3 := TamSX3("D2_ICMSRET")
AAdd(_aCampos ,{"ICMRET_FAT","N", _aTamSX3[1], _aTamSX3[2]})
_aTamSX3 := TamSX3("D2_VALFRE" )
AAdd(_aCampos ,{"FRETE_FAT","N", _aTamSX3[1], _aTamSX3[2]})
_aTamSX3 := TamSX3("D2_DESPESA")
AAdd(_aCampos ,{"DESPES_FAT","N", _aTamSX3[1], _aTamSX3[2]})
_aTamSX3 := TamSX3("D2_TOTAL"  )
AAdd(_aCampos ,{"TOTAL_FAT","N", _aTamSX3[1], _aTamSX3[2]})
AAdd(_aCampos ,{"DEVOLVIDOS","C",15,0})
_aTamSX3 := TamSX3("D2_CF"  )
AAdd(_aCampos ,{"CFOP_DEV","C", _aTamSX3[1], _aTamSX3[2]})
_aTamSX3 := TamSX3("B1_POSIPI"  )
AAdd(_aCampos ,{"NCM_DEV","C", _aTamSX3[1], _aTamSX3[2]})
_aTamSX3 := TamSX3("D2_TOTAL"  )
AAdd(_aCampos ,{"PROD_DEVOL","N", _aTamSX3[1], _aTamSX3[2]})
//_aTamSX3 := TamSX3("D2_VALICM" )
//AAdd(_aCampos ,{"ICMS_DEV","N", _aTamSX3[1], _aTamSX3[2]})
_aTamSX3 := TamSX3("D2_VALIPI" )
AAdd(_aCampos ,{"IPI_DEV ","N", _aTamSX3[1], _aTamSX3[2]})
_aTamSX3 := TamSX3("D2_ICMSRET")
AAdd(_aCampos ,{"ICMRET_DEV","N", _aTamSX3[1], _aTamSX3[2]})
_aTamSX3 := TamSX3("D2_VALFRE" )
AAdd(_aCampos ,{"FRETE_DEV","N", _aTamSX3[1], _aTamSX3[2]})
_aTamSX3 := TamSX3("D2_DESPESA")
AAdd(_aCampos ,{"DESPES_DEV","N", _aTamSX3[1], _aTamSX3[2]})
_aTamSX3 := TamSX3("D2_TOTAL"  )
AAdd(_aCampos ,{"TOTAL_DEV","N", _aTamSX3[1], _aTamSX3[2]})


_cArqTrb := CriaTrab(_aCampos,.T.)
DbUseArea(.T.,,_cArqTrb,"TRB",.F.,.F.)


ProcRegua(5000)

DbSelectArea("cSQL1")
DbSelectArea("cSQL2")
cSQL1->(dbGotop())
cSQL2->(dbGotop())
DbSelectArea("TRB")

While cSQL1->(!Eof()) .Or. cSQL2->(!Eof())
	
	IncProc("Faturamento/Devolução ..: ")
	
	RecLock("TRB",.T.)
	
	//FATURADOS
	TRB->CFOP_FAT   := cSQL1->CFOP
	TRB->NCM_FAT    := cSQL1->NCM
	TRB->PROD_FATUR := cSQL1->TOTAL_FAT
//	TRB->ICMS_FAT   := cSQL1->T_ICMS
	TRB->IPI_FAT    := cSQL1->T_IPI
	TRB->ICMRET_FAT := cSQL1->T_ICMSRET
	TRB->FRETE_FAT  := cSQL1->T_FRETE
	TRB->DESPES_FAT := cSQL1->T_DESPESA
	TRB->TOTAL_FAT  := cSQL1->(TOTAL_FAT+T_IPI+T_ICMSRET+T_FRETE+T_DESPESA)
	
	//DEVOLVIDOS
	TRB->CFOP_DEV   := cSQL2->CFOP
  	TRB->NCM_DEV    := cSQL2->NCM
	TRB->PROD_DEVOL := cSQL2->TOTAL_DEV
// 	TRB->ICMS_DEV   := cSQL2->T_ICMS
	TRB->IPI_DEV    := cSQL2->T_IPI
	TRB->ICMRET_DEV := cSQL2->T_ICMSRET
	TRB->FRETE_DEV  := cSQL2->T_FRETE
	TRB->DESPES_DEV := cSQL2->T_DESPESA
	TRB->TOTAL_DEV  := cSQL2->(TOTAL_DEV+T_IPI+T_ICMSRET+T_FRETE+T_DESPESA)
	
	
	MsUnLock()
	
	cSQL1->(dbSkip())
	cSQL2->(dbSkip())
	
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

// Gerando arquivo excel - RB 10/12/2014
COPY TO &cArqExcell VIA "DBFCDX"
MakeDir(cDestino) // CRIA DIRETÓRIO CASO NÃO EXISTA
CpyS2T(cArqExcell+".dbf",cDestino,.T.) // COPIA ARQUIVO PARA MAQUINA DO USUÁRIO

// Buscando e apagando arquivos temporários
aTmp := Directory( cDestino+"*.tmp" )
For nI:= 1 to Len(aTmp)
	fErase(cDestino+aTmp[nI,1])
Next nI

Return(!cSQL1->(BOF().and.!cSQL2->(BOF()).and.EOF()))

/*BEGINDOC
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³fQuery2 retornara, por ordem de CFOP e NCM,    ³
//³o faturamento e devolucao apenas dos produtos  ³
//³que contenham o NCM da regra de oneradas   .   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ENDDOC*/
*----------------------------------*
USER FUNCTION FQuery2() // NCM´s Oneradas
*----------------------------------*
Local _x
Local cArqExcell:= "\Excell-DBF\"+_cDipUsr+"-DIPR081-Oneradas"+DTOS(MV_PAR01)+"-"+DTOS(MV_PAR02)+""

ProcRegua(15000)
For _x := 1 to 5000
	IncProc( "Preparando dados do faturamento... ")
Next


cSQL3 := " SELECT "
cSQL3 += " D2_CF CFOP, SB1.B1_POSIPI NCM, SUM(Case F4_DUPLIC  when 'S' then D2_TOTAL else 0 End )          TOTAL_FAT  ,"
cSQL3 += "                       		  SUM(D2_VALICM )                                                  T_ICMS  	  ,"
cSQL3 += "								  SUM(D2_VALIPI )                                                  T_IPI      ,"
cSQL3 += "								  SUM(D2_ICMSRET)                                         	       T_ICMSRET  ,"
cSQL3 += "								  SUM(D2_VALFRE )                                          	       T_FRETE    ,"
cSQL3 += "								  SUM(D2_DESPESA)                                         	       T_DESPESA  "
cSQL3 += "FROM "+ RetSQLName("SD2")
cSQL3 += "	INNER JOIN "+ RetSQLName("SF2") +" SF2 ON F2_FILIAL = '"+xFilial("SD2") +"'"
cSQL3 += "	AND        SF2.F2_TIPO IN ('N','C')       					"
cSQL3 += "	AND        SF2.F2_FILIAL  = D2_FILIAL	 					"
cSQL3 += "	AND        SF2.F2_DOC     = D2_DOC    						"
cSQL3 += "	AND        SF2.F2_SERIE   = D2_SERIE  						"
cSQL3 += "	AND        SF2.F2_EMISSAO BETWEEN '"+DTOS(MV_PAR01)+"' AND '"+DTOS(MV_PAR02)+"' "
cSQL3 += "	AND        SF2.D_E_L_E_T_ = ' ' 				            "
cSQL3 += "	INNER JOIN "+ RetSQLName("SC5") +" SC5 ON C5_FILIAL = '"+xFilial("SD2") +"'"
cSQL3 += "	AND        SC5.C5_NUM     = 	D2_PEDIDO                   "
cSQL3 += "	AND        SC5.D_E_L_E_T_ = ' '                             "
cSQL3 += "	INNER JOIN "+ RetSQLName("SF4") +" SF4 ON F4_CODIGO = D2_TES"
cSQL3 += "	AND        SF4.F4_DUPLIC  ='S'                              "
cSQL3 += "	AND        SF4.F4_FILIAL  = '"+xFilial("SD2") +"'           "
cSQL3 += "	AND        SF4.D_E_L_E_T_ = ' '                             "
cSQL3 += "	INNER JOIN "+ RetSQLName("SB1") +" SB1 ON B1_COD  =   D2_COD"
cSQL3 += "	AND        SB1.B1_FILIAL  = '"+xFilial("SD2") +"'           "
cSQL3 += "	AND        SB1.B1_POSIPI  NOT IN (SELECT ZZE_POSIPI FROM "+RetSQLName("ZZE")+" )
cSQL3 += "	AND        SB1.D_E_L_E_T_ = ' '                             "

cSQL3 += "GROUP BY D2_CF, B1_POSIPI "
cSQL3 += "ORDER BY D2_CF, B1_POSIPI "


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

TcQuery cSQL3 NEW ALIAS "cSQL3"

TCSETFIELD("cSQL3","TOTAL_FAT ","N",10,2)
TCSETFIELD("cSQL3","T_ICMS    ","N",10,2)
TCSETFIELD("cSQL3","T_IPI     ","N",10,2)
TCSETFIELD("cSQL3","T_ICMSRET ","N",10,2)
TCSETFIELD("cSQL3","T_FRETE   ","N",10,2)
TCSETFIELD("cSQL3","T_DESPESA ","N",10,2)

ProcRegua(15000)
For _x := 1 to 5000
	IncProc( "Preparando dados da devolucao...")
Next

cSQL4 := " SELECT "
cSQL4 += " D1_CF CFOP, SB1.B1_POSIPI NCM, SUM(Case F4_DUPLIC  when 'S' then D1_TOTAL else 0 End )          TOTAL_DEV  ,"
cSQL4 += "                      		  SUM(D1_VALICM )                                                  T_ICMS  	  ,"
cSQL4 += "								  SUM(D1_VALIPI )                                                  T_IPI      ,"
cSQL4 += "								  SUM(D1_ICMSRET)                                         	       T_ICMSRET  ,"
cSQL4 += "								  SUM(D1_VALFRE )                                          	       T_FRETE    ,"
cSQL4 += "								  SUM(D1_DESPESA)                                         	       T_DESPESA   "
cSQL4 += "FROM "+ RetSQLName("SD1")
cSQL4 += "	INNER JOIN "+ RetSQLName("SF1") +" SF1 ON F1_FILIAL = '"+xFilial("SD1") +"'"
cSQL4 += "	AND        SF1.F1_TIPO    IN ('D')         					"
cSQL4 += "	AND        SF1.F1_FILIAL  = D1_FILIAL	 					"
cSQL4 += "	AND        SF1.F1_DOC     = D1_DOC    						"
cSQL4 += "	AND        SF1.F1_SERIE   = D1_SERIE  						"
cSQL4 += "	AND        SF1.F1_DTDIGIT BETWEEN '"+DTOS(MV_PAR01)+"' AND '"+DTOS(MV_PAR02)+"' "
cSQL4 += "	AND        SF1.D_E_L_E_T_ = ' ' 				            "
cSQL4 += "	INNER JOIN "+ RetSQLName("SF4") +" SF4 ON F4_CODIGO = D1_TES"
cSQL4 += "	AND        SF4.F4_DUPLIC  = 'S'                             "
cSQL4 += "	AND        SF4.F4_FILIAL  = '"+xFilial("SD1") +"'           "
cSQL4 += "	AND        SF4.D_E_L_E_T_ = ' '                             "
cSQL4 += "	INNER JOIN "+ RetSQLName("SB1") +" SB1 ON B1_COD  =   D1_COD"
cSQL4 += "	AND        SB1.B1_FILIAL  = '"+xFilial("SD1") +"'           "
cSQL4 += "	AND        SB1.B1_POSIPI  NOT IN (SELECT ZZE_POSIPI FROM "+RetSQLName("ZZE")+" )
cSQL4 += "	AND        SB1.D_E_L_E_T_ = ' '                             "

cSQL4 += "GROUP BY D1_CF, B1_POSIPI "
cSQL4 += "ORDER BY D1_CF, B1_POSIPI "


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

TcQuery cSQL4 NEW ALIAS "cSQL4"

TCSETFIELD("cSQL4","TOTAL_DEV ","N",10,2)
TCSETFIELD("cSQL4","T_ICMS    ","N",10,2)
TCSETFIELD("cSQL4","T_IPI     ","N",10,2)
TCSETFIELD("cSQL4","T_ICMSRET ","N",10,2)
TCSETFIELD("cSQL4","T_FRETE   ","N",10,2)
TCSETFIELD("cSQL4","T_DESPESA ","N",10,2)


ProcRegua(15000)
For _x := 1 to 5000
	IncProc( "Classificando Faturamento/Devolucao... ")
Next

AAdd(_aCampos2 ,{"FATURADOS","C",15,0})
_aTamSX3 := TamSX3("D2_CF"  )
AAdd(_aCampos2 ,{"CFOP_FAT","C", _aTamSX3[1], _aTamSX3[2]})
_aTamSX3 := TamSX3("B1_POSIPI"  )
AAdd(_aCampos2 ,{"NCM_FAT","C", _aTamSX3[1], _aTamSX3[2]})
_aTamSX3 := TamSX3("D2_TOTAL"  )
AAdd(_aCampos2 ,{"PROD_FATUR","N", _aTamSX3[1], _aTamSX3[2]})
//_aTamSX3 := TamSX3("D2_VALICM" )
//AAdd(_aCampos2 ,{"ICMS_FAT","N", _aTamSX3[1], _aTamSX3[2]})
_aTamSX3 := TamSX3("D2_VALIPI" )
AAdd(_aCampos2 ,{"IPI_FAT ","N", _aTamSX3[1], _aTamSX3[2]})
_aTamSX3 := TamSX3("D2_ICMSRET")
AAdd(_aCampos2 ,{"ICMRET_FAT","N", _aTamSX3[1], _aTamSX3[2]})
_aTamSX3 := TamSX3("D2_VALFRE" )
AAdd(_aCampos2 ,{"FRETE_FAT","N", _aTamSX3[1], _aTamSX3[2]})
_aTamSX3 := TamSX3("D2_DESPESA")
AAdd(_aCampos2 ,{"DESPES_FAT","N", _aTamSX3[1], _aTamSX3[2]})
_aTamSX3 := TamSX3("D2_TOTAL"  )
AAdd(_aCampos2 ,{"TOTAL_FAT","N", _aTamSX3[1], _aTamSX3[2]})
AAdd(_aCampos2 ,{"DEVOLVIDOS","C",15,0})
_aTamSX3 := TamSX3("D2_CF"  )
AAdd(_aCampos2 ,{"CFOP_DEV","C", _aTamSX3[1], _aTamSX3[2]})
_aTamSX3 := TamSX3("B1_POSIPI"  )
AAdd(_aCampos2 ,{"NCM_DEV","C", _aTamSX3[1], _aTamSX3[2]})
_aTamSX3 := TamSX3("D2_TOTAL"  )
AAdd(_aCampos2 ,{"PROD_DEVOL","N", _aTamSX3[1], _aTamSX3[2]})
//_aTamSX3 := TamSX3("D2_VALICM" )
//AAdd(_aCampos2 ,{"ICMS_DEV","N", _aTamSX3[1], _aTamSX3[2]})
_aTamSX3 := TamSX3("D2_VALIPI" )
AAdd(_aCampos2 ,{"IPI_DEV ","N", _aTamSX3[1], _aTamSX3[2]})
_aTamSX3 := TamSX3("D2_ICMSRET")
AAdd(_aCampos2 ,{"ICMRET_DEV","N", _aTamSX3[1], _aTamSX3[2]})
_aTamSX3 := TamSX3("D2_VALFRE" )
AAdd(_aCampos2 ,{"FRETE_DEV","N", _aTamSX3[1], _aTamSX3[2]})
_aTamSX3 := TamSX3("D2_DESPESA")
AAdd(_aCampos2 ,{"DESPES_DEV","N", _aTamSX3[1], _aTamSX3[2]})
_aTamSX3 := TamSX3("D2_TOTAL"  )
AAdd(_aCampos2 ,{"TOTAL_DEV","N", _aTamSX3[1], _aTamSX3[2]})


_cArqTrb := CriaTrab(_aCampos2,.T.)
DbUseArea(.T.,,_cArqTrb,"TRB2",.F.,.F.)


ProcRegua(5000)

DbSelectArea("cSQL3")
DbSelectArea("cSQL4")
cSQL3->(dbGotop())
cSQL4->(dbGotop())
DbSelectArea("TRB2")

While cSQL3->(!Eof()) .Or. cSQL4->(!Eof())
	
	IncProc("Faturamento/Devolução ..: ")
	
	RecLock("TRB2",.T.)
	
	//FATURADOS
	TRB2->CFOP_FAT   := cSQL3->CFOP
	TRB2->NCM_FAT    := cSQL3->NCM
	TRB2->PROD_FATUR := cSQL3->TOTAL_FAT
//	TRB2->ICMS_FAT   := cSQL3->T_ICMS
	TRB2->IPI_FAT    := cSQL3->T_IPI
	TRB2->ICMRET_FAT := cSQL3->T_ICMSRET
	TRB2->FRETE_FAT  := cSQL3->T_FRETE
	TRB2->DESPES_FAT := cSQL3->T_DESPESA
	TRB2->TOTAL_FAT  := cSQL3->(TOTAL_FAT+T_IPI+T_ICMSRET+T_FRETE+T_DESPESA)
	
	//DEVOLVIDOS
	TRB2->CFOP_DEV   := cSQL4->CFOP
	TRB2->NCM_DEV    := cSQL4->NCM
	TRB2->PROD_DEVOL := cSQL4->TOTAL_DEV
  //	TRB2->ICMS_DEV   := cSQL4->T_ICMS
	TRB2->IPI_DEV    := cSQL4->T_IPI
	TRB2->ICMRET_DEV := cSQL4->T_ICMSRET
	TRB2->FRETE_DEV  := cSQL4->T_FRETE
	TRB2->DESPES_DEV := cSQL4->T_DESPESA
	TRB2->TOTAL_DEV  := cSQL4->(TOTAL_DEV+T_IPI+T_ICMSRET+T_FRETE+T_DESPESA)
	
	
	MsUnLock()
	
	cSQL3->(dbSkip())
	cSQL4->(dbSkip())
	
EndDo

DbSelectArea("TRB2")
TRB2->(dbGotop())
ProcRegua(TRB2->(RECCOUNT()))	
aCols := Array(TRB2->(RECCOUNT()),Len(_aCampos2))
nColuna := 0
nLinha := 0
While TRB2->(!Eof())
	nLinha++
	IncProc(OemToAnsi("Gerando planilha excel..."))
	For nColuna := 1 to Len(_aCampos2)
		aCols[nLinha][nColuna] := &("TRB2->("+_aCampos2[nColuna][1]+")")			
	Next nColuna
	TRB2->(dbSkip())	
EndDo
u_GDToExcel(_aCampos2,aCols,Alltrim(FunName()))

DbSelectArea("TRB2")

// Gerando arquivo excel - RB 10/12/2014
COPY TO &cArqExcell VIA "DBFCDX"
MakeDir(cDestino) // CRIA DIRETÓRIO CASO NÃO EXISTA
CpyS2T(cArqExcell+".dbf",cDestino,.T.) // COPIA ARQUIVO PARA MAQUINA DO USUÁRIO

// Buscando e apagando arquivos temporários
aTmp := Directory( cDestino+"*.tmp" )
For nI:= 1 to Len(aTmp)
	fErase(cDestino+aTmp[nI,1])
Next nI



Return(!cSQL3->(BOF().and.!cSQL4->(BOF()).and.EOF()))

/////////////////////////////////////////////////////////////////////////////
Static Function AjustaSX1(cPerg)
_sAlias := Alias()
dbSelectArea("SX1")
dbSetOrder(1)

aRegs:={}

//------------ Grupo/Ordem/Pergunta/PERGING/PERGESP/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05/F3

aAdd(aRegs,{cPerg,"1","Emissao de    ?","","","mv_ch1","D",8,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"2","Emissao Ate   ?","","","mv_ch2","D",8,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","",""})


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

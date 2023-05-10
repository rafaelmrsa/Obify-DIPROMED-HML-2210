/*
+========================================================+
|Funcao |DIPR079   |Autor| RBORGES     |Data| 07/08/2014 |
+========================================================+
|Descr.|Relatório para imprimir as notas ficais para     |
|       efeito de conferência para pagamento do seguro   |
|       das mercadorias transportadas.                   |
+========================================================+
|Uso: Transportadora Emovere							 |
+========================================================+
*/

#include "Protheus.ch"

User Function DIPR079()

Local _xArea   := GetArea()
Local titulo     := OemTOAnsi("Relatório de seguro das mercadorias",72)
Local cDesc1     := OemToAnsi("Este programa tem como objetivo emitir um relatório",72)
Local cDesc2     := OemToAnsi("com as informações da nota fical",72)
Local cDesc3     := OemToAnsi("Conforme parametros definidos pelo o usuario.",72)
//Local cUserAut    := GetMV("MV_URELFAT") // MCVN - 04/05/09
Private cDestino   := "C:\EXCELL-DBF\"
Private _cDipUsr   := U_DipUsr()
Private aReturn    := {"Bco A4", 1,"Faturamento", 1, 2, 1,"",1}
Private li         := 66
Private tamanho    := "P" // “P”, “M” ou “G” 
Private limite     := 80 // 80,132 ou 220 
Private nomeprog   := "DIPR079"
Private cPerg      := "DIPR079"

// FPADR(cPerg, cArq, cCampo, cTipo)  - Para ajustar o tamanho das perguntas no SX1- uso generico
PRIVATE cPerg  	:= U_FPADR( "DIPR079","SX1","SX1->X1_GRUPO"," " ) //RBorges 07/08/2014

Private nLastKey   := 0
Private lEnd       := .F.
Private wnrel      := "DIPR079"
Private cString    := "DT6"
Private m_pag      := 1
Private _cArqTrb

/*/ MCVN - 04/05/09
If !(Upper(U_DipUsr()) $ cUserAut)
	Alert(Upper(U_DipUsr())+", você não tem autorização para utilizar esta rotina. Qualquer dúvida falar com Maximo!","Atenção")
	Return()
EndIF
*/

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
dbSelectArea("QRY1")
QRY1->(dbCloseArea())
TRB->(dbCloseArea())

Return

//////////////////////////////////////////////////////////////////////
Static Function RodaProc()


Local cArqExcell:= "\Excell-DBF\"+_cDipUsr+"-DIPR079"
Local nFatDipmI := 0
Local nFatDipmU := 0
Local nFatDipcI := 0
Local nFatDipcU := 0
Local nFatHQI   := 0
Local nFatHQU   := 0
Local nOutros   := 0

ProcRegua(15000)
For _x := 1 to 5000
	IncProc( "Preparando os dados... ")
Next

QRY1 := " SELECT DT6_CLIREM,A1_COD, A1_LOJA, A1_CEP,DT6_LOJREM,DTC_DOC, DTC_SERIE,DT6_DOC, DT6_SERIE, DT6_DATEMI,DTC_NUMNFC,DTC_PESO,DTC_QTDVOL,DTC_VALOR"
QRY1 += " FROM " + RetSQLName("DT6")+' DT6, '+RetSQLName("DTC")+' DTC, '+RetSQLName("SA1")+" SA1 "
QRY1 += " WHERE DT6_FILIAL = '" + xFilial('DT6') + "'"
QRY1 += " AND   DTC_FILIAL = '" + xFilial('DTC') + "'"
QRY1 += " AND   A1_FILIAL = '" + xFilial('SA1') + "'"
QRY1 += " AND	DT6_CLIDES = A1_COD      "
QRY1 += " AND	DT6_LOJDES = A1_LOJA     "
QRY1 += " AND   DT6_DOC    = DTC_DOC     "
QRY1 += " AND   DT6_SERIE  = DTC_SERIE   "
QRY1 += " AND   DT6_DATEMI = DTC_DATENT  "
QRY1 += " AND   DT6.D_E_L_E_T_ <> '*'    "
QRY1 += " AND   DTC.D_E_L_E_T_ <> '*'    "
QRY1 += " AND   SA1.D_E_L_E_T_ <> '*'    "
QRY1 += " AND   DT6_DATEMI BETWEEN '" + DTOS(mv_par01) + "' AND '" + DTOS(mv_par02) + "'"
QRY1 += " ORDER BY DT6_CLIREM,DT6_LOJREM,DT6_DATEMI,DTC_NUMNFC,DT6_DOC"

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

ProcRegua(15000)
For _x := 1 to 5000
	IncProc( "Classificando... ")
	
Next

If MV_PAR03 == "2"
	
	_aCampos := {}
	_aTamSX3 := TamSX3("DTC_VALOR")
	AAdd(_aCampos ,{"DIPR_MTZ_I", "N",_aTamSX3[1],_aTamSX3[2]})
	_aTamSX3 := TamSX3("DTC_VALOR")
	AAdd(_aCampos ,{"DIPR_MTZ_U", "N",_aTamSX3[1],_aTamSX3[2]})
	_aTamSX3 := TamSX3("DTC_VALOR")
	AAdd(_aCampos ,{"DIPR_CD_I", "N",_aTamSX3[1],_aTamSX3[2]})
	_aTamSX3 := TamSX3("DTC_VALOR")
	AAdd(_aCampos ,{"DIPR_CD_U", "N",_aTamSX3[1],_aTamSX3[2]})
	_aTamSX3 := TamSX3("DTC_VALOR")
	AAdd(_aCampos ,{"HQUALITY_I  ", "N",_aTamSX3[1],_aTamSX3[2]})
	_aTamSX3 := TamSX3("DTC_VALOR")
	AAdd(_aCampos ,{"HQUALITY_U  ", "N",_aTamSX3[1],_aTamSX3[2]})
	_aTamSX3 := TamSX3("DTC_VALOR")
	AAdd(_aCampos ,{"OUTRAS_FAT ", "N",_aTamSX3[1],_aTamSX3[2]})
	
Else
	
	_aCampos := {}
	_aTamSX3 := TamSX3("DTC_VALOR")
	AAdd(_aCampos ,{"DIPR_MTZ_I", "N",_aTamSX3[1],_aTamSX3[2]})
	_aTamSX3 := TamSX3("DTC_VALOR")
	AAdd(_aCampos ,{"DIPR_MTZ_U", "N",_aTamSX3[1],_aTamSX3[2]})
	_aTamSX3 := TamSX3("DTC_VALOR")
	AAdd(_aCampos ,{"DIPR_CD_I", "N",_aTamSX3[1],_aTamSX3[2]})
	_aTamSX3 := TamSX3("DTC_VALOR")
	AAdd(_aCampos ,{"DIPR_CD_U", "N",_aTamSX3[1],_aTamSX3[2]})
	_aTamSX3 := TamSX3("DTC_VALOR")
	AAdd(_aCampos ,{"HQUALITY_I  ", "N",_aTamSX3[1],_aTamSX3[2]})
	_aTamSX3 := TamSX3("DTC_VALOR")
	AAdd(_aCampos ,{"HQUALITY_U  ", "N",_aTamSX3[1],_aTamSX3[2]})
	_aTamSX3 := TamSX3("DTC_VALOR")
	AAdd(_aCampos ,{"OUTRAS_FAT ", "N",_aTamSX3[1],_aTamSX3[2]})
	_aTamSX3 := TamSX3("DT6_CLIREM")
	AAdd(_aCampos ,{"REMETENTE", "C",_aTamSX3[1],_aTamSX3[2]})
	_aTamSX3 := TamSX3("DT6_LOJREM")
	AAdd(_aCampos ,{"LOJA_REM", "C",_aTamSX3[1],_aTamSX3[2]})
	_aTamSX3 := TamSX3("DT6_DATEMI")
	AAdd(_aCampos ,{"EMISSAO", "D",_aTamSX3[1],_aTamSX3[2]})
	_aTamSX3 := TamSX3("DTC_NUMNFC")
	AAdd(_aCampos ,{"N_FISCAL", "C",_aTamSX3[1],_aTamSX3[2]})
	_aTamSX3 := TamSX3("DTC_PESO")
	AAdd(_aCampos ,{"PESO", "N",_aTamSX3[1],_aTamSX3[2]})
	_aTamSX3 := TamSX3("DTC_QTDVOL")
	AAdd(_aCampos ,{"QTD_VOL", "N",_aTamSX3[1],_aTamSX3[2]})
	_aTamSX3 := TamSX3("DTC_VALOR")
	AAdd(_aCampos ,{"VALOR", "N",_aTamSX3[1],_aTamSX3[2]})
	
EndIf

_cArqTrb := CriaTrab(_aCampos,.T.)
DbUseArea(.T.,,_cArqTrb,"TRB",.F.,.F.)

DbSelectArea("QRY1")
QRY1->(dbGotop())

Do While !QRY1->(EOF())
	
	If     QRY1->(DT6_CLIREM+DT6_LOJREM) == "00080401" .And. QRY1->A1_CEP <= "11000000"
		nFatDipmU += QRY1->DTC_VALOR
	ElseIf QRY1->(DT6_CLIREM+DT6_LOJREM) == "00080404" .And. QRY1->A1_CEP <= "11000000"
		nFatDipcU += QRY1->DTC_VALOR
	ElseIf QRY1->(DT6_CLIREM+DT6_LOJREM) == "01105001" .And. QRY1->A1_CEP <= "11000000"
		nFatHQU += QRY1->DTC_VALOR
	ElseIf QRY1->(DT6_CLIREM+DT6_LOJREM) == "00080401" .And. QRY1->A1_CEP >= "11000001"
		nFatDipmI += QRY1->DTC_VALOR
	ElseIf QRY1->(DT6_CLIREM+DT6_LOJREM) == "00080404" .And. QRY1->A1_CEP >= "11000001"
		nFatDipcI += QRY1->DTC_VALOR
	ElseIf QRY1->(DT6_CLIREM+DT6_LOJREM) == "01105001" .And. QRY1->A1_CEP >= "11000001"
		nFatHQI += QRY1->DTC_VALOR
	Else
		nOutros  += QRY1->DTC_VALOR
	EndIf
	
	If MV_PAR03 <> "2"
		
		DbSelectArea("TRB")
		RecLock("TRB",.T.)
		
		TRB->REMETENTE  := QRY1->DT6_CLIREM
		TRB->LOJA_REM   := QRY1->DT6_LOJREM
		TRB->EMISSAO    := CTOD(SUBSTRING(QRY1->DT6_DATEMI,7,2)+'/'+SUBSTRING(QRY1->DT6_DATEMI ,5,2)+'/'+SUBSTRING(QRY1->DT6_DATEMI ,1,4))
		TRB->N_FISCAL   := QRY1->DTC_NUMNFC
		TRB->PESO       := QRY1->DTC_PESO
		TRB->QTD_VOL    := QRY1->DTC_QTDVOL
		TRB->VALOR      := QRY1->DTC_VALOR
		
		TRB->(MsUnLock())
		
	EndIf
	
	QRY1->(dbSkip())
	
EndDo

DbSelectArea("TRB")
RecLock("TRB",.T.)

TRB->DIPR_MTZ_I  := nFatDipmI
TRB->DIPR_MTZ_U  := nFatDipmU
TRB->DIPR_CD_I   := nFatDipcI
TRB->DIPR_CD_U   := nFatDipcU
TRB->HQUALITY_I  := nFatHQI
TRB->HQUALITY_U  := nFatHQU

TRB->OUTRAS_FAT := nOutros

TRB->(MsUnLock())

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
TRB->(DbGotop())

// Gerando arquivo excel - RBorges 07/08/2014
COPY TO &cArqExcell VIA "DBFCDX"

MakeDir(cDestino) // CRIA DIRETÓRIO CASO NÃO EXISTA
CpyS2T(cArqExcell+".dbf",cDestino,.T.) // COPIA ARQUIVO PARA MAQUINA DO USUÁRIO

// Buscando e apagando arquivos temporários - RBorges 07/08/2014
aTmp := Directory( cDestino+"*.tmp" )
For nI:= 1 to Len(aTmp)
	fErase(cDestino+aTmp[nI,1])
Next nI

Return(.T.)


////////////////////////
Static Function RodaRel()

DbSelectArea("TRB")
TRB->(DbGotop())
SetRegua(RecCount()) 

	        *          1         2         3         4         5         6         7         8
    	    *012345678901234567890123456789012345678901234567890123456789012345678901234567890

_cTitulo := "Relatório das notas fiscais da seguradora - " + 'PERIODO: '+dTOc(mv_par01)+' a '+dTOc(mv_par02)
_cDesc1  := "                              Interior            Urbano            Sub Total   "
_cDesc2  := ""

Do While TRB->(!Eof())
	
	IncRegua( "Imprimindo... ")
	
	If li > 60
		li := Cabec(_cTitulo,_cDesc1,_cDesc2,nomeprog,tamanho)
	EndIf
                                                                                          
	*          1         2         3         4         5         6         7         8
	*012345678901234567890123456789012345678901234567890123456789012345678901234567890
	*
	*                         Interior            Urbano               Sub Total
	*    Dipromed_Matriz   9,999.999.999,99  | 9,999.999.999,99  |  9,999.999.999,99
	*	 Dipromed_CD       9,999.999.999,99  | 9,999.999.999,99  |  9,999.999.999,99
	*	 H.Quality         9,999.999.999,99  | 9,999.999.999,99  |  9,999.999.999,99
	*	 Outras_Faturas    9,999.999.999,99  | 9,999.999.999,99  |  9,999.999.999,99
	*                      9,999.999.999,99  | 9,999.999.999,99  |  9,999.999.999,99
	*.................................................................................
	*     Total Geral      9,999.999.999,99  | 9,999.999.999,99  |  9,999.999.999,99
	* ................................................................................

	
	IF ((TRB->DIPR_MTZ_I > 0) .Or. (TRB->DIPR_MTZ_U > 0) .Or. (TRB->DIPR_CD_I > 0) .Or.;
		(TRB->DIPR_CD_U > 0 ) .Or. (TRB->HQUALITY_I > 0) .Or. (TRB->HQUALITY_U > 0) .Or. (TRB->OUTRAS_FAT > 0))
		
		li+=1
		@ li,001 PSay "Dipromed_Matriz:"
		@ li,022 PSay TRB->DIPR_MTZ_I PICTURE "@E 9,999,999,999.99"
		@ li,040 PSay REPLICATE("|",1)
		@ li,042 PSay TRB->DIPR_MTZ_U PICTURE "@E 9,999,999,999.99"
		@ li,060 PSay REPLICATE("|",1)
		@ li,062 PSay (TRB->DIPR_MTZ_I+TRB->DIPR_MTZ_U)PICTURE "@E 9,999,999,999.99"
		li+=1
		@ li,001 PSay "Dipromed_CD:"		
		@ li,022 PSay TRB->DIPR_CD_I  PICTURE "@E 9,999,999,999.99"
		@ li,040 PSay REPLICATE("|",1)
		@ li,042 PSay TRB->DIPR_CD_U  PICTURE "@E 9,999,999,999.99"
		@ li,060 PSay REPLICATE("|",1)
		@ li,062 PSay (TRB->DIPR_CD_I+TRB->DIPR_CD_U)PICTURE "@E 9,999,999,999.99"		
		li+=1
		@ li,001 PSay "H.Quality:"		
		@ li,022 PSay TRB->HQUALITY_I PICTURE "@E 9,999,999,999.99"
		@ li,040 PSay REPLICATE("|",1)
		@ li,042 PSay TRB->HQUALITY_U PICTURE "@E 9,999,999,999.99"
		@ li,060 PSay REPLICATE("|",1)
		@ li,062 PSay (TRB->HQUALITY_I+TRB->HQUALITY_U)PICTURE "@E 9,999,999,999.99"				
		li+=1
		@ li,001 PSay "Outras Faturas:"		
		@ li,060 PSay REPLICATE("|",1)		
		@ li,062 PSay TRB->OUTRAS_FAT PICTURE "@E 9,999,999,999.99"
		li+=1
		@ li,000 PSay REPLICATE(".",limite)
		li+=1
		@ li,001 PSay "Total"
		@ li,022 PSay ((TRB->DIPR_MTZ_I)+(TRB->DIPR_CD_I)+(TRB->HQUALITY_I))PICTURE "@E 9,999,999,999.99"
		@ li,040 PSay REPLICATE("|",1)
		@ li,042 PSay ((TRB->DIPR_MTZ_U)+(TRB->DIPR_CD_U)+(TRB->HQUALITY_U)) PICTURE "@E 9,999,999,999.99"
		@ li,060 PSay REPLICATE("|",1)
  		@ li,062 PSay ((TRB->DIPR_MTZ_I)+(TRB->DIPR_MTZ_U)+(TRB->DIPR_CD_I)+(TRB->DIPR_CD_U)+(TRB->HQUALITY_I)+(TRB->HQUALITY_U)+TRB->OUTRAS_FAT) PICTURE "@E 9,999,999,999.99"
		li+=1
		@ li,000 PSay REPLICATE(".",limite)
				
	EndIf
	
	TRB->(dbSkip())
	
EndDo
If li > 60
	li := Cabec(_cTitulo,_cDesc1,_cDesc2,nomeprog,tamanho)
EndIf

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

////////////////////////////////////////////////////////////////////////////
Static Function AjustaSX1(cPerg)
_sAlias := Alias()
dbSelectArea("SX1")
dbSetOrder(1)

aRegs:={}

//------------ Grupo/Ordem/Pergunta/PERGING/PERGESP/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05/F3

aAdd(aRegs,{cPerg,"01","Data inicial        ?","","","mv_ch1","D",8, 0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"02","Data final          ?","","","mv_ch2","D",8, 0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"03","Visualizar Docts 1-S/2-N ?","","","mv_ch3","C",1, 0,0,"G","","mv_par03","1-Sim","1-Sim","1-Sim","","","2-Não","2-Não","2-Não","","","","","","","","","","","","","","","","","",""})


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

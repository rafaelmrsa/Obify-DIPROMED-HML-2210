/*====================================================================================\
|Programa  | DIPR055       | Autor | Rafael de Campos Falco     | Data | 06/01/2005   |
|=====================================================================================|
|Descrição | Pedidos do SC9 x SC5                                                     |
|=====================================================================================|
|Sintaxe   | DIPR055                                                                  |
|=====================================================================================|
|Uso       | Especifico DIPROMED                                                      |
|=====================================================================================|
|........................................Histórico....................................|
|Rafael    | DD/MM/AA - Descrição                                                     |
|Eriberto  | DD/MM/AA - Descrição                                                     |
\====================================================================================*/

#include "rwmake.ch"
#INCLUDE "TBICONN.CH"
#INCLUDE "FILEIO.CH"

User Function DIPR055()

Local _xArea		:= GetArea()
Local titulo		:= OemTOAnsi("Relatório de pedidos do SC9 x SC5 - Por Período",72)
Local cDesc1		:= (OemToAnsi("Este programa tem como objetivo emitir um relat¢rio",72))
Local cDesc2		:= (OemToAnsi("com a relação de pedidos do SC9 x SC5.",72))
Local cDesc3		:= (OemToAnsi("Conforme parametros definidos pelo o usuario.",72))
Private m_pag		:= 1
Private nLastKey	:= 0
Private aPar2		:= ""
Private cWorkFlow	:= ""
Private li			:= 99
Private tamanho	:= "G"
Private limite		:= 220
Private lEnd		:= .F.
Private cString	:= "SZD"
Private wnrel		:= "DIPR055"
Private nomeprog	:= "DIPR055"

// Private cPerg		:= "DIPR55"
// FPADR(cPerg, cArq, cCampo, cTipo)  - Para ajustar o tamanho das perguntas no SX1- uso generico
PRIVATE cPerg  	:= U_FPADR( "DIPR55","SX1","SX1->X1_GRUPO"," " ) //Função criada por Sandro em 19/11/09.

Private aReturn	:= {"Bco A4", 1,"Administracao", 1, 2, 1,"",1}                  

U_DIPPROC(ProcName(0),U_DipUsr()) // JBS 05/10/2005 - Gravando o nome do Programa no SZU

AjustaSX1(cPerg)                // Verifica perguntas. Se nao existe INCLUI.

If !Pergunte(cPerg,.T.)    // Solicita parametros
	Return
EndIf                      

wnrel := SetPrint(cString,wnrel,cPerg,Titulo,cDesc1,cDesc2,cDesc3,.f.,,.f.,tamanho,,.f.,,,,,)

If nLastKey == 27
	Return
Endif
	
SetDefault(aReturn,cString)

Processa({|lEnd| RunProc55()},"Processando dados das tabelas...")

RptStatus({|lEnd| RodaRel55()},"Imprimindo Relação de Pedidos...")

Set device to Screen
	
/*====================================================================================\
|  Se em disco, desvia para Spool                                                     |
\====================================================================================*/
If aReturn[5] == 1    // Se Saida para disco, ativa SPOOL
	Set Printer TO
	Commit
	ourspool(wnrel)
Endif

RestArea(_xArea)

Return

//////////////////////////////////////////////////////////////////////
Static Function RunProc55()

ProcRegua(100)
For _x := 1 to 50
	IncProc( "Processando dados das tabelas SC9 x SC5... ")
Next

/*
*/

QRY1 := " SELECT C5_FILIAL, C5_NUM, C5_CLIENTE, C5_LOJACLI,  A1_NOME, C5_VEND1, C5_OPERADO, U7_NREDUZ, C5_EMISSAO, C5_CONDPAG, C5_PARC1, C5_DATA1, C5_PARC2, C5_DATA2, C5_PARC3, C5_DATA3, C5_PARC4, C5_DATA4, C5_PARC5, C5_DATA5, C5_PARC6, C5_DATA6, C5_TRANSP, C5_EXPLBLO, C9_PRODUTO, C9_BLEST, C9_BLCRED, C9_BLCRED2, C9_QTDLIB, C9_PARCIAL, C9_QTDVEN, C9_SALDO, C5_DT_PRE, C5_HR_PRE"
QRY1 += " FROM  " + RetSQLName("SC5") + "," + RetSQLName("SA1") + "," + RetSQLName("SC9") + "," + RetSQLName("SU7")
QRY1 += " WHERE C5_FILIAL = '" + xFilial('SC5') + "'"
QRY1 += " AND C5_EMISSAO BETWEEN '" + DTOS(MV_PAR01) + "' AND '" + DTOS(MV_PAR02) + "'"
QRY1 += " AND C5_VEND1 BETWEEN '" + MV_PAR03 + "' AND '" + MV_PAR04 + "'"
QRY1 += " AND C5_OPERADO BETWEEN '" + MV_PAR05 + "' AND '" + MV_PAR06 + "'"
QRY1 += " AND C5_NUM BETWEEN '" + MV_PAR07 + "' AND '" + MV_PAR08 + "'"
QRY1 += " AND C5_CLIENTE = A1_COD"
QRY1 += " AND C5_FILIAL = C9_FILIAL"
QRY1 += " AND C5_NUM = C9_PEDIDO"

If MV_PAR10 = 1
	QRY1 += " AND C9_PARCIAL = ' '"
	QRY1 += " AND C9_BLEST = '02'"
	QRY1 += " AND C9_BLCRED = '  '"
 //	QRY1 += " AND C9_BLCRED2 = '  '"
ElseIf MV_PAR10 = 2
	QRY1 += " AND C9_PARCIAL = 'N'"
	QRY1 += " AND C9_BLEST <> '10'"
	QRY1 += " AND C9_BLCRED <> '10'"
ElseIf MV_PAR10 = 3
	QRY1 += " AND C9_BLEST <> '10'"
	QRY1 += " AND C9_BLCRED <> '10'"
EndIf

QRY1 += " AND C5_OPERADO = U7_COD"
QRY1 += " AND " + RetSQLName("SC5") + ".D_E_L_E_T_ = ''"
QRY1 += " AND " + RetSQLName("SA1") + ".D_E_L_E_T_ = ''"
QRY1 += " AND " + RetSQLName("SC9") + ".D_E_L_E_T_ = ''"
QRY1 += " AND " + RetSQLName("SU7") + ".D_E_L_E_T_ = ''"

If MV_PAR09 = 1
	QRY1 += " ORDER BY C5_NUM, C9_PRODUTO"
ElseIf MV_PAR09 = 2
	QRY1 += " ORDER BY C5_VEND1, C5_NUM, C5_DT_PRE, C5_HR_PRE, C9_PRODUTO"
Else
	QRY1 += " ORDER BY C5_OPERADO, C5_NUM, C5_DT_PRE, C5_HR_PRE, C9_PRODUTO"
EndIf

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
QRY1->(dbGotop())

ProcRegua(100)
For _x := 1 to 100
	IncProc( "Fim do Processando... ")
Next

Return(.T.)

//////////////////////////////////////////////////////////////////////
Static Function RodaRel55()

Local _cTitulo	:= "Pedidos no SC9 - " + Iif(MV_PAR10=1,"LIBERADOS - ",Iif(MV_PAR10=2,"BLOQUEADO PELO OPERADOR - ",Iif(MV_PAR10=3,"TODOS - ","He He deu errado - ")))+ Substr(DtoS(MV_PAR01),7,2)+"/"+Substr(DtoS(MV_PAR01),5,2)+"/"+Substr(DtoS(MV_PAR01),1,4) + " até " + Substr(DtoS(MV_PAR02),7,2)+"/"+Substr(DtoS(MV_PAR02),5,2)+"/"+Substr(DtoS(MV_PAR02),1,4)
Local _cDesc1	:= " Pedido Código Lj Nome                                                       Vendedor Código-Operador          Emissão      Cond.Pgto Transp.   Dt.Pre-Nota  Hr.Pre-Nota"
Local _cDesc2	:= " Produto   Qtd. Liber      Qtd. Vend.             Saldo   Parcial BLEST BLCRED BLCRED2"
Local cReg_Ant	:= ""
Local nTot_Reg	:= 30

*0                                                                                                   1                                                                                                   2
*0         1         2         3         4         5         6         7         8         9         0         1         2         3         4         5         6         7         8         9         0         1         2
*01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
*-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
* Pedido Código Lj Nome                                                       Vendedor Código-Operador          Emissão      Cond.Pgto Transp.   Dt.Pre-Nota  Hr.Pre-Nota
* Produto   Qtd. Liber      Qtd. Vend.             Saldo   Parcial BLEST BLCRED BLCRED2
*-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
* 999999 999999 99 XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX     999999   999999-XXXXXXXXXXXXXXX   DD/MM/AAAA   999       999999    DD/MM/AAAA   HH-MM-SS
* PARCELAS: 9.999.999,99  DD/MM/AAAA   9.999.999,99  DD/MM/AAAA   9.999.999,99  DD/MM/AAAA   9.999.999,99  DD/MM/AAAA
* EXCLUSÃO: XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
* -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
* 999999  9,999,999.99   99,999,999.99      9,999,999.99   X       XX    XX     XX      
* 999999  9,999,999.99   99,999,999.99      9,999,999.99   X       XX    XX     XX      
* 999999  9,999,999.99   99,999,999.99      9,999,999.99   X       XX    XX     XX      
* 999999  9,999,999.99   99,999,999.99      9,999,999.99   X       XX    XX     XX      
*-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

DbSelectArea("QRY1")

QRY1->(dbGoTop())
Do While QRY1->(!Eof())


	SetRegua(nTot_Reg)	
	
	If lAbortPrint
		@ li+1,00 PSAY "*** CANCELADO PELO OPERADOR ***"
		Exit
	Endif
	
	If li > 66
		li := Cabec(_cTitulo,_cDesc1,_cDesc2,nomeprog,tamanho) + 1
	EndIf

	@ li,001 PSay QRY1->C5_NUM
	@ li,008 PSay AllTrim(QRY1->C5_CLIENTE)
	@ li,015 PSay QRY1->C5_LOJACLI
	@ li,018 PSay SubStr(AllTrim(QRY1->A1_NOME),1,54)
	@ li,077 PSay QRY1->C5_VEND1
	@ li,086 PSay QRY1->C5_OPERADO + "-" + AllTrim(QRY1->U7_NREDUZ)
	@ li,111 PSay SubStr(QRY1->C5_EMISSAO,7,2)+'/'+SubStr(QRY1->C5_EMISSAO,5,2)+'/'+SubStr(QRY1->C5_EMISSAO,1,4)
	@ li,124 PSay QRY1->C5_CONDPAG
	@ li,134 PSay QRY1->C5_TRANSP
	@ li,144 PSay SubStr(QRY1->C5_DT_PRE,7,2)+'/'+SubStr(QRY1->C5_DT_PRE,5,2)+'/'+SubStr(QRY1->C5_DT_PRE,1,4)
	@ li,157 PSay QRY1->C5_HR_PRE
	li++        
	@ li,001 PSay "PARCELAS: "
	@ li,011 PSay QRY1->C5_PARC1 PICTURE '@E 9,999,999.99'
	@ li,025 PSay SubStr(QRY1->C5_DATA1,7,2)+'/'+SubStr(QRY1->C5_DATA1,5,2)+'/'+SubStr(QRY1->C5_DATA1,1,4)
	@ li,038 PSay QRY1->C5_PARC2 PICTURE '@E 9,999,999.99'
	@ li,052 PSay SubStr(QRY1->C5_DATA2,7,2)+'/'+SubStr(QRY1->C5_DATA2,5,2)+'/'+SubStr(QRY1->C5_DATA2,1,4)
	@ li,065 PSay QRY1->C5_PARC3 PICTURE '@E 9,999,999.99'
	@ li,079 PSay SubStr(QRY1->C5_DATA3,7,2)+'/'+SubStr(QRY1->C5_DATA3,5,2)+'/'+SubStr(QRY1->C5_DATA3,1,4)
	@ li,092 PSay QRY1->C5_PARC4 PICTURE '@E 9,999,999.99'
	@ li,106 PSay SubStr(QRY1->C5_DATA4,7,2)+'/'+SubStr(QRY1->C5_DATA4,5,2)+'/'+SubStr(QRY1->C5_DATA4,1,4)
	@ li,120 PSay QRY1->C5_PARC5 PICTURE '@E 9,999,999.99'
	@ li,134 PSay SubStr(QRY1->C5_DATA5,7,2)+'/'+SubStr(QRY1->C5_DATA5,5,2)+'/'+SubStr(QRY1->C5_DATA5,1,4)
	@ li,148 PSay QRY1->C5_PARC6 PICTURE '@E 9,999,999.99'
	@ li,162 PSay SubStr(QRY1->C5_DATA6,7,2)+'/'+SubStr(QRY1->C5_DATA6,5,2)+'/'+SubStr(QRY1->C5_DATA6,1,4)
	li++
	@ li,001 PSay "EXPLICAÇÃO: " + AllTrim(QRY1->C5_EXPLBLO)
	li++
	@ li,000 PSay Replic("-",Limite)
	li++

	// ARMAZENA ÚLTIMO REGISTRO PARA COMPARAÇÃO		
	cReg_Ant := QRY1->C5_NUM + QRY1->C5_CLIENTE + QRY1->C5_LOJACLI + QRY1->C5_VEND1 + QRY1->C5_OPERADO
	
	While cReg_Ant == QRY1->C5_NUM + QRY1->C5_CLIENTE + QRY1->C5_LOJACLI + QRY1->C5_VEND1 + QRY1->C5_OPERADO

		IncRegua("Imprimindo Pedidos do SC9 x SC5... " + QRY1->C5_NUM )

		If li > 66
			li := Cabec(_cTitulo,_cDesc1,_cDesc2,nomeprog,tamanho) + 1
		EndIf
		
		@ li,001 PSay AllTrim(QRY1->C9_PRODUTO)
		@ li,009 PSay QRY1->C9_QTDLIB PICTURE '@E 9,999,999.99'
		@ li,024 PSay QRY1->C9_QTDVEN PICTURE '@E 99,999,999.99'
		@ li,043 PSay QRY1->C9_SALDO PICTURE '@E 9,999,999.99'
		@ li,058 PSay QRY1->C9_PARCIAL 
		@ li,066 PSay QRY1->C9_BLEST 
		@ li,072 PSay QRY1->C9_BLCRED
		@ li,079 PSay QRY1->C9_BLCRED2

		li++
		QRY1->(DbSkip())
	EndDo
	li++
	@ li,000 PSay Replic("-",Limite)
	li++
EndDo	

QRY1->(dbCloseArea())

Return(.T.)

/////////////////////////////////////////////////////////////////////////////
Static Function AjustaSX1(cPerg)
_sAlias := Alias()
dbSelectArea("SX1")
dbSetOrder(1)

aRegs:={}

//------------ Grupo/Ordem/Pergunta/PERGING/PERGESP/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05/F3

aAdd(aRegs,{cPerg,"01","Período de         ?","","","mv_ch1","D",8,0,0,"G","","MV_PAR01","","","","","","","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"02","Período ate        ?","","","mv_ch2","D",8,0,0,"G","","MV_PAR02","","","","","","","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"03","Vendedor de        ?","","","mv_ch3","C",6,0,0,"G","","MV_PAR03","","","","","","","","","","","","","","","","","","","","","","","","","SA3"})
aAdd(aRegs,{cPerg,"04","Vendedor ate       ?","","","mv_ch4","C",6,0,0,"G","","MV_PAR04","","","","","","","","","","","","","","","","","","","","","","","","","SA3"})
aAdd(aRegs,{cPerg,"05","Operador de        ?","","","mv_ch5","C",6,0,0,"G","","MV_PAR05","","","","","","","","","","","","","","","","","","","","","","","","","SU7"})
aAdd(aRegs,{cPerg,"06","Operador ate       ?","","","mv_ch6","C",6,0,0,"G","","MV_PAR06","","","","","","","","","","","","","","","","","","","","","","","","","SU7"})
aAdd(aRegs,{cPerg,"07","Pedido Vend. de    ?","","","mv_ch7","C",6,0,0,"G","","MV_PAR07","","","","","","","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"08","Pedido Vend. ate   ?","","","mv_ch8","C",6,0,0,"G","","MV_PAR08","","","","","","","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"09","Informe a ordem    ?","","","mv_ch9","N",1,0,0,"C","","MV_PAR09","1-Pedido","","","","","2-Vendedor","","","","","3-Operador","","",""})
aAdd(aRegs,{cPerg,"10","Listar quais       ?","","","mv_chA","N",1,0,0,"C","","MV_PAR10","1-Liberados","","","","","2-Bloq.Parcial","","","","","3-Tudo","","",""})

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
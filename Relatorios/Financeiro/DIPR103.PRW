/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Funcao    ³ DIPR103  ³ Autor ³ Eriberto Elias     ³ Data ³ 02/06/2003  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Relacao de pedidos de compra (sintetico/analitico)         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ DIPR103                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Especifico DIPROMED                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

#include "rwmake.ch"
#IFNDEF WINDOWS
	#DEFINE PSay Say
#ENDIF

User Function DIPR103()

Local _xArea    := GetArea()

// FPADR(cPerg, cArq, cCampo, cTipo)  - Para ajustar o tamanho das perguntas no SX1- uso generico
PRIVATE cPerg  	:= U_FPADR( "DIPR103","SX1","SX1->X1_GRUPO"," " ) //Função criada por Sandro em 19/11/09.

If MsgYesNo("Gerar Relatório com Opção Livro Caixa?") 
	U_DIPR103B()
	Return()	
EndIf

U_DIPPROC(ProcName(0),U_DipUsr()) // JBS 05/10/2005 - Gravando o nome do Programa no SZU

tamanho    := "M"
limite     := 130
titulo     := OemTOAnsi("Relacao de pedidos de compra",72)
cDesc1     := (OemToAnsi("Este relatorio pode ser emitido de forma",72))
cDesc2     := (OemToAnsi("sintetica ou analitica.",72))
cDesc3     := (OemToAnsi(" ",72))
aReturn    := {"Bco A4", 1,"Faturamento", 1, 2, 1,"",1}
nomeprog   := "DIPR103"
//cPerg      := "DIPR27"
nLastKey   := 0
lContinua  := .T.
lEnd       := .F.
li         := 67
wnrel      := "DIPR103"
M_PAG      := 1
cString    := "SC7"

AjustaSX1(cPerg)             // Verifica perguntas. Se nao existe INCLUI

Pergunte(cPerg,.T.)     // Solicita parametros

wnrel := SetPrint(cString,wnrel,cPerg,Titulo,cDesc1,cDesc2,cDesc3,.f.,,.f.,tamanho,,.f.,,,,,)

If nLastKey == 27
	Return
Endif

SetDefault(aReturn,cString)

Processa({|lEnd| RunProc()},"Selecionando pedidos...")

RptStatus({|lEnd| RptDetail()},"Imprimindo relacao de pedidos...")

Set device to Screen

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se em disco, desvia para Spool                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If aReturn[5] == 1    // Se Saida para disco, ativa SPOOL
	Set Printer TO
	Commit
	ourspool(wnrel)
Endif

dbSelectArea("QRY1")
QRY1->(dbCloseArea())

RestArea(_xArea)

Return

//////////////////////////////////////////////////////////////////////
Static Function RunProc()
/*
select C7_EMISSAO, C7_NUM, sum(C7_TOTAL) C7_TOTAL, C7_FORNECE, C7_LOJA, A2_NREDUZ

from SC7010, SA2010

where
SC7010.D_E_L_E_T_        <> '*' and
SA2010.D_E_L_E_T_        <> '*' and
SC7010.C7_FILIAL          = '01' and
SC7010.C7_EMISSAO between '20030501' and '20030531'
and SC7010.C7_FORNECE    >= '      '
and SC7010.C7_FORNECE    <= 'ZZZZZZ'
and SC7010.C7_FORNECE     = SA2010.A2_COD
and SC7010.C7_LOJA        = SA2010.A2_LOJA

group by C7_EMISSAO, C7_NUM, C7_FORNECE, C7_LOJA, A2_NREDUZ

order by C7_EMISSAO, C7_FORNECE  ou C7_FORNECE, C7_EMISSAO
*/

QRY1 := Iif(mv_par05==1,"SELECT C7_FORNECE, C7_COND, E4_CODIGO, E4_DESCRI, C7_LOJA, A2_NREDUZ, SUM(C7_TOTAL) C7_TOTAL, SUM(C7_TOTAL+C7_VALIPI) C7_TOTAL_I",;
"SELECT C7_EMISSAO, C7_DENTREG, E4_CODIGO, E4_DESCRI, C7_COND, C7_NUM, SUM(C7_TOTAL) C7_TOTAL, SUM(C7_TOTAL+C7_VALIPI) C7_TOTAL_I, C7_FORNECE, C7_LOJA, A2_NREDUZ")
QRY1 := QRY1 + " FROM " + RetSQLName("SC7")+', '+ RetSQLName("SA2")+', '+ RetSQLName("SE4")
QRY1 := QRY1 + " WHERE "

If cEmpAnt == '01'
	If mv_par13 == 1 //Consolidado 1-SIM/2-NAO
		QRY1 := QRY1 + RetSQLName('SC7')+".C7_FILIAL IN ('01','04') and "
	Else
		QRY1 := QRY1 + RetSQLName('SC7')+".C7_FILIAL = '"+xFilial('SC7')+"' and "
	EndIf
Else
	If mv_par13 == 1 //Consolidado 1-SIM/2-NAO
		QRY1 := QRY1 + RetSQLName('SC7')+".C7_FILIAL IN ('01','02') and "
	Else
		QRY1 := QRY1 + RetSQLName('SC7')+".C7_FILIAL = '"+xFilial('SC7')+"' and "
	EndIf	
EndIF

QRY1 := QRY1 + RetSQLName('SC7')+".D_E_L_E_T_ <> '*' and "
QRY1 := QRY1 + RetSQLName('SA2')+".D_E_L_E_T_ <> '*' and "

If MV_PAR10 == 1
	QRY1 := QRY1 + RetSQLName('SC7')+".C7_DENTREG between '"+dTOs(mv_par11)+"' and '"+dTOs(mv_par12)+"' and "
Else
	QRY1 := QRY1 + RetSQLName('SC7')+".C7_EMISSAO between '"+dTOs(mv_par01)+"' and '"+dTOs(mv_par02)+"' and "
EndIf	

QRY1 := QRY1 + RetSQLName('SC7')+".C7_FORNECE between '"+mv_par03+"' and '"+mv_par04+"' and "
QRY1 := QRY1 + RetSQLName('SC7')+".C7_FORNECE  = "+RetSQLName('SA2')+".A2_COD    and "
QRY1 := QRY1 + RetSQLName('SC7')+".C7_LOJA     = "+RetSQLName('SA2')+".A2_LOJA   and "
QRY1 := QRY1 + RetSQLName('SC7')+".C7_COND     = "+RetSQLName('SE4')+".E4_CODIGO and"

If mv_par09 == 1
	QRY1 := QRY1 +" C7_CONAPRO <> 'B' and"
ElseIf mv_par09 == 2
	QRY1 := QRY1 +" C7_CONAPRO = 'B' and"
Endif


If mv_par07 == 2
	QRY1 := QRY1 +" ( (C7_QUANT-C7_QUJE) > 0 ) and"
	QRY1 := QRY1 +" C7_RESIDUO = ' ' and"
ElseIf mv_par07 == 3
	QRY1 := QRY1 +" C7_RESIDUO <> ' ' and"
ElseIf mv_par07 == 4
	QRY1 := QRY1 +" C7_QUANT <= C7_QUJE and"
ElseIf mv_par07 == 5
	QRY1 := QRY1 +" C7_QUJE > 0 and"
Endif

If mv_par08 == 1
	QRY1 := QRY1 +" C7_TIPO = 1 "
ElseIf mv_par08 == 2
	QRY1 := QRY1 +" C7_TIPO = 2 "
ElseIf mv_par08 == 3	         
	QRY1 := QRY1 +" (C7_TIPO = 1 Or C7_TIPO = 2 ) "
Endif


QRY1 := QRY1 + ' group by '+ Iif(mv_par05==1,"C7_COND, E4_CODIGO, E4_DESCRI, C7_FORNECE, C7_LOJA, A2_NREDUZ ",'C7_COND, E4_CODIGO, E4_DESCRI, C7_EMISSAO, C7_DENTREG, C7_NUM, C7_FORNECE, C7_LOJA, A2_NREDUZ')

If MV_PAR10 == 1 .And. MV_PAR05 == 2
	QRY1 := QRY1 + ' order by C7_DENTREG'
Else
	QRY1 := QRY1 + ' order by '+ Iif(mv_par05==1,'SUM(C7_TOTAL)*-1','C7_EMISSAO, C7_FORNECE')
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

Return
       



///////////////////////////
Static Function RptDetail()
_cTitulo := "Pedidos de COMPRA "+Iif(mv_par05==1,'(S)','(A)')
_cDesc1  := Space(50)+'Periodo: '+dTOc(mv_par01)+" - "+dTOc(mv_par02)
If mv_par05 == 1
	_cDesc2  := "  Forncedor                                                                     Valor                     Valor+Imposto	"
	
Else
	                               
	_cDesc2  := "  Emissao      Prv.Entreg.    Pedido  Forncedor                       Tipo                  Valor                    Valor+Imposto"
	
EndIf
_nReg     := 0
_nTotal   := 0
_nTotalImp:= 0

dbSelectArea("QRY1")
QRY1->(dbGotop())



SetRegua(RecCount())


Do While QRY1->(!Eof())
	
	// If mv_par06 == 3 .AND. QRY1->C7_COND == '401'
	
	
	If (mv_par06 == 1).OR.;
		(mv_par06 == 2 .AND. !QRY1->C7_COND $ GETMV("ES_BEACOM")).OR.;
		(mv_par06 == 3 .AND.  QRY1->C7_COND $ GETMV("ES_BONCOM")).OR.;
		(mv_par06 == 4 .AND.  QRY1->C7_COND $ GETMV("ES_AMOCOM"))
		
		
		IncRegua( "Imprimindo: " + QRY1->A2_NREDUZ )
		
		If li > 58
			li := Cabec(_cTitulo,_cDesc1,_cDesc2,nomeprog,tamanho) + 1
		EndIf
		
		*                                                                                                   1                                                                                                   2                                                                                                   3
		*         1         2         3         4         5         6         7         8         9         0         1         2         3         4         5         6         7         8         9         0         1         2         3         4         5         6         7         8         9         0         1         2         3         4         5         6
		*1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
		* Emissao    Prv.Ente     Pedido    Forncedor                       Tipo              Valor                     Valor+Imposto
		* dd/mm/aaaa dd/mm/aaaa   999999    999999-99 12345678901234567890                999.999.999,99                999.999.999,99
		*                                                              Total: 999.999.999,99     Total+Imp: 999.999.999,99
		
		* Forncedor                                  Valor
		* 999999-99 12345678901234567890    999.999.999,99
		*                             Total:
		
		
		
		If mv_par05 == 1
			
			@ li,002 PSay QRY1->C7_FORNECE+'-'+QRY1->C7_LOJA+' '+QRY1->A2_NREDUZ
			@ li,075 PSay QRY1->C7_TOTAL   Picture "@E 999,999,999.99"
			@ li,105 PSay QRY1->C7_TOTAL_I Picture "@E 999,999,999.99"
		Else
			@ li,002 PSay SubStr(QRY1->C7_EMISSAO,7,2)+'/'+SubStr(QRY1->C7_EMISSAO,5,2)+'/'+SubStr(QRY1->C7_EMISSAO,1,4)
			@ li,015 PSay SubStr(QRY1->C7_DENTREG,7,2)+'/'+SubStr(QRY1->C7_DENTREG,5,2)+'/'+SubStr(QRY1->C7_DENTREG,1,4)			
			@ li,030 PSay QRY1->C7_NUM
			@ li,038 PSay QRY1->C7_FORNECE+'-'+QRY1->C7_LOJA+' '+QRY1->A2_NREDUZ
			@ li,070 PSAY Substr(QRY1->E4_DESCRI,1,5)
			@ li,085 PSay QRY1->C7_TOTAL   Picture "@E 999,999,999.99"
			@ li,115 PSay QRY1->C7_TOTAL_I Picture "@E 999,999,999.99"
		EndIf
		li++
		
		_nReg++
		
		_nTotal    += QRY1->C7_TOTAL
		_nTotalImp += QRY1->C7_TOTAL_I
		
	EndIf
	
	DbSelectArea("QRY1")
	QRY1->(dbSkip())
	
	
EndDo

If li <> 66
	li++
	@ li,000 PSay Replic("*",Limite)
	li++
	If mv_par05 == 1
		@ li,068 PSay 'Total:'
		@ li,075 PSay _nTotal Picture "@E 999,999,999.99"
		@ li,092 PSay 'Total+Imposto:'
		@ li,105 PSay _nTotalImp Picture "@E 999,999,999.99"
	Else
		@ li,078 PSay 'Total:'
		@ li,085 PSay _nTotal Picture "@E 999,999,999.99"
		@ li,102 PSay 'Total+Impo:'
		@ li,115 PSay _nTotalImp Picture "@E 999,999,999.99"
	EndIf
	li++
	@ li,000 PSay Replic("*",Limite)
	li+=2
	
	Roda(_nReg,if(_nReg=1,'Registro',"Registros"),Tamanho)
	//	Roda(cbcont,cbtxt,"G")
	
	
EndIf

Return(.T.)

/////////////////////////////////////////////////////////////////////////////
//
Static Function AjustaSX1(cPerg)
_sAlias := Alias()
dbSelectArea("SX1")
dbSetOrder(1)

aRegs:={}

//------------ Grupo/Ordem/Pergunta/PERGING/PERGESP/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05/F3

AADD(aRegs,{cPerg,"01","De data                    ?","","","mv_ch1","D",8,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","",""})
AADD(aRegs,{cPerg,"02","Ate data                   ?","","","mv_ch2","D",8,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","",""})
AADD(aRegs,{cPerg,"03","De Fornecedor              ?","","","mv_ch3","C",6,0,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","SA2"})
aAdd(aRegs,{cPerg,"04","Ate Fornecedor             ?","","","mv_ch4","C",6,0,0,"G","","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","","SA2"})
aAdd(aRegs,{cPerg,"05","Sintetico/Analitico        ?","","","mv_ch5","N",1,0,1,"C","","mv_par05","Sintetico","","","","","Analitico","","","","","","","",""})
aAdd(aRegs,{cPerg,"06","Pedido/Bonificacao/Amostra ?","","","mv_ch6","N",1,0,2,"C","","mv_par06","Todos","","","","","Pedido","","","","","Bonificacao","","","","","Amostra","","","",""})
aAdd(aRegs,{cPerg,"07","Lista Quais                ?","","","mv_ch7","N",1,0,2,"C","","mv_par07","Todos","","","","","Em Aberto","","","","","Residuos","","","","","Atendidos","","","","","Atendidos+Parcial Entreg","","","",""})
aAdd(aRegs,{cPerg,"08","Lista Quais Tipos          ?","","","mv_ch8","N",1,0,1,"C","","mv_par08","Pedido Compra","","","","","Aut.de Entrega","","","","","Ambos","","","",""})
aAdd(aRegs,{cPerg,"09","Imprime Pedidos            ?","","","mv_ch9","N",1,0,1,"C","","mv_par09","Liberados","","","","","Bloqueados","","","","","Ambos","","","",""})
aAdd(aRegs,{cPerg,"10","Ordenar Previsao Entrega   ?","","","mv_chA","N",1,0,1,"C","","mv_par10","Sim","","","","","Nao","","","","","","","","",""})
AADD(aRegs,{cPerg,"11","Previsao Entrega De        ?","","","mv_chB","D",8,0,0,"G","","mv_par11","","","","","","","","","","","","","","","","","","","","","","","","",""})
AADD(aRegs,{cPerg,"12","Previsao  Entrega Ate      ?","","","mv_chC","D",8,0,0,"G","","mv_par12","","","","","","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"13","Consolidado                ?","","","mv_chD","N",1,0,1,"C","","mv_par13","Sim","","","","","Nao","","","","","","","","",""})


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
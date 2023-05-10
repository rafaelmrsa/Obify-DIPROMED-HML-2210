/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Funcao    ³ DIPR024  ³ Autor ³ Eriberto Elias     ³ Data ³ 07/04/2003  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Relacao de pedidos que solicitou SENHA                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ DIPR024                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Especifico DIPROMED                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
#include "rwmake.ch"

User Function DIPR024()

Local _xArea   := GetArea()

Local titulo     := OemTOAnsi("Relacao de pedidos com SENHA...",72)
Local cDesc1     := (OemToAnsi("Este programa tem como objetivo emitir um relat¢rio",72))
Local cDesc2     := (OemToAnsi("com os pedidos com SENHA.",72))
Local cDesc3     := (OemToAnsi("Conforme parametros definidos pelo o usuario.",72))

Private aReturn    := {"Bco A4", 1,"Faturamento", 1, 2, 1,"",1}
Private li         := 66
Private tamanho    := "G"
Private limite     := 220
Private nomeprog   := "DIPR024"
Private nLastKey   := 0
Private lEnd       := .F.
Private wnrel      := "DIPR024"
Private cString    := "SC5"
Private m_pag      := 1
Private nReg       := 0

//Private cPerg      := "DIPR24"
// FPADR(cPerg, cArq, cCampo, cTipo)  - Para ajustar o tamanho das perguntas no SX1- uso generico
PRIVATE cPerg  	:= U_FPADR( "DIPR24","SX1","SX1->X1_GRUPO"," " ) //Função criada por Sandro em 19/11/09.


U_DIPPROC(ProcName(0),U_DipUsr()) // JBS 05/10/2005 - Gravando o nome do Programa no SZU

AjustaSX1(cPerg)           // Verifica perguntas. Se nao existe INCLUI

If !Pergunte(cPerg,.T.)     // Solicita parametro
	Return
EndIf

//wnrel := SetPrint(cString,wnrel,cPerg,Titulo,cDesc1,cDesc2,cDesc3,.F.)
wnrel := SetPrint(cString,wnrel,cPerg,Titulo,cDesc1,cDesc2,cDesc3,.f.,,.f.,tamanho,,.f.,,,,,)
/*Informado ao analista que poderá utilizar o 13o. parâmetro da função setprint com .f.
que irá          TI0617 FERNANDO JOSE     TI0917 MARCIA            09/04/03 13:51
desabilitar o filtro..Segue abaixo sintaxe da função
setprint:..Function SetPrint(cAlias,cNome,cPerg,cDesc,cCnt1,cCnt2,cCnt3,lDic,aOrd,
lCompres,cSize,aFilter,lFiltro,lCrystal,cNameDrv,lNoAsk,lServer,cPortToPrint)
*/

If nLastKey == 27
	Return
Endif

SetDefault(aReturn,cString)

RptStatus({|lEnd| RodaRel()},Titulo)

Set device to Screen

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se em disco, desvia para Spool                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If aReturn[5] == 1    // Se Saida para disco, ativa SPOOL
	Set Printer TO
	Commit
	ourspool(wnrel)
Endif

RestArea(_xArea)

Return

//////////////////////////////////////////////////////////////////////
Static Function RodaRel()
Local _lIgual    := .F.
Local _cPedido   := ''

/*
*/

QRY1 := "select DISTINCT Z9_PEDIDO"
QRY1 += " C5_NUM, C5_EMISSAO, C5_CLIENTE, C5_LOJACLI, C5_OPERADO,  C5_MARGATU, C5_MARGLIB, C5_SENHMAR, C5_SENHPAG, C5_EXPLSEN, C5_DATA1, C5_PARC1, C5_DATA2, C5_PARC2, C5_DATA3, C5_PARC3, C5_DATA4, C5_PARC4, C5_DATA5, C5_PARC5, C5_DATA6, C5_PARC6 "
QRY1 += " C6_PRODUTO, C6_MARGATU, C6_MARGITE, C6_QTDVEN, C6_PRCVEN, C6_CUSTO, C6_PRCMIN, C6_NOTA, C6_VALOR,"
//QRY1 += " B1_DESC, B1_UCOM, B1_UPRC+(B1_UPRC*B1_IPI/100) B1_UPRC, B1_PRVMINI, B1_PRVSUPE, B1_ALTPREC,"
//QRY1 += " B1_DESC, B1_UCOM, (B1_CUSDIP) B1_UPRC, B1_PRVMINI, B1_PRVSUPE, B1_ALTPREC,"  // Alterado de B1_UPRC+IPI p/ B1_CUSDIP - MCVN 30/10/2008
//QRY1 += " B1_DESC, B1_UCOM, (B1_LISFOR) B1_UPRC, B1_PRVMINI, B1_PRVSUPE, B1_ALTPREC,"  // Alterado de B1_CUSDIP p/ B1_LISFOR - MCVN 26/03/2009  
QRY1 += " B1_DESC, B1_UCOM, (B1_CUSDIP) B1_UPRC, B1_PRVMINI, B1_PRVSUPE, B1_ALTPREC,"  // Alterado de B1_LISFOR p/ B1_CUSDIP - MCVN 02/04/2009
QRY1 += " A1_NOME,"
QRY1 += " U7_NREDUZ,"
QRY1 += " E4_CODIGO, E4_DESCRI, E4_INFER"
QRY1 += " FROM " + RetSQLName("SZ9")+', '+RetSQLName("SC5")+', '+ RetSQLName("SC6")+', '+ RetSQLName("SB1")+', '+RetSQLName("SA1")+', '+RetSQLName("SU7")+', '+RetSQLName("SE4")
QRY1 += " WHERE "
QRY1 += RetSQLName('SZ9')+".Z9_FILIAL = '"+xFilial('SZ9')+"' and "
QRY1 += RetSQLName('SC5')+".C5_FILIAL = '"+xFilial('SC5')+"' and "
QRY1 += RetSQLName('SC6')+".C6_FILIAL = '"+xFilial('SC6')+"' and "
QRY1 += RetSQLName('SE4')+".E4_FILIAL = '"+xFilial('SE4')+"' and "
QRY1 += RetSQLName('SZ9')+".D_E_L_E_T_ <> '*' and "
QRY1 += RetSQLName('SC5')+".D_E_L_E_T_ <> '*' and "
QRY1 += RetSQLName('SC6')+".D_E_L_E_T_ <> '*' and "
QRY1 += RetSQLName('SE4')+".D_E_L_E_T_ <> '*' and "
QRY1 += RetSQLName('SZ9')+".Z9_TIPMOV = 'SENHA' and "
QRY1 += RetSQLName('SZ9')+".Z9_DATAMOV between '"+DTOS(mv_par01)+"' and '"+DTOS(mv_par02)+"' and "
QRY1 += RetSQLName('SZ9')+".Z9_HORAMOV between '"+mv_par03+"' and '"+mv_par04+"' and "
QRY1 += RetSQLName('SZ9')+".Z9_PEDIDO = "+RetSQLName('SC5')+".C5_NUM and "
QRY1 += RetSQLName('SC5')+".C5_NUM = "+RetSQLName('SC6')+".C6_NUM and "
QRY1 += RetSQLName('SC5')+".C5_CLIENTE = "+RetSQLName('SA1')+".A1_COD and "
QRY1 += RetSQLName('SC5')+".C5_LOJACLI = "+RetSQLName('SA1')+".A1_LOJA and "
QRY1 += RetSQLName('SC5')+".C5_OPERADO = "+RetSQLName('SU7')+".U7_COD and "

//ALTERAR AQUI 25/03/09
//QRY1 += 'U7_CODVEN <> SPACE(6) AND '

If MV_PAR05 == 1 // APOIO    // MCVN - 26/03/2009
	QRY1 += 'U7_POSTO = 01 AND '
ElseIf MV_PAR05 == 2 // TELEVENDAS
	QRY1 += 'U7_CODVEN <> SPACE(6) AND '
Endif


QRY1 += RetSQLName('SC5')+".C5_CONDPAG = "+RetSQLName('SE4')+".E4_CODIGO and ("
QRY1 += RetSQLName('SC6')+".C6_QTDVEN <> "+RetSQLName('SC6')+".C6_QTDENT or "
QRY1 += RetSQLName('SC5')+".C5_EMISSAO between '"+DTOS(mv_par01)+"' and '"+DTOS(mv_par02)+"') and "
QRY1 += RetSQLName('SC6')+".C6_PRODUTO = "+RetSQLName('SB1')+".B1_COD "
QRY1 += "order by Z9_PEDIDO"
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

SetRegua(RecCount())

_cTitulo := "Relacao de pedidos com SENHA  -  De: "+DTOC(mv_par01)+' '+mv_par03+'  Ate: '+DTOC(mv_par02)+' '+mv_par04
_cDesc1  := "                              Margens         Quem liberou?"
_cDesc2  := "Pedido    Emissao         Atual  Liberacao    Margem      Pagamento     Explicacao"

_cPedido := QRY1->C5_NUM

_lCabProd := .T.
_lCabCond := !(Empty(QRY1->C5_SENHPAG))
_nTotalPed:= 0

nReg    := 0

Do While QRY1->(!Eof())
	
	IncRegua( "Imprimindo... ")
	
	If li > 60
		li := Cabec(_cTitulo,_cDesc1,_cDesc2,nomeprog,tamanho) + 1
	EndIf
	*                                                                                                   1         1         1         1         1         1         1         1         1         1         2         2         2
	*          1         2         3         4         5         6         7         8         9         0         1         2         3         4         5         6         7         8         9         0         1         2
	*01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
	*                              Margens         Quem liberou?
	*Pedido    Emissao         Atual  Liberacao    Margem      Pagamento     Explicacao
	*999999    99/99/9999    999,999  999,999      xxxxxxxxxx  xxxxxxxxxx    1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
	*Cliente: 999999-99 1234567890123456789012345678901234567890123456789012345678901  -  Operador: 999999-123456789012345
	
	If !_lIgual
		@ li,000 PSay QRY1->C5_NUM
		@ li,010 PSay SubStr(QRY1->C5_EMISSAO,7,2)+'/'+SubStr(QRY1->C5_EMISSAO,5,2)+'/'+SubStr(QRY1->C5_EMISSAO,1,4)
		@ li,024 PSay QRY1->C5_MARGATU*20 PICTURE '@E 999.999'
		@ li,033 PSay QRY1->C5_MARGLIB*20 PICTURE '@E 999.999'
		@ li,046 PSay QRY1->C5_SENHMAR
		@ li,058 PSay QRY1->C5_SENHPAG
		@ li,072 PSay QRY1->C5_EXPLSEN
		li := li+1
		@ li,000 PSay 'Cliente: '+QRY1->C5_CLIENTE+'-'+QRY1->C5_LOJACLI+' '+QRY1->A1_NOME
		@ li,081 PSay '-'
		@ li,084 PSay 'Operador: '+QRY1->C5_OPERADO+' - '+QRY1->U7_NREDUZ
		li++
		@ li,000 Psay Replicate('-',220)
		li++
		
		_lCabProd := .T.
		
	EndIf
	*                                                                                                    1         1         1         1         1         1         1         1         1         1         2         2         2
	*          1         2         3         4         5         6         7         8         9         0         1         2         3         4         5         6         7         8         9         0         1         2
	*01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
	*                                                                              Margens
	*  Produto                                                                 Atual  Liberacao      Quantidade        Preco   Menor Preco        Custo   Ultima Entrada  Ultima Alteracao  Nota
	*  999999 123456789012345678901234567890123456789012345678901234567890   999,999  999,999       999.999.999 999.999,9999  999.999,9999 999.999,9999   99/99/9999      99/99/9999        999999
// Eriberto 25/03/09
//	If QRY1->C6_MARGATU < QRY1->C6_MARGITE
		If _lCabProd
			@ li,000 Psay '                                                                              Margens'
			li++
			@ li,000 Psay '  Produto                                                                 Atual  Liberacao      Quantidade        Preco   Menor Preco        Custo   Ultima Entrada  Ultima Alteracao  Nota'
			li++
			@ li,000 Psay Replicate('=',220)
			li++
			_lCabProd := .F.
		EndIf
		@ li,002 PSay SUBSTR(QRY1->C6_PRODUTO,1,6)
		@ li,009 PSay QRY1->B1_DESC
		@ li,072 PSay QRY1->C6_MARGATU*20 PICTURE '@E 999.999'
		@ li,081 PSay QRY1->C6_MARGITE*20 PICTURE '@E 999.999'
		@ li,095 PSay QRY1->C6_QTDVEN     PICTURE '@E 999,999,999'
		@ li,107 PSay QRY1->C6_PRCVEN     PICTURE '@E 999,999.9999'
		@ li,121 PSay Iif(QRY1->B1_PRVSUPE==0,QRY1->B1_PRVMINI,QRY1->B1_PRVSUPE) PICTURE '@E 999,999.9999'
		@ li,134 PSay QRY1->C6_CUSTO      PICTURE '@E 999,999.9999'
		@ li,149 PSay SubStr(QRY1->B1_UCOM,7,2)+'/'+SubStr(QRY1->B1_UCOM,5,2)+'/'+SubStr(QRY1->B1_UCOM,1,4)
		@ li,165 PSay SubStr(QRY1->B1_ALTPREC,7,2)+'/'+SubStr(QRY1->B1_ALTPREC,5,2)+'/'+SubStr(QRY1->B1_ALTPREC,1,4)
		@ li,183 PSay QRY1->C6_NOTA PICTURE '999999'
		li++
//	EndIf
	
	nReg++
	//Inclusao dos campos PARC5 e 6
	_nTotalPed := _nTotalPed + QRY1->C6_VALOR
	_lCabCond := !(Empty(QRY1->C5_SENHPAG))
	_dDATA1 := QRY1->C5_DATA1
	_dDATA2 := QRY1->C5_DATA2
	_dDATA3 := QRY1->C5_DATA3
	_dDATA4 := QRY1->C5_DATA4
	_dDATA5 := QRY1->C5_DATA5
	_dDATA6 := QRY1->C5_DATA6
	_nPARC1 := QRY1->C5_PARC1
	_nPARC2 := QRY1->C5_PARC2
	_nPARC3 := QRY1->C5_PARC3
	_nPARC4 := QRY1->C5_PARC4
	_nPARC5 := QRY1->C5_PARC5
	_nPARC6 := QRY1->C5_PARC6
	_cE4_CODIGO := QRY1->E4_CODIGO
	_cE4_DESCRI := QRY1->E4_DESCRI
	_nE4_INFER  := QRY1->E4_INFER
	
	QRY1->(DbSkip())
	
	If _cPedido == QRY1->C5_NUM
		_lIgual := .T.
	Else
		@ li,000 Psay Replicate('*',220)
		li++
		li++
		_lIgual := .F.
		_cPedido := QRY1->C5_NUM
		
		*                                                                                                    1         1         1         1         1         1         1         1         1         1         2         2         2
		*          1         2         3         4         5         6         7         8         9         0         1         2         3         4         5         6         7         8         9         0         1         2
		*01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
		*  Condicao de Pagamento             Valor Minimo Total do Pedido               1a. Parcela              2a. Parcela              3a. Parcela              4a. Parcela
		*  999 - 1234567890123456789012345 999.999.999,99  999.999.999,99   999.999,99 - 99/99/9999  999.999,99 - 99/99/9999  999.999,99 - 99/99/9999  999.999,99 - 99/99/9999
		If _lCabCond
			@ li,000 Psay '  Condicao de Pagamento             Valor Minimo Total do Pedido'
			If !(Empty(_dDATA1))
				@ li,079 Psay '1a. Parcela'
			EndIf
			If !(Empty(_dDATA2))
				@ li,104 Psay '2a. Parcela'
			EndIf
			If !(Empty(_dDATA3))
				@ li,129 Psay '3a. Parcela'
			EndIf
			If !(Empty(_dDATA4))
				@ li,154 Psay '4a. Parcela'
			EndIf
			If !(Empty(_dDATA5))
				@ li,179 Psay '5a. Parcela'
			EndIf
			If !(Empty(_dDATA6))
				@ li,204 Psay '6a. Parcela'
			EndIf
			li++
			@ li,000 Psay Replicate('=',220)
			li++
			@ li,002 PSay _cE4_CODIGO
			@ li,009 PSay _cE4_DESCRI
			@ li,034 PSay _nE4_INFER   PICTURE '@E 999,999,999.99'
			@ li,050 PSay _nTotalPed   PICTURE '@E 999,999,999.99'
			If !(Empty(_dDATA1))
				@ li,067 PSay _nPARC1  PICTURE '@E 999,999.99'
				@ li,080 PSay SubStr(_dDATA1,7,2)+'/'+SubStr(_dDATA1,5,2)+'/'+SubStr(_dDATA1,1,4)
			EndIf
			If !(Empty(_dDATA2))
				@ li,092 PSay _nPARC2  PICTURE '@E 999,999.99'
				@ li,105 PSay SubStr(_dDATA2,7,2)+'/'+SubStr(_dDATA2,5,2)+'/'+SubStr(_dDATA2,1,4)
			EndIf
			If !(Empty(_dDATA3))
				@ li,117 PSay _nPARC3  PICTURE '@E 999,999.99'
				@ li,130 PSay SubStr(_dDATA3,7,2)+'/'+SubStr(_dDATA3,5,2)+'/'+SubStr(_dDATA3,1,4)
			EndIf
			If !(Empty(_dDATA4))
				@ li,142 PSay _nPARC4  PICTURE '@E 999,999.99'
				@ li,155 PSay SubStr(_dDATA4,7,2)+'/'+SubStr(_dDATA4,5,2)+'/'+SubStr(_dDATA4,1,4)
			EndIf
			If !(Empty(_dDATA5))
				@ li,142 PSay _nPARC5  PICTURE '@E 999,999.99'
				@ li,155 PSay SubStr(_dDATA5,7,2)+'/'+SubStr(_dDATA5,5,2)+'/'+SubStr(_dDATA5,1,4)
			EndIf
			If !(Empty(_dDATA6))
				@ li,142 PSay _nPARC6  PICTURE '@E 999,999.99'
				@ li,155 PSay SubStr(_dDATA6,7,2)+'/'+SubStr(_dDATA6,5,2)+'/'+SubStr(_dDATA6,1,4)
			EndIf
			li++
			@ li,000 Psay Replicate('*',220)
			li++
			li++
		EndIf
	
		_nTotalPed := 0
		
	EndIf
	
EndDo

li++
If li <> 80
	Roda(nREG,Iif(nReg=1,'Registro impresso',"Registros impressos"),tamanho)
EndIf

dbSelectArea("QRY1")
QRY1->(dbCloseArea())

Return(.T.)

/////////////////////////////////////////////////////////////////////////////
Static Function AjustaSX1(cPerg)
Local i,j

_sAlias := Alias()
dbSelectArea("SX1")
dbSetOrder(1)

aRegs:={}

//------------ Grupo/Ordem/Pergunta/PERGING/PERGESP/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05/F3

aAdd(aRegs,{cPerg,"01","Data de            ?","","","mv_ch1","D",8,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"02","Data ate           ?","","","mv_ch2","D",8,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"03","Hora de            ?","","","mv_ch3","C",8,0,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"04","Hora ate           ?","","","mv_ch4","C",8,0,0,"G","","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","","",""})
AADD(aRegs,{cPerg,"05","Informe o setor    ?","","","mv_ch5","N",1,0,0,"C","","mv_par05","1-Apoio","","","","","2-Call Center","","","","","3-Ambos","","",""})

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

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Funcao    ³ DIPR048  ³ Autor ³ RAFAEL DE CAMPOS FALCO³ Data ³ 12/05/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Controle de Estoque                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ DIPR048                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Especifico DIPROMED                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
#include "rwmake.ch"
#INCLUDE "TBICONN.CH"
#INCLUDE "FILEIO.CH"

User Function DIPR048()
Local _xArea		:= GetArea()
Local titulo		:= OemTOAnsi("Levantamento do Estoque - Por Período",72)
Local cDesc1		:= (OemToAnsi("Este programa tem como objetivo emitir um relat¢rio",72))
Local cDesc2		:= (OemToAnsi("com levantamento do estoque por período.",72))
Local cDesc3		:= (OemToAnsi("Conforme parametros definidos pelo o usuario.",72))
Local	_dDatIn		:= ""
Local	_dDatFim	:= ""
Private aPar2		:= ""
Private aReturn		:= {"Bco A4", 1,"Administracao", 1, 2, 1,"",1}
Private li			:= 67
Private tamanho		:= "G"
Private limite		:= 220
Private nomeprog	:= "DIPR048"   

//Private cPerg		:= "DIPR48"
// FPADR(cPerg, cArq, cCampo, cTipo)  - Para ajustar o tamanho das perguntas no SX1- uso generico
PRIVATE cPerg  	:= U_FPADR( "DIPR48","SX1","SX1->X1_GRUPO"," " ) //Função criada por Sandro em 19/11/09.

Private nLastKey	:= 0
Private lEnd		:= .F.
Private wnrel		:= "DIPR048"
Private cString		:= "SD2"
Private m_pag		:= 1
Private cWorkFlow	:= ""

U_DIPPROC(ProcName(0),U_DipUsr()) // JBS 05/10/2005 - Gravando o nome do Programa no SZU

/*
If AllTrim(Upper(U_DipUsr())) <> 'ERIBERTO'
If AllTrim(Upper(U_DipUsr())) <> 'FALCO'
MSGSTOP("Voce nao é o Eriberto","Usuario sem autorizacao!")
Return
EndIf
EndIf
*/

AjustaSX1(cPerg)           // Verifica perguntas. Se nao existe INCLUI.

If !Pergunte(cPerg,.T.)    // Solicita parametros
	Return
EndIf

wnrel := SetPrint(cString,wnrel,cPerg,Titulo,cDesc1,cDesc2,cDesc3,.f.,,.f.,tamanho,,.f.,,,,,)

If nLastKey == 27
	Return
Endif

SetDefault(aReturn,cString)

Processa({|lEnd| RunProc48()},"Calculando Estoque Atual...")

RptStatus({|lEnd| RodaRel48()},"Imprimindo Estoque Atual...")

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
Static Function RunProc48()

ProcRegua(150)
For _x := 1 to 50
	IncProc( "Processando dados do banco... ")
Next

/*
SELECT D3_USUARIO, D3_COD, B1_DESC, D3_EMISSAO, D3_QUANT, D3_DOC, D3_CUSTO1, D3_TM, F5_TEXTO, D3_LOTECTL, D3_NUMLOTE, D3_DTVALID, D3_LOCALIZ, D3_EXPLIC
FROM SD3010, SB1010, SF5010
WHERE D3_EMISSAO BETWEEN '20040201' AND '20040231'
AND D3_FILIAL = '04'
AND D3_COD BETWEEN '' AND 'ZZZZZZ'
AND B1_PROC BETWEEN '000338' AND '000338'
AND D3_COD = B1_COD
AND D3_TM = F5_CODIGO
AND D3_ESTORNO <> 'S'
AND SD3010.D_E_L_E_T_ <> '*'
AND SB1010.D_E_L_E_T_ <> '*'
AND SF5010.D_E_L_E_T_ <> '*'
ORDER BY D3_COD, D3_EMISSAO
*/

QRY1 := " SELECT D3_USUARIO, D3_COD, B1_DESC, D3_EMISSAO, D3_QUANT, D3_DOC, D3_CUSTO1, D3_TM, F5_TEXTO, D3_LOTECTL, D3_NUMLOTE, D3_DTVALID, D3_LOCALIZ, D3_EXPLIC, D3_LOCAL"
QRY1 += " FROM " + RetSQLName("SD3") + " SD3 with (nolock)"

QRY1 += " inner join " + RetSQLName("SB1") + " SB1 with (nolock)"
QRY1 += "    on  SB1.D_E_L_E_T_ = ''"
QRY1 += "    and '" + xFilial("SB1") +"' = SB1.B1_FILIAL"   
QRY1 += "    and SD3.D3_COD = SB1.B1_COD"
QRY1 += "    and SB1.B1_PROC BETWEEN '" + MV_PAR06 + "' AND '" + MV_PAR07 + "'"

QRY1 += " left join " + RetSQLName("SF5") + " SF5 with (nolock)"
QRY1 += "    on  SF5.D_E_L_E_T_ = ''"
QRY1 += "    and '" + xFilial("SF5") +"' = SF5.F5_FILIAL"
QRY1 += "    and SD3.D3_TM = SF5.F5_CODIGO"

QRY1 += " WHERE SD3.D_E_L_E_T_ = '' "
QRY1 += "    and SD3.D3_EMISSAO BETWEEN '" + DTOS(MV_PAR01) + "' AND '" + DTOS(MV_PAR02) + "'"
QRY1 += "    and '" + xFilial("SD3") +"' = SD3.D3_FILIAL"

QRY1 += "    and SD3.D3_COD BETWEEN '" + MV_PAR03 + "' AND '" + MV_PAR04 + "'"
QRY1 += "    and SD3.D3_ESTORNO <> 'S'"
QRY1 += "    and SD3.D3_TM BETWEEN '" + MV_PAR09 + "' AND '" + MV_PAR10 + "'" //FELIPE DURAN - 17/11/19

IF MsgBox("Ignora transferência automática?","Atencao","YESNO")  // MCVN - 22/01/09
	QRY1 += "    and SD3.D3_NUMSEP = ''" // Eriberto 22/01/09 ignora as transferencias automáticas
ENDIF


If MV_PAR05 == 1
	QRY1 += " ORDER BY D3_COD, D3_EMISSAO"
ElseIf MV_PAR05 == 2
	QRY1 += " ORDER BY D3_DOC, D3_EMISSAO"
ElseIf MV_PAR05 == 3
	QRY1 += " ORDER BY B1_DESC, D3_EMISSAO"
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

ProcRegua(150)
For _x := 1 to 150
	IncProc( "Fim do Processando... ")
Next

Return(.T.)



//////////////////////////////////////////////////////////////////////
Static Function RodaRel48()
Local cCod_Pro 	:= ""
Local cWorkFlow	:= "N"
Local _cTitulo	:= "Movimentação Interna - " + Iif(AllTrim(MV_PAR03)==""," Todos Produtos ", ("do código " + MV_PAR03 + " até " + MV_PAR04)) + " - " + "Período de " + Substr(DtoS(MV_PAR01),7,2) + "/" + Substr(DtoS(MV_PAR01),5,2) + "/" + Substr(DtoS(MV_PAR01),1,4) +" até " + Substr(DtoS(MV_PAR02),7,2)+ "/" + Substr(DtoS(MV_PAR02),5,2) + "/" + Substr(DtoS(MV_PAR02),1,4) + " - Ordenado por " + Iif(MV_PAR05 == 1,"Código", Iif(MV_PAR05 == 2, "Documento","Descrição"))
Local _cDesc1	:= ""
Local _cDesc2	:= ""

If MV_PAR05 == 1
	_cDesc1	:= "  Código - Produto"
	_cDesc2	:= "  Tipo Movimentação                Emissão                Quantidade                Documento                Custo                Lote                Validade                Local-Localização          Usuário"
Else
	_cDesc1	:= "  Código-Produto                                                                 Tipo Movimentação                      Emissão        Quant.    Documento       Custo  Lote       Validade    Local-Localiz.    Usuário"
	If MV_PAR08 == 1
		_cDesc2	:= "  Explicação"
	Else
		_cDesc2	:= " "
	EndIf
EndIf

*0                                                                                                   1                                                                                                   2
*0         1         2         3         4         5         6         7         8         9         0         1         2         3         4         5         6         7         8         9         0         1         2
*01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
*-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*  Código - Produto
*  Tipo Movimentação                Emissão                Quantidade                Documento                Custo                Lote                Validade                Localização                Usuário
*-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*  999999 - XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
*  999 - XXXXXXXXXXXXXXXXXXXX       99/99/9999             99.999.999                999999           99.999.999,99                999999              99/99/9999              999999                     XXXXXXXXXXXXXX
*-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*  Código-Produto                                                                           Tipo Movimentação                      Emissão        Quant.    Documento       Custo  Lote       Validade    Local.  Usuário
*-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*  999999-XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX   999-XXXXXXXXXXXXXXXXXXXX      99/99/9999     999.999   999999    999.999,99  999999  99/99/9999  999999  XXXXXXXXXXXXXX
*-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


DbSelectArea("QRY1")
QRY1->(DbGoTop())
Do While QRY1->(!Eof())
	
	If lAbortPrint
		@ li+1,00 PSAY "*** CANCELADO PELO OPERADOR ***"
		Exit
	Endif
	
	If li > 65
		li := Cabec(_cTitulo,_cDesc1,_cDesc2,nomeprog,tamanho) + 1
	EndIf
	
	If MV_PAR05 == 1
		If cCod_Pro != QRY1->D3_COD
			If li > 10
				@ li,000 PSay Replicate("-",220)
				li++
			EndIf
			cCod_Pro := QRY1->D3_COD
			@ li,002 PSay AllTrim(QRY1->D3_COD) + " - " + QRY1->B1_DESC
			li++
		EndIf
		
		@ li,002 PSay QRY1->D3_TM + " - " + QRY1->F5_TEXTO
		@ li,035 PSay SubStr(QRY1->D3_EMISSAO,7,2) + "/" + SubStr(QRY1->D3_EMISSAO,5,2) + "/" + SubStr(QRY1->D3_EMISSAO,1,4)
		@ li,058 PSay Transform(QRY1->D3_QUANT , "@E 99,999,999")
		@ li,084 PSay QRY1->D3_DOC
		@ li,101 PSay Transform(QRY1->D3_CUSTO1, "@E 99,999,999.99")
		@ li,130 PSay QRY1->D3_LOTECTL
		@ li,150 PSay SubStr(QRY1->D3_DTVALID,7,2) + "/" + SubStr(QRY1->D3_DTVALID,5,2) + "/" + SubStr(QRY1->D3_DTVALID,1,4)
		@ li,174 PSay QRY1->D3_LOCAL +"-"+QRY1->D3_LOCALIZ
		@ li,201 PSay QRY1->D3_USUARIO
		li++
		
		If MV_PAR08 == 1
			@ li,002 PSay QRY1->D3_EXPLIC
			li++
		EndIf
	Else
		@ li,002 PSay Alltrim(QRY1->D3_COD) + "-" + Alltrim(QRY1->B1_DESC)
		@ li,081 PSay Alltrim(QRY1->D3_TM)  + "-" + Alltrim(QRY1->F5_TEXTO)
		@ li,120 PSay SubStr(QRY1->D3_EMISSAO,7,2) + "/" + SubStr(QRY1->D3_EMISSAO,5,2) + "/" + SubStr(QRY1->D3_EMISSAO,1,4)
		@ li,135 PSay Transform(QRY1->D3_QUANT , "@E 999,999")
		@ li,145 PSay Iif(Empty(QRY1->D3_DOC),Space(06),Alltrim(QRY1->D3_DOC))
		@ li,156 PSay Transform(QRY1->D3_CUSTO1, "@E 999,999.99")
		@ li,168 PSay Iif(Empty(QRY1->D3_LOTECTL),Space(06),Alltrim(QRY1->D3_LOTECTL))
		@ li,179 PSay SubStr(QRY1->D3_DTVALID,7,2) + "/" + SubStr(QRY1->D3_DTVALID,5,2) + "/" + SubStr(QRY1->D3_DTVALID,1,4)
		@ li,191 PSay Iif(Empty(QRY1->D3_LOCALIZ),Space(06),Alltrim(QRY1->D3_LOCAL+"-"+QRY1->D3_LOCALIZ))
		@ li,209 PSay Iif(Empty(QRY1->D3_USUARIO),Space(06),Alltrim(QRY1->D3_USUARIO))
		li++
		
		If MV_PAR08 == 1
			@ li,002 PSay QRY1->D3_EXPLIC
			li++
		EndIf
		
	EndIf
	
	QRY1->(DbSkip())
	
EndDo

If li > 56
	li := Cabec(_cTitulo,_cDesc1,_cDesc2,nomeprog,tamanho) + 1
EndIf
@ li,000 PSay Replicate("-",220)
li++

If li > 56
	li := u_MYCabec(_cTitulo,_cDesc1,_cDesc2,nHandle,cWorkFlow)
EndIf

dbSelectArea("QRY1")
QRY1->(dbCloseArea())
Return(.T.)

/////////////////////////////////////////////////////////////////////////////
Static Function AjustaSX1(cPerg)
_sAlias := Alias()

dbSelectArea("SX1")
dbSetOrder(1)

aRegs	:=	{}
//------------ Grupo/Ordem/Pergunta/PERGING/PERGESP/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05/F3
aAdd(aRegs,{cPerg,"01","Emissao de         ?","","","mv_ch1","D",8,0,0,"G","","MV_PAR01","","","","","","","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"02","Emissao ate        ?","","","mv_ch2","D",8,0,0,"G","","MV_PAR02","","","","","","","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"03","Do Produto         ?","","","mv_ch3","C",6,0,0,"G","","MV_PAR03","","","","","","","","","","","","","","","","","","","","","","","","","SB1","",""})
aAdd(aRegs,{cPerg,"04","Até Produto        ?","","","mv_ch4","C",6,0,0,"G","","MV_PAR04","","","","","","","","","","","","","","","","","","","","","","","","","SB1","",""})
aAdd(aRegs,{cPerg,"05","Ordenar por        ?","","","mv_ch5","N",1,0,0,"C","","MV_PAR05","1-Código","","","","","2-Documento","","","","","3-Descrição","","",""})
aAdd(aRegs,{cPerg,"06","Do Fornecedor      ?","","","mv_ch6","C",6,0,0,"G","","MV_PAR06","","","","","","","","","","","","","","","","","","","","","","","","","SA2","",""})
aAdd(aRegs,{cPerg,"07","Até Fornecedor     ?","","","mv_ch7","C",6,0,0,"G","","MV_PAR07","","","","","","","","","","","","","","","","","","","","","","","","","SA2","",""})
aAdd(aRegs,{cPerg,"08","Imprime Explicação ?","","","mv_ch8","N",1,0,2,"C","","MV_PAR08","1-Sim"   ,"","","","","2-Não"      ,"","","","",""           ,"","",""})
aAdd(aRegs,{cPerg,"09","Tipo Mov. De       ?","","","mv_ch9","C",3,0,0,"G","","MV_PAR09","","","","","","","","","","","","","","","","","","","","","","","","","SF5","",""}) //FELIPE DURAN - 17/11/19
aAdd(aRegs,{cPerg,"10","Tipo Mov. Até      ?","","","mv_chA","C",3,0,0,"G","","MV_PAR10","","","","","","","","","","","","","","","","","","","","","","","","","SF5","",""})//FELIPE DURAN - 17/11/19

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
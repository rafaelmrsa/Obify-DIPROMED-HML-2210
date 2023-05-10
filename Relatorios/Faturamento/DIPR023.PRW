/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Funcao    ³ DIPR023  ³ Autor ³ Eriberto Elias     ³ Data ³ 28/03/2003  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Relacao de baixas por vendedor e total por mes de emissao  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ DIPR023                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Especifico DIPROMED                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

#include "rwmake.ch"

User Function DIPR023()

Local _xArea   := GetArea()

Local titulo     := OemTOAnsi("Relacao de recebimentos por vendedor...",72)
Local cDesc1     := (OemToAnsi("Este programa tem como objetivo emitir um relat¢rio",72))
Local cDesc2     := (OemToAnsi("com os recebimentos por vendedor e totalizando por mes.",72))
Local cDesc3     := (OemToAnsi("Conforme parametros definidos pelo o usuario.",72))

Private aReturn    := {"Bco A4", 1,"Estoques", 1, 2, 1,"",1}
Private li         := 67
Private tamanho    := "G"
Private limite     := 220
Private nomeprog   := "DIPR023"
Private nLastKey   := 0
Private lEnd       := .F.
Private wnrel      := "DIPR023"
Private cString    := "SE1"
Private m_pag      := 1

//Private cPerg      := "DIPR23"
// FPADR(cPerg, cArq, cCampo, cTipo)  - Para ajustar o tamanho das perguntas no SX1- uso generico
PRIVATE cPerg  	:= U_FPADR( "DIPR023","SX1","SX1->X1_GRUPO"," " ) //Função criada por Sandro em 19/11/09.


U_DIPPROC(ProcName(0),U_DipUsr()) // JBS 05/10/2005 - Gravando o nome do Programa no SZU

AjustaSX1(cPerg)             // Verifica perguntas. Se nao existe INCLUI

If !Pergunte(cPerg,.T.)     // Solicita parametro
	Return
EndIf

wnrel := SetPrint(cString,wnrel,cPerg,Titulo,cDesc1,cDesc2,cDesc3,.T.)

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
Local _nSubTotal := 0
Local _nTotal    := 0
Local _lIgual    := .F.
Local _cMesAno   := ''

/*
select E1_PREFIXO, E1_NUM, E1_PARCELA, E1_PEDIDO, E1_CLIENTE, E1_LOJA , E1_NOMCLI, E1_EMISSAO, E1_VENCREA, E1_BAIXA, E1_VEND1, E1_COMIS1, E1_VALOR, E1_SALDO, A3_NOME, E5_MOTBX
FROM SE1010, SA3010, SE5010
WHERE 
SE1010.E1_FILIAL = '01' and 
SE1010.D_E_L_E_T_ <> '*' and
SE5010.D_E_L_E_T_ <> '*' and
SE1010.E1_VEND1 = '000193' and
SE1010.E1_BAIXA between '20030301' and '20030331' and
SE1010.E1_VEND1 = SA3010.A3_COD and
SE1010.E1_PREFIXO = SE5010.E5_PREFIXO and
SE1010.E1_NUM     = SE5010.E5_NUMERO and 
SE1010.E1_PARCELA = SE5010.E5_PARCELA and 
SE1010.E1_CLIENTE = SE5010.E5_CLIFOR and 
SE1010.E1_LOJA    = SE5010.E5_LOJA and
SE5010.E5_MOTBX <> 'DAC'
order by E1_EMISSAO, E1_NUM
*/        

QRY1 :=        " select E1_PREFIXO, E1_NUM, E1_PARCELA, E1_PEDIDO, E1_CLIENTE, E1_LOJA , E1_NOMCLI, E1_EMISSAO, E1_VENCREA, E1_BAIXA, E1_VEND1, E1_COMIS1, E1_VALOR, E1_SALDO, A3_NOME "
QRY1 := QRY1 + " FROM " + RetSQLName("SE1")+', '+ RetSQLName("SA3")  // ', '+RetSQLName("SE5")+
QRY1 := QRY1 + " WHERE "
QRY1 := QRY1 + RetSQLName("SE1")+".E1_FILIAL = '" +xFilial("SE1")+"' AND "
QRY1 := QRY1 + RetSQLName("SE1")+".D_E_L_E_T_ <> '*'" + " AND "
//QRY1 := QRY1 + RetSQLName("SE5")+".D_E_L_E_T_ <> '*'" + " AND "
QRY1 := QRY1 + RetSQLName("SE1")+".E1_EMISSAO >= '"+DTOS(MV_PAR04) + "' AND "
QRY1 := QRY1 + RetSQLName("SE1")+".E1_BAIXA between '"+DTOS(MV_PAR02)+"' and '"+DTOS(MV_PAR03)+"' AND "
QRY1 := QRY1 + RetSQLName("SE1")+".E1_VEND1 = '"+MV_PAR01+"' AND "
QRY1 := QRY1 + RetSQLName("SE1")+".E1_VEND1 = "+RetSQLName("SA3")+".A3_COD and "
QRY1 := QRY1 + RetSQLName("SE1")+".E1_NUM <> "+RetSQLName("SE1")+".E1_FATURA " //and "
//QRY1 := QRY1 + RetSQLName("SE1")+".E1_PREFIXO = "+RetSQLName("SE5")+".E5_PREFIXO and "
//QRY1 := QRY1 + RetSQLName("SE1")+".E1_NUM     = "+RetSQLName("SE5")+".E5_NUMERO and "
//QRY1 := QRY1 + RetSQLName("SE1")+".E1_PARCELA = "+RetSQLName("SE5")+".E5_PARCELA and "
//QRY1 := QRY1 + RetSQLName("SE1")+".E1_CLIENTE = "+RetSQLName("SE5")+".E5_CLIFOR and "
//QRY1 := QRY1 + RetSQLName("SE1")+".E1_LOJA    = "+RetSQLName("SE5")+".E5_LOJA and "
//QRY1 := QRY1 + RetSQLName("SE5")+".E5_MOTBX <> 'DAC' "
QRY1 := QRY1 + "order by E1_EMISSAO, E1_NUM"
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

_cTitulo := "Relacao de Baixas - Vendedor: "+mv_par01+' - '+AllTrim(QRY1->A3_NOME)+' - De: '+DTOC(mv_par02)+'  Ate: '+DTOC(mv_par03)
_cDesc1  := "   Nota           Emissao                 Baixa                                    Comissao"
_cDesc2  := "  Fiscal  Pedido   Nota       Vencimento  Titulo      Parcela           Valor    %         Valor  Cliente"

_cMesAno := SUBS(QRY1->E1_EMISSAO,1,6)

Do While QRY1->(!Eof())

	IncRegua( "Imprimindo... ")
	
	If li > 65
		li := Cabec(_cTitulo,_cDesc1,_cDesc2,nomeprog,tamanho) + 1
	EndIf
	*         1         2         3         4         5         6         7         8         9         0         1         2         3         4         5         6         7         8         9         0
	*123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901
	*  Nota           Emissao                 Baixa                                    Comissao
	* Fiscal  Pedido   Nota       Vencimento  Titulo      Parcela           Valor     %         Valor  Cliente
	* 999999  999999  99/99/9999  99/99/9999  99/99/9999     A     999.999.999,99  99.99  999.999,99  123456-12 - 1234567890123456789012345678901234567890123456789012345678901
	*                                                                 Sub-TotaL 99/999: 9.999.999,99  
    *                                                                      TotaL GeraL: 9,999,999.99  
	@ li,002 PSay QRY1->E1_NUM
	@ li,010 PSay QRY1->E1_PEDIDO
	@ li,018 PSay SubStr(QRY1->E1_EMISSAO,7,2)+'/'+SubStr(QRY1->E1_EMISSAO,5,2)+'/'+SubStr(QRY1->E1_EMISSAO,1,4)
	@ li,030 PSay SubStr(QRY1->E1_VENCREA,7,2)+'/'+SubStr(QRY1->E1_VENCREA,5,2)+'/'+SubStr(QRY1->E1_VENCREA,1,4)
	@ li,042 PSay SubStr(QRY1->E1_BAIXA,7,2)+'/'+SubStr(QRY1->E1_BAIXA,5,2)+'/'+SubStr(QRY1->E1_BAIXA,1,4)
	@ li,057 PSay QRY1->E1_PARCELA
	@ li,063 PSay QRY1->E1_VALOR-QRY1->E1_SALDO  PICTURE '@E 999,999,999.99'
	@ li,079 PSay QRY1->E1_COMIS1 PICTURE '@E 99.99'
	@ li,086 PSay ROUND((QRY1->E1_VALOR-QRY1->E1_SALDO) * QRY1->E1_COMIS1 / 100,2) PICTURE '@E 999,999.99'
	@ li,098 PSay QRY1->E1_CLIENTE+'-'+QRY1->E1_LOJA+' - '+QRY1->E1_NOMCLI
	li++
	
	_nSubTotal := _nSubTotal + ROUND((QRY1->E1_VALOR-QRY1->E1_SALDO) * QRY1->E1_COMIS1 / 100,2)
	_nTotal    := _nTotal    + ROUND((QRY1->E1_VALOR-QRY1->E1_SALDO) * QRY1->E1_COMIS1 / 100,2)
	
	QRY1->(DbSkip())
	
	If _cMesAno <> SUBS(QRY1->E1_EMISSAO,1,6) .OR. QRY1->(EOF())
		@ li,000 Psay Replicate('-',171)
		li++
		If li > 65
			li := Cabec(_cTitulo,_cDesc1,_cDesc2,nomeprog,tamanho) + 1
		EndIf
		@ li,066 PSay 'Sub-TotaL: '+SubStr(_cMesAno,5,2)+'/'+SubStr(_cMesAno,1,4)
		@ li,084 PSay _nSubTotal PICTURE '@E 9,999,999.99' 
		li++
		@ li,000 PSay Replicate('-',171)
		li++
		_nSubTotal := 0
		_cMesAno := SUBS(QRY1->E1_EMISSAO,1,6)
	EndIf


EndDo

If li > 65
	li := Cabec(_cTitulo,_cDesc1,_cDesc2,nomeprog,tamanho) + 1
EndIf
	
@ li,071 PSay 'TotaL GeraL:'
@ li,084 PSay _nTotal PICTURE '@E 9,999,999.99'
li++
@ li,000 Psay Replicate('*',171)
li++

If li <> 80
	@ 065,000 PSAY 'Impresso em '+DtoC(DATE())+' as '+TIME()
//	Roda(nREG,'Impresso em '+DtoC(DATE())+' as '+TIME(),Tamanho)
EndIf

dbSelectArea("QRY1")
QRY1->(dbCloseArea())

Return(.T.)

/////////////////////////////////////////////////////////////////////////////
Static Function AjustaSX1(cPerg)
_sAlias := Alias()
dbSelectArea("SX1")
dbSetOrder(1)

aRegs:={}

//------------ Grupo/Ordem/Pergunta/PERGING/PERGESP/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05/F3

AADD(aRegs,{cPerg,"01","Qual vendedor      ?","","","mv_ch1","C",6,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","",'SA3'})
aAdd(aRegs,{cPerg,"02","Baixa de           ?","","","mv_ch2","D",8,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"03","Baixa ate          ?","","","mv_ch3","D",8,0,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"04","Emissao apartir de ?","","","mv_ch3","D",8,0,0,"G","","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","","",""})

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

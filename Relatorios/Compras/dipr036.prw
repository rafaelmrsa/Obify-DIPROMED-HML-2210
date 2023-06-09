/*
�����������������������������������������������������������������������������
���Funcao    � DIPR036  � Autor � Eriberto Elias     � Data � 11/08/2003  ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Relacao de produtos sem giro ou com estoque superior       ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � DIPR036                                                    ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Especifico DIPROMED                                        ���
�������������������������������������������������������������������������Ĵ��
�����������������������������������������������������������������������������
*/
#include "rwmake.ch"

User Function DIPR036()

Local _xArea   := GetArea()

Local titulo     := OemTOAnsi("Relacao de produtos sem giro ou com estoque superior...",72)
Local cDesc1     := OemToAnsi("Este programa tem como objetivo emitir um relat�rio",72)
Local cDesc2     := OemToAnsi("com os produtos sem giro ou com estoque superior.",72)
Local cDesc3     := OemToAnsi("Conforme parametros definidos pelo o usuario.",72)

Private aReturn    := {"Bco A4", 1,"Faturamento", 1, 2, 1,"",1}
Private li         := 66
Private tamanho    := "G"
Private limite     := 220
Private nomeprog   := "DIPR036"
Private cPerg      := "DIPR36"
Private nLastKey   := 0
Private lEnd       := .F.
Private wnrel      := "DIPR036"
Private cString    := "SB1"
Private m_pag      := 1

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

RptStatus({|lEnd| RodaRel()},Titulo)

Set device to Screen

//���������������������������������������������������������������������������Ŀ
//� Se em disco, desvia para Spool                                            �
//�����������������������������������������������������������������������������
If aReturn[5] == 1    // Se Saida para disco, ativa SPOOL
	Set Printer TO
	Commit
	ourspool(wnrel)
Endif

RestArea(_xArea)

Return

//////////////////////////////////////////////////////////////////////
Static Function RodaRel()
Local _nSubTotal := _nTotal := 0
Local _cForn := ""
Local _cCampo := '('
Local _cMes   := 0
Local _x
/*
select B1_COD, B1_DESC, B1_UM, (B1_UPRC+(B1_UPRC*B1_IPI/100)) B1_UPRC, B1_UCOM, B1_PRVMINI, B2_QATU, B2_USAI, (B3_Q07+B3_Q06+B3_Q05)/3/30*30 B3_MEDIA , A2_NREDUZ
from SB1010, SB2010, SB3010, SA2010
where
SB1010.B1_FILIAL = '  ' and
SB2010.B2_FILIAL = '04' and
SB3010.B3_FILIAL = '  ' and
SB1010.D_E_L_E_T_ <> '*' and
SB2010.D_E_L_E_T_ <> '*' and
SB3010.D_E_L_E_T_ <> '*' and
SA2010.D_E_L_E_T_ <> '*' and
(SB2010.B2_USAI < '20030711' or  -- MV_PAR01 = 20030711
((B3_Q07+B3_Q06+B3_Q05)/3/30*30) < SB2010.B2_QATU) and  -- MV_PAR02 = 30
SB2010.B2_QATU > 0 and
SB1010.B1_PROC = '000041' and   -- MV_PAR03 = 000041
SB1010.B1_COD = SB2010.B2_COD and
SB1010.B1_COD = SB3010.B3_COD and
SB1010.B1_PROC (*LEFT JOIN) SA2010.A2_COD
order by A2_NREDUZ, B1_DESC
*/

For _x := 1 to 3
	If Month(dDataBase)-_x <= 0
		_cMes := 12 + (Month(dDataBase)-_x)
	Else
		_cMes := Month(dDataBase)-_x
	EndIf
	_cCampo := _cCampo + 'B3_Q'+StrZero(_cMes,2)+Iif(_x<>3,'+',')/3/30*'+Str(MV_PAR02,2))
Next

//QRY1 := "SELECT B1_COD, B1_DESC, B1_UM, (B1_UPRC+(B1_UPRC*B1_IPI/100)) B1_UPRC, B1_UCOM, B1_PRVMINI, B2_QATU, B2_USAI, "+_cCampo+" B3_MEDIA, A2_NREDUZ"
//QRY1 := "SELECT B1_COD, B1_DESC, B1_UM, (B1_CUSDIP) B1_UPRC, B1_UCOM, B1_PRVMINI, B2_QATU, B2_USAI, "+_cCampo+" B3_MEDIA, A2_NREDUZ"
//QRY1 := "SELECT B1_COD, B1_DESC, B1_UM, (B1_LISFOR) B1_UPRC, B1_UCOM, B1_PRVMINI, B2_QATU, B2_USAI, "+_cCampo+" B3_MEDIA, A2_NREDUZ" // MCVN - 26/03/2009
QRY1 := "SELECT B1_COD, B1_DESC, B1_UM, (B1_LISFOR) B1_UPRC, B1_UCOM, B1_PRVMINI, B2_QATU, B2_USAI, "+_cCampo+" B3_MEDIA, A2_NREDUZ" // MCVN - 02/04/2009
QRY1 += " FROM " + RetSQLName("SB1") + " SB1 with (nolock) "

QRY1 += " inner join " + RetSQLName("SB2") + " SB2 with (nolock) "
QRY1 += "    on SB2.D_E_L_E_T_ <> '*' "
QRY1 += "    and SB2.B2_FILIAL = '"+xFilial('SB2')+"' "
QRY1 += "    and SB2.B2_LOCAL = '"+mv_par04+"' "
QRY1 += "    and SB1.B1_COD = SB2.B2_COD  "

	If MV_PAR05 = 1
		QRY1 += "    and SB2.B2_USAI < '"+DtoS(dDataBase-mv_par01)+"' "
		QRY1 += "    and SB2.B2_QATU > 0 "
	ElseIf MV_PAR05 = 2
		QRY1 += "    and " +  _cCampo+" < SB2.B2_QATU "
		QRY1 += "    and SB2.B2_QATU > 0 "
	Else
		QRY1 += "    and (SB2.B2_USAI < '"+DtoS(dDataBase-mv_par01)+"' "
		QRY1 += "    or  " + _cCampo+" < SB2.B2_QATU) "
		QRY1 += "    and SB2.B2_QATU > 0 "
	Endif                                                

QRY1 += " inner join " + RetSQLName("SB3") + " SB3 with (nolock) "
QRY1 += "    on SB3.D_E_L_E_T_ <> '*' "
QRY1 += "    and SB3.B3_FILIAL = '"+xFilial('SB3')+"' "
QRY1 += "    and SB1.B1_COD = SB3.B3_COD "

QRY1 += " left join " + RetSQLName("SA2") + " SA2 with (nolock) "
QRY1 += "    on SA2.D_E_L_E_T_ <> '*' "
QRY1 += "    and SB1.B1_PROC = SA2.A2_COD "
QRY1 += "    and SB1.B1_LOJPROC = SA2.A2_LOJA "

QRY1 += " WHERE SB1.D_E_L_E_T_ <> '*' "
QRY1 += "    and SB1.B1_FILIAL = '"+xFilial('SB1')+"' "
                                                           
	If !Empty(MV_PAR06)
		QRY1 += "    and SB1.B1_COD = '"+mv_par06+"' "
	Endif                      

	If !Empty(mv_par03)
		QRY1 += "    and SB1.B1_PROC = '"+mv_par03+"' "
	EndIf

QRY1 += "order by A2_NREDUZ, B1_DESC"

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
SetRegua(QRY1->(RecCount()))

_cTitulo := "Relacao de produtos sem giro a "+STR(mv_par01,3,0)+' dias OU estoque superior ao minimo para '+STR(mv_par02,2,0)+' dias'
_cDesc1  := "                                                                                                          Custo                                        Estoque       Ultima       Ultima"
_cDesc2  := "Produto                                                               Marca                  UM         Entrada    Quantidade              Total        Minimo      Entrada        Saida "//    Preco (C)   Margem"

Do While QRY1->(!Eof())
	
	IncRegua( "Imprimindo... ")
	
	If li > 60 .or.  _cForn <> QRY1->A2_NREDUZ
		li := Cabec(_cTitulo,_cDesc1,_cDesc2,nomeprog,tamanho) + 1
	    _cForn := QRY1->A2_NREDUZ
	EndIf
	*                                                                                                    1         1         1         1         1         1         1         1         1         1         2         2         2
	*          1         2         3         4         5         6         7         8         9         0         1         2         3         4         5         6         7         8         9         0         1         2
	*01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
	*                                                                                                          Custo                                        Estoque       Ultima       Ultima
	*Produto                                                               Marca                  UM         Entrada    Quantidade              Total        Minimo      Entrada        Saida     Preco (C)   Margem
	*999999 123456789012345678901234567890123456789012345678901234567890   12345678901234567890   UMX   999.999,9999   999.999.999   9.999.999.999,99   999.999.999   XX/XX/XXXX   XX/XX/XXXX   99.999,9999   999,99%
	*                                                                                                  Total 12345678901234567890:   9.999.999.999,99
	*                                                                                                                 TotaL GeraL:   9.999.999.999,99
	
	@ li,000 PSay SUBSTR(QRY1->B1_COD,1,6)+' '+QRY1->B1_DESC
	@ li,070 PSay QRY1->A2_NREDUZ
	@ li,093 PSay QRY1->B1_UM
	@ li,099 PSay QRY1->B1_UPRC PICTURE "@E 999,999.9999"
	@ li,114 PSay QRY1->B2_QATU PICTURE "@E 999,999,999"
	@ li,128 PSay QRY1->B1_UPRC * QRY1->B2_QATU PICTURE "@E 9,999,999,999.99"
	@ li,147 PSay QRY1->B3_MEDIA PICTURE "@E 999,999,999"
	@ li,161 PSay SubStr(QRY1->B1_UCOM,7,2)+'/'+SubStr(QRY1->B1_UCOM,5,2)+'/'+SubStr(QRY1->B1_UCOM,1,4)
	@ li,174 PSay SubStr(QRY1->B2_USAI,7,2)+'/'+SubStr(QRY1->B2_USAI,5,2)+'/'+SubStr(QRY1->B2_USAI,1,4)
//	@ li,187 PSay QRY1->B1_PRVMINI PICTURE "@E 99,999.9999"
//	@ li,202 PSay QRY1->B1_PRVMINI / QRY1->B1_UPRC *100 -100 PICTURE "@E 999.99"
//	@ li,208 PSay "%"
	li++
	
	_nSubTotal := _nSubTotal + (QRY1->B1_UPRC * QRY1->B2_QATU)
	_nTotal := _nTotal + (QRY1->B1_UPRC * QRY1->B2_QATU)
 
	QRY1->(DbSkip())
	
	If _cForn <> QRY1->A2_NREDUZ .or. QRY1->(EOF())
		If li > 60
			li := Cabec(_cTitulo,_cDesc1,_cDesc2,nomeprog,tamanho) + 1
        EndIf
		@ li,125-Len('TotaL '+AllTrim(_cForn)+':') PSay 'TotaL '+AllTrim(_cForn)+':'
		@ li,128 PSay _nSubTotal PICTURE "@E 9,999,999,999.99"
    	_nSubTotal := 0
   		li+=2
    EndIf
EndDo

If li > 60
	li := Cabec(_cTitulo,_cDesc1,_cDesc2,nomeprog,tamanho) + 1
	@ li,113 PSay 'TotaL GeraL:'
	@ li,128 PSay _nTotal PICTURE "@E 9,999,999,999.99"

	Roda(0,"Bom trabalho!",tamanho)
Else
	@ li,113 PSay 'TotaL GeraL:'
	@ li,128 PSay _nTotal PICTURE "@E 9,999,999,999.99"

	Roda(0,"Bom trabalho!",tamanho)
EndIf

dbSelectArea("QRY1")
QRY1->(dbCloseArea())

Return(.T.)

/////////////////////////////////////////////////////////////////////////////
Static Function AjustaSX1(cPerg)
_sAlias := Alias()
dbSelectArea("SX1")
dbSetOrder(1)

cPerg := PADR(cPerg, Len(SX1->X1_GRUPO)," " ) // Incluido por Sandro em 17/11/09.

aRegs:={}

//------------ Grupo/Ordem/Pergunta/PERGING/PERGESP/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05/F3

aAdd(aRegs,{cPerg,"01","Dias sem giro         ?","","","mv_ch1","N",3, 0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","",''})
AADD(aRegs,{cPerg,"02","Dias em estoque       ?","","","mv_ch2","N",2, 0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","",''})
AADD(aRegs,{cPerg,"03","Fornecedor            ?","","","mv_ch3","C",6, 0,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","",'SA2'})
AADD(aRegs,{cPerg,"04","Almoxarifado          ?","","","mv_ch4","C",2, 0,0,"G","","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","",''})          
aAdd(aRegs,{cPerg,"05","Sem Giro/Estoque Alto ?","","","mv_ch5","N",1, 0,1,"C","","mv_par05","Sem Giro","","","","","Estoque Alto","","","","","Ambos","","","","","","","","",""})
AADD(aRegs,{cPerg,"06","Produto               ?","","","mv_ch6","C",6, 0,0,"G","","MV_PAR06","","","","","","","","","","","","","","","","","","","","","","","","",'SB1'})

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

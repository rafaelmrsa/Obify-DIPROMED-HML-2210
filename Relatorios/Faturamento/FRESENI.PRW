/*================================================================================\
|Programa  | FRESENI   | Autor | Rafael de Campos Falco    | Data | 06/07/2004    |
|=================================================================================|
|Desc.     | Relatório de Notas Fiscais ou Títulos - por período                  |
|=================================================================================|
|Sintaxe   | FRESENI                                                              |
|=================================================================================|
|Uso       | Especifico DIPROMED                                                  |
|=================================================================================|
|Histórico |   /  /   -                                                           |
\================================================================================*/

#INCLUDE "RWMAKE.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "FILEIO.CH"
#INCLUDE "AP5MAIL.CH"

User Function FRESENI()
Local _xArea      := GetArea()
Local titulo      := OemTOAnsi("Relatório de Notas Fiscais ou Títulos",72)
Local cDesc1      := (OemToAnsi("Este programa tem como objetivo emitir um relat¢rio",72))
Local cDesc2      := (OemToAnsi("com a posicao das Notas Fiscais emitidas ou Títulos.",72))
Local cDesc3      := (OemToAnsi("Conforme parametros definidos pelo o usuario.",72))
Local _nPos			:= 1
Local _aFeriad		:= {}
Private aPar2		:= ""
Private aReturn    := {"Bco A4", 1,"Administracao", 1, 2, 1,"",1}
Private li         := 67
Private tamanho    := "P"
Private limite     := 80
Private nomeprog   := "FRESENI-1"

// Private cPerg      := "FRESEN"
// FPADR(cPerg, cArq, cCampo, cTipo)  - Para ajustar o tamanho das perguntas no SX1- uso generico
PRIVATE cPerg  	:= U_FPADR( "FRESEN","SX1","SX1->X1_GRUPO"," " ) //Função criada por Sandro em 19/11/09.

Private nLastKey   := 0
Private lEnd       := .F.
Private wnrel      := "FRESENI"
Private cString    := "SA1"
Private m_pag      := 1
Private cWorkFlow  := "N"
Private _dDatIni   := ""
Private _dDatFim   := ""

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

If MV_PAR01 = 1
	nomeprog   := "FRESENI-1"
	RptStatus({|lEnd| TitRel()},Titulo)
Else
	nomeprog   := "FRESENI-2"
	RptStatus({|lEnd| NFSRel()},Titulo)
EndIf
Set device to Screen

/*==========================================================================\
| Se em disco, desvia para Spool                                            |
\==========================================================================*/
If aReturn[5] == 1    // Se Saida para disco, ativa SPOOL
	Set Printer TO
	Commit
	ourspool(wnrel)
Endif

RestArea(_xArea)

Return

//////////////////////////////////////////////////////////////////////
Static Function TitRel()
Local cCodCli 	:= ""
Local nHandle	:= 0
Local	nTotTit 	:= 0
Local cAttach	:= ""
Local cAssunto	:= ""
Local cEmail	:= Space(220)
Local cRemet	:= Space(220)
Local aMsg		:= {}
Local aRet		:= {}
Private _cTitulo	:= ""
Private _cDesc1	:= ""
Private _cDesc2	:= ""

/* Seleciona os títulos

SELECT E1_NUM, E1_PARCELA, E1_VALOR, E1_VENCTO, E1_NOMCLI, E1_CLIENTE, E1_LOJA, E1_BAIXA, E1_VENCORI, E1_PEDIDO
FROM SE1010, SA1010
WHERE E1_EMISSAO BETWEEN '20040101' AND '20040701'
AND E1_CLIENTE = A1_COD
AND E1_LOJA    = A1_LOJA
AND A1_SATIV1    = '2.1.05'
ORDER BY A1_NOME, E1_NUM, E1_PARCELA

*/

QRY1 := " SELECT E1_NUM, E1_PARCELA, E1_VALOR, E1_VENCTO, E1_NOMCLI, E1_CLIENTE, E1_LOJA, E1_BAIXA, E1_VENCORI, E1_PEDIDO"
QRY1 += " FROM " + RetSQLName("SE1")+', '+ RetSQLName("SA1")
QRY1 += " WHERE E1_EMISSAO BETWEEN '" +DtoS(MV_PAR02)+ "' AND '" +DtoS(MV_PAR03)+ "'"
QRY1 += " AND E1_CLIENTE = A1_COD"
QRY1 += " AND E1_LOJA    = A1_LOJA"
//Giovani Zago 13/03/2012 filtro para os vendedores.
If alltrim(Posicione("SU7",4,xFilial("SU7") + RetCodUsr(),"U7_CGC")) $ GetMv("ES_VENDUSE",,"000053" )
	QRY1 += " AND E1_VEND1    = '"+alltrim(Posicione("SU7",4,xFilial("SU7") + RetCodUsr(),"U7_CGC"))+"'"
EndIf
QRY1 += " AND E1_SALDO   > 0"   // MCVN - 27/02/2009
QRY1 += " AND A1_SATIV1  = '" +MV_PAR05+ "'"   //'2.1.05'"
QRY1 += " AND " + RetSQLName("SE1")+ ".D_E_L_E_T_ <> '*'"
QRY1 += " AND " + RetSQLName("SA1")+ ".D_E_L_E_T_ <> '*'"
QRY1 += " ORDER BY A1_NOME, E1_NUM, E1_PARCELA"

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
DbCommitAll()
TcQuery QRY1 NEW ALIAS "QRY1"         // Abre uma workarea com o resultado da query

DbSelectArea("QRY1")
QRY1->(dbGotop())

// Função para localizar endereço de e-mail do usuário
aRet := U_EmailUsu()

// Parâmetros de montagem do cabeçalho
_cTitulo := " Títulos emitidos de " + SubStr(DtoS(MV_PAR02),7,2) + "/" + SubStr(DtoS(MV_PAR02),5,2) + " até " + SubStr(DtoS(MV_PAR03),7,2) + "/" + SubStr(DtoS(MV_PAR03),5,2) + "/" + SubStr(DtoS(MV_PAR03),3,2)
_cDesc1  := " Código-Lj - Cliente"
_cDesc2  := " Título       Parcela       Vencimento              Valor"

AADD(aMsg,{'Código','Lj', 'Cliente', 'Título', 'Parcela', 'Vencimento', 'Valor'})

SetRegua(RecCount())

*          1         2         3         4         5         6         7         8         9         0         1         2         3         4         5         6         7         8         9         0
*0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901
*dipr032/v.AP6 6.09    Títulos emitidos de 99 até 99/99/99   Data.: 99/99/99
* Código-Lj - Cliente
* Título       Parcela       Vencimento              Valor
* 999999-99 - XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
* 999999       XX            99/99/9999       9.999.999,99
* Valores Acumulados..........................9.999.999,99

Do While QRY1->(!Eof())
	
	If lAbortPrint
		@ li+1,00 PSAY "*** CANCELADO PELO OPERADOR ***"
		Exit
	Endif
	
	IncRegua( "Imprimindo... " + QRY1->E1_NUM)
	
	If li > 60
		li := u_MYCabec(_cTitulo,_cDesc1,_cDesc2,nHandle,cWorkFlow)
	EndIf
	
	If cCodCli != QRY1->E1_CLIENTE + QRY1->E1_LOJA
		If !Empty(cCodCli)
			@ li,000 PSay Replic("-",Limite)
			li++
		EndIf
		@ li,001 PSay QRY1->E1_CLIENTE + "-" + QRY1->E1_LOJA + " - " + QRY1->E1_NOMCLI
		cCodCli := QRY1->E1_CLIENTE + QRY1->E1_LOJA
		li++
	EndIf
	
	@ li,001 PSay QRY1->E1_NUM
	@ li,014 PSay QRY1->E1_PARCELA
	@ li,028 PSay Substr(QRY1->E1_VENCTO,7,2)+"/"+Substr(QRY1->E1_VENCTO,5,2)+"/"+Substr(QRY1->E1_VENCTO,3,2)
	@ li,045 PSay QRY1->E1_VALOR picture "@E 9,999,999.99"
	li++
	
	nTotTit += QRY1->E1_VALOR
	
	/// Adiciona todos os dados no array para montar e-mail
	AADD(aMsg,{QRY1->E1_CLIENTE, QRY1->E1_LOJA, QRY1->E1_NOMCLI, QRY1->E1_NUM, QRY1->E1_PARCELA, Substr(QRY1->E1_VENCTO,7,2)+"/"+Substr(QRY1->E1_VENCTO,5,2)+"/"+Substr(QRY1->E1_VENCTO,3,2), Transform(QRY1->E1_VALOR,"@E 9,999,999.99")})
	
	QRY1->(DbSkip())
	
EndDo

// Assunto do E-mail
cAssunto := _cTitulo

@ li,000 PSay Replic("*",Limite)
li++

If li > 60
	li := u_MYCabec(_cTitulo,_cDesc1,_cDesc2,nHandle,cWorkFlow)
EndIf

If li <> 80
	@ 062,000 PSAY 'Impresso em '+DtoC(DATE())+' as '+TIME()
EndIf

If MV_PAR04 == 1
	//rfalco@ibest.com.br;rafael@dipromed.com.br
	@ 126,000 To 320,300 DIALOG oDlg TITLE OemToAnsi("Informe o endereço do E-mail")
	@ 010,015 Say "Destinatário:"
	@ 025,015 Get cEmail Size 120,20 Picture "@S80" Valid !Empty(cEmail)
	@ 040,015 Say "Remetente:"
	@ 055,015 Get cRemet Size 120,20 Picture "@S80" Valid !Empty(cRemet)
	@ 070,050 BmpButton Type 1 Action Close(oDlg)
	Activate Dialog oDlg Centered
	
	EMail(cEmail,cAssunto,aMsg,cAttach,cRemet)
	
EndIf

dbSelectArea("QRY1")
QRY1->(dbCloseArea())

Return(.T.)



//////////////////////////////////////////////////////////////////////
Static Function NFSRel()
Local cCodCli 		:= ""
Local nHandle		:= 0
Local nTotTit 		:= 0
Local cAttach	:= ""
Local cAssunto	:= ""
Local cEmail	:= Space(220)
Local cRemet	:= Space(220)
Local aMsg		:= {}
Private _cTitulo	:= ""
Private _cDesc1	:= ""
Private _cDesc2	:= ""
Private nomeprog	:= "FRESENI-1"

/* Seleciona as notas fiscais

SELECT F2_DOC, F2_SERIE, F2_CLIENTE, F2_LOJA, A1_NOME, F2_EMISSAO, F2_VALBRUT, F2_DATASAI, F2_HORASAI, F2_TRANSP, A4_NOME
FROM SF2010, SA1010, SA4010
WHERE F2_EMISSAO BETWEEN '20040101' AND '20040701'
AND F2_CLIENTE = A1_COD
AND F2_LOJA    = A1_LOJA
AND A1_SATIV1    = '2.1.05'
AND F2_TRANSP = A4_COD
ORDER BY A1_NOME, F2_EMISSAO

*/

QRY1 := " SELECT F2_DOC, F2_SERIE, F2_CLIENTE, F2_LOJA, A1_NOME, F2_EMISSAO, F2_VALBRUT, F2_DATASAI, F2_HORASAI, F2_TRANSP, A4_NOME"
QRY1 += " FROM " + RetSQLName("SF2")+', '+ RetSQLName("SA1")+', '+ RetSQLName("SA4")
QRY1 += " WHERE F2_EMISSAO BETWEEN '" + DtoS(MV_PAR02) + "' AND '" + DtoS(MV_PAR03) + "'"
QRY1 += " AND F2_CLIENTE = A1_COD"
QRY1 += " AND F2_LOJA    = A1_LOJA"
//Giovani Zago 13/03/2012 filtro para os vendedores.
If alltrim(Posicione("SU7",4,xFilial("SU7") + RetCodUsr(),"U7_CGC")) $ GetMv("ES_VENDUSE",,"000053" )
	QRY1 += " AND F2_VEND1    = '"+alltrim(Posicione("SU7",4,xFilial("SU7") + RetCodUsr(),"U7_CGC"))+"'"
EndIf
QRY1 += " AND A1_SATIV1  = '" +MV_PAR05+ "'"   //'2.1.05'"
QRY1 += " AND F2_TRANSP  = A4_COD"
QRY1 += " AND " + RetSQLName("SF2")+ ".D_E_L_E_T_ <> '*'"
QRY1 += " AND " + RetSQLName("SA1")+ ".D_E_L_E_T_ <> '*'"
QRY1 += " AND " + RetSQLName("SA4")+ ".D_E_L_E_T_ <> '*'"
QRY1 += " ORDER BY A1_NOME, F2_EMISSAO"

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
DbCommitAll()
TcQuery QRY1 NEW ALIAS "QRY1"         // Abre uma workarea com o resultado da query

DbSelectArea("QRY1")
QRY1->(dbGotop())

// Parâmetros de montagem do cabeçalho
_cTitulo := "N.Fiscais emitidas de " + SubStr(DtoS(MV_PAR02),7,2) + "/" + SubStr(DtoS(MV_PAR02),5,2) + " até " + SubStr(DtoS(MV_PAR03),7,2) + "/" + SubStr(DtoS(MV_PAR03),5,2) + "/" + SubStr(DtoS(MV_PAR03),1,4)
_cDesc1  := "Código-Lj - Cliente                                                    Saída "
_cDesc2  := "NF          Valor Emissão  Transportadora                        Data     Hora"

AADD(aMsg,{'Código', 'Lj', 'Cliente', 'NF', 'Valor', 'Emissão', 'Transportadora', 'Dt.Saída', 'Hr.Saída'})

SetRegua(RecCount())

*          1         2         3         4         5         6         7         8         9         0         1         2         3         4         5         6         7         8         9         0
*0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901
*dipr032/v.AP6 6.09 Notas Fiscais emitidas de 99 até 99/99/9999 Data.: 99/99/99
*Código-Lj - Cliente                                                  Saída
*NF          Valor Emissão  Transportadora                        Data     Hora
*999999-99 - XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
*999999 999.999,99 99/99/99 XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX 99/99/99 99:99
*TOTAL 9999.999,99

Do While QRY1->(!Eof())
	
	If lAbortPrint
		@ li+1,00 PSAY "*** CANCELADO PELO OPERADOR ***"
		Exit
	Endif
	
	IncRegua( "Imprimindo... " + QRY1->F2_DOC)
	
	If li > 60
		li := u_MYCabec(_cTitulo,_cDesc1,_cDesc2,nHandle,cWorkFlow)
	EndIf
	
	If cCodCli != QRY1->F2_CLIENTE + QRY1->F2_LOJA
		If !Empty(cCodCli)
			@ li,000 PSay Replic("-",Limite)
			li++
		EndIf
		@ li,000 PSay QRY1->F2_CLIENTE + "-" + QRY1->F2_LOJA + " - " + QRY1->A1_NOME
		cCodCli := QRY1->F2_CLIENTE + QRY1->F2_LOJA
		li++
	EndIf
	
	@ li,000 PSay QRY1->F2_DOC
	@ li,007 PSay QRY1->F2_VALBRUT picture "@E 999,999.99"
	@ li,018 PSay Substr(QRY1->F2_EMISSAO,7,2)+"/"+Substr(QRY1->F2_EMISSAO,5,2)+"/"+Substr(QRY1->F2_EMISSAO,3,2)
	@ li,027 PSay SubStr(QRY1->A4_NOME,1,37)
	@ li,065 PSay Substr(QRY1->F2_DATASAI,7,2)+"/"+Substr(QRY1->F2_DATASAI,5,2)+"/"+Substr(QRY1->F2_DATASAI,3,2)
	@ li,074 PSay Substr(QRY1->F2_HORASAI,1,2)+":"+Substr(QRY1->F2_HORASAI,3,2)
	li++
	
	nTotTit += QRY1->F2_VALBRUT
	
	/// Adiciona todos os dados no array para montar e-mail
	AADD(aMsg,{QRY1->F2_CLIENTE, QRY1->F2_LOJA, QRY1->A1_NOME, QRY1->F2_DOC, Transform(QRY1->F2_VALBRUT, "@E 9,999,999.99"), Substr(QRY1->F2_EMISSAO,7,2)+"/"+Substr(QRY1->F2_EMISSAO,5,2)+"/"+Substr(QRY1->F2_EMISSAO,3,2), SubStr(QRY1->A4_NOME,1,37), Substr(QRY1->F2_DATASAI,7,2)+"/"+Substr(QRY1->F2_DATASAI,5,2)+"/"+Substr(QRY1->F2_DATASAI,3,2), Substr(QRY1->F2_HORASAI,1,2)+":"+Substr(QRY1->F2_HORASAI,3,2),Transform(nTotTit,"@E 99,999,999.99")})
	
	QRY1->(DbSkip())
	
EndDo

// Assunto do E-mail
cAssunto := _cTitulo

/* Impressão da linha de totais */
@ li,000 PSay Replic("*",Limite)
li++
@ li,000 PSay "Total"
@ li,006 PSay nTotTit picture "@E 99,999,999.99"
li++
@ li,000 PSay Replic("*",Limite)
li++

If li > 60
	li := u_MYCabec(_cTitulo,_cDesc1,_cDesc2,nHandle,cWorkFlow)
EndIf
If li <> 80
	@ 062,000 PSAY 'Impresso em '+DtoC(DATE())+' as '+TIME()
EndIf

If MV_PAR04 == 1
	//rfalco@ibest.com.br;rafael@dipromed.com.br
	@ 126,000 To 320,300 DIALOG oDlg TITLE OemToAnsi("Informe o endereço do E-mail")
	@ 010,015 Say "Destinatário:"
	@ 025,015 Get cEmail Size 120,20 Picture "@S80" Valid !Empty(cEmail)
	@ 040,015 Say "Remetente:"
	@ 055,015 Get cRemet Size 120,20 Picture "@S80" Valid !Empty(cRemet)
	@ 070,050 BmpButton Type 1 Action Close(oDlg)
	Activate Dialog oDlg Centered
	
	EMail(cEmail,cAssunto,aMsg,cAttach,cRemet)
	
EndIf

dbSelectArea("QRY1")
QRY1->(dbCloseArea())

Return(.T.)


/*==========================================================================\
|Programa  |EMail   | Autor | Rafael de Campos Falco  | Data ³ 04/06/2004   |
|===========================================================================|
|Desc.     | Envio de EMail                                                 |
|===========================================================================|
|Sintaxe   | EMail                                                          |
|===========================================================================|
|Uso       | Especifico DIPROMED                                            |
\==========================================================================*/

Static Function EMail(cEmail,cAssunto,aMsg,cAttach,cRemet)

Local cAccount  := Lower(Alltrim(GetMv("MV_RELACNT")))
Local cFrom     := Lower(Alltrim(GetMv("MV_RELACNT")))
Local cPassword := Alltrim(GetMv("MV_RELPSW"))
Local cServer   := Alltrim(GetMv("MV_RELSERV"))
Local cEmailTo  := ""
Local cEmailCc  := Lower(Alltrim(cRemet))
Local cEmailBcc := ""
Local lResult   := .F.
Local cError    := ""
Local cCod_Pro	 := ""
Local ni 		 := 1
Local i         := 0
Local	cTot_Pro  := 0
Local cArq      := ""
Local cMsg      := ""  
LOCAL lSmtpAuth := GetNewPar("MV_RELAUTH",.F.)
LOCAL lAutOk	:= .F.


/*=============================================================================*/
/*Definicao do cabecalho do email                                              */
/*=============================================================================*/
cMsg := ""
cMsg += '<html>'
cMsg += '<head>'
cMsg += '<title>' + cAssunto + '</title>'
cMsg += '</head>'
cMsg += '<body>'
//cMsg += '<Img Src="C:/AP5/SIGAADV/LGRL01.BMP"><BR>'
cMsg += '<HR Width=85% Size=3 Align=Centered Color=Red> <P>'
cMsg += '<Table Align=Center BorderColor=#000000 CELLPADDING=4 CELLSPACING=0 Width=60%>'

/*=============================================================================*/
/*Definicao do cabecalho do relatório                                          */
/*=============================================================================*/

cMsg += '<table width="100%">'
cMsg += '<tr>'
cMsg += '<td align="left" width="50%"><font size="5" face="verdana">Dipromed</font></td>'
cMsg += '<td align="right" width="50%"><font size="5" face="verdana">Fresenius</font></td>'
cMsg += '</tr>'
cMsg += '</table>'


cMsg += '<table width="100%">'
cMsg += '<tr>'
cMsg += '<td>=======================================================================================</td>'
cMsg += '</tr>'
cMsg += '</table>'

cMsg += '<table width="100%">'
cMsg += '<tr>'
cMsg += '<td width="10%">' + aMsg[1,1] + '</td>'
cMsg += '<td width="10%">' + aMsg[1,2] + '</td>'
cMsg += '<td width="80%">' + aMsg[1,3] + '</td>'
cMsg += '</tr>'
cMsg += '</table>'

cMsg += '<table width="100%">'
cMsg += '<tr>'
cMsg += '<td width="10%">' + aMsg[1,4] + '</td>'
If MV_PAR01 = 2
	cMsg += '<td width="10%" align="right">' + aMsg[1,5] + '</td>'
Else
	cMsg += '<td width="10%">' + aMsg[1,5] + '</td>'
EndIf
cMsg += '<td width="10%">' + aMsg[1,6] + '</td>'
If MV_PAR01 = 2
	cMsg += '<td width="50%">' + aMsg[1,7] + '</td>'
	cMsg += '<td width="10%">' + aMsg[1,8] + '</td>'
	cMsg += '<td width="10%">' + aMsg[1,9] + '</td>'
Else
	cMsg += '<td width="10%">' + aMsg[1,7] + '</td>'
	cMsg += '<td width="10%"></td>'
	cMsg += '<td width="50%"></td>'
EndIf
cMsg += '</tr>'
cMsg += '</table>'

cMsg += '<table width="100%">'
cMsg += '<tr>'
cMsg += '<td>=======================================================================================</td>'
cMsg += '</tr>'
cMsg += '</table>'


/*=============================================================================*/
/*Definicao do texto/detalhe do email                                          */
/*=============================================================================*/


For nLin := 2 to Len(aMsg)
	If cCod_Pro != aMsg[nLin,1] + aMsg[nLin,2]
		cMsg += '<table width="100%">'
		cMsg += '<tr BgColor=#B0E2FF>'
		cMsg += '<td width="10%">' + aMsg[nLin,1] + '</td>'
		cMsg += '<td width="10%">' + aMsg[nLin,2] + '</td>'
		cMsg += '<td width="80%">' + aMsg[nLin,3] + '</td>'
		cMsg += '</tr>'
		cMsg += '</table>'
		cCod_Pro := aMsg[nLin,1] + aMsg[nLin,2]
	EndIf
	
	cMsg += '<table width="100%" border="1">'
	cMsg += '<tr BgColor=#FFFFFF>'
	cMsg += '<td width="10%">' + aMsg[nLin,4] + '</td>'
	cMsg += '<td width="10%" align="right">' + aMsg[nLin,5] + '</td>'
	cMsg += '<td width="10%">' + aMsg[nLin,6] + '</td>'
	cMsg += '<td width="50%">' + aMsg[nLin,7] + '</td>'
	If MV_PAR01 = 2
		cMsg += '<td width="10%">' + aMsg[nLin,8] + '</td>'
		cMsg += '<td width="10%">' + aMsg[nLin,9] + '</td>'
	EndIf
	cMsg += '</tr>'
	cMsg += '</table>'
Next

If MV_PAR01 = 2
	cMsg += '<table width="100%" border="1">'
	cMsg += '<tr BgColor=#B0E2FF>'
	cMsg += '<td width="10%">Total</td>'
	cMsg += '<td width="10%" align="right">' + aMsg[Len(aMsg),10] + '</td>'
	cMsg += '<td width="10%"></td>'
	cMsg += '<td width="50%"></td>'
	cMsg += '<td width="10%"></td>'
	cMsg += '<td width="10%"></td>'
	cMsg += '</tr>'
	cMsg += '</table>'
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Definicao do rodape do email                                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cMsg += '</Table>'
cMsg += '<HR Width=85% Size=3 Align=Centered Color=Red> <P>'
cMsg += '</body>'
cMsg += '</html>'

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Envia o mail para a lista selecionada. Envia como BCC para que a pessoa pense³
//³que somente ela recebeu aquele email, tornando o email mais personalizado.   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
IF At(";",cEmail) > 0
	cEmailTo := SubStr(cEmail,1,At(";",cEmail)-1)
	cEmailBcc:= SubStr(cEmail,At(";",cEmail)+1,Len(cEmail))
Else
	cEmailTo := Alltrim(cEmail)
EndIF


CONNECT SMTP SERVER cServer ACCOUNT cAccount PASSWORD cPassword RESULT lResult

If !lAutOk
	If ( lSmtpAuth )
		lAutOk := MailAuth(cAccount,cPassword)
	Else
		lAutOk := .T.
	EndIf
EndIf

If lResult .And. lAutOk
	SEND MAIL FROM cFrom ;
	TO      	Lower(cEmailTo);
	CC      	Lower(cEmailCc);
	BCC     	Lower(cEmailBcc);
	SUBJECT 	cAssunto;
	BODY    	cMsg;
	RESULT lResult
	
	If !lResult
		//Erro no envio do email
		GET MAIL ERROR cError
		
		MsgInfo(cError,OemToAnsi("Atenção"))
	EndIf
	
	DISCONNECT SMTP SERVER
Else
	//Erro na conexao com o SMTP Server
	GET MAIL ERROR cError
	
	MsgInfo(cError,OemToAnsi("Atenção"))
EndIf

Return(.T.)





/*==========================================================================\
|Programa  |VALIDPERG| Autor | Rafael de Campos Falco  | Data ³ 04/06/2004  |
|===========================================================================|
|Desc.     | Inclui as perguntas caso nao existam                           |
|===========================================================================|
|Sintaxe   | VALIDPERG                                                      |
|===========================================================================|
|Uso       | Especifico DIPROMED                                            |
|===========================================================================|
|Histórico | DD/MM/AA - Descrição da alteração                              |
\==========================================================================*/

Static Function AjustaSX1(cPerg)
_sAlias := Alias()
dbSelectArea("SX1")
dbSetOrder(1)

aRegs:={}

//------------ Grupo/Ordem/Pergunta/PERGING/PERGESP/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05/F3

AADD(aRegs,{cPerg,"01","Qual relatório     ?","","","mv_ch1","N",01,0,0,"C","","mv_par01","1-Títulos","","","","","2-Notas Fiscais","","","","","","","",""})
AADD(aRegs,{cPerg,"02","Da Data            ?","","","mv_ch2","D",08,0,0,"G","","mv_par02","","","","","","","","","","","","","",""})
AADD(aRegs,{cPerg,"03","Ate a Data         ?","","","mv_ch3","D",08,0,0,"G","","mv_par03","","","","","","","","","","","","","",""})
AADD(aRegs,{cPerg,"04","Envia e-mail       ?","","","mv_ch4","N",01,0,0,"C","","MV_PAR04","1-Sim","","","","","2-Não","","","","","","","","","","","","","","","","","","",''})
aAdd(aRegs,{cPerg,"05","Segmento           ?","","","mv_ch5","C",06,0,0,"G","","mv_par05","","",""," ","","","","","","","","","","","","","","","","","","","","","T3",""})
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

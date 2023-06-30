#INCLUDE "RWMAKE.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "FILEIO.CH"

#DEFINE ENTER CHR(13)+CHR(10)
/*====================================================================================\
|Programa  | DIPR084()  | Autor  | Reginaldo Borges   | Data | 26/11/2015             |
|=====================================================================================|
|Descrição | Gera um relatorio com as informacoes do prazo de entrega dos pedidos     |
|          | de compras em abertos, que os prazos de entrega estejam vencidos.        |
|          | As informações serão geradas de acordo com as informacoes nos parametros.|
|          |                                                                          |
|=====================================================================================|
|Uso       | Especifico Compras                                                       |
|=====================================================================================|
|Histórico | 																		  |
\====================================================================================*/

User Function DIPR084(aWork)
                                                                            
Local titulo      := OemTOAnsi("Relatorio dos pedidos de compras vencidos.",72)
Local cDesc1      := (OemToAnsi("Este programa tem como objetivo emitir um relatorio com a",72))
Local cDesc2      := (OemToAnsi("relação de todos os pedidos de compras com data de entrega vencida.",72))
Local cDesc3      := (OemToAnsi("Conforme parametros definidos.",72))
Private aReturn   := {"Bco A4", 1,"Administracao", 1, 2, 1,"",1}
Private nomeprog  := "DIPR084"
PRIVATE cPerg  	  := "DIPR084"
Private nLastKey  := 0
Private lEnd      := .F.
Private wnrel     := "DIPR084"
Private cString   := "SC7"
Private cWorkFlow := ""
Private cWCodEmp  := ""
Private cWCodFil  := ""
Private PG := 0

cWorkFlow := aWork[1]
cWCodEmp  := aWork[2]
cWCodFil  := aWork[3]

If ValType(aWork) == 'A'
	PREPARE ENVIRONMENT EMPRESA cWCodEmp FILIAL cWCodFil FUNNAME "DIPR084" TABLES "SC7"
EndIf

ConOut('Inicio do relatorio dos pedidos de compras vencidos '+dToc(date())+' as '+Time())

RodaRel()

ConOut('Fim relatorio dos pedidos de compras vencidos '+dToc(date())+' as '+Time())

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³RODAREL() ºAutor  ³Microsiga           º Data ³  11/26/15   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function RodaRel()

Local   cSQL 	 := ""
Private aMsgI    := {}
Private aMsgJ    := {}
Private _cEmCom  := ""
Private cPedid   := ""
Private cForne   := ""

cSQL := " SELECT "
cSQL += " C7_NUM As _cPedido, C7_ITEM As cItem, C7_PRODUTO As cProduto, C7_PRECO As nPreco, C7_QUANT As nQuant, C7_QUJE As nQuantE,"
cSQL += " C7_EMISSAO As dEmissao, C7_DATPRF As _cEntPre, C7_DENTREG As cEntDip, C7_FORNECE As cFornec "
cSQL += "FROM "+ RetSQLName("SC7")
cSQL += " WHERE"
cSQL += "    	C7_FILIAL IN ('01','04') "
//cSQL += "	AND DATEDIFF(DAY,C7_DENTREG,'20151118') = 1"  //'20151118'
//cSQL += "	AND DATEDIFF(DAY,C7_DENTREG,'"+dTos(date())+"') > 0"
cSQL += "	AND DATEDIFF(DAY,'"+dTos(date())+"',C7_DENTREG) < 3"  //Ajustado dia 06/08/21 chamado 3071
cSQL += "   AND C7_QUANT - C7_QUJE > 0 "
cSQL += "   AND C7_ENCER    = ''       "
cSQL += "	AND C7_RESIDUO  = '' 	   "
cSQL += "	AND D_E_L_E_T_  = ''       "
cSQL += " ORDER BY cFornec, _cPedido, cItem, cProduto  "

cSQL := ChangeQuery(cSQL)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),"cSQLSC7",.T.,.F.)

cPedid := cSQLSC7->_cPedido
cForne := cSQLSC7->cFornec

While  cSQLSC7->(!Eof())
	
	_cPedid  := cSQLSC7->_cPedido
	_cFornec :="FORNECEDOR: "+cSQLSC7->cFornec
	_cItem   := cSQLSC7->cItem
	_cProduto:= ALLTRIM( cSQLSC7->cProduto)
	_nQuant  := cSQLSC7->nQuant
	_nPreco  := cSQLSC7->nPreco
	_nQuantE := cSQLSC7->nQuantE
	_nQuantP := (cSQLSC7->nQuant - cSQLSC7->nQuantE)
	_dData   := StoD(cSQLSC7->dEmissao)
	_EntDip  := StoD(cSQLSC7->cEntDip)
	_cFornecN:='-'+ALLTRIM(Posicione("SA2",1,xFilial("SA2")+cSQLSC7->cFornec,"A2_NOME"))
	_cProduto+='-'+ALLTRIM(Posicione("SB1",1,xFilial("SB1")+_cProduto,"B1_DESC"))
	_cContato:= "CONTATO: "+ALLTRIM(Posicione("SA2",1,xFilial("SA2")+cSQLSC7->cFornec,"A2_CONTATO"))
	_cTel    := "TEL: "+ALLTRIM(Posicione("SA2",1,xFilial("SA2")+cSQLSC7->cFornec,"A2_DDD"))+" "+;
	ALLTRIM(Posicione("SA2",1,xFilial("SA2")+cSQLSC7->cFornec,"A2_TEL"))
	_cCompra := ALLTRIM(Posicione("SA2",1,xFilial("SA2")+cSQLSC7->cFornec,"A2_COMPRA"))
	_cNomeCo := "COMPRADOR: "+_cCompra+" - "+ALLTRIM(Posicione("SY1",1,xFilial("SY1")+_cCompra,"Y1_NOME"))
	_cEmCompr:= "compras@dipromed.com.br" //ALLTRIM(Posicione("SY1",1,xFilial("SY1")+_cCompra,"Y1_EMAIL"))
	//Rafael Moraes Rosa - 28/06/2023 - Linha abaixo comentada
	//_cEmCompr:= "compras@dipromed.com.br" //ALLTRIM(Posicione("SY1",1,xFilial("SY1")+_cCompra,"Y1_EMAIL"))
	//Rafael Moraes Rosa - 28/06/2023 - Linha abaixo substituida
	_cEmCompr:= IIF(Empty(SUPERGETMV("MV_#EMLSCH", .F., "")),"compras@dipromed.com.br",GETMV("MV_#EMLSCH"))
	*   1        2         3       4        5       6     7         8       9         10     11       12      13     14
	//	aadd(aMsgI,{_cPedid,_cProduto,_nQuant,_nQuantE,_nQuantP,_dData,_EntDip,_cFornec,_cFornecN,_cItem,_nPreco,_cContato,_cTel,_cNomeCo})
	
	If ((cPedid == _cPedid)  .Or. (cForne == cSQLSC7->cFornec))
		*   1        2         3       4        5       6     7         8       9         10     11       12      13     14
		aadd(aMsgJ,{_cPedid,_cProduto,_nQuant,_nQuantE,_nQuantP,_dData,_EntDip,_cFornec,_cFornecN,_cItem,_nPreco,_cContato,_cTel,_cNomeCo})		
	Else
		
		If Len(aMsgJ) > 0 // SE NÃO POSSUIR NENHUMA LINHA NO ARRAY NÃO ENVIA NADA  -  RBORGES 26/11/15
			cEmail :=_cEmCompr
			cAssunto:= EncodeUTF8('ATENÇÃO - PEDIDOS DE COMPRA COM ATRASO NA ENTREGA - '+aMsgJ[1,8]+''+aMsgJ[1,9],"cp1252")//+' - ' +AllTrim(SM0->M0_NOME)//+"/"+AllTrim(SM0->M0_FILIAL)
			U__EMailPC(cEmail,cAssunto,aMsgJ) //RBORGES 26/11/15 - Dispara E-mail de entrega vencida por pedido e comprador
			
			aMsgJ := {}
			*   1        2         3       4        5       6     7         8       9         10     11       12      13     14
			aadd(aMsgJ,{_cPedid,_cProduto,_nQuant,_nQuantE,_nQuantP,_dData,_EntDip,_cFornec,_cFornecN,_cItem,_nPreco,_cContato,_cTel,_cNomeCo})
		EndIf
	EndIf
	
	cPedid := cSQLSC7->_cPedido
	cForne := cSQLSC7->cFornec
	
	cSQLSC7->(dbSkip())
EndDo

cSQLSC7->(dbCloseArea())

If Len(aMsgJ) > 0 // SE NÃO POSSUIR NENHUMA LINHA NO ARRAY NÃO ENVIA NADA  -  RBORGES 26/11/15
	cEmail :=_cEmCompr
	cAssunto:= EncodeUTF8('ATENÇÃO - PEDIDOS DE COMPRA COM ATRASO NA ENTREGA - '+aMsgJ[1,8]+''+aMsgJ[1,9],"cp1252")//+' - ' +AllTrim(SM0->M0_NOME)//+"/"+AllTrim(SM0->M0_FILIAL)
	U__EMailPC(cEmail,cAssunto,aMsgJ) //RBORGES 26/11/15 - Dispara E-mail de entrega vencida por pedido e comprador
EndIf


/* // Sera enviado somente o e-mail individual por comprador. RBORGES 01/12/15
If Len(aMsgI) > 0 // SE NÃO POSSUIR NENHUMA LINHA NO ARRAY NÃO ENVIA NADA  -  RBORGES 26/11/15
	cEmail := GetNewPar("ES_SC7PC","reginaldo.borges@dipromed.com.br")   //Usuários que receberão e-mails - RBORGES 26/11/15
	cAssunto:= 'ATENÇÃO - PEDIDOS DE COMPRA COM ATRASO NA ENTREGA para '+dToc(_EntDip)//+' - ' +AllTrim(SM0->M0_NOME)//+"/"+AllTrim(SM0->M0_FILIAL)
	U_EMailPC(cEmail,cAssunto,aMsgI) //RBORGES 26/11/15 - Dispara E-mail dos pedidos com data de entrega vencida
EndIf
*/
		
Return

/*------------------------------------------------------------------------+
+ Funcao:_EMailPC()    |  Autor: RBORGES     |      Data: 26/11/15        +                                                     
+ Fará tratamento para enviar E-mail dos pedidos de compras com data de   +
+ entrega vencida.                                                        +
-------------------------------------------------------------------------*/

User Function _EMailPC(cEmail,cAssunto,aMsgJ)

Local cAccount  := Lower(Alltrim(GetMv("MV_RELACNT")))
Local cFrom     := Lower(Alltrim(GetMv("MV_RELACNT")))
Local cPassword := Alltrim(GetMv("MV_RELPSW"))
Local cServer   := Alltrim(GetMv("MV_RELSERV"))
Local cEmailTo  := ""
Local cEmailCc  := ""
Local cEmailBcc := ""
Local lResult   := .F.
Local cError    := ""
Local cMsg      := ""
Local nI
Local lSmtpAuth := GetNewPar("MV_RELAUTH",.F.)
Local lAutOk	:= .F.
Local _cPedido  := aMsgJ[1,1]
Local cFornec   := "99999_"
Local cAssuntob := DecodeUTF8(cAssunto, "cp1252")

/*=============================================================================*/
/*Definicao do cabecalho do email                                              */
/*=============================================================================*/
cMsg := ""
cMsg += '<html>'
cMsg += '<head>'
cMsg += '<title>' + cAssunto + '</title>'
cMsg += '</head>'
cMsg += '<body>'
cMsg += '<HR Width=100% Size=3 Align=Centered Color=Red> <P>'
cMsg += '<Table Align=Center BorderColor=#000000 CELLPADDING=4 CELLSPACING=0 Width=100%>'

cMsg += '<table width="100%">'
cMsg += '<tr>'
cMsg += '<td width="100%" colspan="2" Align="Center" ><font size="4" color="red">' +cAssuntob+ '</font></td>'
cMsg += '</tr>'
cMsg += '</table>'

/*=============================================================================*/
/*Definicao do texto/detalhe do email                                          */
/*=============================================================================*/

For nI := 1 to Len(aMsgJ)
	
	nLin := nI
	
	If cFornec <> aMsgJ[nLin,8]
		cMsg += '<table width="100%" cellspacing="0" cellpadding="0"><font size="2" color="white">'
		cMsg += '<tr>'
		cMsg += '<td width="100%">-</td>'
		cMsg += '</tr>'
		cMsg += '</font></table>'
		cMsg += '<table width="100%" cellspacing="0" cellpadding="0"><font size="2" color="DarkRed">'
		cMsg += '<tr>'
		cMsg += '<td Width="55%" Align="LEFT">'+aMsgJ[nLin,8]+''+aMsgJ[nLin,9]+'</td>'
		cMsg += '<td Width="25%" Align="LEFT">'+aMsgJ[nLin,12]+'</td>'
		cMsg += '<td Width="20%" Align="LEFT">'+aMsgJ[nLin,13]+'</td>'
		cMsg += '</tr>'
		cMsg += '<tr>'
		cMsg += '<td Width="55%" Align="LEFT">'+aMsgJ[nLin,14]+'</td>'
		cMsg += '</tr>'
		cMsg += '</font></table>'
		
		cMsg += '<table width="100%" cellspacing="0" cellpadding="0"><font size="2" color="blue">'
		cMsg += '<tr>'
		cMsg += '<td>==========================================================================================================================================================================================</td>'
		cMsg += '</tr>'
		cMsg += '</font></table>'
		cMsg += '<table width="100%" Border="0" cellspacing="0" cellpadding="0"><font size="2" color="DarkBlue">'
		cMsg += '<tr>'
		cMsg += '<td width="5% " Align="Left"><b>Pedido</b></td>'
		cMsg += '<td width="4% " Align="Left"><b>Item</b></td>'
		cMsg += '<td width="44%" Align="Left"><b>Produto</b></td>'
		cMsg += '<td width="8% " Align="Left"><b>Quantidade</b></td>'
		cMsg += '<td width="8% " Align="Left"><b>Qtd. Entregue</b></td>'
		cMsg += '<td width="8% " Align="Left"><b>Saldo Entregar</b></td>'
		cMsg += '<td width="7% " Align="Left"><b>Preço Unit.</b></td>'
		cMsg += '<td width="8% " Align="Left"><b>Data Emissao</b></td>'
		cMsg += '<td width="8% " Align="Center"><b>Data Ent.Dipromed</b></td>'
		cMsg += '</tr>'
		cMsg += '</font></table>'
		cMsg += '<table width="100%" cellspacing="0" cellpadding="0"><font size="2" color="blue">'
		cMsg += '<tr>'
		cMsg += '<td>==========================================================================================================================================================================================</td>'
		cMsg += '</tr>'
		cMsg += '</font></table>'
		
		If nI = 1
			cMsg += '<table width="100%" cellspacing="0" cellpadding="0"><font size="2" color="white">'
			cMsg += '<tr>'
			cMsg += '<td width="100%">-</td>'
			cMsg += '</tr>'
			cMsg += '</font></table>'
		EndIf
	EndIf
	
	If _cPedido == aMsgJ[nLin,1]
		
		If Mod(nLin,2) == 0
			
			cMsg += '<table width="100%" border="0" cellspacing="0" cellpadding="0">'
			cMsg += '<tr bgcolor="#B0E2FF">'
			cMsg += '<td width="5%"  Align="Left"><font size="2">'+aMsgJ[nLin,1]+'</font></td>'
			cMsg += '<td width="4%"  Align="Left"><font size="2">'+aMsgJ[nLin,10]+'</font></td>'			
			cMsg += '<td width="44%" Align="Left"><font size="2">'+aMsgJ[nLin,2]+ '</font></td>'
			cMsg += '<td width="8%"  Align="Left"><font size="2" color="Blue">' +cValToChar(aMsgJ[nLin,3])+ '</font></td>'
			cMsg += '<td width="8%"  Align="Left"><font size="2" color="Blue">' +cValToChar(aMsgJ[nLin,4])+ '</font></td>'
			cMsg += '<td width="8%"  Align="Left"><font size="2" color="Blue">' +cValToChar(aMsgJ[nLin,5])+ '</font></td>'
			cMsg += '<td width="7%"  Align="Left"><font size="2" color="Blue">' +Transform(aMsgJ[nLin,11],"@E 999,999.99")+'</font></td>'
			cMsg += '<td width="8%"  Align="Left"><font size="2" color="Blue">' +DToC(aMsgJ[nLin,6])+ '</font></td>'
			cMsg += '<td width="8%"  Align="Right"><font size="2" color="Blue">' +DToC(aMsgJ[nLin,7])+ '</font></td>'
			cMsg += '</tr>'
			cMsg += '</table>'
		Else
			cMsg += '<table width="100%" border="0" cellspacing="0" cellpadding="0">'
			cMsg += '<tr bgcolor="##CCCCCC">'
			cMsg += '<td width="5%"  Align="Left"><font size="2">'+aMsgJ[nLin,1]+'</font></td>'
			cMsg += '<td width="4%"  Align="Left"><font size="2">'+aMsgJ[nLin,10]+'</font></td>'			
			cMsg += '<td width="44%" Align="Left"><font size="2">'+aMsgJ[nLin,2]+ '</font></td>'
			cMsg += '<td width="8%"  Align="Left"><font size="2" color="Blue">' +cValToChar(aMsgJ[nLin,3])+ '</font></td>'
			cMsg += '<td width="8%"  Align="Left"><font size="2" color="Blue">' +cValToChar(aMsgJ[nLin,4])+ '</font></td>'
			cMsg += '<td width="8%"  Align="Left"><font size="2" color="Blue">' +cValToChar(aMsgJ[nLin,5])+ '</font></td>'
			cMsg += '<td width="7%"  Align="Left"><font size="2" color="Blue">' +Transform(aMsgJ[nLin,11],"@E 999,999.99")+'</font></td>'
			cMsg += '<td width="8%"  Align="Left"><font size="2" color="Blue">' +DToC(aMsgJ[nLin,6])+ '</font></td>'
			cMsg += '<td width="8%"  Align="Right"><font size="2" color="Blue">' +DToC(aMsgJ[nLin,7])+ '</font></td>'
			cMsg += '</tr>'
			cMsg += '</table>'
		EndIf
	Else
		cMsg += '<table width="100%" cellspacing="0" cellpadding="0"><font size="2" color="white">'
		cMsg += '<tr>'
		cMsg += '<td width="100%">-</td>'
		cMsg += '</tr>'
		cMsg += '</font></table>'
		
		If Mod(nLin,2) == 0
			cMsg += '<table width="100%" border="0" cellspacing="0" cellpadding="0">'
			cMsg += '<tr bgcolor="#B0E2FF">'
			cMsg += '<td width="5%"  Align="Left"><font size="2">'+aMsgJ[nLin,1]+'</font></td>'
			cMsg += '<td width="4%"  Align="Left"><font size="2">'+aMsgJ[nLin,10]+'</font></td>'			
			cMsg += '<td width="44%" Align="Left"><font size="2">'+aMsgJ[nLin,2]+ '</font></td>'
			cMsg += '<td width="8%"  Align="Left"><font size="2" color="Blue">' +cValToChar(aMsgJ[nLin,3])+ '</font></td>'
			cMsg += '<td width="8%"  Align="Left"><font size="2" color="Blue">' +cValToChar(aMsgJ[nLin,4])+ '</font></td>'
			cMsg += '<td width="8%"  Align="Left"><font size="2" color="Blue">' +cValToChar(aMsgJ[nLin,5])+ '</font></td>'
			cMsg += '<td width="7%"  Align="Left"><font size="2" color="Blue">' +Transform(aMsgJ[nLin,11],"@E 999,999.99")+'</font></td>'
			cMsg += '<td width="8%"  Align="Left"><font size="2" color="Blue">' +DToC(aMsgJ[nLin,6])+ '</font></td>'
			cMsg += '<td width="8%"  Align="Right"><font size="2" color="Blue">' +DToC(aMsgJ[nLin,7])+ '</font></td>'
			cMsg += '</tr>'
			cMsg += '</table>'
		Else
			cMsg += '<table width="100%" border="0" cellspacing="0" cellpadding="0">'
			cMsg += '<tr bgcolor="#CCCCCC">'
			cMsg += '<td width="5%"  Align="Left"><font size="2">'+aMsgJ[nLin,1]+'</font></td>'
			cMsg += '<td width="4%"  Align="Left"><font size="2">'+aMsgJ[nLin,10]+'</font></td>'			
			cMsg += '<td width="44%" Align="Left"><font size="2">'+aMsgJ[nLin,2]+ '</font></td>'
			cMsg += '<td width="8%"  Align="Left"><font size="2" color="Blue">' +cValToChar(aMsgJ[nLin,3])+ '</font></td>'
			cMsg += '<td width="8%"  Align="Left"><font size="2" color="Blue">' +cValToChar(aMsgJ[nLin,4])+ '</font></td>'
			cMsg += '<td width="8%"  Align="Left"><font size="2" color="Blue">' +cValToChar(aMsgJ[nLin,5])+ '</font></td>'
			cMsg += '<td width="7%"  Align="Left"><font size="2" color="Blue">' +Transform(aMsgJ[nLin,11],"@E 999,999.99")+'</font></td>'
			cMsg += '<td width="8%"  Align="Left"><font size="2" color="Blue">' +DToC(aMsgJ[nLin,6])+ '</font></td>'
			cMsg += '<td width="8%"  Align="Right"><font size="2" color="Blue">' +DToC(aMsgJ[nLin,7])+ '</font></td>'
			cMsg += '</tr>'
			cMsg += '</table>'
		EndIf
		
	EndIf
	_cPedido := aMsgJ[nLin,1]
	cFornec  := aMsgJ[nLin,8]
	nLin     += 1
Next


cMsg += '<table width="100%" cellspacing="0" cellpadding="0"><font size="2" color="blue">'
cMsg += '<tr>'
cMsg += '<td>==========================================================================================================================================================================================</td>'
cMsg += '</tr>'
cMsg += '</font></table>'


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Definicao do rodape do email                                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cMsg += '</Table>'
cMsg += '<HR Width=100% Size=3 Align=Centered Color=Red> <P>'
cMsg += '<table width="100%" Align="Center" border="0">'
cMsg += '<tr align="center">'
cMsg += '<td colspan="10"><font color="BLUE" size="2">Mensagem enviada automaticamente pelo sistema PROTHEUS - <font color="BLUE" size="1">(DIPR084.PRW)</td>'
cMsg += '</tr>'
cMsg += '</table>'
cMsg += '</body>'
cMsg += '</html>'
               
If GetNewPar("ES_ATIVJOB",.T.)
	cEmail+=";"+AllTrim(cEmailBcc)
	u_UEnvMail(AllTrim(cEmail),cAssunto,nil,"",cFrom,"_EMailPC(DIPR084.prw)",cMsg)
EndIf


Return(.T.)

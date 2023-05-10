
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณMT175ATU  บAutor  ณReginaldo Borges    บ Data ณ  03/02/16   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ P.E. na confirmacao da liberacao/rejeicao ou estorno do    บฑฑ
ฑฑบ          ณ material.                                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Dipromed - Qualidade                                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#include "RWMAKE.CH" 
#INCLUDE "AP5MAIL.CH"

User Function MT175ATU()
                   
Local nI        := 0                
Local cProd     := ""
Local _cUsuario := UPPER(U_DipUsr())
Private aCampos   := {}

For nI := 1 To Len(Acols)
	
	If aHeader[2,2] <> "D7_ESTORNO"
		If aCols[nI,2] == 2    .And.;
		   aCols[nI,4]  > 0    .And.;
		   aCols[nI,11]== "06" .And.;
		   Empty(aCols[nI,14])
		   
		   cProd := AllTrim(Posicione("SB1",1,xFilial("SB1")+SD7->D7_PRODUTO,"B1_DESC"))	
			
		   			//        Documento         Produto  Desc.Prod   Qtde           Lote       Local     Usuario
			aadd(aCampos,{SD7->D7_NUMERO,SD7->D7_PRODUTO,cProd,aCols[nI,4],SD7->D7_LOTECTL,aCols[nI,11],aCols[nI,7],M->QEL_JUSTLA})
			
		EndIf
	EndIf
	
Next

If Len(aCampos) > 0
	
	// Chamada das fun็๕es de e-mail e CIC.
	cEmail := GetNewPar("ES_EMTRAQ","reginaldo.borges@dipromed.com.br;qualidade@dipromed.com.br")
	cAssunto:= EncodeUTF8('TRANSFERสNCIA PARA O LOCAL '+aCampos[1,6]+' - DOCUMENTO: ' + SD7->D7_NUMERO +" - "+AllTrim(SM0->M0_NOME)+"/"+AllTrim(SM0->M0_FILIAL),"cp1252")
	U_EMailTQ(cEmail,cAssunto,aCampos)
	
	CicTAQua()
	
EndIf

Return

/*------------------------------------------------------------------------+
+ Funcao:EMailTQ() | Autor: Reginaldo Borges|      Data: 02/03/16         +                                                     
+ Farแ tratamento para enviar E-mail de todas as transfer๊ncias           +
+ do local 01 para o 6 e 8 pela inspecao e armazenamento.                 +
-------------------------------------------------------------------------*/

User Function EMailTQ(cEmail,cAssunto,aMsg1)

Local cAccount  := Lower(Alltrim(GetMv("MV_RELACNT")))
Local cFrom     := "protheus@dipromed.com.br"
Local cPassword := Alltrim(GetMv("MV_RELPSW"))
Local cServer   := Alltrim(GetMv("MV_RELSERV"))
Local cEmailTo  := ""
Local cEmailCc  := ""
Local cEmailBcc := ""
Local lResult   := .F.
Local cError    := ""
Local cMsg      := ""
Local nI
Local lSmtpAuth := GetNewPar("MV_RELAUTQ",.F.)
Local lAutOk	:= .F.

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

/*=============================================================================*/
/*Definicao do cabecalho do relat๓rio                                          */
/*=============================================================================*/

cMsg += '<table width="100%">'
cMsg += '<tr>'
cMsg += '<td width="100%" colspan="2"><font size="4" color="red">Documento - ' + aCampos[1,1] + '</font></td>'
cMsg += '</tr>'
cMsg += '<tr>'
//cMsg += '<td width="50%"><font size="2" color="blue">Num. Transf: ' + aMsg1[1,2]  + '</font></td>'
//cMsg += '<td width="50%"><font size="2" color="blue">Emissใo: '     + SubStr(aMsg1[1,3],7,2)+'/'+ SubStr(aMsg1[1,3],5,2)+'/'+ SubStr(aMsg1[1,3],1,4) + '</font></td>
cMsg += '</tr>'
cMsg += '</table>'

cMsg += '<table width="100%" cellspacing="0" cellpadding="0"><font size="2" color="blue">'
cMsg += '<tr>'
cMsg += '<td>==========================================================================================================================================================================================</td>'
cMsg += '</tr>'
cMsg += '</font></table>'

cMsg += '<table width="100%" cellspacing="0" cellpadding="0"><font size="2" color="blue">'
cMsg += '<td width="10%">Produto</td>'
cMsg += '<td width="50%">Descricao</td>'
cMsg += '<td width="10%">Quantidade</td>'
cMsg += '<td width="10%">Lote</td>'
cMsg += '<td width="10%">Local Dest.</td>'
cMsg += '<td width="10%">Usuario</td>'
cMsg += '</tr>'
cMsg += '</font></table>'

cMsg += '<table width="100%" cellspacing="0" cellpadding="0"><font size="2" color="blue">'
cMsg += '<tr>'
cMsg += '<td>==========================================================================================================================================================================================</td>'
cMsg += '</tr>'
cMsg += '</font></table>'

/*=============================================================================*/
/*Definicao do texto/detalhe do email                                          */
/*=============================================================================*/

For nI := 1 to Len(aCampos)
	nLin:= nI
	If Mod(nLin,2) == 0
		cMsg += '<table width="100%" border="0" cellspacing="0" cellpadding="0">'
		cMsg += '<tr bgcolor="#B0E2FF">'
		cMsg += '<td width="10%"><font size="2">' +aCampos[nLin,2]+ '</font></td>'
		cMsg += '<td width="50%"><font size="2">' +aCampos[nLin,3]+ '</font></td>'		
		cMsg += '<td width="10%"><font size="2">' +cValToChar(aCampos[nLin,4])+ '</font></td>'
		cMsg += '<td width="10%"><font size="2">' +aCampos[nLin,5]+ '</font></td>'
		cMsg += '<td width="10%"><font size="2">' +aCampos[nLin,6]+ '</font></td>'
		cMsg += '<td width="10%"><font size="2">' +Upper(aCampos[nLin,7])+ '</font></td>'
		cMsg += '</tr>'
		cMsg += '</table>'
		cMsg += '<table width="100%" border="0" cellspacing="0" cellpadding="0">'
		cMsg += '<tr>'
		cMsg += '<td width="10%"><font size="2">JUSTIFICATIVA:</font></td>'
		cMsg += '<td width="90%"><font size="2">' +Upper(aCampos[nLin,8])+ '</font></td>'
		cMsg += '</tr>'
		cMsg += '</table>'
	Else
		cMsg += '<table width="100%" border="0" cellspacing="0" cellpadding="0">'
		cMsg += '<tr bgcolor="#c0c0c0">'
		cMsg += '<td width="10%"><font size="2">' +aCampos[nLin,2]+ '</font></td>'
		cMsg += '<td width="50%"><font size="2">' +aCampos[nLin,3]+ '</font></td>'		
		cMsg += '<td width="10%"><font size="2">' +cValToChar(aCampos[nLin,4])+ '</font></td>'
		cMsg += '<td width="10%"><font size="2">' +aCampos[nLin,5]+ '</font></td>'
		cMsg += '<td width="10%"><font size="2">' +aCampos[nLin,6]+ '</font></td>'
		cMsg += '<td width="10%"><font size="2">' +Upper(aCampos[nLin,7])+ '</font></td>'
		cMsg += '</tr>'
		cMsg += '</table>'
		cMsg += '<table width="100%" border="0" cellspacing="0" cellpadding="0">'
		cMsg += '<tr>'
		cMsg += '<td width="10%"><font size="2">JUSTIFICATIVA</font></td>'
		cMsg += '<td width="90%"><font size="2">' +Upper(aCampos[nLin,8])+ '</font></td>'
		cMsg += '</tr>'
		cMsg += '</table>'		
	EndIf
Next

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Definicao do rodape do email                                                ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
cMsg += '</Table>'
cMsg += '<HR Width=100% Size=3 Align=Centered Color=Red> <P>'
cMsg += '<table width="100%" Align="Center" border="0">'
cMsg += '<tr align="center">'
cMsg += '<td colspan="10"><font color="BLUE" size="2">Mensagem enviada automaticamente pelo sistema PROTHEUS - <font color="BLUE" size="1">(MT175ATU.PRW)</td>'
cMsg += '</tr>'
cMsg += '</table>'
cMsg += '</body>'
cMsg += '</html>'


If GetNewPar("ES_ATIVJOB",.T.)   
	u_UEnvMail(AllTrim(cEmail),cAssunto,nil,"",cFrom,"EMailTQ(MT175ATU.prw)",cMsg)
EndIf


Return(.T.)                   


/*------------------------------------------------------------------------+
+ Funcao:CicTAQua()| Autor: Reginaldo Borges  |     Data: 02/03/16        +                                                     
+ Farแ tratamento para enviar CIC de aviso de todas as transfer๊ncias     +
+ do local 01 para o 6 e 8 pela inspecao e armazenamento.                 +
-------------------------------------------------------------------------*/

*--------------------------------------------------------------------------*
Static Function CicTAQua()
*--------------------------------------------------------------------------*
	
	Local aArea       := GetArea()
	Local cDeIc       := "protheus@dipromed.com.br"
    Local cCICDest    := Upper(GetNewPar("ES_CIC_TQ","REGINALDO.BORGES,RAFAELA.BEAZIN"))
	Local cAttachIc   :=  "  a"
	Local cFuncSentIc :=   "MT175ATU.PRW "
 	
		dbSelectArea("SM0")
		
	_aMsgIc := {}
	cMSGcIC       := " EMPRESA:__ " + Capital( AllTrim( GetAdvFVal( "SM0", "M0_NOME", cEmpAnt + cFilAnt, 1, "" ) ) ) +"/"+ Capital( AllTrim( GetAdvFVal( "SM0", "M0_FILIAL" , cEmpAnt + cFilAnt, 1, "" ) ) )   +CHR(13)+CHR(10)+CHR(13)+CHR(10)
    cMSGcIC       += "TRANSFERENCIA ENTRE ARMAZENS - VERIFICAR E-MAIL!"	+CHR(13)+CHR(10)+CHR(13)+CHR(10)
	cMSGcIC       += " DOCUMENTO:  " +SD7->D7_NUMERO +" - "+ " OPERADOR.: " +Upper(SD7->D7_USUARIO) 
                        	
   	U_DIPCIC(cMSGcIC,cCICDest)
   	  		
    RestArea(aArea)	

Return() 



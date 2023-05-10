/*====================================================================================\
|Programa  | DIPRANV  | Autor | Rafael Blandino              | Data | 19/05/2022   |
|=====================================================================================|
|Descrição | Disparar e-mail para os clientes com Anvisa próximos a vencer e ou        |
|          | vencidos.                                                                |
|          |                                                                          |
|=====================================================================================|
|Sintaxe   | DIPRANV                                                                  |
|=====================================================================================|
|Uso       | Especifico DIPROMED                                                      |
|=====================================================================================|
|........................................Histórico....................................|
|Blandino  | DD/MM/AA - Descrição                                                     |
|          | 																		  |
\====================================================================================*/

#INCLUDE "RWMAKE.CH"
#INCLUDE "AP5MAIL.CH"
#INCLUDE "TBICONN.CH"

#DEFINE ENTER CHR(13)+CHR(10) 

User Function DIPRANV(aWork)

Local _xArea := GetArea()
Private cWorkFlow	:= ""
Private cWCodEmp    := ""
Private cWCodFil    := ""

cWorkFlow := aWork[1]
cWCodEmp  := aWork[2]
cWCodFil  := aWork[3]

PREPARE ENVIRONMENT EMPRESA cWCodEmp FILIAL cWCodFil FUNNAME "DIPRANV"

RunProc()	// Relatório de clientes conforme critérios

RestArea(_xArea)                    

Return


/*=============================================\
|PROCESSAMENTO DOS DADOS E ENVIO DO E-MAIL
\=============================================*/
Static Function RunProc()

Local cEmail     := ""
Local cAssunto   := EncodeUTF8("ATENÇÃO! NOTIFICAÇÃO DE VENCIMENTO DO(S) ANVISA(S).","cp1252")
Local cCliente   := ""
Local aEmDipr100 := {}
Local aEmDip100b := {}
Local nI         := 1
Local nDiasVenc  := 0
Local nDiasVenc_R:= 0
Local cMsgbody   := ""
Local cMsgCabe   := ""
Local dDataVenc  := "  /  /  "
Local dDataHoje  := DToS(date())


//************** QUERY PARA BUSCAR OS CLIENTES CONFORME CRITÉRIOS***************** 

QRY2 := "Select A1_COD, A1_NOME, A1_LFVISA, A1_VLLVISA,A1_TIPO,A1_EMAIL From SA1010"
QRY2 +="Where A1_TIPO = 'R' And A1_PESSOA = 'J' And A1_RISCO Between 'B' And 'C' And A1_VLLVISA <= 'DATABASE' + 15
QRY2 +="And A1_LFVISA <> ' ' And A1_VEND Not In ('006743','000359','0006949') And D_E_L_E_T_ = ' '"
QRY2 += " ORDER BY A1_COD"

QRY2 := ChangeQuery(QRY2)
dbUseArea(.T., "TOPCONN", TCGenQry(,,QRY2), 'QRYSB1', .T., .T.)

memowrite('DIPRANV.SQL',QRY2)

//-----------------------------------------------------------

DbSelectArea("QRYSB1")
DbGoTop()

While QRYSE1->(!EOF())
				   * 1					 2                 3               4            	  5									          
	Aadd(aEmDiprAnv,{QRYSB1->A1_COD, QRYSB1->A1_NOME,  QRYSB1->A1_LFVISA, QRYSB1->A1_VLLVISA, QRYSB1->A1_EMAIL})
	QRYSB1->(DbSkip())
	
EndDo

QRYSB1->(dbCloseArea())

If Len(aEmDipr100) > 0

	cCliente := aEmDiprAnv[nI,1]
	nDiasVenc:= aEmDiprAnv[nI,4]
	dDataVenc:= DTOC(STOD(aEmDiprAnv[nI,4]))
	
	cEmail   := AllTrim(aEmDiprAnv[nI,5])
	
	
	For nI := 1 To Len(aEmDiprAnv)
		
		If aEmDiprAnv[nI,1] == cCliente
			
						   //COD_CLIENTE      NOME             ANVISA      VALIDADE ANVISA          EMAIL
			Aadd(aEmDiprAnvb,{aEmDiprAnv[nI,1],aEmDiprAnv[nI,2],aEmDiprAnv[nI,3],aEmDiprAnv[nI,4],aEmDiprAnv[nI,5]})
	
		Else
			
			Msgbody(nDiasVenc,nDiasVenc_R,dDataVenc,@cAssunto,@cMsgbody,@cMsgCabe)
			 
			ENV_100(cEmail,cAssunto,aEmDiprAnvb,cMsgbody,cMsgCabe)
			
			cEmail     := ""
			cMsgbody   := ""
			cMsgCabe   := ""
			aEmDiprAnvb := {}
			
				   				//COD_CLIENTE      NOME             ANVISA      VALIDADE ANVISA         EMAIL
			Aadd(aEmDiprAnvb,{aEmDiprAnv[nI,1],aEmDiprAnv[nI,2],aEmDiprAnv[nI,3],aEmDiprAnv[nI,4],aEmDiprAnv[nI,5]})

		EndIf
		
		cCliente   := aEmDiprAnv[nI,1]
		nDiasVenc  := aEmDiprAnv[nI,4]
		dDataVenc  := DTOC(STOD(aEmDiprAnv[nI,5]))
		
		cEmail   := AllTrim(aEmDiprAnv[nI,5])
		
	Next
	
	Msgbody(nDiasVenc,dDataVenc,@cAssunto,@cMsgbody,@cMsgCabe)
	
	ENV_100(cEmail,cAssunto,aEmDiprAnvb,cMsgbody,cMsgCabe)
	
	
EndIf


Return(.T.)      

/*==========================================================================\
|Programa  | ENV_100 | Autor | Reginaldo Borges   |      Data ³ 22/04/2019  |
|===========================================================================|
|Desc.     | E-mail notificando o vencimento de titulos.                    |
|===========================================================================|
|Sintaxe   | ENV_100                                                        |
|===========================================================================|
|Uso       | Especifico DIPROMED                                            |
\==========================================================================*/

Static Function ENV_100(cEmail,cAssunto,aEmDiprAnvb,cMsgbody,cMsgCabe)

Local cAccount  := Lower(Alltrim(GetMv("MV_RELACNT")))
Local cFrom     := Lower(Alltrim(GetMv("MV_RELACNT")))
Local cPassword := Alltrim(GetMv("MV_RELPSW"))
Local cServer   := Alltrim(GetMv("MV_RELSERV"))
Local cEmailTo  := cEmail
Local cEmailCc  := AllTrim(GetNewPar("ES_VENTIT"," deise.mistron@dipromed.com.br;rafael.blandino@dipromed.com.br;maximo@dipromed.com.br"))
Local cEmailBcc := ""
Local lResult   := .F.
Local cError    := ""
Local cMsg      := ""
Local lSmtpAuth := GetNewPar("MV_RELAUTH",.F.)
Local lAutOk	:= .F.
Local nI        := 0
Local nLin      := 0
Local CATTACH := ""

    
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Definicao do cabecalho do email                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   
cMsg := ""
cMsg += '<html>'
cMsg += '<head>'
cMsg += '<title>' + cAssunto +'</title>'
cMsg += '</head>'
cMsg += '<body>'
cMsg += '<HR Width=100% Size=3 Align=Centered Color=Red> <P>'
cMsg += '<Table Border=1 Align=Center BorderColor=#000000 cellspacing="0" cellpadding="0" Width=100%>'
cMsg += '<font color=#000000 face= "arial" size=2>'+cMsgCabe+cEmail+'</font> '


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Definicao do texto/detalhe do email                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
         
cMsg += '<table width="100%" border="1" cellspacing="2" cellpadding="0">'
cMsg += '<td width="5%"  align=center><font  size="2" color="blue"> CLIENTE    		</font></td>'
cMsg += '<td width="30%" align=center><font  size="2" color="blue"> NOME       		</font></td>'
cMsg += '<td width="8%"  align=center><font  size="2" color="blue"> ANVISA     		</font></td>'
cMsg += '<td width="5%"  align=center><font  size="2" color="blue"> VALIDADE ANVISA	</font></td>'
cMsg += '<td width="20%" align=center><font  size="2" color="blue"> EMAIL 			</font></td>'

//cMsg+= '</font></table>'	 

For nI := 1 to Len(aEmDiprAnvb)
	nLin:= nI
	If Mod(nLin,2) == 0
		//cMsg += '<table width="100%" border="1" cellspacing="0" cellpadding="0">'
		//cMsg += '<tr bgcolor="#FFFAFA">'
		cMsg += '<td width="5%"  align=center><font  size="2">' +aEmDiprAnvb[nLin,1]+ '</font></td>'   // Codigo Cliente
		cMsg += '<td width="30%"> <font  size="2">' +aEmDiprAnvb[nLin,2]+ '</font></td>'  // Nome Cliente
		cMsg += '<td width="5%"  align=center><font  size="2">' +aEmDiprAnvb[nLin,3]+ '</font></td>'	 // Nota Fiscal 			
		cMsg += '<td width="5%"  align=center><font  size="2">' +aEmDiprAnvb[nLin,6]+ '</font></td>'   // Parcela
		cMsg += '<td width="8%"  align=center><font  size="2">' +DTOC(STOD(aEmDiprAnvb[nLin,4]))+ '</font></td>' // Emissao
		cMsg += '<td width="8%"  align=center><font  size="2">' +DTOC(STOD(aEmDiprAnvb[nLin,5]))+ '</font></td>' // Vencimento
		cMsg += '<td width="5%"  align=center><font  size="2">' +CVALTOCHAR(aEmDiprAnvb[nLin,7])+ '</font></td>'   // Valor 	
		cMsg += '<td width="4%"  align=center><font  size="2">' +aEmDiprAnvb[nLin,8]+ '</font></td>'   // Banco
		cMsg += '<td width="10%" align=center><font  size="2">' +aEmDiprAnvb[nLin,9]+ '</font></td>'  // Status  
		cMsg += '<td width="20%" align=center><font  size="2">' +aEmDiprAnvb[nLin,10]+ '</font></td>' //	Vendedor(a)		
		cMsg += '</tr>'
		//cMsg += '</table>'
	Else
		//cMsg += '<table width="100%" border="1" cellspacing="0" cellpadding="0">'
		cMsg += '<tr bgcolor="#FFFAFA">'
		cMsg += '<td width="5%"  align=center><font  size="2">' +aEmDiprAnvb[nLin,1]+ '</font></td>'   // Codigo Cliente
		cMsg += '<td width="30%"> <font  size="2">' +aEmDiprAnvb[nLin,2]+ '</font></td>'  // Nome Cliente
		cMsg += '<td width="5%"  align=center><font  size="2">' +aEmDiprAnvb[nLin,3]+ '</font></td>'	 // Nota Fiscal 			
		cMsg += '<td width="5%"  align=center><font  size="2">' +aEmDiprAnvb[nLin,6]+ '</font></td>'   // Parcela
		cMsg += '<td width="8%"  align=center><font  size="2">' +DTOC(STOD(aEmDiprAnvb[nLin,4]))+ '</font></td>' // Emissao
		cMsg += '<td width="8%"  align=center><font  size="2">' +DTOC(STOD(aEmDiprAnvb[nLin,5]))+ '</font></td>' // Vencimento
		cMsg += '<td width="5%"  align=center><font  size="2">' +CVALTOCHAR(aEmDiprAnvb[nLin,7])+ '</font></td>'   // Valor 	
		cMsg += '<td width="4%"  align=center><font  size="2">' +aEmDiprAnvb[nLin,8]+ '</font></td>'   // Banco
		cMsg += '<td width="10%" align=center><font  size="2">' +aEmDiprAnvb[nLin,9]+ '</font></td>'  // Status  
		cMsg += '<td width="20%" align=center><font  size="2">' +aEmDiprAnvb[nLin,10]+ '</font></td>' //	Vendedor(a)		
		cMsg += '</tr>'
		//cMsg += '</table>'
	EndIf	
Next 

cMsg += '</table>'

cMsg += '<TR>'	    
cMsg += '<TD colspan="10"> <Font Color=#000000 Size="2" Face="Arial">'+cMsgbody+'</Font></TD>'
cMsg += '</TR>'

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Definicao do rodape do email                                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ    
	
cMsg += '</Table>'
cMsg += '<P>'
cMsg += '<Table align="center">'
cMsg += '<tr>'
cMsg += '<td colspan="10" align="center"><font color="red" size="3">Mensagem enviada automaticamente pelo sistema PROTHEUS - <font color="red" size="1">(DIPRANV)</td>'
cMsg += '</tr>'
cMsg += '</Table>'
cMsg += '<HR Width=100% Size=3 Align=Centered Color=Red> <P>'
cMsg += '</body>'
cMsg += '</html>' 
	

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
	ATTACHMENT  cAttach;
	RESULT lResult
	
	If !lResult
		//Erro no envio do email
		GET MAIL ERROR cError
			
		MsgInfo(cError,OemToAnsi("Atencao"))
	EndIf
		
	DISCONNECT SMTP SERVER
Else
	//Erro na conexao com o SMTP Server
	GET MAIL ERROR cError
		MsgInfo(cError,OemToAnsi("Atencao"))
EndIf
	

Return(.T.)

/*
+====================================================+
|	Carregar a mensagem padrão do corpo do e-mail    |
+====================================================+
*/

Static Function Msgbody(nDiasVenc,nDiasVenc_R,dDataVenc,cAssunto,cMsgbody,cMsgCabe)

If     nDiasVenc == -3

	cAssunto := "Comunicado de Anvisa a vencer!"
	
	cMsgCabe := ''+ENTER
	cMsgCabe += '<font face="Arial" size=4><B> DIPROMED COMÉRCIO E IMPORTAÇÃO LTDA. </B></font>'+ENTER
	cMsgCabe += ''+ENTER
	cMsgCabe += '<font face="Arial" size=2><B>Prezado (a) Senhor (a),</B></font>'+ENTER
	cMsgCabe += '<font face="Arial" size=2> Para a Dipromed é muito importante tê-lo como nosso cliente, para tanto, de forma proativa, informamos que há título(s) emitido(s) pela Dipromed à vossa empresa com vencimento no(s) próximo(s) dia(s) útil(eis), conforme informação abaixo. </font>'+ENTER
	cMsgCabe += ''+ENTER
	
	cMsgbody := ''+ENTER
	cMsgbody += '<font face="Arial" size=2> Na eventualidade de ainda não ter recebido os boletos, seja por correio ou mesmo instrução DDA, solicitamos contato imediato de V.Sa(s) através do(s) telefone(s): </font>'+ENTER 
	cMsgbody += '<font face="Arial" size=2> 11-3646-0179 com Daniele Baraldi daniele.baraldi@dipromed.com.br ou </font>'+ENTER
	cMsgbody += '<font face="Arial" size=2> 11-3646-0178 com Sidnéia Domingos sidneia.domingos@dipromed.com.br.  </font>'+ENTER
	cMsgbody += ''+ENTER
	cMsgbody += '<font face="Arial" size=2> Esperamos com tal iniciativa contribuir com sua programação financeira e estabelecer canal de comunicação mais eficaz entre vossa empresa e nosso departamento financeiro. </font>'+ENTER
	cMsgbody += ''+ENTER
	cMsgbody += '<font face="Arial" size=2> Agradecemos desde já por vossa atenção, colocando-nos a disposição para eventuais esclarecimentos necessários. </font>'+ENTER
	cMsgbody += ''+ENTER
	cMsgbody += '<font face="Arial" size=2> Srs. clientes, favor se atentarem a boletos de email, na qual não pertence a Dipromed. Estão sendo enviados boletos com descontos dos bancos Santander e banco do Brasil. Trata-se de (FRAUDE) onde os Srs. clientes devem consultar a  </font>'+ENTER 
	cMsgbody += '<font face="Arial" size=2> Dipromed para verificar a veracidade das informações. </font>'+ENTER
	cMsgbody += ''+ENTER


ElseIf nDiasVenc == 1 .Or. nDiasVenc == 3 .Or. nDiasVenc_R == 1
	
	cAssunto := "Titulo(s) vencido(s)!"
	
	cMsgCabe := ''+ENTER
	cMsgCabe += '<font face="Arial" size=4><B> DIPROMED COMÉRCIO E IMPORTAÇÃO LTDA </B></font>'+ENTER
	cMsgCabe += ''+ENTER
	cMsgCabe += '<font face="Arial" size=2><B>Prezado (a) Senhor (a),</B></font>'+ENTER
	cMsgCabe += '<font face="Arial" size=2> Com o presente, tomamos a liberdade de lembrar ao prezado (a) cliente o vencimento do débito abaixo citado, de sua responsabilidade, e cuja liquidação solicitamos as devidas providências. </font>'+ENTER
	cMsgCabe += ''+ENTER
	
	cMsgbody := ''+ENTER
	cMsgbody += '<font face="Arial" size=2> Lembramos que o pagamento desta(s) duplicata(s) deve ser realizado em até 5 dias corridos do vencimento, conforme instruções constantes no boleto bancário.</font>'+ENTER 
	cMsgbody += ''+ENTER
	cMsgbody += '<font face="Arial" size=2> O pagamento gerará a imediata regularização em nossos arquivos. </font>'+ENTER
	cMsgbody += ''+ENTER
	cMsgbody += '<font face="Arial" color=#0000FF size=3> Observação: Pedimos atenção especial ao receber os boletos do Banco Itaú, pois o mesmo tem nos alertado que enviará em cada folha dois boletos de cobrança diferentes, a fim de diminuir o consumo de papel.</font>'+ENTER
	cMsgbody += ''+ENTER
	cMsgbody += '<font face="Arial" size=2> Qualquer dúvida entre em contato conosco através do(s) telefone(s): 11-3646-0160 ramal 0179 com Daniele Baraldi, ramal 0178 com Sidnéia Domingos</font>'+ENTER
	cMsgbody += ''+ENTER
	cMsgbody += '<font face="Arial" size=2> Com os antecipados agradecimentos pela atenção que a presente merecer, firmamo-nos.</font>'+ENTER
	cMsgbody += ''+ENTER
	cMsgbody += '<font face="Arial" color=#FF0000 size=3><B> Caso o pagamento já tenha sido efetuado, por favor, desconsidere este aviso. </B></font>'+ENTER
	cMsgbody += ''+ENTER
	
	
Else
	
	cAssunto := EncodeUTF8("Quite seu boleto hoje e evite cartório!","cp1252")
	
	cMsgCabe := ''+ENTER
	cMsgCabe += '<font face="Arial" size=4><B> DIPROMED COMÉRCIO E IMPORTAÇÃO LTDA </B></font>'+ENTER
	cMsgCabe += ''+ENTER
	cMsgCabe += '<font face="Arial" size=2><B>Prezado (a) Senhor (a),</B></font>'+ENTER
	cMsgCabe += '<font face="Arial" size=2> Reiterando as solicitações que fizemos anteriormente, até o presente momento não recebemos resposta de V.S.as a respeito do não pagamento da(s) duplicata(s) abaixo relacionadas. </font>'+ENTER
	cMsgCabe += ''+ENTER
	
	cMsgbody := ''+ENTER
	cMsgbody += '<font face="Arial" size=2> Informamos que hoje é o prazo limite para liquidação dos títulos que venceram no dia '+dDataVenc+', a partir de amanhã o(s) título(s) em questão será(ão) enviado(s) automaticamente pelo banco para o Cartório de Protestos de Letras e Títulos. </font>'+ENTER
	cMsgbody += ''+ENTER 
	cMsgbody += '<font face="Arial" size=2> Para saldarem esse débito efetuem o pagamento na data de hoje. </font>'+ENTER
	cMsgbody += ''+ENTER	
	cMsgbody += '<font face="Arial" size=2> Qualquer dúvida entre em contato conosco através do(s) telefone(s): 11-3646-0160 ramal 0179 com Daniele Baraldi, ramal 0178 com Sidnéia Domingos</font>'+ENTER
	cMsgbody += ''+ENTER
	cMsgbody += '<font face="Arial" color=#FF0000 size=3><B> Caso o pagamento já tenha sido efetuado, por favor, desconsidere este aviso. </B></font>'+ENTER
	cMsgbody += ''+ENTER
		
EndIf


Return


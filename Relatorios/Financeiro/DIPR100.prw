/*
 =====================================================================================
|Programa  | DIPR100    | Autor | Reginaldo Borges              | Data | 22/04/2019   |
|=====================================================================================|
|Descri��o | Disparar e-mail para os clintes com t�tulos pr�ximos a vencer e          |
|          | vencidos.                                                                |
|          |                                                                          |
|=====================================================================================|
|Sintaxe   | DIPR100                                                                  |
|=====================================================================================|
|Uso       | Especifico DIPROMED                                                      |
|=====================================================================================|
|........................................Hist�rico....................................|
|RBorges   | DD/MM/AA - Descri��o                                                     |
|          | 																		  |
======================================================================================
*/

#INCLUDE "RWMAKE.CH"
#INCLUDE "AP5MAIL.CH"
#INCLUDE "TBICONN.CH"

#DEFINE ENTER CHR(13)+CHR(10) 

User Function DIPR100(aWork)

Local _xArea := GetArea()
Private cWorkFlow	:= ""
Private cWCodEmp    := ""
Private cWCodFil    := ""

cWorkFlow := aWork[1]
cWCodEmp  := aWork[2]
cWCodFil  := aWork[3]

PREPARE ENVIRONMENT EMPRESA cWCodEmp FILIAL cWCodFil FUNNAME "DIPR100"

RunProc()	// Relat�rio dos t�tulos conforme crit�rios

RestArea(_xArea)                    

Return


/*=============================================\
|PROCESSAMENTO DOS DADOS E ENVIO DO E-MAIL
\=============================================*/
Static Function RunProc()

Local cEmail     := ""
Local cAssunto   := EncodeUTF8("ATEN��O! NOTIFICA��O DE VENCIMENTO DO(S) TITULO(S).","cp1252")
Local cCliente   := ""
Local aEmDipr100 := {}
Local aEmDip100b := {}
Local nI         := 1
Local nDiasVenc  := 0
Local nDiasVenc_R:= 0
Local cSatus     := "" 
Local cMsgbody   := ""
Local cMsgCabe   := ""
Local dDataVenc  := "  /  /  "
Local dDataHoje  := DToS(date())


//************** QUERY PARA BUSCAR OS TITULOS CONFORME CRIT�RIOS***************** 

QRY2 := " SELECT E1_FILORIG, E1_CLIENTE, E1_LOJA, A1_NOME, E1_NUM, E1_PARCELA, E1_VALOR, E1_EMISSAO, E1_VENCTO, "
QRY2 += " DATEDIFF(DAY,E1_VENCTO,'"+dDataHoje+"') 'DIAS_VENC', E1_VENCREA, DATEDIFF(DAY,E1_VENCREA,'"+dDataHoje+"') 'DIAS_VENC_R', " 
QRY2 += " (CASE WHEN(DATEDIFF(DAY,E1_VENCTO,'"+dDataHoje+"'))  = -3 THEN 'VENCER� EM 3 DIAS' " 
QRY2 += "       WHEN(DATEDIFF(DAY,E1_VENCREA,'"+dDataHoje+"')) = 1  THEN 'VENCIDO H� 1 DIA' "
QRY2 += "       WHEN(DATEDIFF(DAY,E1_VENCTO,'"+dDataHoje+"'))  = 3  THEN 'VENCIDO H� 1 DIA' "
QRY2 += "       WHEN(DATEDIFF(DAY,E1_VENCTO,'"+dDataHoje+"'))  = 5  THEN 'A 1 DIA DE CARTORIO' " 
QRY2 += "       WHEN(DATEDIFF(DAY,E1_VENCTO,'"+dDataHoje+"'))  = 6  THEN 'A 1 DIA DE CARTORIO' "  
QRY2 += "       WHEN(DATEDIFF(DAY,E1_VENCTO,'"+dDataHoje+"'))  = 7  THEN 'A 1 DIA DE CARTORIO' END) 'STATUS', E1_TIPO, " 
QRY2 += " (CASE WHEN(E1_PORTADO = '341')THEN 'ITAU'ELSE ' ' END) 'BANCO', 
QRY2 += " LOWER(A1_EMAIL) 'EMACLI', LOWER(A1_XEMAILF) 'EMAFIN', A1_VEND 'COD_VEND', "
QRY2 += " (SELECT A3_NOME FROM SA3010   WHERE A3_COD = A1_VEND AND D_E_L_E_T_ = '') 'VENDEDOR', "
QRY2 += " (SELECT A3_EMAIL FROM SA3010   WHERE A3_COD = A1_VEND AND D_E_L_E_T_ = '') 'EMAVEND' "
QRY2 += " FROM  "+ RetSQLName("SE1")+" SE1"
QRY2 += " INNER JOIN "+RetSQLName("SA1")+" SA1 ON A1_COD = E1_CLIENTE AND A1_LOJA = E1_LOJA AND SA1.D_E_L_E_T_ = '' "
QRY2 += " WHERE E1_SALDO > 0 AND "
QRY2 += " E1_TIPO IN ('NF','FT') AND "
QRY2 += " E1_PORTADO = '341' AND "
QRY2 += " E1_VENCTO NOT IN ('20200222','20200223','20200224','20200225') AND " //Tratativa para o Carnaval, retirar ap�s o dia 26/02
If Alltrim(UPPER(DIASEMANA(DDATABASE))) = "SEGUNDA" .AND. ! Alltrim(UPPER(DIASEMANA(DDATABASE))) $ "SABADO/DOMINGO"
	QRY2 += " (DATEDIFF(DAY,E1_VENCTO,'"+dDataHoje+"') = -3 OR "
	QRY2 += "  DATEDIFF(DAY,E1_VENCTO,'"+dDataHoje+"') = 3  OR "
	QRY2 += "  DATEDIFF(DAY,E1_VENCTO,'"+dDataHoje+"') = 5  OR "
	QRY2 += "  DATEDIFF(DAY,E1_VENCTO,'"+dDataHoje+"') = 6  OR "
	QRY2 += "  DATEDIFF(DAY,E1_VENCTO,'"+dDataHoje+"') = 7) AND "
ElseIf ! Alltrim(UPPER(DIASEMANA(DDATABASE))) $ "SABADO/DOMINGO/SEGUNDA" 
	QRY2 += " (DATEDIFF(DAY,E1_VENCTO,'"+dDataHoje+"')  = -3 OR "
	QRY2 += "  DATEDIFF(DAY,E1_VENCREA,'"+dDataHoje+"') = 1  OR "
	QRY2 += "  DATEDIFF(DAY,E1_VENCTO,'"+dDataHoje+"')  = 5) AND "
Else
	QRY2 += " E1_EMISSAO = '20501231' AND "
EndIf
//QRY2 += "  E1_CLIENTE IN ('001145','010005','016643','019480','019653','021427') AND "
QRY2 += " SE1.D_E_L_E_T_ = '' "
QRY2 += " ORDER BY E1_CLIENTE, STATUS, E1_NUM, E1_PARCELA  "

QRY2 := ChangeQuery(QRY2)
dbUseArea(.T., "TOPCONN", TCGenQry(,,QRY2), 'QRYSE1', .T., .T.)

memowrite('DIPR100.SQL',QRY2)

//-----------------------------------------------------------

DbSelectArea("QRYSE1")
DbGoTop()

While QRYSE1->(!EOF())
				   * 1					 2                 3               4            	   5				  6									          
	Aadd(aEmDipr100,{QRYSE1->E1_CLIENTE, QRYSE1->A1_NOME,  QRYSE1->E1_NUM, QRYSE1->E1_EMISSAO, QRYSE1->E1_VENCTO, QRYSE1->E1_PARCELA,;
		              QRYSE1->E1_VALOR, QRYSE1->BANCO, QRYSE1->STATUS, QRYSE1->VENDEDOR, QRYSE1->EMAVEND, QRYSE1->EMACLI, QRYSE1->EMAFIN, QRYSE1->DIAS_VENC, QRYSE1->DIAS_VENC_R})
                   *  7					8			   9               10                11               12              13              14                 15 
	QRYSE1->(DbSkip())
	
EndDo

QRYSE1->(dbCloseArea())

If Len(aEmDipr100) > 0

	cCliente := aEmDipr100[nI,1]
	nDiasVenc:= aEmDipr100[nI,14]
	nDiasVenc_R:= aEmDipr100[nI,15]
	cSatus   := aEmDipr100[nI,9]
	dDataVenc:= DTOC(STOD(aEmDipr100[nI,5]))
	
	If nDiasVenc <> (-3)
		cEmail   := AllTrim(aEmDipr100[nI,13])+";"+AllTrim(aEmDipr100[nI,11])
	Else
		cEmail   := AllTrim(aEmDipr100[nI,13])	
	EndIf	
		 
	
	For nI := 1 To Len(aEmDipr100)
		
		If aEmDipr100[nI,1] == cCliente .And. Alltrim(aEmDipr100[nI,9]) == AllTrim(cSatus) 
			
						   //COD_CLIENTE      NOME             NOTA FISCAL      EMISSAO          VENCIMENTO       PARCELA VALOR BANCO STATUS VENDEDOR(A)
			Aadd(aEmDip100b,{aEmDipr100[nI,1],aEmDipr100[nI,2],aEmDipr100[nI,3],aEmDipr100[nI,4],aEmDipr100[nI,5],aEmDipr100[nI,6],;
							 aEmDipr100[nI,7],aEmDipr100[nI,8],aEmDipr100[nI,9],aEmDipr100[nI,10], aEmDipr100[nI,11], aEmDipr100[nI,13], aEmDipr100[nI,14]})
						   //VALOR            BANCO            STATUS           VENDEDOR(A)        E-MAIL VENDEDOR    E-MAIL FIN        QTD DIAS VENCIMENTO
			
		Else
			
			Msgbody(nDiasVenc,nDiasVenc_R,dDataVenc,@cAssunto,@cMsgbody,@cMsgCabe)
			 
			ENV_100(cEmail,cAssunto,aEmDip100b,cMsgbody,cMsgCabe)
			
			cEmail     := ""
			cMsgbody   := ""
			cMsgCabe   := ""
			aEmDip100b := {}
			
						   //COD_CLIENTE      NOME             NOTA FISCAL      EMISSAO          VENCIMENTO       PARCELA VALOR BANCO STATUS VENDEDOR(A)
			Aadd(aEmDip100b,{aEmDipr100[nI,1],aEmDipr100[nI,2],aEmDipr100[nI,3],aEmDipr100[nI,4],aEmDipr100[nI,5],aEmDipr100[nI,6],;
							 aEmDipr100[nI,7],aEmDipr100[nI,8],aEmDipr100[nI,9],aEmDipr100[nI,10],aEmDipr100[nI,14]})
						   //VALOR            BANCO            STATUS           VENDEDOR(A)		  QTD DIAS VENCIMENTO	
		EndIf
		
		cCliente   := aEmDipr100[nI,1]
		nDiasVenc  := aEmDipr100[nI,14]
		nDiasVenc_R:= aEmDipr100[nI,15]
		cSatus     := aEmDipr100[nI,9] 
		dDataVenc  := DTOC(STOD(aEmDipr100[nI,5]))
		
		If nDiasVenc <> (-3)
			cEmail   := AllTrim(aEmDipr100[nI,13])+";"+AllTrim(aEmDipr100[nI,11])
		Else
			cEmail   := AllTrim(aEmDipr100[nI,13])	
		EndIf	
		
	Next
	
	Msgbody(nDiasVenc,nDiasVenc_R,dDataVenc,@cAssunto,@cMsgbody,@cMsgCabe)
	
	ENV_100(cEmail,cAssunto,aEmDip100b,cMsgbody,cMsgCabe)

	
	
EndIf


Return(.T.)      

/*==========================================================================\
|Programa  | ENV_100 | Autor | Reginaldo Borges   |      Data � 22/04/2019  |
|===========================================================================|
|Desc.     | E-mail notificando o vencimento de titulos.                    |
|===========================================================================|
|Sintaxe   | ENV_100                                                        |
|===========================================================================|
|Uso       | Especifico DIPROMED                                            |
\==========================================================================*/

Static Function ENV_100(cEmail,cAssunto,aEmDip100b,cMsgbody,cMsgCabe)

Local cAccount  := Lower(Alltrim(GetMv("MV_RELACNT")))
Local cFrom     := Lower(Alltrim(GetMv("MV_RELACNT")))
Local cPassword := Alltrim(GetMv("MV_RELPSW"))
Local cServer   := Alltrim(GetMv("MV_RELSERV"))
Local cEmailTo  := cEmail
Local cEmailCc  := AllTrim(GetNewPar("ES_VENTIT"," deise.mistron@dipromed.com.br;daniele.baraldi@dipromed.com.br;sidneia.domingos@dipromed.com.br;maximo@dipromed.com.br"))//cEmail , alterado no dia 24/08/2020 incluido parametro para tratar valida��o dos emails. Blandino
Local cEmailBcc := ""
Local lResult   := .F.
Local cError    := ""
Local cMsg      := ""
Local lSmtpAuth := GetNewPar("MV_RELAUTH",.F.)
Local lAutOk	:= .F.
Local nI        := 0
Local nLin      := 0
Local CATTACH := ""

    
//�����������������������������������������������������������������������������Ŀ
//� Definicao do cabecalho do email                                             �
//�������������������������������������������������������������������������������
   
cMsg := ""
cMsg += '<html>'
cMsg += '<head>'
cMsg += '<title>' + cAssunto +'</title>'
cMsg += '</head>'
cMsg += '<body>'
cMsg += '<HR Width=100% Size=3 Align=Centered Color=Red> <P>'
cMsg += '<Table Border=1 Align=Center BorderColor=#000000 cellspacing="0" cellpadding="0" Width=100%>'
cMsg += '<font color=#000000 face= "arial" size=2>'+cMsgCabe+cEmail+'</font> '


//�����������������������������������������������������������������������������Ŀ
//� Definicao do texto/detalhe do email                                         �
//�������������������������������������������������������������������������������
         
cMsg += '<table width="100%" border="1" cellspacing="2" cellpadding="0">'
cMsg += '<td width="5%"  align=center><font  size="2" color="blue"> CLIENTE    </font></td>'
cMsg += '<td width="30%" align=center><font  size="2" color="blue"> NOME       </font></td>'
cMsg += '<td width="5%"  align=center><font  size="2" color="blue"> N.FISCAL   </font></td>'	 
cMsg += '<td width="5%"  align=center><font  size="2" color="blue"> PARCELA    </font></td>'
cMsg += '<td width="8%"  align=center><font  size="2" color="blue"> EMISSAO    </font></td>'
cMsg += '<td width="8%"  align=center><font  size="2" color="blue"> VENCIMENTO </font></td>'
cMsg += '<td width="5%"  align=center><font  size="2" color="blue"> VALOR      </font></td>'
cMsg += '<td width="4%"  align=center><font  size="2" color="blue"> BANCO      </font></td>'
cMsg += '<td width="10%" align=center><font  size="2" color="blue"> STATUS     </font></td>'
cMsg += '<td width="20%" align=center><font  size="2" color="blue"> VENDEDOR(A)</font></td>'

//cMsg+= '</font></table>'	 

For nI := 1 to Len(aEmDip100b)
	nLin:= nI
	If Mod(nLin,2) == 0
		//cMsg += '<table width="100%" border="1" cellspacing="0" cellpadding="0">'
		//cMsg += '<tr bgcolor="#FFFAFA">'
		cMsg += '<td width="5%"  align=center><font  size="2">' +aEmDip100b[nLin,1]+ '</font></td>'   // Codigo Cliente
		cMsg += '<td width="30%"> <font  size="2">' +aEmDip100b[nLin,2]+ '</font></td>'  // Nome Cliente
		cMsg += '<td width="5%"  align=center><font  size="2">' +aEmDip100b[nLin,3]+ '</font></td>'	 // Nota Fiscal 			
		cMsg += '<td width="5%"  align=center><font  size="2">' +aEmDip100b[nLin,6]+ '</font></td>'   // Parcela
		cMsg += '<td width="8%"  align=center><font  size="2">' +DTOC(STOD(aEmDip100b[nLin,4]))+ '</font></td>' // Emissao
		cMsg += '<td width="8%"  align=center><font  size="2">' +DTOC(STOD(aEmDip100b[nLin,5]))+ '</font></td>' // Vencimento
		cMsg += '<td width="5%"  align=center><font  size="2">' +CVALTOCHAR(aEmDip100b[nLin,7])+ '</font></td>'   // Valor 	
		cMsg += '<td width="4%"  align=center><font  size="2">' +aEmDip100b[nLin,8]+ '</font></td>'   // Banco
		cMsg += '<td width="10%" align=center><font  size="2">' +aEmDip100b[nLin,9]+ '</font></td>'  // Status  
		cMsg += '<td width="20%" align=center><font  size="2">' +aEmDip100b[nLin,10]+ '</font></td>' //	Vendedor(a)		
		cMsg += '</tr>'
		//cMsg += '</table>'
	Else
		//cMsg += '<table width="100%" border="1" cellspacing="0" cellpadding="0">'
		cMsg += '<tr bgcolor="#FFFAFA">'
		cMsg += '<td width="5%"  align=center><font  size="2">' +aEmDip100b[nLin,1]+ '</font></td>'   // Codigo Cliente
		cMsg += '<td width="30%"> <font  size="2">' +aEmDip100b[nLin,2]+ '</font></td>'  // Nome Cliente
		cMsg += '<td width="5%"  align=center><font  size="2">' +aEmDip100b[nLin,3]+ '</font></td>'	 // Nota Fiscal 			
		cMsg += '<td width="5%"  align=center><font  size="2">' +aEmDip100b[nLin,6]+ '</font></td>'   // Parcela
		cMsg += '<td width="8%"  align=center><font  size="2">' +DTOC(STOD(aEmDip100b[nLin,4]))+ '</font></td>' // Emissao
		cMsg += '<td width="8%"  align=center><font  size="2">' +DTOC(STOD(aEmDip100b[nLin,5]))+ '</font></td>' // Vencimento
		cMsg += '<td width="5%"  align=center><font  size="2">' +CVALTOCHAR(aEmDip100b[nLin,7])+ '</font></td>'   // Valor 	
		cMsg += '<td width="4%"  align=center><font  size="2">' +aEmDip100b[nLin,8]+ '</font></td>'   // Banco
		cMsg += '<td width="10%" align=center><font  size="2">' +aEmDip100b[nLin,9]+ '</font></td>'  // Status  
		cMsg += '<td width="20%" align=center><font  size="2">' +aEmDip100b[nLin,10]+ '</font></td>' //	Vendedor(a)		
		cMsg += '</tr>'
		//cMsg += '</table>'
	EndIf	
Next 

cMsg += '</table>'

cMsg += '<TR>'	    
cMsg += '<TD colspan="10"> <Font Color=#000000 Size="2" Face="Arial">'+cMsgbody+'</Font></TD>'
cMsg += '</TR>'

//�����������������������������������������������������������������������������Ŀ
//� Definicao do rodape do email                                                �
//�������������������������������������������������������������������������������    
	
cMsg += '</Table>'
cMsg += '<P>'
cMsg += '<Table align="center">'
cMsg += '<tr>'
cMsg += '<td colspan="10" align="center"><font color="red" size="3">Mensagem enviada automaticamente pelo sistema PROTHEUS - <font color="red" size="1">(DIPR100)</td>'
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
	
 
 /* 
If GetNewPar("ES_ATIVJOB",.T.)  
 	cEmail := Lower(cEmailTo)+";"+Lower(cEmailCc)
	u_UEnvMail(AllTrim(cEmail),cAssunto,nil,"",cFrom,"ENV_100(DIPR100.prw)",cMsg)
EndIf
*/

Return(.T.)

/*
+====================================================+
|	Carregar a mensagem padr�o do corpo do e-mail    |
+====================================================+
*/

Static Function Msgbody(nDiasVenc,nDiasVenc_R,dDataVenc,cAssunto,cMsgbody,cMsgCabe)

If     nDiasVenc == -3

	/*cAssunto := "Comunicado de titulo(s) a vencer!"
	
	cMsgCabe := ''+ENTER
	cMsgCabe += '<font face="Arial" size=4><B> DIPROMED COM�RCIO E IMPORTA��O LTDA. </B></font>'+ENTER
	cMsgCabe += ''+ENTER
	cMsgCabe += '<font face="Arial" size=2><B>Prezado (a) Senhor (a),</B></font>'+ENTER
	cMsgCabe += '<font face="Arial" size=2> Para a Dipromed � muito importante t�-lo como nosso cliente, para tanto, de forma proativa, informamos que h� t�tulo(s) emitido(s) pela Dipromed � vossa empresa com vencimento no(s) pr�ximo(s) dia(s) �til(eis), conforme informa��o abaixo. </font>'+ENTER
	cMsgCabe += ''+ENTER
	
	cMsgbody := ''+ENTER
	cMsgbody += '<font face="Arial" size=2> Na eventualidade de ainda n�o ter recebido os boletos, seja por correio ou mesmo instru��o DDA, solicitamos contato imediato de V.Sa(s) atrav�s do(s) telefone(s): </font>'+ENTER 
	cMsgbody += '<font face="Arial" size=2> 11-3646-0179 com Daniele Baraldi daniele.baraldi@dipromed.com.br ou </font>'+ENTER
	cMsgbody += '<font face="Arial" size=2> 11-3646-0178 com Sidn�ia Domingos sidneia.domingos@dipromed.com.br.  </font>'+ENTER
	cMsgbody += ''+ENTER
	cMsgbody += '<font face="Arial" size=2> Esperamos com tal iniciativa contribuir com sua programa��o financeira e estabelecer canal de comunica��o mais eficaz entre vossa empresa e nosso departamento financeiro. </font>'+ENTER
	cMsgbody += ''+ENTER
	cMsgbody += '<font face="Arial" size=2> Agradecemos desde j� por vossa aten��o, colocando-nos a disposi��o para eventuais esclarecimentos necess�rios. </font>'+ENTER
	cMsgbody += ''+ENTER
	cMsgbody += '<font face="Arial" size=2> Srs. clientes, favor se atentarem a boletos de email, na qual n�o pertence a Dipromed. Est�o sendo enviados boletos com descontos dos bancos Santander e banco do Brasil. Trata-se de (FRAUDE) onde os Srs. clientes devem consultar a  </font>'+ENTER 
	cMsgbody += '<font face="Arial" size=2> Dipromed para verificar a veracidade das informa��es. </font>'+ENTER
	cMsgbody += ''+ENTER*/


	cAssunto := "[ERRATA] Comunicado de titulo(s) a vencer!"

	cMsgCabe := ''+ENTER
	cMsgCabe += '<font face="Arial" size=4><B> DIPROMED COM�RCIO E IMPORTA��O LTDA. </B></font>'+ENTER
	cMsgCabe += ''+ENTER
	cMsgCabe += '<font face="Arial" size=2><B>Prezado (a) Senhor (a),</B></font>'+ENTER
	cMsgCabe += '<font face="Arial" size=2> Favor desconsiderar e-mail de cobran�a enviados nos dias 21 e 24 de abril, foi um erro de configura��o do sistema!  Pedimos desculpas pelo transtorno e estamos � disposi��o para esclarecer qualquer d�vida. </font>'+ENTER
	cMsgCabe += ''+ENTER

ElseIf nDiasVenc == 1 .Or. nDiasVenc == 3 .Or. nDiasVenc_R == 1
	
	/*cAssunto := "Titulo(s) vencido(s)!"
	
	cMsgCabe := ''+ENTER
	cMsgCabe += '<font face="Arial" size=4><B> DIPROMED COM�RCIO E IMPORTA��O LTDA </B></font>'+ENTER
	cMsgCabe += ''+ENTER
	cMsgCabe += '<font face="Arial" size=2><B>Prezado (a) Senhor (a),</B></font>'+ENTER
	cMsgCabe += '<font face="Arial" size=2> Com o presente, tomamos a liberdade de lembrar ao prezado (a) cliente o vencimento do d�bito abaixo citado, de sua responsabilidade, e cuja liquida��o solicitamos as devidas provid�ncias. </font>'+ENTER
	cMsgCabe += ''+ENTER
	
	cMsgbody := ''+ENTER
	cMsgbody += '<font face="Arial" size=2> Lembramos que o pagamento desta(s) duplicata(s) deve ser realizado em at� 5 dias corridos do vencimento, conforme instru��es constantes no boleto banc�rio.</font>'+ENTER 
	cMsgbody += ''+ENTER
	cMsgbody += '<font face="Arial" size=2> O pagamento gerar� a imediata regulariza��o em nossos arquivos. </font>'+ENTER
	cMsgbody += ''+ENTER
	cMsgbody += '<font face="Arial" color=#0000FF size=3> Observa��o: Pedimos aten��o especial ao receber os boletos do Banco Ita�, pois o mesmo tem nos alertado que enviar� em cada folha dois boletos de cobran�a diferentes, a fim de diminuir o consumo de papel.</font>'+ENTER
	cMsgbody += ''+ENTER
	cMsgbody += '<font face="Arial" size=2> Qualquer d�vida entre em contato conosco atrav�s do(s) telefone(s): 11-3646-0160 ramal 0179 com Daniele Baraldi, ramal 0178 com Sidn�ia Domingos</font>'+ENTER
	cMsgbody += ''+ENTER
	cMsgbody += '<font face="Arial" size=2> Com os antecipados agradecimentos pela aten��o que a presente merecer, firmamo-nos.</font>'+ENTER
	cMsgbody += ''+ENTER
	cMsgbody += '<font face="Arial" color=#FF0000 size=3><B> Caso o pagamento j� tenha sido efetuado, por favor, desconsidere este aviso. </B></font>'+ENTER
	cMsgbody += ''+ENTER*/
	

	cAssunto := "[ERRATA] Titulo(s) vencido(s)!"

	cMsgCabe := ''+ENTER
	cMsgCabe += '<font face="Arial" size=4><B> DIPROMED COM�RCIO E IMPORTA��O LTDA. </B></font>'+ENTER
	cMsgCabe += ''+ENTER
	cMsgCabe += '<font face="Arial" size=2><B>Prezado (a) Senhor (a),</B></font>'+ENTER
	cMsgCabe += '<font face="Arial" size=2> Favor desconsiderar e-mail de cobran�a enviados nos dias 21 e 24 de abril, foi um erro de configura��o do sistema!  Pedimos desculpas pelo transtorno e estamos � disposi��o para esclarecer qualquer d�vida. </font>'+ENTER
	cMsgCabe += ''+ENTER
	
Else
	
	/*cAssunto := EncodeUTF8("Quite seu boleto hoje e evite cart�rio!","cp1252")
	
	cMsgCabe := ''+ENTER
	cMsgCabe += '<font face="Arial" size=4><B> DIPROMED COM�RCIO E IMPORTA��O LTDA </B></font>'+ENTER
	cMsgCabe += ''+ENTER
	cMsgCabe += '<font face="Arial" size=2><B>Prezado (a) Senhor (a),</B></font>'+ENTER
	cMsgCabe += '<font face="Arial" size=2> Reiterando as solicita��es que fizemos anteriormente, at� o presente momento n�o recebemos resposta de V.S.as a respeito do n�o pagamento da(s) duplicata(s) abaixo relacionadas. </font>'+ENTER
	cMsgCabe += ''+ENTER
	
	cMsgbody := ''+ENTER
	cMsgbody += '<font face="Arial" size=2> Informamos que hoje � o prazo limite para liquida��o dos t�tulos que venceram no dia '+dDataVenc+', a partir de amanh� o(s) t�tulo(s) em quest�o ser�(�o) enviado(s) automaticamente pelo banco para o Cart�rio de Protestos de Letras e T�tulos. </font>'+ENTER
	cMsgbody += ''+ENTER 
	cMsgbody += '<font face="Arial" size=2> Para saldarem esse d�bito efetuem o pagamento na data de hoje. </font>'+ENTER
	cMsgbody += ''+ENTER	
	cMsgbody += '<font face="Arial" size=2> Qualquer d�vida entre em contato conosco atrav�s do(s) telefone(s): 11-3646-0160 ramal 0179 com Daniele Baraldi, ramal 0178 com Sidn�ia Domingos</font>'+ENTER
	cMsgbody += ''+ENTER
	cMsgbody += '<font face="Arial" color=#FF0000 size=3><B> Caso o pagamento j� tenha sido efetuado, por favor, desconsidere este aviso. </B></font>'+ENTER
	cMsgbody += ''+ENTER*/

	
	cAssunto := EncodeUTF8("[ERRATA] Quite seu boleto hoje e evite cart�rio!","cp1252")

	cMsgCabe := ''+ENTER
	cMsgCabe += '<font face="Arial" size=4><B> DIPROMED COM�RCIO E IMPORTA��O LTDA. </B></font>'+ENTER
	cMsgCabe += ''+ENTER
	cMsgCabe += '<font face="Arial" size=2><B>Prezado (a) Senhor (a),</B></font>'+ENTER
	cMsgCabe += '<font face="Arial" size=2> Favor desconsiderar e-mail de cobran�a enviados nos dias 21 e 24 de abril, foi um erro de configura��o do sistema!  Pedimos desculpas pelo transtorno e estamos � disposi��o para esclarecer qualquer d�vida. </font>'+ENTER
	cMsgCabe += ''+ENTER
		
EndIf


Return


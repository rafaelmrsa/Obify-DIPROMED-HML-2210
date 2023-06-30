#INCLUDE "rwmake.ch"
#include "ap5mail.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ SAT01C   ³ Autor ³   VIVIANE AP.CAMPOS   ³ Data ³ 16/02/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ TELA DE AVALIACAO DA SAT                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Depto:    | TI											              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function SATAVAL()
SetPrvt("cCadastro,ARotina")

cCadastro := "Avaliação da SAT"
aRotina   := { { "Pesquisar"   ,"AxPesqui" , 0, 1},;
{ "Avaliar"     ,'ExecBlock("SATAVAL1",.F.,.F.)' , 0, 4} }
dbselectarea("SZM")
dbsetorder(1)
//DbSetFilter("SZM->ZM_STATUS='AV'")
set filter to SZM->ZM_STATUS=="AV" .and. SZM->ZM_USER==U_DipUsr()
MarkBrow("SZM",,)
set filter to
Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ SAT01C   ³ Autor ³   VIVIANE AP.CAMPOS   ³ Data ³ 16/02/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³  SAT (AVALIACAO DA SAT)                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Depto:    | TI											              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

//Chama a tela da avaliação

User function SATAVAL1()

PRIVATE cAccount  := Lower(Alltrim(GetMv("MV_RELACNT"))) // JBS 15/01/2010
PRIVATE cFrom     := Lower(Alltrim(GetMv("MV_RELACNT")))           // JBS 15/01/2010
PRIVATE cPassword := Alltrim(GetMv("MV_RELPSW"))         // JBS 15/01/2010
PRIVATE cServer   := Alltrim(GetMv("MV_RELSERV"))        // JBS 15/01/2010

//SetPrvt("dVenc")
PRIVATE cEmInfra	:= alltrim(GETMV("MV_SATINFR")) // E-MAILS INFRA
PRIVATE cEmSiga		:= alltrim(GETMV("MV_SATSIGA")) // E-MAILS INFRA

dbselectarea("SZM")
dbsetorder(1)

dbseek(xfilial("SZM")+SZM->ZM_NRSAT)

cSat    := SZM->ZM_NRSAT
cUser   := SZM->ZM_USER
cData   := SZM->ZM_DATA
cJust	 := SZM->ZM_JUSTIFI

aItems := {"OT Otimo","BO Bom","RE Regular","RU Ruim"}
Do Case
	Case SZM->ZM_AVALIAC == "OT"
		cItem := "OT Otimo"
	Case SZM->ZM_AVALIAC == "BO"
		cItem := "BO Bom"
	Case SZM->ZM_AVALIAC == "RE"
		cItem := "RE Regular"
	Case SZM->ZM_AVALIAC == "RU"
		cItem := "RU Ruim"
	Case empty(SZM-> ZM_AVALIAC)
		cItem := "OT Otimo"
Endcase

@ 00,00 to 340,530 dialog oDlg2 title "Avaliacao de Atendimento SAT"
@ 10,075 SAY " A V A L I E  O  A T E N D I M E N T O "
@ 25,015 SAY "Nr Sat "
@ 25,140 SAY "Usuario "
@ 40,015 SAY "Data Abertura "
@ 55,015 SAY "Avaliacao "
@ 72,015 SAY "Justifique "


@ 23,052 GET cSat 		WHEN .f. SIZE 37,10
@ 23,180 GET cUser 	    WHEN .f. SIZE 37,10
@ 38,052 GET cData  	WHEN .f. SIZE 37,10
@ 55,052 COMBOBOX cItem ITEMS aItems SIZE 50,50
@ 72,052 GET cJust 		SIZE 180,50

@ 155,100 BMPBUTTON TYPE 01 ACTION Grava()
@ 155,140 BMPBUTTON TYPE 02 ACTION Close(oDlg2)
ACTIVATE DIALOG oDlg2 CENTERED

dbselectarea("SZM")

Return(nil)

Static Function Grava()

dbSelectArea("SZM")
SZM->(RecLock("SZM",.F.))
SZM->ZM_AVALIAC := substr(cItem,1,2)
SZM->ZM_JUSTIFI := cJust
If  !empty(SZM->ZM_AVALIAC)
	SZM->ZM_STATUS := "CO"
End IF
MsUnLock()

//Avaliação Regular ou Ruim
IF SZM->ZM_AVALIAC =="RE" .OR. SZM->ZM_AVALIAC =="RU"
	
	Private CRLF       := Chr(13) + Chr(10)
	Private cMensagem  := ''
	Private cSat   := ALLTRIM(SZM->ZM_NRSAT)
	Private cEmiss := DtoC(SZM->ZM_DATA)
	Private cHora  := SZM->ZM_HORA
	Private cUser  := SZM->ZM_USER
	Private cDescr := alltrim(SZM->ZM_DESCR)
	Private cEmail := ''
	Private cNomeCompleto := ''
	Private cJustifi:= alltrim(SZM->ZM_JUSTIFI)
	Private cPara   := SZM->ZM_PARA
	
	If SZM->ZM_AVALIAC == 'RE'
		cAvaliac := "Regular"
	Elseif SZM->ZM_AVALIAC == 'RU'
		cAvaliac := "Ruim"
	EndIF
	
	If cPara == 'I'
		cProbl := 'Infra-Estrutura'
		cTo := cEmInfra
	Elseif cPara == 'S'
		cProbl := 'Microsiga'
		cTo := cEmSiga
		
	EndiF
	
	CONNECT SMTP SERVER cServer ACCOUNT cAccount PASSWORD cPassword	RESULT lOk
	
	cMensagem :=  txthtm1()
	
	If lOk
		SEND MAIL FROM cFrom ;
		TO      	Lower(cTo);
		CC      	Lower(SUPERGETMV("MV_#EMLTI",.F.,"ti@dipromed.com.br"));
		BCC     	Lower("");
		SUBJECT "Avaliacao Ruim ou Regular SAT Nr. " + cSat+ "de " +cUser+ " ";
		BODY    	cMensagem;
		RESULT lOK
		DISCONNECT SMTP SERVER
	Else
		Alert("Erro ao Conectar servidor de e-mails")
	Endif
    //---------------------------------------------------------------
	// Envia Mensagem via CIC para o usuario que eh responsavel 
	// pelo Atendimento Tecnico.
    //---------------------------------------------------------------
	fEnviaMsg() // JBS 19/01/2010
Endif

Close(oDlg2)

RETURN


//<------------------------------------ HTML------------------------------------------------------------------>

Static Function Txthtm1()

Private chtml := ""

chtml := "<html>"
chtml += "<head>"

chtml += "<title>SAT-Solicitacao de Atendimento</title>"
chtml += "</head>"

chtml += "<body bottommargin='0' topmargin='0' leftmargin='0' rightmargin='0' marginheight='0' marginwidth='0'>"


chtml +="<style>a.footer{	font-family 	: Verdana, Arial;	font-size 		: 10px;	color			: #000000;	font-weight		: bold;}a:hover.footer{	font-family 	: "
chtml +="	Verdana, Arial;	font-size 		: 10px;	color			: #2675af;	font-weight		: bold;}.footer{	font-family 	: Verdana, Arial;	font-size 		: 10px;"
chtml +="	color			: #000000;	font-weight		: bold;	padding-top		: 5px;	padding-left	: 5px;	padding-right	: 5px;	padding-bottom	: 5px;}div, .conteudo{	background-image: url('http://www.multiplofomento.com.br/logosat3.jpg');	font-family 	: Verdana, Arial;	font-size 		: 11px;	line-height		: 15px;	color			: #1269aa;	padding-left	: 10px;	padding-right	: 10px;	background-repeat: no-repeat;}.TabMenu{	background-color: #ffffff;	BORDER-TOP 		: #c8c8c8 1px solid;	BORDER-LEFT 	: #c8c8c8 1px solid;	BORDER-RIGHT 	: #c8c8c8 1px solid;	BORDER-BOTTOM 	: #c8c8c8 1px solid;}</style><table width='530' height='100%' cellpadding='0' cellspacing='0' class='TabMenu'><tr><td height='113'><img src='http://www.dipromed.com.br/site//images/inicio_banner.gif' width='540' height='113' alt='' border='0'></td></tr><tr><td valign='top' class='conteudo'><P><B><FONT color=crimson></FONT></B>&nbsp;</P>"

chtml +="<P align=justify><B><FONT style='TEXT-JUSTIFY: distribute-all-lines; TEXT-ALIGN: justify' color=crimson>Verifique o atendimento desta Solicitação, que obteve avaliação abaixo da média.<BR><BR><BR></FONT></B></P>"
chtml +="<P style='TEXT-ALIGN: justify; distribute-all-lines: ' align=justify>Nº "+ cSat+" </P>"
chtml +="<P style='TEXT-ALIGN: justify; distribute-all-lines: ' align=justify>Aberta em: "+cEmiss+" - "+cHora+"</P>"
chtml +="<P style='TEXT-ALIGN: justify; distribute-all-lines: ' align=justify>Para: "+cProbl+"</P>"
chtml +="<P style='TEXT-ALIGN: justify; distribute-all-lines: ' align=justify>"+cDescr+"</P>"
chtml +="<P style='TEXT-ALIGN: justify; distribute-all-lines: ' align=justify>Foi avaliada como "+cAvaliac+"</P>"
chtml +="<P style='TEXT-ALIGN: justify; distribute-all-lines: ' align=justify><B>Justificativa do Usuario:</B></P>"
chtml +="<P style='TEXT-ALIGN: justify; distribute-all-lines: ' align=justify>"+cJustifi+"</P>"
//chtml +="<tr><td align='center' height='20' bgcolor='#d9d9d8' class='footer'><a class='footer' href='http:\\www.multiplofomento.com.br'>www.multiplofomento.com.br</a></td>"

chtml +="</script>"
chtml +="<center>"
chtml +="</center>"
chtml +="</body>"
chtml +="</html>"

Return(chtml)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³fEnviaMsg()ºAutor ³Jailton B Santos-JBSº Data ³ 19/01/2010  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Envia a mensagem pelo CIC para o usuario responsavel pelo  º±±
±±º          ³ chamado.                                                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SAT - Dipromed                                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function fEnviaMsg()

Local lRetorno    := .T.
Local cFilSC9     := xFilial("SC9")
Local cServidor   := GetMV("MV_CIC")     // Servidor para enviar mensagem pelo CIC
Local cOpFatRem   := GetMV("MV_REMETCI") // Usuario do CIC remetente de mensgens no Protheus
Local cOpFatSenha := "123456"
Local cOpFatDest  := fBuscaCic()
Local cMsg        := fMsg()
                                                                        
cOpFatDest += ","  
U_DIPCIC(Padr(cMsg,380),AllTrim(cOpFatDest))// RBorges 12/03/15
//WaitRun(cServidor+' '+cOpFatRem+' '+cOpFatSenha+' "'+AllTrim(cOpFatDest)+'" "'+Padr(cMsg,380)+'" ')// Comentada RBorges 12/03/15

Return(lRetorno)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³fBuscaCic ºAutor  ³Jailton B Santos-JBSº Data ³  19/01/2010 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Busca o usuario para disparar o CIC. Busca no 'SU7', 'SY1' eº±±
±±º          ³na tabela 'Z0'do 'SX5'.                                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³SAT - Dipromed                                              º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function fBuscaCic()

Local cOperador := '' 

Begin Sequence

SU7->(DbSetOrder(4))
SU7->(DbGoTop())

If SU7->(DbSeek(xFilial("SU7") + __cUserId))
	If SU7->U7_VALIDO == "1" .And. !Empty(Alltrim(SU7->U7_CICNOME))
		cOperador := Alltrim(SU7->U7_CICNOME)
		Break
	EndIf
EndIf

SY1->(DbSetOrder(3))
SY1->(DbGoTop())

If SY1->(DbSeek(xFilial("SY1") + __cUserId ))
	If !Empty(Y1_NOMECIC)
		cOperador := Alltrim(Y1_NOMECIC)
		Break
	Endif
EndIf

SX5->( DbSetOrder(1))
SX5->( DbGotop())

If SX5->( DbSeek(xFilial('SX5')+'Z0' + __cUserId ) )
	cOperador := AllTrim(SX5->X5_DESCRI)
EndIf
	
End Sequence

Return(cOperador)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³fMsg()    ºAutor  ³Jailton B Santos-JBSº Data ³ 19/01/2010  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Monta a mensagem a ser enviada pelo CIC, informando ao usu-º±±
±±º          ³ ario que prestou o atendimento, que o mesmo precisa verifi-º±±
±±º          ³ car com o usuario o grau de satisfacao na solucao encontra-º±±
±±º          ³ da para o proplema do usuario.                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SAT - Dipromed                                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function fMsg(cTpMsg)

Local cMsg := "SAT-Solicitacao de Atendimento Tecnico " + Chr(13)+chr(10)

cMsg += "Avaliacao Ruim ou Regular. Verifique com o Usuario!" + Chr(13)+chr(10)
cMsg += "SAT Nº.......: " + cSat     + Chr(13) + chr(10)
cMsg += "Aberta em....: " + cEmiss   + " - " + cHora + Chr(13)+chr(10)
cMsg += "Para.........: " + cProbl   + Chr(13)+chr(10)
cMsg += "Descrição....: " + cDescr   + Chr(13)+chr(10)
cMsg += "Avalição.....: " + cAvaliac + Chr(13)+chr(10)
cMsg += "Justificativa: " + cJustifi + Chr(13)+chr(10)

Return(cMsg)

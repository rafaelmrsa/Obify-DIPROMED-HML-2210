#Include "RwMake.ch"
#Include "Ap5Mail.ch"
#INCLUDE "TBICONN.CH"
#INCLUDE "FILEIO.CH"

/*==========================================================================\
|Programa  | DIPR050 | Autor | Rafael de Campos Falco | Data | 28/06/2004   |
|===========================================================================|
|Descrição | Envio de Email para representantes com relatórios anexos       |
|===========================================================================|
|Sintaxe   | DIPR050                                                        |
|===========================================================================|
|Uso       | Especifico DIPROMED                                            |
|===========================================================================|
|Histórico |   /  /   -                                                     |
\==========================================================================*/

User Function DIPR050(aWork)
Local _xArea		:= GetArea()
Local titulo		:= OemTOAnsi("Envio de email para representantes com relatório anexo",72)
Local cDesc1		:= (OemToAnsi("Este programa tem como objetivo enviar e-mail aos ",72))
Local cDesc2		:= (OemToAnsi("representantes com relatórios anexos.",72))
Local cDesc3		:= (OemToAnsi("Conforme parametros definidos pelo o usuario.",72))

Private m_pag		:= 1
Private nLastKey	:= 0
Private li			:= 99
Private limite		:= 80
Private lEnd		:= .F.
Private cWorkFlow	:= ""   
Private cWCodEmp    := ""  
Private cWCodFil    := ""
Private tamanho	:= "P"
Private cString	:= "SE1"

// Private cPerg		:= "DIPR50"
// FPADR(cPerg, cArq, cCampo, cTipo)  - Para ajustar o tamanho das perguntas no SX1 - uso generico
PRIVATE cPerg  	

Private nomeprog	:= "DIPR050"
Private wnrel		:= "DIPR050"
Private aReturn	:= {"Bco A4", 1,"Administracao", 1, 2, 1,"",1}
Private nHandle	:= ""
//Tratamento para workflow
If ValType(aWork) <> 'A'
	cWorkFlow := "N" 
	cWCodEmp  := cEmpAnt
    cWCodFil  := cFilAnt
	cPerg  	:= U_FPADR( "DIPR50","SX1","SX1->X1_GRUPO"," " ) //Função criada por Sandro em 19/11/09.
    U_DIPPROC(ProcName(0),U_DipUsr()) // JBS 05/10/2005 - Gravando o nome do Programa no SZU
Else
	cWorkFlow := aWork[1]    
	cWCodEmp  := aWork[3]
    cWCodFil  := aWork[4]
EndIf

If cWorkFlow == "S"    
	PREPARE ENVIRONMENT EMPRESA cWCodEmp FILIAL cWCodFil FUNNAME "DIPR050"
EndIf

If cWorkFlow == "N"

	AjustaSX1(cPerg)           // Verifica perguntas. Se nao existe INCLUI.
	
	If !Pergunte(cPerg,.T.)    // Solicita parametros
		Return
	EndIf                      
	
	wnrel := SetPrint(cString,wnrel,cPerg,Titulo,cDesc1,cDesc2,cDesc3,.f.,,.f.,tamanho,,.f.,,,,,)

	If nLastKey == 27
		Return
	Endif
	
	SetDefault(aReturn,cString)
		
	If Processa({|lEnd| ProcRel()},"Gerando envio de emails...")
		RptStatus({|lEnd| RodaRel()},"Imprimindo")
	EndIf
	
Else

	/*==========================================================================\
	| Este relatório executado via WORKFLOW, deverá usar as datas MV_PAR01,     |
	| MV_PAR02 e MV_PAR03. O primeiro parâmetro deverá ser branco e o segundo   |
	| deverá ser preenchido com ZZZZZZ para que sempre envie o email para todos |
	| representantes da tabela SA3, e por último o parametro da data deverá     |
	| usar a data do dia para selecionar os relatórios do dia.                  |
	\==========================================================================*/

	MV_PAR01 := ''                    
	MV_PAR02 := 'ZZZZZZ'
	MV_PAR03 := Date()
	MV_PAR04 := 1
	
	ConOut("--------------------------")
	ConOut('Inicio - ' + dToc(date())+' - '+Time())
	ConOut("--------------------------")
	
	ProcRel()
	RodaRel()

	ConOut("------------------------")
	ConOut('Fim - ' + dToc(date())+' - '+Time())
	ConOut("------------------------")

Endif

If cWorkFlow == "S"    
	RESET ENVIRONMENT 
EndIf


RestArea(_xArea)

Return

/*==========================================================================\
|Programa  | ProcRel | Autor | Rafael de Campos Falco  | Data | 04/06/2004  |
|===========================================================================|
|Desc.     | Envio de e-mail                                                |
|===========================================================================|
|Sintaxe   | RodaRel                                                        |
|===========================================================================|
|Uso       | Especifico DIPROMED                                            |
\==========================================================================*/
Static Function ProcRel()
Local cArq001 	:= ""
Local cArq002 	:= ""
Local cArq003 	:= ""
Local cArq004 	:= ""
Local cArq005	:= ""
Local cArq006	:= ""
Local cArq007	:= ""
Local cArq008	:= ""
Local cEmail	:= ""
Local cAss_Rep := Space(80)
Local cMen_Rep := Space(270)
Local cAttach	:= {}
Local aMsg		:= {}
Local cAssunto	:= EncodeUTF8("Envio de relatórios de Representantes","cp1252")
Local lRetorno := .T.                                
Local _cCodVen  := GetNewPar("ES_DIPCVEN","006796/006899/006896/006932") //Talita-006796/Maura-006899/Elaine-006896/Katia-006932    

_cCodVen := StrTran(_cCodVen,"/","','")

/*
SELECT A3_COD, A3_NOME, A3_NREDUZ, A3_TIPO, A3_EMAIL
FROM SA3010
WHERE A3_TIPO = 'E'
AND A3_COD BETWEEN '' AND 'ZZZZZZ'
AND A3_EMAIL <> ''
AND A3_DESLIG = ''
AND SA3010.D_E_L_E_T_ = ''
ORDER BY A3_COD
*/

If Select("QRY1") > 0
	QRY1->(dbCloseArea())
EndIf

QRY1 := " SELECT A3_COD, A3_NOME, A3_NREDUZ, A3_TIPO, A3_EMAIL "
QRY1 += " FROM " + RetSQLName("SA3")
QRY1 += " WHERE " 		
QRY1 += " A3_FILIAL = '"+xFilial("SA3")+"' "
QRY1 += " AND A3_COD BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "' "
QRY1 += " AND (A3_TIPO = 'E' OR A3_COD IN('"+_cCodVen+"')) "
QRY1 += " AND A3_EMAIL <> '' "                                          
QRY1 += " AND A3_DESLIG = '' "                                          
QRY1 += " AND " + RetSQLName("SA3")+".D_E_L_E_T_ = ''"
QRY1 += " ORDER BY A3_COD "

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

If MV_PAR04 == 2
	@ 126,000 To 320,300 DIALOG oDlg TITLE OemToAnsi("Digite mensagem aos Representantes")
	@ 010,015 Say "Assunto:"
	@ 025,015 Get cAss_Rep Size 120,20 Picture "@S80" Valid !Empty(cAss_Rep)	
	@ 040,015 Say "Mensagem:"
	@ 055,015 Get cMen_Rep Size 120,20 Picture "@S270" Valid !Empty(cMen_Rep)	
	@ 070,050 BmpButton Type 1 Action Close(oDlg)
	Activate Dialog oDlg Centered
EndIf

DbSelectArea("QRY1")
QRY1->(dbGotop())

// EXTRAINDO DIA E MêS DATA INFORMADA
cDat_Rel := Substr(Dtoc(MV_PAR03),1,2) + Substr(Dtoc(MV_PAR03),4,2)

While QRY1->(!Eof())

	/// BLOQUEIO SOLICITADO POR ERIBERTO PARA NÃO ENVIAR E-MAIL PARA REPRESENTANTE UTILMED
	If QRY1->A3_COD = '000364'
		QRY1->(DbSkip())		
	EndIf	

	aMsg := {} // LIMPA ARRAY PARA RECEBER NOVAMENTE O NOME DO REPRESENTANTE
	cAttach := {} // LIMPA ARQUIVOS ENVIADOS

	If MV_PAR04 == 2
		Aadd(aMsg,{QRY1->A3_COD, QRY1->A3_NOME, cMen_Rep})
		cArq001 := "vendedores\zmail.txt" // arquivo vazio apenas teste...
		Aadd(cAttach,cArq001) //  ATACHA APENAS OS 5 PRIMEIROS E MENORES RELATÓRIOS
		cEmail := AllTrim(QRY1->A3_EMAIL) // EMAIL DO REPRESENTANTES
		//cEmail := "rafael@dipromed.com.br" // EMAIL DO REPRESENTANTES
		lRetorno := EMail(cEmail,cAss_Rep,aMsg,cAttach)	// CHAMADA DA FUNçãO DE ENVIO DE EMAIL
	Else	
		// CRIA O NOME DOS ARQUIVOS QUE SERÃO ENVIADOS AOS REPRESENTANTES
		If ("0401" $ cWCodEmp+cWCodFil)
			cArq001 := "\VENDEDORES\HQ\" + QRY1->A3_COD + cDat_Rel + ".028"
			cArq002 := "\VENDEDORES\HQ\" + QRY1->A3_COD + cDat_Rel + ".029"
			cArq003 := "\VENDEDORES\HQ\" + QRY1->A3_COD + cDat_Rel + ".030"
			cArq004 := "\VENDEDORES\HQ\" + QRY1->A3_COD + cDat_Rel + ".031"
			cArq005 := "\VENDEDORES\HQ\" + QRY1->A3_COD + cDat_Rel + ".032"    
			cArq008 := "\VENDEDORES\HQ\" + QRY1->A3_COD + cDat_Rel + ".063"
	    Elseif ("0404" $ cWCodEmp+cWCodFil)
			cArq001 := "\VENDEDORES\HQ-CD\" + QRY1->A3_COD + cDat_Rel + ".028"
			cArq002 := "\VENDEDORES\HQ-CD\" + QRY1->A3_COD + cDat_Rel + ".029"
			cArq003 := "\VENDEDORES\HQ-CD\" + QRY1->A3_COD + cDat_Rel + ".030"
			cArq004 := "\VENDEDORES\HQ-CD\" + QRY1->A3_COD + cDat_Rel + ".031"
			cArq005 := "\VENDEDORES\HQ-CD\" + QRY1->A3_COD + cDat_Rel + ".032"    
			cArq008 := "\VENDEDORES\HQ-CD\" + QRY1->A3_COD + cDat_Rel + ".063"  
	    Elseif ("0101" $ cWCodEmp+cWCodFil)
			cArq001 := "\VENDEDORES\DIPROMED-MTZ\" + QRY1->A3_COD + cDat_Rel + ".028"
			cArq002 := "\VENDEDORES\DIPROMED-MTZ\" + QRY1->A3_COD + cDat_Rel + ".029"
			cArq003 := "\VENDEDORES\DIPROMED-MTZ\" + QRY1->A3_COD + cDat_Rel + ".030"
			cArq004 := "\VENDEDORES\DIPROMED-MTZ\" + QRY1->A3_COD + cDat_Rel + ".031"
			cArq005 := "\VENDEDORES\DIPROMED-MTZ\" + QRY1->A3_COD + cDat_Rel + ".032"    
			cArq008 := "\VENDEDORES\DIPROMED-MTZ\" + QRY1->A3_COD + cDat_Rel + ".063"	
		Else                                                               
			cArq001 := "\VENDEDORES\DIPROMED\" + QRY1->A3_COD + cDat_Rel + ".028"
			cArq002 := "\VENDEDORES\DIPROMED\" + QRY1->A3_COD + cDat_Rel + ".029"
			cArq003 := "\VENDEDORES\DIPROMED\" + QRY1->A3_COD + cDat_Rel + ".030"
			cArq004 := "\VENDEDORES\DIPROMED\" + QRY1->A3_COD + cDat_Rel + ".031"
			cArq005 := "\VENDEDORES\DIPROMED\" + QRY1->A3_COD + cDat_Rel + ".032"    
			cArq008 := "\VENDEDORES\DIPROMED\" + QRY1->A3_COD + cDat_Rel + ".063"   
		EndIf
		Aadd(cAttach,cArq001) //  ATACHA APENAS OS 5 PRIMEIROS E MENORES RELATÓRIOS
		Aadd(cAttach,cArq002)
		Aadd(cAttach,cArq003)
		Aadd(cAttach,cArq004)
		Aadd(cAttach,cArq005)
		Aadd(cAttach,cArq008)
		cEmail := AllTrim(QRY1->A3_EMAIL) // EMAIL DO REPRESENTANTES
	//	cEmail := "rafael@dipromed.com.br" // EMAIL DO REPRESENTANTES
		
		If (File(cArq001) .Or. File(cArq002) .Or. File(cArq003) .Or. File(cArq004) .Or. File(cArq005) .Or. File(cArq008)) //Só envia e-mail se existe arquivo  - MCVN - 28/08/2008
			//cAssunto := "Relatórios de Representantes - Comissões / Baixas - "+If (("0401" $ cWCodEmp+cWCodFil),"HEALTH QUALITY","DIPROMED")
			cAssunto := "Relatórios de Representantes - Comissões / Baixas - "+If (("04" $ cWCodEmp),"HEALTH QUALITY ","DIPROMED ")+If (("01" $ cWCodFil),"-MATRIZ","-CD")
			Aadd(aMsg,{QRY1->A3_COD, QRY1->A3_NOME}) // NOME DO REPRESENTANTE
			lRetorno := EMail(cEmail,cAssunto,aMsg,cAttach)	// CHAMADA DA FUNçãO DE ENVIO DE EMAIL
		Endif
		
		cAttach := {}           
		If ("0401" $ cWCodEmp+cWCodFil)                                         
			cArq006 := "\VENDEDORES\HQ\" + QRY1->A3_COD + cDat_Rel + ".033"    
		ElseIf	("0401" $ cWCodEmp+cWCodFil)                                   
			cArq006 := "\VENDEDORES\HQ-CD\" + QRY1->A3_COD + cDat_Rel + ".033" 
		ElseIf	("0101" $ cWCodEmp+cWCodFil)                                   
			cArq006 := "\VENDEDORES\DIPROMED-MTZ\" + QRY1->A3_COD + cDat_Rel + ".033"          			         
		Else                                                            
			cArq006 := "\VENDEDORES\DIPROMED\" + QRY1->A3_COD + cDat_Rel + ".033"
		Endif

		If (File(cArq006)) //Só envia e-mail se existe arquivo  - MCVN - 28/08/2008
			//cAssunto := "Relatórios de Representantes - Cadastro de clientes - "+If (("0401" $ cWCodEmp+cWCodFil),"HEALTH QUALITY","DIPROMED")
			cAssunto := "Relatórios de Representantes - Cadastro de clientes - "+If (("04" $ cWCodEmp),"HEALTH QUALITY ","DIPROMED ")+If (("01" $ cWCodFil),"-MATRIZ","-CD")
			Aadd(cAttach,cArq006) // ATACHA APENAS O CADASTRO DE CLIENTES
			lRetorno := EMail(cEmail,cAssunto,aMsg,cAttach)   // CHAMADA DA FUNçãO DE ENVIO DE EMAIL
		Endif              
		
	/*	cAttach := {}
		cAssunto := "Relatórios de Representantes - Lista de preços" // ENVIO DA LISTA DE PREÇOS
		cArq007 := "\sigaadv\lista.xls"
		Aadd(cAttach,cArq006) // ATACHA APENAS O CADASTRO DE CLIENTES
		EMail(cEmail,cAssunto,aMsg,cAttach)   // CHAMADA DA FUNçãO DE ENVIO DE EMAIL*/
		
	EndIf
	
	QRY1->(DbSkip())

EndDo

Return(lRetorno)

/*==========================================================================\
|Programa  | RodaRel | Autor | Rafael de Campos Falco  | Data | 04/06/2004  |
|===========================================================================|
|Desc.     | Gera relatório de envio de e-mail na tela para o operador      |
|===========================================================================|
|Sintaxe   | RodaRel                                                        |
|===========================================================================|
|Uso       | Especifico DIPROMED                                            |
\==========================================================================*/
Static Function RodaRel()
Local _cTitulo := "Envio Automático de Relatórios"
Local _cDesc1  := ""
Local _cDesc2  := ""

If cWorkFlow == "N" // SE NÃO FOR WORKFLOW
	QRY1->(DbGoTop())
	While !QRY1->(Eof())
		If li > 56
			li := u_MYCabec(_cTitulo,_cDesc1,_cDesc2,nHandle,cWorkFlow)
			li+=2
		EndIf
		@ li,002 PSay "Representante: " + QRY1->A3_COD + '-' + AllTrim(QRY1->A3_NOME)
		li++
		QRY1->(DbSkip())
	EndDo
	@ li,002 PSay "E-mail enviado para os Representantes acima"
	li+=2
	@ li,002 PSay "Parâmetros informados, do representante: "
	li++
	@ li,002 PSay MV_PAR01 + " até " + MV_PAR02  
	li++
	@ li,002 PSay "referente ao dia " + DtoC(MV_PAR03)	

	/*==========================================================================\
	| Se em disco, desvia para Spool                                          |
	\==========================================================================*/
	If aReturn[5] == 1    // Se Saida para disco, ativa SPOOL
		Set Printer TO
		Commit
		ourspool(wnrel)
	Endif

EndIf

QRY1->(dbCloseArea())

Return(.T.)


/*==========================================================================\
|Programa  |EMail   | Autor | Rafael de Campos Falco  | Data | 04/06/2004   |
|===========================================================================|
|Desc.     | Envio de EMail                                                 |
|===========================================================================|
|Sintaxe   | EMail                                                          |
|===========================================================================|
|Uso       | Especifico DIPROMED                                            |
\==========================================================================*/

Static Function EMail(cEmail,cAssunto,aMsg,cAttach)

Local cAccount  := Lower(Alltrim(GetMv("MV_RELACNT")))
Local cFrom     := Lower(Alltrim(GetMv("MV_RELACNT")))
Local cPassword := Alltrim(GetMv("MV_RELPSW"))
Local cServer   := Alltrim(GetMv("MV_RELSERV"))
Local cEmailTo  := ""
Local cEmailCc  := ""
Local cEmailBcc := ""
Local cError    := ""
Local cMsg      := ""
Local lResult   := .F.
LOCAL lSmtpAuth := GetNewPar("MV_RELAUTH",.F.)
LOCAL lAutOk	:= .F.

/*==============================================================================\
| Definicao do cabecalho do email                                               |
\==============================================================================*/
cMsg := '<html>'
cMsg += '<head>'
//cMsg += '<title>' + cAssunto +"   -   "+If(("0401" $ cWCodEmp+cWCodFil),"HEALTH QUALITY","DIPROMED") + '</title>'
cMsg += '<title>' + cAssunto +"   -   "+If (("04" $ cWCodEmp),"HEALTH QUALITY ","DIPROMED ")+If (("01" $ cWCodFil),"MATRIZ","CD") + '</title>'
cMsg += '</head>'
cMsg += '<body>'    

/*
If ("01" $ cWCodEmp)                                   
	cMsg += '<td width="100%"><font color="red" font size="6">ATENÇÃO - A PARTIR DE 05/2011, OS RELATÓRIOS DE COMISSÃO, BAIXAS A RECEBER E TÍTULOS A RECEBER SÃO CONSOLIDADOS ENTRE DIPROMED MATRIZ E CD!<br></font></td>'
Endif
 */
 
cMsg += '<HR Width=85% Size=3 Align=Centered Color=Red> <P>'
cMsg += '<Table Align=Center BorderColor=#000000 CELLPADDING=4 CELLSPACING=0 Width=60%>'

/*=============================================================================*/
/*Definicao do cabecalho do relatório                                          */
/*=============================================================================*/

cMsg += '<table width="100%">'                                                                              
cMsg += '<tr align="center">'                                                                               
//cMsg += '<td width="100%"><font color="black" font size="4">'+If(("0401" $ cWCodEmp+cWCodFil),'HEALTH QUALITY','DIPROMED')+ '</font></td>'
cMsg += '<td width="100%"><font color="black" font size="4">'+If (("04" $ cWCodEmp),"HEALTH QUALITY ","DIPROMED ")+If (("01" $ cWCodFil),"MATRIZ","CD")+ '</font></td>'
cMsg += '</tr>'
cMsg += '<tr align="center">'                                                                               
cMsg += '<td width="100%"><font color="blue">Representante: ' + aMsg[1,1] + "-" + aMsg[1,2] + '</font></td>'
cMsg += '</tr>'
cMsg += '<tr align="center">'
If MV_PAR04 == 2
	cMsg += '<td width="95%">'+ aMsg[1,3] +'<br>'
	cMsg += '<font color="red">Atenciosamente Patricia<br>'
	cMsg += 'Gerente Administrativa de vendas</font></td>'
Else
	cMsg += '<td width="95%">Relatórios de representantes enviados automaticamente pelo sistema Protheus.<br>'
	cMsg += 'Qualquer dúvida ou esclarecimento entrar em contato com Patrícia - Gerente Administrativa de vendas.<br><br>'
	cMsg += 'Atenciosamente<br><br>'
	cMsg += '<font color="blue">Maximo Canuto V. Neto</font></td>'
EndIf
cMsg += '</tr>'
cMsg += '</table>'
    
/*==============================================================================\
| Definicao do rodape do email                                                  |
\==============================================================================*/
cMsg += '</Table>'
cMsg += '<HR Width=85% Size=3 Align=Centered Color=Red> <P>'
cMsg += '</body>'
cMsg += '</html>'

/*==============================================================================\
| Envia o mail para a lista selecionada. Envia como BCC para que a pessoa pense |
| que somente ela recebeu aquele email, tornando o email mais personalizado.    |
\==============================================================================*/
IF At(";",cEmail) > 0
	cEmailTo := SubStr(cEmail,1,At(";",cEmail)-1)
	cEmailCc := SubStr(cEmail,At(";",cEmail)+1,1)
Else
	cEmailTo := Alltrim(cEmail)
EndIF

If ("0401" $ cWCodEmp+cWCodFil)
//	cEmailTo :=""
//	cEmailCc :=""
//	cEmailBcc:=""
Endif

CONNECT SMTP SERVER cServer ACCOUNT cAccount PASSWORD cPassword RESULT lResult   

If !lAutOk
	If ( lSmtpAuth )
		lAutOk := MailAuth(cAccount,cPassword)
	Else
		lAutOk := .T.
	EndIf
EndIf

If lResult .And. lAutOk
	If Len(cAttach) == 6
		SEND MAIL FROM cFrom ;
		TO      	Lower(cEmailTo);
		CC      	Lower(cEmailCc);
		BCC     	Lower(cEmailBcc);
		SUBJECT 	cAssunto;
		BODY    	cMsg;
		ATTACHMENT  cAttach[1], cAttach[2], cAttach[3], cAttach[4], cAttach[5],cAttach[6];
		RESULT lResult
	Else
		SEND MAIL FROM cFrom ;
		TO      	Lower(cEmailTo);
		CC      	Lower(cEmailCc);
		BCC     	Lower(cEmailBcc);
		SUBJECT 	cAssunto;
		BODY    	cMsg;		
		ATTACHMENT  cAttach[1];
		RESULT lResult
	EndIf
	
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

Return(lResult)


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
Local i,j
_sAlias := Alias()
dbSelectArea("SX1")
dbSetOrder(1)                                                                                   

aRegs:={}

//------------ Grupo/Ordem/Pergunta/PERGING/PERGESP/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05/F3

AADD(aRegs,{cPerg,"01","Do representante    ","","","mv_ch1","C",6,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","",'SA3'})
AADD(aRegs,{cPerg,"02","Até o representante ","","","mv_ch2","C",6,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","",'SA3'})
AADD(aRegs,{cPerg,"03","Relatórios do dia   ","","","mv_ch3","D",8,0,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","",""})
AADD(aRegs,{cPerg,"04","Inf. tipo de e-mail ","","","mv_ch4","N",1,0,0,"C","","mv_par04","1-Relatórios","","","","","2-Informativo","","","","","","","",""})

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
#INCLUDE "RWMAKE.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "FILEIO.CH"

#DEFINE CR CHR(13)+CHR(10) //Carreage Return (Fim de Linha)

/*====================================================================================\
|Programa  | DIPR092()  | Autor  | Reginaldo Borges   | Data | 15/08/2017             |
|=====================================================================================|
|Descrição | Gera um relatorio dos pedidos dos clientes retira, com pre nota gerada,  |
|          | mas não faturado, caso a nota fiscal não seja gerada, após 48 horas,     |
|          | disparar um CIC e E-mail duas vezes ao dia 08:00 e as 15:00.	          |
|          |                                                                          |
|=====================================================================================|
|Uso       | Especifico Faturamento                                                   |
|=====================================================================================|
|Histórico | 																		  |
\====================================================================================*/

User Function DIPR092(aWork)

Local titulo      := OemTOAnsi("Relatorio pedidos para clientes retira não faturados.",72)
Local cDesc1      := (OemToAnsi("Este programa tem como objetivo emitir um relatorio com a",72))
Local cDesc2      := (OemToAnsi("relação de todos os pedidos para clientes retiras gerado a pre nota,",72))
Local cDesc3      := (OemToAnsi("mas não faturados..",72))
Private aReturn   := {"Bco A4", 1,"Administracao", 1, 2, 1,"",1}
Private nomeprog  := "DIPR092"
Private cPerg  	  := "DIPR092"
Private nLastKey  := 0
Private lEnd      := .F.
Private wnrel     := "DIPR092"
Private cString   := "SC5"
Private cWorkFlow := ""
Private cWCodEmp  := ""
Private cWCodFil  := ""
Private _aFeriad  := {}
Private PG := 0


cWorkFlow := aWork[1]
cWCodEmp  := aWork[2]
cWCodFil  := aWork[3]

If ValType(aWork) == 'A'
	PREPARE ENVIRONMENT EMPRESA cWCodEmp FILIAL cWCodFil FUNNAME "DIPR092" TABLES "SC5" 
EndIf

ConOut('Inicio do relatorio dos pedidos retiras com pre nota sem faturamento '+dToc(date())+' as '+Time())

RodaRel()

ConOut('Fim relatorio dos pedidos retiras com pre nota sem faturamento '+dToc(date())+' as '+Time())

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³RODAREL() ºAutor  ³Microsiga           º Data ³  15/08/17   º±±
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

Local  cSQL    := ""
Local  aMsgMail:= {}
Local  aMsgCIc := {}
Local _cPedido := ""
Local _cVend   := ""
Local _cOper   := ""
Local _cCliente:= ""
Local _dEmissao:= "00/00/0000"
Local _cHrLib  := ""
Local _dEmisPre:= ""
Local _cHrPre  := ""
Local _nHrPend := 0 
Local _cFilial := ""
Local cEmailOp := "" 
Local cCICOp   := ""
Local cAssunto := EncodeUTF8("ATENÇÃO - PEDIDOS DE VENDAS RETIRA COM ATRASO NO FATURAMENTO!","cp1252") //"MENSAGEM TESTE DA TI, POR FAVOR, DESCONSIDERAR!!!!"
Local cAssuntR := ""
Local cAssuntV := ""
Local cAssuntA := ""
Local cEmail   := GetNewPar("ES_PEDREEM","edvan.matias@dipromed.com.br;lourival.nunes@dipromed.com.br;expedicao@dipromed.com.br;reginaldo.borges@dipromed.com.br")//"edvan.matias@dipromed.com.br;lourival.nunes@dipromed.com.br;expedicao@dipromed.com.br;reginaldo.borges@dipromed.com.br")
Local cCic     := GetNewPar("ES_PEDRECI","EDVAN.MATIAS,LOURIVAL.NUNES,EXPEDICAOCD,REGINALDO.BORGES")//"")
Local cC5COND  := GetNewPar("ES_C5COND","001','002")
Local _dSab_Fer
Local _dDomingo



// Montagem do array com feriados
dbSelectArea("SX5")
dbSetOrder(1)
dbSeek(xFilial("SX5")+"63")
While X5_TABELA == "63"
	If SubStr(X5_DESCRI,1,1) != "*"
//		If Len(Alltrim(SubStr(X5_DESCRI,1,8))) <> 8
	//		cTemp := SubStr(X5_DESCRI,1,5)+"/"+AllTrim(cAno)
	//	Else
			cTemp := SubStr(X5_DESCRI,1,At(" ",X5_DESCRI)-1)
	//	EndIf
		Aadd(_aFeriad,{cTOD(AllTrim(ctemp))})
	EndIf
	SX5->(DbSkip())
EndDo


cSQL := " SELECT " 
cSQL += " C5_FILIAL, C5_NUM PEDIDO, C5_EMISSAO EMISSAO, C5_HORALIB HORALIB, " 
cSQL += " C5_PRENOTA, C5_DT_PRE DTPRENOTA, C5_HR_PRE HRPRENOTA ,C5_NOTA AS NOTA, C5_CONDPAG, " 
cSQL += " CONVERT(VARCHAR, DATEDIFF(HOUR,C5_DT_PRE, '"+dTos(date())+"')) AS HORAS, C5_TPFRETE, "
cSQL += " C5_VEND1 'CODVEND'  ,(SELECT A3_NREDUZ FROM SA3010 WHERE A3_COD = C5_VEND1) AS NOMVEND,  " 
cSQL += " C5_OPERADO 'CODOPER',(SELECT U7_NOME FROM SU7010 WHERE U7_COD = C5_OPERADO) AS NOMOPER,  " 
cSQL += " C5_CLIENTE 'CODCLI' ,(SELECT A1_NREDUZ FROM SA1010 WHERE A1_COD = C5_CLIENTE) AS NOMCLI " 
cSQL += "FROM "+ RetSQLName("SC5")
cSQL += " WHERE C5_FILIAL IN ('01','04') " 
cSQL += " AND   C5_TIPO    = 'N'  " 
cSQL += " AND   C5_TIPODIP  = 1   " 
cSQL += " AND   (C5_TPFRETE = 'D' OR C5_CONDPAG IN ('" +AllTrim(cC5COND)+ "')) " 
cSQL += " AND   C5_NOTA     = ''  " 
cSQL += " AND   C5_PRENOTA  = 'S' "    
cSQL += " AND   CONVERT(VARCHAR, DATEDIFF(HOUR,C5_DT_PRE, '"+dTos(date())+"')) >= 48 "
cSQL += " AND   D_E_L_E_T_  = ''  " 
cSQL += " ORDER BY EMISSAO, PEDIDO, HORALIB, DTPRENOTA, HRPRENOTA  " 

cSQL := ChangeQuery(cSQL)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),"DIPR92",.T.,.F.)

While  DIPR92->(!Eof())
	
	_cPedido := DIPR92->PEDIDO
	_cVend   := DIPR92->CODVEND+"-"+DIPR92->NOMVEND
	_cOper   := DIPR92->CODOPER+"-"+DIPR92->NOMOPER
	_cCliente:= DIPR92->CODCLI+"-"+DIPR92->NOMCLI
	_dEmissao:= DIPR92->EMISSAO // DTOC(STOD(DIPR92->EMISSAO))
	_cHrLib  := DIPR92->HORALIB
	_dEmisPre:= DIPR92->DTPRENOTA
	_cHrPre  := DIPR92->HRPRENOTA
	_nHrPend := DIPR92->HORAS  
	_cFilial := (Iif (DIPR92->C5_FILIAL == '01',"MTZ","CD"))
    cEmailOp := Lower(AllTrim(Posicione("SU7",1,xFilial("SU7")+DIPR92->CODOPER,"U7_EMAIL")))
    cCICOp   := Upper(AllTrim(Posicione("SU7",1,xFilial("SU7")+DIPR92->CODOPER,"U7_CICNOME")))
         
	If ! cEmailOp $ cEmail
		cEmail := cEmail+";"+cEmailOp
	EndIf 
	
	If		DIPR92->C5_CONDPAG $ cC5COND .AND. DIPR92->C5_TPFRETE <> "D"
			cAssuntV := "A VISTA "
			If ! cAssuntV $ cAssuntA
				cAssuntA :=cAssuntA+cAssuntV
			EndIf			
	ElseIf  DIPR92->C5_CONDPAG $ cC5COND .AND. DIPR92->C5_TPFRETE == "D"
			cAssuntR := "RETIRA " 
			cAssuntV := "A VISTA "				
			If ! cAssuntR $ cAssuntA
				cAssuntA :=cAssuntR+cAssuntA
			EndIf					
	ElseIf  ! DIPR92->C5_CONDPAG $ cC5COND .AND. DIPR92->C5_TPFRETE == "D"
			cAssuntR := "RETIRA "
			If ! cAssuntR $ cAssuntA
				cAssuntA :=cAssuntR+cAssuntA
			EndIf										
	EndIf
	
	cAssunto := EncodeUTF8("ATENÇÃO - PEDIDO DE VENDAS "+cAssuntR+""+cAssuntV+"COM ATRASO NO FATURAMENTO!","cp1252") 	
		
	_dSabado := Date()-2
    _dDom_Fer := Date()-1
		
   	_nPos := Ascan(_aFeriad,{|y| y[1] == _dDom_Fer}) // Verifica se data é um Feriado
	
   	If _nPos == 0 	// Se a data for um feriado despreza o dia

		If (AllTrim(cDow(Date())) <> "Saturday") // Descarta qdo. for Sábado
   			If (AllTrim(cDow(Date())) <> "Sunday")// Descarta qdo. for Domingo
		   		If (AllTrim(cDow(_dSabado)) <> "Saturday") // Descarta qdo. for Sábado
		   			If (AllTrim(cDow(_dDom_Fer)) <> "Sunday")// Descarta qdo. for Domingo
		   				aadd(aMsgMail,{_cPedido,_cVend,_cOper,_cCliente,DTOC(STOD(_dEmissao)),cAssuntR+""+cAssuntV,DTOC(STOD(_dEmisPre)),_cHrPre,_nHrPend,_cFilial})
		   				
		   				cMSGcIC := DecodeUTF8(cAssunto, "cp1252") +CR +CR
						cMSGcIC += " EMPRESA:______  " + Capital( AllTrim( GetAdvFVal( "SM0", "M0_NOME", cEmpAnt + cFilAnt, 1, "" ) ) ) +"/"+ (Iif (DIPR92->C5_FILIAL == '01',"MTZ","CD")) + CR
						cMSGcIC += " PEDIDO:________ "+_cPedido +CR
						cMSGcIC += " TP PEDIDO:_____ "+cAssuntR+""+cAssuntV+ CR
						cMSGcIC += " OPERADOR:_____  "+_cOper +CR	
						cMSGcIC += " CLIENTE:________ "+_cCliente +CR
						cMSGcIC += " DT PRE NOTA:___  "+DTOC(STOD(_dEmisPre)) +CR
						cMSGcIC += " HR PRE NOTA:___ "+_cHrPre +CR
						cMSGcIC += " HRs PENDENTE:__ "+CVALTOCHAR(_nHrPend) +" HORAS" +CR +CR	
						cMSGcIC += " OPERADORA, solicitar o ESTORNO do pedido e VOLTAR o MATERIAL para o ESTOQUE!"		
		    
						If Len(cMSGcIC) > 0 // Se não possuir nenhuma linha no array, não chama a função do CIC - RBORGES 15/08/17        
					//	    cCic := "REGINALDO.BORGES"
					//		U_DIPCIC(cMSGcIC,cCic)
							U_DIPCIC(cMSGcIC,cCic+","+cCICOp)		
						EndIf
					    cAssuntR := ""
					    cAssuntV := ""
					   				
		   			EndIf
		   		EndIf
   		    EndIf
   		Endif
   	
   	EndIf
	
	DIPR92->(dbSkip())
EndDo
	cAssunto := EncodeUTF8("ATENÇÃO - PEDIDO DE VENDAS "+cAssuntA+"COM ATRASO NO FATURAMENTO!","cp1252") 			
	If Len(aMsgMail) > 0 // Se não possuir nenhuma linha no array, não chama a função do e-mail - RBORGES 15/08/17
//		cEmail:="reginaldo.borges@dipromed.com.br"
		U__EMailPR(cEmail,cAssunto,aMsgMail) // Função para disparar o e-mail - RBORGES 15/08/17 
	EndIf

DIPR92->(dbCloseArea())
		
Return

/*------------------------------------------------------------------------+
+ Funcao:_EMailPR()    |  Autor: RBORGES     |      Data: 15/08/2014      +                                                     
+ Fará tratamento para enviar E-mail dos pedidos para clientes retiras    +
+ que tenha pre nota gerada há mais de 48 horas, mas não esteja faturado. +
-------------------------------------------------------------------------*/

User Function _EMailPR(cEmail,cAssunto,aMsgMail)

Local cAccount  := Lower(Alltrim(GetMv("MV_RELACNT")))
Local cFrom     := "protheus@dipromed.com.br"
Local cPassword := Alltrim(GetMv("MV_RELPSW"))
Local cServer   := Alltrim(GetMv("MV_RELSERV"))
Local cEmailTo  := ""
Local cEmailCc  := ""
Local cEmailBcc := ""
Local lResult   := .F.
Local cMsg      := ""
Local nI
Local lSmtpAuth := GetNewPar("MV_RELAUTH",.F.)
Local lAutOk	:= .F.
Local _cPedido  := aMsgMail[1,1]
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
cMsg += '<tr>'
cMsg += '<td width="100%" colspan="2" Align="Center" ><font size="4" color="Blue">"OPERADORA, solicitar o ESTORNO do pedido e VOLTAR o MATERIAL para o ESTOQUE!" </font></td>'
cMsg += '</tr>'
cMsg += '</table>' 
                                                                                         
cMsg += '<HR Width=100% Size=3 Align=Centered Color=Red> <P>'

cMsg += '<HR Width=100% Size=3 Align=Centered Color=Blue> <P>'
cMsg += '</tr>'
cMsg += '</font></table>'
cMsg += '<table width="100%" Border="0" cellspacing="0" cellpadding="0"><font size="2" color="DarkBlue">'
cMsg += '<tr>'
cMsg += '<td width="5% " Align="Left"><b>Filial</b></td>'
cMsg += '<td width="5% " Align="Left"><b>Pedido</b></td>'
cMsg += '<td width="10% " Align="Left"><b> TP Pedido</b></td>'
cMsg += '<td width="12% " Align="Left"><b>Vendedor(a)</b></td>'
cMsg += '<td width="20%" Align="Left"><b>Operador(a)</b></td>'
cMsg += '<td width="20% " Align="Left"><b>Cliente</b></td>'
cMsg += '<td width="7% " Align="Left"><b>Emissao</b></td>'
cMsg += '<td width="7% " Align="Left"><b>Data Pre Nota</b></td>'
cMsg += '<td width="7% " Align="Left"><b>Hora Pre Nota</b></td>'
cMsg += '<td width="7% " Align="Right"><b>Horas Pendente</b></td>'
cMsg += '</tr>'
cMsg += '</font></table>'

cMsg += '<HR Width=100% Size=3 Align=Centered Color=Blue> <P>'

/*=============================================================================*/
/*Definicao do texto/detalhe do email                                          */
/*=============================================================================*/

For nI := 1 to Len(aMsgMail)
	
	cMsg += '<table width="100%" cellspacing="0" cellpadding="0"><font size="2" color="blue">'
	cMsg += '<tr>'
	
	
	If nI = 1
		cMsg += '<table width="100%" cellspacing="0" cellpadding="0"><font size="2" color="white">'
		cMsg += '<tr>'
		cMsg += '<td width="100%">-</td>'
		cMsg += '</tr>'
		cMsg += '</font></table>'
	EndIf
	
	
	If Mod(nI,2) == 0
		
		cMsg += '<table width="100%" border="0" cellspacing="0" cellpadding="0">'
		cMsg += '<tr>'
		cMsg += '<td width="5%"  Align="Left"><font size="2" color="DarkBlue">'+aMsgMail[nI,10]+ '</font></td>'
		cMsg += '<td width="5%"  Align="Left"><font  size="2" color="DarkBlue">'+aMsgMail[nI,1]+'</font></td>'
		cMsg += '<td width="10%"  Align="Left"><font  size="2" color="DarkBlue">'+aMsgMail[nI,6]+'</font></td>'		
		cMsg += '<td width="12%" Align="Left"><font  size="2" color="DarkBlue">'+aMsgMail[nI,2]+'</font></td>'
		cMsg += '<td width="20%" Align="Left"><font  size="2" color="DarkBlue">'+aMsgMail[nI,3]+ '</font></td>'
		cMsg += '<td width="20%" Align="Left"><font  size="2" color="DarkBlue">'+aMsgMail[nI,4]+ '</font></td>'
		cMsg += '<td width="7%"  Align="Left"><font  size="2" color="DarkBlue">'+aMsgMail[nI,5]+ '</font></td>'
		cMsg += '<td width="7%"  Align="Left"><font  size="2" color="DarkBlue">'+aMsgMail[nI,7]+'</font></td>'
		cMsg += '<td width="7%"  Align="Left"><font  size="2" color="DarkBlue">'+aMsgMail[nI,8]+ '</font></td>'
		cMsg += '<td width="7%"  Align="Right"><font size="2" color="DarkBlue">'+CVALTOCHAR(aMsgMail[nI,9])+ '</font></td>'
		cMsg += '</tr>'
		cMsg += '</table>'   
		
	Else
	
		cMsg += '<table width="100%" border="0" cellspacing="0" cellpadding="0">'
		cMsg += '<tr  bgcolor="#B0E2FF">'                                                                      
		cMsg += '<td width="5%"  Align="Left"><font  size="2" color="DarkBlue">'+aMsgMail[nI,10]+ '</font></td>'		
		cMsg += '<td width="5%"  Align="Left"><font  size="2" color="DarkBlue">'+aMsgMail[nI,1]+'</font></td>'      
		cMsg += '<td width="10%"  Align="Left"><font  size="2" color="DarkBlue">'+aMsgMail[nI,6]+'</font></td>'		
		cMsg += '<td width="12%" Align="Left"><font  size="2" color="DarkBlue">'+aMsgMail[nI,2]+'</font></td>'
		cMsg += '<td width="20%" Align="Left"><font  size="2" color="DarkBlue">'+aMsgMail[nI,3]+ '</font></td>'
		cMsg += '<td width="20%" Align="Left"><font  size="2" color="DarkBlue">'+aMsgMail[nI,4]+ '</font></td>'
		cMsg += '<td width="7%"  Align="Left"><font  size="2" color="DarkBlue">'+aMsgMail[nI,5]+ '</font></td>'
		cMsg += '<td width="7%"  Align="Left"><font  size="2" color="DarkBlue">'+aMsgMail[nI,7]+'</font></td>'
		cMsg += '<td width="7%"  Align="Left"><font  size="2" color="DarkBlue">'+aMsgMail[nI,8]+ '</font></td>'
		cMsg += '<td width="7%"  Align="Right"><font size="2" color="DarkBlue">'+CVALTOCHAR(aMsgMail[nI,9])+ '</font></td>'
		cMsg += '</tr>'
		cMsg += '</table>'
	
	EndIf

Next


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Definicao do rodape do email                                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cMsg += '</Table>'
cMsg += '<HR Width=100% Size=3 Align=Centered Color=Blue> <P>'
cMsg += '<table width="100%" Align="Center" border="0">'
cMsg += '<tr align="center">'
cMsg += '<td colspan="10"><font color="BLUE" size="2">Mensagem enviada automaticamente pelo sistema PROTHEUS - <font color="BLUE" size="1">(DIPR092.PRW)</td>'
cMsg += '</tr>'
cMsg += '</table>'
cMsg += '</body>'
cMsg += '</html>'

If GetNewPar("ES_ATIVJOB",.T.)
	cEmail+=";"+AllTrim(cEmailBcc)
	u_UEnvMail(AllTrim(cEmail),cAssunto,nil,"",cFrom,"_EMailPC(DIPR092.prw)",cMsg)
EndIf


Return(.T.)

/*====================================================================================\
|Programa  | DIPR085    | Autor | Reginaldo Borges              | Data | 28/12/2015   |
|=====================================================================================|
|Descrição | Produtos com saldo - Compras                                             |
|          |                                                                          |
|          |                                                                          |
|=====================================================================================|
|Sintaxe   | DIPR085                                                                  |
|=====================================================================================|
|Uso       | Especifico DIPROMED                                                      |
|=====================================================================================|
|........................................Histórico....................................|
|Maximo    | DD/MM/AA - Descrição                                                     |
|          | 																		  |
\====================================================================================*/

#INCLUDE "RWMAKE.CH"
#INCLUDE "AP5MAIL.CH"
#INCLUDE "TBICONN.CH"

User Function DIPR085(aWork)

Local _xArea := GetArea()
Private cWorkFlow	:= ""
Private cWCodEmp    := ""
Private cWCodFil    := ""
Private cComp	    := ""
Private cMailComp	:= ""
private QRY3
Private aPedCom	    := {}


cWorkFlow := aWork[1]
cWCodEmp  := aWork[2]
cWCodFil  := aWork[3]

PREPARE ENVIRONMENT EMPRESA cWCodEmp FILIAL cWCodFil FUNNAME "DIPR085"

RunProc()	// Relatório de produtos com saldo para compras

RestArea(_xArea)                    

Return


/*=============================================\
|PROCESSAMENTO DOS DADOS E ENVIO DO E-MAIL
\=============================================*/
Static Function RunProc()

Local cEmail   := ""
Local cAssunto := ""
Local cFornec  := ""
Local cNomForn := ""
Local cProd    := ""
Local cDescr   := ""
Local cCompra  := ""
Local cCodCom  := ""
Local cEmaCom  := ""
Local nSaldo   := 0
Local nProgSCK := 0
Local nQtdCQ   := 0
Local nI       := 0
Local aEnv_085 := {}
Local aEnv_085a:= {}

//************** QUERY PARA BUSCAR PRODUTO COM SALDO PARA COMPRAS***************** RBORGES 28/12/2015

QRY2 := "SELECT B2_COD, B2_FORNEC,B2_LOJAFOR, SUM((B2_QATU-B2_RESERVA-B2_QACLASS)+(B2_SALPEDI+B2_QACLASS-B2_QPEDVEN)) AS SALDO_COM  "
QRY2 += " 	FROM  "+ RetSQLName("SB2")+", "+ RetSQLName("SB1")
QRY2 += " 		WHERE  B2_FILIAL   IN ('01','04')"
QRY2 += " 		 AND   B1_FILIAL   = B2_FILIAL   "
QRY2 += " 	   	 AND   B2_COD      BETWEEN '      ' AND 'ZZZZZZ' "
QRY2 += " 		 AND   B2_COD    = B1_COD "
QRY2 += " 		 AND   B2_LOCAL  = '01' "
QRY2 += " 		 AND   B1_TIPO   = 'PA' "             
QRY2 += " 		 AND "+RetSQLName("SB2")+".D_E_L_E_T_  = '' "
QRY2 += " 		 AND "+RetSQLName("SB1")+".D_E_L_E_T_  = '' "
QRY2 += " GROUP BY B2_COD, B2_FORNEC,B2_LOJAFOR "

QRY2 := ChangeQuery(QRY2)
dbUseArea(.T., "TOPCONN", TCGenQry(,,QRY2), 'QRY2', .T., .T.)

memowrite('DIPR85.SQL',QRY2)

//-----------------------------------------------------------

DbSelectArea("QRY2")
DbGoTop()

While QRY2->(!EOF())
	
	cProd    := QRY2->B2_COD
	nProgSCK := U_ProgSCK(cProd)                
    nQtdCQ   := u_DipSomaCQ(QRY2->B2_COD,QRY2->B2_FORNEC,QRY2->B2_LOJAFOR,.T.)        
	nSaldo   := (QRY2->SALDO_COM - nProgSCK)+nQtdCQ
	
	If nSaldo < 0
		
		cDescr   := Posicione("SB1",1,xFilial("SB1")+cProd,"B1_DESC")
		cFornec  := Posicione("SB1",1,xFilial("SB1")+cProd,"B1_PROC")
		cNomForn := Posicione("SA2",1,xFilial("SA2")+cFornec,"A2_NOME")
		cCompra  := Posicione("SA2",1,xFilial("SA2")+cFornec,"A2_COMPRA")
		cCodCom  := Posicione("SY1",1,xFilial("SY1")+cCompra,"Y1_COD")
		
		//                 1       2       3      4      5      6
		Aadd(aEnv_085a,{cFornec,cNomForn,cProd,cDescr,nSaldo,cCodCom})
		
	EndIf
	
	QRY2->(DbSkip())
	
EndDo

QRY2->(dbCloseArea())

If Len(aEnv_085a) > 0

	aEnv_085a := aSort(aEnv_085a,,,{|x,y| x[6] < y[6] })
	
	cComprador := aEnv_085a[1,6]
//	cEmaCom    := Posicione("SY1",1,xFilial("SY1")+cComprador,"Y1_EMAIL")//Rose pediu para enviar somente para compras@dipromed.com.br 27/07/16
	cEmaCom    := "compras@dipromed.com.br"
	
	For nI := 1 To Len(aEnv_085a)
		
		If aEnv_085a[nI,6] == cComprador
			
			//     Fornecedor      Nome            Produto         Descricao       Saldo           Comprador
			Aadd(aEnv_085,{aEnv_085a[nI,1],aEnv_085a[nI,2],aEnv_085a[nI,3],aEnv_085a[nI,4],aEnv_085a[nI,5],aEnv_085a[nI,6]})
			
		Else
			If Empty(cEmaCom)
				cEmaCom :="compras@dipromed.com.br"
//				cEmaCom :="reginaldo.borges@dipromed.com.br"				
			EndIf
			cEmail :=cEmaCom+";"+"reginaldo.borges@dipromed.com.br"// E-mail do Comprador - RBORGES 11/12/15
//			cEmail :="reginaldo.borges@dipromed.com.br"// E-mail do Comprador - RBORGES 11/12/15			
			cAssunto:= EncodeUTF8("ATENÇÃO! PRODUTO COM SALDO"+" - "+AllTrim(SM0->M0_NOME),"cp1252")
			aEnv_085:= aSort(aEnv_085,,,{|x,y| x[1] < y[1] })
			ENV_085(cEmail,cAssunto,aEnv_085)
			
			aEnv_085 := {}
			
			//     Fornecedor      Nome            Produto         Descricao       Saldo           Comprador
			Aadd(aEnv_085,{aEnv_085a[nI,1],aEnv_085a[nI,2],aEnv_085a[nI,3],aEnv_085a[nI,4],aEnv_085a[nI,5],aEnv_085a[nI,6]})
			
		EndIf
		
		cComprador := aEnv_085a[nI,6]
//		cEmaCom    := Posicione("SY1",1,xFilial("SY1")+cComprador,"Y1_EMAIL")
  	    cEmaCom    := "compras@dipromed.com.br" // A pedido da Rose, todos os e-mails devem ser enviados para o e-mail de compras. 27/07/16
		
	Next
	
	If Empty(cEmaCom)
		cEmaCom :="compras@dipromed.com.br"
//		cEmaCom :="reginaldo.borges@dipromed.com.br"		
	EndIf
	cEmail :=cEmaCom+";"+"reginaldo.borges@dipromed.com.br"// E-mail do Comprador - RBORGES 11/12/15
//	cEmail :="reginaldo.borges@dipromed.com.br"// E-mail do Comprador - RBORGES 11/12/15	
	cAssunto:= EncodeUTF8("ATENÇÃO! PRODUTO COM SALDO"+" - "+AllTrim(SM0->M0_NOME),"cp1252")
	aEnv_085:= aSort(aEnv_085,,,{|x,y| x[1] < y[1] })
	ENV_085(cEmail,cAssunto,aEnv_085)
	
EndIf


Return(.T.)      

/*==========================================================================\
|Programa  | ENV_085 | Autor | Reginaldo Borges   |      Data ³ 28/12/2015  |
|===========================================================================|
|Desc.     | Envio de EMail de produtos com saldo em compras                |
|===========================================================================|
|Sintaxe   | ENV_085                                                        |
|===========================================================================|
|Uso       | Especifico DIPROMED                                            |
\==========================================================================*/

Static Function ENV_085(cEmail,cAssunto,aEnv_085)

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
Local nTot_Prod := 0
Local cFornec   := aEnv_085[1,1]
Local xi
LOCAL lSmtpAuth := GetNewPar("MV_RELAUTH",.F.)
LOCAL lAutOk	:= .F.


/*=============================================================================*/
/*Definicao do cabecalho do email                                              */
/*=============================================================================*/
cMsg := ""
cMsg += '<html>'
cMsg += '<head>'
cMsg += '<title>' +cAssunto + '</title>'
cMsg += '</head>'
cMsg += '<body>'
cMsg += '<HR Width=100% Size=3 Align=Centered Color=Red><P>'
cMsg += '<Table Align=Center BorderColor=#000000 CELLPADDING=4 CELLSPACING=0 Width=100%>'

cMsg += '<table width="100%">'
cMsg += '<tr>'
cMsg += '<td width="100%" align="center"><font size="4" color="red">'+If (("04" $ cWCodEmp),"HEALTH QUALITY ","DIPROMED ")+'</font></td>'
cMsg += '</tr>'
cMsg += '</table>'

cMsg += '<hr width="100%" size="3" align="center" color="#000000">'

cMsg += '<table width="100%" cellspacing="0" cellpadding="0"><font size="3" >'
cMsg += '<tr>'
cMsg += '<td Width="7% " Align="LEFT"  ><B>Fornecedor</B></td>'
cMsg += '<td Width="38%" Align="LEFT"  ><B>Nome</B></td>'
cMsg += '<td Width="6% " Align="LEFT"  ><B>Produto</B></td>'
cMsg += '<td Width="39%" Align="LEFT"  ><B>Descricao</B></td>'
cMsg += '<td Width="10%" Align="LEFT"  ><B>Saldo</B></td>'
cMsg += '</tr>'
cMsg += '</font></table>'

cMsg += '<hr width="100%" size="2" align="center" color="#000000">'

For nI := 1 to Len(aEnv_085)
	
	nLin := nI
	
	If cFornec == aEnv_085[nI,1]
		
		If Mod(nLin,2) == 0
			
			cMsg += '<table width="100%" border="0" cellspacing="0" cellpadding="0">'
			cMsg += '<tr bgcolor="#F8F8FF">'
			If nI == 1
				cMsg += '<td width="7%  " Align="Left"><font  size="2"><B>'+aEnv_085[nLin,1]+'</B></font></td>' 
				cMsg += '<td width="38% " Align="Left"><font  size="2">'+aEnv_085[nLin,2]+'</font></td>'
			Else
				If cFornec <> aEnv_085[nI,1]
					cMsg += '<td width="7%  " Align="Left"><font  size="2"><B>'+aEnv_085[nLin,1]+'</B></font></td>'
					cMsg += '<td width="38% " Align="Left"><font  size="2">'+aEnv_085[nLin,2]+'</font></td>'
				Else
					cMsg += '<td width="45%  " Align="Left"><font  size="2" color="White">-</font></td>'
				EndIf
			EndIf
			cMsg += '<td width="6%  " Align="Left"><font  size="2">'+aEnv_085[nLin,3]+ '</font></td>'
			cMsg += '<td width="39% " Align="Left"><font  size="2" color="Blue">'+aEnv_085[nLin,4]+'</font></td>'
			cMsg += '<td width="10% " Align="Left"><font  size="2" color="Blue">'+cValToChar(aEnv_085[nLin,5])+'</font></td>'
			cMsg += '</tr>'
			cMsg += '</table>'
			
		Else
			
			cMsg += '<table width="100%" border="0" cellspacing="0" cellpadding="0">'
			cMsg += '<tr bgcolor="#FFFAFA">'
			If nI == 1
				cMsg += '<td width="7%  " Align="Left"><font  size="2"><B>'+aEnv_085[nLin,1]+'</B></font></td>' 
				cMsg += '<td width="38% " Align="Left"><font  size="2">'+aEnv_085[nLin,2]+'</font></td>'
			Else
				If cFornec <> aEnv_085[nI,1]
					cMsg += '<td width="7%  " Align="Left"><font  size="2"><B>'+aEnv_085[nLin,1]+'</B></font></td>'
					cMsg += '<td width="38% " Align="Left"><font  size="2">'+aEnv_085[nLin,2]+'</font></td>'
				Else
					cMsg += '<td width="45%  " Align="Left"><font  size="2" color="White">-</font></td>'
				EndIf
			EndIf
			cMsg += '<td width="6%  " Align="Left"><font  size="2">'+aEnv_085[nLin,3]+ '</font></td>'
			cMsg += '<td width="39% " Align="Left"><font  size="2" color="Blue">'+aEnv_085[nLin,4]+'</font></td>'
			cMsg += '<td width="10% " Align="Left"><font  size="2" color="Blue">'+cValToChar(aEnv_085[nLin,5])+'</font></td>'
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
			cMsg += '<tr bgcolor="#F8F8FF">'
			If nI == 1
				cMsg += '<td width="7%  " Align="Left"><font  size="2"><B>'+aEnv_085[nLin,1]+'</B></font></td>' 
				cMsg += '<td width="38% " Align="Left"><font  size="2">'+aEnv_085[nLin,2]+'</font></td>'
			Else
				If cFornec <> aEnv_085[nI,1]
					cMsg += '<td width="7%  " Align="Left"><font  size="2"><B>'+aEnv_085[nLin,1]+'</B></font></td>'
					cMsg += '<td width="38% " Align="Left"><font  size="2">'+aEnv_085[nLin,2]+'</font></td>'
				Else
					cMsg += '<td width="45%  " Align="Left"><font  size="2" color="White">-</font></td>'
				EndIf
			EndIf
			cMsg += '<td width="6%  " Align="Left"><font  size="2">'+aEnv_085[nLin,3]+ '</font></td>'
			cMsg += '<td width="39% " Align="Left"><font  size="2" color="Blue">'+aEnv_085[nLin,4]+'</font></td>'
			cMsg += '<td width="10% " Align="Left"><font  size="2" color="Blue">'+cValToChar(aEnv_085[nLin,5])+'</font></td>'
			cMsg += '</tr>'
			cMsg += '</table>'
			
		Else
			
			cMsg += '<table width="100%" border="0" cellspacing="0" cellpadding="0">'
			cMsg += '<tr bgcolor="#FFFAFA">'
			If nI == 1
				cMsg += '<td width="7%  " Align="Left"><font  size="2"><B>'+aEnv_085[nLin,1]+'</B></font></td>' 
				cMsg += '<td width="38% " Align="Left"><font  size="2">'+aEnv_085[nLin,2]+'</font></td>'
			Else
				If cFornec <> aEnv_085[nI,1]
					cMsg += '<td width="7%  " Align="Left"><font  size="2"><B>'+aEnv_085[nLin,1]+'</B></font></td>'
					cMsg += '<td width="38% " Align="Left"><font  size="2">'+aEnv_085[nLin,2]+'</font></td>'
				Else
					cMsg += '<td width="45%  " Align="Left"><font  size="2" color="White">-</font></td>'
				EndIf
			EndIf
			cMsg += '<td width="6%  " Align="Left"><font  size="2">'+aEnv_085[nLin,3]+ '</font></td>'
			cMsg += '<td width="39% " Align="Left"><font  size="2" color="Blue">'+aEnv_085[nLin,4]+'</font></td>'
			cMsg += '<td width="10% " Align="Left"><font  size="2" color="Blue">'+cValToChar(aEnv_085[nLin,5])+'</font></td>'
			cMsg += '</tr>'
			cMsg += '</table>'
			
		EndIf
		
	Endif
	cFornec := aEnv_085[nI,1]
	nLin  += 1
	
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
cMsg += '<td colspan="10"><font color="BLUE" size="2">Mensagem enviada automaticamente pelo sistema PROTHEUS - <font color="BLUE" size="1">(DIPR085.PRW)</td>'
cMsg += '</tr>'
cMsg += '</table>'
cMsg += '</body>'
cMsg += '</html>'
  
If GetNewPar("ES_ATIVJOB",.T.)   
	u_UEnvMail(AllTrim(cEmail),cAssunto,nil,"",cFrom,"ENV_085(DIPR085.prw)",cMsg)
EndIf

Return(.T.)


//QUERY PARA RETORNAR A PROGRAMAÇÃO POR PRODUTO              
User Function ProgSCK(_cProd)	

Local QRY3   := ""
Local nSaldo := 0

QRY3 := " SELECT SUM(B.CK_QTDVEN) AS QTDVEN "
QRY3 += " FROM " +RetSQLName ("SCJ")+" A ,"+RetSQLName("SCK")+" B ,"+RetSQLName("SA1")+" S "
QRY3 += "   WHERE   A.CJ_FILIAL  IN ('01','04') "
QRY3 += " 	  AND   B.CK_FILIAL  IN ('01','04') "
QRY3 += " 	  AND   B.CK_PRODUTO = '"+AllTrim(_cProd)+"' "
QRY3 += " 	  AND   B.CK_CLIENTE = S.A1_COD "
QRY3 += " 	  AND   B.CK_LOJA    = S.A1_LOJA " 
QRY3 += " 	  AND   B.CK_NUMPV   = ''  " 
QRY3 += " 	  AND   A.CJ_CLIENTE = B.CK_CLIENTE "
QRY3 += " 	  AND   A.CJ_LOJA    = B.CK_LOJA    "
QRY3 += " 	  AND   A.CJ_NUM     = B.CK_NUM    "
QRY3 += " 	  AND   A.CJ_OPCAO   = 'P'          "
QRY3 += " 	  AND   A.D_E_L_E_T_ = ''           "
QRY3 += " 	  AND   B.D_E_L_E_T_ = ''           "
QRY3 += " 	  AND   S.D_E_L_E_T_ = ''           "

QRY3 := ChangeQuery(QRY3)
dbUseArea(.T., "TOPCONN", TCGenQry(,,QRY3), 'QRY3', .T., .T.)

		nSaldo := QRY3->QTDVEN	

QRY3->(DbCloseArea())

Return(nSaldo)
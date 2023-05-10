/*====================================================================================\
|Programa  | DIPAL90       | Autor | Maximo Canuto Vieira Neto  | Data | 02/06/07     |
|=====================================================================================|
|Descrição | Cadastrando produto para ser usado somente em Licitação                  |
|=====================================================================================|
|Uso       | Especifico DIPROMED                                                      |
\====================================================================================*/

#INCLUDE "RWMAKE.CH"
#Include "Ap5Mail.ch"
#DEFINE CR    chr(13)+chr(10) // Carreage Return (Fim de Linha)

User Function DIPAL90()

Local cUser          := GetMV("MV_LICIPRO")  
Private cNextCod     := Val(GetMV("MV_PRODLIC"))
Private cNewCod      := ""
Private cHabilit     := "L"
Private cCodProdut   := strzero(cNextCod,6)
Private cDesc        := SPACE(60)
Private cUnidMed     := SPACE(02)
Private cMarca       := SPACE(30)
Private cFabric      := SPACE(20)
Private cCodAlfand   := SPACE(20)
Private cUnidMed     := SPACE(02)
Private cProc	     := SPACE(06)
Private cLjProc      := SPACE(02)
Private cNomeProc    := SPACE(60)
Private cTipo        := "PA"
Private cTesSaida    := "501"
Private cTesEntrada  := "001" 
Private cLocPad      := "01"

U_DIPPROC(ProcName(0),U_DipUsr()) // MCVN 22/01/2009

If !AllTrim(Upper(U_DipUsr())) $ AllTrim(Upper(cUser))
	MSGSTOP("Usuario sem autorização!")
	Return
EndIf

U_DIPPROC(ProcName(0),U_DipUsr()) 

@ 130,000 To 560,400 DIALOG oDlg TITLE OemToAnsi("CADASTRO DE PRODUTO - LICITAÇÃO.")

@ 008,010 Say "Código "                       
@ 008,080 Get cCodProdut  Size 033,30 When .f.
@ 028,010 Say "Descrição "
@ 028,080 Get cDesc       Size 110,40 Valid (!Empty(cDesc) .and. Len(cDesc) > 15)
@ 045,010 Say "Unidade de Medida"
@ 045,080 Get cUnidMed    Size 020,28 F3 "SAH" Valid ExistCpo("SAH")
@ 060,010 Say "Marca"
@ 060,080 Get cMarca      Size 110,40 Valid !Empty(cMarca)
@ 075,010 Say "Fabricante"
@ 075,080 Get cFabric     Size 110,28 Valid !Empty(cFabric)
@ 090,010 Say "Cód. Alfandegário"
@ 090,080 Get cCodAlfand  Size 110,40 Valid !Empty(cCodAlfand) 
@ 105,010 Say "Fornecedor(Garantia)"
@ 105,080 Get cProc       Size 015,28  F3 "SA2" Valid (ExistCpo("SA2") .And. AtuProc(cProc)) .Or. Vazio()

@ 120,010 Say "Loja Fornecedor"
@ 120,080 Get cLjProc     Size 015,28  When .f.   
@ 135,010 Say "Nome Fornecedor"
@ 135,080 Get cNomeProc   Size 110,28  When .f.   
@ 150,010 Say "Tipo"
@ 150,080 Get cTipo       Size 015,28  When .f.       
@ 165,010 Say "TES de Entrada"
@ 165,080 Get cTesEntrada Size 015,40  When .f.
@ 180,010 Say "TES de Saída"
@ 180,080 Get cTesSaida   Size 015,28  When .f.
@ 195,100 BMPBUTTON TYPE 1 ACTION GravaSB1()
@ 195,140 BMPBUTTON TYPE 2 ACTION Close(oDlg)
@ 003,003 to 210,198                                         
ACTIVATE DIALOG oDlg Centered
        
Return()	    

/////////////////////////////////////////////////////////////////////////
Static Function GravaSB1()
Local cAssunto := ""
Local cAssuntob:= ""
Local aEnv_Pro := {}                                           
Local cEmail   := "rose@dipromed.com.br"

// Valida campos
If !(Alltrim(cDesc) = "" .or. Alltrim(cUnidMed) = ""  .or. Alltrim(cMarca) = "" .or. Alltrim(cFabric) = "" .or. Alltrim(cCodAlfand) = "")

	If Left(cCodProdut,3) == "006"  
		// Atualizando SB1
		DbSelectArea("SB1")
		SB1->(DbSetOrder(1))
	    SB1->(DbGoTop())   
	    
	    If !(SB1->(DbSeek(xFilial("SB1")+cCodProdut)))

   			If MsgBox("Confirma a inclusão do produto " + cCodProdut + " - "+ Alltrim(cDesc)+" ?","Atencao","YESNO")   
   				
   				cCodProdut   := Upper(cCodProdut)
   				cDesc        := Upper(cDesc)
				cUnidMed     := Upper(cUnidMed)
				cMarca       := Upper(cMarca)			
				cFabric      := Upper(cFabric)
				cCodAlfand   := Upper(cCodAlfand)
				cNomeProc    := Upper(cNomeProc)


				Begin Transaction	   
				SB1->(Reclock("SB1",.T.))
				SB1->B1_COD     := cCodProdut
				SB1->B1_DESC    := cDesc
				SB1->B1_UM      := cUnidMed
				SB1->B1_MARCA   := cMarca
				SB1->B1_FABRIC  := cFabric
				SB1->B1_CODALF  := cCodAlfand
				SB1->B1_TIPO    := cTipo
				SB1->B1_HABILIT := cHabilit
				SB1->B1_TE      := cTesEntrada
				SB1->B1_TS      := cTesSaida  
				SB1->B1_LOCPAD  := cLocPad
				If !Empty(Alltrim(cProc))
					SB1->B1_PROC    := cProc
					SB1->B1_LOJPROC := cLjProc
				Endif
				SB1->(MsUnLock("SB1"))
				End Transaction	   	    
		      	
		      	// Atualiza SB2 e SB3
		      	u_MT010INC()         
		      	
    			MSGINFO("Produto " + cCodProdut + " - "+ Alltrim(cDesc) + " foi incluído com sucesso!") 
    		
				// Gravando Proximo Produto
				cNextCod := cNextCod+1
				cNewCod := strzero(cNextCod,6)
				SetMv("MV_PRODLIC",cNewCod)  

	    		// Enviando e-mail
				Aadd(aEnv_Pro,{cCodProdut, cDesc, cUnidMed, cMarca, cFabric, cHabilit, cCodAlfand, cProc, cNomeProc})

				cAssunto := EncodeUTF8('Licitação - Inclusão de Produto para Licitação: '+ Upper(U_DipUsr())+' - Código-'+ SB1->B1_COD,"cp1252")
				cAssuntob:= 'Licitação - Inclusão de Produto para Licitação: '+ Upper(U_DipUsr())+' - Código-'+ SB1->B1_COD
		     	//U_Env_Pro(cEmail,cAssunto,cAssuntob,aEnv_Pro)

		
				//Limpando Variáveia
				//cCodProdut   := SPACE(06)
				cCodProdut   := cNewCod
				cDesc        := SPACE(60)
				cUnidMed     := SPACE(02)
				cMarca       := SPACE(30)
				cFabric      := SPACE(20)
				cCodAlfand   := SPACE(20)
				cUnidMed     := SPACE(02)
				cProc        := SPACE(06)
				cLjProc      := SPACE(02)
				cNomeProc    := SPACE(60)
			
		    Else
    			MSGINFO("Inclusão do produto " + cCodProdut + " - "+ Alltrim(cDesc) + " foi cancelada!")
		    Endif
		Else                                                                                            
			MSGINFO("Produto " + cCodProdut + " - "+ Alltrim(cDesc) + " já está cadastrado!")
		EndIf    
		DbSelectArea("SB1")
    	SB1->(DbCloseArea())				
	Else
		MSGINFO("O Código do Produto está incorreto. O Código deve iniciar com 006 !")
	Endif	        
Else
	MSGINFO("Todos os campos devem ser preenchidos! Favor verificar!")
Endif


Return()         
/////////////////////////////////////////////////////////////////////////////////////////////////////

/*============================================================================\
|Programa  | Env_Pro_Lic |Autor | Maximo Canuto V. Neto  | Data | 04/06/2007  |
|=============================================================================|
|Desc.     | Envio de EMail - Cadastro de Produto de Licitação                |
|=============================================================================|
|Sintaxe   | Env_Pro_Lic                                                      |
|=============================================================================|
|Uso       | Especifico DIPROMED                                              |
\============================================================================*/

Static Function Env_Pro(cEmail,cAssunto,cAssuntob,aMsg,aAttach)

Local cEmailTo  := ""
Local cEmailCc  := ""
Local cEmailBcc := ""
            
EscreveEmail(cEmailTo,cEmailCc,cEmailBcc,cAssunto,cAssuntob,cEmail,aMsg,aAttach,.t.)
              
cEmail    := "rosemeire.ferraris@dipromed.com.br"
cEmailCc  := ""
cEmailBcc := ""
EscreveEmail(cEmailTo,cEmailCc,cEmailBcc,cAssunto,cAssuntob,cEmail,aMsg,aAttach,.f.)

Return(.T.)   


*-------------------------------------------------------------------------------------------------*   
Static Function EscreveEmail(cEmailTo,cEmailCc,cEmailBcc,cAssunto,cAssuntob,cEmail,aMsg,aAttach,lMostraCusto)
*-------------------------------------------------------------------------------------------------*   
Local cAccount  := Lower(Alltrim(GetMv("MV_RELACNT")))
Local cFrom     := Lower(Alltrim(GetMv("MV_RELACNT")))
Local cPassword := Alltrim(GetMv("MV_RELPSW"))
Local cServer   := Alltrim(GetMv("MV_RELSERV"))
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
cMsg += '<title>' + cAssunto + '</title>'
cMsg += '</head>'
cMsg += '<body>'
cMsg += '<HR Width=85% Size=3 Align=Centered Color=Red> <P>'
cMsg += '<Table Align=Center BorderColor=#000000 CELLPADDING=4 CELLSPACING=0 Width=60%>'

/*=============================================================================*/
/*Definicao do cabecalho do relatório                                          */
/*=============================================================================*/
cMsg += '<table width="100%" border="1">'
cMsg += '<tr align="center">'
cMsg += '<td width="100%" colspan="10"><font color="red" size="4">' + cAssuntob + '</font></td>'
cMsg += '</tr>'

cMsg += '<tr align="center">'
cMsg += '<td width="100%" colspan="10"><font color="red" size="2">Produto: <font color="blue" size="2">' + aMsg[1,1]+" - "+ aMsg[1,2] + '<font color="red" size="2">  -  Unid. Medida:<font color="blue" size="2">' + aMsg[1,3] + '</td>'
cMsg += '</font>'
cMsg += '</tr>'
cMsg += '<tr align="center">'
cMsg += '<td width="100%" colspan="10"><font color="red" size="2">Marca: <font color="blue" size="2">' + aMsg[1,4] + '<font color="red" size="2">  -  Fabricante:<font color="blue" size="2">' + aMsg[1,5] + '</td>'
cMsg += '</font>'
cMsg += '</tr>' 

If !Empty(Alltrim(aMsg[1,8]))
	cMsg += '<tr align="center">'
	cMsg += '<td width="100%" colspan="10"><font color="red" size="2">Fornecedor(Garantia): <font color="blue" size="2">' + aMsg[1,8]+ '<font color="red" size="2">  -  Nome Fornecedor:<font color="blue" size="2">' + aMsg[1,9] + '</td>'
	cMsg += '</font>'
	cMsg += '</tr>'
	cMsg += '</tr>'              
Endif
/*==============================================================================\
| Definicao do rodape do email                                                  |
\==============================================================================*/
cMsg += '<tr align="center">'
cMsg += '<td colspan="10"><font color="red" size="3">Mensagem enviada automaticamente pelo sistema PROTHEUS - <font color="red" size="1">(dipal90.PRW)</td>'
cMsg += '</tr>'

cMsg += '</table>'
cMsg += '<HR Width=85% Size=3 Align=Centered Color=Red> <P>'
cMsg += '</body>'
cMsg += '</html>'

/*==============================================================================\
| Envia o mail para a lista selecionada. Envia como BCC para que a pessoa pense |
| que somente ela recebeu aquele email, tornando o email mais personalizado.    |
\==============================================================================*/
cEmailTo := Alltrim(cEmail)

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
//	ATTACHMENT  aAttach;
	
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
            
/////////////////////////////////////////////////////////////
Static Function AtuProc(cProc)

cLjProc   := Posicione("SA2",1,xFilial('SA2')+cProc,"A2_LOJA") 
cNomeProc := Posicione("SA2",1,xFilial('SA2')+cProc,"A2_NOME")

Return(.T.)       


/*====================================================================================\
|Programa  | DIPAL90       | Autor | Maximo Canuto Vieira Neto  | Data | 31/07/07     |
|=====================================================================================|
|Descrição | Altera SB1 com informações do SIA FISICO                                 |
|=====================================================================================|
|Uso       | Especifico DIPROMED                                                      |
\====================================================================================*/

User Function SiaFisico() // Desabilitado   MCVN 30/07/2007
                                  
Local cUser          := GetMV("MV_LICIPRO") 
Local _xArea         := GetArea()
Private cCodSiaFis   := SPACE(10)
Private cDesc        := SPACE(60)
Private cDescSiaFis  := ""    
Private cCodprod     := SPACE(06)

/*
If !AllTrim(Upper(U_DipUsr())) $ AllTrim(Upper(cUser))
	MSGSTOP("Usuario sem autorização!")
	Return
EndIf

@ 130,000 To 400,370 DIALOG oDlg TITLE OemToAnsi("ALTERANDO CADASTRO DE PRODUTO - SIAFISICO.")

@ 008,010 Say "Produto "                       
@ 008,060 Get cCodProd    Size 033,30 F3 "SB1" Valid ExistCpo("SB1") .And. AtuProd(cCodProd) 
@ 028,010 Say "Descrição "
@ 028,060 Get cDesc       Size 110,40 When .F.  
@ 048,010 Say "Cod SiaFisico"
@ 048,060 Get cCodSiaFis  Size 45,28 Picture "99999999-9
@ 068,010 Say "Descrição do Código SIAFISICO"
@ 078,010 Get cDescSiaFis Size 160,30  MEMO	
@ 115,100 BMPBUTTON TYPE 1 ACTION AtualizaSB1()
@ 115,140 BMPBUTTON TYPE 2 ACTION Close(oDlg)
@ 003,003 to 135,190                                         
ACTIVATE DIALOG oDlg Centered

RestArea(_xArea)
Return

////////////////////////////////////////////////////////////	
Static Function AtualizaSB1()

// Valida campos
If !(Alltrim(cCodSiaFis) = "" .or. Alltrim(cDescSiaFis) = "") 

		// Atualizando SB1
		DbSelectArea("SB1")
		SB1->(DbSetOrder(1))
	    SB1->(DbGoTop())   
	    
	    If (SB1->(DbSeek(xFilial("SB1")+cCodProd)))

   			If MsgBox("Confirma a alteração no cadastro do produto " + cCodProd  +" ?","Atencao","YESNO")   
   				
				Begin Transaction	   
				SB1->(Reclock("SB1",.F.))
				SB1->B1_SIAFISI  := cCodSiaFis 
				SB1->B1_SIA      := cDescSiaFiS
			    If Empty(cDescSiaFiS)
					MSMM(SB1->B1_CODSIA,60,,cDescSiaFiS,2,,,"SB1","B1_CODSIA")
					SB1->B1_CODSIA := ''
				Else
					If Empty(SB1->B1_CODSIA)
					MSMM(SB1->B1_CODSIA,60,,cDescSiaFiS,1,,,"SB1","B1_CODSIA")
					Else
					MSMM(SB1->B1_CODSIA,60,,cDescSiaFiS,4,,,"SB1","B1_CODSIA")
					EndIf
				EndIf
				
				SB1->(MsUnLock("SB1"))  
				End Transaction	   	    
		      	
    			MSGINFO("Produto " + cCodProd + " foi alterado com sucesso!") 

                                            
				cCodProd     := SPACE(06)
				cDesc        := SPACE(60)
				cCodSiaFis   := SPACE(10)
				cDescSiaFis  := ""
			    
					
		    Else
    			MSGINFO("Alteração do produto " + cCodProd + " - "+ Alltrim(cDesc) + " foi cancelada!")
		    Endif
		Else                                                                                            
			MSGINFO("Produto " + cCodProd + " não está cadastrado!")
		EndIf    
		DbSelectArea("SB1")
    	SB1->(DbCloseArea())				
Else
	MSGINFO("Todos os campos devem ser preenchidos! Favor verificar!")
Endif

Return()                    
/////////////////////////////////////////////////////////////
Static Function AtuProd(cCodProd)

IF  !Empty(Alltrim(cCodProd))
	cDesc        := Posicione("SB1",1,xFilial('SB1')+cCodProd,"B1_DESC") 
	cCodSiaFis   := Posicione("SB1",1,xFilial('SB1')+cCodProd,"B1_SIAFISI") 
	cDescSiaFis  := MSMM(SB1->B1_CODSIA,60)   
Endif*/
Return 
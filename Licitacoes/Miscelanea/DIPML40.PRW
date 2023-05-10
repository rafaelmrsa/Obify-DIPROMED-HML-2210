#Include "Protheus.ch"
#INCLUDE "AP5MAIL.CH"   
#DEFINE CR    chr(13)+chr(10) // Carreage Return (Fim de Linha)        

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DIPML40   ºAutor  ³William Ailton Mafraº Data ³  10/13/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Envio do WorkFlow de confirmação de Editais                º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
*--------------------------------------*                                                                                   
User Function DIPML40Financeiro()
*--------------------------------------*                                                                                   
Local oHTML
Local lControl:= .T.    
Local cOrigem := "CREDITO"
Local cQuery
Local cCartas := ""
Local cDoctos := ""
Local cProdts := ""
Local nPrCusto:= 0
Local nControl:= 0
Local nCntFor := 0
Local aTipoEd :={"Pregao Presencial",;
                 "Pregao Eletronico",;
                 "Tomada de Precos",;
                 "Convite",;
                 "Registro de Precos",;
                 "Bec"}
Local cCnpj := Substr(UA1->UA1_CGC,1,2)+'.'+Substr(UA1->UA1_CGC,3,3)+'.'+Substr(UA1->UA1_CGC,6,3)+'/'+Substr(UA1->UA1_CGC,9,4)+'-'+Substr(UA1->UA1_CGC,13,2)// JBS 31/07/2006
Local cObsMem := MSMM(UA1->UA1_OBSMEM,,,,3)
Local cOrgao  := MSMM(UA1->UA1_ORGM,,,,3)
Local aContaUsuarios := U_Dip40Usuario("MV_WFFINAN") // Usuarios do Financeiro que irão avaliar o credito do cliente
Local cWfId

Private oProcess
U_DIPPROC(ProcName(0),U_DipUsr()) // MCVN 22/01/2009
Begin Sequence
    If !file("\workflow\wf001.htm")
	    Alert("Arquivo html não encontrando, Operação abotarda!")
  	    Break
    Endif
    If UA1->UA1_WFLOW == '1' 
	    If Empty(Alltrim(UA1->UA1_FINANC))
		    Alert("Cliente sendo avaliado pelo financeiro. Aguardando resposta do finceiro!")
	    Else
		    Alert("Edital já avaliado pelo financeiro."+chr(13)+chr(10)+"Aprovado por "+Alltrim(UA1->UA1_FINANC))
	    EndIF
	    lControl := .F.
    EndIF
    If UA1->UA1_WFLOW > '2' .or. (!lControl) .or. !Empty(UA1->UA1_WFID )
	    Break
    EndIF
    
    cWfId := Space(AvSx3("UA1_WFID",3))
    
    For id :=1 to len(aContaUsuarios) 
   
        PswOrder(2)
        PswSeek(AllTrim(aContaUsuarios[id]))
	    aUsuario := PswRet(1)
	    cMail := Lower(Alltrim(GetNewPar("ES_DIPML40","maximo.canuto@dipromed.com.br;reginaldo.borges@dipromed.com.br;licitacoes@healthquality.ind.br"))) // RBORGES 04/08/16
	    //cMail := "andrea.almeida@dipromed.com.br;juraci.rocha@dipromed.com.br;maximo.canuto@dipromed.com.br;ana.santos@dipromed.com.br"//AllTrim(aUsuario[1,14])
	    oProcess:=TWFProcess():New( "000001", "Avaliação de Credito" )
  	    oProcess:NewTask( "Licitação - Solicitação de Avaliação de Credito", "\WORKFLOW\WF001.htm" )
	    oProcess:cSubject := EncodeUTF8("Licitação - Solicitação de Avaliação de Credito", "cp1252")
	    oProcess:bReturn := "U_DIP040OK()"
	    oProcess:cTo := cMail
	    oProcess:aParams := {{aContaUsuarios[id],"CREDITO"}}
	    
	    oHTML:=oProcess:oHTML
	    oHTML:ValByName('CODIGO',UA1->UA1_CODIGO)
	    oHTML:ValByName('CLIENTE',Posicione("SA1",1,XFilial("SA1") + M->UA1_CODCLI+M->UA1_LOJA,"A1_NOME")) // MCVN - 15/02/2007
        oHTML:ValByName('CODCLI' ,M->UA1_CODCLI) // MCVN - 13/02/207
        oHTML:ValByName('LOJACLI',M->UA1_LOJA) // MCVN - 13/02/207
	    oHTML:ValByName('ORGAO',cOrgao)
	    oHTML:ValByName('CGC',cCnpj)//UA1->UA1_CGC)
	    oHTML:ValByName('TIPO',aTipoEd[val(UA1->UA1_TIPO)] )
	    oHTML:ValByName('CONCOR',UA1->UA1_NRCONC)
	    oHTML:ValByName('PROCES',UA1->UA1_PROCES)
	    oHTML:ValByName('ENCERRA',UA1->UA1_DENCER)
	    oHTML:ValByName('HENCER',UA1->UA1_HENCER)
	    oHTML:ValByName('ABERT' ,UA1->UA1_DABERT)
	    oHTML:ValByName('HABERT',UA1->UA1_HABERT)
	    oHTML:ValByName('DPROPO',UA1->UA1_DPROPO)
	    oHTML:ValByName('DENTRE',UA1->UA1_DENTRE)
	    oHTML:ValByName('REPRES',Posicione("SA3",1,xFilial("SA3")+M->UA1_VEND,"A3_NREDUZ"))
     	oHTML:ValByName('FORNE1',UA1->UA1_FORNE1)
 		oHTML:ValByName('TFORN1',UA1->UA1_TFORN1)
		oHTML:ValByName('FORNE2',UA1->UA1_FORNE2)
		oHTML:ValByName('TFORN2',UA1->UA1_TFORN2)
		oHTML:ValByName('FORNE3',UA1->UA1_FORNE3)
		oHTML:ValByName('TFORN3',UA1->UA1_TFORN3)
	   	oHTML:ValByName('MOTREJEIT',"")
	    If Len(cObsMem)>0
		   oHTML:ValByName('OBS',cObsMem)
	    Else
		   oHTML:ValByName('OBS','Observação: ')
	    EndIf
 	    oHTML:ValByName('APROVA','')
 		cWfid:=oProcess:fProcessID + oProcess:fTaskID
	    oProcess:Start()
	    inkey(.25) 
    Next id                                       
    //
    // Localiza o operador para usar o nome do CIC - Não funcionou fica comentado para depois continuar
    //
	//SU7->(dbSetOrder(6))
	//SU7->(dbSeek(xFilial("SU7")+U_DipUsr()))
    //
    // Registra o nova situação do cliente
    //                   
    UA1->(RecLock("UA1",.f.))
	UA1->UA1_WFID   := cWfid
	UA1->UA1_WFLOW  := '2'
	UA1->UA1_FINANC := ''
	UA1->UA1_STATUS := '1'
	UA1->UA1_RISCO  := SA1->A1_RISCO
	If Empty(UA1->UA1_USUDIG)
		UA1->UA1_USUDIG := U_DipUsr() //SU7->U7_CICNOME 
		UA1->UA1_DTRISC := dDataBase
		UA1->UA1_HRRISC := Time()
	Endif	
	UA1->(MsUnLock("UA1"))
    Dipal10CIC(cOrigem)
    Alert("Foi solicitado a avaliação do financeiro e está aguadando a resposta!")
    
End Sequence
//oProcess:Finish()	// Finaliza a task do processo anterior.
Return .T.
*----------------------------------------------------------------------------*                                                                                   
User Function DIP040OK(oProcess)                                              
*----------------------------------------------------------------------------*
Local cCod 	  := oProcess:oHtml:RetByName( 'CODIGO' ) 
Local cAvaliador := oProcess:aParams[1][1]
Local cFunEma := oProcess:aParams[1][2]
Local lAprova := .F.  
Local cAprova := "" //MCVN
Local cObsMem := oProcess:oHTML:ValByName('OBS')
Local mObsFin := oProcess:oHTML:ValByName('MOTREJEIT')
Local cCorrige:= Iif(cFunEma == "VENDAS",oProcess:oHTML:ValByName('CORRIGE'),"")//MCVN 26/06/2007
Local cCredito:= ""  
cObsMen := cObsMen+CR+mObsFin
U_DIPPROC(ProcName(0),U_DipUsr()) // MCVN 22/01/2009
Do Case
	
	Case cFunEma == "CREDITO"
		
        cCredito := AllTrim( Upper( oProcess:oHtml:RetByName( 'APROVA' ) ) )
   
   		If Left(cCredito,1) == "A"
			lAprova := .T.
		Else
			lAprova := .F.
		EndIF
		
		If UA1->( dbSeek(XFilial("UA1") + cCod ) )
			
			If Empty(UA1->UA1_FINANC)
				
				UA1->( RecLock("UA1") )
				UA1->UA1_FINANC := cAvaliador
				
				cMensagem := ""
				If(lAprova)
					UA1->UA1_WFLOW := '1'
					UA1->UA1_STATUS := '2'
					ConOut("Licitação - Edital [" +cCod+ "] Crédito Liberado por "+ cAvaliador)
					cMensagem := "Licitação - Edital [" + cCod + "] Crédito Liberado por " + cAvaliador
				    u_Dipal10Mail(cMensagem, {UA1->UA1_USUDIG},"Licitação - Completar Edital "+cCod+".") //UA1->UA1_USUCIC)
				Else
					UA1->UA1_WFLOW = '2'
					UA1->UA1_STATUS := '9'
					UA1->UA1_WFID := ""
					ConOut("Licitação - Edital [" +cCod+ "] Crédito Rejeitado por " + cAvaliador)
					u_EnviaEmail(cObsMem)
					cMensagem := "Licitação - Edital [" +cCod+ "] Crédito Rejeitado por " + cAvaliador
					ConOut("Licitação - Enviado e-mail para o Eric, Patricia e Vendedor . . .  ")
					u_Dipal10Mail(cMensagem, {UA1->UA1_USUDIG}, "Licitação - Edital "+cCod+": Credito Rejeitado.") //UA1->UA1_USUCIC)
	            EndIF 
				
				If Empty(cObsMem)
					MSMM(UA1->UA1_OBSMDI,60,,cObsMem,2,,,"UA1","UA1_OBSMDI")
					UA1->UA1_OBSMDI := ''
				Else
					If Empty(UA1->UA1_OBSMDI)
						MSMM(UA1->UA1_OBSMDI,60,,cObsMem,1,,,"UA1","UA1_OBSMDI")
					Else
						MSMM(UA1->UA1_OBSMDI,60,,cObsMem,4,,,"UA1","UA1_OBSMDI")
					EndIf
				EndIf          
				
				UA1->(MsUnlock("UA1"))
				      
				// Gravando informação de rejeição no Cadastro do Cliente  MCVN - 13/07/2007
				If !(lAprova)                                                   
							
					SA1->(dbSetOrder(1))
					SA1->(dbSeek(xFilial("SA1") + UA1->UA1_CODCLI + UA1->UA1_LOJA))
					SA1->(Reclock("SA1",.f.))
				
					mObsFin := Trim(MSMM(SA1->A1_OBSFINM,60,,,3))
		
					If !empty(mObsFin)
						mObsFin := CR + mObsFin
   					EndIf
			
					mObsFin := " Em "+dToc(dDatabase)+" o edital nro "+Alltrim(UA1->UA1_CODIGO)+" foi rejeitado. Motivo: "+AllTrim(cGetMotivo)+". " + mObsFin
		
		   			SA1->(RecLock("SA1",.F.))
			
					If empty(SA1->A1_OBSFINM)
						MSMM(,60,,mObsFin ,1,,,"SA1","A1_OBSFINM")
					Else
						MSMM(SA1->A1_OBSFINM,60,,mObsFin,4,,,"SA1","A1_OBSFINM")
					EndIf
			
					SA1->(MsUnLock("SA1"))
	        	    SA1->(DbCommit()) 
	        	    
				Endif
			EndIf
		EndIf
	Case cFunEma == "VENDAS"
		
		If(AllTrim( Upper( oProcess:oHtml:RetByName( 'APROVA' ) ) ) == "A")//MCVN 26/06/2007
		        cAprova := "A"
		ElseIf (AllTrim( Upper( oProcess:oHtml:RetByName( 'APROVA' ) ) ) == "R")//MCVN 26/06/2007
				cAprova := "R"
		Else                  
				cAprova := "C"
		EndIF
		
		UA1->( dbSeek(XFilial("UA1") + cCod ) )
		
		If Empty(UA1->UA1_VENDAS)
			
			UA1->( RecLock("UA1") )
			UA1->UA1_VENDAS := cAvaliador
			cMensagem := ""
			If cAprova = "A"  //MCVN 26/06/2007
				UA1->UA1_WFLOW  := '4'
				UA1->UA1_STATUS := '4'
				ConOut("Licitação - Edital [" +cCod+ "] foi autorizado por " + AllTrim(cAvaliador))
				cMensagem := "Licitação - Edital [" +cCod+ "] foi autorizado por " + AllTrim(cAvaliador)
				u_Dipal10Mail(cMensagem, {UA1->UA1_USUDIG},"Licitação - Edital [" +cCod+ "] foi autorizado...")//UA1->UA1_USUCIC)
				
				// Cartas do edital
				cQuery	:= "SELECT UA2_CARTA, UA6_DESCRI, UA2_VIAS "
				cQuery	+= "  FROM "+ RETSQLNAME("UA2") + " UA2 ,"+ RETSQLNAME("UA6") + " UA6"
				cQuery	+= "  WHERE UA2.D_E_L_E_T_ <> '*'"
				cQuery	+= "  AND UA2.UA2_EDITAL = '"+ UA1->UA1_CODIGO +"'"
				cQuery	+= "  AND UA2.UA2_CARTA  = UA6.UA6_CODIGO"
				//	cQuery := ChangeQuery(cQuery)
				dbUseArea(.T.,"TOPCONN", TCGENQRY(,,cQuery),"TMPCARTA", .F., .T.)
				
				TMPCARTA->(dbgotop())

				cMensagem := "Licitação - Edital [" +cCod+ "] Separar Cartas e documentos a seguir: "+chr(13)+chr(10)+chr(13)+chr(10)

				Do While TMPCARTA->(!EOF())
					cMensagem += "Carta "+TMPCARTA->UA2_CARTA
					cMensagem += "  "+TMPCARTA->UA6_DESCRI
					cMensagem += "  Vias "+StrZero(TMPCARTA->UA2_VIAS,2)
					cMensagem += Chr(13) + Chr(10)
					TMPCARTA->(dbSkip())
				EndDo
				
				// Documentos do edital
				cQuery	:= "SELECT UA3_DOCTO, UA7_DESCRI, UA3_VIAS, UA3_XEROX, UA3_ASSINA, UA3_AUTENT "
				cQuery	+= "  FROM "+ RETSQLNAME("UA3") + " UA3, " + RETSQLNAME("UA7") + " UA7 "
				cQuery	+= "  WHERE UA3.D_E_L_E_T_ <> '*'"
				cQuery	+= "  AND UA3.UA3_EDITAL = '"+ UA1->UA1_CODIGO +"'"
				cQuery	+= "  AND UA3.UA3_DOCTO  = UA7.UA7_CODIGO"
				
				dbUseArea(.T.,"TOPCONN", TCGENQRY(,,cQuery),"TMPDOC", .F., .T.)
				
				TMPDOC->(dbgotop())
				
				Do While TMPDOC->(!EOF())
					cMensagem += "Doc " + TMPDOC->UA3_DOCTO
					cMensagem += "  "   + TMPDOC->UA7_DESCRI
					cMensagem += "  Vias "+ StrZero(TMPDOC->UA3_VIAS,2) 
					cMensagem += "  Copia ["+If(TMPDOC->UA3_XEROX       =="1","Sim","Não")+"] "
					cMensagem += "  Autenticar ["+If(TMPDOC->UA3_AUTENT =="1","Sim","Não")+"] "
					cMensagem += "  Assinatura ["+If(TMPDOC->UA3_ASSINA =="1","Sim","Não")+"] "
					cMensagem += Chr(13) + Chr(10)
					
					TMPDOC->(dbSkip())
				EndDo                    
				u_Dipal10Mail(cMensagem, U_Dip40Usuario('MV_SEPARA'),"Licitação - Separar Cartas e Documentos para Edital "+cCod )
		
			ElseIf cAprova = "R"
				
				UA1->UA1_WFLOW = '4'
				UA1->UA1_STATUS := '9'
				UA1->UA1_WFID := ""
				ConOut("Licitação - Edital [" +cCod+ "] foi rejeitado por " + Alltrim(cAvaliador))
				cMensagem := "Licitação - Edital [" +cCod+ "] foi rejeitado por " + Alltrim(cAvaliador)
				u_Dipal10Mail(cMensagem, {UA1->UA1_USUDIG},"Licitação - Edital [" +cCod+ "] foi rejeitado ... ")//UA1->UA1_USUCIC)
			
			Else 
			
				UA1->UA1_WFLOW = '2'
				UA1->UA1_STATUS := '2' 
				UA1->UA1_VENDAS := ""
				UA1->UA1_WFID := ""
				ConOut("Licitação - Edital [" +cCod+ "] necessita de correção " + Alltrim(cAvaliador))
				cMensagem := "Licitação - Edital [" +cCod+ "] necessita de correção " + Alltrim(cAvaliador)
				u_Dipal10Mail(cMensagem, {UA1->UA1_USUDIG},"Licitação - Edital [" +cCod+ "] necessita de correção ... ")//UA1->UA1_USUCIC)
				
			EndIF                                                                                                     
			
			
			If Empty(cObsMem)
				MSMM(UA1->UA1_OBSMDI,60,,cObsMem,2,,,"UA1","UA1_OBSMDI")
				UA1->UA1_OBSMDI := ''
			Else
				If Empty(UA1->UA1_OBSMDI)
					MSMM(UA1->UA1_OBSMDI,60,,cObsMem,1,,,"UA1","UA1_OBSMDI")
				Else
					MSMM(UA1->UA1_OBSMDI,60,,cObsMem,4,,,"UA1","UA1_OBSMDI")
				EndIf
			EndIf
			
			If cAprova = "C" // GRAVA A CORREÇÃO DESCRITA - MCVN 26/06/2007
			    
			    cCorrige := MSMM(UA1->UA1_OBSMDI,,,,3) +" "+cCorrige
				If Empty(cCorrige)
					MSMM(UA1->UA1_OBSMDI,60,,cCorrige,2,,,"UA1","UA1_OBSMDI")
					UA1->UA1_OBSMDI := ''
				Else
					If Empty(UA1->UA1_OBSMDI)
						MSMM(UA1->UA1_OBSMDI,60,,cCorrige,1,,,"UA1","UA1_OBSMDI")
					Else
						MSMM(UA1->UA1_OBSMDI,60,,cCorrige,4,,,"UA1","UA1_OBSMDI")
					EndIf
				EndIf
			Endif
			
			UA1->(MsUnlock("UA1"))
			
		EndIf
		
	Case cFunEma == "GARANTIAS"
		
		If(AllTrim( Upper( oProcess:oHtml:RetByName( 'APROVA' ) ) ) == "A")
			lAprova := .T.
		Else
			lAprova := .F.
		EndIF
		
		UA1->( dbSeek(XFilial("UA1") + cCod ) )
		
		If Empty(UA1->UA1_FINANC)
			
			UA1->( RecLock("UA1") )
			UA1->UA1_VENDAS := cAvaliador
			
			If(lAprova)
				UA1->UA1_WFLOW  := '6'
				UA1->UA1_STATUS := '5'
				ConOut("Licitação - Edital [" +cCod+ "] for autorizado " + AllTrim(cAvaliador))
			Else
				UA1->UA1_WFLOW  := '6'
				UA1->UA1_STATUS := '9'
				UA1->UA1_WFID   := ''
				ConOut("Licitação - Edital [" +cCod+ "] foi rejeitado por " + Alltrim(cAvaliador))
			EndIF
			UA1->(MsUnlock("UA1"))
		EndIf
EndCase

oProcess:Finish()
Return .T.
*----------------------------------------------*
User Function DIPML40Vendas(cObs)
*----------------------------------------------*
Local oHTML
Local lControl:= .T.
Local cOrigem := "VENDAS"
Local cQuery
Local cCartas := ""
Local cDoctos := ""
Local cProdts := ""
Local nPrCusto:= 0 
Local nSB1PrcMin
Local nSB1PrcPro    
Local nIpi := 0
Local nControl:= 0
Local nCntFor := 0
Local aContaUsuarios := U_Dip40Usuario("MV_WFDIRVE") 
Local cCnpj   := Substr(UA1->UA1_CGC,1,2)+'.'+Substr(UA1->UA1_CGC,3,3)+'.'+Substr(UA1->UA1_CGC,6,3)+'/'+Substr(UA1->UA1_CGC,9,4)+'-'+Substr(UA1->UA1_CGC,13,2)
Local cObsMem := MSMM(UA1->UA1_OBSMEM,,,,3)
Local cOrgao  := MSMM(UA1->UA1_ORGM,,,,3)
Local aTipoEd := {"Pregao Presencial",;
"Pregao Eletronico",;
"Tomada de Precos",;
"Convite",;
"Registro de Precos",;
"Bec"}

If !cObs $ cObsMem
	cObsMem := cObsMem + AllTrim(cObs)
EndIf

Private oProcess

Begin Sequence

If !File("\workflow\wf002.htm")
	Alert("Arquivo WF002.HTM não encontrado, abortando WorkFlow!")
	Break
EndIf

If UA1->UA1_WFLOW == '3'
	If Empty(Alltrim(UA1->UA1_VENDAS))
		Alert("Edital sendo avaliado pelo Diretor comercial. "+chr(13)+chr(10)+"Aguardando resposta do Diretor Comercial!")
	Else
		Alert("Edital já avaliado pelo Diretor Comercial. "+chr(13)+chr(10)+"Aprovado por "+Alltrim(UA1->UA1_VENDAS))
	EndIF
	lControl := .F.
EndIF

If(!lControl)
	Return (.F.)
EndIF

If !Empty( UA1->UA1_VENDAS )
	Break
EndIf

cWfId := Space(AvSx3("UA1_WFID",3))

For id :=1 to len(aContaUsuarios)
	
	PswOrder(2)
    PswSeek(AllTrim(aContaUsuarios[id]))
	aUsuario := PswRet(1)
	cMail := "erich.pontoldio@dipromed.com.br;maximo.canuto@dipromed.com.br"//AllTrim(aUsuario[1,14])
	
	oProcess := TWFProcess():New( "000001", "Aprovação de edital" )
	
	oProcess:NewTask( "Licitação - Avaliação da Diretoria Comercial", "\workflow\wf002.htm" )
	oProcess:cSubject := EncodeUTF8( "Licitação - Solicitação de Avaliação", "cp1252")
	oProcess:bReturn := "U_DIP040OK()"
	oProcess:cTo := cMail
//	oProcess:aParams := {{cMail,"VENDAS"}}
	oProcess:aParams := {{aContaUsuarios[id],"VENDAS"}}
	oHTML := oProcess:oHTML
	                               
	oHTML:ValByName('CODIGO',UA1->UA1_CODIGO)
    oHTML:ValByName('CLIENTE',Posicione("SA1",1,XFilial("SA1") + M->UA1_CODCLI+M->UA1_LOJA,"A1_NOME")) // MCVN - 15/02/2007
    oHTML:ValByName('CODCLI' ,M->UA1_CODCLI) // MCVN - 13/02/207
    oHTML:ValByName('LOJACLI',M->UA1_LOJA) // MCVN - 13/02/207
	oHTML:ValByName('ORGAO',cOrgao)
	oHTML:ValByName('CGC',cCnpj)//UA1->UA1_CGC)
	oHTML:ValByName('TIPO',aTipoEd[val(UA1->UA1_TIPO)] )
	oHTML:ValByName('CONCOR',UA1->UA1_NRCONC)
	oHTML:ValByName('PROCES',UA1->UA1_PROCES)
	oHTML:ValByName('ENCERRA',UA1->UA1_DENCER)
	oHTML:ValByName('HENCER',UA1->UA1_HENCER)
	oHTML:ValByName('ABERT',UA1->UA1_DABERT)
	oHTML:ValByName('HABERT',UA1->UA1_HABERT)
	oHTML:ValByName('PAGTO',Posicione("SE4",1,xFilial("SE4")+ M->UA1_CONDPA,"E4_DESCRI") )
	oHTML:ValByName('DPROPO',UA1->UA1_DPROPO)
	oHTML:ValByName('DENTRE',UA1->UA1_DENTRE)
	oHTML:ValByName('REPRES',Posicione("SA3",1,xFilial("SA3")+M->UA1_VEND,"A3_NREDUZ"))
	oHTML:ValByName('CONTRATO',if( UA1->UA1_CODCLI == '1', 'Sim', 'Não') )
	oHTML:ValByName('VCONTR',UA1->UA1_VCONTR)
	oHTML:ValByName('PONTUAL',if( UA1->UA1_PAGORG == '1', 'Sim', 'Não'))
	oHTML:ValByName('APROVA','A')
	
	
	cQuery	:= "SELECT DISTINCT UA6.UA6_DESCRI CARTA FROM "
	cQuery	+= RetSQLName("UA1") + " UA1 " //EDITAIS"
	cQuery	+= "INNER JOIN "+ RetSQLName("UA2") + " UA2 ON  UA1.UA1_CODIGO = UA2.UA2_EDITAL "//UA2
	cQuery	+= "INNER JOIN "+ RetSQLName("UA6") + " UA6 ON  UA2.UA2_CARTA = UA6.UA6_CODIGO "//UA2
	cQuery	+= "WHERE "
	cQuery	+= "UA1.D_E_L_E_T_	<> '*'	AND	"
	cQuery	+= "UA2.D_E_L_E_T_	<> '*'	AND	"
	cQuery	+= "UA6.D_E_L_E_T_	<> '*'	AND	"
	cQuery	+= "UA1.UA1_FILIAL	= '" + xFilial("UA1") + "' AND "
	cQuery	+= "UA2.UA2_FILIAL	= '" + xFilial("UA2") + "' AND "
	cQuery	+= "UA6.UA6_FILIAL	= '" + xFilial("UA6") + "' AND "
	cQuery	+= "UA1.UA1_CODIGO = '" + UA1->UA1_CODIGO + "' "
	
	//	cQuery := ChangeQuery(cQuery)
	
	dbUseArea(.T.,"TOPCONN", TCGENQRY(,,cQuery),"CARTAS", .F., .T.)
	cCartas:=''
   
	Do While CARTAS->( !Eof() )
		If nControl > 3
			nControl := 1
			cCartas +="</tr>"
		Elseif nControl == 1
			cCartas +="<tr>"
		EndIF                                    '
		cCartas += '<td width="33%" class="aCol" >'+allTrim(CARTAS->CARTA)+'</td>'
		nControl++
		CARTAS->( dbSkip() )
	EndDo
	for nCntFor := nControl to 3
		cCartas += '<td width="33%" class="aCol" ></td>'
	next nCntFor
	oHTML:ValByName('CARTAS',cCartas)
	CARTAS->( dbCloseArea() )
	nControl := 1
	
	cQuery	:= "SELECT DISTINCT UA7.UA7_DESCRI DOCTO FROM "
	cQuery	+= RetSQLName("UA1") + " UA1 " //EDITAIS"
	cQuery	+= "INNER JOIN "+ RetSQLName("UA3") + " UA3 ON  UA1.UA1_CODIGO = UA3.UA3_EDITAL "
	cQuery	+= "INNER JOIN "+ RetSQLName("UA7") + " UA7 ON  UA3.UA3_DOCTO = UA7.UA7_CODIGO "
	cQuery	+= "WHERE "
	cQuery	+= "UA1.D_E_L_E_T_	<> '*'	AND	"
	cQuery	+= "UA3.D_E_L_E_T_	<> '*'	AND	"
	cQuery	+= "UA7.D_E_L_E_T_	<> '*'	AND	"
	cQuery	+= "UA1.UA1_FILIAL	= '" + xFilial("UA1") + "' AND "
	cQuery	+= "UA3.UA3_FILIAL	= '" + xFilial("UA3") + "' AND "
	cQuery	+= "UA7.UA7_FILIAL	= '" + xFilial("UA7") + "' AND "
	cQuery	+= "UA1.UA1_CODIGO = '" + UA1->UA1_CODIGO + "' "
	//	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN", TCGENQRY(,,cQuery),"DOCTOS", .F., .T.)
	cDoctos:=''
	Do While DOCTOS->( !Eof() )
		if nControl > 3
			nControl := 1
			cDoctos +="</tr>"
		Elseif(nControl == 1)
			cDoctos +="<tr>"
		EndIF
		cDoctos += '<td width="33%" class="aCol" >'+allTrim(DOCTOS->DOCTO)+'</td></tr>'
		nControl++
		DOCTOS->( dbSkip() )
	EndDo
	for nCntFor := nControl to 3
		cDoctos += '<td width="33%" class="aCol" ></td>'
	next nCntFor
	
	oHTML:ValByName('DOCS',cDoctos)
	DOCTOS->( dbCloseArea() )

	nControl := 1
	cQuery	:= "SELECT UA4.UA4_PRODUT CODIGO, UA4.UA4_PROMEM PRODT, UA4.UA4_PRCMIN PRMIN, UA4_PRCVEN PRVEN, UA4_FORNEC FORNEC, UA4_QUANT QUANT FROM "
	cQuery	+= RetSQLName("UA1") + " UA1 " //EDITAIS"
	cQuery	+= "INNER JOIN "+ RetSQLName("UA4") + " UA4 ON  UA1.UA1_CODIGO = UA4.UA4_EDITAL "
	cQuery	+= "WHERE "
	cQuery	+= "UA1.D_E_L_E_T_	<> '*'	AND	"
	cQuery	+= "UA4.D_E_L_E_T_	<> '*'	AND	"
	cQuery	+= "UA1.UA1_FILIAL	= '" + xFilial("UA1") + "' AND "
	cQuery	+= "UA4.UA4_FILIAL	= '" + xFilial("UA4") + "' AND "
	cQuery	+= "UA1.UA1_CODIGO = '" + UA1->UA1_CODIGO + "' "
	//	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN", TCGENQRY(,,cQuery),"PRODTS", .F., .T.)
	cProdts    := ''
	nSB1PrcMin := ''
	nSB1PrcPro := ''                                               
	
	Do While PRODTS->( !Eof() )
		cProdts += '<TR><TD colspan="3" class="Acol" >' + PRODTS->CODIGO + '</TD> '  // Codigo
	    cProdts += '<TD colspan="3" class="Acol" >' + Posicione("SB1",1,xFilial("SB1") + PRODTS->CODIGO,"B1_DESC") + '</TD> ' // Descricao
   		cProdts += '<TD colspan="3" class="Acol" align="right">' + Str(PRODTS->QUANT) + '</TD> '	 // Quantidade
     	cProdts += '<TD colspan="3" class="Acol" align="right">' + Str(PRODTS->PRVEN) + '</TD> '	 // Preco Venda
		cProdts += '<TD colspan="3" class="Acol" align="right">' + Str(PRODTS->PRMIN) + '</TD> '	 // Preco minimo do Edital

	    // Buscando valores no Cadastro de Produto
		nIpi       := Posicione("SB1",1,xFilial("SB1") + PRODTS->CODIGO,"B1_IPI")
//	    nPrCusto   := Posicione("SB1",1,xFilial("SB1") + PRODTS->CODIGO,"B1_UPRC")
//	    nPrCusto   := Posicione("SB1",1,xFilial("SB1") + PRODTS->CODIGO,"B1_CUSDIP")  // MCVN - 30/10/2008
//	    nPrCusto   := Posicione("SB1",1,xFilial("SB1") + PRODTS->CODIGO,"B1_LISFOR")  // MCVN - 26/03/2009 
	    nPrCusto   := Posicione("SB1",1,xFilial("SB1") + PRODTS->CODIGO,"B1_CUSDIP")  // MCVN - 02/04/2009
   		nPrCusto   := nPrCusto + (nPrCusto*nIpi/100)
        nSB1PrcMin := Posicione("SB1",1,xFilial("SB1") + PRODTS->CODIGO,"B1_PRVMINI") 
        nSB1PrcPro := Posicione("SB1",1,xFilial("SB1") + PRODTS->CODIGO,"B1_PRVSUPE") 

        If nSB1PrcPro > 0 .and. nSB1PrcPro < nSB1PrcMin                                           
	    	cProdts += '<TD colspan="3" class="Acol" align="right" ><font color="red" size="1">' + Str(nSB1PrcPro) + '</Font></TD> ' // Preço Promoção                       
        Else                                                                                     
           	cProdts += '<TD colspan="3" class="Acol" align="right" ><font color="red" size="1">' + Str(nSB1PrcMin) + '</Font></TD> ' // Preço C                             
        Endif

		cProdts += '<TD colspan="3" class="Acol" align="right" >'
		cProdts += '<p><span style="color:red;FONT-WEIGHT: bold" >' + Str(nPrCusto) + '<o:p></o:p></span></p></TD></TR>' // Preço de Custo

		PRODTS->( dbSkip() )
	EndDo
	oHTML:ValByName('PRODUTOS', cProdts)
	If Len(cObsMem)>0
		oHTML:ValByName('OBS',cObsMem)
	Else
		oHTML:ValByName('OBS','Observação: ')
	EndIf      
	
    
	oHTML:ValByName('CORRIGE',"Informe aqui o que deve ser corrigido no edital") //MCVN 26/06/2007

	PRODTS->( dbCloseArea() )
	oProcess:Start()
	inkey(.25)
Next id
// UA1 já esta Travado e será destravado no rtorno da função
// ALTERADO PARA PASSAR DIRETAMENTE PELA APROVAÇÃO COMERCIAL, conforme solicitado pela Patrícia por Cic (18/02/2015)
// UA1->UA1_WFID   := cWfid
// UA1->UA1_WFLOW  := '3'
// UA1->UA1_STATUS := '3'
// UA1->UA1_VENDAS := ''
//Dipal10CIC(cOrigem)
//Alert("Foi solicitado a avaliação do Edital pela Diretoria Comercial")


UA1->UA1_WFID   := cWfid
UA1->UA1_WFLOW  := '4'
UA1->UA1_STATUS := '4'
UA1->UA1_VENDAS :=  'Pre-Aprovado Pelo Comercial'

Dipal10CIC(cOrigem)
Alert("Edital avaliado e aprovado automaticamente pela Diretoria Comercial")

End Sequence
Return(.t.)
*--------------------------------------------------*
User Function Dip40Usuario(cWfUsuarios)
// Retorna em array os usuarios do Mv para o email
*--------------------------------------------------*
Local cString := getMV(cWfUsuarios)
Local aWfUsuario := {}

Do While .t.
	
	If At(",",cString) = 0 .and. len(cString) > 0
		aAdd(aWfUsuario,AllTrim(cString))
		Exit
	EndIf
	
	If At(",",cString) > 0
		aAdd(aWfUsuario,left(cString,At(",",cString)-1))
		cString := SubStr(cString,At(",",cString)+1,len(cString)-At(",",cString))
	EndIf
	
EndDo

Return(aWfUsuario)

*------------------------------*
User Function EnviaEmail(cObsMem)
*------------------------------*
Local cAccount:=Lower(Alltrim(GetMv('MV_RELACNT')))
Local cFrom:= Lower(Alltrim(GetMv('MV_RELACNT')))
Local cPassword:=alltrim(GetMv('MV_RELPSW'))
Local cServer:=alltrim(GetMv('MV_RELSERV'))
Local lResult:=.F.
Local cError:=''
Local cMsg:=''
Local cAssunto:=''   
Local cTo  := ''
Local cBCC := ''
Local aContaUsuarios := U_Dip40Usuario('MV_LICITRE') 
Local cPontoVirgual:=''   
LOCAL lSmtpAuth := GetNewPar("MV_RELAUTH",.F.)
LOCAL lAutOk	:= .F.

SA1->(dbSeek(xFilial("SA1")+UA1->UA1_CODCLI))
SA3->(dbSeek(xFilial("SA3")+SA1->A1_VEND))

cTo := AllTrim(SA3->A3_EMAIL)

PswOrder(2)
For id:=1 to len(aContaUsuarios)
    PswSeek(AllTrim(aContaUsuarios[id]))
	aUsuario := PswRet(1)
    cBCC += cPontoVirgual + AllTrim(aUsuario[1,14])
    cPontoVirgual := '; '
Next

cAssunto:= EncodeUTF8('Licitação - Reprovado o Edital ' + UA1->UA1_CODIGO+'. Do Cliente ' + UA1->UA1_CODCLI+'-'+SA1->A1_NREDUZ,"cp1252")
ConOut('****************************************************************************')
ConOut('**                 Controle de Licitacoes V 1.0 (P) 2006                  **')
ConOut('****************************************************************************')
ConOut('**                                                                        **')
conout('**  Comunicando aos interessados, que o edital ' + UA1->UA1_CODIGO+'                     **') 
ConOut('**  Do Cliente ' + UA1->UA1_CODCLI+'-'+SA1->A1_NREDUZ +'                                **')
ConOut('**  Foi reprovado pelo departamento financeiro . . .                      **')
ConOut('**                                                                        **')
ConOut('****************************************************************************')
ConOut('** Representante/Vendedor: '+cTo)
PswOrder(2)
For id:=1 to len(aContaUsuarios)
    PswSeek(AllTrim(aContaUsuarios[id]))
	aUsuario := PswRet(1)
    cBCC += cPontoVirgual + AllTrim(aUsuario[1,14])
    ConOut('** Usuario '+ AllTrim(aContaUsuarios[id]) + '  E-Mail: ' + AllTrim(aUsuario[1,14]))
    cPontoVirgual := '; '
Next
ConOut('****************************************************************************')
conout(cAssunto)
//--------------------------------------------------------------------------
// Definicao do cabecalho do email
//--------------------------------------------------------------------------
cMsg := '<html>'
cMsg += '<head>'
cMsg += '<title>'+cAssunto+'</title>'
cMsg += '</head>'
cMsg += '<body>'
cMsg += '<HR Width=100% Size=4 Align=Centered Color=Red>'
cMsg += '<Table Align=Center BorderColor=#000000 CELLPADDING=4 CELLSPACING=0 Width=100%>'
//-------------------------------------------------------------------------
// Definicao do cabecalho do relatório
//-------------------------------------------------------------------------
cMsg += '<table width="100%">'
cMsg += '  <tr>'
cMsg += '     <td width="100%"><font size="5" color="red">'+DecodeUTF8(cAssunto, "cp1252")+'</font></td>'
cMsg += '  </tr>'
cMsg += '</table> <P>'
cMsg += '<table width="100%" cellspacing="0" cellpadding="0"><font size="1" color="blue">'
//-------------------------------------------------------------------------
// Definicao do texto/detalhe do email
//-------------------------------------------------------------------------
cMsg += '<table width="100%" border="3" cellspacing="0" cellpadding="0">'
cMsg += '   <tr>'
cMsg += '      <td width="100%" align="left"><font size="3">Codigo do Edital................: ' + UA1->UA1_CODIGO + '</font></td>'
cMsg += '   </tr>'
cMsg += '   <tr>'
cMsg += '      <td width="100%" align="left"><font size="3">Cliente.........................: ' + UA1->UA1_CODCLI + '-' + SA1->A1_NREDUZ +'</font></td>'
cMsg += '   </tr>'
cMsg += '   <tr>'
cMsg += '      <td width="100%" align="left"><font size="3">Vendedor........................: ' + SA1->A1_VEND + '-' + SA3->A3_NREDUZ +'</font></td>'
cMsg += '   </tr>'
cMsg += '   <tr>'
cMsg += '      <td width="100%" align="left"><font size="3">Reprovado pelo usuario do Financ: ' + UA1->UA1_FINANC + '</font></td>'
cMsg += '   </tr>'
cMsg += '   <tr>'
cMsg += '      <td width="100%" align="left"><font size="3">Data e Hora de abertura.........: ' + dtoc(UA1->UA1_DABERT)+ ' às ' + UA1->UA1_HABERT + '</font></td>'
cMsg += '   </tr> <p>'
cMsg += '</table>'
cMsg += '<table width="100%" border="3" cellspacing="0" cellpadding="0">'
cMsg += '   <tr>'
cMsg += '      <td width="100%"><font size="3">Comentario do Financeiro:</font></td>'
cMsg += '   </tr> <p>'
cMsg += '   <tr>'
cMsg += '      <td width="100%" align="left"><font size="3">' + cObsMem + '</font></td>'
cMsg += '   </tr>'
cMsg += '</table>'
//-----------------------------------------------------------------------
// Definicao do rodape do email
//-----------------------------------------------------------------------
cMsg += '<HR Width=100% Size=4 Align=Centered Color=Red> <P>'
cMsg += '    <table width="100%" Align="Center" border="0">'
cMsg += '       <tr align="center">'
cMsg += '           <td colspan="10"><font color="BLUE" size="2">Mensagem enviada automaticamente pelo sistema PROTHEUS - <font color="BLUE" size="1">(DIPML40.PRW)</td>'
cMsg += '       </tr>'
cMsg += '    </table>'
cMsg += '</body>'
cMsg += '</html>'
//-------------------------------------------------------------------------------
// Envia o mail para a lista selecionada. Envia como BCC para que a pessoa pense
// que somente ela recebeu aquele email, tornando o email mais personalizado.
//-------------------------------------------------------------------------------
CONNECT SMTP SERVER cServer ACCOUNT cAccount PASSWORD cPassword RESULT lResult
//CC  '' //                      ;
//BCC 'relatorios@dipromed.com.br';
If !lAutOk
	If ( lSmtpAuth )
		lAutOk := MailAuth(cAccount,cPassword)
	Else
		lAutOk := .T.
	EndIf
EndIf

If lResult .And. lAutOk
	SEND MAIL FROM cFrom ;
	TO  cTo;
	BCC cBCC;
	SUBJECT 	cAssunto;
	BODY    	cMsg;
	RESULT lResult
	If !lResult
		//Erro no envio do email
		GET MAIL ERROR cError
		MsgInfo(cError,OemToAnsi('Atenção'))
	EndIf
	DISCONNECT SMTP SERVER
Else
	//Erro na conexao com o SMTP Server
	GET MAIL ERROR cError
	MsgInfo(cError,OemToAnsi('Atenção'))
EndIf
Return(.T.)

*--------------------------------------------------------------------------*
Static Function Dipal10CIC(cOrigem)
// MCVN 06/07/2007 - AVALIAÇÃO DE EDITAL
*--------------------------------------------------------------------------*
Local lRetorno := .T.
Local cMail
Local cServidor   := GetMV("MV_CIC")     // Servidor para enviar mensagem pelo CIC
Local cOpFatRem   := GetMV("MV_REMETCI") // Usuario do CIC remetente de mensgens no Protheus
Local cOpFatSenha := "123456"
Local cOpFatDest  := ""
Local cGetMotivo  := Space(90)
Local nOpcao      := 0
Local lSaida      := .f.

Default cOrigem   := ""

	If cOrigem == "CREDITO"	
		// Monta a mensagem a ser enviado ao operador
		cOpFatDest  := GetMV("MV_LICFCIC")    
		cMail := "LICITAÇÃO - EDITAL AGUARDANDO LIBERAÇÃO DE CRÉDITO"+CR+CR
		cMail += "O edital " +UA1->UA1_CODIGO
		cMail += " do Cliente "+AllTrim(UA1->UA1_CODCLI)+" - "+AllTrim(M->UA1_NOME)+CR
		cMail += "aguarda liberação de crédito !"+CR+CR 
		cMail += CR+U_DipUsr()
		
		// Envia a mensagem ao operador através do CIC	
		U_DIPCIC(cMail,AllTrim(cOpFatDest))// RBorges 12/03/15
//		WaitRun(cServidor+' '+cOpFatRem+' '+cOpFatSenha+' "'+AllTrim(cOpFatDest)+'" "'+cMail+'" ') // Comentada RBorges 12/03/15
		
	ElseIf cOrigem == "VENDAS"                                                                   
        // Monta a mensagem a ser enviado ao operador
        /*cOpFatDest  := GetMV("MV_LICVCIC") 
		cMail := "LICITAÇÃO - EDITAL AGUARDANDO LIBERAÇÃO DO DIRETOR COMERCIAL"+CR+CR
		cMail += "O edital " +UA1->UA1_CODIGO
		cMail += " do Cliente "+AllTrim(UA1->UA1_CODCLI)+" - "+AllTrim(M->UA1_NOME)+CR
		cMail += " aguarda liberação do diretor comercial !"+CR+CR 
		cMail += CR+U_DipUsr()*/
		
        cOpFatDest  := GetMV("MV_LICVCIC") 
		cMail := "LICITAÇÃO - EDITAL LIBERADO AUTOMATICAMENTE PELO DIRETOR COMERCIAL"+CR+CR
		cMail += "O edital " +UA1->UA1_CODIGO
		cMail += " do Cliente "+AllTrim(UA1->UA1_CODCLI)+" - "+AllTrim(M->UA1_NOME)+CR
		cMail += " Foi liberado automaticamente pelo Diretor comercial !"+CR+CR 
		cMail += CR+U_DipUsr()
		
		
		
		// Envia a mensagem ao operador através do CIC	
		U_DIPCIC(cMail,AllTrim(cOpFatDest))// RBorges 12/03/15
//		WaitRun(cServidor+' '+cOpFatRem+' '+cOpFatSenha+' "'+AllTrim(cOpFatDest)+'" "'+cMail+'" ') // RBorges 12/03/15
	Endif

Return()    
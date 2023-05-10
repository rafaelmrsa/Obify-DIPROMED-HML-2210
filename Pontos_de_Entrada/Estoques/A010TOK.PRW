/*====================================================================================\
|Programa  | MATA010       | Autor | Eriberto Elias             | Data | 12/08/2004   |
|=====================================================================================|
|Ponto Ent | A010TOK                                                                  |
|=====================================================================================|
|Descrição | LOCALIZADO NA VALIDACAO DO PRODUTO                                       |
|          | Este ponto de entrada tem como objetivo validar o produto                |
|          | antes de gravar no arquivo.                                              |
|          |  1                                                                        |
|          |                                                                          |
|          |                                                                          |
|          |                                                                          |
|=====================================================================================|
|Parâmetros| UPAR do tipo X : Nenhum.                                                 |
|=====================================================================================|
|Retorno   | URET do tipo X : Logico. Caso verdadeiro grava registro.                 |
|          | Caso falso retorna a tela de inclusao ou alteracao do produto.           | 
|=====================================================================================|
|Observ.   | Nenhum                                                                   |
|=====================================================================================|
|Sintaxe   | XXXXXXX                                                                  |
|=====================================================================================|
|Uso       | Especifico DIPROMED                                                      |
|=====================================================================================|
|........................................Histórico....................................|
|Rafael    | 12/08/04 - Adicionado a função de envio de e-mail                        |
|Maximo    | 09/08/07 - Alterando o Envio de e-mail e incluindo envio de cic quando   |
|          |            preço de promoção for alterado.                               |
|Maximo    | 04/11/08 - Definido que só será enviado cic qdo alterado o preço de      |
|          |            promoção for alterado e Email sempre é enviado                |
|Eriberto  | DD/MM/AA - Descrição                                                     |
\====================================================================================*/

#INCLUDE "RWMAKE.CH"
#INCLUDE "AP5MAIL.CH" 
#INCLUDE "PROTHEUS.CH"
#INCLUDE 'FWMVCDEF.CH'
#DEFINE CR    chr(13)+chr(10) // Carreage Return (Fim de Linha)

User Function A010TOK()

	Local cEmail        :=If(cEmpAnt == '01','erich@dipromed.com.br;patricia.mendonca@dipromed.com.br','protheus@dipromed.com.br')
	Local cAssunto      := ''  
	Local cTitulo       := '' 
	Local aEnv_Pro      := {}     
	Local UserRevFis    := GetMv("MV_UREVFIS")    
	Local cDipUser      := Upper(AllTrim(GetNewPar("ES_TRAVSB",""))) 
	Local cUsuario      := Upper(U_DipUsr())

	Private  cObsAltPro := ''
	Private oSB1Model 	:= FWModelActive()
	Private oStruSB1

	U_DIPPROC(ProcName(0),U_DipUsr()) // JBS 05/10/2005 - Gravando o nome do Programa no SZU    

	// VALIDANDO CÓDIGO DO PRODUTO - MCVN  21/09/2009
	If !ALTERA .And. !('DIPM_B1'$FUNNAME()) .And. (Type("l010Auto")=="U" .Or. !l010Auto)
		If !U_DipValSB1() 
			Return(.F.)
		Endif
	Endif

	//-- Valida Preenchimento do campo TES  - D'Leme: 10/10/2011
	If (Type("l010Auto")=="U" .Or. !l010Auto) .And. (INCLUI .Or. ALTERA)
		If Empty(M->B1_TE) .Or. Empty(M->B1_TS)
			MsgAlert("Preencha TES padrão para Entrada e Saída!","Atenção")
			Return .F.
		EndIf
	EndIf

	//RBorges - 22/10/14 - Verificar se algum campo foi alterado e gravar o usuário e a data. 

	If INCLUI .Or. ALTERA

		If Upper(U_DipUsr()) $ cDipUser

			If  M->B1_XQTDEMB <> SB1->B1_XQTDEMB .Or.;
			M->B1_PESOEMB <> SB1->B1_PESOEMB .Or.;
			M->B1_LARGURA <> SB1->B1_LARGURA .Or.;
			M->B1_ALTURA  <> SB1->B1_ALTURA  .Or.;
			M->B1_COMPRIM <> SB1->B1_COMPRIM .Or.;
			M->B1_XCUBEMB <> SB1->B1_XCUBEMB .Or.;
			M->B1_CODBAR  <> SB1->B1_CODBAR  .Or.;
			M->B1_QE      <> SB1->B1_QE      .Or.;
			M->B1_XQTDSEC <> SB1->B1_XQTDSEC .Or.;
			M->B1_XPESSEC <> SB1->B1_XPESSEC .Or.;
			M->B1_XLARSEC <> SB1->B1_XLARSEC .Or.;
			M->B1_XALTSEC <> SB1->B1_XALTSEC .Or.;
			M->B1_XCOMSEC <> SB1->B1_XCOMSEC .Or.;
			M->B1_XCUBSEC <> SB1->B1_XCUBSEC .Or.;
			M->B1_XBARSEC <> SB1->B1_XBARSEC .Or.;
			M->B1_XLARPRI <> SB1->B1_XLARPRI .Or.;
			M->B1_XALTPRI <> SB1->B1_XALTPRI .Or.;
			M->B1_XCOMPRI <> SB1->B1_XCOMPRI .Or.;
			M->B1_XCUBPRI <> SB1->B1_XCUBPRI .Or.;
			M->B1_XBARRUM <> SB1->B1_XBARRUM .Or.;
			M->B1_XTPEMBV <> SB1->B1_XTPEMBV .Or.;
			M->B1_XTPEMBC <> SB1->B1_XTPEMBC .Or.;
			M->B1_PESO    <> SB1->B1_PESO    .Or.;
			M->B1_PESBRU  <> SB1->B1_PESBRU  .Or.;
			M->B1_XVALSEC <> SB1->B1_XVALSEC

				M->B1_XDTATU := dDataBase
				M->B1_XUSESB := cUsuario

				oSB1Model:SetValue('SB1MASTER','B1_XDTATU',dDataBase)
				oSB1Model:SetValue('SB1MASTER','B1_XUSESB',cUsuario)

				// RBorges - 04/11/14 - Se algum dos campos abaixo for alterado gravar a data e o nome
				// de quem alterou, campos da qualidade.
			ElseIf M->B1_REG_ANV <> SB1->B1_REG_ANV .Or.;
			M->B1_DTV_ANV <> SB1->B1_DTV_ANV .Or.;
			M->B1_CANVISA <> SB1->B1_CANVISA .Or.;
			M->B1_RANVISA <> SB1->B1_RANVISA 

				M->B1_XDTANV := dDataBase
				M->B1_XUSEAV := cUsuario

				oSB1Model:SetValue('SB1MASTER','B1_XDTANV',dDataBase)
				oSB1Model:SetValue('SB1MASTER','B1_XUSEAV',cUsuario)

			EndIf
		EndIf
	EndIf	


	If ALTERA       

		If M->B1_PRV1 <> SB1->B1_PRV1 .or. ;
		M->B1_PRVSUPE <> SB1->B1_PRVSUPE .or. ;
		M->B1_PRVMINI <> SB1->B1_PRVMINI .or. ;
		M->B1_PRVPROM <> SB1->B1_PRVPROM

			// ALTERADOITEM 5 DO ARRY DE B1_UPRC PARA B1_CUSDIP - 22/09/09 MCVN
			Aadd(aEnv_Pro,{SB1->B1_COD, SB1->B1_DESC, SB1->B1_UM, SB1->B1_UCOM, SB1->B1_CUSDIP, SB1->B1_PRV1, SB1->B1_PRVSUPE, SB1->B1_PRVMINI, SB1->B1_PRVPROM}) 
			Aadd(aEnv_Pro,{M->B1_COD, M->B1_DESC, M->B1_UM, M->B1_UCOM, M->B1_CUSDIP, M->B1_PRV1, M->B1_PRVSUPE, M->B1_PRVMINI, M->B1_PRVPROM})	

			// MCVN - 09/08/2007
			If M->B1_PRV1 > SB1->B1_PRV1 // Verifico somente a diferença no preço de lista porque os outros são alterados proporcionalmente
				cAssunto := 'Aumento de preco feito por: '+ Upper(U_DipUsr())+' - Codigo-'+ SB1->B1_COD + " - Empresa: "+ If(cEmpAnt=="04","HQ","DIPROMED")
				U_Env_Pro(cEmail,cAssunto,aEnv_Pro)
				//	EnvCic(aEnv_Pro,cAssunto,cTitulo,"C") Desabilitado a partir de 04/11/2008 - MCVN 
			ElseIf M->B1_PRV1 < SB1->B1_PRV1
				cAssunto := 'Reducao de preco feita por: '+ Upper(U_DipUsr())+' - Codigo-'+ SB1->B1_COD	+ " - Empresa: "+ If(cEmpAnt=="04","HQ","DIPROMED")	
				U_Env_Pro(cEmail,cAssunto,aEnv_Pro)
				//	EnvCic(aEnv_Pro,cAssunto,cTitulo,"C")Desabilitado a partir de 04/11/2008  - MCVN 
			Endif


			// Envia Cic quando produto entra ou sai de promoção  MCVN - 09/08/2007
			If M->B1_PRVSUPE <> SB1->B1_PRVSUPE  
				cObsAltPro:= "" 

				// Desabilitada opção de mensagem no cic e e-mail em 17/12/10 (Solicitado pelo Eriberto)
				/*IF MsgBox("PROMOÇÃO!   Deseja incluir uma observação no Cic e no Email enviado aos colaboradores?","Atencao","YESNO")  		
				cObsAltPro:=u_ObsAltPro() // MCVN - 18/02/10		
				Endif */

				If M->B1_PRVSUPE = 0
					cTitulo  := 'SAIU da promoção'
					cAssCic  := 'Produto saiu da promoção'
					cAssunto := 'Produto saiu da promocao'	+' - Codigo-'+ SB1->B1_COD +' - Alterado por: '+ Upper(U_DipUsr())+ " - Empresa: "+ If(cEmpAnt=="04","HQ","DIPROMED")
				Elseif	M->B1_PRVSUPE > SB1->B1_PRVSUPE  .And. SB1->B1_PRVSUPE > 0 
					cTitulo  := 'PROMOÇÃO - Alteração de preço.'                          
					cAssCic  := 'Produto continua em promoção mas houve aumento no preço'
					cAssunto := 'Produto continua em promocao mas houve aumento no preco' +' - Codigo-'+ SB1->B1_COD +' - Alterado por: '+ Upper(U_DipUsr()) + " - Empresa: "+ If(cEmpAnt=="04","HQ","DIPROMED")
				Elseif	M->B1_PRVSUPE < SB1->B1_PRVSUPE  .And. M->B1_PRVSUPE > 0 
					cTitulo  := 'PROMOÇÃO - Alteração de preço.'                            
					cAssCic  := 'Produto continua em promoção e houve redução no preço' 
					cAssunto := 'Produto continua em promocao e houve reducao no preco' +' - Codigo-'+ SB1->B1_COD +' - Alterado por: '+ Upper(U_DipUsr())+ " - Empresa: "+ If(cEmpAnt=="04","HQ","DIPROMED")                            		
				Elseif	M->B1_PRVSUPE > SB1->B1_PRVSUPE  .And. SB1->B1_PRVSUPE = 0                               
					cTitulo  := 'PROMOÇÃO'                         
					cAssCic  := 'Produto em promoção'+ " - Empresa: "+ If(cEmpAnt=="04","HQ","DIPROMED")                            
					cAssunto := 'Produto em promocao'+' - Codigo-'+ SB1->B1_COD	+' - Alterado por: '+ Upper(U_DipUsr())	+ " - Empresa: "+ If(cEmpAnt=="04","HQ","DIPROMED")                            
				Endif  

				// Chama função que envia email e Cic MCVN - 09/08/2007
				U_Env_Pro(cEmail,cAssunto,aEnv_Pro)
				U_EnvCic(aEnv_Pro,cAssunto,cTitulo,"PRO")	    	

			Endif
			
			nAtuPrc := 0
	        If cEmpAnt == "01"      	
	        	nAtuPrc := Aviso("Atenção","Atualiza a informação nas duas filiais?",{"Não","Sim"},2)  			
	   	    Endif
	   	    
	   	    if nAtuPrc == 2
	   	    		aAreaAux := SB1->(GetArea())
			    	SB1->(DbSetOrder(1)) //-- B1_FILIAL+B1_COD
			    	If SB1->(DbSeek( xFilial("SB1",Iif(cFilAnt=="01","04","01")) + B1_COD ))
				   		RecLock("SB1",.F.)		     		
				     		SB1->B1_PRVSUPE   := M->B1_PRVSUPE
					   		SB1->B1_PRV1      := M->B1_PRV1
							SB1->B1_PRVPROM   := M->B1_PRVPROM
							SB1->B1_PRVMINI   := M->B1_PRVMINI
						    SB1->B1_ALTPREC   := M->B1_ALTPREC
						    SB1->( MsUnLock() )        
					    SB1->( DbCommit() )        
			    	endif
			    	RestArea( aAreaAux )
					
	   	    endif

		EndIf
		
		//Verificar se atualiza ou não o Preço - 13/10/11
		
		
		//U_M010NCM()  // Verifica ICMS-ST MCVN - 11/03/09
	EndIf 

	If !('DIPM_B1' $ FUNNAME()) .And. (Type("l010Auto")=="U" .Or. !l010Auto)
		U_M010NCM("A010TOK")  // Verifica ICMS-ST MCVN - 11/03/09          
	Endif                 

	//-- Copia de PA para Health/Cd e Dipromed
	If (Type("l010Auto")=="U" .Or. !l010Auto) //.And. cEmpAnt+cFilAnt == "0401" 

		U_ClrMemSB1() //-- Zera Array com variaveis de memória

		If (Inclui .And. AllTrim(M->B1_TIPO) $ "PA/MC/MP/PI/BN" ).Or. ;
		(Altera .And. (AllTrim(M->B1_TIPO) $ "PA/MC/MP/PI/BN" .Or. AllTrim(SB1->B1_TIPO) $ "PA/MC/MP/PI/BN" ))

			U_SvMemSB1() // Guarda Array com variáveis de Memoria para uso posterior na gravacao

		EndIf

	EndIf


	//------------------------------------------------------------------------------------
	// VALIDAÇÃO DOS CAMPOS RESPONSÁVEIS PELO CALCULO DOS IMPOSTOS 
	// Avalia os campo (B1_REDPIS, B1_REDCOF, B1_TE, B1_TS, B1_ORIGEM,  B1_PICMRET
	// B1_PICMENT, B1_PICM, B1_IPI)  e atualiza o campo B1_DREVFIS que será
	// utilizado na validação do pedido de venda.
	// Maximo Canuto Vieira - MCVN 17/09/10
	//------------------------------------------------------------------------------------

	If !('DIPM_B1' $ FUNNAME()) .And. (Type("l010Auto")=="U" .Or. !l010Auto)  .And. M->B1_TIPO = 'PA'
		If Altera

			If 	!(Upper(U_DipUsr()) $ UserRevFis)
				If M->B1_REDPIS <> SB1->B1_REDPIS .or. ;
				M->B1_REDCOF    <> SB1->B1_REDCOF    .or. ;
				M->B1_TE        <> SB1->B1_TE        .or. ;
				M->B1_TS        <> SB1->B1_TS        .or. ;
				M->B1_ORIGEM    <> SB1->B1_ORIGEM    .or. ;
				M->B1_PICMRET   <> SB1->B1_PICMRET   .or. ;
				M->B1_PICMENT   <> SB1->B1_PICMENT   .or. ;
				M->B1_PICM      <> SB1->B1_PICM      .or. ;
				M->B1_IPI       <> SB1->B1_IPI       .or. ;
				M->B1_IVAAJU    <> SB1->B1_IVAAJU    .or. ;
				M->B1_ARTIGST   <> SB1->B1_ARTIGST   .or. ;
				(Left(UPPER(SB1->B1_DESC),1) =='Z'  .and.  Left(UPPER(M->B1_DESC),1)  <> 'Z')  // @Andre Mendes - Obify - 22/07/2021 - quando o "Z" é removido indica que passa para o fiscal.     
//				M->B1_DESC      <> SB1->B1_DESC      .or. ; @Andre Mendes - Obify - 22/07/2021 - diferença na descrição não precisa de liberação do fiscal

					cAssunto:="Produto necessita de liberacao do departamento fiscal."
					cTitulo :="DEPARTAMENTO FISCAL - AVALIAÇÃO DE CADASTRO DE PRODUTO  - (ALTERAÇÃO)."
					// Alimentando Array para envio de CIC
					Aadd(aEnv_Pro,{SB1->B1_COD, SB1->B1_DESC, SB1->B1_REDPIS, SB1->B1_REDCOF, SB1->B1_TE, SB1->B1_TS, SB1->B1_ORIGEM, SB1->B1_PICMRET, SB1->B1_PICMENT,SB1->B1_PICM,SB1->B1_IPI, SB1->B1_IVAAJU, SB1->B1_ARTIGST }) 
					Aadd(aEnv_Pro,{M->B1_COD, M->B1_DESC, M->B1_REDPIS, M->B1_REDCOF, M->B1_TE, M->B1_TS, M->B1_ORIGEM, M->B1_PICMRET, M->B1_PICMENT,M->B1_PICM,M->B1_IPI, M->B1_IVAAJU, M->B1_ARTIGST} ) 
					Aadd(aEnv_Pro,{"SB1->B1_COD", "SB1->B1_DESC", "PERC. RED. PIS","PERC. RED. COFINS","TES PADRÃO DE ENTRADA","TES PADRÃO DE SAÍDA","ORIGEM DO PRODUTO","IVA DE ENTRADA","IVA DE SAÍDA","ALIQ. ICMS","ALIQ. IPI","IVA AJUSTADO","ARTIGO ST"}) 				


					SB1->( RecLock("SB1",.F.) )	
					SB1->B1_DREVFIS := ""		                        			
					SB1->( MsUnLock('SB1'))                             
					If cEmpAnt+cFilAnt <> '0401'
						U_EnvCic(aEnv_Pro,cAssunto,cTitulo,"REVFIS")
					Endif	   
					M->B1_DREVFIS := ""  // BLoqueia produto. 
					
					oStruSB1:= oSB1Model:GetModel("SB1MASTER"):GetStruct()

					oStruSB1:SetProperty('B1_DREVFIS', MODEL_FIELD_WHEN, FwBuildFeature(STRUCT_FEATURE_WHEN, '.T.'))
					oSB1Model:SetValue('SB1MASTER','B1_DREVFIS',"")	   	
				Endif
			Endif
		Else
			// Alimentando Array para envio de CIC
			Aadd(aEnv_Pro,{M->B1_COD, M->B1_DESC, M->B1_REDPIS, M->B1_REDCOF, M->B1_TE, M->B1_TS, M->B1_ORIGEM, M->B1_PICMRET, M->B1_PICMENT,M->B1_PICM,M->B1_IPI, M->B1_IVAAJU, M->B1_ARTIGST} ) 
			Aadd(aEnv_Pro,{M->B1_COD, M->B1_DESC, M->B1_REDPIS, M->B1_REDCOF, M->B1_TE, M->B1_TS, M->B1_ORIGEM, M->B1_PICMRET, M->B1_PICMENT,M->B1_PICM,M->B1_IPI, M->B1_IVAAJU, M->B1_ARTIGST} ) 
			Aadd(aEnv_Pro,{"SB1->B1_COD", "SB1->B1_DESC", "PERC. RED. PIS","PERC. RED. COFINS","TES PADRÃO DE ENTRADA","TES PADRÃO DE SAÍDA","ORIGEM DO PRODUTO","IVA DE ENTRADA","IVA DE SAÍDA","ALIQ. ICMS","ALIQ. IPI","IVA AJUSTADO","ARTIGO ST"}) 				

			cAssunto:="Produto necessita de liberacao do departamento fiscal."
			cTitulo :="DEPARTAMENTO FISCAL - AVALIAÇÃO DE CADASTRO DE PRODUTO - (INCLUSÃO)."
			If cEmpAnt+cFilAnt <> '0401'
				U_EnvCic(aEnv_Pro,cAssunto,cTitulo,"REVFIS")	    	   	
			Endif
		Endif
	Endif  
	/* Removido por conta da implantação da ST padrão
	If INCLUI .Or. ALTERA
		If xFilial("SB1")=="01" .And. M->B1_TIPO = "PA" .And. !(SubStr(M->B1_DESC,1,1)$"./Z")
			If M->B1_ORIGEM$"1/2/3/8" .And. M->B1_GRTRIB<>"001"  
				M->B1_GRTRIB := "001"
				oSB1Model:SetValue('SB1MASTER','B1_GRTRIB',"001")	
			ElseIf !(M->B1_ORIGEM$"1/2/3/8") .And. M->B1_GRTRIB=="001"
				M->B1_GRTRIB := ""	
				oSB1Model:SetValue('SB1MASTER','B1_GRTRIB',"")
			EndIf
		EndIf

	EndIf
	*/
	If !('DIPM_B1'$FUNNAME()) .And. (Type("l010Auto")=="U" .Or. !l010Auto)
		If ALTERA .And. M->B1_XCODDES<>'' .And. M->B1_XCXFECH == '1' .And.  M->B1_XVLDCXE == '1' .And. !Empty(SB1->B1_XCODDES)
			MsgBox("FAVOR ALTERAR  AS  MESMAS INFORMAÇÕES NO CÓDIGO "+SB1->B1_XCODDES+"!","ATENÇÃO","OK")
		Endif
	EndIf
	
	//
	If lCopia
	
	//ES_XB1CPY 
		

	EndIf

	U_XULTPRC()
	U_GravaZG("SB1") // Atualiza Kardex Dipromed                         

Return(.T.)

/*============================================================================\
|Programa  | Env_Pro  | Autor | Rafael de Campos Falco  | Data | 10/08/2004   |
|=============================================================================|
|Desc.     | Envio de EMail                                                   |
|=============================================================================|
|Sintaxe   | Env_Pro                                                          |
|=============================================================================|
|Uso       | Especifico DIPROMED                                              |
\=============================================================================*/

User Function Env_Pro(cEmail,cAssunto,aMsg,aAttach)

	Local cEmailTo  := ""
	Local cEmailCc  := ""
	Local cEmailBcc := ""



	// Envia para o Erich com o Custo
	EscreveEmail(cEmailTo,cEmailCc,cEmailBcc,cAssunto,cEmail,aMsg,aAttach,.t.)

	// Envia para os demais interessados - Incluído televendas no e-mail 04/11/2008
	cEmail   := GetNewPar("ES_ENV_PRO","compras@dipromed.com.br;callcenter@dipromed.com.br;publico@dipromed.com.br;apoio@dipromed.com.br") 
	cEmailCc := ""
	cEmailBcc:= "maximo.canuto@dipromed.com.br"

	If (AllTrim(Upper(U_DipUsr()))$'MCANUTO')  // Apenas para teste MCVN - 08-06-11
		cEmail   := "maximo.canuto@dipromed.com.br"
		cEmailCc := ""
		cEmailBcc:= ""
	Endif

	EscreveEmail(cEmailTo,cEmailCc,cEmailBcc,cAssunto,cEmail,aMsg,aAttach,.f.)

	Return(.T.)   
	*-------------------------------------------------------------------------------------------------*   
Static Function EscreveEmail(cEmailTo,cEmailCc,cEmailBcc,cAssunto,cEmail,aMsg,aAttach,lMostraCusto)
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
	cMsg += '<table width="100%" border="1">'
	cMsg += '<tr align="Left">'
	cMsg += '<td width="100%" colspan="10"><font color="blue" size="5">' + If(cEmpAnt=="04","HQ","DIPROMED"+'-'+SM0->M0_FILIAL) + '</font></td>'
	cMsg += '</tr>'                           
	cMsg += '</table >'
	cMsg += '<HR Width=85% Size=3 Align=Centered Color=Red> <P>'     
	cMsg += '<Table Align=Center BorderColor=#000000 CELLPADDING=4 CELLSPACING=0 Width=60%>'

	/*=============================================================================*/
	/*Definicao do cabecalho do relatório                                          */
	/*=============================================================================*/

	If Len(Alltrim(cObsAltPro)) > 0 // MCVN - 18/02/10			                               
		cMsg += '<table width="100%" border="1">'
		cMsg += '<tr align="Left">'
		cMsg += '<td width="100%" colspan="10"><font color="black" size="5"> Observação: ' + Upper(cObsAltPro) + '</font></td>'
		cMsg += '</tr>'  
	Endif
	cMsg += '<table width="100%" border="1">'
	cMsg += '<tr align="center">'
	cMsg += '<td width="100%" colspan="10"><font color="red" size="4">' + cAssunto + '</font></td>'
	cMsg += '</tr>'

	cMsg += '<tr align="center">'
	cMsg += '<td width="100%" colspan="10"><font color="red" size="2">Produto: <font color="blue" size="2">' + aMsg[1,2] + '<font color="red" size="2">  -  Unid. Medida:<font color="blue" size="2">' + aMsg[1,3] + '</td>'
	cMsg += '</font>'
	cMsg += '</tr>'

	cMsg += '<tr align="center">'
	cMsg += '<td width="10%"><font color="red" size="2">Preços:</td>'
	cMsg += '<td width="10%"><font color="red" size="2">Lista</td>'
	cMsg += '<td width="10%"><font color="red" size="2">D</td>'
	cMsg += '<td width="10%"><font color="red" size="2">C</td>'
	cMsg += '<td width="10%"><font color="red" size="2">Promoção</td>'
	If lMostraCusto
		cMsg += '<td width="10%"><font color="red" size="2">Custo</td>'
		cMsg += '<td width="10%"><font color="red" size="2">Últ. Compra</td>'
	EndIf
	cMsg += '<td width="70%" colspan="10" align="left"><font color="red" size="2"></td>'
	cMsg += '</font>'
	cMsg += '</tr>'

	For xi:=1 to Len(aMsg)
		cMsg += '<tr align="center">'
		If Mod(xi,2) == 0
			cMsg += '<td width="10%"><font color="red" size="2">Novo:</td>'
		Else
			cMsg += '<td width="10%"><font color="red" size="2">Antigo:</td>'
		EndIf
		cMsg += '<td width="10%" align="right"><font color="blue" size="2">' + TransForm(aMsg[xi,6],"@E 999,999.9999") + '</td>'
		cMsg += '<td width="10%" align="right"><font color="blue" size="2">' + TransForm(aMsg[xi,9],"@E 999,999.9999") + '</td>'
		cMsg += '<td width="10%" align="right"><font color="blue" size="2">' + TransForm(aMsg[xi,8],"@E 999,999.9999") + '</td>'
		cMsg += '<td width="10%" align="right"><font color="blue" size="2">' + TransForm(aMsg[xi,7],"@E 999,999.9999") + '</td>'
		If lMostraCusto
			cMsg += '<td width="10%" align="right"><font color="blue" size="2">' + TransForm(aMsg[xi,5],"@E 999,999.9999") + '</td>'
			cMsg += '<td width="10%"><font color="blue" size="2">' + SubStr(DtoS(aMsg[xi,4]),7,2) + "/" + SubStr(DtoS(aMsg[xi,4]),5,2) + "/" + SubStr(DtoS(aMsg[xi,4]),1,4) + '</td>'
		EndIF
		cMsg += '<td width="60%" colspan="10" align="left"><font color="blue" size="2"></td>'
		cMsg += '</font>'
		cMsg += '</tr>'
	Next

	/*==============================================================================\
	| Definicao do rodape do email                                                  |
	\==============================================================================*/
	cMsg += '<tr align="center">'
	cMsg += '<td colspan="10"><font color="red" size="3">Mensagem enviada automaticamente pelo sistema PROTHEUS - <font color="red" size="1">'+If("DIPA008" $ cAssunto,"(DIPA008.PRW)","(A010TOK.PRW)")+'</td>'
	cMsg += '</tr>'

	cMsg += '</table>'
	cMsg += '<HR Width=85% Size=3 Align=Centered Color=Red> <P>'
	cMsg += '</body>'
	cMsg += '</html>'

	/*==============================================================================\
	| Envia o mail para a lista selecionada. Envia como BCC para que a pessoa pense |
	| que somente ela recebeu aquele email, tornando o email mais personalizado.    |
	\==============================================================================*/


	If GetNewPar("ES_ATIVJOB",.T.)
		cEmailTo := Alltrim(cEmail)+";"+AllTrim(cEmailCc)+";"+AllTrim(cEmailBcc)
		u_UEnvMail(AllTrim(cEmailTo),cAssunto,nil,"",cFrom,"DIPA008(A010TOK.PRW)",cMsg)
	Else

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

	EndIf

	Return(.T.)

	*--------------------------------------------------------------------------*
//Função para enviar Cic   MCVN - 09/08/2007
User Function EnvCic(aEnv_Pro,cAssunto,cTitulo,cTipo)
	*--------------------------------------------------------------------------*
	Local lRetorno := .T.
	Local cMail
	Local cServidor   := GetMV("MV_CIC")     // Servidor para enviar mensagem pelo CIC
	Local cOpFatRem   := GetMV("MV_REMETCI") // Usuario do CIC remetente de mensgens no Protheus
	Local cOpFatSenha := "123456"
	Local cCliente := ""      
	Private cOpFatDest := If(cTipo<>'REVFIS',"",GetMv("MV_CREVFIS"))

	If Empty(Alltrim(cOpFatDest))
		BuscaCic(cTipo)  // Busca CIC no cadastro de operador
	EndIf

	// Monta a mensagem a ser enviado ao operador   (Alterado para enviar somente quando o preço de promoção for alterado)MCVN - 24/10/2007
	If cTipo<>'REVFIS'

		If cTipo = "PRO"    
			cMail :=  If(cEmpAnt+cFilAnt=="0404","HQ",If(cEmpAnt+cFilAnt=="0401","HQ-MATRIZ","DIPROMED"+"-"+SM0->M0_FILIAL))+CR+CR       
			cMail += cTitulo+CR+CR
			//cMail += cAssunto+CR+CR
			cMail += aEnv_Pro[1,1] + ' - ' + aEnv_Pro[1,2] +CR+CR
			If aEnv_Pro[2,7] > 0
				cMail += "Preço alterado de :  R$  "+ TransForm(aEnv_Pro[1,7],"@E 999,999.9999") +"  para   R$  " + TransForm(aEnv_Pro[2,7],"@E 999,999.9999")+CR+CR
			Endif           
			cMail += "Alterado por: "  + U_DipUsr() +CR+CR 
			If Len(Alltrim(cObsAltPro)) > 0 // MCVN - 18/02/10			                               
				cMail += "Observação: " + UPPER(cObsAltPro) +CR+CR 
			Endif
		Else
			cMail :=  If(cEmpAnt+cFilAnt=="0404","HQ",If(cEmpAnt+cFilAnt=="0401","HQ-MATRIZ","DIPROMED"))+CR+CR       
			cMail += "C  -  Alteração de preço"+CR+CR
			//cMail += cAssunto+CR+CR
			cMail += aEnv_Pro[1,1] + ' - ' + aEnv_Pro[1,2] +CR+CR
			cMail += "Preço alterado de :  R$  "+ TransForm(aEnv_Pro[1,8],"@E 999,999.9999") +"  para   R$  " + TransForm(aEnv_Pro[2,8],"@E 999,999.9999")+CR+CR
			cMail += "Alterado por: " + U_DipUsr()
		Endif	                       
	Else                                                   
		cMail :=  If(cEmpAnt+cFilAnt=="0404","HQ",If(cEmpAnt+cFilAnt=="0401","HQ-MATRIZ","DIPROMED"))+CR+CR       
		cMail += cTitulo+CR+CR
		cMail += cAssunto+CR
		cMail += aEnv_Pro[1,1] + ' - ' + aEnv_Pro[1,2]+CR+CR
		cMail += "CAMPOS:"+CR+CR
		For x:= 3 to 13
			If aEnv_Pro[1,X] <> aEnv_Pro[2,X]
				cMail += If(X>3,",  ","  ")+aEnv_Pro[3,X]
			Endif
		Next x
		cMail += CR+CR
		cMail += U_DipUsr()
	Endif	 

	// Envia a mensagem ao operador através do CIC	
	U_DIPCIC(cMail,AllTrim(cOpFatDest))// RBorges 12/03/15
	//WaitRun(cServidor+' '+cOpFatRem+' '+cOpFatSenha+' "'+AllTrim(cOpFatDest)+'" "'+cMail+'" ') // Comentada 12/03/15

	Return()

	*--------------------------------------------------------------------------*
//Função para buscar usuários no CIC
Static Function BuscaCic(cTipo)  
	*--------------------------------------------------------------------------*

	// Busca Cic no cadastro dos operadorea 
	DbSelectArea("SU7")
	SU7->(DbSetOrder(1))
	SU7->(DbGoTop())
	SU7->(dbSeek(xFilial("SU7")+"000002"))

	// Alterado para enviar promoção para todos e preço C para Televendas  - MCVN 31/10/2008
	While !Eof() 
		//	    If ((U7_POSTO = "01" .And. cTipo = "PRO") .Or. U7_POSTO = "02" .Or. (U7_POSTO = "03" .And. cTipo = "PRO" )) .And.;
		//    	   U7_VALIDO == "1" .And. !Empty(Alltrim(U7_CICNOME))

		If (U7_POSTO $ "01" .And. cTipo = "PRO" .And.   U7_VALIDO == "1" .And. !Empty(Alltrim(U7_CICNOME)))	
			//	cOpFatDest := cOpFatDest+','+Alltrim(U7_CICNOME)          		
		Endif                                                                                                      

		SU7->(DbSkip())
	Enddo                                                             
	SU7->(DbCloseArea()) 

	// Busca Cic no cadastro dos compradores - MCVN 08/04/2008
	DbSelectArea("SY1")
	SY1->(DbSetOrder(1))
	SY1->(DbGoTop())
	SY1->(dbSeek(xFilial("SY1")+"005"))

	While !Eof() 
		If !Empty(Y1_NOMECIC)
			cOpFatDest := cOpFatDest+','+Alltrim(Y1_NOMECIC)          
		Endif
		SY1->(DbSkip())
	Enddo                                                             
	SY1->(DbCloseArea()) 

Return      

////////////////////////////////////////////////////////////////////////

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³M010NCM  ºAutor  ³Maximo Canuto        º Data ³  10/03/2009 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Atualiza B1_PICMRET, B1_PICMENT E B1_TE                    º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Dipromed                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
//#include "rwmake.ch"

User Function M010NCM(cPentrada)

	Local _xAlias   := GetArea() 
	Local _cFilSZH  := xFilial('SZH')
	Local _lRecLock := .F. 
	Local _cAlias   := Iif(cPentrada = 'A010TOK',"M","SB1")  // Chamada da função tudo OK no Cadastro ou Do P.E. MT010INC
	Local _bAlias   := {|x| &(_cAlias+"->"+x)}               // Substitui a referencia do alias no uso dos campos ou variavel de memoria.
	Local _cPosIPI  := eVal(_bAlias,"B1_POSIPI")
	Local _cCodPr   := eVal(_bAlias,"B1_COD")      
	Local _cQry0    := " " 
	Local lTcqu     := .F.
	Local cPosi     := "" 

	If Empty(_cPosIPI) .Or. !(Upper(u_DipUsr())$Upper(GetNewPar("ES_USRFISC","")))
		Return(.T.)
	Endif

	Begin Sequence



		_cQry0 :=" SELECT B1_POSIPI,TZH.ZH_NCM AS 'NCM' "
		_cQry0 +=" FROM  "+RETSQLNAME ("SB1") + " SB1 "
		_cQry0 +=" INNER JOIN(SELECT * FROM "+RETSQLNAME ("SZH") + " SZH "
		_cQry0 +=" WHERE SZH.D_E_L_E_T_ <> '*')TZH "
		_cQry0 +=" ON TZH.ZH_FILIAL = B1_FILIAL   "
		_cQry0 +=" AND (LTRIM(RTRIM(TZH.ZH_NCM)) = B1_POSIPI  "
		_cQry0 +=" OR LTRIM(RTRIM(TZH.ZH_NCM))   = 'G'+SUBSTRING(LTRIM(RTRIM(B1_POSIPI)),1,8) "
		_cQry0 +=" OR LTRIM(RTRIM(TZH.ZH_NCM))   = 'G'+SUBSTRING(LTRIM(RTRIM(B1_POSIPI)),1,7) "
		_cQry0 +=" OR LTRIM(RTRIM(TZH.ZH_NCM))   = 'G'+SUBSTRING(LTRIM(RTRIM(B1_POSIPI)),1,6) "
		_cQry0 +=" OR LTRIM(RTRIM(TZH.ZH_NCM))   = 'G'+SUBSTRING(LTRIM(RTRIM(B1_POSIPI)),1,5) "
		_cQry0 +=" OR LTRIM(RTRIM(TZH.ZH_NCM))   = 'G'+SUBSTRING(LTRIM(RTRIM(B1_POSIPI)),1,4))  "
		_cQry0 +=" WHERE SB1.D_E_L_E_T_ <> '*'   "
		_cQry0 +=" AND B1_POSIPI =  '"+_cPosIPI+"' "
		_cQry0 +=" AND B1_FILIAL =  '"+xFilial("SB1")+"'"
		//_cQry0 +=" AND B1_COD    =  '"+_cCodPr+"' "

		dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQry0),'TMP1',.T.,.F.)

		TMP1->(dbgotop())
		If !EMPTY ("TMP1")
			DbSelectArea("TMP1")
			DbGoTop()
			While TMP1->(!EOF())
				lTcqu:= .T.
				cPosi:= TMP1->NCM
				TMP1->( dbSkip())
			END

		EndIf

		TMP1->(DBCloseArea())
		SZH->( DbSetOrder(1) )
		If !lTcqu
			Break
		Else
			SZH->( DbSeek(_cFilSZH + cPosi) )
		EndIf


		If ((Altera .and. (Alltrim(_cPosIPI) <> Alltrim(SB1->B1_POSIPI)) .or. SB1->B1_PICMRET = 0) .or. INCLUI) .and. _cAlias == 'M' //.and. SB1->B1_PICMRET = 0
			fConsulta(1)
			Break
		EndIf

		If fConsulta(2)
			If cPentrada = 'A010TOK'

				If Posicione("SA2",1,xFilial('SA2')+SB1->B1_PROC,"A2_EST")=="SP"
					If M->B1_IPI = 0
						M->B1_TE := SZH->ZH_TESSIPI   // Pega do SZH TES Sem IPI em SP       S = Sem
						oSB1Model:SetValue('SB1MASTER','B1_TE',SZH->ZH_TESSIPI)
					Else
						M->B1_TE := SZH->ZH_TESCIPI   // Pega do SZH Tes Com IPI em SP       C = Com
						oSB1Model:SetValue('SB1MASTER','B1_TE',SZH->ZH_TESCIPI)
					Endif
				Else
					If M->B1_IPI = 0
						M->B1_TE := SZH->ZH_TEOSIPI   // Pega do SZH TES Sem IPI Fora de SP   O = Outros Estados S = Sem
						oSB1Model:SetValue('SB1MASTER','B1_TE',SZH->ZH_TEOSIPI)
					Else
						M->B1_TE := SZH->ZH_TEOCIPI   // Pega do SZH Tes Com IPI Fora de SP   O = Outros Estados C = Com
						oSB1Model:SetValue('SB1MASTER','B1_TE',SZH->ZH_TEOCIPI)
					Endif
				Endif

				M->B1_PICMRET := SZH->ZH_AL_SAID  // Aliquota de Saida
				M->B1_PICMENT := SZH->ZH_AL_ENTR  // Aliquota de Entrada
				M->B1_ARTIGST := SZH->ZH_ARTIGST  // ARTIGO ST

				oSB1Model:SetValue('SB1MASTER','B1_PICMRET',SZH->ZH_AL_SAID)
				oSB1Model:SetValue('SB1MASTER','B1_PICMENT',SZH->ZH_AL_ENTR)
				oSB1Model:SetValue('SB1MASTER','B1_ARTIGST',SZH->ZH_ARTIGST)

			Else

				SB1->( RecLock("SB1",.F.) )

				If Posicione("SA2",1,xFilial('SA2')+SB1->B1_PROC,"A2_EST")=="SP"
					If SB1->B1_IPI = 0
						SB1->B1_TE := SZH->ZH_TESSIPI  // Pega do SZH TES Sem IPI em SP       S = Sem
					Else
						SB1->B1_TE := SZH->ZH_TESCIPI   // Pega do SZH Tes Com IPI em SP       C = Com
					Endif
				Else
					If SB1->B1_IPI = 0
						SB1->B1_TE := SZH->ZH_TEOSIPI   // Pega do SZH TES Sem IPI Fora de SP   O = Outros Estados S = Sem
					Else
						SB1->B1_TE := SZH->ZH_TEOCIPI   // Pega do SZH Tes Com IPI Fora de SP   O = Outros Estados C = Com
					Endif
				Endif

				SB1->B1_PICMRET := SZH->ZH_AL_SAID  // Aliquota de Saida
				SB1->B1_PICMENT := SZH->ZH_AL_ENTR  // Aliquota de Entrada
				SB1->B1_ARTIGST := SZH->ZH_ARTIGST  // ARTIGO ST

				SB1->( MsUnLock('SB1'))
			EndIf
		EndIf
		fConsulta(0)
	End Sequence

Return(.T.)                   

Static Function fConsulta(nOpcao)
	Local cDescri := ""
	Static lResposta

	SX5->(DbSetOrder(1))
	SX5->(DbSeek(xFilial("SX5")+"ZA"+SZH->ZH_GRUPO))
	cDescri := ALLTRIM(SX5->X5_DESCRI)+" "+If(ALLTRIM(SX5->X5_DESCRI)<>ALLTRIM(SX5->X5_DESCSPA), ALLTRIM(SX5->X5_DESCSPA),"")+" "+If(ALLTRIM(SX5->X5_DESCRI)<>ALLTRIM(SX5->X5_DESCENG), ALLTRIM(SX5->X5_DESCENG),"")
	do case    
		case nOpcao == 0; lResposta := .F.
		case nOpcao == 1; lResposta := MSGBOX("Se o Produto " + If(ALTERA,"Alterado","Incluido") +  " estiver entre (" + cDescri + ") ele tem Substituição tributária em SP com IVA de" + STR(SZH->ZH_AL_ENTR) + ". "+ chr(13)+chr(10)+ "Confirma substituição tributária para o produto "+Alltrim(M->B1_COD)+"-"+Alltrim(M->B1_DESC)+"  ? ","Atenção","YESNO")
		case nOpcao == 2
		OtherWise
		lResposta := .F.
	endcase

	return(lResposta)

	////////////////////////////////////////////////////////////////////////////////
	/*               
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
	±±ºPrograma  ³DipValSB1 º Autor ³ Maximo             º Data ³ 08/09/2009  º±±
	±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
	±±ºDescricao ³ Validação do código no cadastro de produto(SB1)            º±±
	±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
	±±ºUso       ³ ESPECIFICO DIPROMED                                        º±±
	±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
	/*/
	*-------------------------------*
User Function DipValSB1()
	*-------------------------------*

	Local lRet 			:= .T.     
	Local oModelSB1		:= FWModelActive()
	Local lTem			:= .T.
	Local cQuery  := ""
	Local _cAlias := ""
                     
                     
		_b1_tipo      := oModelSB1:GetModel("SB1MASTER"):GetValue("B1_TIPO")	
		_b1_grupo     := oModelSB1:GetModel("SB1MASTER"):GetValue("B1_GRUPO")	
		_b1_cod       := ""
		_b1_proc      := oModelSB1:GetModel("SB1MASTER"):GetValue("B1_PROC") 

If ("HEALTH" $ SM0->M0_NOMECOM) .And. !(AllTrim(Upper(U_DipUsr()))$'MCANUTO/DDOMINGOS/RBORGES/RLOPES/BLANDINO')

		Do Case
			Case _b1_tipo == 'PA'
			_b1_cod := "2"
			Case _b1_tipo == 'AI'
			_b1_cod := "4"
			Case _b1_tipo == 'MP'
			_b1_cod := "6"
			Case _b1_tipo == 'PI' .And. _b1_grupo == "700 "
			_b1_cod := "7"	            
			Case _b1_tipo == 'PI' .And. _b1_grupo <> "700 "
			_b1_cod := "8"	    
			Case _b1_tipo == 'MC'
			_b1_cod := "9"	
		EndCase

		QRY1 := " SELECT LTRIM(RTRIM(STR(MAX(B1_COD)+1))) AS NEXTCOD"
		QRY1 += " FROM " + RetSQLName("SB1")
		/*COMENTADO ORIGINAL
		//	QRY1 += " WHERE B1_GRUPO 	 = '"  + _b1_grupo +  "'"
		QRY1 += " WHERE B1_TIPO    	 = '"  + _b1_tipo  +  "'"  
		*/  
		QRY1 += " WHERE B1_GRUPO 	 = '"  + _b1_grupo +  "'"
		QRY1 += " AND B1_TIPO    	 = '"  + _b1_tipo  +  "'"  
		QRY1 += " AND B1_FILIAL 	 = '"  + xFilial("SB1")+"'"
		QRY1 += " AND LEFT(B1_COD,3) = '"  + _b1_cod +SubStr(Alltrim(_b1_grupo),2,2) + "' 
		QRY1 += " AND "+RetSQLName("SB1")+".D_E_L_E_T_ <> '*'"

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
		DbCommitAll()

		If (Select("QRY1") > 0)
			dbCloseArea()
		EndIf

		TcQuery QRY1 NEW ALIAS "QRY1"         // Abre uma workarea com o resultado da query

		DbSelectArea("QRY1")
		QRY1->(dbGotop())	                  	                                  

		//12/05/2020 - Edson Estevam - Delta - Tratamento para adicionar 1 ao útimo código existente - verifcado que o sistema estava utilizando um código já existente. 
		cNextCodB1:=NEXTCOD
		
		/*					
		If !Empty(Alltrim(cNextCodB1))

			nNextCod := 0
			nNextCod := Val(cNextCodB1)
			
			nNextCod ++ 
                       
			cNextCodB1:= Alltrim(Str(nNextCod))	

		Endif
		*/ 

		If (Select("QRY1") > 0)
			dbCloseArea()
		EndIf

		If Empty(Alltrim(cNextCodB1))
			Do Case
				Case _b1_tipo == 'PA'
					cNextCodB1 := '2'+RIGHT(Alltrim(_b1_grupo),2)+'001'				
				Case _b1_tipo == 'AI'
					cNextCodB1 := '4'+RIGHT(ALLTRIM(_b1_grupo),2)+'001'
				Case _b1_tipo == 'MP'
					cNextCodB1 := '6'+RIGHT(ALLTRIM(_b1_grupo),2)+'001'
				Case _b1_tipo == 'PI' .And. _b1_grupo == '700 ' 
					cNextCodB1 := '7'+RIGHT(ALLTRIM(_b1_grupo),2)+'001'
				Case _b1_tipo == 'PI'.And. _b1_grupo <>  '700 '
					cNextCodB1 := '8'+RIGHT(ALLTRIM(_b1_grupo),2)+'001'
				Case _b1_tipo == 'MC'
					cNextCodB1 := '9'+RIGHT(ALLTRIM(_b1_grupo),2)+'001'	            
			EndCase
		Endif
		
		While lTem
		
			cQuery := " SELECT * " + CRLF
			cQuery += " FROM " + RetSqlName("SB1") + " SB1 " + CRLF
			cQuery += " WHERE SB1.D_E_L_E_T_ = ' ' AND B1_FILIAL = '" + xFilial("SB1") + "' " + CRLF
			cQuery += " AND B1_COD = '"+Alltrim(cNextCodB1)+"' "
			
			cQuery := ChangeQuery(cQuery)
			_cAlias:= GetNextAlias() 	
			If Select(_cAlias) > 0;( _cAlias )->( dbCloseArea() );EndIf
			dbUseArea(.t., "TOPCONN", TCGenQry(,,cQuery), _cAlias, .t., .t.)
			( _cAlias )->( dbGoTop() )
			If ( ( _cAlias )->( !Eof() ) )
				cNextCodB1 := SOMA1(Alltrim(cNextCodB1))
			Else
				lTem := .F.
			EndIf
			If Select(_cAlias) > 0;( _cAlias )->( dbCloseArea() );EndIf
		
		EndDo
		
		If _b1_tipo $ 'PA/MP/MC/AI/PI' 
			DbSelectArea("SBP")
			oModelSB1:SetValue("SB1MASTER","B1_COD",cNextCodB1)
            
			If INCLUI .AND. !(Left(cNextCodB1,1) $ "2/4/6/7/8/9")
				Alert("Os códigos devem começar com 2,4,6,7,8 ou 9 de acordo com a categoria do produto!")	
				lRet := .F.
			ElseIf INCLUI .AND. LEN(ALLTRIM(cNextCodB1)) <> 6 
				Alert("O código do produto deve ser formado com 6 caracteres!")
				lRet := .F.
			Endif                 
			If lRet
				Alert("O código do produto é "+cNextCodB1)		
			Endif
		//Inclução de parametro para validação dos usuarios com direito a incluir produtos diferentes do padrao - Blandino - 11/08/2020
		ElseIf (Upper(U_DipUsr())$Upper(GetNewPar("ES_PDTPDIF","")))
		//ElseIf (Upper(U_DipUsr()) $ 'MCANUTO/DDOMINGOS/RBORGES/RLOPES/BLANDINO/') antiga linha
			lRet := .T.                                             
		Else
			Alert("Para incluir produtos com tipo diferente de PA ,MP ,MC ,AI ,PI  é necessário falar com MAXIMO ou ERIBERTO!")	
			lRet := .F.
		Endif                  
	Else
		cNextCodB1    := oModelSB1:GetModel("SB1MASTER"):GetValue("B1_COD")
		If INCLUI .AND. Left(cNextCodB1,1) $ "2/3/4/6/7/8"  .And. !AllTrim(Upper(U_DipUsr()))$'MCANUTO/DDOMINGOS/RBORGES/RLOPES/BLANDINO' .And. _b1_proc <> '051508'
			Alert("Os códigos iniciados com 2 A 9 com exceto 5 e 7 estão reservados para HEALTH QUALITY!")
			lRet := .F.
		Endif
	Endif

Return(lRet)  

/*==========================================================================\
|Programa  | D3_EXPLIC | Autor | Rafael de Campos Falco  | Data | 07/06/2004|
|===========================================================================|
|Descrição | Digita explicação do movimento do estoque                      |
|===========================================================================|
|Sintaxe   | D3_EXPLIC                                                      |
|===========================================================================|
|Uso       | Especifico DIPROMED                                            |
|===========================================================================|
|Histórico | DD/MM/AA - Descrição da alteração                              |
\==========================================================================*/

User Function ObsAltPro()
	Local cObs := Space(100)
	Local _xAlias  := GetArea()
	Private lSaida := .T.

	U_DIPPROC(ProcName(0),U_DipUsr()) // JBS 05/10/2005 - Gravando o nome do Programa no SZU

	While lSaida
		@ 126,000 To 270,300 DIALOG oDlg TITLE OemToAnsi('PROMOÇÃO')
		@ 015,015 Say "Produto: "+SB1->B1_COD+"-"+SB1->B1_DESC
		@ 030,015 Get cObs Size 130,30 Picture "@S80" Valid !Empty(cObs)
		@ 050,055 BmpButton Type 1 Action (lSaida:=.F.,Close(oDlg))
		ACTIVATE DIALOG oDlg Centered
	End

	RestArea(_xAlias)
	Return(cObs)

Return

/*====================================================================================\
|Programa  | DIPR065    | Autor | Maximo Canuto                 | Data | 14/10/2008   |
|=====================================================================================|
|DescriÁ„o | PEDIDOS BLOQUEADOS                                                       |
|          |                                                                          |
|          |                                                                          |
|=====================================================================================|
|Sintaxe   | DIPR065                                                                  |
|=====================================================================================|
|Uso       | Especifico DIPROMED                                                      |
|=====================================================================================|
|........................................HistÛrico....................................|
|Maximo    | DD/MM/AA - DescriÁ„o                                                     |
|Maximo    | 23/10/08 - Alterado grupos de e-mail e estrutura do e-mail               |
|Maximo    | 23/10/08 - IncluÌdo rotina para enviar emails bloqueados no sistema      |
|Borges    | 22/01/18 - RelatÛrio alterado para gerar me PDF                          |
\====================================================================================*/

#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWPrintSetup.ch"
#INCLUDE "AP5MAIL.CH"
#INCLUDE "TBICONN.CH"

#IFNDEF WINDOWS
	#DEFINE PSay Say
#ENDIF

User Function DIPR065(aWork)

Local _xArea := GetArea()
Local _dData        
Private cWorkFlow	:= "" 
Private cWCodEmp    := ""  
Private cWCodFil    := "" 
Private cVend	    := ""
Private cMailVend	:= "" 
private QRY1
private QRY3
Private aPedCom	    := {} 
Private oFont14 := TFont():New("Arial",9,12,.T.,.F.,5,.T.,5,.T.,.F.)
Private oFont14n:= TFont():New("Arial",9,12,.T.,.T.,5,.T.,5,.T.,.F.)
Private oFont15 := TFont():New("Arial",9,13,.T.,.F.,5,.T.,5,.T.,.F.)
Private oFont15n:= TFont():New("Arial",9,13,.T.,.T.,5,.T.,5,.T.,.F.)
Private oFont16 := TFont():New("Arial",9,14,.T.,.T.,5,.T.,5,.T.,.F.)
Private oFont15n:= TFont():New("Arial",9,14,.T.,.T.,5,.T.,5,.T.,.F.)
Private oFont17 := TFont():New("Arial",9,15,.T.,.F.,5,.T.,5,.T.,.F.)
Private oFont17n:= TFont():New("Arial",9,15,.T.,.T.,5,.T.,5,.T.,.F.)
Private oFont20n:= TFont():New("Arial",9,18,.T.,.T.,5,.T.,5,.T.,.F.)
Private oFont33n:= TFont():New("Arial",9,31,.T.,.T.,5,.T.,5,.T.,.F.) 
Private cTipoRel:= "S" // S= relatÛrio de pedidos em saldo, B = relatÛrio de pedidos bloqueados Televendas e BA = Todos pedidos bloqueados MCVN - 23/10/08
Private cArq001 := ""
Private cArq002 := ""
Private cArq003 := ""
Private cArq004 := ""
Private cDepart := ""

//Tratamento para workflow

/*
If ValType(aWork) <> 'A'

	U_DIPPROC(ProcName(0),U_DipUsr()) // MCVN - 22/01/2009
	cWorkFlow := "N" 
	cWCodEmp  := cEmpAnt
    cWCodFil  := cFilAnt

Else
*/

cWorkFlow := aWork[1]    
cWCodEmp  := aWork[3]
cWCodFil  := aWork[4]  

//EndIf

If cWorkFlow == "S"                                  
	PREPARE ENVIRONMENT EMPRESA cWCodEmp FILIAL cWCodFil FUNNAME "DIPR065"
EndIf

ConOut('Inicio do relatorio dos pedidos com saldo, bloqueados, faturados e a faturar DIPR065 '+dToc(date())+' as '+Time())

U_DIPPROC(ProcName(0),U_DipUsr())

_dData := ((dDatabase)-1)

// Selecionando vendedores para envio dos pedidos faturados
QRY1 := " SELECT A3_COD, A3_EMAIL, A3_TIPO"
QRY1 += " FROM " + RetSQLName("SA3")
QRY1 += " WHERE A3_DESLIG = ''"
QRY1 += " AND A3_EMAIL    <> ''"            
QRY1 += " AND A3_COD      <> '000204'"
//QRY1 += " AND A3_COD      IN ('000192')"   
QRY1 += " AND " + RetSQLName("SA3") + ".D_E_L_E_T_ = ''"
	
QRY1 := ChangeQuery(QRY1)
	
dbUseArea(.T.,"TOPCONN",TcGenQry(,,QRY1),"QRY1",.F.,.T.)
			
DbSelectArea("QRY1")
DbGoTop()
While QRY1->(!EOF())   
    cVend     := QRY1->A3_COD
    cMailVend := QRY1->A3_EMAIL
    
    cTipoRel := "S"	    
   	RunProc()	// RelatÛrio de pedidos em Saldo para os vendedores
   	cTipoRel := "B"
   	If cTipoRel = "B" .And. QRY1->A3_TIPO = 'I' 
   		RunProc()	// RelatÛrio de pedidos em Saldo para os vendedores
   	Endif
   	RunProcf()	// RelatÛrio de pedidos faturados
   	RunProcaf()	// RelatÛrio de pedidos a faturar

   	cArq001 := "\RELATO\PED_SALD_"+cVend+".pdf""
   	cArq002 := "\RELATO\PED_BLOQ_"+cVend+".pdf""
   	cArq003 := "\RELATO\PED_FATU_"+cVend+".pdf""
   	cArq004 := "\RELATO\PED_AFAT_"+cVend+".pdf""

	If      File(cArq001)
	   	ENV_MAIL(cMailVend,cVend,cArq001,cArq002,cArq003,cArq004)   	
	ElseIf File(cArq002)  	
	   	ENV_MAIL(cMailVend,cVend,cArq001,cArq002,cArq003,cArq004)
	ElseIf File(cArq003)
	   	ENV_MAIL(cMailVend,cVend,cArq001,cArq002,cArq003,cArq004)
	ElseIf File(cArq004)
	   	ENV_MAIL(cMailVend,cVend,cArq001,cArq002,cArq003,cArq004)
	EndIf
   	
   	QRY1->(DbSkip())
EndDo
	
QRY1->(dbCloseArea())

/*
cTipoRel := "AB"
RunProc() // Envia e-mail com todos pedidos bloqueados
*/

ConOut('Fim relatorio dos pedidos com saldo, bloqueados, faturados e a faturar DIPR065 '+dToc(date())+' as '+Time())

RestArea(_xArea)

Return

/*=============================================\
|PROCESSAMENTO DOS DADOS E ENVIO DO E-MAIL     | 
|PEDIDOS COM SALDO E BLOQUEADOS                | 
\=============================================*/
Static Function RunProc()

Local nPar_Med := 0
Local cEmail   := ""
Local cAssunto := ""
Local cNomeVend:= ""
Local aEnv_065 := {} 
Local cExpira  := ""
Local nEstoque := 0


If cTipoRel = "S"                                    
	//************** QUERY PARA BUSCAR PEDIDOS DE VENDA EM SALDO***************** MCVN - 20/10/2008
	QRY2 := ""
	QRY2 := "SELECT C9_PEDIDO, C9_OPERADO, C9_VEND, A3_NOME, C9_DATALIB, C9_CLIENTE, A1_NOME, C9_PRODUTO,C9_LOCAL, B1_DESC, C9_SALDO,C9_QTDORI,C9_QTDVEN, C5_DTPEDID, U7_NOME, U7_POSTO, C9_QTDLIB, C5_XDATEXP, C5_XHOREXP "
	QRY2 += " FROM " + RetSQLName("SC9")+', '+RetSQLName("SA1")+', '+ RetSQLName("SA3")+', '+ RetSQLName("SB1")+', '+ RetSQLName("SC5")+', '+ RetSQLName("SU7")
	QRY2 += " WHERE " + RetSQLName("SC9") + ".D_E_L_E_T_ = ''"
	QRY2 += " AND " + RetSQLName("SA1") + ".D_E_L_E_T_ = ''"
	QRY2 += " AND " + RetSQLName("SA3") + ".D_E_L_E_T_ = ''"
	QRY2 += " AND " + RetSQLName("SB1") + ".D_E_L_E_T_ = ''" 
	QRY2 += " AND " + RetSQLName("SC5") + ".D_E_L_E_T_ = ''"
	QRY2 += " AND " + RetSQLName("SU7") + ".D_E_L_E_T_ = ''"	
	QRY2 += " AND C9_FILIAL = '" + xFilial('SC9') + "'"
	QRY2 += " AND C5_FILIAL = '" + xFilial('SC5') + "'"   
	QRY2 += " AND B1_FILIAL = '" + xFilial('SB1') + "'"
	QRY2 += " AND C9_SALDO   > 0"
	QRY2 += " AND C9_NFISCAL = ''"
	QRY2 += " AND C9_CLIENTE = A1_COD"
	QRY2 += " AND C9_LOJA    = A1_LOJA"
	QRY2 += " AND C9_VEND    = A3_COD"
	QRY2 += " AND C9_PRODUTO = B1_COD"
	QRY2 += " AND C9_VEND    = '" +cVend+"'"
	QRY2 += " AND C9_PEDIDO  = C5_NUM"          
	QRY2 += " AND C9_OPERADO = U7_COD"          
	QRY2 += " ORDER BY U7_POSTO, C9_PEDIDO, C5_DTPEDID"
	
	cQuery := ChangeQuery(QRY2)
	dbUseArea(.T., "TOPCONN", TCGenQry(,,QRY2), 'QRY2', .F., .T.)   

	TCSETFIELD("QRY2","C5_XDATEXP","D",8,0)
	
	memowrite('DIPR65.SQL',QRY2)


		//************** QUERY PARA BUSCAR PEDIDOS DE COMPRA(QUANTIDADE E PRAZO DE ENTREGA)***************** MCVN - 20/10/2008
	QRY3 :=        "SELECT C7_NUM, C7_PRODUTO, C7_DENTREG, (C7_QUANT - C7_QUJE) QUANT"
	QRY3 := QRY3 + " FROM " + RetSQLName("SC7")
	QRY3 := QRY3 + " WHERE "
	QRY3 := QRY3 + RetSQLName('SC7')+".C7_FILIAL = '"+xFilial('SC7')+"' and "
	QRY3 := QRY3 + RetSQLName('SC7')+".D_E_L_E_T_ = '' and " 
	//QRY3 := QRY3 + RetSQLName('SC7')+".C7_PRODUTO between '"+mv_par09+"' and '"+mv_par10+"' and "
	QRY3 := QRY3 + RetSQLName('SC7')+".C7_ENCER = '' and "  
	QRY3 := QRY3 + RetSQLName('SC7')+".C7_RESIDUO = '' "  
	QRY3 := QRY3 + "order by C7_PRODUTO, C7_NUM, C7_DENTREG"

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
	TcQuery QRY3 NEW ALIAS "QRY3"         // Abre uma workarea com o resultado da query

	memowrite('DIPR065B.SQL',QRY3)  

ElseIf cTipoRel = "B" .Or. cTipoRel = "AB"
	//************** QUERY PARA BUSCAR PEDIDOS DE VENDA BLOQUEADOS)***************** MCVN - 23/10/2008
	QRY2 := ""
	QRY2 := "SELECT C9_PEDIDO, C9_OPERADO, C9_VEND, A3_NOME, C9_DATALIB, C9_CLIENTE, A1_NOME, C9_PRODUTO, C9_LOCAL, B1_DESC, C9_SALDO,C9_QTDORI,C9_QTDVEN, C5_DTPEDID, U7_NOME, U7_POSTO, C9_QTDLIB, C5_XDATEXP, C5_XHOREXP "
	QRY2 += " FROM " + RetSQLName("SC9")+', '+RetSQLName("SA1")+', '+ RetSQLName("SA3")+', '+ RetSQLName("SB1")+', '+ RetSQLName("SC5")+', '+ RetSQLName("SU7")
	QRY2 += " WHERE " + RetSQLName("SC9") + ".D_E_L_E_T_ = ''"
	QRY2 += " AND " + RetSQLName("SA1") + ".D_E_L_E_T_ = ''"
	QRY2 += " AND " + RetSQLName("SA3") + ".D_E_L_E_T_ = ''"
	QRY2 += " AND " + RetSQLName("SB1") + ".D_E_L_E_T_ = ''" 
	QRY2 += " AND " + RetSQLName("SC5") + ".D_E_L_E_T_ = ''"
	QRY2 += " AND " + RetSQLName("SU7") + ".D_E_L_E_T_ = ''"	
	QRY2 += " AND C9_FILIAL = '" + xFilial('SC9') + "'"
	QRY2 += " AND C5_FILIAL = '" + xFilial('SC5') + "'"  
	QRY2 += " AND B1_FILIAL = '" + xFilial('SB1') + "'"	
	QRY2 += " AND C9_PARCIAL   = 'N'"
	QRY2 += " AND C9_NFISCAL = ''"
	QRY2 += " AND C9_CLIENTE = A1_COD"
	QRY2 += " AND C9_LOJA    = A1_LOJA"
	QRY2 += " AND C9_VEND    = A3_COD"
	QRY2 += " AND C9_PRODUTO = B1_COD"
	If cTipoRel == "B"
		QRY2 += " AND C9_VEND    = '" +cVend+"'"
	Endif
	QRY2 += " AND C9_PEDIDO  = C5_NUM"          
	QRY2 += " AND C9_OPERADO = U7_COD"          
	If cTipoRel == "B"	
		QRY2 += " ORDER BY C9_VEND, C9_PEDIDO, C5_DTPEDID"
	Else                                                  
		QRY2 += " ORDER BY U7_POSTO, C9_CLIENTE, C9_PEDIDO, C5_DTPEDID"
	Endif
	
	cQuery := ChangeQuery(QRY2)
	dbUseArea(.T., "TOPCONN", TCGenQry(,,QRY2), 'QRY2', .F., .T.)	
	TCSETFIELD("QRY2","C5_XDATEXP","D",8,0)
	
	memowrite('DIPR65C.SQL',QRY2)
Endif

//-----------------------------------------------------------

DbSelectArea("QRY2")
DbGoTop()
While QRY2->(!EOF())

    cNomeVend := QRY2->A3_NOME   
    cExpira   := DtoC(QRY2->C5_XDATEXP)+" ‡s ("+AllTrim(QRY2->C5_XHOREXP)+") "
    nEstoque  := U_DIPSALDSB2(QRY2->C9_PRODUTO,.T.,'')
                 
                                                                                                                                                                                                                                                                                                                                          
    //                      1                 2               3            4                 5                 6               7              8                                               9                                                           10             11                12             13      14      15          16             17
	Aadd(aEnv_065 ,{QRY2->C9_PEDIDO,QRY2->C9_CLIENTE ,QRY2->A1_NOME,QRY2->C9_PRODUTO, QRY2->B1_DESC, QRY2->C9_SALDO, QRY2->C9_OPERADO, QRY2->U7_NOME, SubStr(QRY2->C5_DTPEDID,7,2)+'/'+SubStr(QRY2->C5_DTPEDID,5,2)+'/'+SubStr(QRY2->C5_DTPEDID,1,4),QRY2->U7_POSTO,QRY2->C9_QTDLIB,QRY2->C9_VEND,QRY2->A3_NOME,cExpira,nEstoque,QRY2->C9_QTDORI,QRY2->C9_QTDVEN})

	// Verificando Departamentos pelos operadores 23/10/2008 - MCVN
	If QRY2->U7_POSTO = "01"
		If !("01/" $ cDepart)
			cDepart += "01/"
		Endif		
	ElseIf QRY2->U7_POSTO = "03"	      
		If !("03/" $ cDepart)
			cDepart += "03/"
		Endif			
	Else       
		cDepart := "02"                            
	Endif	
	
QRY2->(DbSkip())
EndDo
QRY2->(dbCloseArea())


If Len(aEnv_065) > 0          
	If cTipoRel = "S"	
		cAssunto := "Pedidos em Saldo - Vend.: "+cVend+" - "+cNomeVend
	ElseIf cTipoRel = "B"	                                                             
		cAssunto := "Pedidos Bloqueados - Vend.: "+cVend+" - "+cNomeVend
	Else                                                                
		cAssunto := "Pedidos Bloqueados - Vendedores"
	Endif
   	ENV_065(cMailVend,cAssunto,aEnv_065)
Endif
If cTipoRel = "S"	
	QRY3->(dbCloseArea())
Endif


Return(.T.)      

/*==========================================================================\
|Programa  | ENV_065 | Autor | Maximo Canuto V. Neto   | Data ≥ 16/10/2008  |
|===========================================================================|
|Desc.     | Envio de EMail de pedidos em saldo de cliente por vendedor     |
|===========================================================================|
|Sintaxe   | ENV_065                                                        |
|===========================================================================|
|Uso       | Especifico DIPROMED                                            |
\==========================================================================*/

Static Function ENV_065(cEmail,cAssunto,aEnv_065)

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
Local cPedido   := ""  
Local cPed      := ""
Local cPosto    := ""
Local nx               
Local lSmtpAuth := GetNewPar("MV_RELAUTH",.F.)
Local lAutOk	:= .F.
Local nLin      := 0
Local nCol      := 70
Local cAnexos   := ""
Local cPrefixo  := ""
Local _nPag     := 1
Local _dData    := ((dDatabase)-1) 

If     cTipoRel == "S"
	cPrefixo:="PED_SALD_"+cVend
ElseIf cTipoRel == "B"	
	cPrefixo:="PED_BLOQ_"+cVend
Else
	cPrefixo:="PED_BLOQV_"+cVend	
EndIf

oPrint := FWMSPrinter():New(cPrefixo,6,.T.,,.T.)
oPrint :SetLandscape () 
//MakeDir("C:\Relatorios\")
oPrint :cPathPDF:="\RELATO\"  


oPrint:Startpage()
R99Cab(@nLin,aEnv_065[1,12],aEnv_065[1,13],@_nPag)
	
For nx := 1 to Len(aEnv_065)

If nLin > 2200
	oPrint:EndPage()
	oPrint:Startpage()
	R99Cab(@nLin,aEnv_065[1,12],aEnv_065[1,13],@_nPag)
EndIf

		
	nCol := 70
	
		If cTipoRel = "S"
			VerPedCom(SUBSTR(aEnv_065[nx,4],1,6)) // Executa a funÁ„o que mostra a informaÁ„o dos pedidos de compra
		Endif	
		
		If cTipoRel = "S"
		 	If	("01/" $ cDepart .Or. "03/" $ cDepart )// .And.  cPosto <> aEnv_065[nx,10]
		
		    	If aEnv_065[nx,10] = '01'
					oPrint:Say(350,1350,"APOIO",oFont17,,CLR_GREEN)
				Else
					oPrint:Say(350,1350,"LICITA«√O",oFont17,,CLR_GREEN)
				Endif		
	
				cPosto := aEnv_065[nx,10]
	
		    ElseIf "02" $ cDepart  //.And.  cPosto <> aEnv_065[nx,10]
					
				oPrint:Say(350,1350,"TELEVENDAS",oFont17,,CLR_GREEN)
					
				cPosto := aEnv_065[nx,10]
				
		    Endif       
	
	    Else
	
			If aEnv_065[nx,10] = '01'
				oPrint:Say(350,1300,"APOIO",oFont17,,CLR_GREEN)
			ElseIf aEnv_065[nx,10] = '03'
				oPrint:Say(350,1350,"LICITA«√O",oFont17,,CLR_GREEN)
			ElseIf aEnv_065[nx,10] = '02'
				If cTipoRel <> "AB"
					oPrint:Say(350,1350,"TELEVENDAS",oFont17,,CLR_GREEN)
				Else
					oPrint:Say(350,1420,"TELEVENDAS",oFont17,,CLR_GREEN)				
				EndIf				
			Endif		
				
			cPosto := aEnv_065[nx,10]
	    Endif
	
	If Empty(Alltrim(cPedido))
	
			oPrint:Say(nlin ,nCol,aEnv_065[nx,1],oFont20n,100,CLR_RED)
			oPrint:Say(nlin ,nCol+=200,aEnv_065[nx,2],oFont15n,100,CLR_BLUE)
			oPrint:Say(nlin ,nCol+=200,aEnv_065[nx,3],oFont15n,100,CLR_BLUE)
			oPrint:Say(nlin ,nCol+=1150,aEnv_065[nx,9],oFont15,100,CLR_BLUE)
			oPrint:Say(nlin ,nCol+=350,aEnv_065[nx,14],oFont15,100,CLR_RED)
			oPrint:Say(nlin ,nCol+=500,SUBSTR(aEnv_065[nx,7]+' - '+aEnv_065[nx,8],1,37),oFont15,100,CLR_BLUE)
			
			If cTipoRel <> "S"	
				nLin   += 50
			
				oPrint:Say(nlin ,nCol-2400,"ExplicaÁ„o: "+Alltrim(Posicione("SC5",1,xFilial("SC5")+aEnv_065[nx,1],"C5_EXPLBLO")),oFont15,100,CLR_BLUE)
				oPrint:Say(nlin ,nCol,SUBSTR(aEnv_065[nx,12]+' - '+aEnv_065[nx,13],1,37),oFont15,100,CLR_BLUE)
			
			Endif
			
			If cTipoRel <> "S"
				If cPed <> aEnv_065[nx,1]	
					nLin += 40
					oPrint:Line(nLin,0050,nLin,3000,CLR_HRED)
					nLin += 20
				EndIf
			EndIf
					  		
			cPed    := aEnv_065[nx,1]
		    cPedido := aEnv_065[nx,1]                                  
			cPosto  := aEnv_065[nx,10]
			
			nLin   += 50
			nCol   := 70

	ElseIf cPedido <> aEnv_065[nx,1]  
                	   
		oPrint:Say(nlin ,nCol,aEnv_065[nx,1],oFont20n,100,CLR_RED)
		oPrint:Say(nlin ,nCol+=200,aEnv_065[nx,2],oFont15n,100,CLR_BLUE)
		oPrint:Say(nlin ,nCol+=200,aEnv_065[nx,3],oFont15n,100,CLR_BLUE)
		oPrint:Say(nlin ,nCol+=1150,aEnv_065[nx,9],oFont15,100,CLR_BLUE)
		oPrint:Say(nlin ,nCol+=350,aEnv_065[nx,14],oFont15,100,CLR_RED)
		oPrint:Say(nlin ,nCol+=500,SUBSTR(aEnv_065[nx,7]+' - '+aEnv_065[nx,8],1,37),oFont15,100,CLR_BLUE)

		If cTipoRel <> "S"	
			nLin   += 50
			
			oPrint:Say(nlin ,nCol-2400,"ExplicaÁ„o: "+Alltrim(Posicione("SC5",1,xFilial("SC5")+aEnv_065[nx,1],"C5_EXPLBLO")),oFont15,100,CLR_BLUE)
			oPrint:Say(nlin ,nCol,SUBSTR(aEnv_065[nx,12]+' - '+aEnv_065[nx,13],1,37),oFont15,100,CLR_BLUE)
			
		Endif
		
		If cTipoRel <> "S"
			If cPed <> aEnv_065[nx,1]	
				nLin += 40
				oPrint:Line(nLin,0050,nLin,3000,CLR_HRED)
				nLin += 20
			EndIf
		EndIf
        
        cPed    := aEnv_065[nx,1] 				  		
        cPedido := aEnv_065[nx,1]
        cPosto  := aEnv_065[nx,10]        
        
        nLin   += 50
        nCol   := 70
	EndIf  	              

	nLinAx := 40
	If cTipoRel = "S"

		oPrint:Say(nLin-10,nCol+50,aEnv_065[nx,4],oFont14)
		oPrint:Say(nLin-10,(nCol+=300)-100,aEnv_065[nx,5],oFont14)
		oPrint:SayAlign(nLin-nLinAx,nCol+=1320,Transform(aEnv_065[nx,6],"@E 999,999"),oFont14,155,nLin-nLinAx,,1,0)
		oPrint:SayAlign(nLin-nLinAx,nCol+=530,Transform(aEnv_065[nx,15],"@E 999,999"),oFont14,155,nLin-nLinAx,,1,0)
   		    
		If Len(aPedCom)>=1
			oPrint:Say(nLin-10,nCol+=250,fAglutina(),oFont14)
		Else                                                 
			oPrint:Say(nLin-10,nCol+=500,' / / ',oFont14)                                                                                                                           
		Endif
	
		If cPed = aEnv_065[nx,1]	
			nLin += 15
			oPrint:Line(nLin,0050,nLin,3000,CLR_HRED)
			nLin += 45
		Else	
			nLin += 60
		EndIf
	EndIf	

	/*
	Else
		
		oPrint:SayAlign(nLin-nLinAx,nCol+=1450,Transform(aEnv_065[nx,17],"@E 999,999"),oFont14,155,nLin-nLinAx,,1,0)// Qtd Vend
		oPrint:SayAlign(nLin-nLinAx,nCol+=300,Transform(aEnv_065[nx,16],"@E 999,999"),oFont14,155,nLin-nLinAx,,1,0)// Qtd Lib
		oPrint:SayAlign(nLin-nLinAx,nCol+=300,Transform(aEnv_065[nx,6] ,"@E 999,999"),oFont14,155,nLin-nLinAx,,1,0)// Saldo
		oPrint:SayAlign(nLin-nLinAx,nCol+=370,Transform(aEnv_065[nx,15],"@E 999,999"),oFont14,155,nLin-nLinAx,,1,0)// Estoque
		
		
		If cPed = aEnv_065[nx,1]	
			nLin += 15
			oPrint:Line(nLin,0050,nLin,3000,CLR_HRED)
			nLin += 45
		Else	
			nLin += 60
		EndIf
			
	EndIf
	*/		

aPedCom := {}
Next

oPrint:EndPage()
oPrint:SetViewPDF(.F.)
oPrint:Print()

/*
_cArquivo:="C:\Relatorios\"+cPrefixo+".pdf""
CpyT2S( "C:\Relatorios\"+cPrefixo+".pdf", "\RELATO\PDFVEN" )
fErase(_cArquivo)
*/

Return(.T.)        

//MCVN - 20/10/07
//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥Verifica se existe pedido de compra e grava data e quantidade em um array≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ

Static Function VerPedCom(_cProduto)

aPedCom := {}

// Gravando informaÁıes no array

DbSelectArea("QRY3")
QRY3->(dbGotop())

Do While QRY3->(!Eof())
	
	If _cProduto == Alltrim(QRY3->C7_PRODUTO)
		
		Aadd(aPedCom,{QRY3->C7_DENTREG, QRY3->QUANT})
		
	Endif
	
	QRY3->(DbSkip())
	
EndDo

aPedCom := aSort(aPedCom,,,{|x,y| x[1] < y[1] })
Return
/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥fAglutina()∫Autor ≥Jailton B Santos-JBS∫ Data ≥ 06/01/2010  ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥Aglutina datas e quantidades de produtos em pedidos de com- ∫±±
±±∫          ≥pra para a reposicao.                                       ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ FAT - Scheduler                                            ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Static Function fAglutina()

Local cAglutina := ''
Local cPicture  := '@e 999,999,999,999'
Local nId       := 0
Local cVirgula  := ''

For nId := 1 to len(aPedCom)
	
	cValor := AllTrim(Transform(aPedCom[nId][2],'@e 999,999,999,999'))
	cDia   := SubStr(aPedCom[nId][1],7,2) + '/' + SubStr(aPedCom[nId][1],5,2)
	
	If len( cAglutina + cVirgula + cDia  + ' ' + cValor) <= 60
		cAglutina += (cVirgula + cDia  + ' ' + cValor)
		If len(AllTrim(cAglutina)) > 0
		    cVirgula  := ' - '
		EndIf    
	EndIf

Next nId

Return(cAglutina)


/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥DIPR099   ∫Autor  ≥Microsiga           ∫ Data ≥  16/01/18   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥                                                            ∫±±
±±∫          ≥                                                            ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ AP                                                        ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/

Static Function R99Cab(nLinha,nVend,cNomVend,_nPag)

Local nLin     := 0100
Local nCol     := 0070
Local nColAux  := 0
Local _cEmpresa:=""

	//Box Geral
	oPrint:Box(nLin,0050,2400,3000)
	
	If "01" $ cWCodEmp
		If "01" $ cWCodFil
			_cEmpresa:="DIPROMED"+"-"+"MATRIZ"
		Else
		   cEmpresa:="DIPROMED"+"-"+"CD"
		EndIf
	Else
		If "01" $ cWCodFil
			_cEmpresa:="HEALTH"+"-"+"MATRIZ"
		Else
		   _cEmpresa:="HEALTH"+"-"+"CD"
		EndIf	
	EndIf
	
	
	nLin +=60	
	oPrint:Say(nLin,1300,_cEmpresa,oFont20n,,CLR_RED)
	oPrint:Say(nLin,2880,"Pag: "+StrZero(_nPag,2),oFont15n,100)

	nLin +=50
	oPrint:Line(nLin-10,0050,nLin-10,3000)

	nLin +=50
	
	If cTipoRel = 'S'
		oPrint:Say(nLin,1000,"PEDIDOS EM SALDO - VENDEDOR(A): "+nVend+" - "+cNomVend,oFont17n)
	Else
		oPrint:Say(nLin,1000,"PEDIDOS BLOQUEADOS - VENDEDOR(A):"+nVend+" - "+cNomVend,oFont17n)	
	EndIf
	
	nLin +=40
	oPrint:Line(nLin,0050,nLin,3000)
	
	nLin +=100
	nColAux := nCol
	oPrint:Say(nLin,nCol,"Pedido",oFont17n,,CLR_BLUE)
	oPrint:Say(nLin,nColAux+=200,"Cliente",oFont17n,,CLR_BLUE)
	oPrint:Say(nLin,nColAux+=200,"Nome Cliente",oFont17n,,CLR_BLUE)
	oPrint:Say(nLin,nColAux+=1150,"Emiss„o",oFont17n,,CLR_BLUE)
	oPrint:Say(nLin,nColAux+=350,"ExpiraÁ„o",oFont17n,,CLR_RED)
	If cTipoRel = 'S'
		oPrint:Say(nLin,nColAux+=500,"Operador",oFont17n,,CLR_BLUE)
	Else
		oPrint:Say(nLin,nColAux+=500,"Operador/Vendedor",oFont17n,,CLR_BLUE)	
	EndIf	
	
	nLin +=40
	oPrint:Line(nLin,0050,nLin,3000,CLR_BLUE)
		
	If cTipoRel = 'S'
		nLin +=50
		nColAux := nCol 
		oPrint:Say(nLin,nCol+50,"Produto",oFont17n)
		oPrint:Say(nLin,nColAux+=200,"DescriÁ„o",oFont17n)
		oPrint:Say(nLin,nColAux+=1500,"Saldo",oFont17n)
		oPrint:Say(nLin,nColAux+=400,"Est.DisponÌvel",oFont17n)	
		oPrint:Say(nLin,nColAux+=450,"Previs„o de Entrega",oFont17n)
	EndIf
	/*
	Else
		nColAux := nCol
		oPrint:Say(nLin,nCol+50,"Produto",oFont17n)
		oPrint:Say(nLin,nColAux+=200,"DescriÁ„o",oFont17n)
		oPrint:Say(nLin,nColAux+=1500,"Qtd. Vendida",oFont17n)
		oPrint:Say(nLin,nColAux+=300,"Qtd. Liberada",oFont17n)
		oPrint:Say(nLin,nColAux+=400,"Saldo",oFont17n)
		oPrint:Say(nLin,nColAux+=200,"Estq. DisponÌvel",oFont17n)
	EndIf	
	*/
	
	nLin +=40
	oPrint:Line(nLin,0050,nLin,3000)		
	
	nLin +=50
	nLinha := nLin
	_nPag++
	

Return 

/*=============================================\
|PROCESSAMENTO DOS DADOS E ENVIO DO E-MAIL     |
|PEDIDOS FATURADOS                             |
\=============================================*/
Static Function RunProcf()

Local nPar_Med := 0
Local cEmail   := ""
Local cAssunto := ""
Local cNomeVend:= ""
Local aEnv_065F:= {} 
Local cExpira  := ""
Local nEstoque := 0
Local _dData   := dTos((dDataBase)-1)
Private cDepart:= "" 


	//************** QUERY PARA BUSCAR PEDIDOS DE VENDA FATURADO***************** 
	QRY2 := "SELECT C9_PEDIDO, C9_PRODUTO, B1_DESC, C9_PRCVEN, C9_QTDVEN, C9_QTDORI, C9_QTDLIB, C9_SALDO, (C9_QTDLIB*C9_PRCVEN) TOT_PROD, "
	QRY2 += " C5_DTPEDID, C9_DATALIB, C9_NFISCAL, C9_OPERADO, C9_VEND, A3_NOME, C9_CLIENTE, A1_NOME, C9_LOCAL, U7_NOME, U7_POSTO "
	QRY2 += " FROM " + RetSQLName("SC9")+', '+RetSQLName("SA1")+', '+ RetSQLName("SA3")+', '+ RetSQLName("SB1")+', '+ RetSQLName("SC5")+', '+ RetSQLName("SU7")+', '+ RetSQLName("SF2")
	QRY2 += " WHERE " + RetSQLName("SC9") + ".D_E_L_E_T_ = ''"
	QRY2 += " AND " + RetSQLName("SA1") + ".D_E_L_E_T_ = ''"
	QRY2 += " AND " + RetSQLName("SA3") + ".D_E_L_E_T_ = ''"
	QRY2 += " AND " + RetSQLName("SB1") + ".D_E_L_E_T_ = ''" 
	QRY2 += " AND " + RetSQLName("SC5") + ".D_E_L_E_T_ = ''"
	QRY2 += " AND " + RetSQLName("SU7") + ".D_E_L_E_T_ = ''"
	QRY2 += " AND " + RetSQLName("SF2") + ".D_E_L_E_T_ = ''"	
	QRY2 += " AND C9_FILIAL = '" + xFilial('SC9') + "'"
	QRY2 += " AND C5_FILIAL = '" + xFilial('SC5') + "'"   
	QRY2 += " AND B1_FILIAL = '" + xFilial('SB1') + "'"
	QRY2 += " AND F2_FILIAL = '" + xFilial('SF2') + "'"
	//QRY2 += " AND C9_DATALIB = '"+_dData+"' "
	QRY2 += " AND C9_BLCRED  = '10' "
	QRY2 += " AND C9_BLEST   = '10' "
	QRY2 += " AND C9_NFISCAL <> '' "
	QRY2 += " AND C9_CLIENTE = A1_COD"
	QRY2 += " AND C9_LOJA    = A1_LOJA"
	QRY2 += " AND C9_VEND    = A3_COD"
	QRY2 += " AND C9_PRODUTO = B1_COD"
	QRY2 += " AND C9_VEND    = '" +cVend+"'"
	QRY2 += " AND C9_PEDIDO  = C5_NUM"          
	QRY2 += " AND C9_OPERADO = U7_COD"          
	QRY2 += " AND F2_CLIENTE = C9_CLIENTE "
    QRY2 += " AND F2_LOJA    = C9_LOJA "
	QRY2 += " AND F2_DOC     = C9_NFISCAL "
    QRY2 += " AND F2_SERIE   = C9_SERIENF "
    QRY2 += " AND F2_EMISSAO = '"+_dData+"' "
	QRY2 += " ORDER BY U7_POSTO, C9_PEDIDO, C5_DTPEDID"
	
	cQuery := ChangeQuery(QRY2)
	dbUseArea(.T., "TOPCONN", TCGenQry(,,QRY2), 'QRY2', .F., .T.)   

	TCSETFIELD("QRY2","C5_XDATEXP","D",8,0)
	
	memowrite('DIPR65FAT.SQL',QRY2)

//-----------------------------------------------------------
DbSelectArea("QRY2")
DbGoTop()
While QRY2->(!EOF())

    cNomeVend := QRY2->A3_NOME   
                                                                                                                                                                                                                                                                                                                                          
    //                      1                 2               3            4                 5                 6               7              8                                               9                                                           10             11                12             13      14                                                        15                                                         16             17             18              19
	Aadd(aEnv_065F ,{QRY2->C9_PEDIDO,QRY2->C9_CLIENTE ,QRY2->A1_NOME,QRY2->C9_PRODUTO, QRY2->B1_DESC, QRY2->C9_SALDO, QRY2->C9_OPERADO, QRY2->U7_NOME, SubStr(QRY2->C5_DTPEDID,7,2)+'/'+SubStr(QRY2->C5_DTPEDID,5,2)+'/'+SubStr(QRY2->C5_DTPEDID,1,4),QRY2->U7_POSTO,QRY2->C9_QTDLIB,QRY2->C9_VEND,QRY2->A3_NOME,QRY2->TOT_PROD,SubStr(QRY2->C9_DATALIB,7,2)+'/'+SubStr(QRY2->C9_DATALIB,5,2)+'/'+SubStr(QRY2->C9_DATALIB,1,4),QRY2->C9_QTDORI,QRY2->C9_QTDVEN,QRY2->C9_PRCVEN,QRY2->C9_NFISCAL})

	// Verificando Departamentos pelos operadores
	If QRY2->U7_POSTO = "01"
		If !("01/" $ cDepart)
			cDepart += "01/"
		Endif		
	ElseIf QRY2->U7_POSTO = "03"	      
		If !("03/" $ cDepart)
			cDepart += "03/"
		Endif			
	Else       
		cDepart := "02"                            
	Endif	
	
QRY2->(DbSkip())
EndDo
QRY2->(dbCloseArea())

If Len(aEnv_065F) > 0          

	cAssunto := "Pedidos Faturados - Vend.: "+cVend+" - "+cNomeVend

   	ENV_065F(cMailVend,cAssunto,aEnv_065F)
Endif


Return(.T.)      

/*==========================================================================\
|Programa  | ENV_065F | Autor | Reginaldo Borges   | Data ≥ 29/01/2018     |
|===========================================================================|
|Desc.     | Envio de EMail de pedidos faturados de cliente por vendedor     |
|===========================================================================|
|Sintaxe   | ENV_065F                                                        |
|===========================================================================|
|Uso       | Especifico DIPROMED                                            |
\==========================================================================*/

Static Function ENV_065F(cEmail,cAssunto,aEnv_065F)

Local nTot_Prod := 0
Local cPedido   := ""  
Local cPed      := ""
Local cPosto    := ""
Local nx               
LOCAL lAutOk	:= .F.
Local nLin      := 0
Local nCol      := 70
Local nTotNF    := 0
Local nTotGer   := 0
Local _dData    := ((dDatabase)-1)
Local cPrefixo  := "PED_FATU_"+cVend
Local _nPag     := 1

oPrint := FWMSPrinter():New(cPrefixo,6,.T.,,.T.)
oPrint :SetLandscape () 
//MakeDir("C:\Relatorios\")
oPrint :cPathPDF:="\RELATO\"  

oPrint:Startpage()
R99Cabf(@nLin,aEnv_065F[1,12],aEnv_065F[1,13],@_nPag)
	
For nx := 1 to Len(aEnv_065F)

If nLin > 2200
	oPrint:EndPage()
	oPrint:Startpage()
	R99Cabf(@nLin,aEnv_065F[1,12],aEnv_065F[1,13],@_nPag)
EndIf


nCol := 70

		
		If	("01/" $ cDepart .Or. "03/" $ cDepart )// .And.  cPosto <> aEnv_065F[nx,10]

			If aEnv_065F[nx,10] = '01'
				oPrint:Say(350,1350,"APOIO",oFont17,,CLR_GREEN)
			Else
				oPrint:Say(350,1350,"LICITA«√O",oFont17,,CLR_GREEN)
			Endif		

			cPosto := aEnv_065F[nx,10]

		ElseIf "02" $ cDepart

			oPrint:Say(350,1350,"TELEVENDAS",oFont17,,CLR_GREEN)

			cPosto := aEnv_065F[nx,10]

		Endif       


	If Empty(Alltrim(cPedido))

			oPrint:Say(nlin ,nCol,aEnv_065F[nx,1],oFont20n,100,CLR_RED)
			oPrint:Say(nlin ,nCol+=200,aEnv_065F[nx,2],oFont15n,100,CLR_BLUE)
			oPrint:Say(nlin ,nCol+=200,aEnv_065F[nx,3],oFont15n,100,CLR_BLUE)
			oPrint:Say(nlin ,nCol+=1200,aEnv_065F[nx,9],oFont15,100,CLR_BLUE)
			oPrint:Say(nlin ,nCol+=300,aEnv_065F[nx,15],oFont15,100,CLR_RED) 
			oPrint:Say(nlin ,nCol+=350,SUBSTR(aEnv_065F[nx,7]+' - '+aEnv_065F[nx,8],1,37),oFont15,100,CLR_BLUE)

		

		cPed    := aEnv_065F[nx,1]
		cPedido := aEnv_065F[nx,1]                                  
		cPosto  := aEnv_065F[nx,10]

		nLin   += 50
		nCol   := 70

	ElseIf cPedido <> aEnv_065F[nx,1]  
		
		nLinAx := 90
		oPrint:SayAlign(nLin-nLinAx,nCol+2720,Transform(nTotNF,"@E 999,999,999.99"),oFont15n,155,nLin-nLinAx,,1,0)
		nTotNF := 0
		
		nLin += 10
		oPrint:Line(nLin,0050,nLin,3000,CLR_HRED)
		nLin += 50

		oPrint:Say(nlin ,nCol,aEnv_065F[nx,1],oFont20n,100,CLR_RED)
		oPrint:Say(nlin ,nCol+=200,aEnv_065F[nx,2],oFont15n,100,CLR_BLUE)
		oPrint:Say(nlin ,nCol+=200,aEnv_065F[nx,3],oFont15n,100,CLR_BLUE)
		oPrint:Say(nlin ,nCol+=1200,aEnv_065F[nx,9],oFont15,100,CLR_BLUE)
		oPrint:Say(nlin ,nCol+=300,aEnv_065F[nx,15],oFont15,100,CLR_RED)
		oPrint:Say(nlin ,nCol+=350,SUBSTR(aEnv_065F[nx,7]+' - '+aEnv_065F[nx,8],1,37),oFont15,100,CLR_BLUE)

		cPed    := aEnv_065F[nx,1] 				  		
		cPedido := aEnv_065F[nx,1]
		cPosto  := aEnv_065F[nx,10]        

		nLin   += 50
		nCol   := 70
	EndIf  	              

	/*
	oPrint:Say(nLin,nCol+50,aEnv_065F[nx,4],oFont14)
	oPrint:Say(nLin,(nCol+=300)-100,aEnv_065F[nx,5],oFont14)
	
	
	nLinAx := 30
	oPrint:SayAlign(nLin-nLinAx,nCol+=900,Transform(aEnv_065F[nx,17],"@E 999,999"),oFont14,155,nLin-nLinAx,,1,0)
	oPrint:SayAlign(nLin-nLinAx,nCol+=300,Transform(aEnv_065F[nx,11],"@E 999,999"),oFont14,155,nLin-nLinAx,,1,0)
	oPrint:SayAlign(nLin-nLinAx,nCol+=280,Transform(aEnv_065F[nx,6] ,"@E 999,999"),oFont14,155,nLin-nLinAx,,1,0)
	oPrint:SayAlign(nLin-nLinAx,nCol+=350,Transform(aEnv_065F[nx,18],"@E 999,999.99"),oFont14,155,nLin-nLinAx,,1,0)
	oPrint:SayAlign(nLin-nLinAx,nCol+=280,Transform(aEnv_065F[nx,14],"@E 999,999,999.99"),oFont14,155,nLin-nLinAx,,1,0)
	oPrint:SayAlign(nLin-nLinAx,nCol+=320,aEnv_065F[nx,19],oFont14,155,nLin-nLinAx,,1,0)
	
	
	If cPed = aEnv_065F[nx,1]
		nLin += 30
		oPrint:Line(nLin,0050,nLin,3000,CLR_HRED)
		nLin += 30
	Else	
		nLin += 60
	EndIf
	*/	
	
	nTotNF += aEnv_065F[nx,14]
	nTotGer+= aEnv_065F[nx,14]

Next

nLinAx := 90
oPrint:SayAlign(nLin-nLinAx,nCol+2720,Transform(nTotNF,"@E 999,999,999.99"),oFont15n,155,nLin-nLinAx,,1,0)
nTotNF := 0

nLin += 15
oPrint:Line(nLin,0050,nLin,3000,CLR_HRED)
nLin += 45

nLinAx := 90
oPrint:SayAlign(nLin-nLinAx,nCol+2720,Transform(nTotGer,"@E 999,999,999.99"),oFont15n,155,nLin-nLinAx,,1,0)
nTotNF := 0

nLin += 15
oPrint:Line(nLin,0050,nLin,3000,CLR_HRED)
nLin += 45


oPrint:EndPage()
oPrint:SetViewPDF(.F.)
oPrint:Print()

/*
_cArquivo:="C:\Relatorios\"+cPrefixo+".pdf""
CpyT2S( "C:\Relatorios\"+cPrefixo+".pdf", "\RELATO\PDFVEN" )
fErase(_cArquivo)
*/

Return(.T.)        


//CabeÁalho dos pedidos faturados

Static Function R99CabF(nLinha,nVend,cNomVend,_nPag)

Local nLin     := 0100
Local nCol     := 0070
Local nColAux  := 0
Local _cEmpresa:=""

	//Box Geral
	oPrint:Box(nLin,0050,2400,3000)
	
	If "01" $ cWCodEmp
		If "01" $ cWCodFil
			_cEmpresa:="DIPROMED"+"-"+"MATRIZ"
		Else
		   cEmpresa:="DIPROMED"+"-"+"CD"
		EndIf
	Else
		If "01" $ cWCodFil
			_cEmpresa:="HEALTH"+"-"+"MATRIZ"
		Else
		   _cEmpresa:="HEALTH"+"-"+"CD"
		EndIf	
	EndIf
	
	
	nLin +=60	
	oPrint:Say(nLin,1300,_cEmpresa,oFont20n,,CLR_RED)
	oPrint:Say(nLin,2880,"Pag: "+StrZero(_nPag,2),oFont15n,100)

	nLin +=50
	oPrint:Line(nLin-10,0050,nLin-10,3000)

	nLin +=50
	
	oPrint:Say(nLin,1000,"PEDIDOS FATURADOS - VENDEDOR(A): "+nVend+" - "+cNomVend,oFont17n)
	
	nLin +=40
	oPrint:Line(nLin,0050,nLin,3000)
	
	nLin +=100
	nColAux := nCol
	oPrint:Say(nLin,nCol,"Pedido",oFont17n,,CLR_BLUE)
	oPrint:Say(nLin,nColAux+=200,"Cliente",oFont17n,,CLR_BLUE)
	oPrint:Say(nLin,nColAux+=200,"Nome Cliente",oFont17n,,CLR_BLUE)
	oPrint:Say(nLin,nColAux+=1200,"Emiss„o",oFont17n,,CLR_BLUE)
	oPrint:Say(nLin,nColAux+=300,"LiberaÁ„o",oFont17n,,CLR_RED)
	oPrint:Say(nLin,nColAux+=350,"Operador",oFont17n,,CLR_BLUE)
	oPrint:Say(nLin,nColAux+=450,"Valor Total",oFont17n,,CLR_BLUE)
	
	nLin +=40
	oPrint:Line(nLin,0050,nLin,3000,CLR_BLUE)
	
	/*
	nLin +=50
	
	nColAux := nCol
	oPrint:Say(nLin,nCol+50,"Produto",oFont17n)
	oPrint:Say(nLin,nColAux+=200,"DescriÁ„o",oFont17n)
	oPrint:Say(nLin,nColAux+=950,"Qtd. Vendida",oFont17n)
	oPrint:Say(nLin,nColAux+=300,"Qtd. Liberada",oFont17n)
	oPrint:Say(nLin,nColAux+=400,"Saldo",oFont17n)
	oPrint:Say(nLin,nColAux+=250,"Vlr. Unit·rio",oFont17n)
	oPrint:Say(nLin,nColAux+=300,"Total Prod.",oFont17n)
	oPrint:Say(nLin,nColAux+=300,"Nota Fiscal",oFont17n)
	
	
	nLin +=40
	oPrint:Line(nLin,0050,nLin,3000)		
	*/
	
	nLin +=50
	nLinha := nLin
	_nPag++

Return 

/*=============================================\
|PROCESSAMENTO DOS DADOS E ENVIO DO E-MAIL     |
|PEDIDOS A FATURAR                             |
\=============================================*/
Static Function RunProcAf()

Local nPar_Med := 0
Local cEmail   := ""
Local cAssunto := ""
Local cNomeVend:= ""
Local aEnv_065aF:= {} 
Local cExpira  := ""
Local nEstoque := 0
Local _dData   := dTos((dDataBase)-1)
Private cDepart:= "" 


	//************** QUERY PARA BUSCAR PEDIDOS DE VENDA A FATURAR***************** 
	QRY2 := "SELECT C9_PEDIDO, C9_PRODUTO, B1_DESC, C9_PRCVEN, C9_QTDVEN, C9_QTDORI, C9_QTDLIB, C9_SALDO, (C9_QTDLIB*C9_PRCVEN) TOT_PROD, "
	QRY2 += " C5_DTPEDID, C9_DATALIB, C9_NFISCAL, C9_OPERADO, C9_VEND, A3_NOME, C9_CLIENTE, A1_NOME, C9_LOCAL, U7_NOME, U7_POSTO "
	QRY2 += " FROM " + RetSQLName("SC9")+', '+RetSQLName("SA1")+', '+ RetSQLName("SA3")+', '+ RetSQLName("SB1")+', '+ RetSQLName("SC5")+', '+ RetSQLName("SU7")
	QRY2 += " WHERE " + RetSQLName("SC9") + ".D_E_L_E_T_ = ''"
	QRY2 += " AND " + RetSQLName("SA1") + ".D_E_L_E_T_ = ''"
	QRY2 += " AND " + RetSQLName("SA3") + ".D_E_L_E_T_ = ''"
	QRY2 += " AND " + RetSQLName("SB1") + ".D_E_L_E_T_ = ''" 
	QRY2 += " AND " + RetSQLName("SC5") + ".D_E_L_E_T_ = ''"
	QRY2 += " AND " + RetSQLName("SU7") + ".D_E_L_E_T_ = ''"	
	QRY2 += " AND C9_FILIAL = '" + xFilial('SC9') + "'"
	QRY2 += " AND C5_FILIAL = '" + xFilial('SC5') + "'"   
	QRY2 += " AND B1_FILIAL = '" + xFilial('SB1') + "'"
	QRY2 += " AND C9_DATALIB <= '"+_dData+"' "
	QRY2 += " AND C9_BLCRED  = ' ' "
	QRY2 += " AND (C9_BLEST  = ' ' OR C9_BLEST = '02')"
	QRY2 += " AND C9_NFISCAL = '' "
	QRY2 += " AND C9_CLIENTE = A1_COD"
	QRY2 += " AND C9_LOJA    = A1_LOJA"
	QRY2 += " AND C9_VEND    = A3_COD"
	QRY2 += " AND C9_PRODUTO = B1_COD"
	QRY2 += " AND C9_VEND    = '" +cVend+"'"
	QRY2 += " AND C9_PEDIDO  = C5_NUM"          
	QRY2 += " AND C9_OPERADO = U7_COD"      
	QRY2 += " AND C5_PRENOTA NOT IN ('F','O') "    
	QRY2 += " ORDER BY U7_POSTO, C9_PEDIDO, C5_DTPEDID"
	
	cQuery := ChangeQuery(QRY2)
	dbUseArea(.T., "TOPCONN", TCGenQry(,,QRY2), 'QRY2', .F., .T.)   

	TCSETFIELD("QRY2","C5_XDATEXP","D",8,0)
	
	memowrite('DIPR65AFAT.SQL',QRY2)

//-----------------------------------------------------------
DbSelectArea("QRY2")
DbGoTop()
While QRY2->(!EOF())

    cNomeVend := QRY2->A3_NOME   
                                                                                                                                                                                                                                                                                                                                          
    //                      1                 2               3            4                 5                 6               7              8                                               9                                                           10             11                12             13      14                                                        15                                                         16             17             18              19
	Aadd(aEnv_065aF ,{QRY2->C9_PEDIDO,QRY2->C9_CLIENTE ,QRY2->A1_NOME,QRY2->C9_PRODUTO, QRY2->B1_DESC, QRY2->C9_SALDO, QRY2->C9_OPERADO, QRY2->U7_NOME, SubStr(QRY2->C5_DTPEDID,7,2)+'/'+SubStr(QRY2->C5_DTPEDID,5,2)+'/'+SubStr(QRY2->C5_DTPEDID,1,4),QRY2->U7_POSTO,QRY2->C9_QTDLIB,QRY2->C9_VEND,QRY2->A3_NOME,QRY2->TOT_PROD,SubStr(QRY2->C9_DATALIB,7,2)+'/'+SubStr(QRY2->C9_DATALIB,5,2)+'/'+SubStr(QRY2->C9_DATALIB,1,4),QRY2->C9_QTDORI,QRY2->C9_QTDVEN,QRY2->C9_PRCVEN,QRY2->C9_NFISCAL})

	// Verificando Departamentos pelos operadores
	If QRY2->U7_POSTO = "01"
		If !("01/" $ cDepart)
			cDepart += "01/"
		Endif		
	ElseIf QRY2->U7_POSTO = "03"	      
		If !("03/" $ cDepart)
			cDepart += "03/"
		Endif			
	Else       
		cDepart := "02"                            
	Endif	
	
QRY2->(DbSkip())
EndDo
QRY2->(dbCloseArea())

If Len(aEnv_065aF) > 0          

	cAssunto := "Pedidos a Faturar - Vend.: "+cVend+" - "+cNomeVend

   	ENV_065aF(cMailVend,cAssunto,aEnv_065aF)
Endif


Return(.T.)      

/*==========================================================================\
|Programa  | ENV_065aF| Autor | Reginaldo Borges   | Data ≥ 29/01/2018     |
|==========================================================================|
|Desc.     | Envio de EMail de pedidos a faturar de cliente por vendedor   |
|==========================================================================|
|Sintaxe   | ENV_065aF                                                     |
|==========================================================================|
|Uso       | Especifico DIPROMED                                           |
\==========================================================================*/

Static Function ENV_065aF(cEmail,cAssunto,aEnv_065aF)

Local nTot_Prod := 0
Local cPedido   := ""  
Local cPed      := ""
Local cPosto    := ""
Local nx               
Local nLin      := 0
Local nCol      := 70
Local cAnexos   := ""
Local nTotNF    := 0
Local nTotGer   := 0 
Local _dData    := ((dDatabase)-1)
Local cPrefixo  := "PED_AFAT_"+cVend
Local _nPag     := 1

oPrint := FWMSPrinter():New(cPrefixo,6,.T.,,.T.)
oPrint :SetLandscape () 
//MakeDir("C:\Relatorios\")
oPrint :cPathPDF:="\RELATO\"  


oPrint:Startpage()
R99CabAf(@nLin,aEnv_065aF[1,12],aEnv_065aF[1,13],@_nPag)
	
For nx := 1 to Len(aEnv_065aF)

If nLin > 2200
	oPrint:EndPage()
	oPrint:Startpage()
	R99CabAf(@nLin,aEnv_065aF[1,12],aEnv_065aF[1,13],@_nPag)
EndIf


nCol := 70

		If	("01/" $ cDepart .Or. "03/" $ cDepart )// .And.  cPosto <> aEnv_065aF[nx,10]

			If aEnv_065aF[nx,10] = '01'
				oPrint:Say(350,1350,"APOIO",oFont17,,CLR_GREEN)
			Else
				oPrint:Say(350,1350,"LICITA«√O",oFont17,,CLR_GREEN)
			Endif		

				cPosto := aEnv_065aF[nx,10]

		ElseIf "02" $ cDepart
			oPrint:Say(350,1350,"TELEVENDAS",oFont17,,CLR_GREEN)

			cPosto := aEnv_065aF[nx,10]

		Endif       


	If Empty(Alltrim(cPedido))

			oPrint:Say(nlin ,nCol,aEnv_065aF[nx,1],oFont20n,100,CLR_RED)
			oPrint:Say(nlin ,nCol+=200,aEnv_065aF[nx,2],oFont15n,100,CLR_BLUE)
			oPrint:Say(nlin ,nCol+=200,aEnv_065aF[nx,3],oFont15n,100,CLR_BLUE)
			oPrint:Say(nlin ,nCol+=1200,aEnv_065aF[nx,9],oFont15,100,CLR_BLUE)
			oPrint:Say(nlin ,nCol+=350,aEnv_065aF[nx,15],oFont15,100,CLR_RED) 
			oPrint:Say(nlin ,nCol+=450,SUBSTR(aEnv_065aF[nx,7]+' - '+aEnv_065aF[nx,8],1,37),oFont15,100,CLR_BLUE)

		cPed    := aEnv_065aF[nx,1]
		cPedido := aEnv_065aF[nx,1]                                  
		cPosto  := aEnv_065aF[nx,10]

		nLin   += 50
		nCol   := 70

	ElseIf cPedido <> aEnv_065aF[nx,1]  
		
		nLinAx := 90
		oPrint:SayAlign(nLin-nLinAx,nCol+2720,Transform(nTotNF,"@E 999,999,999.99"),oFont15n,155,nLin-nLinAx,,1,0)
		nTotNF := 0
		
		nLin += 10
		oPrint:Line(nLin,0050,nLin,3000,CLR_HRED)
		nLin += 50

		oPrint:Say(nlin ,nCol,aEnv_065aF[nx,1],oFont20n,100,CLR_RED)
		oPrint:Say(nlin ,nCol+=200,aEnv_065aF[nx,2],oFont15n,100,CLR_BLUE)
		oPrint:Say(nlin ,nCol+=200,aEnv_065aF[nx,3],oFont15n,100,CLR_BLUE)
		oPrint:Say(nlin ,nCol+=1200,aEnv_065aF[nx,9],oFont15,100,CLR_BLUE)
		oPrint:Say(nlin ,nCol+=350,aEnv_065aF[nx,15],oFont15,100,CLR_RED)
		oPrint:Say(nlin ,nCol+=450,SUBSTR(aEnv_065aF[nx,7]+' - '+aEnv_065aF[nx,8],1,37),oFont15,100,CLR_BLUE)

		cPed    := aEnv_065aF[nx,1] 				  		
		cPedido := aEnv_065aF[nx,1]
		cPosto  := aEnv_065aF[nx,10]        

		nLin   += 50
		nCol   := 70
	EndIf  	              

	/*
	oPrint:Say(nLin,nCol+50,aEnv_065aF[nx,4],oFont14)
	oPrint:Say(nLin,(nCol+=300)-100,aEnv_065aF[nx,5],oFont14)

	nLinAx := 30
	oPrint:SayAlign(nLin-nLinAx,nCol+=900,Transform(aEnv_065aF[nx,17],"@E 999,999"),oFont14,155,nLin-nLinAx,,1,0)
	oPrint:SayAlign(nLin-nLinAx,nCol+=300,Transform(aEnv_065aF[nx,11],"@E 999,999"),oFont14,155,nLin-nLinAx,,1,0)
	oPrint:SayAlign(nLin-nLinAx,nCol+=280,Transform(aEnv_065aF[nx,6] ,"@E 999,999"),oFont14,155,nLin-nLinAx,,1,0)
	oPrint:SayAlign(nLin-nLinAx,nCol+=350,Transform(aEnv_065aF[nx,18],"@E 999,999.99"),oFont14,155,nLin-nLinAx,,1,0)
	oPrint:SayAlign(nLin-nLinAx,nCol+=280,Transform(aEnv_065aF[nx,14],"@E 999,999,999.99"),oFont14,155,nLin-nLinAx,,1,0)
	//oPrint:SayAlign(nLin-nLinAx,nCol+=320,aEnv_065aF[nx,19],oFont14,155,nLin-nLinAx,,1,0)

	nTotNF += aEnv_065aF[nx,14]
	
	If cPed = aEnv_065aF[nx,1]
		nLin += 15
		oPrint:Line(nLin,0050,nLin,3000,CLR_HRED)
		nLin += 45
	Else	
		nLin += 60
	EndIf	
	*/
	
	nTotNF += aEnv_065aF[nx,14]	
	nTotGer+= aEnv_065aF[nx,14]
	
Next

nLinAx := 90
oPrint:SayAlign(nLin-nLinAx,nCol+2720,Transform(nTotNF,"@E 999,999,999.99"),oFont15n,155,nLin-nLinAx,,1,0)
nTotNF := 0

nLin += 15
oPrint:Line(nLin,0050,nLin,3000,CLR_HRED)
nLin += 45

nLinAx := 90
oPrint:SayAlign(nLin-nLinAx,nCol+2720,Transform(nTotGer,"@E 999,999,999.99"),oFont15n,155,nLin-nLinAx,,1,0)
nTotNF := 0

nLin += 15
oPrint:Line(nLin,0050,nLin,3000,CLR_HRED)
nLin += 45


oPrint:EndPage()
oPrint:SetViewPDF(.F.)
oPrint:Print()

/*
_cArquivo:="C:\Relatorios\"+cPrefixo+".pdf""
CpyT2S( "C:\Relatorios\"+cPrefixo+".pdf", "\RELATO\PDFVEN" )
fErase(_cArquivo)
*/

Return(.T.)        


//CabeÁalho dos pedidos faturados

Static Function R99CabaF(nLinha,nVend,cNomVend,_nPag)

Local nLin     := 0100
Local nCol     := 0070
Local nColAux  := 0
Local _cEmpresa:=""

	//Box Geral
	oPrint:Box(nLin,0050,2400,3000)
	
	If "01" $ cWCodEmp
		If "01" $ cWCodFil
			_cEmpresa:="DIPROMED"+"-"+"MATRIZ"
		Else
		   cEmpresa:="DIPROMED"+"-"+"CD"
		EndIf
	Else
		If "01" $ cWCodFil
			_cEmpresa:="HEALTH"+"-"+"MATRIZ"
		Else
		   _cEmpresa:="HEALTH"+"-"+"CD"
		EndIf	
	EndIf
	
	
	nLin +=60	
	oPrint:Say(nLin,1300,_cEmpresa,oFont20n,,CLR_RED)
	oPrint:Say(nLin,2880,"Pag: "+StrZero(_nPag,2),oFont15n,100)

	nLin +=50
	oPrint:Line(nLin-10,0050,nLin-10,3000)

	nLin +=50
	
	oPrint:Say(nLin,1000,"PEDIDOS A FATURAR - VENDEDOR(A): "+nVend+" - "+cNomVend,oFont17n)
	
	nLin +=40
	oPrint:Line(nLin,0050,nLin,3000)
	
	nLin +=100
	nColAux := nCol
	oPrint:Say(nLin,nCol,"Pedido",oFont17n,,CLR_BLUE)
	oPrint:Say(nLin,nColAux+=200,"Cliente",oFont17n,,CLR_BLUE)
	oPrint:Say(nLin,nColAux+=200,"Nome Cliente",oFont17n,,CLR_BLUE)
	oPrint:Say(nLin,nColAux+=1200,"Emiss„o",oFont17n,,CLR_BLUE)
	oPrint:Say(nLin,nColAux+=350,"LiberaÁ„o",oFont17n,,CLR_RED)
	oPrint:Say(nLin,nColAux+=450,"Operador",oFont17n,,CLR_BLUE)
	oPrint:Say(nLin,nColAux+=300,"Valor Total",oFont17n,,CLR_BLUE)
	
	nLin +=40
	oPrint:Line(nLin,0050,nLin,3000,CLR_BLUE)
	
	/*
	nLin +=50
	nColAux := nCol
	oPrint:Say(nLin,nCol+50,"Produto",oFont17n)
	oPrint:Say(nLin,nColAux+=200,"DescriÁ„o",oFont17n)
	oPrint:Say(nLin,nColAux+=950,"Qtd. Vendida",oFont17n)
	oPrint:Say(nLin,nColAux+=300,"Qtd. Liberada",oFont17n)
	oPrint:Say(nLin,nColAux+=400,"Saldo",oFont17n)
	oPrint:Say(nLin,nColAux+=250,"Vlr. Unit·rio",oFont17n)
	oPrint:Say(nLin,nColAux+=300,"Total Prod.",oFont17n)
	//oPrint:Say(nLin,nColAux+=300,"Nota Fiscal",oFont17n)
	*/
	
	nLin +=40
	oPrint:Line(nLin,0050,nLin,3000)		
	
	nLin +=50
	nLinha := nLin
	_nPag++

Return 


/*==========================================================================\
|Programa  | ENV_MAIL | Autor | Reginaldo Borges       | Data ≥ 31/01/18    |
|===========================================================================|
|Desc.     | Envia EMail com anexos dos relatÛrios dos pedidos por vendedor |
|===========================================================================|
|Sintaxe   | ENV_MAIL                                                       |
|===========================================================================|
|Uso       | Especifico DIPROMED                                            |
\==========================================================================*/
					    
Static Function ENV_MAIL(cEmail,cVend,cArq001,cArq002,cArq003,cArq004)

Local cAccount  := Lower(Alltrim(GetMv("MV_RELACNT")))
Local cFrom     := Lower(Alltrim(GetMv("MV_RELACNT")))
Local cPassword := Alltrim(GetMv("MV_RELPSW"))
Local cServer   := Alltrim(GetMv("MV_RELSERV"))
Local cEmailTo  := cEmail 
Local cEmailCc  := ""
Local cEmailBcc := ""                
Local lResult   := .F.
Local cError    := ""
LOCAL lSmtpAuth := GetNewPar("MV_RELAUTH",.F.)
LOCAL lAutOk	:= .F.
Local aAnexos   := {}
Local cAssunto  := ""
Local cBody     := ""
Local _dData    := (dDatabase)-1
Local _cVendedor:=cVend+" - "+Posicione("SA3",1,xFilial("SA3")+cVend,"A3_NOME")
Local _cFilial := ""

If Empty(cAssunto)
If "01" $ cWCodEmp
	If "01" $ cWCodFil
		_cFilial:="MATRIZ"
	Else
		_cFilial:="CD"
	EndIf
Else
	If "01" $ cWCodFil
		_cFilial:="MATRIZ"
	Else
		_cFilial:="CD"
	EndIf	
EndIf
                              
cAssunto := EncodeUTF8("Pedidos Di·rios: "+AllTrim(Substr(_cVendedor,1,29))+" - "+_cFilial,"cp1252")

EndIf

/*
cEmailCc := If((cDepart='01/03/' .Or. cDepart='03/01/'),"publico@dipromed.com.br;apoio@dipromed.com.br",;                                      
		    If(cDepart='03/',"publico@dipromed.com.br",;
		   	If(cDepart='01/',"apoio@dipromed.com.br","patricia.mendonca@dipromed.com.br;reginaldo.borges@dipromed.com.br")))
*/

Aadd(aAnexos,cArq001)
Aadd(aAnexos,cArq002)
Aadd(aAnexos,cArq003)
Aadd(aAnexos,cArq004)

cBody += (+Chr(13) +Chr(10) +Chr(13) +Chr(10))
cBody += '<font face="Arial" size=3>VENDEDOR, ESSE RELAT”RIO … REFERENTE AO DIA '+DTOC(_dData)+"." +Chr(13) +Chr(10)
//cBody += '<font face="Arial" size=3>VENDEDOR, ESSE RELAT”RIO … TESTE DA TI, RBORGES!!!!!!!!!' +Chr(13) +Chr(10)


If ("0401" $ cWCodEmp+cWCodFil)
//  cEmailTo :=""
//	cEmailCc :=""
    cEmailBcc:="vendas@healthquality.ind.br"   
Endif    

 /*
If GetNewPar("ES_ATIVJOB",.T.)
	cEmail+=";"+AllTrim(cEmailBcc)
	u_UEnvMail(AllTrim(cEmail),cAssunto,nil,"",cFrom,"ENV_065(DIPR065.prw)",cMsg)
EndIf
*/

//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥Envia o mail para a lista selecionada. Envia como BCC para que a pessoa pense≥
//≥que somente ela recebeu aquele email, tornando o email mais personalizado.   ≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ


CONNECT SMTP SERVER cServer ACCOUNT cAccount PASSWORD cPassword RESULT lResult

If !lAutOk
	If ( lSmtpAuth )
		lAutOk := MailAuth(cAccount,cPassword)
	Else
		lAutOk := .T.
	EndIf
EndIf

/*
cEmailTo := "reginaldo.borges@dipromed.com.br"
cEmailCc := "reginaldo.borges@dipromed.com.br"
cEmailBcc:= "reginaldo.borges@dipromed.com.br"
*/

If lResult .And. lAutOk
	SEND MAIL FROM cFrom ;
	TO      	Lower(cEmailTo);
	CC      	Lower(cEmailCc);
	BCC     	Lower(cEmailBcc);
	SUBJECT 	SubStr(cAssunto,1,55);
	BODY    	cBody;
	ATTACHMENT aAnexos[1],aAnexos[2],aAnexos[3],aAnexos[4];
	RESULT lResult
	
	If !lResult
		//Erro no envio do email''
		GET MAIL ERROR cError
		
		MsgInfo(cError,OemToAnsi("AtenÁ„o"))
	EndIf
	
	DISCONNECT SMTP SERVER
Else
	//Erro na conexao com o SMTP Server
	GET MAIL ERROR cError
	MsgInfo(cError,OemToAnsi("AtenÁ„o"))
EndIf


fErase(cArq001)
fErase(cArq002)
fErase(cArq003)
fErase(cArq004)


Return(.T.)
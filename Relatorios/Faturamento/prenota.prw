#INCLUDE "rwmake.ch"
#INCLUDE "protheus.ch"
#INCLUDE "ap5mail.ch"

#DEFINE CR    chr(13)+chr(10) // Carreage Return (Fim de Linha)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPRENOTA   บ Autor ณFabio Rogerio       บ Data ณ  25/09/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Rotina para a impressao da pre-nota.                       บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP6 IDE                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

User Function PRENOTA(cNum,lDireto,aProblema)
Local titulo 	     := "Pre Nota"
Local Cabec1    	 := ""
Local Cabec2       	 := ""
PRIVATE cDesc1       := "Este programa tem como objetivo imprimir relatorio "
PRIVATE cDesc2       := "de acordo com os parametros informados pelo usuario."
PRIVATE cDesc3       := "Pre Nota"
PRIVATE cPict        := ""
PRIVATE imprime      := .T.
PRIVATE aOrd         := {}
PRIVATE cPerg  		 := U_FPADR( "MTR730","SX1","SX1->X1_GRUPO"," " ) //Fun็ใo criada por Sandro em 19/11/09.
Private nLin       	 := 80
Private lEnd       	 := .F.
Private lAbortPrint	 := .F.
Private CbTxt      	 := ""
Private limite     	 := 80
Private tamanho    	 := "M"
Private nomeprog   	 := "PRENOTA" // Coloque aqui o nome do programa para impressao no cabecalho
Private nTipo      	 := 18
Private aReturn    	 := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
Private nLastKey   	 := 0
Private cbtxt      	 := Space(10)
Private cbcont     	 := 0
Private CONTFL     	 := 1
Private m_pag      	 := 1
Private nQtdTotPag 	 := 0
Private wnrel      	 := "PRENOTA" // Coloque aqui o nome do arquivo usado para impressao em disco
Private cString    	 := "SC9"
Private nCols      	 := 132
Private cTipoPre   	 := "S"
Private lTransfere 	 := .F.
Private cNumSep    	 := ""

Private	cAssuntoIc  :=  " AVISO - Pedido Com Icms InterEstadual - Prioridade na Libera็ใo"
Private	cAttachIc   :=  "  a"
Private	cDeIc       :=  Lower(Alltrim(Posicione("SU7",1,xFilial("SU7")+SC5->C5_OPERADO,"U7_EMAIL")))
Private cEmailIc    :=  GetMv("ES_DIPV4_6")+","+cDeIc
Private	cFuncSentIc :=  "Prenota.prw"
Private _aMsgIcm    := {}
Private nLen        := 0
Private cValfim     := " "
Private cNomeDes    := " "
Private nTotped     := 0
Private cLibVista   := "  "
Private cTituV      := "ATENวรO PEDIDO TEM PRIORIDADE NA LIBERAวรO"
Private lFunPre		:= Upper(FunName()) == "PRENOTA"                      
Private nAux		:= 0

//********************************************
DEFAULT cNum      := ""
DEFAULT lDireto   := .F.
DEFAULT aProblema := {}

U_DIPPROC(ProcName(0),U_DipUsr()) //MCVN - 22/01/2009

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Monta a interface padrao com o usuario...                           ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

Pergunte(cPerg,lFunPre)

If !Empty(cNum)
	Mv_Par01:= cNum
	Mv_Par02:= cNum
EndIf


//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Processamento. RPTSTATUS monta janela com a regua de processamento. ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

RptStatus({|| RunReport(Cabec1,Cabec2,Titulo,lDireto,aProblema,cNum) },Titulo)

// Imprime documento de transf๊rencia de produtos  03/10/2007
If lDireto         // MCVN - 04/10/2007
	If lTransfere .and. !Empty(cNumSep)
		U_TRANSFAUTO(cNumSep, lTransfere,lDireto,Mv_Par01)
		Alert("Esse Pedido gerou transfer๊ncia automatica. O documento de transfer๊ncia foi impresso!")
	Endif
Else
	If lTransfere .and. !Empty(cNumSep)
		If MsgBox("Essa prenota gerou transfer๊ncia. Deseja imprimir? ","Atencao","YESNO")
			U_TRANSFAUTO(cNumSep, lTransfere,lDireto,Mv_Par01)
		Endif
	Endif
Endif
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณRUNREPORT บ Autor ณ AP6 IDE            บ Data ณ  25/09/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Funcao auxiliar chamada pela RPTSTATUS. A funcao RPTSTATUS บฑฑ
ฑฑบ          ณ monta a janela com a regua de processamento.               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Programa principal                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Static Function RunReport(Cabec1,Cabec2,Titulo,lDireto,aProblema,cNum)
Local cSeparador := ""
Local nI         := 0
Local nJ		 := 0
Local aItens     := 0
Local cQuery  	 := ""
Local cEmail  	 := ""
Local cAssunto	 := ""
Local aMsg1   	 := {}
Local aMsg    	 := {}
Local aMsgSuf 	 := {}
Local cVal_STD	 := ""
Local cDescIcm	 := ""
Local cSuframa	 := ""
Local cNomeCliente := ""             
Local cTipo		 := ""
Local nValTot 	 := 0
Local cChave	 := ""
Local cSenha	 := ""
Local lPrimPag	 := .F.
Local cImp		 := GetNewPar("MV_LPT_PR2","")
Local nPos		 := At("|",cImp)  
Local cImpPre	 := "_PRENOTA_"                     
Local nTenta	 := 0
Private nTotPag	 := ""
Private nTotPa1	 := 0
DEFAULT cNum	 := ""

dbSelectArea("SC5")
SC5->(dbSetOrder(1))
SC5->(dbSeek(xFilial("SC5")+Mv_Par01,.T.))

SetRegua(RecCount())
While !SC5->(EOF()) .And. (SC5->(C5_FILIAL+C5_NUM) <= xFilial("SC5")+Mv_Par02)
	
	IncRegua("Imprimindo Pre-Nota " + SC5->C5_NUM)
	
	If !Empty(SC5->C5_NOTA) .Or. ((SC5->C5_PRENOTA == "S") .And. (Mv_Par03 == 1))
		dbSelectArea("SC5")
		dbSkip()
		Loop
	EndIf
	
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Verifica o cancelamento pelo usuario...                             ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If lAbortPrint
		@nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
		Exit
	Endif
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณValida o status da Pre-Nota.ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	aItens:= ItensPreNota(SC5->C5_NUM,@cSeparador,aProblema)
	 
	If aReturn[5] == 3  // Tratamento para impressใo na matricial  MCVN - 13/09/2007
		nTotPa1 := Int(Len(aItens[1])/17)+Iif(MOD(Len(aItens[1]),17)==0,0,1)
		nTotPag := nTotPa1+Int(Len(aItens[2])/17)+Iif(MOD(Len(aItens[2]),17)==0,0,1)
	Else	
		nTotPa1 := Int(Len(aItens[1])/18)+Iif(MOD(Len(aItens[1]),18)==0,0,1)		
		nTotPag := nTotPa1+Int(Len(aItens[2])/18)+Iif(MOD(Len(aItens[2]),18)==0,0,1)
	Endif      
	
	Do Case
		Case Len(aItens[1]) > 0 .And. Len(aItens[2]) > 0
			cTipo := "T/M"										
		Case Len(aItens[1]) > 0
			cTipo := " T "
		Case Len(aItens[2]) > 0
			cTipo := " M "
	End Case                 

	If (Len(aItens[1]) > 0) .Or. (Len(aItens[2]) > 0)
		SC5->(Reclock("SC5",.F.))
			SC5->C5_PRENOTA := "S"
			SC5->C5_DT_PRE  := DATE()
			SC5->C5_HR_PRE  := TIME()			
			
			If SC5->(FieldPos("C5_XTIPPRE")) > 0 
				SC5->C5_XTIPPRE := cTipo
			EndIf
			
			If SC5->(FieldPos("C5_XCHVPRE")) > 0 
				If cTipo == "T/M" .And. Empty(SC5->C5_XCHVPRE)
					SC5->C5_XCHVPRE := Embaralha(StrZero(Randomize(Val(SC5->C5_NUM),Val(SC5->C5_NUM)+32767),8),0) 
				ElseIf cTipo <> "T/M" .And. !Empty(SC5->C5_XCHVPRE)
					SC5->C5_XCHVPRE := "" 							
				EndIf
			EndIf   
		SC5->(MsUnLock())
		SC5->(DbCommit())  // Eriberto 24/04/07
	EndIf
	
	cSenha := SC5->C5_XCHVPRE    
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Impressao do cabecalho do relatorio. . .                            ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	
	For nI:=1 to Len(aItens)                  	
		aEval(aItens[nI],{|x| nValTot += x[10]})
    Next nI
    
    cChave  := Transform(Val(Embaralha(StrZero(Int(nValTot),9),0)),"@E 999,999,999")
    
	If lFunPre	
		PrepImp(lDireto,cNum,Titulo,nI)
	EndIf                      
	
	While !LockByName(cImpPre,.T.,.F.) .And. nTenta<=10
		ConOut("Ficou preso no lock da prenota - nTenta = "+StrZero(nTenta,2)+" "+Time()+" Emp/Fil "+cEmpAnt+"/"+cFilAnt)
		Sleep(3000)	
		nTenta++                      	
	EndDo                           
    
	For nI:=1 to Len(aItens)
		lPrimPag := .T.
		nLin := 80                                  

		If Len(aItens[nI]) == 0
			Loop
		EndIf
		
		If !lFunPre
			PrepImp(lDireto,cNum,Titulo,nI)
		EndIf
		
		// Alterado para incluir a sequencia na Pre-Nota  -   MCVN 07/03/07
		For nJ:= 1 To Len(aItens[nI])
			
			If aReturn[5] == 3  // Tratamento para impressใo na matricial  MCVN - 13/09/2007
				If nLin > 49 // Salto de Pแgina. Neste caso o formulario tem 55 linhas...
					
					If nJ <> 1
						RODAPRENOTA(cSeparador,aItens[nI],nI,cChave)						
						m_pag++					
					EndIf
					
					nLin:= CABPRENOTA(aItens[nI],cSeparador,cTipo,nI,cChave,cSenha,@lPrimPag)
					
				Endif
			Else
				If nLin > 52 // Salto de Pแgina. Neste caso o formulario tem 55 linhas...
					If nJ <> 1
						RODAPRENOTA(cSeparador,aItens[nI],nI,cChave)
						m_pag++					
					EndIf
					
					nLin:= CABPRENOTA(aItens[nI],cSeparador,cTipo,nI,cChave,cSenha,@lPrimPag)
					
				Endif
			Endif			
			
			@nLin,02  PSAY aItens[nI,nJ,1]
			@nLin,04  PSAY "-" + aItens[nI,nJ,2]
			@nLin,09  PSAY aItens[nI,nJ,3]
			
			If Empty(Alltrim(aItens[nI,nJ,12]))
				@nLin,18  PSAY "    "+AllTrim(aItens[nI,nJ,9])
			Else
				@nLin,18  PSAY "(T) "+AllTrim(aItens[nI,nJ,9])
				If !lTransfere
					lTransfere := .T.
					cNumSep := Alltrim(aItens[nI,nJ,12])
				Endif
			EndIf
			
			@nLin,30  PSAY aItens[nI,nJ,4]
			@nLin,44  PSAY aItens[nI,nJ,5]
			@nLin,48  PSAY Left(aItens[nI,nJ,6],62)
			@nLin,111  PSAY aItens[nI,nJ,7]
			If aItens[nI,nJ,11] <> "S"  .OR. Alltrim(aItens[nI,nJ,7]) = Alltrim(aItens[nI,nJ,3]) //Se o Produto nใo tem controle de lote interno nใo imprime a data na Pre-nota  MCVN - 22/08/07
				@nLin,124 PSAY "  /  /  "
			Else
				@nLin,124 PSAY Dtoc(aItens[nI,nJ,8])
			Endif
			
			nLin++			
			@nLin,002 PSAY Replicate("-",nCols)
			nLin++
			
		Next nJ
		
		If Len(aItens[nI]) > 0
			RODAPRENOTA(cSeparador,aItens[nI],nI,cChave)
			m_pag++											
			// Registra na ficha Kardex
			If Len(aProblema)>0
				U_DiprKardex(SC5->C5_NUM,U_DipUsr(),"PRE-NOTA COM PROBLEMA - "+cSeparador,.T.,"37")
			Else
				U_DiprKardex(SC5->C5_NUM,U_DipUsr(),"IMPRESSAO DE PRE-NOTA - "+cSeparador,.T.,"19")
			EndIf
			
		EndIf

		If !lFunPre
			ImpRel()	
		EndIf			
	Next nI   
	
	If lFunPre	
		ImpRel()                        
	EndIf

	
	If cEmpAnt == '01' .And. !lFunPre
		WinExec("RUNDLL32 PRINTUI.DLL,PrintUIEntry /y /n "+Left(cImp,nPos-1))	
	EndIf
	
	If nTenta <= 10
		UnlockByName(cImpPre,.T.,.F.)	
	EndIf
	
	If !Empty(SC5->C5_SENHCID) .or. !Empty(SC5->C5_SENHPAG) .or. !Empty(SC5->C5_SENHMAR) .or. !Empty(SC5->C5_SENHTES) /// VERIFICA SE ALGUM DOS CAMPOS DE SENHA ESTม PREENCHIDO.
		/*====================================================================================\
		|SELECIONANDO ITENS DO PEDIDO QUE POSSUI SENHA GRAVADA PARA ENVIAR AO ERICH           |
		\====================================================================================*/
		
		QRY1 := " SELECT C5_CLIENTE, C5_LOJACLI, A1_NOME, C5_NUM, C5_EMISSAO, C5_OPERADO, C5_MARGATU, C5_MARGLIB, C5_SENHCID, C5_SENHTES, C5_SENHMAR, C5_SENHPAG, C5_EXPLSEN, C5_DATA1, C5_PARC1, C5_DATA2, C5_PARC2, C5_DATA3, C5_PARC3, C5_DATA4, C5_PARC4, C5_DATA5, C5_PARC5, C5_DATA6, C5_PARC6, C6_PRODUTO, C6_MARGATU, C6_MARGITE, C6_QTDVEN, C6_PRCVEN, C6_CUSTO, C6_PRCMIN, C6_NOTA, C6_VALOR, B1_DESC, B1_UCOM, B1_UPRC+(B1_UPRC*B1_IPI/100) B1_UPRC, B1_PRVMINI, B1_PRVSUPE, B1_ALTPREC, U7_NREDUZ, U7_EMAIL, E4_DESCRI, C5_DATA1, C5_DATA2, C5_DATA3, C5_DATA4 "
		QRY1 += " FROM " + RetSQLName("SC6") + ", " + RetSQLName("SC5") + ", " + RetSQLName("SA1") + ", " + RetSQLName("SU7") + ", " + RetSQLName("SB1") + ", " + RetSQLName("SE4")
		QRY1 += " WHERE C6_FILIAL = '"+xFilial("SC6")+"'" // JBS 09/11/2005
		QRY1 += "   AND C5_FILIAL = '"+xFilial("SC5")+"'" // JBS 09/11/2005
		QRY1 += "   AND A1_FILIAL = '"+xFilial("SA1")+"'" // JBS 09/11/2005
		QRY1 += "   AND U7_FILIAL = '"+xFilial("SU7")+"'" // JBS 09/11/2005
		QRY1 += "   AND B1_FILIAL = '"+xFilial("SB1")+"'" // JBS 09/11/2005
		QRY1 += "   AND E4_FILIAL = '"+xFilial("SE4")+"'" // JBS 09/11/2005
		QRY1 += "   AND C6_NUM = '" + SC5->C5_NUM + "'" // JBS 09/11/2005
		QRY1 += "   AND C5_NUM = C6_NUM"
		QRY1 += "   AND C6_CLI = A1_COD"
		QRY1 += "   AND C6_LOJA = A1_LOJA"
		QRY1 += "   AND C5_OPERADO = U7_COD"
		QRY1 += "   AND E4_CODIGO = C5_CONDPAG"
		QRY1 += "   AND B1_COD = C6_PRODUTO"
		QRY1 += "   AND " + RetSQLName("SC6") + ".D_E_L_E_T_ <> '*'"
		QRY1 += "   AND " + RetSQLName("SC5") + ".D_E_L_E_T_ <> '*'"
		QRY1 += "   AND " + RetSQLName("SA1") + ".D_E_L_E_T_ <> '*'"
		QRY1 += "   AND " + RetSQLName("SU7") + ".D_E_L_E_T_ <> '*'"
		QRY1 += "   AND " + RetSQLName("SB1") + ".D_E_L_E_T_ <> '*'"
		QRY1 += "   AND " + RetSQLName("SE4") + ".D_E_L_E_T_ <> '*'"
		QRY1 += " ORDER BY C6_NUM"
		
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
		
		DbCommitAll()
		TcQuery QRY1 NEW ALIAS "QRY1"
		
		DbSelectArea("QRY1")
		QRY1->(dbGotop())
		
		Do While QRY1->(!EOF())
			aadd(aMsg,{QRY1->C5_CLIENTE, QRY1->C5_LOJACLI, QRY1->A1_NOME, QRY1->C5_NUM, QRY1->C5_EMISSAO, QRY1->C5_OPERADO, QRY1->C5_MARGATU, QRY1->C5_MARGLIB, QRY1->C5_SENHMAR, QRY1->C5_SENHPAG, QRY1->C5_SENHTES, QRY1->C5_SENHCID, QRY1->C5_EXPLSEN, QRY1->C5_DATA1, QRY1->C5_PARC1, QRY1->C5_DATA2, QRY1->C5_PARC2, QRY1->C5_DATA3, QRY1->C5_PARC3, QRY1->C5_DATA4, QRY1->C5_PARC4, QRY1->C5_DATA5, QRY1->C5_PARC5, QRY1->C5_DATA6, QRY1->C5_PARC6, QRY1->C6_PRODUTO, QRY1->C6_MARGATU, QRY1->C6_MARGITE, QRY1->C6_QTDVEN, QRY1->C6_PRCVEN, QRY1->C6_CUSTO, QRY1->C6_PRCMIN, QRY1->C6_NOTA, QRY1->C6_VALOR, QRY1->B1_DESC, QRY1->B1_UCOM, QRY1->B1_UPRC, QRY1->B1_PRVMINI, QRY1->B1_PRVSUPE, QRY1->B1_ALTPREC, QRY1->U7_NREDUZ, QRY1->U7_EMAIL, QRY1->E4_DESCRI, QRY1->C5_DATA1, QRY1->C5_DATA2, QRY1->C5_DATA3, QRY1->C5_DATA4, QRY1->C5_DATA5, QRY1->C5_DATA6})
			QRY1->(DbSkip())
		EndDo
		
		
		If Len(aMsg) > 0 // SE NรO POSSUIR NENHUMA LINHA NO ARRAY NรO ENVIA NADA
			cEmail := 'erich@dipromed.com.br'

			If '02' $ Posicione("SU7",1,xFilial("SU7")+SC5->C5_OPERADO,"U7_POSTO")
				cEmail := cEmail +";patricia.mendonca@dipromed.com.br"
			EndIf
			cAssunto := 'Pedido de venda liberado por senha - ' + SC5->C5_NUM
			If substr(SC5->C5_XRECOLH,5,1) $ "-"
				cAssunto := cAssunto + " - Item com Valor Menor que Pre็o de Lista."
			EndIf
			U_EMail2(cEmail,cAssunto,aMsg)
		Endif
		
		
		DBCLOSEAREA("QRY1")
	EndIf
	
	If SubStr(SC5->C5_MENNOTA,AT('=',SC5->C5_MENNOTA),5) == "=ST=D"  .AND. Val(Left(SC5->C5_MENNOTA,4)) > 0/// VERIFICA SE SUBST. TRIBUTมRIA ESTม INCLUSO NO VALOR DA DESPESA. TRATANDO ST COM VALOR 0 - MCVN 12/11/09.
		/*====================================================================================\
		|SELECIONANDO ITENS DO PEDIDO QUE POSSUI SUBSTITUIวรO TRIBUTมRIA NA DESPESA           |
		\====================================================================================*/
		
		cQuery := "SELECT C6_NUM, C6_ITEM, C6_PRODUTO, C6_QTDVEN, C6_UM, C6_DESCRI, C6_VALOR, C6_CLI, C6_LOJA, C5_MENNOTA, A1_NOME, A1_EST, U7_EMAIL, C5_FRETE, C5_DESPESA, C5_TRANSP, C5_OPERADO "
		cQuery += " FROM " + RetSQLName("SC6") + ", " + RetSQLName("SC5") + ", " + RetSQLName("SA1") + ", " + RetSQLName("SU7")
		cQuery += " WHERE C5_FILIAL = '"+xFilial("SC5")+"'" // JBS 09/11/2005
		cQuery += "   AND C6_FILIAL = '"+xFilial("SC6")+"'" // JBS 09/11/2005
		cQuery += "   AND A1_FILIAL = '"+xFilial("SA1")+"'" // JBS 09/11/2005
		cQuery += "   AND U7_FILIAL = '"+xFilial("SU7")+"'" // JBS 09/11/2005
		cQuery += "   AND C6_NUM = '" + SC5->C5_NUM + "'" // JBS 09/11/2005
		cQuery += "   AND C5_NUM = C6_NUM"
		cQuery += "   AND C6_CLI = A1_COD"
		cQuery += "   AND C6_LOJA = A1_LOJA"
		cQuery += "   AND C5_OPERADO = U7_COD"
		cQuery += "   AND " + RetSQLName("SC6") + ".D_E_L_E_T_ <> '*'"
		cQuery += "   AND " + RetSQLName("SC5") + ".D_E_L_E_T_ <> '*'"
		cQuery += "   AND " + RetSQLName("SA1") + ".D_E_L_E_T_ <> '*'"
		cQuery += "   AND " + RetSQLName("SU7") + ".D_E_L_E_T_ <> '*'"
		cQuery += " ORDER BY C6_NUM"
		
		cQuery := ChangeQuery(cQuery)
		
		DbCommitAll()
		DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"QRY2",.T.,.T.)
		
		dbSelectArea("QRY2")
		dbGotop()
		
		Do While QRY2->(!EOF())
			cVal_STD := SubStr(QRY2->C5_MENNOTA,1,AT("=",QRY2->C5_MENNOTA)-1)
			aadd(aMsg1,{QRY2->C6_NUM, QRY2->C6_ITEM, QRY2->C6_PRODUTO, QRY2->C6_DESCRI, QRY2->C6_UM, QRY2->C6_QTDVEN, QRY2->C6_VALOR, QRY2->C6_CLI, QRY2->C6_LOJA, QRY2->A1_NOME, QRY2->A1_EST, Val(cVal_STD), QRY2->U7_EMAIL, QRY2->C5_FRETE, QRY2->C5_DESPESA,QRY2->C5_TRANSP,QRY2->C5_OPERADO})
			//			1             2             3                 4                5             6               7               8             9              10             11               12          13              14              15               16               17
			QRY2->(DbSkip())
		EndDo
		QRY2->(dbCloseArea())
		
		If cEmpAnt+cFilAnt == '0401'
			If Len(aMsg1) > 0 // SE NรO POSSUIR NENHUMA LINHA NO ARRAY NรO ENVIA NADA
				cEmail := GetNewPar("ES_M460HQ","reginaldo.borges@dipromed.com.br")
				cAssunto:= 'AVISO - Substitui็ใo Tributแria - PV-' + SC5->C5_NUM
				U_EMailPre(cEmail,cAssunto,aMsg1)
			EndIf
		Else
			If Len(aMsg1) > 0 // SE NรO POSSUIR NENHUMA LINHA NO ARRAY NรO ENVIA NADA
				cEmail := 'magda.teixeira@dipromed.com.br;sirlene.creatto@dipromed.com.br'
				cAssunto:= 'AVISO - Substitui็ใo Tributแria - PV-' + SC5->C5_NUM
				U_EMailPre(cEmail,cAssunto,aMsg1)	
			EndIf	
		EndIf				

	EndIf
	
	// ENVIA EMAIL SE CLIENTE TIVER SUFRAMA (PIN-PROTOCOLO DE INTERNAวรO DE NOTA FISCAL)  17/01/2008
	cSuframa := Posicione('SA1', 1, xFilial('SA1') + SC5->C5_CLIENTE + SC5->C5_LOJACLI, 'A1_SUFRAMA')
	If  !Empty(cSuframa)
		cDescIcm     := SA1->A1_CALCSUF
		cNomeCliente := SA1->A1_NOME
		cFrom        := Lower(Alltrim(Posicione("SU7",1,xFilial("SU7")+SC5->C5_OPERADO,"U7_EMAIL")))
		
		Aadd( aMsgSuf , { "Cliente: "             , SC5->C5_CLIENTE + " - " + cNomeCliente} )
		Aadd( aMsgSuf , { "Numero Pedido: "       , SC5->C5_NUM } )
		Aadd( aMsgSuf , { "Operador: "            , SC5->C5_OPERADO +" - " + Alltrim(Posicione("SU7",1,xFilial("SU7")+SC5->C5_OPERADO,"U7_NOME")) } )
		Aadd( aMsgSuf , { "Transportadora: "      , SC5->C5_TRANSP + " - " + Alltrim(Posicione("SA4",1,xFilial("SA4")+SC5->C5_TRANSP,"A4_NOME" )) } )
		Aadd( aMsgSuf , { "Destino do Pedido:  "  , SC5->C5_ESTE +" - "+ SC5->C5_MUNE } )
		Aadd( aMsgSuf , { "C๓digo Suframa: "      , Posicione('SA1', 1, xFilial('SA1') + SC5->C5_CLIENTE + SC5->C5_LOJACLI, 'A1_SUFRAMA') } )
		If cDescIcm == "S"
			Aadd( aMsgSuf , { "Desconto Icms:  "  , "SIM" } )
		Endif
		
		If Len(aMsgSuf) > 0
			cEmail 	 := GetNewPar("ES_MAILSUF","magda.teixeira@dipromed.com.br;sirlene.creatto@dipromed.com.br;deoclecio.santos@dipromed.com.br")
			cAssunto := 'AVISO - Cliente com SUFRAMA - PV-' + SC5->C5_NUM
			U_UEnvMail(cEmail,cAssunto,aMsgSuf,"",cFrom,"Prenota.prw")
		Endif
	EndIf
	
	//giovani reposicionamento do e-mail do cic e do e-mail a vista sem para no financeiro. 12/07/11
	
	SA1->(dbSetOrder(1))
	SA1->(dbSeek(xFilial("SA1") + SC5->C5_CLIENTE + SC5->C5_LOJACLI))
	
	
	If SC5->C5_TIPODIP = "1" .And. substr(SC5->C5_XRECOLH,1,3) $ "ACR/GUI"
		
		aAdd( _aMsgIcm , { "EMPRESA"      , + Capital( AllTrim( GetAdvFVal( "SM0", "M0_NOMECOM", cEmpAnt + cFilAnt, 1, "" ) ) )  } )
		aAdd( _aMsgIcm , { "FILIAL"       , + Capital( AllTrim( GetAdvFVal( "SM0", "M0_FILIAL" , cEmpAnt + cFilAnt, 1, "" ) ) ) } )
		aAdd( _aMsgIcm , { "PEDIDO"       , ""+SC5->C5_NUM+""  } )
		aAdd( _aMsgIcm , { "CLIENTE"      , ""+AllTrim(SA1->A1_COD)+" - "+AllTrim(SA1->A1_NREDUZ)+""  } )
		aAdd( _aMsgIcm , { "E-Mail"       , ""+Lower(Alltrim(Posicione("SA1",1,xFilial("SA1")+SC5->C5_CLIENTE+SC5->C5_LOJACLI,"A1_EMAIL")))+""} ) //giovani 19/07/11
		aAdd( _aMsgIcm , { "OPERADOR"      ,""+SC5->C5_OPERADO+"-"+Posicione("SU7",1,xFilial("SU7")+SC5->C5_OPERADO,"U7_NOME") })
		aAdd( _aMsgIcm , { "VENDEDOR"      ,""+SC5->C5_VEND1+"-"+Posicione("SA3",1,xFilial("SA3")+SC5->C5_VEND1,"A3_NOME") })
		aAdd( _aMsgIcm , { "TRANSPORTADORA", ""+SC5->C5_TRANSP+" - " + AllTrim(FDesc("SA4",SC5->C5_TRANSP,"SA4->A4_NREDUZ"))+" "  } )
		If substr(SC5->C5_XRECOLH,1,3) $ "ACR"
			aAdd( _aMsgIcm , { "OPวรO"        , "1- Acrescimo no Valor do Pedido."  } )
		EndIf
		
		
		U_MailPedi(cEmailIc,cAssuntoIc,_aMsgIcm,cAttachIc,cDeIc,cFuncSentIc,cTituV)
		
		//manda cic do pedido
		
		cMSGcIC       := " EMPRESA:_______" + Capital( AllTrim( GetAdvFVal( "SM0", "M0_NOME", cEmpAnt + cFilAnt, 1, "" ) ) ) +"/"+ Capital( AllTrim( GetAdvFVal( "SM0", "M0_FILIAL" , cEmpAnt + cFilAnt, 1, "" ) ) )   + CR + CR
		cMSGcIC       += _aMsgIcm[3][1]+":____________" +_aMsgIcm[3][2] +CR
		//................1 2 3 4 5 6 7 8 9 0
		cMSGcIC       += _aMsgIcm[4][1]+":___________" +_aMsgIcm[4][2] +CR
		//................1 2 3 4 5 6 7 8 9 0
		cMSGcIC       += _aMsgIcm[6][1]+":_________" +_aMsgIcm[6][2] +CR
		//................1 2 3 4 5 6 7 8 9 0
		cMSGcIC       += _aMsgIcm[8][1]+":__" +_aMsgIcm[8][2] +CR
		//................1 2 3 4 5 6 7 8 9 0
		If substr(SC5->C5_XRECOLH,1,3) $ "ACR"
			cMSGcIC       += _aMsgIcm[9][1]+":_____________" +_aMsgIcm[9][2] +CR
			//................1 2 3 4 5 6 7 8 9 0
		EndIf
		cMSGcIC       += "AVISO: Pedido com Prioridade de libera็ใo -(Icms-Interestadual)" +CR
		//................1 2 3 4 5 6 7 8 9 0
		
		//manda CIC
		U_DIPCIC(cMSGcIC,GetMV("ES_DIPV4_7"))
		
		//giovani msg do cic na libera็ใo do pedido a vista  e nao ficou parado no financeiro
		
		If SC5->C5_CONDPAG $ "001/002"
			If	SC5->C5_TIPODIP = "1"
				cMSGcIC   := " "
				nTotped := ValorPedido(SC5->C5_NUM)
				
				// Monta a mensagem a ser enviado ao operador
				cMSGcIC := "PEDIDO A VISTA"+CR+CR
				cMSGcIC += "O Pedido A VISTA   "   +Alltrim(SC5->C5_NUM)+CR+CR
				cMSGcIC += " do Cliente   "+AllTrim(SA1->A1_COD)+" - "+AllTrim(SA1->A1_NREDUZ)+CR+CR
				cMSGcIC += " Valor total "+AllTrim(Transform(nTotped,"@E 999,999,999.99"))+CR +CR+CR      // Incluido por Sandro em 10/11/09
				
				cMSGcIC += "Operador:  "+SC5->C5_OPERADO+"-"+Posicione("SU7",1,xFilial("SU7")+SC5->C5_OPERADO,"U7_NOME")
				
				
				
				U_DIPCIC(cMSGcIC,GetMV("ES_DIPV4_5"))
			EndIf
		Endif
	EndIf
	//**************************************************************************
	
	U_DipCicCli()
	
	dbSelectArea("SC5")
	dbSkip() // Avanca o ponteiro do registro no arquivo
EndDo

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCABPRENOTAบAutor  ณFabio Rogerio       บ Data ณ  09/28/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณImprime o cabecalho da Pre-Nota                             บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function CABPRENOTA(aItens,cSeparador,cTipo,nI,cChave,cSenha,lPrimPag)
Local cTitulo:= "PRE-NOTA N. "+SC5->C5_NUM
Local cTitulo2 := Iif(cEmpAnt+cFilAnt=='0401',Iif(!(SC5->C5_TIPO $ "DB"),"CLIENTE: " +SC5->C5_CLIENTE+"-"+SC5->C5_LOJACLI +" - "+ Alltrim(Posicione("SA1",1,xFilial("SA1")+SC5->(C5_CLIENTE+C5_LOJACLI),"A1_NOME")),"FORNECEDOR: " +SC5->C5_CLIENTE+"-"+SC5->C5_LOJACLI +" - "+ Alltrim(Posicione("SA2",1,xFilial("SA2")+SC5->(C5_CLIENTE+C5_LOJACLI),"A2_NOME"))),"")
Local nSpace   := nCols - (Len(cTitulo2) + Len(cTitulo))
Local cNomeRota:= ""
Local aProdMA := {}
Local cLin 	   := 0


Private cHrLib := ""
Private dDtLib := ""
Private cHrLibCred  := ""
Private dDtLibCred  := ""

Private cClientLic:=GetMv("ES_DIPML27")
Private cTESLicG  :=GetMv("ES_DIPMG27")
Private cTESLicN  :=GetMv("ES_DIPMN27") 
Private cPEDVEN   :=SC5->C5_NUM


DEFAULT aItens 		:= {}
DEFAULT cSeparador 	:= ""
DEFAULT cTipo		:= ""
DEFAULT nI			:= 0                        
DEFAULT cChave		:= ""
DEFAULT cSenha	 	:= ""
DEFAULT lPrimPag	:= .F.

nQtdTotPag := nTotPag

aProdMA := MAItens(SC5->C5_NUM) // Desabilitado em 08/06/2012 (Solicitado pelo Valdo atrav้s de CIC)

If Len(aProdMA) > 0 .And. nI == 1
	nTotPag++
	nQtdTotPag := nTotPag
	If m_pag == 1
		PrnMA( aProdMA, m_pag, nTotPag, @cTitulo2 )
		nSpace := nCols - (Len(cTitulo2) + Len(cTitulo))
		RODAPRENOTA(cSeparador,aItens,nI,cChave)
		m_pag++        
		nAux++
	EndIf
EndIf
	
SetPrc(0,0)
// Busca no Z9 data e hora de libera็ใo e libera~]ao de cr้dito  -   MCVN 24/01/2007
PrenotaSz9()
// Buscando a rota  -   MCVN 05/10/10
If Empty(Alltrim(cNomeRota))
	cNomeRota:=FindRotaZv(SC5->C5_CEPE)
Endif

@ 00,000 PSAY chr(15)
@ 01,002 PSAY Replicate("-",nCols)

cLin := PADR(cTitulo ,25)
cLin += PADC(cTitulo2,25)
If cEmpAnt = '04'
	cLin += Space(15)
Else
	cLin += PADC("TIPO: " +cTipo,15)
EndIf

If !Empty(cSenha)              
	cLin += PADC("PARTE: "+If(nI==1,"T","M"),15)
	If lPrimPag
		cLin += PADC(If(nI==1,"SENHA T: "+SubStr(cSenha,1,4),"SENHA M: "+SubStr(cSenha,5,4)),30)
		lPrimPag := .F.
	Else
		cLin += Space(30)
	EndIf                
Else
	cLin += Space(45)	
EndIf
	
cLin += PADL("Pag. " + Str(m_pag,2)+' /'+Str(nTotPag,2),20)

@ 02,002 PSAY cLin

@ 03,002 PSAY Replicate("-",nCols)
@ 04,002 PSAY Space((nCols-6)-Len(Alltrim(cNomeRota))) + If(Len(Alltrim(cNomeRota))>0,"ROTA: " + cNomeRota, "")
@ 05,002 PSAY "Cliente: " +SC5->C5_CLIENTE+ " - " +Posicione("SA1",1,xFilial("SA1")+SC5->(C5_CLIENTE+C5_LOJACLI),"A1_NREDUZ")
@ 06,002 PSAY "Mensagem para o DEPOSITO: " + SC5->C5_MENDEP

 
//RBorges 21/10/2013-
// Imprime observa็ใo de carta de vale quando o cliente estiver no parโmetro, no tes que gera financeiro e nใo atualiza 
//estoque, posto igual licita็ใo e for transporte Emovere.                                          
If	(SC5->C5_CLIENTE $ cClientLic .AND. SC6->C6_TES $ cTesLicG .AND. SU7->U7_POSTO $ "03" .AND. SC5->C5_TRANSP == "100000")
	
	@ 07,002 PSAY "OBS. LICITAวรO - INCLUIR VOLUME PARA ESTE PEDIDO E GERAR CTE, APENAS FINANCEIRO! "
	
	CCDipm27()
	EmDipm27()
	
EndIf


@ 08,002 PSAY PADR("Observacao do Cliente   : " + Posicione("SA1",1,xFilial("SA1")+SC5->(C5_CLIENTE+C5_LOJACLI),"A1_OBSPRE"),128)

@ 10,002 PSAY "Emitido em  : "   + DTOC(SC5->C5_EMISSAO)+' as '+SC5->C5_HORA
@ 10,065 PSAY "Impresso dia  : " + DTOC(dDatabase) + " as " + SUBSTR(Time(),1,5)+'  Por: '+Upper(U_DipUsr())

@ 11,002 PSAY "Liberado dia: "   + dDtLib     + " as " + SUBSTR(cHrLib,1,5)
@ 11,065 PSAY "Credito  dia  : " + dDtLibCred + " as " + SUBSTR(cHrLibCred,1,5)

@ 12,002 PSAY "Vendedor    : "   + SC5->C5_VEND1 + " - " + Alltrim(Posicione('SA3',1,xFILIAL('SA3')+SC5->C5_VEND1,'A3_NOME'))
@ 12,065 PSAY "Transportadora: " + SC5->C5_TRANSP+ " - " + Alltrim(Posicione('SA4',1,xFILIAL('SA4')+SC5->C5_TRANSP,'A4_NOME'))

@ 13,002 PSAY "Operador    : "   + Alltrim(Posicione('SU7',1,xFILIAL('SU7')+SC5->C5_OPERADO,'U7_NOME'))
@ 13,065 PSAY "Cond.Pagto.   : " + SC5->C5_CONDPAG+" - "+Alltrim(Posicione('SE4',1,xFILIAL('SE4')+SC5->C5_CONDPAG,'E4_DESCRI'))

@ 14,002 PSAY Replicate("-",nCols)

If aReturn[5] == 3 // MCVN - 13/09/2007
	@ 15,002 PSAY "Item   Codigo   Localizacao  Quantidade   UM  Descricao do Material                                          Lote          Data Validade" //MCVN 28/03/07
Else
	@ 15,002 PSAY "Item   Codigo   Localizacao  Quantidade   UM  Descricao do Material                                          Lote         Validade  " //MCVN 28/03/07
Endif

@ 16,002 PSAY Replicate("-",nCols)

nLin := 17




Return(nLin)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma  ณRODAPRENOTAบAutor  ณMicrosiga           บ Data ณ  09/28/06  บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDesc.     ณRodape da Pre-Nota                                          บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function RODAPRENOTA(cSeparador,aItens,nI,cChave)

DEFAULT cSeparador 	:= ""
DEFAULT aItens		:= {}
DEFAULT nI			:= 0                        
DEFAULT cChave 		:= ""
              
If aReturn[5] == 3 // Tratamento para impressใo na matricial  MCVN - 13/09/2007
	
	@ 49,002 PSAY Replicate("-",nCols)
	@ 50,002 PSAY "SEPARADO POR -> __________________"
	@ 50,037 PSAY "CONFERIDO POR -> __________________"
	@ 50,073 PSAY "EXPEDICAO -> ________________"
	@ 50,101 PSAY "VOLUME PARCIAL -> ________________"
	@ 51,002 PSAY Replicate("-",nCols)
	
	U_BigNumber(SC5->C5_NUM)
	
	@ 60,002 PSAY Replicate("-",nCols)	
	If m_pag == 1
		@ 61,002 PSAY 'Chave para validar na geracao da nota: '+cChave
		@ 65,101 PSAY 'VOLUME TOTAL -> ________________'
	EndIf		
	@ 65,000 PSAY ""
	SetPgEject(.T.)
	
Else
	
	@ 54,002 PSAY Replicate("-",nCols)
	@ 55,002 PSAY "SEPARADOR -> ______________"
	@ 55,030 PSAY "CONFERIDO -> ______________"
	@ 55,058 PSAY "EXPEDICAO -> ___________"
	@ 55,083 PSAY "VOL PARC. -> ____________"                   
	@ 55,109 PSAY "VOL TOTAL -> ____________"
	@ 56,002 PSAY Replicate("-",nCols)
	
	U_BigNumber(SC5->C5_NUM)
	
	@ 64,002 PSAY Replicate("-",nCols)
	If m_pag == 1+nAux
		@ 65,002 PSAY 'Chave para validar na geracao da nota: '+cChave
	EndIf
	@ 69,000 PSAY ""                   
	
	If !lFunPre
		If (nI == 1 .And. m_pag < nTotPa1) .Or.;
		   (nI == 2 .And. m_pag < nTotPag)
			Eject
		EndIf
	ElseIf m_pag < nTotPag
		Eject		
	EndIf
	
Endif

Return( NIL )
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณBIGNUMBER บAutor  ณFabio Rogerio       บ Data ณ  09/28/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRotina para impressao do numero do pedido em formato grande บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function BigNumber(cPedido,lEtiqueta)
Local ee1, ee2
Local _linha    :=''
Local _numero   := ''
Local lEtiqueta := If(lEtiqueta == NIL,.F.,lEtiqueta)
Local aEtiqueta := {}
Local aNumero := ;
{{'  11  ',' 111  ','  11  ','  11  ','  11  ','  11  ','111111'},;
{' 2222 ','22  22','    22','   22 ','  22  ',' 22   ','222222'},;
{'33333 ','    33','    33','33333 ','    33','    33','33333 '},;
{'44  44','44  44','44  44','444444','    44','    44','    44'},;
{'555555','55    ','55    ','55555 ','    55','55  55',' 5555 '},;
{' 6666 ','66  66','66    ','66666 ','66  66','66  66',' 6666 '},;
{'777777','    77','   77 ','  77  ',' 77   ','77    ','77    '},;
{' 8888 ','88  88','88  88',' 8888 ','88  88','88  88',' 8888 '},;
{' 9999 ','99  99','99  99',' 99999','    99','    99',' 9999 '},;
{' 0000 ','00  00','00  00','00  00','00  00','00  00',' 0000 '},;
{'  AA  ',' AAAA ','AA  AA','AAAAAA','AA  AA','AA  AA','AA  AA'},;
{'-----------------------------------','|      Numero da Nota Fiscal      |','|                                 |','|                                 |','|                                 |','|                                 |','-----------------------------------'}}

For ee1 = 1 to 7
	_linha := ''
	For ee2 = 1 to 6
		_numero := anumero[Iif(Subs(cPedido,ee2,1)='0',10,Iif(Subs(cPedido,ee2,1)='A',11,Val(Subs(cPedido,ee2,1))))][ee1]
		_linha := _linha + _numero+space(If(lEtiqueta,6,10))
	Next
	If !lEtiqueta
		If cTipoPre == "S"
			If aReturn[5] == 3  // Tratamento para impressใo na matricial  MCVN - 13/09/2007
				@ 52+ee1,002 psay _linha +space(3)+ anumero[12][ee1]
			Else
				@ 56+ee1,002 psay _linha +space(3)+ anumero[12][ee1]
			Endif
		Else
			@ 52+ee1,002 psay _linha +space(3)+ anumero[12][ee1]
		Endif
	Else
		Aadd(aEtiqueta,_linha)
	EndIf
Next
If lEtiqueta
	If Select("QRY1") > 0
		_linha := "Volumes.    Nota Fiscal/Serie: " + QRY1->F2_DOC + "/" + mv_par01 + space(14)+QRY1->F2_LOCEXP + "    "+QRY1->F2_CONFERI
		Aadd(aEtiqueta,_linha)
		Aadd(aEtiqueta,QRY1->F2_VOLUME1)
	Else
		_linha := "Volumes.    Nota Fiscal/Serie: " + SF2->F2_DOC + "/" + SF2->F2_SERIE + space(14)+SF2->F2_LOCEXP + "    "+SF2->F2_CONFERI
		Aadd(aEtiqueta,_linha)
		Aadd(aEtiqueta,SF2->F2_VOLUME1)
	EndIf
EndIf

Return(aEtiqueta)

/*
11       2222     33333     44  44    555555     6666   -----------------
111      22  22        33    44  44    55        66  66  | Numero da N.F.|
11          22        33    44  44    55        66      |               |
11         22     33333     444444    55555     66666   |               |
11        22          33        44        55    66  66  |               |
11       22           33        44    55  55    66  66  |               |
111111    222222    33333         44     5555      6666   -----------------

777777     8888      9999      0000       AA
77    88  88    99  99    00  00     AAAA
77     88  88    99  99    00  00    AA  AA
77       8888      99999    00  00    AAAAAA
77       88  88        99    00  00    AA  AA
77        88  88    99  99    00  00    AA  AA
77         8888      9999      0000     AA  AA



11       2222     33333     44  44    555555     6666
11          22        33    44  44    55        66
11         22     33333     444444    55555     66666
11        22          33        44        55    66  66
111111    222222    33333         44     5555      6666

777777     8888      9999      0000       AA
77     88  88    99  99    00  00     AAAA
77       8888      99999    00  00    AAAAAA
77       88  88        99    00  00    AA  AA
77         8888      9999      0000     AA  AA

*/


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณITENSPRENOTAบAutor  ณMicrosiga           บ Data ณ  09/28/06 บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDesc.     ณCarrega os itens da Pre-Nota                                บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ItensPreNota(cNum,cSeparador,aProblema)
Local aItens		:= Array(2,0)
Local aItensAux		:= {}
Local lVLote 		:= !IsInCallStack("DIPM010")
Local cES_CLIVLOT	:= &(SuperGetMv("ES_CLIVLOT",,"''"))
Local nPosCliVal	:= 0
Local nI            := 0       
Local cPiso			:= ""    
Local aProb			:= {}
Local lProblema		:= .F.

SC9->(dbSetOrder(1))
SC9->(dbSeek(xFilial("SC9")+cNum,.T.))

While !Eof() .And. (xFilial("SC9")+cNum == SC9->(C9_FILIAL+C9_PEDIDO))

	If (!Empty(SC9->C9_NFISCAL)) .OR. (!Empty(SC9->C9_BLEST) .and. Len(aProblema) = 0)		
		SC9->(dbSkip())
		Loop           		
	EndIf
	
	SB1->(dbSetOrder(1))
	SB1->(dbSeek(xFilial("SB1")+SC9->C9_PRODUTO))
	
	SC6->(dbSetOrder(1))
	SC6->(dbSeek(xFilial("SC6")+SC9->(C9_PEDIDO+C9_ITEM+C9_PRODUTO)))
	
	SF4->(dbSetOrder(1))
	SF4->(dbSeek(xFilial("SF4")+SC6->C6_TES))
	
	If (SF4->F4_ESTOQUE == "S")
		If Rastro(SC9->C9_PRODUTO) .Or. Localiza(SC9->C9_PRODUTO)
			

			SDC->(dbSetOrder(1))
			SDC->(dbSeek(xFilial("SDC")+SC9->C9_PRODUTO+SC9->C9_LOCAL+"SC6"+SC9->C9_PEDIDO+SC9->C9_ITEM+SC9->C9_SEQUEN,.T.))
			While !SDC->(Eof()) .And. (xFilial("SDC")+SC9->C9_PRODUTO+SC9->C9_LOCAL+"SC6"+SC9->C9_PEDIDO+SC9->C9_ITEM+SC9->C9_SEQUEN ==;
				SDC->(DC_FILIAL+DC_PRODUTO+DC_LOCAL+DC_ORIGEM+DC_PEDIDO+DC_ITEM+DC_SEQ))
			
				cPiso := ""    
				
				SBE->(dbSetOrder(1))				  
				If SBE->(dbSeek(xFilial("SBE")+SDC->(DC_LOCAL+DC_LOCALIZ))) .And. SBE->(FieldPos("BE_XPISO")) > 0
					cPiso := SBE->BE_XPISO
				EndIf
										
				SB8->(dbSetOrder(3))
				SB8->(dbSeek(xFilial("SB8")+SDC->(DC_PRODUTO+DC_LOCAL+DC_LOTECTL+DC_NUMLOTE),.T.))
				
				If (xFilial("SB8")+SDC->(DC_PRODUTO+DC_LOCAL+DC_LOTECTL) == SB8->(B8_FILIAL+B8_PRODUTO+B8_LOCAL+B8_LOTECTL))
					
					If lVLote .And. (nPosCliVal := At( SC9->C9_CLIENTE, cES_CLIVLOT) ) > 0
						nPosCliVal += Len(SC9->C9_CLIENTE)
						If 	Substr(cES_CLIVLOT, nPosCliVal, 1) == ":" .And. ;
							Val(Substr(cES_CLIVLOT, nPosCliVal+1, 4)) > (SC9->C9_DTVALID - dDataBase)
							
							aAdd(aProb,{SC9->C9_ITEM,;
										SC9->C9_SEQUEN,;
										Left(SC9->C9_PRODUTO,6),;
										IIf(cEmpAnt=='04',Transform(0,"@E 999,999.99"),Transform(0,"@E 999,999,999")),;
										SB1->B1_UM,;
										SB1->B1_DESC,;
										"*** ESTORNE O PEDIDO - ESTOQUE COM PROBLEMA ***",;
										Ctod(""),;
										Space(TamSx3("DC_LOCALIZ")[1]),;
										NoRound(SC9->C9_QTDLIB * SC9->C9_PRCVEN,2),;
										SB1->B1_LOTEDIP,;
										SC9->C9_NUMSEP,;
										""})
										
							lProblema := .T.
						EndIf
					EndIf

					aAdd(aItensAux,{SDC->DC_ITEM,;
									SDC->DC_SEQ,;
									Left(SDC->DC_PRODUTO,6),;
									IIf(cEmpAnt=='04',Transform(SDC->DC_QUANT,"@E 999,999.99"),Transform(SDC->DC_QUANT,"@E 999,999,999")),;
									SB1->B1_UM,;
									SB1->B1_DESC,;
									SDC->DC_LOTECTL,;
									SB8->B8_DTVALID,;
									SDC->DC_LOCALIZ,;
									NoRound(SDC->DC_QUANT * SC9->C9_PRCVEN,2),;
									SB1->B1_LOTEDIP,;
									SC9->C9_NUMSEP,;
									cPiso}) // MCVN 28/09/07 INCLUINDO C9_NUMSEP

				Else				
					aAdd(aItensAux,{SDC->DC_ITEM,;
									SDC->DC_SEQ,;
									Left(SDC->DC_PRODUTO,6),;
									IIf(cEmpAnt=='04',Transform(SDC->DC_QUANT,"@E 999,999.99"),Transform(SDC->DC_QUANT,"@E 999,999,999")),;
									SB1->B1_UM,;
									SB1->B1_DESC,;
									Space(TamSx3("DC_LOTECTL")[1]),;
									Ctod(""),;
									SDC->DC_LOCALIZ,;
									NoRound(SDC->DC_QUANT * SC9->C9_PRCVEN,2),;
									SB1->B1_LOTEDIP,;
									SC9->C9_NUMSEP,;
									cPiso}) // MCVN 28/09/07 INCLUINDO C9_NUMSEP
				EndIf				
				
				SDC->(dbSkip())
											
			EndDo
		Else			
			aAdd(aItensAux,{SC9->C9_ITEM,;
							SC9->C9_SEQUEN,;
							Left(SC9->C9_PRODUTO,6),;
							IIf(cEmpAnt=='04',Transform(SC9->C9_QTDLIB,"@E 999,999.99"),Transform(SC9->C9_QTDLIB,"@E 999,999,999")),;
							SB1->B1_UM,;
							SB1->B1_DESC,;
							Space(TamSx3("DC_LOTECTL")[1]),;
							Ctod(""),;
							Space(TamSx3("DC_LOCALIZ")[1]),;
							NoRound(SC9->C9_QTDLIB * SC9->C9_PRCVEN,2),;
							SB1->B1_LOTEDIP,;
							SC9->C9_NUMSEP,;
							""}) // MCVN 28/09/07 INCLUINDO C9_NUMSEP
		EndIf
	Else
		aAdd(aItensAux,{SC9->C9_ITEM,;
						SC9->C9_SEQUEN,;
						Left(SC9->C9_PRODUTO,6),;
						IIf(cEmpAnt=='04',Transform(0,"@E 999,999.99"),Transform(0,"@E 999,999,999")),;
						SB1->B1_UM,;
						SB1->B1_DESC,;
						"NAO SEPARAR",;
						Ctod(""),;
						Space(TamSx3("DC_LOCALIZ")[1]),;
						NoRound(SC9->C9_QTDLIB * SC9->C9_PRCVEN,2),;
						SB1->B1_LOTEDIP,;
						SC9->C9_NUMSEP,;
						""}) // MCVN 28/09/07 INCLUINDO C9_NUMSEP
	EndIf
	
	cSeparador := SC9->C9_SEPARAD
			
	SC9->(dbSkip())
EndDo

If lProblema     
	aItensAux := aClone(aProb)
EndIf    

aItensAux:= aSort(aItensAux,,,{|x,y| x[9] < y[9]})

For nI:=1 to Len(aItensAux)
	If Empty(aItensAux[nI,13]) .Or. aItensAux[nI,13] == 'T'
		aAdd(aItens[1],aItensAux[nI])
	Else
		aAdd(aItens[2],aItensAux[nI])
	EndIf
Next nI

Return(aItens)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณEMAIL   บAutor  ณMicrosiga           บ Data ณ  03/13/07     บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function EMailPre(cEmail,cAssunto,aMsg1,aAttach)

Local cAccount  := Lower(Alltrim(GetMv("MV_RELACNT")))
Local cFrom     := Lower(Alltrim(GetMv("MV_RELACNT")))
Local cPassword := Alltrim(GetMv("MV_RELPSW"))
Local cServer   := Alltrim(GetMv("MV_RELSERV"))
Local cEmailTo  := ""
Local cEmailCc  := Lower(aMsg1[1,13])
Local cEmailBcc := ""
Local lResult   := .F.
Local cError    := ""
Local cMsg      := ""
Local nTot_Ped := 0
Local nI               
LOCAL lSmtpAuth := GetNewPar("MV_RELAUTH",.F.)
LOCAL lAutOk	:= .F.

If !Empty(AllTrim(POSICIONE("SU7",1,XFILIAL("SU7")+AllTrim(aMsg1[1,17]),"U7_EMAIL"))) .And. !Empty(AllTrim(POSICIONE("SU7",1,XFILIAL("SU7")+AllTrim(aMsg1[1,17]),"U7_SENHA")))
	cAccount  := AllTrim(POSICIONE("SU7",1,XFILIAL("SU7")+AllTrim(aMsg1[1,17]),"U7_EMAIL"))
	cFrom     := AllTrim(POSICIONE("SU7",1,XFILIAL("SU7")+AllTrim(aMsg1[1,17]),"U7_EMAIL"))
	cPassword := AllTrim(POSICIONE("SU7",1,XFILIAL("SU7")+AllTrim(aMsg1[1,17]),"U7_SENHA"))
EndIf	

/*=============================================================================*/
/*Definicao do cabecalho do email                                              */
/*=============================================================================*/
cMsg := ""
cMsg += '<html>'
cMsg += '<head>'
cMsg += '<title>' + cAssunto + '</title>'
cMsg += '</head>'
cMsg += '<body>'
cMsg += '<HR Width=85% Size=3 Align=Centered Color=Red> <P>'
cMsg += '<Table Align=Center BorderColor=#000000 CELLPADDING=4 CELLSPACING=0 Width=60%>'

/*=============================================================================*/
/*Definicao do cabecalho do relat๓rio                                          */
/*=============================================================================*/

cMsg += '<table width="100%">'
cMsg += '<tr>'
cMsg += '<td width="100%" colspan="2"><font size="4" color="red">Pedido - ' + aMsg1[1,1] + '</font></td>'
cMsg += '</tr>'
cMsg += '<tr>'
cMsg += '<td width="80%"><font size="2" color="blue">Cliente: ' +  [1,8] + "-" + aMsg1[1,9] + "-" + aMsg1[1,10] + '</font></td>'
cMsg += '<td width="40%" align="right"><font size="3" color="red">Estado: ' + aMsg1[1,11] + '</font></td>'
cMsg += '</tr>'
//If Len(aMsg1)>15  //FELIPE DURAN - Retirado validacao para sempre levar a transportadora
	cMsg += '<tr>'
	cMsg += '<td width="100%"><font size="2" color="blue">Transportadora: '+aMsg1[1,16]+" - "+Alltrim(Posicione("SA4",1,xFilial("SA4")+aMsg1[1,16],"A4_NOME" ))+'</font></td>'
	cMsg += '</tr>'
//EndIf
cMsg += '</table>'


cMsg += '<table width="100%" cellspacing="0" cellpadding="0"><font size="2" color="blue">'
cMsg += '<tr>'
cMsg += '<td>===============================================================================================================</td>'
cMsg += '</tr>'
cMsg += '</font></table>'

cMsg += '<table width="100%" cellspacing="0" cellpadding="0"><font size="2" color="blue">'
cMsg += '<td width="80%">C๓digo - Descri็ใo</td>'
cMsg += '<td width="20%" align="right">Valor</td>'
cMsg += '</tr>'
cMsg += '</font></table>'

cMsg += '<table width="100%" cellspacing="0" cellpadding="0"><font size="2" color="blue">'
cMsg += '<tr>'
cMsg += '<td>===============================================================================================================</td>'
cMsg += '</tr>'
cMsg += '</font></table>'

/*=============================================================================*/
/*Definicao do texto/detalhe do email                                          */
/*=============================================================================*/


For nI := 1 to Len(aMsg1)
	nLin:= nI
	nTot_Ped += aMsg1[nLin,7]
	If Mod(nLin,2) == 0
		cMsg += '<table width="100%" border="0" cellspacing="0" cellpadding="0">'
		cMsg += '<tr BgColor="#B0E2FF">'
		cMsg += '<td width="80%"><font size="2">' + aMsg1[nLin,3] + ' - ' + aMsg1[nLin,4] + '</font></td>'
		cMsg += '<td width="20%" align="right"><font size="2">' + Transform(aMsg1[nLin,7],"@E 999,999,999.99") + '</font></td>'
		cMsg += '</tr>'
		cMsg += '</table>'
	Else
		cMsg += '<table width="100%" border="0" cellspacing="0" cellpadding="0">'
		cMsg += '<tr bgcolor="#c0c0c0">'
		cMsg += '<td width="80%"><font size="2">' + aMsg1[nLin,3] + ' - ' + aMsg1[nLin,4] + '</font></td>'
		cMsg += '<td width="20%" align="right"><font size="2">' + Transform(aMsg1[nLin,7],"@E 999,999,999.99") + '</font></td>'
		cMsg += '</tr>'
		cMsg += '</table>'
	EndIf
Next

cMsg += '<table width="100%" cellspacing="5" cellpadding="0">'
cMsg += '<tr BgColor=#FFFF80>'
cMsg += '<td width="33%" align="right"><font color="red" size="2">Frete: ' + Transform(aMsg1[1,14],"@E 999,999,999.99") + '</font></td>'
cMsg += '<td width="33%" align="right"><font color="red" size="2">Despesas: ' + Transform( aMsg1[1,15]-aMsg1[1,12],"@E 999,999,999.99") + '</font></td>'
cMsg += '<td width="33%" align="right"><font color="red" size="2">Total dos Produtos: ' + Transform(nTot_Ped,"@E 999,999,999.99") + '</font></td>'
cMsg += '</tr>'
cMsg += '<tr BgColor=#FFFF80>'
cMsg += '<td width="33%" align="right"><font color="red" size="2">Substitui็ใo Tributแria: ' + Transform(aMsg1[1,12],"@E 999,999,999.99") + '</font></td>'
cMsg += '<td width="33%" align="right"></td>'
cMsg += '<td width="33%" align="right"><font color="red" size="2">Total do Pedido: ' + Transform(aMsg1[1,14]+aMsg1[1,15]+nTot_Ped,"@E 999,999,999.99") + '</font></td>'
cMsg += '</tr>'
cMsg += '</table>'

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Definicao do rodape do email                                                ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
cMsg += '</Table>'
cMsg += '<HR Width=85% Size=3 Align=Centered Color=Red> <P>'
cMsg += '<table width="100%" Align="Center" border="0">'
cMsg += '<tr align="center">'
cMsg += '<td colspan="10"><font color="BLUE" size="2">Mensagem enviada automaticamente pelo sistema PROTHEUS - <font color="BLUE" size="1">(PRENOTA.PRW)</td>'
cMsg += '</tr>'
cMsg += '</table>'
cMsg += '</body>'
cMsg += '</html>'

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณEnvia o mail para a lista selecionada. Envia como BCC para que a pessoa penseณ
//ณque somente ela recebeu aquele email, tornando o email mais personalizado.   ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
IF At(";",cEmail) > 0
	cEmailTo := SubStr(cEmail,1,At(";",cEmail)-1)
	cEmailCc := SubStr(cEmail,At(";",cEmail)+1,Len(cEmail))
Else
	cEmailTo := Alltrim(cEmail)
EndIF

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
	TO      	Lower(cValToChar(cEmailTo));
	CC      	Lower(cValToChar(cEmailCc));
	BCC     	Lower(cEmailBcc);
	SUBJECT 	cAssunto;
	BODY    	cMsg;
	RESULT lResult
	
	If !lResult
		//Erro no envio do email
		GET MAIL ERROR cError
		
		MsgInfo(cError,OemToAnsi("Aten็ใo"))
	EndIf
	
	DISCONNECT SMTP SERVER
Else
	//Erro na conexao com o SMTP Server
	GET MAIL ERROR cError
	MsgInfo(cError,OemToAnsi("Aten็ใo"))
EndIf

Return(.T.)



User Function EMail2(cEmail,cAssunto,aMsg,aAttach)

Local cAccount  := Lower(Alltrim(GetMv("MV_RELACNT")))
Local cFrom     := Lower(Alltrim(GetMv("MV_RELACNT")))
Local cPassword := Alltrim(GetMv("MV_RELPSW"))
Local cServer   := Alltrim(GetMv("MV_RELSERV"))
Local cEmailTo  := ""
Local cEmailCc  := aMsg[1,38]
Local cEmailBcc := ""
Local lResult   := .F.
Local cError    := ""
Local cMsg      := ""
Local nTot_Ped := 0
Local nI               
LOCAL lSmtpAuth := GetNewPar("MV_RELAUTH",.F.)
LOCAL lAutOk	:= .F.

/*=============================================================================*/
/*Definicao do cabecalho do email                                              */
/*=============================================================================*/
cMsg := ""
cMsg += '<html>'
cMsg += '<head>'
cMsg += '<title>' + cAssunto + '</title>'
cMsg += '</head>'
cMsg += '<body>'
cMsg += '<HR Width=85% Size=3 Align=Centered Color=Red> <P>'
cMsg += '<Table Align=Center BorderColor=#000000 CELLPADDING=4 CELLSPACING=0 Width=60%>'

/*=============================================================================*/
/*Definicao do cabecalho do relat๓rio                                          */
/*=============================================================================*/

cMsg += ' <table width="100%">'
cMsg += ' <tr>'
cMsg += ' <td width="100%"><font size="4" color="red">Pedido - ' + aMsg[1,4] + '  /   Operador: '+ aMsg[1,6]+' - '+Alltrim(Posicione("SU7",1,xFilial("SU7")+aMsg[1,6],"U7_NOME")) +'</font></td>'
cMsg += ' </tr>'
cMsg += ' <tr>'
cMsg += ' <td width="100%"><font size="2" color="blue">Cliente - ' + aMsg[1,1] + "-" + aMsg[1,2] + "-" + aMsg[1,3] + '</font></td>'
cMsg += ' </tr>'
cMsg += ' </table>'


cMsg += ' <table width="100%" cellspacing="0" cellpadding="0">'
cMsg += ' <tr BgColor="#B0E2FF">'
cMsg += ' <td>============================================================================================================</td>'
cMsg += ' </tr>'
cMsg += ' </table>'

cMsg += ' <table width="100%" cellspacing="0" cellpadding="0">'
cMsg += ' <tr BgColor="#B0E2FF">'
cMsg += ' <td width="8%" align="left"><font size="2">Pedido</font></td>'
cMsg += ' <td width="8%" align="left"><font size="2">Emissใo</font></td>'
cMsg += ' <td width="8%" align="right"><font size="2">Marg.Atual</font></td>'
cMsg += ' <td width="8%" align="right"><font size="2">Marg.Lib.</font></td>'
cMsg += ' <td width="3%" align="center"></td>'
cMsg += ' <td width="8%" align="left"><font size="2">TES</font></td>'
cMsg += ' <td width="8%" align="left"><font size="2">Margem</font></td>'
cMsg += ' <td width="8%" align="left"><font size="2">Pagamento</font></td>'
cMsg += ' <td width="8%" align="left"><font size="2">Cond.Pgto.</font></td>'
cMsg += ' </tr>'
cMsg += ' <tr BgColor="#B0E2FF">'
cMsg += ' <td colspan="9">============================================================================================================</td>'
//cMsg += ' <td colspan="9">-------------------------------------------------------------------------------------------------------------------------</td>'
cMsg += ' </tr>'
cMsg += ' <tr BgColor="#B0E2FF">'
cMsg += ' <td width="8%" align="left"><font size="2">' + aMsg[1,4] + '</font></td>'
cMsg += ' <td width="8%" align="left"><font size="2">' + SubStr(aMsg[1,5],7,2) + '/' + SubStr(aMsg[1,5],5,2) + '/' + SubStr(aMsg[1,5],1,4) + '</font></td>'
If aMsg[1,7] <= aMsg[1,8]
	cMsg += ' <td width="8%" align="right"><font size="2" color="red">' + Transform(aMsg[1,7],"@E 999.999") + '</font></td>'
Else
	cMsg += ' <td width="8%" align="right"><font size="2">' + Transform(aMsg[1,7],"@E 999.999") + '</font></td>'
EndIf
cMsg += ' <td width="8%" align="right"><font size="2">' + Transform(aMsg[1,8],"@E 999.999") + '</font></td>'
cMsg += ' <td width="3%" align="center"></td>'
cMsg += ' <td width="8%" align="left"><font size="2">' + aMsg[1,11] + '</font></td>'
cMsg += ' <td width="8%" align="left"><font size="2">' + aMsg[1,9] + '</font></td>'
cMsg += ' <td width="8%" align="left"><font size="2">' + aMsg[1,10] + '</font></td>'
cMsg += ' <td width="8%" align="left"><font size="2">' + aMsg[1,43] + '</font></td>'
//cMsg += ' <td width="8%" align="right"><font size="2">' + Transform(aMsg[1,39],"@E 999.999") + '</font></td>' // Emerson - 10/06/2020
cMsg += ' </tr>'
cMsg += ' <tr BgColor="#B0E2FF">'
cMsg += ' <td width="100%" colspan="9"><font size="2">Explica็ใo: ' + aMsg[1,13] + '</font></td>'
cMsg += ' </tr>'
if !Empty(aMsg[1,40]) .or.!Empty(aMsg[1,41]) .or.!Empty(aMsg[1,42]) .or.!Empty(aMsg[1,43])
	cMsg += ' <tr BgColor="#B0E2FF">'
	cMsg += ' <td width="100%" colspan="9"><font size="2">Vencimentos: ' + ;
	SubStr(aMsg[1,40],7,2) + '/' + SubStr(aMsg[1,40],5,2) + '/' + SubStr(aMsg[1,44],1,4) + " - " + ;
	SubStr(aMsg[1,41],7,2) + '/' + SubStr(aMsg[1,41],5,2) + '/' + SubStr(aMsg[1,45],1,4) + " - " + ;
	SubStr(aMsg[1,42],7,2) + '/' + SubStr(aMsg[1,42],5,2) + '/' + SubStr(aMsg[1,46],1,4) + " - " + ;
	SubStr(aMsg[1,43],7,2) + '/' + SubStr(aMsg[1,43],5,2) + '/' + SubStr(aMsg[1,47],1,4) + '</font></td>'
	//aMsg[1,40] + " - " + aMsg[1,41] + " - " + aMsg[1,42] + " - " + aMsg[1,43] + '</font></td>'
	cMsg += ' </tr>'
EndIf
cMsg += ' </table>'

cMsg += ' <table width="100%" border="0" cellspacing="0" cellpadding="0">'
cMsg += ' <tr BgColor="#B0E2FF">'
cMsg += ' <td>============================================================================================================</td>'
cMsg += ' </tr>'
cMsg += ' </table>'
//        1                2                3                4                5                6                7                8                9                10                11                12                13              14             15             16                17                18               19              20                21                22              23                24               25                26              27          28                29               30                31           32              33                34                35	            36                 37           38             39            40                41               42            43              44              45               46               47             48               49               
// QRY1->C5_CLIENTE, QRY1->C5_LOJACLI, QRY1->A1_NOME, QRY1->C5_NUM, QRY1->C5_EMISSAO, QRY1->C5_OPERADO, QRY1->C5_MARGATU, QRY1->C5_MARGLIB, QRY1->C5_SENHMAR, QRY1->C5_SENHPAG, QRY1->C5_SENHTES, QRY1->C5_SENHCID, QRY1->C5_EXPLSEN, QRY1->C5_DATA1, QRY1->C5_PARC1, QRY1->C5_DATA2, QRY1->C5_PARC2, QRY1->C5_DATA3, QRY1->C5_PARC3, QRY1->C5_DATA4, QRY1->C5_PARC4,                                                                 QRY1->C6_PRODUTO, QRY1->C6_MARGATU, QRY1->C6_MARGITE, QRY1->C6_QTDVEN, QRY1->C6_PRCVEN, QRY1->C6_CUSTO, QRY1->C6_PRCMIN, QRY1->C6_NOTA, QRY1->C6_VALOR, QRY1->B1_DESC, QRY1->B1_UCOM, QRY1->B1_UPRC, QRY1->B1_PRVMINI, QRY1->B1_PRVSUPE, QRY1->B1_ALTPREC, QRY1->U7_NREDUZ, QRY1->U7_EMAIL, QRY1->E4_DESCRI
// QRY1->C5_CLIENTE, QRY1->C5_LOJACLI, QRY1->A1_NOME, QRY1->C5_NUM, QRY1->C5_EMISSAO, QRY1->C5_OPERADO, QRY1->C5_MARGATU, QRY1->C5_MARGLIB, QRY1->C5_SENHMAR, QRY1->C5_SENHPAG, QRY1->C5_SENHTES, QRY1->C5_SENHCID, QRY1->C5_EXPLSEN, QRY1->C5_DATA1, QRY1->C5_PARC1, QRY1->C5_DATA2, QRY1->C5_PARC2, QRY1->C5_DATA3, QRY1->C5_PARC3, QRY1->C5_DATA4, QRY1->C5_PARC4, QRY1->C5_DATA5, QRY1->C5_PARC5, QRY1->C5_DATA6, QRY1->C5_PARC6, QRY1->C6_PRODUTO, QRY1->C6_MARGATU, QRY1->C6_MARGITE, QRY1->C6_QTDVEN, QRY1->C6_PRCVEN, QRY1->C6_CUSTO, QRY1->C6_PRCMIN, QRY1->C6_NOTA, QRY1->C6_VALOR, QRY1->B1_DESC, QRY1->B1_UCOM, QRY1->B1_UPRC, QRY1->B1_PRVMINI, QRY1->B1_PRVSUPE, QRY1->B1_ALTPREC, QRY1->U7_NREDUZ, QRY1->U7_EMAIL, QRY1->E4_DESCRI, QRY1->C5_DATA1, QRY1->C5_DATA2, QRY1->C5_DATA3, QRY1->C5_DATA4, QRY1->C5_DATA5, QRY1->C5_DATA6

cMsg += ' <table width="100%" border="0" cellspacing="0" cellpadding="0">' 
cMsg += ' <tr bgcolor="#c0c0c0">'
cMsg += ' <td width="84%" colspan="6"><font size="2">Produto</font></td>'
cMsg += ' <td width="8%"><font size="2">ฺlt. Entrada</font></td>'
cMsg += ' <td width="8%"><font size="2">ฺlt. Alter.</font></td>'
cMsg += ' </tr>'
cMsg += ' <tr bgcolor="#c0c0c0">'
cMsg += ' <td width="8%" align="right"><font size="2">Marg. Atual</font></td>'
cMsg += ' <td width="8%" align="right"><font size="2">Marg. Liber.</font></td>'
cMsg += ' <td width="8%" align="right"><font size="2">Quantidade</font></td>'
cMsg += ' <td width="8%" align="right"><font size="2">Pre็o</font></td>'
cMsg += ' <td width="8%" align="right"><font size="2">Total</font></td>'
cMsg += ' <td width="8%" align="right"><font size="2">Menor Pre็o</font></td>'
cMsg += ' <td width="8%" align="right"><font size="2">Custo</font></td>'
cMsg += ' </tr>'
cMsg += ' <tr BgColor="#c0c0c0">'
cMsg += ' <td colspan="8">============================================================================================================</td>'
//	cMsg += ' <td colspan="8">-------------------------------------------------------------------------------------------------------------------------</td>'
cMsg += ' </tr>'
cMsg += ' </table>'

nTot_Ped := 0

For nI := 1 to Len(aMsg)
	nLin := nI
	If Mod(nLin,2) == 0
		cMsg += ' <table width="100%" border="0" cellspacing="0" cellpadding="0">'
		cMsg += ' <tr BgColor="#B0E2FF">'
		cMsg += ' <td width="84%" colspan="6"><font size="2">' + aMsg[nLin,26]+'-'+aMsg[nLin,35] + '</font></td>'
		cMsg += ' <td width="8%"><font size="2">' + SubStr(aMsg[nLin,36],7,2) + '/' + SubStr(aMsg[nLin,36],5,2) + '/' + SubStr(aMsg[nLin,36],1,4) + '</font></td>'
		cMsg += ' <td width="8%"><font size="2">' + SubStr(aMsg[nLin,40],7,2) + '/' + SubStr(aMsg[nLin,40],5,2) + '/' + SubStr(aMsg[nLin,40],1,4) + '</font></td>'
		cMsg += ' </tr>'
		cMsg += ' <tr BgColor="#B0E2FF">'
		//If aMsg[nLin,23] <= aMsg[nLin,24]
		If aMsg[nLin,23] <= aMsg[nLin,25]
			cMsg += ' <td width="8%" align="right"><font size="2" color="red">' + Transform(aMsg[nLin,27]*20,"@E 999.999") + '</font></td>'
		Else
			cMsg += ' <td width="8%" align="right"><font size="2">' + Transform(aMsg[nLin,27]*20,"@E 999.999") + '</font></td>'
		EndIf
		cMsg += ' <td width="8%" align="right"><font size="2">' + Transform(aMsg[nLin,28]*20,"@E 999.999") + '</font></td>'
		cMsg += ' <td width="8%" align="right"><font size="2">' + Transform(aMsg[nLin,29],"@E 999,999,999") + '</font></td>'
		cMsg += ' <td width="8%" align="right"><font size="2">' + Transform(aMsg[nLin,28],"@E 999,999.9999") + '</font></td>'
		cMsg += ' <td width="8%" align="right"><font size="2">' + Transform(aMsg[nLin,30],"@E 999,999.9999") + '</font></td>'
		cMsg += ' <td width="8%" align="right"><font size="2">' + Transform(Iif(aMsg[nLin,39]==0,aMsg[nLin,38],aMsg[nLin,39]),"@E 999,999.9999") + '</font></td>'
		cMsg += ' <td width="8%" align="right"><font size="2">' + Transform(aMsg[nLin,31],"@E 999,999.9999") + '</font></td>'
		cMsg += ' </tr>'
		cMsg += ' </table>'
	Else
		cMsg += ' <table width="100%" border="0" cellspacing="0" cellpadding="0">'
		cMsg += ' <tr bgcolor="#c0c0c0">'
		cMsg += ' <td width="84%" colspan="6"><font size="2">' + aMsg[nLin,26]+'-'+aMsg[nLin,35] + '</font></td>'
		//cMsg += ' <td width="84%" colspan="6"><font size="2">' + aMsg[nLin,22]+'-'+Transform(aMsg[nLin,31],"@E 999,999.9999") + '</font></td>'
		cMsg += ' <td width="8%"><font size="2">' + SubStr(aMsg[nLin,36],7,2) + '/' + SubStr(aMsg[nLin,36],5,2) + '/' + SubStr(aMsg[nLin,36],1,4) + '</font></td>'
		cMsg += ' <td width="8%"><font size="2">' + SubStr(aMsg[nLin,40],7,2) + '/' + SubStr(aMsg[nLin,40],5,2) + '/' + SubStr(aMsg[nLin,40],1,4) + '</font></td>'
		cMsg += ' </tr>'
		cMsg += ' <tr bgcolor="#c0c0c0">'
		//If aMsg[nLin,23] <= aMsg[nLin,24]
		If aMsg[nLin,23] <= aMsg[nLin,25]
			cMsg += ' <td width="8%" align="right"><font size="2" color="red">' + Transform(aMsg[nLin,27]*20,"@E 999.999") + '</font></td>'
		Else
			cMsg += ' <td width="8%" align="right"><font size="2">' + Transform(aMsg[nLin,27]*20,"@E 999.999") + '</font></td>'
		EndIf
		cMsg += ' <td width="8%" align="right"><font size="2">' + Transform(aMsg[nLin,28]*20,"@E 999.999") + '</font></td>'
		cMsg += ' <td width="8%" align="right"><font size="2">' + Transform(aMsg[nLin,29],"@E 999,999,999") + '</font></td>'
		cMsg += ' <td width="8%" align="right"><font size="2">' + Transform(aMsg[nLin,30],"@E 999,999.9999") + '</font></td>'
		cMsg += ' <td width="8%" align="right"><font size="2">' + Transform(aMsg[nLin,31],"@E 999,999.9999") + '</font></td>'
		cMsg += ' <td width="8%" align="right"><font size="2">' + Transform(Iif(aMsg[nLin,39]==0,aMsg[nLin,38],aMsg[nLin,39]),"@E 999,999.9999") + '</font></td>'
		cMsg += ' <td width="8%" align="right"><font size="2">' + Transform(aMsg[nLin,31],"@E 999,999.9999") + '</font></td>'
		cMsg += ' </tr>'
		cMsg += ' </table>'
	EndIf
	
	nTot_Ped += aMsg[nLin,34]
Next

cMsg += ' <table width="100%" border="0" cellspacing="0" cellpadding="0">'
cMsg += ' <tr BgColor="#B0E2FF">'
cMsg += ' <td width="84%" colspan="6"><font size="2"></font></td>'
cMsg += ' <td width="8%"><font size="2"></font></td>'
cMsg += ' <td width="8%"><font size="2"></font></td>'
cMsg += ' </tr>'
cMsg += ' <tr BgColor="#B0E2FF">'
cMsg += ' <td width="8%" align="right"><font size="2"></font></td>'
cMsg += ' <td width="8%" align="right"><font size="2"></font></td>'
cMsg += ' <td width="8%" align="right"><font size="2"></font></td>'
cMsg += ' <td width="8%" align="left"><font size="2">Total do Pedido:</font></td>'
cMsg += ' <td width="8%" align="right"><font size="2">' + Transform(nTot_Ped,"@E 999,999.9999") + '</font></td>'
cMsg += ' <td width="8%" align="right"><font size="2"></font></td>'
cMsg += ' <td width="8%" align="right"><font size="2"></font></td>'
cMsg += ' </tr>'
cMsg += ' </table>'

cMsg += '<table width="100%" border="0" cellspacing="0" cellpadding="0">'
cMsg += '<tr BgColor="#B0E2FF">'
cMsg += '<td>=============================================================================================================</td>'
cMsg += '</tr>'
cMsg += '</table>'


//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Definicao do rodape do email                                                ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
cMsg += '</Table>'
cMsg += '<HR Width=85% Size=3 Align=Centered Color=Red> <P>'
cMsg += '<table width="100%" Align="Center" border="0">'
cMsg += '<tr align="center">'
cMsg += '<td colspan="10"><font color="BLUE" size="2">Mensagem enviada automaticamente pelo sistema PROTHEUS - <font color="BLUE" size="1">(PRENOTA.PRW)</td>'
cMsg += '</tr>'
cMsg += '</table>'
cMsg += '</body>'
cMsg += '</html>'

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณEnvia o mail para a lista selecionada. Envia como BCC para que a pessoa penseณ
//ณque somente ela recebeu aquele email, tornando o email mais personalizado.   ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
IF At(";",cEmail) > 0
	cEmailTo := SubStr(cEmail,1,At(";",cEmail)-1)
	cEmailCc := SubStr(cEmail,At(";",cEmail)+1,Len(cEmail))
Else
	cEmailTo := Alltrim(cEmail)
EndIF

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
	TO      	Lower(cValToChar(cEmailTo));
	CC      	Lower(cValToChar(cEmailCc));
	BCC     	Lower(cEmailBcc);
	SUBJECT 	cAssunto;
	BODY    	cMsg;
	RESULT lResult
	
	If !lResult
		//Erro no envio do email
		GET MAIL ERROR cError
		
		MsgInfo(cError,OemToAnsi("Aten็ใo"))
	EndIf
	
	DISCONNECT SMTP SERVER
Else
	//Erro na conexao com o SMTP Server
	GET MAIL ERROR cError
	MsgInfo(cError,OemToAnsi("Aten็ใo"))
EndIf

Return(.T.)

*-------------------------------*
Static Function DIPR059Cabec()
*-------------------------------*
local b_lin :={|valor,ind| F_Ler_Tab(R_Campos,ind)}
Local tamanho :="M"
Local nAsterisco:=132

If Linha>55
	Cabec(titulo,cabec1,cabec2,nomeprog,tamanho,GetMv("MV_COMP"))
	If Empty(cabec1) .And. Empty(cabec2)
		@ PROW()+1,T_Len[1,2]-1 PSAY REPLI('*',nAsterisco)
	Endif
	Linha:=PROW()+1 ; l_tag:=say_tit
	AEVAL(R_Campos, b_lin)
	Linha++ ; l_tag:=say_rep
	AEVAL(R_Campos, b_lin)
Endif
RETURN(.T.)




//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณFun็ใo para buscar no Kardex do pedido informa็๕es referentes libera็ใo do pedido e libera็ใo de cr้dito do pedido.ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
*-------------------------------*
Static Function PrenotaSz9()  // MCVN 24/01/08
*-------------------------------*
Local _x
Local nCount:=200


Query := "SELECT "
Query += " Z9_PEDIDO, "
//Query += " SUBSTRING(Z9_DATAMOV,7,2)+'/'+SUBSTRING(Z9_DATAMOV,5,2)+'/'+SUBSTRING(Z9_DATAMOV,1,4) Z9_DATAMOV, "
Query += " Z9_DATAMOV, "
Query += " Z9_HORAMOV, "
Query += " Z9_OCORREN "
Query += " FROM  "+RetSQLName('SZ9')
Query += " WHERE "+RetSQLName("SZ9")+".D_E_L_E_T_ <> '*'"
Query += " AND Z9_FILIAL = '" + xFilial('SZ9') + "'"
Query += " AND Z9_PEDIDO = '"+ SC5->C5_NUM + "'"
Query += " AND Z9_OCORREN IN ('10','16','26')"

Query += " ORDER BY Z9_DATAMOV, Z9_HORAMOV, Z9_PEDIDO,Z9_OCORREN

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

DbCommitAll()
TcQuery Query NEW ALIAS "QRYSZ9"
QRYSZ9->(dbGotop())

dDtLib     := ""
cHrLib     := ""
dDtLibCred := ""
cHrLibCred := ""


Do While QRYSZ9->(!EOF())
	
	If QRYSZ9->Z9_OCORREN = "10" .OR. QRYSZ9->Z9_OCORREN = "16"
		dDtLib := SUBSTRING(QRYSZ9->Z9_DATAMOV,7,2)+'/'+SUBSTRING(QRYSZ9->Z9_DATAMOV,5,2)+'/'+SUBSTRING(QRYSZ9->Z9_DATAMOV,3,2)
		cHrLib := Left(QRYSZ9->Z9_HORAMOV,5)
	EndIf
	
	If QRYSZ9->Z9_OCORREN = "26"
		dDtLibCred := SUBSTRING(QRYSZ9->Z9_DATAMOV,7,2)+'/'+SUBSTRING(QRYSZ9->Z9_DATAMOV,5,2)+'/'+SUBSTRING(QRYSZ9->Z9_DATAMOV,3,2)
		cHrLibCred := Left(QRYSZ9->Z9_HORAMOV,5)
	EndIf
	
	QRYSZ9->(dbSkip())
Enddo

dbSelectArea("QRYSZ9")
QRYSZ9->(dbCloseArea())

RETURN(.T.)


/*BEGINDOC
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ`ฟ
//ณFun็ใo para buscar Rota de Transporte do pedido                                     ||
//ณMaximo Canuto  - 05/10/10														   ||
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ`ู
ENDDOC
*/

Static Function FindRotaZv(nCepCli)
Local QRY2    := ""
Local QRY3    := ""
Local cRota   := ""
Local cNumRota:= ""
Local _xAlias := GetArea()

QRY2 := "SELECT ZV_TRANSP, ZV_VIAGEM, ZV_NUMROTA "
QRY2 += " FROM " + RetSQLName("SZV")
QRY2 += " WHERE ZV_CEPINI <= '" + nCepCli + "'"
QRY2 += " AND ZV_CEPFIM >= '" + nCepCli + "'"
QRY2 += " AND ZV_TRANSP = '100000' "
QRY2 += " AND " + RetSQLName("SZV") + ".D_E_L_E_T_ = '' "
QRY2 += " ORDER BY ZV_TRANSP"

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
TcQuery QRY2 NEW ALIAS "QRY2"         // Abre uma workarea com o resultado da query
memowrite('szvprenota.SQL',QRY2)

DbSelectArea("QRY2")
QRY2->(dbGotop())
cNumRota := Alltrim(QRY2->ZV_NUMROTA)
QRY2->(dbSkip())


DbSelectArea("QRY2")
QRY2->(DbCloseArea())


//////////////////////////////////////////////////////////////
//Buscando nome da Rota no TMS - Tabela  DA8030
/////////////////////////////////////////////////////////////

QRY3 := "SELECT DA8_DESC "
QRY3 += " FROM DA8030 "
QRY3 += " WHERE DA8030.D_E_L_E_T_ = '' "
QRY3 += " AND DA8_COD = '" + cNumRota + "'"
QRY3 += " ORDER BY DA8_COD "

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
TcQuery QRY3 NEW ALIAS "QRY3"         // Abre uma workarea com o resultado da query
memowrite('NomeRota.SQL',QRY3)

DbSelectArea("QRY3")
QRY3->(dbGotop())
cRota := Alltrim(QRY3->DA8_DESC)
QRY3->(dbSkip())


DbSelectArea("QRY3")
QRY3->(DbCloseArea())

RestArea(_xAlias)
Return(cRota)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณMAItens  บAutor  ณMicrosiga           บ Data ณ  05/26/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Retorna um array com produtos do fornecedor Steri-Pack     บฑฑ
ฑฑบ          ณ para tratamento especifico                                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function MAItens(cPedido)
Local aArea 	:= GetArea()
Local cQryAux	:= ""
Local cAliasMA	:= GetNextAlias()
Local aProdMA 	:= {}

cQryAux := " SELECT DISTINCT B1_COD, B1_CODANT FROM " + RetSqlName("SC9") + " C9 "
cQryAux += " JOIN " + RetSqlName("SB1") + " B1 ON "
cQryAux += "    B1.B1_FILIAL      = '" + xFilial("SB1") + "'"
cQryAux += "    AND B1.B1_COD     = C9.C9_PRODUTO"
cQryAux += "    AND B1.B1_PROC    = '000997'"  
// cQryAux += "    AND B1.B1_CODANT  = ' '"
cQryAux += "	AND B1.D_E_L_E_T_ = ' '"
cQryAux += " WHERE  C9.C9_FILIAL  = '" + xFilial("SC9") + "'"
cQryAux += "	AND C9.C9_PEDIDO  = '" + cPedido + "'" 
cQryAux += " 	AND C9.C9_LOTECTL IN ('070301','070302','070303','070304','085955') "
cQryAux += "    AND C9.C9_PRODUTO = '089024' "
cQryAux += "	AND C9.D_E_L_E_T_ = ' '"

DbCommitAll()
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQryAux),cAliasMA,.T.,.T.)
(cAliasMA)->(DbEval({|| aAdd( aProdMA, { B1_COD, B1_CODANT } ) }))
(cAliasMA)->(DbCloseArea())

RestArea( aArea )

Return aProdMA


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณMAItens  บAutor  ณMicrosiga           บ Data ณ  05/26/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Retorna um array com produtos do fornecedor Steri-Pack     บฑฑ
ฑฑบ          ณ para tratamento especifico                                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function PrnMA(aProdMA, m_pag, nTotPag, cTitulo2 )

Local cTitulo:= "PRE-NOTA N. "+SC5->C5_NUM
Local nSpace   := nCols - (Len(cTitulo2) + Len(cTitulo))
Local cNomeRota:= ""
Local nCol     := 0
Local cPrn     := ""
Local nI
Local cMsgMA   := ""
//Local cCicPack  := "MAXIMO.CANUTO,NOTAFISCAL,"
Local cCicMA	:= "MAXIMO.CANUTO,NOTAFISCAL,DIEGO.DOMINGOS,VALDO.ZAVATTI"

If Empty(cTitulo2)
	cTitulo2 := "Aten็ใo!!! Esta Pr้-Nota cont้m Produtos Medical Action!!!"
	nSpace   := nCols - (Len(cTitulo2) + Len(cTitulo))
EndIf

SetPrc(0,0)
// Busca no Z9 data e hora de libera็ใo e libera~]ao de cr้dito  -   MCVN 24/01/2007
PrenotaSz9()
// Buscando a rota  -   MCVN 05/10/10
If Empty(Alltrim(cNomeRota))
	cNomeRota:=FindRotaZv(SC5->C5_CEPE)
Endif

@ 00,000 PSAY chr(15)
@ 01,002 PSAY Replicate("-",nCols)
@ 02,002 PSAY cTitulo
@ 02,022 PSAY Space((nSpace-22)/2) + cTitulo2
If aReturn[5] == 3 // MCVN - 13/09/2007
	@ 02,132 PSAY "Pag. " + Str(m_pag,2)+' /'+Str(nTotPag,2)
Else
	@ 02,122 PSAY "Pag. " + Str(m_pag,2)+' /'+Str(nTotPag,2)
Endif
@ 03,002 PSAY Replicate("-",nCols)
@ 04,002 PSAY Space((nCols-6)-Len(Alltrim(cNomeRota))) + If(Len(Alltrim(cNomeRota))>0,"ROTA: " + cNomeRota, "")
@ 05,002 PSAY "Mensagem para o DEPOSITO: " + SC5->C5_MENDEP

@ 07,002 PSAY "Observacao do Cliente   : " + Posicione("SA1",1,xFilial("SA1")+SC5->(C5_CLIENTE+C5_LOJACLI),"A1_OBSPRE")

@ 09,002 PSAY "Emitido em  : "   + DTOC(SC5->C5_EMISSAO)+' as '+SC5->C5_HORA
@ 09,065 PSAY "Impresso dia  : " + DTOC(dDatabase) + " as " + SUBSTR(Time(),1,5)+'  Por: '+Upper(U_DipUsr())

@ 10,002 PSAY "Liberado dia: "   + dDtLib     + " as " + SUBSTR(cHrLib,1,5)
@ 10,065 PSAY "Credito  dia  : " + dDtLibCred + " as " + SUBSTR(cHrLibCred,1,5)

@ 11,002 PSAY "Vendedor    : "   + SC5->C5_VEND1 + " - " + Alltrim(Posicione('SA3',1,xFILIAL('SA3')+SC5->C5_VEND1,'A3_NOME'))
@ 11,065 PSAY "Transportadora: " + SC5->C5_TRANSP+ " - " + Alltrim(Posicione('SA4',1,xFILIAL('SA4')+SC5->C5_TRANSP,'A4_NOME'))

@ 12,002 PSAY "Operador    : "   + Alltrim(Posicione('SU7',1,xFILIAL('SU7')+SC5->C5_OPERADO,'U7_NOME'))
@ 12,065 PSAY "Cond.Pagto.   : " + SC5->C5_CONDPAG+" - "+Alltrim(Posicione('SE4',1,xFILIAL('SE4')+SC5->C5_CONDPAG,'E4_DESCRI'))

@ 13,002 PSAY Replicate("-",nCols)

@ 14,002 PSAY Replicate("-",nCols)

nLin := 16
nCol := 12
@ nLin,nCol PSAY "                                         MM     MM        AAAAAAAAA     										   " ; nLin++
@ nLin,nCol PSAY "                                         MMM   MMM        AA     AA                                              " ; nLin++
@ nLin,nCol PSAY "                                         MMMM MMMM        AA     AA                                              " ; nLin++
@ nLin,nCol PSAY "                                         MM MMM MM        AAAAAAAAA                                              " ; nLin++
@ nLin,nCol PSAY "                                         MM  M  MM        AA     AA                                              " ; nLin++
@ nLin,nCol PSAY "                                         MM     MM OOO    AA     AA OOO                                          " ; nLin++
@ nLin,nCol PSAY "                                         MM     MM OOO    AA     AA OOO                                          " ; nLin++
nLin++
@ nLin,nCol PSAY "                                  ( E T I Q U E T A S   I N F O R M A T I V A S )                                " ; nLin++
nLin++
nLin++
@ nLin,nCol PSAY "   Esta Pr้-Nota cont้m produtos do fornecedor MEDICAL ACTION que necessitam de retifica็ใo no prazo de validade." ; nLin++
@ nLin,nCol PSAY "Anexe a carta do fornecedor e certificado de anแlise เ Nota Fiscal.                                                 " ; nLin++
nLin++

nCol := 2
For nI := 1 To Len(aProdMA)
	cPrn := Iif(nI==1,"Produto(s): ",", ")
	If nCol > 105
		@ nLin, nCol PSAY cPrn
		cPrn := ""
		nCol := 2
		nLin++
	EndIf
	
	cPrn += AllTrim(aProdMA[nI][1]) + Iif(!Empty(aProdMA[nI][2])," (Ant:"+AllTrim(aProdMA[nI][2])+")","")
	@ nLin, nCol PSAY cPrn
	nCol += Len(cPrn)
Next nI


//-- Monta a mensagem a ser enviado ao operador
cMsgMA := "AVISO IMPORTANTE - MEDICAL ACTION"+CR+CR
cMsgMA += "Pr้-Nota " +SC5->C5_NUM
cMsgMA += " impressa com produtos do fornecedor Medical Action"+CR
U_DIPCIC(cMsgMA,cCicMA)

Return


*--------------------------------------------------------------------------*
Static Function ValorPedido(cPedido)
*--------------------------------------------------------------------------*
Local aArea      := GetArea()
Local aAreaSC61   := SC6->( GetArea() )
Local aAreaSC51   := SC5->( GetArea() )

Local nVlrPed    := 0

DbSelectArea("SC6")
DbSetOrder(1)
SC6->(DbSeek(xFilial("SC6")+cPedido))
While SC6->C6_NUM == cPedido
	If SC6->C6_NUM == cPedido
		nVlrPed += SC6->C6_VALOR
	Endif
	SC6->(DbSkip())
Enddo
SC6->(DbCloseArea())


nVlrPed := (nVlrPed + SC5->C5_DESPESA + SC5->C5_SEGURO + SC5->C5_FRETE)

RestArea( aAreaSC51 )
RestArea( aAreaSC61 )
RestArea( aArea )

Return(nVlrPed)

//rotina de e-mail especifica para pedido com icms interestadual
*--------------------------------------------------------------------------*
User Function MailPedi(cEmail,cAssunto,aMsg,cAttach,cDe,cFuncSent,cTituVal)
*--------------------------------------------------------------------------*
Local cAccount  := Lower(Alltrim(GetMv("MV_RELACNT")))
Local cFrom     := Lower(Alltrim(GetMv("MV_RELACNT"))) //If(Empty(Alltrim(cDe)),"protheus@dipromed.com.br",cDe)
Local cPassword := Alltrim(GetMv("MV_RELPSW"))
Local cServer   := Alltrim(GetMv("MV_RELSERV"))
Local cEmailTo  := ""
Local cEmailCc  := ""
Local cEmailBcc := ""
Local lResult   := .F.
Local cError    := ""
Local i         := 0
Local cArq      := ""
Local cMsg      := ""
LOCAL _nLin                
LOCAL lSmtpAuth := GetNewPar("MV_RELAUTH",.F.)
LOCAL lAutOk	:= .F.

If ( Type("l410Auto") == "U" .OR. !l410Auto )
	U_DIPPROC(ProcName(0),U_DipUsr()) // JBS 05/10/2005 - Gravando o nome do Programa no SZU
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Definicao do cabecalho do email                                             ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	cMsg := ""
	cMsg += '<html>'
	cMsg += '<head>'
	cMsg += '<title>' + cAssunto + " - "+SM0->M0_NOME+"/"+SM0->M0_FILIAL+'</title>'
	cMsg += '</head>'
	cMsg += '<body>'
	//cMsg += '<Img Src="C:/AP5/SIGAADV/LGRL01.BMP"><BR>'
	cMsg += '</Table>'
	cMsg += '<P>'
	cMsg += '<Table align="center">'
	cMsg += '<tr>'
	cMsg += '<td colspan="10" align="center"><font color="red" size="5">'+cTituVal+'<font color="red" size="1">.</td>'
	cMsg += '</tr>'
	cMsg += '</Table>'
	
	cMsg += '<HR Width=85% Size=3 Align=Centered Color=Red> <P>'
	
	cMsg += '<Table Border=1 Align=Center BorderColor=#000000 CELLPADDING=4 CELLSPACING=0 Width=60%>'
	cMsg += '<Caption> <FONT COLOR=#000000 FACE= "ARIAL" SIZE=5>' + cAssunto +" - "+SM0->M0_NOME+"/"+SM0->M0_FILIAL+ '</FONT> </Caption>'
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Definicao do texto/detalhe do email                                         ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	For _nLin := 1 to Len(aMsg)
		IF (_nLin/2) == Int( _nLin/2 )
			cMsg += '<TR BgColor=#B0E2FF>'
		Else
			cMsg += '<TR BgColor=#FFFFFF>'
		EndIF
		cMsg += '<TD><B><Font Color=#000000 Size="2" Face="Arial">' + aMsg[_nLin,1] + ' </Font></B></TD>'
		cMsg += '<TD> <Font Color=#000000 Size="2" Face="Arial">' + aMsg[_nLin,2] + ' </Font></TD>'
		cMsg += '</TR>'
	Next
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Definicao do rodape do email                                                ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	cMsg += '</Table>'
	cMsg += '<P>'
	cMsg += '<Table align="center">'
	cMsg += '<tr>'
	cMsg += '<td colspan="10" align="center"><font color="red" size="3">Mensagem enviada automaticamente pelo sistema PROTHEUS - <font color="red" size="1">('+cFuncSent+')</td>'
	cMsg += '</tr>'
	cMsg += '</Table>'
	cMsg += '<HR Width=85% Size=3 Align=Centered Color=Red> <P>'
	//cMsg += '<B><Font Color=#000000 Size="2" Face="Arial"> Atenciosamente </Font></B><BR>'
	//cMsg += '<B><Font Color=#000000 Size="2" Face="Arial">' + SM0->M0_NOMECOM + '</Font></B><BR>'
	//cMsg += '<Img Src="C:/AP5/SIGAADV/LGRL01.BMP">'
	cMsg += '</body>'
	cMsg += '</html>'
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณEnvia o mail para a lista selecionada. Envia como BCC para que a pessoa penseณ
	//ณque somente ela recebeu aquele email, tornando o email mais personalizado.   ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	IF At(";",cEmail) > 0
		cEmailTo := SubStr(cEmail,1,At(";",cEmail)-1)
		cEmailCc:= SubStr(cEmail,At(";",cEmail)+1,Len(cEmail))
	Else
		cEmailTo := Alltrim(cEmail)
	EndIF
	
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
		TO      	Lower(cValToChar(cEmailTo));
		CC      	Lower(cValToChar(cEmailCc));
		BCC     	Lower(cEmailBcc);
		SUBJECT 	cAssunto;
		BODY    	cMsg;
		ATTACHMENT  cAttach;
		RESULT lResult
		
		If !lResult
			//Erro no envio do email
			GET MAIL ERROR cError
			
			MsgInfo(cError,OemToAnsi("Ateno"))
		EndIf
		
		DISCONNECT SMTP SERVER
	Else
		//Erro na conexao com o SMTP Server
		GET MAIL ERROR cError
		
		MsgInfo(cError,OemToAnsi("Ateno"))
	EndIf
ENDIF
Return(.T.)


//Giovani Zago    17/01/2012
*--------------------------------------------------------------------------*
User Function DipCicCli()
*--------------------------------------------------------------------------*
Local _aMsgVal 		:= {}
Local cAsIc  		:=  " AVISO SEPARAวรO NECESSITA DE CONFERENCIA"
Local cAttachIc   	:=  "  a"
Local cEc       	:=  "protheus@dipromed.com.br"
Local cEIc    		:=  "lourival.nunes@dipromed.com.br;maximo.canuto@dipromed.com.br"
Local cFuIc 		:=  "Prenota.prw"
Local cMSGcVal      :=  ""
Local cEnvMsg       := "LOURIVAL.NUNES , MAXIMO.CANUTO"
Local cTituV        := "ATENวรO PEDIDO TEM PRIORIDADE NA CONFERENCIA"
If SC5->C5_CLIENTE $ "016234/016310"
	
	aAdd( _aMsgVal , { "EMPRESA"      , + Capital( AllTrim( GetAdvFVal( "SM0", "M0_NOMECOM", cEmpAnt + cFilAnt, 1, "" ) ) )  } )
	aAdd( _aMsgVal , { "FILIAL"       , + Capital( AllTrim( GetAdvFVal( "SM0", "M0_FILIAL" , cEmpAnt + cFilAnt, 1, "" ) ) ) } )
	aAdd( _aMsgVal , { "PEDIDO"       , ""+SC5->C5_NUM+""  } )
	aAdd( _aMsgVal , { "CLIENTE"      , ""+AllTrim(SA1->A1_COD)+" - "+AllTrim(SA1->A1_NREDUZ)+""  } )
	aAdd( _aMsgVal , { "NOME"         , ""+AllTrim(SA1->A1_NOME)+""  } )       
	
	U_MailPedi(cEIc,cAsIc,_aMsgVal,cAttachIc,cEc,cFuIc,cTituV)
	
	
	
	// Monta a mensagem a ser enviado ao operador
	cMSGcVal := "CLIENTE NECESSITA DE CONFERENCIA"+CR+CR
	cMSGcVal += "O Pedido    "   +Alltrim(SC5->C5_NUM)+CR+CR
	cMSGcVal += "do Cliente   "+AllTrim(SA1->A1_COD)+" - "+AllTrim(SA1->A1_NREDUZ)+CR+CR
	cMSGcVal += "             "+AllTrim(SA1->A1_NOME)+CR+CR
	
	U_DIPCIC(cMSGcVal,cEnvMsg)
	
EndIf

Return()
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPrepImp   บAutor  ณMicrosiga           บ Data ณ  07/12/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function PrepImp(lDireto,cNum,Titulo,nI) 
Local cCaminho	:= AllTrim(GetNewPar("MV_LPT_PRE",""))
Local cPorta	:= Left(cCaminho,4)
Local cImp		:= GetNewPar("MV_LPT_PR2","")
Local nPos		:= At("|",cImp)  
DEFAULT lDireto := .F. 
DEFAULT cNum	:= ""       
DEFAULT Titulo  := ""
DEFAULT nI		:= ""
/*
If cEmpAnt == '01' .And. !lFunPre
	If nI == 1
		WinExec("RUNDLL32 PRINTUI.DLL,PrintUIEntry /y /n "+Left(cImp,nPos-1))
	Else
		WinExec("RUNDLL32 PRINTUI.DLL,PrintUIEntry /y /n "+Right(cImp,Len(cImp)-nPos))
	EndIf
EndIf
*/
If !lDireto
	wnrel := SetPrint(cString,NomeProg,IIf(!Empty(cNum),"",cPerg),@titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,.F.,Tamanho,,.F.)                       
	
	If nLastKey == 27
		Return
	Endif
	
	SetDefault(aReturn,cString)
	
	If nLastKey == 27
		Return
	Endif
ElseIf  lDireto .And. "LASER" $ cCaminho
	
	// Imprime via Spool direto na impressora padrใo sem a intera็ใo do usuแrio
	wnrel := SetPrint(cString,NomeProg,IIf(!Empty(cNum),"",cPerg),@titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,.F.,Tamanho,,.F.,,"DEFAULT.DRV",.T.,.F.,nil)
	
	aReturn[5] := 2
	aReturn[4] := 2
	
	If nLastKey == 27
		Return
	Endif
	
	SetDefault(aReturn,cString)
	
	If nLastKey == 27
		Return
	Endif
Else
	aReturn[5] := 3
EndIf

//Tratamento impressใo de prenota na matricial
If aReturn[5] == 3
	nCols      := 140
	limite     := 80
	tamanho    := "P"
	aReturn[4] :=  2
Endif

nTipo := If(aReturn[4]==1,15,18)

If lDireto .And. !("LASER" $ cCaminho)
	// Emite normalmente a Pr้-Nota
	WaitRun("NET USE "+cPorta+" /DELETE")
	WaitRun("NET USE "+cCaminho)
	
	Set Device To Print
	Set Printer to &cPorta
	PrinterWin(.F.) // Impressao Dos/Windows
	PreparePrint(.F., "", .F., cPorta) // Prepara a impressao na porta especificada
	Initprint(1) // 1=Impressora cliente e 2=Impressora Server
EndIf            			

Return  



/*-----------------------------------------------------------------------------
+ RBORGES - 17/10/2013 ----- User Funcion: CicDipm27()                        +                                                     
+ Enviarแ CIC quando for necessแrio o pedido de licita็ใo, apenas financeiro  +
+ gerar Cte.                                                                  +
+ 														                      +
------------------------------------------------------------------------------*/

*--------------------------------------------------------------------------*
	Static Function CCDipm27()
*--------------------------------------------------------------------------*
	
	Local aArea       := GetArea()
	Local cDeIc       := "protheus@dipromed.com.br"
    Local cCICDest    := Upper(GetNewPar("ES_DIPMC27","reginaldo.borges")) // Usuแrios que receberใo CICดs
	Local cAttachIc   :=  "  a"
	Local cFuncSentIc :=   " PRENOTA.prw "
 	
		dbSelectArea("SM0")
		
	_aMsgIc := {}
    	cMSGcIC       := 'AVISO - PEDIDO DE LICITAวรO, INFORMAR VOLUME E GERAR CTE!: ' +CHR(13)+CHR(10)+CHR(13)+CHR(10) +cPEDVEN+CHR(13)+CHR(10)
	
	    cMSGcIC       += " PEDIDO DE LICITAวรO, APENAS FINANCEIRO INFORMAR VOLUME E GERAR CTE! "


   	U_DIPCIC(cMSGcIC,cCICDest)
   	  	
	
    RestArea(aArea)	
	return() 

                                  

/*-----------------------------------------------------------------------------
+ Reginaldo Borges Data: 17/10/213 Fun็ใo: EmDipm27()                         +                                                     
+ Essa fun็ใo enviarแ e-mail para os usuแrios contidos no parโmetro,          +
+ quando for necessแrio o pedido de licita็ใo, carta de vale, apenas finacnใo +
+ gerar Cte.                                                                  +
-----------------------------------------------------------------------------*/
 


	*--------------------------------------------------------------------------*
	Static Function EmDipm27()
	*--------------------------------------------------------------------------*
	
	Local cDeIc       := "protheus@dipromed.com.br"
    Local cEmailIc    := GetNewPar("ES_DIPME27","reginaldo.borges@dipromed.com.br")        //Usuแrios que receberใo e-mails
	Local cAssuntoIc  := "PEDIDO DE LICITAวรO, INFORMAR VOLUME E GERAR CTE! " 
	Local cAttachIc   :=  "  a"
	Local cFuncSentIc :=   " PRENOTA.prw "
 	
	_aMsgIc := {}
    	cMSGcIC       := "PEDIDO DE LICITAวรO, INFORMAR VOLUME E GERAR CTE! : " +CHR(13)+CHR(10)+CHR(13)+CHR(10)
	
   
	aAdd( _aMsgIc , { "PEDIDO DE VENDA ", +cPEDVEN})
	aAdd( _aMsgIc , { "ATENวรO!     ", +"PEDIDO DE LICITAวรO, APENAS FINANCEIRO INFORMAR VOLUME E GERAR CTE! "})

  	  	
	U_UEnvMail(cEmailIc,cAssuntoIc,_aMsgIc,cAttachIc,cDeIc,cFuncSentIc)

		
	return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณImpRel    บAutor  ณMicrosiga           บ Data ณ  07/12/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ImpRel()

SET DEVICE TO SCREEN

If aReturn[5]==1
	dbCommitAll()
	SET PRINTER TO
	OurSpool(wnrel)
Endif

MS_FLUSH()		

Return


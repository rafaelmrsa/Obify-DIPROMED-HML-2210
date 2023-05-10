#INCLUDE 'PROTHEUS.CH' 
#INCLUDE 'APVT100.CH'
#INCLUDE 'ACDV175.CH'
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ACDV175   ºAutor  ³Microsiga           º Data ³  02/21/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function DipV175X()
Local ckey09  := VTDescKey(09)    
Local ckey24  := VTDescKey(24)
Local bkey09  := VTSetKey(09)
Local bkey24  := VTSetKey(24)

Local cEtiqueta
Local cProduto
Local cF3 := nil
Local nQtde
Local lSai:= .f.
Private cCodOpe    :=CBRetOpe()
Private cTranspConf 
Private cDesTra
Private lVldOrdSep:= GetMV("MV_CBVLDOS") == "1" // --> Valida Ordem de Separacao
Private lVldTransp:= GetMV("MV_CBVLDTR") == "1" // --> Valida Transportadora
Private lEmbarque := .t.

If Type('cOrdSep')=='U'
	Private cOrdSep := Space(6)
EndIf    


//CBChkTemplate()

//Verifica se foi chamado pelo programa ACDV170 e se ja foi embarcado 
//(ver se eh necessario fazer esta consistencia)
If ACDGet170() .AND. !("06" $ CB7->CB7_TIPEXP)
	Return 10
ElseIf ACDGet170()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Desativa a  tecla  avanca                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	A170ATVKeys(.f.,.t.)		
EndIf

VTClear()
If VtModelo()=="RF"
	@ 0,0 VtSay  "Embarque"  //"Embarque" 
EndIf          
//nOpc = 2 no fonte padrão

//Rafael Moraes Rosa - 09/12/2022 - Validacao por paramtro adicionada
IF GetNewPar("ES_VLDEXPD","PV") == "PV"
	If !DipGetPed()
		Return 10
	EndIf
ELSEIF GetNewPar("ES_VLDEXPD","PV") == "NF"
	//Rafael Moraes Rosa - 09/12/2022 - Nova Funcao DIPGETNF() adicionada
	If !DipGetNF()
		Return 10
	EndIf
EndIf 


If CB7->CB7_STATUS == "9"
   VTAlert("Processo de embarque finalizado","Aviso",.t.,4000) //"Processo de embarque finalizado" "Aviso" 
   If VTYesNo("Deseja estornar os produtos embarcados ?","Atencao",.T.)   //"Deseja estornar os produtos embarcados ?" "Atencao"
	   VTSetKey(09,{|| Informa()},"Informacoes")//"Informacoes"	 
	   Estorna()
	   VTSetKey(09,bkey09,cKey09)        
	   Return FimEmbarq(,"2")
	Endif			   			
EndIf   

If !IniProcesso()
	Return 10
EndIf

VTSetKey(09,{|| Informa()},"Informacoes") //"Informacoes"
VTSetKey(24,{|| Estorna()},"Estorno") //"Estorno"

//Informa a Transportadora
If !Transport()
	Return FimEmbarq(10)
EndIf       

//Atualiza variavel com dados da transportadora
cTranspConf:= SA4->A4_COD
cDesTra    := SA4->A4_NOME

//Leitura dos produtos para embarque
If !Embarque()
	Return FimEmbarq(10)
EndIf

Vtsetkey(09,bkey09,cKey09)
Vtsetkey(24,bkey24,cKey24)
Return  FimEmbarq(,"1")                   


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ VldCodSep³ Autor ³ ACD                   ³ Data ³ 08/03/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Validacao da Ordem de Separacao                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAACD                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function VldCodSep()

If Empty(cOrdSep)
   VtKeyBoard(chr(23))
   Return .f.
EndIf

CB7->(DbSetOrder(1))
CB7->(DbSeek(xFilial("CB7")+cOrdSep))

// --> Atencao nao alterar a sequencia das validacoes.

If CB7->(Eof())
	VtAlert("Ordem de separacao nao encontrada.","Aviso",.t.,4000,3) //### "Ordem de separacao  nao encontrada." "Aviso"
	VtKeyboard(Chr(20))  // zera o get
	Return .F.
EndIf
  
// analisar a pergunta '00-Separcao,01-Separacao/Embalagem,02-Embalagem,03-Gera Nota,04-Imp.Nota,05-Imp.Volume,06-embarque'
If !("06") $ CB7->CB7_TIPEXP
	VtAlert("Ordem de separacao nao configurada para Embarque","Aviso",.t.,4000,3) //### "Ordem de separacao nao configurada para Embarque","Aviso"
	VtKeyboard(Chr(20))  // zera o get
	Return .F.
Endif

If CB7->CB7_STATUS == "0" .OR. CB7->CB7_STATUS == "1"
	VtAlert("Ordem de separacao possui itens nao separados","Aviso",.t.,4000,3) //### "Ordem de separacao possui itens nao separados","Aviso"
	VtKeyboard(Chr(20))  // zera o get
	Return .f.
Endif

If "02" $ CB7->CB7_TIPEXP .and. (CB7->CB7_STATUS == "2" .OR. CB7->CB7_STATUS == "3")
	VtAlert("Ordem de separacao possui itens nao embalados","Aviso",.t.,4000,3) //### "Ordem de separacao possui itens nao embalados","Aviso"
	VtKeyboard(Chr(20))  // zera o get
	Return .F.
Endif

If "03" $ CB7->CB7_TIPEXP .and. Empty(CB7->(CB7_NOTA+CB7_SERIE))
	VtAlert("nota não gerada para esta ordem de separação","Aviso",.t.,4000,3) //"nota não gerada para esta ordem de separação",,"Aviso"
	VtKeyboard(Chr(20))  // zera o get
	Return .F.
Endif

If !ACDGet170()
	If "04" $ CB7->CB7_TIPEXP .AND.  (CB7->CB7_STATUS  < "6")
		VtAlert("Nota nao impressa para esta Ordem de separacao","Aviso",.t.,4000,3) //"Nota nao impressa para esta Ordem de separacao","Aviso",
		VtKeyboard(Chr(20))  // zera o get
		Return .F.
	EndIf
	If "05" $ CB7->CB7_TIPEXP .AND.  (CB7->CB7_STATUS  < "7")
		VtAlert("Etiquetas oficiais de volume nao foram impressas para esta Ordem de separacao","Aviso",.t.,4000,3) //"Etiquetas oficiais de volume nao foram impressas para esta Ordem de separacao","Aviso"
		VtKeyboard(Chr(20))  // zera o get
		Return .F.
	EndIf		
EndIf

If CB7->CB7_STATUS # "0" .AND. CB7->CB7_STATPA == "1" .AND. CB7->CB7_CODOPE # cCodOpe  // SE ESTIVER EM SEPARACAO E PAUSADO SE DEVE VERIFICAR SE O OPERADOR E' O MESMO
   VtBeep(3)
   If !VTYesNo("Ordem Separacao iniciada pelo operador "+CB7->CB7_CODOPE+". Deseja continuar ?","Aviso",.T.) //###### "Ordem Separacao iniciada pelo operador "+CB7->CB7_CODOPE+". Deseja continuar ?","Aviso"
      VtKeyboard(Chr(20))  // zera o get
      Return .F.
   EndIf
EndIf

//-- Ponto de entrada permite validação especifica para a ordem de separação.   
If ExistBlock("ACD175SOL")
	lRet:=ExecBlock("ACD175SOL",.f.,.f.)
	If ValType(lRet) == "L"
	   	Return lRet
   	EndIf
EndIf   	

RecLock("CB7",.f.)
If !Empty(CB7->CB7_STATPA)  // se estiver pausado tira o STATUS  de pausa
	CB7->CB7_STATPA := " "
EndIf
CB7->CB7_CODOPE := cCodOpe
CB7->(MsUnlock())
Return .t.


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ IniProcesso³ Autor ³ ACD                 ³ Data ³ 08/03/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Embarque                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAACD                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function IniProcesso()
Local cSQL := ""
Local lRet := .F.

cSQL := " SELECT "
cSQL += " 	CB7_STATUS "
cSQL += " 	FROM "
cSQL += 		RetSQLName("CB7")
cSQL += " 		WHERE "
cSQL += " 			CB7_FILIAL = '"+CB7->CB7_FILIAL+"' AND "
cSQL += " 			CB7_PEDIDO = '"+CB7->CB7_PEDIDO+"' AND "
cSQL += " 			CB7_STATUS < '4' AND "
cSQL += " 			D_E_L_E_T_ = ' ' "
                                           
cSQL := ChangeQuery(cSQL)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),"QRYCB7",.F.,.T. )

lRet := QRYCB7->(Eof())

If lRet	
	CBFlagSC5("3",CB7->CB7_ORDSEP)  //Embarcado
	CB7->(RecLock("CB7",.F.))
		CB7->CB7_STATUS := "8"    //Em processo de embarque
		CB7->CB7_STATPA := " "    //tira pausa
	CB7->(MsUnlock())
Else
	VTClear()
	VTAlert("O pedido não está pronto para ser embarcado","Aviso",.t.,4000) //"Processo de embarque finalizado" "Aviso" 
EndIf

QRYCB7->(dbCloseArea())                                                                                                                        

Return lRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³Transport³ Autor ³ ACD    	            ³ Data ³ 03/01/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Responsável por apresentar tela de digitação de dados  da³   ±±
±±³transportadora.³                                                                        ±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAACD                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Transport()          
Local cF3 
Local nLinha
Local uRetTrans
Local lV175CODT :=ExistBlock("V175CODT")
VTClear()
If VtModelo()=="RF"
	If ! Empty(CB7->CB7_TRANSP)
		@ 0,0 VTSay "Va para doca " //"Va para doca " 
		@ 1,0 VTSay "referente a  "  //"referente a  " 
		@ 2,0 VTSay "transportadora:" //"transportadora:" 
		@ 3,0 VTSay CB7->CB7_TRANSP
		@ 5,0 VTSay "Confirme a "  //"Confirme a " 
		@ 6,0 VTSay "transportadora"  //"transportadora" 
		nLinha:= 7
	Else
		@ 0,0 VTSay "Leia o codigo da"  //"Leia o codigo da" 
		@ 1,0 VTSay "transportadora:"  //"transportadora:" 
		@ 2,0 VTSay "para embarcar"  //"para embarcar" 
		nLinha := 3
	EndIf  
ElseIf VtModelo()=="MT44"
	If ! Empty(CB7->CB7_TRANSP)
		@ 0,0 VTSay "Confirme a transportadora "+ CB7->CB7_TRANSP //"Confirme a transportadora "
	Else
		@ 0,0 VTSay "Informe a Transportadora"  //"Informe a Transportadora" 
	EndIf
	nLinha := 1	
ElseIf VtModelo()=="MT16"
	If ! Empty(CB7->CB7_TRANSP)
	   VtClear()	
	   @ 0,0 VTSay "Confirme a " //"Confirme a "
	   @ 1,0 VTSay "Transportadora" //"Transportadora"	   
	   VtInkey(0)
	   VtClear()
		@ 0,0 VTSay "Transp.: "+CB7->CB7_TRANSP
	Else
	   VtClear()	
	   @ 0,0 VTSay  "Informe a " //"Informe a "
	   @ 1,0 VTSay  "Transportadora" //"Transportadora"	   
	   VtInkey(0)
	   VtClear()
		@ 0,0 VTSay "Transportadora"  //"Transportadora" 
	EndIf
	nLinha:= 1
EndIf   

while .t.
	VtClearBuffer()
	If UsaCB0('06')
		cTranspConf := Space(10)
	Else
		cTranspConf := Space(6)
		cF3 := 'SA4'
	EndIf
	If lV175CODT
		uRetTrans := ExecBlock("V175CODT",.F.,.F.)
		If(ValType(uRetTrans)=="C") 
			cTranspConf := uRetTrans
	    EndIf
	EndIf
	@ nLinha,0 VTGet cTranspConf  pict "@!" Valid VldConfTransp(cTranspConf) F3 cF3
	VTRead
	If VtLastKey() == 27
		Return .f.
	EndIf
	Exit
End
Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³VldConfTransp³ Autor ³ ACD                ³ Data ³ 03/01/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Validacao da Transportadora                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function VldConfTransp(cTranspConf)
Local lACD175VE := ExistBlock("ACD175VE")
Local aRet      := {}
Local lRet      := .T.

If UsaCB0("06")  // se usar CB0 para dispositivo
	aRet := CBRetEti(cTranspConf,"06")
	If lACD175VE
		aRet:=ExecBlock('ACD175VE',,,{aRet,"06"})
	EndIf	
	If Empty(aRet)
		VtAlert("Etiqueta invalida","Aviso",.t.,4000,3) //### "Etiqueta invalida","Aviso"
		VtClearGet("cTranspConf")
		lRet := .F.
	EndIf
Else
	aRet := {PadR(cTranspConf,6)}
EndIf

If !Empty(CB7->CB7_TRANSP) .and. CB7->CB7_TRANSP <> aRet[1]
	VtBeep(3)
	VtAlert("Transportadora invalida","Aviso",.T.,4000) //"Transportadora invalida"###"Aviso"
	VtKeyboard(Chr(20))  // zera o get
	lRet:= .F.
EndIf

If lRet
	SA4->(DbSetOrder(1))
	If !SA4->(DbSeek(xFilial()+aRet[1]))
		VtAlert("Transportadora nao encontrada","Aviso",.T.,4000,3)  //### "Transportadora nao encontrada","Aviso"
		VtClearGet("cTranspConf")
		lRet := .F.
	EndIf
EndIf

If lRet
	RecLock("CB7")
	CB7->CB7_TRANSP := aRet[1]
	CB7->(MsUnlock())
EndIf	

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ FimEmbarq  ³ Autor ³ ACD                 ³ Data ³ 09/03/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Finalisa o processo de Impressao de NFS                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAACD                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/              
Static Function FimEmbarq(nSai,cTipo)
Local _cStatus   := CB7->CB7_STATUS
Local _cPausa    := " "
Local lACD175FI  := ExistBlock("ACD175FI") 
Local cSQL 		 := ""
DEFAULT nSai 	 := 1                      
DEFAULT cTipo	 := ""

cPedido := CB7->CB7_PEDIDO      

cSQL := " SELECT "
cSQL += " 	R_E_C_N_O_ REC "
cSQL += " 	FROM "
cSQL += 		RetSQLName("CB7")
cSQL += " 		WHERE "
cSQL += " 			CB7_FILIAL = '"+xFilial("CB7")+"' AND "
cSQL += " 			CB7_PEDIDO = '"+cPedido+"' AND "
cSQL += " 			D_E_L_E_T_ = ' ' "

cSQL := ChangeQuery(cSQL)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),"TRBCB7",.F.,.T. )

                
If !Empty(cTipo)
	While !TRBCB7->(Eof())
		CB7->(dbGoTo(TRBCB7->REC))
		CB7->(RecLock("CB7"))
			If cTipo=="1"
				CB7->CB7_STATUS := "9"    //embarcado/finalizado               
				CB7->CB7_STATPA := " "
			Else 
				CB7->CB7_STATUS := "8"    //embarcado/finalizado               
				CB7->CB7_STATPA := "1"		
			EndIf                     
		CB7->(MsUnlock())             
		CBLogExp(CB7->CB7_ORDSEP)                                              
		TRBCB7->(dbSkip())
	EndDo                    
EndIf

TRBCB7->(dbCloseArea())

//VTAlert('Processo de embarque finalizado','Aviso',.t.,4000) //'Processo de expedicao finalizado'###

/*
CB9->(DbSetOrder(5))
If !CB9->(DbSeek(xFilial("CB9")+CB7->CB7_ORDSEP+"1")) .AND. ;
	!CB9->(DbSeek(xFilial("CB9")+CB7->CB7_ORDSEP+"2")) 
   _cStatus := "9"	//Embarque finalizado
   _cPausa  := " "   //Sem pausa
   VTAlert(STR0001,"Aviso",.t.,4000) 
ElseIf CB9->(DbSeek(xFilial("CB9")+CB7->CB7_ORDSEP+"3")) .AND.;
		(CB9->(DbSeek(xFilial("CB9")+CB7->CB7_ORDSEP+"1")) .OR. ;
		 CB9->(DbSeek(xFilial("CB9")+CB7->CB7_ORDSEP+"2")))
   _cStatus := "8"  //Embarcando
   _cPausa  := "1"  //Pausada
Else              
	 // Retorna para processo anterior 
	_cStatus :=  CBAntProc(CB7->CB7_TIPEXP,"06*")
	_cPausa  := "1"  //Pausada
EndIf
*/
/*
RecLock("CB7",.F.)
CB7->CB7_STATUS := _cStatus
CB7->CB7_STATPA := _cPausa
CB7->(MsUnLock())
*/
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ponto de entrada para Customizacoes apos gravar dados Embarque     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lACD175FI
       ExecBlock("ACD175FI",.F.,.F.,{CB7->CB7_ORDSEP})
EndIf       

//Verifica se esta sendo chamado pelo ACDV170 e se existe um avanco 
//ou retrocesso forcado pelo operador
If ACDGet170() .AND. A170AvOrRet() 
 	nSai := A170ChkRet()         
EndIf
Return nSai


Static Function Embarque()
Local cEtiqProd
Local cProduto
Local cPictQtdExp := PesqPict("CB8","CB8_QTDORI")
Local nQtde
Local lForcaQtd   := GetMV("MV_CBFCQTD",,"2") =="1"     
Private cVolume   := Space(10)
Private lEmbarque := .t.

While .T.
	VTClear           
	If VtModelo()=="RF"
		@ 0,0 VTSay "Transportadora" //Transportadora
		@ 1,0 VTSay CB7->CB7_TRANSP
		@ 2,0 VtSay SubStr(cDesTra,1,20)
		If '01' $ CB7->CB7_TIPEXP .or. '02' $ CB7->CB7_TIPEXP // trabalha com sub-volume
			cVolume := Space(10)
			@ 06,00 VtSay "Leia o volume" //"Leia o volume" 
			@ 07,00 VtGet cVolume Picture "@!" Valid VldEbqVol(cVolume)
		Else
			nQtde := 1
			cProduto   := Space(48)
			If ! Usacb0("01")
				@ 4,0 VTSay 'Qtde ' VtGet nQtde pict cPictQtdExp valid VldQtde(nQtde,.f.) when (lForcaQtd .or. VTLastkey() == 5) //
			EndIf
			@ 5,0 VTSay  'Leia o produto' //'Leia o produto' 
			@ 6,0 VtSay  'a embarcar' //'a embarcar' 
			@ 7,0 VTGet cProduto pict '@!' VALID VTLastkey() == 5 .or. VldProdEbq(cProduto,nQtde,Nil)
		EndIf
	ElseIf VtModelo()=="MT44" 
		If '01' $ CB7->CB7_TIPEXP .or. '02' $ CB7->CB7_TIPEXP // trabalha com sub-volume
		   @ 0,0 VTSay "Transp." +CB7->CB7_TRANSP+" "+SubStr(cDesTra,1,20)
			cVolume := Space(10)
			@ 01,00 VtSay "Leia o volume" VtGet cVolume Picture "@!" Valid VldEbqVol(cVolume) //STR0028 -> Leia o volume
		Else         
		   @ 0,0 VTSay "Transp." +CB7->CB7_TRANSP
			nQtde := 1   
			cProduto   := Space(48)
			If ! Usacb0("01")
				@ 0,17 VTSay 'Qtde ' VtGet nQtde pict cPictQtdExp valid VldQtde(nQtde,.f.) when (lForcaQtd .or. VTLastkey() == 5) //
			EndIf
			@ 1,0 VTSay "Embarcar Produto" VTGet cProduto pict '@!' VALID VTLastkey() == 5 .or. VldProdEbq(cProduto,nQtde,Nil) // STR0031->Embarcar Produto
		EndIf           
	ElseIf VtModelo()=="MT16"	
		If '01' $ CB7->CB7_TIPEXP .or. '02' $ CB7->CB7_TIPEXP // trabalha com sub-volume
		   @ 0,0 VTSay "Transp." +CB7->CB7_TRANSP
			cVolume := Space(10)
			@ 01,00 VtSay "Volume" VtGet cVolume Picture "@!" Valid VldEbqVol(cVolume) // STR0032 ->Volume
		Else         
			nQtde := 1   
			cProduto   := Space(48)
			If Usacb0("01")
		   	@ 0,0 VTSay "Transp." +CB7->CB7_TRANSP
			Else
				@ 0,0 VTSay 'Qtde ' VtGet nQtde pict cPictQtdExp valid VldQtde(nQtde,.f.) when (lForcaQtd .or. VTLastkey() == 5) //
			EndIf
			@ 1,0 VTSay "Produto" VTGet cProduto pict '@!' VALID VTLastkey() == 5 .or. VldProdEbq(cProduto,nQtde,Nil) //STR0033->Produto
		EndIf           
	EndIf
	VtRead
	If VtLastKey() == 27
		If VTYesNo("Deseja finalizar o embarque?","Atenção",.T.)
			If DipFinEmb(CB7->CB7_PEDIDO)
				If DipVldEmb(CB7->CB7_PEDIDO)				
					Exit
				Else 
					VTBeep(6)
					VTAlert('ERRO! Quantidade embarcada diferente da Nota Fiscal.','Aviso',.t.,4000)  					
					If VTYesNo("Deseja finalizar o embarque mesmo com divergência?","Atenção",.T.)					
						Exit
					EndIf
				EndIf
			Else
				VTAlert('Existem volumes pendentes para o embarque','Aviso',.t.,4000)				
			EndIf  
		Else
			If VTYesNo("Deseja sair?","Atenção",.T.)  
				Return .F.
			EndIf
		EndIf
	EndIf               
	/*
	If DipFinEmb(CB7->CB7_PEDIDO)
		Exit
	EndIf
	*/
	/*
	CB9->(DbSetOrder(5))
	If ! CB9->(DbSeek(xFilial("CB9")+CB7->CB7_ORDSEP+"1")) .and. ! CB9->(DbSeek(xFilial("CB9")+CB7->CB7_ORDSEP+"2"))
		Exit
	EndIF
	*/                     
EndDo                      

VTAlert('Processo de embarque finalizado','Aviso',.t.,4000) //'Processo de expedicao finalizado'###

U_DiprKardex(CB7->CB7_PEDIDO,U_DipUsr(),DtoC(dDataBase)+"-"+Left(Time(),5),.T.,"64")

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ VldEbqVol³ Autor ³ ACD                   ³ Data ³ 08/03/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Validacao do Volume no embarque e no estorno do embarque   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAACD                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function VldEbqVol(cVolume,lEstorna,lFim)
Local lACD175VE  := ExistBlock("ACD175VE")
Local lACD175VO  := ExistBlock("ACD175VO")
Local aRet       := {}
Local cVolOri
Default lEstorna := .F.

If Empty(cVolume)
	Return .f.
EndIf

If lACD175VO
	cVolOri := cVolume
	cVolume := ExecBlock("ACD175VO",.F.,.F.,{cVolume})
	If (ValType(cVolume)<>"C") .OR. (ValType(cVolume)=="C" .AND. Empty(cVolume))
		cVolume := cVolOri
	EndIf
EndIf

If UsaCB0("05")
   aRet:= CBRetEti(cVolume,"05")
	If lACD175VE
		aRet:=ExecBlock('ACD175VE',,,{aRet,"05"})
	Endif   
   If Empty(aRet)
	   VtAlert("Etiqueta de volume invalida","Aviso",.t.,4000,3) //###"Etiqueta de volume invalida","Aviso"
	   VtKeyboard(Chr(20))  // zera o get
	   Return .f.
   EndIf
   cCodVol:= aRet[1]   
Else
   cCodVol:= cVolume
EndIf

CB6->(DbSetOrder(1))
If ! CB6->(DbSeek(xFilial("CB6")+cCodVol))
	VtAlert("Codigo de volume nao cadastrado "+cCodVol,"Aviso",.t.,4000,3) //###"Codigo de volume nao cadastrado "+cCodVol,"Aviso"
	VtKeyboard(Chr(20))  // zera o get
	return .f.
EndIf
If lEstorna
	If CB6->CB6_STATUS # "5"
		VtAlert("Volume nao embarcado","Aviso",.t.,4000) //### "Volume nao embarcado","Aviso"
		VtKeyboard(Chr(20))  // zera o get
		return .f.
	EndIf
EndIf
CB9->(DbSetOrder(4))
If !CB9->(DbSeek(xFilial("CB9")+cCodVol))
	//VtAlert("Volume nao encontrado","Aviso",.t.,4000) //### "Volume nao encontrado","Aviso"
	VtAlert("Volume nao encontrado","Aviso",.t.,8000,10) //Ajustado dia 30/11/22 - MCVN
	VtKeyboard(Chr(20))  // zera o get   
	
	DipGrvLog(CB7->CB7_PEDIDO,cCodVol)
	
	return .f.
EndIf
//If CB9->CB9_ORDSEP # CB7->CB7_ORDSEP
If !DipVldVol(CB9->CB9_ORDSEP, CB7->CB7_PEDIDO)
	VtAlert("Volume pertence a outro pedido"+CB9->CB9_PEDIDO,"Aviso",.t.,8000,10) //Ajustado dia 30/11/22 - MCVN -- Beep e Sleep 
	VtKeyboard(Chr(20))  // zera o get
	
	DipGrvLog(CB7->CB7_PEDIDO,cCodVol,CB9->CB9_PEDIDO)
	
	return .f.
EndIf
If lEstorna
	IF ! VtYesNo("Confirma o estorno?","Aviso",.t.) //### "Confirma o estorno?","Aviso"
		VtKeyboard(Chr(20))  // zera o get
		Return .F.
	EndIf
Else
	IF CB9->CB9_STATUS =="3"
		VtAlert("Volume ja lido","Aviso",.t.,4000,3) //### "Volume ja lido","Aviso"
		VtKeyboard(Chr(20))  // zera o get
		return .f.
	EndIf
EndIf

CB9->(DbSetOrder(4))
CB9->(DbSeek(xFilial("CB9")+cCodVol))
While CB9->(! EOF() .and. CB9_FILIAL+CB9_VOLUME == ;
	xFilial("CB9")+cCodVol)
	RecLock("CB9")
	If lEstorna
		CB9->CB9_QTEEBQ := 0.00
		CB9->CB9_STATUS := "2"  // EMBALAGEM FINALIZADA
	Else
		CB9->CB9_QTEEBQ := CB9->CB9_QTESEP
		CB9->CB9_STATUS := "3"  // EMBARCADO
	EndIf
	CB9->(MsUnLock())
	CB9->(DBSkip())
End
RecLock("CB6")
If lEstorna
	If CBAntProc(CB7->CB7_TIPEXP,"06*") == "7"
		CB6->CB6_STATUS := "3"   // VOLUME ENCERRADO
	Else
		CB6->CB6_STATUS := "1"   // VOLUME EM ABERTO
	EndIf		
	CB6->CB6_CODEB1 := ""
	CB6->CB6_CODEB2 := ""
Else
	CB6->CB6_STATUS := "5"   // EMBARQUE
	CB6->CB6_CODEB1 := cCodOpe
	CB6->CB6_CODEB2 := cCodOpe
EndIf                             
CB6->(MsUnlock())                 

If DipFinEmb(CB7->CB7_PEDIDO,.T.)              
	lFim := .T.
	VTAlert('Processo de estorno finalizado','Aviso',.t.,4000)
	Return lFim                                 	
EndIf

VtKeyboard(Chr(20))  // zera o get

Return ! lEstorna

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³  VldQtde ³ Autor ³ ACD                   ³ Data ³ 09/03/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Validacao da quantidade informada                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAACD															        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function VldQtde(nQtde,lSerie)
Local   lRet := .T.
Default lSerie:=.F.

If nQtde <= 0
   Return .F.
Endif
If lSerie .and. nQtde > 1
   VTAlert("Quantidade invalida !","Aviso",.T.,2000,3) //###  "Quantidade invalida !""Aviso"
   VTAlert("Quando se utiliza numero de serie a quantidade deve ser == 1","Aviso",.T.,4000) //### "Quando se utiliza numero de serie a quantidade deve ser == 1","Aviso"
   Return .F.
Endif

If Existblock("ACD175QTD") 
	lRet:=ExecBlock("ACD175QTD",.F.,.F.,{nQtde})
	If ValType(lRet) == "L"
	   	Return lRet
   	EndIf
EndIf 
 	
Return .T.


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³VldProdEbq³ Autor ³ ACD                   ³ Data ³ 09/03/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Validacao do Produto no embarque e no estorno do embarque   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAACD                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function VldProdEbq(cEProduto,nQtde,lEstorna)
Local cTipo
Local aEtiqueta,aRet
Local cLote    := Space(10)
Local cSLote   := Space(6)
Local cNumSer  := Space(20)
Local nQE      :=0
Local nQEConf  :=0
Local nQtdBaixa:=0
Local nSaldoEmb
Local cProduto
Local lACD175VE := ExistBlock("ACD175VE")
Default lEstorna := .F.

If !CBLoad128(@cEProduto)
	VtKeyboard(Chr(20))  // zera o get
	Return .F.
EndIf
cTipo := CBRetTipo(cEProduto)
If cTipo == "01"
	aEtiqueta:= CBRetEti(cEProduto,"01") 
	If lACD175VE
		aEtiqueta:=ExecBlock('ACD175VE',,,{aEtiqueta,"01"})
	EndIf		
	If Empty(aEtiqueta)
		VtAlert("Etiqueta invalida","Aviso",.t.,4000,3) //### "Etiqueta invalida","Aviso"
		VtKeyboard(Chr(20))  // zera o get
		Return .F.
	EndIf
	CB9->(DbSetorder(1))
	If ! CB9->(DbSeek(xFilial("CB9")+cOrdSep+Left(cEProduto,10)))
		VtAlert("Produto nao separado","Aviso",.t.,4000,3) //### "Produto nao separado" "AVISO"
		VtKeyboard(Chr(20))  // zera o get
		Return .F.
	EndIf
	cProduto:= aEtiqueta[1]
	nQE     := aEtiqueta[2]
	cLote   := aEtiqueta[16]
	cSLote  := aEtiqueta[17]
	nQEConf := nQE
	If ! CBProdUnit(aEtiqueta[1]) .and. GetMv("MV_CHKQEMB") =="1"
		nQEConf := CBQtdEmb(aEtiqueta[1])
	EndIf
	If Empty(nQEConf) .or. nQE # nQEConf
		VtAlert("Quantidade invalida","Aviso",.t.,4000,3) //### "Quantidade invalida""Aviso"
		VtKeyboard(Chr(20))  // zera o get
		Return .f.
	EndIf
	If lEstorna
		If CB9->CB9_STATUS == "1"  // STATUS=1 (EM ABERTO)
			VtAlert("Produto nao embarcado","Aviso",.t.,4000,3) //### "Produto nao embarcado","Aviso"
			VtKeyboard(Chr(20))  // zera o get
			Return .f.
		EndIf
		If ! VtYesNo("Confirma o estorno?","Aviso",.t.) //### "Confirma o estorno?","Aviso"
			VtKeyboard(Chr(20))  // zera o get
			Return .F.
		EndIf
	Else
		If CB9->CB9_STATUS # "1"  // STATUS=1 (EM ABERTO)
			VtAlert("Produto ja embarcado","Aviso",.t.,4000,3) //### "Produto ja embarcado","Aviso"
			VtKeyboard(Chr(20))  // zera o get
			Return .f.
		EndIf
	EndIf
	If lEstorna
		RecLock("CB9")
		CB9->CB9_QTEEBQ := 0.00
		CB9->CB9_STATUS := "1"  // em aberto
		CB9->(MsUnlock())
	Else
		RecLock("CB9")
		CB9->CB9_QTEEBQ += nQE
		CB9->CB9_STATUS := "3"  // embarcado
		CB9->(MsUnlock())
	EndIf
ElseIf cTipo $ "EAN8OU13-EAN14-EAN128"
	aRet     := CBRetEtiEan(cEProduto)
	If lACD175VE
		aRet:=ExecBlock('ACD175VE',,,{aRet,"01"})
	Endif	
	If Empty(aRet)
		VtAlert("Etiqueta invalida","Aviso",.t.,4000,3) //### "Etiqueta invalida","Aviso"
		VtKeyboard(Chr(20))  // zera o get
		Return .F.
	EndIf
	cProduto := aRet[1]
	If ! CBProdUnit(cProduto)
		VtAlert("Etiqueta invalida","Aviso",.t.,4000,3)  //### "Etiqueta invalida","Aviso"
		VtKeyboard(Chr(20))  // zera o get
		Return .F.
	EndIf
	nQE  :=CBQtdEmb(cProduto)*nQtde
	If Empty(nQE)
		VtAlert("Quantidade invalida","Aviso",.t.,4000,3) //### "Quantidade invalida" "Aviso"
		VtKeyboard(Chr(20))  // zera o get
		Return .F.
	EndIf
	cLote := aRet[3]
	If ! CBRastro(aRet[1],@cLote,@cSLote)
		VTKeyBoard(chr(20))
		Return .f.
	EndIf   
	cNumSer:= aRet[5]
	If Empty(cNumSer) .and. CBSeekNumSer(cOrdSep,cProduto)
      If ! VldQtde(nQtde,.T.)
         VtKeyboard(Chr(20))  // zera o get
		   Return .F.
      Endif
      If ! CBNumSer(@cNumSer)
         VTKeyBoard(chr(20))
         Return .f.
      EndIf
   EndIf
	CB9->(DbSetorder(8))
	If ! CB9->(DBSeek(xFilial("CB9")+cOrdSep+cProduto+cLote+cSLote+cNumSer+space(10)))
		VtAlert("Produto invalido","Aviso","Aviso",.t.,4000,3)  //### "Produto invalido","Aviso"
		VtKeyboard(Chr(20))  // zera o get
		Return .F.
	EndIf
	nSaldoEmb:=0
	While CB9->(! EOF() .AND. CB9_FILIAL+CB9_ORDSEP+CB9_PROD+CB9_LOTECT+CB9_NUMLOT+CB9_VOLUME ==;
		xFilial("CB9")+cOrdSep+cProduto+cLote+cSLote+space(10))
		If lEstorna
			nSaldoEmb += CB9->CB9_QTEEBQ
		Else
			nSaldoEmb += CB9->CB9_QTESEP-CB9->CB9_QTEEBQ
		EndIf
		CB9->(DbSkip())
	Enddo
	If nQE > nSaldoEmb
		VtBeep(3)
		If lEstorna
			VtAlert("Quantidade informada maior que a quantidade embarcada","Aviso",.t.,4000)  //### "Quantidade informada maior que a quantidade embarcada","Aviso"
		Else
			VtAlert("Quantidade informada maior que disponivel para o embarque","Aviso",.t.,4000) //### "Quantidade informada maior que disponivel para o embarque","Aviso"
		EndIf
		VtKeyboard(Chr(20))  // zera o get
		Return .F.
	EndIf
	If lEstorna
		If ! VtYesNo("Confirma o estorno?","Aviso",.t.) //### "Confirma o estorno?","Aviso"
			VtKeyboard(Chr(20))  // zera o get
			Return .F.
		EndIf
	EndIf
	nSaldoEmb := nQE
	nQtdBaixa :=0
	CB9->(DbSetorder(8))
	CB9->(DBSeek(xFilial("CB9")+cOrdSep+cProduto+cLote+cSLote+cNumSer+space(10)))
	While CB9->(! EOF() .AND. CB9_FILIAL+CB9_ORDSEP+CB9_PROD+CB9_LOTECT+CB9_NUMLOT+CB9_VOLUME ==;
		xFilial("CB9")+cOrdSep+cProduto+cLote+cSLote+space(10)) .and. ! Empty(nSaldoEmb)
		If lEstorna
			If Empty(CB9->CB9_QTEEBQ)
				CB9->(DBSkip())
				Loop
			EndIf
		Else
			If CB9->CB9_STATUS == '3'
				CB9->(DBSkip())
				Loop
			EndIf
		EndIf
		nQtdBaixa := nSaldoEmb
		If lEstorna
			If nSaldoEmb >= CB9->CB9_QTEEBQ
				nQtdBaixa := CB9->CB9_QTEEBQ
			EndIf
		Else
			If nSaldoEmb >= (CB9->CB9_QTESEP-CB9->CB9_QTEEBQ)
				nQtdBaixa := (CB9->CB9_QTESEP-CB9->CB9_QTEEBQ)
			EndIf
		EndIf
		RecLock("CB9")
		If lEstorna
			CB9->CB9_QTEEBQ -=nQtdBaixa
			CB9->CB9_STATUS := "1"  // em aberto
		Else
			CB9->CB9_QTEEBQ +=nQtdBaixa
			If CB9->CB9_QTEEBQ == CB9->CB9_QTESEP
				CB9->CB9_STATUS := "3"  // embarcado
			EndIf
		EndIf
		CB9->(MsUnlock())
		nSaldoEmb -=nQtdBaixa
		CB9->(DbSkip())
	Enddo
Else
	VtAlert("Etiqueta invalida","Aviso",.t.,4000,3) //### "Etiqueta invalida","Aviso"
	VtKeyboard(Chr(20))  // zera o get
	Return .F.
EndIf
nQtde:=1
VTGetRefresh('nQtde')
VtKeyboard(Chr(20))  // zera o get
Return ! lEstorna


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ Informa  ³ Autor ³ ACD                   ³ Data ³ 17/03/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Mostra as etiquetas lidas o tipo e a quantidade das mesmas ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAACD                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Informa()
Local cPallet                
Local nRecCB9 := CB9->(RecNo())
Local cTipo                       
Local nPos
Local aCab      := {}
Local aSize     := {}
Local aSave     := VTSAVE()              
Local aAreaCB9  := GetArea("CB9")
Local aEtiqueta := {}
Local aDados    := {}
Local lACD175VE := ExistBlock("ACD175VE")

VTClear()
If UsaCB0("01")
   aCab  := {"Etiqueta","Tipo","Ordem Separacao"} //###### "Etiqueta","Tipo","Ordem Separacao"
   aSize := {10,10,15}
   CB9->(DbSetOrder(1))
   CB9->(DbSeek(xFilial("CB9")+cOrdSep))
   While CB9->(! Eof() .and. CB9_FILIAL+CB9_ORDSEP == xFilial("CB9")+cOrdSep)
      cTipo  := CBRetTipo(CB9->CB9_CODETI)
   	cPallet:= RetPallet(CB9->CB9_CODETI)   	
   	If cTipo == "05"   		// --> Etiqueta de Volume         
      	aadd(aDados,{CB9->CB9_CODETI,"Volume",CB9->CB9_ORDSEP})  // STR0032 -> Volume
   	Elseif cTipo == "01" .and. Empty(cPallet)  // --> Etiqueta de Produto  com CB0	  
	   	aadd(aDados,{CB9->CB9_CODETI,"Produto",CB9->CB9_ORDSEP})		 // STR0033 -> Produto
   	Elseif ! Empty(cPallet)  // --> Etiqueta de Pallet			 
         aEtiqueta:= CBRetEti(CB9->CB9_CODETI)
			If lACD175VE
				aEtiqueta:=ExecBlock('ACD175VE',,,{aEtiqueta,"01"})
			EndIf	
         If Alltrim(CB0->CB0_PALLET) # Alltrim(cPallet)    
         	CB9->(DbSkip())
            Loop
         Endif
  			If ascan(aDados,{|x|x[1] == cPallet})== 0 // Adiciona o Pallet somente uma vez
     	      aadd(aDados,{cPallet,"Pallet",CB9->CB9_ORDSEP}) //
 			Endif                        
   	EndIf   	
      CB9->(DbSkip())
   EndDo
   aDados := aSort(aDados,,,{|x,y| x[2] < y[2]})   
Else
   aCab  := {"Produto","Volume","Qtd.Sep","Qtd.Embq"}  //"Produto","Volume","Qtd.Sep","Qtd.Embq"
   aSize := {15,10,9,9}              
   CB9->(DbSetOrder(12))
   CB9->(DbSeek(xFilial("CB9")+cOrdSep))
   While CB9->(! Eof() .and. CB9_FILIAL+CB9_ORDSEP == xFilial("CB9")+cOrdSep)
   	nPos := AsCan(aDados,{|x| x[1]+x[2]+x[5]==CB9->(CB9_PROD+CB9_VOLUME+CB9_LOCAL+CB9_LCALIZ+CB9_LOTECT+CB9_NUMLOT+CB9_NUMSER)})
   	If Empty(nPos)
			CB9->(aadd(aDados,{CB9_PROD,CB9_VOLUME,CB9_QTESEP,CB9_QTEEBQ,CB9_LOCAL+CB9_LCALIZ+CB9_LOTECT+CB9_NUMLOT+CB9_NUMSER}) )
		Else
			aDados[nPos,3] += CB9->CB9_QTESEP
			aDados[nPos,4] += CB9->CB9_QTEEBQ
		EndIf
   	CB9->(DbSkip())
   EndDo
Endif   
VTaBrowse(0,0,VTMaxRow(),VTMaxCol(),aCab,aDados,aSize)
VtRestore(,,,,aSave)
RestArea(aAreaCB9)
CB9->(DbGoto(nRecCB9))
Return                 



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ Estorna  ³ Autor ³ Anderson Rodrigues    ³ Data ³ 15/07/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Realiza estorno dos volumes embarcados                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAACD                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Estorna()
Local ckey24  := VTDescKey(24)
Local bkey24  := VTSetKey(24)
Local aTela   := VTSave()
Local cEtiqueta  
Local cVolume
Local cProduto
Local nQtde
Local lForcaQtd   := GetMV("MV_CBFCQTD",,"2") =="1"     
Local cPictQtdExp := PesqPict("CB8","CB8_QTDORI")
Local lFim		  := .F.
VTSetKey(24,Nil)        

While .t.
	VTClear()           
	If VtModelo()=="RF"
		@ 0,0 VtSay Padc("Estorno do embarque",VTMaxCol())  // STR0049->"Estorno do embarque"
		If '01' $ CB7->CB7_TIPEXP .or. '02' $ CB7->CB7_TIPEXP // trabalha com sub-volume
			cVolume := Space(10)
			@ 06,00 VtSay  "Leia o volume" // "Leia o volume"
			@ 07,00 VtGet cVolume Picture "@!" Valid VldEbqVol(cVolume,.t.,@lFim)
		Else
			nQtde := 1
			cProduto   := Space(48)
			If ! Usacb0("01")
				@ 4,0 VTSay 'Qtde ' VtGet nQtde pict cPictQtdExp valid VldQtde(nQtde,.f.) when (lForcaQtd .or. VTLastkey() == 5) //
			EndIf
			@ 5,0 VTSay  'Leia o produto'  // 'Leia o produto' 
			@ 6,0 VtSay  'a embarcar' // 'a embarcar' 
			@ 7,0 VTGet cProduto pict '@!' VALID VTLastkey() == 5 .or. VldProdEbq(cProduto,nQtde,.t.)						
		EndIf
	ElseIf VtModelo()=="MT44" 
		If '01' $ CB7->CB7_TIPEXP .or. '02' $ CB7->CB7_TIPEXP // trabalha com sub-volume
			cVolume := Space(10)                                                            
			@ 0,0 VtSay Padc("Estorno do embarque",VTMaxCol()) // STR0049->"Estorno do embarque"
			@ 1,00 VtSay "Leia o volume" VtGet cVolume Picture "@!" Valid VldEbqVol(cVolume,.t.) // "Leia o volume"
		Else         
			nQtde := 1   
			cProduto   := Space(48)
			If Usacb0("01")       
			   @ 0,0 VtSay Padc("Estorno do embarque",VTMaxCol())// STR0049->"Estorno do embarque"
			Else
				@ 0,0 VTSay 'Estorno: Qtde ' VtGet nQtde pict cPictQtdExp valid VldQtde(nQtde,.f.) when (lForcaQtd .or. VTLastkey() == 5) //
			EndIf
			@ 1,0 VTSay "Produto" VTGet cProduto pict '@!' VALID VTLastkey() == 5 .or. VldProdEbq(cProduto,nQtde,.T.) // "STR0033 ->Produto"
		EndIf           
	ElseIf VtModelo()=="MT16"	
		If '01' $ CB7->CB7_TIPEXP .or. '02' $ CB7->CB7_TIPEXP // trabalha com sub-volume
			cVolume := Space(10)                                 
			@ 0,0 VtSay Padc("Estorno do embarque",VTMaxCol())	// STR0049->"Estorno do embarque"		
			@ 1,0 VtSay "Volume" VtGet cVolume Picture "@!" Valid VldEbqVol(cVolume,.t.) //STR0032 ->"Volume"
		Else         
			nQtde := 1   
			cProduto   := Space(48)                                 
			If  Usacb0("01")
				@ 0,0 VtSay Padc("Estorno do embarque",VTMaxCol())	// STR0049->"Estorno do embarque"			
			Else
				@ 0,0 VTSay 'Est.Qtde ' VtGet nQtde pict cPictQtdExp valid VldQtde(nQtde,.f.) when (lForcaQtd .or. VTLastkey() == 5) //
			EndIf
			@ 1,0 VTSay "Produto" VTGet cProduto pict '@!' VALID VTLastkey() == 5 .or. VldProdEbq(cProduto,nQtde,.T.) //STR0033 -> Produto
		EndIf           
	EndIf
	VtRead
	If VtLastKey() == 27 .Or. lFim
		Exit
	EndIf
	//Se nao existir mais nenhum produto embarcado para esta ordem
	//de separacao aborta estorno
	/*
	CB9->(DbSetOrder(5))
	If ! CB9->(DbSeek(xFilial("CB9")+CB7->CB7_ORDSEP+"3"))
		Exit
	EndIF
	*/
EndDo

VTRestore(,,,,aTela)
VTSetKey(24,bkey24,cKey24)        
Return 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³RetPalletCB9³ Autor ³ ACD                 ³ Data ³ 03/01/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Verifica se existe o Pallet para a etiqueta informada       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAACD                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function RetPallet(cEtiqueta)
Local cPallet:= " "
Local aArea  := GetArea("CB0")

If ! UsaCB0("01") .or. Empty(cEtiqueta)
   Return(cPallet)
EndIf

CB0->(DbSetOrder(1))
If CB0->(DbSeek(xFilial("CB0")+cEtiqueta)) 
   cPallet:= CB0->CB0_PALLET
EndIf
RestArea(aArea)
Return(cPallet)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ACDV175   ºAutor  ³Microsiga           º Data ³  02/21/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function DipVldVol(cOrdSep,cPedido)
Local lRet := .F.                 
Local cSQL := ""
DEFAULT cOrdSep := "" 
DEFAULT cPedido := ""

cSQL := " SELECT "
cSQL += " 	CB7_ORDSEP "
cSQL += " 	FROM "
cSQL += 		RetSQLName("CB7")
cSQL += " 		WHERE "
cSQL += " 			CB7_FILIAL = '"+xFilial("CB7")+"' AND "
cSQL += " 			CB7_PEDIDO = '"+cPedido+"' AND "
cSQL += " 			CB7_ORDSEP = '"+cOrdSep+"' AND "
cSQL += " 			D_E_L_E_T_ = ' ' "

cSQL := ChangeQuery( cSQL )
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),"TRBCB7",.F.,.T. )

lRet := !TRBCB7->(Eof())
TRBCB7->(dbCloseArea())

Return lRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ACDV175   ºAutor  ³Microsiga           º Data ³  02/21/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function DipFinEmb(cPedido,lEstorno)
Local lRet := .F.                 
Local cSQL := ""
DEFAULT cPedido := ""                     
DEFAULT lEstorno:= .F.

cSQL := " SELECT "
cSQL += " 	CB9_ORDSEP "
cSQL += " 	FROM "
cSQL += 		RetSQLName("CB9")
cSQL += " 		WHERE "
cSQL += " 			CB9_FILIAL = '"+xFilial("CB9")+"' AND "
cSQL += " 			CB9_PEDIDO = '"+cPedido+"' AND "
If lEstorno
	cSQL += " 			CB9_STATUS = '3' AND "
Else                                           
	cSQL += " 			CB9_STATUS <> '3' AND "
EndIf	
cSQL += " 			D_E_L_E_T_ = ' ' "

cSQL := ChangeQuery( cSQL )
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),"TRBCB9",.F.,.T. )

lRet := TRBCB9->(Eof())
TRBCB9->(dbCloseArea())    

Return lRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DIPV175X  ºAutor  ³Microsiga           º Data ³  05/30/17   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function DipVldEmb(cPedido)
Local lRet := .F.                 
Local cSQL := ""
DEFAULT cPedido := ""                     

cSQL := " SELECT "
cSQL += "  	SUM(CB9_QTEEBQ) CB9_QTD "
cSQL += " 	FROM "
cSQL +=  		RetSQLName("CB9")
cSQL += " 		WHERE "
cSQL += " 			CB9_FILIAL = '"+xFilial("CB9")+"' AND "
cSQL += " 			CB9_PEDIDO = '"+cPedido+"' AND "
cSQL +=  			RetSQLName("CB9")+".D_E_L_E_T_ = ' ' "

cSQL := ChangeQuery( cSQL )
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),"TDIPCB9",.F.,.T. )

cSQL := " SELECT "
cSQL += "  	SUM(D2_QUANT) D2_QTD "
cSQL += " 	FROM "
cSQL +=  		RetSQLName("SD2")
cSQL += " 		WHERE "
cSQL += " 			D2_FILIAL = '"+xFilial("SD2")+"' AND "
cSQL += " 			D2_PEDIDO = '"+cPedido+"' AND "
cSQL +=  			RetSQLName("SD2")+".D_E_L_E_T_ = ' ' "

cSQL := ChangeQuery( cSQL )
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),"TDIPSD2",.F.,.T. )

If !TDIPSD2->(Eof()) .And. !TDIPCB9->(Eof()) .And. TDIPSD2->D2_QTD==TDIPCB9->CB9_QTD
	lRet := .T.                                             
Else
	U_DiprKardex(CB7->CB7_PEDIDO,U_DipUsr(),"Qtd. NF: "+cValToChar(TDIPSD2->D2_QTD)+" / Qtd. Emb.: "+cValToChar(TDIPCB9->CB9_QTD),.T.,"65")
EndIf                                      

TDIPSD2->(dbCloseArea())
TDIPCB9->(dbCloseArea())

Return lRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ACDV175   ºAutor  ³Microsiga           º Data ³  02/21/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function DipGetPed()
Local cPedido := Space(6)
Local aTela   := VTSave()

@ If(VTModelo()=="RF",2,0),0 VTSay 'Informe o Pedido'
@ If(VTModelo()=="RF",3,1),0 VTSay 'de venda: ' VTGet cPedido PICT "@!"  F3 "CBL"  Valid !Empty(cPedido)

VTRead                                                                        		

VTRestore(,,,,aTela)
If VTLastKey() == 27
 	Return .f.
EndIf      

CB7->(dbSetOrder(2))         
If !CB7->(dbSeek(xFilial("CB7")+cPedido)) 
	VTAlert('Pedido não encontrado...','Aviso',.t.,4000)
	Return .f.	
EndIf

U_DiprKardex(cPedido,U_DipUsr(),DtoC(dDataBase)+"-"+Left(Time(),5),.T.,"63")

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  DipGetNF   ºAutor  Rafaelm Rosa          º Data ³  09/12/22  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Tratamento para buscar pedido pela chave da NFe            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function DipGetNF()
Local cCHVNF := Space(44)
Local cPedido := Space(6)
Local aTela   := VTSave()

@ If(VTModelo()=="RF",2,0),0 VTSay 'Informe a chave'
@ If(VTModelo()=="RF",3,1),0 VTSay 'da NF: ' VTGet cCHVNF PICT "@!"  F3 "CBL"  Valid !Empty(cCHVNF)

VTRead                                                                        		

VTRestore(,,,,aTela)
If VTLastKey() == 27
 	Return .f.
EndIf      

//Verificacao Registros pela SF2 pela Chave do XML
SF2->(dbSetOrder(22))         
If !SF2->(dbSeek(xFilial("SF2")+cCHVNF)) 
	VTAlert('Nota Fiscal não encontrado...','Aviso',.t.,4000)
	Return .f.
EndIf

//Verificacao Registros pela SD2 pela N.Fiscal indexada pela Chave do XML
SD2->(dbSetOrder(3))         
If !SD2->(dbSeek(xFilial("SD2")+ALLTRIM(SF2->F2_DOC)+SF2->F2_SERIE)) 
	VTAlert('Item da Nota Fiscal não encontrado...','Aviso',.t.,4000)
	Return .f.
EndIf

cPedido	:= SD2->D2_PEDIDO
SF2->(dbSkip())
SD2->(dbSkip())

CB7->(dbSetOrder(2))         
If !CB7->(dbSeek(xFilial("CB7")+cPedido)) 
	VTAlert('Pedido não encontrado...','Aviso',.t.,4000)
	Return .f.	
EndIf

U_DiprKardex(cCHVNF,U_DipUsr(),DtoC(dDataBase)+"-"+Left(Time(),5),.T.,"63")

Return .T.      

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DIPV175X  ºAutor  ³Microsiga           º Data ³  07/02/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function DipGrvLog(cPedido,cCodVol,cPedido2)
Local _aMsg      := {}
Local _cFrom     := "protheus@dipromed.com.br"
Local _cFuncSent := "DIPV175X(VldEbqVol)"
//Local _cEnvCic   := GetNewPar("ES_CICEMB" ,"EXPEDICAOCD,DIEGO.DOMINGOS,MAXIMO.CANUTO,JOSE.MAMEDE,LOURIVAL.NUNES,MARCO.AUGUSTO")	
Local _cEnvMail  := GetNewPar("ES_MAILEMB","expedicao@dipromed.com.br;maximo.canuto@dipromed.com.br;jose.mamede@dipromed.com.br;lourival.nunes@dipromed.com.br;emovere02@dipromed.com.br")
Local _cMscCic   := ""                           
DEFAULT cPedido2 := ""

U_DiprKardex(cPedido,U_DipUsr(),"Volume incorreto - "+cCodVol,.T.,"59")
  
/*
_cMscCic += "VOL " +cCodVol + " não pertence ao pedido " +cPedido+" ("+U_DipUsr()+") "
U_DIPCIC(_cMscCic,_cEnvCic)
*/

_cAssunto:= "VOLUME NAO PERTENCE AO PEDIDO "+cPedido+"."
If !Empty(cPedido2)                                        
	Aadd( _aMsg , { "Volume (Pedido): ", cCodVol+" ("+cPedido2+")"	} )
Else
	Aadd( _aMsg , { "Volume: "		 , cCodVol 			} )
EndIf
Aadd( _aMsg , { "Ped. Embarque: "  	 , cPedido			} ) 
Aadd( _aMsg , { "Usuário: "     , U_DipUsr() 			} )
U_UEnvMail(_cEnvMail,_cAssunto,_aMsg,"",_cFrom,_cFuncSent)

Return

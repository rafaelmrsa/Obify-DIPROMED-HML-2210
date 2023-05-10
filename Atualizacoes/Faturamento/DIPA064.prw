#INCLUDE "RWMAKE.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "PROTHEUS.CH"

STATIC lFWCodFil	:= FindFunction("FWCodFil")
STATIC lFindPccBx 	:= FindFunction("FPccBxCr")
STATIC lFindIrBx 	:= FindFunction("FIrPjBxCr")
STATIC lFindAtuSld 	:= FindFunction("AtuSldNat")
STATIC lFina440
STATIC cComiLiq
STATIC lDevolucao
STATIC lComiLiq

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DIPA064   ºAutor  ³Microsiga           º Data ³  12/27/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function DIPA064(aWork)
//Local dDtDe  := FirstDay(ddatabase)
//Local dDtAte := LastDay(ddatabase)

	If ValType(aWork)=="A"
		PREPARE ENVIRONMENT EMPRESA aWork[1] FILIAL aWork[2] FUNNAME "FINA440"
		Conout("DIPA064 - Inicio em: "+DtoC(dDataBase)+" - "+SubStr(Time(),1,2)+":"+SubStr(Time(),4,2)+" Emp:"+aWork[1]+" Fil:"+aWork[2])		
	EndIf
	
	Pergunte("AFI440",.f.)
	MV_PAR01 := FirstDay(ddatabase)
	MV_PAR02 := LastDay(ddatabase)
	MV_PAR03 := ""
	MV_PAR04 := "Z"
	MV_PAR05 := 2
	MV_PAR06 := 1
	MV_PAR07 := 2
	MV_PAR08 := 3
	MV_PAR09 := 1
	MV_PAR10 := 1
	MV_PAR11 := 1
	
	DipDelE3(MV_PAR08)
	DipProcB()        
	
	If ValType(aWork)=="A"	
		RESET ENVIRONMENT
		Conout("DIPA064 - Fim em: "+DtoC(dDataBase)+" - "+SubStr(Time(),1,2)+":"+SubStr(Time(),4,2)+" Emp:"+aWork[1]+" Fil:"+aWork[2])  
	EndIf
Return 
/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³FA440DelE3   ³ Autor ³ Eduardo Riera         ³ Data ³17/12/97³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Zera as comissoes do periodo                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ FINA440                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function DipDelE3(nTipo)

Local aArea		:= GetArea()
Local cChave    := ""
Local cArqInd   := ""
Local nValComis	:= ""
Local lAtuSldNat 		:= lFindAtuSld .AND. AliasInDic("FIV") .AND. AliasInDic("FIW")

#IFDEF TOP
	Local lDelFisico	:= GetNewPar('MV_FIN440D',.T.)
	Local lE3Moeda  	:= SE3->(FieldPos("E3_MOEDA") > 0)
	Local cQuery		:= ""
	Local nX			:= 0
	Local nMax			:= 0
	Local nMin			:= 0
	Local cNatCom		:= PADR(&(GetNewPar("MV_NATCOM","")),TamSx3("E2_NATUREZ")[1])
#ELSE
	Local nIndex    := 0
	Local cNatCom		:= PADR(&(GetNewPar("MV_NATCOM","")),TamSx3("E2_NATUREZ")[1])
#ENDIF

dbSelectArea("SE3")
dbSetOrder(1)
ProcRegua(RecCount())
#IFDEF TOP
	If ( TcSrvType()!="AS/400" ) .And. lDelFisico

		//Atualiza saldo das naturezas antes de deletar as comissoes
		If lAtuSldNat .and. cNatCom != NIL
			cQuery := "SELECT E3_VENCTO, SUM(E3_COMIS) VLRCOMIS , E3_EMISSAO "
			If lE3Moeda
				cQuery += ", E3_MOEDA "
			EndIf
			cQuery += "FROM "+RetSqlName("SE3")+" SE3 "
			cQuery += "WHERE SE3.E3_FILIAL='"+xFilial("SE3")+"' AND "
			cQuery += 	"SE3.E3_EMISSAO>='"+Dtos(mv_par01)+"' AND "
			cQuery += 	"SE3.E3_EMISSAO<='"+Dtos(mv_par02)+"' AND "
			cQuery += 	"SE3.E3_VEND>='"+mv_par03+"' AND "
			cQuery += 	"SE3.E3_VEND<='"+mv_par04+"' AND "
			cQuery += 	"SE3.E3_DATA='"+Dtos(Ctod(""))+"' AND "
			cQuery += 	"SE3.E3_ORIGEM NOT IN(' ','L') AND "
			Do Case
			Case nTipo == 2
				cQuery += "SE3.E3_BAIEMI='E' AND "
			Case nTipo == 3
				cQuery += "SE3.E3_BAIEMI='B' AND "			
			EndCase
			cQuery += 	"SE3.D_E_L_E_T_ = ' ' "
			cQuery += 	"GROUP BY E3_VENCTO , E3_EMISSAO "

			If lE3Moeda
				cQuery += ", E3_MOEDA "
			EndIf			
	
			cQuery := ChangeQuery(cQuery)
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TRBNAT")
		
			TCSetField('TRBNAT','E3_VENCTO','D',8,0)
			TCSetField('TRBNAT','VLRCOMIS' ,'N',17,2)
			TCSetField('TRBNAT','E3_EMISSAO','D',8,0)

		   dbSelectArea("TRBNAT")
			While !Eof()
				// Tratamento de outras moedas no controle de saldos do fluxo de caixa por natureza
				If SE3->(FieldPos("E3_MOEDA")) > 0 .AND. VAL(TRBNAT->E3_MOEDA) > 1
					nValComis := NOROUND(XMOEDA(TRBNAT->VLRCOMIS,01,VAL(TRBNAT->E3_MOEDA),TRBNAT->E3_EMISSAO))
				Else
			   		nValComis := TRBNAT->VLRCOMIS		
				EndIf
				
				//Atualizo o valor atual para o saldo da natureza
				//Diminuo pois as comissoes serao recalculadas e somadas posteriormente
				AtuSldNat(cNatCom, TRBNAT->E3_VENCTO, Iif(SE3->(FieldPos("E3_MOEDA")) > 0,TRBNAT->E3_MOEDA,"01"), "2", "P",nValComis, TRBNAT->VLRCOMIS,"-",,FunName(),"SE3",SE3->(Recno()))
				dbSkip()
			Enddo
			dbCloseArea()
			dbSelectArea("SE3")
		Endif
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica qual eh o maior e o menor Recno que satisfaca a selecao³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cQuery := "SELECT MIN(R_E_C_N_O_) MINRECNO,"
		cQuery += "       MAX(R_E_C_N_O_) MAXRECNO "
		cQuery += "  FROM "+RetSqlName("SE3")+" SE3 "
		cQuery += " WHERE SE3.E3_FILIAL   = '"+xFilial("SE3")+"'"
		cQuery += "   AND SE3.E3_EMISSAO >= '"+Dtos(mv_par01)+"'"
		cQuery += "   AND SE3.E3_EMISSAO <= '"+Dtos(mv_par02)+"'"
		cQuery += "   AND SE3.E3_VEND    >= '"+mv_par03+"'"
		cQuery += "   AND SE3.E3_VEND    <= '"+mv_par04+"'"
		cQuery += "   AND SE3.E3_DATA     = '"+Dtos(Ctod(""))+"'"
		cQuery += "   AND SE3.E3_ORIGEM NOT IN(' ','L') AND "
		Do Case
			Case nTipo == 2
				cQuery += "SE3.E3_BAIEMI='E' AND "
			Case nTipo == 3
				cQuery += "SE3.E3_BAIEMI='B' AND "			
		EndCase
	
		cQuery += 	" SE3.D_E_L_E_T_<>'*'" 
		cQuery := ChangeQuery(cQuery)

	  	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"FA440DELE3")
		
		nMax := FA440DELE3->MAXRECNO
		nMin := FA440DELE3->MINRECNO
		dbCloseArea()
		dbSelectArea("SE3")
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Monta a string de execucao no banco³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cQuery := "DELETE FROM "+RetSqlName("SE3")+" "
		cQuery += " WHERE E3_FILIAL   = '"+xFilial("SE3")+"'"
		cQuery += "   AND E3_EMISSAO >= '"+Dtos(mv_par01)+"'"
		cQuery += "   AND E3_EMISSAO <= '"+Dtos(mv_par02)+"'"
		cQuery += "   AND E3_VEND    >= '"+mv_par03+"'"
		cQuery += "   AND E3_VEND    <= '"+mv_par04+"'"
		cQuery += "   AND E3_DATA     = '"+Dtos(Ctod(""))+"'"
		cQuery += "   AND E3_ORIGEM NOT IN(' ','L') AND "

		Do Case
			Case nTipo == 2
				cQuery += "E3_BAIEMI='E' AND "
			Case nTipo == 3
				cQuery += "E3_BAIEMI='B' AND "
		EndCase              
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Executa a string de execucao no banco para os proximos 1024 registro a fim de nao estourar o log do SGBD³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		For nX := nMin To nMax STEP 1024
			cChave := "R_E_C_N_O_>="+Str(nX,10,0)+" AND R_E_C_N_O_<="+Str(nX+1023,10,0)+""
			TcSqlExec(cQuery+cChave)
		Next nX
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³A tabela eh fechada para restaurar o buffer da aplicacao³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea("SE3")
		dbCloseArea()
		ChkFile("SE3",.F.)
	Else
#ENDIF
	cQuery := 'E3_FILIAL=="'+xFilial("SE3")+'".And.'
	cQuery += 'Dtos(E3_EMISSAO)>="'+Dtos(mv_par01)+'".And.'
	cQuery += 'Dtos(E3_EMISSAO)<="'+Dtos(mv_par02)+'".And.'
	cQuery += 'E3_VEND>="'+mv_par03+'".And.'
	cQuery += 'E3_VEND<="'+mv_par04+'".And.'
	cQuery += 'Dtos(E3_DATA)=="'+Dtos(cTod(""))+'".And.'
	Do Case
	Case nTipo == 2
		cQuery += "E3_BAIEMI='E'.And."
	Case nTipo == 3
		cQuery += "E3_BAIEMI='B' .And."
	EndCase		
	cQuery += '!(E3_ORIGEM$" #L")'
	cArqInd  := CriaTrab(,.F.)
	cChave   := IndexKey()

	nIndex := RetIndex("SE3")
	dbSelectArea("SE3")
	#IFNDEF TOP
		dbSetIndex(cArqInd+OrdBagExt())
	#ENDIF
	dbSelectArea("SE3")
	dbSetOrder(nIndex+1)
	MsSeek(xFilial("SE3"),.T.)

	While ( ! Eof() .And. xFilial("SE3") == SE3->E3_FILIAL )

		//Atualiza saldo das naturezas antes de deletar as comissoes
		If lAtuSldNat .and. cNatCom != NIL
			// Tratamento de outras moedas no controle de saldos do fluxo de caixa por natureza
			If SE3->(FieldPos("E3_MOEDA")) > 0 .AND. VAL(SE3->E3_MOEDA) > 1
				nValComis := NOROUND(XMOEDA(SE3->E3_COMIS,"01",SE3->E3_MOEDA,SE3->E3_EMISSAO))
			Else
		   		nValComis := SE3->E3_COMIS		
			EndIf
			//Diminuo pois as comissoes serao recalculadas e somadas posteriormente
			AtuSldNat(cNatCom, SE3->E3_VENCTO,Iif(SE3->(FieldPos("E3_MOEDA")) > 0, SE3->E3_MOEDA, "01"), "2", "P", nValComis, SE3->E3_COMIS,"-",,FunName(),"SE3",SE3->(Recno()) )
		Endif	

		RecLock("SE3",.F.)
		dbDelete()
		MsUnlock()
		dbSelectArea("SE3")
		dbSkip()
	Enddo
	dbSelectArea("SE3")
	RetIndex("SE3")
	dbClearFilter()
	FErase(cArqInd+OrdBagExt())
	#IFDEF TOP
	EndIf
	#ENDIF
RestArea(aArea)
Return(.T.)
/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³FA440ProcB ³ Autor ³ Eduardo Riera         ³ Data ³ 16/12/97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Processa o c lculo das comissoes pela Baixa                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ FINA440                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function DipProcB()

Local aBaixas 	:= {}
Local aBxEst	:= {}
Local cChave	:= ""
Local cArqInd   := ""
Local cQuebra   := ""
Local cRegPos	:= ""
Local cAliasSE5 := "SE5"   
Local nPos      := 0
#IFDEF TOP
	Local aStruSE5  := {}
	Local cQuery    := ""
#ELSE
	Local nIndex    := 0
#ENDIF

Local nCntFor   := 0
Local cSeekSE5  := ""
Local lQuery    := .F.
Local lGerComNeg := .F.
DEFAULT lFina440	:= FUNNAME() == "FINA440"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³             Array aBaixas             ³
//³                                       ³
//³ 1 : Motivo da Baixa                   ³
//³ 2 : Sequencia da Baixa                ³
//³ 3 : Registro no SE5                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Abre com outro alias para eliminar o filtro do Top Connect ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ( ChkFile("SE5",.F.,"NEWSE5") )
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Selecionando Registros.               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SE5")
	ProcRegua(RecCount())
	If lFina440
		cChave   := "E5_FILIAL+E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR+E5_LOJA+E5_SEQ+DTOS(E5_DATA)+E5_MOTBX"
	Else
		cChave   := "E5_FILIAL+DTOS(E5_DATA)+E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR+E5_LOJA+E5_MOTBX+E5_SEQ"
	Endif

	#IFDEF TOP
		cAliasSE5 := "FA440PROCB"
		lQuery    := .T.
		aStruSE5  := SE5->(dbStruct())
		
		cQuery := "SELECT SE5.*,SE5.R_E_C_N_O_ SE5RECNO "
		cQuery += "FROM "+RetSqlName("SE5") + " SE5 "
		cQuery += "WHERE "
		cQuery += DipChecF()+" AND "
		cQuery += "D_E_L_E_T_=' ' "
		cQuery += "ORDER BY "+SqlOrder(cChave)
		
		cQuery := ChangeQuery(cQuery)
		
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSE5)
		For nCntFor := 1 To Len(aStruSE5)
			If aStruSE5[nCntFor][2] <> "C"
				TcSetField(cAliasSE5,aStruSE5[nCntFor][1],aStruSE5[nCntFor][2],aStruSE5[nCntFor][3],aStruSE5[nCntFor][4])
		    EndIf
		Next nCntFor
	
	#ELSE
		cArqInd  := CriaTrab(,.F.)
		
		nIndex := RetIndex("SE5")
		dbSelectArea("SE5")
		dbSetIndex(cArqInd+OrdBagExt())
		dbSetOrder(nIndex+1)
		MsSeek(xFilial(),.T.)
	#ENDIF
   	
   	If (cAliasSE5)->(FieldPos("E5_FORMAPG")) > 0  .AND.  Alltrim((cAliasSE5)->E5_MOTBX) == "LOJ" // Verifica se possui o campo E5_FORMAPG criado pelo UPDLOJ58.
   		cQuebra := Alltrim((cAliasSE5)->E5_PREFIXO+(cAliasSE5)->E5_NUMERO+(cAliasSE5)->E5_PARCELA+(cAliasSE5)->E5_TIPO+(cAliasSE5)->E5_CLIFOR+(cAliasSE5)->E5_LOJA+(cAliasSE5)->E5_FORMAPG)
   	ElseIf Alltrim((cAliasSE5)->E5_MOTBX) == "LOJ" // Caso nao possua o UPDLOJ58 aplicado utiliza o campo E5_MOEDA. 
   		cQuebra := Alltrim((cAliasSE5)->E5_PREFIXO+(cAliasSE5)->E5_NUMERO+(cAliasSE5)->E5_PARCELA+(cAliasSE5)->E5_TIPO+(cAliasSE5)->E5_CLIFOR+(cAliasSE5)->E5_LOJA+(cAliasSE5)->E5_MOEDA)
   	Else
		cQuebra := Alltrim((cAliasSE5)->E5_PREFIXO+(cAliasSE5)->E5_NUMERO+(cAliasSE5)->E5_PARCELA+(cAliasSE5)->E5_TIPO+(cAliasSE5)->E5_CLIFOR+(cAliasSE5)->E5_LOJA)
    EndIf 

	While ( ! Eof() .And. xFilial("SE5") == (cAliasSE5)->E5_FILIAL )
		If !f440Loja("SE5",cAliasSE5)		// Baixas de Vendas do SIGALOJA nao deve entrar.
			nPos := (TamSx3("E1_PREFIXO")[1]) + (TamSx3("E1_NUM")[1]) + (TamSx3("E1_PARCELA")[1]) + 1			

			If ( (cAliasSE5)->E5_TIPODOC != "ES" .and. !(cAliasSE5)->E5_TIPO $ MVPAGANT) .and. (cAliasSE5)->E5_SITUACA != "C" ;
					.and. (mv_par07 == 1 .or. (mv_par07 == 2 .and. !Substr((cAliasSE5)->E5_DOCUMEN,nPos,3)=="NCC" .And. !(cAliasSE5)->E5_TIPO $ MV_CRNEG))
				aadd(aBaixas,{ (cAliasSE5)->E5_MOTBX,(cAliasSE5)->E5_SEQ,IIF(lQuery,(cAliasSE5)->SE5RECNO,(cAliasSE5)->(Recno())) })
			Elseif (cAliasSE5)->E5_TIPODOC == "ES" .or. (cAliasSE5)->E5_SITUACA == "C"
				aadd(aBxEst, IIF(lQuery,(cAliasSE5)->SE5RECNO,(cAliasSE5)->(Recno())) )
			EndIf
		EndIf

		dbSelectArea(cAliasSE5) 
		//Marca flag para geracao de comissao negativa.
		If (cAliasSE5)->E5_RECPAG=="P".And.(cAliasSE5)->E5_TIPO $ MV_CRNEG
			lGerComNeg := .T.		
		Endif
		(cAliasSE5)->(dbSkip())
		
		If (cAliasSE5)->(FieldPos("E5_FORMAPG")) > 0 .AND. Alltrim((cAliasSE5)->E5_MOTBX) == "LOJ" // Verifica se possui o campo E5_FORMAPG criado pelo UPDLOJ58.
			cRegPos := Alltrim((cAliasSE5)->E5_PREFIXO+(cAliasSE5)->E5_NUMERO+(cAliasSE5)->E5_PARCELA+(cAliasSE5)->E5_TIPO+(cAliasSE5)->E5_CLIFOR+(cAliasSE5)->E5_LOJA+(cAliasSE5)->E5_FORMAPG)
		ElseIf Alltrim((cAliasSE5)->E5_MOTBX) == "LOJ" // Caso nao possua o UPDLOJ58 aplicado utiliza o campo E5_MOEDA. 
			cRegPos := Alltrim((cAliasSE5)->E5_PREFIXO+(cAliasSE5)->E5_NUMERO+(cAliasSE5)->E5_PARCELA+(cAliasSE5)->E5_TIPO+(cAliasSE5)->E5_CLIFOR+(cAliasSE5)->E5_LOJA+(cAliasSE5)->E5_MOEDA)	
		Else 
			cRegPos := Alltrim((cAliasSE5)->E5_PREFIXO+(cAliasSE5)->E5_NUMERO+(cAliasSE5)->E5_PARCELA+(cAliasSE5)->E5_TIPO+(cAliasSE5)->E5_CLIFOR+(cAliasSE5)->E5_LOJA)
		EndIf
		
		If (cQuebra != cRegPos) .OR. Eof()

			If ( !Empty(aBaixas) )
				
				fa440CalcB(aBaixas,If(MV_PAR05==1,.T.,.F.),;
					If(MV_PAR06==1,.T.,.F.),;
					"FINA440",If(lGerComNeg,"-","+"),mv_par03,mv_par04,,,mv_par09)
			EndIf
			If ( !Empty(aBxEst) )
				For nCntFor := 1 To Len(aBxEst)
					aBaixas := {}
					dbSelectArea("NEWSE5")
					MsGoto(aBxEst[nCntFor])
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Caso tenha desconto o MsGoto ira posicionar numa sequencia do SE5       ³
					//³que ja foi processada por isso a verificao abaixo                       ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If cSeekSE5 == NEWSE5->E5_PREFIXO+NEWSE5->E5_NUMERO+NEWSE5->E5_PARCELA+NEWSE5->E5_TIPO+NEWSE5->E5_CLIFOR+NEWSE5->E5_LOJA+NEWSE5->E5_SEQ
						Loop
					EndIf
					cSeekSE5 := NEWSE5->E5_PREFIXO+NEWSE5->E5_NUMERO+NEWSE5->E5_PARCELA+NEWSE5->E5_TIPO+NEWSE5->E5_CLIFOR+NEWSE5->E5_LOJA+NEWSE5->E5_SEQ
					dbSelectArea("NEWSE5")
					dbSetOrder(7)
					MsSeek(xFilial("SE5")+cSeekSE5)
					While ( !Eof() .And. xFilial("SE5")	== NEWSE5->E5_FILIAL .And.;
							cSeekSE5			== NEWSE5->E5_PREFIXO+;
							NEWSE5->E5_NUMERO+;
							NEWSE5->E5_PARCELA+;
							NEWSE5->E5_TIPO+;
							NEWSE5->E5_CLIFOR+;
							NEWSE5->E5_LOJA+;
							NEWSE5->E5_SEQ )
						If ( NEWSE5->E5_TIPODOC != "ES" )
							aadd(aBaixas,{ NEWSE5->E5_MOTBX,NEWSE5->E5_SEQ,NEWSE5->(Recno()) })
						EndIf
						dbSelectArea("NEWSE5")
						dbSkip()
					EndDo
					dbSelectArea(cAliasSE5)
					fa440DeleB(aBaixas,If(MV_PAR05==1,.T.,.F.),;
						If(MV_PAR06==1,.T.,.F.);
						,"FINA440",mv_par03,mv_par04)
				Next nCntFor
			EndIf
			dbSelectArea(cAliasSE5)
			lGerComNeg := .F. 	//Recarrega como falso a variavel para verificacao do titulo seguinte.
			aBaixas := {}
			aBxEst  := {}
			cQuebra :=  (cAliasSE5)->E5_PREFIXO+(cAliasSE5)->E5_NUMERO+(cAliasSE5)->E5_PARCELA+;
				(cAliasSE5)->E5_TIPO+(cAliasSE5)->E5_CLIFOR+(cAliasSE5)->E5_LOJA
		EndIf
	EndDo
	If lQuery
		dbSelectArea(cAliasSE5)
		dbCloseArea()
		dbSelectArea("SE5")
	Else
		dbSelectArea("SE5")
		RetIndex("SE5")
		dbClearFilter()
		FErase(cArqInd+OrdBagExt())
	EndIf
	dbSelectArea("NEWSE5")
	dbCloseArea()
	dbSelectArea("SE5")
Else
	Help(" ",1,"FA440FALHA")
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Atualiza o log de processamento com o erro  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	ProcLogAtu("ERRO","FA440FALHA",Ap5GetHelp("FA440FALHA"))
EndIf

Return(.T.)
/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³FA440ChecF³ Autor ³ Eduardo Riera         ³ Data ³ 01/10/96 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Efetua sele‡„o dos T¡tulos.                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ FINA440                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function DipChecf()
Local cQuery		:= ""

DEFAULT cComiLiq 	:= SuperGetMv("MV_COMILIQ",,"2")
DEFAULT lDevolucao	:= SuperGetMv("MV_COMIDEV")
DEFAULT lComiLiq	:= ComisBx("LIQ") .AND. cComiLiq == "1"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Caso motivo da baixa seja DEVOLUCAO e lCalcComis = .F.	³
//³ NŽO calcula a comiss„o . O Valor de lCalcComis vem do 	³
//³ parƒmetro MV_COMIDEV									³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

cQuery  := "E5_FILIAL='"+xFilial("SE5")+"' AND "

//Verifica se considera a data da baixa ou a data de disponibilidade do titulo
If mv_par09 == 1
	cQuery  += "E5_DATA >= '"+dtos(mv_par01) + "' AND "
	cQuery  += "E5_DATA <= '"+Dtos(mv_par02) + "' AND "
Else
	cQuery  += "E5_DTDISPO >= '"+dtos(mv_par01) + "' AND "
	cQuery  += "E5_DTDISPO <= '"+Dtos(mv_par02) + "' AND "
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Caso parƒmetro MV_COMIDEV = .F.	, desconsidera o baixa de³
//³ titulo por devolucao para fins de recalculo de comissao. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lDevolucao
	cQuery  += "E5_MOTBX <> 'DEV' AND "
Endif

//NAO permitir que se faca calculo de comissao pela geracao da liquidacao e sim pelo metodo novo
If !lComiLiq
	cQuery  += "E5_MOTBX NOT IN('   ','LIQ') AND "
Endif

cQuery  += "(E5_RECPAG='R' OR (E5_RECPAG='P' AND (E5_TIPODOC='ES' Or E5_TIPO IN "+FormatIN(MV_CRNEG,,3)+"))) AND E5_TIPODOC NOT IN('BD','TR') "

Return(cQuery)
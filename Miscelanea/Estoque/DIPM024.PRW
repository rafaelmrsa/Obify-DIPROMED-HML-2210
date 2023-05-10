#INCLUDE "rwmake.ch"

User Function DIPM024() // Antigo EE_009 MCVN - 25/07/2008
Local _xArea   := GetArea()
Local _areaSF3 := SF3->(getarea())
Local cPerg := "DIPM24"

U_DIPPROC(ProcName(0),U_DipUsr()) // JBS 05/10/2005 - Gravando o nome do Programa no SZU

//	MSGSTOP("Voce DEVE ALTERAR O PROGRAMA: ISENTAS NAO É OUTRAS","Usuario sem autorizacao!")
	// ALTERE TAMBEM O CFOP 5949 --> 5911
	//Return


If AllTrim(Upper(U_DipUsr())) <> 'ERIBERTO/EELIAS'
	MSGSTOP("Voce nao é o Eriberto","Usuario sem autorizacao!")
	Return
EndIf

AjustaSX1(cPerg)             // Verifica perguntas. Se nao existe INCLUI

If !Pergunte(cPerg,.T.)     // Solicita parametro
	Return
EndIf

IF MsgBox("Vamos ajustar SF3?","Atencao","YESNO")
	Processa({|lEnd| AjustaF3()},"Ajustando SF3")
	Processa({|lEnd| Ajusta5949()},"Juntando 5949")
EndIf

RestArea(_AreaSF3)
RestArea(_xArea)
Return

//////////////////////////
Static Function AjustaF3()

IF File("\SF3010\SF3010.DBF")
	DbUseArea(.T.,"DBFCDXADS","\SF3010\SF3010.DBF","TRB",.T.,.T.)  //  SO VOU VER EM JUNHO
	//DbUseArea(.T.,,"\SF3010\SF3010.DTC","TRB",.T.,.T.)
	If Select ("TRB") == 0
		MsgBox("Nao foi possivel abrir \SF3010\SF3010.DBF !!!","Atencao","INFO")
		Return( Nil )
	Endif
Else
	MsgBox("Nao encontrei \SF3010\SF3010.DBF !!!","Atencao","INFO")
	Return
Endif

dBSelectArea("SF3")
dbSetOrder(1)  //F3_FILIAL+DTOS(F3_ENTRADA)+F3_NFISCAL+F3_SERIE+F3_CLIEFOR+F3_LOJA+F3_CFO+STR(F3_ALIQICM,5,2)

DbSelectArea("TRB")
DbGoTop()
_cChave  := 'F3_FILIAL+DTOS(F3_ENTRADA)+F3_NFISCAL+F3_SERIE+F3_CLIEFOR+F3_LOJA+F3_CFO+STR(F3_ALIQICM,5,2)'
IndRegua("TRB","SF3010",_cChave,,,"Criando Indice...")
ProcRegua(Reccount())
TRB->(dbSeek("01",.t.))

Do While TRB->(!Eof())
	
	IncProc( "Atualizando " + TRB->F3_NFISCAL )
	
	If !'X' $ AllTrim(TRB->F3_CONTA)  //!AllTrim(TRB->F3_CONTA) $ 'XV/XA/XA1'
	    TRB->(DbSkip())
	    Loop
	EndIf
		
	dbSelectArea("SF3")
	If SF3->(dbSeek(TRB->F3_FILIAL+DTOS(TRB->F3_ENTRADA)+TRB->F3_NFISCAL+TRB->F3_SERIE+TRB->F3_CLIEFOR+TRB->F3_LOJA+TRB->F3_CFO+STR(TRB->F3_ALIQICM,5,2)))
		
		RecLock("SF3",.F.)
		If 'XA' $ AllTrim(TRB->F3_CONTA)
	      SF3->F3_FILIAL := 'XA'
	   EndIf
	   If AllTrim(TRB->F3_CONTA) == 'XV'
	      SF3->F3_CFO    := Subs(SF3->F3_CFO,1,1)+'949'
	      SF3->F3_VALOBSE:= 0
	      SF3->F3_DESPESA:= 0
	      SF3->F3_ISENICM:= 0
	      SF3->F3_BASEICM:= 0
	      SF3->F3_VALICM := 0
	      SF3->F3_ALIQICM:= 0
	      SF3->F3_VALCONT:= Iif(SF3->F3_VALCONT / 1000 < 10,ROUND(SF3->F3_VALCONT / 1000,2)+10,ROUND(SF3->F3_VALCONT / 1000,2))
	      SF3->F3_OUTRICM:= SF3->F3_VALCONT
		EndIf
		SF3->(MsUnlock())
	EndIf
	
	dBSelectArea("TRB")
	TRB->(dBSkip())
	
EndDo 

DbSelectArea("TRB")
DbCloseArea()

Ferase("SF3010"+OrdBagExt())

MsgBox("Atualizei F3","Atencao","INFO")

Return                                                     

///////////////////////////////////////////////////////////
Static Function Ajusta5949()
Local _nValCont := _nIsenIcm := 0
Local _cNfiscal
Local _cSerie
Local _nAliqIcm
Local aUlt_Reg := {}
Local _dUltimoDia

_dUltimoDia := LastDay(MV_PAR01)

dBSelectArea("SF3")
dbSetOrder(1)  //F3_FILIAL+DTOS(F3_ENTRADA)+F3_NFISCAL+F3_SERIE+F3_CLIEFOR+F3_LOJA+F3_CFO+STR(F3_ALIQICM,5,2)
SF3->(dbSeek(xFilial("SF3")+DtoS(MV_PAR01),.T.))
ProcRegua(Reccount())

Do While SF3->(!Eof()) .and. SF3->F3_ENTRADA <= _dUltimoDia
	
	IncProc( "Juntando 5949 " + SF3->F3_NFISCAL + Space(4) + dTOc(SF3->F3_ENTRADA))
	
	If SF3->F3_CFO <> '5949 '
		SF3->(dBSkip())
		Loop
	EndIf

	_cNfiscal := SF3->F3_NFISCAL
	_cSerie   := SF3->F3_SERIE
	_nAliqIcm := SF3->F3_ALIQICM
	_nValCont := 0
	_nOutrIcm := 0

	aadd(aUlt_Reg,{0, "", "", 0, "", 0, 0, 0, 0, 0, "", "", "", "", "", "", "", "", "", "", "", ""})
	Do While SF3->F3_ALIQICM == _nAliqIcm .and. SF3->F3_SERIE == _cSerie .and. SF3->F3_NFISCAL == _cNfiscal
		_nValCont += SF3->F3_VALCONT
		_nOutrIcm += SF3->F3_OUTRICM

		aUlt_Reg[1,1]	 := SF3->F3_ALIQICM
		aUlt_Reg[1,2]	 := SF3->F3_SERIE
		aUlt_Reg[1,3]	 := SF3->F3_NFISCAL
		aUlt_Reg[1,4]	 := SF3->F3_DESPESA
		aUlt_Reg[1,5]	 := SF3->F3_ESPECIE
		aUlt_Reg[1,6]	 := SF3->F3_VALOBSE
		aUlt_Reg[1,7]	 := SF3->F3_ISENICM
		aUlt_Reg[1,8]	 := SF3->F3_VALICM
		aUlt_Reg[1,9]	 := SF3->F3_BASEICM
		aUlt_Reg[1,10]	 := SF3->F3_VALCONT
		aUlt_Reg[1,11]	 := SF3->F3_ENTRADA
		aUlt_Reg[1,12]	 := SF3->F3_EMISSAO
		aUlt_Reg[1,13]	 := SF3->F3_ESTADO
		aUlt_Reg[1,14]	 := SF3->F3_CFO
		aUlt_Reg[1,15]	 := SF3->F3_LOJA
		aUlt_Reg[1,16]	 := SF3->F3_CLIEFOR
		aUlt_Reg[1,17]	 := SF3->F3_REPROC
		aUlt_Reg[1,18]	 := SF3->F3_FILIAL
		aUlt_Reg[1,19]	 := SF3->F3_OBSERV
		aUlt_Reg[1,20]	 := SF3->F3_DTCANC
		aUlt_Reg[1,21]	 := SF3->F3_FORMUL
		aUlt_Reg[1,22]	 := SF3->F3_TIPO

		RecLock("SF3",.F.)
		SF3->F3_REPROC := 'E'
		SF3->(DbDelete())
		SF3->(MsUnLock())

		SF3->(DbSkip())

	EndDo
	
		RecLock("SF3",.T.)
		SF3->F3_ALIQICM := aUlt_Reg[1,1]
		SF3->F3_SERIE	:= aUlt_Reg[1,2]
		SF3->F3_NFISCAL := aUlt_Reg[1,3]
		SF3->F3_DESPESA := aUlt_Reg[1,4]
		SF3->F3_ESPECIE := aUlt_Reg[1,5]
		SF3->F3_VALOBSE := aUlt_Reg[1,6]
		SF3->F3_ISENICM := aUlt_Reg[1,7]
		SF3->F3_VALICM	:= aUlt_Reg[1,8]
		SF3->F3_BASEICM := aUlt_Reg[1,9]
		SF3->F3_VALCONT := _nValCont	 
		SF3->F3_OUTRICM := _nOutrIcm
		SF3->F3_ENTRADA := aUlt_Reg[1,11]
		SF3->F3_EMISSAO := aUlt_Reg[1,12]
		SF3->F3_ESTADO	:= aUlt_Reg[1,13]
		SF3->F3_CFO		:= aUlt_Reg[1,14]
		SF3->F3_LOJA	:= aUlt_Reg[1,15]
		SF3->F3_CLIEFOR := aUlt_Reg[1,16]
		SF3->F3_REPROC	:= aUlt_Reg[1,17]
		SF3->F3_FILIAL	:= aUlt_Reg[1,18]
		SF3->F3_OBSERV  := aUlt_Reg[1,19]
		SF3->F3_DTCANC  := aUlt_Reg[1,20]
		SF3->F3_FORMUL  := aUlt_Reg[1,21]
		SF3->F3_TIPO    := aUlt_Reg[1,22]
		SF3->(MsUnlock())	
	
		SF3->(dBSkip())

EndDo


SF3->(dBSkip(-1))

MsgBox("Juntei 5949  ate: "+dTOc(SF3->F3_ENTRADA),"Atencao","INFO")

Return

/////////////////////////////////////////////////////////////////////////////
Static Function AjustaSX1(cPerg)
_sAlias := Alias()
dbSelectArea("SX1")
dbSetOrder(1) 

cPerg := Padr( cPerg, Len(SX1->X1_GRUPO)," " ) // Incluido por Sandro em 18/11/09 - Virada P10. 

aRegs:={}       

//-----------Grupo/Ordem/Pergunta/PERGING/PERGESP/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05/F3

aAdd(aRegs,{cPerg,"01","Emissao a partir de ?","","","mv_ch1","D",8,0,0,"G","!Empty(MV_PAR01)","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","",""})

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
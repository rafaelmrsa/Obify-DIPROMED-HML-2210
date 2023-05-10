#INCLUDE 'PROTHEUS.CH'              
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³NOVO13    ºAutor  ³Microsiga           º Data ³  01/30/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User function Ganhador()          
	
	If !(Upper(U_DipUsr()) $ 'MCANUTO/DDOMINGOS/VQUEIROZ/VEGON/RBORGES')
		Aviso("Atençaõ","Usuário sem permissão para executar a rotina.",{"Ok"},1)
		Return .F.	
	EndIf
	      
	Processa({|lEnd| CalcGanha()},"Processando...")
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GANHADOR  ºAutor  ³Microsiga           º Data ³  02/01/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function CalcGanha()
Local aContagens := {}
Local aAcertos   := {}              
Local aLog		 := {}
Local cSQL 		 := ""
Local cSQL1		 := ""
Local cSQL2 	 := ""
Local nPos 		 := 0
Local cMsg		 := ""     
Local aJaProc	 := {}
Private aGanhador:= {}           

If cEmpAnt+cFilAnt = '0101'
	Aviso("Atençaõ","Executar a rotina na filial 04",{"Ok"},1)
	Return
EndIf

cSQL1 := " SELECT "
cSQL1 += "	COUNT(CBB_CODINV) QTD, CBB_CODINV "

cSQL2 := " SELECT "
cSQL2 += "	COUNT(1) QTD "

cSQL += "  	FROM "
cSQL += "	    "+RetSQLName("CBB")
cSQL += "		WHERE "   
//cSQL += "			CBB_USU = '000062' AND  " // LINHA PARA TESTE
cSQL += "			D_E_L_E_T_ = ' ' "

cSQL3 := "GROUP BY CBB_CODINV "
cSQL3 += "ORDER BY CBB_CODINV " 

cSQL2 := ChangeQuery(cSQL2+cSQL)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL2),"QRYCBB",.T.,.T.)

ProcRegua(QRYCBB->QTD)
QRYCBB->(dbCloseArea())

cSQL1 := ChangeQuery(cSQL1+cSQL+cSQL3)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL1),"QRYCBB",.T.,.T.)

While !QRYCBB->(Eof())                            
    
	IncProc("Inventário: "+QRYCBB->CBB_CODINV)
	
	If QRYCBB->QTD == 1                                      
		CBC->(dbSetOrder(3))
		If CBC->(dbSeek(xFilial("CBC")+QRYCBB->CBB_CODINV))  
			While !CBC->(Eof()) .AND. CBC->(CBC_FILIAL+CBC_CODINV) == xFilial("CBB")+QRYCBB->CBB_CODINV  
				SomaGanha(POSICIONE("CBB",1,xFilial("CBB")+QRYCBB->CBB_CODINV,"CBB_USU"),.T.)
				CBC->(dbSkip())
			EndDo		
		Else
			Aviso("Atençaõ","Inventario nao encontrado na CBC: "+QRYCBB->CBB_CODINV,{"Ok"},1)
			Return
		EndIf
	Else
		CBC->(dbSetOrder(3))
		If CBC->(dbSeek(xFilial("CBC")+QRYCBB->CBB_CODINV))  
			While !CBC->(Eof()) .AND. CBC->(CBC_FILIAL+CBC_CODINV) == xFilial("CBB")+QRYCBB->CBB_CODINV  		
				If aScan(aJaProc, {|x| x == CBC->(CBC_FILIAL+CBC_CODINV+CBC_COD+CBC_LOCAL+CBC_LOCALI+CBC_LOTECT)}) == 0
					CtgBatida(CBC->CBC_CODINV,CBC->CBC_COD,CBC->CBC_LOTECT,CBC->CBC_LOCAL,CBC->CBC_LOCALI)          
				EndIf
				aAdd(aJaProc, CBC->(CBC_FILIAL+CBC_CODINV+CBC_COD+CBC_LOCAL+CBC_LOCALI+CBC_LOTECT))
				CBC->(dbSkip())
			EndDo
		Else
			Aviso("Atençaõ","Inventario nao encontrado na CBC: "+QRYCBB->CBB_CODINV,{"Ok"},1)
			Return
		EndIf
	EndIf
	QRYCBB->(dbSkip())
EndDo
QRYCBB->(dbCloseArea())

aGanhador := aSort(aGanhador,,,{|x,y| x[3] > y[3]}) 

For nI:= 1 to Len(aGanhador)
	cMsg +=	" "+PadR(AllTrim(Str(aGanhador[nI,2])),10)+";"
	cMsg += " "+PadR(AllTrim(Str(aGanhador[nI,3])),10)+";"
	cMsg += " "+AllTrim(aGanhador[nI,1])+";"
	cMsg += " "+PadR(POSICIONE("CB1",1,xFilial("CB1")+aGanhador[nI,1],"CB1_NOME"),30)
	cMsg += CHR(10)+CHR(13)
Next nI

Aviso("Ganhadores",cMsg,{"Ok"},3)

Return      
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³NOVO13    ºAutor  ³Microsiga           º Data ³  01/30/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function	SomaGanha(cCodUsu,lAcerto)
Local nPos := 0
DEFAULT cCodUsu := ""
DEFAULT lAcerto := .F.

If (nPos:=aScan(aGanhador, {|x| x[1]==cCodUsu}))>0
	aGanhador[nPos,2]++
	If lAcerto
		aGanhador[nPos,3]++			
	EndIf
Else
	aAdd(aGanhador, {cCodUsu,1,IIf(lAcerto,1,0)})
EndIf

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³UACDR030  ºAutor  ³Microsiga           º Data ³  01/23/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function CtgBatida(cCodInv,cProduto,cLote,cLocal,cLocaliz)  
Local cSQL 		 := ""
Local lRet		 := .F.  
Local lFlag		 := .F.
Local aQuant	 := {}
Local nI		 := 0
DEFAULT cCodInv  := "" 
DEFAULT cProduto := ""

cSQL := " SELECT "
cSQL += " 	CBC_QUANT, CBC_NUM, CBC_QTDORI "
cSQL += " 	FROM "
cSQL += " 		"+RetSQLName("CBC")
cSQL += " 		WHERE "
cSQL += " 			CBC_FILIAL 		= '"+xFilial("CBC")+"' "
cSQL += " 			AND CBC_CODINV 	= '"+cCodInv+"' "       
cSQL += " 			AND CBC_COD 	= '"+cProduto+"' "
cSQL += " 			AND CBC_LOTECT 	= '"+cLote+"' "
cSQL += " 			AND D_E_L_E_T_ 	= ' ' "

cSQL := ChangeQuery(cSQL)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),"QRYCBC",.T.,.T.)   

TCSETFIELD("QRYCBC","CBC_QUANT","N",12,4)

While !QRYCBC->(Eof())           
    If aScan(aQuant, {|x| x[1]==QRYCBC->CBC_QUANT})>0    	
       	lRet := .T.
    EndIf
	aAdd(aQuant, {QRYCBC->CBC_QUANT,QRYCBC->CBC_NUM,QRYCBC->CBC_QTDORI})		
	QRYCBC->(dbSkip())
EndDo 
QRYCBC->(dbCloseArea())	
       
If lRet
	For nI := 1 to Len(aQuant)
		SomaGanha(POSICIONE("CBB",3,xFilial("CBB")+cCodInv+aQuant[nI,2],"CBB_USU"),lRet)    		
	Next nI
EndIf

If !lRet .And. Len(aQuant)>0
	cSQL := " SELECT BF_QUANT "
	cSQL += " FROM "+RetSqlName("SBF")
	cSQL += " WHERE BF_FILIAL ='"+xFilial("SBF")+"' AND "
	cSQL += " BF_PRODUTO	  = '"+cProduto  +"' AND "
	cSQL += " BF_LOTECTL 	  = '"+cLote	 +"' AND "
	cSQL += " BF_LOCAL 	      = '"+cLocal	 +"' AND "
	cSQL += " BF_LOCALIZ 	  = '"+cLocaliz  +"' AND "
	cSQL += " D_E_L_E_T_ 	  = ' ' "
	
	cSQL := ChangeQuery(cSQL)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),"QRYSBF",.T.,.T.)   
	           
	TCSETFIELD("QRYSBF","BF_QUANT","N",12,4)
	
	For nI := 1 to Len(aQuant)
		If aQuant[nI,1] == QRYSBF->BF_QUANT .And. aQuant[nI,1] == aQuant[nI,3]
			SomaGanha(POSICIONE("CBB",3,xFilial("CBB")+cCodInv+aQuant[nI,2],"CBB_USU"),.T.)    		
		Else
			SomaGanha(POSICIONE("CBB",3,xFilial("CBB")+cCodInv+aQuant[nI,2],"CBB_USU"),.F.)    					
		EndIf
	Next nI
	QRYSBF->(dbCloseArea())                             	
EndIf

Return
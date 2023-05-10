#INCLUDE "RWMAKE.CH"
#INCLUDE "TBICONN.CH"


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³CORRIGE B2_RESERVA E B2_QPEDVEN AVALIANDO SC6 E SC9³
//³Maximo Canuto Vieira neto  ³  26/04/2007           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
                                                                             

User Function DIPM022(cProdSb2)  //Antigo C6C9B2 - MCVN - 25/07/2008
Local _xArea   := GetArea()
Local _xAreaB2 := ""
Local _xAreaC6 := "" 
Local _xAreaC9 := ""
Local nOpcao   := 0  
Local cCalcDip := {}
Private cGetProd := ""
Private lRetorno := .T.   
Private cProdutos   := "" 


//Default cProdSb2 := ""

    U_DIPPROC(ProcName(0),U_DipUsr()) // JBS 05/10/2005 - Gravando o nome do Programa no SZU
	
	If Empty(cProdSb2)
		If !(Upper(U_DipUsr()) $ 'MCANUTO/EELIAS/DDOMINGOS/VQUEIROZ/VEGON/RBORGES')
			If !InTransact() //-- Não pode exibir mensagem Quando está dentro de Transação
 			MSGSTOP("Voce nao é o MAXIMO","Usuario sem autorizacao!")
	 		EndIf
 			Return
 		EndIf
 	Endif

	_xAreaB2 := SB2->(GetArea())
	_xAreaC6 := SC6->(GetArea())
	_xAreaC9 := SC9->(GetArea())
	
	If !Empty(cProdSb2)
		Processa({|| CORRIGE(cProdSb2) }, "Corrigindo SB2(Estoque) do Produto "+_aErroSb2[mm,1])			
		//CORRIGE(cProdSb2)
	ElseIf !InTransact() //-- Não pode exibir tela se estiver dentro da transação
   	   //	AjustaSX1()
   	   
   	   cGetProd    := Space(1024)

		Do While .t.
	
			Define msDialog oDlg Title "Produtos com problema" From 10,10 TO 19,92
	
			@ 001,002 tO 60,320
			@ 020,010 say "Informe os produtos com problema separados por /: "
			@ 030,010 get cGetProd valid !empty(cGetProd) size 300,12
	
			DEFINE SBUTTON FROM 45,250 TYPE 1 ACTION IF(!empty(cGetProd),(nOpcao:=1,oDlg:End()),msgInfo("informe ao menos um produto","Atenção")) ENABLE OF oDlg
			DEFINE SBUTTON FROM 45,280 TYPE 2 ACTION (nOpcao:=0,oDlg:End()) ENABLE OF oDlg
	
			Activate dialog oDlg centered
	    	   
   	    If nOpcao = 1
   			//If Pergunte("C6C9B2",.T.)
				Processa({|| CORRIGE("") }, "Corrigindo SB2. Aguarde! ...")
			//	MsgBox("B2_RESERVA E B2_QPEDVEN CORRIGIDOS","Atencao","INFO")   
			    Exit
	   		//EndIf        
	   	Else
		   	Exit	
   		Endif
   		Enddo
	Endif      
	RestArea(_xAreaC9)
	RestArea(_xAreaC6)                                                                          
	RestArea(_xAreaB2)
	

RestArea(_xArea)

Return(lRetorno)

//////////////////////////////////////////////////////////////////////////////////////////
Static Function CORRIGE(cProdSb2)

Local nSC6Qpedven := 0
Local nSC6Qqtdemp := 0
Local nSC9Saldo   := 0
Local nSC9Qtdori  := 0 


dBSelectArea("SB2")       
dbSetOrder(1)

//cProdSb2 := Alltrim(cProdSb2)
If !Empty(cProdSb2)  
	If SB2->(dbSeek(xFilial("SB2")+cProdSb2+"01")) 
 	   If Alltrim(SB2->B2_COD) = Alltrim(cProdSb2)

			If SB2->B2_LOCAL = "01"	                                                                       
			
				//***************** QUERY QUE TOTALIZA C6 PARA CORRIGIR SB2********************************
				QRY1 := "SELECT "
				QRY1 += " SUM( CASE WHEN C6_QTDVEN <> C6_QTDENT AND C6_QTDEMP = 0  AND C6_TIPODIP <> '2'  THEN C6_QTDVEN - C6_QTDENT ELSE 0 END) AS nSC6Qpedven, " 	//28/07/09  -  MCVN
				QRY1 += " SUM( CASE WHEN C6_QTDVEN <> C6_QTDENT AND C6_QTDEMP > 0  THEN C6_QTDVEN - C6_QTDENT ELSE 0 END) AS nSC6Qqtdemp "		                                                       				
				QRY1 += " FROM " + RetSQLName("SC6")
				QRY1 += " WHERE C6_FILIAL = '" + xFILIAL("SC6") + "'"
				QRY1 += " AND C6_PRODUTO = '" + SB2->B2_COD + "'"
				QRY1 += " AND C6_LOCAL = '" + SB2->B2_LOCAL +"'"
				QRY1 += " AND "  + RetSQLName("SC6")+".D_E_L_E_T_ = ' '"      

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
				TcQuery QRY1 NEW ALIAS "QRY1"         // Abre uma workarea com o resultado da query
				memowrite('DIPMB2_SC6.SQL',QRY1)  
											
				DbSelectArea("QRY1") 
				QRY1->(DbGoTop())
				nSC6Qpedven := QRY1->nSC6Qpedven
				nSC6Qqtdemp := QRY1->nSC6Qqtdemp
	

				QRY2 := "SELECT "
				QRY2 += " SUM( CASE WHEN C9_QTDORI > 0 THEN C9_QTDORI ELSE 0 END) AS nSC9Qtdori, "
				QRY2 += " SUM( CASE WHEN C9_SALDO  > 0 THEN C9_SALDO  ELSE 0 END) AS nSC9Saldo "
				QRY2 += " FROM " + RetSQLName("SC9")
				QRY2 += " WHERE C9_FILIAL = '" + xFILIAL("SC9") + "'"
				QRY2 += " AND C9_PRODUTO  = '" + SB2->B2_COD + "'"
				QRY2 += " AND C9_LOCAL    = '" + SB2->B2_LOCAL +"'"
				QRY2 += " AND C9_NFISCAL  = ''"								
				QRY2 += " AND "  + RetSQLName("SC9")+".D_E_L_E_T_ = ' '"      
				
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
				memowrite('DIPMB2_SC9.SQL',QRY2)  												
		       
				DbSelectArea("QRY2") 
				QRY2->(DbGoTop())
				nSC9Qtdori := QRY2->nSC9Qtdori
				nSC9Saldo  := QRY2->nSC9Saldo
				
			Endif

	
	    	dBSelectArea("SB2")   
			If (nSC9Qtdori + nSC9Saldo) == nSC6Qqtdemp  // Só grava se o SC6 = SC9
				If (SB2->B2_QATU-SB2->B2_QACLASS) >= nSC9Qtdori
					RecLock("SB2",.F.)
					SB2->B2_QPEDVEN := (nSC9Saldo + nSC6Qpedven)
					SB2->B2_QPEDVE2 := ConvUm(SB2->B2_COD,(nSC9Saldo + nSC6Qpedven),0,2)
					SB2->B2_RESERVA := nSC9Qtdori
					SB2->B2_RESERV2 := ConvUm(SB2->B2_COD,nSC9Qtdori,0,2)
					SB2->(MsUnlock())	
					SB2->(Dbcommit())
					_lCorrige := .T.
				Else   
   					_lCorrige := .F.
				Endif                                                             
			Else
				_lCorrige := .F.					
			Endif				
		Endif                                       
	  Endif                                           
	nSC6Qpedven := 0
	nSC6Qqtdemp := 0
	nSC9Saldo   := 0                                                                     
	nSC9Qtdori  := 0
	                 
	QRY2->(dbCloseArea())
	QRY1->(dbCloseArea())


Else
  //	If Empty(mv_par01)
   //		MsgBox("FAVOR INFORMAR O PRODUTO.","Atencao","INFO")
   //	    RETURN()
   //	Else	
	    cProdutos :=  Alltrim(cGetProd)
		SB2->(dbSeek(xFilial("SB2")+Left(cProdutos,6)))
  //	EndIf

	Do While SB2->(!Eof()) .and. xFILIAL("SB2") == SB2->B2_FILIAL  
 
		If Alltrim(SB2->B2_COD) $ cProdutos

			If SB2->B2_LOCAL = "01"	
				QRY1 := "SELECT "
				QRY1 += " SUM( CASE WHEN C6_QTDVEN <> C6_QTDENT AND C6_QTDEMP = 0  AND C6_TIPODIP <> '2'  THEN C6_QTDVEN - C6_QTDENT ELSE 0 END) AS nSC6Qpedven, " //28/07/09  - MCVN
				QRY1 += " SUM( CASE WHEN C6_QTDVEN <> C6_QTDENT AND C6_QTDEMP > 0  THEN C6_QTDVEN - C6_QTDENT ELSE 0 END) AS nSC6Qqtdemp "
				QRY1 += " FROM " + RetSQLName("SC6")
				QRY1 += " WHERE C6_FILIAL = '" + xFILIAL("SC6") + "'"
				QRY1 += " AND C6_PRODUTO = '" + SB2->B2_COD + "'"
				QRY1 += " AND C6_LOCAL = '" + SB2->B2_LOCAL +"'"
				QRY1 += " AND "  + RetSQLName("SC6")+".D_E_L_E_T_ = ' '"      

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
				TcQuery QRY1 NEW ALIAS "QRY1"         // Abre uma workarea com o resultado da query
				memowrite('DIPMB2_SC6.SQL',QRY1)  
											
				DbSelectArea("QRY1") 
				QRY1->(DbGoTop())
				nSC6Qpedven := QRY1->nSC6Qpedven
				nSC6Qqtdemp := QRY1->nSC6Qqtdemp
				QRY1->(dbCloseArea())
				
       
		
				QRY2 := "SELECT "
				QRY2 += " SUM( CASE WHEN C9_QTDORI > 0 THEN C9_QTDORI ELSE 0 END) AS nSC9Qtdori, "
				QRY2 += " SUM( CASE WHEN C9_SALDO  > 0 THEN C9_SALDO  ELSE 0 END) AS nSC9Saldo "
				QRY2 += " FROM " + RetSQLName("SC9")
				QRY2 += " WHERE C9_FILIAL = '" + xFILIAL("SC9") + "'"
				QRY2 += " AND C9_PRODUTO  = '" + SB2->B2_COD + "'"
				QRY2 += " AND C9_LOCAL    = '" + SB2->B2_LOCAL +"'"
				QRY2 += " AND C9_NFISCAL  = ''"								
				QRY2 += " AND "  + RetSQLName("SC9")+".D_E_L_E_T_ = ' '"      
				
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
				memowrite('DIPMB2_SC9.SQL',QRY2)  												
		       
				DbSelectArea("QRY2") 
				QRY2->(DbGoTop())
				nSC9Qtdori := QRY2->nSC9Qtdori
				nSC9Saldo  := QRY2->nSC9Saldo
				QRY2->(dbCloseArea())
				
           Endif
			
		   dBSelectArea("SB2")   
		   If (nSC9Qtdori + nSC9Saldo) == nSC6Qqtdemp  // Só grava se o SC6 = SC9
		       If (SB2->B2_QATU-SB2->B2_QACLASS) >= nSC9Qtdori
			   		RecLock("SB2",.F.)  
					SB2->B2_QPEDVEN := (nSC9Saldo + nSC6Qpedven)
					SB2->B2_QPEDVE2 := ConvUm(SB2->B2_COD,(nSC9Saldo + nSC6Qpedven),0,2)
					SB2->B2_RESERVA := nSC9Qtdori
					SB2->B2_RESERV2 := ConvUm(SB2->B2_COD,nSC9Qtdori,0,2)
					SB2->(MsUnlock())	
					SB2->(Dbcommit())
			   Endif		
		   Endif
  		Endif  
	nSC6Qpedven := 0
	nSC6Qqtdemp := 0
	nSC9Saldo   := 0
	nSC9Qtdori  := 0
	
	SB2->(dBSkip())  
	  
	EndDo    

Endif

Return()
     


////////////////////////////////////////////////////////////////////////////
Static Function AjustaSX1()
Local i,j
_sAlias := Alias()
cPerg := "DIPM022"

dbSelectArea("SX1")
dbSetOrder(1)

cPerg := PADR(cPerg, Len(SX1->X1_GRUPO)," " ) // Incluido por Sandro em 18/11/09.

aRegs:={}

//------------ Grupo/Ordem/Pergunta/PERGING/PERGESP/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05/F3
AADD(aRegs,{cPerg,"01","Do Produto         ?","","","mv_ch1","C",15,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","SB1"})
AADD(aRegs,{cPerg,"02","Ate o Produto      ?","","","mv_ch2","C",15,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","SB1"})

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

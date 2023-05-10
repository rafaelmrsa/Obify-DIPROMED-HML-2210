#include 'protheus.ch'
#include 'parmtype.ch'
#include "topconn.ch"
#INCLUDE "FWMVCDEF.CH"
#include "TbiConn.ch"
/*
ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½
ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½
ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½Í»ï¿½ï¿½
ï¿½ï¿½ï¿½Programa  ï¿½ DIPCONV ï¿½Autor  ï¿½ Delta Decisï¿½o		 ï¿½ Data ï¿½  05/09/19   ï¿½ï¿½ï¿½
ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½Í¹ï¿½ï¿½
ï¿½ï¿½ï¿½Desc.     ï¿½ Rotina para gerar arquivo para Convatec			          ï¿½ï¿½ï¿½
ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½Í¹ï¿½ï¿½
ï¿½ï¿½ï¿½Uso       ï¿½ DIPROMED                                                   ï¿½ï¿½ï¿½
ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½Í¼ï¿½ï¿½
ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½
ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½
*/
User Function DIPCONV(lJob,nTipo,cDesc)

Local aRet		:= {}
Local aParamBox	:= {}
Local aCombo	:= {}
Local cDe		:= ""
Local cAte		:= ""
Local c2De  	:= ""
Local c2Ate 	:= ""
Local cQuery  	:= ""
Local _cAlias 	:= ""
Local _c1Alias 	:= ""
Local _Qry1		:= ""
Local _Qry2 	:= ""
Local _Qry3		:= ""
Local cDtValid	:= ""
Local cDtEmiss	:= ""
Local lParam	:= .F.
Local lNaoAchou	:= .F.
Local nTam		:= 0
Local cHora		:= Time()
Local lExit 	:= .F.
Local cCodBar	:= ""
Local dDataDe  	:= FirstDate()
Local dDataAt 	:= LastDate(date())
Local _cTexto 	:=  ""
Local cFile		:= 	""

Private cArqTxt   := "_"+DToS(dDataBase)+".txt"
Private cLocDir   := ""
Private nHdl      := 0

Default lJob 	:= .F.
Default nTipo	:= 0
Default cDesc	:= ""


//DbSelectArea("ZAA")



If !lJob

	aCombo	:= {"1=Clientes","2=Produtos","3=Estoques","4=Pedidos"}
	
	aAdd(aParamBox,{2,"Informe o tipo do arquivo",1,aCombo,90,"",.F.})
	
	If ParamBox(aParamBox,"Convatec",@aRet)
	
		nTipo		:= aRet[1]
		aParamBox	:= {}
		aRet		:= {}

		If Valtype(nTipo) == 'C'
			nTipo := Val(nTipo)
		EndIf	
		
		If nTipo == 1
			nTam := TamSX3("A1_COD")[1]
			aAdd(aParamBox,{1,"Cliente De" ,Space(nTam),"","","SA1","",0,.F.})
			aAdd(aParamBox,{1,"Cliente Ate",Space(nTam),"","","SA1","",0,.F.})
			aAdd(aParamBox,{1,"Data De" ,dDataDe,"",".T.","",".T.",80,.F.})
			aAdd(aParamBox,{1,"Data Ate" ,dDataAt,"",".T.","",".T.",80,.T.})
			cDesc := "Clientes"		
		ElseIf nTipo == 2
			nTam := TamSX3("B1_COD")[1]
			aAdd(aParamBox,{1,"Produto De" ,Space(nTam),"","","SB1","",0,.F.})
			aAdd(aParamBox,{1,"Produto Ate",Space(nTam),"","","SB1","",0,.F.})
			cDesc := "Produtos"
		ElseIf nTipo == 3
			nTam := TamSX3("B1_COD")[1]
			aAdd(aParamBox,{1,"Produto De" ,Space(nTam),"","","SB1","",0,.F.})
			aAdd(aParamBox,{1,"Produto Ate",Space(nTam),"","","SB1","",0,.F.})
			nTam := TamSX3("B2_LOCAL")[1]
			aAdd(aParamBox,{1,"Armazem De" ,Space(nTam),"","","SB2","",0,.F.})
			aAdd(aParamBox,{1,"Armazem Ate",Space(nTam),"","","SB2","",0,.F.})
			cDesc := "Estoques"
		ElseIf nTipo == 4
			nTam := TamSX3("C5_NUM")[1]
			aAdd(aParamBox,{1,"Pedido De" ,Space(nTam),"","","SC5","",0,.F.})
			aAdd(aParamBox,{1,"Pedido Ate",Space(nTam),"","","SC5","",0,.F.})
			aAdd(aParamBox,{1,"Data De" ,dDataDe,"",".T.","",".T.",80,.F.})
			aAdd(aParamBox,{1,"Data Ate" ,dDataAt,"",".T.","",".T.",80,.T.})
			cDesc := "Pedidos"
		EndIf
		
		If ParamBox(aParamBox,cDesc,@aRet)		
			cDe  := aRet[1]
			cAte := aRet[2]
			If nTipo == 1
				d2De	:= aRet[3]
				d2Ate	:= aRet[4]
			EndIf
			If nTipo == 3
				c2De  := aRet[3]
				c2Ate := aRet[4]
			EndIf		
			If nTipo == 4
				d2De	:= aRet[3]
				d2Ate	:= aRet[4]
			EndIf
		EndIf		
	EndIf
	
	cLocDir := cGetFile("\", "Selecione o Diretorio p/ Gerar o Arquivo",,,,GETF_RETDIRECTORY+GETF_LOCALHARD+GETF_LOCALFLOPPY/*128+GETF_NETWORKDRIVE*/)
	
Else

	d2De 	:= (ddatabase -30)
	d2Ate	:= (ddatabase -1) 
	nTipo := Val(nTipo)
	cLocDir := SupergetMV("MV_XPCONV",,"D:\P12\PROTHEUS_DATA\CONVATEC\ENTRADA")	

EndIf

If lJob
	cArqTxt := cDesc+cArqTxt
	ConvCriaArq(cArqTxt, cLocDir,cDesc)
EndIf

If !lJob
	cArqTxt := cDesc+cArqTxt
	nHdl    := fCreate(cLocDir+cArqTxt)	
EndIf

Begin Transaction

	_cTexto := "" 	

	If nTipo == 1
		Conout("Inicio Clientes...")
		//*****************************************************************************************************************
		// CLIENTES
		//*****************************************************************************************************************	
		cQuery := " SELECT DISTINCT SA1.R_E_C_N_O_ AS RECSA1, SA1.A1_FILIAL AS FILIAL " + CRLF
		
		If lJob
			cQuery += " , ZAA.* " + CRLF
		EndIf
		
		cQuery += " FROM " + RetSqlName("SA1") + " SA1 " + CRLF
			
		If lJob
			cQuery += " LEFT JOIN " + RetSqlName("ZAA") + " ZAA " + CRLF
			cQuery += " ON SA1.R_E_C_N_O_ = ZAA.ZAA_RECTAB AND ZAA.D_E_L_E_T_ = ' ' AND ZAA_FILIAL = '" + xFilial("ZAA") + "' " + CRLF
			cQuery += " WHERE SA1.D_E_L_E_T_ = ' ' AND SA1.A1_FILIAL = '" + xFilial("SA1") + "' AND SA1.A1_MSBLQL <> '1' " + CRLF
			cQuery += " AND A1_COD IN (SELECT D2_CLIENTE FROM SD2010 WHERE 	D2_EMISSAO BETWEEN '" + DTOS(dDataBase-30) +"' AND '" + DTOS(dDataBase-1) + "' AND D2_FORNEC ='100269' AND D_E_L_E_T_ = '' AND D2_TIPO = 'N')" + CRLF
		EndIf
      	
		If !lJob
			cQuery += " WHERE SA1.D_E_L_E_T_ = ' ' AND SA1.A1_FILIAL = '" + xFilial("SA1") + "' AND SA1.A1_MSBLQL <> '1' " + CRLF
			cQuery += " AND A1_COD IN (SELECT D2_CLIENTE FROM SD2010 WHERE 	D2_EMISSAO BETWEEN '" + DTOS(d2De) +"' AND '" + DTOS(d2Ate) + "' AND D2_FORNEC ='100269' AND D_E_L_E_T_ = '' AND D2_TIPO = 'N')" + CRLF
			cQuery += " AND SA1.A1_COD BETWEEN '" + cDe + "' AND '" + cAte + "' " + CRLF
		Else		
			cQuery += " AND ZAA.ZAA_TABELA IS NULL " + CRLF
			cQuery += " ORDER BY SA1.A1_FILIAL " + CRLF			
		EndIf
		
		cQuery := ChangeQuery(cQuery)
		_cAlias:= GetNextAlias()
		If Select(_cAlias) > 0;( _cAlias )->( dbCloseArea() );EndIf
			dbUseArea(.t., "TOPCONN", TCGenQry(,,cQuery), _cAlias, .t., .t.)
			( _cAlias )->( dbGoTop() )
		If ( ( _cAlias )->( !Eof() ) )
		
			cLin   := "CNPJ_CPF_CLIENTE;RAZAO_SOCIAL_CLIENTE;NOME_FANTASIA_CLIENTE;COD_MUNICIPIO_IBGE;RUA_END_CLIENTE;NUMERO_END_CLIENTE;COMPLEMENTO_END_CLIENTE;"
			cLin   += "CEP_END_CLIENTE;BAIRRO_END_CLIENTE;MUNICIPIO_END_CLIENTE;UF_END_CLIENTE;TEL_END_CLIENTE;EMAIL_END_CLIENTE;DATA_CADASTRO_CLIENTE;"
			cLin   += "DATA_DESATIVACAO_CLIENTE;FLAG_ATIVO_CLIENTE;CNAE"
			cLin   += CRLF
			
			_cTexto += cLin
			
			If !lJob
				If fWrite(nHdl,cLin,Len(cLin)) != Len(cLin)
					If !MsgAlert(OemToAnsi("Ocorreu um erro na gravacao do arquivo. Continua ? "),OemToAnsi("Atenï¿½ï¿½o ! "))
						DisarmTransaction()
						lExit := .T.
					EndIf
				EndIf
			EndIf
			If lJob
				//U_DipGerConv(aCabec,aDetal,cNomArq)
			EndIf

			If !lExit
			
				While ( ( _cAlias )->( !Eof() ) )
					
					DbSelectArea("SA1")
					SA1->(DbGoTo(( _cAlias )->RECSA1))
					
					If Empty(SA1->A1_CGC)
						Alert("Campo A1_CGC obrigatï¿½rio vazio. Processo abortado. Cliente/Loja: " + SA1->A1_COD+"/"+SA1->A1_LOJA)
						DisarmTransaction()
						lExit := .T.
						Exit
					EndIf  				
					If Empty(SA1->A1_NOME)
						Alert("Campo A1_NOME obrigatï¿½rio vazio. Processo abortado. Cliente/Loja: " + SA1->A1_COD+"/"+SA1->A1_LOJA)
						DisarmTransaction()
						lExit := .T.
						Exit
					EndIf 
					If Empty(SA1->A1_NREDUZ)
						Alert("Campo A1_NREDUZ obrigatï¿½rio vazio. Processo abortado. Cliente/Loja: " + SA1->A1_COD+"/"+SA1->A1_LOJA)
						DisarmTransaction()
						lExit := .T.
						Exit
					EndIf 
					If Empty(SA1->A1_COD_MUN)
						Alert("Campo A1_COD_MUN obrigatï¿½rio vazio. Processo abortado. Cliente/Loja: " + SA1->A1_COD+"/"+SA1->A1_LOJA)
						DisarmTransaction()
						lExit := .T.
						Exit
					EndIf 
					If Empty(SA1->A1_END)
						Alert("Campo A1_END obrigatï¿½rio vazio. Processo abortado. Cliente/Loja: " + SA1->A1_COD+"/"+SA1->A1_LOJA)
						DisarmTransaction()
						lExit := .T.
						Exit
					EndIf 
					If Empty(SA1->A1_CEP)
						Alert("Campo A1_CEP obrigatï¿½rio vazio. Processo abortado. Cliente/Loja: " + SA1->A1_COD+"/"+SA1->A1_LOJA)
						DisarmTransaction()
						lExit := .T.
						Exit
					EndIf 
					If Empty(SA1->A1_BAIRRO)
						Alert("Campo A1_BAIRRO obrigatï¿½rio vazio. Processo abortado. Cliente/Loja: " + SA1->A1_COD+"/"+SA1->A1_LOJA)
						DisarmTransaction()
						lExit := .T.
						Exit
					EndIf 
					If Empty(SA1->A1_MUN)
						Alert("Campo A1_MUN obrigatï¿½rio vazio. Processo abortado. Cliente/Loja: " + SA1->A1_COD+"/"+SA1->A1_LOJA)
						DisarmTransaction()
						lExit := .T.
						Exit
					EndIf 
					If Empty(SA1->A1_EST)
						Alert("Campo A1_EST obrigatï¿½rio vazio. Processo abortado. Cliente/Loja: " + SA1->A1_COD+"/"+SA1->A1_LOJA)
						DisarmTransaction()
						lExit := .T.
						Exit
					EndIf 
					
					cLin   := Alltrim(Left(SA1->A1_CGC,14))+";"+Alltrim(Left(SA1->A1_NOME,50))+";"+Alltrim(Left(SA1->A1_NREDUZ,50))+";"+Alltrim(Left(SA1->A1_COD_MUN,20))+";"
					cLin   += Alltrim(Left(StrTran(SA1->A1_END,";",""),150))+";"+Alltrim(Left("",10))+";"
					cLin   += Alltrim(Left(StrTran(SA1->A1_COMPLEM,";",""),100))+";"+Alltrim(Left(SA1->A1_CEP,8))+";"+Alltrim(Left(SA1->A1_BAIRRO,50))+";"
					cLin   += Alltrim(Left(SA1->A1_MUN,100))+";"+Alltrim(Left(SA1->A1_EST,2))+";"
					cLin   += Alltrim(Left(SA1->A1_TEL,50))+";"+SubStr(SA1->A1_EMAIL,1,At(";",SA1->A1_EMAIL)-1)+";"+Alltrim(Left("",10))+";"+Alltrim(Left("",10))+";"
					cLin   += Alltrim(Left("",1))+";"+Alltrim(Left("",7))+";"
					cLin   +=CRLF	


					_cTexto+=cLin

					If !lJob
						If fWrite(nHdl,cLin,Len(cLin)) != Len(cLin)
							If !MsgAlert(OemToAnsi("Ocorreu um erro na gravacao do arquivo. Continua ? "),OemToAnsi("Atenï¿½ï¿½o ! "))
								DisarmTransaction()
								lExit := .T.
								Exit
							EndIf
						EndIf
					EndIf
	

					//-------------------------------------------------------------------------
					// Geraï¿½ï¿½o de LOG DE GERAï¿½ï¿½O DE ARQUIVO
					//-------------------------------------------------------------------------  				
					ZAALOG(		"SA1"										,; // Tabela
								SA1->(Recno())								,; // Recno
					  			cHora										,; // Hora
								cArqTxt										,; // Arquivo
								SA1->A1_FILIAL+SA1->A1_COD+SA1->A1_LOJA		 ) // Primeiro Indice				
								
					( _cAlias )->( dbSkip() )
				EndDo
				If lJob //Cliente
					cFile := "\CONVATEC\ENTRADA\CLIENTES_"+DToS(dDataBase)+".txt"
					MemoWrite(cFile, _cTexto)
					Conout("Arquivo Clientes gerado com sucesso!")
				EndIf
			EndIf
		Else
			lNaoAchou := .T.
		EndIf
		If Select(_cAlias) > 0;( _cAlias )->( dbCloseArea() );EndIf 
	
	ElseIf nTipo == 2	
		Conout("Inicio Produtos...")
		//*****************************************************************************************************************
		// PRODUTOS
		//***************************************************************************************************************** 	
		cQuery := " SELECT SB1.R_E_C_N_O_ AS RECSB1, SB1.B1_COD AS COD, SB1.B1_PROC AS FORNEC, SB1.B1_LOJPROC AS LOJPROC, SB1.B1_FILIAL AS FILIAL  " + CRLF
		If lJob
			cQuery += " , ZAA.* " + CRLF
		EndIf
		cQuery += " FROM " + RetSqlName("SB1") + " SB1 " + CRLF
		
		If lJob
			cQuery += " LEFT JOIN " + RetSqlName("ZAA") + " ZAA " + CRLF
			cQuery += " ON SB1.R_E_C_N_O_ = ZAA.ZAA_RECTAB AND ZAA.D_E_L_E_T_ = ' ' AND ZAA_FILIAL IN ('01','04')" + CRLF
		EndIf
		
		cQuery += " WHERE SB1.D_E_L_E_T_ = ' ' AND B1_FILIAL IN ('01','04') AND B1_MSBLQL <> '1' " + CRLF
		If !lJob
			If MsgYesNo("Considera produtos em Z ?")
				cQuery += " AND B1_PROC = '100269' AND B1_UCOM > '20180101' AND B1_DESC NOT LIKE'.%' Or B1_COD In ('080888','080885','010942','456012','080873','425142','010945')" + CRLF
			Else
				cQuery += " AND B1_PROC = '100269' AND B1_DESC NOT LIKE 'Z%' and B1_DESC NOT LIKE'.%' Or B1_COD In ('080888','080885','010942','456012','080873','425142','010945')" + CRLF
			Endif	
		Else
			cQuery += " AND B1_PROC = '100269' AND B1_DESC NOT LIKE 'Z%' and B1_DESC NOT LIKE'.%' Or B1_COD In ('080888','080885','010942','456012','080873','425142','010945')" + CRLF
		Endif

		If !lJob
			cQuery += " AND B1_COD BETWEEN '" + cDe + "' AND '" + cAte + "' " + CRLF			
		Else
			cQuery += " AND ZAA.ZAA_TABELA IS NULL " + CRLF
			cQuery += " ORDER BY B1_FILIAL " + CRLF
			
		EndIf 
		
		 
		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), '_Qry2', .F., .T.)
		DbSelectArea("_Qry2")
		_Qry2->(dbGotop())

		If _Qry2->( !Eof() ) 
	
		
			cLin   := "EAN_PRODUTO (CODIGO SAP);ID_DISTRIBUIDOR;ID_PRODUTO_DISTRIBUIDOR;BOM (lista de materiais) **KIT**;QTD_PRODUTO "
			cLin   += CRLF

			_cTexto+=cLin

			If !lJob
				If fWrite(nHdl,cLin,Len(cLin)) != Len(cLin)
					If !MsgAlert(OemToAnsi("Ocorreu um erro na gravaï¿½ï¿½o do arquivo. Continua ? "),OemToAnsi("Atenï¿½ï¿½o ! "))
						DisarmTransaction()
						lExit := .T.
					EndIf
				EndIf
			EndIf

			If !lExit	
			
				While  _Qry2 ->( !Eof() )
				
					cSb1Proc := _Qry2 ->FORNEC
					cSb1Loj  := _Qry2->LOJPROC
					cSb1Prod := _Qry2->COD
					cSb1Filial := _Qry2->FILIAL
					

					If cSb1Proc == "100269"
						DbSelectArea("SA5")
						DBSetOrder(2)
						If SA5->(MsSeek( xFilial("SA5") + ("SB1")->(cSb1Prod+cSb1Proc+cSb1Loj) ))
							cCodBar  := U_TiraZeros(SA5->A5_CODPRF)
						Else
							cCodBar := "NAO ENCONTRADO"
					EndIf
					cLin   := Alltrim(Left(cCodBar,50))+";"
					If cSb1Filial = '01'
						cLin   += Alltrim(Left('47869078000100',14))+";"
					ElseIf cSb1Filial = '04'
						cLin   += Alltrim(Left('47869078000453',14))+";"
					EndIf	
					cLin   += Alltrim(Left(cSb1Prod,50))+";"+Alltrim(Left("",50))
					cLin   += CRLF

					_cTexto+=cLin
					
					
					If !lJob
						If fWrite(nHdl,cLin,Len(cLin)) != Len(cLin)
							If !MsgAlert(OemToAnsi("Ocorreu um erro na gravaï¿½ï¿½o do arquivo. Continua ? "),OemToAnsi("Atenï¿½ï¿½o ! "))
								DisarmTransaction()
								lExit := .T.
								Exit
							EndIf
						EndIf
					EndIf

					//-------------------------------------------------------------------------
					// Geraï¿½ï¿½o de LOG DE GERAï¿½ï¿½O DE ARQUIVO
					//-------------------------------------------------------------------------  				
					ZAALOG(		"SB1"										,; // Tabela
								SB1->(Recno())								,; // Recno
					  			cHora										,; // Hora
								cArqTxt										,; // Arquivo
								SB1->B1_FILIAL+SB1->B1_COD					 ) // Primeiro Indice
						
					_Qry2->( dbSkip() )
				
			EndIf
			EndDo
			If lJob //Produto
				cFile := "\CONVATEC\ENTRADA\PRODUTOS_"+DToS(dDataBase)+".txt"				
				MemoWrite( cFile, _cTexto)
				Conout("Arquivo Estoque gerado com sucesso!")
			EndIf
			EndIf
		Else
			lNaoAchou := .T.
		EndIf
		If Select(_Qry2) > 0; _Qry2->( dbCloseArea() );EndIf 			
	
	ElseIf nTipo == 3
		Conout("Inicio Estoques...")
		//*****************************************************************************************************************
		// ESTOQUES
		//*****************************************************************************************************************
		cQuery := " SELECT DISTINCT SB2.R_E_C_N_O_ AS RECSB2, Sb2.B2_COD AS COD, SB2.B2_FILIAL AS FILIAL, SB2.B2_LOCAL AS LOCAL1, SB2.B2_QATU AS QATU, SB2.B2_CM1 AS CM1   " + CRLF
		If lJob
			cQuery += " , ZAA.* " + CRLF
		EndIf
		cQuery += " FROM " + RetSqlName("SB2") + " SB2 " + CRLF
		
		If lJob
			cQuery += " LEFT JOIN " + RetSqlName("ZAA") + " ZAA " + CRLF
			cQuery += " ON SB2.R_E_C_N_O_ = ZAA.ZAA_RECTAB AND ZAA.D_E_L_E_T_ = ' ' AND ZAA_FILIAL IN ('01','04') " + CRLF
		EndIf
		
		cQuery+= "LEFT JOIN SB1010 on (B1_COD = B2_COD)"
		cQuery += " WHERE SB2.D_E_L_E_T_ = ' ' AND B2_FILIAL IN ('01','04') AND B2_QATU > 0 " + CRLF
		
		If !lJob
			cQuery 	+= " AND B2_COD BETWEEN '" + cDe + "' AND '" + cAte + "' " + CRLF
			cQuery 	+= " AND B2_LOCAL BETWEEN '" + c2De + "' AND '" + c2Ate + "' " + CRLF
			cQuery	+= "AND B1_PROC = '100269' AND B1_DESC NOT LIKE 'Z%' and B1_DESC NOT LIKE'.%'" + CRLF
		Else
			cQuery	+= "AND B1_PROC = '100269' AND B1_DESC NOT LIKE 'Z%' and B1_DESC NOT LIKE'.%'" + CRLF
			cQuery 	+= " AND ZAA.ZAA_TABELA IS NULL " + CRLF
			cQuery 	+= " ORDER BY B2_FILIAL " + CRLF
			
			//cQuery += " AND B2_COD BETWEEN 'R00001         ' AND 'V00003         ' " + CRLF //////////////////////
		EndIf
		
		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), '_Qry3', .F., .T.)
		DbSelectArea("_Qry3")
		_Qry3->(dbGotop())

		If _Qry3->( !Eof() ) 
		
			cLin   := "ID_PRODUTO_DISTRIBUIDOR;CNPJ_DISTRIBUIDOR;QUANTIDADE_ATUAL_ESTOQUE;VALOR_CUSTO_UNITARIO_ESTOQUE;VALOR_CUSTO_TOTAL_ESTOQUE;IS_FRACIONADO;"
			cLin   += "DATA_DE_VALIDADE"
			cLin   += CRLF

			_cTexto+=cLin

			
			If !lJob
				If fWrite(nHdl,cLin,Len(cLin)) != Len(cLin)
					If !MsgAlert(OemToAnsi("Ocorreu um erro na gravaï¿½ï¿½o do arquivo. Continua ? "),OemToAnsi("Atenï¿½ï¿½o ! "))
						DisarmTransaction()
						lExit := .T.
					EndIf
				EndIf
			EndIf

			If !lExit
			
				While  _Qry3 ->( !Eof() )
					
					cSb2Cod		:= _Qry3->COD				
					cSb2Filial	:= _Qry3->FILIAL
					cSb2Qatu	:= _Qry3->QATU
					cSb2Cm1		:= _Qry3->CM1
					cSb2Local	:= _Qry3->LOCAL1
					nCaixa		:= ''

					DbSelectArea("SB1")
					DbSetOrder(1)
					DbSeek(cSb2Filial+cSb2Cod)

					If SB1->B1_UM == 'CX'
						nCaixa := '0'
					Else
						nCaixa := '1'
					EndIf

					cQuery := " SELECT TOP 1 SB8.B8_DTVALID " + CRLF		
					cQuery += " FROM " + RetSqlName("SB8") + " SB8 " + CRLF		
					cQuery += "Left Join SB8010 on (SB8.B8_PRODUTO = '" + cSb2Cod + "')"
					cQuery += " WHERE SB8.D_E_L_E_T_ = ' ' AND SB8.B8_FILIAL IN ('01','04') " + CRLF
					cQuery += " AND SB8.B8_LOCAL = '" + cSb2Local + "' AND SB8.B8_PRODUTO = '" + cSb2Cod + "' "	+ CRLF
					cQuery += " AND SB8.B8_SALDO > 0 " + CRLF
					cQuery += " ORDER BY SB8.R_E_C_N_O_ DESC "	

					cQuery := ChangeQuery(cQuery)

					dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), '_c1Alias', .F., .T.)
					DbSelectArea("_c1Alias")
					_c1Alias->(dbGotop())
					
					If  _c1Alias->( !Eof() ) 
						cDtValid := _c1Alias->B8_DTVALID
					//Else
						//cDtValid := DTOS(dDataBase)									
					//EndIf
					//If Select(_c1Alias) > 0;( _c1Alias )->( dbCloseArea() );EndIf	
						cDtValid := SubStr(cDtValid,1,4)+"-"+SubStr(cDtValid,5,2)+"-"+SubStr(cDtValid,7,2)		
					EndIf
						        
					cLin   := Alltrim(Left(cSb2Cod,50))+";"
					If cSb2Filial = "01"
						cLin	+= Alltrim(Left('47869078000100',14))+";"
					ElseIf cSb2Filial = '04'
						cLin   += Alltrim(Left('47869078000453',14))+";"
					EndIf	
					cLin	+= Alltrim(Left(cValtoChar(cSb2Qatu),7))+";"
					cLin	+= Alltrim(Left(StrTran(Str(cSb2Cm1),""),22))+";"+Alltrim(Left(StrTran(Str(cSb2Cm1*cSb2Qatu),""),22))+";"
					//cLin	+= Alltrim(Left("1",1))+";"
					cLin   += Alltrim(Left(nCaixa,1))+";"
					cLin	+= Alltrim(Left(cDtValid,10))
					cLin	+= CRLF				

					_cTexto+=cLin

				
					If !lJob	
						If fWrite(nHdl,cLin,Len(cLin)) != Len(cLin)
							If !MsgAlert(OemToAnsi("Ocorreu um erro na gravaï¿½ï¿½o do arquivo. Continua ? "),OemToAnsi("Atenï¿½ï¿½o ! "))
								DisarmTransaction()
								lExit := .T.
								Exit
							EndIf
						EndIf 
					EndIf

						//-------------------------------------------------------------------------
						// Geraï¿½ï¿½o de LOG DE GERAï¿½ï¿½O DE ARQUIVO
						//-------------------------------------------------------------------------  				
						ZAALOG(		"SB2"										,; // Tabela
									SB2->(Recno())								,; // Recno
						  			cHora										,; // Hora
									cArqTxt										,; // Arquivo
									SB2->B2_FILIAL+SB2->B2_COD+SB2->B2_LOCAL	 ) // Primeiro Indice
								
					If Select(_c1Alias) > 0;_c1Alias->( dbCloseArea() );EndIf			
						
					_Qry3->( dbSkip() )
				EndDo
					If lJob //Estoque
						cFile := "\CONVATEC\ENTRADA\ESTOQUES"+DToS(dDataBase)+".txt"
						MemoWrite(cFile, _cTexto)
						Conout("Arquivo Estoque gerado com sucesso!")
					EndIf
			EndIf
		Else
			lNaoAchou := .T.
		EndIf
		If Select (_Qry3) > 0; _Qry3->( dbCloseArea() );EndIf
	
	ElseIf nTipo == 4
		Conout("Inicio Pedidos...")
		//*****************************************************************************************************************
		// PEDIDOS
		//*****************************************************************************************************************
		cQuery := " SELECT SF2.*, SD2.*, A1_CGC, C5_MENNOTA, SC5.R_E_C_N_O_ AS RECSC5, C5_FILIAL, C5_NUM, D2_FILIAL AS FILIAL,SF2.D_E_L_E_T_ AS F2DEL, SB1.B1_UM, SD1.* " + CRLF
		If lJob
			cQuery += " , ZAA.* " + CRLF
		EndIf
		cQuery += " FROM " + RetSqlName("SD2") + " SD2 " + CRLF
		
		cQuery += " INNER JOIN " + RetSqlName("SF2") + " SF2 " + CRLF
		cQuery += " ON F2_DOC = D2_DOC AND F2_SERIE = D2_SERIE AND F2_CLIENTE = D2_CLIENTE AND F2_LOJA = D2_LOJA " + CRLF
		cQuery += " AND F2_FILIAL = D2_FILIAL " + CRLF
		
		cQuery += " INNER JOIN " + RetSqlName("SC5") + " SC5 " + CRLF
		cQuery += " ON C5_NUM = D2_PEDIDO AND C5_CLIENTE = D2_CLIENTE " + CRLF
		cQuery += " AND SC5.D_E_L_E_T_ = ' ' AND C5_FILIAL = D2_FILIAL " + CRLF
		
		cQuery += " INNER JOIN " + RetSqlName("SA1") + " SA1 " + CRLF
		cQuery += " ON A1_COD = D2_CLIENTE AND A1_LOJA = D2_LOJA " + CRLF
		cQuery += " AND SA1.D_E_L_E_T_ = ' '" + CRLF
		cQuery += " INNER JOIN " + CRLF
		cQuery += " 	" + RetSqlName("SB1") + " SB1 ON " + CRLF
		cQuery += " 	SB1.B1_FILIAL	= SD2.D2_FILIAL	AND " + CRLF
		cQuery += " 	SB1.B1_COD		= SD2.D2_COD	AND " + CRLF
		cQuery += " 	SB1.D_E_L_E_T_	= '' " + CRLF
		cQuery += " LEFT JOIN " + CRLF
		cQuery += " " + RetSqlName("SD1") + " SD1		 " + CRLF
		cQuery += " ON SD1.D1_FILIAL	=  D2_FILIAL	AND " + CRLF
		cQuery += " 	SD1.D1_NFORI	=  D2_DOC		AND " + CRLF
		cQuery += " 	SD1.D1_SERIORI	=  D2_SERIE	AND " + CRLF
		cQuery += " 	SD1.D1_FORNECE	=  D2_CLIENTE	AND " + CRLF
		cQuery += " 	SD1.D1_LOJA		=  D2_LOJA	AND " + CRLF
		cQuery += " 	SD1.D1_ITEMORI	=  D2_ITEM	AND " + CRLF
		cQuery += " 	SD1.D1_TIPO		= 'D' AND" + CRLF
		cQuery += " 	SD1.D_E_L_E_T_	= '' " + CRLF
		
		If lJob
			cQuery += " LEFT JOIN " + RetSqlName("ZAA") + " ZAA " + CRLF
			cQuery += " ON SD2.R_E_C_N_O_ = ZAA.ZAA_RECTAB AND ZAA.D_E_L_E_T_ = ' ' AND ZAA_FILIAL IN ('01','04') " + CRLF
		EndIf
		
		cQuery += " WHERE D2_FILIAL IN ('01','04') " + CRLF
		cQuery += "AND D2_FORNEC = '100269' AND D2_TIPO = 'N'AND D2_LOTECTL <> '' AND D2_CLIENTE NOT IN ('000804','990064') "
		
		If !lJob
			cQuery += " AND D2_PEDIDO BETWEEN '" + cDe + "' AND '" + cAte + "' " + CRLF
			cQuery += " AND D2_EMISSAO BETWEEN '" + DTOS(d2De) +"' AND '" + DTOS(d2Ate) + "' " + CRLF
		Else
			cQuery += " AND D2_EMISSAO BETWEEN '" + DTOS(dDatabase-30) + "' AND '" + DTOS(dDatabase-1) + "' " + CRLF
			cQuery += " AND ZAA.ZAA_TABELA IS NULL " + CRLF
			cQuery += " ORDER BY D2_FILIAL " + CRLF
		EndIf
		
		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), '_Qry1', .F., .T.)
		DbSelectArea("_Qry1")
		_Qry1->(dbGotop())

		If ( _Qry1->( !Eof() ) )
		
			cLin   := "ID_PRODUTO_DISTRIBUIDOR;CNPJ_CPF_CLIENTE;CNPJ_DISTRIBUIDOR;NUMERO_PEDIDO;QUANTIDADE_ITEM_NF_FATURA;IS_FRACIONADO;VALOR_UNITARIO_ITEM_NF_FATURA;"
			cLin   += "VALOR_TOTAL_BRUTO_NF_FATURA;VALOR_TOTAL_BRUTO_ITEM_NF_FATURA;VALOR_TOTAL_LIQUIDO_NF_FATURA;VALOR_TOTAL_LIQUIDO_ITEM_NF_FATURA;"
			cLin   += "NUM_NF_FATURA;SERIE_NF_FATURA;ITEM_NF_FATURA;CFOP_NF_FATURA;NATUREZA_OPERACAO_NF_FATURA;OBSERVACAO_NF_FATURA;DATA_NF_FATURA;"
			cLin   += "FLAG_ITEM_CANCELADO;DATA_CANCELAMENTO;QUANTIDADE_CANCELADO;VALOR_FRETE_NF;VALOR_IPI_ITEM;VALOR_PIS_ITEM;VALOR_COFINS_ITEM;"			
			cLin   += "VALOR_ICMS_ITEM;VALOR_ICMS_ST_ITEM;VALOR_SEGURO_ITEM;VALOR_DESPESAS_EXTRA_ITEM;FLAG_FATURAMENTO_TP_ENTREGA;VALOR_OPERACIONAL;DESCONTO_ITEM;"
			cLin   += "BOM (kit para atendimento de ï¿½rgï¿½o pï¿½blico)"
			cLin   += CRLF				
			
			_cTexto+=cLin

		
			If !lJob
				If fWrite(nHdl,cLin,Len(cLin)) != Len(cLin)
					If !MsgAlert(OemToAnsi("Ocorreu um erro na gravaï¿½ï¿½o do arquivo. Continua ? "),OemToAnsi("Atenï¿½ï¿½o ! "))
						DisarmTransaction()
						lExit := .T.
					EndIf
				EndIf		
			EndIf

			If !lExit
			
				While (_Qry1->( !Eof() ) )
				cSc5Filial := _Qry1->FILIAL
				cDtDev	= ''
				cQtDev	= 0
				cNunDev	= '0'
				nCaixa	= ''
				//cSd2Del = SD2.D_E_L_E_T_

				//		If cSd2Del = '*'
				//			cQtDev = D2_QUAN
				//			cDtDev = D2_EMISSAO
				//		EndIf
						cDtEmiss := SubStr(_Qry1->F2_EMISSAO,1,4)+"-"+SubStr(_Qry1->F2_EMISSAO,5,2)+"-"+SubStr(_Qry1->F2_EMISSAO,7,2)
						If _Qry1->F2DEL == '*'
							cNunDev = '1'
							cQtDev = _Qry1->D2_QUANT
							cDtDev = cDtEmiss

						Endif

						If _Qry1->D2_QTDEDEV > 0 
							cNunDev = '1'
							cQtDev = _Qry1->D1_QUANT
							cDtDev = SubStr(_Qry1->D1_EMISSAO,1,4)+"-"+SubStr(_Qry1->D1_EMISSAO,5,2)+"-"+SubStr(_Qry1->D1_EMISSAO,7,2)
						EndIf

						If 	_Qry1->B1_UM == 'CX'
							nCaixa := '0'
						Else
							nCaixa := '1'
						EndIf

					
					
					cLin   := Alltrim(Left(_Qry1->D2_COD,50))+";"+Alltrim(Left(_Qry1->A1_CGC,14))+";"
					If cSc5Filial = '01'
						cLin   += Alltrim(Left('47869078000100',14))+";"
					ElseIf cSc5Filial = '04'
						cLin   += Alltrim(Left('47869078000453',14))+";"
					EndIf
					cLin   += Alltrim(Left(_Qry1->D2_PEDIDO,50))+";"
					cLin   += Alltrim(Left(StrTran(Str(_Qry1->D2_QUANT)," "),7))+";"
					cLin   += Alltrim(Left(nCaixa,1))+";"				
					cLin   += Alltrim(Left(StrTran(Str(_Qry1->D2_PRCVEN),""),23))+";"
					cLin   += Alltrim(Left(StrTran(Str(_Qry1->F2_VALBRUT),""),23))+";"
					cLin   += Alltrim(Left(StrTran(Str(_Qry1->D2_VALBRUT),""),23))+";"
					cLin   += Alltrim(Left(StrTran(Str(_Qry1->F2_VALMERC),""),23))+";"
					cLin   += Alltrim(Left(StrTran(Str(_Qry1->D2_TOTAL),""),23))+";"				
					cLin   += Alltrim(Left(_Qry1->F2_DOC,50))+";"
					cLin   += Alltrim(Left(_Qry1->F2_SERIE,50))+";"
					cLin   += Alltrim(Left(Strzero(DecodSoma1(_Qry1->D2_ITEM),3),7))+";"
					cLin   += Alltrim(Left(_Qry1->D2_CF,50))+";"
					cLin   += Alltrim(Left("",50))+";"
					cLin   += Alltrim(Left(_Qry1->C5_MENNOTA,400))+";"
					cLin   += Alltrim(Left(cDtEmiss,10))+";"
					cLin   += Alltrim(Left(cNunDev,1))+";"
					cLin   += Alltrim(Left(cDtDev,10))+";"
					cLin   += Alltrim(Left(StrTran(Str(cQtDev)," "),7))+";"
					cLin   += Alltrim(Left("",22))+";"				
					cLin   += Alltrim(Left("",22))+";"
					cLin   += Alltrim(Left("",22))+";"				
					cLin   += Alltrim(Left("",22))+";"
					cLin   += Alltrim(Left("",22))+";"				
					cLin   += Alltrim(Left("",22))+";"
					cLin   += Alltrim(Left("",22))+";"
					cLin   += Alltrim(Left("",22))+";"
					cLin   += Alltrim(Left("",50))+";"				
					cLin   += Alltrim(Left("",22))+";"
					cLin   += Alltrim(Left("",22))+";"				
					cLin   += Alltrim(Left("",7))							
					cLin   += CRLF

					_cTexto+=cLin


					If !lJob					
						If fWrite(nHdl,cLin,Len(cLin)) != Len(cLin)
							If !MsgAlert(OemToAnsi("Ocorreu um erro na gravaï¿½ï¿½o do arquivo. Continua ? "),OemToAnsi("Atenï¿½ï¿½o ! "))
								DisarmTransaction()
								lExit := .T.
								Exit
							EndIf
						EndIf 
					EndIf
					//-------------------------------------------------------------------------
					// Geraï¿½ï¿½o de LOG DE GERAï¿½ï¿½O DE ARQUIVO
					//-------------------------------------------------------------------------  				
					ZAALOG(		"SC5"										,; // Tabela
								_Qry1->RECSC5							,; // Recno
					  			cHora										,; // Hora
								cArqTxt										,; // Arquivo
								_Qry1->C5_FILIAL+_Qry1->C5_NUM   ) // Primeiro Indice
						
					_Qry1->( dbSkip() )
				EndDo
					If lJob // Pedido
						cFile := "\CONVATEC\ENTRADA\PEDIDOS"+DToS(dDataBase)+".txt"
						MemoWrite( cFile, _cTexto)
						Conout("Arquivo Produto gerado com sucesso!")
					EndIf
			EndIf	
		Else
			lNaoAchou := .T.
		EndIf
		If Select(_Qry1) > 0;_Qry1->( dbCloseArea() );EndIf	
		
	EndIf
	
	if lJob
		If lNaoAchou
			Conout(OemToAnsi("Nenhum dado encontrado com os parï¿½metros informados ou os dados jï¿½ foram extraï¿½dos e constam na tabela ZAA. Favor verificar."))
		ElseIf lExit
			Conout(OemToAnsi("Processo abortado."))
		Else		
			Conout(OemToAnsi("Geracao Finalizada"),"Arquivo "+cArqTxt+" gerado com sucessso!",{"&Ok"})			
		EndIf
	EndIf
	If !lJob	
		If lNaoAchou
			Alert(OemToAnsi("Nenhum dado encontrado com os parï¿½metros informados ou os dados jï¿½ foram extraï¿½dos e constam na tabela ZAA. Favor verificar."))
		ElseIf lExit
			Alert(OemToAnsi("Processo abortado."))
		Else		
			Aviso(OemToAnsi("Geracao Finalizada"),"Arquivo "+cArqTxt+" gerado com sucessso!",{"&Ok"})			
		EndIf
	EndIf
	
End Transaction	
//FECHA O ARQUIVO TXT
fClose(nHdl)

Return
/*
ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½
ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½
ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½Í»ï¿½ï¿½
ï¿½ï¿½ï¿½Programa  ï¿½ ZAALOG ï¿½Autor  ï¿½ Delta Decisï¿½o		 ï¿½ Data ï¿½  05/09/19   ï¿½ï¿½ï¿½
ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½Í¹ï¿½ï¿½
ï¿½ï¿½ï¿½Desc.     ï¿½ Rotina para gerar log de arquivo					          ï¿½ï¿½ï¿½
ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½Í¹ï¿½ï¿½
ï¿½ï¿½ï¿½Uso       ï¿½ DIPROMED                                                   ï¿½ï¿½ï¿½
ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½Í¼ï¿½ï¿½
ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½
ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½
*/
Static Function ZAALOG(cTabela, nRecTab, cHora, cArquivo, cPIndice)

dbselectarea("ZAA")

If RECLOCK("ZAA", .T. )
         
	ZAA->ZAA_FILIAL	:= xFilial("ZAA")
	ZAA->ZAA_TABELA	:= cTabela
	ZAA->ZAA_RECTAB := nRecTab
	ZAA->ZAA_DATA	:= dDataBase
	ZAA->ZAA_HORA	:= cHora
	ZAA->ZAA_ARQUIV	:= cArquivo
	ZAA->ZAA_PINDIC	:= cPIndice
	
	ZAA->(MSUNLOCK()) 	
EndIf

return NIL


/*
ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½
ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½
ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½Í»ï¿½ï¿½
ï¿½ï¿½ï¿½Programa  ï¿½ DIPJOBCONVï¿½Autor  ï¿½  Delta Decisï¿½o ï¿½ Data ï¿½   05/09/19     ï¿½ï¿½ï¿½
ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½Í¹ï¿½ï¿½
ï¿½ï¿½ï¿½Desc.     ï¿½ Funï¿½ï¿½o para chamada do JOB				          		  ï¿½ï¿½ï¿½
ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½Í¹ï¿½ï¿½
ï¿½ï¿½ï¿½Uso       ï¿½ DIPROMED                                                   ï¿½ï¿½ï¿½
ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½Í¼ï¿½ï¿½
ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½
ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½
*/
/*
User Function DIPJOBCONV()
   


Conout(Replicate("*",120))
Conout("*** Função....: DIPCONV *** ")
Conout("*** Descrição.: Geração de arquivos Convatec FTP  *** ")
	
     RpcSetEnv("01","01",,,'FAT',, )

    U_DIPCONV( .T.,'1',"Clientes")
	U_DIPCONV( .T.,'2',"Produtos")
	U_DIPCONV( .T.,'3',"Estoques")
	U_DIPCONV( .T.,'4',"Pedidos")
Else
	Conout("*** Parâmetro(s) do job (empresa e/ou filial) inválido(s) *** ")
Endif

Conout("*** Data......: " + Dtoc(Date()))
Conout("*** Hora......: " + Time())
Conout(Replicate("*",120))
	
Return
*/


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  TiraZeros ºAutor  Blandino           º Data ³  30/11/20      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function TiraZeros(cTexto)
    Local aArea     := GetArea()
    Local cRetorno  := ""
    Local lContinua := .T.
    Default cTexto  := ""
 
    //Pegando o texto atual
    cRetorno := Alltrim(cTexto)
 
    //Enquanto existir zeros a esquerda
    While lContinua
        //Se a priemira posição for diferente de 0 ou não existir mais texto de retorno, encerra o laço
        If SubStr(cRetorno, 1, 1) <> "0" .Or. Len(cRetorno) ==0
            lContinua := .f.
        EndIf
         
        //Se for continuar o processo, pega da próxima posição até o fim
        If lContinua
            cRetorno := Substr(cRetorno, 2, Len(cRetorno))
        EndIf
    EndDo
     
    RestArea(aArea)
Return cRetorno


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DIPNCLI3M ºAutor  ³Microsiga           º Data ³  08/18/16   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

/*User Function DipGerConv(aCabec,aDetal,cNomArq)
Local _nH 	   	:= 0
Local nI       	:= 0
Local cLinha 	:= ""
//Local cDirDest := "\\172.27.72.246\Out\"
Local cLocDir  := SupergetMV("MV_XPCONV",,"D:\P12\PROTHEUS_DATA\CONVATEC\ENTRADA")

_nH := ConvCriaArq(cArqTxt,cLocDir,cDesc)        

If _nH > 0                       
	If Len(aCabec)>0
		For nI:=1 to Len(aCabec[1])
			If nI>1
				cLinha += "|"
			EndIf
			cLinha += AllTrim(aCabec[1,nI])
		Next nI                       
		cLinha += CHR(13)+CHR(10)
		FWrite(_nH,cLinha)
			
		For nI:=1 to Len(aDetal) 
			cLinha := ""
			For nJ:=1 to Len(aDetal[nI])
				If nJ>1
					cLinha += "|"
				EndIf
				cLinha += AllTrim(aDetal[nI,nJ])
			Next nJ                         
			cLinha += CHR(13)+CHR(10)
			FWrite(_nH,cLinha)
		Next nI
		
		FClose(_nH)						
		
		//Aviso("Atenção","Arquivo gerado com sucesso."+CHR(10)+CHR(13)+"C:\ARQUIVOS_3M\"+cNomArq,{"Ok"},2)
	EndIf      
EndIf

Return 
*/

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DIPNCLI3M ºAutor  ³Microsiga           º Data ³  08/18/16   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function ConvCriaArq(cArqTxt,cLocDir,cDesc)
Local _nH 		:= 0 
DEFAULT cNomArq := ""
DEFAULT cLocDir := ""
                   
cArqTxt := cDesc+cArqTxt

Conout(cArqTxt)

If !ExistDir(cLocDir)         
	If Makedir(cLocDir) <> 0
		Return
	Endif                  
Endif

If File(cArqTxt)
	FErase(cArqTxt)
EndIf

If !File(cArqTxt)
	_nH := FCreate(cArqTxt)
Endif 	  

Return _nH

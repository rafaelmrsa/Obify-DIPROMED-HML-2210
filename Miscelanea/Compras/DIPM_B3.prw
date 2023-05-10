/*====================================================================================\
|Programa  | DIPM_B3       | Autor | Eriberto Elias             | Data | 14/08/2002   |
|=====================================================================================|
|Descrição | Atualização das medias no B3 - so considera TES que atualiza estoque     |
|=====================================================================================|
|Sintaxe   | DIPM_B3                                                                  |
|=====================================================================================|
|Uso       | Especifico DIPROMED                                                      |
|=====================================================================================|
|........................................Histórico....................................|
|Eriberto  | 06/08/2004 - atualiza requizicoes de material de consumo                 |
|Rafael    | 10/08/2004 - Alteração das consultas a BD usando QUERYs                  |
|Maximo    | 10/09/2010 - Corrigindo Erro no tratamento das Filiais por empresa       | 
|Maximo    | 01/12/2010 - Alterado para funcionar via workflow                        |
\====================================================================================*/

#INCLUDE "RWMAKE.CH"  
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"

User Function DIPM_B3(aWork)                                                                

Private cWorkFlow := ""
Private cWCodEmp  := ""  // MCVN - 04/10/2010
Private cWCodFil  := ""  // MCVN - 04/10/2010 

If ValType(aWork) <> 'A'                    
    U_DIPPROC(ProcName(0),U_DipUsr()) 
	cWorkFlow := "N"   
	cWCodEmp  := cEmpAnt// MCVN - 04/10/2010
    cWCodFil  := cFilAnt// MCVN - 04/10/2010
Else    
	cWorkFlow := aWork[1]    // MCVN - 04/10/2010
	cWCodEmp  := aWork[3]	 // MCVN - 04/10/2010
    cWCodFil  := aWork[4]    // MCVN - 04/10/2010
Endif                        

If cWorkFlow == "S"  // MCVN - 04/10/2010  

	PREPARE ENVIRONMENT EMPRESA cWCodEmp FILIAL cWCodFil FUNNAME "DIPM_B3" 
	
	ConOut("--------------------------")
	ConOut('DIPM_B3 agendado - Inicio Processamento-' +Time())
	ConOut("--------------------------")     
EndIf

If cWorkFlow = "N" 
	Processa({|| ProssNome() })
Else             
	ProssNome()
Endif
Return

/*====================================================================================\
|FUNÇÃO PROSSNOME()                                                                   |
|====================================================================================*/
Static Function ProssNome()

Local _dInicial := FirstDay(dDataBase-3)  
Local _bOk      := {|| IIf(cWCodEmp=="01",CalcCons(_dInicial),CalcConsHQ(_dInicial))}

If cWorkFlow = "N" 
	@ 126,000 To 295,180 DIALOG oDlg TITLE OemToAnsi("Consumo mensais")
	@ 020,010 Say "Digite o 1o. dia do mes: "
	@ 040,010 Get _dInicial Size 53,20 Valid !Empty(_dInicial)
	@ 065,015 BMPBUTTON TYPE 1 ACTION (processa({|| Eval(_bOk) },'Atualização das medias'),Close(oDlg))
	@ 065,050 BmpButton Type 2 Action Close(oDlg)
	ACTIVATE DIALOG oDlg Centered
Else 
	Eval(_bOk)
EndIf

Return

/*====================================================================================\
|FUNÇÃO CALCCONS(_DINICIAL)                                                           |
|====================================================================================*/
Static Function CalcCons(_dInicial)

Local aFilial 		:= {}
Local cLocal  		:= "01"    
Local cFilSB3 		:= xFilial("SB3")

Local cQueryB3  	:= ""	//Rafael Moraes Rosa Obify - 28/07/2022
Local cQueryD2  	:= ""	//Rafael Moraes Rosa Obify - 28/07/2022
Local cQueryD3  	:= ""	//Rafael Moraes Rosa Obify - 28/07/2022
Local cQueryD3UPD   := ""	//Rafael Moraes Rosa Obify - 24/11/2022
Local nTotal		:= 0

If cWorkFlow = "N" 
	Aadd(aFilial,cFilAnt) 
Else                                                            
	Aadd(aFilial,cWCodFil) 
Endif

//Rafael Moraes Rosa Obify - 28/07/2022 - Linhas adicionadas
cQueryB3	:= "SELECT B3_COD FROM "+RetSqlName("SB3")+ " SB3  "
cQueryB3	+= "INNER JOIN SB1010 SB1 ON SB3.B3_FILIAL = SB1.B1_FILIAL AND SB3.B3_COD = SB1.B1_COD "
cQueryB3	+= "WHERE SB3.B3_FILIAL = '"+ cFilSB3 +"' "
cQueryB3	+= "AND SB3.D_E_L_E_T_ = '' AND SB1.D_E_L_E_T_ = '' "
If cWorkFlow = 'N'
	If MsgYesNo("Calcular os produtos que estão em Z ?","Atenção") //"Calcular ou não os produtos que estão em Z
		cQueryB3	+= "AND (SUBSTRING(SB1.B1_COD,1,1)<>'E' AND SUBSTRING(SB1.B1_COD,1,1)<>'L' AND SUBSTRING(SB1.B1_COD,1,1)<>'M') "
		cQueryB3	+= "AND SUBSTRING(SB1.B1_COD,1,2)<>'MC' "
	Else
		cQueryB3	+= "AND (SUBSTRING(SB1.B1_COD,1,1)<>'E' AND SUBSTRING(SB1.B1_COD,1,1)<>'L' AND SUBSTRING(SB1.B1_COD,1,1)<>'M') "
		cQueryB3	+= "AND (SUBSTRING(SB1.B1_DESC,1,1)<>'Z' AND SUBSTRING(SB1.B1_COD,1,2)<>'MC') "
	Endif 
Else
	cQueryB3	+= "AND (SUBSTRING(SB1.B1_COD,1,1)<>'E' AND SUBSTRING(SB1.B1_COD,1,1)<>'L' AND SUBSTRING(SB1.B1_COD,1,1)<>'M') "
	cQueryB3	+= "AND (SUBSTRING(SB1.B1_DESC,1,1)<>'Z' AND SUBSTRING(SB1.B1_COD,1,2)<>'MC') "
Endif
	
cQueryB3	+= "ORDER BY B3_FILIAL,B3_COD "
//cQueryB3	+= "WHERE SB3.D_E_L_E_T_ = '' AND B3_FILIAL = '"+ cFilSB3 +"' ORDER BY B3_FILIAL,B3_COD"

TcQuery cQueryB3 New Alias "QRYB3"
dbSelectArea("QRYB3")
Count To nTotal
QRYB3->(dbGoTop())
ProcRegua(nTotal)

WHILE  !QRYB3->(EOF())

	//Rafael Moraes Rosa Obify - 28/07/2022 - Linhas comentadas
	/*
	If cFilSB3 == SB3->B3_FILIAL
		_cProd   := SB3->B3_COD
		_nQuant  := 0
	*/

	//If	cFilSB3 == QRYB3->B3_FILIAL //Rafael Moraes Rosa Obify - 28/07/2022 - Linha comentada
		_cProd		:= QRYB3->B3_COD //Rafael Moraes Rosa Obify - 28/07/2022
		_nQuant		:= 0

	    // Busca o local padrão no cadastro de Produto - MCVN 02/12/10
    	cLocPad:= Posicione("SB1",1,xFilial("SB1")+_cProd,"B1_LOCPAD")
	    cLocal := If(cLocPad <> "",cLocPad,cLocal)

		//IncProc("Processando: "+SB3->B3_COD)
		IncProc("Processando: "+ _cProd)
	                

		//Rafael Moraes Rosa Obify - 28/07/2022 - Linhas adicionadas - INICIO
		//Rafael Moraes Rosa Obify - 02/12/2022 - Linhas comentadas - INICIO
		/*cQueryD2	:= "SELECT D2_EMISSAO, D2_TIPO, D2_CLIENTE, D2_TES, D2_DOC, D2_SERIE, D2_QUANT FROM "+RetSqlName("SD2")+ " SD2  "
		cQueryD2	+= "INNER JOIN "+RetSqlName("SF4")+ " SF4  ON SD2.D2_FILIAL = SF4.F4_FILIAL AND SD2.D2_TES = SF4.F4_CODIGO "
		cQueryD2	+= "WHERE SD2.D_E_L_E_T_ = '' AND SD2.D2_FILIAL = '"+ cFilSB3 +"' AND SD2.D2_COD = '" + _cProd + "' AND SD2.D2_LOCAL = '" + cLocal + "' AND D2_TIPO = 'N' "
		cQueryD2	+= "AND SUBSTRING(SD2.D2_EMISSAO,1,4) = '" + SUBSTR(DTOS(_dInicial),1,4) + "' AND SUBSTRING(SD2.D2_EMISSAO,5,2) = '" + SUBSTR(DTOS(_dInicial),5,2) + "' "
		cQueryD2	+= "AND (SD2.D2_DOC NOT IN (151517,151518,151519,151520,151521) AND SD2.D2_SERIE <> '2') AND SF4.F4_ESTOQUE = 'S' "
		cQueryD2	+= "AND (SD2.D2_DOC IN (000216407,000216407,000217545) AND SD2.D2_FILIAL = '04') AND SD2.D2_CLIENTE like '%" + GetNewPar("ES_DIPM_B3","") + "%' "
		cQueryD2	+= "ORDER BY D2_FILIAL,D2_COD,D2_LOCAL,D2_EMISSAO,D2_NUMSEQ"*/
		//Rafael Moraes Rosa Obify - 28/07/2022 - Linhas adicionadas - INICIO
		//Rafael Moraes Rosa Obify - 02/12/2022 - Linhas comentadas - FIM

		//Rafael Moraes Rosa Obify - 02/12/2022 - Linhas reajustadas - INICIO
		cQueryD2	:= "SELECT D2_EMISSAO, D2_TIPO, D2_CLIENTE, D2_TES, D2_DOC, D2_SERIE, D2_QUANT FROM "+RetSqlName("SD2")+ " SD2  "
		cQueryD2	+= "INNER JOIN "+RetSqlName("SF4")+ " SF4  ON SD2.D2_FILIAL = SF4.F4_FILIAL AND SD2.D2_TES = SF4.F4_CODIGO "

		cQueryD2	+= "WHERE SD2.D_E_L_E_T_ = '' "
		cQueryD2	+= "AND SD2.D2_FILIAL = '"+ cFilSB3 +"' "
		cQueryD2	+= "AND SD2.D2_COD = '" + _cProd + "' "
		cQueryD2	+= "AND SD2.D2_LOCAL = '" + cLocal + "' "
		cQueryD2	+= "AND D2_TIPO = 'N' "
		cQueryD2	+= "AND SUBSTRING(SD2.D2_EMISSAO,1,4) = '" + SUBSTR(DTOS(_dInicial),1,4) + "' "
		cQueryD2	+= "AND SUBSTRING(SD2.D2_EMISSAO,5,2) = '" + SUBSTR(DTOS(_dInicial),5,2) + "' "
		cQueryD2	+= "AND (SD2.D2_DOC NOT IN (151517,151518,151519,151520,151521) AND SD2.D2_SERIE <> '2') "
		cQueryD2	+= "AND SF4.F4_ESTOQUE = 'S' "
		cQueryD2	+= "AND SD2.D2_CLIENTE NOT IN (" + GetNewPar("ES_DIPM_B3","") + ") "
		//cQueryD2	+= "AND SD2.D2_CLIENTE like '%" + GetNewPar("ES_DIPM_B3","") + "%' "
		//cQueryD2	+= "AND (SD2.D2_DOC IN (000216407,000216407,000217545) AND SD2.D2_FILIAL = '04') "

		cQueryD2	+= "ORDER BY D2_FILIAL,D2_COD,D2_LOCAL,D2_EMISSAO,D2_NUMSEQ"
		//Rafael Moraes Rosa Obify - 02/12/2022 - Linhas reajustadas - FIM

		TcQuery cQueryD2 New Alias "QRYD2"
		dbSelectArea("QRYD2")
		QRYD2->(dbGoTop())

		//Rafael Moraes Rosa Obify - 28/07/2022 - Linhas comentadas (Adicionadas a instrucao SQL)
		//While QRYD2->(!Eof()) .AND. QRYD2->D2_EMISSAO < DTOS(_dInicial)
		//	QRYD2->(DbSkip())
		//End                       

		//Rafael Moraes Rosa Obify - 28/07/2022 - Condicoes parcialmente comentadas (Adicionadas a instrucao SQL)	
		While QRYD2->(!Eof()) //.AND. Month(_dInicial) == Month(CTOD(QRYD2->D2_EMISSAO)) .AND. Year(_dInicial) == Year(QRYD2->D2_EMISSAO)

			//Rafael Moraes Rosa Obify - 28/07/2022 - Condicoes comentadas (Adicionadas a instrucao SQL)
			//If QRYD2->D2_TIPO == 'N' .And. !(QRYD2->D2_CLIENTE$GetNewPar("ES_DIPM_B3",""))
			//If !(QRYD2->D2_CLIENTE$GetNewPar("ES_DIPM_B3",""))
				//_cTes := QRYD2->D2_TES
				//DbSelectArea("SF4")
				//DbSetOrder(1)
				//IF DbSeek(xFilial("SF4")+_cTes)
					//IF SF4->F4_ESTOQUE == "S"     
						//NÃO CONSIDERA AS NOTAS DE TRANSFERÊNCIA DA DIPROMED PARA HQ-CD  MCVN 07/05/2010 
						//If !(ALLTRIM(QRYD2->D2_DOC) $ '151517/151518/151519/151520/151521' .And. ALLTRIM(QRYD2->D2_SERIE) = '2')
							_nQuant := _nQuant + QRYD2->D2_QUANT
						//Endif
					//EndIf
				//EndIf
			//EndIf
						
			QRYD2->(DbSkip())

		EndDo
		QRYD2->(dbCloseArea())

		//Rafael Moraes Rosa Obify - 28/07/2022 - Linhas comentadas (Adicionadas a instrucao SQL)
		//Instrucao SQL anteriormente desenvolvida, porem desabilitada por ter sido incorporada a instrucao SQL do bloco de validacoes anteriores
		/*
		cQueryD2	:= "SELECT D2_EMISSAO, D2_DOC, D2_FILIAL, D2_QUANT FROM "+RetSqlName("SD2")+ " SD2  "
		cQueryD2	+= "WHERE SD2.D_E_L_E_T_ = '' AND SD2.D2_FILIAL = '"+ cFilSB3 +"' AND SD2.D2_COD = '" + _cProd + "' AND SD2.D2_LOCAL = '06' AND D2_EMISSAO = '"+ DTOS(_dInicial) +"' "
		cQueryD2	+= "ORDER BY D2_FILIAL,D2_COD,D2_LOCAL,D2_EMISSAO,D2_NUMSEQ"

		TcQuery cQueryD2 New Alias "QRYD2"
		dbSelectArea("QRYD2")
		//Count To nTotal
		QRYD2->(dbGoTop())

		While QRYD2->(!Eof()) .AND. QRYD2->D2_EMISSAO < _dInicial
			QRYD2->(DbSkip())
		End                       
					
		While QRYD2->(!Eof()) .AND. QRYD2->D2_EMISSAO < _dInicial .AND. !(QRYD2->D2_DOC $ ('000216407'))
			QRYD2->(DbSkip())
		End
		                    
		While QRYD2->(!Eof()) .AND. Month(_dInicial) == Month(QRYD2->D2_EMISSAO) .AND. Year(_dInicial) == Year(QRYD2->D2_EMISSAO)

			If QRYD2->D2_DOC $ ('000216407/000216407/000217545') .AND. QRYD2->D2_FILIAL = '04'
				 _nQuant := _nQuant + QRYD2->D2_QUANT
			EndIf

		QRYD2->(DbSkip())
		EndDo
		QRYD2->(dbCloseArea())
		*/
		

		//Rafael Moraes Rosa Obify - 28/07/2022 - Linhas adicionadas - INICIO
		//Rafael Moraes Rosa Obify - 02/12/2022 - Linhas comentadas - INICIO
		/*cQueryD3	:= "SELECT D3_EMISSAO, D3_TM, D3_IDENT, D3_TIPO, D3_CF, D3_ESTORNO, D3_QUANT FROM "+RetSqlName("SD3")+ " SD3  "
		cQueryD3	+= "WHERE SD3.D_E_L_E_T_ = '' AND D3_FILIAL = '"+ cFilSB3 +"' AND D3_COD = '" + _cProd + "' AND D3_LOCAL = '" + cLocal + "' "
		cQueryD3	+= "AND SUBSTRING(SD3.D3_EMISSAO,1,4) = '" + SUBSTR(DTOS(_dInicial),1,4) + "' AND SUBSTRING(SD3.D3_EMISSAO,5,2) = '" + SUBSTR(DTOS(_dInicial),5,2) + "'"
		cQueryD3	+= "AND ((SD3.D3_TM = '532' AND (SD3.D3_IDENT = 'UNI   ' OR SD3.D3_IDENT = '1     ' OR SD3.D3_IDENT = '2     ' OR SD3.D3_IDENT = '003   '  OR SD3.D3_IDENT = '004   ')) "
		cQueryD3	+= "OR (SD3.D3_TM = '501' AND SD3.D3_CF = 'RE0' AND SD3.D3_ESTORNO <> 'S')) AND SD3.D3_TIPO LIKE '%" + Iif(cEmpAnt='01','MC','MC/MP') + "%'
		cQueryD3	+= "ORDER BY D3_FILIAL,D3_COD,D3_LOCAL,D3_EMISSAO,D3_NUMSEQ"*/
		//Rafael Moraes Rosa Obify - 28/07/2022 - Linhas adicionadas - FIM
		//Rafael Moraes Rosa Obify - 02/12/2022 - Linhas comentadas - FIM

		//Rafael Moraes Rosa Obify - 02/12/2022 - Linhas reajustadas - INICIO
		cQueryD3		:= "SELECT D3_EMISSAO, D3_TM, D3_IDENT, D3_TIPO, D3_CF, D3_ESTORNO, D3_QUANT FROM "+RetSqlName("SD3")+ " SD3  "

		cQueryD3		+= "WHERE SD3.D_E_L_E_T_ = '' "
		cQueryD3		+= "AND D3_FILIAL = '"+ cFilSB3 +"' "
		cQueryD3		+= "AND D3_COD = '" + _cProd + "' "
		cQueryD3		+= "AND D3_LOCAL = '" + cLocal + "' "
		cQueryD3		+= "AND SUBSTRING(SD3.D3_EMISSAO,1,4) = '" + SUBSTR(DTOS(_dInicial),1,4) + "' "
		cQueryD3		+= "AND SUBSTRING(SD3.D3_EMISSAO,5,2) = '" + SUBSTR(DTOS(_dInicial),5,2) + "' "
		cQueryD3		+= "AND ((SD3.D3_TM = '532' "
			cQueryD3	+= "AND (SD3.D3_IDENT = 'UNI   ' OR SD3.D3_IDENT = '1     ' OR SD3.D3_IDENT = '2     ' OR SD3.D3_IDENT = '003   '  OR SD3.D3_IDENT = '004   ')) "
			cQueryD3	+= "OR (SD3.D3_TM = '501' AND SD3.D3_CF = 'RE0' AND SD3.D3_ESTORNO <> 'S')) "
		cQueryD3		+= "AND SD3.D3_TIPO LIKE '%" + Iif(cEmpAnt='01','MC','MC/MP') + "%' "
		
		cQueryD3		+= "ORDER BY D3_FILIAL,D3_COD,D3_LOCAL,D3_EMISSAO,D3_NUMSEQ"
		//Rafael Moraes Rosa Obify - 02/12/2022 - Linhas reajustadas - FIM

		TcQuery cQueryD3 New Alias "QRYD3"
		dbSelectArea("QRYD3")
		QRYD3->(dbGoTop())

		//Rafael Moraes Rosa Obify - 28/07/2022 - Linhas comentadas (Adicionadas a instrucao SQL)
		//While QRYD3->(!Eof()) .AND. QRYD3->D3_EMISSAO < DTOS(_dInicial)
		//	QRYD3->(DbSkip())
		//End

		//Rafael Moraes Rosa Obify - 28/07/2022 - Condicoes parcialmente comentadas (Adicionadas a instrucao SQL)
		While QRYD3->(!Eof()) //.AND. Month(_dInicial) == Month(CTOD(QRYD3->D3_EMISSAO)) .AND. Year(_dInicial) == Year(QRYD3->D3_EMISSAO)

			//Rafael Moraes Rosa Obify - 28/07/2022 - Condicoes comentadas (Adicionadas a instrucao SQL)
			//IF (SD3->D3_TM $ "532/" .AND. (SD3->D3_IDENT = 'UNI   ' .OR. SD3->D3_IDENT = '1     ' .OR. SD3->D3_IDENT = '2     ' .OR. SD3->D3_IDENT = '003   '  .OR. SD3->D3_IDENT = '004   ' )) .OR.;
			//	 (SD3->D3_TM == '501' .AND. SD3->D3_TIPO $ Iif(cEmpAnt='01','MC','MC/MP') .AND. SD3->D3_CF == 'RE0' .AND. SD3->D3_ESTORNO != 'S')
					_nQuant := _nQuant + QRYD3->D3_QUANT
			//EndIf

			QRYD3->(DbSkip())
		End
		QRYD3->(dbCloseArea())
	  
		_cCampo := 'SB3->B3_Q'+Subs(dTOc(_dInicial),4,2)
		
		//Rafael Moraes Rosa - 24/11/2022 - instrucao adicionada - INICIO
		Begin Transaction
			cQueryD3UPD := "UPDATE "+RetSqlName("SB3")+ " SET B3_Q" + Subs(dTOc(_dInicial),4,2)+" = " + cValToChar(_nQuant) + " "
			cQueryD3UPD += "WHERE D_E_L_E_T_ = '' AND B3_FILIAL = '"+ cFilSB3 +"' AND B3_COD = '" + _cProd + "' "
			
			nErro := TcSqlExec(cQueryD3UPD)
							
			If nErro != 0
				//Mensagem comentada pois a aplicacao sera executada via Schedule
				//MsgStop("Erro na execução da query: "+TcSqlError(), "Atenção")
				DisarmTransaction()
			EndIf
		End Transaction
		//Rafael Moraes Rosa - 24/11/2022 - instrucao adicionada - FIM
		
		/*
		DbSelectArea("SB3")
		SB3->(RecLock("SB3",.F.))
			&(_cCampo) := _nQuant
		SB3->(MsUnLock())
		SB3->(DbSkip())
		*/

	//Endif	//Rafael Moraes Rosa Obify - 28/07/2022 - Linha comentada
	QRYB3->(DbSkip())
End
QRYB3->(dbCloseArea())

//BACKUP INSTRUCOES ANTERIORES
/*
DbSelectArea("SB3")
DbSeek(xFilial("SB3"),.T.)
ProcRegua(RecCount())

While SB3->(!Eof()) 

	If cFilSB3 == SB3->B3_FILIAL
		_cProd   := SB3->B3_COD
		_nQuant  := 0
	

		// Busca o local padrão no cadastro de Produto - MCVN 02/12/10
		cLocPad:= Posicione("SB1",1,xFilial("SB1")+_cProd,"B1_LOCPAD")
		cLocal := If(cLocPad <> "",cLocPad,cLocal)

		//IncProc("Processando: "+SB3->B3_COD)
		IncProc("Processando: "+ _cProd)

		/*
		DbSelectArea("SD2")
		DbSetOrder(6)
		// Avaliando tabela de movimentação SD2
		DbSeek(xFilial("SD2")+_cProd+cLocal+DtoS(_dInicial),.T.)

		While SD2->(!Eof()) .AND. SD2->D2_FILIAL == xFilial("SD2") .AND. SD2->D2_COD == _cProd .AND. SD2->D2_EMISSAO < _dInicial
			SD2->(DbSkip())
		End                       
			
		While SD2->(!Eof()) .AND. SD2->D2_FILIAL == xFilial("SD2") .AND. SD2->D2_COD == _cProd .AND. Month(_dInicial) == Month(SD2->D2_EMISSAO) .AND. Year(_dInicial) == Year(SD2->D2_EMISSAO)

		    If SD2->D2_TIPO == 'N' .And. !(SD2->D2_CLIENTE$GetNewPar("ES_DIPM_B3",""))
			    _cTes := SD2->D2_TES
				DbSelectArea("SF4")
				DbSetOrder(1)
				IF DbSeek(xFilial("SF4")+_cTes)
					IF SF4->F4_ESTOQUE == "S"     
					    //NÃO CONSIDERA AS NOTAS DE TRANSFERÊNCIA DA DIPROMED PARA HQ-CD  MCVN 07/05/2010 
						If !(ALLTRIM(SD2->D2_DOC) $ '151517/151518/151519/151520/151521' .And. ALLTRIM(SD2->D2_SERIE) = '2')
							_nQuant := _nQuant + SD2->D2_QUANT
						Endif
					EndIf
				EndIf
			EndIf
				
			DbSelectArea("SD2")
			SD2->(DbSkip())
		EndDo
		*/


		/*
		DbSelectArea("SD2")
		DbSetOrder(6)
		// Avaliando tabela de movimentação SD2 Armazem 06  - 24/03/2022
		DbSeek(xFilial("SD2")+_cProd+'06'+DtoS(_dInicial),.T.)

		While SD2->(!Eof()) .AND. SD2->D2_FILIAL == xFilial("SD2") .AND. SD2->D2_COD == _cProd .AND. SD2->D2_EMISSAO < _dInicial .AND. !(SD2->D2_DOC $ ('000216407'))
			SD2->(DbSkip())
		End                       
		
		While SD2->(!Eof()) .AND. SD2->D2_FILIAL == xFilial("SD2") .AND. SD2->D2_COD == _cProd .AND. Month(_dInicial) == Month(SD2->D2_EMISSAO) .AND. Year(_dInicial) == Year(SD2->D2_EMISSAO)
			    If SD2->D2_DOC $ ('000216407/000216407/000217545') .AND. SD2->D2_FILIAL = '04'
			    _nQuant := _nQuant + SD2->D2_QUANT
			EndIf
			
			DbSelectArea("SD2")
			SD2->(DbSkip())
		EndDo
		*/
			
		 /*   
	    // Avaliando tabela de movimentação SD3
		DbSelectArea("SD3")                                         
		DbSetOrder(7)
		DbSeek(xFilial("SD3")+_cProd+cLocal+DtoS(_dInicial),.T.)
			While SD3->(!Eof()) .AND. SD3->D3_FILIAL == xFilial("SD3") .AND. SD3->D3_COD == _cProd .AND. SD3->D3_EMISSAO < _dInicial
				SD3->(DbSkip())
			End
			While SD3->(!Eof()) .AND. SD3->D3_FILIAL == xFilial("SD3") .AND. SD3->D3_COD == _cProd .AND. Month(_dInicial) == Month(SD3->D3_EMISSAO) .AND. Year(_dInicial) == Year(SD3->D3_EMISSAO)
				IF (SD3->D3_TM $ "532/" .AND. (SD3->D3_IDENT = 'UNI   ' .OR. SD3->D3_IDENT = '1     ' .OR. SD3->D3_IDENT = '2     ' .OR. SD3->D3_IDENT = '003   '  .OR. SD3->D3_IDENT = '004   ' )) .OR.;
					(SD3->D3_TM == '501' .AND. SD3->D3_TIPO $ Iif(cEmpAnt='01','MC','MC/MP') .AND. SD3->D3_CF == 'RE0' .AND. SD3->D3_ESTORNO != 'S')
					_nQuant := _nQuant + SD3->D3_QUANT
				EndIf
				DbSelectArea("SD3")
				SD3->(DbSkip())
			End
		*/

		/*
		_cCampo := 'SB3->B3_Q'+Subs(dTOc(_dInicial),4,2)
		DbSelectArea("SB3")
		RecLock("SB3",.F.)
		&(_cCampo) := _nQuant
		MsUnLock()

		//If SB3->B3_COD > '602050'  // Eriberto 02/10/2007  02/04/09  09/09/10
			//Exit
		//EndIf 
	Endif	      
SB3->(DbSkip())
End
*/

If cWorkFlow = "N" 
	MsgBox("Fim do Processamento !!!","Atencao","ALERT")
Else 				
	ConOut("--------------------------")
	ConOut('DIPM_B3 agendado - Fim processamento- ' +Time())
    ConOut("--------------------------")
Endif

Return


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

Local aFilial := {}
Local cLocal  := "01"    
Local cFilSB3 := xFilial("SB3")

If cWorkFlow = "N" 
	Aadd(aFilial,cFilAnt) 
Else                                                            
	Aadd(aFilial,cWCodFil) 
Endif

DbSelectArea("SB3")
DbSeek(xFilial("SB3"),.T.)
ProcRegua(RecCount())

//DbSeek(xFilial("SB3")+'602049')	// Eriberto 02/10/2007  02/04/09  07/07/10  09/09/10

While SB3->(!Eof()) 

	If cFilSB3 == SB3->B3_FILIAL
		_cProd   := SB3->B3_COD
		_nQuant  := 0

	    // Busca o local padrão no cadastro de Produto - MCVN 02/12/10
    	cLocPad:= Posicione("SB1",1,xFilial("SB1")+_cProd,"B1_LOCPAD")
	    cLocal := If(cLocPad <> "",cLocPad,cLocal)

		IncProc("Processando: "+SB3->B3_COD)
	                
		
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
	  
		_cCampo := 'SB3->B3_Q'+Subs(dTOc(_dInicial),4,2)
		DbSelectArea("SB3")
		RecLock("SB3",.F.)
		&(_cCampo) := _nQuant
		MsUnLock()

 //	If SB3->B3_COD > '602050'  // Eriberto 02/10/2007  02/04/09  09/09/10
 //	   Exit
 //	EndIf 
	Endif	      
	SB3->(DbSkip())
End
If cWorkFlow = "N" 
	MsgBox("Fim do Processamento !!!","Atencao","ALERT")
Else 				
	ConOut("--------------------------")
	ConOut('DIPM_B3 agendado - Fim processamento- ' +Time())
    ConOut("--------------------------")
Endif

Return


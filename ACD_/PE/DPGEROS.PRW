#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"
//#INCLUDE "ACDA100.ch" 

/*-------------------------------------------------------------------------------------
{Protheus.doc} DPGERSO

@Author  	   Felipe Aguiar - Delta Decisao
@since		   12/2019
@version	   P12

@description Tela Geração de Ordem de Separação  
---------------------------------------------------------------------------------------
|Author                  | Date       | Description                                    |
|                        |            |                                                |
--------------------------------------------------------------------------------------*/

User Function DPGERSO()

	Private c_TitOdlg   := "Ordem de Separação"
	Private aSize       := MsAdvSize()
	Private a_Vet   	:= {}
	Private o_DlgPrinc	:= Nil
	Private a_Botao     := {}
	Private o_Lbx	    := Nil
	Private o_Check		:= LoadBitmap( GetResources(), "LBTIK") //CHECKED	//ENABLE	//LBOK
	Private o_UnCheck 	:= LoadBitmap( GetResources(), "LBNO")  //UNCHECKED	//DISABLE	//LBNO
	Private c_Perg      := "XDPGSO"
	Private o_LVerde    := LoadBitmap( GetResources(), "BR_VERDE")
	Private o_LVermelho	:= LoadBitmap( GetResources(), "BR_VERMELHO")
	Private o_LPreto	:= LoadBitmap( GetResources(), "BR_PRETO")

	aAdd(a_Botao,{"RELATORIO",{|| MntLeg()}	,"Legenda"	})
  
    If !Pergunte(c_Perg, .T.)
        Return(Nil)
    EndIF
    
    a_Vet := fGetOps()
    
	DEFINE MSDIALOG o_DlgPrinc TITLE c_TitOdlg From aSize[7],aSize[1] TO aSize[6],aSize[5] PIXEL OF oMainWnd
    
    @ 030,010 LISTBOX o_Lbx FIELDS HEADER ;	
    	" ", " ", "Filial", "Ordem de Produção","Item","Seq", "Produto","Apropri." ,"Descrição", "Emissão", "Quantidade","Log Ord.Sep.","Lote";
		COLSIZES 15, 15, 20, 60, 20, 40, 30;
		SIZE 120,150 OF o_DlgPrinc PIXEL ON dblClick( ClickOp() )
	o_Lbx:Align := CONTROL_ALIGN_ALLCLIENT

	o_Lbx:BHEADERCLICK := {|| fClickHeader() }

    o_Lbx:SetArray( a_Vet )
    o_Lbx:bLine := {|| {	Iif(a_Vet[o_Lbx:nAt,1], o_Check, o_UnCheck),;
                                a_Vet[o_Lbx:nAt,2],;
                                a_Vet[o_Lbx:nAt,3],;
                                a_Vet[o_Lbx:nAt,4],;
                                a_Vet[o_Lbx:nAt,5],;
                                a_Vet[o_Lbx:nAt,6],;
                                a_Vet[o_Lbx:nAt,7],;
                                a_Vet[o_Lbx:nAt,15],;
                                a_Vet[o_Lbx:nAt,11],;
                                a_Vet[o_Lbx:nAt,8],;
                                Transform(a_Vet[o_Lbx:nAt,9],"@E 999,999,999.99"),;
                                a_Vet[o_Lbx:nAt,10],;
                                a_Vet[o_Lbx:nAt,14]}}
    o_Lbx:Refresh()                            
    
	Set Key VK_F4 To ShowF4()

	ACTIVATE MSDIALOG o_DlgPrinc CENTER ON INIT EnchoiceBar(o_DlgPrinc,{|| Processa({|| fConfirm()}, "Gerando Ordem...") }, {|| o_DlgPrinc:End()},,a_Botao)

Return Nil

/*
|---------------------------------------------------------------------------|
| Programa  | fGetOps    | Autor | Felipe Aguiar          | Data | 26/12/19 |
|-----------+---------------------------------------------------------------|
| Descrição | Busca Ops     		         						        |
|-----------+---------------------------------------------------------------|
| Uso       | Dipromed                                                      |
|---------------------------------------------------------------------------|
*/

Static Function fGetOps()

	Local a_Ops     := {} 
	Local c_Query   := "" 	
	Local _nSldEst  := 0
	Local _oStatus  := 0
	Local _cOrdAnt  := ""
	Local aOrdSep := {},nI
	Local cCodOpe
	Local aRecSC2   := {}
	Local cTipExp
	Local aItemCB8  := {}
	Local lSai      := .f.
	Local cArm      := Space(Tamsx3("B1_LOCPAD")[1])
	Local lFilItens := ExistBlock("ACDA100I")  // Ponto de Entrada para filtrar o processamento dos itens selecionados
	Local cTM	    := GetMV("MV_CBREQD3")
	Local lConsEst  := .F. //SuperGetMV("MV_CBRQEST",,.F.)  // Considera a Estrutura do Produto x Saldo na geracao da Ordem de Separacao
	Local lParcial  := .F. //SuperGetMV("MV_CBOSPRC",,.F.)  // Permite ou nao gerar Ordens de Separacoes parciais
	Local lGera		:= .T.	
	Local nSalTotIt := 0
	Local nSaldoEmp := 0
	Local aSaldoSBF := {}
	Local aSaldoSDC := {}
	Local nSldGrv   := 0
	Local nRetSldEnd:= 0
	Local nRetSldSDC:= 0
	Local nSldAtu   := 0
	Local nQtdEmpOS := 0
	Local nPosEmp    
	Local nX
	Local l_Sai			:= .F.
	Local _aNEstoq  	:= {}
	Local _aOpSemEst := {}
	Local lAvalEst   := MV_PAR07 == 2
	
	Private _aSldProc  := {}
	Conout("fGetOps")

	c_Query   := " SELECT	* "
	c_Query   += " FROM	" +RetSqlName("SC2")+"(NOLOCK) "
	c_Query   += " WHERE	C2_NUM BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"'"	
	c_Query   += " AND  C2_EMISSAO BETWEEN '"+DTOS(MV_PAR03)+"' AND '"+DTOS(MV_PAR04)+"' "
	c_Query   += " AND  C2_PRODUTO BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR06+"' "
	/*
	If MV_PAR07 <> 2
		c_Query   += " AND  C2_ORDSEP = '' "
	EndIf
	*/
	c_Query   += " AND	D_E_L_E_T_ = '' "
	c_Query   += " ORDER BY C2_EMISSAO, C2_NUM "
	Conout(c_Query)

	If ( Select("QRY") > 0 )
		QRY->(DbCloseArea())
	Endif

	TcQuery c_Query New Alias "QRY"

	While ( QRY->(!Eof()) )
	
		DbSelectArea("SC2")
		SC2->(DbSetOrder(1) )       
		SC2->( dbGoTop() )
		DbSeek(xFilial("SC2")+QRY->C2_NUM+QRY->C2_ITEM+QRY->C2_SEQUEN)
		
		_cOp 	 := PADR(QRY->C2_NUM+QRY->C2_ITEM+QRY->C2_SEQUEN,TamSx3("D4_OP")[1])
	
		dbSelectArea("SD4")
		dbSetOrder(2)
		
		Conout("MV_PAR07")
		Conout(MV_PAR07)
		SD4->(DbSeek(xFilial('SD4')+_cOp))
		While SD4->(!Eof()) .And. SD4->D4_FILIAL+SD4->D4_OP == xFilial('SD4')+_cOp
			Conout(_cOp, SD4->D4_COD, SD4->D4_LOTECTL, SB1->B1_APROPRI, SD4->D4_TRT)

			_oStatus := IIF( ALLTRIM(SD4->D4_XORDSEP) == "" , o_LVerde, o_LVermelho )
			If MV_PAR07 == 2
				_oStatus := o_LVerde
			EndIf

			If MV_PAR07 == 1
				if alltrim(SD4->D4_XORDSEP) <> ''
					Conout("SD4->D4_XORDSEP",SD4->D4_XLOGSEP,"dbSkip por parametro 1 e ja possuir OS")
					SD4->(dbSkip())
					Loop
				endif
			endif
		
			If MV_PAR07 == 2
				If SD4->D4_XLOGSEP <> 'S'
					Conout("SD4->D4_XLOGSEP",SD4->D4_XLOGSEP,"dbSkip")
					SD4->(dbSkip())
					Loop
				EndIf
			EndIf
					
			//Posicione no cadastro de produtos
			dbSelectArea("SB1")
			dbSetOrder(1)
			MsSeek(xFilial("SB1")+SD4->D4_COD)

			//Considerar produtos indiretos
			If Alltrim(SB1->B1_APROPRI) == "I" .And. !Empty( SD4->D4_LOTECTL )
				Conout("SB1->B1_APROPRI", "I", "Empty Lote")
				SD4->(dbSkip())
				Loop
			EndIf
				
			If Alltrim(SB1->B1_TIPO) == "BN"
				Conout("SB1->B1_TIPO", "BN", "dbSkip")
				SD4->(dbSkip())
				Loop
			EndIf
		
			If MV_PAR07 == 2
				If SD4->D4_XLOGSEP <> "S"
					Conout("SD4->D4_XLOGSEP",SD4->D4_XLOGSEP,"dbSkip Repetido")
					SD4->(dbSkip())
					Loop
				EndIf
			EndIf
			
			//Faz a validacao do saldo em estoque
			_aAreaSD4 	:= SD4->(GetArea())			
			_lEstoq 	:= .T.
			_nQuant     := SD4->D4_QUANT
			Conout("SD4->D4_QUANT",SD4->D4_QUANT)
			
			//Conforme solicitação do Ivan verificar estoque do produto PI			
			If Alltrim(SB1->B1_APROPRI) <> "I" 
				_lEstoq 	:= ChkSdc()//ChkEstoq( SD4->D4_COD )
				if !_lEstoq .AND. MV_PAR07 == 2 //Se nao tem estoque mas é para ver produtos com problemas de estoque, eu testo o saldo em estoque
					_lEstoq 	:= ChkEstIN( SD4->D4_COD, "D", @_nQuant )
				endif
				Conout("ChkSdc",_lEstoq)
			Else				
				Conout("_nQuant", _nQuant)
				_lEstoq 	:= ChkEstIN( SD4->D4_COD, "I", @_nQuant )
				Conout("ChkEstIN",_lEstoq, SD4->D4_COD, "_nQuant", _nQuant)
											
				If _lEstoq
				
					nPos  := aScan( _aSldProc , { |x| x[1] == SD4->D4_COD } )
			 		If nPos > 0
			 		 	Conout("Achou _aSldProc e somou", SD4->D4_COD, SD4->D4_QUANT)
			 			_aSldProc[nPos][2] += SD4->D4_QUANT
			 		Else	
			 		 	Conout("Adicionou _aSldProc", SD4->D4_COD, SD4->D4_QUANT)
			 			AADD(_aSldProc, {  SD4->D4_COD, SD4->D4_QUANT }   )
			 		EndIf
			 					 							
				EndIf
			EndIf
												
			RestArea( _aAreaSD4 )
			 
			If !_lEstoq .And. !Alltrim(SB1->B1_TIPO) $ "PI"
			 	Conout("!_lEstoq .And. !Alltrim(SB1->B1_TIPO) $ 'PI'", "_aNEstoq", SD4->D4_OP, SD4->D4_COD, SD4->D4_LOTECTL )
				AADD(_aNEstoq , { SD4->D4_OP, SD4->D4_COD, SD4->D4_LOTECTL } )				
				//AADD( _aOpSemEst, SD4->D4_OP )
			ElseIf !_lEstoq .And. Alltrim(SB1->B1_TIPO) $ "PI"
			 	Conout("!_lEstoq .And. Alltrim(SB1->B1_TIPO) $ 'PI'", "_aNEstoq", SD4->D4_OP, SD4->D4_COD, SD4->D4_LOTECTL )
				AADD(_aNEstoq , { SD4->D4_OP, SD4->D4_COD, SD4->D4_LOTECTL } )				
			EndIf
				
			If SB1->B1_TIPO == "PI"
				Conout("PI")
			
				nPos  := aScan( a_Ops , { |x| x[3]+x[4]+x[5]+x[6]+x[7]+x[12]+x[14] ==;
				 			QRY->C2_FILIAL + QRY->C2_NUM + QRY->C2_ITEM+ QRY->C2_SEQUEN + SD4->D4_COD+SD4->D4_OPORIG+SD4->D4_LOTECTL } )
				
				If nPos > 0
					Conout("Achou e Somou", QRY->C2_FILIAL + QRY->C2_NUM + QRY->C2_ITEM+ QRY->C2_SEQUEN + SD4->D4_COD+SD4->D4_OPORIG+SD4->D4_LOTECTL, a_Ops[nPos][9], _nQuant)
					a_Ops[nPos][9] += _nQuant
				Else
				
					_cBlqEst := ""
					If _lEstoq
						_cBlqEst := "1"
					Else
						AADD(_aNEstoq , { SD4->D4_OP, SD4->D4_COD, SD4->D4_LOTECTL } )
						Conout("Adicionou NEstoque", SD4->D4_OP, SD4->D4_COD, SD4->D4_LOTECTL )
					EndIf
					
					/*_cBlqEst := ""					 									
					If Empty(SD4->D4_OPORIG) .Or. !Empty( SD4->D4_LOTECTL )
						_cBlqEst := "1"																		
					Else
						AADD(_aNEstoq , { SD4->D4_OP, SD4->D4_COD, SD4->D4_LOTECTL } )	
					EndIf*/
																									
					If _nQuant > 0
						Conout("_nQuant > 0", "add a_Ops", _nQuant)
						Conout("Adicionou a_Ops", QRY->C2_FILIAL + QRY->C2_NUM + QRY->C2_ITEM+ QRY->C2_SEQUEN + SD4->D4_COD+SD4->D4_OPORIG+SD4->D4_LOTECTL, _nQuant)
						aAdd(a_Ops, { .T.,;
							_oStatus ,;
							QRY->C2_FILIAL  	,;	
							QRY->C2_NUM		    ,;	
							QRY->C2_ITEM		,;	
							QRY->C2_SEQUEN		,;	
							SD4->D4_COD,;						
							DTOC(STOD(QRY->C2_EMISSAO)),;
							_nQuant,;
							"",;
							SB1->B1_DESC,;
							SD4->D4_OPORIG,;
							_cBlqEst,;
							SD4->D4_LOTECTL,;
							SB1->B1_APROPRI })
					EndIf
				EndIf
						
			Else
				Conout("Nao PI")

				nPos  := aScan( a_Ops , { |x| x[3]+x[4]+x[5]+x[6]+x[7]+x[14] ==;
				 			QRY->C2_FILIAL + QRY->C2_NUM + QRY->C2_ITEM+ QRY->C2_SEQUEN + SD4->D4_COD+ SD4->D4_LOTECTL } )

				If nPos > 0
					Conout("Achou e Somou", QRY->C2_FILIAL + QRY->C2_NUM + QRY->C2_ITEM+ QRY->C2_SEQUEN + SD4->D4_COD + SD4->D4_LOTECTL, a_Ops[nPos][9], _nQuant)
					a_Ops[nPos][9] += _nQuant
				Else
					
					If _nQuant > 0
						Conout("_nQuant > 0", "add a_Ops", _nQuant)
						Conout("Adicionou a_Ops", QRY->C2_FILIAL + QRY->C2_NUM + QRY->C2_ITEM+ QRY->C2_SEQUEN + SD4->D4_COD + SD4->D4_LOTECTL, _nQuant)
						aAdd(a_Ops, { .T.,;
							_oStatus ,;
							QRY->C2_FILIAL  	,;	
							QRY->C2_NUM		    ,;	
							QRY->C2_ITEM		,;	
							QRY->C2_SEQUEN		,;	
							SD4->D4_COD,;						
							DTOC(STOD(QRY->C2_EMISSAO)),;
							_nQuant,;
							"",;
							SB1->B1_DESC,;
							SD4->D4_OPORIG,;
							"",;
							SD4->D4_LOTECTL,;
							SB1->B1_APROPRI })
					EndIf
			     Endif	
				
					
			EndIf
		
			SD4->(dbSkip())
		EndDo
		
		QRY->(DbSkip())

	EndDo
			
	//Não gerar OS para ordens com produtos sem estoque''
	Conout("Não gerar OS para ordens com produtos sem estoque")
	For _nY := 1 To Len( _aOpSemEst )	
		For _nEst := 1 To Len( a_Ops )
			If Alltrim(a_Ops[_nEst][4]+a_Ops[_nEst][5]+a_Ops[_nEst][6]) == Alltrim(_aOpSemEst[_nY])
														
				If Empty(a_Ops[_nEst][13]) 
				
					a_Ops[_nEst][1]  := .F.
					a_Ops[_nEst][2]  := o_LPreto				
					a_Ops[_nEst][10] := ""
					
					cUpdate := "UPDATE "+RetSqlName("SD4")+" SET D4_XLOGSEP = 'S' "
					cUpdate += "WHERE D4_OP = '"+_aOpSemEst[_nY]+"' AND D_E_L_E_T_ = '' AND D4_FILIAL = '"+xFilial("SD4")+"' AND D4_LOTECTL = '"+a_Ops[_nEst][14]+"' "
					cUpdate += " AND D4_COD = '"+a_Ops[_nEst][07]+"' "
					Conout("cUpdate", _aOpSemEst[_nY], a_Ops[_nEst][14], a_Ops[_nEst][07] ) 
					Conout(cUpdate) 
					TCSQLEXEC(cUpdate)
				
				EndIf

			EndIf 
		Next 	
	Next _nY
	
	//Verificar os produtos sem estoque
	Conout("Verificar os produtos sem estoque")
	For _nY := 1 To Len( _aNEstoq )	
	
		For _nEst := 1 To Len( a_Ops )
		
			//Posicione no cadastro de produtos
			dbSelectArea("SB1")
			dbSetOrder(1)
			MsSeek(xFilial("SB1")+_aNEstoq[_nY][2])
			
			If Alltrim( SB1->B1_TIPO ) == "PI"
				Conout("PI", , "Update D4_XLOGSEP")
						
				If Empty(a_Ops[_nEst][13]) .And. Alltrim( _aNEstoq[_nY][2] ) == Alltrim( a_Ops[_nEst][7] ) .And.;
						Alltrim(a_Ops[_nEst][4]+a_Ops[_nEst][5]+a_Ops[_nEst][6]) == Alltrim(_aNEstoq[_nY][1])  
				
					a_Ops[_nEst][1]  := .F.
					a_Ops[_nEst][2]  := o_LPreto				
					a_Ops[_nEst][10] := "PRODUTO SEM ESTOQUE"
					
					cUpdate := "UPDATE "+RetSqlName("SD4")+" SET D4_XLOGSEP = 'S' "
					cUpdate += "WHERE D4_OP = '"+_aNEstoq[_nY][1]+"' AND D_E_L_E_T_ = '' AND D4_FILIAL = '"+xFilial("SD4")+"' AND D4_LOTECTL = '"+_aNEstoq[_nY][3]+"' "
					cUpdate += " AND D4_COD = '"+a_Ops[_nEst][07]+"' "					
					Conout("cUpdate", _aNEstoq[_nY][1], _aNEstoq[_nY][3], a_Ops[_nEst][07] ) 
					Conout(cUpdate) 
					TCSQLEXEC(cUpdate)
				
				EndIf
				
				
			Else
				Conout("Nao PI", "Update D4_XLOGSEP")
				
				//If Alltrim(a_Ops[_nEst][4]+a_Ops[_nEst][5]+a_Ops[_nEst][6]) == Alltrim(_aNEstoq[_nY][1])
				If Empty(a_Ops[_nEst][13]) .And. Alltrim( _aNEstoq[_nY][2] ) == Alltrim( a_Ops[_nEst][7] ) .And.;
						Alltrim(a_Ops[_nEst][4]+a_Ops[_nEst][5]+a_Ops[_nEst][6]) == Alltrim(_aNEstoq[_nY][1]) .And.;
						_aNEstoq[_nY][3] == a_Ops[_nEst][14]
				
					If Empty(a_Ops[_nEst][13]) 
					
						a_Ops[_nEst][1]  := .F.
						a_Ops[_nEst][2]  := o_LPreto				
						a_Ops[_nEst][10] := "PRODUTO SEM ESTOQUE"
						
						cUpdate := " UPDATE "+RetSqlName("SD4")+" SET D4_XLOGSEP = 'S' "
						cUpdate += " WHERE D4_OP = '"+_aNEstoq[_nY][1]+"' AND D_E_L_E_T_ = '' AND D4_FILIAL = '"+xFilial("SD4")+"' AND D4_LOTECTL = '"+_aNEstoq[_nY][3]+"' "
						cUpdate += " AND D4_COD = '"+a_Ops[_nEst][07]+"' "
						Conout("cUpdate", _aNEstoq[_nY][1], _aNEstoq[_nY][3], a_Ops[_nEst][07] ) 
						Conout(cUpdate) 
						TCSQLEXEC(cUpdate)
						
					
					EndIf
					
				EndIf
			
			EndIf
			 
		Next 	
	Next _nY
	
	If ( Len(a_Ops) == 0 ) 
		Conout("Sem itens na Grid a_Ops")
		aAdd( a_Ops , {.F.,"","","","","","","", 0, 0,"","","","","","" } )
	EndIf

Return a_Ops

/*
|---------------------------------------------------------------------------|
| Programa  | fClickHeader| Autor | Felipe Aguiar         | Data | 26/12/19 |
|-----------+---------------------------------------------------------------|
| Descrição | Busca Ops     		         						        |
|-----------+---------------------------------------------------------------|
| Uso       | Dipromed                                                      |
|---------------------------------------------------------------------------|
*/

Static Function fClickHeader()

	Local n_Lin := 0

	If ( MsgYesNo("Deseja inverter a marcação de todas as linhas?", "Confirmação") )

		For n_Lin := 1 To Len(a_Vet)

			a_Vet[n_Lin][1] := !a_Vet[n_Lin][1]

		Next n_Lin

		o_Lbx:Refresh()

	Endif

Return Nil 

/*
|---------------------------------------------------------------------------|
| Programa  | fConfirm | Autor | Felipe Aguiar            | Data | 26/12/19 |
|-----------+---------------------------------------------------------------|
| Descrição | Gera Oderns de Separação                          	        |
|-----------+---------------------------------------------------------------|
| Uso       | Dipromed                                                      |
|---------------------------------------------------------------------------|
*/

Static Function fConfirm()

	Local n_Lin      := 0
	Local a_AreaSD4  := SD4->(GetArea()) 
	Local a_AreaSC2  := SC2->(GetArea())
	Local nTotal     := Len(a_Vet)
	Local _cOrdAnt   := ""
	
	Private aLogOS := {}
	Private aEmp   := {}
	Private cOrdSep := ""
	Conout("fConfirm")

	Count To nTotal
	ProcRegua(nTotal)

	conout(varinfo("a_Vet",a_Vet))
	For n_Lin := 1 To Len(a_Vet)

		If Empty( a_Vet[n_Lin][4] )
			MsgInfo("Não existe produtos para gerar ordem de separação.")
			//fecha tela
			o_DlgPrinc:End()
			Retur Nil
		Else
		
			IncProc("O.P. " + ALLTRIM(a_Vet[n_Lin][4]) + "...")
			conout(a_Vet[n_Lin][1], a_Vet[n_Lin][7], a_Vet[n_Lin][9], a_Vet[n_Lin][14])
	
			If a_Vet[n_Lin][1]  
										
				DbSelectArea("SC2")
				SC2->(DbSetOrder(1) )       
				SC2->( dbGoTop() )
	
				//If DbSeek(xFilial("SC2")+a_Vet[n_Lin][4]+"01001")
				If DbSeek(xFilial("SC2")+a_Vet[n_Lin][4]+a_Vet[n_Lin][5]+a_Vet[n_Lin][6])
							
					If _cOrdAnt <> SC2->C2_NUM
						_cOrdAnt := SC2->C2_NUM
						
						While .T.						
							cOrdSep  := GetSXENum( "CB7", "CB7_ORDSEP" )
							Conout("testando se a Ord Sep Exsite :"+cOrdSep)												
							dbSelectArea("CB7")
							dbSetorder(1)					
							If !CB7->(DbSeek(xFilial("CB7")+cOrdSep))
								Conout("Nao Achou a Ord. Sep. Exit")
								Exit						
							EndIf					
						EndDo
						
						
					EndIf
					
					GerOSProd( a_Vet[n_Lin][7], a_Vet[n_Lin][9], a_Vet[n_Lin][14] )
				EndIF
			
			EndIf

		EndIf
	Next n_Lin

	LogACDA100()
	
	RestArea(a_AreaSC2)
	RestArea(a_AreaSD4)

	//fecha tela
	o_DlgPrinc:End()
Return Nil

/*
|---------------------------------------------------------------------------|
| Programa  | MntLeg   | Autor | Felipe Aguiar            | Data | 26/12/19 |
|-----------+---------------------------------------------------------------|
| Descrição | Monta Legenda                                       	        |
|-----------+---------------------------------------------------------------|
| Uso       | Dipromed                                                      |
|---------------------------------------------------------------------------|
*/

Static Function MntLeg()

	Local aLegenda := {	{"BR_VERDE" 	 	  , "Sem Ordem de Separação"	},;
						{"BR_VERMELHO"        , "Com Ordem de Separação"	},;
						{"BR_PRETO"        , "Sem estoque"	}}

	BrwLegenda("Legenda", "Legenda", aLegenda)

Return .T.

Static Function GerOSProd( _cProd, _nQtdProc, _cLotePrc )

	Local aOrdSep := {},nI
	Local cCodOpe
	Local aRecSC2   := {}
	Local cTipExp
	Local aItemCB8  := {}
	Local lSai      := .f.
	Local cArm      := Space(Tamsx3("B1_LOCPAD")[1])
	Local lFilItens := ExistBlock("ACDA100I")  // Ponto de Entrada para filtrar o processamento dos itens selecionados
	Local cTM	    := GetMV("MV_CBREQD3")
	Local lConsEst  := .F. //SuperGetMV("MV_CBRQEST",,.F.)  // Considera a Estrutura do Produto x Saldo na geracao da Ordem de Separacao
	Local lParcial  := .F. //SuperGetMV("MV_CBOSPRC",,.F.)  // Permite ou nao gerar Ordens de Separacoes parciais
	Local lGera		:= .T.
	Local lA100CABE := ExistBlock("A100CABE")
	Local lACD100GI := ExistBlock("ACD100GI")
	Local lACDA100F := ExistBlock("ACDA100F")
	Local lExtACDEMP := ExistBlock("ACD100EMP")
	Local nSalTotIt := 0
	Local nSaldoEmp := 0
	Local aSaldoSBF := {}
	Local aSaldoSDC := {}
	Local nSldGrv   := 0
	Local nRetSldEnd:= 0
	Local nRetSldSDC:= 0
	Local nSldAtu   := 0
	Local nQtdEmpOS := 0
	Local nPosEmp    
	Local nX
	Local l_Sai		:= .F.
	Local _cAmzProc := "01"
	Local aSldLote  := {}
	Local _cProdPrc  := ""
	Local _cLote  	 := ""
	Local _cEnder 	 := ""
	Local _cNumLot 	 := ""
	Local _cNumSerie := ""
	Local _lEmp      := .T.
	Local cQuery	 := ""
	Conout("")
	Conout("")
	Conout("*****************  GerOSProd  *****************", SC2->C2_NUM, _cProd, _nQtdProc, _cLotePrc)
	//aLogOS := {}
	cOP 		:= SC2->C2_NUM
	cArm 		:=Space(Tamsx3("B1_LOCPAD")[1])
	
	cTipExp := ""
	cCodOpe	 := ""
	
	cQuery := "SELECT *, R_E_C_N_O_ as D4_RECNO FROM "+RetSQLName("SD4")+" SD4 where D_E_L_E_T_='' AND D4_FILIAL='"+SC2->C2_FILIAL+"' AND D4_OP='"+SC2->C2_NUM+SC2->C2_ITEM+SC2->C2_SEQUEN+"' AND D4_COD = '"+_cProd+"' AND D4_LOTECTL='"+_cLotePrc+"' "
	conout(cQuery)
	If ( Select("TSD4") > 0 )
		TSD4->(DbCloseArea())
	Endif

	TcQuery cQuery New Alias "TSD4"

	While ( TSD4->(!Eof()) )
    	Conout("Passando pelo SD4 para gerar separacao "+TSD4->D4_OP+" - "+TSD4->D4_COD+" - "+TSD4->D4_TRT+" - "+ TSD4->D4_LOTECTL + " - "+ Alltrim(str(TSD4->D4_QUANT)))
    	    	    		    		    	    		    		    		    
		//Posicione no cadastro de produtos
		dbSelectArea("SB1")
		dbSetOrder(1)
		MsSeek(xFilial("SB1")+TSD4->D4_COD)
		Conout("Produto : "+SB1->B1_COD+" - "+SB1->B1_DESC)
		
		If Alltrim(SB1->B1_APROPRI) == "I" .And. !Empty( TSD4->D4_LOTECTL )
			Conout("Alltrim(SB1->B1_APROPRI) == 'I' .And. !Empty( TSD4->D4_LOTECTL )", "dbSkip", TSD4->D4_COD )
			TSD4->(dbSkip())
			Loop
		EndIf
			
		//Filtros na tabela de produtos
		//If (Alltrim(SB1->B1_APROPRI) == "I" .And. _nQtdProc > 0) //Modificado por que se for Sem Estoque Sim, Material Direto e o lote estiver em branco, ele deve procurar lote no Armazem 01
		conout(Alltrim(SB1->B1_APROPRI))
		conout(MV_PAR07)
		conout(ValType(MV_PAR07))
		conout(TSD4->D4_LOTECTL)
		conout(Empty(TSD4->D4_LOTECTL))
		
		Conout("Valido se deve entrar para pegar os saldos ou nao", (Alltrim(SB1->B1_APROPRI) == "I" .And. _nQtdProc > 0), (Alltrim(SB1->B1_APROPRI) <> "I" .AND. MV_PAR07 == 2 .AND. Empty(TSD4->D4_LOTECTL)), (Alltrim(SB1->B1_APROPRI) == "I" .And. _nQtdProc > 0) .OR. (Alltrim(SB1->B1_APROPRI) <> "I" .AND. MV_PAR07 == 2 .AND. Empty(TSD4->D4_LOTECTL)))
		 
		If (Alltrim(SB1->B1_APROPRI) == "I" .And. _nQtdProc > 0) .OR. (Alltrim(SB1->B1_APROPRI) <> "I" .AND. MV_PAR07 == 2 .AND. Empty(TSD4->D4_LOTECTL))
			if (Alltrim(SB1->B1_APROPRI) <> "I" .AND. MV_PAR07 == 2 .AND. Empty(TSD4->D4_LOTECTL))
				Conout("SB1->B1_APROPRI", "D", "Com Lote em branco" )
			else
				Conout("SB1->B1_APROPRI", "I", _nQtdProc )
			endif
					
			//Verificar os endereços disponiveis
			_cProdPrc := TSD4->D4_COD
			_nTotEmp  := 0 
			aSldLote  := RetSldEnd(_cProdPrc,.F.,, _cAmzProc )
			Conout(varinfo("aSldLote", aSldLote))

			If Len( aSldLote ) > 0
				Conout("Vou atualizar o Empenho excuindo o empenho atual **************** ")
				_lEmp := u_DDGrvEmp( 5, TSD4->D4_COD, TSD4->D4_LOCAL, TSD4->D4_OP, TSD4->D4_QUANT, TSD4->D4_LOTECTL, "", TSD4->D4_RECNO, TSD4->D4_TRT, TSD4->D4_OPORIG, TSD4->D4_PRODUTO )
			 
				dbSelectArea("CB7")
				dbSetorder(1)
				If !CB7->(DbSeek(xFilial("CB7")+cOrdSep))	
					Conout("Nao achei o CB7 e vou criar um novo")
					RecLock( "CB7", .T. )
					CB7->CB7_FILIAL := xFilial( "CB7" )
					CB7->CB7_ORDSEP := cOrdSep
					CB7->CB7_PEDIDO := cOrdSep
					CB7->CB7_OP     := cOP+cOrdSep
					CB7->CB7_LOCAL  := _cAmzProc
					CB7->CB7_DTEMIS := dDataBase
					CB7->CB7_HREMIS := Time()
					CB7->CB7_STATUS := " "   // Gravar STATUS de nao iniciada somente depois do processo
					CB7->CB7_CODOPE := cCodOpe
					CB7->CB7_PRIORI := "1"
					CB7->CB7_ORIGEM := "3"
					CB7->CB7_TIPEXP := cTipExp 
					Msunlock()
					ConfirmSX8()							
				EndIf
			Else
				aSavAtu := GetArea()
				DBSelectArea("SD4")
				DBGoTo(TSD4->D4_RECNO)
				SD4->(RecLock("SD4",.F.))
					SD4->D4_XLOGSEP := "S"
				SD4->(MsUnLock())
				RestArea(aSavAtu)
			EndIf
			
			//Verifica a CB8 para acumular valores por quantidade 
			For nY := 1 To Len( aSldLote )

				_cLote  	:= aSldLote[nY,4]
				_cEnder 	:= aSldLote[nY,3]
				_cNumLot 	:= aSldLote[nY,5]
				_cNumSerie 	:= aSldLote[nY,6]										
				_nQtdLot    := aSldLote[nY,7]
				
				Conout("**** For aSldLote", nY, _cLote, _cEnder, _nQtdLot, _nQtdProc)
				If _nQtdProc <= _nQtdLot
					_nQtdLot  := _nQtdProc
					_nQtdProc := 0
				Else
					_nQtdProc -= _nQtdLot
				EndIf
				Conout("Apos Ajuste _nQtdProc <= _nQtdLot")
				Conout(_nQtdProc, _nQtdLot)
			
			
				//Função para gerar um novo empenho
				_aSd4Atu := SD4->(GetArea())
				
				_lEmp := u_DDGrvEmp( 3, _cProdPrc, _cAmzProc, TSD4->D4_OP, _nQtdLot, _cLote, _cEnder, 0, "", TSD4->D4_OPORIG, TSD4->D4_PRODUTO )
				Conout("Empenho", _lEmp)
																																		 
				RestArea( _aSd4Atu )
				
				If _lEmp
				
					dbSelectArea("CB8")
					dbSetOrder(7) //CB8_FILIAL, CB8_ORDSEP, CB8_LOCAL, CB8_LCALIZ, CB8_PROD, CB8_LOTECT, CB8_NUMLOT, CB8_NUMSER, R_E_C_N_O_, D_E_L_E_T_                                                                            
					
					If !MsSeek(xFilial( "CB8" )+cOrdSep+Padr(_cAmzProc,TamSx3("CB8_LOCAL")[1])+_cEnder+TSD4->D4_COD+_cLote)
						Conout("Cria CB8", cOrdSep, _cProdPrc, _cAmzProc, _nQtdLot, _cLote, _cEnder )
						
						_nQtdEmb := GetAdvFVal("SB1","B1_XQE",xFilial("SB1")+_cProdPrc,1,1)
						if _nQtdEmb <= 0
							_nQtdEmb := 1
						endif
						
						cOrdSep := CB7->CB7_ORDSEP
						CB8->(RecLock( "CB8", .T. ))
						CB8->CB8_FILIAL := xFilial( "CB8" )
						CB8->CB8_ORDSEP := cOrdSep
						CB8->CB8_OP     := SC2->C2_NUM+cOrdSep
						CB8->CB8_ITEM   := RetItemCB8(cOrdSep,aItemCB8)
						CB8->CB8_PROD   := _cProdPrc
						CB8->CB8_LOCAL  := _cAmzProc
						if Alltrim(SB1->B1_APROPRI) == "I"
							CB8->CB8_QTDORI := DDTETO(_nQtdLot,_nQtdEmb)
							CB8->CB8_SALDOS := DDTETO(_nQtdLot,_nQtdEmb)
						else
							CB8->CB8_QTDORI := _nQtdLot
							CB8->CB8_SALDOS := _nQtdLot
						endif
						
						CB8->CB8_LCALIZ := _cEnder
						CB8->CB8_SEQUEN := ""
						CB8->CB8_LOTECT := _cLote
						CB8->CB8_NUMLOT := _cNumLot
						CB8->CB8_NUMSER := _cNumSerie
						CB8->CB8_CFLOTE := "1"
						
						CB8->(MsUnLock())
					Else
						Conout("Ja Existe CB8", CB8->CB8_ORDSEP, CB8->CB8_PROD, CB8->CB8_LOCAL, CB8->CB8_QTDORI, CB8->CB8_LOTECT, CB8->CB8_LCALIZ, _nQtdLot )

						_nQtdEmb := GetAdvFVal("SB1","B1_XQE",xFilial("SB1")+_cProdPrc,1,1)
						if _nQtdEmb <= 0
							_nQtdEmb := 1
						endif

						CB8->(RecLock( "CB8", .F. ))
						if Alltrim(SB1->B1_APROPRI) == "I"
							CB8->CB8_QTDORI += DDTETO(_nQtdLot,_nQtdEmb)
							CB8->CB8_SALDOS += DDTETO(_nQtdLot,_nQtdEmb)
						else
							CB8->CB8_QTDORI := _nQtdLot
							CB8->CB8_SALDOS := _nQtdLot
						endif
						CB8->(MsUnLock())
					EndIf
					
					_nTotEmp += _nQtdLot
					Conout("_nTotEmp", _nTotEmp)
				
				EndIf
				
				If _nQtdProc == 0
					Exit
				EndIf
				
			Next nY
							
			// Grava o historico das geracoes:
			aadd(aLogOS,{"1","OP",TSD4->D4_OP,"",_cAmzProc,"",CB7->CB7_ORDSEP})
			aadd(aOrdSep,cOrdSep)
																										
		Else
			Conout("SB1->B1_APROPRI", "<>" )
								
			If Alltrim(SB1->B1_TIPO) == "BN"
				Conout("SB1->B1_TIPO", "BN", "dbSkip")
				TSD4->(dbSkip())
				Loop
			EndIf
		
			If MV_PAR07 == 1
				If TSD4->D4_XLOGSEP == "S"
					Conout("TSD4->D4_XLOGSEP", "S", "dbSkip", "MV_PAR07 == 1")
					TSD4->(dbSkip())
					Loop
				EndIf
			Else					
				If MV_PAR07 == 2
				
					If TSD4->D4_XLOGSEP <> "S"
						Conout("TSD4->D4_XLOGSEP", "S", "dbSkip", "MV_PAR07 == 2")
						TSD4->(dbSkip())
						Loop
					EndIf
							
				EndIf
			EndIf
			
			If TSD4->D4_QUANT <= 0
				Conout("Empenho Negativo ou Zero", "dbSkip")
				TSD4->(DbSkip())
				Loop
			EndIf  

			//Verificar se o item tem empenho na SDC
			_cQrySdc := " SELECT DC_PRODUTO, DC_LOCAL,  DC_QUANT, DC_LOTECTL, DC_LOCALIZ "
			_cQrySdc += " FROM "+RetSqlName("SDC")+" "
			_cQrySdc += " WHERE DC_ORIGEM = 'SC2' "
			_cQrySdc += " AND DC_OP  = '"+TSD4->D4_OP+"' "
			_cQrySdc += " AND DC_PRODUTO = '"+TSD4->D4_COD+"' "
			_cQrySdc += " AND DC_LOTECTL = '"+TSD4->D4_LOTECTL+"' "				
			_cQrySdc += " AND DC_FILIAL = '"+xFilial("SDC")+"'
			_cQrySdc += " AND D_E_L_E_T_ = ''
			Conout("_cQrySdc", _cQrySdc)
			 				
			If ( Select("TSDC") > 0 )
				TSDC->(DbCloseArea())
			Endif
			
			TcQuery _cQrySdc New Alias "TSDC"
			
			dbSelectArea("TSDC")
			TSDC->(dbGotop())
			if TSDC->(!Eof())
			
				While TSDC->(!Eof())
				
					dbSelectArea("CB7")
					dbSetorder(1)
					
					If !CB7->(DbSeek(xFilial("CB7")+cOrdSep))	
						Conout("Cria CB7")
						CB7->(RecLock( "CB7", .T. ))
						CB7->CB7_FILIAL := xFilial( "CB7" )
						CB7->CB7_ORDSEP := cOrdSep
						CB7->CB7_PEDIDO := cOrdSep
						CB7->CB7_OP     := cOP+cOrdSep
						CB7->CB7_LOCAL  := _cAmzProc
						CB7->CB7_DTEMIS := dDataBase
						CB7->CB7_HREMIS := Time()
						CB7->CB7_STATUS := " "   // Gravar STATUS de nao iniciada somente depois do processo
						CB7->CB7_CODOPE := cCodOpe
						CB7->CB7_PRIORI := "1"
						CB7->CB7_ORIGEM := "3"
						CB7->CB7_TIPEXP := cTipExp 
						MsUnlock()
						ConfirmSX8()							
					EndIf
					
					//Verifica a CB8 para acumular valores por quantidade 
					dbSelectArea("CB8")
					dbSetOrder(7) //CB8_FILIAL+CB8_ORDSEP+CB8_LOCAL+CB8_LCALIZ+CB8_PROD+CB8_LOTECT+CB8_NUMLOT+CB8_NUMSER                                                                            
					
					If !MsSeek(xFilial( "CB8" )+cOrdSep+TSDC->DC_LOCAL+TSDC->DC_LOCALIZ+TSDC->DC_PRODUTO+TSDC->DC_LOTECTL)
						cOrdSep := CB7->CB7_ORDSEP
						Conout("Cria CB8", cOrdSep, TSDC->DC_PRODUTO, TSDC->DC_LOCAL, TSDC->DC_QUANT, TSDC->DC_LOTECTL, TSDC->DC_LOCALIZ )
						
						_nQtdEmb := GetAdvFVal("SB1","B1_XQE",xFilial("SB1")+TSDC->DC_PRODUTO,1,1)
						if _nQtdEmb <= 0
							_nQtdEmb := 1
						endif
	
						CB8->(RecLock( "CB8", .T. ))
						CB8->CB8_FILIAL := xFilial( "CB8" )
						CB8->CB8_ORDSEP := cOrdSep
						CB8->CB8_OP     := SC2->C2_NUM+cOrdSep
						CB8->CB8_ITEM   := RetItemCB8(cOrdSep,aItemCB8)
						CB8->CB8_PROD   := TSDC->DC_PRODUTO
						CB8->CB8_LOCAL  := TSDC->DC_LOCAL
						CB8->CB8_QTDORI := TSDC->DC_QUANT //DDTETO(TSDC->DC_QUANT,_nQtdEmb)
						CB8->CB8_SALDOS := TSDC->DC_QUANT //DDTETO(TSDC->DC_QUANT,_nQtdEmb)
																
						CB8->CB8_LCALIZ := TSDC->DC_LOCALIZ
						CB8->CB8_SEQUEN := ""
						CB8->CB8_LOTECT := TSDC->DC_LOTECTL
						CB8->CB8_NUMLOT := ""
						CB8->CB8_NUMSER := ""
						CB8->CB8_CFLOTE := "1"
						
						CB8->(MsUnLock())
					Else
						Conout("Ja Existe CB8", CB8->CB8_ORDSEP, CB8->CB8_PROD, CB8->CB8_LOCAL, CB8->CB8_QTDORI, CB8->CB8_LOTECT, CB8->CB8_LCALIZ, TSDC->DC_QUANT )

						_nQtdEmb := GetAdvFVal("SB1","B1_XQE",xFilial("SB1")+TSDC->DC_PRODUTO,1,1)
						if _nQtdEmb <= 0
							_nQtdEmb := 1
						endif
	
						CB8->(RecLock( "CB8", .F. ))
						CB8->CB8_QTDORI += TSDC->DC_QUANT //DDTETO(TSDC->DC_QUANT,_nQtdEmb)
						CB8->CB8_SALDOS += TSDC->DC_QUANT //DDTETO(TSDC->DC_QUANT,_nQtdEmb)
						CB8->(MsUnLock())
					EndIf
					
					// Grava o historico das geracoes:
					aadd(aLogOS,{"1","OP",TSD4->D4_OP,"",cArm,"",CB7->CB7_ORDSEP})
					aadd(aOrdSep,cOrdSep)
										
					TSDC->(dbSkip())
				EndDo
	
				aSavAtu := GetArea()
				DBSelectArea("SD4")
				DBGoTo(TSD4->D4_RECNO)
				SD4->(RecLock("SD4",.F.))
				SD4->D4_XORDSEP := cOrdSep
				If MV_PAR07 == 2
					SD4->D4_XLOGSEP := ""
					SD4->D4_XLOG	:= ""
				EndIf
				SD4->(MsUnLock())
				RestArea(aSavAtu)
			endif
		EndIf
		TSD4->(dbSkip())
	EndDo	
			
	
	aadd(aRecSC2,SC2->(Recno()))
	SC2->(dbSkip())

	CB7->(DbSetOrder(1))

	For nI := 1 to len(aOrdSep)
		if CB7->(DbSeek(xFilial("CB7")+aOrdSep[nI]))
			CB7->(RecLock("CB7"),.F.)
			CB7->CB7_STATUS := "0"  // Nao iniciado
			CB7->(MsUnlock())
		endif
	Next
	
	//Atualiza flag quando estiver com saldo
	If Len( aOrdSep ) > 0 
		For nI := 1 to len(aRecSC2)
			SC2->(DbGoto(aRecSC2[nI]))
			SC2->(RecLock("SC2"),.F.)
			SC2->C2_ORDSEP := cOrdSep
			SC2->(MsUnlock())
		Next	
	EndIf
	
	Conout("Fim GerOSProd")
		
Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ SemSldOS  ³ Autor ³ Microsiga             ³ Data ³ 20/05/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Analisa se os produtos empenhados possuem saldo suficiente  ³±±
±±³          ³ para a separacao (considera a estrutura)                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function SemSldOS()

	Local nUnPA := 0
	Local nX

	//aEmp:
	// [01] - OP
	// [02] - Produto
	// [03] - Quantidade
	// [04] - Saldo em Estoque
	// [05] - Quantidade na estrutura
	// [06] - Quantidade disponivel para a producao de um PA
	// [07] - Nova quantidade a ser definida para a meteria-prima (com base na estrutura)

	SG1->(DbSetOrder(1))
	// Calcula quantos produtos acabados podem ser gerados com as materias-primas empenhadas:
	For nX:=1 to Len(aEmp)
		If SG1->(DbSeek(xFilial("SG1")+SC2->C2_PRODUTO+aEmp[nX,02]))
			aEmp[nX,05] := SG1->G1_QUANT
			If aEmp[nX,04] >= aEmp[nX,03]  // Se tem saldo suficiente para atender a quantidade da OP:
				aEmp[nX,06] := SC2->C2_QUANT-(SC2->C2_QUJE+SC2->C2_PERDA)
			Else  // Se saldo insuficiente, encontrar o coeficiente para producao de um PA
				aEmp[nX,06] := (aEmp[nX,04]/SG1->G1_QUANT)
				If aEmp[nX,06] == 0
					aEmp[nX,06] := 0.1 // Se zero, novo valor deve ter residuo para processar abaixo
				Endif
			Endif
		Endif
	Next

	aSort(aEmp,,,{|x,y| x[06]<y[06]})

	// Verifico qual a menor unidade para producao de um produto acabado:
	// (descartando as materias-primas que nao fazem parte da estrutura e foram incluidas manualmente):
	For nX:=1 to Len(aEmp)
		If !Empty(aEmp[nX,06])
			nUnPA := Int(aEmp[nX,06])
			Exit
		Endif
	Next

	If nUnPA <= 0
		Return .t.
	Endif

	// Refaco a quantidade de materias-primas necessarias com base no coeficiente encontrado para producao do PA:
	For nX:=1 to Len(aEmp)
		If !Empty(aEmp[nX,05])  // Se empenho nao incluido manualmente
			aEmp[nX,07] := aEmp[nX,05] * nUnPA
		Else
			aEmp[nX,07] := aEmp[nX,03]
		Endif
	Next

Return .f.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ RetSldEnd ³ Autor ³ Microsiga                                                        ³ Data ³ 09/05/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna os saldos disponiveis nos enderecos:                                                           ³±±
±±³          ³ - Quando produto com apropriacao INDIRETA, disconsidera o saldo de Ordens de Separacao ainda nao sepa- ³±±
±±³          ³   radas;                                                                                               ³±±
±±³          ³ - Quando produto com apropriacao DIRETA, disconsidera apenas o saldo nao separado do item atual;       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function RetSldEnd(cProd,lRetSaldo,aVarAlt, cLocProc )

	Local aArea     := GetArea()
	Local aAreaSBF  := SBF->(GetArea())
	Local cArmProc  := GetMvNNR('MV_LOCPROC','99')
	Local cLocCQ    := GetMvNNR('MV_CQ','98')
	Local nSaldoAtu := 0
	Local nSaldoCB8 := 0
	Local nSaldoSBF := 0
	Local aSaldoSBF := {}
	Local cQuerySBF
	Local lQuery    := .F.
	Local cAliasSBF := "SBF"
	Local lACD100END                 

	Local cTM       := GetMV("MV_CBREQD3")
	Local lApropInd := CBArmProc(cProd,cTM)
	Local lExAcdEnd := ExistBlock("ACD100END")

	LocaL cArmOri    
	Local cEndOri    
	Local cLoteOri   
	Local cSLoteOri  
	Local cNumSerOri          
	Local nSldSepOri
	
	DEFAULT cLocProc := SD4->D4_LOCAL

	If aVarAlt<>NIL
		cArmOri    := aVarAlt[1]
		cEndOri    := aVarAlt[2]
		cLoteOri   := aVarAlt[3]
		cSLoteOri  := aVarAlt[4]
		cNumSerOri := aVarAlt[5]
		nSldSepOri := aVarAlt[6]
	EndIf

	lQuery    := .T.
	cQuerySBF := "SELECT * FROM " + RetSqlName("SBF")
	cQuerySBF += " WHERE BF_PRODUTO = '" + cProd + "' AND "
	cQuerySBF += " BF_LOCAL = '" + cLocProc + "' AND "
	cQuerySBF += " BF_FILIAL = '" + xFilial("SBF") + "' AND "
	cQuerySBF += RetSQLName("SBF") + ".D_E_L_E_T_ <> '*'"
	cQuerySBF += " ORDER BY BF_PRODUTO,BF_LOCAL,BF_LOTECTL,BF_NUMLOTE"
	cQuerySBF := ChangeQuery( cQuerySBF )

	TCQUERY cQuerySBF NEW ALIAS "SBFTMP"

	dbSelectArea("SBFTMP")
	cAliasSBF := "SBFTMP"

	While (cAliasSBF)->(!Eof() .AND. BF_FILIAL+BF_PRODUTO == xFilial("SBF")+cProd)
		If ((cAliasSBF)->BF_LOCAL == cArmProc) .or. (aVarAlt<>NIL .and. (cAliasSBF)->BF_LOCAL == cLocCQ)
			(cAliasSBF)->(DbSkip())
			Loop
		Endif
		If	lExAcdEnd
			lACD100END := ExecBlock("ACD100END",.F.,.F.,{(cAliasSBF)->BF_LOCAL,(cAliasSBF)->BF_LOCALIZ,(cAliasSBF)->BF_PRODUTO,(cAliasSBF)->BF_NUMSERI,(cAliasSBF)->BF_LOTECTL,(cAliasSBF)->BF_NUMLOTE})
			lACD100END := If(ValType(lACD100END)=="L",lACD100END,.T.)
			If !lACD100END
				(cAliasSBF)->(DbSkip())
				Loop
			Endif
		Endif
		If lApropInd
			nSaldoAtu := (cAliasSBF)->(SaldoSBF(BF_LOCAL,BF_LOCALIZ,BF_PRODUTO,BF_NUMSERI,BF_LOTECTL,BF_NUMLOTE))
			nSaldoCB8 := (cAliasSBF)->(RetSldCB8(BF_PRODUTO,BF_LOCAL,BF_LOCALIZ,BF_NUMSERI,BF_LOTECTL,BF_NUMLOTE))
			If (nSaldoAtu-nSaldoCB8) > 0
				nSaldoSBF += (nSaldoAtu-nSaldoCB8)
				aadd(aSaldoSBF,{(cAliasSBF)->BF_PRODUTO,(cAliasSBF)->BF_LOCAL,(cAliasSBF)->BF_LOCALIZ,(cAliasSBF)->BF_LOTECTL,(cAliasSBF)->BF_NUMLOTE,(cAliasSBF)->BF_NUMSERI,(nSaldoAtu-nSaldoCB8)})
			Endif
		Else                                                                                                        
			nSaldoAtu := (cAliasSBF)->(SaldoSBF(BF_LOCAL,BF_LOCALIZ,BF_PRODUTO,BF_NUMSERI,BF_LOTECTL,BF_NUMLOTE))
			If aVarAlt<> NIL .and. (cProd+cArmOri+cEndOri+cLoteOri+cSLoteOri+cNumSerOri) == (cAliasSBF)->(BF_PRODUTO+BF_LOCAL+BF_LOCALIZ+BF_LOTECTL+BF_NUMLOTE+BF_NUMSERI)
				//Se a chave SBF corresponder a chave do CB8, permitir que o usuario possa seleciona-la com o saldo a ser separado:
				nSaldoAtu := nSldSepOri
			Endif                                                                        
			
			If nSaldoAtu > 0
				nSaldoSBF += nSaldoAtu
				aadd(aSaldoSBF,{(cAliasSBF)->BF_PRODUTO,(cAliasSBF)->BF_LOCAL,(cAliasSBF)->BF_LOCALIZ,(cAliasSBF)->BF_LOTECTL,(cAliasSBF)->BF_NUMLOTE,(cAliasSBF)->BF_NUMSERI,nSaldoAtu})
			Endif
		Endif
		(cAliasSBF)->(DbSkip())
	Enddo
		
	If lQuery
		(cAliasSBF)->( DbCloseArea() )
	Endif

	aSort(aSaldoSBF,,,{|x,y| x[01]+x[02]+x[03]+x[04]+x[05]+x[06]<y[01]+y[02]+y[03]+y[04]+y[05]+y[06]})

	RestArea(aAreaSBF)
	RestArea(aArea)

Return If(lRetSaldo,nSaldoSBF,aSaldoSBF)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ RetEmpOS  ³ Autor ³ Microsiga             ³ Data ³ 20/05/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna a quantidade do produto a ser separada na Ordem de  ³±±
±±³          ³ Separacao                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function RetEmpOS(lConsEst,cProdEmp,nQtdEmp)

	Local nPos

	If !lConsEst
		Return nQtdEmp
	Endif

	nPos := Ascan(aEmp,{|x| x[02] == cProdEmp})

Return aEmp[nPos,07]

Static Function RetItemCB8(cOrdSep,aItemCB8)

	Local nPos := Ascan(aItemCB8,{|x| x[1] == cOrdSep})
	Local cItem :=' '

	If Empty(nPos )
		AAdd(aItemCB8,{cOrdSep,'00'})
		nPos := len(aItemCB8)
	EndIF

	cItem := Soma1(aItemcb8[nPos,2])
	aItemcb8[nPos,2]:= cItem

Return cItem

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³LogACDA100³ Autor ³ Henrique Gomes Oikawa ³ Data ³ 23/09/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Exibicao do log das geracoes das Ordens de Separacao       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nil                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Apos a geracao das OS sao exibidas todas as informacoes que³±±
±±³          ³ ocorreram durante o processo                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function LogACDA100()

	Local i, j, k
	Local cChaveAtu, cPedCli, cOPAtual

	// Cabecalho do Log de processamento:
	AutoGRLog(Replicate("=",75))
	AutoGRLog("                         I N F O R M A T I V O") //"                         I N F O R M A T I V O"
	AutoGRLog("               H I S T O R I C O   D A S   G E R A C O E S") //"               H I S T O R I C O   D A S   G E R A C O E S"

	// Detalhes do Log de processamento:
	AutoGRLog(Replicate("=",75))
	AutoGRLog( "I T E N S   P R O C E S S A D O S :") // "I T E N S   P R O C E S S A D O S :"
	AutoGRLog(Replicate("=",75))

	aLogOS := aSort(aLogOS,,,{|x,y| x[01]+x[07]+x[03]+x[04]<y[01]+y[07]+y[03]+y[04]})
	// Status Ord.Sep(1=Gerou;2=Nao Gerou) + Ordem Separacao + Ordem Producao + Produto
	cChaveAtu := ""
	cOPAtual  := ""

	For i:=1 to len(aLogOs)
		If aLogOs[i,07] <> cChaveAtu .OR. aLogOs[i,03] <> cOPAtual
			If !Empty(cChaveAtu)
				AutoGRLog(Replicate("-",75) )
			Endif
			j:=0
			k:=i  // Armazena o conteudo do contador do laco logico principal (i) pois o "For" j altera o valor de i;
			cChaveAtu := aLogOs[i,07]
			For j:=k to len(aLogOs)
				If aLogOs[j,07] <> cChaveAtu
					Exit
				Endif
				If Empty(aLogOs[j,05]) // Aglutina Armazem
					AutoGRLog( "Ordem de Producao: "+aLogOs[i,03]) // "Ordem de Producao: "
				Else
					AutoGRLog( "Ordem de Producao: "+aLogOs[i,03]+" - Local: "+aLogOs[j,05]) // "Ordem de Producao: "###" - Local: "
				Endif
				cOPAtual := aLogOs[j,03]
				If aLogOs[j,07] == "NAO_GEROU_OS"
					Exit
				Endif
				i:=j
			Next
			AutoGRLog("Ordem de Separacao: "+If(aLogOs[i,01]=="1",aLogOs[i,07],"N A O  G E R A D A")) // "Ordem de Separacao: "###"N A O  G E R A D A"
			If aLogOs[i,01] == "2"  // Ordem Sep. NAO gerada
				AutoGRLog( "Motivo: ") // "Motivo: "
			Endif
		Endif
		If aLogOs[i,01] == "2"  // Ordem Sep. NAO gerada
			AutoGRLog(" ---> "+aLogOs[i,06])
		Endif
	Next

	MostraErro()

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ RetSldCB8 ³ Autor ³ Microsiga             ³ Data ³ 13/05/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna os saldos que ainda nao foram separados nas OS      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function RetSldCB8(cProd,cLocal,cLocaliz,cNumSerie,cLote,cSubLote)

	Local aArea     := GetArea()
	Local aAreaCB7  := CB7->(GetArea())
	Local nSaldoCB8 := 0

	cQueryCB8 := "SELECT SUM(CB8_SALDOS) AS SALDOSEP FROM " + RetSqlName("CB7") + " CB7, " + RetSqlName("CB8") + " CB8"
	cQueryCB8 += " WHERE CB7.CB7_ORDSEP = CB8.CB8_ORDSEP AND CB7.CB7_OP <> '' AND CB7.CB7_REQOP <> '1' AND"
	cQueryCB8 += " CB8.CB8_LOCAL = '" + cLocal + "' AND CB8.CB8_LCALIZ = '" + cLocaliz + "' AND"
	cQueryCB8 += " CB8.CB8_NUMSER = '" + cNumSerie + "' AND CB8.CB8_LOTECT = '" + cLote + "' AND CB8.CB8_NUMLOT = '" + cSubLote + "' AND"
	cQueryCB8 += " CB8.CB8_PROD = '" + cProd + "' AND CB8.CB8_SALDOS > 0 AND"
	cQueryCB8 += " CB7.CB7_FILIAL = '" + xFilial("CB7") + "' AND CB8.CB8_FILIAL = '" + xFilial("CB8") + "' AND "
	cQueryCB8 += " CB7.D_E_L_E_T_ <> '*' AND CB8.D_E_L_E_T_ <> '*'"
	cQueryCB8 := ChangeQuery( cQueryCB8 )

	TCQUERY cQueryCB8 NEW ALIAS "CB8TMP"

	dbSelectArea("CB8TMP")
	CB8TMP->(DbGoTop())

	If CB8TMP->(!Eof())
		nSaldoCB8 := CB8TMP->SALDOSEP
	Endif

	CB8TMP->( DbCloseArea() )

	RestArea(aAreaCB7)
	RestArea(aArea)

Return nSaldoCB8

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ RetSldSDC ³ Autor ³ Microsiga             ³ Data ³ 25/05/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna os saldos disponiveis nas Composicoes de Empenho    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function RetSldSDC(cProd,cLocal,cOP,lRetSaldo,cLote,cSublote,cSequen)

	Local aArea     := GetArea()
	Local aAreaSDC  := SDC->(GetArea())
	Local nSaldoSDC := 0
	Local aSaldoSDC := {}
	Local cQuerySDC
	Local lQuery    :=.F.
	Local cAliasSDC := "SDC"

	DEFAULT cLote := ''
	DEFAULT cSubLote := ''

	lQuery    :=.T.
	cQuerySDC := "SELECT * FROM " + RetSqlName("SDC")
	cQuerySDC += " WHERE DC_PRODUTO = '" + cProd + "' AND DC_LOCAL = '" + cLocal + "' AND DC_OP = '" + cOP + "' AND "
	If !Empty(cLote)
		cQuerySDC += " DC_LOTECTL = '" + cLote + "' AND " 
	EndIf
	If !Empty(cSubLote)
		cQuerySDC += " DC_NUMLOTE = '" + cSubLote + "' AND " 
	EndIf
	If !Empty(cSequen)
		cQuerySDC += " DC_TRT = '" + cSequen + "' AND " 
	EndIf
	cQuerySDC += " DC_FILIAL = '" + xFilial("SDC") + "' AND " + RetSQLName("SDC") + ".D_E_L_E_T_ <> '*'"
	cQuerySDC += " ORDER BY R_E_C_N_O_"
	cQuerySDC := ChangeQuery( cQuerySDC )

	TCQUERY cQuerySDC NEW ALIAS "SDCTMP"

	dbSelectArea("SDCTMP")
	cAliasSDC := "SDCTMP"

	While (cAliasSDC)->(!Eof() .AND. DC_FILIAL+DC_PRODUTO+DC_LOCAL+DC_OP == xFilial("SDC")+cProd+cLocal+cOP)
	//While (cAliasSDC)->(!Eof() .AND. DC_FILIAL+DC_PRODUTO+DC_LOCAL+DC_OP+DC_LOTECTL == xFilial("SDC")+cProd+cLocal+cOP+cLote)
		nSaldoSDC += (cAliasSDC)->DC_QUANT
		aadd(aSaldoSDC,{(cAliasSDC)->DC_PRODUTO,(cAliasSDC)->DC_LOCAL,(cAliasSDC)->DC_LOCALIZ,(cAliasSDC)->DC_LOTECTL,(cAliasSDC)->DC_NUMLOTE,(cAliasSDC)->DC_NUMSERI,(cAliasSDC)->DC_QUANT,(cAliasSDC)->(recno())})
		(cAliasSDC)->(DbSkip())
	Enddo

	If lQuery
		(cAliasSDC)->( DbCloseArea() )
	Endif

	aSort(aSaldoSDC,,,{|x,y| x[08]<y[08]})

	RestArea(aAreaSDC)
	RestArea(aArea)

Return If(lRetSaldo,nSaldoSDC,aSaldoSDC)

/*/{Protheus.doc} ClickOp
//Função para marca ou desmarcar itens da op
@author delta01
@since 02/02/2020
@version 1.0
@return ${return}, ${return_description}
@param _cOp, , descricao
@type function
/*/
Static Function ClickOp()

Local _nX := 0

/*For _nX := 1 To Len(a_Vet)

	If a_Vet[_nX][4] == a_Vet[o_Lbx:nAt][4]
		a_Vet[_nX][1]:=!a_Vet[_nX][1]
	Endif

Next _nX*/ 

If a_Vet[o_Lbx:nAt][2] == o_LVerde 
	a_Vet[o_Lbx:nAt][1]:=!a_Vet[o_Lbx:nAt][1]
Else
	MsgInfo("Status não permite marcação.")
EndIf

o_Lbx:Refresh()  
    
Return .t.
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ ChkEstoq ³ Autor ³ Diego fernandes        ³ Data ³ 25/05/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao para realizar validacao do estoque 			       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ChkEstoq( _cProd, _cTipo, _nQuant )

	Local aOrdSep := {},nI
	Local cCodOpe
	Local aRecSC2   := {}
	Local cTipExp
	Local aItemCB8  := {}
	Local lSai      := .f.
	Local cArm      := Space(Tamsx3("B1_LOCPAD")[1])
	Local lFilItens := ExistBlock("ACDA100I")  // Ponto de Entrada para filtrar o processamento dos itens selecionados
	Local cTM	    := GetMV("MV_CBREQD3")
	Local lConsEst  := .F. //SuperGetMV("MV_CBRQEST",,.F.)  // Considera a Estrutura do Produto x Saldo na geracao da Ordem de Separacao
	Local lParcial  := .F. //SuperGetMV("MV_CBOSPRC",,.F.)  // Permite ou nao gerar Ordens de Separacoes parciais
	Local lGera		:= .T.	
	Local nSalTotIt := 0
	Local nSaldoEmp := 0
	Local aSaldoSBF := {}
	Local aSaldoSDC := {}
	Local nSldGrv   := 0
	Local nRetSldEnd:= 0
	Local nRetSldSDC:= 0
	Local nSldAtu   := 0
	Local nQtdEmpOS := 0
	Local nPosEmp    
	Local nX
	Local l_Sai		:= .F.
	Local lRet      := .T.

	Private aLogOS := {}
	Private aEmp   := {}
	Private cOrdSep := ""

	// Analisar a pergunta '00-Separcao,01-Separacao/Embalagem,02-Embalagem,03-Gera Nota,04-Imp.Nota,05-Imp.Volume,06-embarque,07-Requisita'
	cTipExp := ""
	cCodOpe	 := ""

	SB2->(DbSetOrder(1))
	SD4->(DbSetOrder(2))
	SDC->(dbSetOrder(2))
	CB7->(DbSetOrder(1))
	CB8->(DbSetOrder(6))
	lSai := .f.
	aEmp := {}
	
	SD4->(DbSeek(xFilial('SD4')+PADR(SC2->C2_NUM+SC2->C2_ITEM+SC2->C2_SEQUEN,TamSx3("D4_OP")[1])+_cProd))
	
    While SD4->(! Eof() .And. D4_FILIAL+Alltrim(D4_OP)+D4_COD == xFilial('SD4')+SC2->C2_NUM+SC2->C2_ITEM+SC2->C2_SEQUEN+ _cProd ) 
		If SD4->D4_QUANT <= 0
			SD4->(DbSkip())
			Loop
		Endif
		If lParcial .And. Localiza(SD4->D4_COD)// Se permitir parcial, controlar localização e nao existir composição de empenho, passa para o proximo.   
			If !CBArmProc(SD4->D4_COD,cTM)
				aSaldoSDC := RetSldSDC(SD4->D4_COD,SD4->D4_LOCAL,SD4->D4_OP,.F.,"","",SD4->D4_TRT)
				If Empty(aSaldoSDC)
				    SD4->(DbSkip())
				    Loop
	             EndIf
			Else
				aSaldoSBF := RetSldEnd(SD4->D4_COD,.f.)
				If Empty(aSaldoSBF)
					SD4->(DbSkip())
					Loop
				EndIf
			EndIf  
	    EndIf
		SB1->(DBSetOrder(1))
		If SB1->(DbSeek(xFilial("SB1")+SD4->D4_COD)) .And. IsProdMOD(SD4->D4_COD)
			SD4->(DbSkip())
			Loop
		Endif
		
		//Filtros na tabela de produtos
		//Considerar produtos indiretos
		If Alltrim(SB1->B1_APROPRI) == "I"
			SD4->(dbSkip())
			Loop
		EndIf
				
		If Alltrim(SB1->B1_TIPO) == "BN"
			SD4->(dbSkip())
			Loop
		EndIf
	
		If MV_PAR07 == 2
			If SD4->D4_XLOGSEP <> "S"
				SD4->(dbSkip())
				Loop
			EndIf
		EndIf
	
		If !Localiza(SD4->D4_COD) // Nao controla endereco
			SB2->(DbSeek(xFilial("SB2")+SD4->(D4_COD+D4_LOCAL)))
			nSldAtu := If(CBArmProc(SD4->D4_COD,cTM),SB2->B2_QATU,SaldoSB2())
			nPosEmp := Ascan(aEmp,{|x| x[02] == SD4->D4_COD})
			If nPosEmp == 0
				aadd(aEmp,{SD4->D4_OP,SD4->D4_COD,SD4->D4_QUANT,nSldAtu,0,0,0})
			Else
				aEmp[nPosEmp,03] += SD4->D4_QUANT
			Endif
			SD4->(DbSkip())
			Loop
		Endif
		
		nRetSldEnd := RetSldEnd(SD4->D4_COD,.t.)
				
		If SD4->D4_QUANT > nRetSldEnd .AND. !lConsEst
			// Grava o historico das geracoes:
			aadd(aLogOS,{"2","OP",SD4->D4_OP,SD4->D4_COD,"","O produto "+Alltrim(SD4->D4_COD)+" Nao possui saldo enderecado suficiente."+CHR(13)+CHR(10)+"        (ou existem Ordens de Separacao ainda nao requisitadas)","NAO_GEROU_OS"}) // "OP"###"O produto " //" Nao possui saldo enderecado suficiente."###"        (ou existem Ordens de Separacao ainda nao requisitadas)"
			lSai := .T.
			lRet := .F.			
			//Grava o log na SD4	
			SD4->(RecLock("SD4",.F.))
				SD4->D4_XLOGSEP := "S"
				SD4->D4_XLOG := "O produto "+Alltrim(SD4->D4_COD)+" Nao possui saldo enderecado suficiente.(ou existem Ordens de Separacao ainda nao requisitadas)"
			SD4->(MsUnLock())			
		EndIf
		
		nPosEmp := Ascan(aEmp,{|x| x[02] == SD4->D4_COD})
		If nPosEmp == 0
			aadd(aEmp,{SD4->D4_OP,SD4->D4_COD,SD4->D4_QUANT,If(CBArmProc(SD4->D4_COD,cTM),nRetSldEnd,nRetSldSDC),0,0,0})
		Else
			aEmp[nPosEmp,03] += SD4->D4_QUANT
		Endif
		SD4->(DbSkip())
		//Loop
	EndDo
	
Return( lRet )
	
/*/{Protheus.doc} ChkEstIN
//Funcao para verificar saldo em processo
@author d fernandes
@since 19/03/2020
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function ChkEstIN( cProd, _cOrig, _nQuant )

Local _cLocPro  := "01"
Local cTM	    := GetMV("MV_CBREQD3")
Local lRet 		:= .T.
Conout("ChkEstIN", cProd, _cOrig, _nQuant)

dbSelectArea("SB2")
dbSetOrder(1)

If SB2->( DbSeek( xFilial("SB2")+cProd+_cLocPro ) )
	Conout("Achou SB2")
	dbSelectArea("SB1") 
	dbSetOrder(1)
	MsSeek(xFilial("SB1")+cProd)
	
	nSldAtu := If(CBArmProc(cProd,cTM),SB2->B2_QATU-SB2->B2_QEMP,SaldoSB2())
	Conout("nSldAtu", nSldAtu)
	
	//Verificar se já foi utulizado saldo na OP
	nPos  := aScan( _aSldProc , { |x| x[1] == cProd } )
	If nPos > 0
		Conout("Achei o produto nessa OP, vou diminuir o Saldo Atual do produto", nSldAtu, _aSldProc[nPos][2])
		nSldAtu -= _aSldProc[nPos][2]		
	EndIf

	If nSldAtu < 0
		Conout("Saldo ficou menor que zero, zero o saldo")
		nSldAtu := 0
	EndIf			
	
	//_nQuant -= nSldAtu	
	nSldAtu -= _nQuant
	If nSldAtu < 0
		//Conout("Saldo Menor Aplicao a regra do B1_XQE")
		//_nQuant := Ceiling( ABS( nSldAtu ) / SB1->B1_XQE ) * SB1->B1_XQE
		lRet    := .F. 
	/*Else
		_nQuant := 0*/
	EndIf
	Conout("Retorno", lRet, _nQuant)
EndIf

Return( lRet ) 

/*/{Protheus.doc} u_DDGrvEmp
//Funcao para realizar gravação do empenho 
@author dfern
@since 21/06/2020
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
User Function DDGrvEmp( _nOpc, cProduto, cLocal, cOp, nQuant, cLote, cEnder, nRecno, _cTRT, cOpOrig, cProdPai, cLogSep, _lTela )

Local aMata380 := {}
Local aEmpen   := {}
Local lRet     := .T.
Local cTRT	   := CriaVar("D4_TRT")

DEFAULT _nOpc    := 3
DEFAULT _cTRT    := CriaVar("D4_TRT")
DEFAULT cLogSep	 := ""
DEFAULT _lTela	 := .F.

Conout("****************** DDGrvEmp ******************* cProduto, cLocal, cOp, nQuant, cLote, cEnder, nRecno ", cProduto, cLocal, cOp, nQuant, cLote, cEnder, nRecno)
conout("Operacao: "+alltrim(str(_nOpc)))

dbSelectArea("SD4")
if _nOpc == 3
	aSavAtu := GetArea()
	aSavSD4 := SD4->(GetArea())
	dbSetOrder(2) //D4_FILIAL+D4_OP+D4_COD+D4_LOCAL
	//se for inclusao, valido o TRT para ver se ja nao existe para evitar erros no execauto
	if DBSeek(xFilial("SD4")+cOp+cProduto)
		While !SD4->(Eof()) .AND. SD4->D4_FILIAL+SD4->D4_OP+SD4->D4_COD == xFilial("SD4")+cOp+cProduto
			cTRT := Soma1(SD4->D4_TRT)
			SD4->(DBSkip())
		EndDo
	endif
	RestArea(aSavSD4)
	RestArea(aSavAtu)
else
	//Se for exclusao, passo o TRT
	if !Empty(_cTRT)
		cTRT := _cTRT
	endif
endif

dbSetOrder(1)//D4_FILIAL, D4_COD, D4_OP, D4_TRT, D4_LOTECTL
if nRecno > 0
	DBGoTo(nRecno)
endif

aAdd(aMata380,{"D4_COD"    , cProduto 			,NIL})
aAdd(aMata380,{"D4_LOCAL"  , cLocal				,NIL})
aAdd(aMata380,{"D4_OP"     , cOp				,NIL})
aAdd(aMata380,{"D4_DATA"   , dDataBase			,NIL})
aAdd(aMata380,{"D4_QTDEORI", nQuant				,NIL})
aAdd(aMata380,{"D4_QUANT"  , nQuant				,NIL})
aAdd(aMata380,{"D4_TRT"    , cTRT	 			,NIL})
aAdd(aMata380,{"D4_LOTECTL", cLote				,NIL})
aAdd(aMata380,{"D4_NUMLOTE", CriaVar("D4_NUMLOTE"),NIL})
aAdd(aMata380,{"D4_XEMPMAN", "S"				,NIL})
aAdd(aMata380,{"D4_XORDSEP", cOrdSep			,NIL})
aAdd(aMata380,{"D4_XLOGSEP", cLogSep			,NIL})
aAdd(aMata380,{"D4_OPORIG" , cOpOrig			,NIL})
aAdd(aMata380,{"D4_PRODUTO", cProdPai			,NIL})
aAdd(aMata380,{"D4_POTENCI", CriaVar("D4_POTENCI"),NIL})
		
lMSErroAuto := .F.
lMSHelpAuto := .F.

//ALERT(cProduto+"/"+cLocal+"/"+cEnder)

if Empty(cEnder)
	aEmpen := {}
else
	AADD(aEmpen,{ nQuant								,;   // SD4->D4_QUANT
				  PADR(cEnder, TamSX3("DC_LOCALIZ")[1])	,;  // DC_LOCALIZ
				  CriaVar("DC_NUMSERI")					,;  // DC_NUMSERI
				  0										,;  // D4_QTSEGUM
				  .F.})
endif	            

Conout(VarInfo("aMata380",aMata380))
Conout(VarInfo("aEmpen",aEmpen))
MsExecAuto({|x,y,z|MATA380(x,y,z)},aMata380,_nOpc, aEmpen )

If lMSErroAuto
	lRet  := .F.
	if !_lTela 
		cPath := GetSrvProfString("Startpath","")
		cArquivo := "ErrorLog_"+CriaTrab(,.F.)
		MostraErro(cPath,cArquivo)
		cMsg := MemoRead(cPath+"\"+cArquivo)
	    conout("Erro Execauto MATA380", cMsg)
	else
		MostraErro()
	endif
	//DisarmTransaction()
	Conout("Erro no execauto acima!")
EndIf	

Return( lRet )
/*/{Protheus.doc} DPTRAN01
//Função para realizar a transferencia dos produtos para o amz 99
@author dfern
@since 21/06/2020
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
User Function DPTRAN01(_cOrdSep, _lTela)

Local aAreaATU  := GetArea()
Local cArmProc  := GetMvNNR('MV_LOCPROC','99')
Local cEndProc  := "PRODUCAO" //GetNewPar('MV_ENDPROC','PRODUCAO')       
Local lRet		:= .T.
Local aNovoEmp	:= {} //Necessário por que apos a exclusao, a query esta ficando sem dados.
Local nI
Conout("DPTRAN01 ****************************************************")

DEFAULT _cOrdSep := CriaVar("D4_XORDSEP",.F.)
DEFAULT _lTela	 := .F. 

Private cOrdSep := _cOrdSep //Por compactibilidade de outras chamadas

//Exclusao dos empenhos gerados pela rotina da ordem de separação
cQuery := " SELECT *, R_E_C_N_O_ AS D4_RECNO FROM "+RetSQLName("SD4")+" " 
cQuery += " WHERE D4_FILIAL = '"+xFilial("SD4")+"' "
cQuery += " AND D4_XORDSEP = '"+cOrdSep+"' "
cQuery += " AND D4_XEMPMAN = 'S' "
cQuery += " AND D_E_L_E_T_ = '' "
Conout(cQuery)

If ( Select("TSD4") > 0 )
	TSD4->(DbCloseArea())
Endif

TcQuery cQuery New Alias "TSD4"

BEGIN TRANSACTION

dbSelectArea("TSD4")
TSD4->(dbGotop())
//Cancelo os empenhos para serem transferidos do armazem 01 para o 99 via Ordem de Separação
While !TSD4->(Eof())

	dbSelectArea("SD4")
	dbGoto( TSD4->D4_RECNO )
	
	dbSelectArea("SB1")
	dbSetOrder(1)	
	MsSeek(xFilial("SB1")+TSD4->D4_COD)
	
	//Se for material direto nao deve fazer a exclusao do empenho e nem a transferencia para o armazem de produção.
	if Alltrim(SB1->B1_APROPRI) <> "I"
		TSD4->(dbSkip())
		Loop		
	endif
	
	//Varificacao para nao se transferir mais de uma vez, caso seja executada a rotina via menu da ACDA100
	if alltrim(TSD4->D4_LOCAL) == Alltrim(cArmProc)
		TSD4->(dbSkip())
		Loop		
	endif
	
	//Adiciono os dados no array por que apos a exclusao para incluir apos a transferencia
	aadd(aNovoEmp, {TSD4->D4_COD, TSD4->D4_LOCAL, TSD4->D4_OP, TSD4->D4_QUANT, TSD4->D4_LOTECTL, "", TSD4->D4_RECNO, TSD4->D4_TRT, TSD4->D4_OPORIG, TSD4->D4_PRODUTO })
	lRet := u_DDGrvEmp( 5, TSD4->D4_COD, TSD4->D4_LOCAL, TSD4->D4_OP, TSD4->D4_QUANT, TSD4->D4_LOTECTL, "", TSD4->D4_RECNO, TSD4->D4_TRT, TSD4->D4_OPORIG, TSD4->D4_PRODUTO, nil, _lTela )
	if !lRet
		Conout("Erro ao excluir Empenho - Disarmando Transação")
		DisarmTransaction()
		Break
	endif
				 			 			
	TSD4->(dbSkip())
EndDo

lRet := ExeTransf(cOrdSep, _lTela)
Conout("Apos o ExeTransf", lRet)

if !lRet
	Conout("Erro na Transferencia - Disarmando Transação")
	DisarmTransaction()
	Break
endif

//Incluo os empenhos apos a transferencia via Ordem de Separação
if lRet 
	Conout("Vou iniciar o processo de Inclusao dos Empenhos", lRet)
	For nI := 1 to Len(aNovoEmp)
	
		dbSelectArea("SB1")
		dbSetOrder(1)	
		MsSeek(xFilial("SB1")+aNovoEmp[nI][1])

		lRet := u_DDGrvEmp( 3, aNovoEmp[nI][1], cArmProc, aNovoEmp[nI][3], aNovoEmp[nI][4], aNovoEmp[nI][5], cEndProc, 0, "", aNovoEmp[nI][9], aNovoEmp[nI][10], "", _lTela )
		if !lRet
			Conout("Erro no Empenho - Disarmando Transação")
			DisarmTransaction()
			Break
		endif
					 			 			
	Next nI
endif

END TRANSACTION

If ( Select("TSD4") > 0 )
	TSD4->(DbCloseArea())
Endif

RestArea(aAreaATU)

Conout("FIM DPTRAN01 ****************************************************")

Return lRet

/*/{Protheus.doc} ExeTransf
//Função para realizar a transferencia para o armazem de processo
@author dfern
@since 21/06/2020
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function ExeTransf( cOrdSep, _lTela )

Local aAuto := {}
Local aItem := {}
Local aLinha := {}
Local nX
Local nOpcAuto := 0
Local cDocumen := ""
Local lContinua := .T.
Local _cQuery   := ""
Local cArmProc  := GetMvNNR('MV_LOCPROC','99')
Local cEndProc  := "PRODUCAO" //GetNewPar('MV_ENDPROC','PRODUCAO')
Local lTransf := .F.

DEFAULT _lTela := .F.

Private lMsErroAuto := .F.
Conout("ExeTransf ***************************************************** ")

//Buscar os empenhos em aberto na SDC 
_cQuery   := " SELECT CB8.*, SB8.B8_DTVALID "
_cQuery   += " FROM "+RetSqlName("CB8")+" CB8 "
_cQuery   += " LEFT JOIN "+RetSqlName("SB8")+" SB8 ON B8_FILIAL=CB8_FILIAL AND B8_PRODUTO=CB8_PROD AND B8_LOCAL=CB8_LOCAL AND B8_LOTECTL=CB8_LOTECT AND SB8.D_E_L_E_T_='' "
_cQuery   += " WHERE CB8_FILIAL = '"+xFilial("CB8")+"' "
_cQuery   += " AND CB8_ORDSEP = '"+cOrdSep+"' "
_cQuery   += " AND CB8.D_E_L_E_T_ = '' "
Conout(_cQuery)

If ( Select("TCB8") > 0 )
	TCB8->(DbCloseArea())
Endif

TcQuery _cQuery New Alias "TCB8"
TcSetField("TCB8", "B8_DTVALID", "D")

dbSelectArea("TCB8")
TCB8->(dbGotop())

//Cabecalho a Incluir
cDocumen := GetSxeNum("SD3","D3_DOC")

aadd(aAuto,{cDocumen,dDataBase}) //Cabecalho

//Itens a Incluir
aItem := {}
_nEmp := 0

While TCB8->(!Eof())

    //Origem
    dbSelectArea("SB1")
    dbSetOrder(1)
    SB1->(DbSeek(xFilial("SB1")+TCB8->CB8_PROD))
    
	//Se for material direto nao deve fazer a exclusao do empenho e nem a transferencia para o armazem de produção.
	if Alltrim(SB1->B1_APROPRI) <> "I"
		TCB8->(dbSkip())
		Loop		
	endif
        
    lTransf := .T. //Controlo para ver se a separacao tem que fazer transferencia
	aAdd(aAuto,{	SB1->B1_COD															,; // 01.Produto Origem
							SB1->B1_DESC												,; // 02.Descricao
							SB1->B1_UM													,; // 03.Unidade de Medida
							TCB8->CB8_LOCAL												,; // 04.Local Origem
							TCB8->CB8_LCALIZ											,; // 05.Endereco Origem
							SB1->B1_COD													,; // 06.Produto Destino
							SB1->B1_DESC												,; // 07.Descricao
							SB1->B1_UM													,; // 08.Unidade de Medida
							cArmProc					   								,; // 09.Armazem Destino
							cEndProc													,; // 10.Endereco Destino
							CriaVar("D3_NUMSERI",.F.)									,; // 11.Numero de Serie
							TCB8->CB8_LOTECT											,; // 12.Lote Origem
							CriaVar("D3_NUMLOTE",.F.)									,; // 13.Sublote
							TCB8->B8_DTVALID											,; // 14.Data de Validade
							CriaVar("D3_POTENCI",.F.)									,; // 15.Potencia do Lote
							TCB8->CB8_QTDORI											,; // 16.Quantidade
							CriaVar("D3_QTSEGUM",.F.)									,; // 17.Quantidade na 2 UM
							CriaVar("D3_ESTORNO",.F.)									,; // 18.Estorno
							CriaVar("D3_NUMSEQ",.F.)									,; // 19.NumSeq
							TCB8->CB8_LOTECT											,; // 20.Lote Destino
							TCB8->B8_DTVALID											,; // 21.Data de Validade do DestinoS
							Criavar("D3_ITEMGRD",.F.)									,; // 22.Item grade MCVN - 16/11/09)
							""															,;												
							"processo de separacao transferencia para o armazem 99"		,; // 23.Explicacao
							"" }) 														   // 24. Numero de separacao
							
									        
    TCB8->(dbSkip())
EndDo

if lTransf
	conout(varinfo("aAuto",aAuto))
	MSExecAuto({|x,y| mata261(x,y)}, aAuto ,3)
	
	if lMsErroAuto
	    lContinua := .F.    
		if !_lTela
			cPath := GetSrvProfString("Startpath","")
			cArquivo := "ErrorLog_"+CriaTrab(,.F.)
			MostraErro(cPath,cArquivo)
			cMsg := MemoRead(cPath+"\"+cArquivo)
		    conout("Erro Execauto MATA261", cMsg)
		else
			MostraErro()
		endif
	Else
	    conout("Inclusão de movimentação multipla efetuada com sucesso")
	    lContinua := .T.
	EndIf
endif

If ( Select("TCB8") > 0 )
	TCB8->(DbCloseArea())
Endif

Return( lContinua )

/*/{Protheus.doc} ChkSdc
//Funcao para validar processo na SDC
@author dfern
@since 30/06/2020
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function ChkSdc()

Local lRet := .F.

//Verificar se o item tem empenho na SDC
_cQrySdc := " SELECT DC_PRODUTO, DC_LOCAL,  SUM(DC_QUANT) AS DC_QUANT, DC_LOTECTL "
_cQrySdc += " FROM "+RetSqlName("SDC")+" "
_cQrySdc += " WHERE DC_ORIGEM = 'SC2' "
_cQrySdc += " AND DC_OP  = '"+SD4->D4_OP+"' "
_cQrySdc += " AND DC_PRODUTO = '"+SD4->D4_COD+"' "
_cQrySdc += " AND DC_LOTECTL = '"+SD4->D4_LOTECTL+"' "
_cQrySdc += " GROUP BY DC_PRODUTO, DC_LOCAL,  DC_QUANT, DC_LOTECTL, DC_QTDORIG " 

If ( Select("TSDC") > 0 )
	TSDC->(DbCloseArea())
Endif

TcQuery _cQrySdc New Alias "TSDC"

If TSDC->(!Eof())
	lRet := .T.
EndIf

Return( lRet )


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ DDTETO   ºAutor  ³ Anderson Messias   º Data ³  08/05/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funcao responsavel por arredondar para cima e de x em x    º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Delta Decisao                                              º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function DDTETO(nValor,nFator)

	Local nValorD := 0
	Local nRet    := 0
	Local nValorI := 0

	DEFAULT nFator := 1

	nValorD := nValor / iif(nFator==0,1,nFator)
	nValorI := Int(nValorD)
	if nValorD > nValorI
		nValorI := nValorI+1
	endif

	nRet := nValorI*iif(nFator==0,1,nFator)

Return nRet

User Function DDTESTE()

	u_DPTRAN01('042846')

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ SHOWF4   ³ Autor ³ Cesar Eduardo Valadao ³ Data ³25/11/1999³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Chamada da funcao F4LOTE                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATA380                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ShowF4(a,b,c)
/*
If ReadVar() == "M->DC_LOCALIZ"
	F4Localiz(,,,   "A380", SD4->D4_COD, SD4->D4_LOCAL,, ReadVar())
ElseIf ReadVar() == "M->D4_NUMLOTE" .Or. ReadVar() == "M->D4_LOTECTL"
	F4Lote(,,,   "A380",M->D4_COD,M->D4_LOCAL)
ElseIf ReadVar() == "M->D4_COD"
	MaViewSB2(M->D4_COD)
EndIf
*/
MaViewSB2(a_Vet[o_Lbx:nAt,7])

Return Nil
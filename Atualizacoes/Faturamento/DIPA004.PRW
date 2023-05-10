/*====================================================================================\
|Programa  | DIPA004       | Autor | Alexandro Dias             | Data | 24/08/2001   |
|=====================================================================================|
|Descri็ใo | Demonstrativo do Saldo em Estoque para o modulo de Fatur.                |
|          |                                                                          |
|          |                                                                          |
|=====================================================================================|
|Sintaxe   | DIPA004                                                                  |
|=====================================================================================|
|Uso       | Especifico DIPROMED                                                      |
|=====================================================================================|
|........................................Hist๓rico....................................|
|Rafael    | 24/02/05 - Ajustes no posicionamento do registro desejado, no qual nใo   |
|          | era possํvel posicionar qdo o c๓d. do produto era composto por letras,   |
|          | por isso na linha 73 foi modificada a forma de posicionamento.           |
+-------------------------------------------------------------------------------------+
|Maximo    | 30/09/08 - Incluํdo Custo Dipromed nas ๚ltimas entradas(SD1->D1_CUSDIP)  | 
+-------------------------------------------------------------------------------------+ 
|Maximo    | 29/10/08 - Alterado UPRC nas ultimas entradas                            | 
+-------------------------------------------------------------------------------------+
|Eriberto  | DD/MM/AA - Descri็ใo                                                     |
\====================================================================================*/


#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"                                                            
#INCLUDE "TCBROWSE.CH"
#INCLUDE "COLORS.CH"
#DEFINE TELEMARKETING 1 // JBS 03/11/2005
#DEFINE TELEVENDAS    2 // JBS 03/11/2005
#DEFINE TELECOBRANCA  3 // JBS 03/11/2005
//------------------------------------------------------------
// Pedido de Compras 
//------------------------------------------------------------
#DEFINE VALMERC  	 1  // Valor total do mercadoria
#DEFINE VALDESC 	 2  // Valor total do desconto
#DEFINE FRETE   	 3  // Valor total do Frete
#DEFINE VALDESP 	 4  // Valor total da despesa
#DEFINE TOTF1		 5  // Total de Despesas Folder 1
#DEFINE TOTPED		 6  // Total do Pedido
#DEFINE SEGURO		 7  // Valor total do seguro
#DEFINE TOTF3		 8  // Total utilizado no Folder 3
#DEFINE IMPOSTOS    9  // Array contendo Os Valores de Impostos Exibidos no ListBox
#DEFINE NTRIB		 10 // Valor das despesas nao tributadas - Portugal
#DEFINE TARA        11 // Valor da Tara - Portugal

#DEFINE MAXGETDAD 999

User Function DIPA004(_cOrigem,_lBotao)

Local _oProgram
Local _oUltimasEnt
Local _oMediaConsu
Local _aUltimasEnt  := {}
Local _aMediaConsu  := {}
Local _aProgramacao := {}
Local _nStok        := 0
Local _nQtdPorg     := 0
Local _nEstoqAtual  := 0
Local _nList        := 1
Local _nListProg    := 1
Local _lSaida       := .F.
Local _xAlias       := GetArea()
Local _xSA1Aias     := {SA1->(IndexOrd()), SA1->(Recno()) }
Local _cProduto     := ""
Local _cProdAux     := ""
Local _cLocal   	:= "" 
Local _Men_Hab
Local _SldPoder3    := 0   
Local _nQtdCQ		:= 0   
Local _nQtdSI       := 0
Local _nSalPed      := 0
Local _QtdEmp       := 0
Local _SldEcom      := 0

Private _aPedCompras:= {} // JBS - 14/01/2010 - Trocado de Local para Private

Private lRetorno	:= .F.
Private _oDlg 
Private oMemo     
Private oPanel1  
Private _oColuna    

If Type("TRBSB1->B1_COD") <> "U"
	SB1->(dbSetOrder(1))
	If !SB1->(dbSeek(xFilial("SB1")+TRBSB1->B1_COD))
		Return(.T.)
	EndIf
EndIf              

U_DIPPROC(ProcName(0),U_DipUsr()) // JBS 05/10/2005 - Gravando o nome do Programa no SZU

If FunName(0) = "TMKA271" .and. nFolder <> TELEVENDAS // JBS 03/11/2005
	Return(.T.)
EndIf

IF FunName(0) != "MATA010"  //FunName(0) != "#MATA010"
	IF _cOrigem == "SALDO"
		_cProduto := SC9->C9_PRODUTO
		_cLocal   := SC9->C9_LOCAL
	ElseIF _cOrigem == "SLDTMP"
		_cProduto := TRB->RB_PRODUTO
		_cLocal   := TRB->RB_LOCAL
	ElseIF _cOrigem == "TMP"
		lRetorno := &(ReadVar())
		_cProduto := TMP1->CK_PRODUTO
		_cLocal   := TMP1->CK_LOCAL
  	ElseIF "DIPAL10" $ FunName() // MCVN - 06/06/2007     
 		_cProduto := M->UA4_PRODUT
  		_cLocal   := "01"    
  	ElseIf _cOrigem == "APROVACAO"     
  		_cProduto := SB1->B1_COD
		_cLocal   := SB1->B1_LOCPAD
	Else
		_cProduto := aCols[n][aScan(aHeader,{|x| Alltrim(x[2])== IIF("TMK"$FunName(),"UB_PRODUTO","C6_PRODUTO") })]
		_cLocal   := aCols[n][aScan(aHeader,{|x| Alltrim(x[2])== IIF("TMK"$FunName(),"UB_LOCAL","C6_LOCAL") })]
	EndIF
Else
	_cProduto := SB1->B1_COD
	_cLocal   := SB1->B1_LOCPAD
EndIF
            
// Verifica se existe Saldo em poder de terceiro (GY-LOG Produtos importados pela Ultraline)
//RBorges - 08/02/2018 - Alterada para trazer o saldo do LOCAL 06.
_SldPoder3 := U_DIP8Poder3(_cProduto)

// Verifica se existe Saldo em poder de terceiro (CBE / QUALITY - ESTERILIZAวรO HQ)

If cEmpAnt == '04'
	If Substr(_cProduto,1,1) == "2" 
	    _cProdAux := _cProduto
		_cProduto := "8"+Substr(_cProduto,2,6) 
   		_nQtdSI := U_SalEsPCP(_cProduto)
   		_cProduto := _cProdAux 
   	Else
   		_nQtdSI := U_SalEsPCP(_cProduto)
	EndIf
//	Else
//		_nQtdSI := U_SalEstHQ(_cProduto)	
 //	EndIf	
 	If Substr(_cProduto,1,1) == "6"
 		_QtdEmp := U_HQEMPSB2(_cProduto)
    EndIf
    
EndIf


DbSelectArea("SB1")
DbSetOrder(1)

If DbSeek(xFilial("SB1")+_cProduto)
	
	_cObs     := MSMM(SB1->B1_CODOBS,TamSx3("B1_OBS")[1])
	_Men_Hab  := SB1->B1_MEN_HAB
	
	/// LOCALIZA O PR๓XIMO C๓DIGO DO PRODUTO
	While SB1->(!EOF()) .and. _cProduto == SB1->B1_COD
		SB1->(DbSkip())
	EndDo
	
	If SB1->(EOF())
		_cProdProc := "ZZZZZZ" // CASO SEJA FIM DE ARQUIVO PEGA O ๚LTIMO REGISTRO
	Else	
		_cProdProc := SB1->B1_COD // CASO NใO SEJA FIM DE ARQUIVO PEGA O PR๓XIMO C๓DIGO
	EndIf

	DbSeek(xFilial("SB1")+_cProduto) //POSICIONA NOVAMENTE NO REGISTRO SELECIONADO

/*	_nTamTotProd  := Len(_cProduto)
	_nTamOriginal := Len(Alltrim(_cProduto))
	_cProdProc    := StrZero( Val(_cProduto)+1,_nTamOriginal)+Space(_nTamTotProd-_nTamOriginal)
*/
	
	IF FunName(0) == "MATA010"  //FunName(0) == "#MATA010"
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณCarrega as Notas Fiscais de Entrada do produto. ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		cSQL := " SELECT "
		cSQL += "	D1_TES, D1_VUNIT, D1_QUANT, D1_EMISSAO, D1_DOC, D1_SERIE, D1_CUSDIP, D1_DTDIGIT, D1_FORNECE "
		cSQL += "	FROM "+RetSQLName("SD1")
		cSQL += "		WHERE "
		cSQL += "			D1_FILIAL = '"+xFilial("SD1")+"' "
		cSQL += "			AND D1_COD = '"+_cProduto+"' "
		cSQL += "           AND D1_TIPO = 'N' "
		cSQL += "			AND D_E_L_E_T_ = ' ' "
     	cSQL += " ORDER BY R_E_C_N_O_ DESC "

		cSQL := ChangeQuery(cSQL)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),"QRYSD1",.T.,.T.)       

		TCSETFIELD("QRYSD1","D1_DTDIGIT","D",8,0)
		TCSETFIELD("QRYSD1","D1_EMISSAO","D",8,0)
				
		While !QRYSD1->(Eof())			
			IF Dp04Check(QRYSD1->D1_TES)
				AAdd( _aUltimasEnt,{ Iif(QRYSD1->D1_FORNECE $ '000996/000997',0,QRYSD1->D1_VUNIT),QRYSD1->D1_QUANT,DTOC(QRYSD1->D1_EMISSAO),QRYSD1->D1_DOC,QRYSD1->D1_SERIE,QRYSD1->D1_CUSDIP,DTOC(QRYSD1->D1_DTDIGIT)} )
				IF Len(_aUltimasEnt) >= 15
					Exit
				EndIF
			EndIF
			QRYSD1->(dbSkip())	
		EndDo
		QRYSD1->(dbCloseArea())
		
		IF Len(_aUltimasEnt) <=0
			AAdd( _aUltimasEnt,{ 0, 0, Ctod(""), "", "",0,Ctod("") } )// Alterado para incluir custo dipromed no array - MCVN 30/09/08 
		EndIF
		
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณConsumo medio dos produtos.                     ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		
		DbSelectArea("SB3")
		DbSetOrder(1)
		
		IF DbSeek(xFilial("SB3")+_cProduto)
			
			_aMeses := {"Janeiro","Fevereiro","Marco","Abril","Maio",;
			"Junho","Julho","Agosto","Setembro","Outubro","Novembro","Dezembro"}
			
			_nAno   := Year(dDataBase)
			
			If month(dDatabase) < 12
				_nAno--
			Endif
			
			_nMes := Month(dDataBase)+1
			IF _nMes = 13
				_nMes := 1
			Endif
			
			FOR nX := 1 TO 12
				IF _aMeses[_nMes] == "Janeiro" .And. nX != 1
					_nAno++
				EndIF
				
				AAdd(_aMediaConsu,{_aMeses[_nMes]+"/"+StrZero(_nAno,4), &("SB3->B3_Q" + StrZero(_nMes,2) ), nX })
				
				_nMes++
				IF _nMes > 12
					_nMes := 1
				EndIF
			Next
			
			AAdd(_aMediaConsu,{"Media dos Ultimos 3 Meses", 0,100})
			
			aSort( _aMediaConsu ,,, {|a,b| a[3] > b[3]} )
			
			For nX := 1 To 5
				If nX>2
					_aMediaConsu[1,2] += _aMediaConsu[nX,2]
				EndIf
			Next
			
			_aMediaConsu[1,2] := _aMediaConsu[1,2] / 3
			
		Else
			AAdd(_aMediaConsu,{ "", 0 })
		EndIF
		
	EndIF
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณCarrega os pedidos de compra do produto. ณ
	//ณAlterado para query  - MCVN 11/02/11 ณ	
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If cEmpAnt == '01'
		QRY2 :=        " SELECT C7_NUM, C7_PRODUTO, SUBSTRING(C7_DENTREG,7,2)+'/'+SUBSTRING(C7_DENTREG,5,2)+'/'+SUBSTRING(C7_DENTREG,1,4) C7_DENTREG, C7_ENCER, C7_RESIDUO, SUBSTRING(C7_EMISSAO,7,2)+'/'+SUBSTRING(C7_EMISSAO,5,2)+'/'+SUBSTRING(C7_EMISSAO,1,4) C7_EMISSAO, C7_ITEM, (C7_QUANT - C7_QUJE) C7_QUANT, 'MATRIZ' EMPRESA "
		QRY2 := QRY2 + " FROM SC7010 "
		QRY2 := QRY2 + " WHERE "
		QRY2 := QRY2 + " SC7010.C7_FILIAL  = '01' and "
		QRY2 := QRY2 + " SC7010.D_E_L_E_T_ <> '*' and " 
		QRY2 := QRY2 + " SC7010.C7_PRODUTO = '"+_cProduto+" ' and "
		QRY2 := QRY2 + " SC7010.C7_ENCER   = '' and "  
		QRY2 := QRY2 + " SC7010.C7_RESIDUO = '' "       

		QRY2 := QRY2 + " UNION "       

		QRY2 := QRY2 + " SELECT C7_NUM, C7_PRODUTO, SUBSTRING(C7_DENTREG,7,2)+'/'+SUBSTRING(C7_DENTREG,5,2)+'/'+SUBSTRING(C7_DENTREG,1,4) C7_DENTREG, C7_ENCER, C7_RESIDUO, SUBSTRING(C7_EMISSAO,7,2)+'/'+SUBSTRING(C7_EMISSAO,5,2)+'/'+SUBSTRING(C7_EMISSAO,1,4) C7_EMISSAO, C7_ITEM, (C7_QUANT - C7_QUJE) C7_QUANT, 'CD' EMPRESA "
		QRY2 := QRY2 + " FROM SC7010 "
		QRY2 := QRY2 + " WHERE "
		QRY2 := QRY2 + " SC7010.C7_FILIAL  = '04' and "
		QRY2 := QRY2 + " SC7010.D_E_L_E_T_ <> '*' and " 
		QRY2 := QRY2 + " SC7010.C7_PRODUTO = '"+_cProduto+ " ' and "
		QRY2 := QRY2 + " SC7010.C7_ENCER   = '' and "  
		QRY2 := QRY2 + " SC7010.C7_RESIDUO = '' "       
		QRY2 := QRY2 + " Order by C7_DENTREG, C7_PRODUTO, C7_NUM "
    Else
		QRY2 := " SELECT C7_NUM, C7_PRODUTO, SUBSTRING(C7_DENTREG,7,2)+'/'+SUBSTRING(C7_DENTREG,5,2)+'/'+SUBSTRING(C7_DENTREG,1,4) C7_DENTREG, C7_ENCER, C7_RESIDUO, SUBSTRING(C7_EMISSAO,7,2)+'/'+SUBSTRING(C7_EMISSAO,5,2)+'/'+SUBSTRING(C7_EMISSAO,1,4) C7_EMISSAO, C7_ITEM, (C7_QUANT - C7_QUJE) C7_QUANT, 'HQ-MATRIZ' EMPRESA "
		QRY2 := QRY2 + " FROM SC7040 "
		QRY2 := QRY2 + " WHERE "
		QRY2 := QRY2 + " SC7040.C7_FILIAL  = '"+xFilial("SC7")+ " ' and "
		QRY2 := QRY2 + " SC7040.D_E_L_E_T_ <> '*' and " 
		QRY2 := QRY2 + " SC7040.C7_PRODUTO = '"+_cProduto+ " ' and "
		QRY2 := QRY2 + " SC7040.C7_ENCER   = '' and "  
		QRY2 := QRY2 + " SC7040.C7_RESIDUO = '' "       
		QRY2 := QRY2 + " Order by C7_DENTREG, C7_PRODUTO, C7_NUM "
   	Endif
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
	TcQuery QRY2 NEW ALIAS "QRY2"         // Abre uma workarea com o resultado da query

	memowrite('DIPA004.SQL',QRY2)

	DbSelectArea("QRY2")
   	QRY2->(dbGotop())	

	Do While QRY2->(!Eof()) 
		
    	If Alltrim(_cProduto) == Alltrim(QRY2->C7_PRODUTO)
	    		       
			IF Empty(QRY2->C7_ENCER) .AND. Empty(QRY2->C7_RESIDUO)
				AAdd( _aPedCompras,{ QRY2->C7_QUANT , QRY2->C7_DENTREG, QRY2->C7_EMISSAO, QRY2->C7_NUM, QRY2->C7_ITEM, QRY2->C7_PRODUTO, QRY2->EMPRESA } )
				IF Len(_aPedCompras) >= 15
					Exit
				EndIF
			EndIF
	    
	    Endif
	    
	QRY2->(DbSkip()) 	
			
	EndDo
	
	
	QRY2->(dbCloseArea())
	IF Len(_aPedCompras) <=0
		AAdd( _aPedCompras,{ 0, Ctod(""),Ctod(""),"","","",""} )
	EndIF
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณCarrega as programacoes de venda do produto. ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	DbSelectArea("SCK")
	DbSetOrder(3)
	DbSeek(xFilial("SCK")+_cProdProc,.T.)
	SCK->(DbSkip(-1))
	
/*	IF Eof()
		DbSkip(-1)
	EndIF
	
	IF SCK->CK_PRODUTO >= _cProdProc
		DbSkip(-1)
	EndIF*/
	
	While !Bof() .and. SCK->CK_PRODUTO == _cProduto
		
		IF Empty(SCK->CK_NUMPV)
			
			SCJ->(DbSetorder(1))
			IF SCJ->(DbSeek(xFilial("SCJ")+SCK->CK_NUM))
				
				IF SCJ->CJ_OPCAO == "P"
					
					SA1->(DbSetOrder(1))
					SA1->(DbSeek(xFilial("SA1")+SCK->CK_CLIENTE+SCK->CK_LOJA))
					
					AAdd( _aProgramacao,{ SCK->CK_QTDVEN, SCK->CK_ENTREG, SA1->A1_COD+"-"+SA1->A1_NOME } )
					
					_nQtdPorg := _nQtdPorg + SCK->CK_QTDVEN
					IF Len(_aProgramacao) >= 50  //MCVN - 29/05/2008 (O PADRรO ESTAVA COMO 15)
						Exit
					EndIF
					
				EndIF
				
			EndIF
			
		EndIF
		
		DbSelectArea("SCK")
		
		DbSkip(-1)
		
	EndDo
	
	IF Len(_aProgramacao) <=0
		AAdd( _aProgramacao,{ 0, Ctod(""), "" } )
	EndIF
	
	DbSelectArea("SA1")
	DbSetOrder(_xSA1Aias[1])
	DbGoto(_xSA1Aias[2])
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณVerifica estoque do produto.             ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	
	DbSelectArea("SB2")
	DbSetOrder(1)                      
	If cEmpAnt == '04'
		DbSeek(xFilial("SB2")+_cProduto)
	Else
		DbSeek(xFilial("SB2")+_cProduto+_cLocal)	
	EndIf	
	Do While !Eof() .and. SB2->B2_COD == _cProduto .And. SB2->B2_LOCAL $ '01/02/03/04/05/06/07/08/09/10/11/12/13/14/15/20' 
	   
		If cEmpAnt == '04' //RBorges 06/04/17            
	
			If     SB1->B1_TIPO == 'PA' .And. SB2->B2_LOCAL $ "01/02"          
				_nStok := _nStok + SaldoSb2() //(SB2->B2_QATU - SB2->B2_RESERVA - SB2->B2_QACLASS)
				_nEstoqAtual := _nEstoqAtual + SB2->B2_QATU
				_nSalPed := _nSalPed + SB2->B2_SALPEDI
			ElseIf SB1->B1_TIPO == 'MP' .And. SB2->B2_LOCAL $ "01"                         
				_nStok := _nStok + SaldoSb2() //(SB2->B2_QATU - SB2->B2_RESERVA - SB2->B2_QACLASS)
				_nEstoqAtual := _nEstoqAtual + SB2->B2_QATU		
				_nSalPed := _nSalPed + SB2->B2_SALPEDI			
			ElseIf SB1->B1_TIPO == 'BN' .And. SB2->B2_LOCAL $ "06"                              
				_nStok := _nStok + SaldoSb2() //(SB2->B2_QATU - SB2->B2_RESERVA - SB2->B2_QACLASS)
				_nEstoqAtual := _nEstoqAtual + SB2->B2_QATU		
				_nSalPed := _nSalPed + SB2->B2_SALPEDI			
			ElseIf SB1->B1_TIPO == 'PI' .And. SB2->B2_LOCAL $ "04"          
				_nStok := _nStok + SaldoSb2() //(SB2->B2_QATU - SB2->B2_RESERVA - SB2->B2_QACLASS)
				_nEstoqAtual := _nEstoqAtual + SB2->B2_QATU		
				_nSalPed := _nSalPed + SB2->B2_SALPEDI			
			EndIf
			SB2->(DbSkip())
	
		Else
	    
			IF SB2->B2_LOCAL $ "01/02"
				_nStok := _nStok + SaldoSb2() //(SB2->B2_QATU - SB2->B2_RESERVA - SB2->B2_QACLASS)
				_nEstoqAtual := _nEstoqAtual + SB2->B2_QATU
				_nSalPed := _nSalPed + SB2->B2_SALPEDI
			ElseIf SB2->B2_LOCAL $ "20"
				_SldEcom := _SldEcom + SaldoSb2()  				
			EndIF

			SB2->(DbSkip())
			
		EndIf

	EnDdo

	DbSeek(xFilial("SB2")+_cProduto+_cLocal)
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Mostra dados do Produto.					                       ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	IF FunName(0) == "MATA010" .AND. (cModulo == 'COM' .OR. UPPER(U_DipUsr()) $ 'EPONTOLDIO/LMARTINS/PMENDONCA/BRODRIGUES/RBEAZIN')
		@ 010,180 To 482,1070 Dialog _oDlg Title OemToAnsi("Caracteristicas do produto.")
	Else
		@ 010,180 To 500,770 Dialog _oDlg Title OemToAnsi("Caracteristicas do produto.")
	EndIF
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณDados das caracteristicas do produto                 ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	@ 001,002 To 038,295
	@ 003,004 SAY OemToAnsi("  Dados do Produto ") SIZE 047,007 
	@ 014,004 SAY OemToAnsi("Codigo") 		 	  SIZE 021,007
	@ 014,040 SAY SB1->B1_COD 					  SIZE 050,008 COLOR CLR_BLUE
	
	@ 014,080 SAY OemToAnsi("Unidade") 			SIZE 020,007
	@ 014,102 SAY SB1->B1_UM 					SIZE 010,008 COLOR CLR_BLUE
	
	@ 014,115 SAY OemToAnsi("Grupo") 			SIZE 018,007
	@ 014,135 SAY SB1->B1_GRUPO 				SIZE 040,008 COLOR CLR_BLUE

	If cEmpAnt=="01"
		IF FunName(0) == "MATA010" .AND. (cModulo == 'COM' .OR. UPPER(U_DipUsr()) $ 'EPONTOLDIO/LMARTINS/PMENDONCA/RBEAZIN')
			@ 006,200 SAY OemToAnsi("Qtd. Embalagem") 				SIZE  070,007
			@ 006,240 SAY Transform(SB1->B1_XQE,"@E 999,999.999") 	SIZE  035,007 COLOR CLR_BLUE
		EndIf
	
		@ 014,200 SAY OemToAnsi("Cx. Embarque") 			 		SIZE  070,007
		@ 014,240 SAY Transform(SB1->B1_XQTDEMB,"@E 999,999.999") 	SIZE  035,007 COLOR CLR_BLUE
	Else
		@ 014,200 SAY OemToAnsi("Qtd. Embalagem") 			 		SIZE  070,007
		@ 014,240 SAY Transform(SB1->B1_XQE,"@E 999,999.999") 		SIZE  035,007 COLOR CLR_BLUE
	EndIf	
	
	@ 022,004  SAY OemToAnsi("Descricao") 	SIZE  032,007
	@ 022,040  SAY SB1->B1_DESC 			SIZE 160,007 COLOR CLR_BLUE
	
	@ 022,200 SAY OemToAnsi("Peso Liquido") 				SIZE  060,007
	@ 022,240 SAY Transform(SB1->B1_PESO,"@E 999,999.999") 	SIZE  035,007 COLOR CLR_BLUE
	
	@ 030,004 SAY OemToAnsi("Reg. Anvisa") 	SIZE  032,007
	@ 030,040 SAY SB1->B1_REG_ANV 	     	SIZE 160,007 COLOR CLR_BLUE
	If (AllTrim(SB1->B1_RANVISA) == "III" .Or. AllTrim(SB1->B1_RANVISA) == "IV")
		@ 030,200 SAY OemToAnsi("Data Validade") 		                                                                                	SIZE  060,007
		@ 030,240 SAY SubStr(DtoS(SB1->B1_DTV_ANV),7,2) + "/" + SubStr(DtoS(SB1->B1_DTV_ANV),5,2) + "/" + SubStr(DtoS(SB1->B1_DTV_ANV),1,4) SIZE  035,007 COLOR CLR_BLUE
	ElseIf (AllTrim(SB1->B1_RANVISA) == "I" .Or. AllTrim(SB1->B1_RANVISA) == "II")
 		@ 030,200 SAY OemToAnsi("Venc.Registro") 		                                                                                	SIZE  060,007
		@ 030,240 SAY SB1->B1_XVENREG  SIZE  035,007 COLOR CLR_BLUE
	Else
		@ 030,200 SAY OemToAnsi("Data Validade") 		                                                                                	SIZE  060,007
		@ 030,240 SAY SubStr(DtoS(SB1->B1_DTV_ANV),7,2) + "/" + SubStr(DtoS(SB1->B1_DTV_ANV),5,2) + "/" + SubStr(DtoS(SB1->B1_DTV_ANV),1,4) SIZE  035,007 COLOR CLR_BLUE	
	EndIf
	   
	
	IF FunName(0) == "MATA010" .AND. (cModulo == 'COM' .OR. UPPER(U_DipUsr()) $ 'EPONTOLDIO/LMARTINS/PMENDONCA/RBEAZIN')
		//IF FunName(0) == "#MATA010" .AND. cModulo == 'COM'
		
		@ 002,297 To 112,445
		
		@ 003,300 SAY OemToAnsi(" Ultimas Entradas") Size 046,007
		
		_oUltimasEnt := TCBROWSE():New(014,300,140,097,,,,_oDlg,,,,,{||(_lSaida:=.T.,;
		_nList:=_oUltimasEnt:nAt,Close(_oDlg))},,,,,,,.F.,,.T.,,.F.,,)
		
		_oUltimasEnt:SetArray(_aUltimasEnt)
		
		ADD COLUMN TO _oUltimasEnt HEADER "Custo Dipro" OEM DATA {|| TransForm(_aUltimasEnt[_oUltimasEnt:nAt,06],"@E 999,999.9999") } SIZE 030 PIXEL // Custo Dipromed - MCVN  30/09/08 
		ADD COLUMN TO _oUltimasEnt HEADER "Ult. Preco"  OEM DATA {|| TransForm(_aUltimasEnt[_oUltimasEnt:nAt,01],"@E 999,999.9999") } SIZE 030 PIXEL
		ADD COLUMN TO _oUltimasEnt HEADER "Quantidade"  OEM DATA {|| TransForm(_aUltimasEnt[_oUltimasEnt:nAt,02],"@E 99,999,999") }   SIZE 035 PIXEL
		ADD COLUMN TO _oUltimasEnt HEADER "Dt. Entrada" OEM DATA {|| _aUltimasEnt[_oUltimasEnt:nAt,07] } SIZE 035 PIXEL
		ADD COLUMN TO _oUltimasEnt HEADER "Nt Fiscal"   OEM DATA {|| _aUltimasEnt[_oUltimasEnt:nAt,04] } SIZE 035 PIXEL
		ADD COLUMN TO _oUltimasEnt HEADER "Dt. Emissao" OEM DATA {|| _aUltimasEnt[_oUltimasEnt:nAt,03] } SIZE 035 PIXEL
		ADD COLUMN TO _oUltimasEnt HEADER "Serie"       OEM DATA {|| _aUltimasEnt[_oUltimasEnt:nAt,05] } SIZE 035 PIXEL                             
		
		
		@ 113,297 To 220,445
		
		@ 114,300 SAY OemToAnsi(" Media de Consumo") Size 048,007
		
		_oMediaConsu := TCBROWSE():New(122,300,140,097,,,,_oDlg,,,,,{||(_lSaida:=.T.,;
		_nList:=_oMediaConsu:nAt,Close(_oDlg))},,,,,,,.F.,,.T.,,.F.,,)
		
		_oMediaConsu:SetArray(_aMediaConsu)
		
		ADD COLUMN TO _oMediaConsu HEADER "Meses/Ano"   OEM DATA {|| _aMediaConsu[_oMediaConsu:nAt,01] } SIZE 070 PIXEL
		ADD COLUMN TO _oMediaConsu HEADER "Consumo"     OEM DATA {|| TransForm(_aMediaConsu[_oMediaConsu:nAt,02],"@E 99,999,999") } SIZE 035 PIXEL
		
	EndIF
	
	_nQtdCQ := u_DipSomaCQ(SB1->B1_COD,SB1->B1_PROC,SB1->B1_LOJPROC,.F.)                               
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณMostra saldo em estoque do produto                   ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	@ 039,002 To 095,157
	@ 040,004 SAY OemToAnsi("  Estoque") Size 026,007 
	
	@ 048,004 SAY OemToAnsi("CQ ")								SIZE 040,007
	@ 048,038 SAY Transform(_nQtdCQ   ,"@E 99,999,999") 	    SIZE 040,007 COLOR CLR_GREEN  
 	If cEmpAnt	== '04'       
		@ 048,070 SAY OemToAnsi("Sld p/ Industrial")     	    SIZE 040, 007
		@ 048,123 SAY Transform(_nQtdSI,"@E 99,999,999") 	  	SIZE 040, 007 COLOR CLR_GREEN	
	EndIf	
	If cEmpAnt == "01"
		@ 055,004 SAY OemToAnsi("Saldo Arm.06")						SIZE 040,007
		@ 055,038 SAY Transform(_SldPoder3,"@E 99,999,999") 	    SIZE 040,007 COLOR CLR_GREEN
	Else
		@ 055,004 SAY OemToAnsi("Saldo Arm.07")						SIZE 040,007
		@ 055,038 SAY Transform(_SldPoder3,"@E 99,999,999") 	    SIZE 040,007 COLOR CLR_GREEN
	EndIf
	
	If cEmpAnt <> "04"
		@ 062,004 SAY OemToAnsi("Saldo Arm.20")						SIZE 040,007
		@ 062,038 SAY Transform(_SldEcom,"@E 99,999,999") 	        SIZE 040,007 COLOR CLR_GREEN
	EndIf
	
	@ 069,004 SAY OemToAnsi("Saldo") 							SIZE 040,007 COLOR CLR_HRED
	@ 069,038 SAY Transform(SB2->B2_QPEDVEN,"@E 99,999,999") 	SIZE 040,007 COLOR CLR_HRED
	
	@ 076,004 SAY OemToAnsi("a Entrar") 						SIZE 040, 007
	@ 076,038 SAY Transform(_nSalPed,"@E 99,999,999") 	SIZE 040, 007 COLOR CLR_BLUE
	
	@ 083,004 SAY OemToAnsi("Est.Atual(A)") 					SIZE 040,007
	
	If cEmpAnt == '04' .And. Substr(_cProduto,1,1) == "6"
		@ 090,004 SAY OemToAnsi("Empenhado") 					SIZE 040,007
		@ 090,038 SAY Transform(_QtdEmp,"@E 99,999,999")  	SIZE 040,007 COLOR CLR_GREEN		
	EndIf
		
	IF _nEstoqAtual > 0
		@ 083,038 SAY Transform(_nEstoqAtual,"@E 99,999,999")  	SIZE 040,007 COLOR CLR_BLUE
	Else
		@ 083,038 SAY Transform(_nEstoqAtual,"@E 99,999,999")  	SIZE 040,007 COLOR CLR_HRED
	EndIF 
	
	@ 055,070 SAY OemToAnsi("a Enderecar(B)") 					SIZE 040,007
	@ 055,123 SAY Transform(SB2->B2_QACLASS,"@E 99,999,999") 	SIZE 030,007 COLOR CLR_BLUE
	
	@ 062,070 SAY OemToAnsi("Reservado(C)") 					SIZE  040,007
	@ 062,123 SAY Transform(SB2->B2_RESERVA,"@E 99,999,999") 	SIZE 030,007 COLOR CLR_BLUE
	
	@ 069,070 SAY OemToAnsi("Programacao(D)") 					SIZE  050,007
	@ 069,123 SAY Transform(_nQtdPorg,"@E 99,999,999")  		SIZE 030,007 COLOR CLR_BLUE
	
	@ 076,070 SAY OemToAnsi("Disponivel(A-(B+C+D))")			SIZE  060,007
	@ 076,123 SAY Transform((_nStok-_nQtdPorg),"@E 99,999,999") SIZE 030,007 COLOR CLR_BLUE
	
	IF FunName(0) == "MATA010" .AND. (cModulo == 'COM' .OR. UPPER(U_DipUsr()) $ 'EELIAS/EPONTOLDIO/LMARTINS/PMENDONCA')
	    If  U_DIP8Amostra() // JBS 25/07/2005
		    @ 222,350 Button "&Amostras"   size 40,14   action (U_MYSALDOSB2('04',"M->C6_PRODUTO"),Close(_oDlg)) // JBS 14/02/2006
		EndIf    
		@ 222,400 Button "&OK"   size 40,14  action (_oDlg:End())
	Else
	    If  U_DIP8Amostra() // JBS 25/07/2005
		    @ 222,200 Button "&Amostras"   size 40,14   action (U_MYSALDOSB2('04',"M->C6_PRODUTO"),Close(_oDlg)) // JBS 14/02/2006
		EndIf                                                                  
		@ 222,250 Button "&OK"   size 40,14  action (_oDlg:End())
	EndIF
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณMostra as observaao sobre o produto B1_OBS         ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	@ 039,160 TO 220, 295                 // JBS 13/10/2005
	@ 040,164 SAY OemToAnsi(" Observacoes:") Size 066,007
	@ 047,164 GET _cObs Size 127,130 MEMO WHEN .F.// JBS 13/10/2005
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณMostra mensagem sobre o produto B1_MEN_HAB         ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If !Empty(_Men_Hab)
		@ 180,164 SAY OemToAnsi(" MENSAGEM HABILITADO:") Size 066,007 COLOR CLR_BLUE
	    @ 187,164 SAY Substr(_Men_Hab,1,45)   Size 130,8 COLOR CLR_HRED
    	@ 195,164 SAY Substr(_Men_Hab,46,45)  Size 130,8 COLOR CLR_HRED
	    @ 203,164 SAY Substr(_Men_Hab,92,45)  Size 130,8 COLOR CLR_HRED
	    @ 211,164 SAY Substr(_Men_Hab,138,45) Size 130,8 COLOR CLR_HRED
	Endif   
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณMostra os pedidos de compra do produto. ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู 
	@ 100,002 To 162,157
	@ 101,004 SAY OemToAnsi("  Pedido de Compra") Size 048,007  

	_oColuna := TCBROWSE():New(108,004,150,050,,,,_oDlg,,,,,{||(_lSaida:=.T.,;
	_nList:=_oColuna:nAt)},,,,,,,.F.,,.T.,,.F.,,) // JBS 14/01/2010 - Removido do Cod.Block o fechamento do objeto
	
	_oColuna:SetArray(_aPedCompras)
	_oColuna:blDblClick := {|| U_fPedCompra(_oColuna:nAt,_aPedCompras[_oColuna:nAt,07])}
	
	ADD COLUMN TO _oColuna HEADER "Quantidade"         OEM DATA {|| TransForm(_aPedCompras[_oColuna:nAt,01],"@E 99,999,999") } SIZE 035 PIXEL
	ADD COLUMN TO _oColuna HEADER "Previsao Entrega"   OEM DATA {|| _aPedCompras[_oColuna:nAt,02] } SIZE 045 PIXEL
	ADD COLUMN TO _oColuna HEADER "Solitacao"          OEM DATA {|| _aPedCompras[_oColuna:nAt,03] } SIZE 030 PIXEL
	ADD COLUMN TO _oColuna HEADER "Empresa"            OEM DATA {|| _aPedCompras[_oColuna:nAt,07] } SIZE 010 PIXEL
	
	@ 163,002 To 220,157                                  
	@ 164,004 SAY OemToAnsi("  Programa็ใo") Size 035,007 
		
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณMostra as programacoes do produto.      ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	_oProgram := TCBROWSE():New(171,004,150,046,,,,_oDlg,,,,,{||(_lSaida:=.T.,;
	_nListProg:=_oProgram:nAt,Close(_oDlg))},,,,,,,.F.,,.T.,,.F.,,)
	
	_oProgram:SetArray(_aProgramacao)
	
	ADD COLUMN TO _oProgram HEADER "Quantidade"         OEM DATA {|| TransForm(_aProgramacao[_oProgram:nAt,01],"@E 99,999,999") } SIZE 035 PIXEL
	ADD COLUMN TO _oProgram HEADER "Previsao Entrega"   OEM DATA {|| _aProgramacao[_oProgram:nAt,02] } SIZE 045 PIXEL
	ADD COLUMN TO _oProgram HEADER "Cliente"            OEM DATA {|| _aProgramacao[_oProgram:nAt,03] } SIZE 040 PIXEL
	
	/* Eriberto 15/09/2004
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณCarrega a imagem do produto                         ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	IF FunName(0) != "#MATA010"
		@ 110,158 REPOSITORY _oBitPro OF _oDlg SIZE 135,110 Pixel
	Else
		@ 110,158 REPOSITORY _oBitPro OF _oDlg SIZE 135,120 Pixel
	EndIF
	Showbitmap(_oBitPro,IIF(!Empty(SB1->B1_BITMAP),SB1->B1_BITMAP,"LOJAWIN"),"")
	_oBitPro:lStretch:=.T.
	_oBitPro:Refresh(.T.)
	
	@ 105,164 SAY OemToAnsi(" Foto") Size 014,007
	
	*/
	ACTIVATE MSDIALOG _oDlg CENTER
	
Else
	HELP(" ",1, IIF("TMK"$FunName(),"UB_PRODUTO","C6_PRODUTO"))
EndIf

RestArea(_xAlias)

Return(lRetorno)

/*
Saldo atual
*/
User Function SALDOATUAL()

Local _nStok := 0          
                                                 			
SB2->(DbSetOrder(1))
If SB2->(DbSeek(xFilial("SB2")+SB1->B1_COD+If(SB1->B1_TIPO == 'MC',SB1->B1_LOCPAD,'01'))) //MCVN - TRATAMENTO PARA UTILIZAR O  LOCAL PADRรO QUANDO FOR MATERIAL DE CONSUMO 31-05-11   // ERIBERTO EM 19/07/2005 COLOQUEI O LOCAL "01" MOSTRO SO SALDO QUE PODEMOS VENDER
   //While !Eof() .and. SB2->B2_COD == SB1->B1_COD .AND. SB2->B2_LOCAL == "01"
	_nStok := _nStok + SaldoSb2() //(SB2->B2_QATU - SB2->B2_RESERVA - SB2->B2_QACLASS)
	//_nEstoqAtual := _nEstoqAtual + SB2->B2_QATU
   //	DbSkip()
EnDIf

Return(_nStok)
*-----------------------------------------------*
Static Function Dp04Check(cTes)                                 
*-----------------------------------------------*
Local lRet	:= .F.

SF4->(dbSetOrder(1))
SF4->(dbseek(xFilial('SF4')+cTes))    

lRet :=  (SF4->F4_ESTOQUE == 'S')

If lRet
	If cEmpAnt+cFilAnt = '0101'
		lRet := !(SF4->F4_CODIGO$('131/135/263'))
	ElseIf cEmpAnt+cFilAnt = '0104'
		lRet := !(SF4->F4_CODIGO$('179/255/038'))
	EndIf
EndIf
	
Return(lRet)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณfPedCompraบAutor  ณJailton B Santos-JBSบ Data ณ 14/01/2010  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRotina chamada quando o usuario faz um duplo clique na linhaบฑฑ
ฑฑบ          ณda janela de pedidos de compra.                             บฑฑ
ฑฑบ          ณTem como objetivo trazer pedido para que o usuario altere   บฑฑ
ฑฑบ          ณalguns campos.                                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณCompras - Dipromed.                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User function fPedCompra(nAt,cEmpresa)
Local nOpcA     := 0
Local lRet      := .T. 
Local cSeek     := ""
Local cWhile    := ""
Local cAlias    := "SC7"
Local nStyle    := GD_UPDATE  //Apenas alterar a linha no getdados
Local bOk       := {|| If(U_DPA004TudOk(),(fSalva(),nOpcA := 1, oDlg:End()),)}
Local bCancel   := {|| nOpcA := 2, oDlg:End()}
Local cCadastro := "Alterando Pedido de Compras" 
Local nOpc      := 4
//---------------------------------------------------------------------------
Private aHeader := {}
Private aCols   := {}
Private nRecno  := 0 
Private aSize   := MsAdvSize()
Private aInfo   := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 5, 5 }
Private aObjects:= { { 100, 100, .T., .T. } , { 200, 200, .T., .T. } }
Private aPosObj := MsObjSize( aInfo, aObjects,.T.)
//---------------------------------------------------------------------------
Private oGetDados
Private oGetD
Private aTELA[0][0]
Private aGETS[0]
Private aCposNao := {} 
Private cDescMoed:= SuperGetMv("MV_MOEDA"+AllTrim(Str(SC7->C7_MOEDA,2)))


//--------------------------------------------------------------------------- 
//  Valida a empresa para alterar pedido de compra - MCVN 12/02/11
//--------------------------------------------------------------------------- 
If (cEmpresa = "MATRIZ" .And. cEmpAnt+cFilAnt == '0104') .Or. (cEmpresa = "CD" .And. cEmpAnt+cFilAnt == '0101')
   Aviso('Aten็ใo','Entre na Dipromed '+If(cEmpresa = "MATRIZ" .And.  cEmpAnt+cFilAnt == '0104'," MATRIZ "," CD ")+' para realizar ajustes neste pedido de compras!',{'Ok'})
   lRet := .F.
   Return(lRet)
EndIf

//--------------------------------------------------------------------------- 
//  Valida se o usuario eh um comprador
//--------------------------------------------------------------------------- 
SY1->(DbSetOrder(3))
SY1->(DbGoTop())
                     
If !SY1->(DbSeek(xFilial("SY1") + __cUserId ))
   Aviso('Aten็ใo','Apenas compradores podem realizar ajustes no pedido de compras!',{'Ok'})
   lRet := .F.
   Return(lRet)
EndIf

//--------------------------------------------------------------------------- 
//  Questiona o usuario se relamente deseja alterar o pedido, e sai em caso 
//  de o mesmo responder negativamente.
//--------------------------------------------------------------------------- 
If Aviso('Aten็ใo','Deseja alterar o pedido de Compras ' + _aPedCompras[nAt][4]+ ' ?',{'Sim','Nใo'}) <> 1  
   Return(lRet)
EndIf
//--------------------------------------------------------------
// Campos da tabela SC7 que nao devem ser mostrados na GetDados
//--------------------------------------------------------------
aAdd(aCposNao,"C7_NUM")
aAdd(aCposNao,"C7_EMISSAO")
aAdd(aCposNao,"C7_FORNECE")
aAdd(aCposNao,"C7_NOMEFOR")
aAdd(aCposNao,"C7_LOJA")
aAdd(aCposNao,"C7_COND")
aAdd(aCposNao,"C7_CONTATO")
aAdd(aCposNao,"C7_FILENT")
aAdd(aCposNao,"C7_MOEDA")
aAdd(aCposNao,"C7_TXMOEDA")
aAdd(aCposNao,"C7_IPI")
aAdd(aCposNao,"C7_VALIPI")
aAdd(aCposNao,"C7_VALICM")
aAdd(aCposNao,"C7_PICM")
aAdd(aCposNao,"C7_NUMSC")
aAdd(aCposNao,"C7_ITEMSC")
aAdd(aCposNao,"C7_OBS")
aAdd(aCposNao,"C7_CONTA")
aAdd(aCposNao,"C7_REAJUST")
aAdd(aCposNao,"C7_FRETE")
aAdd(aCposNao,"C7_ITEMCTA")
aAdd(aCposNao,"C7_EMITIDO")
aAdd(aCposNao,"C7_TPFRETE")
aAdd(aCposNao,"C7_QTDREEM")
aAdd(aCposNao,"C7_RESIDUO")
aAdd(aCposNao,"C7_MSG")
aAdd(aCposNao,"C7_CONTROL")
aAdd(aCposNao,"C7_OP")
aAdd(aCposNao,"C7_IPIBRUT")
aAdd(aCposNao,"C7_TEC")
aAdd(aCposNao,"C7_EX_NCM")
aAdd(aCposNao,"C7_EX_NBM")
aAdd(aCposNao,"C7_DT_EMB")
aAdd(aCposNao,"C7_TIPO")
aAdd(aCposNao,"C7_NODIA")
aAdd(aCposNao,"C7_DIACTB")
aAdd(aCposNao,"C7_FABRICA")
aAdd(aCposNao,"C7_LOJFABR")
aAdd(aCposNao,"C7_CON40HC")
aAdd(aCposNao,"C7_CONTA40")
aAdd(aCposNao,"C7_CONTA20")
aAdd(aCposNao,"C7_MT3")
aAdd(aCposNao,"C7_CONTAIN")
aAdd(aCposNao,"C7_LOJAEXP")
aAdd(aCposNao,"C7_EXPORTA")
aAdd(aCposNao,"C7_DESP")
aAdd(aCposNao,"C7_CONF_PE")
aAdd(aCposNao,"C7_CONSIG")
aAdd(aCposNao,"C7_IMPORT")
aAdd(aCposNao,"C7_PESO_B")
aAdd(aCposNao,"C7_ITEMGRD")
aAdd(aCposNao,"C7_GRADE")
aAdd(aCposNao,"C7_CODTAB")
aAdd(aCposNao,"C7_ITEMGRD")
aAdd(aCposNao,"C7_CC")
aAdd(aCposNao,"C7_CLVL")
aAdd(aCposNao,"C7_ICMCOMP")
aAdd(aCposNao,"C7_LOCAL")
aAdd(aCposNao,"C7_VLDESC")
aAdd(aCposNao,"C7_ALIQIR")
aAdd(aCposNao,"C7_APROV")
aAdd(aCposNao,"C7_ARMAZEM")
aAdd(aCposNao,"C7_BASEICM")
aAdd(aCposNao,"C7_BASEIPI")
aAdd(aCposNao,"C7_BASEIR")
aAdd(aCposNao,"C7_BASESOL")
aAdd(aCposNao,"C7_FLUXO")
aAdd(aCposNao,"C7_VALIPI")
aAdd(aCposNao,"C7_VALIPI")
//------------------------------------------------------------
// Define a Montagem do aCols e aHeader
//------------------------------------------------------------
cSeek  := xFilial("SC7")+_aPedCompras[nAt][4]
cWhile := "SC7->C7_FILIAL+SC7->C7_NUM" 
FillGetDados(nOpc,"SC7",1,cSeek,{|| &cWhile },,aCposNao,,,,,,aHeader,aCols,,,,"SC7")
//------------------------------------------------------------
// Posiciona no primeiro Recno do Pedido
//------------------------------------------------------------
SC7->( DbSetOrder(1) ) 
SC7->( DbGoTop() )
SC7->( DbSeek(cSeek) ) 
//------------------------------------------------------------
// Informacoes da Capa do Pedido
//------------------------------------------------------------
M->C7_NUM      := SC7->C7_NUM
M->C7_EMISSAO  := SC7->C7_EMISSAO
M->C7_FORNECE  := SC7->C7_FORNECE 
M->C7_LOJA     := SC7->C7_LOJA
M->C7_COND     := SC7->C7_COND
M->C7_CONTATO  := SC7->C7_CONTATO
M->C7_FILENT   := SC7->C7_FILENT
M->C7_MOEDA    := SC7->C7_MOEDA
M->C7_TXMOEDA  := SC7->C7_TXMOEDA
//------------------------------------------------------------
// Acha a Descricao da Condicao de Pagamento
//------------------------------------------------------------
SE4->( DbSetOrder(1))
SE4->( DbSeek(xFilial('SE4') + M->C7_COND) )
M->E4_DESCRI := SE4->E4_DESCRI
//------------------------------------------------------------
// Limpa a Validacao padrao definida no SX3
//------------------------------------------------------------
//aHeader[ascan(aHeader,{|x| x[2] == 'C7_DENTREG' })][15] := ''

Define MsDialog oDlg from aSize[7],0 to aSize[6]-30,aSize[5]-50 title cCadastro of oMainWnd pixel

@ aPosObj[1][1],aPosObj[1][2] TO aPosObj[1][3]-30,aPosObj[1][4]-22 OF oDlg pixel
@ 020,016 Say "Numero"            OF oDlg pixel size 031,006  
@ 020,154 Say "Data de Emissao"   OF oDlg pixel size 050,006              
@ 020,324 Say "Fornecedor"        OF oDlg pixel size 036,006          
@ 020,421 Say "Loja"              OF oDlg pixel size 019,006	   
@ 032,016 Say "Cond. Pagto"       OF oDlg pixel size 030,006              
@ 032,180 Say "Contato"           OF oDlg pixel size 038,006              
@ 032,361 Say "Filial p/ Entrega" OF oDlg pixel size 050,006 
@ 044,016 Say "Moeda"             OF oDlg pixel size 030,006  
@ 044,180 Say "Taxa da Moeda"     OF oDlg pixel size 030,006

@ 019,064 MsGet M->C7_NUM     when .F. picture PesqPict('SC7','C7_NUM')        OF oDlg pixel size 031,006
@ 019,227 MsGet M->C7_EMISSAO when .F. picture PesqPict('SC7','C7_EMISSAO')    OF oDlg pixel size 042,006 HASBUTTON
@ 019,379 MsGet M->C7_FORNECE when .F. picture PesqPict('SC7','C7_FORNECE')    OF oDlg pixel size 040,006 HASBUTTON
@ 019,434 MsGet M->C7_LOJA    when .F. picture PesqPict('SC7','C7_LOJA')       OF oDlg pixel size 019,006
@ 031,064 MsGet M->C7_COND    when .F. picture PesqPict('SC7','C7_COND')       OF oDlg pixel size 025,006 HASBUTTON
@ 031,227 MsGet M->C7_CONTATO when .F. picture PesqPict('SC7','C7_CONTATO')    OF oDlg pixel size 074,006
@ 031,102 MsGet M->E4_DESCRI  when .F. picture PesqPict('SE4','E4_DESCRI')     OF oDlg pixel size 055,006
@ 031,434 MsGet M->C7_FILENT  when .F. picture PesqPict('SC7','C7_FILENT')     OF oDlg pixel size 019,006 HASBUTTON 
@ 043,064 MsGet M->C7_MOEDA   when .F.                                          OF oDlg pixel size 025,006
@ 043,102 MsGet cDescMoed     when .F.                                          OF oDlg pixel size 055,006
@ 043,227 MsGet M->C7_TXMOEDA when .F. picture PesqPict("SC7","C7_TXMOEDA",11) OF oDlg pixel size 074,006 HASBUTTON

oGetDados:=MsNewGetDados():New(aPosObj[2,1]-32,aPosObj[2,2],aPosObj[2,3]-13,aPosObj[2,4]-22,nStyle,'U_DPA004LinOk','U_DPA004TudOk','+C7_ITEM',{'C7_DENTREG'},/*freeze*/,MAXGETDAD,'U_DPA004FldOk()',/*superdel*/,/*delok*/,oDlg,@aHeader,@aCols)
//------------------------------------------------------------
// Limpa a Validacao padrao definida no SX3
//------------------------------------------------------------
//oGetDados:aHeader[ascan(oGetDados:aHeader,{|x| x[2] == 'C7_DENTREG' })][15] := ''

oGetDados:oBrowse:bAdd    := {|| .F. }      // Nao Permite a inclusao de Linhas
oGetDados:oBrowse:bDelete := {|| .F. }	     // Nao Permite a deletar Linhas
//oGetDados:oBrowse:aAlter  := {'C7_DENTREG'} // Campo Editavel

Activate MsDialog oDlg On Init EnchoiceBar(oDlg,bOk,bCancel) CENTERED
   
Return(lRet)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDPA004LinOkบAutor ณJailton B Santos-JBSบ Data ณ 20/01/2010  บฑฑ
ฑฑฬออออออออออุอออออออออออสออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Valida a Saida da Linha da GetDados                        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Compras - Dipromed                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function DPA004LinOk()

Local lRet := .T. 
Local nPos := Ascan(oGetDados:aHeader,{|x| x[2] == 'C7_DENTREG' })

SC7->( DbGoto(oGetDados:aCols[oGetDados:nAt][len(oGetDados:aHeader)] ))
                               
Do Case
case oGetDados:aCols[oGetDados:nAt][nPos] < SC7->C7_DENTREG ; lRet := .F. ; Aviso('Aten็ใo','Data de Entrega Nใo pode ser alterada para menor.',{'Ok'})
case oGetDados:aCols[oGetDados:nAt][nPos] == SC7->C7_DENTREG; lRet := .T. 
case oGetDados:aCols[oGetDados:nAt][nPos] < dDataBase       ; lRet := .F. ; Aviso('Aten็ใo','Data de Entrega Nใo pode ser Menor que a Data Atual.',{'Ok'})
EndCase

Return(lRet)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDPA004TudOkบAutor ณJailton B Santos-JBSบ Data ณ 20/01/2010  บฑฑ
ฑฑฬออออออออออุอออออออออออสออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Valida a Saida da Tela de alteracao do pedido de compra    บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Compras - Dipromed                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function DPA004TudOk()

Local lRet := .T. 
Local nPos := Ascan(oGetDados:aHeader,{|x| x[2] == 'C7_DENTREG' })

For nId := 1 to Len(oGetDados:aCols)
    
    SC7->( DbGoto(oGetDados:aCols[nId][len(oGetDados:aHeader)] )) 
    Do Case
    case oGetDados:aCols[nId][nPos] < SC7->C7_DENTREG ; lRet := .F. ; Aviso('Aten็ใo','Data de Entrega Nใo pode ser alterada para menor.',{'Ok'}); Exit
    case oGetDados:aCols[nId][nPos] == SC7->C7_DENTREG; lRet := .T. 
    case oGetDados:aCols[nId][nPos] < dDataBase       ; lRet := .F. ; Aviso('Aten็ใo','Data de Entrega Nใo pode ser Menor que a Data Atual.',{'Ok'}) ; Exit
    EndCase 
          
Next nId

return(lRet)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDPA004FldOkบAutor ณJailton B Santos-JBSบ Data ณ 20/01/2010  บฑฑ
ฑฑฬออออออออออุอออออออออออสออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Valida a Saida do Campo                                    บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Compras - Dipromed                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function DPA004FldOk()
Local lRet := .T.
return(lRet)       
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDPA004Del บAutor  ณJailton B Santos-JBSบ Data ณ 20/01/2010  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Valida a Delecao do registro todo.                         บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Compras - Dipromed                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function DPA004Del()
Local lRet := .T.
return(lRet)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณfSalva()  บAutor  ณJailton B Santos-JBSบ Data ณ 21/01/2010  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Salva a alteracao do usuario no cadastro do pedido de com- บฑฑ
ฑฑบ          ณ pra.                                                       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Compras - Dipromed                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static function fSalva()

Local lRet   := .T. 
Local nPos   := Ascan(oGetDados:aHeader,{|x| x[2] == 'C7_DENTREG' })
Local nPosPed:= 0

For nId := 1 to Len(oGetDados:aCols)
    //-----------------------------------------------------------------------
    //  Atualiza a data de Entrega Dipromed no 'SC7'
    //-----------------------------------------------------------------------
    SC7->( DbGoto(oGetDados:aCols[nId][len(oGetDados:aHeader)] )) 
    SC7->( RecLock('SC7',.F.) )
    SC7->C7_DENTREG  := oGetDados:aCols[nId][nPos]
    SC7->( MsUnLock('SC7') ) 
    //-----------------------------------------------------------------------
    //  Atualiza a data de Entrega na Janela de Consulta 'SC7'
    //-----------------------------------------------------------------------
    nPosPed:= Ascan(_aPedCompras,{|x| x[4]+x[5]+x[6] == SC7->C7_NUM + SC7->C7_ITEM + SC7->C7_PRODUTO})
    If nPosPed > 0
        _aPedCompras[nPosPed][2] := oGetDados:aCols[nId][nPos]
        _oColuna:Refresh()
    EndIf
Next nId

Return(.T.) 


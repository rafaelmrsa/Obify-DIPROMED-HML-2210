/*====================================================================================\
|Programa  | DIPA004C       | Autor | Maximo Canuto              | Data | 21/10/2015  |
|=====================================================================================|
|Descrição | Demonstrativo do Saldo em Estoque CONSOLIDADOpara o modulo de Fatur.     |
|          |                                                                          |
|          |                                                                          |
|=====================================================================================|
|Sintaxe   | DIPA004C                                                                  |
|=====================================================================================|
|Uso       | Especifico DIPROMED                                                      |
|=====================================================================================|
|........................................Histórico....................................|
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
#DEFINE IMPOSTOS     9  // Array contendo Os Valores de Impostos Exibidos no ListBox
#DEFINE NTRIB		 10 // Valor das despesas nao tributadas - Portugal
#DEFINE TARA         11 // Valor da Tara - Portugal

#DEFINE MAXGETDAD 999

User Function DIPA004C(_cOrigem,_lBotao)

Local _oProgram
Local _oUltimasEnt
Local _oMediaConsu
Local _aUltimasEnt  := {}
Local _aMediaConsu  := {}
Local _aProgramacao := {}
Local _nQtdPorg     := 0
Local _nList        := 1
Local _nListProg    := 1
Local _lSaida       := .F.
Local _xAlias       := GetArea()
Local _cProduto     := ""  
Local _cProdAux     := ""  
Local _cLocal   	:= "" 
Local _Men_Hab
Local _SldPoder3    := 0   
Local _nQtdCQ		:= 0   
Local _nQtdSI       := 0     
Local lGatilho      := .f.
Local _QtdEmp       := 0
Local _SldArm08     := 0
Local _SldArm09     := 0
Local nX            := 0

Private _aPedCompras  := {} // JBS - 14/01/2010 - Trocado de Local para Private

Private lRetorno	:= .F.
Private _oDlg 
Private oMemo     
Private oPanel1  
Private _oColuna    
Private aEstMTZ    := {}
Private aEstCD     := {}
Private aEstTOTAL  := {}



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
_SldPoder3 := U_DIP8Poder3(_cProduto,.T.)

_SldArm08   := U_SALDECOM(_cProduto,'08') 
_SldArm09   := U_SALDECOM(_cProduto,'09') 

// Verifica se existe Saldo em poder de terceiro (CBE / QUALITY - ESTERILIZAÇÃO HQ)/
If cEmpAnt == '04'
	If Substr(_cProduto,1,1) == "2" 
		_cProdAux := _cProduto
		_cProduto := "8"+Substr(_cProduto,2,6) 
		_nQtdSI   := U_SalEsPCP(_cProduto) 
		_cProduto := _cProdAux
	Else	
		_nQtdSI   := U_SalEsPCP(_cProduto) 	
	EndIf	
//	Else
//		_nQtdSI := U_SalEstHQ(_cProduto)	
//	EndIf	
	If Substr(_cProduto,1,1) == "6"
		_QtdEmp := U_HQEMPB2C(_cProduto)
	EndIf	

EndIf

DbSelectArea("SB1")
DbSetOrder(1)

If DbSeek(xFilial("SB1")+_cProduto)
	
	_cObs     := MSMM(SB1->B1_CODOBS,TamSx3("B1_OBS")[1])
	_Men_Hab  := SB1->B1_MEN_HAB
	
	/// LOCALIZA O PRóXIMO CóDIGO DO PRODUTO
	While SB1->(!EOF()) .and. _cProduto == SB1->B1_COD
		SB1->(DbSkip())
	EndDo
	
	If SB1->(EOF())
		_cProdProc := "ZZZZZZ" // CASO SEJA FIM DE ARQUIVO PEGA O úLTIMO REGISTRO
	Else	
		_cProdProc := SB1->B1_COD // CASO NãO SEJA FIM DE ARQUIVO PEGA O PRóXIMO CóDIGO
	EndIf

	DbSeek(xFilial("SB1")+_cProduto) //POSICIONA NOVAMENTE NO REGISTRO SELECIONADO

	
	IF FunName(0) == "MATA010"  //FunName(0) == "#MATA010"
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Carrega as Notas Fiscais de Entrada do produto. ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cSQL := " SELECT "
		cSQL += "	D1_TES, D1_VUNIT, D1_QUANT, D1_EMISSAO, D1_DOC, D1_SERIE, D1_CUSDIP, D1_DTDIGIT, D1_FORNECE, (CASE WHEN D1_FILIAL = '01' THEN 'MATRIZ' ELSE 'CD' END) EMPRESA  "
		cSQL += "	FROM "+RetSQLName("SD1")
		cSQL += "		WHERE "
		If cEmpAnt == '04'
			cSQL += "			D1_FILIAL IN ('01','02') "// RBORGES 05/04/17 - consulta consolidada será para as duas empresas
		Else
			cSQL += "			D1_FILIAL IN ('01','04') "		
		EndIf			
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
				AAdd( _aUltimasEnt,{ Iif(QRYSD1->D1_FORNECE $ '000996/000997',0,QRYSD1->D1_VUNIT),QRYSD1->D1_QUANT,DTOC(QRYSD1->D1_EMISSAO),QRYSD1->D1_DOC,QRYSD1->D1_SERIE,QRYSD1->D1_CUSDIP,DTOC(QRYSD1->D1_DTDIGIT),QRYSD1->EMPRESA } )
				IF Len(_aUltimasEnt) >= 15
					Exit
				EndIF
			EndIF
			QRYSD1->(dbSkip())	
		EndDo
		QRYSD1->(dbCloseArea())
		
		IF Len(_aUltimasEnt) <=0
			AAdd( _aUltimasEnt,{ 0, 0, Ctod(""), "", "",0,Ctod(""),"" } )// Alterado para incluir custo dipromed no array - MCVN 30/09/08 
		EndIF

		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Consumo medio dos produtos.  SB3 - Consolidado  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		
		cSQLB3 := " SELECT B3_COD, SUM(B3_Q01) B3_Q01,SUM(B3_Q02) B3_Q02,SUM(B3_Q03) B3_Q03,SUM(B3_Q04) B3_Q04,SUM(B3_Q05) B3_Q05,SUM(B3_Q06) B3_Q06,SUM(B3_Q07) B3_Q07,SUM(B3_Q08) B3_Q08,SUM(B3_Q09) B3_Q09,SUM(B3_Q10) B3_Q10,SUM(B3_Q11) B3_Q11,SUM(B3_Q12) B3_Q12 "
		cSQLB3 += "	FROM "+RetSQLName("SB3")
		cSQLB3 += "		WHERE "                             
		cSQLB3 += "		    B3_COD = '"+_cProduto+"' And "
		If cEmpAnt == '04'
			cSQLB3 += "		    B3_FILIAL IN ('01','02') "// RBORGES 05/04/17 - consulta consolidada será para as duas empresas
		Else
			cSQLB3 += "		    B3_FILIAL IN ('01','04') "		
		EndIf			

		cSQLB3 += "			AND D_E_L_E_T_ = ' ' "
		cSQLB3 += "	GROUP BY B3_COD "
		
		
		cSQLB3 := ChangeQuery(cSQLB3)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQLB3),"QRYSB3",.T.,.T.)       
            

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
		
		
		While !QRYSB3->(Eof())			
						
			FOR nX := 1 TO 12
				IF _aMeses[_nMes] == "Janeiro" .And. nX != 1
					_nAno++
				EndIF
				
				AAdd(_aMediaConsu,{_aMeses[_nMes]+"/"+StrZero(_nAno,4), &("QRYSB3->B3_Q" + StrZero(_nMes,2) ), nX })
					
				_nMes++
				IF _nMes > 12
					_nMes := 1
				EndIF
			Next              
			
			QRYSB3->(DbSkip()) 		
		EndDo              
		
		QRYSB3->(dbCloseArea())	

		AAdd(_aMediaConsu,{"Media dos Ultimos 3 Meses", 0,100})
			
		aSort( _aMediaConsu ,,, {|a,b| a[3] > b[3]} )
		
		For nX := 1 To 5        
			If nX>2
				_aMediaConsu[1,2] += _aMediaConsu[nX,2]
			EndIf
		Next
			
		_aMediaConsu[1,2] := _aMediaConsu[1,2] / 3
			
	EndIF
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Carrega os pedidos de compra do produto. - Consolidado ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	QRY2 :=        " SELECT C7_NUM, C7_PRODUTO, C7_DENTREG, C7_ENCER, C7_RESIDUO, C7_EMISSAO, C7_ITEM, (C7_QUANT - C7_QUJE) C7_QUANT, (CASE WHEN C7_FILIAL = '01' THEN 'MATRIZ' ELSE 'CD' END) EMPRESA   "
	QRY2 := QRY2 + " FROM "+RetSQLName("SC7")
	QRY2 := QRY2 + " WHERE "
    If cEmpAnt == '04' // RBORGES 05/04/17 - consulta consolidada será para as duas empresas
		QRY2 := QRY2 + " SC7040.C7_FILIAL IN ('01','02') and "
		QRY2 := QRY2 + " SC7040.D_E_L_E_T_ <> '*' and " 
		QRY2 := QRY2 + " SC7040.C7_PRODUTO = '"+_cProduto+" ' and "
		QRY2 := QRY2 + " SC7040.C7_ENCER   = '' and "  
		QRY2 := QRY2 + " SC7040.C7_RESIDUO = '' "     
		QRY2 := QRY2 + " Order by C7_DENTREG, C7_PRODUTO, C7_NUM "
	Else
		QRY2 := QRY2 + " SC7010.C7_FILIAL IN ('01','04') and "
		QRY2 := QRY2 + " SC7010.D_E_L_E_T_ <> '*' and " 
		QRY2 := QRY2 + " SC7010.C7_PRODUTO = '"+_cProduto+" ' and "
		QRY2 := QRY2 + " SC7010.C7_ENCER   = '' and "  
		QRY2 := QRY2 + " SC7010.C7_RESIDUO = '' "     
		QRY2 := QRY2 + " Order by C7_DENTREG, C7_PRODUTO, C7_NUM "
	EndIf		

	QRY2 := ChangeQuery(QRY2)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,QRY2),"QRYSC7",.T.,.T.)       

	TCSETFIELD("QRYSC7","C7_DENTREG","D",8,0)
	TCSETFIELD("QRYSC7","C7_EMISSAO","D",8,0)

	While QRYSC7->(!Eof()) 
		
    	If Alltrim(_cProduto) == Alltrim(QRYSC7->C7_PRODUTO)
	    		       
			IF Empty(QRYSC7->C7_ENCER) .AND. Empty(QRYSC7->C7_RESIDUO)
				AAdd( _aPedCompras,{ QRYSC7->C7_QUANT , QRYSC7->C7_DENTREG, QRYSC7->C7_EMISSAO, QRYSC7->C7_NUM, QRYSC7->C7_ITEM, QRYSC7->C7_PRODUTO, QRYSC7->EMPRESA } )
				IF Len(_aPedCompras) >= 15
					Exit
				EndIF
			EndIF
	    
	    Endif
	    
	QRYSC7->(DbSkip()) 	
			
	EndDo
	
	QRYSC7->(dbCloseArea())

	IF Len(_aPedCompras) <=0
		AAdd( _aPedCompras,{ 0, Ctod(""),Ctod(""),"","","",""} )
	EndIF
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Carrega as programacoes de venda do produto. - Consolidado ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	QRYSCK :=          " SELECT CK_QTDVEN, CK_ENTREG, CK_NUMPV, A1_COD,A1_NOME, (CASE WHEN CK_FILIAL = '01' THEN 'MATRIZ' ELSE 'CD' END) EMPRESA   "
	QRYSCK := QRYSCK + " FROM "+RetSQLName("SCK")+", "+RetSQLName("SCJ")+", "+RetSQLName("SA1")
	QRYSCK := QRYSCK + " WHERE "
	If cEmpAnt == '04'
		QRYSCK := QRYSCK + " CK_FILIAL  IN ('01','02') and "  // RBORGES 05/04/17 - consulta consolidada será para as duas empresas                 
		QRYSCK := QRYSCK + " CJ_FILIAL  IN ('01','02') and "
	Else
		QRYSCK := QRYSCK + " CK_FILIAL  IN ('01','04') and "                   
		QRYSCK := QRYSCK + " CJ_FILIAL  IN ('01','04') and "	
	EndIf
	QRYSCK := QRYSCK + " CJ_OPCAO   = 'P'  and "      
	QRYSCK := QRYSCK + " CK_NUM     = CJ_NUM and "  
	QRYSCK := QRYSCK + " CK_NUMPV   = ''     and "      
	QRYSCK := QRYSCK + " CK_FILIAL  = CJ_FILIAL and "      
	QRYSCK := QRYSCK + " CK_CLIENTE = CJ_CLIENTE and "  
	QRYSCK := QRYSCK + " CK_LOJA    = CJ_LOJA and "  
	QRYSCK := QRYSCK + " CK_FILIAL  = CJ_FILIAL and "      
	QRYSCK := QRYSCK + " CK_CLIENTE = A1_COD and "  
	QRYSCK := QRYSCK + " CK_LOJA    = A1_LOJA and "      
	QRYSCK := QRYSCK + " CK_PRODUTO = '"+_cProduto+" ' and "
	QRYSCK := QRYSCK + RetSQLName("SCK") + ".D_E_L_E_T_ = '' and "
	QRYSCK := QRYSCK + RetSQLName("SCJ") + ".D_E_L_E_T_ = '' and "
	QRYSCK := QRYSCK + RetSQLName("SA1") + ".D_E_L_E_T_ = '' "
	QRYSCK := QRYSCK + " ORDER BY CK_ENTREG "

	QRYSCK := ChangeQuery(QRYSCK)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,QRYSCK),"QRYSCK",.T.,.T.)       

	TCSETFIELD("QRYSCK","CK_ENTREG","D",8,0)
           
	While !QRYSCK->(Eof())			
					
		AAdd( _aProgramacao,{ QRYSCK->CK_QTDVEN, QRYSCK->CK_ENTREG, QRYSCK->A1_COD+"-"+QRYSCK->A1_NOME,  QRYSCK->EMPRESA} )
					
		_nQtdPorg := _nQtdPorg + QRYSCK->CK_QTDVEN

		IF Len(_aProgramacao) >= 50  //MCVN - 29/05/2008 (O PADRÃO ESTAVA COMO 15)
			Exit
		EndIF					
		QRYSCK->(DbSkip()) 		
	EndDo
	QRYSCK->(dbCloseArea())		    

	IF Len(_aProgramacao) <=0
		AAdd( _aProgramacao,{ 0, Ctod(""), "",""} )
	EndIF
	
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica estoque do produto - Consolidado³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aEstMTZ  := U_DIPSALDSB2(SB1->B1_COD,lGatilho,'MTZ') //Array com estoque da Matriz
	aEstCD   := U_DIPSALDSB2(SB1->B1_COD,lGatilho,'CD')  //Array com estoque do CD

	AADD(aEstTOTAL,{aEstMTZ[1][1]+aEstCD[1][1],; // Estoque total          01
					aEstMTZ[1][2]+aEstCD[1][2],; // Reserva total          02
					aEstMTZ[1][3]+aEstCD[1][3],; // Total A Endereçar      03
					aEstMTZ[1][4]+aEstCD[1][4],; // Saldo total Disponível 04
					aEstMTZ[1][5]+aEstCD[1][5],; // Saldo em Pedidos	   05  
					aEstMTZ[1][6]+aEstCD[1][6]}) // Total A Entrar         06  



	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Mostra dados do Produto.					                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	IF FunName(0) == "MATA010" .AND. (cModulo == 'COM' .OR. UPPER(U_DipUsr()) $ 'EPONTOLDIO/LMARTINS/PMENDONCA/BRODRIGUES/RBEAZIN')
		@ 010,180 To 482,1070 Dialog _oDlg Title OemToAnsi("Caracteristicas do produto.")
	Else
		@ 010,180 To 482,770 Dialog _oDlg Title OemToAnsi("Caracteristicas do produto.")
	EndIF
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Dados das caracteristicas do produto                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	@ 001,002 To 038,295
	@ 003,004 SAY OemToAnsi("  Dados do Produto ") SIZE 047,007 
	@ 014,004 SAY OemToAnsi("Codigo") 		 	  SIZE 021,007
	@ 014,040 SAY SB1->B1_COD 					  SIZE 050,008 COLOR CLR_BLUE
	
	@ 014,080 SAY OemToAnsi("Unidade") 			SIZE 020,007
	@ 014,102 SAY SB1->B1_UM 					SIZE 010,008 COLOR CLR_BLUE
	
	@ 014,115 SAY OemToAnsi("Grupo") 			SIZE 018,007
	@ 014,135 SAY SB1->B1_GRUPO 				SIZE 040,008 COLOR CLR_BLUE
      
	If cEmpAnt=="01"
		If FunName(0) == "MATA010" .AND. (cModulo == 'COM' .OR. UPPER(U_DipUsr()) $ 'EPONTOLDIO/LMARTINS/PMENDONCA/RBEAZIN')
			@ 006,200 SAY OemToAnsi("Qtd. Embalagem") 				SIZE  070,007
			@ 006,240 SAY Transform(SB1->B1_XQE,"@E 999,999.999") 	SIZE  035,007 COLOR CLR_BLUE
		EndIf
		
		@ 014,200 SAY OemToAnsi("Cx. Embarque") 			 		SIZE  070,007
		@ 014,240 SAY Transform(SB1->B1_XQTDEMB,"@E 999,999.999") 	SIZE  035,007 COLOR CLR_BLUE
	Else 
		@ 014,200 SAY OemToAnsi("Qtd. Embalagem") 			 		SIZE  070,007
		@ 014,240 SAY Transform(SB1->B1_XQE,"@E 999,999.999")  		SIZE  035,007 COLOR CLR_BLUE
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
		ADD COLUMN TO _oUltimasEnt HEADER "Empresa"     OEM DATA {|| _aUltimasEnt[_oUltimasEnt:nAt,08] } SIZE 035 PIXEL                             
		
		
		@ 113,297 To 220,445
		
		@ 114,300 SAY OemToAnsi(" Media de Consumo ") Size 048,007
		
		_oMediaConsu := TCBROWSE():New(122,300,140,097,,,,_oDlg,,,,,{||(_lSaida:=.T.,;
		_nList:=_oMediaConsu:nAt,Close(_oDlg))},,,,,,,.F.,,.T.,,.F.,,)
		
		_oMediaConsu:SetArray(_aMediaConsu)
		
		ADD COLUMN TO _oMediaConsu HEADER "Meses/Ano"   OEM DATA {|| _aMediaConsu[_oMediaConsu:nAt,01] } SIZE 070 PIXEL
		ADD COLUMN TO _oMediaConsu HEADER "Consumo"     OEM DATA {|| TransForm(_aMediaConsu[_oMediaConsu:nAt,02],"@E 99,999,999") } SIZE 035 PIXEL
		
	EndIF
	
	_nQtdCQ := u_DipSomaCQ(SB1->B1_COD,SB1->B1_PROC,SB1->B1_LOJPROC,.T.)                               
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Mostra saldo em estoque do produto                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	@ 039,002 To 095,157
	@ 040,004 SAY OemToAnsi("  Estoque") Size 026,007 
	
	@ 048,004 SAY OemToAnsi("Saldo Arm.06")								SIZE 040,007
	@ 048,038 SAY Transform(_SldPoder3,"@E 99,999,999") 	    SIZE 040,007 COLOR CLR_GREEN  
	
	@ 055,004 SAY OemToAnsi("Saldo Arm.08")						SIZE 040,007
	@ 055,038 SAY Transform(_SldArm08,"@E 99,999,999") 	    SIZE 040,007 COLOR CLR_GREEN

	@ 062,004 SAY OemToAnsi("Saldo Arm.09")						SIZE 040,007
	@ 062,038 SAY Transform(_SldArm09,"@E 99,999,999") 	    SIZE 040,007 COLOR CLR_GREEN
	
	@ 069,004 SAY OemToAnsi("Saldo") 							SIZE 040,007 COLOR CLR_HRED
	@ 069,038 SAY Transform(aEstTOTAL[1][5],"@E 99,999,999") 	SIZE 040,007 COLOR CLR_HRED
	
	@ 076,004 SAY OemToAnsi("a Entrar") 						SIZE 040, 007
	@ 076,038 SAY Transform(aEstTOTAL[1][6],"@E 99,999,999") 	SIZE 040, 007 COLOR CLR_BLUE
	
	@ 083,004 SAY OemToAnsi("Est.Atual(A)") 					SIZE 040,007
	@ 083,038 SAY Transform(aEstTOTAL[1][1],"@E 99,999,999")  	SIZE 040,007 COLOR CLR_HRED
	
	@ 055,070 SAY OemToAnsi("a Enderecar(B)") 					SIZE 040,007
	@ 055,123 SAY Transform(aEstTOTAL[1][3],"@E 99,999,999") 	SIZE 030,007 COLOR CLR_BLUE
	
	@ 062,070 SAY OemToAnsi("Reservado(C)") 					SIZE  040,007
	@ 062,123 SAY Transform(aEstTOTAL[1][2],"@E 99,999,999") 	SIZE 030,007 COLOR CLR_BLUE
	
	@ 069,070 SAY OemToAnsi("Programacao(D)") 					SIZE  050,007
	@ 069,123 SAY Transform(_nQtdPorg,"@E 99,999,999")  		SIZE 030,007 COLOR CLR_BLUE
	
	@ 076,070 SAY OemToAnsi("Disponivel(A-(B+C+D))")			SIZE  060,007
	@ 076,123 SAY Transform((aEstTOTAL[1][4]-_nQtdPorg),"@E 99,999,999") SIZE 030,007 COLOR CLR_BLUE
	
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
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Mostra as observa‡ao sobre o produto B1_OBS         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	@ 039,160 TO 220, 295                 // JBS 13/10/2005
	@ 040,164 SAY OemToAnsi(" Observacoes:") Size 066,007
	@ 047,164 GET _cObs Size 127,130 MEMO WHEN .F.// JBS 13/10/2005
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Mostra mensagem sobre o produto B1_MEN_HAB         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !Empty(_Men_Hab)
		@ 180,164 SAY OemToAnsi(" MENSAGEM HABILITADO:") Size 066,007 COLOR CLR_BLUE
	    @ 187,164 SAY Substr(_Men_Hab,1,45)   Size 130,8 COLOR CLR_HRED
    	@ 195,164 SAY Substr(_Men_Hab,46,45)  Size 130,8 COLOR CLR_HRED
	    @ 203,164 SAY Substr(_Men_Hab,92,45)  Size 130,8 COLOR CLR_HRED
	    @ 211,164 SAY Substr(_Men_Hab,138,45) Size 130,8 COLOR CLR_HRED
	Endif   
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Mostra os pedidos de compra do produto. ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
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
	@ 164,004 SAY OemToAnsi("  Programação") Size 035,007 
		
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Mostra as programacoes do produto.      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	_oProgram := TCBROWSE():New(171,004,150,046,,,,_oDlg,,,,,{||(_lSaida:=.T.,;
	_nListProg:=_oProgram:nAt,Close(_oDlg))},,,,,,,.F.,,.T.,,.F.,,)
	
	_oProgram:SetArray(_aProgramacao)
	
	ADD COLUMN TO _oProgram HEADER "Quantidade"         OEM DATA {|| TransForm(_aProgramacao[_oProgram:nAt,01],"@E 99,999,999") } SIZE 035 PIXEL
	ADD COLUMN TO _oProgram HEADER "Previsao Entrega"   OEM DATA {|| _aProgramacao[_oProgram:nAt,02] } SIZE 045 PIXEL
	ADD COLUMN TO _oProgram HEADER "Cliente"            OEM DATA {|| _aProgramacao[_oProgram:nAt,03] } SIZE 080 PIXEL
	ADD COLUMN TO _oProgram HEADER "Empresa"            OEM DATA {|| _aProgramacao[_oProgram:nAt,04] } SIZE 010 PIXEL
	
	/* Eriberto 15/09/2004
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Carrega a imagem do produto                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
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


*-----------------------------------------------*
Static Function Dp04Check(cTes)                                 
*-----------------------------------------------*
Local lRet	:= .F.

SF4->(dbSetOrder(1))
SF4->(dbseek(xFilial('SF4')+cTes))    

lRet :=  (SF4->F4_ESTOQUE == 'S')

If lRet
	If cEmpAnt+cFilAnt == '0101'
		lRet := !(SF4->F4_CODIGO$('131/135/263'))
	ElseIf cEmpAnt+cFilAnt == '0104'
		lRet := !(SF4->F4_CODIGO$('179/255/038'))
	EndIf
EndIf
	
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDIPR042A  บAutor  ณJailton B Santos-JBSบ Data ณ 05/03/2010  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณPrograma desenvolvido para gerar relatorio de faturamento   บฑฑ
ฑฑบ          ณdiario e acompanhamento dos pedidos disponiveis para serem  บฑฑ
ฑฑบ          ณfaturados.                                                  บฑฑ
ฑฑฬออออออออออุออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออนฑฑ
ฑฑบOrigem    ณDIPR042   บAutor  ณRafael Campos Falco บ Data ณ 17/09/2003  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบVersao    ณVersao do programa DIPR042, criados tratamentos para impres-บฑฑ
ฑฑบ          ณsao multi empresas e feliais. 70% Ajustado.                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Especifico - Faturamento - Dipromed.                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#include "rwmake.ch"
//---------------------------------------------------------------------------------------
// Posicoes de Metas por Departamento. Veja os exemplos comentados a direita da definicao
//---------------------------------------------------------------------------------------
#DEFINE METTEL  1  //  _aMeta[nId][METTEL]
#DEFINE METREP  2  //  _aMeta[nId][METREP]
#DEFINE METPAR  3  //  _aMeta[nId][METPAR]
#DEFINE METPUB  4  //  _aMeta[nId][METPUB]
#DEFINE METDIP  5  //  _aMeta[nId][METDIP]

User Function DIPR042A()

Local oDlg
Local _xArea	:= GetArea()
Local titulo	:= OemTOAnsi("Faturamento Diแrio",72)
Local cDesc1	:= OemToAnsi("Este programa tem como objetivo emitir um relatขrio",72)
Local cDesc2	:= OemToAnsi("do faturamento diแrio separado por",72)
Local cDesc3	:= OemToAnsi("P๚blico, Particular, Prefeitura, Representantes, Televendas.",72)
Local nOpcao    := 0

Private cUserAut   := GetMV("MV_URELFAT")// MCVN - 04/05/09
Private aReturn    := {"Bco A4", 1,"Financeiro", 1, 2, 1,"",1}
Private li         := 80
Private tamanho    := "M"
Private limite     := 132
Private nomeprog   := "DIPR042A"
PRIVATE cPerg      := U_FPADR( "DIPR42","SX1","SX1->X1_GRUPO"," " ) //Fun็ใo criada por Sandro em 19/11/09.
Private nLastKey   := 0
Private lEnd       := .F.
Private lContinua  := .T.
Private wnrel      := "DIPR042A"
Private cString    := "SE1"
Private m_pag      := 1
Private _aAllEmiFat:= {}  // JBS 05/03/2010 - Faturamento de todas as empresas e feliais
Private _aAllEmiPed:= {}  // JBS 05/03/2010 - Pedidos de todas as empresas e feliais
Private _aFeriad   := {} 
Private _aNaoFatDip:= {} 
Private _aAcuFat   := {}
Private _aPedLib   := {}
Private _aNodia    := {}
Private _aDia      := {}
//---------------------------------------------------------------------------------------------
Private _aSintetico:= {}//fSintetico("040","01") // JBS 07/04/2010 - Apura os valores sinteti-
// cos para empresa 04 na filial 01.
//---------------------------------------------------------------------------------------------
Private _aSinForn  := {}//fSintetico("040","04") // JBS 14/05/2010 - Apura os valores sinteti-
// cos para empresa 04 na filial 04.
//--------------------------------------------------------------------------------------------- 
Private _aHQ_CD    := {} // Faturamento sintetico HQ CD p/ os fornecedores $ '000851/000847/051508' 
// JBS 15/06/2010
//---------------------------------------------------------------------------------------------
Private _nDiasCom  := 0
Private _nDiasSem  := 0
Private cFornVend  := AllTrim(GETNEWPAR("MV_FORNVEN",""))
Private cFornQH    := AllTrim(GETNEWPAR("MV_FORNQH",'051508-27')) // JBS 14/05/2010 - Este fornecedores nใo devem aparecer no relatorio diario, apenas na ultima linha de totais.
Private cMes       := Space(2)
Private cAno       := Space(4)
Private _aMeta     := {}                            // JBS 04/03/2010 - Array usada para guardar as mestas por departamento
//Private aEmpresa   := {{'010','04'},{'040','04'}}  //-- Daniel 29/06/2011
/* REMOVIDO HQ - TIAGO STOCCO
Private aEmpresa   := {	{ {'010','04'} },;
						{ {'010','01'} , {'040','04'} }   }  // Empresa e filial para processar as querys
*/
Private aEmpresa   := {	{ {'010','04'} },;
						{ {'010','01'} } }  // Empresa e filial para processar as querys
Private nMetTel    := 0
Private nMetRep    := 0
Private nMetPar    := 0 
Private nMetPub    := 0
Private nMetDip    := 0
Private cCodVend   := Space(40)     // Codigos de fornecedores a serem impressos - JBS 06/08/2010
Private cCodForn   := Space(40)     // Codigos de fornecedores a serem impressos - JBS 06/08/2010
Private cOper      := Space(254)
Private _cDiaTot   := CtoD("")      // Eriberto 18/04/2007
Private _nTotDia   := 0             // Eriberto 18/04/2007
Private _lUltDia   := .t.           // Eriberto 18/04/2007
Private lValor     := .F.                // MCVN - 04/05/09
Private cVendInt   := GetMV("MV_DIPVINT")// MCVN - 06/05/09
Private cVendExt   := GetMV("MV_DIPVEXT")// MCVN - 06/05/09
Private cVendPub   := GetMV("MV_DIPVPUB")// MCVN - 19/08/10      
Private _cDipUsr   := U_DipUsr() 
//Private cVF2orC5   := "C5_VEND1"                       

cFornVend += "\000996" // Nใo coloquei no parametro por que ele ้ utilizado em outras rotinas

/*If !(Upper(_cDipUsr) $ cUserAut .Or. Upper(_cDipUsr) $ cVendInt .or. Upper(_cDipUsr) $ cVendExt  .or. Upper(_cDipUsr) $ cVendPub) // MCVN - 19/08/10
 	Alert(Upper(_cDipUsr)+", voc๊ nใo tem autoriza็ใo para utilizar esta rotina. Qualquer d๚vida falar com Eriberto!","Aten็ใo")
 	Return()
Endif*/

//If (Upper(_cDipUsr) $ cUserAut .Or. Upper(_cDipUsr) $ cVendInt .or. Upper(_cDipUsr) $ cVendExt  .or. Upper(_cDipUsr) $ cVendPub) // MCVN - 19/08/10
lValor := MsgBox("Deseja gerar relat๓rios com valores?","Aten็ใo","YESNO")
//Endif

U_DIPPROC(ProcName(0),_cDipUsr) // JBS 05/10/2005 - Gravando o nome do Programa no SZU

SX1->(DipPergDiverg(.t.)) // Verifica se existe o no SX1 o "DIPR42". Retorna os Valores ou cria

Define msDialog oDlg title OemToAnsi("Faturamento Diแrio") From 10,10 TO 22,43

@ 002,002 to 090,130

@ 010,010 say "Informe o mes       "
@ 025,010 say "Informe o ano       "
@ 040,010 say "Informe o Vendedor  "
@ 055,010 say "Informe o Fornecedor"

@ 010,070 get cMes valid cMes>='01'.and.cMes<='12' Size 10,08
@ 025,070 get cAno valid !empty(cAno) size 20,08
@ 040,070 get cCodVend F3 'SA3' Size 30,08
@ 055,070 get cCodForn F3 'SA2' size 30,08

Define sbutton oBt1 from 075,065 type 1 action (nOpcao := 1, oDlg:End()) enable of oDlg
Define sbutton oBt2 from 075,097 type 2 action (nOpcao := 0, oDlg:End()) enable of oDlg

Activate Dialog oDlg Centered

If nOpcao = 0
	Return(.t.)
EndIf

//If !(Empty(Alltrim(cCodVend)))
//	cVF2orC5   := "F2_VEND1"
//Edif
fCalcMetas()

//-------------------------------------------------------------------------------------------------------
OperadorPub() // MCVN - 06/08/09
//-------------------------------------------------------------------------------------------------------

SX1->(DipPergDiverg(.f.))


//-------------------------------------------------------------------------------------------------------
//-- Retirado por Daniel em 29/06/2011
// Ajustes para consolidar Dipromed Matriz e CD a partir de 01/05/2011   - MCVN 03/05/2011
//If cMes > '04' .And. cAno >= '2011'
//	aEmpresa := {{'010','04'},{'010','01'}}  // Empresa e filial para processar as querys
//Endif
//-------------------------------------------------------------------------------------------------------

wnrel := SetPrint(cString,wnrel,cPerg,Titulo,cDesc1,cDesc2,cDesc3,.f.,,.f.,tamanho,,.f.,,,,,)

If nLastKey == 27
	Return
Endif

SetDefault(aReturn,cString)

Processa({|lEnd| RunProc()},"Selecionando dados...")

RptStatus({|lEnd| RptDetail()},"Imprimindo...")

RestArea(_xArea)

Return

//////////////////////////////////////////////////////////////////////
Static Function RunProc()

Local _cFim    := "31"
Local _dDatFim := ""
Local _dEmiAtu := ""
Local _dEmiIni := ""

Local _nPar    := 0
Local _nPub    := 0
Local _nPre    := 0
Local _nRep    := 0
Local _nTel    := 0
Local _nTot    := 0
Local _nAcPar  := 0
Local _nAcPub  := 0
Local _nAcPre  := 0
Local _nAcRep  := 0
Local _nAcTel  := 0
Local _nAcTot  := 0
Local _nAcCol  := 0
Local _nAcLib  := 0
Local _nAcFat  := 0
Local _nAcEst  := 0
Local _nAcCre  := 0
Local _nAcOpe  := 0
Local _nColPed := 0
Local _nLibPed := 0
Local _nFatPed := 0
Local _nEstPed := 0
Local _nCrePed := 0
Local _nOpePed := 0
Local _nPVLPar := 0
Local _nPVLPub := 0
Local _nPVLPre := 0
Local _nPVLRep := 0
Local _nPVLTel := 0
Local _nPVLTot := 0
Local _nDIAPar := 0
Local _nDIAPub := 0
Local _nDIAPre := 0
Local _nDIARep := 0
Local _nDIATel := 0
Local _nDIATot := 0
Local nId      := 0
Local xi,_x,nEmp

Local _aEmiFat := {}
Local _aEmiPed := {}
//----------------------------------------------------------------------------------------
// Le a Tabela de Feriados no mes.
//----------------------------------------------------------------------------------------
_aFeriad   := fFeriados()
_aNaoFatDip:= fNaoFatDip()
//----------------------------------------------------------------------------------------
// Calcula dia util anterior a data atual
//----------------------------------------------------------------------------------------
_nDias   := fDiaAnt()
//----------------------------------------------------------------------------------------
For nId := 1  to len(aEmpresa)

	//------------------------------------------------------------------------------------
	// Fecha o SX2 auxiliar para abri-lo para a proxima empresa informada na array
	//------------------------------------------------------------------------------------
	If Select('SX2_2') > 0
		SX2_2->( DbCloseArea() )
	EndIf
	
	_aEmiFat := {}
	_aEmiPed := {}
	_cFim    := "31"
	_dDatFim := ""
	_dEmiAtu := ""
	_dEmiIni := ""
	
	_nPar    := 0
	_nPub    := 0
	_nPre    := 0
	_nRep    := 0
	_nTel    := 0
	_nTot    := 0
	_nAcPar  := 0
	_nAcPub  := 0
	_nAcPre  := 0
	_nAcRep  := 0
	_nAcTel  := 0
	_nAcTot  := 0
	_nAcCol  := 0
	_nAcLib  := 0
	_nAcFat  := 0
	_nAcEst  := 0
	_nAcCre  := 0
	_nAcOpe  := 0
	_nColPed := 0
	_nLibPed := 0
	_nFatPed := 0
	_nEstPed := 0
	_nCrePed := 0
	_nOpePed := 0
	_nPVLPar := 0
	_nPVLPub := 0
	_nPVLPre := 0
	_nPVLRep := 0
	_nPVLTel := 0
	_nPVLTot := 0
	_nDIAPar := 0
	_nDIAPub := 0
	_nDIAPre := 0
	_nDIARep := 0
	_nDIATel := 0
	_nDIATot := 0

	For nEmp := 1 to Len(aEmpresa[nId])
		//----------------------------------------------------------------------------------------
		// Le o faturamento do periodo para empresa '0X0 e filial '0Y'
		//----------------------------------------------------------------------------------------
		fQuery01(aEmpresa[nId][nEmp][01],aEmpresa[nId][nEmp][02],.t.)  // Gerou QRY1
		//----------------------------------------------------------------------------------------
		// Le as Devolucoes do periodo para empresa '0X0 e filial '0Y'
		//----------------------------------------------------------------------------------------
		fQuery02(aEmpresa[nId][nEmp][01],aEmpresa[nId][nEmp][02],.t.)  // Gerou QRY2
		//----------------------------------------------------------------------------------------
		// Le os Pedidos do periodo para empresa '0X0 e filial '0Y'
		//----------------------------------------------------------------------------------------
		fQuery03(aEmpresa[nId][nEmp][01],aEmpresa[nId][nEmp][02],.t.)  // Gerou QRY3
		//----------------------------------------------------------------------------------------
		// Preenchendo o array com todos os dias do m๊s, exceto sแbados, domingos e feriados
		//----------------------------------------------------------------------------------------
		_dEmiIni := ctod( "01" + "/" + cMes + "/" + Substr(cAno,3,2 ))
		//----------------------------------------------------------------------------------------
		// Acha ๚ltimo dia do m๊s
		//----------------------------------------------------------------------------------------
		_dFim := U_LastDay(_dEmiIni)
		
		
		For xi := 1 to Val(SubStr(dTOc(_dFim),1,2))
			
			_nPos := Ascan(_aFeriad,{|y| y[1] == _dEmiIni})         // Verifica se data ้ um Feriado
			
			If _nPos == 0
				_nPos := Ascan(_aNaoFatDip,{|y| y[1] == _dEmiIni})  // Verifica se data nใo ้ um dia ๚til para efeito de faturamento
			Endif
						
			If _nPos == 0                                   	// Se a data for um feriado despreza o dia
				If (AllTrim(cDow(_dEmiIni)) <> "Saturday")      // Descarta qdo. for Sแbado
					If (AllTrim(cDow(_dEmiIni)) <> "Sunday")    // Descarta qdo. for Domingo
						If aScan( _aEmiFat, { |x| x[1] == _dEmiIni } ) == 0
							Aadd(_aEmiFat,{_dEmiIni,0,0,0,0,0,0,0})
							Aadd(_aEmiPed,{_dEmiIni,0,0,0,0,0,0,0})
						EndIf
					EndIf
				EndIf
			EndIf
			_dEmiIni++
		Next
				
		ProcRegua(3000)
		For _x := 1 to 500
			IncProc( "Processando... Dados vendas")
		Next
		
		DbSelectArea("QRY1")
		DbGoTop()
		
		Do While QRY1->(!Eof())
			IncProc( "Processando... Dados vendas")
			
			_dEmiAtu := Ctod(Substr(QRY1->F2_EMISSAO,7,2)+"/"+Substr(QRY1->F2_EMISSAO,5,2)+"/"+Substr(QRY1->F2_EMISSAO,1,4))
			//----------------------------------------------------------------------------------------
			// Loop para totalizar o dia
			//----------------------------------------------------------------------------------------
			Do While _dEmiAtu == Ctod(Substr(QRY1->F2_EMISSAO,7,2)+"/"+Substr(QRY1->F2_EMISSAO,5,2)+"/"+Substr(QRY1->F2_EMISSAO,1,4))
		        //----------------------------------------------------------------------------------------
		        // Uso da condicao para tornar esta funcao um rotina mais generica e permiir maior uso.  
		        // JBS 15/06/2010  - Hoje ha a necessidade de trazer um total de um fornecedor  em  uma 
		        // Empresa e filial determinada na condicao vai codeblock com os fornecedores que eu quero. 
		        //----------------------------------------------------------------------------------------
	            If QRY1->D2_FORNEC $ "000851/000847/051508"   
	                //QRY1->( DbSkip())
	                //Loop
	            EndIf    
		        // Comentado em 15/06/2010 - O Eriberto mudou o conceito
				//----------------------------------------------------------------------------------------
				// Exclui do processamento diario o fornecedor  051508'  - JBS 14/05/2010
				// Apenas quando for o CD HQ
				//----------------------------------------------------------------------------------------
				//If aEmpresa[nId][01] + aEmpresa[nId][02] == '04004'  .and. AllTrim(QRY1->D2_FORNEC) $ cFornQH
				//	QRY1->(DbSkip())
				//	Loop
				//EndIf
				//----------------------------------------------------------------------------------------
				// Televendas
				//----------------------------------------------------------------------------------------
				If ((Empty(QRY1->F2_VEND2) .OR. ;
					(!Empty(QRY1->F2_VEND2) .AND. !(QRY1->D2_FORNEC $ cFornVend))).AND. ;
					!Empty(QRY1->U7_CODVEN) .and. ;
					QRY1->F2_VEND1 <> '000204') .or. ;
					QRY1->F2_VEND1 $ '006684/000353/000352/000356/000357/000359'
					
					_nTel += QRY1->F2_VALFAT
				Else
					//----------------------------------------------------------------------------------------
					// Representantes
					//----------------------------------------------------------------------------------------
					_nRep += QRY1->F2_VALFAT
					//----------------------------------------------------------------------------------------
					// Publico
					//----------------------------------------------------------------------------------------
					If QRY1->C5_OPERADO $ cOper
						_nPub += QRY1->F2_VALFAT
					EndIf
					_nPar := (_nRep - _nPub - _nPre)
				EndIf
				//----------------------------------------------------------------------------------------
				// Total
				//----------------------------------------------------------------------------------------
				_nTot += QRY1->F2_VALFAT
				QRY1->(DbSkip())
				
			EndDo
			//----------------------------------------------------------------------------------------
			// Eriberto 05/11/07
			//----------------------------------------------------------------------------------------
			If Ascan(_aFeriad,{|y| y[1] == _dEmiAtu}) <> 0; // ษ feriado
			    .or.  Ascan(_aNaoFatDip,{|y| y[1] == _dEmiAtu}) <> 0; // Nใo ้ um dia ๚til para efeito de faturamento
				.or. (AllTrim(cDow(_dEmiAtu)) = "Saturday"); // ษ Sแbado
				.or. (AllTrim(cDow(_dEmiAtu)) = "Sunday")    // ษ Domingo
				
				// MCVN - 04/12/2007
				If Ascan(_aFeriad,{|y| y[1] == _dEmiAtu}) <> 0 .Or. Ascan(_aNaoFatDip,{|y| y[1] == _dEmiAtu}) <> 0
					_dEmiAtu++
					If (AllTrim(cDow(_dEmiAtu)) = "Saturday")
						_dEmiAtu+=2
						If Val(cMes) <> Month(_dEmiAtu)
							_dEmiAtu-=2
						Endif
					Endif
					If Val(cMes) <> Month(_dEmiAtu)
						_dEmiAtu--
					Endif				
				ElseIf (AllTrim(cDow(_dEmiAtu)) = "Saturday")
					_dEmiAtu+=2
					If Val(cMes) <> Month(_dEmiAtu)
						_dEmiAtu-=2
					Endif
				Else
					_dEmiAtu++
					If Val(cMes) <> Month(_dEmiAtu)
						_dEmiAtu--
					Endif
				Endif
			EndIf
			//----------------------------------------------------------------------------------------
			// Adiciona totais dos dias de cada coluna
			//----------------------------------------------------------------------------------------
			_nPos := Ascan(_aEmiFat,{|y| y[1] == _dEmiAtu})
			_aEmiFat[_nPos,2] += _nPar
			_aEmiFat[_nPos,3] += _nPub
			_aEmiFat[_nPos,4] += _nPre
			_aEmiFat[_nPos,5] += _nRep
			_aEmiFat[_nPos,6] += _nTel
			_aEmiFat[_nPos,7] += _nTot
			//----------------------------------------------------------------------------------------
			// Acumula totais para montar linha dos totais
			//----------------------------------------------------------------------------------------
			_nAcPar += _nPar
			_nAcPub += _nPub
			_nAcPre += _nPre
			_nAcRep += _nRep
			_nAcTel += _nTel
			_nAcTot += _nTot
			//----------------------------------------------------------------------------------------
			// Zera
			//----------------------------------------------------------------------------------------
			_nPar := _nRep := _nTel := _nPub := _nPre := _nTot := 0
			
		EndDo
		
		DbSelectArea("QRY2")
		DbGoTop()
		
		Do While QRY2->(!Eof())
			IncProc( "Processando... Dados devolu็ใo")
			
			_dEmiAtu := Ctod(Substr(QRY2->D1_DTDIGIT,7,2)+"/"+Substr(QRY2->D1_DTDIGIT,5,2)+"/"+Substr(QRY2->D1_DTDIGIT,1,4))
			// Loop para totalizar o dia
			Do While _dEmiAtu == Ctod(Substr(QRY2->D1_DTDIGIT,7,2)+"/"+Substr(QRY2->D1_DTDIGIT,5,2)+"/"+Substr(QRY2->D1_DTDIGIT,1,4))
		        //----------------------------------------------------------------------------------------
		        // Uso da condicao para tornar esta funcao um rotina mais generica e permiir maior uso.  
		        // JBS 15/06/2010  - Hoje ha a necessidade de trazer um total de um fornecedor  em  uma 
		        // Empresa e filial determinada na condicao vai codeblock com os fornecedores que eu quero. 
		        //----------------------------------------------------------------------------------------
	            //If QRY2->D2_FORNEC $ "000851/000847/051508"   
	            //    QRY2->( DbSkip())
	            //    Loop
	            //EndIf    
		        // Comentado em 15/06/2010 - O Eriberto mudou o conceito
				//----------------------------------------------------------------------------------------
				// Exclui do processamento diario o fornecedor  051508'  - JBS 14/05/2010
				// Apenas quando for o CD HQ
				//----------------------------------------------------------------------------------------
				//If aEmpresa[nId][01] + aEmpresa[nId][02] == '04004'  .and. AllTrim(QRY2->D2_FORNEC) $ cFornQH
				//	QRY2->(DbSkip())
				//	Loop
				//EndIf
				// Televendas
				If ((Empty(QRY2->C5_VEND2) .OR. ;
					(!Empty(QRY2->C5_VEND2) .AND. !(QRY2->D2_FORNEC $ cFornVend))).AND. ;
					!Empty(QRY2->U7_CODVEN) .and. ;
					QRY2->F2_VEND1 <> '000204') .or. ;
					QRY2->F2_VEND1 $ '006684/000353/000352/000356/000357/000359'
					
					_nTel -= QRY2->D1_TOTAL
				Else
					// Representantes
					_nRep -= QRY2->D1_TOTAL
					// P๚blico
					If QRY2->C5_OPERADO $ cOper
						_nPub -= QRY2->D1_TOTAL
					EndIf
					//Prefeitura
					//If QRY2->C5_CLIENTE = '004303'
					//	_nPre -= QRY2->D1_TOTAL
					//EndIf
					// Particular
					_nPar := (_nRep - _nPub - _nPre)
				EndIf
				// Total
				_nTot -= QRY2->D1_TOTAL
				
				QRY2->(DbSkip())
				
			EndDo
			
			// Eriberto 05/11/07
			If Ascan(_aFeriad,{|y| y[1] == _dEmiAtu}) <> 0; // ษ feriado
			    .or.  Ascan(_aNaoFatDip,{|y| y[1] == _dEmiAtu}) <> 0; // Nใo ้ um dia ๚til para efeito de faturamento
				.or. (AllTrim(cDow(_dEmiAtu)) = "Saturday"); // ษ Sแbado
				.or. (AllTrim(cDow(_dEmiAtu)) = "Sunday")    // ษ Domingo
				
				// MCVN - 04/12/2007
				If Ascan(_aFeriad,{|y| y[1] == _dEmiAtu}) <> 0 .Or. Ascan(_aNaoFatDip,{|y| y[1] == _dEmiAtu}) <> 0
					_dEmiAtu++
					If (AllTrim(cDow(_dEmiAtu)) = "Saturday")
						_dEmiAtu+=2
						If Val(cMes) <> Month(_dEmiAtu)
							_dEmiAtu-=2
						Endif
					Endif
					If Val(cMes) <> Month(_dEmiAtu)
						_dEmiAtu--
					Endif
				ElseIf (AllTrim(cDow(_dEmiAtu)) = "Saturday")
					_dEmiAtu+=2
					If Val(cMes) <> Month(_dEmiAtu)
						_dEmiAtu-=2
					Endif
				Else
					_dEmiAtu++
					If Val(cMes) <> Month(_dEmiAtu)
						_dEmiAtu--
					Endif
				Endif
			EndIf
			//-----------------------------------------------------------
			// Adiciona totais dos dias de cada coluna
			//-----------------------------------------------------------
			_nPos := Ascan(_aEmiFat,{|y| y[1] == _dEmiAtu})
			_aEmiFat[_nPos,2] += _nPar
			_aEmiFat[_nPos,3] += _nPub
			_aEmiFat[_nPos,4] += _nPre
			_aEmiFat[_nPos,5] += _nRep
			_aEmiFat[_nPos,6] += _nTel
			_aEmiFat[_nPos,7] += _nTot
			//-----------------------------------------------------------
			// Acumula totais para montar linha dos totais
			//-----------------------------------------------------------
			_nAcPar += _nPar
			_nAcPub += _nPub
			_nAcPre += _nPre
			_nAcRep += _nRep
			_nAcTel += _nTel
			_nAcTot += _nTot
			//-----------------------------------------------------------
			_nPar := _nRep := _nTel := _nPub := _nPre := _nTot := 0
			
		EndDo
		
		For _x := 1 to 500
			IncProc( "Processando... Dados dos pedidos")
		Next
		
		DbSelectArea("QRY3")
		DbGoTop()
		
		Do While QRY3->(!Eof())
			
			IncProc( "Processando... Dados dos pedidos")
			
			_dEmiAtu := Ctod(Substr(QRY3->C5_EMISSAO,7,2)+"/"+Substr(QRY3->C5_EMISSAO,5,2)+"/"+Substr(QRY3->C5_EMISSAO,1,4))
			// Loop para totalizar o dia
		   	If Substr(QRY3->C5_EMISSAO,5,2) == cMes 
				
				Do While _dEmiAtu == Ctod(Substr(QRY3->C5_EMISSAO,7,2)+"/"+Substr(QRY3->C5_EMISSAO,5,2)+"/"+Substr(QRY3->C5_EMISSAO,1,4))
		            //----------------------------------------------------------------------------------------
		            // Uso da condicao para tornar esta funcao um rotina mais generica e permiir maior uso.  
		            // JBS 15/06/2010  - Hoje ha a necessidade de trazer um total de um fornecedor  em  uma 
		            // Empresa e filial determinada na condicao vai codeblock com os fornecedores que eu quero. 
		            //----------------------------------------------------------------------------------------
	                //If QRY3->C9_FORNEC $ "000851/000847/051508"   
	                //    QRY3->( DbSkip())
	                //    Loop
	                //EndIf    
		            // Comentado em 15/06/2010 - O Eriberto mudou o conceito
					//----------------------------------------------------------------------------------------
					// Exclui do processamento diario o fornecedor  051508'  - JBS 14/05/2010
					// Apenas quando for o CD HQ
					//----------------------------------------------------------------------------------------
					//If aEmpresa[nId][01] + aEmpresa[nId][02] == '04004'  .and. AllTrim(QRY3->C9_FORNEC) $ cFornQH
					//	QRY3->( DbSkip() )
					//	Loop
					//EndIf
					// Colocados
					
				 If Substr(QRY3->C9_DATALIB,1,6) == (cAno+cMes) .And. Left(QRY3->C9_DATALIB,6) == Left(DTOS(DDATABASE),6)					
					_nColPed += QRY3->C9_VALOR
					// Liberados
					If Empty(QRY3->C5_PARCIAL) .and. ((QRY3->C9_BLEST='02' .or. QRY3->C9_BLEST='  ') .and. QRY3->C9_SALDO = 0 .and. Empty(QRY3->C9_BLCRED) .and. Empty(QRY3->C9_BLCRED2))
						_nLibPed += QRY3->C9_VALOR
						// Estoque
						
					ElseIf QRY3->C9_BLEST = '02' .and. QRY3->C9_SALDO != 0
						_nEstPed += QRY3->C9_VALOR
						// Pelo Operador
					ElseIf !Empty(QRY3->C5_PARCIAL)
						_nOpePed  += QRY3->C9_VALOR
						// Credito
					ElseIf QRY3->C9_BLCRED $ '01/04/09' //!Empty(QRY3->C9_BLCRED2) Eriberto 12/03/2007
						_nCrePed += QRY3->C9_VALOR
						// Faturado
					ElseIf QRY3->C9_BLEST == '10' .and. QRY3->C9_BLCRED == '10'
						_nFatPed += QRY3->C9_VALOR
					EndIf
					
					// S๓ para pedidos liberados - vamos separar por area
					If Empty(QRY3->C5_PARCIAL) .and. ((QRY3->C9_BLEST = '02' .or. QRY3->C9_BLEST = '  ') .and. QRY3->C9_SALDO = 0 .and. Empty(QRY3->C9_BLCRED) .and. Empty(QRY3->C9_BLCRED2))
						// Televendas
						If (!Empty(QRY3->U7_CODVEN) .and. QRY3->C9_VEND <> '000204') .or. QRY3->C9_VEND $ '006684/000353/000352/000356/000357/000359'
							_nPVLTel += QRY3->C9_VALOR
						Else
							// Representantes
							_nPVLRep += QRY3->C9_VALOR
							// P๚blico
							If QRY3->C9_OPERADO $ cOper
								_nPVLPub += QRY3->C9_VALOR
							EndIf
							//Prefeitura
							If QRY3->C9_CLIENTE = '004303'
								_nPVLPre += QRY3->C9_VALOR
							EndIf
							// Particular
							_nPVLPar := (_nPVLRep - _nPVLPub - _nPVLPre)
						EndIf
						// Total
						_nPVLTot += QRY3->C9_VALOR
					EndIf
				 EndIf	
					QRY3->(DbSkip())
					
				EndDo
				
				// Eriberto 05/11/07                                                                                 
				If Ascan(_aFeriad,{|y| y[1] == _dEmiAtu}) <> 0; // ษ feriado                                         
				    .or.  Ascan(_aNaoFatDip,{|y| y[1] == _dEmiAtu}) <> 0; // Nใo ้ um dia ๚til para efeito de faturamento
					.or. (AllTrim(cDow(_dEmiAtu)) = "Saturday"); // ษ Sแbado
					.or. (AllTrim(cDow(_dEmiAtu)) = "Sunday")    // ษ Domingo
					
					// MCVN - 04/12/2007
					If Ascan(_aFeriad,{|y| y[1] == _dEmiAtu}) <> 0 .Or. Ascan(_aNaoFatDip,{|y| y[1] == _dEmiAtu}) <> 0
						_dEmiAtu++
						If (AllTrim(cDow(_dEmiAtu)) = "Saturday")
							_dEmiAtu+=2
							If Val(cMes) <> Month(_dEmiAtu)
								_dEmiAtu-=2
							Endif
						Endif
						If Val(cMes) <> Month(_dEmiAtu)
							_dEmiAtu--
						Endif
					ElseIf (AllTrim(cDow(_dEmiAtu)) = "Saturday")
						_dEmiAtu+=2
						If Val(cMes) <> Month(_dEmiAtu)
							_dEmiAtu-=2
						Endif
					Else
						_dEmiAtu++
						If Val(cMes) <> Month(_dEmiAtu)
							_dEmiAtu--
						Endif
					Endif
				EndIf
				
				// Adiciona totais dos dias de cada coluna
				_nPos := Ascan(_aEmiPed,{|y| y[1] == _dEmiAtu})
				//		_aEmiPed[_nPos,1] += _dEmiAtu
				
				If _nPos > 0
					_aEmiPed[_nPos,2] += _nColPed
					_aEmiPed[_nPos,3] += _nLibPed
					_aEmiPed[_nPos,4] += _nFatPed
					_aEmiPed[_nPos,5] += _nEstPed
					_aEmiPed[_nPos,6] += _nCrePed
					_aEmiPed[_nPos,7] += _nOpePed
				Endif
					// Acumula totais para montar linha dos totais
					_nAcCol += _nColPed
					_nAcLib += _nLibPed
					_nAcFat += _nFatPed
					_nAcEst += _nEstPed
					_nAcCre += _nCrePed
					_nAcOpe += _nOpePed
			
				
				// Zera
				_nColPed:= _nLibPed := _nFatPed:= _nEstPed:= _nCrePed:= _nOpePed:= 0
				
			Else
	            //----------------------------------------------------------------------------------------
	            // Uso da condicao para tornar esta funcao um rotina mais generica e permiir maior uso.  
	            // JBS 15/06/2010  - Hoje ha a necessidade de trazer um total de um fornecedor  em  uma 
	            // Empresa e filial determinada na condicao vai codeblock com os fornecedores que eu quero. 
	            //----------------------------------------------------------------------------------------
	            //If QRY3->C9_FORNEC $ "000851/000847/051508"   
	            //    QRY3->( DbSkip())
	            //    Loop
	            //EndIf    
				// S๓ para pedidos liberados - vamos separar por area *** DE OUTROS MESES
				If Empty(QRY3->C5_PARCIAL) .and. ((QRY3->C9_BLEST = '02' .or. QRY3->C9_BLEST = '  ') .and. QRY3->C9_SALDO = 0 .and. Empty(QRY3->C9_BLCRED) .and. Empty(QRY3->C9_BLCRED2))
					// Televendas
					If (!Empty(QRY3->U7_CODVEN) .and. QRY3->C9_VEND <> '000204') .or. QRY3->C9_VEND $ '006684/000353/000352/000356/000357/000359'
						_nPVLTel += QRY3->C9_VALOR
					Else
						// Representantes
						_nPVLRep += QRY3->C9_VALOR
						// P๚blico
						If QRY3->C9_OPERADO $ cOper
							_nPVLPub += QRY3->C9_VALOR
						EndIf
						//Prefeitura
						If QRY3->C9_CLIENTE = '004303'
							_nPVLPre += QRY3->C9_VALOR
						EndIf
						// Particular
						_nPVLPar := (_nPVLRep - _nPVLPub - _nPVLPre)
					EndIf
					// Total
					_nPVLTot += QRY3->C9_VALOR
				EndIf
				
				QRY3->(DbSkip())
				
			EndIf
		EndDo
	Next nEmp
	//----------------------------------------------------------------------------------------
	// Aculumulas os valores diarios por empresas
	//----------------------------------------------------------------------------------------
	aAdd(_aAllEmiFat,_aEmiFat)
	aAdd(_aAllEmiPed,_aEmiPed)
	//----------------------------------------------------------------------------------------
	// Adiciona linha de totais
	//----------------------------------------------------------------------------------------
	Aadd(_aAcuFat   ,{"Acumulado",_nAcPar,_nAcPub,_nAcPre,_nAcRep,_nAcTel,_nAcTot,_nAcCol,_nAcLib,_nAcFat,_nAcEst,_nAcCre,_nAcOpe})
	Aadd(_aPedLib   ,{"PV Liberados",_nPVLPar,_nPVLPub,_nPVLPre,_nPVLRep,_nPVLTel,_nPVLTot})
	
	Aadd(_aNoDia    ,{"No Dia ",0,0,0,0,0,0})
	Aadd(_aDia      ,{"Dia "   ,0,0,0,0,0,0})
	
Next nId
//--------------------------------------------------------------------------------------------
// Soma os valores acumulados por empresa, em uma quarta dimensao
// para mostrar umm unico total
//--------------------------------------------------------------------------------------------
fSomaEmpresa()
//--------------------------------------------------------------------------------------------
// JBS 07/04/2010 Apura os valores sinteticos para a empresa HQ (04) na filial Matriz (01).
// Estes valores serใo impressos na ultima linha do relatorio com o titulo de 'HQ-JARINU'.
//--------------------------------------------------------------------------------------------
_aSintetico := fSintetico("040","01")
//--------------------------------------------------------------------------------------------
// JBS 07/04/2010 - Apura os valores sinteticos para o fornecedor Health Quality (051508).
// Vendidos na empresa HQ na filial CD.
// Estes valores serใo impressos na ultima linha do relatorio com o titulo de 'HQ-JARINU'.
//--------------------------------------------------------------------------------------------
// Comentado JBS 15/06/2010
//_aSinForn   := fSintetico("040","04")
//--------------------------------------------------------------------------------------------
// Soma os dois valores em uma unica array para imprimir na linha 'HQ-JARINU'.
//--------------------------------------------------------------------------------------------
//For nId := 1 to len(_aSintetico)
//	_aSintetico[nId] += _aSinForn[nId]
//Next    

// JBS 15/06/2010 - Buscar o volume faturado para os fornecedores abaixo, dentro da empresa 04/04


_aHQ_CD := fSintetico("040","04",{|| D2_FORNEC $ "000851/000847/051508"},; // Condicao para query 01
                                  {|| D2_FORNEC $ "000851/000847/051508"},; // Condicao para query 02
                                  {|| C9_FORNEC $ "000851/000847/051508"})  // Condicao para query 03
//--------------------------------------------------------------------------------------------
// Soma os dois valores em uma unica array para imprimir na linha 'HQ-JARINU'.
//--------------------------------------------------------------------------------------------
//For nId := 1 to len(_aSintetico)
//	_aSintetico[nId] += _aSinForn[nId]                                                                                             
//Next




Return

///////////////////////////
Static Function RptDetail()

Local lFaturas := .T.
//----------------------------------------------------------------------------------------
// Calcula dia util anterior a data atual
//----------------------------------------------------------------------------------------
Local _nDias := fDiaAnt()
Local nCol   := 0
Local nXy    := 0
Local y,xi,nId

// inicializa็ใo das variแveis
_cTitulo := "Faturamento Diแrio - " + MesExtenso(Val(cMes)) + "/" + cAno
/*
*                                                                                                   1                                                                                                   2                                                                                                   3
*         1         2         3         4         5         6         7         8         9         0         1         2         3         4         5         6         7         8         9         0         1         2         3         4         5         6         7         8         9         0         1         2         3         4         5         6
*1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
*Data                          Particular                      P๚blico                   Prefeitura               Representantes                   Televendas                        Total                    Acumulado
*DD/MM/AAAA                 99.999.999,99                99.999.999,99                99.999.999,99                99.999.999,99                99.999.999,99                99.999.999,99                99.999.999,99
*                                                                                                   1                                                                                                   2                                                                                                   3
*         1         2         3         4         5         6         7         8         9         0         1         2         3         4         5         6         7         8         9         0         1         2         3         4         5         6         7         8         9         0         1         2         3         4         5         6
*1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
*Data            Particular         P๚blico         Representantes        Televendas             Total         Acumulado                           PEDIDOS                                         Bloqueados                *
*                       (1)             (2)              (4)=1+2+3                (5)          (6)=4+5            diario        Colocados          Liberados       Faturados         Estoque          Credito   Pelo Operador*
*DD/MM/AAAA   99.999.999,99   99.999.999,99          99.999.999,99     99.999.999,99      9.999.999,99     99.999.999,99    99.999.999,99      99.999.999,99   99.999.999,99   99.999.999,99    99.999.999,99   99.999.999,99                      *
*/


//----------------------------------------------------------------------------------------------------------
//_cDesc1:= "Data               Particular           P๚blico     Representantes         Televendas             Total        Acumulado                           PEDIDOS                                       Bloqueados                "
//_cDesc2:= "                          (1)               (2)            (3)=1+2                (4)           (5)=3+4           diario        Colocados          Liberados      Faturados         Estoque         Credito   Pelo Operador"
//----------------------------------------------------------------------------------------------------------
_cDesc1:= "Data               Particular           P๚blico     Representantes         Televendas             Total        Acumulado" //                          PEDIDOS                                       Bloqueados                "
_cDesc2:= "                          (1)               (2)            (3)=1+2                (4)           (5)=3+4           diario" //       Colocados          Liberados      Faturados         Estoque         Credito   Pelo Operador"
//----------------------------------------------------------------------------------------------------------
_cDesc3:= "Data                                    PEDIDOS                                        Bloqueados                       "
_cDesc4:= "                   Colocados          Liberados          Faturados             Estoque           Credito   Pelo Operador"
//----------------------------------------------------------------------------------------------------------
Do While .T.
	//------------------------------------------------------------------------------------------------------
	_nSomRec := 0
	_nSomPag := 0
	_nFimRec := 0
	_nFimPag := 0
	_lUltDia := .T.
	_nTotDia := 0
	//------------------------------------------------------------------------------------------------------
	
	For nId := 1 to Len(_aAllEmiFat)
		
		SetRegua(Len(_aAllEmiFat[nId]))
		
		// Impressใo do relatoro
		_nDiasCom  := 0
		_nDiasSem  := 0
		_nAcu      := 0
		_lUltDia   := .T.
		
		For xi:=1 to Len(_aAllEmiFat[nId])
			
			IncRegua("Imprimindo: " + DtoC(_aAllEmiFat[nId][xi][1]))
			
			If li > 65
				li := Cabec(_cTitulo,_cDesc1,_cDesc2,nomeprog,tamanho) +1
			EndIf
			_nPos   := 0
			// Impressใo das colunas
			If lValor
				@ li,001 PSay Left(dtoc(_aAllEmifat[nId][xi][1]),2)+"-"+DiaSemana(_aAllEmifat[nId][xi][1])
				If lFaturas
					@ li,016 psay _aAllEmifat[nId][xi][2] Picture "@E 99,999,999.99"
					@ li,032 PSay _aAllEmifat[nId][xi][3] Picture "@E 99,999,999.99"
					//@ li,046 PSay _aEmiFat[xi,4] Picture "@E 99,999,999.99"
					@ li,053 PSay _aAllEmifat[nId][xi][5] Picture "@E 99,999,999.99"
					@ li,071 PSay _aAllEmifat[nId][xi][6] Picture "@E 99,999,999.99"
					@ li,090 PSay _aAllEmifat[nId][xi][7] Picture "@E 99,999,999.99"
					@ li,107 PSay Iif(_aAllEmifat[nId][xi][7] == 0,0,_nAcu += _aAllEmifat[nId][xi][7]) Picture "@E 99,999,999.99"
				Else
					@ li,016 psay _aAllEmiPed[nId][xi][2] Picture "@E 99,999,999.99"
					@ li,032 PSay _aAllEmiPed[nId][xi][3] Picture "@E 99,999,999.99"
					@ li,053 PSay _aAllEmiPed[nId][xi][4] Picture "@E 99,999,999.99"
					@ li,071 PSay _aAllEmiPed[nId][xi][5] Picture "@E 99,999,999.99"
					@ li,090 PSay _aAllEmiPed[nId][xi][6] Picture "@E 99,999,999.99"
					@ li,107 PSay _aAllEmiPed[nId][xi][7] Picture "@E 99,999,999.99"
				EndIf
				li++
			Else
				@ li,001 PSay Left(dtoc(_aAllEmifat[nId][xi][1]),2)+"-"+DiaSemana(_aAllEmifat[nId][xi][1])
				If lFaturas
					@ li,016 psay Round((_aAllEmifat[nId][xi][2]/_aMeta[nId][METPAR])*100,2) Picture "@E 99,999,999.99"
					@ li,029 PSay '%'
					@ li,032 PSay Round((_aAllEmifat[nId][xi][3]/_aMeta[nId][METPUB])*100,2) Picture "@E 99,999,999.99"
					@ li,045 PSay '%'
					//@ li,046 PSay _aEmiFat[xi,4] Picture "@E 99,999,999.99"
					@ li,053 PSay Round((_aAllEmifat[nId][xi][5]/_aMeta[nId][METREP])*100,2) Picture "@E 99,999,999.99"
					@ li,066 PSay '%'
					@ li,071 PSay Round((_aAllEmifat[nId][xi][6]/_aMeta[nId][METTEL])*100,2) Picture "@E 99,999,999.99"
					@ li,084 PSay '%'
					@ li,090 PSay Round((_aAllEmifat[nId][xi][7]/_aMeta[nId][METDIP])*100,2) Picture "@E 99,999,999.99"
					@ li,103 PSay '%'
					@ li,107 PSay Round((Iif(_aAllEmifat[nId][xi][7]==0,0,_nAcu += _aAllEmifat[nId][xi][7])/_aMeta[nId][METDIP])*100,2) Picture "@E 99,999,999.99"
					@ li,120 PSay '%'
				Else
					@ li,016 psay Round((_aAllEmifat[nId][xi][2]/(_aMeta[nId][METDIP]/Len(_aAllEmifat[nId])))*100,2) Picture "@E 99,999,999.99"
					@ li,029 PSay '%'
					@ li,032 PSay Round((_aAllEmiPed[nId][xi][3]/(_aMeta[nId][METDIP]/Len(_aAllEmifat[nId])))*100,2) Picture "@E 99,999,999.99"
					@ li,045 PSay '%'
					@ li,053 PSay Round((_aAllEmiPed[nId][xi][4]/(_aMeta[nId][METDIP]/Len(_aAllEmifat[nId])))*100,2) Picture "@E 99,999,999.99"
					@ li,066 PSay '%'
					@ li,071 PSay Round((_aAllEmiPed[nId][xi][5]/_aMeta[nId][METDIP])*100,2) Picture "@E 99,999,999.99"
					@ li,084 PSay '%'
					@ li,090 PSay Round((_aAllEmiPed[nId][xi][6]/_aMeta[nId][METDIP])*100,2) Picture "@E 99,999,999.99"
					@ li,103 PSay '%'
					@ li,107 PSay Round((_aAllEmiPed[nId][xi][7]/_aMeta[nId][METDIP])*100,2) Picture "@E 99,999,999.99"
					@ li,120 PSay '%'
				EndIf
				li++
			Endif
			// Calculando total do dia Faturado + pedidos - MCVN 04/12/2007
			If _aAllEmiFat[nId][xi][1] == DDatabase
				
				_aNoDia[nId,1] := "No Dia " + DtoC(_aAllEmiFat[nId][xi][1])
				_aNoDia[len(_aNoDia),1] := "No Dia " + DtoC(_aAllEmiFat[nId][xi][1])
				
				For y:=2 to 7
					_aNoDia[nId,y] += _aAllEmiFat[nId][xi][y]
					_aNoDia[len(_aNoDia),y] += _aAllEmiFat[nId][xi][y]
				Next
				
			ElseIf _aAllEmiFat[nId][xi][1] = DDatabase - _nDias .and. _nDias > 0
				//---------------------------------------------------------------------------------------------
				// JBS - 11/03/2010 - Calcula dia Util Anterior a Data Atual
				//---------------------------------------------------------------------------------------------
				_aDia[nId,1]        := "Dia " + DtoC(_aAllEmiFat[nId][xi][1])
				_aDia[len(_aDia),1] := "Dia " + DtoC(_aAllEmiFat[nId][xi][1])
				
				For y:=2 to 7
					_aDia[nId,y]        += _aAllEmiFat[nId][xi][y]
					_aDia[len(_aDia),y] += _aAllEmiFat[nId][xi][y]
				Next
				
			EndIf
			
			If _aAllEmiFat[nId][xi][7] == 0 .and. _aAllEmiFat[nId][xi][1] >= Date()
				_nDiasSem++
			Else
				_nDiasCom++
			EndIf
			
			If _lUltDia .and. (xi = Len(_aAllEmiFat[nId]) .or. _aAllEmiFat[nId][xi+1][2] = 0)  // Eriberto 18/04/2007
				_cDiaTot += _aAllEmiFat[nId][xi][1]
				_nTotDia += _aAllEmiFat[nId][xi][7]
				_lUltDia := .f.
			EndIf
			
		Next xi
		//-------------------------------------------------------------------
		// Impressao da linha de totais
		//-------------------------------------------------------------------
		@ li,000 psay Replicate("-",132)
		li++
		
		If lValor
			@ li,001 PSay _aAcuFat[nId,01] + ' ' + Substr(aEmpresa[nId][01][01],2,1) + '-' + Substr(aEmpresa[nId][01][02],2,1)
			If lFaturas
				@ li,016 psay _aAcuFat[nId,02] Picture "@E 99,999,999.99"
				@ li,032 PSay _aAcuFat[nId,03] Picture "@E 99,999,999.99"
				//@ li,046 PSay _aAcuFat[nId,04] Picture "@E 99,999,999.99"
				@ li,053 PSay _aAcuFat[nId,05] Picture "@E 99,999,999.99"
				@ li,071 PSay _aAcuFat[nId,06] Picture "@E 99,999,999.99"
				@ li,090 PSay _aAcuFat[nId,07] Picture "@E 99,999,999.99"
			Else
				@ li,016 psay _aAcuFat[nId,08] Picture "@E 99,999,999.99"
				@ li,032 PSay _aAcuFat[nId,09] Picture "@E 99,999,999.99"
				@ li,053 PSay _aAcuFat[nId,10] Picture "@E 99,999,999.99"
				@ li,071 PSay _aAcuFat[nId,11] Picture "@E 99,999,999.99"
				@ li,090 PSay _aAcuFat[nId,12] Picture "@E 99,999,999.99"
				@ li,107 PSay _aAcuFat[nId,13] Picture "@E 99,999,999.99"
			EndIf
		Else
			@ li,001 PSay _aAcuFat[1,1]
			If lFaturas
				@ li,016 psay Round((_aAcuFat[nId,2]/_aMeta[nId][METPAR])*100,2)  Picture "@E 99,999,999.99"
				@ li,029 PSay '%'
				@ li,032 PSay Round((_aAcuFat[nId,3]/_aMeta[nId][METPUB])*100,2)  Picture "@E 99,999,999.99"
				@ li,045 PSay '%'
				//@ li,046 PSay _aAcuFat[1,4] Picture "@E 99,999,999.99"
				@ li,053 PSay Round((_aAcuFat[nId,5]/_aMeta[nId][METREP])*100,2)  Picture "@E 99,999,999.99"
				@ li,066 PSay '%'
				@ li,071 PSay Round((_aAcuFat[nId,6]/_aMeta[nId][METTEL])*100,2)  Picture "@E 99,999,999.99"
				@ li,084 PSay '%'
				@ li,090 PSay Round((_aAcuFat[nId,7]/_aMeta[nId][METDIP])*100,2)  Picture "@E 99,999,999.99"
				@ li,103 PSay '%'
			Else
				@ li,016 psay Round((_aAcuFat[nId,8]/_aMeta[nId][METDIP])*100,2)  Picture "@E 99,999,999.99"
				@ li,029 PSay '%'
				@ li,032 PSay Round((_aAcuFat[nId,9]/(nMetDip/Len(_aAllEmiFat[nId])))*100,2)  Picture "@E 99,999,999.99"
				@ li,045 PSay '%'
				@ li,053 PSay Round((_aAcuFat[nId,10]/(nMetDip/Len(_aAllEmiFat[nId])))*100,2) Picture "@E 99,999,999.99"
				@ li,066 PSay '%'
				@ li,071 PSay Round((_aAcuFat[nId,11]/nMetDip)*100,2) Picture "@E 99,999,999.99"
				@ li,084 PSay '%'
				@ li,090 PSay Round((_aAcuFat[nId,12]/nMetDip)*100,2) Picture "@E 99,999,999.99"
				@ li,103 PSay '%'
				@ li,107 PSay Round((_aAcuFat[nId,13]/nMetDip)*100,2) Picture "@E 99,999,999.99"
				@ li,120 PSay '%'
			EndIf
		EndIf
		li++
		@ li,000 psay Replicate("-",132)
		li++
	Next nId
	//------------------------------------------------------------------------------------------------------
	For nId := len(_aAcuFat) to len(_aAcuFat)
		If lValor
			//@ li,000 psay Replicate("-",132)
			//li++
			@ li,001 PSay _aAcuFat[nId,01] + ' Geral'
			If lFaturas
				@ li,016 psay _aAcuFat[nId,02] Picture "@E 99,999,999.99"
				@ li,032 PSay _aAcuFat[nId,03] Picture "@E 99,999,999.99"
				//@ li,046 PSay _aAcuFat[nId,4] Picture "@E 99,999,999.99"
				@ li,053 PSay _aAcuFat[nId,05] Picture "@E 99,999,999.99"
				@ li,071 PSay _aAcuFat[nId,06] Picture "@E 99,999,999.99"
				@ li,090 PSay _aAcuFat[nId,07] Picture "@E 99,999,999.99"
			else
				@ li,016 psay _aAcuFat[nId,08] Picture "@E 99,999,999.99"
				@ li,032 PSay _aAcuFat[nId,09] Picture "@E 99,999,999.99"
				@ li,053 PSay _aAcuFat[nId,10] Picture "@E 99,999,999.99"
				@ li,071 PSay _aAcuFat[nId,11] Picture "@E 99,999,999.99"
				@ li,090 PSay _aAcuFat[nId,12] Picture "@E 99,999,999.99"
				@ li,106 PSay _aAcuFat[nId,13] Picture "@E 99,999,999.99"
			EndIf
			
			li++
			@ li,000 psay Replicate("-",132)
			li++
			@ li,001 PSay "Media Diแria("+AllTrim(Str(_nDiasCom,2))+')'
			
			If lFaturas
				@ li,017 PSay _aAcuFat[nId,2]/_nDiasCom Picture "@E 9,999,999.99"
				@ li,033 PSay _aAcuFat[nId,3]/_nDiasCom Picture "@E 9,999,999.99"
				//@ li,046 PSay _aAcuFat[nId,4]/_nDiasCom Picture "@E 99,999,999.99"
				@ li,053 PSay _aAcuFat[nId,5]/_nDiasCom Picture "@E 99,999,999.99"
				@ li,071 PSay _aAcuFat[nId,6]/_nDiasCom Picture "@E 99,999,999.99"
				@ li,090 PSay _aAcuFat[nId,7]/_nDiasCom Picture "@E 99,999,999.99"
			Else
				@ li,017 PSay _aAcuFat[nId,8]/_nDiasCom Picture "@E 9,999,999.99"
			EndIf
			
			li++
			@ li,000 psay Replicate("-",132)
			li++
			@ li,001 PSay "Meta Diแria("+AllTrim(Str(_nDiasSem,2))+')'
			
			If lFaturas
				@ li,016 psay (_aMeta[nId][METPAR] - _aAcuFat[nId,2])/_nDiasSem Picture "@E 99,999,999.99"
				@ li,032 PSay (_aMeta[nId][METPUB] - _aAcuFat[nId,3])/_nDiasSem Picture "@E 99,999,999.99"
				@ li,053 PSay (_aMeta[nId][METREP] - _aAcuFat[nId,5])/_nDiasSem Picture "@E 99,999,999.99"
				@ li,071 PSay (_aMeta[nId][METTEL] - _aAcuFat[nId,6])/_nDiasSem Picture "@E 99,999,999.99"
				@ li,090 PSay ((_aMeta[nId][METTEL] + _aMeta[nId][METREP]) -_aAcuFat[nId,7])/_nDiasSem Picture "@E 99,999,999.99"
			Else
				@ li,016 psay ((_aMeta[nId][METTEL] + _aMeta[nId][METREP]) -_aAcuFat[nId,8])/_nDiasSem Picture "@E 99,999,999.99"
			EndIf
			
			li++
			@ li,000 psay Replicate("-",132)
			li++
			@ li,001 PSay "Meta Mensal("+Str(Len(_aAllEmifat[nId-1]),2)+')' // O nId, esta posicionado para uma dimensao que esta array nao possui, por isto, o decremento de 1
			
			If lFaturas
				@ li,016 psay _aMeta[nId][METPAR] Picture "@E 99,999,999.99"
				@ li,032 PSay _aMeta[nId][METPUB] Picture "@E 99,999,999.99"
				@ li,053 PSay _aMeta[nId][METREP] Picture "@E 99,999,999.99"
				@ li,071 PSay _aMeta[nId][METTEL] Picture "@E 99,999,999.99"
				@ li,090 PSay _aMeta[nId][METTEL] + _aMeta[nId][METREP] Picture "@E 99,999,999.99"
			Else
				@ li,016 psay _aMeta[nId][METTEL] + _aMeta[nId][METREP] Picture "@E 99,999,999.99"
			EndIf
			
			li++
			@ li,000 psay Replicate("-",132)
			li++
			@ li,001 PSay "Falta para Meta"
			
			If lFaturas
				@ li,016 psay _aMeta[nId][METPAR] - _aAcuFat[nId,2] Picture "@E 99,999,999.99"
				@ li,032 PSay _aMeta[nId][METPUB] - _aAcuFat[nId,3] Picture "@E 99,999,999.99"
				@ li,053 PSay _aMeta[nId][METREP] - _aAcuFat[nId,5] Picture "@E 99,999,999.99"
				@ li,071 PSay _aMeta[nId][METTEL] - _aAcuFat[nId,6] Picture "@E 99,999,999.99"
				@ li,090 PSay _aMeta[nId][METTEL] + _aMeta[nId][METREP] - _aAcuFat[nId,7] Picture "@E 99,999,999.99"
			else
				@ li,016 psay _aMeta[nId][METTEL] + _aMeta[nId][METREP] - _aAcuFat[nId,8] Picture "@E 99,999,999.99"
			EndIf
			li++
			@ li,000 psay Replicate("-",132)
			li++
			@ li,001 PSay "% Atingido"
			If lFaturas
				@ li,016 psay Round(_aAcuFat[nId,2]/_aMeta[nId][METPAR]*100,2) Picture "@E 99,999,999.99"
				@ li,029 PSay  "%"
				@ li,032 PSay Round(_aAcuFat[nId,3]/_aMeta[nId][METPUB]*100,2) Picture "@E 99,999,999.99"
				@ li,045 PSay  "%"
				@ li,053 PSay Round(_aAcuFat[nId,5]/_aMeta[nId][METREP]*100,2) Picture "@E 99,999,999.99"
				@ li,066 PSay  "%"
				@ li,071 PSay Round(_aAcuFat[nId,6]/_aMeta[nId][METTEL]*100,2) Picture "@E 99,999,999.99"
				@ li,084 PSay  "%"
				@ li,090 PSay Round(_aAcuFat[nId,7]/(_aMeta[nId][METTEL] + _aMeta[nId][METREP])*100,2) Picture "@E 99,999,999.99"
				@ li,103 PSay  "%"
			Else
				@ li,016 psay Round(_aAcuFat[nId,8]/(_aMeta[nId][METTEL] + _aMeta[nId][METREP])*100,2) Picture "@E 99,999,999.99"
				@ li,029 PSay  "%"
			EndIf
			
			li++
			@ li,000 psay Replicate("-",132)
			li++
			@ li,001 PSay "Participa็ใo"
			
			If lFaturas
				@ li,016 psay Round(_aAcuFat[nId,2]/_aAcuFat[nId,7]*100,2) Picture "@E 99,999,999.99"
				@ li,029 PSay  "%"
				@ li,032 PSay Round(_aAcuFat[nId,3]/_aAcuFat[nId,7]*100,2) Picture "@E 99,999,999.99"
				@ li,045 PSay  "%"
				//@ li,046 PSay Round(_aAcuFat[nId,4]/_aAcuFat[nId,7]*100,2) Picture "@E 99,999,999.99"
				//@ li,059 PSay  "%"
				@ li,053 PSay Round(_aAcuFat[nId,5]/_aAcuFat[nId,7]*100,2) Picture "@E 99,999,999.99"
				@ li,066 PSay  "%"
				@ li,071 PSay Round(_aAcuFat[nId,6]/_aAcuFat[nId,7]*100,2) Picture "@E 99,999,999.99"
				@ li,084 PSay  "%"
				@ li,097 PSay "100.00%"
				
				nCol := 107
				For nXy :=1 to len(aEmpresa)
					@ li,nCol PSay Substr(aEmpresa[nXy][01][01],2,1) + '-' + Substr(aEmpresa[nXy][01][02],2,1) + Transform(Round(_aAcuFat[nXy,7]/_aAcuFat[nId,7]*100,2),"@E 999.99")+"%"  // Empresa 01 / Acumulado Geral * 100 -> Calcaula Percentual de participacao da empresa
					nCol += 12
				Next nXy
			Else
				nCol := 016
				For nXy := 1 to len(aEmpresa)
					@ li,nCol PSay Substr(aEmpresa[nXy][01][01],2,1) + '-' + Substr(aEmpresa[nXy][01][02],2,1) + Transform(Round(_aAcuFat[nXy,8]/_aAcuFat[nId,8]*100,2),"@E 999.99")+"%"  // Empresa 01 / Acumulado Geral * 100 -> Calcaula Percentual de participacao da empresa
					nCol += 12
				Next nXy
				
				//@ li,120 PSay "4-4 "+ Transform(Round(_aAcuFat[2,7]/_aAcuFat[nId,7]*100,2),"@E 999.99")+"%"  // Empresa 02 / Acumulado Geral * 100 -> Calcaula Percentual de participacao da empresa
				
			EndIf
			li++
			// @ li,000 psay Replicate("-",132)
			// li++
			If Val(cMes) == Month(DDataBase) .and. lFaturas
				
				@ li,000 psay Replicate("=",132)
				li++
				
				@ li,001 PSay _aDia[nId,1]
				If lFaturas
					@ li,016 psay _aDia[nId,2] Picture "@E 99,999,999.99"
					@ li,032 PSay _aDia[nId,3] Picture "@E 99,999,999.99"
					//@ li,046 PSay _aPedLib[nId,4] Picture "@E 99,999,999.99"
					@ li,053 PSay _aDia[nId,5] Picture "@E 99,999,999.99"
					@ li,071 PSay _aDia[nId,6] Picture "@E 99,999,999.99"
					@ li,090 PSay _aDia[nId,7] Picture "@E 99,999,999.99"
					//@ li,107 PSay _nTotDia            Picture "@E 99,999,999.99"
					
					// MCVN 15/01/2009
					//@ li,106 PSay "Total "+DtoC(_cDiaTot)+": "+ Alltrim(Transform(_NoDia[1,7],"@E 99,999,999.99"))
				EndIf
				
				li++
				@ li,000 psay Replicate("-",132)
				li++
				
				@ li,001 PSay _aPedLib[nId,1]
				If lFaturas
					@ li,016 psay _aPedLib[nId,2] Picture "@E 99,999,999.99"
					@ li,032 PSay _aPedLib[nId,3] Picture "@E 99,999,999.99"
					//@ li,046 PSay _aPedLib[nId,4] Picture "@E 99,999,999.99"
					@ li,053 PSay _aPedLib[nId,5] Picture "@E 99,999,999.99"
					@ li,071 PSay _aPedLib[nId,6] Picture "@E 99,999,999.99"
					@ li,090 PSay _aPedLib[nId,7] Picture "@E 99,999,999.99"
					//@ li,106 PSay "Total "+DtoC(_cDiaTot)+": "+ Alltrim(Transform(_nTotDia+_aPedLib[1,7],"@E 99,999,999.99"))
				EndIf
				
				li++
				//@ li,000 psay Replicate("-",132)
				//li++
				
				@ li,001 PSay _aNoDia[nId,1]
				If lFaturas
					@ li,016 psay _aPedLib[nId,2]+_aNoDia[nId,2] Picture "@E 99,999,999.99"
					@ li,032 PSay _aPedLib[nId,3]+_aNoDia[nId,3] Picture "@E 99,999,999.99"
					//@ li,046 PSay _aPedLib[nId,4] Picture "@E 99,999,999.99"
					@ li,053 PSay _aPedLib[nId,5]+_aNoDia[nId,5] Picture "@E 99,999,999.99"
					@ li,071 PSay _aPedLib[nId,6]+_aNoDia[nId,6] Picture "@E 99,999,999.99"
					@ li,090 PSay _aPedLib[nId,7]+_aNoDia[nId,7] Picture "@E 99,999,999.99"
					@ li,107 PSay _aPedLib[nId,7]+_aAcuFat[nId,7] Picture "@E 99,999,999.99"   // MCVN 15/01/2009
					//@ li,106 PSay "Total "+DtoC(_cDiaTot)+": "+ Alltrim(Transform(_NoDia[1,7],"@E 99,999,999.99"))
				EndIf
				//
			    li++
				If !Upper(_cDipUsr) $ cUserAut 
				    @ li,000 psay Replicate("-",132)
				    li++
				EndIf    
				//
			Else
				//
				@ li,000 psay Replicate("=",132)
				li++
				//
			Endif
			//----------------------------------------------------------------------------------------
			// Imprime o acumulado Sintetico da filial 01 da empresa 04  - JBS 07/04/2010
			//----------------------------------------------------------------------------------------
			If lValor .and. Upper(_cDipUsr) $ cUserAut 
				@ li,000 psay Replicate("*",132)
				li++
				@ li,001 PSay 'HQ-JARINU'
				//
				If lFaturas
					@ li,016 psay _aSintetico[1] Picture "@E 99,999,999.99"
					@ li,032 PSay _aSintetico[2] Picture "@E 99,999,999.99"
					//@ li,032 PSay _aSintetico[3] Picture "@E 99,999,999.99"    // JBS 08/04/2010 Seguindo o exemplo, esta informa็ใo nใo ้ impressa mesmo
					@ li,053 PSay _aSintetico[4] Picture "@E 99,999,999.99"
					@ li,071 PSay _aSintetico[5] Picture "@E 99,999,999.99"
					@ li,090 PSay _aSintetico[6] Picture "@E 99,999,999.99"
				Else                                                            // JBS 14/05/2010
					@ li,016 psay _aSintetico[07] Picture "@E 99,999,999.99"    // JBS 14/05/2010
					@ li,032 PSay _aSintetico[08] Picture "@E 99,999,999.99"    // JBS 14/05/2010
					@ li,053 PSay _aSintetico[09] Picture "@E 99,999,999.99"    // JBS 14/05/2010
					@ li,071 PSay _aSintetico[10] Picture "@E 99,999,999.99"    // JBS 14/05/2010
					@ li,090 PSay _aSintetico[11] Picture "@E 99,999,999.99"    // JBS 14/05/2010
					@ li,107 PSay _aSintetico[12] Picture "@E 99,999,999.99"    // JBS 14/05/2010
				EndIf
				li++ 
			ElseIf lValor                              // JBS 28/07/2010
				@ li,000 psay Replicate("*",132)      // JBS 28/07/2010
				li++                                  // JBS 28/07/2010
			EndIf
            //------------------------------------------------------------------------------------------------------------------------------         
            // JBS 16/06/2010 - Impressao do sintetico de vendas de produtos dos fornecedores '000851', '000847' e '051508'
            //                  de acordo com os paramentros informados pelo usuario.
            //------------------------------------------------------------------------------------------------------------------------------ 
			If lValor             
		    /*
				@ li,001 PSay 'Prod HQ no CD'
				//
				If lFaturas
					@ li,016 psay _aHQ_CD[1] Picture "@E 99,999,999.99"
					@ li,032 PSay _aHQ_CD[2] Picture "@E 99,999,999.99"
				  //@ li,032 PSay _aHQ_CD[3] Picture "@E 99,999,999.99"    
					@ li,053 PSay _aHQ_CD[4] Picture "@E 99,999,999.99"
					@ li,071 PSay _aHQ_CD[5] Picture "@E 99,999,999.99"
					@ li,090 PSay _aHQ_CD[6] Picture "@E 99,999,999.99"
					If Upper(_cDipUsr) $ cUserAut
						@ li,107 PSay _aHQ_CD[6] + _aSintetico[6] + _aSintetico[8]Picture "@E 99,999,999.99"
					EndIf
				Else                                                        
					@ li,016 psay _aHQ_CD[07] Picture "@E 99,999,999.99"    
					@ li,032 PSay _aHQ_CD[08] Picture "@E 99,999,999.99"    
					@ li,053 PSay _aHQ_CD[09] Picture "@E 99,999,999.99"    
					@ li,071 PSay _aHQ_CD[10] Picture "@E 99,999,999.99"    
					@ li,090 PSay _aHQ_CD[11] Picture "@E 99,999,999.99"    
					@ li,107 PSay _aHQ_CD[12] Picture "@E 99,999,999.99"    
				EndIf */
				li++                                  // JBS 28/07/2010
				@ li,000 psay Replicate("*",132)      // JBS 28/07/2010
				li++                                  // JBS 28/07/2010
	        EndIf

		Else
			
			@ li,000 psay Replicate("-",132)
			li++
			@ li,001 PSay _aAcuFat[nId,1]
			
			If lFaturas
				@ li,016 psay Round((_aAcuFat[nId,2]/_aMeta[nId][METPAR])*100,2)  Picture "@E 99,999,999.99"
				@ li,029 PSay '%'
				@ li,032 PSay Round((_aAcuFat[nId,3]/_aMeta[nId][METPUB])*100,2)  Picture "@E 99,999,999.99"
				@ li,045 PSay '%'
				//@ li,046 PSay _aAcuFat[nId,4] Picture "@E 99,999,999.99"
				@ li,053 PSay Round((_aAcuFat[nId,5]/_aMeta[nId][METREP])*100,2)  Picture "@E 99,999,999.99"
				@ li,066 PSay '%'
				@ li,071 PSay Round((_aAcuFat[nId,6]/_aMeta[nId][METTEL])*100,2)  Picture "@E 99,999,999.99"
				@ li,084 PSay '%'
				@ li,090 PSay Round((_aAcuFat[nId,7]/_aMeta[nId][METDIP])*100,2)  Picture "@E 99,999,999.99"
				@ li,103 PSay '%'
			Else
				@ li,016 psay Round((_aAcuFat[nId,8]/_aMeta[nId][METDIP])*100,2)  Picture "@E 99,999,999.99"
				@ li,029 PSay '%'
				@ li,032 PSay Round((_aAcuFat[nId,9]/(_aMeta[nId][METDIP]/Len(_aAllEmiFat[nId-1])))*100,2)  Picture "@E 99,999,999.99"
				@ li,045 PSay '%'
				@ li,053 PSay Round((_aAcuFat[nId,10]/(_aMeta[nId][METDIP]/Len(_aAllEmiFat[nId-1])))*100,2) Picture "@E 99,999,999.99"
				@ li,066 PSay '%'
				@ li,071 PSay Round((_aAcuFat[nId,11]/_aMeta[nId][METDIP])*100,2) Picture "@E 99,999,999.99"
				@ li,084 PSay '%'
				@ li,090 PSay Round((_aAcuFat[nId,12]/_aMeta[nId][METDIP])*100,2) Picture "@E 99,999,999.99"
				@ li,103 PSay '%'
				@ li,107 PSay Round((_aAcuFat[nId,13]/_aMeta[nId][METDIP])*100,2) Picture "@E 99,999,999.99"
				@ li,120 PSay '%'
			EndIf
			
			li++
			@ li,000 psay Replicate("-",132)
			li++
			@ li,001 PSay "Media Diแria("+AllTrim(Str(_nDiasCom,2))+')'
			
			If lFaturas
				@ li,017 PSay Round(((_aAcuFat[nId,2]/_nDiasCom)/_aMeta[nId][METPAR])*100,2) Picture "@E 9,999,999.99"
				@ li,030 PSay '%'
				@ li,032 PSay Round(((_aAcuFat[nId,3]/_nDiasCom)/_aMeta[nId][METPUB])*100,2) Picture "@E 9,999,999.99"
				@ li,045 PSay '%'
				//@ li,046 PSay _aAcuFat[nId,4]/_nDiasCom Picture "@E 99,999,999.99"
				@ li,053 PSay Round(((_aAcuFat[nId,5]/_nDiasCom)/_aMeta[nId][METREP])*100,2) Picture "@E 99,999,999.99"
				@ li,066 PSay '%'
				@ li,071 PSay Round(((_aAcuFat[nId,6]/_nDiasCom)/_aMeta[nId][METTEL])*100,2) Picture "@E 99,999,999.99"
				@ li,084 PSay '%'
				@ li,090 PSay Round(((_aAcuFat[nId,7]/_nDiasCom)/_aMeta[nId][METDIP])*100,2) Picture "@E 99,999,999.99"
				@ li,103 PSay '%'
			Else
				@ li,017 psay Round(((_aAcuFat[nId,8]/_nDiasCom)/(_aMeta[nId][METDIP]/Len(_aAllEmiFat[nId-1])))*100,2) Picture "@E 99,999,999.99"
				@ li,030 PSay '%'
			EndIf
			
			li++
			@ li,000 psay Replicate("-",132)
			li++
			@ li,001 PSay "Meta Diแria("+AllTrim(Str(_nDiasSem,2))+')'
			
			If lFaturas
				@ li,016 psay Round((((_aMeta[nId][METPAR] - _aAcuFat[nId,2])/_nDiasSem)/_aMeta[nId][METPAR])*100,2) Picture "@E 99,999,999.99"
				@ li,029 PSay '%'
				@ li,032 PSay Round((((_aMeta[nId][METPUB] - _aAcuFat[nId,3])/_nDiasSem)/_aMeta[nId][METPUB])*100,2) Picture "@E 99,999,999.99"
				@ li,045 PSay '%'
				@ li,053 PSay Round((((_aMeta[nId][METREP]- _aAcuFat[nId,5])/_nDiasSem)/_aMeta[nId][METREP])*100,2) Picture "@E 99,999,999.99"
				@ li,066 PSay '%'
				@ li,071 PSay Round((((_aMeta[nId][METTEL] - _aAcuFat[nId,6])/_nDiasSem)/_aMeta[nId][METTEL])*100,2) Picture "@E 99,999,999.99"
				@ li,084 PSay '%'
				@ li,090 PSay Round(((((_aMeta[nId][METDIP])-_aAcuFat[nId,7])/_nDiasSem)/_aMeta[nId][METDIP])*100,2) Picture "@E 99,999,999.99"
				@ li,103 PSay '%'
			Else
				@ li,016 PSay Round(((((_aMeta[nId][METDIP])-_aAcuFat[nId,8])/_nDiasSem)/(_aMeta[nId][METDIP]/Len(_aAllEmiFat[nId-1])))*100,2) Picture "@E 99,999,999.99"
				@ li,029 PSay '%'
			EndIf
			
			li++
			@ li,000 psay Replicate("-",132)
			li++
			@ li,001 PSay "Meta Mensal("+Str(Len(_aAllEmiFat[nId-1]),2)+')'
			
			If lFaturas
				@ li,016 psay 100 Picture "@E 99,999,999.99"
				@ li,029 PSay  "%"
				@ li,032 PSay 100 Picture "@E 99,999,999.99"
				@ li,045 PSay  "%"
				@ li,053 PSay 100 Picture "@E 99,999,999.99"
				@ li,066 PSay  "%"
				@ li,071 PSay 100 Picture "@E 99,999,999.99"
				@ li,084 PSay  "%"
				@ li,090 PSay 100 Picture "@E 99,999,999.99"
				@ li,103 PSay  "%"
			EndIf
			
			li++
			@ li,000 psay Replicate("-",132)
			li++
			@ li,001 PSay "Falta para Meta"
			
			If lFaturas
				@ li,016 psay Round(((_aMeta[nId][METPAR] - _aAcuFat[nId,2])/_aMeta[nId][METPAR])*100,2) Picture "@E 99,999,999.99"
				@ li,029 PSay  "%"
				@ li,032 PSay Round(((_aMeta[nId][METPUB] - _aAcuFat[nId,3])/_aMeta[nId][METPUB])*100,2) Picture "@E 99,999,999.99"
				@ li,045 PSay  "%"
				@ li,053 PSay Round(((_aMeta[nId][METREP] - _aAcuFat[nId,5])/_aMeta[nId][METREP])*100,2) Picture "@E 99,999,999.99"
				@ li,066 PSay  "%"
				@ li,071 PSay Round(((_aMeta[nId][METTEL] - _aAcuFat[nId,6])/_aMeta[nId][METTEL])*100,2) Picture "@E 99,999,999.99"
				@ li,084 PSay  "%"
				@ li,090 PSay Round(((_aMeta[nId][METDIP] - _aAcuFat[nId,7])/_aMeta[nId][METDIP])*100,2) Picture "@E 99,999,999.99"
				@ li,103 PSay  "%"
			Else
				@ li,016 psay Round(((_aMeta[nId][METDIP] - _aAcuFat[nId,8])/(_aMeta[nId][METDIP]/_nDiasCom))*100,2) Picture "@E 99,999,999.99"
				@ li,029 PSay  "%"
			EndIf
			
			li++
			@ li,000 psay Replicate("-",132)
			li++
			@ li,001 PSay "% Atingido"
			
			If lFaturas
				@ li,016 psay Round(_aAcuFat[nId,2]/_aMeta[nId][METPAR]*100,2) Picture "@E 99,999,999.99"
				@ li,029 PSay  "%"
				@ li,032 PSay Round(_aAcuFat[nId,3]/_aMeta[nId][METPUB]*100,2) Picture "@E 99,999,999.99"
				@ li,045 PSay  "%"
				@ li,053 PSay Round(_aAcuFat[nId,5]/_aMeta[nId][METREP]*100,2) Picture "@E 99,999,999.99"
				@ li,066 PSay  "%"
				@ li,071 PSay Round(_aAcuFat[nId,6]/_aMeta[nId][METTEL]*100,2) Picture "@E 99,999,999.99"
				@ li,084 PSay  "%"
				@ li,090 PSay Round(_aAcuFat[nId,7]/(_aMeta[nId][METDIP])*100,2) Picture "@E 99,999,999.99"
				@ li,103 PSay  "%"
			Else
				@ li,016 psay Round(_aAcuFat[nId,8]/(_aMeta[nId][METDIP])*100,2) Picture "@E 99,999,999.99"
				@ li,029 PSay  "%"
			EndIf
			
			li++
			@ li,000 psay Replicate("-",132)
			li++
			@ li,001 PSay "Participa็ใo"
			
			If lFaturas
				@ li,016 psay Round(_aAcuFat[nId,2]/_aAcuFat[nId,7]*100,2) Picture "@E 99,999,999.99"
				@ li,029 PSay  "%"
				@ li,032 PSay Round(_aAcuFat[nId,3]/_aAcuFat[nId,7]*100,2) Picture "@E 99,999,999.99"
				@ li,045 PSay  "%"
				//@ li,046 PSay Round(_aAcuFat[nId,4]/_aAcuFat[nId,7]*100,2) Picture "@E 99,999,999.99"
				//@ li,059 PSay  "%"
				@ li,053 PSay Round(_aAcuFat[nId,5]/_aAcuFat[nId,7]*100,2) Picture "@E 99,999,999.99"
				@ li,066 PSay  "%"
				@ li,071 PSay Round(_aAcuFat[nId,6]/_aAcuFat[nId,7]*100,2) Picture "@E 99,999,999.99"
				@ li,084 PSay  "%"
				@ li,097 PSay "100.00%"
			EndIf
			
			li++
			@ li,000 psay Replicate("-",132)
			li++
			
			If Val(cMes) == Month(DDataBase) .and. lFaturas
				
				@ li,000 psay Replicate("=",132)
				li++
				
				@ li,001 PSay _aPedLib[nId,1]
				
				If lFaturas
					@ li,016 psay Round((_aPedLib[nId,2]/_aMeta[nId][METPAR])*100,2) Picture "@E 99,999,999.99"
					@ li,029 PSay  "%"
					@ li,032 PSay Round((_aPedLib[nId,3]/_aMeta[nId][METPUB])*100,2) Picture "@E 99,999,999.99"
					@ li,045 PSay  "%"
					//@ li,046 PSay _aPedLib[nId,4] Picture "@E 99,999,999.99"
					@ li,053 PSay Round((_aPedLib[nId,5]/_aMeta[nId][METREP])*100,2) Picture "@E 99,999,999.99"
					@ li,066 PSay  "%"
					@ li,071 PSay Round((_aPedLib[nId,6]/_aMeta[nId][METTEL])*100,2) Picture "@E 99,999,999.99"
					@ li,084 PSay  "%"
					@ li,090 PSay Round((_aPedLib[nId,7]/_aMeta[nId][METDIP])*100,2) Picture "@E 99,999,999.99"
					@ li,103 PSay  "%"
					//@ li,106 PSay "Total "+DtoC(_cDiaTot)+": "+ Alltrim(Transform(_nTotDia+_aPedLib[nId,7],"@E 99,999,999.99"))
				EndIf
				
				li++
				@ li,000 psay Replicate("-",132)
				li++
				@ li,001 PSay _aNoDia[nId,1]
				
				If lFaturas
					@ li,016 psay Round((_aNoDia[nId,2]/_aMeta[nId][METPAR])*100,2) Picture "@E 99,999,999.99"
					@ li,029 PSay  "%"
					@ li,032 PSay Round((_aNoDia[nId,3]/_aMeta[nId][METPUB])*100,2) Picture "@E 99,999,999.99"
					@ li,045 PSay  "%"
					//@ li,046 PSay _aPedLib[nId,4] Picture "@E 99,999,999.99"
					@ li,053 PSay Round((_aNoDia[nId,5]/_aMeta[nId][METREP])*100,2) Picture "@E 99,999,999.99"
					@ li,066 PSay  "%"
					@ li,071 PSay Round((_aNoDia[nId,6]/_aMeta[nId][METTEL])*100,2) Picture "@E 99,999,999.99"
					@ li,084 PSay  "%"
					@ li,090 PSay Round((_aNoDia[nId,7]/_aMeta[nId][METDIP])*100,2) Picture "@E 99,999,999.99"
					@ li,103 PSay  "%"
					@ li,107 PSay Round(((_aPedLib[nId,7]+_aAcuFat[nId,7])/_aMeta[nId][METDIP])*100,2) Picture "@E 99,999,999.99"   // MCVN 15/01/2009
					@ li,120 PSay  "%"
					//@ li,106 PSay "Total "+DtoC(_cDiaTot)+": "+ Alltrim(Transform(_NoDia[nId,7],"@E 99,999,999.99"))
				EndIf
				li++
				@ li,000 psay Replicate("-",132)
				li++
			Endif
		Endif
	Next nId
	//-------------------------------------------------------------------------------------------
	// Se lFaturas estiver em falso sai do laco, pois ja' tera' concluido as duas impressoes
	//-------------------------------------------------------------------------------------------
	If !lFaturas
		Exit
	EndIf
	//-------------------------------------------------------------------------------------------
	// Apos a impressao das faturas, flaga (flega) lFaturas em falso, para imprimir pedidos.
	//-------------------------------------------------------------------------------------------
	lFaturas := .F.       // Processar pedidos
	li       := 80       // Forca a reimpressao do cacario
	_cDesc1  := _cDesc3  // Cabec para Pedidos
	_cDesc2  := _cDesc4  // Cabec para Pedidos
	
EndDo

DbSelectArea("QRY1")
QRY1->(DbCloseArea())

DbSelectArea("QRY2")
QRY2->(DbCloseArea())

DbSelectArea("QRY3")
QRY3->(DbCloseArea())

Set device to Screen

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Se em disco, desvia para Spool                                            ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If aReturn[5] == 1    // Se Saida para disco, ativa SPOOL
	Set Printer TO
	Commit
	ourspool(wnrel)
Endif

Return(.T.)
*---------------------------------------*
Static Function DipPergDiverg(lLer)
// Registra altera็๕es no SX1
*---------------------------------------*
Local aRegs:={}
Local lIncluir
Local i,j
SX1->(dbSetOrder(1))
aAdd(aRegs,{cPerg,"01","Informe o M๊s        ?","","","MV_CH1","C",002,0,0,"G","","MV_PAR01","","","", cMes,"","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"02","Informe o Ano        ?","","","MV_CH2","C",004,0,0,"G","","MV_PAR02","","","", cAno,"","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"03","Meta Televendas      ?","","","MV_CH3","N",012,2,0,"G","","MV_PAR03","","","", Str(nMetTel),"","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"04","Meta Representante   ?","","","MV_CH4","N",012,2,0,"G","","MV_PAR04","","","", Str(nMetRep),"","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"05","Meta Particular      ?","","","MV_CH5","N",012,2,0,"G","","MV_PAR05","","","", Str(nMetPar),"","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"06","Meta Publico         ?","","","MV_CH6","N",012,2,0,"G","","MV_PAR06","","","", Str(nMetPub),"","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"07","Operadores Publico   ?","","","MV_CH7","C",040,0,0,"G","","MV_PAR07","","","", Substr(cOper,01,40),"","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"08","Operadores Publico   ?","","","MV_CH8","C",040,0,0,"G","","MV_PAR08","","","", Substr(cOper,41,40),"","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"09","Vendedor             ?","","","MV_CH9","C",006,0,0,"G","","MV_PAR09","","","", cCodVend,"","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"10","Fornecedor           ?","","","MV_CHA","C",006,0,0,"G","","MV_PAR10","","","", cCodForn,"","","","","","","","","","",""})
For i:=1 to len(aRegs)
	lIncluir:=!SX1->(dbSeek(cPerg+aRegs[i,2]))
	If !lIncluir.and.lLer
		aRegs[i,17]:=SX1->X1_CNT01
	EndIf
	SX1->(RecLock("SX1",lIncluir))
	For j:=1 to SX1->(FCount())
		If j <= len(aRegs[i])
			SX1->(FieldPut(j,aRegs[i,j]))
		Endif
	Next
	SX1->(MsUnlock("SX1"))
Next
cMes:=Left(aRegs[1,17],2)      // cMes cMes
cAno:=Left(aRegs[2,17],4)      // cAno cAno
nMetTel:=val(aRegs[3,17])      // nMetTel nMetTel
nMetRep:=val(aRegs[4,17])      // nMetRep nMetRep
nMetPar:=val(aRegs[5,17])      // nMetTel nMetTel
nMetPub:=val(aRegs[6,17])      // nMetRep nMetRep
//cOper:=ALLTRIM(aRegs[7,17])+ALLTRIM(aRegs[8,17])+Space(80-Len(ALLTRIM(aRegs[7,17])+ALLTRIM(aRegs[8,17]))) // cOper cOpe
cCodVend:= SubStr(aRegs[09,17],1,6) // Codigo do Vendedor // JBS 06/08/2010
cCodForn:= SubStr(aRegs[10,17],1,6) // Codigo do Fornecedor // JBS 06/08/2010

Return(.t.)


*---------------------------------------*
Static Function OperadorPub()
// Busca operadores no SU7 com U7_POSTO = "3" (Operadores de licita็ใo - Publico)
//MCVN - 06/08/09
*---------------------------------------*
Local cOpePub  := ""

QRY4 :=        " SELECT U7_COD"
QRY4 := QRY4 + " FROM " + RetSQLName("SU7") + " (NOLOCK)"
QRY4 := QRY4 + " WHERE "
QRY4 := QRY4 + RetSQLName("SU7")+".D_E_L_E_T_ <> '*'" + " AND "
QRY4 := QRY4 + "U7_POSTO = '03' "
QRY4 := QRY4 + "ORDER BY U7_COD"

TcQuery QRY4 NEW ALIAS "QRY4"

DbSelectArea("QRY4")
Do While QRY4->(!Eof())
	cOper := If(Empty(cOper),Alltrim(QRY4->U7_COD),cOper+"/"+Alltrim(QRY4->U7_COD))
	QRY4->(DbSkip())
Enddo

QRY4->(DbCloseArea())

Return(cOpePub)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณfFeriados บAutor  ณJailton B Santos-JBSบ Data ณ  03/03/2010 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Verifica os feriados existentes no mes corrente e retorna  บฑฑ
ฑฑบ          ณ -os em uma array                                           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Especifico - Faturamento - Dipromed                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function fFeriados()
Local _aFeriad := {}

// Montagem do array com feriados
DbSelectArea("SX5")
DbSetOrder(1)
DbSeek(xFilial("SX5")+"63")

Do While X5_TABELA == "63"
	
	If SubStr(X5_DESCRI,1,1) != "*"
		If Len(Alltrim(SubStr(X5_DESCRI,1,8))) <> 8
			cTemp := SubStr(X5_DESCRI,1,5)+"/"+AllTrim(cAno)
		Else
			cTemp := SubStr(X5_DESCRI,1,At(" ",X5_DESCRI)-1)
		EndIf
		Aadd(_aFeriad,{cTOD(AllTrim(cTemp))})
	EndIf
	SX5->(DbSkip())
EndDo
Return(_aFeriad)                                     

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณfNaoFatDip บAutor  ณMaximo Canutoบ     Data ณ  10/12/2015 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Verifica os dias nใo uteis para faturamento na dipromed    บฑฑ
ฑฑบ          ณ e adiciona no em uma array                                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Especifico - Faturamento - Dipromed                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function fNaoFatDip()
Local _aNaoFatDip := {}

// Montagem do array com feriados
DbSelectArea("SX5")
DbSetOrder(1)
DbSeek(xFilial("SX5")+"Z2")

Do While X5_TABELA == "Z2"
	
	If SubStr(X5_DESCRI,1,1) != "*"
		If Len(Alltrim(SubStr(X5_DESCRI,1,8))) <> 8
			cTemp := SubStr(X5_DESCRI,1,5)+"/"+AllTrim(cAno)
		Else
			cTemp := SubStr(X5_DESCRI,1,At(" ",X5_DESCRI)-1)
		EndIf
		Aadd(_aNaoFatDip,{cTOD(AllTrim(cTemp))})
	EndIf
	SX5->(DbSkip())
EndDo
Return(_aNaoFatDip)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณfQuery01  บAutor  ณJailton B Santos-JBSบ Data ณ 03/03/2010  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Esta Query apura os falores faturado no pedido pela empresaบฑฑ
ฑฑบ          ณ informada como parametro, Retorna Query QRY1.              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Especifico - Faturamento - DIPROMED.                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function fQuery01( _cEmpresa ,_cFilial, lAnalitico)

Local lRet    := .T.
Local cQry1   := ""
Local cFilSF2 := fFilial(_cEmpresa,'SF2',_cFilial)  // iif(!Empty(xFilial('SF2')),_cFilial,Space(2))
Local cFilSF4 := fFilial(_cEmpresa,'SF4',_cFilial)  //  iif(!Empty(xFilial('SF4')),_cFilial,Space(2))
Local nId     := 0
Local _x

//-----------------------------------------------------------------------------------------
// Default lAnalitico:= .T. // JBS 07/04/2010 - Novo tratamento Apura็ใo de valores analiticos
//-----------------------------------------------------------------------------------------
ProcRegua(500)

For _x := 1 to 150
	IncProc( "Processando...VENDAS ")
Next

If lAnalitico
	cQry1 := " SELECT F2_DOC, CASE F4_DUPLIC WHEN 'S' THEN (D2_TOTAL+D2_SEGURO+D2_VALFRE+D2_DESPESA+D2_ICMSRET ) ELSE (D2_SEGURO+D2_VALFRE+D2_DESPESA+D2_ICMSRET ) END AS F2_VALFAT, F2_EMISSAO, F2_VEND1, F2_VEND2, C5_OPERADO, U7_CODVEN, F2_CLIENTE, D2_FORNEC"  // JBS 03/08/2010 - Condicionado a soma do D2_TOTAL p/ nใo somar vlr, porem somar o fretes e despesas e acessorios.
Else
	//cQry1 := " SELECT SUM(CASE F4_DUPLIC WHEN 'S' THEN (D2_TOTAL+D2_SEGURO+D2_VALFRE+D2_DESPESA+D2_ICMSRET ) ELSE (D2_SEGURO+D2_VALFRE+D2_DESPESA+D2_ICMSRET ) END) as F2_VALFAT, F2_EMISSAO, F2_VEND1, F2_VEND2, C5_OPERADO, U7_CODVEN, F2_CLIENTE, D2_FORNEC"  // JBS 03/08/2010 - Condicionado a soma do D2_TOTAL p/ nใo somar vlr, porem somar o fretes e despesas e acessorios.
	cQry1 := " SELECT SUM(CASE F4_DUPLIC WHEN 'S' THEN (D2_TOTAL+D2_SEGURO+D2_VALFRE+D2_DESPESA+D2_ICMSRET ) ELSE (D2_SEGURO+D2_VALFRE+D2_DESPESA+D2_ICMSRET ) END) as F2_VALFAT, F2_VEND1, F2_VEND2, C5_OPERADO, U7_CODVEN, F2_CLIENTE, D2_FORNEC"  // JBS 03/08/2010 - Condicionado a soma do D2_TOTAL p/ nใo somar vlr, porem somar o fretes e despesas e acessorios.
EndIf
cQry1 += "   FROM SF2" + _cEmpresa  + " SF2 WITH (NOLOCK) "
cQry1 += "       INNER JOIN SD2" + _cEmpresa + " SD2  WITH (NOLOCK) "
cQry1 += "           on SD2.D_E_L_E_T_ = ' '  "
cQry1 += "           and SF2.F2_FILIAL = SD2.D2_FILIAL "
cQry1 += "           and SF2.F2_DOC    = SD2.D2_DOC  "
cQry1 += "           and SF2.F2_SERIE  = SD2.D2_SERIE "
//-----------------------------------------------------------------------------------------
//  Tratamento para fazer o filtro por fornecedor - JBS 06/08/2010
//-----------------------------------------------------------------------------------------
If !Empty(cCodForn)
	cQry1 += "       and SD2.D2_FORNEC = '" + cCodForn + "' "
EndIf
cQry1 += "       INNER JOIN SC5" + _cEmpresa + " SC5 WITH (NOLOCK) "
cQry1 += "           on SC5.D_E_L_E_T_ = ' '  "
cQry1 += "           and SD2.D2_FILIAL = SC5.C5_FILIAL "
cQry1 += "           and SD2.D2_PEDIDO = SC5.C5_NUM "
If lAnalitico
	// Filtro ListOper (OPERADOR) MCVN - 19/08/10
	If U_ListOper() != ''   
		If Upper(_cDipUsr) $ cVendInt    
			For nId := 1 to len(_aMeta)
				_aMeta[nId][METREP] := 0
				_aMeta[nId][METPAR] := 0
				_aMeta[nId][METPUB] := 0
			Next nId  
		ElseIf Upper(_cDipUsr) $ cVendExt
			For nId := 1 to len(_aMeta)
				_aMeta[nId][METTEL] := 0
				_aMeta[nId][METPUB] := 0
			Next nId
		ElseIf Upper(_cDipUsr) $ cVendPub
			For nId := 1 to len(_aMeta)
				_aMeta[nId][METREP] := 0
				_aMeta[nId][METPAR] := 0
				_aMeta[nId][METTEL] := 0
			Next nId  
		Endif
		cQry1 += "      and C5_OPERADO " + U_ListOper()+" "
	EndIf                 
EndIf
cQry1 += "       INNER JOIN SF4" + _cEmpresa  + " SF4 WITH (NOLOCK) "
cQry1 += "           on SF4.D_E_L_E_T_ = ' ' "
cQry1 += "           and SD2.D2_TES = SF4.F4_CODIGO "
cQry1 += "           and ( SF4.F4_DUPLIC = 'S' or D2_SEGURO+D2_VALFRE+D2_DESPESA+D2_ICMSRET  > 0 ) " // JBS 03/08/2010 - Incluido clausula do OR para considerar frete + despesas + seguro de brindes e amostras.
cQry1 += "           and SF4.F4_FILIAL = '" + cFilSF4 + "' "	// Eriberto 02/03/2010
cQry1 += "       LEFT JOIN " + RetSQLName("SU7")  + " SU7  WITH (NOLOCK) "
cQry1 += "           on SU7.D_E_L_E_T_ = ' '  "
cQry1 += "           and SF2.F2_VEND1 = SU7.U7_CODVEN "
cQry1 += "  WHERE SF2.D_E_L_E_T_ = ' ' "
cQry1 += "    	AND  + LEFT(SF2.F2_EMISSAO,6) = '" + cAno + cMes + "' "
//-- Tratamento da HQ-CD: se Dipromed-Mtz, somente listar dados a partir de 01/05/2011 => Daniel Leme: 29/06/2011
If _cEmpresa + _cFilial == "01001"
	cQry1 +=  "           and SF2.F2_EMISSAO >= '20110501' "
EndIf
cQry1 += "           and SF2.F2_FILIAL = '" + cFilSF2 + "'  "	// Eriberto 02/03/2010
cQry1 += "           and SF2.F2_TIPO IN ('N','C') "				// Eriberto 02/03/2010
//-----------------------------------------------------------------------------------------
// Tratamento para fazer o filtro por vendedor  - JBS 06/08/2010
//-----------------------------------------------------------------------------------------
If !Empty(cCodVend)
	//cQry1 += " (F2_VEND1 = "+cCodVend+" AND (F2_VEND2 = ' ' OR D2_FORNEC <> '000996') OR "
  	//cQry1 += " (F2_VEND2 = "+cCodVend+" AND D2_FORNEC IN ('000366','000446','000996'))) AND "
  	cQry1 += "           and (CASE WHEN F2_VEND2 <> ' ' AND D2_FORNEC IN('000366','000446','000996') THEN F2_VEND2 ELSE F2_VEND1 END) = "+cCodVend+" "
EndIf

//------------------------------------------------------------------------------------
// Filtro listven  MCVN - 06/05/09
//------------------------------------------------------------------------------------
/*If lValor .and. lAnalitico
	If U_ListVend() != ''
		If Upper(_cDipUsr) $ cVendInt
			For nId := 1 to len(_aMeta)
				_aMeta[nId][METREP] := 0
				_aMeta[nId][METPAR] := 0
				_aMeta[nId][METPUB] := 0
			Next nId
		ElseIf Upper(_cDipUsr) $ cVendExt
			For nId := 1 to len(_aMeta)
				_aMeta[nId][METTEL] := 0
			Next nId
		Endif
		cQry1 += " C5_VEND1 " + U_ListVend() + " AND "
	EndIf
Endif */

//If lValor .and. lAnalitico
If lAnalitico
	If U_ListVend() != ''   
		If Upper(_cDipUsr) $ cVendInt    
			For nId := 1 to len(_aMeta)
				_aMeta[nId][METREP] := 0
				_aMeta[nId][METPAR] := 0
				_aMeta[nId][METPUB] := 0
			Next nId  
		ElseIf Upper(_cDipUsr) $ cVendExt
			For nId := 1 to len(_aMeta)
				_aMeta[nId][METTEL] := 0
			Next nId
		Endif
		//cQry1 +=" C5_VEND1 " + U_ListVend()+" AND "
		//cQry1 +=" F2_VEND1 " + U_ListVend()+" AND "
		cQry1 +="      and F2_VEND1 IN( " + U_ListVend("2")+" ) "
	EndIf

Endif	
// Filtro listven  DSD - 22/10/12
If U_ListVend() != ''
	cQry1 += "      and F2_VEND1 IN( " + U_ListVend("2")+" ) "
EndIf       
If lAnalitico
	cQry1 += " ORDER BY F2_EMISSAO "
Else
	cQry1 += " GROUP BY F2_VEND1, F2_VEND2, C5_OPERADO, U7_CODVEN, F2_CLIENTE, D2_FORNEC"
EndIf
If Select("QRY1") > 0
	QRY1->( DbCloseArea() )
EndIf
memowrite('\query\DIPR42A_SD2'+_cEmpresa+_cFilial+'.SQL',cQry1)
TcQuery cQry1 NEW ALIAS "QRY1"


lRet := !QRY1->( BOF().and.EOF() )
QRY1->( DbGoTop() )

Return(lRet)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณfQuery02  บAutor  ณJailton B Santos-JBSบ Data ณ 03/03/2010  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Esta Query apura os valores das devolucoes na empresa      บฑฑ
ฑฑบ          ณ informada como parametro, Retorna Query QRY2               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Especifico - Faturamento - DIPROMED.                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function fQuery02(_cEmpresa,_cFilial,lAnalitico)

Local lRet    := .T.
Local cQry2   := ""
Local cFilSD1 := fFilial(_cEmpresa,'SD1',_cFilial) // Se nao for compaartilhado, traz a filial informada no _cFilial
Local cFilSF2 := fFilial(_cEmpresa,'SF2',_cFilial) // Idem  - JBS 06/08/2010
Local cFilSF4 := fFilial(_cEmpresa,'SF4',_cFilial) // Idem  - JBS 06/08/2010
Local _x

//---------------------------------------------------------------------------------------------
// Default lAnalitico:= .T. // JBS 07/04/2010 - Novo tratamento Apura็ใo de valores analiticos
//---------------------------------------------------------------------------------------------
For _x := 1 to 150
	IncProc( "Processando... DEVOLUวรO")
Next

If lAnalitico // Processamento Normal
//	cQry2 := "SELECT D1_DOC, D1_DTDIGIT, D1_TES, C5_OPERADO, U7_CODVEN, C5_VEND1, C5_VEND2, C5_CLIENTE, SUM( CASE F4_DUPLIC WHEN 'S' THEN (D1_TOTAL+D1_VALFRE+D1_SEGURO+D1_DESPESA) ELSE (D1_VALFRE+D1_SEGURO+D1_DESPESA) END) D1_TOTAL, D2_FORNEC" // JBS 03/08/2010 - Condicionado a soma do D1_TOTAL p/ nใo somar vlr, porem somar o fretes e despesas e acessorios.
	cQry2 := "SELECT D1_DOC, D1_DTDIGIT, D1_TES, C5_OPERADO, U7_CODVEN, F2_VEND1, C5_VEND2, C5_CLIENTE, SUM( CASE F4_DUPLIC WHEN 'S' THEN (D1_TOTAL+D1_VALFRE+D1_SEGURO+D1_DESPESA+D1_ICMSRET ) ELSE (D1_VALFRE+D1_SEGURO+D1_DESPESA+D1_ICMSRET) END) D1_TOTAL, D2_FORNEC" // JBS 03/08/2010 - Condicionado a soma do D1_TOTAL p/ nใo somar vlr, porem somar o fretes e despesas e acessorios.
Else // Processamento sintetico de valores
//	cQry2 := "SELECT C5_OPERADO, U7_CODVEN, C5_VEND1, C5_VEND2, C5_CLIENTE, SUM( CASE F4_DUPLIC WHEN 'S' THEN (D1_TOTAL+D1_VALFRE+D1_SEGURO+D1_DESPESA) ELSE (D1_VALFRE+D1_SEGURO+D1_DESPESA) END) D1_TOTAL, D2_FORNEC"  //  // JBS 03/08/2010 - Condicionado a soma do D1_TOTAL p/ nใo somar vlr, porem somar o fretes e despesas e acessorios.
	cQry2 := "SELECT C5_OPERADO, U7_CODVEN, F2_VEND1, C5_VEND2, C5_CLIENTE, SUM( CASE F4_DUPLIC WHEN 'S' THEN (D1_TOTAL+D1_VALFRE+D1_SEGURO+D1_DESPESA+D1_ICMSRET) ELSE (D1_VALFRE+D1_SEGURO+D1_DESPESA+D1_ICMSRET) END) D1_TOTAL, D2_FORNEC"  //  // JBS 03/08/2010 - Condicionado a soma do D1_TOTAL p/ nใo somar vlr, porem somar o fretes e despesas e acessorios.
EndIf

cQry2 += " FROM SD1" + _cEmpresa  + "  SD1 with (NOLOCK) "
cQry2 += "    inner join SD2" + _cEmpresa  + " SD2 with (NOLOCK) "
cQry2 += "       on SD2.D_E_L_E_T_ = ' '  "
cQry2 += "       and SD1.D1_FILIAL = SD2.D2_FILIAL "
cQry2 += "       and SD1.D1_NFORI  = SD2.D2_DOC "
cQry2 += "       and SD1.D1_SERIORI = SD2.D2_SERIE  "
cQry2 += "       and SD1.D1_ITEMORI = SD2.D2_ITEM  "
	//-----------------------------------------------------------------------------------------
	//  Tratamento para fazer o filtro por fornecedor - JBS 06/08/2010
	//-----------------------------------------------------------------------------------------
	If !Empty(cCodForn)
		cQry2 += "    and SD2.D2_FORNEC = '" + cCodForn + "' "
	EndIf
cQry2 += "    inner join SC5" + _cEmpresa  + " SC5 with (NOLOCK) "
cQry2 += "       on SC5.D_E_L_E_T_ = ' '  "
cQry2 += "       and SD2.D2_FILIAL = SC5.C5_FILIAL "
cQry2 += "       and SD2.D2_PEDIDO = SC5.C5_NUM  "  
	// Filtro listOper  MCVN - 04/08/10
	If U_ListOper() != ''
		cQry2 += "    and C5_OPERADO " + U_ListOper()+" "
	EndIf
cQry2 += "    inner join SF4" + _cEmpresa + " SF4 with (NOLOCK) "
cQry2 += "       on SF4.D_E_L_E_T_ = ' ' "
cQry2 += "       and SD1.D1_TES = SF4.F4_CODIGO  "
cQry2 += "       and SF4.F4_FILIAL = '" + cFilSF4 + "' "
cQry2 += "    inner join SF2" + _cEmpresa  + "  SF2  with (NOLOCK) "
cQry2 += "       on SF2.D_E_L_E_T_ = ' '  "
cQry2 += "       and SF2.F2_FILIAL = SD2.D2_FILIAL  "
cQry2 += "       and SF2.F2_DOC    = SD2.D2_DOC  "
cQry2 += "       and SF2.F2_SERIE  = SD2.D2_SERIE "
cQry2 += "    left join " + RetSQLName("SU7") + " SU7 with (NOLOCK) "
cQry2 += "       on SU7.D_E_L_E_T_ = ' '  "
cQry2 += "       and SF2.F2_VEND1 = SU7.U7_CODVEN "

cQry2 += " WHERE SD1.D_E_L_E_T_ = ' ' "
cQry2 += "    and SD1.D1_TIPO = 'D' "
cQry2 += "    and LEFT(SD1.D1_DTDIGIT,6) = '" + cAno + cMes + "' "

//-- Tratamento da HQ-CD: se Dipromed-Mtz, somente listar dados a partir de 01/05/2011 => Daniel Leme: 29/06/2011
If _cEmpresa + _cFilial == "01001"
	cQry2 +=  "    and SD1.D1_DTDIGIT >= '20110501' "
EndIf

// Eriberto 02/03/2010
cQry2 += "    and SD1.D1_FILIAL = '" + cFilSD1 + "' "

cQry2 += "    and ( SF4.F4_DUPLIC = 'S' or D1_VALFRE+D1_SEGURO+D1_DESPESA+D1_ICMSRET > 0 ) "    // JBS 03/08/2010 - Incluido o Or para conciderar a brindes e amostras.

// Eriberto 02/03/2010   
//-----------------------------------------------------------------------------------------
// Tratamento para fazer o filtro por vendedor  - JBS 06/08/2010
//-----------------------------------------------------------------------------------------
If !Empty(cCodVend)
	//cQry2 += " (F2_VEND1 = "+cCodVend+" AND (F2_VEND2 = ' ' OR D2_FORNEC <> '000996') OR "
	//cQry2 += " (F2_VEND2 = "+cCodVend+" AND D2_FORNEC IN ('000366','000446','000996'))) AND "
	cQry2 += "    and (CASE WHEN F2_VEND2 <> ' ' AND D2_FORNEC IN('000366','000446','000996') THEN F2_VEND2 ELSE F2_VEND1 END) = "+cCodVend+" "
EndIf
	

// Filtro listven  MCVN - 06/05/09
If U_ListVend() != ''
	//cQry2 += " F2_VEND1 " + U_ListVend()+" AND "
	cQry2 += "    and F2_VEND1 IN( " + U_ListVend("2")+" ) "
EndIf       

If lAnalitico
//	cQry2 += " GROUP BY D1_DOC,D1_DTDIGIT,D1_TES,C5_OPERADO,U7_CODVEN,C5_VEND1,C5_VEND2,C5_CLIENTE,D2_FORNEC "
	cQry2 += " GROUP BY D1_DOC,D1_DTDIGIT,D1_TES,C5_OPERADO,U7_CODVEN, F2_VEND1 ,C5_VEND2,C5_CLIENTE,D2_FORNEC "
	cQry2 += " ORDER BY D1_DTDIGIT"
Else 
   //	cQry2 += " GROUP BY C5_OPERADO,U7_CODVEN,C5_VEND1,C5_VEND2,C5_CLIENTE,D2_FORNEC "
  	cQry2 += " GROUP BY C5_OPERADO,U7_CODVEN, F2_VEND1,C5_VEND2,C5_CLIENTE,D2_FORNEC "
EndIf

If Select("QRY2") > 0
	QRY2->( DbCloseArea() )
EndIf
memowrite('\query\DIPR42ASD1'+_cEmpresa+_cFilial+'.SQL',cQry2)
TcQuery cQry2 NEW ALIAS "QRY2"


lRet := !QRY2->( BOF().and.EOF() )
QRY2->( DbGoTop() )

Return(lRet)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณfQuery03  บAutor  ณJailton B Santos-JBSบ Data ณ 03/03/2010  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Esta Query apura os valores dos pedidos da empresa infor-  บฑฑ
ฑฑบ          ณ mada como parametro. Retorna QRY3.                         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Especifico - Faturamento - DIPROMED.                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function fQuery03(_cEmpresa,_cFilial)

Local lRet    := .T.
Local cQry3   := ""
Local cFilSC5 := fFilial(_cEmpresa,'SC5',_cFilial)  // iif(!Empty(xFilial('SC5')),_cFilial,Space(2))
Local cFilSF4 := fFilial(_cEmpresa,'SF4',_cFilial)  // iif(!Empty(xFilial('SF4')),_cFilial,Space(2))
Local _x

For _x := 1 to 150
	IncProc( "Processando... PEDIDOS")
Next

cQry3 := "SELECT C5_EMISSAO, C5_PARCIAL, C9_CLIENTE, C9_OPERADO, U7_CODVEN, C9_VEND, C9_PARCIAL, C9_BLEST, C9_DATALIB, C9_BLCRED, C9_BLCRED2, SUM(C9_QTDLIB*C9_PRCVEN) C9_VALOR, C9_SALDO,C9_FORNEC,C5_OPERADO "
cQry3 += " FROM SC9" + _cEmpresa  + " SC9 with (NOLOCK) "
cQry3 += "    inner join SC6" + _cEmpresa  + " SC6 with (NOLOCK) "
cQry3 += "       on SC6.D_E_L_E_T_ = ' ' "
cQry3 += "       and SC9.C9_FILIAL = SC6.C6_FILIAL "
cQry3 += "       and SC9.C9_PEDIDO = SC6.C6_NUM "
cQry3 += "       and SC9.C9_ITEM   = SC6.C6_ITEM "
cQry3 += "    inner join SC5" + _cEmpresa  + " SC5 with (NOLOCK) "
cQry3 += "       on SC5.D_E_L_E_T_ = ' ' "
cQry3 += "       and SC5.C5_FILIAL = '" + cFilSC5 + "' "
cQry3 += "       and SC5.C5_TIPO   = 'N' "
cQry3 += "       and SC9.C9_FILIAL = SC5.C5_FILIAL "
cQry3 += "       and SC9.C9_PEDIDO = SC5.C5_NUM "
//-- Tratamento da HQ-CD: se Dipromed-Mtz, somente listar dados a partir de 01/05/2011 => Daniel Leme: 29/06/2011
If _cEmpresa + _cFilial == "01001"
	cQry3 +=  "       and SC5.C5_DTPEDID >= '20110501' "
EndIf
If U_ListVend() != ''
	//cQry3 += " C5_VEND1 " + U_ListVend()+" AND "
	cQry3 += "       and C5_VEND1 IN( " + U_ListVend("2")+" ) "
EndIf
// Filtro listOper  MCVN - 04/08/10
If U_ListOper() != ''
	cQry3 += "       and C5_OPERADO " + U_ListOper()+" "
EndIf
//-----------------------------------------------------------------------------------------
// Tratamento para fazer o filtro por vendedor  - JBS 06/08/2010
//-----------------------------------------------------------------------------------------
If !Empty(cCodVend) 
    cQry3 += "       and (C5_VEND1 = "+cCodVend+" AND (C5_VEND2 = ' ' OR C9_FORNEC <> '000996') "
	cQry3 += "       or  (C5_VEND2 = "+cCodVend+" AND C9_FORNEC IN ('000366','000446','000996'))) "
EndIf
cQry3 += "    inner join SF4" + _cEmpresa  + " SF4 with (NOLOCK) "
cQry3 += "       on SF4.D_E_L_E_T_ = ' ' "
cQry3 += "       and SC6.C6_TES    = SF4.F4_CODIGO "
cQry3 += "       and SF4.F4_DUPLIC = 'S' "
cQry3 += "       and SF4.F4_FILIAL = '" + cFilSF4 + "' "
cQry3 += "    left join " + RetSQLName("SU7")  + " SU7 with (NOLOCK) "
cQry3 += "       on SU7.D_E_L_E_T_ = ' ' "
cQry3 += "       and SC5.C5_VEND1 = SU7.U7_CODVEN "      
cQry3 += " WHERE SC9.D_E_L_E_T_ = ' ' "
cQry3 += "    and (LEFT(C5_EMISSAO,6) = '" + cAno + cMes + "' or ((C9_BLEST = '  ' or C9_BLEST = '02') and C5_PARCIAL = ' ' and C9_SALDO = 0 and C9_BLCRED = '  ' and C9_BLCRED2 = '  ')) "
//-----------------------------------------------------------------------------------------
//  Tratamento para fazer o filtro por fornecedor - JBS 06/08/2010
//-----------------------------------------------------------------------------------------
If !Empty(cCodForn)
    cQry3 += "       and SC9.C9_FORNEC = '" + cCodForn + "' "
EndIf
cQry3 += "GROUP BY C5_EMISSAO, C5_PARCIAL, C9_CLIENTE, C9_OPERADO, U7_CODVEN, C9_VEND, C9_PARCIAL, C9_BLEST, C9_DATALIB, C9_BLCRED, C9_BLCRED2, C9_SALDO, C9_FORNEC, C5_OPERADO "
cQry3 += "ORDER BY C5_EMISSAO"

If Select("QRY3") > 0
	QRY3->( DbCloseArea() )
EndIf

TcQuery cQry3 NEW ALIAS "QRY3"
memowrite('DIPR42ASC9'+_cEmpresa+_cFilial+'.SQL',cQry3)

lRet := !QRY3->( BOF().and.EOF() )
QRY3->( DbGoTop() )

Return(lRet)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณfCalcMetasบAutor  ณJailton B Santos-JBSบ Data ณ 04/03/2010  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMonta uma array com as metas de vendedores                  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณEspecifico - Faturamento - Dipromed                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function fCalcMetas()

Local cCodDip   := '000001' // MCVN - 04/05/09
Local cCodTel   := '000002' // MCVN - 04/05/09
Local cCodPar   := '000003' // MCVN - 04/05/09
Local cCodPub   := '000004' // MCVN - 04/05/09
Local cCodRep   := '000005' // MCVN - 04/05/09

Local lRet      := .T.
Local cFilSZF   := ''
Local cFilSZF   := iif(!Empty(xFilial('SZF')),cFilial,Space(2))
Local nId

_aMeta := {}

For nId := 1 to len(aEmpresa)
	
	If Select('SX2_2') > 0
		SX2_2->( DbCloseArea() )
	EndIf
	
	cFilSZF := fFilial(aEmpresa[nId][01][01],'SZF',aEmpresa[nId][01][02]) // JBS 10/03/2010 iif(!Empty(xFilial('SF4')),aEmpresa[nId][02],Space(2))
	
	aadd(_aMeta,{ fBusc_aMeta(cFilSZF,aEmpresa[nId][01][01],cCodTel,cMes + "/" + cAno),; // nMetTel
	              fBusc_aMeta(cFilSZF,aEmpresa[nId][01][01],cCodRep,cMes + "/" + cAno),; // nMetRep
	              fBusc_aMeta(cFilSZF,aEmpresa[nId][01][01],cCodPar,cMes + "/" + cAno),; // nMetPar
	              fBusc_aMeta(cFilSZF,aEmpresa[nId][01][01],cCodPub,cMes + "/" + cAno),; // nMetPub
	              fBusc_aMeta(cFilSZF,aEmpresa[nId][01][01],cCodDip,cMes + "/" + cAno)}) // nMetDip
	
Next nId
Return(len(_aMeta)>0)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณfBusc_aMetaบAutor  ณJailton B Santos-JBSบ Data ณ 04/03/2010  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณBusca a meta de venda por departamento. Informa-se a o codi-บฑฑ
ฑฑบ          ณgo do vendedor.                                             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณEspecifico - Faturamento - Dipromed                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static function fBusc_aMeta(_cFilial,_cEmpresa,cVendedor,cMesAno)

Local nRet   := 0
Local cQuery := ""
Local cFilSZF:= xFilial('SZF')  // JBS 10/12/2010 fFilial(_cEmpresa,'SZF',_cFilial)

cQuery := " SELECT ZF_FILIAL,ZF_MESANO,ZF_VEND,ZF_META "
cQuery += "   FROM " + RetSqlName('SZF') +" SZF (NOLOCK) "
//JBS 10/12/2010 cQuery += "   FROM SZF" + _cEmpresa + " SZF "
//cQuery += "   FROM SZF010 SZF "
cQuery += "  WHERE ZF_FILIAL = '" + cFilSZF   + "' "
// JBS 10/12/2010 cQuery += "  WHERE ZF_FILIAL = '" + cFilSZF   + "' "
//cQuery += "  WHERE ZF_FILIAL = '' "
cQuery += "    AND ZF_MESANO = '" + cMesAno   + "' "

//-- Tratamento da HQ-CD: se Dipromed-Mtz, somente listar dados a partir de 01/05/2011 => Daniel Leme: 29/06/2011
If _cEmpresa + _cFilial == "01001"
	cQuery +=  " AND (SUBSTRING(ZF_MESANO,4,4) > '2011' OR (SUBSTRING(ZF_MESANO,4,4) == '2011' AND ZF_MESANO >= '05/2011')"
EndIf

cQuery += "    AND ZF_VEND =   '" + cVendedor + "' "
cQuery += "    AND SZF.D_E_L_E_T_ = '' "
cQuery += "  ORDER BY ZF_MESANO "

If Select("WORK") > 0
	WORK->( DbCloseArea() )
EndIf

TcQuery cQuery NEW ALIAS "WORK"
TCSETFIELD("WORK","ZF_META"    , "N" , 16 , 04)

WORK->( DbGoTop() )

If !WORK->( BOF().and.EOF() )
	nRet := ZF_META
EndIf

Return(nRet)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหอออออัออออออออออออออออออออหออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณfSomaEmpresa()บAutorณJailton B Santos-JBSบDataณ 08/03/2010  บฑฑ
ฑฑฬออออออออออุออออออออออออออสอออออฯออออออออออออออออออออสออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao desenvolvida para somar os totais entre empresas.    บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณEsppecifico - Faturamento Dipromed                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function fSomaEmpresa(lFaturas)

Local nX    := 0
Local nY    := 0
Local nTam  := len(_aAcuFat)+1  // Dimensao criada para totais
Local nLen  := Iif(nTam > 1, len(_aAcuFat[1]),0) // Quantidade de Colunas da Dimensao dos totais
Local nTamPL:= Iif(nTam > 1, len(_aPedLib[1]),0)
Local nTamDi:= Iif(nTam > 1, len(_aNoDia[1]) ,0)
Local nTamMt:= Iif(nTam > 1, len(_aMeta[1])  ,0)
Local nTamAn:= Iif(nTam > 1, len(_aDia[1])  ,0)

aAdd(_aAcuFat   ,array(nLen  ))  // Criando a dimensao dos totais  Faturados
aAdd(_aPedLib   ,array(nTamPL))  // Criando a dimensao dos totais  Pedidos Liberados
aAdd(_aNoDia    ,array(nTamDi))  // Criando a dimensao dos totais  No ia
aAdd(_aMeta     ,array(nTamMt))  // Criando a dimensao dos totais  Metas
aAdd(_aDia      ,array(nTamAn))  // Criando a dimensao dos totais  Faturas do Dia Anterior

For nY := 1 to nLen
	_aAcuFat[nTam][nY] := _aAcuFat[01][nY] // Somando os totais na dimensao criada para faturados
Next nY
For nY := 1 to nTamPL
	_aPedLib[nTam][nY] := _aPedLib[01][nY] // Somando os totais na dimensao criada para pedidos liberados
Next nY
For nY := 1 to nTamDi
	_aNoDia[nTam][nY] := _aNoDia[01][nY]  // Somando os totais na dimensao criada para faturados do dia
Next nY
For nY := 1 to nTamMt
	_aMeta[nTam][nY] := _aMeta[01][nY]   // Somando os totais na dimensao criada para Metas
Next nY
For nY := 1 to nTamAn
	_aDia[nTam][nY] := _aDia[01][nY]  // Somando os totais na dimensao criada para Metas
Next nY

For nX := 2 to len(_aAcuFat)-1
	For nY := 2 to nLen
		_aAcuFat[nTam][nY] += _aAcuFat[nX][nY] // Somando os totais na dimensao criada para faturados
	Next nY
	For nY := 2 to nTamPL
		_aPedLib[nTam][nY] += _aPedLib[nX][nY] // Somando os totais na dimensao criada para pedidos liberados
	Next nY
	For nY := 2 to nTamDi
		_aNoDia[nTam][nY] += _aNoDia[nX][nY]   // Somando os totais na dimensao criada para faturados do dia
	Next nY
	For nY := 2 to nTamMt
		_aMeta[nTam][nY] := _aMeta[nX][nY]     // Somando os totais na dimensao criada para Metas
	Next nY
	//----------------------------------------------------------------------------------------------------
	// JBS - 11/03/2010 - Total do Dia Anterior
	//----------------------------------------------------------------------------------------------------
	For nY := 2 to nTamAn
		_aDia[nTam][nY] += _aDia[nX][nY] // Somando os totais na dimensao criada para vendas de dias anteriores
	Next nY
Next nX

Return(.T.)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณfFilial() บAutor  ณJailton B Santos-JBSบ Data ณ 10/03/2010  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFaz o tratamento para achar a filial para empresa para a    บฑฑ
ฑฑบ          ณqual ira' abrir a tabela informada.                         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametro ณ_cEmpresa: Empresa na qual queremos coletar dados           บฑฑ
ฑฑบ          ณ_cTabela : Nome da tabela da qual queremos coletar dados    บฑฑ
ฑฑบ          ณ_cFilial : Se a tabela for exclusiva, esta eh a filial da   บฑฑ
ฑฑบ          ณ           qual eh preciso coletar dados.                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Especifico - Faturamento - DIPROMED                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function fFilial(_cEmpresa,_cTabela,_cFilial)

Local _cNewFilial := Space(2)
Local _cFile      := 'SX2'+_cEmpresa
Local _cFileIdx   := _cFile

If Select("SX2_2") = 0
	MsOpEndbf(.T.,"DBFCDX",_cFile,"SX2_2",.T.,.F.)
EndIf

SX2_2->( DbSetOrder(1) )
If SX2_2->( DbSeek(_cTabela) )			  //
	If SX2_2->X2_MODO = 'E'
		_cNewFilial := _cFilial
	EndIf
Else
	_cNewFilial := xFilial(_cTabela)
EndIf

Return(_cNewFilial)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณfDiaAnt() บAutor  ณJailton B Santos-JBSบ Data ณ 11/03/2010  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณCalcular quantos das deve-se retroagir no dDataBase para    บฑฑ
ฑฑบ          ณchegar ao dia util anterior ao atual.                       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณEspecifico - Faturamento - Dipromed                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function fDiaAnt()
Local nDias := 1

Do While Ascan(_aFeriad,{|y| y[1] == dDataBase - nDias}) <> 0.or.;
	AllTrim(cDow(dDataBase - nDias)) = "Saturday"	.or. ;
	AllTrim(cDow(dDataBase - nDias)) = "Sunday"
	
	If FirstDay(dDataBase) == dDataBase - nDias
		nDias := 0
		Exit
	EndIf
	
	nDias++
	
EndDo

Return(nDias)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณfSinteticoบAutor  ณJailton B Santos-JBSบ Data ณ  07/04/2010 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Apura os valor sintetico de vendas-devolu็๕es de uma deter-บฑฑ
ฑฑบ          ณ minada empresa e uma determinada filial                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Especifico Faturamento Dipromed                           บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function fSintetico(_cEmpresa,_cFilial,_bQry01,_bQry02,_bQry03)

Local _nSPar := 0
Local _nSPub := 0
Local _nSPre := 0
Local _nSRep := 0
Local _nSTel := 0
Local _nSTot := 0
Local nRegua := 1000
//----------------------------------------------------------------------------------------
// Posi็ใo de Pedidos - Apura็ใo de subtotais
//----------------------------------------------------------------------------------------
Local _nColPed:= 0
Local _nLibPed:= 0
Local _nFatPed:= 0
Local _nEstPed:= 0
Local _nCrePed:= 0
Local _nOpePed:= 0
//----------------------------------------------------------------------------------------
// Posi็ใo de Pedidos - Apura็ใo de Totais
//----------------------------------------------------------------------------------------
Local _nAcCol := 0
Local _nAcLib := 0
Local _nAcFat := 0
Local _nAcEst := 0
Local _nAcCre := 0
Local _nAcOpe := 0 
//----------------------------------------------------------------------------------------
ProcRegua(nRegua)
//----------------------------------------------------------------------------------------
// Le o faturamento do periodo para empresa '040 e filial '01'
//----------------------------------------------------------------------------------------
fQuery01(_cEmpresa,_cFilial,.f.)
//----------------------------------------------------------------------------------------
// Le as Devolucoes do periodo para empresa '040 e filial '01'
//----------------------------------------------------------------------------------------
fQuery02(_cEmpresa,_cFilial,.f.)  // Gerou QRY2
//----------------------------------------------------------------------------------------
// Le os Pedidos do periodo para empresa '0X0 e filial '0Y'
//----------------------------------------------------------------------------------------
fQuery03(_cEmpresa,_cFilial,.f.)  // Gerou QRY3
//----------------------------------------------------------------------------------------
DbSelectArea("QRY1")
DbGoTop()
//----------------------------------------------------------------------------------------
// Classfica as vendas por departamentos de vendas
//----------------------------------------------------------------------------------------
Do While QRY1->(!Eof())
	
	IncProc( "Processando... Sint้tico de Vendas")
	
	If nRegua = 0
		nRegua := 1000
		ProcRegua(nRegua)
	EndIf
	
	nRegua--
	//----------------------------------------------------------------------------------------
	// Uso da condicao para tornar esta funcao um rotina mais generica e permiir maior uso.  
	// JBS 15/06/2010  - Hoje ha a necessidade de trazer um total de um fornecedor  em  uma 
	// Empresa e filial determinada na condicao vai codeblock com os fornecedores que eu quero. 
	//----------------------------------------------------------------------------------------
	If _bQry01 <> Nil        // 
	    If QRY1->(!Eval(_bQry01))   
	        QRY1->( DbSkip())
	        Loop
	    EndIf    
	EndIf   
	// Comentado em 15/06/2010 - O Eriberto mudou o conceito
	//----------------------------------------------------------------------------------------
	// Exclui do processamento diario o fornecedor  051508'  - JBS 14/05/2010
	// Apenas quando for o CD HQ
	//----------------------------------------------------------------------------------------
	//If _cEmpresa== '040' .and. _cFilial == '04' .and. !AllTrim(QRY1->D2_FORNEC) $ cFornQH
	//	QRY1->(DbSkip())
	//	Loop
	//EndIf
	//----------------------------------------------------------------------------------------
	// Televendas
	//----------------------------------------------------------------------------------------
	If ((Empty(QRY1->F2_VEND2) .OR. (!Empty(QRY1->F2_VEND2) .AND. !(QRY1->D2_FORNEC $ cFornVend))).AND. !Empty(QRY1->U7_CODVEN) .and. QRY1->F2_VEND1 <> '000204') .or. ;
		QRY1->F2_VEND1 $ '006684/000353/000352/000356/000357/000359'
		_nSTel += QRY1->F2_VALFAT
	Else
		//----------------------------------------------------------------------------------------
		// Representantes
		//----------------------------------------------------------------------------------------
		_nSRep += QRY1->F2_VALFAT
		//----------------------------------------------------------------------------------------
		// Publico
		//----------------------------------------------------------------------------------------
		If QRY1->C5_OPERADO $ cOper
			_nSPub += QRY1->F2_VALFAT
		EndIf
		_nSPar := (_nSRep - _nSPub - _nSPre)
	EndIf
	//----------------------------------------------------------------------------------------
	// Total
	//----------------------------------------------------------------------------------------
	_nSTot += QRY1->F2_VALFAT
	
	QRY1->( DbSkip() )
	
EndDo
//----------------------------------------------------------------------------------------
// Classfica as devolu็๕es de vendas por departamentos de vendas, fazendo a devida subtra-
// ็ใo do faturamento aprurado
//----------------------------------------------------------------------------------------
DbSelectArea("QRY2")
DbGoTop()

Do While QRY2->(!Eof())
	
	IncProc( "Processando... Sint้tico de devolu็ใo")
	
	If nRegua = 0
		nRegua := 1000
		ProcRegua(nRegua)
	EndIf
	
	nRegua--
	//----------------------------------------------------------------------------------------
	// Uso da condicao para tornar esta funcao um rotina mais generica e permiir maior uso.  
	// JBS 15/06/2010  - Hoje ha a necessidade de trazer um total de um fornecedor  em  uma 
	// Empresa e filial determinada na condicao vai codeblock com os fornecedores que eu quero. 
	//----------------------------------------------------------------------------------------
	If _bQry02 <> Nil        // 
	    If QRY2->(!Eval(_bQry02))   
	        QRY2->( DbSkip())
	        Loop
	    EndIf    
	EndIf   
	//
	// Comentado em 15/06/2010 - O Eriberto mudou o conceito
	//----------------------------------------------------------------------------------------
	// Exclui do processamento diario o fornecedor  051508'  - JBS 14/05/2010
	// Apenas quando for o CD HQ
	//----------------------------------------------------------------------------------------
	//If _cEmpresa== '040' .and. _cFilial == '04'.and. !AllTrim(QRY2->D2_FORNEC) $ cFornQH
	//	QRY2->(DbSkip())
	//	Loop
	//EndIf
	//-------------------------------------------------------------------------------------------------
	// Televendas
	//-------------------------------------------------------------------------------------------------
//	If ((Empty(QRY2->C5_VEND2).OR.(!Empty(QRY2->C5_VEND2) .AND. !(QRY2->D2_FORNEC $ cFornVend))).AND.!Empty(QRY2->U7_CODVEN).and.QRY2->C5_VEND1 <> '000204') .or. ;
//	QRY2->C5_VEND1 $ '006684/000353/000352/000356/000357/000359'
	If ((Empty(QRY2->C5_VEND2).OR.(!Empty(QRY2->C5_VEND2) .AND. !(QRY2->D2_FORNEC $ cFornVend))).AND.!Empty(QRY2->U7_CODVEN).and.QRY2->F2_VEND1 <> '000204') .or. ;
		QRY2->F2_VEND1 $ '006684/000353/000352/000356/000357/000359'
		_nSTel -= QRY2->D1_TOTAL
	Else
		//-------------------------------------------------------------------------------------------------
		// Representantes
		//-------------------------------------------------------------------------------------------------
		_nSRep -= QRY2->D1_TOTAL
		//-------------------------------------------------------------------------------------------------
		// P๚blico
		//-------------------------------------------------------------------------------------------------
		If QRY2->C5_OPERADO $ cOper
			_nSPub -= QRY2->D1_TOTAL
		EndIf
		//-------------------------------------------------------------------------------------------------
		//Prefeitura
		//-------------------------------------------------------------------------------------------------
		//If QRY2->C5_CLIENTE = '004303'
		//	_nSPre -= QRY2->D1_TOTAL
		//EndIf
		//-------------------------------------------------------------------------------------------------
		// Particular
		//-------------------------------------------------------------------------------------------------
		_nSPar := (_nSRep - _nSPub - _nSPre)
	EndIf
	//-------------------------------------------------------------------------------------------------
	// Total
	//-------------------------------------------------------------------------------------------------
	_nSTot -= QRY2->D1_TOTAL
	//-------------------------------------------------------------------------------------------------
	QRY2->(DbSkip())
	
EndDo

DbSelectArea("QRY3")
DbGoTop()

Do While QRY3->(!Eof())
	
	IncProc( "Processando... Dados dos pedidos")
	//----------------------------------------------------------------------------------------
	// Uso da condicao para tornar esta funcao um rotina mais generica e permiir maior uso.  
	// JBS 15/06/2010  - Hoje ha a necessidade de trazer um total de um fornecedor  em  uma 
	// Empresa e filial determinada na condicao vai codeblock com os fornecedores que eu quero. 
	//----------------------------------------------------------------------------------------
	If _bQry03 <> Nil        // 
	    If QRY3->(!Eval(_bQry03))   
	        QRY3->( DbSkip())
	        Loop
	    EndIf    
	EndIf   
	// Comentado em 15/06/2010 - O Eriberto mudou o conceito
    //----------------------------------------------------------------------------------------
	// Exclui do processamento diario o fornecedor  051508'  - JBS 14/05/2010
	// Apenas quando for o CD HQ
	//----------------------------------------------------------------------------------------
	//If _cEmpresa== '040' .and. _cFilial == '04' .and. !AllTrim(QRY3->C9_FORNEC) $ cFornQH
	//	QRY3->(DbSkip())
	//	Loop
	//EndIf
	//----------------------------------------------------------------------------------------
	_nColPed += QRY3->C9_VALOR
	// Liberados
	If Empty(QRY3->C5_PARCIAL) .and. ((QRY3->C9_BLEST='02' .or. QRY3->C9_BLEST='  ') .and. QRY3->C9_SALDO = 0 .and. Empty(QRY3->C9_BLCRED) .and. Empty(QRY3->C9_BLCRED2))
		_nLibPed += QRY3->C9_VALOR
		// Estoque
	ElseIf QRY3->C9_BLEST = '02' .and. QRY3->C9_SALDO != 0
		_nEstPed += QRY3->C9_VALOR
		// Pelo Operador
	ElseIf !Empty(QRY3->C5_PARCIAL)
		_nOpePed  += QRY3->C9_VALOR
		// Credito
	ElseIf QRY3->C9_BLCRED $ '01/04/09'
		_nCrePed += QRY3->C9_VALOR
		// Faturado
	ElseIf QRY3->C9_BLEST == '10' .and. QRY3->C9_BLCRED == '10'
		_nFatPed += QRY3->C9_VALOR
	EndIf
	/*
	// S๓ para pedidos liberados - vamos separar por area
	If Empty(QRY3->C5_PARCIAL) .and. ((QRY3->C9_BLEST = '02' .or. QRY3->C9_BLEST = '  ') .and. QRY3->C9_SALDO = 0 .and. Empty(QRY3->C9_BLCRED) .and. Empty(QRY3->C9_BLCRED2))
		// Televendas
		If (!Empty(QRY3->U7_CODVEN) .and. QRY3->C9_VEND <> '000204') .or. QRY3->C9_VEND $ '006684/000353/000352/000356/000357/000359'
			_nPVLTel += QRY3->C9_VALOR
		Else
			// Representantes
			_nPVLRep += QRY3->C9_VALOR
			// P๚blico
			If QRY3->C9_OPERADO $ cOper
				_nPVLPub += QRY3->C9_VALOR
			EndIf
			//Prefeitura
			If QRY3->C9_CLIENTE = '004303'
				_nPVLPre += QRY3->C9_VALOR
			EndIf
			// Particular
			_nPVLPar := (_nPVLRep - _nPVLPub - _nPVLPre)
		EndIf
		// Total
		_nPVLTot += QRY3->C9_VALOR
	EndIf 
	*/
	//-----------------------------------------------------------------------------------------
	// Acumula totais para montar linha dos totais
	//-----------------------------------------------------------------------------------------
	_nAcCol += _nColPed
	_nAcLib += _nLibPed
	_nAcFat += _nFatPed
	_nAcEst += _nEstPed
	_nAcCre += _nCrePed
	_nAcOpe += _nOpePed
	//-----------------------------------------------------------------------------------------
	// Zera
	//-----------------------------------------------------------------------------------------
	_nColPed:= 0
	_nLibPed:= 0
	_nFatPed:= 0
	_nEstPed:= 0
	_nCrePed:= 0
	_nOpePed:= 0
	//-----------------------------------------------------------------------------------------
	QRY3->(DbSkip())
	
EndDo
//-------------------------------------------------------------------------------------------------
// Retorna os valores apurados dentro de uma array
//-------------------------------------------------------------------------------------------------
Return({_nSPar,_nSPub,_nSPre,_nSRep,_nSTel,_nSTot,_nAcCol,_nAcLib,_nAcFat,_nAcEst,_nAcCre,_nAcOpe})

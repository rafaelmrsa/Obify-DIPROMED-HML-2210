/*====================================================================================\
|Programa  | DIPR044       | Autor | Rafael de Campos Falco     | Data | 06/02/2004   |
|=====================================================================================|
|DescriÁ„o | FATURAMENTO POR VENDEDOR DOS ⁄LTIMOS 12 MESES                            |
|=====================================================================================|
|Sintaxe   | DIPR044                                                                  |
|=====================================================================================|
|Uso       | Especifico DIPROMED                                                      |
|=====================================================================================|
|........................................HistÛrico....................................|
|Rafael    | 01/02/05 - alteraÁ„o na linha 1660                                       |
|Eriberto  | 18/04/05 - Inclui o parametro MV_PAR07 = FORNECEDOR                      |
|Daniel    | 11/10/07 - Tratamento de Filtro de Vendedor                              |
|          |            inclusao de filtro por Grupo de Clientes                      |
|JailtonBS | 16/04/10 - Desenvolvido o tratamento para apurar informaÁıes de forma    |
|          |            multiempresas.                                                |
|Maximo    | 28/10/10 - Agrupa por tÈcnico                                            |
|Giovani   | 26/07/11 - AlteraÁ„o do campo u7_nreduz para u7_nome.                    |
|Giovani   | 03/08/11 - AlteraÁ„o do campo A3_nreduz para A3_nome.                    |
|RBorges   | 20/12/13 - Adicionado no arquivo o campo A3_NREDUZ.                      |
\====================================================================================*/

#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

User Function DIPR044()

Local _xArea	:= GetArea()
Local titulo	:= OemTOAnsi("RelatÛrio do faturamento por vendedor dos ˙ltimos 12 meses",72)
Local cDesc1	:= OemToAnsi("Este programa tem como objetivo emitir um relat¢rio",72)
Local cDesc2	:= OemToAnsi("do faturamento por vendedor dos ˙ltimos 12 meses.",72)
Local cDesc3	:= OemToAnsi("Conforme parametros definidos pelo o usu·rio.",72)
Local cUserAut  := GetMV("MV_URELFAT") // MCVN - 04/05/09

Private nLastKey	:= 0
Private M_PAG		:= 1
Private li			:= 67
Private cPer_Ini	:= ""
Private cPer_Fim	:= ""
Private lContinua	:= .T.
Private lEnd		:= .F.
Private tamanho	    := "G"
Private limite		:= 220
Private cString	    := "SC7"
Private nomeprog	:= "DIPR044"
Private wnrel		:= "DIPR044"

// Private cPerg		:= "DIPR44"
// FPADR(cPerg, cArq, cCampo, cTipo)  - Para ajustar o tamanho das perguntas no SX1- uso generico
PRIVATE cPerg  	    := U_FPADR( "DIPR44","SX1","SX1->X1_GRUPO"," " ) //FunÁ„o criada por Sandro em 19/11/09.

Private aVen_Fat	:= {}
Private aVen_Hq     := {} // Vendas Hq CD - JBS 21/06/2010
Private aVen_Cli	:= {}
Private aVen_Car    := {}
Private aVen_Nfs	:= {}
Private aVen_Atv	:= {}
Private aVen_Tot	:= {}

Private aReturn	    := {"Bco A4", 1,"Faturamento", 1, 2, 1,"",1}
Private aMeses      := {}
Private _cArqTRB    := ""
Private cVendInt    := GetMV("MV_DIPVINT")// MCVN - 06/05/09
Private cVendExt    := GetMV("MV_DIPVEXT")// MCVN - 06/05/09
Private cDIPR044    := GetMV("MV_DIPR044")// MCVN - 15/06/09 Usu·rio com acesso total no relatÛrio
Private cDestino    := "C:\EXCELL-DBF\"
//-------------------------------------------------------------------------------------------------------------------------------
// JBS 16/04/2010: Tratamento para montar a query quando for executado para Health Quality apenas, ou para o Grupo Dipromed.
//-------------------------------------------------------------------------------------------------------------------------------
Private aEmpresa    := {} // Empresa e filial para processar as querys
Private _cDipUsr	:= U_DipUsr()
//-------------------------------------------------------------------------------------------------------------------------------
// JBS 16/04/2010
// Se a empresa e filial corrente forem 04 e 01, forÁa o relatorio de forma individual, para n„o mostrar valores
// para pessoas que n„o possuem a necessidade da informaÁ„o.
// Para as demais, permite o usuario escolher os 4 diferentes tipos da informaÁ„o.
//-------------------------------------------------------------------------------------------------------------------------------
If cEmpAnt == '04' .and. cFilAnt == '01'
	Private nConsolida := 2
	Private lMatrizHq  := .T. // JBS 23/06/2010
Else
	Private nConsolida := Aviso('AtenÁ„o','Imprime relatorio consolidando empresas Grupo ?',{'DIPROMED','Individual','Matrizes','Todas'})
	Private lMatrizHq  := .F.  // JBS 23/06/2010
EndIf       

Private cCodTec :=  ""
Private _aCampos := {}
//-------------------------------------------------------------------------------------------------------------------------------
// Determina quais empresas devem ser processadas  - JBS 14/04/2010
//-------------------------------------------------------------------------------------------------------------------------------
do case
	case nConsolida == 1 ;	aEmpresa := {{'010','04'},{"010","01"}}  //
	case nConsolida == 2 ;	aEmpresa := {{SM0->M0_CODIGO+"0",SM0->M0_CODFIL }}
	case nConsolida == 3 ;	aEmpresa := {{'010','01'},}  //
	case nConsolida == 4 ;	aEmpresa := {{'010','01'},{'010','04'}}//,{'040','01'},{'040','04'}}  //
	OtherWise
		Return(.F.)
endcase

U_DIPPROC(ProcName(0),_cDipUsr) // JBS 05/10/2005 - Gravando o nome do Programa no SZU

// MCVN - 10/05/09
If !(Upper(_cDipUsr) $ cUserAut .Or. Upper(_cDipUsr) $ cVendInt .or. Upper(_cDipUsr) $ cVendExt) // MCVN - 07/05/09
	Alert(Upper(_cDipUsr)+", vocÍ n„o tem autorizaÁ„o para utilizar esta rotina. Qualquer d˙vida falar com Departamento de T.I.!","AtenÁ„o")
	Return()
Endif


AjustaSX1(cPerg)             // Verifica perguntas. Se nao existe INCLUI

If !Pergunte(cPerg,.T.)    // Solicita parametros
	Return
EndIf

cCodTec := DipRetTec(MV_PAR07)

wnrel := SetPrint(cString,wnrel,cPerg,Titulo,cDesc1,cDesc2,cDesc3,.f.,,.f.,tamanho,,.f.,,,,,)


If MV_PAR05 == 3 // Se For Listagem por TÈcnico
	MV_PAR04 := 2 // Sem quantidade de notas fiscais 
	MV_PAR03 := 3 // Todos os departamentos
Endif

If nLastKey == 27
	Return
Endif

SetDefault(aReturn,cString)

Processa({|lEnd| RunProc()},"Totalizando faturamento e devoluÁ„o por vendedor e mes...")

RptStatus({|lEnd| RptDetail()},"Imprimindo faturamento por vendedor e mes...")

RestArea(_xArea)
Return

/*====================================================================================\
|                                    PROCESSAMENTO DOS DADOS                          |
|====================================================================================*/
Static Function RunProc()

Local yi 		:= 1
Local xi 		:= 1
Local nSom_Cli 	:= 0
Local nTot_Fat 	:= 0
Local nMes_Ini 	:= 0
Local nTot_Atv 	:= 0
Local nAtv_Tot 	:= 0
Local nCar_Tot 	:= 0
Local cCod_Ven 	:= ""
Local cDat_Ant 	:= ""
Local _nMesFim 	:= ""
Local _nAnoFim 	:= ""
Local _nMesIni 	:= ""
Local _nAnoIni 	:= ""
Local cCod_Cli 	:= ""
Local nTot_Nfs 	:= 0
Local cQuery   	:= ""  // JBS 16/04/2010
Local cUniao   	:= ""  // JBS 16/04/2010
Local nEmp

// Determina os 12 meses que ser„o apresentados
_nMesFim := Val(Substr(mv_par01,1,2))
_nAnoFim := Val(Substr(mv_par01,3,4))       

//-------------------------------------------------------------------------------------------------------
// Ajustes para consolidar Dipromed Matriz e CD a partir de 01/05/2011   - MCVN 04/05/2011

//-- Retirado por Daniel em 05/05/2011
//If nConsolida == 1 .And. _nMesFim > Val('04') .And. _nAnoFim >= Val('2011')
//	aEmpresa := {{'010','04'},{'010','01'}}  // Empresa e filial para processar as querys
//Endif
//-------------------------------------------------------------------------------------------------------

If _nMesFim == 12
	_nMesIni := 1
	_nAnoIni := _nAnoFim
Else
	_nMesIni := _nMesFim + 1
	_nAnoIni := _nAnoFim - 1
EndIf

cPer_Ini := AllTrim(Str(_nAnoIni)) + AllTrim(StrZero(_nMesIni,2))
cPer_Fim := AllTrim(Str(_nAnoFim)) + AllTrim(StrZero(_nMesFim,2))

// MONTA ARRAY COM OS 12 MESES SELECIONADOS
cMes_Ext := Val(SubStr(cPer_Ini,5,2))
For xi:=1 to 12
	AaDd(aMeses,AllTrim(MesExtenso(cMes_Ext))+'_'+StrZero(xi,2))
	
	If cMes_Ext >= 12
		cMes_Ext := 1
	Else
		cMes_Ext++
	EndIf
Next
///////////////////////////////////////////////////
/// BLOCO PARA GERA«√O DE ARQUIVO
///////////////////////////////////////////////////
If MV_PAR06 = 1
	
	IncProc( "Criando arquivo... ")
	
	_aCampos := {}
	
	_aTamSX3 := TamSX3("U7_CODVEN")
	AAdd(_aCampos ,{"CODIGO", "C",_aTamSX3[1],_aTamSX3[2]})
	
	_aTamSX3 := TamSX3("A3_NOME")//giovani 03/08/11
	AAdd(_aCampos ,{"NOME", "C",_aTamSX3[1],_aTamSX3[2]}) 
	
	_aTamSX3 := TamSX3("B1_COD")
	AAdd(_aCampos ,{"TIPO", "C",_aTamSX3[1],_aTamSX3[2]})
	
	_aTamSX3 := TamSX3("D2_TOTAL")
	cMes_Ext := Val(SubStr(cPer_Ini,5,2))
	
	For xi:=1 to 12
		AAdd(_aCampos ,{Subs(aMeses[xi],1,3)+'_'+StrZero(xi,2), "N",_aTamSX3[1],_aTamSX3[2]})
	Next
	AAdd(_aCampos ,{"Total_13", "N",_aTamSX3[1],_aTamSX3[2]})
	AAdd(_aCampos ,{"Media_14", "N",_aTamSX3[1],_aTamSX3[2]})
	
	_aTamSX3 := TamSX3("A3_NREDUZ")//RBORGES - 20/12/2013
	AAdd(_aCampos ,{"NREDUZ", "C",_aTamSX3[1],_aTamSX3[2]})
	
	_cArqTrb := CriaTrab(_aCampos,.T.)
	DbUseArea(.T.,,_cArqTrb,"TRB",.F.,.F.)
	//	IndRegua("TRB",_cArqTrb,"CODIGO+TIPO",,,"Criando Indice...(CODIGO+TIP0)")
	
	DbSelectArea("TRB")
	RecLock("TRB",.T.)
	TRB->CODIGO := Iif(MV_PAR05==1,"Operador ","Vendedor ")
	TRB->NOME   := SubStr(cPer_Ini,5,2)+"/"+SubStr(cPer_Ini,1,4) + "-" + SubStr(cPer_Fim,5,2)+"/"+SubStr(cPer_Fim,1,4)
	TRB->(MsUnLock())
	
EndIf

ProcRegua(6)
IncProc( "Processando Vendas... ")
//-------------------------------------------------------------------------------------------
// JBS 16/04/2010 - Montagem da Query, sao duas querys unidas por empresas.
// Empresa 010 unida a empresa 040.
// Esta primeira consulta os produtos faturados dentro de um periodo e atendendo
// Aos parametros informados pelo usuario.
// A array aEmpresa determina quais empresas/filiais podem ser processadas.
//-------------------------------------------------------------------------------------------
cUniao := ""
cQuery := ""

For nEmp := 1 to len(aEmpresa)
	
	If Select('SX2_2') > 0
		SX2_2->( DbCloseArea() )
	EndIf
	
	cQuery += cUniao + fQuery01(aEmpresa[nEmp][01],aEmpresa[nEmp][02])
	cUniao := "  UNION  "
	
Next nEmp

If MV_PAR05 == 1 //(operador)
	cQuery += " ORDER BY U7_COD, SUBSTRING(D2_EMISSAO,1,6)"
ElseIf MV_PAR05 == 2 //(vendedor)
	If MV_PAR09 == 1
		cQuery += " ORDER BY (CASE WHEN D2_FORNEC = '000996' AND F2_VEND2 <> ' ' THEN F2_VEND2 ELSE F2_VEND1 END), U7_CODVEN, SUBSTRING(D2_EMISSAO,1,6)"
	Else                                                                    
		cQuery += " ORDER BY A1_VEND, U7_CODVEN, SUBSTRING(D2_EMISSAO,1,6)"		
	EndIf
Else //TÈcnico
    cQuery += " ORDER BY " +cCodTec+ ", SUBSTRING(D2_EMISSAO,1,6)"   
EndIf

If Select("QRY1") > 0
	QRY1->( DbCloseArea() )
EndIf

TcQuery cQuery NEW ALIAS "QRY1"
memowrite('DIPR044_QRY1'+SM0->M0_CODIGO+'0'+SM0->M0_CODFIL+'.SQL',cQuery)

//--------------------------------------------------------------------------------------
// JBS 16/04/2010 - Tratamento para para apurar devoluÁıes
//--------------------------------------------------------------------------------------
cUniao := ""
cQuery := ""

For nEmp := 1 to len(aEmpresa)
	
	If Select('SX2_2') > 0
		SX2_2->( DbCloseArea() )
	EndIf
	
	cQuery += cUniao + fQuery02(aEmpresa[nEmp][01],aEmpresa[nEmp][02])
	cUniao  := "  UNION  "
	
Next nEmp

If MV_PAR05 == 1 //(operador)
	cQuery += " ORDER BY U7_COD, SUBSTRING(D1_DTDIGIT,1,6)"
ElseIf  MV_PAR05 == 2//(vendedor)
	If MV_PAR09 == 1
		cQuery += " ORDER BY (CASE WHEN D2_FORNEC = '000996' AND F2_VEND2 <> ' ' THEN F2_VEND2 ELSE F2_VEND1 END), SUBSTRING(D1_DTDIGIT,1,6)"
	Else 
		cQuery += " ORDER BY A1_VEND, SUBSTRING(D1_DTDIGIT,1,6)"
	EndIf
Else //TÈcnico
    cQuery += " ORDER BY " + cCodTec + ",  SUBSTRING(D1_DTDIGIT,1,6) "   
EndIf

If Select("QRY2") > 0
	QRY2->( DbCloseArea() )
EndIf

IncProc( "Processando DevoluÁıes... ")

TcQuery cQuery NEW ALIAS "QRY2"
memowrite('DIPR044_QRY2'+SM0->M0_CODIGO+'0'+SM0->M0_CODFIL+'.SQL',cQuery)

If MV_PAR04 == 1
    
	IncProc( "Totalizando Notas Fiscais por vendedor... ")

	cUniao := ""
	cQuery := ""
	
	For nEmp := 1 to len(aEmpresa)
		
		If Select('SX2_2') > 0
			SX2_2->( DbCloseArea() )
		EndIf
		
		cQuery += cUniao + fQuery03(aEmpresa[nEmp][01],aEmpresa[nEmp][02])
		cUniao  := "  UNION  "
		
	Next nEmp
	
	If MV_PAR05 == 1 //(operador)
		cQuery += " ORDER BY U7_CODVEN, C5_OPERADO, SUBSTRING(F2_EMISSAO,1,6), F2_VEND1"
	ElseIf MV_PAR05 == 2 //(vendedor)
		If MV_PAR09 == 1
			cQuery += " ORDER BY (CASE WHEN D2_FORNEC = '000996' AND F2_VEND2 <> ' ' THEN F2_VEND2 ELSE F2_VEND1 END), SUBSTRING(F2_EMISSAO,1,6)"
		Else 
			cQuery += " ORDER BY A1_VEND, SUBSTRING(F2_EMISSAO,1,6)"			
		EndIf
	Else //TÈcnico
    	cQuery += " ORDER BY " + cCodTec + ",  SUBSTRING(F2_EMISSAO,1,6) "   	
	EndIf
	
	If Select("QRY3") > 0
		QRY3->( DbCloseArea() )
	EndIf
	
	TcQuery cQuery NEW ALIAS "QRY3"
	memowrite('DIPR044_QRY3'+SM0->M0_CODIGO+'0'+SM0->M0_CODFIL+'.SQL',cQuery)

	IncProc( "Processando Clientes Ativos por vendedor... ")
	
	cUniao := ""
	cQuery := ""
	
	For nEmp := 1 to len(aEmpresa)
		
		If Select('SX2_2') > 0
			SX2_2->( DbCloseArea() )
		EndIf
		
		cQuery += cUniao + fQuery04(aEmpresa[nEmp][01],aEmpresa[nEmp][02])
		cUniao  := "  UNION  "
		
	Next nEmp
	
	If MV_PAR05 == 1 //(operador)
		cQuery += " ORDER BY U7_COD, SUBSTRING(D2_EMISSAO,1,6)"
	ElseIf MV_PAR05 == 2 //(vendedor)
		If MV_PAR09 == 1
			cQuery += " ORDER BY (CASE WHEN D2_FORNEC = '000996' AND F2_VEND2 <> ' ' THEN F2_VEND2 ELSE F2_VEND1 END),  SUBSTRING(D2_EMISSAO,1,6)"
		Else 
			cQuery += " ORDER BY A1_VEND,  SUBSTRING(D2_EMISSAO,1,6)"
		EndIf
	Else //TÈcnico
    	cQuery += " ORDER BY " + cCodTec + ", SUBSTRING(D2_EMISSAO,1,6) "   			
	EndIf
	
	If Select("QRY4") > 0
		QRY4->( DbCloseArea() )
	EndIf
	
	TcQuery cQuery NEW ALIAS "QRY4"
	memowrite('DIPR044_QRY4'+SM0->M0_CODIGO+'0'+SM0->M0_CODFIL+'.SQL',cQuery)
	
EndIf

If MV_PAR05 == 2 // Vendedor
	

	IncProc( "Carteira de Clientes por vendedor... ")
	
	/*-- CARTEIRA DE CLIENTES POR VENDEDOR (total)
	SELECT A1_VEND, COUNT(*) QUANTOS
	FROM SA1010 AS SA1
	WHERE SA1.D_E_L_E_T_ = ''
	AND A1_PRICOM != ''
	GROUP BY A1_VEND
	ORDER BY A1_VEND
	*/
	
	QRY5 := " SELECT A1_VEND, COUNT(*) QUANTOS"
	QRY5 += " FROM  " + RetSQLName('SA1')
	QRY5 += " WHERE " + RetSQLName('SA1') + ".D_E_L_E_T_ = ''"
    QRY5 += " AND A1_VEND  BETWEEN '"+MV_PAR10+"' AND '"+MV_PAR11+"' " //RSB - 26/08/2013 - PESQUISA POR VENDEDOR 	
	
	If U_ListVend() != '' .And. !(Upper(_cDipUsr) $ cDIPR044) // Liberando DIPR044 para alguns usu·rios  MCVN-15/06/09
		QRY5 += " AND A1_VEND "+U_ListVend()
	EndIf
	If !Empty(MV_PAR08)
		QRY5 +=  " AND A1_GRPVEN = '"+MV_PAR08+"'"
	EndIf
	QRY5 += " GROUP BY A1_VEND"
	QRY5 += " ORDER BY A1_VEND"
	
	TcQuery QRY5 NEW ALIAS "QRY5"         // Abre uma workarea com o resultado da query
	memowrite('DIPR044_QRY5'+SM0->M0_CODIGO+'0'+SM0->M0_CODFIL+'.SQL',QRY5)
	
	DbSelectArea("QRY5")

	IncProc( "Carteira de Clientes por mÍs... ")
	
	/*-- CARTEIRA DE CLIENTES POR VENDEDOR (mensal)
	SELECT A1_VEND, SUBSTRING(A1_PRICOM,1,6) A1_PRICOM, COUNT(*) QUANTOS
	FROM SA1010 AS SA1
	WHERE SUBSTRING(A1_PRICOM,1,6) BETWEEN '200308' AND '200407'
	AND SA1.D_E_L_E_T_ = ''
	GROUP BY A1_VEND, SUBSTRING(A1_PRICOM,1,6)
	ORDER BY A1_VEND, SUBSTRING(A1_PRICOM,1,6) DESC
	*/
	
	QRY6 := " SELECT A1_VEND, SUBSTRING(A1_PRICOM,1,6) A1_PRICOM, COUNT(*) QUANTOS "
	QRY6 += " FROM " +  RetSQLName('SA1')
	QRY6 += " WHERE SUBSTRING(A1_PRICOM,1,6) BETWEEN '" + Substr(cPer_Ini,1,6) + "' AND '" + Substr(cPer_Fim,1,6) +"'"
  	QRY6 += " AND " + RetSQLName('SA1') + ".D_E_L_E_T_ = ''"
	If U_ListVend() != '' .And. !(Upper(_cDipUsr) $ cDIPR044) // Liberando DIPR044 para alguns usu·rios  MCVN-15/06/09
		QRY6 += " AND A1_VEND " + U_ListVend()
	EndIf
	If !Empty(MV_PAR08)
		QRY6 +=  " AND A1_GRPVEN = '" + MV_PAR08 + "'"
	EndIf
	QRY6 += " GROUP BY A1_VEND, SUBSTRING(A1_PRICOM,1,6)"
	QRY6 += " ORDER BY A1_VEND, SUBSTRING(A1_PRICOM,1,6) DESC"
	
	TcQuery QRY6 NEW ALIAS "QRY6"         // Abre uma workarea com o resultado da query
	memowrite('DIPR044_QRY6'+SM0->M0_CODIGO+'0'+SM0->M0_CODFIL+'.SQL',QRY6)
	
	DbSelectArea("QRY6")
	
EndIf

IncProc( "Finalizando Processamento... ")

/*====================================================================================\
|                                    TOTALIZANDO FATURAMENTO                          |
|====================================================================================*/
DbSelectArea("QRY1")
QRY1->(DbGotop())

// Inicializa vari·veis de controle
xi := 0
ProcRegua(3000)

Do While QRY1->(!Eof())
	
	nMes_Ini := Val(Substr(cPer_Ini,5,2)) /// MÍs inicial informado pelo usu·rio
	yi := 3 // Inicia na 3a. posiÁ„o depois do cÛdigo e nome do vendedor
	
	If MV_PAR05 == 1 // operador  
	
				
		IncProc( "Totalizando faturamento por vendedor e operador... " + Substr(ALLTRIM(QRY1->U7_NOME),1,15))//GIOVANI ALTERADO NREDUZ PARA NOME  26/07/2011
		
		If MV_PAR03 == 1 //(apoio)
			If !Empty(QRY1->U7_CODVEN) //(callcenter)
				If QRY1->U7_CODVEN == '000204' // CRISTINA URIAS
					
					Aadd(aVen_HQ, { QRY1->U7_COD, Substr(ALLTRIM(QRY1->U7_NOME),1,15), 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0})//GIOVANI ALTERADO NREDUZ PARA NOME  26/07/2011
					Aadd(aVen_Fat,{ QRY1->U7_COD, Substr(ALLTRIM(QRY1->U7_NOME),1,15), 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0})//GIOVANI ALTERADO NREDUZ PARA NOME  26/07/2011
					xi++
					//
					// Faz enquanto for Cristina Urias
					//
					Do While QRY1->U7_CODVEN == '000204'
						//
						// Posiciona o array conforme o mÍs
						//
						Do While Val(Substr(QRY1->D2_EMISSAO,5,2)) != nMes_Ini
							If nMes_Ini == 12
								nMes_Ini := 1
							Else
								nMes_Ini++
							EndIf
							yi++
						EndDo
						
						Begin Sequence
						//--------------------------------------------------------------------------------------------------------
						// JBS 24/06/2010 - HQ CD ('000851','000847','051508')
						//--------------------------------------------------------------------------------------------------------
						If QRY1->D2_FORNEC $ '000851/000847/051508' .and. QRY1->D2_FILIAL == '04' //.and. QRY1->D2_CODEMP = '010'
							
							aVen_HQ[xi,yi] += QRY1->D2_TOTAL // Lanca o valor na posicaoo do Array
							aVen_HQ[xi,15] += QRY1->D2_TOTAL // Acumula valor para coluna de total
							//-----------------------------------------------------------------------------------------------------
							// Nesta situacao, os dados da filial 04 da empresa 04 deve ser desconsiderados, pois a query foi forca
							// para trazer estas informacoes, as quais mudariam o valor do faturamento apurado dentro da empresa.
							//-----------------------------------------------------------------------------------------------------
							If (nConsolida == 2 .and. lMatrizHq) .or. nConsolida == 3
								Break
							EndIf
							
						EndIf
						
						aVen_Fat[xi,yi] += QRY1->D2_TOTAL // Lanca o valor na posicaoo do Array
						aVen_Fat[xi,15] += QRY1->D2_TOTAL // Acumula valor para coluna de total
						
						End Sequence
						
						QRY1->(DbSkip())
						
					EndDo
					//--------------------------------------------------------------------------------------------------------
					// Calcula a Media de Faturamento  - JBS 24/06/2010
					//--------------------------------------------------------------------------------------------------------
					aVen_HQ[xi,16] := aVen_HQ[xi,15]/12  // Media Faturada
					aVen_Fat[xi,16]:= aVen_Fat[xi,15]/12 // Media Faturada
					
				Else
					QRY1->(DbSkip())
				EndIf
				
			Else //(apoio)
				
				cCodigo := QRY1->U7_COD
				
				Aadd(aVen_HQ, { QRY1->U7_COD, Substr(ALLTRIM(QRY1->U7_NOME),1,15), 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0})//GIOVANI ALTERADO NREDUZ PARA NOME  26/07/2011
				Aadd(aVen_Fat,{ QRY1->U7_COD, Substr(ALLTRIM(QRY1->U7_NOME),1,15), 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0})//GIOVANI ALTERADO NREDUZ PARA NOME  26/07/2011
				
				xi++
				
				Do While QRY1->U7_COD == cCodigo
					
					// Posiciona o array conforme o mÍs

					Do While Val(Substr(QRY1->D2_EMISSAO,5,2)) != nMes_Ini
						If nMes_Ini == 12
							nMes_Ini := 1
						Else
							nMes_Ini++
						EndIf
						yi++
					EndDo
					
					Begin Sequence
					
					//--------------------------------------------------------------------------------------------------------
					// JBS 24/06/2010 - HQ CD ('000851','000847','051508')
					//--------------------------------------------------------------------------------------------------------
					
					If QRY1->D2_FORNEC $ '000851/000847/051508' .and. QRY1->D2_FILIAL == '04' //.and. QRY1->D2_CODEMP = '010'
					
						aVen_HQ[xi,yi] += QRY1->D2_TOTAL // Lanca o valor na posicaoo do Array
						aVen_HQ[xi,15] += QRY1->D2_TOTAL // Acumula valor para coluna de total
						
						//-----------------------------------------------------------------------------------------------------
						// Nesta situacao, os dados da filial 04 da empresa 04 deve ser desconsiderados, pois a query foi forca
						// para trazer estas informacoes, as quais mudariam o valor do faturamento apurado dentro da empresa.
						//-----------------------------------------------------------------------------------------------------
						If (nConsolida == 2 .and. lMatrizHq) .or. nConsolida == 3
							Break
						EndIf
						
					EndIf
					
					aVen_Fat[xi,yi] += QRY1->D2_TOTAL // Lanca o valor na posicaoo do Array
					aVen_Fat[xi,15] += QRY1->D2_TOTAL // Acumula valor para coluna de total
					
					End Sequence
					
					QRY1->(DbSkip())
					
				EndDo
				//--------------------------------------------------------------------------------------------------------
				// Calcula a Media de Faturamento  - JBS 24/06/2010
				//--------------------------------------------------------------------------------------------------------
				aVen_HQ[xi,16] := aVen_HQ[xi,15]/12  // Media Faturada
				aVen_Fat[xi,16]:= aVen_Fat[xi,15]/12 // Media Faturada
				
			EndIf
			
		ElseIf MV_PAR03 == 2 //(callcenter)
			 	
			IF QRY1->U7_CODVEN == '000201' .or.QRY1->U7_CODVEN == '000193'
			    nJilton := 19680401
			EndIF               
			
			If Empty(QRY1->U7_CODVEN) //(apoio)
				QRY1->(DbSkip())
			Else //(callcenter)
				
				If QRY1->U7_CODVEN == '000204' //(cristina urias)
					QRY1->(DbSkip())
				Else
					
					cCodigo := QRY1->U7_CODVEN
					
					Aadd(aVen_HQ, { QRY1->U7_COD, Substr(ALLTRIM(QRY1->U7_NOME),1,15), 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0})//GIOVANI ALTERADO NREDUZ PARA NOME  26/07/2011
					Aadd(aVen_Fat,{ QRY1->U7_COD, Substr(ALLTRIM(QRY1->U7_NOME),1,15), 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0})//GIOVANI ALTERADO NREDUZ PARA NOME  26/07/2011
					
					xi++
					
					Do While QRY1->U7_CODVEN == cCodigo
						
						// Posiciona o array conforme o mÍs
						Do While Val(Substr(QRY1->D2_EMISSAO,5,2)) != nMes_Ini
							If nMes_Ini == 12
								nMes_Ini := 1
							Else
								nMes_Ini++
							EndIf
							yi++
						EndDo
				
						Begin Sequence
				
						//--------------------------------------------------------------------------------------------------------
						// JBS 24/06/2010 - HQ CD ('000851','000847','051508')
						//--------------------------------------------------------------------------------------------------------
				
						If QRY1->D2_FORNEC $ '000851/000847/051508' .and. QRY1->D2_FILIAL == '04' //.and. QRY1->D2_CODEMP = '010'
				
							aVen_HQ[xi,yi] += QRY1->D2_TOTAL // Lanca o valor na posicaoo do Array
							aVen_HQ[xi,15] += QRY1->D2_TOTAL // Acumula valor para coluna de total
							//-----------------------------------------------------------------------------------------------------
							// Nesta situacao, os dados da filial 04 da empresa 04 deve ser desconsiderados, pois a query foi forca
							// para trazer estas informacoes, as quais mudariam o valor do faturamento apurado dentro da empresa.
							//-----------------------------------------------------------------------------------------------------
							If (nConsolida == 2 .and. lMatrizHq) .or. nConsolida == 3
								Break
							EndIf
						EndIf
						
						aVen_Fat[xi,yi] += QRY1->D2_TOTAL // Lanca o valor na posicaoo do Array
						aVen_Fat[xi,15] += QRY1->D2_TOTAL // Acumula valor para coluna de total
						
						End Sequence
						
						QRY1->(DbSkip())
						
					EndDo
					//--------------------------------------------------------------------------------------------------------
					// Calcula a Media de Faturamento  - JBS 24/06/2010
					//--------------------------------------------------------------------------------------------------------
					aVen_HQ[xi,16] := aVen_HQ[xi,15]/12  // Media Faturada
					aVen_Fat[xi,16]:= aVen_Fat[xi,15]/12 // Media Faturada
					
				EndIf
			EndIf
			
		Else // AMBOS
			
			IF QRY1->U7_COD == '000201' .or. QRY1->U7_COD == '000193'
			    nJilton := 19680401
			EndIF               

			cCodigo := QRY1->U7_COD
			
			Aadd(aVen_HQ, { QRY1->U7_COD, Substr(ALLTRIM(QRY1->U7_NOME),1,15), 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0})//GIOVANI ALTERADO NREDUZ PARA NOME  26/07/2011
			Aadd(aVen_Fat,{ QRY1->U7_COD, Substr(ALLTRIM(QRY1->U7_NOME),1,15), 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0})//GIOVANI ALTERADO NREDUZ PARA NOME  26/07/2011
			
			xi++
			
			Do While QRY1->U7_COD == cCodigo
				
				// Posiciona o array conforme o mÍs

				Do While Val(Substr(QRY1->D2_EMISSAO,5,2)) != nMes_Ini
					If nMes_Ini == 12
						nMes_Ini := 1
					Else
						nMes_Ini++
					EndIf
					yi++
				EndDo
				
				Begin Sequence
				
				//--------------------------------------------------------------------------------------------------------
				// JBS 24/06/2010 - HQ CD ('000851','000847','051508')
				//--------------------------------------------------------------------------------------------------------
				
				If QRY1->D2_FORNEC $ '000851/000847/051508' .and. QRY1->D2_FILIAL == '04' //.and. QRY1->D2_CODEMP = '010'
				
					aVen_HQ[xi,yi] += QRY1->D2_TOTAL // Lanca o valor na posicaoo do Array
					aVen_HQ[xi,15] += QRY1->D2_TOTAL // Acumula valor para coluna de total
					//-----------------------------------------------------------------------------------------------------
					// Nesta situacao, os dados da filial 04 da empresa 04 deve ser desconsiderados, pois a query foi forca
					// para trazer estas informacoes, as quais mudariam o valor do faturamento apurado dentro da empresa.
					//-----------------------------------------------------------------------------------------------------
					If (nConsolida == 2 .and. lMatrizHq) .or. nConsolida == 3
						Break
					EndIf
				EndIf
				
				aVen_Fat[xi,yi] += QRY1->D2_TOTAL // Lanca o valor na posicaoo do Array
				aVen_Fat[xi,15] += QRY1->D2_TOTAL // Acumula valor para coluna de total
				
				End Sequence
				
				QRY1->( DbSkip() )
				
			EndDo
			//--------------------------------------------------------------------------------------------------------
			// Calcula a Media de Faturamento  - JBS 24/06/2010
			//--------------------------------------------------------------------------------------------------------
			aVen_HQ[xi,16] := aVen_HQ[xi,15]/12  // Media Faturada
			aVen_Fat[xi,16]:= aVen_Fat[xi,15]/12 // Media Faturada
			
		EndIf
		
	ElseIf MV_PAR05 == 2 //(vendedor)
		
			
		IncProc( "Totalizando faturamento por vendedor e operador... " + QRY1->A3_NOME)//giovani 03/08/11
		
		If MV_PAR03 == 1 //(apoio)
			If !Empty(QRY1->U7_CODVEN) //(callcenter)
				If QRY1->U7_CODVEN == '000204' //(CRISTINA URIAS)
					
					Aadd(aVen_HQ, { QRY1->VEND, QRY1->A3_NOME, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0})//giovani 03/08/11
					Aadd(aVen_Fat,{ QRY1->VEND, QRY1->A3_NOME, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0})//giovani 03/08/11
					
					xi++
					
					Do While QRY1->U7_CODVEN == '000204'

						// Posiciona o array conforme o mÍs

						Do While Val(Substr(QRY1->D2_EMISSAO,5,2)) != nMes_Ini
							If nMes_Ini == 12
								nMes_Ini := 1
							Else
								nMes_Ini++
							EndIf
							yi++
						EndDo
						
						Begin Sequence
						
						//--------------------------------------------------------------------------------------------------------
						// JBS 24/06/2010 - HQ CD ('000851','000847','051508')
						//--------------------------------------------------------------------------------------------------------

						If QRY1->D2_FORNEC $ '000851/000847/051508' .and. QRY1->D2_FILIAL == '04' //.and. QRY1->D2_CODEMP = '010'

							aVen_HQ[xi,yi] += QRY1->D2_TOTAL // Lanca o valor na posicaoo do Array
							aVen_HQ[xi,15] += QRY1->D2_TOTAL // Acumula valor para coluna de total
							//-----------------------------------------------------------------------------------------------------
							// Nesta situacao, os dados da filial 04 da empresa 04 deve ser desconsiderados, pois a query foi forca
							// para trazer estas informacoes, as quais mudariam o valor do faturamento apurado dentro da empresa.
							//-----------------------------------------------------------------------------------------------------
							If (nConsolida == 2 .and. lMatrizHq) .or. nConsolida == 3
								Break
							EndIf

						EndIf
						
						aVen_Fat[xi,yi] += QRY1->D2_TOTAL // Lanca o valor na posicaoo do Array
						aVen_Fat[xi,15] += QRY1->D2_TOTAL // Acumula valor para coluna de total
						
						End Sequence
						
						QRY1->(DbSkip())
						
					EndDo
					//--------------------------------------------------------------------------------------------------------
					// Calcula a Media de Faturamento  - JBS 24/06/2010
					//--------------------------------------------------------------------------------------------------------
					aVen_HQ[xi,16] := aVen_HQ[xi,15]/12  // Media Faturada
					aVen_Fat[xi,16]:= aVen_Fat[xi,15]/12 // Media Faturada
					
				Else
					QRY1->(DbSkip())
				EndIf
				
			Else //(apoio)
				
				cCodigo := QRY1->VEND
				
				Aadd(aVen_HQ, { QRY1->VEND, QRY1->A3_NOME, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0})//giovani 03/08/11
				Aadd(aVen_Fat,{ QRY1->VEND, QRY1->A3_NOME, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0})//giovani 03/08/11
				
				xi++
				
				Do While QRY1->VEND == cCodigo

					// Posiciona o array conforme o mÍs

					Do While Val(Substr(QRY1->D2_EMISSAO,5,2)) != nMes_Ini
						If nMes_Ini == 12
							nMes_Ini := 1
						Else
							nMes_Ini++
						EndIf
						yi++
					EndDo
					
					Begin Sequence
					
					//--------------------------------------------------------------------------------------------------------
					// JBS 24/06/2010 - HQ CD ('000851','000847','051508')
					//--------------------------------------------------------------------------------------------------------
					If QRY1->D2_FORNEC $ '000851/000847/051508' .and. QRY1->D2_FILIAL == '04' //.and. QRY1->D2_CODEMP = '010'

						aVen_HQ[xi,yi] += QRY1->D2_TOTAL // Lanca o valor na posicaoo do Array
						aVen_HQ[xi,15] += QRY1->D2_TOTAL // Acumula valor para coluna de total

						//-----------------------------------------------------------------------------------------------------
						// Nesta situacao, os dados da filial 04 da empresa 04 deve ser desconsiderados, pois a query foi forca
						// para trazer estas informacoes, as quais mudariam o valor do faturamento apurado dentro da empresa.
						//-----------------------------------------------------------------------------------------------------
						If (nConsolida == 2 .and. lMatrizHq) .or. nConsolida == 3
							Break
						EndIf

					EndIf
					
					aVen_Fat[xi,yi] += QRY1->D2_TOTAL // Lanca o valor na posicaoo do Array
					aVen_Fat[xi,15] += QRY1->D2_TOTAL // Acumula valor para coluna de total
					
					End Sequence
					
					QRY1->(DbSkip())
					
				EndDo
				//--------------------------------------------------------------------------------------------------------
				// Calcula a Media de Faturamento  - JBS 24/06/2010
				//--------------------------------------------------------------------------------------------------------
				aVen_HQ[xi,16] := aVen_HQ[xi,15]/12  // Media Faturada
				aVen_Fat[xi,16]:= aVen_Fat[xi,15]/12 // Media Faturada
				
			EndIf
			
		ElseIf MV_PAR03 == 2 //(callcenter)
			
			If Empty(QRY1->U7_CODVEN) //(apoio)
				QRY1->(DbSkip())
				
			Else //(callcenter)
				
				If QRY1->U7_CODVEN == '000204' //(cristina urias)
					QRY1->(DbSkip())
				Else
					
					cCodigo := QRY1->U7_CODVEN
					
					Aadd(aVen_HQ, { QRY1->VEND, QRY1->A3_NOME, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0})//giovani 03/08/11
					Aadd(aVen_Fat,{ QRY1->VEND, QRY1->A3_NOME, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0})//giovani 03/08/11
					
					xi++
					
					Do While QRY1->U7_CODVEN == cCodigo

						// Posiciona o array conforme o mÍs

						Do While Val(Substr(QRY1->D2_EMISSAO,5,2)) != nMes_Ini
							If nMes_Ini == 12
								nMes_Ini := 1
							Else
								nMes_Ini++
							EndIf
							yi++
						EndDo
						
						Begin Sequence
						
						//--------------------------------------------------------------------------------------------------------
						// JBS 24/06/2010 - HQ CD ('000851','000847','051508')
						//--------------------------------------------------------------------------------------------------------

						If QRY1->D2_FORNEC $ '000851/000847/051508' .and. QRY1->D2_FILIAL == '04' //.and. QRY1->D2_CODEMP = '010'

							aVen_HQ[xi,yi] += QRY1->D2_TOTAL // Lanca o valor na posicaoo do Array
							aVen_HQ[xi,15] += QRY1->D2_TOTAL // Acumula valor para coluna de total

							//-----------------------------------------------------------------------------------------------------
							// Nesta situacao, os dados da filial 04 da empresa 04 deve ser desconsiderados, pois a query foi forca
							// para trazer estas informacoes, as quais mudariam o valor do faturamento apurado dentro da empresa.
							//-----------------------------------------------------------------------------------------------------
							If (nConsolida == 2 .and. lMatrizHq) .or. nConsolida == 3
								Break
							EndIf

						EndIf
						
						aVen_Fat[xi,yi] += QRY1->D2_TOTAL // Lanca o valor na posicaoo do Array
						aVen_Fat[xi,15] += QRY1->D2_TOTAL // Acumula valor para coluna de total
						
						End Sequence
						
						QRY1->(DbSkip())
						
					EndDo
					//--------------------------------------------------------------------------------------------------------
					// Calcula a Media de Faturamento  - JBS 24/06/2010
					//--------------------------------------------------------------------------------------------------------
					aVen_HQ[xi,16] := aVen_HQ[xi,15]/12  // Media Faturada
					aVen_Fat[xi,16]:= aVen_Fat[xi,15]/12 // Media Faturada
					
				EndIf
			EndIf
		Else // AMBOS
			cCodigo := QRY1->VEND
			
			Aadd(aVen_HQ, { QRY1->VEND, QRY1->A3_NOME, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0})//giovani 03/08/11
			Aadd(aVen_Fat,{ QRY1->VEND, QRY1->A3_NOME, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0})//giovani 03/08/11
			
			xi++
			
			Do While QRY1->VEND == cCodigo
                //
				// Posiciona o array conforme o mÍs
				//
				Do While Val(Substr(QRY1->D2_EMISSAO,5,2)) != nMes_Ini
					If nMes_Ini == 12
						nMes_Ini := 1
					Else
						nMes_Ini++
					EndIf
					yi++
				EndDo
				
				Begin Sequence
				
				//--------------------------------------------------------------------------------------------------------
				// JBS 24/06/2010 - HQ CD ('000851','000847','051508')
				//--------------------------------------------------------------------------------------------------------

				If QRY1->D2_FORNEC $ '000851/000847/051508' .and. QRY1->D2_FILIAL == '04' //.and. QRY1->D2_CODEMP = '010'

					aVen_HQ[xi,yi] += QRY1->D2_TOTAL // Lanca o valor na posicaoo do Array
					aVen_HQ[xi,15] += QRY1->D2_TOTAL // Acumula valor para coluna de total

					//-----------------------------------------------------------------------------------------------------
					// Nesta situacao, os dados da filial 04 da empresa 04 deve ser desconsiderados, pois a query foi forca
					// para trazer estas informacoes, as quais mudariam o valor do faturamento apurado dentro da empresa.
					//-----------------------------------------------------------------------------------------------------
					If (nConsolida == 2 .and. lMatrizHq) .or. nConsolida == 3
						Break
					EndIf

				EndIf
				
				aVen_Fat[xi,yi] += QRY1->D2_TOTAL // Lanca o valor na posicaoo do Array
				aVen_Fat[xi,15] += QRY1->D2_TOTAL // Acumula valor para coluna de total
				
				End Sequence
				
				QRY1->(DbSkip())
				
			EndDo
			//--------------------------------------------------------------------------------------------------------
			// Calcula a Media de Faturamento  - JBS 24/06/2010
			//--------------------------------------------------------------------------------------------------------
			aVen_HQ[xi,16] := aVen_HQ[xi,15]/12  // Media Faturada
			aVen_Fat[xi,16]:= aVen_Fat[xi,15]/12 // Media Faturada
			
		EndIf
	Else //TÈcnico
		
		IncProc( "Totalizando faturamento por TÈcnico... " + QRY1->A3_NOME)//giovani 03/08/11
		
		cCodigo := &("QRY1->"+cCodTec)
			

	  	Aadd(aVen_HQ, { &("QRY1->"+cCodTec),QRY1->A3_NOME , 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0})//giovani 03/08/11
		Aadd(aVen_Fat,{ &("QRY1->"+cCodTec),QRY1->A3_NOME , 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0})//giovani 03/08/11
		
		xi++
			
		Do While cCodigo == &("QRY1->"+cCodTec)
               //
			// Posiciona o array conforme o mÍs
			//
			Do While Val(Substr(QRY1->D2_EMISSAO,5,2)) != nMes_Ini
				If nMes_Ini == 12
					nMes_Ini := 1
				Else
					nMes_Ini++
				EndIf
				yi++
			EndDo
			
			Begin Sequence
			
			//--------------------------------------------------------------------------------------------------------
			// JBS 24/06/2010 - HQ CD ('000851','000847','051508')
			//--------------------------------------------------------------------------------------------------------
				If QRY1->D2_FORNEC $ '000851/000847/051508' .and. QRY1->D2_FILIAL == '04' //.and. QRY1->D2_CODEMP = '010'
					aVen_HQ[xi,yi] += QRY1->D2_TOTAL // Lanca o valor na posicaoo do Array
					aVen_HQ[xi,15] += QRY1->D2_TOTAL // Acumula valor para coluna de total
					//-----------------------------------------------------------------------------------------------------
				// Nesta situacao, os dados da filial 04 da empresa 04 deve ser desconsiderados, pois a query foi forca
				// para trazer estas informacoes, as quais mudariam o valor do faturamento apurado dentro da empresa.
				//-----------------------------------------------------------------------------------------------------
					If (nConsolida == 2 .and. lMatrizHq) .or. nConsolida == 3
						Break
					EndIf
				EndIf
		
			aVen_Fat[xi,yi] += QRY1->D2_TOTAL // Lanca o valor na posicaoo do Array
			aVen_Fat[xi,15] += QRY1->D2_TOTAL // Acumula valor para coluna de total
			
			End Sequence
			
			QRY1->(DbSkip())
			
		EndDo
		//--------------------------------------------------------------------------------------------------------
		// Calcula a Media de Faturamento  - JBS 24/06/2010
		//--------------------------------------------------------------------------------------------------------
		aVen_HQ[xi,16] := aVen_HQ[xi,15]/12  // Media Faturada
		aVen_Fat[xi,16]:= aVen_Fat[xi,15]/12 // Media Faturada			
	EndIf
EndDo
/*====================================================================================\
|                                    TOTALIZANDO DEVOLU«’ES                           |
|====================================================================================*/
DbSelectArea("QRY2")
QRY2->(DbGotop())

ProcRegua(3000)

Do While QRY2->(!Eof())
	yi := 3
	nMes_Ini := Val(Substr(cPer_Ini,5,2))
	
	If MV_PAR05 == 1 //(operador)
		IncProc( "Totalizando devoluÁıes por vendedor... " + ALLTRIM(QRY2->U7_NOME))//GIOVANI ALTERADO NREDUZ PARA NOME  26/07/2011
		
		Begin Sequence
		
		//--------------------------------------------------------------------------------------------------------
		// JBS 24/06/2010 - HQ CD ('000851','000847','051508')
		//--------------------------------------------------------------------------------------------------------
		
		If QRY2->D2_FORNEC $ '000851/000847/051508' .and. QRY2->D1_FILIAL == '04' //.and. QRY2->D1_CODEMP = '010'
			
			nPos := aScan(aVen_HQ, { |x| x[1] == QRY2->U7_COD })
			
			If nPos > 0
			    //
				// Posiciona o array conforme o mÍs
				//
				Do While Val(Substr(QRY2->D1_DTDIGIT,5,2)) != nMes_Ini
					If nMes_Ini == 12
						nMes_Ini := 1
					Else
						nMes_Ini++
					EndIf
					yi++
				EndDo
				
				aVen_HQ[nPos,yi] := aVen_HQ[nPos,yi] - QRY2->D1_TOTAL /// acumula total
				aVen_HQ[nPos,15] := aVen_HQ[nPos,15] - QRY2->D1_TOTAL /// Total Faturado
				aVen_HQ[nPos,16] := aVen_HQ[nPos,15] / 12 /// MÈdia Faturada
				
				//-----------------------------------------------------------------------------------------------------
				// Nesta situacao, os dados da filial 04 da empresa 04 deve ser desconsiderados, pois a query foi forca
				// para trazer estas informacoes, as quais mudariam o valor do faturamento apurado dentro da empresa.
				//-----------------------------------------------------------------------------------------------------
				If (nConsolida == 2 .and. lMatrizHq) .or. nConsolida == 3
					Break
				EndIf

			EndIf
			
		EndIf
		
		nPos := aScan(aVen_Fat, { |x| x[1] == QRY2->U7_COD })
		
		If nPos > 0
		    //
			// Posiciona o array conforme o mÍs
			//
			Do While Val(Substr(QRY2->D1_DTDIGIT,5,2)) != nMes_Ini
				If nMes_Ini == 12
					nMes_Ini := 1
				Else
					nMes_Ini++
				EndIf
				yi++
			EndDo
		
			aVen_Fat[nPos,yi] -= QRY2->D1_TOTAL         // acumula total
			aVen_Fat[nPos,15] -= QRY2->D1_TOTAL         // Total Faturado
			aVen_Fat[nPos,16] := aVen_Fat[nPos,16] / 12 // MÈdia Faturada

		EndIf
		
		End Sequence
		
		QRY2->(DbSkip())
		
	ElseIf MV_PAR05 == 2 //(vendedor)
		
		IncProc( "Totalizando devoluÁıes por vendedor... " + QRY2->A3_NOME)//giovani 03/08/11
		
		Begin Sequence
		
		//--------------------------------------------------------------------------------------------------------
		// JBS 24/06/2010 - HQ CD ('000851','000847','051508')
		//--------------------------------------------------------------------------------------------------------

		If QRY2->D2_FORNEC $ '000851/000847/051508' .and. QRY2->D1_FILIAL == '04' //.and. QRY2->D1_CODEMP = '010'
			
			nPos := aScan(aVen_HQ, { |x| x[1] == QRY2->VEND })
			
			If nPos > 0
                //
				// Posiciona o array conforme o mÍs
				//
				Do While Val(Substr(QRY2->D1_DTDIGIT,5,2)) != nMes_Ini
					If nMes_Ini == 12
						nMes_Ini := 1
					Else
						nMes_Ini++
					EndIf
					yi++
				EndDo

				aVen_HQ[nPos,yi] := aVen_HQ[nPos,yi] - QRY2->D1_TOTAL /// acumula total
				aVen_HQ[nPos,15] := aVen_HQ[nPos,15] - QRY2->D1_TOTAL /// Total Faturado
				aVen_HQ[nPos,16] := aVen_HQ[nPos,15] / 12 /// MÈdia Faturada

				//-----------------------------------------------------------------------------------------------------
				// Nesta situacao, os dados da filial 04 da empresa 04 deve ser desconsiderados, pois a query foi forca
				// para trazer estas informacoes, as quais mudariam o valor do faturamento apurado dentro da empresa.
				//-----------------------------------------------------------------------------------------------------
				If (nConsolida == 2 .and. lMatrizHq) .or. nConsolida == 3
					Break
				EndIf

			EndIf
			
		EndIf
		
		nPos := aScan(aVen_Fat, { |x| x[1] == QRY2->VEND })
		
		If nPos > 0
            //
			// Posiciona o array conforme o mÍs
            //
			Do While Val(Substr(QRY2->D1_DTDIGIT,5,2)) != nMes_Ini
				If nMes_Ini == 12
					nMes_Ini := 1
				Else
					nMes_Ini++
				EndIf
				yi++
			EndDo

			aVen_Fat[nPos,yi] -= QRY2->D1_TOTAL /// acumula total
			aVen_Fat[nPos,15] -= QRY2->D1_TOTAL /// Total Faturado
			aVen_Fat[nPos,16] := aVen_Fat[nPos,16]/12 /// MÈdia Faturada

		EndIf
		
		End Sequence
		
		QRY2->(DbSkip())

	Else // TÈcnico
		
		IncProc( "Totalizando devoluÁıes por TÈcnico... " + QRY2->A3_NOME)//giovani 03/08/11
		
		Begin Sequence
		
		//--------------------------------------------------------------------------------------------------------
		// JBS 24/06/2010 - HQ CD ('000851','000847','051508')
		//--------------------------------------------------------------------------------------------------------

		If QRY2->D2_FORNEC $ '000851/000847/051508' .and. QRY2->D1_FILIAL == '04' //.and. QRY2->D1_CODEMP = '010'
			
			nPos := aScan(aVen_HQ, { |x| x[1] == &("QRY2->"+cCodTec)    })
			
			If nPos > 0
                //
				// Posiciona o array conforme o mÍs
				//
				Do While Val(Substr(QRY2->D1_DTDIGIT,5,2)) != nMes_Ini
					If nMes_Ini == 12
						nMes_Ini := 1
					Else
						nMes_Ini++
					EndIf
					yi++
				EndDo

				aVen_HQ[nPos,yi] := aVen_HQ[nPos,yi] - QRY2->D1_TOTAL /// acumula total
				aVen_HQ[nPos,15] := aVen_HQ[nPos,15] - QRY2->D1_TOTAL /// Total Faturado
				aVen_HQ[nPos,16] := aVen_HQ[nPos,15] / 12 /// MÈdia Faturada

				//-----------------------------------------------------------------------------------------------------
				// Nesta situacao, os dados da filial 04 da empresa 04 deve ser desconsiderados, pois a query foi forca
				// para trazer estas informacoes, as quais mudariam o valor do faturamento apurado dentro da empresa.
				//-----------------------------------------------------------------------------------------------------
				If (nConsolida == 2 .and. lMatrizHq) .or. nConsolida == 3
					Break
				EndIf

			EndIf
			
		EndIf
		
		nPos := aScan(aVen_Fat, { |x| x[1] == &("QRY2->"+cCodTec)    })
		
		If nPos > 0
            //
			// Posiciona o array conforme o mÍs
            //
			Do While Val(Substr(QRY2->D1_DTDIGIT,5,2)) != nMes_Ini
				If nMes_Ini == 12
					nMes_Ini := 1
				Else
					nMes_Ini++
				EndIf
				yi++
			EndDo

			aVen_Fat[nPos,yi] -= QRY2->D1_TOTAL /// acumula total
			aVen_Fat[nPos,15] -= QRY2->D1_TOTAL /// Total Faturado
			aVen_Fat[nPos,16] := aVen_Fat[nPos,16]/12 /// MÈdia Faturada

		EndIf
		
		End Sequence
		
		QRY2->(DbSkip())

	EndIf
EndDo

/*====================================================================================\
|                                    TOTALIZANDO NFs                                  |
|====================================================================================*/

If MV_PAR04 == 1
	
	DbSelectArea("QRY3")
	QRY3->(DbGotop())
	xi	:= 0
	
	ProcRegua(3300)
	Do While QRY3->(!Eof()) .And. MV_PAR05 <> 3
		
		// Inicializa vari·veis de controle
		xi++
		yi := 3
		nTot_Nfs := 0
		nMes_Ini := Val(Substr(cPer_Ini,5,2))
		
		If MV_PAR05 == 1 //(operador)
			// Inicializa vari·veis de controle
			cCod_Ven := QRY3->C5_OPERADO
			IncProc( "Totalizando NFs por operador... " + QRY3->C5_OPERADO)
			Aadd(aVen_Nfs,{ QRY3->C5_OPERADO, "NFs", 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0})
			Do While cCod_Ven == QRY3->C5_OPERADO
				// Posiciona o array conforme o mÍs
				Do While Val(Substr(QRY3->F2_EMISSAO,5,2)) != nMes_Ini
					If nMes_Ini == 12
						nMes_Ini := 1
					Else
						nMes_Ini++
					EndIf
					yi++
				EndDo
				aVen_Nfs[xi,yi] += QRY3->F2_QTDNF /// acumula total
				nTot_Nfs += QRY3->F2_QTDNF
				QRY3->(DbSkip())
			EndDo
			aVen_Nfs[xi,15] := nTot_Nfs      /// Total Acumulado
			aVen_Nfs[xi,16] := nTot_Nfs / 12 /// MÈdia do Total Acumulado
			
		ElseIf MV_PAR05 == 2 //(vendedor)
			
			cCod_Ven := QRY3->VEND
			IncProc( "Totalizando NFs por vendedor... " + QRY3->VEND)
			Aadd(aVen_Nfs,{ QRY3->VEND, "NFs", 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0})
			Do While cCod_Ven == QRY3->VEND
				// Posiciona o array conforme o mÍs
				Do While Val(Substr(QRY3->F2_EMISSAO,5,2)) != nMes_Ini
					If nMes_Ini == 12
						nMes_Ini := 1
					Else
						nMes_Ini++
					EndIf
					yi++
				EndDo
				aVen_Nfs[xi,yi] += QRY3->F2_QTDNF /// acumula total
				nTot_Nfs += QRY3->F2_QTDNF
				QRY3->(DbSkip())
			EndDo
			aVen_Nfs[xi,15] := nTot_Nfs      /// Total Acumulado
			aVen_Nfs[xi,16] := nTot_Nfs / 12 /// MÈdia do Total Acumulado
		EndIf
	EndDo
	
	/*====================================================================================\
	|                                TOTALIZANDO CLIENTES ATIVOS                          |
	|====================================================================================*/
	
	DbSelectArea("QRY4")
	QRY4->(DbGotop())
	
	ProcRegua(3300)
	xi	:= 0
	
	Do While QRY4->(!Eof())
		
		// Inicializa vari·veis de controle
		xi++
		yi := 3
		nSom_Cli := 0
		nTot_Cli := 0
		cNum_Cli := ""
		nMes_Ini := Val(Substr(cPer_Ini,5,2))
		
		If MV_PAR05 == 1 // OPERADOR - Totaliza clientes ativos mÍs a mÍs
			IncProc( "Totalizando clientes ativos por operador... " + ALLTRIM(QRY4->U7_NOME))//GIOVANI ALTERADO NREDUZ PARA NOME  26/07/2011
			
			Aadd(aVen_Atv,{QRY4->C5_OPERADO, ALLTRIM(QRY4->U7_NOME), 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0})//GIOVANI ALTERADO NREDUZ PARA NOME  26/07/2011
			cCod_Ven := QRY4->C5_OPERADO
			
			Do While cCod_Ven == QRY4->C5_OPERADO
				nSom_Cli := 0
				cDat_Ant := QRY4->D2_EMISSAO
				Do While cDat_Ant == QRY4->D2_EMISSAO
					If cCod_Ven != QRY4->C5_OPERADO
						Exit
					EndIf
					// Posiciona o array conforme o mÍs
					Do While Val(Substr(QRY4->D2_EMISSAO,5,2)) != nMes_Ini
						If nMes_Ini == 12
							nMes_Ini := 1
						Else
							nMes_Ini++
						EndIf
						yi++
					EndDo
					nSom_Cli++
					If !(QRY4->D2_CLIENTE $ cNum_Cli)
						nTot_Cli++
						cNum_Cli += AllTrim(QRY4->D2_CLIENTE) + "#"
					EndIf
					QRY4->(DbSkip())
				EndDo
				aVen_Atv[xi,yi] := nSom_Cli /// acumula total
				nAtv_Tot += nSom_Cli
			EndDo
			aVen_Atv[xi,15] := nAtv_Tot
			nAtv_Tot := 0
		ElseIf MV_PAR05 == 2 // VENDEDOR - Totaliza clientes ativos mÍs a mÍs
			
			IncProc( "Totalizando clientes ativos por vendedor... " + QRY4->A3_NOME)//giovani 03/08/11
			
			Aadd(aVen_Atv,{ QRY4->VEND, QRY4->A3_NOME, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0})//giovani 03/08/11
			cCod_Ven := QRY4->VEND
			Do While cCod_Ven == QRY4->VEND
				nSom_Cli := 0
				cDat_Ant := QRY4->D2_EMISSAO
				Do While cDat_Ant == QRY4->D2_EMISSAO
					If cCod_Ven != QRY4->VEND
						Exit
					EndIf
					// Posiciona o array conforme o mÍs
					Do While Val(Substr(QRY4->D2_EMISSAO,5,2)) != nMes_Ini
						If nMes_Ini == 12
							nMes_Ini := 1
						Else
							nMes_Ini++
						EndIf
						yi++
					EndDo
					nSom_Cli++
					If !(QRY4->D2_CLIENTE $ cNum_Cli)
						nTot_Cli++
						cNum_Cli += AllTrim(QRY4->D2_CLIENTE) + "#"
					EndIf
					QRY4->(DbSkip())
				EndDo
				aVen_Atv[xi,yi] := nSom_Cli /// acumula total
				
				nAtv_Tot += nSom_Cli
			EndDo
			aVen_Atv[xi,15] := nAtv_Tot
			nAtv_Tot := 0
			//aVen_Atv[xi,15] := nTot_Cli /// acumula total
		Else //TÈcnico
			
			IncProc( "Totalizando clientes ativos por tÈcnico... " + QRY4->A3_NOME)//giovani 03/08/11
			
			Aadd(aVen_Atv,{ &("QRY4->"+cCodTec), QRY4->A3_NOME, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0})//giovani 03/08/11
			cCod_Ven := &("QRY4->"+cCodTec)
		    
			Do While cCod_Ven == &("QRY4->"+cCodTec)
				nSom_Cli := 0
				cDat_Ant := QRY4->D2_EMISSAO
				Do While cDat_Ant == QRY4->D2_EMISSAO
					If cCod_Ven != &("QRY4->"+cCodTec) 
						Exit
					EndIf
					// Posiciona o array conforme o mÍs
					Do While Val(Substr(QRY4->D2_EMISSAO,5,2)) != nMes_Ini
						If nMes_Ini == 12
							nMes_Ini := 1
						Else
							nMes_Ini++
						EndIf
						yi++
					EndDo
					nSom_Cli++
					If !(QRY4->D2_CLIENTE $ cNum_Cli)
						nTot_Cli++
						cNum_Cli += AllTrim(QRY4->D2_CLIENTE) + "#"
					EndIf
					QRY4->(DbSkip())
				EndDo
				aVen_Atv[xi,yi] := nSom_Cli /// acumula total
				
				nAtv_Tot += nSom_Cli
			EndDo
			aVen_Atv[xi,15] := nAtv_Tot
			nAtv_Tot := 0
			//aVen_Atv[xi,15] := nTot_Cli /// acumula total
		EndIf
	EndDo
EndIf


/*====================================================================================\
|                      TOTALIZANDO CARTEIRA DE CLIENTES POR VENDEDOR                  |
\====================================================================================*/
If MV_PAR05 == 2 // Vendedor
	ProcRegua(3300)
	zi := 0
	aVen_Car := {}
	cDat_Ini := ""
	nQtd_Mes := 0
	
	While QRY5->(!Eof())
		IncProc( "Carteira de Clientes (totais)... " + QRY5->A1_VEND)
		zi++
		Aadd(aVen_Car,{QRY5->A1_VEND, "Carteira", QRY5->QUANTOS, QRY5->QUANTOS, QRY5->QUANTOS, QRY5->QUANTOS, QRY5->QUANTOS, QRY5->QUANTOS, QRY5->QUANTOS, QRY5->QUANTOS, QRY5->QUANTOS, QRY5->QUANTOS, QRY5->QUANTOS, QRY5->QUANTOS, QRY5->QUANTOS})
		QRY5->(DbSkip())
	EndDo
	
	
	While QRY6->(!Eof())
		
		IncProc( "Carteira de Clientes (meses)... " + QRY6->A1_VEND)
		
		nPos := aScan(aVen_Car, { |x| x[1] == QRY6->A1_VEND })
		If nPos > 0
			nQtd_Mes := 0
			cDat_Ini := Substr(cPer_Fim,1,6)
			
			For yi:=14 to 3 step -1
				If aVen_Car[nPos,1] == QRY6->A1_VEND
					If cDat_Ini == Substr(QRY6->A1_PRICOM,1,6)
						If aVen_Car[nPos,yi+1] > QRY6->QUANTOS
							aVen_Car[nPos,yi] := aVen_Car[nPos,yi+1] - QRY6->QUANTOS
						Else
							aVen_Car[nPos,yi] := aVen_Car[nPos,yi+1]
						EndIf
						QRY6->(DbSkip())
					Else
						aVen_Car[nPos,yi] := aVen_Car[nPos,yi+1]
					EndIf
					If Substr(cDat_Ini,5,2) == "01"
						cDat_Ini := AllTrim(Str(Val(Substr(cDat_Ini,1,4))-1)) + "12"
					Else
						cDat_Ini := Substr(cDat_Ini,1,4) + Iif((Val(Substr(cDat_Ini,5,2))-1)<10,"0","") + AllTrim(Str(Val(Substr(cDat_Ini,5,2))-1))
					EndIf
				Else
					aVen_Car[npos,yi] := aVen_Car[nPos,yi+1]
				EndIf
				nCar_Tot += aVen_Car[npos,yi]
				
			Next
			aVen_Car[npos,15] := nCar_Tot
			nCar_Tot := 0
		EndIf
		QRY6->(DbSkip())
	EndDo
EndIf

QRY1->(DbCloseArea())
QRY2->(DbCloseArea())
If MV_PAR05 == 2 // Vendedor
	QRY5->(DbCloseArea())
	QRY6->(DbCloseArea())
EndIf
If MV_PAR04 == 1
	QRY3->(DbCloseArea())
	QRY4->(DbCloseArea())
EndIf

Return


/*====================================================================================\
|                                   MONTAGEM DO RELAT”RIO                             |
|====================================================================================*/
Static Function RptDetail()

Local _nMesIni := Val(Substr(MV_PAR01,1,2))
Local _nAnoIni := Val(Substr(MV_PAR01,3,4))
Local _cTitulo := "Faturamento por Vendedor 12 " +Iif(MV_PAR09 == 2,"(Carteira)  ",Iif(MV_PAR05==1,"(Operador) ",Iif(MV_PAR05==2,"(Vendedor) ","(Tecnico) ")))
Local _cDesc1  := Iif(MV_PAR05==1,"Operador ",Iif(MV_PAR05==2,"Vendedor ","Tecnico")) + Space(27)
Local _cDesc2  := ""
Local nTot_Mes := 0
Local nSom_Tot := 0 
Local nPosHQ   := 0 // JBS 10/08/2010
Local xI, yi, nI
//Local cArqExcell:= GetSrvProfString("STARTPATH","")+"Excell-DBF\"+_cDipUsr+"-FatVen12" // MCVN 08/02/2008

// Alterado para gravar arquivos no protheus_data - Por Sandro 19/11/09.
Local cArqExcell:= "\Excell-DBF\"+_cDipUsr+"-FatVen12" 
Local aTmp := {}
Local nColuna
// Ajusta para a coluna que ser· colocada em ordem
If Val(MV_PAR02) > 14
	nColuna := 16
Else
	nColuna := Val(MV_PAR02)+2
EndIf
aSort( aVen_Fat ,,, {|a,b| a[nColuna] > b[nColuna]} )
//aSort( aVen_HQ  ,,, {|a,b| a[nColuna] > b[nColuna]} )

// Monta tÌtulo conforme par‚metro (Vendedor / Operador)
If MV_PAR03 == 1
	_cTitulo += " de "+SubStr(cPer_Ini,5,2)+"/"+SubStr(cPer_Ini,1,4) + " atÈ " + SubStr(cPer_Fim,5,2)+"/"+SubStr(cPer_Fim,1,4) + " - Apoio"
ElseIf MV_PAR03 == 2
	_cTitulo += " de "+SubStr(cPer_Ini,5,2)+"/"+SubStr(cPer_Ini,1,4) + " atÈ " + SubStr(cPer_Fim,5,2)+"/"+SubStr(cPer_Fim,1,4) + " - CallCenter"
Else
	_cTitulo += " de "+SubStr(cPer_Ini,5,2)+"/"+SubStr(cPer_Ini,1,4) + " atÈ " + SubStr(cPer_Fim,5,2)+"/"+SubStr(cPer_Fim,1,4)
EndIf

_cTitulo += If(!Empty(MV_PAR07),' - Fornecedor: '+If(MV_PAR07$"000851/051508","000851/051508",MV_PAR07),'') + " - ordem: coluna "+AllTrim(MV_PAR02)

// MONTA O CABECALHO COM OS 12 MESES SELECIONADOS
For xi:=1 to 12
	_nTamMes := 13 - Len(aMeses[xi])
	_cDesc1 += Space(_nTamMes)+aMeses[xi]
Next
_cDesc1 += Space(06) + "Total_13" + Space(05) + "MÈdia_14"

SetRegua(Len(aVen_Fat))

*                                                                                                    1                                                                                                   2                                                                                                   3
*          1         2         3         4         5         6         7         8         9         0         1         2         3         4         5         6         7         8         9         0         1         2         3         4         5         6         7         8         9         0         1         2         3         4         5         6
*01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
*Vendedor                     Janeiro    Fevereiro        MarÁo        Abril         Maio        Junho        Julho       Agosto     Setembro      Outubro     Novembro     Dezembro           Total        MÈdia
*-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*123456789012345-999999  9.999.999,99 9.999.999,99 9.999.999,99 9.999.999,99 9.999.999,99 9.999.999,99 9.999.999,99 9.999.999,99 9.999.999,99 9.999.999,99 9.999.999,99 9.999.999,99    9.999.999,99 9.999.999,99
*-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*Total Geral Faturado    9.999.999,99 9.999.999,99 9.999.999,99 9.999.999,99 9.999.999,99 9.999.999,99 9.999.999,99 9.999.999,99 9.999.999,99 9.999.999,99 9.999.999,99 9.999.999,99 9.999.999,99 9.999.999,99
//
// Array para armazenar os totais
//
Aadd(aVen_Tot,{ "TotaiS", "       R$"            , 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0})
Aadd(aVen_Tot,{ "TotaiS", "       Prod HQ no CD" , 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0})
Aadd(aVen_Tot,{ "TotaiS", "       NFs"           , 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0})
Aadd(aVen_Tot,{ "TotaiS", "       NF MÈdiA"      , 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0})
Aadd(aVen_Tot,{ "TotaiS", "       AtivoS"        , 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0})
Aadd(aVen_Tot,{ "TotaiS", "       ComprA MÈdiA"  , 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0})
Aadd(aVen_Tot,{ "TotaiS", "       CarteirA"      , 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0})

For xi := 1 To Len(aVen_Fat)
	
	IncRegua( "Imprimindo Faturamento por vendedor: " + aVen_Fat[xi,2] )
	//
	// Quebra de p·gina
	//
	If li > 66
		li := Cabec(_cTitulo,_cDesc1,_cDesc2,nomeprog,tamanho) + 1
	EndIf
	//
	// Cria uma linha em branco no arquivo
	//
	If MV_PAR06 = 1
		DbSelectArea("TRB")
		RecLock("TRB",.T.)
		TRB->(MsUnLock())
	EndIf
	//
	// Impress„o do nome do operador ou vendedor
	//
	@ li,000 PSay aVen_Fat[xi,1] + "-" +AllTrim(aVen_Fat[xi,2]) // CÛdigo-Nome do vendedor ou operador
	//
	// Grava dados do venddor ou operador no arquivo
	//
	If MV_PAR06 = 1
		DbSelectArea("TRB")
		RecLock("TRB",.T.)
		TRB->CODIGO := aVen_Fat[xi,1]
		TRB->NOME   := AllTrim(aVen_Fat[xi,2])
		TRB->TIPO   := "1-R$" 
	    TRB->NREDUZ := POSICIONE("SA3",1,xFilial("SA3")+aVen_Fat[xi,1],"A3_NREDUZ") //RBORGES - 20/12/2013 
	EndIf
	//
	// Inicio da impress„o do faturamento por operador
	//
	@ li,024 PSay "R$"
	nCol := 37
	nSom_Tot := 0
	nTot_Mes := 0
	
	For yi := 3 To 14
		
		@ li,nCol PSay aVen_Fat[xi,yi] Picture "@E 9,999,999.99"
		nCol+=13
		nSom_Tot += aVen_Fat[xi,yi]
		
		// Totaliza qtos. meses possui valores maior que zero (0)
		If aVen_Fat[xi,yi] > 0
			nTot_Mes++
		EndIf
		
		// Grava valores do vendedor ou operador no arquivo
		If MV_PAR06 = 1
			cNom_Cam := "TRB->"+Subs(aMeses[yi-2],1,3)+'_'+StrZero(yi-2,2)
			&cNom_Cam := aVen_Fat[xi,yi]
		EndIf
		
		// Armazena os valores e totaliza os valores no Array de TOTAIS
		aVen_Tot[1,yi] += aVen_Fat[xi,yi]
		
	Next
	
	// Impress„o das colunas de Total(13) e MÈdia(14)
	@ li,nCol PSay nSom_Tot Picture "@E 99,999,999.99"
	nCol+=14
	@ li,nCol PSay (nSom_Tot/nTot_Mes) Picture "@E 9,999,999.99"
	li++
	nVal_001 := nSom_Tot
	nVal_003 := nSom_Tot/nTot_Mes
	
	// Quebra de p·gina
	If li > 66
		li := Cabec(_cTitulo,_cDesc1,_cDesc2,nomeprog,tamanho) + 1
	EndIf
	
	// Grava Total e MÈdia do vendedor ou operador no arquivo
	If MV_PAR06 = 1
		TRB->TOTAL_13 := nSom_Tot
		TRB->MEDIA_14 := (nSom_Tot/nTot_Mes)
		TRB->(MsUnLock())
	EndIf
	//--------------------------------------------------------------------------------------------------------------
	// JBS - 10/08/2010 
	// Desenvolvido tratamento para localiacao da posicao do array em relacao ao vendedor que esta sendo impresso
	// pelo  array aFat_ven[][]
	//--------------------------------------------------------------------------------------------------------------
	If (nPosHQ := Ascan(aVen_HQ,{|x| x[1] == aVen_Fat[xi,1] })) > 0 // JBS 10/08/2010
		
		If MV_PAR06 = 1 .And. MV_PAR05 <> 3
			DbSelectArea("TRB")
			RecLock("TRB",.T.)
			TRB->CODIGO := aVen_HQ[xi,1]
			TRB->NOME := AllTrim(aVen_HQ[nPosHQ,2])
			TRB->TIPO := "2-Prod HQ no CD"
		    TRB->NREDUZ := POSICIONE("SA3",1,xFilial("SA3")+aVen_Fat[xi,1],"A3_NREDUZ")  //RBORGES - 20/12/2013
		EndIf
		
		If MV_PAR05 <> 3
			@ li,024 PSay "Prod HQ no CD"
			nCol     := 37
			nSom_Tot := 0
			nTot_Mes := 0
			For yi := 3 To 14
				
				@ li,nCol PSay aVen_HQ[nPosHQ,yi] Picture "@E 9,999,999.99"
				nCol += 13
				nSom_Tot += aVen_HQ[nPosHQ,yi]
				//
				// Totaliza qtos. meses possui valores maior que zero (0)
				//
				If aVen_HQ[nPosHQ,yi] > 0
					nTot_Mes++
				EndIf
				//
				// Grava valores do vendedor ou operador no arquivo
				//
		
			
				If MV_PAR06 = 1
					cNom_Cam  := "TRB->"+Subs(aMeses[yi-2],1,3)+'_'+StrZero(yi-2,2)
					&cNom_Cam := aVen_HQ[nPosHQ,yi]
				EndIf
				//
				// Armazena os valores e totaliza os valores no Array de TOTAIS
				//
				aVen_Tot[2,yi] += aVen_HQ[nPosHQ,yi]
			
			Next		
		//
		// Impress„o das colunas de Total(13) e MÈdia(14)
		//
		@ li,nCol PSay nSom_Tot Picture "@E 99,999,999.99"
		nCol+=14
		@ li,nCol PSay (nSom_Tot/nTot_Mes) Picture "@E 9,999,999.99"
		li++
		// nVal_001 := nSom_Tot
		// nVal_003 := nSom_Tot/nTot_Mes
		Endif
	EndIf
	// Quebra de p·gina
	
	If li > 66
		li := Cabec(_cTitulo,_cDesc1,_cDesc2,nomeprog,tamanho) + 1
	EndIf
	//
	// Grava Total e MÈdia do vendedor ou operador no arquivo
	//
	If MV_PAR06 = 1
		TRB->TOTAL_13 := nSom_Tot
		TRB->MEDIA_14 := (nSom_Tot/nTot_Mes)
		TRB->(MsUnLock())
	EndIf
    //}
	// -----------------------------------------------------------------------------------------//
	
	If MV_PAR04 == 1
		
		// Posiciona o array atual conforme array de faturamento
		nPos := aScan(aVen_Nfs,{|x| x[1] == aVen_Fat[xi,1]})
		                                                                                 
		If nPos > 0
			// Grava dados do vendedor ou operador no arquivo
			If MV_PAR06 = 1
				DbSelectArea("TRB")
				RecLock("TRB",.T.)
				TRB->CODIGO := aVen_Fat[xi,1]
				TRB->NOME := AllTrim(aVen_Fat[xi,2])
				TRB->TIPO := "3-NFs"
        	    TRB->NREDUZ := POSICIONE("SA3",1,xFilial("SA3")+aVen_Fat[xi,1],"A3_NREDUZ")  //RBORGES - 20/12/2013
			EndIf
			
			// inicio da impress„o das Notas Fiscais por operador
			nCol := 37
			nSom_Tot := 0
			nTot_Mes := 0
			@ li,024 PSay "NFs"
			
			// LaÁo para impress„o das colunas de valores
			For yi := 3 To 14
				@ li,nCol PSay aVen_Nfs[nPos,yi] Picture "@E 9999,999,999"
				nCol+=13
				nSom_Tot += aVen_Nfs[nPos,yi]
				
				// Totaliza qtos. meses possui valores maior que zero (0)
				If aVen_Nfs[nPos,yi] > 0
					nTot_Mes++
				EndIf
				
				// Grava valores do vendedor ou operador no arquivo
				If MV_PAR06 = 1
					cNom_Cam := "TRB->"+Subs(aMeses[yi-2],1,3) + '_' + StrZero(yi-2,2)
					&cNom_Cam := aVen_Nfs[nPos,yi]
				EndIf
				
				// Armazena os valores e totaliza os valores no Array de TOTAIS
				aVen_Tot[3,yi] += aVen_Nfs[nPos,yi]
				
			Next
			
			// Impress„o das colunas de Total(13) e MÈdia(14)
			@ li,1+nCol PSay nSom_Tot Picture "@E 9999,999,999"
			nCol+=13
			@ li,nCol+1 PSay (nSom_Tot/nTot_Mes) Picture "@E 9999,999,999"
			li++
			nVal_002 := nSom_Tot
			
			// Quebra de p·gina
			If li > 66
				li := Cabec(_cTitulo,_cDesc1,_cDesc2,nomeprog,tamanho) + 1
			EndIf
			
			// Grava Total e MÈdia do vendedor ou operador no arquivo
			If MV_PAR06 = 1
				TRB->TOTAL_13 := nSom_Tot
				TRB->MEDIA_14 := (nSom_Tot/nTot_Mes)
				TRB->(MsUnLock())
			EndIf
		EndIf
		//-----------------------------------------------------------------------------------------//
		
		If nPos > 0
			// Grava dados do vendedor ou operador no arquivo
			If MV_PAR06 = 1
				DbSelectArea("TRB")
				RecLock("TRB",.T.)
				TRB->CODIGO := aVen_Fat[xi,1]
				TRB->NOME := AllTrim(aVen_Fat[xi,2])
				TRB->TIPO := "4-NF MÈdiA"
			    TRB->NREDUZ := POSICIONE("SA3",1,xFilial("SA3")+aVen_Fat[xi,1],"A3_NREDUZ") //RBORGES - 20/12/2013 	
			EndIf
			
			// Inicio da impress„o da mÈdia do faturamento por nota fiscal
			nCol := 37
			nSom_Tot := 0
			nTot_Mes := 0
			@ li,024 PSay "NF MÈdiA"
			
			// LaÁo para impress„o das colunas de valores
			For yi := 3 To 14
				@ li,nCol PSay aVen_Fat[xi,yi] / aVen_Nfs[nPos,yi] Picture "@E 9,999,999.99"
				nCol+=13
				nSom_Tot += aVen_Fat[xi,yi] / aVen_Nfs[nPos,yi]
				
				// Totaliza qtos. meses possui valores maior que zero (0)
				If aVen_Fat[xi,yi] / aVen_Nfs[nPos,yi] > 0
					nTot_Mes++
				EndIf
				
				// Grava valores do vendedor ou operador no arquivo
				If MV_PAR06 = 1
					cNom_Cam := "TRB->"+Subs(aMeses[yi-2],1,3)+'_'+StrZero(yi-2,2)
					&cNom_Cam := aVen_Fat[xi,yi] / aVen_Nfs[nPos,yi]
				EndIf
				
				// Armazena os valores e totaliza os valores no Array de TOTAIS
				aVen_Tot[4,yi] += aVen_Fat[xi,yi] / aVen_Nfs[nPos,yi]
				
			Next
			
			// Impress„o das colunas de Total(13) e MÈdia(14)
			@ li,nCol PSay (nVal_001/nVal_002) Picture "@E 99,999,999.99"
			//			nCol+=14
			//			@ li,nCol PSay ((nVal_001/nVal_002)/nTot_Mes) Picture "@E 9,999,999.99"
			li++
			
			// Quebra de p·gina
			If li > 66
				li := Cabec(_cTitulo,_cDesc1,_cDesc2,nomeprog,tamanho) + 1
			EndIf
			
			// Grava Total e MÈdia do vendedor ou operador no arquivo
			If MV_PAR06 = 1
				TRB->TOTAL_13 := nSom_Tot
				TRB->MEDIA_14 := (nSom_Tot/nTot_Mes)
				TRB->(MsUnLock())
			EndIf
		EndIf
		
		//-----------------------------------------------------------------------------------------//
		
		// Posiciona o array atual conforme array de faturamento
		nPos := aScan(aVen_Atv,{|x| x[1] == aVen_Fat[xi,1]})
		
		If nPos > 0
			// Grava dados do vendedor ou operador no arquivo
			If MV_PAR06 = 1
				DbSelectArea("TRB")
				RecLock("TRB",.T.)
				TRB->CODIGO := aVen_Fat[xi,1]
				TRB->NOME := AllTrim(aVen_Fat[xi,2])
				TRB->TIPO := "5-AtivoS"
			    TRB->NREDUZ := POSICIONE("SA3",1,xFilial("SA3")+aVen_Fat[xi,1],"A3_NREDUZ") //RBORGES - 20/12/2013 
			EndIf
			
			// inicio da impress„o dos clientes ativos
			nCol := 37
			nSom_Tot := 0
			nTot_Mes := 0
			ci := 1
			@ li,024 PSay "AtivoS"
			
			// LaÁo para impress„o das colunas de valores
			For yi := 3 To 14
				@ li,nCol PSay aVen_Atv[nPos,yi] Picture "@E 9999,999,999"
				nCol+=13
				
				// Totaliza qtos. meses possui valores maior que zero (0)
				If aVen_Atv[nPos,yi] > 0
					nTot_Mes++
				EndIf
				
				// Grava valores do vendedor ou operador no arquivo
				If MV_PAR06 = 1
					cNom_Cam := "TRB->"+Subs(aMeses[yi-2],1,3)+'_'+StrZero(yi-2,2)
					&cNom_Cam := aVen_Atv[nPos,yi]
				EndIf
				
				// Armazena os valores e totaliza os valores no Array de TOTAIS
				aVen_Tot[5,yi] += aVen_Atv[nPos,yi]
				
			Next
			
			// Impress„o das colunas de Total(13) e MÈdia(14)
			//			@ li,nCol+1 PSay aVen_Atv[nPos,15] Picture "@E 9999,999,999"
			nCol+=14
			@ li,nCol PSay (aVen_Atv[nPos,15]/nTot_Mes) Picture "@E 9,999,999999"
			li++
			nVal_004 := Round(aVen_Atv[nPos,15]/nTot_Mes,0)
			
			// Quebra de p·gina
			If li > 66
				li := Cabec(_cTitulo,_cDesc1,_cDesc2,nomeprog,tamanho) + 1
			EndIf
			
			// Grava Total do vendedor ou operador no arquivo
			If MV_PAR06 = 1
				TRB->TOTAL_13 := aVen_Atv[nPos,14]
				TRB->(MsUnLock())
			EndIf
		EndIf
	EndIf
	
	//-----------------------------------------------------------------------------------------//
	
	// Posiciona o array atual conforme array de faturamento
	nPos := aScan(aVen_Atv,{|x| x[1] == aVen_Fat[xi,1]})
	
	If nPos > 0
		//
		// Grava dados do vendedor ou operador no arquivo
		//
		If MV_PAR06 = 1
			DbSelectArea("TRB")
			RecLock("TRB",.T.)
			TRB->CODIGO := aVen_Fat[xi,1]
			TRB->NOME := AllTrim(aVen_Fat[xi,2])
			TRB->TIPO := "6-ComprA MÈdiA"
		    TRB->NREDUZ := POSICIONE("SA3",1,xFilial("SA3")+aVen_Fat[xi,1],"A3_NREDUZ") //RBORGES - 20/12/2013 			
		EndIf
		//
		// Inicio da impress„o da linha de mÈdia de compra
		//
		nCol := 37
		nSom_Tot := 0
		nTot_Mes := 0
		@ li,024 PSay "ComprA MÈdiA"
		//
		// LaÁo para impress„o das colunas de valores
		//
		For yi := 3 To 14
			If aVen_Fat[xi,yi] <= 0 .or. aVen_Atv[nPos,yi] <= 0
				@ li,nCol PSay 0 Picture "@E 9,999,999.99"
			Else
				@ li,nCol PSay aVen_Fat[xi,yi] / aVen_Atv[nPos,yi] Picture "@E 9,999,999.99"
			EndIf
			nCol+=13
			nSom_Tot += aVen_Fat[xi,yi] / aVen_Atv[nPos,yi]
			//
			// Totaliza qtos. meses possui valores maior que zero (0)
			//
			If aVen_Fat[xi,yi] > 0 .and. aVen_Atv[nPos,yi] > 0
				nTot_Mes++
			EndIf
			//
			// Grava valores do vendedor ou operador no arquivo
			//
			If MV_PAR06 = 1
				cNom_Cam := "TRB->"+Subs(aMeses[yi-2],1,3)+'_'+StrZero(yi-2,2)
				&cNom_Cam := aVen_Fat[xi,yi] / aVen_Atv[nPos,yi]
			EndIf
			//
			// Armazena os valores e totaliza os valores no Array de TOTAIS
			//
			aVen_Tot[6,yi] += aVen_Fat[xi,yi] / aVen_Atv[nPos,yi]
			
		Next
		//
		// Impress„o das colunas de Total(13) e MÈdia(14)
		//		@ li,nCol PSay nSom_Tot Picture "@E 99,999,999.99"
		nCol+=14
		@ li,nCol PSay (nVal_003/nVal_004) Picture "@E 9,999,999.99"
		li++
		//
		// Quebra de p·gina    
		//
		If li > 66
			li := Cabec(_cTitulo,_cDesc1,_cDesc2,nomeprog,tamanho) + 1
		EndIf
		//
		// Grava Total do vendedor ou operador no arquivo
		//
		If MV_PAR06 = 1
			TRB->TOTAL_13 := nSom_Tot
			TRB->MEDIA_14 := (nSom_Tot/nTot_Mes)
			TRB->(MsUnLock())
		EndIf
	EndIf
	//-----------------------------------------------------------------------------------------//
	
	If MV_PAR05 == 2 // Vendedor
		
		// Posiciona o array atual conforme array de faturamento
		nPos := aScan(aVen_Car,{|x| x[1] == aVen_Fat[xi,1]})
		
		If nPos > 0
			// impress„o carteira de clientes
			nCol := 37
			nTot_Mes := 0
			@ li,024 PSay "CarteirA"
			
			// Grava dados do vendedor ou operador no arquivo
			If MV_PAR06 = 1
				DbSelectArea("TRB")
				RecLock("TRB",.T.)
				TRB->CODIGO := aVen_Fat[xi,1]
				TRB->NOME := AllTrim(aVen_Fat[xi,2])
				TRB->TIPO := "7-CarteirA"
			    TRB->NREDUZ := POSICIONE("SA3",1,xFilial("SA3")+aVen_Fat[xi,1],"A3_NREDUZ") //RBORGES - 20/12/2013 
			EndIf
			
			// LaÁo para impress„o das colunas de valores
			For yi := 3 To 14
				@ li,nCol PSay aVen_Car[nPos,yi] Picture "@E 9999,999,999"
				nCol+=13
				
				// Totaliza qtos. meses possui valores maior que zero (0)
				If aVen_Car[nPos,yi] > 0
					nTot_Mes++
				EndIf
				
				// Grava valores do vendedor ou operador no arquivo
				If MV_PAR06 = 1
					cNom_Cam := "TRB->"+Subs(aMeses[yi-2],1,3)+'_'+StrZero(yi-2,2)
					&cNom_Cam := aVen_Car[nPos,yi]
				EndIf
				
				// Armazena os valores e totaliza os valores no Array de TOTAIS
				aVen_Tot[7,yi] += aVen_Car[nPos,yi]
			Next
			
			// Impress„o das colunas de Total(13) e MÈdia(14)
			//			@ li,nCol+1 PSay aVen_Car[nPos,15] Picture "@E 9999,999,999"
			//			nCol+=14
			//			@ li,nCol PSay (aVen_Car[nPos,15]/nTot_Mes) Picture "@E 9,999,999999"
			li++
			
			// Quebra de p·gina
			If li > 66
				li := Cabec(_cTitulo,_cDesc1,_cDesc2,nomeprog,tamanho) + 1
			EndIf
			
			// Grava Total e MÈdia do vendedor ou operador no arquivo
			If MV_PAR06 = 1
				TRB->TOTAL_13 := nSom_Tot
				TRB->(MsUnLock())
			EndIf
		EndIf
	EndIf
	
	li += 1
	
Next

// Cria uma Linha em Branco
If MV_PAR06 = 1
	DbSelectArea("TRB")
	RecLock("TRB",.T.)
	TRB->(MsUnLock())
EndIf


/*====================================================================================\
|                          BLOCO DE IMPRESS√O DA LINHA DE TOTAIS                      |
\====================================================================================*/
// impress„o da linha de Total
nSom_Tot := 0
nTot_Mes := 0
li++
@ li,000 psay Replicate("-",220)
li++
For xi := 1 To iif(MV_PAR04==1,Len(aVen_Tot),2)
	nCol := 37
	nSom_Tot := 0
	nTot_Mes := 0
	
	If MV_PAR06 = 1
		DbSelectArea("TRB")
		RecLock("TRB",.T.)
		TRB->NOME := aVen_Tot[xi,1]
		TRB->TIPO := aVen_Tot[xi,2]
	EndIf
	                         '
	@ li,000 PSay aVen_Tot[xi,1] + aVen_Tot[xi,2]
	
	For yi := 3 to 14
		
		If (xi%2) = 0 .or. xi = 1
			If xi == 4
				@ li,nCol PSay (aVen_Tot[1,yi]/aVen_Tot[3,yi]) Picture "@E 9,999,999.99"
			ElseIf xi == 6
				@ li,nCol PSay (aVen_Tot[1,yi]/aVen_Tot[5,yi]) Picture "@E 9,999,999.99"
			Else
				@ li,nCol PSay aVen_Tot[xi,yi] Picture "@E 9,999,999.99"
			EndIf
		Else
			@ li,nCol PSay aVen_Tot[xi,yi] Picture "@E 9999,999,999"
		EndIf
		
		nCol+=13
		If xi == 6
			nSom_Tot += (aVen_Tot[1,yi]/aVen_Tot[5,yi])
		Else
			nSom_Tot += aVen_Tot[xi,yi]
		EndIf
		
		// Totaliza qtos. meses possui valores maior que zero (0)
		If aVen_Tot[xi,yi] > 0
			nTot_Mes++
		EndIf
		
		// Grava valores do vendedor ou operador no arquivo
		If MV_PAR06 = 1
			cNom_Cam := "TRB->"+Subs(aMeses[yi-2],1,3)+'_'+StrZero(yi-2,2)
			&cNom_Cam := aVen_Tot[xi,yi]
		EndIf
	Next
	
	// Impress„o das colunas de Total(13) e MÈdia(14)
	If (xi%2) = 0 .or. xi = 1
		If xi == 4
			nSom_Tot := aVen_Tot[xi-3,15]/aVen_Tot[xi-1,15]
		ElseIf xi == 5
			nSom_Tot := nSom_Tot/nTot_Mes
		EndIf
		If xi < 5
			@ li,nCol PSay nSom_Tot Picture "@E 99,999,999.99"
			aVen_Tot[xi,15] := nSom_Tot
		EndIf
	Else
		If xi < 5
			@ li,nCol+1 PSay nSom_Tot Picture "@E 9999,999,999"
			aVen_Tot[xi,15] := nSom_Tot
		EndIf
	EndIf
	
	nCol += 14
	
	If MV_PAR05 == 2
		If xi == 1
			@ li,nCol PSay Round((nSom_Tot/nTot_Mes),2) Picture "@E 9,999,999.99"
			nTot_Med := Round((nSom_Tot/nTot_Mes),2) // MÈdia da linha de totais (R$)
		ElseIf xi == 2                                                                // JBS 28/07/2010
			@ li,nCol PSay Round((nSom_Tot/nTot_Mes),2) Picture "@E 9,999,999.99"    // JBS 28/07/2010
	    ElseIf xi == 3
			@ li,nCol PSay (nSom_Tot/nTot_Mes) Picture "@E 9999,999,999"
		ElseIf xi == 5
			@ li,nCol PSay Round((nSom_Tot/nTot_Mes),0) Picture "@E 9999,999,999"
			nTot_Atv := Round((nSom_Tot/nTot_Mes),0) // MÈdia da linha de totais (Ativos)
		ElseIf xi == 6
			@ li,nCol PSay Round((nTot_Med/nTot_Atv),2) Picture "@E 9,999,999.99"
		EndIf
	EndIf 
	
	li++
	
	// Quebra de p·gina
	If li > 66
		li := Cabec(_cTitulo,_cDesc1,_cDesc2,nomeprog,tamanho) + 1
	EndIf
	
Next

@ li,000 psay Replicate("-",220)
li++
///////////////////////////////


/*====================================================================================\
|                              SE EM DISCO, DESVIA PARA SPOOL                         |
|====================================================================================*/
Set device to Screen
If aReturn[5] == 1    // Se Saida para disco, ativa SPOOL
	Set Printer TO
	Commit
	ourspool(wnrel)
Endif

If MV_PAR06 == 1

	DbSelectArea("TRB")
	TRB->(dbGotop())
	ProcRegua(TRB->(RECCOUNT()))	
	aCols := Array(TRB->(RECCOUNT()),Len(_aCampos))
	nColuna := 0
	nLinha := 0
	While TRB->(!Eof())
		nLinha++
		IncProc(OemToAnsi("Gerando planilha excel..."))
		For nColuna := 1 to Len(_aCampos)
			aCols[nLinha][nColuna] := &("TRB->("+_aCampos[nColuna][1]+")")			
		Next nColuna
		TRB->(dbSkip())	
	EndDo
	u_GDToExcel(_aCampos,aCols,Alltrim(FunName()))
	
	DbSelectArea("TRB")

	COPY TO &cArqExcell VIA "DBFCDX"
	
	MakeDir(cDestino) // CRIA DIRET”RIO CASO N√O EXISTA
	CpyS2T(cArqExcell+".dbf",cDestino,.T.) // COPIA ARQUIVO PARA MAQUINA DO USU¡RIO
	
	// Buscando e apagando arquivos tempor·rios - MCVN 27/08/10
	aTmp := Directory( cDestino+"*.tmp" )
	For nI:= 1 to Len(aTmp)
		fErase(cDestino+aTmp[nI,1])
	Next nI 
	
	TRB->(E_EraseArq(_cArqTRB)) // JBS 02/02/2006
EndIf

Return(.T.)

/*====================================================================================\
|                              FUN«√O DE VALIDA«√O DE PERGUNTAS                       |
|====================================================================================*/
Static Function AjustaSX1(cPerg)
Local i,j

_sAlias := Alias()
dbSelectArea("SX1")
dbSetOrder(1)

cPerg := PADR(cPerg, Len(SX1->X1_GRUPO)," " ) // Incluido por Sandro em 17/11/09.

aRegs:={}

//------------ Grupo/Ordem/Pergunta/PERGING/PERGESP/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05/F3
AADD(aRegs,{cPerg,"01","Mes e Ano Final       ","","","mv_ch1","C",6,0,0,"G","","MV_PAR01","","","","","","","","","","","","","",""})
AADD(aRegs,{cPerg,"02","Ordenar pela Coluna   ","","","mv_ch2","C",2,0,0,"G","","MV_PAR02","","",""," ","","","","","","","","","",""})
AADD(aRegs,{cPerg,"03","Informe o setor      ?","","","mv_ch3","N",1,0,0,"C","","MV_PAR03","1-Apoio","","","","","2-Call Center","","","","","3-Ambos","","",""})
AADD(aRegs,{cPerg,"04","Listar Qtde. NFs.     ","","","mv_ch4","N",1,0,1,"C","","MV_PAR04","1-Sim","","","","","2-N„o","","","","","","","",""})
AADD(aRegs,{cPerg,"05","Listar Vend ou Oper  ?","","","mv_ch5","N",1,0,1,"C","","MV_PAR05","1-Operador","","","","","2-Vendedor","","","","","3-Tecnico","","",""})
AADD(aRegs,{cPerg,"06","Gerar Arquivo        ?","","","mv_ch6","N",1,0,1,"C","","MV_PAR06","1-Sim","","","","","2-N„o","","","","","","","",""})
AADD(aRegs,{cPerg,"07","Fornecedor           ?","","","mv_ch7","C",6,0,0,"G","","mv_par07","","","","","","","","","","","","","","","","","","","","","","","","","SA2"})
AADD(aRegs,{cPerg,"08","Grupo Clientes       ?","","","mv_ch8","C",6,0,0,"G","","mv_par08","","","","","","","","","","","","","","","","","","","","","","","","","ACY"})
AADD(aRegs,{cPerg,"10","Vendedor De          ?","","","mv_ch10","C",6,0,0,"G","","MV_PAR10","","","","","","","","","","","","","","","","","","","","","","","","","SA3"})
AADD(aRegs,{cPerg,"11","Vendedor AtÈ         ?","","","mv_ch11","C",6,0,0,"G","","MV_PAR11","","","","","","","","","","","","","","","","","","","","","","","","","SA3"})  

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


/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥fQuery01  ∫Autor  ≥Jailton B Santos-JBS∫ Data ≥ 22/03/2010  ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥ Esta Query apura os falores faturado no pedido pela empresa∫±±
±±∫          ≥ informada como parametro, Retorna Query QRY1.              ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ Especifico - Faturamento - DIPROMED.                       ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Static Function fQuery01( _cEmpresa ,_cFilial)

Local cQuery  := ""
Local cFilSD2 := fFilial(_cEmpresa,'SD2',_cFilial)
Local cFilSF2 := fFilial(_cEmpresa,'SF2',_cFilial)
Local cFilSF4 := fFilial(_cEmpresa,'SF4',_cFilial)
Local cFilSC5 := fFilial(_cEmpresa,'SC5',_cFilial)
Local nId     := 0
//------------------------------------------------------------------------------------------
// Define as tabelas que ser„o lidas
//------------------------------------------------------------------------------------------
Local cNomeSD2 := 'SD2' + _cEmpresa
Local cNomeSF4 := 'SF4' + _cEmpresa
Local cNomeSC5 := 'SC5' + _cEmpresa
Local cNomeSF2 := 'SF2' + _cEmpresa
Local cNomeSA1 := RetSqlName('SA1')
Local cNomeSU7 := RetSqlName('SU7')
Local cNomeSA3 := RetSQLName('SA3')

cQuery := " SELECT SUM(CASE F4_DUPLIC WHEN 'S' THEN (D2_TOTAL + D2_VALFRE + D2_SEGURO + D2_DESPESA + D2_ICMSRET) ELSE (D2_VALFRE + D2_SEGURO + D2_DESPESA + D2_ICMSRET) END) D2_TOTAL, SUBSTRING(D2_EMISSAO,1,6) D2_EMISSAO, '" + _cEmpresa + "' D2_CODEMP, D2_FORNEC, D2_FILIAL"

If MV_PAR05 == 1 //(operador)
	cQuery += ", U7_COD, U7_CODVEN, U7_NOME"//GIOVANI ALTERADO NREDUZ PARA NOME  26/07/2011
ElseIf MV_PAR05 == 2 //(vendedor)   
	If MV_PAR09 == 1 
		cQuery += ", (CASE WHEN D2_FORNEC = '000996' AND F2_VEND2 <> ' ' THEN F2_VEND2 ELSE F2_VEND1 END) VEND,SUBSTRING(A3_NOME,1,15) A3_NOME,A3_NREDUZ, U7_CODVEN"//giovani 03/08/11 
	Else 
		cQuery += ", A1_VEND VEND,SUBSTRING(A3_NOME,1,15) A3_NOME, A3_NREDUZ, U7_CODVEN"//giovani 03/08/11 
	EndIf
Else // tÈcnico
	cQuery += ",SUBSTRING(A3_NREDUZ,1,15) A3_NOME, A3_NREDUZ, "+cCodTec   	//giovani 03/08/11
EndIf

cQuery += " FROM " + cNomeSF2 + " SF2 WITH(NOLOCK) " // Exclusivo Empresa e Filial

cQuery += " inner join "+ cNomeSD2 + " SD2  WITH(NOLOCK) " // Exclusivo Empresa e Filial
cQuery += "    on  SD2.D_E_L_E_T_ = ''"
cQuery += "    and F2_FILIAL = D2_FILIAL"
cQuery += "    and F2_DOC = D2_DOC"
cQuery += "    and F2_SERIE = D2_SERIE"
cQuery += "    and F2_CLIENTE = D2_CLIENTE"
cQuery += "    and F2_LOJA = D2_LOJA"
cQuery += "    and F2_TIPO = D2_TIPO"      


cQuery += " inner join "+ cNomeSF4 + " SF4  WITH(NOLOCK) " // Exclusivo Empresa e filial
cQuery += "    on  SF4.D_E_L_E_T_ = ''"
cQuery += "    and D2_TES = F4_CODIGO"
	If _cEmpresa == "010" //.and. aScan(aEmpresa,{|X| x[1] == '040' .and. x[2] == '04'}) == 0
		cQuery += "    and F4_FILIAL = D2_FILIAL " //'" + cFilSF4 + "' or ( F4_FILIAL  = '04' and D2_FORNEC in ('000851','000847','051508'))) " //
	Else
		cQuery += "    and F4_FILIAL  = '" + cFilSF4 + "' "
	EndIf

cQuery += " inner join "+ cNomeSC5 + " SC5  WITH(NOLOCK) " // Exclusivo Empresa e Filial
cQuery += "    on  SC5.D_E_L_E_T_ = ''"
cQuery += "    and D2_FILIAL = C5_FILIAL"
cQuery += "    and D2_PEDIDO = C5_NUM"

cQuery += " inner join "+ cNomeSA1 + " SA1  WITH(NOLOCK) "   // Tabela Compartilhada entre emrpesa e filial
cQuery += "    on  SA1.D_E_L_E_T_ = ''"
cQuery += "    and A1_FILIAL = '"+xFilial("SA1")+"' "
cQuery += "    and D2_CLIENTE = A1_COD"
cQuery += "    and D2_LOJA = A1_LOJA"

If MV_PAR05 <> 3 //Vendedor ou operador
	cQuery +=  " left join " + cNomeSU7 + " SU7  WITH(NOLOCK) "      // Tabela Compartilhada entre empresa e filial
	cQuery += "    on  SU7.D_E_L_E_T_ = ''"      
Endif

If MV_PAR05 <> 1 //(vendedor) ou Tecnico
	cQuery +=  " left join " + cNomeSA3 + " SA3  WITH(NOLOCK) "
	cQuery += "    on  SA3.D_E_L_E_T_ = ''"      
EndIf

cQuery += " Where SF2.D_E_L_E_T_ = ''"
//----------------------------------------------------------------------------------------------------------------------------------------------------------
// JBS 23/06/2010 - Vendas HQ Cd dos fornecedores abaixo
// Quando for a empresa 04, traz as vendas dos fornecedores 000851,0000847 e 051508
//----------------------------------------------------------------------------------------------------------------------------------------------------------
If _cEmpresa == "010" .and. aScan(aEmpresa,{|X| x[1] == '010' .and. x[2] == '04'}) == 0
	cQuery += "    and (F2_FILIAL  = '" + cFilSF2 + "' or ( F2_FILIAL  = '04' and D2_FORNEC in ('000851','000847','051508'))) "  ///
Else
	cQuery += "    and F2_FILIAL  = '" + cFilSF2 + "' "
EndIf
//----------------------------------------------------------------------------------------------------------------------------------------------------------
cQuery += "    and SUBSTRING(F2_EMISSAO,1,6) BETWEEN '" + cPer_Ini + "' AND '" + cPer_Fim +"'"

//-- Tratamento da HQ-CD: se Dipromed-Mtz, somente listar dados a partir de 01/05/2011 => Daniel Leme: 05/05/2011
	If (nConsolida == 1 .Or. nConsolida == 4) .And. _cEmpresa + _cFilial == "0101"
		cQuery +=  "    and F2_EMISSAO >= '20110501'"
	EndIf

cQuery += "    and F2_TIPO = 'N'"    

	If MV_PAR05 == 1 .And. MV_PAR09 == 1
		cQuery += "    and A1_VEND <> '006874'" 	
	Else
		cQuery += "    and F2_VEND1 <> '006874'" 
	EndIf

cQuery += " AND ( F4_DUPLIC = 'S' OR (D2_VALFRE + D2_SEGURO + D2_DESPESA + D2_ICMSRET) > 0 ) " 

If U_ListVend()!='' .And. !(Upper(_cDipUsr) $ cDIPR044) // Liberando DIPR044 para alguns usu·rios  MCVN-15/06/09
	If MV_PAR05 == 1 
		If MV_PAR09 == 1
			cQuery += " AND F2_VEND1 "+ U_ListVend()               
/*
			If MV_PAR03 == 2                                                                                                     
				cQuery += " AND (F2_VEND1 BETWEEN '"+MV_PAR10+"' AND '"+MV_PAR11+"' AND (F2_VEND2 = ' ' OR D2_FORNEC <> '000996')) "
			Else
		  	    cQuery += " AND (F2_VEND1 BETWEEN '"+MV_PAR10+"' AND '"+MV_PAR11+"' AND (F2_VEND2 = ' ' OR D2_FORNEC <> '000996') OR "
  				cQuery += " (F2_VEND2 BETWEEN '"+MV_PAR10+"' AND '"+MV_PAR11+"' AND D2_FORNEC IN ('000366','000446','000996'))) "
  			EndIf
*/
			cQuery += " AND (CASE WHEN F2_VEND2 <> ' ' AND D2_FORNEC IN('000366','000446','000996') THEN F2_VEND2 ELSE F2_VEND1 END) BETWEEN '"+MV_PAR10+"' AND '"+MV_PAR11+"' "
		Else 
			cQuery +=  " AND A1_VEND "+ U_ListVend()
			cQuery +=  " AND A1_VEND  BETWEEN '"+MV_PAR10+"' AND '"+MV_PAR11+"' " //RSB - 26/08/2013 - PESQUISA POR VENDEDOR 		
		EndIf       
	ElseIf MV_PAR05 == 2
		cQuery += " AND F2_VEND1 "+ U_ListVend()                                         
/*
		If MV_PAR03 == 2
			cQuery += " AND (F2_VEND1 BETWEEN '"+MV_PAR10+"' AND '"+MV_PAR11+"' AND (F2_VEND2 = ' ' OR D2_FORNEC <> '000996')) "
		Else
	  	    cQuery += " AND (F2_VEND1 BETWEEN '"+MV_PAR10+"' AND '"+MV_PAR11+"' AND (F2_VEND2 = ' ' OR D2_FORNEC <> '000996') OR "
  			cQuery += " (F2_VEND2 BETWEEN '"+MV_PAR10+"' AND '"+MV_PAR11+"' AND D2_FORNEC IN ('000366','000446','000996'))) "
  		EndIf
*/
		cQuery += " AND (CASE WHEN F2_VEND2 <> ' ' AND D2_FORNEC IN('000366','000446','000996') THEN F2_VEND2 ELSE F2_VEND1 END) BETWEEN '"+MV_PAR10+"' AND '"+MV_PAR11+"' "
	Else
		cQuery +=  " AND " +cCodTec + U_ListVend()
	Endif
EndIf

If MV_PAR05 == 2  //(vendedor)
	If MV_PAR09 == 1
		cQuery += " AND A3_COD = (CASE WHEN D2_FORNEC = '000996' AND F2_VEND2 <> ' ' THEN F2_VEND2 ELSE F2_VEND1 END ) "
		cQuery += " AND (CASE WHEN D2_FORNEC = '000996' AND F2_VEND2 <> ' ' THEN F2_VEND2 ELSE F2_VEND1 END ) = U7_CODVEN"                                                                                 
/*
		If MV_PAR03 == 2
			cQuery += " AND (F2_VEND1 BETWEEN '"+MV_PAR10+"' AND '"+MV_PAR11+"' AND (F2_VEND2 = ' ' OR D2_FORNEC <> '000996')) "
		Else							
	  	    cQuery += " AND (F2_VEND1 BETWEEN '"+MV_PAR10+"' AND '"+MV_PAR11+"' AND (F2_VEND2 = ' ' OR D2_FORNEC <> '000996') OR "
  			cQuery += " (F2_VEND2 BETWEEN '"+MV_PAR10+"' AND '"+MV_PAR11+"' AND D2_FORNEC IN ('000366','000446','000996'))) "
  		EndIf
*/
		cQuery += " AND (CASE WHEN F2_VEND2 <> ' ' AND D2_FORNEC IN('000366','000446','000996') THEN F2_VEND2 ELSE F2_VEND1 END) BETWEEN '"+MV_PAR10+"' AND '"+MV_PAR11+"' "
	Else         
		cQuery += " AND A3_FILIAL = '"+xFilial("SA3")+"' "		
		cQuery += " AND A1_VEND = A3_COD"      
		cQuery += " AND U7_FILIAL = '"+xFilial("SU7")+"' "				
		cQuery += " AND A1_VEND = U7_CODVEN"		
	EndIf
ElseIf MV_PAR05 == 1 //(operador)
	cQuery +=  " AND C5_OPERADO = U7_COD"
Else                
 	cQuery +=  " AND " + cCodTec + " = A3_COD"
EndIf

If !Empty(MV_PAR07) // FORNECEDOR       
	If MV_PAR07 $ "000851/051508" //CÛdigos do fornecedor HQ
		cQuery += " AND D2_FORNEC IN ('000851','051508') "
	Else
		cQuery += " AND D2_FORNEC = '" + MV_PAR07 + "'"
	Endif
EndIf

If !Empty(MV_PAR08)
	cQuery +=  " AND A1_GRPVEN = '"+MV_PAR08+"'"
EndIf


If MV_PAR05 == 1 //(operador)
	cQuery += " GROUP BY SUBSTRING(D2_EMISSAO,1,6), U7_CODVEN, U7_COD, U7_NOME, D2_FORNEC,D2_FILIAL"//GIOVANI ALTERADO NREDUZ PARA NOME  26/07/2011
ElseIf MV_PAR05 == 2 //(vendedor)
	If MV_PAR09 == 1
		cQuery += " GROUP BY SUBSTRING(D2_EMISSAO,1,6), (CASE WHEN D2_FORNEC = '000996' AND F2_VEND2 <> ' ' THEN F2_VEND2 ELSE F2_VEND1 END) ,SUBSTRING(A3_NOME,1,15),A3_NREDUZ, U7_CODVEN, D2_FORNEC,D2_FILIAL"//giovani 03/08/11
	Else 
		cQuery += " GROUP BY SUBSTRING(D2_EMISSAO,1,6), A1_VEND,SUBSTRING(A3_NOME,1,15),A3_NREDUZ, U7_CODVEN, D2_FORNEC,D2_FILIAL"//giovani 03/08/11		
	EndIf
Else
	cQuery += " GROUP BY SUBSTRING(D2_EMISSAO,1,6)," + cCodTec + ",SUBSTRING(A3_NREDUZ,1,15),A3_NREDUZ, D2_FORNEC,D2_FILIAL"	//giovani 03/08/11
EndIf


Return(cQuery)
/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥fQuery02  ∫Autor  ≥Jailton B Santos-JBS∫ Data ≥ 22/03/2010  ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥ Esta Query apura os falores faturado no pedido pela empresa∫±±
±±∫          ≥ informada como parametro, Retorna Query QRY2.              ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ Especifico - Faturamento - DIPROMED.                       ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Static Function fQuery02( _cEmpresa ,_cFilial)

Local nId           := 0
Local cQuery        := ""
Local cQuerySelect  := ""
Local cQueryJoin    := ""
Local cQueryWhere   := ""

Local cFilSD1 := fFilial(_cEmpresa,'SD1',_cFilial)
Local cFilSD2 := fFilial(_cEmpresa,'SD2',_cFilial)
Local cFilSF2 := fFilial(_cEmpresa,'SF2',_cFilial)
Local cFilSF4 := fFilial(_cEmpresa,'SF4',_cFilial)
Local cFilSC5 := fFilial(_cEmpresa,'SC5',_cFilial)
Local nId     := 0
//------------------------------------------------------------------------------------------
// Define as tabelas que ser„o lidas
//------------------------------------------------------------------------------------------
Local cNomeSD1 := 'SD1' + _cEmpresa
Local cNomeSD2 := 'SD2' + _cEmpresa
Local cNomeSF4 := 'SF4' + _cEmpresa
Local cNomeSC5 := 'SC5' + _cEmpresa
Local cNomeSF2 := 'SF2' + _cEmpresa
Local cNomeSA1 := RetSqlName('SA1')
Local cNomeSU7 := RetSqlName('SU7')
Local cNomeSA3 := RetSQLName('SA3')

cQuerySelect := " SELECT SUM(CASE F4_DUPLIC WHEN 'S' THEN (D1_TOTAL + D1_VALFRE+D1_SEGURO+D1_DESPESA+D1_ICMSRET) ELSE (D1_VALFRE+D1_SEGURO+D1_DESPESA+D1_ICMSRET) END)  D1_TOTAL, SUBSTRING(D1_DTDIGIT,1,6) D1_DTDIGIT, '" + _cEmpresa + "' D1_CODEMP, D2_FORNEC,D1_FILIAL,"

cQueryJoin   := " FROM " +  cNomeSD1 + " SD1 with (nolock)"

cQueryJoin   += " inner join " + cNomeSD2 + " SD2 with (nolock)" 
cQueryJoin   += "    on  SD2.D_E_L_E_T_ = ''"
	If MV_PAR05 == 1 //(operador)
		cQueryJoin += " AND D1_FILIAL = D2_FILIAL"
		cQueryJoin += " AND D1_NFORI = D2_DOC"
		cQueryJoin += " AND D1_SERIORI = D2_SERIE"
		cQueryJoin += " AND D1_ITEMORI = D2_ITEM"

		If !Empty(MV_PAR07) // FORNECEDOR       
			If MV_PAR07 $ "000851/051508" //CÛdigos do fornecedor HQ
				cQueryJoin += " AND D2_FORNEC IN ('000851','051508') "
			Else
				cQueryJoin += " AND D2_FORNEC = '" + MV_PAR07 + "'"
			Endif
		EndIf
	ElseIf MV_PAR05 == 2 //(vendedor)
		cQueryJoin += " AND D1_FILIAL = D2_FILIAL"
		cQueryJoin += " AND D1_NFORI = D2_DOC"
		cQueryJoin += " AND D1_SERIORI = D2_SERIE"
		cQueryJoin += " AND D1_ITEMORI = D2_ITEM"
	Endif
	
cQueryJoin   += " inner join " + cNomeSF2 + " SF2 with (nolock) " 
cQueryJoin   += "    on  SF2.D_E_L_E_T_ = ''"
	If MV_PAR05 == 1 //(operador)
		cQueryJoin += " AND F2_FILIAL = D2_FILIAL"
		cQueryJoin += " AND F2_DOC = D2_DOC"
		cQueryJoin += " AND F2_SERIE = D2_SERIE" 
		If U_ListVend() != '' .And. !(Upper(_cDipUsr) $ cDIPR044) // Liberando DIPR044 para alguns usu·rios  MCVN-15/06/09
			cQueryJoin +=  " AND F2_VEND1 "+U_ListVend()
		EndIf
	ElseIf MV_PAR05 == 2 //(vendedor)
		cQueryJoin += " AND F2_SERIE = D2_SERIE" 
		cQueryJoin += " AND D1_FILIAL = F2_FILIAL"
		cQueryJoin += " AND D1_NFORI = F2_DOC"
	Endif

cQueryJoin   += " inner join " + cNomeSF4 + " SF4 with (nolock)" 
cQueryJoin   += "    on  SF4.D_E_L_E_T_ = ''"
	If MV_PAR05 == 1 //(operador)
		cQueryJoin += " AND D1_TES = F4_CODIGO"
		
		If _cEmpresa == "010" //.and. aScan(aEmpresa,{|X| x[1] == '040' .and. x[2] == '04'}) == 0
			cQueryJoin += " and F4_FILIAL = D2_FILIAL " //'" + cFilSF4 + "' or ( F4_FILIAL  = '04' and D2_FORNEC in ('000851','000847','051508'))) " //
		Else
			cQueryJoin += " and F4_FILIAL  = '" + cFilSF4 + "' "
		EndIf
		//cQueryJoin += " AND F4_FILIAL = '" + cFilSF4 + "' "
	ElseIf MV_PAR05 == 2 //(vendedor)
		cQueryJoin += " AND D1_TES = F4_CODIGO" 
		cQueryJoin += " AND ( F4_DUPLIC = 'S' OR (D1_VALFRE + D1_SEGURO + D1_DESPESA + D1_ICMSRET) > 0 )" 

		If _cEmpresa == "010" //.and. aScan(aEmpresa,{|X| x[1] == '040' .and. x[2] == '04'}) == 0
			cQueryJoin += " and F4_FILIAL = D2_FILIAL " //'" + cFilSF4 + "' or ( F4_FILIAL  = '04' and D2_FORNEC in ('000851','000847','051508'))) " //
		Else
			cQueryJoin += " and F4_FILIAL  = '" + cFilSF4 + "' "
		EndIf
		//	cQueryJoin += " AND F4_FILIAL = '" + cFilSF4 + "'"
	Endif

cQueryWhere  := " WHERE SD1.D_E_L_E_T_ = ''"

If MV_PAR05 == 1     //(operador)
	cQuerySelect += " U7_COD, U7_CODVEN, U7_NOME" //GIOVANI ALTERADO NREDUZ PARA NOME  26/07/2011

	cQueryJoin   += " inner join " + cNomeSC5 + " SC5 with (nolock) "
	cQueryJoin   += "    on  SC5.D_E_L_E_T_ = ''"
	cQueryJoin   += "    AND D2_FILIAL = C5_FILIAL"
	cQueryJoin   += "    AND D2_PEDIDO = C5_NUM"

	cQueryJoin   += " inner join " + cNomeSU7 + " SU7 with (nolock) "
	cQueryJoin   += "    on  SU7.D_E_L_E_T_ = ''"
	cQueryJoin   += "    AND C5_OPERADO = U7_COD"

	cQueryWhere += " AND D1_TIPO = 'D'"

ElseIf MV_PAR05 == 2 //(vendedor)
	If MV_PAR09 == 1
  		cQuerySelect += " (CASE WHEN D2_FORNEC = '000996' AND F2_VEND2 <> ' ' THEN F2_VEND2 ELSE F2_VEND1 END) VEND,SUBSTRING(A3_NOME,1,15) A3_NOME,A3_NREDUZ "//giovani 03/08/11
		cQueryJoin   += " inner join " + cNomeSA3 + " SA3 with (nolock) "
	Else                                                                                                                                
		cQuerySelect += " A1_VEND VEND,SUBSTRING(A3_NOME,1,15) A3_NOME,A3_NREDUZ "//giovani 03/08/11
		cQueryJoin   += " inner join " + cNomeSA3 + " SA3 with (nolock) "
	EndIf
Else                                                                                                                                
	cQuerySelect += " SUBSTRING(A3_NREDUZ,1,15) A3_NOME, A3_NREDUZ, " + cCodTec//giovani 03/08/11   	
	cQueryJoin   += " inner join " + cNomeSA3 + " SA3 with (nolock) "
EndIf

cQueryJoin   += " inner join " + cNomeSA1+" SA1 with (nolock) "
cQueryJoin   += "    on  SA1.D_E_L_E_T_ = ''"
	If MV_PAR05 == 1 //(operador)
		cQueryJoin += " AND D2_CLIENTE = A1_COD"
		cQueryJoin += " AND D2_LOJA = A1_LOJA"

		If !Empty(MV_PAR08)
			cQueryJoin +=  " AND A1_GRPVEN = '"+MV_PAR08+"'"
		EndIf
	ElseIf MV_PAR05 == 2 //(vendedor)
		cQueryJoin += " AND D2_CLIENTE = A1_COD"
		cQueryJoin += " AND D2_LOJA = A1_LOJA"
	Endif
	
//----------------------------------------------------------------------------------------------------------------------------------------------------------
// JBS 17/06/2010 - Vendas HQ Cd dos fornecedores abaixo
// Quando for a empresa 04, traz as vendas dos fornecedores 000851,0000847 e 051508
//----------------------------------------------------------------------------------------------------------------------------------------------------------
If _cEmpresa == "010" .and. aScan(aEmpresa,{|X| x[1] == '010' .and. x[2] == '04'}) == 0
	cQueryWhere += "    and (D1_FILIAL  = '" + cFilSD1 + "' or ( D1_FILIAL  = '04' and D2_FORNEC in ('000851','000847','051508'))) "
Else
	cQueryWhere += "    and D1_FILIAL  = '" + cFilSD1 + "' "
EndIf
//----------------------------------------------------------------------------------------------------------------------------------------------------------
cQueryWhere += "    and SUBSTRING(D1_DTDIGIT,1,6) BETWEEN '" + cPer_Ini + "' AND '" + cPer_Fim +"' "

//-- Tratamento da HQ-CD: se Dipromed-Mtz, somente listar dados a partir de 01/05/2011 => Daniel Leme: 05/05/2011
If (nConsolida == 1 .Or. nConsolida == 4) .And. _cEmpresa + _cFilial == "0101"
	cQueryWhere +=  "    and D1_DTDIGIT >= '20110501'"
EndIf

If MV_PAR05 == 1 //(operador)
	cQueryWhere += " AND (CASE WHEN F2_VEND2 <> ' ' AND D2_FORNEC IN('000366','000446','000996') THEN F2_VEND2 ELSE F2_VEND1 END) BETWEEN '"+MV_PAR10+"' AND '"+MV_PAR11+"' "
	cQueryWhere += " AND ( F4_DUPLIC = 'S' OR (D1_VALFRE + D1_SEGURO + D1_DESPESA + D1_ICMSRET) > 0 )"
	cQueryWhere += " GROUP BY SUBSTRING(D1_DTDIGIT,1,6), U7_COD, U7_CODVEN, U7_NOME, D2_FORNEC, D1_FILIAL"
	/*
		If MV_PAR03 == 2
			cQueryWhere += " AND (F2_VEND1 BETWEEN '"+MV_PAR10+"' AND '"+MV_PAR11+"' AND (F2_VEND2 = ' ' OR D2_FORNEC <> '000996')) "
		Else
			cQueryWhere += " AND (F2_VEND1 BETWEEN '"+MV_PAR10+"' AND '"+MV_PAR11+"' AND (F2_VEND2 = ' ' OR D2_FORNEC <> '000996') OR "
			cQueryWhere += " (F2_VEND2 BETWEEN '"+MV_PAR10+"' AND '"+MV_PAR11+"' AND D2_FORNEC IN ('000366','000446','000996'))) "
		EndIf
	*/
ElseIf MV_PAR05 == 2 //(vendedor)
	cQueryWhere += " AND D1_TIPO = 'D'"
	cQueryWhere += " AND (CASE WHEN F2_VEND2 <> ' ' AND D2_FORNEC IN('000366','000446','000996') THEN F2_VEND2 ELSE F2_VEND1 END) BETWEEN '"+MV_PAR10+"' AND '"+MV_PAR11+"' "

	If MV_PAR09 == 1
		cQueryWhere += " AND A3_COD = (CASE WHEN D2_FORNEC = '000996' AND F2_VEND2 <> ' ' THEN F2_VEND2 ELSE F2_VEND1 END ) "

		If U_ListVend() != '' .And. !(Upper(_cDipUsr) $ cDIPR044) // Liberando DIPR044 para alguns usu·rios  MCVN-15/06/09
			cQueryWhere +=  " AND F2_VEND1 "+U_ListVend()
		EndIf
	Else                                            
		cQueryWhere += " AND A1_VEND = A3_COD"
	
		If U_ListVend() != '' .And. !(Upper(_cDipUsr) $ cDIPR044) // Liberando DIPR044 para alguns usu·rios  MCVN-15/06/09
			cQueryWhere +=  " AND A1_VEND "+U_ListVend()
		EndIf                                      
  		cQueryWhere += " AND A1_VEND  BETWEEN '"+MV_PAR10+"' AND '"+MV_PAR11+"' " //RSB - 26/08/2013 - PESQUISA POR VENDEDOR 	
	EndIf
	
	If !Empty(MV_PAR07) // FORNECEDOR       
		If MV_PAR07 $ "000851/051508" //CÛdigos do fornecedor HQ
			cQueryWhere += " AND D2_FORNEC IN ('000851','051508') "
		Else
			cQueryWhere += " AND D2_FORNEC = '" + MV_PAR07 + "'"
		Endif
	EndIf
	If !Empty(MV_PAR08)
		cQueryWhere +=  " AND A1_GRPVEN = '"+MV_PAR08+"'"
	EndIf
	

	If MV_PAR09 == 1
		cQueryWhere += " GROUP BY (CASE WHEN D2_FORNEC = '000996' AND F2_VEND2 <> ' ' THEN F2_VEND2 ELSE F2_VEND1 END), SUBSTRING(D1_DTDIGIT,1,6),SUBSTRING(A3_NOME,1,15),A3_NREDUZ, D2_FORNEC,D1_FILIAL"//giovani 03/08/11
	Else
		cQueryWhere += " GROUP BY A1_VEND, SUBSTRING(D1_DTDIGIT,1,6),SUBSTRING(A3_NOME,1,15),A3_NREDUZ, D2_FORNEC,D1_FILIAL"//giovani 03/08/11	
	EndIf
	/*
		If MV_PAR03 == 2
			cQueryWhere += " AND (F2_VEND1 BETWEEN '"+MV_PAR10+"' AND '"+MV_PAR11+"' AND (F2_VEND2 = ' ' OR D2_FORNEC <> '000996')) "
		Else
			cQueryWhere += " AND (F2_VEND1 BETWEEN '"+MV_PAR10+"' AND '"+MV_PAR11+"' AND (F2_VEND2 = ' ' OR D2_FORNEC <> '000996') OR "
			cQueryWhere += " (F2_VEND2 BETWEEN '"+MV_PAR10+"' AND '"+MV_PAR11+"' AND D2_FORNEC IN ('000366','000446','000996'))) "
		EndIf
	*/
Else //TÈcnico
	cQueryWhere += " AND D1_TIPO = 'D'"
	cQueryWhere += " AND D1_FILIAL = F2_FILIAL"
	cQueryWhere += " AND D1_NFORI = F2_DOC"
	cQueryWhere += " AND D1_FILIAL = D2_FILIAL"
	cQueryWhere += " AND D1_NFORI = D2_DOC"
	cQueryWhere += " AND D1_SERIORI = D2_SERIE"
	cQueryWhere += " AND D1_ITEMORI = D2_ITEM"
	cQueryWhere += " AND D2_CLIENTE = A1_COD"
	cQueryWhere += " AND D2_LOJA = A1_LOJA"
	cQueryWhere += " AND F2_SERIE = D2_SERIE"                                     
/*
	If MV_PAR03 == 2
		cQueryWhere += " AND (F2_VEND1 BETWEEN '"+MV_PAR10+"' AND '"+MV_PAR11+"' AND (F2_VEND2 = ' ' OR D2_FORNEC <> '000996')) "
	Else
    	cQueryWhere += " AND (F2_VEND1 BETWEEN '"+MV_PAR10+"' AND '"+MV_PAR11+"' AND (F2_VEND2 = ' ' OR D2_FORNEC <> '000996') OR "
		cQueryWhere += " (F2_VEND2 BETWEEN '"+MV_PAR10+"' AND '"+MV_PAR11+"' AND D2_FORNEC IN ('000366','000446','000996'))) "
	EndIf
*/
	cQueryWhere += " AND (CASE WHEN F2_VEND2 <> ' ' AND D2_FORNEC IN('000366','000446','000996') THEN F2_VEND2 ELSE F2_VEND1 END) BETWEEN '"+MV_PAR10+"' AND '"+MV_PAR11+"' "
	cQueryWhere += " AND D1_TES = F4_CODIGO"
	cQueryWhere += " AND ( F4_DUPLIC = 'S' OR (D1_VALFRE + D1_SEGURO + D1_DESPESA + D1_ICMSRET) > 0 )" 

	
	If _cEmpresa == "010" //.and. aScan(aEmpresa,{|X| x[1] == '040' .and. x[2] == '04'}) == 0
	    cQueryWhere += " and F4_FILIAL = D2_FILIAL " //'" + cFilSF4 + "' or ( F4_FILIAL  = '04' and D2_FORNEC in ('000851','000847','051508'))) " //
    Else
		cQueryWhere += " and F4_FILIAL  = '" + cFilSF4 + "' "
	EndIf
	//	cQueryWhere += " AND F4_FILIAL = '" + cFilSF4 + "'"
	 	cQueryWhere +=  " AND " + cCodTec + " = A3_COD"    
	If U_ListVend() != '' .And. !(Upper(_cDipUsr) $ cDIPR044) // Liberando DIPR044 para alguns usu·rios  MCVN-15/06/09
		cQueryWhere +=  " AND " + cCodTec + U_ListVend()
	EndIf
		cQueryWhere +=  " AND F2_VEND1 <> '006874' "
	If !Empty(MV_PAR07) // FORNECEDOR       
		If MV_PAR07 $ "000851/051508" //CÛdigos do fornecedor HQ
			cQueryWhere += " AND D2_FORNEC IN ('000851','051508') "
		Else
			cQueryWhere += " AND D2_FORNEC = '" + MV_PAR07 + "'"
		Endif
	EndIf
	If !Empty(MV_PAR08)
		cQueryWhere +=  " AND A1_GRPVEN = '"+MV_PAR08+"'"
	EndIf
	cQueryWhere += " GROUP BY " + cCodTec + ", SUBSTRING(D1_DTDIGIT,1,6),SUBSTRING(A3_NREDUZ,1,15),A3_NREDUZ, D2_FORNEC,D1_FILIAL"//giovani 03/08/11

EndIf

cQuery := cQuerySelect + cQueryJoin + cQueryWhere

Return(cQuery)
/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥fQuery03  ∫Autor  ≥Jailton B Santos-JBS∫ Data ≥ 16/04/2010  ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥ Esta Query apura os vfalores faturado no pedido pela empresa∫±±
±±∫          ≥ informada como parametro, Retorna Query QRY1.              ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ Especifico - Faturamento - DIPROMED.                       ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Static Function fQuery03( _cEmpresa ,_cFilial)

Local cQuery  := ""
Local cFilSD2 := fFilial(_cEmpresa,'SD2',_cFilial)
Local cFilSF2 := fFilial(_cEmpresa,'SF2',_cFilial)
Local cFilSF4 := fFilial(_cEmpresa,'SF4',_cFilial)
Local cFilSC5 := fFilial(_cEmpresa,'SC5',_cFilial)
Local nId     := 0
//------------------------------------------------------------------------------------------
// Define as tabelas que ser„o lidas
//------------------------------------------------------------------------------------------
Local cNomeSD2 := 'SD2' + _cEmpresa
Local cNomeSF4 := 'SF4' + _cEmpresa
Local cNomeSC5 := 'SC5' + _cEmpresa
Local cNomeSF2 := 'SF2' + _cEmpresa
Local cNomeSA1 := RetSqlName('SA1')
Local cNomeSU7 := RetSqlName('SU7')

If MV_PAR05 == 1 //(operador)
	
	cQuery := " SELECT COUNT(DISTINCT C5_NUM) F2_QTDNF, SUBSTRING(F2_EMISSAO,1,6) F2_EMISSAO, F2_VEND1, C5_OPERADO, U7_CODVEN"
	
	cQuery += " FROM " + cNomeSF2 + " SF2 with (nolock) "

	cQuery += " inner join " + cNomeSD2 + " SD2 with (nolock) "
  	cQuery += "    on  SD2.D_E_L_E_T_ = ''"
	cQuery += "    and D2_FILIAL = '" + cfilSD2 + "' "
	cQuery += "    and F2_FILIAL = D2_FILIAL"
	cQuery += "    and F2_DOC = D2_DOC"
	cQuery += "    and F2_SERIE = D2_SERIE"

	cQuery += " inner join " + cNomeSF4 + " SF4 with (nolock) "
	cQuery += "    on  SF4.D_E_L_E_T_ = ''"
	cQuery += "    and D2_TES = F4_CODIGO"
	cQuery += "    and F4_DUPLIC = 'S'"
	cQuery += "    and F4_FILIAL = '" + cFilSF4 +"'"

	cQuery += " inner join " + cNomeSC5 + " SC5 with (nolock) "
	cQuery += "    on  SC5.D_E_L_E_T_ = ''"
	cQuery += "    and D2_FILIAL = C5_FILIAL"
	cQuery += "    and D2_PEDIDO = C5_NUM"

	cQuery += " inner join " + cNomeSA1 + " SA1 with (nolock) "
	cQuery += "    on  SA1.D_E_L_E_T_ = ''"
	cQuery += "    and A1_COD = F2_CLIENTE"

	cQuery += " left join " + cNomeSU7 + " SU7 with (nolock) "
	cQuery += "    on  SU7.D_E_L_E_T_ = ''"

	
	cQuery += " WHERE SF2.D_E_L_E_T_ = ''"
	cQuery += "    and F2_TIPO = 'N'"
	cQuery += "    and SUBSTRING(F2_EMISSAO,1,6) BETWEEN '" + cPer_Ini + "' AND '" + cPer_Fim +"'"

	//-- Tratamento da HQ-CD: se Dipromed-Mtz, somente listar dados a partir de 01/05/2011 => Daniel Leme: 05/05/2011
	If (nConsolida == 1 .Or. nConsolida == 4) .And. _cEmpresa + _cFilial == "0101"
		cQuery +=  "    and F2_EMISSAO >= '20110501'"
	EndIf
	
/*
	If MV_PAR03 == 2
		cQuery += "    and (F2_VEND1 BETWEEN '"+MV_PAR10+"' AND '"+MV_PAR11+"' AND (F2_VEND2 = ' ' OR D2_FORNEC <> '000996')) "
	Else
    	cQuery += "    and (F2_VEND1 BETWEEN '"+MV_PAR10+"' AND '"+MV_PAR11+"' AND (F2_VEND2 = ' ' OR D2_FORNEC <> '000996') "
		cQuery += "    or  (F2_VEND2 BETWEEN '"+MV_PAR10+"' AND '"+MV_PAR11+"' AND D2_FORNEC IN ('000366','000446','000996')))"
	EndIF
*/
	cQuery += "    and (CASE WHEN F2_VEND2 <> ' ' AND D2_FORNEC IN('000366','000446','000996') THEN F2_VEND2 ELSE F2_VEND1 END) BETWEEN '"+MV_PAR10+"' AND '"+MV_PAR11+"' "
	cQuery += "    and (CASE WHEN D2_FORNEC = '000996' AND F2_VEND2 <> ' ' THEN F2_VEND2 ELSE F2_VEND1 END ) = U7_CODVEN " 
	If U_ListVend() != '' .And. !(Upper(_cDipUsr) $ cDIPR044) // Liberando DIPR044 para alguns usu·rios  MCVN-15/06/09
		cQuery +=  "    and F2_VEND1 "+U_ListVend()
	EndIf
	If !Empty(MV_PAR07) // FORNECEDOR       
		If MV_PAR07 $ "000851/051508" //CÛdigos do fornecedor HQ
			cQuery += "    and D2_FORNEC IN ('000851','051508') "
		Else
			cQuery += "    and D2_FORNEC = '" + MV_PAR07 + "'"
		Endif
	EndIf
	If !Empty(MV_PAR08)
		cQuery +=  "    and A1_GRPVEN = '"+MV_PAR08+"'"
	EndIf
	
	cQuery += " GROUP BY F2_VEND1, SUBSTRING(F2_EMISSAO,1,6), C5_OPERADO, U7_CODVEN"
	//cQuery += " ORDER BY U7_CODVEN, C5_OPERADO, SUBSTRING(F2_EMISSAO,1,6), F2_VEND1"
ElseIf MV_PAR05 == 2 //(vendedor)                                                             
	If MV_PAR09 == 1
		cQuery := " SELECT COUNT(DISTINCT D2_DOC) F2_QTDNF, SUBSTRING(F2_EMISSAO,1,6) F2_EMISSAO, (CASE WHEN D2_FORNEC = '000996' AND F2_VEND2 <> ' ' THEN F2_VEND2 ELSE F2_VEND1 END) VEND" 
    Else                                                                                                   
		cQuery := " SELECT COUNT(DISTINCT D2_DOC) F2_QTDNF, SUBSTRING(F2_EMISSAO,1,6) F2_EMISSAO, A1_VEND VEND" 
	EndIf
	
	cQuery += " FROM " + cNomeSD2 + " SD2 with (nolock)"
	
	cQuery += " inner join " + cNomeSF2 + " SF2 with (nolock)"
	cQuery += "    on  SF2.D_E_L_E_T_ = ''"
	cQuery += "    and F2_TIPO = 'N'"
	cQuery += "    and F2_FILIAL = D2_FILIAL"
	cQuery += "    and F2_DOC = D2_DOC"
	cQuery += "    and F2_SERIE = D2_SERIE"
	cQuery += "    and F2_TIPO = 'N'"
		If (nConsolida == 1 .Or. nConsolida == 4) .And. _cEmpresa + _cFilial == "0101"
			cQuery +=  "    and F2_EMISSAO >= '20110501'"
		EndIf
	
	cQuery += " inner join " + cNomeSF4 + " SF4 with (nolock)"
	cQuery += "    on  SF4.D_E_L_E_T_ = ''"
	cQuery += "    and D2_TES = F4_CODIGO"
	cQuery += "    and F4_DUPLIC = 'S'"
	cQuery += "    and F4_FILIAL = '" + cFilSF4 + "' "
	
	cQuery += " inner join " + cNomeSA1 + " SA1 with (nolock)"
	cQuery += "    on  SA1.D_E_L_E_T_ = ''"
	cQuery += "    and A1_COD = F2_CLIENTE"                                                                              
		If !Empty(MV_PAR08)
			cQuery +=  "    and A1_GRPVEN = '"+MV_PAR08+"'"
		EndIf

	cQuery += " WHERE SD2.D_E_L_E_T_ = ''"
	cQuery += "    and SUBSTRING(F2_EMISSAO,1,6) BETWEEN '" + cPer_Ini + "' AND '" + cPer_Fim +"'"

	//-- Tratamento da HQ-CD: se Dipromed-Mtz, somente listar dados a partir de 01/05/2011 => Daniel Leme: 05/05/2011

	cQuery += "    and D2_FILIAL = '" + cFilSD2 + "' "
    If MV_PAR09 == 1                                                                     
	 /*
	    If MV_PAR03 == 2
			cQuery += "    and (F2_VEND1 BETWEEN '"+MV_PAR10+"' AND '"+MV_PAR11+"' AND (F2_VEND2 = ' ' OR D2_FORNEC <> '000996')) "
		Else
		    cQuery += "    and (F2_VEND1 BETWEEN '"+MV_PAR10+"' AND '"+MV_PAR11+"' AND (F2_VEND2 = ' ' OR D2_FORNEC <> '000996') "
			cQuery += "    or  (F2_VEND2 BETWEEN '"+MV_PAR10+"' AND '"+MV_PAR11+"' AND D2_FORNEC IN ('000366','000446','000996')))"
		EndIf
	*/
		cQuery += "    and (CASE WHEN F2_VEND2 <> ' ' AND D2_FORNEC IN('000366','000446','000996') THEN F2_VEND2 ELSE F2_VEND1 END) BETWEEN '"+MV_PAR10+"' AND '"+MV_PAR11+"' "
	Else 
  		cQuery += "    and A1_VEND  BETWEEN '"+MV_PAR10+"' AND '"+MV_PAR11+"' "
	EndIf

	If U_ListVend() != '' .And. !(Upper(_cDipUsr) $ cDIPR044) // Liberando DIPR044 para alguns usu·rios  MCVN-15/06/09
		If MV_PAR09 == 1
			cQuery +=  "    and F2_VEND1 "+U_ListVend()
		Else                                        
			cQuery +=  "    and A1_VEND "+U_ListVend()
		EndIf
	EndIf                                          
	


	If MV_PAR09 == 1
		cQuery += " GROUP BY SUBSTRING(F2_EMISSAO,1,6),(CASE WHEN D2_FORNEC = '000996' AND F2_VEND2 <> ' ' THEN F2_VEND2 ELSE F2_VEND1 END) "
	Else                                                         
		cQuery += " GROUP BY SUBSTRING(F2_EMISSAO,1,6), A1_VEND"
	EndIf
//	cQuery += " ORDER BY F2_VEND1, SUBSTRING(F2_EMISSAO,1,6)"
Else // TÈcnico
	cQuery := " SELECT COUNT(DISTINCT D2_DOC) F2_QTDNF, SUBSTRING(F2_EMISSAO,1,6) F2_EMISSAO, " + cCodTec
	
	cQuery += " FROM " + cNomeSD2 + " SD2, " +; // Exclusivo Empresa e Filial
	cNomeSF2 + " SF2, " +; // Exclusivo Empresa e Filial
	cNomeSF4 + " SF4, " +; // Exclusivo Empresa e filial
	cNomeSA1 + " SA1 "     // Tabela Compartilhada entre emrpesa e filial
	
	cQuery += " WHERE SUBSTRING(F2_EMISSAO,1,6) BETWEEN '" + cPer_Ini + "' AND '" + cPer_Fim +"'"

	//-- Tratamento da HQ-CD: se Dipromed-Mtz, somente listar dados a partir de 01/05/2011 => Daniel Leme: 05/05/2011
	If (nConsolida == 1 .Or. nConsolida == 4) .And. _cEmpresa + _cFilial == "0101"
		cQuery +=  " AND F2_EMISSAO >= '20110501'"
	EndIf
	
	cQuery += " AND D2_FILIAL = '" + cFilSD2 + "' "
	cQuery += " AND F2_TIPO = 'N'"
	cQuery += " AND F2_FILIAL = D2_FILIAL"
	cQuery += " AND F2_DOC = D2_DOC"
	cQuery += " AND F2_SERIE = D2_SERIE"
	cQuery += " AND F2_TIPO = 'N'"  
/*
	If MV_PAR03 == 2
		cQuery += " AND (F2_VEND1 BETWEEN '"+MV_PAR10+"' AND '"+MV_PAR11+"' AND (F2_VEND2 = ' ' OR D2_FORNEC <> '000996')) "
	Else
    	cQuery += " AND (F2_VEND1 BETWEEN '"+MV_PAR10+"' AND '"+MV_PAR11+"' AND (F2_VEND2 = ' ' OR D2_FORNEC <> '000996') OR "
		cQuery += " (F2_VEND2 BETWEEN '"+MV_PAR10+"' AND '"+MV_PAR11+"' AND D2_FORNEC IN ('000366','000446','000996')))"
	EndIf
*/
	cQuery += " AND (CASE WHEN F2_VEND2 <> ' ' AND D2_FORNEC IN('000366','000446','000996') THEN F2_VEND2 ELSE F2_VEND1 END) BETWEEN '"+MV_PAR10+"' AND '"+MV_PAR11+"' "
	cQuery += " AND D2_TES = F4_CODIGO"
	cQuery += " AND F4_DUPLIC = 'S'"
	cQuery += " AND F4_FILIAL = '" + cFilSF4 + "' "
	cQuery += " AND A1_COD = F2_CLIENTE"
	If U_ListVend() != '' .And. !(Upper(_cDipUsr) $ cDIPR044) // Liberando DIPR044 para alguns usu·rios  MCVN-15/06/09
		cQuery +=  " AND " + cCodTec + U_ListVend()
	EndIf
	If !Empty(MV_PAR08)
		cQuery +=  " AND A1_GRPVEN = '"+MV_PAR08+"'"
	EndIf
	cQuery += " AND SA1.D_E_L_E_T_ = ''"
	cQuery += " AND SF2.D_E_L_E_T_ = ''"
	cQuery += " AND SD2.D_E_L_E_T_ = ''"
	cQuery += " AND SF4.D_E_L_E_T_ = ''"
	cQuery += " GROUP BY SUBSTRING(F2_EMISSAO,1,6), " + cCodTec
//	cQuery += " ORDER BY F2_VEND1, SUBSTRING(F2_EMISSAO,1,6)"
EndIf

Return(cQuery)

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥fQuery04  ∫Autor  ≥Jailton B Santos-JBS∫ Data ≥ 16/04/2010  ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥ Esta Query apura os falores faturado no pedido pela empresa∫±±
±±∫          ≥ informada como parametro, Retorna Query QRY1.              ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ Especifico - Faturamento - DIPROMED.                       ∫±±mcan
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Static Function fQuery04( _cEmpresa ,_cFilial)

Local cQuery  := ""
Local cFilSD2 := fFilial(_cEmpresa,'SD2',_cFilial)
Local cFilSF2 := fFilial(_cEmpresa,'SF2',_cFilial)
Local cFilSF4 := fFilial(_cEmpresa,'SF4',_cFilial)
Local cFilSC5 := fFilial(_cEmpresa,'SC5',_cFilial)
Local nId     := 0
//------------------------------------------------------------------------------------------
// Define as tabelas que ser„o lidas
//--------------------mcan----------------------------------------------------------------------
Local cNomeSD2 := 'SD2' + _cEmpresa
Local cNomeSF4 := 'SF4' + _cEmpresa
Local cNomeSC5 := 'SC5' + _cEmpresa
Local cNomeSF2 := 'SF2' + _cEmpresa
Local cNomeSA1 := RetSqlName('SA1')
Local cNomeSU7 := RetSqlName('SU7')

cQuery := " SELECT DISTINCT D2_CLIENTE, SUBSTRING(D2_EMISSAO,1,6) D2_EMISSAO "

If MV_PAR05 == 1 //(operador)
	cQuery += ", U7_CODVEN , U7_COD, U7_NOME, C5_OPERADO"
ElseIf MV_PAR05 == 2 //(vendedor)   
	If MV_PAR09 == 1
		cQuery += ", (CASE WHEN D2_FORNEC = '000996' AND F2_VEND2 <> ' ' THEN F2_VEND2 ELSE F2_VEND1 END) VEND,SUBSTRING(A3_NOME,1,15) A3_NOME, A3_NREDUZ "//giovani 03/08/11
	Else                                                                          
		cQuery += ", A1_VEND VEND,SUBSTRING(A3_NOME,1,15) A3_NOME, A3_NREDUZ "//giovani 03/08/11
	EndIf
Else
	cQuery += ",SUBSTRING(A3_NREDUZ,1,15) A3_NOME,A3_NREDUZ, " + cCodTec
EndIf

cQuery += " FROM " + cNomeSF2 + " SF2 with (nolock)"

cQuery += " inner join " + cNomeSD2 + " SD2 with (nolock)"
cQuery += "    on  SD2.D_E_L_E_T_ = ''"
cQuery += "    AND D2_FILIAL = '" + cFilSD2 + "' "
cQuery += "    AND F2_FILIAL = D2_FILIAL"
cQuery += "    AND F2_DOC = D2_DOC"
cQuery += "    AND F2_SERIE = D2_SERIE"
cQuery += "    AND D2_TIPO = 'N'"

cQuery += " inner join " + cNomeSF4 + " SF4 with (nolock)"
cQuery += "    on  SF4.D_E_L_E_T_ = ''"
cQuery += "    AND D2_TES = F4_CODIGO"
cQuery += "    AND F4_DUPLIC = 'S'"
cQuery += "    AND F4_FILIAL = '" + cFilSF4 + "' "

cQuery += " inner join " + cNomeSC5 + " SC5 with (nolock)"
cQuery += "    on  SC5.D_E_L_E_T_ = ''"
cQuery += "    AND D2_FILIAL = C5_FILIAL"
cQuery += "    AND D2_PEDIDO = C5_NUM"

cQuery += " inner join " + cNomeSA1 + " SA1  with (nolock)"
cQuery += "    on  SA1.D_E_L_E_T_ = ''"
cQuery += "    AND A1_COD = F2_CLIENTE"

If MV_PAR05 <> 3  //(vendedor)
	cQuery += " left join " + RetSQLName('SU7') + " SU7 with (nolock)"
	cQuery += "    on SU7.D_E_L_E_T_ = ''"
EndIf
If MV_PAR05 <> 1 //(vendedor)
	cQuery += " left join " + RetSQLName('SA3') + " SA3 with (nolock)" 
	cQuery += "    on  SA3.D_E_L_E_T_ = ''"
EndIf

cQuery += " WHERE SF2.D_E_L_E_T_ = ''"
cQuery += " SUBSTRING(F2_EMISSAO,1,6) BETWEEN '" + cPer_Ini + "' AND '" + cPer_Fim +"'"

//-- Tratamento da HQ-CD: se Dipromed-Mtz, somente listar dados a partir de 01/05/2011 => Daniel Leme: 05/05/2011
If (nConsolida == 1 .Or. nConsolida == 4) .And. _cEmpresa + _cFilial == "0101"
	cQuery +=  " AND F2_EMISSAO >= '20110501'"
EndIf

// Eriberto 10/03/2010

If U_ListVend() != '' .And. !(Upper(_cDipUsr) $ cDIPR044) // Liberando DIPR044 para alguns usu·rios  MCVN-15/06/09
	cQuery +=  " AND "+ cCodTec +U_ListVend()
EndIf

If MV_PAR05 == 1 //(operador)
	cQuery += " AND C5_OPERADO = U7_COD"
ElseIf MV_PAR05 == 2 //(vendedor)
	If MV_PAR09 == 1
		cQuery += "    AND A3_COD = (CASE WHEN D2_FORNEC = '000996' AND F2_VEND2 <> ' ' THEN F2_VEND2 ELSE F2_VEND1 END ) "
		/*
		If MV_PAR03 == 2
			cQuery += "    AND (F2_VEND1 BETWEEN '"+MV_PAR10+"' AND '"+MV_PAR11+"' AND (F2_VEND2 = ' ' OR D2_FORNEC <> '000996')) "
		Else
		    cQuery += "    AND (F2_VEND1 BETWEEN '"+MV_PAR10+"' AND '"+MV_PAR11+"' AND (F2_VEND2 = ' ' OR D2_FORNEC <> '000996') "
			cQuery += "    OR  (F2_VEND2 BETWEEN '"+MV_PAR10+"' AND '"+MV_PAR11+"' AND D2_FORNEC IN ('000366','000446','000996')))"
		EndIf
		*/
		cQuery += " 	AND (CASE WHEN F2_VEND2 <> ' ' AND D2_FORNEC IN('000366','000446','000996') THEN F2_VEND2 ELSE F2_VEND1 END) BETWEEN '"+MV_PAR10+"' AND '"+MV_PAR11+"' "
	Else
  		cQuery += " AND A1_VEND = A3_COD"
  		cQuery += " AND A1_VEND  BETWEEN '"+MV_PAR10+"' AND '"+MV_PAR11+"' " //RSB - 26/08/2013 - PESQUISA POR VENDEDOR 	
	EndIf	
Else
 	cQuery +=  " AND " + cCodTec + " = A3_COD"
EndIf

If !Empty(MV_PAR07) // FORNECEDOR       
	If MV_PAR07 $ "000851/051508" //CÛdigos do fornecedor HQ
		cQuery += " AND D2_FORNEC IN ('000851','051508') "
	Else
		cQuery += " AND D2_FORNEC = '" + MV_PAR07 + "'"
	Endif
EndIf

If !Empty(MV_PAR08)
	cQuery +=  " AND A1_GRPVEN = '"+MV_PAR08+"'"
EndIf


Return(cQuery)

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥fFilial() ∫Autor  ≥Jailton B Santos-JBS∫ Data ≥ 22/03/2010  ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥Faz o tratamento para achar a filial para empresa para a    ∫±±
±±∫          ≥qual ira' abrir a tabela informada.                         ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Parametro ≥_cEmpresa: Empresa na qual queremos coletar dados           ∫±±
±±∫          ≥_cTabela : Nome da tabela da qual queremos coletar dados    ∫±±
±±∫          ≥_cFilial : Se a tabela for exclusiva, esta eh a filial da   ∫±±
±±∫          ≥           qual eh preciso coletar dados.                   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ Especifico - Faturamento - DIPROMED                        ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Static Function fFilial(_cEmpresa,_cTabela,_cFilial)

Local _cNewFilial := Space(2)
Local _cFile      := 'SX2'+_cEmpresa
Local _cFileIdx   := _cFile

If Select("SX2_2") = 0
	MsOpEndbf(.T.,"DBFCDX",_cFile,"SX2_2",.T.,.F.)
EndIf

SX2_2->( DbSetOrder(1) )
If SX2_2->( DbSeek(_cTabela) )
	If SX2_2->X2_MODO = 'E'
		_cNewFilial := _cFilial
	EndIf
Else
	_cNewFilial := xFilial(_cTabela)
EndIf

Return(_cNewFilial)
/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥DIPR044   ∫Autor  ≥Microsiga           ∫ Data ≥  03/11/13   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥                                                            ∫±±
±±∫          ≥                                                            ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ AP                                                        ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Static Function DipRetTec(cCod)
Local cRet 	 := ""
DEFAULT cCod := ""

Do Case
	Case cCod == "000183"
		cRet := "A1_TECN_A"
	Case cCod == "000041"             
		cRet := "A1_TECN_3"
	Case cCod $ "000338/100015"
		cRet := "A1_TECN_R" 
	Case cCod == "000647"
		cRet :=	"A1_TECN_C"	  
	Case cCod == "000997"
		cRet := "A1_XTEC_MA" 
	Case cCod == "000996"
		cRet := "A1_XTEC_SP"
	Case cCod $ "000517/100027/100028"
		cRet := "A1_TECN_B"	
	Case cCod == "000851"
		cRet := "A1_XTEC_HQ"
	Case cEmpAnt == '04'
		cRet := "A1_XTEC_HQ"
	OtherWise
		cRet := "A1_TECNICO"
End Case

Return cRet

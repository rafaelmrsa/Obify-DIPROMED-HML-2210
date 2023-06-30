/*====================================================================================\
|Programa  | DIPR028       | Autor | Eriberto Elias             | Data | 14/07/2003   |
|=====================================================================================|
|Descrição | Posicao de Titulos a Receber - analitico - Por Cliente                   |
|=====================================================================================|
|Sintaxe   | DIPR028                                                                  |
|=====================================================================================|
|Uso       | Especifico DIPROMED                                                      |
|=====================================================================================|
|........................................Histórico....................................|
|Rafael    | 31/08/04 - Juraci solicitou a colocação de 2 parâmentros Banco e Situação|
|Eriberto  | DD/MM/AA - Descrição                                                     |
|Daniel    | 23/10/07 - Adicionado filtro de Vendedor e Grupo de Clientes             | 
|Maximo    | 15/10/07 - Tratamento para ser executado na HQ (A1_VENDHQ)               | 
|Maximo    | 15/10/09 - Alterado o caminho do arquivo e PREPARE ENVIRONMENT           | 
\====================================================================================*/

#Include "RwMake.ch"
#INCLUDE "TBICONN.CH"
#INCLUDE "FILEIO.CH"

User Function DIPR028(aWork)
Local _xArea		:= GetArea()
Local titulo		:= OemTOAnsi("Posicao de Titulos a Receber - analitico - Por Cliente",72)
Local cDesc1		:= (OemToAnsi("Este programa tem como objetivo emitir um relat¢rio",72))
Local cDesc2		:= (OemToAnsi("com a posicao de titulos a receber.",72))
Local cDesc3		:= (OemToAnsi("Conforme parametros definidos pelo o usuario.",72))
Local _dDatIni		:= ""
Local _dDatFim		:= ""
Private aPar2		:= ""
Private aReturn	    := {"Bco A4", 1,"Administracao", 1, 2, 1,"",1}
Private li			:= 67
Private tamanho	    := "P"
Private limite		:= 80
Private nomeprog	:= "DIPR028"

// Private cPerg		:= "DIPR28"
// FPADR(cPerg, cArq, cCampo, cTipo)  - Para ajustar o tamanho das perguntas no SX1- uso generico
PRIVATE cPerg  	    

Private nLastKey	:= 0
Private lEnd		:= .F.
Private wnrel		:= "DIPR028"
Private cString	    := "SE1"
Private m_pag		:= 1
Private cWorkFlow	:= ""   
Private cWCodEmp    := ""  
Private cWCodFil    := ""  
Private _dDatIni    := ""
Private _dDatFim    := ""
//Tratamento para workflow
If ValType(aWork) <> 'A'
	cWorkFlow := "N"   
	cWCodEmp  := cEmpAnt
    cWCodFil  := cFilAnt                                                                   
	cPerg  	:= U_FPADR( "DIPR28","SX1","SX1->X1_GRUPO"," " ) //Função criada por Sandro em 19/11/09.
    U_DIPPROC(ProcName(0),U_DipUsr()) // JBS 13/12/2005 - Gravando o nome do Programa no SZU
Else
	cWorkFlow := aWork[1]
	cWCodEmp  := aWork[3]
    cWCodFil  := aWork[4]
EndIf

If cWorkFlow == "S" 
	PREPARE ENVIRONMENT EMPRESA cWCodEmp FILIAL cWCodFil FUNNAME "DIPR028"  //TABLES "SE1 "
EndIf

If cWorkFlow == "N"

	AjustaSX1(cPerg)           // Verifica perguntas. Se nao existe INCLUI.
	
	If !Pergunte(cPerg,.T.)    // Solicita parametros
		Return
	EndIf                      
	
	wnrel := SetPrint(cString,wnrel,cPerg,Titulo,cDesc1,cDesc2,cDesc3,.f.,,.f.,tamanho,,.f.,,,,,)

	If nLastKey == 27
		Return
	Endif
	
	SetDefault(aReturn,cString)
	
	RptStatus({|lEnd| RodaRel()},Titulo)
	
	Set device to Screen
	
	/*==========================================================================\
	| Se em disco, desvia para Spool                                          |
	\==========================================================================*/
	If aReturn[5] == 1    // Se Saida para disco, ativa SPOOL
		Set Printer TO
		Commit
		ourspool(wnrel)
	Endif
	
	
Else



	/*==========================================================================\
	| Este relatório executado via WORKFLOW, deverá usar as datas MV_PAR05,     |
	| MV_PAR06, MV_PAR07 e MV_PAR08. A data INICIAL deverá ser em branco e a    |
	| data final deverá usar a data do DDATABASE()-2, isto é, sempre voltar     |
	| dois dias na data final.                                                  |
	|                                                                           |
	\==========================================================================*/

	MV_PAR01 := aWork[2]
	MV_PAR02 := aWork[2]
	MV_PAR03 := '      '                    
	MV_PAR04 := 'ZZZZZZ'
	MV_PAR05 := CtoD('')
	MV_PAR06 := dDataBase - 1
	MV_PAR07 := CtoD('')
	MV_PAR08 := dDataBase + 720 // MCVN - 27/09/2007
	MV_PAR09 := ''
	MV_PAR10 := 'ZZZZZZ'
	MV_PAR11 := ''
	MV_PAR12 := ''
	MV_PAR13 := ''

	If Empty( Posicione("SA3",1,xFilial("SA3")+MV_PAR01,"A3_DESLIG") )
		ConOut(' ')
	    ConOut('Posicao de Titulos a Receber - Vendedor ' + MV_PAR01 + ' Inicio em '+dToc(date())+' as '+Time())
		ConOut(' ')
	
		RodaRel()
	
		ConOut(' ')
	    ConOut('Posicao de Titulos a Receber - Vendedor ' + MV_PAR01 + ' Concluido em '+dToc(date())+' as '+Time())
		ConOut(' ')
	EndIf
/*
	ConOut("--------------------------")
	ConOut('Inicio - ' + dToc(date())+' - '+Time())
	ConOut("--------------------------")
	RodaRel()
	ConOut("------------------------")
	ConOut('Fim - ' + dToc(date())+' - '+Time())
	ConOut("------------------------")
*/
Endif

RestArea(_xArea)

Return

//////////////////////////////////////////////////////////////////////
Static Function RodaRel()
Local _nTotVal		:= 0
Local _nTotSal		:= 0
Local _nTotValG	:= 0
Local _nTotSalG	:= 0
Local _nAtraso		:= 0
Local _cCliente	:= ''
Local _cVend		:= ''
Local cArq			:= ""
Local cCampos		:= ""
Local nHandle		:= ""
Local cDat_Emi		:= ""
Local cDat_Ven		:= ""
Local cVal_Tit		:= ""
Local cSal_Tit		:= ""

/*
SELECT E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO, E1_CLIENTE, E1_LOJA , A1_NOME, A1_TEL, E1_EMISSAO, E1_VENCTO, E1_VALOR, E1_SALDO, E1_VEND1, A3_NOME, A1_VEND, A3_EMAIL
FROM SE1010, SA3010, SA1010
WHERE E1_SALDO > 0
--AND E1_FILIAL = ''
AND E1_PORTADO BETWEEN '' AND 'ZZZZZZ'
AND E1_SITUACA BETWEEN '0' AND '3'
AND E1_EMISSAO BETWEEN '19980101' AND '20040831'
AND E1_VENCTO  BETWEEN '19850101' AND '20051231'
AND E1_CLIENTE BETWEEN '' AND 'ZZZZZZ'
AND A1_VEND BETWEEN '' AND 'ZZZZZZ'
AND E1_CLIENTE = A1_COD
AND E1_LOJA = A1_LOJA
AND A1_VEND = A3_COD
AND SE1010.D_E_L_E_T_ = ''
AND SA3010.D_E_L_E_T_ = ''
AND SA1010.D_E_L_E_T_ = ''
ORDER BY A1_VEND, A1_NOME, E1_NUM
*/

QRY1 := " SELECT E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO, E1_CLIENTE, E1_LOJA , A1_NOME, A1_TEL, E1_EMISSAO, E1_VENCTO, E1_VALOR, E1_SALDO, A3_NOME, "+If(("0401" $ cWCodEmp+cWCodFil),"A1_VENDHQ","E1_VEND1")+", A3_EMAIL"
QRY1 += " FROM " + RetSQLName("SE1")+', '+ RetSQLName("SA3")+', '+ RetSQLName("SA1")
QRY1 += " WHERE E1_FILIAL = '" +xFilial("SE1")+"'"
QRY1 += " AND  E1_SALDO > 0"
QRY1 += " AND "+If(("0401" $ cWCodEmp+cWCodFil),"A1_VENDHQ","E1_VEND1")+" BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "'"
QRY1 += " AND E1_CLIENTE BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"'"
QRY1 += " AND E1_EMISSAO BETWEEN '"+DTOS(MV_PAR05)+"' AND '"+DTOS(MV_PAR06)+"'"
If cWorkFlow == "N"  //MCVN 03/07/2007
	QRY1 += " AND E1_VENCTO  BETWEEN '"+DTOS(MV_PAR07)+"' AND '"+DTOS(MV_PAR08)+"'"
Endif
QRY1 += " AND E1_PORTADO BETWEEN '" + MV_PAR09 + "' AND '" + MV_PAR10 + "'"
If MV_PAR11 == '4' .and. MV_PAR12 == '4'// Quando for só 4
	QRY1 += " AND E1_SITUACA BETWEEN '" + MV_PAR11 + "' AND '" + MV_PAR12 + "'"
ElseIf Empty(MV_PAR11) // Todos exceto 4
	QRY1 += " AND E1_SITUACA <> '4'"
Else // Uma faixa de tanto a tanto (de 0 a 3) ou (de 5 a 7)
	QRY1 += " AND E1_SITUACA BETWEEN '" + MV_PAR11 + "' AND '" + MV_PAR12 + "'"
EndIf
QRY1 += " AND E1_CLIENTE = A1_COD"
QRY1 += " AND E1_LOJA = A1_LOJA"
QRY1 += " AND "+If(("0401" $ cWCodEmp+cWCodFil),"A1_VENDHQ","E1_VEND1")+" = A3_COD"        
If !Empty(MV_PAR13)
	QRY1 += " AND A1_GRPVEN = '" + MV_PAR13 + "'"
EndIf
If U_ListVend() != ''
	QRY1 += " AND "+If(("0401" $ cWCodEmp+cWCodFil),"A1_VENDHQ","E1_VEND1")+" "+U_ListVend()
EndIf
QRY1 += " AND " + RetSQLName('SE1') + ".D_E_L_E_T_ = ''"
QRY1 += " AND " + RetSQLName('SA3') + ".D_E_L_E_T_ = ''"
QRY1 += " AND " + RetSQLName('SA1') + ".D_E_L_E_T_ = '' "
QRY1 += "ORDER BY "+If(("0401" $ cWCodEmp+cWCodFil),"A1_VENDHQ","E1_VEND1")+", A1_NOME, E1_NUM"

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
TcQuery QRY1 NEW ALIAS "QRY1"         // Abre uma workarea com o resultado da query

DbSelectArea("QRY1")
QRY1->(dbGotop())

_cTitulo := "Posicao de Titulos a Receber"
_cDesc1  := "                                                                           Dias"
_cDesc2  := "Pfx Numero Parcela Tipo Emissao     Vencimento        Valor        Saldo Atraso"

If cWorkFlow == "S"  
	If ("0401" $ cWCodEmp+cWCodFil)
		cArq := "/VENDEDORES/HQ/"+MV_PAR01 + Substr(Dtoc(Date()),1,2) + Substr(Dtoc(Date()),4,2) + ".028"
	ElseIf ("0404" $ cWCodEmp+cWCodFil)                                                                  
		cArq := "/VENDEDORES/HQ-CD/"+MV_PAR01 + Substr(Dtoc(Date()),1,2) + Substr(Dtoc(Date()),4,2) + ".028"
	ElseIf ("0101" $ cWCodEmp+cWCodFil)                                                                  
		cArq := "/VENDEDORES/DIPROMED-MTZ/"+MV_PAR01 + Substr(Dtoc(Date()),1,2) + Substr(Dtoc(Date()),4,2) + ".028"			
	Else                                                                                                      
		cArq := "/VENDEDORES/DIPROMED/"+MV_PAR01 + Substr(Dtoc(Date()),1,2) + Substr(Dtoc(Date()),4,2) + ".028"
	Endif
	cCampos		:= ""
	nHandle		:= Fcreate(cArq,0)
Else
	SetRegua(RecCount())
EndIf

Do While QRY1->(!Eof())
	*         1         2         3         4         5         6         7         8         9         0         1         2         3         4         5         6         7         8         9         0
	*123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901
	*dipr028/v.AP6 6.09 Posicao de Titulos a Receber - analitico - PData.: 99/99/99
	*                                                                           Dias
	*Pfx Numero Parcela Tipo Emissao     Vencimento        Valor        Saldo Atraso
	*UNI 999999    A     NF  99/99/9999  99/99/9999 9.999.999,99 9.999.999,99  99999
	*                                       Totais: 9,999,999.99 9,999,999.99
	*                    Totais do Vendedor 999999:

		
	If cWorkFlow == "N" // SE NÃO FOR WORKFLOW

		If lAbortPrint
			@ li+1,00 PSAY "*** CANCELADO PELO OPERADOR ***"
			Exit
		Endif
	
		IncRegua( "Imprimindo... ")
		
		If li > 56 .or. _cVend <> If(("0401" $ cWCodEmp+cWCodFil),QRY1->A1_VENDHQ,QRY1->E1_VEND1)
			If _cVend <> If(("0401" $ cWCodEmp+cWCodFil),QRY1->A1_VENDHQ,QRY1->E1_VEND1)
				m_pag  := 1
				_cVend := If(("0401" $ cWCodEmp+cWCodFil),QRY1->A1_VENDHQ,QRY1->E1_VEND1)
			EndIf
			li := u_MYCabec(_cTitulo,_cDesc1,_cDesc2,nHandle,cWorkFlow)
			@ li,002 PSay "Vendedor: "+If(("0401" $ cWCodEmp+cWCodFil),QRY1->A1_VENDHQ,QRY1->E1_VEND1)+' - '+AllTrim(QRY1->A3_NOME)
			li+=2
		EndIf
		
		If _cCliente <> QRY1->E1_CLIENTE+QRY1->E1_LOJA
			@ li,002 PSay "Cliente: "+QRY1->E1_CLIENTE+'-'+QRY1->E1_LOJA+' - '+QRY1->A1_NOME
			li++

		// Verifica o salto de página			
		If li > 56 .or. _cVend <> If(("0401" $ cWCodEmp+cWCodFil),QRY1->A1_VENDHQ,QRY1->E1_VEND1)
			If _cVend <> If(("0401" $ cWCodEmp+cWCodFil),QRY1->A1_VENDHQ,QRY1->E1_VEND1)
				m_pag  := 1
				_cVend := If(("0401" $ cWCodEmp+cWCodFil),QRY1->A1_VENDHQ,QRY1->E1_VEND1)
			EndIf
			li := u_MYCabec(_cTitulo,_cDesc1,_cDesc2,nHandle,cWorkFlow)
			@ li,002 PSay "Vendedor: "+If(("0401" $ cWCodEmp+cWCodFil),QRY1->A1_VENDHQ,QRY1->E1_VEND1)+' - '+AllTrim(QRY1->A3_NOME)
			li+=2
		EndIf
		
			@ li,002 PSay 'Telefone: '+QRY1->A1_TEL
			li+=2

		// Verifica o salto de página			
		If li > 56 .or. _cVend <> If(("0401" $ cWCodEmp+cWCodFil),QRY1->A1_VENDHQ,QRY1->E1_VEND1)
			If _cVend <> If(("0401" $ cWCodEmp+cWCodFil),QRY1->A1_VENDHQ,QRY1->E1_VEND1)
				m_pag  := 1
				_cVend := If(("0401" $ cWCodEmp+cWCodFil),QRY1->A1_VENDHQ,QRY1->E1_VEND1)
			EndIf
			li := u_MYCabec(_cTitulo,_cDesc1,_cDesc2,nHandle,cWorkFlow)
			@ li,002 PSay "Vendedor: "+If(("0401" $ cWCodEmp+cWCodFil),QRY1->A1_VENDHQ,QRY1->E1_VEND1)+' - '+AllTrim(QRY1->A3_NOME)
			li+=2
		EndIf
	
			_cCliente := QRY1->E1_CLIENTE+QRY1->E1_LOJA
		EndIf
		
		If dDataBase > cTOd(SubStr(QRY1->E1_VENCTO,7,2)+'/'+SubStr(QRY1->E1_VENCTO,5,2)+'/'+SubStr(QRY1->E1_VENCTO,1,4))
			_nAtraso := dDataBase-cTOd(SubStr(QRY1->E1_VENCTO,7,2)+'/'+SubStr(QRY1->E1_VENCTO,5,2)+'/'+SubStr(QRY1->E1_VENCTO,1,4))
		Else
			_nAtraso := 0
		EndIf
		
		@ li,001 PSay QRY1->E1_PREFIXO
		@ li,005 PSay QRY1->E1_NUM
		@ li,015 PSay QRY1->E1_PARCELA
		@ li,020 PSay QRY1->E1_TIPO
		@ li,025 PSay SubStr(QRY1->E1_EMISSAO,7,2)+'/'+SubStr(QRY1->E1_EMISSAO,5,2)+'/'+SubStr(QRY1->E1_EMISSAO,1,4)
		@ li,037 PSay SubStr(QRY1->E1_VENCTO,7,2)+'/'+SubStr(QRY1->E1_VENCTO,5,2)+'/'+SubStr(QRY1->E1_VENCTO,1,4)
		@ li,048 PSay If(Alltrim(QRY1->E1_TIPO)$'NCC/RA',QRY1->E1_VALOR*-1,QRY1->E1_VALOR) PICTURE '@E 9,999,999.99'
		@ li,063 PSay If(Alltrim(QRY1->E1_TIPO)$'NCC/RA',QRY1->E1_SALDO*-1,QRY1->E1_SALDO) PICTURE '@E 9,999,999.99'
		@ li,076 PSay _nAtraso PICTURE '9999'
		li++
		
		
		// Verifica o salto de página			
		If li > 56 .or. _cVend <> If(("0401" $ cWCodEmp+cWCodFil),QRY1->A1_VENDHQ,QRY1->E1_VEND1)
			If _cVend <> If(("0401" $ cWCodEmp+cWCodFil),QRY1->A1_VENDHQ,QRY1->E1_VEND1)
				m_pag  := 1
				_cVend := If(("0401" $ cWCodEmp+cWCodFil),QRY1->A1_VENDHQ,QRY1->E1_VEND1)
			EndIf
			li := u_MYCabec(_cTitulo,_cDesc1,_cDesc2,nHandle,cWorkFlow)
			@ li,002 PSay "Vendedor: "+If(("0401" $ cWCodEmp+cWCodFil),QRY1->A1_VENDHQ,QRY1->E1_VEND1)+' - '+AllTrim(QRY1->A3_NOME)
			li+=2
		EndIf
	
		
		_nTotVal := _nTotVal + If(Alltrim(QRY1->E1_TIPO)$'NCC/RA',QRY1->E1_VALOR*-1,QRY1->E1_VALOR)
		_nTotSal := _nTotSal + If(Alltrim(QRY1->E1_TIPO)$'NCC/RA',QRY1->E1_SALDO*-1,QRY1->E1_SALDO)
	
		_nTotValG := _nTotValG + If(Alltrim(QRY1->E1_TIPO)$'NCC/RA',QRY1->E1_VALOR*-1,QRY1->E1_VALOR)
		_nTotSalG := _nTotSalG + If(Alltrim(QRY1->E1_TIPO)$'NCC/RA',QRY1->E1_SALDO*-1,QRY1->E1_SALDO)
			
		QRY1->(DbSkip())
		
		If _cCliente <> QRY1->E1_CLIENTE+QRY1->E1_LOJA .OR. QRY1->(EOF())
			@ li,040 PSay 'Totais: '
			@ li,048 PSay _nTotVal PICTURE '@E 9,999,999.99'
			@ li,063 PSay _nTotSal PICTURE '@E 9,999,999.99'
			li+=2

			_nTotVal  := 0
			_nTotSal  := 0
		EndIf
	
		If _cVend <> If(("0401" $ cWCodEmp+cWCodFil),QRY1->A1_VENDHQ,QRY1->E1_VEND1) .OR. QRY1->(EOF())
			@ li,021 PSay 'Total do vendedor '+_cVend+': '
			@ li,048 PSay _nTotValG PICTURE '@E 9,999,999.99'
			@ li,063 PSay _nTotSalG PICTURE '@E 9,999,999.99'
			li+=2
			
			_nTotValG := 0
			_nTotSalG := 0
		EndIf
		
	Else	// CASO SEJA WORKFLOW
		/*----------------------------- A T E N Ç Ã O ------------------------------------	
		Para correta impressão do relatório verificar as seguintes configurações de 
		impressão no bloco de notas (NotePad):
		Fonte Courier - Normal - 10
		Papel Carta 21,59 X 27,94cm
		Margens: Direita 20 , Esquerda 20 , Superior 25 e Inferior 20
		---------------------------------------------------------------------------------*/	

		// Verifica o salto de página
		If li > 56 .or. _cVend <> If(("0401" $ cWCodEmp+cWCodFil),QRY1->A1_VENDHQ,QRY1->E1_VEND1)
			If _cVend <> If(("0401" $ cWCodEmp+cWCodFil),QRY1->A1_VENDHQ,QRY1->E1_VEND1)
				m_pag  := 1
				_cVend := If(("0401" $ cWCodEmp+cWCodFil),QRY1->A1_VENDHQ,QRY1->E1_VEND1)
			EndIf
			li := u_MYCabec(_cTitulo,_cDesc1,_cDesc2,nHandle,cWorkFlow)
			cCampos := "Vendedor: " + If(("0401" $ cWCodEmp+cWCodFil),QRY1->A1_VENDHQ,QRY1->E1_VEND1) + ' - ' + AllTrim(QRY1->A3_NOME) + chr(13) + chr(10) + chr(13) + chr(10)
			Fwrite(nHandle,cCampos)
			cCampos := ""
			li+=2
		EndIf
		
		If _cCliente <> QRY1->E1_CLIENTE+QRY1->E1_LOJA
			cCampos := "Cliente: "+QRY1->E1_CLIENTE+'-'+QRY1->E1_LOJA+' - '+QRY1->A1_NOME + chr(13)+chr(10)
			li++
			Fwrite(nHandle,cCampos)

			// Verifica o salto de página
			If li > 56 .or. _cVend <> If(("0401" $ cWCodEmp+cWCodFil),QRY1->A1_VENDHQ,QRY1->E1_VEND1)
				If _cVend <> If(("0401" $ cWCodEmp+cWCodFil),QRY1->A1_VENDHQ,QRY1->E1_VEND1)
					m_pag  := 1
					_cVend := If(("0401" $ cWCodEmp+cWCodFil),QRY1->A1_VENDHQ,QRY1->E1_VEND1)
				EndIf
				li := u_MYCabec(_cTitulo,_cDesc1,_cDesc2,nHandle,cWorkFlow)
				cCampos := "Vendedor: " + If(("0401" $ cWCodEmp+cWCodFil),QRY1->A1_VENDHQ,QRY1->E1_VEND1) + ' - ' + AllTrim(QRY1->A3_NOME) + chr(13) + chr(10) + chr(13) + chr(10)
				Fwrite(nHandle,cCampos)
				cCampos := ""
				li+=2
			EndIf
	
			cCampos := 'Telefone: '+QRY1->A1_TEL + chr(13)+chr(10)
			li++    
			Fwrite(nHandle,cCampos)
			
			// Verifica o salto de página
			If li > 56 .or. _cVend <> If(("0401" $ cWCodEmp+cWCodFil),QRY1->A1_VENDHQ,QRY1->E1_VEND1)
				If _cVend <> If(("0401" $ cWCodEmp+cWCodFil),QRY1->A1_VENDHQ,QRY1->E1_VEND1)
					m_pag  := 1
					_cVend := If(("0401" $ cWCodEmp+cWCodFil),QRY1->A1_VENDHQ,QRY1->E1_VEND1)
				EndIf
				li := u_MYCabec(_cTitulo,_cDesc1,_cDesc2,nHandle,cWorkFlow)
				cCampos := "Vendedor: " + If(("0401" $ cWCodEmp+cWCodFil),QRY1->A1_VENDHQ,QRY1->E1_VEND1) + ' - ' + AllTrim(QRY1->A3_NOME) + chr(13) + chr(10) + chr(13) + chr(10)
				Fwrite(nHandle,cCampos)
				cCampos := ""
				li+=2
			EndIf
			_cCliente := QRY1->E1_CLIENTE+QRY1->E1_LOJA
		EndIf
		
		If dDataBase > cTOd(SubStr(QRY1->E1_VENCTO,7,2)+'/'+SubStr(QRY1->E1_VENCTO,5,2)+'/'+SubStr(QRY1->E1_VENCTO,1,4))
			_nAtraso := dDataBase-cTOd(SubStr(QRY1->E1_VENCTO,7,2)+'/'+SubStr(QRY1->E1_VENCTO,5,2)+'/'+SubStr(QRY1->E1_VENCTO,1,4))
		Else
			_nAtraso := 0
		EndIf
		
		cCampos := QRY1->E1_PREFIXO+Space(01)
		cCampos += QRY1->E1_NUM+Space(04)
		cCampos += QRY1->E1_PARCELA+Space(05)
		cCampos += QRY1->E1_TIPO+Space(02)
		cCampos += AllTrim(SubStr(QRY1->E1_EMISSAO,7,2)+'/'+SubStr(QRY1->E1_EMISSAO,5,2)+'/'+SubStr(QRY1->E1_EMISSAO,1,4))+Space(02)
		cCampos += AllTrim(SubStr(QRY1->E1_VENCTO,7,2) +'/'+SubStr(QRY1->E1_VENCTO,5,2) +'/'+SubStr(QRY1->E1_VENCTO,1,4 ))+Space(01)
		cCampos += TRANSFORM(If(Alltrim(QRY1->E1_TIPO)$'NCC/RA',QRY1->E1_VALOR*-1,QRY1->E1_VALOR), "@E 9,999,999.99")+Space(01)
		cCampos += TRANSFORM(If(Alltrim(QRY1->E1_TIPO)$'NCC/RA',QRY1->E1_SALDO*-1,QRY1->E1_SALDO), "@E 9,999,999.99")+Space(02)
		cCampos += TRANSFORM(_nAtraso, '9999')+Chr(13)+Chr(10)
		Fwrite(nHandle,cCampos)
		cCampos := ""
		li++
	
		// Verifica o salto de página
		If li > 56 .or. _cVend <> If(("0401" $ cWCodEmp+cWCodFil),QRY1->A1_VENDHQ,QRY1->E1_VEND1)
			If _cVend <> If(("0401" $ cWCodEmp+cWCodFil),QRY1->A1_VENDHQ,QRY1->E1_VEND1)
				m_pag  := 1
				_cVend := If(("0401" $ cWCodEmp+cWCodFil),QRY1->A1_VENDHQ,QRY1->E1_VEND1)
			EndIf
			li := u_MYCabec(_cTitulo,_cDesc1,_cDesc2,nHandle,cWorkFlow)
			cCampos := "Vendedor: " + If(("0401" $ cWCodEmp+cWCodFil),QRY1->A1_VENDHQ,QRY1->E1_VEND1) + ' - ' + AllTrim(QRY1->A3_NOME) + chr(13) + chr(10) + chr(13) + chr(10)
			Fwrite(nHandle,cCampos)
			cCampos := ""
			li+=2
		EndIf
		
		_nTotVal := _nTotVal + If(Alltrim(QRY1->E1_TIPO)$'NCC/RA',QRY1->E1_VALOR*-1,QRY1->E1_VALOR)
		_nTotSal := _nTotSal + If(Alltrim(QRY1->E1_TIPO)$'NCC/RA',QRY1->E1_SALDO*-1,QRY1->E1_SALDO)
	
		_nTotValG := _nTotValG + If(Alltrim(QRY1->E1_TIPO)$'NCC/RA',QRY1->E1_VALOR*-1,QRY1->E1_VALOR)
		_nTotSalG := _nTotSalG + If(Alltrim(QRY1->E1_TIPO)$'NCC/RA',QRY1->E1_SALDO*-1,QRY1->E1_SALDO)
		
		If Empty(AllTrim(QRY1->A3_EMAIL))
			cEmail	:= "maximo@dipromed.com.br"
		Else
			cEmail	:= AllTrim(QRY1->A3_EMAIL)
		EndIf
		
		cEmail	:= "maximo@dipromed.com.br"

		//Rafael Moraes Rosa - 28/06/2023 - Linha abaixo adicionada
		cEmail	:= IIF(Empty(SUPERGETMV("MV_#EMLSCH", .F., "")),cEmail,GETMV("MV_#EMLSCH"))
		
		QRY1->(DbSkip())
		
		If _cCliente <> QRY1->E1_CLIENTE+QRY1->E1_LOJA .OR. QRY1->(EOF())
			cCampos := Space(40) + 'Totais: '
			cCampos += TRANSFORM(_nTotVal, "@E 9,999,999.99") + Space(01)
			cCampos += TRANSFORM(_nTotSal, "@E 9,999,999.99") + chr(13) + chr(10) + chr(13) + chr(10)
			Fwrite(nHandle,cCampos)
			li+=2
			
		// Verifica o salto de página
		If li > 56 .or. _cVend <> If(("0401" $ cWCodEmp+cWCodFil),QRY1->A1_VENDHQ,QRY1->E1_VEND1)
			If _cVend <> If(("0401" $ cWCodEmp+cWCodFil),QRY1->A1_VENDHQ,QRY1->E1_VEND1)
				m_pag  := 1
				_cVend := If(("0401" $ cWCodEmp+cWCodFil),QRY1->A1_VENDHQ,QRY1->E1_VEND1)
			EndIf
			li := u_MYCabec(_cTitulo,_cDesc1,_cDesc2,nHandle,cWorkFlow)
			cCampos := "Vendedor: " + If(("0401" $ cWCodEmp+cWCodFil),QRY1->A1_VENDHQ,QRY1->E1_VEND1) + ' - ' + AllTrim(QRY1->A3_NOME) + chr(13) + chr(10) + chr(13) + chr(10)
			Fwrite(nHandle,cCampos)
			cCampos := ""
			li+=2
		EndIf
	
			_nTotVal  := 0
			_nTotSal  := 0
		EndIf
	
		If _cVend <> If(("0401" $ cWCodEmp+cWCodFil),QRY1->A1_VENDHQ,QRY1->E1_VEND1) .OR. QRY1->(EOF())
			cCampos += Space(22) + 'Total do vendedor '+_cVend+': '
			cCampos += TRANSFORM(_nTotValG, "@E 9,999,999.99") + Space(01)
			cCampos += TRANSFORM(_nTotSalG, "@E 9,999,999.99") + chr(13) + chr(10) + chr(13) + chr(10)
			Fwrite(nHandle,cCampos)
			cCampos := ""
			li+=2
			
		// Verifica o salto de página
		If li > 56 .or. _cVend <> If(("0401" $ cWCodEmp+cWCodFil),QRY1->A1_VENDHQ,QRY1->E1_VEND1)
			If _cVend <> If(("0401" $ cWCodEmp+cWCodFil),QRY1->A1_VENDHQ,QRY1->E1_VEND1)
				m_pag  := 1
				_cVend := If(("0401" $ cWCodEmp+cWCodFil),QRY1->A1_VENDHQ,QRY1->E1_VEND1)
			EndIf
			li := u_MYCabec(_cTitulo,_cDesc1,_cDesc2,nHandle,cWorkFlow)
			cCampos := "Vendedor: " + If(("0401" $ cWCodEmp+cWCodFil),QRY1->A1_VENDHQ,QRY1->E1_VEND1) + ' - ' + AllTrim(QRY1->A3_NOME) + chr(13) + chr(10) + chr(13) + chr(10)
			Fwrite(nHandle,cCampos)
			cCampos := ""
			li+=2
		EndIf
	
			_nTotValG := 0
			_nTotSalG := 0
		EndIf
	EndIf
EndDo

If cWorkFlow == "N"
	If li <> 80
		@ 062,000 PSAY 'Impresso em '+DtoC(DATE())+' as '+TIME()
	EndIf
Else

	If li <> 80
		cCampos += Space(Limite-(Len('Impresso em '+DtoC(DATE())+' às '+TIME())))
		cCampos += 'Impresso em '+DtoC(DATE())+' às '+TIME() + chr(13) + chr(10)
		li+=2
		Fwrite(nHandle,cCampos)
		cCampos := "Padrões de impressão p/ bloco de notas (NotePad):" + chr(13) + chr(10)
		cCampos += "Fonte Courier - Normal - 10 " + chr(13) + chr(10)
		cCampos += "Papel Carta 21,59 X 27,94cm " + chr(13) + chr(10)
		cCampos += "Margens: Direita 20 , Esquerda 20 , Superior 25 e Inferior 20"
		Fwrite(nHandle,cCampos)
		cCampos := ""
	EndIf
	Fclose(nHandle)
	
EndIf

dbSelectArea("QRY1")
QRY1->(dbCloseArea())
Return(.T.)


/*==========================================================================\
|Programa  |VALIDPERG| Autor | Rafael de Campos Falco  | Data ³ 04/06/2004  |
|===========================================================================|
|Desc.     | Inclui as perguntas caso nao existam                           |
|===========================================================================|
|Sintaxe   | VALIDPERG                                                      |
|===========================================================================|
|Uso       | Especifico DIPROMED                                            |
|===========================================================================|
|Histórico | DD/MM/AA - Descrição da alteração                              |
\==========================================================================*/

Static Function AjustaSX1(cPerg)
_sAlias := Alias()
dbSelectArea("SX1")
dbSetOrder(1)                                                                                   

aRegs:={}

//------------ Grupo/Ordem/Pergunta/PERGING/PERGESP/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05/F3

AADD(aRegs,{cPerg,"01","De vendedor        ?","","","mv_ch1","C",6,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","",'SA3'})
AADD(aRegs,{cPerg,"02","Ate vendedor       ?","","","mv_ch2","C",6,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","",'SA3'})
AADD(aRegs,{cPerg,"03","De cliente         ?","","","mv_ch3","C",6,0,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","",'SA1'})
AADD(aRegs,{cPerg,"04","Ate cliente        ?","","","mv_ch4","C",6,0,0,"G","","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","",'SA1'})
AADD(aRegs,{cPerg,"05","Emissao de         ?","","","mv_ch5","D",8,0,0,"G","","mv_par05","","","","","","","","","","","","","","","","","","","","","","","","","",""})
AADD(aRegs,{cPerg,"06","Emissao ate        ?","","","mv_ch6","D",8,0,0,"G","","mv_par06","","","","","","","","","","","","","","","","","","","","","","","","","",""})
AADD(aRegs,{cPerg,"07","Vencimento de      ?","","","mv_ch7","D",8,0,0,"G","","mv_par07","","","","","","","","","","","","","","","","","","","","","","","","","",""})
AADD(aRegs,{cPerg,"08","Vencimento ate     ?","","","mv_ch8","D",8,0,0,"G","","mv_par08","","","","","","","","","","","","","","","","","","","","","","","","","",""})
AADD(aRegs,{cPerg,"09","Do Banco           ?","","","mv_ch9","C",6,0,0,"G","","mv_par09","","","","","","","","","","","","","","","","","","","","","","","","",''})
AADD(aRegs,{cPerg,"10","Ate Banco          ?","","","mv_cha","C",6,0,0,"G","","mv_par10","","","","","","","","","","","","","","","","","","","","","","","","",''})
AADD(aRegs,{cPerg,"11","Situação de        ?","","","mv_chb","C",1,0,0,"G","","mv_par11","","","","","","","","","","","","","","","","","","","","","","","","",""})
AADD(aRegs,{cPerg,"12","Situação até       ?","","","mv_chc","C",1,0,0,"G","","mv_par12","","","","","","","","","","","","","","","","","","","","","","","","",""})
AADD(aRegs,{cPerg,"13","Grupo de Clientes  ?","","","mv_chd","C",6,0,0,"G","","mv_par13","","","","","","","","","","","","","","","","","","","","","","","","","ACY"})
//AADD(aRegs,{cPerg,"13","Envia Email        ?","","","mv_chd","N",1,0,0,"C","","mv_par13","1-Sim","","","","","2-Não","","","","","","","","","","","","","","","","","","",''})

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
///////////////////////////////////////////////////////////////////////////

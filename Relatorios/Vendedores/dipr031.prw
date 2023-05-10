/*==========================================================================\
|Programa  | DIPR031 | Autor | Eriberto Elias         | Data | 28/03/2003   |
|===========================================================================|
|Descrição | Relacao de baixas por vendedor e total por mes de emissao      |
|===========================================================================|
|Sintaxe   | DIPR031                                                        |
|===========================================================================|
|Uso       | Especifico DIPROMED                                            |
|===========================================================================|
|Maximo    | 23/08/07 - Incluir tratamento p/ gerar relatírio p/ vendedor 2 |
|Daniel    | 01/11/07 - Adicionado Filtro de Vendedor e Grupo de Clientes   | 
|Maximo    | 15/10/09 - Alterado o caminho do arquivo e PREPARE ENVIRONMENT | 
\==========================================================================*/

#Include "RwMake.ch"
#INCLUDE "TBICONN.CH"
#INCLUDE "FILEIO.CH"

User Function DIPR031(aWork)

Local _xArea       := GetArea()
Local titulo       := OemTOAnsi("Relacao de recebimentos por vendedor...",72)
Local cDesc1       := (OemToAnsi("Este programa tem como objetivo emitir um relat¢rio",72))
Local cDesc2       := (OemToAnsi("com os recebimentos por vendedor e totalizando por mes.",72))
Local cDesc3       := (OemToAnsi("Conforme parametros definidos pelo o usuario.",72))
Local _aFeriad	  	 := {}
Private aReturn    := {"Bco A4", 1,"Estoques", 1, 2, 1,"",1}
Private li         := 67
Private tamanho    := "P"
Private limite     := 80
Private nomeprog   := "DIPR031"

// Private cPerg      := "DIPR31"
// FPADR(cPerg, cArq, cCampo, cTipo)  - Para ajustar o tamanho das perguntas no SX1- uso generico
PRIVATE cPerg  	

Private nLastKey   := 0
Private lEnd       := .F.
Private wnrel      := "DIPR031"
Private cString    := "SE1"
Private m_pag      := 1
Private cWorkFlow := ""     
Private cWCodEmp  := ""  
Private cWCodFil  := "" 
Private nHandle	:= ""   
Private _dDatIni   := ""
Private _dDatFim   := ""
If ValType(aWork) <> 'A'
	cWorkFlow := "N" 
	cWCodEmp  := cEmpAnt
    cWCodFil  := cFilAnt 
	cPerg  	  := U_FPADR( "DIPR31","SX1","SX1->X1_GRUPO"," " ) //Função criada por Sandro em 19/11/09.
    U_DIPPROC(ProcName(0),U_DipUsr()) // JBS 13/12/2005 - Gravando o nome do Programa no SZU
Else                                                       
	cWorkFlow := aWork[1]    
	cWCodEmp  := aWork[3]
    cWCodFil  := aWork[4]     
    If cWorkFlow == "S"
		PREPARE ENVIRONMENT EMPRESA cWCodEmp FILIAL cWCodFil FUNNAME "DIPR031"  TABLES "SX5"
	EndIf
EndIf

If cWorkFlow == "N" 

	AjustaSX1(cPerg)             // Verifica perguntas. Se nao existe INCLUI

	If !Pergunte(cPerg,.T.)     // Solicita parametro
		Return
	EndIf

	wnrel := SetPrint(cString,wnrel,cPerg,Titulo,cDesc1,cDesc2,cDesc3,.T.)

	If nLastKey == 27                                                                                           
		Return
	Endif

	SetDefault(aReturn,cString)

	RptStatus({|lEnd| RodaRel()},Titulo)

	Set device to Screen

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Se em disco, desvia para Spool                                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If aReturn[5] == 1    // Se Saida para disco, ativa SPOOL
		Set Printer TO
		Commit
		ourspool(wnrel)
	Endif
Else

	/*==========================================================================\
	| Este relatório executado via WORKFLOW, deverá usar as datas MV_PAR02 e    |
	| MV_PAR03. A data INICIAL deverá ser calculada da seguinte forma, a data   |
	| atual do sistema DDATABASE(), deverá verificar se a data é o 3o. dia útil |
	| ou menor que ele se sim deverá voltar para o dia 01 do mês anterior e o   |
	| útimo dia do mês anterior. Caso a data esteja no 4o. útil em diante deverá|
	| usar o mês atual começando pelo dia 1o. até o último dîa do mês atual     |
	|                                                                           |
	\==========================================================================*/

	// Montagem do array com feriados
	dbSelectArea("SX5")
	dbSetOrder(1)
	dbSeek(xFilial("SX5")+"63")
	While X5_TABELA == "63"
		If SubStr(X5_DESCRI,1,1) != "*" .and. Val(SubStr(X5_DESCRI,7,2)) < 80 // Condição para pegar campos somente com datas e com ano de 2000 em diante
			// Monta data extraída do campo X5_DESCRI
			cTemp := Iif(Empty(SubStr(X5_DESCRI,7,2)),CtoD(SubStr(X5_DESCRI,1,2)+"/"+SubStr(X5_DESCRI,4,2)+"/"+"20"+AllTrim(Str(Year(Date())))),CtoD(SubStr(X5_DESCRI,1,2)+"/"+SubStr(X5_DESCRI,4,2)+"/"+"20"+SubStr(X5_DESCRI,7,2)))
			Aadd(_aFeriad,{cTOD(AllTrim(cTemp))})
		EndIf
		SX5->(DbSkip())
	EndDo
	
/*	// Verificação da data se o dia é feriado, se sim voltar (-1) dia
	_nPos := Ascan(_aFeriad,{|y| y[1] == dDatSis}) // Verifica se data é um Feriado
	If _nPos == 0 	// Se a data for um feriado despreza o dia
		dDatSis := dDatSis-1	
	EndIf

	// Verificação da data se o dia é domingo, se sim voltar (-1) dia
	If (AllTrim(cDow(dDatSis)) == "Sunday")// Descarta qdo. for Domingo
		dDatSis := dDatSis-1	
	EndIf

	// Verificação da data se o dia é sábado, se sim voltar (-1) dia
	If (AllTrim(cDow(dDatSis)) == "Saturday") // Descarta qdo. for Sábado
		dDatSis := dDatSis-1	
	EndIf*/
	     

	/*==========================================================================\
	| No bloco seguinte é feita a identificação do 3o. dia útil do mês atual    |
	|                                                                           |
	\==========================================================================*/

  	// Data do DIA atual
	nConta := 0
	nDia_Uti:= 0
	dDatSis := Date()
	dDatUti := FirstDay(dDatSis)
	
	// Verifica se data do dia útil é um feriado ou ponte  MCVN - 04/09/2007
	While nConta < 4 // Quantidade de DIAS utéis considerando que os relatórios são enviados na madrugada do dia seguinte MCVN - 04/09/2007
		_nPos := Ascan(_aFeriad,{|y| y[1] == dDatUti}) // Verifica se data é um Feriado
		If _nPos != 0 	// Se a data for um feriado despreza o dia
			nDia_Uti++
		Else
			// verifica se data do dia útil é um sábado ou domingo
			If cDow(dDatUti) == "Saturday"
				nDia_Uti++
			ElseIf cDow(dDatUti) == "Sunday"
				nDia_Uti++
			Endif
						
 		EndIf
        nConta++   
        dDatUti++
        nDia_Uti++
	EndDo
                
  
  	// Data do DIA atual
	//dDatSis := Date()
	
	// Verificação se está entre o 1o. e 3o. dia útil para voltar para o mês anterior
   If val(substr(dtos(dDatSis),7,2)) > nDia_Uti
   		_dDatIni := FirstDay(dDatSis)	// Primeiro dia
		_dDatFim := LastDay (dDatSis)	// Último Dia
	Else   
		_dDatIni := FirstDay(dDatSis)-10 // volta para o mês anterior			
   		_dDatIni := FirstDay(_dDatIni)	// Primeiro dia
		_dDatFim := LastDay (_dDatIni)	// Último Dia
	EndIf

	// Parâmetros do vendedor
	MV_PAR01 := aWork[2]
	MV_PAR02 := _dDatIni
	MV_PAR03 := _dDatFim
	MV_PAR04 := ""

	If Empty( Posicione("SA3",1,xFilial("SA3")+MV_PAR01,"A3_DESLIG") )
		ConOut(' ')
	    ConOut('Relacao de baixas - Vendedor ' + MV_PAR01 + ' Inicio em '+dToc(date())+' as '+Time())
		ConOut(' ')
		
		RodaReL()	
	
		ConOut(' ')
	    ConOut('Relacao de baixas - Vendedor ' + MV_PAR01 + ' Concluido em '+dToc(date())+' as '+Time())
		ConOut(' ')
	EndIf	
/*	
	ConOut("--------------------------")
	ConOut('Inicio - ' + dToc(date())+' - '+Time())
	ConOut("--------------------------")
	
	RodaReL()	

	ConOut("------------------------")
	ConOut('Fim - ' + dToc(date())+' - '+Time())
	ConOut("------------------------")
*/
EndIf

RestArea(_xArea)
	
Return

//////////////////////////////////////////////////////////////////////
Static Function RodaRel()
Local _nTotBax := 0
Local _cTitulo	:= "" 
Local _cDesc1	:= ""
Local _cDesc2	:= ""
Local cCampos	:= ""
Local cCodCli  := ""

ProcRegua(3000)
For _x := 1 to 1500
	IncProc( "Processando...BAIXAS ")
Next

/*
SELECT DISTINCT E5_NUMERO, E5_PREFIXO, E5_PARCELA, E5_TIPO, E5_CLIFOR, E1_NOMCLI, E5_DATA, E1_VENCORI, E5_VALOR, E5_BANCO, E5_MOTBX, A3_NOME, E5_LOJA
FROM SE5010, SE1010, SA3010
WHERE E5_DATA BETWEEN '20031101' AND '20031130'
AND E5_RECPAG = 'R'
AND E5_MOTBX <> 'DAC'
AND E5_TIPO IN ('NCC','NF')
AND E5_PARCELA = E1_PARCELA
AND E5_PREFIXO = E1_PREFIXO
AND E5_NUMERO = E1_NUM
AND E1_VEND1 = '000190'
AND A3_COD = '000190'
AND SE5010.D_E_L_E_T_ <> '*'
AND SE1010.D_E_L_E_T_ <> '*'
AND SA3010.D_E_L_E_T_ <> '*'
ORDER BY E5_DATA, E1_VENCORI
*/        

QRY1 := " SELECT DISTINCT E5_NUMERO, E5_PREFIXO, E5_PARCELA, E5_TIPO, E5_CLIFOR, E1_NOMCLI, E5_DATA, E1_VENCORI, E5_VALOR, E5_BANCO, E5_MOTBX, A3_NOME, E5_LOJA"
QRY1 += " FROM " + RetSQLName("SE5") + ',' + RetSQLName('SE1') + ',' + RetSQLName('SA3') + ',' + RetSQLName('SA1')
QRY1 += " WHERE E5_DATA BETWEEN '" + DTOS(MV_PAR02) + "' AND '" + DTOS(MV_PAR03) +"' "  
QRY1 += " AND E5_RECPAG = 'R'"
QRY1 += " AND E5_MOTBX <> 'DAC'"
QRY1 += " AND E5_TIPO IN ('NCC','NF')"
QRY1 += " AND E5_PARCELA = E1_PARCELA"
QRY1 += " AND E5_PREFIXO = E1_PREFIXO "
QRY1 += " AND E5_NUMERO  = E1_NUM "             
// MCVN - 08/03/2010
QRY1 += " AND E1_FILIAL = '"+xFilial("SE1")+"'" 
QRY1 += " AND E5_FILIAL = '"+xFilial("SE5")+"'" 
QRY1 += " AND A1_FILIAL = '"+xFilial("SA1")+"'"
QRY1 += " AND A1_COD = E1_CLIENTE"
QRY1 += " AND A1_LOJA = E1_LOJA"   

//QRY1 += " AND E1_VEND1 =  '" + MV_PAR01 + "'"
QRY1 += " AND (E1_VEND1 =  '" + MV_PAR01 + "' OR E1_VEND2 =  '" + MV_PAR01 + "')"  //MCVN - 24/08/07
QRY1 += " AND A3_COD = '" + MV_PAR01 + "'"
If U_ListVend() != ''
	QRY1 += " AND (E1_VEND1 " + U_ListVend() + " OR E1_VEND2 " + U_ListVend() + ")" 
EndIf        
If !Empty(MV_PAR04)
	QRY1 += " AND A1_GRPVEN = '"+MV_PAR04+"'"	
EndIf
QRY1 += " AND " + RetSQLName('SE5') + ".D_E_L_E_T_ = ' '"
QRY1 += " AND " + RetSQLName('SA1') + ".D_E_L_E_T_ = ' '"
QRY1 += " AND " + RetSQLName('SE1') + ".D_E_L_E_T_ = ' '"
QRY1 += " AND " + RetSQLName('SA3') + ".D_E_L_E_T_ = ' '"
QRY1 += " ORDER BY E5_DATA, E1_VENCORI"

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
DbGoTop()


_cTitulo := "Relacao de Baixas por vendedor"
_cDesc1  := "Prf Número P TP  Dt. Venc.  Dt. Baixa          Valor Bco MotBx"
_cDesc2	:= ""
_cNomVen := "Vendedor: " +mv_par01+' - '+AllTrim(QRY1->A3_NOME)+' - Período de '+Substr(DTOC(MV_PAR02),1,2)+' até '+DTOC(mv_par03)

//Monta o nome do arquivo caso seja WORKFLOW
If cWorkFlow == "S"        
	If ("0401" $ cWCodEmp+cWCodFil)
		cArq := "/VENDEDORES/HQ/" + MV_PAR01 + Substr(Dtoc(Date()),1,2) + Substr(Dtoc(Date()),4,2) + ".031"
	ElseIf ("0404" $ cWCodEmp+cWCodFil)                                                                    
		cArq := "/VENDEDORES/HQ-CD/" + MV_PAR01 + Substr(Dtoc(Date()),1,2) + Substr(Dtoc(Date()),4,2) + ".031"	
	ElseIf ("0101" $ cWCodEmp+cWCodFil)                                                                  
		cArq := "/VENDEDORES/DIPROMED-MTZ/"+MV_PAR01 + Substr(Dtoc(Date()),1,2) + Substr(Dtoc(Date()),4,2) + ".031"			
	Else                                                                                                    
		cArq := "/VENDEDORES/DIPROMED/" + MV_PAR01 + Substr(Dtoc(Date()),1,2) + Substr(Dtoc(Date()),4,2) + ".031"
	Endif
	cCampos		:= ""
	nHandle		:= Fcreate(cArq,0)
Else
	SetRegua(QRY1->(RecCount()))
EndIf

QRY1->(DbGoTop())

Do While QRY1->(!Eof())

	// quebra de página
	If li > 56
		u_Pag031(_cTitulo,_cDesc1,_cDesc2,nHandle,cWorkFlow)
	EndIf
	
	*         1         2         3         4         5         6         7         8         9         0         1         2         3         4         5         6         7         8         9         0
	*123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901
	*Vendedor: 000190 - CRISTINA SANTOS - Período de 01/01/01 até 31/01/01
	*Prf Número P TP  Dt. Baixa  Dt. Digit.         Valor Bco MotBx
	*----------------------------------------------------------------------------------------------------
	*999999-99-XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX 
	*XXX 999999 X XX  99/99/9999 99/99/9999 99.999.999,99 XXX XXX
	*----------------------------------------------------------------------------------------------------
	*Total das Baixas de 01 a 31/01/01 =>  99.999.999,99
	*----------------------------------------------------------------------------------------------------
	If cWorkFlow == "N"	
		IncRegua( "Imprimindo... " + QRY1->E1_NOMCLI)

      // Imprime código, loja e nome do cliente
		If QRY1->E5_CLIFOR != cCodCli
			li++
			@ li,001 PSay QRY1->E5_CLIFOR + '-' + QRY1->E5_LOJA
			@ li,010 PSay '-' + QRY1->E1_NOMCLI
			li++
			cCodCli := QRY1->E5_CLIFOR
		EndIf	
		
		@ li,000 PSay QRY1->E5_PREFIXO
		@ li,005 PSay QRY1->E5_NUMERO
		@ li,012 PSay QRY1->E5_PARCELA
		@ li,014 PSay QRY1->E5_TIPO
		@ li,018 PSay SubStr(QRY1->E1_VENCORI,7,2)+'/'+SubStr(QRY1->E1_VENCORI,5,2)+'/'+SubStr(QRY1->E1_VENCORI,1,4)
		@ li,029 PSay SubStr(QRY1->E5_DATA,7,2)+'/'+SubStr(QRY1->E5_DATA,5,2)+'/'+SubStr(QRY1->E5_DATA,1,4)
		@ li,040 PSay QRY1->E5_VALOR PICTURE '@E 99,999,999.99'
		@ li,054 PSay QRY1->E5_BANCO
		@ li,058 PSay QRY1->E5_MOTBX	
		li++

		// Gera totais com base no tipo do documento (NF / NCC)
		If AllTrim(QRY1->E5_TIPO) == 'NF'
			_nTotBax += QRY1->E5_VALOR
		Else
			_nTotBax -= QRY1->E5_VALOR
		EndIf
		
		QRY1->(DbSkip())

	Else
	
		// Imprime código, loja, nome do cliente
		If QRY1->E5_CLIFOR != cCodCli
			li++
			// quebra de página
			If li > 56
				u_Pag031(_cTitulo,_cDesc1,_cDesc2,nHandle,cWorkFlow)
				Fwrite(nHandle,cCampos)
				li++
			EndIf
			cCampos := Chr(13) + Chr(10) + QRY1->E5_CLIFOR + '-' + QRY1->E5_LOJA
			cCampos += '-' + QRY1->E1_NOMCLI + Chr(13) + Chr(10)
			Fwrite(nHandle,cCampos)
			li++
			// quebra de página
			If li > 56
				u_Pag031(_cTitulo,_cDesc1,_cDesc2,nHandle,cWorkFlow)
				Fwrite(nHandle,cCampos)
				li++
			EndIf
			cCodCli := QRY1->E5_CLIFOR
		EndIf
		
		cCampos := QRY1->E5_PREFIXO + Space(01)
		cCampos += QRY1->E5_NUMERO + Space(01)
		cCampos += QRY1->E5_PARCELA + Space(01)
		cCampos += QRY1->E5_TIPO + Space(01)
		cCampos += SubStr(QRY1->E1_VENCORI,7,2)+'/'+SubStr(QRY1->E1_VENCORI,5,2)+'/'+SubStr(QRY1->E1_VENCORI,1,4) + Space(01)
		cCampos += SubStr(QRY1->E5_DATA,7,2)+'/'+SubStr(QRY1->E5_DATA,5,2)+'/'+SubStr(QRY1->E5_DATA,1,4) + Space(01)
		cCampos += Transform(QRY1->E5_VALOR,'@E 99,999,999.99') + Space(01)
		cCampos += QRY1->E5_BANCO + Space(01)
		cCampos += QRY1->E5_MOTBX + Chr(13) + Chr(10)
		Fwrite(nHandle,cCampos)
		li++
		// quebra de página
		If li > 56
			u_Pag031(_cTitulo,_cDesc1,_cDesc2,nHandle,cWorkFlow)
			Fwrite(nHandle,cCampos)
			li++
		EndIf

		// Gera totais com base no tipo de documento (NF / NCC)		
		If AllTrim(QRY1->E5_TIPO) == 'NF'
			_nTotBax += QRY1->E5_VALOR
		Else
			_nTotBax -= QRY1->E5_VALOR
		EndIf

		QRY1->(DbSkip())
	EndIf	
EndDo
If !Empty(_nTotBax)
	// quebra de página
	If li > 56
		u_Pag031(_cTitulo,_cDesc1,_cDesc2,nHandle,cWorkFlow)
		Fwrite(nHandle,cCampos)
		li++
	EndIf

	// Bloco de impressõa da linha de TOTAL
	If cWorkFlow == "N"		
		@ li,000 Psay Replicate('-',limite)
		li++	
		@ li,000 PSay "Total das Baixas de " + Substr(DTOC(MV_PAR02),1,2) + " a " +  DTOC(MV_PAR03) + " =>"
		@ li,040 PSay _nTotBax PICTURE '@E 99,999,999.99'
		li++
		@ li,000 Psay Replicate('-',limite)
	Else
		cCampos :=  Replicate('-',limite) + Chr(13) + Chr(10)
		Fwrite(nHandle,cCampos)
		li++	
		// quebra de página
		If li > 56
			u_Pag031(_cTitulo,_cDesc1,_cDesc2,nHandle,cWorkFlow)
			Fwrite(nHandle,cCampos)
			li++
		EndIf
		cCampos :=  "Total das Baixas de " + Substr(DTOC(MV_PAR02),1,2) + " a " +  DTOC(MV_PAR03) + " =>"
		cCampos +=  Space(03) + Transform(_nTotBax,'@E 99,999,999.99') + Chr(13) + Chr(10)
		Fwrite(nHandle,cCampos)
		li++
		// quebra de página
		If li > 56
			u_Pag031(_cTitulo,_cDesc1,_cDesc2,nHandle,cWorkFlow)
			Fwrite(nHandle,cCampos)
			li++
		EndIf
		cCampos :=  Replicate('-',limite) + Chr(13) + Chr(10)
		Fwrite(nHandle,cCampos)
		Fclose(nHandle)
	EndIf
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

AADD(aRegs,{cPerg,"01","Qual vendedor      ?","","","mv_ch1","C",6,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","",'SA3'})
aAdd(aRegs,{cPerg,"02","Baixa de           ?","","","mv_ch2","D",8,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"03","Baixa ate          ?","","","mv_ch3","D",8,0,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"04","Grupo Clientes     ?","","","mv_ch4","C",6,0,0,"G","","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","",'ACY'})

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

User Function Pag031(_cTitulo,_cDesc1,_cDesc2,nHandle,cWorkFlow)
	li := U_MYCABEC(_cTitulo,_cDesc1,_cDesc2,nHandle,cWorkFlow)
	If cWorkFlow == "N"	
		@ li,000 PSay _cNomVen
		li++
	Else
		cCampos := Chr(13) + Chr(10) + _cNomVen + Chr(13) + Chr(10)
		li++
	EndIf
Return
///////////////////////////////////////////////////////////////////////////

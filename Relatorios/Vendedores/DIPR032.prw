/*================================================================================\
|Programa  | DIPR032   | Autor | Rafael de Campos Falco    | Data | 06/11/2003    |
|=================================================================================|
|Desc.     | Relat�rio de Comiss�es - Por Vendedor                                |
|=================================================================================|
|Sintaxe   | DIPR032                                                              |
|=================================================================================|
|Uso       | Especifico DIPROMED                                                  |
|=================================================================================|
|Hist�rico |   /  /   -                                                           |
|Daniel    | 01/11/07 -Adicionado Filtro de Vendedor e Grupo de Clientes          | 
|Maximo    | 15/10/09 - Alterado o caminho do arquivo e PREPARE ENVIRONMENT       | 
\================================================================================*/

#Include "RwMake.ch"
#INCLUDE "TBICONN.CH"
#INCLUDE "FILEIO.CH"

User Function DIPR032(aWork)
Local _xArea      := GetArea()
Local titulo      := OemTOAnsi("Relat�rio de Comiss�es por vendedor",72)
Local cDesc1      := (OemToAnsi("Este programa tem como objetivo emitir um relat�rio",72))
Local cDesc2      := (OemToAnsi("com a posicao das comiss�es por vendedor.",72))
Local cDesc3      := (OemToAnsi("Conforme parametros definidos pelo o usuario.",72))
Local _nPos			:= 1
Local _aFeriad		:= {}
Private aPar2		:= ""
Private aReturn    := {"Bco A4", 1,"Administracao", 1, 2, 1,"",1}
Private li         := 67
Private tamanho    := "P"
Private limite     := 80
Private nomeprog   := "DIPR032"

// Private cPerg      := "DIPR32"
// FPADR(cPerg, cArq, cCampo, cTipo)  - Para ajustar o tamanho das perguntas no SX1 - uso generico
PRIVATE cPerg  	

Private nLastKey   := 0
Private lEnd       := .F.
Private wnrel      := "DIPR032"
Private cString    := "SE3"
Private m_pag      := 1
Private cWorkFlow  := ""  
Private cWCodEmp  := ""  
Private cWCodFil  := "" 
Private _dDatIni   := ""
Private _dDatFim   := ""
//Tratamento para workflow
If ValType(aWork) <> 'A'
	cWorkFlow := "N"    
	cWCodEmp  := cEmpAnt
    cWCodFil  := cFilAnt 
	cPerg  	:= U_FPADR( "DIPR32","SX1","SX1->X1_GRUPO"," " ) //Fun��o criada por Sandro em 19/11/09.
    U_DIPPROC(ProcName(0),U_DipUsr()) // JBS 13/12/2005 - Gravando o nome do Programa no SZU
Else
	cWorkFlow := aWork[1]    
	cWCodEmp  := aWork[3]
    cWCodFil  := aWork[4]
EndIf

If cWorkFlow == "S"                                                                               
	PREPARE ENVIRONMENT EMPRESA cWCodEmp FILIAL cWCodFil FUNNAME "DIPR032" TABLES "SA3"
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
	| Se em disco, desvia para Spool                                            |
	\==========================================================================*/
	If aReturn[5] == 1    // Se Saida para disco, ativa SPOOL
		Set Printer TO
		Commit
		ourspool(wnrel)
	Endif
	
	
Else

	/*==========================================================================\
	| Este relat�rio executado via WORKFLOW, dever� usar as datas MV_PAR02 e    |
	| MV_PAR03. A data INICIAL dever� ser calculada da seguinte forma, a data   |
	| atual do sistema DDATABASE(), dever� verificar se a data � o 3o. dia �til |
	| ou menor que ele se sim dever� voltar para o dia 01 do m�s anterior e o   |
	| �timo dia do m�s anterior. Caso a data esteja no 4o. �til em diante dever�|
	| usar o m�s atual come�ando pelo dia 1o. at� o �ltimo d�a do m�s atual     |
	|                                                                           |
	\==========================================================================*/

	// Montagem do array com feriados
	dbSelectArea("SX5")
	dbSetOrder(1)
	dbSeek(xFilial("SX5")+"63")
	While X5_TABELA == "63"
		If SubStr(X5_DESCRI,1,1) != "*" .and. Val(SubStr(X5_DESCRI,7,2)) < 80 // Condi��o para pegar campos somente com datas e com ano de 2000 em diante
			// Monta data extra�da do campo X5_DESCRI
			cTemp := Iif(Empty(SubStr(X5_DESCRI,7,2)),CtoD(SubStr(X5_DESCRI,1,2)+"/"+SubStr(X5_DESCRI,4,2)+"/"+"20"+AllTrim(Str(Year(Date())))),CtoD(SubStr(X5_DESCRI,1,2)+"/"+SubStr(X5_DESCRI,4,2)+"/"+"20"+SubStr(X5_DESCRI,7,2)))
			Aadd(_aFeriad,{cTOD(AllTrim(cTemp))})
		EndIf
		SX5->(DbSkip())
	EndDo
	
/*	// Verifica��o da data se o dia � feriado, se sim voltar (-1) dia
	_nPos := Ascan(_aFeriad,{|y| y[1] == dDatSis}) // Verifica se data � um Feriado
	If _nPos == 0 	// Se a data for um feriado despreza o dia
		dDatSis := dDatSis-1	
	EndIf

	// Verifica��o da data se o dia � domingo, se sim voltar (-1) dia
	If (AllTrim(cDow(dDatSis)) == "Sunday")// Descarta qdo. for Domingo
		dDatSis := dDatSis-1	
	EndIf

	// Verifica��o da data se o dia � s�bado, se sim voltar (-1) dia
	If (AllTrim(cDow(dDatSis)) == "Saturday") // Descarta qdo. for S�bado
		dDatSis := dDatSis-1	
	EndIf*/
	     

	/*==========================================================================\
	| No bloco seguinte � feita a identifica��o do 3o. dia �til do m�s atual    |
	|                                                                           |
	\==========================================================================*/

  	// Data do DIA atual
	nConta := 0
	nDia_Uti:= 0
	dDatSis := Date()
	dDatUti := FirstDay(dDatSis)
	
	// Verifica se data do dia �til � um feriado ou ponte  MCVN - 04/09/2007
	While nConta < 8 // Quantidade de DIAS ut�is considerando que os relat�rios s�o enviados na madrugada do dia seguinte MCVN - 04/09/2007
		_nPos := Ascan(_aFeriad,{|y| y[1] == dDatUti}) // Verifica se data � um Feriado
		If _nPos != 0 	// Se a data for um feriado despreza o dia
			nDia_Uti++
		Else
			// verifica se data do dia �til � um s�bado ou domingo
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
	
	// Verifica��o se est� entre o 1o. e 3o. dia �til para voltar para o m�s anterior
   If val(substr(dtos(dDatSis),7,2)) > nDia_Uti
   		_dDatIni := FirstDay(dDatSis)	// Primeiro dia
		_dDatFim := LastDay (dDatSis)	// �ltimo Dia
	Else   
		_dDatIni := FirstDay(dDatSis)-10 // volta para o m�s anterior			
   		_dDatIni := FirstDay(_dDatIni)	// Primeiro dia
		_dDatFim := LastDay (_dDatIni)	// �ltimo Dia
	EndIf

	// Par�metros do vendedor
	MV_PAR01 := aWork[2]
	MV_PAR02 := _dDatIni
	MV_PAR03 := _dDatFim
	MV_PAR04 := ""

	If Empty( Posicione("SA3",1,xFilial("SA3")+MV_PAR01,"A3_DESLIG") )
		ConOut(' ')
	    ConOut('Relat�rio de Comiss�es - Vendedor ' + MV_PAR01 + ' Inicio em '+dToc(date())+' as '+Time())
		ConOut(' ')
	
		RodaRel()
	
		ConOut(' ')
	    ConOut('Relat�rio de Comiss�es - Vendedor ' + MV_PAR01 + ' Concluido em '+dToc(date())+' as '+Time())
		ConOut(' ')
	EndIf
Endif

RestArea(_xArea)

Return

//////////////////////////////////////////////////////////////////////
Static Function RodaRel()
Local nTotTit		:= 0
Local nTotBas		:= 0
Local nTotCom		:= 0
Local cArq			:= ""
Local cCampos		:= ""
Local nHandle		:= ""
Private _cTitulo	:= ""
Private _cDesc1	:= "" 
Private _cDesc2	:= ""
Private cNomVen	:= ""

// Localiza vendedor informado
If !Empty(MV_PAR01)
	DbSelectArea("SA3")
	DbSetOrder(1)
	If DbSeek(xFilial("SA3")+MV_PAR01)
		cNomVen  := 'Vendedor.: ' + MV_PAR01 + ' - ' + AllTrim(SA3->A3_NOME) + " - Per�odo: " + Substr(DtoS(MV_PAR02),7,2) + " at� " + Substr(DtoS(MV_PAR03),7,2) +"/"+ Substr(DtoS(MV_PAR03),5,2)+"/"+ Substr(DtoS(MV_PAR03),1,4)
	Else
		cNomVen  := 'vendedor nao cadastrado'
	EndIf
Else
	cNomVen  := 'Todos vendedores'	
EndIf

/* Seleciona as comiss�es do vendedor informado

SELECT E3_PREFIXO, E3_NUM, E3_PARCELA, E3_CODCLI, E3_LOJA, E1_NOMCLI, E1_VENCTO, E3_EMISSAO, E3_PEDIDO, E1_VALOR, E3_BASE, E3_PORC, E3_COMIS, E3_BAIEMI
FROM SE3010, SE1010
WHERE E3_VEND = '000190'
AND E3_EMISSAO BETWEEN '20031001' AND '20031031'
AND E3_NUM = E1_NUM
AND E3_PREFIXO = E1_PREFIXO
AND E3_PARCELA = E1_PARCELA
AND SE3010.D_E_L_E_T_ <> '*'
ORDER BY E3_EMISSAO, E3_NUM

*/

QRY1 := " SELECT E3_PREFIXO, E3_NUM, E3_PARCELA, E1_NOMCLI,E3_CODCLI, E3_LOJA, E1_VENCTO, E3_EMISSAO, E3_PEDIDO, E1_VALOR, E3_BASE, E3_PORC, E3_COMIS, E3_BAIEMI"
QRY1 += " FROM " + RetSQLName("SE3")+', '+ RetSQLName("SE1")+', '+ RetSQLName("SA1")
QRY1 += " WHERE E3_VENCTO BETWEEN '" + DtoS(MV_PAR02) + "' AND '" + DtoS(MV_PAR03) + "'"
QRY1 += " AND E3_VEND = '" + MV_PAR01 + "'"
QRY1 += " AND E3_NUM = E1_NUM "
QRY1 += " AND E3_PREFIXO = E1_PREFIXO "
QRY1 += " AND E3_PARCELA = E1_PARCELA "
// MCVN - 08/03/2010
QRY1 += " AND E1_FILIAL = '"+xFilial("SE1")+"'" 
QRY1 += " AND E3_FILIAL = '"+xFilial("SE3")+"'"
 
QRY1 += " AND A1_FILIAL = '"+xFilial("SA1")+"'"
QRY1 += " AND A1_COD = E1_CLIENTE"
QRY1 += " AND A1_LOJA = E1_LOJA"
If U_ListVend() != ''
	QRY1 += " AND E3_VEND " + U_ListVend()
EndIf        
If !Empty(MV_PAR04)
	QRY1 += " AND A1_GRPVEN = '"+MV_PAR04+"'"	
EndIf
QRY1 += " AND " + RetSQLName("SE3")+ ".D_E_L_E_T_ <> '*'"
QRY1 += " AND " + RetSQLName("SE1")+ ".D_E_L_E_T_ <> '*'"
QRY1 += " AND " + RetSQLName("SA1")+ ".D_E_L_E_T_ <> '*'"
QRY1 += " ORDER BY E3_EMISSAO, E3_NUM"

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

// Par�metros de montagem do cabe�alho
_cTitulo := "Relat�rio de Comiss�es por vendedor"
_cDesc1  := "C�digo Lj Cliente                                              Dt.Venc. Dt.Baixa" 
_cDesc2  := "Prf N�mero P Pedido            Valor           Base     Porc.     Comiss�o     T"

//Monta o nome do arquivo caso seja WORKFLOW
If cWorkFlow == "S"     
	If ("0401" $ cWCodEmp+cWCodFil)
		cArq := "/VENDEDORES/HQ/" + MV_PAR01 + Substr(Dtoc(Date()),1,2) + Substr(Dtoc(Date()),4,2) + ".032"
	ElseIf ("0404" $ cWCodEmp+cWCodFil)
		cArq := "/VENDEDORES/HQ-CD/" + MV_PAR01 + Substr(Dtoc(Date()),1,2) + Substr(Dtoc(Date()),4,2) + ".032"	                                                                                                       	
	ElseIf ("0101" $ cWCodEmp+cWCodFil)                                                                  
		cArq := "/VENDEDORES/DIPROMED-MTZ/"+MV_PAR01 + Substr(Dtoc(Date()),1,2) + Substr(Dtoc(Date()),4,2) + ".032"			
	Else                                                                                                        
		cArq := "/VENDEDORES/DIPROMED/" + MV_PAR01 + Substr(Dtoc(Date()),1,2) + Substr(Dtoc(Date()),4,2) + ".032"
	Endif
	cCampos		:= ""
	nHandle		:= Fcreate(cArq,0)

Else
	SetRegua(RecCount())
EndIf

	*         1         2         3         4         5         6         7         8         9         0         1         2         3         4         5         6         7         8         9         0
	*123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901
	*dipr032/v.AP6 6.09 Posicao de Titulos a Receber - analitico     Data.: 99/99/99
	*C�digo Lj Cliente                                              Dt.Venc. Dt.Baixa
	*Prf N�mero P Pedido            Valor           Base     Porc.     Comiss�o     T
	*999999 99 XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX 01/01/01 01/01/01 
	*999 999999 X 999999     9.999.999,99     999.999,99     99,99    99.999,99     X 
	*Valores Acumulados 7     9,999,999.99     999,999.99     99,99    99.999,99 

Do While QRY1->(!Eof())

	If cWorkFlow == "N" // SE N�O FOR WORKFLOW
		
		If lAbortPrint
			@ li+1,00 PSAY "*** CANCELADO PELO OPERADOR ***"
			Exit
		Endif
		
		IncRegua( "Imprimindo... " + QRY1->E3_NUM)
		
		If li > 60
			li := u_MYCabec(_cTitulo,_cDesc1,_cDesc2,nHandle,cWorkFlow)
			@ li,000 PSay cNomVen
			li+=2
			@ li,000 PSay Replic("-",Limite)
		EndIf	

		@ li,000 PSay QRY1->E3_CODCLI
		@ li,007 PSay QRY1->E3_LOJA
		@ li,010 PSay SubStr(QRY1->E1_NOMCLI,1,51)
		@ li,063 PSay Substr(QRY1->E1_VENCTO,7,2)+"/"+Substr(QRY1->E1_VENCTO,5,2)+"/"+Substr(QRY1->E1_VENCTO,3,2)
		@ li,072 PSay Substr(QRY1->E3_EMISSAO,7,2)+"/"+Substr(QRY1->E3_EMISSAO,5,2)+"/"+Substr(QRY1->E3_EMISSAO,3,2)
		li++
		@ li,000 PSay QRY1->E3_PREFIXO
		@ li,004 PSay QRY1->E3_NUM
		@ li,011 PSay QRY1->E3_PARCELA
		@ li,013 PSay QRY1->E3_PEDIDO
		@ li,024 PSay QRY1->E1_VALOR picture "@E 9,999,999.99"
		@ li,041 PSay QRY1->E3_BASE  picture   "@E 999,999.99"
		@ li,056 PSay QRY1->E3_PORC  picture        "@E 99.99"
		@ li,066 PSay QRY1->E3_COMIS picture     "@E 99,999.99"
		@ li,079 PSay QRY1->E3_BAIEMI
		li++
		@ li,000 PSay Replic("-",Limite)
		li++	

		nTotTit += QRY1->E1_VALOR
		nTotBas += QRY1->E3_BASE
		nTotCom += QRY1->E3_COMIS
		QRY1->(DbSkip())
		
	Else	// CASO SEJA WORKFLOW

		/*----------------------------- A T E N � � O ------------------------------------	
		Para correta impress�o do relat�rio verificar as seguintes configura��es de 
		impress�o no bloco de notas (NotePad):
		Fonte Courier - Normal - 10
		Papel Carta 21,59 X 27,94cm
		Margens: Direita 20 , Esquerda 20 , Superior 25 e Inferior 20
		---------------------------------------------------------------------------------*/	
		
		If li > 60
			li := u_MYCabec(_cTitulo,_cDesc1,_cDesc2,nHandle,cWorkFlow)
			cCampos := Chr(13) + Chr(10) + cNomVen + Chr(13) + Chr(10) + Chr(13) + Chr(10)
			cCampos += Replic("-",Limite) + Chr(13) + Chr(10)
			Fwrite(nHandle,cCampos)
			li+=2
		EndIf	

		cCampos := QRY1->E3_CODCLI
		cCampos += Space(01) + QRY1->E3_LOJA
		cCampos += Space(01) + SubStr(QRY1->E1_NOMCLI,1,51)
		cCampos += Space(02) + Substr(QRY1->E1_VENCTO,7,2)+"/"+Substr(QRY1->E1_VENCTO,5,2)+"/"+Substr(QRY1->E1_VENCTO,3,2)
		cCampos += Space(01) + Substr(QRY1->E3_EMISSAO,7,2)+"/"+Substr(QRY1->E3_EMISSAO,5,2)+"/"+Substr(QRY1->E3_EMISSAO,3,2) + Chr(13) + Chr(10)
		Fwrite(nHandle,cCampos)
		li++
		cCampos := QRY1->E3_PREFIXO
		cCampos += Space(01) + QRY1->E3_NUM
		cCampos += Space(01) + QRY1->E3_PARCELA
		cCampos += Space(01) + QRY1->E3_PEDIDO
		cCampos += Space(05) + Transform(QRY1->E1_VALOR,"@E 9,999,999.99")
		cCampos += Space(05) + Transform(QRY1->E3_BASE ,  "@E 999,999.99")
		cCampos += Space(05) + Transform(QRY1->E3_PORC ,       "@E 99.99")
		cCampos += Space(04) + Transform(QRY1->E3_COMIS,    "@E 99,999.99")
		cCampos += Space(05) + QRY1->E3_BAIEMI + Chr(13) + Chr(10)
		Fwrite(nHandle,cCampos)
		li++
		cCampos := Replic("-",Limite) + Chr(13) + Chr(10)
		Fwrite(nHandle,cCampos)
		li++
		
		nTotTit += QRY1->E1_VALOR
		nTotBas += QRY1->E3_BASE
		nTotCom += QRY1->E3_COMIS
		
		QRY1->(DbSkip())
	EndIf
EndDo
If !Empty(nTotTit)
	// Impress�o da linha de totais
	If cWorkFlow == "N" // SE N�O FOR WORKFLOW
		@ li,000 PSay Replic("*",Limite)
		li++
		@ li,000 PSay "Valores Acumulados"
		@ li,024 PSay nTotTit picture "@E 9,999,999.99"
		@ li,041 PSay nTotBas picture   "@E 999,999.99"
		@ li,056 PSay (nTotCom/nTotBas)*100 picture "@E 99.99"
		@ li,065 PSay nTotCom picture "@E 99,999.99"
		li++
		@ li,000 PSay Replic("*",Limite)
		li++
	Else
		cCampos := Replic("*",Limite) + Chr(13) + Chr(10)
		Fwrite(nHandle,cCampos)
		li++
		cCampos := "Valores Acumulados"
		cCampos += Space(06) + Transform(nTotTit,"@E 9,999,999.99")
		cCampos += Space(05) + Transform(nTotBas ,  "@E 999,999.99")
		cCampos += Space(05) + Transform( (nTotCom/nTotBas)*100,"@E 99.99")
		cCampos += Space(04) + Transform(nTotCom,    "@E 99,999.99") + Chr(13) + Chr(10)
		cCampos += Replic("*",Limite) + Chr(13) + Chr(10)
		Fwrite(nHandle,cCampos)
		li+=2
	EndIf
	
	If cWorkFlow == "N"
		If li > 60
			li := u_MYCabec(_cTitulo,_cDesc1,_cDesc2,nHandle,cWorkFlow)
			@ li,000 PSay cNomVen
			li+=2
			@ li,000 PSay Replic("-",Limite)
		EndIf	
		If li <> 80
			@ 062,000 PSAY 'Impresso em '+DtoC(DATE())+' as '+TIME()
		EndIf
	Else
		If li > 60
			li := u_MYCabec(_cTitulo,_cDesc1,_cDesc2,nHandle,cWorkFlow)
			cCampos := Chr(13) + Chr(10) + cNomVen + Chr(13) + Chr(10) + Chr(13) + Chr(10)
			cCampos += Replic("-",Limite) + Chr(13) + Chr(10)
			Fwrite(nHandle,cCampos)
			li+=2
		EndIf	
		If li <> 80
			cCampos := chr(13) + chr(10) + Space(Limite-(Len('Impresso em '+DtoC(DATE())+' �s '+TIME())))
			cCampos += 'Impresso em '+DtoC(DATE())+' �s '+TIME() + chr(13) + chr(10)
			Fwrite(nHandle,cCampos)
			cCampos := "Padr�es de impress�o p/ bloco de notas (NotePad):" + chr(13) + chr(10)
			cCampos += "Fonte Courier - Normal - 10 " + chr(13) + chr(10)
			cCampos += "Papel Carta 21,59 X 27,94cm " + chr(13) + chr(10)
			cCampos += "Margens: Direita 20 , Esquerda 20 , Superior 25 e Inferior 20"
			Fwrite(nHandle,cCampos)
			cCampos := ""
		EndIf
		Fclose(nHandle)
		
	EndIf
EndIf
	
dbSelectArea("QRY1")
QRY1->(dbCloseArea())
Return(.T.)

/*==========================================================================\
|Programa  |VALIDPERG| Autor | Rafael de Campos Falco  | Data � 04/06/2004  |
|===========================================================================|
|Desc.     | Inclui as perguntas caso nao existam                           |
|===========================================================================|
|Sintaxe   | VALIDPERG                                                      |
|===========================================================================|
|Uso       | Especifico DIPROMED                                            |
|===========================================================================|
|Hist�rico | DD/MM/AA - Descri��o da altera��o                              |
\==========================================================================*/

Static Function AjustaSX1(cPerg)
_sAlias := Alias()
dbSelectArea("SX1")
dbSetOrder(1)                                                                                   

aRegs:={}

//------------ Grupo/Ordem/Pergunta/PERGING/PERGESP/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05/F3

AADD(aRegs,{cPerg,"01","De vendedor        ?","","","mv_ch1","C",06,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","",'SA3'})
aAdd(aRegs,{cPerg,"02","Da Data            ?","","","mv_ch2","D",08,0,0,"G","","mv_par02","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"03","Ate a Data         ?","","","mv_ch3","D",08,0,0,"G","","mv_par03","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"04","Grupo Clientes     ?","","","mv_ch4","C",06,0,0,"G","","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","",'ACY'})

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
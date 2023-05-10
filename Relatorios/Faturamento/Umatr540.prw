#INCLUDE "UMATR540.CH"
#INCLUDE "FIVEWIN.CH"


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ MATR540  ³ Autor ³ Claudinei M. Benzi       ³ Data ³ 13.04.92 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Relatorio de Comissoes.                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ MATR540(void)                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±± 
±±ÚÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ DATA   ³ BOPS ³Programad.³ALTERACAO                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³05.02.03³XXXXXX³Eduardo Ju³Inclusao de Queries para filtros em TOPCONNECT.³±±
±±ÀÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
User Function uMatr540()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local wnrel
Local titulo    := STR0001  //"Relatorio de Comissoes"
Local cDesc1    := STR0002  //"Emissao do relatorio de Comissoes."
Local tamanho   := "G"
Local limite    := 220
Local cString   := "SE3"
Local cAliasAnt := Alias()
Local cOrdemAnt := IndexOrd()
Local nRegAnt   := Recno()
Local cDescVend := " "

Private aReturn := { OemToAnsi(STR0003), 1,OemToAnsi(STR0004), 1, 2, 1, "",1 }  //"Zebrado"###"Administracao"
Private nomeprog:= "UMATR540"
Private aLinha  := { },nLastKey := 0

//Private cPerg   := "MTR540"   
// FPADR(cPerg, cArq, cCampo, cTipo)  - Para ajustar o tamanho das perguntas no SX1- uso generico
PRIVATE cPerg  	:= U_FPADR( "MTR540","SX1","SX1->X1_GRUPO"," " ) //Função criada por Sandro em 19/11/09.
Private nSetor  := 3  
MV_PAR16 := 3   
U_DIPPROC(ProcName(0),U_DipUsr()) //MCVN - 22/01/2009

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica as perguntas selecionadas                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

//AjustaSX1(cPerg)

Pergunte(cPerg,.F.)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros                         ³
//³ mv_par01        	// Pela <E>missao,<B>aixa ou <A>mbos        ³
//³ mv_par02        	// A partir da data                         ³
//³ mv_par03        	// Ate a Data                               ³
//³ mv_par04 	    	// Do Vendedor                              ³
//³ mv_par05	     	// Ao Vendedor                              ³
//³ mv_par06	     	// Quais (a Pagar/Pagas/Ambamvs)              ³
//³ mv_par07	     	// Incluir Devolucao ?                      ³
//³ mv_par08	     	// Qual moeda                               ³
//³ mv_par09	     	// Comissao Zerada ?                        ³
//³ mv_par10	     	// Abate IR Comiss                          ³
//³ mv_par11	     	// Quebra pag.p/Vendedor                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Envia controle para a funcao SETPRINT                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	  //Giovani Zago 13/03/2012 filtro para os vendedores.
		If alltrim(Posicione("SU7",4,xFilial("SU7") + RetCodUsr(),"U7_CGC")) $ GetMv("ES_VENDUSE",,"000053" )
			mv_par04 := alltrim(Posicione("SU7",4,xFilial("SU7") + RetCodUsr(),"U7_CGC"))
			mv_par05 := mv_par04
		EndIf



wnrel := "UMATR540"
wnrel := SetPrint(cString,wnrel,cPerg,titulo,cDesc1,"","",.F.,"",.F.,Tamanho)

If nLastKey==27
	dbClearFilter()
	Return
Endif
SetDefault(aReturn,cString)
If nLastKey ==27
	dbClearFilter()
	Return
Endif

RptStatus({|lEnd| C540Imp(@lEnd,wnRel,cString)},Titulo)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Retorna para area anterior, indice anterior e registro ant.  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea(caliasAnt)
DbSetOrder(cOrdemAnt)
DbGoto(nRegAnt)
Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ C540IMP  ³ Autor ³ Rosane Luciane Chene  ³ Data ³ 09.11.95 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Chamada do Relatorio                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATR540			                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function C540Imp(lEnd,WnRel,cString)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local CbCont,cabec1,cabec2
Local tamanho  := "G"
Local limite   := 220
Local nomeprog := "UMATR540"
Local imprime  := .T.
Local cPict    := ""
Local cTexto,j :=0,nTipo:=0
Local cCodAnt,nCol:=0
Local nAc1:=0,nAc2:=0,nAg1:=0,nAg2:=0,nAc3:=0,nAg3:=0,lFirstV:=.T.
Local nTregs,nMult,nAnt,nAtu,nCnt,cSav20,cSav7
Local lContinua:= .T.
Local cNFiscal :=""
Local aCampos  :={}
Local lImpDev  := .F.
Local cBase    := ""
Local cNomArq, cCondicao, cFilialSE1, cFilialSE3, cChave, cFiltroUsu
Local nDecs    := GetMv("MV_CENT"+(IIF(mv_par08 > 1 , STR(mv_par08,1),"")))
Local	nBasePrt :=0, nComPrt:=0 
Local aStru    := SE3->(dbStruct()), ni  
Private _cQuer1 := "" 
Private nMarNe  := 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para Impressao do Cabecalho e Rodape    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cbtxt    := Space(10)
cbcont   := 00
li       := 80
m_pag    := 01
imprime  := .T.

nTipo := IIF(aReturn[4]==1,15,18)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Definicao dos cabecalhos                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If mv_par01 == 1
	titulo := OemToAnsi(STR0005)+OemToAnsi(STR0006)+ " - " + GetMv("MV_MOEDA" + STR(mv_par08,1)) //"RELATORIO DE COMISSOES "###"(PGTO PELA EMISSAO)"
Elseif mv_par01 == 2
	titulo := OemToAnsi(STR0005)+OemToAnsi(STR0007)+ " - " + GetMv("MV_MOEDA" + STR(mv_par08,1))  //"RELATORIO DE COMISSOES "###"(PGTO PELA BAIXA)"
Else
	titulo := OemToAnsi(STR0008)+ " - " + GetMv("MV_MOEDA" + STR(mv_par08,1))  //"RELATORIO DE COMISSOES"
Endif

titulo += " - De "+DtoC(mv_par02)+" Ate "+DtoC(mv_par03) // JBS 26/04/2006 12:15

cabec1:=OemToAnsi(STR0009)	//"PRF NUMERO   PARC. CODIGO DO              LJ  NOME                                 DATA DE     DATA        DATA        DATA       NUMERO          VALOR           VALOR      %           VALOR    TIPO"
cabec2:=OemToAnsi(STR0010)	//"    TITULO         CLIENTE                                                         EMISSAO     VENCTO      BAIXA       PAGTO      PEDIDO         TITULO            BASE               COMISSAO   COMISSAO"
									// XXX XXXXXXxxxxxx X XXXXXXxxxxxxxxxxxxxx   XX  012345678901234567890123456789012345 XX/XX/XXxx  XX/XX/XXxx  XX/XX/XXxx  XX/XX/XXxx XXXXXX 12345678901,23  12345678901,23  99.99  12345678901,23     X       AJUSTE
									// 0         1         2         3         4         5         6         7         8         9         10        11        12        13        14        15        16        17        18        19        20        21
									// 0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta condicao para filtro do arquivo de trabalho            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

DbSelectArea("SE3")	// Posiciona no arquivo de comissoes
DbSetOrder(2)			// Por Vendedor
cFilialSE3 := xFilial("SE3")
cNomArq :=CriaTrab("",.F.)

cCondicao := "SE3->E3_FILIAL=='" + cFilialSE3 + "'"
cCondicao += ".And.SE3->E3_VEND>='" + mv_par04 + "'"
cCondicao += ".And.SE3->E3_VEND<='" + mv_par05 + "'"
cCondicao += ".And.DtoS(SE3->E3_EMISSAO)>='" + DtoS(mv_par02) + "'"
cCondicao += ".And.DtoS(SE3->E3_EMISSAO)<='" + DtoS(mv_par03) + "'" 

If mv_par01 == 1
	cCondicao += ".And.SE3->E3_BAIEMI!='B'"  // Baseado pela emissao da NF
Elseif mv_par01 == 2
	cCondicao += " .And.SE3->E3_BAIEMI=='B'"  // Baseado pela baixa do titulo
Endif 

If mv_par06 == 1 		// Comissoes a pagar
	cCondicao += ".And.Dtos(SE3->E3_DATA)=='"+Dtos(Ctod(""))+"'"
ElseIf mv_par06 == 2 // Comissoes pagas
	cCondicao += ".And.Dtos(SE3->E3_DATA)!='"+Dtos(Ctod(""))+"'"
Endif

If mv_par09 == 2 		// Nao Inclui Comissoes Zeradas
   cCondicao += ".And.SE3->E3_COMIS<>0"
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria expressao de filtro do usuario                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ( ! Empty(aReturn[7]) )
	cFiltroUsu := &("{ || " + aReturn[7] +  " }")
Else
	cFiltroUsu := { || .t. }
Endif

nAg1 := nAg2 := 0

#IFDEF TOP
	If TcSrvType() != "AS/400"
		cOrder := SqlOrder(SE3->(IndexKey()))
		
		cQuery := "SELECT * "
		cQuery += "  FROM "+	RetSqlName("SE3") +", "+RetSqlName("SA1")+", "+RetSqlName("SA3")
		cQuery += " WHERE E3_FILIAL = '" + xFilial("SE3") + "' AND "
	  	cQuery += "	E3_VEND >= '"  + mv_par04 + "' AND E3_VEND <= '"  + mv_par05 + "' AND " 
		cQuery += "	E3_EMISSAO >= '" + Dtos(mv_par02) + "' AND E3_EMISSAO <= '"  + Dtos(mv_par03) + "' AND " 		
		If mv_par01 == 1
			cQuery += "E3_BAIEMI <> 'B' AND "  //Baseado pela emissao da NF
		Elseif mv_par01 == 2
			cQuery += "E3_BAIEMI =  'B' AND "  //Baseado pela baixa do titulo  
		EndIf	
		
		If mv_par06 == 1 		//Comissoes a pagar
			cQuery += "E3_DATA = '" + Dtos(Ctod("")) + "' AND "
		ElseIf mv_par06 == 2 //Comissoes pagas
  			cQuery += "E3_DATA <> '" + Dtos(Ctod("")) + "' AND "
		Endif 
		
		If mv_par09 == 2 		//Nao Inclui Comissoes Zeradas
	   		cQuery+= "E3_COMIS <> 0 AND "
		EndIf  
		
		cQuery += " "+RetSqlName("SA3")+".D_E_L_E_T_ = ' ' AND " 
		cQuery += " A3_COD = E3_VEND AND "
		If !Empty(MV_PAR16) .And. MV_PAR16 <> 3  // Filtra por Setor  MCVN - 04/12/2007
			If MV_PAR16 == 1 // REPRESENTANTE
				cQuery += " A3_TIPVEND <> '2' AND "
			ElseIf MV_PAR16 == 2 // FUNCIONARIO  
				cQuery += " A3_TIPVEND = '2' AND "
			EndIf
		Endif		

		cQuery += " A1_FILIAL = '"+ xFilial("SA1") + "' AND "
		cQuery += " A1_COD = E3_CODCLI AND "
		cQuery += " A1_LOJA = E3_LOJA AND "
		cQuery += " "+RetSqlName("SA1")+".D_E_L_E_T_ = ' ' AND "     
		If U_ListVend() != ""
			cQuery += " E3_VEND "+U_ListVend()+" AND "   
		EndIf
		//Giovani Zago 06/12/11 
		
			cQuery += " E3_CODCLI BETWEEN '"+mv_par17+"'AND '"+mv_par18+"' AND "  //Filtra cliente 
		   //*********************************************************
		
		If !Empty(mv_par19)
			cQuery += " A1_GRPVEN = '"+mv_par19+"' AND "   
		EndIf
		cQuery += " "+RetSqlName("SE3")+".D_E_L_E_T_ = ' ' "   

		cQuery += " ORDER BY "+ cOrder

		cQuery := ChangeQuery(cQuery)
											
		dbSelectArea("SE3")
		dbCloseArea()
		dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'SE3', .F., .T.)
			
		For ni := 1 to Len(aStru)
			If aStru[ni,2] != 'C'
				TCSetField('SE3', aStru[ni,1], aStru[ni,2],aStru[ni,3],aStru[ni,4])
			Endif
		Next 
	Else
	
#ENDIF	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Cria arquivo de trabalho                                     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cChave := IndexKey()
		cNomArq :=CriaTrab("",.F.)
		IndRegua("SE3",cNomArq,cChave,,cCondicao, OemToAnsi(STR0016)) //"Selecionando Registros..."
		nIndex := RetIndex("SE3")
		DbSelectArea("SE3") 
		#IFNDEF TOP
			DbSetIndex(cNomArq+OrdBagExT())
		#ENDIF
		DbSetOrder(nIndex+1)

#IFDEF TOP
	EndIf
#ENDIF
	
SC5->(dbSetOrder(1))  // JBS 26/04/2006 12:06
SetRegua(RecCount())  // Total de Elementos da regua 
SE3->(DbGotop())
While SE3->(!Eof())
	IF lEnd
		@Prow()+1,001 PSAY OemToAnsi(STR0011)  //"CANCELADO PELO OPERADOR"
		lContinua := .F.
		Exit
	EndIF
	IncRegua()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Processa condicao do filtro do usuario                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ! Eval(cFiltroUsu)
		Dbskip()
		Loop
	Endif
	
	nAc1   := nAc2 := nAc3 := 0
	lFirstV:= .T.
	cVend  := SE3->E3_VEND
	
	While SE3->(!Eof()) .AND. SE3->E3_VEND == cVend
		IncRegua()
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Processa condicao do filtro do usuario                       ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If ! Eval(cFiltroUsu)
			Dbskip()
			Loop
		Endif  
		
		If li > 55
			cabec(titulo,cabec1,cabec2,nomeprog,tamanho,nTipo)
		EndIF
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Seleciona o Codigo do Vendedor e Imprime o seu Nome          ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		IF lFirstV
			dbSelectArea("SA3")
			dbSeek(xFilial("SA3")+SE3->E3_VEND)
			cDescVend := SE3->E3_VEND + " " + A3_NOME 
			@li, 00 PSAY OemToAnsi(STR0012) + cDescVend //"Vendedor : "
			li+=2
			dbSelectArea("SE3")
			lFirstV := .F.
		EndIF
		
		@li, 00 PSAY SE3->E3_PREFIXO
		@li, 04 PSAY SE3->E3_NUM
		@li, 17 PSAY SE3->E3_PARCELA
		@li, 19 PSAY SE3->E3_CODCLI
		@li, 42 PSAY SE3->E3_LOJA
		
		dbSelectArea("SA1")
		dbSeek(xFilial("SA1")+SE3->E3_CODCLI+SE3->E3_LOJA)
		@li, 46 PSAY Substr(A1_NOME,1,35)
		
		dbSelectArea("SE3")
//		@li, 83 PSAY SE3->E3_EMISSAO
		
		dbSelectArea("SE1")
		dbSetOrder(1)
		dbSeek(xFilial("SE1")+SE3->E3_PREFIXO+SE3->E3_NUM+SE3->E3_PARCELA+SE3->E3_TIPO)
		nVlrTitulo := Round(xMoeda(SE1->E1_VALOR,SE1->E1_MOEDA,MV_PAR08,SE1->E1_EMISSAO,nDecs+1),nDecs)
		dVencto    := SE1->E1_VENCTO  

		@li, 83 PSAY SE1->E1_EMISSAO // JBS 01/08/2006
		
		/*
		Nas comissoes geradas por baixa pego a data da emissao da comissao que eh igual a data da baixa do titulo.
		Isto somente dara diferenca nas baixas parciais
		*/	 
		
      If SE3->E3_BAIEMI == "B"
			dBaixa     := SE3->E3_EMISSAO
    	Else
			dBaixa     := SE1->E1_BAIXA
		Endif
		
		If Eof()
			dbSelectArea("SF2")
			dbSetorder(1)
			dbSeek(xFilial("SF2")+SE3->E3_NUM+SE3->E3_PREFIXO) 
			nVlrTitulo := Round(xMoeda(F2_VALFAT,SF2->F2_MOEDA,mv_par08,SF2->F2_EMISSAO,nDecs+1,SF2->F2_TXMOEDA),nDecs)
			
			dVencto    := " "
			dBaixa     := " "
			
			If Eof()
				nVlrTitulo := 0
				dbSelectArea("SE1")
				dbSetOrder(1)
				cFilialSE1 := xFilial("SE1")
				dbSeek(cFilialSE1+SE3->E3_PREFIXO+SE3->E3_NUM)
				While ( !Eof() .And. SE3->E3_PREFIXO == SE1->E1_PREFIXO .And.;
						SE3->E3_NUM == SE1->E1_NUM .And.;
						SE3->E3_FILIAL == cFilialSE1 )
					If ( SE1->E1_TIPO == SE3->E3_TIPO  .And. ;
						SE1->E1_CLIENTE == SE3->E3_CODCLI .And. ;
						SE1->E1_LOJA == SE3->E3_LOJA )
						nVlrTitulo += Round(xMoeda(SE1->E1_VALOR,SE1->E1_MOEDA,MV_PAR08,SE1->E1_EMISSAO,nDecs+1),nDecs)
						dVencto    := " "
						dBaixa     := " "
					EndIf
					dbSelectArea("SE1")
					dbSkip()
				EndDo
			EndIf
		Endif

		//Preciso destes valores para pasar como parametro na funcao TM(), e como 
		//usando a xmoeda direto na impressao afetaria a performance (deveria executar
		//duas vezes, uma para imprimir e outra para pasar para a picture), elas devem]
		//ser inicializadas aqui. Bruno.

		nBasePrt	:=	Round(xMoeda(SE3->E3_BASE ,1,MV_PAR08,SE1->E1_EMISSAO,nDecs+1),nDecs)
		nComPrt	:=	Round(xMoeda(SE3->E3_COMIS,1,MV_PAR08,SE1->E1_EMISSAO,nDecs+1),nDecs)

		@ li, 95 PSAY dVencto
		@ li,107 PSAY dBaixa      
		
		If nBasePrt < 0 .And. nComPrt < 0
			nVlrTitulo := nVlrTitulo * -1
		Endif	
		
		dbSelectArea("SE3")
		@ li,119 PSAY SE3->E3_DATA
		@ li,130 PSAY SE3->E3_PEDIDO	Picture "@!"
		@ li,137 PSAY nVlrTitulo		Picture tm(nVlrTitulo,14,nDecs)
		@ li,153 PSAY nBasePrt 			Picture tm(nBasePrt,14,nDecs)
		@ li,169 PSAY SE3->E3_PORC		Picture tm(SE3->E3_PORC,6)
		@ li,176 PSAY nComPrt			Picture tm(nComPrt,14,nDecs)
		@ li,195 PSAY SE3->E3_BAIEMI

		If ( SE3->E3_AJUSTE == "S" .And. MV_PAR07==1)
			@ li,203 PSAY STR0018 //"AJUSTE "
		EndIf  
		        
	   _cQuer1 := " 	SELECT SC5.C5_MARGATU AS 'MARGATU'     "
       _cQuer1 += " FROM "+RetSqlName('SC5')+" SC5 "
   	   _cQuer1 += " INNER JOIN(SELECT * FROM "+RetSqlName('SE1')+" SE1 "
	   _cQuer1 += " WHERE E1_NUM  = '"+SE3->E3_NUM+"'"
	   _cQuer1 += " AND E1_PREFIXO  = '"+SE3->E3_PREFIXO+"'"
	   _cQuer1 += " AND SE1.D_E_L_E_T_ = ' '  "
	   _cQuer1 += " AND E1_FILIAL =  ' '  "
	   _cQuer1 += " AND E1_CLIENTE  = '"+SE3->E3_CODCLI+"'"
	   _cQuer1 += " AND E1_LOJA  = '"+SE3->E3_LOJA+"')TE1 "
	   _cQuer1 += " ON TE1.E1_FILORIG = C5_FILIAL   "
	   _cQuer1 += " WHERE C5_NUM  = '"+SE3->E3_PEDIDO+"'"
	   _cQuer1 += " AND C5_CLIENTE  = '"+SE3->E3_CODCLI+"'"
	   _cQuer1 += " AND C5_LOJACLI  = '"+SE3->E3_LOJA+"'"
	   _cQuer1 += " AND SC5.D_E_L_E_T_ = ' ' "
	   dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQuer1),'TM1A',.T.,.F.)
		
	
			DbSelectArea("TM1A")
		    TM1A->(dbgotop())
			While TM1A->(!EOF())
		       nMarNe := TM1A->MARGATU   
			   TM1A->(	dbskip()) 
			End
		    TM1A->(DBCLOSEAREA()) 
				 
				 	@ li,210 PSAY nMarNe Picture "@ke 999.99"  
				 		_cQuer1 := ""
		 	    //dbSelectArea("SE1")
			   //	dbSetOrder(1)
			  //	If	dbSeek(xFilial("SE1")+SE3->E3_PREFIXO+SE3->E3_NUM)
	                
	        	  //	If SC5->(dbSeek(SE1->E1_FILORIG+SE3->E3_PEDIDO)) 
		    	   //		@ li,210 PSAY SC5->C5_MARGATU Picture "@ke 999.99""
        	   	  //	EndIf
       
        	   //	EndIf
		nAc1 += nBasePrt
		nAc2 += nComPrt
		nAc3 += nVlrTitulo
		li++
		SE3->(dbSkip())
	EndDo
	
	If (nAc1+nAc2+nAc3) != 0
		li++
		
		If li > 55
			cabec(titulo,cabec1,cabec2,nomeprog,tamanho,nTipo)
		EndIF
		
		@ li, 00  PSAY OemToAnsi(STR0013)+cDescVend  //"TOTAL DO VENDEDOR --> "
		@ li,136  PSAY nAc3 	PicTure tm(nAc3,15,nDecs)
		@ li,152  PSAY nAc1 	PicTure tm(nAc1,15,nDecs)
		
		If nAc1 != 0
			@ li, 169 PSAY (nAc2/nAc1)*100   PicTure "999.99"
		Endif
		
		@ li, 175  PSAY nAc2 PicTure tm(nAc2,15,nDecs)
		li++
		
		If mv_par10 > 0 .And. (nAc2 * mv_par10 / 100) > GetMV("MV_VLRETIR") //IR
			@ li, 00  PSAY OemToAnsi(STR0015)  //"TOTAL DO IR       --> "
			@ li, 175  PSAY (nAc2 * mv_par10 / 100) PicTure tm(nAc2 * mv_par10 / 100,15,nDecs)
			li ++
			@ li, 00  PSAY OemToAnsi(STR0017)  //"TOTAL (-) IR      --> "
			@ li, 175 PSAY nAc2 - (nAc2 * mv_par10 / 100) PicTure tm(nAc2,15,nDecs)
			li ++
		EndIf
		
		@ li, 00  PSAY __PrtThinLine()

		If mv_par11 == 1  // Quebra pagina por vendedor (padrao)
			li := 60  
		Else
		   li+= 2
		Endif
	EndIF
	
	dbSelectArea("SE3")
	nAg1 += nAc1
	nAg2 += nAc2
 	nAg3 += nAc3
EndDo

IF (nAg1+nAg2+nAg3) != 0

	If li > 55
		cabec(titulo,cabec1,cabec2,nomeprog,tamanho,nTipo)
	Endif

	@li,  00 PSAY OemToAnsi(STR0014)  //"TOTAL  GERAL      --> "
	@li, 136 PSAY nAg3	Picture tm(nAg3,15,nDecs)
	@li, 152 PSAY nAg1	Picture tm(nAg1,15,nDecs)
	@li, 169 PSAY (nAg2/nAg1)*100														Picture "999.99"
	@li, 175 PSAY nAg2 Picture tm(nAg2,15,nDecs)
	
	If mv_par10 > 0 .And. (nAg2 * mv_par10 / 100) > GetMV("MV_VLRETIR")//IR
		li ++
		@ li, 00  PSAY OemToAnsi(STR0015)  //"TOTAL DO IR       --> "
		@ li, 175  PSAY (nAg2 * mv_par10 / 100) PicTure tm((nAg2 * mv_par10 / 100),15,nDecs)
		li ++
		@ li, 00  PSAY OemToAnsi(STR0017)  //"TOTAL (-) IR       --> "
		@ li, 175  PSAY nAg2 - (nAg2 * mv_par10 / 100) Picture tm(nAg2,15,nDecs)
	EndIf
	roda(cbcont,cbtxt,"G")
EndIF
    
#IFDEF TOP
	If TcSrvType() != "AS/400"
  		dbSelectArea("SE3")
		DbCloseArea()
		chkfile("SE3")
	Else	
#ENDIF
		fErase(cNomArq+OrdBagExt())
#IFDEF TOP
	Endif
#ENDIF

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Restaura a integridade dos dados                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("SE3")
RetIndex("SE3")
DbSetOrder(2)
dbClearFilter()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se em disco, desvia para Spool                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If aReturn[5] = 1
	Set Printer To
	dbCommitAll()
	ourspool(wnrel)
Endif

MS_FLUSH()
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AjustaSX1 ºAutor  ³Kleber Dias Gomes   º Data ³  22/12/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MATR540                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function AjustaSX1(cPerg)
Local aHelpPor := {}
Local aHelpEng := {}
Local aHelpSpa := {}

// Geracao do TXT
Aadd( aHelpPor, 'Selecione o Grupo de Clientes que deseja '  )
Aadd( aHelpPor, 'listar as Comissões                      '  )
PutSx1( cPerg, "16","Informe o setor    ?","Informe o setor    ?","Informe o setor    ?","mv_chg","N",1,0,3,"C","",""   ,"","","mv_par16","1-Representante","","","","2-Funcionario","","","3-Ambos","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)
PutSx1( cPerg, "17","Cliente de?","Cliente de?","Cliente de?",          				 "mv_chh","C",6,0,0,"G","","SA1","","","mv_par17","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)
PutSx1( cPerg, "18","Cliente ate ?","Cliente ate  ?","Cliente ate    ?",				 "mv_chi","C",6,0,0,"G","","SA1","","","mv_par18","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)
PutSx1( cPerg, "19","Grupo de Clientes?","Grupo de Clientes??","Grupo de Clientes?",     "mv_chj","C",6,0,0,"G","","ACY","","","mv_par19","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)

PutSX1Help("P.MTR54013.",aHelpPor,aHelpEng,aHelpSpa)

Return

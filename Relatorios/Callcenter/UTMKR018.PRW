#INCLUDE "TMKDEF.CH"           
#INCLUDE "REPORT.CH"


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TMKR018  ³ Autor ³ Armando M. Tessaroli  ³ Data ³ 28/02/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Analise do Telemarketing Ativo pelo Tipo de Reclamacao     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMKR018(void)                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TeleMarketing (SUC)                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Analista  ³ Data/Bops/Ver ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Marcelo K ³10/07/03³710   ³Correcao do seek na Tabela SU9 indice 1     ³±±
±±³Andrea F. ³11/05/04³811   ³Revisao do Fonte e inclusao de totalizadores³±±
±±³Michel W. ³07/08/06³99189 ³Atualizacao de relatorio para release 4.    ³±±
±±³Michel W. ³05/10/06³105074³Inserido SetLineBreak para secao 2.         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function UTMKR018()
Local oReport //Objeto relatorio TReport (Release 4)

If !FindFunction("TRepInUse") .OR. !TRepInUse()
	TMKR018R3()	
Else
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica as perguntas selecionadas                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Pergunte("TMK018",.F.)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Variaveis utilizadas para parametros                         ³
	//³ Mv_Par01           // Da Data                                ³
	//³ Mv_Par02           // Ate a Data                             ³
	//³ Mv_Par03           // Tipo de Reclamacao - Ocorrencia        ³
	//³ Mv_Par04           // Operador                               ³
	//³ Mv_Par05           // Produto                                ³
	//³ Mv_Par06           // Tipo de Produto                        ³
	//³ Mv_Par07           // Status da Ligacao - Plan. Pend. Encerr.³
	//³ Mv_Par08           // Do CEP                                 ³
	//³ Mv_Par09           // Ate o CEP                              ³
	//³ Mv_Par10	       // Contato                ?               ³
	//³ Mv_Par11 	       // Entidade               ?               ³
	//³ Mv_Par12	       // Segmento 1             ?               ³
	//³ Mv_Par13 	       // Segmento 2             ?               ³
	//³ Mv_Par14 		   // Segmento 3             ?               ³
	//³ Mv_Par15		   // Segmento 4             ?               ³
	//³ Mv_Par16	       // Segmento 5             ?               ³
	//³ Mv_Par17           // Segmento 6             ?               ³
	//³ Mv_Par18           // Segmento 7             ?               ³
	//³ Mv_Par19           // Segmento 8             ?               ³
	//³ Mv_Par20           // Tipo de atendimento    ?               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Interface de impressao³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oReport := Tkr018RptDef()
	oReport:PrintDialog() 
EndIf
Return(.T.)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³TMkr018R3 ³ Autor ³                       ³ Data ³          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Rotina para criacao de relatorios de Atendimento receptivo  ³±±
±±³          ³-Ocorrencias utilizando o release 3.                        ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMkr018R3()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ CALL CENTER                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function TMKR018R3()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local wnrel   	:= "TMKR018"  	 	// Nome do Arquivo utilizado no Spool
Local Titulo 	:= "Ligacoes Recebidas - Tipo de Reclamacao "			//"Ligacoes Recebidas - Tipo de Reclamacao "
Local cDesc1 	:= "Este programa ira emitir a relacao dos tipos"			//"Este programa ira emitir a relacao dos tipos"
Local cDesc2 	:= "de reclamacoes recebidas pelo operador"			//"de reclamacoes recebidas pelo operador"
Local cDesc3 	:= ""
Local nomeprog	:= "TMKR018.PRX"	 // nome do programa
Local cString 	:= "SUC"			 // Alias utilizado na Filtragem
Local lDic    	:= .F. 				 // Habilita/Desabilita Dicionario
Local lComp   	:= .F. 				 // Habilita/Desabilita o Formato Comprimido/Expandido
Local lFiltro 	:= .T. 				 // Habilita/Desabilita o Filtro

Private Tamanho := "G" 				 // P/M/G
Private Limite  := 220 				 // 80/132/220
Private aReturn := { "Zebrado",;		 //[1] Reservado para Formulario	//"Zebrado"
					 1,;			 //[2] Reservado para N§ de Vias
					 "Administracao",;		 //[3] Destinatario					//"Administracao"
					 2,;			 //[4] Formato => 1-Comprimido 2-Normal	
					 2,;	    	 //[5] Midia   => 1-Disco 2-Impressora
					 1,;			 //[6] Porta ou Arquivo 1-LPT1... 4-COM1...
					 "",;			 //[7] Expressao do Filtro
					 1 } 			 //[8] Ordem a ser selecionada
					 				 //[9]..[10]..[n] Campos a Processar (se houver)
Private m_pag   := 1  				 // Contador de Paginas
Private nLastKey:= 0  				 // Controla o cancelamento da SetPrint e SetDefault
Private cPerg   := "TMK018"  		 // Pergunta do Relatorio
Private aOrdem  := {}  				 // Ordem do Relatorio

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica as perguntas selecionadas                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Pergunte("TMK018",.F.)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros                         ³
//³ Mv_Par01           // Da Data                                ³
//³ Mv_Par02           // Ate a Data                             ³
//³ Mv_Par03           // Tipo de Reclamacao - Ocorrencia        ³
//³ Mv_Par04           // Operador                               ³
//³ Mv_Par05           // Produto                                ³
//³ Mv_Par06           // Tipo de Produto                        ³
//³ Mv_Par07           // Status da Ligacao - Plan. Pend. Encerr.³
//³ Mv_Par08           // Do CEP                                 ³
//³ Mv_Par09           // Ate o CEP                              ³
//³ Mv_Par10	       // Contato                ?               ³
//³ Mv_Par11 	       // Entidade               ?               ³
//³ Mv_Par12	       // Segmento 1             ?               ³
//³ Mv_Par13 	       // Segmento 2             ?               ³
//³ Mv_Par14 		   // Segmento 3             ?               ³
//³ Mv_Par15		   // Segmento 4             ?               ³
//³ Mv_Par16	       // Segmento 5             ?               ³
//³ Mv_Par17           // Segmento 6             ?               ³
//³ Mv_Par18           // Segmento 7             ?               ³
//³ Mv_Par19           // Segmento 8             ?               ³
//³ Mv_Par20           // Tipo de atendimento    ?               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    
CriaSX1()

wnrel:=SetPrint(cString,wnrel,cPerg,@titulo,cDesc1,cDesc2,cDesc3,lDic,aOrdem,lComp,Tamanho,lFiltro)

If (nLastKey == 27)
	DbSelectArea(cString)
	DbSetOrder(1)
	DbClearFilter()
	Return
Endif

SetDefault(aReturn,cString)

If (nLastKey == 27)
	DbSelectArea(cString)
	DbSetOrder(1)
	DbClearFilter()
	Return
Endif

RptStatus({|lEnd| TR018Imp(@lEnd,wnRel,cString,nomeprog,Titulo)},Titulo)

Return(.T.)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TR018    ³ Autor ³ Armando M. Tessaroli  ³ Data ³ 28/02/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Analise do Telemarketing Ativo pelo Tipo de Reclamacao     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMKR018			                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Analista  ³ Data/Bops/Ver ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³        ³      ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function TR018Imp(lEnd,wnrel,cString,nomeprog,Titulo)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para Impressao Do Cabecalho e Rodape    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local nLi		:= 0			// Linha a ser impressa
Local nMax		:= 58			// Maximo de linhas suportada pelo relatorio
Local cbCont	:= 0			// Numero de Registros Processados
Local cbText	:= SPACE(10)	// Mensagem do Rodape
Local cCabec1	:= "" 			// Label dos itens
Local cCabec2	:= "" 			// Label dos itens

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Declaracao de variaveis especificas para este relatorio³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local cSUC			:= "SUC"					// Gerencia o alias para tratamento no top e dbf
Local cSUD			:= "SUD"					// Gerencia o alias para tratamento no top e dbf
Local nI			:= 0						// Controle
Local cCodSUC		:= ""						// Manipula a quebra do cabecalho
Local cCodSUD		:= ""						// Manipula a quebra dos itens
Local aTotGerAtend	:= {}						// Totalizacao dos atendimentos ativos e receptivos por data
Local aTotGerOcorr	:= {}						// Totalizacao das ocorrencias
Local aTotGerProd	:= {}						// Totalizacao das ocorrencias X produtos
Local aTotGerAss 	:= {}						// Totalizacao das ocorrencias X assunto 
Local dData			:= CtoD("  /  /  ")			// Manipula a quebra por data
Local aUC_Status	:= TkSx3Box("UC_STATUS")	// Le as opcoes do campo no dd SX3
Local aUC_Operaca	:= TkSx3Box("UC_OPERACA")	// Le as opcoes do campo no dd SX3
Local aUD_Status	:= TkSx3Box("UD_STATUS")	// Le as opcoes do campo no dd SX3
Local cDesc			:= ""						// Variavel de auxilio 
Local cDescPro		:= ""						// Variavel de auxilio 
Local cDescOco		:= ""						// Variavel de auxilio 
Local cCodOcorr     := ""					    // Contem o codigo da Ocorrencia anterior
Local cCodAss       := ""						// Contem o codigo do Assunto anterior
Local nAtivos		:= 0                        // Total de ligacoes ativas
Local nReceptivos	:= 0                        // Total de ligacoes receptivas
Local nTotOcorr		:= 0                        // Total de Ocorrencias
Local nTotProd 		:= 0                        // Total de Produtos
Local nTotAss       := 0                        // Total de Assunto
Local lCompart		:= SUC->(FieldPos("UC_CHAORIG")) > 0

#IFDEF TOP
	Local aSetField		:= {}			// Parametros para SetField do alias principal
	Local cCampos		:= ""			// Campos do alias principal para select
	Local cQuery		:= ""			// Armazena a expressao da query para top
	Local cWhere		:= ""			// Validacao do segmento de negocio para top
#ENDIF

DbSelectArea("SUD")
DbSetOrder(1)

DbSelectArea("SUC")
DbSetOrder(3)
SetRegua(RecCount())

#IFDEF TOP
	cSUD := "SUC"
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Chamo a funcao que monta a parte da query para validar os segmentos de negocios³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Mv_Par11 == "SA1" .OR. Mv_Par11 == "SUS"
		TKSegmento(	Mv_Par12,	Mv_Par13,	Mv_Par14,	Mv_Par15,;
					Mv_Par16,	Mv_Par17,	Mv_Par18,	Mv_Par19,;
					Mv_Par11,	"",			@cWhere)
	Endif
	
	TkSelect(cString, @cCampos, @aSetField)
	
	cQuery :=	" SELECT	" + cCampos + ", " +;
				"			UD_ASSUNTO, UD_PRODUTO, UD_OCORREN, UD_SOLUCAO, UD_OPERADO, UD_DATA, UD_STATUS, " +;
				"			UD_DTEXEC, UD_OBS, UD_CODEXEC, UD_CODIGO, UD_ITEM " +;
				" FROM " + RetSqlName("SUC") + " SUC," + RetSqlName("SUD") + " SUD"

	If !Empty(Mv_Par06)
		cQuery += ", " + RetSqlName("SB1") + " SB1"
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Implementa na query a validacao dos segmentos de negocios³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !Empty(cWhere)
		cQuery += ", " + RetSqlName(Mv_Par11) + " " + Mv_Par11
	Endif
	
	cQuery +=	" WHERE	SUC.UC_FILIAL = '" + xFilial("SUC") + "' AND" +;
				"		SUC.UC_CODCANC = '' AND" +;
				"		SUC.UC_DATA BETWEEN '" + DtoS(Mv_Par01) + "' AND '" + DtoS(Mv_Par02) + "' AND"

	If Mv_Par20 <> 3 //Ambos
		cQuery += "		(SUC.UC_OPERACA = '" + IIF(Mv_Par20==1,"2","1") + "' OR"
		cQuery += "		SUC.UC_OPERACA = '') AND"
	Endif

	If !Empty(Mv_Par04)
		cQuery += "		SUC.UC_OPERADO = '" + Mv_Par04 + "' AND"
	Endif
	
	If !Empty(Mv_Par10)
		cQuery += "		SUC.UC_CODCONT = '" + Mv_Par10 + "' AND"
	Endif
	
	If !Empty(Mv_Par11)
		cQuery += "		SUC.UC_ENTIDAD = '" + Mv_Par11 + "' AND"
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Seleciono somente chamados que nao sao compartilhamento³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lCompart
		cQuery += "		SUC.UC_CHAORIG = '' AND"
	EndIf

	If (Mv_Par07 <> 1)  // Todas as licacoes
		cQuery += "		(SUC.UC_STATUS = '" + Str(Mv_Par07-1,1) + "' OR"
		cQuery += "		SUC.UC_STATUS = '') AND"
	Endif
                
	cQuery +=	"		SUD.UD_FILIAL = '" + xFilial("SUD") + "' AND" +;
     				"		SUD.UD_CODIGO = SUC.UC_CODIGO AND"
     			
	If !Empty(Mv_Par03)
		cQuery += "		SUD.UD_OCORREN = '" + Mv_Par03 + "' AND"
	Endif
	
	If !Empty(Mv_Par05)
		cQuery += "		SUD.UD_PRODUTO = '" + Mv_Par05 + "' AND"
	Endif
	
	If !Empty(Mv_Par06)
		cQuery +=	"	SB1.B1_FILIAL = '" + xFilial("SB1") + "' AND" +;
					"	SB1.B1_COD = SUD.UD_PRODUTO AND" +;
					"	SB1.B1_TIPO = '" + AllTrim(Mv_Par06) + "' AND" +;
					"	SB1.D_E_L_E_T_ = ' ' AND"
	Endif
     			
	cQuery +=	"		SUD.D_E_L_E_T_ = ' ' AND" +;
				"		SUC.D_E_L_E_T_ = ' ' "

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Implementa na query a validacao dos segmentos de negocios³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !Empty(cWhere)
		cQuery += " AND " + cWhere
	Endif
	
	cQuery +=	" ORDER BY " + SqlOrder(SUC->(IndexKey())) + "," + SqlOrder(SUD->(IndexKey()))
	
	cQuery	:= ChangeQuery(cQuery)
	// MemoWrite("TMKR018.SQL", cQuery)
	DbSelectArea(cSUC)
	DbCloseArea()
	DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'SUC', .F., .T.)
	
	For nI := 1 To Len(aSetField)
		TCSetField(cString, aSetField[nI][1], aSetField[nI][2], aSetField[nI][3], aSetField[nI][4])
	Next nI
	TCSetField('SUC', 'UD_DATA',	'D')
	TCSetField('SUC', 'UD_DTEXEC',	'D')

#ELSE
	DbSeek(xFilial("SUC")+DtoS(Mv_Par01), .T.)
#ENDIF


While	(!Eof())							.AND.;
		(cSUC)->UC_FILIAL == xFilial(cSUC)	.AND.;
		(cSUC)->UC_DATA >= Mv_Par01			.AND.;
		(cSUC)->UC_DATA <= Mv_Par02
	
	IncRegua()
	
	If lEnd
		@Prow()+1,000 PSay "CANCELADO PELO OPERADOR" //"CANCELADO PELO OPERADOR"
		Exit
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Considera filtro do usuario                                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If (!Empty(aReturn[7])) .AND. (!&(aReturn[7]))
		DbSkip()
		Loop
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Seleciona o intervalo do CEP Exeto Concorrente que nao tem CEP ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Mv_Par11 <> "AC3"
		cCep := TkEntidade((cSUC)->UC_ENTIDAD,(cSUC)->UC_CHAVE,5)
		If Alltrim(cCep) < Alltrim(Mv_Par08) .OR. Alltrim(cCep) > Alltrim(Mv_Par09)
			DbSkip()
			Loop
		Endif
	Endif
	
	#IFNDEF TOP
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Elimino as ligacoes canceladas                           ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !Empty((cSUC)->UC_CODCANC)
			DbSkip()
			Loop
		Endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Nao seleciono chamados que sao compartilhamentos         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lCompart .AND. !Empty((cSUC)->UC_CHAORIG)
			DbSkip()
			Loop
		EndIf
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Seleciona as ligacoes de acordo com o parametro RECEPTIVO/ATIVO/AMBOS³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If Mv_Par20 <> 3 //Ambos  (Nao sera validado o Tipo de Ligacao para a impressao)
			If Mv_Par20 == 1  //Ativo
				If Val((cSUC)->UC_OPERACA) <> ATIVO .OR. Empty((cSUC)->UC_OPERACA) //"2"
					DbSkip()
					Loop
				Endif
			Else           //Receptivo
				If Val((cSUC)->UC_OPERACA) <> RECEPTIVO .OR. Empty((cSUC)->UC_OPERACA) //"1"
					DbSkip()
					Loop
				Endif
			Endif
		Endif
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Seleciono apenas os operadores validos³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !Empty(Mv_Par04) .AND. (cSUC)->UC_OPERADO <> Mv_Par04
			DbSkip()
			Loop
		Endif
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifico o contato                                   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !Empty(Mv_Par10) .AND. (cSUC)->UC_CODCONT <> AllTrim(Mv_Par10)
			DbSkip()
			Loop
		Endif
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Permite a impressao somente da entidade informada        ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !Empty(Mv_Par11) .AND. (cSUC)->UC_ENTIDAD <> Mv_Par11
			DbSkip()
			Loop
		Endif
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Seleciona o status da ligacao informado                  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If Mv_Par07 <> 1  // Todas
			Do Case
				Case Mv_Par07 == 2 // Planejada
					If Val((cSUC)->UC_STATUS) <> PLANEJADA		// 1
						DbSelectarea(cSUC)
						DbSkip()
						Loop
					Endif
					
				Case Mv_Par07 == 3 // Pendente
					If Val((cSUC)->UC_STATUS) <> PENDENTE		// 2
						DbSelectarea(cSUC)
						DbSkip()
						Loop
					Endif
					
				Case Mv_Par07 == 4 // Encerrada
					If VAL((cSUC)->UC_STATUS) <> ENCERRADA		// 3
						DbSelectarea(cSUC)
						DbSkip()
						Loop
					Endif
			EndCase
		Endif
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ VerIfico os parametros referentes aos itens do atendimento ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !Tk018Valid(cSUC, cSUD)
			DbSkip()
			Loop
		Endif
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Chamo a funcao que valida os segmentos de negocios³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If Mv_Par11 == "SA1" .OR. Mv_Par11 == "SUS"
			If !TKSegmento(	Mv_Par12,	Mv_Par13,	Mv_Par14,	Mv_Par15,;
							Mv_Par16,	Mv_Par17,	Mv_Par18,	Mv_Par19,;
							Mv_Par11,	(cSUC)->UC_CHAVE)
				DbSkip()
				Loop
			Endif
		Endif
	#ENDIF
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Comeca a imprimir o relatorio neste ponto³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If cCodSUC <> (cSUC)->UC_CODIGO
		cCodSUC := (cSUC)->UC_CODIGO

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Funcao que incrementa a linha e verifica a quebra de pagina³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		TkIncLine(@nLi,3,nMax,titulo,cCabec1,cCabec2,nomeprog,tamanho)
		@ nLi,000		PSay __PrtThinLine()
		TkIncLine(@nLi,2,nMax,titulo,cCabec1,cCabec2,nomeprog,tamanho)
				
		@ nLi,000		PSay PadR("Data do Atendimento",25) + ":"//"Data do Atendimento"
		@ nLi,PCol()+1	PSay PadR((cSUC)->UC_DATA,10)
		@ nLi,PCol()+1	PSay (cSUC)->UC_INICIO 
		@ nLi,PCol()+1	PSay " - " + (cSUC)->UC_FIM 
		@ nLi,Limite/2	PSay PadR("Nome do Contato",25) + ":"//"Nome do Contato"
		@ nLi,PCol()+1	PSay PadR(Posicione("SU5",1,xFilial("SU5")+(cSUC)->UC_CODCONT,"U5_CONTAT"),30)
		
		DbSelectArea("SX5")
		DbSetOrder(1)
		If DbSeek(xFilial("SX5")+"T5"+(cSUC)->UC_ENTIDAD)
			cDesc := X5DESCRI()
		EndIf
		TkIncLine(@nLi,1,nMax,titulo,cCabec1,cCabec2,nomeprog,tamanho)
		@ nLi,000		PSay PadR("Codigo do Atendimento",25) + ":"//"Codigo do Atendimento"
		@ nLi,PCol()+1	PSay PadR((cSUC)->UC_CODIGO,6)
		@ nLi,Limite/2	PSay PadR("Fone Com.1",25) + ":"// "Fone Com.1"
		@ nLi,PCol()+1	PSay PadR(TkDadosContato((cSUC)->UC_CODCONT,4),15) Picture "@R 9999-9999" 

		TkIncLine(@nLi,1,nMax,titulo,cCabec1,cCabec2,nomeprog,tamanho)
		@ nLi,000		PSay PadR("Nome do Operador",25) + ":"//"Nome do Operador"
		@ nLi,PCol()+1	PSay PadR(Posicione("SU7",1,xFilial("SU7")+(cSUC)->UC_OPERADO,"U7_NREDUZ"),30)
		@ nLi,Limite/2	PSay PadR("E-Mail",25) + ":"		// "E-Mail"
		@ nLi,PCol()+1	PSay PadR(TkDadosContato((cSUC)->UC_CODCONT,10),40)//"Descricao do Email"

		TkIncLine(@nLi,1,nMax,titulo,cCabec1,cCabec2,nomeprog,tamanho)
		@ nLi,000		PSay PadR("Status do Atendimento",25) + ":"//"Status do Atendimento"
		@ nLi,PCol()+1	PSay PadR(IIF(!Empty((cSUC)->UC_STATUS),aUC_Status[Val((cSUC)->UC_STATUS)],""),30)
		@ nLi,Limite/2	PSay PadR("Descricao da Entidade",25) + ":"//"Descricao da Entidade"
		@ nLi,PCol()+1	PSay PadR(cDesc,120)

		TkIncLine(@nLi,1,nMax,titulo,cCabec1,cCabec2,nomeprog,tamanho)
		@ nLi,000		PSay PadR("Tipo do Atendimento",25) + ":"//"Tipo do Atendimento"
		@ nLi,PCol()+1	PSay PadR(IIF(!Empty((cSUC)->UC_OPERACA),aUC_Operaca[Val((cSUC)->UC_OPERACA)],""),30)
		@ nLi,Limite/2	PSay PadR("Razao Social da Entidade",25) + ":"//"Razao Social da Entidade"
		@ nLi,PCol()+1	PSay PadR(TkEntidade((cSUC)->UC_ENTIDAD,(cSUC)->UC_CHAVE,1),120)
		
		TkIncLine(@nLi,1,nMax,titulo,cCabec1,cCabec2,nomeprog,tamanho)
		@ nLi,000		PSay PadR("Midia",25) + ":"	//"Midia"	
		@ nLi,PCol()+1	PSay PadR((cSUC)->UC_MIDIA,6) + " - " +;
							 PadR(Posicione("SUH",1,xFilial("SUH")+(cSUC)->UC_MIDIA,"UH_DESC"),40) // "Descricao da Midia"
		@ nLi,Limite/2	PSay PadR("Telefone da Entidade",25) + ":"//"Telefone da Entidade"
		@ nLi,PCol()+1	PSay TkEntidade((cSUC)->UC_ENTIDAD,(cSUC)->UC_CHAVE,6) Picture "@R 9999-9999" 
		
		TkIncLine(@nLi,1,nMax,titulo,cCabec1,cCabec2,nomeprog,tamanho)
		@ nLi,000		PSay PadR("Comunicacao",25)  + ":"		// "Comunicacao"
		@ nLi,PCol()+1	PSay PadR((cSUC)->UC_TIPO,6)  + " - " + ;
							 PadR(Posicione("SUL",1,xFilial("SUL")+(cSUC)->UC_TIPO,"UL_DESC"),55) // "Descricao da Comunicacao"
		@ nLi,Limite/2	PSay PadR("Cidade da Entidade",25) + ":"//"Cidade da Entidade"
		@ nLi,PCol()+1	PSay PadR(TkEntidade((cSUC)->UC_ENTIDAD,(cSUC)->UC_CHAVE,3),120)

		TkIncLine(@nLi,1,nMax,titulo,cCabec1,cCabec2,nomeprog,tamanho)
		@ nLi,000		PSay PadR("Motivo do Encerramento",25) + ":"//"Motivo do Encerramento"
		@ nLi,PCol()+1	PSay PadR(Posicione("SUN",1,xFilial("SUN")+(cSUC)->UC_CODENCE,"UN_DESC"),30)
		@ nLi,Limite/2	PSay PadR("Estado da Entidade",25) + ":"//"Estado da Entidade"
		@ nLi,PCol()+1	PSay PadR(TkEntidade((cSUC)->UC_ENTIDAD,(cSUC)->UC_CHAVE,4),120)
				
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Imprime a observacao da liga‡ao                          ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aLinhas := TkMemo((cSUC)->UC_CODOBS, 190)
		For nI := 1 to Len(aLinhas)
			TkIncLine(@nLi,1,nMax,titulo,cCabec1,cCabec2,nomeprog,tamanho)
			If nI == 1
				@ nLi,000 PSay PadR("Observacao do Atendimento",25)+ ":" //"Observacao do Atendimento"
			Endif
			@ nLi,28 PSay aLinhas[nI]
		Next nI
		
		TkIncLine(@nLi,1,nMax,titulo,cCabec1,cCabec2,nomeprog,tamanho)
		@ nLi,000 Psay Replicate("-",220)
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Acumula os atendimentos Ativos e Receptivos por Data³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If Len(aTotGerAtend) == 0
			aAdd(aTotGerAtend, {,,1})
		Else
			aTotGerAtend[1][3]++	
        Endif                 
        
		nPosDtAtend:= aScan(aTotGerAtend, {|x| x[1]==(cSUC)->UC_DATA}) 
		If nPosDtAtend > 0
			If Val((cSUC)->UC_OPERACA) == ATIVO
				aTotGerAtend[nPosDtAtend][2]++	//ATIVO
			Else
				aTotGerAtend[nPosDtAtend][3]++ 	//RECEPTIVO
		    Endif
		Else
			If Val((cSUC)->UC_OPERACA) == ATIVO
			 	Aadd(aTotGerAtend,{(cSUC)->UC_DATA,1,0 })
			Else
			 	Aadd(aTotGerAtend,{(cSUC)->UC_DATA,0,1 })
		    Endif
		Endif
		
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Comeca a imprimir os itens do atendimento            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	#IFNDEF TOP
		DbSelectArea(cSUD)
		DbSetOrder(1)
		DbSeek(xFilial(cSUD) + (cSUC)->UC_CODIGO)
		While	(!Eof())								.AND.;
				(cSUD)->UD_FILIAL == xFilial(cSUC)		.AND.;
				(cSUD)->UD_CODIGO == (cSUC)->UC_CODIGO
	#ENDIF
			
			TK018Itens(	@nLi,			nMax,			titulo,			cCabec1,;
						cCabec2,		nomeprog,		tamanho,		cSUC,;
						cSUD,			aUD_Status,		@cCodSUD,		@aTotGerOcorr,;
						@aTotGerProd,	@aTotGerAss,	@nTotOcorr,		@nTotProd,;
						@nTotAss)
	#IFNDEF TOP
			DbSelectArea(cSUD)
			DbSkip()
		End
	#ENDIF
	
	DbSelectArea(cSUC)
	DbSkip()

End


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Imprimi os totais dos atendimentos ao sair do while³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Len(aTotGerAtend) > 0
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Salta a Pagina para imprimir os totalizadores³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	TkIncLine(@nLi,nMax+1,nMax,titulo,cCabec1,cCabec2,nomeprog,tamanho)
	TkIncLine(@nLi,1,nMax,titulo,cCabec1,cCabec2,nomeprog,tamanho)
	@ nLi,000			PSay "TOTAL DE ATENDIMENTOS ATIVOS E RECEPTIVOS NO PERÍODO DE  " +;	//"TOTAL DE ATENDIMENTOS ATIVOS E RECEPTIVOS NO PERÍODO DE  "  
	DTOC(MV_PAR01)+ " - " + (cDia:= Tk_DiaSemana(MV_PAR01,Nil,Nil))+ " ATE " +;  //" ATE "
	DTOC(MV_PAR02)+ " - " + (cDia:= Tk_DiaSemana(MV_PAR02,Nil,Nil)) + " -> " 
	@ nLi,PCol()+5		PSay aTotGerAtend[1][3] Picture '@E 999,999'
	
	TkIncLine(@nLi,2,nMax,titulo,cCabec1,cCabec2,nomeprog,tamanho)
	@ nLi,000			PSay "DATA          ATIVOS       RECEPTIVOS"	//"DATA          ATIVOS       RECEPTIVOS"
	For nI:= 2 To Len(aTotGerAtend)
		TkIncLine(@nLi,1,nMax,titulo,cCabec1,cCabec2,nomeprog,tamanho)
		@ nLi,000		PSay aTotGerAtend[nI][1] Picture '@E 999,999'
		@ nLi,PCol()+5 	PSay aTotGerAtend[nI][2] Picture '@E 999,999'
		@ nLi,PCol()+10	PSay aTotGerAtend[nI][3] Picture '@E 999,999'
	    nAtivos		+=aTotGerAtend[nI][2]
	    nReceptivos	+=aTotGerAtend[nI][3]
	Next nI
	TkIncLine(@nLi,1,nMax,titulo,cCabec1,cCabec2,nomeprog,tamanho)
	@ nLi,000 			PSay "TOTAL"	//"TOTAL"
	@ nLi,013			PSay nAtivos 	Picture '@E 999,999'
	@ nLi,PCol()+10		PSay nReceptivos Picture '@E 999,999'
	
	If Len(aTotGerOcorr) > 0
		aSort(aTotGerOcorr,,, {|x,y| x[2] > y[2]} )		// Decrescente
		TkIncLine(@nLi,1,nMax,titulo,cCabec1,cCabec2,nomeprog,tamanho)
		@ nLi,000		PSay __PrtThinLine()
		TkIncLine(@nLi,1,nMax,titulo,cCabec1,cCabec2,nomeprog,tamanho)
		@ nLi,000		PSay "OCORRÊNCIAS COM MAIOR NÚMERO DE ATENDIMENTOS"	//"OCORRÊNCIAS COM MAIOR NÚMERO DE ATENDIMENTOS"
		TkIncLine(@nLi,2,nMax,titulo,cCabec1,cCabec2,nomeprog,tamanho)
		@ nLi,000		PSay "OCORRÊNCIA                                                    TOTAL       %"	//"OCORRÊNCIA                                                    TOTAL       %"
		For nI := 1 To Len(aTotGerOcorr)
			TkIncLine(@nLi,1,nMax,titulo,cCabec1,cCabec2,nomeprog,tamanho)
			@ nLi,000		PSay aTotGerOcorr[nI][1] + " - " + PadR(Posicione("SU9",2,xFilial("SU9")+aTotGerOcorr[nI][1],"U9_DESC"),35)
			@ nLi,PCol()+15	PSay aTotGerOcorr[nI][2] Picture '@E 999,999'
			@ nLi,PCol()+5	PSay Transform(aTotGerOcorr[nI][2]/nTotOcorr*100, '@E 999.99') + ' %'
		Next nI
	Endif
	
	If Len(aTotGerProd) > 0
		aSort(aTotGerProd,,, {|x,y| x[1]+x[2] < y[1]+y[2]} )		 
		TkIncLine(@nLi,1,nMax,titulo,cCabec1,cCabec2,nomeprog,tamanho)
		@ nLi,000		PSay __PrtThinLine()
		TkIncLine(@nLi,1,nMax,titulo,cCabec1,cCabec2,nomeprog,tamanho)
		@ nLi,000		PSay "OCORRÊNCIAS EXECUTADAS POR PRODUTO "	//"OCORRÊNCIAS EXECUTADAS POR PRODUTO "
		TkIncLine(@nLi,2,nMax,titulo,cCabec1,cCabec2,nomeprog,tamanho)
		@ nLi,000		PSay "OCORRÊNCIA                                                    TOTAL       %"	//"OCORRÊNCIA                                                    TOTAL       %"
		For nI := 1 To Len(aTotGerProd)
			TkIncLine(@nLi,1,nMax,titulo,cCabec1,cCabec2,nomeprog,tamanho)
            If cCodOcorr <> aTotGerProd[nI][1]
				@ nLi,000		PSay aTotGerProd[nI][1] + " - " +  PadR(Posicione("SU9",2,xFilial("SU9")+aTotGerProd[nI][1],"U9_DESC"),35)
				TkIncLine(@nLi,1,nMax,titulo,cCabec1,cCabec2,nomeprog,tamanho)
				cCodOcorr:= aTotGerProd[nI][1]
            Endif
			@ nLi,010		PSay aTotGerProd[nI][1] + " - " + PadR(Posicione("SB1",1,xFilial("SB1")+aTotGerProd[nI][2],"B1_DESC"),35)
			@ nLi,PCol()+5	PSay aTotGerProd[nI][3] Picture '@E 999,999'
			@ nLi,PCol()+5	PSay Transform(aTotGerProd[nI][3]/nTotProd*100, '@E 999.99') + ' %'
		Next nI
	Endif
	
    If Len(aTotGerAss) > 0
		TkIncLine(@nLi,1,nMax,titulo,cCabec1,cCabec2,nomeprog,tamanho)
		@ nLi,000		PSay __PrtThinLine()
		TkIncLine(@nLi,1,nMax,titulo,cCabec1,cCabec2,nomeprog,tamanho)
		@ nLi,000		PSay "OCORRÊNCIAS EXECUTADAS POR ASSUNTO "	//"OCORRÊNCIAS EXECUTADAS POR ASSUNTO "
		TkIncLine(@nLi,2,nMax,titulo,cCabec1,cCabec2,nomeprog,tamanho)
		@ nLi,000		PSay "ASSUNTO                                                       TOTAL       %"	//"ASSUNTO                                                       TOTAL       %"
		For nI := 1 To Len(aTotGerAss)
			TkIncLine(@nLi,1,nMax,titulo,cCabec1,cCabec2,nomeprog,tamanho)
            If cCodAss <> aTotGerAss[nI][1]
				@ nLi,000		PSay aTotGerAss[nI][1] + " - " +  PadR(Posicione("SX5",1,xFilial("SX5")+"T1"+aTotGerAss[nI][1],"X5_DESCRI"),55)
				TkIncLine(@nLi,1,nMax,titulo,cCabec1,cCabec2,nomeprog,tamanho)
				cCodAss:= aTotGerAss[nI][1]
            Endif
			@ nLi,010		PSay aTotGerAss[nI][2] + " - " + PadR(Posicione("SU9",2,xFilial("SU9")+aTotGerAss[nI][2],"U9_DESC"),35)
			@ nLi,PCol()+5	PSay aTotGerAss[nI][3] Picture '@E 999,999'
			@ nLi,PCol()+5	PSay Transform(aTotGerAss[nI][3]/nTotAss*100, '@E 999.99') + ' %'
		Next nI
    Endif
    
	TkIncLine(@nLi,1,nMax,titulo,cCabec1,cCabec2,nomeprog,tamanho)
	@ nLi,000		PSay __PrtFatLine()
		
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Depois que imprime os totais salta de pagina³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	TkIncLine(@nLi,nMax+1,nMax,titulo,cCabec1,cCabec2,nomeprog,tamanho)
Endif

If nLi == 0
	TkIncLine(@nLi,1,nMax,titulo,cCabec1,cCabec2,nomeprog,tamanho)
	@ nLi,000 PSay "Nao ha informacoes para imprimir este relatorio" //"Nao ha informacoes para imprimir este relatorio"
Endif


Roda(cbCont,cbText,Tamanho)

#IFDEF TOP
	DbSelectArea(cSUC)
	DbCloseArea()
	ChkFile(cSUC)
#ENDIF

Set Device To Screen
If ( aReturn[5] = 1 )
	Set Printer To
	dbCommitAll()
	OurSpool(wnrel)
Endif
MS_FLUSH()

Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TMKR018   ºAutor  ³Armando M. Tessaroliº Data ³  25/02/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³   Imprime os itens do atendimento SUC |----o< SUD          º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ TMKR018                                                    º±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Analista  ³ Data/Bops/Ver ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Conrado Q.|13/03/07³912   ³ Bops 121068: Correção na chamada da função ³±±
±±³          |        ³      ³ DbSeek.                                    ³±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function TK018Itens(	nLi,	   		nMax,			titulo,			cCabec1,;
							cCabec2,		nomeprog,		tamanho,		cSUC,;
							cSUD,			aUD_Status,		cCodSUD,		aTotGerOcorr,;
							aTotGerProd,	aTotGerAss,		nTotOcorr,		nTotProd,;
							nTotAss	)

Local aLinhas	:= {}
Local nI		:= 0
Local aUser		:= {}
Local cDescAss	:= "" 
Local cDescPro	:= ""
Local cDescOco	:= ""
Local cDescSol	:= ""
Local nPos 		:= 0 

If (cSUD)->UD_CODIGO <> cCodSUD
	cCodSUD := (cSUD)->UD_CODIGO
	TkIncLine(@nLi,1,nMax,titulo,cCabec1,cCabec2,nomeprog,tamanho)
	@ nLi,000	PSay PadR("Item  Assunto                              Produto                         Ocorrencia                      Acao                                                Responsavel      Dt Acao     Status        Execucao", Limite) //"Item  Assunto                              Produto                         Ocorrencia                      Acao                                                Responsavel      Dt Acao     Status        Execucao"
	TkIncLine(@nLi,1,nMax,titulo,cCabec1,cCabec2,nomeprog,tamanho)
	@ nLi,000 Psay Replicate("-",220)//PSay __PrtThinLine()
Endif

If !Empty((cSUD)->UD_ASSUNTO)
	DbSelectArea("SX5")
	DbSetORder(1)		// Codigo do Assunto
	If DbSeek(xFilial("SX5")+"T1"+(cSUD)->UD_ASSUNTO)
		cDescAss := X5DESCRI()
	EndIf
EndIf


If !Empty((cSUD)->UD_PRODUTO)
	DbSelectArea("SB1")
	DbSetORder(1)
	If DbSeek(xFilial("SB1")+(cSUD)->UD_PRODUTO)
		cDescPro := SB1->B1_DESC
	EndIf
EndIf

If !Empty((cSUD)->UD_OCORREN)
	DbSelectArea("SU9")
	DbSetORder(1)
	If DbSeek(xFilial("SU9")+(cSUD)->UD_ASSUNTO+(cSUD)->UD_OCORREN)
		cDescOco := SU9->U9_DESC
	EndIf
EndIf

If !Empty((cSUD)->UD_SOLUCAO)
	DbSelectArea("SUQ")
	DbSetORder(1)
	If DbSeek(xFilial("SUQ")+(cSUD)->UD_SOLUCAO)
		cDescSol := SUQ->UQ_DESC
	EndIf
EndIf

PswOrder(1)
aUser := IIF(PswSeek((cSUD)->UD_OPERADO),PswRet(1),{})

TkIncLine(@nLi,1,nMax,titulo,cCabec1,cCabec2,nomeprog,tamanho)
@ nLi,000		PSay PadR((cSUD)->UD_ITEM,4)
@ nLi,PCol()+2	PSay PadR(cDescAss,35)
@ nLi,PCol()+2	PSay PadR(cDescPro,30)
@ nLi,PCol()+2	PSay PadR(cDescOco,30)
@ nLi,PCol()+2	PSay PadR(cDescSol,50)
@ nLi,PCol()+2	PSay PadR(IIF(Len(aUser)>0,aUser[1][2],""),15)
@ nLi,PCol()+2	PSay PadR((cSUD)->UD_DATA,10)
@ nLi,PCol()+2	PSay PadR(IIF(!Empty((cSUD)->UD_STATUS),aUD_Status[Val((cSUD)->UD_STATUS)],""),12)
@ nLi,PCol()+2	PSay PadR((cSUD)->UD_DTEXEC,10)
 
 
//Reginaldo Borges 31/08/2012

// Abrir esse bloco de comentario nessa estrutura
//para nao sair no relatorio
/*
If !Empty((cSUD)->UD_OBS)
	TkIncLine(@nLi,1,nMax,titulo,cCabec1,cCabec2,nomeprog,tamanho)
	@ nLi,000		PSay PadR(STR0020,30) //"Observação do atendimento"
	@ nLi,PCol()+1	PSay PadR((cSUD)->UD_OBS,190)
Endif

If !Empty((cSUD)->UD_CODEXEC)
	aLinhas := TkMemo((cSUD)->UD_CODEXEC, 185)
	For nI := 1 to Len(aLinhas)
		TkIncLine(@nLi,1,nMax,titulo,cCabec1,cCabec2,nomeprog,tamanho)
		If nI == 1
			  @ nLi,000 PSay PadR(STR0031,30) //"Complemento da execucao"
		Endif
		@ nLi,031 PSay aLinhas[nI]
	Next nI
Endif 

*/


//Michel - 07/08/06 - Parei aqui...
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Acumula os totalizadores gerais³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Empty((cSUD)->UD_OCORREN)
	nTotOcorr+=1
	nPos := aScan(aTotGerOcorr, {|x| x[1]==(cSUD)->UD_OCORREN} )
	If nPos == 0
		aAdd(aTotGerOcorr, {(cSUD)->UD_OCORREN, 1} )
	Else
		aTotGerOcorr[nPos][2]++
	Endif
Endif

If !Empty((cSUD)->UD_PRODUTO) .AND. !Empty((cSUD)->UD_OCORREN)
	nTotProd+=1
	nPos := aScan(aTotGerProd, {|x| ALLTRIM(x[1]+x[2])==ALLTRIM((cSUD)->UD_OCORREN+(cSUD)->UD_PRODUTO)} )
	If nPos == 0
		aAdd(aTotGerProd, {(cSUD)->UD_OCORREN,(cSUD)->UD_PRODUTO,1} )
	Else
		aTotGerProd[nPos][3]++
	Endif
Endif

If !Empty((cSUD)->UD_ASSUNTO) .AND. !Empty((cSUD)->UD_OCORREN)
	nTotAss+=1
	nPos := aScan(aTotGerAss, {|x| ALLTRIM(x[1]+x[2])==ALLTRIM((cSUD)->UD_ASSUNTO+(cSUD)->UD_OCORREN)} )
	If nPos == 0
		aAdd(aTotGerAss, {(cSUD)->UD_ASSUNTO,(cSUD)->UD_OCORREN,1} )
	Else
		aTotGerAss[nPos][3]++
	Endif
Endif

Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Tk018ValidºAutor  ³Armando M. Tessaroliº Data ³  25/02/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³   Valida os itens do atendimento de acordo com os parametroº±±
±±º          ³informado para validar se o atendimento sera impresso ou naoº±±
±±º          ³   Valida tambem os itens que serao impressos para o atendi-º±±
±±º          ³mento selecionado.                                          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ TMKR018                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Tk018Valid(cSUC, cSUD)

Local aArea	:= GetArea()
Local lRet	:= .F.

DbSelectArea(cSUD)
DbSetOrder(1)
If DbSeek(xFilial(cSUD)+(cSUC)->UC_CODIGO)
	While	(!Eof())									.AND.;
			(cSUD)->UD_FILIAL == xFilial(cSUC)			.AND.;
			(cSUD)->UD_CODIGO == (cSUC)->UC_CODIGO
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Seleciona o tipo de reclamacao informado                 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !Empty(Mv_Par03) .AND. (cSUD)->UD_OCORREN <> Mv_Par03
			DbSkip()
			Loop
		Endif
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Seleciona o produto  informado                           ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !Empty(Mv_Par05) .AND. (cSUD)->UD_PRODUTO <> Mv_Par05
			DbSkip()
			Loop
		Endif
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Seleciona o tipo de produto informado                    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !Empty(Mv_Par06)
			DbSelectArea("SB1")
			DbSetOrder(1)
			If DbSeek(xFilial("SB1")+(cSUD)->UD_PRODUTO)
				If AllTrim(SB1->B1_TIPO) <> AllTrim(Mv_Par06)
					DbSelectArea(cSUD)
					DbSkip()
					Loop
				Endif
			Endif
		Endif
		
		lRet := .T.
		Exit
	End
Endif

RestArea(aArea)

Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³TKR018RptDef ³ Autor ³Michel W. Mosca     ³ Data ³07/08/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Rotina que define os itens que serao apresentados no relato-³±±
±±³          ³rio de Atendimento receptivo - Ocorrencias.                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Tkr018RptDef()                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±³          ³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ CALL CENTER                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄ|ÄÄÄÄÄÄÄÄ|ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Fernando ³811   |11/10/06|Foi modificada a funcao Tkr018RptDef para   ³±±
±±³			 |		|		 |criacao de string a ser visualizada na opcao³±±
±±³			 |		|		 |Personalizar do relatorio TMKR018           ³±±                               
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄ|ÄÄÄÄÄÄÄÄ|ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/              
Static Function Tkr018RptDef()
Local oReport 				//Objeto relatorio TReport (Release 4)
Local oSection1             //Objeto secao 1 do relatorio (Dados do atendimentos)
Local oSection2             //Objeto secao 2 do relatorio (Itens vendidos)
Local oSection3				//Totalizador por atendimentos
Local oSection4				//Totalizador por ocorrencias
Local oSection5				//Totalizador de ocorrencias executadas por produto
Local oSection6				//Totalizador de ocorrencias executadas por assunto
Local cSUC := "SUC"     	//Alias da consulta Embedded SQL     
Local cSUD := "SUD"     	//Alias da consulta Embedded SQL     
Local aUC_Status	:= TkSx3Box("UC_STATUS")	// Le as opcoes do campo no dd SX3 
Local aUD_Status	:= TkSx3Box("UD_STATUS")	// Le as opcoes do campo no dd SX3


#IFDEF TOP
	cSUC	:= GetNextAlias()						// Pega o proximo Alias Disponivel
	cSUD	:= cSUC
#ENDIF

//"Ligacoes Recebidas - Tipo de Reclamacao " # //"Este programa ira emitir a relacao dos tipos" #
//"de reclamacoes recebidas pelo operador"
DEFINE REPORT oReport NAME "TMKR018" TITLE "Ligacoes Recebidas - Tipo de Reclamacao " PARAMETER "TMK018" ACTION {|oReport| Tkr018PrtRpt( oReport, cSUC, cSUD)} DESCRIPTION "Este programa ira emitir a relacao dos tipos"  + "de reclamacoes recebidas pelo operador"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Define a secao1 do relatorio, informando que o arquivo principal ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DEFINE SECTION oSection1 OF oReport		TITLE "telemarketing" TABLES "SUC"    // telemarketing                      
DEFINE SECTION oSection2 OF oSection1	TITLE "itens do telemarketing" TABLES "SUD"  // itens do telemarketing
DEFINE SECTION oSection3 OF oReport		TITLE "periodo"                 // periodo
DEFINE SECTION oSection4 OF oReport 	TITLE "ocorrencia por atendimento"                 // ocorrencia por atendimento
DEFINE SECTION oSection5 OF oReport 	TITLE "ocorrencia por produto"                 // ocorrencia por produto
DEFINE SECTION oSection6 OF oReport 	TITLE "ocorrencia por assunto"                 // ocorrencia por assunto

DEFINE CELL NAME "" 			OF oSection1 ALIAS "" 		BLOCK {||DToC((cSUC)->UC_DATA) + "  " + (cSUC)->UC_INICIO + " - " + (cSUC)->UC_FIM} TITLE "Data do Atendimento" SIZE 30 //"Data do Atendimento"
DEFINE CELL NAME "" 			OF oSection1 ALIAS "" 		BLOCK {||Posicione("SU5",1,xFilial("SU5")+(cSUC)->UC_CODCONT,"U5_CONTAT")} TITLE "Nome do Contato" SIZE 40  //"Nome do Contato"
DEFINE CELL NAME "UC_CODIGO" 	OF oSection1 ALIAS cSUC
DEFINE CELL NAME "" 			OF oSection1 ALIAS "" 		BLOCK{||Transform(TkDadosContato((cSUC)->UC_CODCONT,4),'@R 9999-9999')} TITLE "Tel. Com.1" SIZE 9
DEFINE CELL NAME "" 			OF oSection1 ALIAS "" 		BLOCK{||Posicione("SU7",1,xFilial("SU7")+(cSUC)->UC_OPERADO,"U7_NREDUZ")} TITLE "Nombre del operador" SIZE 40 
DEFINE CELL NAME "" 			OF oSection1 ALIAS cSUC 	BLOCK{||TkDadosContato((cSUC)->UC_CODCONT,10),40} TITLE "Descricao do Email" SIZE 30 //"Descricao do Email"
DEFINE CELL NAME "" 			OF oSection1 ALIAS cSUC 	BLOCK{||IIF(!Empty((cSUC)->UC_STATUS),aUC_Status[Val((cSUC)->UC_STATUS)],"")} TITLE "Status do Atendimento" SIZE 25  //"Status do Atendimento"
DEFINE CELL NAME "S1_ENTDESC"	OF oSection1 ALIAS cSUC 	TITLE "Descricao da Entidade" SIZE 40 //"Descricao da Entidade"
DEFINE CELL NAME "UC_OPERACA"	OF oSection1 ALIAS cSUC
DEFINE CELL NAME "" 			OF oSection1 ALIAS cSUC 	BLOCK{||TkEntidade((cSUC)->UC_ENTIDAD,(cSUC)->UC_CHAVE,1)} TITLE "Razao Social da Entidade" SIZE 40 //"Razao Social da Entidade"
DEFINE CELL NAME "" 			OF oSection1 ALIAS cSUC 	BLOCK{||(cSUC)->UC_MIDIA + " - " +	Posicione("SUH",1,xFilial("SUH")+(cSUC)->UC_MIDIA,"UH_DESC")} TITLE "Descricao da Midia" SIZE 20 // "Descricao da Midia"
DEFINE CELL NAME "" 			OF oSection1 ALIAS cSUC 	BLOCK{||Transform(TkEntidade((cSUC)->UC_ENTIDAD,(cSUC)->UC_CHAVE,6),'@R 9999-9999')} TITLE "Telefone da Entidade" SIZE 10 //"Telefone da Entidade"
DEFINE CELL NAME "" 			OF oSection1 ALIAS cSUC 	BLOCK{||(cSUC)->UC_TIPO  + " - " + Posicione("SUL",1,xFilial("SUL")+(cSUC)->UC_TIPO,"UL_DESC")} TITLE  "Descricao da Comunicacao" SIZE 20 // "Descricao da Comunicacao"
DEFINE CELL NAME "" 			OF oSection1 ALIAS cSUC 	BLOCK{||TkEntidade((cSUC)->UC_ENTIDAD,(cSUC)->UC_CHAVE,3)} TITLE "Cidade da Entidade" SIZE 25 //"Cidade da Entidade"
DEFINE CELL NAME "" 			OF oSection1 ALIAS cSUC 	BLOCK{||Posicione("SUN",1,xFilial("SUN")+(cSUC)->UC_CODENCE,"UN_DESC")} TITLE "Motivo do Encerramento" SIZE 25 //"Motivo do Encerramento"
DEFINE CELL NAME "" 			OF oSection1 ALIAS cSUC 	BLOCK{||TkEntidade((cSUC)->UC_ENTIDAD,(cSUC)->UC_CHAVE,4)} TITLE "Estado da Entidade" SIZE 25 //"Estado da Entidade"
DEFINE CELL NAME "UC_OBS"		OF oSection1 ALIAS cSUC 	BLOCK{||MSMM((cSUC)->UC_CODOBS)} TITLE "Observacion de la atencion"

DEFINE CELL NAME "UD_ITEM" 		OF oSection2 ALIAS cSUD
DEFINE CELL NAME "S2_PRODDESC"	OF oSection2 ALIAS "" 		TITLE "Asunto"
DEFINE CELL NAME "" 			OF oSection2 ALIAS cSUD 	BLOCK{||Posicione("SB1",1,xFilial("SB1")+(cSUD)->UD_PRODUTO,"B1_DESC")} TITLE "Producto" SIZE 30
DEFINE CELL NAME "" 			OF oSection2 ALIAS cSUD 	BLOCK{||Posicione("SU9",1,xFilial("SU9")+(cSUD)->UD_ASSUNTO+(cSUD)->UD_OCORREN,"U9_DESC")} TITLE "Ocurrencia" SIZE 30
DEFINE CELL NAME "" 			OF oSection2 ALIAS cSUD 	BLOCK{||Posicione("SUQ",1,xFilial("SUQ")+(cSUD)->UD_SOLUCAO,"UQ_DESC")} TITLE "Acc." SIZE 50
DEFINE CELL NAME "S2_AUSER" 	OF oSection2 ALIAS "" 		TITLE "Responsável" SIZE 15 // "Responsável"
DEFINE CELL NAME "UD_DATA" 		OF oSection2 ALIAS cSUD 	
DEFINE CELL NAME "" 			OF oSection2 ALIAS cSUD 	BLOCK{||IIF(!Empty((cSUD)->UD_STATUS),aUD_Status[Val((cSUD)->UD_STATUS)],"")} TITLE "Estat." SIZE 12
DEFINE CELL NAME "UD_DTEXEC" 	OF oSection2 ALIAS cSUD
DEFINE CELL NAME "" 			OF oSection2 ALIAS cSUD
DEFINE CELL NAME "S2_OBS"		OF oSection2 ALIAS "" 		BLOCK{||MSMM((cSUD)->UD_OBS)} TITLE "Observacion de la atencion" 
DEFINE CELL NAME "UD_OBSEXEC"	OF oSection2 ALIAS "" 		BLOCK{||MSMM((cSUD)->UD_CODEXEC)} TITLE "Complemento de la ejecucion" 


DEFINE CELL NAME "S3_DATA" 		OF oSection3 TITLE "Fch." 	SIZE 10
DEFINE CELL NAME "S3_ATIV" 		OF oSection3 TITLE "Activ."	SIZE 10
DEFINE CELL NAME "S3_RECP" 		OF oSection3 TITLE "Receptivos"	SIZE 10

DEFINE CELL NAME "S4_OCORR" 	OF oSection4 TITLE "Ocurrencia"	SIZE 30
DEFINE CELL NAME "S4_TOTAL" 	OF oSection4 TITLE "TOTAL"	SIZE 10
DEFINE CELL NAME "S4_PERC" 		OF oSection4 TITLE "%" 		SIZE 5

DEFINE CELL NAME "S5_OCORR" 	OF oSection5 TITLE "Ocurrencia" 	SIZE 30
DEFINE CELL NAME "S5_PROD"  	OF oSection5 TITLE "Producto"	SIZE 30
DEFINE CELL NAME "S5_TOT" 		OF oSection5 TITLE "TOTAL"	SIZE 10
DEFINE CELL NAME "S5_PERC"		OF oSection5 TITLE "%" 		SIZE 5

DEFINE CELL NAME "S6_ASS" 		OF oSection6 TITLE "Asunto"	SIZE 30
DEFINE CELL NAME "S6_OCORR" 	OF oSection6 TITLE "Ocurrencia"	SIZE 30
DEFINE CELL NAME "S6_TOT" 		OF oSection6 TITLE "TOTAL"	SIZE 10
DEFINE CELL NAME "S6_PERC" 		OF oSection6 TITLE "%"		SIZE 5


Return(oReport) 


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Tkr018PrtRpt ³ Autor ³Michel W. Mosca     ³ Data ³07/08/2006³±±
±±³          ³             ³       ³                    ³      ³          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Rotina responsavel pela impressao do relatorio de           ³±±
±±³          ³Atendimento Receptivo - Ocorrencias                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Tkr018PrtRept(ExpO1,ExpC2,ExpC3)                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpO1 = objeto relatorio                                   ³±±
±±³          ³ ExpC2 = alias da query atual                               ³±±
±±³          ³ ExpC3 = alias da query atual                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Tkr018PrtRpt(oReport, cSUC, cSUD)     
Local oSection1 := oReport:Section(1)		//Objeto secao 1 do relatorio (Cabecalho, campos das tabelas SU2 e SB1)
Local oSection2 := oSection1:Section(1) 	//Objeto secao 2 do relatorio (Itens vendidos)
Local oSection3 := oReport:Section(2)		//Totalizador por atendimentos
Local oSection4 := oReport:Section(3)		//Totalizador por ocorrencias
Local oSection5 := oReport:Section(4)     	//Totalizador de ocorrencias executadas por produto
Local oSection6 := oReport:Section(5)		//Totalizador de ocorrencias executadas por assunto
Local cFiltro	:= ""                      	//String contendo o filtro de busca a ser utilizado com DBF

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Declaracao de variaveis especificas para este relatorio³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local nI			:= 0						// Controle
Local cCodSUC		:= ""						// Manipula a quebra do cabecalho
Local cCodSUD		:= ""						// Manipula a quebra dos itens
Local aTotGerAtend	:= {}						// Totalizacao dos atendimentos ativos e receptivos por data
Local nPosDtAtend
Local aUser		:= {}     
Local aTotGerOcorr	:= {}						// Totalizacao das ocorrencias
Local aTotGerProd	:= {}						// Totalizacao das ocorrencias X produtos
Local aTotGerAss 	:= {}						// Totalizacao das ocorrencias X assunto
Local nTotOcorr		:= 0                        // Total de Ocorrencias
Local nTotProd 		:= 0                        // Total de Produtos
Local nTotAss       := 0                        // Total de Assunto                     
Local nAtivos		:= 0                        // Total de ligacoes ativas
Local nReceptivos	:= 0                        // Total de ligacoes receptivas
Local cCodOcorr     := ""					    // Contem o codigo da Ocorrencia anterior
Local cCodAss       := ""						// Contem o codigo do Assunto anterior
Local lCompart		:= SUC->(FieldPos("UC_CHAORIG")) > 0

#IFDEF TOP 
	Local cTables								//Armazena as tabelas adicionais a serem consultadas
	Local cQuery		:= ""					// Armazena a expressao da query para top
	Local cWhere		:= ""					// Validacao do segmento de negocio para top

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Transforma parametros do tipo Range em expressao SQL para ser utilizada na query ³
	//³Exemplo Word, nao intervalos pre definidos (mais utilizado pelo RH - Ferias)     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	MakeSqlExpr("TMK018")      
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Chamo a funcao que monta a parte da query para validar os segmentos de negocios³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Mv_Par11 == "SA1" .OR. Mv_Par11 == "SUS"
		TKSegmento(	Mv_Par12,	Mv_Par13,	Mv_Par14,	Mv_Par15,;
					Mv_Par16,	Mv_Par17,	Mv_Par18,	Mv_Par19,;
					Mv_Par11,	"",			@cWhere)
	Endif
        
	cTables = "%"
	If !Empty(Mv_Par06)
		cTables += " , " + RetSqlName("SB1") + " SB1"
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Implementa na query a validacao dos segmentos de negocios³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !Empty(cWhere)
		cTables += ", " + RetSqlName(Mv_Par11) + " " + Mv_Par11 
	Endif    
	cTables +="%"

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Implementa na query as condicoes de busca dos dados do relatório³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	cQuery +=	"% SUC.UC_FILIAL = '" + xFilial("SUC") + "' AND" +;
				"		SUC.UC_CODCANC = '' AND" +;
				"		SUC.UC_DATA BETWEEN '" + DtoS(Mv_Par01) + "' AND '" + DtoS(Mv_Par02) + "' AND"

	If Mv_Par20 <> 3 //Ambos
		cQuery += "		(SUC.UC_OPERACA = '" + IIF(Mv_Par20==1,"2","1") + "' OR"
		cQuery += "		SUC.UC_OPERACA = '') AND"
	Endif

	If !Empty(Mv_Par04)
		cQuery += "		SUC.UC_OPERADO = '" + Mv_Par04 + "' AND"
	Endif
	
	If !Empty(Mv_Par10)
		cQuery += "		SUC.UC_CODCONT = '" + Mv_Par10 + "' AND"
	Endif
	
	If !Empty(Mv_Par11)
		cQuery += "		SUC.UC_ENTIDAD = '" + Mv_Par11 + "' AND"
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Seleciono somente chamados que nao sao compartilhamento³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lCompart
		cQuery += "		SUC.UC_CHAORIG = '' AND"
	EndIf

	If (Mv_Par07 <> 1)  // Todas as licacoes
		cQuery += "		(SUC.UC_STATUS = '" + Str(Mv_Par07-1,1) + "' OR"
		cQuery += "		SUC.UC_STATUS = '') AND"
	Endif
                
	cQuery +=	"		SUD.UD_FILIAL = '" + xFilial("SUD") + "' AND" +;
     				"		SUD.UD_CODIGO = SUC.UC_CODIGO AND"
     			
	If !Empty(Mv_Par03)
		cQuery += "		SUD.UD_OCORREN = '" + Mv_Par03 + "' AND"
	Endif
	
	If !Empty(Mv_Par05)
		cQuery += "		SUD.UD_PRODUTO = '" + Mv_Par05 + "' AND"
	Endif
	
	If !Empty(Mv_Par06)
		cQuery +=	"	SB1.B1_FILIAL = '" + xFilial("SB1") + "' AND" +;
					"	SB1.B1_COD = SUD.UD_PRODUTO AND" +;
					"	SB1.B1_TIPO = '" + AllTrim(Mv_Par06) + "' AND" +;
					"	SB1.D_E_L_E_T_ = ' ' AND"
	Endif
     			
	cQuery +=	"		SUD.D_E_L_E_T_ = ' ' AND" +;
				"		SUC.D_E_L_E_T_ = ' ' "

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Implementa na query a validacao dos segmentos de negocios³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !Empty(cWhere)
		cQuery += " AND " + cWhere
	Endif
	cQuery += "%"

	BEGIN REPORT QUERY oSection1
 	BeginSQL alias cSUC       
 		SELECT 	UC_DATA,		UC_INICIO,		UC_FIM,			UC_CODCONT,		UC_FILIAL,
				UC_CODCONT,		UC_OPERADO,		UC_CODCONT,		UC_STATUS,
				UC_ENTIDAD,		UC_CHAVE,		UC_MIDIA, 		UC_TIPO,
				UC_CODENCE,		UC_CODOBS,		UC_OPERACA,		UC_CODIGO, 		
 				UD_ASSUNTO, 	UD_PRODUTO, 	UD_OCORREN, 	UD_SOLUCAO, 
 				UD_OPERADO, 	UD_DATA, 		UD_STATUS,		UD_DTEXEC, 
 				UD_OBS, 		UD_CODEXEC, 	UD_CODIGO, 		UD_ITEM  
 		FROM %table:SUC% SUC, %table:SUD% SUD%exp:cTables%
 		WHERE %exp:cQuery%	
        ORDER BY %order:SUC%
    EndSql    
	END REPORT QUERY oSection1
                                  

#ELSE 

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Utilizar a funcao MakeAdvlExpr, somente quando for utilizar o range de parametros³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	MakeAdvplExpr("TMK018")       
	
	DbSelectArea("SUC")
	DbSetOrder(3)
	oReport:SetMeter(RecCount())
	DbSeek(xFilial("SUC")+DtoS(Mv_Par01), .T.)	
#ENDIF

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Quebra a linha, caso existam muitas colunas³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oSection1:SetLineBreak()
oSection2:SetLineBreak()

While	(!Eof())							.AND.;
		(cSUC)->UC_FILIAL == xFilial("SUC")	.AND.;
		(cSUC)->UC_DATA >= Mv_Par01			.AND.;
		(cSUC)->UC_DATA <= Mv_Par02
	
	oReport:IncMeter()
	
	If oReport:Cancel()
		Exit
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Seleciona o intervalo do CEP Exeto Concorrente que nao tem CEP ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Mv_Par11 <> "AC3"
		cCep := TkEntidade((cSUC)->UC_ENTIDAD,(cSUC)->UC_CHAVE,5)
		If Alltrim(cCep) < Alltrim(Mv_Par08) .OR. Alltrim(cCep) > Alltrim(Mv_Par09)
			DbSkip()
			Loop
		Endif
	Endif
	
	#IFNDEF TOP
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Elimino as ligacoes canceladas                           ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !Empty((cSUC)->UC_CODCANC)
			DbSkip()
			Loop
		Endif
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Seleciona as ligacoes de acordo com o parametro RECEPTIVO/ATIVO/AMBOS³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If Mv_Par20 <> 3 //Ambos  (Nao sera validado o Tipo de Ligacao para a impressao)
			If Mv_Par20 == 1  //Ativo
				If Val((cSUC)->UC_OPERACA) <> ATIVO .OR. Empty((cSUC)->UC_OPERACA) //"2"
					DbSkip()
					Loop
				Endif
			Else           //Receptivo
				If Val((cSUC)->UC_OPERACA) <> RECEPTIVO .OR. Empty((cSUC)->UC_OPERACA) //"1"
					DbSkip()
					Loop
				Endif
			Endif
		Endif
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Seleciono apenas os operadores validos³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !Empty(Mv_Par04) .AND. (cSUC)->UC_OPERADO <> Mv_Par04
			DbSkip()
			Loop
		Endif
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifico o contato                                   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !Empty(Mv_Par10) .AND. (cSUC)->UC_CODCONT <> AllTrim(Mv_Par10)
			DbSkip()
			Loop
		Endif
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Permite a impressao somente da entidade informada        ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !Empty(Mv_Par11) .AND. (cSUC)->UC_ENTIDAD <> Mv_Par11
			DbSkip()
			Loop
		Endif
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Seleciona o status da ligacao informado                  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If Mv_Par07 <> 1  // Todas
			Do Case
				Case Mv_Par07 == 2 // Planejada
					If Val((cSUC)->UC_STATUS) <> PLANEJADA		// 1
						DbSelectarea(cSUC)
						DbSkip()
						Loop
					Endif
					
				Case Mv_Par07 == 3 // Pendente
					If Val((cSUC)->UC_STATUS) <> PENDENTE		// 2
						DbSelectarea(cSUC)
						DbSkip()
						Loop
					Endif
					
				Case Mv_Par07 == 4 // Encerrada
					If VAL((cSUC)->UC_STATUS) <> ENCERRADA		// 3
						DbSelectarea(cSUC)
						DbSkip()
						Loop
					Endif
			EndCase
		Endif
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ VerIfico os parametros referentes aos itens do atendimento ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !Tk018Valid(cSUC, cSUD)
			DbSkip()
			Loop
		Endif
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Nao seleciono chamados que sao compartilhamentos         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lCompart .AND. !Empty((cSUC)->UC_CHAORIG)
			DbSkip()
			Loop
		EndIf
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Chamo a funcao que valida os segmentos de negocios³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If Mv_Par11 == "SA1" .OR. Mv_Par11 == "SUS"
			If !TKSegmento(	Mv_Par12,	Mv_Par13,	Mv_Par14,	Mv_Par15,;
							Mv_Par16,	Mv_Par17,	Mv_Par18,	Mv_Par19,;
							Mv_Par11,	(cSUC)->UC_CHAVE)
				DbSkip()
				Loop
			Endif
		Endif
	#ENDIF
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Comeca a imprimir o relatorio neste ponto³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If cCodSUC <> (cSUC)->UC_CODIGO
	         
		If cCodSUC <> ""
			oSection2:Finish()
			oSection1:Finish()
		EndIf		                   
		cCodSUC := (cSUC)->UC_CODIGO				
		oSection1:Init()
		oSection1:SetLineStyle()
		DbSelectArea("SX5")
		DbSetOrder(1)
		oSection1:Cell("S1_ENTDESC"):SetValue("")
		If DbSeek(xFilial("SX5")+"T5"+(cSUC)->UC_ENTIDAD)
			oSection1:Cell("S1_ENTDESC"):SetValue(X5DESCRI())
		EndIf		
		oSection1:PrintLine() 
		oSection2:Init()
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Acumula os atendimentos Ativos e Receptivos por Data³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If Len(aTotGerAtend) == 0
			aAdd(aTotGerAtend, {,,1})
		Else
			aTotGerAtend[1][3]++	
        Endif                 
        
		nPosDtAtend:= aScan(aTotGerAtend, {|x| x[1]==(cSUC)->UC_DATA}) 
		If nPosDtAtend > 0
			If Val((cSUC)->UC_OPERACA) == ATIVO
				aTotGerAtend[nPosDtAtend][2]++	//ATIVO
			Else
				aTotGerAtend[nPosDtAtend][3]++ 	//RECEPTIVO
		    Endif
		Else
			If Val((cSUC)->UC_OPERACA) == ATIVO
			 	Aadd(aTotGerAtend,{(cSUC)->UC_DATA,1,0 })
			Else
			 	Aadd(aTotGerAtend,{(cSUC)->UC_DATA,0,1 })
		    Endif
		Endif
		
	EndIf 

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Comeca a imprimir os itens do atendimento            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	#IFNDEF TOP
		DbSelectArea(cSUD)
		DbSetOrder(1)
		DbSeek(xFilial(cSUD) + (cSUC)->UC_CODIGO)
		While	(!Eof())								.AND.;
				(cSUD)->UD_FILIAL == xFilial(cSUC)		.AND.;
				(cSUD)->UD_CODIGO == (cSUC)->UC_CODIGO
	#ENDIF
			
                                  
				If !Empty((cSUD)->UD_ASSUNTO)
					DbSelectArea("SX5")
					DbSetORder(1)		// Codigo do Assunto
					If DbSeek(xFilial("SX5")+"T1"+(cSUD)->UD_ASSUNTO)
						oSection2:Cell("S2_PRODDESC"):SetValue(X5DESCRI())
					EndIf
				EndIf     
				
				PswOrder(1)
				aUser := IIF(PswSeek((cSUD)->UD_OPERADO),PswRet(1),{})
				oSection2:Cell("S2_AUSER"):SetValue(IIF(Len(aUser)>0,aUser[1][2],""))
				oSection2:PrintLine()
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Acumula os totalizadores gerais³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If !Empty((cSUD)->UD_OCORREN)
					nTotOcorr+=1
					nPos := aScan(aTotGerOcorr, {|x| x[1]==(cSUD)->UD_OCORREN} )
					If nPos == 0
						aAdd(aTotGerOcorr, {(cSUD)->UD_OCORREN, 1} )
					Else
						aTotGerOcorr[nPos][2]++
					Endif
				Endif
				
				If !Empty((cSUD)->UD_PRODUTO) .AND. !Empty((cSUD)->UD_OCORREN)
					nTotProd+=1
					nPos := aScan(aTotGerProd, {|x| ALLTRIM(x[1]+x[2])==ALLTRIM((cSUD)->UD_OCORREN+(cSUD)->UD_PRODUTO)} )
					If nPos == 0
						aAdd(aTotGerProd, {(cSUD)->UD_OCORREN,(cSUD)->UD_PRODUTO,1} )
					Else
						aTotGerProd[nPos][3]++
					Endif
				Endif
				
				If !Empty((cSUD)->UD_ASSUNTO) .AND. !Empty((cSUD)->UD_OCORREN)
					nTotAss+=1
					nPos := aScan(aTotGerAss, {|x| ALLTRIM(x[1]+x[2])==ALLTRIM((cSUD)->UD_ASSUNTO+(cSUD)->UD_OCORREN)} )
					If nPos == 0
						aAdd(aTotGerAss, {(cSUD)->UD_ASSUNTO,(cSUD)->UD_OCORREN,1} )
					Else
						aTotGerAss[nPos][3]++
					Endif
				Endif
	#IFNDEF TOP
			DbSelectArea(cSUD)
			DbSkip()
		End
	#ENDIF
	
	
	DbSelectArea(cSUC)
	DbSkip()
End 	//Fim-Loop de impressao

If cCodSUC <> ""
	oSection2:Finish()
	oSection1:Finish()
EndIf	   

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Imprimi os totais dos atendimentos ao sair do while³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Len(aTotGerAtend) > 0
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Salta a Pagina para imprimir os totalizadores³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
	oReport:EndPage()
	oReport:SkipLine()
	oReport:PrintText("TOTAL DE ATENDIMENTOS ATIVOS E RECEPTIVOS NO PERÍODO DE  " +; //"TOTAL DE ATENDIMENTOS ATIVOS E RECEPTIVOS NO PERÍODO DE  "  
	 					DTOC(MV_PAR01)+ " - " + (cDia:= Tk_DiaSemana(MV_PAR01,Nil,Nil))+ " ATE " + " " +;  //" ATE "
	 					DTOC(MV_PAR02)+ " - " + (cDia:= Tk_DiaSemana(MV_PAR02,Nil,Nil)) + " -> " +;
	 					Transform(aTotGerAtend[1][3],'@E 999,999'))
	

	oSection3:Init()
	For nI:= 2 To Len(aTotGerAtend)
		oSection3:Cell("S3_DATA"):SetValue(Transform(aTotGerAtend[nI][1],'@ 999,999'))
		oSection3:Cell("S3_ATIV"):SetValue(Transform(aTotGerAtend[nI][2],'@ 999,999'))
		oSection3:Cell("S3_RECP"):SetValue(Transform(aTotGerAtend[nI][3],'@ 999,999'))
		oSection3:PrintLine()
	    nAtivos		+=aTotGerAtend[nI][2]
	    nReceptivos	+=aTotGerAtend[nI][3]
	Next nI	
	oSection3:Cell("S3_DATA"):SetValue("TOTAL" ) //"TOTAL" 
	oSection3:Cell("S3_ATIV"):SetValue(Transform(nAtivos,'@ 999,999'))
	oSection3:Cell("S3_RECP"):SetValue(Transform(nReceptivos,'@ 999,999'))	      
	oSection3:PrintLine()
	oSection3:Finish()
	
	If Len(aTotGerOcorr) > 0
		oSection4:Init()  
		oReport:SkipLine()
		aSort(aTotGerOcorr,,, {|x,y| x[2] > y[2]} )		// Decrescente
        oReport:ThinLine()
        oReport:PrintText("OCORRÊNCIAS COM MAIOR NÚMERO DE ATENDIMENTOS") //"OCORRÊNCIAS COM MAIOR NÚMERO DE ATENDIMENTOS"
        oReport:SkipLine()
		For nI := 1 To Len(aTotGerOcorr)
			oSection4:Cell("S4_OCORR"):SetValue(aTotGerOcorr[nI][1] + " - " + Posicione("SU9",2,xFilial("SU9")+aTotGerOcorr[nI][1],"U9_DESC"))
			oSection4:Cell("S4_TOTAL"):SetValue(Transform(aTotGerOcorr[nI][2],'@ 999,999'))
			oSection4:Cell("S4_PERC"):SetValue(Transform(aTotGerOcorr[nI][2]/nTotOcorr*100, '@ 999.99') + ' %')
			oSection4:PrintLine()
		Next nI         
		oSection4:Finish()
	Endif	
	
	If Len(aTotGerProd) > 0
		aSort(aTotGerProd,,, {|x,y| x[1]+x[2] < y[1]+y[2]} )		 
		oSection5:Init()
		oReport:SkipLine()
		oReport:ThinLine()
		oReport:PrintText("OCORRÊNCIAS EXECUTADAS POR PRODUTO ")  //"OCORRÊNCIAS EXECUTADAS POR PRODUTO "		
		oReport:SkipLine()		
		For nI := 1 To Len(aTotGerProd)
            If cCodOcorr <> aTotGerProd[nI][1]
				oSection5:Cell("S5_OCORR"):SetValue(aTotGerProd[nI][1] + " - " +  Posicione("SU9",2,xFilial("SU9")+aTotGerProd[nI][1],"U9_DESC"))
                oSection5:PrintLine()
				cCodOcorr:= aTotGerProd[nI][1]
				oSection5:Cell("S5_OCORR"):SetValue("")
            Endif
			oSection5:Cell("S5_PROD"):SetValue(aTotGerProd[nI][1] + " - " + Posicione("SB1",1,xFilial("SB1")+aTotGerProd[nI][2],"B1_DESC"))
			oSection5:Cell("S5_TOT"):SetValue(Transform(aTotGerProd[nI][3],'@ 999,999'))
			oSection5:Cell("S5_PERC"):SetValue(Transform(aTotGerProd[nI][3]/nTotProd*100, '@ 999.99') + ' %')
			oSection5:PrintLine()                                                                              
			oSection5:Cell("S5_OCORR"):SetValue("")
			oSection5:Cell("S5_PROD"):SetValue("")
			oSection5:Cell("S5_TOT"):SetValue("") 
			oSection5:Cell("S5_PERC"):SetValue("")			
		Next nI
		oSection5:Finish()
	Endif  

    If Len(aTotGerAss) > 0
    	oSection6:Init()
    	oReport:SkipLine()
    	oReport:ThinLine()
    	oReport:PrintText("OCORRÊNCIAS EXECUTADAS POR ASSUNTO ") 	//"OCORRÊNCIAS EXECUTADAS POR ASSUNTO "
		oReport:SkipLine()
		For nI := 1 To Len(aTotGerAss)
            If cCodAss <> aTotGerAss[nI][1]
				oSection6:Cell("S6_ASS"):SetValue(aTotGerAss[nI][1] + " - " +  Posicione("SX5",1,xFilial("SX5")+"T1"+aTotGerAss[nI][1],"X5_DESCRI"))
				oSection6:PrintLine()
				cCodAss:= aTotGerAss[nI][1]
				oSection6:Cell("S6_ASS"):SetValue("")
            Endif
			oSection6:Cell("S6_OCORR"):SetValue(aTotGerAss[nI][2] + " - " + Posicione("SU9",2,xFilial("SU9")+aTotGerAss[nI][2],"U9_DESC"))
			oSection6:Cell("S6_TOT"):SetValue(Transform(aTotGerAss[nI][3],'@ 999,999'))
			oSection6:Cell("S6_PERC"):SetValue(Transform(aTotGerAss[nI][3]/nTotAss*100, '@ 999.99') + ' %')			
			oSection6:PrintLine()			                                                                  
			oSection6:Cell("S6_ASS"):SetValue("")
			oSection6:Cell("S6_OCORR"):SetValue("")
			oSection6:Cell("S6_TOT"):SetValue("")
			oSection6:Cell("S6_PERC"):SetValue("")			
		Next nI 
		oSection6:Finish()
    Endif	
	
EndIf 


Return(.T.)



/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa   ³ CriaSX1   ³ Autor ³Geraldo Felix Junior. ³ Data ³ 03.02.05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao  ³ Atualiza SX1                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/

Static Function CriaSX1()

Local aRegs := {}
LOCAL cPerg := "TMK018"

If  ! SX1->(msSeek(cPerg+"21"))
                               
                aadd(aRegs,{cPerg,"21","Num. Ligacao de?","","","mv_ch2","C", 6,0,0,"G","","mv_par21","","","","","","","","","","","","","","","","","","","","","","","","","XSUC",""}) 
                aadd(aRegs,{cPerg,"22","Num. Ligacao ate?","","","mv_ch2","C",6,0,0,"G","","mv_par22","","","","","","","","","","","","","","","","","","","","","","","","","XSUC",""})              
                
                ValidPerg(aRegs,cPerg,.T.) 
Endif
    
Return


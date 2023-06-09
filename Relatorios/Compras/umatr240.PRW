#include "rwmake.ch"
#INCLUDE 'MATR240.CH'

/*
�����������������������������������������������������������������������������
���Fun��o    � UMATR240 � Autor �  Alexandro Dias       � Data � 24/01/02 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Saldos em Estoques                                         ���
�����������������������������������������������������������������������������
*/
User Function UMATR240()

Local Tamanho    := 'M'
Local Titulo     := STR0001 // 'Saldos em Estoque'
Local cDesc1     := STR0002 // "Este programa ira' emitir um resumo dos saldos, em quantidade,"
Local cDesc2     := STR0003 // 'dos produtos em estoque.'
Local cDesc3     := ''
Local cString    := 'SB1'
Local aOrd       := {OemToAnsi(STR0004),OemToAnsi(STR0005),OemToAnsi(STR0006),OemToAnsi(STR0007)} // ' Por Codigo         '###' Por Tipo           '###' Por Descricao    '###' Por Grupo        '
Local WnRel      := 'MATR240'

//� Variaveis tipo Private padrao de todos os relatorios         �
Private aReturn    := {OemToAnsi(STR0008), 1,OemToAnsi(STR0009), 2, 2, 1, '',1 } // 'Zebrado'###'Administracao'
Private nLastKey   := 0

// Private cPerg      := 'MTR240'
// FPADR(cPerg, cArq, cCampo, cTipo)  - Para ajustar o tamanho das perguntas no SX1- uso generico
PRIVATE cPerg  	:= U_FPADR( "MTR240","SX1","SX1->X1_GRUPO"," " ) //Fun��o criada por Sandro em 19/11/09.

U_DIPPROC(ProcName(0),U_DipUsr()) // JBS 05/10/2005 - Gravando o nome do Programa no SZU

//� Verifica as perguntas selecionadas                           �
//� Variaveis utilizadas para parametros                                  �
//� mv_par01     // Aglutina por: Almoxarifado / Filial / Empresa         �
//� mv_par02     // Filial de                                             �
//� mv_par03     // Filial ate                                            �
//� mv_par04     // Almoxarifado de                                       �
//� mv_par05     // Almoxarifado ate                                      �
//� mv_par06     // Produto de                                            �
//� mv_par07     // Produto ate                                           �
//� mv_par08     // tipo de                                               �
//� mv_par09     // tipo ate                                              �
//� mv_par10     // grupo de                                              �
//� mv_par11     // grupo ate                                             �
//� mv_par12     // descricao de                                          �
//� mv_par13     // descricao ate                                         �
//� mv_par14     // imprime qtde zeradas                                  �
//� mv_par15     // Saldo a considerar : Atual / Fechamento / Movimento   �
//� mv_par16     // Lista Somente Saldos Negativos                 		  �
//� mv_par17     // Descricao Produto : Cientifica / Generica      		  �

Pergunte(cPerg,.F.)

//� Envia controle para a funcao SETPRINT                        �
WnRel := SetPrint(cString,WnRel,cPerg,@Titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,,Tamanho)
If nLastKey == 27
	Set Filter to
	Return Nil
Endif
SetDefault(aReturn,cString)
If nLastKey == 27
	Set Filter to
	Return Nil
Endif
RptStatus({|lEnd| C240Imp(aOrd,@lEnd,WnRel,Titulo,Tamanho)},Titulo)

Return Nil

/*
�����������������������������������������������������������������������������
���Fun��o    � C240IMP  � Autor � Rodrigo de A. Sartorio� Data � 11.12.95 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Chamada do Relatorio                                       ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � MATR240									    			  ���
�����������������������������������������������������������������������������
*/
Static Function C240Imp(aOrd,lEnd,WnRel,Titulo,Tamanho)

//� Define Variaveis                                             �
Local cRodaTxt   := 'REG(S)'
Local nCntImpr   := 0
Local nTipo      := 0

//� Variaveis locais exclusivas deste programa                   �
Local lImpr      :=.F.
Local nSoma      := 0
Local nSavRec    := 0
Local nTotSoma   := 0
Local nX         := 0
Local nRegM0     := 0
Local nIndB1     := 0
Local nIndB2     := 0
Local nQtdProd   := 0
Local aSalProd   := {}
Local cFilialDe  := ''
Local cQuebra1   := ''
Local cCampo     := ''
Local cMens      := ''
Local aProd      := {}
Local aProd1     := {}
Local aProd2     := {}
Local aProd3     := {}
Local cFilOld    := '��'
Local cCodAnt    := '��'
Local cDesc 
Local lIsCient
Local cPict
If ( cPaisLoc=="CHI" )
	cPict:= "@E 999,999,999,999.99"
Else          
	cPict:= PesqPictQt(If(mv_par15==1,'B2_QATU','B2_QFIM'),16)
Endif

//� Variaveis Private exclusivas deste programa                  �
Private cQuebra2   := ''
Private cCond2     := ''
Private cFiltroB1  := ''
Private cIndB1     := ''
Private aFiliais   := {}
Private cFiltroB2  := ''
Private cIndB2     := ''
Private lContinua  := .T.
Private cNomArqB1  := ''
Private cNomArqB2  := ''

//� Contadores de linha e pagina                                 �
Private Li         := 80
Private m_pag      := 1

//� Inicializa os codigos de caracter Comprimido/Normal da impressora �
nTipo := If(aReturn[4]==1,15,18)

//� Adiciona a ordem escolhida ao Titulo do relatorio          �
If Type('NewHead') #'U'
	NewHead := AllTrim(NewHead)
	NewHead += ' (' + AllTrim(SubStr(aOrd[aReturn[8]],6,20)) + ')'
Else
	Titulo := AllTrim(Titulo)
	Titulo += ' (' + AllTrim(SubStr(aOrd[aReturn[8]],6,20)) + ')'
EndIf

//� Monta os Cabecalhos                                          �
cCabec1 := OemToAnsi('CODIGO          TP GRUP DESCRICAO                                                    UM FL ALM      QUANTIDADE')
cCabec2 := ''

//-- Alimenta Array com Filiais a serem Pesquizadas
aFiliais := {}
nRegM0   := SM0->(Recno())
SM0->(dbSeek(cEmpAnt, .T.))
Do While !SM0->(Eof()) .And. SM0->M0_CODIGO == cEmpAnt
	If SM0->M0_CODFIL >= mv_par02 .And. SM0->M0_CODFIL <= mv_par03
		aAdd(aFiliais, SM0->M0_CODFIL)
	Endif
	SM0->(dbSkip())
End
SM0->(dbGoto(nRegM0))

//� Processos de Inicia��o dos Arquivos Utilizados               �
//-- SB2 (Saldos em Estoque)
dbSelectArea('SB2')
dbSetOrder(1)
cFiltroB2 := 'B2_COD>="'+mv_par06+'".And.B2_COD<="'+mv_par07+'".And.'
cFiltroB2 += 'B2_LOCAL>="'+mv_par04+'".And.B2_LOCAL<="'+mv_par05+'"'
If !Empty(xFilial('SB2'))
	cFiltroB2 += '.And.B2_FILIAL>="'+mv_par02+'".And.B2_FILIAL<="'+mv_par03+'"'
EndIf
If mv_par01 == 3
	cIndB2 := 'B2_COD + B2_FILIAL + B2_LOCAL'
ElseIf mv_par01 == 2
	cIndB2 := 'B2_FILIAL + B2_COD + B2_LOCAL'
Else
	cIndB2 := 'B2_COD + B2_FILIAL + B2_LOCAL'
EndIf	
cNomArqB2 := Left(CriaTrab('',.F.),7) + 'a'
IndRegua('SB2',cNomArqB2,cIndB2,,cFiltroB2,'Selecionando Registros...')
nIndB2 := RetIndex('SB2')
#IFNDEF TOP
	dbSetIndex(cNomArqB2 + OrdBagExt())
#ENDIF
dbSetOrder(nIndB2 + 1)
dbGoTop()

//-- SB1 (Produtos)
dbSelectArea('SB1')
dbSetOrder(aReturn[8])
cFiltroB1 := 'B1_COD>="'+mv_par06+'".And.B1_COD<="'+mv_par07+'".And.'
cFiltroB1 += 'B1_TIPO>="'+mv_par08+'".And.B1_TIPO<="'+mv_par09+'".And.'
cFiltroB1 += 'B1_GRUPO>="'+mv_par10+'".And.B1_GRUPO<="'+mv_par11+'"'
If !Empty(xFilial('SB1'))
	cFiltroB1 += '.And.B1_FILIAL>="'+mv_par02+'".And.B1_FILIAL<="'+mv_par03+'"'
EndIf
If aReturn[8] == 4
	cIndB1 := 'B1_GRUPO+B1_COD+B1_FILIAL'
	cCampo := 'B1_GRUPO'
	cMens  := OemToAnsi(STR0012) // 'Grupo.........'
ElseIf aReturn[8] == 3
	cIndB1 := 'B1_DESC+B1_COD+B1_FILIAL'
	cCampo := .T.
ElseIf aReturn[8] == 2
	cIndB1 := 'B1_TIPO+B1_COD+B1_FILIAL'
	cCampo := 'B1_TIPO'
	cMens  := OemToAnsi(STR0011) // 'Tipo..........'
Else
	cIndB1 := 'B1_COD+B1_FILIAL'
	cCampo := .T.
Endif
cNomArqB1 := Left(CriaTrab('',.F.),7) + 'b'
IndRegua('SB1',cNomArqB1,cIndB1,,cFiltroB1,'Selecionando Registros...')
nIndB1 := RetIndex('SB1')
#IFNDEF TOP
	dbSetIndex(cNomArqB1 + OrdBagExt())
#ENDIF
dbSetOrder(nIndB1 + 1)
dbGoTop()
SetRegua(LastRec())
cFilialDe := If(Empty(xFilial('SB2')),xFilial('SB2'),mv_par02)
If aReturn[8] == 4
	dbSeek(mv_par10, .T.)
ElseIf aReturn[8] == 3

	//-- Pesquisa Somente se a Descricao For Generica.
	If mv_par17 == 2
		dbSeek(mv_par12, .T.)
	Endif
ElseIf aReturn[8] == 2
	dbSeek(mv_par08, .T.)
Else
	dbSeek(mv_par06, .T.)
Endif

//-- 1� Looping no Arquivo Principal (SB1)
Do While !SB1->(Eof()) .and. lContinua
	aProd  := {}
	aProd1 := {}

	//� Verifica se imprime nome cientifico do produto. Se Sim    �
	//� verifica se existe registro no SB5 e se nao esta vazio    �
	cDesc := SB1->B1_DESC
	lIsCient := .F.
	If mv_par17 == 1
		dbSelectArea("SB5")
		dbSeek(xFilial()+SB1->B1_COD)
		If Found() .and. !Empty(B5_CEME)
			cDesc := B5_CEME
			lIsCient := .T.
		EndIf
		dbSelectArea('SB1')
	Endif
	
	//-- Consiste Descri��o De/At�
	If cDesc < mv_par12 .Or. cDesc > mv_par13
		SB1->(dbSkip())
		Loop
	EndIf
	
	//-- Filtro do usuario
	If !Empty(aReturn[7]) .And. !&(aReturn[7])
		SB1->(dbSkip())
		Loop
	EndIf
	If lEnd
		@ PROW()+1, 001 pSay OemToAnsi(STR0013) // 'CANCELADO PELO OPERADOR'
		Exit
	EndIf
	cQuebra1 := If(aReturn[8]==1.Or.aReturn[8]==3,.T.,&(cCampo))
	
	//-- 2� Looping no Arquivo Principal (SB1)
	Do While !SB1->(Eof()) .And. (cQuebra1 == If(aReturn[8]==1.Or.aReturn[8]==3,.T.,&(cCampo))) .And. lContinua

		//-- Incrementa R�gua
		IncRegua()
		lImpr := .F.

		//� Verifica se imprime nome cientifico do produto. Se Sim    �
		//� verifica se existe registro no SB5 e se nao esta vazio    �
		cDesc := SB1->B1_DESC
		lIsCient := .F.
		If mv_par17 == 1
			dbSelectArea("SB5")
			dbSeek(xFilial()+SB1->B1_COD)
			If Found() .and. !Empty(B5_CEME)
				cDesc := B5_CEME
				lIsCient := .T.
			EndIf
			dbSelectArea('SB1')
		Endif
		
		//-- Consiste Descri��o De/At�
		If cDesc < mv_par12 .Or. cDesc > mv_par13
			SB1->(dbSkip())
			Loop
		EndIf
		
		//-- Filtro do usuario
		If !Empty(aReturn[7]) .And. !&(aReturn[7])
			SB1->(dbSkip())
			Loop
		EndIf
		For nX := 1 to Len(aFiliais)
			IF !lContinua
				Exit
			Endif
			
			//� Localiza produto no Cadastro de ACUMULADOS DO ESTOQUE        �
			dbSelectArea('SB2')
			If mv_par01 == 3
				dbSeek(SB1->B1_COD + If(Empty(xFilial('SB2')),xFilial('SB2'),aFiliais[nX]), .T.)
			ElseIf mv_par01 == 2
				dbSeek(If(Empty(xFilial('SB2')),xFilial('SB2'),aFiliais[nX]) + SB1->B1_COD, .T.)
			Else
				dbSeek(SB1->B1_COD + If(Empty(xFilial('SB2')),xFilial('SB2'),aFiliais[nX]) + mv_par04, .T.)
			EndIf
			
			//-- 1� Looping no Arquivo Secund�rio (SB2)
			Do While lContinua .And. !SB2->(Eof()) .And. B2_COD == SB1->B1_COD
				If mv_par01 == 3
					If Empty(xFilial('SB1'))
						cQuebra2  := B2_COD
						cCond2	 := 'B2_COD == cQuebra2'
					Else
						cQuebra2  := B2_COD + B2_FILIAL
						cCond2	 := 'B2_COD + B2_FILIAL == cQuebra2'
					EndIf	
				ElseIf mv_par01 == 2
					cQuebra2 := B2_FILIAL + B2_COD
					cCond2   := 'B2_FILIAL + B2_COD == cQuebra2'					
				Else
					cQuebra2 := B2_COD + B2_FILIAL + B2_LOCAL
					cCond2   := 'B2_COD + B2_FILIAL + B2_LOCAL == cQuebra2'
				EndIf
				
				//-- N�o deixa o mesmo Filial/Produto passar mais de 1 vez
				If Len(aProd) <= 4096
					If Len(aProd) == 0 .Or. Len(aProd[Len(aProd)]) == 4096
						aAdd(aProd, {})
					EndIf
					If aScan(aProd[Len(aProd)], cQuebra2) > 0
						SB2->(dbSkip())
						Loop
					Else
						aAdd(aProd[Len(aProd)], cQuebra2)
					EndIf
				Else
					If Len(aProd1) == 0 .Or. Len(aProd1[Len(aProd1)]) == 4096
						aAdd(aProd1, {})
					EndIf
					If aScan(aProd1[Len(aProd1)], cQuebra2) > 0
						SB2->(dbSkip())
						Loop
					Else
						aAdd(aProd1[Len(aProd1)], cQuebra2)
					EndIf					
				EndIf

				//-- 2� Looping no Arquivo Secund�rio (SB2)
				Do While lContinua .And. !SB2->(Eof()) .And. &(cCond2)
					If aReturn[8] == 2 //-- Tipo
						If SB1->B1_TIPO #fContSB1(SB2->B2_FILIAL, SB2->B2_COD, 'B1_TIPO')
							SB2->(dbSkip())
							Loop
						EndIf
					ElseIf aReturn[8] == 4 //-- Grupo
						If SB1->B1_GRUPO #fContSB1(SB2->B2_FILIAL, SB2->B2_COD, 'B1_GRUPO')
							SB2->(dbSkip())
							Loop
						EndIf
					EndIf
					If !Empty(SB2->B2_FILIAL)

						//-- Posiciona o SM0 na Filial Correta
						If SM0->(dbSeek(cEmpAnt+SB2->B2_FILIAL, .F.))

							//-- Atualiza a Variavel utilizada pela fun��o xFilial()
							If !(cFilAnt==SM0->M0_CODFIL)
								cFilAnt := SM0->M0_CODFIL
							EndIf	
						EndIf
					EndIf
					If lEnd
						@ PROW()+1, 001 pSay OemToAnsi(STR0013) // 'CANCELADO PELO OPERADOR'
						lContinua := .F.
						Exit
					EndIf

					//� Carrega array com dados do produto na data base.             �
					IF mv_par15 > 2

						//-- Verifica se o SM0 esta posicionado na Filial Correta
						If !Empty(SB2->B2_FILIAL) .And. !(cFilAnt==SB2->B2_FILIAL)
							aSalProd := {0,0,0,0,0,0,0}
						Else
							aSalProd := CalcEst(SB2->B2_COD,SB2->B2_LOCAL,dDataBase+1)
						EndIf	
					Else
						aSalProd := {0,0,0,0,0,0,0}
					Endif
					
					//� Verifica se devera ser impressa o produto zerado             �
					If(If(mv_par15==1,B2_QATU,If(mv_par15==2,B2_QFIM,aSalProd[1])) == 0 .And. mv_par14 == 2 .Or. ;
						If(mv_par15==1,B2_QATU,If(mv_par15==2,B2_QFIM,aSalProd[1])) > 0  .And. mv_par16 == 1)
						cCodAnt := SB2->B2_COD
						SB2->(dbSkip())
						If mv_par01 == 1 .And. SB2->B2_COD #cCodAnt
							If nQtdProd > 1
								lImpr := .T.
							Else
								nSoma    := 0
								nQtdProd := 0
							EndIf
						EndIf
						Loop
					EndIf
					lImpr := .T.
					If Li > 55
						Cabec(Titulo,cCabec1,cCabec2,WnRel,Tamanho,nTipo)
					EndIf
					
					//� Adiciona 1 ao contador de registros impressos         �
					If mv_par01 == 1
						@ Li, 00 pSay B2_COD
						@ Li, 16 pSay fContSB1(SB2->B2_FILIAL, SB2->B2_COD, 'B1_TIPO')
						@ Li, 19 pSay fContSB1(SB2->B2_FILIAL, SB2->B2_COD, 'B1_GRUPO')
						@ Li, 24 pSay Left(If(lIsCient, cDesc,	fContSB1(SB2->B2_FILIAL, SB2->B2_COD, 'B1_DESC')),60)
						@ Li, 85 pSay fContSB1(SB2->B2_FILIAL, SB2->B2_COD, 'B1_UM')
						@ Li, 88 pSay B2_FILIAL
						@ Li, 91 pSay B2_LOCAL
						@ Li, 94 pSay Transform( If(mv_par15==1,B2_QATU,If(mv_par15==2,B2_QFIM,aSalProd[1])), cPict)
						Li++						
						nQtdProd ++
					EndIf
					nSoma += If(mv_par15==1,B2_QATU,If(mv_par15==2,B2_QFIM,aSalProd[1]))
					nTotSoma += If(mv_par15==1,B2_QATU,If(mv_par15==2,B2_QFIM,aSalProd[1]))
					cFilOld := SB2->B2_FILIAL
					cCodAnt := SB2->B2_COD
					SB2->(dbSkip())
				EndDo
				If lImpr
					If Li > 55
						Cabec(Titulo,cCabec1,cCabec2,WnRel,Tamanho,nTipo)
					EndIf
					If mv_par01 == 1
						If SB2->B2_COD #cCodAnt .And. ;
							(aReturn[8] #2 .And. aReturn[8] # 4)
							If nQtdProd > 1
								@ Li, 54 pSay OemToAnsi(STR0014) + Space(1) + AllTrim(Left(cCodAnt,15)) + Space(1) + Replicate('.',21-Len(AllTrim(Left(cCodAnt,15)))) // 'Total do Produto'
								@ Li, 94 pSay Transform(nSoma, cPict)
								Li += 2
							EndIf	
							nSoma    := 0
							nQtdProd := 0
						EndIf
					Else
						@ Li, 00 pSay cCodAnt
						@ Li, 16 pSay fContSB1(cFilOld, cCodAnt, 'B1_TIPO')
						@ Li, 19 pSay fContSB1(cFilOld, cCodAnt, 'B1_GRUPO')
						@ Li, 24 pSay Left(If(lIsCient, cDesc,	fContSB1(cFilOld, cCodAnt, 'B1_DESC')),60)
						@ Li, 85 pSay fContSB1(cFilOld, cCodAnt, 'B1_UM')
						@ Li, 88 pSay If(mv_par01==2,cFilOld,'**')
						@ Li, 91 pSay SB1->B1_LOCPAD
						@ Li, 94 pSay Transform(nSoma, cPict)
						Li++
						nSoma := 0
					EndIf
					lImpr := .F.
				EndIf
			EndDo
		Next nX
		dbSelectArea('SB1')
		SB1->(dbSkip())
	EndDo
	If Li > 55
		Cabec(Titulo,cCabec1,cCabec2,WnRel,Tamanho,nTipo)
	EndIf
	If (aReturn[8] == 2 .Or. aReturn[8] == 4) .And. ;
		nTotSoma #0
		@ Li, 70 pSay 'Total do ' + cMens
		@ Li, 94 pSay Transform(nTotSoma, cPict)
		Li += 2
		nTotSoma := 0
	EndIf
EndDo
If Li #80
	Roda(nCntImpr,cRodaTxt,Tamanho)
EndIf

//-- Retorna a Posi��o Correta do SM0
SM0->(dbGoto(nRegM0))

//-- Reinicializa o Conteudo da Variavel cFilAnt
If !(cFilAnt==SM0->M0_CODFIL)	
	cFilAnt := SM0->M0_CODFIL
EndIf	

//� Devolve as ordens originais dos arquivos                     �
RetIndex('SB2')
Set Filter to
RetIndex('SB1')
Set Filter to

//� Apaga indices de trabalho                                    �
If File(cNomArqB2 += OrdBagExt())
	fErase(cNomArqB2)
EndIf	
If File(cNomArqB1 += OrdBagExt())
	fErase(cNomArqB1)
EndIf	

//� Devolve a condicao original dos arquivos principal           �
dbSelectArea('SB1')
Set Filter To
dbSetOrder(1)
dbSelectArea('SB2')
Set Filter To
dbSetOrder(1)
If aReturn[5] == 1
	Set Printer To
	dbCommitAll()
	OurSpool(WnRel)
Endif
Ms_Flush()

Return Nil

/*
�����������������������������������������������������������������������������
���Fun��o    � fContSB1 � Autor � Fernando Joly Siquini � Data � 13.10.98 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Procura produto em SB1 e retorna o conteudo do campo       ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � fContSB1( cChave, cCampo)                                  ���
�������������������������������������������������������������������������Ĵ��
���Par�metros� cFil   = Filial de procura                                 ���
���Par�metros� cCod   = Codido de procura                                 ���
���          � cCampo = Campo cujo conte�do se deseja retornar            ���
�����������������������������������������������������������������������������
*/
Static Function fContSB1(cFil, cCod, cCampo)
	
//-- Inicializa Variaveis
Local cCont      := &('SB1->' + cCampo)
Local cPesq      := ''
Local nPos       := 0
Local nOrdem     := SB1->(IndexOrd())
Local nRecno     := SB1->(Recno())
If Empty(xFilial('SB1')) .And. !Empty(cFil)
	cFil := xFilial('SB1')
EndIf
cPesq := cFil + cCod
If cPesq == Nil .Or. cCampo == Nil
	Return cCont
EndIf	
SB1->(dbSetOrder(1))
If SB1->(dbSeek(cPesq, .F.)) .And. (nPos := SB1->(FieldPos(Upper(cCampo)))) > 0
	cCont := SB1->(FieldGet(nPos))
EndIf
SB1->(dbSetOrder(nOrdem))
SB1->(dbGoto(nRecno))

Return cCont
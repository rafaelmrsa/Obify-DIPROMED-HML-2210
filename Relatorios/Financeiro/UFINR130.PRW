/*====================================================================================\
|Programa  | UFINR130      | Autor | Paulo Boschetti            | Data | 01/06/1992   |
|=====================================================================================|
|Descrição | Posição dos Títulos a Receber                                            |
|=====================================================================================|
|Sintaxe   | UFINR130                                                                 |
|=====================================================================================|
|Uso       | Especifico DIPROMED                                                      |
|=====================================================================================|
|........................................Histórico....................................|
|Rafael    | 16/08/04 - Exclusão das colunas Tit. Vlro. Nominal Vlr Juros e Histórico |
|Eriberto  | DD/MM/AA - Descrição                                                     |
\====================================================================================*/

#INCLUDE "RWMAKE.CH"
#INCLUDE "UFINR130.CH"

User function UFINR130()

Local cDesc1 :=OemToAnsi(STR0001)  //"Imprime a posi‡„o dos titulos a receber relativo a data ba-"
Local cDesc2 :=OemToAnsi(STR0002)  //"se do sistema."
Local cDesc3 :=""
Local wnrel
Local cString:="SE1"
Local nRegEmp:=SM0->(RecNo())
Local dOldDtBase := dDataBase

Private titulo  :=""
Private cabec1  :=""
Private cabec2  :=""

Private aLinha  :={}
Private aReturn :={ OemToAnsi(STR0003), 1,OemToAnsi(STR0004), 1, 2, 1, "",1 }  //"Zebrado"###"Administracao"

//Private cPerg	 :="_FN130"
// FPADR(cPerg, cArq, cCampo, cTipo)  - Para ajustar o tamanho das perguntas no SX1- uso generico
PRIVATE cPerg  	:= U_FPADR( "_FN130","SX1","SX1->X1_GRUPO"," " ) //Função criada por Sandro em 19/11/09.

Private aSubTot :={} //-- 27/Out/2011 - D'Leme: Ordenação por valor (descendente) na opção sintético
Private nJuros  :=0
Private nLastKey:=0
Private nomeprog:="_FIR130"
Private tamanho :="G"

U_DIPPROC(ProcName(0),U_DipUsr()) // JBS 05/10/2005 - Gravando o nome do Programa no SZU

/*
Private cCar_001 := " "
Private cCar_002 := " "

@ 126,000 To 320,300 DIALOG oDlg TITLE OemToAnsi("Informe quais carteiras")
@ 010,015 Say "Da carteira:"
@ 025,015 Get cCar_001 Size 5,20 Picture PesqPict("SE1","E1_SITUACA")
@ 040,015 Say "Até a carteira:"
@ 055,015 Get cCar_002 Size 5,20 Picture PesqPict("SE1","E1_SITUACA")
@ 070,050 BmpButton Type 1 Action Close(oDlg)
Activate Dialog oDlg Centered*/

AjustaSX1(cPerg)

pergunte(cPerg,.F.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros   ³
//³ mv_par01		 // Do Cliente 		   ³
//³ mv_par02		 // Ate o Cliente 	   ³
//³ mv_par03		 // Do Prefixo 		   ³
//³ mv_par04		 // Ate o prefixo 	   ³
//³ mv_par05		 // Do Titulo	       ³
//³ mv_par06		 // Ate o Titulo	   ³
//³ mv_par07		 // Do Banco		   ³
//³ mv_par08		 // Ate o Banco		   ³
//³ mv_par09		 // Do Vencimento 	   ³
//³ mv_par10		 // Ate o Vencimento   ³
//³ mv_par11		 // Da Natureza		   ³
//³ mv_par12		 // Ate a Natureza     ³
//³ mv_par13		 // Da Emissao 		   ³
//³ mv_par14		 // Ate a Emissao 	   ³
//³ mv_par15		 // Qual Moeda 		   ³
//³ mv_par16		 // Imprime provisorios³
//³ mv_par17		 // Reajuste pelo vecto³
//³ mv_par18		 // Impr Tit em Descont³
//³ mv_par19		 // Relatorio Anal/Sint³
//³ mv_par20		 // Consid Data Base?  ³
//³ mv_par21		 // Consid Filiais  ?  ³
//³ mv_par22		 // da filial          ³
//³ mv_par23		 // a flial            ³
//³ mv_par24		 // Da loja            ³
//³ mv_par25		 // Ate a loja         ³
//³ mv_par26		 // Consid Adiantam.?  ³
//³ mv_par27		 // Da data contab. ?  ³
//³ mv_par28		 // Ate data contab.?  ³
//³ mv_par29		 // Imprime Nome    ?  ³
//³ mv_par30		 // Outras Moedas   ?  ³
//³ mv_par31       // Imprimir os Tipos  ³
//³ mv_par32       // Nao Imprimir Tipos ³
//³ mv_par33       // Listar abatimentos ³
//³ mv_par34       // Consid. Fluxo Caixa³
//³ mv_par35       // Salt Pag por Client³
//³ mv_par36       // Ignora abatimentos ³
//³ mv_par37       // Data Base          ³
//³ mv_par38       // Verifica Baixa por ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Envia controle para a fun‡„o SETPRINT ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

#IFDEF TOP
	IF TcSrvType() == "AS/400" .and. Select("__SE1") == 0
		ChkFile("SE1",.f.,"__SE1")
	Endif
#ENDIF

wnrel:="UFINR130"            //Nome Default do relatorio em Disco
aOrd :={	OemToAnsi(STR0008),;	//"Por Cliente"
OemToAnsi(STR0009),;	//"Por Prefixo/Numero"
OemToAnsi(STR0010),; //"Por Banco"
OemToAnsi(STR0011),;	//"Por Venc/Cli"
OemToAnsi(STR0012),;	//"Por Natureza"
OemToAnsi(STR0013),; //"Por Emissao"
OemToAnsi(STR0014),;	//"Por Ven\Bco"
OemToAnsi(STR0015),; //"Por Cod.Cli."
OemToAnsi(STR0016),; //"Banco/Situacao"
OemToAnsi(STR0047),; // "Por Numero/Tipo/Prefixo"
OemToAnsi(STR0054),; //"Por Vendedor"
OemToAnsi(STR0055) } //"Por Cliente/Valor"

wnrel:=SetPrint(cString,wnrel,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,,Tamanho)

If nLastKey == 27
	Return
Endif

SetDefault(aReturn,cString)

If nLastKey == 27
	Return
Endif

RptStatus({|lEnd| FA130Imp(@lEnd,wnRel,cString)},titulo)  // Chamada do Relatorio

SM0->(dbGoTo(nRegEmp))
cFilAnt := SM0->M0_CODFIL

//Acerta a database de acordo com a database real do sistema
If mv_par20 == 1    // Considera Data Base
	dDataBase := dOldDtBase
Endif

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ FA130Imp ³ Autor ³ Paulo Boschetti	     ³ Data ³ 01.06.92 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Imprime relat¢rio dos T¡tulos a Receber					     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ FA130Imp(lEnd,WnRel,cString)				      				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ lEnd	  - A‡Æo do Codeblock				            		  ³±±
±±³			 ³ wnRel   - T¡tulo do relat¢rio 						      	  ³±±
±±³			 ³ cString - Mensagem										           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Generico 												              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function FA130Imp(lEnd,WnRel,cString)
Local CbCont
Local CbTxt
Local limite := 220
Local nOrdem
Local lContinua := .T.
Local cCond1,cCond2,cCarAnt
Local nTit0:=0
Local nTit1:=0
Local nTit2:=0
Local nTit3:=0
Local nTit4:=0
Local nTit5:=0
Local nTotJ:=0
Local nTot0:=0
Local nTot1:=0
Local nTot2:=0
Local nTot3:=0
Local nTot4:=0
Local nTotTit:=0
Local nTotJur:=0
Local nTotFil0:=0
Local nTotFil1:=0
Local nTotFil2:=0
Local nTotFil3:=0
Local nTotFil4:=0
Local nTotFilTit:=0
Local nTotFilJ:=0
Local aCampos:={}
Local aTam:={}
Local nAtraso:=0
Local nTotAbat:=0
Local nSaldo:=0
Local dDataReaj
Local dDataAnt := dDataBase
Local lQuebra
Local nMesTit0 := 0
Local nMesTit1 := 0
Local nMesTit2 := 0
Local nMesTit3 := 0
Local nMesTit4 := 0
Local nMesTTit := 0
Local nMesTitj := 0
Local cIndexSe1
Local cChaveSe1
Local nIndexSE1
Local dDtContab
Local cTipos  := ""
Local aStru := SE1->(dbStruct()), ni
Local nTotsRec := SE1->(RecCount())
Local aTamCli := TAMSX3("E1_CLIENTE")

// variavel  abaixo criada p/pegar o nr de casas decimais da moeda
Local ndecs := Msdecimais(mv_par15) 
Local _cDipUsr:= U_DipUsr()
Local cArqExcell:= "\Excell-DBF\"+_cDipUsr+"-UFINR130-CR"   
PRIVATE cDestino:= "C:\EXCELL-DBF\"   
Private nRegSM0 := SM0->(Recno())
Private nAtuSM0 := SM0->(Recno())
PRIVATE dBaixa := dDataBase
PRIVATE cFilDe,cFilAte 

_aCampos := {}
_aTamSX3 := TamSX3("E1_CLIENTE")                          
AAdd(_aCampos ,{"CODIGO", "C",_aTamSX3[1],_aTamSX3[2]})
_aTamSX3 := TamSX3("E1_NOMCLI")                          
AAdd(_aCampos ,{"CLIENTE", "C",_aTamSX3[1],_aTamSX3[2]})
_aTamSX3 := TamSX3("E1_PREFIXO")
AAdd(_aCampos ,{"PREFIXO", "C",_aTamSX3[1],_aTamSX3[2]})
_aTamSX3 := TamSX3("E1_NUM")
AAdd(_aCampos ,{"NUM_PARCEL", "C",_aTamSX3[1],_aTamSX3[2]})
_aTamSX3 := TamSX3("E1_PARCELA")
AAdd(_aCampos ,{"PARCELA", "C",_aTamSX3[1],_aTamSX3[2]})
_aTamSX3 := TamSX3("E1_TIPO")
AAdd(_aCampos ,{"TIPO", "C",_aTamSX3[1],_aTamSX3[2]})
_aTamSX3 := TamSX3("E1_NATUREZ")
AAdd(_aCampos ,{"NATUREZA", "C",_aTamSX3[1],_aTamSX3[2]})
_aTamSX3 := TamSX3("E1_EMISSAO")
AAdd(_aCampos ,{"EMISSAO", "D",_aTamSX3[1],_aTamSX3[2]})
_aTamSX3 := TamSX3("E1_VENCTO")
AAdd(_aCampos ,{"VENCIMENTO", "D",_aTamSX3[1],_aTamSX3[2]})
_aTamSX3 := TamSX3("E1_VENCREA")
AAdd(_aCampos ,{"VENC_REAL", "D",_aTamSX3[1],_aTamSX3[2]})
_aTamSX3 := TamSX3("E1_PORTADO")
AAdd(_aCampos ,{"BANCO", "C",_aTamSX3[1],_aTamSX3[2]})
_aTamSX3 := TamSX3("E1_SITUACA")
AAdd(_aCampos ,{"SITUACAO", "C",_aTamSX3[1],_aTamSX3[2]})
_aTamSX3 := TamSX3("E1_VALOR")
AAdd(_aCampos ,{"VL_ORIGINA", "N",_aTamSX3[1],_aTamSX3[2]})
_aTamSX3 := TamSX3("E1_VALOR")
AAdd(_aCampos ,{"TVENC_VCOR", "N",_aTamSX3[1],_aTamSX3[2]})
_aTamSX3 := TamSX3("E1_VALOR")
AAdd(_aCampos ,{"TAVENC_VLN", "N",_aTamSX3[1],_aTamSX3[2]})
_aTamSX3 := TamSX3("E1_NUMBCO")
AAdd(_aCampos ,{"NUM_BANCO", "C",_aTamSX3[1],_aTamSX3[2]})
AAdd(_aCampos ,{"DIA_ATRASO","N",6,0})

_cArqTrb := CriaTrab(_aCampos,.T.)
DbUseArea(.T.,,_cArqTrb,"TRB1",.F.,.F.)



/*====================================================================================\
| Definição dos cabe‡alhos                                                            |
|====================================================================================*/
titulo := "Posição dos Títulos a Receber"
cabec1 := "Código-Nome do Cliente                                                Prf-Número    TP   Natureza  Data de    Vencto     Vencto      Banco   Valor Original       Tit.Vencidos       Tít. a Vencer   Núm.           Dias"
cabec2 := "                                                                      Parcela                      Emissão    Título     Real                                   Vlr. Corrigido       Valor Nominal   Banco          Atraso"


*0                                                                                                   1                                                                                                   2
*0         1         2         3         4         5         6         7         8         9         0         1         2         3         4         5         6         7         8         9         0         1         2
*01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
*-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*Código-Nome do Cliente                                                Prf-Número    TP   Natureza  Data de    Vencto     Vencto      Banco   Valor Original       Tit.Vencidos       Tít. a Vencer   Núm.           Dias
*                                                                      Parcela                      Emissão    Título     Real                                   Vlr. Corrigido       Valor Nominal   Banco          Atraso
*-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*999999-XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX         XXXXXXXXXXX   XX   XXXXXX    DD/MM/AA   DD/MM/AA   DD/MM/AA    99999   999.999.999,99     999.999.999,99      999.999.999,99   999999999999   9999
**----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*																																																																               999.999.999,99
**----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

/*====================================================================================\
| Ponto de entrada para Filtrar os tipos sem entrar na tela do                        |
| FINRTIPOS(), localizacao Argentina.                                                 |
\====================================================================================*/
IF EXISTBLOCK("F130FILT")
	cTipos	:=	EXECBLOCK("F130FILT",.f.,.f.)
ENDIF

nOrdem:=aReturn[8]
cMoeda:=Str(mv_par15,1)

/*====================================================================================\
| Variáveis utilizadas para Impress„o do Cabe‡alho e Rodapé                           |
|====================================================================================*/
cbtxt 	:= OemtoAnsi(STR0046)
cbcont	:= 1
li 		:= 80
m_pag 	:= 1

/*====================================================================================\
| A função SomaAbat reabre o SE1 com outro nome pela ChkFile para                     |
| efeito de performance. Se o alias auxiliar para a SumAbat() não                     |
| estiver aberto antes da IndRegua, ocorre Erro de & na ChkFile,                      |
| pois o Filtro do SE1 uptrapassa 255 Caracteres.                                     |
\====================================================================================*/
SomaAbat("","","","R")

/*====================================================================================\
| Atribui valores as variaveis ref a filiais                                          |
\====================================================================================*/
If mv_par21 == 2
	cFilDe  := cFilAnt
	cFilAte := cFilAnt
ELSE
	cFilDe := mv_par22	// Todas as filiais
	cFilAte:= mv_par23
Endif

//Acerta a database de acordo com o parametro
If mv_par20 == 1    // Considera Data Base
	dDataBase := mv_par37
Endif

dbSelectArea("SM0")
dbSeek(cEmpAnt+cFilDe,.T.)

nRegSM0 := SM0->(Recno())
nAtuSM0 := SM0->(Recno())

While !Eof() .and. M0_CODIGO == cEmpAnt .and. M0_CODFIL <= cFilAte
	
	dbSelectArea("SE1")
	cFilAnt := SM0->M0_CODFIL
	Set Softseek On
	
	If mv_par19 == 1
		titulo := titulo + OemToAnsi(STR0026)  //" - Analitico"
	Else
		titulo := titulo + OemToAnsi(STR0027)  //" - Sintetico"
		cabec1 := OemToAnsi(STR0044)  //"                                                                                                               |        Titulos Vencidos          | Titulos a Vencer |            Vlr.juros ou             (Vencidos+Vencer)"
		cabec2 := OemToAnsi(STR0045)  //"                                                                                                               |  Valor Nominal   Valor Corrigido |   Valor Nominal  |             permanencia                              "
	EndIf
	                                                      
	#IFDEF TOP
		if TcSrvType() != "AS/400"
			cQuery := "SELECT * "
			cQuery += "  FROM "+	RetSqlName("SE1")
			cQuery += " WHERE E1_FILIAL = '" + xFilial("SE1") + "'"
/*			If !Empty(cCar_002) //("0","1","2","3","6")
				cQuery += " AND E1_SITUACA BETWEEN '" + cCar_001 + "' AND '" + cCar_002 + "'"  // LINHA PARA FILTRAR SOMENTE A CARTEIRA DESEJADA
			EndIf	*/
			cQuery += "   AND D_E_L_E_T_ <> '*' "
		endif
	#ENDIF
	
	IF nOrdem = 1
		cChaveSe1 := "E1_FILIAL+E1_NOMCLI+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO"
		#IFDEF TOP
			if TcSrvType() == "AS/400"
				cIndexSe1 := CriaTrab(nil,.f.)
				IndRegua("SE1",cIndexSe1,cChaveSe1,,Fr130IndR(),OemToAnsi(STR0022))
				nIndexSE1 := RetIndex("SE1")
				dbSetOrder(nIndexSe1+1)
				dbSeek(xFilial("SE1"))
			else
				cOrder := SqlOrder(cChaveSe1)
			endif
		#ELSE
			cIndexSe1 := CriaTrab(nil,.f.)
			IndRegua("SE1",cIndexSe1,cChaveSe1,,Fr130IndR(),OemToAnsi(STR0022))
			nIndexSE1 := RetIndex("SE1")
			dbSetIndex(cIndexSe1+OrdBagExt())
			dbSetOrder(nIndexSe1+1)
			dbSeek(xFilial("SE1"))
		#ENDIF
		cCond1 := "E1_CLIENTE <= mv_par02"
		cCond2 := "E1_CLIENTE + E1_LOJA"
		titulo := titulo + OemToAnsi(STR0017)  //" - Por Cliente"
		
	Elseif nOrdem = 2
		SE1->(dbSetOrder(1))
		#IFNDEF TOP
			dbSeek(cFilial+mv_par03+mv_par05)
		#ELSE
			if TcSrvType() == "AS/400"
				dbSeek(cFilial+mv_par03+mv_par05)
			else
				cOrder := SqlOrder(IndexKey())
			endif
		#ENDIF
		cCond1 := "E1_NUM <= mv_par06"
		cCond2 := "E1_NUM"
		titulo := titulo + OemToAnsi(STR0018)  //" - Por Numero"
	Elseif nOrdem = 3
		SE1->(dbSetOrder(4))
		#IFNDEF TOP
			dbSeek(cFilial+mv_par07)
		#ELSE
			if TcSrvType() == "AS/400"
				dbSeek(cFilial+mv_par07)
			else
				cOrder := SqlOrder(IndexKey())
			endif
		#ENDIF
		cCond1 := "E1_PORTADO <= mv_par08"
		cCond2 := "E1_PORTADO"
		titulo := titulo + OemToAnsi(STR0019)  //" - Por Banco"
	Elseif nOrdem = 4
		SE1->(dbSetOrder(7))
		#IFNDEF TOP
			dbSeek(cFilial+DTOS(mv_par09))
		#ELSE
			if TcSrvType() == "AS/400"
				dbSeek(cFilial+DTOS(mv_par09))
			else
				cOrder := SqlOrder(IndexKey())
			endif
		#ENDIF
		cCond1 := "E1_VENCTO <= mv_par10"
		cCond2 := "E1_VENCTO"
		titulo := titulo + OemToAnsi(STR0020)  //" - Por Data de Vencimento"
	Elseif nOrdem = 5
		SE1->(dbSetOrder(3))
		#IFNDEF TOP
			dbSeek(cFilial+mv_par11)
		#ELSE
			if TcSrvType() == "AS/400"
				dbSeek(cFilial+mv_par11)
			else
				cOrder := SqlOrder(IndexKey())
			endif
		#ENDIF
		cCond1 := "E1_NATUREZ <= mv_par12"
		cCond2 := "E1_NATUREZ"
		titulo := titulo + OemToAnsi(STR0021)  //" - Por Natureza"
	Elseif nOrdem = 6
		SE1->(dbSetOrder(6))
		#IFNDEF TOP
			dbSeek( cFilial+DTOS(mv_par13))
		#ELSE
			if TcSrvType() == "AS/400"
				dbSeek( cFilial+DTOS(mv_par13))
			else
				cOrder := SqlOrder(IndexKey())
			endif
		#ENDIF
		cCond1 := "E1_EMISSAO <= mv_par14"
		cCond2 := "E1_EMISSAO"
		titulo := titulo + OemToAnsi(STR0042)  //" - Por Emissao"
	Elseif nOrdem == 7
		cChaveSe1 := "E1_FILIAL+DTOS(E1_VENCTO)+E1_PORTADO+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO"
		#IFNDEF TOP
			cIndexSe1 := CriaTrab(nil,.f.)
			IndRegua("SE1",cIndexSe1,cChaveSe1,,Fr130IndR(),OemToAnsi(STR0022))
			nIndexSE1 := RetIndex("SE1")
			dbSetIndex(cIndexSe1+OrdBagExt())
			dbSetOrder(nIndexSe1+1)
			dbSeek(xFilial("SE1"))
		#ELSE
			if TcSrvType() == "AS/400"
				cIndexSe1 := CriaTrab(nil,.f.)
				IndRegua("SE1",cIndexSe1,cChaveSe1,,Fr130IndR(),OemToAnsi(STR0022))
				nIndexSE1 := RetIndex("SE1")
				dbSetOrder(nIndexSe1+1)
				dbSeek(xFilial("SE1"))
			else
				cOrder := SqlOrder(cChaveSe1)
			endif
		#ENDIF
		cCond1 := "E1_VENCTO <= mv_par10"
		cCond2 := "DtoS(E1_VENCTO)+E1_PORTADO"
		titulo := titulo + OemToAnsi(STR0023)  //" - Por Vencto/Banco"
	Elseif nOrdem = 8
		SE1->(dbSetOrder(2))
		#IFNDEF TOP
			dbSeek(cFilial+mv_par01,.T.)
		#ELSE
			if TcSrvType() == "AS/400"
				dbSeek(cFilial+mv_par01,.T.)
			else
				cOrder := SqlOrder(IndexKey())
			endif
		#ENDIF
		cCond1 := "E1_CLIENTE <= mv_par02"
		cCond2 := "E1_CLIENTE"
		titulo := titulo + OemToAnsi(STR0024)  //" - Por Cod.Cliente"
	Elseif nOrdem = 9
		cChave := "E1_FILIAL+E1_PORTADO+E1_SITUACA+E1_NOMCLI+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO"
		#IFNDEF TOP
			dbSelectArea("SE1")
			cIndex := CriaTrab(nil,.f.)
			IndRegua("SE1",cIndex,cChave,,fr130IndR(),OemToAnsi(STR0022))
			nIndex := RetIndex("SE1")
			dbSetIndex(cIndex+OrdBagExt())
			dbSetOrder(nIndex+1)
			dbSeek(xFilial("SE1"))
		#ELSE
			if TcSrvType() == "AS/400"
				dbSelectArea("SE1")
				cIndex := CriaTrab(nil,.f.)
				IndRegua("SE1",cIndex,cChave,,fr130IndR(),OemToAnsi(STR0022))
				nIndex := RetIndex("SE1")
				dbSetOrder(nIndex+1)
				dbSeek(xFilial("SE1"))
			else
				cOrder := SqlOrder(cChave)
			endif
		#ENDIF
		cCond1 := "E1_PORTADO <= mv_par08"
		cCond2 := "E1_PORTADO+E1_SITUACA"
		titulo := titulo + OemToAnsi(STR0025)  //" - Por Banco e Situacao"
	ElseIf nOrdem == 10
		cChave := "E1_FILIAL+E1_NUM+E1_TIPO+E1_PREFIXO+E1_PARCELA"
		#IFNDEF TOP
			dbSelectArea("SE1")
			cIndex := CriaTrab(nil,.f.)
			IndRegua("SE1",cIndex,cChave,,,OemToAnsi(STR0022))
			nIndex := RetIndex("SE1")
			dbSetIndex(cIndex+OrdBagExt())
			dbSetOrder(nIndex+1)
			dbSeek(xFilial("SE1")+mv_par05)
		#ELSE
			if TcSrvType() == "AS/400"
				dbSelectArea("SE1")
				cIndex := CriaTrab(nil,.f.)
				IndRegua("SE1",cIndex,cChave,,,OemToAnsi(STR0022))
				nIndex := RetIndex("SE1")
				dbSetOrder(nIndex+1)
				dbSeek(xFilial("SE1")+mv_par05)
			else
				cOrder := SqlOrder(cChave)
			endif
		#ENDIF
		cCond1 := "E1_NUM <= mv_par06"
		cCond2 := "E1_NUM"
		titulo := titulo + OemToAnsi(STR0048)  //" - Numero/Prefixo"
	ElseIf nOrdem = 11
		cChaveSe1 := "E1_FILIAL+E1_VEND1+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO"
		#IFDEF TOP
			if TcSrvType() == "AS/400"
				cIndexSe1 := CriaTrab(nil,.f.)
				IndRegua("SE1",cIndexSe1,cChaveSe1,,Fr130IndR(),OemToAnsi(STR0022))
				nIndexSE1 := RetIndex("SE1")
				dbSetOrder(nIndexSe1+1)
				dbSeek(xFilial("SE1"))
			else
				cOrder := SqlOrder(cChaveSe1)
			endif
		#ELSE
			cIndexSe1 := CriaTrab(nil,.f.)
			IndRegua("SE1",cIndexSe1,cChaveSe1,,Fr130IndR(),OemToAnsi(STR0022))
			nIndexSE1 := RetIndex("SE1")
			dbSetIndex(cIndexSe1+OrdBagExt())
			dbSetOrder(nIndexSe1+1)
			dbSeek(xFilial("SE1"))
		#ENDIF
		cCond1 := "E1_VEND1<=mv_par40 .OR. E1_VEND2<=mv_par40 .OR. E1_VEND3<=mv_par40 .OR. E1_VEND4<=mv_par40 .OR. E1_VEND5 <= mv_par40"  //40
		cCond2 := "E1_VEND1"
		titulo := titulo + OemToAnsi(STR0054)
		
	ElseIf nOrdem = 12
		cChaveSe1 := "E1_FILIAL+E1_NOMCLI+E1_CLIENTE+E1_LOJA+DESCEND(STR(E1_VALOR))"
		#IFDEF TOP
			if TcSrvType() == "AS/400"
				cIndexSe1 := CriaTrab(nil,.f.)
				IndRegua("SE1",cIndexSe1,cChaveSe1,,Fr130IndR(),OemToAnsi(STR0022))
				nIndexSE1 := RetIndex("SE1")
				dbSetOrder(nIndexSe1+1)
				dbSeek(xFilial("SE1"))
			else
				cOrder := "E1_FILIAL, E1_NOMCLI, E1_CLIENTE, E1_LOJA, E1_VALOR DESC"
			endif
		#ELSE
			cIndexSe1 := CriaTrab(nil,.f.)
			IndRegua("SE1",cIndexSe1,cChaveSe1,,Fr130IndR(),OemToAnsi(STR0022))
			nIndexSE1 := RetIndex("SE1")
			dbSetIndex(cIndexSe1+OrdBagExt())
			dbSetOrder(nIndexSe1+1)
			dbSeek(xFilial("SE1"))
		#ENDIF
		cCond1 := "E1_CLIENTE <= mv_par02"
		cCond2 := "E1_CLIENTE + E1_LOJA"
		titulo := titulo + " - " + OemToAnsi(STR0055)  //"Por Cliente/Valor"
	Endif
	
	If mv_par19 == 1
		titulo := titulo + OemToAnsi(STR0026)  //" - Analitico"
	Else
		titulo := titulo + OemToAnsi(STR0027)  //" - Sintetico"
		cabec1 := OemToAnsi(STR0044)  //"Nome do Cliente      |        Titulos Vencidos          | Titulos a Vencer |            Vlr.juros ou             (Vencidos+Vencer)"
		cabec2 := OemToAnsi(STR0045)  //"|  Valor Nominal   Valor Corrigido |   Valor Nominal  |             permanencia                              "
	EndIf
	
	cFilterUser:=aReturn[7]
	Set Softseek Off
	
	#IFDEF TOP
		if TcSrvType() != "AS/400"
			cQuery += " AND E1_CLIENTE between '" + mv_par01        + "' AND '" + mv_par02 + "'"
			cQuery += " AND E1_PREFIXO between '" + mv_par03        + "' AND '" + mv_par04 + "'"
			cQuery += " AND E1_NUM     between '" + mv_par05        + "' AND '" + mv_par06 + "'"
			cQuery += " AND E1_PORTADO between '" + mv_par07        + "' AND '" + mv_par08 + "'"
			cQuery += " AND E1_VENCTO  between '" + DTOS(mv_par09)  + "' AND '" + DTOS(mv_par10) + "'"
			cQuery += " AND (E1_MULTNAT = '1' OR (E1_NATUREZ BETWEEN '"+MV_PAR11+"' AND '"+MV_PAR12+"'))"
			cQuery += " AND E1_EMISSAO between '" + DTOS(mv_par13)  + "' AND '" + DTOS(mv_par14) + "'"
			cQuery += " AND E1_LOJA    between '" + mv_par24        + "' AND '" + mv_par25 + "'"
			cQuery += " AND E1_EMISSAO <=      '" + DTOS(dDataBase) + "'"
			cQuery += " AND ((E1_EMIS1  Between '"+ DTOS(mv_par27)+"' AND '"+DTOS(mv_par28)+"') OR E1_EMISSAO Between '"+DTOS(mv_par27)+"' AND '"+DTOS(mv_par28)+"')"

			If !Empty(mv_par31) // Deseja imprimir apenas os tipos do parametro 31
				cQuery += " AND E1_TIPO IN "+FormatIn(mv_par31,";")
			ElseIf !Empty(Mv_par32) // Deseja excluir os tipos do parametro 32
				cQuery += " AND E1_TIPO NOT IN "+FormatIn(mv_par32,";")
			EndIf
			If mv_par18 == 2
				cQuery += " AND E1_SITUACA NOT IN ('2','7')"
			Endif
			If mv_par20 == 2
				cQuery += ' AND E1_SALDO <> 0'
			Endif
			If mv_par34 == 1
				cQuery += " AND E1_FLUXO <> 'N'"
			Endif
			cQuery += " ORDER BY "+ cOrder
			
			cQuery := ChangeQuery(cQuery)
			
			dbSelectArea("SE1")
			dbCloseArea()
			dbSelectArea("SA1")
			
			dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'SE1', .F., .T.)
			
			For ni := 1 to Len(aStru)
				If aStru[ni,2] != 'C'
					TCSetField('SE1', aStru[ni,1], aStru[ni,2],aStru[ni,3],aStru[ni,4])
				Endif
			Next
		endif
	#ENDIF
	SetRegua(nTotsRec)
	
	If MV_MULNATR .And. nOrdem == 5
		Finr135(cTipos, lEnd, @nTot0, @nTot1, @nTot2, @nTot3, @nTotTit, @nTotJ )
		#IFDEF TOP
			If TcSrvType() != "AS/400"
				dbSelectArea("SE1")
				dbCloseArea()
				ChKFile("SE1")
				dbSelectArea("SE1")
				dbSetOrder(1)
			Endif
		#ENDIF
		dbSelectArea("SM0")
		dbSkip()
		Loop
	Endif
	_cVend:="9a9a9a"  //só para ajuste
	While &cCond1 .and. !Eof() .and. lContinua .and. E1_FILIAL == xFilial("SE1")
		
		IF	lEnd
			@PROW()+1,001 PSAY OemToAnsi(STR0028)  //"CANCELADO PELO OPERADOR"
			Exit
		Endif
		
		IncRegua()
		
		Store 0 To nTit1,nTit2,nTit3,nTit4,nTit5
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Carrega data do registro para permitir ³
		//³ posterior analise de quebra por mes.   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea("SE1")
		
		dDataAnt := Iif(nOrdem == 6 , SE1->E1_EMISSAO,  SE1->E1_VENCTO)
		
		cCarAnt := &cCond2

		While &cCond2==cCarAnt .and. !Eof() .and. lContinua .and. E1_FILIAL == xFilial("SE1")
			
			IF lEnd
				@PROW()+1,001 PSAY OemToAnsi(STR0028)  //"CANCELADO PELO OPERADOR"
				lContinua := .F.
				Exit
			EndIF
			
			IncRegua()
			
			dbSelectArea("SE1")
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Filtrar com base no Pto de entrada do Usuario...             ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄJose Lucas, Localiza‡”es ArgentinaÄÙ
			If !Empty(cTipos)
				If !(SE1->E1_TIPO $ cTipos)
					dbSkip()
					Loop
				Endif
			Endif
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Considera filtro do usuario                                  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If !Empty(cFilterUser).and.!(&cFilterUser)
				dbSkip()
				Loop
			Endif
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica se titulo, apesar do E1_SALDO = 0, deve aparecer ou ³
			//³ nÆo no relat¢rio quando se considera database (mv_par20 = 1) ³
			//³ ou caso nÆo se considere a database, se o titulo foi totalmen³
			//³ te baixado.																  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			dbSelectArea("SE1")
			IF !Empty(SE1->E1_BAIXA) .and. Iif(mv_par20 == 2 ,SE1->E1_SALDO == 0 ,;
				IIF(mv_par38 == 1,(SE1->E1_SALDO == 0 .and. SE1->E1_BAIXA <= dDataBase),.F.))
				dbSkip()
				Loop
			EndIF
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica se trata-se de abatimento ou somente titulos³
			//³ at‚ a data base. 									         ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			IF (SE1->E1_TIPO $ MVABATIM .And. mv_par33 != 1) .Or.;
				SE1->E1_EMISSAO>dDataBase
				dbSkip()
				Loop
			Endif
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica se ser  impresso titulos provis¢rios		   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			IF E1_TIPO $ MVPROVIS .and. mv_par16 == 2
				dbSkip()
				Loop
			Endif
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica se ser  impresso titulos de Adiantamento	 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			IF SE1->E1_TIPO $ MVRECANT .and. mv_par26 == 2
				dbSkip()
				Loop
			Endif
			
			// dDtContab para casos em que o campo E1_EMIS1 esteja vazio
			dDtContab := Iif(Empty(SE1->E1_EMIS1),SE1->E1_EMISSAO,SE1->E1_EMIS1)
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica se esta dentro dos parametros ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			dbSelectArea("SE1")
			IF SE1->E1_CLIENTE < mv_par01 .OR. SE1->E1_CLIENTE > mv_par02 .OR. ;
				SE1->E1_PREFIXO < mv_par03 .OR. SE1->E1_PREFIXO > mv_par04 .OR. ;
				SE1->E1_NUM	 	 < mv_par05 .OR. SE1->E1_NUM 		> mv_par06 .OR. ;
				SE1->E1_PORTADO < mv_par07 .OR. SE1->E1_PORTADO > mv_par08 .OR. ;
				SE1->E1_VENCTO < mv_par09 .OR. SE1->E1_VENCTO > mv_par10 .OR. ;
				SE1->E1_NATUREZ < mv_par11 .OR. SE1->E1_NATUREZ > mv_par12 .OR. ;
				SE1->E1_EMISSAO < mv_par13 .OR. SE1->E1_EMISSAO > mv_par14 .OR. ;
				SE1->E1_LOJA    < mv_par24 .OR. SE1->E1_LOJA    > mv_par25 .OR. ;
				dDtContab       < mv_par27 .OR. dDtContab       > mv_par28 .OR. ;
				SE1->E1_EMISSAO > dDataBase .Or. !&(fr130IndR())
				
				dbSkip()
				Loop
			Endif
			
			If mv_par18 == 2 .and. E1_SITUACA $ "27"
				dbSkip()
				Loop
			Endif
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica se deve imprimir outras moedas³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If mv_par30 == 2 // nao imprime
				if SE1->E1_MOEDA != mv_par15 //verifica moeda do campo=moeda parametro
					dbSkip()
					Loop
				endif
			Endif
			dDataReaj := IIF(SE1->E1_VENCTO < dDataBase ,;
			IIF(mv_par17=1,dDataBase,E1_VENCTO),;
			dDataBase)
			
			If mv_par20 == 1	// Considera Data Base
				nSaldo :=SaldoTit(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,SE1->E1_TIPO,SE1->E1_NATUREZ,"R",SE1->E1_CLIENTE,mv_par15,dDataReaj,,SE1->E1_LOJA,,IIF(mv_par38 == 1,.F.,.T.))
			Else
				nSaldo := xMoeda((SE1->E1_SALDO+SE1->E1_SDACRES-SE1->E1_SDDECRE),SE1->E1_MOEDA,mv_par15,dDataReaj,ndecs+1)
			Endif
			
			If ! SE1->E1_TIPO $ MVABATIM
				If ! (SE1->E1_TIPO $ MVRECANT+"/"+MV_CRNEG) .And. ;
					!( MV_PAR20 == 2 .And. nSaldo == 0 ) .and. mv_par36 == 2 	// deve olhar abatimento pois e zerado o saldo na liquidacao final do titulo
					nSaldo-=SomaAbat(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,"R",mv_par15,dDataReaj,SE1->E1_CLIENTE,SE1->E1_LOJA)
				EndIf
			Endif
			nSaldo:=Round(NoRound(nSaldo,3),2)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Desconsidera caso saldo seja menor ou igual a zero   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If nSaldo <= 0
				dbSkip()
				Loop
			Endif
			
			dbSelectArea("SA1")
			MSSeek(cFilial+SE1->E1_CLIENTE+SE1->E1_LOJA)
			dbSelectArea("SA6")
			MSSeek(cFilial+SE1->E1_PORTADO)
			dbSelectArea("SA3")  // VENDEDOR
			MSSeek(cFilial+SE1->E1_VEND1)
			
			dbSelectArea("SE1")
			
			IF li > 58
				nAtuSM0 := SM0->(Recno())
				SM0->(dbGoto(nRegSM0))
				cabec(titulo,cabec1,cabec2,nomeprog,tamanho,GetMv("MV_COMP"))
				SM0->(dbGoTo(nAtuSM0))
			EndIF
			
			If mv_par19 == 1
				If nOrdem=11
					if _cVend <>SE1->E1_VEND1
						LI ++
						dbSelectArea("SA3")  // VENDEDOR
						MSSeek(cFilial+SE1->E1_VEND1)
						if _cvend<> "9a9a9a"
							@Li,00 PSay __PrtThinLine()
							li++
						endif
						@li,000 PSAY SA3->A3_COD+" - "+SA3->A3_NOME
						dbSelectArea("SE1")
						_cVend:=SE1->E1_VEND1 
						li ++
					endif
				endif
				
//				li++

				@li,	0 PSAY SE1->E1_CLIENTE + "-" + SE1->E1_NOMCLI
				//li := IIf (aTamCli[1] > 6,li+1,li)
				@li, 70 PSAY SE1->E1_PREFIXO+"-"+SE1->E1_NUM+"-"+SE1->E1_PARCELA
				@li, 84 PSAY SE1->E1_TIPO
				@li, 89 PSAY SE1->E1_NATUREZ
				@li, 99 PSAY SE1->E1_EMISSAO
				@li,110 PSAY SE1->E1_VENCTO
				@li,121 PSAY SE1->E1_VENCREA
				@li,133 PSAY SE1->E1_PORTADO+" "+SE1->E1_SITUACA
				@li,141 PSAY xMoeda(SE1->E1_VALOR,SE1->E1_MOEDA,mv_par15,SE1->E1_EMISSAO,ndecs+1) * If(SE1->E1_TIPO$MVABATIM, -1,1) Picture PesqPict("SE1","E1_VALOR",14,MV_PAR15)
				
				DbSelectArea("TRB1")
				RecLock("TRB1",.T.)
				
					TRB1->CODIGO     := SE1->E1_CLIENTE
					TRB1->CLIENTE	 := SE1->E1_NOMCLI
					TRB1->PREFIXO	 := SE1->E1_PREFIXO
					TRB1->NUM_PARCEL := SE1->E1_NUM
					TRB1->PARCELA	 := SE1->E1_PARCELA
					TRB1->TIPO       := SE1->E1_TIPO
					TRB1->NATUREZA   := SE1->E1_NATUREZ
					TRB1->EMISSAO	 := SE1->E1_EMISSAO
					TRB1->VENCIMENTO := SE1->E1_VENCTO
					TRB1->VENC_REAL	 := SE1->E1_VENCREA
					TRB1->BANCO	     := SE1->E1_PORTADO
					TRB1->SITUACAO	 := SE1->E1_SITUACA
	            	TRB1->VL_ORIGINA := xMoeda(SE1->E1_VALOR,SE1->E1_MOEDA,mv_par15,SE1->E1_EMISSAO,ndecs+1) * If(SE1->E1_TIPO$MVABATIM, -1,1)//Picture PesqPict("SE1","E1_VALOR",14,MV_PAR15)
			
			Endif
			
			DbSelectArea("SE1")
			
			If dDataBase > E1_VENCTO	//vencidos
				If mv_par19 == 1
					If !(SE1->E1_TIPO $ MVABATIM)
//						@li, 116 PSAY nSaldo  Picture PesqPict("SE1","E1_SALDO",14,MV_PAR15)
					Endif
				EndIf
				nJuros:=0
				fa070Juros(mv_par15)
				dbSelectArea("SE1")
				If mv_par19 == 1
					If !(SE1->E1_TIPO $ MVABATIM)
						@li,160 PSAY nSaldo+nJuros Picture PesqPict("SE1","E1_SALDO",14,MV_PAR15)
						TRB1->TVENC_VCOR := nSaldo+nJuros //Picture PesqPict("SE1","E1_SALDO",14,MV_PAR15)
					Endif
				EndIf
				If SE1->E1_TIPO $ MVRECANT+"/"+MV_CRNEG
					nTit0 -= xMoeda(SE1->E1_VALOR,SE1->E1_MOEDA,mv_par15,SE1->E1_EMISSAO,ndecs+1)
					nTit1 -= (nSaldo)
					nTit2 -= (nSaldo+nJuros)
					nMesTit0 -= xMoeda(SE1->E1_VALOR,SE1->E1_MOEDA,mv_par15,SE1->E1_EMISSAO,ndecs+1)
					nMesTit1 -= (nSaldo)
					nMesTit2 -= (nSaldo+nJuros)
					nTotJur  -= nJuros
					nMesTitj -= nJuros
					nTotFilJ -= nJuros
				Else
					If !SE1->E1_TIPO $ MVABATIM
						nTit0 += xMoeda(SE1->E1_VALOR,SE1->E1_MOEDA,mv_par15,SE1->E1_EMISSAO,ndecs+1)
						nTit1 += (nSaldo)
						nTit2 += (nSaldo+nJuros)
						nMesTit0 += xMoeda(SE1->E1_VALOR,SE1->E1_MOEDA,mv_par15,SE1->E1_EMISSAO,ndecs+1)
						nMesTit1 += (nSaldo)
						nMesTit2 += (nSaldo+nJuros)
						nTotJur  += nJuros
						nMesTitj += nJuros
						nTotFilJ += nJuros
					Endif
				Endif
			Else						//a vencer
				If mv_par19 == 1
					If !(SE1->E1_TIPO $ MVABATIM)
						@li,180 PSAY nSaldo Picture PesqPict("SE1","E1_SALDO",14,MV_PAR15)
		                TRB1->TAVENC_VLN := nSaldo						
					Endif
				EndIf
				If ! ( SE1->E1_TIPO $ MVRECANT+"/"+MV_CRNEG)
					If !SE1->E1_TIPO $ MVABATIM
						nTit0 += xMoeda(SE1->E1_VALOR,SE1->E1_MOEDA,mv_par15,SE1->E1_EMISSAO,ndecs+1)
						nTit3 += (nSaldo-nTotAbat)
						nTit4 += (nSaldo-nTotAbat)
						nMesTit0 += xMoeda(SE1->E1_VALOR,SE1->E1_MOEDA,mv_par15,SE1->E1_EMISSAO,ndecs+1)
						nMesTit3 += (nSaldo-nTotAbat)
						nMesTit4 += (nSaldo-nTotAbat)
					EndIf
				Else
					nTit0 -= xMoeda(SE1->E1_VALOR,SE1->E1_MOEDA,mv_par15,SE1->E1_EMISSAO,ndecs+1)
					nTit3 -= (nSaldo-nTotAbat)
					nTit4 -= (nSaldo-nTotAbat)
					nMesTit0 -= xMoeda(SE1->E1_VALOR,SE1->E1_MOEDA,mv_par15,SE1->E1_EMISSAO,ndecs+1)
					nMesTit3 -= (nSaldo-nTotAbat)
					nMesTit4 -= (nSaldo-nTotAbat)
				Endif
			Endif
			
			If mv_par19 == 1
				@ li, 197 PSAY SE1->E1_NUMBCO 
   				TRB1->NUM_BANCO	 := SE1->E1_NUMBCO
			EndIf
			If nJuros > 0
				If mv_par19 == 1
//					@ Li,181 PSAY nJuros Picture PesqPict("SE1","E1_JUROS",10,MV_PAR15)
				EndIf
				nJuros := 0
			Endif
			
			IF dDataBase > SE1->E1_VENCTO
				nAtraso:=dDataBase-SE1->E1_VENCTO
				IF Dow(SE1->E1_VENCTO) == 1 .Or. Dow(SE1->E1_VENCTO) == 7
					IF Dow(dBaixa) == 2 .and. nAtraso <= 2
						nAtraso := 0
					EndIF
				EndIF
				nAtraso:=IIF(nAtraso<0,0,nAtraso)
				IF nAtraso>0
					If mv_par19 == 1
						@li ,212 PSAY nAtraso Picture "9999" 
						TRB1->DIA_ATRASO := nAtraso
					EndIf
				EndIF
			EndIF
			If mv_par19 == 1
//				@li,200 PSAY SubStr(SE1->E1_HIST,1,20)+ ;
//				IIF(E1_TIPO $ MVPROVIS,"*"," ")+ ;
//				Iif(nSaldo == xMoeda(E1_VALOR,E1_MOEDA,mv_par15,dDataReaj,ndecs+1)," ","P")
			EndIf
			TRB1->(MsUnLock())
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Carrega data do registro para permitir ³
			//³ posterior an lise de quebra por mes.   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			dDataAnt := Iif(nOrdem == 6, SE1->E1_EMISSAO, SE1->E1_VENCTO)
			dbSkip()
			nTotTit ++
			nMesTTit ++
			nTotFiltit++
			nTit5 ++
			If mv_par19 == 1
				li++
			EndIf
		Enddo
		
		IF nTit5 > 0 .and. nOrdem != 2 .and. nOrdem != 10
			//-- 27/Out/2011 - D'Leme: Ordenação por Valor (descendente) em modo Sintético
			If nOrdem == 12 .And. mv_par19 == 2
				aAdd(aSubTot,{SA1->(Recno()),nTit0,nTit1,nTit2,nTit3,nTit4,nOrdem,cCarAnt,nTotJur})
			Else
				SubTot130(nTit0,nTit1,nTit2,nTit3,nTit4,nOrdem,cCarAnt,nTotJur)
				If mv_par19 == 1
					Li++
				EndIf
			EndIf
		Endif
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica quebra por mˆs	  			   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		lQuebra := .F.
		If nOrdem == 4  .and. (Month(SE1->E1_VENCTO) # Month(dDataAnt) .or. SE1->E1_VENCTO > mv_par10)
			lQuebra := .T.
		Elseif nOrdem == 6 .and. (Month(SE1->E1_EMISSAO) # Month(dDataAnt) .or. SE1->E1_EMISSAO > mv_par14)
			lQuebra := .T.
		Endif
		If lQuebra .and. nMesTTit # 0
			ImpMes130(nMesTit0,nMesTit1,nMesTit2,nMesTit3,nMesTit4,nMesTTit,nMesTitJ)
			nMesTit0 := nMesTit1 := nMesTit2 := nMesTit3 := nMesTit4 := nMesTTit := nMesTitj := 0
		Endif
		nTot0+=nTit0
		nTot1+=nTit1
		nTot2+=nTit2
		nTot3+=nTit3
		nTot4+=nTit4
		nTotJ+=nTotJur
		
		nTotFil0+=nTit0
		nTotFil1+=nTit1
		nTotFil2+=nTit2
		nTotFil3+=nTit3
		nTotFil4+=nTit4
		Store 0 To nTit0,nTit1,nTit2,nTit3,nTit4,nTit5,nTotJur,nTotAbat
	Enddo
	
	dbSelectArea("SE1")		// voltar para alias existente, se nao, nao funciona
	
	//-- 27/Out/2011 - D'Leme: Ordenação por Valor (descendente) em modo Sintético
	If nOrdem == 12 .And. mv_par19 == 2
		aSort(aSubTot,,,{|x,y| x[4]+x[5] > y[4]+y[5] })
		aEval(aSubTot,{|x|	SA1->(DbGoto(x[1])),;
							SubTot130(x[2],x[3],x[4],x[5],x[6],x[7],x[8],x[9]) })
		aSubTot := {}		
	EndIf	
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Imprimir TOTAL por filial somente quan-³
	//³ do houver mais do que 1 filial.        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	if mv_par21 == 1 .and. SM0->(Reccount()) > 1
		ImpFil130(nTotFil0,nTotFil1,nTotFil2,nTotFil3,nTotFil4,nTotFiltit,nTotFilJ)
	Endif
	Store 0 To nTotFil0,nTotFil1,nTotFil2,nTotFil3,nTotFil4,nTotFilTit,nTotFilJ
	If Empty(xFilial("SE1"))
		Exit
	Endif
	
	#IFDEF TOP
		if TcSrvType() != "AS/400"
			dbSelectArea("SE1")
			dbCloseArea()
			ChKFile("SE1")
			dbSelectArea("SE1")
			dbSetOrder(1)
		endif
	#ENDIF
	
	dbSelectArea("SM0")
	dbSkip()
Enddo

SM0->(dbGoTo(nRegSM0))
cFilAnt := SM0->M0_CODFIL
IF li != 80
	IF li > 58
		cabec(titulo,cabec1,cabec2,nomeprog,tamanho,GetMv("MV_COMP"))
	EndIF
	TotGer130(nTot0,nTot1,nTot2,nTot3,nTot4,nTotTit,nTotJ)
	Roda(cbcont,cbtxt,"G")
EndIF

Set Device To Screen

#IFNDEF TOP
	dbSelectArea("SE1")
	dbClearFil(NIL)
	RetIndex( "SE1" )
	If !Empty(cIndexSE1)
		FErase (cIndexSE1+OrdBagExt())
	Endif
	dbSetOrder(1)
#ELSE
	if TcSrvType() != "AS/400"
		dbSelectArea("SE1")
		dbCloseArea()
		ChKFile("SE1")
		dbSelectArea("SE1")
		dbSetOrder(1)
	else
		dbSelectArea("SE1")
		dbClearFil(NIL)
		RetIndex( "SE1" )
		If !Empty(cIndexSE1)
			FErase (cIndexSE1+OrdBagExt())
		Endif
		dbSetOrder(1)
	endif
#ENDIF  

DbSelectArea("TRB1")
TRB1->(dbGotop())
ProcRegua(TRB1->(RECCOUNT()))	
aCols := Array(TRB1->(RECCOUNT()),Len(_aCampos))
nColuna := 0
nLinha := 0
While TRB1->(!Eof())
	nLinha++
	IncProc(OemToAnsi("Gerando planilha excel..."))
	For nColuna := 1 to Len(_aCampos)
		aCols[nLinha][nColuna] := &("TRB1->("+_aCampos[nColuna][1]+")")			
	Next nColuna
	TRB1->(dbSkip())	
EndDo
u_GDToExcel(_aCampos,aCols,Alltrim(FunName()))
 
DbSelectArea("TRB1")

// Gerando arquivo excel - RBorges 17/04/15
COPY TO &cArqExcell VIA "DBFCDX"

MakeDir(cDestino) // CRIA DIRETÓRIO CASO NÃO EXISTA
CpyS2T(cArqExcell+".dbf",cDestino,.T.) // COPIA ARQUIVO PARA MAQUINA DO USUÁRIO

// Buscando e apagando arquivos temporários - MCVN 27/08/10
aTmp := Directory( cDestino+"*.tmp" )
For nI:= 1 to Len(aTmp)
	fErase(cDestino+aTmp[nI,1])
Next nI     

TRB1->(dbCloseArea())  

If aReturn[5] = 1
	Set Printer TO
	dbCommitAll()
	Ourspool(wnrel)
Endif
MS_FLUSH()

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³SubTot130 ³ Autor ³ Paulo Boschetti 		  ³ Data ³ 01.06.92 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Imprimir SubTotal do Relatorio										  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ SubTot130()																  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³																				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso 	    ³ Generico																	  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
STATIC Function SubTot130(nTit0,nTit1,nTit2,nTit3,nTit4,nOrdem,cCarAnt,nTotJur)
LOCAL aSituaca := {OemToAnsi(STR0029),OemToAnsi(STR0030),;  			//"Carteira"###"Simples"
OemToAnsi(STR0031),OemToAnsi(STR0032),OemToAnsi(STR0033),;  //"Descontada"###"Caucionada"###"Vinculada"
OemToAnsi(STR0034),OemToAnsi(STR0035),OemToAnsi(STR0036)}  //"Advogado"###"Judicial"###"Cauc Desc"
If mv_par19 == 1
	li++
EndIf
IF li > 58
	nAtuSM0 := SM0->(Recno())
	SM0->(dbGoto(nRegSM0))
	cabec(titulo,cabec1,cabec2,nomeprog,tamanho,GetMv("MV_COMP"))
	SM0->(dbGoTo(nAtuSM0))
EndIF
If nOrdem = 1
	@li,000 PSAY IIF(mv_par29 == 1,SA1->A1_NREDUZ,SA1->A1_NOME)+" "+SA1->A1_TEL+ " "+Iif(mv_par21==1,cFilAnt,"")
	//ELSEIF nOrdem = 11
	// 	@li,000 PSAY SA3->A3_COD+" - "+SA3->A3_NOME
Elseif nOrdem == 4 .or. nOrdem == 6
	@li,000 PSAY OemToAnsi(STR0037)  // "S U B - T O T A L ----> "
	@li,028 PSAY cCarAnt
	@li,PCOL()+2 PSAY Iif(mv_par21==1,cFilAnt,"  ")
Elseif nOrdem = 3
	@li,000 PSAY OemToAnsi(STR0037)  // "S U B - T O T A L ----> "
	@li,028 PSAY Iif(Empty(SA6->A6_NREDUZ),OemToAnsi(STR0029),SA6->A6_NREDUZ) + " " + Iif(mv_par21==1,cFilAnt,"")
ElseIf nOrdem == 5
	dbSelectArea("SED")
	MsSeek(cFilial+cCarAnt)
	@li,000 PSAY OemToAnsi(STR0037)  // "S U B - T O T A L ----> "
	@li,028 PSAY cCarAnt + " "+ED_DESCRIC + " " + Iif(mv_par21==1,cFilAnt,"")
	dbSelectArea("SE1")
Elseif nOrdem == 7
	@li,000 PSAY OemToAnsi(STR0037)  // "S U B - T O T A L ----> "
	@li,028 PSAY SubStr(cCarAnt,7,2)+"/"+SubStr(cCarAnt,5,2)+"/"+SubStr(cCarAnt,3,2)+" - "+SubStr(cCarAnt,9,3) + " " +Iif(mv_par21==1,cFilAnt,"")
ElseIf nOrdem = 8 .Or. nOrdem == 12
	@li,000 PSAY SA1->A1_COD+" "+SA1->A1_NOME+" "+SA1->A1_TEL + " " + Iif(mv_par21==1,cFilAnt,"")
ElseIf nOrdem = 9
	@li,000 PSAY SubStr(cCarant,1,3)+" "+SA6->A6_NREDUZ + SubStr(cCarant,4,1) + " "+aSituaca[Val(SubStr(cCarant,4,1))+1] + " " + Iif(mv_par21==1,cFilAnt,"")
Endif
If mv_par19 == 1
	@li,141 PSAY nTit0		  Picture PesqPict("SE1","E1_VALOR",14,MV_PAR15)
Endif
//@li,141 PSAY nTit1		  Picture PesqPict("SE1","E1_SALDO",14,MV_PAR15)
@li,160 PSAY nTit2		  Picture PesqPict("SE1","E1_SALDO",14,MV_PAR15)
@li,180 PSAY nTit3		  Picture PesqPict("SE1","E1_SALDO",14,MV_PAR15)
/*If nTotJur > 0
	@li,179 PSAY nTotJur  Picture PesqPict("SE1","E1_JUROS",12,MV_PAR15)
Endif*/
@li,203 PSAY nTit2+nTit3 Picture PesqPict("SE1","E1_SALDO",16,MV_PAR15)
//li++
//@Li,00 PSay __PrtThinLine()
li++
If (nOrdem = 1 .Or. nOrdem == 8) .And. mv_par35 == 1 // Salta pag. por cliente
	cabec(titulo,cabec1,cabec2,nomeprog,tamanho,GetMv("MV_COMP"))
Endif
Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ TotGer130³ Autor ³ Paulo Boschetti       ³ Data ³ 01.06.92 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Imprimir total do relatorio										  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ TotGer130()																  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³																				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico																	  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
STATIC Function TotGer130(nTot0,nTot1,nTot2,nTot3,nTot4,nTotTit,nTotJ)

li++
@li,000 PSAY OemToAnsi(STR0038) //"T O T A L   G E R A L ----> " + " " + Iif(mv_par21==1,cFilAnt,"")
@li,028 PSAY "("+ALLTRIM(STR(nTotTit))+" "+IIF(nTotTit > 1,OemToAnsi(STR0039),OemToAnsi(STR0040))+")"		//"TITULOS"###"TITULO"
If mv_par19 == 1
	@li,141 PSAY nTot0		  Picture PesqPict("SE1","E1_VALOR",14,MV_PAR15)
Endif
//@li,141 PSAY nTot1		  Picture PesqPict("SE1","E1_SALDO",14,MV_PAR15)
@li,160 PSAY nTot2		  Picture PesqPict("SE1","E1_SALDO",14,MV_PAR15)
@li,180 PSAY nTot3		  Picture PesqPict("SE1","E1_SALDO",14,MV_PAR15)
//@li,179 PSAY nTotJ		  Picture PesqPict("SE1","E1_JUROS",12,MV_PAR15)
@li,203 PSAY nTot2+nTot3 Picture PesqPict("SE1","E1_SALDO",16,MV_PAR15)
li++
li++
Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ImpMes130 ³ Autor ³ Vinicius Barreira	  ³ Data ³ 12.12.94 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³IMPRIMIR TOTAL DO RELATORIO - QUEBRA POR MES					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ ImpMes130() 															  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ 																			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Generico 																  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
STATIC Function ImpMes130(nMesTot0,nMesTot1,nMesTot2,nMesTot3,nMesTot4,nMesTTit,nMesTotJ)
li++
IF li > 58
	nAtuSM0 := SM0->(Recno())
	SM0->(dbGoto(nRegSM0))
	cabec(titulo,cabec1,cabec2,nomeprog,tamanho,GetMv("MV_COMP"))
	SM0->(dbGoTo(nAtuSM0))
EndIF
@li,000 PSAY OemToAnsi(STR0041)  //"T O T A L   D O  M E S ---> "
@li,028 PSAY "("+ALLTRIM(STR(nMesTTit))+" "+IIF(nMesTTit > 1,OemToAnsi(STR0039),OemToAnsi(STR0040))+")"  //"TITULOS"###"TITULO"
If mv_par19 == 1
	@li,141 PSAY nMesTot0   Picture PesqPict("SE1","E1_VALOR",14,MV_PAR15)
Endif
//@li,141 PSAY nMesTot1	Picture PesqPict("SE1","E1_SALDO",14,MV_PAR15)
@li,160 PSAY nMesTot2	Picture PesqPict("SE1","E1_SALDO",14,MV_PAR15)
@li,180 PSAY nMesTot3	Picture PesqPict("SE1","E1_SALDO",14,MV_PAR15)
//@li,179 PSAY nMesTotJ	Picture PesqPict("SE1","E1_JUROS",12,MV_PAR15)
@li,203 PSAY nMesTot2+nMesTot3 Picture PesqPict("SE1","E1_SALDO",16,MV_PAR15)
li+=2
Return(.T.)

/*====================================================================================\
|Programa  | ImpFil130     | Autor | Paulo Boschetti            | Data | 01/06/1992   |
|=====================================================================================|
|Descrição | Imprimir total do relatorio                                              |
|=====================================================================================|
|Sintaxe   | ImpFil130                                                                |
|=====================================================================================|
|Uso       | Especifico DIPROMED                                                      |
|=====================================================================================|
|........................................Histórico....................................|
|Rafael    | DD/MM/AA - Descrição                                                     |
|Eriberto  | DD/MM/AA - Descrição                                                     |
\====================================================================================*/

STATIC Function ImpFil130(nTotFil0,nTotFil1,nTotFil2,nTotFil3,nTotFil4,nTotFilTit,nTotFilJ)
li++
IF li > 58
	nAtuSM0 := SM0->(Recno())
	SM0->(dbGoto(nRegSM0))
	cabec(titulo,cabec1,cabec2,nomeprog,tamanho,GetMv("MV_COMP"))
	SM0->(dbGoTo(nAtuSM0))
EndIF
@li,000 PSAY OemToAnsi(STR0043)+" "+Iif(mv_par21==1,cFilAnt,"")  //"T O T A L   F I L I A L ----> "
If mv_par19 == 1
	@li,141 PSAY nTotFil0        Picture PesqPict("SE1","E1_VALOR",14,MV_PAR15)
Endif
//@li,141 PSAY nTotFil1        Picture PesqPict("SE1","E1_SALDO",14,MV_PAR15)
@li,160 PSAY nTotFil2        Picture PesqPict("SE1","E1_SALDO",14,MV_PAR15)
@li,180 PSAY nTotFil3        Picture PesqPict("SE1","E1_SALDO",14,MV_PAR15)
//@li,179 PSAY nTotFilJ		  Picture PesqPict("SE1","E1_JUROS",12,MV_PAR15)
@li,203 PSAY nTotFil2+nTotFil3 Picture PesqPict("SE1","E1_SALDO",16,MV_PAR15)
li+=2
Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³fr130Indr ³ Autor ³ Wagner           	  ³ Data ³ 12.12.94 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Monta Indregua para impressao do relat¢rio						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Generico 																  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
STATIC Function fr130IndR()
Local cStringRESTRICAO
cString := 'E1_FILIAL=="'+xFilial("SE1")+'".And.'
cString += 'E1_CLIENTE>="'+mv_par01+'".and.E1_CLIENTE<="'+mv_par02+'".And.'
cString += 'E1_PREFIXO>="'+mv_par03+'".and.E1_PREFIXO<="'+mv_par04+'".And.'
cString += 'E1_NUM>="'+mv_par05+'".and.E1_NUM<="'+mv_par06+'".And.'
cString += 'DTOS(E1_VENCTO)>="'+DTOS(mv_par09)+'".and.DTOS(E1_VENCTO)<="'+DTOS(mv_par10)+'".And.'
cString += '(E1_MULTNAT == "1" .OR. (E1_NATUREZ>="'+mv_par11+'".and.E1_NATUREZ<="'+mv_par12+'")).And.'
cString += 'DTOS(E1_EMISSAO)>="'+DTOS(mv_par13)+'".and.DTOS(E1_EMISSAO)<="'+DTOS(mv_par14)+'"'
If !Empty(mv_par31) // Deseja imprimir apenas os tipos do parametro 31
	cString += '.And.E1_TIPO$"'+mv_par31+'"'
ElseIf !Empty(Mv_par32) // Deseja excluir os tipos do parametro 32
	cString += '.And.!(E1_TIPO$'+'"'+mv_par32+'")'
EndIf
IF mv_par34 == 1  // Apenas titulos que estarao no fluxo de caixa
	cString += '.And.(E1_FLUXO!="N")'
Endif
//if nOrdem=11  // vendedor
cString += '.And.((E1_VEND1 >= '+'"'+mv_par39+'"'
cString += '.And. E1_VEND1 <= '+'"'+mv_par40+'")'
cString += '.or.(E1_VEND2 >= '+'"'+mv_par39+'"'
cString += '.And. E1_VEND2 <= '+'"'+mv_par40+'")'
cString += '.or.(E1_VEND3 >= '+'"'+mv_par39+'"'
cString += '.And. E1_VEND3 <= '+'"'+mv_par40+'")'
cString += '.or.(E1_VEND4 >= '+'"'+mv_par39+'"'
cString += '.And. E1_VEND4 <= '+'"'+mv_par40+'")'
cString += '.or.(E1_VEND5 >= '+'"'+mv_par39+'"'
cString += '.And. E1_VEND5 <= '+'"'+mv_par40+'"))'

//ENDIF

Return cString

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ AjustaSX1³ Autor ³ Lucas                 ³ Data ³ 11/04/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Verifica as perguntas inclu¡ndo-as caso n„o existam        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Remito .prx                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function AjustaSX1(cPerg)
Local _sAlias	:= Alias()
Local cOrdem
Local aRegs		:= {}


AAdd(aRegs,{"Imprimir Tipos       ","Imprimir Tipos      ","Print Types         ","mv_cho","C",TamSx3("E1_TIPO")[1]*10,0,0,"G","","mv_par31","","","",""      ,"","","","","",""})
AAdd(aRegs,{"Nao Imprimir Tipos   ","No Imprimir Tipos   ","Do not Print Types  ","mv_chp","C",TamSx3("E1_TIPO")[1]*10,0,0,"G","","mv_par32","","","","","","","","","",""})
AAdd(aRegs,{"Lista abatimentos   ?","¨Lista Rebajas     ?","Print Allowwances   ","mv_chq","N",1,0,1,"C","","mv_par33","Sim","Si","Yes","","","Nao","No","No","",""})
AAdd(aRegs,{"Somente Tit.p/Fluxo ?","¨Solo Tit.p/Flujo  ?","Just Bills to C.Flow","mv_chn","N",1,0,2,"C","","mv_par34","Sim","Si","Yes","","","Nao","No","No","",""})
AAdd(aRegs,{"Salta pag.p/Cliente ?","¨Salta pg.p/Cliente?","Eject pg by customer","mv_cho","N",1,0,2,"C","","mv_par35","Sim","Si","Yes","","","Nao","No","No","",""})
AAdd(aRegs,{"Despreza abatimentos?","No lista Abatimentos?","Ignore descounts   ","mv_chr","N",1,0,2,"C","","mv_par36","Sim","Si","Yes","","","Nao","No","No","",""})
AAdd(aRegs,{"Data Base            ","Data de Hoy         ","Base Date           ","mv_chs","D",8,0,0,"G","","mv_par37","","","","'"+Dtoc(dDataBase)+"'","","","","","",""})
AAdd(aRegs,{"Compoe Saldo por     ","Compone Saldo por   ","Arrange Remaider by ","mv_chq","N",1,0,1,"C","","mv_par38","Data de Baixa","Fecha de Cancel.","Posting Date","","","Data de Credito","Fecha de Credito","Credit Date","",""})
AADD(aRegs,{"Do Vendedor          ",""                    ,""                    ,"mv_cht","C",6,0,0,"G","","mv_par39","","","",""      ,"","","","","","","","","","","","","","","","","","","","","SA3",""})
AADD(aRegs,{"Ate o Vendedor ?     ",""                    ,""                    ,"mv_chu","C",6,0,0,"G","","mv_par40","","","","ZZZZZZ","","","","","","","","","","","","","","","","","","","","","SA3",""})

dbSelectArea("SX1")
dbSetOrder(1)

For nX:=1 to Len(aRegs)
	cOrdem := StrZero(nX+30,2)
	If !(MsSeek(cPerg+cOrdem))   //começa so 31
		RecLock("SX1",.T.)
		Replace X1_GRUPO	With cPerg
		Replace X1_ORDEM	With cOrdem
		Replace x1_pergunte	With aRegs[nx][01]
		Replace x1_perspa	With aRegs[nx][02]
		Replace x1_pereng	With aRegs[nx][03]
		Replace x1_variavl	With aRegs[nx][04]
		Replace x1_tipo		With aRegs[nx][05]
		Replace x1_tamanho	With aRegs[nx][06]
		Replace x1_decimal	With aRegs[nx][07]
		Replace x1_presel	With aRegs[nx][08]
		Replace x1_gsc		With aRegs[nx][09]
		Replace x1_valid	With aRegs[nx][10]
		Replace x1_var01	With aRegs[nx][11]
		Replace x1_def01	With aRegs[nx][12]
		Replace x1_defspa1	With aRegs[nx][13]
		Replace x1_defeng1	With aRegs[nx][14]
		Replace x1_cnt01	With aRegs[nx][15]
		Replace x1_var02	With aRegs[nx][16]
		Replace x1_def02	With aRegs[nx][17]
		Replace x1_defspa2	With aRegs[nx][18]
		Replace x1_defeng2	With aRegs[nx][19]
		Replace x1_f3		With aRegs[nx][20]
		Replace x1_grpsxg	With aRegs[nx][21]
		MsUnlock()
	ElseIf cOrdem == "37"  //DataBase
		//Acerto o parametro com a database
		RecLock("SX1",.F.)
		Replace x1_cnt01	With aRegs[nx][15]
		MsUnlock()
	Endif
Next
dbSelectArea(_sAlias)
Return

/*====================================================================================\
|Programa  | FINR130E    | Autor  | Reginaldo Borges, RSB   | Data | 14/04/2015      |
|=====================================================================================|
|Descrição | Gera um relatorio EXCEL dos títulos a receber, conforme a necessidade e  |
|          | e informacoes do usuario nos parâmetros.                                 |
|          |                                                                          |
|=====================================================================================|
|Sintaxe   | FINR130E                                                                |
|=====================================================================================|
|Uso       | Especifico DIPROMED  - Departamento de Financeiro                        |
|=====================================================================================|
|Histórico | 																		  |
\====================================================================================*/

*-------------------------------------*
User Function FINR130E()                
*-------------------------------------*

Local aDados:={}
Local lQuery
Private aReturn :={"Zebrado", 1,"Administracao", 1, 2, 1,"",1}
Private _aCampos:={}
Private cDestino:= "C:\EXCELL-DBF\"
Private _cDipUsr:= U_DipUsr()
Private cQry    := ""
Private aReturn :={"Zebrado", 1,"Administracao", 1, 2, 1,"",1}
Private cString :="SE1"

PRIVATE cPerg  	:= U_FPADR( "UFINR130E","SX1","SX1->X1_GRUPO"," " ) //Função criada RBorges 15/04/15

U_DIPPROC(ProcName(0),U_DipUsr()) //RBorges 15/04/15

_AjustaSX1(cPerg)

If !Pergunte(cPerg,.T.)
	Return
EndIf


Processa({|| lQuery := FQuery()},"Filtrando os Títulos...",,.t.)

If !lQuery
	MsgInfo(;
	"Não encontrado dados que satisfaçam aos"+CHR(13)+CHR(10)+;
	"parametros informados pelo usuario! ","Atenção")
	cQry->(dbCloseArea())
	Return(.T.)
EndIf

cQry->(dbCloseArea())

Return
*----------------------------------*
STATIC FUNCTION FQuery()
*----------------------------------*
Local _x
Local cArqExcell:= "\Excell-DBF\"+_cDipUsr+"-UFINR130E"  
Local _nCount := 0  
Local _lRet := .T.

ProcRegua(15000)
For _x := 1 to 5000
	IncProc( "Preparando os dados... ")
Next


cQry := "SELECT SE1.E1_FILIAL, SE1.E1_EMISSAO,SE1.E1_CLIENTE, SE1.E1_NOMCLI, SE1.E1_LOJA, SE1.E1_VALOR, (SE1.E1_NUM+SE1.E1_PARCELA) AS NF, "
cQry += " SE1.E1_VENCORI, SE1.E1_VENCREA, SE1.E1_BAIXA, SE1.E1_PORTADO, SA3.A3_NOME, SE1.E1_STATUS, SE1.E1_CONTA "
cQry += " FROM " +RetSQLName("SE1")+" SE1, "+RetSqlName('SA3')+" SA3 "
cQry += " WHERE  SE1.E1_FILIAL  = '" + xFilial('SE1') + "'"
cQry += "    AND SA3.A3_FILIAL  = '" + xFilial('SA3') + "'"
cQry += "    AND SE1.E1_VENCREA BETWEEN '"+DTOS(MV_PAR01)+"' AND '"+DTOS(MV_PAR02)+"' "
cQry += "    AND SE1.E1_EMISSAO BETWEEN '"+DTOS(MV_PAR03)+"' AND '"+DTOS(MV_PAR04)+"' "
cQry += "    AND SE1.E1_VEND1   BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR06+"' "
cQry += "    AND SA3.A3_COD = SE1.E1_VEND1 "
cQry += "    AND SE1.D_E_L_E_T_  = ''      "
cQry += "    AND SA3.D_E_L_E_T_  = ''      "

If     MV_PAR07 == 1
	cQry += "    AND SE1.E1_BAIXA   =  ''"  // Imprime não baixados
ElseIf MV_PAR07 == 2
	cQry += "    AND SE1.E1_BAIXA   <> ''"  // Imprime baixados
ElseIf MV_PAR07 == 3
	//	cQry += "    AND SE1.E1_BAIXA   <> ''"  // Comentado para imprimir todos
EndIf

If MV_PAR08 == 1
	cQry += " ORDER BY SE1.E1_EMISSAO"
Else
	cQry += " ORDER BY SE1.E1_NOMCLI"
EndIF


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

TcQuery cQry NEW ALIAS "cQry"

DbSelectArea("cQry")
cQry->(dbGotop())

ProcRegua(15000)
For _x := 1 to 5000
	IncProc( "Classificando Títulos... ")
Next

_aCampos := {}
_aTamSX3 := TamSX3("E1_CLIENTE")                          
AAdd(_aCampos ,{"COD_CLI", "C",_aTamSX3[1],_aTamSX3[2]})
_aTamSX3 := TamSX3("E1_NOMCLI")                          
AAdd(_aCampos ,{"CLIENTE", "C",_aTamSX3[1],_aTamSX3[2]})
_aTamSX3 := TamSX3("E1_LOJA")
AAdd(_aCampos ,{"LOJA", "C",_aTamSX3[1],_aTamSX3[2]})
_aTamSX3 := TamSX3("E1_VALOR")
AAdd(_aCampos ,{"VALOR", "N",_aTamSX3[1],_aTamSX3[2]})
AAdd(_aCampos ,{"N_FISCAL", "C",10,0})
_aTamSX3 := TamSX3("E1_EMISSAO")
AAdd(_aCampos ,{"EMISSAO", "D",_aTamSX3[1],_aTamSX3[2]})
_aTamSX3 := TamSX3("E1_VENCORI")
AAdd(_aCampos ,{"VENCIMENTO", "D",_aTamSX3[1],_aTamSX3[2]})
_aTamSX3 := TamSX3("E1_VENCREA")
AAdd(_aCampos ,{"VENC_REAL", "D",_aTamSX3[1],_aTamSX3[2]})
_aTamSX3 := TamSX3("E1_BAIXA")
AAdd(_aCampos ,{"BAIXA", "D",_aTamSX3[1],_aTamSX3[2]})
_aTamSX3 := TamSX3("A6_NOME")
AAdd(_aCampos ,{"BANCO", "C",_aTamSX3[1],_aTamSX3[2]})
_aTamSX3 := TamSX3("A3_NOME")
AAdd(_aCampos ,{"NOME_VEND", "C",_aTamSX3[1],_aTamSX3[2]})
_aTamSX3 := TamSX3("E1_STATUS")
AAdd(_aCampos ,{"_STATUS", "C",_aTamSX3[1],_aTamSX3[2]})
_aTamSX3 := TamSX3("E1_CONTA")
AAdd(_aCampos ,{"CONTA", "C",_aTamSX3[1],_aTamSX3[2]})

_cArqTrb := CriaTrab(_aCampos,.T.)
DbUseArea(.T.,,_cArqTrb,"TRB",.F.,.F.)


While cQRY->(!Eof())
	
	DbSelectArea("TRB")
		
	RecLock("TRB",.T.)
	
	TRB->COD_CLI    := cQry->E1_CLIENTE
	TRB->CLIENTE	:= cQry->E1_NOMCLI
	TRB->LOJA		:= cQry->E1_LOJA
	TRB->VALOR		:= cQry->E1_VALOR
	TRB->N_FISCAL	:= cQry->NF
	TRB->EMISSAO    := STOD(cQry->E1_EMISSAO)
	TRB->VENCIMENTO := STOD(cQry->E1_VENCORI)
	TRB->VENC_REAL	:= STOD(cQry->E1_VENCREA)
	TRB->BAIXA		:= STOD(cQry->E1_BAIXA)
	TRB->BANCO		:= POSICIONE("SA6",1,xFilial("SA6")+cQry->E1_PORTADO,"A6_NOME")
	TRB->NOME_VEND	:= cQry->A3_NOME
	TRB->_STATUS	:= cQry->E1_STATUS
	TRB->CONTA		:= cQry->E1_CONTA
		
	TRB->(MsUnLock())
	_nCount++
	cQry->(DbSkip())
EndDo

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

// Gerando arquivo excel - RBorges 15/04/15
COPY TO &cArqExcell VIA "DBFCDX"

MakeDir(cDestino) // CRIA DIRETÓRIO CASO NÃO EXISTA
CpyS2T(cArqExcell+".dbf",cDestino,.T.) // COPIA ARQUIVO PARA MAQUINA DO USUÁRIO

// Buscando e apagando arquivos temporários - MCVN 27/08/10
aTmp := Directory( cDestino+"*.tmp" )
For nI:= 1 to Len(aTmp)
	fErase(cDestino+aTmp[nI,1])
Next nI     

If! _nCount > 0
_lRet := .F.

EndIf

TRB->(dbCloseArea())  

Return(_lRet)


/////////////////////////////////////////////////////////////////////////////
Static Function _AjustaSX1(cPerg)
_sAlias := Alias()
dbSelectArea("SX1")
dbSetOrder(1)

aRegs:={}

//------------ Grupo/Ordem/Pergunta/PERGING/PERGESP/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05/F3

aAdd(aRegs,{cPerg,"1","Do  Vencimento Real?","","","mv_ch1","D",8,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"2","Ate Vencimento Real?","","","mv_ch2","D",8,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"3","Da  Emissao        ?","","","mv_ch3","D",8,0,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"4","Ate Emissao        ?","","","mv_ch4","D",8,0,0,"G","","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"5","Do  Vendedor       ?","","","mv_ch5","C",6,0,0,"G","","mv_par05","","","","","","","","","","","","","","","","","","","","","","","","","SA3"})
aAdd(aRegs,{cPerg,"6","Ate Vendedor       ?","","","mv_ch6","C",6,0,0,"G","","mv_par06","","","","","","","","","","","","","","","","","","","","","","","","","SA3"})
aAdd(aRegs,{cPerg,"7","Imprimir Titulos   ?","","","mv_ch7","N",1,0,0,"C","","mv_par07","1-Nao Baixados","","","","","2-Baixados","","","","","3-Ambos","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"8","Ordenar por        ?","","","mv_ch8","N",1,0,0,"C","","mv_par08","1-Emissao","","","","","2-Cliente","","","","","","","","","","","","","","","","","","",""})


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

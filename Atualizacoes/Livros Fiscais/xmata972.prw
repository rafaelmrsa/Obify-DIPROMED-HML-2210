#include "fivewin.ch"
#include "mata972.ch"

/*                              
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MATA972   ºAutor  ³Andreia do Santos   ?Data ? 16/06/00    º±?                      
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³GIA Eletronica - Valida para a Secretaria da Fazenda do Es-  º±?
±±?         ³tado de Sao Paulo vigorando a partir da referencia julho/2000º±?
±±?         ³a Nova GIA, contem em um unico documento as informacoes eco- º±?
±±?         ³nomico-fiscais de 5 documentos em 1: GIA, GIA-ST-11, GINTER, º±?
±±?         ³Zona Franca Manaus/ALC e DIPAM-B. Portaria CAT 46/2000.	   º±?
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ?AP5                                                         º±?
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/                               
User Function XMATA972
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//?Salva a Integridade dos dados de Entrada                     ?
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local aSave:={Alias(),IndexOrd(),Recno()}
      
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//?Define variaveis                                             ?
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local 	nOpc	:=	0         

Local 	oDlg
Local	cTitulo
Local	cText1
Local	cText2
Local	cText3
Local 	aCAP	:=	{STR0001,STR0002,STR0003} //"Confirma"###"Abandona"###"Parƒmetros"             
Local   cTipoNf := ""
Local aD1Imp    := {}
Local aD2Imp    := {}
LOcal nScanPis  := 0
Local cCampoPis := ""
Local nPosPis	:= 0
Local nScanCof	:= 0
Local cCampoCof	:= ""
Local nPosCof	:= 0

Private cPerg	:=	"MTA972"
Private lEnd	:=	.F.
Private cArqCabec
Private cArqCFO               
Private cArqInt               
Private cArqZFM               
Private cArqOcor              
Private cArqIE                
Private cArqIeSt
Private cArqIeSd                
Private cArqDIPAM             
Private cCredAcum            
Private cArqExpt
Private cIndSF3	:= ""  
Private nTipoReg      := 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//?Janela Principal                                             ?
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cTitulo	:=	STR0004 //"Arquivo Magn‚tico"
cText1	:=	STR0005 //"Este programa gera arquivo pr?formatado dos lan‡amentos fiscais"
cText2	:=	STR0006 //"para entrega as Secretarias de Fazenda Estaduais da Guia de  "
cText3	:=	STR0007 //"Informacao e Apuracao do ICMS (GIA )."

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//?Verifica as perguntas selecionadas                           ?
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
AjustaSX1()
Pergunte("MTA972",.T.)

While .T.
	nOpc	:=	0
	DEFINE MSDIALOG oDlg TITLE OemtoAnsi(cTitulo) FROM  165,115 TO 315,525 PIXEL OF oMainWnd
	@ 03, 10 TO 43, 195 LABEL "" OF oDlg  PIXEL
	@ 10, 15 SAY OemToAnsi(cText1) SIZE 180, 8 OF oDlg PIXEL
	@ 20, 15 SAY OemToAnsi(cText2) SIZE 180, 8 OF oDlg PIXEL
	@ 30, 15 SAY OemToAnsi(cText3) SIZE 180, 8 OF oDlg PIXEL
	DEFINE SBUTTON FROM 50, 112 TYPE 5 ACTION (nOpc:=3,oDlg:End()) ENABLE OF oDlg
	DEFINE SBUTTON FROM 50, 141 TYPE 1 ACTION (nOpc:=1,oDlg:End()) ENABLE OF oDlg
	DEFINE SBUTTON FROM 50, 170 TYPE 2 ACTION (nOpc:=2,oDlg:End()) ENABLE OF oDlg
	ACTIVATE MSDIALOG oDlg
	Pergunte(cPerg,.f.)
	Do Case
		Case nOpc==1
			Processa({||a972Processa()},,,@lEnd)
		Case nOpc==3
			Pergunte(cPerg,.t.)
			Loop
	EndCase
	Exit
End


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//?Restaura area                                                ?
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea(aSave[1])
dbSetOrder(aSave[2])
dbGoto(aSave[3])

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ?
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±?
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±?
±±ºFuncao	 ³a972ProcessaºAutor  ³Andreia dos Santos  ?Data ? 19/06/00   º±?
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±?
±±ºDesc.     ?Faz o processamento de forma a montar os arquivos temporariosº±?
±±?         ³para gerar gerar o arquivo texto final.                     	º±?
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±?
±±ºUso       ?MATA972                                                    	º±?
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±?
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±?
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß?
*/
Static Function a972Processa()
LOCAL aApuracao	
Local cRef	:=  ""
Local lRet  := .F.
Local lAglFil :=  (mv_par22 == 1)   // A Variável ?local para ser passada por parâmetro na função a972MontTrab, que ?chamada por outras rotinas.
/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
³Parametros															    ?
³mv_par01 - Data Inicial       ?     									?
³mv_par02 - Data Final         ?   										?  	
³mv_par03 - Tipo de GIA        ? (01-Normal/02-Substitutiva)			?
³mv_par04 - GIA com Movimento  ? (Sim/Nao)								?
³mv_par05 - GIA ja transmitida ? (Sim/Nao)								?
³mv_par06 - Saldo Credor - ST  ?    									?
³mv_par07 - Regime Tributario  ? (01-RPA/02-RES/03-RPA-DISPENSADO)     	?
³mv_par08 - Mes de Referencia  ?      									?
³mv_par09 - Ano de Referencia  ?      									?
³mv_par10 - Mes Ref. Inicial   ?      									?
³mv_par11 - Ano Ref. Inicial   ?      									?
³mv_par12 - Livro Selecionado  ?      									?
³mv_par13 - ICMS Fixado para o periodo?									?
³mv_par14 - Nome do arquivo    ?										?
³mv_par15 - Versão do Validador?										?
³mv_par16 - Versão do Layout   ?    									?
³mv_par17 - Drive Destino                                               ?
³mv_par18 - Filial De                                                   ?
³mv_par19 - Filial Ate                                                  ?
³mv_par20 - NF Transf. Filiais                                          ?
³mv_par21 - Seleciona Filiais?                                          ?
³mv_par22 - Aglutina por CNPJ?                                          ?
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
*/
PRIVATE	dDtIni		:=	mv_par01
PRIVATE	dDtFim		:=	mv_par02
PRIVATE	nTipoGia	:=	mv_par03
PRIVATE	nMoviment	:=	mv_par04	
PRIVATE	nTransmit	:=	mv_par05
PRIVATE	nSaldoST	:=	mv_par06
PRIVATE	nRegime		:=	mv_par07
PRIVATE	nMes		:=	mv_par08
PRIVATE	nAno		:=	mv_par09
PRIVATE	nMesIni		:=	mv_par10
PRIVATE	nAnoIni		:=	mv_par11
PRIVATE	cNrLivro	:=	mv_par12
PRIVATE nICMSFIX	:=	mv_par13
Private cVValid     :=  mv_par15
Private cVLayOut    :=  mv_par16
Private	nHandle
Private lSelFil     :=  ( mv_par21 == 1 )
#IFDEF TOP
	Private	cFilDe		:= Iif (Empty(mv_par18).or. !lSelFil, cFilAnt, mv_par18)
	Private	cFilAte		:= Iif (Empty(mv_par19).or. !lSelFil, cFilAnt, mv_par19)
#ELSE
	Private	cFilDe		:= Iif (Empty(mv_par18), cFilAnt, mv_par18)
	Private	cFilAte		:= Iif (Empty(mv_par19), cFilAnt, mv_par19)
#ENDIF
Private nGeraTransp :=  mv_par20

cRef := strzero(nAno,4)+strzero(nMes,2)
Do Case
		Case nRegime == 2
			If cRef <= "200012"
				lRet := .T.
			EndIf
		Case nRegime == 4
			If cRef >= "200007"
			 	lRet := .T.
			EndIF
		Case cRef >= "200007" .and. cRef <= Substr(DTOS(date()),1,6)	
			 	lRet := .T.
		OtherWise
				MsgInfo(STR0019)
EndCase

If lRet
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//?Le valores das Apuracoes .IC?                             ?
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ			ÄÄÄÄÄÙ
	aApuracao := A970ArqIC(.F.)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//?Monta arquivo de Trabalho                                    ?
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	a972MontTrab(aApuracao,.F.,dDtIni,dDtFim,cNrLivro,nRegime,cFilDe,cFilAte,cVLayOut,lSelFil,lAglFil)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//?Grava arquivo texto                                          ?
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	a972GeraTxt()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//?Fecha arquivo texto                                          ?
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ   
	If nHandle >= 0
		FClose(nHandle)
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//?Apaga arquivos temporarios               ?
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	If File(cArqCabec+GetDBExtension())
		dbSelectArea(cArqCabec)
		dbCloseArea()
		Ferase(cArqCabec+GetDBExtension())
		Ferase(cArqCabec+OrdBagExt())
	Endif

	If File(cArqCFO+GetDBExtension())
		dbSelectArea(cArqCFO)
		dbCloseArea()
		Ferase(cArqCFO+GetDBExtension())
		Ferase(cArqCFO+OrdBagExt())
	Endif

	If File(cArqInt+GetDBExtension())
		dbSelectArea(cArqInt)
		dbCloseArea()
		Ferase(cArqInt+GetDBExtension())
		Ferase(cArqInt+OrdBagExt())
	Endif
	If File(cArqZFM+GetDBExtension())
		dbSelectArea(cArqZFM)
		dbCloseArea()
		Ferase(cArqZFM+GetDBExtension())
		Ferase(cArqZFM+OrdBagExt())
	Endif

	If File(cArqOcor+GetDBExtension())
		dbSelectArea(cArqOcor)
		dbCloseArea()
		Ferase(cArqOcor+GetDBExtension())
		Ferase(cArqOcor+OrdBagExt())
	Endif         

	If File(cArqIE+GetDBExtension())
		dbSelectArea(cArqIE)
		dbCloseArea()
		Ferase(cArqIE+GetDBExtension())
		Ferase(cArqIE+OrdBagExt())
	Endif      
	If File(cArqIeSt+GetDBExtension())
		dbSelectArea(cArqIeSt)
		dbCloseArea()
		Ferase(cArqIeSt+GetDBExtension())
		Ferase(cArqIeSt+OrdBagExt())
	Endif         

	If File(cArqIeSd+GetDBExtension())
		dbSelectArea(cArqIeSd)
		dbCloseArea()
		Ferase(cArqIeSd+GetDBExtension())
		Ferase(cArqIeSd+OrdBagExt())
	Endif         
	If File(cArqExpt+GetDBExtension())
		dbSelectArea(cArqExpt)
		dbCloseArea()
		Ferase(cArqExpt+GetDBExtension())
		Ferase(cArqExpt+OrdBagExt())
	Endif         
	If File(cArqDIPAM+GetDBExtension())
		dbSelectArea(cArqDIPAM)
		dbCloseArea()
		Ferase(cArqDIPAM+GetDBExtension())
		Ferase(cArqDIPAM+OrdBagExt())
	Endif
    If File(cCredAcum+GetDBExtension())
		dbSelectArea(cCredAcum)
		dbCloseArea()
		Ferase(cCredAcum+GetDBExtension())
		Ferase(cCredAcum+OrdBagExt())
	Endif

Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//?Restaura indices                                             ?
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
RetIndex("SF3")
Ferase(cIndSF3+OrdBagExt())

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ?
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±?
±±ÉÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±?
±±ºFunction³A972MontTrabºAutor  ³Andreia dos Santos  ?Data ? 25/07/00   º±?
±±ÌÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±?
±±ºDesc.   ³Armazena as informacoes nos arquivos temporarios para depois  º±?
±±?       ³gerar arquivo texto.                                          º±?
±±ÌÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±?
±±ºUso     ?MATA972                                                      º±?
±±ÈÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±?
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±?
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß?
*/
Static Function a972MontTrab(aApuracao,lRelDIPAM,dDataIni,dDataFim,cNrLivro,nRegime,cFilDe,cFilAte,cVLayOut,lSelFil,lAglFil)
Local cCod_Mun  := ""
Local cFiltro 	:=	""
Local cChave	:=	""  
Local cCGC		:=	""
Local cTipo		:=	""
Local cInscr	:= ""
Local cCodMun	:=	""
Local lZranca	:=	.T.
Local cRefIni	:= ""
Local cCNAE		:= ""
Local cUF       := ""
Local cRef      := ""
Local cQuery    := ""
Local lQuery    := .F.
Local cAliasSF3 := "SF3"
Local cCodMunDp := ""
Local nT        := 0
Local cRe       := ""
Local lConteudo := .F.
Local aStruSF3  := {}
Local nSF3      := 0
Local cMvUF     := GetMV("MV_ESTADO")
Local cCodUf    := "09#11#26"
Local aFilsCalc := {}
Local aApuICM   := {}
Local aApuST    := {}
Local aQ20		:= {}
Local nQtdQ20   := 0
Local nX        := 0
Local nY        := 0       
Local cSubCod   := ""       
Local cD2_Re    := GetMv("MV_RE",,"")	// Campo D2 - Exportacao (Sem Integracao EIC)
Local lD2_Re    := !Empty(cD2_Re)
Local lExibMsgTms	:=	.F.
Local lGeraExp	:= .T.
Local lTms		:=	IntTms () .And. AliasInDic('DT6')
Local cDip11	:= GetNewPar("MV_DIP11","")
Local cDip13	:= GetNewPar("MV_DIP13","")
Local aAreaSm0	:=	SM0->(GetArea ())
Local lStSb		:=	.F.          
Local cIndSF3	:= ""
Local lAntiICM	:= 	Iif(SF3->(FieldPos("F3_VALANTI"))>0,.T.,.F.)
Local lUfPg 	:= GetNewPar("MV_TMSUFPG",.T.)
Local lOcorrGen:= .F.
Local cMv_StUfS:= GetNewPar( "MV_STUFS" , "")
Local cMv_StUf := GetNewPar( "MV_STUF" , "")

Local nCal1     :=0
Local nCal2     :=0
Local nCal3     :=0
Local nPosFil	:=0
Local aSM0		:= {}
Local cPJIEAnt	:= ""
Local n0		:= 0
Local n24Sai    := 0
Local n24Ent    := 0
Local n24Tot    := 0  
Local nPerc     := 0 
Local dIni      := CToD ("//") 
Local dFim      := CToD ("//")
Local acRe		:= {}
Local acRebk	:= {}
Local lCodRSEF	:= SF3->( FieldPos( "F3_CODRSEF" ) ) > 0
Local aFilClone	:= {}
Default aApuracao	:= {}
Default lRelDIPAM	:= .F. 
Default dDataIni	:= dDataBase
Default dDataFim	:= dDataBase       
Default cNrLivro	:= "*"   
Default nRegime		:= 1
Default cFilDe		:= cFilAnt
Default cFilAte 	:= cFilAnt                                               			
Default cVLayOut	:= ""
Default lSelFil  	:= .F.
Default lAglFil		:= .F.

cCredAcum  :=IIf(Type("cCredAcum")<>"U",cCredAcum,"")

If Empty(nGeraTransp)
	nGeraTransp := 2
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
//?Cria arquivos temporarios       ?
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
a972CriaTemp(lRelDIPAM)

If lRelDIPAM
	nAno := Year(dDataIni)
	nMes := Month(dDataIni)
Endif

cRef := StrZero(nAno,4)+StrZero(nMes,2)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
//³Verifica como as filiais serao processadas:?
//? apenas a filial                          ?
//? filial de/ate                            ?
//? filiais selecionadas                     ?
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
If !lSelFil
	cFilDe	:=	cFilAte	:=	cFilAnt
Else
	aFilsCalc := MatFilCalc( lSelFil, , , (lSelfil .and. lAglFil), , 2 )			// Aglutina por CNPJ + I.E.
EndIf

If lSelFil .And. ( Len(aFilsCalc) >= 1 )
	aFilClone := aSort(aFilsCalc, , , { | x,y | x[2] < y[2] } )	
	cFilDe 	:= aFilClone[01][02]
	cFilAte	:= aFilClone[Len(aFilClone)][02]
Endif

DbSelectArea ("SM0")
SM0->(dbSeek (cEmpAnt+cFilDe, .T.))
While !SM0->(Eof ()) .And. FWGrpCompany() == cEmpAnt .And. (SM0->M0_CODFIL<=cFilAte)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Se foram selecionadas as filiais, identifica se a filial posicionada esta selecionada no array?
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lSelFil		
		If ( nPosFil := aScan(aFilsCalc,{|x| Alltrim(x[2]) == Alltrim(SM0->M0_CODFIL)}) ) > 0 .And. aFilsCalc[nPosFil,1]
  	        Aadd(aSM0,{SM0->M0_CODIGO,SM0->M0_CODFIL,SM0->M0_FILIAL,SM0->M0_NOME,SM0->M0_CGC,SM0->M0_INSC})
  		Endif
  	Else
  		Aadd(aSM0,{SM0->M0_CODIGO,SM0->M0_CODFIL,SM0->M0_FILIAL,SM0->M0_NOME,SM0->M0_CGC,SM0->M0_INSC})
  	Endif
   	SM0->(DbSkip ())
EndDo

aSM0 := ASort(aSM0,,,{|x,y| x[5] < y[5] })

For n0 := 1 to Len(aSM0)
	SM0->(dbSeek (aSM0[n0][1]+aSM0[n0][2]))

	cFilAnt		:=	FWGETCODFILIAL       
	
	If Type("cVLayOut")<>"U" .And. ( cVLayOut=="0207" .OR. cVLayOut=="0208" .OR. cVLayOut=="0209" .OR. cVLayOut=="0210")
		cCNAE		:=	"0000000"	//tratamento desta nova versao
	Else
		cCNAE		:=	If(Len(Alltrim(SM0->M0_CNAE))==7,SM0->M0_CNAE,Alltrim(SM0->M0_CNAE)+Replicate("00",7-Len(alltrim(SM0->M0_CNAE))))
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Cabecalho do documento Fiscal - CR=05 ?
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cRefIni	:=	if(nRegime == 2 ,strzero(nAnoIni,4)+strzero(nMesIni,2),"000000") 
		
	//
	#IFDEF TOP
		If TcSrvType() <> "AS/400"
		    cAliasSF3:= "a972MontTrab"
		   	lQuery    := .T.
			aStruSF3  := SF3->(dbStruct())		
			cQuery := "SELECT SF3.F3_FILIAL,SF3.F3_ENTRADA,SF3.F3_DTCANC, "
			cQuery += "SF3.F3_TIPO,SF3.F3_CFO,SF3.F3_ESTADO,SF3.F3_VALCONT,SF3.F3_BASEICM, "
			cQuery += "SF3.F3_VALICM,SF3.F3_ISENICM,SF3.F3_OUTRICM,SF3.F3_ICMSRET, "
			cQuery += "SF3.F3_CLIEFOR,SF3.F3_LOJA,SF3.F3_NFISCAL,SF3.F3_EMISSAO, "
			cQuery += "SF3.F3_SERIE, SF3.F3_VALIPI, SF3.F3_IPIOBS, SF3.F3_IDENTFT "
			cQuery += IIf(SF3->(FieldPos("F3_TRFICM"))>0,",SF3.F3_TRFICM "," ")	
			cQuery += Iif(lAntiICM,",SF3.F3_VALANTI "," ")
			cQuery += "FROM "
			cQuery += RetSqlName("SF3") + " SF3 "
			cQuery += "WHERE "    
			cQuery += "SF3.F3_FILIAL = '"+xFilial("SF3")+"' AND "		
			If nGeraTransp == 1 .And. SF3->(FieldPos("F3_TRFICM")) > 0
				cQuery	+= " ((SF3.F3_ENTRADA >= '"+DTOS(dDtIni)+"' AND SF3.F3_ENTRADA <= '"+DTOS(dDtFim)+"'"						
		   		cQuery	+= " AND SF3.F3_CFO NOT IN ('1601','1602','1605','5601','5602','5605') )
		   		If SuperGetMv('MV_ESTADO')=='PR'
	   				cQuery	+= " OR (SF3.F3_ENTRADA >= '"+DTOS(dDtIni+5)+"' AND SF3.F3_ENTRADA <= '"+DTOS(dDtFim+5)+"'"
	   			Else		   		
		   			cQuery	+= " OR (SF3.F3_ENTRADA >= '"+DTOS(dDtIni+9)+"' AND SF3.F3_ENTRADA <= '"+DTOS(dDtFim+9)+"'"
		   		EndIf
		   		cQuery	+= " AND SF3.F3_CFO IN ('1601','1602','1605','5601','5602','5605') )) AND "			
			Else
				cQuery += "SF3.F3_ENTRADA >= '"+DTOS(dDtIni)+"' AND "		
				cQuery += "SF3.F3_ENTRADA <= '"+DTOS(dDtFim)+"' AND "
				cQuery += "SF3.F3_CFO NOT IN ('1601','1602','1605','5601','5602','5605') AND "
			EndIf
			If cNrLivro <> "*"
				cQuery += "F3_NRLIVRO ='"+ cNrLivro +"' AND "
			EndIf	
			If lCodRSEF
				cQuery += "SF3.F3_CODRSEF NOT IN('102','110','204','205','206','301','302','303','304','305','306') AND "
			Endif
			cQuery += "SF3.D_E_L_E_T_ = ' '"
	
			cQuery := ChangeQuery(cQuery)
	    	
		   	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSF3,.T.,.T.)
	
			For nSF3 := 1 To Len(aStruSF3)
				If aStruSF3[nSF3][2] <> "C" .and. FieldPos(aStruSF3[nSF3][1]) > 0
					TcSetField(cAliasSF3,aStruSF3[nSF3][1],aStruSF3[nSF3][2],aStruSF3[nSF3][3],aStruSF3[nSF3][4])
				EndIf
			Next nSF3
		    
		Else
	#ENDIF	 
			dbSelectArea(cAliasSF3)
			cIndSF3	:=	CriaTrab(NIL,.F.)
			cChave	:=	IndexKey()
			cFiltro	:=	"F3_FILIAL=='"+xFilial()+"'"
			If nGeraTransp == 1 .And. SF3->(FieldPos("F3_TRFICM")) > 0
				cFiltro	+= " .And. ((DTOS(F3_ENTRADA)>='"+Dtos(dDtIni)+"' .And. DTOS(F3_ENTRADA)<='"+Dtos(dDtFim)+"'"						
				cFiltro	+= " .And. !(F3_CFO $ '1601/1602/1605/5601/5602/5605') )
				cFiltro	+= " .Or. (DTOS(F3_ENTRADA)>='"+Dtos(dDtIni+9)+"' .And. DTOS(F3_ENTRADA)<='"+Dtos(dDtFim+9)+"'"
				cFiltro	+= " .And. (F3_CFO $ '1601/1602/1605/5601/5602/5605') ))
			Else
				cFiltro	+= " .And. DTOS(F3_ENTRADA)>='"+DTOS(dDtIni)+"' .AND. DTOS(F3_ENTRADA)<='"+DTOS(dDtFim)+"'"
				cFiltro	+= " .And. !(F3_CFO $ '1601/1602/1605/5601/5602/5605') 
			EndIf
			If !(cNrLivro=="*")
				cFiltro+='.And. F3_NRLIVRO$"'+cNrLivro+'"'
			Endif
			
			IndRegua(cAliasSF3,cIndSF3,cChave,,cFiltro,STR0008) //"Selec.Notas fiscais..."
	#IFDEF TOP
		Endif
	#ENDIF	
			
		             
	#IFNDEF TOP
		If ProcName(1) == "R972IMP" 
			SetRegua((cAliasSF3)->(LastRec()))
		Else
			ProcRegua((cAliasSF3)->(LastRec()))
		Endif	
	#ENDIF     
	
		If Type("nTipoReg") == "U"
			nTipoReg := 0
		EndIf	
		
	If !lAglFil .Or. ((cPJIEAnt)<>SubStr(SM0->M0_CGC,1,8)+SM0->M0_INSC)

	   		cPJIEAnt := SubStr(SM0->M0_CGC,1,8)+SM0->M0_INSC
			nTipoReg++

			If !lRelDIPAM			
				RecLock(cArqCabec,.T.)
					(cArqCabec)->IE			:=	SM0->M0_INSC					//Inscricao Estadual
					(cArqCabec)->CNPJ		:=	SM0->M0_CGC						//CNPJ
					(cArqCabec)->CNAE		:=	cCNAE 							//Classficacao Nacional da Atividade Economica
					(cArqCabec)->REGTRIB	:=	strzero(nRegime,2)			//Regime Tributario
					(cArqCabec)->REF		:=	strzero(nAno,4)+strzero(nMes,2)//Referencia(Ano e Mes da GIA)
					(cArqCabec)->REFINIC	:=	cRefIni							//Referencia Inicial( Ano e Mes)
					(cArqCabec)->TIPO		:=	strzero(nTipoGia,2)			//Tipo da GIA
					(cArqCabec)->MOVIMEN	:=	if(nMoviment==1,"1","0")	//GIA com Movimento?
					(cArqCabec)->TRANSMI	:=	if(nTransmit==1,"1","0")	//GIA ja transmitida?
					(cArqCabec)->SALDO		:=	aApuracao[09]					//Saldo Credor do periodo anterior
					(cArqCabec)->SALDOST	:=	If(nRegime == 4,0.00,nSaldoST)	//Saldo Credor do Per.Ant. Substituicao Tributaria
					(cArqCabec)->ORIGSOF	:=	"53113791000122"				//CNPJ do Fabricande do sofwtare( Microsiga )
					(cArqCabec)->ORIGARQ	:=	"0"								//0-Gerado pelo sistama de informacao contabil
					(cArqCabec)->ICMSFIX	:=	if(nRegime==2,nICMSFIX,0.00)//ICMS Fixado para o periodo( Apenas para regime RES)
					(cArqCabec)->TIPOREG	:=  StrZero(nTipoReg,6)
				MSUnlock()	
			EndIf	
		EndIf	
	SA1->(dbSetOrder(1))			
	SA2->(dbSetOrder(1)) 
	SD1->(dbSetOrder(1))			
	SD2->(dbSetOrder(3))			
	SF4->(dbSetOrder(1))			
	SFT->(dbSetOrder(3))
	EE9->(dbSetOrder(3)	)
	While (cAliasSF3)->(!Eof()) .and. xFilial("SF3")==(cAliasSF3)->F3_FILIAL
		If !lQuery             
			If ProcName(1) == "R972IMP"
				IncRegua()
			else
				IncProc()
			EndIf
		EndIf	
	                 
		If !Empty((cAliasSF3)->F3_DTCANC)
			(cAliasSF3)->(dbSkip())
			Loop
		EndIf 

        dIni := STOD(Substr(DTOS((cAliasSF3)->F3_EMISSAO),1,4)+Substr(DTOS((cAliasSF3)->F3_EMISSAO),5,2)+Substr(DTOS((cAliasSF3)->F3_EMISSAO),7,2))
        dFim := STOD(Substr(DTOS(dDataFim),1,4)+Substr(DTOS(dDataFim),5,2)+Substr(DTOS(dDataFim),7,2))
		If  nGeraTransp == 1 .And. dIni>dFim .And. SF3->(FieldPos("F3_TRFICM")) > 0 .And. (cAliasSF3)->F3_TRFICM == 0  
	     	(cAliasSF3)->(dbSkip())
			Loop                                                                                
		EndIf  
	
		If ((cAliasSF3)->F3_TIPO=="S" ) .OR. (SubStr((cAliasSF3)->F3_CFO,1,3)$"000#999") .Or. (SubStr((cAliasSF3)->F3_CFO,1,4)$"1601#1602#1605#5601#5602#5605#5927")
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
				//³Grava arquivo temporario CR=25 (cArqIE)?
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
				If !lRelDIPAM .And. (SubStr((cAliasSF3)->F3_CFO,1,3)$"000#999" .Or. SubStr((cAliasSF3)->F3_CFO,1,4)$"1601#1602#1605#5601#5602#5605#5927")
					a972TmpIE(cAliasSF3)
		       Endif
				(cAliasSF3)->(dbSkip())
				Loop
		EndIf
		If !lRelDIPAM .And. nRegime == 4 .And. ;
			((cRef<="200212" .And. !(Alltrim((cAliasSF3)->F3_CFO)$"171/172/173/174/175/176/177/178/179/196/571/572/573/574/575/576/577/578/579" .Or. Substr((cAliasSF3)->F3_CFO,2,2)=="99")) .Or. ;
			(cRef>"200212" .And. cRef<="200312" .And. !(Alltrim((cAliasSF3)->F3_CFO)$"1401/1403/1406/1407/1408/1409/1410/1411/1414/1415/5401/5402/5403/5405/5408/5409/5410/5411/5412/5413/5414/5415" .Or. Left((cAliasSF3)->F3_CFO,2)$"19/59")) .Or. ;
			(cRef>"200312" .And. cRef <= "200412" .And. !(Alltrim((cAliasSF3)->F3_CFO)$"1401/1403/1406/1407/1408/1409/1410/1411/1414/1415/1651/1652/1653/1658/1659/1660/1661/1662/1663/1664/5401/5402/5403/5405/5408/5409/5410/5411/5412/5413/5414/5415/5651/5652/5653/5654/5655/5656/5657/5658/5659/5660/5661/5662/5663/5664/5665/5666" .Or. Left((cAliasSF3)->F3_CFO,2)$"19/59")) .Or.;
			(cRef>"200412" .And. !(Alltrim((cAliasSF3)->F3_CFO)$"1401/1403/1406/1407/1408/1409/1410/1411/1414/1415/1651/1652/1653/1658/1659/1660/1661/1662/1663/1664/5359/5401/5402/5403/5405/5408/5409/5410/5411/5412/5413/5414/5415/5651/5652/5653/5654/5655/5656/5657/5658/5659/5660/5661/5662/5663/5664/5665/5666/" .Or. Left((cAliasSF3)->F3_CFO,2)$"19/59")) .Or.;
			(cRef>"200712" .And. cRef <= "200804" .And. !(Alltrim((cAliasSF3)->F3_CFO)$"1360/1401/1403/1406/1407/1408/1409/1410/1411/1414/1415/1651/1652/1653/1658/1659/1660/1661/1662/1663/1664/5359/5360/5401/5402/5403/5405/5408/5409/5410/5411/5412/5413/5414/5415/5651/5652/5653/5654/5655/5656/5657/5658/5659/5660/5661/5662/5663/5664/5665/5666/" .Or. Left((cAliasSF3)->F3_CFO,2)$"19/59")) .or.;
			(cRef>"200804" .And. !(Alltrim((cAliasSF3)->F3_CFO)$"1360/1401/1403/1406/1407/1408/1409/1410/1411/1414/1415/1651/1652/1653/1658/1659/1660/1661/1662/1663/1664/5359/5360/6360/5401/5402/5403/5405/5408/5409/5410/5411/5412/5413/5414/5415/5651/5652/5653/5654/5655/5656/5657/5658/5659/5660/5661/5662/5663/5664/5665/5666/" .Or. Left((cAliasSF3)->F3_CFO,2)$"19/59")))
			(cAliasSF3)->(dbSkip()) 
			Loop
		EndIf
		cUF	:= A972CodUF((cAliasSF3)->F3_ESTADO)
		If cMvUF == "SP"
			If (substr(alltrim((cAliasSF3)->F3_CFO),2,2) == "99") .Or. (substr(alltrim((cAliasSF3)->F3_CFO),2,2) == "94" .And. Len(Alltrim((cAliasSF3)->F3_CFO))=4)
	            If !substr(alltrim((cAliasSF3)->F3_CFO),4,1)==""
				   If (strzero(nAno,4)+strzero(nMes,2)) > "200012" .and. (!(substr(alltrim((cAliasSF3)->F3_CFO),4,1)$ "19") .And. Len(Alltrim((cAliasSF3)->F3_CFO))=3)
					  (cAliasSF3)->(dbSkip())
					  Loop	
				   EndIf
				Endif   
			EndIf	
			cUF	:= A972CodUF((cAliasSF3)->F3_ESTADO)
			If Substr((cAliasSF3)->F3_CFO,1,1)$"26" .and. cUF$cCodUf  .And. lUfPg
				(cAliasSF3)->(dbSkip())
				Loop 
			EndIf	
		EndIf				

		SA1->(dbSeek(xFilial("SA1")+(cAliasSF3)->F3_CLIEFOR+(cAliasSF3)->F3_LOJA,.F.))
		SA2->(dbSeek(xFilial("SA2")+(cAliasSF3)->F3_CLIEFOR+(cAliasSF3)->F3_LOJA,.F.))

		If !lRelDIPAM
		
		//Encerra a movimentacao caso o parametro mv_par04 seja == 2.
		//Alterada a posicao do If no fonte para que o registro CR=05 seja executado independente do parametro, mv_par04.  
		If nMoviment == 2
			Return
		EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Detalhes CFOPs CR=10  ?
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If (cArqCFO)->(!dbSeek((cAliasSF3)->F3_CFO+StrZero(nTipoReg,6)))  
				RecLock(cArqCabec,.f.)
				(cArqCabec)->Q10	+=	1			//quantidade de registro tipo CR-10
			    MSUnLock()
			
				RecLock(cArqCFO,.T.)
				(cArqCFO)->CFOP		:=	(cAliasSF3)->F3_CFO			//CFOP
			Else
				RecLock(cArqCFO,.F.)
			EndIf 
				(cArqCFO)->VALCONT	+=	(cAliasSF3)->F3_VALCONT		//Valor Contabil
				(cArqCFO)->BASEICM	+=	(cAliasSF3)->F3_BASEICM		//Base de Calculo
				(cArqCFO)->VALTRIB	+=	(cAliasSF3)->F3_VALICM		//Valor do imposto creditado
				(cArqCFO)->ISENTA	+=	(cAliasSF3)->F3_ISENICM		//Isenta e nao tributada
				(cArqCFO)->OUTRAS	+=	(cAliasSF3)->F3_OUTRICM		//Outras Operacoes
		    If cRef >= "200201"
		    	(cArqCFO)->RETIDO   += 0
		    Else
			 	If lAntiICM .And. (cAliasSF3)->F3_VALANTI == 0
			    	(cArqCFO)->RETIDO	+=	(cAliasSF3)->F3_ICMSRET		//Imposto retido por Substituicao Tributaria
			    
				EndIf         

			EndIf
	
			lStSb		:=	.F.
			If (cVValid == "0700" .and. cVLayOut == "0200") .Or. (cVValid == "0710" .and. cVLayOut == "0201") .or. (cVValid == "0720" .and. cVLayOut == "0202") .Or. ;
				(cVValid == "0730" .and. cVLayOut == "0203") .Or. (cVValid == "0740" .and. cVLayOut == "0204") .Or. (cVValid == "0750" .and. cVLayOut == "0205") .Or. ;
			 	(cVValid == "0760" .and. cVLayOut == "0206") .Or. (cVValid == "0770" .and. cVLayOut == "0207") .Or. (cVValid == "0780" .and. cVLayOut == "0208") .or.;
			    (cVValid == "0790" .and. cVLayOut == "0209") .Or. (cVValid == "0800" .and. cVLayOut == "0210")
				If (cRef<="200212")
					If (SubStr ((cAliasSF3)->F3_CFO, 1, 1)$"56")
						If (((SubStr ((cAliasSF3)->F3_CFO, 1, 3)>="571") .And. (SubStr ((cAliasSF3)->F3_CFO, 1, 3)<="579")) .Or.;
							(SubStr ((cAliasSF3)->F3_CFO, 1, 3)=="597") .Or.;
							((SubStr ((cAliasSF3)->F3_CFO, 1, 3)>="671") .And. (SubStr ((cAliasSF3)->F3_CFO, 1, 3)<="679")) .Or.;
							(SubStr ((cAliasSF3)->F3_CFO, 1, 3)=="697") .Or.;
							(SubStr ((cAliasSF3)->F3_CFO, 2, 2)=="99"))
					
							(cArqCFO)->RtStSt := 0
							(cArqCFO)->RtSbSt := 0
					
						Else
							If lAntiICM .And. (cAliasSF3)->F3_VALANTI == 0
							(cArqCFO)->RtStSt += (cAliasSF3)->F3_ICMSRET
							lStSb		:=	.T.
							Endif
						EndIf
					ElseIf (SubStr ((cAliasSF3)->F3_CFO, 1, 1)$"12")
						If (((SubStr ((cAliasSF3)->F3_CFO, 1, 3)>="171") .And. (SubStr ((cAliasSF3)->F3_CFO, 1, 3)<="179")) .Or.;
							((SubStr ((cAliasSF3)->F3_CFO, 1, 3)>="271") .And. (SubStr ((cAliasSF3)->F3_CFO, 1, 3)<="279")) .Or.;
							(SubStr ((cAliasSF3)->F3_CFO, 1, 3)=="196") .Or.;
							(SubStr ((cAliasSF3)->F3_CFO, 1, 3)=="296") .Or.;
							(SubStr ((cAliasSF3)->F3_CFO, 2, 2)=="99"))
							
							(cArqCFO)->RtStSt := 0						
							(cArqCFO)->RtSbSt := 0

						Else 
							If lAntiICM .And. (cAliasSF3)->F3_VALANTI == 0  
							(cArqCFO)->RtSbSt += (cAliasSF3)->F3_ICMSRET
							lStSb		:=	.T.
							Endif									
						EndIf
					EndIf        
					
				ElseIf (cRef>"200212" .And. cRef<="200312")
					If (SubStr ((cAliasSF3)->F3_CFO, 1, 1)$"56")
						If (((Val ((cAliasSF3)->F3_CFO)>=5401) .And. (Val ((cAliasSF3)->F3_CFO)<=5449)) .Or.;
							((Val ((cAliasSF3)->F3_CFO)>=6401) .And. (Val ((cAliasSF3)->F3_CFO)<=6449)) .Or.;
							(SubStr ((cAliasSF3)->F3_CFO, 1, 2)=="59") .Or.;
							(SubStr ((cAliasSF3)->F3_CFO, 1, 2)=="69"))

							(cArqCFO)->RtStSt := 0
							(cArqCFO)->RtSbSt := 0

						Else   
							If lAntiICM .And. (cAliasSF3)->F3_VALANTI == 0						
							(cArqCFO)->RtStSt += (cAliasSF3)->F3_ICMSRET
							lStSb		:=	.T.
							Endif		
						EndIf							
						
					ElseIf (SubStr ((cAliasSF3)->F3_CFO, 1, 1)$"12")
						If (((Val ((cAliasSF3)->F3_CFO)>=1401) .And. (Val ((cAliasSF3)->F3_CFO)<=1449)) .Or.;
							((Val ((cAliasSF3)->F3_CFO)>=2401) .And. (Val ((cAliasSF3)->F3_CFO)<=2449)) .Or.;
							(SubStr ((cAliasSF3)->F3_CFO, 1, 2)=="19") .Or.;
							(SubStr ((cAliasSF3)->F3_CFO, 1, 2)=="29"))

							(cArqCFO)->RtStSt := 0
							(cArqCFO)->RtSbSt := 0
												
						Else
							If lAntiICM .And. (cAliasSF3)->F3_VALANTI == 0
							(cArqCFO)->RtSbSt += (cAliasSF3)->F3_ICMSRET
							lStSb		:=	.T.
							Endif									
						EndIf
					EndIf
					
				ElseIf	(cRef>"200312" .And. cRef<="200712")
					If (SubStr ((cAliasSF3)->F3_CFO, 1, 1)$"56")
						If (((Val ((cAliasSF3)->F3_CFO)>=5401) .And. (Val ((cAliasSF3)->F3_CFO)<=5449)) .Or.;
							((Val ((cAliasSF3)->F3_CFO)>=5651) .And. (Val ((cAliasSF3)->F3_CFO)<=5699)) .Or.;				
							((Val ((cAliasSF3)->F3_CFO)>=6401) .And. (Val ((cAliasSF3)->F3_CFO)<=6449)) .Or.;
							((Val ((cAliasSF3)->F3_CFO)>=6651) .And. (Val ((cAliasSF3)->F3_CFO)<=6699)) .Or.;
							(SubStr ((cAliasSF3)->F3_CFO, 1, 2)=="59") .Or.;
							(SubStr ((cAliasSF3)->F3_CFO, 1, 2)=="69"))
						
							(cArqCFO)->RtStSt := 0
							(cArqCFO)->RtSbSt := 0
						
						Else 
							If lAntiICM .And. (cAliasSF3)->F3_VALANTI == 0						
							(cArqCFO)->RtStSt += (cAliasSF3)->F3_ICMSRET
							lStSb		:=	.T.
							Endif			
						EndIf
													
					ElseIf (SubStr ((cAliasSF3)->F3_CFO, 1, 1)$"12")
						If (((Val ((cAliasSF3)->F3_CFO)>=1401) .And. (Val ((cAliasSF3)->F3_CFO)<=1449)) .Or.;
							((Val ((cAliasSF3)->F3_CFO)>=1651) .And. (Val ((cAliasSF3)->F3_CFO)<=1699)) .Or.;				
							((Val ((cAliasSF3)->F3_CFO)>=2401) .And. (Val ((cAliasSF3)->F3_CFO)<=2449)) .Or.;
							((Val ((cAliasSF3)->F3_CFO)>=2651) .And. (Val ((cAliasSF3)->F3_CFO)<=2699)) .Or.;
							(SubStr ((cAliasSF3)->F3_CFO, 1, 2)=="19") .Or.;
							(SubStr ((cAliasSF3)->F3_CFO, 1, 2)=="29"))
							
							(cArqCFO)->RtStSt := 0
							(cArqCFO)->RtSbSt := 0
							
							
						Else 
							If (cAliasSF3)->F3_TIPO <> "D"	//Devolucao
								If lAntiICM .And. (cAliasSF3)->F3_VALANTI == 0
									(cArqCFO)->RtSbSt += (cAliasSF3)->F3_ICMSRET
									lStSb		:=	.T.
								Endif
							Else
								If lAntiICM .And. (cAliasSF3)->F3_VALANTI == 0
									(cArqCFO)->RtStSt += (cAliasSF3)->F3_ICMSRET
									lStSb		:=	.T.
								Endif
							Endif
						EndIf
					EndIf						
                     
                      
				ElseIf	(cRef>"200712" .And. cRef<="200804")
					If (SubStr ((cAliasSF3)->F3_CFO, 1, 1)$"56")
						If (((Val ((cAliasSF3)->F3_CFO)>=5401) .And. (Val ((cAliasSF3)->F3_CFO)<=5449)) .Or.;
							((Val ((cAliasSF3)->F3_CFO)>=5651) .And. (Val ((cAliasSF3)->F3_CFO)<=5699)) .Or.;				
							((Val ((cAliasSF3)->F3_CFO)>=6401) .And. (Val ((cAliasSF3)->F3_CFO)<=6449)) .Or.;
							((Val ((cAliasSF3)->F3_CFO)>=6651) .And. (Val ((cAliasSF3)->F3_CFO)<=6699)) .Or.;
							(Val ((cAliasSF3)->F3_CFO)==5360)) .Or.;
							(SubStr ((cAliasSF3)->F3_CFO, 1, 2)=="69")
							
							(cArqCFO)->RtStSt := 0
							(cArqCFO)->RtSbSt := 0
						
						Else 
							If (cAliasSF3)->F3_TIPO <> "D"	//Devolucao
								If lAntiICM .And. (cAliasSF3)->F3_VALANTI == 0
									(cArqCFO)->RtSbSt += (cAliasSF3)->F3_ICMSRET
									lStSb		:=	.T.
								Endif
							Else
								If lAntiICM .And. (cAliasSF3)->F3_VALANTI == 0
									(cArqCFO)->RtStSt += (cAliasSF3)->F3_ICMSRET
									lStSb		:=	.T.
								Endif
							Endif
						Endif			

												
					ElseIf (SubStr ((cAliasSF3)->F3_CFO, 1, 1)$"12")
						If (((Val ((cAliasSF3)->F3_CFO)<>1360) .And. (Val ((cAliasSF3)->F3_CFO)>=1401) .And. (Val ((cAliasSF3)->F3_CFO)<=1449)) .Or.;
							((Val ((cAliasSF3)->F3_CFO)>=1651) .And. (Val ((cAliasSF3)->F3_CFO)<=1699)) .Or.;				
							((Val ((cAliasSF3)->F3_CFO)>=2401) .And. (Val ((cAliasSF3)->F3_CFO)<=2449)) .Or.;
							((Val ((cAliasSF3)->F3_CFO)>=2651) .And. (Val ((cAliasSF3)->F3_CFO)<=2699)) .Or.;
							(SubStr ((cAliasSF3)->F3_CFO, 1, 2)=="19") .Or.;
							(SubStr ((cAliasSF3)->F3_CFO, 1, 2)=="29"))
							
							(cArqCFO)->RtStSt := 0
							(cArqCFO)->RtSbSt := 0
							
							
						Else 
							If lAntiICM .And. (cAliasSF3)->F3_VALANTI == 0
							(cArqCFO)->RtSbSt += (cAliasSF3)->F3_ICMSRET
							lStSb		:=	.T.
							Endif
						EndIf

                    EndIf   
                     
                Else //(cRef>"200804")
					If (SubStr ((cAliasSF3)->F3_CFO, 1, 1)$"56")
						If (((Val ((cAliasSF3)->F3_CFO)>=5401) .And. (Val ((cAliasSF3)->F3_CFO)<=5449)) .Or.;
							((Val ((cAliasSF3)->F3_CFO)>=5651) .And. (Val ((cAliasSF3)->F3_CFO)<=5699)) .Or.;				
							((Val ((cAliasSF3)->F3_CFO)>=6401) .And. (Val ((cAliasSF3)->F3_CFO)<=6449)) .Or.;
							((Val ((cAliasSF3)->F3_CFO)>=6651) .And. (Val ((cAliasSF3)->F3_CFO)<=6699)) .Or.;
							((Val ((cAliasSF3)->F3_CFO)==5360)) .Or.;
							((Val ((cAliasSF3)->F3_CFO)==6360)) .Or.;
							(SubStr ((cAliasSF3)->F3_CFO, 1, 2)=="59").Or.;
							(SubStr ((cAliasSF3)->F3_CFO, 1, 2)=="69"))
						      
							If lAntiICM .And. (cAliasSF3)->F3_VALANTI == 0	
								SFT->(dbSeek(xFilial("SF3")+"S"+(cAliasSF3)->F3_CLIEFOR+(cAliasSF3)->F3_LOJA+(cAliasSF3)->F3_SERIE+(cAliasSF3)->F3_NFISCAL+(cAliasSF3)->F3_IDENTFT))
								SD2->(DbSeek(xFilial("SD2")+SFT->FT_NFISCAL+SFT->FT_SERIE+SFT->FT_CLIEFOR+SFT->FT_LOJA+SFT->FT_PRODUTO))
								SF4->(dbSeek(xFilial("SF4")+SD2->D2_TES))
								
								// Aplicado o conceito dos parametros MV_STUF e MV_STUFS, assim como eh feito nos Speds e Apuracao de ICMS				
								If	SF4->F4_CREDST $ "23" .And.;
									!SubStr( ( cAliasSF3 )->F3_CFO , 1 , 4 ) $ "6109|6110|6119" .And.;
									(	( Empty( cMv_StUfS ) .Or. ( cAliasSF3 )->F3_ESTADO $ cMv_StUfS ) .Or.;
										( Empty( cMv_StUf ) .Or. ( cAliasSF3 )->F3_ESTADO $ cMv_StUf ) )
									
									(cArqCFO)->RtStSt += (cAliasSF3)->F3_ICMSRET
									lStSb		:=	.T.
						    	
						    	ElseIf SF4->F4_CREDST == "4" .And. !SubStr( ( cAliasSF3 )->F3_CFO , 1 , 4 ) $ "6109|6110|6119"
							    	(cArqCFO)->RtSbSt += (cAliasSF3)->F3_ICMSRET
									lStSb		:=	.T.
						    	EndIf
							Endif
						Else
							(cArqCFO)->RtStSt += 0
							(cArqCFO)->RtSbSt += 0
						EndIf
													
					ElseIf (SubStr ((cAliasSF3)->F3_CFO, 1, 1)$"12")
						If (((Val ((cAliasSF3)->F3_CFO)<>1360) .And. (Val ((cAliasSF3)->F3_CFO)>=1401) .And. (Val ((cAliasSF3)->F3_CFO)<=1449)) .Or.;
							((Val ((cAliasSF3)->F3_CFO)>=1651) .And. (Val ((cAliasSF3)->F3_CFO)<=1699)) .Or.;				
							((Val ((cAliasSF3)->F3_CFO)>=2401) .And. (Val ((cAliasSF3)->F3_CFO)<=2449)) .Or.;
							((Val ((cAliasSF3)->F3_CFO)>=2651) .And. (Val ((cAliasSF3)->F3_CFO)<=2699)) .Or.;
							((Val ((cAliasSF3)->F3_CFO)>=1949) .And. (Val ((cAliasSF3)->F3_CFO)<=2949)) .And. (Val ((cAliasSF3)->F3_CFO)<>1603) .And. (Val ((cAliasSF3)->F3_CFO)<>2603).Or.;
							(SubStr ((cAliasSF3)->F3_CFO, 1, 2)=="19") .Or.; 
							(SubStr ((cAliasSF3)->F3_CFO, 1, 2)=="29")) 							
														
							If lAntiICM .And. (cAliasSF3)->F3_VALANTI == 0	
								If SFT->(dbSeek(xFilial("SFT")+"E"+(cAliasSF3)->F3_CLIEFOR+(cAliasSF3)->F3_LOJA+(cAliasSF3)->F3_SERIE+(cAliasSF3)->F3_NFISCAL+(cAliasSF3)->F3_IDENTFT))
									If SD1->(DbSeek(xFilial("SD1")+SFT->FT_NFISCAL+SFT->FT_SERIE+SFT->FT_CLIEFOR+SFT->FT_LOJA+SFT->FT_PRODUTO	))
										If SF4->(dbSeek(xFilial("SF4")+SD1->D1_TES))				
											If	SF4->F4_CREDST == "2"								
												(cArqCFO)->RtStSt += (cAliasSF3)->F3_ICMSRET
												lStSb		:=	.T.
							    			ElseIf SF4->F4_CREDST == "4"
								    			(cArqCFO)->RtSbSt += (cAliasSF3)->F3_ICMSRET
												lStSb		:=	.T.											
							    			EndIf							    			
							    		EndIf
							    	EndIf
							    EndIf			
							Endif
						Else
							(cArqCFO)->RtStSt += 0
							(cArqCFO)->RtSbSt += 0
						EndIf
					EndIf
		   		EndIf
            Endif
        
			If ((cAliasSF3)->F3_BASEICM <= (cAliasSF3)->F3_VALCONT .And. !Empty((cAliasSF3)->F3_VALIPI)) .Or. !Empty((cAliasSF3)->F3_VALIPI)
			   (cArqCFO)->IMPOSTO	+= (cAliasSF3)->F3_VALIPI
			Else
               (cArqCFO)->IMPOSTO	+= (cAliasSF3)->F3_IPIOBS 			
			Endif       
						
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
			//³Tratamento para PIS/COFINS agregado no total da Nota     ?
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
			cTipoNf=Iif(Substr((cAliasSF3)->F3_CFO,1,1)<"4","E","S")
			// Verificar caso seja entrada.
			If cTipoNf="E"
				aD1Imp    := MaFisRelImp("MT100",{ "SD1" })
				// Posiciona no primeiro item da NF
				If SD1->(DbSeek(xFilial("SD1")+(cAliasSF3)->F3_NFISCAL+(cAliasSF3)->F3_SERIE+(cAliasSF3)->F3_CLIEFOR+(cAliasSF3)->F3_LOJA))
					// Verifica em cada item da NF a existencia de PIS/COFINS
					Do While SD1->D1_FILIAL==xFilial("SD1") .And. SD1->D1_DOC==(cAliasSF3)->F3_NFISCAL .And. SD1->D1_SERIE==(cAliasSF3)->F3_SERIE .And. ;
						SD1->D1_FORNECE==(cAliasSF3)->F3_CLIEFOR .And. SD1->D1_LOJA==(cAliasSF3)->F3_LOJA
						// Verifica caso seja a mesma CFOP
						If SD1->D1_CF==(cAliasSF3)->F3_CFO
							If SF4->(dbSeek(xFilial("SF4")+SD1->D1_TES))
								// Soma o valor de PIS/COFINS
								IF SF4->F4_AGRPIS $ "1S"
									If !Empty( nScanPis := aScan(aD1Imp,{|x| x[1]=="SD1" .And. x[3]=="IT_VALPS2"} ) )
										cCampoPis := aD1Imp[nScanPis,2]
										nPosPis := SD1->( FieldPos( cCampoPis ) )
										(cArqCFO)->IMPOSTO += SD1->( FieldGet( nPosPis ) )
									EndIf
								Endif
								If SF4->F4_AGRCOF $ "1S"
									If !Empty( nScanCof := aScan(aD1Imp,{|x| x[1]=="SD1" .And. x[3]=="IT_VALCF2"} ) )
										cCampoCof := aD1Imp[nScanCof,2]
										nPosCof := SD1->( FieldPos( cCampoCof ) )
										(cArqCFO)->IMPOSTO += SD1->( FieldGet( nPosCof ) )
									EndIf
								Endif
							Endif
						Endif
						SD1->( DbSkip() )
					EndDo
				EndIf
			Else
				aD2Imp    := MaFisRelImp("MT100",{ "SD2" })
				If SD2->(DbSeek(xFilial("SD2")+(cAliasSF3)->F3_NFISCAL+(cAliasSF3)->F3_SERIE+(cAliasSF3)->F3_CLIEFOR+(cAliasSF3)->F3_LOJA))
					// Verifica em cada item da NF a existencia de PIS/COFINS
					Do While SD2->D2_FILIAL==xFilial("SD2") .And. SD2->D2_DOC==(cAliasSF3)->F3_NFISCAL .And. SD2->D2_SERIE==(cAliasSF3)->F3_SERIE .And. ;
						SD2->D2_CLIENTE==(cAliasSF3)->F3_CLIEFOR .And. SD2->D2_LOJA==(cAliasSF3)->F3_LOJA
						
						// Verifica caso seja a mesma CFOP
						If SD2->D2_CF==(cAliasSF3)->F3_CFO
							If SF4->(dbSeek(xFilial("SF4")+SD2->D2_TES))
								// Soma o valor de PIS/COFINS
								IF SF4->F4_AGRPIS $ "1S"
									If !Empty( nScanPis := aScan(aD2Imp,{|x| x[1]=="SD2" .And. x[3]=="IT_VALPS2"} ) )
										cCampoPis := aD2Imp[nScanPis,2]
										nPosPis := SD2->( FieldPos( cCampoPis ) )
										(cArqCFO)->IMPOSTO += SD2->( FieldGet( nPosPis ) )
									EndIf
								Endif
								If SF4->F4_AGRCOF $ "1S"
									If !Empty( nScanCof := aScan(aD2Imp,{|x| x[1]=="SD2" .And. x[3]=="IT_VALCF2"} ) )
										cCampoCof := aD2Imp[nScanCof,2]
										nPosCof := SD2->( FieldPos( cCampoCof ) )
										(cArqCFO)->IMPOSTO += SD2->( FieldGet( nPosCof ) )
									EndIf
								Endif
							Endif
						Endif
						SD2->( DbSkip() )
					EndDo
				Endif				
			EndIf
			(cArqCFO)->TIPOREG	:=  StrZero(nTipoReg,6)							            
	   		(cArqCFO)->(MSUnlock())
			
			If !lRelDIPAM .And. nRegime <> 4
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
				//³Detalhes Interestaduais CR=14?
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
				If (Substr((cAliasSF3)->F3_CFO,1,1)$"26" .and. cMvUF <> "SP") .or. (Substr((cAliasSF3)->F3_CFO,1,1)$"26" .and. !(cUF$cCodUf) .and. cMvUF == "SP")
					If Substr((cAliasSF3)->F3_CFO,1,1)=="2"		
						cInscr	:= If((cAliasSF3)->F3_TIPO$"DB",SA1->A1_INSCR,SA2->A2_INSCR)
		   	     		cTipo  	:= If((cAliasSF3)->F3_TIPO$"DB",SA1->A1_TIPO,SA2->A2_TIPO)
					ElseIf Substr((cAliasSF3)->F3_CFO,1,1)=="6"
						cInscr	:= If((cAliasSF3)->F3_TIPO$"DB",SA2->A2_INSCR,SA1->A1_INSCR)
		   	     		cTipo  	:= If((cAliasSF3)->F3_TIPO$"DB",SA2->A2_TIPO,SA1->A1_TIPO)
					EndIf
					If !(cArqInt)->(dbSeek((cAliasSF3)->F3_CFO+cUF+StrZero(nTipoReg,6)))
						If (cArqCFO)->(dbSeek((cAliasSF3)->F3_CFO+StrZero(nTipoReg,6)))
		 					RecLocK(cArqCFO,.f.)	
		 					(cArqCFO)->Q14	+=	1						//Quantidade de Registros CR=14
							MsUnlock()
						EndIf
				
						RecLock(cArqInt,.T.)                 
						(cArqInt)->CFOP  :=	(cAliasSF3)->F3_CFO				//CFOP
						(cArqInt)->UF	 :=	cUF								//Unidade da Federacao
						(cArqInt)->TIPOREG	:=  StrZero(nTipoReg,6)
					Else
						RecLock(cArqInt,.F.)	
					EndIf		
				
					If Substr((cAliasSF3)->F3_CFO,1,1)=="2"
						(cArqInt)->VALCONT	+=	(cAliasSF3)->F3_VALCONT		//Valor Contabil de Contribuinte
						(cArqInt)->BASECON	+=	(cAliasSF3)->F3_BASEICM   	//Base de Calculo de Contribuinte		
					ElseIf (nAno<2003 .And. Subs(ALLTRIM((cAliasSF3)->F3_CFO),1,3)$"618/619/645/653") .Or. (nAno>=2003 .And. Subs(ALLTRIM((cAliasSF3)->F3_CFO),1,4)$"6107/6108/5307/6307") .or. "ISENT" $Upper(cInscr) .or. (empty(cInscr) .and. cTipo != "L" .and. substr((cAliasSF3)->F3_CFO,1,1)=="6")
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ??
						//³Nao Contribuinte?
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ??
						(cArqInt)->VALNCON	+=	(cAliasSF3)->F3_VALCONT		//Valor Contabil de NAO Contribuinte
						(cArqInt)->BASENCO	+=	(cAliasSF3)->F3_BASEICM 		//Base de Calculo de NAO Contribuinte
					Else
						(cArqInt)->VALCONT	+=	(cAliasSF3)->F3_VALCONT		//Valor Contabil de Contribuinte
						(cArqInt)->BASECON	+=	(cAliasSF3)->F3_BASEICM   	//Base de Calculo de Contribuinte
					EndIf
					If (cRef >= "200201")
						(cArqInt)->IMPOSTO	+=	(cAliasSF3)->F3_VALICM      //Imposto Creditado e Debitado
					Else
						(cArqInt)->IMPOSTO	+=	0      //Imposto Creditado e Debitado						
					EndIf
					(cArqInt)->OUTRAS	+=	(cAliasSF3)->F3_OUTRICM        	//Outras operacoes
					(cArqInt)->ISENTA	+=	(cAliasSF3)->F3_ISENICM        	//Isentas/nao tributadas			
		
					If (cVValid == "0700" .and. cVLayOut == "0200") .or. (cVValid == "0710" .and. cVLayOut == "0201") .or. (cVValid == "0720" .and. cVLayOut == "0202") .Or. ;
						(cVValid == "0730" .and. cVLayOut == "0203") .or. (cVValid == "0740" .and. cVLayOut == "0204") .Or. (cVValid == "0750" .and. cVLayOut == "0205") .Or. ;
						(cVValid == "0760" .and. cVLayOut == "0206") .Or. (cVValid == "0770" .and. cVLayOut == "0207") .Or. (cVValid == "0780" .and. cVLayOut == "0208") .or.; 
						(cVValid == "0790" .and. cVLayOut == "0209") .Or. (cVValid == "0800" .and. cVLayOut == "0210")

						If (cRef<="200212")
							If (SubStr ((cAliasSF3)->F3_CFO, 1, 1)$"56")
								If (((SubStr ((cAliasSF3)->F3_CFO, 1, 3)>="571") .And. (SubStr ((cAliasSF3)->F3_CFO, 1, 3)<="579")) .Or.;
										(SubStr ((cAliasSF3)->F3_CFO, 1, 3)=="597") .Or.;
										((SubStr ((cAliasSF3)->F3_CFO, 1, 3)>="671") .And. (SubStr ((cAliasSF3)->F3_CFO, 1, 3)<="679")) .Or.;
										(SubStr ((cAliasSF3)->F3_CFO, 1, 3)=="697") .Or.;
										(SubStr ((cAliasSF3)->F3_CFO, 2, 2)=="99"))
									
								 		(cArqInt)->RETIDO	+=	0
								 	
								Else
									If lAntiICM .And. (cAliasSF3)->F3_VALANTI == 0
										(cArqInt)->RETIDO	+=	(cAliasSF3)->F3_ICMSRET		//ICMS cobrado por Substituicao Tributaria
									Endif
								EndIf
							ElseIf (SubStr ((cAliasSF3)->F3_CFO, 1, 1)$"12")
								If (((SubStr ((cAliasSF3)->F3_CFO, 1, 3)>="171") .And. (SubStr ((cAliasSF3)->F3_CFO, 1, 3)<="179")) .Or.;
									((SubStr ((cAliasSF3)->F3_CFO, 1, 3)>="271") .And. (SubStr ((cAliasSF3)->F3_CFO, 1, 3)<="279")) .Or.;
									(SubStr ((cAliasSF3)->F3_CFO, 1, 3)=="196") .Or.;
									(SubStr ((cAliasSF3)->F3_CFO, 1, 3)=="296") .Or.;
									(SubStr ((cAliasSF3)->F3_CFO, 2, 2)=="99"))

					       	    	(cArqInt)->OUTPROD	+=	0							//Outros produtos quando Substituicao Tributaria
					       	    	
								Else
									If lAntiICM .And. (cAliasSF3)->F3_VALANTI == 0 
						   				(cArqInt)->OUTPROD	+=	(cAliasSF3)->F3_ICMSRET		//Outros produtos quando Substituicao Tributaria
						   			Endif
								EndIf
							EndIf    
							
						ElseIf (cRef>"200212" .And. cRef<="200312")
							If (SubStr ((cAliasSF3)->F3_CFO, 1, 1)$"56")
								If (((Val ((cAliasSF3)->F3_CFO)>=5401) .And. (Val ((cAliasSF3)->F3_CFO)<=5449)) .Or.;
									((Val ((cAliasSF3)->F3_CFO)>=6401) .And. (Val ((cAliasSF3)->F3_CFO)<=6449)) .Or.;
									(SubStr ((cAliasSF3)->F3_CFO, 1, 2)=="59") .Or.;
									(SubStr ((cAliasSF3)->F3_CFO, 1, 2)=="69"))
								
							   		(cArqInt)->RETIDO	+= 0
								    
								Else
									If lAntiICM .And. (cAliasSF3)->F3_VALANTI == 0						
										(cArqInt)->RETIDO	+=	(cAliasSF3)->F3_ICMSRET	 	//ICMS cobrado por Substituicao Tributaria
									Endif																											
								EndIf							
							ElseIf (SubStr ((cAliasSF3)->F3_CFO, 1, 1)$"12")
					  			If (((Val ((cAliasSF3)->F3_CFO)>=1401) .And. (Val ((cAliasSF3)->F3_CFO)<=1449)) .Or.;
									((Val ((cAliasSF3)->F3_CFO)>=2401) .And. (Val ((cAliasSF3)->F3_CFO)<=2449)) .Or.;
									(SubStr ((cAliasSF3)->F3_CFO, 1, 2)=="19") .Or.;
									(SubStr ((cAliasSF3)->F3_CFO, 1, 2)=="29"))
                                    
                                    (cArqInt)->OUTPROD	+= 0

								Else
									If lAntiICM .And. (cAliasSF3)->F3_VALANTI == 0
										(cArqInt)->OUTPROD	+=	(cAliasSF3)->F3_ICMSRET		//Outros produtos quando Substituicao Tributaria
									Endif									
									
								EndIf
							EndIf

						ElseIf	(cRef>"200312" .And. cRef<="200712")
							If (SubStr ((cAliasSF3)->F3_CFO, 1, 1)$"56")
								If (((Val ((cAliasSF3)->F3_CFO)>=5401) .And. (Val ((cAliasSF3)->F3_CFO)<=5449)) .Or.;
									((Val ((cAliasSF3)->F3_CFO)>=5651) .And. (Val ((cAliasSF3)->F3_CFO)<=5699)) .Or.;				
									((Val ((cAliasSF3)->F3_CFO)>=6401) .And. (Val ((cAliasSF3)->F3_CFO)<=6449)) .Or.;
									((Val ((cAliasSF3)->F3_CFO)>=6651) .And. (Val ((cAliasSF3)->F3_CFO)<=6699)) .Or.;
									(SubStr ((cAliasSF3)->F3_CFO, 1, 2)=="59") .Or.;
									(SubStr ((cAliasSF3)->F3_CFO, 1, 2)=="69"))
		      				         
		      						(cArqInt)->OUTPROD	+= 0
	
								Else
									If lAntiICM .And. (cAliasSF3)->F3_VALANTI == 0
										(cArqInt)->OUTPROD	+=	(cAliasSF3)->F3_ICMSRET		//Outros produtos quando Substituicao Tributaria
									Endif									
									
								EndIf
							ElseIf (SubStr ((cAliasSF3)->F3_CFO, 1, 1)$"12")
								If (((Val ((cAliasSF3)->F3_CFO)>=1401) .And. (Val ((cAliasSF3)->F3_CFO)<=1449)) .Or.;
									((Val ((cAliasSF3)->F3_CFO)>=1651) .And. (Val ((cAliasSF3)->F3_CFO)<=1699)) .Or.;				
									((Val ((cAliasSF3)->F3_CFO)>=2401) .And. (Val ((cAliasSF3)->F3_CFO)<=2449)) .Or.;
									((Val ((cAliasSF3)->F3_CFO)>=2651) .And. (Val ((cAliasSF3)->F3_CFO)<=2699)) .Or.;
									(SubStr ((cAliasSF3)->F3_CFO, 1, 2)=="19") .Or.;
									(SubStr ((cAliasSF3)->F3_CFO, 1, 2)=="29"))
									 
									(cArqInt)->OUTPROD	+= 0
	
								Else
									If lAntiICM .And. (cAliasSF3)->F3_VALANTI == 0
										(cArqInt)->OUTPROD	+=	(cAliasSF3)->F3_ICMSRET		//Outros produtos quando Substituicao Tributaria
									Endif									
								EndIf
							EndIf	
						ElseIf	(cRef>"200712" .And. cRef<="200804")
							If (SubStr ((cAliasSF3)->F3_CFO, 1, 1)$"56")
								If (((Val ((cAliasSF3)->F3_CFO)>=5401) .And. (Val ((cAliasSF3)->F3_CFO)<=5449)) .Or.;
									((Val ((cAliasSF3)->F3_CFO)>=5651) .And. (Val ((cAliasSF3)->F3_CFO)<=5699)) .Or.;				
									((Val ((cAliasSF3)->F3_CFO)>=6401) .And. (Val ((cAliasSF3)->F3_CFO)<=6449)) .Or.;
									((Val ((cAliasSF3)->F3_CFO)>=6651) .And. (Val ((cAliasSF3)->F3_CFO)<=6699)) .Or.;
									(Val ((cAliasSF3)->F3_CFO)==5360)) .Or.;
									(SubStr ((cAliasSF3)->F3_CFO, 1, 2)=="69")	 
									
									(cArqInt)->OUTPROD	+= 0

								Else
									If lAntiICM .And. (cAliasSF3)->F3_VALANTI == 0
										(cArqInt)->OUTPROD	+=	(cAliasSF3)->F3_ICMSRET		//Outros produtos quando Substituicao Tributaria
									Endif									
								EndIf
							ElseIf (SubStr ((cAliasSF3)->F3_CFO, 1, 1)$"12")
								If (((Val ((cAliasSF3)->F3_CFO)<>1360) .And. (Val ((cAliasSF3)->F3_CFO)>=1401) .And. (Val ((cAliasSF3)->F3_CFO)<=1449)) .Or.;
									((Val ((cAliasSF3)->F3_CFO)>=1651) .And. (Val ((cAliasSF3)->F3_CFO)<=1699)) .Or.;				
									((Val ((cAliasSF3)->F3_CFO)>=2401) .And. (Val ((cAliasSF3)->F3_CFO)<=2449)) .Or.;
									((Val ((cAliasSF3)->F3_CFO)>=2651) .And. (Val ((cAliasSF3)->F3_CFO)<=2699)) .Or.;
									(SubStr ((cAliasSF3)->F3_CFO, 1, 2)=="19") .Or.;
									(SubStr ((cAliasSF3)->F3_CFO, 1, 2)=="29"))  
									
									(cArqInt)->OUTPROD	+= 0
	
								Else
									If lAntiICM .And. (cAliasSF3)->F3_VALANTI == 0
										(cArqInt)->OUTPROD	+=	(cAliasSF3)->F3_ICMSRET		//Outros produtos quando Substituicao Tributaria
									Endif									
								EndIf
							EndIf  
						Else //(cRef>"200804")
							If (SubStr ((cAliasSF3)->F3_CFO, 1, 1)$"56")
								If (((Val ((cAliasSF3)->F3_CFO)>=5401) .And. (Val ((cAliasSF3)->F3_CFO)<=5449)) .Or.;
									((Val ((cAliasSF3)->F3_CFO)>=5651) .And. (Val ((cAliasSF3)->F3_CFO)<=5699)) .Or.;				
									((Val ((cAliasSF3)->F3_CFO)>=6401) .And. (Val ((cAliasSF3)->F3_CFO)<=6449)) .Or.;
									((Val ((cAliasSF3)->F3_CFO)>=6651) .And. (Val ((cAliasSF3)->F3_CFO)<=6699)) .Or.;
									((Val ((cAliasSF3)->F3_CFO)==5360)) .Or.;
									((Val ((cAliasSF3)->F3_CFO)==6360)) .Or.;
									(SubStr ((cAliasSF3)->F3_CFO, 1, 2)=="59").Or.;
									(SubStr ((cAliasSF3)->F3_CFO, 1, 2)=="69"))
										
										
									If lAntiICM .And. (cAliasSF3)->F3_VALANTI == 0 .And. Val((cAliasSF3)->F3_CFO)<>6107 .And. Val((cAliasSF3)->F3_CFO)<>6109 .And. Val((cAliasSF3)->F3_CFO)<>6110 .And. Val((cAliasSF3)->F3_CFO)<>6119
										(cArqInt)->RETIDO	+=	(cAliasSF3)->F3_ICMSRET		//Outros produtos quando Substituicao Tributaria
									Endif
								Else
									(cArqInt)->RETIDO	+= 0
								EndIf
							
							ElseIf (SubStr ((cAliasSF3)->F3_CFO, 1, 1)$"12")
									If (((Val ((cAliasSF3)->F3_CFO)<>1360) .And. (Val ((cAliasSF3)->F3_CFO)>=1401) .And. (Val ((cAliasSF3)->F3_CFO)<=1449)) .Or.;
										((Val ((cAliasSF3)->F3_CFO)>=1651) .And. (Val ((cAliasSF3)->F3_CFO)<=1699)) .Or.;				
										((Val ((cAliasSF3)->F3_CFO)>=2401) .And. (Val ((cAliasSF3)->F3_CFO)<=2449)) .Or.;
										((Val ((cAliasSF3)->F3_CFO)>=2651) .And. (Val ((cAliasSF3)->F3_CFO)<=2699)) .Or.;
										(SubStr ((cAliasSF3)->F3_CFO, 1, 2)=="19") .Or.;
										(SubStr ((cAliasSF3)->F3_CFO, 1, 2)=="29"))   									    
										
										If lAntiICM .And. (cAliasSF3)->F3_VALANTI == 0
											(cArqInt)->OUTPROD	+=	(cAliasSF3)->F3_ICMSRET		//Outros produtos quando Substituicao Tributaria
										Endif
									Else
										(cArqInt)->OUTPROD	+= 0
									EndIf
							EndIf
						EndIf
				    EndIf
					MsUnlock()	
		 			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Zona Franca de Manaus /Areas de Livre Comercio CR=18?
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If Substr((cAliasSF3)->F3_CFO,1,1)=="6" .and. (cAliasSF3)->F3_ESTADO $ "AC/AP/AM/RO/RR/" .and. (cAliasSF3)->F3_ISENICM > 0
						cCGC		:=	""
						cCodMun		:=	""
						lZFranca	:= .T.
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//?Verifica se Cliente X Fornecedor e pega Insc. Estadual       ?
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If (cAliasSF3)->F3_TIPO$"BD"
							If SA2->(dbSeek(xFilial()+(cAliasSF3)->F3_CLIEFOR+(cAliasSF3)->F3_LOJA,.F.))
								cCGC	:=	SA2->A2_CGC
								If SA2->(FieldPos("A2_CODMUN"))>0
									cCodMun	:=	SA2->A2_CODMUN
								Endif
							Endif
						Else
							If lTms
								//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							    //?Integracao com TMS                                 ?
							    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
								PosTms ((cAliasSF3)->F3_NFISCAL, (cAliasSF3)->F3_SERIE)
								//
								If Empty (SA1->A1_SUFRAMA) .Or. SA1->A1_CALCSUF=="N"
									lZFranca	:= .F.
							 	Endif
							 	//
								cCGC	:=	SA1->A1_CGC
								//
								If SA1->(FieldPos("A1_CODMUN"))>0
									cCodMun	:=	SA1->A1_CODMUN
								Endif
							Else
								If SA1->(dbSeek(xFilial()+(cAliasSF3)->F3_CLIEFOR+(cAliasSF3)->F3_LOJA,.F.))
				   	    		     If Empty(SA1->A1_SUFRAMA) .Or. SA1->A1_CALCSUF=="N"
										lZFranca	:= .F.
									 Endif
									 cCGC	:=	SA1->A1_CGC
									If SA1->(FieldPos("A1_CODMUN"))>0
										cCodMun:=SA1->A1_CODMUN
									Endif
								Endif
							EndIf
						Endif
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//?Valida codigo do municipio                                   ?
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If SX5->(!dbSeek(xFilial()+"S1"+cCodMun))
							lZFranca	:= .F.
						EndIf
						If lZFranca      
							RECLOCK(cArqZFM,.T.)
							(cArqZFM)->CFOP		:=	(cAliasSF3)->F3_CFO	 //CFOP
							(cArqZFM)->UF		:=	cUF //Unidade de Federacao
							(cArqZFM)->NFISCAL	:=	(cAliasSF3)->F3_NFISCAL	//Nota Fiscal
							(cArqZFM)->EMISSAO	:=	(cAliasSF3)->F3_EMISSAO	//Data da Emissao
							(cArqZFM)->VALOR	:=	(cAliasSF3)->F3_VALCONT //Valor da nota fiscal
							(cArqZFM)->CNPJDES	:=	cCGC	//CGC do destinatario
							(cArqZFM)->MUNICIP	:=	cCodMun	//Codigo do Municipio
							(cArqZFM)->TIPOREG	:=  StrZero(nTipoReg,6)
							MSUnlock()			                                             
						
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
							//³Indica no Registro Detalhes Interestaduais que existe?
							//³operacoes beneficiadas por Isencao do ICMS.          ?
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
							If (cArqInt)->(dbSeek((cAliasSF3)->F3_CFO+cUF+StrZero(nTipoReg,6)))	
								RecLock(cArqInt,.F.)
								If Alltrim((cAliasSF3)->F3_CFO)<>"6107" .And. Alltrim((cAliasSF3)->F3_CFO)<>"6108"
									(cArqInt)->BENEF	:= "1"
									(cArqInt)->Q18	+=	1
								Endif
								MsUnlock()
							EndIf
						EndIf
					EndIf //Zona Franca
				EndIf //Detalhes interestaduais
			EndIf
	 	Endif

		If lRelDIPAM .Or. nRegime <> 4
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄ?
			//³DIPAM B CR=30?
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄ?
			If ExistBlock("MA972MUN") //-- CODIGO DE MUNICIPIO do cliente na geracao da Nova Gia, no quadro DIPAM B, CR = 30
				cCod_Mun := ExecBlock("MA972MUN",.F.,.F.,{cAliasSF3})
			Else
				cCod_Mun := A972RetMun (cAliasSf3, lTms)
			EndIf
			//--
			If ( Year(dDtFim) >= 2001 )
				If Substr((cAliasSF3)->F3_CFO,1,1) > "5"
					If	lTms
						cCodMunDp := StrZero(val(Alltrim(cCod_Mun)),5,0)
					Else
						If ExistBlock("MA972MUN") .And. Alltrim(cCod_Mun)<>''  
						   cCodMunDp := StrZero(val(Alltrim(cCod_Mun)),5,0)
						Else
						   cCodMunDp := StrZero(val(Alltrim(GetNewPar("MV_CODDP", "1004"))),5,0)
						EndIf 
					EndIf
				Elseif Substr((cAliasSF3)->F3_CFO,1,1) < "5"
					If (GetNewPar("MV_MUNA2", "X")<>"X")
						If (SA2->(FieldPos(AllTrim (SuperGetMv ("MV_MUNA2"))))>0)
							cCodMunDp	:= StrZero(Val(Alltrim(SA2->(FieldGet(FieldPos(SuperGetMv("MV_MUNA2")))))),5,0)
						Else
							cCodMunDp	:= "00000"
						EndIf
					Else
						cCodMunDp	:= "00000"
					EndIf
				Else
					cCodMunDp := StrZero(val(Alltrim(cCod_Mun)),5,0)
				EndIf
				Do Case
					Case (cVLayOut=="0208" .And. Alltrim(SM0->M0_CNAE)=='5620101') .Or. ; //tratamento para CNAE de Refeicoes fora do Municipio
					     (cCnae$"5620101/5131400/5146201/5241804/5524701") .And. ;
					     ( (nAno<2003  .And. Subs(Alltrim((cAliasSF3)->F3_CFO),1,3)$"511/512/514/515") .Or. ;
					       (nAno>=2003 .And. Subs(Alltrim((cAliasSF3)->F3_CFO),1,4)$"5101/5102/5103/5104") )
						If ( (cAliasSF3)->F3_BASEICM + (cAliasSF3)->F3_ISENICM + (cAliasSF3)->F3_OUTRICM > 0 )

							dbSelectArea(cArqDipam)
							dbSetOrder(1)
								If !lRelDIPAM
								If dbSeek("22"+cCodMunDp+StrZero(nTipoReg,6))
									RecLock(cArqDipam,.F.)
								Else
									RecLock(cArqCabec,.F.)
									(cArqCabec)->Q30	+=	1
									MsUnLock()
									RecLock(cArqDipam,.T.)
									CODDIP := "22"
									MUNICIP:= cCodMunDp 
									(cArqDipam)->TIPOREG	:=  StrZero(nTipoReg,6)
								EndIf
								VALOR  += (cAliasSF3)->F3_BASEICM + (cAliasSF3)->F3_ISENICM + (cAliasSF3)->F3_OUTRICM
								MsUnLock()
							Else
								SA1->(dbSeek(xFilial('SA1')+(cAliasSF3)->F3_CLIEFOR+(cAliasSF3)->F3_LOJA))							
								
								RecLock(cArqDipam,.T.)						
								FILIAL		:= (cAliasSF3)->F3_FILIAL
								CFOP		:= (cAliasSF3)->F3_CFO
								ENT_SAI 	:= "S"
								TIPO		:= (cAliasSF3)->F3_TIPO 	//Tipo da NF: N-Normal, D-Devolucao, B-Beneficiamento
								SERIE		:= (cAliasSF3)->F3_SERIE
								NOTA		:= (cAliasSF3)->F3_NFISCAL
								CLIFOR		:= (cAliasSF3)->F3_CLIEFOR
								LOJA		:= (cAliasSF3)->F3_LOJA
								ESTADO 		:= (cAliasSF3)->F3_ESTADO
								MUNICIP		:= Substr(SA1->A1_MUN,1,26)
								CODDIP 		:= "22"
								VALOR  		:= (cAliasSF3)->F3_BASEICM + (cAliasSF3)->F3_ISENICM + (cAliasSF3)->F3_OUTRICM
								MsUnLock()
							Endif
						EndIf
					Case ( (nAno<2003 .And. Subs(Alltrim((cAliasSF3)->F3_CFO),1,3)$"561/562/563/661/662/663/761") .Or. (nAno>=2003 .And. Subs(Alltrim((cAliasSF3)->F3_CFO),1,4)$"5351/5352/5353/5354/5355/5356/5357/5358/5359/5360/6351/6352/6353/6354/6355/6356/6357/6358/6359/6360/7358") )
						If ( (cAliasSF3)->F3_BASEICM + (cAliasSF3)->F3_ISENICM + (cAliasSF3)->F3_OUTRICM > 0 )
							dbSelectArea(cArqDipam)
							dbSetOrder(1)
							If !lRelDIPAM
								If dbSeek("23"+cCodMunDp+StrZero(nTipoReg,6))
									RecLock(cArqDipam,.F.)
								Else
									RecLock(cArqCabec,.F.)
									(cArqCabec)->Q30	+=	1
									MsUnLock()
									RecLock(cArqDipam,.T.)
									CODDIP := "23"
									MUNICIP:= cCodMunDp
									(cArqDipam)->TIPOREG	:=  StrZero(nTipoReg,6)
								EndIf
								VALOR  += (cAliasSF3)->F3_BASEICM + (cAliasSF3)->F3_ISENICM + (cAliasSF3)->F3_OUTRICM
								MsUnLock()
							Else
								SA1->(dbSeek(xFilial('SA1')+(cAliasSF3)->F3_CLIEFOR+(cAliasSF3)->F3_LOJA))								
								
								RecLock(cArqDipam,.T.)						
								FILIAL		:= (cAliasSF3)->F3_FILIAL
								CFOP		:= (cAliasSF3)->F3_CFO
								ENT_SAI 	:= "S"
								TIPO		:= (cAliasSF3)->F3_TIPO 	//Tipo da NF: N-Normal, D-Devolucao, B-Beneficiamento
								SERIE		:= (cAliasSF3)->F3_SERIE
								NOTA		:= (cAliasSF3)->F3_NFISCAL
								CLIFOR		:= (cAliasSF3)->F3_CLIEFOR
								LOJA		:= (cAliasSF3)->F3_LOJA
								
								If IntTMS() .And. lRelDIPAM 
									If DT6->(MsSeek(xFilial("DT6")+(cAliasSF3)->(F3_FILIAL+F3_NFISCAL+F3_SERIE)))
										If DUY->(MsSeek(XFilial("DUY")+DT6->DT6_CDRORI))
											ESTADO := DUY->DUY_EST		
											MUNICIP:= DUY->DUY_DESCRI
										EndIf
									EndIf	
								Else
									ESTADO	:= (cAliasSF3)->F3_ESTADO
									MUNICIP	:= Substr(SA1->A1_MUN,1,26)
								EndIf
								
								CODDIP 		:= "23"
								VALOR  		:= (cAliasSF3)->F3_BASEICM + (cAliasSF3)->F3_ISENICM + (cAliasSF3)->F3_OUTRICM
								MsUnLock()
							Endif
						EndIf
					Case ((nAno<2003 .And. Subs(Alltrim((cAliasSF3)->F3_CFO),1,3)$"551/552/553") .Or. (nAno>2003 .And. Subs(Alltrim((cAliasSF3)->F3_CFO),1,4)$"5301/5302/5303/5304/5305/5306/5307/6301/6302/6303/6304/6305/6306/7301"))
							dbSelectArea(cArqDipam)
							dbSetOrder(1)
							If !lRelDIPAM
								n24Sai += (cAliasSF3)->F3_BASEICM + (cAliasSF3)->F3_ISENICM + (cAliasSF3)->F3_OUTRICM								
								If dbSeek("24"+cCodMunDp+StrZero(nTipoReg,6))
									RecLock(cArqDipam,.F.)
								Else
									RecLock(cArqCabec,.F.)
									(cArqCabec)->Q30	+=	1
									MsUnLock()
									RecLock(cArqDipam,.T.)
									CODDIP := "24"
									MUNICIP:= cCodMunDp   
									(cArqDipam)->TIPOREG	:=  StrZero(nTipoReg,6)
								EndIf
								VALOR  += (cAliasSF3)->F3_BASEICM + (cAliasSF3)->F3_ISENICM + (cAliasSF3)->F3_OUTRICM
								MsUnLock()
							Else
								SA1->(dbSeek(xFilial('SA1')+(cAliasSF3)->F3_CLIEFOR+(cAliasSF3)->F3_LOJA))								
								
								RecLock(cArqDipam,.T.)						
								FILIAL		:= (cAliasSF3)->F3_FILIAL
								CFOP		:= (cAliasSF3)->F3_CFO
								ENT_SAI 	:= "S"
								TIPO		:= (cAliasSF3)->F3_TIPO 	//Tipo da NF: N-Normal, D-Devolucao, B-Beneficiamento
								SERIE		:= (cAliasSF3)->F3_SERIE
								NOTA		:= (cAliasSF3)->F3_NFISCAL
								CLIFOR		:= (cAliasSF3)->F3_CLIEFOR
								LOJA		:= (cAliasSF3)->F3_LOJA
							   
								If IntTMS() .And. lRelDIPAM 
									If DT6->(MsSeek(xFilial("DT6")+(cAliasSF3)->(F3_FILIAL+F3_NFISCAL+F3_SERIE)))
										If DUY->(MsSeek(XFilial("DUY")+DT6->DT6_CDRORI))
											ESTADO := DUY->DUY_EST		
											MUNICIP:= DUY->DUY_DESCRI
										EndIf
									EndIf	
								Else
									ESTADO	:= (cAliasSF3)->F3_ESTADO
									MUNICIP	:= Substr(SA1->A1_MUN,1,26)
								EndIf
								
								CODDIP 		:= "24"
								VALOR  		:= (cAliasSF3)->F3_BASEICM + (cAliasSF3)->F3_ISENICM + (cAliasSF3)->F3_OUTRICM
								MsUnLock()							
							Endif
					Case ( (nAno<2003 .And. Subs(Alltrim((cAliasSF3)->F3_CFO),1,3)$"541/542/543/544/545/546/641/642/643/644/645/646") .Or. (nAno>=2003 .And. Subs(Alltrim((cAliasSF3)->F3_CFO),1,4)$"5251/5252/5253/5254/5255/5256/5257/5258/6251/6252/6253/6254/6255/6256/6257/6258/7251") )
							dbSelectArea(cArqDipam)
							dbSetOrder(1)
							If !lRelDIPAM
								If dbSeek("25"+cCodMunDp+StrZero(nTipoReg,6))
									RecLock(cArqDipam,.F.)
								Else
									RecLock(cArqCabec,.F.)
									(cArqCabec)->Q30	+=	1
									MsUnLock()
									RecLock(cArqDipam,.T.)
									CODDIP := "25"
									MUNICIP:= cCodMunDp 
									(cArqDipam)->TIPOREG	:=  StrZero(nTipoReg,6)
								EndIf
								VALOR  += (cAliasSF3)->F3_BASEICM + (cAliasSF3)->F3_ISENICM + (cAliasSF3)->F3_OUTRICM
								MsUnLock()
							Else
								SA1->(dbSeek(xFilial('SA1')+(cAliasSF3)->F3_CLIEFOR+(cAliasSF3)->F3_LOJA))								
								
								RecLock(cArqDipam,.T.)						
								FILIAL		:= (cAliasSF3)->F3_FILIAL
								CFOP		:= (cAliasSF3)->F3_CFO
								ENT_SAI 	:= "S"
								TIPO		:= (cAliasSF3)->F3_TIPO 	//Tipo da NF: N-Normal, D-Devolucao, B-Beneficiamento
								SERIE		:= (cAliasSF3)->F3_SERIE
								NOTA		:= (cAliasSF3)->F3_NFISCAL
								CLIFOR		:= (cAliasSF3)->F3_CLIEFOR
								LOJA		:= (cAliasSF3)->F3_LOJA
								
								If IntTMS() .And. lRelDIPAM 
									If DT6->(MsSeek(xFilial("DT6")+(cAliasSF3)->(F3_FILIAL+F3_NFISCAL+F3_SERIE)))
										If DUY->(MsSeek(XFilial("DUY")+DT6->DT6_CDRORI))
											ESTADO := DUY->DUY_EST		
											MUNICIP:= DUY->DUY_DESCRI
										EndIf
									EndIf	
								Else
									ESTADO	:= (cAliasSF3)->F3_ESTADO
									MUNICIP	:= Substr(SA1->A1_MUN,1,26)
								EndIf
								
								CODDIP 		:= "25"
								VALOR  		:= (cAliasSF3)->F3_BASEICM + (cAliasSF3)->F3_ISENICM + (cAliasSF3)->F3_OUTRICM
								MsUnLock()								
							Endif
					//Compra Escriturada de Mercadorias de Produtores Agropecuarios
					Case SubStr(AllTrim((cAliasSF3)->F3_CFO),1,1)=="1" .And. !Empty(SA2->A2_TIPORUR) .And. Alltrim((cAliasSF3)->F3_CFO)$cDip11
							dbSelectArea(cArqDipam)
							dbSetOrder(1)
							If !lRelDIPAM
								If dbSeek("11"+cCodMunDp+StrZero(nTipoReg,6))
									RecLock(cArqDipam,.F.)
								Else
									RecLock(cArqCabec,.F.)
									(cArqCabec)->Q30	+=	1
									MsUnLock()
									RecLock(cArqDipam,.T.)
									CODDIP := "11"
									MUNICIP:= cCodMunDp 
									(cArqDipam)->TIPOREG	:=  StrZero(nTipoReg,6)
								EndIf
								VALOR  += (cAliasSF3)->F3_BASEICM + (cAliasSF3)->F3_ISENICM + (cAliasSF3)->F3_OUTRICM
								MsUnLock()
							Else
								SA2->(dbSeek(xFilial('SA2')+(cAliasSF3)->F3_CLIEFOR+(cAliasSF3)->F3_LOJA))							
								
								RecLock(cArqDipam,.T.)						
								FILIAL		:= (cAliasSF3)->F3_FILIAL
								CFOP		:= (cAliasSF3)->F3_CFO
								ENT_SAI 	:= "E"
								TIPO		:= (cAliasSF3)->F3_TIPO 	//Tipo da NF: N-Normal, D-Devolucao, B-Beneficiamento
								SERIE		:= (cAliasSF3)->F3_SERIE
								NOTA		:= (cAliasSF3)->F3_NFISCAL
								CLIFOR		:= (cAliasSF3)->F3_CLIEFOR
								LOJA		:= (cAliasSF3)->F3_LOJA
								ESTADO 		:= (cAliasSF3)->F3_ESTADO
								MUNICIP		:= Substr(SA2->A2_MUN,1,26)
								CODDIP 		:= "11"
								VALOR  		:= (cAliasSF3)->F3_BASEICM + (cAliasSF3)->F3_ISENICM + (cAliasSF3)->F3_OUTRICM
								MsUnLock()							
							Endif
					//Recebimento por Cooperativa de Mercadoria remetida por Produtores Agropecuarios
					Case SubStr(AllTrim((cAliasSF3)->F3_CFO),1,1)=="1" .And. !Empty(SA2->A2_TIPORUR) .And. Alltrim((cAliasSF3)->F3_CFO)$cDip13
						dbSelectArea(cArqDipam)
						dbSetOrder(1)
						If !lRelDIPAM
							If dbSeek("13"+cCodMunDp+StrZero(nTipoReg,6))
								RecLock(cArqDipam,.F.)
							Else
								RecLock(cArqCabec,.F.)
								(cArqCabec)->Q30	+=	1
								MsUnLock()
								RecLock(cArqDipam,.T.)
								CODDIP := "13"
								MUNICIP:= cCodMunDp
								(cArqDipam)->TIPOREG	:=  StrZero(nTipoReg,6)
							EndIf
							VALOR  += (cAliasSF3)->F3_BASEICM + (cAliasSF3)->F3_ISENICM + (cAliasSF3)->F3_OUTRICM
							MsUnLock()
						Else
							SA2->(dbSeek(xFilial('SA2')+(cAliasSF3)->F3_CLIEFOR+(cAliasSF3)->F3_LOJA))							
							
							RecLock(cArqDipam,.T.)						
							FILIAL		:= (cAliasSF3)->F3_FILIAL
							CFOP		:= (cAliasSF3)->F3_CFO
							ENT_SAI 	:= "E"
							TIPO		:= (cAliasSF3)->F3_TIPO 	//Tipo da NF: N-Normal, D-Devolucao, B-Beneficiamento
							SERIE		:= (cAliasSF3)->F3_SERIE
							NOTA		:= (cAliasSF3)->F3_NFISCAL
							CLIFOR		:= (cAliasSF3)->F3_CLIEFOR
							LOJA		:= (cAliasSF3)->F3_LOJA
							ESTADO 		:= (cAliasSF3)->F3_ESTADO
							MUNICIP		:= Substr(SA2->A2_MUN,1,26)
							CODDIP 		:= "13"
							VALOR  		:= (cAliasSF3)->F3_BASEICM + (cAliasSF3)->F3_ISENICM + (cAliasSF3)->F3_OUTRICM
							MsUnLock()							
						Endif
					Case ((nAno>=2003 .And. (Subs(Alltrim((cAliasSF3)->F3_CFO),1,4)$"5301/5302/5303/5304/5305/5306/5307/6301/6302/6303/6304/6305/6306/6307/7301") .OR. Subs(Alltrim((cAliasSF3)->F3_CFO),1,4)$"1301/2301/3301"))
							dbSelectArea(cArqDipam)
							dbSetOrder(1)
							If !lRelDIPAM 
								If Substr((cAliasSF3)->F3_CFO,1,4)$"1301/2301/3301"
								    n24Ent += (cAliasSF3)->F3_BASEICM + (cAliasSF3)->F3_ISENICM + (cAliasSF3)->F3_OUTRICM                                
								Else
								    n24Sai += (cAliasSF3)->F3_BASEICM + (cAliasSF3)->F3_ISENICM + (cAliasSF3)->F3_OUTRICM
									If dbSeek("24"+cCodMunDp+StrZero(nTipoReg,6))
										RecLock(cArqDipam,.F.)
									Else
										If Substr((cAliasSF3)->F3_CFO,1,1) >= "5"
										    RecLock(cArqCabec,.F.)
										    (cArqCabec)->Q30	+=	1
										    MsUnLock() 
										    RecLock(cArqDipam,.T.)
											CODDIP := "24"
									   		MUNICIP:= cCodMunDp
									   		(cArqDipam)->TIPOREG	:=  StrZero(nTipoReg,6) 
										EndIf             
									EndIf 
									VALOR  += (cAliasSF3)->F3_BASEICM + (cAliasSF3)->F3_ISENICM + (cAliasSF3)->F3_OUTRICM
									MsUnLock()
									EndIf
							Else
								SA1->(dbSeek(xFilial('SA1')+(cAliasSF3)->F3_CLIEFOR+(cAliasSF3)->F3_LOJA))
								
								RecLock(cArqDipam,.T.)						
								FILIAL		:= (cAliasSF3)->F3_FILIAL
								CFOP		:= (cAliasSF3)->F3_CFO
								ENT_SAI 	:= "S"
								TIPO		:= (cAliasSF3)->F3_TIPO 	//Tipo da NF: N-Normal, D-Devolucao, B-Beneficiamento
								SERIE		:= (cAliasSF3)->F3_SERIE
								NOTA		:= (cAliasSF3)->F3_NFISCAL
								CLIFOR		:= (cAliasSF3)->F3_CLIEFOR
								LOJA		:= (cAliasSF3)->F3_LOJA
								ESTADO 		:= (cAliasSF3)->F3_ESTADO
								MUNICIP		:= Substr(SA1->A1_MUN,1,26)
								CODDIP 		:= "24"
								VALOR  		:= (cAliasSF3)->F3_BASEICM + (cAliasSF3)->F3_ISENICM + (cAliasSF3)->F3_OUTRICM
								MsUnLock()							
							Endif
				EndCase
			EndIf
	
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿            
			//³Reg Exportacao CR=31?
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ                          	        
			If !lRelDIPAM .And. lD2_Re
				lGeraExp := .T.
				If ((cVValid == "0740" .and. cVLayOut == "0204") .And. (cRef<="200112")) .Or.;
				 	((cVValid == "0750" .and. cVLayOut == "0205") .And. (cRef<="200112")) .Or. ;
				 	((cVValid == "0760" .and. cVLayOut == "0206") .And. (cRef<="200112")) .Or.;
				 	((cVValid == "0770" .and. cVLayOut == "0207") .And. (cRef<="200112")) .Or.;
				 	((cVValid == "0780" .and. cVLayOut == "0208") .And. (cRef<="200112")) .or.;
				 	((cVValid == "0790" .and. cVLayOut == "0209") .And. (cRef<="200112")) .Or.;
				 	((cVValid == "0800" .and. cVLayOut == "0210") .And. (cRef<="200112")) 
					lGeraExp := .F.
				Endif              
				If lGeraExp		
					
					If SD2->(dbSeek(xFilial("SD2")+(cAliasSF3)->F3_NFISCAL+(cAliasSF3)->F3_SERIE))
						While SD2->(!Eof()) .and. (cAliasSF3)->F3_NFISCAL+(cAliasSF3)->F3_SERIE == SD2->D2_DOC+SD2->D2_SERIE .and.;
								 (xFilial("SD2") == (cAliasSF3)->F3_FILIAL)

								dbSelectArea(cArqExpt)
								dbSetOrder(1)
								nT  		:= 0
								//Se tiver integração para com EEC e o campo nao estiver criado, emitir aviso e retornar. 
								If SD2->(FieldPos(cD2_Re))==0 .and. SuperGetMV("MV_EECFAT")	
									Aviso("Integração com o módulo SIGAEEC Habilitada ","Por favor crie o campo " + cD2_Re + " via configurador.",{"Ok"}) //Não foi possivel excluir a nota, pois a mesma j?foi transmitida e encotra-se bloqueada. Ser?necessário realizar a primeiro a classificação da nota e posteriormente a exclusão!"		
									return
								EndIf            
								If lD2_Re .And. "D2_"$cD2_Re
									cRe := SD2->&cD2_Re
								Endif
								For nT:=33 to 255
									If (nT >= 33 .and. nT <= 47) .or. (nT >= 58 .and. nT <= 64) .or. (nT >= 91 .and. nT <= 96) .or. (nT >= 123 .and. nT <= 255)
									    If (at(CHR(nT),cRe)) > 0
											cRe := StrTran(cRe,CHR(nT),"")
										EndIf
									EndIf
								Next nT
								cRe := If(Empty(cRe),cRe,Strzero(val(Alltrim(cRe)),15,0))
								
								If !Empty(cRe) .And. !dbSeek(cRe)
								   RecLock(cArqExpt,.T.)
								   (cArqExpt)->RE := cRe
								   (cArqExpt)->TIPOREG	:=  StrZero(nTipoReg,6)
								   MsUnLock()
								   RecLock(cArqCabec,.F.)
								   (cArqCabec)->Q31	+=	1
								   MsUnLock()
								EndIf

							SD2->(dbSkip())
						EndDo
                    EndIf
                EndIf 
          	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿            
			//³Reg Exportacao CR=31?
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ              
            Elseif !lRelDIPAM .And. !lD2_Re
           		lGeraExp := .T.
				If ((cVValid == "0740" .and. cVLayOut == "0204") .And. (cRef<="200112")) .Or.;
	 				((cVValid == "0750" .and. cVLayOut == "0205") .And. (cRef<="200112")) .Or. ;
				 	((cVValid == "0760" .and. cVLayOut == "0206") .And. (cRef<="200112")) .Or.;
				 	((cVValid == "0770" .and. cVLayOut == "0207") .And. (cRef<="200112")) .Or.;
				 	((cVValid == "0780" .and. cVLayOut == "0208") .And. (cRef<="200112")) .or.;
				 	((cVValid == "0790" .and. cVLayOut == "0209") .And. (cRef<="200112")) .Or.;
				 	((cVValid == "0800" .and. cVLayOut == "0210") .And. (cRef<="200112")) 
					lGeraExp := .F.
				Endif              
		
				If lGeraExp 
		    		If SD2->(dbSeek(xFilial("SD2")+(cAliasSF3)->F3_NFISCAL+(cAliasSF3)->F3_SERIE))
		
						dbSelectArea(cArqExpt)
						dbSetOrder(1)								 
						
						If dbSeek(xFilial("EE9")+SD2->D2_PREEMB)  
						
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Processamento da funcao da Average que retorna os avisos de embarque conforme regras do SIGAEEC ?
						//|Conforme solicitado nos Chamados: THMQEB e THMOIB, he necessário as datas de RE e DSE para o R31|
						//|                     FUNCAO DISPONIBILIZADA PELA AVEGARE - FONTE AVGERAL.PRW                    |
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ						
							acRe := EasySpedRes(cValToChar(Month(SD2->D2_EMISSAO)),cValToChar(Year(SD2->D2_EMISSAO)))
							 
							If Len(acRe) > 0                     					                      
								If aScan(acRebk,{|aX|aX==acRe[1][2]})==0
									For nx:= 1 to Len(acRe)								
										cRe := Strzero(val(Alltrim(acRe[nx][2])),15,0)
										RecLock(cArqExpt,.T.)
										(cArqExpt)->RE := cRe						
										(cArqExpt)->TIPOREG	:=  StrZero(nTipoReg,6)
										MsUnLock()
										RecLock(cArqCabec,.F.)
										(cArqCabec)->Q31 +=	 1
										MsUnLock()
									Next nx															
									
									Aadd(acRebk,acRe[1][2])
								EndIf							
							EndIf
						Endif												 
		    		EndIf
	    		EndIf              
            EndIf
            
		Endif
    (cAliasSF3)->( dbSkip() )
    End
		//ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
		//³Ocorrencias CR=20?
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?                  
		If !lRelDIPAM
			aApuICM := FisApur("IC",nAno,nMes,2,0,"*",.F.,{},1,.F.,"")
			aApuST  := FisApur("ST",nAno,nMes,2,0,"*",.F.,{},1,.F.,"")
			
			For nX := 1 to len(aApuICM)
			
				//lOcorrGen -> Variavel que indica um registro de ocorrencia generica (99)
				//Nesse caso, o validador permite que seja utilizado o sexto caracter de subitem para diferenciar
				//as ocorrencias, portanto devo verificar ateh o sexto caracter para segregar as informacoes do arquivo
				//Exemplo:	007.991 -> Legislacao 1
				//			007.992 -> Legislacao 2
				//Arquivo:	20007990000000000200000Legislacao 1
				//			20007990000000000200000Legislacao 2
				//Teoricamente seriam linhas duplicadas, porem o validador permite para os codigos genericos
				lOcorrGen := .F.
				
				If alltrim(aApuICM[nX][1])$"002#003#006#007#012" .and. aApuICM[nX][3] > 0
					cSubCod := RetChar(alltrim(aApuICM[nX][4]),.F.,.F.,.F.,.T.,.F.,6,.F.)
					
					//Verifico se eh sub codigo generico
					If SubStr( cSubCod , 4 , 2 ) <> "99"
						cSubCod := SubStr( cSubCod , 1 , 5 )
					Else
						cSubCod		:= Alltrim( cSubCod )                    	
						lOcorrGen	:= .T.
					Endif
					
					dbSelectArea(cArqOcor)
					If !(cSubCod$"00200#00300#00600#00700#01200")
						If (cArqOcor)->( dbSeek( PadR( cSubCod , Len( (cArqOcor)->SUBITEM ) ) + "0" ) ) 
							RecLock(cArqOcor,.F.) 
						Else 
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
							//³Caso existam codigos duplicados na apuracao, ira criar apenas uma linha?
							//³no CR=20, acumulando os valores.                                       ?
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
							// Isaac Silva 16/12/09
							RecLock(cArqOcor,.T.)          					    
						    (cArqOcor)->SUBITEM := cSubCod
						    (cArqOcor)->PRO_ST  := "0"
						    If lOcorrGen
						    	(cArqOcor)->FLEGAL  := If(!Empty(alltrim(aApuICM[nX][2])),alltrim(aApuICM[nX][2]),"OUTRAS HIPOTESES")
								(cArqOcor)->OCORREN := If(!Empty(alltrim(aApuICM[nX][2])),alltrim(aApuICM[nX][2]),"OUTRAS HIPOTESES")
							Else
								(cArqOcor)->FLEGAL  := Space(100)
								(cArqOcor)->OCORREN := Space(300)
							EndIf	 
					    	(cArqOcor)->CODAUTO := alltrim(aApuICM[nX][2])
							
							nQtdQ20:=aScan(aQ20,{|x| x[1] == "20"+Alltrim((cArqOcor)->SUBITEM)+Alltrim((cArqOcor)->PRO_ST)})
							If nQtdQ20==0
								aAdd(aQ20,{"20"+Alltrim((cArqOcor)->SUBITEM)+Alltrim((cArqOcor)->PRO_ST)})		    		
								RecLock(cArqCabec,.f.)
								(cArqCabec)->Q20	+=	1 
								(cArqOcor)->TIPOREG	:=  StrZero(nTipoReg,6)
						        (cArqCabec)->(MsUnlock())
						  	Endif   
						Endif
						(cArqOcor)->VALOR   += aApuICM[nX][3]
						If (cArqCabec)->REF >= "201004"
								If cSubCod $ "00220|00221|00740|00741" 
								   	If (cCredAcum)->(dbSeek( PadR( cSubCod , Len( (cArqOcor)->SUBITEM ) ) +alltrim(aApuICM[nX][2]))) 
							            RecLock(cCredAcum,.F.)
							            (cCredAcum)->VALOR   += aApuICM[nX][3] 
								   	Else
								   		RecLock(cCredAcum,.T.) 
								   		(cCredAcum)->SUBITEM := cSubCod
								    	(cCredAcum)->CODAUTO := alltrim(aApuICM[nX][2])
								    	(cCredAcum)->VALOR   := aApuICM[nX][3]
								    	(cCredAcum)->TIPOREG :=  StrZero(nTipoReg,6)
								    	(cArqOcor)->Q28		+= 1
								    	(cArqOcor)->TIPOREG	:=  StrZero(nTipoReg,6)
								    EndIf 	
								    (cCredAcum)->(MsUnlock())
						        Endif
						Endif
			
						If (cArqCabec)->REF >= "201201"
								If cSubCod $ "00223|00744|00745" 
									If (cCredAcum)->(dbSeek( PadR( cSubCod , Len( (cArqOcor)->SUBITEM ) ) +alltrim(aApuICM[nX][2])))
							            RecLock(cCredAcum,.F.)
							            (cCredAcum)->VALOR	+= aApuICM[nX][3] 
								   	Else
									   	RecLock(cCredAcum,.T.) 
									   		(cCredAcum)->SUBITEM := cSubCod
									    	(cCredAcum)->CODAUTO := alltrim(aApuICM[nX][2])
									    	(cCredAcum)->VALOR   := aApuICM[nX][3] 
									    	(cCredAcum)->TIPOREG :=  StrZero(nTipoReg,6)
									    	(cArqOcor)->Q28		+= 1 
									    	(cArqOcor)->TIPOREG	:=  StrZero(nTipoReg,6)
									 EndIf
									 (cCredAcum)->(MsUnlock())
						        Endif
						Endif
						(cArqOcor)->(MsUnlock())
					EndIf	    						
				EndIf	
			Next nX                               
			
			For nY := 1 to len(aApuST)
				If alltrim(aApuST[nY][1])$"002#003#007#008" .and. aApuST[nY][3] > 0
					cSubCod := RetChar(alltrim(aApuST[nY][4]),.T.,.F.,.F.,.T.,.F.,5,.F.)	    
					If !(cSubCod$"00200#00300#00700#00800")
						dbSelectArea(cArqOcor)
					    If (cArqOcor)->(dbSeek(cSubCod+"1"))
							RecLock(cArqOcor,.F.)          
						Else
							RecLock(cArqOcor,.T.)          					    
						    (cArqOcor)->SUBITEM := cSubCod
							(cArqOcor)->PRO_ST  := "1"
							If Substr(cSubCod,4,5) == "99"
						    	(cArqOcor)->FLEGAL  := If(!Empty(alltrim(aApuST[nY][2])),alltrim(aApuST[nY][2]),"OUTRAS HIPOTESES")
								(cArqOcor)->OCORREN := If(!Empty(alltrim(aApuST[nY][2])),alltrim(aApuST[nY][2]),"OUTRAS HIPOTESES")
							Else
								(cArqOcor)->FLEGAL  := Space(100)
								(cArqOcor)->OCORREN := Space(300)
							EndIf
					    	(cArqOcor)->CODAUTO := alltrim(aApuST[nY][2])
				    		nQtdQ20:=aScan(aQ20,{|x| x[1] == "20"+Alltrim((cArqOcor)->SUBITEM)+Alltrim((cArqOcor)->PRO_ST)})
							If nQtdQ20==0
								aAdd(aQ20,{"20"+Alltrim((cArqOcor)->SUBITEM)+Alltrim((cArqOcor)->PRO_ST)})		    		
								RecLock(cArqCabec,.f.)
								(cArqCabec)->Q20	+=	1
								(cArqOcor)->TIPOREG	:=  StrZero(nTipoReg,6)
						        MsUnlock()	
						  	Endif   
					    EndIf
				
						(cArqOcor)->VALOR   += aApuST[nY][3]
					    MsUnlock()
					    
					EndIf	        
				EndIf	
			Next nY
		Endif	
		
	//
	If FWModeAccess("SF3",3)=="C" 
		Exit
	//Else
   	//	SM0->(dbSkip())	
	Endif
	
	//SM0->(DbSkip ())
	//
	If lQuery
	    dbSelectArea(cAliasSF3)
		dbCloseArea()
	 	Ferase(cIndSF3+OrdBagExt())
		dbSelectArea("SF3")
		RetIndex("SF3")
	Endif   	
	
Next(n0) //Next da SM0 para a mesma EMPRESA

If !lRelDIPAM .And.n24Ent > 0
	//tratamento para o código 24 do CR=30
	n24Tot := n24Sai - n24Ent
	dbSelectArea(cArqDipam)
	If (cArqDipam)->(dbSeek("24"))
		While !((cArqDipam)->(Eof()))
			If (cArqDipam)->CODDIP == "24"
				nPerc := (cArqDipam)->VALOR/n24Sai
				RecLock(cArqDipam,.F.)
				(cArqDipam)->VALOR := n24Tot*nPerc
				MsUnLock()
			Endif
			dbSelectArea(cArqDipam)
			(cArqDipam)->(dbSkip())
		EndDo
	EndIf
EndIf	

RestArea (aAreaSm0)
cFilAnt		:=	FWGETCODFILIAL

If lRelDIPAM
	Return(cArqDipam)
Endif

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ?
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±?
±±ÉÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±?
±±ºFuncao  ³a972CriaTempºAutor  ³Andreia dos Santos  ?Data ? 26/06/00   º±?
±±ÌÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±?
±±ºDesc.   ³Cria todos os arquivos temporarios necessarios a geracao da   º±?
±±?       ³GIA                                                           º±?
±±ÌÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±?
±±ºUso     ?MATA972                                                      º±?
±±ÈÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±?
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±?
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß?
*/

Static Function a972CriaTemp(lRelDIPAM)                        

Local aCampos	:=	{}
Local cAlias	:=	Alias()
Local aTam		:= TAMSX3("F3_CFO")

Default lRelDIPAM := .F.

If !lRelDIPAM
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Arquivo do Cabecalho do Doc.Fiscal CR=05?
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	AADD(aCampos,{"IE"		,"C"	,012,0})
	AADD(aCampos,{"CNPJ"	,"C"	,014,0})
	AADD(aCampos,{"CNAE"	,"C"	,007,0})
	AADD(aCampos,{"REGTRIB"	,"C"	,002,0})
	AADD(aCampos,{"REF"		,"C"	,006,0})
	AADD(aCampos,{"REFINIC"	,"C"	,006,0})
	AADD(aCampos,{"TIPO"	,"C"	,002,0})
	AADD(aCampos,{"MOVIMEN"	,"C"	,001,0})
	AADD(aCampos,{"TRANSMI"	,"C"	,001,0})
	AADD(aCampos,{"SALDO"	,"N"	,015,2})
	AADD(aCampos,{"SALDOST"	,"N"	,015,2})
	AADD(aCampos,{"ORIGSOF"	,"C"	,014,0})
	AADD(aCampos,{"ORIGARQ"	,"C"	,001,0})
	AADD(aCampos,{"ICMSFIX"	,"N"	,015,2})
	AADD(aCampos,{"Q07"		,"N"	,004,0})
	AADD(aCampos,{"Q10"		,"N"	,004,0})
	AADD(aCampos,{"Q20"		,"N"	,004,0})
	AADD(aCampos,{"Q30"		,"N"	,004,0})
	AADD(aCampos,{"Q31"		,"N"	,004,0})
	AADD(aCampos,{"TIPOREG"	,"C"	,006,0})
	cArqCabec	:=	CriaTrab(aCampos)
	dbUseArea(.T.,__LocalDriver,cArqCabec,cArqCabec,.T.,.F.)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Arquivo Detalhes CFOPs CR=10?
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aCampos	:=	{}
	AADD(aCampos,{"CFOP"    ,"C"	,aTam[1],0})
	AADD(aCampos,{"VALCONT" ,"N"	,015,2})
	AADD(aCampos,{"BASEICM"	,"N"	,015,2})
	AADD(aCampos,{"VALTRIB"	,"N"	,015,2})
	AADD(aCampos,{"ISENTA"	,"N"	,015,2})
	AADD(aCampos,{"OUTRAS"	,"N"	,015,2})
	AADD(aCampos,{"RETIDO"	,"N"	,015,2})
	AADD(aCampos,{"RtStSt"	,"N"	,015,2})
	AADD(aCampos,{"RtSbSt"	,"N"	,015,2})	
	AADD(aCampos,{"IMPOSTO"	,"N"	,015,2})
	AADD(aCampos,{"Q14"		,"N"	,004,0})
	AADD(aCampos,{"TIPOREG" ,"C"	,006,0})
		
	cArqCFO	:=	CriaTrab(aCampos)
	dbUseArea(.T.,__LocalDriver,cArqCFO,cArqCFO,.T.,.F.)
	IndRegua(cArqCFO,cArqCFO,"CFOP+TIPOREG",,,STR0009) //"Indexando Detalhes de CFOP" 
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
	//³Arquivo Detalhes interestaduais CR=14?
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
	aCampos	:=	{}
	AADD(aCampos,{"CFOP"   	,"C"	,aTam[1],0})
	AADD(aCampos,{"UF"   	,"C"	,002,0})
	AADD(aCampos,{"VALCONT" ,"N"	,015,2})
	AADD(aCampos,{"BASECON"	,"N"	,015,2})
	AADD(aCampos,{"VALNCON"	,"N"	,015,2})
	AADD(aCampos,{"BASENCO"	,"N"	,015,2})
	AADD(aCampos,{"ISENTA"	,"N"	,015,2})
	AADD(aCampos,{"IMPOSTO"	,"N"	,015,2}) //Imposto creditado ou debitado
	AADD(aCampos,{"OUTRAS"	,"N"	,015,2})
	AADD(aCampos,{"RETIDO"	,"N"	,015,2})
	AADD(aCampos,{"PETROL"	,"N"	,015,2})
	AADD(aCampos,{"OUTPROD"	,"N"	,015,2})
	AADD(aCampos,{"BENEF"	,"C"	,001,2})
	AADD(aCampos,{"Q18"		,"N"	,004,0})
	AADD(aCampos,{"TIPOREG" ,"C"	,006,0})
		
	cArqInt	:=	CriaTrab(aCampos)
	dbUseArea(.T.,__LocalDriver,cArqInt,cArqInt,.T.,.F.)
	IndRegua(cArqInt,cArqInt,"CFOP+UF+TIPOREG",,,STR0010) //"Indexando Operacoes interestaduais"
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
	//³Arquivo ZFM/ALC?
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
	aCampos	:=	{}
	AADD(aCampos,{"CFOP"   	,"C"	,aTam[1],0})
	AADD(aCampos,{"UF"   	,"C"	,002,0})
	AADD(aCampos,{"NFISCAL" ,"C"	,TamSX3("F2_DOC")[1],0})
	AADD(aCampos,{"EMISSAO" ,"D"	,008,0})
	AADD(aCampos,{"VALOR"	,"N"	,015,2})
	AADD(aCampos,{"CNPJDES"	,"C"	,014,0})
	AADD(aCampos,{"MUNICIP"	,"C"	,005,0})
	AADD(aCampos,{"TIPOREG" ,"C"	,006,0})
	
	cArqZFM	:=	CriaTrab(aCampos)
	dbUseArea(.T.,__LocalDriver,cArqZFM,cArqZFM,.T.,.F.)
	IndRegua(cArqZFM,cArqZFM,"CFOP+UF+TIPOREG",,,STR0011) //"Indexando ZFM/ALC"
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Arquivo de Ocorrencias CR=20?
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aCampos	:=	{}
	AADD(aCampos,{"SUBITEM" ,"C"	,006,0})
	AADD(aCampos,{"VALOR"	,"N"	,015,2})
	AADD(aCampos,{"PRO_ST"	,"C"	,001,0})
	AADD(aCampos,{"FLEGAL"	,"C"	,100,0})
	AADD(aCampos,{"OCORREN"	,"C"	,300,0})
	AADD(aCampos,{"Q25"    	,"N"	,004,0})
	AADD(aCampos,{"Q26"    	,"N"	,004,0})
	AADD(aCampos,{"Q27"    	,"N"	,004,0})
	AADD(aCampos,{"Q28"    	,"N"	,004,0})	                                    
	AADD(aCampos,{"CODAUTO"	,"C"	,012,0})
	AADD(aCampos,{"TIPOREG" ,"C"	,006,0})

	cArqOcor	:=	CriaTrab(aCampos)
	dbUseArea(.T.,__LocalDriver,cArqOcor,cArqOcor,.T.,.F.)
	IndRegua(cArqOcor,cArqOcor,"SUBITEM+PRO_ST+TIPOREG",,,STR0012)  //"Indexando Ocorrencias"
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
	//³Arquivo de Remetentes CR=25?
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
	aCampos	:=	{}
	AADD(aCampos,{"SUBITEM"	,"C"	,005,0})
	AADD(aCampos,{"IE"		,"C"	,012,0})
	AADD(aCampos,{"VALOR"	,"N"	,015,2})
	AADD(aCampos,{"TIPOREG" ,"C"	,006,0})
	
	cArqIE	:=	CriaTrab(aCampos)
	dbUseArea(.T.,__LocalDriver,cArqIE,cArqIE,.T.,.F.)
	IndRegua(cArqIE,cArqIE,"SUBITEM+IE",,,STR0013) //"Indexando Remetentes"
Endif	
	
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
//³Arquivo DIPAM-B CR=30?
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?

aCampos	:=	{}
If lRelDIPAM
	AADD(aCampos,{"FILIAL"	,"C"	,008,0})   						// Filial
	AADD(aCampos,{"CFOP"	,"C"	,aTam[1],0})   					// CFOP
	AADD(aCampos,{"ENT_SAI"	,"C"	,001,0})   						// [E]ntradas / [S]Saidas
	AADD(aCampos,{"SERIE"	,"C"	,003,0})						// Serie
	AADD(aCampos,{"NOTA"	,"C"	,TamSX3("F2_DOC")[1],0})		// Numero da Nota
	AADD(aCampos,{"CLIFOR"	,"C"	,TAMSX3("F3_CLIEFOR")[1],0}) 	// Cliente / Fornecedor
	AADD(aCampos,{"LOJA"	,"C"	,TAMSX3("F3_LOJA")[1],0})		// Loja
	AADD(aCampos,{"MUNICIP" ,"C"	,026,0}) 						// Municipio
	AADD(aCampos,{"CODDIP"	,"C"	,002,0})						// Codigo da Dipam
	AADD(aCampos,{"VALOR"	,"N"	,018,2})						// Valor da Nota
	AADD(aCampos,{"TIPO"	,"C"	,001,0})						// Tipo da NF
	AADD(aCampos,{"ESTADO"	,"C"	,002,0})						// Estado
Else
	AADD(aCampos,{"CODDIP"	,"C"	,002,0})
	AADD(aCampos,{"MUNICIP"	,"C"	,005,0})
	AADD(aCampos,{"VALOR"	,"N"	,015,2})
	AADD(aCampos,{"TIPOREG" ,"C"	,006,0})
Endif 

cArqDIPAM	:=	CriaTrab(aCampos)
dbUseArea(.T.,__LocalDriver,cArqDIPAM,cArqDIPAM,.T.,.F.)
If lRelDIPAM
	IndRegua(cArqDipam,cArqDipam,"FILIAL")
Else
	IndRegua(cArqDipam,cArqDipam,"CODDIP+MUNICIP+TIPOREG")
Endif
dbSelectArea(cAlias)

If !lRelDIPAM
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Arquivo de IE_SUBSTITUTO CR=26?
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aCampos	:=	{}
	AADD(aCampos,{"IE"		,"C"	,012,0})
	AADD(aCampos,{"NF"		,"C"	,TamSX3("F2_DOC")[1],0})
	AADD(aCampos,{"Dataini"	,"C"	,006,0})
	AADD(aCampos,{"DataFim"	,"C"	,006,0})
	AADD(aCampos,{"Valor"	,"N"	,015,2})
	
	cArqIeSt	:=	CriaTrab(aCampos)
	dbUseArea(.T.,__LocalDriver,cArqIeSt,cArqIeSt,.T.,.F.)
	IndRegua(cArqIeSt,cArqIeSt,"IE+NF",,,STR0016) //"Indexando Ie_Substitutos"

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
	//³Arquivo de IE_SUBSTITUIDO CR=27?
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
	aCampos	:=	{}
	AADD(aCampos,{"IE"		,"C"	,012,0})
	AADD(aCampos,{"NF"		,"C"	,TamSX3("F2_DOC")[1],0})
	AADD(aCampos,{"Valor"	,"N"	,015,2})
	cArqIeSd	:=	CriaTrab(aCampos)
	dbUseArea(.T.,__LocalDriver,cArqIeSd,cArqIeSd,.T.,.F.)
	IndRegua(cArqIeSd,cArqIeSd,"IE+NF",,,STR0017) //"Indexando Ie_Substituidos"

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
	//³CredAcum CR=28 ?
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?    
	aCampos	:=	{}
	AADD(aCampos,{"SUBITEM"	,"C"	,005,0})
	AADD(aCampos,{"CODAUTO"	,"C"	,012,0})
	AADD(aCampos,{"VALOR"	,"N"	,015,2})
	AADD(aCampos,{"TIPOREG" ,"C"	,006,0})
	
	cCredAcum	:=	CriaTrab(aCampos)
	dbUseArea(.T.,__LocalDriver,cCredAcum,cCredAcum,.T.,.F.)
	IndRegua(cCredAcum,cCredAcum,"SUBITEM+CODAUTO") 

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Arquivo EXPORTACAO CR=31?
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aCampos	:=	{}
	AADD(aCampos,{"RE"	,"C"	,015,0}) 
	AADD(aCampos,{"TIPOREG" ,"C"	,006,0})
		
	cArqExpt	:=	CriaTrab(aCampos)
	dbUseArea(.T.,__LocalDriver,cArqExpt,cArqExpt,.T.,.F.)
	IndRegua(cArqExpt,cArqExpt,"RE+TIPOREG")          
Endif
dbSelectArea(cAlias)

Return  


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ?
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±?
±±ÉÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±?
±±ºFunction³A972GeraTXT ºAutor  ³Microsiga           ?Data ? 07/03/00   º±?
±±ÌÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±?
±±ºDesc.   ³Gera Arquivo texto para GIA                                   º±?
±±ÌÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±?
±±ºUso     ³MATA972                                                       º±?
±±ÈÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±?
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±?
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß?
*/
Static Function a972GeraTxt()
Local cNomeArq	:= ALLTRIM(mv_par14)+".PRF"
Local cDisco	:= Upper(mv_par17)
Local cPath		:= ""
Local n20		:= 0
Local n25		:= 0
Local n28		:= 0
Local nPos20	:= 0
Local nPos25	:= 0
Local nPos28	:= 0
Local aOcorr    := {}
Local aRemetent := {}
Local cRef := strzero(nAno,4)+strzero(nMes,2)
Private aCredAcum := {}

If !Empty(cDisco)
	// cPath	:=	Alltrim(cDisco)+":\"
	cPath	:=	Alltrim(cDisco)
Else
	cPath:=""
Endif   

cNomeArq := cPath+cNomeArq

If File(cNomeArq)
	Ferase(cNomeArq)
Endif

nHandle	 :=	MsFCreate(cNomeArq)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
//³Registro Mestre CR=01?
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?   
a972Mestre()

If ProcName(1) == "R972IMP" 
	setregua((cArqCFO)->(LastRec()))
else	
	PROCREGUA((cArqCFO)->(LastRec()))
endIf	

DbSelectArea(cArqCFO)

nr07 := 0
nr20 := 0
nr30 := 0
nr31 := 0
n20	 := 1
		
dbSelectArea(cArqCabec)
IndRegua(cArqCabec,cArqCabec,"IE",,,"")
(cArqCabec)->( dbGoTop())
While (cArqCabec)->(!eof())		
	
	nr10 := 0 
	
	(cArqCFO)->( DbGoTop())
	While (cArqCFO)->(!Eof()) 	
		If AllTrim((cArqCabec)->TIPOREG) == AllTrim((cArqCFO)->TIPOREG)
			nr10++
		EndIf 	         	
		(cArqCFO)->(DbSkip())
	EndDo                          
	
    If cRef >= "201201"                   
		nr07 := (cArqCabec)->Q07                                      	
	EndIf
	                    
	nr20 := (cArqCabec)->Q20
                                                      
	nr30 := (cArqCabec)->Q30
                  
	nr31 := (cArqCabec)->Q31
		               
	a972Cabec(nr10,nr20,nr30,nr31,/*1,*/nr07)          					
		
	(cArqCFO)->( dbGoTop())
	While (cArqCFO)->(!eof())
	
		If AllTrim((cArqCabec)->TIPOREG) <> AllTrim((cArqCFO)->TIPOREG)
			(cArqCFO)->(DbSkip())
			Loop			
		EndIf  
	
		if ProcName(1) == "R972IMP" 
			IncRegua()
		else	
			#IFNDEF WINDOWS
				IncProc(17,4)
			#ELSE  
				IncProc()
			#ENDIF
		EndIf	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Detalhes CFOPs CR=10?
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
		a972CFOP()
			
		if (cArqInt)->(dbseek((cArqCFO)->CFOP))	
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
			//³Detalhes Interestaduais CR=14?
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?              
			While (cArqInt)->(!eof()) .and. (cArqInt)->CFOP==(cArqCFO)->CFOP
				If AllTrim((cArqCFO)->TIPOREG) <> AllTrim((cArqInt)->TIPOREG)
					(cArqInt)->(DbSkip())
					Loop			
				EndIf
				a972Estados()
				if (cArqZFM)->(dbseek((cArqInt)->CFOP+(cArqInt)->UF+(cArqInt)->TIPOREG))
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Zona Franca de Manaus /Areas de Livre Comercio CR=18?
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					While (cArqZFM)->(!eof()) .and.(cArqZFM)->CFOP+(cArqZFM)->UF == (cArqInt)->CFOP+(cArqInt)->UF
						If AllTrim((cArqZFM)->TIPOREG) <> AllTrim((cArqInt)->TIPOREG)
							(cArqZFM)->(DbSkip())
							Loop			
						EndIf
						If !Empty((cArqInt)->BENEF)
							If (cArqInt)->BENEF == "1"
								A972ZFranca()
							EndIf
						EndIf
						(cArqZFM)->(dbSkip())		            
					EndDo
				EndIf		
			   (cArqInt)->(dbSkip())
			EndDo
		Endif
		(cArqCFO)->(dbSkip())	
	EndDo 
	
	(cArqOcor)->( dbGoTop())	
	While (cArqOcor)->(!eof())		
		if ProcName(1) == "R972IMP" 
			IncRegua()
		else	
			#IFNDEF WINDOWS
				IncProc(17,4)
			#ELSE  
				IncProc()
			#ENDIF
		EndIf	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
		//³Ocorrencias CR=20?
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
		//a972Ocorrencia()   
		//01.Chave(Codigo do registro+Codigo do SubItem)
		//02.Codigo do Subitem
		//03.Valor associado ao subitem
		//04.Indica se a operacao e propria ou Substituicao Tributaria
		//05.Fundamento legal associada ao Subitem
		//06.Descricao da ocorrencia associada ao Subitem
		//07.Quantidade de registro CR=25
		//08.Quantidade de registro CR=26
		//09.Quantidade de registro CR=27
		//10.Quantidade de registro CR=28 
		If AllTrim((cArqCabec)->TIPOREG) <> AllTrim((cArqOcor)->TIPOREG)
			(cArqOcor)->(DbSkip())
			Loop			
		EndIf
		nPosQ20:=aScan(aOcorr,{|x| x[1] == "20"+Alltrim((cArqOcor)->SUBITEM)+Alltrim((cArqOcor)->PRO_ST)})
		If nPosQ20==0
			aAdd(aOcorr,{"20"+Alltrim((cArqOcor)->SUBITEM),(cArqOcor)->SUBITEM,(cArqOcor)->VALOR,(cArqOcor)->PRO_ST,(cArqOcor)->FLEGAL,(cArqOcor)->OCORREN,(cArqOcor)->Q25,(cArqOcor)->Q26,(cArqOcor)->Q27,(cArqOcor)->Q28})
		Else
			aOcorr[nPosQ20][3]+=(cArqOcor)->VALOR
		Endif		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
		//³IES remetentes CR=25                                                                                           ?
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
		//Os registros desse tipo detalham informacoes lancadas em um registro-pai do tipo Ocorrencias cujo campo         ?
		//CodSubItem>=00704 e CodSubItem<=00707.                                                                          ?
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?	
		If cRef > "200112"
			//01.Chave(Codigo do registro+Codigo do SubItem)
			//02.Inscricao estadual do remetente
			//03.Valor associado ao IE do Remetente      
			If alltrim((cArqOcor)->SUBITEM)$ "00218|00729|00219|00730|00704|00705|00225|00747|00226|00748"
		  		//(cArqIE)->(dbGoTop())
				//a972Remetentes()   
				aAdd(aRemetent,{"20"+Alltrim((cArqOcor)->SUBITEM),(cArqIE)->IE,(cArqIE)->VALOR})
				If nPosQ20==0           
					aOcorr[Len(aOcorr)][7]:=1
				Else
					aOcorr[nPosQ20][7]+=1
				Endif
			Endif
		Endif  	

		cRegistro	:=a972Fill("20"+a972Fill(aOcorr[n20][2],005)+a972Fill(Num2Chr(aOcorr[n20][3],15,2),015)+a972Fill(aOcorr[n20][4],001)+;
		a972Fill(aOcorr[n20][5] ,100)+a972Fill(aOcorr[n20][6] ,300)+a972Fill(Num2Chr(aOcorr[n20][7],4,0),04)+;
		a972Fill(Num2Chr(aOcorr[n20][8],4,0),04)+a972Fill(Num2Chr(aOcorr[n20][9],4,0),04)+a972Fill(Num2Chr(aOcorr[n20][10],4,0),04),439)
		a972Grava( cRegistro )
	
	    
		nPos25:=0
		If Len(aRemetent)>0
			nPosQ25:=aScan(aRemetent,{|x| x[1] == Alltrim(aOcorr[n20][1])})	
			If nPosQ25>0
				For n25:=nPosQ25 To Len(aRemetent)
					If aRemetent[n25][1]==aOcorr[n20][1]
						cRegistro	:=a972Fill("25"+a972Fill((cArqIE)->IE,12)+a972Fill(Num2Chr((cArqIE)->VALOR,15,2),15),29)
						a972Grava( cRegistro )
					Else
						Exit
					Endif
				Next       
			Endif     
		Endif    
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
		//³CredAcum. CR=28                                                                                                ?
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
		//Os registros desse tipo detalham informacoes lancadas em um registro-pai do tipo Ocorrencias que possua no campo*
		//CodSubItem,um dos seguintes valores 00220,00221,00740 ou 00741                                                  *
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
		If cRef >= "201004"
			If (cCredAcum)->(dbseek(Alltrim((cArqOcor)->SUBITEM)))
				//01.Chave(Codigo do registro+Codigo do SubItem)
				//03.Codigo de Autorizacao                                            
				//03.Valor
				 while  (cCredAcum)->(!Eof()).And. (Alltrim(((cCredAcum)->SUBITEM))==Alltrim((cArqOcor)->SUBITEM))
		  				cRegistro:=a972Fill("28"+Lower(a972Fill((cCredAcum)->CODAUTO,12))+a972Fill(Num2Chr((cCredAcum)->VALOR,15,2),15),29)
				  		a972Grava( cRegistro )
				 (cCredAcum)->(DbSkip ()) 		
				EndDo

			Endif
		Endif   
   		n20++		                      
		(cArqOcor)->(dbSkip())	
   	EndDo 
   	
   	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄ?
	//³DIPAM B CR=30?                          	
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄ?
	(cArqDipam)->( dbGoTop())
	While (cArqDipam)->(!Eof()) 
		If AllTrim((cArqCabec)->TIPOREG) <> AllTrim((cArqDipam)->TIPOREG)
			(cArqDipam)->(DbSkip())
			Loop			
		EndIf
		a972DIPAM()
		(cArqDipam)->(DbSkip())
	EndDo
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Reg.Exportacao CR=31?
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	(cArqExpt)->( dbGoTop())
	While(cArqExpt)->(!eof())
		If AllTrim((cArqCabec)->TIPOREG) <> AllTrim((cArqExpt)->TIPOREG)
			(cArqExpt)->(DbSkip())
			Loop			
		EndIf
		a972Expot()
		dbSelectArea(cArqExpt)
		dbSkip()
	EndDo  
	(cArqCabec)->(dbSkip()) 	   	
EndDo
	
dbSelectArea(cArqOcor)
(cArqOcor)->( dbGoTop())
if ProcName(1) == "R972IMP" 
	setregua((cArqOcor)->(LastRec()))
else	
	ProcRegua((cArqOcor)->(LastRec()))
endIf	   

return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ?
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±?
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±?
±±ºFunction  ³a972MestreºAutor  ³Andreia dos Santos  ?Data ? 19/06/00   º±?
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±?
±±ºDesc.     ³Armazena informacoes no arquivo texto para armazenar infor- º±?
±±?         ³macoes do registro mestre. CR=01                            º±?
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±?
±±ºUso       ?mata972                                                    º±?
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±?
±±ºTamanho   ?32 Bytes                                                   º±?
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±?
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±?
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß?
*/
Static Function a972Mestre()

Local cRegistro

cRegistro 	:=	"01"                        //01.Deve ser igual a  01 para indicar que ?Registro Mestre
cRegistro	+=	"01"						//02.Tipo do documento
cRegistro	+=	dtos(dDataBase)		     	//03.Data de geracao do Arq.Pre-formatado
cRegistro	+=	substr(Time(),1,2)+substr(Time(),4,2)+substr(Time(),7,2) //04. Hora da Geracao
cRegistro	+=	"0000"   					//05.Versao do sistema NOVA GIA
cRegistro	+=	mv_par16					//06.Versao do Layout do pre-formatado
cRegistro	+=	StrZero(nTipoReg,4)			//07.Quantidade de registro CR=05

cRegistros	:= a972Fill(cRegistro,30)
a972Grava(cRegistro)

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ?
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±?
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±?
±±ºFunction  ³a972Cabec ºAutor  ³Andreia dos Santos  ?Data ? 19/06/00   º±?
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±?
±±ºDesc.     ³Cabecalho do documento fiscal.							  º±?
±±?         ³Contem informacoes sobre o contribuinte e informacoes geraisº±?
±±?         ³sobre o documento fiscal. CR=05							  º±?
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±?
±±ºUso       ?Mata972                                                    º±?
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±?
±±ºTamanho   ?127 Bytes                                                  º±?
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±?
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±?
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß?
*/
Static Function a972Cabec(nr10,nr20,nr30,nr31,/*nOpc,*/nr07)                     
Local cRegistro

cRegistro	:=	"05"     											//01.Codigo do registro
cRegistro	+=	a972Fill((cArqCabec)->IE,12)						//02.Inscricao Estadual
cRegistro	+=	a972Fill((cArqCabec)->CNPJ,14)						//03.CNPJ
cRegistro	+=	a972Fill((cArqCabec)->CNAE,07)						//04.CNAE
cRegistro	+=	a972Fill((cArqCabec)->REGTRIB,02)					//05.Regime Tributario
cRegistro	+=	a972Fill((cArqCabec)->REF,06)						//06.Referencia( Ano e Mes da Gia)
cRegistro	+=	a972Fill((cArqCabec)->REFINIC,06)					//07.Referencia Inicial
cRegistro	+=	a972Fill((cArqCabec)->TIPO,02)						//08.Tipo da GIA
cRegistro	+=	a972Fill((cArqCabec)->MOVIMEN,01)					//09.Indica se houve movimento
cRegistro	+=	a972Fill((cArqCabec)->TRANSMI,01)	  				//10.Indica se o documento ja foi transmitido
cRegistro	+=	a972Fill(Num2Chr((cArqCabec)->SALDO,15,2),15)		//11.Saldo Credor do periodo anterior
cRegistro	+=	a972Fill(Num2Chr((cArqCabec)->SALDOST,15,2),15)	//12.Saldo Credor do Periodo anteiro para ST.
cRegistro	+=	a972Fill((cArqCabec)->ORIGSOF,14)					//13.Identificacao do fabricante do Software que gerou o arquivo pre formatado
cRegistro	+=	a972Fill((cArqCabec)->ORIGARQ,01) 					//14.Indica se o arquivo foi gerado por algum sistema de informacao contabil
cRegistro	+=	a972Fill(Num2Chr((cArqCabec)->ICMSFIX,15,2),15)	//15.ICMS fixado para o periodo
cRegistro   +=  a972Fill(REPLICATE("0",32),32)						//No caso em que o Pr?formatado-NG ?gerado por algum sistema de informação contábil, deixar este campo com ZEROS
If cVLayOut == "0209" .Or. cVLayOut == "0210"
	cRegistro	+=	a972Fill(Num2Chr(nr07,4,0),04)					//19.Quantidade de Registro tipo CR=07
Endif
cRegistro	+=	a972Fill(Num2Chr(nr10,4,0),04)						//16.Quantidade de registro tipo CR=10 
cRegistro	+=	a972Fill(Num2Chr(nr20,4,0),04)		//17.Quantidade de Registro tipo CR=20
cRegistro	+=	a972Fill(Num2Chr(nr30,4,0),04)		//18.Quantidade de Registro tipo CR=30
If strzero(nAno,4)+strzero(nMes,2) < "200101"
	cRegistro	+= "0000"
Else
	cRegistro	+=	a972Fill(Num2Chr(nr31,4,0),04)	//19.Quantidade de Registro tipo CR=31
Endif

If cVLayOut == "0209" .Or. cVLayOut == "0210"
	cRegistro	:= a972Fill(cRegistro,165)
Else
	cRegistro	:= a972Fill(cRegistro,161)
EndIf
a972Grava( cRegistro )

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ?
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±?
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±?
±±ºFunction  ³a972CFOP()ºAutor  ³Andreia dos Santos  ?Data ? 19/06/00   º±?
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±?
±±ºDesc.     ³Detalhes CFOPs.                                             º±?
±±?         ³Contem lancamentos de valores totalizados por CFOPs.Cada re º±?
±±?         ³gistro do tipo Detalhes CFOPs pertence a um unico registro  º±?
±±?         ³do tipo Cabecalho do Documento Fiscal. CR=10                º±?
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±?
±±ºUso       ?MATA972 										 	          º±?
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±?
±±ºTamanho   ?119 bytes   								 	              º±?
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±?
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±?
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß?
*/                                                                        
Static Function a972CFOP()
LOCAL cRegistro

cRegistro	:=	"10"											  									//01.Codigo do Registro
cRegistro	+=	a972Fill(alltrim((cArqCFO)->CFOP)+repli("0",6-len(alltrim((cArqCFO)->CFOP))),06)	//02.Codigo Fiscal de Operacao e Prestacao
cRegistro	+=	a972Fill(Num2Chr((cArqCFO)->VALCONT,15,2),15)										//03.Valor Contabil
cRegistro	+=	a972Fill(Num2Chr(NoRound((cArqCFO)->BASEICM,2),15,2),15)							//04.Base de Calculo
cRegistro	+=	a972Fill(Num2Chr((cArqCFO)->VALTRIB,15,2),15)										//05.Imposto
cRegistro	+=	a972Fill(Num2Chr((cArqCFO)->ISENTA,15,2),15)										//06.Isentas e Nao tributadas
cRegistro	+=	a972Fill(Num2Chr((cArqCFO)->OUTRAS,15,2),15)										//07.Outras
cRegistro	+=	a972Fill(Num2Chr((cArqCFO)->RETIDO,15,2),15)										//08.Imposto Retido por Substituicao Tributaria
cRegistro	+=  a972Fill(Num2Chr((cArqCFO)->RtStSt,15,2),15)          								//Substituto
cRegistro	+=	a972Fill(Num2Chr((cArqCFO)->RtSbSt,15,2),15)          								//Substituido
cRegistro	+=	a972Fill(Num2Chr((cArqCFO)->IMPOSTO,15,2),15)		    							//09.Outros Impostos
cRegistro	+=	a972Fill(Num2Chr((cArqCFO)->Q14,4,0),04)											//10.Quantidade de Registros CR=14
cRegistro	:=	a972Fill(cRegistro,147)
a972Grava( cRegistro )

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ?
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±?
±±ÉÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±?
±±ºFunction ³a972EstadosºAutor  ³Andreia dos Santos  ?Data ? 19/06/00   º±?
±±ÌÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±?
±±ºDesc.    ³Detalhes Interestaduais.CR=14	                              º±?
±±?        ³Contem informacoes relativas as entradas interestaduais e/ou º±?
±±?        ³saidas interestaduais agrupadas por estados. Registros deste º±?
±±?        ³tipo irao existir sempre que existir registros Detalhes CFOPSº±?
±±?        ³com valor do campo CFOP =2XX ou 6XX.                         º±?
±±ÌÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±?
±±ºUso      ?AP5          	                                              º±?
±±ÌÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±?
±±ºTamanho  ?131 Bytes 	                                              º±?
±±ÈÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±?
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±?
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß?
*/
Static Function a972Estados()            
LOCAL cRegistro

cRegistro	:=	"14"												//01.Codigo do registro
cRegistro	+=	a972Fill((cArqInt)->UF,02)							//02.Unidade da Federacao
cRegistro	+=	a972Fill(Num2Chr((cArqInt)->VALCONT,15,2),15)		//03.Valor Contabil de contribuinte
cRegistro	+=	a972Fill(Num2Chr((cArqInt)->BASECON,15,2),15)		//04.Base de Calculo de contribuinte
cRegistro	+=	a972Fill(Num2Chr((cArqInt)->VALNCON,15,2),15)		//05.Valor Contabil de Nao contribuinte
cRegistro	+=	a972Fill(Num2Chr((cArqInt)->BASENCO,15,2),15)		//06.Base de calculo de nao contribuinte
cRegistro	+=	a972Fill(Num2Chr((cArqInt)->IMPOSTO,15,2),15)		//Imposto creditado ou debitado
cRegistro	+=	a972Fill(Num2Chr((cArqInt)->OUTRAS,15,2),15)		//07.Outras
cRegistro	+=	a972Fill(Num2Chr((cArqInt)->RETIDO,15,2),15)		//08.ICMS cobrado por Substituicao Tributaria
cRegistro	+=	a972Fill(Num2Chr((cArqInt)->PETROL,15,2),15)		//09.Petroleo e Energia quando ICMS cobrado por Substituicao Tributaria
cRegistro	+=	a972Fill(Num2Chr((cArqInt)->OUTPROD,15,2),15)		//10.Outros produtos
cRegistro	+=	a972Fill(if((cArqInt)->BENEF=="1",(cArqInt)->BENEF,"0"),01)//11.Indica se ha alguma operacao beneficiada por isencao de ICMS(ZFM/ALC)
cRegistro	+=	a972Fill(Num2Chr((cArqInt)->Q18,04,0),04)			//12.Quantidade de registros CR=18
cRegistro	:=	a972Fill(cRegistro,144)
a972Grava( cRegistro )      
         
return       

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ?
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±?
±±ÉÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±?
±±ºFunction ³A972ZFrancaºAutor  ³Andreia dos Santos  ?Data ? 19/06/00   º±?
±±ÌÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±?
±±ºDesc.    ³ZFM/ALC. CR=18                                               º±?
±±?        ³Neste registro detalham-se as informacoes relativas as saidasº±?
±±?        ³interestaduais, quando houver lancamentos de CFOPs do grupo  º±?
±±?        ?.XX e a operacao permitir o beneficio da isencao devido aos º±?
±±?        ³municipios destinos pertencentes a Zona Franca de Manaus ou  º±?
±±?        ³Areas de Livre Comercio. Nao possui registros filhos         º±?
±±ÌÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±?
±±ºUso      ?AP5                                                         º±?
±±ÌÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±?
±±ºTamanho  ?52 bytes	                                                  º±?
±±ÈÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±?
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±?
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß?
*/
Static Function a972ZFranca()
LOCAL cRegistro

cRegistro	:=	"18"              								//01.Codigo do registro
cRegistro	+=  Strzero(Val((cArqZFM)->NFISCAL),09) 			//02.Numero da Nota Fiscal 
cRegistro	+=	a972Fill(dtos((cArqZFM)->EMISSAO),08)			//03.Data de emissao da Nota Fiscal
cRegistro	+=	a972Fill(Num2Chr((cArqZFM)->VALOR,15,2),15)	//04.Valor da Nota Fiscal
cRegistro	+=	a972Fill((cArqZFM)->CNPJDES,14)					//05.CNPJ do destinatario
cRegistro	+=	a972Fill((cArqZFM)->MUNICIP,05)					//06.Codigo do municipio do destinatario
                      
cRegistro	:=	a972Fill(cRegistro,53)
a972Grava( cRegistro )
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ?
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±?
±±ÉÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±?
±±ºFuncao  ³a972OcorrenciaºAutor  ³Andreia dos Santos?Data ? 20/06/00   º±?
±±ÌÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±?
±±ºDesc.   ³Ocorrencias. CR=20                                            º±?
±±?       ³Detalham informacoes correspondentes aos campos 052-Outros De-º±?
±±?       ³bitos, 053-Estorno de Créditos, 057(Outros Créditos),058(Estorº±?
±±?       ³no de Debitos),064-Deducoes(RPA/DISPENSADO) e 064-Outras(RES) º±?
±±?       ?necessárias para Apuracao do ICMS para Operacoes Proprias e  º±?
±±?       ³Apuracao do ICMS-ST-11              						  º±?
±±ÌÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±?
±±ºUso     ?AP5                                                          º±?
±±ÌÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±?
±±ºTamanho ?429 bytes.                                                   º±?
±±ÈÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±?
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±?
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß?
*/
Static Function a972Ocorrencia(nCR25)
LOCAL cRegistro

cRegistro	:=	"20"											//01.Codigo de registro
cRegistro	+=	a972Fill((cArqOcor)->SUBITEM,005) 				//02.Codigo do Subitem
cRegistro	+=	a972Fill(Num2Chr((cArqOcor)->VALOR,15,2),015)	//03.Valor associado ao subitem
cRegistro	+=	a972Fill((cArqOcor)->PRO_ST,001)				//04.Indica se a operacao e propria ou Substituicao Tributaria
cRegistro	+=	a972Fill((cArqOcor)->FLEGAL,100)				//05.Fundamento legal associada ao Subitem
cRegistro	+=	a972Fill((cArqOcor)->OCORREN,300)				//06.Descricao da ocorrencia associada ao Subitem
cRegistro	+=	a972Fill(Num2Chr((cArqOcor)->Q25,4,0),04)		//07.Quantidade de registro CR=25
cRegistro	+=	a972Fill(Num2Chr((cArqOcor)->Q26,4,0),04)		//Quantidade de registro CR=26
cRegistro	+=	a972Fill(Num2Chr((cArqOcor)->Q27,4,0),04)		//Quantidade de registro CR=27
cRegistro	+=	a972Fill(Num2Chr((cArqOcor)->Q28,4,0),04)		//Quantidade de registro CR=28
cRegistro	:=	a972Fill(cRegistro,439)
a972Grava( cRegistro )
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFunction ³a972RemetentesºAutor  ³Andreia dos Santos ?Data ? 20/06/00  º±?
±±ÌÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.    ³IEs Remetentes. CR=25										   º±?
±±?        ³Os registros desse tipo detalham informacoes lancadas em um   º±?
±±?        ³registro-pai do tipo Ocorrencias cujo campo CodSubItem>=00704 º±?
±±?        ?e CodSubItem<=00707.                                         º±?
±±ÌÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso      ?AP5          	                                               º±?
±±ÌÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºTamanho  ?31 Bytes     	                                               º±?
±±ÈÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function a972Remetentes()  
LOCAL cRegistro
cRegistro	:=	"25"										//01.Codigo de Registro
cRegistro	+=	a972Fill((cArqIE)->IE,12)					//02.Inscricao estadual do remetente
cRegistro	+=	a972Fill(Num2Chr((cArqIE)->VALOR,15,2),15)	//03.Valor associado ao IE do Remetente      

cRegistro	:=	a972Fill( cRegistro,29)
a972Grava( cRegistro )
return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ?
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±?
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±?
±±ºFunction  ³a972FILL  ºAutor  ³Andreia dos Santos  ?Data ? 19/06/00   º±?
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±?
±±ºDesc.     ?Encaixa conteudo no espaco especificado.                   º±?
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±?
±±ºUso       ?Mata972                                                    º±?
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±?
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±?
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß?
*/
Static Function a972Fill(cConteudo,nTam)
	
cConteudo	:=	If(cConteudo==NIL,"",cConteudo)
If Len(cConteudo)>nTam
	cRetorno	:=	Substr(cConteudo,1,nTam)
Else
	cRetorno	:=	cConteudo+Space(nTam-Len(cConteudo))
Endif
	
Return (cRetorno)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ?
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±?
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±?
±±ºFuncao    ³a972Grava ºAutor  ³Andreia dos Santos  ?Data ? 26/06/00   º±?
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±?
±±ºDesc.     ³Grava Registro no arquivo texto e acrescenta marca de final º±?
±±?         ³de registro                                                 º±?
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±?
±±ºUso       ?MATA972                                                    º±?
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±?
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±?
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß?
*/
Static Function a972Grava(cConteudo)

cConteudo += Chr(13)+Chr(10)

If !lEnd
	FWrite(nHandle,cConteudo,Len(cConteudo))
Endif

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ?
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±?
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±?
±±ºFuncao  	 ³A972CodUF ºAutor  ³Andreia dos Santos  ?Data ? 12/07/00   º±?
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±?
±±ºDesc.     ³Converte as unidades de federacao para um codigo aceito no  º±?
±±?         ³programa NOVA GIA da Secretaria da fazenda                  º±?
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±?
±±ºUso       ?mata972                                                    º±?
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±?
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±?
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß?
*/
Static Function A972CodUF(cUF)
cCOD := "01"
             
Do Case
	Case cUF == "AC"
		cCOD	:= "01"
	Case cUF == "AL"
		cCOD	:= "02"
	Case cUF == "AP"
		cCOD	:= "03"
	Case cUF == "AM"
		cCOD	:= "04"
	Case cUF == "BA"
		cCOD	:= "05"
	Case cUF == "CE"
		cCOD	:= "06"
	Case cUF == "DF"
		cCOD	:= "07"
	Case cUF == "ES"
		cCOD	:= "08"
	Case cUF == "GO"
		cCOD	:= "10"
	Case cUF == "MA"
		cCOD	:= "12"
	Case cUF == "MT"
		cCOD	:= "13"
	Case cUF == "MS"
		cCOD	:= "28"
	Case cUF == "MG"
		cCOD	:= "14"
	Case cUF == "PA"
		cCOD	:= "15"
	Case cUF == "PB"
		cCOD	:= "16"
	Case cUF == "PR"
		cCOD	:= "17"
	Case cUF == "PE"
		cCOD	:= "18"
	Case cUF == "PI"
		cCOD	:= "19"
	Case cUF == "RJ"
		cCOD	:= "22"
	Case cUF == "RN"
		cCOD	:= "20"
	Case cUF == "RS"
		cCOD	:= "21"
	Case cUF == "RO"
		cCOD	:= "23"
	Case cUF == "RR"
		cCOD	:= "24"
	Case cUF == "SC"
		cCOD	:= "25"
	Case cUF == "SP"
		cCOD	:= "26"
	Case cUF == "SE"
		cCOD	:= "27"
	Case cUF == "TO"
		cCOD	:= "29"
EndCase

Return(cCOD )
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ?
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±?
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±?
±±ºFuncao    ³a972Dipam ºAutor  ³Andreia dos Santos  ?Data ? 26/06/00   º±?
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±?
±±ºDesc.     ³Grava os registros referentes a DIPAM-B. CR=30              º±?
±±?         ?                                                           º±?
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±?
±±ºUso       ?MATA972                                                    º±?
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±?
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±?
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß?
*/
Static Function a972Dipam()

cRegistro	:=	"30"													//01.Codigo de Registro
cRegistro	+=	a972Fill((cArqDipam)->CODDIP,2)							//02.Codigo da DIPI
cRegistro   +=  a972Fill((cArqDipam)->MUNICIP,5)						//03.Codigo do Municipio
cRegistro	+=	a972Fill(Num2Chr((cArqDipam)->VALOR,15,2),15)			//04.Codigo do Municipio

a972Grava( cRegistro )

Return(.T.)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ?
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±?
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±?
±±ºFuncao    ³a972Expot ºAutor  ³Eduardo Jose Zanardo?Data ? 08/02/02   º±?
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±?
±±ºDesc.     ³Grava os registros referentes a exportacao CR=31            º±?
±±?         ?                                                           º±?
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±?
±±ºUso       ?MATA972                                                    º±?
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±?
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±?
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß?
*/
Static Function a972Expot()

cRegistro	:=	"31"												//01.Codigo de Registro
cRegistro	+=	a972Fill((cArqExpt)->RE,15)							//02.Registro de Importacao

a972Grava( cRegistro )

Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ?
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±?
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±?
±±ºFuncao    ³a972TmpIE ?Autor ³Sergio S. Fuzinaka  ?Data ? 26/05/03   º±?
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±?
±±ºDesc.     ³Grava os registros referentes a IE CR=25, somente movimenta-º±?
±±?         ³cao de transferencia ( F3->TRFICM > 0 )                     º±?
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±?
±±ºUso       ³MATA972                                                     º±?
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±?
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±?
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß?
*/
Static Function a972TmpIE(cAlias)

Local cIE := ""
Local aSA1 := SA1->(GetArea())
Local aSA2 := SA2->(GetArea())

SA1->(dbSetOrder(1))			
SA1->(dbSeek(xFilial("SA1")+(cAlias)->F3_CLIEFOR+(cAlias)->F3_LOJA,.F.))
SA2->(dbSetOrder(1))			
SA2->(dbSeek(xFilial("SA2")+(cAlias)->F3_CLIEFOR+(cAlias)->F3_LOJA,.F.))

If SF3->(FieldPos("F3_TRFICM")) > 0
	If (cAlias)->F3_TRFICM > 0	//Houve transferencia de Credito ou Debito
		If Left((cAlias)->F3_CFO,1) >= "5"	//Saida
			If (cAlias)->F3_TIPO $ "DB"
				cIE := Alltrim(SA2->A2_INSCR)
			Else
				cIE := Alltrim(SA1->A1_INSCR)
			Endif
		Else	//Entrada
			If (cAlias)->F3_TIPO $ "DB"
				cIE := Alltrim(SA1->A1_INSCR)
			Else
				cIE := Alltrim(SA2->A2_INSCR)
			Endif
		Endif		
		If (cArqIE)->(dbSeek(Space(5)+cIE))
			RecLock((cArqIE),.F.)
			(cArqIE)->IE 		:= cIE
			(cArqIE)->VALOR += (cAlias)->F3_TRFICM
		Else
			RecLock((cArqIE),.T.)
			(cArqIE)->SUBITEM	:= Space(5)
			(cArqIE)->IE 		:= cIE
			(cArqIE)->VALOR		:= (cAlias)->F3_TRFICM
		Endif
		MsUnlock()
	Endif
Endif
RestArea(aSA1)
RestArea(aSA2)

Return Nil

/*               
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ?
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±?
±±ÉÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±?
±±ºFunction³A972RetMun  ºAutor  ³Gustavo G. Rueda    ?Data ? 28/09/2004 º±?
±±ÌÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±?
±±ºDesc.   ³Verifica se existe integracao com o TMS, e caso exista retornaº±?
±±?       ?o codigo do municipio da tabela DUE ou DUL. Caso contrario   º±?
±±?       ?retorno do cadastro de cliente posicionado anteriormente.    º±?
±±ÌÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±?
±±ºParamet.³ExpC -> Indica o alias da tabela SF3 a ser utilizada.         º±?
±±?       ³ExpL -> Integracao com o TMS.                                 º±?
±±ÌÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±?
±±ºUso     ?MATA972                                                      º±?
±±ÈÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±?
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±?
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß?
*/
Static Function A972RetMun (cAliasSf3, lTms)
	Local	cCod_Mun :=	""
	Local	aArea	 :=	GetArea ()
	Local	aCodMun  := {}
	Local	cMvUF    := SuperGetMV("MV_ESTADO",,"SP")
	//
	If lTms
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//?Integracao com TMS                                 ?
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aCodMun := TMSInfSol((cAliasSf3)->F3_FILIAL,(cAliasSf3)->F3_NFISCAL,(cAliasSf3)->F3_SERIE,(cAliasSf3)->F3_CLIEFOR,(cAliasSf3)->F3_LOJA,.T.)
		If Substr((cAliasSF3)->F3_CFO,1,1) >= "5"
			If Len(aCodMun) > 0
				//-- SIGATMS: para remetente SP e CFOP interestadual.
				If aCodMun[8] == cMvUF
					cCod_Mun := aCodMun[11]
				Else
					cCod_Mun := StrZero(val(Alltrim(GetNewPar("MV_CODDP", "1004"))),5,0)
				EndIf
			Else
				cCod_Mun := StrZero(val(Alltrim(GetNewPar("MV_CODDP", "1004"))),5,0)
			EndIf
		EndIf
	Else
		If (GetNewPar ("MV_CODMUN", "X")<>"X") .And. !(SA1->(Eof ()))
			If (SA1->(FieldPos(AllTrim(SuperGetMv("MV_CODMUN"))))>0)
				cCod_Mun	:=	SA1->(FieldGet (FieldPos(SuperGetMv("MV_CODMUN"))))
			Else
				cCod_Mun	:=	""
			EndIf
		Else
			cCod_Mun	:=	""
		EndIf
		//
		If (SA1->(FieldPos("A1_COD_MUN"))>0) .And. (Empty (cCod_Mun)) .And. !(SA1->(Eof ()))
			cCod_Mun	:=	SA1->A1_COD_MUN
		EndIf
	EndIf
	RestArea (aArea)
Return (cCod_Mun)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ?
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±?
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±?
±±³Funcao    ³AjustaSX1 ?Autor ?William P. Alves      ?Data ?6.10.2009³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±?
±±³Descri‡…o ³Cria as perguntas necesarias para o programa                ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±?
±±³Retorno   ³Nenhum                                                      ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±?
±±³Parametros³Nenhum                                                      ³±?
±±?         ?                                                           ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±?
±±?  DATA   ?Programador   ³Manutencao Efetuada                         ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±?
±±?         ?              ?                                           ³±?
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±?
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±?
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß?
/*/
Static Function AjustaSX1()

Local aHelpPor :={} 
Local aHelpEng :={} 
Local aHelpSpa :={} 
Local aArea		:= GetArea()
      
SX1->(dbSetOrder(1))
If SX1->(MsSeek("MTA972    "+"07")) .And. Alltrim(SX1->X1_PERGUNT) <> "Regime Tributário ?"
	RecLock("SX1", .F.)
	SX1->X1_PERGUNT := "Regime Tributário ?"
	SX1->( MsUnlock() )
EndIf

If SX1->(MsSeek("MTA972    "+"08")) .And. Alltrim(SX1->X1_PERGUNT) <> "Mês de Referência ?"
	RecLock("SX1", .F.)
	SX1->X1_PERGUNT := "Mês de Referência ?"
	SX1->( MsUnlock() )
EndIf

If SX1->(MsSeek("MTA972    "+"09")) .And. Alltrim(SX1->X1_PERGUNT) <> "Ano de Referência ?"
	RecLock("SX1", .F.)
	SX1->X1_PERGUNT := "Ano de Referência ?"
	SX1->( MsUnlock() )
EndIf

If SX1->(MsSeek("MTA972    "+"10")) .And. Alltrim(SX1->X1_PERGUNT) <> "Mês Ref. Inicial ?"
	RecLock("SX1", .F.)
	SX1->X1_PERGUNT := "Mês Ref. Inicial ?"
	SX1->( MsUnlock() )
EndIf

If SX1->(MsSeek("MTA972    "+"13")) .And. Alltrim(SX1->X1_PERGUNT) <> "ICMS Fix.p/ período ?"
	RecLock("SX1", .F.)
	SX1->X1_PERGUNT := "ICMS Fix.p/ período ?"
	SX1->( MsUnlock() )
EndIf

aHelpPor := {}
Aadd(aHelpPor	,"Informa a filial inicial no caso de pro-")
Aadd(aHelpPor	,"cessamento consolidado.")
Aadd(aHelpPor	,"Este parâmetro não ter?efeito em ambi-")
Aadd(aHelpPor	,"ente dbAccess ou quando o parâmetro ")
Aadd(aHelpPor	,"Seleciona Filiais? estiver preenchido ")
Aadd(aHelpPor	,"com o conteúdo = Sim. ")
aHelpEng	:=	aHelpSpa	:=	aHelpPor
PutSX1Help("P.MTA97218.",aHelpPor,aHelpEng,aHelpSpa,.T.)

aHelpPor := {}
Aadd(aHelpPor	,"Informa a filial final no caso de pro-")
Aadd(aHelpPor	,"cessamento consolidado.")
Aadd(aHelpPor	,"Este parâmetro não ter?efeito em ambi-")
Aadd(aHelpPor	,"ente dbAccess ou quando o parâmetro ")
Aadd(aHelpPor	,"Seleciona Filiais? estiver preenchido ")
Aadd(aHelpPor	,"com o conteúdo = Sim. ")
aHelpEng	:=	aHelpSpa	:=	aHelpPor
PutSX1Help("P.MTA97219.",aHelpPor,aHelpEng,aHelpSpa,.T.)



/*-----------------------MV_PAR20--------------------------*/
Aadd( aHelpPor, "Para notas de transferência de saldo    " )
Aadd( aHelpPor, "entre filiais, serão consideradas notas " )
Aadd( aHelpPor, "emitidas at?o dia 9 do mês subseqüente." )
Aadd( aHelpPor, "1 - Sim;                                 ")
Aadd( aHelpPor, "2 - Não.                                 ")

Aadd( aHelpEng, "Para notas de transferência de saldo    " )
Aadd( aHelpEng, "entre filiais, serão consideradas notas " )
Aadd( aHelpEng, "emitidas at?o dia 9 do mês subseqüente." )
Aadd( aHelpEng, "1 - Sim;                                 ")
Aadd( aHelpEng, "2 - Não.                                 ")

Aadd( aHelpSpa, "Para notas de transferência de saldo    " )
Aadd( aHelpSpa, "entre filiais, serão consideradas notas " )
Aadd( aHelpSpa, "emitidas at?o dia 9 do mês subseqüente." )
Aadd( aHelpSpa, "1 - Sim;                                 ")
Aadd( aHelpSpa, "2 - Não.                                 ")

PutSx1( "MTA972","20","NF Transf. Filiais","NF Transf. Filiais","NF Transf. Filiais","mv_chl",;
"N",1,0,2,"C","","","","","mv_par20","Sim","Si","Yes","","Nao","No","No","","","","","","","","","",;
aHelpPor,aHelpEng,aHelpSpa)

/*-----------------------MV_PAR21-------------------------*/
aHelpPor	:=	{}
aHelpEng	:=	{}
aHelpSpa	:=	{}

Aadd( aHelpPor, "Informe se deseja processar filiais." )
Aadd( aHelpPor, "Neste caso, ser?aberta uma janela  " )
Aadd( aHelpPor, "para informar quais filiais deseja  " )
Aadd( aHelpPor, "processar, desconsiderando as per-  " )
Aadd( aHelpPor, "guntas de filial de/ate.            " )
Aadd( aHelpEng, "Informe se deseja processar filiais." )
Aadd( aHelpEng, "Neste caso, ser?aberta uma janela  " )
Aadd( aHelpEng, "para informar quais filiais deseja  " )
Aadd( aHelpEng, "processar, desconsiderando as per-  " )
Aadd( aHelpEng, "guntas de filial de/ate.            " )
Aadd( aHelpSpa, "Informe se deseja processar filiais." )
Aadd( aHelpSpa, "Neste caso, ser?aberta uma janela  " )
Aadd( aHelpSpa, "para informar quais filiais deseja  " )
Aadd( aHelpSpa, "processar, desconsiderando as per-  " )
Aadd( aHelpSpa, "guntas de filial de/ate.            " )

PutSx1("MTA972", "21", "Seleciona filiais?", "Seleciona filiais?", "Seleciona filiais?",;
			"mv_chm", "N", 1, 0, 2,"C", "","","","","mv_par21", "Sim", "Si",  "Yes", "","Nao", "No", "No",;
			"", "", "", "", "", "","","","",aHelpPor,aHelpEng,aHelpSpa)

/*-----------------------MV_PAR22-------------------------*/
aHelpPor	:=	{}
aHelpEng	:=	{}
aHelpSpa	:=	{}

Aadd( aHelpPor, "Informe se deseja agrupar as infor- ")
Aadd( aHelpPor, "mações por CNPJ+IE. Neste caso, as  ")
Aadd( aHelpPor, "filiais com o mesmo CNPJ e Insc.Est.")
Aadd( aHelpPor, "serão apresentadas como uma Filial  ")
Aadd( aHelpPor, "única. ")
aHelpEng := aHelpSpa := aHelpPor
PutSx1("MTA972", "22", "Aglutina por CNPJ+IE?", "Aglutina por CNPJ+IE?", "Aglutina por CNPJ+IE?",;
			"mv_chn", "N", 1, 0, 2,"C", "","","","","mv_par22", "Sim", "Si",  "Yes", "","Nao", "No", "No",;
			"", "", "", "", "", "","","","",aHelpPor,aHelpEng,aHelpSpa)

RestArea(aArea)
Return()

#INCLUDE "AP5MAIL.CH"
#INCLUDE "DIPR064.CH"
#INCLUDE "PROTHEUS.CH"
#DEFINE ctrls   CHR(13)+CHR(10)   && quebra de linha  
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ DIPR064  ³ Autor ³ Consultoria           ³ Data ³09/07/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Pedido de Compras / Autorizacao de Entrega                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ DIPR064(void)                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico SIGACOM                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function DIPR064( cAlias, nReg, nOpcx )

LOCAL cString	:= "SC7"   

//Rafael Moraes Rosa - 12/01/2023 - VARIAVEL
Local cEndEnt	:= ""
Local cCodMun	:= ""
Local cCidEnt	:= ""
Local cEstEnt	:= ""
Local cCEPEnt	:= ""
Local cBairEnt	:= ""
Local cCompEnt	:= ""


Private _cBodyPrvt    
Private lPodeEnv	 := Eval({|| SY1->(dbSetOrder(3)),SY1->(dbSeek(xFilial("SY1")+RetCodUsr()))})
Private lSomaSt	:= .F.

//Rafael Moraes Rosa - 12/01/2023 - INICIO
//dbSelectArea("SM0")

IF cEmpAnt+cFilAnt = '0101'

	SM0->(dbSeek("0104"))
		cEndEnt		:= SM0->M0_ENDENT
		cCodMun		:= SM0->M0_CODMUN
		cCidEnt		:= SM0->M0_CIDENT
		cEstEnt		:= SM0->M0_ESTENT
		cCEPEnt		:= SM0->M0_CEPENT
		cBairEnt	:= SM0->M0_BAIRENT
		cCompEnt	:= SM0->M0_COMPENT

ELSE
	SM0->(dbSeek(cEmpAnt+cFilAnt))
		cEndEnt		:= SM0->M0_ENDENT
		cCodMun		:= SM0->M0_CODMUN
		cCidEnt		:= SM0->M0_CIDENT
		cEstEnt		:= SM0->M0_ESTENT
		cCEPEnt		:= SM0->M0_CEPENT
		cBairEnt	:= SM0->M0_BAIRENT
		cCompEnt	:= SM0->M0_COMPENT

ENDIF
//SM0->(dbSkip())

SM0->(dbSeek(cEmpAnt+cFilAnt))

//Rafael Moraes Rosa - 12/01/2023 - FIM

If cEmpAnt+cFilAnt = '0401' .And. SC7->C7_CONAPRO <> 'L' // MCVN - 19/01/11
	MsgStop("O Pedido de Compra não está aprovado e não pode ser impresso ou enviado por e-mail." +Chr(13)+Chr(10)+ SC7->C7_NUM,"AVISO")
	Return()
EndIf

IF "MATA121"$FUNNAME(0)            		
   	nReg := Recno() 
   	MV_PAR15 := 2   	
   	If lPodeEnv
		If MsgYesNo("Deseja Enviar por E-Mail?")
	   		MV_PAR15 := 1 // Envia por E-Mail? 1=Sim; 2-Nao
	   		_cBodyPrvt := RetBody()
	   	EndIf
	EndIf
EndIf

Private nColini
Private cDestMat
Private cAprovador   := "" 
Private lUserComp    := .f.                         
Private titulo	 	 := "Impressao de Pedido de Compra"
Private lAuto		 := (nReg!=Nil)
Private nlin    	 := 50
Private nLinBoxs     := 50 //Controlar recuo superior  - 23/07/2013  RBorges
Private nColBoxe     := 50 //Controlar recuo esquerdo  - 23/07/2013  RBorges
Private nColBoxi     := 50 //Controlar recuo inferior  - 23/07/2013  RBorges
Private nColBoxd     := 50 //Controlar recuo direito   - 23/07/2013  RBorges
Private ArialN6      := TFont():New("Arial"          ,,08,,.F.,,,,,.F.)
Private ArialN6B     := TFont():New("Arial"	          ,,08,,.T.,,,,,.F.)
Private ArialN8      := TFont():New("Arial"	          ,,10,,.F.,,,,,.F.)  
Private ArialN9      := TFont():New("Arial"	          ,,11,,.F.,,,,,.F.)
Private ArialN8B     := TFont():New("Arial"	          ,,10,,.T.,,,,,.F.)
Private ArialN10     := TFont():New("Arial"          ,,12,,.F.,,,,,.F.)
Private ArialN10B    := TFont():New("Arial"	          ,,12,,.T.,,,,,.F.)
Private ArialN12     := TFont():New("Arial"	          ,,14,,.F.,,,,,.F.)
Private ArialN12B    := TFont():New("Arial"          ,,14,,.T.,,,,,.F.)
Private ArialN14     := TFont():New("Arial"	          ,,16,,.F.,,,,,.F.)
Private ArialN14B    := TFont():New("Arial"          ,,16,,.T.,,,,,.F.)
Private ArialN16     := TFont():New("Arial"	          ,,18,,.F.,,,,,.F.)
Private ArialN16B    := TFont():New("Arial"	          ,,18,,.T.,,,,,.F.)
Private ArialN18     := TFont():New("Arial"	          ,,22,,.F.,,,,,.F.)
Private ArialN18B    := TFont():New("Arial"	          ,,22,,.T.,,,,,.F.)
Private ArialN20     := TFont():New("Arial"	          ,,22,,.F.,,,,,.F.)
Private ArialN20B    := TFont():New("Arial"	          ,,22,,.T.,,,,,.F.)
Private Times14	     := TFont():New("Times New Roman",,16,,.T.,,,,,.F. )
Private Times20      := TFont():New("Times New Roman",,22,,.T.,,,,,.F. )
Private CourN08B     := TFont():New("Courier New"    ,,10,,.T.,,,,.T.,.F.)
Private CourN10B     := TFont():New("Courier New"    ,,12,,.F.,,,,.T.,.F.)
Private lTipPedido   := .T.  // JBS 12/01/2010 

Private ArialN24B    := TFont():New("Arial"	          ,,26,,.T.,,,,,.F.)//Giovani Zago 06/12/11 
Private nCont        := 0

/*
Private ArialN6      := TFont():New("Arial"          ,,06,,.F.,,,,,.F.)
Private ArialN6B     := TFont():New("Arial"	          ,,06,,.T.,,,,,.F.)
Private ArialN8      := TFont():New("Arial"	          ,,08,,.F.,,,,,.F.)  
Private ArialN9      := TFont():New("Arial"	          ,,09,,.F.,,,,,.F.)
Private ArialN8B     := TFont():New("Arial"	          ,,08,,.T.,,,,,.F.)
Private ArialN10     := TFont():New("Arial"          ,,10,,.F.,,,,,.F.)
Private ArialN10B    := TFont():New("Arial"	          ,,10,,.T.,,,,,.F.)
Private ArialN12     := TFont():New("Arial"	          ,,12,,.F.,,,,,.F.)
Private ArialN12B    := TFont():New("Arial"          ,,12,,.T.,,,,,.F.)
Private ArialN14     := TFont():New("Arial"	          ,,14,,.F.,,,,,.F.)
Private ArialN14B    := TFont():New("Arial"          ,,14,,.T.,,,,,.F.)
Private ArialN16     := TFont():New("Arial"	          ,,16,,.F.,,,,,.F.)
Private ArialN16B    := TFont():New("Arial"	          ,,16,,.T.,,,,,.F.)
Private ArialN18     := TFont():New("Arial"	          ,,18,,.F.,,,,,.F.)
Private ArialN18B    := TFont():New("Arial"	          ,,18,,.T.,,,,,.F.)
Private ArialN20     := TFont():New("Arial"	          ,,20,,.F.,,,,,.F.)
Private ArialN20B    := TFont():New("Arial"	          ,,20,,.T.,,,,,.F.)
Private Times14	     := TFont():New("Times New Roman",,14,,.T.,,,,,.F. )
Private Times20      := TFont():New("Times New Roman",,20,,.T.,,,,,.F. )
Private CourN08B     := TFont():New("Courier New"    ,,08,,.T.,,,,.T.,.F.)
Private CourN10B     := TFont():New("Courier New"    ,,10,,.F.,,,,.T.,.F.)
Private ArialN24B    := TFont():New("Arial"	          ,,24,,.T.,,,,,.F.)//Giovani Zago 06/12/11 
*/    



// Private cPerg
// FPADR(cPerg, cArq, cCampo, cTipo)  - Para ajustar o tamanho das perguntas no SX1- uso generico
Private cPerg  	     := U_FPADR( "DIPR64","SX1","SX1->X1_GRUPO"," " ) //Função criada por Sandro em 19/11/09.

U_DIPPROC(ProcName(0),U_DipUsr()) // MCVN - 22/01/2009

lTipPedido := (Upper(U_DipUsr()) $ GetNewPar("ES_DIPR064",""))

If Type("lPedido") != "L"
	lPedido := .F.
Endif

Dbselectarea("SY1")
Dbsetorder(3)
If dbSeek(xFilial("SY1")+Alltrim(RetCodUsr()))
	lUserComp := .T.
EndIf                       
SY1->(DbCloseArea())

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros                         ³
//³ mv_par01               Do Pedido                             ³
//³ mv_par02               Ate o Pedido                          ³
//³ mv_par03               A partir da data de emissao           ³
//³ mv_par04               Ate a data de emissao                 ³
//³ mv_par05               Somente os Novos                      ³
//³ mv_par06               Campo Descricao do Produto    	     ³
//³ mv_par07               Unidade de Medida:Primaria ou Secund. ³
//³ mv_par08               Do Comprador?                         ³
//³ mv_par09               Ate Comprador?                        ³
//³ mv_par10               Pedidos ? Liberados Bloqueados Ambos  ³
//³ mv_par11               Impr. SC's Firmes, Previstas ou Ambas ³
//³ mv_par12               Qual a Moeda ?                        ³
//³ mv_par13               Endereco de Entrega                   ³
//³ mv_par14               todas ou em aberto ou atendidos       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
AjustaSX1(cPerg)

If !lAuto
	If Pergunte(cPerg,.T.) 
		If lPedido
			mv_par12 := MAX(SC7->C7_MOEDA,1)
		Endif
	
		RptStatus({|lEnd| C110PC(@lEnd,cString,nReg)},titulo)

		lPedido := .F.
	EndIf
Else    
	If lPedido
		mv_par12 := MAX(SC7->C7_MOEDA,1)
	Endif
	
	RptStatus({|lEnd| C110PC(@lEnd,cString,nReg)},titulo)

	lPedido := .F.
Endif
Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ C110PC   ³ Autor ³ CONSILTORIA           ³ Data ³ 01.07.07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Chamada do Relatorio                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ DIPR064			                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function C110PC(lEnd,cString,nReg)
Local nOrder
Local cCondBus
Local nSavRec
Local aPedido := {}
Local aPedMail:= {}
Local aSavRec := {}
Local nLinObs := 0
Local i       := 0
Local ncw     := 0
Local cFiltro := ""
Local cMsgIsenSt := "Empresa isenta de SUBSTITUIÇÃO TRIBUTÁRIA, conforme disposto no artigo 482, $3º do RICMS aprovado pelo Decreto 45.490 de 30/11/2000,"
Local cMsg2IsenSt:= "bem como nos Artigos 479-A e 489 do Regulamento do Regime Especial: Comunicado DEAT-Série Regime especial nº 9/2010 com base na Portaria CAT nº 198/2009."

Private cCGCPict, cCepPict           
Private nIt   := 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Definir as pictures                                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cCepPict:=PesqPict("SA2","A2_CEP")
cCGCPict:=PesqPict("SA2","A2_CGC")

li         := 80
nDescProd  := 0
nTotMerc   := 0 
nTotal	   := 0
nTotSt     := 0
nTotIPI    := 0
nPagina	   := 0
NumPed     := Space(6)

If lAuto 
	dbSelectArea("SC7")
	dbGoto(nReg)
	SetRegua(1)
	mv_par01 := C7_NUM
	mv_par02 := C7_NUM
	mv_par03 := C7_EMISSAO
	mv_par04 := C7_EMISSAO
	mv_par05 := 2  
	mv_par07 := 1
	mv_par08 := ''
	mv_par09 := 'zzzzzz' 
	mv_par10 := 3    
	mv_par11 := 3
	mv_par12 := 1   
	mv_par13 := ""
	If lTipPedido
		mv_par14 := 1
	Else             
		mv_par14 := 2
	Endif	
ElseIf !lTipPedido
	mv_par14 := 2	
EndIf

If ( cPaisLoc$"ARG|POR|EUA" )
	cCondBus	:=	"1"+strzero(val(mv_par01),6)
	nOrder	    :=	10
	nTipo		:=  1
Else
	cCondBus	:=mv_par01
	nOrder	:=	1
EndIf

If mv_par14 == 2
	cFiltro := "SC7->C7_QUANT-SC7->C7_QUJE <= 0 .Or. !EMPTY(SC7->C7_RESIDUO)"
Elseif mv_par14 == 3
	cFiltro := "SC7->C7_QUANT > SC7->C7_QUJE"
EndIf

dbSelectArea("SC7")
dbSetOrder(1)
SetRegua(RecCount())
dbSeek(xFilial("SC7")+cCondBus,.T.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Impressao do relatorio                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

//RBorges 23/07/2013 - alterada a forma de impressão de imagem para PDF
// Antes era usado o TMSPrint, agora FWMSPrint

Private NumPed   := SC7->C7_NUM
Private cPrefixo := "PC_"+NumPed+"_"+DTOS(dDatabase)

oPrint := FWMSPrinter():New(cPrefixo,6,.T.,,.T.)
oPrint :SetLandScape() //paisagem
oPrint :Setup()
oPrint :cPathPDF:="C:\PedCompras\"



While !Eof() .And. C7_FILIAL = xFilial("SC7") .And. C7_NUM >= mv_par01 .And. ;
		C7_NUM <= mv_par02

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Cria as variaveis para armazenar os valores do pedido        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nOrdem   := 1
	If cEmpAnt+cFilAnt == '0401'
		cObs01   := "CONFORME RDC 16/2013 NÃO RECEBEREMOS MERCADORIA EM CARRO ABERTO!"
		cObs02   := " "
		cObs03   := " "
		cObs04   := " "
    Else
		cObs01   := " "
		cObs02   := " "
		cObs03   := " "
		cObs04   := "     
    EndIf
	If C7_USER  < mv_par08 .OR. C7_USER > mv_par09 
		dbSkip()
		Loop
	Endif
	If	C7_EMITIDO == "S" .And. mv_par05 == 1
		dbSkip()
		Loop
	Endif
	If (C7_CONAPRO == "B" .And. mv_par10 == 1) .Or.;
	   (C7_CONAPRO != "B" .And. mv_par10 == 2)
		dbSkip()
		Loop
	Endif
	If	(C7_EMISSAO < mv_par03) .Or. (C7_EMISSAO > mv_par04)
		dbSkip()
		Loop
	Endif
	If	C7_TIPO == 2
		dbSkip()
		Loop
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Consiste este item. EM ABERTO                                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If mv_par14 == 2
		If SC7->C7_QUANT-SC7->C7_QUJE <= 0 .Or. !EMPTY(SC7->C7_RESIDUO)
			dbSelectArea("SC7")
			dbSkip()
			Loop
		Endif
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Consiste este item. ATENDIDOS                                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If mv_par14 == 3
		If SC7->C7_QUANT > SC7->C7_QUJE
			dbSelectArea("SC7")
			dbSkip()
			Loop
		Endif
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Filtra Tipo de SCs Firmes ou Previstas                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !MtrAValOP(mv_par11, 'SC7')
		dbSkip()
		Loop
	EndIf

	MaFisEnd()
	u_DipFIniPC(SC7->C7_NUM,,,cFiltro)

	nTotMerc	:= 0
	nTotal		:= 0
	nTotSt      := 0 //MCVN - 24/04/2009
	nTotIPI     := 0
	nPagina		:= 0
	nDescProd:= 0
	nSavRec  := SC7->(Recno())
	NumPed   := SC7->C7_NUM
	nLinObs  := 0
	aPedido  := {SC7->C7_FILIAL,SC7->C7_NUM,SC7->C7_EMISSAO,SC7->C7_FORNECE,SC7->C7_LOJA,SC7->C7_TIPO}
	
	oPrint:Startpage()
	DIPR064Cab(@nlin)
	nLin 	 -= 10
	cDestMat := ""

While !Eof() .And. C7_FILIAL = xFilial("SC7") .And. C7_NUM == NumPed

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Consiste este item. EM ABERTO                                ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If mv_par14 == 2
			If SC7->C7_QUANT-SC7->C7_QUJE <= 0 .Or. !EMPTY(SC7->C7_RESIDUO)
				dbSelectArea("SC7")
				dbSkip()
				Loop
			Endif
		Endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Consiste este item. ATENDIDOS                                ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If mv_par14 == 3
			If SC7->C7_QUANT > SC7->C7_QUJE
				dbSelectArea("SC7")
				dbSkip()
				Loop
			Endif
		Endif

		If Ascan(aSavRec,Recno()) == 0		// Guardo recno p/gravacao
			AADD(aSavRec,Recno())
		Endif
		If lEnd
			Goto Bottom
			Exit
		Endif

		IncRegua()

		LinVer(@nLin,40)   
		nIt++ 
     
		
//     	If MV_PAR14 = 2
//			LinVer(@nLin,40) 
//			nIt++          
//		Endif     
	
		If (nIt%2) == 0 .And. File("cinza_escuro.bmp")            
			oPrint:SayBitmap(nLin,0060,"cinza_escuro.bmp",3060,40)
		EndIf	

		
	   	oPrint:Say(nlin , 070,	C7_ITEM+If(!lUserComp,+"     "+Posicione("SB1",1,xFilial("SB1") + SC7->C7_PRODUTO ,"B1_LOTEDIP"),"")      	,ArialN10	,100)
	   //	oPrint:Say(nlin , 070,	C7_NUMSC  				      			  	,ArialN10	,100)
 		oPrint:Say(nlin , 0280,Transform(Alltrim(C7_PRODUTO)+If(C7_ICMSRET>0,SPACE(3)+"*",""),PesqPict("SC7","c7_produto"))	  	,ArialN10	,100)

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Pesquisa Descricao do Produto                                ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		ImpProd()           
		SC1->(DbSetOrder(1))
		/*
		If SC1->(MsSeek(xFilial("SC1")+SC7->C7_NUMSC+SC7->C7_ITEMSC))
			// Descrição do Status da Viagem
			aRetBox1 	:= {}
			aRetBox1 	:= RetSx3Box( Posicione('SX3', 2, 'C1_TPCPA', 'X3CBox()' ),,, 1 )
			cDestItem 	:= AllTrim( aRetBox1[ Ascan( aRetBox1, { |x| x[ 2 ] == SC1->C1_TPCPA } ) , 3 ] )
			cDestMat	+= Iif(cDestItem$cDestMat,"",cDestItem+"/")
		EndIf
		*/
		If SC7->C7_DESC1 != 0 .or. SC7->C7_DESC2 != 0 .or. SC7->C7_DESC3 != 0
			nDescProd+= CalcDesc(SC7->C7_TOTAL,SC7->C7_DESC1,SC7->C7_DESC2,SC7->C7_DESC3)
		Else
			nDescProd+=SC7->C7_VLDESC
		Endif
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Inicializacao da Observacao do Pedido.                       ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !EMPTY(SC7->C7_OBS) .And. nLinObs < 5
			nLinObs++
			cVar:="cObs"+StrZero(nLinObs,2)
			Eval(MemVarBlock(cVar),SC7->C7_OBS)
		Endif           
		_cComprador := SC7->C7_USER
       
   		If cEmpAnt+cFilAnt == '0401'                                                                                  
   			//Imprimir o código da Especificação do Material na Health Quality Matriz - MCVN 19/01/11
			LinVer(@nLin,40)
			nIt++
    		oPrint:Say(nlin , 0500,	"E.M. Nº: "+Posicione("SB1",1,xFilial("SB1") + SC7->C7_PRODUTO ,"B1_ESPEMAT"),CourN08B	,100) // +;If(!lTipPedido,"   LOTE:_______________________  VALIDADE:_____/_____/_____","")    	,CourN08B	,100)// RBorges, comentado, solicitado pela Rafaela Beazin 19/09/16
   		Else
   			//Imprimir o Reg. Anvisa MCVN - 10/06/09
			LinVer(@nLin,40)
			nIt++
    		oPrint:Say(nlin , 0500,	"Nº Anvisa: "+Posicione("SB1",1,xFilial("SB1") + SC7->C7_PRODUTO ,"B1_REG_ANV"),CourN08B	,100) // +; If(!lTipPedido,"   LOTE:_______________________  VALIDADE:_____/_____/_____","")    	,CourN08B	,100) // RBorges, comentado, solicitado pela Rafaela Beazin 19/09/16
    	Endif
		dbSkip()
EndDo
    
    //Imprime mensagem referente a isenção de ST na Dipromed - MCVN 21-06-10
    If cEmpAnt+cFilAnt = "0104" .And. lTipPedido
	    dbSkip(-1)
    	LinVer(@nLin,40)
    	LinVer(@nLin,40) 
//    	oPrint:Box(nlin,0050,nlin+100,2850)
		oPrint:Say(nlin , 0070,	cMsgIsenSt 	,CourN10B	,100)
	   	LinVer(@nLin,40)                                     
	   	oPrint:Say(nlin , 0070,	cMsg2IsenSt	,CourN10B	,100)	   	
	    dbSkip()
	Endif
	dbGoto(nSavRec)

	FinalPed(nDescProd)		// Imprime os dados complementares do PC
	ImpRodape()
    oPrint:Endpage()
	MaFisEnd()
	If Len(aSavRec)>0
		For i:=1 to Len(aSavRec)
			dbGoto(aSavRec[i])
			RecLock("SC7",.F.)  //Atualizacao do flag de Impressao
			Replace C7_QTDREEM With (C7_QTDREEM+1)
			Replace C7_EMITIDO With "S"
			MsUnLock()
		Next
		dbGoto(aSavRec[Len(aSavRec)])		// Posiciona no ultimo elemento e limpa array
	Endif

	Aadd(aPedMail,aPedido)

	aSavRec := {}
	dbSkip()
EndDo

//RBorges 31/07/2013 - A chamda do PdfMail(UsrRetMAIL(_cComprador))
// que antes era aqui, mudei para ser chamada antes do Return.T.
// da função. Motivo, envia o email sem o anexo atual, pois não tinha sido gravado ainda

_cArquivo:="C:\PedCompras\"+cPrefixo+".pdf"
Do While File(_cArquivo)
	nCont++
	fErase(_cArquivo)
	if nCont > 1
		MsgAlert("FECHAR o arquivo "+cPrefixo+" antes de gerar o novo relatório.","ATENÇÃO!")
	EndIf
	Loop
EndDo

oPrint:Preview()


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Executa o ponto de entrada M110MAIL quando a impressao for   ³
//³ enviada por email, fornecendo um Array para o usuario conten ³
//³ do os pedidos enviados para possivel manipulacao.            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock("M110MAIL")
	lEnvMail := HasEmail(,,,,.F.)
	If lEnvMail
		Execblock("M110MAIL",.F.,.F.,{aPedMail})
	EndIf
EndIf

dbSelectArea("SC7")
dbClearFilter()
dbSetOrder(1)

dbSelectArea("SX3")
dbSetOrder(1)

//RBorges 31/07/2013 - Adicionei a funcao CpyT2S para copiar o 
//arquivo do diretorio local para o RootPath), pois apenas assim se consegue pegar o anexo.
CpyT2S( "C:\PedCompras\"+cPrefixo+"*.pdf", "\RELATO\PDF" )

//RBorges 31/07/2013 - O envio do email era chamado antes do oPrint:Preview(),
// agora é chamado daqui para conseguir pegar o anexo atual. 
If MV_PAR15 == 1 .And. MV_PAR01==MV_PAR02 .And. lPodeEnv
	PdfMail(UsrRetMAIL(_cComprador))
EndIF                    



Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ ImpProd  ³ Autor ³ CONSULTORIA           ³ Data ³          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Pesquisar e imprimir  dados Cadastrais do Produto.         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ImpProd(Void)                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ DIPR064                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ImpProd()
LOCAL nBegin := 0, cDescri := "", nLinha:=0
Local	nTamDesc := 65

If Empty(mv_par06)
	mv_par06 := "B1_DESC"
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Impressao da descricao generica do Produto.                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If AllTrim(mv_par06) == "B1_DESC"
	dbSelectArea("SB1")
	dbSetOrder(1)
	dbSeek( xFilial("SB1")+SC7->C7_PRODUTO )
	cDescri := Alltrim(SB1->B1_DESC)
	dbSelectArea("SC7")
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Impressao da descricao cientifica do Produto.                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If AllTrim(mv_par06) == "B5_CEME"
	dbSelectArea("SB5")
	dbSetOrder(1)
	If dbSeek( xFilial("SB5")+SC7->C7_PRODUTO )
		cDescri := Alltrim(B5_CEME)
	EndIf
	dbSelectArea("SC7")
EndIf

dbSelectArea("SC7")
If AllTrim(mv_par06) == "C7_DESCRI"
	cDescri := Alltrim(SC7->C7_DESCRI)
EndIf

If Empty(cDescri)
	dbSelectArea("SB1")
	dbSetOrder(1)
	MsSeek( xFilial("SB1")+SC7->C7_PRODUTO )
	cDescri := Alltrim(SB1->B1_DESC)
	dbSelectArea("SC7")
EndIf

dbSelectArea("SA5")
dbSetOrder(1)
If dbSeek(xFilial("SA5")+SC7->C7_FORNECE+SC7->C7_LOJA+SC7->C7_PRODUTO).And. !Empty(SA5->A5_CODPRF)
	cDescri := cDescri + " ("+Alltrim(A5_CODPRF)+")"
EndIf
dbSelectArea("SC7")

nLinha:= MLCount(cDescri,nTamDesc)

oPrint:Say(nlin , 0500,MemoLine(cDescri,nTamDesc,1) 		           	,ArialN9	,100)        

ImpCampos()
For nBegin := 2 To nLinha
	LinVer(@nLin,40)
	If (nIt%2) == 0 .And. File("cinza_escuro.bmp")
		oPrint:SayBitmap(nLin,0060,"cinza_escuro.bmp",3060,40)
	EndIf
	oPrint:Say(nlin , 0500,Memoline(cDescri,nTamDesc,nBegin) 		           	,ArialN9	,100)        
Next nBegin

Return NIL
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ ImpCampos³ Autor ³Consultoria        ³ Data ³          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Imprimir dados Complementares do Produto no Pedido.        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ImpCampos(Void)                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ DIPR064                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ImpCampos()
Local nTxMoeda := IIF(SC7->C7_TXMOEDA > 0,SC7->C7_TXMOEDA,Nil)

dbSelectArea("SC7")


		//nColBoxd > esta com valor=50
		nColBoxd := 1800  //1700
oPrint:Say(nlin , nColBoxd,Transform(SC7->C7_DATPRF,PesqPict("SC7","C7_DATPRF"))	           	,ArialN10	,100)  
If MV_PAR07 == 2 .And. !Empty(SC7->C7_SEGUM)
		nColBoxd += 200 //1900
	oPrint:Say(nlin , nColBoxd,Transform(SC7->C7_QTSEGUM,"@E 999,999,999")	  ,ArialN10	,100)   
		nColBoxd += 215 // 2170
	oPrint:Say(nlin , nColBoxd,Transform(SC7->C7_SEGUM,PesqPict("SC7","C7_UM"))		   	,ArialN10	,100)    			     
		nColBoxd += 085 // 2310
	oPrint:Say(nlin , nColBoxd,Transform(xMoeda((SC7->C7_TOTAL/SC7->C7_QTSEGUM),SC7->C7_MOEDA,MV_par12,SC7->C7_DATPRF,,nTxMoeda), PesqPict("SC7","C7_PRECO",14, mv_par12)	)	 ,ArialN10	,100)   	

ElseIf MV_PAR14 == 2
		nColBoxd += 200 //1900
	oPrint:Say(nlin , nColBoxd,Transform(SC7->C7_QUANT-SC7->C7_QUJE,"@E 999,999,999") 	 ,ArialN10	,100)   
		nColBoxd += 215 //2170
	oPrint:Say(nlin , nColBoxd,Transform(SC7->C7_UM,PesqPict("SC7","C7_UM"))		          	,ArialN10	,100)    			     
		nColBoxd += 085 //2310
	oPrint:Say(nlin , nColBoxd,Transform(xMoeda(SC7->C7_PRECO,SC7->C7_MOEDA,MV_par12,SC7->C7_DATPRF,,nTxMoeda), PesqPict("SC7","C7_PRECO",14,MV_par12))		 		   			          	,ArialN10	,100)   
Else
   		nColBoxd += 200 //1900
	oPrint:Say(nlin ,nColBoxd,Transform(SC7->C7_QUANT,"@E 999,999,999") 	 ,ArialN10	,100)   
		nColBoxd += 215 //2170
	oPrint:Say(nlin , nColBoxd,Transform(SC7->C7_UM,PesqPict("SC7","C7_UM"))		          	,ArialN10	,100)    			     
		nColBoxd += 085 //2310
	oPrint:Say(nlin , nColBoxd,Transform(xMoeda(SC7->C7_PRECO,SC7->C7_MOEDA,MV_par12,SC7->C7_DATPRF,,nTxMoeda), PesqPict("SC7","C7_PRECO",14,MV_par12))		 		   			          	,ArialN10	,100)   

EndIf

If MV_PAR14 == 2
		nColBoxd += 305 //2650
	oPrint:Say(nlin ,2530,Transform(xMoeda(((SC7->C7_TOTAL/SC7->C7_QUANT)*(SC7->C7_QUANT-SC7->C7_QUJE)),SC7->C7_MOEDA,MV_par12,SC7->C7_DATPRF,,nTxMoeda), PesqPict("SC7","C7_TOTAL",16,MV_par12))    	,ArialN10	,100)   	
Else
		nColBoxd += 305 //2650 
	oPrint:Say(nlin ,2530,Transform(xMoeda((SC7->C7_TOTAL),SC7->C7_MOEDA,MV_par12,SC7->C7_DATPRF,,nTxMoeda), PesqPict("SC7","C7_TOTAL",16,MV_par12))    	,ArialN10	,100)   	
Endif  
		nColBoxd += 315 //2950
oPrint:Say(nlin , 2750,Transform(SC7->C7_IPI,PesqPictQt("C7_IPI",5))	   							,ArialN10	,100)   	

nTotIPI += SC7->C7_VALIPI
nTotal  += SC7->C7_TOTAL
nTotSt  += SC7->C7_ICMSRET //MCVN - 24/04/2009
//nTotMerc:=MaFisRet(,"NF_TOTAL")
nTotMerc:= ntotal + nTotIPI + nTotSt// inclusão de valor total das mercadorias
       
If nTotSt > 0                            
	If nTotal > nTotMerc
		If (nTotal-(nTotSt+nTotIPI))<>nTotMerc
			lSomaST := .T.
		Else
			lSomaST := .F.
		EndIf
	Else 
		If (nTotal+nTotSt+nTotIPI)==nTotMerc
			lSomaST := .T.   
		Else
			lSomaST := .F.
		EndIf	
	EndIf	
EndIf

Return .T.
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ FinalPed ³ Autor ³ CONSULTORIA           ³ Data ³          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Imprime os dados complementares do Pedido de Compra        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ FinalPed(Void)                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ DIPR064                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function FinalPed(nDescProd)

Local nk		:= 1
Local nG		:= 0
Local nX		:= 0
Local nQuebra	:= 0
Local nTotDesc	:= nDescProd
Local lNewAlc	:= .F.
Local lLiber 	:= .F.
Local lImpLeg	:= .T.
Local lImpLeg2	:= .F.
Local cComprador:=""
LOcal cAlter	:=""
Local cAprov	:=""
//Local nTotIpi	:= MaFisRet(,'NF_VALIPI')
Local nTotIcms	:= MaFisRet(,'NF_VALICM')
Local nTotDesp	:= MaFisRet(,'NF_DESPESA')
Local nTotFrete	:= MaFisRet(,'NF_FRETE')
Local nTotalNF	:= MaFisRet(,'NF_TOTAL')
Local nTotSeguro:= MaFisRet(,'NF_SEGURO') 
Local aValIVA   := MaFisRet(,"NF_VALIMP")
Local nValIVA   :=0
Local nTxMoeda  := IIF(SC7->C7_TXMOEDA > 0,SC7->C7_TXMOEDA,Nil)
Local cComprador := UsrFullName(SC7->C7_USER)


If cPaisLoc <> "BRA" .And. !Empty(aValIVA)
	For nG:=1 to Len(aValIVA)
		nValIVA+=aValIVA[nG]
	Next
Endif
// Finaliza o Pedido 
LinVer(@nLin,040)                   
If nLin < 1580 .Or. (nLin > 1600 .And. nLin < 1980 )
	oPrint:Line(nLin,0050, nLin, 2850)  
	oPrint:Line(If(nLin < 1580,1600,2000),0050, nLin, 2850)  
EndIf
If nLin > 1580
	nLin := 2200
	LinVer(@nLin,10)
	oPrint:Line(1600,0050, 0460, 2850)  
EndIf
	cMensagem:= ""//Formula(C7_MSG)

 nLinBoxs := 1600 //Controlar recuo superior  - 23/07/2013  RBorges
 nColBoxe := 2200 //Controlar recuo esquerdo  - 23/07/2013  RBorges
 nColBoxi := 2180 //Controlar recuo inferior  - 23/07/2013  RBorges
 nColBoxd := 2850 //Controlar recuo direito   - 23/07/2013  RBorges
	


// Box dos Valores
oPrint:Box(nLinBoxs,nColBoxe,nColBoxi,nColBoxd)
	nLinBoxs += 50  //1650
	nColBoxe += 20  //2220
oPrint:Say(nLinBoxs,nColBoxe,"Descontos:"+Transform(C7_DESC1,"@E 999.99")+"% /"+Transform(C7_DESC2,"@E 999.99")+"% /"+Transform(C7_DESC3,"@E 999.99")+"%" 	,ArialN10B	,100)  
	nColBoxe += 610 //2830
oPrint:Say(nLinBoxs,2630,Transform(xMoeda(nTotDesc,SC7->C7_MOEDA,MV_par12,SC7->C7_DATPRF,,nTxMoeda),"@E 999,999,999.99") 	,ArialN10B	,100)  
	nLinBoxs += 50  //1700
	nColBoxe -= 610 //2220
oPrint:Say(nLinBoxs,nColBoxe,"Total das Mercadorias:"	,	ArialN10B	,100)  
	nColBoxe += 610 //2830
oPrint:Say(nLinBoxs,2600,Transform(xMoeda(nTotal,SC7->C7_MOEDA,MV_par12,SC7->C7_DATPRF,,nTxMoeda),"@E 999,999,999.99"),ArialN10B	,100)  
	nLinBoxs += 50  //1750
	nColBoxe -= 610  //2220
oPrint:Say(nLinBoxs,nColBoxe,"Total com Impostos:"		,	ArialN10B	,100)  
	nColBoxe += 610 //2830
oPrint:Say(nLinBoxs,2600,Transform(xMoeda(nTotal+nTotIPI+IIf(lSomaSt,nTotSt,0),SC7->C7_MOEDA,MV_par12,SC7->C7_DATPRF,,nTxMoeda),"@E 999,999,999.99"),ArialN10B	,100)  

// Box Impostos

 nLinBoxs += 30 //Controlar recuo superior  - 23/07/2013  RBorges
 nColBoxe -= 630//Controlar recuo esquerdo  - 23/07/2013  RBorges
 nColBoxi := 2180//Controlar recuo inferior  - 23/07/2013  RBorges
 nColBoxd := 2850 //Controlar recuo direito   - 23/07/2013  RBorges    

//oPrint:Box(1780,2200,2200,3002)
oPrint:Box(nLinBoxs,nColBoxe,nColBoxi,nColBoxd)

	nLinBoxs += 50   //1830
	nColBoxe += 20   //2220	
oPrint:Say(nLinBoxs,2220,"IPI:" 		           	,	ArialN10B	,100)  
	nColBoxe += 080  //2400
oPrint:Say(nLinBoxs,nColBoxe,Transform(xMoeda(nTotIPI,SC7->C7_MOEDA,MV_par12,SC7->C7_DATPRF,,nTxMoeda), "@E 999,999,999.99"),ArialN10	,100)   
	nColBoxe += 170  //2650
oPrint:Say(nLinBoxs,nColBoxe,"ICMS:" 		           	,	ArialN10B	,100)  
	nColBoxe += 100  //2830
oPrint:Say(nLinBoxs,nColBoxe,Transform(xMoeda(nTotIcms,SC7->C7_MOEDA,MV_par12,SC7->C7_DATPRF,,nTxMoeda), "@E 999,999,999.99"),ArialN10	,100)   
	nLinBoxs += 40   //1870
	nColBoxe -= 510  //2220	
oPrint:Say(nLinBoxs,2220,"Frete:" 		           	,	ArialN10B	,100)  
	nColBoxe += 080   //2400
oPrint:Say(nLinBoxs,2300,Transform(xMoeda(nTotFrete,SC7->C7_MOEDA,MV_par12,SC7->C7_DATPRF,,nTxMoeda), "@E 999,999,999.99"),ArialN10	,100)   
	nColBoxe += 170   //2650
oPrint:Say(nLinBoxs,2470,"Despesas:" 	           	,	ArialN10B	,100)  
oPrint:Say(nLinBoxs,2590,Transform(xMoeda(nTotDesp,SC7->C7_MOEDA,MV_par12,SC7->C7_DATPRF,,nTxMoeda), "@E 999,999,999.99"),ArialN10	,100)   
	nLinBoxs += 40   //1910
	nColBoxe := 2220  //2220
oPrint:Say(nLinBoxs,nColBoxe,"ST :" 		           	,	ArialN10B	,100)  
	nColBoxe += 080  //2400
oPrint:Say(nLinBoxs,nColBoxe,Transform(xMoeda(nTotSt,SC7->C7_MOEDA,MV_par12,SC7->C7_DATPRF,,nTxMoeda), "@E 999,999,999.99"),ArialN10	,100)    //MCVN - 24/04/2009
	nColBoxe += 170  //2650
oPrint:Say(nLinBoxs,nColBoxe,"Seguro:" 		           	,	ArialN10B	,100)  
	nColBoxe += 120  //2830
oPrint:Say(nLinBoxs,nColBoxe,Transform(xMoeda(nTotSeguro,SC7->C7_MOEDA,MV_par12,SC7->C7_DATPRF,,nTxMoeda), "@E 999,999,999.99"),ArialN10	,100)   

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Posiciona o Arquivo de Empresa SM0.                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cAlias := Alias()
dbSelectArea("SM0")
dbSetOrder(1)   // forca o indice na ordem certa
nRegistro := Recno()
dbSeek(SUBS(cNumEmp,1,2)+SC7->C7_FILENT)

If lTipPedido
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Imprime endereco de entrega do SM0 somente se o MV_PAR13 =" "³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  
	// Box Local Entrega/Cobranca  / Observacoes
	
 nLinBoxs += 10   //Controlar recuo superior  - 23/07/2013  RBorges
 nColBoxe -= 2540 //2780Controlar recuo esquerdo  - 23/07/2013  RBorges
 nColBoxi -= 470 //Controlar recuo inferior  - 23/07/2013  RBorges
 nColBoxd -= 655 //656-804Controlar recuo direito   - 23/07/2013  RBorges 
	                                
//	oPrint:Box(1920,0050,1730,2202)
	oPrint:Box(nLinBoxs,nColBoxe,nColBoxi,nColBoxd)
    If cEmpAnt=='01'
	If cFilAnt = '01'
		If SC7->C7_XMC = "1" 
		  		
		  		nLinBoxs := 1960 //1960
				nColBoxe := 0070 //0070
			oPrint:Say(nLinBoxs,nColBoxe,"Local de Faturamento:" 				           	,	ArialN10B	,100)
		Else 
		  		nLinBoxs := 1960 //1960
				nColBoxe := 0070 //0070
			oPrint:Say(nLinBoxs,nColBoxe,"Local de Entrega:" 				           	,	ArialN10B	,100)
		Endif
	Else
		If SC7->C7_XMC = "1"
		
		  		nLinBoxs := 1960 //1960
				nColBoxe := 0070 //0070
			oPrint:Say(nLinBoxs,nColBoxe,"Local de Faturamento:" 				           	,	ArialN10B	,100)
		Else
		  		nLinBoxs := 1960 //1960
				nColBoxe := 0070 //0070
		oPrint:Say(nLinBoxs,nColBoxe,"Local de Entrega/Faturamento:"	           	,	ArialN10B	,100) 
		Endif
	Endif
Else
		  		nLinBoxs := 1960 //1960
				nColBoxe := 0070 //0070
	oPrint:Say(nLinBoxs,nColBoxe,"Local de Entrega:" 		        			   	,	ArialN10B	,100)
Endif
	
If Empty(MV_par13)
	If SC7->C7_XMC = "1" 
		nLinBoxs := 1960 //1960
		nColBoxe := 0610 //0610
		If cEmpAnt+cFilAnt = '0401'		
			oPrint:Say(nLinBoxs,nColBoxe,"AV. VEREADOR JOAO PEDRO FERRAZ, 1255 - BOM RETIRO -  JARINU - SP - "+Trans(Alltrim(SM0->M0_CEPCOB),cCepPict),	ArialN10	,100)
		Else
			oPrint:Say(nLinBoxs,nColBoxe,AllTrim(SM0->M0_ENDCOB)+" - "+AllTrim(SM0->M0_CIDCOB)+" - "+AllTrim(SM0->M0_ESTCOB)+" - "+Trans(Alltrim(SM0->M0_CEPCOB),cCepPict),	ArialN10	,100)
		EndIf
	else 
		nLinBoxs := 1960 //1960
		nColBoxe := 0610 //0610
        If cEmpAnt+cFilAnt = '0401'           
			oPrint:Say(nLinBoxs,nColBoxe,"AV. VEREADOR JOAO PEDRO FERRAZ, 1255 - BOM RETIRO -  JARINU - SP - "+Trans('13240000',cCepPict),	ArialN10	,100)
     		nLinBoxs += 0030 //1990
		  	oPrint:Say(nLinBoxs,nColBoxe,"Agendar a entrega no tel: (11)2398-1888 ramal 221 ou e-mail: agendamento@healthquality.ind.br",ArialN10B,100) 	  	 
		Else
       		nColBoxe := 0610 //0610                     
			//oPrint:Say(nLinBoxs,nColBoxe,AllTrim(SM0->M0_ENDENT)+" - "+AllTrim(SM0->M0_CIDENT)+" - "+AllTrim(SM0->M0_ESTENT)+" - "+Trans(Alltrim(SM0->M0_CEPENT),cCepPict),	ArialN10	,100) //Rafael Moraes Rosa - 13/01/2023 - LINHA COMENTADA
			oPrint:Say(nLinBoxs,nColBoxe,AllTrim(cEndEnt)+" - "+AllTrim(cCidEnt)+" - "+AllTrim(cEstEnt)+" - "+Trans(Alltrim(cCEPEnt),cCepPict),	ArialN10	,100) //Rafael Moraes Rosa - 13/01/2023 - LINHA SUBSTITUIDA
        EndIf
   Endif
Else
	nLinBoxs := 1960 //1960
	nColBoxe := 0450 //0450
	oPrint:Say(nLinBoxs,nColBoxe,AllTrim(MV_par13),ArialN10,100)
Endif
	
dbGoto(nRegistro)
dbSelectArea( cAlias )  

If cEmpAnt=='01'
	If cFilAnt = '01'
		If SC7->C7_XMC = "1" 
		
 			   nLinBoxs := 2030 //2030
			   nColBoxe := 0070 //0070
			oPrint:Say(nLinBoxs,nColBoxe,"Local de Cobranca/Entrega:" 				           	,	ArialN10B	,100)
		Else
		
 			   nLinBoxs := 2030  //2030
			   nColBoxe := 0070 //0070
			oPrint:Say(nLinBoxs,nColBoxe,"Local de Cobranca/Faturamento:" 		           	,	ArialN10B	,100)
		Endif
		
	Else
		If SC7->C7_XMC = "1"
			
 			   nLinBoxs := 2030  //2030
			   nColBoxe := 0070 //0070
			oPrint:Say(nLinBoxs,nColBoxe,"Local de Cobranca/Entrega:" 				           	,	ArialN10B	,100)
		Else
		
 			   nLinBoxs := 2030 //2030
			   nColBoxe := 0070 //0070
			oPrint:Say(nLinBoxs,nColBoxe,"Local de Cobranca:" 		           	,	ArialN10B	,100)
		Endif
	Endif
Else         

 			   nLinBoxs := 2030  //2030
			   nColBoxe := 0070 //0070
	oPrint:Say(nLinBoxs,nColBoxe,"Local de Cobranca:" 		   			        	,	ArialN10B	,100)
		Endif 
		
If cEmpAnt+cFilAnt = '0401'
	        
			   nLinBoxs := 2030  //2030
			   nColBoxe := 0610  //0610
	oPrint:Say(nLinBoxs,nColBoxe,"AV. VEREADOR JOAO PEDRO FERRAZ, 1255 - BOM RETIRO -  JARINU - SP - "+Trans('13240000',cCepPict),	ArialN10	,100) 
 	
Else
	
	//oPrint:Say(1670,0450,AllTrim(SM0->M0_ENDCOB)+" - "+AllTrim(SM0->M0_CIDCOB)+" - "+AllTrim(SM0->M0_ESTCOB)+" - "+Trans(Alltrim(SM0->M0_CEPCOB),cCepPict),	ArialN10	,100)
	
	nLinBoxs := 2030 //2030
	nColBoxe := 610  //0610
	oPrint:Say(nLinBoxs,nColBoxe,"RUA BARTOLOMEU PAES,  441 - SAO PAULO - SP - "+Trans('05092000',cCepPict),	ArialN10	,100)
	     	EndIf

	
	dbSelectArea("SE4")
	dbSetOrder(1)
	dbSeek(xFilial("SE4")+SC7->C7_COND)
	dbSelectArea("SC7")
	
	
	dbSelectArea("SM4")
	dbSetOrder(1)
	dbSeek(xFilial("SM4")+SC7->C7_REAJUST)
	dbSelectArea("SC7")
	
	
	// Box Obs Frete/ Reajuste 
	
		 nLinBoxs := 1930  //Controlar recuo superior  - 23/07/2013  RBorges
	 	 nColBoxe := 2200 //Controlar recuo esquerdo  - 23/07/2013  RBorges
     	 nColBoxi := 2050 //Controlar recuo inferior  - 23/07/2013  RBorges
	 	 nColBoxd := 2850 //Controlar recuo direito   - 23/07/2013  RBorges 
	
	oPrint:Box(nLinBoxs,nColBoxe,nColBoxi,nColBoxd)
	
		 nLinBoxs += 45 // 1975   
	     nColBoxe += 20 // 2220
	oPrint:Say(nLinBoxs,nColBoxe,"Obs. do Frete:"  	,	ArialN10B	,100)
		 nColBoxe += 300 // 2520
	oPrint:Say(nLinBoxs,nColBoxe,IF( SC7->C7_TPFRETE $ "F","FOB",IF(SC7->C7_TPFRETE $ "C","CIF"," " ))  	,	ArialN10	,100)
   		 nLinBoxs += 45 // 2025  
	     nColBoxe -= 300 // 2220
	oPrint:Say(nLinBoxs,nColBoxe,"Reajuste:" 	  	,	ArialN10B	,100)
	  	 nColBoxe += 200 // 2420
	oPrint:Say(nLinBoxs,nColBoxe,AllTrim(Transform(SC7->C7_REAJUST, PesqPict("SC7","c7_reajust",,MV_par12)))+ ' ' +AllTrim(SM4->M4_DESCR),	ArialN10	,100)
	
	
	/*
	oPrint:Box(2000,0050,2200,2200)
	oPrint:Say(2050,0200,cComprador  	,ArialN10B	,100)
	oPrint:Say(2100,0200,"COMPRADOR"	,ArialN12B	,100)
	oPrint:Say(2100,1000,"GERENTE"		,ArialN12B	,100)
	oPrint:Say(2100,1800,"DIRETORIA"	,ArialN12B	,100)  */
	
		 nLinBoxs := 2050  //Controlar recuo superior  - 23/07/2013  RBorges
	 	 nColBoxe := 0050 //Controlar recuo esquerdo  - 23/07/2013  RBorges
     	 nColBoxi := 2180 //Controlar recuo inferior  - 23/07/2013  RBorges
	 	 nColBoxd := 2200 //Controlar recuo direito   - 23/07/2013  RBorges 
	
	oPrint:Box(nLinBoxs,nColBoxe,nColBoxi,nColBoxd)
		 nLinBoxs += 0050  // 2100
	 	 nColBoxe += 0150  // 0200
	oPrint:Say(nLinBoxs,nColBoxe,cComprador  	,ArialN10B	,100)
		 nLinBoxs := 2150 // 2150
	oPrint:Say(nLinBoxs,nColBoxe,"COMPRADOR"	,ArialN12B	,100)
	 	 nColBoxe += 0800  // 1000    
	If cEmpAnt+cFilAnt == '0401' // MCVN - 19/01/11
		oPrint:Say(nLinBoxs,nColBoxe,"APROVADOR"	,ArialN12B	,100)
	Else                                                 
		oPrint:Say(nLinBoxs,nColBoxe,"GERENTE"		,ArialN12B	,100)
	Endif
		 nColBoxe += 0800 // 1800
	oPrint:Say(nLinBoxs,nColBoxe,"DIRETORIA"	,ArialN12B	,100)
	
	// Box Total Geral
		 nLinBoxs := 2050  //Controlar recuo superior  - 23/07/2013  RBorges
	 	 nColBoxe := 2200 //Controlar recuo esquerdo  - 23/07/2013  RBorges
     	 nColBoxi := 2180 //Controlar recuo inferior  - 23/07/2013  RBorges
	 	 nColBoxd := 2850 //Controlar recuo direito   - 23/07/2013  RBorges 
	
	oPrint:Box(nLinBoxs,nColBoxe,nColBoxi,nColBoxd)
		 nLinBoxs := 2150 //2150 
	 	 nColBoxe := 2220 //2220
	oPrint:Say(nLinBoxs,nColBoxe,"TOTAL GERAL:" 		           	,ArialN12B	,100)
             nColBoxe := 2200 //2200
		 	 nColBoxe := 2600 //2810
	oPrint:Say(nLinBoxs,nColBoxe,Transform(xMoeda(ntotal+nTotIPI+IIf(lSomaSt,nTotSt,0),SC7->C7_MOEDA,MV_par12,SC7->C7_DATPRF,,nTxMoeda), "@E 999,999,999.99")	,ArialN12B	,100)
	 
	//Giovani Zago 06/12/11
 
		 nLinBoxs += 0100 //2270
	 	 nColBoxe -= 2530 //0100
   	If cEmpAnt+cFilAnt = '0401'
		oPrint:Say(nLinBoxs,nColBoxe,"Atentar       Para       Local       de       ENTREGA       e       COBRANÇA. " 	,ArialN24B	,100)
	Else
		oPrint:Say(nLinBoxs,nColBoxe,"FAVOR CADASTRAR EM SEU SISTEMA PARA QUE POSSAMOS RECEBER O XML E DANFE,"	,ArialN12B,100,CLR_RED)
		oPrint:Say(nLinBoxs,nColBoxe+1400," NFE@DIPROMED.COM.BR"	,ArialN12B,100,CLR_BLUE)
		 nLinBoxs += 0100
		oPrint:Say(nLinBoxs,nColBoxe,"Atentar       Para       Local       de       ENTREGA       e       FATURAMENTO. " 	,ArialN24B	,100)
	EndIf
   //	oPrint:Say(nLinBoxs,nColBoxe,"Atentar       Para       Local       de       ENTREGA       e       FATURAMENTO. " 	,ArialN24B	,100)
	
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Inicializar campos de Observacoes.                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	If Empty(cObs02)
		If Len(cObs01) > 130
			cObs := cObs01
			cObs01 := Substr(cObs,1,130)
			For nX := 2 To 4
				cVar  := "cObs"+StrZero(nX,2)
				&cVar := Substr(cObs,(130*(nX-1))+1,130)
			Next
		EndIf
	Else
		cObs01:= Substr(cObs01,1,IIf(Len(cObs01)<130,Len(cObs01),130))
		cObs02:= Substr(cObs02,1,IIf(Len(cObs02)<130,Len(cObs01),130))
		cObs03:= Substr(cObs03,1,IIf(Len(cObs03)<130,Len(cObs01),130))
		cObs04:= Substr(cObs04,1,IIf(Len(cObs04)<130,Len(cObs01),130))
	EndIf
		 nLinBoxs -= 0595 //1760
	oPrint:Say(nLinBoxs,nColBoxe,"Observacoes: "+cObs01	,ArialN8B	,100)
		 nLinBoxs += 0030 //1790
	oPrint:Say(nLinBoxs,nColBoxe,cObs02	,ArialN8B	,100)
		 nLinBoxs += 0040 //1830
	oPrint:Say(nLinBoxs,nColBoxe,cObs03	,ArialN8B	,100)
                        
		 nLinBoxs += 0040 //1870
	If !Empty(cMensagem)
		oPrint:Say(nLinBoxs,nColBoxe,cMensagem	,ArialN8B	,100)
	Else
		oPrint:Say(nLinBoxs,nColBoxe,cObs04	,ArialN8B	,100)
	EndIf
	
	// Box Nota Rodape
	
		 nLinBoxs := 1600  //Controlar recuo superior  - 23/07/2013  RBorges
	 	 nColBoxe := 0050 //Controlar recuo esquerdo  - 23/07/2013  RBorges
     	 nColBoxi := 1730 //Controlar recuo inferior  - 23/07/2013  RBorges
	 	 nColBoxd := 2198 //Controlar recuo direito   - 23/07/2013  RBorges 
	
//	oPrint:Box(1600,0050,2050,2200)
	oPrint:Box(nLinBoxs,nColBoxe,nColBoxi,nColBoxd)
//	oPrint:Say(1620,0070,"NOTA: So aceitaremos a mercadoria se na sua nota fiscal constar o numero do nosso pedido de compras."	,ArialN10B	,100)                                                                        
	
	     nLinBoxs += 0035 // 1635
	 	 nColBoxe += 0020 // 0070
	IF cEmpAnt=='01'
		oPrint:Say(nLinBoxs,nColBoxe,"NOTA: Só aceitaremos a mercadoria se na sua nota fiscal constar o número do nosso pedido de compras."	,ArialN10B	,100)       	
		 nLinBoxs += 0035 // 1670
	    oPrint:Say(nLinBoxs,nColBoxe,"Favor agendar a entrega no email agendamento@dipromed.com.br ou pelo NOVO telefone 11 3646-0160 no Ramal 0404 com Marcos Bernardo até às 17H. " ,ArialN10B	,100)
		 nLinBoxs += 0050
		oPrint:Say(nLinBoxs,nColBoxe,"INFORMAR À COMPRAS, QUALQUER ALTERAÇÃO NA EMBALAGEM OU PRODUTO ADQUIRIDO PELA DIPROMED! " ,ArialN12B ,100, CLR_RED)
	ElseIf cEmpAnt=="04" 
 		If cFilAnt = "01"
 		
 			     nLinBoxs := 1635 // 1635
			 	 nColBoxe := 0070 // 0070
 			oPrint:Say(nLinBoxs,nColBoxe,"NOTA: Só aceitaremos a mercadoria se na sua nota fiscal constar o número do nosso pedido de compras. Favor notificar a Empresa Health Quality,"	,ArialN8B	,100)                                                                        
       			 nLinBoxs := 1665 // 1665
 			oPrint:Say(nLinBoxs,nColBoxe," de qualquer alteração no produto.Todos os produtos deverão conter rótulos de identificação descrevendo lote, data de fabricação e validade."   ,ArialN8B	,100)
			     nLinBoxs := 1695 // 1695
			oPrint:Say(nLinBoxs,nColBoxe,"SÓ ACEITAREMOS NO MÁXIMO DOIS LOTES DE FABRICAÇÃO. "   ,ArialN8B	,100)
			     nLinBoxs := 1725 // 1725
			oPrint:Say(nLinBoxs,nColBoxe,"Nos dois ultimos dias do mês não receberemos mercadorias. Para maiores informações entrar em contato (11) 2398-1888 ramal 221. ",ArialN10B	,100)
			//oPrint:Say(nLinBoxs,nColBoxe,"Não receberemos mercadorias entre os dias 27 e 31 de cada mês. Para maiores informações entrar em contato (11) 2398-1888. ",ArialN10B	,100)
	    Else
	    	nLinBoxs := 1635 // 1635 
	    	oPrint:Say(nLinBoxs,nColBoxe,"NOTA: Só aceitaremos a mercadoria se na sua nota fiscal constar o número do nosso pedido de compras."	,ArialN10B	,100)                                                                        
		    nLinBoxs += 0050 // 1670
		    oPrint:Say(nLinBoxs,nColBoxe,"Favor agendar a entrega no email agendamento@dipromed.com.br ou pelo NOVO telefone 11 3646-0160 no Ramal 0404 com Marcos Bernardo até às 17H.  " ,ArialN10B	,100)
	    Endif
	Endif
	
	
	dbSelectArea("SC7")
	If !Empty(C7_APROV)
		lNewAlc := .T.
		cComprador := UsrFullName(SC7->C7_USER)
		If C7_CONAPRO != "B"
			lLiber := .T.
		EndIf
		dbSelectArea("SCR")
		dbSetOrder(1)
		dbSeek(xFilial("SCR")+"PC"+SC7->C7_NUM)
		While !Eof() .And. SCR->CR_FILIAL+Alltrim(SCR->CR_NUM)==xFilial("SCR")+SC7->C7_NUM .And. SCR->CR_TIPO == "PC"
			cAprov += AllTrim(UsrFullName(SCR->CR_USER))+" ["
			Do Case
				Case SCR->CR_STATUS=="03" //Liberado
					cAprov += "Ok" 
					cAprovador := Posicione('SAK', 1, xFilial('SAK') + SCR->CR_LIBAPRO, 'AK_NOME') // MCVN - 19/01/11
				Case SCR->CR_STATUS=="04" //Bloqueado
					cAprov += "BLQ"
				Case SCR->CR_STATUS=="05" //Nivel Liberado
					cAprov += "##"
				OtherWise                 //Aguar.Lib
					cAprov += "??"
			EndCase
			cAprov += "] - "
			dbSelectArea("SCR")
			dbSkip()
		Enddo        
		If cEmpAnt+cFilAnt == '0401' // MCVN - 19/01/11
			
			 	 nLinBoxs := 2100 // 2100
			 	 nColBoxe := 1000 // 1000
			oPrint:Say(nLinBoxs,nColBoxe,cAprovador  	,ArialN10B	,100)
		EndIf
		If !Empty(SC7->C7_GRUPCOM)
			dbSelectArea("SAJ")
			dbSetOrder(1)
			dbSeek(xFilial("SAJ")+SC7->C7_GRUPCOM)
			While !Eof() .And. SAJ->AJ_FILIAL+SAJ->AJ_GRCOM == xFilial("SAJ")+SC7->C7_GRUPCOM
				If SAJ->AJ_USER != SC7->C7_USER
					cAlter += AllTrim(UsrFullName(SAJ->AJ_USER))+"/"
				EndIf
				dbSelectArea("SAJ")
				dbSkip()
			EndDo
		EndIf
	EndIf

Else 
		 nLinBoxs := 1600  //Controlar recuo superior  - 23/07/2013  RBorges
	 	 nColBoxe := 0050 //Controlar recuo esquerdo  - 23/07/2013  RBorges
     	 nColBoxi := 2052 //Controlar recuo inferior  - 23/07/2013  RBorges
	 	 nColBoxd := 1100 //Controlar recuo direito   - 23/07/2013  RBorges   

	oPrint:Box(nLinBoxs,nColBoxe,nColBoxi,nColBoxd)
   		 nLinBoxs += 0040
   		 nColBoxe := 0100
	oPrint:Say(1630,nColBoxe    ,"TRANSPORTE ADEQUADO (FECHADO E LIMPO)   ( ) Sim ( ) Não",CourN10B,100)
   		 nLinBoxs += 0040
	oPrint:Say(nLinBoxs,nColBoxe,"DANFE X PEDIDO DE COMPRAS               ( ) Sim ( ) Não",CourN10B,100)
		 nLinBoxs += 0050
	oPrint:Say(nLinBoxs,nColBoxe,"EMBALAGEM ÍNTEGRA                       ( ) Sim ( ) Não",CourN10B,100)
		 nLinBoxs += 0050
	oPrint:Say(nLinBoxs,nColBoxe,"PRODUTO ÍNTEGRO                         ( ) Sim ( ) Não",CourN10B,100)
		 nLinBoxs += 0050
	oPrint:Say(nLinBoxs,nColBoxe,"VALIDADE MAIOR QUE 18 MESES             ( ) Sim ( ) Não",CourN10B,100)
		 nLinBoxs += 0050
	oPrint:Say(nLinBoxs,nColBoxe,"ROTULAGEM ADEQUADA                      ( ) Sim ( ) Não",CourN10B,100)
		 nLinBoxs += 0050
	oPrint:Say(nLinBoxs,nColBoxe,"DANFE X FÍSICO                          ( ) Sim ( ) Não",CourN10B,100) 
		 nLinBoxs += 0080
	oPrint:Say(nLinBoxs,nColBoxe,"OCORRENCIA - COR Nº _______/_______"	, ArialN12B	,100) 	
   		 nLinBoxs -= 0380 
   		 nColBoxe += 1060
	oPrint:Say(nLinBoxs,nColBoxe,"OBSERVAÇÕES PARA ESTE PEDIDO: " , ArialN8B	,100)
	
	dbGoto(nRegistro)
	dbSelectArea( cAlias )
	dbSelectArea("SE4")
	dbSetOrder(1)
	dbSeek(xFilial("SE4")+SC7->C7_COND)
	dbSelectArea("SC7")
	
	dbSelectArea("SM4")
	dbSetOrder(1)
	dbSeek(xFilial("SM4")+SC7->C7_REAJUST)
	dbSelectArea("SC7")
	
	// Box Obs Frete/ Reajuste
	
		 nLinBoxs := 1930  //Controlar recuo superior  - 23/07/2013  RBorges
	 	 nColBoxe := 2200 //Controlar recuo esquerdo  - 23/07/2013  RBorges
     	 nColBoxi := 2050 //Controlar recuo inferior  - 23/07/2013  RBorges
	 	 nColBoxd := 2850 //Controlar recuo direito   - 23/07/2013  RBorges   

	oPrint:Box(nLinBoxs,nColBoxe,nColBoxi,nColBoxd)  
	    
		 nLinBoxs += 0040  // 1970
	 	 nColBoxe += 0020  // 2220
	oPrint:Say(nLinBoxs,nColBoxe,"Obs. do Frete:"  	,	ArialN10B	,100)
	     nColBoxe += 0300  // 2520
	oPrint:Say(nLinBoxs,nColBoxe,IF( SC7->C7_TPFRETE $ "F","FOB",IF(SC7->C7_TPFRETE $ "C","CIF"," " ))  	,	ArialN10	,100)
		 nLinBoxs += 0045  // 2015
	 	 nColBoxe -= 0300 // 2220
	oPrint:Say(nLinBoxs,nColBoxe,"Reajuste:" 	  	,	ArialN10B	,100)
	 	 nColBoxe += 0200 // 2220
	oPrint:Say(nLinBoxs,nColBoxe,AllTrim(Transform(SC7->C7_REAJUST, PesqPict("SC7","c7_reajust",,MV_par12)))+ ' ' +AllTrim(SM4->M4_DESCR),	ArialN10	,100)
	       
		 nLinBoxs := 2050  //Controlar recuo superior - 23/07/2013  RBorges
	 	 nColBoxe := 0050 //Controlar recuo esquerdo  - 23/07/2013  RBorges
     	 nColBoxi := 2180 //Controlar recuo inferior  - 23/07/2013  RBorges
	 	 nColBoxd := 2200 //Controlar recuo direito   - 23/07/2013  RBorges   
	
	oPrint:Box(nLinBoxs,nColBoxe,nColBoxi,nColBoxd)
	 
	     nLinBoxs += 0050 // 2100
	 	 nColBoxe += 0150 // 0200
	oPrint:Say(nLinBoxs,nColBoxe,cComprador  	,ArialN10B	,100)
		 nLinBoxs += 0050 // 2150
	oPrint:Say(nLinBoxs,nColBoxe,"COMPRADOR"	,ArialN12B	,100)
 		 nColBoxe += 0800 // 1000
//	oPrint:Say(nLinBoxs,nColBoxe,"CONFERENTE"	,ArialN12B	,100) // RBorges, comentado, solicitado pela Rafaela Beazin 19/09/16
   		 nColBoxe += 0800 // 1800
//	oPrint:Say(nLinBoxs,nColBoxe,"ARMAZENADOR"	,ArialN12B	,100)
	
	// Box Total Geral
	
		 nLinBoxs := 2050  //Controlar recuo superior - 23/07/2013  RBorges
	 	 nColBoxe := 2200 //Controlar recuo esquerdo  - 23/07/2013  RBorges
     	 nColBoxi := 2180 //Controlar recuo inferior  - 23/07/2013  RBorges
	 	 nColBoxd := 2850 //Controlar recuo direito   - 23/07/2013  RBorges  
	oPrint:Box(nLinBoxs,nColBoxe,nColBoxi,nColBoxd)
		 nLinBoxs += 0100 //2150
	 	 nColBoxe := 2220 //2220
	oPrint:Say(nLinBoxs,nColBoxe,"TOTAL GERAL:" 		           	,ArialN12B	,100)
		 nColBoxe := 2600 //2780
	oPrint:Say(nLinBoxs,nColBoxe,Transform(xMoeda(nTotal+nTotIPI+IIf(lSomaSt,nTotSt,0),SC7->C7_MOEDA,MV_par12,SC7->C7_DATPRF,,nTxMoeda), "@E 999,999,999.99")	,ArialN12B	,100)
            
		 nLinBoxs += 0090 //2150
	 	 nColBoxe -= 2730 //005
//	oPrint:Say(nLinBoxs,0050, "DATA ______/_____/_________" 		, ArialN12B	,100) // RBorges, comentado, solicitado pela Rafaela Beazin 19/09/16
		 nColBoxe += 0600 //0650
//	oPrint:Say(nLinBoxs,0650, "CHEGADA ______:_____"   			  	, ArialN12B	,100)
		 nColBoxe += 0500 //1150
//	oPrint:Say(nLinBoxs,1150, "INÍCIO  ______:_____"            	, ArialN12B	,100)
		 nColBoxe += 0500 //1650
 //	oPrint:Say(nLinBoxs,1650, "TÉRMINO ______:_____"            	, ArialN12B	,100)
    
    If cEmpAnt+cFilAnt == '0401'
    	 nLinBoxs := 2260 //2260
	 	 nColBoxe := 2200 //2200
    
    oPrint:Say(nLinBoxs,nColBoxe, "HORA. RECEBIMENTO DAS: "+GetMv("ES_HR064"),ArialN12B  ,100)
   //	oPrint:Say(2260,2150, "OCORRENCIA NRO: COR _______/_______"	, ArialN12B	,100) 	
	 
	EndIf
	
	dbSelectArea("SC7")
	If !Empty(C7_APROV)
		lNewAlc := .T.
		cComprador := UsrFullName(SC7->C7_USER)
		If C7_CONAPRO != "B"
			lLiber := .T.
		EndIf
		dbSelectArea("SCR")
		dbSetOrder(1)
		dbSeek(xFilial("SCR")+"PC"+SC7->C7_NUM)
		While !Eof() .And. SCR->CR_FILIAL+Alltrim(SCR->CR_NUM)==xFilial("SCR")+SC7->C7_NUM .And. SCR->CR_TIPO == "PC"
			cAprov += AllTrim(UsrFullName(SCR->CR_USER))+" ["
			Do Case
				Case SCR->CR_STATUS=="03" //Liberado
					cAprov += "Ok"
				Case SCR->CR_STATUS=="04" //Bloqueado
					cAprov += "BLQ"
				Case SCR->CR_STATUS=="05" //Nivel Liberado
					cAprov += "##"
				OtherWise                 //Aguar.Lib
					cAprov += "??"
			EndCase
			cAprov += "] - "
			dbSelectArea("SCR")
			dbSkip()                  `
		Enddo
		If !Empty(SC7->C7_GRUPCOM)
			dbSelectArea("SAJ")
			dbSetOrder(1)
			dbSeek(xFilial("SAJ")+SC7->C7_GRUPCOM)
			While !Eof() .And. SAJ->AJ_FILIAL+SAJ->AJ_GRCOM == xFilial("SAJ")+SC7->C7_GRUPCOM
				If SAJ->AJ_USER != SC7->C7_USER
					cAlter += AllTrim(UsrFullName(SAJ->AJ_USER))+"/"
				EndIf
				dbSelectArea("SAJ")
				dbSkip()
			EndDo
		EndIf
	EndIf

EndIf

Return .T.
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ ImpRodape³ Autor ³ CONSULTORIA           ³ Data ³          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Imprime o rodape do formulario e salta para a proxima folha³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ImpRodape(Void)   			         					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ 					                     				      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ DIPR064                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function ImpRodape(lSalto)
Local nLimite := 0 
Default lSalto := .F.

nLimite := If(lSalto, 2000, 1600)

//Box cpo:Solic Compra

//oPrint:Box(380,0050,nLimite,300)  

		 nLinBoxs := 0380  //Controlar recuo superior - 23/07/2013  RBorges
	 	 nColBoxe := 0240 //Controlar recuo esquerdo  - 23/07/2013  RBorges
     	 //nColBoxi := 2200 //Controlar recuo inferior  - 23/07/2013  RBorges
	 	 nColBoxd := 0240 //Controlar recuo direito   - 23/07/2013  RBorges 
oPrint:Line(nLinBoxs,nColBoxe, nLimite, nColBoxe)  

//Box cpo:Codigo

//oPrint:Box(380,0260,nLimite,580) 

//Box cpo:Descricao

//oPrint:Box(380,0580,nLimite,1640) 
		nColBoxe:= 0440
oPrint:Line(nLinBoxs,nColBoxe, nLimite,nColBoxe)  

//Box cpo:Dt.Entrega

//oPrint:Box(380,1640,nLimite,1890)
		nColBoxe:= 1750 
oPrint:Line(nLinBoxs,nColBoxe, nLimite,nColBoxe)  

//Box cpo:Qtde

//oPrint:Box(380,1890,nLimite,2200)
		nColBoxe:= 1940
oPrint:Line(nLinBoxs,nColBoxe, nLimite, nColBoxe)  

//Box cpo:Un

//oPrint:Box(380,2200,nLimite,2300)
		nColBoxe:= 2200
oPrint:Line(nLinBoxs,nColBoxe, nLimite,nColBoxe)  

//Box cpo:Pr.Unit

//oPrint:Box(380,2300,nLimite,2650)
		nColBoxe:= 2270
oPrint:Line(nLinBoxs,nColBoxe, nLimite, nColBoxe)  

//Box cpo:Pr.Total

//oPrint:Box(380,2650,nLimite,2995)
		nColBoxe:= 2520
oPrint:Line(nLinBoxs,nColBoxe, nLimite, nColBoxe)  

//Box cpo:IPI

//oPrint:Box(380,2995,nLimite,2850)   
		nColBoxe:= 2910
oPrint:Line(nLinBoxs,2730, nLimite,2730)  

// Linha do Final dos Itens

oPrint:Line(nLimite,0050, nLimite, 2850)  

If lSalto
	oPrint:Say(2070,1400,"Continua...",ArialN10B	,100)  
EndIf

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AjustaSX1 ºAutor  ³Consultoria         º Data ³ 01/07/2007  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ DIPR064                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function AjustaSX1(cPerg)

Local aHelpPor	:= {}
Local aHelpEng	:= {}
Local aHelpSpa	:= {}

Aadd( aHelpPor, "Filtra os itens do PC a serem impressos " )
Aadd( aHelpPor, "Todos,somente os abertos ou Atendidos.  " )
Aadd( aHelpEng, "                                        " )
Aadd( aHelpEng, "                                        " )
Aadd( aHelpSpa, "                                        " )
Aadd( aHelpSpa, "                                        " )
PutSx1(cPerg,"12","Lista quais ?       ","Cuales Lista ?      ","List which ?        ","mv_che","N",1,0,1,"C","","","","","mv_par12",;
"Todos ","Todos ","All ","","Em Aberto ","En abierto ","Open ","Atendidos ","Atendidos ","Serviced ","","","","","","","","","","")
PutSX1Help("P.MTR11014.",aHelpPor,aHelpEng,aHelpSpa)


Aadd( aHelpPor, "Envia o pedido de compra para o fornecedor" )
Aadd( aHelpPor, "por e-mail, em formato JPEG               " )
PutSx1(cPerg,"15","Envia por E-mail?    ","","","mv_chf","C",1,0,1,"C","","","","","mv_par15","Sim","Sim","Sim","","","Nao","Nao","Nao","","","","","","","","","","","","")
PutSX1Help("P.MTR11015.",aHelpPor,aHelpEng,aHelpSpa)

Return
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³DIPR064   ³ Autor ³ Consultoria           ³ Data ³03.07.2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Cabecalho do Relatorio                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function DIPR064Cab(nlin)
Local cString1  := ""
Local aRetBox1  := {}
Local nOrden, cCGC
LOCAL cMoeda
             
// Box Geral       
            

		 nLinBoxs := 0080 //Controlar recuo superior - 23/07/2013   RBorges
	 	 nColBoxe := 0050 //Controlar recuo esquerdo  - 23/07/2013  RBorges
     	 nColBoxi := 2180 //Controlar recuo inferior  - 23/07/2013  RBorges
	 	 nColBoxd := 2850 //Controlar recuo direito   - 23/07/2013  RBorges 
oPrint:Box(nLinBoxs,nColBoxe,nColBoxi,nColBoxd)

//oPrint:Box(50,0050,2200,3130)

If !lTipPedido
	oPrint:Say(075,2520,"Impresso: "+ Dtoc(dDataBase) +" as "+ TIME(),ArialN8B	,100)   //075,2670
Endif
// Cabecalho + logo 
		 
		 nLinBoxs := 0080  
	 	 nColBoxe := 0050
     	 nColBoxi := 0380
	 	 nColBoxd := 2850

oPrint:Box(nLinBoxs,nColBoxe,nColBoxi,nColBoxd)
// Para destaque do titulo das colnas 
		 
		 
     	nColBoxi += 0080 
	 	
oPrint:Box(nLinBoxs,nColBoxe,nColBoxi,nColBoxd)
//  
//Box Itens
		 nLinBoxs := 0380  
	 	 nColBoxe := 0050
     	 nColBoxi := 0460
	 	 nColBoxd := 2850

oPrint:Box(nLinBoxs,nColBoxe,nColBoxi,nColBoxd)  

// Ajuste de Logotipo - MCVN 03/03/2010
IF cEmpAnt=="01"                
	If !lTipPedido
		If cFilAnt == "01"
			oPrint:SayBitmap(0085,0070,"Dipromedcon.BMP",378,290)
		Else 
			oPrint:SayBitmap(0085,0070,"Dipromedcon.BMP",378,290)
		EndIf
	Else	 
		If cFilAnt == "01"
			oPrint:SayBitmap(0085,0070,"cnpj_mtz.BMP",378,290)
		Else 
			oPrint:SayBitmap(0085,0070,"cnpj_cd.BMP",378,290)
		EndIf	
	EndIf	
ELSEIf cEmpAnt=="04"                       
	oPrint:SayBitmap(0085,0070,"hq_logo.BMP",378,290)
ENDIF

		 nLinBoxs := 0120  
	 	 nColBoxe := 0700

IF cEmpAnt=="01" 
	oPrint:Say(nLinBoxs,nColBoxe, AllTrim(Upper(SM0->M0_NOMECOM))		 		,ArialN12B	,100)
		nLinBoxs += 0080
		nColBoxe += 0130
	oPrint:Say(nLinBoxs,nColBoxe,AllTrim(SM0->M0_ENDCOB)				   	,ArialN10	,100)
		nLinBoxs += 0040
		nColBoxe -= 0080
	oPrint:Say(nLinBoxs,nColBoxe,Transform(SM0->M0_CEPCOB,"@R 99999-999")+" - "+AllTrim(SM0->M0_BAIRCOB)+" - "+AllTrim(SM0->M0_CIDCOB)+" - "+AllTrim(SM0->M0_ESTCOB),ArialN10	,100)
		nLinBoxs += 0040
		nColBoxe -= 0080
oPrint:Say(nLinBoxs,nColBoxe,"PABX:"							  		,ArialN10	,100)   
	 		nColBoxe += 0115
oPrint:Say(nLinBoxs,nColBoxe,Substr(AllTrim(SM0->M0_TEL),3,12)  		,ArialN10	,100)   
			nColBoxe += 0270
oPrint:Say(nLinBoxs,nColBoxe,"FAX: "						  			,ArialN10	,100)   
			nColBoxe += 0085
oPrint:Say(nLinBoxs,nColBoxe,Substr(AllTrim(SM0->M0_FAX),3,12)	 		,ArialN10	,100)   
		nLinBoxs += 0040        
		nColBoxe -= 0400		
oPrint:Say(nLinBoxs,nColBoxe,"CNPJ:"									   		,ArialN10	,100)        
		nColBoxe += 0110
oPrint:Say(nLinBoxs,nColBoxe,Transform(SM0->M0_CGC,"@R 99.999.999/9999-99")	,ArialN10	,100)        
		nColBoxe += 0330
oPrint:Say(nLinBoxs,nColBoxe," IE:"									  		,ArialN10	,100)  
		nColBoxe += 0065
oPrint:Say(nLinBoxs,nColBoxe,Transform(SM0->M0_INSC,"@R 999.999.999.999")	,ArialN10	,100)     
		nLinBoxs += 0040
		nColBoxe -= 0305		
	oPrint:Say(nLinBoxs,nColBoxe,"www.dipromed.com.br" 					,ArialN10	,100) 
ELSEIf cEmpAnt=='04'
	oPrint:Say(nLinBoxs,nColBoxe, AllTrim(Upper(SM0->M0_NOMECOM))		 		,ArialN12B	,100)
		nLinBoxs += 0080
		nColBoxe += 0130
	oPrint:Say(nLinBoxs,nColBoxe,"AV. VEREADOR JOAO PEDRO FERRAZ, 1255"   	,ArialN10	,100)
		nLinBoxs += 0040
		nColBoxe -= 0080
	//oPrint:Say(nLinBoxs,nColBoxe,Transform(SM0->M0_CEPCOB,"@R 99999-999")+" - "+AllTrim(SM0->M0_BAIRCOB)+" - "+AllTrim(SM0->M0_CIDCOB)+" - "+AllTrim(SM0->M0_ESTCOB),ArialN10	,100)
		oPrint:Say(nLinBoxs,nColBoxe,Transform(SM0->M0_CEPCOB,"@R 99999-999")+" - "+"BOM RETIRO"+" - "+AllTrim(SM0->M0_CIDCOB)+" - "+AllTrim(SM0->M0_ESTCOB),ArialN10	,100)
		nLinBoxs += 0040
		nColBoxe -= 0080
oPrint:Say(nLinBoxs,nColBoxe,"PABX:"							  		,ArialN10	,100)   
	 		nColBoxe += 0115
oPrint:Say(nLinBoxs,nColBoxe,Substr(AllTrim(SM0->M0_TEL),3,12)  		,ArialN10	,100)   
			nColBoxe += 0270
oPrint:Say(nLinBoxs,nColBoxe,"FAX: "						  			,ArialN10	,100)   
			nColBoxe += 0085
oPrint:Say(nLinBoxs,nColBoxe,Substr(AllTrim(SM0->M0_FAX),3,12)	 		,ArialN10	,100)   
		nLinBoxs += 0040        
		nColBoxe -= 0400		
oPrint:Say(nLinBoxs,nColBoxe,"CNPJ:"									   		,ArialN10	,100)        
		nColBoxe += 0110
oPrint:Say(nLinBoxs,nColBoxe,Transform(SM0->M0_CGC,"@R 99.999.999/9999-99")	,ArialN10	,100)        
		nColBoxe += 0330
oPrint:Say(nLinBoxs,nColBoxe," IE:"									  		,ArialN10	,100)  
		nColBoxe += 0065
oPrint:Say(nLinBoxs,nColBoxe,Transform(SM0->M0_INSC,"@R 999.999.999.999")	,ArialN10	,100)     
		nLinBoxs += 0040
		nColBoxe -= 0305                                                                              
	oPrint:Say(nLinBoxs,nColBoxe,"www.healthquality.ind.br" 					,ArialN10	,100) 
ENDIF
                                    
//oPrint:Line(nlin,0050, nlin, 3150)  

//oPrint:Say(400, 070,"Sol.Compra"	         	  	,ArialN10B	,100)
		nLinBoxs:= 0435

oPrint:Say(nLinBoxs, 070,"Item"                          ,ArialN10B	,100)   
oPrint:Say(nLinBoxs, 280,"Codigo"	           			,ArialN10B	,100)   
oPrint:Say(nLinBoxs, 500,"Descricao do Material"			,ArialN10B	,100)   
oPrint:Say(nLinBoxs,1800,"Entrega"	           		,ArialN10B	,100)
If MV_PAR14 == 2
	oPrint:Say(nLinBoxs,1980,"Qtd. em Aberto"	 	 	,ArialN10B	,100)   
Else
	oPrint:Say(nLinBoxs,2000,"Quantidade"	      		,ArialN10B	,100)   
Endif
oPrint:Say(nLinBoxs,2215,"Un"				    		,ArialN10B	,100)   
oPrint:Say(nLinBoxs,2330,"Preco Unit"	    			,ArialN10B	,100)   
oPrint:Say(nLinBoxs,2570,"Preco Total"	    	  		,ArialN10B	,100)   
oPrint:Say(nLinBoxs,2750,"%IPI"			    	 		,ArialN10B	,100)   

		 nLinBoxs := 0460  
	 	 nColBoxe := 0050
     	 nColBoxi := 0460
	 	 nColBoxd := 2850   
oPrint:Line(nLinBoxs,nColBoxe, nColBoxi, nColBoxd)  
cMoeda := Iif(MV_par12<10,Str(MV_par12,1),Str(MV_par12,2))

nPagina++
oPrint:Say(140,2700,"Pag: "+StrZero(nPagina,4) 					 							,ArialN8B	,100)//2870   

If  !lTipPedido                                 
	If cEmpAnt = "01"
		oPrint:Say(120,1790,"ESPELHO DO PEDIDO DE COMPRAS: "					  		   						,ArialN14B	,100)     
		oPrint:Say(120,2480,Transform(SC7->C7_NUM,PesqPict("SC7","C7_NUM")),ArialN14B	,100) 	
	Else
		oPrint:Say(120,1790,"PRÉ-NOTA DE ENTRADA: "					  		   						,ArialN14B	,100)     
		oPrint:Say(120,2480,Transform(SC7->C7_NUM,PesqPict("SC7","C7_NUM")),ArialN14B	,100) 
	Endif

Else                                                                                      
	oPrint:Say(120,1790,"PEDIDO DE COMPRA: "					  		   						,ArialN14B	,100)     
	oPrint:Say(120,2380,Transform(SC7->C7_NUM,PesqPict("SC7","C7_NUM")),ArialN14B	,100)                             
Endif

dbSelectArea("SA2")
dbSetOrder(1)
dbSeek(xFilial("SA2")+SC7->C7_FORNECE+SC7->C7_LOJA)

		nLinBoxs:= 0200

oPrint:Say(nLinBoxs,1790,"FORNECEDOR:" 							 	  			 		  					,ArialN8	,100)
oPrint:Say(nLinBoxs,1980,SA2->A2_COD+"-"+SA2->A2_LOJA	   									,ArialN8	,100)   
oPrint:Say(nLinBoxs,2170,Substr(SA2->A2_NOME,1,50) 						 						,ArialN8	,100)
		nLinBoxs += 0030
oPrint:Say(nLinBoxs,1790,"ENDEREÇO:" 							 					  						,ArialN8	,100)
oPrint:Say(nLinBoxs,1980,Transform(SA2->A2_END,PesqPict("SA2","A2_END") )		  	,ArialN8	,100)
oPrint:Say(nLinBoxs,2610,Trim(SA2->A2_BAIRRO)											  			,ArialN8	,100)
		nLinBoxs += 0030
oPrint:Say(nLinBoxs,2335,Trim(SA2->A2_MUN)   					   			 						,ArialN8	,100) 
oPrint:Say(nLinBoxs,1980,Transform(SA2->A2_CEP,PesqPict("SA2","A2_CEP") ) 			,ArialN8	,100)   
oPrint:Say(nLinBoxs,2610,Transform(SA2->A2_EST,PesqPict("SA2","A2_EST") ) 			,ArialN8	,100)   

dbSelectArea("SX3")
nOrden = IndexOrd()
dbSetOrder(2)
dbSeek("A2_CGC")
cCGC := Alltrim(X3TITULO())
dbSetOrder(nOrden)
		nLinBoxs := 0282
dbSelectArea("SA2")
oPrint:Say(nLinBoxs,1790,"TEL/CONTATO:"					 																,ArialN8	,100)   
oPrint:Say(nLinBoxs,1980,"("+Substr(SA2->A2_DDD,1,3)+") "+Substr(SA2->A2_TEL,1,15)		  	,ArialN8	,100)

oPrint:Say(nLinBoxs,2335,Transform(SC7->C7_CONTATO,PesqPict("SC7","C7_CONTATO") ) 	,ArialN8	,100)   

oPrint:Say(nLinBoxs,2610,"FAX:" 							   																,ArialN8	,100) 
oPrint:Say(nLinBoxs,2680,"("+Substr(SA2->A2_DDD,1,3)+") "+SubStr(SA2->A2_FAX,1,15)  		,ArialN8	,100) 
		nLinBoxs += 0030
oPrint:Say(nLinBoxs,1865,"CNPJ:"              	 				 														,ArialN8	,100) 
oPrint:Say(nLinBoxs,1980,Transform(SA2->A2_CGC,PesqPict("SA2","A2_CGC") )  					,ArialN8	,100) 
oPrint:Say(nLinBoxs,2335,"IE:"									   						   									,ArialN8	,100)  
oPrint:Say(nLinBoxs,2385,	Transform(SA2->A2_INSCR,PesqPict("SA2","A2_INSCR") ) 				,ArialN8	,100)  
		nLinBoxs += 0030
oPrint:Say(nLinBoxs,1780,"Data Pedido:" 					 							,ArialN8B	,100)   
oPrint:Say(nLinBoxs,1980,Transform(SC7->C7_EMISSAO,PesqPict("SC7","C7_EMISSAO"))		   	,ArialN8B	,100)  
	   nLinBoxs += 0025
oPrint:Say(nLinBoxs,2230,"Cond.Pagamento:" 										,ArialN10B	,100)
SE4->(DbSetOrder(1))
SE4->(MsSeek(xFilial("SE4")+SC7->C7_COND))
		nLinBoxs := 0360
oPrint:Say(nLinBoxs,2570,SubStr(SE4->E4_DESCRI,1,40)	 						,ArialN10	,100)

nlin:=475    

dbSelectArea("SC7")
 
Return       
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³LinVer    ³ Autor ³ Consultoria           ³ Data ³29.06.2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Controle de Linhas e Quebras do Relatório                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function LinVer(nLin,nSoma,nLimite)
DEFAULT nLimite := 1980 //1580
nLin+=nSoma

If nLin > nLimite
	ImpRodape(.T.)
    oPrint:Endpage()
	oPrint:Startpage()
	DIPR064Cab(@nlin) 
	nLin+=30
EndIf
Return                                           


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PdfMail  ºAutor  ³Microsiga           º Data ³  01/22/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ DIPR064                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function PdfMail(cMailComprador)

//imagem boa qualidade
Local nLargura := 1300 //920
Local nAltura  := 920  //1300
Local nZoom    := 145         

Local cAccount  := Lower(Alltrim(GetMv("MV_RELACNT")))
Local cFrom     := Lower(Alltrim(GetMv("MV_RELACNT"))) //Lower(Alltrim(GetMv("MV_RELACNT")))
Local cPassword := Alltrim(GetMv("MV_RELPSW"))
Local cServer   := Alltrim(GetMv("MV_RELSERV"))  
Local cCC		:= cMailComprador
Local cBCC      := Alltrim(GetNewPar("ES_RELCCO",""))//"relatorios@dipromed.com.br"
Local cTo		:= AllTrim(SA2->A2_EMAIL)+If(Empty(AllTrim(SA2->A2_EMAILD)),'',';'+AllTrim(SA2->A2_EMAILD))
Local cAnexos	:= "\RELATO\PDF\"+cPrefixo+".pdf"
Local cFile     := cAnexos
LOCAL lSmtpAuth := GetNewPar("MV_RELAUTH",.F.)
LOCAL lAutOk	:= .F.
				  
If !Empty(AllTrim(POSICIONE("SU7",4,XFILIAL("SU7")+RetCodUsr(),"U7_EMAIL"))) .And. !Empty(AllTrim(POSICIONE("SU7",4,XFILIAL("SU7")+RetCodUsr(),"U7_SENHA")))
	cAccount  := AllTrim(POSICIONE("SU7",4,XFILIAL("SU7")+RetCodUsr(),"U7_EMAIL"))
	cFrom     := AllTrim(POSICIONE("SU7",4,XFILIAL("SU7")+RetCodUsr(),"U7_EMAIL"))
	cPassword := AllTrim(POSICIONE("SU7",4,XFILIAL("SU7")+RetCodUsr(),"U7_SENHA"))
EndIf	

cBody  := If(!Empty(_cBodyPrvt),_cBodyPrvt, "Segue em anexo Pedido de Compra")
cSubject := "Pedido de Compra nº:  " + NumPed

CONNECT SMTP SERVER cServer ACCOUNT cAccount PASSWORD cPassword Result lOk

If !lAutOk
	If ( lSmtpAuth )
		lAutOk := MailAuth(cAccount,cPassword)
	Else
		lAutOk := .T.
	EndIf
EndIf

If lOk .and. lAutOk 
	If !Empty(cCC)
		SEND MAIL FROM cFrom TO cTo CC cCC BCC cBcc SUBJECT Alltrim(cSubject) BODY cBody ATTACHMENT cAnexos Result lOk
		// Deleta os arquivos PDF do "\RELATO\PDF\"+cPrefixo+".pdf" depois de enviar o e-mail 
	   //	FErase(cFile)
	Else
		SEND MAIL FROM cFrom TO cTo SUBJECT Alltrim(cSubject) BODY cBody ATTACHMENT cAnexos Result lOk
	    // Deleta os arquivos PDF do "\RELATO\PDF\"+cPrefixo+".pdf" depois de enviar o e-mail 
		//FErase(cFile)
	EndIf
	If lOk
		MsgInfo("Email enviado com sucesso")
	Else
		GET MAIL ERROR cErro
		MsgStop("Não foi possível enviar o Email." +Chr(13)+Chr(10)+ cErro,"AVISO")
		Return .f.
	EndIf
Else
	GET MAIL ERROR cErro
	MsgStop("Erro na conexão com o SMTP Server." +Chr(13)+Chr(10)+ cErro,"AVISO")
	Return .f.
EndIf
DISCONNECT SMTP SERVER


Return .T.



/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³RetBody   ºAutor  ³Microsiga           º Data ³  01/29/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Abre uma Dialog para digitacao do corpo do e-mail          º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ DIPR064 - DIPROMED                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function RetBody()
Local cBody := ctrls+ctrls+ctrls+'*FAVOR CONFIRMAR O RECEBIMENTO E MENCIONAR NOSSO NUMERO DE PEDIDO EM SUA NOTA FISCAL. ';
					+ctrls+ctrls+ IF(cEmpAnt+cFilAnt=="0104",'DIPROMED ISENTA DE SUBSTITUIÇÃO TRIBUTÁRIA.','') ;   
					+ctrls+ctrls+ IF(cEmpAnt+cFilAnt=="0404",'FAVOR ATENTAR PARA ENDEREÇO DE FATURAMENTO/ENTREGA E COBRANÇA.','') ;
				   		  +ctrls+ IF(cEmpAnt='01' .or. cEmpAnt+cFilAnt='0404',"FAVOR AGENDAR A ENTREGA NO EMAIL AGENDAMENTO@DIPROMED.COM.BR OU PELO NOVO TELEFONE 11 3646-0160 NO RAMAL 0404 COM MARCOS BERNARDO ATé àS 17H. ","");
					+ctrls+ctrls+ IF(cEmpAnt='01',"FAVOR CADASTRAR EM SEU SISTEMA PARA QUE POSSAMOS RECEBER O XML E DANFE, NFE@DIPROMED.COM.BR","")					

DEFINE MSDIALOG oDlgEmail TITLE OemToAnsi("Digite a Mensagem do E-Mail") From 1,0 To 20,50 OF oMainWnd

@ 10,04 SAY "Mensagem:" PIXEL OF oDlgEmail
@ 18,04 Get cBody Size 186,070 MEMO  PIXEL OF oDlgEmail

@ 127, 132 Button "Ok"      			Size 28,10 Action Eval({||nOpca:=1,oDlgEmail:End()})  Pixel
@ 127, 162 Button "Cancela"  			Size 28,10 Action Eval({||nOpca:=2,oDlgEmail:End()})  Pixel
nOpca:=0

ACTIVATE MSDIALOG oDlgEmail CENTERED

If nOpca == 1
	Return cBody
Else          
	MV_PAR15 := 2 // MCVN - 06-03-08
	Return ""
Endif

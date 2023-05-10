#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "MATR340.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑณFun…o    ณ UMATR340 ณ Autor ณ   Alexandro Dias      ณ Data ณ 24.01.02 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ Consumos mes a mes                                         ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณOrigem    ณ Conversao realizada a partir do original MATR340.          ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณMelhoria01ณ Aumentado descricao do produto para 60 caracteres.         ณฑฑ
ฑฑณMelhoria02ณ Incluido quebra por fornecedor.                            ณฑฑ
ฑฑณMelhoria03ณ Incluido calculo da media de consumo conforme a Quantidade ณฑฑ
ฑฑณ          ณ de meses informada na parametro.                           ณฑฑ
ฑฑณMelhoria04ณ Incluido coluna de Saldo atual em estoque.                 ณฑฑ
ฑฑณMelhoria05ณ Incluido coluna de Saldo atual em estoque GY LOG.          ณฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
*/
User Function UMATR340()

//ณ Define Variaveis                                             ณ
LOCAL Tamanho  := "G"
LOCAL titulo   := STR0001	//"Consumos/Vendas mes a mes de Materiais"
LOCAL cDesc1   := STR0002	//"Este programa exibira' o consumo dos ultimos 12 meses de cada material"
LOCAL cDesc2   := STR0003	//"ou produto acabado. No caso dos produtos ele estara' listando o  total"
LOCAL cDesc3   := STR0004	//"das vendas."
LOCAL cString  := "SB1"
LOCAL aOrd     := {OemToAnsi(STR0005),OemToAnsi(STR0006),OemToAnsi(STR0007),OemToAnsi(STR0008),OemToAnsi("Por Fornecedor")}	//" Por Codigo         "###" Por Tipo           "###" Por Descricao     "###" Por Grupo        "
LOCAL wnrel    := "UMATR340"

//ณ Variaveis tipo Private padrao de todos os relatorios         ณ
PRIVATE aReturn:= {STR0009, 1,STR0010, 1, 2, 1, "",1 }	//"Zebrado"###"Administracao"

//PRIVATE nLastKey := 0 ,cPerg := "MTR340"
// FPADR(cPerg, cArq, cCampo, cTipo)  - Para ajustar o tamanho das perguntas no SX1- uso generico
PRIVATE cPerg  	:= U_FPADR( "MTR340","SX1","SX1->X1_GRUPO"," " ) //Fun็ใo criada por Sandro em 19/11/09.

U_DIPPROC(ProcName(0),U_DipUsr()) // JBS 05/10/2005 - Gravando o nome do Programa no SZU
//ณ Verifica as perguntas selecionadas                           ณ
//ณ Variaveis utilizadas para parametros                         ณ
//ณ mv_par01     // Codigo de                                    ณ
//ณ mv_par02	 // Codigo ate                                   ณ
//ณ mv_par03     // Tipo de                                      ณ
//ณ mv_par04     // Tipo ate                                     ณ
//ณ mv_par05     // Grupo de                                     ณ
//ณ mv_par06     // Grupo ate                                    ณ
//ณ mv_par07     // Descricao de                                 ณ
//ณ mv_par08     // Descricao ate                                ณ
//ณ mv_par09     // Do fornecedor                                ณ
//ณ mv_par10     // Ate fornecedor                               ณ
//ณ mv_par11     // Quantidade de Meses para Calculo da Media.   ณ
//ณ mv_par12     // Considera mes atual para Calculo da Media.   ณ


DbSelectArea("SX1")
DbSetOrder(1)
cPerg := PADR(cPerg, Len(SX1->X1_GRUPO), " " ) // Incluido por Sandro em 17/11/09.


pergunte(cPerg,.F.)

//ณ Envia controle para a funcao Setprint                        ณ
wnrel:=SetPrint(cString,wnrel,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,.F.,Tamanho)
If nLastKey = 27
	Set Filter to
	Return
Endif
SetDefault(aReturn,cString)
If nLastKey = 27
	Set Filter to
	Return
Endif                                                               
If cEmpAnt == '01' 
	If Aviso("Aten็ใo","Deseja imprimir o relat๓rio consolidado?",{"Sim","Nใo"},1) == 1
		RptStatus({|lEnd| C340ImpC(@lEnd,aOrd,wnRel,cString,tamanho,titulo)},titulo)
	Else
		RptStatus({|lEnd| C340Imp(@lEnd,aOrd,wnRel,cString,tamanho,titulo)},titulo)	 
	EndIf  		
Else 
	RptStatus({|lEnd| C340ImpH(@lEnd,aOrd,wnRel,cString,tamanho,titulo)},titulo)
EndIf

Return NIL

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑณFun…o    ณ C340IMP  ณ Autor ณ   Alexandro Dias      ณ Data ณ 24.01.02 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ Chamada do Relatorio                                       ณฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function C340Imp(lEnd,aOrd,WnRel,cString,tamanho,titulo)

//ณ Variaveis locais exclusivas deste programa                   ณ
LOCAL aMeses:= {STR0011,STR0012,STR0013,STR0014,STR0015,STR0016,STR0017,STR0018,STR0019,STR0020,STR0021,STR0022}	//"JAN"###"FEV"###"MAR"###"ABR"###"MAI"###"JUN"###"JUL"###"AGO"###"SET"###"OUT"###"NOV"###"DEZ"
LOCAL nX ,nAno := 0 ,nMes := 0 ,aSub[14] ,aTot[14] ,lPassou ,nCol ,nMesAux
LOCAL _cCodFor := ""
LOCAL _nMedia  := 0  

Local nEstq    := 0  // JBS 05/02/2010  -> Quantidade atual local 01 e 02
Local nAclass  := 0  // JBS 05/02/2010  -> Quantidade a classificar nos locais 01 e 02
Local nReserva := 0  // JBS 05/02/2010  -> Quantidade reservada nos locais 01 e 02
Local nSalPedi := 0  // JBS 05/02/2010  -> Saldo em Pedido de Compras nos locais 01 e 02
Local _cProduto:= ""  // RSB 22/08/2013 -> Quantidade do saldo Gy Log > RBORGES 08/02/2018 - Alterada para SALDO no 06
Local nSalGl   := ""  // RSB 22/08/2013 -> Quantidade do saldo Gy Log > RBORGES 08/02/2018 - Alterada para SALDO no 06
Local nTotPrg  := 0   // TEO - 29/07/2021 - Total Programado
Local cPctQEmb := AvSx3('B1_XQE',6)    // JBS 03/02/2010
Local cPctPrazo:= AvSx3('A2_PRAZO',6) // JBS 03/02/2010
Local lImprimiu:= .F. // JBS 05/02/2010

PRIVATE cMes ,cCondicao ,lContinua := .T. ,cCondSec ,cAnt

cbtxt    := SPACE(10)
cbcont   := 0
li       := 80
m_pag    := 1 //1 

//ณ Inicializa os codigos de caracter Comprimido/Normal da impressora ณ
nTipo    := IIF(aReturn[4]==1,15,18)

//ณ Soma a ordem escolhida ao titulo do relatorio                ณ
If Type("NewHead")#"U"
	NewHead += " ("+AllTrim(aOrd[aReturn[8]])+' - Media de consumo dos ultimos '+StrZero(mv_par11,2)+' Meses'+IIF(mv_par12==1,"/Considera Mes Atual","/Nao Considera Mes Atual") +") "
Else
	Titulo  += " ("+AllTrim(aOrd[aReturn[8]])+' - Media de consumo dos ultimos '+StrZero(mv_par11,2)+' Meses'+IIF(mv_par12==1,"/Considera Mes Atual","/Nao Considera Mes Atual") +") "
EndIf

//ณ Montagem Dos Dados do cabecalho do relatorio                 ณ
nAno := Year(dDataBase)
If month(dDatabase) < 12
	nAno--
Endif
nMes := MONTH(dDataBase)+1
IF nMes = 13
	nMes := 1
Endif
cMes := StrZero(nMes,2)    

//         1234567890123456789012345678901234567890123456789012345678901234567890
//         0        1         2         3         4         5         6         7         8         9        10        11        12        13        14        15        16        17        18        19        20        21        22
//         01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
cabec1 := "CODIGO  DESCRICAO                                                        U.M.   QTD POR EMB   PRAZO ENTREGA    " //"TIPO PRAZO "
cabec2 := ""

FOR nX := 1 TO 12
	IF aMeses[nMes] == STR0011 .And. nX != 1	//"JAN"
		nAno++
	EndIF
	cabec2 += Space(3)+aMeses[nMes]+"/"+StrZero(nAno,4)
	nMes++
	IF nMes > 12
		nMes := 1
	ENDIF
NEXT nX 
cabec2 += "      MEDIA  EST.ATUAL   RESERVAS  ENTR.PROG DISPONIVEL PED.COMPRA   SALDO_06        CQ"
dbSelectArea("SB1")
SetRegua(LastRec())
Set SoftSeek On
IF aReturn[8] == 5
	DbOrderNickName("B1FORNDESC")
Else
	Set Order To aReturn[8]
EndIF

If aReturn[8] == 5
	Seek cFilial+mv_par09
	cCondicao := "lContinua .And. !EOF() .And. B1_PROC <= mv_par10"
ElseIf aReturn[8] == 4
	Seek cFilial+mv_par05
	cCondicao := "lContinua .And. !EOF() .And. B1_GRUPO <= mv_par06"
ElseIf aReturn[8] == 3
	Seek cFilial+mv_par07
	cCondicao := "lContinua .And. !EOF() .And. B1_DESC <= mv_par08"
ElseIf aReturn[8] == 2
	Seek cFilial+mv_par03
	cCondicao := "lContinua .And. !EOF() .And. B1_TIPO <= mv_par04"
Else
	Seek cFilial+mv_par01
	cCondicao := "lContinua .And. !EOF() .And. B1_COD <= mv_par02"
Endif  

Set SoftSeek Off
AFILL(aTot,0)

Do While &cCondicao .and. B1_FILIAL == cFilial

	If aReturn[8] == 2

		cAnt      := B1_TIPO
		cCondSec  := "B1_TIPO == cAnt"
		cLinhaSub := STR0025+cAnt+" .........."	//"Total do tipo "

	ElseIf aReturn[8] == 4

		cAnt      := B1_GRUPO
		cCondSec  := "B1_GRUPO == cAnt"
		cLinhaSub := STR0026+cAnt+" ......."		//"Total do grupo "

	ElseIf aReturn[8] == 5

		cAnt      := B1_PROC
		cCondSec  := "B1_PROC == cAnt"
		cLinhaSub := "Fornecedor: "+cAnt+" ......."		//"Total do fornecedor "

	Else
		cCondSec := ".T."
	EndIf

	AFILL(aSub,0)
	lPassou := .F.

	Do While &cCondicao .And. &cCondSec .and. B1_FILIAL == cFilial

		If lEnd
			@Prow()+1,001 PSay STR0027	//"CANCELADO PELO OPERADOR"
			lContinua := .F.
			Exit
		Endif

		IncRegua()

		If B1_COD < mv_par01 .Or. B1_COD > mv_par02
			Skip
			Loop
		EndIf

		If B1_TIPO < mv_par03 .Or. B1_TIPO > mv_par04
			Skip
			Loop
		EndIf

		If B1_GRUPO < mv_par05 .Or. B1_GRUPO > mv_par06
			Skip
			Loop
		EndIf

		If B1_DESC < mv_par07 .Or. B1_DESC > mv_par08
			Skip
			Loop
		EndIf

		If B1_PROC < mv_par09 .Or. B1_PROC > mv_par10
			Skip
			Loop
		EndIf

		DbSelectArea("SB3")
		Seek cFilial+SB1->B1_COD
	
		IF !Found()
			dbSelectArea("SB1")
			dbSkip()
			Loop
		EndIF

		If li > 55 
		    If lImprimiu
		        li := 60 
		        Roda(cbcont,cbtxt,Tamanho)
		    EndIf
			Cabec(titulo,cabec1,cabec2,wnrel,Tamanho,nTipo)
		EndIf

		lPassou := .T.
		DbSelectArea('SB1')                                                   
		//---------------------------------------------------------------------
        // Posiciona o fornecedor do Produto para Impressใo do Prazo de Entrega
		//---------------------------------------------------------------------
        SA2->( DbSetOrder(1) )                                             // JBS 04/02/2010
        SA2->( DbSeek( xFilial('SA2') + SB1->B1_PROC + SB1->B1_LOJPROC) ) // JBS 04/02/2010
		//---------------------------------------------------------------------
		@ li,000 PSay Alltrim(B1_COD)
		@ li,008 PSay B1_DESC                          // JBS 03/02/2010
		@ li,073 PSay B1_UM                            // JBS 03/02/2010
		@ li,080 PSay B1_XQE Picture cPctQEmb           // JBS 03/02/2010
		@ li,097 PSay SA2->A2_PRAZO Picture cPctPrazo  // JBS 04/02/2010 - Usado A2_PRAZO ao Inves de B1_PE por solicitacao do Eriberto.
		//@ li,114 PSay B1_TIPE                          // JBS 04/02/2010
        lImprimiu:= .T.
		li++
		
		DbSelectArea('SB3')
		
		nCol    := 1  //
		nMesAux := nMes
		
		For nX := 1 To 12
		
			cCampo := "B3_Q&cMes"
			@ li,nCol PSay &(cCampo) Picture PesqPictQt("B3_Q01",10)
			aSub[nX] += &(cCampo)
			nMesAux++
		
			If nMesAux > 12
				nMesAux := 1
			EndIf
		
			cMes := StrZero(nMesAux,2)
			nCol += 11
		
		Next nX 
		
		_nMedia := U_Calc_Media(SB1->B1_COD,mv_par11,IIF(mv_par12==1,.T.,.F.))
		@ li,nCol PSay _nMedia PicTure PesqPictQt("B3_MEDIA",10)
        
//        nCol += 11
		SB2->( DbSetOrder(1) )

		nEstq    := 0  // JBS 05/02/2010
        nAclass  := 0  // JBS 05/02/2010
        nReserva := 0  // JBS 05/02/2010
        nSalPedi := 0  // JBS 05/02/2010
        nSalGl   := 0  // RSB 22/08/2013
		nTotPrg	 := 0  // TEO 19/07/2021
        nQtdCQ 	 := 0
        
        nQtdCQ 	 := u_DipSomaCQ(SB1->B1_COD,SB1->B1_PROC,SB1->B1_LOJPROC)        
            
		If SB2->( DbSeek(xFilial("SB2")+SB1->B1_COD+"01") )

			nEstq    += SB2->B2_QATU      // JBS 05/02/2010
            nReserva += SB2->B2_RESERVA   // JBS 05/02/2010
            nAClass  += SB2->B2_QACLASS   // JBS 05/02/2010
            nSalPedi += SB2->B2_SALPEDI   // JBS 05/02/2010
            
            _cProduto := SB2->B2_COD              // RSB 20/08/2013
            nSalGl    := U_Dip8Poder3(_cProduto) // RSB 20/08/2013

			If SB2->( DbSeek(xFilial("SB2")+SB1->B1_COD+"02") )
			    nEstq    += SB2->B2_QATU      // JBS 05/02/2010
                nReserva += SB2->B2_RESERVA   // JBS 05/02/2010
                nAClass  += SB2->B2_QACLASS   // JBS 05/02/2010
                nSalPedi += SB2->B2_SALPEDI   // JBS 05/02/2010
                
                _cProduto := SB2->B2_COD              // RSB 20/08/2013
                nSalGl    := U_Dip8Poder3(_cProduto) // RSB 20/08/2013
			Endif

			@ li,nCol += 11 PSay nEstq    PicTure PesqPictQt("B3_MEDIA",10)
   		    @ li,nCol += 11 PSay nReserva PicTure PesqPictQt("B3_MEDIA",10)   // JBS 05/02/2010
		    @ li,nCol += 11 PSay fQuery(_cProduto,'X') PicTure PesqPictQt("B3_MEDIA",10)   // JBS 05/02/2010
		    @ li,nCol += 11 PSay nEstq - nReserva - nAClass  PicTure PesqPictQt("B3_MEDIA",10)   // JBS 05/02/2010
		    @ li,nCol += 11 PSay nSalPedi PicTure PesqPictQt("B3_MEDIA",10)   // JBS 05/02/2010
		    @ li,nCol += 11 PSay nSalGl   PicTure PesqPictQt("B3_MEDIA",10)   // RSB 20/08/2013
 		    @ li,nCol += 11 PSay nQtdCQ   PicTure PesqPictQt("B3_MEDIA",10)   // RSB 20/08/2013
		Else
   		    @ li,nCol += 11 PSay 0 PicTure PesqPictQt("B3_MEDIA",10)   // JBS 05/02/2010
		    @ li,nCol += 11 PSay 0 PicTure PesqPictQt("B3_MEDIA",10)   // JBS 05/02/2010
		    @ li,nCol += 11 PSay 0 PicTure PesqPictQt("B3_MEDIA",10)   // JBS 05/02/2010
		    @ li,nCol += 11 PSay 0 PicTure PesqPictQt("B3_MEDIA",10)   // JBS 05/02/2010
			@ li,nCol += 11 PSay 0 PicTure PesqPictQt("B3_MEDIA",10)    
		    @ li,nCol += 11 PSay 0 PicTure PesqPictQt("B3_MEDIA",10)   // RSB 20/08/2013			
   		    @ li,nCol += 11 PSay 0 PicTure PesqPictQt("B3_MEDIA",10)   // RSB 20/08/2013			
		EndIF

		li += 2
		aSub[13] += _nMedia
		_cCodFor := SB1->B1_PROC
		
		DbSelectArea("SB1")
		DbSkip()

	EndDo

	If (aReturn[8] == 2 .Or. aReturn[8] == 4 .Or. aReturn[8] == 5) .And. lPassou

		li++

		IF aReturn[8] == 5
			SA2->(DbSetOrder(1))
			IF SA2->( DbSeek(xFilial("SA2")+_cCodFor) )
				@ li,00 PSay "Fornededor :" + SA2->A2_COD + "-" + SA2->A2_NOME
			EndIF
		Else
			@ li,00 PSay cLinhaSub
		EndIF

		nCol := 1
        li++
		For nX := 1 To 12
			@ li,nCol PSay aSub[nX] Picture PesqPictQt("B3_Q01",10)  
			nCol += 11
		Next nX

		@ li,nCol PSay aSub[13] PicTure PesqPictQt("B3_MEDIA",10)
		li += 2

	EndIf
    If li > 55
	    Roda(cbcont,cbtxt,Tamanho)
	EndIf    
	_cCodFor := ""

	For nX := 1 To Len(aTot)
		aTot[nX] += aSub[nX]
	Next nX

EndDo
If li != 80
	If aReturn[8] == 2 .Or. aReturn[8] == 4 .Or. aReturn[8] == 5
		@ li,00 PSay STR0028+Replicate(".",210)		//"Total geral"
		nCol := 1 
		li++
		For nX := 1 To 12
			@ li,nCol PSay aTot[nX] Picture PesqPictQt("B3_Q01",10)
			nCol += 11
		Next nX
		@ li,nCol PSay aTot[13] PicTure PesqPictQt("B3_MEDIA",10)
	EndIf
	li += 2
	Roda(cbcont,cbtxt,Tamanho)
EndIf

//ณ Devolve a condicao original do arquivo principal             ณ
dbSelectArea(cString)
Set Filter To
Set Order To 1
If aReturn[5] = 1
	Set Printer To
	dbCommitAll()
	OurSpool(wnrel)
Endif

MS_FLUSH()

Return(NIL) 
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณfQuery()  บAutor  ณJailton B Santos-JBSบ Data ณ 03/02/2010  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Busca a quantidade de entrega programada nas tabelas 'SCK' บฑฑ
ฑฑบ          ณ e 'SCJ' para o produto.                                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Especifico Faturamento - Dipromed.                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
///Static Function fQuery(_cProduto,_cTipoRel)
Static Function fQuery(_cProduto,_cTipoRel)

Local nRet   := 0
Local cQuery := ""
Local aArea  := GetArea()  
Default _cTipoRel = 'C'
//--------------------------------------------------------------
// Soma as quantidade de Entregas Programadas
//--------------------------------------------------------------
cQuery := " SELECT SUM(SCK.CK_QTDVEN) QTDVEN,SCK.CK_PRODUTO "
cQuery += "   FROM " + RetSqlName('SCK') + " SCK "
//--------------------------------------------------------------
// Amarra os Itens das atrengas programadas com as capas dos 
// pedidos no SCJ.
//--------------------------------------------------------------

If _cTipoRel = 'C' //Consolidado
	cQuery += "  INNER JOIN " + RetSqlName('SCJ') + " SCJ ON SCJ.CJ_FILIAL = '"+QRYSB1->B1_FILIAL+"' "
	cQuery += "                      AND SCJ.CJ_NUM = SCK.CK_NUM
	cQuery += "                      AND SCJ.CJ_OPCAO = 'P' 
	cQuery += "                      AND SCJ.D_E_L_E_T_ <> '*'  
	cQuery += "  WHERE CK_FILIAL = '"+QRYSB1->B1_FILIAL+"' "
Else
	cQuery += "  INNER JOIN " + RetSqlName('SCJ') + " SCJ ON SCJ.CJ_FILIAL = '"+xFilial('SCJ')+"' "
	cQuery += "                      AND SCJ.CJ_NUM = SCK.CK_NUM
	cQuery += "                      AND SCJ.CJ_OPCAO = 'P' 
	cQuery += "                      AND SCJ.D_E_L_E_T_ <> '*'  
	cQuery += "  WHERE CK_FILIAL = '"+xFilial('SCK')+"' "
Endif
//--------------------------------------------------------------
// Determina o produto a ser consultado
//--------------------------------------------------------------
cQuery += "    AND CK_PRODUTO = '" + _cProduto + "' " 
cQuery += "    AND SCK.D_E_L_E_T_ <> '*'  

cQuery += "  GROUP BY SCK.CK_PRODUTO "     

If Select('QRY') > 0
	QRY->( DbCloseArea() )          
EndIf

TcQuery cQuery New Alias "QRY"
TCSetField("QRY","QTDVEN"  ,"N",15,02) // Formata o Campo na View
//--------------------------------------------------------------
// Retorna a quantidade de entrega programada
//--------------------------------------------------------------
nRet := QRY->QTDVEN
//--------------------------------------------------------------
QRY->( DbCloseArea() )          
RestArea(aArea)
Return(nRet)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณUMATR340  บAutor  ณMicrosiga           บ Data ณ  09/01/14   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function C340ImpC(lEnd,aOrd,WnRel,cString,tamanho,titulo)
LOCAL aMeses	:= {STR0011,STR0012,STR0013,STR0014,STR0015,STR0016,STR0017,STR0018,STR0019,STR0020,STR0021,STR0022}	//"JAN"###"FEV"###"MAR"###"ABR"###"MAI"###"JUN"###"JUL"###"AGO"###"SET"###"OUT"###"NOV"###"DEZ"
LOCAL nX 		:= 0
LOCAL nAno  	:= 0 
LOCAL nMes 		:= 0 
LOCAL aSub[14] 
LOCAL aTot[14] 
LOCAL lPassou   := .F.
LOCAL nCol 		:= 0
LOCAL nMesAux	:= 0
LOCAL _cCodFor  := ""
LOCAL _nMedia   := 0  

Local nEstq     := 0  // Quantidade atual local 01 e 02
Local nAclass   := 0  // Quantidade a classificar nos locais 01 e 02
Local nReserva  := 0  // Quantidade reservada nos locais 01 e 02
Local nSalPedi  := 0  // Saldo em Pedido de Compras nos locais 01 e 02
Local _cProduto := "" // Quantidade do saldo Gy Log > RBORGES 08/02/2018 - Alterada para SALDO no 06 
Local nSalGl    := "" // Quantidade do saldo Gy Log > RBORGES 08/02/2018 - Alterada para SALDO no 06
Local nTotPrg	:= 0 // Total programado
Local cPctQEmb  := AvSx3('B1_XQE',6)   
Local cPctPrazo := AvSx3('A2_PRAZO',6)
Local lImprimiu := .F. 

PRIVATE cMes 	  := ""
PRIVATE cCondicao := "" 
PRIVATE lContinua := .T. 
PRIVATE cCondSec  := ""
PRIVATE cAnt 	  := ""

dbSelectArea("SB1")

cbtxt    := Space(10)
cbcont   := 0
li       := 80
m_pag    := 1

//ณ Inicializa os codigos de caracter Comprimido/Normal da impressora ณ
nTipo    := IIf(aReturn[4]==1,15,18)

//ณ Soma a ordem escolhida ao titulo do relatorio                ณ
If Type("NewHead")#"U"
	NewHead += " ("+AllTrim(aOrd[aReturn[8]])+' - Media de consumo dos ultimos '+StrZero(mv_par11,2)+' Meses'+IIF(mv_par12==1,"/Considera Mes Atual","/Nao Considera Mes Atual") +") "
Else
	Titulo  += " ("+AllTrim(aOrd[aReturn[8]])+' - Media de consumo dos ultimos '+StrZero(mv_par11,2)+' Meses'+IIF(mv_par12==1,"/Considera Mes Atual","/Nao Considera Mes Atual") +") "
EndIf

//ณ Montagem Dos Dados do cabecalho do relatorio                 ณ
nAno := Year(dDataBase)
If month(dDatabase) < 12
	nAno--
Endif
nMes := MONTH(dDataBase)+1
IF nMes = 13
	nMes := 1
Endif
cMes := StrZero(nMes,2)    

//         1234567890123456789012345678901234567890123456789012345678901234567890
//         0        1         2         3         4         5         6         7         8         9        10        11        12        13        14        15        16        17        18        19        20        21        22
//         01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
cabec1 := "CODIGO  DESCRICAO                                                        U.M.   QTD POR EMB   PRAZO ENTREGA    " //"TIPO PRAZO "
cabec2 := ""

FOR nX := 1 TO 12
	IF aMeses[nMes] == STR0011 .And. nX != 1	//"JAN"
		nAno++
	EndIF
	cabec2 += Space(3)+aMeses[nMes]+"/"+StrZero(nAno,4)
	nMes++
	IF nMes > 12
		nMes := 1
	ENDIF
NEXT nX
cabec2 += "      MEDIA  EST.ATUAL   RESERVAS  ENTR.PROG DISPONIVEL PED.COMPRA   SALDO_06        CQ"

IF aReturn[8] == 5
	cOrd := " ORDER BY B1_PROC, B1_DESC, B1_COD "
ElseIf aReturn[8] == 4
	cOrd := " ORDER BY B1_GRUPO, B1_COD "
ElseIf aReturn[8] == 3
	cOrd := " ORDER BY B1_DESC, B1_COD "
ElseIf aReturn[8] == 2
	cOrd := " ORDER BY B1_TIPO, B1_COD "
Else
	cOrd := " ORDER BY B1_COD "
EndIF

cSQL := " SELECT "
cSQL += "  B1_FILIAL, B1_COD, B1_DESC, B1_UM, B1_TIPO, B1_GRUPO, B1_PROC, B1_LOJPROC, B1_XQE  "
cSQL += " 	FROM "
cSQL += 		RetSQLName("SB1")
cSQL += " 		WHERE "
cSQL += " 			B1_FILIAL IN ('01','04') AND "
cSQL += " 			B1_COD BETWEEN   '"+MV_PAR01+"' AND '"+MV_PAR02+"' AND "
cSQL += " 			B1_TIPO BETWEEN  '"+MV_PAR03+"' AND '"+MV_PAR04+"' AND "
cSQL += " 			B1_GRUPO BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR06+"' AND "
cSQL += " 			LEFT(B1_DESC,"+StrZero(Len(AllTrim(MV_PAR07)),2)+") >=  '"+MV_PAR07+"' AND "
cSQL += "			LEFT(B1_DESC,"+StrZero(Len(AllTrim(MV_PAR08)),2)+") <=  '"+MV_PAR08+"' AND "
cSQL += " 			B1_PROC BETWEEN  '"+MV_PAR09+"' AND '"+MV_PAR10+"' AND "
cSQL += " 			D_E_L_E_T_ = ' ' "                                             
//cSQL += " GROUP BY B1_FILIAL, B1_COD, B1_DESC, B1_UM, B1_TIPO, B1_GRUPO, B1_PROC, B1_LOJPROC, B1_XQE "
//cSQL += cOrd
cSQL += " UNION "
cSQL += " SELECT "
cSQL += "  'C', B1_COD, B1_DESC, B1_UM, B1_TIPO, B1_GRUPO, B1_PROC, B1_LOJPROC, B1_XQE  "
cSQL += " 	FROM "
cSQL += 		RetSQLName("SB1")
cSQL += " 		WHERE "
cSQL += " 			B1_FILIAL = '01' AND "
cSQL += " 			B1_COD BETWEEN   '"+MV_PAR01+"' AND '"+MV_PAR02+"' AND "
cSQL += " 			B1_TIPO BETWEEN  '"+MV_PAR03+"' AND '"+MV_PAR04+"' AND "
cSQL += " 			B1_GRUPO BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR06+"' AND "
cSQL += " 			LEFT(B1_DESC,"+StrZero(Len(AllTrim(MV_PAR07)),2)+") >=  '"+MV_PAR07+"' AND "
cSQL += "			LEFT(B1_DESC,"+StrZero(Len(AllTrim(MV_PAR08)),2)+") <=  '"+MV_PAR08+"' AND "
cSQL += " 			B1_PROC BETWEEN  '"+MV_PAR09+"' AND '"+MV_PAR10+"' AND "
cSQL += " 			D_E_L_E_T_ = ' ' "                                             
cSQL += cOrd

cSQL := ChangeQuery(cSQL)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),"QRYSB1",.T.,.T.)

SetRegua(QRYSB1->(RecCount()))

While !QRYSB1->(Eof())

	If aReturn[8] == 2
	
		cAnt      := QRYSB1->B1_TIPO
		cCondSec  := "QRYSB1->B1_TIPO == cAnt"
		cLinhaSub := STR0025+cAnt+" .........."	//"Total do tipo "

	ElseIf aReturn[8] == 4

		cAnt      := QRYSB1->B1_GRUPO
		cCondSec  := "QRYSB1->B1_GRUPO == cAnt"
		cLinhaSub := STR0026+cAnt+" ......."		//"Total do grupo "

	ElseIf aReturn[8] == 5

		cAnt      := QRYSB1->B1_PROC
		cCondSec  := "QRYSB1->B1_PROC == cAnt"
		cLinhaSub := "Fornecedor: "+cAnt+" ......."		//"Total do fornecedor "

	Else
		cCondSec := ".T."
	EndIf
               
	AFILL(aSub,0)
	lPassou := .F.

	While !QRYSB1->(Eof()) .And. &cCondSec

		If lEnd
			@Prow()+1,001 PSay STR0027	//"CANCELADO PELO OPERADOR"
			lContinua := .F.
			Exit
		Endif

		IncRegua()

		If li > 55 
		    If lImprimiu
		        li := 60 
		        Roda(cbcont,cbtxt,Tamanho)
		    EndIf
			Cabec(titulo,cabec1,cabec2,wnrel,Tamanho,nTipo)
		EndIf

		lPassou := .T.
		
		//---------------------------------------------------------------------
        // Posiciona o fornecedor do Produto para Impressใo do Prazo de Entrega
		//---------------------------------------------------------------------
        SA2->( DbSetOrder(1) )                                             
        SA2->( DbSeek( xFilial('SA2') + QRYSB1->B1_PROC + QRYSB1->B1_LOJPROC) ) 
		//---------------------------------------------------------------------
		
		If QRYSB1->B1_FILIAL == '01'
		
		    @ li,000 PSay Alltrim(QRYSB1->B1_COD)
			@ li,008 PSay QRYSB1->B1_DESC                          
			@ li,073 PSay QRYSB1->B1_UM                            
			@ li,080 PSay QRYSB1->B1_XQE Picture cPctQEmb          
			@ li,097 PSay SA2->A2_PRAZO Picture cPctPrazo
			
			li++
		EndIf 
       
        lImprimiu:= .T.
				
		nCol    := 1
		nMesAux := nMes
		
		cSQL := " SELECT "
		cSQL += " 	SUM(B3_Q01) B3_Q01, SUM(B3_Q02) B3_Q02, SUM(B3_Q03) B3_Q03, "
		cSQL += " 	SUM(B3_Q04) B3_Q04, SUM(B3_Q05) B3_Q05, SUM(B3_Q06) B3_Q06, "
		cSQL += " 	SUM(B3_Q07) B3_Q07, SUM(B3_Q08) B3_Q08, SUM(B3_Q09) B3_Q09, "
		cSQL += " 	SUM(B3_Q10) B3_Q10, SUM(B3_Q11) B3_Q11, SUM(B3_Q12) B3_Q12 "
		cSQL += " 	FROM "
		cSQL +=  		RetSQLName("SB3")
		cSQL += " 		WHERE "
		If     QRYSB1->B1_FILIAL == '01'
			cSQL += " 			B3_FILIAL = '01' AND "
		ElseIf QRYSB1->B1_FILIAL == '04'
			cSQL += " 			B3_FILIAL = '04' AND "
		Else
			cSQL += " 			B3_FILIAL IN ('01','04') AND "			
		EndIf	
		cSQL += " 			B3_COD = '"+QRYSB1->B1_COD+"' AND "
		cSQL += " 			D_E_L_E_T_ = ' ' "

		cSQL := ChangeQuery(cSQL)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),"QRYSB3",.T.,.T.)
		
		If QRYSB3->(Eof())
			QRYSB3->(dbCloseArea())
			QRYSB1->(dbSkip())
			Loop			
		Else		
			For nX := 1 To 12
				
				If     QRYSB1->B1_FILIAL == '01'
					@ li,000 Psay "MTZ"
				ElseIf QRYSB1->B1_FILIAL == '04'
					@ li,000 Psay "CD "
				Else
					@ li,000 Psay "Tot "					
				EndIf	
				
				@ li,nCol PSay &("QRYSB3->B3_Q"+cMes) Picture PesqPictQt("B3_Q01",10)
				aSub[nX] += &("QRYSB3->B3_Q"+cMes)
				nMesAux++
			
				If nMesAux > 12
					nMesAux := 1
				EndIf
			
				cMes := StrZero(nMesAux,2)
				nCol += 11
			
			Next nX 
			
			_nMedia := DipCalMed(QRYSB1->B1_COD,mv_par11,(mv_par12==1))

			QRYSB3->(dbCloseArea())
			
		EndIf         
		
		dbSelectArea("SB3")
		
		@ li,nCol PSay _nMedia PicTure PesqPictQt("B3_MEDIA",10)
        
		SB2->( DbSetOrder(1) )

		nEstq    := 0
        nAclass  := 0
        nReserva := 0
        nSalPedi := 0
        nSalGl   := 0	
        nQtdCQ	 := 0
	
        nQtdCQ := u_DipSomaCQ(QRYSB1->B1_COD,QRYSB1->B1_PROC,QRYSB1->B1_LOJPROC,.T.)        
                                                     
        If DipSomaB2(QRYSB1->B1_FILIAL,QRYSB1->B1_COD,@nEstq,@nReserva,@nAClass,@nSalPedi)  
          
            // nSalGl    := DipPod3(QRYSB1->B1_COD) 
			nSalGl  := U_DIP8Poder3(QRYSB1->B1_COD,.T.)
			nTotPrg += fQuery(QRYSB1->B1_COD)
			dbSelectArea("SB3")
			
			@ li,nCol += 11 PSay nEstq    PicTure PesqPictQt("B3_MEDIA",10)
   		    @ li,nCol += 11 PSay nReserva PicTure PesqPictQt("B3_MEDIA",10) 
			If QRYSB1->B1_FILIAL $ "01,04"
		    	@ li,nCol += 11 PSay fQuery(QRYSB1->B1_COD)  PicTure PesqPictQt("B3_MEDIA",10) 
		    Else
		    	@ li,nCol += 11 PSay nTotPrg				 PicTure PesqPictQt("B3_MEDIA",10) 
				nTotPrg := 0
			Endif
			@ li,nCol += 11 PSay nEstq - nReserva - nAClass  PicTure PesqPictQt("B3_MEDIA",10) 
		    @ li,nCol += 11 PSay nSalPedi PicTure PesqPictQt("B3_MEDIA",10) 
		    @ li,nCol += 11 PSay nSalGl   PicTure PesqPictQt("B3_MEDIA",10)
   		    @ li,nCol += 11 PSay nQtdCQ   PicTure PesqPictQt("B3_MEDIA",10)
		Else
   		    @ li,nCol += 11 PSay 0 PicTure PesqPictQt("B3_MEDIA",10)  
		    @ li,nCol += 11 PSay 0 PicTure PesqPictQt("B3_MEDIA",10)  
		    @ li,nCol += 11 PSay 0 PicTure PesqPictQt("B3_MEDIA",10)  
		    @ li,nCol += 11 PSay 0 PicTure PesqPictQt("B3_MEDIA",10)   
			@ li,nCol += 11 PSay 0 PicTure PesqPictQt("B3_MEDIA",10)    
		    @ li,nCol += 11 PSay 0 PicTure PesqPictQt("B3_MEDIA",10)  			
   		    @ li,nCol += 11 PSay 0 PicTure PesqPictQt("B3_MEDIA",10)  		
		EndIF
		If QRYSB1->B1_FILIAL == '01' .Or. QRYSB1->B1_FILIAL =='04'
			li++
		Else
			li += 2
		EndIf
		aSub[13] += _nMedia
		_cCodFor := QRYSB1->B1_PROC
		
		QRYSB1->(DbSkip())
		
	EndDo

	If (aReturn[8] == 2 .Or. aReturn[8] == 4 .Or. aReturn[8] == 5) .And. lPassou

		li++

		IF aReturn[8] == 5
			SA2->(DbSetOrder(1))
			IF SA2->( DbSeek(xFilial("SA2")+_cCodFor) )
				@ li,00 PSay "Fornededor :" + SA2->A2_COD + "-" + SA2->A2_NOME
			EndIF
		Else
			@ li,00 PSay cLinhaSub
		EndIF

		nCol := 1
		li++
		For nX := 1 To 12
			@ li,nCol PSay aSub[nX] Picture PesqPictQt("B3_Q01",10)
			nCol += 11
		Next nX

		@ li,nCol PSay aSub[13] PicTure PesqPictQt("B3_MEDIA",10)

		li += 2

	EndIf
    If li > 55
	    Roda(cbcont,cbtxt,Tamanho)
	EndIf
	    
	_cCodFor := ""
	AFILL(aTot,0)
	
	For nX := 1 To Len(aTot)
		aTot[nX] += aSub[nX]
	Next nX
	
	If !lPassou
		QRYSB1->(dbSkip())
	EndIf
EndDo    
QRYSB1->(dbCloseArea())

If li != 80
	If aReturn[8] == 2 .Or. aReturn[8] == 4 .Or. aReturn[8] == 5
		@ li,00 PSay STR0028+Replicate(".",210)		//"Total geral"
		nCol := 1 
		li++
		For nX := 1 To 12
			@ li,nCol PSay aTot[nX] Picture PesqPictQt("B3_Q01",10)
			nCol += 11
		Next nX
		@ li,nCol PSay aTot[13] PicTure PesqPictQt("B3_MEDIA",10)
	EndIf
	li += 2
	Roda(cbcont,cbtxt,Tamanho)
EndIf

//ณ Devolve a condicao original do arquivo principal             ณ
dbSelectArea(cString)
Set Filter To
Set Order To 1
If aReturn[5] = 1
	Set Printer To
	dbCommitAll()
	OurSpool(wnrel)
Endif

MS_FLUSH()

Return(NIL)    
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณUMATR340  บAutor  ณMicrosiga           บ Data ณ  09/01/14   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function DipCalMed(_cProduto,_nMes,_lMesAtual)
Local _nMesIni := Month(dDataBase)
Local _nMedia  := 0              

For _nCont := 1 to _nMes
	
	If !_lMesAtual
		_nMesIni := _nMesIni - 1
	EndIf
	
	If _nMesIni == 0
		_nMesIni := 12
	EndIf
	
	_nMedia := _nMedia + &( "QRYSB3->B3_Q" + StrZero(_nMesIni,2) )
			
	If _lMesAtual
		_nMesIni := _nMesIni - 1
	EndIf
	
Next
_nMedia := Int(_nMedia / _nMes)

Return(_nMedia) 
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณUMATR340  บAutor  ณMicrosiga           บ Data ณ  09/03/14   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static function DipPod3(cProduto)
Local nSaldo	:= 0
Local cSQL 		:= ""

cSQL := " SELECT "
cSQL += "	SUM(B6_SALDO) SALDO "    
cSQL += " 	FROM "
cSQL += 		RetSQLName("SB6") 
cSQL += " 		WHERE 
cSQL += "			B6_FILIAL IN ('01','04') AND "
cSQL += " 			B6_PRODUTO  = '"+cProduto+"' AND "
//cSQL += " 			B6_LOCAL    = '06' AND "     
cSQL += " 			B6_PODER3   = 'R' AND "     
cSQL += " 			B6_CLIFOR   = '019181' AND "     
cSQL += " 			D_E_L_E_T_ = ' ' "   

cSQL := ChangeQuery(cSQL)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),"QRYSB6",.T.,.T.)

If !QRYSB6->(Eof())   
	nSaldo := QRYSB6->SALDO
EndIf 
QRYSB6->(dbCloseArea())

Return(nSaldo)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณUMATR340  บAutor  ณMicrosiga           บ Data ณ  09/03/14   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function DipSomaB2(_cFilial,cProduto,nEstq,nReserva,nAClass,nSalPedi,cTipo)
local lRet := .F.
Local cSQL := ""
DEFAULT cTipo := ""
DEFAULT _cFilial := ""


cSQL := " SELECT "
cSQL += "	SUM(B2_QATU) B2_QATU, SUM(B2_RESERVA) B2_RESERVA, SUM(B2_QACLASS) B2_QACLASS, SUM(B2_SALPEDI) B2_SALPEDI "
cSQL += "	FROM "
cSQL += 		RetSQLName("SB2")
cSQL += "		WHERE "
If cEmpAnt=="01"
	If Empty(_cFilial)
	cSQL += "		B2_FILIAL IN ('01','04') AND "
	Else
		If     _cFilial = "01"
			cSQL += "		B2_FILIAL = '01' AND "		
		ElseIf _cFilial = "04"
			cSQL += "		B2_FILIAL = '04' AND "		
		Else
			cSQL += "		B2_FILIAL IN ('01','04') AND "
		EndIf
	EndIf
Else
	cSQL += "		B2_FILIAL IN ('01','02') AND "
EndIf
If cEmpAnt=="04"
	If cTipo=="MP"
		cSQL += "	B2_LOCAL IN('01','03','05') AND "
	Else
		cSQL += "	B2_LOCAL IN('01','02') AND "
	EndIf
Else
	cSQL += "		B2_LOCAL = '01' AND "
EndIf
cSQL += "			B2_COD 	 = '"+cProduto+"' AND "
cSQL += "			D_E_L_E_T_ = ' ' "

cSQL := ChangeQuery(cSQL)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),"QRYSB2",.T.,.T.)

If !QRYSB2->(Eof())
	nEstq    += QRYSB2->B2_QATU
	nReserva += QRYSB2->B2_RESERVA
	nAClass  += QRYSB2->B2_QACLASS
	nSalPedi += QRYSB2->B2_SALPEDI
	lRet := .T.
EndIf
QRYSB2->(dbCloseArea())

Return lRet     
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณUMATR340  บAutor  ณMicrosiga           บ Data ณ  09/01/14   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function C340ImpH(lEnd,aOrd,WnRel,cString,tamanho,titulo)
LOCAL aMeses	:= {STR0011,STR0012,STR0013,STR0014,STR0015,STR0016,STR0017,STR0018,STR0019,STR0020,STR0021,STR0022}	//"JAN"###"FEV"###"MAR"###"ABR"###"MAI"###"JUN"###"JUL"###"AGO"###"SET"###"OUT"###"NOV"###"DEZ"
LOCAL nX 		:= 0
LOCAL nAno  	:= 0 
LOCAL nMes 		:= 0 
LOCAL aSub[14] 
LOCAL aTot[14] 
LOCAL lPassou   := .F.
LOCAL nCol 		:= 0
LOCAL nMesAux	:= 0
LOCAL _cCodFor  := ""
LOCAL _nMedia   := 0  

Local nEstq     := 0  // Quantidade atual local 01 e 02
Local nAclass   := 0  // Quantidade a classificar nos locais 01 e 02
Local nReserva  := 0  // Quantidade reservada nos locais 01 e 02
Local nSalPedi  := 0  // Saldo em Pedido de Compras nos locais 01 e 02
Local _cProduto := "" // Quantidade do saldo Gy Log
Local nSalGl    := "" // Quantidade do saldo Gy Log
Local cPctQEmb  := AvSx3('B1_XQE',6)   
Local cPctPrazo := AvSx3('A2_PRAZO',6)
Local lImprimiu := .F. 

Local cSelect1  := ""
Local cSelect2  := ""

PRIVATE cMes 	  := ""
PRIVATE cCondicao := "" 
PRIVATE lContinua := .T. 
PRIVATE cCondSec  := ""
PRIVATE cAnt 	  := ""

dbSelectArea("SB1")

cbtxt    := Space(10)
cbcont   := 0
li       := 80
m_pag    := 1

//ณ Inicializa os codigos de caracter Comprimido/Normal da impressora ณ
nTipo    := IIf(aReturn[4]==1,15,18)

//ณ Soma a ordem escolhida ao titulo do relatorio                ณ
If Type("NewHead")#"U"
	NewHead += " ("+AllTrim(aOrd[aReturn[8]])+' - Media de consumo dos ultimos '+StrZero(mv_par11,2)+' Meses'+IIF(mv_par12==1,"/Considera Mes Atual","/Nao Considera Mes Atual") +") "
Else
	Titulo  += " ("+AllTrim(aOrd[aReturn[8]])+' - Media de consumo dos ultimos '+StrZero(mv_par11,2)+' Meses'+IIF(mv_par12==1,"/Considera Mes Atual","/Nao Considera Mes Atual") +") "
EndIf

//ณ Montagem Dos Dados do cabecalho do relatorio                 ณ
nAno := Year(dDataBase)
If month(dDatabase) < 12
	nAno--
Endif
nMes := MONTH(dDataBase)+1
IF nMes = 13
	nMes := 1
Endif
cMes := StrZero(nMes,2)    

//         1234567890123456789012345678901234567890123456789012345678901234567890
//         0        1         2         3         4         5         6         7         8         9        10        11        12        13        14        15        16        17        18        19        20        21        22
//         01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
cabec1 := "CODIGO  DESCRICAO                                                        U.M.   QTD POR EMB   PRAZO ENTREGA    " //"TIPO PRAZO "
cabec2 := ""

FOR nX := 1 TO 12
	IF aMeses[nMes] == STR0011 .And. nX != 1	//"JAN"
		nAno++
	EndIF
	cabec2 += Space(3)+aMeses[nMes]+"/"+StrZero(nAno,4)
	nMes++
	IF nMes > 12
		nMes := 1
	ENDIF
NEXT nX
cabec2 += "      MEDIA  EST.ATUAL   RESERVAS  ENTR.PROG DISPONIVEL PED.COMPRA   SALDO_06        CQ"

IF aReturn[8] == 5
	cOrd := " ORDER BY B1_PROC, B1_DESC "
ElseIf aReturn[8] == 4
	cOrd := " ORDER BY B1_GRUPO, B1_COD "
ElseIf aReturn[8] == 3
	cOrd := " ORDER BY B1_DESC, B1_COD "
ElseIf aReturn[8] == 2
	cOrd := " ORDER BY B1_TIPO, B1_COD "
Else
	cOrd := " ORDER BY B1_COD "
EndIF

cSQL := " SELECT "
cSQL += " 	B1_COD, B1_DESC, B1_UM, B1_TIPO, B1_GRUPO, B1_PROC, B1_LOJPROC, B1_XQE  "
cSQL += " 	FROM "
cSQL += 		RetSQLName("SB1")
cSQL += " 		WHERE "
cSQL += " 			B1_FILIAL IN ('01','02') AND "
cSQL += " 			B1_COD BETWEEN   '"+MV_PAR01+"' AND '"+MV_PAR02+"' AND "
cSQL += " 			B1_TIPO BETWEEN  '"+MV_PAR03+"' AND '"+MV_PAR04+"' AND "
cSQL += " 			B1_GRUPO BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR06+"' AND "
cSQL += " 			LEFT(B1_DESC,"+StrZero(Len(AllTrim(MV_PAR07)),2)+") >=  '"+MV_PAR07+"' AND "
cSQL += "			LEFT(B1_DESC,"+StrZero(Len(AllTrim(MV_PAR08)),2)+") <=  '"+MV_PAR08+"' AND "
cSQL += " 			B1_PROC BETWEEN  '"+MV_PAR09+"' AND '"+MV_PAR10+"' AND "
cSQL += " 			D_E_L_E_T_ = ' ' "                                             
cSQL += " GROUP BY B1_COD, B1_DESC, B1_UM, B1_TIPO, B1_GRUPO, B1_PROC, B1_LOJPROC, B1_XQE "
cSQL += cOrd

cSQL := ChangeQuery(cSQL)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),"QRYSB1",.T.,.T.)

SetRegua(QRYSB1->(RecCount()))

While !QRYSB1->(Eof())

	If aReturn[8] == 2
	
		cAnt      := QRYSB1->B1_TIPO
		cCondSec  := "QRYSB1->B1_TIPO == cAnt"
		cLinhaSub := STR0025+cAnt+" .........."	//"Total do tipo "

	ElseIf aReturn[8] == 4

		cAnt      := QRYSB1->B1_GRUPO
		cCondSec  := "QRYSB1->B1_GRUPO == cAnt"
		cLinhaSub := STR0026+cAnt+" ......."		//"Total do grupo "

	ElseIf aReturn[8] == 5

		cAnt      := QRYSB1->B1_PROC
		cCondSec  := "QRYSB1->B1_PROC == cAnt"
		cLinhaSub := "Fornecedor: "+cAnt+" ......."		//"Total do fornecedor "

	Else
		cCondSec := ".T."
	EndIf
               
	AFILL(aSub,0)
	lPassou := .F.

	While !QRYSB1->(Eof()) .And. &cCondSec

		If lEnd
			@Prow()+1,001 PSay STR0027	//"CANCELADO PELO OPERADOR"
			lContinua := .F.
			Exit
		Endif

		IncRegua()

		If li > 55 
		    If lImprimiu
		        li := 60 
		        Roda(cbcont,cbtxt,Tamanho)
		    EndIf
			Cabec(titulo,cabec1,cabec2,wnrel,Tamanho,nTipo)
		EndIf

		lPassou := .T.
		//---------------------------------------------------------------------
        // Posiciona o fornecedor do Produto para Impressใo do Prazo de Entrega
		//---------------------------------------------------------------------
        SA2->( DbSetOrder(1) )                                             
        SA2->( DbSeek( xFilial('SA2') + QRYSB1->B1_PROC + QRYSB1->B1_LOJPROC) ) 
		//---------------------------------------------------------------------
		@ li,000 PSay Alltrim(QRYSB1->B1_COD)
		@ li,008 PSay QRYSB1->B1_DESC                          
		@ li,073 PSay QRYSB1->B1_UM                            
		@ li,080 PSay QRYSB1->B1_XQE Picture cPctQEmb          
		@ li,097 PSay SA2->A2_PRAZO Picture cPctPrazo 

        lImprimiu:= .T.
		li++
		
		nCol    := 1
		nMesAux := nMes      
		    
		
		If cEmpAnt=="04" 		
			If QRYSB1->B1_TIPO=="MP" .And. Year(dDataBase)==2017   
					
				If Empty(cSelect1+cSelect2)
					For nI := 1 to Month(dDataBase)
				   		cSelect1 += "B3_Q"+StrZero(nI,2)+", "
				   		cSelect2 += "0 B3_Q"+StrZero(nI,2)+", "
				 	Next nI                                     
				 	
				 	For nI := Month(dDataBase)+1 to 12
				 		cSelect1 += "0 B3_Q"+StrZero(nI,2)+", "
				   		cSelect2 += "B3_Q"+StrZero(nI,2)+", "
				 	Next nI
				EndIf
			 	
				cSQL := " SELECT "
				cSQL += " 	SUM(B3_Q01) B3_Q01, SUM(B3_Q02) B3_Q02, SUM(B3_Q03) B3_Q03, SUM(B3_Q04) B3_Q04, SUM(B3_Q05) B3_Q05, SUM(B3_Q06) B3_Q06, "
				cSQL += " 	SUM(B3_Q07) B3_Q07, SUM(B3_Q08) B3_Q08, SUM(B3_Q09) B3_Q09, SUM(B3_Q10) B3_Q10, SUM(B3_Q11) B3_Q11, SUM(B3_Q12) B3_Q12 "
				cSQL += " 	FROM "
				cSQL += " 		(SELECT "
				cSQL +=  			  SubStr(cSelect1,1,Len(cSelect1)-2)
				cSQL += " 			  FROM "
				cSQL +=  					RetSQLName("SB3")
				cSQL += " 					WHERE "
				cSQL += " 						  B3_FILIAL = '02' AND "
				cSQL += " 						  B3_COD = '"+QRYSB1->B1_COD+"' AND "
				cSQL += " 						  D_E_L_E_T_ = ' ' "
				cSQL += " 		UNION "
				cSQL += " 		SELECT "
				cSQL +=  			 SubStr(cSelect2,1,Len(cSelect2)-2)
				cSQL += " 			  FROM "
				cSQL +=  					RetSQLName("SB3")
				cSQL += " 					WHERE "                  
				cSQL += " 						  B3_FILIAL = '01' AND  "
				cSQL += " 						  B3_COD = '"+QRYSB1->B1_COD+"' AND  "
				cSQL += " 						  D_E_L_E_T_ = ' ') A "
				
				cSQL := ChangeQuery(cSQL)
				dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),"QRYSB3",.T.,.T.)				
			Else 
				cSQL := " SELECT "
				cSQL += " 	SUM(B3_Q01) B3_Q01, SUM(B3_Q02) B3_Q02, SUM(B3_Q03) B3_Q03, "
				cSQL += " 	SUM(B3_Q04) B3_Q04, SUM(B3_Q05) B3_Q05, SUM(B3_Q06) B3_Q06, "
				cSQL += " 	SUM(B3_Q07) B3_Q07, SUM(B3_Q08) B3_Q08, SUM(B3_Q09) B3_Q09, "
				cSQL += " 	SUM(B3_Q10) B3_Q10, SUM(B3_Q11) B3_Q11, SUM(B3_Q12) B3_Q12 "
				cSQL += " 	FROM "
				cSQL +=  		RetSQLName("SB3")
				cSQL += " 		WHERE "                            
				If QRYSB1->B1_TIPO=="MP"
					cSQL += "		B3_FILIAL = '02' AND "
				Else 
					cSQL += "		B3_FILIAL = '01' AND "
				EndIf
				cSQL += " 			B3_COD = '"+QRYSB1->B1_COD+"' AND "
				cSQL += " 			D_E_L_E_T_ = ' ' "
		
				cSQL := ChangeQuery(cSQL)
				dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),"QRYSB3",.T.,.T.)
			EndIf
		Else		 
			cSQL := " SELECT "
			cSQL += " 	SUM(B3_Q01) B3_Q01, SUM(B3_Q02) B3_Q02, SUM(B3_Q03) B3_Q03, "
			cSQL += " 	SUM(B3_Q04) B3_Q04, SUM(B3_Q05) B3_Q05, SUM(B3_Q06) B3_Q06, "
			cSQL += " 	SUM(B3_Q07) B3_Q07, SUM(B3_Q08) B3_Q08, SUM(B3_Q09) B3_Q09, "
			cSQL += " 	SUM(B3_Q10) B3_Q10, SUM(B3_Q11) B3_Q11, SUM(B3_Q12) B3_Q12 "
			cSQL += " 	FROM "
			cSQL +=  		RetSQLName("SB3")
			cSQL += " 		WHERE "
			cSQL += " 			B3_FILIAL IN ('01','04') AND "
			cSQL += " 			B3_COD = '"+QRYSB1->B1_COD+"' AND "
			cSQL += " 			D_E_L_E_T_ = ' ' "
	
			cSQL := ChangeQuery(cSQL)
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),"QRYSB3",.T.,.T.)
		EndIf   
		
		If QRYSB3->(Eof())
			QRYSB3->(dbCloseArea())
			QRYSB1->(dbSkip())
			Loop			
		Else		
			For nX := 1 To 12
			
				@ li,nCol PSay &("QRYSB3->B3_Q"+cMes) Picture PesqPictQt("B3_Q01",10)
				aSub[nX] += &("QRYSB3->B3_Q"+cMes)
				nMesAux++
			
				If nMesAux > 12
					nMesAux := 1
				EndIf
			
				cMes := StrZero(nMesAux,2)
				nCol += 11
			
			Next nX 
			
			_nMedia := DipCalMed(QRYSB1->B1_COD,mv_par11,(mv_par12==1))

			QRYSB3->(dbCloseArea())
			
		EndIf         
		
		dbSelectArea("SB3")
		
		@ li,nCol PSay _nMedia PicTure PesqPictQt("B3_MEDIA",10)
        
		SB2->( DbSetOrder(1) )

		nEstq    := 0
        nAclass  := 0
        nReserva := 0
        nSalPedi := 0
        nSalGl   := 0
        nQtdCQ	 := 0

        nQtdCQ := u_DipSomaCQ(QRYSB1->B1_COD,QRYSB1->B1_PROC,QRYSB1->B1_LOJPROC,.T.)        
                                                     
        If DipSomaB2(QRYSB1->B1_COD,@nEstq,@nReserva,@nAClass,@nSalPedi,QRYSB1->B1_TIPO)  
          
            // nSalGl    := DipPod3(QRYSB1->B1_COD) 
			nSalGl := U_DIP8Poder3(QRYSB1->B1_COD)
			dbSelectArea("SB3")
			
			@ li,nCol += 11 PSay nEstq    PicTure PesqPictQt("B3_MEDIA",10)
   		    @ li,nCol += 11 PSay nReserva PicTure PesqPictQt("B3_MEDIA",10) 
		    @ li,nCol += 11 PSay fQuery(QRYSB1->B1_COD) PicTure PesqPictQt("B3_MEDIA",10) 
		    @ li,nCol += 11 PSay nEstq - nReserva - nAClass  PicTure PesqPictQt("B3_MEDIA",10) 
		    @ li,nCol += 11 PSay nSalPedi PicTure PesqPictQt("B3_MEDIA",10) 
		    @ li,nCol += 11 PSay nSalGl   PicTure PesqPictQt("B3_MEDIA",10)
   		    @ li,nCol += 11 PSay nQtdCQ   PicTure PesqPictQt("B3_MEDIA",10)
		Else
   		    @ li,nCol += 11 PSay 0 PicTure PesqPictQt("B3_MEDIA",10)  
		    @ li,nCol += 11 PSay 0 PicTure PesqPictQt("B3_MEDIA",10)  
		    @ li,nCol += 11 PSay 0 PicTure PesqPictQt("B3_MEDIA",10)  
		    @ li,nCol += 11 PSay 0 PicTure PesqPictQt("B3_MEDIA",10)   
			@ li,nCol += 11 PSay 0 PicTure PesqPictQt("B3_MEDIA",10)    
		    @ li,nCol += 11 PSay 0 PicTure PesqPictQt("B3_MEDIA",10)  			
   		    @ li,nCol += 11 PSay 0 PicTure PesqPictQt("B3_MEDIA",10)  		
		EndIF

		li += 2
		aSub[13] += _nMedia
		_cCodFor := QRYSB1->B1_PROC
		
		QRYSB1->(DbSkip())
		
	EndDo

	If (aReturn[8] == 2 .Or. aReturn[8] == 4 .Or. aReturn[8] == 5) .And. lPassou

		li++

		IF aReturn[8] == 5
			SA2->(DbSetOrder(1))
			IF SA2->( DbSeek(xFilial("SA2")+_cCodFor) )
				@ li,00 PSay "Fornededor :" + SA2->A2_COD + "-" + SA2->A2_NOME
			EndIF
		Else
			@ li,00 PSay cLinhaSub
		EndIF

		nCol := 1
		li++
		For nX := 1 To 12
			@ li,nCol PSay aSub[nX] Picture PesqPictQt("B3_Q01",10)
			nCol += 11
		Next nX

		@ li,nCol PSay aSub[13] PicTure PesqPictQt("B3_MEDIA",10)
		li += 2

	EndIf
    If li > 55
	    Roda(cbcont,cbtxt,Tamanho)
	EndIf
	    
	_cCodFor := ""
	AFILL(aTot,0)
	
	For nX := 1 To Len(aTot)
		aTot[nX] += aSub[nX]
	Next nX
	
	If !lPassou
		QRYSB1->(dbSkip())
	EndIf
EndDo    
QRYSB1->(dbCloseArea())

If li != 80
	If aReturn[8] == 2 .Or. aReturn[8] == 4 .Or. aReturn[8] == 5
		@ li,00 PSay STR0028+Replicate(".",210)		//"Total geral"
		nCol := 1
		li++
		For nX := 1 To 12
			@ li,nCol PSay aTot[nX] Picture PesqPictQt("B3_Q01",10)
			nCol += 11
		Next nX
		@ li,nCol PSay aTot[13] PicTure PesqPictQt("B3_MEDIA",10)
	EndIf
	li += 2
	Roda(cbcont,cbtxt,Tamanho)
EndIf

//ณ Devolve a condicao original do arquivo principal             ณ
dbSelectArea(cString)
Set Filter To
Set Order To 1
If aReturn[5] = 1
	Set Printer To
	dbCommitAll()
	OurSpool(wnrel)
Endif

MS_FLUSH()

Return(NIL)    

/*====================================================================================\
|Programa  | UMATR440      | Autor | Eriberto Elias             | Data | 10/04/2002   |
|=====================================================================================|
|Descri็ใo | Lista os items que atingirao o ponto de pedido                           |
|          |                                                                          |
|          |                                                                          |
|=====================================================================================|
|Sintaxe   | UMATR440                                                                 |
|=====================================================================================|
|Uso       | Especifico DIPROMED                                                      |
|=====================================================================================|
|........................................Hist๓rico....................................|
|Rafael    | DD/MM/AA - Descri็ใo                                                     |
|Eriberto  | DD/MM/AA - Descri็ใo                                                     |
\====================================================================================*/

#include "rwmake.ch"
User Function UMATR440()

//ณ Define Variaveis                                              ณ
LOCAL wnrel
LOCAL Tamanho 
LOCAL cDesc1  
LOCAL cDesc2  
LOCAL cDesc3  

SetPrvt("TAMANHO,CDESC1,CDESC2,CDESC3,NOMEPROG,CSTRING")
SetPrvt("ARETURN,NLASTKEY,CPERG,TITULO,LI,M_PAG")
SetPrvt("WNREL,NQUANT,NSALDO,NNECES,NCNTIMPR,CRODATXT,nCntFOR")
SetPrvt("NTIPO,LIMITE,CBCONT,CLOCCQ,CABEC1,CABEC2")
SetPrvt("nvalfor,NVALTOT,NESTSEG,AQTDES,NX,NPRAZO,NTOLER")
SetPrvt("CTIPOVAL,DDATA,NVALUNIT,NVALOR,")
U_DIPPROC(ProcName(0),U_DipUsr()) // JBS 05/10/2005 - Gravando o nome do Programa no SZU
//ณ Define Variaveis                                             ณ
Tamanho  := "G"
cDesc1   := "Emite uma relacao com os itens em estoque que atingiram o Ponto de"
cDesc2   := "Pedido ,sugerimdo a quantidade a comprar."
cDesc3   := ""

//ณ Variaveis tipo Private padrao de todos os relatorios         ณ
PRIVATE nomeprog := "UMATR440"
PRIVATE cString  := "SB1"
PRIVATE aReturn  := { "Zebrado", 1,"Administracao", 1, 2, 1, "",1 }
PRIVATE nLastKey := 0            

// PRIVATE cPerg    := "UMR440"
// FPADR(cPerg, cArq, cCampo, cTipo)  - Para ajustar o tamanho das perguntas no SX1- uso generico
PRIVATE cPerg  	:= U_FPADR( "UMR440","SX1","SX1->X1_GRUPO"," " ) //Fun็ใo criada por Sandro em 19/11/09.

PRIVATE titulo   := "Itens em Ponto de Pedido"

//ณ Contadores de linha e pagina                                 ณ
PRIVATE li    := 80
PRIVATE m_pag := 1

//ณ Verifica as perguntas selecionadas                           ณ
//ณ Variaveis utilizadas para parametros                         ณ
//ณ mv_par01             // Fornecedor de                        ณ
//ณ mv_par02             // Fornecedor ate                       ณ
//ณ mv_par03   1         // Produto de                           ณ
//ณ mv_par04   2         // Produto ate                          ณ
//ณ mv_par05   3         // Grupo de                             ณ
//ณ mv_par06   4         // Grupo ate                            ณ
//ณ mv_par07   5         // Tipo de                              ณ
//ณ mv_par08   6         // Tipo ate                             ณ
//ณ mv_par09   7         // Local de                             ณ
//ณ mv_par10   8         // Local ate                            ณ
//ณ mv_par11   9         // Considera Necess Bruta   1 - Sim     ณ Pto Pedido
//ณ mv_par12   10        // Saldo Neg Considera      1 - Sim     ณ Lote Economico
//ณ mv_par13   11        // Considera C.Q.           1 - Sim     ณ
// 
//ณ Verifica as perguntas selecionadas                           ณ

AjustaSX1(cPerg)   

pergunte(cPerg,.f.)

//ณ Envia controle para a funcao SETPRINT                        ณ
wnrel:=SetPrint(cString,NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,"",.F.,Tamanho)
If nLastKey = 27
	Set Filter To
	Return
Endif
SetDefault(aReturn,cString)
If nLastKey = 27
	Set Filter To
	Return
Endif                    
If Aviso("Aten็ใo","Deseja imprimir o relat๓rio consolidado?",{"Sim","Nใo"},1) == 1
	Titulo   := "Itens em Ponto de Pedido - Consolidado"
	RptStatus({|lEnd| R440ImpC(@lEnd,tamanho,wnrel,cString)},Titulo)
Else 
	RptStatus({|lEnd| R440Imp(@lEnd,tamanho,wnrel,cString)},Titulo)
EndIf

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑณFun…o    ณ R440IMP  ณ Autor ณ Cristina M. Ogura     ณ Data ณ 09.11.95 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ Chamada do Relatorio                                       ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ MATR440		                                              ณฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function R440Imp(lEnd,tamanho,wnrel,cString)

LOCAL nQuant := nSaldo := nValUnit := nValor := nValFor := nValTot := cTipoVal := nPrazo := nSalPedi := 0
LOCAL nToler, nEstSeg, nNeces := 0
LOCAL nCntImpr := 0
Local nCntFOR := 0 
Local _nQtdSI  := 0
LOCAL cRodaTxt := "PRODUTO(S)"
LOCAL nTipo    := 0
LOCAL cabec1,cabec2,cabec3
LOCAL limite   := 162
LOCAL cbCont   := 0
LOCAL cLocCQ   := GetMV("MV_CQ")
Local dDataRela:= Iif(Empty(MV_PAR16),dDataBase,MV_PAR16)
Local cPicture := Left(PesqPictQt("B2_QATU",12),len(PesqPictQt("B2_QATU",12))-3)

nTipo  := IIF(aReturn[4]==1,15,18)
/*                                                                                                                                                                                                                                                           
cabec1 := "CODIGO  DESCRICAO                                                    TP GRP  UM      SALDO  " + fMesB3(dDataRela,3,.T.)+ " " + fMesB3(dDataRela,2,.T.)+ "  " + fMesB3(dDataRela,1,.T.)+ "    PONTO DE QUANTIDADE  QUANTIDADE VAL.ESTIM.  BASE  DATA DE    VLR UNIT   %     PRAZO DE"
cabec2 := "                                                                                DISPONIVEL       (03)      (02)       (01)      PEDIDO POR EMBAL.   A COMPRAR  DA COMPRA        REFEREE   DA COMPRA  IPI    ENTREGA"             
*/                                                                                                                                                                                                                                                           
cabec1 := "CODIGO  DESCRICAO                                                    UM   SALDO      SALDO PARA " + fMesB3(dDataRela,3,.T.)+ "  " + fMesB3(dDataRela,2,.T.)+ "  " + fMesB3(dDataRela,1,.T.)+"  " + fMesB3(dDataRela,0,.T.)+ "   PONTO DE QUANTIDADE  QUANTIDADE ICMS  DATA DE   VLR UNIT   %     PRZ ENT."//Giovani Zago 09/01/12
cabec2 := "                                                                        DISPONIVEL  ESTERILIZACAO   (-3)       (-2)       (-1)        (0)     PEDIDO  POR EMBAL.  A COMPRAR   ST   REFEREE  DA COMPRA  IPI    EM DIAS"                             
******     0         1         2         3         4         5         6         7         8         9        10        11        12        13        14        15        16 |       17        18        19        20        21
******     0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123

dbSelectArea("SB1")
SetRegua(RecCount())
DbOrderNickName("B1FORNDESC") // MCVN - corrigido devido a atualiza็ใo do R4 06/11/2007
Set SoftSeek On
dbSeek( xFilial('SB1')+mv_par01 )
Set SoftSeek Off
nRegSB1 := RECNO()
nValTot := 0
nValFor := 0
_nEtqDias := 0
While !Eof() .And. B1_FILIAL+B1_PROC <= xFilial('SB1')+mv_par02
	
 	
	If lEnd
		@PROW()+1,001 PSAY "CANCELADO PELO OPERADOR"
		Exit
	Endif
	

	
	IncRegua()
		 
	
	//ณ Filtra grupos e tipos nao selecionados e tambem se for MODณ
	If  B1_COD   < mv_par03 .Or. B1_COD   > mv_par04
		B1_GRUPO < mv_par05 .Or. B1_GRUPO > mv_par06 .Or.;
		B1_NAOIPP == "N" .Or.;
		B1_TIPO  < mv_par07 .Or. B1_TIPO  > mv_par08 .Or.;
		SubStr(B1_COD,1,3) == "MOD" .Or. B1_TIPO == "BN" .Or.;
		B1_CONTRAT == "S"
		dbSkip()
		nRegSB1 := RECNO()
		Loop
	EndIf
	DbSelectArea("SA2")
	DbSetOrder(1)
	DbSeek(xFilial("SA2")+SB1->B1_PROC)

	if SA2->A2_COMPRA < mv_par14 .OR. SA2->A2_COMPRA > mv_par15
		DbSelectArea("SB1")
		DbOrderNickName("B1FORNDESC") // MCVN - corrigido devido a atualiza็ใo do R4 06/11/2007
		DbGoto(nRegSB1)
		DbSkip()
		nRegSB1 := RECNO()
		Loop
	endif

	IF A2_NAOIPP == "N" 
		DbSelectArea("SB1")
		DbOrderNickName("B1FORNDESC") // MCVN - corrigido devido a atualiza็ใo do R4 06/11/2007
		DbGoto(nRegSB1)
		DbSkip()
		nRegSB1 := RECNO()
		Loop
	ENDIF
	//ณ Direciona para funcao que calcula o necessidade de compra ณ
	//ณ Calcula o saldo atual de todos os almoxarifados ณ
	dbSelectArea("SB2")
	dbSeek( xFilial("SB2")+SB1->B1_COD )
	While SB2->(!Eof()) .and. B2_FILIAL+B2_COD == xFilial("SB2")+SB1->B1_COD
		
		If (B2_LOCAL < mv_par09 .Or. B2_LOCAL > mv_par10)
			If !(mv_par13==1  .And. B2_LOCAL == cLocCQ)			
				dbSkip()
				Loop  			
			EndIf 
		EndIf
		
		//ณ inclui os produtos que estao no C.Q.      ณ
		If B2_LOCAL == cLocCQ .And. mv_par13 == 2
			dbSkip()
			Loop
		Endif
		
		If cEmpAnt == '04'
			nSaldo += ((B2_QATU - B2_RESERVA)-B2_QPEDVEN) //(SaldoSB2()+B2_SALPEDI)-B2_QPEDVEN
		Else
			nSaldo += ((B2_QATU - B2_RESERVA)+B2_SALPEDI)-B2_QPEDVEN //(SaldoSB2()+B2_SALPEDI)-B2_QPEDVEN		
		EndIf	
		
		nSalPedi += B2_SALPEDI 
		dbSkip()
	EndDo
	nEstSeg := CalcEstSeg( SB1->B1_ESTFOR )
	nSaldo -= nEstSeg
	If (Round(nSaldo,4) #0) .Or. (mv_par11 == 1)
		Do Case
			Case ( SB1->B1_EMIN != 0 .And. MV_PAR11 == 1 )
				nNeces := If((nSaldo < 0),Abs(nSaldo)+SB1->B1_EMIN,(SB1->B1_EMIN-nSaldo))
			Case ( SB1->B1_EMIN != 0 .And. MV_PAR11 == 2 )
				nNeces := If((nSaldo < 0),Abs(nSaldo),(SB1->B1_EMIN-nSaldo))
			Case ( SB1->B1_LE != 0 .And. (nSaldo < 0  .or. mv_par11 == 2) )
				If ( MV_PAR11 == 2 .And. nSaldo < 0 )
					nNeces := Abs(nSaldo)+SB1->B1_LE
				Else
					nNeces := If( Abs(nSaldo)<SB1->B1_LE,SB1->B1_LE,if(nSaldo<0,Abs(nSaldo),0))
				EndIf
			OtherWise
				nNeces := IF(MV_PAR11 == 1,IIf(nSaldo<0,Abs(nSaldo),0),0)
		EndCase
	Else
		If SB1->B1_EMIN != 0
			nNeces := ( SB1->B1_EMIN )
		Else
			nNeces := 0
		Endif
	EndIf
	If nNeces > 0
		
		//ณ Verifica se o produto tem estrutura                       ณ
		dbSelectArea("SG1")
		If dbSeek( xFilial("SG1")+SB1->B1_COD )
			aQtdes := CalcLote(SB1->B1_COD,nNeces,"F")
		Else
			aQtdes := CalcLote(SB1->B1_COD,nNeces,"C")
		Endif
		For nX := 1 to Len(aQtdes)
			nQuant += aQtdes[nX]
		Next
	EndIf
	dbSelectArea("SB1")   
	
    If Substr(SB1->B1_COD,1,1) == "8"
    	_nQtdSI := U_SalEsPCP(SB1->B1_COD) 
	EndIf	
	
	If ((nQuant > 0 .And. Substr(SB1->B1_COD,1,1) <> "8") .Or. (_nQtdSI > 0)) 
		
		//ณ Pega o prazo de entrega do material         ณ
		nPrazo := CalcPrazo(SB1->B1_COD,nQuant)
		dbSelectArea("SB1")
		
		//ณ Calcula a tolerancia do item                ณ
		nToler   := (B1_LE * B1_TOLER)/100
		If li > 55
			Cabec(titulo,cabec1,cabec2,nomeprog,Tamanho,nTipo)
		EndIf
		
		//ณ Adiciona 1 ao contador de registros impressos         ณ
		nCntImpr++
		
		//ณ Verifica qual dos precos e' mais recente servir de base ณ
		If B1_UCOM < B1_DATREF
			cTipoVal := "STD"
			dData    := B1_DATREF
			nValUnit := B1_CUSTD
		Else
			cTipoVal := "U.CO"
			dData    := B1_UCOM
            //nValUnit := B1_UPRC+(B1_UPRC*B1_IPI/100)
			//nValUnit := B1_CUSDIP
			//nValUnit := B1_LISFOR // MCVN - 26/03/2009
			nValUnit := B1_CUSDIP   // MCVN - 02/04/2009
		EndIf
		//nValor    := nQuant * nValUnit                       '
        
        SB3->( DbSetOrder(1) )
        SB3->( DbSeek(xFilial("SB3")+SB1->B1_COD)) 
        
        If Substr(SB1->B1_COD,1,1) <> "8"
      		_nQtdSI := U_SalEstHQ(SB1->B1_COD)   		
  		EndIf

		_nQuant := (Round(nQuant/B1_XQE,0)*B1_XQE)
		_nQuant := IIF(_nQuant<nQuant,_nQuant+B1_XQE,_nQuant)
		nValor    := _nQuant * nValUnit
		
		_nEtqDias := B1_ETQDIAS    
		
		@ li,000 PSAY SubStr(B1_COD,1,6)
		@ li,Pcol()+2 PSAY SubStr(B1_DESC,1,60)
		//@ li,Pcol()+1 PSAY B1_TIPO
		//@ li,Pcol()+1 PSAY B1_GRUPO
		@ li,Pcol()+1 PSAY B1_UM
		@ li,Pcol()+2 PSAY nSaldo    Picture cPicture 
		@ li,Pcol()+2 PSAY _nQtdSI   Picture cPicture
		@ li,Pcol()+2 PSAY fMesB3(dDataRela,3,.F.) Picture cPicture
		@ li,Pcol()+2 PSAY fMesB3(dDataRela,2,.F.) Picture cPicture
		@ li,Pcol()+2 PSAY fMesB3(dDataRela,1,.F.) Picture cPicture
		@ li,Pcol()+2 PSAY fMesB3(dDataRela,0,.F.) Picture cPicture
		@ li,Pcol()+2 PSAY B1_EMIN   Picture cPicture
		@ li,Pcol()+2 PSAY B1_XQE     Picture cPicture
		@ li,Pcol()+3 PSAY _nQuant Picture cPicture
//		@ li,Pcol()+2 PSAY nValor    Picture cPicture
		@ li,Pcol()+3 PSAY B1_LOTEDIP //Giovani Zago 09/01/12 cTipoVal
		@ li,Pcol()+2 PSAY dData
		@ li,Pcol()+2 PSAY nValUnit  Picture "@e 999999.99"//cPicture
		@ li,Pcol()+2 PSAY B1_IPI    Picture "99"
		@ li,Pcol()+2 PSAY nPrazo    Picture "99999"
		//@ li,Pcol()+2 PSAY "Dia(s)"    
			 
		_nQtdSI := 0
		nValFor += nValor
		nValTot += nValor
		li++
		
		nCntFOR++
	Endif
	nSaldo := 0
	nQuant := 0
	dbSelectArea("SA2")
	dbSeek(xFilial("SA2")+SB1->B1_PROC)
	dbSelectArea("SB1")
	DbOrderNickName("B1FORNDESC") // MCVN - corrigido devido a atualiza็ใo do R4 06/11/2007
	dbGoto(nRegSB1)
	dbSkip()
	nRegSB1 := RECNO()
	
	If Eof() .or. B1_FILIAL+B1_PROC > xFilial('SB1')+mv_par02 .or. ;
		(SB1->B1_PROC != SA2->A2_COD) // Eriberto 17/08/06 .and. nValFor > 0)
        
   		If nCntFOR > 0
			
			Li++       
			@ li,000 PSAY "Total a comprar de "+SA2->A2_COD+'-'+SA2->A2_NOME+Space(10)+"Contato: "+SA2->A2_CONTATO+;
			         Space(4)+"Estoque para Qtde. Dias: "+StrZero(_nEtqDias,2)
			@ li,143 PSAY nValFor Picture TM(nValFor,16)
			
			nValFor := 0
			Li++         
        	@ li,000 PSAY Space(20)+"Telefone: "+SA2->A2_TEL+"  Fax: "+SA2->A2_FAX+"  Cond.Pagto.: "+;
    	             IIF(!Empty(SA2->A2_COND),GetAdvFVal("SE4","E4_DESCRI",xFilial("SE4")+SA2->A2_COND,1),Space(25))
			Li++                                                                                                    
			@ li,000 PSAY Replicate("-",220)
			Li++
			nCntFOR := 0
		EndIf
	EndIf
EndDo
If li != 80
	Li++
	@ li,000 PSAY "TOTAL GERAL A COMPRAR"+Replicate(".",134)
	@ li,156 PSAY nValTot Picture TM(nValTot,16)
	Roda(nCntImpr,cRodaTxt,Tamanho)
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

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบFuno    ณVALIDPERG บ Autor ณ AP5 IDE            บ Data ณ  08/01/02   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Verifica a existencia das perguntas criando-as caso seja   บฑฑ
ฑฑบ          ณ necessario (caso nao existam).                             บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function AjustaSX1(cPerg)

Local _sAlias := Alias()                              
Local aRegs := {}
Local i,j
dbSelectArea("SX1")
dbSetOrder(1)

aAdd(aRegs,{cPerg,"01","Fornecedor de      ?","","","mv_ch1","C",06,0,0,"G","","mv_par01","","",""," ","","","","","","","","","","","","","","","","","","","","","SA2",""})
aAdd(aRegs,{cPerg,"02","Fornecedor ate     ?","","","mv_ch2","C",06,0,0,"G","","mv_par02","","","","Z","","","","","","","","","","","","","","","","","","","","","SA2",""})
aAdd(aRegs,{cPerg,"03","Produto de         ?","","","mv_ch3","C",15,0,0,"G","","mv_par03","","",""," ","","","","","","","","","","","","","","","","","","","","","SB1",""})
aAdd(aRegs,{cPerg,"04","Produto ate        ?","","","mv_ch4","C",15,0,0,"G","","mv_par04","","","","Z","","","","","","","","","","","","","","","","","","","","","SB1",""})
aAdd(aRegs,{cPerg,"05","Grupo de           ?","","","mv_ch5","C",04,0,0,"G","","mv_par05","","",""," ","","","","","","","","","","","","","","","","","","","","","SBM",""})
aAdd(aRegs,{cPerg,"06","Grupo ate          ?","","","mv_ch6","C",04,0,0,"G","","mv_par06","","","","Z","","","","","","","","","","","","","","","","","","","","","SBM",""})
aAdd(aRegs,{cPerg,"07","Tipo de            ?","","","mv_ch7","C",02,0,0,"G","","mv_par07","","",""," ","","","","","","","","","","","","","","","","","","","","","02",""})
aAdd(aRegs,{cPerg,"08","Tipo ate           ?","","","mv_ch8","C",02,0,0,"G","","mv_par08","","","","Z","","","","","","","","","","","","","","","","","","","","","02",""})
aAdd(aRegs,{cPerg,"09","Local de           ?","","","mv_ch9","C",02,0,0,"G","","mv_par09","","",""," ","","","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"10","Local ate          ?","","","mv_cha","C",02,0,0,"G","","mv_par10","","","","Z","","","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"11","Consid.Necess.Bruta?","","","mv_chb","N",01,0,1,"C","","mv_par11","Sim","","","","","Nao","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"12","Saldo Neg Considera?","","","mv_chc","N",01,0,1,"C","","mv_par12","Saldo","","","","","Saldo+LE","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"13","Considera C.Q.     ?","","","mv_chd","N",01,0,2,"C","","mv_par13","Sim","","","","","Nao","","","","","","","","","","","","","","","","","","","",""})
AADD(aRegs,{cPerg,"14","Do Comprador       ?","","","mv_che","C",03,0,0,"G","","mv_par14","","","","","","","","","","","","","","SY1"})
AADD(aRegs,{cPerg,"15","Ate o Comprador    ?","","","mv_chf","C",03,0,0,"G","","mv_par15","","","","","","","","","","","","","","SY1"})
AADD(aRegs,{cPerg,"16","Data Base          ?","","","mv_chg","D", 8,0,0,"G","","mv_par16","","","","","","","","","","","","","",""})


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
DbSelectArea(_sAlias)

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณfMesB3()  บAutor  ณJailton B Santos-JBSบ Data ณ  21/05/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ  Retorna a quantidade da data atual menos quantidade de    บฑฑ
ฑฑบ          ณ  meses.                                                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Especifico Camporas Dipromed                              บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function fMesB3(dData,nMes,lDesc) 
Local nMesB3 := Month(dData) - nMes
Local cMes   := ''
Local aMeses
Local aMeses   := {'JANEIRO','FEVEREIRO','MARวO','ABRIL','MAIO','JUNHO','JULHO','AGOSTO','SETEMBRO','OUTUBRO','NOVEMBRO','DEZEMBRO'}
 
If nMesB3 < 1
   nMesB3 := 12 - abs(nMesB3) 
EndIf    

If !lDesc
    cMes := &('SB3->B3_Q' + StrZero(nMesB3,2))
Else
    cMes := Padl(aMeses[nMesB3],9)
EndIf                 

Return(cMes)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑณFun…o    ณ R440IMP  ณ Autor ณ Cristina M. Ogura     ณ Data ณ 09.11.95 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ Chamada do Relatorio                                       ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ MATR440		                                              ณฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function R440ImpC(lEnd,tamanho,wnrel,cString)
Local nQuant 	:= 0
Local nSaldo 	:= 0
Local nValUnit 	:= 0
Local nValor 	:= 0
Local nValFor 	:= 0
Local nValTot 	:= 0
Local cTipoVal 	:= 0
Local nPrazo 	:= 0
Local nToler 	:= 0
Local nEstSeg	:= 0
Local nNeces 	:= 0
Local nCntImpr 	:= 0
Local nCntFOR 	:= 0 
Local cRodaTxt 	:= "PRODUTO(S)"
Local nTipo    	:= 0
Local cabec1	:= ""
Local cabec2	:= ""
Local cabec3	:= ""
Local limite   	:= 162
Local cbCont   	:= 0
Local cLocCQ   	:= GetMV("MV_CQ")
Local dDataRela	:= Iif(Empty(MV_PAR16),dDataBase,MV_PAR16)
Local cPicture 	:= Left(PesqPictQt("B2_QATU",12),len(PesqPictQt("B2_QATU",12))-3)
Local nValTot  	:= 0
Local nValFor  	:= 0
Local _nEtqDias	:= 0
Local _nQtdSI   := 0
Private titulo  := "Itens em Ponto de Pedido - Consolidado"

nTipo  := IIF(aReturn[4]==1,15,18)
/*                                                                                                                                                                                                                                                           
cabec1 := "CODIGO  DESCRICAO                                                    TP GRP  UM      SALDO  " + fMesB3(dDataRela,3,.T.)+ " " + fMesB3(dDataRela,2,.T.)+ "  " + fMesB3(dDataRela,1,.T.)+ "    PONTO DE QUANTIDADE  QUANTIDADE VAL.ESTIM.  BASE  DATA DE    VLR UNIT   %     PRAZO DE"
cabec2 := "                                                                                DISPONIVEL       (03)      (02)       (01)      PEDIDO POR EMBAL.   A COMPRAR  DA COMPRA        REFEREE   DA COMPRA  IPI    ENTREGA"             
*/                                                                                                                     
If cEmpAnt=="01"
	cabec1 := "CODIGO  DESCRICAO                                                    UM      SALDO  " + DipMesB3(nil,dDataRela,3,.T.)+ "  " + DipMesB3(nil,dDataRela,2,.T.)+ "  " + DipMesB3(nil,dDataRela,1,.T.)+"  " + DipMesB3(nil,dDataRela,0,.T.)+ "   PONTO DE QUANTIDADE  QUANTIDADE ICMS  DATA DE    VLR UNIT   %     PRZ ENT."//Giovani Zago 09/01/12
	cabec2 := "                                                                        DISPONIVEL       (-3)       (-2)       (-1)        (0)     PEDIDO POR EMBAL.   A COMPRAR  DA COMPRA   ST   REFEREE   IPI    EM DIAS"             
Else 
	cabec1 := "CODIGO  DESCRICAO                                                    UM   SALDO      SALDO PARA " + fMesB3(dDataRela,3,.T.)+ "  " + fMesB3(dDataRela,2,.T.)+ "  " + fMesB3(dDataRela,1,.T.)+"  " + fMesB3(dDataRela,0,.T.)+ "   PONTO DE QUANTIDADE  QUANTIDADE ICMS  DATA DE   VLR UNIT   %     PRZ ENT."//Giovani Zago 09/01/12
	cabec2 := "                                                                        DISPONIVEL  ESTERILIZACAO   (-3)       (-2)       (-1)        (0)     PEDIDO  POR EMBAL.  A COMPRAR   ST   REFEREE  DA COMPRA  IPI    EM DIAS"
EndIf
	******     0         1         2         3         4         5         6         7         8         9        10        11        12        13        14        15        16        17        18        19        20        21
	******     0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123
	
cSQL := " SELECT "
cSQL += " 	B1_COD, B1_PROC, B1_ESTFOR, SUM(B1_EMIN) B1_EMIN, B1_LE, B1_TOLER, B1_DESC, B1_IPI, "
cSQL += "	B1_XQE, B1_UM, B1_LOTEDIP, B1_TIPO, B1_ETQDIAS "
cSQL += " 	FROM "
cSQL += 		RetSQLName("SB1")
cSQL += " 		WHERE "            
If cEmpAnt=="01"
	cSQL += " 			B1_FILIAL IN ('01','04') AND "
Else 
	cSQL += " 			B1_FILIAL IN ('01','02') AND "	
EndIf
cSQL += " 			B1_PROC BETWEEN  '"+MV_PAR01+"' AND '"+MV_PAR02+"' AND "
cSQL += " 			B1_COD BETWEEN   '"+MV_PAR03+"' AND '"+MV_PAR04+"' AND "
cSQL += " 			B1_GRUPO BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR06+"' AND "
cSQL += " 			B1_TIPO BETWEEN  '"+MV_PAR07+"' AND '"+MV_PAR08+"' AND "
cSQL += "			B1_NAOIPP <> 'N' AND "
cSQL += "			B1_CONTRAT <> 'S' AND "    
If cEmpAnt <> "04"
	cSQL += "			B1_TIPO <> 'BN' AND " 
EndIf
cSQL += "			LEFT(B1_COD,3) <> 'MOD' AND " 
cSQL += " 			D_E_L_E_T_ = ' ' "                                             
cSQL += " GROUP BY B1_COD, B1_PROC, B1_ESTFOR, B1_LE, B1_TOLER, B1_DESC, B1_IPI, "
cSQL += "		   B1_XQE, B1_UM , B1_LOTEDIP, B1_TIPO,B1_ETQDIAS "
cSQL += " ORDER BY B1_PROC, B1_DESC "

cSQL := ChangeQuery(cSQL)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),"QRYSB1",.T.,.T.)     

SetRegua(QRYSB1->(RecCount()))

While !QRYSB1->(Eof())
	
	If lEnd
		@PROW()+1,001 PSAY "CANCELADO PELO OPERADOR"
		Exit
	Endif
	
	IncRegua()	

	SA2->(DbSetOrder(1))
	If SA2->(dbSeek(xFilial("SA2")+QRYSB1->B1_PROC))	
		If SA2->A2_COMPRA < mv_par14 .OR. SA2->A2_COMPRA > mv_par15 .Or. SA2->A2_NAOIPP == "N" 
			QRYSB1->(dbSkip())
			Loop			
		EndIf		          
	Else
		QRYSB1->(dbSkip())
		Loop			
	EndIf
	
	nSaldo := DipCalSld(QRYSB1->B1_COD,MV_PAR09,MV_PAR10,cLocCQ,MV_PAR13)

	nEstSeg := CalcEstSeg(QRYSB1->B1_ESTFOR)
	
	If QRYSB1->B1_TIPO <> "BN"
		nSaldo  -= nEstSeg    
	EndIf
	
	If nSaldo > 0 .Or. mv_par11==1	
		Do Case
			Case QRYSB1->B1_EMIN <> 0 .And. MV_PAR11 == 1
				If nSaldo < 0			
					nNeces := Abs(nSaldo)+QRYSB1->B1_EMIN
				Else 
					nNeces := QRYSB1->B1_EMIN-nSaldo
				EndIf					
			Case QRYSB1->B1_EMIN <> 0 .And. MV_PAR11 == 2
				If nSaldo < 0			
					nNeces := Abs(nSaldo)
				Else 
					nNeces := QRYSB1->B1_EMIN-nSaldo
				EndIf								
			Case (QRYSB1->B1_LE <> 0 .And. (nSaldo < 0 .Or. mv_par11 == 2))			
				If MV_PAR11 == 2 .And. nSaldo < 0
					nNeces := Abs(nSaldo)+SB1->B1_LE
				Else
					nNeces := If( Abs(nSaldo)<QRYSB1->B1_LE,QRYSB1->B1_LE,if(nSaldo<0,Abs(nSaldo),0))
				EndIf
			OtherWise
				If MV_PAR11==1 .And. nSaldo < 0
					nNeces := Abs(nSaldo)
				Else                     
					nNeces := 0
				EndIf
		End Case
	Else
		If QRYSB1->B1_EMIN > 0
			nNeces := QRYSB1->B1_EMIN
		Else
			nNeces := 0
		Endif
	EndIf

	If nNeces > 0
		//ณ Verifica se o produto tem estrutura                       ณ
		dbSelectArea("SG1")
		If dbSeek( xFilial("SG1")+QRYSB1->B1_COD )
			aQtdes := CalcLote(QRYSB1->B1_COD,nNeces,"F")
		Else
			aQtdes := CalcLote(QRYSB1->B1_COD,nNeces,"C")
		Endif
		For nX := 1 to Len(aQtdes)
			nQuant += aQtdes[nX]
		Next
	EndIf                          
	
	If cEmpAnt=="04" .And. Substr(QRYSB1->B1_COD,1,1) == "8"
    	_nQtdSI := U_SalEsPCP(QRYSB1->B1_COD,.T.) 
	EndIf	
	
	If cEmpAnt=="04" .And. Substr(QRYSB1->B1_COD,1,1) <> "8"
    	_nQtdSI := U_SalEstHQ(QRYSB1->B1_COD,.T.)   		
  	EndIf
		
	If ((nQuant > 0 .And. Substr(QRYSB1->B1_COD,1,1) <> "8") .Or.(_nQtdSI > 0))
		//ณ Pega o prazo de entrega do material         ณ
		nPrazo := CalcPrazo(QRYSB1->B1_COD,nQuant)
		
		//ณ Calcula a tolerancia do item                ณ
		nToler   := (QRYSB1->B1_LE * QRYSB1->B1_TOLER)/100
		If li > 55
			Cabec(titulo,cabec1,cabec2,nomeprog,Tamanho,nTipo)
		EndIf
		
		//ณ Adiciona 1 ao contador de registros impressos         ณ
		nCntImpr++
		
		//ณ Verifica qual dos precos e' mais recente servir de base ณ
		dData    := U_DipRetDat(QRYSB1->B1_COD)
			
        SB3->( DbSetOrder(1) )
        SB3->( DbSeek(xFilial("SB3")+QRYSB1->B1_COD))
        
		_nQuant := (Round(nQuant/QRYSB1->B1_XQE,0)*QRYSB1->B1_XQE)
		_nQuant := IIF(_nQuant<nQuant,_nQuant+QRYSB1->B1_XQE,_nQuant)
		
	   //	If QRYSB1->B1_UCOM < QRYSB1->B1_DATREF
	  //		nValUnit := QRYSB1->B1_CUSTD
	  //	Else
			nValUnit := Posicione("SB1",1,xFilial("SB1")+QRYSB1->B1_COD,"B1_CUSDIP")
	  //	EndIf		
		
		nValor    := _nQuant * nValUnit
		
		_nEtqDias := QRYSB1->B1_ETQDIAS    
		
		@ li,000 PSAY SubStr(QRYSB1->B1_COD,1,6)
		@ li,Pcol()+2 PSAY SubStr(QRYSB1->B1_DESC,1,60)
		@ li,Pcol()+1 PSAY QRYSB1->B1_UM
		@ li,Pcol()+2 PSAY nSaldo    Picture cPicture  
		If cEmpAnt=="04"
			@ li,Pcol()+2 PSAY _nQtdSI   Picture cPicture
		EndIf
		@ li,Pcol()+2 PSAY DipMesB3(QRYSB1->B1_COD,dDataRela,3,.F.) Picture cPicture
		@ li,Pcol()+2 PSAY DipMesB3(QRYSB1->B1_COD,dDataRela,2,.F.) Picture cPicture
		@ li,Pcol()+2 PSAY DipMesB3(QRYSB1->B1_COD,dDataRela,1,.F.) Picture cPicture
		@ li,Pcol()+2 PSAY DipMesB3(QRYSB1->B1_COD,dDataRela,0,.F.) Picture cPicture
		@ li,Pcol()+2 PSAY QRYSB1->B1_EMIN   Picture cPicture
		@ li,Pcol()+2 PSAY QRYSB1->B1_XQE     Picture cPicture
		@ li,Pcol()+3 PSAY _nQuant   Picture cPicture
//		@ li,Pcol()+2 PSAY nValor    Picture cPicture
		@ li,Pcol()+3 PSAY QRYSB1->B1_LOTEDIP
		@ li,Pcol()+2 PSAY DtoC(dData)
		@ li,Pcol()+2 PSAY nValUnit  Picture "@e 999999.99"
		@ li,Pcol()+2 PSAY QRYSB1->B1_IPI    Picture "99"
		@ li,Pcol()+2 PSAY nPrazo    Picture "99999" 
		
		nValFor += nValor
		nValTot += nValor
		li++
		
		nCntFOR++
	Endif
	
	nSaldo := 0
	nQuant := 0
	_nQtdSI := 0
	
	QRYSB1->(dbSkip())
	
	If QRYSB1->B1_PROC <> SA2->A2_COD	
   		If nCntFOR > 0

			Li++                          
			@ li,000 PSAY "Total a comprar de "+SA2->A2_COD+'-'+SA2->A2_NOME+Space(10)+"Contato: "+SA2->A2_CONTATO+;
			         Space(4)+"Estoque para Qtde. Dias: "+StrZero(_nEtqDias,2)
			@ li,143 PSAY nValFor Picture TM(nValFor,16)			
			
			nValFor := 0
			Li++        
        	@ li,000 PSAY Space(20)+"Telefone: "+SA2->A2_TEL+"  Fax: "+SA2->A2_FAX+"  Cond.Pagto.: "+;
    	             IIF(!Empty(SA2->A2_COND),GetAdvFVal("SE4","E4_DESCRI",xFilial("SE4")+SA2->A2_COND,1),Space(25))
			Li++                                                                                                    
			@ li,000 PSAY Replicate("-",220)
			Li++
			nCntFOR := 0
		EndIf
	EndIf
EndDo
QRYSB1->(dbCloseArea())

If li != 80
	Li++
	@ li,000 PSAY "TOTAL GERAL A COMPRAR"+Replicate(".",134)
	@ li,156 PSAY nValTot Picture TM(nValTot,16)
	Roda(nCntImpr,cRodaTxt,Tamanho)
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

Return .T.
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณUMATR440  บAutor  ณMicrosiga           บ Data ณ  09/05/14   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function DipCalSld(cCod,cLocIni,cLocFim,cLocCQ,nImpCQ)
Local cSQL   := ""
Local nSaldo := 0
 
cSQL := " SELECT "                
If cEmpAnt=="01"
	cSQL += " 	SUM(((B2_QATU - B2_RESERVA)+B2_SALPEDI)-B2_QPEDVEN) SALDO "
Else
	cSQL += " 	SUM((B2_QATU - B2_RESERVA)-B2_QPEDVEN) SALDO "
EndIf
cSQL += " 	FROM "
cSQL += 		RetSQLName("SB2")
cSQL += " 		WHERE "        
If cEmpAnt=="01"
	cSQL += " 			B2_FILIAL IN('01','04') AND "
Else 
	cSQL += " 			B2_FILIAL IN('01','02') AND "
EndIf
cSQL += " 			B2_COD = '"+cCod+"' AND "
cSQL += " 			(B2_LOCAL BETWEEN '"+cLocIni+"' AND '"+cLocFim+"' "
If nImpCQ == 1
	cSQL += " 		OR B2_LOCAL = '"+cLocCQ+"' "
Else
	cSQL += " 		AND B2_LOCAL <> '"+cLocCQ+"' "
EndIf
cSQL += " 			) AND D_E_L_E_T_ = ' ' "

cSQL := ChangeQuery(cSQL)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),"QRYSB2",.T.,.T.)

If !QRYSB2->(Eof())
	nSaldo := QRYSB2->SALDO
EndIf
QRYSB2->(dbCloseArea())
	
Return nSaldo
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDipMesB3()  บAutor  ณJailton B Santos-JBSบ Data ณ  21/05/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ  Retorna a quantidade da data atual menos quantidade de    บฑฑ
ฑฑบ          ณ  meses.                                                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Especifico Camporas Dipromed                              บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function DipMesB3(cCodPro,dData,nMes,lDesc) 
Local nMesB3 := Month(dData) - nMes
Local cMes   := ''
Local aMeses := {'JANEIRO','FEVEREIRO','MARวO','ABRIL','MAIO','JUNHO','JULHO','AGOSTO','SETEMBRO','OUTUBRO','NOVEMBRO','DEZEMBRO'}

If nMesB3<1
	nMesB3 := 12+nMesB3
EndIf
             
If lDesc
    cMes := Padl(aMeses[nMesB3],9)
Else
	cSQL := " SELECT "
	cSQL += " 	SUM(B3_Q01) B3_Q01, SUM(B3_Q02) B3_Q02, SUM(B3_Q03) B3_Q03, "
	cSQL += " 	SUM(B3_Q04) B3_Q04, SUM(B3_Q05) B3_Q05, SUM(B3_Q06) B3_Q06, "
	cSQL += " 	SUM(B3_Q07) B3_Q07, SUM(B3_Q08) B3_Q08, SUM(B3_Q09) B3_Q09, "
	cSQL += " 	SUM(B3_Q10) B3_Q10, SUM(B3_Q11) B3_Q11, SUM(B3_Q12) B3_Q12 "
	cSQL += " 	FROM "
	cSQL +=  		RetSQLName("SB3")
	cSQL += " 		WHERE "      
	If cEmpAnt=="01"
		cSQL += " 			B3_FILIAL IN ('01','04') AND "
	Else 
		cSQL += " 			B3_FILIAL IN ('01','02') AND "
	EndIf
	cSQL += " 			B3_COD = '"+cCodPro+"' AND "
	cSQL += " 			D_E_L_E_T_ = ' ' "
	
	cSQL := ChangeQuery(cSQL)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),"QRYSB3",.T.,.T.)
	
	If !QRYSB3->(Eof())
		If nMesB3 < 1
		   nMesB3 := 12 - abs(nMesB3) 
		EndIf    
	    cMes := &('QRYSB3->B3_Q' + StrZero(nMesB3,2))
	EndIf		
	QRYSB3->(dbCloseArea())
EndIf
 
Return(cMes)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณUMATR440  บAutor  ณMicrosiga           บ Data ณ  09/19/14   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function DipRetDat(cCodigo)
Local cSQL 	  := ""
Local dDatRet := StoD("")

cSQL := " SELECT "
cSQL += " 	B1_FILIAL, B1_UCOM, B1_DATREF "
cSQL += " 	FROM "
cSQL +=  		RetSQLName("SB1")
cSQL += " 		WHERE "                           
If cEmpAnt=="01"
	cSQL += " 			B1_FILIAL IN ('01','04') AND "
Else 
	cSQL += " 			B1_FILIAL IN ('01','02') AND "
EndIf
cSQL += " 			B1_COD = '"+cCodigo+"' AND "
cSQL += " 			D_E_L_E_T_ = ' ' "

cSQL := ChangeQuery(cSQL)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),"QRYUCOM",.T.,.T.)     

TCSETFIELD("QRYUCOM","B1_UCOM"  ,"D",8,0)
TCSETFIELD("QRYUCOM","B1_DATREF","D",8,0)

While !QRYUCOM->(Eof())              
	
    If Empty(dDatRet)
		If QRYUCOM->B1_UCOM > QRYUCOM->B1_DATREF
			dDatRet := QRYUCOM->B1_UCOM
		Else 
			dDatRet := QRYUCOM->B1_DATREF
		EndIf
	Else                                        
		If QRYUCOM->B1_UCOM > QRYUCOM->B1_DATREF
			If QRYUCOM->B1_UCOM > dDatRet
				dDatRet := QRYUCOM->B1_UCOM
			EndIf
		ElseIf QRYUCOM->B1_DATREF > dDatRet 
			dDatRet := QRYUCOM->B1_DATREF
		EndIf	
	EndIf		

	QRYUCOM->(dbSkip())
EndDo
QRYUCOM->(dbCloseArea())

Return dDatRet
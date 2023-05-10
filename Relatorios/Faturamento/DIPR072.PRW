#INCLUDE "PROTHEUS.ch"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFun‡„o    ³RUNREPORT º Autor ³ Giovani.Zago       º Data ³  23/08/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescri‡„o ³ relatorio de faturamento                                   º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Programa principal                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function DIPR072()

Local cString 			:= "SC5"
Local cDesc1         	:= "Este programa tem como objetivo imprimir relatorio "
Local cDesc2         	:= "de faturamento, padrao frete 'CIF'."
Local cDesc3         	:= ""
Local cPict         	:= ""
Local titulo       		:= " "
Local nLin         		:= 0
Local Cabec1       		:= " "
Local Cabec2      		:= "          "
Local aOrd 				:= {}      
Local cUserAut          := 'EPONTOLDIO/LMARTINS/LSANTOS/MCANUTO/PMENDONCA/GIO100/DDOMINGOS/VQUEIROZ/VEGON/RBORGES/DSANTOS/JMAMEDE'
Private lEnd         	:= .F.
Private lAbortPrint  	:= .F.
Private CbTxt        	:= ""
Private limite          := 132
Private tamanho         := "M"
Private nomeprog        := "DIPR072"
Private nTipo           := 08
Private aReturn         := {"Bco A4", 1, "Administração", 2, 1, 1, "",1}
Private nLastKey        := 0
Private cbtxt     		:= Space(10)
Private cbcont     		:= 00
Private CONTFL     		:= 01
Private m_pag      		:= 01
Private wnrel      		:= "DIPR072"
Private cPerg       	:= U_FPADR( "DIPR072","SX1","SX1->X1_GRUPO"," " )  
Private cPDifAno  		:= GetNewPar("ES_PDIFANO","")
Private aPDifAno  		:= {}

cUserAut := GetNewPar("ES_DIPR072",cUserAut)

If !(Upper(U_DipUsr()) $ cUserAut)
	Aviso("Atencao","Usuário não autorizado!",{"Ok"} )	
	Return	
Endif

AjustaSX1(cPerg)
If !Pergunte(cPerg,.T.)
	Return
EndIf

aPDifAno := StrTokArr(cPDifAno,",")
_nPosDif := aScan(aPDifAno, {|x| cValToChar(Year(mv_par01))$x})
If _nPosDif > 0
	cPDifAno := aPDifAno[_nPosDif]
	cPDifAno := SubStr(cPDifAno,At("|",cPDifAno)+1,Len(cPDifAno))
Else
	cPDifAno := "0"
EndIf                                                            

If cEmpAnt = '01'
If  MV_PAR16 = 1
	titulo       		:= "RELATORIO DE FATURAMENTO - FRETE ( CIF )   MATRIZ/Cd  -  "    +dtoc(MV_PAR01)+" à "+dtoc(MV_PAR02)
ElseIf  MV_PAR16 = 2
	titulo       		:= "RELATORIO DE FATURAMENTO - FRETE ( INCLUSO )   MATRIZ/Cd  -  "    +dtoc(MV_PAR01)+" à "+dtoc(MV_PAR02)	
ElseIf  MV_PAR16 = 3
	titulo       		:= "RELATORIO DE FATURAMENTO - FRETE ( C/I )   MATRIZ/Cd  -  "    +dtoc(MV_PAR01)+" à "+dtoc(MV_PAR02)
	Else
	titulo       		:= "RELATORIO DE FATURAMENTO - FRETE	"    +dtoc(MV_PAR01)+" à "+dtoc(MV_PAR02)
EndIf
EndIf

//Cabec1    := (" ESTADO                           VALOR FATURADO      PREÇO 'C'      PREÇO 'C'("+cPDifAno+"%)    DIFERENÇA     % DIF.    FRETE REAL     % FRETE")  
//Cabec1    := (" ESTADO   DEPARTAMENTO            VALOR FATURADO      PREÇO 'C'      PREÇO 'C'("+cPDifAno+"%)    DIFERENÇA     % DIF.    FRETE REAL     % FRETE")  

If MV_PAR13 = 1  .and. MV_PAR14 = 1
	Cabec1  := (" ESTADO                           VALOR FATURADO      PREÇO 'C'      PREÇO 'C'("+cPDifAno+"%)    DIFERENÇA      % DIF.   FRETE REAL     % FRETE")  
ElseIf MV_PAR13 = 2  .and. MV_PAR14 = 1                        //
	Cabec1  := ("                                  VALOR FATURADO      PREÇO 'C'      PREÇO 'C'("+cPDifAno+"%)    DIFERENÇA      % DIF.   FRETE REAL     % FRETE")  
ElseIf MV_PAR13 = 1  .and. MV_PAR14 = 2
	Cabec1  := (" ESTADO   DEPARTAMENTO            VALOR FATURADO      PREÇO 'C'      PREÇO 'C'("+cPDifAno+"%)    DIFERENÇA      % DIF.   FRETE REAL     % FRETE")  
ElseIf MV_PAR13 = 2  .and. MV_PAR14 = 2
	Cabec1  := ("          DEPARTAMENTO	           VALOR FATURADO      PREÇO 'C'      PREÇO 'C'("+cPDifAno+"%)    DIFERENÇA      % DIF.   FRETE REAL     % FRETE")  
EndIf

wnrel := SetPrint(cString,wnrel,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,.T.,Tamanho,,.T.)

If nLastKey == 27
	Return
Endif

SetDefault(aReturn,cString,,,,2) 

If nLastKey == 27
	Return
Endif

nTipo := If(aReturn[4]==1,15,18)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Processamento. RPTSTATUS monta janela com a regua de processamento. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

RptStatus({|| RunReport(Cabec1,Cabec2,Titulo,nLin) },Titulo)
Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFun‡„o    ³RUNREPORT º Autor ³ AP6 IDE            º Data ³  09/04/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescri‡„o ³ Funcao auxiliar chamada pela RPTSTATUS. A funcao RPTSTATUS º±±
±±º          ³ monta a janela com a regua de processamento.               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Programa principal                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function RunReport(Cabec1,Cabec2,Titulo,nLin)

Local _aResult  := {}
Local _nOrdem  	:= 0
Local _cQry0    := " "
Local cWCodEmp  := cEmpAnt
Local cWCodFil  := ""
Local nFatu     := 0
Local nPrc      := 0
Local nPrcD		:= 0
Local nDif      := 0
Local nFret     := 0
Local cEstd     := ' '
Local nFatEst   := 0
Local nPrcESt   := 0
Local nPrcEStD  := 0
Local nDifEst   := 0
Local nFreEst   := 0            

If cWCodEmp = '01'
	cWCodFil := "IN ('01','04')"
Else
	cWCodFil := " = '"+cfilant+"'"
EndIf
If Select("TMP1") > 0
	TMP1->( DbCloseArea() )
EndIf                                  

_cQry0 := " "
If MV_PAR13 = 1
	_cQry0 +=" SELECT ESTADO, "
	If MV_PAR14 = 2            
		_cQry0 +=" DEPARTAMENTO, "
	EndIf
	_cQry0 +=" SUM(FATURADO) FATURADO, SUM(PRECO) PRECO, SUM(PRECOD) PRECOD, SUM(DIFERENCA) DIFERENCA, "
	_cQry0 +=" SUM(PORCENTAGEM) PORCENTAGEM, SUM(FRETE) FRETE, SUM(FRETEPOR) FRETEPOR FROM ( "
	_cQry0 +=" SELECT  SC5.C5_ESTE AS 'ESTADO', "
	If MV_PAR14 = 2            
		_cQry0 +=" TU7.POSTO AS 'DEPARTAMENTO', "
	EndIf          
ElseIf MV_PAR14 = 2
	_cQry0 +=" SELECT DEPARTAMENTO, SUM(FATURADO) FATURADO, SUM(PRECO) PRECO, SUM(PRECOD) PRECOD, "
	_cQry0 +=" SUM(DIFERENCA) DIFERENCA, SUM(PORCENTAGEM) PORCENTAGEM, SUM(FRETE) FRETE, SUM(FRETEPOR) FRETEPOR FROM ( "
	_cQry0 +=" 			SELECT  TU7.POSTO AS 'DEPARTAMENTO', "
Else
	_cQry0 +=" SELECT "
EndIf

_cQry0 +=" ROUND((SUM(TD2.TOTAL)+SUM(TD2.DESPESA)+SUM(TD2.VALFRE)+SUM(TD2.SEGURO)+SUM(TD2.ICMSRET)),4)                          AS 'FATURADO',   "
_cQry0 +=" ROUND(SUM(TC6.PRECO * TD2.QTD),4)                          										   AS 'PRECO',      "
_cQry0 +=" CASE WHEN TA1.A1_TIPO='F' AND SC5.C5_ESTE <> 'SP' THEN ROUND(SUM(TC6.PRECO * TD2.QTD)*1.0"+cPDifAno+",4) ELSE  ROUND(SUM(TC6.PRECO * TD2.QTD),4) END   AS 'PRECOD',
_cQry0 +=" ROUND((SUM(TD2.TOTAL)+ SUM(TD2.DESPESA)+ SUM(TD2.VALFRE)+ SUM(TD2.SEGURO)+SUM(TD2.ICMSRET)),4)- CASE WHEN TA1.A1_TIPO='F' AND SC5.C5_ESTE <> 'SP' THEN ROUND(SUM(TC6.PRECO * TD2.QTD)*1.0"+cPDifAno+",4) ELSE  ROUND(SUM(TC6.PRECO * TD2.QTD),4) END AS 'DIFERENCA',  "
_cQry0 +="CASE WHEN SUM(TC6.PRECO * TD2.QTD)>0 THEN ROUND((((ROUND((SUM(TD2.TOTAL)+SUM(TD2.DESPESA)+SUM(TD2.VALFRE)+SUM(TD2.SEGURO)+SUM(TD2.ICMSRET)),4) *100)/ ROUND(SUM(TC6.PRECO * TD2.QTD),4))-100),2)ELSE 0 END AS 'PORCENTAGEM', "
_cQry0 +=" ROUND(SUM(TD2.FRTDIP),4)                           																	AS 'FRETE' , "
_cQry0 +="  CASE WHEN (SUM(TD2.TOTAL)+SUM(TD2.DESPESA)+SUM(TD2.VALFRE)+SUM(TD2.SEGURO)+SUM(TD2.ICMSRET))>0 THEN ROUND((ROUND(SUM(TD2.FRTDIP),4)*100)/ROUND((SUM(TD2.TOTAL)+SUM(TD2.DESPESA)+SUM(TD2.VALFRE)+SUM(TD2.SEGURO)+SUM(TD2.ICMSRET)),4),2) ELSE 0 END  AS 'FRETEPOR' "
_cQry0 +=" FROM "+RETSQLNAME ("SC5") + " SC5
_cQry0 +=" INNER JOIN ( SELECT A1_FILIAL,A1_VEND,A1_GRPVEN,A1_COD ,A1_LOJA, A1_TIPO
_cQry0 +=" FROM "+RETSQLNAME ("SA1") + " SA1   "
_cQry0 +=" WHERE A1_FILIAL = ' '
_cQry0 +=" AND SA1.D_E_L_E_T_ = ' '
_cQry0 +=" AND A1_GRPVEN  BETWEEN '"+mv_par11+"' AND '"+mv_par12+"' )TA1  "
_cQry0 +=" ON TA1.A1_COD =  SC5.C5_CLIENTE "
_cQry0 +=" AND TA1.A1_LOJA = SC5.C5_LOJACLI "
_cQry0 +=" INNER JOIN(SELECT C6_TES, C6_ITEM  ,C6_FILIAL, C6_NUM, C6_NOTA, C6_SERIE, (CASE WHEN C6_PRVSUPE > 0 THEN C6_PRVSUPE ELSE  C6_PRVMINI END) AS 'PRECO' , C6_VALOR  "
_cQry0 +="  FROM "+RETSQLNAME ("SC6") + " SC6                      "
_cQry0 +=" WHERE SC6.D_E_L_E_T_ = ' ')TC6       "
_cQry0 +=" ON TC6.C6_NUM        =  SC5.C5_NUM   "
_cQry0 +=" AND TC6.C6_FILIAL    =   SC5.C5_FILIAL  "
_cQry0 +=" INNER JOIN(SELECT D2_QUANT AS 'QTD',D2_FILIAL,D2_PEDIDO, D2_SERIE,D2_DOC, SUM(D2_TOTAL) AS 'TOTAL' ,SUM(D2_DESPESA) AS 'DESPESA' ,SUM(D2_VALFRE) AS 'VALFRE', SUM(D2_ICMSRET) AS 'ICMSRET' ,SUM(D2_SEGURO) AS 'SEGURO' , SUM(D2_FRTDIP) AS 'FRTDIP' ,D2_ITEMPV "
_cQry0 +=" FROM "+RETSQLNAME ("SD2") + " SD2     "
_cQry0 +=" WHERE SD2.D_E_L_E_T_ = ' ' "
_cQry0 +=" AND SD2.D2_EMISSAO  BETWEEN '"+Dtos(mv_par01)+"' AND '"+Dtos(mv_par02)+"'"
_cQry0 +=" AND SD2.D2_CLIENTE  BETWEEN '"+mv_par03+"' AND '"+mv_par04+"'"
_cQry0 +=" AND SD2.D2_FORNEC   BETWEEN '"+mv_par05+"' AND '"+mv_par06+"'"
_cQry0 +=" AND SD2.D2_COD      BETWEEN '"+mv_par09+"' AND '"+mv_par10+"'"
_cQry0 +=" GROUP BY  SD2.D2_QUANT,SD2.D2_FILIAL,SD2.D2_PEDIDO, SD2.D2_SERIE,SD2.D2_DOC,D2_ITEMPV  )TD2 "
_cQry0 +=" ON TC6.C6_NOTA    =  TD2.D2_DOC                 "
_cQry0 +=" AND TC6.C6_SERIE  = TD2.D2_SERIE                "
_cQry0 +=" AND TC6.C6_NUM    = TD2.D2_PEDIDO               "
_cQry0 +=" AND TC6.C6_FILIAL = TD2.D2_FILIAL               "
_cQry0 +=" AND TC6.C6_ITEM   = TD2.D2_ITEMPV                 "
_cQry0 +=" INNER JOIN (SELECT (CASE WHEN U7_POSTO = 01 THEN 'APOIO' WHEN U7_POSTO = 02 THEN 'TELEVENDAS' WHEN U7_POSTO = 03  THEN 'LICITAÇÃO' WHEN U7_POSTO = 04  THEN 'SAC'WHEN U7_POSTO = 05  THEN 'COBRANÇA' WHEN U7_POSTO = 06  THEN 'HQ' ELSE 'OUTROS' END)	AS 'POSTO',U7_COD  "
_cQry0 +=" FROM SU7010 SU7  "
_cQry0 +=" WHERE SU7.D_E_L_E_T_ = ' '  "
_cQry0 +=" AND U7_FILIAL        = ' ' "
If cWCodEmp = '01'
_cQry0 +=" AND U7_POSTO IN (01,02,03))TU7 " 
ELSE
_cQry0 +=" AND U7_POSTO IN (01,02,03,04,05,06))TU7 "
EndIf 
_cQry0 +=" ON TU7.U7_COD = SC5.C5_OPERADO "

_cQry0 +=" INNER JOIN (SELECT F4_FILIAL,F4_DUPLIC ,F4_CODIGO  "
_cQry0 +=" FROM "+RETSQLNAME ("SF4") + " SF4  "
_cQry0 +=" WHERE F4_DUPLIC    = 'S'    "
_cQry0 +=" AND SF4.D_E_L_E_T_ = ' ')TF4     "
_cQry0 +=" ON TC6.C6_TES      = TF4.F4_CODIGO  "
_cQry0 +=" AND TF4.F4_FILIAL  =  TC6.C6_FILIAL  "

_cQry0 +=" INNER JOIN (SELECT F2_FILIAL,F2_SERIE,F2_DOC ,F2_VEND1 ,F2_TRANSP"
_cQry0 +=" FROM "+RETSQLNAME ("SF2") + " SF2  " 
If  MV_PAR17 = 2
_cQry0 +=" WHERE F2_TRANSP    <> '100000'    "
Else
_cQry0 +=" WHERE F2_TRANSP    <> '      '    "
EndIf 
_cQry0 +=" AND SF2.F2_VEND1 <> '006874'  "
_cQry0 +=" AND SF2.F2_VEND1  BETWEEN '"+mv_par07+"' AND '"+mv_par08+"'"
_cQry0 +=" AND SF2.D_E_L_E_T_  = ' ')TF2     "
_cQry0 +=" ON  TC6.C6_NOTA     = TF2.F2_DOC                  "
_cQry0 +=" AND TC6.C6_SERIE    = TF2.F2_SERIE                "
_cQry0 +=" AND TC6.C6_FILIAL   = TF2.F2_FILIAL               "

_cQry0 +=" WHERE SC5.D_E_L_E_T_ = ' '   					" 
If  MV_PAR16 = 1
_cQry0 +=" AND SC5.C5_TPFRETE   = 'C'    					"
ElseIf  MV_PAR16 = 2
_cQry0 +=" AND SC5.C5_TPFRETE   = 'I'    					"
ElseIf  MV_PAR16 = 3
_cQry0 +=" AND SC5.C5_TPFRETE   IN ('C','I')    			"
EndIf
_cQry0 +=" AND SC5.C5_FILIAL  "+cWCodFil 
_cQry0 +=" AND SC5.C5_TIPO      IN ('N','C')"

If MV_PAR15 = 2
	_cQry0 +=" AND SC5.C5_ESTE <> 'SP' "
EndIf

If MV_PAR13 = 1 
	_cQry0 +=" GROUP BY SC5.C5_ESTE, TA1.A1_TIPO "
	
	If MV_PAR14 = 2
		_cQry0 +=" ,TU7.POSTO "
	EndIf	                         
	
	_cQry0 +=" )A GROUP BY A.ESTADO "
	
	If MV_PAR14 = 2
		_cQry0 +=", A.DEPARTAMENTO "
	EndIf
	
	_cQry0 +=" ORDER BY A.ESTADO "
	
	If MV_PAR14 = 2
		_cQry0 +=", A.DEPARTAMENTO "
	EndIf		
ElseIf MV_PAR14 = 2                      
	_cQry0 +=" GROUP BY TU7.POSTO, SC5.C5_ESTE, TA1.A1_TIPO ) A "
	_cQry0 +=" GROUP BY A.DEPARTAMENTO "
	_cQry0 +=" ORDER BY A.DEPARTAMENTO "      
Else
	_cQry0 +=" GROUP BY SC5.C5_ESTE, TA1.A1_TIPO "
EndIf

dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQry0),'TMP1',.T.,.F.) 

If Select("TMP1") > 0
	nLin         		:= 120
	TMP1->(dbgotop())
	If !EMPTY ("TMP1")
		DbSelectArea("TMP1")
		DbGoTop()
		While TMP1->(!EOF())
			if lAbortPrint
				@nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
				Exit
			Endif
			//somar os totais de todos os estados
			nFatu    := TMP1->FATURADO  +nFatu
			nPrc     := TMP1->PRECO     +nPrc
			nPrcD    := TMP1->PRECOD    +nPrcD
			nDif     := TMP1->DIFERENCA +nDif
			nFret    := TMP1->FRETE     +nFret
			
			If nLin >65
				Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo,,.T.)
			   //	Cabec(cTitulo, cCabec1, cCabec2, cNomeProg, nTamanho, nCompress, aCustomText, lPerg, cLogo)
				nLin := 8
			endif
			If MV_PAR13 = 1 .and. cEstd <> TMP1->ESTADO .and. nFatEst <> 0    .and. MV_PAR14 = 2
				nLin := nLin + 1
				@nLIN,002 PSAY "TOTAL ("+cEstd+")"
				@nLIN,031 PSAY Transform(nFatEst    					,"@e 999,999,999.99")
				@nLIN,048 PSAY Transform(nPrcESt    					,"@e 999,999,999.99")
				@nLIN,065 PSAY Transform(nPrcEStD   					,"@e 999,999,999.99")
				@nLIN,080 PSAY Transform(nDifEst    					,"@e 999,999,999.99")
				@nLIN,100 PSAY Transform((((nFatEst*100)/nPrcEStD)-100)	,"@e 999.99")+"%"
				@nLIN,110 PSAY Transform(nFreEst    					,"@e 99,999.99")
				@nLIN,125 PSAY Transform(((nFreEst*100)/nFatEst)    	,"@e 999.99")+"%"
				nFatEst   := 0
				nPrcESt   := 0
				nPrcEstD  := 0
				nDifEst   := 0
				nFreEst   := 0
				nLin := nLin + 1
			EndIf			
			
			If MV_PAR13 = 1 .and. cEstd <> TMP1->ESTADO
				
				@nLIN,000 PSAY  Replicate('-',Limite)
				If nLin >60
					Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
					
					nLin := 8
				endif
				nLin := nLin + 1
				@nLIN,002 PSAY ALLTRIM(TMP1->ESTADO)
				cEstd := TMP1->ESTADO
			EndIf
			
			If MV_PAR14 = 2				
				@nLIN,010 PSAY	TMP1->DEPARTAMENTO
			EndIf
			If !(MV_PAR14 = 1 .and. MV_PAR13 = 2)
				@nLIN,031 PSAY Transform(TMP1->FATURADO 	,"@e 999,999,999.99")
				@nLIN,048 PSAY Transform(TMP1->PRECO    	,"@e 999,999,999.99")
				@nLIN,065 PSAY Transform(TMP1->PRECOD   	,"@e 999,999,999.99")				
				@nLIN,080 PSAY Transform(TMP1->DIFERENCA	,"@e 999,999,999.99")
				@nLIN,100 PSAY Transform(TMP1->PORCENTAGEM	,"@e 999.99")+"%"
				@nLIN,110 PSAY Transform(TMP1->FRETE    	,"@e 99,999.99")
				@nLIN,125 PSAY Transform(TMP1->FRETEPOR		,"@e 999.99")+"%"
				//TOTAL POR ESTADO
				nFatEst   := TMP1->FATURADO  + nFatEst
				nPrcESt   := TMP1->PRECO     + nPrcESt
				nPrcEStD  := TMP1->PRECOD    + nPrcEStD			
				nDifEst   := TMP1->DIFERENCA + nDifEst
				nFreEst   := TMP1->FRETE     + nFreEst
			EndIf
			
			nLin := nLin + 1
			
			TMP1->(DbSkip())
		End
		
		If	MV_PAR14 = 1 .and. MV_PAR13 = 1			
			@nLIN,000 PSAY  Replicate('-',Limite)
			nLin := nLin + 1
		EndIf                              
		
		If MV_PAR13 = 1 .and. nFatEst <> 0.and. MV_PAR14 = 2
			nLin := nLin + 2
			@nLIN,002 PSAY "TOTAL ("+cEstd+")"
			@nLIN,031 PSAY Transform(nFatEst     					,"@e 999,999,999.99")
			@nLIN,048 PSAY Transform(nPrcESt     					,"@e 999,999,999.99")
			@nLIN,065 PSAY Transform(nPrcEStD   					,"@e 999,999,999.99")
			@nLIN,080 PSAY Transform(nDifEst    					,"@e 999,999,999.99")
			@nLIN,100 PSAY Transform((((nFatEst*100)/nPrcEStD)-100)	,"@e 999.99")+"%"
			@nLIN,110 PSAY Transform(nFreEst    					,"@e 99,999.99")
			@nLIN,125 PSAY Transform(((nFreEst*100)/nFatEst)		,"@e 999.99")+"%"
			nFatEst   := 0
			nPrcEst   := 0
			nPrcEstD  := 0
			nDifEst   := 0
			nFreEst   := 0
			nLin := nLin + 1
			@nLIN,000 PSAY Replicate('-',Limite)
			nLin := nLin + 2
		EndIf

		nLin := nLin + 1
		@nLIN,000 PSAY Replicate('*',Limite)
		nLin := nLin + 1
		@nLIN,002 PSAY "TOTAL:"
		@nLIN,031 PSAY Transform(nFatu    					,"@e 999,999,999.99")
		@nLIN,048 PSAY Transform(nPrc     					,"@e 999,999,999.99")
		@nLIN,065 PSAY Transform(nPrcD    					,"@e 999,999,999.99")
		@nLIN,080 PSAY Transform(nDif     					,"@e 999,999,999.99")
		@nLIN,100 PSAY Transform((((nFatu*100)/nPrcD)-100)  ,"@e 999.99") +"%"
		@nLIN,110 PSAY Transform(nFret    					,"@e 999,999.99")
		@nLIN,125 PSAY Transform(((nFret*100)/nFatu)		,"@e 999.99")+"%"
		nLin := nLin + 1
		@nLIN,000 PSAY Replicate('*',Limite)
		
		TMP1->(DBCloseArea())
	Endif
Else

Aviso('Atenção','Nao encontrado dados que satisfacam aos parametros informados!',{'Ok'}) 

Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Finaliza a execucao do relatorio...                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

SET DEVICE TO SCREEN

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se impressao em disco, chama o gerenciador de impressao...          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If aReturn[5]==1
	dbCommitAll()
	SET PRINTER TO
	OurSpool(wnrel)
Endif

MS_FLUSH()

Return


//PERGUNTA *********************************************************************8
Static Function AjustaSX1(cPerg)
_sAlias := Alias()
dbSelectArea("SX1")
dbSetOrder(1)

aRegs:={}

//------------ Grupo/Ordem/Pergunta/PERGING/PERGESP/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05/F3
Aadd(aRegs,{cPerg, "01", "Da Emissao:"        ,"Da Emissao:  " 		  ,"Da Emissao:  " 		  ,"mv_ch1"  ,"D",8,0,0,"G","","mv_par01","","","","","","","","","","","","","",""})
Aadd(aRegs,{cPerg, "02", "Ate Emissao:"       ,"Ate Emissao:  " 	  ,"Ate Emissao:  "		  ,"mv_ch2"  ,"D",8,0,0,"G","","mv_par02","","","","","","","","","","","","","",""})
Aadd(aRegs,{cPerg, "03", "Do Cliente :"       ,"Do Cliente :  "		  ,"Do Cliente :  "		  ,"mv_ch3"  ,"C",6,0,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","",'SA1'})
Aadd(aRegs,{cPerg, "04", "Ate Cliente :"      ,"Ate Cliente :  " 	  ,"Ate Cliente :  "	  ,"mv_ch4"  ,"C",6,0,0,"G","","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","",'SA1'})
Aadd(aRegs,{cPerg, "05", "Do Fornecedor :"    ,"Do Fornecedor :  "	  ,"Do Fornecedor :  "	  ,"mv_ch5"  ,"C",6,0,0,"G","","mv_par05","","","","","","","","","","","","","","","","","","","","","","","","",'SA2'})
Aadd(aRegs,{cPerg, "06", "Ate Fornecedor :"   ,"Ate Fornecedor : "	  ,"Ate Fornecedor :  "   ,"mv_ch6"  ,"C",6,0,0,"G","","mv_par06","","","","","","","","","","","","","","","","","","","","","","","","",'SA2'})
Aadd(aRegs,{cPerg, "07", "Do Vendedor :"      ,"Do Vendedor : "       ,"Do Vendedor :  "      ,"mv_ch7"  ,"C",6,0,0,"G","","mv_par07","","","","","","","","","","","","","","","","","","","","","","","","",'SA3'})
Aadd(aRegs,{cPerg, "08", "Ate Vendedor :"     ,"Ate Vendedor : "      ,"Ate Vendedor :  "     ,"mv_ch8"  ,"C",6,0,0,"G","","mv_par08","","","","","","","","","","","","","","","","","","","","","","","","",'SA3'})
Aadd(aRegs,{cPerg, "09", "Do Produto :"       ,"Do Produto : "		  ,"Do Produto :  "		  ,"mv_ch9"  ,"C",6,0,0,"G","","mv_par09","","","","","","","","","","","","","","","","","","","","","","","","",'SB1'})
Aadd(aRegs,{cPerg, "10", "Ate Produto :"      ,"Ate Produto : "		  ,"Ate Produto :  "	  ,"mv_cha"  ,"C",6,0,0,"G","","mv_par10","","","","","","","","","","","","","","","","","","","","","","","","",'SB1'})
Aadd(aRegs,{cPerg, "11", "Grupo de  :"        ,"Grupo de : "		  ,"Grupo de : "		  ,"mv_chb"  ,"C",6,0,0,"G","","mv_par11","","","","","","","","","","","","","","","","","","","","","","","","",'ACY'})
Aadd(aRegs,{cPerg, "12", "Grupo Ate  :"       ,"Grupo Ate  : "		  ,"Grupo Ate  : "		  ,"mv_chc"  ,"C",6,0,0,"G","","mv_par12","","","","","","","","","","","","","","","","","","","","","","","","",'ACY'})
Aadd(aRegs,{cPerg, "13", "Consolida ?"        ,"Consolida ? "	      ,"Consolida ? "	      ,"mv_chd"  ,"N",1,0,1,"C","","mv_par13","Nao","","","","","Sim","","","","","","","",""})
Aadd(aRegs,{cPerg, "14", "Departamento ?"     ,"Departamento ? "	  ,"Departamento ? "      ,"mv_che"  ,"N",1,0,1,"C","","mv_par14","Nao","","","","","Sim","","","","","","","",""})
Aadd(aRegs,{cPerg, "15", "Considera SP ?"     ,"Considera SP ? "	  ,"Considera SP ? "  	  ,"mv_chf"  ,"N",1,0,1,"C","","mv_par15","Sim","","","","","Nao","","","","","","","",""})
Aadd(aRegs,{cPerg, "16", "Tipo de Frete"      ,"Tipo de Frete"	      ,"Tipo de Frete"		  ,"mv_chg"  ,"N",1,0,1,"C","","mv_par16","CIF","","","","","INCLUSO","","","","","Ambos","","",""})
Aadd(aRegs,{cPerg, "17", "Considera Emovere ?","Considera Emovere ? ","Considera Emovere ? "  ,"mv_chh"  ,"N",1,0,1,"C","","mv_par17","Sim","","","","","Nao","","","","","","","",""})



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


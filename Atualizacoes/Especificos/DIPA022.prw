/*==========================================================================\
|Programa  | DIPA022 | Autor | Rafael de Campos Falco  | Data | 16/03/2004  |
|===========================================================================|
|Desc.     | Digita dados para compor tela de frete                         |
|===========================================================================|
|Sintaxe   | DIPA022                                                        |
|==========================================================================|
|Uso       | Especifico DIPROMED                                            |
|===========================================================================|
|Histórico | DD/MM/AA - Descrição da alteração                              |
|          =================================================================|
|  Maximo  | 14/05/07 - Incluir tela para selecionar várias faturas e       |                      
|          |            incluir total geral.                                |                      
|  Maximo  | 12/03/09 - Permite imprimir notas canceladas                   |                      
|  Maximo  | 04/11/09 - Mostra Peso CRTC e frete calculado pelo PESO CTRC   |                      
|          |            e sai o valor da mercadoria                         |                      
\==========================================================================*/

#include "rwmake.ch"
#Include "colors.ch"
#INCLUDE "TBICONN.CH"
#INCLUDE "FILEIO.CH"

User Function DIPA022()
Local _xAlias  := GetArea()
Local _aCpos	:= {}

Private cCadastro := "Digitacao do Frete Dipromed"

PRIVATE aRotina := { ;
{"Pesquisar"  ,"AxPesqui"  , 0 , 1},;
{"Visualiza"  ,"AxVisual"  , 0 , 2},;
{"Alteração"  ,"U_FreAlt"  , 0 , 4},;
{"Lista Frete" ,"U_LisFre"  , 0 , 6}}

Private bFiltraBrw := {|| Nil}

/*If AllTrim(Upper(U_DipUsr())) <> 'FALCO'
	MSGSTOP("Voce nao é o Eriberto","Usuario sem autorizacao!")
	Return
EndIf*/

U_DIPPROC(ProcName(0),U_DipUsr()) // MCVN - 22/01/2009

dbSelectArea("SF2")
dbGotop()
Set Deleted Off                                                           
aadd(_aCpos,{"Nota Fiscal"   ,"F2_DOC"    })
aadd(_aCpos,{"Emissao"       ,"F2_EMISSAO"})
aadd(_aCpos,{"Valor Frete"   ,"F2_FRETE"  })
aadd(_aCpos,{"Transportadora","F2_TRANSP" })
aadd(_aCpos,{"Conhecimento"  ,"F2_NROCON" })
aadd(_aCpos,{"Frete Dipromed","F2_FRTDIP" })
aadd(_aCpos,{"Frete SZ3"     ,"F2_FRETSZ3"})
aadd(_aCpos,{"Peso CTRC "    ,"F2_PESOCTR"})
aadd(_aCpos,{"Valor Bruto"   ,"F2_VALBRUT"})
aadd(_aCpos,{"Valor Merc"    ,"F2_VALMERC"})
aadd(_aCpos,{"Tipo Frete"    ,"F2_TPFRETE"})

//MBrowse(nLinha1,nColuna1,nLinha2,ncoluna2,cAlias,aFixe,cCpo,nPar,cCor,nOpc)
MBrowse(06,01,22,75,"SF2",_aCpos,,,,)
Set Deleted on
RestArea(_xAlias)

Return

/*==========================================================================\
|Programa  | FreAlt  | Autor | Rafael de Campos Falco  | Data | 16/03/2004  |
|===========================================================================|
|Desc.     | Alteração de frete                                             |
|===========================================================================|
|Sintaxe   | FreAlt                                                         |
|===========================================================================|
|Uso       | Especifico DIPROMED                                            |
|===========================================================================|
|Histórico | DD/MM/AA - Descrição da alteração                              |
\==========================================================================*/

User Function FreAlt(cAlias,nReg)
Local cNum_Con := Space(06)
Local cFat_Num := Space(06)
Local nFrt_Dip := 0
Local nPeso_Ctr:= 0


Begin Transaction
Dbselectarea("SF2")
DbGoTo(nReg)

cNum_Con := SF2->F2_NROCON
cFat_Num := SF2->F2_FATFRET
nFrt_Dip := SF2->F2_FRTDIP                                          
nPeso_Ctr:= SF2->F2_PESOCTR

@ 126,000 To 395,310 DIALOG oDlg TITLE OemToAnsi("      NF - " + SF2->F2_DOC)
@ 008,010 Say "N.Fiscal-Série: " + SF2->F2_DOC + "-" + SF2->F2_SERIE
@ 020,010 Say "Emissão: " + SubStr(DtoS(SF2->F2_EMISSAO),7,2) + "/" + SubStr(DtoS(SF2->F2_EMISSAO),5,2) + "/" + SubStr(DtoS(SF2->F2_EMISSAO),1,4)
@ 035,010 Say "Tipo Frete: " + SF2->F2_TPFRETE
@ 050,010 Say "Conhecimento: "
@ 050,055 Get cNum_Con Size 40,20 Picture "@!" Valid !Empty(cNum_Con)
@ 065,010 Say "Frete Dipromed: "
@ 065,055 Get nFrt_Dip Size 40,20 Picture "@E 999,999.99" Valid If(nFrt_Dip <= 0,.F.,.T.)
@ 080,010 Say "Peso CTRC: "//MCVN 02/09/10
@ 080,055 Get nPeso_CTR Size 40,20 Picture "@E 999,999.99" Valid If(nPeso_CTR <= 0,.F.,.T.) //MCVN 02/09/10
@ 095,010 Say "Fatura: "
@ 095,055 Get cFat_Num Size 40,20 Picture "@!" Valid !Empty(cFat_Num)
@ 115,090 BmpButton Type 1 Action (Ok(cNum_Con, nFrt_Dip, cFat_Num, nPeso_Ctr),Close(oDlg))
@ 115,120 BmpButton Type 2 Action Close(oDlg)
ACTIVATE DIALOG oDlg Centered
End Transaction
Return

Static Function Ok(cNum_Con, nFrt_Dip, cFat_Num, nPeso_Ctr)
RecLock("SF2",.F.)
SF2->F2_NROCON := cNum_Con
SF2->F2_FRTDIP := nFrt_Dip
If SF2->F2_FRETSZ3 = 0           //MCVN 02/09/10
	SF2->F2_FRETSZ3 := nFrt_Dip  //MCVN 02/09/10
Endif
SF2->F2_PESOCTR:= nPeso_Ctr //MCVN 02/09/10
SF2->F2_FATFRET:= cFat_Num
MsUnlock()
// Eriberto 13/02/2006 Close(oDlg)
Return



/*==========================================================================\
|Programa  | LisFre  | Autor | Rafael de Campos Falco  | Data | 16/03/2004  |
|===========================================================================|
|Desc.     | Listagem de frete por transportadora                           |
|===========================================================================|
|Sintaxe   | LisFre                                                         |
|===========================================================================|
|Uso       | Especifico DIPROMED                                            |
|===========================================================================|
|Histórico | 15/06/04 - Adicionar colunas Peso Bruto e Porcentagem          |
\==========================================================================*/

User Function LisFre() 

Local _xArea		:= GetArea()
Local titulo		:=  OemTOAnsi("Listagem de fretes por transportadora",72)
Local cDesc1		:= (OemToAnsi("Este programa tem como objetivo emitir um relat¢rio",72))
Local cDesc2		:= (OemToAnsi("informando NF emitadas e seus respectivos fretes.",72))
Local cDesc3     	:= (OemToAnsi("Conforme parâmetros.",72))
Local oDlg  

Private aReturn	:= {"Bco A4", 1,"Administracao", 1, 2, 1,"",1}
Private nomeprog	:= "DIPA022-LISFRE"
Private cPerg		:= "LISFRE"
Private wnrel		:= "LISFRE"
Private cString	:= "SF2"
Private tamanho	:= "G"
Private limite		:= 220
Private lEnd		:= .F.
Private nLastKey	:= 0
Private li			:= 67
Private m_pag		:= 1    
Private cGetFaturas := Space(63)
Private cFaturas	:= ""
Private cFatFrete	:= ""


AjustaSX1(cPerg) //PergFre()             // Verifica perguntas. Se nao existe INCLUI

If !Pergunte(cPerg,.T.)    // Solicita parametros
	Return
EndIf

 If MV_PAR07 == 2
 
	Define msDialog oDlg Title "LISTANDO FATURAS DE FRETE" From 10,10 TO 20,55
	
	@ 001,002 tO 70,177	
	
	@ 010,010 say "INFORME AS FATURAS SEPARADAS POR VIRGULA! "  COLOR CLR_HBLUE
	@ 030,010 get cGetFaturas valid !empty(cGetFaturas) size 160,08
	
	DEFINE SBUTTON FROM 55,135 TYPE 1 ACTION IF(!empty(cGetFaturas),oDlg:End(),msgInfo("Informe no mínimo duas faturas","Atenção")) ENABLE OF oDlg

	Activate dialog oDlg centered
    
	cFaturas := cGetFaturas
	cFatFrete:= ""   
	j:=1
 
	For i := 1 to (Len(Alltrim(cFaturas))+1)/7   //MCVN   
	    
    	If i = (Len(Alltrim(cFaturas))+1)/7
    		cGetFaturas  := "'"+subs(cFaturas,j,6)+"'"
    		cFatFrete    := cFatFrete + cGetFaturas
    	Else  
    		cGetFaturas  := "'"+subs(cFaturas,j,6)+"',"
    		cFatFrete    := cFatFrete + cGetFaturas
       	Endif
   		j := j+7
    Next   
    
EndIf	  

wnrel := SetPrint(cString,wnrel,cPerg,Titulo,cDesc1,cDesc2,cDesc3,.f.,,.f.,tamanho,,.f.,,,,,)

If nLastKey == 27
	Return
Endif

SetDefault(aReturn,cString)

RptStatus({|lEnd| RodaFre()},Titulo)

Set device to Screen

/*============================================================================\
| Se em disco, desvia para Spool                                              |
\============================================================================*/
If aReturn[5] == 1    // Se Saida para disco, ativa SPOOL
	Set Printer TO
	Commit
	ourspool(wnrel)
Endif
RestArea(_xArea)

Return

//////////////////////////////////////////////////////////////////////
Static Function RodaFre()

Local nTotFre	 := 0
Local nTotDip	 := 0
Local nTotDif	 := 0
Local nTotBrt	 := 0
Local nTotMer	 := 0 
Local nTotSZ3    := 0
Local nTotGerFre := 0
Local nTotGerDip := 0
Local nTotGerBrt := 0
Local nTotGerMer := 0
Local nTotGerSZ3 := 0
Local nFreCif    := 0
Local nFreInc    := 0
Local nFreFob    := 0
Local cFat_Num   := ""
Local cNomFor    := ""
Local nHandle	 := ""
Local cWorkFlow  := "N"
Local oDlg


/*
SELECT F2_FILIAL, F2_DOC, F2_SERIE, F2_EMISSAO, F2_FRETE, F2_TRANSP, F2_VEND1, F2_TPFRETE, F2_NROCON, F2_FRTDIP, F2_VALBRUT, F2_VALMERC, A4_COD, A4_NOME, F2_PBRUTO, F2_FATFRET
FROM SF2010, SA4010
WHERE F2_EMISSAO BETWEEN '20040101' AND '20041231'
AND F2_FATFRET BETWEEN '333333' AND '333333'
AND F2_TRANSP = '000001'
AND F2_NROCON <> ''
AND F2_TRANSP = A4_COD
AND SF2010.D_E_L_E_T_ = ''
AND SA4010.D_E_L_E_T_ = ''
--ORDER BY F2_DOC, F2_EMISSAO
ORDER BY F2_FATFRET, F2_EMISSAO
*/

QRY1 := " SELECT F2_FILIAL, F2_DOC, F2_SERIE, F2_EMISSAO, F2_FRETE, F2_TRANSP, F2_VEND1, F2_TPFRETE, F2_NROCON, F2_FRTDIP, F2_VALBRUT, F2_VALMERC, A4_COD, A4_NOME, F2_PBRUTO, F2_FATFRET, F2_PESOCTR, F2_FRETSZ3, "+RetSQLName("SF2")+".D_E_L_E_T_  AS DELETADA"
QRY1 += " FROM " + RetSQLName("SF2")+', '+ RetSQLName("SA4")
QRY1 += " WHERE F2_EMISSAO BETWEEN '"+ DTOS(MV_PAR02) +"' AND '"+ DTOS(MV_PAR03) +"'"
If MV_PAR07 == 1
   QRY1 += " AND F2_FATFRET BETWEEN '"+ MV_PAR04 +"' AND '"+ MV_PAR05 +"'"
Else
   QRY1 += " AND F2_FATFRET IN ("+cFatFrete+')'
Endif
		
If !Empty(MV_PAR01)
	QRY1 += " AND F2_TRANSP = '" +MV_PAR01 +"'"
EndIf	
QRY1 += " AND F2_NROCON <> ''"
QRY1 += " AND F2_TRANSP = A4_COD"
If !(MSGYESNO("Imprime notas deletadas?"))  // MCVN - 12/03/2009
	QRY1 += " AND " + RetSQLName("SF2")+".D_E_L_E_T_ <> '*'"
Endif
QRY1 += " AND " + RetSQLName("SA4")+".D_E_L_E_T_ <> '*'"

If MV_PAR06 == 1
	QRY1 += " ORDER BY F2_DOC, F2_EMISSAO"
Else
	QRY1 += " ORDER BY F2_FATFRET, F2_EMISSAO"
EndIf	

memowrite('DIPA022.SQL',QRY1)

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

DbCommitAll()
// Processa Query SQL
TcQuery QRY1 NEW ALIAS "QRY1"         // Abre uma workarea com o resultado da query

DbSelectArea("QRY1")

_cTitulo := "Listagem de Frete - "
_cTitulo += "Período de " + SubStr(DtoS(MV_PAR02),7,2)+"/"+SubStr(DtoS(MV_PAR02),5,2)+"/"+SubStr(DtoS(MV_PAR02),1,4) 
_cTitulo += " até "  + SubStr(DtoS(MV_PAR03),7,2)+"/"+SubStr(DtoS(MV_PAR03),5,2)+"/"+SubStr(DtoS(MV_PAR03),1,4)

If MV_PAR07 = 2                  
     cFaturas := StrTran(AllTrim(cFaturas),",","/")
	_cTitulo += " - Fatura(s): (" + cFaturas +")"
Else                                                       
	_cTitulo += " - Fatura de " + MV_PAR04 + " até " + MV_PAR05
Endif
_cDesc1  := "Transportadora: " + QRY1->A4_COD + "-" +AllTrim(QRY1->A4_NOME) + " - Fatura: " + QRY1->F2_FATFRET 

If cEmpAnt+cFilAnt =="0401"
	_cDesc2  := " N.Fiscal-Serie  Emissao     Conhecimento     Frete NF (A)        (%)       Peso Bruto      Frt.H.Quality(B)        (%)      Peso CTRC    Frt. Calculado     Diferença (A-B)         (%)      Valor Bruto    Tipo"
Else
	_cDesc2  := " N.Fiscal-Serie  Emissao     Conhecimento     Frete NF (A)        (%)       Peso Bruto      Frt.Dipromed (B)        (%)      Peso CTRC    Frt. Calculado     Diferença (A-B)         (%)      Valor Bruto    Tipo"
	//_cDesc2    := " N.Fiscal-Serie  Emissao     Conhecimento     Frete NF (A)        (%)     Frt.Dipromed (B)        (%)      Diferença (A-B)         (%)      Valor Bruto        Vlr.Mercadoria        Peso Bruto    Tipo" //// MCVN - 04/11/2009
EndIf


SetRegua(70)
For _x := 1 to 10
	IncRegua( "Imprimindo... " + QRY1->F2_DOC )
Next
*                                                                                                    1                                                                                                   2
*          1         2         3         4         5         6         7         8         9         0         1         2         3         4         5         6         7         8         9         0
*012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123
*dipr028/v.AP6 6.09                                                                          Listagem de Fretes ( 999999-XXXXXXXXXXXXXXXXXXXX )
*------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
* N.Fiscal-Série  Emissão     Conhecimento     Frete NF (A)        (%)     Frt.Dipromed (B)        (%)      Diferença (A-B)         (%)      Valor Bruto        Vlr.Mercadoria        Peso Bruto    Tipo
* 999999  -XXX    DD/MM/AAAA  999999             999.999,99    999,99%           999.999,99    999,99%           999.999,99     999,99%       999.999,99            999.999,99      999.999,9999    Incluso
*------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
* Total Geral..............................:     999.999,99    999,99%           999.999,99    999,99%           999.999,99     999,99%       999.999,99            999.999,99      999.999,9999
*------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

cFat_Num := QRY1->F2_FATFRET

Do While QRY1->(!Eof())

	// VERIFICA SE O NUMERO DA FATURA E DIFERENTE SALTAR PAGINA
	If QRY1->F2_FATFRET == cFat_Num
	
		If lAbortPrint
			@ li+1,00 PSAY "*** CANCELADO PELO OPERADOR ***"
			Exit
		Endif
		
		IncRegua( "Imprimindo... " + QRY1->F2_DOC )
		
		If li > 56
			_cDesc1  := "Transportadora: " + QRY1->A4_COD + "-" +AllTrim(QRY1->A4_NOME) + " - Fatura: " + QRY1->F2_FATFRET
			li := u_MYCabec(_cTitulo,_cDesc1,_cDesc2,nHandle,cWorkFlow)
		EndIf
		
	   // IMPRESSAO DOS DADOS DO RELATORIO
		@ li,001 PSay QRY1->F2_DOC+"  -"+QRY1->F2_SERIE 
		@ li,017 PSay SubStr(QRY1->F2_EMISSAO,7,2)+"/"+SubStr(QRY1->F2_EMISSAO,5,2)+"/"+SubStr(QRY1->F2_EMISSAO,1,4)
		@ li,029 PSay QRY1->F2_NROCON
		@ li,048 PSay QRY1->F2_FRETE PICTURE "@E 999,999.99"
		@ li,062 PSay Transform((QRY1->F2_FRETE / QRY1->F2_VALMERC)*100,"@E 999.99")+"%"
		@ li,074 PSay QRY1->F2_PBRUTO PICTURE "@E 999,999.9999" // MCVN - 04/11/2009
		@ li,098 PSay QRY1->F2_FRTDIP PICTURE "@E 999,999.99"                            
		@ li,112 PSay Transform((QRY1->F2_FRTDIP / QRY1->F2_VALMERC)*100,"@E 999.99")+"%"
		@ li,121 PSay QRY1->F2_PESOCTR PICTURE "@E 999,999.9999"// MCVN - 04/11/2009
		@ li,142 PSay QRY1->F2_FRETSZ3 PICTURE "@E 999,999.99"  // MCVN - 04/11/2009
		@ li,162 PSay (QRY1->F2_FRETE - QRY1->F2_FRTDIP) PICTURE "@E 999,999.99"
		@ li,179 PSay Transform(((QRY1->F2_FRETE - QRY1->F2_FRTDIP) / QRY1->F2_VALMERC)*100,"@E 999.99")+"%"
		@ li,192 PSay QRY1->F2_VALBRUT PICTURE "@E 999,999.99"
			
		// GERANDO TOTAIS
		nTotFre += QRY1->F2_FRETE
		nTotDip += QRY1->F2_FRTDIP
		nTotBrt += QRY1->F2_VALBRUT
		nTotMer += QRY1->F2_VALMERC	
		nTotSZ3 += QRY1->F2_FRETSZ3	//MCVN - 04/11/2009
		
		
		// GERANDO TOTAIS GERAIS
		nTotGerFre += QRY1->F2_FRETE
		nTotGerDip += QRY1->F2_FRTDIP
		nTotGerBrt += QRY1->F2_VALBRUT
		nTotGerMer += QRY1->F2_VALMERC
		nTotGerSZ3 += QRY1->F2_FRETSZ3 //MCVN - 04/11/2009
	
		// DEFININDO TIPO DE FRETE
		If QRY1->F2_TPFRETE == "I"
			cTip_Fre := "Incluso"
			nFreInc  += QRY1->F2_FRETE
		ElseIf QRY1->F2_TPFRETE == "C"	
			cTip_Fre := "CIF" 
			nFreCif  += QRY1->F2_FRTDIP
		ElseIf QRY1->F2_TPFRETE == "F"
			cTip_Fre := "FOB"
			nFreFob  += QRY1->F2_FRTDIP				
		Else
			cTip_Fre := QRY1->F2_TPFRETE
		EndIf	
		
		// IMPRIMINDO TIPO DE FRETE
		@ li,205 PSay cTip_Fre   
	 	@ li,213 PSay If(QRY1->DELETADA = '*', "NF CANC.","")    // MCVN - 12/03/2009
		li++
		QRY1->(DbSkip())
	Else
		If li > 56
			_cDesc1  := "Transportadora: " + QRY1->A4_COD + "-" +AllTrim(QRY1->A4_NOME) + " - Fatura: " + QRY1->F2_FATFRET
			li := u_MYCabec(_cTitulo,_cDesc1,_cDesc2,nHandle,cWorkFlow)
			li+=5
		EndIf
		
		// IMPRESSAO DA LINHA DE TOTAIS
		@ li,000 Psay Replicate('*',limite)
		li++
		@ li,000 PSay " Total da fatura "+cFat_Num+"...................:"
		@ li,048 PSay Transform(nTotFre,"@E 999,999.99")
		@ li,062 PSay Transform(( nTotFre/nTotMer )*100,"@E 999.99")+"%"
		@ li,098 PSay Transform(nTotDip,"@E 999,999.99")  
//		@ li,080 PSay Transform(nTotDip,"@E 999,999.99")  
		@ li,112 PSay Transform(( nTotDip/nTotMer )*100,"@E 999.99")+"%"
		@ li,142 PSay Transform(nTotSZ3,"@E 999,999.99")  
		@ li,162 PSay Transform((nTotFre-nTotDip),"@E 999,999.99")
		@ li,179 PSay Transform(( (nTotFre-nTotDip)/nTotMer )*100,"@E 999.99")+"%"
		@ li,192 PSay Transform(nTotBrt,"@E 999,999,999.99")            
		//@ li,163 PSay Transform(nTotMer,"@E 999,999,999.99") 
		li++
		@ li,000 Psay Replicate(' ',limite)
		li++
		@ li,0001 Psay "Total Frete Incluso: " 
		@ li,0025 PSay Transform(nFreInc, "@E 999,999.99")
		li++
		@ li,0001 PSay "Total Frete CIF: "
		@ li,0025 PSay Transform(nFreCif, "@E 999,999.99")
		li++
		@ li,0001 Psay "Total Frete FOB: " 
		@ li,0025 PSay Transform(nFreFob, "@E 999,999.99")
		li++
		@ li,000 Psay Replicate('*',limite)
		li+=2
		cFat_Num := QRY1->F2_FATFRET
		li			:= 99 
	

		nTotFre    := 0
		nTotDip    := 0
		nTotBrt    := 0
		nTotMer    := 0   
		nTotSZ3    := 0
		nFreCif    := 0
		nFreInc    := 0
		nFreFob    := 0
		
	EndIf	
EndDo

If li > 56
	li := u_MYCabec(_cTitulo,_cDesc1,_cDesc2,nHandle,cWorkFlow)
	li+=5
EndIf
                                 



// IMPRESSAO DA LINHA DE TOTAIS
@ li,000 Psay Replicate('*',limite)
li++           

@ li,000 PSay " Total da fatura "+cFat_Num+"...................:"
@ li,048 PSay Transform(nTotFre,"@E 999,999.99")
@ li,062 PSay Transform(( nTotFre/nTotMer )*100,"@E 999.99")+"%"
@ li,098 PSay Transform(nTotDip,"@E 999,999.99")  
//@ li,080 PSay Transform(nTotDip,"@E 999,999.99")  
@ li,112 PSay Transform(( nTotDip/nTotMer )*100,"@E 999.99")+"%"
@ li,142 PSay Transform(nTotSZ3,"@E 999,999.99")  
@ li,162 PSay Transform((nTotFre-nTotDip),"@E 999,999.99")
@ li,179 PSay Transform(( (nTotFre-nTotDip)/nTotMer )*100,"@E 999.99")+"%"
@ li,192 PSay Transform(nTotBrt,"@E 999,999,999.99") 
li++
@ li,000 Psay Replicate(' ',limite) 
li++
@ li,0001 Psay "Total Frete Incluso: " 
@ li,0025 PSay Transform(nFreInc, "@E 999,999.99")
li++
@ li,0001 PSay "Total Frete CIF: "
@ li,0025 PSay Transform(nFreCif, "@E 999,999.99")
li++
@ li,0001 Psay "Total Frete FOB: " 
@ li,0025 PSay Transform(nFreFob, "@E 999,999.99")
li++
@ li,000 Psay Replicate('*',limite)
li+=2

If MV_PAR07 == 2
	// IMPRESSAO DA LINHA DOS TOTAIS GERAIS
	@ li,000 Psay Replicate('*',limite)
	li++
	@ li,000 PSay " Total Geral..............................:"
	@ li,048 PSay Transform(nTotGerFre,"@E 999,999.99")
	@ li,062 PSay Transform(( nTotGerFre/nTotGerMer )*100,"@E 999.99")+"%"
	@ li,098 PSay Transform(nTotGerDip,"@E 999,999.99")  
	@ li,112 PSay Transform(( nTotGerDip/nTotGerMer )*100,"@E 999.99")+"%"
	@ li,142 PSay Transform(nTotGerSZ3,"@E 999,999.99")  
	@ li,162 PSay Transform((nTotGerFre-nTotGerDip),"@E 999,999.99")
	@ li,179 PSay Transform(( (nTotGerFre-nTotGerDip)/nTotGerMer )*100,"@E 999.99")+"%"
	@ li,192 PSay Transform(nTotGerBrt,"@E 99,999,999.99")
//	@ li,163 PSay Transform(nTotGerMer,"@E 99,999,999.99")
	li++                                               
	@ li,000 Psay Replicate('*',limite)
	li+=2
Endif

dbSelectArea("QRY1")
QRY1->(dbCloseArea())

Return(.T.)

/*==========================================================================\
|Programa  | PergFre | Autor | Rafael de Campos Falco  | Data | 16/03/2004  |
|===========================================================================|
|Desc.     | Validação das pergunta da emissão do relatório de fretes       |
|===========================================================================|
|Sintaxe   | PergFre                                                        |
|===========================================================================|
|Uso       | Especifico DIPROMED                                            |
|===========================================================================|
|Histórico | DD/MM/AA - Descrição da alteração                              |
\==========================================================================*/

Static Function AjustaSX1(cPerg) //PergFre()
_sAlias := Alias()
dbSelectArea("SX1")
dbSetOrder(1)

cPerg := PADR(cPerg, Len(SX1->X1_GRUPO)," " ) // Incluido por Sandro em 18/11/09.

aRegs:={}

//------------ Grupo/Ordem/Pergunta/PERGING/PERGESP/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05/F3

AADD(aRegs,{cPerg,"01","Inf. Transportadora","","","mv_ch1","C",6,0,0,"G","","MV_PAR01","","","","","","","","","","","","","","","","","","","","","","","","",'SA4'})
AADD(aRegs,{cPerg,"02","Inf. Data Inicial  ","","","mv_ch2","D",8,0,1,"G","","MV_PAR02","","","","","","","","","","","","","",""})
AADD(aRegs,{cPerg,"03","Inf. Data Final    ","","","mv_ch3","D",8,0,1,"G","","MV_PAR03","","","","","","","","","","","","","",""})
AADD(aRegs,{cPerg,"04","Inf. Fatura Inicial","","","mv_ch4","C",10,0,0,"G","","MV_PAR04","","","","","","","","","","","","","",""})
AADD(aRegs,{cPerg,"05","Inf. Fatura Final  ","","","mv_ch5","C",10,0,0,"G","","MV_PAR05","","","","","","","","","","","","","",""})
AADD(aRegs,{cPerg,"06","Ordenar por        ","","","mv_ch6","N",1,0,0,"C","","MV_PAR06","1-Data","","","","","2-Fatura","","","","","","","","","","","","","","","",""})
AADD(aRegs,{cPerg,"07","Varias faturas     ","","","mv_ch7","N",1,0,0,"C","","MV_PAR07","1-Não","","","","","2-Sim","","","","","","","","","","","","","","","",""})

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


////////////fim do programa

#INCLUDE "PROTHEUS.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณUMAT455A  บAutor  ณMicrosiga           บ Data ณ  04/16/13   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/                                                                                                                                   
User Function UMAT455A(cTipo,cCondic,cPedIni,cPedFin,cCliIni,cCliFin,cOpeIni,cOpeFin,cVenIni,cVenFin,cProIni,cProFin,cDatIni,cDatFin)
Local cSQL 		:= ""    
Local aItens	:= {}
DEFAULT cTipo   := ""
DEFAULT cCondic := "" 
DEFAULT cPedIni := ""
DEFAULT cPedFin := ""
DEFAULT	cCliIni := ""
DEFAULT	cCliFin := ""
DEFAULT	cOpeIni := ""
DEFAULT	cOpeFin := ""
DEFAULT	cVenIni := ""
DEFAULT	cVenFin := ""
DEFAULT	cProIni := ""
DEFAULT	cProFin := ""
DEFAULT	cDatIni := ""
DEFAULT	cDatFin := ""

cCondic := SubStr(cCondic,6,Len(cCondic)) 

If cTipo == '1'      
	cSQL += " SELECT "
	cSQL += " 	C5_PRENOTA PRENOTA, C5_NUM PEDIDO, C9_ITEM ITEM, C9_SEQUEN SEQ, C5_CLIENTE CLIENTE, C9_PRODUTO PRODUTO, "
	cSQL += " 	C9_QTDVEN QTD, C9_QTDLIB QTD_LIB, C9_SALDO SALDO, C9_OPERADO OPERADOR, C5_NOTA N_FISCAL, C5_SERIE SERIE, C9_DATALIB DT_LIB, " 
	cSQL += " 	C5_PARCIAL PARCIAL, C9_BLEST BLEST, C9_BLCRED BLCRED, "
	cSQL += "   SC5.R_E_C_N_O_ REC, "
	cSQL += "   C9_PRCVEN PRCVEN, C9_LOTECTL LOTECTL, C9_DTVALID DTVALID, C9_LOCAL LOCALI, C9_VEND VEND "
	cSQL += " 	FROM "                              
	cSQL += " 		"+RetSQLName("SC5")+" SC5 ,"+RetSQLName("SC9")+" SC9 "
	cSQL += " 		WHERE "                         
	cSQL += " 			C9_FILIAL = '"+xFilial("SC9")+"' AND "
	cSQL += " 			C5_FILIAL = '"+xFilial("SC5")+"' AND "
	cSQL += "  			C5_NUM = C9_PEDIDO AND "
	cSQL += "			SC5.D_E_L_E_T_ = ' ' AND "
	cSQL += "			SC9.D_E_L_E_T_ = ' ' AND "
	cSQL += cCondic                             	
	
	cSQL += " UNION "
EndIf

cSQL  += " SELECT "
cSQL  += " 	C5_PRENOTA PRENOTA, C5_NUM PEDIDO, D2_ITEM ITEM, D2_ITEMPV SEQ, D2_CLIENTE CLIENTE, D2_COD PRODUTO, "
cSQL  += "  D2_QUANT QTD, D2_QUANT QTD_LIB, 0 SALDO, C5_OPERADO OPERADOR, D2_DOC N_FISCAL, D2_SERIE SERIE, D2_EMISSAO DT_LIB, "
cSQL  += "  C5_PARCIAL PARCIAL, 'XX' BLEST, 'XX' BLCRED, "
cSQL  +=    RetSQLName("SC5")+".R_E_C_N_O_ REC, "       
cSQL  += "  D2_PRCVEN PRCVEN, D2_LOTECTL LOTECTL, D2_DTVALID DTVALID, D2_LOCAL LOCALI, C5_VEND1 VEND "
cSQL  += " 	FROM "
cSQL  += " 		"+RetSQLName("SD2")+", "+RetSQLName("SC5")
cSQL  += " 		WHERE "
cSQL  += " 			D2_FILIAL = '"+xFilial("SD2")+"' "
cSQL  += " 			AND C5_FILIAL = '"+xFilial("SC5")+"' "
cSQL  += " 			AND D2_PEDIDO = C5_NUM "
cSQL  += " 			AND D2_CLIENTE = C5_CLIENTE "
cSQL  += " 			AND D2_LOJA = C5_LOJACLI "
cSQL  += " 			AND C5_NUM BETWEEN     '"+cPedIni+"' AND '"+cPedFin+"' "
cSQL  += " 			AND C5_CLIENTE BETWEEN '"+cCliIni+"' AND '"+cCliFin+"' "
cSQL  += " 			AND C5_OPERADO BETWEEN '"+cOpeIni+"' AND '"+cOpeFin+"' "
cSQL  += " 			AND C5_VEND1 BETWEEN   '"+cVenIni+"' AND '"+cVenFin+"' "
cSQL  += " 			AND D2_COD BETWEEN     '"+cProIni+"' AND '"+cProFin+"' "
cSQL  += " 			AND D2_EMISSAO BETWEEN '"+cDatIni+"' AND '"+cDatFin+"' "
cSQL  += " 			AND "+RetSQLName("SD2")+".D_E_L_E_T_ = ' ' "
cSQL  += " 			AND "+RetSQLName("SC5")+".D_E_L_E_T_ = ' ' "  
cSQL  += " ORDER BY PEDIDO, CLIENTE "

cSQL := ChangeQuery(cSQL)
DbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),"QRYTRB",.T.,.T.)

TCSETFIELD("QRYTRB","DT_LIB","D",8,0)
TCSETFIELD("QRYTRB","DTVALID","D",8,0)

DbSelectArea("QRYTRB")
dbGoTop()

QRYTRB->(DbEval( {|| IncProc(), aAdd(aItens,{QRYTRB->PRENOTA,;  //01
									QRYTRB->PEDIDO,;            //02
									QRYTRB->ITEM,;              //03
									QRYTRB->SEQ,;               //04
									QRYTRB->CLIENTE,;           //05
									QRYTRB->PRODUTO,;           //06
									QRYTRB->QTD,;               //07
									QRYTRB->QTD_LIB,;           //08
									QRYTRB->SALDO,;             //09
									QRYTRB->OPERADOR,;          //10
									QRYTRB->N_FISCAL,;          //11
									QRYTRB->SERIE,;             //12
									QRYTRB->DT_LIB,;            //13
									QRYTRB->PARCIAL,;           //14
									QRYTRB->BLEST,;             //15
									QRYTRB->BLCRED,;            //16
									QRYTRB->PRCVEN,;            //17
									QRYTRB->LOTECTL,;           //18
									QRYTRB->DTVALID,;           //19
									QRYTRB->LOCALI,;            //20
									QRYTRB->VEND,;				//21
									QRYTRB->REC  }) }  ) )      //22

QRYTRB->(dbCloseArea())
DipTela(aItens)									

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณUMAT455A  บAutor  ณMicrosiga           บ Data ณ  04/16/13   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function DipTela(aItens)
Local aSize    	:= MsAdvSize(.F.)
Local aObjects  := {}
Local aPosObj   := {}
Local aOrd      := {}
Local aCab      := {}
Local nPsq		:= 0
Local cKey		:= Space(14)
Local oDlg
Local oScro1
Local oScro2
Local oPsq
Local oKey                    
DEFAULT aItens  := {}

aCab:= {"","Pre-Nota","Pedido","Item","Seq.","Cliente","Nome Cliente","Produto","Descricao","Quant.","Qt.Liberada","Saldo","Sld.Estoque","Operador","Nota Fiscal","Serie NF","Dt.Liberacao","Prc.Venda","Lote","Validade do Lote","Almoxarifado","Vendedor"}

Aadd(aOrd, "Pedido  + Cliente" )
Aadd(aOrd, "Cliente + Pedido" )
Aadd(aOrd, "Produto + Pedido  + Cliente" )

AAdd( aObjects, { 100 , 10, .T., .T.,.T. } )
AAdd( aObjects, { 100 , 80, .T., .T.,.T. } )
AAdd( aObjects, { 100 , 10, .T., .T.,.T. } )

aInfo   := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 1, 1 }
aPosObj := MsObjSize( aInfo, aObjects, .T. )

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Monta a tela para usuario visualizar consulta                  ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
DEFINE MSDIALOG oDlg FROM 0,0 TO aSize[6],aSize[5] TITLE "Status de Pedido de Vendas" Of oMainWnd PIXEL

oScro1 := TScrollBox():New( oDlg, aPosObj[1,1], aPosObj[1,2],aPosObj[1,4], aPosObj[1,3], .T., .T., .T.)
oScro1:Align:= CONTROL_ALIGN_TOP

@ 02,02  MSCOMBOBOX oPsq VAR nPsq ITEMS aOrd WHEN Len(aItens) < 140000 SIZE 80,40 Of oScro1 Pixel
oPsq:nAt:= 1
oPsq:bChange:= {|| DipOrdem(oPsq,@oBrw,@aItens,aOrd,@cKey) }


@ 02,85  MSGET oKey VAR cKey  WHEN Len(aItens) < 140000 OF oScro1 SIZE 100,10 PIXEL
@ 02,187 BUTTON "Pesquisar"  WHEN Len(aItens) < 140000 SIZE 36,12 ACTION A455Psq(oPsq,@oBrw,@aItens,aOrd,@cKey) OF oScro1 PIXEL

oBrw:= TwBrowse():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,4],aPosObj[2,3],,aCab,,oDlg,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
oBrw:Align:= CONTROL_ALIGN_ALLCLIENT
oBrw:SetArray( aItens )
oBrw:bLine := {|| DipLine(aItens,oBrw) }
oScro2 := TScrollBox():New( oDlg, aPosObj[3,1], aPosObj[3,2],aPosObj[3,4], aPosObj[3,3], .T., .T., .T.)
oScro2:Align:= CONTROL_ALIGN_BOTTOM


@ 02,02  BUTTON "Visualiza Pedido" 		SIZE 45,12 ACTION DipPEDIDO(aItens,oBrw) OF oScro2 PIXEL
@ 02,194 BUTTON "Legenda"  				SIZE 45,12 ACTION BrwLegenda(cCadastro,"Legenda",aCoresLeg) OF oScro2 PIXEL
@ 02,241 BUTTON "Sair"                  SIZE 45,12 ACTION oDlg:End() OF oScro2 PIXEL

ACTIVATE MSDIALOG oDlg

Return(.T.)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณUMAT455A  บAutor  ณMicrosiga           บ Data ณ  04/16/13   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function DipLine(aItens,oBrw)
Local aLine      := {}

If (Len(aItens) > 0)
	
	SA1->(dbSetOrder(1))
	SA1->(dbSeek(xFilial("SA1")+SC9->(C9_CLIENTE+C9_LOJA)))
	
	//		            1            2              3          4         5          6           7         8          9          10         11        12                   13         14        15        16          17         18        19         20          21        22       23          24                25       26        27          28
//	aBrwLine := SC9->({/*oObj*/,SC5->C5_PRENOTA,C9_PEDIDO,C9_ITEM,C9_SEQUEN,C9_CLIENTE,SA1->A1_NOME,C9_PRODUTO,"          ",C9_QTDVEN,C9_QTDLIB,C9_SALDO,0                        ,"   ",C9_OPERADO,C9_NFISCAL,C9_SERIENF,C9_DATALIB,C9_PRCVEN,C9_LOTECTL,C9_DTVALID,C9_LOCAL,C9_VEND,SC9->(Recno()),SC5->C5_PARCIAL,C9_BLEST,C9_BLCRED,C9_SEPARAD})

	Do Case 
		Case aItens[oBrw:nat,15] == 'XX' .And. aItens[oBrw:nat,16] == 'XX'
			Aadd( aLine, oVermelho )
					
		Case (aItens[oBrw:nat,14]  == 'N') .And. (aItens[oBrw:nat,15] != '10' .And. aItens[oBrw:nat,16] != '10' .And. aItens[oBrw:nat,16] != '09')
			Aadd( aLine, oPink )
			
		Case (Empty(aItens[oBrw:nat,15]) .And. Empty(aItens[oBrw:nat,16]))
			Aadd( aLine, oVerde )
				
		Case (aItens[oBrw:nat,16]  $ '01/04' )
			Aadd( aLine, oAzul )
			
		Case (aItens[oBrw:nat,16]  == '09' )
			Aadd( aLine, oMarrom )
								
		Case (aItens[oBrw:nat,09] == 0 .And. aItens[oBrw:nat,15] == '02')
			Aadd( aLine, oLaranja )
						
		Case (aItens[oBrw:nat,09]  > 0 .And. aItens[oBrw:nat,15] == '02')
			Aadd( aLine, oBranco )
			
		Otherwise
			Aadd( aLine, oCinza )
	EndCase
	
	SA1->(dbSetOrder(1))
	SA1->(dbSeek(xFilial("SA1")+aItens[oBrw:nat,5]))
	
	SB1->(dbSetOrder(1))
	SB1->(dbSeek(xFilial("SB1")+aItens[oBrw:nat,6]))      
	
	SA2->(dbSetOrder(1))
	SA2->(dbSeek(xFilial("SA2")+aItens[oBrw:nat,5]))
	
	SC5->(dbSetOrder(1))
	SC5->(dbSeek(xFilial("SC5")+aItens[oBrw:nat,2]))   

	
	aAdd(aLine,Transform(aItens[oBrw:nat,1],PesqPict("SC5","C5_PRENOTA")))
	aAdd(aLine,Transform(aItens[oBrw:nat,2],PesqPict("SC9","C9_PEDIDO")))
	aAdd(aLine,Transform(aItens[oBrw:nat,3],PesqPict("SC9","C9_ITEM")))
	aAdd(aLine,Transform(aItens[oBrw:nat,4],PesqPict("SC9","C9_SEQUEN")))
	aAdd(aLine,Transform(aItens[oBrw:nat,5],PesqPict("SC9","C9_CLIENTE")))
  	
  	If SC5->C5_TIPO $ 'D/B'
		aAdd(aLine,Transform(SA2->A2_NOME,PesqPict("SA2","A2_NOME")))  	
  	Else
		aAdd(aLine,Transform(SA1->A1_NOME,PesqPict("SA1","A1_NOME")))
	EndIf                       
	
	aAdd(aLine,Transform(aItens[oBrw:nat,6],PesqPict("SB1","B1_COD")))

	aAdd(aLine,Transform(SB1->B1_DESC,PesqPict("SB1","B1_DESC")))
	
	aAdd(aLine,Transform(aItens[oBrw:nat,7],PesqPict("SC9","C9_QTDVEN")))
	aAdd(aLine,Transform(aItens[oBrw:nat,8],PesqPict("SC9","C9_QTDLIB")))
	aAdd(aLine,Transform(aItens[oBrw:nat,9],PesqPict("SC9","C9_SALDO")))
	aAdd(aLine,Transform(U_SaldSB2(aItens[oBrw:nat,6]),PesqPict("SB2","B2_QATU")))
	
//	aAdd(aLine,Transform(aItens[oBrw:nat,14],PesqPict("SC9","C9_STATUS")))
	aAdd(aLine,Transform(aItens[oBrw:nat,10],PesqPict("SC9","C9_OPERADO")))
	aAdd(aLine,Transform(aItens[oBrw:nat,11],PesqPict("SC9","C9_NFISCAL")))
	aAdd(aLine,Transform(aItens[oBrw:nat,12],PesqPict("SC9","C9_SERIENF")))
	aAdd(aLine,Transform(aItens[oBrw:nat,13],PesqPict("SC9","C9_DATALIB")))
	aAdd(aLine,Transform(aItens[oBrw:nat,17],PesqPict("SC9","C9_PRCVEN")))
	aAdd(aLine,Transform(aItens[oBrw:nat,18],PesqPict("SC9","C9_LOTECTL")))
	aAdd(aLine,Transform(aItens[oBrw:nat,19],PesqPict("SC9","C9_DTVALID")))
	aAdd(aLine,Transform(aItens[oBrw:nat,20],PesqPict("SC9","C9_LOCAL")))
	aAdd(aLine,Transform(aItens[oBrw:nat,21],PesqPict("SC9","C9_VEND")))
//	aAdd(aLine,Transform(aItens[oBrw:nat,28],PesqPict("SC9","C9_SEPARAD")))
	
EndIf

Return aLine
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณA455PEDIDOณ Autor ณ    Alexandro Dias     ณ Data ณ 12.09.01 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ Visualiza o pedido de venda em questao.                    ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function DipPEDIDO(aBrw,oBrw)
Private aRotina := { { OemToAnsi("Pesquisar"),"AxPesqui"  ,0,1},;
{ OemToAnsi("Visual"),"A410Visual",0,2},;
{ OemToAnsi("Incluir"),"A410Inclui",0,3},;
{ OemToAnsi("Alterar"),"A410Altera",0,4,20},;
{ OemToAnsi("Excluir"),"A410Deleta",0,5,21},;
{ OemToAnsi("Cod.barra"),"A410Barra" ,0,3,0},;
{ OemToAnsi("Copia"),"A410Copia",0,3},;
{ OemToAnsi("Dev. Compras"),"A410Devol",0,3},;
{ OemToAnsi("Legenda"),"A410Legend" ,0,3,0} }

dbSelectArea("SC5")
SC5->(dbSetOrder(1))
SC5->(dbGoto(aBrw[oBrw:nAT,22]))

IF !Eof()
	A410Visual("SC5",SC5->(Recno()),2)
EndIF

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณA455Ordem บAutor  ณFabio Rogerio       บ Data ณ  01/24/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRotina para indexar os arrays                               บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function DipOrdem(oPsq,oBrw,aItens,aOrd,cKey)


If (oPsq:nAt == 1) 		//-- "Pedido  + Cliente"
	aItens:= aSort(aItens,,,{|x,y| x[2]+x[5] < y[2]+y[5]})
	cKey:= Space(12)
ElseIf (oPsq:nAt == 2)	//-- "Cliente + Pedido"
	aItens:= aSort(aItens,,,{|x,y| x[5]+x[2] < y[5]+y[2]})
	cKey:= Space(12)
ElseIf (oPsq:nAt == 3)	//-- "Produto + Pedido  + Cliente"
	aItens:= aSort(aItens,,,{|x,y| x[6]+x[2]+x[5] < y[6]+y[2]+y[5]})
	cKey:= Space(27)
EndIf

oBrw:SetArray(aItens)
oBrw:bLine := {|| DipLine(aItens,oBrw) }
oBrw:Refresh()

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณA455PSQ   บAutor  ณFabio Rogerio       บ Data ณ  01/24/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRotina para pesquisa de pedidos no browse.                  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function A455PSQ(oPsq,oBrw,aBrw,aOrd,cKey)
Local nPos:= 0

If (oPsq:nAt == 1) 		//-- "Pedido  + Cliente"
	nPos:= aScan(aBrw,{|x| AllTrim(cKey) $ x[2]+x[5] })
ElseIf (oPsq:nAt == 2)	//-- "Cliente + Pedido"
	nPos:= aScan(aBrw,{|x| AllTrim(cKey) $ x[5]+x[2] })
ElseIf (oPsq:nAt == 3)	//-- "Produto + Pedido  + Cliente"
	nPos:= aScan(aBrw,{|x| AllTrim(cKey) $ x[6]+x[2]+x[5] })
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณVerifica se achou o item para posiciona-lo.ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
nPos:= IIf(nPos > 0,nPos,1)
oBrw:nAt:= nPos

Return
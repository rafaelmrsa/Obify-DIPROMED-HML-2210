#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
#IFNDEF WINDOWS
	#DEFINE PSay Say
#ENDIF               
/*
�����������������������������������������������������������������������������
���Funcao    � DIPR103b � Autor � Reginaldo Borges     � Data � 30/05/17  ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Relacao de pedidos de compra (sintetico/analitico)         ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � DIPR103b                                                   ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Especifico DIPROMED                                        ���
�������������������������������������������������������������������������Ĵ��
�����������������������������������������������������������������������������
*/      
User Function DIPR103b()
Local _xArea    := GetArea()

Private cPerg  	:= U_FPADR( "DIPR103B","SX1","SX1->X1_GRUPO"," " ) //Fun��o criada por Sandro em 19/11/09.

U_DIPPROC(ProcName(0),U_DipUsr()) // JBS 05/10/2005 - Gravando o nome do Programa no SZU

tamanho    := "M"
limite     := 130
titulo     := OemTOAnsi("Relacao de pedidos de compra",72)
cDesc1     := (OemToAnsi("Este relatorio pode ser emitido de forma",72))
cDesc2     := (OemToAnsi("analitica com livro caixa",72))
cDesc3     := (OemToAnsi(" ",72))
aReturn    := {"Bco A4", 1,"Faturamento", 1, 2, 1,"",1}
nomeprog   := "DIPR103B"
nLastKey   := 0
lContinua  := .T.
lEnd       := .F.
li         := 67
wnrel      := "DIPR103B"
M_PAG      := 1
cString    := "SC7"

AjustaSX1(cPerg)             // Verifica perguntas. Se nao existe INCLUI

//Pergunte(cPerg,.T.)     // Solicita parametros

pergunte("FIN140",.T.)

wnrel := SetPrint(cString,wnrel,"FIN140",Titulo,cDesc1,cDesc2,cDesc3,.f.,,.f.,tamanho,,.f.,,,,,)

If nLastKey == 27
	Return
Endif

SetDefault(aReturn,cString)

RptStatus({|lEnd| _RptDetail()},"Imprimindo relacao de pedidos...")

Set device to Screen

//���������������������������������������������������������������������������Ŀ
//� Se em disco, desvia para Spool                                            �
//�����������������������������������������������������������������������������
If aReturn[5] == 1    // Se Saida para disco, ativa SPOOL
	Set Printer TO
	Commit
	ourspool(wnrel)
Endif

MS_FLUSH() 

RestArea(_xArea)

Return
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �DIPR103B  �Autor  �Microsiga           � Data �  06/02/17   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function _RptDetail() 

Local _aPedidos :={}
Local _cPedido  := ""
Local _nValor   := 0
Local cPedi     := ""
Local dEmis     := "  /  /  "
Local dEntr     := "  /  /  "
Local cCodCon   := ""
Local cCond     := ""
Local nTotal    := 0
Local cForn     := ""
Local cLoja     := ""
Local nPrazo    := 0
Local cNomeR    := ""
Local aParc     := {}
Local aCond     := {}
Local nQtdPar   := 0 
Local aTmpAna 	:= {}
Local cAliasPc	:= ""
Local cArqAnaPc	:= ""
Local aTotais   := {{},{},{},{},{},{},{},{},{},{}}
Local aPeriodo 	:= {}
Local aFluxo   	:= {}
Local nDias     := MV_PAR01    
Local nMoeda    := 1  
LOcal lRegua    := .F. 
Local dDatAux	:= CTOD("  /  /  ")
Local aSelFil	:= {}
Local cQueryST	:= ""
Local nTotST	:= 0
Local nTotDiaST	:= 0
Local nTotMesST	:= 0
Private cErros 	  := ""
Private adCompras := {}
Private aCompras  := {}
PRIVATE aVendas	  := {}
PRIVATE adVendas  := {}
PRIVATE aAvFluxo  := {}  

_cTitulo := "Pedidos de COMPRA / Livro Caixa
_cDesc1  := Space(50)+'Periodo: '//+dTOc(mv_par01)+" - "+dTOc(mv_par02)
*            1       10        20        30        40        50        60        70        80        90       100       110        120
*            1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789001234567890
_cDesc2  := "  Emissao      Prv.Entreg.     Forncedor                     Pedido    Condi��o                     Vencimento            Valor"

_nReg    := 0
_nTotal  := 0
_nTotParc:= 0
_nTotMes := 0
_nTotalIm:= 0

Aadd(aSelFil,cFilAnt)

SetRegua(RecCount())

aTmpAna   := CriaTmpAna()
cAliasPc  := aTmpAna[1]
cArqAnaPc := aTmpAna[2]
                               
aPeriodo  := {}
For nX := 1 To nDias           
	dDataTrab := dDataBase+nX-1
	Aadd(aPeriodo, {dDataTrab,0,0,0,0,0,0,0,0,0})
Next

//Fc020Compra(cAliasPc,aTotais,.T.,nMoeda,aPeriodo,cFilDe, cFilAte, cPedidos,lConsDtBase)

If cEmpAnt=="01"
	cFilIni	:= "01"
	cFilFin	:= "04"
ElseIf cEmpAnt=="04"
	cFilIni	:= "01"
	cFilFin	:= "02"
EndIf
	        
fc020Compra(cAliasPc,aTotais,lRegua,nMoeda,aPeriodo,cFilIni,cFilFin,/*cPedidos*/,.F.,,aSelFil)        

dbSelectArea("SC7")
SC7->(dbSetOrder(1))
dbSelectArea(cAliasPc)
(cAliasPc)->(dbGoTop())

While !(cAliasPc)->(Eof())
	
	IncRegua( "Imprimindo: " )
	
	If li > 58
		li := Cabec(_cTitulo,_cDesc1,_cDesc2,nomeprog,tamanho) + 1
	EndIf 
	
    If !Empty(dDatAux) .And. (cAliasPc)->DATAX <> dDatAux 
    	
		@ li,002 PSay "Total "+DtoC(dDatAux)+"  "+Replicate("-",90)+">"
   		@ li,115 PSay Transform(_nTotParc,"@E 999,999,999.99")
		_nTotParc := 0
		
		If Select("TMPST")
			TMPST->(dbCloseArea())
		ENDIF
		cQueryST := " SELECT SUM(C7_ICMSRET)AS VALST, "
		cQueryST += " C7_FILIAL, C7_NUM, C7_DENTREG "
		cQueryST += " FROM " + RetSqlName("SC7")+" SC7 "
		cQueryST += " INNER JOIN " + RetSqlName("SA2")+" SA2 ON "
		cQueryST += " C7_FORNECE = A2_COD AND C7_LOJA = A2_LOJA "
		cQueryST += " AND A2_EST <> 'SP' "
		cQueryST += " AND SA2.D_E_L_E_T_ = ' ' "
		cQueryST += " WHERE C7_FILIAL between '"+cFilIni+"' and '"+cFilFin+"' "
		cQueryST += " AND SC7.D_E_L_E_T_ = ' ' "
		cQueryST += " AND C7_QUJE < C7_QUANT"
		cQueryST += " AND C7_RESIDUO <> 'S'"
		cQueryST += " AND C7_ICMSRET > 0 "
		cQueryST += " AND C7_DENTREG ='"+DTOS(dDatAux) +"' "
		cQueryST += " GROUP by C7_FILIAL,C7_NUM,C7_DENTREG "
		cQueryST := ChangeQuery(cQueryST)
		dbUseArea(.T., "TOPCONN", TCGenQry(,,cQueryST), 'TMPST', .F., .T.)
		TMPST->(dbGoTop())
		IF TMPST->(!Eof())
			li+=2
			@ li,002 PSay "ICMS ST PREVISTO  "+DtoC(dDatAux)//+"  "+Replicate("-",90)
			While TMPST->(!Eof())
					li++
					dbSelectArea("SC7")
					SC7->(dbSetOrder(1))
					dbSeek(TMPST->C7_FILIAL+TMPST->C7_NUM)
					@ li,002 PSay DtoC(SC7->C7_EMISSAO) 					// emissao
					@ li,015 PSay STOD(TMPST->C7_DENTREG) 			   		// entrega
					@ li,031 PSay SC7->C7_FORNECE+"-"+POSICIONE("SA2",1,xFilial("SA2")+SC7->(C7_FORNECE+C7_LOJA),"A2_NREDUZ")  // Fornecedor
					@ li,061 PSay TMPST->C7_NUM 			 				// Pedido
					@ li,071 PSay StrTran(POSICIONE("SE4",1,xFilial("SE4")+SC7->C7_COND,"E4_DESCRI"),",","/")
//					@ li,100 PSay DtoC((cAliasPc)->DATAX)                   		// Data Vencimento
					@ li,115 PSay Transform(TMPST->VALST, "@E 999,999,999.99") 			// Valor da ST
					nTotDiaST += TMPST->VALST
					TMPST->(dbSkip())
			EndDo
			TMPST->(dbCloseArea())
			li++
			@ li,002 PSay "Total ST "+DtoC(dDatAux)+"  "+Replicate("-",87)+">"
			@ li,115 PSay Transform(nTotDiaST,"@E 999,999,999.99")
			nTotMesST 	+= nTotDiaST
			nTotST 		+= nTotDiaST
			nTotDiaST 	:= 0
		EndIf
    	li+=2
	EndIf
	
	
    If !Empty(dDatAux) .And. Month((cAliasPc)->DATAX) <> Month(dDatAux)
    	li--
    	@ li,002 PSay "Total do M�s "+StrZero(Month(dDatAux),2)+"  "+Replicate("-",89)+">"
   		@ li,115 PSay Transform(_nTotMes,"@E 999,999,999.99")
    	_nTotMes := 0
    	
		li++
		@ li,002 PSay "Total de ST no M�s"+StrZero(Month(dDatAux),2)+"  "+Replicate("-",87)+">"
		@ li,115 PSay Transform(nTotMesST,"@E 999,999,999.99")
		nTotMesST 	:= 0
		li+=2
	EndIf
		
	@ li,002 PSay DtoC((cAliasPc)->EMISSAO) 									// emissao
	If SC7->(dbSeek((cAliasPc)->CHAVE))
		@ li,015 PSay SC7->C7_DENTREG 			   								// entrega
		@ li,031 PSay (cAliasPc)->CLIFOR+"-"+POSICIONE("SA2",1,xFilial("SA2")+SC7->(C7_FORNECE+C7_LOJA),"A2_NREDUZ")  // Fornecedor
	Else
		@ li,015 PSay DtoC(StoD(""))			   								// entrega
		@ li,031 PSay (cAliasPc)->CLIFOR+"-"+Left((cAliasPc)->NomCliFor,20)  	// Fornecedor
	EndIf
	@ li,061 PSay (cAliasPc)->NUMERO 			 								// Pedido
	@ li,071 PSay StrTran(POSICIONE("SE4",1,xFilial("SE4")+SC7->C7_COND,"E4_DESCRI"),",","/")
	@ li,100 PSay DtoC((cAliasPc)->DATAX)                           			// Data Vencimento
	@ li,115 PSay Transform((cAliasPc)->SALDO, "@E 999,999,999.99") 			// Valor da parcela //Transform(_aPedidos[I,6], "@E 999,999,999.99") // Total por pedido

	_nTotal   += (cAliasPc)->SALDO
	_nTotParc += (cAliasPc)->SALDO
	_nTotMes  += (cAliasPc)->SALDO
	dDatAux   := (cAliasPc)->DATAX 
	
	li++	
		
	(cAliasPc)->(dbSkip())
EndDo                    

(cAliasPc)->(DbCloseArea())
fErase(cArqAnaPc+GetDbExtension())

If li <> 66

	If li > 58
		li := Cabec(_cTitulo,_cDesc1,_cDesc2,nomeprog,tamanho) + 1
	EndIf 

	@ li,002 PSay "Total "+DtoC(dDatAux)+"  "+Replicate("-",90)+">"
	@ li,115 PSay Transform(_nTotParc,"@E 999,999,999.99")
	li++
	
   	@ li,002 PSay "Total do M�s "+StrZero(Month(dDatAux),2)+"  "+Replicate("-",89)+">"
	@ li,115 PSay Transform(_nTotMes,"@E 999,999,999.99")
   	li+=2

	@ li,000 PSay Replic("*",Limite)
	li++

	@ li,100 PSay 'Total de ST:'
	@ li,115 PSay Transform(nTotST,"@E 999,999,999.99")

	li++

	@ li,100 PSay 'Total Geral:'
	@ li,115 PSay Transform(_nTotal,"@E 999,999,999.99")
	li++

	@ li,000 PSay Replic("*",Limite)
	li+=2
	
EndIf


Return(.T.)                                                                
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �CriaTmpAna�Autor  �Claudio D. de Souza � Data �  08/10/01   ���
�������������������������������������������������������������������������͹��
���Desc.     � Criar os arquivos analiticos do Fluxo de Caixa             ���
���          � Parametro:                                                 ���
���          � nArquivo   Numero do arquivo que sera criado               ���
���          � Retorno:                                                   ���
���          � aRet                                                       ���
���          � aRet[1] - Alias do arquivo temporario							  ���
���          � aRet[2] - Nome do arquivo temporario                       ���
�������������������������������������������������������������������������͹��
���Uso       � FINC021                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function CriaTmpAna()
LOCAL aCposAna 	:= {}
LOCAL cAliasAna := ""
LOCAL cArqAna 	:= ""
LOCAL cChave 	:= ""

cChave := "Dtos(DataX)+Numero"

aCposAna := {}
Aadd( aCposAna, {"Periodo"	 ,"N",12				 		,0 })
Aadd( aCposAna, {"DATAX"  	 ,"D",08				 		,0 })
Aadd( aCposAna, {"NUMERO" 	 ,"C",TamSx3("C7_NUM")[1]		,0 })
Aadd( aCposAna, {"EMISSAO"	 ,"D",8							,0 })
Aadd( aCposAna, {"CLIFOR" 	 ,"C",TamSx3("E5_CLIFOR")[1]	,0 })
Aadd( aCposAna, {"TIPO"   	 ,"N",TamSx3("C7_TIPO")[1]		,0 })
Aadd( aCposAna, {"ITEM"   	 ,"C",TamSx3("C7_ITEM")[1]		,0 })
Aadd( aCposAna, {"NomCliFor" ,"C",TamSx3("A1_NOME")[1]		,0 })
Aadd( aCposAna, {"PRODUTO"	 ,"C",TamSx3("C7_PRODUTO")[1]	,0 })
Aadd( aCposAna, {"SALDO"  	 ,"N",Max(TamSx3("E1_SALDO")[1]	,TamSx3("E2_SALDO")[1]) , TamSx3("E1_SALDO")[2] })
Aadd( aCposAna, {"CHAVE"  	 ,"C"							,40,0 })
Aadd( aCposAna, {"Apelido"   ,"C"							,10,0 })
Aadd( aCposAna, {"VALPAGANT" ,"N"							,12,4 })

cAliasAna := "cArqAnaPc"  // Alias do arquivo analitico

Aadd( aCposAna, { "CampoNulo", "C", 1, 0 } )
Aadd( aCposAna, { "Flag"     , "L", 1, 0 } )

cArqAna := CriaTrab(aCposAna,.T.)
dbUseArea(.T.,__LocalDriver,cArqAna,cAliasAna,.F.)
IndRegua ( cAliasAna,cArqAna,cChave,,,"Selecionando Registros...")
		   
Return {cAliasAna,cArqAna}
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �DIPR103B  �Autor  �Microsiga           � Data �  06/02/17   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function AjustaSX1(cPerg)
_sAlias := Alias()
dbSelectArea("SX1")
dbSetOrder(1)

aRegs:={}

//------------ Grupo/Ordem/Pergunta/PERGING/PERGESP/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05/F3

AADD(aRegs,{cPerg,"01","De data                    ?","","","mv_ch1","D",8,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","",""})
AADD(aRegs,{cPerg,"02","Ate data                   ?","","","mv_ch2","D",8,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","",""})
AADD(aRegs,{cPerg,"03","De Fornecedor              ?","","","mv_ch3","C",6,0,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","SA2"})
aAdd(aRegs,{cPerg,"04","Ate Fornecedor             ?","","","mv_ch4","C",6,0,0,"G","","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","","SA2"})
aAdd(aRegs,{cPerg,"05","Pedido/Bonificacao/Amostra ?","","","mv_ch6","N",1,0,2,"C","","mv_par05","Todos","","","","","Pedido","","","","","Bonificacao","","","","","Amostra","","","",""})
aAdd(aRegs,{cPerg,"06","Lista Quais                ?","","","mv_ch7","N",1,0,2,"C","","mv_par06","Todos","","","","","Em Aberto","","","","","Residuos","","","","","Atendidos","","","","","Atendidos+Parcial Entreg","","","",""})
aAdd(aRegs,{cPerg,"07","Lista Quais Tipos          ?","","","mv_ch8","N",1,0,1,"C","","mv_par07","Pedido Compra","","","","","Aut.de Entrega","","","","","Ambos","","","",""})
aAdd(aRegs,{cPerg,"08","Imprime Pedidos            ?","","","mv_ch9","N",1,0,1,"C","","mv_par08","Liberados","","","","","Bloqueados","","","","","Ambos","","","",""})
aAdd(aRegs,{cPerg,"09","Ordenar Previsao Entrega   ?","","","mv_chA","N",1,0,1,"C","","MV_PAR09","Sim","","","","","Nao","","","","","","","","",""})
AADD(aRegs,{cPerg,"10","Previsao Entrega De        ?","","","mv_chB","D",8,0,0,"G","","mv_par10","","","","","","","","","","","","","","","","","","","","","","","","",""})
AADD(aRegs,{cPerg,"11","Previsao  Entrega Ate      ?","","","mv_chC","D",8,0,0,"G","","mv_par11","","","","","","","","","","","","","","","","","","","","","","","","",""})
AADD(aRegs,{cPerg,"12","Vencimento De              ?","","","mv_chD","D",8,0,0,"G","","mv_par12","","","","","","","","","","","","","","","","","","","","","","","","",""})
AADD(aRegs,{cPerg,"13","Vencimento Ate             ?","","","mv_chE","D",8,0,0,"G","","mv_par13","","","","","","","","","","","","","","","","","","","","","","","","",""})



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
///////////////////////////////////////////////////////////////////////////

#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³NOVO4     ºAutor  ³Jailton B Santos-JBSº Data ³ 22/01/2010  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Demonstra os prazos de validacao dos lotes de cada produto º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Especifico Estoque - Dipromed                              º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function DIPR067()

Local cDesc1       := "De acordo com a data informada Traz os produto com "
Local cDesc2       := "validade ate esta data. Demonstra os prazos.       "
Local cDesc3       := "Validade de Produtos a Vencer"
Local cPict        := ""
Local cTitulo      := "Produtos A Vencer  Ate "
Local nLin         := 80

Local Cabec1       := ""
Local Cabec2       := ""
Local imprime      := .T.
Local aOrd         := {}
Local cQuery       := ""
//Local nRecEZB      := SZB->( Recno() )
//Local nOrdEZB      := SZB->( IndexOrd() )

Private cPerg      := Padr("DIPR067",10)
Private lEnd       := .F.
Private lAbortPrint:= .F.
Private CbTxt      := ""
Private limite     := 220
Private tamanho    := "G"
Private nomeprog   := "DIPR067"
Private nTipo      := 15
Private aReturn    := { "Zebrado", 1, "Administracao", 1, 2, 1, "", 1}
Private nLastKey   := 0
Private cbtxt      := Space(10)
Private cbcont     := 00
Private CONTFL     := 01
Private m_pag      := 01
Private wnrel      := "DIPR067"

Private cString := "SB1"

fCriaSx1()

Pergunte(cPerg,.F.)

wnrel := SetPrint(cString,NomeProg,cPerg,@cTitulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)

If nLastKey == 27
	Return
Endif
//        "1       10        20        30        40        50        60        70        80        90       100       110       120       130       140       150       160       170       180       190       200       210       220
//        "1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
Cabec1 := "Codigo   Descricao                       Nome do               Numero     Data de   U.M.  Quantidade       Custo        Total   Observacao do Setor de                   Observacao Responsavel                    Valid LOC"
Cabec2 := "Produto  Do Produto                      Fornecedor            Do Lote    Validade           Do Lote    Unitario                Compras                                  Tecnico                                   Dias     "
//        "XXXXXX   123456789012345678901234567890  XXXXXXXXXXXXXXXXXXXX  1234567890 99/99/99   XX  XXX,XXX,XXX  XXX,XXX.XXXX XXX,XXX.XXXX 1234567890123456789012345678901234567890 1234567890123456789012345678901234567890  99999  99"
//                                                                                                  999,999,999  999,999.99   999,999.99

cTitulo := "Produtos A Vencer  Ate " + dToc(Mv_PAR01)+". (Fornecedor de '"+AllTrim(Mv_PAR02)+"' Ate '"+AllTrim(Mv_PAR03)+"', Produto de '"+AllTrim(Mv_PAR06)+"' Ate '"+AllTrim(Mv_PAR07)+"', Local de '"+AllTrim(Mv_PAR04)+"' Ate '"+AllTrim(Mv_PAR05)+"' )"

SetDefault(aReturn,cString)

If nLastKey == 27
	Return
Endif

nTipo := If(aReturn[4]==1,15,18)
RptStatus({|| RunReport(Cabec1,Cabec2,cTitulo,nLin) },cTitulo)

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³RunReport()ºAutor ³Jailton B Santos-JBSº Data ³ 22/01/2010  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Gera as Informacoes e Imprime o relatorio.                 º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Especifico Estoque - Dipromed                              º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function RunReport(Cabec1,Cabec2,cTitulo,nLin)

Local nId       := 00
Local nIdX      := 00
Local nMlCt01   := 00
Local nMlCt02   := 00
Local nTamLin   := 35
Local mObsTroca := """
Local mObsTecni := ""
Local cPicB8Saldo:= AvSx3("B8_SALDO",6)
Local cPicB1CusDi:= AvSx3("B1_CUSDIP",6)
Local lImprimiu := .F.
Local cPonto    := ""
Local nProc     := 0 
Local nSubTVenc := 0 // JBS  29/01/2010
Local nSubTaVenc:= 0 // JBS  29/01/2010
Local nSubTForne:= 0 // MCVN 07/01/2011    
Local cFornec   := ""// MCVN 07/01/2011    
Local cNomeForn := ""// MCVN 10/01/2011    
Local aFornec   := {}// MCVN 07/01/2011    

//-------------------------------------------------------------
// Executa a query para buscar as informacoes do lote
//-------------------------------------------------------------
If !fQuery()
	QRY->( DbCloseArea() )
	Return(.F.)
EndIf

QRY->( DbGotop() )
                                                               
Do While QRY->( !EOF() )                                       

	If cFornec = "" // Valorizando pela primeira vez a variável
		cFornec   := QRY->A2_COD	
		cNomeForn := QRY->A2_NREDUZ	
	Endif
	
	If nProc < 1
		nProc := 500
		SetRegua(nProc)
	EndIf
	
	IncRegua()
	nProc--
	
	If nLin > 55
		If lImprimiu
			Roda(1,"",Tamanho)
		EndIf
		
		Cabec(cTitulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
		nLin := 10 
		
	EndIf    
	//--------------------------------------------------------------------------
    // JBS 28/01/2010 - (A2_OBSTROC + B8_OBSTRC)
    // Cacatena a observacao do cadastro do fornecedor com a observacao 
    // encontrada no lote do produto.  
	//--------------------------------------------------------------------------
	mObsTroca := ""

	If Len(AllTrim(QRY->A2_OBSTROC)) > 0 // .and. Len(AllTrim(QRY->B8_OBSTROC)) > 0
	    For nIdX := 1 to len(AllTrim(QRY->A2_OBSTROC))
	         mObsTroca += MemoLine(AllTrim(QRY->A2_OBSTROC),nTamLin, nIdX)
	    Next nIdX
	EndIf
	   
	mObsTroca += AllTrim(QRY->B8_OBSTROC)               
	nMlCt01   := MlCount(mObsTroca, nTamLin)
	
	mObsTecni := AllTrim(QRY->B8_OBSTEC)
	nMlCt02   := MlCount (mObsTecni, nTamLin)    
	
	If MV_PAR08 == 3  // Ordena por fornecedor e salta páginas
	    If	cFornec <> QRY->A2_COD
		    nLin++
			@ nLin,080 psay "Total por Fornecedor"
			@ nLin,111 psay nSubTForne Picture "@e 999,999,999.99"			
			AAdd( aFornec,{cFornec,cNomeForn,nSubTForne} ) 
			nSubTForne := 0
		    cFornec    := QRY->A2_COD
		    cNomeForn  := QRY->A2_NREDUZ
	    	Roda(1,"",Tamanho)
			Cabec(cTitulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
			nLin := 10		
		Endif
	Endif	
	
	@ nLin,000 psay QRY->B1_COD
	@ nLin,010 psay SubStr(QRY->B1_DESC,1,30)
	@ nLin,042 psay QRY->A2_COD
	@ nLin,064 psay QRY->B8_LOTECTL
	@ nLin,075 psay QRY->B8_DTVALID
	@ nLin,086 psay QRY->B1_UM
	@ nLin,090 psay QRY->B8_SALDO  Picture "@e 999,999,999"   // cPicB8Saldo
	@ nLin,103 psay QRY->B1_CUSDIP Picture  "@e 999,999.99"   // cPicB1CusDi
	@ nLin,116 psay QRY->B8_SALDO * QRY->B1_CUSDIP Picture "@e 999,999.99" // cPicB1CusDi
	
	If nMlCt01 > 0
		@ nLin,129 psay AllTrim(MemoLine(mObsTroca,nTamLin, 1))
	EndIf
	
	If nMlCt02 > 0
		@ nLin,170 psay AllTrim(MemoLine(mObsTecni,nTamLin, 1))
	EndIf
	
	@ nLin,211 psay QRY->B8_DTVALID-dDataBase Picture "@e 99,999"     
	@ nLin,219 psay QRY->B8_LOCAL Picture "@e 99"     
	
	nLin++

	If nLin > 55 
		Roda(1,"",Tamanho)
		Cabec(cTitulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
		nLin := 10
	EndIf
	//-------------------------------------------------------------------- 
    // Impressao da Segunda Linha
	//-------------------------------------------------------------------- 
	@ nLin,009 psay AllTrim(SubStr(QRY->B1_DESC,31,30))
	@ nLin,041 psay QRY->A2_NREDUZ

	If nMlCt01 > 1 .or. nMlCt02 > 1

		For nId := 2 to Max(nMlCt01,nMlCt02)
			If nLin > 55
				Roda(1,"",Tamanho)
				Cabec(cTitulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
				nLin := 10
			EndIf
			If nMlCt01 >= nId
				@ nLin,128 psay AllTrim(MemoLine(mObsTroca,nTamLin, nId))
			EndIf
			If nMlCt02 >= nId
				@ nLin,169 psay AllTrim(MemoLine(mObsTecni,nTamLin, nId))
			EndIf
			nLin ++
		Next
	Else 
  		nLin++
	EndIf
	nLin++                                    
	//-------------------------------------------------------------------- 
	// Acumula os Subtotais a Vencer e Vencidos
	//-------------------------------------------------------------------- 
	If QRY->B8_DTVALID-dDataBase > 0
	    nSubTaVenc += (QRY->B8_SALDO * QRY->B1_CUSDIP)
	Else 
	    nSubTVenc += (QRY->B8_SALDO * QRY->B1_CUSDIP)
	EndIf    
	nSubTFornec +=(QRY->B8_SALDO * QRY->B1_CUSDIP) // Total por fornecedor
	lImprimiu := .T.
	QRY->( DbSkip() )

EndDo
//--------------------------------------------------------------------------
// { JBS 29/01/2010 - Impressao de Totais  
//--------------------------------------------------------------------------


If MV_PAR08 == 3

    nLin++
	@ nLin,080 psay "Total por Fornecedor"
	@ nLin,111 psay nSubTForne Picture "@e 999,999,999.99"			
	AAdd( aFornec,{cFornec,cNomeForn,nSubTForne} ) 
	
	Roda(1,"",Tamanho)
	Cabec("RESUMO  POR FORNECEDOR - "+cTitulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
	nLin := 10

	//Ordena por valor
	aSort( aFornec ,,, {|a,b| a[3] > b[3] } )
	//Imprime total por vendedor resumido              
	For i := 1 to Len(aFornec)                                   
		If nLin > 50
			Roda(1,"",Tamanho)
			Cabec("RESUMO  POR FORNECEDOR - "+cTitulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
			nLin := 10
		EndIf
		@ nLin,080 psay aFornec[i,1] + " - " + aFornec[i,2]
		@ nLin,111 psay aFornec[i,3]  Picture "@e 999,999,999.99"
		nLin++
	Next
	nLin++  
	nLin++  
	@ nLin,111 psay Replicate("-",15)
	nLin++  
	nLin++  
Else 
	If nLin > 50
		Roda(1,"",Tamanho)
		Cabec(cTitulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
		nLin := 10
	EndIf
Endif

nLin++  

@ nLin,080 psay "Sub-Total Vencidos"
@ nLin,111 psay nSubTVenc  Picture "@e 999,999,999.99"
nLin++
@ nLin,080 psay "Sub-Total A Vencer"
@ nLin,111 psay nSubTaVenc Picture  "@e 999,999,999.99" 

nLin++
@ nLin,111 psay Replicate("-",15)

nLin++
@ nLin,080 psay "Total Geral"
@ nLin,111 psay nSubTaVenc + nSubTVenc Picture "@e 999,999,999.99"
//--------------------------------------------------------------------------
// }  JBS 29/01/2010 - 
//--------------------------------------------------------------------------
QRY->( DbCloseArea() )

Set Device To Screen

If aReturn[5]==1
	dbCommitAll()
	Set Printer To
	OurSpool(wnrel)
Endif

MS_FLUSH()

Return(.t.)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³fCriaSx1()ºAutor  ³Jailton B Santos-JBSº Data ³ 22/01/2010  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Verifica se existe o grupo de perguntas, se nao existir criaº±±
±±º          ³automaticamente no Banco de Dados.                          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Especifico Estoque - Dipromed                              º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function fCriaSx1()

Local nId   := 0
Local aPerg := {}

SX1->( DbSetOrder(1) )

aadd(aPerg,{"01","Validade a Vencer até ","mv_ch1","D",08,00,00,"G","" ,"mv_par01","", "", "", ""})
aadd(aPerg,{"02","Fornecedor De          ","mv_ch2","C",06,00,00,"G","" ,"mv_par02","", "", "", ""})
aadd(aPerg,{"03","Fornecedor Ate         ","mv_ch3","C",06,00,00,"G","" ,"mv_par03","", "", "", ""})
aadd(aPerg,{"04","Local de               ","mv_ch4","C",02,00,00,"G","" ,"mv_par04","", "", "", ""})
aadd(aPerg,{"05","Local de               ","mv_ch5","C",02,00,00,"G","" ,"mv_par05","", "", "", ""})
aadd(aPerg,{"06","Produto de             ","mv_ch6","C",15,00,00,"G","" ,"mv_par06","", "", "", ""})
aadd(aPerg,{"07","Produto Ate            ","mv_ch7","C",15,00,00,"G","" ,"mv_par07","", "", "", ""})
aadd(aPerg,{"08","Classificar por        ","mv_ch8","N",01,00,02,"C","" ,"mv_par08","", "Produto", "Validade" , "Fornecedor"})

For nId := 01 to len(aPerg)
	
	If SX1->(!DbSeek(cPerg + aPerg[nId][01] , .t.) )
		
		SX1->( Reclock("SX1",.t.) )
		
		SX1->X1_GRUPO   := cPerg
		SX1->X1_ORDEM   := aPerg[nId][01]
		SX1->X1_PERGUNT := aPerg[nId][02]
		SX1->X1_VARIAVL := aPerg[nId][03]
		SX1->X1_TIPO    := aPerg[nId][04]
		SX1->X1_TAMANHO := aPerg[nId][05]
		SX1->X1_DECIMAL := aPerg[nId][06]
		SX1->X1_PRESEL  := aPerg[nId][07]
		SX1->X1_GSC     := aPerg[nId][08]
		SX1->X1_VALID   := aPerg[nId][09]
		SX1->X1_VAR01   := aPerg[nId][10]
		SX1->X1_F3		:= aPerg[nId][11]
		SX1->X1_DEF01   := aPerg[nId][12]
		SX1->X1_DEF02   := aPerg[nId][13]
		SX1->X1_DEF03   := aPerg[nId][14]
		
		SX1->( MsUnLock() )
		
	EndIf
	
Next nId
Return(.T.)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³fQuery()  ºAutor  ³Jailton B Santos-JBSº Data ³ 22/01/2010  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Desenvolve a query para trazer as informacoes de cada pro- º±±
±±º          ³ duto.                                                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Especifico Estoque - Dipromed                              º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function fQuery()

Local lRet := .T.
Local cArqExcell := "\Excell-DBF\"+U_DipUsr()+"-DIPR067"
Local _aCampos	 := {}

Private cDestino := "C:\EXCELL-DBF\"

/*
aAdd(_aCampos,{"B1_COD","C"})
aAdd(_aCampos,{"B1_DESC","C"})
aAdd(_aCampos,{"A2_COD","C"})
aAdd(_aCampos,{"A2_LOJA","C"})
aAdd(_aCampos,{"A2_NREDUZ","C"})
aAdd(_aCampos,{"B1_UM","C"})
aAdd(_aCampos,{"B1_CUSDIP","N"})
aAdd(_aCampos,{"B8_LOCAL","C"})
aAdd(_aCampos,{"B8_SALDO","N"})
aAdd(_aCampos,{"B8_LOTECTL","C"})
aAdd(_aCampos,{"B8_DTVALID","D"})
aAdd(_aCampos,{"A2_OBSTROC","C"})
aAdd(_aCampos,{"B8_OBSTROC","C"})
aAdd(_aCampos,{"B8_OBSTEC","C"})
*/

cQuery := "  SELECT SB1.B1_COD, "
cQuery += "         SB1.B1_DESC, "
cQuery += "         SA2.A2_COD, "
cQuery += "         SA2.A2_LOJA, "
cQuery += "         SA2.A2_NREDUZ, "    
cQuery += "         SB1.B1_UM, "
cQuery += "         SB1.B1_CUSDIP, "
cQuery += "         SB8.B8_LOCAL, "
cQuery += "         SUM(SB8.B8_SALDO) B8_SALDO,"
cQuery += "         SB8.B8_LOTECTL, "
cQuery += "         SB8.B8_DTVALID, "
cQuery += "         SA2.A2_OBSTROC, "
cQuery += "         SB8.B8_OBSTROC, "
cQuery += "         SB8.B8_OBSTEC "

cQuery += "  FROM " + RetSqlName('SB1') + " SB1 "

cQuery += "  INNER JOIN " + RetSqlName('SA2') + " SA2  ON SA2.A2_FILIAL = '" + xFilial('SA2')+ "' "
cQuery += "                        AND SA2.A2_COD  = SB1.B1_PROC "
cQuery += "                        AND SA2.A2_LOJA = SB1.B1_LOJPROC "
cQuery += "                        AND SA2.D_E_L_E_T_ = '' "

cQuery += "  INNER JOIN " + RetSqlName('SB8') + " SB8  ON SB8.B8_FILIAL = '" + xFilial('SB8')+ "' "
cQuery += "                        AND SB8.B8_PRODUTO = SB1.B1_COD "
cQuery += "                        AND SB8.B8_SALDO-B8_QACLASS > 0  "
cQuery += "                        AND SB8.B8_LOCAL  BETWEEN '" + MV_PAR04 + "' AND '" + MV_PAR05 + "' "
cQuery += "                        AND SB8.B8_DTVALID <= '" + dTos(MV_PAR01) + "' "
cQuery += "                        AND SB8.B8_SALDO <> 0 " //Rafael Moraes Rosa - 02/02/2023
cQuery += "                        AND SB8.D_E_L_E_T_ = '' "

cQuery += "  WHERE B1_FILIAL = '" + xFilial('SB1')+ "' "
cQuery += "    AND SB1.D_E_L_E_T_ = '' "
cQuery += "    AND SB1.B1_PROC BETWEEN '" + MV_PAR02 + "' AND '" + MV_PAR03 + "' "
cQuery += "    AND SB1.B1_COD  BETWEEN '" + MV_PAR06 + "' AND '" + MV_PAR07 + "' "

 //Rafael Moraes Rosa - 02/02/2023 - INICIO
IF !Empty(GETMV("ES_TPPRREL"))
	cQuery += "    AND SB1.B1_TIPO  IN (" + GETMV("ES_TPPRREL") + ") "
ENDIF
 //Rafael Moraes Rosa - 02/02/2023 - FIM

If (Upper(U_DipUsr()) $ "MCANUTO/DDOMINGOS/VQUEIROZ/VEGON/RBORGES") 
	If MsgYesNo("Deseja filtrar as incubadoras para verificar o valor?","Aten‡„o")
		cQuery += "    AND SB1.B1_COD  NOT IN ('011138','011316','011003','011197','011185','011151','011243','011250','011007') "
	Endif
Endif                                                                             

cQuery += "  GROUP BY SB1.B1_COD, "
cQuery += "           SB1.B1_DESC, "
cQuery += "           SA2.A2_COD, "
cQuery += "           SA2.A2_LOJA, "
cQuery += "           SA2.A2_NREDUZ, "
cQuery += "           SB1.B1_UM, "                                                    
cQuery += "           SB1.B1_CUSDIP, "
cQuery += "           SB8.B8_LOCAL, "
cQuery += "           SB8.B8_LOTECTL, "
cQuery += "           SB8.B8_DTVALID, "
cQuery += "           SA2.A2_OBSTROC, "
cQuery += "           SB8.B8_OBSTROC, "
cQuery += "           SB8.B8_OBSTEC, "
cQuery += "           SB8.B8_DTVALID "

If MV_PAR08 == 1 				// 1 -> Por ordem de Produto, Validacao e Lote
	cQuery += "  ORDER BY SB1.B1_COD,SB8.B8_DTVALID, SB8.B8_LOTECTL "
ElseIf MV_PAR08 == 2            // 2 -> Por ordem de Validacao, Produto e Lote
	cQuery += "  ORDER BY SB8.B8_DTVALID,SB1.B1_COD, SB8.B8_LOTECTL "
Else				            // 2 -> Por ordem de Fornecedor, Validade, Produto e Lote
	cQuery += "  ORDER BY SA2.A2_NREDUZ, SB8.B8_DTVALID,SB1.B1_COD, SB8.B8_LOTECTL "	
EndIf

If Select('QRY') > 0
	QRY->( DbCloseArea() )          
EndIf

TcQuery cQuery New Alias "QRY"

TCSetField("QRY","B8_SALDO"  ,"N",15,02)
TCSetField("QRY","B1_CUSDIP" ,"N",15,02)
TCSetField("QRY","B8_DTVALID","D",08,00)

If QRY->(BOF().and.EOF() )
	lRet := .F.
	Aviso('Atenção','Não encontrado dados que satifaçam os parametros informados',{'Ok'})
Else

	DbSelectArea("QRY")
	_aCampos := QRY->(DbStruct())
	nTotReg := Contar("QRY","!Eof()")
	QRY->(dbGotop())	
	ProcRegua(nTotReg)	
	aCols := Array(nTotReg,Len(_aCampos))
	nColuna := 0
	nLinha := 0
	While QRY->(!Eof())
		nLinha++
		IncProc(OemToAnsi("Gerando planilha excel..."))
		For nColuna := 1 to Len(_aCampos)
			aCols[nLinha][nColuna] := &("QRY->("+_aCampos[nColuna][1]+")")			
		Next nColuna
		QRY->(dbSkip())	
	EndDo
	u_GDToExcel(_aCampos,aCols,Alltrim(FunName()))
	
	//COPY TO &cArqExcell VIA "DBFCDX"
	//MakeDir(cDestino) // CRIA DIRETÓRIO CASO NÃO EXISTA
	//CpyS2T(cArqExcell+".dbf",cDestino,.T.) // COPIA ARQUIVO PARA MAQUINA DO USUÁRIO
EndIf

Return(lRet)
//   SELECT SB1.B1_COD,          SB1.B1_DESC,          SA2.A2_NREDUZ,          SB1.B1_UM,          SB1.B1_CUSDIP,          SB8.B8_LOCAL,          SB8.B8_SALDO,          SB8.B8_LOTECTL,          SB8.B8_DTVALID   FROM SB1010 SB1   INNER JOIN SA2010 SA2  ON SA2.A2_FILIAL = '  '                         AND SA2.A2_COD  = SB1.B1_PROC                         AND SA2.A2_LOJA = SB1.B1_LOJPROC                         AND SA2.D_E_L_E_T_ = ''   INNER JOIN SB8010 SB8  ON SB8.B8_FILIAL = '04'                         AND SB8.B8_PRODUTO  = SB1.B1_COD                         AND SB8.B8_LOCAL  BETWEEN '00' AND 'zz'                         AND SB8.B8_DTVALID >= '20101231'                         AND SB8.D_E_L_E_T_ = ''   WHERE B1_FILIAL = '  '     AND SB1.D_E_L_E_T_ = ''     AND SB1.B1_PROC BETWEEN '000000' AND 'zzzzzz'     AND SB1.B1_COD  BETWEEN '000000000000000' AND 'zzzzzzzzzzzzzzz'   ORDER BY SB8.B8_DTVALID,SB1.B1_COD, SB8.B8_LOTECTL

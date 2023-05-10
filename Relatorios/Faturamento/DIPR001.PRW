#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"

/*====================================================================================\
|Programa  | DIPR001.PRW  | Autor  | Alexandro Dias          | Data | 25/01/2002      |
|=====================================================================================|
|Descrição | Gera um relatorio do faturamento por operador.                           |
|          |                                                                          |
|=====================================================================================|
|Data      | Autor	   |        		       Histórico                              |
|-------------------------------------------------------------------------------------|
|04/03/15  | RBorges   | Deixar o valor total igual aos demais relatórios.            |
|-------------------------------------------------------------------------------------|
|          |           | 														      |
|-------------------------------------------------------------------------------------|
|          |           | 														      |
|-------------------------------------------------------------------------------------|
|04/03/15  | RBorges   | Alteração de toda a estrutura do relatorio                   |
|=====================================================================================|
|Uso       | Vendas																	  |
\====================================================================================*/
     
User Function DIPR001()
//--------------------------------------------------------------------------------------------------
// RBorges - Tratamento para trabalhar com as duas versoes do programa:
//--------------------------------------------------------------------------------------------------
// -> fDIPR001(): Versao desenvolvida para processar por filial.
//--------------------------------------------------------------------------------------------------
// -> xDIPR001(): Versao para trabalhar consolidando as filiais.
//--------------------------------------------------------------------------------------------------
                                                            
If ! cEmpAnt == '04' .and. cFilAnt == '01'
	If MsgBox("Gerar Relatório por FILIAL? ","Atenção","YESNO")
		U_fDIPR001() // Versao para gerar relatorio por filial
	Else
		U_xDIPR001() // Chama a versao que consolida as filiais da Dipromed
	EndIf
Else
	U_fDIPR001()     // Versao para gerar relatorio por filial
EndIf


Return(Nil)  



User Function fDIPR001()     
Local   _xArea	   := GetArea()
Local   titulo	   := OemTOAnsi("Faturamento por operador",72)
Local   cDesc1	   := OemToAnsi("Este programa tem como objetivo emitir um relat¢rio",72)
Local   cDesc2	   := OemToAnsi("do faturamento por operador.",72)
Local   cDesc3	   := ""
Local   nOpcao     := 0 
Private nFatTot    := 0
Private nFatLiq    := 0 
Private nTotDev    := 0
Private nOutDev    := 0 
Private cOutOper   := ""
Private _aDados    := {}  
Private _aDados2   := {}
Private aReturn    := {"Bco A4", 1,"Faturamento", 1, 2, 1,"",1}
Private li         := 220
Private m_pag      :=1
Private tamanho    := "P"
Private limite     := 80
Private nomeprog   := "fDIPR001"
Private cPerg  	   := ""
Private nLastKey   := 0
Private wnrel      := "fDIPR001"
Private cString    := "SF2"
Private cOper      := Space(254)
Private cVendInt   := GetMV("MV_DIPVINT")// MCVN - 06/05/09
Private cVendExt   := GetMV("MV_DIPVEXT")// MCVN - 06/05/09
Private cVendPub   := GetMV("MV_DIPVPUB")// MCVN - 19/08/10
Private cPerg      := U_FPADR( "fDIPR001","SX1","SX1->X1_GRUPO"," " )
//--------------------------------------------------------------------------------------------------
Private _cDipusr   := U_DipUsr()

U_DIPPROC(ProcName(0),_cDipusr) // JBS 05/10/2005 - Gravando o nome do Programa no SZU

AjustaSX1(cPerg)

If !Pergunte(cPerg,.T.)
	Return
EndIf


wnrel := SetPrint(cString,wnrel,cPerg,Titulo,cDesc1,cDesc2,cDesc3,.f.,,.f.,tamanho,,.f.,,,,,)

If nLastKey == 27
	Return
Endif

SetDefault(aReturn,cString)

Processa({|lEnd| RunProc()},"Selecionando dados...")
RptStatus({|lEnd| RptDetail()},"Imprimindo...")

RestArea(_xArea)

Return


//////////////////////////////////////////////////////////////////////
Static Function RunProc() 

Local cQry1      := ""
Local cQry2      := ""
Local cOper      := ""
Local nValFat    := 0
Local nValFatL   := 0
Local nValDev    := 0
Local nCont      := 0
Local cOperFat   := ""
Local cOutOper   := "" 
Local cOperDev   := ""
Local _x


ProcRegua(5000)
For _x := 1 to 150
	IncProc( "Processando...VENDAS ")
Next

cQry1 := " SELECT F2_DOC, SUM(CASE F4_DUPLIC WHEN 'S' THEN (D2_TOTAL+D2_SEGURO+D2_VALFRE+D2_DESPESA+D2_ICMSRET ) ELSE (D2_SEGURO+D2_VALFRE+D2_DESPESA+D2_ICMSRET ) END) as F2_VALFAT, F2_VEND1, F2_VEND2, C5_OPERADO, U7_CODVEN, F2_CLIENTE, D2_FORNEC"
cQry1 += " FROM "+ RetSQLName("SF2") + " SF2"
cQry1 += "    INNER JOIN " + RetSQLName("SD2") + " SD2"
cQry1 += "       on SD2.D_E_L_E_T_ = ' ' "
cQry1 += "       and SF2.F2_FILIAL = SD2.D2_FILIAL "
cQry1 += "       and SF2.F2_DOC    = SD2.D2_DOC "
cQry1 += "       and SF2.F2_SERIE  = SD2.D2_SERIE "
cQry1 += "    INNER JOIN " + RetSQLName("SF4") + " SF4"
cQry1 += "       on SF4.D_E_L_E_T_ = ' ' "
cQry1 += "       and SD2.D2_TES = SF4.F4_CODIGO "
cQry1 += "       and SF4.F4_FILIAL = '"  + xFilial("SF4") + "'  "
cQry1 += "    INNER JOIN " + RetSQLName("SC5") + " SC5"
cQry1 += "       on SC5.D_E_L_E_T_ = ' ' "
cQry1 += "       and SD2.D2_FILIAL = SC5.C5_FILIAL"
cQry1 += "       and SD2.D2_PEDIDO = SC5.C5_NUM"
cQry1 += "       and SC5.C5_OPERADO BETWEEN '" +MV_PAR03+ "' AND '" +MV_PAR04+ "' "
	If U_ListOper() != ''
		cQry1 += "       and C5_OPERADO " + U_ListOper()+" "
	EndIf
cQry1 += "    LEFT JOIN " + RetSQLName("SU7") + " SU7"
cQry1 += "       on SU7.D_E_L_E_T_ = ' ' "
cQry1 += "       and SF2.F2_VEND1 = SU7.U7_CODVEN "
cQry1 += " WHERE SF2.D_E_L_E_T_ = ' '"
cQry1 += "    and SF2.F2_EMISSAO BETWEEN '" +DTOS(MV_PAR01)+ "' AND '" +DTOS(MV_PAR02)+ "' "
cQry1 += "    and SF2.F2_FILIAL = '"  + xFilial("SF2") + "'   "
cQry1 += "    and SF2.F2_TIPO IN ('N','C') "
cQry1 += "    and ( SF4.F4_DUPLIC = 'S' or D2_SEGURO+D2_VALFRE+D2_DESPESA+D2_ICMSRET  > 0 ) "
	If U_ListVend() != ''
		cQry1 += "    and F2_VEND1 IN( " + U_ListVend("2")+" ) "
	EndIf

cQry1 += " GROUP BY F2_DOC, F2_VEND1, F2_VEND2, C5_OPERADO, U7_CODVEN, F2_CLIENTE, D2_FORNEC"
cQry1 += " ORDER BY C5_OPERADO "
//cQry2 += "       and SF2.F2_VEND1 	= SU7.U7_CODVEN "

TcQuery cQRY1 NEW ALIAS "cQRY1"
memowrite('fDIPR001SD2' + ' .SQL',cQRY1)

ProcRegua(500)
For _x := 1 to 150
	IncProc( "Processando... DEVOLUÇÃO")
Next


cQry2 := "SELECT C5_OPERADO, U7_CODVEN, F2_VEND1, C5_VEND2, C5_CLIENTE, SUM( CASE F4_DUPLIC WHEN 'S' THEN (D1_TOTAL+D1_VALFRE+D1_SEGURO+D1_DESPESA+D1_ICMSRET) ELSE (D1_VALFRE+D1_SEGURO+D1_DESPESA+D1_ICMSRET) END) D1_TOTAL, D2_FORNEC"
cQry2 += " FROM "+ RetSqlName("SD1") + " SD1 "
cQry2 += "    INNER JOIN " + RetSqlName("SD2") + " SD2 "
cQry2 += "       on SD2.D_E_L_E_T_   = ' ' "
cQry2 += "       and SD1.D1_FILIAL     = SD2.D2_FILIAL "
cQry2 += "       and SD1.D1_NFORI      = SD2.D2_DOC "
cQry2 += "       and SD1.D1_SERIORI    = SD2.D2_SERIE "
cQry2 += "       and SD1.D1_ITEMORI    = SD2.D2_ITEM "
cQry2 += "    INNER JOIN " + RetSqlName("SC5") + " SC5 "
cQry2 += "       on SC5.D_E_L_E_T_   = ' ' "
cQry2 += "       and SD2.D2_FILIAL 	 = SC5.C5_FILIAL "
cQry2 += "       and SC5.C5_OPERADO BETWEEN '" +MV_PAR03+ "' AND '" +MV_PAR04+ "' "
cQry2 += "       and SD2.D2_PEDIDO 	 = SC5.C5_NUM "
	If U_ListOper() != ''
		cQry2 += "       and C5_OPERADO " + U_ListOper()+" "
	EndIf
cQry2 += "    INNER JOIN " + RetSqlName("SF4") + " SF4 "
cQry2 += "       on SF4.D_E_L_E_T_   = ' ' "
cQry2 += "       and SD1.D1_TES = SF4.F4_CODIGO "
cQry2 += "       and SF4.F4_FILIAL 	 = '" + xFilial("SF4") + "' "
cQry2 += "    INNER JOIN " + RetSqlName("SF2") + " SF2 "
cQry2 += "       on SF2.D_E_L_E_T_   = ' ' "
cQry2 += "       and SF2.F2_FILIAL     = SD2.D2_FILIAL "
cQry2 += "       and SF2.F2_DOC    	 = SD2.D2_DOC  "
cQry2 += "       and SF2.F2_SERIE  	 = SD2.D2_SERIE  "
	If U_ListVend() != ''
		cQry2 += "       and F2_VEND1 IN( " + U_ListVend("2")+" ) "
	EndIf
cQry2 += "    LEFT JOIN " + RetSQLName("SU7") + " SU7 "
cQry2 += "       on SU7.D_E_L_E_T_   = ' ' "
cQry2 += "       and SF2.F2_VEND1 	= SU7.U7_CODVEN "
cQry2 += " WHERE SD1.D_E_L_E_T_   = ' ' "
cQry2 += "    and SD1.D1_TIPO = 'D' "
cQry2 += "    and SD1.D1_DTDIGIT BETWEEN '" +DTOS(MV_PAR01)+ "' AND '" +DTOS(MV_PAR02)+ "' "
cQry2 += "    and SD1.D1_FILIAL     = '" + xFilial("SD1") + "' "
cQry2 += "    and ( SF4.F4_DUPLIC   = 'S' or D1_VALFRE+D1_SEGURO+D1_DESPESA+D1_ICMSRET > 0 ) "
cQry2 += " GROUP BY C5_OPERADO,U7_CODVEN, F2_VEND1,C5_VEND2,C5_CLIENTE,D2_FORNEC "
cQry2 += " ORDER BY C5_OPERADO "
TcQuery cQRY2 NEW ALIAS "cQRY2"         // Abre uma workarea com o resultado da query
memowrite('fDIPR001SD1' + '.SQL',cQRY2)


ProcRegua(3000)
For _x := 1 to 500
	IncProc( "Processando... Dados vendas")
Next

DbSelectArea("cQRY1")
DbGoTop()

cOper := cQRY1->C5_OPERADO

IncProc( "Processando... Dados vendas")

Do While cQRY1->(!Eof())
	
	Do While cQRY1->C5_OPERADO == cOper
		
		cOper    := cQRY1->C5_OPERADO
		nValFat  += cQRY1->F2_VALFAT
		
		cQRY1->(DbSkip())
	EndDo
	
	DbSelectArea("cQRY2")
	DbGoTop()
	Do While cQRY2->(!Eof())
		
		If cQRY2->C5_OPERADO == cOper
			nValDev += cQRY2->D1_TOTAL
		EndIF
		
		cQRY2->(DbSkip())
	EndDo
	cOperFat += cOper+","
	nValFatL := (nValFat-nValDev)
	aadd(_aDados,{cOper,nValFat,nValFatL,nValDev})
	cOper := cQRY1->C5_OPERADO
	nFatTot  += nValFat
	nFatLiq  += nValFatL
	nTotDev  += nValDev
	nValFat  := nValFatL := nValDev := 0
	
EndDo

DbSelectArea("cQRY2")
DbGoTop()


	Do While cQRY2->(!Eof())
		
		If ! cQRY2->C5_OPERADO $ cOperFat
			cOutOper := cQRY2->C5_OPERADO
			nOutDev  += cQRY2->D1_TOTAL
		EndIf 
	
		cQRY2->(DbSkip())
	    If cOutOper <> ""
			cOperDev := cOutOper
		Else
			cOperDev := cQRY2->C5_OPERADO
		EndIf	
			If cOperDev != cQRY2->C5_OPERADO 
				aadd(_aDados2,{cOutOper,nValFat,nValFatL,nOutDev})
				nFatLiq  -= nOutDev
				nTotDev  += nOutDev 
				nOutDev  := 0
				cOutOper :=""
			EndIf
		
	EndDo                    

Return


///////////////////////////
Static Function RptDetail()

Local _cTitulo := " Faturamento por Operador "
Local _cDesc1  := " =======================Período de "+DTOC(MV_PAR01)+" até "+DTOC(MV_PAR02)+"========================"
Local _cDesc2  := " Codigo    Nome Operador            Fat_Total         Fat_Liquido      Devolucao"
Local nI := 0     
Local nX := 0     
                  
If MV_PAR05 ==1
	ASORT(_aDados, , , { | x,y | x[1] < y[1] } )
Else
	ASORT(_aDados, , , { | x,y | x[3] > y[3] } )
EndIf
	
For nI := 1 To Len(_aDados)
		
		If li > 65
			li := Cabec(_cTitulo,_cDesc1,_cDesc2,nomeprog,tamanho)
		EndIf
		
		li++
		@ li,001 PSay _aDados[nI,1]
		@ li,011 PSay SubStr(POSICIONE("SU7",1,xFilial("SU7")+_aDados[nI,1],"U7_NOME"),1,20)
		@ li,032 PSay _aDados[nI,2] Picture "@E 99,999,999.99"
		@ li,052 PSay _aDados[nI,3] Picture "@E 99,999,999.99"
		@ li,067 PSay (_aDados[nI,4]*-1) Picture "@E 99,999,999.99"
	  
Next nI  
        If Len(_aDados2) > 0
        	li++
  			li++                                                                          
			@ li,000 PSay "-----------------Faturamento Anterior aos Parametros Informados-----------------"
		EndIf
		                                
For nI := 1 To Len(_aDados2)
		
		If li > 65
			li := Cabec(_cTitulo,_cDesc1,_cDesc2,nomeprog,tamanho)
		EndIf
          li++
		@ li,001 PSay _aDados2[nI,1]
		@ li,011 PSay SubStr(POSICIONE("SU7",1,xFilial("SU7")+_aDados2[nI,1],"U7_NOME"),1,20)
		@ li,032 PSay _aDados2[nI,2] Picture "@E 99,999,999.99"
		@ li,052 PSay _aDados2[nI,3] Picture "@E 99,999,999.99"
		@ li,067 PSay (_aDados2[nI,4]*-1) Picture "@E 99,999,999.99"
	
Next nI
	
 
	li++
	@ li,000 PSay Replicate("-",limite)
	li++	
	
	
	@ li,001 PSay "Tota Geral"
	@ li,032 PSay nFatTot  Picture "@E 99,999,999.99"
	@ li,052 PSay nFatLiq  Picture "@E 99,999,999.99"
	@ li,067 PSay (nTotDev*-1)  Picture "@E 99,999,999.99"
	li++
	@ li,000 PSay Replicate("-",limite)
	
	nFatTot := 0
	nFatLiq := 0
	nTotDev := 0


DbSelectArea("cQRY1")
cQRY1->(DbCloseArea())

DbSelectArea("cQRY2")
cQRY2->(DbCloseArea())


Set device to Screen

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se em disco, desvia para Spool                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If aReturn[5] == 1    // Se Saida para disco, ativa SPOOL
	Set Printer TO
	Commit
	ourspool(wnrel)
Endif



Return(.T.)   

/*
=============================================================
| Verifica se existe as perguntas, caso não exista as cria.
=============================================================*/
Static Function AjustaSX1(cPerg)
_sAlias := Alias()
dbSelectArea("SX1")
dbSetOrder(1)

aRegs:={}

//------------ Grupo/Ordem/Pergunta/PERGING/PERGESP/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05/F3
aAdd(aRegs,{cPerg,"01","Da Data            ?","","","mv_ch1","D",08,0,0,"G","","mv_par01","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"02","Ate a Data         ?","","","mv_ch2","D",08,0,0,"G","","mv_par02","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"03","Do Operador        ?","","","mv_ch3","C",06,0,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","SU7"})
aAdd(aRegs,{cPerg,"04","Ate o Operador     ?","","","mv_ch4","C",06,0,0,"G","","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","","SU7"})
aAdd(aRegs,{cPerg,"05","Lista por          ?","","","mv_ch5","N",01,0,1,"C","","mv_par05","Operador","Operador","Operador","","","Ranking","Ranking","Ranking","","","","","",""})

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


/*====================================================================================\
|Programa  | xDIPR001.PRW  | Autor  | Alexandro Dias          | Data | 25/01/2002      |
|=====================================================================================|
|Descrição | Gera um relatorio do faturamento por operador.                           |
|          |                                                                          |
|=====================================================================================|
|Data      | Autor	   |        		       Histórico                              |
|-------------------------------------------------------------------------------------|
|04/03/15  | RBorges   | Deixar o valor total igual aos demais relatórios.            |
|-------------------------------------------------------------------------------------|
|          |           | 														      |
|-------------------------------------------------------------------------------------|
|          |           | 														      |
|-------------------------------------------------------------------------------------|
|04/03/15  | RBorges   | Alteração de toda a estrutura do relatorio                   |
|=====================================================================================|
|Uso       | Vendas																	  |
\====================================================================================*/

User Function xDIPR001()

Local   _xArea	   := GetArea()
Local   titulo	   := OemTOAnsi("Faturamento por operador",72)
Local   cDesc1	   := OemToAnsi("Este programa tem como objetivo emitir um relat¢rio",72)
Local   cDesc2	   := OemToAnsi("do faturamento por operador.",72)
Local   cDesc3	   := ""
Local   nOpcao     := 0 
Private nFatTot    := 0
Private nFatLiq    := 0 
Private nTotDev    := 0
Private nOutDev    := 0 
Private cOutOper   := ""
Private _aDados    := {}  
Private _aDados2   := {}
Private aReturn    := {"Bco A4", 1,"Faturamento", 1, 2, 1,"",1}
Private li         := 220
Private m_pag      :=1
Private tamanho    := "P"
Private limite     := 80
Private nomeprog   := "xDIPR001"
Private cPerg  	   := ""
Private nLastKey   := 0
Private wnrel      := "xDIPR001"
Private cString    := "SF2"
Private cOper      := Space(254)
Private cVendInt   := GetMV("MV_DIPVINT")// MCVN - 06/05/09
Private cVendExt   := GetMV("MV_DIPVEXT")// MCVN - 06/05/09
Private cVendPub   := GetMV("MV_DIPVPUB")// MCVN - 19/08/10
Private cPerg      := U_FPADR( "xDIPR001","SX1","SX1->X1_GRUPO"," " )
//--------------------------------------------------------------------------------------------------
Private _cDipusr   := U_DipUsr()

U_DIPPROC(ProcName(0),_cDipusr) // JBS 05/10/2005 - Gravando o nome do Programa no SZU

_AjustaSX1(cPerg)

If !Pergunte(cPerg,.T.)
	Return
EndIf


wnrel := SetPrint(cString,wnrel,cPerg,Titulo,cDesc1,cDesc2,cDesc3,.f.,,.f.,tamanho,,.f.,,,,,)

If nLastKey == 27
	Return
Endif

SetDefault(aReturn,cString)

Processa({|lEnd| _RunProc()},"Selecionando dados...")
RptStatus({|lEnd| _RptDetail()},"Imprimindo...")

RestArea(_xArea)

Return


//////////////////////////////////////////////////////////////////////
Static Function _RunProc() 

Local cQry1      := ""
Local cQry2      := ""
Local cOper      := ""
Local nValFat    := 0
Local nValFatL   := 0
Local nValDev    := 0
Local nCont      := 0
Local cOperFat   := ""
Local cOutOper   := ""
Local cOperDev   := ""


ProcRegua(5000)
For _x := 1 to 150
	IncProc( "Processando...VENDAS ")
Next

cQry1 := " SELECT F2_DOC, SUM(CASE F4_DUPLIC WHEN 'S' THEN (D2_TOTAL+D2_SEGURO+D2_VALFRE+D2_DESPESA+D2_ICMSRET ) ELSE (D2_SEGURO+D2_VALFRE+D2_DESPESA+D2_ICMSRET ) END) as F2_VALFAT, F2_VEND1, F2_VEND2, C5_OPERADO, U7_CODVEN, F2_CLIENTE, D2_FORNEC"
cQry1 += " FROM "+ RetSQLName("SF2") + " SF2 "
cQry1 += "    INNER JOIN " + RetSQLName("SD2") + " SD2 "
cQry1 += "       on SD2.D_E_L_E_T_ = ' ' "
cQry1 += "       and SF2.F2_FILIAL = SD2.D2_FILIAL  "
cQry1 += "       and SF2.F2_DOC    = SD2.D2_DOC     "
cQry1 += "       and SF2.F2_SERIE  = SD2.D2_SERIE   "
cQry1 += "    INNER JOIN " + RetSQLName("SC5") + " SC5 "
cQry1 += "       on SC5.D_E_L_E_T_ = ' ' "
cQry1 += "       and SD2.D2_FILIAL = SC5.C5_FILIAL "
cQry1 += "       and SD2.D2_PEDIDO = SC5.C5_NUM "
cQry1 += "       and SC5.C5_OPERADO BETWEEN '" +MV_PAR03+ "' AND '" +MV_PAR04+ "' "
	If U_ListOper() != ''
		cQry1 += "       and C5_OPERADO " + U_ListOper()+" "
	EndIf
cQry1 += "    INNER JOIN " + RetSQLName("SF4") + " SF4 "
cQry1 += "       on SF4.D_E_L_E_T_ = ' ' "
cQry1 += "       and SD2.D2_TES = SF4.F4_CODIGO     "
cQry1 += "       and SF4.F4_FILIAL = '"  + xFilial("SF4") + "'  "
cQry1 += "    LEFT JOIN " + RetSQLName("SU7") + " SU7 "
cQry1 += "       on SU7.D_E_L_E_T_ = ' ' "
cQry1 += "       and SF2.F2_VEND1 = SU7.U7_CODVEN "
cQry1 += " WHERE SF2.D_E_L_E_T_ = ' ' "
cQry1 += "    and SF2.F2_EMISSAO BETWEEN '" +DTOS(MV_PAR01)+ "' AND '" +DTOS(MV_PAR02)+ "' "
cQry1 += "    and SF2.F2_FILIAL IN ('01','04')   "
cQry1 += "    and SF2.F2_TIPO IN ('N','C')       "
cQry1 += "    and ( SF4.F4_DUPLIC = 'S' or D2_SEGURO+D2_VALFRE+D2_DESPESA+D2_ICMSRET  > 0 ) "
If U_ListVend() != ''
	cQry1 += "       and F2_VEND1 IN( " + U_ListVend("2")+" ) "
EndIf
cQry1 += " GROUP BY F2_DOC, F2_VEND1, F2_VEND2, C5_OPERADO, U7_CODVEN, F2_CLIENTE, D2_FORNEC"
cQry1 += " ORDER BY C5_OPERADO "

TcQuery cQRY1 NEW ALIAS "cQRY1"
memowrite('xDIPR001SD2' + ' .SQL',cQRY1)

ProcRegua(500)
For _x := 1 to 150
	IncProc( "Processando... DEVOLUÇÃO")
Next


cQry2 := "SELECT C5_OPERADO, U7_CODVEN, F2_VEND1, C5_VEND2, C5_CLIENTE, SUM( CASE F4_DUPLIC WHEN 'S' THEN (D1_TOTAL+D1_VALFRE+D1_SEGURO+D1_DESPESA+D1_ICMSRET) ELSE (D1_VALFRE+D1_SEGURO+D1_DESPESA+D1_ICMSRET) END) D1_TOTAL, D2_FORNEC"
cQry2 += " FROM "+ RetSqlName("SD1") + " SD1 "
cQry2 += "    INNER JOIN " + RetSqlName("SD2") + " SD2 "
cQry2 += "       on SD2.D_E_L_E_T_   = ' ' "
cQry2 += "       and SD1.D1_FILIAL     = SD2.D2_FILIAL "
cQry2 += "       and SD1.D1_NFORI      = SD2.D2_DOC    "
cQry2 += "       and SD1.D1_SERIORI    = SD2.D2_SERIE  "
cQry2 += "       and SD1.D1_ITEMORI    = SD2.D2_ITEM   "
cQry2 += "    INNER JOIN " + RetSqlName("SF4") + " SF4 "
cQry2 += "       on SF4.D_E_L_E_T_   = ' ' "
cQry2 += "       and SF4.F4_FILIAL 	 = '" + xFilial("SF4") + "' "
cQry2 += "       and SD1.D1_TES = SF4.F4_CODIGO "
cQry2 += "    INNER JOIN " + RetSqlName("SF2") + " SF2 "
cQry2 += "       on SF2.D_E_L_E_T_   = ' ' "
cQry2 += "       and SF2.F2_FILIAL     = SD2.D2_FILIAL "
cQry2 += "       and SF2.F2_DOC    	 = SD2.D2_DOC    "
cQry2 += "       and SF2.F2_SERIE  	 = SD2.D2_SERIE  "
	If U_ListVend() != ''
		cQry2 += "       and F2_VEND1 IN( " + U_ListVend("2")+" ) "
	EndIf
cQry2 += "    INNER JOIN " + RetSqlName("SC5") + " SC5 "
cQry2 += "       on SC5.D_E_L_E_T_   = ' ' "
cQry2 += "       and SD2.D2_FILIAL 	 = SC5.C5_FILIAL "
cQry2 += "       and SC5.C5_OPERADO BETWEEN '" +MV_PAR03+ "' AND '" +MV_PAR04+ "' "
cQry2 += "       and SD2.D2_PEDIDO 	 = SC5.C5_NUM "
	If U_ListOper() != ''
		cQry2 += "       and C5_OPERADO " + U_ListOper()+" "
	EndIf
cQry2 += "    LEFT JOIN " + RetSQLName("SU7") + " SU7 "
cQry2 += "       on SU7.D_E_L_E_T_   = ' ' "
cQry2 += "       and SF2.F2_VEND1 	= SU7.U7_CODVEN "
cQry2 += " WHERE SD1.D_E_L_E_T_   = ' ' "
cQry2 += "    and SD1.D1_TIPO = 'D' "
cQry2 += "    and SD1.D1_DTDIGIT BETWEEN '" +DTOS(MV_PAR01)+ "' AND '" +DTOS(MV_PAR02)+ "' "
cQry2 += "    and SD1.D1_FILIAL IN ('01','04')      "
cQry2 += "    and ( SF4.F4_DUPLIC   = 'S' or D1_VALFRE+D1_SEGURO+D1_DESPESA+D1_ICMSRET > 0 ) "
cQry2 += " GROUP BY C5_OPERADO,U7_CODVEN, F2_VEND1,C5_VEND2,C5_CLIENTE,D2_FORNEC "
cQry2 += " ORDER BY C5_OPERADO "
TcQuery cQRY2 NEW ALIAS "cQRY2"         // Abre uma workarea com o resultado da query
memowrite('xDIPR001SD1' + '.SQL',cQRY2)

ProcRegua(3000)
For _x := 1 to 500
	IncProc( "Processando... Dados vendas")
Next

DbSelectArea("cQRY1")
DbGoTop()

cOper := cQRY1->C5_OPERADO

IncProc( "Processando... Dados vendas")

Do While cQRY1->(!Eof())
	
	Do While cQRY1->C5_OPERADO == cOper
		
		cOper    := cQRY1->C5_OPERADO
		nValFat  += cQRY1->F2_VALFAT
		
		cQRY1->(DbSkip())
	EndDo
	
	DbSelectArea("cQRY2")
	DbGoTop()
	Do While cQRY2->(!Eof())
		
		If cQRY2->C5_OPERADO == cOper
			nValDev += cQRY2->D1_TOTAL
		EndIF
		
		cQRY2->(DbSkip())
	EndDo
	cOperFat += cOper+","
	nValFatL := (nValFat-nValDev)
	aadd(_aDados,{cOper,nValFat,nValFatL,nValDev})
	cOper := cQRY1->C5_OPERADO
	nFatTot  += nValFat
	nFatLiq  += nValFatL
	nTotDev  += nValDev
	nValFat  := nValFatL := nValDev := 0
	
EndDo

DbSelectArea("cQRY2")
DbGoTop()


Do While cQRY2->(!Eof())
	
	If ! cQRY2->C5_OPERADO $ cOperFat
		cOutOper := cQRY2->C5_OPERADO
		nOutDev  += cQRY2->D1_TOTAL
	EndIf
	
	cQRY2->(DbSkip())
	If cOutOper <> ""
		cOperDev := cOutOper
	Else
		cOperDev := cQRY2->C5_OPERADO
	EndIf
	If cOperDev != cQRY2->C5_OPERADO
		aadd(_aDados2,{cOutOper,nValFat,nValFatL,nOutDev})
		nFatLiq  -= nOutDev
		nTotDev  += nOutDev
		nOutDev  := 0
		cOutOper :=""
	EndIf
	
EndDo

Return


///////////////////////////
Static Function _RptDetail()

Local _cTitulo := " Faturamento por Operador "
Local _cDesc1  := " =======================Período de "+DTOC(MV_PAR01)+" até "+DTOC(MV_PAR02)+"========================"
Local _cDesc2  := " Codigo    Nome Operador            Fat_Total         Fat_Liquido      Devolucao"
Local nI := 0
Local nX := 0

If MV_PAR05 ==1
	ASORT(_aDados, , , { | x,y | x[1] < y[1] } )
Else
	ASORT(_aDados, , , { | x,y | x[3] > y[3] } )
EndIf

For nI := 1 To Len(_aDados)
	
	If li > 65
		li := Cabec(_cTitulo,_cDesc1,_cDesc2,nomeprog,tamanho)
	EndIf
	
	li++
	@ li,001 PSay _aDados[nI,1]
	@ li,011 PSay SubStr(POSICIONE("SU7",1,xFilial("SU7")+_aDados[nI,1],"U7_NOME"),1,20)
	@ li,032 PSay _aDados[nI,2] Picture "@E 99,999,999.99"
	@ li,052 PSay _aDados[nI,3] Picture "@E 99,999,999.99"
	@ li,067 PSay (_aDados[nI,4]*-1) Picture "@E 99,999,999.99"
	
Next nI
If Len(_aDados2) > 0
	li++
	li++
	@ li,000 PSay "-----------------Faturamento Anterior aos Parametros Informados-----------------"
EndIf

For nI := 1 To Len(_aDados2)
	
	If li > 65
		li := Cabec(_cTitulo,_cDesc1,_cDesc2,nomeprog,tamanho)
	EndIf
	li++
	@ li,001 PSay _aDados2[nI,1]
	@ li,011 PSay SubStr(POSICIONE("SU7",1,xFilial("SU7")+_aDados2[nI,1],"U7_NOME"),1,20)
	@ li,032 PSay _aDados2[nI,2] Picture "@E 99,999,999.99"
	@ li,052 PSay _aDados2[nI,3] Picture "@E 99,999,999.99"
	@ li,067 PSay (_aDados2[nI,4]*-1) Picture "@E 99,999,999.99"
	
Next nI


li++
@ li,000 PSay Replicate("-",limite)
li++


@ li,001 PSay "Tota Geral"
@ li,032 PSay nFatTot  Picture "@E 99,999,999.99"
@ li,052 PSay nFatLiq  Picture "@E 99,999,999.99"
@ li,067 PSay (nTotDev*-1)  Picture "@E 99,999,999.99"
li++
@ li,000 PSay Replicate("-",limite)

nFatTot := 0
nFatLiq := 0
nTotDev := 0


DbSelectArea("cQRY1")
cQRY1->(DbCloseArea())

DbSelectArea("cQRY2")
cQRY2->(DbCloseArea())


Set device to Screen

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se em disco, desvia para Spool                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If aReturn[5] == 1    // Se Saida para disco, ativa SPOOL
	Set Printer TO
	Commit
	ourspool(wnrel)
Endif



Return(.T.)   

/*
=============================================================
| Verifica se existe as perguntas, caso não exista as cria.
=============================================================*/
Static Function _AjustaSX1(cPerg)
_sAlias := Alias()
dbSelectArea("SX1")
dbSetOrder(1)

aRegs:={}

//------------ Grupo/Ordem/Pergunta/PERGING/PERGESP/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05/F3
aAdd(aRegs,{cPerg,"01","Da Data            ?","","","mv_ch1","D",08,0,0,"G","","mv_par01","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"02","Ate a Data         ?","","","mv_ch2","D",08,0,0,"G","","mv_par02","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"03","Do Operador        ?","","","mv_ch3","C",06,0,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","SU7"})
aAdd(aRegs,{cPerg,"04","Ate o Operador     ?","","","mv_ch4","C",06,0,0,"G","","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","","SU7"})
aAdd(aRegs,{cPerg,"05","Lista por          ?","","","mv_ch5","N",01,0,1,"C","","mv_par05","Operador","Operador","Operador","","","Ranking","Ranking","Ranking","","","","","",""})

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

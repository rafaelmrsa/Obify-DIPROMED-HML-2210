/*====================================================================================\
|Programa  | DIPR060       | Autor | Jailton b Santos - JBS     | Data | 30/03/2006   |
|=====================================================================================|
|Descrição | Este programa gera um relatorio de faturamento de um periodo. Primeiro   |
|          | apura as vendas do perido e coloca em um arquivo temporario. Segundo     |
|          | Aprura as devuloções de clientes existentes no mesmo periodo e as sub-   |
|          | trai do arquivo temporario, nos respectivo vendedor e fornecedor e mes.  |
|          | Terceiro, exibe as informações na tela. Neste momento o usuario tem a    |
|          | a opção de imprimir.                                                     |
|=====================================================================================|
|Sintaxe   | U_DIPR060()                                                              |
|=====================================================================================|
|Uso       | Especifico DIPROMED                                                      |
|=====================================================================================|
|........................................Histórico....................................|
|          |                                                                          |
\====================================================================================*/
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#DEFINE ENTER CHR(13)+CHR(10)
#DEFINE say_tit 1
#DEFINE say_det 2
#DEFINE say_rep 3
//------------------------------------------------------------
User Function Dipr060()
//------------------------------------------------------------
Local bOk:={|| nOpcao:=1,oDlg:End()}
Local oDlg
Local oBt1
Local oBt2
Local oGeraArq
Local nOpcao:=0
Local aMes:={}   
Local cUserAut      := GetMV("MV_URELFAT") // MCVN - 04/05/09 

Private aDados:={}

// Private cPerg:="DIPR60"
// FPADR(cPerg, cArq, cCampo, cTipo)  - Para ajustar o tamanho das perguntas no SX1- uso generico
PRIVATE cPerg  	:= U_FPADR( "DIPR60","SX1","SX1->X1_GRUPO"," " ) //Função criada por Sandro em 19/11/09.

Private aReturn:={"Zebrado", 1,"Administracao", 1, 2, 1,"",1}
Private nLastKey:=0
Private aRCampos:={}
Private aStru:={}
Private cArqWork
Private cUltimo:=""
Private lGeraArq:=.f.
Private nDias
Private dDiaI
Private dDiaF
Private cAnoI
Private cMesI
Private cAno:= StrZero(Year(FirstDay(dDataBase)-1),4)
Private cMes:= StrZero(Month(FirstDay(dDataBase)-1),2)
Private cQtde:='12'
Private cVend:=Space(len(SA1->A1_VEND))
Private cCodven:=''
Private nQVen:=0
Private nQFat:=0
Private aTotais:={0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}    
Private cDestino  := "C:\EXCELL-DBF\"
	 

U_DIPPROC(ProcName(0),U_DipUsr()) // MCVN - 22/01/2009  

// MCVN - 04/05/09    
If !(Upper(U_DipUsr()) $ cUserAut)
	Alert(Upper(U_DipUsr())+", você não tem autorização para utilizar esta rotina. Qualquer dúvida falar com Eriberto!","Atenção")	
	Return()
EndIF 

//-----------------------------------------------------------
// Lê o pergunte DIPR60
//-----------------------------------------------------------
SX1->(DipPergDiverg(.t.))
//-----------------------------------------------------------
// Tela de Dialogo com o usuario
//-----------------------------------------------------------
Define msDialog oDlg title OemToAnsi("Realtorio de Vendas") From 09,10 TO 25,45

@ 002,002 to 103,136 pixel

@ 010,010 say "Ano Final" Pixel
@ 020,010 say "Mes Final" Pixel
@ 030,010 say "Vendedor"  Pixel

@ 010,080 get cAno  Valid !Empty(cAno) Size 40,08 pixel
@ 020,080 get cMes  valid !Empty(cMes) Size 40,08 pixel
@ 030,080 get cVend Size 40,08 pixel
@ 060,010 checkbox oGeraArq var lGeraArq   PROMPT "Gera arquivo para Excel" size 110,008 of oDlg

Define sbutton oBt1 from 108,079 type 1 action Eval(bOK) enable of oDlg
Define sbutton oBt2 from 108,109 type 2 action (nOpcao := 0, oDlg:End()) enable of oDlg

Activate Dialog oDlg Centered

If nOpcao = 0
	Return(.t.)
EndIf
//--------------------------------------------------------
// Grava o dialogo com o usuario no SX1
//--------------------------------------------------------
SX1->(DipPergDiverg(.f.))
//--------------------------------------------------------
// Calcula datas para o Relatorio
//--------------------------------------------------------
cMesF:=cMes
cAnoF:=cAno
cMesI:=If(cMesF=='12','01',StrZero(Val(cMes)+1,2))
cAnoI:=If(cMesF=='12',cAno,StrZero(Val(cAno)-1,4))
//--------------------------------------------------------
// Configurações do Relatorio
//--------------------------------------------------------
aAdd(aDados,"WORK")                                                     // 01
aAdd(aDados,OemTOAnsi("Faturamento Por Vendedor e Fornecedores",72))    // 02
aAdd(aDados,"")                                                         // 03
aAdd(aDados,OemToAnsi("Dentro de um periodo",72))                       // 04
aAdd(aDados,"G")                                                        // 05
aAdd(aDados,200)                                                        // 06
aAdd(aDados,OemTOAnsi("Classificado Por Vendedor e Fornecedor"))        // 07
aAdd(aDados,OemTOAnsi('Periodo de '+cMesI+'/'+cAnoI+' a '+cMes+'/'+cAno))// 08
aAdd(aDados,OemTOAnsi("Faturamento Por Vendedor e Fornecedores",72))    // 09
aAdd(aDados,aReturn)                                                    // 10
aAdd(aDados,"DIPR060")                                                  // 11
aAdd(aDados,{{||DIPR060Quebra()},{||Dipr060Final()}})                   // 12
aAdd(aDados,Nil)                                                        // 13
//--------------------------------------------------------
// Estrutura para a Work
//--------------------------------------------------------
aAdd(aStru,{"VEND"    ,AvSx3("A3_COD",2) ,AvSx3("A3_COD",3) ,0})
aAdd(aStru,{"NOMEVEND",AvSx3("A3_NOME",2),AvSx3("A3_NOME",3),0})
aAdd(aStru,{"FORN"    ,AvSx3("A3_COD",2) ,AvSx3("A3_COD",3) ,0})
aAdd(aStru,{"NOMEFORN",'C',35,0})
//--------------------------------------------------------
// Campos para acular os valores mensais
//--------------------------------------------------------
nNom_Cam := Val(cMesI)
cNom_Ano := cAnoI
For wi := 1 to 12
	AAdd(aStru,{'M'+cNom_Ano+StrZero(nNom_Cam,2),'N',15,2})
	If nNom_Cam = 12
		nNom_Cam := 1
		cNom_Ano := cAno
	Else
		nNom_Cam++
	EndIf
Next
aAdd(aStru,{"TOTAL",'N',15,2})
aAdd(aStru,{"TIPO", 'C',05,0})

//--------------------------------------------------------
// Estrutura como o relatorio será mostrado
//--------------------------------------------------------
aRCampos:= {}
//aAdd(aRCampos,{"NOMEVEND" ,"","Nome do Vendedor","@!"})
aAdd(aRCampos,{"FORN"     ,"","Cod Forn","@!"})
aAdd(aRCampos,{"NOMEFORN" ,"","Nome do Fornecedor","@!"})
//--------------------------------------------------------
// Mostrar o nome do mes para os Campos com val. mensais
//--------------------------------------------------------
nNom_Cam := Val(cMesI)
cNom_Ano := cAnoI
aMes := {'Jan','Fev','Mar','Abr','Mai','Jun','Jul','Ago','Set','Out','Nov','Dez'}
For wi := 1 to 12
	AAdd(aRCampos,{'M'+cNom_Ano+StrZero(nNom_Cam,2),"",aMes[nNom_Cam]+'/'+cNom_Ano,"@ke 9,999,999.99"})
	If nNom_Cam = 12
		nNom_Cam := 1
		cNom_Ano := cAnoF
	Else
		nNom_Cam++
	EndIf
Next
aAdd(aRCampos,{"TOTAL","","Total","@ke 9,999,999.99"})

aRCampos:=E_CriaRCampos(aRCampos,"E")

For wi:=03 to 15
	aRCampos[wi,3]:="D"
Next wi

//-------------------------------------------------------------
// Cria o arquivo temporario
//-------------------------------------------------------------
DIPR60CriaWork()
//-------------------------------------------------------------
// Processa a query que seleciona as vendas do periodo
//-------------------------------------------------------------
Processa({|| Dip60Vendas()},"Selecionando Vendas",,.f.)
//-------------------------------------------------------------
// Processa a query que seleciona as Devoluções de clientes
//-------------------------------------------------------------
Processa({|| Dip60Devolucoes()},"Apurando Devoluções de Clientes",,.f.)
//-------------------------------------------------------------
// Gera arquivo dbf para ser usado no Excel
//-------------------------------------------------------------
Work->(Dipr60GeraArq())
//-------------------------------------------------------------
// Monta o Relat na tela para o usuario. Onde ele pode imprimir
//-------------------------------------------------------------
Work->(dbGotop())
Work->(E_Report(aDados,aRCampos))
//--------------------------------
//Elimina os arquivos temporarios
//--------------------------------
Work->(E_EraseArq(cArqWork))
Return(.t.)
//-------------------------------------------------------------
// Gera o arquivo dbf para ser aberto pelo Excel
//-------------------------------------------------------------
Static Function Dipr60GeraArq()
//-------------------------------------------------------------
//Local cArqExcell:= GetSrvProfString("STARTPATH","")+"Excell-DBF\Dipr060.dbf" 

// Alterado para gravar dados no Protheus-data - por Sandro em 19/11/09.  
Local cArqExcell:= "\Excell-DBF\Dipr060.dbf"

If lGeraArq

	DbSelectArea("WORK")
	WORK->(dbGotop())
	ProcRegua(WORK->(RECCOUNT()))	
	aCols := Array(WORK->(RECCOUNT()),Len(aStru))
	nColuna := 0
	nLinha := 0
	While WORK->(!Eof())
		nLinha++
		IncProc(OemToAnsi("Gerando planilha excel..."))
		For nColuna := 1 to Len(aStru)
			aCols[nLinha][nColuna] := &("WORK->("+aStru[nColuna][1]+")")			
		Next nColuna
		WORK->(dbSkip())	
	EndDo
	u_GDToExcel(aStru,aCols,Alltrim(FunName()))

	dbSelectArea('WORK')
	COPY TO &cArqExcell VIA "DBFCDX"

	MakeDir(cDestino) // CRIA DIRETÓRIO CASO NÃO EXISTA
	CpyS2T(cArqExcell+".dbf",cDestino,.T.) // COPIA ARQUIVO PARA MAQUINA DO USUÁRIO
	

	dbSelectArea('SA3')
EndIf
Return(.t.)
//-------------------------------------------------------------
// Cria o Arq Temporario para ser usado pela função e_report
//-------------------------------------------------------------
Static Function Dipr60CriaWork()
//-------------------------------------------------------------
dbSelectArea('SF2')
cArqWork:=E_CriaTrab(,aStru,"WORK")
Indregua("WORK",cArqWork,"VEND+FORN ",,,"Criando indice temporario")
Return(.t.)
//------------------------------------------------------------
// Query que seleciona as vendas e coloca no temporario
//------------------------------------------------------------
Static Function Dip60Vendas()
//------------------------------------------------------------
Local lRetorno:=.t.
Local cQuery
Local nCount:=1000
Local nTotMes
Local cFilSA1:=xFilial('SA1')
Local cFilSA2:=xFilial('SA2')
Local cFilSA3:=xFilial('SA3')

/* Query original para selecionar as vendas no periodo

SELECT F2_VEND1 VEND, D2_FORNEC FORN, LEFT(D2_EMISSAO,6) EMI, SUM(D2_TOTAL + D2_VALFRE + D2_SEGURO + D2_DESPESA) TOTAL

FROM SF2010, SD2010, SF4010

WHERE F2_EMISSAO BETWEEN '20050301' AND '20060228'
AND F2_FILIAL = D2_FILIAL
AND F2_DOC = D2_DOC
AND D2_TIPO <> 'D'
AND D2_TES = F4_CODIGO
AND F4_DUPLIC = 'S'

GROUP BY F2_FILIAL, F2_VEND1,D2_FORNEC, D2_EMISSAO

ORDER BY F2_VEND1,D2_FORNEC, D2_EMISSAO
*/
cQuery := "SELECT F2_VEND1 VEND, D2_FORNEC FORN, LEFT(D2_EMISSAO,6) EMI, SUM(D2_TOTAL + D2_VALFRE + D2_SEGURO + D2_DESPESA + D2_ICMSRET) TOTAL"

cQuery += " FROM "+RetSQLName("SF2")+" SF2, "+RetSQLName("SD2")+" SD2, "+RetSQLName("SF4")+" SF4 "

cQuery += " WHERE SF2.D_E_L_E_T_ <> '*'"
cQuery += "   AND SD2.D_E_L_E_T_ <> '*'"
cQuery += "   AND SF4.D_E_L_E_T_ <> '*'"
cQuery += "   AND LEFT(F2_EMISSAO,6) BETWEEN '"+cAnoI+cMesI+"' AND '"+cAnoF+cMesF+"'"
cQuery += "   AND F2_FILIAL = D2_FILIAL"
cQuery += "   AND F2_DOC = D2_DOC"
cQuery += "   AND D2_TIPO <> 'D' "
cQuery += "   AND D2_TES = F4_CODIGO"
cQuery += "   AND F4_DUPLIC = 'S' "
cQuery += "   AND D2_FORNEC IN ('000004','000036','000041','000108','000261','000285','000338')"

If !Empty(cVend)
	cQuery += "   AND F2_VEND1 = '"+cVend+"'"
EndIf
cQuery += " GROUP BY F2_FILIAL, F2_VEND1,D2_FORNEC, D2_EMISSAO"
cQuery += " ORDER BY F2_VEND1,D2_FORNEC, D2_EMISSAO"

cQuery := ChangeQuery(cQuery)
dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'TRB', .F., .T.)
memowrite('DIPR60A.SQL',cQuery)
//------------------------------------------------------------
// Grava as vendas do periodo no arq temporario
//------------------------------------------------------------
TRB->(dbGotop())
ProcRegua(nCount)

SA1->(dbSetOrder(1))
SA2->(dbSetOrder(1))
SA3->(dbSetOrder(1))

Do while TRB->(!EOF())
	
	If nCount<1
		nCount:= 1000
		ProcRegua(nCount)
	EndIf
	
	nCount--
	IncProc('Vend '+AllTrim(TRB->VEND)+' Forn: '+Alltrim(TRB->FORN)+' Ano: '+Substr(TRB->EMI,1,4)+' Mes: '+Substr(TRB->EMI,5,2))
	
	If !Work->(dbSeek(TRB->VEND + TRB->FORN))
		Work->(RecLock("Work",.T.))
		Work->VEND    :=TRB->VEND
		Work->FORN    :=TRB->FORN
		Work->NOMEVEND:=If(SA3->(dbSeek(cFilSA3+TRB->VEND)),SA3->A3_NOME,"")
		Work->NOMEFORN:=If(SA2->(dbSeek(cFilSA2+TRB->FORN)),SA2->A2_NOME,"")
	Else
		Work->(RecLock("Work",.f.))
	EndIf
	
	Work->TOTAL:=Work->TOTAL + TRB->TOTAL
	nTotMes := Work->(FieldGet(FieldPos('M'+AllTrim(TRB->EMI)))) + TRB->TOTAL
	Work->(Fieldput(FieldPos('M'+AllTrim(TRB->EMI)),nTotMes))
	Work->(MsUnlock("Work"))
	
	TRB->(dbSkip())
	
EndDo

TRB->(dbCloseArea())

Return(.t.)
//------------------------------------------------------------
// Query que seleciona as devoluções e subtrai das vendas
//------------------------------------------------------------
Static Function Dip60Devolucoes
//------------------------------------------------------------
Local lRetorno:=.t.
Local cQuery
Local nCount:=1000
Local nTotMes
Local cFilSA1:=xFilial('SA1')
Local cFilSA2:=xFilial('SA2')
Local cFilSA3:=xFilial('SA3')

/* Query original para selecionar as devoluçoes de clientes

SELECT A1_VEND VEND, D1_FORNECE FORN,  LEFT(D1_DTDIGIT,6) EMI , SUM(D1_TOTAL + D1_VALFRE + D1_SEGURO + D1_DESPESA)  TOTAL

FROM SF1010, SD1010, SD2010, SF4010,SA1010

WHERE SF1010.D_E_L_E_T_ <> '*'
AND SD1010.D_E_L_E_T_ <> '*'
AND SD2010.D_E_L_E_T_ <> '*'
AND SF4010.D_E_L_E_T_ <> '*'
AND SA1010.D_E_L_E_T_ <> '*'
AND F1_DTDIGIT BETWEEN '20050301' AND '20060228'
AND F1_FILIAL = D1_FILIAL
AND F1_DOC = D1_DOC
AND D1_TIPO   = 'D'
AND D1_FORNECE = A1_COD
AND D1_LOJA    = A1_LOJA
AND D1_FILIAL = D2_FILIAL
AND D1_NFORI  = D2_DOC
AND D1_ITEMORI= D2_ITEM
AND D1_TES    = F4_CODIGO
AND F4_DUPLIC = 'S'

GROUP BY A1_VEND, D1_FORNECE, D1_DTDIGIT

ORDER BY A1_VEND,D1_FORNECE, D1_DTDIGIT
*/
cQuery := "SELECT A1_VEND VEND, B1_PROC FORN,  LEFT(D1_DTDIGIT,6) EMI , SUM(D1_TOTAL + D1_VALFRE + D1_SEGURO + D1_DESPESA + D1_ICMSRET)  TOTAL"

cQuery += " FROM "+RetSQLName("SF1")+" SF1,"
cQuery += " "+RetSQLName("SD1")+" SD1,"
cQuery += " "+RetSQLName("SD2")+" SD2,"
cQuery += " "+RetSQLName("SF4")+" SF4,"
cQuery += " "+RetSQLName("SA1")+" SA1,"
cQuery += " "+RetSQLName("SB1")+" SB1 "

cQuery += " WHERE SF1.D_E_L_E_T_ <> '*'"
cQuery += "   AND SD1.D_E_L_E_T_ <> '*'"
cQuery += "   AND SD2.D_E_L_E_T_ <> '*'"
cQuery += "   AND SF4.D_E_L_E_T_ <> '*'"
cQuery += "   AND SA1.D_E_L_E_T_ <> '*'"
cQuery += "   AND SB1.D_E_L_E_T_ <> '*'"
cQuery += "   AND LEFT(F1_DTDIGIT,6) BETWEEN '"+cAnoI+cMesI+"' AND '"+cAnoF+cMesF+"'"
cQuery += "   AND F1_FILIAL = D1_FILIAL"
cQuery += "   AND F1_DOC = D1_DOC"
cQuery += "   AND F1_SERIE = D1_SERIE"
cQuery += "   AND F1_FORMUL = 'S'"
cQuery += "   AND D1_FORMUL = 'S'"
cQuery += "   AND D1_TIPO   = 'D'"
cQuery += "   AND D1_FORNECE = A1_COD"
cQuery += "   AND D1_LOJA    = A1_LOJA"
cQuery += "   AND D1_FILIAL = D2_FILIAL"
cQuery += "   AND D1_NFORI  = D2_DOC"
cQuery += "   AND D1_ITEMORI= D2_ITEM"
cQuery += "   AND D1_TES    = F4_CODIGO"
cQuery += "   AND F4_DUPLIC = 'S'" 
cQuery += "   AND D1_COD = B1_COD" 
cQuery += "   AND D2_FORNEC IN ('000004','000036','000041','000108','000261','000285','000338')"
//cQuery += "     AND D1_FORNEC IN ('000004','000036','000041','000108','000261','000285','000338')"
If !Empty(cVend)
	cQuery += "   AND A1_VEND = '"+cVend+"'"
EndIf
//cQuery += "     AND A1_VEND  IN ('000186','000187','000188')"
cQuery += " GROUP BY A1_VEND, B1_PROC, D1_DTDIGIT"

cQuery += " ORDER BY A1_VEND, B1_PROC, D1_DTDIGIT"

cQuery:=ChangeQuery(cQuery)
dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'TRB', .F., .T.)
MemoWrite('DIPR60B.SQL',cQuery)
//------------------------------------------------------------
// Subtrai as devoluções das vendas selecionadas do periodo
//------------------------------------------------------------
TRB->(dbGotop())
ProcRegua(nCount)

Do while TRB->(!EOF())
	
	If nCount<1
		nCount:= 1000
		ProcRegua(nCount)
	EndIf
	
	nCount--
	IncProc('Vend '+AllTrim(TRB->VEND)+' Forn: '+Alltrim(TRB->FORN)+' Ano: '+Substr(TRB->EMI,1,4)+' Mes: '+Substr(TRB->EMI,5,2))
	
	If !Work->(dbSeek(TRB->VEND + TRB->FORN))
		Work->(RecLock("Work",.T.))
		Work->VEND    :=TRB->VEND
		Work->FORN    :=TRB->FORN
		Work->NOMEVEND:=If(SA3->(dbSeek(cFilSA3+TRB->VEND)),SA3->A3_NOME,"")
		Work->NOMEFORN:=If(SA2->(dbSeek(cFilSA2+TRB->FORN)),SA2->A2_NOME,"")
	Else
		Work->(RecLock("Work",.f.))
	EndIf
	
	Work->TOTAL:=Work->TOTAL - TRB->TOTAL
	nTotMes := Work->(FieldGet(FieldPos('M'+AllTrim(TRB->EMI)))) - TRB->TOTAL
	Work->(Fieldput(FieldPos('M'+AllTrim(TRB->EMI)),nTotMes))
	Work->(MsUnlock("Work"))
	
	TRB->(dbSkip())
	
EndDo

TRB->(dbCloseArea())

Return
//------------------------------------------------------------
Static Function DipPergDiverg(lLer)
//------------------------------------------------------------
Local aRegs:={}
Local lIncluir
Local i,j

SX1->(dbSetOrder(1))

aAdd(aRegs,{cPerg,"01","Ano Final             ?","","","MV_CH1","C",004,0,0,"G","","MV_PAR01","","","", cAno,"","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"02","Mes Final             ?","","","MV_CH2","C",002,0,0,"G","","MV_PAR02","","","", cMes ,"","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"03","Quantos meses (max 12)?","","","MV_CH3","C",002,0,0,"G","","MV_PAR03","","","", cQtde,"","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"04","Vendedor              ?","","","MV_CH3","C",006,0,0,"G","","MV_PAR03","","","", cVend,"","","","","","","","","","",""})

For i:=1 to len(aRegs)
	lIncluir:=!SX1->(dbSeek(cPerg+aRegs[i,2]))
	If !lIncluir.and.lLer
		aRegs[i,17]:=SX1->X1_CNT01
	EndIf
	SX1->(RecLock("SX1",lIncluir))
	For j:=1 to SX1->(FCount())
		If j <= len(aRegs[i])
			SX1->(FieldPut(j,aRegs[i,j]))
		Endif
	Next
	SX1->(MsUnlock("SX1"))
Next

cAno :=Left(aRegs[01,17],4)
cMes :=Left(aRegs[02,17],2)
cQtde:=Left(aRegs[03,17],2)
cVend:=Left(aRegs[04,17],6)

Return(.t.)
//------------------------------------------------------------
Static Function DIPR060Quebra()
//------------------------------------------------------------
If cCodVen <> Work->VEND .and. Empty(cCodVen)
	linha+=2
	@ linha, 001 psay 'Vendedor: '+AllTrim(Work->VEND)+' - '+Alltrim(WORK->NOMEVEND)
	linha++
ElseIf !Empty(cCodVen) .and. cCodVen <> Work->VEND
	linha++
	If nQFat > 1
		For wi:=3 to 15
			@ linha, T_LEN[wi,2] psay '------------'
		Next wi
		linha++
		i:=1
		For wi:=3 to 15
			@ linha, T_LEN[wi,2] psay Transform(aTotais[i],"@ke 9,999,999.99")
			aTotais[i]:= 0
			i++
		Next wi
		linha++
	EndIf
	nQFat:=0
	nQVen:=0
	If Work->(!EOF())
		linha++
		@ Linha, 001 psay 'Vendedor: '+AllTrim(Work->VEND)+' - '+Alltrim(WORK->NOMEVEND)
		linha++
	EndIf
EndIf
If linha>=55
	Roda(0,Space(10),"M")
	linha := 56
	DIPR060Cabec()
	linha+=2
	@ linha, 001 psay 'Vendedor: '+AllTrim(Work->VEND)+' - '+Alltrim(WORK->NOMEVEND)
	linha++
EndIf
cCodVen:=WORK->VEND
nQFat+=  WORK->TOTAL
nQVen++
i:=1
For wi:=5 to 17
	aTotais[i] += Work->(FieldGet(wi))
	i++
Next wi
Return(.T.)
//------------------------------------------------------------
Static Function Dipr060Final()
//------------------------------------------------------------
Local lEof := Work->(Eof())
If nQFat > 1
	If linha>=55
		Roda(0,Space(10),"M")
		linha := 56
		DIPR060Cabec()
		linha+=2
		If lEof
		   Work->(dbSkip(-1))
		EndIf   
		@ linha, 001 psay 'Vendedor: '+AllTrim(Work->VEND)+' - '+Alltrim(WORK->NOMEVEND)
		linha++
		If lEof
		   Work->(dbSkip())
		EndIf   
	EndIf
	linha++
	For wi:=3 to 15
		@ linha, T_LEN[wi,2] psay '------------'
	Next wi
	linha++
	i:=1
	For wi:=3 to 15
		@ linha, T_LEN[wi,2] psay Transform(aTotais[i],"@ke 9,999,999.99")
		aTotais[i]:= 0
		i++
	Next wi
	linha++
EndIf
Return(.T.)
//------------------------------------------------------------
Static Function DIPR060Cabec()
//------------------------------------------------------------
local b_lin :={|valor,ind| F_Ler_Tab(R_Campos,ind)}
Local tamanho := Adados[5]
Local nAsterisco
Do Case
	Case Tamanho=="P";nAsterisco:=80
	Case Tamanho=="M";nAsterisco:=132
	Case Tamanho=="G";nAsterisco:=220
EndCase
If Linha>55
	Cabec(titulo,cabec1,cabec2,nomeprog,tamanho,GetMv("MV_COMP"))
	If Empty(cabec1) .And. Empty(cabec2)
		@ PROW()+1,T_Len[1,2]-1 PSAY REPLI('*',nAsterisco)
	Endif
	Linha:=PROW()+1 ; l_tag:=say_tit
	AEVAL(R_Campos, b_lin)
	Linha++ ; l_tag:=say_rep
	AEVAL(R_Campos, b_lin)
Endif
Return(.T.)

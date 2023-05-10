/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Funcao    ³ DIPR045  ³ Autor ³ RAFAEL DE CAMPOS FALCO³ Data ³ 25/03/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Total de vendas mês a mês                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ DIPR045                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Especifico DIPROMED                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
#include "rwmake.ch"
#INCLUDE "TBICONN.CH"
#INCLUDE "FILEIO.CH"

User Function DIPR045()
Local _xArea		:= GetArea()
Local titulo		:= OemTOAnsi("Levantamento dos custos - Por Cliente e Período",72)
Local cDesc1		:= (OemToAnsi("Este programa tem como objetivo emitir um relat¢rio",72))
Local cDesc2		:= (OemToAnsi("com levantamento dos custos por cliente.",72))
Local cDesc3		:= (OemToAnsi("Conforme parametros definidos pelo o usuario.",72))
Local _dDatIni	    := ""
Local _dDatFim	    := ""   
Local cUserAut      := GetMV("MV_URELFAT") // MCVN - 04/05/09        

Private aPar2		:= ""
Private aReturn	:= {"Bco A4", 1,"Administracao", 1, 2, 1,"",1}
Private li			:= 67
Private tamanho	:= "G"
Private limite		:= 220
Private nomeprog	:= "DIPR045"

// Private cPerg		:= "DIPR45"
// FPADR(cPerg, cArq, cCampo, cTipo)  - Para ajustar o tamanho das perguntas no SX1- uso generico
PRIVATE cPerg  	:= U_FPADR( "DIPR45","SX1","SX1->X1_GRUPO"," " ) //Função criada por Sandro em 19/11/09.

Private nLastKey	:= 0
Private lEnd		:= .F.
Private wnrel		:= "DIPR045"
Private cString	:= "SD2"
Private m_pag		:= 1
Private cWorkFlow	:= "" 
Private _cDipUsr	:= U_DipUsr()

U_DIPPROC(ProcName(0),_cDipUsr) // JBS 05/10/2005 - Gravando o nome do Programa no SZU

// MCVN - 04/05/09    
If !(Upper(_cDipUsr) $ cUserAut)
	Alert(Upper(_cDipUsr)+", você não tem autorização para utilizar esta rotina. Qualquer dúvida falar com Eriberto!","Atenção")	
	Return()
EndIF  

/*If AllTrim(Upper(_cDipUsr)) <> 'ERIBERTO'
	If AllTrim(Upper(_cDipUsr)) <> 'FALCO'
		MSGSTOP("Voce nao é o Eriberto","Usuario sem autorizacao!")
		Return
	EndIf
EndIf*/

AjustaSX1(cPerg)                // Verifica perguntas. Se nao existe INCLUI.

If !Pergunte(cPerg,.T.)    // Solicita parametros
	Return
EndIf                      

wnrel := SetPrint(cString,wnrel,cPerg,Titulo,cDesc1,cDesc2,cDesc3,.f.,,.f.,tamanho,,.f.,,,,,)

If nLastKey == 27
	Return
Endif
	
SetDefault(aReturn,cString)

Processa({|lEnd| RunProc45()},"Totalizando custos...")

RptStatus({|lEnd| RodaRel45()},"Imprimindo levantamento dos custos...")

Set device to Screen
	
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se em disco, desvia para Spool                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If aReturn[5] == 1    // Se Saida para disco, ativa SPOOL
	Set Printer TO
	Commit
	ourspool(wnrel)
Endif

RestArea(_xArea)

Return

//////////////////////////////////////////////////////////////////////
Static Function RunProc45()

ProcRegua(150)
For _x := 1 to 50
	IncProc( "Processando dados do banco... ")
Next

/*
SELECT D2_CLIENTE, D2_LOJA, D2_EMISSAO, D2_COD, B1_DESC, D2_TOTAL, D2_CUSDIP*D2_QUANT D2_CUSTO,D2_COMIS1
FROM SD2010, SB1010, SF4010
WHERE SD2010.D_E_L_E_T_ <> '*' 
  AND SB1010.D_E_L_E_T_ <> '*'
  AND SF4010.D_E_L_E_T_ <> '*'
  AND D2_EMISSAO BETWEEN '20040201' AND '20040231'
  AND D2_CLIENTE = '000271'
  AND D2_COD = B1_COD
  AND D2_TES = F4_CODIGO
  AND F4_DUPLIC = 'S'
ORDER BY D2_COD, D2_EMISSAO
*/

QRY1 := " SELECT D2_CLIENTE, D2_LOJA, D2_EMISSAO, D2_COD, B1_DESC, D2_TOTAL, D2_CUSDIP*D2_QUANT D2_CUSTO,D2_COMIS1"
QRY1 += " FROM " + RetSQLName("SD2") + ", " + RetSQLName("SB1") + ", " + RetSQLName("SF4")
QRY1 += " WHERE D2_EMISSAO BETWEEN '" + DTOS(MV_PAR01) + "' AND '" + DTOS(MV_PAR02) + "'"
QRY1 += " AND D2_CLIENTE = '" + MV_PAR03 + "'"
QRY1 += " AND D2_COD = B1_COD"
QRY1 += " AND D2_TES = F4_CODIGO"
QRY1 += " AND F4_DUPLIC = 'S'"
QRY1 += " AND " + RetSQLName("SD2") + ".D_E_L_E_T_ = ''"
QRY1 += " AND " + RetSQLName("SB1") + ".D_E_L_E_T_ = ''"
QRY1 += " ORDER BY D2_COD, D2_EMISSAO"

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
// Processa Query SQL
TcQuery QRY1 NEW ALIAS "QRY1"         // Abre uma workarea com o resultado da query
DbSelectArea("QRY1")
QRY1->(dbGotop())

ProcRegua(150)
For _x := 1 to 150
	IncProc( "Fim do Processando... ")
Next

Return(.T.)



//////////////////////////////////////////////////////////////////////
Static Function RodaRel45()
Local cArq		:= ""
Local cCampos	:= ""
Local nHandle	:= ""
Local cWorkFlow:= "N"
Local nTot_Val	:= 0
Local nTot_Cus := 0
Local nTot_Com := 0
Local _cTitulo	:= "Vendas por cliente"
Local _cDesc1	:= Space(02) + MV_PAR03 + "-" + POSICIONE('SA1',1,xFilial('SA1') + MV_PAR03,"A1_NOME") + Space(16) + "Período de " + Substr(DtoS(MV_PAR01),7,2) + "/" + Substr(DtoS(MV_PAR01),5,2) + "/" + Substr(DtoS(MV_PAR01),1,4) +" até " + Substr(DtoS(MV_PAR02),7,2)+ "/" + Substr(DtoS(MV_PAR02),5,2) + "/" + Substr(DtoS(MV_PAR02),1,4)
Local _cDesc2	:= "  Emissão       Código-Produto                                                                                                                Total         Custo       % Comissão       Valor Comissão"

*0                                                                                                   1                                                                                                   2
*0         1         2         3         4         5         6         7         8         9         0         1         2         3         4         5         6         7         8         9         0         1         2
*01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
*---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*  999999-XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX                 Período de DD/MM/AAAA até DD/MM/AAAA
*  Emissão       Código-Produto                                                                                                                Total         Custo       % Comissão       Valor Comissão 
*---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*  99/99/9999    999999-XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX        999.999,99    999.999,99            99,99           999.999,99
*---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*                TOTAL............................................................................................................        999.999,99    999.999,99                            999.999,99
*---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

DbSelectArea("QRY1")
QRY1->(DbGoTop())
Do While QRY1->(!Eof())
		
	If lAbortPrint
		@ li+1,00 PSAY "*** CANCELADO PELO OPERADOR ***"
		Exit
	Endif
	
	If li > 56
		li := u_MYCabec(_cTitulo,_cDesc1,_cDesc2,nHandle,cWorkFlow)
	EndIf

	@ li,002 PSay SubStr(QRY1->D2_EMISSAO,7,2) + "/" + SubStr(QRY1->D2_EMISSAO,5,2) + "/" + SubStr(QRY1->D2_EMISSAO,1,4)
	@ li,016 PSay AllTrim(QRY1->D2_COD) + "-" + QRY1->B1_DESC
	@ li,137 PSay Transform(QRY1->D2_TOTAL , "@E 999,999.99")
	@ li,151 PSay Transform(QRY1->D2_CUSTO , "@E 999,999.99")
	@ li,173 PSay Transform(QRY1->D2_COMIS1, "@E 99.99")	
	@ li,189 PSay Transform((QRY1->D2_TOTAL * QRY1->D2_COMIS1 / 100) , "@E 999,999.99")
	nTot_Val += QRY1->D2_TOTAL
	nTot_Cus += QRY1->D2_CUSTO
	nTot_Com += (QRY1->D2_TOTAL * QRY1->D2_COMIS1 / 100)
	li++                    
	
	QRY1->(DbSkip())
	
EndDo	

If li > 56
	li := u_MYCabec(_cTitulo,_cDesc1,_cDesc2,nHandle,cWorkFlow)
EndIf
	@ li,000 PSay Replicate("-",220)
	li++
	
If li > 56
	li := u_MYCabec(_cTitulo,_cDesc1,_cDesc2,nHandle,cWorkFlow)
EndIf
	@ li,016 PSay "TOTAL............................................................................................................"
	@ li,137 PSay Transform(nTot_Val , "@E 999,999.99")
	@ li,151 PSay Transform(nTot_Cus , "@E 999,999.99")
	@ li,189 PSay Transform(nTot_Com , "@E 999,999.99")

dbSelectArea("QRY1")
QRY1->(dbCloseArea())
Return(.T.)

/////////////////////////////////////////////////////////////////////////////
Static Function AjustaSX1(cPerg)
_sAlias := Alias()
dbSelectArea("SX1")
dbSetOrder(1)                                                                    

aRegs:={}

//------------ Grupo/Ordem/Pergunta/PERGING/PERGESP/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05/F3

aAdd(aRegs,{cPerg,"01","Emissao de         ?","","","mv_ch1","D",8,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"02","Emissao ate        ?","","","mv_ch2","D",8,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"03","Cliente            ?","","","mv_ch3","C",6,0,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","SA1","",""})

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
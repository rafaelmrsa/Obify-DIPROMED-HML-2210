/*
�����������������������������������������������������������������������������
���Funcao    � DIPR046  � Autor � RAFAEL DE CAMPOS FALCO� Data � 23/03/04 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Total de vendas m�s a m�s                                  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � DIPR046                                                    ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Especifico DIPROMED                                        ���
�������������������������������������������������������������������������Ĵ��
�����������������������������������������������������������������������������
*/
#include "rwmake.ch"
#INCLUDE "TBICONN.CH"
#INCLUDE "FILEIO.CH"

User Function DIPR046()
Local _xArea		:= GetArea()
Local titulo		:= OemTOAnsi("Posicao de Vendas m�s a m�s - analitico - Por Per�odo",72)
Local cDesc1		:= (OemToAnsi("Este programa tem como objetivo emitir um relat�rio",72))
Local cDesc2		:= (OemToAnsi("com a posicao de vendas m�s a m�s.",72))
Local cDesc3		:= (OemToAnsi("Conforme parametros definidos pelo o usuario.",72))
Local	_dDatIni	:= ""
Local	_dDatFim	:= "" 
Local cUserAut      := GetMV("MV_URELFAT") // MCVN - 04/05/09     
Private aPar2		:= ""
Private aReturn	:= {"Bco A4", 1,"Administracao", 1, 2, 1,"",1}
Private li			:= 67
Private tamanho	:= "P"
Private limite		:= 80
Private nomeprog	:= "DIPR046"

// Private cPerg		:= "DIPR46"
// FPADR(cPerg, cArq, cCampo, cTipo)  - Para ajustar o tamanho das perguntas no SX1- uso generico
PRIVATE cPerg  	:= U_FPADR( "DIPR46","SX1","SX1->X1_GRUPO"," " ) //Fun��o criada por Sandro em 19/11/09.

Private nLastKey	:= 0
Private lEnd		:= .F.
Private wnrel		:= "DIPR046"
Private cString	:= "SF2"
Private m_pag		:= 1
Private cWorkFlow	:= ""
U_DIPPROC(ProcName(0),U_DipUsr()) // JBS 05/10/2005 - Gravando o nome do Programa no SZU
/*If AllTrim(Upper(U_DipUsr())) <> 'ERIBERTO'
	If AllTrim(Upper(U_DipUsr())) <> 'FALCO'
		MSGSTOP("Voce nao � o Eriberto","Usuario sem autorizacao!")
		Return
	EndIf
EndIf*/

// MCVN - 04/05/09    
If !(Upper(U_DipUsr()) $ cUserAut)
	Alert(Upper(U_DipUsr())+", voc� n�o tem autoriza��o para utilizar esta rotina. Qualquer d�vida falar com Eriberto!","Aten��o")	
	Return()
EndIF  

AjustaSX1(cPerg)           // Verifica perguntas. Se nao existe INCLUI.

If !Pergunte(cPerg,.T.)    // Solicita parametros
	Return
EndIf                      

wnrel := SetPrint(cString,wnrel,cPerg,Titulo,cDesc1,cDesc2,cDesc3,.f.,,.f.,tamanho,,.f.,,,,,)

If nLastKey == 27
	Return
Endif
	
SetDefault(aReturn,cString)

Processa({|lEnd| RunProc46()},"Totalizando vendas m�s a m�s...")

RptStatus({|lEnd| RodaRel46()},"Imprimindo volume de vendas...")

Set device to Screen
	
//���������������������������������������������������������������������������Ŀ
//� Se em disco, desvia para Spool                                            �
//�����������������������������������������������������������������������������
If aReturn[5] == 1    // Se Saida para disco, ativa SPOOL
	Set Printer TO
	Commit
	ourspool(wnrel)
Endif

RestArea(_xArea)

Return

//////////////////////////////////////////////////////////////////////
Static Function RunProc46()

ProcRegua(150)
For _x := 1 to 50
	IncProc( "Processando dados do banco... ")
Next

/*
SELECT SUBSTRING(F2_EMISSAO,1,6) MESANO, COUNT(*) QUANTOS
FROM SF2010
WHERE F2_EMISSAO BETWEEN '20030101' AND '20041231'
AND F2_TIPO = 'N'
AND SF2010.D_E_L_E_T_ <> '*'
GROUP BY SUBSTRING(F2_EMISSAO,1,6)
ORDER BY SUBSTRING(F2_EMISSAO,1,6)
*/

QRY1 := " SELECT SUBSTRING(F2_EMISSAO,1,6) MESANO, COUNT(*) QUANTOS"
QRY1 += " FROM " + RetSQLName("SF2")
QRY1 += " WHERE F2_EMISSAO BETWEEN '" + DTOS(MV_PAR01) + "' AND '" + DTOS(MV_PAR02) + "'"
QRY1 += " AND F2_TIPO = 'N'"
QRY1 += " AND " + RetSQLName("SF2") + ".D_E_L_E_T_ = ''"
QRY1 += " GROUP BY SUBSTRING(F2_EMISSAO,1,6)"
QRY1 += " ORDER BY SUBSTRING(F2_EMISSAO,1,6)"

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
Static Function RodaRel46()
Local cArq		:= ""
Local cCampos	:= ""
Local nHandle	:= ""
Local cWorkFlow:= "N"
Local nTamMes	:= 0
Local _cTitulo	:= "Posi��o de Pedidos por m�s"
Local _cDesc1	:= "                      Per�odo de " + Substr(DtoS(MV_PAR01),7,2) + "/" + Substr(DtoS(MV_PAR01),5,2) + "/" + Substr(DtoS(MV_PAR01),1,4) +" at� " + Substr(DtoS(MV_PAR02),7,2)+ "/" + Substr(DtoS(MV_PAR02),5,2) + "/" + Substr(DtoS(MV_PAR02),1,4)
Local _cDesc2	:= "                    Ano       M�s                 Quantidade"

DbSelectArea("QRY1")
QRY1->(DbGoTop())


Do While QRY1->(!Eof())

	*0         1         2         3         4         5         6         7         8         9         0         1         2         3         4         5         6         7         8         9         0
	*0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901
	*--------------------------------------------------------------------------------
	*                      Per�odo de DD/MM/AAAA at� DD/MM/AAAA
	*                    Ano       M�s                 Quantidade
	*--------------------------------------------------------------------------------
	*                    9999      XXXXXXXXXXXX           999,999
	*--------------------------------------------------------------------------------
		
	If lAbortPrint
		@ li+1,00 PSAY "*** CANCELADO PELO OPERADOR ***"
		Exit
	Endif
	
	If li > 56
		li := u_MYCabec(_cTitulo,_cDesc1,_cDesc2,nHandle,cWorkFlow)
	EndIf

	nTamMes := 23 - Len(MesExtenso(Val(SubStr(QRY1->MESANO,5,2))))
	
	@ li,020 PSay SubStr(QRY1->MESANO,1,4) + Space(6) + MesExtenso(Val(SubStr(QRY1->MESANO,5,2))) + Space(nTamMes) + Transform(QRY1->QUANTOS, "@E 999,999")
	li++                    
	
	QRY1->(DbSkip())
EndDo	

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
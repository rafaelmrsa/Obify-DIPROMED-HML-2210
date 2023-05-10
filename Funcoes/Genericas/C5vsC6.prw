/*================================================================================\
|Programa  | C5vsC6    | Autor | Rafael de Campos Falco    | Data | 29/09/2004    |
|=================================================================================|
|Desc.     | Relatório conferencia do SC5 com SC6                                 |
|=================================================================================|
|Sintaxe   | C5vsC6                                                              |
|=================================================================================|
|Uso       | Especifico DIPROMED                                                  |
|=================================================================================|
|Histórico |   /  /   -                                                           |
\================================================================================*/

#INCLUDE "RWMAKE.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "FILEIO.CH"

User Function C5vsC6()
Local _xArea      	:= GetArea()
Local titulo      	:= OemTOAnsi("Relatório de Notas Fiscais ou Títulos",72)
Local cDesc1      	:= (OemToAnsi("Este programa tem como objetivo emitir um relat¢rio",72))
Local cDesc2      	:= (OemToAnsi("com a posicao das Notas Fiscais emitidas ou Títulos.",72))
Local cDesc3      	:= (OemToAnsi("Conforme parametros definidos pelo o usuario.",72))
Local _nPos			:= 1
Local _aFeriad		:= {}
Private aPar2		:= ""
Private aReturn    	:= {"Bco A4", 1,"Administracao", 1, 2, 1,"",1}
Private li         	:= 67
Private tamanho    	:= "P"
Private limite     	:= 80
Private nomeprog   	:= "C5vsC6"
Private cPerg      	:= "C5vsC6"
Private nLastKey   	:= 0
Private lEnd       	:= .F.
Private wnrel      	:= "C5vsC6"
Private cString    	:= "SC5"
Private m_pag      	:= 1
Private cWorkFlow  	:= "N"
Private _dDatIni   	:= ""
Private _dDatFim   	:= ""

U_DIPPROC(ProcName(0),U_DipUsr())	 // JBS 05/10/2005 - Gravando o nome do Programa no SZU

AjustaSX1(cPerg)	             // Verifica perguntas. Se nao existe INCLUI

If !Pergunte(cPerg,.T.)    		// Solicita parametros
	Return
EndIf

wnrel := SetPrint(cString,wnrel,cPerg,Titulo,cDesc1,cDesc2,cDesc3,.f.,,.f.,tamanho,,.f.,,,,,)

If nLastKey == 27
	Return
Endif

SetDefault(aReturn,cString)

nomeprog   := "C5vsC6"
RptStatus({|lEnd| ImpRel()},"Montando array para impressão...")

Set device to Screen

/*==========================================================================\
| Se em disco, desvia para Spool                                            |
\==========================================================================*/
If aReturn[5] == 1    // Se Saida para disco, ativa SPOOL
	Set Printer TO
	Commit
	ourspool(wnrel)
Endif

RestArea(_xArea)

Return

//////////////////////////////////////////////////////////////////////
Static FUNCTION ImpRel()

Local aRg5_Sel := {}
Local aRg6_Sel := {}
Local aRg5_Dup := {}
Local aRg6_Dup := {}
Local cNum_Ant := ""
Local nTot_Rg1 := 0
Local nTot_Rg2 := 0
Local _cTitulo := "Relatório de comparação SC5 vs SC6"
Local _cDesc1 := ""
Local _cDesc2 := ""
Local nHandle	:= 0
Local cWorkFlow := "N"

DbSelectArea("SC5")
DbSetOrder(1)

DbSelectArea("SC6")
DbSetOrder(1)

If MV_PAR01 = 1
	SetRegua(133000)
	SC5->(DbSeek( "04" ))
	Do While SC5->(!Eof())
		IncRegua("Montando array da tabela SC5... " + SC5->C5_NUM )
		If !SC6->(DbSeek( xFilial("SC6") + SC5->C5_NUM ))
			Aadd(aRg5_Sel,{SC5->C5_FILIAL, SC5->C5_NUM, SC5->C5_TIPO, SC5->C5_CLIENTE, SC5->C5_LOJACLI, SC5->C5_OPERADO, SC5->C5_VEND1, SC5->C5_NOTA, SC5->C5_SERIE, DtoS(SC5->C5_EMISSAO)})
		Else
			If cNum_Ant == SC5->C5_NUM
				Aadd(aRg5_Dup,{SC5->C5_FILIAL, SC5->C5_NUM, SC5->C5_TIPO, SC5->C5_CLIENTE, SC5->C5_LOJACLI, SC5->C5_OPERADO, SC5->C5_VEND1, SC5->C5_NOTA, SC5->C5_SERIE, DtoS(SC5->C5_EMISSAO)})
			EndIf
		EndIf
		cNum_Ant := SC5->C5_NUM
		SC5->(DbSkip())
	EndDo
	
Else
	
	SetRegua(610000)
	SC6->(DbGoTop())
	SC6->(DbSeek( "04" ))
	cNum_Ant := ""
	Do While SC6->(!Eof())
		IncRegua( "Montando array da tabela SC6... " + SC6->C6_NUM )
		If !SC5->(DbSeek( xFilial("SC5") + SC6->C6_NUM ))
			Aadd(aRg6_Sel,{Alltrim(SC6->C6_FILIAL), Alltrim(SC6->C6_NUM), Alltrim(SC6->C6_TES), Alltrim(SC6->C6_CLI), Alltrim(SC6->C6_LOJA), Alltrim(SC6->C6_ITEM), Alltrim(SC6->C6_PRODUTO), Alltrim(SC6->C6_NOTA), Alltrim(SC6->C6_SERIE), DtoS(SC6->C6_DATFAT)})
		Else
			If cNum_Ant == SC6->C6_NUM
				Aadd(aRg6_Dup,{Alltrim(SC6->C6_FILIAL), Alltrim(SC6->C6_NUM), Alltrim(SC6->C6_TES), Alltrim(SC6->C6_CLI), Alltrim(SC6->C6_LOJA), Alltrim(SC6->C6_ITEM), Alltrim(SC6->C6_PRODUTO), Alltrim(SC6->C6_NOTA), Alltrim(SC6->C6_SERIE), DtoS(SC6->C6_DATFAT)})
			EndIf
		EndIf
		cNum_Ant := SC6->C6_NUM
		While cNum_Ant == SC6->C6_NUM
			SC6->(DbSkip())
		EndDo
	EndDo
	
EndIf
*          1         2         3         4         5         6         7         8         9         0         1         2         3         4         5         6         7         8         9         0
*0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901
*dipr032/v.AP6 6.09    Títulos emitidos de 99 até 99/99/99   Data.: 99/99/99
*---------------------------------------------------------------------------------
* FILIAL NUM      TIPO CLIENTE LOJA OPERADO VEND     NOTA     SERIE
* FILIAL NUM      TES  CLIENTE LOJA ITEM    PRODUTO  NOTA     SERIE    EMISSAO
*---------------------------------------------------------------------------------
* 99     999999   99   999999  99   999999  999999   999999   999      DD/MM/AAAA
*---------------------------------------------------------------------------------
* Total Registros não Localizados no SC6.......................... 9.999.999
* Total Registros Duplicados no SC5 .............................. 9.999.999
*---------------------------------------------------------------------------------
If MV_PAR01 = 1
	_cDesc1 := " Registros da tabela SC5010"
	_cDesc2 := " FILIAL NUM      TES  CLIENTE LOJA ITEM    PRODUTO  NOTA     SERIE    EMISSAO"
	li := 99
	aSort(aRg5_Sel ,,, {|a,b| a[4]+a[10] < b[4]+b[10]})
	aSort(aRg5_Dup ,,, {|a,b| a[4]+a[10] < b[4]+b[10]})
	
	SetRegua(Len(aRg5_Sel))
	
	For xi:=1 To Len(aRg5_Sel)
		
		IncRegua( "Imprimindo array da tabela SC5... " + aRg5_Sel[xi,2] )
		
		If li > 60
			li := u_MYCabec(_cTitulo,_cDesc1,_cDesc2,nHandle,cWorkFlow)
			@ li,001 PSay "Não Localizado no SC6....."
			li++
		EndIf
		@ li,001 PSay aRg5_Sel[xi,1]
		@ li,008 PSay aRg5_Sel[xi,2]
		@ li,017 PSay aRg5_Sel[xi,3]
		@ li,022 PSay aRg5_Sel[xi,4]
		@ li,030 PSay aRg5_Sel[xi,5]
		@ li,035 PSay aRg5_Sel[xi,6]
		@ li,043 PSay aRg5_Sel[xi,7]
		@ li,052 PSay aRg5_Sel[xi,8]
		@ li,061 PSay aRg5_Sel[xi,9]
		@ li,070 PSay Subs(aRg5_Sel[xi,10],7,2) + "/" + Subs(aRg5_Sel[xi,10],5,2) + "/" + Subs(aRg5_Sel[xi,10],1,4)
		nTot_Rg1++
		li++
	Next
	
	@ li,001 PSay Replicate("=",80)
	li++
	If li > 60
		li := u_MYCabec(_cTitulo,_cDesc1,_cDesc2,nHandle,cWorkFlow)
	EndIf
	@ li,001 PSay "Duplicados no SC5....."
	li++
	If li > 60
		li := u_MYCabec(_cTitulo,_cDesc1,_cDesc2,nHandle,cWorkFlow)
	EndIf
	
	For xi:=1 To Len(aRg5_Dup)
		IncRegua( "Imprimindo array da tabela SC5... " + aRg5_Dup[xi,2] )
		If li > 60
			li := u_MYCabec(_cTitulo,_cDesc1,_cDesc2,nHandle,cWorkFlow)
			@ li,001 PSay "Duplicados no SC5....."
			li++
		EndIf
		@ li,001 PSay aRg5_Dup[xi,1]
		@ li,008 PSay aRg5_Dup[xi,2]
		@ li,017 PSay aRg5_Dup[xi,3]
		@ li,022 PSay aRg5_Dup[xi,4]
		@ li,030 PSay aRg5_Dup[xi,5]
		@ li,035 PSay aRg5_Dup[xi,6]
		@ li,043 PSay aRg5_Dup[xi,7]
		@ li,052 PSay aRg5_Dup[xi,8]
		@ li,061 PSay aRg5_Dup[xi,9]
		@ li,070 PSay Subs(aRg5_Dup[xi,10],7,2) + "/" + Subs(aRg5_Dup[xi,10],5,2) + "/" + Subs(aRg5_Dup[xi,10],1,4)
		nTot_Rg2++
		li++
	Next
	
	@ li,001 PSay Replicate("=",80)
	li++
	If li > 60
		li := u_MYCabec(_cTitulo,_cDesc1,_cDesc2,nHandle,cWorkFlow)
	EndIf
	@ li,001 PSay "Total Registros não Localizados no SC6.......................... "
	@ li,066 PSay nTot_Rg1 Picture "@E 999,999,999"
	li++
	If li > 60
		li := u_MYCabec(_cTitulo,_cDesc1,_cDesc2,nHandle,cWorkFlow)
	EndIf
	@ li,001 PSay "Total Registros Duplicados no SC5 .............................. "
	@ li,066 PSay nTot_Rg2 Picture "@E 999,999,999"
	
Else	/// bloco para impressão do SC6
	
	li := 99
	_cDesc1 := " Registros da tabela SC6010"
	_cDesc2 := " FILIAL NUM      TES  CLIENTE LOJA ITEM    PRODUTO  NOTA     SERIE    EMISSAO"
	aSort(aRg6_Sel ,,, {|a,b| a[4]+a[10] < b[4]+b[10]})
	aSort(aRg6_Dup ,,, {|a,b| a[4]+a[10] < b[4]+b[10]})
	
	SetRegua(Len(aRg6_Sel))
	
	For xi:=1 To Len(aRg6_Sel)
		
		IncRegua( "Imprimindo array da tabela SC6... " + aRg6_Sel[xi,2] )
		
		If li > 60
			li := u_MYCabec(_cTitulo,_cDesc1,_cDesc2,nHandle,cWorkFlow)
			@ li,001 PSay "Não Localizado no SC5....."
			li++
		EndIf
		
		@ li,001 PSay aRg6_Sel[xi,1]
		@ li,008 PSay aRg6_Sel[xi,2]
		@ li,017 PSay aRg6_Sel[xi,3]
		@ li,022 PSay aRg6_Sel[xi,4]
		@ li,030 PSay aRg6_Sel[xi,5]
		@ li,035 PSay aRg6_Sel[xi,6]
		@ li,043 PSay aRg6_Sel[xi,7]
		@ li,052 PSay aRg6_Sel[xi,8]
		@ li,061 PSay aRg6_Sel[xi,9]
		@ li,070 PSay Subs(aRg6_Sel[xi,10],7,2) + "/" + Subs(aRg6_Sel[xi,10],5,2) + "/" + Subs(aRg6_Sel[xi,10],1,4)
		nTot_Rg1++
		li++
	Next
	
	@ li,001 PSay Replicate("=",80)
	li++
	If li > 60
		li := u_MYCabec(_cTitulo,_cDesc1,_cDesc2,nHandle,cWorkFlow)
	EndIf
	@ li,001 PSay "Duplicados no SC6....."
	li++
	If li > 60
		li := u_MYCabec(_cTitulo,_cDesc1,_cDesc2,nHandle,cWorkFlow)
	EndIf
	
	For xi:=1 To Len(aRg6_Dup)
		
		IncRegua( "Imprimindo array da tabela SC6... " + aRg6_Dup[xi,2] )
		
		If li > 60
			li := u_MYCabec(_cTitulo,_cDesc1,_cDesc2,nHandle,cWorkFlow)
			@ li,001 PSay "Duplicados no SC6....."
			li++
		EndIf
		
		@ li,001 PSay aRg6_Dup[xi,1]
		@ li,008 PSay aRg6_Dup[xi,2]
		@ li,017 PSay aRg6_Dup[xi,3]
		@ li,022 PSay aRg6_Dup[xi,4]
		@ li,030 PSay aRg6_Dup[xi,5]
		@ li,035 PSay aRg6_Dup[xi,6]
		@ li,043 PSay aRg6_Dup[xi,7]
		@ li,052 PSay aRg6_Dup[xi,8]
		@ li,061 PSay aRg6_Dup[xi,9]
		@ li,070 PSay Subs(aRg6_Dup[xi,10],7,2) + "/" + Subs(aRg6_Dup[xi,10],5,2) + "/" + Subs(aRg6_Dup[xi,10],1,4)
		nTot_Rg2++
		li++
		
	Next
	
	@ li,001 PSay "Total Registros não Localizados no SC5.......................... "
	@ li,066 PSay nTot_Rg1 Picture "@E 999,999,999"
	li++
	If li > 60
		li := u_MYCabec(_cTitulo,_cDesc1,_cDesc2,nHandle,cWorkFlow)
	EndIf
	@ li,001 PSay "Total Registros Duplicados no SC6 .............................. "
	@ li,066 PSay nTot_Rg2 Picture "@E 999,999,999"
EndIf

If li > 60
	li := u_MYCabec(_cTitulo,_cDesc1,_cDesc2,nHandle,cWorkFlow)
EndIf

Return(.T.)
///////////////////////////////////////////////////////////////////////////



Static Function AjustaSX1(cPerg)
_sAlias := Alias()
dbSelectArea("SX1")
dbSetOrder(1)

cPerg := PADR(cPerg, Len(SX1->X1_GRUPO)," " ) // Incluido por Sandro em 18/11/09.

aRegs:={}

//------------ Grupo/Ordem/Pergunta/PERGING/PERGESP/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05/F3

aAdd(aRegs,{cPerg,"01","Escolha a tabela ?","","","mv_ch1","N", 1,0,0,"C","","MV_PAR01","1-SC5","","","","","2-SC6","","","","","","","","","","","","","","","","","","",''})

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
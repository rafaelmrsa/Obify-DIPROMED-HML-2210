/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Funcao    ³ DIPR037  ³ Autor ³ Eriberto Elias     ³ Data ³ 18/08/2003  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Eficiencia da expedicao                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ DIPR037                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Especifico DIPROMED                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ MODIFICADO PARA FAZER A LEITURA DOS DADOS DA TABELA                   ³±±
±±³ SZG010(SEPARADOR / CONFERENTE) => RAFAEL DE CAMPOS FALCO - 02/04/04   ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
#include "rwmake.ch"

User Function DIPR037A()

Local _xArea   := GetArea()

Local titulo     := OemTOAnsi("Eficiencia da expedicao - SEPARADOR/CONFERENTE",72)
Local cDesc1     := OemToAnsi("Este programa tem como objetivo emitir um relat¢rio",72)
Local cDesc2     := OemToAnsi("com as notas emitidas.",72)
Local cDesc3     := OemToAnsi("Conforme parametros definidos pelo o usuario.",72)

Private aReturn   := {"Bco A4", 1,"Faturamento", 1, 2, 1,"",1}
Private li        := 66
Private tamanho   := "P"
Private limite    := 80
Private nomeprog  := "DIPR037"

// Private cPerg     := "DIPR37"
// FPADR(cPerg, cArq, cCampo, cTipo)
PRIVATE cPerg  	:= "DIP37A"

Private nLastKey  := 0
Private lEnd      := .F.
Private wnrel     := "DIPR037"
Private cString   := "SF2"
Private m_pag     := 1
Private QRY1 		:= ""                                                             
Private QRY2 		:= ""

U_DIPPROC(ProcName(0),U_DipUsr()) // JBS 05/10/2005 - Gravando o nome do Programa no SZU

AjustaSX1(cPerg)             // Verifica perguntas. Se nao existe INCLUI

If !Pergunte(cPerg,.T.)     // Solicita parametro
	Return
EndIf

wnrel := SetPrint(cString,wnrel,cPerg,Titulo,cDesc1,cDesc2,cDesc3,.f.,,.f.,tamanho,,.f.,,,,,)

If nLastKey == 27
	Return
Endif

SetDefault(aReturn,cString)

RptStatus({|lEnd| RodaRel()},Titulo)

RestArea(_xArea)

Return

//////////////////////////////////////////////////////////////////////
Static Function RodaRel()
Local _nQtdNotas := 0
Local _nQtdItens := 0
Local _nTotDiaN  := 0
Local _nTotDiaI  := 0
Local _nTotSCN   := 0
Local _nTotSCI   := 0
Local _nTotGerN  := 0
Local _nTotGerI  := 0
Local _cDia 	 := ''
Local _cSC  	 := ''  
Local cSQL 		 := ""
Local lCons 	 := .F.

SetRegua(15000)

For _x := 1 to 1600
	IncRegua( "Preparando os dados... ")
Next

lCons := (Aviso("Atenção","Deseja imprimir consolidado (Matriz+CD)?",{"Sim","Não"},1)==1)
                                   
cSQL := " SELECT "                                                                         
	cSQL += "  CB7_DTFIMS, CB7_XTM, SUM(DISTINCT CB7_NUMITE) ITEM, COUNT(DISTINCT CB9_VOLUME) VOL "
//If mv_par01 == 1
	cSQL += ", CB7_ORDSEP " 
//EndIf                              
If mv_par02 == 1
	cSQL += ", CB9_CODSEP DIPUSU "
Else
	cSQL += ", CB9_CODEMB DIPUSU "
EndIf
cSQL += " 	FROM "
cSQL += 		RetSQLName("CB7")+","+RetSQLName("CB9")
cSQL += " 		WHERE "
cSQL += " 			CB7_FILIAL = CB9_FILIAL AND "
cSQL += " 			CB7_ORDSEP = CB9_ORDSEP AND "
cSQL += " 			CB7_DTFIMS BETWEEN '"+DtoS(mv_par03)+"' AND '"+DtoS(mv_par04)+"' AND "
cSQL += " 			CB7_DTFIMS <> ' ' AND "
If !lCons
	cSQL += " 		CB9_FILIAL = '"+xFilial("CB9")+"' AND "
EndIf

If mv_par02 == 1
	If !Empty(mv_par05)
		cSQL += " 	CB9_CODSEP = '"+mv_par05+"' AND "
	EndIf
Else
	If !Empty(mv_par05)
		cSQL += " 	CB9_CODEMB = '"+mv_par05+"' AND "
	EndIf
EndIf

cSQL += 			RetSQLName("CB9")+".D_E_L_E_T_ = ' ' AND "
cSQL += 			RetSQLName("CB7")+".D_E_L_E_T_ = ' '  "
cSQL += "GROUP BY CB7_DTFIMS, CB7_XTM, "
//If mv_par01 == 1
	cSQL += " CB7_ORDSEP, "
//EndIf                              
If mv_par02 == 1
	cSQL += " CB9_CODSEP "
	cSQL += " ORDER BY CB9_CODSEP "
Else
	cSQL += " CB9_CODEMB "
	cSQL += " ORDER BY CB9_CODEMB "
EndIf                                

cSQL := ChangeQuery(cSQL)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),"QRY1",.T.,.T.) 

TCSETFIELD("QRY1","CB7_DTFIMS","D",8,0)

_cTitulo := "EFICIENCIA EXPEDICAO - "+Iif(mv_par01==1,'Analitico','Sintetico')

	_cDesc1  := 'Periodo: '+dTOc(mv_par03)+' - '+dTOc(mv_par04)
	If mv_par01 ==1
		If mv_par02 == 1
			_cDesc2  := "Separador                Ordem                  Itens             Volumes       "
		Else
			_cDesc2  := "Conferente               Ordem                  Itens             Volumes       "
		EndIf
	Else 
		If mv_par02 == 1
			_cDesc2  := "Separador                                  Ordem         Itens      Volumes       "
		Else
			_cDesc2  := "Conferente                                 Ordem         Itens      Volumes       "
		EndIf
	EndIf

	*                                                                                                    1         1         1         1         1         1         1         1         1         1         2         2         2
	*          1         2         3         4         5         6         7         8         9         0         1         2         3         4         5         6         7         8         9         0         1         2
	*01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
	*Periodo: 99/99/9999 - 99/99/9999           Quantidade              Horario
	*Conferente               Pedido    N.F.         Itens        Pre-nota       Nota
	*99-12345678901234567890  123456  123456    99.999.999        99:99:99   99:99:99
	*            Total 99/99/9999:
	*Total - 12345678901234567890:
	*                 TotaL Geral:99,999,999    99,999,999
	*Periodo: 99/99/9999 - 99/99/9999      Quantidades
	*Conferente                        Notas         Itens
	*99-12345678901234567890      99.999.999    99.999.999
	*                 TotaL GeraL:


_dDia 	  := QRY1->CB7_DTFIMS
_cSC  	  := ''
_cSCAux   := ''
_nTotGSep := 0
_nTotGVol := 0
_nTotGIte := 0
_nTotSep  := 0
_nTotVol  := 0
_nTotIte  := 0

Do While QRY1->(!Eof())
	
	IncRegua( "Imprimindo... ")
	
	If li > 60
		li := Cabec(_cTitulo,_cDesc1,_cDesc2,nomeprog,tamanho) + 1
	EndIf
	
	_cSCAux := AllTrim(Posicione("CB1",1,xFilial("CB1")+QRY1->DIPUSU,"CB1_NOME"))
	
	If mv_par01 == 1  	
		If _dDia <> QRY1->CB7_DTFIMS
			@ li,000 PSay 'Total '+SubStr(DtoS(_dDia),7,2)+'/'+SubStr(DtoS(_dDia),5,2)+'/'+SubStr(DtoS(_dDia),1,4)+':'
			@ li,025 PSay _nTotSep PICTURE '@E 99,999,999'
			@ li,043 PSay _nTotIte PICTURE '@E 99,999,999'
			@ li,061 PSay _nTotVol PICTURE '@E 99,999,999'
			_nTotSep := 0
			_nTotIte := 0
			_nTotVol := 0
			li++
			_dDia := QRY1->CB7_DTFIMS
		EndIf		
		
		If _cSC <> _cSCAux .And. !Empty(_cSC)
			@ li,000 PSay 'Total :'
			@ li,025 PSay _nTotSep PICTURE '@E 99,999,999'
			@ li,043 PSay _nTotIte PICTURE '@E 99,999,999'
			@ li,061 PSay _nTotVol PICTURE '@E 99,999,999'
			_nTotSep := 0
			_nTotIte := 0
			_nTotVol := 0
			li+=2
		EndIf
	EndIf
	
	If _cSC <> _cSCAux
		@ li,000 PSay QRY1->DIPUSU+'-'+_cSCAux
		_cSC := _cSCAux                    
		If mv_par01 == 1
			li++
		EndIf
	EndIf
	
	If mv_par01 == 1 
		@ li,025 PSay QRY1->CB7_ORDSEP+" - "+QRY1->CB7_XTM
		@ li,043 PSay QRY1->ITEM PICTURE '@E 99,999,999'
		@ li,061 PSay QRY1->VOL  PICTURE '@E 99,999,999'
		li++
		
		_nTotSep++
		_nTotIte += QRY1->ITEM
		_nTotVol += QRY1->VOL

		_nTotGSep++
		_nTotGIte += QRY1->ITEM
		_nTotGVol += QRY1->VOL
		
		QRY1->(DbSkip())
		
		If QRY1->(Eof())
			@ li,000 PSay 'Total :'
			@ li,025 PSay _nTotSep PICTURE '@E 99,999,999'
			@ li,043 PSay _nTotIte PICTURE '@E 99,999,999'
			@ li,061 PSay _nTotVol PICTURE '@E 99,999,999'
			li+=2
		EndIf
	Else  // Sintetico
		Do While !QRY1->(Eof()) .And. _cSC == _cSCAux
			_nTotSep++
			_nTotIte += QRY1->ITEM
			_nTotVol += QRY1->VOL

			QRY1->(DbSkip())
 			_cSCAux := AllTrim(Posicione("CB1",1,xFilial("CB1")+QRY1->DIPUSU,"CB1_NOME")) 			
		EndDo
		
		@ li,035 PSay _nTotSep PICTURE '@E 99,999,999'
		@ li,050 PSay _nTotIte PICTURE '@E 99,999,999'
		@ li,061 PSay _nTotVol PICTURE '@E 99,999,999'
		
		li++

		_nTotGSep += _nTotSep
		_nTotGIte += _nTotIte
		_nTotGVol += _nTotVol
		
		_nTotSep := 0
		_nTotIte := 0
		_nTotVol := 0
	EndIf   
EndDo

// Totaliza NF e Itens
li++
@ li,000 PSay 'Total Geral:'
If mv_par01==1
	@ li,025 PSay _nTotGSep PICTURE '@E 99,999,999'
	@ li,043 PSay _nTotGIte PICTURE '@E 99,999,999'
Else                                               
	@ li,035 PSay _nTotGSep PICTURE '@E 99,999,999'
	@ li,050 PSay _nTotGIte PICTURE '@E 99,999,999'
EndIf
@ li,061 PSay _nTotGVol PICTURE '@E 99,999,999'
li++                  

Roda(0,"Bom trabalho!",tamanho)

dbSelectArea("QRY1")
QRY1->(dbCloseArea())

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

/////////////////////////////////////////////////////////////////////////////
Static Function AjustaSX1(cPerg)
_sAlias := Alias()
dbSelectArea("SX1")
dbSetOrder(1)

cPerg := PADR(cPerg, Len(SX1->X1_GRUPO)," " ) // Incluido por Sandro em 17/11/09.

aRegs:={}

//------------ Grupo/Ordem/Pergunta/PERGING/PERGESP/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05/F3

aAdd(aRegs,{cPerg,"01","Analitico/Sintetico?","","","mv_ch1","N",1, 0,1,"C","","mv_par01","Analitico","","","","","Sintetico","","","","","","","",""})
aAdd(aRegs,{cPerg,"02","Por Separ./Confer. ?","","","mv_ch2","N",1, 0,1,"C","","mv_par02","Separador","","","","","Conferente","","","","","","","",""})
aAdd(aRegs,{cPerg,"03","Data inicial       ?","","","mv_ch3","D",8, 0,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"04","Data final         ?","","","mv_ch4","D",8, 0,0,"G","","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"05","Codigo Separ/Confer?","","","mv_ch5","C",6, 0,0,"G","","mv_par05","","","","","","","","","","","","","","","","","","","","","","","","","CB1"})

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

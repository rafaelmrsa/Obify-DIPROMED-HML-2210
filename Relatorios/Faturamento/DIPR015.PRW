/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Funcao    ³ DIPR015  ³ Autor ³ Eriberto Elias     ³ Data ³ 21/05/2002  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Vendas dos produtos por fornecedor                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ DIPR015                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Especifico DIPROMED                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

#include "rwmake.ch"
#IFNDEF WINDOWS
   #DEFINE PSay Say
#ENDIF

User Function DIPR015()

Local _xArea    := GetArea()
Local _xAreaA2  := SA2->(GetArea())
Local _xAreaA1  := SA1->(GetArea())
Local _xAreaD2  := SD2->(GetArea())
Local _xAreaB1  := SB1->(GetArea())
Local cUserAut  := GetMV("MV_URELFAT") // MCVN - 04/05/09    
Local cCompraUsu:= GetMV("ES_USERCOM") // MCVN - 03/06/2009 - FELIPE DURAN - 18/10/2019
// cPerg      := "DIPR15"

// FPADR(cPerg, cArq, cCampo, cTipo)  - Para ajustar o tamanho das perguntas no SX1
PRIVATE cPerg  	:= U_FPADR( "DIPR15","SX1","SX1->X1_GRUPO"," " ) //Função criada por Sandro em 19/11/09.


// MCVN - 04/05/09    
If !(Upper(U_DipUsr()) $ cUserAut .Or. Upper(U_DipUsr()) $ cCompraUsu)
	Alert(Upper(U_DipUsr())+", você não tem autorização para utilizar esta rotina. Qualquer dúvida falar com Departamento de T.I. !!!","Atenção")	
	Return()
EndIF                     

U_DIPPROC(ProcName(0),U_DipUsr()) // JBS 05/10/2005 - Gravando o nome do Programa no SZU
tamanho    := "G"
limite     := 0//Iif( MV_PAR05=='000108',146,179)
titulo     := OemTOAnsi("Relatorio de vendas por FORNECEDOR",72)
cDesc1     := (OemToAnsi("Este programa tem como objetivo emitir um relat¢rio",72))
cDesc2     := (OemToAnsi("de Faturamento por Produto, conforme parƒmetros",72))
cDesc3     := (OemToAnsi("definidos pelo usu rio.",72))
aReturn    := {"Bco A4", 1,"Faturamento", 1, 2, 1,"",1}
nomeprog   := "DIPR015"
nLastKey   := 0
lContinua  := .T.
lEnd       := .F.
li         := 67
wnrel      := "DIPR015"
M_PAG      := 1
cString    := "SD2"

Private _cArqTrb

AjustaSX1(cPerg)             // Verifica perguntas. Se nao existe INCLUI  


Pergunte(cPerg,.T.)     // Solicita parametros
limite     := Iif( MV_PAR05=='000108',146,179)

wnrel:=SetPrint(cString,wnrel,cPerg,Titulo,cDesc1,cDesc2,cDesc3,.T.)

If nLastKey == 27
   Return
Endif

SetDefault(aReturn,cString)

Processa({|lEnd| RunProc()},Titulo)

RptStatus({|lEnd| RptDetail()},Titulo)

Set device to Screen

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se em disco, desvia para Spool                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If aReturn[5] == 1    // Se Saida para disco, ativa SPOOL
   Set Printer TO
   Commit
   ourspool(wnrel)
Endif


RestArea(_xAreaA2)
RestArea(_xAreaA1)
RestArea(_xAreaB1)
RestArea(_xAreaD2)
RestArea(_xArea)


Return

//////////////////////////////////////////////////////////////////////
Static Function RunProc()

_aCampos := {}
_aTamSX3 := TamSX3("A1_SET_PLA")
AAdd(_aCampos ,{"SETOR", "C",_aTamSX3[1],_aTamSX3[2]})
_aTamSX3 := TamSX3("A1_EST")
AAdd(_aCampos ,{"ESTADO","C",_aTamSX3[1],_aTamSX3[2]})
_aTamSX3 := TamSX3("A1_MUN")
AAdd(_aCampos ,{"CIDADE","C",_aTamSX3[1],_aTamSX3[2]})
_aTamSX3 := TamSX3("A1_NOME")
AAdd(_aCampos ,{"CLIENTE","C",_aTamSX3[1],_aTamSX3[2]})
_aTamSX3 := TamSX3("D2_COD")
AAdd(_aCampos ,{"COD",   "C",_aTamSX3[1],_aTamSX3[2]})
_aTamSX3 := TamSX3("B1_DESC")
AAdd(_aCampos ,{"DESC",  "C",_aTamSX3[1],_aTamSX3[2]})
_aTamSX3 := TamSX3("D2_UM")
AAdd(_aCampos ,{"UM"   , "C",_aTamSx3[1],_aTamSX3[2]})
_aTamSX3 := TamSX3("D2_QUANT")
AAdd(_aCampos ,{"QUANT", "N",_aTamSX3[1],_aTamSX3[2]})
_aTamSX3 := TamSX3("D2_PRCVEN")
AAdd(_aCampos ,{"PRECO", "N",_aTamSX3[1],_aTamSX3[2]})
_aTamSX3 := TamSX3("D2_TES")                          //Reginaldo Borges 16/05/13
AAdd(_aCampos ,{"TES", "C",_aTamSX3[1],_aTamSX3[2]})
_cArqTrb := CriaTrab(_aCampos,.T.)
DbUseArea(.T.,,_cArqTrb,"TRB",.F.,.F.)

_cChave  := Iif(MV_PAR05=='000108','SETOR+CIDADE+COD','ESTADO+CIDADE+CLIENTE+COD')
IndRegua("TRB",_cArqTrb,_cChave,,,"Criando Indice...")


dbSelectArea("SA2")
dbSetOrder(1)
dbSeek(xFilial('SA2')+mv_par05)

dbSelectArea("SD2")
SD2->(DbOrderNickName("D2FOREMI"))
dbSeek(xFilial('SD2')+mv_par05+dTOs(mv_par01),.T.) 


ProcRegua(RECCOUNT())

While !Eof() .and. SD2->D2_FILIAL == xFilial('SD2') .and. SD2->D2_EMISSAO <= mv_par02 .and. SD2->D2_FORNEC == mv_par05 

	//Define o ìndice da SF4 a ser usado                                        |Reginaldo Borges 16/05/13
    SF4->(DbSetOrder(1))                                                        
	                                                                            
	//Busca a TES do item selecionado na SD2                                    |Reginaldo Borges 16/05/13
	If SF4->(DbSeek(xFilial("SF4")+SD2->D2_TES))                                
	  //Se não movimente estoque ou não gera duplicata, não imprime             |Reginaldo Borges 16/05/13
		If (SF4->F4_ESTOQUE != "S") .OR. (SF4->F4_DUPLIC != "S")                
	  //Passa para o proximo registro da SD2 e realiza um pulo no resto do loop	|Reginaldo Borges 16/05/13	
			SD2->(DbSkip())
			Loop
		EndIf
	EndIf

		    	
		    	
              
                                                                                               
   _cChave := TRB->SETOR+TRB->CIDADE+TRB->COD
      
       
   IncProc(OemToAnsi("Data: " + DTOC(SD2->D2_EMISSAO) + " Nota: " + SD2->D2_DOC + '-' + SD2->D2_SERIE))

   //------- FILTRO DO RELATORIO
   DbSelectArea("SD2")
   If SD2->D2_COD < mv_par03 .or. SD2->D2_COD > mv_par04
      dbSkip()
      Loop
   EndIf

   DbSelectArea("SA1")
   DbSetOrder(1)
   DbSeek(xFilial("SA1")+SD2->D2_CLIENTE+SD2->D2_LOJA)
   
   If MV_PAR05=='000108' .AND. (SA1->A1_SET_PLA < '1' .OR. SA1->A1_SET_PLA > '4')
   // filtro SO CLIENTES COM SETOR PLASCALP preenchido!
	  DbSelectArea("SD2")
      dbSkip()
      Loop
   EndIf

   DbSelectArea("SB1")
   DbSetOrder(1)
   DbSeek(xFilial("SB1")+SD2->D2_COD)

   DbSelectArea("TRB")
   _CHAVEBUSCA := Iif(MV_PAR05=='000108',SA1->A1_SET_PLA+SA1->A1_MUN+SD2->D2_COD,SA1->A1_EST+SA1->A1_MUN+SA1->A1_COD+SD2->D2_COD)
   
   If !dbSeek(_CHAVEBUSCA)
	   RecLock("TRB",.T.)
	   TRB->SETOR  := SA1->A1_SET_PLA
	   TRB->ESTADO := SA1->A1_EST
	   TRB->CIDADE := SA1->A1_MUN
	   TRB->CLIENTE:= SA1->A1_NOME
	   TRB->COD    := SD2->D2_COD
	   TRB->DESC   := SB1->B1_DESC
	   TRB->UM     := SD2->D2_UM
	   TRB->QUANT  := SD2->D2_QUANT 
	   TRB->TES    := SD2->D2_TES //Reginaldo Borges 16/05/13
	  //TRB->PRECO := (SB1->B1_UPRC+(SB1->B1_UPRC*SB1->B1_IPI/100))
	 //TRB->PRECO  := (SB1->B1_CUSDIP)  // MCVN - 30/10/2008
	 //TRB->PRECO  := SB1->B1_LISFOR    // MCVN - 26/03/2009
       TRB->PRECO  := (SB1->B1_CUSDIP)  // MCVN - 02/04/2009
       
       
    
   Else                   
   	   RecLock("TRB",.F.)
	   TRB->QUANT  := TRB->QUANT + SD2->D2_QUANT
   EndIf
   MsUnLock()

   dbSelectArea("SD2")
   dbSkip()
    

EndDo

Return

//////////////////////////////////////////////////////////////
Static Function RptDetail()
DbSelectArea("TRB")
DbGoTop()


SetRegua(RecCount())

_cTitulo := "Relatorio Analitico de Vendas dos Produtos fornecidos por "+AllTrim(Upper(SA2->A2_NREDUZ))+" - de: "+dTOc(mv_par01)+' até '+dTOc(mv_par02)
_cDesc1  := Iif(MV_PAR05=='000108',;
'Setor    Municipio                      Produto  Descricao                                                     UM Quantidade    Preco        Total',;
'UF  Municipio                      Cliente                                                      Produto  Descricao                                                     UM Quantidade  TES')

_cDesc2  := ''
_nTOTAL_s  := 0
_nTOTAL_g  := 0
_setor     := ''
_cidade    := ''
_estado    := ''
_cliente   := '' 
                 

Do While !Eof()  
                 
			                            			                  
                 	   
		IncRegua("Imprimindo: " + Iif(MV_PAR05=='000108',TRB->SETOR,TRB->ESTADO) + ' - ' + TRB->CIDADE + ' - ' + TRB->COD)
		
		If li > 65
			li := Cabec(_cTitulo,_cDesc1,_cDesc2,nomeprog,tamanho) + 1
		EndIf
		
		*         1         2         3         4         5         6         7         8         9         0         1         2         3         4         5         6         7
		*12345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456
		*XXXXXXXXXXXXXXX  XXXXXXXXXXXXXXX       XXXXXX   XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX  um 99.999.999 9999,9999.999.999,99
		*etor             Municipio             Produto  Descricao                                                     UM Quantidade    Preco        Total
		*        123456789012345678901234567890
		*F  Municipio                      Cliente90123456789012345678901234567890123456789012345678901 Produto  Descricao                                                     UM Quantidade
		*   123456789012345678901234567890
		If MV_PAR05=='000108'   // PLASCALP
			@ li,000 PSay Iif(_setor == TRB->SETOR,' ','Setor '+TRB->SETOR)
			@ li,009 PSay Iif(_cidade == TRB->CIDADE,' ',TRB->CIDADE)
			@ li,040 PSay Subs(TRB->COD,1,6)
			@ li,049 PSay TRB->DESC
			@ li,111 PSay TRB->UM
			@ li,114 PSay TRB->QUANT             Picture "@E 99,999,999"
			@ li,126 PSay TRB->PRECO             Picture "@E 9999.99"
			@ li,133 PSay TRB->QUANT*TRB->PRECO  Picture "@E 99,999,999.99"
		Else
			@ li,000 PSay Iif(_estado == TRB->ESTADO,' ',TRB->ESTADO)
			@ li,004 PSay Iif(_cidade == TRB->CIDADE,' ',TRB->CIDADE)
			@ li,035 PSay Iif(_cliente== TRB->CLIENTE,' ',TRB->CLIENTE)
			@ li,096 PSay Subs(TRB->COD,1,6)
			@ li,105 PSay TRB->DESC
			@ li,167 PSay TRB->UM
			@ li,170 PSay TRB->QUANT   Picture "@E 99,999,999"
			@ li,182 PSay TRB->TES
			
		EndIf
		
		li++
		
		_nTOTAL_s := _nTOTAL_s + TRB->QUANT*TRB->PRECO
		_nTOTAL_g := _nTOTAL_g + TRB->QUANT*TRB->PRECO
		
		_setor  := TRB->SETOR
		_cidade := TRB->CIDADE
		_estado := TRB->ESTADO
		_cliente:= TRB->CLIENTE
		
		DbSelectArea("TRB")
		DbSkip()
		
		If MV_PAR05=='000108' .AND. (_setor <> TRB->SETOR .or. Eof())
			If li <> 80
				@ li,000 PSay Replic("*",Limite)
				li++
				@ li,113 PSay "Total do Setor "+ _setor +": "
				@ li,133 PSay _nTOTAL_s  Picture "@E 99,999,999.99"
				li++
				@ li,000 PSay Replic("*",Limite)
				li++
				
				_nTotal_s := 0
			EndIf
		EndIf
	
EndDo


If li <> 80
	If MV_PAR05=='000108'
	   @ li,120 PSay "Total Geral: "
	   @ li,133 PSay _nTOTAL_g  Picture "@E 99,999,999.99"
	   li++
	EndIf
   @ li,000 PSay Replic("*",Limite)
   Roda(1,"",Tamanho)
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Deleta arquivos temporarios e Retorna Indices padräes ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("TRB")
DbCloseArea()

Ferase(_cArqTrb+".DBF")
Ferase(_cArqTrb+OrdBagExt())

Return(.T.)

/////////////////////////////////////////////////////////////////////////////
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³VALIDPERG ³ Autor ³                       ³ Data ³          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Verifica as perguntas inclu¡ndo-as caso n„o existam        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Especifico para Clientes Microsiga                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function AjustaSX1(cPerg)
_sAlias := Alias()
dbSelectArea("SX1")
dbSetOrder(1)

aRegs:={}

//------------ Grupo/Ordem/Pergunta/PERGING/PERGESP/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05/F3

   AADD(aRegs,{cPerg,"01","Da Emissao         ?","","","mv_ch1","D", 8,0,0,"G","","mv_par01","","","","","","","","","","","","","",""})
   AADD(aRegs,{cPerg,"02","At‚ a Emissao      ?","","","mv_ch2","D", 8,0,0,"G","","mv_par02","","","","","","","","","","","","","",""})
   AADD(aRegs,{cPerg,"03","Do Produto         ?","","","mv_ch3","C",15,0,0,"G","","mv_par03","","","","","","","","","","","","","",""})
   AADD(aRegs,{cPerg,"04","At‚ o Produto      ?","","","mv_ch4","C",15,0,0,"G","","mv_par04","","","","","","","","","","","","","",""})
   AADD(aRegs,{cPerg,"05","Qual FORNECEDOR    ?","","","mv_ch5","C", 6,0,0,"G","","mv_par05","","","","","","","","","","","","","","","","","","","","","","","","",'SA2'})

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

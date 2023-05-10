/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Funcao      ³ DIPR019  ³ Autor ³ Eriberto Elias     ³ Data ³ 01/08/2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao   ³ Vendas por fornecedor com margem  "fat / custo - 1 * 100"³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe     ³ DIPR019                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso        ³ Especifico DIPROMED                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³                     ATUALIZACOES									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Maximo  01/20/08³ Atualizado para buscar custo no SD2  (Mtz)  	      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Jailton 23/03/10³ Tratamento para chamar a versao nova e antiga do pro-³±±
±±³                ³ grama de acordo com a empresa e filial em uso.       ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
#include "Protheus.ch"

User Function DIPR019()

If cEmpAnt == '04' //.and. cFilAnt == '01'
	//fDipR019() // Versao Anterior, para rodar apenas para a Health Quality (Matriz)
	 U_DipR019c() // Versao para rodar Health Quality CD e Matriz
Else
	U_DipR019a() // Chama a versao MultyEmpresas (Dipromed CD e Health Quality CD)
EndIf

Return(Nil)    
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³fDipR019()ºAutor  ³Eriberto Elias      º Data ³ 01/08/2002  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Versao do programa para rodar uma empresa, a matriz da     º±±
±±º          ³ Health Quality.                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Especifico - Dipromed - Faturamento                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function fDipR019()

Local _xArea   := GetArea()
Local _areaSD1 := SD1->(getarea())
Local _areaSD2 := SD2->(getarea())
Local _areaSF2 := SF2->(getarea())
Local _areaSF4 := SF4->(getarea())
Local _areaSA3 := SA3->(getarea())
Local _areaSA2 := SA2->(getarea())
Local _areaSB1 := SB1->(getarea())   
Local cUserAut  := GetMV("MV_URELFAT") // MCVN - 04/05/09    

//cPerg      := "DIPR19"
// FPADR(cPerg, cArq, cCampo, cTipo)  - Para ajustar o tamanho das perguntas no SX1
PRIVATE cPerg  	 := U_FPADR( "DIPR019","SX1","SX1->X1_GRUPO"," " ) //Função criada por Sandro em 19/11/09.
PRIVATE _cDipUsr := U_DipUsr()
/*
IF cEmpAnt=="04"
	Alert(Upper(_cDipUsr)+", Relatório desativado temporariamente!","Atenção")		
	Return()
EndiF
*/

// MCVN - 04/05/09    
If !(Upper(_cDipUsr) $ cUserAut)                                                                                                  
	Alert(Upper(_cDipUsr)+", você não tem autorização para utilizar esta rotina. Qualquer dúvida falar com Departamento de T.I. !","Atenção")	
//	Alert(Upper(_cDipUsr)+", você não tem autorização para utilizar esta rotina. Qualquer dúvida falar com Eriberto!","Atenção")	
	Return()
EndIF    
    
U_DIPPROC(ProcName(0),_cDipUsr) // JBS 05/10/2005 - Gravando o nome do Programa no SZU
_nFrete   := 0
_nSeguro  := 0
_nDespesa := 0
_nICMSRet := 0

tamanho    := "M"
limite     := 132
titulo     := OemTOAnsi("Vendas por FORNECEDOR com margem",72)
cDesc1     := (OemToAnsi("Este programa tem como objetivo emitir um relat¢rio",72))
cDesc2     := (OemToAnsi("de Faturamento por FORNECEDOR e VENDEDOR.",72))
cDesc3     := (OemToAnsi("Se deixar VENDEDOR vazio, saira todos.",72))
aReturn    := {"Bco A4", 1,"Faturamento", 1, 2, 1,"",1}
nomeprog   := "DIPR019"
nLastKey   := 0
lContinua  := .T.
lEnd       := .F.
li         := 67
wnrel      := "DIPR019"
M_PAG      := 1
cString    := "SD2"

Private _cArqTrb

AjustaSX1(cPerg)             // Verifica perguntas. Se nao existe INCLUI

If !Pergunte(cPerg,.T.)     // Solicita parametros
	Return
EndIf

wnrel := SetPrint(cString,wnrel,cPerg,Titulo,cDesc1,cDesc2,cDesc3,.f.,,.f.,tamanho,,.f.,,,,,)

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

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Deleta arquivos temporarios e Retorna Indices padräes ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("TRB")
DbCloseArea()

Ferase(_cArqTrb+".DBF")
Ferase(_cArqTrb+OrdBagExt())

RestArea(_areaSD1)
RestArea(_areaSD2)
RestArea(_areaSF2)
RestArea(_areaSF4)
RestArea(_areaSA3)
RestArea(_areaSA2)
RestArea(_areaSB1)
RestArea(_xArea)

Return

//////////////////////////////////////////////////////////////////////
Static Function RunProc()  

Local nCusDip := 0
Local cFilSD1 := xFilial("SD1")
Local cFilSD2 := xFilial("SD1")

_aCampos := {}
_aTamSX3 := TamSX3("D2_FORNEC")
AAdd(_aCampos ,{"FORNEC", "C",_aTamSX3[1],_aTamSX3[2]})
_aTamSX3 := TamSX3("D2_TOTAL")
AAdd(_aCampos ,{"FATUR","N",_aTamSX3[1],_aTamSX3[2]})
_aTamSX3 := TamSX3("D2_CUSTO1")
AAdd(_aCampos ,{"CUSTO","N",_aTamSX3[1],_aTamSX3[2]})

_cArqTrb := CriaTrab(_aCampos,.T.)
DbUseArea(.T.,,_cArqTrb,"TRB",.F.,.F.)

_cChave  := 'FORNEC'
IndRegua("TRB",_cArqTrb,_cChave,,,"Criando Indice...(fornec)")

/* Eriberto 10/03/10
//mtz
dbSelectArea("SD2")
dbSetOrder(12)
dbSeek('01'+dTOs(mv_par01),.T.)

//SetRegua(RecCount())
ProcRegua(RecCount())

While SD2->(!Eof()) .and. SD2->D2_FILIAL == '01' .AND. SD2->D2_EMISSAO <= mv_par02
	
	   IncProc(OemToAnsi("Data: " + DTOC(SD2->D2_EMISSAO) + "     Fornecedor: " + SD2->D2_FORNEC))
	
	//------- FILTRO DO RELATORIO
	
	If !(SD2->D2_TIPO $ 'NC')
		SD2->(DbSkip())
		Loop
	EndIf
		
	If SD2->D2_FORNEC < mv_par03 .OR. SD2->D2_FORNEC > mv_par04
		SD2->(dbSkip())
		Loop
	EndIf
	     
	If !Empty(mv_par06)
		If SD2->D2_CLIENTE != mv_par06 
			SD2->(dbSkip())
			Loop
		EndIf
	EndIf
	
	DbSelectArea("SF2")
	dbSetOrder(1)
	If DbSeek("01"+SD2->(D2_DOC+D2_SERIE))
		If !Empty(mv_par05)
			If SF2->F2_VEND1 <> mv_par05
				SD2->(DbSkip())
				Loop
			EndIf
		EndIf
		
	EndIf
	
	DbSelectArea("SF4")
	DbSetOrder(1)
	DbSeek(xFilial("SF4")+SD2->D2_TES)
	If SF4->F4_DUPLIC <> 'S'
		SD2->(DbSkip())
		Loop
	EndIf
	///////////////////////////////////////////////////////////
	
	DbSelectArea("TRB")
	
	If !dbSeek(SD2->D2_FORNEC)
		RecLock("TRB",.T.)
		TRB->FORNEC := SD2->D2_FORNEC
		TRB->FATUR  := SD2->D2_TOTAL
		TRB->CUSTO  := (SD2->D2_QUANT * SD2->D2_CUSDIP)   //CUSTO1
	Else
		RecLock("TRB",.F.)
		TRB->FATUR := TRB->FATUR + SD2->D2_TOTAL
		TRB->CUSTO := TRB->CUSTO + (SD2->D2_QUANT * SD2->D2_CUSDIP)  //CUSTO1
	EndIf
	TRB->(MsUnLock())

	_nFrete   := _nFrete + SD2->D2_VALFRE
	_nSeguro  := _nSeguro + SD2->D2_SEGURO
	_nDespesa := _nDespesa + SD2->D2_DESPESA
	
	SD2->(dbSkip())
EndDo

// DEVOLUCAO mtz
dbSelectArea("SD1")
dbSetOrder(6)
dbSeek('01'+dTOs(mv_par01),.T.)

While SD1->(!Eof()) .and. SD1->D1_FILIAL == '01' .AND. SD1->D1_DTDIGIT <= mv_par02
	
	//------- FILTRO DO RELATORIO
	If SD1->D1_TIPO <> 'D'
		SD1->(DbSkip())
		Loop
	EndIf
		
	If Empty(SD1->D1_ITEMORI)
		SD1->(DbSkip())
		Loop
	EndIf

	If !Empty(mv_par06)
		If SD1->D1_FORNECE != mv_par06 
			SD1->(dbSkip())
			Loop
		EndIf
	EndIf

	If !Empty(mv_par05)
		DbSelectArea("SF2")
		dbSetOrder(1)
		If DbSeek("01"+SD1->(D1_NFORI+D1_SERIORI))
			If SF2->F2_VEND1 <> mv_par05
				SD1->(DbSkip())
				Loop
			EndIf
		EndIf
	EndIf   
	
	DbSelectArea("SF4")
	DbSetOrder(1)
	DbSeek(xFilial("SF4")+SD1->D1_TES)
	If SF4->F4_DUPLIC <> 'S'
		SD1->(DbSkip())
		Loop
	EndIf
	
	DbSelectArea("SB1")
	DbSetOrder(1)
	DbSeek(xFilial("SB1")+SD1->D1_COD)
	If SB1->B1_PROC < mv_par03 .OR. SB1->B1_PROC > mv_par04
		SD1->(dbSkip())
		Loop
	EndIf   
	
	///////////////////////////////////////////////////////////
    // Busca D2_CUSDIP   -  CORRIGINDO CALCULO DO CUSTO DIPROMED DA DEVOLUÇÃO MCVN - 01/10/08
    nCusDip := 0
	DbSelectArea("SD2")
	DbSetOrder(3)
	DbSeek(xFilial("SD2")+SD1->D1_NFORI+SD1->D1_SERIORI+SD1->D1_FORNECE+SD1->D1_LOJA+SD1->D1_COD+SD1->D1_ITEMORI)
	
		If SD2->(D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD+D2_ITEM) ==;
		   SD1->(D1_FILIAL+D1_NFORI+D1_SERIORI+D1_FORNECE+D1_LOJA+D1_COD+D1_ITEMORI)     
	   
	       nCusDip := SD2->D2_CUSDIP
		Endif

	///////////////////////////////////////////////////////////    


	DbSelectArea("TRB")
	
	If !dbSeek(SB1->B1_PROC)
		RecLock("TRB",.T.)
		TRB->FORNEC := SB1->B1_PROC
		TRB->FATUR  := SD1->D1_TOTAL *-1
	  //TRB->CUSTO  := SD1->D1_QUANT * (SB1->B1_UPRC+(SB1->B1_UPRC*SB1->B1_IPI/100)) *-1  //CUSTO1
	  	TRB->CUSTO  := TRB->CUSTO + (SD1->D1_QUANT * nCusDip) *-1  //CUSTO1 MCVN - 01/10/08
	Else
		RecLock("TRB",.F.)
		TRB->FATUR := TRB->FATUR + (SD1->D1_TOTAL *-1)
   //	TRB->CUSTO := TRB->CUSTO + (SD1->D1_QUANT * (SB1->B1_UPRC+(SB1->B1_UPRC*SB1->B1_IPI/100)) *-1)  //CUSTO1
   	   	TRB->CUSTO  := TRB->CUSTO + (SD1->D1_QUANT * nCusDip) *-1  //CUSTO1 MCVN - 01/10/08
	EndIf
	TRB->(MsUnLock())

	_nFrete   := _nFrete - SD1->D1_VALFRE
	_nSeguro  := _nSeguro - SD1->D1_SEGURO
	_nDespesa := _nDespesa - SD1->D1_DESPESA

	SD1->(dbSkip())
EndDo
*/
// cd       


dbSelectArea("SD2")
dbSetOrder(12)
dbSeek(cFilSD2+dTOs(mv_par01),.T.)

While SD2->(!Eof()) .and. SD2->D2_FILIAL == cFilSD2 .AND. SD2->D2_EMISSAO <= mv_par02
	
	IncProc(OemToAnsi("Data: " + DTOC(SD2->D2_EMISSAO) + "     Fornecedor: " + SD2->D2_FORNEC))
	
	//------- FILTRO DO RELATORIO
	
	If !(SD2->D2_TIPO $ 'NC')
		SD2->(DbSkip())
		Loop
	EndIf
		
	If SD2->D2_FORNEC < mv_par03 .OR. SD2->D2_FORNEC > mv_par04
		SD2->(dbSkip())
		Loop
	EndIf
	
	If !Empty(mv_par06)
		If SD2->D2_CLIENTE != mv_par06 
			SD2->(dbSkip())
			Loop
		EndIf
	EndIf

	DbSelectArea("SF2")
	dbSetOrder(1)
	If DbSeek(cFilSD2+SD2->(D2_DOC+D2_SERIE))
		If !Empty(mv_par05)
			If SF2->F2_VEND1 <> mv_par05
				SD2->(DbSkip())
				Loop
			EndIf
		EndIf
		If SF2->F2_VEND1 = '006874'  // MCVN 14/04/11
			SD2->(DbSkip())
			Loop
		EndIf
	EndIf
	
	DbSelectArea("SF4")
	DbSetOrder(1)
	DbSeek(xFilial("SF4")+SD2->D2_TES)
	If SF4->F4_DUPLIC <> 'S' .and. !( SD2->D2_VALFRE + SD2->D2_SEGURO + SD2->D2_DESPESA ) > 0 // JBS 03/08/2010 - Se nao gerou financeiro e nao possui despesas acessorias.
		SD2->(DbSkip())
		Loop
	EndIf
	
	///////////////////////////////////////////////////////////
	
	DbSelectArea("TRB")
	
	If !dbSeek(SD2->D2_FORNEC)
		RecLock("TRB",.T.)
		TRB->FORNEC := SD2->D2_FORNEC
		TRB->FATUR  := If(SF4->F4_DUPLIC = 'S', SD2->D2_TOTAL,0) // JBS 03/08/2010 - Considera o D2_TOTAL apenas quando o mesmo gerou financeiro.
   		TRB->CUSTO  := (SD2->D2_QUANT * SD2->D2_CUSDIP)   //CUSTO1
	Else
		RecLock("TRB",.F.)
		TRB->FATUR := TRB->FATUR + If(SF4->F4_DUPLIC = 'S', SD2->D2_TOTAL,0) // JBS 03/08/2010 - Considera o D2_TOTAL apenas quando o mesmo gerou financeiro.
		TRB->CUSTO := TRB->CUSTO + (SD2->D2_QUANT * SD2->D2_CUSDIP)  //CUSTO1
	EndIf

	TRB->(MsUnLock())

	_nFrete   := _nFrete   + SD2->D2_VALFRE
	_nSeguro  := _nSeguro  + SD2->D2_SEGURO
	_nDespesa := _nDespesa + SD2->D2_DESPESA
	_nICMSRet := _nICMSRet + SD2->D2_ICMSRET                                        
	
	SD2->(dbSkip())
EndDo

// DEVOLUCAO cld
dbSelectArea("SD1")
dbSetOrder(6)
dbSeek(cFilSD1+dTOs(mv_par01),.T.)

While !Eof() .and. SD1->D1_FILIAL == cFilSD1 .AND. SD1->D1_DTDIGIT <= mv_par02
	
	//------- FILTRO DO RELATORIO
	
	If SD1->D1_TIPO <> 'D'
		SD1->(DbSkip())
		Loop
	EndIf
		
	If Empty(SD1->D1_ITEMORI)
		SD1->(DbSkip())
		Loop
	EndIf

	If !Empty(mv_par06)
		If SD1->D1_FORNECE != mv_par06 
  			SD1->(dbSkip())
			Loop
		EndIf
	EndIf

	DbSelectArea("SF2")
	dbSetOrder(1)
	If DbSeek(cFilSD1+SD1->(D1_NFORI+D1_SERIORI))
		If !Empty(mv_par05)
			If SF2->F2_VEND1 <> mv_par05
				SD1->(DbSkip())
				Loop
			EndIf
		Endif
		If SF2->F2_VEND1 = '006874'// MCVN 14/04/11
			SD1->(DbSkip())
			Loop
		EndIf
	EndIf
	
	DbSelectArea("SF4")
	DbSetOrder(1)
	DbSeek(xFilial("SF4")+SD1->D1_TES)
	If SF4->F4_DUPLIC <> 'S' .and. !( SD1->D1_VALFRE + SD1->D1_SEGURO + SD1->D1_DESPESA ) > 0 // JBS 03/08/2010 - Se nao gerou financeiro e nao possui despesas acessorias.
		SD1->(DbSkip())
		Loop
	EndIf
	
	DbSelectArea("SB1")
	DbSetOrder(1)
	DbSeek(xFilial("SB1")+SD1->D1_COD)

	If SB1->B1_PROC < mv_par03 .OR. SB1->B1_PROC > mv_par04
		SD1->(dbSkip())
		Loop
	EndIf

	///////////////////////////////////////////////////////////
    // Busca D2_CUSDIP   -  CORRIGINDO CALCULO DO CUSTO DIPROMED DA DEVOLUÇÃO MCVN - 05/07/2007
    nCusDip := 0
	DbSelectArea("SD2")
	DbSetOrder(3)
	DbSeek(xFilial("SD2")+SD1->D1_NFORI+SD1->D1_SERIORI+SD1->D1_FORNECE+SD1->D1_LOJA+SD1->D1_COD+SD1->D1_ITEMORI)
	
		If SD2->(D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD+D2_ITEM) ==;
		   SD1->(D1_FILIAL+D1_NFORI+D1_SERIORI+D1_FORNECE+D1_LOJA+D1_COD+D1_ITEMORI)     
	   
	       nCusDip := SD2->D2_CUSDIP
		Endif

	///////////////////////////////////////////////////////////    

	DbSelectArea("TRB")
	
	If !dbSeek(SB1->B1_PROC)
		RecLock("TRB",.T.)
		TRB->FORNEC := SB1->B1_PROC
		TRB->FATUR  := If(SF4->F4_DUPLIC = 'S', SD1->D1_TOTAL *-1,0) // JBS 03/08/2010 - Considera o D2_TOTAL apenas quando o mesmo gerou financeiro.
	   //TRB->CUSTO  := SD1->D1_QUANT * (SB1->B1_UPRC+(SB1->B1_UPRC*SB1->B1_IPI/100)) *-1  //CUSTO1
	   	TRB->CUSTO  := TRB->CUSTO + (SD1->D1_QUANT * nCusDip) *-1  //CUSTO1 MCVN - 05/07/2007
	   
	Else
		RecLock("TRB",.F.)
		TRB->FATUR := TRB->FATUR +  If(SF4->F4_DUPLIC = 'S', SD1->D1_TOTAL *-1,0) // JBS 03/08/2010 - Considera o D2_TOTAL apenas quando o mesmo gerou financeiro.
    	//TRB->CUSTO := TRB->CUSTO + (SD1->D1_QUANT * (SB1->B1_UPRC+(SB1->B1_UPRC*SB1->B1_IPI/100)) *-1)  //CUSTO1
	   	TRB->CUSTO  := TRB->CUSTO + (SD1->D1_QUANT * nCusDip) *-1  //CUSTO1 MCVN - 05/07/2007
	EndIf
	TRB->(MsUnLock())
	
	_nFrete   := _nFrete   - SD1->D1_VALFRE
	_nSeguro  := _nSeguro  - SD1->D1_SEGURO
	_nDespesa := _nDespesa - SD1->D1_DESPESA
	_nICMSRet := _nICMSRet - SD1->D1_ICMSRET
	
	SD1->(dbSkip())
EndDo

Return

//////////////////////////////////////////////////////////////
Static Function RptDetail()

Local cUserAuth := GETMV("MV_DIPR019")

If !Empty(mv_par05)
	DbSelectArea("SA3")
	DbSetOrder(1)
	If DbSeek(xFilial("SA3")+mv_par05)
		_cDesc1  := 'Vendedor.: '+AllTrim(SA3->A3_NOME)+' - '+mv_par05
	Else
		_cDesc1  := 'vendedor nao cadastrado'
	EndIf
Else
	_cDesc1  := 'Todos Vendedores'
EndIf

If !Empty(mv_par06)
	DbSelectArea("SA1")
	DbSetOrder(1)
	If DbSeek(xFilial("SA1")+mv_par06)
		_cDesc1  += ' - Cliente.: ' + mv_par06 + ' - ' + AllTrim(SA1->A1_NOME)
	Else
		_cDesc1  += ' Cliente nao cadastrado'
	EndIf
Else
	_cDesc1  += ' Todos Clientes'
EndIf

_cTitulo := "Vendas por fornecedor no periodo de: "+dTOc(mv_par01)+' até '+dTOc(mv_par02)
_cDesc2  := "Fornecedor                        Faturamento"

// BLOQUEIA IMPRESSÃO DA COLUNA DE CUSTO
//If Upper(_cDipUsr) $ 'ERICH/ERIBERTO/JOEL/CRISTIANE/PATRICIA/MAXIMO'
If Upper(_cDipUsr) $ cUserAuth  // MCVN - 16/04/2008
	_cDesc2  := "Fornecedor                        Faturamento            Custo    Margem %"
EndIf

_nTOTAL_f  := 0
_nTOTAL_c  := 0
_nReg      := 0

DbSelectArea("TRB")
DbGoTop()

SetRegua(RecCount())

_cChave  := 'FATUR*-1'
IndRegua("TRB",_cArqTrb,_cChave,,,"Criando Indice...(fatur)")

Do While !Eof() 

//If !(TRB->FORNEC $ '000952/990064/000108/000184/478690')  // temporário - limpando relatório para seu ADEMIR

	IncRegua( "Imprimindo: " + TRB->FORNEC +'-'+ Posicione("SA2",1,xFilial('SA2')+TRB->FORNEC,"A2_NREDUZ"))
	
	If li > 65
		li := Cabec(_cTitulo,_cDesc1,_cDesc2,nomeprog,tamanho) + 1
	EndIf
	
	*         1         2         3         4         5         6         7         8         9         0         1         2         3         4         5         6
	*12345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
	*Fornecedor                        Faturamento            Custo    Margem %
	*XXXXXXXXXXXXXXXXXXXX - 999999  999.999.999,99   999.999.999,99    9999,99
	
	
	@ li,001 PSay AllTrim(Posicione("SA2",1,xFilial('SA2')+TRB->FORNEC,"A2_NREDUZ")) +' - '+ TRB->FORNEC
	@ li,031 PSay TRB->FATUR Picture "@E 999,999,999.99"

	//If Upper(_cDipUsr) $ 'ERICH/ERIBERTO/JOEL/CRISTIANE/PATRICIA/MAXIMO'
	If Upper(_cDipUsr) $ cUserAuth // MCVN - 16/04/2008
		@ li,048 PSay TRB->CUSTO Picture "@E 999,999,999.99"
		@ li,066 PSay Iif(TRB->CUSTO==0,100,((TRB->FATUR/TRB->CUSTO)-1)*100) Picture '@E 9999.99'
	EndIf	

	
	li++
	
	_nReg++

	_nTOTAL_f := _nTOTAL_f + TRB->FATUR
	_nTOTAL_c := _nTOTAL_c + TRB->CUSTO
	
//Endif	//temporário
	DbSelectArea("TRB")
	DbSkip()

EndDo

	If li > 65
		li := Cabec(_cTitulo,_cDesc1,_cDesc2,nomeprog,tamanho) + 1
	EndIf

	@ li,000 PSay Replic("*",Limite)
	li++
	If li > 65
		li := Cabec(_cTitulo,_cDesc1,_cDesc2,nomeprog,tamanho) + 1
	EndIf
	@ li,001 PSay "Total: "
	@ li,031 PSay _nTOTAL_f Picture "@E 999,999,999.99"

//If Upper(_cDipUsr) $ 'ERICH/ERIBERTO/JOEL/CRISTIANE/PATRICIA/MAXIMO'
If Upper(_cDipUsr) $ cUserAuth // MCVN - 16/04/2008
	@ li,048 PSay _nTOTAL_c Picture "@E 999,999,999.99"
	@ li,066 PSay Iif(_nTOTAL_c==0,100,((_nTOTAL_f/_nTOTAL_c)-1)*100) Picture '@E 9999.99'
EndIf	

	li++
	If li > 65
		li := Cabec(_cTitulo,_cDesc1,_cDesc2,nomeprog,tamanho) + 1
	EndIf
	@ li,000 PSay Replic("*",Limite)
	li++
	If li > 65
		li := Cabec(_cTitulo,_cDesc1,_cDesc2,nomeprog,tamanho) + 1
	EndIf
	
	li++
	If li > 65
		li := Cabec(_cTitulo,_cDesc1,_cDesc2,nomeprog,tamanho) + 1
	EndIf
	@ li,001 PSay "Frete"
	@ li,031 PSay _nFrete Picture "@E 999,999,999.99"
	li++
	If li > 65
		li := Cabec(_cTitulo,_cDesc1,_cDesc2,nomeprog,tamanho) + 1
	EndIf
	@ li,001 PSay "Seguro"
	@ li,031 PSay _nSeguro Picture "@E 999,999,999.99"
	li++
	If li > 65
		li := Cabec(_cTitulo,_cDesc1,_cDesc2,nomeprog,tamanho) + 1
	EndIf
	@ li,001 PSay "Despesa"
	@ li,031 PSay _nDespesa Picture "@E 999,999,999.99"
	li++
	If li > 65
		li := Cabec(_cTitulo,_cDesc1,_cDesc2,nomeprog,tamanho) + 1
	EndIf
	@ li,001 PSay "ICMS ST"
	@ li,031 PSay _nICMSRet Picture "@E 999,999,999.99"
	li++
	If li > 65
		li := Cabec(_cTitulo,_cDesc1,_cDesc2,nomeprog,tamanho) + 1
	EndIf
	@ li,000 PSay Replic("*",Limite)
	li++
	If li > 65
		li := Cabec(_cTitulo,_cDesc1,_cDesc2,nomeprog,tamanho) + 1
	EndIf
	@ li,001 PSay "Total Geral: "
	@ li,031 PSay _nTOTAL_f+_nFrete+_nSeguro+_nDespesa+_nICMSRet Picture "@E 999,999,999.99"
	li++
	If li > 65
		li := Cabec(_cTitulo,_cDesc1,_cDesc2,nomeprog,tamanho) + 1
	EndIf
	@ li,000 PSay Replic("*",Limite)
	li++
	If li > 65
		li := Cabec(_cTitulo,_cDesc1,_cDesc2,nomeprog,tamanho) + 1
	EndIf

	Roda(_nReg,Iif(_nReg=1,'Fornecedor',"Fornecedores"),Tamanho)
//EndIf

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
AADD(aRegs,{cPerg,"03","Do FORNECEDOR      ?","","","mv_ch3","C", 6,0,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","",'SA2'})
AADD(aRegs,{cPerg,"04","At‚ o FORNECEDOR   ?","","","mv_ch4","C", 6,0,0,"G","","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","",'SA2'})
AADD(aRegs,{cPerg,"05","Vendedor           ?","","","mv_ch5","C", 6,0,0,"G","","mv_par05","","","","","","","","","","","","","","","","","","","","","","","","",'SA3'})
AADD(aRegs,{cPerg,"06","Cliente            ?","","","mv_ch6","C", 6,0,0,"G","","mv_par06","","","","","","","","","","","","","","","","","","","","","","","","",'SA1'})

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

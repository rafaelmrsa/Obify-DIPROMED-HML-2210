/*====================================================================================\
|Programa  | DIPM008       | Autor | Alexandro Dias             | Data | 08/01/2002   |
|=====================================================================================|
|Descrição | Calcula a Media de Consumo do produto conforme o parametro de meses      |
|          | informado                                                                |
|          |                                                                          |
|=====================================================================================|
|Sintaxe   | DIPM008                                                                  |
|=====================================================================================|
|Uso       | Especifico DIPROMED                                                      |
|=====================================================================================|
|........................................Histórico....................................|
|Rafael    | DD/MM/AA - Descrição                                                     |
|Eriberto  | DD/MM/AA - Descrição                                                     |
\====================================================================================*/

#include "rwmake.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºFun‡„o    ³  DIPM008 º Autor ³  Alexandro Dias    º Data ³  08/01/02   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescri‡„o ³ Calcula a Media de Consumo do produto conforme o parame-   º±±
±±º          ³ tro de meses informado.                                    º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function DIPM008()
         
Local cPerg := "DIPM08"

U_DIPPROC(ProcName(0),U_DipUsr()) // JBS 05/10/2005 - Gravando o nome do Programa no SZU

//³ Valida Pergunta do programa								    ³
AjustaSX1(cPerg)

IF Pergunte(cPerg,.T.)

	Processa({|| U_ProcPonto() })

EndIF
Return

User Function ProcPonto()
Local _xAlias      := GETAREA() //{ Alias(), IndexOrd(), Recno() }
Local _nMediaCons  := 0
Local _nQuantSCK   := 0
Local _nQtPontoPed := 0
Local _nPrazoEnt   := 0
Local _nSaldo      := 0
Local _ProcWhile   := ""
DbSelectArea("SB1")
DbGoTop()
ProcRegua(RecCount())
IF Mv_Par05 == 1
	_ProcWhile := 'SB1->B1_FILIAL == xFilial("SB1") .and. SB1->B1_COD <= MV_PAR02'
	DbSetOrder(1)
	DbSeek(xFilial("SB1")+Mv_Par01,.T.)
Else
	_ProcWhile := 'SB1->B1_FILIAL == xFilial("SB1") .and. SB1->B1_PROC <= MV_PAR04'
	DbSetOrder(6)
	DbSeek(xFilial("SB1")+Mv_Par03,.T.)
EndIF
While !Eof() .and. &_ProcWhile
	_nMediaCons := U_Calc_Media(SB1->B1_COD,Mv_Par06,.F.)
	_nQuantSCK  := U_Proc_SCK(SB1->B1_COD, SB1->B1_PROC, SB1->B1_LOJPROC)
	DbSelectArea("SA2")
	DbSetOrder(1)
	IF DbSeek(xFilial("SA2")+SB1->B1_PROC+SB1->B1_LOJPROC)
		_nPrazoEnt := (_nMediaCons / Mv_par07) * SA2->A2_PRAZO
	EndIF
	_nQtPontoPed := ((_nMediaCons/Mv_par07)*Mv_Par08) + (_nPrazoEnt + _nQuantSCK)
	DbSelectArea("SB1")
	RecLock("SB1",.F.)
	Replace B1_EMIN    With _nQtPontoPed
	Replace B1_ETQDIAS With MV_PAR08
	MsUnLock()
	DbSkip()
	IncProc()
EndDo

RESTAREA(_xAlias)

/*
DbSelectArea(_xAlias[1])
DbSetOrder(_xAlias[2])
DbGoto(_xAlias[3])
*/
Return

/*====================================================================================\
|Programa  | Calc_Media    | Autor | Alexandro Dias             | Data | 08/01/2002   |
|=====================================================================================|
|Descrição | Calcula a Media de Consumo do produto conforme o parametro de meses      |
|          | informado                                                                |
|          |                                                                          |
|=====================================================================================|
|Sintaxe   | Calc_Media(_cProduto,_nMes,_lMesAtual)                                   |
|          | _cProduto = Codigo do Produto.                                           |
|          | _nMes = Quantidade de Meses para calculo da Media                        |
|          | _lMesAtual = Considera Mes Atual=.T./Nao=.F.                             |
|=====================================================================================|
|Uso       | Especifico DIPROMED                                                      |
|=====================================================================================|
|........................................Histórico....................................|
|Rafael    | DD/MM/AA - Descrição                                                     |
|Eriberto  | DD/MM/AA - Descrição                                                     |
\====================================================================================*/
User Function Calc_Media(_cProduto,_nMes,_lMesAtual)

Local _nMesIni := Month(dDataBase)
Local _xArea   := GetArea()
Local _nMedia  := 0
DbSelectArea("SB3")
DbSetOrder(1)
IF DbSeek(xFilial("SB3")+SB1->B1_COD)
	For _nCont := 1 to _nMes
		
		//³ Nao considera o mes atual para calculo da Media			    ³
		IF !_lMesAtual
			_nMesIni := _nMesIni - 1
		EndIF
		IF _nMesIni == 0
			_nMesIni := 12
		EndIF
		_nMedia := _nMedia + &( "SB3->B3_Q" + StrZero(_nMesIni,2) )
		
		//³ Considera o mes atual para calculo da Media		     	    ³
		IF _lMesAtual
			_nMesIni := _nMesIni - 1
		EndIF
	Next
	_nMedia := Int(_nMedia / _nMes)
EndIF
RestArea(_xArea)

Return(_nMedia)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºFun‡„o    ³Proc_SCK  º Autor ³  Alexandro Dias    º Data ³  08/01/02   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescri‡„o ³ Verifica as programacoes de compra em Aberto.              º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

/*====================================================================================\
|Programa  | Proc_SCK      | Autor | Alexandro Dias             | Data | 08/01/2002   |
|=====================================================================================|
|Descrição | Verifica as programacoes de compra em Aberto.                            |
|          |                                                                          |
|          |                                                                          |
|=====================================================================================|
|Sintaxe   | Proc_SCK(_cProduto, cCod_For, cLoj_For)                                  |
|          | _cProduto = Código do Produto.                                           |
|          | cCod_For = Código do fornecedor                                          |
|          | cLoj_For = Loja do fornecedor                                            |
|=====================================================================================|
|Uso       | Especifico DIPROMED                                                      |
|=====================================================================================|
|........................................Histórico....................................|
|Rafael    | 25/02/05 - Posiciona SA2 para identificar prazo de entrega do fornecedor |
+-------------------------------------------------------------------------------------+
|Rafael    | 25/02/05 - Deternima o período de ponto de pedido data inicial e final   |
+-------------------------------------------------------------------------------------+
|Rafael    | 25/02/05 - Ignora programação que estiver fora do período determinado    |
+-------------------------------------------------------------------------------------+
|Eriberto  | DD/MM/AA - Descrição                                                     |
\====================================================================================*/
User Function Proc_SCK(_cProduto, cCod_For, cLoj_For)

Local _xArea        := GetArea()
Local _nTamTotProd  := Len(_cProduto)
Local _nTamOriginal := Len(Alltrim(_cProduto))
Local _cProdProc    := StrZero( Val(_cProduto)+1,_nTamOriginal)+Space(_nTamTotProd-_nTamOriginal)
Local _nQtdProg     := 0
Local nPrz_Ent := 0
Local dDat_Ini := ""
Local dDat_Fim := ""


/// LEVANTAMENTO DO PERÍODO PARA GERAR PONTO DE PEDIDO (RAFAEL - 25/02/05)
DbSelectArea("SA2")
DbSetOrder(1)
IF DbSeek(xFilial("SA2")+cCod_For+cLoj_For)
	nPrz_Ent := SA2->A2_PRAZO // PRAZO DE ENTREGA DO FORNECEDOR
	dDat_Ini := dDataBase // DATA ATUAL
	dDat_Fim := dDataBase + nPrz_Ent + mv_par08 /// DATA FINAL (data atual + prazo de entrega + estoque p/ qtos. dias)
EndIF                                    



//³Carrega as programacoes de venda do produto. ³
DbSelectArea("SCK")
DbSetOrder(3)
DbSeek(xFilial("SCK")+_cProdProc,.T.)
IF Eof()
	DbSkip(-1)
EndIF
IF SCK->CK_PRODUTO >= _cProdProc
	DbSkip(-1)
EndIF
While !Bof() .and. SCK->CK_PRODUTO == _cProduto
	IF Empty(SCK->CK_NUMPV)
		SCJ->(DbSetorder(1))
		IF SCJ->(DbSeek(xFilial("SCJ")+SCK->CK_NUM))
			IF SCJ->CJ_OPCAO == "P"
				SA1->(DbSetOrder(1))
				SA1->(DbSeek(xFilial("SA1")+SCK->CK_CLIENTE+SCK->CK_LOJA))

				/// VERIFICA SE PROGRAMAÇÃO ESTÁ DENTRO DO PERÍODO ESTABELECIDO - (RAFAEL - 25/02/05)
				If CK_ENTREG >= dDat_Ini .AND. CK_ENTREG <= dDat_Fim
					_nQtdProg := _nQtdProg + SCK->CK_QTDVEN
				EndIf	


			EndIF
		EndIF
	EndIF
	DbSelectArea("SCK")
	DbSkip(-1)
EndDo

Return(_nQtdProg)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºFun‡„o    ³VALIDPERG º Autor ³ AP5 IDE            º Data ³  08/01/02   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescri‡„o ³ Verifica a existencia das perguntas criando-as caso seja   º±±
±±º          ³ necessario (caso nao existam).                             º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function AjustaSX1(cPerg)

Local _sAlias := Alias()
Local aRegs := {}
Local i,j
dbSelectArea("SX1")
dbSetOrder(1)

cPerg := PADR(cPerg, Len(SX1->X1_GRUPO)," " ) // Incluido por Sandro em 18/11/09.

// Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05
aAdd(aRegs,{cPerg,"01","Do Produto         ?","","","mv_ch1","C",15,0,0,"G","","mv_par01","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"02","Ate o Produto      ?","","","mv_ch2","C",15,0,0,"G","","mv_par02","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"03","Do Fornecedor      ?","","","mv_ch3","C",06,0,0,"G","","mv_par03","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"04","Ate o Fornecedor   ?","","","mv_ch4","C",06,0,0,"G","","mv_par04","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"05","Ordem Processamento?","","","mv_ch5","N",01,0,0,"C","","mv_par05","Produto","","","","","Fornecedor","","","","","","","",""})
aAdd(aRegs,{cPerg,"06","Quantidade de Meses?","","","mv_ch6","N",02,0,0,"G","","mv_par06","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"07","Quant. Dias do Mes ?","","","mv_ch7","N",02,0,0,"G","","mv_par07","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"08","Est. p/ Quant. Dias?","","","mv_ch8","N",02,0,0,"G","","mv_par08","","","","","","","","","","","","","",""})
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

DbSelectArea(_sAlias)

Return           
//

/*====================================================================================\
|Programa  | DIPM008a      | Autor | Reginaldo Borges           | Data | 10/12/2015   |
|=====================================================================================|
|Descrição | Calcula a Media de Consumo do produto conforme o parametro de meses      |
|          | informado.                                                                |
|          |                                                                          |
|=====================================================================================|
|Sintaxe   | DIPM008a                                                                  |
|=====================================================================================|
|Uso       | Especifico DIPROMED                                                      |
|=====================================================================================|
|........................................Histórico....................................|
|Borges    | DD/MM/AA - Descrição                                                     |
\====================================================================================*/

#INCLUDE "RWMAKE.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "FILEIO.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºFun‡„o    ³  DIPM008a º Autor ³  Reginaldo Borges º Data ³  10/12/2015 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescri‡„o ³ Calcula a Media de Consumo do produto conforme o parame-   º±±
±±º          ³ tro de meses informado.                                    º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function DIPM008a(aWork)

cWorkFlow := aWork[1]
cWCodEmp  := aWork[2]
cWCodFil  := aWork[3]

If ValType(aWork) == 'A'
	PREPARE ENVIRONMENT EMPRESA cWCodEmp FILIAL cWCodFil FUNNAME "DIPM008a" TABLES "SB1"
EndIf

ConOut('Inicio do calculo do ponto de pedido dos produtos '+dToc(date())+' as '+Time())

Processa({|| U_ProPonto() })

ConOut('Fim do calculo do ponto de pedido dos produtos '+dToc(date())+' as '+Time())         

Return

User Function ProPonto()
Local _xAlias      := GETAREA() //{ Alias(), IndexOrd(), Recno() }
Local _nMediaCons  := 0
Local _nQuantSCK   := 0
Local _nQtPontoPed := 0
Local _nPrazoEnt   := 0    
DbSelectArea("SB1")
DbGoTop()
ProcRegua(RecCount())   

DbSetOrder(1)
DbSeek(cWCodFil,.T.)

While !Eof() .and. SB1->B1_FILIAL == xFilial("SB1") 
	_nMediaCons := U_Cal_Media(SB1->B1_COD,SA2->A2_XQTDMES,.F.)
	_nQuantSCK  := U_Pro_SCK(SB1->B1_COD, SB1->B1_PROC, SB1->B1_LOJPROC)
	DbSelectArea("SA2")
	DbSetOrder(1)
	IF DbSeek(xFilial("SA2")+SB1->B1_PROC+SB1->B1_LOJPROC)
		_nPrazoEnt := (_nMediaCons / SA2->A2_XQTDIMES) * SA2->A2_PRAZO
	EndIF
	_nQtPontoPed := ((_nMediaCons/SA2->A2_XQTDIMES)*SA2->A2_XESTQMES) + (_nPrazoEnt + _nQuantSCK)
	DbSelectArea("SB1")
	RecLock("SB1",.F.)
	Replace B1_EMIN    With _nQtPontoPed
	Replace B1_ETQDIAS With SA2->A2_XESTQMES
	MsUnLock()
	DbSkip()
	IncProc()
EndDo

RESTAREA(_xAlias)

Return

/*
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
|Borges    | DD/MM/AA - Descrição                                                     |
\====================================================================================*/
User Function Cal_Media(_cProduto,_nMes,_lMesAtual)

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


/*
|=====================================================================================|
|Descrição | Verifica as programacoes de compra em Aberto.                            |
|          |                                                                          |
|          |                                                                          |
|=====================================================================================|
|Sintaxe   | Pro_SCK(_cProduto, cCod_For, cLoj_For)                                   |
|          | _cProduto = Código do Produto.                                           |
|          | cCod_For = Código do fornecedor                                          |
|          | cLoj_For = Loja do fornecedor                                            |
|=====================================================================================|
|Uso       | Especifico DIPROMED                                                      |
|=====================================================================================|
|........................................Histórico....................................|
|Borges    | DD/MM/AA -																  |
\====================================================================================*/
User Function Pro_SCK(_cProduto, cCod_For, cLoj_For)

Local _xArea        := GetArea()
Local _nTamTotProd  := Len(_cProduto)
Local _nTamOriginal := Len(Alltrim(_cProduto))
Local _cProdProc    := StrZero( Val(_cProduto)+1,_nTamOriginal)+Space(_nTamTotProd-_nTamOriginal)
Local _nQtdProg     := 0
Local nPrz_Ent := 0
Local dDat_Ini := ""
Local dDat_Fim := ""

/// LEVANTAMENTO DO PERÍODO PARA GERAR PONTO DE PEDIDO
DbSelectArea("SA2")
DbSetOrder(1)
IF DbSeek(xFilial("SA2")+cCod_For+cLoj_For)
	nPrz_Ent := SA2->A2_PRAZO // PRAZO DE ENTREGA DO FORNECEDOR
	dDat_Ini := dDataBase // DATA ATUAL
	dDat_Fim := dDataBase + nPrz_Ent + SA2->A2_XESTQMES /// DATA FINAL (data atual + prazo de entrega + estoque p/ qtos. dias)
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

				/// VERIFICA SE PROGRAMAÇÃO ESTÁ DENTRO DO PERÍODO ESTABELECIDO
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
                                                                                    

#include "rwmake.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Fun‡ao    ³ DIPR004   ³ Autor ³ Rodrigo Franco     ³ Data ³ 07/11/2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Relacao de Comissoes x Metas                               ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function DIPR004()

//³ Define Variaveis                                             ³
Local cUserAut := GetMV("MV_URELFAT") // MCVN - 04/05/09    
                                       ³
CbTxt    := CbCont := cabec1 := cabec2 := cabec3 := wnrel := ""
nOrdem   := ""
tamanho  := "M"
limite   := 80
titulo   := "Relatorio de Comissoes x Metas"
cDesc1   := "Este programa ira emitir a relacao de Comissoes por Vendedor"
cDesc2   := ""
cDesc3   := ""
cString  := "SE1"
nReg     := 0
aReturn  := { "Especial", 1,"Administracao", 1, 2, 1, "",1 }
nomeprog := "DIPR004"
nLastKey :=  0
_nSomAtra := 0
_nMedAtra := 0
_nvlrpag  := 0
_nvlrsal  := 0
_nMedAtr1 := 0
_nSomAtr1 := 0
_nvlrto1  := 0
_nvlrpa1  := 0
_cNomVen  := ""
_nBase    := 0
_nPorc    := 0
_nComi    := 0
_nPorTot  := 0
_nComTot  := 0
_nRecMes  := 0
_nRecMesa := 0
_nValRec  := 0
_nFatura  := 0
_nMeta 	  := 0
_nDesmp   := 0
//cPerg     := "FVA011"       
// FPADR(cPerg, cArq, cCampo, cTipo)
PRIVATE cPerg  	:= U_FPADR( "FVA011","SX1","SX1->X1_GRUPO"," " ) //Criado por Sandro em 19/11/09. 

U_DIPPROC(ProcName(0),U_DipUsr()) // JBS 05/10/2005 - Gravando o nome do Programa no SZU
// MCVN - 04/05/09    
If !(Upper(U_DipUsr()) $ cUserAut)
	Alert(Upper(U_DipUsr())+", você não tem autorização para utilizar esta rotina. Qualquer dúvida falar com Eriberto!","Atenção")	
	Return()
EndIF
             
//³ Verifica as perguntas selecionadas                           ³
pergunte(cPerg,.F.)

//³ Variaveis utilizadas para parametros                         ³
//³ mv_par01           // Do Vendedor                            ³
//³ mv_par02           // Ate Vendedor                           ³
//³ mv_par03           // De Data                                ³
//³ mv_par04           // Ate a Data                             ³
//³ Monta o Cabecalho de acordo com o tipo de emissao            ³
Cabec1 := "                                             Faturado entre " + dtoc(mv_par03) + " ate " + dtoc(mv_par04)
Cabec2 := "|Nota Fiscal   |Emissao   |Valor N.F.   |Vencimento |Percentual |Vlr Comissao |Cliente                                 |Pagamento  |"
wnrel  := "DIPR004"
wnrel:=SetPrint(cString,wnrel,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,"",.F.)
If nLastKey==27
	Set Filter to
	Return
Endif
SetDefault(aReturn,cString)
If nLastKey==27
	Set Filter to
	Return
Endif
C001Imp()
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Fun‡…o    ³ C001Imp  ³ Autor ³ RODRIGO FRANCO      ³ Data ³ 07/11/2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Chamada do Relatorio                                       ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function C001Imp()

CbTxt   := CbCont := cabec1 := cabec2 := cabec3 := ""
nTotVend:= 0
nTotGer := 0
nOrdem  := ""
tamanho := "M"
limite  := 100
titulo  := "Relatorio de Comissoes x Metas"
cDesc1  := "Este programa ira emitir a relacao de Comissoes por Vendedor"
cDesc2  := ""
cDesc3  := ""
cVendAnt:= ""
cProdAnt:= ""
lContinua  := .T.
lProcessou := .F.
lNewProd   := .T.
nTotQuant:= 0
nReg     := 0
cFiltro  := _cTes := _cCodcli := cCliente := cFiltr1 := ""
lFirst   := .F.
_lInicio := .T.
cMemo    := ""
aMidia   := {}
aQtdMidia:= {}
aTotMidia:= {}
_nLiga    := nTotLiga := 0
_nTotped := 0
_nvlrtot := 0
_nComTot := 0
_ntotal  := 0
dDataAnt := ctod("")
nPos     := i := 0
cObs     := cLinha := ""
nInd     := 0
lAtende  := .F.

//³ Monta o Cabecalho de acordo com o tipo de emissao            ³
Cabec1 := "                                             Faturado entre " + dtoc(mv_par03) + " ate " + dtoc(mv_par04)
Cabec2 := "|Nota Fiscal   |Emissao   |Valor N.F.   |Vencimento |Percentual |Vlr Comissao |Cliente                                 |Pagamento  |"

//³ Variaveis utilizadas para Impressao do Cabecalho e Rodape    ³
cbtxt    := SPACE(10)
cbcont   := 0
Li       := 120
m_pag    := 1
cVendAnt := mv_par01

dbSelectArea("SA3")
dbGoTop()
dbSetorder(1)
dbSeek(xFilial("SA3")+cVendAnt)
While !Eof() .and. A3_Filial== xFilial() .and. A3_COD >= mv_par01 .and. A3_COD <= mv_par02
	cVendAnt := A3_COD
	_cNomVen := A3_NOME
	_nMeta   := A3_META
	cabec(titulo,cabec1,cabec2,nomeprog,tamanho,15)
	@ Li,001 PSAY cVendAnt + " - " + _cNomVen
	Li := Li + 2
	dbSelectArea("SE1")
	
	//SetRegua(RecCount())            // Total de Elementos da regua
	cFiltro := SE1->(dbFilter())
	cArqTrab := CriaTrab("",.F.)
	IndRegua(cString,cArqTrab,"SE1->E1_FILIAL+SE1->E1_VEND1+DTOS(SE1->E1_EMISSAO)",,,"Selecionando Registros...")
	dbCommit()
	If !Empty(Alltrim(cFiltro))
		Set Filter To &cFiltro
		DbGoTop()
	Endif
	dbSelectArea("SE1")
	DbSetOrder(15)
	Set Softseek On
	dbSeek(xFilial("SE1")+cVendAnt) //Vendedor
	Set Softseek off
	While !Eof() .and. E1_Filial == xFilial("SE1") .and. E1_VEND1 == cVendAnt
		If E1_EMISSAO > Mv_par04 .or. E1_EMISSAO < Mv_par03
			DbSkip()
			Loop
		ElseIf E1_BAIXA > Mv_par04 .or. E1_BAIXA < Mv_par03
			DbSkip()
			Loop
		Endif
		
		// Eriberto 08/05/2003
		If SE1->E1_EMISSAO < CtoD('01/03/2003') .and. SE1->E1_VEND1 $ '006694/006712/006681/000196/000193/000192/000191/000190'
			DbSkip()
			Loop
		Endif
		
		//³ Impressao do Cabecalho.                                  ³
		If Li > 58
			cabec(titulo,cabec1,cabec2,nomeprog,tamanho,15)
			@ Li,001 PSAY cVendAnt + " - " + _cNomVen
			Li := Li + 2
		EndIf
		
		//³ dbSeek Para Impressao dos dados do Cliente               ³
		If cVendAnt <> SE1->E1_VEND1
			If !_lInicio
				Li := Li + 1
				_cNomVen := SA3->A3_NOME
				_nMeta   := SA3->A3_META
				@ Li,000 PSAY "Faturado Representante: "
				@ Li,025 PSAY _nvlrtot picture "@E 9,999,999.99"
				@ Li,049 PSAY "Comissoes Representante: "
				@ Li,075 PSAY _nComTot picture "@E 999,999.99"
				_nMedPco := _nPorTot / _nLiga
				@ Li,094 PSAY "Percentual Representante (%): "
				@ Li,124 PSAY _nMedPco picture "@E 999.99"
				Li := Li + 1
				@ Li,000 PSAY Repli('-',132)
				Li := Li + 1
				@ Li,000 PSAY "Total  <A> - Valor Disponivel Referente ao Periodo (R$):"
				@ Li,075 PSAY _nRecMes picture "@E 999,999.99"
				Li := Li + 3
				_nFatura := _nvlrtot
				_nRecMesa := _nRecMes
				_nLiga := 0
				_nvlrtot:= 0
				_nComTot := 0
				_nvlrpag  := 0
				_nvlrsal  := 0
				_nSomAtra := 0
				_nMedPco := 0
				_nPorTot := 0
				_nRecMes := 0
				dbSelectArea("SE1")
				Set Filter To
				RetIndex("SE1")
				fErase(cArqTrab+OrdBagExt())
				PAGAS()
				Return
				cabec(titulo,cabec1,cabec2,nomeprog,tamanho,15)
				Li := Li - 1
				@ Li,000 PSAY Repli('-',132)
				Li := Li + 1
				@ Li,000 PSAY "Representante: "+SA3->A3_COD+" - "+SA3->A3_NOME
				Li := Li + 2
			Else
				@ Li,000 PSAY "Representante: "+SA3->A3_COD+" - "+SA3->A3_NOME
				Li := Li + 2
				_lInicio := .F.
			Endif
		Endif
		dbSelectArea("SA1")
		dbSetOrder(1)
		dbSeek(xFilial("SA1")+SE1->E1_CLIENTE+SE1->E1_LOJA)
		_cCodcli := SA1->A1_COD
		_cCliente:=SUBSTR(SA1->A1_NOME,1,25)
		DbSelectArea("SF2")
		DbSetOrder(1)
		DbSeek(xFilial("SF2")+SE1->E1_NUM+SE1->E1_PREFIXO)
		_cCond := SF2->F2_COND
		_nTotped := SE1->E1_VALOR
		DbSelectArea("SE3")
		DbSetOrder(2)
		IF DbSeek(xFilial("SE3")+SE1->E1_VEND1+SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA)
			_nPorc := SE3->E3_PORC
			_nComi := SE3->E3_COMIS
		ELSE
			_nPorc := 0
			_nComi := 0
		ENDIF
		If _nPorc == 0
			_nPorc  := SE1->E1_COMIS1
		Endif
		If _nComi == 0
			_nComi := (_nTotped/100)*_nPorc
		Endif
		DbSelectArea("SE4")
		DbSetOrder(1)
		DbSeek(xFilial("SE4")+_cCond)
		_cDesc := substr(SE4->E4_DESCRI,1,14)
		_nAtraso := ddatabase - SE1->E1_VENCTO
		IF _nAtraso > 0
			_nSomAtra := _nSomAtra + _nAtraso
			_nSomAtr1 := _nSomAtr1 + _nAtraso
		Endif
		IF _nPorc > 0 .AND. _nComi > 0
			@ Li,001 PSAY SE1->E1_NUM + " - " + SE1->E1_PREFIXO
			@ Li,017 PSAY SE1->E1_EMISSAO
			@ Li,029 PSAY SE1->E1_VALOR picture "@E 999,999.99"
			@ Li,043 PSAY SE1->E1_VENCTO
			@ Li,057 PSAY _nPorc picture "@E 999.99"
			@ Li,067 PSAY _nComi picture "@E 999,999.99"
			@ Li,080 PSAY _cCodcli + " - " + SUBSTR(_cCliente,1,26)
			@ Li,121 PSAY SE1->E1_BAIXA
			
			_nPago := SE1->E1_VALOR - SE1->E1_SALDO
			_nSaldo := SE1->E1_SALDO
			Li := Li + 1
			lfirst:= .T.
			If !Empty(SE1->E1_BAIXA)
				_nRecMes  := _nRecMes + _nComi
			Endif
			_nLiga    := _nLiga + 1
			_nvlrtot  := _nvlrtot + _nTotped
			_nPorTot  := _nPorTot + _nPorc
			_nComTot  := _nComTot + _nComi
			_nvlrto1  := _nvlrto1 + _nTotped
			_nTotped  := 0
			_nMedAtra := _nSomAtra/_nLiga
			_nvlrpag  := _nvlrpag //+ _nPago
			_nvlrsal  := _nvlrsal + _nSaldo
			_ntotal   := _ntotal +  _nSaldo
			_nvlrpa1  := _nvlrpa1 //+ _nPago
			_nMedAtr1 := _nSomAtr1/nTotliga
		ENDIF
		DbSelectArea("SE1")
		DbSkip()
		
		//³ Impressao do Cabecalho.                                  ³
		If li > 58
			cabec(titulo,cabec1,cabec2,nomeprog,tamanho,15)
		Endif
		dbSelectArea("SE1")
	Enddo
	If lFirst                  //ultimo
		If Li > 58
			cabec(titulo,cabec1,cabec2,nomeprog,tamanho,15)
		EndIf
		Li := Li + 1
		_cNomVen := SA3->A3_NOME
		_nMeta   := SA3->A3_META
		@ Li,000 PSAY "Faturado Representante: "
		@ Li,025 PSAY _nvlrtot picture "@E 9,999,999.99"
		@ Li,049 PSAY "Comissoes Representante: "
		@ Li,075 PSAY _nComTot picture "@E 999,999.99"
		_nMedPco := _nPorTot / _nLiga
		@ Li,094 PSAY "Percentual Representante (%): "
		@ Li,124 PSAY _nMedPco picture "@E 999.99"
		Li := Li + 1
		@ Li,000 PSAY Repli('-',132)
		Li := Li + 1
		@ Li,000 PSAY "Total  <A> - Valor Disponivel Referente ao Periodo (R$):"
		@ Li,075 PSAY _nRecMes picture "@E 999,999.99"
		Li := Li + 3
		_nFatura := _nvlrtot
		_nRecMesa := _nRecMes
		_nLiga := 0
		_nvlrtot:= 0
		_nComTot := 0
		_nvlrpag  := 0
		_nvlrsal  := 0
		_nSomAtra := 0
		_nMedPco := 0
		_nPorTot := 0
		_nRecMes := 0
	Endif
	roda(cbcont,cbtxt,tamanho)
	dbSelectArea("SE1")
	Set Filter To
	RetIndex("SE1")
	fErase(cArqTrab+OrdBagExt())
	Pagas()
	dbSelectArea("SA3")
	DbSkip()
End
Set Device To Screen
If aReturn[5] == 1
	Set Printer TO
	dbcommitAll()
	ourspool(wnrel)
EndIf
MS_FLUSH()
Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Fun‡…o    ³ PAGAS    ³ Autor ³ RODRIGO FRANCO      ³ Data ³ 07/11/2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ PAGAS FORA DO PERIODO                                      ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function PAGAS()

Cabec1 := "                                                    Pagas Fora do Periodo"
cabec(titulo,cabec1,cabec2,nomeprog,tamanho,15)
@ Li,001 PSAY cVendAnt + " - " + _cNomVen
Li := Li + 2
dbSelectArea("SE1")
cFiltro := SE1->(dbFilter())
cArqTrab := CriaTrab("",.F.)
IndRegua(cString,cArqTrab,"SE1->E1_FILIAL+SE1->E1_VEND1+DTOS(SE1->E1_BAIXA)",,,"Selecionando Registros...")
dbCommit()
If !Empty(Alltrim(cFiltro))
	Set Filter To &cFiltro
	DbGoTop()
Endif
dbSelectArea("SE1")
Set Softseek On
dbSeek(xFilial("SE1")+(cVendAnt)) //Vendedor
Set Softseek off
While !Eof() .and. E1_Filial== xFilial("SE1") .and. E1_VEND1 == cVendAnt
	If E1_EMISSAO > Mv_par04 .or. E1_EMISSAO < Mv_par03
		If E1_BAIXA >= Mv_par03 .and. E1_BAIXA <= Mv_par04
		Else
			DbSkip()
			Loop
		Endif
	Else
		DbSkip()
		Loop
	Endif

	// Eriberto 08/05/2003
	If SE1->E1_EMISSAO < CtoD('01/03/2003') .and. SE1->E1_VEND1 $ '006694/006712/006681/000196/000193/000192/000191/000190'
		DbSkip()
		Loop
	Endif

	If Li > 58
		cabec(titulo,cabec1,cabec2,nomeprog,tamanho,15)
	EndIf
	If cVendAnt <> SE1->E1_VEND1
		If !_lInicio
			Li := Li + 1
			_cNomVen := SA3->A3_NOME
			_nMeta   := SA3->A3_META
			@ Li,000 PSAY "Faturado Representante: "
			@ Li,025 PSAY _nvlrtot picture "@E 9,999,999.99"
			@ Li,049 PSAY "Comissoes Representante: "
			@ Li,075 PSAY _nComTot picture "@E 999,999.99"
			_nMedPco := _nPorTot / _nLiga
			@ Li,094 PSAY "Percentual Representante (%): "
			@ Li,124 PSAY _nMedPco picture "@E 999.99"
			Li := Li + 1
			@ Li,000 PSAY Repli('-',132)
			Li := Li + 1
			@ Li,000 PSAY "Total  <A> - Valor Disponivel Referente ao Periodo (R$):"
			@ Li,075 PSAY _nRecMes picture "@E 999,999.99"
			Li := Li + 3
			_nLiga := 0
			_nvlrtot:= 0
			_nComTot := 0
			_nvlrpag  := 0
			_nvlrsal  := 0
			_nSomAtra := 0
			_nMedPco := 0
			_nPorTot := 0
			_nRecMes := 0
			dbSelectArea("SE1")
			Set Filter To
			RetIndex("SE1")
			fErase(cArqTrab+OrdBagExt())
			PAGAS()
			Return
			cabec(titulo,cabec1,cabec2,nomeprog,tamanho,15)
			Li := Li - 1
			@ Li,000 PSAY Repli('-',132)
			Li := Li + 1
			@ Li,000 PSAY "Representante: "+SA3->A3_COD+" - "+SA3->A3_NOME
			Li := Li + 2
		Else
			Li := Li - 1
			@ Li,000 PSAY "Representante: "+SA3->A3_COD+" - "+SA3->A3_NOME
			Li := Li + 2
			_lInicio := .F.
		Endif
	Endif
	dbSelectArea("SA1")
	dbSetOrder(1)
	dbSeek(xFilial("SA1")+SE1->E1_CLIENTE+SE1->E1_LOJA)
	_cCodcli := SA1->A1_COD
	_cCliente:=SUBSTR(SA1->A1_NOME,1,25)
	DbSelectArea("SF2")
	DbSetOrder(1)
	DbSeek(xFilial("SF2")+SE1->E1_NUM+SE1->E1_PREFIXO)
	_cCond := SF2->F2_COND
	_nTotped := SE1->E1_VALOR
	DbSelectArea("SE3")
	DbSetOrder(2)
	DbSeek(xFilial("SE3")+SE1->E1_VEND1+SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA)
	_nPorc  := SE3->E3_PORC
	_nComi  := SE3->E3_COMIS
	If _nPorc == 0
		_nPorc  := SE1->E1_COMIS1
	Endif
	If _nComi == 0
		_nComi := (_nTotped/100)*_nPorc
	Endif
	DbSelectArea("SE4")
	DbSetOrder(1)
	DbSeek(xFilial("SE4")+_cCond)
	_cDesc := substr(SE4->E4_DESCRI,1,14)
	_nAtraso := ddatabase - SE1->E1_VENCTO
	IF _nAtraso > 0
		_nSomAtra := _nSomAtra + _nAtraso
		_nSomAtr1 := _nSomAtr1 + _nAtraso
	Endif
	IF _nPorc > 0 .AND. _nComi > 0
		@ Li,001 PSAY SE1->E1_NUM + " - " + SE1->E1_PREFIXO
		@ Li,017 PSAY SE1->E1_EMISSAO
		@ Li,029 PSAY SE1->E1_VALOR picture "@E 999,999.99"
		@ Li,043 PSAY SE1->E1_VENCTO
		@ Li,057 PSAY _nPorc picture "@E 999.99"
		@ Li,067 PSAY _nComi picture "@E 999,999.99"
		@ Li,080 PSAY _cCodcli + " - " + SUBSTR(_cCliente,1,26)
		@ Li,121 PSAY SE1->E1_BAIXA
		
		_nPago := SE1->E1_VALOR - SE1->E1_SALDO
		_nSaldo := SE1->E1_SALDO
		Li := Li + 1
		lfirst:= .T.
		
		//³ Incremento o numero de liga‡äes
		If !Empty(SE1->E1_BAIXA)
			_nRecMes  := _nRecMes + _nComi                   
		Endif
		_nLiga    := _nLiga + 1
		_nvlrtot  := _nvlrtot + _nTotped
		_nPorTot  := _nPorTot + _nPorc
		_nComTot  := _nComTot + _nComi
		_nvlrto1  := _nvlrto1 + _nTotped
		_nTotped  := 0
		_nMedAtra := _nSomAtra/_nLiga
		_nvlrpag  := _nvlrpag //+ _nPago
		_nvlrsal  := _nvlrsal + _nSaldo
		_ntotal   := _ntotal +  _nSaldo
		_nvlrpa1  := _nvlrpa1 //+ _nPago
		_nMedAtr1 := _nSomAtr1/nTotliga
	ENDIF
	DbSelectArea("SE1")
	DbSkip()
	If li > 58
		cabec(titulo,cabec1,cabec2,nomeprog,tamanho,15)
	Endif
	dbSelectArea("SE1")
Enddo
If lFirst                  //ultimo
	If Li > 58
		cabec(titulo,cabec1,cabec2,nomeprog,tamanho,15)
	EndIf
	Li := Li + 1
	_cNomVen := SA3->A3_NOME
	_nMeta   := SA3->A3_META
	@ Li,000 PSAY "< B > - Total: "
	@ Li,022 PSAY _nvlrtot picture "@E 9,999,999.99"
	@ Li,051 PSAY "Valor a ser pago referente ao pagamento no mes(R$): "
	@ Li,106 PSAY _nComTot picture "@E 999,999.99"
	Li := Li + 1
	@ Li,000 PSAY Repli('-',132)
	Li := Li + 1
	@ Li,000 PSAY "< Total > - Periodo(R$): "
	@ Li,025 PSAY _nRecMesa picture "@E 9,999,999.99"
	@ Li,042 PSAY "( + )    Pagas no mes(R$): "
	@ Li,072 PSAY _nRecMes picture "@E 9,999,999.99"
	_nValRec := _nRecMes + _nRecMesa
	@ Li,095 PSAY "( = ) "
	@ Li,104 PSAY _nValRec picture "@E 9,999,999.99"
	Li := Li + 1
	@ Li,000 PSAY Repli('-',132)
	Li := Li + 1
	@ Li,000 PSAY "Faturado: "
	@ Li,011 PSAY _nFatura picture "@E 9,999,999.99"
	@ Li,030 PSAY "Total de Comissoes (R$): "
	@ Li,056 PSAY _nValRec picture "@E 9,999,999.99"
	Li := Li + 1
	@ Li,000 PSAY "Meta: "
	@ Li,011 PSAY _nMeta picture "@E 9,999,999.99"
	_nDesmp := (_nFatura / _nMeta)*100
	@ Li,030 PSAY "Desempenho: "
	@ Li,058 PSAY _nDesmp picture "@E 9,999.9999"
	Li := Li + 2
	@ Li,074 PSAY "_______________      _______________      _______________ "
	Li := Li + 1
	@ Li,000 PSAY "Total a Receber (R$): "
	@ Li,027 PSAY _nValRec picture "@E 9,999,999.99"
	@ Li,074 PSAY "  Ger. Vendas           Ger. Adm.             Diretor"
	Li := Li + 3
	_nMeta := 0
	_nDesmp := 0
	_nFatura := 0
	_nValRec := 0
	_nRecMesa := 0
	_nLiga := 0
	_nvlrtot:= 0
	_nComTot := 0
	_nvlrpag  := 0
	_nvlrsal  := 0
	_nSomAtra := 0
	_nMedPco := 0
	_nPorTot := 0
	_nRecMes := 0
Endif
roda(cbcont,cbtxt,tamanho)
dbSelectArea("SE1")
Set Filter To
RetIndex("SE1")
fErase(cArqTrab+OrdBagExt())
Cabec1 := "                                             Faturado entre " + dtoc(mv_par03) + " ate " + dtoc(mv_par04)

Return
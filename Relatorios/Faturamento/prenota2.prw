#include "rwmake.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Fun‡…o    ³ PRENOTA  ³ Autor ³ Rodrigo Franco        ³ Data ³ 05.11.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Emissao da Pre-Nota                                        ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function PreNota2()

//³ Define Variaveis                                             ³

//³ Define Variaveis                                             ³
LOCAL wnrel
LOCAL tamanho:="G"
LOCAL titulo:="Emissao da PRE-NOTA"
LOCAL cDesc1:="Emiss„o da pre-nota dos pedidos de venda, de acordo com"
LOCAL cDesc2:="intervalo informado na op‡„o Parƒmetros."
LOCAL cDesc3:=" "
LOCAL nRegistro:= 0
LOCAL cKey,nIndex,cIndex  //&& Variaveis para a criacao de Indices Temp.
LOCAL cCondicao
//Local cPerg  :="MTR730"
// FPADR(cPerg, cArq, cCampo, cTipo)  - Para ajustar o tamanho das perguntas no SX1
PRIVATE cPerg  	:= U_FPADR( "MTR730","SX1","SX1->X1_GRUPO"," " ) //Função criada por Sandro em 19/11/09.
PRIVATE aReturn := { "Zebrado", 1,"Administracao", 2, 2, 1, "",0 }
PRIVATE nomeprog:="PRENOTA",nLastKey := 0,nBegin:=0,aLinha:={ }
PRIVATE li:=80,limite:=220,lRodape:=.F.,cPictQtd:=""
PRIVATE nItens := nPag := nPags := 0
wnrel    := "PRENOTA"
cString  := "SC6"

U_DIPPROC(ProcName(0),U_DipUsr()) // JBS 05/10/2005 - Gravando o nome do Programa no SZU
//³ Verifica as perguntas selecionadas   
              

pergunte(cPerg,.t.)
//³ Variaveis utilizadas para parametros		                ³
//³ mv_par01	     	  Do Pedido			                    ³
//³ mv_par02	     	  Ate o Pedido			                ³
//³ mv_par03	     	  Emite ja Impressos	                ³

wnrel:=SetPrint(cString,wnrel,cPerg,@Titulo,cDesc1,cDesc2,cDesc3,.F.,,,Tamanho)

If nLastKey==27
	Set Filter to
	Return( NIL )
Endif
SetDefault(aReturn,cString)
If nLastKey==27
	Set Filter to
	Return( NIL )
Endif
RptStatus({|lEnd| C730Imp(@lEnd,wnRel,cString)},Titulo)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Fun‡…o    ³ C730IMP  ³ Autor ³ Rodrigo Franco        ³ Data ³ 05.11.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Chamada do Relatorio                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATR730			                                          ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function C730Imp(lEnd,WnRel,cString)

//³ Faz manualmente porque nao chama a funcao Cabec()                 ³
@ 0,0 psay AvalImp(Limite)

IF mv_par03 == 1 
	cIndex := CriaTrab(nil,.f.)
	dbSelectArea("SC5")
	cKey := IndexKey()
	cFilter := dbFilter()
	cFilter += If( Empty( cFilter ),""," .And. " )
	cFilter += 'C5_FILIAL == "'+xFilial("SC5")+'" .AND. SC5->C5_PRENOTA == " " .And. C5_NUM >= "'+mv_par01+'"'
	IndRegua("SC5",cIndex,cKey,,cFilter,"Selecionando Registros...")
	nIndex := RetIndex("SC5")
	DbSelectArea("SC5")
	#IFNDEF TOP
		DbSetIndex(cIndex+OrdBagExt())
	#ENDIF
	DbSetOrder(nIndex+1)
	DbGoTop()
	SetRegua(RecCount())		// Total de Elementos da regua
Elseif mv_par03 == 2 	
	cIndex := CriaTrab(nil,.f.)
	dbSelectArea("SC5")
	cKey := IndexKey()
	cFilter := dbFilter()
	cFilter += If( Empty( cFilter ),""," .And. " )
	cFilter += 'C5_FILIAL == "'+xFilial("SC5")+'" .AND. SC5->C5_PRENOTA == "S" .And. C5_NUM >= "'+mv_par01+'"'
	IndRegua("SC5",cIndex,cKey,,cFilter,"Selecionando Registros...")
	nIndex := RetIndex("SC5")
	DbSelectArea("SC5")
	#IFNDEF TOP
		DbSetIndex(cIndex+OrdBagExt())
	#ENDIF
	DbSetOrder(nIndex+1)
	DbGoTop()
	SetRegua(RecCount())		// Total de Elementos da regua
Endif
While !Eof() .And. C5_NUM <= mv_par02
	DBSELECTAREA("SDC")
	DBSETORDER(4)
	IF DBSEEK(xFilial("SDC")+SC5->C5_NUM)
		WHILE !EOF() .AND. xFILIAL("SDC") == SC5->C5_FILIAL .AND. SDC->DC_PEDIDO == SC5->C5_NUM
			nRegistro:= RECNO()
			DBSELECTAREA("SC9")
			DBSETORDER(1)
			IF DBSEEK(xFilial("SC9")+SDC->DC_PEDIDO+SDC->DC_ITEM+SDC->DC_SEQ)
				IF EMPTY(SC9->C9_BLEST) .AND. EMPTY(SC9->C9_BLCRED2) .AND. EMPTY(SC9->C9_PARCIAL)
					DbSelectArea("SC5")
					cPedido := C5_NUM
					IF SC5->C5_PRENOTA == "S"
						IF mv_par03 == 2
							DbSelectArea("SC5")
							DbSeek(cFilial+cPedido)
							Reclock("SC5",.F.)
							SC5->C5_PRENOTA := "S"
							SC5->C5_DT_PRE  := DATE()
							SC5->C5_HR_PRE  := TIME()
							MsUnLock()  
							// Registra na ficha Kardex
	                        U_DiprKardex(cPedido,U_DipUsr(),,.t.,"19") // JBS 29/08/2005
							dbSelectArea("SA4")
							dbSeek(cFilial+SC5->C5_TRANSP)
							dbSelectArea("SA3")
							dbSeek(cFilial+SC5->C5_VEND1)
							dbSelectArea("SE4")
							dbSeek(cFilial+SC5->C5_CONDPAG)
							IF lEnd
								@Prow()+1,001 Psay "CANCELADO PELO OPERADOR"
								Exit
							Endif
							DBSELECTAREA("SDC")
							dbGoTo( nRegistro )
							nItens := 0
							While !Eof() .And. SDC->DC_PEDIDO == SC5->C5_NUM
								nItens := nItens + 1
								dbSkip()
							EndDo
							nPags := Iif(nItens<=18,1,Int((nItens+18)/18))
							nPag  := 1
							DBSELECTAREA("SDC")
							dbGoTo( nRegistro )
							While !Eof() .And. SDC->DC_PEDIDO == SC5->C5_NUM
								IF lEnd
									@Prow()+1,001 Psay "CANCELADO PELO OPERADOR"
									Exit
								Endif
								IF li > 47
									IF lRodape
										ImpRodape()
									Endif
									li := 0
									lRodape := ImpCabec()
								Endif
								ImpItem()
								DBSELECTAREA("SDC")
								dbSkip()
							Enddo
							IF lRodape
								ImpRodape()
								lRodape:=.F.
							Endif
							IncRegua()
						ENDIF
					ELSE
						DbSelectArea("SC5")
						DbSeek(cFilial+cPedido)
						Reclock("SC5",.F.)
						SC5->C5_PRENOTA := "S"
						SC5->C5_DT_PRE  := DATE()
						SC5->C5_HR_PRE  := TIME()
						MsUnLock() 
						// Registra na ficha Kardex
                        U_DiprKardex(cPedido,U_DipUsr(),,.t.,"19") // JBS 29/08/2005
						dbSelectArea("SA4")
						dbSeek(cFilial+SC5->C5_TRANSP)
						dbSelectArea("SA3")
						dbSeek(cFilial+SC5->C5_VEND1)
						dbSelectArea("SE4")
						dbSeek(cFilial+SC5->C5_CONDPAG)
						IF lEnd
							@Prow()+1,001 Psay "CANCELADO PELO OPERADOR"
							Exit
						Endif
						DBSELECTAREA("SDC")
						dbGoTo( nRegistro )
						nItens := 0
						While !Eof() .And. SDC->DC_PEDIDO == SC5->C5_NUM
							nItens := nItens + 1
							dbSkip()
						EndDo
						nPags := Iif(nItens<=18,1,Int((nItens+18)/18))
						nPag  := 1
						DBSELECTAREA("SDC")
						dbGoTo( nRegistro )
						While !Eof() .And. SDC->DC_PEDIDO == SC5->C5_NUM
							IF lEnd
								@Prow()+1,001 Psay "CANCELADO PELO OPERADOR"
								Exit
							Endif
							IF li > 47
								IF lRodape
									ImpRodape()
								Endif
								li := 0
								lRodape := ImpCabec()
							Endif
							ImpItem()
							DBSELECTAREA("SDC")
							dbSkip()
						Enddo
						IF lRodape
							ImpRodape()
							lRodape:=.F.
						Endif
						IncRegua()
					ENDIF
				ENDIF
			ENDIF
			
			DBSELECTAREA("SDC")
			DBSKIP()
		END
	ENDIF
	DBSELECTAREA("SC5")
	DBSKIP()
Enddo

//³ Deleta Arquivo Temporario e Restaura os Indices Nativos.     ³
RetIndex("SC5")
Set Filter to
Ferase(cIndex+OrdBagExt())
dbSelectArea("SC6")
Set Filter To
dbSetOrder(1)
dbGotop()
If aReturn[5] = 1
	Set Printer To
	dbCommitAll()
	OurSpool(wnrel)
Endif

MS_FLUSH()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Fun‡…o    ³ ImpCabec ³ Autor ³ Rodrigo Franco        ³ Data ³ 05.11.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Emissao da Pr‚-Nota                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Matr730                                                    ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ImpCabec()

LOCAL cHeader,nPed,cMoeda,cCampo,cComis,cPedCli

//³ Posiciona registro no cliente do pedido                     ³
IF !(SC5->C5_TIPO$"DB")
	dbSelectArea("SA1")
	dbSeek(cFilial+SC5->C5_CLIENTE+SC5->C5_LOJACLI)
Else
	dbSelectArea("SA2")
	dbSeek(cFilial+SC5->C5_CLIENTE+SC5->C5_LOJACLI)
Endif
@ 01,000 psay Replicate("-",limite-78)
@ 02,000 psay SM0->M0_NOME
IF !(SC5->C5_TIPO$"DB")
	@ 02,041 psay "| "+Left(SA1->A1_COD+"-"+SA1->A1_LOJA+"  "+SA1->A1_NOME, 55)
	@ 02,100 psay "| PRE-NOTA DO PEDIDO N. "+SC5->C5_NUM
	@ 03,041 psay "| "+Left(ALLTRIM(SA1->A1_ENDENT)+'-'+ALLTRIM(SA1->A1_MUNE)+'-'+ALLTRIM(SA1->A1_ESTE),55)
	@ 03,100 psay "| Emitido em : "+DTOC(SC5->C5_EMISSAO)+' as '+SC5->C5_HORA
Else
	@ 02,041 psay "| "+SA2->A2_COD+"-"+SA2->A2_LOJA+"  "+SA2->A2_NOME
	@ 02,100 psay "| PRE-NOTA DO PEDIDO N. "+SC5->C5_NUM
	@ 03,041 psay "| "
	@ 03,100 psay "| Emitido em : "+DTOC(SC5->C5_EMISSAO)+' as '+SC5->C5_HORA
Endif
li:= 4
@ li,000 psay Replicate("-",limite-78)
li++
@ li,000 psay "Impresso dia: " + DTOC(ddatabase) + " as " + SUBSTR(time(),1,5)
_pag := Str(nPag,2)+' /'+Str(nPags,2)
@ li,limite-78-len(_pag) psay _pag
li++
li++
@ li,000 psay "Vendedor.: "+SC5->C5_VEND1+" - "+SA3->A3_NOME
_transp := "Transportadora.:  "+SC5->C5_TRANSP+" *** "+ALLTRIM(SA4->A4_NOME)+" ***"
@ li,limite-78-len(_transp) psay _transp
li++
@ li,000 psay 'Operador.: '+Alltrim(Posicione('SU7',1,xFILIAL('SU7')+SC5->C5_OPERADO,'SU7->U7_NOME'))
_condpag := "Cond.Pagamento.: "+SC5->C5_CONDPAG+" - "+Alltrim(SE4->E4_DESCRI)
@ li,limite-78-len(_condpag) psay _condpag
li++
li++
@ li,000 psay Replicate("-",limite-78)
li++
@ li,000 psay "It Codigo UM Descricao do Material                                           Quantidade     Lote         Data Validade         Localizacao"
li++
@ li,000 psay Replicate("-",limite-78)
li++

nPag := nPag + 1

Return( .T. )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Fun‡…o    ³ ImpItem  ³ Autor ³ Rodrigo Franco        ³ Data ³ 05.11.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Emissao da Pr‚-Nota                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ PRENOTA                                                    ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ImpItem()

dBSELECTAREA("SC9")
dBSETORDER(1)
dBSEEK(xFilial("SC9")+SDC->DC_PEDIDO+SDC->DC_ITEM)

dbSelectArea("SB1")
dbSeek(cFilial+SDC->DC_PRODUTO)

@ li,000 psay Replicate("-",limite-78)
li++
@li,000 psay SDC->DC_ITEM
@li,003 psay SUBSTR(SDC->DC_PRODUTO,1,6)
@li,010 psay SB1->B1_UM
@li,013 psay SB1->B1_DESC
@li,074 psay SDC->DC_QUANT Picture "@E 9,999,999"
@li,092 psay SDC->DC_LOTECTL
@li,105 psay IIf(Empty(SC9->C9_DTVALID),Space(8),SC9->C9_DTVALID)
@li,127 psay SDC->DC_LOCALIZ
li++

Return(nil)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Fun‡…o    ³ ImpRodape³ Autor ³ Rodrigo Franco        ³ Data ³ 05.11.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Emissao da Pr‚-Nota                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Matr730                                                    ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ImpRodape()

@ li,000 psay Replicate("-",limite-78)
li++
@ 49,000 psay Replicate("-",limite-78)
@ 50,002 psay "PESO BRUTO --->"+STR(SC5->C5_PBRUTO)
@ 51,002 psay "PESO LIQUIDO ->"+STR(SC5->C5_PESOL)
@ 51,040 psay "SEPARADO POR -> _______________"
@ 51,076 psay "CONFERIDO POR -> _______________"
@ 51,115 psay "VOLUMES -->________________"
@ 52,000 psay Replicate("-",limite-78)

U_BigNumber(SC5->C5_NUM)

@ 60,000 psay Replicate("-",limite-78)
@ 61,000 psay "Mensagem para o DEPOSITO: " + Substr(AllTrim(SC5->C5_MENDEP),1,54)
@ 62,000 psay Substr(AllTrim(SC5->C5_MENDEP),55)
@ 66,000 psay ''
li := 80
SetPrc(0,0)

Return( NIL )
/*
**************************
User Function BigNumbe3(_PEDIDO)
Local anumero := ;
{{'  11  ',' 111  ','  11  ','  11  ','  11  ','  11  ','111111'},;
{' 2222 ','22  22','    22','   22 ','  22  ',' 22   ','222222'},;
{'33333 ','    33','    33','33333 ','    33','    33','33333 '},;
{'44  44','44  44','44  44','444444','    44','    44','    44'},;
{'555555','55    ','55    ','55555 ','    55','55  55',' 5555 '},;
{' 6666 ','66  66','66    ','66666 ','66  66','66  66',' 6666 '},;
{'777777','    77','   77 ','  77  ',' 77   ','77    ','77    '},;
{' 8888 ','88  88','88  88',' 8888 ','88  88','88  88',' 8888 '},;
{' 9999 ','99  99','99  99',' 99999','    99','    99',' 9999 '},;
{' 0000 ','00  00','00  00','00  00','00  00','00  00',' 0000 '},;
{'-----------------------------------','|      Numero da Nota Fiscal      |','|                                 |','|                                 |','|                                 |','|                                 |','-----------------------------------'}}
Local _linha :=''
Local _numero := ''
Local ee1, ee2
For ee1 = 1 to 7
	_linha := ''
	For ee2 = 1 to 6
		_numero := anumero[Iif(Subs(_PEDIDO,ee2,1)='0',10,Val(Subs(_PEDIDO,ee2,1)))][ee1]
		_linha := _linha + _numero+space(10)
	Next
	@ 52+ee1,002 psay _linha +space(7)+ anumero[11][ee1]
Next

Return
*/
/*
  11       2222     33333     44  44    555555     6666   -----------------
 111      22  22        33    44  44    55        66  66  | Numero da N.F.|
  11          22        33    44  44    55        66      |               |
  11         22     33333     444444    55555     66666   |               |
  11        22          33        44        55    66  66  |               |
  11       22           33        44    55  55    66  66  |               |
111111    222222    33333         44     5555      6666   -----------------

777777     8888      9999      0000
    77    88  88    99  99    00  00
   77     88  88    99  99    00  00
  77       8888      99999    00  00
 77       88  88        99    00  00
77        88  88    99  99    00  00
77         8888      9999      0000
*/

#Include "Protheus.ch"
#Include "RwMake.ch"
/*
PONTO.......: A410CONS          PROGRAMA....: MATA410
DESCRIวฤO...: SERVE P/INCLUIR BOTOES NA ENCHOICEBAR
UTILIZAวฤO..: E chamada no momento de montar a enchoicebar do pedido de vendas, e serve para incluir mais botoes com rotinas de usuario.
PARAMETROS..: <NENHUM>
RETORNO.....: Deve retornar um array com a seguinte estrutura aButtons[x][3], x determina o numero de botoes a incluir e so esta limitado pelo espaco na tela, e cada botao tem a seguintes propriedades
*/
Static aSave	:= {}
Static aSC5Var	:= {}
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบPrograma  ณ A410CONS บ Autor ณ   Alexandro Dias   บ Data ณ  23/08/01     บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออออนฑฑ
ฑฑบDescricao ณ Inclui botoes especificos na rotina de pedido de vanda.      บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function A410Cons()

Local cCodUsr    := alltrim(RetCodUsr())//Giovani Zago 27/03/2012
Local cUser      := GetMv("ES_VENDUSE",,"000053" )//Giovani Zago 27/03/2012

If Type("cDipVend") == "U" 
	Public cDipVend := alltrim(Posicione("SU7",4,xFilial("SU7") + RetCodUsr(),"U7_CGC"))
EndIf
U_DIPPROC(ProcName(0),U_DipUsr()) // JBS 05/10/2005 - Gravando o nome do Programa no SZU

aButtons := {}

//AAdd(aButtons, {"ALTERA" , {|| IF(!Empty(M->C5_CLIENTE),AxAltera("SA1",SA1->(Recno()),4),.F.),lAltera := .T. },"Altera Cliente..."   } )
AAdd(aButtons, {"ALTERA"  , {|| U_SavePerg("SC5"),IF(!Empty(M->C5_CLIENTE),U_ALTCLIENTE(),.F.),lAltera := .T. ,U_RestPerg()},"Altera Cliente..."   } )
//AAdd(aButtons, {"DBG10"   , {|| If(!Empty(M->C5_CLIENTE),U_CalcuFrete('A410CONS'),.F.)},"Calculo do Frete..." } )

AAdd(aButtons, {"PRECO"   , {||	U_SetC5Var(,,.T.),;
U_SavePerg("SC5"),If(!Empty(M->C5_CLIENTE),U_CalcuFrete('A410CONS'),.F.),;
U_RestPerg(),;
U_RestC5Var(),U_DipCalcCIF()},;
"Calculo do Frete..." } )

AAdd(aButtons, {"DBG09"   , {|| U_SavePerg("SC5"),If(!Empty(M->C5_CLIENTE),U_DIPA004("",.F.),.F.),U_RestPerg()},"Caracteristica de Produto..." } )
AAdd(aButtons, {"DBG07"   , {|| U_SavePerg("SC5"),If(!Empty(M->C5_CLIENTE),U_DIPG013("BOT",.F.),.F.) ,U_RestPerg()},"Saldos em Aberto..." } )
//AAdd(aButtons, {"DBG12"   , {|| U_SavePerg(),If(!Empty(M->C5_CLIENTE),MATC060(),.F.),U_RestPerg()    },"Lotes..." } ) // Lote 23/07/09 MCVN
AAdd(aButtons, {"BMPORD"   , {|| U_SavePerg("SC5"),If(!Empty(M->C5_CLIENTE),MATC060(),.F.),U_RestPerg()    },"Lotes..." } ) // Lote 23/07/09 MCVN
AAdd(aButtons, {"BMPORD"   , {|| U_SavePerg("SC5"),If(!Empty(M->C5_CLIENTE),u_ImpZC6(),.F.),U_RestPerg()    },"Imp. BKP..." } )

If !Inclui .And. !Altera
	If M->C5_TIPODIP == '2' //MCVN - 23/07/09
		AAdd(aButtons, {"SIMULACA"  , {|| U_SavePerg("SC5"),If(!Empty(M->C5_CLIENTE),u_UTmkR3A("",.F.),.F.)    ,U_RestPerg()},"Imprime Or็amento..." } )
	ElseIf M->C5_TIPODIP == '3'
		AAdd(aButtons, {"SIMULACA"  , {|| U_SavePerg("SC5"),If(!Empty(M->C5_CLIENTE),u_UTmkR3A("",.F.),.F.)    ,U_RestPerg()},"Imprime Programa็ใo..." } )
	Else
		AAdd(aButtons, {"SIMULACA"  , {|| U_SavePerg("SC5"),If(!Empty(M->C5_CLIENTE),u_UTmkR03("",.F.),.F.)    ,U_RestPerg()},"Imprime Pedido..." } )
	EndIf
EndIf

//AAdd(aButtons, {"BMPTABLE", {|| U_DIPA041() },"Cadastro de Cliente..." } ) // JBS - 11/01/2010 - Botao para mostrar browse de clientes e
AAdd(aButtons, {"PROCESSA", {|| U_SavePerg("SC5"),U_DIPA041() ,U_RestPerg()},"Cadastro de Cliente..." } ) // JBS - 11/01/2010 - Botao para mostrar browse de clientes e

//If Inclui // MCVN - 28/07/2009

If cDipVend $ cUser//Giovani Zago 27/03/2012
	SC5->(dbSetFilter({|| SC5->C5_VEND1 == cDipVend},"SC5->C5_VEND1 == cDipVend "))//Giovani Zago 27/03/2012
Else
	SC5->(DbClearFilter())
	//Endif
EndIf
Return(aButtons)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSavePerg  บAutor  ณMicrosiga           บ Data ณ  12/17/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Salva Perguntas em uma pilha                               บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Especifico Dipromed                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function SavePerg(_cAlias) // funcao de usuario
/*
Local nI := 0

If Type("aPerg") != "A"
aPerg := {}
EndIf

aAdd(aPerg,{})
Do While Type("MV_PAR"+StrZero(++nI,2)) != "U"
aAdd(aPerg[Len(aPerg)], &("MV_PAR"+StrZero(nI,2)) )
EndDo

Return
*/
Local nx
Local nLen

If ValType(aSave) != "A"
	aSave := {}
EndIf

If _cAlias == Nil
	_cAlias := Alias()
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Adiciona um elemento a pilha                                           ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

aadd( aSave, { IIf(Type("n")=="N",N,Nil),;
IIf(Type("aHeader")  =="A",AClone( aHeader   ),Nil),;
IIf(Type("aCols")    =="A",AClone( aCols     ),Nil),;
IIf(Type("aRotina")  =="A",AClone( aRotina   ),Nil),;
IIf(Type("aMemos")   =="A",AClone( aMemos    ),Nil),;
IIf(Type("cCadastro")=="C",cCadastro          ,Nil),;
IIf(Type("INCLUI")   =="L",INCLUI             ,Nil),;
IIf(Type("ALTERA")   =="L",ALTERA             ,Nil),;
IIf(Type("DELETA")   =="L",DELETA             ,Nil),;
{},;
IIf(Type("aPergunta")=="A",AClone( aPergunta ),Nil),;
IIf(Type("aCpoRet")  =="A",AClone( aCpoRet   ),Nil),;
IIf(Type("aGets")    =="A",AClone( aGets     ),Nil),;
IIf(Type("aTela")    =="A",AClone( aTela     ),Nil),;
IIf(Type("aRetBan")  =="A",AClone( aRetBan   ),Nil),;
SetHelpArray(),;
SetLastPerg(),;
IIf(Type("aButtons")  =="A",AClone( aButtons   ),Nil),;
{} })

nLen := Len(aSave)
nX := 0
Do While Type("MV_PAR"+StrZero(++nx,2)) != "U" .And. nX < 150
	aAdd(aSave[nLen][10],IIf(Type("MV_PAR"+StrZero(nx,2,0))!="U",&("MV_PAR"+StrZero(nx,2,0)) ,Nil))
EndDo

//Salva memoria do alias
If !Empty(_cAlias)
	For nX := 1 To (_cAlias)->(FCount())
		If Type("M->"+Trim((_cAlias)->(FieldName(nX)))) <> "U"
			aAdd(aSave[nLen][19],{"M->"+Trim((_cAlias)->(FieldName(nX))),&("M->"+Trim((_cAlias)->(FieldName(nX))))})
		EndIf
	Next nX
EndIf

Return( Nil )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณRestPerg  บAutor  ณMicrosiga           บ Data ณ  12/17/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Restaura perguntas salvas pela funcao U_SavePerg()         บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Especifico Dipromed                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function RestPerg()
/*
If ValType(aPerg) == "A" .And. Len(aPerg) > 0
aEval(aPerg[Len(aPerg)],{ |x,nI| &("MV_PAR"+StrZero(nI,2)) := x } )
aSize(aPerg,Len(aPerg)-1)
EndIf

Return Nil
*/
Local nx

LOCAL lRet  := .F.
LOCAL nSize

If ValType( aSave ) == "A" .And. !Empty( aSave )
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Verifica se existe uma interface armazenada ( array valido )           ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	
	nSize := Len( aSave )
	
	If aSave[ nSize, 1 ] <> Nil
		n := aSave[ nSize, 1 ]
	EndIf
	
	If aSave[ nSize, 2 ] <> Nil
		aHeader   := aClone( aSave[ nSize, 2 ] )
	EndIf
	
	If aSave[ nSize, 3 ] <> Nil
		aCols     := aClone( aSave[ nSize, 3 ] )
	EndIf
	
	If aSave[ nSize, 4 ] <> Nil
		aRotina   := aClone( aSave[ nSize, 4 ] )
	EndIf
	
	If aSave[ nSize, 5 ] <> Nil
		aMemo     := aClone( aSave[ nSize, 5 ] )
	EndIf
	
	If aSave[ nSize, 6 ] <> Nil
		cCadastro := aSave[ nSize, 6 ]
	EndIf
	
	If aSave[ nSize, 7 ] <> Nil
		INCLUI    := aSave[ nSize, 7 ]
	EndIf
	
	If aSave[ nSize, 8 ] <> Nil
		ALTERA    := aSave[ nSize, 8 ]
	EndIf
	
	If aSave[ nSize, 9 ] <> Nil
		DELETA    := aSave[ nSize, 9 ]
	EndIf
	
	For nx := 1 to Len(aSave[nSize,10])
		If aSave[nSize,10][nx] != Nil
			&("MV_PAR"+StrZero(nx,2,0)):= aSave[nSize,10][nx]
		EndIf
	Next
	
	If aSave[ nSize, 11] <> Nil
		aPergunta := aClone( aSave[ nSize, 11] )
	EndIf
	
	If aSave[ nSize, 12] <> Nil
		aCpoRet   := aClone( aSave[ nSize, 12] )
	EndIf
	
	If aSave[ nSize, 13] <> Nil
		aGets     := aClone( aSave[ nSize, 13] )
	EndIf
	
	If aSave[ nSize, 14] <> Nil
		aTela     := aClone( aSave[ nSize, 14] )
	EndIf
	
	If aSave[ nSize, 15] <> Nil
		aRetBan   := aClone( aSave[ nSize, 15] )
	EndIf
	
	SetHelpArray(aSave[ nSize, 16])
	
	SetLastPerg(aSave[ nSize, 17])
	
	If aSave[ nSize, 18] <> Nil
		aButtons   := aClone( aSave[ nSize, 18] )
	EndIf
	
	aEval(aSave[ nSize ][19], { |x| &(x[1]) := x[2]})
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Exclui o ultimo elemento da pilha                                      ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	
	ASize( aSave, nSize - 1 )
	
	lRet := .T.
	
EndIf

Return( lRet )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSetC5Var  บAutor  ณMicrosiga           บ Data ณ  02/04/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function SetC5Var(cCampo,uConteudo,lClear)
Local _nPos := 0

DEFAULT lClear := .F.

If ValType(aSC5Var) != "A" .Or. lClear
	aSC5Var := {}
EndIf

If !lClear
	If (_nPos := aScan(aSC5Var,{|x| x[1] == cCampo})) == 0
		aAdd(aSC5Var,{cCampo,uConteudo})
	Else
		aSC5Var[_nPos][2] := uConteudo
	EndIf
EndIf

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณRestC5Var บAutor  ณMicrosiga           บ Data ณ  02/04/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function RestC5Var()
Local _aArea	:= GetArea()
Local _SvReadV	:= ReadVar()
Local _nCnt		:= 0
Local _cCposErr	:= ""
Local _uAux

If ValType(aSC5Var) != "A"
	aSC5Var := {}
EndIf

For _nCnt := 1 To Len(aSC5Var)
	If ValType(&(aSC5Var[_nCnt][1])) == ValType(aSC5Var[_nCnt][2])
		__ReadVar 				:= aSC5Var[_nCnt][1]
		_uAux 					:= &(aSC5Var[_nCnt][1])
		&(aSC5Var[_nCnt][1])	:= aSC5Var[_nCnt][2]
		
		If AllTrim(Upper(__ReadVar)) != AllTrim(Upper(_SvReadV)) .And. !CheckSX3(Substr(aSC5Var[_nCnt][1],4),aSC5Var[_nCnt][2] )
			&(aSC5Var[_nCnt][1]) := _uAux
			_cCposErr += If(!Empty(_cCposErr),", ","") + aSC5Var[_nCnt][1]
		EndIf
	Else
		_cCposErr += If(!Empty(_cCposErr),", ","") + aSC5Var[_nCnt][1]
	EndIf
Next _nCnt

If !Empty(_cCposErr)
	MsgAlert("Sistema de prote็ใo ao Pedido! Problema ao atribuir valor ao(s) campo(s): " + _cCposErr )
EndIf

__ReadVar := _SvReadV
RestArea(_aArea)
aSC5Var := {}

Return Empty(_cCposErr)   
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณA410CONS  บAutor  ณMicrosiga           บ Data ณ  07/21/14   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function DelCifSN() 
M->C5_XCIFSN := ""       
Aviso("Aten็ใo","Recแlculo autorizado.",{"Ok"},1)
Return 

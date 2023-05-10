#INCLUDE "Protheus.ch"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAcdR030   บ Autor ณ ACD                บ Data ณ  11/02/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Relacao de Inventario de Estoque (ACD)                     บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ ACDA030                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/   
User Function UAcdR030()

AjustaSX1()
ACDR30B()

Return
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัอออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ ACDR030B บ Autor ณErike Yuri da Silvaบ Data ณ  04/01/2005 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯอออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Relatorio do Monitoramento de Inventario Modelo 1 para    บฑฑ
ฑฑบ          ณ codigo interno.                                           บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ ACDSTDIN                                        			 บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function ACDR30B()
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Declaracao de Variaveis                                             ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Local lUsaCB001		:= UsaCB0("01")

Private cString		:= "CBA"
Private aOrd         := {}
Private cDesc1       := "Este programa tem como objetivo imprimir informacoes referentes ao " //"Este programa tem como objetivo imprimir informacoes referentes ao "
Private cDesc2       := "monitoramento do inventario do ACD" //"monitoramento do inventario do ACD"
Private cDesc3       := "usando codigo "+If(lUsaCB001,"interno","natural")+" modelo 2" //"usando codigo "###"interno"###"natural"###" modelo 2"
Private cPict        := ""
Private lEnd         := .F.
Private lAbortPrint  := .F.
Private limite       := 220
Private tamanho      := "G"
Private nomeprog     := "ACDR030B"
Private nTipo        := 18
Private aReturn      := {"Zebrado",1,"Administracao", 2, 2, 1, "", 1}  //"Zebrado"###"Administracao"
Private nLastKey     := 0
Private cPerg        := "AIA037"
Private titulo       := "Relatorio de Monitoramento do Inventario para Codigo "+; //"Relatorio de Monitoramento do Inventario para Codigo "
                         If(lUsaCB001,"Interno","Natural")+" Modelo 2" //"Interno"###"Natural"###" Modelo 2"
Private nLin         := 99
Private Cabec1       := ""
Private Cabec2       := ""
Private cbtxt        := "Registro(s) lido(s)" //"Registro(s) lido(s)"
Private cbcont       := 0
Private CONTFL       := 01
Private m_pag        := 01
Private imprime      := .T.
Private wnrel        := "ACDR030B"

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Variaveis utilizadas como Parametros                                ณ
//ณ MV_PAR01 = Mestre De          ?                                     ณ
//ณ MV_PAR02 = Mestre Ate         ?                                     ณ
//ณ MV_PAR03 = Armazem De         ?                                     ณ
//ณ MV_PAR04 = Armazem Ate        ?                                     ณ
//ณ MV_PAR05 = Produto  De        ?                                     ณ
//ณ MV_PAR06 = Produto  Ate       ?                                     ณ
//ณ MV_PAR07 = Endereco De        ?                                     ณ
//ณ MV_PAR08 = Endereco Ate       ?                                     ณ
//ณ MV_PAR09 = Data De            ?                                     ณ
//ณ MV_PAR10 = Data Ate           ?                                     ณ
//ณ MV_PAR11 = Status             ?                                     ณ
//ณ MV_PAR12 = Tipo de Inventario ?                                     ณ
//ณ MV_PAR13 = Lista Etiquetas    ?                                     ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

wnrel := SetPrint(cString,NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,.F.,Tamanho,Nil,.T.)

Pergunte(cPerg,.F.)

If nLastKey == 27
	Return
Endif

SetDefault(aReturn,cString)

If nLastKey == 27
	Return
Endif

Processa({|| R030B() },Titulo)
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัอออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณ R030B     บ Autor ณErike Yuri da Silvaบ Data ณ  11/02/05   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯอออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Funcao auxiliar chamada pela RPTSTATUS. A funcao RPTSTATUS บฑฑ
ฑฑบ          ณ monta a janela com a regua de processamento.               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ ACDR030B                                        			  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Variaveis utilizadas como Parametros                                ณ
//ณ MV_PAR01 = Mestre De          ?                                     ณ
//ณ MV_PAR02 = Mestre Ate         ?                                     ณ
//ณ MV_PAR03 = Armazem De         ?                                     ณ
//ณ MV_PAR04 = Armazem Ate        ?                                     ณ
//ณ MV_PAR05 = Produto  De        ?                                     ณ
//ณ MV_PAR06 = Produto  Ate       ?                                     ณ
//ณ MV_PAR07 = Endereco De        ?                                     ณ
//ณ MV_PAR08 = Endereco Ate       ?                                     ณ
//ณ MV_PAR09 = Data De            ?                                     ณ
//ณ MV_PAR10 = Data Ate           ?                                     ณ
//ณ MV_PAR11 = Status             ?                                     ณ
//ณ MV_PAR12 = Tipo de Inventario ?                                     ณ
//ณ MV_PAR13 = Lista Etiquetas    ?                                     ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
/*/
Static Function R030B()
Local cExpres
Local cIndCBA
Local cIndex
Local cMestreDe  := MV_PAR01
Local cMestreAte := MV_PAR02
Local cArmDe     := MV_PAR03
Local cArmAte    := MV_PAR04
Local cProdDe    := MV_PAR05
Local cProdAte   := MV_PAR06
Local cEndDe     := MV_PAR07
Local cEndAte    := MV_PAR08
Local dDtDe      := MV_PAR09
Local dDtAte     := MV_PAR10
Local nStatusInv := MV_PAR11
Local cTipoInv	  := Str(MV_PAR12,1)
Local lPrintEtiq := If(MV_PAR13==1,.T.,.F.)
Local nIndex     := 0
Local nPos		  := 0
Local cCodInv    := ""
Local cStatus    := ""
Local cProdAtu	  := ""
Local lFirst     := .t.
Local lLocaliza  := .f. 	//Controle de localizacao
Local lUsaCB001  := UsaCB0("01")
Local aAreaCBA   := GetArea("CBA")
Local aProdLido  := {}
Local aEtiqLida  := {}
Local nI
Private cCodOpe  := ""
Private cCBBNum  := ""
Private cClasses :=""
Private nContagem:= 0

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Monta filtro e indice da IndRegua                            ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

SB1->(DbSetorder(1))
SBF->(DbSetorder(1))
SB3->(DbSetOrder(1))
CBC->(DbSetOrder(2))
CBB->(DbSetOrder(1))
CBA->(DbSetOrder(1))

cIndex:= IndexKey()

cExpres:= 'CBA_FILIAL=="'+xFilial("CBA")+'".And.'
cExpres+= 'CBA_CODINV>="'+cMestreDe+'".And.'
cExpres+= 'CBA_CODINV<="'+cMestreAte+'".And.'
cExpres+= 'CBA_LOCAL>="'+cArmDe+'".And.'
cExpres+= 'CBA_LOCAL<="'+cArmAte+'".And.'
cExpres+= 'CBA_PROD>="'+cProdDe+'".And.'
cExpres+= 'CBA_PROD<="'+cProdAte+'".And.'
cExpres+= 'CBA_LOCALI>="'+cEndDe+'".And.'
cExpres+= 'CBA_LOCALI<="'+cEndAte+'".And.'
cExpres+= 'CBA_STATUS<="3" .And.'
cExpres+= 'DTOS(CBA_DATA)>="'+DTOS(dDtDe)+'".And.'
cExpres+= 'DTOS(CBA_DATA)<="'+DTOS(dDtAte)+'" '    

If mv_par16 == 2
	cExpres+= '.And. CBA_CONTR == 2 ' 
EndIf

If cTipoInv $ "1|2"
	cExpres+= '.And. CBA_TIPINV=="'+cTipoInv+'"'
EndIf

cIndCBA := CriaTrab(Nil,.F.)

IndRegua("CBA",cIndCBA,cIndex,Nil,cExpres,"Selecionando Registros ...") //"Selecionando Registros ..."
nIndex := RetIndex("CBA")

#IFNDEF TOP
   dbSetIndex(cIndCBA+OrdBagExt())
#ENDIF
dbSetOrder(nIndex+1)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Verifica o numero de registros validos para a SetRegua ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
CBA->(DbGoTop())
CBA->(ProcRegua(RecCount()))

cCodInv := CBA->CBA_CODINV
While !CBA->(Eof())
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Verifica se o usuario interrompeu o relatorio                ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If lAbortPrint
		@nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***" //"*** CANCELADO PELO OPERADOR ***"
		Exit
	Endif
	IncProc("Processando Mestre de Inventario: "+CBA->CBA_CODINV)    //"Processando Mestre de Inventario: "
	If (nStatusInv != 5)
		If	(nStatusInv == 1 .AND. !(CBA->CBA_STATUS $ "12")) .OR. ;
			(nStatusInv == 2 .AND. CBA->CBA_STATUS != "3") 	.OR.;
			(nStatusInv == 3 .AND. CBA->CBA_STATUS != "4")    .OR.;
			(nStatusInv == 4 .AND. CBA->CBA_STATUS != "5") .OR. (CBA->CBA_STATUS == "0")
			cCodInv := CBA->CBA_CODINV
			CBA->(DbSkip())
		Loop
		EndIf
	Endif

	nContagem:= 0
	CBB->(DbSeek(xFilial("CBB")+CBA->CBA_CODINV))
	While CBB->(!Eof() .AND. CBB_FILIAL+CBB_CODINV == xFilial("CBA")+CBA->CBA_CODINV)
		nContagem++
		cCBBNum  := CBB->CBB_NUM
		cCodOpe  := CBB->CBB_USU
		cStatus  := CBB->CBB_STATUS
		CBB->(DbSkip())
	Enddo
	If lFirst .AND. cTipoInv != "3"
		ImpCabec(cStatus)
		lFirst := .f.
	Endif

	If cStatus == "1" // Em andamento
		If nLin > 59 // Salto de Pแgina. Neste caso o formulario tem 55 linhas...
			ImpCabec(cStatus)
		Endif
		ImpCbcDet1(.f.,(cCodInv <> CBA->CBA_CODINV))
		nLin++
		@nLin, 000 PSAY "***  CONTAGEM EM ANDAMENTO  -  "+TIME()+"   ***"        //"***  CONTAGEM EM ANDAMENTO  -  "
		nLin++
		cCodInv := CBA->CBA_CODINV
		CBA->(DbSkip())
		Loop
	ElseIf (cTipoInv == "3") .and. (CBA->CBA_TIPINV # cTipoInv) .AND. CBC->(DbSeek(xFilial("CBC")+cCBBNum))
		cTipoInv := CBA->CBA_TIPINV
		ImpCabec(cStatus)
		ImpCbcDet1(.t.,.f.)
	ElseIf CBC->(DbSeek(xFilial("CBC")+cCBBNum))
/*
		If nLin > 59 // Salto de Pแgina. Neste caso o formulario tem 55 linhas...
			ImpCabec(cStatus)
		Endif
		ImpCbcDet1(.t.,(cCodInv <> CBA->CBA_CODINV))
*/		
	Else
		If nLin > 59 // Salto de Pแgina. Neste caso o formulario tem 55 linhas...
			ImpCabec(cStatus)
		Endif
		ImpCbcDet1(.f.,(cCodInv <> CBA->CBA_CODINV))
		nLin++
		@nLin, 000 PSAY "***  ITENS DO INVENTARIO "+cCBBNum+" NAO ENCONTRADOS ***"        //"***  ITENS DO INVENTARIO "###" NAO ENCONTRADOS ***"
		nLin++
		cCodInv := CBA->CBA_CODINV
		CBA->(DbSkip())
		Loop
	Endif

	aProdLido := {}
	aEtiqLida := {}
	CBC->(DbSetOrder(2))
	CBC->(DbSeek(xFilial("CBC")+cCBBNum))
	While CBC->(!Eof() .AND. CBC_FILIAL+CBC_NUM == xFilial("CBB")+cCBBNum)
		If CBC->CBC_CONTOK == '1'
			CBC->(DbSkip())			
			Loop
		EndIf   
		
		If nContagem > 1 .And. CtgBatida(CBC->CBC_CODINV,CBC->CBC_COD,CBC->CBC_LOTECT,CBC->CBC_LOCAL,CBC->CBC_LOCALI) 
			CBC->(DbSkip())	
			Loop
		EndIf 
		
		nPos := AsCan(aProdLido,{|x| x[1]+x[3]+x[4]+x[5]+x[6]+x[7]==CBC->(CBC_COD+CBC_LOCAL+CBC_LOCALI+CBC_LOTECT+CBC_NUMLOT+CBC_NUMSER)})
		If Empty(nPos)
			SB1->(DbSeek(xFilial('SB1')+CBC->CBC_COD))
			SB3->(DbSeek(xFilial('SB3')+CBC->CBC_COD))

			If SuperGetMV("MV_LOCALIZ",.F.,"N")=="S" .and. Localiza(CBC->CBC_COD)
				lLocaliza := .t.
			Else
				lLocaliza := .f.
			EndIf
                                                            
			aRet := DipSldInv(CBC->CBC_CODINV,CBC->CBC_COD,CBC->CBC_LOTECT,CBC->CBC_LOCAL)			
			
			CBC->(Aadd(aProdLido,{CBC_COD,Left(SB1->B1_DESC,30),CBC_LOCAL,CBC_LOCALI,;
		    								CBC_LOTECT,CBC_NUMLOT,CBC_NUMSER,SB3->B3_CLASSE,;
		    								0,IIf(Len(aRet)>0,aRet[1],0),IIf(Len(aRet)>1,aRet[2],0)}))

			If lLocaliza
				aProdLido[Len(aProdLido),9] := CBC->(SaldoSBF(CBC_LOCAL,CBC_LOCALI,CBC_COD,CBC_NUMSER,CBC_LOTECT,CBC_NUMLOT))
			Else
				SB2->(DbSeek(xFilial('SB2')+CBC->(CBC_COD+CBC_LOCAL)))
				aProdLido[Len(aProdLido),9] :=	SaldoSB2(,.F.)
			EndIf                                           
		Else                             
			aRet := DipSldInv(CBC->CBC_CODINV,CBC->CBC_COD,CBC->CBC_LOTECT,CBC->CBC_LOCAL)			
			aProdLido[nPos,10] := IIf(Len(aRet)>0,aRet[1],0)
			aProdLido[nPos,11] := IIf(Len(aRet)>1,aRet[2],0)
		EndIf                 
		
		If lUsaCB001 .AND. lPrintEtiq
			CBC->(Aadd(aEtiqLida,{CBC_COD,CBC_LOCAL,CBC_LOCALI,	CBC_LOTECT,CBC_NUMLOT,CBC_NUMSER,CBC_CODETI,CBC_QUANT}))
		EndIf

		CBC->(DbSkip())
	Enddo
	//Imprimir
	//Possicoes do array aProdLido
	//[01] - CBC->CBC_COD
	//[02] - Left(SB1->B1_DESC,30)
	//[03] - CBC->CBC_LOCAL
	//[04] - CBC->CBC_LOCALI
	//[05] - CBC->CBC_LOTECT
	//[06] - CBC->CBC_NUMLOT
	//[07] - CBC->CBC_NUMSER
	//[08] - SB3->B3_CLASSE
	//[09] - SALDO EM ESTOQUE
	//[10] - QTD. ELEITA  
	
  	If mv_par17 == 1
		If Len(aProdLido)==0  
			cCodInv := CBA->CBA_CODINV
			CBA->(dbSkip())
	 		Loop
		EndIf    
	Else      		
		If Len(aProdLido)>0  
			cCodInv := CBA->CBA_CODINV
			CBA->(dbSkip())
	 		Loop
		EndIf 
	EndIf
		
	If nLin > 59 // Salto de Pแgina. Neste caso o formulario tem 55 linhas...
		ImpCabec(cStatus)
	Endif

	ImpCbcDet1(.t.,(cCodInv <> CBA->CBA_CODINV))
	
	For nI:=1 To Len(aProdLido)
		If nLin > 59 // Salto de Pแgina. Neste caso o formulario tem 55 linhas...
			ImpCabec(cStatus)
		Endif

		If lUsaCB001 .and.  lPrintEtiq
			@nLin, 000 PSAY aProdLido[nI,1]
			@nLin, 017 PSAY aProdLido[nI,2]
			@nLin, 048 PSAY aProdLido[nI,3]
			@nLin, 058 PSAY aProdLido[nI,4]
			If mvPar15 == 2
				@nLin, 074 PSAY aProdLido[nI,5]
			EndIf
			If mv_par14 == 2
				@nLin, 086 PSAY aProdLido[nI,6]
				@nLin, 096 PSAY aProdLido[nI,7]
				@nLin, 117 PSAY aProdLido[nI,8]	
				@nLin, 129 PSAY aProdLido[nI,9]  Picture "@E 999,999,999.99"
				@nLin, 149 PSAY aProdLido[nI,10] Picture "@E 999,999,999.99"
				@nLin, 169 PSAY aProdLido[nI,11] Picture "@E 999,999,999.99"
			EndIf
			nLin++
			@nLin,016 PSAY "COD. ETIQUETA ELEITAS" //"COD. ETIQUETA ELEITAS"
			@nLin,040 PSAY "QUANTIDADE" //"QUANTIDADE"
			nLin++
			While .T.
				If nLin > 59 // Salto de Pแgina. Neste caso o formulario tem 55 linhas...
					ImpCabec(cStatus)
				Endif
				nPos := AsCan(aEtiqLida,{|x| x[1]+x[2]+x[3]+x[4]+x[5]+x[6]==aProdLido[nI,1]+aProdLido[nI,3]+aProdLido[nI,4]+aProdLido[nI,5]+aProdLido[nI,6]+aProdLido[nI,7]})
				If Empty(nPos)
					Exit
				EndIf
				@nLin,016 PSAY aEtiqLida[nPos,7]+" :"
				@nLin,034 PSAY aEtiqLida[nPos,8] Picture "@E 999,999,999.99"
				nLin++
				aDel(aEtiqLida,nPos)
				aSize(aEtiqLida,Len(aEtiqLida)-1)
			EndDo
			nLin+=2
		Else
			@nLin, 000 PSAY aProdLido[nI,1]
			@nLin, 016 PSAY "|"
			@nLin, 017 PSAY aProdLido[nI,2]
			@nLin, 047 PSAY "|"
			@nLin, 048 PSAY aProdLido[nI,3]
			@nLin, 057 PSAY "|"
			@nLin, 058 PSAY aProdLido[nI,4]
			If mv_par15 == 2
				@nLin, 073 PSAY "|"
				@nLin, 074 PSAY aProdLido[nI,5]
			EndIf
			If mv_par14 == 2
				@nLin, 085 PSAY "|"
				@nLin, 086 PSAY aProdLido[nI,6]
				@nLin, 095 PSAY "|"
				@nLin, 096 PSAY aProdLido[nI,7]
				@nLin, 116 PSAY "|"
				@nLin, 117 PSAY aProdLido[nI,8]
				@nLin, 128 PSAY "|"
				@nLin, 129 PSAY aProdLido[nI,9]  Picture "@E 999,999,999.99"
				@nLin, 148 PSAY "|"
				@nLin, 149 PSAY aProdLido[nI,10] Picture "@E 999,999,999.99"
				@nLin, 168 PSAY "|"
				@nLin, 169 PSAY aProdLido[nI,11] Picture "@E 999,999,999.99"

			EndIf
			nLin++
		EndIf
	Next
	cCodInv := CBA->CBA_CODINV
	CBA->(DbSkip())
Enddo

If nLin # 06
	@nLin,000 PSAY ""
Endif

SET DEVICE TO SCREEN
If aReturn[5]==1
	DbCommitAll()
	SET PRINTER TO
	OurSpool(wnrel)
Endif
MS_FLUSH()
RestArea(aAreaCBA)
	
SET FILTER TO

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออัออออออออออออออออออออหออออออัออออออออออปฑฑ
ฑฑบFuno    ณImpCabec     บAutor  ณACD                 บ Data ณ10/02/05  บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออออออนฑฑ
ฑฑบDescricao ณImprime o Cabecalho das Paginas                             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณACDR030                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function ImpCabec(cStatus)
Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
nLin:= 06
Return
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออัออออออออออออออออออออหออออออัออออออออออปฑฑ
ฑฑบFuno    ณImpCbcDet1   บAutor  ณACD                 บ Data ณ10/02/05  บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออออออนฑฑ
ฑฑบDescricao ณImprime o Detalhe do Cabecalho das Paginas                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณACDR030                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function ImpCbcDet1(lImp,lQuebra)
Local  cDescStat:= "NAO INICIADO" //"NAO INICIADO"
Local  cNomeOpe := ""
Default lImp    := .t.
Default lQuebra := .f.

CB1->(DbSetOrder(1))
If CB1->(DbSeek(xFilial("CB1")+cCodOpe,.F.))
   cNomeOpe := Left(CB1->CB1_NOME,15)
EndIf

If Empty(CBA->CBA_STATUS)
   cDescStat := "NAO INICIADO" //"NAO INICIADO"
ElseIf CBA->CBA_STATUS == "1"
   cDescStat := "EM ANDAMENTO" //"EM ANDAMENTO"
ElseIf CBA->CBA_STATUS == "2"
   cDescStat := "EM PAUSA" //"EM PAUSA"
ElseIf CBA->CBA_STATUS == "3"
   cDescStat := "CONTADO" //"CONTADO"
ElseIf CBA->CBA_STATUS == "4"
   cDescStat := "FINALIZADO"    //"FINALIZADO"
ElseIf CBA->CBA_STATUS == "5"
   cDescStat := "PROCESSADO" //"PROCESSADO"
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณAnalisando Classificacao por curva ABC                        ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
cClasses := ""
If CBA->CBA_CLASSA=="1"
	cClasses+="A"
EndIf
If CBA->CBA_CLASSB=="1"
	cClasses+="B"
EndIf
If CBA->CBA_CLASSC=="1"
	cClasses+="C"
EndIf

If lQuebra
	nLin++
	@nLin, 000 PSAY Replicate("_",220)
	nLin++
	
	If mv_par17==1
		nLin++
	EndIf
	
EndIf

@nLin, 000 PSAY "MESTRE..............: "+CBA->CBA_CODINV //"MESTRE..............: "
@nLin, 034 PSAY "CONTAGEM.: "+StrZero(nContagem,3) //"CONTAGEM.: "
@nLin, 050 PSAY "OPERADOR.: "+cCodOpe //"OPERADOR.: "
@nLin, 070 PSAY "- "+cNomeOpe
@nLin, 109 PSAY "ARMAZEM.: "+CBA->CBA_LOCAL //"ARMAZEM.: "
//@nLin, 109 PSAY "ENDERECO.: "+Alltrim(CBA->CBA_LOCALI)
@nLin, 131 PSAY "ANALISA CLASSE ABC...: "+If(Empty(cClasses),"-",cClasses) //"ANALISA CLASSE ABC...: "
@nLin, 170 PSAY "STATUS...: "+cDescStat //"STATUS...: "
nLin++
If CBA->CBA_TIPINV=="2"
	@nLin, 000 PSAY "TIPO DE INVENTARIO..: Por Endereco" //"TIPO DE INVENTARIO..: Por Endereco"
	@nLin, 050 PSAY "ENDERECO..:"+Alltrim(CBA->CBA_LOCALI) //"ENDERECO..:"
Else
	@nLin, 000 PSAY "TIPO DE INVENTARIO..: Por Produto" //"TIPO DE INVENTARIO..: Por Produto"
	If Empty(CBA->CBA_PROD)
		@nLin, 050 PSAY "PRODUTO..: Todos os Produtos" //"PRODUTO..: Todos os Produtos"
	Else
		SB1->(DbSeek(xFilial("SB1")+CBA->CBA_PROD))
		@nLin, 050 PSAY "PRODUTO..: "+CBA->CBA_PROD //"PRODUTO..: "
		@nLin, 070 PSAY "- "+SB1->B1_DESC
	EndIf
EndIf

nLin++
If mv_par17==1
	nLin++
EndIf

If lImp .And. mv_par17 == 1
	ImpCbcDet2()
EndIf

Return
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออัออออออออออออออออออออหออออออัออออออออออปฑฑ
ฑฑบFuno    ณImpCbcDet2   บAutor  ณACD                 บ Data ณ10/02/05  บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออออออนฑฑ
ฑฑบDescricao ณImprime o Detalhe do Cabecalho dos Produtos                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณACDR030                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function ImpCbcDet2()
	@nLin,000 PSAY "PRODUTO" //"PRODUTO"
	@nLin,016 PSAY "|DESCRICAO" //"|DESCRICAO"
	@nLin,047 PSAY "|ARMAZEM" //"|ARMAZEM"
	@nLin,057 PSAY "|ENDERECO" //"|ENDERECO"
    If mv_par15 == 2
		@nLin,073 PSAY "|LOTE" //"|LOTE"
	EndIf
	If mv_par14 ==2
		@nLin,085 PSAY "|SUB-LOTE" //"|SUB-LOTE"
		@nLin,095 PSAY "|N.SERIE" //"|N.SERIE"
		@nLin,116 PSAY "|CLASSE ABC"   //"|CLASSE ABC"   
		@nLin,128 PSAY "|SALDO ESTOQUE" //"|SALDO ESTOQUE"
		@nLin,148 PSAY "|SALDO 1" //"|SLD.INVENTARIADO"
		@nLin,168 PSAY "|SALDO 2" //"|SLD.INVENTARIADO"
	EndIf
	nLin++
Return
/*
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuncao    ณ AjustaSX1  ณ Autor ณ Paulo Fco. Cruz Nt.   ณ Data ณ 20/05/10 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescricao ณ Atualiza a tabela de perguntas                			    ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณSintaxe   ณ AjustaSX1()                                                  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso		 ณ ACDR030				                 					    ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function AjustaSX1()
Local aArea		:= GetArea()
Local nTamCod	:= TamSx3("CBA_CODINV" )[1]
Local aRegs		:= {}

Begin Transaction
	cQuery := "UPDATE "+MPSysSqlName("SX1")+ " SET X1_TAMANHO = " + cValToChar(nTamCod) +" "
	cQuery += "WHERE D_E_L_E_T_ = '' AND "
	cQuery += "X1_GRUPO  = 'AIA037' AND (X1_ORDEM = '01' OR X1_ORDEM = '02') AND X1_TAMANHO <> " + cValToChar(nTamCod)
	nErro := TcSqlExec(cQuery)
							
	If nErro != 0
		MsgStop("Erro na execu็ใo da query: "+TcSqlError(), "Aten็ใo")
		DisarmTransaction()
	EndIf
End Transaction

/*
dbSelectArea("SX1")
dbSetOrder(1)

If SX1->(DbSeek(PadR("AIA037",10)+"01")) .And. SX1->X1_TAMANHO != nTamCod
	RecLock("SX1",.F.)
	Replace SX1->X1_TAMANHO With nTamCod
	SX1->(MsUnlock())
EndIf

If SX1->(DbSeek(PadR("AIA037",10)+"02")) .And. SX1->X1_TAMANHO != nTamCod
	RecLock("SX1",.F.)
	Replace SX1->X1_TAMANHO With nTamCod
	SX1->(MsUnlock())
EndIf
*/

aAdd(aRegs,{"AIA037","14","Lista Saldo? ","","","mv_chg","C",1,0,0,"C","","MV_PAR14","Nใo","","","","","Sim","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{"AIA037","15","Mostra Lote? ","","","mv_chh","C",1,0,0,"C","","MV_PAR15","Nใo","","","","","Sim","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{"AIA037","16","Segunda Cont?","","","mv_chi","C",1,0,0,"C","","MV_PAR16","Nใo","","","","","Sim","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{"AIA037","17","Divergencia? ","","","mv_chj","C",1,0,0,"C","","MV_PAR17","Divergencia","","","","","Ok","","","","","","","","","","","","","","","","","","",""})

PlsVldPerg( aRegs )       


RestArea(aArea)

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณUACDR030  บAutor  ณMicrosiga           บ Data ณ  01/23/13   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function CtgBatida(cCodInv,cProduto,cLote,cLocal,cLocaliz)  
Local cSQL 		 := ""
Local lRet		 := .F.  
Local lFlag		 := .F.
Local aQuant	 := {}
DEFAULT cCodInv  := "" 
DEFAULT cProduto := ""

cSQL := " SELECT "
cSQL += " 	CBC_QUANT "
cSQL += " 	FROM "
cSQL += " 		"+RetSQLName("CBC")
cSQL += " 		WHERE "
cSQL += " 			CBC_FILIAL 		= '"+xFilial("CBC")+"' "
cSQL += " 			AND CBC_CODINV 	= '"+cCodInv+"' "
cSQL += " 			AND CBC_COD 	= '"+cProduto+"' "
cSQL += " 			AND CBC_LOTECT 	= '"+cLote+"' "
cSQL += " 			AND D_E_L_E_T_ 	= ' ' "

cSQL := ChangeQuery(cSQL)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),"QRYCBC",.T.,.T.)   

TCSETFIELD("QRYCBC","CBC_QUANT","N",12,4)

While !QRYCBC->(Eof())            
    If aScan(aQuant, {|x| x==QRYCBC->CBC_QUANT})>0
    	lRet := .T.
     	Exit
    EndIf
	aAdd(aQuant, QRYCBC->CBC_QUANT)		
	QRYCBC->(dbSkip())
EndDo 
QRYCBC->(dbCloseArea())	

If !lRet .And. Len(aQuant)>0
	cSQL := " SELECT BF_QUANT "
	cSQL += " FROM "+RetSqlName("SBF")+" SBF "
	cSQL += " WHERE SBF.BF_FILIAL ='"+xFilial("SBF")+"' AND "
	cSQL += " SBF.BF_PRODUTO	= '"+cProduto+"' AND "
	cSQL += " SBF.BF_LOTECTL 	= '"+cLote+"' AND "
	cSQL += " SBF.BF_LOCAL 		= '"+cLocal+"' AND "
	cSQL += " SBF.BF_LOCALIZ 	= '"+cLocaliz+"' AND "
	cSQL += " SBF.D_E_L_E_T_ 	= ' ' "
	
	cSQL := ChangeQuery(cSQL)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),"QRYSBF",.T.,.T.)   
	           
	TCSETFIELD("QRYSBF","BF_QUANT","N",12,4)
	
	For nI := 1 to Len(aQuant)
		If aQuant[nI] == QRYSBF->BF_QUANT
			lRet := .T.
		EndIf
	Next nI
	QRYSBF->(dbCloseArea())                             	
EndIf

Return lRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณUACDR030  บAutor  ณMicrosiga           บ Data ณ  01/26/13   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function DipSldInv(cCodInv,cProduto,cLote,cLocal)
Local cSQL := ""
Local aRet := {}

cSQL := " SELECT "
cSQL += " 	CBC_QUANT "
cSQL += " 	FROM "
cSQL += " 		"+RetSQLName("CBC")
cSQL += " 		WHERE "
cSQL += " 			CBC_FILIAL 		= '"+xFilial("CBC")+"' "
cSQL += " 			AND CBC_CODINV 	= '"+cCodInv+"' "
cSQL += " 			AND CBC_COD 	= '"+cProduto+"' "
cSQL += "			AND CBC_LOCAL   = '"+cLocal+"' "
cSQL += " 			AND CBC_LOTECT 	= '"+cLote+"' "
cSQL += " 			AND D_E_L_E_T_ 	= ' ' "    
cSQL += " ORDER BY CBC_NUM "

cSQL := ChangeQuery(cSQL)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),"QRYCBC2",.T.,.T.)   

TCSETFIELD("QRYCBC2","CBC_QUANT","N",12,4)              

While !QRYCBC2->(Eof())
	aAdd(aRet,QRYCBC2->CBC_QUANT) 
	QRYCBC2->(dbSkip())
EndDo            
QRYCBC2->(dbCloseArea())
	
Return aRet

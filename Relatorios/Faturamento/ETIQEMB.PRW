/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±≥FunáÖo    ≥ ETIQEMB  ≥ Autor ≥ Rafael de Campos Falco≥ Data ≥ 18.11.03 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÖo ≥ Etiquetas para os volumes                                  ≥±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
#include "rwmake.ch"
#DEFINE ctrls   CHR(13)+CHR(10)   && quebra de linha  

User Function ETIQEMB()
Local titulo		:= "Etiquetas para embalagens"
Local cDesc1		:= OemTOAnsi("Este programa ir· emitir as etiquetas",72)
Local cDesc2		:= OemTOAnsi("para as embalagens a serem despachadas.",72)
Local cDesc3		:= ""

Private aReturn		:= {"Etiqueta", 1,"Producao", 1, 2, 1, "",1 }
Private li        	:= 80
Private tamanho		:= "G"
Private limite    	:= 220
Private nomeprog	:= "ETIQEMB"
Private cPerg		:= "ETIEMB"
Private nLastKey	:= 0
Private cString		:= "SF2"
Private wnrel		:= "ETIQEMB"
Private aEtiq		:= {}
Private nVolInit    := 1
Private lVolParcial := .F.

// Verifica as perguntas selecionadas
AjustaSX1(cPerg)                // Verifica perguntas. Se nao existe INCLUI.  

If !Pergunte(cPerg,.T.)    // Solicita parametros
	Return
EndIf

IF MV_PAR02 = MV_PAR03
	nVolInit := MV_PAR04
	IF nVolInit > 1
		lVolParcial := .T.
	ENDIF
ELSE
    MV_PAR04 := 1
ENDIF

// VEFIFICA SE IMPRIME ETIQUETA COMUM OU ETIQUETA DE CODIGO DE BARRAS
If mv_par05 = 1  // ETIQUETA NORMAL
	
	// Envia controle para a funcao SETPRINT
	wnrel := SetPrint(cString,wnrel,cPerg,Titulo,cDesc1,cDesc2,cDesc3,.f.,,.f.,tamanho,,.f.,,,,,)
	
	// Se pressionar ESC cancela o processamento
	If nLastKey == 27
		Return
	Endif
	
	SetDefault(aReturn,cString)
	
	RptStatus({ |lEnd| U_EtiqImp(aEtiq,mv_par04,If(mv_par04>1,.t.,.f.)) }, Titulo)
	
	Set device to Screen
	
	SetPgEject(.F.) // JBS 03/01/2005
	
	//≥ Se em disco, desvia para Spool                                            ≥
	If aReturn[5] == 1    // Se Saida para disco, ativa SPOOL
		Set Printer TO
		Commit
		ourspool(wnrel)
	Endif
	
	MS_FLUSH()
	
ELSE // ETIQUETA DE C”DIGO DE BARRA

   	RptStatus({ |lEnd| U_GERAETQ(mv_par04,If(mv_par04>1,.t.,.f.)) }, Titulo)

Endif

Return
/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±≥FunáÖo    ≥ EtiqImp  ≥ Autor ≥ Rafael de Campos Falco≥ Data ≥ 24.11.03 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÖo ≥ Chamada do Relatorio                                       ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥ Uso      ≥ MATR550			                                          ≥±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
User Function EtiqImp(aEtiq,nVolInit,lVolParcial)
Local limite	:= 80
Local lRet		:= .F.
Local bValida	:= .T.
Local QRY1		:= ""
Local cEtiq001	:= If(cEmpAnt=="04","HEALTH QUALITY INDUSTRIA E COMERCIO LTDA-ME"+space(14),"DIPROMED COMERCIO E IMPORTACAO LTDA"+space(20)) //"DIPROMED COMERCIO E IMPORTACAO LTDA"
Local cEtiq002	:= REPLICATE("=",36)
Local cEtiq003	:= cEtiq004 := cEtiq005 := cEtiq006 := cEtiq007 := cEtiq008 := ""
Local nDesloca	:= 57 // Deslocamento do carro da impressora de uma etiqueta para outra
Local nVol 		:= li := col := 0
Local zI,xi
Local cPedido	:= SC5->C5_NUM 
Local cTipoMovimento

If Len(aEtiq) == 0
		
	QRY1 := "SELECT A1_NOME, A1_END, A1_MUN, A1_EST, A1_CEP, C5_ENDENT, C5_MUNE, C5_ESTE, C5_CEPE, C5_BAIRROE, A4_NOME, F2_VOLUME1, F2_ESPECI1, F2_DOC, F2_SERIE, D2_PEDIDO, F2_CONFERI, D2_ITEM, F2_TRANSP, F2_LOCEXP"
	QRY1 += " FROM " + RetSQLName("SA1")+', '+ RetSQLName("SF2")+', '+ RetSQLName("SA4")+', '+ RetSQLName("SD2")+', '+ RetSQLName("SC5")
	QRY1 += " WHERE F2_SERIE = '" + MV_PAR01 + "'"
	QRY1 += " AND F2_DOC BETWEEN '" + MV_PAR02 + "' AND '" + MV_PAR03 + "'"
	QRY1 += " AND F2_CLIENTE = A1_COD"
	QRY1 += " AND F2_LOJA = A1_LOJA"
	QRY1 += " AND F2_TRANSP = A4_COD"
	QRY1 += " AND F2_DOC = D2_DOC"
	QRY1 += " AND F2_SERIE = D2_SERIE"  
	QRY1 += " AND C5_NUM = D2_PEDIDO"
	QRY1 += " AND D2_ITEM = '01'"      
	QRY1 += " AND F2_FILIAL = '" + xFilial('SF2') + "'"
	QRY1 += " AND D2_FILIAL = '" + xFilial('SD2') + "'"
	QRY1 += " AND C5_FILIAL = '" + xFilial('SC5') + "'"
	QRY1 += " AND " + RetSQLName("SA1")+".D_E_L_E_T_ <> '*'"
	QRY1 += " AND " + RetSQLName("SF2")+".D_E_L_E_T_ <> '*'"
	QRY1 += " AND " + RetSQLName("SD2")+".D_E_L_E_T_ <> '*'"
	QRY1 += " AND " + RetSQLName("SA4")+".D_E_L_E_T_ <> '*'"
	QRY1 += " AND " + RetSQLName("SC5")+".D_E_L_E_T_ <> '*'"
	QRY1 += "ORDER BY F2_DOC"
	
	#xcommand TCQUERY <sql_expr>                          ;
	[ALIAS <a>]                                           ;
	[<new: NEW>]                                          ;
	[SERVER <(server)>]                                   ;
	[ENVIRONMENT <(environment)>]                         ;
	=> dbUseArea(                                         ;
	<.new.>,                                              ;
	"TOPCONN",                                            ;
	TCGENQRY(<(server)>,<(environment)>,<sql_expr>),      ;
	<(a)>, .F., .T.)
	
	// Processa Query SQL
	DbCommitAll()
	TcQuery QRY1 NEW ALIAS "QRY1"         // Abre uma workarea com o resultado da query
	
	DbSelectArea("QRY1")
	QRY1->(dbGotop())
	
	cPedido := QRY1->D2_PEDIDO
	// Montagem do Array com cada etiqueta da query
	Do While QRY1->(!Eof())
		If QRY1->F2_TRANSP <> "000001" .and. QRY1->F2_TRANSP <> '000111'.and. QRY1->F2_TRANSP <> '000851' .And. QRY1->F2_TRANSP <> '000133'
			cEtiq001 := cEtiq001 +If(QRY1->F2_TRANSP = "000113",u_rotacep(Left(QRY1->C5_CEPE,5),QRY1->F2_TRANSP,AllTrim(QRY1->C5_MUNE)),"")
			cEtiq003 := "Destino: " + AllTrim(QRY1->A1_NOME)
			cEtiq004 := "Endereco: " + IIF(AllTrim(QRY1->C5_ENDENT) = "O MESMO",Subs(QRY1->A1_END,1,48),Subs(QRY1->C5_ENDENT,1,48))
			cEtiq005 := "Cidade: " + IIF(AllTrim(QRY1->C5_ENDENT) = "O MESMO",AllTrim(QRY1->A1_MUN)+" / "+QRY1->A1_EST+' - CEP:  '+QRY1->A1_CEP,AllTrim(QRY1->C5_MUNE)+" / "+QRY1->C5_ESTE)+' - CEP:  '+QRY1->C5_CEPE
			cEtiq006 := "Transportadora: " + If(cEmpAnt+cFilAnt=="0401" .And. QRY1->F2_TRANSP = '100000','NOSSO CARRO',AllTrim(QRY1->A4_NOME))
			cEtiq007 := "    Especie: " + AllTrim(QRY1->F2_ESPECI1)
			cEtiq008 := "Nota Fiscal/Serie: " + QRY1->F2_DOC + "/" + mv_par01 + " Pre-Nota: " + QRY1->D2_PEDIDO + "       " + QRY1->F2_LOCEXP + "  " + QRY1->F2_CONFERI
			cEtiq009 := QRY1->F2_VOLUME1
			Aadd(aEtiq,{cEtiq001, cEtiq002, cEtiq003, cEtiq004, cEtiq005, cEtiq006, cEtiq007, cEtiq008,cEtiq009})
		Else
			//IF ("HEALTH" $ SM0->M0_NOMECOM)
			IF cEmpAnt+cFilAnt=="0401"
				Aadd(aEtiq,U_BigNumber(QRY1->F2_DOC,.t.))
			Else                                        
				Aadd(aEtiq,U_BigNumber(QRY1->D2_PEDIDO,.t.))
			Endif
		EndIf
		QRY1->(DbSkip())
	EndDo
	
	DbSelectArea("QRY1")
	QRY1->(DbCloseArea())
	
EndIf

// Set impressora para imprimir com caracter comprimido
//@ 0,0 Psay chr(15)   // JBS 03/01/2006
//setPrc( li,col )
SetPrc(0,0)
// Verifica se a impress„o de volume È parcial ou total
IF  lVolParcial = .T.
	nVol := nVolInit - 1
ENDIF


// Impress„o das Etiquetas contidas no array
For xi := 1 to Len(aEtiq)
	// Impress„o das linha do array
	
	For zi := nVolInit to aEtiq[xi,09]
		nVol++
		@ li,col  Psay chr(15)+aEtiq[xi,1]  // JBS 03/01/2006
		li++
		col := 0
		@ li,col  Psay aEtiq[xi,2]
		li++
		col := 0
		@ li,col  Psay aEtiq[xi,3]
		li++
		col := 0
		@ li,col  Psay aEtiq[xi,4]
		li++
		col := 0
		@ li,col  Psay aEtiq[xi,5]
		li++
		col := 0
		@ li,col  Psay aEtiq[xi,6]
		li++
		col := 0
		If Left(aEtiq[xi,8],1) <> "V"
			@ li,col  Psay "Volumes: " + AllTrim(STR(nVol)) + "/" + AllTrim(STR(aEtiq[xi,9])) + " " + aEtiq[xi,7]
			li++
			col := 0
			@ li,col  Psay aEtiq[xi,8]
			li += 2
			col := 0
		Else
			@ li,col  Psay aEtiq[xi,7]
			li++
			col := 0
			@ li,col  Psay AllTrim(STR(nVol)) + "/" + AllTrim(STR(aEtiq[xi,09])) +" "+ aEtiq[xi,8]
			li += 2
			col := 0
		EndIf
	Next
	nVolInit := 1
	nVol := 0
Next
//li--  // JBS 03/01/2006
@ Li,0 Psay ""
//Setprc(0,0)

//-- GRAVANDO IMPRESS√O ETIQUETA NO KARDEX SZ9
cTipoMovimento := "IMPRESSAO ETIQUETA"
U_DiprKardex(cPedido,U_DipUsr(),cTipoMovimento,.T.,"31")

Return .T.
/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±≥FunáÖo    ≥ GeraEtq  ≥ Autor ≥ Maximo Canuto V.Neto ≥ Data ≥ 08/01/07 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÖo ≥ FunÁ„o P/ Gerar as etiquetas                               ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥ Uso      ≥              	                                          ≥±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
User Function GeraEtq(nVolInit,lVolParcial)
Local   QRY1		:= ""
Local   cEtiqueta	:= "\EDI\etiqueta\"
Local   cLocalEtiq 	:= "C:\etiqueta\
Local 	lNewEtiq	:= (cEmpAnt=="04" .And. GetNewPar("ES_DIPNETI",.T.))
Private nVolume 	:= 1
Private nVolprt 	:= 1
Private nVolTot 	:= 0
Private cLin		:= ""
Private nSerie		:= 0
Private nCepEnt		:= 0
Private nDtAtual 	:= ""
Private nNomeEtiq 	:= ""
Private CodCliBras 	:= If(cEmpAnt == '01',"038","072")
Private Ncep, cComand
Private nRotaEnt   	:= ""
Private nSgFilOrig 	:= ""   
Private nClassif   	:= ""
Private nSequen    	:= 0
Private cTransp    	:= ""
Private cCidade    	:= "" 
Private lAtuMasc   	:= .F.

// Mapeando a porta da Impressora de cÛdigo de barras
//Private cPorta  := Left(Upper(AllTrim(GETMV("MV_LPT_BAR"))),4)
//Private cCaminho:= Upper(AllTrim(GETMV("MV_LPT_BAR")))

Private cPorta  := Left(Upper(AllTrim(GETMV("MV_LPT_BAR"))),4)
Private cCaminho:= Upper(AllTrim(GETMV("MV_LPT_BAR")))

// Imprime normalmente as etiquetas de cÛdigo de barras

If !ExistDir(cLocalEtiq)
	If Makedir(cLocalEtiq) <> 0
		Aviso("AtenÁ„o","N„o foi possÌvel criar a pasta C:\etiqueta\",{"Ok"},1)
		Return
	Endif
Endif

U_DIPPROC(ProcName(0),U_DipUsr())  // Gravando usu·rio no SZU

QRY1 := "SELECT A1_NOME, A1_NREDUZ, F2_VOLUME1, F2_ESPECI1, F2_DOC, F2_SERIE, F2_ETIBRAS, F2_SEPAROU, D2_PEDIDO, F2_CONFERI, D2_ITEM, F2_TRANSP, F2_LOCEXP, C5_ENDENT, C5_BAIRROE, C5_MUNE, C5_ESTE, C5_CEPE, F2_TPFRETE"
QRY1 += " FROM " + RetSQLName("SA1")+', '+ RetSQLName("SF2")+', '+ RetSQLName("SD2")+', '+ RetSQLName("SC5")
QRY1 += " WHERE F2_SERIE = '" + MV_PAR01 + "'"
QRY1 += " AND F2_DOC BETWEEN '" + MV_PAR02 + "' AND '" + MV_PAR03 + "'"
QRY1 += " AND F2_CLIENTE = A1_COD"
QRY1 += " AND F2_LOJA = A1_LOJA"  
QRY1 += " AND F2_DOC = D2_DOC"
QRY1 += " AND F2_SERIE = D2_SERIE"
QRY1 += " AND F2_FILIAL = '" + xFilial('SF2') + "'"
QRY1 += " AND D2_FILIAL = '" + xFilial('SD2') + "'"
QRY1 += " AND C5_FILIAL = '" + xFilial('SC5') + "'"       
If !lNewEtiq
	QRY1 += " AND (F2_TRANSP IN ('000150','000001','000111','000112','000133','000235','000236','003025','100000','000905','001935','002179','102000') OR F2_TPFRETE = 'F') "
Endif
QRY1 += " AND C5_NUM = D2_PEDIDO"
QRY1 += " AND D2_ITEM = '01'"   

QRY1 += " AND " + RetSQLName("SA1")+".D_E_L_E_T_ <> '*'"
QRY1 += " AND " + RetSQLName("SF2")+".D_E_L_E_T_ <> '*'"
QRY1 += " AND " + RetSQLName("SD2")+".D_E_L_E_T_ <> '*'"
QRY1 += " AND " + RetSQLName("SC5")+".D_E_L_E_T_ <> '*'"
QRY1 += "ORDER BY F2_DOC, F2_SERIE"

#xcommand TCQUERY <sql_expr>                          ;
[ALIAS <a>]                                           ;
[<new: NEW>]                                          ;
[SERVER <(server)>]                                   ;
[ENVIRONMENT <(environment)>]                         ;
=> dbUseArea(                                         ;
<.new.>,                                              ;
"TOPCONN",                                            ;
TCGENQRY(<(server)>,<(environment)>,<sql_expr>),      ;
<(a)>, .F., .T.)

// Processa Query SQL
DbCommitAll()
TcQuery QRY1 NEW ALIAS "QRY1"         // Abre uma workarea com o resultado da query


DbSelectArea("QRY1")
QRY1->(dbGotop())

// Montagem do arquivo TXT
If QRY1->(Bof()) .AND. QRY1->(Eof())
	msgInfo("N„o foram encontrados registros com os par‚metros informados","AtenÁ„o")
	//msgInfo("ETIQUETA DE GRAFICA SOMENTE PARA TRANSPORTADORA VTR. VERIFIQUE OS PAR¬METROS","AtenÁ„o")
EndIf

Do While QRY1->(!Eof())
	
	If cEmpAnt == "01" .And. QRY1->F2_TRANSP$'100000/000111/000133' //Emovere/Retira
		QRY1->(dbCloseArea())
		Return .T.
	EndIf
	
	cTransp := QRY1->F2_TRANSP
	cCidade := QRY1->C5_MUNE
	nHdl := fCreate(cEtiqueta + ALLTRIM(QRY1->F2_DOC)+If(lVolParcial,'_'+AllTrim(Str(nVolInit,4,0)),'')+".txt") // Criando arquivo txt
	nVolume := 1
	nRotaEnt   := ""
	nSgFilOrig := "" 
	nClassif   := ""
	nSequen    := 0
	nCep       := ""
	
	IF  lVolParcial = .T.
		nVolume := nVolInit
	ENDIF
	If QRY1->F2_VOLUME1 == 0
		msgInfo("Volume da nota fiscal "+ALLTRIM(QRY1->F2_DOC)+" est· com ZERO","AtenÁ„o")
	  	QRY1->(DbSkip())
	Endif
	 
	// Atualiza m·scara na memÛria da impressora S4M? - MCVN - 26/10/2009
	      
	If Upper(U_DipUsr()) $ 'MAXIMO/MCANUTO/DDOMINGOS/VQUEIROZ/VEGON/RBORGES'
    	If MsgBox("Atualiza m·scaras?","Atencao","YESNO")  
    		lAtuMasc := .T.
    	Endif
    Endif	   
    
	Do While nVolume <= QRY1->F2_VOLUME1		
		// Tratando informaÁıes referente ao VOLUME
		nVolprt   := nVolume
		TRANSFORM(nVolprt, "@!")
		nVolprt   := STR(nVolprt,4,0)
		nVolprt   := STRTRAN(nVolprt," ","0")
		nVolTot   := STR(QRY1->F2_VOLUME1,4,0)
		nVolTot   := STRTRAN(nVolTot," ","0")
		
		
		// Tratando CEP
		nCepEnt := QRY1->C5_CEPE
		nCepEnt := LEFT(nCepEnt,2)+'.'+ RIGHT(LEFT(nCepEnt,5),3)+'-'+RIGHT(nCepEnt,3)
		
		// Tratando informaÁıes referente a sÈrie da nota fiscal
		// AJUSTE NA S…RIE NA NF DA HQ-CD pois o sistema da Braspress n„o aceita UNI - MCVN - 03/03/2010
		IF cEmpAnt+cFilAnt=="0404" 
			nSerie := AllTrim(QRY1->F2_SERIE)
		Else
			nSerie := AllTrim(QRY1->F2_SERIE)
		EndIf
		TRANSFORM(nSerie,"@!")
		nSerie := SPACE(1) + nSerie
		nSerie := STRTRAN(nSerie," ","0")         

	
		SET CENTURY ON
		SET DATE FORMAT TO "DD-MM-YYYY"
		nDtAtual := DTOC(date())
		SET CENTURY OFF
		
		// Buscando informaÁıes no rotacep
		IF F2_TRANSP == '000150'
			nCep :=  QRY1->C5_CEPE
		ELSE
			nCep :=  Left(QRY1->C5_CEPE,5)
		ENDIF
		
		If F2_TRANSP == '000150'
			u_rotacep(nCep,cTransp,cCidade)
		Endif 
		
		
		If "S4M" $ cCaminho		
			// Gerando Arquivo com cÛdigo ZPL        
			If lAtuMasc  .And. nVolume == 1		 
 			    If (QRY1->F2_TPFRETE == 'F' .AND. QRY1->F2_TRANSP <>  "000150") .Or. QRY1->F2_TRANSP $ '000235/000236/003025/000905/001935/002179/102000'    
					// Inicializando
					cLin := "^XA" + ctrls
					cLin := cLin  + "^LH45,0"  + ctrls
					cLin := cLin  + "^PRD" + ctrls
					cLin := cLin  + "^POI" + ctrls
					cLin := cLin  + "^COY" + ctrls
					cLin := cLin  + "^LL784" + ctrls
					// BOX          
					cLin := cLin  + "^FO3,4^GB780,780,4^FS" + ctrls
					cLin := cLin  + "^FO653,4^GB128,374,96^FS" + ctrls
					cLin := cLin  + "^FO550,4^GB105,517,4^FS" + ctrls
					cLin := cLin  + "^FO550,515^GB105,265,4^FS" + ctrls
					cLin := cLin  + "^FO485,4^GB68,517,4^FS" + ctrls
					cLin := cLin  + "^FO420,4^GB68,517,4^FS" + ctrls
					cLin := cLin  + "^FO312,4^GB111,517,4^FS" + ctrls
					cLin := cLin  + "^FO486,515^GB64,264,40^FS" + ctrls
					cLin := cLin  + "^FO388,515^GB96,264,70^FS" + ctrls
					cLin := cLin  + "^FO312,515^GB86,265,4^FS" + ctrls
					cLin := cLin  + "^FO1,1^GB73,390,4^FS" + ctrls
					cLin := cLin  + "^FO1,1^GB73,780,4^FS" + ctrls
					//Campos Fixos                                
					cLin := cLin  + "^FO630,10^GB20,55,15^FS" + ctrls
					cLin := cLin  + "^A0R,18,18^FO629,17^FR^CI0^FDNF:^FS" + ctrls
					cLin := cLin  + "^FO630,519^GB22,55,15^FS" + ctrls
					cLin := cLin  + "^A0R,18,18^FO629,526^FR^CI0^FDVol:^FS" + ctrls
					cLin := cLin  + "^FO530,10^GB20,65,15^FS" + ctrls
					cLin := cLin  + "^A0R,18,18^FO529,17^FR^CI0^FDRem:^FS" + ctrls
					cLin := cLin  + "^FO466,10^GB20,65,15^FS" + ctrls
					cLin := cLin  + "^A0R,18,18^FO465,17^FR^CI0^FDDest:^FS" + ctrls
					cLin := cLin  + "^A0R,18,18^FO511,521^FR^CI0^FDOrigem -^FS" + ctrls
					cLin := cLin  + "^FO367,515^GB20,75,15^FS" + ctrls
					cLin := cLin  + "^A0R,18,18^FO366,520^FR^CI0^FDFROTA:^FS" + ctrls
					cLin := cLin  + "^FO52,08^GB20,55,15^FS" + ctrls
					cLin := cLin  + "^A0R,18,18^FO52,15^FR^CI0^FDObs.:^FS" + ctrls   
					
					cLin := cLin  + "^ISE:BRFOB.GRF,Y^FS" + ctrls
					cLin := cLin  + "^XZ" + ctrls        
			
				ElseIf	QRY1->F2_TRANSP == "000150"             
					// Inicializando
					cLin := "^XA" + ctrls
					cLin := cLin  + "^LH45,0"  + ctrls
					cLin := cLin  + "^PRD" + ctrls
					cLin := cLin  + "^POI" + ctrls
					cLin := cLin  + "^COY" + ctrls
					cLin := cLin  + "^LL784" + ctrls
			
					// BOX          
					cLin := cLin  + "^FO3,4^GB780,780,4^FS" + ctrls
					cLin := cLin  + "^FO653,4^GB128,374,96^FS" + ctrls
					cLin := cLin  + "^FO550,4^GB105,517,4^FS" + ctrls
					cLin := cLin  + "^FO550,4^GB105,235,4^FS" + ctrls
					cLin := cLin  + "^FO550,515^GB105,265,4^FS" + ctrls
					cLin := cLin  + "^FO485,4^GB68,517,4^FS" + ctrls
					cLin := cLin  + "^FO420,4^GB68,517,4^FS" + ctrls
					cLin := cLin  + "^FO312,4^GB111,517,4^FS" + ctrls
					cLin := cLin  + "^FO486,515^GB64,264,40^FS" + ctrls
					cLin := cLin  + "^FO388,515^GB96,264,70^FS" + ctrls
					cLin := cLin  + "^FO312,515^GB86,265,4^FS" + ctrls
					cLin := cLin  + "^FO1,1^GB73,390,4^FS" + ctrls
					cLin := cLin  + "^FO1,1^GB73,780,4^FS" + ctrls
					//Campos Fixos                                
					cLin := cLin  + "^FO630,10^GB20,55,15^FS" + ctrls
					cLin := cLin  + "^A0R,18,18^FO629,17^FR^CI0^FDNF:^FS" + ctrls
					cLin := cLin  + "^FO630,519^GB22,55,15^FS" + ctrls
					cLin := cLin  + "^A0R,18,18^FO629,526^FR^CI0^FDVol:^FS" + ctrls
					cLin := cLin  + "^FO530,10^GB20,65,15^FS" + ctrls
					cLin := cLin  + "^A0R,18,18^FO529,17^FR^CI0^FDRem:^FS" + ctrls
					cLin := cLin  + "^FO466,10^GB20,65,15^FS" + ctrls
					cLin := cLin  + "^A0R,18,18^FO465,17^FR^CI0^FDDest:^FS" + ctrls
					cLin := cLin  + "^A0R,18,18^FO511,521^FR^CI0^FDOrigem -^FS" + ctrls
					cLin := cLin  + "^FO367,515^GB20,75,15^FS" + ctrls
					cLin := cLin  + "^A0R,18,18^FO366,520^FR^CI0^FDFROTA:^FS" + ctrls
					cLin := cLin  + "^A0R,28,38^FO325,17^CI0^FDCEP:^FS" + ctrls
					cLin := cLin  + "^FO52,08^GB20,55,15^FS" + ctrls
					cLin := cLin  + "^A0R,18,18^FO52,15^FR^CI0^FDObs.:^FS" + ctrls 
					cLin := cLin  + "^A0R,55,65^FO05,410^CI0^FDBRASPRESS^FS" + ctrls 		
					cLin := cLin  + "^ISE:BRP1.GRF,Y^FS" + ctrls
					cLin := cLin  + "^XZ" + ctrls
				Endif
			ElseIf (QRY1->F2_TPFRETE == 'F' .AND. QRY1->F2_TRANSP <>  "000150") .Or. QRY1->F2_TRANSP $ '000235/000236/003025/000905/001935/002179/102000'    
		
				cLin := "^XA" + ctrls
				cLin := cLin  + "^XB" + ctrls
				cLin := cLin  + "^LH10,0"  + ctrls
				cLin := cLin  + "^PRD" + ctrls
				cLin := cLin  + "^POI" + ctrls
				cLin := cLin  + "^LL784" + ctrls
				cLin := cLin  + "^COY" + ctrls
				cLin := cLin  + "^ILE:BRFOB.GRF^FS" + ctrls             

				cLin := cLin  + "^A0R,80,70^FO580,60^CI0^FD"+PADR(ALLTRIM(RIGHT(QRY1->F2_DOC,6)),6)+"/"+PADR(QRY1->F2_SERIE,3)+"^FS" + ctrls 
				cLin := cLin  + "^A0R,80,58^FO580,525^CI0^FD"+PADR(nVolprt,4)+"/"+PADR(nVolTot,4)+"^FS" + ctrls   
				cLin := cLin  + "^A0R,30,26^FO530,6^CI0^FD"+If(cEmpAnt=="04",'HEALTH QUALITY IND. E COM. LTDA-ME','DIPROMED COMERCIO E IMPORTACAO LTDA')+"^FS" + ctrls   
				cLin := cLin  + "^A0R,30,30^FO537,601^FR^CI0^FDSAO^FS" + ctrls  
				
				If Len(AllTrim(QRY1->A1_NOME)) <= 40 
					cLin := cLin  + "^A0R,30,26^FO461,6^CI0^FD"+PADR(QRY1->A1_NOME,40)+"^FS" + ctrls   
				Else                                                                             
					cLin := cLin  + "^A0R,28,15^FO461,6^CI0^FD"+PADR(QRY1->A1_NOME,47)+"^FS" + ctrls   
				Endif 
				
				cLin := cLin  + "^A0R,30,26^FO300,25^CI0^FD"+PADR(QRY1->A1_NOME,47)+"^FS" + ctrls   
				cLin := cLin  + "^A0R,35,35^FO260,25^CI0^FDEndereco: ^FS" + ctrls   			
				cLin := cLin  + "^A0R,30,30^FO220,25^CI0^FD"+ PADR(QRY1->C5_ENDENT,60) +"^FS" + ctrls   				
				cLin := cLin  + "^A0R,30,30^FO180,25^CI0^FD"+ PADR(QRY1->C5_MUNE,LEN(AllTrim(QRY1->C5_MUNE)))+"-"+PADR(QRY1->C5_ESTE,2)+" - CEP: "+nCepEnt+"^FS" + ctrls   				
				cLin := cLin  + "^A0R,28,20^FO140,25^CI0^FD"+ PADR("Transp: " +QRY1->F2_TRANSP+"-"+Alltrim(Posicione("SA4",1,xFilial("SA4")+QRY1->F2_TRANSP,"A4_NOME" )),60)+"^FS" + ctrls   		
				cLin := cLin  + "^A0R,20,25^FO110,610^CI0^FD"+ nDtAtual +"^FS" + ctrls   
	 
				If QRY1->F2_ETIBRAS > 0  
				  	cLin := cLin  + "^A0R,18,22^FO110,330^CI0^FR^FD"+AllTrim(PADR(QRY1->F2_ETIBRAS,2))+'™ REIMPRESSAO'+"^FS"+ ctrls
				Endif          
		
				cLin := cLin  + "^A0R,40,40^FO40,50^FR^CI0^FD"+PADR(QRY1->D2_PEDIDO,6) +'   '+ PADR(QRY1->F2_LOCEXP,3)+'  ' +PADR(QRY1->F2_CONFERI,3)+"^FS" + ctrls
				
				If QRY1->F2_TRANSP $ '000235'    
					cLin := cLin  + "^A0R,55,65^FO40,410^CI0^FDSEDEX^FS" + ctrls		
				ElseIf QRY1->F2_TRANSP $ '000236'                                               
					cLin := cLin  + "^A0R,55,65^FO40,410^CI0^FDSEDEX 10^FS" + ctrls	 
				ElseIf QRY1->F2_TRANSP $ '003025'                                               
					cLin := cLin  + "^A0R,55,65^FO40,410^CI0^FDUTILISSIMO^FS" + ctrls			
				ElseIf QRY1->F2_TRANSP $ '000905'                                               
					cLin := cLin  + "^A0R,55,65^FO40,410^CI0^FDJAMEF^FS" + ctrls                
				ElseIf QRY1->F2_TRANSP $ '102000'                                               
					cLin := cLin  + "^A0R,55,65^FO40,410^CI0^FDMANN^FS" + ctrls
				ElseIf QRY1->F2_TRANSP $ '001935'                                               
					cLin := cLin  + "^A0R,55,65^FO40,410^CI0^FDBERTOLINI^FS" + ctrls															
				ElseIf QRY1->F2_TRANSP $ '002179'                                               
					cLin := cLin  + "^A0R,55,65^FO40,410^CI0^FDTERMACO^FS" + ctrls															
				Else
					cLin := cLin  + "^A0R,55,65^FO40,410^CI0^FDFOB^FS" + ctrls		
	     		Endif
				cLin := cLin  + "^XZ" + ctrls    
			ElseIf  QRY1->F2_TRANSP $ "000001/000111/000112/000133/100000"  
			 
				cLin := "^XA" + ctrls
				cLin := cLin  + "^XB" + ctrls
				cLin := cLin  + "^LH10,0"  + ctrls
				cLin := cLin  + "^PRD" + ctrls
				cLin := cLin  + "^POI" + ctrls
				cLin := cLin  + "^LL784" + ctrls
				cLin := cLin  + "^COY" + ctrls
				// BOX          
				cLin := cLin  + "^FO3,4^GB780,780,4^FS" + ctrls 
				
				cLin := cLin  + "^A0R,250,250^FO500,40^CI0^FD"+PADR(QRY1->D2_PEDIDO,6)+"^FS" + ctrls 
				cLin := cLin  + "^A0R,80,70^FO400,40^CI0^FD" +PADR("N.Fiscal/Serie: "+ALLTRIM(RIGHT(QRY1->F2_DOC,6))+"/"+RIGHT(QRY1->F2_SERIE,2),25)+"^FS" + ctrls   
				cLin := cLin  + "^A0R,80,70^FO325,40^CI0^FD" +"Volume : "+PADR(nVolprt,4)+"/"+PADR(nVolTot,4) +"^FS" + ctrls   
				cLin := cLin  + "^A0R,60,60^FO240,40^CI0^FD"+PADR("Separador:  "+QRY1->F2_SEPAROU,16)+"^FS" + ctrls   
				cLin := cLin  + "^A0R,60,60^FO180,40^CI0^FD"+PADR("Conferente: "+QRY1->F2_CONFERI,16)+"^FS" + ctrls   
				cLin := cLin  + "^A0R,60,60^FO120,40^CI0^FD"+PADR("Expedicao:  "+QRY1->F2_LOCEXP,16) +"^FS" + ctrls   				 
				cLin := cLin  + "^XZ" + ctrls    	

			ElseIf QRY1->F2_TRANSP == "000150" //BrasPress - DESABILITADO MCVN 07/2007 - HABILITADO EM 14/10/09 
		            
				cLin := "^XA" + ctrls
				cLin := cLin  + "^XB" + ctrls
				cLin := cLin  + "^LH10,0"  + ctrls
				cLin := cLin  + "^PRD" + ctrls
				cLin := cLin  + "^POI" + ctrls
				cLin := cLin  + "^LL784" + ctrls
				cLin := cLin  + "^COY" + ctrls

				//Imprime a mascara na etiqueta 
				cLin := cLin  + "^ILE:BRP1.GRF^FS" + ctrls             
				// Campos variaveis -------------^FS             
				cLin := cLin  + "^A0R,140,140^FO662,30^FR^CI0^FD"+PADR(nSgFilOrig,LEN(AllTrim(nSgFilOrig)))+"^FS" + ctrls          
				If LEN(AllTrim(nRotaEnt)) <=5    
        			cLin := cLin  + "^A0R,120,120^FO665,380^CI0^FD"+PADR(nRotaEnt,5)+"^FS" + ctrls      
				Else                                                                     
					cLin := cLin  + "^A0R,60,60^FO685,380^CI0^FD"+PADR(nRotaEnt,10)+"^FS" + ctrls      
				Endif                         
				cLin := cLin  + "^A0R,30,30^FO683,710^CI0^FD"+PADR(Alltrim(nClassif)+StrZero(nSequen,3),4)+"^FS" + ctrls   		
				cLin := cLin  + "^A0R,80,70^FO580,15^CI0^FD"+ PADR(ALLTRIM(RIGHT(QRY1->F2_DOC,6)),6)+"^FS" + ctrls   
				cLin := cLin  + "^A0R,80,58^FO580,525^CI0^FD"+PADR(nVolprt,4)+"/"+PADR(nVolTot,4)+"^FS" + ctrls   
				cLin := cLin  + "^A0R,30,26^FO530,6^CI0^FD"+If(cEmpAnt=="04",'HEALTH QUALITY IND. E COM. LTDA-ME','DIPROMED COMERCIO E IMPORTACAO LTDA')+"^FS" + ctrls   
				cLin := cLin  + "^A0R,30,30^FO537,601^FR^CI0^FDSAO^FS" + ctrls  
				IF LEN(AllTrim(QRY1->A1_NOME)) <= 40 
					cLin := cLin  + "^A0R,30,26^FO461,6^CI0^FD"+PADR(QRY1->A1_NOME,40)+"^FS" + ctrls   
				Else                                                                             
					cLin := cLin  + "^A0R,25,18^FO461,6^CI0^FD"+PADR(QRY1->A1_NOME,57)+"^FS" + ctrls   
				Endif
				IF LEN(AllTrim(QRY1->C5_MUNE)) <= 16
					cLin := cLin  + "^A0R,48,58^FO398,6^CI0^FD"+ PADR(QRY1->C5_MUNE,LEN(AllTrim(QRY1->C5_MUNE)))+"-"+PADR(QRY1->C5_ESTE,2) +"^FS" + ctrls   		
				Else                                                                            
					cLin := cLin  + "^A0R,30,26^FO398,6^CI0^FD"+ PADR(QRY1->C5_MUNE,LEN(AllTrim(QRY1->C5_MUNE)))+"-"+PADR(QRY1->C5_ESTE,2) +"^FS" + ctrls   		
				Endif
				cLin := cLin  + "^A0R,30,30^FO355,105^CI0^FD"+nCepEnt+"^FS" + ctrls   
				cLin := cLin  + "^A0R,20,25^FO110,610^CI0^FD"+ nDtAtual +"^FS" + ctrls   
		
				//O comando BY3 aumenta a densidade da barra mais fina p/ 3 pontos     
				cLin := cLin  + "^BY4^FO135,90^BCR,210,N,N,N^FN1^FS" + ctrls   
				cLin := cLin  + "^A0R,20,25^FO110,90^CI0^FN2^FS" + ctrls    
                                  
				//Codigo de barras 
				cLin := cLin  + "^FN1^FD>;"+'1'+CodCliBras + PADR(Right(nSerie,2),2) + PADR(ALLTRIM(RIGHT(QRY1->F2_DOC,6)),6) + PADR(nVolprt,4)+"^FS" + ctrls   
				cLin := cLin  + "^FN2^FD"  +'1'+CodCliBras + PADR(Right(nSerie,2),2) + PADR(ALLTRIM(RIGHT(QRY1->F2_DOC,6)),6) + PADR(nVolprt,4)+"^FS" + ctrls   
				cLin := cLin  + "^FO112,320^GB18,200,15^FS" + ctrls   
				//cLin := cLin  + "^A0R,18,22^FO110,360^CI0^FR^FDREIMPRESSAO^FS" + ctrls  
				If QRY1->F2_ETIBRAS > 0  
					cLin := cLin  + "^A0R,18,22^FO110,330^CI0^FR^FD"+AllTrim(PADR(QRY1->F2_ETIBRAS,2))+'™ REIMPRESSAO'+"^FS"+ ctrls
				Endif       
				cLin := cLin  + "^A0R,40,40^FO40,50^FR^CI0^FD"+PADR(QRY1->D2_PEDIDO,6) +'   '+ PADR(QRY1->F2_LOCEXP,3)+'  ' +PADR(QRY1->F2_CONFERI,3)+"^FS" + ctrls
				cLin := cLin  + "^XZ" + ctrls      								
			Endif

		ElseIf lNewEtiq                             
            /*
            CÛdigo EPL convertido para ZPL em 11/04/2017
			cLin   := "N" + ctrls
			//cLin   += "R3.5,3" + ctrls
			cLin   += "I8,A" + ctrls

			cLin   += "X25,5,4,800,267" + ctrls
			//cLin   += 'A60,720,3,5,3,3,N,'+'"'+PADR(QRY1->D2_PEDIDO,6)+'"'+ ctrls
			cLin   += 'A30,10,0,2,2,2,R,'  + '"' + "         HEALTH QUALITY         " + '"' + ctrls
			cLin   += 'A35,60,0,3,2,2,N,'  + '"' + "NF:"+RIGHT(QRY1->F2_DOC,6)+"/"+QRY1->F2_SERIE+" Vol:"+PADR(nVolprt,4)+"/"+PADR(nVolTot,4)+'"' + ctrls
			cLin   += 'A35,120,0,2,2,2,N,' + '"' + "CLIENTE:"+QRY1->A1_NREDUZ+ '"' + ctrls
			cLin   += 'A35,170,0,2,2,2,N,' + '"' + "TRANSP.:"+QRY1->F2_TRANSP+"-"+POSICIONE("SA4",1,xFilial("SA4")+QRY1->F2_TRANSP,"A4_NREDUZ")+'"' + ctrls
			cLin   += 'A35,220,0,2,2,2,N,' + '"' + "PEDIDO :"+QRY1->D2_PEDIDO+ '"' + ctrls

			cLin   += "P1"+ ctrls + ctrls
			*/  
			cLin   := "CT~~CD,~CC^~CT~"+ctrls
			cLin   += "^XA~TA000~JSN^LT0^MNW^MTD^PON^PMN^LH0,0^JMA^PR4,4^JUS^LRN^CI0^XZ"+ctrls
			cLin   += "^XA"+ctrls
			cLin   += "^MMT"+ctrls
			cLin   += "^PW799"+ctrls
			cLin   += "^LL0244"+ctrls
			cLin   += "^LS0"+ctrls
			cLin   += "^FT192,48^A0N,34,33^FH\^FDH E A L T H   Q U A L I T Y^FS"+ctrls
			cLin   += "^FT10,104^A0N,55,50^FH\^FDNF: "+RIGHT(QRY1->F2_DOC,6)+"/"+QRY1->F2_SERIE+"       Vol.: "+PADR(nVolprt,4)+"/"+PADR(nVolTot,4)+"^FS"+ctrls
			cLin   += "^FT10,141^A0N,34,33^FH\^FDCLIENTE: "+QRY1->A1_NREDUZ+"^FS"+ctrls
			cLin   += "^FT10,183^A0N,34,33^FH\^FDTRANSP.: "+QRY1->F2_TRANSP+"-"+POSICIONE("SA4",1,xFilial("SA4")+QRY1->F2_TRANSP,"A4_NREDUZ")+"^FS"+ctrls
			cLin   += "^FT10,225^A0N,34,33^FH\^FDPEDIDO: "+QRY1->D2_PEDIDO+"^FS"+ctrls
			cLin   += "^LRY^FO5,11^GB786,0,48^FS^LRN"+ctrls
			cLin   += "^PQ1,0,1,Y^XZ"+ctrls
		Else
		
			//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
			//≥Impressao em EPL - Impressora TLP2844≥
			//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
			If (QRY1->F2_TPFRETE == 'F' .AND. QRY1->F2_TRANSP <>  "000150") .Or. QRY1->F2_TRANSP $ '000235/000236/003025/000905/001935/002179/102000'    
				
				//Inicializando
				cLin   := "N" + ctrls
				cLin   := cLin + "R15,3" + ctrls
				cLin   := cLin + "I8,A" + ctrls
				
				//Box
				cLin   := cLin + "X5,2,4,788,765" + ctrls
				cLin   := cLin + "X133,2,4,243,765" + ctrls
				cLin   := cLin + "X133,2,4,243,270" + ctrls
				cLin   := cLin + "X301,270,4,373,765" + ctrls
				cLin   := cLin + "X370,270,4,479,765" + ctrls
				cLin   := cLin + "X400,2,4,479,272" + ctrls
				cLin   := cLin + "X725,2,4,788,765" + ctrls
				cLin   := cLin + "X725,2,4,788,400" + ctrls
				//Campos fixos
				cLin   := cLin + 'A141,759,3,2,1,1,R," NF: "' + ctrls
				cLin   := cLin + 'A139,264,3,2,1,1,R," Vol: "' + ctrls
				cLin   := cLin + 'A246,759,3,2,1,1,R," Rem: "' + ctrls
				cLin   := cLin + 'A307,759,3,2,1,1,R," Dest: "' + ctrls
				cLin   := cLin + 'A260,265,3,2,1,1,N,"Origem -"' + ctrls 
				cLin   := cLin + 'A408,266,3,2,1,1,R," FROTA: "' + ctrls
				cLin   := cLin + 'A260,160,3,4,1,1,N,"SAO"' + ctrls     
			
				cLin   := cLin + 'A173,720,3,5,1,1,N,'+ '"' +PADR(ALLTRIM(RIGHT(QRY1->F2_DOC,6)),6)+"/"+PADR(QRY1->F2_SERIE,3)+'"'  + ctrls
				cLin   := cLin + 'A173,262,3,3,3,2,N,'+ '"' +PADR(nVolprt,4)+"/"+PADR(nVolTot,4) +'"'  + ctrls
				cLin   := cLin + 'A266,755,3,2,2,1,N,'+If(cEmpAnt=="04",'"HEALTH QUALITY IND. E COM. LTDA-ME"','"DIPROMED COMERCIO E IMPORTACAO LTDA"')+ ctrls
			
				// Tratando nome do cliente
				IF LEN(AllTrim(QRY1->A1_NOME)) <= 40
					cLin   := cLin + "A333,755,3,2,2,1,N,"  +'"'+ PADR(QRY1->A1_NOME,40) +'"' + ctrls
					cLin   := cLin + "A500,750,3,3,2,1,N,"  +'"'+ PADR(QRY1->A1_NOME,40) +'"' + ctrls
				Else
					cLin   := cLin + "A333,755,3,1,2,1,N,"  +'"'+ PADR(QRY1->A1_NOME,47) +'"' + ctrls
					cLin   := cLin + "A500,750,3,2,2,1,N,"  +'"'+ PADR(QRY1->A1_NOME,47) +'"' + ctrls
				Endif
			
				// EndereÁo+transportadora 
				cLin   := cLin + 'A550,750,3,3,2,1,N,"Endereco:"' + ctrls	
				cLin   := cLin + "A590,750,3,2,2,1,N," +'"'+ PADR(QRY1->C5_ENDENT,60) +'"' + ctrls	
				cLin   := cLin + "A630,750,3,2,2,1,N," +'"'+ PADR(QRY1->C5_MUNE,LEN(AllTrim(QRY1->C5_MUNE)))+"-"+PADR(QRY1->C5_ESTE,2)+" - CEP: "+nCepEnt+'"' + ctrls			
				cLin   := cLin + "A670,750,3,2,2,1,N," +'"'+ PADR("Transp: " +QRY1->F2_TRANSP+"-"+Alltrim(Posicione("SA4",1,xFilial("SA4")+QRY1->F2_TRANSP,"A4_NOME" )),60) +'"' + ctrls			                                                             	
				cLin   := cLin + "A705,140,3,2,1,1,N," +'"'+ nDtAtual+'"'+ ctrls
				
				// VERIFICA SE … OU N√O REIMPRESS√O
				If QRY1->F2_ETIBRAS > 0
					cLin   := cLin + 'A705,370,3,2,1,1,N,'+'"'+AllTrim(PADR(QRY1->F2_ETIBRAS,2))+'™ REIMPRESSAO"'+ ctrls
				Endif
		
				cLin   := cLin + 'A731,760,3,2,1,1,R," Obs.: "'+ ctrls
				cLin   := cLin + 'A758,760,3,4,1,1,N,'+'" '+PADR(QRY1->D2_PEDIDO,6) +'   '+ PADR(QRY1->F2_LOCEXP,3)+'  ' +PADR(QRY1->F2_CONFERI,3)+'"'+ ctrls
				
				If QRY1->F2_TRANSP $ '000235'    
					cLin   := cLin + 'A738,370,3,4,2,2,N,"SEDEX"'+ ctrls
				ElseIf QRY1->F2_TRANSP $ '000236'                       
					cLin   := cLin + 'A738,370,3,4,2,2,N,"SEDEX 10"'+ ctrls                             
				ElseIf QRY1->F2_TRANSP $ '003025'   
			   		cLin   := cLin + 'A738,370,3,4,2,2,N,"UTILISSIMO"'+ ctrls   
				ElseIf QRY1->F2_TRANSP $ '000905'
					cLin   := cLin + 'A738,370,3,4,2,2,N,"JAMEF"'+ ctrls   
				ElseIf QRY1->F2_TRANSP $ '002179'
					cLin   := cLin + 'A738,370,3,4,2,2,N,"TERMACO"'+ ctrls   
				ElseIf QRY1->F2_TRANSP $ '001935'
					cLin   := cLin + 'A738,370,3,4,2,2,N,"BERTOLINI"'+ ctrls   
				ElseIf QRY1->F2_TRANSP $ '102000'
					cLin   := cLin + 'A738,370,3,4,2,2,N,"MANN"'+ ctrls   
				Else				
					cLin   := cLin + 'A738,370,3,4,2,2,N,"FOB"'+ ctrls
				Endif											
			
				cLin   := cLin + "LE9,410,124,352"+ ctrls
				cLin   := cLin + "LE244,6,54,266"+ ctrls
				cLin   := cLin + "LE299,6,54,266"+ ctrls
				cLin   := cLin + "LE354,6,52,266"+ ctrls
				cLin   := cLin + "LW1,680,1,1"+ ctrls
				cLin   := cLin + "P1"+ ctrls + ctrls
				
			ElseIf  QRY1->F2_TRANSP $ "000001/000111/000112/000133/100000"   										
					
				cLin   := "N" + ctrls
				cLin   := cLin + "R15,3" + ctrls
				cLin   := cLin + "I8,A" + ctrls

				cLin   := cLin + "X5,2,4,788,765" + ctrls
				cLin   := cLin + 'A60,720,3,5,3,3,N,'+'"'+PADR(QRY1->D2_PEDIDO,6)+'"'+ ctrls
				cLin   := cLin + 'A280,720,3,3,3,2,N,' + '"' + PADR("N.Fiscal/Serie: "+ALLTRIM(RIGHT(QRY1->F2_DOC,6))+"/"+QRY1->F2_SERIE,25)+'"'  + ctrls
				cLin   := cLin + 'A360,720,3,3,3,2,N,' + '"' +"Volume : "+PADR(nVolprt,4)+"/"+PADR(nVolTot,4) +'"'  + ctrls
				cLin   := cLin + 'A450,720,3,3,2,2,N,' + '"' + PADR("Separador:  "+QRY1->F2_SEPAROU,16)+'"'  + ctrls
				cLin   := cLin + 'A500,720,3,3,2,2,N,' + '"' + PADR("Conferente: "+QRY1->F2_CONFERI,16)+'"'  + ctrls
				cLin   := cLin + 'A550,720,3,3,2,2,N,' + '"' + PADR("Expedicao:  "+QRY1->F2_LOCEXP,16)+'"'  + ctrls

				cLin   := cLin + "P1"+ ctrls + ctrls
			
			ElseIf QRY1->F2_TRANSP == "000150" //BrasPress - DESABILITADO MCVN 07/2007 - HABILITADO EM 14/10/09 
		
				cLin   := "N" + ctrls
				cLin   := cLin + "R15,3" + ctrls
				cLin   := cLin + "I8,A" + ctrls
		
				cLin   := cLin + "X5,2,4,788,765" + ctrls
				cLin   := cLin + "X133,2,4,243,765" + ctrls
				cLin   := cLin + "X133,530,4,243,765" + ctrls
				cLin   := cLin + "X133,2,4,243,270" + ctrls
				cLin   := cLin + "X301,270,4,373,765" + ctrls
				cLin   := cLin + "X370,270,4,479,765" + ctrls
				cLin   := cLin + "X400,2,4,479,272" + ctrls
				cLin   := cLin + "X725,2,4,788,765" + ctrls
				cLin   := cLin + "X725,2,4,788,400" + ctrls
				cLin   := cLin + 'A141,759,3,2,1,1,R," NF: "' + ctrls
				cLin   := cLin + 'A139,264,3,2,1,1,R," Vol: "' + ctrls
				cLin   := cLin + 'A246,759,3,2,1,1,R," Rem: "' + ctrls
				cLin   := cLin + 'A307,759,3,2,1,1,R," Dest: "' + ctrls
				cLin   := cLin + 'A260,265,3,2,1,1,N,"Origem -"' + ctrls
				cLin   := cLin + 'A408,266,3,2,1,1,R," FROTA: "' + ctrls
				cLin   := cLin + 'A452,756,3,4,1,1,N,"CEP:"'+ ctrls				
				cLin   := cLin + 'A738,370,3,4,2,2,N,"BRASPRESS"'+ ctrls								
				cLin   := cLin + 'A20,745,3,5,2,2,N,'+'"'+PADR(nSgFilOrig,LEN(AllTrim(nSgFilOrig)))+'"'+ ctrls
			
				// Tratando Rota de entrega
				If Len(AllTrim(nRotaEnt)) <=5
					cLin   := cLin + 'A16,405,3,5,2,2,N,'+'"'+PADR(nRotaEnt,5)+'"'+ ctrls
				Else
					cLin   := cLin + 'A30,380,3,2,6,3,N,'+'"'+PADR(nRotaEnt,10)+'"'+ ctrls
				Endif
				cLin   := cLin + 'A102,060,3,2,2,1,N,'+ '"'+PADR(Alltrim(nClassif)+StrZero(nSequen,3),4)+'"'+ ctrls
				cLin   := cLin + 'A173,756,3,5,1,1,N,'+ '"' + PADR(ALLTRIM(RIGHT(QRY1->F2_DOC,6)),6)+'"'  + ctrls
				cLin   := cLin + 'A173,262,3,3,3,2,N,'+ '"' +PADR(nVolprt,4)+"/"+PADR(nVolTot,4) +'"'  + ctrls
				cLin   := cLin + 'A266,755,3,2,2,1,N,'+ If(cEmpAnt=="04",'"HEALTH QUALITY IND. E COM. LTDA-ME"','"DIPROMED COMERCIO E IMPORTACAO LTDA"') + ctrls
				cLin   := cLin + 'A260,160,3,4,1,1,N,"SAO"' + ctrls
			
				// Tratando nome do cliente
				If Len(AllTrim(QRY1->A1_NOME)) <= 40
					cLin   := cLin + "A333,755,3,2,2,1,N,"  +'"'+ PADR(QRY1->A1_NOME,40) +'"' + ctrls
				Else
					cLin   := cLin + "A333,755,3,1,2,1,N,"  +'"'+ PADR(QRY1->A1_NOME,47) +'"' + ctrls
				Endif
			
				// Tratando municipio do clinte
				If Len(AllTrim(QRY1->C5_MUNE)) <= 16
					cLin   := cLin + 'A385,755,3,3,2,2,N,' +'"'+ PADR(QRY1->C5_MUNE,LEN(AllTrim(QRY1->C5_MUNE)))+"-"+PADR(QRY1->C5_ESTE,2) +'"' + ctrls
				Else
					cLin   := cLin + 'A385,755,3,2,2,1,N,' +'"'+ PADR(QRY1->C5_MUNE,LEN(AllTrim(QRY1->C5_MUNE)))+"-"+PADR(QRY1->C5_ESTE,2) +'"' + ctrls
				Endif
			
				cLin   := cLin + 'A452,704,3,4,1,1,N,'+'"'+nCepEnt+'"'+ ctrls
				cLin   := cLin + 'B485,700,3,1C,4,6,210,N,' +'"'+'1'+CodCliBras + PADR(Right(nSerie,2),2) + PADR(ALLTRIM(RIGHT(QRY1->F2_DOC,6)),6) + PADR(nVolprt,4)+'"' + ctrls
				cLin   := cLin + 'A705,700,3,2,1,1,N,'      +'"'+'1'+CodCliBras + PADR(Right(nSerie,2),2) + PADR(ALLTRIM(RIGHT(QRY1->F2_DOC,6)),6) + PADR(nVolprt,4)+'"' + ctrls
				cLin   := cLin + 'A705,140,3,2,1,1,N,'+'"'+ nDtAtual+'"'+ ctrls
				
				// VERIFICA SE … OU N√O REIMPRESS√O
				If QRY1->F2_ETIBRAS > 0
					cLin   := cLin + 'A705,370,3,2,1,1,R,'+'"'+AllTrim(PADR(QRY1->F2_ETIBRAS,2))+'™ REIMPRESSAO"'+ ctrls
				Endif
		
				cLin   := cLin + 'A731,760,3,2,1,1,R," Obs.: "'+ ctrls
				cLin   := cLin + 'A758,760,3,4,1,1,N,'+'" '+PADR(QRY1->D2_PEDIDO,6) +'   '+ PADR(QRY1->F2_LOCEXP,3)+'  ' +PADR(QRY1->F2_CONFERI,3)+'"'+ ctrls
			
				cLin   := cLin + "LE9,410,124,352"+ ctrls
				cLin   := cLin + "LE244,6,58,266"+ ctrls
				cLin   := cLin + "LE299,6,54,266"+ ctrls
				cLin   := cLin + "LE354,6,52,266"+ ctrls
				cLin   := cLin + "LW1,680,1,1"+ ctrls
				cLin   := cLin + "P1"+ ctrls + ctrls
			Endif
		Endif	
		
		If fWrite(nHdl,cLin,Len(cLin)) != Len(cLin)
			If !MsgAlert("Ocorreu um erro na gravaáÑo do arquivo "+ALLTRIM(QRY1->F2_DOC)+".txt"+" Continua?","AtenáÑo!")
				Exit
			Endif
		Endif
		nVolume := nVolume + 1
		nNomeEtiq := (ALLTRIM(QRY1->F2_DOC) + If(lVolParcial,'_'+AllTrim(Str(nVolInit,4,0)),'')+".txt") 
		
	EndDo
	
	//GRAVANDO IMPRESS√O ETIQUETA NO KARDEX SZ9
	cPedido := QRY1->D2_PEDIDO
	If QRY1->F2_ETIBRAS > 0
		cTipoMovimento := AllTrim(PADR(QRY1->F2_ETIBRAS,2))+'™ REIMPRESSAO ETIQUETA '
	Else
		cTipoMovimento := "IMPRESSAO ETIQUETA"
	EndIf
	U_DiprKardex(cPedido,U_DipUsr(),cTipoMovimento,.T.,"31")
	
	
	//Executa funÁ„o para gravar quantidade de vezes que a etiqueta foi impressa
	QtdImpEtiq()
	
	
	fClose(nHdl)
	
	// Imprindo etiquetas
	Ferase( cLocalEtiq + nNomeEtiq )
	cpyS2t(cEtiqueta+nNomeEtiq,cLocalEtiq,.F.,)  // Copiando arquivo de etiqueta p/ estaÁ„o
	//WaitRun("print /D:" + cPorta +" "+ cLocalEtiq + nNomeEtiq)
	WinExec("print /D:" + cPorta +" "+ cLocalEtiq + nNomeEtiq,1)  //MCVN - 04/10/10
	
	QRY1->(DbSkip())
	
EndDO
        
DbSelectArea("QRY1")
QRY1->(DbCloseArea())

Return .T.
/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±≥FunáÖo    ≥ QtdImpEtiq()≥ Autor ≥ Maximo Canuto V.Neto ≥Data ≥09/01/07 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÖo ≥ Grava no SF2->F2_ETIBRAS,a quantidade de vezes que a       ≥±±
±±≥DescriáÖo ≥ etiqueta foi impressa                                      ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥ Uso      ≥              	                                          ≥±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Static Function QtdImpEtiq()
If SF2->(DbSeek(xFilial("SF2")+QRY1->F2_DOC+QRY1->F2_SERIE))
	RecLock("SF2",.F.)
	SF2->F2_ETIBRAS := SF2->F2_ETIBRAS + 1
	SF2->(MsUnlock())
Endif
Return
/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±≥FunáÖo    ≥ rotacep()≥ Autor ≥ Maximo Canuto V.Neto ≥ Data ≥ 09/01/07  ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÖo ≥ Busca Rota de Entrega e Sigla da Filial Origem no SZV      ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥ Uso      ≥              	                                          ≥±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
User Function rotacep(nCepCli,cTrpCli,cCidCli)
Local QRY2 := ""  
Local cFilImola := ""                           

QRY2 := "SELECT ZV_NUMROTA, ZV_SGFILIA, ZV_CLASSIF, ZV_SEQUEN"
QRY2 += " FROM " + RetSQLName("SZV")
QRY2 += " WHERE ZV_FILIAL = '"+xFilial("SZV")+"' " 
QRY2 += " AND ZV_TRANSP = '" + cTrpCli + "' "
If cTrpCli == '000150
	QRY2 += " AND ZV_CEPINI <= '" + nCepCli + "' "
	QRY2 += " AND ZV_CEPFIM >= '" + nCepCli + "' "
Else                                            
	QRY2 += " AND ((CASE WHEN (LEN(LTRIM(RTRIM(STR(ZV_CEPINI))))=8) THEN SUBSTRING(LTRIM(RTRIM(STR(ZV_CEPINI))),1,5) ELSE '0'+SUBSTRING(LTRIM(RTRIM(STR(ZV_CEPINI))),1,4) End ) = '" + nCepCli + "')"  + " OR (ZV_LOCALID ='" + cCidCli + "') "
Endif
QRY2 += " AND D_E_L_E_T_ = ' ' "
QRY2 += " ORDER BY ZV_ROTA"

QRY2 := ChangeQuery(QRY2)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,QRY2),"QRY2",.T.,.T.)

If !QRY2->(Eof())
	If cTrpCli <> "000113"
		nRotaEnt   := QRY2->ZV_NUMROTA
		nSgFilOrig := QRY2->ZV_SGFILIA   
		nClassif   := QRY2->ZV_CLASSIF
		nSequen    := QRY2->ZV_SEQUEN
	Else
		cFilImola := QRY2->ZV_SGFILIA
	Endif
EndIf

QRY2->(dbCloseArea())	      
	
If cTrpCli == "000113"
	Return(cFilImola)
EndIf 

Return
/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥ETIQEMB   ∫Autor  ≥Microsiga           ∫ Data ≥  07/05/12   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥  Atualiza o dicionario de dados                            ∫±±
±±∫          ≥                                                            ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ AP                                                         ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Static Function AjustaSX1(cPerg)
Local i,j

_sAlias := Alias()
dbSelectArea("SX1")
dbSetOrder(1)

cPerg := PADR(cPerg, Len(SX1->X1_GRUPO), " " ) // Incluido por Sandro em 17/11/09.

aRegs:={}

//------------ Grupo/Ordem/Pergunta/PERGING/PERGESP/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05/F3

AADD(aRegs,{cPerg,"01","Qual sÈrie NF      ?","","","mv_ch1","C",3,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","",''})
AADD(aRegs,{cPerg,"02","Nota fiscal de     ?","","","mv_ch2","C",6,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","",''})
AADD(aRegs,{cPerg,"03","Nota fiscal atÈ    ?","","","mv_ch3","C",6,0,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","",''})
AADD(aRegs,{cPerg,"04","Volume Inicial     ?","","","mv_ch4","N",4,0,0,"G","","MV_PAR04","","","","","","","","","","","","","",""})
AADD(aRegs,{cPerg,"05","Inf. tipo de etiqueta ","","","mv_ch5","N",1,0,0,"C","","mv_par05","1-Normal","","","","","2-Cod. Barras","","","","","","","",""})

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
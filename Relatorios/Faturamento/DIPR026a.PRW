/*====================================================================================\
|Programa  | DIPR026A      | Autor | Eriberto Elias             | Data | 29/05/2003   |
|=====================================================================================|
|Descri็ใo | Faturamento por cliente e produto mes a mes e total ano                  |
|          |                                                                          |
|          |                                                                          |
|=====================================================================================|
|Sintaxe   | DIPR026A                                                                  |
|=====================================================================================|
|Uso       | Especifico DIPROMED                                                      |
|=====================================================================================|
|........................................Hist๓rico....................................|
|Rafael    | DD/MM/AA - Descri็ใo                                                     |
|Eriberto  | DD/MM/AA - Descri็ใo                                                     |
|Eriberto  | 15/04/05 - Inclusao no arquivo dos campos A1_EST, A1_MUN, A1_SATIV1      |
|          |            Inclusao da pergunta para o setor                             |
|Maximo    | 11/04/07 - Inclusใo da media da quantidade e media do valor (MสS)        |
|Maximo    | 24/04/07 - Inclusใo do campo X5_DESCRI e separa็ใo do c๓digo e nome de   |
|          | de todos os vendedores e t้cnicos                                        |
|Maximo    | 24/05/07 - Inclusใo do parโmetro para filtrar por vendedor               |
|Maximo    | 15/08/07 - Inclusใo do CAMPO TECNICO ROCHE NO ARQUIVO                    |
|Daniel    | 10/10/07 - Inclusใo do filtro por grupo de clientes                      |
|          |          - Tratamento do Filtro de Vendedores no Relatorio               |
|Maximo    | 04/10/07 - Inclusใo do filtro por grupo de clientes                      |
|          |          - Tratamento do Filtro de Vendedores no Relatorio               |
|Maximo    | 09/08/08 - Inclusใo de op็ใo p/ nใo mostrar valores(Variแvel lNoShowVal) |
|Maximo    | 19/09/08 - Inclusใo de op็ใo p/ gerar arquivo de faturamento por t้cnico |
em DBF e  possibilita o envio por e-mail.                     |
|Maximo    | 29/09/09 - Tratamento para Empresa HQ/VendedorHQ                         |
|JBS       | 09/01/10 - Tratamento nas query para trabalhar de forma multipla de em-  |
|          |            presas.                                                       |
|JBS       | 09/01/10 - Tratamento nas query para trabalhar de forma multipla de em-  |
|          |            presas.                                                       |
|JBS       | 09/01/10 - Tratamento nas query para trabalhar de forma multipla de em-  |
|          |            presas.                                                       |
|Maximo    | 26/07/10 - Customizacao para filtrar pelos dois fornecedores HQ que sใo: |
|MCVN      |            (000851 e 051508) quando um deles for solicitado no MV_PAR09  |
|Maximo    | 02/03/11 - Inclusใo da pergunta CARTEIRA TODA e traramento para t้cnico  |
|D'Leme    | 23/05/11 - Altera็ใo para ganho de performance na obten็ใo do faturamento|
|Reginaldo | 05/11/12 - Inclusใo t้cnico convatec no relat๓rio.                       |
\====================================================================================*/

#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "AP5MAIL.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "FILEIO.CH"

*-------------------------------------------------*
User Function DIPR026A()
*-------------------------------------------------*
Local aObj:=Array(5)
Local alCheck:={.f.,.f.,.f.}
Local bOk:={|| nOpcao:=1,oDlg:End()}
Local oDlg
Local oBt1
Local oBt2
Local nOpcao      :=0
// Vแriแveis para gera็ใo de arquivo dos T้cnicos - MCVN 17/09/08
Local aObjTec:=Array(8) 
Local alCheckTec:={.f.,.f.,.f.,.f.}
Local bOk2:={|| nOpcao2:=1,oDlg2:End()}
Local oDlg2
Local oBt1_2
Local oBt2_2
Local nOpcao2  :=0
Local cArquivo := ""
// Fim variแveis T้cnicos
Local _xArea      := GetArea()
Local _xAreaSA1   := SA1->(GetArea())
Local _xAreaSB1   := SB1->(GetArea())
Local cUserAuth   := GETMV("MV_DIPR019")
Local cUserAut    := GetMV("MV_URELFAT") // MCVN - 04/05/09
Local bMes        := {|| If( cMes < '01' .or. cMes > '12',(Aviso('Aten็ใo','M๊s Invalido. Informe m๊s de 01 a 12.',{'Ok'}),.F.),.T.)}  // JBS 13/04/2010 - Valida o Mes informado

Private cAno      := Space(04)
Private cMes      := Space(02) // JBS 12/04/2010
Private cGrpCli   := CriaVar("A1_GRPVEN",.F.)
Private cCliDe    := Space(06)
Private cCliAte   := Space(06)
Private cForDe    := Space(06)
Private cForAte   := Space(06)
Private cProDe    := Space(06)
Private cProAte   := Space(06)
Private cVenDe    := Space(06)
Private cTecDe    := Space(06) // Arquivo T้cnicos em DBF - MCVN - 17/09/08
Private cTecAte   := Space(06) // Arquivo T้cnicos em DBF - MCVN - 17/09/08
Private cTec3M	:= Space(06) //Rafael Moraes Rosa - 15/03/2023

Private lCriaArq  := .f.
Private lNoShowVal:= .f. // Nใo mostra valores MCVN - 09/08/08
Private lTecnico  := .f. // Arquivo T้cnicos em DBF - MCVN - 17/09/08
Private lEnvMail  := .f. // Arquivo T้cnicos em DBF - MCVN - 17/09/08
Private lDevoluc  := .T. // Botใo de Op็ใo de Controle de devolu็๕es - JBS 27/04/2010
Private lCarteira := .F. // Determina se o relatorio eh por carteira ou por vendas realizadas  // JBS 19/07/2010
Private nSetor    := 3
Private nTecnico  := 1   // 1=KC, 2=Amcor, 3=3M, 4=Roche, 2=Convatec - Arquivo T้cnicos em DBF - MCVN - 17/09/08
Private cOper     := Space(120)
Private cTecnico  := ""
Private cTecFornec:= ""
Private cUserTec  := GetMV("MV_USERTEC")// MCVN - 04/05/09
Private cDipr026  := GetMV("MV_DIPR026")// MCVN - 04/05/09
Private cDipr026A := GetMV("MV_DIPR26A")// JBS - 08/07/2010
Private cVendInt  := GetMV("MV_DIPVINT")// MCVN - 06/05/09
Private cVendExt  := GetMV("MV_DIPVEXT")// MCVN - 06/05/09
Private cVendPub  := GetMV("MV_DIPVPUB")// MCVN - 30/06/11
Private cSHWCUST  := GetMV("MV_SHWCUST")// MCVN - 13/11/09
//Private cDiretorio := "\RELATO\JPEG\"
Private cDestino  := "C:\EXCELL-DBF\"
Private oDevoluc   // Botใo de Op็ใo de Controle de devolu็๕es - JBS 27/04/2010
Private oCarteira  // Objeto do check box que determina se o relatorio eh por carteira ou por vendas realizadas.// JBS 19/07/2010

Private _nAnoIni   := "" // JBS 12/04/2010
Private _nMesIni   := "" // JBS 12/04/2010
Private _nParIni   := "" // JBS 12/04/2010
Private _nParFim   := "" // JBS 12/04/2010
Private _nAnoFim   := "" // JBS 12/04/2010
Private _nMesFim   := "" // JBS 12/04/2010
Private _cFilSA3   := xFilial("SA3")  // MCVN 02/03/2011
Private nToQto     := 0
Private aQtdMes    := {}//Giovani Zago 10/10/11
Private _cPosto    := ""
Private _CodVen    := "" 
Private _cDipUsr   := U_DipUsr() 
Private cCodUser   := RetCodUsr()
Private _aCampos   := {}

U_USESU7(cCodUser,@_CodVen,@_cPosto)

//-------------------------------------------------------------------------------------------------------------------------------
// JBS 09/04/2010: Tratamento para montar a query quando for executado para Health Quality apenas, ou para o Grupo Dipromed.
//-------------------------------------------------------------------------------------------------------------------------------
// Leia com atencao porque dentro do If sao duas matrizes: 1a. Condicao retorna uma matriz com um elemento (Uma empresa).
//                                                         2a. Condicao retorna uma matriz com 2 elementos (Duas Empresas).
//-------------------------------------------------------------------------------------------------------------------------------
Private aEmpresa  := If("HEALTH" $ SM0->M0_NOMECOM,{{'010','01'}},{{'010','04'},{'010','01'}} ) // Empresa e filial para processar as querys

Private cPerg     := U_FPADR( "DIPR26XX","SX1","SX1->X1_GRUPO"," " ) //Criado por Sandro em 19/11/09.

If _cPosto <> "02" .Or. Upper(_cDipUsr) $ Upper(cUserAut)//RBorges 08/02/17
	// MCVN - 10/05/09
	If !(Upper(_cDipUsr) $ cUserAut .Or.;
		Upper(_cDipUsr) $ cVendInt .Or.;
		Upper(_cDipUsr) $ cVendExt .Or.;
		Upper(_cDipUsr) $ cVendPub .Or.;// MCVN - 30/06/11
		Upper(_cDipUsr) $ cUserTec .Or.;
		Upper(_cDipUsr) $ cDipr026)// MCVN - 07/05/09
		Alert(Upper(_cDipUsr)+", voc๊ nใo tem autoriza็ใo para utilizar esta rotina. Qualquer d๚vida falar com Departamento de T.I.!!!!","Aten็ใo")
		Return()
	Endif
EndIf


U_DIPPROC(ProcName(0),_cDipUsr) // JBS 05/10/2005 - Gravando o nome do Programa no SZU

tamanho    := "G"
limite	   := 220
titulo     := OemTOAnsi("Vendas por cliente/produto mes a mes com total do ano",72)
cDesc1     := (OemToAnsi("Este programa tem como objetivo emitir um relatขrio",72))
cDesc2     := (OemToAnsi("de Faturamento por cliente.",72))
cDesc3     := (OemToAnsi(" ",72))
aReturn    := {"Bco A4", 1,"Faturamento", 1, 2, 1,"",1}
nomeprog   := "DIPR026A"
nLastKey   := 0
lContinua  := .T.
lEnd       := .F.
li         := 67
wnrel      := "DIPR026A"
M_PAG      := 1
cString    := "SD2"
_cArqTrb   := ''

SX1->(DipPergDiverg(.t.)) // Verifica se existe o no SX1 o "DIPR42". Retorna os Valores ou cria

If !Pergunte(cPerg,.T.)
	Return(.t.)
EndIf

cMes		:= SubStr(MV_PAR01,01,02)
cAno		:= SubStr(MV_PAR01,03,04)
cVenDe		:= MV_PAR02
lCriaArq	:= MV_PAR03 == 1
nSetor		:= MV_PAR04
cForDe		:= MV_PAR05
cGrpCli 	:= MV_PAR06
lCarteira	:= MV_PAR07 == 1
cCliDe 		:= MV_PAR08
cCliAte		:= MV_PAR09
cProDe		:= MV_PAR10
cProAte		:= MV_PAR11
lNoShowVal	:= MV_PAR12 == 2
lCartToda	:= MV_PAR13 == 2
cTec3M		:= MV_PAR14 //Rafael Moraes Rosa - 15/03/2023

/*
If nSetor>0.and.empty(cOper)
alCheck[nSetor]:=.t.
EndIf

Define msDialog oDlg title OemToAnsi('Faturamento por cliente') From 0,0 TO 23,38
@ 002,002 to 170,149 pixel
@ 010,010 say 'Ano ' pixel
@ 010,089 say 'M๊s ' pixel  // JBS 12/04/2010
@ 022,010 say 'Grp. Cliente' pixel
@ 032,010 say 'Cliente de' pixel
@ 032,089 say 'At้' pixel
@ 042,010 say 'Fornecedor '  pixel
//@ 042,089 say 'At้' pixel
@ 052,010 say 'Produto de' pixel
@ 052,089 say 'At้' pixel
@ 062,010 say 'Vendedor' pixel
@ 132,010 say 'Operadores' pixel

@ 010,054 msget cAno     Size 030,08 pixel
@ 010,104 msget cMes     valid Eval(bMes) Size 030,08 pixel   // JBS 12/04/2010
@ 020,054 msget cGrpcli  F3 'ACY' Size 030,08 pixel
@ 030,054 msget cCliDe   F3 'SA1' Size 030,08 pixel When Empty(cGrpCli)
@ 030,104 msget cCliAte  F3 'SA1' Size 030,08 Pixel When Empty(cGrpCli)
@ 040,054 msget cForDe   F3 'SA2' Size 030,08 pixel
//@ 040,104 msget cForAte  F3 'SA2' Size 030,08 pixel
@ 050,054 msget cProDe   F3 'SB1' Size 030,08 pixel
@ 050,104 msget cProAte  F3 'SB1' Size 030,08 pixel
@ 060,054 msget cVenDe   F3 'SA3' Size 030,08 pixel

@ 080,010 checkbox oCriaArq  var lCriaArq    PROMPT 'Cria arquivo'     size 110,008
@ 080,089 checkbox oTecnico  var lTecnico    PROMPT 'T้cnicos'         size 050,008
@ 090,010 checkbox oShowVal  var lNoShowVal  PROMPT 'Nใo Mostra Valor' size 110,008
@ 090,089 checkbox oDevoluc  var lDevoluc    PROMPT 'Cons.Devol.Periodo' size 110,008
@ 100,089 checkbox oCarteira var lCarteira   PROMPT 'Por Carteira'       size 110,008
@ 100,010 checkbox aObj[1]   var alCheck[1]  PROMPT 'Apoio'       size 030,008 on change DP26SeleRel(1,aObj,alCheck)
@ 110,010 checkbox aObj[2]   var alCheck[2]  PROMPT 'Call Center' size 040,008 on change DP26SeleRel(2,aObj,alCheck)
@ 120,010 checkbox aObj[3]   var alCheck[3]  PROMPT 'Ambos'       size 030,008 on change DP26SeleRel(3,aObj,alCheck)
//@ 090,010 checkbox aObj[4]  var alCheck[4] PROMPT 'Licita็๕es'   size 030,008 on change DP26SeleRel(4,aObj,alCheck)

@ 140,010 msget aObj[5] var cOper valid DP26SeleRel(5,aObj,alCheck) Size 130,08 pixel

Define sbutton oBt1 from 155,079 type 1 action Iif(Eval(bMes),(nOpcao := 1, oDlg:End()),) enable of oDlg
Define sbutton oBt2 from 155,110 type 2 action (nOpcao := 0, oDlg:End()) enable of oDlg

Activate Dialog oDlg Centered

If nOpcao = 0
Return(.t.)
EndIf
*/
//----------------------------------------------------------------------------------------------------
// Determina os 12 meses que serใo apresentados  - JBS 12/04/2010
//----------------------------------------------------------------------------------------------------
_nMesFim := cMes
_nAnoFim := cAno

/*If (!EMPTY(ALLTRIM(DTOS(MV_PAR14)))  .AND. !empty(ALLTRIM(DTOS(MV_PAR15))) )

		_nMesIni := Val(Substr(dtos(MV_PAR14),5,2))
		_nAnoIni := Val(Substr(dtos(MV_PAR14),1,4))
		_nMesFim := Substr(dtos(MV_PAR15),5,2)
		_nAnoFim := Substr(dtos(MV_PAR15),1,4)

		if (DateDiffMonth(MV_PAR14,MV_PAR15)>12)
			Alert('Intervalo de datas invแlido')
			Return
		EndIF
else*/
	If Val(_nMesFim) == 12
		_nMesIni := 1
		_nAnoIni := Val(cAno)
	Else
		_nMesIni := Val(_nMesFim) + 1
		_nAnoIni := Val(_nAnoFim) - 1
	EndIf
//EndIF

_nParIni := AllTrim(Str(_nAnoIni))+AllTrim(StrZero(_nMesIni,2))
_nParFim := AllTrim(_nAnoFim)+AllTrim(_nMesFim)

If lTecnico // Arquivo T้cnicos em DBF - MCVN - 17/09/08
	
	// Limpa variแveis para criar arquivo e nใo mostra valores.
	lCriaArq   := .f.
	lNoShowVal := .f.
	
	
	Define msDialog oDlg2 title OemToAnsi('T้cnicos') From 0,0 TO 18,36
	@ 002,002 to 135,142 pixel
	@ 010,010 say 'T้cnico de' pixel
	@ 022,010 say 'At้' pixel
	@ 010,054 msget cTecDe   F3 'SA3' Size 030,08 pixel When lTecnico Valid !Empty(cTecDe)
	@ 020,054 msget cTecAte  F3 'SA3' Size 030,08 Pixel When lTecnico Valid !Empty(cTecAte)
	@ 050,010 checkbox aObjTec[1]  var alCheckTec[1]  PROMPT 'T้cnico KC'       	size 050,008 on change DP26SeleTec(1,aObjTec,alCheckTec)
	@ 060,010 checkbox aObjTec[2]  var alCheckTec[2]  PROMPT 'T้cnico AMCOR'    	size 050,008 on change DP26SeleTec(2,aObjTec,alCheckTec)
	@ 070,010 checkbox aObjTec[3]  var alCheckTec[3]  PROMPT 'T้cnico 3M'       	size 050,008 on change DP26SeleTec(3,aObjTec,alCheckTec)
	@ 080,010 checkbox aObjTec[4]  var alCheckTec[4]  PROMPT 'T้cnico Roche'    	size 050,008 on change DP26SeleTec(4,aObjTec,alCheckTec)
	@ 080,010 checkbox aObjTec[5]  var alCheckTec[5]  PROMPT 'T้cnico Convatec' 	size 050,008 on change DP26SeleTec(5,aObjTec,alCheckTec)
	@ 080,010 checkbox aObjTec[6]  var alCheckTec[6]  PROMPT 'T้cnico S.P.'     	size 050,008 on change DP26SeleTec(6,aObjTec,alCheckTec)
	@ 080,010 checkbox aObjTec[7]  var alCheckTec[7]  PROMPT 'T้cnico M.A.'     	size 050,008 on change DP26SeleTec(7,aObjTec,alCheckTec)
	@ 080,010 checkbox aObjTec[8]  var alCheckTec[8]  PROMPT 'T้cnico H.Q.'     	size 050,008 on change DP26SeleTec(8,aObjTec,alCheckTec)
	@ 100,010 checkbox oEnvmail    var lEnvMail       PROMPT 'Envia Email'			size 050,008
	Define sbutton oBt1_2 from 115,079 type 1 action (nOpcao2 := 1, oDlg2:End()) enable of oDlg2
	Define sbutton oBt2_2 from 115,110 type 2 action (nOpcao2 := 0, oDlg2:End()) enable of oDlg2
	
	Activate Dialog oDlg2 Centered
	
	If nOpcao2 = 0
		Return(.t.)
	EndIf
	
Endif


SX1->(DipPergDiverg(.f.))


If lTecnico  // Filtrando Tecnicos -> Arquivo T้cnicos em DBF - MCVN - 17/09/08
	If Upper(_cDipUsr) $ cUserAut
		QRY2 := " SELECT A3_COD, A3_TECNICO, A3_EMAIL, A3_NOME"
		QRY2 += " FROM " + RetSQLName("SA3")
		QRY2 += " WHERE A3_TIPO = 'E'"
		QRY2 += " AND A3_TECNICO <> '' "
		QRY2 += " AND A3_COD BETWEEN '" + cTecDe + "' AND '" + cTecAte + "'"
		QRY2 += " AND A3_EMAIL <> ''"
		QRY2 += " AND " + RetSQLName("SA3") + ".D_E_L_E_T_ = ''"
		QRY2 := ChangeQuery(QRY2)
		
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,QRY2),"QRY2",.F.,.T.)
		
		DbSelectArea("QRY2")
		DbGoTop()
		While QRY2->(!EOF())
			
			cTecnico  := QRY2->A3_COD
			nTecSA3   := Val(QRY2->A3_TECNICO)
		    cTecFornec:= DipRetTec(nTecnico)
			//cArquivo  := GetSrvProfString("STARTPATH","")+"Excell-DBF\"+_cDipUsr+"-DIPR026-"+cTecFornec+"-"+cTecnico+".dbf"
			
			cArquivo  := "\Excell-DBF\"+_cDipUsr+"-DIPR026-"+cTecFornec+"-"+cTecnico+".dbf" // MCVN - Ajusta local gera็ใo arquivo p๓s virada de versใo p 10 - 18/11/09
			
			If Val(QRY2->A3_TECNICO) = nTecnico .Or. Val(QRY2->A3_TECNICO)=5	// Se a op็ใo do fornecedor selecionado nos parโmetros estแ de acordo com o cadastro - MCVN 17/09/08
				Processa({|lEnd| RunProc()},"Totalizando por cliente/produto...Tecnico-> "+cTecnico)
				If lEnvMail
					DP26MailTec(QRY2->A3_COD,QRY2->A3_NOME,QRY2->A3_EMAIL,cArquivo)
				Endif
			Endif
			QRY2->(DbSkip())
		EndDo
		QRY2->(dbCloseArea())
	Else
		MsgBox(_cDipUsr+" voc๊ nใo estแ autorizada a gerar arquivo de faturamento dos t้cnicos !"," Falar com TI!","Error")
	Endif
Else
	wnrel := SetPrint(cString,wnrel,cPerg,Titulo,cDesc1,cDesc2,cDesc3,.f.,,.f.,tamanho,,.f.,,,,,)
	
	If nLastKey == 27
		Return
	Endif
	
	SetDefault(aReturn,cString)
	Processa({|lEnd| RunProc()},"Totalizando por cliente/produto...")
	RptStatus({|lEnd| RptDetail()},"Imprimindo faturamento por cliente/produto...")
Endif

Set device to Screen

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Se em disco, desvia para Spool                                            ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If aReturn[5] == 1    // Se Saida para disco, ativa SPOOL
	Set Printer TO
	Commit
	ourspool(wnrel)
Endif

RestArea(_xAreaSB1)
RestArea(_xAreaSA1)
RestArea(_xArea)

Return

//////////////////////////////////////////////////////////////////////
Static Function RunProc()
Local nRecCount:=200
Local _Media:= 0
Local _MediaC:= 0
Local nPar_Med:= 0
//Local cArqExcell:= GetSrvProfString("STARTPATH","")+"Excell-DBF\"+_cDipUsr+"-DIPR026-"+cTecFornec+"-"+cTecnico // Arquivo T้cnicos em DBF - MCVN - 17/09/08
Local cArqExcell:= "\Excell-DBF\"+_cDipUsr+"-DIPR026-"+cTecFornec+"-"+cTecnico // Arquivo T้cnicos em DBF - MCVN - 17/09/08   - // MCVN - Ajusta local gera็ใo arquivo p๓s virada de versใo p 10 - 18/11/09
Local cQuery := ""  // JBS 09/04/2010
Local cUniao := ""  // JBS 09/04/2010
Local cCodVen:= ""  // JBS 19/07/2010 - Tratamento para determinar se o vendedor vem SA1 ou SF2.
Local _x,nEmp,wi,nMes
Local nColuna
Private cTrimestre := DP26VerTri()

ProcRegua(600)
For _x := 1 to 200
	IncProc("Processando faturamento . . . ")
Next
//-------------------------------------------------------------------------------------------
// JBS 09/04/2010 - Montagem da Query, sao duas querys unidas por empresas.
// Empresa 010 unida a empresa 040.
// Esta primeira consulta os produtos faturados dentro de um periodo e atendendo
// Aos parametros informados pelo usuario.
// A array aEmpresa determina quais empresas/filiais podem ser processadas.
//-------------------------------------------------------------------------------------------
cUniao := ""
cQuery := ""

For nEmp := 1 to len(aEmpresa)
	
	/*If Select('SX2_2') > 0
		SX2_2->( DbCloseArea() )
	EndIf*/
	
	cQuery += cUniao + fQuery01(aEmpresa[nEmp][01],aEmpresa[nEmp][02],lTecnico)
	cUniao  := "  UNION  "
	
Next nEmp

//cQuery += ' ORDER BY D2_CLIENTE, D2_LOJA, D2_COD, left(D2_EMISSAO,6) '
cQuery += ' ORDER BY D2_CLIENTE, D2_LOJA, D2_COD '
cQuery := ChangeQuery(cQuery)
If Select("QRY1") > 0
	QRY1->( DbCloseArea() )
EndIf

memowrite('DIPR026A_SD2_'+SM0->M0_CODIGO+'0_'+SM0->M0_CODFIL+'.SQL',cQuery)
TcQuery cQuery NEW ALIAS "QRY1"

If lDevoluc
	ProcRegua(600)
	For _x := 1 to 400
		IncProc("Processando devolu็๕es . . . ")
	Next
	//--------------------------------------------------------------------------------------
	// JBS 13/04/2010 - Tratamento para para apurar devolu็๕es
	//--------------------------------------------------------------------------------------
	cUniao := ""
	cQuery := ""
	
	For nEmp := 1 to len(aEmpresa)
		
		/*If Select('SX2_2') > 0
			SX2_2->( DbCloseArea() )
		EndIf*/
		
		cQuery += cUniao + fQuery02(aEmpresa[nEmp][01],aEmpresa[nEmp][02])
		cUniao  := "  UNION  "
		
	Next nEmp
	cQuery += " ORDER BY D2_CLIENTE,D2_LOJA, D1_DTDIGIT "
	
	If Select("QRY3") > 0
		QRY3->( DbCloseArea() )
	EndIf
	
	memowrite('DIPR026A_SD1_'+SM0->M0_CODIGO+'0_'+SM0->M0_CODFIL+'.SQL',cQuery)
   //	TcQuery cQuery NEW ALIAS "QRY3" 
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),'QRY3',.T.,.F.)
		DbSelectArea("QRY3")
	    QRY3->(dbgotop())
	
	
EndIf

// cria arquivo com meses colunados
If lTecnico  //Arquivo T้cnicos em DBF - MCVN - 17/09/08
	_aCamposTEC := {}
	AAdd(_aCamposTEC , {"CLIENTE"   ,"C",TamSX3("D2_CLIENTE")[1] , TamSX3("D2_CLIENTE")[2]})
	AAdd(_aCamposTEC , {"LOJA"      ,"C",TamSX3("D2_LOJA")[1]    , TamSX3("D2_LOJA")[2]})
	AAdd(_aCamposTEC , {"NOME"      ,"C",TamSX3("A1_NOME")[1]    , TamSX3("A1_NOME")[2]})
	AAdd(_aCamposTEC , {"CIDADE"    ,"C",TamSX3("A1_MUN")[1]     , TamSX3("A1_MUN")[2]})
	AAdd(_aCamposTEC , {"UF"        ,"C",TamSX3("A1_EST")[1]     , TamSX3("A1_EST")[2]})
	AAdd(_aCamposTEC , {"SEGMENTO"  ,"C",TamSX3("A1_SATIV1")[1]  , TamSX3("A1_SATIV1")[2]})
	AAdd(_aCamposTEC , {"SEG_DESCR" ,"C",TamSX3("X5_DESCRI")[1]  , TamSX3("X5_DESCRI")[2]})
	//	AAdd(_aCamposTEC ,{"SEGMENTO2"    , "C", TamSX3("A1_SATIV1")[1]    ,TamSX3("A1_SATIV1")[2]}) //Giovani Zago 10/10/11
	//	AAdd(_aCamposTEC ,{"SEG_DESCR2"   , "C", TamSX3("X5_DESCRI")[1]    ,TamSX3("X5_DESCRI")[2]}) //Giovani Zago 10/10/11
	AAdd(_aCamposTEC , {"VENDEDOR"  ,"C",TamSX3("A3_COD")[1]     , TamSX3("A3_COD")[2]})
	AAdd(_aCamposTEC , {"NOME_VEND" ,"C",TamSX3("A3_NOME")[1]    , TamSX3("A3_NOME")[2]})
	AAdd(_aCamposTEC , {"TECNICO"   ,"C",TamSX3("A3_COD")[1]     , TamSX3("A3_COD")[2]})
	AAdd(_aCamposTEC , {"N_TECNICO" ,"C",TamSX3("A3_NOME")[1]    , TamSX3("A3_NOME")[2]})
	AAdd(_aCamposTEC , {"PRODUTO"   ,"C",TamSX3("D2_COD")[1]     , TamSX3("D2_COD")[2]})
	AAdd(_aCamposTEC , {"DESCRICAO" ,"C",TamSX3("B1_DESC")[1]    , TamSX3("B1_DESC")[2]})
	AAdd(_aCamposTEC , {"Q1TRIMESTR","N",TamSX3("D2_QUANT")[1]   , TamSX3("D2_QUANT")[2]})
	AAdd(_aCamposTEC , {"V1TRIMESTR","N",TamSX3("D2_TOTAL")[1]   , TamSX3("D2_TOTAL")[2]})
	AAdd(_aCamposTEC , {"Q2TRIMESTR","N",TamSX3("D2_QUANT")[1]   , TamSX3("D2_QUANT")[2]})
	AAdd(_aCamposTEC , {"V2TRIMESTR","N",TamSX3("D2_TOTAL")[1]   , TamSX3("D2_TOTAL")[2]})
	AAdd(_aCamposTEC , {"Q3TRIMESTR","N",TamSX3("D2_QUANT")[1]   , TamSX3("D2_QUANT")[2]})
	AAdd(_aCamposTEC , {"V3TRIMESTR","N",TamSX3("D2_TOTAL")[1]   , TamSX3("D2_TOTAL")[2]})
	AAdd(_aCamposTEC , {"Q4TRIMESTR","N",TamSX3("D2_QUANT")[1]   , TamSX3("D2_QUANT")[2]})
	AAdd(_aCamposTEC , {"V4TRIMESTR","N",TamSX3("D2_TOTAL")[1]   , TamSX3("D2_TOTAL")[2]})
	AAdd(_aCamposTEC , {"QTD_TOTAL" ,"N",TamSX3("D2_QUANT")[1]   , TamSX3("D2_QUANT")[2]})
	AAdd(_aCamposTEC , {"VAL_TOTAL" ,"N",TamSX3("D2_TOTAL")[1]   , TamSX3("D2_TOTAL")[2]})
	AAdd(_aCamposTEC ,{"SEGMENTO2"    , "C", TamSX3("A1_SATIV1")[1]    ,TamSX3("A1_SATIV1")[2]}) //Giovani Zago 10/10/11
	AAdd(_aCamposTEC ,{"SEG_DESCR2"   , "C", TamSX3("X5_DESCRI")[1]    ,TamSX3("X5_DESCRI")[2]}) //Giovani Zago 10/10/11
	AAdd(_aCamposTEC , {"NRED_VEND" ,"C",TamSX3("A3_NREDUZ")[1]    , TamSX3("A3_NREDUZ")[2]}) //RBORGES - 19/12/2013
Else
	
	_aCampos := {}
	_aTamSX3 := TamSX3("D2_CLIENTE")
	
	AAdd(_aCampos ,{"CLIENTE"     , "C", TamSX3("D2_CLIENTE")[1]   ,TamSX3("D2_CLIENTE")[2]})
	AAdd(_aCampos ,{"LOJA"        , "C", TamSX3("D2_LOJA")[1]      ,TamSX3("D2_LOJA")[2]})
	AAdd(_aCampos ,{"NOME"        , "C", TamSX3("A1_NOME")[1]      ,TamSX3("A1_NOME")[2]})
	AAdd(_aCampos ,{"CIDADE"      , "C", TamSX3("A1_MUN")[1]       ,TamSX3("A1_MUN")[2]})
	AAdd(_aCampos ,{"UF"          , "C", TamSX3("A1_EST")[1]       ,TamSX3("A1_EST")[2]})
	AAdd(_aCampos ,{"SEGMENTO"    , "C", TamSX3("A1_SATIV1")[1]    ,TamSX3("A1_SATIV1")[2]})
	AAdd(_aCampos ,{"SEG_DESCR"   , "C", TamSX3("X5_DESCRI")[1]    ,TamSX3("X5_DESCRI")[2]})
	//	AAdd(_aCampos ,{"SEGMENTO2"    , "C", TamSX3("A1_SATIV1")[1]    ,TamSX3("A1_SATIV1")[2]}) //Giovani Zago 10/10/11
	//	AAdd(_aCampos ,{"SEG_DESCR2"   , "C", TamSX3("X5_DESCRI")[1]    ,TamSX3("X5_DESCRI")[2]}) //Giovani Zago 10/10/11
	AAdd(_aCampos ,{"VENDEDOR"    , "C", TamSX3("A3_COD")[1]       ,TamSX3("A3_COD")[2]})
	AAdd(_aCampos ,{"NOME_VEND"   , "C", TamSX3("A3_NOME")[1]      ,TamSX3("A3_NOME")[2]})
	AAdd(_aCampos ,{"VENDKC"      , "C", TamSX3("A3_COD")[1]       ,TamSX3("A3_COD")[2]})
	AAdd(_aCampos ,{"N_VENDKC"    , "C", TamSX3("A3_NOME")[1]      ,TamSX3("A3_NOME")[2]})
	AAdd(_aCampos ,{"TEC_AMCOR"   , "C", TamSX3("A3_COD")[1]       ,TamSX3("A3_COD")[2]})
	AAdd(_aCampos ,{"NTEC_AMCOR"  , "C", TamSX3("A3_NOME")[1]      ,TamSX3("A3_NOME")[2]})
	AAdd(_aCampos ,{"TEC_3M"      , "C", TamSX3("A3_COD")[1]       ,TamSX3("A3_COD")[2]})
	AAdd(_aCampos ,{"N_TEC_3M"    , "C", TamSX3("A3_NOME")[1]      ,TamSX3("A3_NOME")[2]})
	AAdd(_aCampos ,{"TEC_ROCHE"   , "C", TamSX3("A3_COD") [1]      ,TamSX3("A3_COD")[2]})
	AAdd(_aCampos ,{"NTEC_ROCHE"  , "C", TamSX3("A3_NOME")[1]      ,TamSX3("A3_NOME")[2]})
	AAdd(_aCampos ,{"TECNICO"     , "C", TamSX3("A3_COD") [1]      ,TamSX3("A3_COD")[2]})
	AAdd(_aCampos ,{"NOME_TEC"    , "C", TamSX3("A3_NOME")[1]      ,TamSX3("A3_NOME")[2]})
	AAdd(_aCampos ,{"TEC_CONVAT"  , "C", TamSX3("A3_COD") [1]      ,TamSX3("A3_COD")[2]})
	AAdd(_aCampos ,{"NTEC_CONVA"  , "C", TamSX3("A3_NOME")[1]		,TamSX3("A3_NOME")[2]})
	AAdd(_aCampos ,{"PRODUTO"     , "C", TamSX3("D2_COD") [1]      ,TamSX3("D2_COD")[2]})
	AAdd(_aCampos ,{"DESCRICAO"   , "C", TamSX3("B1_DESC")[1]      ,TamSX3("B1_DESC")[2]})
	AAdd(_aCampos ,{"TEC_SP"	  , "C", TamSX3("A3_COD")[1]       ,TamSX3("A3_COD")[2]})
	AAdd(_aCampos ,{"NTEC_SP"	  , "C", TamSX3("A3_NOME")[1]      ,TamSX3("A3_NOME")[2]})
	AAdd(_aCampos ,{"TEC_MA"      , "C", TamSX3("A3_COD")[1]       ,TamSX3("A3_COD")[2]})
	AAdd(_aCampos ,{"NTEC_MA"     , "C", TamSX3("A3_NOME")[1]      ,TamSX3("A3_NOME")[2]})
	AAdd(_aCampos ,{"TEC_HQ"      , "C", TamSX3("A3_COD")[1]       ,TamSX3("A3_COD")[2]})
	AAdd(_aCampos ,{"NTEC_HQ"     , "C", TamSX3("A3_NOME")[1]      ,TamSX3("A3_NOME")[2]})
	//----------------------------------------------------------------------------------------------
	// JBS - 14/04/2010
	// Defini็ใo da extrutura dos mesess, sempre come็ando pelo primeiro mes do periodo
	//----------------------------------------------------------------------------------------------
	nNom_Cam  := _nMesIni
	_aTamSX3Q := TamSX3("D2_QUANT")  // Campos de Quantidades
	_aTamSX3V := TamSX3("D2_TOTAL")  // Campos de valores
	
	For wi := 1 to 12
		
		AAdd(_aCampos ,{"Q"+StrZero(nNom_Cam,2),"N",TamSX3("D2_QUANT")[1],TamSX3("D2_QUANT")[2]})
		If !lNoShowVal // Nใo mostra valores MCVN - 09/08/08
			AAdd(_aCampos ,{"V"+StrZero(nNom_Cam,2),"N",TamSX3("D2_TOTAL")[1],TamSX3("D2_TOTAL")[2]})
		EndIf
		
		If nNom_Cam = 12
			nNom_Cam := 1
		Else
			nNom_Cam++
		EndIf
		
	Next wi
	AAdd(_aCampos ,{"Q13","N",_aTamSX3Q[1],_aTamSX3Q[2]})
	If !lNoShowVal // Nใo mostra valores MCVN - 09/08/08
		AAdd(_aCampos ,{"V13","N",TamSX3("D2_TOTAL")[1],TamSX3("D2_TOTAL")[2]})
	EndIf
	
Endif
//---------------------------------------------------------------------------------------------------
// Mostra informa็๕es quando for gerado por Eriberto/Erich
//---------------------------------------------------------------------------------------------------
nNom_Cam := _nMesIni
//---------------------------------------------------------------------------------------------------
If !lNoShowVal .And. !lTecnico// Nใo mostra valores MCVN - 09/08/08
	For wi := 1 to 12
		_aTamSX3 := TamSX3("D2_TOTAL")
		AAdd(_aCampos ,{"M"+StrZero(nNom_Cam,2),"N",_aTamSX3[1],_aTamSX3[2]})
		If Upper(_cDipUsr) $ cSHWCUST// JBS 20/03/2006
			AAdd(_aCampos ,{"C"+StrZero(nNom_Cam,2),"N",_aTamSX3[1],_aTamSX3[2]}) // JBS 20/03/2006
			AAdd(_aCampos ,{"L"+StrZero(nNom_Cam,2),"N",_aTamSX3[1],_aTamSX3[2]}) // JBS 20/03/2006
		EndIf // JBS 20/03/2006
		If nNom_Cam = 12
			nNom_Cam := 1
		Else
			nNom_Cam++
		EndIf
	Next
Endif
//---------------------------------------------------------------------------------------------------
If !lNoShowVal .And. !lTecnico// Nใo mostra valores MCVN - 09/08/08
	_aTamSX3 := TamSX3("D2_TOTAL")
	AAdd(_aCampos ,{"TOTAL","N",_aTamSX3[1],_aTamSX3[2]})
	AAdd(_aCampos ,{"MEDIA","N",_aTamSX3[1],_aTamSX3[2]})
	If Upper(_cDipUsr) $ cSHWCUST// JBS 20/03/2006
		AAdd(_aCampos ,{"CUST_TOTAL","N",_aTamSX3[1],_aTamSX3[2]}) // JBS 20/03/2006
		AAdd(_aCampos ,{"MARG_TOTAL","N",_aTamSX3[1],_aTamSX3[2]}) // JBS 20/03/2006
		AAdd(_aCampos ,{"CUST_MEDIA","N",_aTamSX3[1],_aTamSX3[2]}) // JBS 20/03/2006
		AAdd(_aCampos ,{"MARG_MEDIA","N",_aTamSX3[1],_aTamSX3[2]}) // JBS 20/03/2006
	EndIf
Endif
//---------------------------------------------------------------------------------------------------
AAdd(_aCampos ,{"SEGMENTO2"    , "C", TamSX3("A1_SATIV1")[1]    ,TamSX3("A1_SATIV1")[2]}) //Giovani Zago 10/10/11
AAdd(_aCampos ,{"SEG_DESCR2"   , "C", TamSX3("X5_DESCRI")[1]    ,TamSX3("X5_DESCRI")[2]}) //Giovani Zago 10/10/11
AAdd(_aCampos ,{"NRED_VEND"   , "C", TamSX3("A3_NREDUZ")[1]    ,TamSX3("A3_NREDUZ")[2]}) //RBORGES - 19/12/2013

If lTecnico
	_cArqTrb := CriaTrab(_aCamposTEC,.T.)
Else
	_cArqTrb := CriaTrab(_aCampos,.T.)
Endif

DbUseArea(.T.,,_cArqTrb,"TRB",.F.,.F.)

_cChave  := 'CLIENTE + LOJA + VENDEDOR + PRODUTO' // JBS 19/07/2010 - Incluir o vendedor no indice
IndRegua("TRB",_cArqTrb,_cChave,,,"Criando Indice...(Cliente + Vendedor + Produto)")

dbSelectArea("QRY1")
QRY1->(dbGotop())

ProcRegua(nRecCount)

If lTecnico   // Arquivo T้cnicos em DBF - MCVN - 17/09/08
	
	Do While QRY1->(!Eof())
		
		IncProc(OemToAnsi("Cliente..: " + QRY1->D2_CLIENTE+'-'+QRY1->D2_LOJA))
		
		If nRecCount<1
			nRecCount:=200
			ProcRegua(nRecCount)
		EndIf
		
		nRecCount--
		
		dbSelectArea("SB1")
		dbSeek(xFilial('SB1')+TRB->PRODUTO)
		
		DbSelectArea("TRB")
		
		If !Empty(QRY1->F2_VEND2) .And. QRY1->D2_FORNEC = '000996' .And. lCarteira
			cVendedor := QRY1->F2_VEND2
		Else
			cVendedor := QRY1->VENDEDOR
		EndIf
	
		SA3->(dbSeek(xFilial('SA3')+cVendedor))	
	
		If !dbSeek(QRY1->D2_CLIENTE+QRY1->D2_LOJA+cVendedor+QRY1->D2_COD) // JBS 19/07/2010 - Inclui o vendedor na chava de busca
			
			RecLock("TRB",.T.)
			
			TRB->CLIENTE  	:= QRY1->D2_CLIENTE
			TRB->LOJA     	:= QRY1->D2_LOJA
			TRB->NOME     	:= QRY1->A1_NOME
			TRB->CIDADE   	:= QRY1->A1_MUN
			TRB->UF       	:= QRY1->A1_EST
			TRB->SEGMENTO 	:= QRY1->A1_SATIV1
			TRB->SEGMENTO2 	:= QRY1->A1_SATIV8
			TRB->SEG_DESCR 	:= QRY1->X5_DESCRI
			TRB->SEG_DESCR2	:= IF(!Empty(QRY1->A1_SATIV8),posicione("SX5",1,xFilial("SX5")+"T3"+ALLTRIM(QRY1->A1_SATIV8),"X5_DESCRI"),"")//Giovani Zago 10/10/11
			TRB->VENDEDOR 	:= cVendedor  // JBS 19/07/2010
			
			TRB->NOME_VEND 	:= SA3->A3_NOME
			TRB->NRED_VEND  := SA3->A3_NREDUZ //RBORGES - 19/12/2013
			
			If nTecnico == 1// T้cnico KC
				TRB->TECNICO  := QRY1->A1_TECNICO
				SA3->(dbSeek(xFilial('SA3')+QRY1->A1_TECNICO))
				TRB->N_TECNICO:= SA3->A3_NOME
			ElseIf nTecnico == 2 // T้cnico Amcor
				TRB->TECNICO  := QRY1->A1_TECN_A
				SA3->(dbSeek(xFilial('SA3')+QRY1->A1_TECN_A))
				TRB->N_TECNICO:=  SA3->A3_NOME
			ElseIf nTecnico == 3 // T้cnico 3M
				TRB->TECNICO  := QRY1->A1_TECN_3
				SA3->(dbSeek(xFilial('SA3')+QRY1->A1_TECN_3))
				TRB->N_TECNICO:= SA3->A3_NOME
			ElseIf nTecnico == 4	// T้cnico Roche
				TRB->TECNICO  := QRY1->A1_TECN_R
				SA3->(dbSeek(xFilial('SA3')+QRY1->A1_TECN_R))
				TRB->N_TECNICO :=  SA3->A3_NOME
			ElseIf nTecnico == 5	// T้cnico Convatec
				TRB->TECNICO  := QRY1->A1_TECN_C
				SA3->(dbSeek(xFilial('SA3')+QRY1->A1_TECN_C))
				TRB->N_TECNICO :=  SA3->A3_NOME
			ElseIf nTecnico == 6	// T้cnico SP
				TRB->TECNICO  := QRY1->A1_XTEC_SP
				SA3->(dbSeek(xFilial('SA3')+QRY1->A1_XTEC_SP))
				TRB->N_TECNICO :=  SA3->A3_NOME
			ElseIf nTecnico == 7	// T้cnico MA
				TRB->TECNICO  := QRY1->A1_XTEC_MA
				SA3->(dbSeek(xFilial('SA3')+QRY1->A1_XTEC_MA))
				TRB->N_TECNICO :=  SA3->A3_NOME
			Else	// T้cnico HQ
				TRB->TECNICO  := QRY1->A1_XTEC_HQ
				SA3->(dbSeek(xFilial('SA3')+QRY1->A1_XTEC_HQ))
				TRB->N_TECNICO :=  SA3->A3_NOME																
			Endif
			
			TRB->PRODUTO  := QRY1->D2_COD
			TRB->DESCRICAO:= QRY1->B1_DESC
			
			TRB->Q1TRIMESTR := QRY1->QTD_1TRI
			TRB->Q2TRIMESTR := QRY1->QTD_2TRI
			TRB->Q3TRIMESTR := QRY1->QTD_3TRI
			TRB->Q4TRIMESTR := QRY1->QTD_4TRI
			
			TRB->V1TRIMESTR := QRY->TOT_1TRI
			TRB->V2TRIMESTR := QRY->TOT_2TRI
			TRB->V3TRIMESTR := QRY->TOT_3TRI
			TRB->V4TRIMESTR := QRY->TOT_4TRI
			TRB->QTD_TOTAL := TRB->QTD_TOTAL + QRY1->D2_QUANT
			TRB->VAL_TOTAL := TRB->VAL_TOTAL + QRY1->D2_TOTAL
			
		Else
			
			RecLock("TRB",.F.)
			
			TRB->Q1TRIMESTR += QRY1->QTD_1TRI
			TRB->Q2TRIMESTR += QRY1->QTD_2TRI
			TRB->Q3TRIMESTR += QRY1->QTD_3TRI
			TRB->Q4TRIMESTR += QRY1->QTD_4TRI
			
			TRB->V1TRIMESTR += QRY->TOT_1TRI
			TRB->V2TRIMESTR += QRY->TOT_2TRI
			TRB->V3TRIMESTR += QRY->TOT_3TRI
			TRB->V4TRIMESTR += QRY->TOT_4TRI
			
			TRB->QTD_TOTAL := TRB->QTD_TOTAL + QRY1->D2_QUANT
			TRB->VAL_TOTAL := TRB->VAL_TOTAL + QRY1->D2_TOTAL
			
			
		Endif
		TRB->(MsUnLock())
		
		dbSelectArea("QRY1")
		QRY1->(dbSkip())
		
	EndDo
	
Else
	Do While QRY1->(!Eof())
		
		IncProc(OemToAnsi("Cliente..: " + QRY1->D2_CLIENTE + '-' + QRY1->D2_LOJA))
		
		If nRecCount<1
			nRecCount:=200
			ProcRegua(nRecCount)
		EndIf
		
		nRecCount--
		
		dbSelectArea("SB1")
		dbSeek(xFilial('SB1')+TRB->PRODUTO)
				
		If !Empty(QRY1->F2_VEND2) .And. QRY1->D2_FORNEC = '000996'  .And. lCarteira
			cVendedor := QRY1->F2_VEND2
		Else
			cVendedor := QRY1->VENDEDOR
		EndIf
		
		SA3->(dbSeek(xFilial('SA3')+cVendedor))	
		
		DbSelectArea("TRB")
		If !dbSeek(QRY1->D2_CLIENTE+QRY1->D2_LOJA+cVendedor+QRY1->D2_COD) // JBS 19/07/2010  incluido o vendedor na chave
			
			RecLock("TRB",.T.)
			
			TRB->CLIENTE  	:= QRY1->D2_CLIENTE
			TRB->LOJA     	:= QRY1->D2_LOJA
			TRB->VENDEDOR 	:= cVendedor
			TRB->PRODUTO  	:= QRY1->D2_COD
			TRB->NOME     	:= QRY1->A1_NOME
			TRB->CIDADE   	:= QRY1->A1_MUN
			TRB->UF       	:= QRY1->A1_EST
			TRB->SEGMENTO 	:= QRY1->A1_SATIV1
			TRB->SEGMENTO2 	:= QRY1->A1_SATIV8//Giovani Zago 06/10/11
			TRB->SEG_DESCR 	:= QRY1->X5_DESCRI
			TRB->SEG_DESCR2	:= IF(!Empty(QRY1->A1_SATIV8),posicione("SX5",1,xFilial("SX5")+"T3"+ALLTRIM(QRY1->A1_SATIV8),"X5_DESCRI"),"")//Giovani Zago 10/10/11
			TRB->NOME_VEND 	:= SA3->A3_NOME
			TRB->NRED_VEND  := SA3->A3_NREDUZ //RBORGES - 19/12/2013
			TRB->VENDKC   	:= QRY1->A1_VENDKC
			SA3->(dbSeek(xFilial('SA3')+QRY1->A1_VENDKC))
			TRB->N_VENDKC := SA3->A3_NOME
			
			TRB->TECNICO 	:= QRY1->A1_TECNICO
			SA3->(dbSeek(xFilial('SA3')+QRY1->A1_TECNICO))
			TRB->NOME_TEC    := SA3->A3_NOME
			
			TRB->TEC_3M  	:= QRY1->A1_TECN_3
			SA3->(dbSeek(xFilial('SA3')+QRY1->A1_TECN_3))
			TRB->N_TEC_3M := SA3->A3_NOME
			
			TRB->TEC_AMCOR  := QRY1->A1_TECN_A
			SA3->(dbSeek(xFilial('SA3')+QRY1->A1_TECN_A))
			TRB->NTEC_AMCOR :=  SA3->A3_NOME
			
			TRB->TEC_ROCHE  := QRY1->A1_TECN_R
			SA3->(dbSeek(xFilial('SA3')+QRY1->A1_TECN_R))
			TRB->NTEC_ROCHE :=  SA3->A3_NOME
			  
			TRB->TEC_CONVAT:= QRY1->A1_TECN_C
			SA3->(dbSeek(xFilial('SA3')+QRY1->A1_TECN_c))
			TRB->NTEC_CONVA :=  SA3->A3_NOME
			
			TRB->TEC_SP  := QRY1->A1_XTEC_SP
			SA3->(dbSeek(xFilial('SA3')+QRY1->A1_XTEC_SP))
			TRB->NTEC_SP :=  SA3->A3_NOME
			
			TRB->TEC_MA  := QRY1->A1_XTEC_MA
			SA3->(dbSeek(xFilial('SA3')+QRY1->A1_XTEC_MA))
			TRB->NTEC_MA :=  SA3->A3_NOME
			
			TRB->TEC_HQ  := QRY1->A1_XTEC_HQ
			SA3->(dbSeek(xFilial('SA3')+QRY1->A1_XTEC_HQ))
			TRB->NTEC_HQ :=  SA3->A3_NOME

			TRB->DESCRICAO:= QRY1->B1_DESC
			
			TRB->Q01 := QRY1->QTD_01
			TRB->Q02 := QRY1->QTD_02
			TRB->Q03 := QRY1->QTD_03
			TRB->Q04 := QRY1->QTD_04
			TRB->Q05 := QRY1->QTD_05
			TRB->Q06 := QRY1->QTD_06
			TRB->Q07 := QRY1->QTD_07
			TRB->Q08 := QRY1->QTD_08
			TRB->Q09 := QRY1->QTD_09
			TRB->Q10 := QRY1->QTD_10
			TRB->Q11 := QRY1->QTD_11
			TRB->Q12 := QRY1->QTD_12
			If !lNoShowVal
				TRB->V01 := QRY1->TOT_01
				TRB->V02 := QRY1->TOT_02
				TRB->V03 := QRY1->TOT_03
				TRB->V04 := QRY1->TOT_04
				TRB->V05 := QRY1->TOT_05
				TRB->V06 := QRY1->TOT_06
				TRB->V07 := QRY1->TOT_07
				TRB->V08 := QRY1->TOT_08
				TRB->V09 := QRY1->TOT_09
				TRB->V10 := QRY1->TOT_10
				TRB->V11 := QRY1->TOT_11
				TRB->V12 := QRY1->TOT_12
				
				TRB->M01 := QRY1->TOT_01
				TRB->M02 := QRY1->TOT_02
				TRB->M03 := QRY1->TOT_03
				TRB->M04 := QRY1->TOT_04
				TRB->M05 := QRY1->TOT_05
				TRB->M06 := QRY1->TOT_06
				TRB->M07 := QRY1->TOT_07
				TRB->M08 := QRY1->TOT_08
				TRB->M09 := QRY1->TOT_09
				TRB->M10 := QRY1->TOT_10
				TRB->M11 := QRY1->TOT_11
				TRB->M12 := QRY1->TOT_12
				
				If Upper(_cDipUsr) $ cSHWCUST     // JBS 20/03/2006
					TRB->C01 := QRY1->CST_01
					TRB->C02 := QRY1->CST_02
					TRB->C03 := QRY1->CST_03
					TRB->C04 := QRY1->CST_04
					TRB->C05 := QRY1->CST_05
					TRB->C06 := QRY1->CST_06
					TRB->C07 := QRY1->CST_07
					TRB->C08 := QRY1->CST_08
					TRB->C09 := QRY1->CST_09
					TRB->C10 := QRY1->CST_10
					TRB->C11 := QRY1->CST_11
					TRB->C12 := QRY1->CST_12
				EndIf
			EndIf
			
			TRB->Q13 := TRB->Q13 + QRY1->D2_QUANT
			If !lNoShowVal
				TRB->V13 := TRB->V13 + QRY1->D2_TOTAL
				TRB->TOTAL := TRB->TOTAL + QRY1->D2_TOTAL
				
				If Upper(_cDipUsr) $ cSHWCUST     // JBS 20/03/2006
					TRB->CUST_TOTAL := TRB->CUST_TOTAL + (QRY1->D2_CUSDIP)// JBS 20/03/2006
				EndIf
			EndIf
			
			
		Else
			RecLock("TRB",.F.)
			TRB->Q01 += QRY1->QTD_01
			TRB->Q02 += QRY1->QTD_02
			TRB->Q03 += QRY1->QTD_03
			TRB->Q04 += QRY1->QTD_04
			TRB->Q05 += QRY1->QTD_05
			TRB->Q06 += QRY1->QTD_06
			TRB->Q07 += QRY1->QTD_07
			TRB->Q08 += QRY1->QTD_08
			TRB->Q09 += QRY1->QTD_09
			TRB->Q10 += QRY1->QTD_10
			TRB->Q11 += QRY1->QTD_11
			TRB->Q12 += QRY1->QTD_12
			If !lNoShowVal
				TRB->V01 += QRY1->TOT_01
				TRB->V02 += QRY1->TOT_02
				TRB->V03 += QRY1->TOT_03
				TRB->V04 += QRY1->TOT_04
				TRB->V05 += QRY1->TOT_05
				TRB->V06 += QRY1->TOT_06
				TRB->V07 += QRY1->TOT_07
				TRB->V08 += QRY1->TOT_08
				TRB->V09 += QRY1->TOT_09
				TRB->V10 += QRY1->TOT_10
				TRB->V11 += QRY1->TOT_11
				TRB->V12 += QRY1->TOT_12
				
				TRB->M01 += QRY1->TOT_01
				TRB->M02 += QRY1->TOT_02
				TRB->M03 += QRY1->TOT_03
				TRB->M04 += QRY1->TOT_04
				TRB->M05 += QRY1->TOT_05
				TRB->M06 += QRY1->TOT_06
				TRB->M07 += QRY1->TOT_07
				TRB->M08 += QRY1->TOT_08
				TRB->M09 += QRY1->TOT_09
				TRB->M10 += QRY1->TOT_10
				TRB->M11 += QRY1->TOT_11
				TRB->M12 += QRY1->TOT_12
				
				If Upper(_cDipUsr) $ cSHWCUST     // JBS 20/03/2006
					TRB->C01 += QRY1->CST_01
					TRB->C02 += QRY1->CST_02
					TRB->C03 += QRY1->CST_03
					TRB->C04 += QRY1->CST_04
					TRB->C05 += QRY1->CST_05
					TRB->C06 += QRY1->CST_06
					TRB->C07 += QRY1->CST_07
					TRB->C08 += QRY1->CST_08
					TRB->C09 += QRY1->CST_09
					TRB->C10 += QRY1->CST_10
					TRB->C11 += QRY1->CST_11
					TRB->C12 += QRY1->CST_12
				EndIf
			EndIf
			
			TRB->Q13 := TRB->Q13 + QRY1->D2_QUANT
			If !lNoShowVal
				TRB->V13 := TRB->V13 + QRY1->D2_TOTAL
				TRB->TOTAL := TRB->TOTAL + QRY1->D2_TOTAL
				
				If Upper(_cDipUsr) $ cSHWCUST     // JBS 20/03/2006
					TRB->CUST_TOTAL := TRB->CUST_TOTAL + (QRY1->D2_CUSDIP)// JBS 20/03/2006
				EndIf
			EndIf
			
		Endif
		
		TRB->(MsUnLock())
		
		dbSelectArea("QRY1")
		QRY1->(dbSkip())
		
	EndDo
Endif


//-------------------------------------------------------------------------------------------------------------
// JBS 13/04/2010 - Desenvolvido todo o tratamento abaixo para considerar as devolu็๕es
//                  ocorridas dentro do periodo do relatorio. Este relatorio nใo tratava
//                  as devolu็๕es.
//-------------------------------------------------------------------------------------------------------------
If lDevoluc
	If lTecnico   // Arquivo T้cnicos em DBF - MCVN - 17/09/08
		
		Do While QRY3->(!Eof())
			
			IncProc(OemToAnsi("Cliente..: " + QRY3->D2_CLIENTE + '-' + QRY3->D2_LOJA ))
			
			If nRecCount<1
				nRecCount:=200
				ProcRegua(nRecCount)
			EndIf
			
			nRecCount--
			
			If !Empty(QRY3->F2_VEND2) .And. QRY3->D2_FORNEC = '000996'   .And. lCarteira
				cVendedor := QRY3->F2_VEND2
			Else
				cVendedor := QRY3->VENDEDOR
			EndIf
			
			SA3->(dbSeek(xFilial('SA3')+cVendedor))	
	
			dbSelectArea("SB1")
			dbSeek(xFilial('SB1')+TRB->PRODUTO)
			
			DbSelectArea("TRB")               
			
			If !dbSeek(QRY3->D2_CLIENTE+QRY3->D2_LOJA+cVendedor+QRY3->D2_COD) // JBS 19/07/2010 Incluido o vendedor na chave
				
				RecLock("TRB",.T.)
				
				TRB->CLIENTE  	:= QRY3->D2_CLIENTE
				TRB->LOJA     	:= QRY3->D2_LOJA
				TRB->NOME     	:= QRY3->A1_NOME
				TRB->CIDADE   	:= QRY3->A1_MUN
				TRB->UF       	:= QRY3->A1_EST
				TRB->SEGMENTO 	:= QRY3->A1_SATIV1
				TRB->SEGMENTO2 	:= QRY3->A1_SATIV8//Giovani Zago 06/10/11
				TRB->SEG_DESCR 	:= QRY3->X5_DESCRI
				TRB->SEG_DESCR2	:= IF(!Empty(QRY3->A1_SATIV8),posicione("SX5",1,xFilial("SX5")+"T3"+ALLTRIM(QRY3->A1_SATIV8),"X5_DESCRI"),"")//Giovani Zago 10/10/11
				TRB->VENDEDOR 	:= cVendedor   // JBS 19/07/2010
				TRB->NOME_VEND 	:= SA3->A3_NOME 
				TRB->NRED_VEND  := SA3->A3_NREDUZ //RBORGES	- 19/12/2013
				
				
				If nTecnico == 1// T้cnico KC
					TRB->TECNICO  := QRY3->A1_TECNICO
					SA3->(dbSeek(xFilial('SA3')+QRY3->A1_TECNICO))
					TRB->N_TECNICO:= SA3->A3_NOME
				ElseIf nTecnico == 2 // T้cnico Amcor
					TRB->TECNICO  := QRY3->A1_TECN_A
					SA3->(dbSeek(xFilial('SA3')+QRY3->A1_TECN_A))
					TRB->N_TECNICO:=  SA3->A3_NOME
				ElseIf nTecnico == 3 // T้cnico 3M
					TRB->TECNICO  := QRY3->A1_TECN_3
					SA3->(dbSeek(xFilial('SA3')+QRY3->A1_TECN_3))
					TRB->N_TECNICO:= SA3->A3_NOME
				ElseIf nTecnico == 4	// T้cnico Roche
					TRB->TECNICO  := QRY3->A1_TECN_R
					SA3->(dbSeek(xFilial('SA3')+QRY3->A1_TECN_R))
					TRB->N_TECNICO :=  SA3->A3_NOME
				ElseIf nTecnico == 5	// T้cnico Convatec
					TRB->TECNICO  := QRY3->A1_TECN_C
					SA3->(dbSeek(xFilial('SA3')+QRY3->A1_TECN_C))
					TRB->N_TECNICO :=  SA3->A3_NOME
				ElseIf nTecnico == 6	// T้cnico SP
					TRB->TECNICO  := QRY3->A1_XTEC_SP
					SA3->(dbSeek(xFilial('SA3')+QRY3->A1_XTEC_SP))
					TRB->N_TECNICO :=  SA3->A3_NOME
				ElseIf nTecnico == 7	// T้cnico MA
					TRB->TECNICO  := QRY3->A1_XTEC_MA
					SA3->(dbSeek(xFilial('SA3')+QRY3->A1_XTEC_MA))
					TRB->N_TECNICO :=  SA3->A3_NOME
				Else	// T้cnico HQ
					TRB->TECNICO  := QRY3->A1_XTEC_HQ
					SA3->(dbSeek(xFilial('SA3')+QRY3->A1_XTEC_HQ))
					TRB->N_TECNICO :=  SA3->A3_NOME																
				Endif
	
				
				TRB->PRODUTO  := QRY3->D2_COD
				TRB->DESCRICAO:= QRY3->B1_DESC
				_triQ := 'TRB->Q'+Iif(SubStr(QRY3->D1_DTDIGIT,5,2) $ ("01/02/03"),"1TRIMESTR",;
				Iif(SubStr(QRY3->D1_DTDIGIT,5,2) $ ("04/05/06"),"2TRIMESTR",;
				Iif(SubStr(QRY3->D1_DTDIGIT,5,2) $ ("07/08/09"),"3TRIMESTR","4TRIMESTR")))
				
				_triV := 'TRB->V'+If(SubStr(QRY3->D1_DTDIGIT,5,2) $ ("01/02/03"),"1TRIMESTR",;
				Iif(SubStr(QRY3->D1_DTDIGIT,5,2) $ ("04/05/06"),"2TRIMESTR",;
				Iif(SubStr(QRY3->D1_DTDIGIT,5,2) $ ("07/08/09"),"3TRIMESTR","4TRIMESTR")))
				
				&_triQ   := &_triQ - QRY3->D2_QUANT
				&_triV   := &_triV - QRY3->D2_TOTAL
				
				TRB->QTD_TOTAL := TRB->QTD_TOTAL - QRY3->D2_QUANT
				TRB->VAL_TOTAL := TRB->VAL_TOTAL - QRY3->D2_TOTAL
				
			Else
				
				RecLock("TRB",.F.)
				_triQ := 'TRB->Q'+If(SubStr(QRY3->D1_DTDIGIT,5,2) $ ("01/02/03"),"1TRIMESTR",;
				Iif(SubStr(QRY3->D1_DTDIGIT,5,2) $ ("04/05/06"),"2TRIMESTR",;
				Iif(SubStr(QRY3->D1_DTDIGIT,5,2) $ ("07/08/09"),"3TRIMESTR","4TRIMESTR")))
				
				_triV := 'TRB->V'+If(SubStr(QRY3->D1_DTDIGIT,5,2) $ ("01/02/03"),"1TRIMESTR",;
				Iif(SubStr(QRY3->D1_DTDIGIT,5,2) $ ("04/05/06"),"2TRIMESTR",;
				Iif(SubStr(QRY3->D1_DTDIGIT,5,2) $ ("07/08/09"),"3TRIMESTR","4TRIMESTR")))
				
				
				&_triQ   := &_triQ - QRY3->D2_QUANT
				&_triV   := &_triV - QRY3->D2_TOTAL
				
				TRB->QTD_TOTAL := TRB->QTD_TOTAL - QRY3->D2_QUANT
				TRB->VAL_TOTAL := TRB->VAL_TOTAL - QRY3->D2_TOTAL
				
			Endif
			TRB->(MsUnLock())
			
			dbSelectArea("QRY3")
			QRY3->(dbSkip())
			
		EndDo
		
	Else
		
		Do While QRY3->(!Eof())
			
			IncProc(OemToAnsi("Cliente..: " + QRY3->D2_CLIENTE + '-' + QRY3->D2_LOJA  ))
			//IncProc(OemToAnsi("Cliente..: " + QRY3->D2_CLIENTE+'-'+QRY3->D2_LOJA))
			If nRecCount<1
				nRecCount:=200
				ProcRegua(nRecCount)
			EndIf
			nRecCount--
			dbSelectArea("SB1")
			dbSeek(xFilial('SB1')+TRB->PRODUTO)

			If !Empty(QRY3->F2_VEND2) .And. QRY3->D2_FORNEC = '000996'   .And. lCarteira
				cVendedor := QRY3->F2_VEND2
			Else
				cVendedor := QRY3->VENDEDOR
			EndIf
			
			SA3->(dbSeek(xFilial('SA3')+cVendedor))	
			
			DbSelectArea("TRB")
			If !dbSeek(QRY3->D2_CLIENTE+QRY3->D2_LOJA+cVendedor+QRY3->D2_COD) // JBS 19/07/2010 Incluido o vendedor na chave
				
				RecLock("TRB",.T.)
				
				TRB->CLIENTE  	:= QRY3->D2_CLIENTE
				TRB->LOJA     	:= QRY3->D2_LOJA
				TRB->NOME     	:= QRY3->A1_NOME
				TRB->CIDADE   	:= QRY3->A1_MUN
				TRB->UF       	:= QRY3->A1_EST
				TRB->SEGMENTO 	:= QRY3->A1_SATIV1
				TRB->SEGMENTO2 	:= QRY3->A1_SATIV8//Giovani Zago 06/10/11
				TRB->SEG_DESCR 	:= QRY3->X5_DESCRI
				TRB->SEG_DESCR2	:= IF(!Empty(QRY3->A1_SATIV8),posicione("SX5",1,xFilial("SX5")+"T3"+ALLTRIM(QRY3->A1_SATIV8),"X5_DESCRI"),"")//Giovani Zago 10/10/11
				TRB->VENDEDOR 	:= cVendedor
				TRB->NOME_VEND 	:= SA3->A3_NOME
				TRB->NRED_VEND  := SA3->A3_NREDUZ //RBORGES - 19/12/2013
				
				TRB->VENDKC   	:= QRY3->A1_VENDKC
				SA3->(dbSeek(xFilial('SA3')+QRY3->A1_VENDKC))
				TRB->N_VENDKC := SA3->A3_NOME
				
				TRB->TECNICO 	:= QRY3->A1_TECNICO
				SA3->(dbSeek(xFilial('SA3')+QRY3->A1_TECNICO))
				TRB->NOME_TEC    := SA3->A3_NOME
				
				TRB->TEC_3M  	:= QRY3->A1_TECN_3
				SA3->(dbSeek(xFilial('SA3')+QRY3->A1_TECN_3))
				TRB->N_TEC_3M := SA3->A3_NOME
				
				TRB->TEC_AMCOR  := QRY3->A1_TECN_A
				SA3->(dbSeek(xFilial('SA3')+QRY3->A1_TECN_A))
				TRB->NTEC_AMCOR :=  SA3->A3_NOME
				
				TRB->TEC_ROCHE  := QRY3->A1_TECN_R
				SA3->(dbSeek(xFilial('SA3')+QRY3->A1_TECN_R))
				TRB->NTEC_ROCHE :=  SA3->A3_NOME 
				
				TRB->TEC_CONVAT:= QRY3->A1_TECN_C
		 		SA3->(dbSeek(xFilial('SA3')+QRY3->A1_TECN_c))
				TRB->NTEC_CONVA :=  SA3->A3_NOME
		
				TRB->TEC_SP  := QRY3->A1_XTEC_SP
				SA3->(dbSeek(xFilial('SA3')+QRY3->A1_XTEC_SP))
				TRB->NTEC_SP :=  SA3->A3_NOME
				
				TRB->TEC_MA  := QRY3->A1_XTEC_MA
				SA3->(dbSeek(xFilial('SA3')+QRY3->A1_XTEC_MA))
				TRB->NTEC_MA :=  SA3->A3_NOME
				
				TRB->TEC_HQ  := QRY3->A1_XTEC_HQ
				SA3->(dbSeek(xFilial('SA3')+QRY3->A1_XTEC_HQ))
				TRB->NTEC_HQ :=  SA3->A3_NOME
	
				TRB->PRODUTO  := QRY3->D2_COD
				TRB->DESCRICAO:= QRY3->B1_DESC
				_mesQ := 'TRB->Q'+SubStr(QRY3->D1_DTDIGIT,5,2)
				If !lNoShowVal // Nใo mostra valores MCVN - 09/08/08
					_mesV := 'TRB->V'+SubStr(QRY3->D1_DTDIGIT,5,2)
				Endif
				&_mesQ   := &_mesQ - QRY3->D2_QUANT
				If !lNoShowVal // Nใo mostra valores MCVN - 09/08/08
					&_mesV   := &_mesV - QRY3->D2_TOTAL
				Endif
				TRB->Q13 := TRB->Q13 - QRY3->D2_QUANT
				
				If !lNoShowVal // Nใo mostra valores MCVN - 09/08/08
					TRB->V13 := TRB->V13 - QRY3->D2_TOTAL
					
					TRB->TOTAL := TRB->TOTAL - QRY3->D2_TOTAL
					nTotMes := TRB->(FieldGet(FieldPos('M'+SubStr(QRY3->D1_DTDIGIT,5,2)))) - QRY3->D2_TOTAL
					TRB->(Fieldput(FieldPos('M'+SubStr(QRY3->D1_DTDIGIT,5,2)),nTotMes))
					
					If Upper(_cDipUsr) $ cSHWCUST
						nCusto := TRB->(FieldGet(FieldPos('C'+SubStr(QRY3->D1_DTDIGIT,5,2)))) - (QRY3->D2_CUSDIP)
						TRB->CUST_TOTAL := TRB->CUST_TOTAL - (QRY3->D2_CUSDIP)
						TRB->(Fieldput(FieldPos('C'+SubStr(QRY3->D1_DTDIGIT,5,2)),nCusto))
					EndIf
					
				Endif
			Else
				RecLock("TRB",.F.)
				_mesQ := 'TRB->Q'+SubStr(QRY3->D1_DTDIGIT,5,2)
				
				If !lNoShowVal // Nใo mostra valores MCVN - 09/08/08
					_mesV := 'TRB->V'+SubStr(QRY3->D1_DTDIGIT,5,2)
				Endif
				&_mesQ   := &_mesQ - QRY3->D2_QUANT
				
				If !lNoShowVal // Nใo mostra valores MCVN - 09/08/08
					&_mesV   := &_mesV - QRY3->D2_TOTAL
				Endif
				
				TRB->Q13 := TRB->Q13 - QRY3->D2_QUANT
				
				If !lNoShowVal // Nใo mostra valores MCVN - 09/08/08
					TRB->V13 := TRB->V13 - QRY3->D2_TOTAL
					
					TRB->TOTAL := TRB->TOTAL - QRY3->D2_TOTAL
					nTotMes := TRB->(FieldGet(FieldPos('M'+SubStr(QRY3->D1_DTDIGIT,5,2)))) - QRY3->D2_TOTAL
					TRB->(Fieldput(FieldPos('M'+SubStr(QRY3->D1_DTDIGIT,5,2)),nTotMes))
					
					If Upper(_cDipUsr) $ cSHWCUST
						nCusto := TRB->(FieldGet(FieldPos('C'+SubStr(QRY3->D1_DTDIGIT,5,2)))) - (QRY3->D2_CUSDIP)
						TRB->CUST_TOTAL := TRB->CUST_TOTAL - (QRY3->D2_CUSDIP)
						TRB->(Fieldput(FieldPos('C'+SubStr(QRY3->D1_DTDIGIT,5,2)),nCusto))
					EndIf
					
				EndIf
			Endif
			
			TRB->(MsUnLock())
			
			dbSelectArea("QRY3")
			QRY3->(dbSkip())
			
		EndDo
	Endif

		QRY3->( DbCloseArea() )

EndIf
//------------------------------------------------------------------------------------------------
// Fim do Tratamento para considerar devolu็๕es
//------------------------------------------------------------------------------------------------
DbSelectArea("TRB") // JBS 20/04/2010
_cChave  := 'CLIENTE + LOJA + VENDEDOR + DESCRICAO'  // JBS 19/07/2010 Incluido o vendedor na chave
IndRegua("TRB",_cArqTrb,_cChave,,,"Criando Indice...(cliente+produto)")

If lTecnico // Arquivo T้cnicos em DBF - MCVN - 17/09/08 - SOMENTE CRIA ARQUIVO

	DbSelectArea("TRB")
	TRB->(dbGotop())
	ProcRegua(TRB->(RECCOUNT()))	
	aCols := Array(TRB->(RECCOUNT()),Len(_aCampos))
	nColuna := 0
	nLinha := 0
	While TRB->(!Eof())
		nLinha++
		IncProc(OemToAnsi("Gerando planilha excel..."))
		For nColuna := 1 to Len(_aCampos)
			aCols[nLinha][nColuna] := &("TRB->("+_aCampos[nColuna][1]+")")			
		Next nColuna
		TRB->(dbSkip())	
	EndDo
	u_GDToExcel(_aCampos,aCols,Alltrim(FunName()))

	dbSelectArea("QRY1")
	QRY1->(dbCloseArea())
	DbSelectArea("TRB")
	DBGOTOP()
	
	COPY TO &cArqExcell VIA "DBFCDX" //Ajustado chamada do dbfcdxads para dbfcdx - Felipe Duran
	
	FRename(cArqExcell+".dtc",cArqExcell+".xls")
	
	MakeDir(cDestino) // CRIA DIRETำRIO CASO NรO EXISTA
	CpyS2T(cArqExcell+".xls",cDestino,.T.) // COPIA ARQUIVO PARA MAQUINA DO USUมRIO
	
	DbCloseArea()
	Ferase(_cArqTrb+".DTC")
	Ferase(_cArqTrb+OrdBagExt())
Else
	dbSelectArea("TRB")
	TRB->(dbGotop())
	
	ProcRegua(TRB->(RECCOUNT()))
	
	While TRB->(!Eof()) .And. !lNoShowVal
		
		IncProc(OemToAnsi("Cliente..: " + TRB->NOME))
		
		RecLock("TRB",.F.) // JBS 21/03/2006
		
		For _x := 1 TO Month(DDATABASE)
			nFat:=TRB->(FieldGet(Fieldpos("M"+StrZero(_x,2))))
			If nFat <> 0
				nPar_Med++
				_Media += nFat
			EndIf
			If Upper(_cDipUsr) $ cSHWCUST// JBS 21/03/2006
				nCus:=TRB->(FieldGet(Fieldpos("C"+StrZero(_x,2))))// JBS 21/03/2006
				If nCus <> 0// JBS 21/03/2006
					_MediaC += nCus// JBS 21/03/2006
				EndIf// JBS 21/03/2006
				nCus:=TRB->(FieldGet(Fieldpos("C"+StrZero(_x,2)))) // JBS 21/03/2006
				nMag:= If(nCus>0 .and. nFat>0,100 - ((nCus / nFat)*100),0) // JBS 21/03/2006
				TRB->(Fieldput(FieldPos('L'+StrZero(_x,2)),nMag))  // JBS 20/03/2006
			EndIf
		Next
		
		TRB->MEDIA := _Media /  nPar_Med
		
		If Upper(_cDipUsr) $ cSHWCUST// JBS 21/03/2006
			TRB->CUST_MEDIA := _MediaC /  nPar_Med
			TRB->MARG_TOTAL := If(TRB->CUST_TOTAL>0 .and. TRB->TOTAL>0,100-((TRB->CUST_TOTAL/TRB->TOTAL)*100),0) // JBS 21/03/2006
			TRB->MARG_MEDIA := If(TRB->CUST_MEDIA>0 .and. TRB->MEDIA>0,100-((TRB->CUST_MEDIA/TRB->MEDIA)*100),0) // JBS 21/03/2006
		EndIf
		
		MsUnLock()
		TRB->(dbSkip())
		
		_Media := 0
		_MediaC:= 0 // JBS 21/03/2006
		nPar_Med := 0
		
	EndDo
Endif

/*//////////////////////////////////////////////////////////////////////////////
#Adiciona clientes sem venda   MCVN - 02/03/2011                              #
/////////////////////////////////////////////////////////////////////////////*/
If lCartToda
	// Executa query
	fQuery04()
	//
	
	ProcRegua(10000)
	DbSelectArea("QRY4")
	QRY4->(dbGotop())
	DbSelectArea("TRB")
	While QRY4->(!Eof())
		
		IncProc(OemToAnsi("Carteira......: " + QRY4->A1_COD+'-'+QRY4->A1_LOJA))
		
		If TRB->( !DbSeek(QRY4->A1_COD + QRY4->A1_LOJA + QRY4->VENDEDOR))
			
			SA3->(dbSeek(_cFilSA3+QRY4->VENDEDOR))
			
			RecLock("TRB",.T.)
			TRB->CLIENTE  := QRY4->A1_COD
			TRB->LOJA     := QRY4->A1_LOJA
			TRB->NOME     := QRY4->A1_NOME
			TRB->CIDADE   := QRY4->A1_MUN
			TRB->UF       := QRY4->A1_EST
			TRB->VENDEDOR := QRY4->VENDEDOR // JBS 30/07/2010	
			TRB->NOME_VEND:= SA3->A3_NOME
			TRB->NRED_VEND:= SA3->A3_NREDUZ //RBORGES - 19/12/2013
			TRB->SEGMENTO := QRY4->A1_SATIV1
			TRB->SEGMENTO2:= QRY4->A1_SATIV8//Giovani Zago 06/10/11 
			TRB->SEG_DESCR:= QRY4->X5_DESCRI
			TRB->SEG_DESCR2	:= IF(!Empty(QRY4->A1_SATIV8),posicione("SX5",1,xFilial("SX5")+"T3"+ALLTRIM(QRY4->A1_SATIV8),"X5_DESCRI"),"")//Giovani Zago 10/10/11
		    
		    TRB->VENDKC     := QRY4->A1_VENDKC
			SA3->(dbSeek(xFilial('SA3')+QRY4->A1_VENDKC))
			TRB->N_VENDKC  := SA3->A3_NOME		
			
			TRB->TECNICO   := QRY4->A1_TECNICO
			SA3->(dbSeek(xFilial('SA3')+QRY4->A1_TECNICO))
			TRB->NOME_TEC  := SA3->A3_NOME                                                            
			
			TRB->TEC_3M    := QRY4->A1_TECN_3
			SA3->(dbSeek(xFilial('SA3')+QRY4->A1_TECN_3))
			TRB->N_TEC_3M  := SA3->A3_NOME                                                             
			
			TRB->TEC_AMCOR := QRY4->A1_TECN_A
			SA3->(dbSeek(xFilial('SA3')+QRY4->A1_TECN_A))
			TRB->NTEC_AMCOR:=  SA3->A3_NOME 	
			
			TRB->TEC_ROCHE := QRY4->A1_TECN_R
			SA3->(dbSeek(xFilial('SA3')+QRY4->A1_TECN_R))
			TRB->NTEC_ROCHE:=  SA3->A3_NOME
			
			TRB->TEC_CONVAT  := QRY4->A1_TECN_C
			SA3->(dbSeek(xFilial('SA3')+QRY4->A1_TECN_C))
			TRB->NTEC_CONVA :=  SA3->A3_NOME			
			
			TRB->TEC_SP  := QRY4->A1_XTEC_SP
			SA3->(dbSeek(xFilial('SA3')+QRY4->A1_XTEC_SP))
			TRB->NTEC_SP :=  SA3->A3_NOME
						
			TRB->TEC_MA  := QRY4->A1_XTEC_MA
			SA3->(dbSeek(xFilial('SA3')+QRY4->A1_XTEC_MA))
			TRB->NTEC_MA :=  SA3->A3_NOME
			
			TRB->TEC_HQ  := QRY4->A1_XTEC_HQ
			SA3->(dbSeek(xFilial('SA3')+QRY4->A1_XTEC_HQ))
			TRB->NTEC_HQ :=  SA3->A3_NOME
			
			MsUnLock()
		EndIf
		
		QRY4->(dbSkip())
		
	EndDo
	
	If Select("QRY4") > 0
		QRY4->( DbCloseArea() )
	EndIf
Endif

Return

///////////////////////////
Static Function RptDetail()
Local aQMedia 	  := {}
Local nQMedia 	  := 0
Local nQCalMedia  := 0
Local aQMedia 	  := {}
Local nQMedia 	  := 0
Local nQCalMedia  := 0
Local cChaveRel   := ""
Local cChaveVend  := ""
Local cRel_Dep    := ""
//Local cArqExcell:= GetSrvProfString("STARTPATH","")+"Excell-DBF\"+_cDipUsr+"-DIPR026" // JBS 12/12/2005
Local cArqExcell:= "\Excell-DBF\"+_cDipUsr+"-DIPR026a" // MCVN - Ajusta local gera็ใo arquivo p๓s virada de versใo p 10 - 18/11/09
Local aTmp        := {}
Local xi,wi,i,nI,s
Local nProdTot    := 0 //Giovani.Zago 15/09/11
Local c1:=0
Local c2:=0
Local c3:=0
Local c4:=0
Local c5:=0
Local c6:=0
Local c7:=0
Local c8:=0
Local c9:=0
Local c10:=0
Local c11:=0
Local c12:=0
Local nColuna
// MCVN 26/08/10
If !Empty(MV_PAR02) // JBS 21/03/2006
	cRel_Dep := '' // JBS 21/03/2006
ElseIf MV_PAR04 == 1
	cRel_Dep := "Apoio"
ElseIf MV_PAR04 == 2
	cRel_Dep := "Call Center"
EndIf

_cTitulo := "Faturamento por cliente/Produto de " + AllTrim(StrZero(_nMesIni,2)) + "/" + AllTrim(Str(_nAnoIni)) +" at้ " + Substr((MV_PAR01),1,2)+"/"+Substr((MV_PAR01),3,4) + Iif(!Empty(MV_PAR02)," - Vendedor: " + MV_PAR02 + "-" + POSICIONE('SA3',1,xFilial('SA3') + MV_PAR02,"A3_NREDUZ"),"") + " - "  + cRel_Dep +If(!Empty(MV_PAR05),' - Fornecedor: '+If(MV_PAR05$"000851/051508","000851/051508",MV_PAR05),'') + Iif(MV_PAR07 = 1,' Por Carteira ',' Por Faturamento ')  // MCVN - 26/08/10
_cTitulo := "Faturamento por cliente/Produto de " + AllTrim(StrZero(_nMesIni,2)) + "/" + AllTrim(Str(_nAnoIni)) +" at้ " + Substr((MV_PAR01),1,2)+"/"+Substr((MV_PAR01),3,4) + Iif(!Empty(MV_PAR02)," - Vendedor: " + MV_PAR02 + "-" + POSICIONE('SA3',1,xFilial('SA3') + MV_PAR02,"A3_NREDUZ"),"") + " - "  + cRel_Dep +If(!Empty(MV_PAR05),' - Fornecedor: '+If(MV_PAR05$"000851/051508","000851/051508",MV_PAR05),'') + Iif(MV_PAR07 = 1,' Por Carteira ',' Por Faturamento ')  // MCVN - 26/08/10
//_cTitulo := "Faturamento por cliente/produto de " +;
//           AllTrim(StrZero(_nMesIni,2)) + "/" + AllTrim(Str(_nAnoIni)) + " at้ " + cMes + "/" + cAno +;
//            Iif(nSetor == 1,' - APOIO',Iif(nSetor == 2,' - CALL CENTER','')+Iif(!Empty(Alltrim(cVenDe)),"  -  Vendedor:  " + cVenDe," "))

_cDesc1  := "                  Janeiro     Fevereiro         Marco         Abril          Maio         Junho         Julho        Agosto      Setembro       Outubro      Novembro      Dezembro         Total         Media"
_cDesc2  := ""
_nReg    := 0
_Total   := {0,0,0,0,0,0,0,0,0,0,0,0,0}
_TotCli  := {0,0,0,0,0,0,0,0,0,0,0,0,0}
_TotVend := {0,0,0,0,0,0,0,0,0,0,0,0,0} // JBS 20/07/2010
_Cli     := .t.
//-------------------------------------------------------------------------------------------------
// MONTA O CABECALHO COM OS 12 MESES SELECIONADOS
//-------------------------------------------------------------------------------------------------
nNum_Cam:= _nMesIni
_cDesc1 := "           "
For xi:=1 to 12
	_nMesIni := Str(_nMesIni)
	If xi == 1
		_nTamMes := 14 - Len(MesExtenso(_nMesIni))
	Else
		_nTamMes := 14 - Len(MesExtenso(_nMesIni))
	EndIf
	_cDesc1 += Space(_nTamMes)+MesExtenso(_nMesIni)
	_nMesIni := Val(_nMesIni)
	If _nMesIni >= 12
		_nMesIni := 1
		_nAnoIni := Val(cAno)
	Else
		_nMesIni++
		_nAnoIni := Val(cAno)-1
	EndIf
Next

_cDesc1  += "         Total         MEDIA"

DbSelectArea("TRB")
DbGoTop()

cChaveRel  := TRB->CLIENTE + TRB->LOJA // JBS 19/07/2010 - Chave para determinar a quebra
cChaveVend := TRB->VENDEDOR // JBS 20/07/2010 - Quebra por vendedor

SetRegua(RecCount())

Do While TRB->(!Eof())
	
	dbSelectArea("SA1")
	dbSetOrder(1)
	dbSeek(xFilial('SA1')+TRB->CLIENTE+TRB->LOJA)
	
	DbSelectArea("TRB")
	
	IncRegua( "Imprimindo: " + TRB->CLIENTE +' - '+ TRB->LOJA )
	
	If li > 55
		li := Cabec(_cTitulo,_cDesc1,_cDesc2,nomeprog,tamanho) + 1
	EndIf
	
	*                                                                                                    1                                                                                                   2                                                                                                   3
	*          1         2         3         4         5         6         7         8         9         0         1         2         3         4         5         6         7         8         9         0         1         2         3         4         5         6         7         8         9         0         1         2         3         4         5         6
	*01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
	*                  Janeiro       Fevereiro           Marco           Abril            Maio           Junho           Julho          Agosto        Setembro         Outubro        Novembro        Dezembro           Total
	*Cliente: 999999-99 123456789012345678901234567890123456789012345678901234567890
	*QuantidadE:   999.999.999     999.999.999     999.999.999     999.999.999     999.999.999     999.999.999     999.999.999     999.999.999     999.999.999     999.999.999     999.999.999     999.999.999     999.999.999
	*ValoR:     999.999.999,99  999.999.999,99  999.999.999,99  999.999.999,99  999.999.999,99  999.999.999,99  999.999.999,99  999.999.999,99  999.999.999,99  999.999.999,99  999.999.999,99  999.999.999,99  999.999.999,99
	
	If _Cli
		@ li,000 PSay 'Cliente..: ' + TRB->CLIENTE +'-'+TRB->LOJA +' - '+ SA1->A1_NOME +  '  Vendedor...: ' + TRB->VENDEDOR +' - ' +TRB->NOME_VEND
		_Cli := .F.
		li+=2
	EndIf
	
	@ li,000 PSay 'Produto..: ' + TRB->PRODUTO +' - '+ TRB->DESCRICAO
	li++
	
	@ li,000 PSay 'Quantidade:'
	
	col  := 14
	nNum := nNum_Cam
	
	For wi:=1 to 12
		If nNum > 12
			nNum := 1
		EndIf
		@ li,col PSay (TRB->(FieldGet(Fieldpos("Q"+StrZero(nNum,2))))) Picture "@E 999,999,999"
		
		AADD(aQtdMes,{ wi,(TRB->(FieldGet(Fieldpos("Q"+StrZero(nNum,2))))) })
		nNum++
		col += 14
	Next
	@ li,Col PSay TRB->Q13 Picture "@E 999,999,999"
	// Calculando e imprimindo a Media da quantidade por M๊s   MCVN - 11/04/2007
	aQMedia 	  := {}
	nQMedia 	  := 0
	nQCalMedia 	  := 0
	
	aQMedia := {TRB->Q01,TRB->Q02,TRB->Q03,TRB->Q04,TRB->Q05,TRB->Q06,TRB->Q07,TRB->Q08,TRB->Q09,TRB->Q10,TRB->Q11,TRB->Q12}
	For i:=1 to 12
		If aQMedia[i] > 0
			nQMedia += aQMedia[i]
			nQCalMedia ++
		Endif
	Next i
	
	nProdTot := nQMedia //Giovani.zago 15/09/11
	nToQto:= nToQto + nProdTot
	
	@ li,196 PSay (nQMedia/nQCalMedia) Picture "@E 999,999,999"
	If lNoShowVal
		TRB->(Fieldput(FieldPos('QM'),nQMedia/nQCalMedia))  //MCVN - 09/09/08
	Endif
	
	li++
	
	If !lNoShowVal // Nใo mostra valores MCVN - 09/08/08
		@ li,000 PSay 'Valor:'
		col  := 14
		nNum := nNum_Cam
		
		For wi:=1 to 12
			If nNum > 12
				nNum := 1
			EndIf
			@ li,col PSay (nFat:=TRB->(FieldGet(Fieldpos("V"+StrZero(nNum,2))))) Picture "@E 999,999,999"
			nNum++
			col += 14
		Next
		@ li,col PSay TRB->V13 Picture "@E 999,999,999"
		
		// Calculando e imprimindo a Media do valor por M๊s   MCVN - 11/04/2007
		aVMedia 	  := {}
		nVMedia 	  := 0
		nVCalMedia 	  := 0
		
		aVMedia := {TRB->V01,TRB->V02,TRB->V03,TRB->V04,TRB->V05,TRB->V06,TRB->V07,TRB->V08,TRB->V09,TRB->V10,TRB->V11,TRB->V12}
		For i:=1 to 12
			If aVMedia[i] > 0
				nVMedia += aVMedia[i]
				nVCalMedia ++
			Endif
		Next i
		
		@ li,196 PSay (nVMedia/nVCalMedia) Picture "@E 999,999,999"
		li++
		
		_nReg++
		
		For I=1 to 13
			_mes := 'TRB->V'+StrZero(i,2)
			_TotCli[i] += (&_mes) // JBS 20/07/2010
			_TotVend[i]+= (&_mes) // JBS 20/07/2010
			_Total[i]  += (&_mes) // JBS 20/07/2010
		Next
	Endif
	
	DbSelectArea("TRB")
	
	TRB->(dbSkip())
	//-------------------------------------------------------------------------------------------------
	// JBS 20/07/2010   - Faz a quebra quando mudar de vendedor
	//-------------------------------------------------------------------------------------------------
	If cChaveVend <> TRB->VENDEDOR .or. cChaveRel <> TRB->CLIENTE + TRB->LOJA
		
		_Cli := .T.
		
		If _TotCli[13] <> _TotVend[13] .or. cChaveRel == TRB->CLIENTE + TRB->LOJA
			
			If !lNoShowVal // Nใo mostra valores MCVN - 09/08/08
				
				li++
				@ li,000 PSay 'Sub Total'
				col  := 14
				nNum := nNum_Cam
				
				For wi:=1 to 12
					
					If nNum > 12
						nNum := 1
					EndIf
					
					@ li,col PSay _TotVend[nNum] Picture "@E 999,999,999"
					nNum++
					col += 14
					
				Next
				@ li,col PSay _TotVend[13] Picture "@E 999,999,999"
			Endif
			li += 2
		EndIf
		
		_TotVend   := {0,0,0,0,0,0,0,0,0,0,0,0,0}
		cChaveVend := TRB->VENDEDOR
		
	EndIf
	//-------------------------------------------------------------------------------------------------
	// Faz a quebra por cliente.
	//-------------------------------------------------------------------------------------------------
	If cChaveRel <> TRB->CLIENTE + TRB->LOJA // JBS 19/07/2010
		
		_Cli := .T.
		
		If !lNoShowVal // Nใo mostra valores MCVN - 09/08/08
			
			li++
			@ li,000 PSay 'Total Cli'
			col  := 14
			nNum := nNum_Cam
			
			For wi:=1 to 12
				
				If nNum > 12
					nNum := 1
				EndIf
				
				@ li,col PSay _TotCli[nNum] Picture "@E 999,999,999"
				nNum++
				col += 14
				
			Next
			
			@ li,col PSay _TotCli[13] Picture "@E 999,999,999"
			
			If li < 62 .or. TRB->(EOF())
				li++
				@ li,000 PSay Replicate('.',220)
			EndIf
			
		Endif
		
		li += 2
		
		_TotCli  := {0,0,0,0,0,0,0,0,0,0,0,0,0}
		cChaveRel:= TRB->CLIENTE + TRB->LOJA
		
	EndIf
	
EndDo

If li <> 80
	
	@ li,000 PSay Replic("*",Limite)
	
	If !lNoShowVal // Nใo mostra valores MCVN - 09/08/08
		
		li++
		@ li,000 PSay "TOTAL VALOR:"  //Giovani Zago 10/10/11
		col  := 14
		nNum := nNum_Cam
		
		For wi:=1 to 12
			
			If nNum > 12
				nNum := 1
			EndIf
			
			@ li,col PSay _Total[nNum] Picture "@E 999,999,999"
			nNum++
			col += 14
			
		Next
		
		@ li,col PSay _Total[13] Picture "@E 999,999,999"
		col += 14
		
	Endif
	li++
	@ li,000 PSay Replic("*",Limite)
	li++
	//Giovani Zago 06/10/11
	
	col = 14
	@ li,000 PSay "TOTAL QUANTIDADES:"    

	nProdTot:= 0
	For s:=1 to len(aQtdMes)
		Do Case
			Case aQtdMes[s][1] = 1
				c1:=c1+aQtdMes[s][2]
			Case aQtdMes[s][1] = 2
				c2:=c2+aQtdMes[s][2]
			Case aQtdMes[s][1] = 3
				c3:=c3+aQtdMes[s][2]
			Case aQtdMes[s][1] = 4
				c4:=c4+aQtdMes[s][2]
			Case aQtdMes[s][1] = 5
				c5:=c5+aQtdMes[s][2]
			Case aQtdMes[s][1] = 6
				c6:=c6+aQtdMes[s][2]
			Case aQtdMes[s][1] = 7
				c7:=c7+aQtdMes[s][2]
			Case aQtdMes[s][1] = 8
				c8:=c8+aQtdMes[s][2]
			Case aQtdMes[s][1] = 9
				c9:=c9+aQtdMes[s][2]
			Case aQtdMes[s][1] = 10
				c10:=c10+aQtdMes[s][2]
			Case aQtdMes[s][1] = 11
				c11:=c11+aQtdMes[s][2]
			Case aQtdMes[s][1] = 12
				c12:=c12+aQtdMes[s][2]
		EndCase
		
		nProdTot:= nProdTot+aQtdMes[s][2]
	Next s
	col += 1
	
	@ li,col PSay c1 Picture "@E 999,999,999" //Giovani Zago 10/10/11
	col += 14
	@ li,col PSay c2 Picture "@E 999,999,999" //Giovani Zago 10/10/11
	col += 14
	@ li,col PSay c3 Picture "@E 999,999,999" //Giovani Zago 10/10/11
	col += 14
	@ li,col PSay c4 Picture "@E 999,999,999" //Giovani Zago 10/10/11
	col += 14
	@ li,col PSay c5 Picture "@E 999,999,999" //Giovani Zago 10/10/11
	col += 14
	@ li,col PSay c6 Picture "@E 999,999,999" //Giovani Zago 10/10/11
	col += 14
	@ li,col PSay c7 Picture "@E 999,999,999" //Giovani Zago 10/10/11
	col += 14
	@ li,col PSay c8 Picture "@E 999,999,999" //Giovani Zago 10/10/11
	col += 14
	@ li,col PSay c9 Picture "@E 999,999,999" //Giovani Zago 10/10/11
	col += 14
	@ li,col PSay c10 Picture "@E 999,999,999" //Giovani Zago 10/10/11
	col += 14
	@ li,col PSay c11 Picture "@E 999,999,999" //Giovani Zago 10/10/11
	col += 14
	@ li,col PSay c12 Picture "@E 999,999,999" //Giovani Zago 10/10/11
	col += 14
	@ li,col PSay nProdTot Picture "@E 999,999,999" //Giovani Zago 10/10/11
	li++
	@ li,000 PSay Replic("*",Limite)
	//**********************************************************************************************************************************************
	
	li+=2
	
	
	Roda(_nReg,if(_nReg=1,'Cliente',"Clientes"),Tamanho)
	//	Roda(cbcont,cbtxt,"G")
	
EndIf

dbSelectArea("QRY1")
QRY1->(dbCloseArea())

DbSelectArea("TRB")

If lCriaArq

	DbSelectArea("TRB")
	TRB->(dbGotop())
	ProcRegua(TRB->(RECCOUNT()))	
	aCols := Array(TRB->(RECCOUNT()),Len(_aCampos))
	nColuna := 0
	nLinha := 0
	While TRB->(!Eof())
		nLinha++
		IncProc(OemToAnsi("Gerando planilha excel..."))
		For nColuna := 1 to Len(_aCampos)
			aCols[nLinha][nColuna] := &("TRB->("+_aCampos[nColuna][1]+")")			
		Next nColuna
		TRB->(dbSkip())	
	EndDo
	u_GDToExcel(_aCampos,aCols,Alltrim(FunName()))

	COPY TO &cArqExcell VIA "DBFCDX" //Ajustado chamada do dbfcdxads para dbfcdx - Felipe Duran
	
	FRename(cArqExcell+".dtc",cArqExcell+".xls")
	
	MakeDir(cDestino) // CRIA DIRETำRIO CASO NรO EXISTA
	CpyS2T(cArqExcell+".xls",cDestino,.T.) // COPIA ARQUIVO PARA MAQUINA DO USUมRIO
	
	// Buscando e apagando arquivos temporแrios - MCVN 27/08/10
	aTmp := Directory( cDestino+"*.tmp" )
	For nI:= 1 to Len(aTmp)
		fErase(cDestino+aTmp[nI,1])
	Next nI
EndIf

DbCloseArea()

Ferase(_cArqTrb+".DTC")
Ferase(_cArqTrb+OrdBagExt())

Return(.T.)

*---------------------------------------*
Static Function DipPergDiverg(lLer)
// Registra altera็๕es no SX1
*---------------------------------------*
Local aRegs:={}
Local lIncluir
Local i,j
SX1->(dbSetOrder(1))

AADD(aRegs,{cPerg,"01","Mes e Ano Final    ?","","","mv_ch1","C",06,0,0,"G","","MV_PAR01",""       ,"","","","","","","","","","","","","","","","","","","","","","",""})
AADD(aRegs,{cPerg,"02","Vendedor           ?","","","mv_ch2","C",06,0,0,"G","","MV_PAR02",""       ,"","","","","","","","","","","","","","","","","","","","","","","","SA3"})
AAdd(aRegs,{cPerg,"03","Cria arquivo       ?","","","mv_ch3","N",01,0,1,"C","","MV_PAR03","Sim"    ,"","","","","Nao","","","","","","","",""})
AADD(aRegs,{cPerg,"04","Informe o setor    ?","","","mv_ch4","N",1,0,0,"C","","MV_PAR04","1-Apoio","","","","","2-Call Center","","","","","3-Ambos","","","4-Licitacoes"})
AADD(aRegs,{cPerg,"05","Fornecedor         ?","","","mv_ch5","C",06,0,0,"G","","MV_PAR05",""       ,"","","","","","","","","","","","","","","","","","","","","","","","SA2"})
AADD(aRegs,{cPerg,"06","Grupo de Clientes  ?","","","mv_ch6","C",06,0,0,"G","","MV_PAR06",""       ,"","","","","","","","","","","","","","","","","","","","","","","","ACY"})
AADD(aRegs,{cPerg,"07","Por Carteira       ?","","","mv_ch7","N",01,0,1,"C","","MV_PAR07","Sim"    ,"","","","","Nao","","","","","","","",""})
AADD(aRegs,{cPerg,"08","De Cliente         ?","","","mv_ch8","C",06,0,0,"G","","MV_PAR08",""       ,"","","","","","","","","","","","","","","","","","","","","","","","SA1"})
AAdd(aRegs,{cPerg,"09","Ate Cliente        ?","","","mv_ch9","C",06,0,0,"G","","MV_PAR09",""       ,"","","","","","","","","","","","","","","","","","","","","","","","SA1"})
AADD(aRegs,{cPerg,"10","De Produto         ?","","","mv_chA","C",15,0,0,"G","","MV_PAR10",""       ,"","","","","","","","","","","","","","","","","","","","","","","","SB1"})
AAdd(aRegs,{cPerg,"11","Ate Produto        ?","","","mv_chB","C",15,0,0,"G","","MV_PAR11",""       ,"","","","","","","","","","","","","","","","","","","","","","","","SB1"})
AAdd(aRegs,{cPerg,"12","Mostrar valores    ?","","","mv_chC","N",01,0,1,"C","","MV_PAR12","Sim"    ,"","","","","Nao","","","","","","","",""})
AADD(aRegs,{cPerg,"13","Carteira TODA      ?","","","mv_chD","N",01,0,1,"C","","MV_PAR13","Nao"    ,"","","","","Sim","","","","","","","",""})
AADD(aRegs,{cPerg,"14","Tecnico 3M         ?","","","MV_CHE","C",06,0,0,"G","","MV_PAR14",""       ,"","","","","","","","","","","","","","","","","","","","","","","","SA3"})//Rafael Moraes Rosa - 15/03/2023

// Excluir:
// AAdd(aRegs,{cPerg,"14","Operadores Publico ?","","","mv_chE","C",40,0,0,"G","","MV_PAR14",""       ,"","",Substr(cOper,01,40),"","","","","","","","","","",""})
// AAdd(aRegs,{cPerg,"15","Operadores Publico ?","","","mv_chF","C",40,0,0,"G","","MV_PAR15",""       ,"","",Substr(cOper,41,40),"","","","","","","","","","",""})
// AAdd(aRegs,{cPerg,"16","Operadores Publico ?","","","mv_chG","C",40,0,0,"G","","MV_PAR16",""       ,"","",Substr(cOper,81,40),"","","","","","","","","","",""})
// aAdd(aRegs,{cPerg,"05","Ate Fornecedor     ?","","","mv_ch5","C",06,0,0,"G","","oMV_PAR05",""       ,"","",cForAte ,"","","","","","","","","","","","","","","","","","","","","SA2"})

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

//cOper:=aRegs[10,17]+aRegs[11,17]+aRegs[12,17]

Return(.t.)
*-----------------------------------------------------*
Static function DP26SeleRel(nCheck,aObj,alCheck)
*-----------------------------------------------------*
Local i
If nCheck = 5
	If !Empty(cOper)
		For i:=1 to 3
			alCheck[i]:= .f.
			aObj[i]:Refresh()
		Next i
	EndIf
Else
	For i:=1 to 3
		If nCheck <> i .and. alCheck[nCheck]
			alCheck[i]:= .f.
		elseIf nCheck = i
			alCheck[i]:= .T.
		EndIf
		aObj[i]:Refresh()
	Next
	If alCheck[nCheck]
		nSetor:=nCheck
		alCheck[nSetor]:=.t.
	ElseIf nSetor=nCheck
		nSetor:=1
	EndIf
	//alCheck[nSetor]:=.t.
	aObj[nSetor]:Refresh()
EndIf
//oBt1:SetFocus()
RETURN(.T.)

*-----------------------------------------------------*
//MCVN - 17/09/08
Static function DP26SeleTec(nCheck,aObj,alCheck)
*-----------------------------------------------------*
Local i

For i:=1 to 4
	If nCheck <> i .and. alCheck[nCheck]
		alCheck[i]:= .f.
		aObj[i]:Refresh()
	EndIf
Next
If alCheck[nCheck]
	nTecnico:=nCheck
	alCheck[nTecnico]:=.t.
ElseIf nTecnico=nCheck
	nTecnico:=1
EndIf
aObj[nTecnico]:Refresh()
RETURN(.T.)

*-----------------------------------------------------*
//MCVN - 17/09/08
Static function DP26VerTri()
*-----------------------------------------------------*
Local cTrimClose := "" // Trimestre Fechado

If cAno < SubStr(Dtos(date()),1,4)
	cTrimClose := ("01/02/03/04/05/06/07/08/09/10/11/12")
ElseIf SubStr(Dtos(date()),5,2) > '09'
	cTrimClose := ("01/02/03/04/05/06/07/08/09")
ElseIf SubStr(Dtos(date()),5,2) > '06'
	cTrimClose := ("01/02/03/04/05/06")
ElseIf SubStr(Dtos(date()),5,2) > '03'
	cTrimClose := ("01/02/03")
Endif

RETURN(cTrimClose)

*-------------------------------------------------------------*
//MCVN - 18/09/08
Static function DP26MailTec(cCodTec,cNomeTec,cEmail,cArquivo)
*-------------------------------------------------------------*

//Local cArquivo  := ""
//Local cEmail	:
Local cAttach	:= {}
Local aMsg		:= {}
Local cAssunto	:= EncodeUTF8("Envio de relat๓rio dos T้cnicos","cp1252")
Local lRetorno := .T.

aMsg := {} // LIMPA ARRAY PARA RECEBER NOVAMENTE O NOME DO REPRESENTANTE
cAttach := {} // LIMPA ARQUIVOS ENVIADOS

Aadd(cAttach,cArquivo) //  ATACHA APENAS OS 5 PRIMEIROS E MENORES RELATำRIOS

//	If File(cArquivo)
Aadd(aMsg,{cCodTec, cNomeTec}) // NOME DO REPRESENTANTE
lRetorno := DIP26EMail(cEmail,cAssunto,aMsg,cAttach)	// CHAMADA DA FUN็ใO DE ENVIO DE EMAIL
//	Endif

Return(lRetorno)
/*==========================================================================\
|Programa  |EMail   | Autor | Rafael de Campos Falco  | Data | 04/06/2004   |
|===========================================================================|
|Desc.     | Envio de EMail                                                 |
|===========================================================================|
|Sintaxe   | EMail                                                          |
|===========================================================================|
|Uso       | Especifico DIPROMED                                            |
\==========================================================================*/

Static Function DIP26EMail(cEmail,cAssunto,aMsg,cAttach)

Local cAccount  := Lower(Alltrim(GetMv("MV_RELACNT")))
Local cFrom     := Lower(Alltrim(GetMv("MV_RELACNT"))) // JBS 08/07/2010 //"fernanda.araujo@dipromed.com.br" //Lower(Alltrim(GetMv("MV_RELACNT")))
Local cPassword := Alltrim(GetMv("MV_RELPSW"))
Local cServer   := Alltrim(GetMv("MV_RELSERV"))
Local cEmailTo  := ""
Local cEmailCc  := Lower(Alltrim(cDipr026A)) // JBS 08/07/2010 "fernanda.araujo@dipromed.com.br"
Local cEmailBcc := ""
Local cError    := ""
Local cMsg      := ""
Local lResult   := .F.
LOCAL lSmtpAuth := GetNewPar("MV_RELAUTH",.F.)
LOCAL lAutOk	:= .F.

/*==============================================================================\
| Definicao do cabecalho do email                                               |
\==============================================================================*/
cMsg := '<html>'
cMsg += '<head>'
cMsg += '<title>' + cAssunto + '</title>'
cMsg += '</head>'
cMsg += '<body>'
cMsg += '<HR Width=85% Size=3 Align=Centered Color=Red> <P>'
cMsg += '<Table Align=Center BorderColor=#000000 CELLPADDING=4 CELLSPACING=0 Width=60%>'

/*=============================================================================*/
/*Definicao do cabecalho do relat๓rio                                          */
/*=============================================================================*/

cMsg += '<table width="100%">'
cMsg += '<tr align="center">'
cMsg += '<td width="100%"><font color="blue">T้cnico: ' + aMsg[1,1] + "-" + aMsg[1,2] + '</font></td>'
cMsg += '</tr>'
cMsg += '<tr align="center">'
cMsg += '<td width="95%">Relat๓rio de t้cnico enviado automaticamente pelo sistema Protheus.<br>'
cMsg += 'Qualquer d๚vida ou esclarecimento entrar em contato com Fernanda - Supervisora Administrativa de Vendas.<br><br>'
cMsg += 'Atenciosamente<br><br>'
cMsg += '<font color="blue">Fernanda Ara๚jo</font><br><br>'
cMsg += '<font color="red">O ARQUIVO ANEXO DEVERม SER ABERTO NO  EXCEL !</font></td>'
cMsg += '</tr>'
cMsg += '</table>'

/*==============================================================================\
| Definicao do rodape do email                                                  |
\==============================================================================*/
cMsg += '</Table>'
cMsg += '<HR Width=85% Size=3 Align=Centered Color=Red> <P>'
cMsg += '</body>'
cMsg += '</html>'

/*==============================================================================\
| Envia o mail para a lista selecionada. Envia como BCC para que a pessoa pense |
| que somente ela recebeu aquele email, tornando o email mais personalizado.    |
\==============================================================================*/
IF At(";",cEmail) > 0
	cEmailTo := SubStr(cEmail,1,At(";",cEmail)-1)
	cEmailCc := SubStr(cEmail,At(";",cEmail)+1,1)
Else
	cEmailTo := Alltrim(cEmail)
EndIF

CONNECT SMTP SERVER cServer ACCOUNT cAccount PASSWORD cPassword RESULT lResult

If !lAutOk
	If ( lSmtpAuth )
		lAutOk := MailAuth(cAccount,cPassword)
	Else
		lAutOk := .T.
	EndIf
EndIf

If lResult .And. lAutOk
	SEND MAIL FROM cFrom ;
	TO      	Lower(cEmailTo);
	CC      	Lower(cEmailCc);
	BCC     	Lower(cEmailBcc);
	SUBJECT 	cAssunto;
	BODY    	cMsg;
	ATTACHMENT  cAttach[1];
	RESULT lResult
	
	If !lResult
		//Erro no envio do email
		GET MAIL ERROR cError
		MsgInfo(cError,OemToAnsi("Aten็ใo"))
	EndIf
	
	DISCONNECT SMTP SERVER
Else
	//Erro na conexao com o SMTP Server
	GET MAIL ERROR cError
	
	MsgInfo(cError,OemToAnsi("Aten็ใo"))
EndIf

Return(lResult)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณfQuery01  บAutor  ณJailton B Santos-JBSบ Data ณ 22/03/2010  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Esta Query apura os falores faturado no pedido pela empresaบฑฑ
ฑฑบ          ณ informada como parametro, Retorna Query QRY1.              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Especifico - Faturamento - DIPROMED.                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function fQuery01( _cEmpresa ,_cFilial, lTecnico)

Local cQuery  := ""
Local cFilSB1 := cFilAnt//fFilial(_cEmpresa,'SB1',_cFilial)
Local cFilSX5 := cFilAnt//fFilial(_cEmpresa,'SX5',_cFilial)
Local cFilSD2 := cFilAnt//fFilial(_cEmpresa,'SD2',_cFilial)
Local cFilSF2 := cFilAnt//fFilial(_cEmpresa,'SF2',_cFilial)
Local cFilSF4 := cFilAnt//fFilial(_cEmpresa,'SF4',_cFilial)
Local cFilSC5 := cFilAnt//fFilial(_cEmpresa,'SC5',_cFilial)
Local nId     := 0
Local _x,nMes

ProcRegua(500)
For _x := 1 to 150
	IncProc( "Processando...VENDAS ")
Next

cQuery   := "SELECT D2_CLIENTE, "
cQuery   += " D2_LOJA, "
cQuery   += " A1_NOME, "
cQuery   += " A1_MUN, "
cQuery   += " A1_EST, "

If lCarteira  // JBS 19/07/2010 If !Empty(Alltrim(cVenDe))
	cQuery   += " A1_VEND  VENDEDOR, "
Else
	cQuery   += " F2_VEND1 VENDEDOR, "
Endif

cQuery   += " A3_NOME, "
cQuery   += " A3_NREDUZ, "//RBORGES - 19/12/2013
cQuery   += " A1_PRICOM, "
cQuery   += " A1_ULTCOM, "
cQuery   += " A1_HPAGE, "
cQuery   += " A1_OBSERV, "
cQuery   += " A1_SATIV1, "
cQuery   += " A1_SATIV8, "
cQuery   += " X5_DESCRI, "
cQuery   += " D2_COD, "
cQuery   += " B1_DESC, "
cQuery   += " A1_VENDKC, "
cQuery   += " A1_TECNICO, "
cQuery   += " A1_TECN_3, "
cQuery   += " A1_TECN_A, "
cQuery   += " A1_TECN_R, "
cQuery   += " A1_TECN_C, "                
cQuery   += " A1_XTEC_SP, "                
cQuery   += " A1_XTEC_MA, "                
cQuery   += " A1_XTEC_HQ, "                
cQuery   += " A1_CGC, "
cQuery   += " A1_INSCR, "
cQuery   += " A1_GRPVEN, "
//cQuery   += "       LEFT(D2_EMISSAO,6) D2_EMISSAO, "
cQuery   += " SUM(D2_QUANT) D2_QUANT, "
cQuery   += " SUM(D2_TOTAL) D2_TOTAL, "
cQuery   += " SUM(D2_CUSDIP*D2_QUANT) D2_CUSDIP "
If lTecnico
	cQuery   += " ,SUM( CASE WHEN SUBSTRING(D2_EMISSAO,5,2) IN('01','02','03') THEN D2_QUANT ELSE 0 END ) QTD_1TRI"
	cQuery   += " ,SUM( CASE WHEN SUBSTRING(D2_EMISSAO,5,2) IN('04','05','06') THEN D2_QUANT ELSE 0 END ) QTD_2TRI"
	cQuery   += " ,SUM( CASE WHEN SUBSTRING(D2_EMISSAO,5,2) IN('07','08','09') THEN D2_QUANT ELSE 0 END ) QTD_3TRI"
	cQuery   += " ,SUM( CASE WHEN SUBSTRING(D2_EMISSAO,5,2) IN('10','11','12') THEN D2_QUANT ELSE 0 END ) QTD_4TRI"
	
	cQuery   += " ,SUM( CASE WHEN SUBSTRING(D2_EMISSAO,5,2) IN('01','02','03') THEN D2_TOTAL ELSE 0 END ) TOT_1TRI"
	cQuery   += " ,SUM( CASE WHEN SUBSTRING(D2_EMISSAO,5,2) IN('04','05','06') THEN D2_TOTAL ELSE 0 END ) TOT_2TRI"
	cQuery   += " ,SUM( CASE WHEN SUBSTRING(D2_EMISSAO,5,2) IN('07','08','09') THEN D2_TOTAL ELSE 0 END ) TOT_3TRI"
	cQuery   += " ,SUM( CASE WHEN SUBSTRING(D2_EMISSAO,5,2) IN('10','11','12') THEN D2_TOTAL ELSE 0 END ) TOT_4TRI"
Else
	For nMes := 1 To 12
		cQuery   += " ,SUM( CASE WHEN SUBSTRING(D2_EMISSAO,5,2) = '"+StrZero(nMes,2)+"' THEN D2_QUANT ELSE 0 END ) QTD_"+StrZero(nMes,2)
		cQuery   += " ,SUM( CASE WHEN SUBSTRING(D2_EMISSAO,5,2) = '"+StrZero(nMes,2)+"' THEN D2_TOTAL ELSE 0 END ) TOT_"+StrZero(nMes,2)
		cQuery   += " ,SUM( CASE WHEN SUBSTRING(D2_EMISSAO,5,2) = '"+StrZero(nMes,2)+"' THEN D2_CUSDIP*D2_QUANT ELSE 0 END ) CST_"+StrZero(nMes,2)
	Next nMes
EndIf
cQuery   += " ,D2_FORNEC "
cQuery   += " ,F2_VEND2 "
cQuery   += " FROM SD2" + _cEmpresa + " SD2 "
//--------------------------------------------------------------------------------------------------------------------------
// Cria o relacionamento entre a TES do produto no SD2 e o cadastro de TES, trazendo apenas transa็๕es que geram financeiro
//--------------------------------------------------------------------------------------------------------------------------
cQuery   += "INNER JOIN SF4" + _cEmpresa + " SF4 ON F4_FILIAL = '"+cFilSF4+"' "
cQuery   += " AND F4_CODIGO = D2_TES "
cQuery   += " AND F4_DUPLIC = 'S' "
cQuery   += " AND SF4.D_E_L_E_T_ =  '' "
//--------------------------------------------------------------------------------------------------------------------------
// Cria o relacionamento do Produto no SD2 com o Cadastro de Produtp
//--------------------------------------------------------------------------------------------------------------------------
cQuery   += "INNER JOIN SB1" + _cEmpresa + " SB1 ON  B1_FILIAL = '"+cFilSB1+"' "
cQuery   += " AND B1_COD = D2_COD "
cQuery   += " AND SB1.D_E_L_E_T_ =  '' "
//--------------------------------------------------------------------------------------------------------------------------
// Cria o Relacionamento do Clientes do SD2 com o Cadastro de clientes.
//--------------------------------------------------------------------------------------------------------------------------
cQuery   += "INNER JOIN "+RetSqlName('SA1')+" SA1 ON  A1_FILIAL = '"+xFilial('SA1')+"' "
cQuery   += " AND A1_COD = D2_CLIENTE "
cQuery   += " AND A1_LOJA = D2_LOJA "

If lTecnico
	
	cQuery   += " AND Right(Left(D2_EMISSAO,6),2) IN ('"+StrTran(AllTrim(cTrimestre),"/","','")+"') "
	
	Do Case
		Case nTecnico==1 .And. (nTecSA3 = 5 .Or. nTecSA3 = 1) // T้cnico KC
			cQuery   += " AND A1_TECNICO = '" + cTecnico +"' "
			cForDe  := "000366"
		Case nTecnico==2 .And. (nTecSA3 = 5 .Or. nTecSA3 = 2) // T้cnico AMCOR
			cQuery   += " AND A1_TECN_A  = '" + cTecnico +"' "
			cForDe  := "000183"
		Case nTecnico==3 .And. (nTecSA3 = 5 .Or. nTecSA3 = 3) // T้cnico 3M
			cQuery   += " AND A1_TECN_3  = '" + cTecnico +"' "
			cForDe  := "000041"
		Case nTecnico==4 .And. (nTecSA3 = 5 .Or. nTecSA3 = 4) // T้cnico ROCHE
			cQuery   += " AND A1_TECN_R  = '" + cTecnico +"' "
			cForDe  := "000338"
		Case nTecnico==5 .And. (nTecSA3 = 5 .Or. nTecSA3 = 5) // T้cnico Convatec
			cQuery   += " AND A1_TECN_C  = '" + cTecnico +"' "
			cForDe  := "000647"                                                    
		Case nTecnico==6 .And. (nTecSA3 = 5 .Or. nTecSA3 = 6) // T้cnico SP
			cQuery   += " AND A1_XTEC_SP  = '" + cTecnico +"' "
			cForDe  := "000996"
		Case nTecnico==7 .And. (nTecSA3 = 5 .Or. nTecSA3 = 7) // T้cnico MA
			cQuery   += " AND A1_XTEC_MA  = '" + cTecnico +"' "
			cForDe  := "000997"
		Case nTecnico==8 .And. (nTecSA3 = 5 .Or. nTecSA3 = 8) // T้cnico HQ
			cQuery   += " AND A1_XTEC_HQ  = '" + cTecnico +"' "
			cForDe  := "000851"
	EndCase
	
Endif

If Empty(cGrpCli)
	cQuery   += " AND A1_COD BETWEEN '"+cCliDe+"' AND '"+cCliAte+"' "
Else
	cQuery  += " AND A1_GRPVEN = '" +cGrpCli+"'"
EndIf

//Rafael Moraes Rosa - 15/03/2023 - INICIO
If !Empty(cTec3M)
	cQuery   += " AND A1_TECN_3 = '"+cTec3M+"' 
EndIf
//Rafael Moraes Rosa - 15/03/2023 - FIM

cQuery   += " AND SA1.D_E_L_E_T_ = '' "
//--------------------------------------------------------------------------------------------------------------------------
// Cria o relacionamento entre o castro de Clientes a o cadastro de Atividades no SX5
//--------------------------------------------------------------------------------------------------------------------------
cQuery   += "Left JOIN SX5" + _cEmpresa + " SX5 ON  X5_FILIAL = '"+cFilSX5+"' "   // JBS 09/08/2010  - Incluido o left join (*=)
cQuery   += " AND X5_CHAVE = A1_SATIV1 "
cQuery   += " AND X5_TABELA = 'T3' "
cQuery   += " AND SX5.D_E_L_E_T_ = '' "
//--------------------------------------------------------------------------------------------------------------------------
// Cria o relacionamento entre os itens do SD2 com as notas fiscais
//--------------------------------------------------------------------------------------------------------------------------
cQuery   += "INNER JOIN SF2" + _cEmpresa + " SF2 ON  F2_FILIAL = '"+cFilSF2+"'
cQuery   += " AND F2_DOC = D2_DOC "
cQuery   += " AND F2_SERIE = D2_SERIE "
cQuery   += " AND F2_VEND1 <> '006874' "
cQuery   += " AND SF2.D_E_L_E_T_ =  '' "

//--------------------------------------------------------------------------------------------------------------------------
// Cria o relacionamento ente o vendedor nas notas  fiscais e o cadastro de vendedores
//--------------------------------------------------------------------------------------------------------------------------
cQuery   += "INNER JOIN " + RetSqlName('SA3') + " SA3 ON  A3_FILIAL = '" + xFilial('SA3') + "'  "
If U_ListVend() == ''
	If !Empty(Alltrim(cVenDe))
		cQuery   += " AND A3_COD  = '"+cVenDe+"' "
	EndIf
	If lCarteira
		cQuery   += " AND A3_COD  = A1_VEND " // JBS 16/07/2010
	Else
		cQuery   += " AND (A3_COD = (CASE WHEN F2_VEND2 <> ' ' AND D2_FORNEC IN('000366','000446','000996') THEN F2_VEND2 ELSE F2_VEND1 END))" // JBS 16/07/2010
	Endif
Else
	//cQuery       += "                      AND A3_COD "+U_ListVend()+" "
	cQuery       += " AND A3_COD IN("+U_ListVend("2")+") "
	If !Empty(cVenDe)
		cQuery   += " AND A3_COD  = '"+cVenDe+"' "
	EndIf
	If lCarteira
		cQuery   += " AND A3_COD  = A1_VEND " // JBS 16/07/2010
	Else
		cQuery   += " AND (A3_COD = (CASE WHEN F2_VEND2 <> ' ' AND D2_FORNEC IN('000366','000446','000996') THEN F2_VEND2 ELSE F2_VEND1 END))" // JBS 16/07/2010
	EndIf
EndIf
cQuery   += " AND SA3.D_E_L_E_T_ = ''  "
//--------------------------------------------------------------------------------------------------------------------------
// Cria o relacionamento do Pedido do SD2 e o Cadastro de Pedidos
//--------------------------------------------------------------------------------------------------------------------------
cQuery   += "INNER JOIN SC5" + _cEmpresa + " SC5 ON  C5_FILIAL = '" + cFilSC5 + "' "
cQuery   += " AND C5_NUM = D2_PEDIDO "
cQuery   += " AND SC5.D_E_L_E_T_ =  ''"
//--------------------------------------------------------------------------------------------------------------------------
// Cria o relacionamento do Operdador do Pedido e o Cadastro de Operadores
//--------------------------------------------------------------------------------------------------------------------------
cQuery   += "INNER JOIN "+RetSqlName('SU7')+" SU7 ON  U7_FILIAL = '"+xFilial('SU7')+"' "
cQuery   += " AND U7_COD = C5_OPERADO "

If nSetor == 1 .and. empty(cOper)// APOIO
	cQuery   += " AND (U7_VEND = 2 OR U7_COD  = '000015') "
ElseIf nSetor == 2 .and. empty(cOper) // CALL CENTER
	cQuery   += " AND U7_VEND = 1"
	cQuery   += " AND U7_COD <> '000015'"
ElseIf nSetor == 4 .and. empty(cOper) // LICITAวOES - WCS - 22/07/2021
		cQuery   += "And U7_POSTO = '03' "                                // Licitacoes JBS 30/07/2010
elseIf !empty(cOper) // Operadores Selecionados pelo usuario
	cQuery   += " AND U7_COD IN ('"+StrTran(AllTrim(cOper),"/","','")+"')"
EndIf
cQuery   += " AND SU7.D_E_L_E_T_ = '' "
//--------------------------------------------------------------------------------------------------------------------------
// Regras do SD2 para filtrar as transa็๕es
//--------------------------------------------------------------------------------------------------------------------------
cQuery   += " WHERE D2_FILIAL = '" + cFilSD2 + "' "
cQuery   += "   AND SD2.D2_TIPO IN ('N','C') "
//cQuery   += "   AND left(D2_EMISSAO,4) = '"+cAno+"' "
cQuery   += "   AND LEFT(D2_EMISSAO,6) BETWEEN '" + _nParIni + "' AND '" + _nParFim + "'"

/*If Empty(mv_par14) .and. Empty(mv_par15)
	cQuery   += "   AND LEFT(D2_EMISSAO,6) BETWEEN '" + _nParIni + "' AND '" + _nParFim + "'"
Else
	cQuery   += "AND D2_EMISSAO BETWEEN '" + DTOS(mv_par14) + "' AND '" + DTOS(mv_par15) + "' "
End*/


//-- Tratamento da HQ-CD: se Dipromed-Mtz, somente listar dados a partir de 01/05/2011 => Daniel Leme: 05/05/2011
If _cEmpresa + _cFilial == "0101"
	cQuery +=  " AND D2_EMISSAO >= '20110501'"
EndIf

If lTecnico
	cQuery   += "   AND Right(Left(D2_EMISSAO,6),2) IN ('"+StrTran(AllTrim(cTrimestre),"/","','")+"') "
EndIf

If !Empty(cForDe) // MCVN - 26/07/10
	If cForDe $ "000851/051508" //C๓digos do fornecedor HQ
		cQuery += " AND D2_FORNEC IN ('000851','051508') "
	ElseIf cForDe $ "000338/100015" //C๓digos do fornecedor ROCHE  //MCVN 16-06-2011
		cQuery += " AND D2_FORNEC IN ('000338','100015') "
	Else
		cQuery += " AND D2_FORNEC = '" + cForDe + "'"
	Endif
Endif
//cQuery   += "   AND D2_FORNEC  >= '"+cForDe+"' "
//cQuery   += "   AND D2_FORNEC  <= '"+cForAte+"' "
If Upper(_cDipUsr) $ cUserTec  //MCVN - 10/05/09 Filtrando fornecedores quando usuแrios estiver no parโmetro MV_USERTEC
	cQuery   += "   AND D2_FORNEC in ('000041','000609','000334','000338','000183','000996','000997','000851','051508','000647','100015') " //ROCHE, 3M e AMCOR
Endif
cQuery   += "   AND D2_COD     >= '"+cProDe+"' "
cQuery   += "   AND D2_COD     <= '"+cProAte+"' "
cQuery   += "   AND SD2.D_E_L_E_T_ = '' "

//-- Daniel Leme - 30/06/2011
If U_ListOper() != ''
	cQuery += " AND C5_OPERADO IN( " + U_ListOper("2")+ " )"
EndIf

If !Empty(MV_PAR02)
    //cQuery += " AND (F2_VEND1 = "+MV_PAR02+" AND (F2_VEND2 = ' ' OR D2_FORNEC <> '000996') "
	//cQuery += "	OR (F2_VEND2 = "+MV_PAR02+" AND D2_FORNEC IN ('000366','000446','000996'))) "
	If lCarteira
		cQuery += " AND A3_COD  = '" + MV_PAR02 + "'"// JBS 16/07/2010
	Else
		cQuery += "	AND (CASE WHEN F2_VEND2 <> ' ' AND D2_FORNEC IN('000366','000446','000996') THEN F2_VEND2 ELSE F2_VEND1 END) = '" + MV_PAR02 + "'"
	Endif	
EndIf
//--------------------------------------------------------------------------------------------------------------------------
// Grupo de Campos
//--------------------------------------------------------------------------------------------------------------------------
cQuery   += " GROUP BY D2_CLIENTE, "
cQuery   += " D2_LOJA, "
cQuery   += " A1_NOME, "
cQuery   += " A1_MUN, "
cQuery   += " A1_EST, "
If lCarteira  // JBS 19/07/2010 !Empty(Alltrim(cVenDe))// JBS 16/07/2010
	cQuery   += " A1_VEND, "
Else
	cQuery   += " F2_VEND1, "
Endif
cQuery   += " A3_NOME, "
cQuery   += " A3_NREDUZ, " //RBORGES - 19/12/2013
cQuery   += " A1_PRICOM, "
cQuery   += " A1_ULTCOM, "
cQuery   += " A1_HPAGE, "
cQuery   += " A1_OBSERV, "
cQuery   += " A1_SATIV1, "
cQuery   += " A1_SATIV8, "
cQuery   += " X5_DESCRI, "
//cQuery   += "          LEFT(D2_EMISSAO,6), "
cQuery   += " D2_COD, "
// Eriberto 24/08/10 cQuery   += "          D2_CUSDIP, "
cQuery   += " B1_DESC, "
cQuery   += " A1_VENDKC, "
cQuery   += " A1_TECNICO, "
cQuery   += " A1_TECN_3, "
cQuery   += " A1_TECN_A, "
cQuery   += " A1_TECN_R, "
cQuery   += " A1_TECN_C, "//Borges 
cQuery   += " A1_XTEC_SP, "                
cQuery   += " A1_XTEC_MA, "                
cQuery   += " A1_XTEC_HQ, "                
cQuery   += " A1_CGC, "
cQuery   += " A1_INSCR, "
cQuery   += " A1_GRPVEN, "
cQuery   += " D2_FORNEC, "
cQuery   += " F2_VEND2 "

Return(cQuery)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณfQuery02  บAutor  ณJailton B Santos-JBSบ Data ณ 22/03/2010  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Esta Query apura os falores faturado no pedido pela empresaบฑฑ
ฑฑบ          ณ informada como parametro, Retorna Query QRY1.              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Especifico - Faturamento - DIPROMED.                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function fQuery02( _cEmpresa ,_cFilial)

Local nId     := 0
Local cQuery  := ""
Local cFilSB1 := cFilAnt//fFilial(_cEmpresa,'SB1',_cFilial)
Local cFilSD1 := cFilAnt//fFilial(_cEmpresa,'SD1',_cFilial)
Local cFilSD2 := cFilAnt//fFilial(_cEmpresa,'SD2',_cFilial)
Local cFilSF2 := cFilAnt//fFilial(_cEmpresa,'SF2',_cFilial)
Local cFilSF4 := cFilAnt//fFilial(_cEmpresa,'SF4',_cFilial)
Local cFilSX5 := cFilAnt//fFilial(_cEmpresa,'SX5',_cFilial)
Local _x

ProcRegua(500)
For _x := 1 to 150
	IncProc( "Processando...VENDAS ")
Next

cQuery   := "SELECT SUBSTRING(D1_DTDIGIT,1,6) D1_DTDIGIT, "
cQuery   += " A1_NOME, "
cQuery   += " A1_EST, "
cQuery   += " A1_PRICOM, "
cQuery   += " A1_ULTCOM, "
cQuery   += " A1_HPAGE, "
cQuery   += " A1_SATIV1, "
cQuery   += " A1_SATIV8, "

If lCarteira  // JBS 19/07/2010 If !Empty(Alltrim(cVenDe))
	cQuery   += " A1_VEND  VENDEDOR, "
Else
	cQuery   += " F2_VEND1 VENDEDOR, "
Endif

cQuery   += " A1_VENDKC, "
cQuery   += " A1_TECNICO, "
cQuery   += " A1_TECN_3, "
cQuery   += " A1_TECN_A, "
cQuery   += " A1_TECN_R," 
cQuery   += " A1_TECN_C," //borges 
cQuery   += " A1_XTEC_SP, "                
cQuery   += " A1_XTEC_MA, "                
cQuery   += " A1_XTEC_HQ, "                
cQuery   += " A1_MUN, "
cQuery   += " X5_DESCRI, "
cQuery   += " SUM(D2_CUSDIP*D2_QUANT) D2_CUSDIP, "
cQuery   += " SUM(D1_QUANT) D2_QUANT,  "  //  Deixei D2_QUANT para ficar igual ao processamento de vendas
cQuery   += " SUM(D1_TOTAL) D2_TOTAL,  "  //  Deixei D2_TOTAL para ficar igual ao processamento de vendas
cQuery   += " B1_DESC, "
cQuery   += " A1_CGC, "
cQuery   += " A1_INSCR, D2_CLIENTE, D2_LOJA, D2_COD, A3_NOME,A3_NREDUZ,  "
cQuery   += " D2_FORNEC, "
cQuery   += " F2_VEND2 "

cQuery   += "  FROM SD1" + _cEmpresa + " SD1 "

cQuery   += " INNER JOIN SD2" + _cEmpresa + " SD2 ON D2_FILIAL = D1_FILIAL "
cQuery   += " AND D2_DOC   = D1_NFORI "
cQuery   += " AND D2_SERIE = D1_SERIORI "
cQuery   += " AND D2_ITEM  = D1_ITEMORI "
If !Empty(cForDe) // MCVN - 26/07/10
	If cForDe $ "000851/051508" //C๓digos do fornecedor HQ
		cQuery += " AND D2_FORNEC IN ('000851','051508') "
	ElseIf cForDe $ "000338/100015" //C๓digos do fornecedor ROCHE  //MCVN 16-06-2011
		cQuery += " AND D2_FORNEC IN ('000338','100015') "
	Else
		cQuery +=" AND D2_FORNEC = '" + cForDe + "'"
	Endif
Endif
//cQuery   += "                       AND D2_FORNEC  >= '"+cForDe+"' "       // JBS 27/04/2010 - Mesma regra de saida para devolu็๕es
//cQuery   += "                       AND D2_FORNEC  <= '"+cForAte+"' "      // JBS 27/04/2010 - Mesma regra de saida para devolu็๕es

If Upper(_cDipUsr) $ cUserTec  //MCVN - 10/05/09 Filtrando fornecedores quando usuแrios estiver no parโmetro MV_USERTEC
	cQuery   += " AND D2_FORNEC in ('000041','000609','000334','000338','000183','000996','000997','000851','051508','000647','100015') " //ROCHE, 3M e AMCOR
Endif
cQuery   += "  AND SD2.D_E_L_E_T_ = '' "
cQuery   += " INNER JOIN SA1010 SA1 ON A1_FILIAL = '" + xFilial('SA1') + "' "
cQuery   += "  AND A1_COD = D1_FORNECE "
cQuery   += "  AND A1_LOJA = D1_LOJA "

If lTecnico
	
	cQuery   += " AND Right(Left(D1_DTDIGIT,6),2) IN ('"+StrTran(AllTrim(cTrimestre),"/","','")+"') "
	
	Do Case
		Case nTecnico==1 .And. (nTecSA3 = 5 .Or. nTecSA3 = 1) // T้cnico KC
			cQuery   += " AND A1_TECNICO = '" + cTecnico +"' "
			cForDe  := "000366"
		Case nTecnico==2 .And. (nTecSA3 = 5 .Or. nTecSA3 = 2) // T้cnico AMCOR
			cQuery   += " AND A1_TECN_A  = '" + cTecnico +"' "
			cForDe  := "000183"
		Case nTecnico==3 .And. (nTecSA3 = 5 .Or. nTecSA3 = 3) // T้cnico 3M
			cQuery   += " AND A1_TECN_3  = '" + cTecnico +"' "
			cForDe  := "000041"
		Case nTecnico==4 .And. (nTecSA3 = 5 .Or. nTecSA3 = 4) // T้cnico ROCHE
			cQuery   += " AND A1_TECN_R  = '" + cTecnico +"' "
			cForDe  := "000338"
		Case nTecnico==4 .And. (nTecSA3 = 5 .Or. nTecSA3 = 4) // T้cnico Convatec
			cQuery   += " AND A1_TECN_C  = '" + cTecnico +"' "
			cForDe  := "000647"
		Case nTecnico==4 .And. (nTecSA3 = 5 .Or. nTecSA3 = 4) // T้cnico SP
			cQuery   += " AND A1_XTEC_SP  = '" + cTecnico +"' "
			cForDe  := "000996"
		Case nTecnico==4 .And. (nTecSA3 = 5 .Or. nTecSA3 = 4) // T้cnico MA
			cQuery   += " AND A1_XTEC_MA  = '" + cTecnico +"' "
			cForDe  := "000997"
		Case nTecnico==4 .And. (nTecSA3 = 5 .Or. nTecSA3 = 4) // T้cnico HQ
			cQuery   += " AND A1_XTEC_HQ  = '" + cTecnico +"' "
			cForDe  := "000851"
	EndCase
Endif

If Empty(cGrpCli)
	cQuery   += " AND A1_COD BETWEEN '"+cCliDe+"' AND '"+cCliAte+"' "
Else
	cQuery  += " AND A1_GRPVEN = '" +cGrpCli+"'"
EndIf

//Rafael Moraes Rosa - 16/03/2023 - INICIO
If !Empty(cTec3M)
	cQuery   += " AND A1_TECN_3 = '"+cTec3M+"' 
EndIf
//Rafael Moraes Rosa - 16/03/2023 - FIM


cQuery   += " AND SA1.D_E_L_E_T_ = '' "
//--------------------------------------------------------------------------------------------------------------------------
// Cria relacionamento do cliente com a descricao da atividade
//--------------------------------------------------------------------------------------------------------------------------
cQuery   += " Left JOIN SX5" + _cEmpresa + " SX5 ON X5_FILIAL = '" + cFilSX5 + "' "
cQuery   += " AND X5_CHAVE  = A1_SATIV1 "
cQuery   += " AND X5_TABELA = 'T3' "
cQuery   += " AND SX5.D_E_L_E_T_ = '' "
//--------------------------------------------------------------------------------------------------------------------------
// Cria o relacionamento entre os itens do SD2 com as notas fiscais
//--------------------------------------------------------------------------------------------------------------------------
cQuery   += "INNER JOIN SF2" + _cEmpresa + " SF2 ON  F2_FILIAL = '"+cFilSF2+"'
cQuery   += " AND F2_DOC = D2_DOC "
cQuery   += " AND F2_SERIE = D2_SERIE "
cQuery   += " AND F2_VEND1 <> '006874' "
cQuery   += " AND SF2.D_E_L_E_T_ =  '' "
//--------------------------------------------------------------------------------------------------------------------------
// Cria o relacionamento ente o vendedor nas notas  fiscais e o cadastro de vendedores
//--------------------------------------------------------------------------------------------------------------------------
cQuery   += "INNER JOIN " + RetSqlName('SA3') + " SA3 ON  A3_FILIAL = '" + xFilial('SA3') + "'  "
If U_ListVend() == ''
	If !Empty(Alltrim(cVenDe))
		cQuery   += " AND A3_COD  = '"+cVenDe+"' "
	EndIf
	If lCarteira  // JBS 19/07/2010
		cQuery   += " AND A3_COD  = A1_VEND " // JBS 16/07/2010
	Else
		cQuery   += " AND (A3_COD = (CASE WHEN F2_VEND2 <> ' ' AND D2_FORNEC IN('000366','000446','000996') THEN F2_VEND2 ELSE F2_VEND1 END))" // JBS 16/07/2010
	Endif
Else
	//cQuery   += "                      AND A3_COD "+U_ListVend()+" "
	cQuery   += " AND A3_COD IN("+U_ListVend("2")+") "
	If !Empty(cVenDe)
		cQuery   += " AND A3_COD  = '"+cVenDe+"' "
	EndIF
	If lCarteira  // JBS 19/07/2010
		cQuery   += " AND A3_COD  = A1_VEND " // JBS 16/07/2010
	Else
		cQuery   += " AND (A3_COD = (CASE WHEN F2_VEND2 <> ' ' AND D2_FORNEC IN('000366','000446','000996') THEN F2_VEND2 ELSE F2_VEND1 END))" // JBS 16/07/2010
	EndIf
EndIf
cQuery   += " AND SA3.D_E_L_E_T_ = ''  "
//--------------------------------------------------------------------------------------------------------------------------
// Cria o relacionamento do Produto no SD2 com o Cadastro de Produtp
//--------------------------------------------------------------------------------------------------------------------------
cQuery   += "INNER JOIN SB1" + _cEmpresa + " SB1 ON  B1_FILIAL = '"+cFilSB1+"' "
cQuery   += " AND B1_COD = D2_COD "
cQuery   += " AND SB1.D_E_L_E_T_ =  '' "

cQuery   += " INNER JOIN SF4" + _cEmpresa + " SF4 ON F4_FILIAL = '" + cFilSF4 + "' "
cQuery   += "  AND F4_CODIGO = D1_TES "
cQuery   += "  AND F4_DUPLIC  = 'S' "
cQuery   += "  AND SF4.D_E_L_E_T_ = '' "

cQuery   += " WHERE D1_FILIAL = '" + cFilSD1 + "' "

//If Empty(mv_par14) .and. Empty(mv_par15)
	cQuery   += " AND SUBSTRING(D1_DTDIGIT,1,6) BETWEEN '" + _nParIni + "' AND '" + _nParFim + "' "
//Else
//	cQuery   += "AND D1_DTDIGIT BETWEEN '" + DTOS(mv_par14) + "' AND '" + DTOS(mv_par15) + "' "
//End

//-- Tratamento da HQ-CD: se Dipromed-Mtz, somente listar dados a partir de 01/05/2011 => Daniel Leme: 05/05/2011
If _cEmpresa + _cFilial == "0101"
	cQuery +=  " AND D1_DTDIGIT >= '20110501'"
EndIf

cQuery   += " AND D1_TIPO    = 'D' "
cQuery   += " AND D1_COD     >= '"+cProDe+"' "     // MVCN 26/04/2010 - Aplica็ใo da regra de saida
cQuery   += " AND D1_COD     <= '"+cProAte+"' "    // MVCN 26/04/2010 - Aplica็ใo da regra de saida
cQuery   += " AND SD1.D_E_L_E_T_ <> '*'"

//-- Daniel Leme - 30/06/2011
If U_ListOper() != ''
	cQuery += " AND EXISTS( SELECT TOP 1 'A' FROM SC5" + _cEmpresa + " SC5 "
	cQuery += "  WHERE"
	cQuery += "   SC5.C5_FILIAL      = SD2.D2_FILIAL"
	cQuery += "   AND SC5.C5_NUM     = SD2.D2_PEDIDO"
	cQuery += "   AND SC5.D_E_L_E_T_ = ' ' "
	cQuery += "   AND SC5.C5_OPERADO  IN( " + U_ListOper("2")

	If nSetor == 4 // LICITAวOES - WCS - 23/07/2021
		cQuery   += " And U7_POSTO = '03' "                                // Licitacoes JBS 30/07/2010
	EndIF
	cQuery += " ) )"

EndIf    

If nSetor == 1 // APOIO
	cQuery += " AND A3_TIPO = 'E'	"
ElseIf nSetor == 2 // CALL CENTER
	cQuery += " AND A3_TIPO = 'I' "
EndIf

If !Empty(MV_PAR02)
    //cQuery += " AND (F2_VEND1 = "+MV_PAR02+" AND (F2_VEND2 = ' ' OR D2_FORNEC <> '000996') "
	//cQuery += "	OR (F2_VEND2 = "+MV_PAR02+" AND D2_FORNEC IN ('000366','000446','000996'))) "
	If lCarteira
		cQuery += " AND A3_COD  = '" + MV_PAR02 + "'"// JBS 16/07/2010
	Else	
		cQuery += "	AND (CASE WHEN F2_VEND2 <> ' ' AND D2_FORNEC IN('000366','000446','000996') THEN F2_VEND2 ELSE F2_VEND1 END) = '" + MV_PAR02 + "'"
	EndIf	
EndIf

cQuery   += " GROUP BY SUBSTRING(D1_DTDIGIT,1,6), "
cQuery   += " A1_NOME, "
cQuery   += " A1_EST, "
cQuery   += " A1_MUN, "
cQuery   += " A1_PRICOM, "
cQuery   += " A1_ULTCOM, "
cQuery   += " A1_HPAGE, "
cQuery   += " A1_SATIV1, "
cQuery   += " A1_SATIV8, "
If lCarteira  // JBS 19/07/2010 If !Empty(Alltrim(cVenDe))
	cQuery   += " A1_VEND, "
Else
	cQuery   += " F2_VEND1, "
Endif
cQuery   += " A1_VENDKC, "
cQuery   += " A1_TECNICO, "
cQuery   += " A1_TECN_3, "
cQuery   += " A1_TECN_A, "
cQuery   += " A1_TECN_R, "
cQuery   += " A1_TECN_C, "//borges
cQuery   += " A1_XTEC_SP, "                
cQuery   += " A1_XTEC_MA, "                
cQuery   += " A1_XTEC_HQ, "                
cQuery   += " X5_DESCRI, "
cQuery   += " A1_CGC, "
cQuery   += " B1_DESC, "
cQuery   += " A1_INSCR, D2_CLIENTE, D2_LOJA, D2_COD, A3_NOME,A3_NREDUZ, "
cQuery   += " D2_FORNEC, "
cQuery   += " F2_VEND2 "
Memowrite('DIR026A.SQL',cQuery)

Return(cQuery)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณfFilial() บAutor  ณJailton B Santos-JBSบ Data ณ 22/03/2010  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFaz o tratamento para achar a filial para empresa para a    บฑฑ
ฑฑบ          ณqual ira' abrir a tabela informada.                         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametro ณ_cEmpresa: Empresa na qual queremos coletar dados           บฑฑ
ฑฑบ          ณ_cTabela : Nome da tabela da qual queremos coletar dados    บฑฑ
ฑฑบ          ณ_cFilial : Se a tabela for exclusiva, esta eh a filial da   บฑฑ
ฑฑบ          ณ           qual eh preciso coletar dados.                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Especifico - Faturamento - DIPROMED                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function fFilial(_cEmpresa,_cTabela,_cFilial)

Local _cNewFilial := Space(2)
/*Local _cFile      := 'SX2'+_cEmpresa
Local _cFileIdx   := _cFile

If Select("SX2_2") = 0
	MsOpEndbf(.T.,"DBFCDX",_cFile,"SX2_2",.T.,.F.) //Ajustado chamada do dbfcdxads para dbfcdx - Felipe Duran
EndIf

SX2_2->( DbSetOrder(1))
If SX2_2->( DbSeek(_cTabela) )
	If SX2_2->X2_MODO = 'E'
		_cNewFilial := _cFilial
	EndIf
Else
	_cNewFilial := xFilial(_cTabela)
EndIf*/

Return(_cNewFilial)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณfQuery04() บAutor  ณMaximo Canuto - MCVNบ Data ณ 01/03/2011 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณQuery para buscar a carteira toda do cliente   			  บฑฑ
ฑฑบ          ณSe UserTec estiver preenchido, filtrar carteira por t้cnica บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Especifico - Faturamento - DIPROMED                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function fQuery04()
Local _x

ProcRegua(300)
For _x := 1 to 200
	IncProc("Processando carteira. . . ")
Next

QRY4 := "SELECT A1_COD, "
QRY4 += "       A1_LOJA, "
QRY4 += "       A1_NOME, "
QRY4 += "       A1_MUN, "
QRY4 += "       A1_EST, "
QRY4 += "       A1_VEND VENDEDOR,"
QRY4 += "       A1_PRICOM, "
QRY4 += "       A1_ULTCOM, "
QRY4 += "       A1_HPAGE, "
QRY4 += "       A1_SATIV1, "
QRY4 += "       A1_SATIV8, "
QRY4 += "       A1_OBSERV, "
QRY4 += "       X5_DESCRI, "
QRY4 += "       A1_CGC,   "
QRY4 += "       A1_INSCR,  "
QRY4 += "       A1_GRPVEN, "
QRY4 += "       A1_VENDKC, "
QRY4 += "       A1_TECNICO, "
QRY4 += "       A1_TECN_3, "
QRY4 += "       A1_TECN_A, "
QRY4 += "       A1_TECN_R, "
QRY4 += "       A1_TECN_C," 
QRY4 += "       A1_XTEC_SP, "
QRY4 += "       A1_XTEC_MA, "
QRY4 += "       A1_XTEC_HQ "
// Andre Mendes - [OBIFY] - 23/02/2022 - Ticket 4333

/*
QRY4 += " FROM "
QRY4 += RetSQLName("SA1") + ", "
QRY4 += RetSQLName("SX5") + ", "
QRY4 += RetSQLName("SA3")
*/

QRY4 += " FROM "
QRY4 += "    "+RetSQLName("SA1") + " SA1		INNER JOIN "
QRY4 += "    "+RetSQLName("SA3") + " SA3 ON "
QRY4 += " 			A1_VEND = A3_COD	LEFT JOIN "
QRY4 += "    "+RetSQLName("SX5") + " SX5 ON "
QRY4 += " 		X5_CHAVE = A1_SATIV1	AND  "
QRY4 += " 		SX5.D_E_L_E_T_ = ''		AND  "
QRY4 += " 		X5_TABELA = 'T3'  "

QRY4 += " WHERE SA1.D_E_L_E_T_ = ''"
//QRY4 += " AND " + RetSQLName("SX5") + ".D_E_L_E_T_ = ''"
QRY4 += " AND SA3.D_E_L_E_T_ = ''"
//QRY4 += " AND X5_TABELA = 'T3'"
//QRY4 += " AND X5_CHAVE =* A1_SATIV1 "

//QRY4 += " AND A1_VEND = A3_COD "

If !Empty(cGrpCli)
	QRY4 += " AND A1_GRPVEN = '" +cGrpCli+"'"
EndIf

If U_ListVend() != ''
	//QRY4 += " AND A1_VEND " + U_ListVend()
	QRY4 += " AND A1_VEND IN( " + U_ListVend("2") + " ) "
EndIf

If !Empty(cVenDe) // VENDEDOR
	QRY4 += " AND A1_VEND = '" + cVenDe + "'"
Else
	If nSetor == 1 // APOIO
		QRY4 += " AND A3_TIPO = 'E'	"
	ElseIf nSetor == 2 // CALL CENTER
		QRY4 += " AND A3_TIPO = 'I' "
	EndIf
EndIf

If Upper(_cDipUsr) $ cUserTec
	If cForDe $ '000041/000609/000334/000338/000183/000996/000997/000851/051508/100015/000647'  
		If cForDe $ '000041/000609' 
			QRY4 += " AND A1_TECN_3  <> '' "	
		ElseIf cForDe $ '000334/000338/100015' 
			QRY4 += " AND A1_TECN_R  <> '' "	     
		ElseIf cForDe = '000183' 
			QRY4 += " AND A1_TECN_A  <> '' "	
		ElseIf cForDe = '000647' 
			QRY4 += " AND A1_TECN_C  <> '' "				
		ElseIf cForDe = '000996' 
			QRY4 += " AND A1_XTEC_SP  <> '' "				
		ElseIf cForDe = '000997' 
			QRY4 += " AND A1_XTEC_MA  <> '' "									
		ElseIf cForDe = '000851' 
			QRY4 += " AND A1_XTEC_HQ  <> '' "				
		Else
			QRY4 += " AND A1_TECNICO <> '' "	
		EndIf  		
	Endif
Endif

QRY4 += " ORDER BY A1_COD, A1_LOJA "

cQuery := ChangeQuery(QRY4)

dbUseArea(.T., "TOPCONN", TCGenQry(,,QRY4), 'QRY4', .F., .T.)
memowrite('DIPR26A_SA1_'+SM0->M0_CODIGO+'0_'+SM0->M0_CODFIL+'.SQL',QRY4)  // JBS 29/07/2010

Return()
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDIPR026   บAutor  ณMicrosiga           บ Data ณ  03/21/13   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function DipRetTec(nTec)
Local cTec	 := ""
DEFAULT nTec := 0      

Do Case
	Case nTec == 1  
		cTec :=	"KC"
	Case nTec == 2
		cTec :=	"AMCOR"
	Case nTec == 3
		cTec := "3M'
	Case nTec == 4
		cTec := "ROCHE"
	Case nTec == 5
		cTec := "CONVATEC"
	Case nTec == 6
		cTec := "STERI PACK"
	Case nTec == 7
	    cTec := "MEDICAL ACTION"
	Case nTec == 8
		cTec := "HEALTH QUALITY"
End Case

Return cTec

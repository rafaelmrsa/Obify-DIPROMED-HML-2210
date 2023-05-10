/*====================================================================================\
|Programa  | DIPR026       | Autor | Eriberto Elias             | Data | 29/05/2003   |
|=====================================================================================|
|DescriÁ„o | Faturamento por cliente e produto mes a mes e total ano                  |
|          |                                                                          |
|          |                                                                          |
|=====================================================================================|
|Sintaxe   | DIPR026                                                                  |
|=====================================================================================|
|Uso       | Especifico DIPROMED                                                      |
|=====================================================================================|
|........................................HistÛrico....................................|
|Rafael    | DD/MM/AA - DescriÁ„o                                                     |
|Eriberto  | DD/MM/AA - DescriÁ„o                                                     |
|Eriberto  | 15/04/05 - Inclusao no arquivo dos campos A1_EST, A1_MUN, A1_SATIV1      |
|          |            Inclusao da pergunta para o setor                             |
|Maximo    | 11/04/07 - Inclus„o da media da quantidade e media do valor (M S)        |
|Maximo    | 24/04/07 - Inclus„o do campo X5_DESCRI e separaÁ„o do cÛdigo e nome de   |
|          | de todos os vendedores e tÈcnicos                                        |
|Maximo    | 24/05/07 - Inclus„o do par‚metro para filtrar por vendedor               |
|Maximo    | 15/08/07 - Inclus„o do CAMPO TECNICO ROCHE NO ARQUIVO                    |
|Daniel    | 10/10/07 - Inclus„o do filtro por grupo de clientes                      |
|          |          - Tratamento do Filtro de Vendedores no Relatorio               |
|Maximo    | 04/10/07 - Inclus„o do filtro por grupo de clientes                      |
|          |          - Tratamento do Filtro de Vendedores no Relatorio               |   
|Maximo    | 09/08/08 - Inclus„o de opÁ„o p/ n„o mostrar valores(Vari·vel lNoShowVal) |
|Maximo    | 19/09/08 - Inclus„o de opÁ„o p/ gerar arquivo de faturamento por tÈcnico |
						em DBF e  possibilita o envio por e-mail.                     | 
|Maximo    | 29/09/09 - Tratamento para Empresa HQ/VendedorHQ                         |  
|Maximo    | 26/07/10 - Customizacao para filtrar pelos dois fornecedores HQ que s„o: |
|MCVN      |            (000851 e 051508) quando um deles for solicitado no oMV_PAR09 |
|Maximo    | 02/03/11 - Inclus„o da pergunta CARTEIRA TODA e traramento para tÈcnico  |
\====================================================================================*/  
#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "AP5MAIL.CH"
#INCLUDE "TOPCONN.CH"                                                                         
#INCLUDE "TBICONN.CH"
#INCLUDE "FILEIO.CH"

User Function DIPR026()                            
If cEmpAnt == '04' .and. cFilAnt == '01' 
    fDipR026() // Versao Anterior, para rodar apenas para a Health Quality (Matriz)
Else                                                                                 
    U_DipR026a() // Chama a versao MultyEmpresas (Dipromed CD e Health Quality CD) 
EndIf
Return(Nil)    
/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥fDipR026()∫Autor  ≥Eriberto Elias      ∫ Data ≥ 01/08/2002  ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥ Versao do programa para rodar uma empresa, a matriz da     ∫±±
±±∫          ≥ Health Quality.                                            ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ Especifico - Dipromed - Faturamento                        ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Static Function fDipR026()

Local aObj:=Array(5) 
Local alCheck:={.f.,.f.,.f.}
Local bOk:={|| nOpcao:=1,oDlg:End()}
Local oDlg
Local oBt1
Local oBt2           
Local nOpcao      :=0
// V·ri·veis para geraÁ„o de arquivo dos TÈcnicos - MCVN 17/09/08
Local aObjTec:=Array(8) 
Local alCheckTec:={.f.,.f.,.f.,.f.,.f.,.f.,.f.,.f.}
Local bOk2:={|| nOpcao2:=1,oDlg2:End()}
Local oDlg2
Local oBt1_2
Local oBt2_2
Local nOpcao2  :=0 
Local cArquivo := ""                       
// Fim vari·veis TÈcnicos
Local _xArea      := GetArea()
Local _xAreaSA1   := SA1->(GetArea())
Local _xAreaSB1   := SB1->(GetArea())     
Local cUserAuth   := GETMV("MV_DIPR019")      
Local cUserAut    := GetMV("MV_URELFAT") // MCVN - 04/05/09 
Local bMes        := {|| If( cMes < '01' .or. cMes > '12',(Aviso('AtenÁ„o','MÍs Invalido. Informe mÍs de 01 a 12.',{'Ok'}),.F.),.T.)}  // JBS 13/04/2010 - Valida o Mes informado

Private cAno      := Space(04)
Private cMes      := Space(02) // JBS 13/04/2010
Private cGrpCli   := CriaVar("A1_GRPVEN",.F.)
Private cCliDe    := Space(06)                                                                              
Private cCliAte   := Space(06)                                                                              
Private cForDe    := Space(06)                                                                              
Private cForAte   := Space(06)                                                                              
Private cProDe    := Space(06)
Private cProAte   := Space(06)
Private cVenDe    := Space(06)
Private cTecDe    := Space(06) // Arquivo TÈcnicos em DBF - MCVN - 17/09/08
Private cTecAte   := Space(06) // Arquivo TÈcnicos em DBF - MCVN - 17/09/08
Private lCriaArq  := .f.
Private lNoShowVal:= .f. // N„o mostra valores MCVN - 09/08/08
Private lTecnico  := .f. // Arquivo TÈcnicos em DBF - MCVN - 17/09/08   
Private lEnvMail  := .f. // Arquivo TÈcnicos em DBF - MCVN - 17/09/08   
Private lDevoluc  := .T. // Bot„o de OpÁ„o de Controle de devoluÁıes - JBS 27/04/2010 
Private lCarteira := .F. // Determina se o relatorio eh por carteira ou por vendas realizadas  // JBS 19/07/2010
Private nSetor    := 4    
Private nTecnico  := 1   // 1=KC, 2=Amcor, 3=3M, 4=Roche - Arquivo TÈcnicos em DBF - MCVN - 17/09/08                                                                      
Private cOper     := Space(120)
Private cTecnico  := ""    
Private cTecFornec:= ""  
Private cUserTec  := GetMV("MV_USERTEC")// MCVN - 04/05/09 
Private cDipr026  := GetMV("MV_DIPR026")// MCVN - 04/05/09 
Private cDipr026A := GetMV("MV_DIPR26A")// JBS - 08/07/2010 
Private cVendInt  := GetMV("MV_DIPVINT")// MCVN - 06/05/09
Private cVendExt  := GetMV("MV_DIPVEXT")// MCVN - 06/05/09   
Private cSHWCUST  := GetMV("MV_SHWCUST")// MCVN - 13/11/09   
//Private cDiretorio := "\RELATO\JPEG\"
Private cDestino  := "C:\EXCELL-DBF\"   
Private oDevoluc   // Bot„o de OpÁ„o de Controle de devoluÁıes - JBS 27/04/2010 
Private oCarteira  // Objeto do check box que determina se o relatorio eh por carteira ou por vendas realizadas.// JBS 19/07/2010
Private _nMesIni   := "" // JBS 13/04/2010
Private _nParIni   := "" // JBS 13/04/2010
Private _nParFim   := "" // JBS 13/04/2010
Private _nAnoFim   := "" // JBS 13/04/2010
Private _nMesFim   := "" // JBS 13/04/2010  
Private _cFilSA3   := xFilial("SA3")  // MCVN 02/03/2011
Private nToQto     := 0
Private aQtdMes    := {}//Giovani Zago 10/10/11
Private cPerg  	   := U_FPADR( "DIPR26X","SX1","SX1->X1_GRUPO"," " ) //Criado por Sandro em 19/11/09. 
Private _cDipUsr   := U_DipUsr()
Private _aCampos   := {}
                             
// MCVN - 10/05/09    
If !(Upper(_cDipUsr) $ cUserAut .Or. Upper(_cDipUsr) $ cVendInt .or. Upper(_cDipUsr) $ cVendExt .or. Upper(_cDipUsr) $ cUserTec .or. Upper(_cDipUsr) $ cDipr026)// MCVN - 07/05/09
	Alert(Upper(_cDipUsr)+", vocÍ n„o tem autorizaÁ„o para utilizar esta rotina. Qualquer d˙vida falar com Eriberto!","AtenÁ„o")	
	Return()
Endif
                                         
U_DIPPROC(ProcName(0),_cDipUsr) // JBS 05/10/2005 - Gravando o nome do Programa no SZU

tamanho    := "G"
limite     := 220
titulo     := OemTOAnsi("Vendas por cliente/produto mes a mes com total do ano",72)
cDesc1     := (OemToAnsi("Este programa tem como objetivo emitir um relat¢rio",72))
cDesc2     := (OemToAnsi("de Faturamento por cliente.",72))
cDesc3     := (OemToAnsi(" ",72))
aReturn    := {"Bco A4", 1,"Faturamento", 1, 2, 1,"",1}
nomeprog   := "DIPR026"
nLastKey   := 0
lContinua  := .T.
lEnd       := .F.
li         := 67
wnrel      := "DIPR026"
M_PAG      := 1
cString    := "SD2"
_cArqTrb   := ''


SX1->(DipPergDiverg(.t.)) // Verifica se existe o no SX1 o "DIPR42". Retorna os Valores ou cria

If !Pergunte(cPerg,.T.)
	Return(.t.)
EndIf               

cMes      := SubStr(MV_PAR01,01,02)
cAno      := SubStr(MV_PAR01,03,04)
cVenDe    := MV_PAR02                                                                                                                                                         
lCriaArq  := MV_PAR03 == 1
nSetor    := MV_PAR04
cForDe    := MV_PAR05                                                                            
cGrpCli   := MV_PAR06
lCarteira := MV_PAR07 == 1
cCliDe    := MV_PAR08                                                                              
cCliAte   := MV_PAR09                                                                              
cProDe    := MV_PAR10                                                                              
cProAte   := MV_PAR11  
lNoShowVal:= MV_PAR12 == 2  
lCartToda := MV_PAR13 == 2

/*
Define msDialog oDlg title OemToAnsi('Faturamento por cliente') From 0,0 TO 23,38
@ 002,002 to 170,149 pixel
@ 010,010 say 'Ano ' pixel
@ 010,089 say 'MÍs ' pixel  // JBS 12/04/2010
@ 022,010 say 'Grp. Cliente' pixel
@ 032,010 say 'Cliente de' pixel
@ 032,089 say 'AtÈ' pixel
@ 042,010 say 'Fornecedor '  pixel
//@ 042,089 say 'AtÈ' pixel
@ 052,010 say 'Produto de' pixel
@ 052,089 say 'AtÈ' pixel         
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
@ 080,089 checkbox oTecnico  var lTecnico    PROMPT 'TÈcnicos'         size 050,008                                      
@ 090,010 checkbox oShowVal  var lNoShowVal  PROMPT 'N„o Mostra Valor' size 110,008 
@ 090,089 checkbox oDevoluc  var lDevoluc    PROMPT 'Cons.Devol.Periodo' size 110,008 
@ 100,089 checkbox oCarteira var lCarteira   PROMPT 'Por Carteira'       size 110,008 
@ 100,010 checkbox aObj[1]   var alCheck[1]  PROMPT 'Apoio'       size 030,008 on change DP26SeleRel(1,aObj,alCheck)
@ 110,010 checkbox aObj[2]   var alCheck[2]  PROMPT 'Call Center' size 040,008 on change DP26SeleRel(2,aObj,alCheck)
@ 120,010 checkbox aObj[3]   var alCheck[3]  PROMPT 'Ambos'       size 030,008 on change DP26SeleRel(3,aObj,alCheck)
//@ 090,010 checkbox aObj[4]  var alCheck[4] PROMPT 'LicitaÁıes'   size 030,008 on change DP26SeleRel(4,aObj,alCheck)

@ 140,010 msget aObj[5] var cOper valid DP26SeleRel(5,aObj,alCheck) Size 130,08 pixel

Define sbutton oBt1 from 155,079 type 1 action Iif(Eval(bMes),(nOpcao := 1, oDlg:End()),) enable of oDlg
Define sbutton oBt2 from 155,110 type 2 action (nOpcao := 0, oDlg:End()) enable of oDlg

Activate Dialog oDlg Centered

If nOpcao = 0
	Return(.t.)
EndIf
*/
//----------------------------------------------------------------------------------------------------
// Determina os 12 meses que ser„o apresentados  - JBS 12/04/2010
//----------------------------------------------------------------------------------------------------
_nMesFim := cMes
_nAnoFim := cAno              

If Val(_nMesFim) == 12
	_nMesIni := 1
	_nAnoIni := Val(cAno)
Else
	_nMesIni := Val(_nMesFim) + 1
	_nAnoIni := Val(_nAnoFim) - 1
EndIf
_nParIni := AllTrim(Str(_nAnoIni))+AllTrim(StrZero(_nMesIni,2))
_nParFim := AllTrim(_nAnoFim)+AllTrim(_nMesFim) 

If lTecnico // Arquivo TÈcnicos em DBF - MCVN - 17/09/08
	
	// Limpa vari·veis para criar arquivo e n„o mostra valores.
	lCriaArq   := .f.
	lNoShowVal := .f.
	
	
	Define msDialog oDlg2 title OemToAnsi('TÈcnicos') From 0,0 TO 18,36
	@ 002,002 to 135,142 pixel
	@ 010,010 say 'TÈcnico de' pixel
	@ 022,010 say 'AtÈ' pixel
	@ 010,054 msget cTecDe   F3 'SA3' Size 030,08 pixel When lTecnico Valid !Empty(cTecDe)
	@ 020,054 msget cTecAte  F3 'SA3' Size 030,08 Pixel When lTecnico Valid !Empty(cTecAte)
	@ 050,010 checkbox aObjTec[1]  var alCheckTec[1]  PROMPT 'TÈcnico KC'       	size 050,008 on change DP26SeleTec(1,aObjTec,alCheckTec)
	@ 060,010 checkbox aObjTec[2]  var alCheckTec[2]  PROMPT 'TÈcnico AMCOR'    	size 050,008 on change DP26SeleTec(2,aObjTec,alCheckTec)
	@ 070,010 checkbox aObjTec[3]  var alCheckTec[3]  PROMPT 'TÈcnico 3M'       	size 050,008 on change DP26SeleTec(3,aObjTec,alCheckTec)
	@ 080,010 checkbox aObjTec[4]  var alCheckTec[4]  PROMPT 'TÈcnico Roche'    	size 050,008 on change DP26SeleTec(4,aObjTec,alCheckTec)
	@ 080,010 checkbox aObjTec[5]  var alCheckTec[5]  PROMPT 'TÈcnico Convatec' 	size 050,008 on change DP26SeleTec(5,aObjTec,alCheckTec)
	@ 080,010 checkbox aObjTec[6]  var alCheckTec[6]  PROMPT 'TÈcnico S.P.'     	size 050,008 on change DP26SeleTec(6,aObjTec,alCheckTec)
	@ 080,010 checkbox aObjTec[7]  var alCheckTec[7]  PROMPT 'TÈcnico M.A.'     	size 050,008 on change DP26SeleTec(7,aObjTec,alCheckTec)
	@ 080,010 checkbox aObjTec[8]  var alCheckTec[8]  PROMPT 'TÈcnico H.Q.'     	size 050,008 on change DP26SeleTec(8,aObjTec,alCheckTec)
	@ 100,010 checkbox oEnvmail    var lEnvMail       PROMPT 'Envia Email'			size 050,008
	Define sbutton oBt1_2 from 115,079 type 1 action (nOpcao2 := 1, oDlg2:End()) enable of oDlg2
	Define sbutton oBt2_2 from 115,110 type 2 action (nOpcao2 := 0, oDlg2:End()) enable of oDlg2
	
	Activate Dialog oDlg2 Centered

	If nOpcao2 = 0
		Return(.t.)
	EndIf

Endif


SX1->(DipPergDiverg(.f.))


If lTecnico  // Filtrando Tecnicos -> Arquivo TÈcnicos em DBF - MCVN - 17/09/08
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

		    cArquivo  := "\Excell-DBF\"+_cDipUsr+"-DIPR026-"+cTecFornec+"-"+cTecnico+".dbf" // MCVN - Ajusta local geraÁ„o arquivo pÛs virada de vers„o p 10 - 18/11/09
	    
	    	If Val(QRY2->A3_TECNICO) = nTecnico .Or. Val(QRY2->A3_TECNICO)=5	// Se a opÁ„o do fornecedor selecionado nos par‚metros est· de acordo com o cadastro - MCVN 17/09/08
				Processa({|lEnd| RunProc()},"Totalizando por cliente/produto...Tecnico-> "+cTecnico)
				If lEnvMail 
					DP26MailTec(QRY2->A3_COD,QRY2->A3_NOME,QRY2->A3_EMAIL,cArquivo)
		    	Endif	
			Endif
			QRY2->(DbSkip())
		EndDo       
		QRY2->(dbCloseArea())
	Else
	   MsgBox(_cDipUsr+" vocÍ n„o est· autorizada a gerar arquivo de faturamento dos tÈcnicos !"," Falar com TI!","Error")      
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

//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥ Se em disco, desvia para Spool                                            ≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
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
//Local cArqExcell:= GetSrvProfString("STARTPATH","")+"Excell-DBF\"+_cDipUsr+"-DIPR026-"+cTecFornec+"-"+cTecnico // Arquivo TÈcnicos em DBF - MCVN - 17/09/08   
Local cArqExcell:= "\Excell-DBF\"+_cDipUsr+"-DIPR026-"+cTecFornec+"-"+cTecnico // Arquivo TÈcnicos em DBF - MCVN - 17/09/08   - // MCVN - Ajusta local geraÁ„o arquivo pÛs virada de vers„o p 10 - 18/11/09
Local cTrimestre := DP26VerTri()  
Local aTmp := {}
Local wI,nI,_x


/* QUERY ANTIGA

QRY1 := "SELECT D2_CLIENTE, "
QRY1 += "       D2_LOJA, "
QRY1 += "       A1_NOME, "
QRY1 += "       A1_MUN, "
QRY1 += "       A1_EST, "  

If lCarteira  // JBS 19/07/2010 If !Empty(Alltrim(cVenDe))
	QRY1 += "       A1_VENDHQ VENDEDOR, "
Else
	QRY1 += "       F2_VEND1 VENDEDOR, "
Endif

QRY1 += "       A3_NOME, "  
QRY1 += "       A1_PRICOM, "
QRY1 += "       A1_ULTCOM, "
QRY1 += "       A1_HPAGE, "
QRY1 += "       A1_OBSERV, "
QRY1 += "       A1_SATIV1, "
QRY1 += "       X5_DESCRI, "
QRY1 += "       D2_COD, "
QRY1 += "       B1_DESC, "
QRY1 += "       A1_VENDKC, "
QRY1 += "       A1_TECNICO, "
QRY1 += "       A1_TECN_3, "
QRY1 += "       A1_TECN_A, "
QRY1 += "       A1_TECN_R, "
QRY1 += "       A1_TECN_C," 
QRY1 += "       A1_XTEC_SP, "
QRY1 += "       A1_XTEC_MA, "
QRY1 += "       A1_XTEC_HQ, "
QRY1 += "       A1_CGC, "
QRY1 += "       A1_INSCR, " 
QRY1 += "       A1_GRPVEN, " 
QRY1 += "       A1_SATIV8," // Giovani Zago 06/10/11
QRY1 += "       LEFT(D2_EMISSAO,6) D2_EMISSAO, "
QRY1 += "       SUM(D2_QUANT) D2_QUANT, "
QRY1 += "       SUM(D2_TOTAL) D2_TOTAL, "
QRY1 += "       SUM(D2_CUSDIP*D2_QUANT) D2_CUSDIP "
QRY1 += " FROM " + RetSQLName("SD2")+', '+ RetSQLName("SF4")+', '+ RetSQLName("SB1")+', '+ RetSQLName("SA1")+', '+ RetSQLName("SA3")+', '+ RetSQLName("SU7")+', '+ RetSQLName("SC5")+', '+ RetSQLName("SX5")+', '+ RetSQLName("SF2")
QRY1 += " WHERE "
QRY1 += RetSQLName('SD2')+".D_E_L_E_T_ <> '*' and "  
QRY1 += RetSQLName('SF2')+".D_E_L_E_T_ <> '*' and "
QRY1 += RetSQLName('SF4')+".D_E_L_E_T_ <> '*' and "
QRY1 += RetSQLName('SB1')+".D_E_L_E_T_ <> '*' and "
QRY1 += RetSQLName('SA1')+".D_E_L_E_T_ <> '*' and "
QRY1 += RetSQLName('SA3')+".D_E_L_E_T_ <> '*' and "
QRY1 += RetSQLName('SU7')+".D_E_L_E_T_ <> '*' and "
QRY1 += RetSQLName('SC5')+".D_E_L_E_T_ <> '*' and "
QRY1 += RetSQLName('SX5')+".D_E_L_E_T_ <> '*' and "
QRY1 += " LEFT(D2_EMISSAO,6) BETWEEN '" + _nParIni + "' AND '" + _nParFim + "' and "

If lTecnico
	QRY1 += "Right(Left("+RetSQLName('SD2')+".D2_EMISSAO,6),2) IN ('"+StrTran(AllTrim(cTrimestre),"/","','")+"') And "
	Do Case                    
		Case nTecnico==1 .And. (nTecSA3 = 5 .Or. nTecSA3 = 1) // TÈcnico KC  
			QRY1 += RetSQLName('SA1')+".A1_TECNICO = '" + cTecnico +"' And "
			cForDe  := "000366"
		Case nTecnico==2 .And. (nTecSA3 = 5 .Or. nTecSA3 = 2) // TÈcnico AMCOR
			QRY1 += RetSQLName('SA1')+".A1_TECN_A  = '" + cTecnico +"' And "
			cForDe  := "000183"
		Case nTecnico==3 .And. (nTecSA3 = 5 .Or. nTecSA3 = 3) // TÈcnico 3M
			QRY1 += RetSQLName('SA1')+".A1_TECN_3  = '" + cTecnico +"' And "
			cForDe  := "000041"
		Case nTecnico==4 .And. (nTecSA3 = 5 .Or. nTecSA3 = 4) // TÈcnico ROCHE
			QRY1 += RetSQLName('SA1')+".A1_TECN_R  = '" + cTecnico +"' And "
			cForDe  := "000338"  
		Case nTecnico==5 .And. (nTecSA3 = 5 .Or. nTecSA3 = 5) // TÈcnico Convatec
			QRY1 += RetSQLName('SA1')+".A1_TECN_C  = '" + cTecnico +"' And "
			cForDe  := "000647"
		Case nTecnico==6 .And. (nTecSA3 = 5 .Or. nTecSA3 = 6) // TÈcnico SP
			QRY1 += RetSQLName('SA1')+".A1_XTEC_SP  = '" + cTecnico +"' And "
			cForDe  := "000996"
		Case nTecnico==7 .And. (nTecSA3 = 5 .Or. nTecSA3 = 7) // TÈcnico MA
			QRY1 += RetSQLName('SA1')+".A1_XTEC_MA  = '" + cTecnico +"' And "
			cForDe  := "000997"
		Case nTecnico==8 .And. (nTecSA3 = 5 .Or. nTecSA3 = 8) // TÈcnico HQ
			QRY1 += RetSQLName('SA1')+".A1_XTEC_HQ  = '" + cTecnico +"' And "
			cForDe  := "000851"
	EndCase
Endif                          

If Empty(cGrpCli)
	QRY1 += RetSQLName('SD2')+".D2_CLIENTE >= '"+cCliDe+"' and "
	QRY1 += RetSQLName('SD2')+".D2_CLIENTE <= '"+cCliAte+"' and "
Else 
	QRY1 += RetSQLName('SA1')+".A1_GRPVEN  = '"+cGrpCli+"' and "                 
EndIf                              

If !Empty(cForDe)
	If cForDe $ "000851/051508" 
		QRY1 += RetSQLName('SD2')+".D2_FORNEC IN ('000851','051508') and "
	ElseIf cForDe $ "000338/100015"
		QRY1 += RetSQLName('SD2')+".D2_FORNEC IN ('000338','100015') and "		
	Else
		QRY1 += RetSQLName('SD2')+".D2_FORNEC  = '"+cForDe+"' and "
	Endif
Endif

If Upper(_cDipUsr) $ cUserTec
	QRY1 += RetSQLName('SD2')+".D2_FORNEC in ('000041','000609','000334','000338','000183','000996','000997','000851','051508','000647','100015','000517') and  " //ROCHE, 3M e AMCOR
Endif
QRY1 += RetSQLName('SD2')+".D2_COD     >= '"+cProDe+"' and "
QRY1 += RetSQLName('SD2')+".D2_COD     <= '"+cProAte+"' and "    

If U_ListVend() == '' 
	
	If !Empty(Alltrim(cVenDe))
		QRY1   += "                      A3_COD  = '"+cVenDe+"' and "
	EndIf 
	
	If lCarteira 
		QRY1   += "                      A3_COD  = A1_VENDHQ and " // JBS 16/07/2010
	Else
        QRY1   += "                      A3_COD  = F2_VEND1 and " // JBS 16/07/2010
	Endif
Else 
	
	QRY1 += "                      A3_COD "+U_ListVend("1")+" and "
	If !Empty(cVenDe)
		QRY1   += "                      A3_COD  = '"+cVenDe+"' and " 
	EndIf	
	
	If lCarteira 
		QRY1   += "                      A3_COD  = A1_VENDHQ and " // JBS 16/07/2010
	Else
        QRY1   += "                      A3_COD  = F2_VEND1 and " // JBS 16/07/2010
	EndIf
	
EndIf                   

QRY1 += RetSQLName('SD2')+".D2_FILIAL = '" + xFilial('SD2') + "' and "
QRY1 += RetSQLName('SD2')+".D2_FILIAL = "+RetSQLName('SF2')+".F2_FILIAL and "
QRY1 += RetSQLName('SD2')+".D2_DOC    = "+RetSQLName('SF2')+".F2_DOC and "
QRY1 += RetSQLName('SD2')+".D2_SERIE  = "+RetSQLName('SF2')+".F2_SERIE and "
QRY1 += RetSQLName('SD2')+".D2_TIPO    <> 'D' and "
QRY1 += RetSQLName('SD2')+".D2_TES = "+RetSQLName('SF4')+".F4_CODIGO and "
QRY1 += RetSQLName('SF4')+".F4_DUPLIC = 'S' and "
QRY1 += RetSQLName('SF4')+".F4_FILIAL = '" + xFilial('SF4') + "' and "
QRY1 += RetSQLName('SD2')+".D2_COD    = "+RetSQLName('SB1')+".B1_COD and "
QRY1 += RetSQLName('SB1')+".B1_FILIAL = '" + xFilial('SB1') + "' and "
QRY1 += RetSQLName('SD2')+".D2_CLIENTE= "+RetSQLName('SA1')+".A1_COD and "
QRY1 += RetSQLName('SD2')+".D2_LOJA   = "+RetSQLName('SA1')+".A1_LOJA"

QRY1 += " AND D2_FILIAL = C5_FILIAL"
QRY1 += " AND D2_PEDIDO = C5_NUM"
QRY1 += " AND C5_OPERADO = U7_COD"
QRY1 += " AND X5_FILIAL = '" + xFilial('SX5') + "'"
QRY1 += " AND A1_SATIV1 *= X5_CHAVE" // JBS 09/08/2010  - Incluido o left join (*=)
QRY1 += " AND X5_TABELA = 'T3'"

If nSetor == 1 .and. empty(cOper)// APOIO
	QRY1 += " AND (U7_VEND = 2"
	QRY1 += "  OR U7_COD  = '000015')"
ElseIf nSetor == 2 .and. empty(cOper) // CALL CENTER
	QRY1 += " AND U7_VEND = 1"
	QRY1 += " AND U7_COD <> '000015'"
ElseIf nSetor == 3 .and. empty(cOper) // LICITACOES BLANDINO 25/02/2021
	QRY1 += " AND U7_POSTO = '03'"
	QRY1 += " AND U7_COD = '000244'"
ElseIf !empty(cOper) // Operadores Selecionados pelo usuario
	QRY1 += " AND U7_COD IN ('"+StrTran(AllTrim(cOper),"/","','")+"')"	
EndIf   

QRY1   += " GROUP BY D2_CLIENTE, "
QRY1   += "          D2_LOJA, "
QRY1   += "          A1_NOME, "
QRY1   += "          A1_MUN, "
QRY1   += "          A1_EST, "
If lCarteira  // JBS 19/07/2010 !Empty(Alltrim(cVenDe))// JBS 16/07/2010
	QRY1   += "       A1_VENDHQ, "
Else
	QRY1   += "       F2_VEND1, "
Endif
QRY1   += "          A3_NOME, "  
QRY1   += "          A1_PRICOM, "
QRY1   += "          A1_ULTCOM, "
QRY1   += "          A1_HPAGE, "
QRY1   += "          A1_OBSERV, "
QRY1   += "          A1_SATIV1, "
QRY1   += "          X5_DESCRI, "
QRY1   += "          LEFT(D2_EMISSAO,6), "
QRY1   += "          D2_COD, "
QRY1   += "          D2_CUSDIP, "
QRY1   += "          B1_DESC, "
QRY1   += "          A1_VENDKC, "
QRY1   += "          A1_TECNICO, "
QRY1   += "          A1_TECN_3, "
QRY1   += "          A1_TECN_A, "
QRY1   += "          A1_TECN_R, "             
QRY1   += "	         A1_TECN_C," 
QRY1   += " 	     A1_XTEC_SP, "
QRY1   += "     	 A1_XTEC_MA, "
QRY1   += "          A1_XTEC_HQ, "
QRY1   += "          A1_CGC, "
QRY1   += "          A1_INSCR, "
QRY1   += "          A1_GRPVEN,  "
QRY1   += "          A1_SATIV8  "
QRY1 += ' order by D2_CLIENTE, D2_LOJA, D2_COD, left(D2_EMISSAO,6)'
*/
// QUERY AJUSTADA

QRY1 := "SELECT D2_CLIENTE, "
QRY1 += "       D2_LOJA, "
QRY1 += "       A1_NOME, "
QRY1 += "       A1_MUN, "
QRY1 += "       A1_EST, "  

If lCarteira  // JBS 19/07/2010 If !Empty(Alltrim(cVenDe))
	QRY1 += "       A1_VENDHQ VENDEDOR, "
Else
	QRY1 += "       F2_VEND1 VENDEDOR, "
Endif
QRY1 += "       A3_NOME, "  
QRY1 += "       A1_PRICOM, "
QRY1 += "       A1_ULTCOM, "
QRY1 += "       A1_HPAGE, "
QRY1 += "       A1_OBSERV, "
QRY1 += "       A1_SATIV1, "
QRY1 += "       X5_DESCRI, "
QRY1 += "       D2_COD, "
QRY1 += "       B1_DESC, "
QRY1 += "       A1_VENDKC, "
QRY1 += "       A1_TECNICO, "
QRY1 += "       A1_TECN_3, "
QRY1 += "       A1_TECN_A, "
QRY1 += "       A1_TECN_R, "
QRY1 += "       A1_TECN_C," 
QRY1 += "       A1_XTEC_SP, "
QRY1 += "       A1_XTEC_MA, "
QRY1 += "       A1_XTEC_HQ, "
QRY1 += "       A1_CGC, "
QRY1 += "       A1_INSCR, " 
QRY1 += "       A1_GRPVEN, " 
QRY1 += "       A1_SATIV8," // Giovani Zago 06/10/11
QRY1 += "       LEFT(D2_EMISSAO,6) D2_EMISSAO, "
QRY1 += "       SUM(D2_QUANT) D2_QUANT, "
QRY1 += "       SUM(D2_TOTAL) D2_TOTAL, "
QRY1 += "       SUM(D2_CUSDIP*D2_QUANT) D2_CUSDIP "
QRY1 += " FROM " + RetSQLName("SD2")+' '
QRY1 += " INNER JOIN  "+ RetSQLName("SF4")+' ON '
QRY1 += RetSQLName('SF4')+".D_E_L_E_T_ <> '*' and "
QRY1 += RetSQLName('SD2')+".D2_TES = "+RetSQLName('SF4')+".F4_CODIGO and "
QRY1 += RetSQLName('SF4')+".F4_DUPLIC = 'S' and "
QRY1 += RetSQLName('SF4')+".F4_FILIAL = '" + xFilial('SF4') + "' "
QRY1 += " INNER JOIN  "+ RetSQLName("SB1")+' ON '
QRY1 += RetSQLName('SB1')+".D_E_L_E_T_ <> '*' and "
QRY1 += RetSQLName('SD2')+".D2_COD    = "+RetSQLName('SB1')+".B1_COD and "
QRY1 += RetSQLName('SB1')+".B1_FILIAL = '" + xFilial('SB1') + "' "
QRY1 += " INNER JOIN  "+ RetSQLName("SA1")+' ON '
QRY1 += RetSQLName('SA1')+".D_E_L_E_T_ <> '*' and "
QRY1 += RetSQLName('SD2')+".D2_CLIENTE= "+RetSQLName('SA1')+".A1_COD and "
QRY1 += RetSQLName('SD2')+".D2_LOJA   = "+RetSQLName('SA1')+".A1_LOJA "
QRY1 += " INNER JOIN  "+ RetSQLName("SA3")+' ON '
QRY1 += RetSQLName('SA3')+".D_E_L_E_T_ <> '*'  "
QRY1 += " INNER JOIN  "+ RetSQLName("SC5")+' ON '
QRY1 += RetSQLName('SC5')+".D_E_L_E_T_ <> '*' "
QRY1 += " AND D2_FILIAL = C5_FILIAL"
QRY1 += " AND D2_PEDIDO = C5_NUM"
QRY1 += " INNER JOIN  "+ RetSQLName("SU7")+' ON '
QRY1 += RetSQLName('SU7')+".D_E_L_E_T_ <> '*' "
QRY1 += " AND C5_OPERADO = U7_COD"
QRY1 += " LEFT JOIN  "+ RetSQLName("SX5")+' ON '
QRY1 += RetSQLName('SX5')+".D_E_L_E_T_ <> '*' "
QRY1 += " AND X5_FILIAL = '" + xFilial('SX5') + "'"
//QRY1 += " AND A1_SATIV1 *= X5_CHAVE" // JBS 09/08/2010  - Incluido o left join (*=)
QRY1 += " AND A1_SATIV1 = X5_CHAVE" // JBS 09/08/2010  - Incluido o left join (*=)
QRY1 += " AND X5_TABELA = 'T3' "
QRY1 += " INNER JOIN  "+ RetSQLName("SF2")+' ON '
QRY1 += RetSQLName('SF2')+".D_E_L_E_T_ <> '*' and "
QRY1 += RetSQLName('SD2')+".D2_FILIAL = "+RetSQLName('SF2')+".F2_FILIAL and "
QRY1 += RetSQLName('SD2')+".D2_DOC    = "+RetSQLName('SF2')+".F2_DOC and "
QRY1 += RetSQLName('SD2')+".D2_SERIE  = "+RetSQLName('SF2')+".F2_SERIE "
QRY1 += " WHERE "
QRY1 += RetSQLName('SD2')+".D_E_L_E_T_ <> '*' and "  
QRY1 += " LEFT(D2_EMISSAO,6) BETWEEN '" + _nParIni + "' AND '" + _nParFim + "' and "
If lTecnico
	QRY1 += "Right(Left("+RetSQLName('SD2')+".D2_EMISSAO,6),2) IN ('"+StrTran(AllTrim(cTrimestre),"/","','")+"') And "
	Do Case                    
		Case nTecnico==1 .And. (nTecSA3 = 5 .Or. nTecSA3 = 1) // TÈcnico KC  
			QRY1 += RetSQLName('SA1')+".A1_TECNICO = '" + cTecnico +"' And "
			cForDe  := "000366"
		Case nTecnico==2 .And. (nTecSA3 = 5 .Or. nTecSA3 = 2) // TÈcnico AMCOR
			QRY1 += RetSQLName('SA1')+".A1_TECN_A  = '" + cTecnico +"' And "
			cForDe  := "000183"
		Case nTecnico==3 .And. (nTecSA3 = 5 .Or. nTecSA3 = 3) // TÈcnico 3M
			QRY1 += RetSQLName('SA1')+".A1_TECN_3  = '" + cTecnico +"' And "
			cForDe  := "000041"
		Case nTecnico==4 .And. (nTecSA3 = 5 .Or. nTecSA3 = 4) // TÈcnico ROCHE
			QRY1 += RetSQLName('SA1')+".A1_TECN_R  = '" + cTecnico +"' And "
			cForDe  := "000338"  
		Case nTecnico==5 .And. (nTecSA3 = 5 .Or. nTecSA3 = 5) // TÈcnico Convatec
			QRY1 += RetSQLName('SA1')+".A1_TECN_C  = '" + cTecnico +"' And "
			cForDe  := "000647"
		Case nTecnico==6 .And. (nTecSA3 = 5 .Or. nTecSA3 = 6) // TÈcnico SP
			QRY1 += RetSQLName('SA1')+".A1_XTEC_SP  = '" + cTecnico +"' And "
			cForDe  := "000996"
		Case nTecnico==7 .And. (nTecSA3 = 5 .Or. nTecSA3 = 7) // TÈcnico MA
			QRY1 += RetSQLName('SA1')+".A1_XTEC_MA  = '" + cTecnico +"' And "
			cForDe  := "000997"
		Case nTecnico==8 .And. (nTecSA3 = 5 .Or. nTecSA3 = 8) // TÈcnico HQ
			QRY1 += RetSQLName('SA1')+".A1_XTEC_HQ  = '" + cTecnico +"' And "
			cForDe  := "000851"
	EndCase
Endif                          

If Empty(cGrpCli)
	QRY1 += RetSQLName('SD2')+".D2_CLIENTE >= '"+cCliDe+"' and "
	QRY1 += RetSQLName('SD2')+".D2_CLIENTE <= '"+cCliAte+"' and "
Else 
	QRY1 += RetSQLName('SA1')+".A1_GRPVEN  = '"+cGrpCli+"' and "                 
EndIf                              

If !Empty(cForDe)
	If cForDe $ "000851/051508" 
		QRY1 += RetSQLName('SD2')+".D2_FORNEC IN ('000851','051508') and "
	ElseIf cForDe $ "000338/100015"
		QRY1 += RetSQLName('SD2')+".D2_FORNEC IN ('000338','100015') and "		
	Else
		QRY1 += RetSQLName('SD2')+".D2_FORNEC  = '"+cForDe+"' and "
	Endif
Endif

If Upper(_cDipUsr) $ cUserTec
	QRY1 += RetSQLName('SD2')+".D2_FORNEC in ('000041','000609','000334','000338','000183','000996','000997','000851','051508','000647','100015','000517') and  " //ROCHE, 3M e AMCOR
Endif
QRY1 += RetSQLName('SD2')+".D2_COD     >= '"+cProDe+"' and "
QRY1 += RetSQLName('SD2')+".D2_COD     <= '"+cProAte+"' and "    

If U_ListVend() == '' 
	
	If !Empty(Alltrim(cVenDe))
		QRY1   += "                      A3_COD  = '"+cVenDe+"' and "
	EndIf 
	
	If lCarteira 
		QRY1   += "                      A3_COD  = A1_VENDHQ and " // JBS 16/07/2010
	Else
        QRY1   += "                      A3_COD  = F2_VEND1 and " // JBS 16/07/2010
	Endif
Else 
	
	QRY1 += "                      A3_COD "+U_ListVend("1")+" and "
	If !Empty(cVenDe)
		QRY1   += "                      A3_COD  = '"+cVenDe+"' and " 
	EndIf	
	
	If lCarteira 
		QRY1   += "                      A3_COD  = A1_VENDHQ and " // JBS 16/07/2010
	Else
        QRY1   += "                      A3_COD  = F2_VEND1 and " // JBS 16/07/2010
	EndIf
	
EndIf                   

QRY1 += RetSQLName('SD2')+".D2_FILIAL = '" + xFilial('SD2') + "' and "
QRY1 += RetSQLName('SD2')+".D2_TIPO    <> 'D' "
If nSetor == 1 .and. empty(cOper)// APOIO
	QRY1 += " AND (U7_VEND = 2"
	QRY1 += "  OR U7_COD  = '000015')"
ElseIf nSetor == 2 .and. empty(cOper) // CALL CENTER
	QRY1 += " AND U7_VEND = 1"
	QRY1 += " AND U7_COD <> '000015'"
elseIf !empty(cOper) // Operadores Selecionados pelo usuario
	QRY1 += " AND U7_COD IN ('"+StrTran(AllTrim(cOper),"/","','")+"')"	
EndIf   
QRY1   += " GROUP BY D2_CLIENTE, "
QRY1   += "          D2_LOJA, "
QRY1   += "          A1_NOME, "
QRY1   += "          A1_MUN, "
QRY1   += "          A1_EST, "
If lCarteira  // JBS 19/07/2010 !Empty(Alltrim(cVenDe))// JBS 16/07/2010
	QRY1   += "       A1_VENDHQ, "
Else
	QRY1   += "       F2_VEND1, "
Endif
QRY1   += "          A3_NOME, "  
QRY1   += "          A1_PRICOM, "
QRY1   += "          A1_ULTCOM, "
QRY1   += "          A1_HPAGE, "
QRY1   += "          A1_OBSERV, "
QRY1   += "          A1_SATIV1, "
QRY1   += "          X5_DESCRI, "
QRY1   += "          LEFT(D2_EMISSAO,6), "
QRY1   += "          D2_COD, "
QRY1   += "          D2_CUSDIP, "
QRY1   += "          B1_DESC, "
QRY1   += "          A1_VENDKC, "
QRY1   += "          A1_TECNICO, "
QRY1   += "          A1_TECN_3, "
QRY1   += "          A1_TECN_A, "
QRY1   += "          A1_TECN_R, "             
QRY1   += "	         A1_TECN_C," 
QRY1   += " 	     A1_XTEC_SP, "
QRY1   += "     	 A1_XTEC_MA, "
QRY1   += "          A1_XTEC_HQ, "
QRY1   += "          A1_CGC, "
QRY1   += "          A1_INSCR, "
QRY1   += "          A1_GRPVEN,  "
QRY1   += "          A1_SATIV8  "
QRY1   += ' order by D2_CLIENTE, D2_LOJA, D2_COD, left(D2_EMISSAO,6)'

// Processa Query SQL
memowrite('DIPR026_SD2_'+SM0->M0_CODIGO+'0_'+SM0->M0_CODFIL+'.SQL',QRY1)
TcQuery QRY1 NEW ALIAS "QRY1"         // Abre uma workarea com o resultado da query

//--------------------------------------------------------------------------------------
// JBS 13/04/2010 - Tratamento para para apurar devoluÁıes
//--------------------------------------------------------------------------------------
If lDevoluc
	cQuery   := "SELECT SUBSTRING(D1_DTDIGIT,1,6) D1_DTDIGIT, "
	cQuery   += "       A1_NOME, "
	cQuery   += "       A1_EST, "
	cQuery   += "       A1_PRICOM, "
	cQuery   += "       A1_ULTCOM, "
	cQuery   += "       A1_HPAGE, "
	cQuery   += "       A1_SATIV1, "
		cQuery   += "       A1_SATIV8, "
	If lCarteira  // JBS 19/07/2010 If !Empty(Alltrim(cVenDe))
		cQuery   += "       A1_VENDHQ  VENDEDOR, "
	Else
		cQuery   += "       F2_VEND1 VENDEDOR, "
	Endif
	
	cQuery   += "       A1_VENDKC, "
	cQuery   += "       A1_TECNICO, "
	cQuery   += "       A1_TECN_3, "
	cQuery   += "       A1_TECN_A, "
	cQuery   += "       A1_TECN_R,"
	cQuery 	 += "       A1_TECN_C," 
	cQuery 	 += "       A1_XTEC_SP, "
	cQuery   += "       A1_XTEC_MA, "
	cQuery   += "       A1_XTEC_HQ, "
	cQuery   += "       A1_MUN, "
	cQuery   += "       X5_DESCRI, "
	cQuery   += "       SUM(D2_CUSDIP*D2_QUANT) D2_CUSDIP, "
	cQuery   += "       SUM(D1_QUANT) D2_QUANT,  "  //  Deixei D2_QUANT para ficar igual ao processamento de vendas
	cQuery   += "       SUM(D1_TOTAL) D2_TOTAL,  "  //  Deixei D2_TOTAL para ficar igual ao processamento de vendas
	cQuery   += "       B1_DESC, "
	cQuery   += "       A1_CGC, "
    cQuery   += "       A1_INSCR, D2_CLIENTE, D2_LOJA, D2_COD, A3_NOME  "
	
	cQuery   += "  FROM " + RetSqlName('SD1') + " SD1 "
	
	cQuery   += " INNER JOIN " + RetSqlName('SD2') + " SD2 ON D2_FILIAL = D1_FILIAL "
	cQuery   += "                       AND D2_DOC   = D1_NFORI "
	cQuery   += "                       AND D2_SERIE = D1_SERIORI "
	cQuery   += "                       AND D2_ITEM  = D1_ITEMORI "
	If !Empty(cForDe) // MCVN - 26/07/10
		If cForDe $ "000851/051508" //CÛdigos do fornecedor HQ
			cQuery +="                  AND D2_FORNEC IN ('000851','051508') "
		Else
 			cQuery +="                  AND D2_FORNEC = '" + cForDe + "'"
		Endif
	Endif
	//cQuery   += "                       AND D2_FORNEC  >= '"+cForDe+"' "       // JBS 27/04/2010 - Mesma regra de saida para devoluÁıes
	//cQuery   += "                       AND D2_FORNEC  <= '"+cForAte+"' "      // JBS 27/04/2010 - Mesma regra de saida para devoluÁıes
	If Upper(_cDipUsr) $ cUserTec  //MCVN - 10/05/09 Filtrando fornecedores quando usu·rios estiver no par‚metro MV_USERTEC
		cQuery   += "                       AND D2_FORNEC in ('000041','000609','000334','000338','000183','000996','000997','000851','051508','000647','100015','000517') " //ROCHE, 3M e AMCOR
	Endif
	cQuery   += "                       AND SD2.D_E_L_E_T_ = '' "
	cQuery   += " INNER JOIN "+RetSQLName("SA1")+" SA1 ON A1_FILIAL = '" + xFilial('SA1') + "' "
	cQuery   += "                       AND A1_COD = D1_FORNECE "
	cQuery   += "                       AND A1_LOJA = D1_LOJA "
	
	If lTecnico
		
		cQuery   += "                      AND Right(Left(D1_DTDIGIT,6),2) IN ('"+StrTran(AllTrim(cTrimestre),"/","','")+"') "

		Do Case                    
			Case nTecnico==1 .And. (nTecSA3 = 5 .Or. nTecSA3 = 1) // TÈcnico KC  
				cQuery   += "                      AND A1_TECNICO = '" + cTecnico +"' "
				cForDe  := "000366"
			Case nTecnico==2 .And. (nTecSA3 = 5 .Or. nTecSA3 = 2) // TÈcnico AMCOR
				cQuery   += "                      AND A1_TECN_A = '" + cTecnico +"' "
				cForDe  := "000183"
			Case nTecnico==3 .And. (nTecSA3 = 5 .Or. nTecSA3 = 3) // TÈcnico 3M
				cQuery   += "                      AND A1_TECN_3 = '" + cTecnico +"' "
				cForDe  := "000041"
			Case nTecnico==4 .And. (nTecSA3 = 5 .Or. nTecSA3 = 4) // TÈcnico ROCHE
				cQuery   += "                      AND A1_TECN_R = '" + cTecnico +"' "
				cForDe  := "000338"  
			Case nTecnico==5 .And. (nTecSA3 = 5 .Or. nTecSA3 = 5) // TÈcnico Convatec
				cQuery   += "                      AND A1_TECN_C = '" + cTecnico +"' "
				cForDe  := "000647"
			Case nTecnico==6 .And. (nTecSA3 = 5 .Or. nTecSA3 = 6) // TÈcnico SP
				cQuery   += "                      AND A1_XTEC_SP = '" + cTecnico +"' "
				cForDe  := "000996"
			Case nTecnico==7 .And. (nTecSA3 = 5 .Or. nTecSA3 = 7) // TÈcnico MA
				cQuery   += "                      AND A1_XTEC_MA = '" + cTecnico +"' "
				cForDe  := "000997"
			Case nTecnico==8 .And. (nTecSA3 = 5 .Or. nTecSA3 = 8) // TÈcnico HQ
				cQuery   += "                      AND A1_XTEC_HQ = '" + cTecnico +"' "
				cForDe  := "000851"
		EndCase
	Endif

	If Empty(cGrpCli)
		cQuery   += "                      AND A1_COD BETWEEN '"+cCliDe+"' AND '"+cCliAte+"' "
	Else
		cQuery  += "                       AND A1_GRPVEN = '" +cGrpCli+"'"
	EndIf

	cQuery   += "                       AND SA1.D_E_L_E_T_ = '' "
	//--------------------------------------------------------------------------------------------------------------------------
	// Cria relacionamento do cliente com a descricao da atividade
	//--------------------------------------------------------------------------------------------------------------------------
	cQuery   += " Left JOIN " + RetSqlName('SX5') + " SX5 ON X5_FILIAL = '" + xFilial('SX5') + "' " // JBS 09/08/2010  - Incluido o left join (*=)
	cQuery   += "                       AND X5_CHAVE  = A1_SATIV1 "
    cQuery   += "                       AND X5_TABELA = 'T3' "
	cQuery   += "                       AND SX5.D_E_L_E_T_ = '' "
	//--------------------------------------------------------------------------------------------------------------------------
	// Cria o relacionamento entre os itens do SD2 com as notas fiscais
	//--------------------------------------------------------------------------------------------------------------------------
	cQuery   += "INNER JOIN " + RetSqlName('SF2') + " SF2 ON  F2_FILIAL = '"+xFilial('SF4')+"'
	cQuery   += "                      AND F2_DOC = D2_DOC "
	cQuery   += "                      AND F2_SERIE = D2_SERIE "
	cQuery   += "                      AND SF2.D_E_L_E_T_ =  '' "
	//--------------------------------------------------------------------------------------------------------------------------
	// Cria o relacionamento ente o vendedor nas notas  fiscais e o cadastro de vendedores
	//--------------------------------------------------------------------------------------------------------------------------
	cQuery   += "INNER JOIN " + RetSqlName('SA3') + " SA3 ON  A3_FILIAL = '" + xFilial('SA3') + "'  "
	If U_ListVend() == ''
		If !Empty(Alltrim(cVenDe))
			cQuery   += "                      AND A3_COD  = '"+cVenDe+"' "
		EndIf
		If lCarteira  // JBS 19/07/2010
			cQuery   += "                      AND A3_COD  = A1_VEND " // JBS 16/07/2010
		Else
			cQuery   += "                      AND A3_COD  = F2_VEND1" // JBS 16/07/2010
		Endif
	Else
		cQuery   += "                      AND A3_COD "+U_ListVend()+" "
		If !Empty(cVenDe)
			cQuery   += "                      AND A3_COD  = '"+cVenDe+"' "
		EndIF
		If lCarteira  // JBS 19/07/2010
			cQuery   += "                      AND A3_COD  = A1_VEND " // JBS 16/07/2010
		Else
			cQuery   += "                      AND A3_COD  = F2_VEND1" // JBS 16/07/2010
		EndIf
	EndIf
	cQuery   += "                      AND SA3.D_E_L_E_T_ = ''  "
	cQuery   += "INNER JOIN " + RetSqlName('SB1') + " SB1 ON  B1_FILIAL = '"+xFilial('SB1')+"' "
	cQuery   += "                      AND B1_COD = D2_COD "
	cQuery   += "                      AND SB1.D_E_L_E_T_ =  '' "
	
	cQuery   += " INNER JOIN " + RetSqlName('SF4') + " SF4 ON F4_FILIAL = '" + xFilial('SF4') + "' "
	cQuery   += "                       AND F4_CODIGO = D1_TES "
	cQuery   += "                       AND F4_DUPLIC  = 'S' "
	cQuery   += "                       AND SF4.D_E_L_E_T_ = '' "
	
	cQuery   += " WHERE D1_FILIAL = '" + xFilial('SD1') + "' "
	cQuery   += "   AND SUBSTRING(D1_DTDIGIT,1,6) BETWEEN '" + _nParIni + "' AND '" + _nParFim + "' "
	cQuery   += "   AND D1_TIPO    = 'D' "
	cQuery   += "   AND D1_COD     >= '"+cProDe+"' "     // MVCN 26/04/2010 - AplicaÁ„o da regra de saida
	cQuery   += "   AND D1_COD     <= '"+cProAte+"' "    // MVCN 26/04/2010 - AplicaÁ„o da regra de saida
	cQuery   += "   AND SD1.D_E_L_E_T_ <> '*'"
	
	cQuery   += " GROUP BY SUBSTRING(D1_DTDIGIT,1,6), "
	cQuery   += "         A1_NOME, "
	cQuery   += "         A1_EST, "
	cQuery   += "         A1_MUN, "
	cQuery   += "         A1_PRICOM, "
	cQuery   += "         A1_ULTCOM, "
	cQuery   += "         A1_HPAGE, "
	cQuery   += "         A1_SATIV1, "
		cQuery   += "       A1_SATIV8, "
	If lCarteira  // JBS 19/07/2010 If !Empty(Alltrim(cVenDe))
		cQuery   += "       A1_VENDHQ, "
	Else
		cQuery   += "       F2_VEND1, "
	Endif
	cQuery   += "         A1_VENDKC, "
	cQuery   += "         A1_TECNICO, "
	cQuery   += "         A1_TECN_3, "
	cQuery   += "         A1_TECN_A, "
	cQuery   += "         A1_TECN_R, "
	cQuery 	 += "         A1_TECN_C," 
	cQuery 	 += "         A1_XTEC_SP, "
	cQuery   += "         A1_XTEC_MA, "
	cQuery   += "         A1_XTEC_HQ, "
	cQuery   += "         X5_DESCRI, "
	cQuery   += "         A1_CGC, "
	cQuery   += "         B1_DESC, "
	cQuery   += "         A1_INSCR, D2_CLIENTE, D2_LOJA, D2_COD, A3_NOME "
	
	cQuery += " ORDER BY D2_CLIENTE,D2_LOJA, D1_DTDIGIT "
	
	If Select("QRY3") > 0
		QRY3->( DbCloseArea() )
	EndIf
	
	TcQuery cQuery NEW ALIAS "QRY3"
    memowrite('DIPR026_SD1'+SM0->M0_CODIGO+'0_'+SM0->M0_CODFIL+'.SQL',cQuery)
EndIf
// cria arquivo com meses colunados
If lTecnico  //Arquivo TÈcnicos em DBF - MCVN - 17/09/08
	_aCamposTEC := {}
	AAdd(_aCamposTEC , {"CLIENTE"   ,"C",TamSX3("D2_CLIENTE")[1] , TamSX3("D2_CLIENTE")[2]})
	AAdd(_aCamposTEC , {"LOJA"      ,"C",TamSX3("D2_LOJA")[1]    , TamSX3("D2_LOJA")[2]})
	AAdd(_aCamposTEC , {"NOME"      ,"C",TamSX3("A1_NOME")[1]    , TamSX3("A1_NOME")[2]})
	AAdd(_aCamposTEC , {"CIDADE"    ,"C",TamSX3("A1_MUN")[1]     , TamSX3("A1_MUN")[2]})
	AAdd(_aCamposTEC , {"UF"        ,"C",TamSX3("A1_EST")[1]     , TamSX3("A1_EST")[2]})
	AAdd(_aCamposTEC , {"SEGMENTO"  ,"C",TamSX3("A1_SATIV1")[1]  , TamSX3("A1_SATIV1")[2]}) 
	AAdd(_aCamposTEC , {"SEG_DESCR" ,"C",TamSX3("X5_DESCRI")[1]  , TamSX3("X5_DESCRI")[2]})
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
	AAdd(_aCamposTEC , {"SEGMENTO2"    , "C", TamSX3("A1_SATIV1")[1]    ,TamSX3("A1_SATIV1")[2]}) //Giovani Zago 10/10/11
	AAdd(_aCamposTEC , {"SEG_DESCR2"   , "C", TamSX3("X5_DESCRI")[1]    ,TamSX3("X5_DESCRI")[2]}) //Giovani Zago 10/10/11
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
	AAdd(_aCampos ,{"VENDEDOR"    , "C", TamSX3("A3_COD")[1]       ,TamSX3("A3_COD")[2]})
	AAdd(_aCampos ,{"NOME_VEND"   , "C", TamSX3("A3_NOME")[1]      ,TamSX3("A3_NOME")[2]})
	AAdd(_aCampos ,{"VENDKC"      , "C", TamSX3("A3_COD")[1]       ,TamSX3("A3_COD")[2]})
	AAdd(_aCampos ,{"N_VENDKC"    , "C", TamSX3("A3_NOME")[1]      ,TamSX3("A3_NOME")[2]})
	AAdd(_aCampos ,{"TEC_AMCOR"   , "C", TamSX3("A3_COD")[1]       ,TamSX3("A3_COD")[2]})
	AAdd(_aCampos ,{"NTEC_AMCOR"  , "C", TamSX3("A3_NOME")[1]      ,TamSX3("A3_NOME")[2]})
	AAdd(_aCampos ,{"TEC_3M"      , "C", TamSX3("A3_COD")[1]       ,TamSX3("A3_COD")[2]})
	AAdd(_aCampos ,{"N_TEC_3M"    , "C", TamSX3("A3_NOME")[1]      ,TamSX3("A3_NOME")[2]})
	AAdd(_aCampos ,{"TEC_ROCHE"   , "C", TamSX3("A3_COD")[1]       ,TamSX3("A3_COD")[2]})
	AAdd(_aCampos ,{"NTEC_ROCHE"  , "C", TamSX3("A3_NOME")[1]      ,TamSX3("A3_NOME")[2]})
	AAdd(_aCampos ,{"TECNICO"     , "C", TamSX3("A3_COD")[1]       ,TamSX3("A3_COD")[2]})
	AAdd(_aCampos ,{"NOME_TEC"    , "C", TamSX3("A3_NOME")[1]      ,TamSX3("A3_NOME")[2]})
	AAdd(_aCampos ,{"PRODUTO"     , "C", TamSX3("D2_COD")[1]       ,TamSX3("D2_COD")[2]})
	AAdd(_aCampos ,{"DESCRICAO"   , "C", TamSX3("B1_DESC")[1]      ,TamSX3("B1_DESC")[2]})
	AAdd(_aCampos ,{"TEC_CONVAT"  , "C", TamSX3("A3_COD")[1]       ,TamSX3("A3_COD")[2]})
	AAdd(_aCampos ,{"NTEC_CONVA"  , "C", TamSX3("A3_NOME")[1]      ,TamSX3("A3_NOME")[2]})
	AAdd(_aCampos ,{"TEC_SP"	  , "C", TamSX3("A3_COD")[1]       ,TamSX3("A3_COD")[2]})
	AAdd(_aCampos ,{"NTEC_SP"	  , "C", TamSX3("A3_NOME")[1]      ,TamSX3("A3_NOME")[2]})
	AAdd(_aCampos ,{"TEC_MA"      , "C", TamSX3("A3_COD")[1]       ,TamSX3("A3_COD")[2]})
	AAdd(_aCampos ,{"NTEC_MA"     , "C", TamSX3("A3_NOME")[1]      ,TamSX3("A3_NOME")[2]})
	AAdd(_aCampos ,{"TEC_HQ"      , "C", TamSX3("A3_COD")[1]       ,TamSX3("A3_COD")[2]})
	AAdd(_aCampos ,{"NTEC_HQ"     , "C", TamSX3("A3_NOME")[1]      ,TamSX3("A3_NOME")[2]})
    //----------------------------------------------------------------------------------------------
    // JBS - 14/04/2010
    // DefiniÁ„o da extrutura dos mesess, sempre comeÁando pelo primeiro mes do periodo
    //----------------------------------------------------------------------------------------------
    nNom_Cam  := _nMesIni
	_aTamSX3Q := TamSX3("D2_QUANT")  // Campos de Quantidades
	_aTamSX3V := TamSX3("D2_TOTAL")  // Campos de valores
	  
	For wi := 1 to 12 

		AAdd(_aCampos ,{"Q"+StrZero(nNom_Cam,2),"N",TamSX3("D2_QUANT")[1],TamSX3("D2_QUANT")[2]})
	    If !lNoShowVal // N„o mostra valores MCVN - 09/08/08
		    AAdd(_aCampos ,{"V"+StrZero(nNom_Cam,2),"N",TamSX3("D2_TOTAL")[1],TamSX3("D2_TOTAL")[2]})
        EndIf

		If nNom_Cam = 12
			nNom_Cam := 1
		Else
			nNom_Cam++
		EndIf		
    
    Next wi
	AAdd(_aCampos ,{"Q13","N",_aTamSX3Q[1],_aTamSX3Q[2]})
    If !lNoShowVal // N„o mostra valores MCVN - 09/08/08
	    AAdd(_aCampos ,{"V13","N",TamSX3("D2_TOTAL")[1],TamSX3("D2_TOTAL")[2]})
    EndIf
Endif                    
//---------------------------------------------------------------------------------------------------
// Mostra informaÁıes quando for gerado por Eriberto/Erich 
//---------------------------------------------------------------------------------------------------
nNom_Cam := _nMesIni
//---------------------------------------------------------------------------------------------------
If !lNoShowVal .And. !lTecnico// N„o mostra valores MCVN - 09/08/08
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
If !lNoShowVal .And. !lTecnico// N„o mostra valores MCVN - 09/08/08
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

If lTecnico   // Arquivo TÈcnicos em DBF - MCVN - 17/09/08

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
		
		If !dbSeek(QRY1->D2_CLIENTE+QRY1->D2_LOJA+QRY1->VENDEDOR+QRY1->D2_COD) // JBS 19/07/2010 - Inclui o vendedor na chava de busca

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
			TRB->VENDEDOR 	:= QRY1->VENDEDOR  // JBS 19/07/2010
		
			TRB->NOME_VEND 	:= QRY1->A3_NOME  
			
			If nTecnico == 1// TÈcnico KC
				TRB->TECNICO  := QRY1->A1_TECNICO
				SA3->(dbSeek(xFilial('SA3')+QRY1->A1_TECNICO))
				TRB->N_TECNICO:= SA3->A3_NOME
            ElseIf nTecnico == 2 // TÈcnico Amcor                                                         
    			TRB->TECNICO  := QRY1->A1_TECN_A
				SA3->(dbSeek(xFilial('SA3')+QRY1->A1_TECN_A))
				TRB->N_TECNICO:=  SA3->A3_NOME 
			ElseIf nTecnico == 3 // TÈcnico 3M
				TRB->TECNICO  := QRY1->A1_TECN_3
				SA3->(dbSeek(xFilial('SA3')+QRY1->A1_TECN_3))
				TRB->N_TECNICO:= SA3->A3_NOME                              
			ElseIf nTecnico == 4	// TÈcnico Roche
				TRB->TECNICO  := QRY1->A1_TECN_R
				SA3->(dbSeek(xFilial('SA3')+QRY1->A1_TECN_R))
				TRB->N_TECNICO :=  SA3->A3_NOME
			ElseIf nTecnico == 5	// TÈcnico Convatec
				TRB->TECNICO  := QRY1->A1_TECN_C
				SA3->(dbSeek(xFilial('SA3')+QRY1->A1_TECN_C))
				TRB->N_TECNICO :=  SA3->A3_NOME
			ElseIf nTecnico == 6	// TÈcnico SP
				TRB->TECNICO  := QRY1->A1_XTEC_SP
				SA3->(dbSeek(xFilial('SA3')+QRY1->A1_XTEC_SP))
				TRB->N_TECNICO :=  SA3->A3_NOME
			ElseIf nTecnico == 7	// TÈcnico MA
				TRB->TECNICO  := QRY1->A1_XTEC_MA
				SA3->(dbSeek(xFilial('SA3')+QRY1->A1_XTEC_MA))
				TRB->N_TECNICO :=  SA3->A3_NOME
			Else	// TÈcnico HQ
				TRB->TECNICO  := QRY1->A1_XTEC_HQ
				SA3->(dbSeek(xFilial('SA3')+QRY1->A1_XTEC_HQ))
				TRB->N_TECNICO :=  SA3->A3_NOME																
			Endif

			TRB->PRODUTO  := QRY1->D2_COD
			TRB->DESCRICAO:= QRY1->B1_DESC
			_triQ := 'TRB->Q'+If(SubStr(QRY1->D2_EMISSAO,5,2) $ ("01/02/03"),"1TRIMESTR",;
							  If(SubStr(QRY1->D2_EMISSAO,5,2) $ ("04/05/06"),"2TRIMESTR",;
							  If(SubStr(QRY1->D2_EMISSAO,5,2) $ ("07/08/09"),"3TRIMESTR","4TRIMESTR")))
							  
			_triV := 'TRB->V'+If(SubStr(QRY1->D2_EMISSAO,5,2) $ ("01/02/03"),"1TRIMESTR",;
							  If(SubStr(QRY1->D2_EMISSAO,5,2) $ ("04/05/06"),"2TRIMESTR",;
							  If(SubStr(QRY1->D2_EMISSAO,5,2) $ ("07/08/09"),"3TRIMESTR","4TRIMESTR")))
							  

			&_triQ   := &_triQ + QRY1->D2_QUANT
			&_triV   := &_triV + QRY1->D2_TOTAL
			
			TRB->QTD_TOTAL := TRB->QTD_TOTAL + QRY1->D2_QUANT	
			TRB->VAL_TOTAL := TRB->VAL_TOTAL + QRY1->D2_TOTAL                                                     
			
		Else
		
			RecLock("TRB",.F.)
			_triQ := 'TRB->Q'+If(SubStr(QRY1->D2_EMISSAO,5,2) $ ("01/02/03"),"1TRIMESTR",;
							  If(SubStr(QRY1->D2_EMISSAO,5,2) $ ("04/05/06"),"2TRIMESTR",;
							  If(SubStr(QRY1->D2_EMISSAO,5,2) $ ("07/08/09"),"3TRIMESTR","4TRIMESTR")))
							  
			_triV := 'TRB->V'+If(SubStr(QRY1->D2_EMISSAO,5,2) $ ("01/02/03"),"1TRIMESTR",;
							  If(SubStr(QRY1->D2_EMISSAO,5,2) $ ("04/05/06"),"2TRIMESTR",;
							  If(SubStr(QRY1->D2_EMISSAO,5,2) $ ("07/08/09"),"3TRIMESTR","4TRIMESTR")))

	  		&_triQ   := &_triQ + QRY1->D2_QUANT
			&_triV   := &_triV + QRY1->D2_TOTAL
				
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

		DbSelectArea("TRB")
		If !dbSeek(QRY1->D2_CLIENTE+QRY1->D2_LOJA+QRY1->VENDEDOR+QRY1->D2_COD) // JBS 19/07/2010  incluido o vendedor na chave
		
			RecLock("TRB",.T.)
		
			TRB->CLIENTE  	:= QRY1->D2_CLIENTE
			TRB->LOJA     	:= QRY1->D2_LOJA
			TRB->NOME     	:= QRY1->A1_NOME
			TRB->CIDADE   	:= QRY1->A1_MUN
			TRB->UF       	:= QRY1->A1_EST
			TRB->SEGMENTO 	:= QRY1->A1_SATIV1
			TRB->SEGMENTO2 	:= QRY1->A1_SATIV8//Giovani Zago 06/10/11
			TRB->SEG_DESCR 	:= QRY1->X5_DESCRI
			TRB->SEG_DESCR2	:= IF(!Empty(QRY1->A1_SATIV8),posicione("SX5",1,xFilial("SX5")+"T3"+ALLTRIM(QRY1->A1_SATIV8),"X5_DESCRI"),"")//Giovani Zago 10/10/11
			TRB->VENDEDOR 	:= QRY1->VENDEDOR // JBS 19/07/2010
			TRB->NOME_VEND 	:= QRY1->A3_NOME  
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
			
			TRB->TEC_CONVAT  := QRY1->A1_TECN_C
			SA3->(dbSeek(xFilial('SA3')+QRY1->A1_TECN_C))
			TRB->NTEC_CONVA  :=  SA3->A3_NOME
			
			TRB->TEC_SP  := QRY1->A1_XTEC_SP
			SA3->(dbSeek(xFilial('SA3')+QRY1->A1_XTEC_SP))
			TRB->NTEC_SP :=  SA3->A3_NOME
			
			TRB->TEC_MA  := QRY1->A1_XTEC_MA
			SA3->(dbSeek(xFilial('SA3')+QRY1->A1_XTEC_MA))
			TRB->NTEC_MA :=  SA3->A3_NOME
			
			TRB->TEC_HQ  := QRY1->A1_XTEC_HQ
			SA3->(dbSeek(xFilial('SA3')+QRY1->A1_XTEC_HQ))
			TRB->NTEC_HQ :=  SA3->A3_NOME

			TRB->PRODUTO  := QRY1->D2_COD
			TRB->DESCRICAO:= QRY1->B1_DESC
			_mesQ := 'TRB->Q'+SubStr(QRY1->D2_EMISSAO,5,2)		
			If !lNoShowVal // N„o mostra valores MCVN - 09/08/08
				_mesV := 'TRB->V'+SubStr(QRY1->D2_EMISSAO,5,2)
			Endif
			&_mesQ   := &_mesQ + QRY1->D2_QUANT
			If !lNoShowVal // N„o mostra valores MCVN - 09/08/08
				&_mesV   := &_mesV + QRY1->D2_TOTAL
			Endif 
			TRB->Q13 := TRB->Q13 + QRY1->D2_QUANT
		
        	If !lNoShowVal // N„o mostra valores MCVN - 09/08/08
				TRB->V13 := TRB->V13 + QRY1->D2_TOTAL    
				
				TRB->TOTAL := TRB->TOTAL + QRY1->D2_TOTAL                                                     
				nTotMes := TRB->(FieldGet(FieldPos('M'+SubStr(QRY1->D2_EMISSAO,5,2)))) + QRY1->D2_TOTAL // JBS 20/03/2006
				TRB->(Fieldput(FieldPos('M'+SubStr(QRY1->D2_EMISSAO,5,2)),nTotMes))      // JBS 20/03/2006

				If Upper(_cDipUsr) $ cSHWCUST     // JBS 20/03/2006
					nCusto := TRB->(FieldGet(FieldPos('C'+SubStr(QRY1->D2_EMISSAO,5,2)))) + (QRY1->D2_CUSDIP*QRY1->D2_QUANT)  // JBS 20/03/2006
					TRB->CUST_TOTAL := TRB->CUST_TOTAL + (QRY1->D2_CUSDIP*QRY1->D2_QUANT)// JBS 20/03/2006
					TRB->(Fieldput(FieldPos('C'+SubStr(QRY1->D2_EMISSAO,5,2)),nCusto))   // JBS 20/03/2006
				EndIf

			Endif
		Else
			RecLock("TRB",.F.)
			_mesQ := 'TRB->Q'+SubStr(QRY1->D2_EMISSAO,5,2)
			If !lNoShowVal // N„o mostra valores MCVN - 09/08/08
				_mesV := 'TRB->V'+SubStr(QRY1->D2_EMISSAO,5,2)
			Endif
			&_mesQ   := &_mesQ + QRY1->D2_QUANT
			If !lNoShowVal // N„o mostra valores MCVN - 09/08/08
				&_mesV   := &_mesV + QRY1->D2_TOTAL
		    Endif
			TRB->Q13 := TRB->Q13 + QRY1->D2_QUANT

			If !lNoShowVal // N„o mostra valores MCVN - 09/08/08
				TRB->V13 := TRB->V13 + QRY1->D2_TOTAL  

				TRB->TOTAL := TRB->TOTAL + QRY1->D2_TOTAL
				nTotMes := TRB->(FieldGet(FieldPos('M'+SubStr(QRY1->D2_EMISSAO,5,2)))) + QRY1->D2_TOTAL // JBS 20/03/2006
				TRB->(Fieldput(FieldPos('M'+SubStr(QRY1->D2_EMISSAO,5,2)),nTotMes))      // JBS 20/03/2006

				If Upper(_cDipUsr) $ cSHWCUST      // JBS 20/03/2006
					nCusto := TRB->(FieldGet(FieldPos('C'+SubStr(QRY1->D2_EMISSAO,5,2)))) + (QRY1->D2_CUSDIP*QRY1->D2_QUANT)  // JBS 20/03/2006
					TRB->CUST_TOTAL := TRB->CUST_TOTAL + (QRY1->D2_CUSDIP*QRY1->D2_QUANT) // JBS 20/03/2006
					TRB->(Fieldput(FieldPos('C'+SubStr(QRY1->D2_EMISSAO,5,2)),nCusto))    // JBS 20/03/2006
				EndIf

			EndIf

    	Endif  

		TRB->(MsUnLock())
	
		dbSelectArea("QRY1")
		QRY1->(dbSkip())
	
	EndDo
Endif                    
//-------------------------------------------------------------------------------------------------------------
// JBS 13/04/2010 - Desenvolvido todo o tratamento abaixo para considerar as devoluÁıes
//                  ocorridas dentro do periodo do relatorio. Este relatorio n„o tratava
//                  as devoluÁıes.    
//-------------------------------------------------------------------------------------------------------------
If lDevoluc
	If lTecnico   // Arquivo TÈcnicos em DBF - MCVN - 17/09/08
		
		Do While QRY3->(!Eof())
			
			IncProc(OemToAnsi("Cliente..: " + QRY3->D2_CLIENTE + '-' + QRY3->D2_LOJA ))
			
			If nRecCount<1
				nRecCount:=200
				ProcRegua(nRecCount)
			EndIf

			nRecCount--

			dbSelectArea("SB1")
			dbSeek(xFilial('SB1')+TRB->PRODUTO)
			
			DbSelectArea("TRB")
			
			If !dbSeek(QRY3->D2_CLIENTE+QRY3->D2_LOJA+QRY3->VENDEDOR+QRY3->D2_COD) // JBS 19/07/2010 Incluido o vendedor na chave
			
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
				TRB->VENDEDOR 	:= QRY3->VENDEDOR   // JBS 19/07/2010
				TRB->NOME_VEND 	:= QRY3->A3_NOME
				
				If nTecnico == 1// TÈcnico KC
					TRB->TECNICO  := QRY3->A1_TECNICO
					SA3->(dbSeek(xFilial('SA3')+QRY3->A1_TECNICO))
					TRB->N_TECNICO:= SA3->A3_NOME
				ElseIf nTecnico == 2 // TÈcnico Amcor
					TRB->TECNICO  := QRY3->A1_TECN_A
					SA3->(dbSeek(xFilial('SA3')+QRY3->A1_TECN_A))
					TRB->N_TECNICO:=  SA3->A3_NOME
				ElseIf nTecnico == 3 // TÈcnico 3M
					TRB->TECNICO  := QRY3->A1_TECN_3
					SA3->(dbSeek(xFilial('SA3')+QRY3->A1_TECN_3))
					TRB->N_TECNICO:= SA3->A3_NOME                              
				ElseIf nTecnico == 4	// TÈcnico Roche
					TRB->TECNICO  := QRY3->A1_TECN_R
					SA3->(dbSeek(xFilial('SA3')+QRY3->A1_TECN_R))
					TRB->N_TECNICO :=  SA3->A3_NOME
				ElseIf nTecnico == 5	// TÈcnico Convatec
					TRB->TECNICO  := QRY3->A1_TECN_C
					SA3->(dbSeek(xFilial('SA3')+QRY3->A1_TECN_C))
					TRB->N_TECNICO :=  SA3->A3_NOME
				ElseIf nTecnico == 6	// TÈcnico SP
					TRB->TECNICO  := QRY3->A1_XTEC_SP
					SA3->(dbSeek(xFilial('SA3')+QRY3->A1_XTEC_SP))
					TRB->N_TECNICO :=  SA3->A3_NOME
				ElseIf nTecnico == 7	// TÈcnico MA
					TRB->TECNICO  := QRY3->A1_XTEC_MA
					SA3->(dbSeek(xFilial('SA3')+QRY3->A1_XTEC_MA))
					TRB->N_TECNICO :=  SA3->A3_NOME
				Else	// TÈcnico HQ
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
			
			DbSelectArea("TRB")
			If !dbSeek(QRY3->D2_CLIENTE+QRY3->D2_LOJA+QRY3->VENDEDOR+QRY3->D2_COD) // JBS 19/07/2010 Incluido o vendedor na chave
			
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
				TRB->VENDEDOR 	:= QRY3->VENDEDOR // JBS 19/07/2010
				TRB->NOME_VEND 	:= QRY3->A3_NOME
				
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

				TRB->TEC_CONVAT  := QRY3->A1_TECN_C
				SA3->(dbSeek(xFilial('SA3')+QRY3->A1_TECN_C))
				TRB->NTEC_CONVA  :=  SA3->A3_NOME
				
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
				If !lNoShowVal // N„o mostra valores MCVN - 09/08/08
					_mesV := 'TRB->V'+SubStr(QRY3->D1_DTDIGIT,5,2)
				Endif
				&_mesQ   := &_mesQ - QRY3->D2_QUANT
				If !lNoShowVal // N„o mostra valores MCVN - 09/08/08
					&_mesV   := &_mesV - QRY3->D2_TOTAL
				Endif
				TRB->Q13 := TRB->Q13 - QRY3->D2_QUANT
				
				If !lNoShowVal // N„o mostra valores MCVN - 09/08/08
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
				
				If !lNoShowVal // N„o mostra valores MCVN - 09/08/08
					_mesV := 'TRB->V'+SubStr(QRY3->D1_DTDIGIT,5,2)
				Endif
				&_mesQ   := &_mesQ - QRY3->D2_QUANT
				
				If !lNoShowVal // N„o mostra valores MCVN - 09/08/08
					&_mesV   := &_mesV - QRY3->D2_TOTAL
				Endif
				
				TRB->Q13 := TRB->Q13 - QRY3->D2_QUANT
				
				If !lNoShowVal // N„o mostra valores MCVN - 09/08/08
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
	If Select("QRY3") > 0
		QRY3->( DbCloseArea() )
	EndIf
EndIf
//------------------------------------------------------------------------------------------------
// Fim do Tratamento para considerar devoluÁıes
//------------------------------------------------------------------------------------------------
DbSelectArea("TRB") // JBS 20/04/2010
_cChave  := 'CLIENTE + LOJA + VENDEDOR + DESCRICAO'  // JBS 19/07/2010 Incluido o vendedor na chave
IndRegua("TRB",_cArqTrb,_cChave,,,"Criando Indice...(cliente+produto)")

If lTecnico // Arquivo TÈcnicos em DBF - MCVN - 17/09/08 - SOMENTE CRIA ARQUIVO	

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
	
	COPY TO &cArqExcell VIA "DBFCDX"  //Ajustado chamada do dbfcdxads para dbfcdx - Felipe Duran
	
	FRename(cArqExcell+".dtc",cArqExcell+".csv")

	MakeDir(cDestino) // CRIA DIRET”RIO CASO N√O EXISTA
	CpyS2T(cArqExcell+".csv",cDestino,.T.) // COPIA ARQUIVO PARA MAQUINA DO USU¡RIO
	
	// Buscando e apagando arquivos tempor·rios - MCVN 27/08/10
	aTmp := Directory( cDestino+"*.tmp" )
	For nI:= 1 to Len(aTmp)
		fErase(cDestino+aTmp[nI,1])
	Next nI 
	
	DbCloseArea()
	Ferase(_cArqTrb+".DBF")
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
			TRB->NOME_VEND:= SA3->A3_NREDUZ
			TRB->SEGMENTO := QRY4->A1_SATIV1
			TRB->SEGMENTO2 	:= QRY4->A1_SATIV8//Giovani Zago 06/10/11 
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
Local cArqExcell:= "\Excell-DBF\"+_cDipUsr+"-DIPR026" // MCVN - Ajusta local geraÁ„o arquivo pÛs virada de vers„o p 10 - 18/11/09
Local aTmp := {}
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
// MCVN 26/08/10
If !Empty(MV_PAR02) // JBS 21/03/2006
	cRel_Dep := '' // JBS 21/03/2006
ElseIf MV_PAR04 == 1
	cRel_Dep := "Apoio"
ElseIf MV_PAR04 == 2
	cRel_Dep := "Call Center"
ElseIf MV_PAR04 == 3
	cRel_Dep := "LicitaÁıes"
ElseIf MV_PAR04 == 4
	cRel_Dep := "Ambos" 
EndIf                  

_cTitulo := "Faturamento por cliente/Produto de " + AllTrim(StrZero(_nMesIni,2)) + "/" + AllTrim(Str(_nAnoIni)) +" atÈ " + Substr((MV_PAR01),1,2)+"/"+Substr((MV_PAR01),3,4) + Iif(!Empty(MV_PAR02)," - Vendedor: " + MV_PAR02 + "-" + POSICIONE('SA3',1,xFilial('SA3') + MV_PAR02,"A3_NREDUZ"),"") + " - "  + cRel_Dep +If(!Empty(MV_PAR05),' - Fornecedor: '+If(MV_PAR05$"000851/051508","000851/051508",MV_PAR05),'') + Iif(MV_PAR07 = 1,' Por Carteira ',' Por Faturamento ')  // MCVN - 26/08/10
//_cTitulo := "Faturamento por cliente/produto de " +;
//            AllTrim(StrZero(_nMesIni,2)) + "/" + AllTrim(Str(_nAnoIni)) + " atÈ " + cMes + "/" + cAno +;
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
		_nAnoIni := Val(Substr((MV_PAR01),3,4))
	Else
		_nMesIni++
		_nAnoIni := Val(Substr((MV_PAR01),3,4))-1
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
    // Calculando e imprimindo a Media da quantidade por MÍs   MCVN - 11/04/2007                     
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
	
	If !lNoShowVal // N„o mostra valores MCVN - 09/08/08
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

	    // Calculando e imprimindo a Media do valor por MÍs   MCVN - 11/04/2007                     
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
			
			If !lNoShowVal // N„o mostra valores MCVN - 09/08/08
				
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
		
		If !lNoShowVal // N„o mostra valores MCVN - 09/08/08
			
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

	If !lNoShowVal // N„o mostra valores MCVN - 09/08/08
		
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
	li+=2  
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

	COPY TO &cArqExcell VIA "DBFCDX"  //Ajustado chamada do dbfcdxads para dbfcdx - Felipe Duran
	FRename(cArqExcell+".dtc",cArqExcell+".csv")
	MakeDir(cDestino) // CRIA DIRET”RIO CASO N√O EXISTA
	CpyS2T(cArqExcell+".csv",cDestino,.T.) // COPIA ARQUIVO PARA MAQUINA DO USU¡RIO

	// Buscando e apagando arquivos tempor·rios - MCVN 27/08/10
	aTmp := Directory( cDestino+"*.tmp" )
	For nI:= 1 to Len(aTmp)
		fErase(cDestino+aTmp[nI,1])
	Next nI 
EndIf

DbCloseArea()

Ferase(_cArqTrb+".DBF")
Ferase(_cArqTrb+OrdBagExt())

Return(.T.)

/////////////////////////////////////////////////////////////////////////////
//
*---------------------------------------*
Static Function DipPergDiverg(lLer)
// Registra alteraÁıes no SX1
*---------------------------------------*
Local aRegs:={}
Local lIncluir
Local i,j
SX1->(dbSetOrder(1))

AADD(aRegs,{cPerg,"01","Mes e Ano Final    ?","","","mv_ch1","C",06,0,0,"G","","MV_PAR01",""       ,"","","","","","","","","","","","","","","","","","","","","","",""})
AADD(aRegs,{cPerg,"02","Vendedor           ?","","","mv_ch2","C",06,0,0,"G","","MV_PAR02",""       ,"","","","","","","","","","","","","","","","","","","","","","","","SA3"})
AAdd(aRegs,{cPerg,"03","Cria arquivo       ?","","","mv_ch3","N",01,0,1,"C","","MV_PAR03","Sim"    ,"","","","","Nao","","","","","","","",""})
AADD(aRegs,{cPerg,"04","Informe o setor    ?","","","mv_ch4","N",01,0,0,"C","","MV_PAR04","1-Apoio","","","","MV_PAR04","2-Call Center","","","","MV_PAR04","3-Licitacoes","","","","MV_PAR04","4-Ambos","","",""})
AADD(aRegs,{cPerg,"05","Fornecedor         ?","","","mv_ch5","C",06,0,0,"G","","MV_PAR05",""       ,"","","","","","","","","","","","","","","","","","","","","","","","SA2"})
AADD(aRegs,{cPerg,"06","Grupo de Clientes  ?","","","mv_ch6","C",06,0,0,"G","","MV_PAR06",""       ,"","","","","","","","","","","","","","","","","","","","","","","","ACY"})
AADD(aRegs,{cPerg,"07","Por Carteira       ?","","","mv_ch7","N",01,0,1,"C","","MV_PAR07","Sim"    ,"","","","","Nao","","","","","","","",""})
AADD(aRegs,{cPerg,"08","De Cliente         ?","","","mv_ch8","C",06,0,0,"G","","MV_PAR08",""       ,"","","","","","","","","","","","","","","","","","","","","","","","SA1"})
AAdd(aRegs,{cPerg,"09","Ate Cliente        ?","","","mv_ch9","C",06,0,0,"G","","MV_PAR09",""       ,"","","","","","","","","","","","","","","","","","","","","","","","SA1"})
AADD(aRegs,{cPerg,"10","De Produto         ?","","","mv_chA","C",15,0,0,"G","","MV_PAR10",""       ,"","","","","","","","","","","","","","","","","","","","","","","","SB1"})
AAdd(aRegs,{cPerg,"11","Ate Produto        ?","","","mv_chB","C",15,0,0,"G","","MV_PAR11",""       ,"","","","","","","","","","","","","","","","","","","","","","","","SB1"})
AAdd(aRegs,{cPerg,"12","Mostra valores     ?","","","mv_chC","N",01,0,1,"C","","MV_PAR12","Sim"    ,"","","","","Nao","","","","","","","",""})
AADD(aRegs,{cPerg,"13","Carteira TODA      ?","","","mv_chD","N",01,0,1,"C","","MV_PAR13","Nao"    ,"","","","","Sim","","","","","","","",""})

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

*-----------------------------------------------------*
//MCVN - 18/09/08    
Static function DP26MailTec(cCodTec,cNomeTec,cEmail,cArquivo)
*-----------------------------------------------------*

//Local cArquivo  := ""
//Local cEmail	:
Local cAttach	:= {}
Local aMsg		:= {}
Local cAssunto	:= EncodeUTF8("Envio de relatÛrio dos TÈcnicos","cp1252")
Local lRetorno := .T.

aMsg := {} // LIMPA ARRAY PARA RECEBER NOVAMENTE O NOME DO REPRESENTANTE
cAttach := {} // LIMPA ARQUIVOS ENVIADOS

Aadd(cAttach,cArquivo) //  ATACHA APENAS OS 5 PRIMEIROS E MENORES RELAT”RIOS
//cEmail := "maximo.canuto@dipromed.com.br" // EMAIL DO REPRESENTANTES
		
  //	If File(cArquivo)
		Aadd(aMsg,{cCodTec, cNomeTec}) // NOME DO REPRESENTANTE
		lRetorno := DIP26EMail(cEmail,cAssunto,aMsg,cAttach)	// CHAMADA DA FUNÁ„O DE ENVIO DE EMAIL
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
/*Definicao do cabecalho do relatÛrio                                          */
/*=============================================================================*/

cMsg += '<table width="100%">'
cMsg += '<tr align="center">'
cMsg += '<td width="100%"><font color="blue">TÈcnico: ' + aMsg[1,1] + "-" + aMsg[1,2] + '</font></td>'
cMsg += '</tr>'
cMsg += '<tr align="center">'
cMsg += '<td width="95%">RelatÛrio de tÈcnico enviado automaticamente pelo sistema Protheus.<br>'
cMsg += 'Qualquer d˙vida ou esclarecimento entrar em contato com Fernanda - Supervisora Administrativa de Vendas.<br><br>'
cMsg += 'Atenciosamente<br><br>'
cMsg += '<font color="blue">Fernanda Ara˙jo</font><br><br>'
cMsg += '<font color="red">O ARQUIVO ANEXO DEVER¡ SER ABERTO NO  EXCEL !</font></td>'
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
		MsgInfo(cError,OemToAnsi("AtenÁ„o"))
	EndIf
	
	DISCONNECT SMTP SERVER
Else
	//Erro na conexao com o SMTP Server
	GET MAIL ERROR cError
	
	MsgInfo(cError,OemToAnsi("AtenÁ„o"))
EndIf 

Return(lResult)           

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥fQuery04() ∫Autor  ≥Maximo Canuto - MCVN∫ Data ≥ 01/03/2011 ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥Query para buscar a carteira toda do cliente   			  ∫±±
±±∫          ≥Se UserTec estiver preenchido, filtrar carteira por tÈcnica ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ Especifico - Faturamento - DIPROMED                        ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ  
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
QRY4 += "       A1_VENDHQ VENDEDOR," 
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

QRY4 += " FROM " 
QRY4 += RetSQLName("SA1") + ", "
QRY4 += RetSQLName("SX5") + ", "
QRY4 += RetSQLName("SA3")

QRY4 += " WHERE " + RetSQLName("SA1") + ".D_E_L_E_T_ = ''"
QRY4 += " AND " + RetSQLName("SX5") + ".D_E_L_E_T_ = ''"
QRY4 += " AND " + RetSQLName("SA3") + ".D_E_L_E_T_ = ''"
QRY4 += " AND X5_TABELA = 'T3'"
QRY4 += " AND X5_CHAVE =* A1_SATIV1 "  

QRY4 += " AND A1_VENDHQ = A3_COD "

If !Empty(cGrpCli)
	QRY4 += " AND A1_GRPVEN = '" +cGrpCli+"'"
EndIf

If U_ListVend() != ''
	QRY4 += " AND A1_VENDHQ " + U_ListVend()
EndIf

If !Empty(cVenDe) // VENDEDOR
	QRY4 += " AND A1_VENDHQ = '" + cVenDe + "'"                                    
Else
	If nSetor == 1 // APOIO
		QRY4 += " AND A3_TIPO = 'E'	"
	ElseIf nSetor == 2 // CALL CENTER
		QRY4 += " AND A3_TIPO = 'I' "
	ElseIf nSetor == 3 // LICITACOES	 						// Licitacoes     RBC 02/02/2021
	    QRY4 += " And C5_FILIAL = D2_FILIAL "					// Licitacoes    	RBC 02/02/2021
	    QRY4 += " And C5_NUM    = D2_PEDIDO "					// Licitacoes    	RBC 02/02/2021
	    QRY4 += " And SC5.D_E_L_E_T_ = '' "						// Licitacoes     	RBC 02/02/2021
	    QRY4 += " And UF_FILIAL = '" + xFilial('SU7') + "' "	// Licitacoes     RBC 02/02/2021
	    QRY4 += " And U7_COD = C5_OPERADO "						// Licitacoes    	RBC 02/02/2021
		QRY4 += " And U7_POSTO = '03' "							// Licitacoes     		RBC 02/02/2021
		QRY4 += " And SU7.D_E_L_E_T_ = '' "						// Licitacoes    	RBC 02/02/2021	
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
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥DIPR026   ∫Autor  ≥Microsiga           ∫ Data ≥  03/21/13   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥                                                            ∫±±
±±∫          ≥                                                            ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ AP                                                        ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
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

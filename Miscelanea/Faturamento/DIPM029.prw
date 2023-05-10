

#INCLUDE "RWMAKE.CH"
#INCLUDE "AP5MAIL.CH"
#INCLUDE "TBICONN.CH"

#DEFINE CR    chr(13)+chr(10) // Carreage Return (Fim de Linha)

User Function DIPM029(aWork)

//Declarando Vari·veis
Local   cUserAut  	:= ""
Local   aProdDFU3M 	:= {}
//---------------------------------------------------------------------------------------------------------------//'
Private TRB1		:=""
Private TRB2   		:=""
Private TRB3		:=""
Private TRB4		:=""
Private TRB2A		:=""

Private TRB3A		:=""
//---------------------------------------------------------------------------------------------------------------//
Private _cArqDEMA 	:= ""
Private _cArqMSKU 	:= ""
Private _cArqMDFU 	:= ""
Private _cArqCNFE 	:= ""
Private cWorkFlow 	:= ""
Private cWCodEmp  	:= ""
Private cWCodFil  	:= ""
//---------------------------------------------------------------------------------------------------------------//
Private _lCargaIni	:= 0
Private nDiaIni   	:= 1
Private nDiaFim   	:= 1
Private aSaldoEst 	:= {}
Private aProduto3M	:= {}
//---------------------------------------------------------------------------------------------------------------//
private nStart, nElapsed
Private aTrb2 		:= {}
Private aTrb2a 		:= {}
Private aTrb3 		:= {}
Private aTrb3a 		:= {}
Private aMsku 		:= {}
Private aMdfu 		:= {}
Private _cQuery1
Private _cQuery2
Private _cQuery3
Private _cQuery4
Private  nConvert 	:= 1
Private nDayDif  	:= 1
Private cResuDat 	:= " "
Private dWResuDat	:=""
Private cProdTud 	:= ""
Private dDate2 		:= ""
Private dIniDat		:= If (ValType(aWork) <> 'A',dDatabase,date()-1)
Private dFimDat		:= If (ValType(aWork) <> 'A',dDatabase,date()-1)
Private dDatDfu 	:= If (ValType(aWork) <> 'A',dDatabase,date()-1)
Private cPerg  		:= If (ValType(aWork) <> 'A',U_FPADR( "DIPM029","SX1","SX1->X1_GRUPO"," " ),"")
Private cFiTro 		:= " In ('01','04')  "
Private cPar03 		:= "N"
nStart:= SECONDS()

If ValType(aWork) <> 'A'
	U_DIPPROC(ProcName(0),U_DipUsr())
	cWorkFlow := "N"
	cWCodEmp  := cEmpAnt
	cWCodFil  := cFilAnt
	cUserAut  := GetMv('MV_DIPM029')
	
	_cArqDEMA := "\EDI\TEMP\X_"+Dtos( DDATABASE )+"_DPMD_dimdemanda1.txt "
	_cArqMSKU := "\EDI\TEMP\X_"+Dtos( DDATABASE )+"_DPMD_movim_sku.txt"
	_cArqMDFU := "\EDI\TEMP\X_"+Dtos( DDATABASE )+"_DPMD_movim_dfu.txt"
	_cArqCNFE := "\EDI\TEMP\X_"+Dtos( DDATABASE )+"_DPMD_confirm_receb.txt"
	
	U_DIPPROC(ProcName(0),U_DipUsr())
Else
	dIniDat		:= Date()
	dFimDat		:= Date()
	dDatDfu 	:= Date()
	cWorkFlow := aWork[1]
	cWCodEmp  := aWork[3]
	cWCodFil  := aWork[4]
	
	PREPARE ENVIRONMENT EMPRESA cWCodEmp FILIAL cWCodFil FUNNAME "DIPM029"
	ConOut("--------------------------")
	ConOut('DIPM029 agendado - Inicio Processamento-' +Time())
	ConOut("--------------------------")
	
	_cArqDEMA := "\EDI\TEMP\X_"+Dtos( Date() )+"_DPMD_dimdemanda1.txt "
	_cArqMSKU := "\EDI\TEMP\X_"+Dtos( Date() )+"_DPMD_movim_sku.txt"
	_cArqMDFU := "\EDI\TEMP\X_"+Dtos( Date() )+"_DPMD_movim_dfu.txt"
	_cArqCNFE := "\EDI\TEMP\X_"+Dtos( Date() )+"_DPMD_confirm_receb.txt"
Endif


If cWorkFlow == "N"
	
	If !AllTrim(Upper(U_DipUsr())) $ cUserAut
		MSGSTOP(AllTrim(Upper(U_DipUsr()))+", vocÍ n„o tem autorizaÁ„o para executar esta rotina!")
		Return
	EndIf
	
	_lCargaIni := Aviso("CONECTA-3M"+SPACE(24)+"NEOGRI","Selecione o tipo de arquivo que deseja gerar.",{"DI¡RIO","CARGA_INIC"})
	If _lCargaIni = 2
		
		AjustaSX1(cPerg)             // Verifica perguntas. Se nao existe INCLUI
		
		If !Pergunte(cPerg,.T.)    // Solicita parametros
			Return
		EndIf
		If MV_PAR03 = 2
			cPar03 := "N"
			cFiTro := " = '04' "
		EndIF
		
		dIniDat := MV_PAR01
		dFimDat := MV_PAR02
		dDatDfu := MV_PAR01
		nDayDif := DateDiffDay( dIniDat , dFimDat )
		nDayDif := nDayDif + 1
		If MV_PAR02 < MV_PAR01
			alert("Data final menor que Data Inicial !!!!!!!!")
			return(.f.)
		Endif
	Endif
	If _lCargaIni = 0
		Return(.F.)
	Endif
	// Verificando arquivos tempor·rios
	If Select("TRB1") > 0
		TRB1->( DbCloseArea() )
	EndIf
	
	If Select("TRB2") > 0
		TRB2->( DbCloseArea() )
	EndIf
	If Select("TRB2A") > 0
		TRB2->( DbCloseArea() )
	EndIf
	If Select("TRB3") > 0
		TRB3->( DbCloseArea() )
	EndIf
	
	If Select("TRB4") > 0
		TRB4->( DbCloseArea() )
	EndIf
	
	
	// Gerando arquivo de Dimens„o de Demanda - Clientes
		If !fQuery1()    // Se Retornar vazio
	Aviso('Dimens„o de Demanda - Clientes','Nao encontrado dados que satisfacam aos parametros informados!',{'Ok'})
	If Select("TRB1") > 0
	TRB1->( DbCloseArea() )
	EndIf
	Return(.F.)
	ElseIf !_lCargaIni == 2 // Se encontar registros v·lidos e n„o for carga inicial
	
	//GerDemanda() // Gerar arquivo de Dimens„o de Demanda
	Processa({|| GerDemanda()},"Gerando CD...demanda")
	EndIf
	//SKU;.;.;.;.;.;.;.;.;.;.;.;.;.;.;.;.;.
	
	
	
	If !fQuery2()  // Se Retornar vazio
	Aviso('MovimentaÁıes de SKU ','Nao encontrado dados que satisfacam aos parametros informados!',{'Ok'})
	If Select("TRB2") > 0
	TRB2->( DbCloseArea() )
	EndIf
	Return(.F.)
	Else // Se encontar registros v·lidos
	//	U_SaldEst29()
	//GerMovSKU() // Gerar arquivo de MovimentaÁıes SKU
	Processa({|| GerMovSKU()},"Gerando CD...sku")
	EndIf
	
	
	
	If !fQuery3()  // Se Retornar vazio
	//Aviso('MovimentaÁıes de DFU ','Nao encontrado dados que satisfacam aos parametros informados!',{'Ok'})
	If Select("TRB3") > 0
	TRB3->( DbCloseArea() )
	EndIf
	//Return(.F.)
	Else // Se encontar registros v·lidos
	Processa({|| GerMovDFU()},"Gerando CD...dfu")
	//	GerMovDFU() // Gerar arquivo de MovimentaÁıes DFU
	EndIf
	
	
	
	
	// Gerando arquivo de ConfirmaÁ„o de recebimento de NF
	If !fQuery4() // Se Retornar vazio
		//Aviso('ConfirmaÁ„o de Recebimento de NF','Nao encontrado dados que satisfacam aos parametros informados!',{'Ok'})
		If Select("TRB4") > 0
			TRB4->( DbCloseArea() )
		EndIf
		Return(.F.)
	ElseIf !_lCargaIni == 2 // Se encontar registros v·lidos e n„o for carga inicial
		//	GerConfNfe() // Gerar arquivo de ConfirmaÁ„o de recebimento de NF
		Processa({||GerConfNfe()},"Gerando CD...NF")
	EndIf
	
	If File(_cArqDEMA) .And. File(_cArqMSKU) .And. File(_cArqMDFU) .And. File(_cArqCNFE)
		//	Aviso('Processado Corretamente','Arquivos gerados com sucesso',{'Ok'})
	ElseIf File(_cArqMSKU) .And. File(_cArqMDFU)
		//	Aviso('Processado Corretamente','Arquivos de CARGA INICIAL gerados com sucesso',{'Ok'})
	Else
		//	Aviso('AtenÁ„o',' Os arquivos n„o foram gerados com sucesso',{'Ok'})
	Endif
	
Else  // Workflow
	
	// Verificando arquivos tempor·rios
	If Select("TRB1") > 0
		TRB1->( DbCloseArea() )
	EndIf
	
	If Select("TRB2") > 0
		TRB2->( DbCloseArea() )
	EndIf
	If Select("TRB2A") > 0
		TRB2->( DbCloseArea() )
	EndIf
	If Select("TRB3") > 0
		TRB3->( DbCloseArea() )
	EndIf
	
	If Select("TRB4") > 0
		TRB4->( DbCloseArea() )
	EndIf
	
	
	// Gerando arquivo de Dimens„o de Demanda - Clientes
	If !fQuery1()    // Se Retornar vazio
	If Select("TRB1") > 0
	TRB1->( DbCloseArea() )
	EndIf
	Else
	
	GerDemanda() // Gerar arquivo de Dimens„o de Demanda
	
	EndIf
	
	// Gerando arquivo de MovimentaÁıes SKU
	If !fQuery2()  // Se Retornar vazio
	If Select("TRB2") > 0
	TRB2->( DbCloseArea() )
	EndIf
	Else
	
	GerMovSKU()
	EndIf
	If !fQuery3()
	If Select("TRB3") > 0
	TRB3->( DbCloseArea() )
	EndIf
	
	Else
	
	GerMovDFU()
	EndIf
	
	
	// Gerando arquivo de ConfirmaÁ„o de recebimento de NF
	If !fQuery4()
		If Select("TRB4") > 0
			TRB4->( DbCloseArea() )
		EndIf
	Else
		GerConfNfe() // Gerar arquivo de ConfirmaÁ„o de recebimento de NF
	EndIf
	
	If File(_cArqDEMA) .And. File(_cArqMSKU) .And. File(_cArqMDFU) .And. File(_cArqCNFE)
		ConOut("--------------------------")
		ConOut('DIPM029 agendado - Fim do Processamento  - ARQUIVOS PROCESSADOS COM SUCESSO - ' +Time())
		ConOut("--------------------------")
	Else
		ConOut("--------------------------")
		ConOut('DIPM029 agendado - Fim do Processamento  - PROBLEMAS NO PROCESSAMENTO DOS ARQUIVOS - ' +Time())
		ConOut("--------------------------")
	Endif
	
Endif

If _lCargaIni <> 0
	u_DIPM029b(aWork,MV_PAR01,MV_PAR02,_lCargaIni)
Else
	u_DIPM029b(aWork)
EndIf

Return()

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa≥fQuery1() ∫Autor ≥Maximo Canuto V Neto-MCVN∫ Data ≥ 17/07/10  ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.   ≥ Busca cadastro completo de POS de venda, correspondente ¿    ∫±±
±±∫            ≥ venda nos ˙ltimos 2 anos(Cliente que compram 3M)         ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ Especifico Compras Dipromed                                ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
STATIC FUNCTION fQuery1()

If cWorkFlow = "N"
	dWResuDat:=	YearSub( DDATABASE , 2 )
Else
	dWResuDat:=	YearSub( DATE() , 2 )
EndIf

_cQuery1 := "	Select A1_COD, A1_CGC, A1_NOME, A1_CNAE,  'CC3_DESC' , (CASE WHEN A1_STATUS = '2'  THEN  'BLOQUEADO' ELSE 'ATIVO'  END ) A1_STATUS "
_cQuery1 += " FROM " + RETSQLNAME ("SA1") + " SA1 "

_cQuery1 += " INNER JOIN (Select * "
_cQuery1 += " FROM " + RETSQLNAME ("SD2") + " SD2 "
_cQuery1 += "	where D2_FILIAL in('01', '04') "

_cQuery1 += " and SD2.D2_EMISSAO >= '"+Dtos(dWResuDat)+"' "

_cQuery1 += " and SD2.D2_TIPO = 'N'  	"
_cQuery1 += " and SD2.D2_FORNEC IN ('000041','000609') "
_cQuery1 += " and SD2.D_E_L_E_T_ = ' ')TDA "
_cQuery1 += " ON  TDA.D2_CLIENTE = SA1.A1_COD	"
_cQuery1 += " AND TDA.D2_LOJA = SA1.A1_LOJA"

_cQuery1 += " INNER JOIN (Select *"
_cQuery1 += "	FROM " + RETSQLNAME ("SF4") + " SF4 "
_cQuery1 += "	where F4_ESTOQUE = 'S' "
_cQuery1 += "	and SF4.D_E_L_E_T_ = ' ')TAB "
_cQuery1 += " ON TAB.F4_FILIAL = TDA.D2_FILIAL "
_cQuery1 += " and TAB.F4_CODIGO = TDA.D2_TES "
_cQuery1 += " where A1_FILIAL = ' '   "
_cQuery1 += " and SA1.D_E_L_E_T_ = ' ' "
_cQuery1 += "	Group By A1_COD, A1_CGC, A1_NOME, A1_CNAE,A1_STATUS "
_cQuery1 += "	Order By A1_CGC "

dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQuery1),'TRB1',.T.,.F.)

TRB1->(dbgotop())


Return(!TRB1->( EOF().and.BOF()))

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥fQuery2()  ∫Autor  ≥Maximo Canuto V Neto-MCVN∫ Data ≥ 17/07/2010  ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.   ≥ MovimentaÁıes SKU (PosiÁao do Estoque) ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ Especifico Compras Dipromed                                ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
STATIC FUNCTION fQuery2()

Local cQuery := ""
Local aSaldo := {}
Local QTD_ESTOQUE := 0
Local PRC_COMPRA  := 0
Local lRest       := .f.
Local cVl010 	  := 0
Local cVl07 	  := 0
Local cVl06       := 0
Local cHQ         := "0404"
Local cDipro      := "0104"
Private cDasTes   := " "
Private dHq       := " "
Private nCatSl    := nDayDif

If !_lCargaIni == 2
	dIniDat:= DaySub( dIniDat , 8 )//retornar os 5 dias antes da data //giovani zago 08/11/11
	nDayDif:=(7+nDayDif)//giovani zago 08/11/11
EndIf
dIniDat:= DaySub( dIniDat , 1 )
dHq  :=dIniDat
For u:=1 To nDayDif
	dIniDat:= DaySum( dIniDat , 1 )
	cDasTes:= dtos (dIniDat)
	If cWorkFlow == "N"
		
		//Processa({|| 		u_sqlvi()  },"Gerando CD...SKU.sql")
		RptStatus({|| 	u_sqlvi()  },"Gerando CD...SKU.sql")
	else
		
		BeginSql Alias "TRB2"
			//EMPRESA 01 FILIAL 04
			Select  A5_CODPRF, A5_PRODUTO, '47869078000453'   LOCAL_EST,     %Exp:cDasTes% AS  DTREFER, A5_QTDUN3M AS  UN_MED_3M, A5_QTDUMDI AS UN_MED_DIPRO,
			(IsNull ( ( Select Sum(D2_QUANT)
			From SD2010 SD2, SF4010 SF4
			where D2_FILIAL = '04'    and D2_EMISSAO  =  %Exp:cDasTes%  and D2_TIPO = 'N' and D2_FORNEC IN ('000041','000609') and D2_COD = SA5.A5_PRODUTO and F4_CODIGO = D2_TES and F4_ESTOQUE = 'S'  and SD2.D_E_L_E_T_ = ' '  and SF4.D_E_L_E_T_ = ' '  and F4_FILIAL = D2_FILIAL GROUP BY D2_COD ),0)  ) QTDVEND,
			(IsNull ( (	Select Sum(D1_QUANT)
			From SD1010 SD1, SF4010 SF4
			where D1_FILIAL = '04'  and D1_DTDIGIT   =  %Exp:cDasTes%  and D1_TIPO = 'D' and D1_FORNECE IN ('000041','000609') and D1_COD = SA5.A5_PRODUTO and F4_CODIGO = D1_TES and F4_ESTOQUE = 'S' and SD1.D_E_L_E_T_ = ' '  and SF4.D_E_L_E_T_ = ' ' and F4_FILIAL = D1_FILIAL  GROUP BY D1_COD),0)    ) QTDDEVOL,
			//(IsNull((Select Sum(ZD_QUANT)
			//From SZD010 SZD
			//where ZD_FILIAL = '04'   and ZD_DATAEXC    =  %Exp:cDasTes%    and ZD_DATAEXC <> ZD_EMISSAO and ZD_ATUEST = 'S'  and ZD_COD = SA5.A5_PRODUTO  and ZD_NOTA+ZD_SERIE NOT IN (SELECT D1_NFORI+D1_SERIORI FROM SD1010 SD1 where D1_TIPO = 'D' and D1_FORNECE IN ('000041','000609') and  D1_FILIAL ='04' and SD1.D_E_L_E_T_ = ' '  ) and SZD.D_E_L_E_T_ = ' '    GROUP BY ZD_COD ),0))QTDDELET,
			0   QTDDELET,
			
			(IsNull ( ( Select Sum((D2_TOTAL)-D2_TOTAL*((CASE WHEN D2_PICM>0 THEN D2_PICM ELSE D2_ALIQSOL END)+D2_ALQIMP5+D2_ALQIMP6)/100)
			From SD2010 SD2, SF4010 SF4
			where D2_FILIAL = '04'    AND D2_FILIAL = F4_FILIAL and D2_EMISSAO    =  %Exp:cDasTes%  and D2_TIPO = 'N' and D2_FORNEC IN ('000041','000609') and D2_COD = SA5.A5_PRODUTO and F4_CODIGO = D2_TES and F4_ESTOQUE = 'S'  and SD2.D_E_L_E_T_ = ' '  and SF4.D_E_L_E_T_ = ' '  GROUP BY D2_COD ),0))  UNITARIO,
			( IsNull ( (SELECT TOP 1 B9_VINI1 From SB9010  SB9 where B9_FILIAL = '04'   and B9_LOCAL = '01' and B9_COD = SA5.A5_PRODUTO and B9_DATA    =  %Exp:cDasTes%   and SB9.D_E_L_E_T_ = ' '   Order by B9_DATA DESC  ),0)) B9_VINI1 ,
			(IsNull   ( (SELECT TOP 1 B9_QINI From SB9010  SB9 where B9_FILIAL = '04'  and B9_LOCAL = '01' and B9_COD = SA5.A5_PRODUTO and B9_DATA    =  %Exp:cDasTes%     and SB9. D_E_L_E_T_ = ' '   Order by B9_DATA DESC  ),0)) B9_QINI,
			
			(IsNull ( ( SELECT B1_CUSDIP FROM SB1010 SB1
			WHERE B1_COD  = A5_PRODUTO
			and B1_FILIAL = '04'
			and SB1.D_E_L_E_T_ = ' ' ),0)  ) CUSTO
			
			From SA5010 SA5
			where A5_FILIAL = ' '
			and A5_FORNECE in ('000041','000609')
			and Rtrim(lTrim(A5_CODPRF)) <> ' '
			and SA5.D_E_L_E_T_= ' '
			Order By A5_PRODUTO
			
		endsql
		GETLastQuery()[2]
	endif
	TRB2->( DbGoTop() )
	
	While !TRB2->(EOF())
		aSaldo := CalcEst(TRB2->A5_PRODUTO,"01",dIniDat+1) // Utilizamos DDATABASE+1 porque esta rotina retorna o Saldo Inicial do dia e n„o o Final
		
		Aadd( aSaldoEst  , {TRB2->A5_PRODUTO, aSaldo[1], aSaldo[2]} )
		
		QTD_ESTOQUE := (ASALDOEST[ASCAN(ASALDOEST, { |X| X[1] == TRB2->A5_PRODUTO }),2])
		PRC_COMPRA  := (ASALDOEST[ASCAN(ASALDOEST, { |X| X[1] == TRB2->A5_PRODUTO }),3]/ASALDOEST[ASCAN(ASALDOEST, { |X| X[1] == TRB2->A5_PRODUTO }),2] )
		If   "HB004045959" $ TRB2->A5_CODPRF
			nConvert := TRB2->UN_MED_DIPRO
			
		Else
			nConvert := 1
		EndIf
		
		Aadd( aTrb2  , {Alltrim(TRB2->A5_CODPRF),UPPER(Alltrim(TRB2-> LOCAL_EST)),Alltrim(TRB2->DTREFER), ;
		Alltrim(Transform(If(TRB2->QTDVEND <=0,0,If(TRB2->UN_MED_3M < TRB2->UN_MED_DIPRO,If(TRB2->QTDVEND<(TRB2->QTDDEVOL+TRB2->QTDDELET),0,TRB2->QTDVEND-(TRB2->QTDDEVOL+TRB2->QTDDELET))/TRB2->UN_MED_DIPRO*nConvert,If(TRB2->QTDVEND<(TRB2->QTDDEVOL+TRB2->QTDDELET),0,TRB2->QTDVEND-(TRB2->QTDDEVOL+TRB2->QTDDELET))*TRB2->UN_MED_3M)),'@E 9999999.999')),;
		Alltrim(Transform(If((TRB2->QTDDEVOL+TRB2->QTDDELET)<=0,0,If(TRB2->UN_MED_3M < TRB2->UN_MED_DIPRO,If(TRB2->QTDVEND<(TRB2->QTDDEVOL+TRB2->QTDDELET),(TRB2->QTDDEVOL+TRB2->QTDDELET)-TRB2->QTDVEND,0)/TRB2->UN_MED_DIPRO,If(TRB2->QTDVEND<(TRB2->QTDDEVOL+TRB2->QTDDELET),(TRB2->QTDDEVOL+TRB2->QTDDELET)-TRB2->QTDVEND,0)*TRB2->UN_MED_3M)),'@E 9999999.999')),;
		noround(If(TRB2->QTDVEND <=0,0,If(TRB2->UN_MED_3M > TRB2->UN_MED_DIPRO,((TRB2->CUSTO/TRB2->UN_MED_3M)*1.5)/nConvert,(( TRB2->CUSTO*TRB2->UN_MED_DIPRO)*1.5)))),;
		noround(If(TRB2->QTDVEND <=0,0,If(TRB2->UN_MED_3M > TRB2->UN_MED_DIPRO,((TRB2->CUSTO/TRB2->UN_MED_3M)*0.5)/nConvert,(( TRB2->CUSTO*TRB2->UN_MED_DIPRO)*0.5)))),;
		'0',                                                                                                           ;
		'0',                                                                                                           ;
		noround(If(TRB2->QTDVEND <=0,0,If(TRB2->UN_MED_3M > TRB2->UN_MED_DIPRO,((TRB2->CUSTO/TRB2->UN_MED_3M)),(( TRB2->CUSTO*TRB2->UN_MED_DIPRO))))),;
		Alltrim(Transform(If(TRB2->UN_MED_3M < TRB2->UN_MED_DIPRO,If(QTD_ESTOQUE<0,0,QTD_ESTOQUE/TRB2->UN_MED_DIPRO),If(QTD_ESTOQUE<0,0,QTD_ESTOQUE)*TRB2->UN_MED_3M),'@E 99999999.999'))})
		
		TRB2->( DbSkip() )
	End
	
	
	
	If Select("TRB2") > 0
		lRest:= .t.
		TRB2->( DbCloseArea() )
	EndIf
	
	aSaldo :={}
	aSaldoEst:={}
next u
If cPar03 = "S"
	If cWorkFlow == "N"
		GetEmpr(cHQ)   //troca empresa pra calcular o saldo na empresa correta
		
	Else
		DipSetEnv("04","04",.T.)
	EndIf
	
	dIniDat := dHq
	For e:=1 To nDayDif
		dIniDat:= DaySum( dIniDat , 1 )
		cDasTes:= dtos(dIniDat)
		//EMPRESA 04 FILIAL 04
		BeginSql Alias "TRB2"
			Select  A5_CODPRF, A5_PRODUTO, '47869078000453'   LOCAL_EST,    %Exp:cDasTes% AS  DTREFER, A5_QTDUN3M AS  UN_MED_3M, A5_QTDUMDI AS UN_MED_DIPRO,
			
			
			(IsNull ( ( Select Sum(D2_QUANT)
			From SD2040 SD2, SF4040 SF4
			where D2_FILIAL = '04'    and D2_EMISSAO  =  %Exp:cDasTes% and D2_TIPO = 'N' and D2_FORNEC IN ('000041','000609') and D2_COD = SA5.A5_PRODUTO and F4_CODIGO = D2_TES and F4_ESTOQUE = 'S'  and SD2.D_E_L_E_T_ = ' '  and SF4.D_E_L_E_T_ = ' '  and F4_FILIAL = D2_FILIAL GROUP BY D2_COD ),0)  ) QTDVEND,
			
			
			(IsNull ( (	Select Sum(D1_QUANT)
			From SD1040 SD1, SF4040 SF4
			where D1_FILIAL = '04'  and D1_DTDIGIT  =  %Exp:cDasTes% and D1_TIPO = 'D' and D1_FORNECE IN ('000041','000609') and D1_COD = SA5.A5_PRODUTO and F4_CODIGO = D1_TES and F4_ESTOQUE = 'S' and SD1.D_E_L_E_T_ = ' '  and SF4.D_E_L_E_T_ = ' ' and F4_FILIAL = D1_FILIAL  GROUP BY D1_COD),0)    ) QTDDEVOL,
			
			
			//	(IsNull((Select Sum(ZD_QUANT)
			//	From SZD040 SZD
			//	where ZD_FILIAL = '04'   and ZD_DATAEXC =  %Exp:cDasTes%    and ZD_DATAEXC <> ZD_EMISSAO and ZD_ATUEST = 'S'  and ZD_COD = SA5.A5_PRODUTO  and ZD_NOTA+ZD_SERIE NOT IN (SELECT D1_NFORI+D1_SERIORI FROM SD1040 SD1 where D1_TIPO = 'D' and D1_FORNECE IN ('000041','000609') and  D1_FILIAL ='04' and SD1.D_E_L_E_T_ = ' '  ) and SZD.D_E_L_E_T_ = ' '    GROUP BY ZD_COD ),0))QTDDELET,
			0 	QTDDELET,
			
			
			(IsNull ( ( Select Sum((D2_TOTAL)-D2_TOTAL*((CASE WHEN D2_PICM>0 THEN D2_PICM ELSE D2_ALIQSOL END)+D2_ALQIMP5+D2_ALQIMP6)/100)
			From SD2040 SD2, SF4040 SF4
			where D2_FILIAL = '04'    AND D2_FILIAL = F4_FILIAL and D2_EMISSAO   = %Exp:cDasTes% and D2_TIPO = 'N' and D2_FORNEC IN ('000041','000609') and D2_COD = SA5.A5_PRODUTO and F4_CODIGO = D2_TES and F4_ESTOQUE = 'S'  and SD2.D_E_L_E_T_ = ' '  and SF4.D_E_L_E_T_ = ' '  GROUP BY D2_COD ),0) ) UNITARIO,
			
			
			( IsNull ( (SELECT TOP 1 B9_VINI1 From SB9040  SB9 where B9_FILIAL = '04'   and B9_LOCAL = '01' and B9_COD = SA5.A5_PRODUTO and B9_DATA =  %Exp:cDasTes%  and SB9.D_E_L_E_T_ = ' '   Order by B9_DATA DESC  ),0)) B9_VINI1 ,
			
			(IsNull   ( (SELECT TOP 1 B9_QINI From SB9040  SB9 where B9_FILIAL = '04'  and B9_LOCAL = '01' and B9_COD = SA5.A5_PRODUTO and B9_DATA  =  %Exp:cDasTes%    and SB9. D_E_L_E_T_ = ' '   Order by B9_DATA DESC  ),0)) B9_QINI,
			
			(IsNull ( ( SELECT B1_CUSDIP FROM SB1010 SB1
			WHERE B1_COD  = A5_PRODUTO
			and B1_FILIAL = '04'
			and SB1.D_E_L_E_T_ = ' ' ),0)  ) CUSTO
			
			From SA5010 SA5
			
			where A5_FILIAL = ' '
			and A5_FORNECE in ('000041','000609')
			and Rtrim(lTrim(A5_CODPRF)) <> ' '
			and SA5.D_E_L_E_T_= ' '
			Order By A5_PRODUTO
		EndSql
		cQuery := GETLastQuery()[2]
		
		
		
		
		TRB2->( DbGoTop() )
		While !TRB2->(EOF())
			aSaldo := CalcEst(TRB2->A5_PRODUTO,"01",dIniDat+1) // Utilizamos DDATABASE+1 porque esta rotina retorna o Saldo Inicial do dia e n„o o Final
			
			Aadd( aSaldoEst  , {TRB2->A5_PRODUTO, aSaldo[1], aSaldo[2]} )
			
			QTD_ESTOQUE := (ASALDOEST[ASCAN(ASALDOEST, { |X| X[1] == TRB2->A5_PRODUTO }),2])
			PRC_COMPRA  := (ASALDOEST[ASCAN(ASALDOEST, { |X| X[1] == TRB2->A5_PRODUTO }),3]/ASALDOEST[ASCAN(ASALDOEST, { |X| X[1] == TRB2->A5_PRODUTO }),2] )
			
			If   "HB004045959" $ TRB2->A5_CODPRF
				nConvert := TRB2->UN_MED_DIPRO
				
			Else
				nConvert := 1
			EndIf
			
			Aadd( aTrb2a  , {Alltrim(TRB2->A5_CODPRF),UPPER(Alltrim(TRB2-> LOCAL_EST)),Alltrim(TRB2->DTREFER), ;
			Alltrim(Transform(If(TRB2->QTDVEND <=0,0,If(TRB2->UN_MED_3M < TRB2->UN_MED_DIPRO,If(TRB2->QTDVEND<(TRB2->QTDDEVOL+TRB2->QTDDELET),0,TRB2->QTDVEND-(TRB2->QTDDEVOL+TRB2->QTDDELET))/TRB2->UN_MED_DIPRO*nConvert,If(TRB2->QTDVEND<(TRB2->QTDDEVOL+TRB2->QTDDELET),0,TRB2->QTDVEND-(TRB2->QTDDEVOL+TRB2->QTDDELET))*TRB2->UN_MED_DIPRO)),'@E 9999999.999')),;
			Alltrim(Transform(If((TRB2->QTDDEVOL+TRB2->QTDDELET)<=0,0,If(TRB2->UN_MED_3M < TRB2->UN_MED_DIPRO,If(TRB2->QTDVEND<(TRB2->QTDDEVOL+TRB2->QTDDELET),(TRB2->QTDDEVOL+TRB2->QTDDELET)-TRB2->QTDVEND,0)/TRB2->UN_MED_DIPRO,If(TRB2->QTDVEND<(TRB2->QTDDEVOL+TRB2->QTDDELET),(TRB2->QTDDEVOL+TRB2->QTDDELET)-TRB2->QTDVEND,0)*TRB2->UN_MED_DIPRO)),'@E 9999999.999')),;
			noround(If(TRB2->QTDVEND <=0,0,If(TRB2->UN_MED_3M > TRB2->UN_MED_DIPRO,((TRB2->CUSTO/TRB2->UN_MED_3M)*1.5)/nConvert,(( TRB2->CUSTO*TRB2->UN_MED_DIPRO)*1.5)))),;
			noround(If(TRB2->QTDVEND <=0,0,If(TRB2->UN_MED_3M > TRB2->UN_MED_DIPRO,((TRB2->CUSTO/TRB2->UN_MED_3M)*0.5)/nConvert,(( TRB2->CUSTO*TRB2->UN_MED_DIPRO)*0.5)))),;
			'0',                                                                                                           ;
			'0',                                                                                                           ;
			noround(If(TRB2->QTDVEND <=0,0,If(TRB2->UN_MED_3M > TRB2->UN_MED_DIPRO,((TRB2->CUSTO/TRB2->UN_MED_3M)),(( TRB2->CUSTO*TRB2->UN_MED_DIPRO))))),;
			Alltrim(Transform(If(TRB2->UN_MED_3M < TRB2->UN_MED_DIPRO,If(QTD_ESTOQUE<0,0,QTD_ESTOQUE/TRB2->UN_MED_DIPRO),If(QTD_ESTOQUE<0,0,QTD_ESTOQUE)*TRB2->UN_MED_3M),'@E 99999999.999'))})
			
			TRB2->( DbSkip() )
		End
		
		
		
		If Select("TRB2") > 0
			TRB2->( DbCloseArea() )
		EndIf
		
		aSaldo :={}
		aSaldoEst:={}
	next e
	
	If cWorkFlow == "N"
		GetEmpr(cDipro)//volta a empresa
	Else
		DipSetEnv("01","04",.T.)
	EndIf
	
	For f:= 1 to len(aTrb2)
		
		For g:= 1 to len(aTrb2a)
			
			If aTrb2[f][1] = aTrb2a[g][1] .And. aTrb2[f][2] = aTrb2a[g][2] .And. aTrb2[f][3] = aTrb2a[g][3]
				If aTrb2[f][6] <> 0 .and.  aTrb2a[g][6] <> 0
					cVl06:= 	Alltrim(Transform(round(( aTrb2[f][6]+ aTrb2a[g][6])/2,2) ,'@E 99999999.99'))
				ElseIf  aTrb2[f][6]>0
					cVl06:=	Alltrim(Transform(round( aTrb2[f][6],2) ,'@E 99999999.99'))
				Else
					cVl06:= 	Alltrim(Transform( round(aTrb2a[g][6],2) ,'@E 99999999.99'))
				EndIf
				If  aTrb2[f][7] <> 0 .and.  aTrb2a[g][7] <> 0
					cVl07:= 	Alltrim(Transform(round( (aTrb2[f][7]+ aTrb2a[g][7])/2,2) ,'@E 99999999.99')  )
				ElseIf aTrb2[f][7]>0
					cVl07:=	Alltrim(Transform( round(aTrb2[f][7],2) ,'@E 99999999.99'))
				Else
					cVl07:= 	Alltrim(Transform( round(aTrb2a[g][7],2) ,'@E 99999999.99'))
				EndIf
				If  aTrb2[f][10] <> 0 .and.  aTrb2a[g][10] <> 0
					cVl010:= 	Alltrim(Transform(round( (aTrb2[f][10]+ aTrb2a[g][10])/2,2) ,'@E 99999999.99')  )
				ElseIf aTrb2[f][10]>0
					cVl010:=	Alltrim(Transform( round(aTrb2[f][10],2) ,'@E 99999999.99'))
				Else
					cVl010:= 	Alltrim(Transform( round(aTrb2a[g][10],2) ,'@E 99999999.99'))
				EndIf
				
				
				Aadd(aMsku,{aTrb2[f][1],;
				aTrb2[f][2],;
				aTrb2[f][3],;
				cvaltochar(val(aTrb2[f][4])+val(aTrb2a[g][4])),;
				cvaltochar(val(aTrb2[f][5])+val(aTrb2a[g][5])),;
				cvaltochar(	cVl06),;
				cvaltochar(	cVl07),;
				cvaltochar(val(aTrb2[f][8])+val(aTrb2a[g][8])),;
				cvaltochar(val(aTrb2[f][9])+val(aTrb2a[g][9])),;
				cvaltochar(cVl010),;
				cvaltochar(val(aTrb2[f][11])+val(aTrb2a[g][11]))})
				
				cVl06:= ""
				cVl07:= ""
				cVl010:=  ""
				
			EndIf
		Next g
	Next f
	
Else
	For f:= 1 to len(aTrb2)
		
		cVl06:=	Alltrim(Transform(round( aTrb2[f][6],2) ,'@E 99999999.99'))
		
		cVl07:=	Alltrim(Transform( round(aTrb2[f][7],2) ,'@E 99999999.99'))
		
		cVl010:=	Alltrim(Transform( round(aTrb2[f][10],2) ,'@E 99999999.99'))
		
		Aadd(aMsku,{aTrb2[f][1],;
		aTrb2[f][2],;
		aTrb2[f][3],;
		aTrb2[f][4],;
		aTrb2[f][5],;
		cvaltochar(	cVl06),;
		cvaltochar(	cVl07),;
		aTrb2[f][8],;
		aTrb2[f][9],;
		cvaltochar(cVl010),;
		aTrb2[f][11]})
		
		cVl06:= ""
		cVl07:= ""
		cVl010:=  ""
		
		
	Next f
EndIf
nDayDif := nCatSl
Return(lRest)


/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥fQuery3()  ∫Autor  ≥Maximo Canuto -MCVN∫ Data ≥ 17/07/2010  ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.   ≥ MovimentaÁıes DFU (PosiÁao do Estoque por Cliente)           ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ Especifico Compras Dipromed                                ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
STATIC FUNCTION fQuery3(cProdDFU3M)

Local cQuery 		:= ""
Local aSaldo 		:= {}
Local PRC_COMPRA  	:= 0
Local lRest 		:= .f.
Local cVl08 		:= 0
Local cVl07 		:= 0
Local cHQ         	:= "0404"
Local cDipro      	:= "0104"
Private cDasTes     := ""
Private dHq 		:= ""
Private cCodDif		:= ""
dIniDat := dDatDfu
If cWorkFlow == "N"
	If !_lCargaIni == 2
		dIniDat:= DaySub( dIniDat , 8 )//retornar os 5 dias antes da data //giovani zago 08/11/11
		nDayDif:=(7+nDayDif)//giovani zago 08/11/11
	Else
		dIniDat:= DaySub( dIniDat , 1 )
	EndIf
Else
	dIniDat:= DaySub( dIniDat , 8 )//giovani zago 08/11/11
	nDayDif:=(7+nDayDif)//giovani zago 08/11/11
EndIf
dHq  :=dIniDat
For u:=1 To nDayDif
	dIniDat:= DaySum( dIniDat , 1 )
	cDasTes:= dtos (dIniDat)
	If cWorkFlow == "N"
		
		
		Processa({|| 		u_Sqllk30103()  },"Gerando CD...SKU.sql")
	else
		BeginSql Alias "TRB3"
			Select A5_CODPRF, A5_PRODUTO,  A1_CGC, A1_COD,   '47869078000453'   LOCAL_EST,   %Exp:cDasTes%  DTREFER, A5_QTDUN3M AS  UN_MED_3M, A5_QTDUMDI AS UN_MED_DIPRO,
			
			
			IsNull ( ( Select Sum(D2_QUANT)
			From SD2010 SD2, SF4010 SF4
			where D2_FILIAL = '04' AND D2_LOCAL = '01' AND D2_FILIAL = F4_FILIAL and D2_EMISSAO = %Exp:cDasTes%    and D2_TIPO = 'N'  	and D2_FORNEC IN ('000041','000609') and D2_COD = SA5.A5_PRODUTO and D2_CLIENTE = SA1.A1_COD  and F4_CODIGO = D2_TES and F4_ESTOQUE = 'S' and SD2.D_E_L_E_T_ = ' '  and SF4.D_E_L_E_T_ = ' '  GROUP BY D2_COD ),0) QTDVEND,
			
			
			
			IsNull ( (	Select Sum(D1_QUANT)
			From SD1010 SD1,SF4010 SF4
			where D1_FILIAL = '04' AND D1_LOCAL = '01' AND D1_FILIAL = F4_FILIAL and D1_DTDIGIT = %Exp:cDasTes%   and D1_TIPO = 'D'  	and D1_FORNECE IN ('000041','000609') and D1_COD = SA5.A5_PRODUTO and D1_FORNECE = SA1.A1_COD   and F4_CODIGO = D1_TES and F4_ESTOQUE = 'S' and SD1.D_E_L_E_T_ = '  '  and SF4.D_E_L_E_T_ = '  '    GROUP BY D1_COD),0) QTDDEVOL,
			
			
			
			//	IsNull((Select Sum(ZD_QUANT)
			//	From SZD010 SZD
			//	where ZD_FILIAL = '04' and ZD_DATAEXC = %Exp:cDasTes%   and ZD_DATAEXC > ZD_EMISSAO+5 and ZD_ATUEST = 'S'  and ZD_COD = SA5.A5_PRODUTO   and ZD_CLIENTE = SA1.A1_COD and ZD_NOTA+ZD_SERIE NOT IN (SELECT D1_NFORI+D1_SERIORI FROM SD1010 SD1 where D1_TIPO = 'D' and D1_FORNECE IN ('000041','000609') and SD1.D_E_L_E_T_ = '  '  ) and SZD.D_E_L_E_T_ = '  '    GROUP BY ZD_COD ),0) QTDDELET,
			0 QTDDELET ,
			
			
			IsNull ( (	Select Sum((D2_TOTAL)-D2_TOTAL*((CASE WHEN D2_PICM>0 THEN D2_PICM ELSE D2_ALIQSOL END)+D2_ALQIMP5+D2_ALQIMP6)/100)
			From SD2010 SD2, SF4010 SF4
			where D2_FILIAL = '04' AND D2_LOCAL = '01'  AND D2_FILIAL = F4_FILIAL and D2_EMISSAO  = %Exp:cDasTes%   and D2_TIPO = 'N'  and D2_FORNEC IN ('000041','000609') and D2_COD = SA5.A5_PRODUTO and D2_CLIENTE = SA1.A1_COD  and F4_CODIGO = D2_TES and F4_ESTOQUE = 'S' and SD2.D_E_L_E_T_ = '  '  and SF4.D_E_L_E_T_ = '  '   GROUP BY D2_COD ),0) 	UNITARIO,
			
			(IsNull ( ( SELECT B1_CUSDIP FROM SB1010 SB1
			WHERE B1_COD  = A5_PRODUTO
			and B1_FILIAL = '04'
			and SB1.D_E_L_E_T_ = ' ' ),0)  ) CUSTO
			From SA5010 SA5
			
			
			Inner Join SA1010 SA1 on A1_FILIAL = ' '
			
			and 	(A1_COD    IN (	Select D2_CLIENTE
			From SD2010 SD2, SF4010 SF4
			where D2_FILIAL = '04'  and D2_EMISSAO  = %Exp:cDasTes% AND D2_LOCAL = '01'  and D2_TIPO = 'N'  	and D2_FORNEC IN ('000041','000609') and D2_COD = SA5.A5_PRODUTO  and D2_CLIENTE = SA1.A1_COD  and F4_CODIGO = D2_TES and F4_ESTOQUE = 'S' and SD2.D_E_L_E_T_ = ' ' and SF4.D_E_L_E_T_ = ' '  GROUP BY D2_COD, D2_CLIENTE)
			OR A1_COD  IN (	Select D1_FORNECE
			From SD1010 SD1, SF4010 SF4
			where D1_FILIAL = '04'  and D1_DTDIGIT = %Exp:cDasTes%  AND D1_LOCAL = '01'  and D1_TIPO = 'D'  	and D1_FORNECE IN ('000041','000609') and D1_COD = SA5.A5_PRODUTO  and D1_FORNECE = SA1.A1_COD   and F4_CODIGO = D1_TES and F4_ESTOQUE = 'S' and F4_FILIAL = '04' and SD1.D_E_L_E_T_ = ' ' and SF4.D_E_L_E_T_ = ' '   GROUP BY D1_COD, D1_FORNECE))
			
			and SA1.D_E_L_E_T_ = ' '
			
			where A5_FILIAL = ' '
			and A5_FORNECE in ('000041','000609')
			and Rtrim(lTrim(A5_CODPRF)) <> ' '
			
			and SA5.D_E_L_E_T_ = '  '
			GROUP BY A5_PRODUTO, A1_CGC ,A5_CODPRF,  A1_COD,  A5_QTDUN3M, A5_QTDUMDI
			Order By A5_PRODUTO, A1_CGC
			
			
		endsql
		GETLastQuery()[3]
	endif
	TRB3->(dbgotop())
	While !TRB3->(EOF())
		If TRB3->QTDVEND > 0 .Or. (TRB3->QTDDEVOL+TRB3->QTDDELET) > 0
			aSaldo := CalcEst(TRB3->A5_PRODUTO,"01",dIniDat+1) // Utilizamos DDATABASE+1 porque esta rotina retorna o Saldo Inicial do dia e n„o o Final
			
			Aadd( aSaldoEst  , {TRB3->A5_PRODUTO, aSaldo[1], aSaldo[2]} )
			
			If   "HB004045959" $ TRB3->A5_CODPRF
				nConvert := TRB3->UN_MED_DIPRO
				
			Else
				nConvert := 1
			EndIf
			
			PRC_COMPRA  := (ASALDOEST[ASCAN(ASALDOEST, { |X| X[1] == TRB3->A5_PRODUTO }),3]/ASALDOEST[ASCAN(ASALDOEST, { |X| X[1] == TRB3->A5_PRODUTO }),2] )
			
			Aadd( aTrb3  , {Alltrim(TRB3->A5_CODPRF),Alltrim(A1_CGC),UPPER(Alltrim(TRB3-> LOCAL_EST)),Alltrim(TRB3->DTREFER),;
			Alltrim(Transform(If(TRB3->QTDVEND <=0,0,If(TRB3->UN_MED_3M < TRB3->UN_MED_DIPRO,If(TRB3->QTDVEND<(TRB3->QTDDEVOL+TRB3->QTDDELET),0,TRB3->QTDVEND-(TRB3->QTDDEVOL+TRB3->QTDDELET))/TRB3->UN_MED_DIPRO*nConvert,If(TRB3->QTDVEND<(TRB3->QTDDEVOL+TRB3->QTDDELET),0,TRB3->QTDVEND-(TRB3->QTDDEVOL+TRB3->QTDDELET))*TRB3->UN_MED_3M)),'@E 9999999.999')),;
			Alltrim(Transform(If((TRB3->QTDDEVOL+TRB3->QTDDELET)<=0,0,If(TRB3->UN_MED_3M < TRB3->UN_MED_DIPRO,If(TRB3->QTDVEND<(TRB3->QTDDEVOL+TRB3->QTDDELET),(TRB3->QTDDEVOL+TRB3->QTDDELET)-TRB3->QTDVEND,0)/TRB3->UN_MED_DIPRO,If(TRB3->QTDVEND<(TRB3->QTDDEVOL+TRB3->QTDDELET),(TRB3->QTDDEVOL+TRB3->QTDDELET)-TRB3->QTDVEND,0)*TRB3->UN_MED_3M)),'@E 9999999.999')),;
			noround(If(TRB3->QTDVEND <=0,0,If(TRB3->UN_MED_3M > TRB3->UN_MED_DIPRO,((TRB3->CUSTO/TRB3->UN_MED_3M)*1.5)/nConvert,(( TRB3->CUSTO*TRB3->UN_MED_DIPRO)*1.5)))),;
			noround(If(TRB3->QTDVEND <=0,0,If(TRB3->UN_MED_3M > TRB3->UN_MED_DIPRO,((TRB3->CUSTO/TRB3->UN_MED_3M)*0.5)/nConvert,(( TRB3->CUSTO*TRB3->UN_MED_DIPRO)*0.5)))),;
			UPPER(Alltrim(TRB3-> LOCAL_EST)) })
			
		Endif
		//	noround(If(TRB3->QTDVEND <=0,0,TRB3->CUSTO*1.5)), ;
		//	noround(If(TRB3->QTDVEND <=0,0,TRB3->CUSTO*0.5)), ;
		TRB3->( DbSkip() )
	End
	
	
	If Select("TRB3") > 0
		TRB3->( DbCloseArea() )
	EndIf
	
	aSaldo :={}
	aSaldoEst:={}
next u
If cPar03 = "S"
	If cWorkFlow == "N"
		GetEmpr(cHQ)   //troca empresa pra calcular o saldo na empresa correta
	Else
		DipSetEnv("04","04",.T.)
	EndIf
	
	dIniDat := dHq
	For i:=1 To nDayDif
		dIniDat:= DaySum( dIniDat , 1 )
		cDasTes:= dtos(dIniDat)
		//EMPRESA 04 FILIAL 04
		//******************************************************************************************************
		
		BeginSql Alias "TRB3"
			Select A5_CODPRF, A5_PRODUTO,  A1_CGC, A1_COD,   '47869078000453'   LOCAL_EST,   %Exp:cDasTes%  DTREFER, A5_QTDUN3M AS  UN_MED_3M, A5_QTDUMDI AS UN_MED_DIPRO,
			
			
			IsNull ( ( Select Sum(D2_QUANT)
			From SD2040 SD2, SF4040 SF4
			where D2_FILIAL = '04' AND D2_LOCAL = '01' AND D2_FILIAL = F4_FILIAL and D2_EMISSAO = %Exp:cDasTes%    and D2_TIPO = 'N'  	and D2_FORNEC IN ('000041','000609') and D2_COD = SA5.A5_PRODUTO and D2_CLIENTE = SA1.A1_COD  and F4_CODIGO = D2_TES and F4_ESTOQUE = 'S' and SD2.D_E_L_E_T_ = ' '  and SF4.D_E_L_E_T_ = ' '  GROUP BY D2_COD ),0) QTDVEND,
			
			
			
			IsNull ( (	Select Sum(D1_QUANT)
			From SD1040 SD1,SF4040 SF4
			where D1_FILIAL = '04' AND D1_LOCAL = '01' AND D1_FILIAL = F4_FILIAL and D1_DTDIGIT = %Exp:cDasTes%   and D1_TIPO = 'D'  	and D1_FORNECE IN ('000041','000609') and D1_COD = SA5.A5_PRODUTO and D1_FORNECE = SA1.A1_COD   and F4_CODIGO = D1_TES and F4_ESTOQUE = 'S' and SD1.D_E_L_E_T_ = '  '  and SF4.D_E_L_E_T_ = '  '    GROUP BY D1_COD),0) QTDDEVOL,
			
			
			
			//	IsNull((Select Sum(ZD_QUANT)
			//	From SZD040 SZD
			//	where ZD_FILIAL = '04' and ZD_DATAEXC = %Exp:cDasTes%   and ZD_DATAEXC > ZD_EMISSAO+5 and ZD_ATUEST = 'S'  and ZD_COD = SA5.A5_PRODUTO   and ZD_CLIENTE = SA1.A1_COD and ZD_NOTA+ZD_SERIE NOT IN (SELECT D1_NFORI+D1_SERIORI FROM SD1010 SD1 where D1_TIPO = 'D' and D1_FORNECE IN ('000041','000609') and SD1.D_E_L_E_T_ = '  '  ) and SZD.D_E_L_E_T_ = '  '    GROUP BY ZD_COD ),0) QTDDELET,
			0 QTDDELET,
			
			
			IsNull ( (	Select Sum((D2_TOTAL)-D2_TOTAL*((CASE WHEN D2_PICM>0 THEN D2_PICM ELSE D2_ALIQSOL END)+D2_ALQIMP5+D2_ALQIMP6)/100)
			From SD2010 SD2, SF4010 SF4
			where D2_FILIAL = '04' AND D2_LOCAL = '01'  AND D2_FILIAL = F4_FILIAL and D2_EMISSAO  = %Exp:cDasTes%  and D2_TIPO = 'N'  and D2_FORNEC IN ('000041','000609') and D2_COD = SA5.A5_PRODUTO and D2_CLIENTE = SA1.A1_COD  and F4_CODIGO = D2_TES and F4_ESTOQUE = 'S' and SD2.D_E_L_E_T_ = '  '  and SF4.D_E_L_E_T_ = '  '   GROUP BY D2_COD ),0) 	UNITARIO
			
			(IsNull ( ( SELECT B1_CUSDIP FROM SB1010 SB1
			WHERE B1_COD  = A5_PRODUTO
			and B1_FILIAL = '04'
			and SB1.D_E_L_E_T_ = ' ' ),0)  ) CUSTO
			From SA5010 SA5
			
			
			Inner Join SA1010 SA1 on A1_FILIAL = ' '
			
			and 	(A1_COD    IN (	Select D2_CLIENTE
			From SD2040 SD2, SF4040 SF4
			where D2_FILIAL = '04'  and D2_EMISSAO  = %Exp:cDasTes% AND D2_LOCAL = '01'  and D2_TIPO = 'N'  	and D2_FORNEC IN ('000041','000609') and D2_COD = SA5.A5_PRODUTO  and D2_CLIENTE = SA1.A1_COD  and F4_CODIGO = D2_TES and F4_ESTOQUE = 'S' and SD2.D_E_L_E_T_ = ' ' and SF4.D_E_L_E_T_ = ' '  GROUP BY D2_COD, D2_CLIENTE)
			OR A1_COD  IN (	Select D1_FORNECE
			From SD1040 SD1, SF4040 SF4
			where D1_FILIAL = '04'  and D1_DTDIGIT = %Exp:cDasTes%  AND D1_LOCAL = '01'  and D1_TIPO = 'D'  	and D1_FORNECE IN ('000041','000609') and D1_COD = SA5.A5_PRODUTO  and D1_FORNECE = SA1.A1_COD   and F4_CODIGO = D1_TES and F4_ESTOQUE = 'S' and F4_FILIAL = '04' and SD1.D_E_L_E_T_ = ' ' and SF4.D_E_L_E_T_ = ' '   GROUP BY D1_COD, D1_FORNECE))
			
			and SA1.D_E_L_E_T_ = ' '
			
			where A5_FILIAL = ' '
			and A5_FORNECE in ('000041','000609')
			and Rtrim(lTrim(A5_CODPRF)) <> ' '
			
			and SA5.D_E_L_E_T_ = '  '
			GROUP BY A5_PRODUTO, A1_CGC ,A5_CODPRF,  A1_COD,  A5_QTDUN3M, A5_QTDUMDI
			Order By A5_PRODUTO, A1_CGC
			
			
			
			
		EndSql
		cQuery := GETLastQuery()[3]
		
		TRB3->(dbgotop())
		While !TRB3->(EOF())
			If TRB3->QTDVEND > 0 .Or. (TRB3->QTDDEVOL+TRB3->QTDDELET) > 0
				aSaldo := CalcEst(TRB3->A5_PRODUTO,"01",dIniDat+1) // Utilizamos DDATABASE+1 porque esta rotina retorna o Saldo Inicial do dia e n„o o Final
				
				Aadd( aSaldoEst  , {TRB3->A5_PRODUTO, aSaldo[1], aSaldo[2]} )
				If   "HB004045959" $ TRB3->A5_CODPRF
					nConvert := TRB3->UN_MED_DIPRO
					
				Else
					nConvert := 1
				EndIf
				PRC_COMPRA  := (ASALDOEST[ASCAN(ASALDOEST, { |X| X[1] == TRB3->A5_PRODUTO }),3]/ASALDOEST[ASCAN(ASALDOEST, { |X| X[1] == TRB3->A5_PRODUTO }),2] )
				
				Aadd( aTrb3a  , {Alltrim(TRB3->A5_CODPRF),Alltrim(A1_CGC),UPPER(Alltrim(TRB3-> LOCAL_EST)),Alltrim(TRB3->DTREFER),;
				Alltrim(Transform(If(TRB3->QTDVEND <=0,0,If(TRB3->UN_MED_3M < TRB3->UN_MED_DIPRO,If(TRB3->QTDVEND<(TRB3->QTDDEVOL+TRB3->QTDDELET),0,TRB3->QTDVEND-(TRB3->QTDDEVOL+TRB3->QTDDELET))/TRB3->UN_MED_DIPRO*nConvert,If(TRB3->QTDVEND<(TRB3->QTDDEVOL+TRB3->QTDDELET),0,TRB3->QTDVEND-(TRB3->QTDDEVOL+TRB3->QTDDELET))*TRB3->UN_MED_3M)),'@E 9999999.999')),;
				Alltrim(Transform(If((TRB3->QTDDEVOL+TRB3->QTDDELET)<=0,0,If(TRB3->UN_MED_3M < TRB3->UN_MED_DIPRO,If(TRB3->QTDVEND<(TRB3->QTDDEVOL+TRB3->QTDDELET),(TRB3->QTDDEVOL+TRB3->QTDDELET)-TRB3->QTDVEND,0)/TRB3->UN_MED_DIPRO,If(TRB3->QTDVEND<(TRB3->QTDDEVOL+TRB3->QTDDELET),(TRB3->QTDDEVOL+TRB3->QTDDELET)-TRB3->QTDVEND,0)*TRB3->UN_MED_3M)),'@E 9999999.999')),;
				noround(If(TRB3->QTDVEND <=0,0,If(TRB3->UN_MED_3M > TRB3->UN_MED_DIPRO,((TRB3->CUSTO/TRB3->UN_MED_3M)*1.5)/nConvert,(( TRB3->CUSTO*TRB3->UN_MED_DIPRO)*1.5)))),;
				noround(If(TRB3->QTDVEND <=0,0,If(TRB3->UN_MED_3M > TRB3->UN_MED_DIPRO,((TRB3->CUSTO/TRB3->UN_MED_3M)*0.5)/nConvert,(( TRB3->CUSTO*TRB3->UN_MED_DIPRO)*0.5)))),;
				UPPER(Alltrim(TRB3-> LOCAL_EST)) })
				
			Endif
			TRB3->( DbSkip() )
		End
		
		
		If Select("TRB3") > 0
			TRB3->( DbCloseArea() )
		EndIf
		
		aSaldo :={}
		aSaldoEst:={}
	next i
	
	
	If cWorkFlow == "N"
		GetEmpr(cDipro)//volta a empresa
	Else
		DipSetEnv("01","04",.T.)
	EndIf
	
EndIf
For f:= 1 to len(aTrb3)
	
	For g:= 1 to len(aTrb3a)
		
		If aTrb3[f][1] = aTrb3a[g][1] .And. aTrb3[f][2] = aTrb3a[g][2] .And. aTrb3[f][4] = aTrb3a[g][4]
			cCodDif:=   cCodDif+"/"+aTrb3[f][1]+aTrb3[f][2] + aTrb3[f][4]
			If  aTrb3[f][7] <> 0 .and.  aTrb3a[g][7] <> 0
				cVl07:= 	Alltrim(Transform(round( (aTrb3[f][7]+ aTrb3a[g][7])/2,2) ,'@E 99999999.99')  )
			ElseIf aTrb3[f][7]>0
				cVl07:=	Alltrim(Transform( round(aTrb3[f][7],2) ,'@E 99999999.99'))
			Else
				cVl07:= 	Alltrim(Transform( round(aTrb3a[g][7],2) ,'@E 99999999.99'))
			EndIf
			If  aTrb3[f][8] <> 0 .and.  aTrb3a[g][8] <> 0
				cVl08:= 	Alltrim(Transform(round( (aTrb3[f][8]+ aTrb3a[g][8])/2,2) ,'@E 99999999.99')  )
			ElseIf aTrb3[f][10]>0
				cVl08:=	Alltrim(Transform( round(aTrb3[f][8],2) ,'@E 99999999.99'))
			Else
				cVl08:= 	Alltrim(Transform( round(aTrb3a[g][8],2) ,'@E 99999999.99'))
			EndIf
			
			
			Aadd(aMdfu,{aTrb3[f][1],;
			aTrb3[f][2],;
			aTrb3[f][3],;
			aTrb3[f][4],;
			cvaltochar(val(aTrb3[f][5])+val(aTrb3a[g][5])),;
			cvaltochar(val(aTrb3[f][6])+val(aTrb3a[g][6])),;
			cvaltochar(	cVl07),;
			cvaltochar(	cVl08),;
			aTrb3[f][9] })
			
			
			cVl07:= ""
			cVl08:=  ""
			
		EndIf
	Next g
Next f



For h:= 1 to len(aTrb3)
	
	If !(aTrb3[h][1]+aTrb3[h][2] + aTrb3[h][4] $ cCodDif)
		
		
		cVl07:= 	Alltrim(Transform( round(aTrb3[h][7],2) ,'@E 99999999.99'))
		
		cVl08:= 	Alltrim(Transform( round(aTrb3[h][8],2) ,'@E 99999999.99'))
		
		
		
		Aadd(aMdfu,{aTrb3[h][1],;
		aTrb3[h][2],;
		aTrb3[h][3],;
		aTrb3[h][4],;
		aTrb3[h][5],;
		aTrb3[h][6],;
		cvaltochar(	cVl07),;
		cvaltochar(	cVl08),;
		aTrb3[h][9] })
		
		
		cVl07:= ""
		cVl08:=  ""
		
	EndIf
Next h


For t:= 1 to len(aTrb3a)
	
	If !(aTrb3a[t][1]+aTrb3a[t][2] + aTrb3a[t][4] $ cCodDif)
		
		
		cVl07:= 	Alltrim(Transform( round(aTrb3a[t][7],2) ,'@E 99999999.99'))
		
		cVl08:= 	Alltrim(Transform( round(aTrb3a[t][8],2) ,'@E 99999999.99'))
		
		
		
		Aadd(aMdfu,{aTrb3a[t][1],;
		aTrb3a[t][2],;
		aTrb3a[t][3],;
		aTrb3a[t][4],;
		aTrb3a[t][5],;
		aTrb3a[t][6],;
		cvaltochar(	cVl07),;
		cvaltochar(	cVl08),;
		aTrb3a[t][9] })
		
		
		cVl07:= ""
		cVl08:=  ""
		
	EndIf
Next t
lRest := .t.
Return(lRest)


/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥fQuery4()  ∫Autor  ≥Maximo Canuto - MCVN∫ Data ≥ 17/07/2010 ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.   ≥ Busca recebimento das notas fiscais de entrada 3M            ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ Especifico Compras Dipromed                                ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
STATIC FUNCTION fQuery4()

BeginSql Alias "TRB4"
	
	COLUMN D1_DTDIGIT AS DATE
	
	Select F1_DOC, '47869078000453'   LOCAL_EST,  '001' COD_FORNEC, F1_DTDIGIT
	From SF1010 SF1
	
	Inner Join SA2010 SA2  on A2_FILIAL = ' '
	and F1_FORNECE  =  A2_COD
	and A2_COD IN ('000041','000609')
	and SA2.%notdel%
	
	where F1_FILIAL = '04'
	and F1_DTDIGIT BETWEEN %Exp:If(cWorkFlow = "N",DDATABASE-60,DATE()-60)%    AND %Exp:If(cWorkFlow = "N",DDATABASE,DATE())%
	and SF1.%notdel%
	
	
	
	Order By F1_DTDIGIT, F1_DOC
	
EndSql

Return(!TRB4->( EOF().and.BOF()))

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥ GerDemanda()    ∫Autor  ≥Maximo Canuto         ∫ Data ≥  29/11/10   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ AP                                                         ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Static Function   GerDemanda()
Local nHandle	:= 0
If !File(_cArqDEMA)
	nHandle := MsfCreate(Upper(_cArqDEMA),0)
Endif
If nHandle > 0
	While !TRB1->( EOF() )
		//	FWrite(nHandle,Alltrim(TRB1->A1_CGC)+';'+UPPER(Alltrim(TRB1->A1_NOME))+';'+UPPER(Alltrim(TRB1->CC3_DESC))+ ';'+'N/A'+ ';'+Alltrim(TRB1->A1_STATUS)+ ';'+'N/A'+ ';'+'N/A'+ ';'+'N/A'+ ';'+ ';'+chr(13)+chr(10))
		FWrite(nHandle,Alltrim(TRB1->A1_CGC)+';'+UPPER(Alltrim(TRB1->A1_NOME))+';'+'N/A'+ ';'+'N/A'+ ';'+Alltrim(TRB1->A1_STATUS)+ ';'+'N/A'+ ';'+'N/A'+ ';'+'N/A'+ ';'+ ';'+chr(13)+chr(10))
		TRB1->( DbSkip() )
	End
	FClose(nHandle)
EndIf
Return

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥ GerMovSKU()    ∫Autor  ≥Maximo Canuto         ∫ Data ≥  29/11/10/  ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ AP                                                         ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Static Function   GerMovSKU()


Local nHandle	  := 0
Local QTD_ESTOQUE := 0
Local PRC_COMPRA  := 0


If !File(_cArqMSKU,)
	nHandle := MsfCreate(_cArqMSKU,0)
Else
	nHandle := FOpen(_cArqMSKU,2)
	fSeek(nHandle,0,2)
Endif

If nHandle > 0
	for k:= 1 to len(aMsku)
//		FWrite(nHandle,aMsku[k][1]+';'+ aMsku[k][2]+';'+ aMsku[k][3]+';'+aMsku[k][4]+';'+aMsku[k][5]+';'+ aMsku[k][6]+';'+ aMsku[k][7]+';'+aMsku[k][8]+';'+aMsku[k][9]+';'+ aMsku[k][10]+';'+ aMsku[k][11]+';'+chr(13)+chr(10))
		FWrite(nHandle,aMsku[k][1]+';'+ aMsku[k][2]+';'+ aMsku[k][3]+';'+aMsku[k][4]+';'+aMsku[k][5]+';'+ aMsku[k][6]+';'+ aMsku[k][7]+';'+aMsku[k][8]+';'+aMsku[k][9]+';'+ aMsku[k][10]+';'+ aMsku[k][11]+';;'+chr(13)+chr(10))		
	next k
	FClose(nHandle)
	
	
EndIf
Return

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥ GerMovDFU()    ∫Autor  ≥Maximo Canuto         ∫ Data ≥  29/11/10/  ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ AP                                                         ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Static Function   GerMovDFU()
Local nHandle	  := 0
Local PRC_COMPRA  := 0


If !File(_cArqMDFU,)
	nHandle := MsfCreate(_cArqMDFU,0)
Else
	nHandle := FOpen(_cArqMDFU,2)
	fSeek(nHandle,0,2)
Endif
ASORT(aMdfu,,, { |x, y| x[4] < y[4] })
for k:= 1 to len(aMdfu)
//	FWrite(nHandle,aMdfu[k][1]+';'+ aMdfu[k][2]+';'+ aMdfu[k][3]+';'+aMdfu[k][4]+';'+aMdfu[k][5]+';'+ aMdfu[k][6]+';'+ aMdfu[k][7]+';'+aMdfu[k][8]+';'+aMdfu[k][9]+';'+ chr(13)+chr(10))
	FWrite(nHandle,aMdfu[k][1]+';'+ aMdfu[k][2]+';'+ aMdfu[k][3]+';'+aMdfu[k][4]+';'+aMdfu[k][5]+';'+ aMdfu[k][6]+';'+ aMdfu[k][7]+';'+aMdfu[k][8]+';'+aMdfu[k][9]+ chr(13)+chr(10))	
next k
FClose(nHandle)

Return


/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥ GerConfNfe()   ∫Autor  ≥Maximo Canuto ∫ Data ≥  30/11/10   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ AP                                                         ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Static Function   GerConfNfe()
Local nHandle	:= 0

If !File(_cArqCNFE,)
	nHandle := MsfCreate(_cArqCNFE,0)
Else
	nHandle := FOpen(_cArqCNFE,2)
	fSeek(nHandle,0,2)
EndIf
While !TRB4->( EOF() )
	FWrite(nHandle,Right(Alltrim(TRB4->F1_DOC),6)+';'+UPPER(Alltrim(TRB4->LOCAL_EST))+';'+UPPER(Alltrim(TRB4->COD_FORNEC))+ ';'+Alltrim(TRB4->F1_DTDIGIT)+chr(13)+chr(10))
	TRB4->( DbSkip() )
End
FClose(nHandle)

Return


/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥ SaldEst29()  ∫Autor  ≥Maximo Canuto     ∫ Data ≥  03/02/11 ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ Busca o estoque inicial e os custos usando a funÁ„o calcest∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ

aSaldo[01] := SB9->B9_QINI
aSaldo[02] := SB9->B9_VINI1
aSaldo[03] := SB9->B9_VINI2
aSaldo[04] := SB9->B9_VINI3
aSaldo[05] := SB9->B9_VINI4
aSaldo[06] := SB9->B9_VINI5
aSaldo[07] := SB9->B9_QISEGUM


*/

User Function Sal29a(cTipoArq,cProdDFU3M)

Local aSaldo      := {}
Local aEmp3M      := {"01","04"}
Local cHQ         := "0404"
Local cDipro      := "0104"
Local _xAlias     :=GetArea()

If cWCodEmp+cWCodFil  <>  "0104" .And. cWorkFlow == "N"
	Aviso("AtenÁ„o","Essa rotina sÛ pode ser executada na DIPROMED CD","OK")
Endif

aSaldoEst  := {} // zera vari·vel
aProduto3M := {}

For p:=1 to Len(aEmp3M)
	
	// Produtos 3M
	If cWCodEmp+cWCodFil  == "0104" .And. Len(aProduto3M) = 0
		SA5->( DbSetOrder(1) )
		SA5->(dbSetFilter({|| SA5->A5_CODPRF <> '' .AND. SA5->A5_FORNECE $ '000041/000609' },"SA5->A5_CODPRF <> '' .AND. SA5->A5_FORNECE $ '000041/000609' "))
		SA5->( DbGoTop() )
		While !SA5->(EOF())
			Aadd( aProduto3M  , SA5->A5_PRODUTO ) // Cria array com os produtos do projeto 3M conecta para ser utilizado nos CD's
			SA5->( DbSkip() )
		End
		SA5->(dbSetFilter({|| .t.},".t."))
		SA5->( DbCloseArea() )
	Endif
	
	For i := 1 to Len(aProduto3M)
		If _lCargaIni == 2	.Or. cTipoArq == "DFU"
			
			For nDiaIni := 1 to nDiaFim
				aSaldo := CalcEst(aProduto3M[i],"01",(DDATABASE-(nDiaFim-nDiaIni))+1) // Utilizamos DDATABASE+1 porque esta rotina retorna o Saldo Inicial do dia e n„o o Final
				If cWCodEmp+cWCodFil == '0104'
					Aadd( aSaldoEst  , {aProduto3M[i], aSaldo[1], aSaldo[2], Dtos(DDATABASE-((nDiaFim-nDiaIni))), Posicione("SB9",1,xFilial("SB9")+ aProduto3M[i],"B9_CM1")} )  //giovani 12/08/11 add o custo do produto posi.5
					
				Else
					If aScan(aSaldoEst,{ |x| x[1]+x[4] == aProduto3M[i]+Dtos(DDATABASE-((nDiaFim-nDiaIni)))}) > 0
						aSaldoEst[aScan(aSaldoEst,{ |x| x[1]+x[4] == aProduto3M[i]+Dtos(DDATABASE-((nDiaFim-nDiaIni)))}),2]  += aSaldo[1]
						aSaldoEst[aScan(aSaldoEst,{ |x| x[1]+x[4] == aProduto3M[i]+Dtos(DDATABASE-((nDiaFim-nDiaIni)))}),3]  += aSaldo[2]
					Endif
				Endif
			Next nDiaIni
			
		Else
			aSaldo := CalcEst(aProduto3M[i],"01",DDATABASE+1) // Utilizamos DDATABASE+1 porque esta rotina retorna o Saldo Inicial do dia e n„o o Final
			If cWCodEmp+cWCodFil == '0104'
				Aadd( aSaldoEst  , {aProduto3M[i], aSaldo[1], aSaldo[2]} )
			Endif
		Endif
	Next i
	
	
Next p

RestArea(_xAlias)
Return()
//*************************************************************************************************
Static Function AjustaSX1(cPerg)
Local i,j

_sAlias := Alias()
dbSelectArea("SX1")
dbSetOrder(1)

cPerg := PADR(cPerg, Len(SX1->X1_GRUPO)," " ) // Incluido por Sandro em 17/11/09.

aRegs:={}

//------------ Grupo/Ordem/Pergunta/PERGING/PERGESP/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05/F3
AADD(aRegs,{cPerg,"01","Data  de :      ","","","mv_ch1","D",8,0,0,"G","","MV_PAR01","","","","","","","","","","","","","",""})
AADD(aRegs,{cPerg,"02","Data  ate :   ","","","mv_ch2","D",8,0,0,"G","","MV_PAR02","","",""," ","","","","","","","","","",""})
AADD(aRegs,{cPerg,"03","Dipromed + Hq:    ","","","mv_ch3","N",1,0,1,"C","","MV_PAR03","Sim","","","","","Nao","","","","","","","",""})

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

Static Function VarDat()
Local cQuery := ""
Local aSaldo := {}
Local QTD_ESTOQUE := 0
Local PRC_COMPRA  := 0
Local lRest := .f.
Local cVl010 := 0
Local cVl07 := 0
Local cVl06 := 0
Local cHQ         := "0404"
Local cDipro      := "0104"
Local cDasTes     := ""
Local _xAlias     :=GetArea()


RestArea(_xAlias)
Return()

//***************************************************************************************************************
Static Function DipSetEnv(cEmpTrb,cFilTrb,lClrEnv, aAliasAmb)

Local  aAliasAmb := {"SD2", "SD1", "SZD", "SA1", "SF4", "SA5"}



If lClrEnv
	If SM0->(!dbSeek(cEmpTrb+cFilTrb))
		SM0->(dbSeek(cEmpTrb))
	EndIf
	cFilTrb := SM0->M0_CODFIL
	//-- Fecha ambiente.
	RpcClearEnv()
EndIf

RpcSetType( 3 ) // Desabilita licenca
ConOut("Montando Ambiente. Empresa ["+cEmpTrb+"] Filial ["+cFilTrb+"]")
RpcSetEnv( cEmpTrb, cFilTrb,,,,, aAliasAmb )

Return
User Function SqlVi()

BeginSql Alias "TRB2"
	//EMPRESA 01 FILIAL 04
	Select  A5_CODPRF, A5_PRODUTO, '47869078000453'   LOCAL_EST,     %Exp:cDasTes% AS  DTREFER, A5_QTDUN3M AS  UN_MED_3M, A5_QTDUMDI AS UN_MED_DIPRO,
	(IsNull ( ( Select Sum(D2_QUANT)
	From SD2010 SD2, SF4010 SF4
	where D2_FILIAL = '04'    and D2_EMISSAO  =  %Exp:cDasTes%  and D2_TIPO = 'N' and D2_FORNEC IN ('000041','000609') and D2_COD = SA5.A5_PRODUTO and F4_CODIGO = D2_TES and F4_ESTOQUE = 'S'  and SD2.D_E_L_E_T_ = ' '  and SF4.D_E_L_E_T_ = ' '  and F4_FILIAL = D2_FILIAL GROUP BY D2_COD ),0)  ) QTDVEND,
	(IsNull ( (	Select Sum(D1_QUANT)
	From SD1010 SD1, SF4010 SF4
	where D1_FILIAL = '04'  and D1_DTDIGIT   =  %Exp:cDasTes%  and D1_TIPO = 'D' and D1_FORNECE IN ('000041','000609') and D1_COD = SA5.A5_PRODUTO and F4_CODIGO = D1_TES and F4_ESTOQUE = 'S' and SD1.D_E_L_E_T_ = ' '  and SF4.D_E_L_E_T_ = ' ' and F4_FILIAL = D1_FILIAL  GROUP BY D1_COD),0)    ) QTDDEVOL,
	//(IsNull((Select Sum(ZD_QUANT)
	//From SZD010 SZD
	//where ZD_FILIAL = '04'   and ZD_DATAEXC    =  %Exp:cDasTes%    and ZD_DATAEXC <> ZD_EMISSAO and ZD_ATUEST = 'S'  and ZD_COD = SA5.A5_PRODUTO  and ZD_NOTA+ZD_SERIE NOT IN (SELECT D1_NFORI+D1_SERIORI FROM SD1010 SD1 where D1_TIPO = 'D' and D1_FORNECE IN ('000041','000609') and  D1_FILIAL ='04' and SD1.D_E_L_E_T_ = ' '  ) and SZD.D_E_L_E_T_ = ' '    GROUP BY ZD_COD ),0))QTDDELET,
	0   QTDDELET,
	
	(IsNull ( ( Select Sum((D2_TOTAL)-D2_TOTAL*((CASE WHEN D2_PICM>0 THEN D2_PICM ELSE D2_ALIQSOL END)+D2_ALQIMP5+D2_ALQIMP6)/100)
	From SD2010 SD2, SF4010 SF4
	where D2_FILIAL = '04'    AND D2_FILIAL = F4_FILIAL and D2_EMISSAO    =  %Exp:cDasTes%  and D2_TIPO = 'N' and D2_FORNEC IN ('000041','000609') and D2_COD = SA5.A5_PRODUTO and F4_CODIGO = D2_TES and F4_ESTOQUE = 'S'  and SD2.D_E_L_E_T_ = ' '  and SF4.D_E_L_E_T_ = ' '  GROUP BY D2_COD ),0))  UNITARIO,
	( IsNull ( (SELECT TOP 1 B9_VINI1 From SB9010  SB9 where B9_FILIAL = '04'   and B9_LOCAL = '01' and B9_COD = SA5.A5_PRODUTO and B9_DATA    =  %Exp:cDasTes%   and SB9.D_E_L_E_T_ = ' '   Order by B9_DATA DESC  ),0)) B9_VINI1 ,
	(IsNull   ( (SELECT TOP 1 B9_QINI From SB9010  SB9 where B9_FILIAL = '04'  and B9_LOCAL = '01' and B9_COD = SA5.A5_PRODUTO and B9_DATA    =  %Exp:cDasTes%     and SB9. D_E_L_E_T_ = ' '   Order by B9_DATA DESC  ),0)) B9_QINI,
	
	(IsNull ( ( SELECT B1_CUSDIP FROM SB1010 SB1
	WHERE B1_COD  = A5_PRODUTO
	and B1_FILIAL = '04'
	and SB1.D_E_L_E_T_ = ' ' ),0)  ) CUSTO
	
	From SA5010 SA5
	where A5_FILIAL = ' '
	and A5_FORNECE in ('000041','000609')
	and Rtrim(lTrim(A5_CODPRF)) <> ' '
	and SA5.D_E_L_E_T_= ' '
	Order By A5_PRODUTO
	//Processa({|| 		u_sqlvi()  },"Gerando CD...SKU.sql")
EndSql
cQuery := GETLastQuery()[2]
return()

User Function Sqllk30103()
BeginSql Alias "TRB3"
	Select A5_CODPRF, A5_PRODUTO,  A1_CGC, A1_COD,   '47869078000453'   LOCAL_EST,   %Exp:cDasTes%  DTREFER, A5_QTDUN3M AS  UN_MED_3M, A5_QTDUMDI AS UN_MED_DIPRO,
	
	
	IsNull ( ( Select Sum(D2_QUANT)
	From SD2010 SD2, SF4010 SF4
	where D2_FILIAL = '04' AND D2_LOCAL = '01' AND D2_FILIAL = F4_FILIAL and D2_EMISSAO = %Exp:cDasTes%    and D2_TIPO = 'N'  	and D2_FORNEC IN ('000041','000609') and D2_COD = SA5.A5_PRODUTO and D2_CLIENTE = SA1.A1_COD  and F4_CODIGO = D2_TES and F4_ESTOQUE = 'S' and SD2.D_E_L_E_T_ = ' '  and SF4.D_E_L_E_T_ = ' '  GROUP BY D2_COD ),0) QTDVEND,
	
	
	
	IsNull ( (	Select Sum(D1_QUANT)
	From SD1010 SD1,SF4010 SF4
	where D1_FILIAL = '04' AND D1_LOCAL = '01' AND D1_FILIAL = F4_FILIAL and D1_DTDIGIT = %Exp:cDasTes%   and D1_TIPO = 'D'  	and D1_FORNECE IN ('000041','000609') and D1_COD = SA5.A5_PRODUTO and D1_FORNECE = SA1.A1_COD   and F4_CODIGO = D1_TES and F4_ESTOQUE = 'S' and SD1.D_E_L_E_T_ = '  '  and SF4.D_E_L_E_T_ = '  '    GROUP BY D1_COD),0) QTDDEVOL,
	
	
	
	//	IsNull((Select Sum(ZD_QUANT)
	//	From SZD010 SZD
	//	where ZD_FILIAL = '04' and ZD_DATAEXC = %Exp:cDasTes%   and ZD_DATAEXC > ZD_EMISSAO+5 and ZD_ATUEST = 'S'  and ZD_COD = SA5.A5_PRODUTO   and ZD_CLIENTE = SA1.A1_COD and ZD_NOTA+ZD_SERIE NOT IN (SELECT D1_NFORI+D1_SERIORI FROM SD1010 SD1 where D1_TIPO = 'D' and D1_FORNECE IN ('000041','000609') and SD1.D_E_L_E_T_ = '  '  ) and SZD.D_E_L_E_T_ = '  '    GROUP BY ZD_COD ),0) QTDDELET,
	0 QTDDELET ,
	
	
	IsNull ( (	Select Sum((D2_TOTAL)-D2_TOTAL*((CASE WHEN D2_PICM>0 THEN D2_PICM ELSE D2_ALIQSOL END)+D2_ALQIMP5+D2_ALQIMP6)/100)
	From SD2010 SD2, SF4010 SF4
	where D2_FILIAL = '04' AND D2_LOCAL = '01'  AND D2_FILIAL = F4_FILIAL and D2_EMISSAO  = %Exp:cDasTes%   and D2_TIPO = 'N'  and D2_FORNEC IN ('000041','000609') and D2_COD = SA5.A5_PRODUTO and D2_CLIENTE = SA1.A1_COD  and F4_CODIGO = D2_TES and F4_ESTOQUE = 'S' and SD2.D_E_L_E_T_ = '  '  and SF4.D_E_L_E_T_ = '  '   GROUP BY D2_COD ),0) 	UNITARIO,
	
	(IsNull ( ( SELECT B1_CUSDIP FROM SB1010 SB1
	WHERE B1_COD  = A5_PRODUTO
	and B1_FILIAL = '04'
	and SB1.D_E_L_E_T_ = ' ' ),0)  ) CUSTO
	From SA5010 SA5
	
	
	Inner Join SA1010 SA1 on A1_FILIAL = ' '
	
	and 	(A1_COD    IN (	Select D2_CLIENTE
	From SD2010 SD2, SF4010 SF4
	where D2_FILIAL = '04'  and D2_EMISSAO  = %Exp:cDasTes% AND D2_LOCAL = '01'  and D2_TIPO = 'N'  	and D2_FORNEC IN ('000041','000609') and D2_COD = SA5.A5_PRODUTO  and D2_CLIENTE = SA1.A1_COD  and F4_CODIGO = D2_TES and F4_ESTOQUE = 'S' and SD2.D_E_L_E_T_ = ' ' and SF4.D_E_L_E_T_ = ' '  GROUP BY D2_COD, D2_CLIENTE)
	OR A1_COD  IN (	Select D1_FORNECE
	From SD1010 SD1, SF4010 SF4
	where D1_FILIAL = '04'  and D1_DTDIGIT = %Exp:cDasTes%  AND D1_LOCAL = '01'  and D1_TIPO = 'D'  	and D1_FORNECE IN ('000041','000609') and D1_COD = SA5.A5_PRODUTO  and D1_FORNECE = SA1.A1_COD   and F4_CODIGO = D1_TES and F4_ESTOQUE = 'S' and F4_FILIAL = '04' and SD1.D_E_L_E_T_ = ' ' and SF4.D_E_L_E_T_ = ' '   GROUP BY D1_COD, D1_FORNECE))
	
	and SA1.D_E_L_E_T_ = ' '
	
	where A5_FILIAL = ' '
	and A5_FORNECE in ('000041','000609')
	and Rtrim(lTrim(A5_CODPRF)) <> ' '
	
	and SA5.D_E_L_E_T_ = '  '
	GROUP BY A5_PRODUTO, A1_CGC ,A5_CODPRF,  A1_COD,  A5_QTDUN3M, A5_QTDUMDI
	Order By A5_PRODUTO, A1_CGC
	
	
	
	
endsql
cQuery := GETLastQuery()[3]

return()

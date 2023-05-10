/*                                                     Sao Paulo, 23 Fev 2010
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDipm028() บ Autor ณJailton B Santos-JBSบ Data ณ 23/02/2010  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Le os CTRCs da Transportadora Emovere e prepara-os na Tabe-บฑฑ
ฑฑบ          ณ la 'SZY'. De onde o usuario ira seleciona-los e gerar as   บฑฑ
ฑฑบ          ณ suas respectivas notas fiscais de entrada.                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Especifico - SIGAFAT - Dipromed.                           บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"       
#INCLUDE "TBICONN.CH"

User Function DIPM028(aWork) 
                            
Local lRet := .F.
Local _xArea := GetArea()

Private cWorkFlow := "N"
Private cPerg     := Padr("DIPM028A",10)
Private nQtdCTRC  := 0  
Private aRecRat := {}// Giovani Zago 21/11/11
If ValType(aWork) <> 'A'
    U_DIPPROC(ProcName(0),U_DipUsr()) // Gravando o nome do Programa no SZU   
    
    If !(Upper(U_DipUsr()) $ 'EELIAS|MCANUTO|WPEREIRA|LNUNES|RBORGES|LPEREIRA|RSILVA|RRODRIGUES|MAUGUSTO|DDOMINGOS|VQUEIROZ|VEGON|RLOPES|') // MCVN - 25/02/10
   		Alert("Usuแrio sem autoriza็ใo para executar esta rotina!")
	Return()   
	
End
Else
	cWorkFlow := aWork[1]
	PREPARE ENVIRONMENT EMPRESA aWork[1] FILIAL aWork[2] FUNNAME "DIPM028"  TABLES "SF2","SYP","SA2","SZY","SC5","SD2"
EndIf

fAjustSX1()

If cWorkFlow == 'S'

	Begin Sequence 
	
	If !Pergunte(cPerg, .F.)
		Break
	EndIf               
	
	MV_PAR01 := dDataBase - 10
	MV_PAR02 := dDataBase
	
	//----------------------------------------------------------------------------
	ConOut('Integra็ใo de Retorno TMS - Inicio ...')
	//----------------------------------------------------------------------------
	lRet:=fQuery()
	If !lRet
		//----------------------------------------------------------------------------
		ConOut('Nao encontrado dados que satisfacam aos parametros informados!')
		//----------------------------------------------------------------------------
		If Select("TRB_TMS") > 0
			TRB_TMS->( DbCloseArea() )
		EndIf
		Break
	EndIf
	//----------------------------------------------------------------------------
	ConOut('Gravando as SZY com o CTRCs do TMS ...')
	//----------------------------------------------------------------------------
	
	lRet:=fGrvSZY()
	
	End Sequence
	//----------------------------------------------------------------------------
	ConOut('Integra็ใo de Retorno TMS  - Fim ...')
	//----------------------------------------------------------------------------
	SF2->(dbCloseArea())
	SYP->(dbCloseArea())
	SA2->(dbCloseArea()) // JBS 29/12/2009
	SZY->(dbCloseArea()) // JBS 29/12/2009
	//----------------------------------------------------------------------------
	RESET ENVIRONMENT
	
else                          

    Begin Sequence
	//-----------------------------------------------------
	// Cria o Grupo de Pergunta no SX1 e Questiona usuario
	//-----------------------------------------------------
	If !Pergunte(cPerg, .T.)
		Break
	EndIf   
	
    Processa({|| lRet := fQuery()}) 
    
	If !lRet
		Aviso('Aten็ใo','Nao encontrado dados que satisfacam aos parametros informados!',{'Ok'})
		If Select("TRB_TMS") > 0
			TRB_TMS->( DbCloseArea() )
		EndIf 
		Break
	EndIf

   	Processa({|| lRet := fGrvSZY() })

    End Sequence 
    If cWorkFlow == 'N'
        If lRet
            Aviso('Sucesso','Quantidade de CTRCs Importados = '+Transform(nQtdCTRC,"@e 9,999,999"),{'OK'})
        EndIf
    Else 
        If lRet
            ConOut('-------------------------------------------------------------------------------------')
            ConOut('Dia: ' + dToc(dDataBase) + ' hora: ' + Time() + '  Sucesso  -> Quantidade de CTRCs Importados = ' + Transform(nQtdCTRC,"@e 9,999,999"))
            ConOut('-------------------------------------------------------------------------------------')
        EndIf
    EndIf   
EndIf
RestArea(_xArea) 

RptStatus({|| D2RatFret(aRecRat)})//Giovani Zago 21/11/11 fun็ใo para ratear o frete na D2

Return(.t.)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณfQuery()   บAutor ณJailton B Santos-JBSบ Data ณ 23/02/2010  บฑฑ
ฑฑฬออออออออออุอออออออออออสออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc. 1:  ณQuery para ler todos os CTRCs gerados em um periodo para    บฑฑ
ฑฑบ          ณgerar as notas fiscais de entrada na empresa.               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Especifico - FATURAMENTO - Dipromed                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function fQuery()     
//----------------------------------------------------------------------------------
Local nId       := 0
Local lRet      := .F.   
Local cQuery    := ""              
Local cCliReme  := ""
Local cLojReme  := ""
//----------------------------------------------------------------------------------
// Determina Qual eh Empresa, e Respectiva Filial, que remeteu as Notas ao TMS.
// Para buscar no TMS os CTRCs.                          
//----------------------------------------------------------------------------------
do case             
case SM0->M0_CODIGO = '01'.and.SM0->M0_CODFIL = '01'; cCliReme := '000804'; cLojReme := '01'          
case SM0->M0_CODIGO = '01'.and.SM0->M0_CODFIL = '04'; cCliReme := '000804'; cLojReme := '04'          
case SM0->M0_CODIGO = '04'.and.SM0->M0_CODFIL = '01'; cCliReme := '011050'; cLojReme := '01'          
case SM0->M0_CODIGO = '04'.and.SM0->M0_CODFIL = '04'; cCliReme := '011050'; cLojReme := '04'          
otherwise 
   return(.F.)    
endcase     
//----------------------------------------------------------------------------------
If cWorkFlow == 'N'
   ProcRegua(1000)
   For nId:= 1 to 800
       IncProc()
   Next nId
EndIf
//----------------------------------------------------------------------------------
cQuery := " SELECT DT6_FILIAL, "
cQuery += "        DT6_LOJREM, "
cQuery += "        DT6_DOC,    "
cQuery += "        DT6_TIPFRE, "
cQuery += "        '100000' TRANSP, "
cQuery += "        DT6_DATEMI,      "
cQuery += "        'EMOVERE LOGISTICA LTDA' REMETE, "
cQuery += "        A1_NREDUZ, "
cQuery += "        F2_VALICM, "
cQuery += "        (CASE WHEN F2_VALICM > 0 THEN (F2_VALICM/F2_BASEICM*100) ELSE 0 END) PICM, "
cQuery += "        F2_BASEICM, "
cQuery += "        0 PEDAGI, "
cQuery += "        F2_PBRUTO, "
cQuery += "        F2_VALBRUT, "
cQuery += "        F2_DESCONT, "
cQuery += "        'N' TIPO, "
cQuery += "        'TMS-EMOVERE' NOME_EDI, "
cQuery += "        'I' STATUS, "
cQuery += "        DTC_NUMNFC, "
cQuery += "        DTC_SERNFC, "
cQuery += "        DT6_SERIE "
//----------------------------------------------------------------------------------
cQuery += "   FROM DTP030 DTP "
//----------------------------------------------------------------------------------
cQuery += " INNER JOIN DTC030 DTC ON DTC.DTC_FILIAL = '' "
cQuery += "                      AND DTC.DTC_LOTNFC = DTP.DTP_LOTNFC "
cQuery += "                      AND DTC.DTC_FILORI = DTP.DTP_FILORI "
cQuery += "                      AND DTC.DTC_CLIREM = '" + cCliReme + "' "
cQuery += "                      AND DTC.DTC_LOJREM = '" + cLojReme+ "' " 
/*
cQuery += "                      AND DTC.DTC_LOJREM+DTC.DTC_DOC NOT IN ( SELECT SZY.ZY_FILIAL + SZY.ZY_CTRC "
cQuery += "                                                                FROM "+ RetSQLName("SZY") + " SZY "
cQuery += "                                                               WHERE SZY.ZY_TRANSP  = '100000' "
cQuery += "                                                                 AND SZY.D_E_L_E_T_ = '' )
*/
cQuery += "                      AND NOT EXISTS ( SELECT TOP 1 'X' "
cQuery += "                                       FROM "+ RetSQLName("SZY") + " SZY "
cQuery += "                                       WHERE  "
cQuery += "                                          SZY.ZY_FILIAL = DTC.DTC_LOJREM "
cQuery += "                                          AND SZY.ZY_CTRC    = DTC.DTC_DOC "
cQuery += "                                          AND SZY.ZY_TRANSP  = '100000' "
cQuery += "                                          AND SZY.D_E_L_E_T_ = '' ) "
cQuery += "                      AND DTC.D_E_L_E_T_ <> '*' "
//----------------------------------------------------------------------------------
cQuery += " INNER JOIN DT6030 DT6 ON DT6.DT6_FILIAL = '' "
cQuery += "                      AND DT6.DT6_DOC    = DTC.DTC_DOC "
cQuery += "                      AND DT6.DT6_SERIE  = DTC.DTC_SERIE "
//cQuery += "                      AND DT6.DT6_FILDOC = DTC_FILORI "
cQuery += "                      AND DT6.DT6_FILDOC = DTC_FILDOC " // MCVN - 17/03/10 (Orienta็ใo Daniel Leme)
cQuery += "                      AND DT6.DT6_DATEMI BETWEEN '" + dTos(MV_PAR01) + "' AND '" + dTos(MV_PAR02) + "' "
cQuery += "                      AND DT6.D_E_L_E_T_ <> '*' "
//----------------------------------------------------------------------------------
//cQuery += " INNER JOIN SF2030 SF2 ON SF2.F2_FILIAL = DT6.DT6_FILORI "
cQuery += " INNER JOIN SF2030 SF2 ON SF2.F2_FILIAL = DT6.DT6_FILDOC " // MCVN - 17/03/10 (Orienta็ใo Daniel Leme)
cQuery += "                      AND SF2.F2_DOC = DT6.DT6_DOC "
cQuery += "                      AND SF2.F2_SERIE = DT6.DT6_SERIE "
cQuery += "                      AND SF2.D_E_L_E_T_ <> '*' "
//----------------------------------------------------------------------------------
cQuery += " INNER JOIN "+RetSQLName("SA1")+" SA1 ON SA1.A1_FILIAL = '' "
cQuery += "                      AND SA1.A1_COD    = DTC.DTC_CLIREM "
cQuery += "                      AND SA1.A1_LOJA   = DTC.DTC_LOJREM "
cQuery += "                      AND SA1.D_E_L_E_T_ <> '*' "
//----------------------------------------------------------------------------------
cQuery += " WHERE DTP_FILIAL = '' "
cQuery += " AND DTP.D_E_L_E_T_ <> '*' "
cQuery += " AND DTP.DTP_STATUS = '3' "
cQuery += " AND DTP.D_E_L_E_T_ <> '*' "
//----------------------------------------------------------------------------------
cQuery += " ORDER BY DT6_FILIAL,DT6_DOC,DT6_SERIE "
//----------------------------------------------------------------------------------
If Select("TRB_TMS") > 0
    TRB_TMS->( DbCloseArea() )
EndIf    
//----------------------------------------------------------------------------------
DbCommitAll()
TCQUERY cQuery NEW ALIAS "TRB_TMS" 
//----------------------------------------------------------------------------------
TCSETFIELD("TRB_TMS","DT6_DATEMI" , "D" , 08 , 00)
TCSETFIELD("TRB_TMS","DT6_TIPFRE" , "C" , 01 , 00)
TCSETFIELD("TRB_TMS","F2_VALICM"  , "N" , 14 , 02)
TCSETFIELD("TRB_TMS","PICM"       , "N" , 05 , 02)
TCSETFIELD("TRB_TMS","F2_VALBRUT" , "N" , 05 , 02)
TCSETFIELD("TRB_TMS","F2_BASEICM" , "N" , 14 , 02)
TCSETFIELD("TRB_TMS","PEDAGI"     , "N" , 14 , 02)
TCSETFIELD("TRB_TMS","F2_PBRUTO"  , "N" , 14 , 02)
TCSETFIELD("TRB_TMS","F2_DESCONT" , "N" , 05 , 02)
TCSETFIELD("TRB_TMS","F2_VALBRUT" , "N" , 05 , 02)   
//----------------------------------------------------------------------------------
lRet := !TRB_TMS->( BOF().and.EOF() )                
//----------------------------------------------------------------------------------
TRB_TMS->( DbGoTop() ) 
//----------------------------------------------------------------------------------
If cWorkFlow == 'N'
   For nId:= 1 to 200
       IncProc()
   Next nId
EndIf
//----------------------------------------------------------------------------------
Return(lRet)             
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณfGrvSZY() บAutor  ณJailton B Santos-JBSบ Data ณ 23/02/2010  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณGrava as informacoes de cada CTRC na Tabela SZY para depois,บฑฑ
ฑฑบ          ณna rotina de geracao de NFE, o usuario selecionar os CTRCs  บฑฑ
ฑฑบ          ณque deverao compor cada nota fiscal de entrada.             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Especifico - FATURAMENTO - Dipromed                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function fGrvSZY()
//----------------------------------------------------------------------------------------
Local cNotas   := ''
Local cNrCTRC  := ''
Local cVirgula := '' 
Local lRet     := .F. 
Local nProcesso:= 0 
Local nNota     
Local cFilSF2  := xFilial('SF2') 
Local cFilSC5  := xFilial('SC5')
Local cFilSD2  := xFilial('SD2') 
//----------------------------------------------------------------------------------------
Private nSF2FretSZ3 := 0
Private nSF2PesoBr  := 0        
Private aDipInfNf   := {}
//----------------------------------------------------------------------------------------
// Deixa a Transportadora Emovere Posicionada
//----------------------------------------------------------------------------------------
SA4->( DbSetOrder(1) )
SA4->( DbSeek( xFilial('SA4') + '10000' ) )
//----------------------------------------------------------------------------------------
TRB_TMS->( DbGoTop() )
//----------------------------------------------------------------------------------------
Do While TRB_TMS->( !EOF() )
	//------------------------------------------------------------------------------------
	// Verificar o CTRC ja foi importado para o SZY
	//------------------------------------------------------------------------------------
	If fExistSZY()
		TRB_TMS->(DbSkip())
		Loop                                               
	EndIf
	//------------------------------------------------------------------------------------
	// Libera as variaveis para controlar um novo CTRC
	//------------------------------------------------------------------------------------ 
	//----------------------------------------------------------------------------------
    If cWorkFlow == 'N'
	    If nProcesso = 0
	        nProcesso := 100 
	        ProcRegua(nProcesso)
	    EndIf 
	    IncProc() 
        nProcesso--
    EndIf
  	//------------------------------------------------------------------------------------
	nQtdCTRC++   // Somando a quantidade de CTRC importados para o SZY
	//------------------------------------------------------------------------------------
	cNotas      := '' 
	cVirgula    := '' 
	aDipInfNf   := {}
	cNrCTRC     := TRB_TMS->DT6_DOC
    nSF2FretSZ3 := 0
    nSF2PesoBr  := 0 
	
	/*
	//------------------------------------------------------------------------------------
	SZY->( RecLock('SZY', .T.) )                                   
	//------------------------------------------------------------------------------------
	// Grava as informacoes do CTRC para na rotina DIPM026, mostra'-las ao usuario para
	// que o mesmo possa gerar a nota fiscal de entrada de Cada CTRC.
	//------------------------------------------------------------------------------------
	SZY->ZY_FILIAL  := xFilial('SZY')
	// SZY->ZY_FILIAL  := TRB_TMS->DT6_LOJREM
	SZY->ZY_CTRC    := TRB_TMS->DT6_DOC
	SZY->ZY_TRANSP  := TRB_TMS->TRANSP
	SZY->ZY_DTEMIS  := TRB_TMS->DT6_DATEMI
	SZY->ZY_REMETE  := TRB_TMS->REMETE
	SZY->ZY_DESTIN  := TRB_TMS->A1_NREDUZ
	SZY->ZY_CGC     := SA4->A4_CGC
	SZY->ZY_ICM     := TRB_TMS->F2_VALICM
	SZY->ZY_AICM    := Round(TRB_TMS->PICM,0)                                                   
	SZY->ZY_BCICM   := TRB_TMS->F2_BASEICM
	SZY->ZY_PEDAGI  := TRB_TMS->PEDAGI
	SZY->ZY_FRET    := Iif(TRB_TMS->DT6_TIPFRE=='1','CIF','FOB')
	SZY->ZY_PESOCTR := TRB_TMS->F2_PBRUTO
	SZY->ZY_VALFRE  := TRB_TMS->F2_VALBRUT
	SZY->ZY_VALDFR  := TRB_TMS->F2_DESCONT
	SZY->ZY_CTRCGR  := ''
	SZY->ZY_TIPOREC := TRB_TMS->TIPO
	SZY->ZY_NOMEEDI := TRB_TMS->NOME_EDI+'-'+dToc(dDataBase)
	SZY->ZY_STATUS  := TRB_TMS->STATUS
	SZY->ZY_SERIE   := TRB_TMS->DT6_SERIE
	*/      
	//------------------------------------------------------------------------------------
	// Executa tratamenro para demonstrar agrupamentos das Notas do CTRC
	// alem de atualizar informacoes de frete no SF2
	//------------------------------------------------------------------------------------
	Do While TRB_TMS->(!EOF()) .and. TRB_TMS->DT6_DOC == cNrCTRC
   		//--------------------------------------------------------------------------------
        // Agrupa as notas do mesmo CTRC, para grava'-las no campo ZY_NOTAS
		//--------------------------------------------------------------------------------
	    cNotas   += ( cVirgula + TRB_TMS->DTC_NUMNFC + TRB_TMS->DTC_SERNFC )  
	    cVirgula := ', ' 
		//--------------------------------------------------------------------------------
	    // Guarda as notas para reteio do Calculo de Fretes
		//--------------------------------------------------------------------------------
	    aadd(aDipInfNf,{TRB_TMS->DTC_NUMNFC + DTC_SERNFC,;  // 01 Numero da Nota e Serie
	                 TRB_TMS->F2_PBRUTO ,;               // 02 Peso Bruto do CTRC
	                 TRB_TMS->F2_VALBRUT,;               // 03 Valor do CTRC
	                 TRB_TMS->F2_DESCONT,;               // 04 Valor do Desvonto
	                 TRB_TMS->DT6_DOC   ,;               // 05 Numero do CTRC
	                 TRB_TMS->F2_PBRUTO})                // 06 Peso do CTRC
		TRB_TMS->( DbSkip() )
    EndDo
    //SZY->ZY_NOTAS   := cNotas // Grava todas as notas agrupadas do CTRC
    //SZY->( MsUnLock('SZY') )
    
   	//--------------------------------------------------------------------------------
    // Posiciona o SD2 para Posicionar o SC5.
    // Dentro da funcao ClcLimite, O SC5 precisa esta posicionado.
    //--------------------------------------------------------------------------------
	SF2->( DbSetOrder(1))   
    SD2->( DbSetOrder(3))
	
	For nNota := 1 to Len(aDipInfNf)	
				
		If SF2->( Dbseek(cFilSF2  + aDipInfNf[nNota][01]) )
		    SD2->( Dbseek(cFilSD2 + aDipInfNf[nNota][01]) )
		   	SC5->( Dbseek(cFilSC5 + SD2->D2_PEDIDO) )
			//----------------------------------------------------------------------------
			// Calcula o valor do frete proporcional em cada nota agrupada no CTRC e grava
			// este valor no Campo F2_FRETSZ3.
			//----------------------------------------------------------------------------
			U_ClcLimite("NF",SF2->F2_VALBRUT,SF2->F2_PBRUTO)        
			//----------------------------------------------------------------------------
			// Acucula o total de Frete Calculado para ratear o desconto
			//----------------------------------------------------------------------------
			nSF2FretSZ3 += SF2->F2_FRETSZ3 
			nSF2PesoBr  += SF2->F2_PBRUTO
		EndIf 

    Next              
	//--------------------------------------------------------------------------------
    // Atualiza Notas Originarias do Frete. 
	//--------------------------------------------------------------------------------
    fGravaNFS(aDipInfNf)
    lRet := .T.
EndDo   
TRB_TMS->( DbCloseArea() ) 
Return(lRet)                 
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณfGravaNFS()บAutor ณJailton B Santos-JBSบ Data ณ 24/02/2010  บฑฑ
ฑฑฬออออออออออุอออออออออออสออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Apos atualizar o valor do frete Calculado na Dipromed, faz บฑฑ
ฑฑบ          ณ o rateio do desconto total do frete do CTRC, entre as notasบฑฑ
ฑฑบ          ณ que compoem o CTRC.                                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Especifico - FATURAMENTO - Dipromed                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static function fGravaNFS(aDipInfNf)
//--------------------------------------------------------------------------------
Local lRet      := .F.
Local nId       := 0

//--------------------------------------------------------------------------------
SF2->( DbSetOrder(1) )
//--------------------------------------------------------------------------------
For nId:=1 to Len(aDipInfNf)   
	//--------------------------------------------------------------------------------
    // Localiza a nota fiscal
	//--------------------------------------------------------------------------------
	If SF2->( DbSeek(xFilial('SF2') + aDipInfNf[nId][1]) )
	    //--------------------------------------------------------------------------------
		SF2->( Reclock("SF2",.F.))
	    //--------------------------------------------------------------------------------
	    // Rateia o desconto do CTRC entre as notas fiscais que compoem o CTRC.
	    //--------------------------------------------------------------------------------
		If SF2->F2_TPFRETE $ 'CI' .and.; // S๓ atualiza o Frete se o tipo for CIF ou Incluso.
		   SF2->F2_FRTDIP = 0             // Valor do Frete Ainda nใo preenchido  
		   SF2->F2_FRTDIP := SF2->F2_FRETSZ3 / nSF2FretSZ3 * (aDipInfNf[nId][3] - aDipInfNf[nId][4])
		
		 AADD(aRecRat,{cValToChar(SF2->(Recno()))})  //Giovani Zago 21/11/11
	   EndIf 
	    //--------------------------------------------------------------------------------
	    // Grava o Numero do Conhecimento, na Nota Fiscal
	    //--------------------------------------------------------------------------------
		SF2->F2_NROCON  := aDipInfNf[nId][5]
		//SF2->F2_PESOCTR := aDipInfNf[nId][6]
        SF2->F2_PESOCTR := If(Len(aDipInfNf)>1,SF2->F2_PBRUTO/nSF2PesoBr*(aDipInfNf[nId][2]),aDipInfNf[nId][2])
	    //--------------------------------------------------------------------------------
		SF2->(MsUnlock("SF2"))
	    //--------------------------------------------------------------------------------
        lRet := .F.
	    //--------------------------------------------------------------------------------
	EndIf
Next nId
Return(lRet)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณfExistSZY()บAutor ณJailton B Santos-JBSบ Data ณ 24/02/2010  บฑฑ
ฑฑฬออออออออออุอออออออออออสออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Verifica se o CTRC ja esta gravado para evitar duplicidade บฑฑ
ฑฑบ          ณ de gravacao na tabela SZY.                                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Especifico - FATURAMENTO - Dipromed                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function fExistSZY()
Local lRet := .F. 
lRet := SZY->( DbSeek( xFilial('SZY') + TRB_TMS->TRANSP + TRB_TMS->DT6_DOC) )
Return(lRet)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณfAjustSX1()บAutor ณJailton B Santos-JBSบ Data ณ 24/02/2010  บฑฑ
ฑฑฬออออออออออุอออออออออออสออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Cria o Grupo de Perguntas no SX1                           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Especifico - FATURAMENTO - Dipromed                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿                              
*/
Static Function fAjustSX1()

Local nId_SX1
Local aRegs	:= {}
Local aArea := GetArea()
Local lRet  := .T.
                   
AAdd(aRegs,{"01","Dt Emissใo Inicial   ","mv_ch1","D",08,0,0,"G","mv_par01","" ,"","","",""})
AAdd(aRegs,{"02","Dt Emissใo Final     ","mv_ch2","D",08,0,0,"G","mv_par02","" ,"","","",""})

DbSelectArea("SX1")
DbSetOrder(1)

For nId_SX1:=1 to Len(aRegs)
	
	DbSeek( cPerg + aRegs[nId_SX1][1] )
	
	If !Found() .or. aRegs[nId_SX1][2]<>X1_PERGUNT
		
		RecLock("SX1",!Found())
		
		SX1->X1_GRUPO   := cPerg
		SX1->X1_ORDEM   := aRegs[nId_SX1][01]
		SX1->X1_PERGUNT := aRegs[nId_SX1][02]
		SX1->X1_VARIAVL := aRegs[nId_SX1][03]
		SX1->X1_TIPO    := aRegs[nId_SX1][04]
		SX1->X1_TAMANHO := aRegs[nId_SX1][05]
		SX1->X1_DECIMAL := aRegs[nId_SX1][06]
		SX1->X1_PRESEL  := aRegs[nId_SX1][07]
		SX1->X1_GSC     := aRegs[nId_SX1][08]
		SX1->X1_VAR01   := aRegs[nId_SX1][09]
		SX1->X1_DEF01   := aRegs[nId_SX1][10]
		SX1->X1_DEF02   := aRegs[nId_SX1][11]
		SX1->X1_DEF03   := aRegs[nId_SX1][12]
		SX1->X1_DEF04   := aRegs[nId_SX1][13]
		SX1->X1_F3      := aRegs[nId_SX1][14]
		
		MsUnlock()
		
	Endif 
	
Next nId_SX1
RestArea(aArea)
Return(lRet)  






/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  D2RatFret()บAutor ณGiovani Zago           Data ณ 14/11/2011   ฑฑ
ฑฑฬออออออออออุอออออออออออสออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Rateia o frete nos itens de cada nota                      บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ FAT - Dipromed                                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function D2RatFret(aRecRat) 

Local i        := 1
Local _cExc    := ""
Local aError   :={}
Local cEmail   := "maximo.canuto@dipromed.com.br"
Local cAssunto := "Erro No Rateio de Frete "
Local cAttach  := ""
Local cDe      := ""
Local cFuncSent:= "Dipm028.prw"



For i :=1 To Len(aRecRat)
	TcCommit(1)
	_cExc:=" UPDATE "+RetSqlName("SD2")
	_cExc+=" SET D2_FRTDIP = CONVERT(DECIMAL(10,3),Round((D2_TOTAL/F2_VALMERC*F2_FRTDIP),3))
	_cExc+=" FROM "+RetSqlName("SD2")+" SD2 , "+RetSqlName("SF2")+" SF2 "
	_cExc+=" WHERE SD2.D_E_L_E_T_  = ''
	_cExc+=" AND   SF2.D_E_L_E_T_  = ''
	_cExc+=" AND    F2_DOC         = D2_DOC
	_cExc+=" AND    F2_SERIE       = D2_SERIE
	_cExc+=" AND   SF2.R_E_C_N_O_  = "+aRecRat[i][1] 
	_cExc+=" AND    F2_FRTDIP      > 0
	_cExc+=" AND    D2_FRTDIP      = 0
	_cExc+=" AND    F2_FILIAL      = '"+xFilial("SD2")+"'"
	_cExc+=" AND    D2_FILIAL      = '"+xFilial("SF2")+"'"

	If TcSqlExec(_cExc) < 0
	   Aadd(aError,{"Documento",SF2->F2_DOC})
	   Aadd(aError,{"Serie"    ,SF2->F2_SERIE})
	   Aadd(aError,{"************","*********************"})
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณRollBack da transacaoณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		TcCommit(3)
	
		
	Else
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณConfirma as transacoesณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		TcCommit(2)
		TcCommit(4)
		MsUnlockAll()
	EndIf
Next i

If Len(aError)>0

U_UEnvMail(cEmail,cAssunto,aError,cAttach,cDe,cFuncSent)

EndIf

Return()

#INCLUDE "PROTHEUS.CH"

User Function UPDBIRFER()

Local aButtons  := {}
Local aSays     := {}
Local cMsg      := ""
Local lContinua := .F.
Local nOpcA     := 0

Private aCodFol := {}
Private aLog    := {}
Private aTitle  := {}
Private cPerg   := "UPDBFER"

//Carrega o array aCodFol para verificar o cadastro de verbas x Ids de c�lculo
Fp_CodFol(@aCodFol, cFilAnt, .F., .F.)

//Verifica se existe o cadastro da verba de Id 1562 e se a verba foi preenchida
If Len(aCodFol) >= 1562
	lContinua := !Empty( aCodFol[1562,1] )
EndIf 

//Se n�o existir cadastro da verba para o Id 1562, aborta o processamento da rotina
If !lContinua
	cMsg := OemToAnsi( "Para executar essa rotina � obrigat�rio o cadastro da verba (Tipo 3 - Base Provento) do seguinte identificador:" ) + CRLF
	cMsg += OemToAnsi( "1562 - Base de IRRF F�rias s/ dedu��o" )
	MsgInfo( cMsg )
	Return()
EndIf

//Cria as perguntas no dicion�rio SX1 para filtro do processamento
fCriaSX1()

aAdd(aSays,OemToAnsi( "Este programa tem como objetivo gerar a verba do Id 1562 - Base de IRRF F�rias s/" ))
aAdd(aSays,OemToAnsi( "dedu��o no movimento acumulado (tabela SRD) dos funcion�rios de acordo com as" ))
aAdd(aSays,OemToAnsi( "verbas das f�rias com incid�ncia de IR para a gera��o correta do evento S-1200" ))
aAdd(aSays,OemToAnsi( "do eSocial." ))
aAdd(aSays,OemToAnsi( "Obs.: para a gera��o da verba no movimento mensal (tabelas SRC) dever� ser efetuado"))
aAdd(aSays,OemToAnsi( "o rec�lculo da folha."))

aAdd(aButtons, { 5,.T.,{|| Pergunte(cPerg,.T. ) } } )
aAdd(aButtons, { 1,.T.,{|o| nOpcA := 1,IF(gpconfOK(), FechaBatch(), nOpcA := 0 ) }} )
aAdd(aButtons, { 2,.T.,{|o| FechaBatch() }} )

//Abre a tela de processamento
FormBatch( "Gera��o da Base de IRRF F�rias s/ dedu��o", aSays, aButtons )

//Efetua o processamento de gera��o
If nOpcA == 1
    Aadd( aTitle, OemToAnsi( "Funcion�rios que tiveram a verba de Id 1562 gerada:" ) )
    Aadd( aLog, {} )
    ProcGpe( {|lEnd| fProcessa()},,,.T. )
    fMakeLog(aLog,aTitle,,,"UPDBIRFER",OemToAnsi("Log de Ocorr�ncias"),"M","P",,.F.)
EndIf

Return

/*/{Protheus.doc} fProcessa
Fun��o que efetua o processamento para a gera��o do Id 1562
/*/
Static Function fProcessa()

Local cAliasQry := GetNextAlias()
Local cFilOld   := cFilAnt
Local cJoinRDRV	:= "% " + FWJoinFilial( "SRD", "SRV" ) + " %"
Local cWhere    := ""
Local lNovo     := .F.

Pergunte( cPerg, .F. )
MakeSqlExpr( cPerg )

//Filial
If !Empty(mv_par01)
    cWhere += mv_par01
EndIf

//Matricula
If !Empty(mv_par02)
	cWhere += Iif(!Empty(cWhere)," AND ","")
	cWhere += mv_par02
EndIf

//Periodo inicial
cWhere += Iif(!Empty(cWhere)," AND ","")
cWhere += "RD_DATARQ >= '" + mv_par03 + "' "

//Periodo final
cWhere += "AND RD_DATARQ <= '" + mv_par04 + "' "

//Filtro para somente trazer verbas que existam no c�lculo de f�rias (SRH)
cWhere += "AND EXISTS( SELECT SRR.RR_FILIAL, SRR.RR_MAT, SRR.RR_PD FROM " + RetSqlName('SRR') + " SRR WHERE SRR.RR_FILIAL = SRD.RD_FILIAL AND SRR.RR_MAT = SRD.RD_MAT AND SRR.RR_DATAPAG = SRD.RD_DATPGT AND SRR.RR_PD = SRD.RD_PD AND SRR.RR_ROTEIR = 'FER' AND SRR.D_E_L_E_T_ = ' ' )"

//Prepara a vari�vel para uso no BeginSql
cWhere := "%" + cWhere + "%"

//Processa a query e cria a tabela tempor�ria com os resultados
BeginSql alias cAliasQry
	SELECT SRD.RD_FILIAL, SRD.RD_MAT, SRD.RD_CC, SRD.RD_DATARQ, SRD.RD_SEMANA, SRD.RD_DATPGT, MIN(SRD.RD_SEQ) AS RD_SEQ, SUM(SRD.RD_VALOR) AS RD_VALOR
    FROM %table:SRD% SRD
    INNER JOIN %table:SRV% SRV
    ON	%exp:cJoinRDRV% AND
        SRV.RV_COD = SRD.RD_PD AND
        SRV.%notDel%
	WHERE %exp:cWhere% AND
			SRV.RV_TIPOCOD = '1' AND
            SRD.RD_IR = 'S' AND
            SRD.%notDel%
	GROUP BY SRD.RD_FILIAL, SRD.RD_MAT, SRD.RD_CC, SRD.RD_DATARQ, SRD.RD_SEMANA, SRD.RD_DATPGT
EndSql 

While (cAliasQry)->( !EoF() )
    //Carrega o array aCodFol para verificar o cadastro de verbas x Ids de c�lculo
    If (cAliasQry)->RD_FILIAL != cFilOld
        cFilOld := (cAliasQry)->RD_FILIAL
        RstaCodFol()
        Fp_CodFol(@aCodFol, (cAliasQry)->RD_FILIAL, .F., .F.)  
    EndIf
    
    //Ordena a tabela SRA pela ordem 1 - RA_FILIAL+RA_MAT
    SRA->( dbSetOrder(1) )
    //Posiciona na tabela SRA
    SRA->( dbSeek( (cAliasQry)->RD_FILIAL + (cAliasQry)->RD_MAT ) )
    
    //Ordena a tabela SRD pela ordem 1 - RD_FILIAL+RD_MAT+RD_DATARQ+RD_PD+RD_SEMANA+RD_SEQ+RD_CC
    SRD->( dbSetOrder(1) )
    //Verifica se a verba de Id 1562 j� exista na tabela SRD
    lNovo := SRD->( !dbSeek( (cAliasQry)->RD_FILIAL + (cAliasQry)->RD_MAT + (cAliasQry)->RD_DATARQ + aCodFol[1562, 1] + (cAliasQry)->RD_SEMANA + (cAliasQry)->RD_SEQ + (cAliasQry)->RD_CC ) )

    //Trava o registro na SRD para edi��o
    If SRD->( RecLock("SRD", lNovo) )
        //Se for inclus�o, grava todos campos da SRD
        //Se for altera��o, apenas altera o valor do registro
        If lNovo
            SRD->RD_FILIAL  := (cAliasQry)->RD_FILIAL
            SRD->RD_MAT     := (cAliasQry)->RD_MAT
            SRD->RD_CC      := (cAliasQry)->RD_CC
            SRD->RD_PD      := aCodFol[1562, 1]
            SRD->RD_TIPO1   := "V"
            SRD->RD_DATARQ  := (cAliasQry)->RD_DATARQ
            SRD->RD_DATPGT  := sToD((cAliasQry)->RD_DATPGT)
            SRD->RD_SEQ     := (cAliasQry)->RD_SEQ
            SRD->RD_TIPO2   := "C"
            SRD->RD_MES     := SubStr( (cAliasQry)->RD_DATARQ, 5, 2 )
            SRD->RD_STATUS  := "A"
            SRD->RD_INSS    := "N"
            SRD->RD_IR      := "N"
            SRD->RD_FGTS    := "N"
            SRD->RD_PROCES  := SRA->RA_PROCES
            SRD->RD_PERIODO := (cAliasQry)->RD_DATARQ
            SRD->RD_SEMANA  := (cAliasQry)->RD_SEMANA
            SRD->RD_ROTEIR  := "FOL"
            SRD->RD_DTREF   := sToD((cAliasQry)->RD_DATPGT)
        EndIf
        SRD->RD_VALOR   := (cAliasQry)->RD_VALOR
        
        //Adiciona no log de ocorr�ncias
        aAdd( aLog[1], "Filial: " + (cAliasQry)->RD_FILIAL + "  -  Matr�cula: " + (cAliasQry)->RD_MAT + "  -  Per�odo: " + (cAliasQry)->RD_DATARQ + "  -  Valor: R$ " + cValToChar( Transform( (cAliasQry)->RD_VALOR, "@E 99,999,999,999.99" ) ) )

        //Libera o registro da SRD
        SRD->( MsUnlock() )
    EndIf
    
    //Pula para o pr�ximo registro
    (cAliasQry)->( dbSkip() )
EndDo

//Fecha a tabela tempor�ria da query
(cAliasQry)->( dbCloseArea() )

Return

/*/{Protheus.doc} fCriaSX1
Fun��o que cria as perguntas que ser�o utilizdas na rotina
/*/
Static Function fCriaSX1()

Local aHelpPor := {}

AAdd( aHelpPor, "Informe o per�odo inicial para a" )
AAdd( aHelpPor, "gera��o da verba de base." )
EngHLP117( "P"+".UPDBFER03.", aHelpPor, aHelpPor, aHelpPor )

aHelpPor := {}
AAdd( aHelpPor, "Informe o per�odo final para a" )
AAdd( aHelpPor, "gera��o da verba de base." )
EngHLP117( "P"+".UPDBFER04.", aHelpPor, aHelpPor, aHelpPor )

//			<cGrupo>	, <cOrdem>	, <cPergunt>				, <cPerSpa>	, <cPerEng>		, <cVar>	,<cTipo>	,<nTamanho>	,<nDecimal>		, <nPresel>		,<cGSC>	,<cValid>							,<cF3>		,<cGrpSxg>	,<cPyme>	,<cVar01>			,<cDef01> 		,<cDefSpa1>		,<cDefEng1>		,<cCnt01>		,<cDef02>				,<cDefSpa2>				,<cDefEng2>			,<cDef03>	, <cDefSpa3>	,<cDefEng3>		, <cDef04>	,<cDefSpa4>		, <cDefEng4>	,<cDef05>		, <cDefSpa5>	, <cDefEng5>	, <aHelpPor>, <aHelpEng>	, <aHelpSpa>	, <cHelp> )
EngSX1117( cPerg 	    , "01" 		,"Filial ?"			 		, ""		, ""		 	, "MV_CH1" 	, "C" 		, 99		,0				, 0	   			, "R" 	, ""								, "XM0" 	, ""		, "S" 		, "MV_PAR01" 		, "" 	   		, "" 			, "" 			, "RD_FILIAL"	, "" 					, ""					, "" 	 			, "" 		, "" 			, "" 			, "" 		, ""	 		, ""	  	 	, ""			, "" 		 	, ""	  		, {}	   	, {}   			, {} 			, ".RHFILDE."	)
EngSX1117( cPerg 	    , "02" 		,"Matr�cula ?"	 			, "" 		, ""			, "MV_CH2"	, "C" 		, 99   		,0	  			, 0	  	 		, "R" 	, ""								, "SRA" 	, "" 		, "S" 		, "MV_PAR02" 		, "" 	  		, "" 			, "" 			, "RD_MAT"		, "" 					, ""					, "" 	 			, "" 		, "" 			, "" 			, "" 	 	, ""	  		, ""	   		, ""		  	, "" 		 	, ""	  		, {}	   	, {} 			, {} 			, ".RHMATD."	)
EngSX1117( cPerg 	    , "03"		,"Per�odo inicial? (AAAAMM)", ""		, ""	        , 'MV_CH3'	, 'C'		, 6			,0				, 0				, 'G'	, 'NaoVazio()'						, ""		, ""		, "S"		, "MV_PAR03"		, "" 	   		, ""			, "" 	   		, ""			, "" 					, "" 					, "" 	 			, ""	  	, ""	   		, ""		  	, "" 		, ""	  		, ""	   		, "" 			, "" 			, ""	  		, {}	   	, {} 			, {} 			, ".UPDBFER03."	)
EngSX1117( cPerg 	    , "04"		,"Per�odo final? (AAAAMM)"	, ""		, ""	        , 'MV_CH4'	, 'C'		, 6			,0				, 0				, 'G'	, 'NaoVazio()'						, ""		, ""		, "S"		, "MV_PAR04"		, "" 			, ""			, "" 	   		, ""			, "" 					, "" 					, "" 	 			, ""	  	, ""	   		, ""		  	, "" 		, ""	  		, ""	   		, "" 			, "" 			, ""	  		, {}	   	, {} 			, {} 			, ".UPDBFER04."	)

Return
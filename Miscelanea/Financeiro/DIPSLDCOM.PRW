#Include "Protheus.ch"
#Include "TopConn.ch"

/*
|-----------------------------------------------------------------------------------|
|  Programa : DIPSLDCOM                                       Data : 26/07/2021     |
|-----------------------------------------------------------------------------------|
|  Cliente  : DIPROMED                                                              |
|-----------------------------------------------------------------------------------|
|  Responsavel Microsiga no Cliente : MAXIMO                                        |
|-----------------------------------------------------------------------------------|
|  Uso      : Cálculo do Saldo comercial Geração (ExecAuto) ORÇAMENTO em aberto                                |
|-----------------------------------------------------------------------------------|
|  Autor    : TEO MONTEIRO - OBIFY                                                  |
|-----------------------------------------------------------------------------------|
|  Tabelas Envolvidas: Diversas                                                     |
|-----------------------------------------------------------------------------------|
|               ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL                    |
|------------+---------+-------+----------------------------------------------------|
| Programador|  Data   | BOPS  |  Motivo da Alteracao                               |
|------------+---------+-------+----------------------------------------------------|
|            |         |       |                                                    |
|-----------------------------------------------------------------------------------|
*/

//=======================
User Function DIPSLDCOM()
//=======================
Local aArea         := GetArea()
Local   cPerg	    := "DIPSLDCOM1"
Local   aParamBox 	:= {}
Local MVPAR01		:= ddatabase
Local MVPAR02       := CriaVar("A1_COD")
Local MVPAR03       := CriaVar("A1_COD")

Private aRet    	:= {} 
Private _dDataIni   := ddatabase
Private _dDataFim   := ddatabase
Private _dDataLim   := ddatabase
Private _cCodIni    := Space(6)
Private _cCodFim    := Space(6)

If !IsBlind()
    aAdd( aParamBox,{1,"Data Limite"    , MVPAR01,	"@"   , '!Empty(mv_par01)', "", '.T.',80,.T.})
    aAdd( aParamBox,{1,"Do Cliente"		, MVPAR02,	"@"   , '', "SA1", '.T.',80,.F.})
    aAdd( aParamBox,{1,"Ate Cliente"	, MVPAR03,	"@"   , '', "SA1", '.T.',80,.F.})

    If ParamBox(aParamBox,"Parâmetros",@aRet,,,,,,,cPerg,.T.,.T.)
        _dDataLim	:= aRet[1]
        _cCodIni    := aRet[2]
        _cCodFim    := aRet[3]
    Else
        Return (.T.)
    Endif 
Else
    _dDataLim	:= ddatabase
    _cCodIni    := "      "
    _cCodFim    := "ZZZZZZ"
Endif

oProcess := MsNewProcess():New({|lEnd| ProcSLD(@oProcess, @lEnd )},"Gravação Saldos Acumulados","Lendo Registros...",.T.)
oProcess:Activate()

Alert("Rotina Finalizada!!!")
RestArea(aArea)
Return

//=====================================
Static Function ProcSLD(oProcess, lEnd)
//=====================================

Local aArea      := GetArea()
//Local   cPerg	 := "DIPSLDCOM1"
Local _dData     := CtoD("01/01/20")
Local _nMoeda    := 1
Local _dDataSld  := _dData
Local _nSaldoCli := 0

cDia    := Strzero(Day(_dDataLim)   , 2)
cMes    := Strzero(Month(_dDataLim) , 2)
cAno    := Strzero(Year(_dDataLim)-5, 4) // processamento a partir de 5 anos atras!
_dData  := CtoD(cDia+"/"+cMes+"/"+cAno)

DbSelectArea("SA1")
DbSetOrder(1)
DbGoTop()
oProcess:SetRegua1(RecCount())
Do While !Eof()

    If (SA1->A1_COD < _cCodIni) .Or. (SA1->A1_COD > _cCodFim) .Or. SA1->A1_ULTCOM < StoD('20210601')
        DbSkip()
        Loop
    Endif

    If !IsBlind()
        oProcess:IncRegua1("Processando Cliente/Loja: "+SA1->A1_COD+"/"+SA1->A1_LOJA)
    Else
        Conout("Processando Cliente/Loja: "+SA1->A1_COD+"/"+SA1->A1_LOJA)
    Endif

    _dxDtUltA := SA1->A1_XDTULTA
    _dDatMIn := Iif(!Empty(_dxDtUltA), _dxDtUltA, MinDatCli())
    
    If Empty(_dDatMIn)
        _dDatMIn := _dDataLim
    ElseIf DTOS(_dData) > DtoS(_dDatMIn) 
        _dDatMIn := _dData
    Endif
    
    _nSaldoCli  := SA1->A1_XSLDCOM // Saldo Comercial gravado no cliente
    _dDataSld   := CtoD(Space(8))

    While DtoS(_dDatMIn) <= Dtos(_dDataLim)

        If !IsBlind()
            oProcess:IncRegua2("Processando Data: "+DtoC(_dDatMIn))
        Endif

        _nSaldo := RetSldCli(SA1->A1_COD+sA1->A1_LOJA, _dDatMIn, _nMoeda)
        /*
        If _nSaldo >= _nSaldoCli'
            _nSaldoCli := _nSaldo
            _dDataSld  := _dDatMIn
        Endif
        */
        If _nSaldo > _nSaldoCli
            If RecLock("SA1", .F.)
                SA1->A1_XSLDCOM := _nSaldo
                SA1->A1_XDTSLDM := _dDatMIn
                SA1->A1_XDTULTA := _dDataLim // _dDataSld
                MsUnLock()
            Endif
            _nSaldoCli := _nSaldo
        Endif
        _dDatMIn++
    EndDo
    
    // Regrava Saldo, somente "Maior Saldo Acumulado" for maior que o maior saldo gravado
    If _nSaldo > _nSaldoCli
        If RecLock("SA1", .F.)
            SA1->A1_XSLDCOM := _nSaldoCli
            SA1->A1_XDTSLDM := _dDataSld
            SA1->A1_XDTULTA := _dData // _dDataSld
            MsUnLock()
        Endif
    Endif

    cDia    := Strzero(Day(_dDataLim)   , 2)
    cMes    := Strzero(Month(_dDataLim) , 2)
    cAno    := Strzero(Year(_dDataLim)-5, 4)
    _dData  := CtoD(cDia+"/"+cMes+"/"+cAno)

    DbSelectArea("SA1")
    DbSkip()
Enddo
Conout("Rotina Finalizada")
RestArea(aArea)

Return (.T.)

//=========================
Static Function MinDatCli()
//=========================
Local cQryAux   := GetNextAlias()
cQuery := " SELECT MIN(E1_EMISSAO) E1_DATMIN FROM "+RetSQLName("SE1")+" SE1 WHERE E1_CLIENTE+E1_LOJA= '"+SA1->A1_COD+SA1->A1_LOJA+"' AND SE1.D_E_L_E_T_ <> '*' "
cQuery := ChangeQuery(cQuery)
TcQuery cQuery NEW Alias &cQryAux
dMinData := StoD((cQryAux)->E1_DATMIN)
(cQryAux)->(dbCloseArea())
Return (dMinData)

//================================================
Static Function RetSldCli(cCliLoja, dData, nMoeda)
//================================================
// --('" + MV_CRNEG + "','" + MV_CPNEG + "','" + MVABATIM + "') 
// Local cFiltro   := "('PCC','"+StrTran(MVABATIM,"|","','")+")"
Local cFiltro   := "('PCC','"+StrTran(MVABATIM,"|","','")+"')"
Local cQryAux	:= GetNextAlias()

cQuery := " SELECT
cQuery += "         SUM(CASE WHEN E1_EMISSAO < '"+DtoS(dData)+"' AND E1_BAIXA > '"+DtoS(dData)+"'  THEN E1_VALOR ELSE 0 END) VALOR_ABERTO,
cQuery += "         SUM(CASE WHEN (E1_EMISSAO = E1_VENCREA AND E1_EMISSAO < '"+DtoS(dData)+"'  AND E1_BAIXA > "+DtoS(dData)+" )  THEN E1_VALOR ELSE 0 END) A_VISTA,
cQuery += "         SUM(CASE WHEN E1_TIPO IN "+cFiltro+" THEN E1_VALOR ELSE 0 END ) ABATIMENTO

cQuery += "     FROM 
cQuery += "         "+RetSQLNAme("SE1")+" SE1 "

cQuery += "     WHERE 
cQuery += "         E1_CLIENTE+E1_LOJA  =  '"+cCliLoja+"' "
cQuery += "     AND E1_EMISSAO  <= '"+DtoS(dData)+"' " 
cQuery += "     AND E1_BAIXA    >  '"+DtoS(dData)+"' " 
cQuery += "     AND SE1.D_E_L_E_T_ <> '*' "
cQuery := ChangeQuery(cQuery)
TcQuery cQuery NEW Alias &cQryAux

_nRet := (cQryAux)->VALOR_ABERTO - A_VISTA - ABATIMENTO
(cQryAux)->(dbCloseArea())
// Alert(_nRet)
Return (_nRet)



//================================================
Static Function RetQryCli(cCliLoja, dData, nMoeda)
//================================================
Local cQryAux	:= GetNextAlias()
Local cFilABT   := "('PCC','"+StrTran(MVABATIM,"|","','")+"')"
cQuery := " DECLARE @site_value date; " + CRLF
cQuery += " DECLARE @site_ate date; " + CRLF
cQuery += " DECLARE @site_valor float; " + CRLF
cQuery += " DECLARE @valor_final float; " + CRLF
cQuery += " DECLARE @siteconv varchar(8); " + CRLF
cQuery += " DECLARE @data_final varchar(8); " + CRLF
cQuery += " SET @site_value = '01-01-2020'; " + CRLF
cQuery += " SET @data_final = '01-01-1985'; " + CRLF
cQuery += " SET @site_valor = 0; " + CRLF
cQuery += " SET @valor_final = 0; " + CRLF
cQuery += " SET @site_ate = '09-08-2021'  " + CRLF // --   DATEADD(Day, 10, @site_value);
cQuery += " WHILE @site_value <= @site_ate " + CRLF
cQuery += " BEGIN " + CRLF
// cQuery += "    -- PRINT CONVERT(VARCHAR, @site_value, 112) + '-';
cQuery += "    SET @siteconv = CONVERT(VARCHAR, @site_value, 112);    " + CRLF
cQuery += "    SET @site_valor= (		SELECT " + CRLF
cQuery += " 		(SUM(CASE WHEN (E1_EMISSAO < @siteconv AND E1_BAIXA > @siteconv)  THEN E1_VALOR ELSE 0 END) -  " + CRLF
cQuery += " 		 SUM(CASE WHEN (E1_EMISSAO = E1_VENCREA AND E1_EMISSAO < @siteconv AND E1_BAIXA > @siteconv AND E1_TIPO NOT IN ('NCC','AB-','CF-','CS-','FU-','I2-','IN-','IR-','IS-','PI-','AB-','CF-','CS-','FU-','IN-','IR-','IS-','PI-','AB-','CF-','CS-','FU-','GN-','IB-','IN-','IR-','IS-','IV-','PI-','AB-','CF-','CS-','FU-','IN-','IR-','IS-','PI-','AB-','CF-','CS-','FU-','GN-','IB-','IN-','IR-','IS-','IV-','PI-','FC-','FE-'))  THEN E1_VALOR ELSE 0 END) -	 " + CRLF
cQuery += " 		 SUM(CASE WHEN E1_TIPO IN "+cFilABT+" THEN E1_VALOR ELSE 0 END )) " + CRLF

cQuery += " 		FROM SE1010 SE1 " + CRLF

cQuery += " 		WHERE  " + CRLF
cQuery += " 			E1_CLIENTE+E1_LOJA = '"+cCliLoja+"' AND  " + CRLF
cQuery += " 			E1_EMISSAO <= @siteconv " + CRLF
cQuery += " 		AND E1_BAIXA > @siteconv " + CRLF
cQuery += " 		AND D_E_L_E_T_ <> '*' " + CRLF
cQuery += " 		GROUP BY E1_CLIENTE) " + CRLF
// cQuery += " 	--PRINT 'Data utilizada: '+@siteconv;
// cQuery += " 	-- PRINT @site_valor;
cQuery += " 	if @site_valor > @valor_final " + CRLF
cQuery += " 		SET @valor_final = @site_valor " + CRLF
cQuery += " 		SET @data_final = @siteconv " + CRLF
		
cQuery += " 	SET @site_value = DATEADD(Day, 1, @site_value); " + CRLF

cQuery += " END; " + CRLF

// cQuery += " -- PRINT 'data final ' + @data_final
// cQuery += " -- PRINT @valor_final
cQuery += " GO " + CRLF
cQuery := ChangeQuery(cQuery)
TcQuery cQuery NEW Alias &cQryAux
(cQryAux)->( DBCloseArea() )

/*

BeginSQL Alias _cAlias

    SELECT
        SUM(CASE WHEN E1_EMISSAO < %Exp:DtoS(dData)%  AND E1_BAIXA > %Exp:DtoS(dData)%  THEN E1_VALOR ELSE 0 END) VALOR_ABERTO,
        SUM(CASE WHEN (E1_EMISSAO = E1_VENCREA AND E1_EMISSAO < %Exp:DtoS(dData)%  AND E1_BAIXA > %Exp:DtoS(dData)% )  THEN E1_VALOR ELSE 0 END) A_VISTA,
        SUM(CASE WHEN E1_TIPO IN %Exp:cFiltro% THEN E1_VALOR ELSE 0 END ) ABATIMENTO

    FROM 
        %table:SE1% SE1

    WHERE 
        E1_CLIENTE  =  %Exp:Substr(cCliLoja,1,6)%
    AND E1_EMISSAO  <= %Exp:DtoS(dData)% 
    AND E1_BAIXA    >  %Exp:DtoS(dData)% 
    AND SE1.%NotDel%

EndSql
*/

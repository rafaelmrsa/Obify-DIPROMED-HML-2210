#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FA060QRY  º Autor ³ Consultoria        º Data ³  04/12/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Filtro Bordero                                             º±±
±±º  Tipo    ³ Ponto de Entrada                                           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Dipromed                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function FA060QRY()         
Local _cQueryADD 
Local aBoxParam:= {}
Local aRetParam:= {}

Aadd(aBoxParam,{2,"Impressão de boleto:",1,{"001 - Dipromed","002 - Banco"},100,"",.F.})

U_DIPPROC(ProcName(0),U_DipUsr()) // MCVN - 22/01/2009

IF cEmpAnt == "01"

	_cQry := "SELECT EE_CODIGO,EE_AGENCIA,EE_CONTA" 
	_cQry += " FROM SEE010 SEE WITH (NOLOCK) "
	_cQry += " WHERE  EE_FILIAL = '"+XFILIAL("SA6")+"'" 
	_cQry += " AND EE_CODIGO = '"+SA6->A6_COD+"'"
	_cQry += " AND EE_AGENCIA = '"+SA6->A6_AGENCIA+"'"
	_cQry += " AND EE_CONTA = '"+SA6->A6_NUMCON+"'" 
	_cQry += " AND D_E_L_E_T_ = '' "
	_cQry += " GROUP BY EE_CODIGO,EE_AGENCIA,EE_CONTA "
	_cQry += " HAVING Count(*) > 1 "
	TCQUERY _cQry NEW ALIAS "QSEE"
	dbSelectArea("QSEE")
	IF QSEE->(!EOF())
		If ParamBox(aBoxParam,"Informe os Parametros",@aRetParam)
			MV_Par01:= IIf(ValType(Mv_Par01) == "N",StrZero(Mv_Par01,1),Left(Mv_Par01,1))
			IF (MV_PAR01=="1")
				_cQueryADD := " E1_PORTADO <> '' AND "
				_cQueryADD += " E1_AGEDEP <> '' AND "
				_cQueryADD += " E1_CONTA <> '' "						
			ELSE
				_cQueryADD := " E1_PORTADO = '' AND "
				_cQueryADD += " E1_AGEDEP = '' AND "
				_cQueryADD += " E1_CONTA = '' "						
			ENDIF
		ENDIF
	ENDIF
	QSEE->(dbCloseArea())

ELSE

	_cQueryADD := " E1_NUMBCO = ' '"
	_cQueryADD += " OR (E1_NUMBCO <> '' "
	_cQueryADD += "     AND E1_SITUACA = '0'"
	_cQueryADD += "     AND E1_AGEDEP = '"+PARAMIXB[1]+"'" 
	_cQueryADD += "     AND E1_CONTA = '"+PARAMIXB[2]+"'" 
	_cQueryADD += "    )" 

ENDIF

Return _cQueryADD
#INCLUDE "PROTHEUS.CH"
User Function F060VLOK()                     
Local lRet := .T.                           
Local cMsg := ""
//ExecBlock("F060VLOK",.F.,.F.,{cNumBor, cPort060,cAgen060,cConta060,cSituacao,dVencIni,dVencFim,nLimite,nMoeda,cContrato,dEmisDe,dEmisAte,cCliDe,cCliAte})
Local cNumBor	:= PARAMIXB[01]
Local cPort060	:= PARAMIXB[02]
Local cAgen060	:= PARAMIXB[03]
Local cConta060	:= PARAMIXB[04]
Local cSituacao	:= PARAMIXB[05]
Local dVencIni	:= PARAMIXB[06]
Local dVencFim	:= PARAMIXB[07]
Local nLimite	:= PARAMIXB[08]
Local nMoeda	:= PARAMIXB[09]
Local cContrato	:= PARAMIXB[10]
Local dEmisDe	:= PARAMIXB[11]
Local dEmisAte	:= PARAMIXB[12]
Local cCliDe	:= PARAMIXB[13]
Local cCliAte	:= PARAMIXB[14]                 
Local cCliNBol  := GetNewPar("ES_CLINBOL","000804/000233/000077")

If cEmpAnt<>'04'
	Return lRet
EndIf


If mv_par12 == 1  
	finatipos()
Endif

cQuery := "SELECT "
cQuery += " E1_PREFIXO, E1_NUM, E1_TIPO, E1_PARCELA "
cQuery += "  FROM "+	RetSqlName("SE1") + " SE1, "+ RetSqlName("SA1") + " SA1 "
cQuery += " WHERE E1_FILIAL = '"+xFilial("SE1")+"'"
cQuery += "   AND E1_NUMBOR = '      '"
cQuery += "   AND E1_EMISSAO Between '" + DTOS(dEmisDe) + "' AND '" + DTOS(dEmisAte) + "'"
cQuery += "   AND E1_CLIENTE between '" + cCliDe        + "' AND '" + cCliAte        + "'"
cQuery += "   AND E1_VENCREA between '" + DTOS(dVencIni)+ "' AND '" + DTOS(dVencFim) + "'"
cQuery += "   AND E1_MOEDA = "+ str(nmoeda)
cQuery += "   AND E1_PREFIXO Between '" + cPrefDe + "' AND '" + cPrefAte + "'"
cQuery += "   AND E1_NUM between '"     + cNumDe  + "' AND '" + cNumAte  + "'"
cQuery += "   AND E1_SALDO > 0 "
cQuery += "   AND E1_NUMBCO =  ' ' "
If mv_par12 == 1
	cQuery += "   AND E1_TIPO IN " + FormatIn(cTipos,"/")
Endif
If !Empty(MVPROVIS) .Or. !Empty(MVRECANT) .Or. !Empty(MV_CRNEG) .Or. !Empty(MVENVBCOR)
	cQuery += "   AND E1_TIPO NOT IN " + FormatIn(MVPROVIS+"/"+MVRECANT+"/"+MV_CRNEG+"/"+MVENVBCOR,"/")
Endif
cQuery += "   AND E1_SITUACA IN ('0','F','G') "
cQuery += "   AND A1_FILIAL = '"+xFilial("SA1")+"' "
cQuery += "   AND A1_COD = E1_CLIENTE "
cQuery += "   AND A1_LOJA = E1_LOJA "
cQuery += "   AND A1_SATIV8 <> '999992' "       
cQuery += "   AND A1_COD NOT IN "+ FormatIn(cCliNBol,"/")
cQuery += "   AND SE1.D_E_L_E_T_ = ' ' "
cQuery += "   AND SA1.D_E_L_E_T_ = ' ' "

cQuery := ChangeQuery(cQuery)
dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'QRYSE1', .F., .T.)

While !QRYSE1->(Eof())
    cMsg += QRYSE1->(E1_PREFIXO+E1_NUM+E1_TIPO+E1_PARCELA)+CHR(10)+CHR(13)
	QRYSE1->(dbSkip())
EndDo
QRYSE1->(dbCloseArea())

If !Empty(cMsg)
	Aviso("Erro","Existem títulos sem o número bancário"+CHR(10)+CHR(13)+cMsg,{"Ok"},3)    
	lRet := .F.
EndIf

Return lRet
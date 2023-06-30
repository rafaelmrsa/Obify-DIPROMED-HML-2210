#include 'protheus.ch'
#include 'parmtype.ch'
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDipExpMDF บAutor  ณMicrosiga           บ Data ณ  08/18/16   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
user function DipExpMDF()
Local cSQL 		 := ""
Local aBoxParam  := {}
Local lFlag      := .F.
Local aRetParam  := {}

Aadd(aBoxParam,{1,"Data De   "	,StoD(""),"@D"			,"","","",40,.F.})
Aadd(aBoxParam,{1,"Data At้  "	,StoD(""),"@D"			,"","","",40,.F.})
Aadd(aBoxParam,{1,"MDF-e De  "	,Space(9),"@E 999999999","","","",40,.F.})
Aadd(aBoxParam,{1,"MDF-e At้ "	,Space(9),"@E 999999999","","","",40,.F.})

If ParamBox(aBoxParam,"Informe os Parametros",@aRetParam)

	cSQL := " SELECT "
	cSQL += " 	SPED050.ID_ENT, SPED050.NFE_ID NF, "
	cSQL += " 	RTRIM(LTRIM(CONVERT(VARCHAR(8000),CONVERT(VARBINARY(8000),XML_SIG))))  SIG, "
	cSQL += " 	RTRIM(LTRIM(CONVERT(VARCHAR(8000),CONVERT(VARBINARY(8000),XML_PROT)))) PROT "
	cSQL += " 	FROM " 
	cSQL += " 		SPED050 " 
	cSQL += " 		INNER JOIN "
	cSQL += " 			SPED054 " 
	cSQL += " 			ON "
	cSQL += " 				SPED050.ID_ENT  = SPED054.ID_ENT AND "
	cSQL += " 				SPED050.NFE_ID  = SPED054.NFE_ID "				
	cSQL += " 		WHERE "
	cSQL += " 			SPED050.ID_ENT 		= '000007' AND "
	cSQL += " 			SUBSTRING(SPED050.NFE_ID,6,9) BETWEEN '"+mv_par03+"' AND '"+mv_par04+"' AND "
	cSQL += " 			SPED050.DATE_NFE BETWEEN '"+DtoS(mv_par01)+"' AND '"+DtoS(mv_par02)+"' AND "
	cSQL += " 			SPED050.MODELO 		= '58' AND "
	cSQL += " 			SPED054.CSTAT_SEFR 	= '100' AND "
	cSQL += " 			SPED050.D_E_L_E_T_ 	= ' ' AND "
	cSQL += " 			SPED054.D_E_L_E_T_ 	= ' ' "

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),'QRYMDFE',.T.,.F.)
	
	While !QRYMDFE->(Eof())
	
		If !Empty(QRYMDFE->SIG+QRYMDFE->PROT)							
			cXMLEXP := '<mdfeProc xmlns="http://www.portalfiscal.inf.br/mdfe" versao="1.00">'
			cXMLEXP += AllTrim(QRYMDFE->SIG)
			cXMLEXP += AllTrim(QRYMDFE->PROT)
			cXMLEXP +='</mdfeProc>'
		
			_nH := DipCriaRC("XMLMDFE_"+SUBSTRING(QRYMDFE->NF,6,9)+".xml","C:\averbacao\XML_MDFE")        
	
			If _nH > 0                       
				FWrite(_nH,cXMLEXP)	
				FClose(_nH)						      
			EndIf
			lFlag := .T.			
		EndIf
		
		QRYMDFE->(dbSkip())
	EndDo
	QRYMDFE->(dbCloseArea())	
EndIf

If lFlag
	MsgInfo("Arquivos gerados com sucesso na pasta C:\averbacao\XML_MDFE")
Else
	MsgInfo("Nใo foram encontrados registros com estes parโmetros")
EndIf
	
return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDipExpMDF บAutor  ณMicrosiga           บ Data ณ  08/18/16   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function DipCriaRC(cNomArq,cDir)
Local _nH 		:= 0 
DEFAULT cNomArq := ""
DEFAULT cDir 	:= ""
                   
cNomArq := cDir+"\"+cNomArq

If !ExistDir(cDir)         
	If Makedir(cDir) <> 0
		Return
	Endif                  
Endif

If File(cNomArq)
	FErase(cNomArq)
EndIf

If !File(cNomArq)
	_nH := FCreate(cNomArq)
Endif 	  

Return _nH
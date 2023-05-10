#include "protheus.ch"
#include "parmtype.ch"
#INCLUDE "RWMAKE.CH"
#include "TbiConn.ch"
#include "TbiCode.ch"
#INCLUDE "TOTVS.CH"
#INCLUDE "FONT.CH"
#INCLUDE "TOPCONN.ch"
#include "Fileio.ch"

/*====================================================================================\
|Programa  | JBEXPMDF    | Autor | Rafael Rosa               | Data | 25/08/2022      |
|=====================================================================================|
|Descrição | Exportacao de MDFe                                                       |
|          |                                                                          |
|          |                                                                          |
|=====================================================================================|
|Sintaxe   | JBEXPMDF                                                                 |
|=====================================================================================|
|Uso       | Especifico DIPROMED                                                      |
|=====================================================================================|
|........................................Histórico....................................|
|Dev       | DD/MM/AA - Descrição                                                     |
|Rafael    | 25/08/2022 - Fonte elaborado (Em fase de testes)                         |
|Rafael    | 01/09/2022 - Fonte em analise. Diretorio/arquivo nao gerado via Schedule |
|Rafael    | 07/09/2022 - Diretorio em \Protheus_Data definido no MV_ZDIEXOM          |
\====================================================================================*/

user function JBEXPMDF()

Local cSQL		:= ""
Local lFlag		:= .F.
Local cDirDest	:= GetNewPar("MV_ZDIEXOM","")

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
	//cSQL += " 			SPED050.DATE_NFE = '" + DTOS(Date()) + "' AND "
	//cSQL += " 			SPED050.DATE_NFE = '20220831' AND "
	//cSQL += " 			SPED050.DATE_NFE = '" + DTOS(dDatabase) + "' AND "  //Rafael Moraes Rosa - 22/12/2022 - Linha comentada
	cSQL += " 			SPED050.DATE_NFE = '" + IIF(!Empty(GetMV("MV_ZDTEXOM")),GetMV("MV_ZDTEXOM"),DTOS(dDatabase)) + "' AND " //Rafael Moraes Rosa - 22/12/2022 - Linha adicionada
	cSQL += " 			SPED050.MODELO 		= '58' AND "
	cSQL += " 			SPED054.CSTAT_SEFR 	= '100' AND "
	cSQL += " 			SPED050.D_E_L_E_T_ 	= ' ' AND "
	cSQL += " 			SPED054.D_E_L_E_T_ 	= ' ' "

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),'QRY_',.T.,.F.)
	dbSelectArea("QRY_")

	While !QRY_->(Eof())
	
		If !Empty(QRY_->SIG+QRY_->PROT)							
			cXMLEXP := '<mdfeProc xmlns="http://www.portalfiscal.inf.br/mdfe" versao="1.00">'
			cXMLEXP += AllTrim(QRY_->SIG)
			cXMLEXP += AllTrim(QRY_->PROT)
			cXMLEXP +='</mdfeProc>'

			_nH := CriaRep("XMLMDFE_"+SUBSTRING(QRY_->NF,6,9)+".xml",cDirDest)
	
			If _nH > 0                       
				FWrite(_nH,cXMLEXP)	
				FClose(_nH)						      
			EndIf
			lFlag := .T.			
		EndIf
		
		QRY_->(dbSkip())
	EndDo
	QRY_->(dbCloseArea())

return

Static Function CriaRep(cNomArq,cDirDest)
Local _nH			:= 0
DEFAULT cNomArq		:= ""
DEFAULT cDirDest	:= ""
                   
cNomArq := cDirDest+"\"+cNomArq

If !ExistDir(cDirDest)         
	If Makedir(cDirDest) <> 0
		Return
	Endif                  
Endif

If File(cNomArq)
	FErase(cNomArq)
EndIf

If !File(cNomArq)
	_nH := MsfCreate(cNomArq,0)
Endif 	  

Return _nH

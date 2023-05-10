#INCLUDE "PROTHEUS.CH"
#INCLUDE "COLORS.CH"
#INCLUDE 'FWMVCDEF.CH'

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³NOVO6     ºAutor  ³Microsiga           º Data ³  08/17/15   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function DIPA073()  
Local oDlg                                    
Local cSQL    := ""
Local nLin	  := 0
Local nCol	  := 0
Local nQtdSZR := 0
Local nQtdZZF := 0
Local nQtdSUC := 0
Local nQtdAVA := 0
Local QRYSC5  := 0                            
Local lRet	  := .F.
Private oFont28 := TFont():New("Arial",9,28,.T.,.T.,5,.T.,5,.T.,.F.)
Private oFont30 := TFont():New("Arial",9,30,.T.,.T.,5,.T.,5,.T.,.F.)

If !Upper(u_DipUsr())$GetNewPar("ES_DIPA073","EPONTOLDIO/PMENDONCA/BRODRIGUES/MCANUTO/DDOMINGOS")
	Aviso("ES_DIPA073","Você não tem acesso para executar esta rotina",{"Ok"},1)
	Return .F.
EndIf

cSQL := " SELECT "
cSQL += "	COUNT(ZR_NUMERO) QTD " 
cSQL += "	FROM "
cSQL += 		RetSQLName("SZR")
cSQL += "		WHERE "
cSQL += "			ZR_FILIAL = '"+xFilial("SZR")+"' AND "
cSQL += "			ZR_STATUS IN ('AGUARDANDO') AND "
cSQL += "			D_E_L_E_T_ = ' ' "

cSQL := ChangeQuery(cSQL)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),"QRYSZR",.T.,.T.)

If !QRYSZR->(Eof()) 
	nQtdSZR := QRYSZR->QTD
EndIf
QRYSZR->(dbCloseArea())


cSQL := " SELECT "
cSQL += "	COUNT(ZR_NUMERO) QTD " 
cSQL += "	FROM "
cSQL += 		RetSQLName("SZR")
cSQL += "		WHERE "
cSQL += "			ZR_FILIAL = '"+xFilial("SZR")+"' AND "
cSQL += "			ZR_STATUS IN ('AVALIANDO') AND "
cSQL += "			D_E_L_E_T_ = ' ' "

cSQL := ChangeQuery(cSQL)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),"QRYSZR",.T.,.T.)

If !QRYSZR->(Eof()) 
	nQtdAVA := QRYSZR->QTD
EndIf
QRYSZR->(dbCloseArea())

cSQL := " SELECT "
cSQL += " 	COUNT(ZZF_CODIGO) QTD "
cSQL += " 	FROM "
cSQL += 		RetSQLName("ZZF")
cSQL += " 		WHERE "
cSQL += " 			ZZF_FILIAL = '"+xFilial("ZZF")+"' AND "
cSQL += " 			ZZF_ATIVO <> '1' AND "
cSQL += " 			D_E_L_E_T_ = ' ' "

cSQL := ChangeQuery(cSQL)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),"QRYZZF",.T.,.T.)

If !QRYZZF->(Eof()) 
	nQtdZZF := QRYZZF->QTD
EndIf
QRYZZF->(dbCloseArea())           


cSQL := " SELECT "
cSQL += " 	COUNT(C5_NUM) QTD "
cSQL += " 	FROM "
cSQL += 		RetSQLName("SC5")
cSQL += " 		WHERE "
cSQL += " 			C5_FILIAL = '"+xFilial("SC5")+"' AND "
cSQL += " 			C5_XAVARES = 'S' AND "
cSQL += " 			D_E_L_E_T_ = ' ' "

cSQL := ChangeQuery(cSQL)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),"QRYSC5",.T.,.T.)

If !QRYSC5->(Eof()) 
	nQtdSC5 := QRYSC5->QTD
EndIf
QRYSC5->(dbCloseArea())           


cSQL := " SELECT "
cSQL += " 	COUNT(UC_STATUS) QTD "
cSQL += " 	FROM "
cSQL += 		RetSQLName("SUC")
cSQL += " 		WHERE "
cSQL += " 			UC_FILIAL = '"+xFilial("SUC")+"' AND "
cSQL += " 			UC_STATUS = '2' AND "
cSQL += " 			D_E_L_E_T_ = ' ' "

cSQL := ChangeQuery(cSQL)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),"QRYSUC",.T.,.T.)

If !QRYSUC->(Eof()) 
	nQtdSUC := QRYSUC->QTD
EndIf
QRYSUC->(dbCloseArea())           

DEFINE MSDIALOG oDlg TITLE "Central de Aprovações" FROM 001,001 TO 035,100

nLin := 20
nCol := 30

@ 001,002 tO 017.5,047
@ nLin, nCol+120 say "Central de Aprovação Digital"  font oFont30  COLOR CLR_BLACK Pixel

If cEmpAnt <> "04"

	nLin+=40
	@ nLin ,nCol tO 204+nLin ,053+nCol
	@ nLin ,nCol say "PAGAMENTO/VALOR..... ("+StrZero(nQtdSZR,2)+")"  font oFont28  COLOR CLR_GREEN Pixel
	DEFINE SBUTTON FROM nLin+15,nCol type 14 ACTION (u_DipDigMbr(1),lRet:=.T.,oDlg:End()) ENABLE OF oDlg
	      
	nLin+=40
	@ nLin ,nCol tO 204+nLin ,053+nCol
	@ nLin ,nCol say "VALOR NEGOCIADO..... ("+StrZero(nQtdZZF,2)+")"  font oFont28  COLOR CLR_RED Pixel
	DEFINE SBUTTON FROM nLin+15,nCol type 14 ACTION (u_DIPA068(.T.),lRet:=.T.,oDlg:End()) ENABLE OF oDlg
	
	nLin+=40
	@ nLin ,nCol tO 204+nLin ,053+nCol
	@ nLin ,nCol say "RESERVA DE PEDIDO... ("+StrZero(nQtdSC5,2)+")"  font oFont28  COLOR CLR_BLUE Pixel
	DEFINE SBUTTON FROM nLin+15,nCol type 14 ACTION (u_DipAprRes(),lRet:=.T.,oDlg:End()) ENABLE OF oDlg
	
	nLin+=40
	@ nLin ,nCol tO 204+nLin ,053+nCol
	@ nLin ,nCol say "S.A.C. ....................... ("+StrZero(nQtdSUC,2)+")"  font oFont28  COLOR CLR_BLUE Pixel
	DEFINE SBUTTON FROM nLin+15,nCol type 14 ACTION (u_Dipa075(),lRet:=.T.,oDlg:End()) ENABLE OF oDlg
	
	nLin+=35
	@ nLin ,nCol tO 204+nLin ,053+nCol
	@ nLin ,nCol say "AVALIAÇÃO. ....................... ("+StrZero(nQtdAVA,2)+")"  font oFont28  COLOR CLR_RED Pixel
	DEFINE SBUTTON FROM nLin+15,nCol type 14 ACTION (u_DipDigMbr(2),lRet:=.T.,oDlg:End()) ENABLE OF oDlg

Else

	nLin+=40
	@ nLin ,nCol tO 204+nLin ,053+nCol
	@ nLin ,nCol say "PAGAMENTO/VALOR..... ("+StrZero(nQtdSZR,2)+")"  font oFont28  COLOR CLR_GREEN Pixel
	DEFINE SBUTTON FROM nLin+15,nCol type 14 ACTION (u_DipDigMbr(1),lRet:=.T.,oDlg:End()) ENABLE OF oDlg
	      
	nLin+=40
	@ nLin ,nCol tO 204+nLin ,053+nCol
	@ nLin ,nCol say "S.A.C. ....................... ("+StrZero(nQtdSUC,2)+")"  font oFont28  COLOR CLR_BLUE Pixel
	DEFINE SBUTTON FROM nLin+15,nCol type 14 ACTION (u_Dipa075(),lRet:=.T.,oDlg:End()) ENABLE OF oDlg

EndIf	

//nLin+=30    
nCol+=310
@ nLin ,nCol tO 204+nLin ,053+nCol
@ nLin ,nCol say "SAIR"  font oFont28  COLOR CLR_BLACK Pixel
DEFINE SBUTTON FROM nLin+15,nCol type 2 ACTION (oDlg:End()) ENABLE OF oDlg

ACTIVATE DIALOG oDlg CENTERED

If lRet
	u_DIPA073()	
EndIf

Return
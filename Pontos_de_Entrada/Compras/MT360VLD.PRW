/*-----------------------------------------------------------------------------------
 + REGINALDO BORGES 09/06/2015                                                      +
 + Função........: MT360VLD()                                                       +
 + Objetivo......: Nao permitir a inclusao de cond de pagamento pelos usuarios de   +
 +   			   compras onde E4_TP seja diferente de 'C'.                        +
 + Consideraçoes.: Ponto de Entrada.                                                +
 -----------------------------------------------------------------------------------*/

#INCLUDE "PROTHEUS.CH" 

User Function MT360VLD()

Local lRet      := .T.
Local _cTP      := M->E4_TP
Local _cUsuario := u_DipUsr() 
Local _cCodUser := cUseID(__cUserID)
Local _UserCP   := Upper(AllTrim(GetNewPar("ES_MT360CP","RBORGES/MCANUTO/DDOMINGOS")))
                                          
If _cTP <> "C" .And._cCodUser <> ""
	If ! AllTrim(Upper(_cUsuario)) $ _UserCP  
		lRet := .F.
		MsgInfo("Você não tem autorização para usar o campo Compra/Venda diferente de 'C'!","ES_MT360CP")
	EndIf	
EndIf

Return (lRet)                      

Static Function cUseID(cCodUser) 

Local cQRY      := ""
Local _cCodUser := ""

cQRY := "SELECT SY1.Y1_USER FROM "+RetSqlName('SY1')+" SY1 "
cQRY += " WHERE SY1.Y1_USER = "+cCodUser+"  "
cQRY += " AND SY1.D_E_L_E_T_ = ''       "

cQRY := ChangeQuery(cQRY)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQRY),"TRB",.T.,.F.)

DbSelectArea("TRB")

 _cCodUser := TRB->Y1_USER

TRB->(DbCloseArea())

Return (_cCodUser)
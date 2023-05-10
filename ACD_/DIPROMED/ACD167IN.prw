#INCLUDE "ACDV167.CH" 
#INCLUDE "PROTHEUS.CH"
#INCLUDE "APVT100.CH"

User Function ACD167IN()

Local lPausa := CB7->CB7_STATPA == "1"

If CB7->CB7_STATUS = "3" .And. !lPausa
	
	//VTAlert("INICIOU EMBALAGEM","Aviso",.T.,2000)
	U_DiprKardex(CB7->CB7_PEDIDO,U_DipUsr(),"INICIO EMBALAGEM",.T.,"67")

EndIf			
	
Return
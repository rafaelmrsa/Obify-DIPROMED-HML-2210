#INCLUDE "ACDV167.CH" 
#INCLUDE "PROTHEUS.CH"
#INCLUDE "APVT100.CH"

User Function ACD167FI()

Local lPausa := CB7->CB7_STATPA == "1"

If CB7->CB7_STATUS = "4" .And. lPausa

	//VTAlert("FINALIZOU EMBALAGEM","Aviso",.T.,2000)
	U_DiprKardex(CB7->CB7_PEDIDO,U_DipUsr(),"FINALIZOU EMBALAGEM",.T.,"68")

EndIf	
	
Return
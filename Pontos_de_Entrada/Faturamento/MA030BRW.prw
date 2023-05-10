#include "RwMake.ch"
#include "Protheus.ch"
#include "vKey.ch"     

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MA030BRW  ºAutor  ³Microsiga           º Data ³  01/31/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Faz Chamada do Kardex do Registro selecionado no SA1       º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ ESPECIFICO DIPROMED                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function MA030BRW()                            
                           
Local cCodUsr    := alltrim(RetCodUsr())
Local cUser      := GetMv("ES_VENDUSE",,"000053" ) 
If Type("cDipVend") == "U" 
	Public cDipVend := alltrim(Posicione("SU7",4,xFilial("SU7") + RetCodUsr(),"U7_CGC"))
EndIf


   /*
// Filtra pedido por operador  MCVN - 22/04/09                              
DbSelectArea("SU7")
SU7->(DbSetOrder(4))
SU7->(DbGoTop())
If (SU7->(dbSeek(xFilial("SU7")+cCodUsr)))
   	cDipVend    := ALLTRIM(SU7->U7_CGC)
Endif  
*/     //Giovani Zago 08/03/2012                                       
SY1->(DbCloseArea())        

If cDipVend $ cUser 
	SA1->(dbSetFilter({|| SA1->A1_VEND == cDipVend},"SA1->A1_VEND == cDipVend"))
EndIf

U_DIPPROC(ProcName(0),U_DipUsr()) // MCVN - 22/01/2009
SetKey(VK_F10,{|| U_DIPA036("SA1")})  

Return ""
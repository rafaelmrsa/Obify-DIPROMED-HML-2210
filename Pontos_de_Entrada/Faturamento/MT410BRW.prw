/*                                                    São Paulo, 01 Jun 2006
----------------------------------------------------------------------------
Empresa....: Dipromed Comercio e Importação Ltda

Execução...: Antes chamada da Função de Browse

Objetivo...: Possibilitar a execução de algum procedimento
             antes da abertura da tela principal

Retorno....: Nenhum retorno é esperado

Autor......: Jailton B Santos (JBS)
Data.......: 01 Jun 2006      

----------------------------------------------------------------------------
*/

#Include "RwMake.Ch"   
#include "vKey.ch"
#Include "FwBrowse.ch"
*-------------------------------*
User Function MT410BRW()
*-------------------------------*

//Local cCodUsr    := RetCodUsr()// MCVN - 16/04/09
//Local cUser      := "000204"   // MCVN - 27/04/09
//Local cVend      := ""         // MCVN - 27/04/09
Local cCodUsr    := alltrim(RetCodUsr())
Local cUser      := GetMv("ES_VENDUSE",,"000053" ) 
//Local cVend      := ""
If Type("cDipVend") == "U" // MCVN - 30/11/09
	Public cDipVend := alltrim(Posicione("SU7",4,xFilial("SU7") + RetCodUsr(),"U7_CGC"))
EndIf
If type("lDipVpa") == "U"
	Public lDipVpa  := .f. // Array que controla se o TmkVpa foi executado
EndIf
If type("aDipSenhas") == "U"
	Public aDipSenhas := {} // Array que controla as senhas.
EndIf
If type("aDipTipo9") == "U"
	Public aDipTipo9 := {} // Array que controla as senhas.
EndIf     

    /*
// Filtra pedido por operador  MCVN - 16/04/09                              
DbSelectArea("SU7")
SU7->(DbSetOrder(4))
SU7->(DbGoTop())
If (SU7->(dbSeek(xFilial("SU7")+cCodUsr)))
	cVend  := ALLTRIM(SU7->U7_CGC) 
Endif    
*/       //Giovani Zago 08/03/2012                                   
SY1->(DbCloseArea())                        

If cDipVend $ cUser 
	SC5->(dbSetFilter({|| SC5->C5_VEND1 == cDipVend},"SC5->C5_VEND1 == cDipVend "))
EndIf

U_DIPPROC(ProcName(0),U_DipUsr()) // MCVN - 22/01/2009
                            
Set Key VK_F5   TO U_DIPA084b() //descontinuado rotina para não ser chamada ao acessar o F5 no codigo do produto. 27/08/20 Blandino
Set Key VK_F7   TO U_SC5FIL()
Set Key VK_F8   TO U_SC5CLEARFil() 

If cEmpAnt == '01'
	Set Key VK_F6 TO U_DIPA053C()
Endif

If cEmpAnt == '01'
	Set Key VK_F11 TO U_DipHisPer()
Endif

MsgBox("Utilize a Tecla F7 para filtrar por CLIENTE."+Chr(13)+Chr(13)+"Utilize a Tecla F8 para limpar FILTRO."+Chr(13)+Chr(13)+"Utilize a Tecla F6 para incluir Solicitação de Transferência entre CD's.","Informacao.","INFO")
                                                                            
//SC5->(dbSetFilter({|| .t.},".t."))

Return(.t.)       


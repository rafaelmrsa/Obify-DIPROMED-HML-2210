/*                                                    São Paulo, 31 Jul 2006
----------------------------------------------------------------------------
Empresa....: Dipromed Comercio e Importação Ltda

Execução...: Apos o preenchimento da cidade de entrega na tela do TMPVPA,
             na validação do campo.

Objetivo...: Salvar o endereço de entrega na array para ser usado no calculo 
             do frete.
             Limpa a Transportadora
             Refaz o destino de frete, se a cidade de entrega for diferente 
             da cidade informada no SA1
              
Retorno....: Array com os Endereços de entrega

Autor......: Jailton B Santos (JBS)
Data.......: 31 Jul 2006      

----------------------------------------------------------------------------
*/

#Include "RwMake.Ch"
*-------------------------------*
User Function TMKCIDE(aCidEnt)
*-------------------------------*
Local aRetorno := Aclone(aCidEnt)
If AllTrim(aCidEnt[1]) <> SA1->A1_MUNE .and. AllTrim(aCidEnt[1]) <> SA1->A1_MUN
	If type("aDipEndEnt") == "U"
		Public aDipEndEnt := Aclone(aCidEnt)
	Else
		aDipEndEnt := Aclone(aCidEnt)
  	EndIf                       
    M->UA_TRANSP:=space(06)
    M->UA_DESTFRE:=space(20) 
    M->UA_DESTFRE:=U_Mt410Frete('UA_DESTFRE')
ElseIf type("aDipEndEnt") == "U"
    Public aDipEndEnt:={}
Else	
    aDipEndEnt:={}	
EndIf   
U_DIPPROC(ProcName(0),U_DipUsr()) // MCVN - 22/01/2009
Return(aCidEnt[1])
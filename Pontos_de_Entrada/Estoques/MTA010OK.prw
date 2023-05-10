#Include "Protheus.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MTA010OK  ºAutor  ³Microsiga           º Data ³  04/20/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ PE antes da exclusão. Grava as informações do produto para º±±
±±º          ³ replicação para outras empresas/filiais                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function MTA010OK()
Local lRet := .T.

/*
//-- Copia de PA para Health/Cd e Dipromed
If (Type("l010Auto")=="U" .Or. !l010Auto)// .And. cEmpAnt+cFilAnt == "0401" 

	U_ClrMemSB1() //-- Zera Array com variaveis de memória

	If !Inclui .And. !Altera .And. AllTrim(SB1->B1_TIPO) == "PA" 

		RegToMemory("SB1",.F.) //-- Carrega registro para as variáveis de memória.
		U_SvMemSB1() //-- Guarda Array com variáveis de Memoria para uso posterior na gravacao
		
    EndIf
    
EndIf   
*/                               

If !U_DipUsr()$"mcanuto/DDOMINGOS/VQUEIROZ/VEGON/RBORGES" 
	lRet := .F.
EndIf

If cEmpAnt=='04' .And. U_DipUsr()=="csossolote"
	lRet := .T.
EndIf
                                                
If !lRet
	MsgAlert("Exclusão desabilitada!","Atenção")
EndIf

//Return .T.
Return lRet
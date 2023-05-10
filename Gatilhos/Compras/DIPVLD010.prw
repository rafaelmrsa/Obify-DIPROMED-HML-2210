#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ DIPVLD010      ºAutor  ³Rafael Rosa    º Data ³  15/12/22  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Valida Lote existente com saldo na SB8.					  º±±
±±º          ³ Utilizado no gatilho do campo D1_LOTECTL.		          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Especifico DIPROMED                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

//Rafael Moraes Rosa - 28/12/2022
//Variavel _cTES retirada dos parametros da funcao pois a pre-nota fiscal (MATA140) nao utiliza a variavel TES
//Gatilho 
//User Function DIPVLD010(_cTES,_cCod,_cLocal,_cLote,dVldlot)
User Function DIPVLD010(_cCod,_cLocal,_cLote,dVldlot)

Local _xAlias	:= GetArea()

IF !Empty(_cLote)
	//Rafael Moraes Rosa - 28/12/2022
	//Funcao abaixo retirada pois a pre-nota fiscal (MATA140) nao utiliza a variavel TES
	//IF Posicione("SF4",1,xFilial("SF4")+_cTES,"F4_DUPLIC") = "S"
		DbSelectArea("SB8")
		SB8->(DbSetOrder(3))
		IF SB8->(dbSeek(xFilial("SB8") + _cCod + _cLocal + _cLote))
			IF SB8->B8_SALDO > 0 .AND. dVldlot <> SB8->B8_DTVALID
				FWAlertError("Lote identificado no estoque com saldo disponivel. Realize a manutencao do estoque ou defina um novo lote na escrituracao da NF.", "Lote Existente.")	
				_cLote	:= ""
			ENDIF
		ENDIF
		SB8->(dbSkip())	

	//ENDIF
ENDIF

RestArea(_xAlias)
Return(_cLote) 

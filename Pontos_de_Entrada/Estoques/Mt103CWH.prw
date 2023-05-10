#INCLUDE "Protheus.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MT103CWH  ºAutor  ³Microsiga           º Data ³ 06/Abr/2010 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³PE para tratamento do When dos campos do cabecalho do Doc.  º±±
±±º          ³de Entrada                                                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Dipromed                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function Mt103CWH()
Local _lRet 	:= .T.
Local _cCampo	:= PARAMIXB[1]
Local _cConteudo:= PARAMIXB[2]
Local _lClassif := PARAMIXB[3]

Static _lStaticRet 

If !_lClassif //-- Inclusao de Doc. Entrada

	//-- Quando é alterado F1_FORMUL para "S", preenche SPED no Especie e salva variavel estatica p/ desabilitar o campo Especie
	If AllTrim(Upper(_cCampo)) == "F1_FORMUL" .And. Left(_cConteudo,1) == "S" .And. Type("cEspecie") == "C" 
	
		cEspecie	:= Padr("SPED",Len(cEspecie))
		_lStaticRet	:= .F. 
	
	//-- Quando é alterado F1_FORMUL para "N" e o campo Especie esta com SPED, limpa o campo Especie, e salva var estatica para habilitar o campo Especie
	ElseIf AllTrim(Upper(_cCampo)) == "F1_FORMUL" .And. Left(_cConteudo,1) != "S" .And. Type("cEspecie") == "C" 
	
		_lStaticRet	:= .T.
	
	EndIf

Else  //-- Classificação

	//-- Na Classificação, bloqueia a Especie caso seja formulario proprio
	_lStaticRet := SF1->F1_FORMUL != "S"
		
EndIf

/* Desativado em 25/05/2021 - Necessário preencher a espécie como SPED para notas de entrada com formulario próprio não.
//-- Quando é alterado F1_FORMUL para "N", preenche e o campo Especie esta com SPED, limpa o campo especie
If AllTrim(Upper(_cCampo)) == "F1_ESPECIE" .And. ValType(_lStaticRet) == "L" 

	_lRet := _lStaticRet

	//--  Não permite alterar a especie para "SPED", quando não é formulario proprio
	If _lRet .And. Type("cEspecie") == "C" .And. _cConteudo == Padr("SPED",Len(cEspecie))
	
		cEspecie := Padr(" ",Len(cEspecie))
	
	EndIf
	
EndIf
*/
Return _lRet

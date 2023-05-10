#INCLUDE "Protheus.ch"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �MT103CWH  �Autor  �Microsiga           � Data � 06/Abr/2010 ���
�������������������������������������������������������������������������͹��
���Desc.     �PE para tratamento do When dos campos do cabecalho do Doc.  ���
���          �de Entrada                                                  ���
�������������������������������������������������������������������������͹��
���Uso       �Dipromed                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function Mt103CWH()
Local _lRet 	:= .T.
Local _cCampo	:= PARAMIXB[1]
Local _cConteudo:= PARAMIXB[2]
Local _lClassif := PARAMIXB[3]

Static _lStaticRet 

If !_lClassif //-- Inclusao de Doc. Entrada

	//-- Quando � alterado F1_FORMUL para "S", preenche SPED no Especie e salva variavel estatica p/ desabilitar o campo Especie
	If AllTrim(Upper(_cCampo)) == "F1_FORMUL" .And. Left(_cConteudo,1) == "S" .And. Type("cEspecie") == "C" 
	
		cEspecie	:= Padr("SPED",Len(cEspecie))
		_lStaticRet	:= .F. 
	
	//-- Quando � alterado F1_FORMUL para "N" e o campo Especie esta com SPED, limpa o campo Especie, e salva var estatica para habilitar o campo Especie
	ElseIf AllTrim(Upper(_cCampo)) == "F1_FORMUL" .And. Left(_cConteudo,1) != "S" .And. Type("cEspecie") == "C" 
	
		_lStaticRet	:= .T.
	
	EndIf

Else  //-- Classifica��o

	//-- Na Classifica��o, bloqueia a Especie caso seja formulario proprio
	_lStaticRet := SF1->F1_FORMUL != "S"
		
EndIf

/* Desativado em 25/05/2021 - Necess�rio preencher a esp�cie como SPED para notas de entrada com formulario pr�prio n�o.
//-- Quando � alterado F1_FORMUL para "N", preenche e o campo Especie esta com SPED, limpa o campo especie
If AllTrim(Upper(_cCampo)) == "F1_ESPECIE" .And. ValType(_lStaticRet) == "L" 

	_lRet := _lStaticRet

	//--  N�o permite alterar a especie para "SPED", quando n�o � formulario proprio
	If _lRet .And. Type("cEspecie") == "C" .And. _cConteudo == Padr("SPED",Len(cEspecie))
	
		cEspecie := Padr(" ",Len(cEspecie))
	
	EndIf
	
EndIf
*/
Return _lRet

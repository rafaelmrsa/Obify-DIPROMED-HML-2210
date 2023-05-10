#include "rwmake.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ F460VER º Autor ³   Eriberto Elias   º Data ³  01/03/2002   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Imprimir verso dos cheques                                   º±±
±±º          ³                                                              º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

//User Function DP10VERS() -- alterado o ponto de Entrada (nome) devido a migração - Fernando Garrigos.
User Function F460VER()

U_DIPPROC(ProcName(0),U_DipUsr()) // JBS 05/10/2005 - Gravando o nome do Programa no SZU

_area := GETAREA()

// 29/11/2005 - _cAux := 'Destinado a: '

_cAux := 'Exclusivamente para fins de liquidacao das obrigacoes relacionadas:' //INICIO DE USO - 01/12/2005

DbSelectArea('SEF')
_areaEF := GETAREA()
_cCHAVE := SEF->EF_NUM+SEF->EF_BANCO+SEF->EF_AGENCIA+SEF->EF_CONTA
dBSETORDER(4)
DbGotop()

dBSEEK(XFILIAL("SEF")+_cCHAVE)

DO WHILE !EOF() .AND. xFILIAL("SEF") == SEF->EF_FILIAL.AND.;
	SEF->(EF_NUM+EF_BANCO+EF_AGENCIA+EF_CONTA) == _cCHAVE
	IF !(ALLTRIM(SEF->EF_HIST) $ _cAux) .AND. SEF->EF_TIPO<>'   ' //SEF->EF_IMPRESS == 'A'
		_cAUX := _cAux +ALLTRIM(SEF->EF_HIST)+ ' -/- '
	EndIf
	DbSkip()
EndDo

RESTAREA(_areaEF)

_cAux1 := _cAux
_eeate := INT(LEN(_cAUX) / 85) + 1
_eeaux := 0
_cAux  := ''
For EE = 1 to _eeate
	_cAux := _cAux +'      '+ SUBS(_cAux1,1+_eeaux,85) + CHR(13)+CHR(10)
	_eeaux += 85
Next

_cArquivo := GetMv("MV_DIRAGEN") + "versoch.TXT" //"\ap6\ap6_data\sigaadv\versoch.TXT"
_cTexto   := "      Banco.: " +SEF->EF_BANCO+ "  Cheque No.: " +ALLTRIM(SEF->EF_NUM)+ CHR(13)+CHR(10)+ CHR(13)+CHR(10)
_cTexto   := _cTexto + _cAUX

MemoWrit(_cArquivo,_cTexto)

RESTAREA(_area)

Return("*"+_cArquivo)

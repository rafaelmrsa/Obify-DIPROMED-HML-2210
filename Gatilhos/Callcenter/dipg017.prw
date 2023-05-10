/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³ DIPG017  º Autor ³ Eriberto Elias     º Data ³  18/04/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Valida fornecedor e vendedor KC                            º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
Alterações: Eriberto - 01/08/2006 - Acrescentei os codigos dos clientes 008038
            Oscar Skin e 011944 Maxmed Sul para zerar comissão, pois eles vendem
            para eles mesmos. E outros segundo a Patricia.
                              002566/005803/007773/008625/009657/009896/011097

*/

#Include "RwMake.ch"

User Function DIPG017(_VENDKC,_CLIENTE,_COMIS)
Local _xAlias := GetArea()
Local _lRet   := .F.
//U_DIPPROC(ProcName(0),U_DipUsr()) // JBS 05/10/2005 - Gravando o nome do Programa no SZU



/*If !EMPTY(_VENDKC) .AND. SB1->B1_PROC $ '000366/000446' .AND. !(_CLIENTE $ '008038/011944')
	_lRet := .t.
// Neste caso zera a comissao para todos os fornecedores                                           
// DESABILITADO TOTALMENTE 13/08/09 - MCVN
ElseIf _COMIS = 1 .AND. _CLIENTE $ '008038/011944/002566/005803/007773/008625/009657/009896/011097'
                                   // Oscar Skin e MaxMed Sul E outros segundo a Patricia
	_lRet := .t.
EndIf*/
  

RestArea(_xAlias)
Return(_lRet)

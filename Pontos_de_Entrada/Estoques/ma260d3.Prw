/*
PONTO.......: MA260D3           PROGRAMA....: MATA260
DESCRIÇÄO...: APOS GRAVACAO DOS REGISTROS DE INCLUSAO
UTILIZAÇÄO..: Apos gravacao dos registros de movimento na inclusao de
              uma transferencia.
              Pode ser utilizado para atualizar algum arquivo ou campo.

PARAMETROS..: UPAR do tipo X :

RETORNO.....: URET do tipo X :

OBSERVAÇÖES.: <NENHUM>
*/
User Function ma260d3()
Local _cAlias    := GetArea()
Local _cAliasSD3 := SD3->(GetArea())
Local _cD3_EXPLIC := U_MT260TOK(.F.)

U_DIPPROC(ProcName(0),U_DipUsr()) // JBS 05/10/2005 - Gravando o nome do Programa no SZU
Dbselectarea("SD3")
DbSetOrder(2)
SD3->(DbSeek(xFilial("SD3")+PADR(M->cDOCTO,9),.T.))
While SD3->D3_DOC == PADR(M->cDOCTO,9)
	Begin Transaction
	Reclock("SD3",.F.)
	SD3->D3_EXPLIC := _cD3_EXPLIC
	SD3->(MsUnlock())
	SD3->(DbSkip())
	End Transaction
End
RestArea(_cAliasSD3)
RestArea(_cAlias)
Return(.T.)
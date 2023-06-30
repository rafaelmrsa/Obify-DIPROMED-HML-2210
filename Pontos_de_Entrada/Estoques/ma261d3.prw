/*
PONTO.......: MA261D3           P Type("ROGRAMA....: MATA261
DESCRIÇÄO...: EXECUTA APOS A GRAVACAO DO SD3
UTILIZAÇÄO..: E chamado na gravacao de cada transferencia no SD3.
              Pode ser utilizado para atualizar campos ou arquivos no momento da
              gravacao.

Obs.:Foi alterado em 15/08/2001 para ser disparado antes de gerar o
arquivo da contabilidade ( Mov. de Destimo)

PARAMETROS..: UPAR do tipo X : E passado como parametro o numero da
linha do browse que esta sendo processada. Serve para leitura de dados
do aCols corretamente.     

RETORNO.....: URET do tipo X :

OBSERVAÇÖES.: 
*/
User Function ma261d3()
Local _cAlias    := GetArea()
Local _cAliasSD3 := SD3->(GetArea())
U_DIPPROC(ProcName(0),U_DipUsr()) // JBS 05/10/2005 - Gravando o nome do Programa no SZU
Dbselectarea("SD3")
DbSetOrder(2)
SD3->(DbSeek(xFilial("SD3")+PADR(M->cDOCUMENTO,9),.T.))
While SD3->D3_DOC == PADR(M->cDOCUMENTO,9)
	Begin Transaction
	Reclock("SD3",.F.)
	SD3->D3_EXPLIC := aCols[1,aScan(aHeader, { |x| Alltrim(x[2]) == "D3_EXPLIC" })]
	If (Type("lAutoma261")!="U" .And. lAutoma261)
		SD3->D3_NUMSEP := aCols[1,aScan(aHeader, { |x| Alltrim(x[2]) == "D3_NUMSEP" })]
	EndIf
	SD3->(MsUnlock())
	SD3->(DbSkip())
	End Transaction
End
RestArea(_cAliasSD3)
RestArea(_cAlias)
Return(.T.)

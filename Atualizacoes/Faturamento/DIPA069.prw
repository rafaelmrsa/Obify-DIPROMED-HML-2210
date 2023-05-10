/*
+==========================================================================+
| Programa: DIPA069()   |   Autor: Reginaldo Borges      |  Data: 08/12/14 |
+==========================================================================+
|Descrição: Incluir NCM´s na regra de  desoneração.                        |
+==========================================================================+
|Uso: Especifico do faturamento Health Quality.							   |
+==========================================================================+
|              ATUALIZAÇÕES SOFRIDAS DESDE A CONSTRUÇÃO INICIAL.           |
+--------------------------------------------------------------------------+
|Programador |  Data  |               Motivo da Alteracao                  |
+--------------------------------------------------------------------------+
|            |        |                                                    |
|            |        |                                                    |
+==========================================================================+
*/

#INCLUDE "PROTHEUS.CH"

User Function DIPA069()
 
Local cAlias  := "ZZE"
Local cTitulo := "Cadastro de NCM Desonerada"
 
AxCadastro(cAlias, cTitulo)
 
Return 

User Function xValNcm(cNcm)

Local aArea := GetArea()
Local nRec := ZZE->(Recno())

If ZZE->(dbSetOrder(1), dbSeek(xFilial("ZZE")+cNcm))
	MsgAlert("Atenção, NCM já Cadastrado!","Atenção!")
	RestArea(aArea)
	ZZE->(dbGoTo(nRec))
	Return .F.
Endif
RestArea(aArea)
ZZE->(dbGoTo(nRec))

Return .T.
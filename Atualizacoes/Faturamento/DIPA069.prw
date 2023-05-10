/*
+==========================================================================+
| Programa: DIPA069()   |   Autor: Reginaldo Borges      |  Data: 08/12/14 |
+==========================================================================+
|Descri��o: Incluir NCM�s na regra de  desonera��o.                        |
+==========================================================================+
|Uso: Especifico do faturamento Health Quality.							   |
+==========================================================================+
|              ATUALIZA��ES SOFRIDAS DESDE A CONSTRU��O INICIAL.           |
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
	MsgAlert("Aten��o, NCM j� Cadastrado!","Aten��o!")
	RestArea(aArea)
	ZZE->(dbGoTo(nRec))
	Return .F.
Endif
RestArea(aArea)
ZZE->(dbGoTo(nRec))

Return .T.
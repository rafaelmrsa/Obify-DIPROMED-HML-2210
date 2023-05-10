/*
+==========================================================================+
| Programa: DIPA070()   |   Autor: Reginaldo Borges      |  Data: 08/12/14 |
+==========================================================================+
|Descri��o: Incluir NCM�s Oneradas.                                        |
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

User Function DIPA070()
 
Local cAlias  := "ZZH"
Local cTitulo := "Cadastro de NCM Onerada"
 
AxCadastro(cAlias, cTitulo)
 
Return 

User Function xValNcmO(cNcm)

Local aArea := GetArea()
Local nRec := ZZH->(Recno())

If ZZH->(dbSetOrder(1), dbSeek(xFilial("ZZH")+cNcm))
	MsgAlert("Aten��o, NCM j� Cadastrado!","Aten��o!")
	RestArea(aArea)
	ZZH->(dbGoTo(nRec))
	Return .F.
Endif
RestArea(aArea)
ZZH->(dbGoTo(nRec))

Return .T.
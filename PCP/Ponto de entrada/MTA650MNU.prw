#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"

/*/
{Protheus.doc} MTA650MNU
Ponto de entrada para adicionar botão na rotina das Ordens de Produção.
@type  Function
@author Reginaldo Borges
@since 17/02/2017
@version 1.0
/*/

User Function MTA650MNU()

AAdd(aRotina, {"Gerar Lote", "U_GeLoteC2()", 0, 4})
AAdd(aRotina, {"Imp. Etq. PI", "U_DIPETPI()", 0, 1})
AAdd(aRotina, {"Imp. Etq. PA", "U_DIPETPA()", 0, 1})

Return



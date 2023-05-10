/*====================================================================================\
|Programa  | MA030MEM.PRW  | Autor | Jailton B Santos, JBS   | Data | 09 Ago 2005     |
|=====================================================================================|
|Descrição | Ponto de entrada para o MATA030.                                         |
|          |                                                                          |
|=====================================================================================|
|Objetivo  | Informar os Campos memos de usuarios.                                    |
|          |                                                                          |
|=====================================================================================|
|Sintaxe   | MA030MEM()                                                               |
|=====================================================================================|
|Uso       | Especifico DIPROMED                                                      |
|=====================================================================================|
|Histórico | 09 Ago 2005 -                                                            |
\====================================================================================*/
#INCLUDE "RWMAKE.CH"
User function MA030MEM()                            

U_DIPPROC(ProcName(0),U_DipUsr()) // MCVN - 22/01/2009

If U_DipWhen()
   aMemos := {{"A1_OBSFINM","A1_OBSFINV"},{"A1_INFOCLM","A1_INFOCLV"},{"A1_MSTATUS","A1_VSTATUS"}}  
Else
   aMemos := {{"A1_INFOCLM","A1_INFOCLV"},{"A1_MSTATUS","A1_VSTATUS"}}  
EndIf
Return({})
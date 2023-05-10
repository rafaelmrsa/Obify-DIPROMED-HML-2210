#INCLUDE "RWMAKE.CH"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Fun��o    �INITSCHED � Autor � NATALINO OLIVEIRA  � Data �  25/01/02   ���
�������������������������������������������������������������������������͹��
���Descri��o � Funcao chamada pelo Workflow.                              ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Exclusivo Dipromed                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

User Function Sched01()     

Local aParams := {"01","01"} //Aqui passa o codigo da Empresa e Filial utilizadas
//U_DIPPROC(ProcName(0),U_DipUsr()) // JBS 05/10/2005 - Gravando o nome do Programa no SZU
ConOut("--- Inicializando Scheduler Dipromed --- ")
WFSCheduler(aParams)          //Aqui inicia a funcao de Agendamento
ConOut("--- Finalizando   Scheduler Dipromed --- ")

Return .T.

User Function Sched04()     

Local aParams := {"04","01"} //Aqui passa o codigo da Empresa e Filial utilizadas
//U_DIPPROC(ProcName(0),U_DipUsr()) // JBS 05/10/2005 - Gravando o nome do Programa no SZU
ConOut("--- Inicializando Scheduler HQ --- ")
WFSCheduler(aParams)          //Aqui inicia a funcao de Agendamento
ConOut("--- Finalizando   Scheduler HQ --- ")  

User Function Sched04CD()     

Local aParams := {"04","04"} //Aqui passa o codigo da Empresa e Filial utilizadas
//U_DIPPROC(ProcName(0),U_DipUsr()) // JBS 05/10/2005 - Gravando o nome do Programa no SZU
ConOut("--- Inicializando Scheduler HQ-CD ")
//WFSCheduler(aParams)          //Aqui inicia a funcao de Agendamento
ConOut("--- Finalizando   Scheduler HQ-CD ")

Return .T.

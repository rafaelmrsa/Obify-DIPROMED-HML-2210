/*====================================================================================\
|Programa  | DIPA052       | Autor | Maximo Canuto              | Data | 20/07/2010   |
|=====================================================================================|
|Descrição | Utilizado para evitar a geração simultânea de nota fiscal na HQ          |
|          |                                                                          |
|=====================================================================================|
|Sintaxe   | DIPA074                                                                  |
|=====================================================================================|
|Uso       | Especifico DIPROMED                                                      |
|=====================================================================================|
|........................................Histórico....................................|
|Analista  | DD/MM/AA - Descrição                                                     |
|Analista  | DD/MM/AA - Descrição                                                     |
\====================================================================================*/

#include "RwMake.ch"

User Function DIPA074()

Local cChave   := "GERANDO_NF..."

U_DIPPROC(ProcName(0),U_DipUsr())
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria a Trava com o Nome 'GERANDO_NF...'.Se algum usuario estiver TRANSFERINSO³
//³ a rotina de nao podera ser executada               					    	 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//-- Parametros da Funcao LockByName() :
//   1o - Nome da Trava
//   2o - usa informacoes da Empresa na chave
//   3o - usa informacoes da Filial na chave 

If cEmpAnt == '04'
	cChave := "TRANSFERINDO..."
	If LockByName(cChave,.T.,.F.)	
		SetFunName("MATA460A")
		MATA460A()
		UnLockByName(cChave,.T.,.F.) // Libera Lock
	Else  
		Aviso('Atenção',"A rotina de Geração de Nota Fiscal está sendo executada no momento. Tente novamente mais tarde!",{'Ok'}) 
	Endif         
Else                          
	SetFunName("MATA460A")
	MATA460A()
Endif

Return 
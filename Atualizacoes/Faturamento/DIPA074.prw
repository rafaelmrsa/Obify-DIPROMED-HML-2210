/*====================================================================================\
|Programa  | DIPA052       | Autor | Maximo Canuto              | Data | 20/07/2010   |
|=====================================================================================|
|Descri��o | Utilizado para evitar a gera��o simult�nea de nota fiscal na HQ          |
|          |                                                                          |
|=====================================================================================|
|Sintaxe   | DIPA074                                                                  |
|=====================================================================================|
|Uso       | Especifico DIPROMED                                                      |
|=====================================================================================|
|........................................Hist�rico....................................|
|Analista  | DD/MM/AA - Descri��o                                                     |
|Analista  | DD/MM/AA - Descri��o                                                     |
\====================================================================================*/

#include "RwMake.ch"

User Function DIPA074()

Local cChave   := "GERANDO_NF..."

U_DIPPROC(ProcName(0),U_DipUsr())
//������������������������������������������������������������������������������Ŀ
//� Cria a Trava com o Nome 'GERANDO_NF...'.Se algum usuario estiver TRANSFERINSO�
//� a rotina de nao podera ser executada               					    	 �
//��������������������������������������������������������������������������������
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
		Aviso('Aten��o',"A rotina de Gera��o de Nota Fiscal est� sendo executada no momento. Tente novamente mais tarde!",{'Ok'}) 
	Endif         
Else                          
	SetFunName("MATA460A")
	MATA460A()
Endif

Return 
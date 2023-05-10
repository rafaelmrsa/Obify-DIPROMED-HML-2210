#INCLUDE "Protheus.ch"   
#INCLUDE "TbiConn.ch"
#INCLUDE "TbiCode.ch"

/*====================================================================================\
|Programa  | EXPCTEMDFE     | Autor | Rafael Rosa               | Data | 25/08/2022   |
|=====================================================================================|
|Descrição | Processamento do Job                                                     |
|          | Chamada das funcoes DIPJBEXPMDF e DIPJBEXPCTE                            |
|          |                                                                          |
|=====================================================================================|
|Sintaxe   | EXPCTEMDFE                                                              |
|=====================================================================================|
|Uso       | Especifico DIPROMED                                                      |
|=====================================================================================|
|........................................Histórico....................................|
|Dev       | DD/MM/AA - Descrição                                                     |
|Rafael    | 25/08/2022 - Fonte elaborado (Em fase de testes)                         |
|Rafael    | 01/09/2022 - Reajustada funcoes de preparacao do ambiente.               |
\====================================================================================*/
                                                                  
User Function EXPCTEMDFE(aParam)

DEFAULT aParam :={"03","01"}
       
    RpcSetType(3)
    RpcSetEnv(aParam[1],aParam[2],,,"OMS")
	
		//Exportacao MDFe
		U_JBEXPMDF()

		//Exportacao CTe
		U_JBEXPCTE()
	
	RpcClearEnv()

Return

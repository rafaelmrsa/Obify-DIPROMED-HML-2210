/*====================================================================================\
|Programa  | DIPA052       | Autor | Maximo Canuto              | Data | 20/07/2010   |
|=====================================================================================|
|Descrição | Utilizado para controlar acesso a Consulta Gen. Relacional - MPVIEW      |
|          |                                                                          |
|=====================================================================================|
|Sintaxe   | DIPA052                                                                  |
|=====================================================================================|
|Uso       | Especifico DIPROMED                                                      |
|=====================================================================================|
|........................................Histórico....................................|
|Rafael    | DD/MM/AA - Descrição                                                     |
|Eriberto  | DD/MM/AA - Descrição                                                     |
\====================================================================================*/

#include "RwMake.ch"

User Function DIPA052()

Local cUserLerda := GetMV("MV_USALERD")
Local cUserGPE   := "EDGLEISON/JOAO LUIZ"

U_DIPPROC(ProcName(0),U_DipUsr()) // JBS 05/10/2005 - Gravando o nome do Programa no SZU

If !(Upper(U_DipUsr()) $ cUserLerda)  .And. !(Upper(U_DipUsr()) $ cUserGPE .And. cModulo == "GPE") // MCVN - 28/05/2009
	Alert(Upper(U_DipUsr())+", você não tem autorização para utilizar esta rotina. Qualquer dúvida falar com Eriberto!","Atenção")	
	Return()
Endif  

MPVIEW() // Função padrão do Microsiga 

Return(.T.) 
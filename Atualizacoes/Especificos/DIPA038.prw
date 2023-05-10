/*====================================================================================\
|Programa  | DIPA038       | Autor | Maximo Canuto              | Data | 28/05/2009   |
|=====================================================================================|
|Descrição | Utilizado para controlar acesso a rotina de Consulta Genérica - LERDA    |
|          |                                                                          |
|=====================================================================================|
|Sintaxe   | DIPA038                                                                  |
|=====================================================================================|
|Uso       | Especifico DIPROMED                                                      |
|=====================================================================================|
|........................................Histórico....................................|
|Rafael    | DD/MM/AA - Descrição                                                     |
|Eriberto  | DD/MM/AA - Descrição                                                     |
\====================================================================================*/

#include "RwMake.ch"

User Function DIPA038()

Local cUserLerda := GetMV("MV_USALERD")
Local cUserGPE   := "EDGLEISON/JOAO LUIZ"

U_DIPPROC(ProcName(0),U_DipUsr()) // JBS 05/10/2005 - Gravando o nome do Programa no SZU

If !(Upper(U_DipUsr()) $ cUserLerda)  .And. !(Upper(U_DipUsr()) $ cUserGPE .And. cModulo == "GPE") // MCVN - 28/05/2009
	Alert(Upper(U_DipUsr())+", você não tem autorização para utilizar esta rotina. Qualquer dúvida falar com Eriberto!","Atenção")	
	Return()
Endif  

LERDA() // Função padrão do Microsiga - Cadastro de Produtos

Return(.T.) 
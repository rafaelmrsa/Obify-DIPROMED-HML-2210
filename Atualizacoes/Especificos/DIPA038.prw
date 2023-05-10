/*====================================================================================\
|Programa  | DIPA038       | Autor | Maximo Canuto              | Data | 28/05/2009   |
|=====================================================================================|
|Descri��o | Utilizado para controlar acesso a rotina de Consulta Gen�rica - LERDA    |
|          |                                                                          |
|=====================================================================================|
|Sintaxe   | DIPA038                                                                  |
|=====================================================================================|
|Uso       | Especifico DIPROMED                                                      |
|=====================================================================================|
|........................................Hist�rico....................................|
|Rafael    | DD/MM/AA - Descri��o                                                     |
|Eriberto  | DD/MM/AA - Descri��o                                                     |
\====================================================================================*/

#include "RwMake.ch"

User Function DIPA038()

Local cUserLerda := GetMV("MV_USALERD")
Local cUserGPE   := "EDGLEISON/JOAO LUIZ"

U_DIPPROC(ProcName(0),U_DipUsr()) // JBS 05/10/2005 - Gravando o nome do Programa no SZU

If !(Upper(U_DipUsr()) $ cUserLerda)  .And. !(Upper(U_DipUsr()) $ cUserGPE .And. cModulo == "GPE") // MCVN - 28/05/2009
	Alert(Upper(U_DipUsr())+", voc� n�o tem autoriza��o para utilizar esta rotina. Qualquer d�vida falar com Eriberto!","Aten��o")	
	Return()
Endif  

LERDA() // Fun��o padr�o do Microsiga - Cadastro de Produtos

Return(.T.) 
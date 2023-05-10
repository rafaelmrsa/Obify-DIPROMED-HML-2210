#include "rwmake.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบPrograma  ณ DIGLOC   บ Autor ณ   Rodrigo Franco   บ Data ณ  25/04/2002 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Atualiza a Localiza็ใo                                     บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function DIGLOC()
U_DIPPROC(ProcName(0),U_DipUsr()) // JBS 05/10/2005 - Gravando o nome do Programa no SZU
_xAlias  := GetArea()

PRIVATE aRotina := {  { "Pesquisa","AxPesqui" , 0 , 1},;       //"Pesquisa" 
					  { "LOCALIZ","U_DIGLOC2()"  , 0 , 2}  }  

//ณ Define o cabecalho da tela de atualizacoes               ณ
cCadastro := "Localizacao Notas Fiscais"
cMarca := GetMark()
MarkBrow("SD2","D2_OK",,,,cMarca)
//MarkBrow("SF2","F2_OK",,,,cMarca,,,'xFilial("SF2")','xFilial("SF2")')

RestArea(_xAlias)

Return
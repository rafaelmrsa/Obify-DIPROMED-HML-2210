#INCLUDE "PROTHEUS.CH"
#include "rwmake.ch"

/*
�����������������������������������������������������������������������������
���Programa  � DIPA012  � Autor �   Rodrigo Franco   � Data �  19/02/02   ���
�������������������������������������������������������������������������͹��
���Desc.     � Atualiza Hora de Saida da empresa da Nota                  ���
�����������������������������������������������������������������������������
*/
User Function DIPA012()
U_DIPPROC(ProcName(0),U_DipUsr()) // JBS 05/10/2005 - Gravando o nome do Programa no SZU
_xAlias  := GetArea()
                      
PRIVATE aRotina := {  { "Pesquisa","AxPesqui"             , 0 , 1},;       //"Pesquisa" 
					  { "Saida N.F.","U_DIPA011"          , 0 , 2},; 
     		          { "Volumes","U_DIPA010"             , 0 , 3},;
     		          { "Sep/Conf N.F.","U_DIPA039"       , 0 , 4},;
     		          { "Limpa Entrega","U_DipM18LimEnt"  , 0 , 5},;
	  		          { "Ocor Entrega" ,"U_DipM18Ocorre"  , 0 , 6},;
       		          { "Acerto de form","U_DIPA029"      , 0 , 7}}
     		  //      { "Finaliza N.F.","U_DIPA039"       , 0 , 8}}  


//� Define o cabecalho da tela de atualizacoes               �
cCadastro := "Saida, Volumes, Separador e Conferente da Notas Fiscais"
cMarca := GetMark()
MarkBrow("SF2","F2_OK2",,,,cMarca)
RestArea(_xAlias)

Return

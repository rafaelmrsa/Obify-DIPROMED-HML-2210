#include "rwmake.ch"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ SAT01A   ³ Autor ³   VIVIANE AP.CAMPOS   ³ Data ³ 16/02/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ TELA DE SAT (SOLICITACAO DE ATENDIMENTO TECNICO)           ³±±
±±³			 ³ Funcao que chama o Browse (Modelo3)                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Depto:    | TI											              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function SAT()
Local _FunLeg := "U_Leg001()"
Local _FunPrn := "U_Mngr001()"
//Local _FunLOk := "AllwaysTrue()"
//Local _FunTOk := "AllwaysTrue()"
Local _FunLOk := "U_ValLin()"
Local _FunTOk := "U_ValAll()"
Local cMain   := "SZM"
Local cDetail := "SZN"
Local cStFiel := "ZM_STATUS=="
Local cCpoMas := "ZM_NRSAT"
Local cCpoDet := "ZN_NRSAT"
Local cCpoKey := "ZN_ITEM"
Local _mArea  := {cMain,cDetail}
Local _mAlias := {}
Local cBlue   := cStFiel + '"AN"'  // Andamento
Local cRed    := cStFiel + '"CO"'  // Concluido
Local cGreen  := cStFiel + '"AB"'  // Aberto
Local cOrange := cStFiel + '"AA"'  // Analise e Aprovacao
Local cPink   := cStFiel + '"AV"'  // Avaliacao do Usuario
Local cBlack  := cStFiel + '"NA"'  // Nao utorizado
Local aColors :=   {{cGreen  ,"ENABLE" },; 	
            	  	{cBlue   ,"BR_AZUL"},; 
					{cOrange ,"BR_LARANJA"},; 
					{cPink   ,"BR_PINK"},; 
					{cBlack  ,"BR_PRETO"},; 
             	  	{cRed    ,"DISABLE"}} 	


Local cOpcoes := IIf(Upper(U_DipUsr()) $ alltrim(getmv("MV_SATTI")),"PVIAENL","PVIL") // JBS 03/02/2010

U_AxSAT3(cMain,cDetail,cCpoMas,cCpoDet,cCpoKey,"SAT - Solicitacao de Atendimento Tecnico",cOpcoes,aColors,,_FunLeg,_FunLOk,_FunTOk,_FunPrn) // JBS 03/02/2010 - Informado a var cOpcoes


//cCpoMas - Campo chave da master
//cCpoDet - Campo de ligacao mestre detalhe
//cCpoKey - Campo que nao pode se repetir no detalhe

Return(.t.)                                           

User Function leg001()

LOCAL cCadastro2 := "Componentes Variaveis"

LOCAL aCores2 := { { 'BR_VERDE'    , "Aberta"     },;
							{ 'BR_LARANJA'  , "Em Analise e Aprovacao"   },;
							{ 'BR_AZUL'     , "Em Andamento"   },;
							{ 'BR_VERMELHO' , "Concluido"    },;
							{ 'BR_PINK'     , "Avaliacao do Usuario"    },;
							{ 'BR_PRETO'    , "Nao Autorizado"    }}

BrwLegenda(cCadastro2,"Legenda do Browse",aCores2)

Return(.t.)

User Function ValLin()
// msgbox("achou a funcao que valida a linha") 
Return(.T.) 

User Function ValAll()
_lret := .t.
for _n := 1 to len(aCols)
	aCols[_n,1]:=strzero(_n,3)
	if empty(aCols[_n,2]) .or. empty(aCols[_n,3])
		_lret := .f.
	endif
next _n
if !_lret
	alert("Existem campos em branco, preencha todos os campos!")
endif
Return(_lret)


User Function mngr001()
msgbox("achou a funcao que imprime ")
Return(.t.)
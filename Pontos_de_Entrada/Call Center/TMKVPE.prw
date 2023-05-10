/*                                                              Sao Paulo,  19 Out 2005
---------------------------------------------------------------------------------------
Empresa.......: DIPOMED Comércio e Importação Ltda.
Programa......: TMKVPE.PRW
Objetivo......: Alteração de Entidades para Televendas. Edição dos campos mesmos do SYP
.               Preechimento da array aMemos.
Autor.........: Jailton B Santos, JBS
Data..........: Sao Paulo,  19 Out 2005
Versão........: 1.0
Consideraçoes.: Ponto de Entrada do TMKA271.PRW -> Função -> TK271AltEnt()
---------------------------------------------------------------------------------------
*/                                    
#INCLUDE "RWMAKE.CH"
USER FUNCTION TMKVPE(cAtend,cCliente,cLoja,cCodCont,cOperador)
Private aMemos:={{"A1_OBSFINM","A1_OBSFINV"},{"A1_INFOCLM","A1_INFOCLV"}}
Private lAltera:=.t.
Private aRotina
Private cCadastro
Private Inclui:=.f.
Private aCposEnchoice:= {}
Private cGetValAlt 

U_DIPPROC(ProcName(0),U_DipUsr()) //MCVN - 22/01/2009

SX3->(dbSetOrder(1))
SX3->(dbSeek("SA1"))
Do While (SX3->(!Eof()).And.SX3->X3_ARQUIVO == "SA1" )
	If !U_DipWhen() .and. AllTrim(SX3->X3_CAMPO) $ 'A1_OBSFINM/A1_OBSFINV'
		SX3->(DbSkip())
		Loop
	EndIF
	If x3uso(SX3->X3_USADO)
		aAdd(aCposEnchoice,AllTrim(SX3->X3_CAMPO))
	EndIf
	SX3->(DbSkip())
EndDo
aRotina:={{OemToAnsi('Pesquisar'),"AxPesqui",0,1},;
{OemToAnsi('Visualizar'),"AxVisual",0,2},;
{OemToAnsi('Incluir'),"AxInclui",0,3},;
{OemToAnsi('Alterar'),"AxAltera",0,4}}
SA1->(DbSetOrder(1))
SA1->(dbSeek(xFilial('SA1')+cCliente+cLoja))
cCadastro:=OemToAnsi('Alteração da Entidade')
cGetValAlt := Altera// Grava o Valor da Variável Altera MCVN - 04/08/2008
Altera := lAltera
SA1->(AxAltera('SA1',RECNO(),4,,aCposEnchoice,,,'U_GravaZG("SA1")')) 
Altera := cGetValAlt  // Retorna o valor original da variável.
RETURN(.t.)                                     
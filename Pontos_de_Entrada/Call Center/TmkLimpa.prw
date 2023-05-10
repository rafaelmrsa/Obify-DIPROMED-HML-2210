#Include "RwMake.Ch"

User Function TmkLimpa()
lDip271Ok  := .f.  //  Libera execução do botão OK na tela do televendas
aDipSenhas := {}   // Array que controla as senhas.
aDipEndEnt := {}    // JBS 31/07/2006 - Após passar pela edição do Endereço de entrega
lDipSenha1 := .f.
lDipSenha2 := .f.  
U_DIPPROC(ProcName(0),U_DipUsr()) //MCVN - 22/01/2009
Return(.t.)
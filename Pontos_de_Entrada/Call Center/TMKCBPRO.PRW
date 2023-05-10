#INCLUDE "RWMAKE.CH"

USER FUNCTION TMKCBPRO(aBtnSup) 
U_DIPPROC(ProcName(0),U_DipUsr()) //MCVN - 22/01/2009                                                                                                  
aBtnSup := {}
//AAdd(aBtnSup, {"DBG10"   , {|| If(!Empty(M->UA_CLIENTE),U_CalcuFrete('TMKCBPRO') ,.F.)  },"Calculo do Frete..." } )
//AAdd(aBtnSup, {"DBG09"   , {|| If(!Empty(M->UA_CLIENTE),U_DIPA004("",.F.)   ,.F.)  },"Caracteristica de Produto..." } )
//AAdd(aBtnSup, {"S4WB005N", {|| If(!Empty(M->UA_CLIENTE),U_DIPG013("BOT",.F.),.F.)  },"Saldos em Aberto..." } )
//AAdd(aBtnSup, {"POSCLI"  , {|| If(!Empty(M->UA_CLIENTE),U_DIPG016(0)         ,.F.)  },"Produtos Top 20..." } )
 
AAdd(aBtnSup, {"S4WB011N", {|| SPEDNFE()    },"Nfe Sefaz" } )
AAdd(aBtnSup, {"S4WB011N", {|| U_ORDSEP11() },"Ordens de Separacao" } )

Return(aBtnSup)

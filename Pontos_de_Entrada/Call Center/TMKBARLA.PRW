
#INCLUDE "RWMAKE.CH"

USER FUNCTION TMKBARLA(aBtnLat)  
                                     
Local cAltCli  := Upper(GetNewPar("ES_TMKALCL","RBORGES/ASANTOS/AALMEIDA"))
Local _cUsuario:= U_DipUsr()
U_DIPPROC(ProcName(0),U_DipUsr()) // JBS 05/10/2005 - Gravando o nome do Programa no SZU

/*
 Eriberto 27/09
aBtnLat := {}
AAdd(aBtnLat, {"DBG10"   , {|| If(!Empty(M->UA_CLIENTE),U_CalcuFrete()      ,.F.)  },"Calculo do Frete..." } )
AAdd(aBtnLat, {"DBG09"   , {|| If(!Empty(M->UA_CLIENTE),U_DIPA004("",.F.)   ,.F.)  },"Caracteristica de Produto..." } )
AAdd(aBtnLat, {"S4WB005N", {|| If(!Empty(M->UA_CLIENTE),U_DIPG013("BOT",.F.),.F.)  },"Saldos em Aberto..." } )
AAdd(aBtnLat, {"POSCLI"  , {|| If(!Empty(M->UA_CLIENTE),U_DIPG016(0)         ,.F.)  },"Produtos Top 20..." } )

*/

aAdd(aBtnLat,{"NOTE"    , {|| U_TELATMKA()} ,"Observação do atendimento."})
aAdd(aBtnLat,{"VENDEDOR", {|| U_C5OPER()}   ,"Operador do Pedido"})
aAdd(aBtnLat,{"S4WB004N", {|| U_LimpAcols()},"Limpa Campos da Nota Fiscal"})
aAdd(aBtnLat,{"BMPPOST" , {|| U_TELATMKB()} ,"Envia E-mail."})
aAdd(aBtnLat,{"BUDGET"  , {|| U_NFDIFALA()} ,"NF com Diferencial ICMS ou ST"})
aAdd(aBtnLat,{"PEDIDO"  , {|| MATA410()}    ,"Pedido de Vendas"})  


If Upper(_cUsuario) $ cAltCli
	AAdd(aBtnLat, {"POSCLI"  , {|| MATA030() } ,"Cadastro de Clientes" } )
EndIf	

Return(aBtnLat)








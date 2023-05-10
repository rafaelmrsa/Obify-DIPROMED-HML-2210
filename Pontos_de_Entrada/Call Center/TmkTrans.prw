#INCLUDE "RWMAKE.CH"

User Function TMKTRANS(_aArray)                                                       
//--------------------------------------------
// Gravando o nome do Programa no SZU
//--------------------------------------------
U_DIPPROC(ProcName(0),U_DipUsr())
//--------------------------------------------
// Calcula o valor do frete - JBS 18/03/2006
//--------------------------------------------
//U_CalcuFrete('TMKVLDE4')
//--------------------------------------------
// Condicao de pagamento                      
//--------------------------------------------
If Empty(M->UA_CONDPG)
	_cCodPagto := Posicione("SA1",1,xFilial("SA1")+M->UA_CLIENTE+M->UA_LOJA,"A1_COND")
Else
	_cCodPagto := M->UA_CONDPG
Endif		
//--------------------------------------------
// Transportadora                             
//--------------------------------------------
If Empty(M->UA_TRANSP)
	_cTransp := Posicione("SA1",1,xFilial("SA1")+M->UA_CLIENTE+M->UA_LOJA,"A1_TRANSP")
Else
	_cTransp := M->UA_TRANSP
EndIf                   
//--------------------------------------------------------------------------------------------------------------------------
// INCLUIDO POR NATALIA DIA 03/11/05 A FIM DE ATUALIZAR O ENDEREÇO DE ENTREGA NA JANELA DE DADOS DE PAGAMENTO NO TELEVENDAS.        
// Quando há o Ponto de Entrada TMKTRANS, o sistema espera que o array contenha os dados da transportadora, 
// condição de pagamento e dados do endereço de entrega, caso contrário, ele deixa em branco. Se este Ponto de Entrada
// não for usado, o sistema atualiza os dados corretamente.
//--------------------------------------------------------------------------------------------------------------------------
cEntE :=Posicione("SA1",1,xFilial("SA1")+M->UA_CLIENTE+M->UA_LOJA,"A1_ENDENT")
Cbairroe:=Posicione("SA1",1,xFilial("SA1")+M->UA_CLIENTE+M->UA_LOJA,"A1_BAIRROE")
Ccidade:=Posicione("SA1",1,xFilial("SA1")+M->UA_CLIENTE+M->UA_LOJA,"A1_MUNE")
CcepE:=Posicione("SA1",1,xFilial("SA1")+M->UA_CLIENTE+M->UA_LOJA,"A1_CEPE")
CUfe:=Posicione("SA1",1,xFilial("SA1")+M->UA_CLIENTE+M->UA_LOJA,"A1_ESTE")

_aArray := {_cTransp,_cCodPagto,centE,CbairroE,Ccidade,CcepE,Cufe}

Return(_aArray)	

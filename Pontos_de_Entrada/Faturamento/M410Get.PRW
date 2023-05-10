/*                                                    São Paulo, 02 Jun 2006
----------------------------------------------------------------------------
Empresa....: Dipromed Comercio e Importação Ltda

Execução...: Antes de montar a tela de alteracao

Objetivo...: Mostra no aCols a quantidade empenhado do produto.
             Este empenho sera utilizado caso exista movimentacao de 
             transferencia entre os almoxarifados para este produto.

Retorno....: Nenhum retorno é esperado

Autor......: Alexandro Dias
Data.......: 20 Fev 2002                                                  


Alterado em: 02 Jun 2006
Por........: Jailton B Santos (JBS)

----------------------------------------------------------------------------
*/
#INCLUDE "RWMAKE.CH"
*----------------------------------*
User Function M410Get()
*----------------------------------*

Local _nX
Local nTotPed := 0

Local _aArea       := GetArea()
Local _cPedido     := M->C5_NUM
Local _aAreaSC6    := {SC6->(IndexOrd()), SC6->(Recno())}
Local _nPosItem    := aScan(aHeader, { |x| Alltrim(x[2]) == "C6_ITEM" })
Local _nPosProd    := aScan(aHeader, { |x| Alltrim(x[2]) == "C6_PRODUTO" })
Local _nPosEmpenho := aScan(aHeader, { |x| Alltrim(x[2]) == "C6_SLDEMPE" })
Local _nPosTotal   := aScan(aHeader, { |x| AllTrim(x[2]) == "C6_VALOR" })
Local _nPosTES     := aScan(aHeader, { |x| AllTrim(x[2]) == "C6_TES" })
Local _nPosPrcVen  := aScan(aHeader, { |x| AllTrim(x[2]) == "C6_PRCVEN" })
Local _nPosMargAtu := aScan(aHeader, { |x| AllTrim(x[2]) == "C6_MARGATU" })
Local _nPosMargIte := aScan(aHeader, { |x| AllTrim(x[2]) == "C6_MARGITE" })
Local _OperLicita := GetMV("MV_OPERLIC") // Operadores de licitação

Private _cCliEspecial := GetMV("MV_CLIESPE") // Cliente especial

If Type("l410Auto")<>"U" .And. l410Auto
	Return .T.
EndIf                                

U_DIPPROC(ProcName(0),U_DipUsr())

aDipSenhas := {}

U_Dipg007("M410GET")

SC6->(DbSetOrder(1))

For _nX := 1 To len(Acols)
	
	nTotPed	+= aCols[_nX][_nPosTotal]
	
	IF SC6->(DbSeek(xFilial("SC6") + _cPedido + aCols[_nX][_nPosItem] + aCols[_nX][_nPosProd] ))
		
		aCols[_nX,_nPosEmpenho] := SC6->C6_QTDEMP
		
	EndIF

	If SB1->(DbSeek(xFilial("SB1")+aCols[_nX][_nPosProd]))
		If SB1->B1_TS <> aCols[_nX][_nPosTES]
			U_DipSenha("TES", aCols[_nX][_nPosTES], aCols[_nX][_nPosPrcVen]*1313*VAL(aCols[_nX][_nPosTES]), 0,.t.)
		EndIf
	EndIf
	
	If aCols[_nX][_nPosMargAtu] < aCols[_nX][_nPosMargIte]
		If Empty(M->C5_CONDPAG).or.(!Empty(M->C5_CONDPAG) .And. SE4->E4_USERDES = 0)
			If !M->C5_CLIENTE $ _cCliEspecial
				U_DipSenha("MA2", aCols[_nX][_nPosProd], aCols[_nX][_nPosTotal], 0,.t.)
			EndIf
		Endif
	EndIf
	
Next _nX

SC6->(DbSetOrder(_aAreaSC6[1]))
SC6->(DbGoto(_aAreaSC6[2]))
//
// Executa o desconto
//
nTotPed  -= M->C5_DESCONT // Desconto Informado na capa do Pedido
nTotPed  -= A410Arred(nTotPed*M->C5_PDESCAB/100,"C6_VALOR") // Desconto em percentual informado na Capa

// Eriberto 11/04/2007 
// Limpa as senhas, se pedir senha grava de novo.
	M->C5_SENHMAR := ''
	M->C5_SENHPAG := ''
	M->C5_SENHCID := '' 
///////////////////////                                  

If M->C5_CONDPAG <> SA1->A1_COND // Caso a condição de pagamento do pedido seja a mesma do cadastro do cliente não pede senha  -  MCVN 09/10/2007

	If (nTotPed <= SE4->E4_INFER .or. nTotPed >= SE4->E4_SUPER) .and.;
    	   (Empty(SE4->E4_SEGMENT) .or. !AllTrim(SA1->A1_SATIV1) $ SE4->E4_SEGMENT) .and.;
	  	   (M->C5_CONDPAG <> "167" .or. !M->C5_OPERADO $ _OperLicita /*'000013/000056/000106/000109/000130'*/) .and.; // JBS 25/10/2006 000130
	   	   !M->C5_CLIENTE $ _cCliEspecial
	
		U_DipSenha("PAG", M->C5_CONDPAG, nTotPed, 0,.t.)
	
	ElseIf !Empty(SE4->E4_SEGMENT) .and. !AllTrim(SA1->A1_SATIV1) $ SE4->E4_SEGMENT .and.;
		   !M->C5_CLIENTE $ _cCliEspecial

		U_DipSenha("PAG", M->C5_CONDPAG, nTotPed, 0,.t.)
	
	EndIf

Endif              

RestArea(_aArea)
Return(.T.)
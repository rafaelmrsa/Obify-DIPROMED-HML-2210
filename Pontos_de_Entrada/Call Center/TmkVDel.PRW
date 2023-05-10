/*                                                    São Paulo, 21 Jul 2006
----------------------------------------------------------------------------
Empresa....: Dipromed Comercio e Importação Ltda

Execução...: Após a validação de todos os valores do atendimento na exclusão
             do item selecionado na rotina de televendas

Objetivo...: Atualizar a variavel UA_MENNOTA com o valor correto da substituição
             tributaria. 

Retorno....: Nenhum retorno é esperado

Autor......: Jailton B Santos (JBS)
Data.......: 21 Jul 2006      

----------------------------------------------------------------------------
*/
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "AP5MAIL.CH"
*------------------------------------------------------*
User Function TMKVDEL()
*------------------------------------------------------*
Local _nST      := 0
Local _nValST   := 0
Local _cAsterix := Iif(SA1->A1_EST=='MG','**','*')
Local _cMais    := Iif(SA1->A1_EST=='RJ','#','')
Local _nIndiceA := _nIndiceB := 0

U_DIPPROC(ProcName(0),U_DipUsr()) //MCVN - 22/01/2009

If SA1->A1_EST == 'RJ'
	_nIndiceA := GetMV("MV_STRJ18")
	_nIndiceB := GetMV("MV_STRJ12")
ElseIf SA1->A1_EST != 'SP'
	_nIndiceA := GetMV("MV_ST" + SA1->A1_EST)
EndIf

If AT('=ST=D',M->UA_MENNOTA) > 0
	
	SB1->(DbSetOrder(1))
	
	If SB1->(DbSeek(xFilial("SB1") + aCols[n,aScan(aHeader, { |x| Alltrim(x[2]) == 'UB_PRODUTO'})]))
		
		If SA1->A1_EST == 'RJ'
			If _cAsterix $ SB1->B1_DESC	.OR. _cMais $ SB1->B1_DESC
				_nST += Round(aCols[n,aScan(aHeader, { |x| Alltrim(x[2]) == 'UB_VLRITEM'})] * IIf(SB1->B1_PICM = 18,_nIndiceA,_nIndiceB),2)
			EndIf
		else
			If _cAsterix $ SB1->B1_DESC
				_nST += Round(aCols[n,aScan(aHeader, { |x| Alltrim(x[2]) == 'UB_VLRITEM'})] * _nIndiceA,2)
			EndIf
		EndIf
		
	EndIf

//	&(Iif("TMK"$FunName(),'aVALORES[5]','M->C5_DESPESA')) := _nDespesa
	&('M->'+Iif("TMK"$FunName(),'UA','C5')+'_MENNOTA')    := Alltrim(SUBS(&('M->'+Iif("TMK"$FunName(),'UA','C5')+'_MENNOTA'),AT('=ST=',&('M->'+Iif("TMK"$FunName(),'UA','C5')+'_MENNOTA'))+IiF(AT('=ST=',&('M->'+Iif("TMK"$FunName(),'UA','C5')+'_MENNOTA'))==0,1,5),120-(AT('=ST=',&('M->'+Iif("TMK"$FunName(),'UA','C5')+'_MENNOTA'))+IiF(AT('=ST=',&('M->'+Iif("TMK"$FunName(),'UA','C5')+'_MENNOTA'))==0,1,5))))
	&('M->'+Iif("TMK"$FunName(),'UA','C5')+'_MENNOTA')    := ;
	Alltrim(&('M->'+Iif("TMK"$FunName(),'UA','C5')+'_MENNOTA')) +;
	space(AvSx3("UA_MENNOTA",3) - len(Alltrim(&('M->'+Iif("TMK"$FunName(),'UA','C5')+'_MENNOTA'))))

/*	
	cMenNota  := Right(M->UA_MENNOTA,At('=ST=D',M->UA_MENNOTA))
	nValorSub := Val(Subs(M->UA_MENNOTA,1,AT('=ST=D',M->UA_MENNOTA)-1))
	
	If nValorSub > 0
		If round((nValorSub - _nST),2) > 0
			cMenNota:=Alltrim(Transform(round(nValorSub-_nST,2),"99999.99"))+cMenNota //Right(M->UA_MENNOTA,At('=ST=D',M->UA_MENNOTA))
		Else
			cMenNota:=Right(M->UA_MENNOTA,At('=ST=D',M->UA_MENNOTA)+5)
		EndIf     
	    M->UA_MENNOTA := cMenNota
	EndIf
*/	
EndIf
  
U_DIPG007() // Para atualizar tela quando deletar/restaurar linhas...
Return(.t.)

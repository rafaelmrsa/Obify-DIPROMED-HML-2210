/*====================================================================================\
|Programa  | DIPA035       | Autor | Maximo Canuto Vieira Neto  | Data | 18/04/07     |
|=====================================================================================|
|Descrição | Atualiza SC5 com novas parcelas e vencimentos                            |
|=====================================================================================|
|Uso       | Especifico DIPROMED                                                      |
\====================================================================================*/

#INCLUDE "RWMAKE.CH"
#Include "Ap5Mail.ch"
#DEFINE CR    chr(13)+chr(10) // Carreage Return (Fim de Linha)

User Function DIPA035()
 

Local cUserAut := GetMV("MV_ALTCOND")
Private nParc1 := nParc2 := nParc3 := nParc4 := nParc5 := nParc6 := 0 
Private dVenc1 := dVenc2 := dVenc3 := dVenc4 := dVenc5 := dVenc6 := ctod("  /  /  ")
Private cCondPag  := "016"
private cPedido   := SPACE(06) 
private nVlrPed   := 0

If !AllTrim(Upper(U_DipUsr())) $ cUserAut
	MSGSTOP("Usuario sem autorização!")
	Return
EndIf

U_DIPPROC(ProcName(0),U_DipUsr()) 
// alteração de tamanho  150 para 10 para compor todos os campos e botões --- Blandino 10/08/2020
@ 10,000 To 525,400 DIALOG oDlg TITLE OemToAnsi("ALTERANDO CONDIÇÃO DE PAGAMENTO, PARCELA E VENCIMENTO NO PEDIDO DE VENDA.")

@ 008,010 Say "INFORME O PEDIDO DE VENDA "                       
@ 008,120 Get cPedido Size 33,30  Valid ValorPedido(cPedido)                
@ 028,010 Say "Valor Total do pedido"
@ 028,120 Get nVlrPed Size 45,40 When .F. Picture "@E 999,999,999.99" 
@ 045,010 Say "Informe o Valor da 1ª parcela"
@ 045,120 Get nParc1 Size 45,40 Valid nParc1<>0 Picture "@E 999,999,999.99" 
@ 060,010 Say "Informe o Vencimento da 1ª parcela"
@ 060,120 Get dVenc1 Size 33,28 Valid !Empty(dVenc1) .and. dVenc1 > date()
@ 075,010 Say "Informe o Valor da 2ª parcela"
@ 075,120 Get nParc2 Size 45,40 Valid nParc1<>0 Picture "@E 999,999,999.99" 
@ 090,010 Say "Informe o Vencimento da 2ª parcela"
@ 090,120 Get dVenc2 Size 33,28 Valid dVenc2 > dVenc1 .and. nParc2<>0
@ 105,010 Say "Informe o Valor da 3ª parcela"
@ 105,120 Get nParc3 Size 45,40 Valid nParc1<>0 .and. nParc2<>0  Picture "@E 999,999,999.99" 
@ 120,010 Say "Informe o Vencimento da 3ª parcela"
@ 120,120 Get dVenc3 Size 33,28 Valid dVenc3 > dVenc2 .and. nParc3<>0 
@ 135,010 Say "Informe o Valor da 4ª parcela"
@ 135,120 Get nParc4 Size 45,40 Valid nParc1<>0 .and. nParc2<>0 .and. nParc3<>0 Picture "@E 999,999,999.99" 
@ 150,010 Say "Informe o Vencimento da 4ª parcela"
@ 150,120 Get dVenc4 Size 33,28 Valid dVenc4 > dVenc3 .and. nParc4<>0 
//Inclusao das validacoes para parcela 5 e 6 - Felipe Duran 
@ 165,010 Say "Informe o Valor da 5ª parcela"
@ 165,120 Get nParc5 Size 45,40 Valid nParc1<>0 .and. nParc2<>0 .and. nParc3<>0 .and. nParc4<>0 Picture "@E 999,999,999.99" 
@ 180,010 Say "Informe o Vencimento da 5ª parcela"
@ 180,120 Get dVenc5 Size 33,28 Valid dVenc5 > dVenc5 .and. nParc5<>0
@ 195,010 Say "Informe o Valor da 6ª parcela"
@ 195,120 Get nParc6 Size 45,40 Valid nParc1<>0 .and. nParc2<>0 .and. nParc3<>0 .and. nParc4<>0 .and. nParc5<>0 Picture "@E 999,999,999.99" 
@ 210,010 Say "Informe o Vencimento da 6ª parcela"
@ 210,120 Get dVenc5 Size 33,28 Valid dVenc5 > dVenc5 .and. nParc5<>0
//Fim do ajuste
@ 230,100 BMPBUTTON TYPE 1 ACTION GravaSC5()
@ 230,140 BMPBUTTON TYPE 2 ACTION Close(oDlg)

ACTIVATE DIALOG oDlg Centered

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DIPA035   ºAutor  ³Microsiga           º Data ³  08/26/16   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function GravaSC5()
      
Local nSomaParc := 0
Local nValPed   := 0
Local _aMsg         := {}
Local _cAssunto     := ""
Local _cEmail       := ""  
Local _cDestCli  	:= ""  
Local _cFrom     	:= "" 
Local _cFuncSent 	:= "DIPA035.PRW

/*//Totalizando o Valor do pedido de venda no Sistema incluindo frete, seguro, Icms-St e despesas.
DbSelectArea("SC6")
DbSetOrder(1)
SC6->(DbSeek(xFilial("SC6")+cPedido))
   While SC6->C6_NUM == cPedido
   		If SC6->C6_NUM == cPedido
   			nValPed += SC6->C6_VALOR
   		Endif
   SC6->(DbSkip())			  
   Enddo
SC6->(DbCloseArea())*/



// Totalizando valores informados
nSomaParc = nParc1+nParc2+nParc3+nParc4+nParc5+nParc6      

// Atualizando SC5
DbSelectArea("SC5")
DbSetOrder(1)
If SC5->(DbSeek(xFilial("SC5")+cPedido))
	If Empty(SC5->C5_NOTA)
	  //	If nSomaParc == (nValPed + SC5->C5_DESPESA + SC5->C5_SEGURO + SC5->C5_FRETE) .and. dVenc1 > SC5->C5_EMISSAO
	  	If nSomaParc == nVlrPed .and. dVenc1 > SC5->C5_EMISSAO

			Begin Transaction	
			SC5->(Reclock("SC5",.F.))
			    SC5->C5_CONDPAG := cCondpag
				SC5->C5_PARC1 := nParc1
				SC5->C5_DATA1 := dVenc1
				SC5->C5_PARC2 := nParc2
				SC5->C5_DATA2 := dVenc2
				SC5->C5_PARC3 := nParc3
				SC5->C5_DATA3 := dVenc3
				SC5->C5_PARC4 := nParc4
				SC5->C5_DATA4 := dVenc4
				SC5->C5_PARC5 := nParc5 //Inclusao das parcelas 5 e 6 - Felipe Duran
				SC5->C5_DATA5 := dVenc5
				SC5->C5_PARC6 := nParc6
				SC5->C5_DATA6 := dVenc6
			SC5->(MsUnLock("SC5"))
			End Transaction	
		   
			//U_DiprKardex(cPedido,U_DipUsr(),,.t.,"38") // Grava Informação no Kardex
			
			CONDPAGCIC(cPedido) //Envia Cic para o responsável 
			
			// Envia e-mail para eriberto   MCVN - 17/04/2008
			_cFrom  := "protheus@dipromed.com.br"//Lower(Alltrim(Posicione("SU7",1,xFilial("SU7")+SC5->C5_OPERADO,"U7_EMAIL")))
		    _cEmail  := "maximo@dipromed.com.br"                                
		    _cAssunto:= EncodeUTF8("Alteração de condição de pagamento do pedido  "+SC5->C5_NUM,"cp1252")
		   	Aadd( _aMsg , { "Numero Pedido: "       , SC5->C5_NUM } )
			Aadd( _aMsg , { "Operador: "            , SC5->C5_OPERADO  +" - "+ Upper(Alltrim(Posicione("SU7",1,xFilial("SU7")+SC5->C5_OPERADO,"U7_NOME"))) } )
			Aadd( _aMsg , { "Cliente:  "            , SC5->C5_CLIENTE  +" - "+ AllTrim(Posicione("SA1",1,xFilial("SA1")+SC5->C5_CLIENTE+SC5->C5_LOJACLI,"A1_NOME")) } )
			Aadd( _aMsg , { "Parcela 1: "           , Transform(nParc1,"@E 999,999,999.99") } )
			Aadd( _aMsg , { "Vencimento 1: "        , Dtoc(dVenc1) } )			
			Aadd( _aMsg , { "Parcela 2: "           , Transform(nParc2,"@E 999,999,999.99") } )
			Aadd( _aMsg , { "Vencimento 2: "        , Dtoc(dVenc2) } )			
			Aadd( _aMsg , { "Parcela 3: "           , Transform(nParc3,"@E 999,999,999.99") } )
			Aadd( _aMsg , { "Vencimento 3: "        , Dtoc(dVenc3) } )			
			Aadd( _aMsg , { "Parcela 4: "           , Transform(nParc4,"@E 999,999,999.99") } )
			Aadd( _aMsg , { "Vencimento 4: "        , Dtoc(dVenc4) } )
			Aadd( _aMsg , { "Parcela 5: "           , Transform(nParc5,"@E 999,999,999.99") } ) //inclusao das parcelas 5 e 6 - Felipe Duran
			Aadd( _aMsg , { "Vencimento 5: "        , Dtoc(dVenc5) } )
			Aadd( _aMsg , { "Parcela 6: "           , Transform(nParc6,"@E 999,999,999.99") } )
			Aadd( _aMsg , { "Vencimento 6: "        , Dtoc(dVenc6) } )
			Aadd( _aMsg , { "Quem Alterou: "        , U_DipUsr() } )			
			U_UEnvMail(_cEmail,_cAssunto,_aMsg,"",_cFrom,_cFuncSent)       
			
			
			// Limpa Variáveis
			//Inclusao das parcelas 5 e 6 - Felipe Duran
			cPedido := ""
			nParc1 := 0
			nParc2 := 0
			nParc3 := 0
			nParc4 := 0
			nParc5 := 0 
			nParc6 := 0   
			nVlrPed:= 0
			dVenc1 := ctod("  /  /  ")
			dVenc2 := ctod("  /  /  ")
			dVenc3 := ctod("  /  /  ")
			dVenc4 := ctod("  /  /  ")
			dVenc5 := ctod("  /  /  ")
			dVenc6 := ctod("  /  /  ")
			                                                   
			
			Alert("O pedido "+cPedido+" foi atualizado com sucesso.")	
		Else
			Alert("O total do valor informado não confere com o total do pedido de venda.")
		EndIF
	Else	
		Alert("Pedido de venda já gerou nota fiscal, não é possível alterar Condição de pagamento e vencimento")
	Endif
Else
	Alert("Pedido de venda "+cPedido+" não encontrado")
Endif  

Return()
        

*--------------------------------------------------------------------------*
//Função para enviar Cic para o responsável
Static Function ValorPedido(cPedido)
*--------------------------------------------------------------------------*

DbSelectArea("SC6")
DbSetOrder(1)
SC6->(DbSeek(xFilial("SC6")+cPedido))
   While SC6->C6_NUM == cPedido
   		If SC6->C6_NUM == cPedido
   			nVlrPed += SC6->C6_VALOR
   		Endif
   SC6->(DbSkip())			  
   Enddo
SC6->(DbCloseArea())

DbSelectArea("SC5")
DbSetOrder(1)
If SC5->(DbSeek(xFilial("SC5")+cPedido))
	 nVlrPed := (nVlrPed + SC5->C5_DESPESA + SC5->C5_SEGURO + SC5->C5_FRETE)
	 If "=ST=D"$SC5->C5_MENNOTA
		nVlrPed += Val(Subs(SC5->C5_MENNOTA,1,AT("=ST=D",SC5->C5_MENNOTA)-1))
	 EndIf
Endif
		
Return()
*--------------------------------------------------------------------------*
//Função para enviar Cic para o responsável
Static Function CONDPAGCIC(cPedido)
*--------------------------------------------------------------------------*
Local lRetorno := .T.
Local cMail
Local cServidor   := GetMV("MV_CIC")     // Servidor para enviar mensagem pelo CIC
Local cOpFatRem   := GetMV("MV_REMETCI") // Usuario do CIC remetente de mensgens no Protheus
Local cOpFatSenha := "123456"
Local cOpFatDest  := ""
Local cCliente := ""

// Dados do Destinatario da Mensagem CIC

cOpFatDest := "MAXIMO.CANUTO,"+Posicione("SU7",1,xFilial("SU7")+SC5->C5_OPERADO,"U7_CICNOME")

SA1->(dbSetOrder(1))
SA1->(dbSeek(xFilial("SA1") + SC5->C5_CLIENTE + SC5->C5_LOJACLI))
	cCliente := AllTrim(SC5->C5_CLIENTE)+" - "+AllTrim(SA1->A1_NREDUZ)
		
		// Monta a mensagem a ser enviado ao operador
		cMail := "AVISO IMPORTANTE"+CR+CR
		cMail += "O Pedido " +SC5->C5_NUM
		cMail += " do Cliente "+cCliente+CR
		cMail += " Teve sua condição de pagamento, parcela e vencimento alterados."+CR+CR
		cMail += "Condição de Pagamento: " +cCondpag +"."+ CR+CR
		cMail += "Parcela 1: R$ " +Transform(nParc1,"@E 999,999,999.99")+"   -   Vencimento : " +Dtoc(dVenc1) +CR+CR
		If nParc2 <> 0 
			cMail += "Parcela 2: R$ " +Transform(nParc2,"@E 999,999,999.99")+"   -   Vencimento : " +Dtoc(dVenc2) +CR+CR 
		Endif
		If nParc3 <> 0 
			cMail += "Parcela 3: R$ " +Transform(nParc3,"@E 999,999,999.99")+"   -   Vencimento : " +Dtoc(dVenc3) +CR+CR 
		Endif
		If nParc4 <> 0 
			cMail += "Parcela 4: R$ " +Transform(nParc4,"@E 999,999,999.99")+"   -   Vencimento : " +Dtoc(dVenc4) +CR+CR 
		Endif
		//Inclusao das parcelas 5 e 6 - Felipe Duran  
		If nParc5 <> 0 
			cMail += "Parcela 5: R$ " +Transform(nParc5,"@E 999,999,999.99")+"   -   Vencimento : " +Dtoc(dVenc5) +CR+CR 
		Endif
		If nParc6 <> 0 
			cMail += "Parcela 6: R$ " +Transform(nParc6,"@E 999,999,999.99")+"   -   Vencimento : " +Dtoc(dVenc6) +CR+CR 
		Endif  
		//Fim                        
		cMail += "Operador: "+ Posicione("SU7",1,xFilial("SU7")+SC5->C5_OPERADO,"U7_CICNOME") +CR+CR 
		cMail += "Quem Alterou: " + U_DipUsr()
		
		// Envia a mensagem ao operador através do CIC

		U_DIPCIC(cMail,AllTrim(cOpFatDest))//RBorges 12/03/15
		//WaitRun(cServidor+' '+cOpFatRem+' '+cOpFatSenha+' "'+AllTrim(cOpFatDest)+'" "'+cMail+'" ') //Comentada RBorges 12/03/15

Return()

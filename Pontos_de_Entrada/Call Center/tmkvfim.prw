#INCLUDE "RWMAKE.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TMKVFIM   ºAutor  ³Fabio Rogerio       º Data ³  09/02/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Adequacao do TMKVFIM para uso com o novo conceito de reservaº±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function TMKVFIM()
Local aAlias    := GetArea()
Local cOpFat	:= SuperGetMv("MV_OPFAT")
Local cCodOpera :=''
Local cMsg      := ''

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿        			
//³ Caso tenha sido gravado o pedido de vendas e o parâmetro  ³
//³ "MV_OPFAT" estiver igual a Não, chama a tela de liberação ³
//³ do pedido de vendas.                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Atualiza a tabela de ocorrencias.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
U_DIPPROC(ProcName(0),U_DipUsr()) // JBS 05/10/2005 - Gravando o nome do Programa no SZU


If SUA->UA_OPER == "1" // Faturamento
	If !Empty(SUA->UA_NUMSC5) .And. cOpFat == "N"
		
		DbSelectArea("SC5")
		DbSetOrder(1)
		If MsSeek(xFilial("SC5") + SUA->UA_NUMSC5)
			RecLock("SC5", .F.)

			SC5->C5_MARGATU := SUA->UA_MARGATU
			SC5->C5_MARGLIB := SUA->UA_MARGLIB
			SC5->C5_TPFRETE := SUA->UA_TPFRETE
			SC5->C5_DESTFRET:= SUA->UA_DESTFRE
			SC5->C5_FLAGFRE := SUA->UA_FLAGFRE
			SC5->C5_PBRUTO  := SUA->UA_PBRUTO
			SC5->C5_PESOL   := SUA->UA_PESOL
			SC5->C5_OPERADO := SUA->UA_OPERADO
			SC5->C5_MENPAD  := SUA->UA_MENPAD
			SC5->C5_MENNOTA := SUA->UA_MENNOTA
			SC5->C5_MENDEP  := SUA->UA_MENDEP
			SC5->C5_QUEMCON := SUA->UA_DESCNT
			SC5->C5_FRETE   := SUA->UA_FRETE
			SC5->C5_HORA    := SUBS(TIME(),1,5)
			SC5->C5_EXPLSEN := SUA->UA_EXPLSEN
			SC5->C5_SENHCID := SUA->UA_SENHCID
			SC5->C5_SENHPAG := SUA->UA_SENHPAG
			SC5->C5_SENHMAR := SUA->UA_SENHMAR
			SC5->C5_SENHTES := SUA->UA_SENHTES
			SC5->C5_CONDPAG := If(Empty(SUA->UA_CONDPG),'002',SUA->UA_CONDPG) // JBS 18/01/2006
			SC5->C5_TRANSP  := If(Empty(SUA->UA_TRANSP),'000001',SUA->UA_TRANSP) // JBS 18/01/2006
			SC5->C5_TPFRETE := If(Empty(SUA->UA_TRANSP),'N',SUA->UA_TPFRETE) // JBS 18/01/2006
			SC5->C5_TIPODIP := '1' // MCVN - 22/07/09 
			SC5->C5_DIPCOM  := '2' // MCVN - 22/07/09 
			SC5->C5_TMK     := '1' // MCVN - 22/07/09
			

			// ENDEREÇO DE ENTREGA
			SC5->C5_ENDENT	:= SUA->UA_ENDENT
			SC5->C5_BAIRROE := SUA->UA_BAIRROE
			SC5->C5_MUNE   	:= SUA->UA_MUNE
			SC5->C5_CEPE   	:= SUA->UA_CEPE
			SC5->C5_ESTE   	:= SUA->UA_ESTE
		
			// Eriberto 16/04/2005 colocando vendedor KC
			SC5->C5_VEND2   := SUA->UA_VENDKC

			//Novo Conceito de Reserva - Fabio Rogerio - 02/09/2006
			SC5->C5_PARCIAL := "N"  //MCVN - 20/08/2007
			
			SC5->(MsUnlock())

		EndIf
	
		DBSelectArea("SUB")
		DBSetOrder(1)
		If MsSeek(xFilial("SUB")+SUA->UA_NUM)
			While SUB->(!Eof())				.AND.;
				 SUB->UB_NUM==SUA->UA_NUM 	.AND.;
				 xFilial("SUB") == SUB->UB_FILIAL 	//  FOI COLOCADO A VALIDACAO DA FILIAL
				
				RecLock("SUB",.F.)
				If SUA->UA_DESCONT > 0 .AND. SUA->UA_OPER == "1"
					SUB->UB_USERDES	:= SUA->UA_DESCONT * (SUB->UB_VLRITEM/SUA->UA_VALMERC)
					SUB->UB_VLRITEM	-= SUB->UB_USERDES
					SUB->UB_VRUNIT	:= SUB->UB_VLRITEM / SUB->UB_QUANT
					SUB->UB_PRCTAB	:= SUB->UB_VRUNIT
	                SUB->UB_USERPRC	:= SUB->UB_VRUNIT				// Eriberto 20/01/2005
				Endif
	            //Eriberto 20/01/06			SUB->UB_USERPRC	:= SUB->UB_VRUNIT
	            //Eriberto 20/01/06			SUB->UB_USEPROD	:= SUB->UB_PRODUTO
				SUB->(MsUnlock())
				
				DbSelectArea("SC6")
				DbSetOrder(1)
				If MsSeek(xFilial("SC6") + SC5->C5_NUM + SUB->(UB_ITEM+UB_PRODUTO) )
					RecLock("SC6", .F.)
					SC6->C6_COMIS1	 := SUB->UB_COMIS1
					SC6->C6_COMIS2	 := SUB->UB_COMIS2
					SC6->C6_QTDRESE  := SUB->UB_QTRESER
					SC6->C6_FORNEC   := SUB->UB_FORNEC
					SC6->C6_MARGITE  := SUB->UB_MARGITE
					SC6->C6_MARGATU  := SUB->UB_MARGATU
					SC6->C6_CUSTO    := SUB->UB_CUSTO
					SC6->C6_NOTA     := SUB->UB_NOTA
					SC6->C6_CLASFIS  := SUB->UB_CLASFIS
					SC6->C6_UNSVEN   := SUB->UB_UNSVEN
					SC6->C6_SEGUM    := SUB->UB_SEGUM
					SC6->C6_PRCMIN   := SUB->UB_PRCMIN
					SC6->C6_PRCVEN   := SUB->UB_VRUNIT
					SC6->C6_PRUNIT   := SUB->UB_PRCTAB
					SC6->C6_USERPRC  := SUB->UB_USERPRC
					SC6->C6_USERDES  := SUB->UB_USERDES      
				 	SC6->C6_PRVMINI  := SUB->UB_PRVMINI //PREÇO C         MCVN - 07/10/2007
				 	SC6->C6_PRVSUPE  := SUB->UB_PRVSUPE //PREÇO PROMOÇÃO  MCVN - 07/10/2007 
				 	SC6->C6_TES		 := SUB->UB_TES  // Atualizando TES   MCVN - 07/04/2008 
				 	SC6->C6_CF		 := SUB->UB_CF   // Atualizando CF    MCVN - 07/04/2008 
	 				SC6->C6_TIPODIP  := '1'          // MCVN - 22/07/09
					SC6->(MsUnlock())
				EndIf
		
				DbSelectArea("SUB")
				DbSkip()
			End
		EndIf
				
  
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Grava o usuario que movimenta o Kardex.     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
        cMsg := ''
        
        // JBS 17/11/2005 - Inicio
		If Inclui                  // Inclusao de Pedido
			 cCodOpera:='11'
		ElseIf SUA->UA_OPER == '1' // Alteração do Pedido  
			If SZ9->(dbSeek(xFilial('SZ9')+SUA->UA_NUMSC5))
			   cCodOpera:='12'	   
			Else                       // Alteração de Cotação para Pedido
			   cCodOpera:='28'
   			   cMsg := 'Cotacao '+SUA->UA_NUM
   			EndIf   
      	EndIf
		
		U_DiprKardex(SUA->UA_NUMSC5,U_DipUsr(),If(cCodOpera = "28",cMsg,NIL),.t.,cCodOpera) // JBS 17/11/2005 - Fim
		If !EMPTY(M->UA_SENHPAG) .OR. !EMPTY(M->UA_SENHMAR) .OR. !EMPTY(M->UA_SENHCID)
			U_DiprKardex(SUA->UA_NUMSC5,U_DipUsr(),,.t.,"27") // JBS 29/08/2005
		EndIf
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Chama a Liberacao do Pedido.³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		U_MTA410T()
	EndIf
EndIf

//-----------------------------------------------
// Atualiza campo Data Limite e Transportadora
//-----------------------------------------------
If SUA->(!EOF()).and. SUA->UA_NUM == M->UA_NUM // JBS 16/02/2006
	RecLock("SUA",.F.) // JBS 16/02/2006
	SUA->UA_DTLIM  := M->UA_DTLIM // Ja foi corrigido
	SUA->UA_TRANSP := M->UA_TRANSP // JBS 10/05/2006 - Calculo do Frete    
	SUA->UA_STATUS :=IF(EMPTY(SUA->UA_STATUS) .OR. SUA->UA_STATUS == "LIB","SUP",SUA->UA_STATUS)  //TRATANDO STATUS DEVIDO A ALTERAÇÃO PARA O R4 MCVN - 07/11/2007
	SUA->(MsUnlock()) // JBS 16/02/2006
EndIf // JBS 16/02/2006

RestArea(aAlias)

Return(NIL)
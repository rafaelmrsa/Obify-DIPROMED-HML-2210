#include "protheus.ch"
#include "rwmake.ch"


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma ³ DIPA034  º Autor ³   Maximo Canuto    º Data ³  12/12/06    º±±
±±ÌÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.    ³ Função chamada pelo DIPA008.PRW - Inclui/Altera B1_PERPROM  º±±
±±ÌÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºHistorico³ 															  º±±
±±º14/02/08 ³Incluindo campos para gravar nome da promoção e se mostra a  º±±
±±          ³promoção aos operadores - Maximo Canuto.					  º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function Dipa034(cOpcao)
Local dDtAtual := date()
Local lValida  := .F.  
Local cPerProm := "  /  /  -  /  /  "
Local cNomeProm:= Space(25) 
Local cMostProm:= " "
Local lReplica := .F.       
Local aProd    := {}
Local nI	   := 0
Private nOpcao := 2
Default cOpcao := "INCLUI"

U_DIPPROC(ProcName(0),U_DipUsr()) // MCVN - 22/01/2009

_cAliasSB1 := SB1->(GetArea())         

dbSelectArea("TRBSB1")

// SB1->(DbOrderNickName("B1MARCPRO"))
// IF SB1->(DbSeek(xFilial("SB1")+cMarca)) // Verificar se existe produtos marcados.
    
If !Empty(cMarca)   
	If cOpcao <> "EXCLUI"
		While lValida == .F. // Verificando se a informação foi digitada corretamente
			@ 126,000 To 300,350 DIALOG oDlg TITLE OemToAnsi("Informe os dados da Promoção")
			@ 010,010 Say "Período: "
			@ 010,035 Get cPerProm  size 60,20 Picture "@E 99/99/99-99/99/99"
			@ 025,010 Say "Nome: "
			@ 025,035 Get cNomeProm size 100,20 Valid (Len(cNomeProm) <= 25 .And. !Empty(cNomeProm))
			@ 040,010 Say "Mostra? (S=Sim, N=Nao): "
			@ 040,075 Get cMostProm size 10,20 Valid (cMostProm	="S" .OR. cMostProm	="N")
			@ 070,010 BMPBUTTON TYPE 1 ACTION  (nOpcao := 1,Close(oDlg))
			@ 070,065 BMPBUTTON TYPE 2 ACTION  (nOpcao := 0,Close(odlg))
			ACTIVATE DIALOG oDlg Centered
			
			If (cPerProm <> "" .AND. Len(alltrim(cPerProm)) == 17 ) .OR. nOpcao == 0 .OR. nOpcao == 2
				lValida := .T.
			Else
				MsgInfo("Favor preencher corretamente o Período de Promoção")
			EndIf		
		EndDo
		
		If nOpcao == 0  .OR. nOpcao == 2
			TRBSB1->(dbGoTop())
			lValida := .F.
			RestArea(_cAliasSB1)
		Else
			lReplica := Aviso("Atenção","Deseja replicar as alterações para "+IIf(xFilial("SB1")=="01","o CD","a Matriz")+"?",{"Sim","Não"},1)==1
			
			If cPerProm <> "" .AND. Len(alltrim(cPerProm)) == 17 //Verifica a informação Digitada
				
				ProcRegua(TRBSB1->(RECCOUNT()))
				
				SET FILTER TO cMarca == TRBSB1->B1_OK2
				TRBSB1->(dbGoTop())	
				
				SB1->(dbSetOrder(1))
				While !TRBSB1->(Eof()) .AND. cMarca == TRBSB1->B1_OK2
					IncProc(AllTrim(TRBSB1->B1_COD)+'-'+SubSTR(TRBSB1->B1_DESC,30))
					If SB1->(dbSeek(xFilial("SB1")+TRBSB1->B1_COD))
						SB1->(RecLock("SB1",.F.))
					  		SB1->B1_PERPROM := cPerProm
							SB1->B1_OK2     := ''
							SB1->B1_NPROMOC := cNomeProm
							SB1->B1_MOSTPRO := cMostProm
						SB1->(MsUnlock())
						If lReplica
							aAdd(aProd,SB1->B1_COD)
						EndIf         
					EndIf
					TRBSB1->(DbSkip())
				EndDo
				
				If lReplica
					Dbselectarea("SB1")
					cDipFil := IIf(xFilial("SB1")=="01","04","01")
					SB1->(dbSetOrder(1))
					For nI:=1 to Len(aProd)
						If SB1->(dbSeek(cDipFil+aProd[nI]))
							SB1->(RecLock("SB1",.F.))
							SB1->B1_PERPROM := cPerProm
							SB1->B1_OK2     := ''
							SB1->B1_NPROMOC := cNomeProm
							SB1->B1_MOSTPRO := cMostProm
							SB1->(MsUnlock())
						EndIf
					Next nI
				EndIf
	
				lValida := .F.
	
				dbSelectArea("TRBSB1")
				Set filter to						
				U_DipMonTmp()                  
	
			EndIf
		EndIf
	Else 
		lReplica := Aviso("Atenção","Deseja replicar as alterações para "+IIf(xFilial("SB1")=="01","o CD","a Matriz")+"?",{"Sim","Não"},1)==1
			
		ProcRegua(TRBSB1->(RECCOUNT()))
		
		SET FILTER TO cMarca == TRBSB1->B1_OK2
		TRBSB1->(dbGoTop())	
		
		SB1->(dbSetOrder(1))
		While !TRBSB1->(Eof()) .AND. cMarca == TRBSB1->B1_OK2
			IncProc(AllTrim(TRBSB1->B1_COD)+'-'+SubSTR(TRBSB1->B1_DESC,30))
			If SB1->(dbSeek(xFilial("SB1")+TRBSB1->B1_COD))
				SB1->(RecLock("SB1",.F.))
			  		SB1->B1_PERPROM := ""
					//SB1->B1_OK2     := ""
					SB1->B1_NPROMOC := ""
					SB1->B1_MOSTPRO := ""
				SB1->(MsUnlock())
				If lReplica
					aAdd(aProd,SB1->B1_COD)
				EndIf         
			EndIf
			TRBSB1->(DbSkip())
		EndDo
		
		If lReplica
			Dbselectarea("SB1")
			cDipFil := IIf(xFilial("SB1")=="01","04","01")
			SB1->(dbSetOrder(1))
			For nI:=1 to Len(aProd)
				If SB1->(dbSeek(cDipFil+aProd[nI]))
					SB1->(RecLock("SB1",.F.))
					SB1->B1_PERPROM := ""
					//SB1->B1_OK2     := ""
					SB1->B1_NPROMOC := ""
					SB1->B1_MOSTPRO := ""
					SB1->(MsUnlock())
				EndIf
			Next nI
		EndIf

		lValida := .F.

		dbSelectArea("TRBSB1")
		Set filter to						
		U_DipMonTmp()                  	
	EndIf
Else   
   MsgInfo('Por favor selecione uma ou mais produtos para alterar o Período de promoção','Atenção')  
   SB1->(dbgotop())
EndIf    

RestArea(_cAliasSB1)

Return       
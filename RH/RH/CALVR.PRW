#INCLUDE "PROTHEUS.CH"
#INCLUDE "rwmake.ch"
#INCLUDE "prtopdef.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ CALVR    ³ Autor ³ Jose Carlos Gouveia   ³ Data ³ 23.12.04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Calculo do Vale Refeicao                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Especifico para a Dipromed                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³        ³      ³                                           ±± 
±±³            ³        ³      ³                                          ³±±
±±³            ³        ³      ³                                          ³±±
±±³            ³        ³      ³                                          ³±±
±±³            ³        ³      ³                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
User Function CalVR()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Montando Variaveis de Trabalho                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local nDesc_,aTabRef,bBlock,nQtd_

U_DIPPROC(ProcName(0),U_DipUsr()) // MCVN - 22/01/2009

//Inicia Valores
aTabref := {}
bBlock  := {|X,Y| X[1] < Y[1]} //Classificacao do array
I :=  nQtd_ := nDesc_ := 0

SZK->(dbSeek("  01" + SRA->RA_VALEREF))
	
If SZK->(Found())   

	//Carrega Valores
	While (SZK->ZK_TIP + SZK->ZK_CODIGO = "01" + SRA->RA_VALEREF) .And. SZK->(!Eof())
		
		aAdd(aTabref,{Val(Subst(SZK->ZK_TXT,21,12)),Val(Subst(SZK->ZK_TXT,33,12))})
		
		SZK->(dbSkip())
	
	Enddo	

	// Classifica Array aTabRef
	aSort(aTabref,,,bBlock)

	//Quantidade de dias
	If !Empty(SRA->RA_VALEREF) .And. SRX->(dbSeek(xFilial('SRX') + '26' + SRA->RA_FILIAL + SRA->RA_VALEREF, .F.))
		nQtd_ := Val(Subst(SRX->RX_TXT,33,3))
	Else
		If !Empty(SRA->RA_VALEREF) .And. SRX->(dbSeek(xFilial('SRX') + '26  ' + SRA->RA_VALEREF, .F.))
			nQtd_ := Val(Subst(SRX->RX_TXT,33,3))
		End
	End   
	

	//Localiza Limite do Salario e Calcula Desconto
	For I := 1 to Len(aTabref) 
		If SRA->RA_SALARIO <= aTabref[I,1] 
			nDesc_ := aTabref[I,2] * nQtd_
	      Exit
		End
	Next

	//Deletar Verba de Vale Refeicao
	If fBuscaPD(aCodFol[050,1],"V") > 0
		aPd[fLocaliaPd(aCodFol[050,1]),9] == "D"
	End
	
	// Verifica se Verba Informada
	If fBuscaPD("498","V") > 0
		If aPd[fLocaliaPd("498"),7] == "I"
   	     Return
		End
	Endif
	
	//Gera Verba
	If nDesc_ > 0
		//Parte Funcionario
		fGeraVerba("498",nDesc_)
	Endif                          

Endif

//Retorna
Return

//Fim da Rotina
							

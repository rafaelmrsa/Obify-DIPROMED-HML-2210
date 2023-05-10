#Include "PROTHEUS.CH"
#Include "RWMAKE.CH"     
#INCLUDE "AP5MAIL.CH"   

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDIPAL40   บAutor  ณAlexandro Meier     บ Data ณ  10/10/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณCadastro de Pre็os dos Concorrentes                         บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function DIPAL40()

Private cCadastro	:= "Cadastro de pre็os dos concorrentes"
Private lRefresh	:= .T.
Private aHeader		:= {}
Private aCols		:= {}
Private cAlias		:= "UA5"  
Private cAntEdi     := "" 
Private aNewGrade   := {}
Private aProAlt     := {}  
Private ccEmail := Space(100)

Private aRotina		:= {{"Pesquisar" ,"AxPesqui"   , 0, 1},;
{"Visualizar"    ,"U_DI040Vis"  , 0, 2},;
{"Incluir"       ,"U_DI040"     , 0, 3},;
{"Alterar"       ,"U_DI040Alt"  , 0, 4},;
{"Excluir"       ,"U_DI040Exc"  , 0, 5},;
{"Envia Grade"   ,"U_DI040Grd"  , 0, 3},;
{"Por produto"   ,"U_DI040pro"  , 0, 2}}


U_DIPPROC(ProcName(0),U_DipUsr()) // MCVN 22/01/2009
mBrowse(,,,,cAlias,,,,,,)

Return(.T.)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDIPAL40   บAutor  ณAlexandro Meier     บ Data ณ  10/10/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function DI040(cAlias,nReg,nOpcx,nOpc)

Local nI 		:= 0
Local nUsado	:= 0
Local aArea		:= GetArea()
Local oDlg
Local nOpcA		:= 0


Private aGETS   := {}
Private aTELA   := {}
Private oGetDados
Private cEdital := space(06)
Private cOrgao  := space(50)
Private cRazao	:= space(40)
Private dDAbert	:= "  /  /  "
Private dDEncer	:= "  /  /  "
Private cConcor := space(30)
Private oCombo    


aHeader := {}
aCols	:= {}

/*IF !UA1->(BOF().and.EOF()).and. UA4->( !dbSeek(xFilial("UA4") + UA1->UA1_CODIGO))
   	Alert("Edital sem nenhum produto cadastrado!")
  	Return (.F.)
EndIF*/

RegToMemory(cAlias,.F.)
RegToMemory("UA1",.F.)
RegToMemory("UA4",.F.)

oDlg := MSDialog():New(020,00,600,760,cCadastro,,,,,CLR_BLACK,,,,.T.)

@15,10 To 70,380 Label Pixel OF oDlg

@22,20 Say "Edital" Pixel Of oDlg
@20,60 MSGet cEdital F3 "UA1" Valid u_load() Size 20,08 Pixel Of oDlg

@34,20 Say "Orgใo" Pixel Of oDlg
@32,60 MSGet cOrgao Size 150,08 When .F. Pixel Of oDlg

@46,20 Say "Abertura" Pixel Of oDlg
@44,60 MSGet dDAbert Size 30,08 When .F. Pixel Of oDlg

@46,100 Say "Encerramento" Pixel Of oDlg
@44,140 MSGet dDEncer Size 30,08 When .F. Pixel Of oDlg

@58,20 Say "Concorrente" Pixel Of oDlg
@56,60 MSGet cConcor Size 150,08 Valid !empty(cConcor) Picture "@!" Pixel Of oDlg


//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณMONTA O AHEADER DA GETDADOS							 ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
DbSelectArea("SX3")
DbSetOrder(1)
DbSeek("UA5")
While !Eof() .and. SX3->X3_ARQUIVO == "UA5"
	If X3Uso(SX3->X3_USADO) .and. cNivel >= SX3->X3_NIVEL
		If Trim(SX3->X3_CAMPO) <> "UA5_EDITAL" .AND.;
			Trim(SX3->X3_CAMPO) <> "UA5_CONCOR" //.AND.;
			//Trim(SX3->X3_CAMPO) <> "UA5_VENCEU"
			nUsado++
			Aadd(aHeader,{Trim(X3Titulo()),;
			Trim(SX3->X3_CAMPO),;
			SX3->X3_PICTURE,;
			SX3->X3_TAMANHO,;
			SX3->X3_DECIMAL,;
			SX3->X3_VALID,;
			"",;
			SX3->X3_TIPO,;
			"",;
			"" })
		EndIf
	EndIf
	DbSkip()
End

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณMONTA O ACOLS DA GETDADOS							 ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Aadd(aCols,Array(nUsado+1))

For nI := 1 To nUsado
	aCols[1][nI] := CriaVar(aHeader[nI][2])
Next
aCols[1][nUsado+1] := .F.

oGetDados    := MSGETDADOS():NEW(73,10,270,380,nOpcx,,,,.F.,{"UA5_PRCVEN","UA5_DETPRO","UA5_VENCEU","UA5_QTDOFE","UA5_MARMOD","UA5_OBSERV"}, ,.F.,200,,,,,oDlg)

ACTIVATE MSDIALOG oDlg CENTERED ON INIT ;
(EnchoiceBar(oDlg, {||nOpcA:=If(Obrigatorio(aGets,aTela), 1,0),If(nOpcA==1,oDlg:End(),Nil)},{|| If(Len(aNewGrade) > 0,	If(MsgBox("Deseja enviar grade agora? ","Atencao","YESNO"),(NewGrade(aNewGrade,nOpcx),oDlg:End()),oDlg:End()),oDlg:End())}))

If ( nOpcx == 3 .And. nOpcA == 1 )
	u_DI040Grv(nOpcx)
EndIf
Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDIPAL40   บAutor  ณAlexandro Meier     บ Data ณ  10/10/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณGrava os registros no UA5                                   บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function DI040Grv(nOpcx)

Local nPosCod
Local nL 	 := 0
Local cProdut
Local cDProdu
Local nQtdOfe:=0
Local cMarMod:=""
Local nPrcven 
Local nOldPrc
Local nAcols := 0
Local cTeste
Local nTam
Local nTam1
Local nVenceu  
Local cObserv:=""      



If (nOpcx == 3) // Inclui  

    // Alimenta Array para Envio de Email   MCVN - 18/07/2007
    If Ascan(aNewGrade, {|x| x[1] == cEdital}) == 0
	    aAdd(aNewGrade,{cEdital})
    Endif
	n := 1
	For nL := 1 To Len(aCols)
		
		If Len(alltrim(aCols[nL][1])) <> 0
			//Le as linhas da get dados para
			//pegar os registros nas colunas especificadas
			nPosCod := aScan(aHeader,{ |x| Upper(AllTrim(x[2])) == "UA5_PRODUT" })
			cProdut := aCols[n,nPosCod]
			nPosCod := aScan(aHeader,{ |x| Upper(AllTrim(x[2])) == "UA5_DPRODU" })
			cDProdu := aCols[n,nPosCod]                                           
			nPosCod := aScan(aHeader,{ |x| Upper(AllTrim(x[2])) == "UA5_MARMOD" })//MCVN - 17/07/2007
    		cMarMod := aCols[n,nPosCod]                                           
			nPosCod := aScan(aHeader,{ |x| Upper(AllTrim(x[2])) == "UA5_QTDOFE" })//MCVN - 17/07/2007
			nQtdOfe := aCols[n,nPosCod]
			nPosCod := aScan(aHeader,{ |x| Upper(AllTrim(x[2])) == "UA5_PRCVEN" }) 
			nPrcven := aCols[n,nPosCod]
			nPosCod := aScan(aHeader,{ |x| Upper(AllTrim(x[2])) == "UA5_VENCEU" })
			nVenceu := aCols[n,nPosCod] 
			nPosCod := aScan(aHeader,{ |x| Upper(AllTrim(x[2])) == "UA5_OBSERV" }) //MCVN - 18/09/2007
			cObserv := aCols[n,nPosCod] 
								
			RecLock("UA5",.T.)
			
			UA5->UA5_FILIAL	:= xFilial("UA5")
			UA5->UA5_EDITAL	:= cEdital
			UA5->UA5_CONCOR	:= cConcor
			UA5->UA5_PRODUT	:= cProdut
			UA5->UA5_MARMOD := cMarMod
			UA5->UA5_QTDOFE := nQtdOfe
			UA5->UA5_PRCVEN	:= nPrcven
			UA5->UA5_VENCEU	:= Iif(!Empty(Alltrim(nVenceu)),nVenceu,"2")
			UA5->UA5_OBSERV := cObserv //MCVN - 18/09/2007
			
			UA5->(dbSkip())
			
			n++
		EndIf
	Next nL
	MSUnlock()
Else
	If (nOpcx == 4) // Altera
		nPrcven  := 0 
		nOldPrc  := 0 
		cAntEdi := cEdital
		n := 1
		UA5->(dbSetOrder(1))
		nAcols := Len(aCols)
		while n <= nAcols
			If Len(alltrim(aCols[n][1])) <> 0
				//Le as linhas da get dados para
				//pegar os registros nas colunas especificadas
				nPosCod := aScan(aHeader,{ |x| Upper(AllTrim(x[2])) == "UA5_PRODUT" })
				cProdut := acols[n,nPosCod]
				
				UA5->(dbSeek(xFilial("UA5") + cEdital + cConcor + cProdut))
				
				nPosCod := aScan(aHeader,{ |x| Upper(AllTrim(x[2])) == "UA5_PRCVEN" })
				nPrcven := aCols[n,nPosCod]                                           
				nPosCod := aScan(aHeader,{ |x| Upper(AllTrim(x[2])) == "UA5_VENCEU" })
				nVenceu := aCols[n,nPosCod]
				nPosCod := aScan(aHeader,{ |x| Upper(AllTrim(x[2])) == "UA5_QTDOFE" })//MCVN - 17/07/2007
				nQtdOfe := aCols[n,nPosCod]
				nPosCod := aScan(aHeader,{ |x| Upper(AllTrim(x[2])) == "UA5_MARMOD" })//MCVN - 17/07/2007
				cMarMod := aCols[n,nPosCod]
				nPosCod := aScan(aHeader,{ |x| Upper(AllTrim(x[2])) == "UA5_OBSERV" })//MCVN - 18/09/2007
				cObserv := aCols[n,nPosCod]

				RecLock("UA5",.F.)
				If aCols[n,Len(aHeader)+1] //= .T.
					DbDelete()
				Else
			 		UA5->UA5_PRCVEN := nPrcven
					UA5->UA5_VENCEU	:= nVenceu
					UA5->UA5_QTDOFE := nQtdOfe		//MCVN - 17/07/2007
					UA5->UA5_MARMOD	:= cMarMod		//MCVN - 17/07/2007	
					UA5->UA5_OBSERV := cObserv      //MCVN - 18/09/2007
				Endif
				MSUnlock() 
			EndIf
			UA5->(dbSkip())
			n := n + 1  
			
		End             
		// Envia E-mail com Grade //MCVN - 18/07/2007
		If MsgBox("Deseja enviar grade agora? ","Atencao","YESNO")	
			EnviaGrade(cAntEdi,nOpcx)
			cAntEdi := ""
		Else             
			cAntEdi := ""
		Endif
	EndIf
	
	If (nOpcx == 5) // Exclui
		Begin Transaction
		n := 1
		UA5->(dbSetOrder(1))
		nAcols := Len(aCols)
		while n <= nAcols
			//Le as linhas da get dados para
			//pegar os registros nas colunas especificadas
			nPosCod := aScan(aHeader,{ |x| Upper(AllTrim(x[2])) == "UA5_PRODUT" })
			cProdu := acols[n,nPosCod]
			
			UA5->(dbSeek(xFilial("UA5") + cEdital + cConcor + cProdu))
			
			RecLock("UA5",.F.) 	
			dbDelete()                      	
			
			UA5->(dbSkip())
			n := n + 1
		End
		End Transaction
		
		If __lSX8
			ConfirmSX8()
		EndIf
		
		MSUnlock()
	EndIf
EndIf
Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDIPAL40   บAutor  ณAlexandro Meier     บ Data ณ  10/10/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณVisualiza o registro selecionado no MBrowse                 บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function DI040Vis(cAlias,nReg,nOpcx,nOpc)

Local cArea		:= GetArea()
Local nUsado	:= 0
Local nOpcA		:= 0
Local cEdUA1	:= ""
Local nCntFor2	:= 0
Local aGETS		:= {}
Local aTELA		:= {}
Local cOrg		:= ""
Local dAber
Local dEnce
Local oDlg2
Local nHItem 	:= 0
Local nAItem 	:= 0
Local cConcor	:= ""
Local cEdital	:= ""


aCols   := {}
aHeader := {}

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณMONTA O AHEADER DA GETDADOS							 ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
SX3->( dbSetOrder(1) )
SX3->( DbSeek("UA5") )
While !Eof() .and. SX3->X3_ARQUIVO == "UA5"
	If X3Uso(SX3->X3_USADO) .and. cNivel >= SX3->X3_NIVEL
		If Trim(SX3->X3_CAMPO) <> "UA5_EDITAL" .AND.;
			Trim(SX3->X3_CAMPO) <> "UA5_CONCOR" //.AND.;
			//Trim(SX3->X3_CAMPO) <> "UA5_VENCEU"
			nUsado++
			Aadd(aHeader,{Trim(X3Titulo()),;
			Trim(SX3->X3_CAMPO),;
			SX3->X3_PICTURE,;
			SX3->X3_TAMANHO,;
			SX3->X3_DECIMAL,;
			SX3->X3_VALID,;
			SX3->X3_USADO,;
			SX3->X3_TIPO,;
			SX3->X3_ARQUIVO,;
			SX3->X3_CONTEXT } )
		EndIf
	EndIf
	SX3->(DbSkip() )
End

oDlg2 := MSDialog():New(020,00,600,760,cCadastro,,,,,CLR_BLACK,,,,.T.)

cConcor	  := UA5->UA5_CONCOR
cEdital   := UA5->UA5_EDITAL

UA1->(dbSetOrder(1))
UA1->(dbSeek(xFilial("UA1") + cEdital))

cEdUA1 := UA1->UA1_CODIGO
//cOrg   := UA1->UA1_ORGAO
cOrg   := MSMM(UA1->UA1_ORGM,,,,3)
dAber  := UA1->UA1_DABERT
dEnce  := UA1->UA1_DENCER

UA5->(dbSetOrder(1))
UA5->(dbSeek(xFilial("UA5") + cEdUA1 + cConcor))

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณMONTA O ACOLS DA GETDADOSณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
While !UA5->(EOF()) .And. UA5->(UA5_FILIAL) == xFilial("UA5") .And.;
	cEdUA1 == UA5->UA5_EDITAL .AND. cConcor == UA5->UA5_CONCOR
	
	AADD(aCols,Array(Len(aHeader) + 1))
	For nCntFor2 := 1 To Len(aHeader)
		If ( aHeader[nCntFor2][10] != "V" )
			aCols[Len(aCols)][nCntFor2] := FieldGet(FieldPos(aHeader[nCntFor2][2]))
		Else
			aCols[Len(aCols)][nCntFor2] := CriaVar(aHeader[nCntFor2][2])
		EndIf
	Next nCntFor2
	
	aCols[Len(aCols)][Len(aHeader)+1] := .F.
	
	UA5->(dbSkip())
	
EndDo

@15,10 To 70,380 Label Pixel OF oDlg2

@22,20 Say "Edital" Pixel Of oDlg2
@20,60 MSGet cEdital Size 20,08 When .F. Pixel Of oDlg2

@34,20 Say "Orgใo" Pixel Of oDlg2
@32,60 MSGet cOrg Size 150,08 When .F. Pixel Of oDlg2

@46,20 Say "Abertura" Pixel Of oDlg2
@44,60 MSGet dAber Size 30,08 When .F. Pixel Of oDlg2

@46,100 Say "Encerramento" Pixel Of oDlg2
@44,140 MSGet dEnce Size 30,08 When .F. Pixel Of oDlg2

@58,20 Say "Concorrente" Pixel Of oDlg2
@56,60 MSGet cConcor Size 150,08 Picture "@!" When .F. Pixel Of oDlg2

oGetDados := MSGETDADOS():NEW(73,10,270,380,nOpcx,,,,.F.,, ,.F.,200,,,,,oDlg2)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณVERIFICA SE EXITEM GATILHOS                           ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
For nAItem := 1 to Len(aCols)
	For nHItem := 1 to Len(aHeader)
		If ExistTrigger(aHeader[nHitem][2])
			RunTrigger(2, nAItem)
		EndIF
	Next nHItem
Next nAItem

oGetDados:ForceRefresh()

ACTIVATE MSDIALOG oDlg2 CENTERED ON INIT ;
EnchoiceBar(oDlg2, {||nOpcA:=If(Obrigatorio(aGets,aTela), 1,0),If(nOpcA==1,oDlg2:End(),oDlg2:End())},{||oDlg2:End()})

RestArea(cArea)

Return(.T.)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDIPAL40   บAutor  ณAlexandro Meier     บ Data ณ  10/24/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณAltera o registro selecionado no MBrowse                    บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function DI040Alt(cAlias,nReg,nOpcx,nOpc)

Local cArea		:= GetArea()
Local nUsado	:= 0
Local nOpcA		:= 0
Local nCntFor2	:= 0
Local nItem		:= 0
Local aGETS		:= {}
Local aTELA		:= {}
Local oDlg2
Local cEdUA1	:= ""
Local nHItem    := 0
Local nAItem    := 0
Private oGetDados

aCols   := {}
aHeader := {}       
aProAlt := {}
cEdital := ""
cOrgao 	:= ""
cConcor	:= ""

RegToMemory("UA5",.F.)
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณMONTA O AHEADER DA GETDADOSณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
SX3->( dbSetOrder(1) )
SX3->( DbSeek("UA5") )
While !Eof() .and. SX3->X3_ARQUIVO == "UA5"
	If X3Uso(SX3->X3_USADO) .and. cNivel >= SX3->X3_NIVEL
		If Trim(SX3->X3_CAMPO) <> "UA5_EDITAL" .AND.;
			Trim(SX3->X3_CAMPO) <> "UA5_CONCOR" //.AND.;
			//Trim(SX3->X3_CAMPO) <> "UA5_VENCEU"
			nUsado++
			Aadd(aHeader,{Trim(X3Titulo()),;
			Trim(SX3->X3_CAMPO),;
			SX3->X3_PICTURE,;
			SX3->X3_TAMANHO,;
			SX3->X3_DECIMAL,;
			SX3->X3_VALID,;
			SX3->X3_USADO,;
			SX3->X3_TIPO,;
			SX3->X3_ARQUIVO,;
			SX3->X3_CONTEXT } )
		EndIf
	EndIf
	SX3->(DbSkip() )
End


oDlg2 := MSDialog():New(020,00,600,760,cCadastro,,,,,CLR_BLACK,,,,.T.)

cEdital  := UA5->UA5_EDITAL
cConcor  := UA5->UA5_CONCOR

UA1->(dbSetOrder(1))
UA1->(dbSeek(xFilial("UA1") + cEdital))

cEdUA1 := UA1->UA1_CODIGO
//cOrgao  := UA1->UA1_ORGAO
cOrgao  := MSMM(UA1->UA1_ORGM,,,,3)
dDabert := UA1->UA1_DABERT
dDencer := UA1->UA1_DENCER

UA5->(dbSetOrder(1))
UA5->(dbSeek(xFilial("UA5") + cEdUA1 + cConcor))

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณMONTA O ACOLS DA GETDADOSณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
While !UA5->(EOF()) .And. UA5->(UA5_FILIAL) == xFilial("UA5") .And.;
	cEdUA1 == UA5->UA5_EDITAL .AND. cConcor == UA5->UA5_CONCOR         
	
	AADD(aProAlt,{UA5->UA5_PRODUT,cConcor,UA5_PRCVEN}) // MCVN - 18/07/2007
	AADD(aCols,Array(Len(aHeader) + 1))
	For nCntFor2 := 1 To Len(aHeader)
		If ( aHeader[nCntFor2][10] != "V" )
			aCols[Len(aCols)][nCntFor2] := FieldGet(FieldPos(aHeader[nCntFor2][2]))
		Else
			aCols[Len(aCols)][nCntFor2] := CriaVar(aHeader[nCntFor2][2])
		EndIf
	Next nCntFor2
	
	aCols[Len(aCols)][Len(aHeader)+1] := .F.
	
	UA5->(dbSkip())
	
EndDo

@15,10 To 70,380 Label Pixel OF oDlg2

@22,20 Say "Edital" Pixel Of oDlg2
@20,60 MSGet cEdital Size 20,08 When .F. Pixel Of oDlg2

@34,20 Say "Orgใo" Pixel Of oDlg2
@32,60 MSGet cOrgao Size 150,08 When .F. Pixel Of oDlg2

@46,20 Say "Abertura" Pixel Of oDlg2
@44,60 MSGet dDabert Size 30,08 When .F. Pixel Of oDlg2

@46,100 Say "Encerramento" Pixel Of oDlg2
@44,140 MSGet dDencer Size 30,08 When .F. Pixel Of oDlg2

@58,20 Say "Concorrente" Pixel Of oDlg2
@56,60 MSGet cConcor Size 150,08 Picture "@!" When .F. Pixel Of oDlg2

oGetDados := MSGETDADOS():NEW(73,10,270,380,nOpcx,,,,.T.,{"UA5_PRCVEN","UA5_DETPRO","UA5_VENCEU","UA5_QTDOFE","UA5_MARMOD","UA5_OBSERV"}, ,.F.,200,,,,,oDlg2)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณVERIFICA SE EXITEM GATILHOS                           ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
For nAItem := 1 to Len(aCols)
	For nHItem := 1 to Len(aHeader)
		If ExistTrigger(aHeader[nHitem][2])
			RunTrigger(2, nAItem)
		EndIF
	Next nHItem
Next nAItem

oGetDados:ForceRefresh()

ACTIVATE MSDIALOG oDlg2 CENTERED ON INIT ;
EnchoiceBar(oDlg2, {||nOpcA:=If(Obrigatorio(aGets,aTela), 1,0),If(nOpcA==1,oDlg2:End(),oDlg2:End())},{||oDlg2:End()})

If (nOpcx == 4 .and. nOpcA == 1 )
	u_DI040Grv(nOpcx)
EndIf

RestArea(cArea)

Return(.T.)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDIPAL40   บAutor  ณAlexandro Meier     บ Data ณ  10/24/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณExclui o registro selecionado no MBrowse                    บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function DI040Exc(cAlias,nReg,nOpcx,nOpc)

Local cArea		:= GetArea()
Local nUsado	:= 0
Local oCombo2
Local nOpcA		:= 0
Local nCntFor2	:= 0
Local nItem		:= 0
Local aGETS		:= {}
Local aTELA		:= {}
Local cOrg		:= ""
Local dAber
Local dEnce

Local oGetDados
Local oDlg2
Local cEdUA1	:= ""
Local cProd     := ""
Local nHItem	:= 0
Local nAItem	:= 0

aCols := {}
aHeader := {}

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณMONTA O AHEADER DA GETDADOSณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
SX3->( dbSetOrder(1) )
SX3->( DbSeek("UA5") )
Do While !Eof() .and. SX3->X3_ARQUIVO == "UA5"
	If X3Uso(SX3->X3_USADO) .and. cNivel >= SX3->X3_NIVEL
		If Trim(SX3->X3_CAMPO) <> "UA5_EDITAL" .AND.;
			Trim(SX3->X3_CAMPO) <> "UA5_CONCOR" //.AND.;
			//Trim(SX3->X3_CAMPO) <> "UA5_VENCEU"
			nUsado++
			Aadd(aHeader,{Trim(X3Titulo()),;
			Trim(SX3->X3_CAMPO),;
			SX3->X3_PICTURE,;
			SX3->X3_TAMANHO,;
			SX3->X3_DECIMAL,;
			SX3->X3_VALID,;
			SX3->X3_USADO,;
			SX3->X3_TIPO,;
			SX3->X3_ARQUIVO,;
			SX3->X3_CONTEXT } )
		EndIf
	EndIf
	SX3->(DbSkip() )
End

oDlg2 := MSDialog():New(020,00,600,760,cCadastro,,,,,CLR_BLACK,,,,.T.)

cConcor := UA5->UA5_CONCOR
cEdital := UA5->UA5_EDITAL
cProd	:= UA5->UA5_PRODUT

UA1->(dbSetOrder(1))
UA1->(dbSeek(xFilial("UA1") + cEdital))

cEdUA1:= UA1->UA1_CODIGO
//cOrg   := UA1->UA1_ORGAO
cOrg  := MSMM(UA1->UA1_ORGM,,,,3)
dAber  := UA1->UA1_DABERT
dEnce  := UA1->UA1_DENCER

UA5->(dbSetOrder(1))
UA5->(dbSeek(xFilial("UA5") + cEdUA1 + cConcor))

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณMONTA O ACOLS DA GETDADOSณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
While !UA5->(EOF()) .And. UA5->(UA5_FILIAL) == xFilial("UA5") .And.;
	cEdUA1 == UA5->UA5_EDITAL .AND. cConcor == UA5->UA5_CONCOR
	                                    
	AADD(aCols,Array(Len(aHeader) + 1))
	For nCntFor2 := 1 To Len(aHeader)
		If ( aHeader[nCntFor2][10] != "V" )
			aCols[Len(aCols)][nCntFor2] := FieldGet(FieldPos(aHeader[nCntFor2][2]))
		Else
			aCols[Len(aCols)][nCntFor2] := CriaVar(aHeader[nCntFor2][2])
		EndIf
	Next nCntFor2
	
	aCols[Len(aCols)][Len(aHeader)+1] := .F.
	
	UA5->(dbSkip())
	
EndDo

@15,10 To 70,380 Label Pixel OF oDlg2

@22,20 Say "Edital" Pixel Of oDlg2
@20,60 MSGet cEdital Size 20,08 When .F. Pixel Of oDlg2

@34,20 Say "Orgใo" Pixel Of oDlg2
@32,60 MSGet cOrg Size 150,08 When .F. Pixel Of oDlg2

@46,20 Say "Abertura" Pixel Of oDlg2
@44,60 MSGet dAber Size 30,08 When .F. Pixel Of oDlg2

@46,100 Say "Encerramento" Pixel Of oDlg2
@44,140 MSGet dEnce Size 30,08 When .F. Pixel Of oDlg2

@58,20 Say "Concorrente" Pixel Of oDlg2
@56,60 MSGet cConcor Size 150,08 Picture "@!" When .F. Pixel Of oDlg2

oGetDados := MSGETDADOS():NEW(73,10,270,380,nOpcx,,,,.T.,, ,.F.,200,,,,,oDlg2)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณVERIFICA SE EXITEM GATILHOS                           ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
For nAItem := 1 to Len(aCols)
	For nHItem := 1 to Len(aHeader)
		If ExistTrigger(aHeader[nHitem][2])
			RunTrigger(2, nAItem)
		EndIF
	Next nHItem
Next nAItem

oGetDados:ForceRefresh()

ACTIVATE MSDIALOG oDlg2 CENTERED ON INIT ;
(EnchoiceBar(oDlg2, {||nOpcA:=If(Obrigatorio(aGets,aTela), 1,0),If(nOpcA==1,oDlg2:End(),oDlg2:End())},{||oDlg2:End()}))

If ( nOpcx == 5 .and. nOpcA == 1 )
	u_DI040Grv(nOpcx)
EndIf

RestArea(cArea)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDIPAL40   บAutor  ณAlexandro Meier     บ Data ณ  10/10/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณCarrega os produtos na GetDados do edital selecionado       บฑฑ
ฑฑบ          ณna op็ao de inclusao                                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function load()

//Local nCntFor2  := 1

UA1->(dbSetOrder(1))
UA1->(dbSeek(xFilial("UA1") + cEdital))

cOrgao  := MSMM(UA1->UA1_ORGM,,,,3)
dDAbert := UA1->UA1_DABERT
dDEncer := UA1->UA1_DENCER

dbSelectArea("UA4")
UA4->(dbSetOrder(1))
If !UA4->(dbSeek(xFilial("UA4") + UA1->UA1_CODIGO))
	Alert("Edital sem nenhum produto cadastrado!")
  	Return (.F.)
EndIF
	
UA4->(dbSeek(xFilial("UA4") + UA1->UA1_CODIGO))

If Len(aCols) >= 1
	aCols := {}
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณMONTA O ACOLS DA GETDADOS							 ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
While !UA4->( EOF()) .And. UA4->UA4_FILIAL == xFilial("UA4") .And. UA4->UA4_EDITAL == UA1->UA1_CODIGO
	
	AADD(aCols,Array(Len(aHeader) + 1))
	
	aCols[Len(aCols)][1] := UA4->UA4_PRODUT //PRODUTO   
	aCols[Len(aCols)][3] := SPACE(20)       //MARCA/MODELO - MCVN - 18/07/2007
	aCols[Len(aCols)][4] := UA4->UA4_QUANT  //QUANTIDADE - MCVN - 18/07/2007

    If Empty(UA4->UA4_VENCEU)  
		aCols[Len(aCols)][5] := 0
		aCols[Len(aCols)][6] := "2"
	Else
        aCols[Len(aCols)][5] := UA4->UA4_PRCVEN//PRECO
		aCols[Len(aCols)][6] := UA4->UA4_VENCEU //VENCEU?
	EndIf  

	aCols[Len(aCols)][7] := SPACE(60)
	aCols[Len(aCols)][Len(aHeader)+1] := .F.
	
	UA4->(dbSkip())
	
EndDo

oGetDados:ForceRefresh()

U_DI040TG()

UA4->(dbclosearea())

dbSelectArea("UA1")

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDIPAL40   บAutor  ณAlexandro Meier     บ Data ณ  10/10/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณVerifca se existe gatilhos e executa-os                     บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function DI040TG()

Local nHItem
Local nAItem

For nAItem := 1 to Len(aCols)
	For nHItem := 1 to Len(aHeader)
		If ExistTrigger(aHeader[nHitem][2])
			RunTrigger(2, nAItem)
		EndIF
	Next nHItem
Next nAItem

oGetDados:ForceRefresh()

Return (.T.)

User Function DTG()

Local nHItem
Local nAItem

aCols	:= ogetdados:aCols
aHeader	:= ogetdados:aHeader

For nAItem := 1 to Len(aCols)
	For nHItem := 1 to Len(aHeader)
		If ExistTrigger(aHeader[nHitem][2])
			RunTrigger(2, nAItem)
		EndIF
	Next nHItem
Next nAItem

oGetDados:ForceRefresh()

Return (.T.)
              


*------------------------------*
// Envia e-mail com a Grade incluida no sistema  
// MCVN - 19/07/2007
Static Function NewGrade(aEnvGrade,nOpcx)  

Default aEnvGrade := {}

	For mm := 1 to Len(aEnvGrade) 
		If nOpcx == 8
			If Upper(Posicione("SB1",1,xFilial("SB1")+aEnvGrade[mm,1],"B1_PROC")) $ ('000041/000609')
		 		EnviaGrade(aEnvGrade[mm,1],nOpcx)
		    Else
		    	//Aviso('Aten็ใo','Grade por produtos somente para o fornecedor 3M!',{'Ok'})// 
		    	EnviaGrade(aEnvGrade[mm,1],nOpcx) // Habilitado o envio para todos fornecedores(autorizado pelo Eriberto dia 14/07/09) MCVN - 14/07/09
		    Endif
		Else                                 
			EnviaGrade(aEnvGrade[mm,1],nOpcx)
		EndIf
	Next mm

    EnviaGrade :={}
Return(.T.)
		


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDIPAGRD   บAutor  ณMaximo Canuto       บ Data ณ  07/12/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณEnvia Grade por produto ou por edital                       บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออ  ออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function DI040Grd(cAlias,nReg,nOpcx,nOpc)

Local cArea		:= GetArea()
Local nOpcA		:= 0
Local nCntFor2	:= 0
Local nItem		:= 0    
Local nOpcao    := 0        
Local bOK       := {|| nOpcao := 1, oDlg:End()}
Local bCancel   := {|| nOpcao := 0, oDlg:End()}
Local cGrade    := Space(100)
Local aItens	:= {}
Local aGrade	:= {}
Local cGetEdital := ""
Local aNewGrade := {}
Private cTpOrd  := 1
Private nRdo := 1   
aAdd(aItens,"Grade por Edital")
aAdd(aItens,"Grade por Produto")

   While nOpcao = 0
   

	nRdo := 1
	nOpcao := 0

	Define msDialog oDlg Title "Envio de Grade" From 00,00 TO 14,70


	@ 015,020 RADIO aItens VAR nRdo
	@ 040,010 Say "Informe o c๓digo do Edital ou do produto (Separados por vํrgula(,). "
	@ 050,010 Get cGrade Size 250,20 Valid !Empty(cGrade) 
	@ 065,010 Say "Informe o E-mail (Separados por ponto e vํrgula(;). "
	@ 075,010 Get ccEmail Size 250,20 Valid !Empty(ccEmail) 	
	Activate Dialog oDlg Centered on init EnchoiceBar(oDlg,bOk,bCancel)                   
    	      	   
	Do Case
		Case nOpcao == 0
			Exit
		Case nRdo == 1          
 
			cGetEdital := ""
			j:=1
 			For i := 1 to (Len(Alltrim(cGrade))+1)/7   //MCVN   
	    
    			If i = (Len(Alltrim(cGrade))+1)/7
    				cGetEdital   := subs(cGrade,j,6)
 	   				If Ascan(aNewGrade, {|x| x[1] == cGetEdital}) == 0
		   				aAdd(aNewGrade,{cGetEdital})
					Endif
    			Else  
    				cGetEdital   := subs(cGrade,j,6)
 	   				If Ascan(aNewGrade, {|x| x[1] == cGetEdital}) == 0
		   				aAdd(aNewGrade,{cGetEdital})
					Endif
	    	   	Endif
   				j := j+7
		    Next  

			cTpOrd := 6
			NewGrade(aNewGrade,cTpOrd)
		Case nRdo == 2  
		
			cGetEdital := ""
			j:=1
 			For i := 1 to (Len(Alltrim(cGrade))+1)/7   //MCVN   
	    
    			If i = (Len(Alltrim(cGrade))+1)/7
    				cGetEdital   := subs(cGrade,j,6)
 	   				If Ascan(aNewGrade, {|x| x[1] == cGetEdital}) == 0
		   				aAdd(aNewGrade,{cGetEdital})
					Endif
    			Else  
    				cGetEdital   := subs(cGrade,j,6)
 	   				If Ascan(aNewGrade, {|x| x[1] == cGetEdital}) == 0
		   				aAdd(aNewGrade,{cGetEdital})
					Endif
	    	   	Endif
   				j := j+7   				                                                                       
		    Next  		      
		             
			cTpOrd := 8			
			NewGrade(aNewGrade,cTpOrd)
	EndCase
	
 Enddo   
                      
 Return()


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDIPAPRO   บAutor  ณMaximo Canuto       บ Data ณ  10/12/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณEnvia Grade por produto ou por edital                       บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออ  ออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function DI040pro(cAlias,nReg,nOpcx,nOpc)

Local cArea		:= GetArea()
Local nUsado	:= 0
Local nOpcA		:= 0
Local cEdUA1	:= ""
Local nCntFor2	:= 0
Local aGETS		:= {}
Local aTELA		:= {}
Local cOrg		:= ""
Local dAber
Local dEnce
Local oDlg2
Local nHItem 	:= 0
Local nAItem 	:= 0
Local cProdut	:= ""
Local cDesPro	:= ""           


aCols   := {}
aHeader := {}

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณMONTA O AHEADER DA GETDADOS							 ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
SX3->( dbSetOrder(1) )
SX3->( DbSeek("UA5") )
While !Eof() .and. SX3->X3_ARQUIVO == "UA5"
	If X3Uso(SX3->X3_USADO) .and. cNivel >= SX3->X3_NIVEL
		If Trim(SX3->X3_CAMPO) <> "UA5_PRODUT" .AND.;
			Trim(SX3->X3_CAMPO) <> "UA5_DPRODU" //.AND.;
			//Trim(SX3->X3_CAMPO) <> "UA5_VENCEU" 
			nUsado++
			Aadd(aHeader,{Trim(X3Titulo()),;
			Trim(SX3->X3_CAMPO),;
			SX3->X3_PICTURE,;
			SX3->X3_TAMANHO,;
			SX3->X3_DECIMAL,;
			SX3->X3_VALID,;
			SX3->X3_USADO,;
			SX3->X3_TIPO,;
			SX3->X3_ARQUIVO,;
			SX3->X3_CONTEXT } )
		EndIf
	EndIf
	SX3->(DbSkip() )
End

oDlg2 := MSDialog():New(020,00,600,760,cCadastro,,,,,CLR_BLACK,,,,.T.)

cProdut	  := UA5->UA5_PRODUT
cDesPro   := Upper(Posicione("SB1",1,xFilial("SB1")+UA5->UA5_PRODUT,"B1_DESC"))


UA5->(dbSetOrder(4))
UA5->(dbSeek(xFilial("UA5") + cProdut))

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณMONTA O ACOLS DA GETDADOSณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
While !UA5->(EOF()) .And. UA5->(UA5_FILIAL) == xFilial("UA5") .And. cProdut == UA5->UA5_PRODUT
	
	AADD(aCols,Array(Len(aHeader) + 1))
	For nCntFor2 := 1 To Len(aHeader)
		If ( aHeader[nCntFor2][10] != "V" )
			aCols[Len(aCols)][nCntFor2] := FieldGet(FieldPos(aHeader[nCntFor2][2]))
		Else
			aCols[Len(aCols)][nCntFor2] := CriaVar(aHeader[nCntFor2][2])
		EndIf
	Next nCntFor2
	
	aCols[Len(aCols)][Len(aHeader)+1] := .F.
	
	UA5->(dbSkip())
	
EndDo

@15,10 To 55,380 Label Pixel OF oDlg2

@22,20 Say "Produto" Pixel Of oDlg2
@20,60 MSGet cProdut Size 33,08 When .F. Pixel Of oDlg2

@34,20 Say "Descri็ใo" Pixel Of oDlg2
@32,60 MSGet cDesPro Size 250,08 When .F. Pixel Of oDlg2

//@46,20 Say "Abertura" Pixel Of oDlg2
//@44,60 MSGet dAber Size 30,08 When .F. Pixel Of oDlg2

//@46,100 Say "Encerramento" Pixel Of oDlg2
//@44,140 MSGet dEnce Size 30,08 When .F. Pixel Of oDlg2

//@58,20 Say "Concorrente" Pixel Of oDlg2
//@56,60 MSGet cConcor Size 150,08 Picture "@!" When .F. Pixel Of oDlg2

oGetDados := MSGETDADOS():NEW(60,10,270,380,nOpcx,,,,.F.,, ,.F.,200,,,,,oDlg2)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณVERIFICA SE EXITEM GATILHOS                           ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
For nAItem := 1 to Len(aCols)
	For nHItem := 1 to Len(aHeader)
		If ExistTrigger(aHeader[nHitem][2])
			RunTrigger(2, nAItem)
		EndIF
	Next nHItem
Next nAItem

oGetDados:ForceRefresh()

ACTIVATE MSDIALOG oDlg2 CENTERED ON INIT ;
EnchoiceBar(oDlg2, {||nOpcA:=If(Obrigatorio(aGets,aTela), 1,0),If(nOpcA==1,oDlg2:End(),oDlg2:End())},{||oDlg2:End()})

RestArea(cArea)

Return(.T.)



*------------------------------*
// Envia e-mail com a Grade incluida no sistema  
// MCVN - 18/07/2007
Static Function EnviaGrade(cNumEdital,nOpcx)
*------------------------------*
Local cAccount:=Lower(Alltrim(GetMv('MV_RELACNT')))
Local cFrom:= Lower(Alltrim(GetMv('MV_RELACNT')))
Local cPassword:=alltrim(GetMv('MV_RELPSW'))
Local cServer:=alltrim(GetMv('MV_RELSERV'))
Local lResult:=.F.
Local cError:=''
Local cMsg:=''
Local cAssunto:=''   
Local cAssuntob:=''
Local cTo  := ''
Local cBCC := 'publico@dipromed.com.br'
Local aContaUsuarios := U_Dip40Usuario('MV_WFDIRVE')   
Local aGrade := {}
Local cPontoVirgual:='' 
Local cProdAnt := ""   
Local nNovoVAlor := 0 
Local cPProd     := 0
Local cProduto   := ""
Local cDestMailG := 0  
LOCAL lSmtpAuth := GetNewPar("MV_RELAUTH",.F.)
LOCAL lAutOk	:= .F.

Default cNumEdital := ""
  
PswOrder(2)

cDestMailG :=Aviso("Aten็ใo","Escolha a op็ใo de envio da grade ?" ,{"Operadora","Publico"})
If cDestMailG == 1
	cBCC := Alltrim(Posicione("SU7",6,xFilial("SU7")+U_DipUsr(),"U7_EMAIL")) // MCVN - 10/07/2007
Endif

cDestMailG := 0	


If nOpcx <> 8 
    cTo := If(!Empty(Alltrim(cTo)),cTo+";"+Alltrim(ccEmail),Alltrim(ccEmail))
	UA1->(dbSetOrder(1))
	UA1->(dbSeek(xFilial("UA1") + cNumEdital))

	cCliente:=UA1->UA1_CODCLI
	cLoja   :=UA1->UA1_LOJA
	cNomeCli:=Upper(Posicione("SA1",1,xFilial("SA1")+ cCliente + cLoja,"A1_NOME"))

 //	DbSelectArea("UA5")                                 
	UA5->(dbSetOrder(1))                                
	UA5->(DbGotop())
	UA5->(dbSeek(xFilial("UA5") + cNumEdital))   
	
   While !UA5->(EOF()) .And. UA5->(UA5_FILIAL) == xFilial("UA5") .And.	cNumEdital == UA5->UA5_EDITAL 
	   cDesc:=Upper(Posicione("SB1",1,xFilial("SB1")+UA5->UA5_PRODUT,"B1_DESC"))
	   aAdd(aGrade,{UA5->UA5_EDITAL, UA5->UA5_PRODUT, cDesc, UA5->UA5_QTDOFE, UA5->UA5_PRCVEN, UA5->UA5_CONCOR, UA5->UA5_MARMOD, UA5->UA5_VENCEU,"",UA5->UA5_OBSERV})
   	   UA5->(DbSkip())
   Enddo
Else
	cProduto:= cNumEdital+Space(9)                                                                           
	cCliente:= ""
	cLoja   := ""
	cNomeCli:= ""
	cPregao := ""
	cDesc   := ""
   
   //	DbSelectArea("UA5")                                 
	UA5->(dbSetOrder(4))                                
	UA5->(DbGotop())
	UA5->(dbSeek(xFilial("UA5") + cProduto))   			
	
	While !UA5->(EOF()) .And. UA5->(UA5_FILIAL) == xFilial("UA5") .And.	cProduto == UA5->UA5_PRODUT
	   cDesc    :=Upper(Posicione("SB1",1,xFilial("SB1")+UA5->UA5_PRODUT,"B1_DESC"))
	   cCliente :=Upper(Posicione("UA1",1,xFilial("UA1")+UA5->UA5_EDITAL,"UA1_CODCLI"))
	   cLoja    :=Upper(Posicione("UA1",1,xFilial("UA1")+UA5->UA5_EDITAL,"UA1_LOJA"))
	   cNomeCli :=Upper(Posicione("SA1",1,xFilial("SA1")+cCliente+cLoja,"A1_NOME")) 
	   cPregao  :=Upper(Posicione("UA1",1,xFilial("UA1")+UA5->UA5_EDITAL,"UA1_NRCONC"))
	   
	   aAdd(aGrade,{UA5->UA5_EDITAL, UA5->UA5_PRODUT, cDesc, UA5->UA5_QTDOFE, UA5->UA5_PRCVEN, UA5->UA5_CONCOR, UA5->UA5_MARMOD, UA5->UA5_VENCEU,"",UA5->UA5_OBSERV,cCliente,cNomeCli,cPregao})
	   UA5->(DbSkip())
   Enddo
   
Endif




UA5->(DbCloseArea())

aSort( aGrade ,,, {|a,b| a[2]+a[8]+strzero(a[5],12,4) < b[2]+b[8]+strzero(b[5],12,4)} )
//aSort( aGrade ,,, {|a,b| a[5] < b[5]} )

If nOpcx == 3
	cAssunto := EncodeUTF8('Licita็ใo - Cadastro de Grade do Edital '+cNumEdital+' do Cliente '+cCliente+'-'+cLoja+' - '+cNomeCli+'.',"cp1252")
	cAssuntob:= 'Licita็ใo - Cadastro de Grade do Edital '+cNumEdital+' do Cliente '+cCliente+'-'+cLoja+' - '+cNomeCli+'.'
ElseIf nOpcx == 4
	cAssunto := EncodeUTF8('Licita็ใo - Altera็ใo de Grade do Edital '+cNumEdital+' do Cliente '+cCliente+'-'+cLoja+' - '+cNomeCli+'.',"cp1252")
	cAssuntob:= 'Licita็ใo - Altera็ใo de Grade do Edital '+cNumEdital+' do Cliente '+cCliente+'-'+cLoja+' - '+cNomeCli+'.'
ElseIf nOpcx == 6                                                                                                          
	cAssunto := EncodeUTF8('Licita็ใo - Grade do Edital '+cNumEdital+' do Cliente '+cCliente+'-'+cLoja+' - '+cNomeCli+'.',"cp1252")
	cAssuntob:= 'Licita็ใo - Grade do Edital '+cNumEdital+' do Cliente '+cCliente+'-'+cLoja+' - '+cNomeCli+'.'
ElseIf nOpcx == 8   
	aSort( aGrade ,,, {|a,b| a[11]+a[12] < b[11]+b[12] } )
    cAssunto := EncodeUTF8('Licita็ใo - Grade por Produto ' + cProduto + ' - ' + Upper(Posicione("SB1",1,xFilial("SB1")+cProduto,"B1_DESC")),"cp1252")
    cAssuntob:= 'Licita็ใo - Grade por Produto ' + cProduto + ' - ' + Upper(Posicione("SB1",1,xFilial("SB1")+cProduto,"B1_DESC"))
Endif

//--------------------------------------------------------------------------
// Definicao do cabecalho do email
//--------------------------------------------------------------------------
cMsg := '<html>'
cMsg += '<head>'
cMsg += '<title>'+cAssunto+'</title>'
cMsg += '</head>'
cMsg += '<body>'
cMsg += '<HR Width=100% Size=4 Align=Centered Color=Red>'
cMsg += '<Table Align=Center BorderColor=#000000 CELLPADDING=4 CELLSPACING=0 Width=100%>'
//-------------------------------------------------------------------------
// Definicao do cabecalho do relat๓rio
//-------------------------------------------------------------------------
cMsg += '<table width="100%">'
cMsg += '  <tr>'
cMsg += '     <td width="100%"><font size="3" color="blue">'+cAssuntob+'</font></td>'
cMsg += '  </tr>'
cMsg += '</table> <P>'
cMsg += '<table width="100%" cellspacing="0" cellpadding="0"><font size="1" color="blue">'
//-------------------------------------------------------------------------
// Definicao do texto/detalhe do email
//-------------------------------------------------------------------------

If nOpcx <> 8

	cMsg += '<table width="100%" border="2" cellspacing="0" cellpadding="0">'
	cMsg += '   <tr>'
	cMsg += '      <td width="20%" align="left"><font size="2" Face="Arial Black">CONCORRENTE</font></td>'	
	cMsg += '      <td width="10%" align="left"><font size="2" Face="Arial Black">PRODUTO</font></td>'	
	cMsg += '      <td width="40%" align="left"><font size="2" Face="Arial Black">DESCRIวรO</font></td>'	
	cMsg += '      <td width="15%" align="left"><font size="2" Face="Arial Black">QUANT</font></td>'	
	cMsg += '      <td width="10%" align="left"><font size="2" Face="Arial Black">VALOR</font></td>'	
	cMsg += '      <td width="05%" align="left"><font size="2" Face="Arial Black">MAR/MOD</font></td>'	
	cMsg += '      <td width="05%" align="left"><font size="2" Face="Arial Black">OBSERVAวรO</font></td>'	
	cMsg += '   </tr>'
	
	For i:=1 to Len(aGrade)
 
   		If aGrade[i,5] > 0    
	    
    	   cPProd   := cPProd + 1
	 	   // Separando Produtos
           If cProdAnt <> aGrade[i,2] .And. cPProd > 1  

				cMsg += '   <tr>'
				cMsg += '      <td width="20%" align="left"><font size="1">&nbsp</font></td>'	
				cMsg += '      <td width="10%" align="left"><font size="1">&nbsp</font></td>'	
				cMsg += '      <td width="40%" align="left"><font size="1">&nbsp</font></td>'	
				cMsg += '      <td width="15%" align="left"><font size="1">&nbsp</font></td>'	
				cMsg += '      <td width="10%" align="left"><font size="1">&nbsp</font></td>'	
				cMsg += '      <td width="05%" align="left"><font size="1">&nbsp</font></td>'	
				cMsg += '   </tr>'
	
	    	Endif
    	
		
    	    cProdAnt := aGrade[i,2]
        	nNovoValor := 0    
			If "DIPROMED" $ aGrade[i,6]
	    
				cMsg += '   <tr>'
				cMsg += '      <td width="20%" align="left"><font color="BLUE" size="1">' + Alltrim(aGrade[i,6]) + '</font></td>'
				cMsg += '      <td width="10%" align="left"><font color="BLUE" size="3">' + aGrade[i,2] + '</font></td>'
				cMsg += '      <td width="40%" align="left"><font color="BLUE" size="1">' + aGrade[i,3] + '</font></td>'
				cMsg += '      <td width="15%" align="center"><font color="BLUE" size="1">' + Transform(aGrade[i,4],"@E 999,999,999.99") + '</font></td>'
            
        	    If nOpcx == 4 .And. aScan(aProAlt, {|x| Alltrim(x[1])+Alltrim(x[2]) == Alltrim(aGrade[i,2])+Alltrim(aGrade[i,6])}) > 0 
    				nNovoVAlor := aProAlt[aScan(aProAlt, { |x| Alltrim(x[1])+Alltrim(x[2]) == Alltrim(aGrade[i,2])+Alltrim(aGrade[i,6])}),3]
	            	If  nNovoVAlor <> aGrade[i,5]
						cMsg += '      <td width="10%" align="center"><font color="red" size="2">' + Transform(aGrade[i,5],"@E 9,999.9999") + '</font></td>'
				    Else
						cMsg += '      <td width="10%" align="center"><font color="BLUE" size="1">' + Transform(aGrade[i,5],"@E 9,999.9999") + '</font></td>'
					Endif
				Else     
					cMsg += '      <td width="10%" align="center"><font color="BLUE" size="1">' + Transform(aGrade[i,5],"@E 9,999.9999") + '</font></td>'
				Endif
				
				cMsg += '      <td width="05%" align="left"><font color="BLUE" size="1">' + Iif(Empty(Alltrim(aGrade[i,7])),"Nใo Informado",aGrade[i,7]) + '</font></td>'  
				cMsg += '      <td width="05%" align="left"><font color="BLUE" size="1">' + Iif(Empty(Alltrim(aGrade[i,10])),"Sem observa็ใo",aGrade[i,10]) + '</font></td>'
				cMsg += '   </tr>' 
			Else	               
				cMsg += '   <tr>'
				cMsg += '      <td width="20%" align="left"><font size="1">' + Alltrim(aGrade[i,6]) + '</font></td>'
				cMsg += '      <td width="10%" align="left"><font size="3">' + aGrade[i,2] + '</font></td>'
				cMsg += '      <td width="40%" align="left"><font size="1">' + aGrade[i,3] + '</font></td>'
				cMsg += '      <td width="15%" align="center"><font size="1">' + Transform(aGrade[i,4],"@E 999,999,999.99") + '</font></td>'
			
			
        	    If nOpcx == 4 .And. aScan(aProAlt, {|x| Alltrim(x[1])+Alltrim(x[2]) == Alltrim(aGrade[i,2])+Alltrim(aGrade[i,6])}) > 0 
    				nNovoVAlor := aProAlt[aScan(aProAlt, { |x| Alltrim(x[1])+Alltrim(x[2]) == Alltrim(aGrade[i,2])+Alltrim(aGrade[i,6])}),3]
	            	If  nNovoVAlor <> aGrade[i,5]
						cMsg += '      <td width="10%" align="center"><font color="red" size="2">' + Transform(aGrade[i,5],"@E 9,999.9999") + '</font></td>'
				    Else
						cMsg += '      <td width="10%" align="center"><font size="1">' + Transform(aGrade[i,5],"@E 9,999.9999") + '</font></td>'
					Endif
				Else
					cMsg += '      <td width="10%" align="center"><font size="1">' + Transform(aGrade[i,5],"@E 9,999.9999") + '</font></td>'
				Endif        	
				cMsg += '      <td width="05%" align="left"><font size="1">' + Iif(Empty(Alltrim(aGrade[i,7])),"Nใo Informado",aGrade[i,7]) +  '</font></td>'
				cMsg += '      <td width="05%" align="left"><font size="1">' + Iif(Empty(Alltrim(aGrade[i,10])),"Sem observa็ใo",aGrade[i,10]) + '</font></td>'
				cMsg += '   </tr>' 
			Endif
		Endif    
	
	Next i
	
	cMsg += '</table>'

	//-----------------------------------------------------------------------
	// Definicao do rodape do email
	//-----------------------------------------------------------------------
	cMsg += '<HR Width=100% Size=4 Align=Centered Color=Red> <P>'
	cMsg += '    <table width="100%" Align="Center" border="0">'
	cMsg += '       <tr align="center">'
	If nOpcx == 6 
		cMsg += '           <td colspan="10"><font color="BLUE" size="2">Mensagem enviada pelo usuario '+ Upper(U_DipUsr())+ '- <font color="BLUE" size="1">(DIPAL40.PRW)</td>'
	Else
		cMsg += '           <td colspan="10"><font color="BLUE" size="2">Mensagem enviada automaticamente pelo sistema PROTHEUS - <font color="BLUE" size="1">(DIPAL40.PRW)</td>'
    Endif
	cMsg += '       </tr>'
	cMsg += '    </table>'
	cMsg += '</body>'
	cMsg += '</html>'
	
Else   


	cMsg += '<table width="100%" border="2" cellspacing="0" cellpadding="0">'
	cMsg += '   <tr>'
	cMsg += '      <td width="20%" align="left"><font size="2" Face="Arial Black">CONCORRENTE</font></td>'	
	cMsg += '      <td width="40%" align="left"><font size="2" Face="Arial Black">NOME CLIENTE</font></td>'	
	cMsg += '      <td width="10%" align="left"><font size="2" Face="Arial Black">PREGรO</font></td>'	
	cMsg += '      <td width="15%" align="left"><font size="2" Face="Arial Black">QUANT</font></td>'	
	cMsg += '      <td width="10%" align="left"><font size="2" Face="Arial Black">VALOR</font></td>'	
	cMsg += '      <td width="05%" align="left"><font size="2" Face="Arial Black">RESULTADO</font></td>'	
	cMsg += '      <td width="05%" align="left"><font size="2" Face="Arial Black">OBSERVAวรO</font></td>'	
	cMsg += '   </tr>'
	
	For i:=1 to Len(aGrade)
 
   		If aGrade[i,5] > 0    
	    
    	   cPProd   := cPProd + 1
	 	   // Separando Produtos
           If cProdAnt <> aGrade[i,2] .And. cPProd > 1  

				cMsg += '   <tr>'
				cMsg += '      <td width="20%" align="left"><font size="1">&nbsp</font></td>'	
				cMsg += '      <td width="40%" align="left"><font size="1">&nbsp</font></td>'	
				cMsg += '      <td width="10%" align="left"><font size="1">&nbsp</font></td>'	
				cMsg += '      <td width="15%" align="left"><font size="1">&nbsp</font></td>'	
				cMsg += '      <td width="10%" align="left"><font size="1">&nbsp</font></td>'	
				cMsg += '      <td width="05%" align="left"><font size="1">&nbsp</font></td>'	
				cMsg += '   </tr>'
	
	    	Endif
    	
		
    	    cProdAnt := aGrade[i,2]
        	nNovoValor := 0    
			If "DIPROMED" $ aGrade[i,6]
	    
				cMsg += '   <tr>'
				cMsg += '      <td width="20%" align="left"><font color="BLUE" size="1">' + Alltrim(aGrade[i,6]) + '</font></td>'
				cMsg += '      <td width="40%" align="left"><font color="BLUE" size="2">' + aGrade[i,12] + '</font></td>'
				cMsg += '      <td width="10%" align="left"><font color="BLUE" size="1">' + aGrade[i,13] + '</font></td>'
				cMsg += '      <td width="15%" align="center"><font color="BLUE" size="1">' + Transform(aGrade[i,4],"@E 999,999,999.99") + '</font></td>'
            
        	    If nOpcx == 4 .And. aScan(aProAlt, {|x| Alltrim(x[1])+Alltrim(x[2]) == Alltrim(aGrade[i,2])+Alltrim(aGrade[i,6])}) > 0 
    				nNovoVAlor := aProAlt[aScan(aProAlt, { |x| Alltrim(x[1])+Alltrim(x[2]) == Alltrim(aGrade[i,2])+Alltrim(aGrade[i,6])}),3]
	            	If  nNovoVAlor <> aGrade[i,5]
						cMsg += '      <td width="10%" align="center"><font color="red" size="2">' + Transform(aGrade[i,5],"@E 9,999.9999") + '</font></td>'
				    Else
						cMsg += '      <td width="10%" align="center"><font color="BLUE" size="1">' + Transform(aGrade[i,5],"@E 9,999.9999") + '</font></td>'
					Endif
				Else     
					cMsg += '      <td width="10%" align="center"><font color="BLUE" size="1">' + Transform(aGrade[i,5],"@E 9,999.9999") + '</font></td>'
				Endif
				cMsg += '      <td width="05%" align="left"><font color="BLUE" size="1">' + Iif(aGrade[i,8]="1","Venceu","Perdeu") +  '</font></td>'  
				cMsg += '      <td width="05%" align="left"><font color="BLUE" size="1">' + Iif(Empty(Alltrim(aGrade[i,10])),"Sem observa็ใo",aGrade[i,10]) + '</font></td>'
				cMsg += '   </tr>' 
			Else	               
				cMsg += '   <tr>'
				cMsg += '      <td width="20%" align="left"><font size="1">' + Alltrim(aGrade[i,6]) + '</font></td>'
				cMsg += '      <td width="40%" align="left"><font size="2">' + aGrade[i,12] + '</font></td>'
				cMsg += '      <td width="10%" align="left"><font size="1">' + aGrade[i,13] + '</font></td>'
				cMsg += '      <td width="15%" align="center"><font size="1">' + Transform(aGrade[i,4],"@E 999,999,999.99") + '</font></td>'
			
			
        	    If nOpcx == 4 .And. aScan(aProAlt, {|x| Alltrim(x[1])+Alltrim(x[2]) == Alltrim(aGrade[i,2])+Alltrim(aGrade[i,6])}) > 0 
    				nNovoVAlor := aProAlt[aScan(aProAlt, { |x| Alltrim(x[1])+Alltrim(x[2]) == Alltrim(aGrade[i,2])+Alltrim(aGrade[i,6])}),3]
	            	If  nNovoVAlor <> aGrade[i,5]
						cMsg += '      <td width="10%" align="center"><font color="red" size="2">' + Transform(aGrade[i,5],"@E 9,999.9999") + '</font></td>'
				    Else
						cMsg += '      <td width="10%" align="center"><font size="1">' + Transform(aGrade[i,5],"@E 9,999.9999") + '</font></td>'
					Endif
				Else
					cMsg += '      <td width="10%" align="center"><font size="1">' + Transform(aGrade[i,5],"@E 9,999.9999") + '</font></td>'
				Endif
        	
				cMsg += '      <td width="05%" align="left"><font size="1">' + Iif(aGrade[i,8]="1","Venceu","Perdeu") + '</font></td>'
				cMsg += '      <td width="05%" align="left"><font size="1">' + Iif(Empty(Alltrim(aGrade[i,10])),"Sem observa็ใo",aGrade[i,10]) + '</font></td>'
				cMsg += '   </tr>' 
			Endif
		Endif    
	
	Next i
	
	cMsg += '</table>'

	//-----------------------------------------------------------------------
	// Definicao do rodape do email
	//-----------------------------------------------------------------------
	cMsg += '<HR Width=100% Size=4 Align=Centered Color=Red> <P>'
	cMsg += '    <table width="100%" Align="Center" border="0">'
	cMsg += '       <tr align="center">'
	cMsg += '           <td colspan="10"><font color="BLUE" size="2">Mensagem enviada  pelo usuaแrio '+Upper(U_DipUsr())+ ' - <font color="BLUE" size="1">(DIPAL40.PRW)</td>'
	cMsg += '       </tr>'
	cMsg += '    </table>'
	cMsg += '</body>'
	cMsg += '</html>'
	
Endif
//-------------------------------------------------------------------------------
// Envia o mail para a lista selecionada. Envia como BCC para que a pessoa pense
// que somente ela recebeu aquele email, tornando o email mais personalizado.
//-------------------------------------------------------------------------------
CONNECT SMTP SERVER cServer ACCOUNT cAccount PASSWORD cPassword RESULT lResult   

//CC  '' //                      ;
//BCC 'relatorios@dipromed.com.br';

If !lAutOk
	If ( lSmtpAuth )
		lAutOk := MailAuth(cAccount,cPassword)
	Else
		lAutOk := .T.
	EndIf
EndIf

If lResult .And. lAutOk
	SEND MAIL FROM cFrom ;
	TO  cTo;
	BCC cBCC;
	SUBJECT 	cAssunto;
	BODY    	cMsg;
	RESULT lResult
	If !lResult
		//Erro no envio do email
		GET MAIL ERROR cError
		MsgInfo(cError,OemToAnsi('Aten็ใo'))
	EndIf
	DISCONNECT SMTP SERVER
Else
	//Erro na conexao com o SMTP Server
	GET MAIL ERROR cError
	MsgInfo(cError,OemToAnsi('Aten็ใo'))
EndIf
Return(.T.) 
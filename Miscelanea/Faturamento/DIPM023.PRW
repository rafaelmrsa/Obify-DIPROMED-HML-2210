#include "protheus.ch"
#include "rwmake.ch"
#include "AP5MAIL.CH"
#include "color.ch"
#include "FwPrintSetup.ch" 
#INCLUDE "RPTDEF.CH"
#INCLUDE "TBICONN.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ DIPM023 ³ Autor ³ Maximo                ³ Data ³ 26/11/07  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ IMPRESSAO DO BOLETO BANCO REAL                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Especifico Dipromed                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function DIPM023(_l460i,_cBanco)//Antigo BLTLASER - MCVN - 25/07/2008 //User Function DIPM023(_l460i) BORGES

LOCAL	aPergs 		:= {}
Local   aOrd        := {}
PRIVATE _aAreAtu    := GetArea()//Giovani Zago 19/03/2012
PRIVATE lExec    	:= .F.
PRIVATE cIndexName 	:= ''
PRIVATE cIndexKey  	:= ''
PRIVATE cFilter    	:= ''
PRIVATE _lPreview	:= .T.
PRIVATE nAjustVal   := 0.00001 // Utilizado para corrigir erro no cálculo da variável blvalorfinal - MCVN  28/09/09
//Giovani Zago 19/03/2012 troca de mv_par por cpar  
PRIVATE CondPgtoAV :=GetNewPar("ES_DIP23CV","")//RBORGES - 13/11/2013 - Parâmetro conterá as condições de pagamento à vista 
PRIVATE	cPAR01 := ""
PRIVATE	cPAR02 := ""
PRIVATE	cPAR03 := ""
PRIVATE	cPAR04 := ""
PRIVATE	cPAR05 := ""
PRIVATE	cPAR06 := ""
PRIVATE	cPAR07 := ""
PRIVATE	cPAR08 := ""
PRIVATE	cPAR09 := ""
PRIVATE	cPAR10 := ""
PRIVATE	cPAR11 := ""
PRIVATE	cPAR12 := ""
PRIVATE	cPAR13 := ""
PRIVATE	cPAR14 := ""
PRIVATE	cPAR15 := ""
PRIVATE	cPAR16 := ""
PRIVATE	cPAR17 := ""
PRIVATE	cPAR18 := ""
PRIVATE	cPAR19 := ""
Default _l460i := .F.
 

_lPreview := !_l460i

Tamanho  := "M"
titulo   := "Impressao de Boleto Banco com Codigo de Barras."
cDesc1   := "Este programa destina-se a impressao do Boleto com Codigo de Barras."
cDesc2   := ""
cDesc3   := ""
cString  := "SE1"
wnrel    := "BOLETO"
lEnd     := .F.
cPerg    :="DIPM23"
aReturn  := {"Zebrado", 1,"Administracao", 2, 2, 1, "",1 }
nLastKey := 0

U_DIPPROC(ProcName(0),U_DipUsr()) // MCVN - 22/01/2009

dbSelectArea("SE1")

Aadd(aPergs,{"Prefixo","","","mv_ch1","C",3,0,0,"G","","MV_PAR01","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
//Aadd(aPergs,{"Ate Prefixo","","","mv_ch2","C",3,0,0,"G","","MV_PAR02","","","","ZZZ","","","","","","","","","","","","","","","","","","","","","","","","",""})
Aadd(aPergs,{"De Numero","","","mv_ch2","C",9,0,0,"G","","MV_PAR02","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
Aadd(aPergs,{"Ate Numero","","","mv_ch3","C",9,0,0,"G","","MV_PAR03","","","","ZZZZZZ","","","","","","","","","","","","","","","","","","","","","","","","",""})
Aadd(aPergs,{"De Parcela","","","mv_ch4","C",1,0,0,"G","","MV_PAR04","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
Aadd(aPergs,{"Ate Parcela","","","mv_ch5","C",1,0,0,"G","","MV_PAR05","","","","Z","","","","","","","","","","","","","","","","","","","","","","","","",""})
Aadd(aPergs,{"De Cliente","","","mv_ch6","C",6,0,0,"G","","MV_PAR06","","","","","","","","","","","","","","","","","","","","","","","","","SA1","","","",""})
Aadd(aPergs,{"Ate Cliente","","","mv_ch7","C",6,0,0,"G","","MV_PAR07","","","","ZZZZZZ","","","","","","","","","","","","","","","","","","","","","SA1","","","",""})
Aadd(aPergs,{"De Loja","","","mv_ch8","C",2,0,0,"G","","MV_PAR08","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
Aadd(aPergs,{"Ate Loja","","","mv_ch9","C",2,0,0,"G","","MV_PAR09","","","","ZZ","","","","","","","","","","","","","","","","","","","","","","","","",""})
Aadd(aPergs,{"De Emissao","","","mv_cha","D",8,0,0,"G","","MV_PAR10","","","","01/01/80","","","","","","","","","","","","","","","","","","","","","","","","",""})
Aadd(aPergs,{"Ate Emissao","","","mv_chb","D",8,0,0,"G","","MV_PAR11","","","","31/12/03","","","","","","","","","","","","","","","","","","","","","","","","",""})
Aadd(aPergs,{"De Vencimento","","","mv_chc","D",8,0,0,"G","","MV_PAR12","","","","01/01/80","","","","","","","","","","","","","","","","","","","","","","","","",""})
Aadd(aPergs,{"Ate Vencimento","","","mv_chd","D",8,0,0,"G","","MV_PAR13","","","","31/12/03","","","","","","","","","","","","","","","","","","","","","","","","",""})
Aadd(aPergs,{"Do Bordero","","","mv_che","C",6,0,0,"G","","MV_PAR14","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
Aadd(aPergs,{"Ate Bordero","","","mv_chf","C",6,0,0,"G","","MV_PAR15","","","","ZZZZZZ","","","","","","","","","","","","","","","","","","","","","","","","",""})
Aadd(aPergs,{"Banco ","","","mv_chg","C",3,0,0,"G","","mv_par16","","","","","","","","","","","","","","","","","","","","","","","","","SA6","007","S"})  // MCVN - 06/06/09
Aadd(aPergs,{"Agencia ","",""  ,"mv_chh","C",5,0,0,"G","","mv_par17","","","","","","","","","","","","","","","","","","","","","","","","","","008","S"}) // MCVN - 06/06/09
Aadd(aPergs,{"Conta ","",""  ,"mv_chi","C",10,0,0,"G","","mv_par18","","","","","","","","","","","","","","","","","","","","","","","","","","009","S"})  // MCVN - 06/06/09


AjustaSx1(cPerg,aPergs)
If !_l460i
	Pergunte (cPerg,.F.)
	
	If !Pergunte(cPerg,.T.)     // Solicita parametro
		
		RestArea(_aAreAtu)
		Return
	EndIf
	//Giovani Zago 19/03/2012
	cPAR01 := Mv_Par01
	cPAR02 := Mv_Par02
	cPAR03 := Mv_Par03
	cPAR04 := Mv_Par04
	cPAR05 := Mv_Par05
	cPAR06 := Mv_Par06
	cPAR07 := Mv_Par07
	cPAR08 := Mv_Par08
	cPAR09 := Mv_Par09
	cPAR10 := Mv_Par10
	cPAR11 := Mv_Par11
	cPAR12 := Mv_Par12
	cPAR13 := Mv_Par13
	cPAR14 := Mv_Par14
	cPAR15 := Mv_Par15
	cPAR16 := Mv_Par16
	cPAR17 := Mv_Par17
	cPAR18 := Mv_Par18
	
Else    
//Giovani Zago 19/03/2012
	cPAR01 := If(cEmpAnt+cFilAnt=='0101',SUBSTR(SF2->F2_SERIE,2,2),SF2->F2_SERIE)
	cPAR02 := SF2->F2_DOC
	cPAR03 := SF2->F2_DOC
	cPAR04 := Repl(' ',Len(SE1->E1_PARCELA))
	cPAR05 := Repl('Z',Len(SE1->E1_PARCELA))
	cPAR06 := Repl(' ',Len(SE1->E1_CLIENTE))
	cPAR07 := Repl('Z',Len(SE1->E1_CLIENTE))
	cPAR08 := Repl(' ',Len(SE1->E1_LOJA))
	cPAR09 := Repl('Z',Len(SE1->E1_LOJA))
	cPAR10 := CtoD("  /  /    ")
	cPAR11 := CtoD("31/12/2059")
	cPAR12 := CtoD("  /  /    ")
	cPAR13 := CtoD("31/12/2059")
	cPAR14 := Repl(' ',Len(SE1->E1_NUMBOR))
	cPAR15 := Repl('Z',Len(SE1->E1_NUMBOR))
	cPAR16 := Space(Len(SE1->E1_PORTADO))
	cPAR17 := Space(Len(SE1->E1_AGEDEP))
	cPAR18 := Space(Len(SE1->E1_CONTA))
EndIf



// Desabilita boleto pelo real (Eriberto ciente) 05/04/2010
If '356' $ cPAR16 .And. cModulo <> "FAT"
	Alert("Foi desativado a emissão de boleto pelo BANCO REAL em 05/04/2010 !")
	
	RestArea(_aAreAtu)
	Return()
EndIf

cIndexName	:= Criatrab(Nil,.F.)
cIndexKey	:= " E1_CLIENTE+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO+DTOS(E1_EMISSAO)"
///FILTRO
cFilter		+= " E1_FILIAL=='"+xFilial("SE1")+"'.And.E1_SALDO>0.And."
cFilter		+= " E1_PREFIXO>='" + cPAR01 + "' .And. E1_PREFIXO <='" + cPAR01 + "' .And. "
cFilter		+= " E1_NUM>='" + cPAR02 + "'.And.E1_NUM<='" + cPAR03 + "' .And."
cFilter		+= " E1_PARCELA>='" + cPAR04 + "'.And.E1_PARCELA<='" + cPAR05 + "' .And."
//cFilter		+= "E1_PORTADO = '356' .And."
cFilter		+= " E1_CLIENTE>='" + cPAR06 + "'.And.E1_CLIENTE<='" + cPAR07 + "' .And."
cFilter		+= " E1_LOJA>='" + cPAR08 + "'.And.E1_LOJA<='"+cPAR09+"' .And."
cFilter		+= " DTOS(E1_EMISSAO)>='"+DTOS(cPAR10)+"'.and.DTOS(E1_EMISSAO)<='"+DTOS(cPAR11)+"' .And."
cFilter		+= ' DTOS(E1_VENCREA)>="'+DTOS(cPAR12)+'".and.DTOS(E1_VENCREA)<="'+DTOS(cPAR13)+'" .And.'
cFilter		+= " E1_NUMBOR>='" + cPAR14 + "'.And.E1_NUMBOR<='" + cPAR15 + "'.And."
cFilter		+= " !(E1_TIPO$MVABATIM)"//.And."
//cFilter		+= "E1_PORTADO<>'   '"


IndRegua("SE1", cIndexName, cIndexKey,, cFilter, "Aguarde selecionando registros....")
DbSelectArea("SE1")
#IFNDEF TOP
	DbSetIndex(cIndexName + OrdBagExt())
#ENDIF
dbGoTop()
lExec := .T.
/*
@ 001,001 TO 400,700 DIALOG oDlg TITLE "Seleção de Titulos"
@ 001,001 TO 170,350 BROWSE "SE1" MARK "E1_OK"
@ 180,310 BMPBUTTON TYPE 01 ACTION (lExec := .T.,Close(oDlg))
@ 180,280 BMPBUTTON TYPE 02 ACTION (lExec := .F.,Close(oDlg))
ACTIVATE DIALOG oDlg CENTERED
*/
dbGoTop()

If lExec
	If _lPreview
		
		If cEmpAnt+cFilAnt == '0401'// RBORGES - 12/11/2013 - Entrar na validação apenas HQ.
			// RBORGES - 12/11/2013 - Não gerar boleto para condição de pagamento à vista.
			If! ImpBolHq(MV_PAR01,MV_PAR02,MV_PAR03) // RBORGES - 12/11/2013
				Processa({|lEnd|MontaRel(1)},"Aguarde...","Gerando boleto na pasta..." )
				Processa({|lEnd|MontaRel(2)},"Aguarde...","Enviando boleto para impressora...")
			EndIf
		Else	
				Processa({|lEnd|MontaRel(1)},"Aguarde...","Gerando boleto na pasta..." )
				Processa({|lEnd|MontaRel(2)},"Aguarde...","Enviando boleto para impressora...")
		EndIF
	Else
				Processa({|lEnd|MontaRel(1)},"Aguarde...","Gerando boleto na pasta..." )
				Processa({|lEnd|MontaRel(2)},"Aguarde...","Enviando boleto para impressora...")
	Endif
Endif

RetIndex("SE1")
Ferase(cIndexName+OrdBagExt())


RestArea(_aAreAtu)
Return Nil


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³  MontaRel³ Autor ³ Microsiga             ³ Data ³ 13/10/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ IMPRESSAO DO BOLETO LASER COM CODIGO DE BARRAS             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Especifico para Clientes Microsiga                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MontaRel(nTipo)
//LOCAL oPrint
LOCAL nX := 0
Local cNroDoc :=  " "
LOCAL aDadosEmp    := {	SM0->M0_NOMECOM                                    ,; //[1]Nome da Empresa
SM0->M0_ENDCOB                                     ,; //[2]Endereço
AllTrim(SM0->M0_BAIRCOB)+", "+AllTrim(SM0->M0_CIDCOB)+", "+SM0->M0_ESTCOB ,; //[3]Complemento
"CEP: "+Subs(SM0->M0_CEPCOB,1,5)+"-"+Subs(SM0->M0_CEPCOB,6,3)             ,; //[4]CEP
"PABX/FAX: "+SM0->M0_TEL                                                  ,; //[5]Telefones
"CNPJ: "+Subs(SM0->M0_CGC,1,2)+"."+Subs(SM0->M0_CGC,3,3)+"."+          ; //[6]
Subs(SM0->M0_CGC,6,3)+"/"+Subs(SM0->M0_CGC,9,4)+"-"+                       ; //[6]
Subs(SM0->M0_CGC,13,2)                                                    ,; //[6]CGC
"I.E.: "+Subs(SM0->M0_INSC,1,3)+"."+Subs(SM0->M0_INSC,4,3)+"."+            ; //[7]
Subs(SM0->M0_INSC,7,3)+"."+Subs(SM0->M0_INSC,10,3)                        }  //[7]I.E

LOCAL aDadosTit
LOCAL aDadosBanco
LOCAL aDatSacado
LOCAL aBolText     := {"Após o vencimento cobrar multa de R$ "                ,;
"Mora Diaria de R$ "                                   ,;
""}

LOCAL nI           := 1
LOCAL aCB_RN_NN    := {}
LOCAL nVlrAbat		:= 0
Local aAreaAux

//-- Calculo Dac Bradesco.
Local StrMult
Local BaseDac
Local VarDac
Local iDac

Private cBitMap := ""
Private cCodBco := ""
Private oPrint

/*
oPrint:= TMSPrinter():New( "Boleto Laser" )
    If !_lPreview .And. ! oPrint:IsPrinterActive()
	oPrint:Setup()	// Escolhe a impressora
Endif
     */

/**************************************************************** 
| RBORGES 05/08/2013 - Feito as alterações de acordo com a  	|
| nova classe. Antes TMSPRINTER agora FWMSPRINTER.				| 
/****************************************************************/

Private cPrefixo := "Boleto_" +Alltrim(SE1->E1_NUM)+"_"+DTOS(dDatabase)
Private oPrint := FWMSPrinter():New(cPrefixo,6,.T.,,.T.,,,,,,,.F.,)

oPrint:SetResolution(72)
oPrint :SetPortrait() 
oPrint:SetPaperSize(9)
MakeDir("C:\Boleto_Laser\") 
oPrint :cPathPDF:= "C:\Boleto_Laser\"                               


dbGoTop()
ProcRegua(RecCount())
Do While SE1->(!EOF())
	// Verifca se o Cliente Gera Boleto
	_cMV_BCOAUT := SuperGetMv("MV_BCOAUTO",,"")
	_nPosBco	:= At('/',_cMV_BCOAUT)
	_cBco		:= If(!_lPreview .Or. cModulo = "FAT",Substr(_cMV_BCOAUT,1,_nPosBco-1),cPAR16) // MCVN - 06/06/09
	_nPosAg		:= At('/',_cMV_BCOAUT,_nPosBco+1)
	_cAgencia   := If(!_lPreview .Or. cModulo = "FAT",Substr(_cMV_BCOAUT,_nPosBco+1,_nPosAg-_nPosBco-1),cPAR17) // MCVN - 06/06/09
	_cConta		:= If(!_lPreview .Or. cModulo = "FAT",AllTrim(Substr(_cMV_BCOAUT,_nPosAg+1)),cPAR18) // MCVN - 06/06/09
	_lLoop 		:= .F.
	
	
	//Posiciona o SA1 (Cliente)
	SA1->(DbSetOrder(1)) // A1_FILIAL+A1_COD+A1_LOJA
	If !SA1->(DbSeek(xFilial()+SE1->E1_CLIENTE+SE1->E1_LOJA,.T.) )
		_lLoop := .T.
	EndIf
	
	If !_lLoop .And. Empty(SE1->E1_NUMBCO) .And. (Empty(SA1->A1_PORTADO) .Or. SA1->A1_PORTADO == _cBco)
		_lLoop 		:= .T.
		//Posiciona o SA6 (Bancos)
		SA6->(DbSetOrder(1))
		If SA6->(DbSeek(xFilial("SA6")+_cBco+_cAgencia+_cConta,.T.))
			//Posiciona na Arq de Parametros CNAB
			SEE->(DbSetOrder(1))
			If SEE->(DbSeek(xFilial("SEE")+_cBco+_cAgencia+_cConta,.T.)) .And. _cBco $ '237/341/356'
				// Varre os Titulos, Alterando-os
				RecLock("SE1",.F.)
				_lLoop := .F.
				SE1->E1_PORTADO	:= _cBco
				SE1->E1_AGEDEP	:= _cAgencia
				SE1->E1_CONTA	:= _cConta
				SE1->E1_SITUACA	:= '0'
				If _cBco == '356'     // Real
					// NUMTIT(6) + PARCELA(1) = 7 CARACTERES
					SE1->E1_NUMBCO	:= RIGHT(AllTrim(SE1->E1_NUM),6) + StrZero(At(AllTrim(SE1->E1_PARCELA),'ABCDEFGHIJ'),1)
				ElseIf _cBco == '341' // Itau
					// CONST- 03 (1) + NUMTIT(6) + PARCELA(1) = 8 CARACTERES
					SE1->E1_NUMBCO := Right(cFilAnt,1)+RIGHT(AllTrim(SE1->E1_NUM),6)+StrZero(At(AllTrim(SE1->E1_PARCELA),'ABCDEFGHIJ'),1)
					
					StrMult  := "2765432765432"
					BaseDac  := StrZero(Val(SEE->EE_CART),2)+AllTrim(SE1->E1_NUMBCO)
					VarDac   := 0
					For iDac := 1 To 13
						VarDac := VarDac + Val(Substr(BaseDac, iDac, 1)) * Val(Substr(StrMult, iDac, 1))
					Next iDac
					
					VarDac  := 11 - VarDac % 11
					VarDac  := Iif (VarDac == 10, "P", Iif (VarDac == 11, "0", Str (VarDac, 1)))
					
					SE1->E1_NUMBCO	= AllTrim(SE1->E1_NUMBCO)+VarDac
					
				ElseIf _cBco == '237' // Bradesco
					// CONST- 003 (3) + NUMTIT(6) + PARCELA(2) + DAC(1) = 12 CARACTERES
					SE1->E1_NUMBCO	:= Right(cFilAnt,1)+'03'+RIGHT(AllTrim(SE1->E1_NUM),6) + StrZero(At(AllTrim(SE1->E1_PARCELA),'ABCDEFGHIJ'),2)
					
					// NUMTIT(9) + PARCELA(2) + DAC(1) = 12 CARACTERES
					//SE1->E1_NUMBCO	:= StrZero(Val(SE1->E1_NUM),9) + StrZero(At(AllTrim(SE1->E1_PARCELA),'ABCDEFGHIJ'),2)
					
					StrMult  := "2765432765432"
					BaseDac  := StrZero(Val(SEE->EE_CART),2)+AllTrim(SE1->E1_NUMBCO)
					VarDac   := 0
					For iDac := 1 To 13
						VarDac := VarDac + Val(Substr(BaseDac, iDac, 1)) * Val(Substr(StrMult, iDac, 1))
					Next iDac
					
					VarDac  := 11 - VarDac % 11
					VarDac  := Iif (VarDac == 10, "P", Iif (VarDac == 11, "0", Str (VarDac, 1)))
					
					SE1->E1_NUMBCO	:= AllTrim(SE1->E1_NUMBCO)+VarDac
				EndIf
				MsUnlock()
			EndIf
		EndIf
	EndIf
	
	If !_lLoop
		//Posiciona o SA6 (Bancos)
		SA6->(DbSetOrder(1)) // A6_FILIAL+A6_COD+A6_AGENCIA+A6_NUMCON
		If !SA6->(DbSeek(xFilial("SA6")+SE1->E1_PORTADO+SE1->E1_AGEDEP+SE1->E1_CONTA,.T.))
			_lLoop := .T.
		EndIf
		
		//Posiciona na Arq de Parametros CNAB
		SEE->(DbSetOrder(1)) // EE_FILIAL+EE_CODIGO+EE_AGENCIA+EE_CONTA+EE_SUBCTA
		If !SEE->(DbSeek(xFilial("SEE")+SE1->(E1_PORTADO+E1_AGEDEP+E1_CONTA),.T.))
			_lLoop := .T.
		EndIf
	EndIf
	
	If !_lLoop
		DbSelectArea("SE1")
		aDadosBanco  := {SA6->A6_COD                        ,; 						// [1]Numero do Banco
		SA6->A6_NOME      	            	                  ,; 	// [2]Nome do Banco
		SA6->A6_AGENCIA                       			 ,; 		// [3]Agência
		SA6->A6_NUMCON 				,; 								// [4]Conta Corrente
		" "  														,; 	// [5]Dígito da conta corrente
		SEE->EE_CART                                     		,;		// [6]Codigo da Carteira
		SEE->EE_ACEITE                                   		}		// [7]Aceite
		
		
		_cPessoa := IIF(Len(AllTrim(str(val(SA1->A1_CGC))))>11,"J","F")
		
		
		If Empty(SA1->A1_ENDCOB)
			aDatSacado   := {AllTrim(SA1->A1_NOME)           ,;      	// [1]Razão Social
			AllTrim(SA1->A1_COD )+"-"+SA1->A1_LOJA           ,;      	// [2]Código
			AllTrim(SA1->A1_END )+"-"+AllTrim(SA1->A1_BAIRRO),;      	// [3]Endereço
			AllTrim(SA1->A1_MUN )                            ,;  			// [4]Cidade
			SA1->A1_EST                                      ,;     		// [5]Estado
			SA1->A1_CEP                                      ,;      	// [6]CEP
			SA1->A1_CGC										          ,;  			// [7]CGC
			_cPESSOA										}       				// [8]PESSOA
		Else
			aDatSacado   := {AllTrim(SA1->A1_NOME)            	 ,;   	// [1]Razão Social
			AllTrim(SA1->A1_COD )+"-"+SA1->A1_LOJA              ,;   	// [2]Código
			AllTrim(SA1->A1_ENDCOB)+"-"+AllTrim(SA1->A1_BAIRROC),;   	// [3]Endereço
			AllTrim(SA1->A1_MUNC)	                             ,;   	// [4]Cidade
			SA1->A1_ESTC	                                     ,;   	// [5]Estado
			SA1->A1_CEPC                                        ,;   	// [6]CEP
			SA1->A1_CGC												 		 ,;		// [7]CGC
			_cPESSOA										}       				// [8]PESSOA
		Endif
		
		aAreaAux := SE1->(GetArea())
		nVlrAbat   :=  SomaAbat(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,"R",1,,SE1->E1_CLIENTE,SE1->E1_LOJA)
		RestArea(aAreaAux)
		
		//Aqui defino parte do nosso numero. Sao 8 digitos para identificar o titulo.
		//Abaixo apenas uma sugestao.
		//cNroDoc	:= StrZero(	Val(Alltrim(SE1->E1_NUM)+Alltrim(SE1->E1_PARCELA)),8)
		cNroDoc	:= Left(SE1->E1_NUMBCO,8)
		
		//Monta codigo de barras
		If SA6->A6_COD == '356'  		// Bco Real
			cBitMap:= "LOGO_REAL.BMP"
			cCodBco:= '356-5'
			_cBanco := '356'
			aCB_RN_NN    := RCBReal(Subs(aDadosBanco[1],1,3),@aDadosBanco[3],@aDadosBanco[4],@aDadosBanco[5],cNroDoc,(SE1->E1_SALDO-nVlrAbat),SE1->E1_VENCTO,SE1->E1_NUMBCO,aDadosBanco[6])
		ElseIf SA6->A6_COD == '341'		// Bco Itau
			cBitMap:= "LOGO_ITAU.BMP"
			cCodBco:= '341-7'
			_cBanco := '341'
			aCB_RN_NN    := RCBItau(Subs(aDadosBanco[1],1,3),@aDadosBanco[3],@aDadosBanco[4],@aDadosBanco[5],cNroDoc,(SE1->E1_SALDO-nVlrAbat),SE1->E1_VENCTO,SE1->E1_NUMBCO,aDadosBanco[6])
		ElseIf SA6->A6_COD == '237'    // Bco Bradesco
			cBitMap:= "LOGO_BRAD.BMP"
			cCodBco:= '237-2'
			_cBanco := '237'
			aCB_RN_NN    := RCBBrad(Subs(aDadosBanco[1],1,3),@aDadosBanco[3],@aDadosBanco[4],@aDadosBanco[5],cNroDoc,(SE1->E1_SALDO-nVlrAbat),SE1->E1_VENCTO,SE1->E1_NUMBCO,aDadosBanco[6])
		EndIf
		//(cBanco,cAgencia,cConta,cDacCC,cNroDoc,nValor,dVencto)
		//                         NUMERO DO BANCO      ,MOEDA,AGENCIA, CONTA CORRENTE
		RestArea(aAreaAux)
		
		aDadosTit	:= {RIGHT(AllTrim(SE1->E1_NUM),6)+AllTrim(SE1->E1_PARCELA)		,;  // [1] Número do título
		SE1->E1_EMISSAO                 		        ,;  // [2] Data da emissão do título
		dDataBase                    					,;  // [3] Data da emissão do boleto
		SE1->E1_VENCTO                           		,;  // [4] Data do vencimento
		(SE1->E1_SALDO - nVlrAbat)               		,;  // [5] Valor do título
		SE1->E1_NUMBCO	                        		,;  // [6] Nosso número
		SE1->E1_PREFIXO                          		,;  // [7] Prefixo da NF
		SE1->E1_TIPO	                           		,;  // [8] Tipo do Titulo
		SE1->E1_DESCFIN                          		}   // [9] Desc. financeiro MCVN 05/06/09
		
		//	If Marked("E1_OK")

oPrint:StartPage()		
		Impress(oPrint,aDadosEmp,aDadosTit,aDadosBanco,aDatSacado,aBolText,aCB_RN_NN)
		
		nX := nX + 1
		//	EndIf
		RestArea(aAreaAux)
	EndIf
	
	DbSelectArea("SE1")
	SE1->(dbSkip())
	IncProc()
	nI := nI + 1
EndDo

oPrint:EndPage()     // Finaliza a página

If _lPreview
	oPrint:Preview()     // Visualiza antes de imprimir
	    CpyT2S( "C:\Boleto_Laser\"+cPrefixo+".pdf", "\RELATO\PDF" )//RBORGES - 12/08/2013 - copiar o arquivo do diretorio local para o RootPath), pois apenas assim se consegue pegar o anexo.
	    
Else
	If SF2->F2_COND $ ('051/052') .Or. SF2->F2_CLIENTE $ GetNewPar("ES_CLIMAIL","020719")// Se a condição de pagamento for 051 ou 052 ou o cliente estiver no parâmetro ES_CLIMAIL envia boleto por e-mail mas não imprimo no CD - MCVN - 24/02/11
	        oPrint:Print()     // Visualiza antes de enviar e-mail
				CpyT2S( "C:\Boleto_Laser\"+cPrefixo+".pdf", "\RELATO\PDF" )//RBORGES - 12/08/2013 - copiar o arquivo do diretorio local para o RootPath), pois apenas assim se consegue pegar o anexo.
				PdfMail(UsrRetMAIL()) // Envia e-mail para financeiro
				DIPM23CIC()
	Else         
		If cEmpAnt == '01'
			WriteProfString("PRINTER_"+GetComputerName(),"DEFAULT","Lexmark T644",.F.)
			WriteProfString("PRINTER_"+GetComputerName(),"LOCAL","SERVER",.F.)
		EndIf
			
		If nTipo == 1
	
			oPrint:Print()
			CpyT2S( "C:\Boleto_Laser\"+cPrefixo+".pdf", "\RELATO\PDF" )//RBORGES - 12/08/2013 - copiar o arquivo do diretorio local para o RootPath), pois apenas assim se consegue pegar o anexo.
			
			PdfMail(UsrRetMAIL()) // Envia e-mail para financeiro
			
			WinExec("Explorer.exe C:\Boleto_Laser\"+cPrefixo+".pdf")
					
		Else	
			
			oPrint:SetDevice(IMP_SPOOL)
			oPrint:Print()						
			
	    EndIf
	    		


	Endif
	
EndIf


Return nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³  Impress ³ Autor ³ Microsiga             ³ Data ³ 13/10/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ IMPRESSAO DO BOLETO LASER COM CODIGO DE BARRAS             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Especifico para Clientes Microsiga                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Impress(oPrint,aDadosEmp,aDadosTit,aDadosBanco,aDatSacado,aBolText,aCB_RN_NN)
LOCAL oFont7
LOCAL oFont8
LOCAL oFont9
LOCAL oFont9n
LOCAL oFont11c
LOCAL oFont10
LOCAL oFont13
LOCAL oFont14
LOCAL oFont16n
LOCAL oFont15
LOCAL oFont14n
LOCAL oFont18
LOCAL oFont24
LOCAL nI := 0
LOCAL oBrush
Local jj
//Parametros de TFont.New()
//1.Nome da Fonte (Windows)
//3.Tamanho em Pixels
//5.Bold (T/F)
oFont7  	:= TFont():New("Arial",9,9,.T.,.F.,5,.T.,5,.T.,.F.)
oFont8  	:= TFont():New("Arial",9,10,.T.,.F.,5,.T.,5,.T.,.F.)
oFont9  	:= TFont():New("Arial",9,11,.T.,.T.,5,.T.,5,.T.,.F.)
oFont9n  	:= TFont():New("Arial",9,11,.T.,.F.,5,.T.,5,.T.,.F.)
oFont11c 	:= TFont():New("Courier New",9,13,.T.,.T.,5,.T.,5,.T.,.F.)
oFont10  	:= TFont():New("Arial",9,12,.T.,.T.,5,.T.,5,.T.,.F.)
oFont12  	:= TFont():New("Arial",9,14,.T.,.T.,5,.T.,5,.T.,.F.)
oFont13  	:= TFont():New("Arial",9,15,.T.,.T.,5,.T.,5,.T.,.F.)
oFont14  	:= TFont():New("Arial",9,16,.T.,.T.,5,.T.,5,.T.,.F.)
oFont18  	:= TFont():New("Arial",9,20,.T.,.T.,5,.T.,5,.T.,.F.)
oFont20  	:= TFont():New("Arial",9,22,.T.,.T.,5,.T.,5,.T.,.F.)
oFont21  	:= TFont():New("Arial",9,23,.T.,.T.,5,.T.,5,.T.,.F.)
oFont16n 	:= TFont():New("Arial",9,18,.T.,.F.,5,.T.,5,.T.,.F.)
oFont15  	:= TFont():New("Arial",9,17,.T.,.T.,5,.T.,5,.T.,.F.)
oFont15n 	:= TFont():New("Arial",9,17,.T.,.F.,5,.T.,5,.T.,.F.)
oFont14n 	:= TFont():New("Arial",9,16,.T.,.F.,5,.T.,5,.T.,.F.)
oFont24  	:= TFont():New("Arial",9,26,.T.,.T.,5,.T.,5,.T.,.F.)
oBrush 		:= TBrush():New("",4)


/******************/
/* PRIMEIRA PARTE */
/******************/

//nRow1 := 0
//cBitMap:= "LOGO_REAL.BMP"
// RETIRADO A PARTE DO ACEITE, POIS NA DIPROMED OS BOLETOS IRAO JUNTO COM A NF...
/*
For jj:=0 to 6 Step 1
oPrint:Line (nRow1+0146+jj,100,nRow1+0146+jj,2300)
oPrint:Line (nRow1+0150,503+jj,nRow1+0070, 503+jj)
oPrint:Line (nRow1+0150,713+jj,nRow1+0070, 713+jj)
Next

//oPrint:FillRect({nRow1+0250,1050,nRow1+0350,1900},oBrush)

oPrint:SayBitmap(nRow1+065,095,cBitMap,0065,080 )
oPrint:Say  (nRow1+0065,170,"BANCO REAL",oFont13 )	// [2]Nome do Banco
oPrint:Say  (nRow1+0108,170,"ABN AMRO",oFont8 )	// [2]Nome do Banco
oPrint:Say  (nRow1+0075,530,aDadosBanco[1]+"-5",oFont18 )		// [1]Numero do Banco

oPrint:Say  (nRow1+0084,1900,"Comprovante de Entrega",oFont10)

oPrint:Say  (nRow1+0150,100 ,"Cedente:",oFont8)
oPrint:Say  (nRow1+0200,100 ,aDadosEmp[1],oFont10)				//Nome + CNPJ

oPrint:Say  (nRow1+0150,1060,"Agência/Código Cedente:",oFont8)
oPrint:Say  (nRow1+0200,1060,"  "+aDadosBanco[3]+"/"+aDadosBanco[4]+"-"+aDadosBanco[5],oFont10)

oPrint:Say  (nRow1+0150,1510,"Nro.Documento:",oFont8)
oPrint:Say  (nRow1+0200,1510,"  "+aDadosTit[7]+aDadosTit[1],oFont10) //Prefixo +Numero+Parcela

oPrint:Say  (nRow1+0150,1910,"Motivo devolução:"                         	,oFont8)

oPrint:Say  (nRow1+0250,0100 ,"Sacado:",oFont8)
oPrint:Say  (nRow1+0280,0100 ,Left(aDatSacado[1],42),oFont10)				//Nome
if aDatSacado[8] = "J"
oPrint:Say  (nRow1+0310,0100,"CNPJ: "+TRANSFORM(aDatSacado[7],"@R 99.999.999/9999-99"),oFont10) // CGC
Else
oPrint:Say  (nRow1+0310,0100,"CPF: "+TRANSFORM(aDatSacado[7],"@R 999.999.999-99"),oFont10) 	// CPF
EndIf
oPrint:Say  (nRow1+350,0100 ,Substr(aDatSacado[3],1,50)                              ,oFont9n)
oPrint:Say  (nRow1+380,0100 ,aDatSacado[6]+"    "+aDatSacado[4]+" - "+aDatSacado[5]  ,oFont9n) // CEP+Cidade+Estado

oPrint:Say  (nRow1+0250,1060,"Vencimento:",oFont8)
oPrint:Say  (nRow1+0300,1060,"  "+StrZero(Day(aDadosTit[4]),2) +"/"+ StrZero(Month(aDadosTit[4]),2) +"/"+ Right(Str(Year(aDadosTit[4])),4),oFont10)

oPrint:Say  (nRow1+0250,1510,"Valor do Documento:",oFont8)
oPrint:Say  (nRow1+0300,1510,"  R$ "+AllTrim(Transform(aDadosTit[5],"@E 999,999,999.99")),oFont10)

oPrint:Say  (nRow1+0350,1060,"Espécie Doc. / Nosso Numero:",oFont8)
oPrint:Say  (nRow1+0400,1060,"  DM "+"/"+" "+ StrZero(Val(aDadosTit[6]),7) ,oFont10)
oPrint:Say  (nRow1+0350,1510,"Multa por dia:",oFont8)
oPrint:Say  (nRow1+0400,1510,"  R$ "+AllTrim(Transform(aDadosTit[5]*9/30/100,"@E 99,999.99"))          ,oFont10)

oPrint:Say  (nRow1+0480,0100,"DECLARAMOS TER RECEBIDO ESTE TÍTULO, REFERENTE À PRESTAÇÃO DE SERVIÇOS, PARA ACEITE.",oFont9)
oPrint:Say  (nRow1+0550,0310,"_____ / _____ / _____              __________________________________________",oFont10)

oPrint:Line (nRow1+0250,0100,nRow1+0250,1900 )
oPrint:Line (nRow1+0350,1050,nRow1+0350,1900 )
oPrint:Line (nRow1+0450,0100,nRow1+0450,1900 ) //---

For jj:=0 to 6 Step 1
oPrint:Line (nRow1+0620+jj, 100,nRow1+0620+jj,2300 )
Next

oPrint:Line (nRow1+0450,1050,nRow1+0150,1050 )
oPrint:Line (nRow1+0450,1500,nRow1+0150,1500 ) //--
oPrint:Line (nRow1+0620,1900,nRow1+0150,1900 )

oPrint:Say  (nRow1+0205,1910,"(  ) Mudou-se"                                	,oFont8)
oPrint:Say  (nRow1+0245,1910,"(  ) Ausente"                                    ,oFont8)
oPrint:Say  (nRow1+0285,1910,"(  ) Não existe nº indicado"                  	,oFont8)
oPrint:Say  (nRow1+0325,1910,"(  ) Recusado"                                	,oFont8)
oPrint:Say  (nRow1+0365,1910,"(  ) Não procurado"                              ,oFont8)
oPrint:Say  (nRow1+0405,1910,"(  ) Endereço insuficiente"                  	,oFont8)
oPrint:Say  (nRow1+0445,1910,"(  ) Desconhecido"                            	,oFont8)
oPrint:Say  (nRow1+0485,1910,"(  ) Falecido"                                   ,oFont8)
oPrint:Say  (nRow1+0525,1910,"(  ) Outros (anotar no verso)"                  	,oFont8)
*/

/*****************/
/* SEGUNDA PARTE */
/*****************/


nRow2 := 0
nLinH := 2200 
//nRow2 := -150 //RBORGES 02/08/2013

//Pontilhado separador
For nI := 100 to nLinH step 25 //For nI := 100 to 2280 step 25 rborges 05/08/2013
	oPrint:Line(nRow2+0580, nI,nRow2+0580, nI+15)
Next nI

For jj:=1 to 2 Step 1
	oPrint:Line (nRow2+0708+jj,100,nRow2+0708+jj,nLinH,,"+1")
	oPrint:Line (nRow2+0710,503+jj,nRow2+0630, 503+jj,,"+1") 
	oPrint:Line (nRow2+0710,713+jj,nRow2+0630, 713+jj,,"+1")
Next

//oPrint:FillRect({nRow2+0710,1800,nRow2+0810,2300},oBrush)
//oPrint:FillRect({nRow2+0980,1800,nRow2+1050,2300},oBrush)
//oPrint:FillRect({nRow2+1330,1800,nRow2+1400,2300},oBrush)

//cBitMap:= "LOGO_REAL.BMP"
//oPrint:SayBitmap(nRow2+0625,095,cBitMap,0065,080 )
oPrint:SayBitmap(nRow2+0625,095,cBitMap,0310,080 )
oPrint:Say  (nRow2+0620,1790,"Recibo do Pagador",oFont10)
//oPrint:Say  (nRow2+0625,170,"BANCO REAL",oFont13 )	// [2]Nome do Banco
//oPrint:Say  (nRow2+0668,170,"ABN AMRO",oFont8 )	// [2]Nome do Banco
oPrint:Say  (nRow2+0685,530,cCodBco,oFont18 )	    //+50 [1]Numero do Banco
oPrint:Say  (nRow2+0673,740,aCB_RN_NN[2],oFont14n)	//+35		Linha Digitavel do Codigo de Barras


oPrint:Line (nRow2+0810,100,nRow2+0810,nLinH )
oPrint:Line (nRow2+0910,100,nRow2+0910,nLinH )
oPrint:Line (nRow2+0980,100,nRow2+0980,nLinH )
oPrint:Line (nRow2+1050,100,nRow2+1050,nLinH )

oPrint:Line (nRow2+0910,500,nRow2+1050,500)
oPrint:Line (nRow2+0980,750,nRow2+1050,750)
oPrint:Line (nRow2+0910,1000,nRow2+1050,1000)
oPrint:Line (nRow2+0910,1300,nRow2+0980,1300)
oPrint:Line (nRow2+0910,1480,nRow2+1050,1480)

oPrint:Say  (nRow2+0740,100 ,"Local de Pagamento:",oFont8)//+30
oPrint:Say  (nRow2+0775,100 ,"Pagável em qualquer Banco até o vencimento.",oFont10)//+30


oPrint:Say  (nRow2+0740,1810,"Vencimento:"                                    ,oFont8)//+30 
cString	:= StrZero(Day(aDadosTit[4]),2) +"/"+ StrZero(Month(aDadosTit[4]),2) +"/"+ Right(Str(Year(aDadosTit[4])),4)
nCol := 1870+(354-(len(cString)*22))//-30 
oPrint:Say  (nRow2+0780,nCol,cString,oFont11c)//+30 

oPrint:Say  (nRow2+0840,100 ,"Beneficiário:"                                        ,oFont8)//+30 
oPrint:Say  (nRow2+0880,100 ,AllTrim(aDadosEmp[1])+" - "+aDadosEmp[6]	,oFont10) //Nome + CNPJ

oPrint:Say  (nRow2+0840,1810,"Agência/Código Beneficiário:",oFont8)
cString := Alltrim(aDadosBanco[3]+"/"+aDadosBanco[4]+iif(RIGHT(aDadosBanco[4],1)="-","","-")+aDadosBanco[5])
nCol := 1880+(354-(len(cString)*22))//-10 
oPrint:Say  (nRow2+0880,nCol,cString,oFont11c)//+30 

oPrint:Say  (nRow2+0940,100 ,"Data do Documento:"                              ,oFont8)//+30 
oPrint:Say  (nRow2+0970,100, StrZero(Day(aDadosTit[2]),2) +"/"+ StrZero(Month(aDadosTit[2]),2) +"/"+ Right(Str(Year(aDadosTit[2])),4),oFont10)//+30 

oPrint:Say  (nRow2+0940,505 ,"Nro.Documento:"                                  ,oFont8)//+30 
oPrint:Say  (nRow2+0970,605 ,aDadosTit[7]+aDadosTit[1]						,oFont10) //+30  Prefixo +Numero+Parcela

oPrint:Say  (nRow2+0940,1005,"Espécie Doc.:"                                   ,oFont8)//+30 
oPrint:Say  (nRow2+0970,1050,"DM"										,oFont10) //+30 Tipo do Titulo

oPrint:Say  (nRow2+0940,1305,"Aceite:"                                         ,oFont8)//+30 
oPrint:Say  (nRow2+0970,1400,aDadosBanco[7]                                    ,oFont10)//+30 

oPrint:Say  (nRow2+0940,1485,"Data do Processamento:"                          ,oFont8)//+30 
oPrint:Say  (nRow2+0970,1550,StrZero(Day(aDadosTit[3]),2) +"/"+ StrZero(Month(aDadosTit[3]),2) +"/"+ Right(Str(Year(aDadosTit[3])),4),oFont10) // +30 Data impressao

oPrint:Say  (nRow2+0940,1810,"Nosso Número:"                                   ,oFont8)//+30 
nCol := 1890+(354-(len(aCB_RN_NN[3])*22)) 
oPrint:Say  (nRow2+0970,nCol,aCB_RN_NN[3],oFont11c)

oPrint:Say  (nRow2+1010,100 ,"Uso do Banco:"                                   ,oFont8)//+30 

oPrint:Say  (nRow2+1010,505 ,"Carteira:"                                       ,oFont8)//+30 
oPrint:Say  (nRow2+1040,555 ,aDadosBanco[6]                                  	,oFont10)//+30 

oPrint:Say  (nRow2+1010,755 ,"Espécie:"                                        ,oFont8)//+30 
oPrint:Say  (nRow2+1040,805 ,"R$"                                             ,oFont10)//+30 

oPrint:Say  (nRow2+1010,1005,"Quantidade:"                                     ,oFont8)//+30 
oPrint:Say  (nRow2+1010,1485,"Valor:"                                          ,oFont8)//+30 

oPrint:Say  (nRow2+1010,1810,"(=) Valor do Documento:"                          	,oFont8)//+30 
cString := Alltrim(Transform(aDadosTit[5],"@E 99,999,999.99"))
nCol := 1850+(354-(len(cString)*22))//-50
oPrint:Say  (nRow2+1040,nCol,cString ,oFont11c)//+30 

oPrint:Say  (nRow2+1080,100 ,"Instruções:",oFont8)
oPrint:Say  (nRow2+1130,120 ,"Juros de Mora dia - R$ "+AllTrim(Transform(aDadosTit[5]*SuperGetMV("MV_DIPJURM",,6)/30/100,"@E 99,999.99")),oFont10)//+30 
oPrint:Say  (nRow2+1170,120 ,"Sujeito a Protesto apos 05 (cinco) dias do vencimento",oFont10)//+30 
If aDadosTit[9] > 0 // Desconto financeiro MCVN - 05/06/09
	oPrint:Say  (nRow2+1210,120 ,"Conceder desconto de - R$ "+AllTrim(Transform(aDadosTit[5]*aDadosTit[9]/100,"@E 99,999.99")+" para pagto. efetuado até o vencimento"),oFont10)//+30 
Endif

oPrint:Say  (nRow2+1080,1810,"(+) Outros Acréscimos:"                           ,oFont8)//+30 
oPrint:Say  (nRow2+1150,1810,"(-) Desconto / Abatimento:"                       ,oFont8)//+30 
oPrint:Say  (nRow2+1220,1810,"(-) Outras Deduções:"                             ,oFont8)//+30 
oPrint:Say  (nRow2+1290,1810,"(+) Mora/Multa:"                                  ,oFont8)//+30 
oPrint:Say  (nRow2+1360,1810,"(=) Valor Cobrado:"                               ,oFont8)//+30 

oPrint:Say  (nRow2+1430,100 ,"Pagador:"                                         ,oFont8)//+30 
oPrint:Say  (nRow2+1430,250 ,aDatSacado[1]+" ("+aDatSacado[2]+")"             ,oFont10)//+30 

if aDatSacado[8] = "J"
	oPrint:Say  (nRow2+1430,1770,"CNPJ: "+TRANSFORM(aDatSacado[7],"@R 99.999.999/9999-99"),oFont10) //+30-30 CGC 
Else
	oPrint:Say  (nRow2+1430,1770,"CPF: "+TRANSFORM(aDatSacado[7],"@R 999.999.999-99"),oFont10) 	//+30-30 CPF
EndIf

oPrint:Say  (nRow2+1465,0250 ,aDatSacado[3]                                    ,oFont10)//+30 
oPrint:Say  (nRow2+1500,0250 ,aDatSacado[6]+"    "+aDatSacado[4]+" - "+aDatSacado[5],oFont10) //+30  CEP+Cidade+Estado
oPrint:Say  (nRow2+1500,1600,Substr(aDadosTit[6],1,3)+Substr(aDadosTit[6],4)  ,oFont10)//+30 

oPrint:Say  (nRow2+1560,0100 ,"Sacador/Avalista: "+AllTrim(aDadosEmp[1])+" - "+aDadosEmp[6],oFont8)//+25
oPrint:Say  (nRow2+1560,1720 ,"Código de Baixa"									,oFont8)//+25 
oPrint:Say  (nRow2+1610,1680 ,"Autenticação Mecânica"							,oFont8)//+25 

oPrint:Line (nRow2+0710,1800,nRow2+1400,1800)
oPrint:Line (nRow2+1120,1800,nRow2+1120,nLinH )
oPrint:Line (nRow2+1190,1800,nRow2+1190,nLinH )
oPrint:Line (nRow2+1260,1800,nRow2+1260,nLinH )
oPrint:Line (nRow2+1330,1800,nRow2+1330,nLinH )
oPrint:Line (nRow2+1400,100 ,nRow2+1400,nLinH )
For jj:=1 to 2 Step 1
	oPrint:Line (nRow2+1575+jj,100 ,nRow2+1575+jj,nLinH,,"+1")
Next

/******************/
/* TERCEIRA PARTE */
/******************/

nRow3 := -0050


For nI := 100 to nLinH step 25
	oPrint:Line(nRow3+1880, nI, nRow3+1880, nI+15)
Next nI

For jj := 1 to 2 Step 1
	oPrint:Line (nRow3+2000+jj,100,nRow3+2000+jj,nLinH,,"+1")
	oPrint:Line (nRow3+2000,503+jj,nRow3+1920, 503+jj,,"+1")
	oPrint:Line (nRow3+2000,713+jj,nRow3+1920, 713+jj,,"+1")
Next

//oPrint:FillRect({nRow3+2000,1800,nRow3+2100,2300},oBrush)
//oPrint:FillRect({nRow3+2200,1800,nRow3+2270,2300},oBrush)
//oPrint:FillRect({nRow3+2620,1800,nRow3+2690,2300},oBrush)

//oPrint:Say  (nRow3+1934,100,aDadosBanco[2],oFont14 )		// 	[2]Nome do Banco
//cBitMap:= "LOGO_REAL.BMP"
//oPrint:SayBitmap(nRow3+1915,095,cBitMap,0065,080 )
oPrint:SayBitmap(nRow3+1915,095,cBitMap,0310,080 )
//oPrint:Say  (nRow3+1915,170,"BANCO REAL",oFont13 )	// [2]Nome do Banco
//oPrint:Say  (nRow3+1958,170,"ABN AMRO",oFont8 )	// [2]Nome do Banco
oPrint:Say  (nRow3+1975,530,cCodBco,oFont18 )	//+050 	[1]Numero do Banco 
oPrint:Say  (nRow3+1969,740,aCB_RN_NN[2],oFont14n)//+035		Linha Digitavel do Codigo de Barras

oPrint:Line (nRow3+2100,100,nRow3+2100,nLinH )
oPrint:Line (nRow3+2200,100,nRow3+2200,nLinH )
oPrint:Line (nRow3+2270,100,nRow3+2270,nLinH )
oPrint:Line (nRow3+2340,100,nRow3+2340,nLinH )

oPrint:Line (nRow3+2200,500 ,nRow3+2340,500 )
oPrint:Line (nRow3+2270,750 ,nRow3+2340,750 )
oPrint:Line (nRow3+2200,1000,nRow3+2340,1000)
oPrint:Line (nRow3+2200,1300,nRow3+2270,1300)
oPrint:Line (nRow3+2200,1480,nRow3+2340,1480)

oPrint:Say  (nRow3+2030,100 ,"Local de Pagamento:",oFont8)//+030
oPrint:Say  (nRow3+2075,100 ,"Pagável em qualquer Banco até o vencimento.",oFont10)//+030

oPrint:Say  (nRow3+2030,1810,"Vencimento:",oFont8) //+030
cString := StrZero(Day(aDadosTit[4]),2) +"/"+ StrZero(Month(aDadosTit[4]),2) +"/"+ Right(Str(Year(aDadosTit[4])),4)
nCol	 	 := 1870+(354-(len(cString)*22))//-030
oPrint:Say  (nRow3+2070,nCol,cString,oFont11c)//+030

oPrint:Say  (nRow3+2130,100 ,"Beneficiário:",oFont8)//+030
oPrint:Say  (nRow3+2170,100 ,AllTrim(aDadosEmp[1])+" - "+aDadosEmp[6]	,oFont10) //+030 Nome + CNPJ

oPrint:Say  (nRow3+2130,1810,"Agência/Código Beneficiário:",oFont8)//+030
cString := Alltrim(aDadosBanco[3]+"/"+aDadosBanco[4]+iif(RIGHT(aDadosBanco[4],1)="-","","-")+aDadosBanco[5])
nCol 	 := 1880+(354-(len(cString)*22))//-010
oPrint:Say  (nRow3+2170,nCol,cString ,oFont11c)//+030


oPrint:Say  (nRow3+2230,100 ,"Data do Documento:"                              ,oFont8)//+030
oPrint:Say (nRow3+2260,100, StrZero(Day(aDadosTit[2]),2) +"/"+ StrZero(Month(aDadosTit[2]),2) +"/"+ Right(Str(Year(aDadosTit[2])),4), oFont10)//+030


oPrint:Say  (nRow3+2230,505 ,"Nro.Documento:"                                  ,oFont8)//+030
oPrint:Say  (nRow3+2260,605 ,aDadosTit[7]+aDadosTit[1]						,oFont10) //+030 Prefixo +Numero+Parcela

oPrint:Say  (nRow3+2230,1005,"Espécie Doc.:"                                   ,oFont8)//+030
oPrint:Say  (nRow3+2260,1050,"DM"	  									,oFont10) //+030 Tipo do Titulo

oPrint:Say  (nRow3+2230,1305,"Aceite:"                                         ,oFont8)//+030
oPrint:Say  (nRow3+2260,1400,aDadosBanco[7]                                    ,oFont10)//+030

oPrint:Say  (nRow3+2230,1485,"Data do Processamento:"                          ,oFont8)//+030
oPrint:Say  (nRow3+2260,1550,StrZero(Day(aDadosTit[3]),2) +"/"+ StrZero(Month(aDadosTit[3]),2) +"/"+ Right(Str(Year(aDadosTit[3])),4)                               ,oFont10) //+030 Data impressao


oPrint:Say  (nRow3+2230,1810,"Nosso Número:"                                   ,oFont8)//+030
nCol 	 := 1860+(354-(len(aCB_RN_NN[3])*22))//-030
oPrint:Say  (nRow3+2260,nCol,aCB_RN_NN[3],oFont11c)//+030


oPrint:Say  (nRow3+2300,100 ,"Uso do Banco:"                                   ,oFont8)//+030

oPrint:Say  (nRow3+2300,505 ,"Carteira:"                                       ,oFont8)//+030
oPrint:Say  (nRow3+2330,555 ,aDadosBanco[6]                       				,oFont10)//+030

oPrint:Say  (nRow3+2300,755 ,"Espécie:"                                        ,oFont8)//+030
oPrint:Say  (nRow3+2330,805 ,"R$"                                             ,oFont10)//+030

oPrint:Say  (nRow3+2300,1005,"Quantidade:"                                     ,oFont8)//+030
oPrint:Say  (nRow3+2300,1485,"Valor:"                                          ,oFont8)//+030

oPrint:Say  (nRow3+2300,1810,"(=) Valor do Documento:"                       	,oFont8)//+030
cString  := Alltrim(Transform(aDadosTit[5],"@E 99,999,999.99"))
nCol 	 := 1850+(354-(len(cString)*22))//-050
oPrint:Say  (nRow3+2330,nCol,cString,oFont11c)//+030

oPrint:Say  (nRow3+2370,100 ,"Instruções:",oFont8)//+030
oPrint:Say  (nRow3+2420,120 ,"Juros de Mora Dia - R$ "+AllTrim(Transform(aDadosTit[5]*SuperGetMV("MV_DIPJURM",,6)/30/100,"@E 99,999.99")),oFont10)//+030
oPrint:Say  (nRow3+2460,120 ,"Sujeito a Protesto apos 05 (cinco) dias do vencimento",oFont10)//+030
If aDadosTit[9] > 0 // Desconto financeiro MCVN - 05/06/09
	oPrint:Say  (nRow3+2500,120 ,"Conceder desconto de - R$ "+AllTrim(Transform(aDadosTit[5]*aDadosTit[9]/100,"@E 99,999.99")+" para pagto. efetuado até o vencimento"),oFont10)//+030
Endif


oPrint:Say  (nRow3+2370,1810,"(+) Outros Acréscimos:"                           ,oFont8)//+030
oPrint:Say  (nRow3+2440,1810,"(-) Desconto / Abatimento:"                       ,oFont8)//+030
oPrint:Say  (nRow3+2510,1810,"(-) Outras Deduções:"                             ,oFont8)//+030
oPrint:Say  (nRow3+2580,1810,"(+) Mora/Multa:"                                  ,oFont8)//+030
oPrint:Say  (nRow3+2650,1810,"(=) Valor Cobrado:"                               ,oFont8)//+030

oPrint:Say  (nRow3+2720,100 ,"Pagador:"                                       ,oFont8)//+030
oPrint:Say  (nRow3+2720,250 ,aDatSacado[1]+" ("+aDatSacado[2]+")"             ,oFont10)//+030

if aDatSacado[8] = "J"
	oPrint:Say  (nRow3+2720,1800,"CNPJ: "+TRANSFORM(aDatSacado[7],"@R 99.999.999/9999-99"),oFont10) //+030 CGC
Else
	oPrint:Say  (nRow3+2720,1800,"CPF: "+TRANSFORM(aDatSacado[7],"@R 999.999.999-99"),oFont10) 	//+030 CPF
EndIf

oPrint:Say  (nRow3+2755,0250 ,aDatSacado[3]                                    ,oFont10)//+030
oPrint:Say  (nRow3+2790,0250 ,aDatSacado[6]+"    "+aDatSacado[4]+" - "+aDatSacado[5],oFont10) //+030 CEP+Cidade+Estado
oPrint:Say  (nRow3+2790,1600,Substr(aDadosTit[6],1,3)+Substr(aDadosTit[6],4)  ,oFont10)//+030d

oPrint:Say  (nRow3+2845,0100 ,"Sacador/Avalista: "+AllTrim(aDadosEmp[1])+" - "+aDadosEmp[6],oFont8)//+030
oPrint:Say  (nRow3+2845,1840 ,"Código de Baixa"								  ,oFont8)//+030
oPrint:Say  (nRow3+2890,1800,"Autenticação Mecânica"                        ,oFont8)//+030
oPrint:Say  (nRow3+2970,1800,"Ficha de Compensação"                        ,oFont12)//+030

oPrint:Line (nRow3+2000,1800,nRow3+2690,1800 )
oPrint:Line (nRow3+2410,1800,nRow3+2410,nLinH )
oPrint:Line (nRow3+2480,1800,nRow3+2480,nLinH )
oPrint:Line (nRow3+2550,1800,nRow3+2550,nLinH )
oPrint:Line (nRow3+2620,1800,nRow3+2620,nLinH )
oPrint:Line (nRow3+2690,100 ,nRow3+2690,nLinH )
For jj:=1 to 2 Step 1
	oPrint:Line (nRow3+2855+jj,100 ,nRow3+2855+jj,nLinH,,"+1")
Next

//MSBAR("INT25",24.6,1.3,aCB_RN_NN[1],oPrint,.F.,Nil,Nil,0.025,1.3,Nil,Nil,"A",.F.)
//MSBAR("INT25",27.8,1.3,aCB_RN_NN[1],oPrint,.F.,Nil,Nil,0.025,1.3,Nil,Nil,"A",.F.)
 
 //RBORGES - 15/08/2013 - Alterada de MSBAR para FWMSBAR por causa da alteração da classe de JPG para PDF.
 oPrint:FWMSBAR("INT25",64,2, aCB_RN_NN[1],oPrint,.F.,Nil,.T.,0.025,1.3,.F.,"Arial",NIL,.F. ,0.025,1,.F.)
 //                 1   2  3        4        5     6   7   8   9    10  11   12    13  14 15 16 17
//FWMsPrinter():FWMsBAR("INT25",242,9,aCB_RN_NN[1],oPrint,.F.,Nil,Nil,0.08186,3.5,.F.,"A",,.F.,1, , )



//oPrint:Line (nRow3+3135,030 ,nRow3+3135,060 )
//oPrint:Line (nRow3+3120,035 ,nRow3+3145,035 )
//oPrint:Line (nRow3+3135,2330 ,nRow3+3135,2360 )
//oPrint:Line (nRow3+3125,2355 ,nRow3+3145,2355 )

/*
For nI := 100 to 2280 step 20
oPrint:Line(nRow3+3135, nI, nRow3+3135, nI+10)
Next nI
*/

oPrint:EndPage() // Finaliza a página



Return Nil



/*/
'ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ Modulo10 ³ Autor ³ Microsiga             ³ Data ³ 13/10/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ IMPRESSAO DO BOLETO LASE COM CODIGO DE BARRAS              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Especifico para Clientes Microsiga                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Modulo10(cData)
LOCAL L,D,P := 0
LOCAL B     := .F.
L := Len(cData)
B := .T.
D := 0
While L > 0
	P := Val(SubStr(cData, L, 1))
	If (B)
		P := P * 2
		If P > 9
			P := P - 9
		End
	End
	D := D + P
	L := L - 1
	B := !B
End
D := 10 - (Mod(D,10))
If D = 10
	D := 0
End
Return(D)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ Modulo11 ³ Autor ³ Microsiga             ³ Data ³ 13/10/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ IMPRESSAO DO BOLETO LASER COM CODIGO DE BARRAS             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Especifico para Clientes Microsiga                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function D23Mod11(cData)
LOCAL L, D, P := 0
L := Len(cdata)
D := 0
P := 1
While L > 0
	P := P + 1
	D := D + (Val(SubStr(cData, L, 1)) * P)
	If P = 9
		P := 1
	End
	L := L - 1
End
D := 11 - (mod(D,11))
If (D == 0 .Or. D == 1 .Or. D == 10 .Or. D == 11)
	D := 1
End
Return(D)


//***********************************************************************************
Static Function RCBReal(cBanco,cAgencia,cConta,cDacCC,cNroDoc,nValor,dVencto,cNNum,cCart)
//***********************************************************************************
LOCAL cValorFinal := strzero(int((nValor+nAjustVal)*100),10)
LOCAL nDvcb			:= 0
LOCAL nDv			:= 0
LOCAL cNN			:= ''
LOCAL cRN			:= ''
LOCAL cCB			:= ''
LOCAL cFator      	:= strzero(dVencto - ctod("07/10/97"),4)

cAgencia	:= StrZero(Val(cAgencia),4)
cConta 		:= StrZero(Val(cConta),7)

//-----------------------------
// Definicao do NOSSO NUMERO
// ----------------------------
cNN   := StrZero(Val(cNNum),13)

_cDC 	:= AllTrim(Str(modulo10(cNN + cAgencia + cConta)))
cDacCC 	:= _cDC
//----------------------------------
//	 Definicao da LINHA DIGITAVEL
//----------------------------------
//-------- Definicao da LINHA DIGITAVEL (Representacao Numerica)
//	Campo 1			Campo 2			Campo 3		 Campo 4	Campo 5
//	AAABC.CCCDX		DDDDD.DEFFFY	FFFFF.FFFFZ	 K			HHHHIIIIIIIIII

// 	CAMPO 1:
//	AAA	 		= Codigo do banco na Camara de Compensacao 356
//	  B  		= Codigo da moeda, sempre 9
//	CCCC 		= Agencia
//	  D  		= Primeiro digito na conta corrente
//	  X 		= DAC que amarra o campo, calculado pelo Modulo 10 da String do campo
_cBlc1 		:= cBanco + "9" + cAgencia + Substr(cConta,1,1)
_cDgBlc1 	:= AllTrim(Str(modulo10(_cBlc1)))


// 	CAMPO 2:
//	DDDDDD 		= Restante do numero da conta corrente
//  E			= Digito da Cobranca
//  FFF			= Tres primeiros digitos do Nosso Numero
//	  Y 		= DAC que amarra o campo, calculado pelo Modulo 10 da String do campo
_cBlc2 		:= Substr(cConta,2,7) + _cDC + Substr(cNN,1,3)
_cDgBlc2 	:= AllTrim(Str(modulo10(_cBlc2)))


// 	CAMPO 3:
//	FFFFFFFFFF 	= Restante do nosso numero
//	  Z 		= DAC que amarra o campo, calculado pelo Modulo 10 da String do campo
_cBlc3 		:= Substr(cNN,4,10)
_cDgBlc3 	:= AllTrim(Str(modulo10(_cBlc3)))


// 	CAMPO 4:
//  K			= Digitao do codigo de barras
K:= cBanco + "9" + cFator + cValorFinal + cAgencia + cConta + _cDC + cNN
_cDg_K := AllTrim(Str(D23Mod11(K)))


// 	CAMPO 5:
//	HHHH   		= Fator de Vencimento
//	IIIIIIIIII 	= Valor do Titulo
_cBlc4 		:= cFator + cValorFinal
//msgbox(_cBlc4)

cRN := Substr(_cBlc1 + _cDgBlc1,1,5)+"."+Substr(_cBlc1 + _cDgBlc1,6,5) + "   "
cRN := cRN + Substr(_cBlc2 + _cDgBlc2,1,5) + "." +Substr(_cBlc2 + _cDgBlc2,6,6) + "   "
cRN := cRN + Substr(_cBlc3 + _cDgBlc3,1,5) + "." +Substr(_cBlc3 + _cDgBlc3,6,6) + "   "
cRN := cRN + _cDg_K + "   " + _cBlc4


//----------------------------------
//	 Definicao do CODIGO DE BARRAS
//----------------------------------
cCB		:= cBanco + "9" + _cDg_K + cFator +  cValorFinal + cAgencia + cConta + _cDC + cNN
cNN		:= AllTrim(Str(val(cNN)))
Return({cCB,cRN,cNN})


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Ret_cBarra   ³Descri‡ão³Gera a codificacao da Linha digitav.³±±
±±³          ³             ³         ³gerando o codigo de barras.         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function RCBItau(cBanco,cAgencia,cConta,cDacCC,cNroDoc,nValor,dVencto,cNNum,cCart)
//
//LOCAL bldocnufinal := strzero(val(cNroDoc),8)
LOCAL blvalorfinal := strzero(int((nValor+nAjustVal)*100),10)
LOCAL dvnn         := 0
LOCAL dvcb         := 0
LOCAL dv           := 0
LOCAL NN           := ''
LOCAL RN           := ''
LOCAL CB           := ''
LOCAL s            := ''
LOCAL _cfator      := strzero(dVencto - ctod("07/10/97"),4)

cAgencia	:= StrZero(Val(cAgencia),4)
cConta 		:= StrZero(Val(cConta),6)
//
//-------- Definicao do NOSSO NUMERO
//s    :=  cAgencia + cConta + cCart + bldocnufinal
s    :=  cAgencia + Left(cConta,5) + cCart + cNroDoc
dvnn := modulo10(s) // digito verifacador Agencia + Conta + Carteira + Nosso Num
//NN   := cCart + bldocnufinal + '-' + AllTrim(Str(dvnn))
NN   := AllTrim(cNNum)
//
//	-------- Definicao do CODIGO DE BARRAS
s    := cBanco + "9" + _cfator + blvalorfinal + cCart + cNroDoc + AllTrim(Str(dvnn)) + cAgencia + cConta + '000'
dvcb := D23Mod11(s)
CB   := SubStr(s, 1, 4) + AllTrim(Str(dvcb)) + SubStr(s,5)
//
//-------- Definicao da LINHA DIGITAVEL (Representacao Numerica)
//	Campo 1			Campo 2			Campo 3			Campo 4		Campo 5
//	AAABC.CCDDX		DDDDD.DEFFFY	FGGGG.GGHHHZ	K			UUUUVVVVVVVVVV
//
// 	CAMPO 1:
//	AAA	= Codigo do banco na Camara de Compensacao - 341
//	  B = Codigo da moeda, sempre 9
//	CCC = Codigo da Carteira de Cobranca
//	 DD = Dois primeiros digitos no nosso numero
//	  X = DAC que amarra o campo, calculado pelo Modulo 10 da String do campo
//

//s    := cBanco +'9'+ cCart + SubStr(bldocnufinal,1,2)
s    := cBanco +'9'+ cCart + SubStr(cNroDoc,1,2)
dv   := modulo10(s)
RN   := SubStr(s, 1, 5) + '.' + SubStr(s, 6, 4) + AllTrim(Str(dv)) + '  '
//
// 	CAMPO 2:
//	DDDDDD = Restante do Nosso Numero
//	     E = DAC do campo Agencia/Conta/Carteira/Nosso Numero
//	   FFF = Tres primeiros numeros que identificam a agencia
//	     Y = DAC que amarra o campo, calculado pelo Modulo 10 da String do campo
//

//s    := SubStr(bldocnufinal, 3, 6) + AllTrim(Str(dvnn)) + SubStr(cAgencia, 1, 3)
s    := SubStr(cNroDoc, 3, 6) + AllTrim(Str(dvnn)) + SubStr(cAgencia, 1, 3)
dv   := modulo10(s)
RN   := RN + SubStr(s, 1, 5) + '.' + SubStr(s, 6, 5) + AllTrim(Str(dv)) + '  '
//
// 	CAMPO 3:
//	     F = Restante do numero que identifica a agencia
//	GGGGGG = Numero da Conta + DAC da mesma
//	   HHH = Zeros (Nao utilizado)
//	     Z = DAC que amarra o campo, calculado pelo Modulo 10 da String do campo
s    := SubStr(cAgencia, 4, 1) + cConta + '000'
dv   := modulo10(s)
RN   := RN + SubStr(s, 1, 5) + '.' + SubStr(s, 6, 5) + AllTrim(Str(dv)) + '  '
//
// 	CAMPO 4:
//	     K = DAC do Codigo de Barras
RN   := RN + AllTrim(Str(dvcb)) + '  '
//
// 	CAMPO 5:
//	      UUUU = Fator de Vencimento
//	VVVVVVVVVV = Valor do Titulo
RN   := RN + _cfator + StrZero(int((nValor+nAjustVal)*100),14-Len(_cfator))

NN 		:= cCart +"/"+SubStr(NN,1,8)+"-"+AllTrim(Str(dvnn))

cDacCC 	:= Right(cConta,1)
cConta 	:= Left(cConta,5)

Return({CB,RN,NN})

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Ret_cBarra   ³Descri‡ão³Gera a codificacao da Linha digitav.³±±
±±³          ³             ³         ³gerando o codigo de barras.         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function RCBBrad(cBanco,cAgencia,cConta,cDacCC,cNroDoc,nValor,dVencto,cNNum,cCart)
//
LOCAL blvalorfinal := strzero(int((nValor+nAjustVal)*100),10)
LOCAL dvnn         := 0
LOCAL dvcb         := 0
LOCAL dv           := 0
LOCAL NN           := ''
LOCAL RN           := ''
LOCAL CB           := ''
LOCAL s            := ''
LOCAL _cfator      := strzero(dVencto - ctod("07/10/97"),4)

cDacCC		:= Right(cConta,1)
cAgencia	:= StrZero(Val(cAgencia),4)
cConta 		:= StrZero(Val(Left(cConta,Len(cConta)-1)),7)
cCart		:= StrZero(Val(cCart),2)
//
//-------- Definicao do NOSSO NUMERO
NN   := Left(cNNum,11)
//
//	-------- Definicao do CODIGO DE BARRAS
s    := cBanco + "9" + _cfator + blvalorfinal + cAgencia + cCart + NN + cConta + '0'
dvcb := D23Mod11(s)
CB   := SubStr(s, 1, 4) + AllTrim(Str(dvcb)) + SubStr(s,5)
//
//-------- Definicao da LINHA DIGITAVEL (Representacao Numerica)
//	Campo 1			Campo 2			Campo 3			Campo 4		Campo 5
//	AAABC.CCCDX		DEEEE.FFFFFY	GGHHH.HHHHIZ	K			UUUUVVVVVVVVVV
//
// 	CAMPO 1:
//	AAA	= Codigo do banco na Camara de Compensacao - 341
//	  B = Codigo da moeda, sempre 9
// CCCC = Codigo da Agencia
//	  D = Primeiro digito da Carteira
//	  X = DAC que amarra o campo, calculado pelo Modulo 10 da String do campo
//

s    := cBanco +'9'+ cAgencia + Left(cCart,1)
dv   := modulo10(s)
RN   := SubStr(s, 1, 5) + '.' + SubStr(s, 6, 4) + AllTrim(Str(dv)) + '  '
//
// 	CAMPO 2:
//	     D = Restante da Carteira
//	  EEEE = Quatro primeiros digitos do NN
//	 FFFFF = Proximos Cinco digitos do NN
//	     Y = DAC que amarra o campo, calculado pelo Modulo 10 da String do campo
//

s    := Substr(cCart,2,1)+Substr(NN,1,4)+Substr(NN,5,5)
dv   := modulo10(s)
RN   := RN + SubStr(s, 1, 5) + '.' + SubStr(s, 6, 5) + AllTrim(Str(dv)) + '  '
//
// 	CAMPO 3:
//	    GG = Restante do NN
// HHHHHHH = Conta
//	     I = Zeros (Nao utilizado)
//	     Z = DAC que amarra o campo, calculado pelo Modulo 10 da String do campo
s    := Substr(NN,10,2)+cConta + '0'
dv   := modulo10(s)
RN   := RN + SubStr(s, 1, 5) + '.' + SubStr(s, 6, 5) + AllTrim(Str(dv)) + '  '
//
// 	CAMPO 4:
//	     K = DAC do Codigo de Barras
RN   := RN + AllTrim(Str(dvcb)) + '  '
//
// 	CAMPO 5:
//	      UUUU = Fator de Vencimento
//	VVVVVVVVVV = Valor do Titulo
RN   := RN + _cfator + StrZero(int((nValor+nAjustVal)*100),14-Len(_cfator))

NN	:= cCart+"/"+SubsTr(cNNum,1,2)+"/"+Substr(cNNum,3,9)+"-"+Substr(cNNum,12,1)

Return({CB,RN,NN})


/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ DIPM23BLT  ³ Autor ³ Maximo                	³ Data ³ 13/12/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Tela que permite a alteração do Banco no MV_A1_BLTS            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Especifico Dipromed                                  		  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
              
User Function DIPM23BLT() //User Function DIPM23BLT() -BORGES


Local _nOpcBco      := 0
Local _cDadosAtuais := ""
Local _cMV_BcoAuto  := GetMV("MV_BCOAUTO")
Local _cUsuario     := Upper(GetMV("MV_A1_BLTS"))



_cBco         := SPACE(03)
_cAgencia     := SPACE(05)
_cCC          := SPACE(10)

_cDadosAtuais := "Banco: "+Left(_cMV_BcoAuto,3)+"  -  Agência: "+Substr(_cMV_BcoAuto,5,5)+"  -  C/C: "+Substr(_cMV_BcoAuto,11,10)


@ 126,000 To 310,350 DIALOG oDlg TITLE OemToAnsi("Altera dados bancarios para impressao de boleto")
@ 010,010 Say "DADOS ATUAIS:  "
@ 020,010 Say _cDadosAtuais
@ 035,010 Say "Banco: "
@ 035,060 Get _cBco  Size 20,20
@ 050,010 say 'Agencia:'
@ 050,060 get _cAgencia Size 30,20
@ 065,010 say "Cta. Corrente:
@ 065,060 get _cCC Size 45,20
@ 080,100 BMPBUTTON TYPE 1 ACTION (_nOpcBco := 1,Close(odlg))
@ 080,140 BMPBUTTON TYPE 2 ACTION (_nOpcBco := 0,Close(odlg))
ACTIVATE DIALOG oDlg Centered


If Upper(U_DipUsr()) $ _cUsuario
	//If Upper(U_DipUsr()) $ ('JURACI/ERIBERTO/MAXIMO')
	If _nOpcBco == 1
		If MsgYesNo("Confirma a alteração dos dados bancários?")
			SetMv("MV_BCOAUTO",_cBco+"/"+Alltrim(_cAgencia)+"/"+Alltrim(_cCC))
			MsgInfo("Alteração efetuada com sucesso!   Banco: "+_cBco+"  -  Agência: "+_cAgencia+"  -  C/C: "+Alltrim(_cCC))
		Endif
	Endif
Else
	MsgInfo("Você não tem autorização para alterar dados bancários. Contate o Administrador!")
Endif

Return()


/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ AjustaSx1    ³ Autor ³ Microsiga            	³ Data ³ 13/10/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Verifica/cria SX1 a partir de matriz para verificacao          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Especifico para Clientes Microsiga                     		  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function AjustaSX1(cPerg, aPergs)

Local _sAlias	:= Alias()
Local aCposSX1	:= {}
Local nX 		:= 0
Local lAltera	:= .F.
Local nCondicao
Local cKey		:= ""
Local nJ		:= 0

cPerg := PADR(cPerg, Len(SX1->X1_GRUPO)," " ) // Incluido por Sandro em 18/11/09.

aCposSX1:={"X1_PERGUNT","X1_PERSPA","X1_PERENG","X1_VARIAVL","X1_TIPO","X1_TAMANHO",;
"X1_DECIMAL","X1_PRESEL","X1_GSC","X1_VALID",;
"X1_VAR01","X1_DEF01","X1_DEFSPA1","X1_DEFENG1","X1_CNT01",;
"X1_VAR02","X1_DEF02","X1_DEFSPA2","X1_DEFENG2","X1_CNT02",;
"X1_VAR03","X1_DEF03","X1_DEFSPA3","X1_DEFENG3","X1_CNT03",;
"X1_VAR04","X1_DEF04","X1_DEFSPA4","X1_DEFENG4","X1_CNT04",;
"X1_VAR05","X1_DEF05","X1_DEFSPA5","X1_DEFENG5","X1_CNT05",;
"X1_F3", "X1_GRPSXG", "X1_PYME","X1_HELP" }

dbSelectArea("SX1")
dbSetOrder(1)


For nX:=1 to Len(aPergs)
	lAltera := .F.
	If MsSeek(cPerg+Right(aPergs[nX][11], 2))
		If (ValType(aPergs[nX][Len(aPergs[nx])]) = "B" .And.;
			Eval(aPergs[nX][Len(aPergs[nx])], aPergs[nX] ))
			aPergs[nX] := ASize(aPergs[nX], Len(aPergs[nX]) - 1)
			lAltera := .T.
		Endif
	Endif
	
	If ! lAltera .And. Found() .And. X1_TIPO <> aPergs[nX][5]
		lAltera := .T.		// Garanto que o tipo da pergunta esteja correto
	Endif
	
	If ! Found() .Or. lAltera
		RecLock("SX1",If(lAltera, .F., .T.))
		Replace X1_GRUPO with cPerg
		Replace X1_ORDEM with Right(aPergs[nX][11], 2)
		For nj:=1 to Len(aCposSX1)
			If 	Len(aPergs[nX]) >= nJ .And. aPergs[nX][nJ] <> Nil .And.;
				FieldPos(AllTrim(aCposSX1[nJ])) > 0
				Replace &(AllTrim(aCposSX1[nJ])) With aPergs[nx][nj]
			Endif
		Next nj
		MsUnlock()
		cKey := "P."+AllTrim(X1_GRUPO)+AllTrim(X1_ORDEM)+"."
		
		
		If ValType(aPergs[nx][Len(aPergs[nx])]) = "A"
			aHelpSpa := aPergs[nx][Len(aPergs[nx])]
		Else
			aHelpSpa := {}
		Endif
		
		If ValType(aPergs[nx][Len(aPergs[nx])-1]) = "A"
			aHelpEng := aPergs[nx][Len(aPergs[nx])-1]
		Else
			aHelpEng := {}
		Endif
		
		If ValType(aPergs[nx][Len(aPergs[nx])-2]) = "A"
			aHelpPor := aPergs[nx][Len(aPergs[nx])-2]
		Else
			aHelpPor := {}
		Endif
		
		PutSX1Help(cKey,aHelpPor,aHelpEng,aHelpSpa)
	Endif
Next

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PdfMail  ºAutor  ³Microsiga           º Data ³  22/04/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ DIPM023                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function PdfMail()//RBORGES 12/08/2013 - Manutenção para alterar a forma de envio de e-mail em JPEG por envio em PDF. 

//imagem boa qualidade
Local nLargura := 920
Local nAltura  := 1300
Local nZoom    := 145                              
Local cMailFina:= GetNewPar("ES_M23MAIL","luciana.matiazzo@dipromed.com.br;notafiscal@dipromed.com.br")

Local cAccount  := Lower(Alltrim(GetMv("MV_RELACNT")))
Local cFrom     := Lower(Alltrim(GetMv("MV_RELACNT")))
Local cPassword := Alltrim(GetMv("MV_RELPSW"))
Local cServer   := Alltrim(GetMv("MV_RELSERV"))
Local cCC		:= ""//cMailFina
Local cBCC      := "maximo.canuto@dipromed.com.br"
Local cTo		:= cMailFina//AllTrim(SA1->A1_EMAIL)
Local cAnexos	:= "\RELATO\PDF\"+cPrefixo+".pdf"
Local lSmtpAuth := .F. // .T. se o servidor requer autenticacao de SMTP.
Local lAutOk	:= .T.
Local nI

  
// Busca o Grupo de cliente no Cadastro de Cliente - MCVN 26/08/11
/*If Posicione ('SA1', 1, xFilial('SA1') + SF2->F2_CLIENTE + SF2->F2_LOJA, 'A1_GRPVEN') == '000031'
	If Empty(AllTrim(SA1->A1_EMAILD))
		cTo += ";"+GetNewPar("ES_DIP23CC","")		
	ElseIf Empty(AllTrim(GetNewPar("ES_DIP23CC","")))
		cTo += ";"+AllTrim(SA1->A1_EMAILD)
	Else
		cTo += ";"+AllTrim(SA1->A1_EMAILD)+';'+GetNewPar("ES_DIP23CC","")
	Endif
ElseIf SF2->F2_CLIENTE $ GetNewPar("ES_CLIMAIL","020719") .Or. SF2->F2_CLIENTE $ GetNewPar("ES_CPRMAIL","018461")
		cTo += ";" +If(SF2->F2_CLIENTE=='020719','beatriz.souza@unimedfesp.coop.br;faturamento.opme@unimedfesp.coop.br;amanda.pego@unimedfesp.coop.br;renata.santos@dipromed.com.br',Alltrim(Posicione ('SA1', 1, xFilial('SA1') + SF2->F2_CLIENTE + SF2->F2_LOJA, 'A1_EMAILD')))
ElseIf SA1->A1_BLTAUTO == "1"
		cTo += ";"+AllTrim(SA1->A1_XEMAILF) 
Endif */

//If AllTrim(SA1->A1_BLTAUTO) == "1"

If !(SF2->F2_COND$'001/002')
	If ((SA1->A1_BLTAUTO == "1" .And. Empty(SA1->A1_PORTADO))  .Or. (SF2->F2_COND $ ('354/052/051/504/661'))) .And. !("DIPA012" $ FUNNAME()) .AND. !Type("lDIPA039") <> "U" .And. !(SF2->F2_TIPO $ 'D/B')//Geração automática de Nota Fiscal

		cTo += ";"+AllTrim(SA1->A1_XEMAILF)
	
		If Posicione ('SA1', 1, xFilial('SA1') + SF2->F2_CLIENTE + SF2->F2_LOJA, 'A1_GRPVEN') == '000031'
			cTo += ";"+GetNewPar("ES_DIP23CC","")		
		ElseIf Empty(AllTrim(GetNewPar("ES_DIP23CC","")))
			cTo += ";"+AllTrim(SA1->A1_XEMAILF)
		Endif

		If SF2->F2_CLIENTE $ GetNewPar("ES_CLIMAIL","020719") .Or. SF2->F2_CLIENTE $ GetNewPar("ES_CPRMAIL","018461")
			cTo += ";" +If(SF2->F2_CLIENTE=='020719','beatriz.souza@unimedfesp.coop.br;faturamento.opme@unimedfesp.coop.br;amanda.pego@unimedfesp.coop.br;renata.santos@dipromed.com.br',Alltrim(Posicione ('SA1', 1, xFilial('SA1') + SF2->F2_CLIENTE + SF2->F2_LOJA, 'A1_XEMAILF')))
		Endif		

	Endif
EndIf 


cSubject := "Boleto(s) ref. a Nf:  " +SF2->F2_DOC+"-"+SF2->F2_SERIE+"  do cliente "+SF2->F2_CLIENTE+"-"+SF2->F2_LOJA+" - "+Posicione('SA1', 1, xFilial('SA1') + SF2->F2_CLIENTE + SF2->F2_LOJA, 'A1_NREDUZ')
cBody    :=  ("Segue em anexo "+cSubject+".")  

aMsg := {}
aAdd(aMsg,{"Obs:",cBody})

u_UEnvMail(cTo,cSubject,aMsg,cAnexos,cFrom,"PdfMail(DIPM023)")

/*
CONNECT SMTP SERVER cServer ACCOUNT cAccount PASSWORD cPassword Result lOk
If !lAutOk
	If ( lSmtpAuth )
		lAutOk := MailAuth(cAccount,cPassword)
	Else
		lAutOk := .T.
	EndIf
EndIf
If lOk .and. lAutOk
	If !Empty(cCC)
		SEND MAIL FROM cFrom TO cTo CC cCC BCC cBcc SUBJECT Alltrim(cSubject) BODY cBody ATTACHMENT cAnexos Result lOk
	Else
		SEND MAIL FROM cFrom TO cTo BCC cBcc SUBJECT  Alltrim(cSubject) BODY cBody ATTACHMENT cAnexos Result lOk
	EndIf
	If lOk
		MsgInfo("Email enviado com sucesso")
	Else
		GET MAIL ERROR cErro
		MsgStop("Não foi possível enviar o Email." +Chr(13)+Chr(10)+ cErro,"AVISO")
		Return .f.
	EndIf
Else
	GET MAIL ERROR cErro
	MsgStop("Erro na conexão com o SMTP Server." +Chr(13)+Chr(10)+ cErro,"AVISO")
	Return .f.
EndIf
DISCONNECT SMTP SERVER

*/  

Return .T.

*--------------------------------------------------------------------------*
Static Function DIPM23CIC()
// MCVN - 24/02/11
*--------------------------------------------------------------------------*
Local cMail
Local cServidor   := GetMV("MV_CIC")     // Servidor para enviar mensagem pelo CIC
Local cOpFatRem   := GetMV("MV_REMETCI") // Usuario do CIC remetente de mensgens no Protheus
Local cOpFatSenha := "123456"
Local cOpFatDest  := GetNewPar("ES_M23ECIC","LUCIANA.MATIAZZO,MAXIMO.CANUTO")

//
// Monta a mensagem a ser enviado ao operador
//

cMail := SM0->M0_NOME+" - "+SM0->M0_FILIAL+ Chr(13) + Chr(10)+ Chr(13) + Chr(10)
cMail += "IMPORTANTE"+ Chr(13) + Chr(10)+ Chr(13) + Chr(10)
//cMail += StrTran(cOpFatDest,',',' ou ')+ Chr(13) + Chr(10)+ Chr(13) + Chr(10)
cMail += "Daniela Baraldi" + Chr(13) + Chr(10)+ Chr(13) + Chr(10)
cMail += " Vocês acabaram de receber um e-mail com um BOLETO anexo referente ao título " +SF2->F2_DOC
cMail += " do Cliente "+AllTrim(SA1->A1_COD)+" - "+AllTrim(SA1->A1_NREDUZ)+"."+ Chr(13) + Chr(10)+ Chr(13) + Chr(10)
cMail += Upper("ENVIAR AO CLIENTE O MAIS RÁPIDO POSSÍVEL!" ) + Chr(13) + Chr(10)+ Chr(13) + Chr(10)
cMail += U_DipUsr()
//
// Envia a mensagem ao operador através do CIC
//
U_DIPCIC(cMail,AllTrim(cOpFatDest))// RBorges 12/03/15
//WaitRun(cServidor+' '+cOpFatRem+' '+cOpFatSenha+' "'+AllTrim(cOpFatDest)+'" "'+cMail+'" ') // Comentada 12/03/15
Return() 

/*=======================================================
 RBORGES - 10/11/2013  - FUNÇÃO:ImpBolHq
 Objetivo: Verificar se a nota é à vista ou faturada.
=======================================================*/

Static Function ImpBolHq(MV_PAR01,MV_PAR02,MV_PAR03)
Local lRet := .T.
Local cSQLB := ""
Local cMsg := ""
DEFAULT MV_PAR01 := ""
DEFAULT MV_PAR02 := ""
DEFAULT MV_PAR03 := ""


cSQL := " SELECT "
cSQL += " 	F2_COND"
cSQL += " 	FROM "
cSQL += " 	  "+RetSQlName("SF2")+", "+RetSQLName("SE1")
cSQL += " 		WHERE "
cSQL += " 			    E1_FILIAL  = '"+xFilial("SE1")+"' "
cSQL += " 			AND F2_FILIAL  = '"+xFilial("SF2")+"' "
cSQL += " 			AND E1_NUM     = F2_DOC     "
cSQL += " 			AND E1_SERIE   = F2_SERIE   "
cSQL += " 			AND E1_CLIENTE = F2_CLIENTE "
cSQL += " 			AND E1_LOJA    = F2_LOJA    "
cSQL += " 			AND E1_NUM       BETWEEN '"+MV_PAR02+"' AND '"+MV_PAR02+"' " 
cSQL += " 			AND E1_SERIE   = '"+MV_PAR01+"' "
cSQL += "		    AND F2_COND      NOT IN ("+CondPgtoAV+")"
cSQL += " 			AND "+RetSQlName("SE1")+".D_E_L_E_T_ = ' ' "
cSQL += " 			AND "+RetSQlName("SF2")+".D_E_L_E_T_ = ' ' "

cSQL := ChangeQuery(cSQL)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),"QRYSE",.T.,.T.)

lRet := QRYSE->(Eof())

QRYSE->(dbCloseArea())

Return lRet

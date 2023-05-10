#INCLUDE "RWMAKE.CH"
//#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "FILEIO.CH"
*-------------------------------------------*
User Function DIPR061()
*-------------------------------------------*
Local nOpcao := 0
Local cOper   := Alltrim(Posicione("SU7",4,xFilial("SU7")+Alltrim(RetCodUsr()),"U7_COD")) // OPERADOR
Local cUserLic:= GetMv("MV_OPERLIC") // Operador de Licita��o 
Private lMenu := .t.
Private aRadio:={}
Private aTipo:={}
Private nRadio:=0                 
Private _lObsProd := .F.
Private _lRascunho := .F.
Private cNroPedido:=Space(len(SC5->C5_NUM))
Private _lCartaVale    
Private _lFax := .F.       

U_DIPPROC(ProcName(0),U_DipUsr()) // MCVN - 22/01/2009

aRadio:={;
"Pedido de Venda",;
"Pedido de Licita��o",; 
"Pedido sem ICMS",;
"Or�amento de Venda",;
"Or�amento para Licita��o",;
"Or�amento sem ICMS"}
If cOper $ cUserLic //Mostra op��o de carta de vale s� para operadores de licita��o
	aadd(aRadio,"Carta de Vale")
Endif

@ 000,000 To 350,450 Dialog oDlg Title OemToAnsi("Impressao do Pedido/Or�amento")    
@ 010,020 say 'Numero do Pedido ou Or�amento'
@ 010,110 get cNroPedido picture '999999'  valid !Empty(cNroPedido) //F3 'SUA' 
@ 030,020 say "Escolha o Tipo de Documento"
@ 040,020 RADIO aRadio VAR nRadio
@ 110,020 CheckBox "Imprime Observa��o do Produto"  Var _lObsProd 
@ 120,020 CheckBox "Imprime como Rascunho"  Var _lRascunho 
@ 140,100 BmpButton Type 1 Action (If(Dipr061Valid('OK'),(nOpcao:=1,Close(oDlg)),nOpcao:=0))
@ 140,130 BmpButton Type 2 Action (nOpcao:=0,Close(oDlg))
Activate Dialog oDlg Centered
If nOpcao==1
   If nRadio>0.and.nRadio<4 .or. nRadio == 7
       If nRadio == 7
	       _lCartaVale := .T.
       Endif       
       U_UTMKR03_Menu()     

   ElseIf nRadio>=4.and.nRadio<=6
       U_UTMKR3A_Menu()   
   EndIf
EndIf
Return(.t.)                                   
*--------------------------------------------*
Static Function Dipr061Valid(cCampo)
*--------------------------------------------*
Local lretorno:=.t.
If cCampo == 'OK' .and. (nRadio < 1 .or. nRadio > 7)
	Aviso('Aten��o','N�o foi selecionado o tipo do documento',{'OK'})
    lRetorno:=.t. 
EndIf

SUA->(dbSetOrder(1))
If nRadio < 4  .or. nRadio == 7
   SUA->(dbSetOrder(8))
EndIf
   

If "DIPAL10" $ FunName() .And. (nRadio == 2 .OR. nRadio == 3 .OR. nRadio == 7)
	SC5->(DbSelectArea("SC5"))
	SC5->(DbSetOrder(1))
	If !(lRetorno:=SC5->(dbSeek(xFilial('SC5')+cNroPedido)))
   		Aviso('Aten��o','Numero de documento n�o encontrado',{'OK'})
	   	lRetorno := .f.
	Endif
ELSEIF "DIPAL10" $ FunName() .And. (nRadio == 5 .OR. nRadio == 6) 

	UA1->(DbSelectArea("UA1"))
	UA1->(DbSetOrder(1))
	If !(lRetorno:=UA1->(dbSeek(xFilial('UA1')+cNroPedido)))
   		Aviso('Aten��o','EDITAL n�o encontrado',{'OK'})
	   	lRetorno := .f.
	Endif

ELSE
	If !(lRetorno:=SUA->(dbSeek(xFilial('SUA')+cNroPedido)))
	   	Aviso('Aten��o','Numero de documento n�o encontrado',{'OK'})
   		lRetorno := .f.
    EndIf                     
Endif   

Return(lRetorno)
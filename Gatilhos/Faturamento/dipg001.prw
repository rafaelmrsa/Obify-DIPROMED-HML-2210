#include "rwmake.ch"
*------------------------------------------------*
User Function DIPG001()
*------------------------------------------------*  
Local mInfoCli := ''
Local cRet
Local lTranspA := .F.
Local lTranspJ := .F.
Local _xAlias 	   := GetArea()  
Local _xAliasSA3   := SA3->(GetArea())
Local _xAliasSU7   := SU7->(GetArea())  

If ISINCALLSTACK("LOJA901A") .Or. ISINCALLSTACK("LOJA901") .Or. FwIsInCallStack("U_DIPEXCRES")
	Return (M->C5_CLIENTE)
EndIf

U_DIPPROC(ProcName(0),U_DipUsr()) // JBS 05/10/2005 - Gravando o nome do Programa no SZU

// Chama fun��o para verificar clientes com dif�cil acesso - RBorges 04/12/2018

lTranspA := DifAce(SA1->A1_COD,"123455")
lTranspJ := DifAce(SA1->A1_COD,"000905")
If     (lTranspA .And. lTranspJ)
	MsgBox("CLIENTE COM DIF�CIL ACESSO ( ATIVA / JAMEF ), N�O ENVIAR FRETE CIF!","ATEN��O!")
ElseIf lTranspA
	MsgBox("CLIENTE COM DIF�CIL ACESSO ( ATIVA ), N�O ENVIAR FRETE CIF!","ATEN��O!")
ElseIf lTranspJ
	MsgBox("CLIENTE COM DIF�CIL ACESSO ( JAMEF ), N�O ENVIAR FRETE CIF!","ATEN��O!")
EndIf

If (Type("l410Auto") == "U" .OR. !l410Auto)
	/*
	|====================================================================|
	| Programa:  DIPG001  | Autor:   Rodrigo Franco   | Data:  29/11/01  |
	|--------------------------------------------------------------------|
	| Desc.     | Avisa operador quando ao risco do cliente.             |
	|====================================================================|
	|Eriberto  | 20 Abr 2007 - Informa��o do campo A1_DIFEREN para       |
	|          |               para informar ao operador como a nota     |
    |          |               ser� emitida:                             |
    |          |               ERIKA= DESC, QTD, PRC e UM                |
    |          |               TAIS = QTD, PRC e UM                      |
	|====================================================================|
	*/
	cRet := &(ReadVar())
	IF "TMK" $ FUNNAME() .Or. "DIPAL10" $ FUNNAME()
		_TIPO := '' //M->UA_TIPO
	Else
		_TIPO := M->C5_TIPO
	EndIf
	
	IF _TIPO <> "D" .AND. _TIPO <> "B"
		
		IF SA1->A1_STATUS == '2'                             
			mInfoCli := Trim(MSMM(SA1->A1_MSTATUS,,,,3)) 
			MsgBox(Alltrim(substr(mInfoCli,1,240)),"Cliente: "+SA1->A1_NOME,'INFO')// JBS 09/08/2005
			Return('')
		
		ElseIf Empty(SA1->A1_CONTRIB) // MCVN 28/10/16 - Bloquear Digita��o do Pedido quando campo A1_CONTRIB (Contribuinte) estiver vazio.
		
			mInfoCli := 'Cliente sem informa��o se � ou n�o CONTRIBUINTE !!!' + Chr(13)+Chr(13)+'N�o � poss�vel digitar pedidos.'
			MsgBox(mInfoCli,"Cliente: "+SA1->A1_NOME,'INFO')
			Return('')	
		
		ElseIf (SA1->A1_SITCNPJ) <> '1'
			
			mInfoCli := 'Cliente com situa��o do CNPJ Suspensa, Inapta, Baixada ou n�o informada!!!' + Chr(13)+Chr(13)+'N�o � poss�vel digitar pedidos. Fale com o FINANCEIRO!'
			MsgBox(mInfoCli,"Cliente: "+SA1->A1_NOME,'INFO')
			Return('')
		
		ElseIf Empty(SA1->A1_RISCO)
			
			mInfoCli := 'Nao existe Risco de Venda cadastrado para este cliente !!!' + Chr(13)+Chr(13)+'Este pedido sera bloqueado por falta de Credito.'
			
		ElseIF SA1->A1_RISCO != "A"
			
			IF SA1->A1_RISCO $ "E"  // MCVN 08/03/07  (RETIRAR ESSA ROTINA QUANDO CR�DITO ESTIVER CORRETO
				mInfoCli := 'Cliente sem Credito !!!' + Chr(13)+Chr(13)+'N�o � poss�vel digitar pedidos.'
				MsgBox(mInfoCli,"Cliente: "+SA1->A1_NOME,'INFO')// JBS 09/08/2005
				Return('')
			ElseIf SA1->A1_RISCO $ "C"
				mInfoCli := 'Cliente com Risco de Venda igual a ' + SA1->A1_RISCO + ' !!!' + Chr(13)+Chr(13)+'Este pedido sera bloqueado por falta de Credito.'
			Else 
				mInfoCli := 'Cliente com Risco de Venda igual a ' + SA1->A1_RISCO + ' !!!' + Chr(13)+Chr(13)+'Este pedido pode ser bloqueado por falta de Credito.'
			EndIf
		
		ElseIF (SA1->A1_SITCNPJ) = '1' //Valida��o para vendedoras internas - Felipe Duran 03/03/20
				
		EndIf
		
	EndIf
	
//AJUSTE BLOQUEIO TELEVENDAS - FELIPE DURAN 03/03/2020
	IF cEmpAnt ='01'
		DbSelectArea("SA3")
		DbSetOrder(1)
		If DbSeek(xFilial("SA3") + SA1->A1_VEND)
			DbSelectArea("SU7")
			DbSetOrder(1)
			If DbSeek(xFilial("SU7") + M->C5_OPERADO)
				If U7_POSTO = '02' 
					If Empty(SA3->A3_CODUSR)  .And.  (SA3->A3_COD <> '006964' .And. SA3->A3_COD <> '000353' .AND. SA3->A3_COD <> '006956' .And. SA3->A3_COD <> '006957')  
						MsgBox("Cliente n�o est� em sua Carteira. Favor falar com a Patr�cia!!!","Atencao","ALERT")
						Return('')
					EndIf
				EndIf			
			EndIf				
		EndIf
	EndIf
//FIM	
	
	If SA1->A1_DIFEREN == "E"	
		If !empty(mInfoCli)
		   	   mInfoCli += chr(13)+chr(10)+chr(13)+chr(10)
	    Endif
		mInfoCli += 'O cliente deste pedido est� marcado como "ERIKA", a nota ser� emitida pela 2a. descri��o, ser� alterado tamb�m: Quantidade, Pre�o Unit�rio e Unidade de medida.'	 
	ElseIf SA1->A1_DIFEREN == "T"
		If !empty(mInfoCli)
			mInfoCli += chr(13)+chr(10)+chr(13)+chr(10)
		Endif
	   mInfoCli += 'O cliente deste pedido est� marcado como "TAIS", na emiss�o da nota ser� alterado os campos: Quantidade, Pre�o Unit�rio e Unidade de medida.'
	EndIf                
	
	If !empty(SA1->A1_SUFRAMA) .And. (empty(SA1->A1_CALCSUF) .Or. SA1->A1_CALCSUF == "S") // MCVN 05/07/2007
		If !empty(mInfoCli)
			mInfoCli += chr(13)+chr(10)+chr(13)+chr(10)
		Endif
	   mInfoCli += 'Ser� calculado o desconto do ICMS referente ao SUFRAMA '+ SA1->A1_SUFRAMA+'.'
	ElseIf !empty(SA1->A1_SUFRAMA) .And. SA1->A1_CALCSUF == "N"
		If !empty(mInfoCli)
			mInfoCli += chr(13)+chr(10)+chr(13)+chr(10)
		Endif
	   mInfoCli += 'O cliente tem campo SUFRAMA preenchido '+SA1->A1_SUFRAMA+', mas n�o ser� calculado o desconto de ICMS .'
	EndIf
	
	/*====================================================================================\
	|Programa  | DIPG014    | Autor | Eriberto Elias               | Data |  08/06/2003   |
	|=====================================================================================|
	|Descri��o | Gatilho para mostrar informacoes do cliente nos atendimento              |
	|          | e nos pedidos                                                            |
	|=====================================================================================|
	|Objetivo  | Carregar na tabela SYP os campos memo.Gerar na tabela SA1 a chave para os|
	|          | Respectivos campos memo.                                                 |
	|=====================================================================================|
	|Sintaxe   | DIPG014()                                                                |
	|=====================================================================================|
	|Uso       | Especifico DIPROMED                                                      |
	|=====================================================================================|
	|Hist�rico | 10 Ago 2005 - Programado para carregar o campo memo A1_INFOICLM a partir |
	|          |               do conteudo na tabela SYP.                                 |
	|Eriberto  | 26 Abr 2006 - Informa��o para o estado da BA                             |
	|          |                                                                          |
	|          |                                                                          |
	|          |                                                                          |
	|          |                                                                          |
	\====================================================================================*/
	/* Retirado em 18/08/2010 Eriberto
	If SA1->A1_EST == "RJ"
		If !empty(mInfoCli)
			mInfoCli += chr(13)+chr(10)+chr(13)+chr(10)
		Endif
		// Retirado em 30/08/07 
		// mInfoCli += 'NAO cotar KIMBERLY - Informe: Oscar Eskin - (21) 2504-4595. ' + chr(13)+chr(10)
		//
		mInfoCli += 'N�o podemos vender REXAM para o Estado do Rio de Janeiro. ' + chr(13)+chr(10)
	EndIf
	*/
	
	
	/*If SA1->A1_EST $ 'MG/PE/AL/BA/PA'  //Mensagem desativada em 03-02-2021 
		mInfoCli += '***INFORMA��O IMORTANTE***' + chr(13)+chr(10) + chr(13)+chr(10)
		mInfoCli += 'SOMENTE VENDA A VISTA! '+ chr(13)+chr(10)
	EndIf*/ 
			
	If SA1->A1_EST == "BA"
		If !empty(mInfoCli)
			mInfoCli += chr(13)+chr(10)+chr(13)+chr(10)
		Endif
		mInfoCli += '***INFORMA��O SOMENTE PARA LICITA��O***' + chr(13)+chr(10) + chr(13)+chr(10)
		mInfoCli += 'Para clientes ORG�OS P�BLICOS do estado da '
		mInfoCli += 'Bahia, as mercadorias devem ser acompanhadas '
		mInfoCli += 'da nota eletronica. Coloque uma mensagem para '
		mInfoCli += 'o deposito enviar fax da nota para Sra. Magda.' + chr(13)+chr(10)
	EndIf
	
	If !Empty(SA1->A1_INFOCLM)
		If !empty(mInfoCli)
			mInfoCli += chr(13)+chr(10)+chr(13)+chr(10)
		Endif
		mInfoCli += MSMM(SA1->A1_INFOCLM,,,,3) // JBS 09/08/2005
	EndIf
	
	If Len(AllTrim(mInfoCli))<>0
		MsgBox(mInfoCli,"Cliente: "+SA1->A1_NOME,'INFO') // JBS 09/08/2005
	EndIf
Else

    cRet := SA1->A1_COD
EndIf



Return(cRet)         

/*
+=========================================================+
|Fonte: DifAce() | Autor: Reginaldo Borges | Data 04/12/18|
+---------------------------------------------------------+
|Descr.: Clientes com dif�cil Acesso.        		      |
+=========================================================+
*/

Static Function DifAce(cCodCli,cCodTransp)
Local _xAlias 	   := GetArea()  
Local _xAliasSA1   := SA1->(GetArea())  
Local lRet    	   := .F.
Local QRY2    	   := ""
Local cCNPJCli	   := ""

If !Empty(cCodCli)
	SA1->(dbSetOrder(1))
	If SA1->(dbSeek(xFilial("SA1")+cCodCli))
		cCNPJCli := cValToChar(Val(SA1->A1_CGC)) //Retirar zeros � esquerda
	Else
		Aviso("ATEN��O","ERRO - Cliente n�o encontrado para c�lculo de dif�cil acesso. Fale com o TI",{"Ok"})
	EndIf
EndIf
	
QRY2 := "SELECT ZZV_TRANSP"
QRY2 += " FROM " + RetSQLName("ZZV")
QRY2 += " WHERE ZZV_FILIAL  = '" + xFilial("ZZV") + "'"
QRY2 += "   AND ZZV_TRANSP  = '" +cCodTransp+ "'"
QRY2 += "   AND CAST(CAST(ZZV_CGCCLI AS BIGINT) AS VARCHAR(14)) = '"+cCNPJCli+"'"
QRY2 += "   AND " + RetSQLName("ZZV") + ".D_E_L_E_T_ = ' ' "

#xcommand TCQUERY <sql_expr>                          ;
[ALIAS <a>]                                           ;
[<new: NEW>]                                          ;
[SERVER <(server)>]                                   ;
[ENVIRONMENT <(environment)>]                         ;
=> dbUseArea(                                         ;
<.new.>,                                              ;
"TOPCONN",                                            ;
TCGENQRY(<(server)>,<(environment)>,<sql_expr>),      ;
<(a)>, .F., .T.)

TcQuery QRY2 NEW ALIAS "QRY2"         

If !QRY2->(Eof())
	lRet := .T.
EndIf       

QRY2->(DbCloseArea())
RestArea(_xAliasSA1)
RestArea(_xAlias)

SU7->(DbCloseArea())
SA3->(DbCloseArea())

Return(lRet)

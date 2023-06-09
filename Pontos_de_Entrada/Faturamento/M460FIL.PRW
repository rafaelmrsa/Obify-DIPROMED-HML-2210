#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
/*
PONTO.......: M460FIL           PROGRAMA....: MATA460
DESCRI��O...: ANTES DA MONTAGEM DA INDREGUA
UTILIZA��O..: Antes da execucao da Indregua de selecao da Markbrowse.
PARAMETROS..: Nenhum
RETORNO.....: ExpC1: Expressao xBase de Condi�ao.         Ex. "C9_TEXTO=='A'"
OBSERVA��ES.: Na vers�o Top Connect deve ser utilizado o ponto de entrada MT460QRY, com a mesma express�o deste.
*/
/*
�����������������������������������������������������������������������������
���Programa  � M460FIL  � Autor � Eriberto Elias        � Data � 24/11/03 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � PONTO DE ENTRADA PARA FILTRAR PEDIDOS PARCIAIS             ���
�������������������������������������������������������������������������Ĵ��
���Uso       � DIPROMED                                                   ���
�����������������������������������������������������������������������������
���Retirada analise de cr�dito customizada 								  ���
���Fernando R. Assun��o - 08/06/06										  ���
�����������������������������������������������������������������������������
*/
User Function M460FIL()
Local _cQry0 	:= ""
Local _aCli  	:= {}
Local _cPed  	:= ""
Local i
Local _lRet	 	:= .T. 
Local _aAreaSC5 := SC5->(GetArea())         
Local _nOpcao	:= 0
Local _aRet		:= {}
Local _oDlg		                                                    
Local _lFat		:= .F.         
Local _cMsgCli  := ""
Local _cMsgDep  := ""
Local _cMsg     := ""


U_DIPPROC(ProcName(0),U_DipUsr()) // MCVN - 22/01/2009
                                   
                         
If MV_PAR05 <> MV_PAR06
	Aviso("Aten��o","S� � permitida o faturamento de um pedido por vez."+CHR(13)+;
		            "Preencha os par�metros de pedido com o mesmo n�mero.",{"Ok"},1)
	Return("1=2")		            
Endif


SC5->(dbSetOrder(1))
If SC5->(dbSeek(xFilial("SC5")+AllTrim(MV_PAR05)))
	If !Empty(SC5->C5_XBLQNF)      
		Aviso("Aten��o","Foi solicitado estorno deste pedido. Entre em contato com a vendedora.",{"Ok"},1)
		Return("1=2")
	EndIf        
Else 
	Aviso("Aten��o","Pedido n�o encontrado na tabela SC5.",{"Ok"},1)	
	Return("1=2")
EndIf	

ZZ5->(dbSetOrder(1))
If ZZ5->(dbSeek(xFilial("ZZ5")+MV_PAR05))
	If Upper(FunName()) == "MATA460A"
		Aviso("Aten��o","Ordem de separa��o gerada utilizando o m�dulo ACD."+CHR(10)+CHR(13)+;
						"Utilize a rotina de faturamento do menu ACD (m�dulo estoque/custos)",{"Ok"},1)
		Return("1=2")
	Else
		While !ZZ5->(Eof()) .And. ZZ5->ZZ5_PEDIDO == MV_PAR05
			If ZZ5->ZZ5_STATUS == "4" .And. Empty(ZZ5->ZZ5_NOTA)
				
				_cMsgCli := AllTrim(ZZ5->ZZ5_OBSPRE)
				_cMsgDep := AllTrim(ZZ5->ZZ5_MENDEP)
				
				If !Empty(_cMsgCli) 
					_cMsg += "Obs. Cliente: "
					_cMsg += CHR(10)+CHR(13)
					_cMsg += _cMsgCli
					_cMsg += CHR(10)+CHR(13)
					_cMsg += CHR(10)+CHR(13)
				EndIF
				
				If !Empty(_cMsgDep)
					_cMsg += "Msg. Dep�sito: "
					_cMsg += CHR(10)+CHR(13)
					_cMsg += _cMsgDep
				EndIf
				
				If !Empty(_cMsg) .And. (Aviso("Aten��o",_cMsg,{"Cancela","Ok"},3)<>2)
					Return("1=2")
				EndIf
				
				If !Empty(_cMsg)
					Define msDialog oDlg Title "MENSAGEM" From 10,10 TO 15,080
						@ 010,020 get alltrim(_cMsg)   when .t. SIZE 250,15 Pixel	
					Activate dialog oDlg centered
				EndIf
					
				_lFat := .T.  
				
				Exit
			EndIf
			ZZ5->(dbSkip())
		EndDo
		If !_lFat
			Aviso("Aten��o","O pedido n�o est� pronto para ser faturado",{"Ok"},1)
			Return("1=2")
		EndIf
	EndIf
EndIf

_cQry0 :=" SELECT C5_NUM AS 'PEDIDO', C5_CLIENTE AS 'CLIENTE'   "
_cQry0 +=" FROM "+RETSQLNAME ("SC5") + " SC5 , "+RETSQLNAME ("SC9") + " SC9 "
_cQry0 +=" WHERE C5_FILIAL =  '"+XFILIAL("SC5")+"' "
_cQry0 +=" AND SC5.D_E_L_E_T_ = ' ' "
_cQry0 +=" AND C5_NUM     BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR06+"' "
_cQry0 +=" AND C5_CLIENTE BETWEEN '"+MV_PAR07+"' AND '"+MV_PAR08+"' "
_cQry0 +=" AND C5_LOJACLI BETWEEN '"+MV_PAR09+"' AND '"+MV_PAR10+"' "
_cQry0 +=" AND C9_DATALIB BETWEEN '" + Dtos(MV_PAR11) + "' AND '" + Dtos(MV_PAR12) + "'"
_cQry0 +=" AND C5_BLQ  <>  ' '   "
_cQry0 +=" AND C9_FILIAL =  '"+XFILIAL("SC9")+"' "
_cQry0 +=" AND SC9.D_E_L_E_T_=' ' "
_cQry0 +=" AND C5_NUM = C9_PEDIDO "
_cQry0 +=" AND C9_CLIENTE = C5_CLIENTE  "
_cQry0 +=" AND C9_LOJA = C5_LOJACLI     "
_cQry0 +=" GROUP BY C5_NUM, C5_CLIENTE    "


dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQry0),'TMP1',.T.,.F.)


If !EMPTY ("TMP1")
	DbSelectArea("TMP1")
	TMP1->(dbgotop())
	While TMP1->(!EOF())
		_cPed := "  numero: "+ TMP1->PEDIDO 
		
		TMP1->( dbSkip())
	END
EndIf        

TMP1->(DBCloseArea())

If !empty(_cPed)
	msgInfo("Aviso o pedido a vista "+_cPed+" se encontra em avalia��o financeira !!!!!")
	_lRet := .F.
EndIf         

SC5->(dbSetOrder(1))     

If _lRet .And. SC5->(dbSeek(xFilial("SC5")+MV_PAR05)) .And. !Empty(SC5->C5_XCHVPRE) .And. !("DIPA056"$FunName())

	_aRet := U_TelaPSW(SC5->C5_NUM) 
    
	While _aRet[1] .And. _aRet[2] <> SC5->C5_XCHVPRE                                      
		Aviso("Aten��o","Senha digitada n�o confere. Verifique a prenota.",{"Ok"},1)
		_aRet := U_TelaPSW(SC5->C5_NUM) 	
	EndDo
	 
	If !_aRet[1]
		RestArea(_aAreaSC5)
		Return(".F.")				                      		
	EndIf
EndIf             

RestArea(_aAreaSC5)    
Return("Empty(SC9->C9_BLEST) .And. Empty(SC9->C9_BLCRED) .And. Empty(SC9->C9_BLCRED2) .And. (SC9->C9_QTDLIB > 0 ) .And. Posicione('SC5',1,XFILIAL('SC5')+SC9->C9_PEDIDO,'C5_PARCIAL') <> 'N' .And. Empty(Posicione('SC5',1,XFILIAL('SC5')+SC9->C9_PEDIDO,'C5_BLQ')) .And. Empty(Posicione('SC5',1,XFILIAL('SC5')+SC9->C9_PEDIDO,'C5_XBLQNF')) .And. MV_PAR05 == MV_PAR06")
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �M460FIL   �Autor  �Microsiga           � Data �  07/16/12   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function TelaPSW(_cPedido)
Local _oDlg
Local _nOpcao := 0
Local _cSenha := Space(8)   
DEFAULT _cPedido := ""
        

@ 126,000 To 250,350 DIALOG _oDlg TITLE OemToAnsi("Pedido " + _cPedido)
@ 008,010 Say 'Digite as senhas (T+M) contidas na prenota do pedido: '+_cPedido
@ 020,010 Say "Senha: "
@ 020,040 Get _cSenha Size 43,20 Picture "99999999" 
@ 040,100 BUTTON OemToAnsi("Confirma")       SIZE 30,15 ACTION (_nOpcao := 1, Close(_oDlg))
@ 040,140 BUTTON OemToAnsi("Cancela")        SIZE 30,15 ACTION (_nOpcao := 0, Close(_oDlg))
ACTIVATE DIALOG _oDlg Centered	                                                          

Return({_nOpcao==1,_cSenha})
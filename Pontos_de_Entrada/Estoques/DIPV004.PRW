#INCLUDE "Protheus.ch"
/*====================================================================================\
|Programa  | DIPV004       | Autor | GIOVANI.ZAGO               | Data | 30/06/2011   |
|=====================================================================================|
|Descri��o | Valida��o de cliente para consumidor final fora de SP                    |
|          |                                                                          |
|          |                                                                          |
|=====================================================================================|
|Sintaxe   | DIPV004                                                                  |
|=====================================================================================|
|Uso       | Especifico DIPROMED                                                      |
|=====================================================================================|
|........................................Hist�rico....................................|
\====================================================================================*/
*---------------------------------------------------*
User Function DIPV004 (_cCodCli,_cLojaCli,_cProgRef,_lAltPed)
*---------------------------------------------------*
Local _aArea   	    := GetArea()
Local _aAreaSC5     := SC5->(GetArea())
Local _aAreaSA1		:= SA1->(GetArea())
Local _cTabela      := "1Z"                 //tabela da sx5 com a descri��o dos estado do protocolo 21
Local _cChave       := " "
Local _cMsgDecr     := " "
Local _cNomeDes     := " "
Local _cQry0        := " "
Local _cIsentCli    := GetMv("ES_DIPV4_1")  //parametro com os clientes isentos da nova tabela de pre�o
Local _cExcIseCli   := GetMv("ES_DIPV4_8")  //parametro com os clientes isentos da nova tabela de pre�o mas recolhem a guia
Local _cCadCliIsen  := Getmv("ES_DIPV4_9")  //parametro com os cliente isentos da tributa��o de 16%( ex. cliente dos estado de 'MS','MT',CE' isentos de tributa��o de icms
DEFAULT _lAltPed	:= .F.

SA1->( DbSetOrder(1))
If SA1->( DbSeek(xFilial('SA1')+_cCodCli+_cLojaCli)) 
	If Empty(SA1->A1_RISCO)
		Aviso("Aten��o","Cliente sem o campo Risco Preenchido."+Chr(10)+Chr(13)+"Entre em contato com o Financeiro!"+Chr(10)+Chr(13)+"Obrigado",{"Ok"},1)
		Return(.F.)
	EndIf                                                                   
	/*
	//C�digo retirado em 04/09/2013 - N�o trabalhamos mais com a transp BRASPRESS
	If !("DIPAL10" $ FunName()) .And. Left(SA1->A1_CEP,2)$'11/12'
		Aviso("Aten��o - Problema na Entrega","Cliente da regi�o do Litoral de SP ou Vale do Para�ba"+CHR(10)+CHR(13)+;
		"N�O UTILIZE a transportadora BRASPRESS para esta regi�o."+Chr(10)+Chr(13)+"Exceto se for exig�ncia do cliente.",{"Ok"},2,"Aviso importante!")
	EndIf
	*/
EndIf     


If !("DIPAL10" $ FunName()) .And. !(_cCodCli $ _cIsentCli ).And. !(_cCodCli $ _cExcIseCli )
	
	_cQry0 :=" SELECT * "
	_cQry0 +=" FROM "+RETSQLNAME ("SA1") + " SA1 "
	_cQry0 +=" WHERE A1_COD      =  '"+_cCodCli+"' "
	_cQry0 +=" AND A1_LOJA       =  '"+_cLojaCli+"' "
	_cQry0 +=" AND A1_FILIAL     =  ' ' "
	_cQry0 +=" AND (A1_TIPO      =  'F'  OR  A1_CONTRIB = '2') "
	_cQry0 +=" AND D_E_L_E_T_    <> '*' "
	
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQry0),'TMP1',.T.,.F.)
	
	TMP1->(dbgotop())
	If !EMPTY ("TMP1")
		DbSelectArea("TMP1")
		DbGoTop()
		While TMP1->(!EOF())
			
			_cChave    := ALLTRIM(TMP1->A1_EST)
			_cNomeDes  := ALLTRIM(TMP1->A1_NOME)
			_cMsgDecr  := ALLTRIM(GetAdvFVal("SX5","X5_DESCRI",XFILIAL("SX5")+_cTabela+_cChave,1))
			_cNomeDes  := ALLTRIM(GetAdvFVal("SX5","X5_DESCSPA",XFILIAL("SX5")+_cTabela+_cChave,1))
			
			If !Empty (_cMsgDecr)  .And.  _cCodCli $ _cCadCliIsen .and. _cProgRef = "1"
				DipGrvXRec("ISE",_lAltPed)  // 'ISE' apresenta o pre�o unitario com acrescimo de 06%.
			EndIf
			If  !Empty (_cMsgDecr)  .And.  !(_cCodCli $ _cCadCliIsen) .and. _cProgRef = "1" .And. !Empty(_cNomeDes)
				DipGrvXRec("ISE",_lAltPed)  // 'ISE' apresenta o pre�o unitario com acrescimo de 06%.
			ElseIf  !Empty (_cMsgDecr)  .And.  !(_cCodCli $ _cCadCliIsen) .and. _cProgRef = "1" .And.  Empty(_cNomeDes)
				DipGrvXRec("ACR",_lAltPed)  // 'ACR' apresenta o pre�o unitario com acrescimo de 16%.
			EndIf
			
			TMP1->( dbSkip())
		END
	EndIf
	
	TMP1->(DBCloseArea())
	
ElseIf !("DIPAL10" $ FunName()) .And. _cCodCli $ _cExcIseCli
	_cQry0 :=" SELECT * "
	_cQry0 +=" FROM "+RETSQLNAME ("SA1") + " SA1 "
	_cQry0 +=" WHERE A1_COD      =  '"+_cCodCli+"' "
	_cQry0 +=" AND A1_LOJA       =  '"+_cLojaCli+"' "
	_cQry0 +=" AND A1_FILIAL     =  ' ' "
	_cQry0 +=" AND (A1_TIPO      =  'F'  OR  A1_CONTRIB = '2') "
	_cQry0 +=" AND D_E_L_E_T_    <> '*' "
	
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQry0),'TMP1',.T.,.F.)
	
	TMP1->(dbgotop())
	If !EMPTY ("TMP1")
		DbSelectArea("TMP1")
		DbGoTop()
		While TMP1->(!EOF())
			
			_cChave    := ALLTRIM(TMP1->A1_EST)
			_cNomeDes  := ALLTRIM(TMP1->A1_NOME)
			_cMsgDecr  := ALLTRIM(GetAdvFVal("SX5","X5_DESCRI",XFILIAL("SX5")+_cTabela+_cChave,1))
			_cNomeDes  := ALLTRIM(GetAdvFVal("SX5","X5_DESCSPA",XFILIAL("SX5")+_cTabela+_cChave,1))
			
			
			If !(_cMsgDecr $ "Protocolo")
				DipGrvXRec("GUI",_lAltPed)  // 'GUI' Nao calcula acrescimo porem envia e-mail na libera��o avisando que cliente tem de mandar a guia.
			Endif
			
			TMP1->( dbSkip())
		END
	EndIf
	
	TMP1->(DBCloseArea())
EndIf 

RestArea(_aArea)
RestArea(_aAreaSC5)                      
RestArea(_aAreaSA1)

Return(.T.)
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �DIPV004   �Autor  �Microsiga           � Data �  07/18/13   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function DipGrvXRec(cContGrv,lDiplock)
Local aArea := GetArea()
DEFAULT cContGrv := ""
DEFAULT lDipLock := .F.

If lDipLock
	SC5->(RecLock("SC5",.F.))
		SC5->C5_XRECOLH := cContGrv
	SC5->(MsUnlock())
Else 
	M->C5_XRECOLH := cContGrv	                
EndIf          
         
RestArea(aArea)

Return
#INCLUDE "PROTHEUS.CH"
#include "rwmake.ch" 


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³ DIPA017  º Autor ³ Eriberto Elias     º Data ³  04/06/02   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Atualiza SF2->F2_SEPERAU e SF2->F2_CONFERI                 º±±
±±-------------------------------------------------------------------------±±
±±ºMaximo    ³ Incluindo opção de alterar transportadora       30/05/09   º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function DIPA017()

Local lAltTransp 	:= .F.
Local _nOpcao     	:= 0 
Local _cTranAnt    	:= ""  //Giovani Zago 26/03/2012
Local _cTipFreAnt  	:= ""  //Giovani Zago 26/03/2012
Local _lWhen		:= .T.

U_DIPPROC(ProcName(0),U_DipUsr()) // JBS 05/10/2005 - Gravando o nome do Programa no SZU

_xAlias  := GetArea()
                      
If !("DIPA012" $ FUNNAME())  // MCVN - 29/10/2008
	Return
Endif  
        
dbselectarea("SF2")

If !Empty(cMarca)

 /*	Dbselectarea("SF2")
	DbSetOrder(8)
	DbSeek(xFilial("SF2")+cMarca)*/
	
	SF2->(DbOrderNickName("F2OK2"))	// Utilizando DbOrderNickName ao invés de DbSetOrder  devido a virada de versão MCVN - 26/10/2007
	SF2->(DbSeek(xFilial("SF2")+cMarca))

	_cNotaSerie := SF2->F2_DOC+SF2->F2_SERIE
	_cSeparo    := If(Empty(Alltrim(SF2->F2_SEPAROU)),Space(2),Alltrim(SF2->F2_SEPAROU))
	_cConfir    := If(Empty(Alltrim(SF2->F2_CONFERI)),Space(2),Alltrim(SF2->F2_CONFERI))
	_nVolume    := SF2->F2_VOLUME1
	_cTransp    := SF2->F2_TRANSP    
	_cTpFrete   := SF2->F2_TPFRETE
	_cLocExp    := '000'
	_cPedid		:= Posicione("SD2",3,xFilial("SD2") + _cNotaSerie,"D2_PEDIDO")
	
	ZZ5->(dbSetOrder(1))
	If ZZ5->(dbSeek(xFilial("ZZ5")+Posicione("SD2",3,xFilial("SD2") + _cNotaSerie,"D2_PEDIDO")))
		_lWhen := .F.
	EndIf

  /*	@ 126,000 To 295,180 DIALOG oDlg TITLE OemToAnsi("      NF - " + SF2->F2_DOC)
	@ 008,030 Say '" Quem "'
	@ 020,010 Say "Separou: "
	@ 020,035 Get _cSeparo Size 33,20 F3 "SZC" Valid ExistCpo("SZC")
	@ 035,010 Say "Conferiu: "
	@ 035,035 Get _cConfir Size 33,20 F3 "SZC" Valid ExistCpo("SZC")
	@ 065,030 BMPBUTTON TYPE 1 ACTION Close(odlg)
	ACTIVATE DIALOG oDlg Centered
	Dbselectarea("SF2") */
	
	@ 126,000 To 450,350 DIALOG oDlg TITLE OemToAnsi("      NF - " + SF2->F2_DOC)
	@ 008,010 Say 'Quem?'      
	@ 020,010 Say "Separou: "
	@ 020,040 Get _cSeparo Size 33,20 F3 "SZC" Valid ExistCPO("SZC") When _lWhen
	@ 035,010 Say "Conferiu: "                                                        
	@ 035,040 Get _cConfir Size 33,20 F3 "SZC" Valid ExistCPO("SZC") When _lWhen
	@ 050,010 say 'Expedição:'
	@ 050,040 get _cLocExp Size 15,20 Picture "999" When _lWhen
	@ 065,010 say 'Volumes:'                                      
	@ 065,040 get _nVolume Size 33,20 Picture "@E 999,999" When _lWhen 
	@ 090,010 Say "Transportadora: "                                                        
	@ 090,060 Get _cTransp Size 33,20 F3 "SA4" Valid ExistCPO("SA4")  When lAltTransp
	@ 105,010 say 'Tipo de Frete:'
	@ 105,060 get _cTpFrete Size 15,20         VALID _cTpFrete $ "CFINM" When lAltTransp	
	@ 130,010 BUTTON OemToAnsi("Alterar Transp") SIZE 44,15 ACTION (lAltTransp := u_DipVldPro(_cPedid,_cTpFrete,_cTransp) )
	@ 130,100 BUTTON OemToAnsi("Confirma")       SIZE 30,15 ACTION (_nOpcao := 1, Close(odlg))
	@ 130,140 BUTTON OemToAnsi("Cancela")        SIZE 30,15 ACTION (_nOpcao := 0, Close(odlg))
	ACTIVATE DIALOG oDlg Centered
   
	
	If _nOpcao = 1  // MCVN - 30/05/09

		While SF2->(!Eof()) .AND. xFILIAL("SF2") == SF2->F2_FILIAL
		// .AND. cMarca == SF2->F2_OK2
			_cNotaSerie := SF2->F2_DOC+SF2->F2_SERIE
			SF2->(RecLock("SF2",.F.))
				Replace SF2->F2_SEPAROU WITH _cSeparo
				Replace SF2->F2_CONFERI WITH _cConfir 
				Replace SF2->F2_VOLUME1 WITH _nVolume 
				Replace SF2->F2_LOCEXP  WITH _cLocExp 
				Replace SF2->F2_OK2     WITH ''
				If lAltTransp// MCVN - 30/05/09
					Replace SF2->F2_TPFRETE WITH _cTpFrete
					Replace SF2->F2_TRANSP  WITH _cTransp 
				EndIf
			SF2->(MsUnlock())
			SF2->(dbSeek(xFilial("SF2")+cMarca))
			//Dbselectarea("SF2")
			//DbSkip()   
		                                 
			If lAltTransp // MCVN - 30/05/09    
			
		   		// Atualiza SUA - MCVN - 30/05/09
				SUA->(dbSetOrder(8))
				If SUA->(dbSeek(xFilial("SUA")+Posicione("SD2",3,xFilial("SD2") + _cNotaSerie,"D2_PEDIDO")))
					SUA->(RecLock("SUA",.F.))
						Replace SUA->UA_TRANSP  With _cTransp
						Replace SUA->UA_TPFRETE With _cTpFrete
					SUA->(MsUnLock())
				EndIf
                           
				//Atualiza SUB - MCVN - 30/05/09
				SC5->(dbSetOrder(1))
				If SC5->(dbSeek(xFilial("SC5")+Posicione("SD2",3,xFilial("SD2") + _cNotaSerie,"D2_PEDIDO")))
				 	_cTranAnt    := SC5->C5_TRANSP  //Giovani Zago 26/03/2012
                 	_cTipFreAnt  := SC5->C5_TPFRETE  //Giovani Zago 26/03/2012
					SC5->(RecLock("SC5",.F.))
						Replace SC5->C5_TRANSP  With _cTransp
						Replace SC5->C5_TPFRETE With _cTpFrete
					SC5->(MsUnLock())
				EndIf
			EndIf
			   
			//Giovani Zago 26/03/2012 registra alteração na transportadora
			U_DiprKardex(Posicione("SD2",3,xFilial("SD2") + _cNotaSerie,"D2_PEDIDO"),U_DipUsr(),;
			Alltrim(_cSeparo)+"-"+Alltrim(_cConfir)+"-"+Alltrim(_cLocExp)+"-"+Alltrim(Str(_nVolume))+"-"+Alltrim(_cTranAnt)+"-"+Alltrim(_cTipFreAnt)+"-DIPA017 - A",.T.,"42")
	
			
			// Registrando alteração de separador, conferente, volume e expedição no kardex. MCVN - 10/11/08              
			U_DiprKardex(Posicione("SD2",3,xFilial("SD2") + _cNotaSerie,"D2_PEDIDO"),U_DipUsr(),;
			Alltrim(_cSeparo)+"-"+Alltrim(_cConfir)+"-"+Alltrim(_cLocExp)+"-"+Alltrim(Str(_nVolume))+"-"+Alltrim(_cTransp)+"-"+Alltrim(_cTpFrete)+"-DIPA017 - D",.T.,"42")
		EndDo 		
		
    EndIf
Else
	MsgInfo("VOCE NAO MARCOU NENHUMA NOTA")
EndIf  

RestArea(_xAlias)

Return
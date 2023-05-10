#INCLUDE "PROTHEUS.CH"



/******************************************************
Programa: telatmka()  
Descrição: Essa tela será usada no TMK para registrar 
ou atualizar as observações no campo UC_OBS do 
do atendimento do telemarketing.
Autor: Reginaldo Borges
Data 13/08/2012
/******************************************************/


USER FUNCTION telatmka()

Private oMEMO
Private cMEMO   := SPACE (80)    
Private oMEMO1
Private cMEMO1  :=""
Private oBUTTON
Private oDLG  
Private oFont30 := TFont():New("Arial",9,28,.T.,.T.,5,.T.,5,.T.,.F.)


If M->UC_OBS =""
	cMemo1 := "Não há histórico para esse SAC!"
Else                       
	cMemo1 := M->UC_OBS
EndIf

DEFINE MSDIALOG oDlg FROM 000,000 TO 600,420 TITLE "Observação da Ocorrência" PIXEL
                           
If ! (INCLUI .Or. ALTERA)

	@ 030,050 SAY "Visualizando Histórico" font oFont30  COLOR CLR_BLUE Pixel
	
	@ 050,010 SAY "Historico:" SIZE 030,010 PIXEL OF ODLG
	@ 060,010 GET oMemo1 VAR cMemo1 Memo SIZE 190,210 PIXEL OF ODLG   
	
	@ 288,160 BUTTON oBOTAOFECHAR PROMPT "&Fechar" SIZE 030,010 PIXEL OF oDLG ACTION oDLG:END() 	                                                         

Else

	@ 010,010 SAY "Observação:" SIZE 030,020 PIXEL OF ODLG
	oMEMO:= tMULTIGET():NEW(020,010,{|u|IF(Pcount()>0,cMEMO:=u,cMEMO)};
	,oDLG,190,080,,,,,,.T.)  
	
	@ 105,010 SAY "Historico:" SIZE 030,010 PIXEL OF ODLG
	@ 115,010 GET oMemo1 VAR cMemo1 Memo SIZE 190,170 PIXEL OF ODLG   

	@ 288,100 BUTTON oBOTAOOK PROMPT "&Ok" SIZE 30,10 PIXEL OF oDLG ACTION(GRAVA(), oDlg:End()) 
	@ 288,160 BUTTON oBOTAOFECHAR PROMPT "&Fechar" SIZE 030,010 PIXEL OF oDLG ACTION oDLG:END() 

EndIf


ACTIVATE MSDIALOG oDLG CENTERED


RETURN  


/******************************************************************************
+ Static Function GRAVA(), será chamada no Button "Ok", gravará as alterações +
+ do cMEMO no campo UC_Obs do Atendimento callcenter no modulo CallCenter.    +
+ Além da alteração feita no cMemo, gravará, também, o usuario, data e a hora.+
******************************************************************************/

STATIC FUNCTION GRAVA() 
Local cHora := Time() 
Local _cNusePth := ""
Local _nX
Local aAllusers := FWSFALLUSERS()   

For nX := 1 To Len(aAllusers)
	If aAllusers[nX][2] == __cUserId
		_cNusePth := Upper(aAllusers[nX][4])
	EndIf
Next 
                              
	M->UC_OBS := AllTrim(_cNusePth)+" - "+AllTrim(DTOC(dDataBase))+" - "+AllTrim(cHora)+": "+;
	             CHR(10)+CHR(13)+AllTrim(cMEMO)+CHR(10)+CHR(13)+CHR(10)+CHR(13)+AllTrim(M->UC_OBS)
	
RETURN

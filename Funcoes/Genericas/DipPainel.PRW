#include "PROTHEUS.CH"
#include "TOTVS.CH"    
#INCLUDE "TBICONN.CH"
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �DIPENVWF  �Autor  �Microsiga           � Data �  08/06/14   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function DipPainel()       
Local aTela := {}
Local lDipMob := .F.
Local oFont30n := TFont():New("Arial",,-30,.T.,.T.)
Local oFont15n := TFont():New("Arial",,-15,.T.,.T.)
Local oFont20i := TFont():New("Arial",,-10,.T.,.T.,,,,,,.T.)
Private aTopFat :={}
Private cTime1
Private cTime2
Private cTime
Private nProc := 0
Private nVezes := 3

PREPARE ENVIRONMENT EMPRESA "01" FILIAL "01" FUNNAME "Indicadores"

aTela := GETSCREENRES()
cNomeSO := Upper(GetRmtInfo()[2])

DEFINE MSDIALOG oDlgAux TITLE "Indicadores" FROM 0,0 TO IIf(lDipMob,2560,aTela[2]),IIf(lDipMob,1440,aTela[1]) COLORS 0,0 PIXEL //120 -20 

If "ANDROID"$cNomeSO .Or. "IOS"$cNomeSO
	lDipMob := .F. //desativado
EndIf
                         
If lDipMob
	@ 005,005 say "Aguarde! Atualizando dados..." font oFont15n COLOR CLR_WHITE Pixel   
	@ 015,055 say "vers�o beta - MOBILE" font oFont20i COLOR CLR_WHITE Pixel   	
Else
	@ 150,220 say "Aguarde! Atualizando dados..." font oFont30n COLOR CLR_WHITE Pixel   
EndIf
    
//MsgInfo("Teste de resolu��o -> "+cValToChar(aTela[1])+"x"+cValToChar(aTela[2]))                 
    
ACTIVATE MSDIALOG oDlgAux CENTERED ON INIT ChamaTela(lDipMob)

RESET ENVIRONMENT     

Return     
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � �Autor  �Microsiga           � Data �  03/10/16   ���
�������������������������������������������������������������������������͹��
���Desc.     � Enquanto n�o for derrubado no browser, o sistema continua  ���
���          � chamando a tela                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function ChamaTela(lDipMob)
DEFAULT lDipMob := .F.

While .T.
	Processa({|| u_DipIndic(lDipMob)},"Atualizando dados")
EndDo

Return 

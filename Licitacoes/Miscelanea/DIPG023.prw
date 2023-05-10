#INCLUDE "Protheus.ch" 
#INCLUDE "COLORS.CH"
#INCLUDE "RWMAKE.CH" 
#DEFINE CR    chr(13)+chr(10)
/*====================================================================================\
|Programa  | DIPG023       | Autor | GIOVANI.ZAGO               | Data | 21/07/2011   |
|=====================================================================================|
|Descrição |Gatilho para licitação justificativa para encerramento de contrato antes  |
|          |do prazo de validade                                                      |
|          |                                                                          |
|=====================================================================================|
|Sintaxe   | DIPG023                                                               |
|=====================================================================================|
|Uso       | Especifico DIPROMED                                                      |
|=====================================================================================|
|........................................Histórico....................................|
\====================================================================================*/

User Function DIPG023 ()

Local _aArea   	     := GetArea()
Local aAreaUA1       := UA1->(GetArea())
Local lSaida         := .f.
Local cGetMotivo     := Space(90)
Private cMotiEnc     := " "
Private nChave       := 0
Private nOpcao       := 0
Private cMsgDecr     := "Você selecionou ENCERRAR este contrato."+CR+CR+"Confirma o ENCERRAMENTO ?" 
Private cNomeDes     := Upper(U_DipUsr())
Private _Retorno     := ".F."
Private _cQry0       := " "  
 

If ("DIPAL10" $ FunName())

nChave:= Aviso("Encerrar Contrato",cMsgDecr ,{"Sim","Não"}) 
 If nChave == 1
 Do While !lSaida
	   
 	nOpcao := 0
	
	Define msDialog oDlg Title "Encerrar Contrato " From 10,10 TO 23,60
	
	@ 001,002 tO 78,196
	
	@ 010,010 say "Contrato" COLOR CLR_BLACK
	@ 020,010 say "Cliente " COLOR CLR_BLACK
	@ 030,010 say "Operador" COLOR CLR_BLACK
	
	@ 010,050 get M->UA1_CODIGO  when .f. size 050,08
	@ 020,050 get M->UA1_CODCLI when .f. size 120,08 
   	@ 030,050 GET cNomeDes when .f. size 120,08
	
	@ 050,010 say "Descreva o motivo do encerramento: " COLOR CLR_HBLUE
	@ 060,010 get cGetMotivo valid !empty(cGetMotivo) size 165,08
	
	DEFINE SBUTTON FROM 82,130 TYPE 1 ACTION IF(!empty(cGetMotivo),(lSaida:=.T.,nOpcao:=1,oDlg:End()),msgInfo("Motivo do encerramento não preenchido","Atenção")) ENABLE OF oDlg
//	DEFINE SBUTTON FROM 82,160 TYPE 2 ACTION (nOpcao:=0,oDlg:End()) ENABLE OF oDlg
	
	Activate dialog oDlg centered

 Enddo
	If nOpcao == 1
 
 
    cMotiEnc := "   -- Encerrado -- "+ALLTRIM(cGetMotivo)+" -- OPERADOR: "+Upper(U_DipUsr())+" -- "+DTOC(ddatabase)
    M->UA1_STATUS := "8" 
    M->UA1_OBS := ALLTRIM(M->UA1_OBS)+ALLTRIM(M->UA1_XMOTEN)+ALLTRIM(cMotiEnc)
    Else
    cMotiEnc:= " " 
    M->UA1_XENCER := " "
    EndIf
Else
M->UA1_XENCER := "2"
 cMotiEnc:= " "
 EndIf

EndIf



	RestArea(_aArea)
	RestArea(aAreaUA1)
Return(cMotiEnc)  



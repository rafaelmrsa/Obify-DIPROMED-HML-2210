/*
PONTO.......: TMKLINOK          PROGRAMA....: 6.09
DESCRIÇÄO...: TMKA271E.PRW
UTILIZAÇÄO..: Ponto de entrada executado depois da funçao de validaçao
              da linha da Getdados de telemarketing.
              O seu objetivo é validar o item da linha atual selecionada
              no telemarketing.
              
PARAMETROS..: Nenhum do tipo X : Nenhum

RETORNO.....: Lógico do tipo L : .T. ou .F.

OBSERVAÇÖES.: <NENHUM>
*/
/*====================================================================================\
|Programa  | TMKLINOK      | Autor | Eriberto Elias             | Data | 16/09/2004   |
|=====================================================================================|
|Descrição | Vamos validar a ocorrencia para pedir VOLUMES                            |
|=====================================================================================|
|Sintaxe   | TMKLINOK                                                                 |
|=====================================================================================|
|Uso       | Especifico DIPROMED                                                      |
|=====================================================================================|
|Histórico | DD/MM/AA - Descrição da alteração                                        |
\====================================================================================*/
#include "rwmake.ch"
#include "tcbrowse.ch"

USER FUNCTION TMKLINOK()

Private _lRet := .T.
Private nVol_Env := 0
Private nVol_Rec := 0

U_DIPPROC(ProcName(0),U_DipUsr()) // JBS 05/10/2005 - Gravando o nome do Programa no SZU

If !aCols[n,Len(aHeader)+1]

	If 'CONSTA NA NF E NAO RECEBEU' $ UppeR(aCols[n,aScan(aHeader, { |x| Alltrim(x[2]) == "UD_DESCOCO"})])
		//msgstop(aCols[n,aScan(aHeader, { |x| Alltrim(x[2]) == "UD_DESCOCO"})],"entrei")
		_lRet := .F.
		// DIÁLOGO PARA INFORMAR QTDE DE VOLUMES ENVIADOS E RECEBIDOS
		@ 126,000 To 320,300 DIALOG oDlg TITLE OemToAnsi("Volumes Enviados e Recebidos")
		@ 010,015 Say "Quantos volumes na NF ?"
		@ 025,015 Get nVol_Env Size 20,20 Picture "9999" // PERMITE CAMPO VÁZIO
		@ 040,015 Say "Quantos volumes chegaram ?"
		@ 055,015 Get nVol_Rec Size 20,20 Picture "9999" Valid IIf(nVol_Rec == 0,.F.,.T.)
		@ 070,050 BmpButton Type 1 Action (U_Ok(nVol_Env,nVol_Rec),Close(oDlg))
		@ 070,100 BmpButton Type 2 Action Close(oDlg)
		Activate Dialog oDlg Centered

	EndIf
EndIf

Return(_lRet)


/*====================================================================================\
|Programa  | OK            | Autor | Rafael de Campos Falco     | Data | 16/09/2004   |
|=====================================================================================|
|Descrição | Vamos validar a ocorrencia para pedir VOLUMES                            |
|=====================================================================================|
|Sintaxe   | OK                                                                       |
|=====================================================================================|
|Uso       | Especifico DIPROMED                                                      |
|=====================================================================================|
|Histórico | DD/MM/AA - Descrição da alteração                                        |
\====================================================================================*/

User Function Ok(nVol_Env,nVol_Rec)

Local cSud_Obs := ""
If nVol_Rec > 0
	// VERIFICA SE EXISTE OBS FEITA ANTERIOMENTE
	If "Vol.NF.:" $ aCols[n,aScan(aHeader, { |x| Alltrim(x[2]) == "UD_OBS"})]
		// RECUPERA APENAS A PARTE SEM A OBS ANTERIOR
		cSud_Obs := SubStr(aCols[n,aScan(aHeader, { |x| Alltrim(x[2]) == "UD_OBS"})] ,At("#",aCols[n,aScan(aHeader, { |x| Alltrim(x[2]) == "UD_OBS"})])+1	,Len(aCols[n,aScan(aHeader, { |x| Alltrim(x[2]) == "UD_OBS"})]))
	Else
		// RECUPERA A OBS NORMAL
		cSud_Obs := AllTrim(aCols[n,aScan(aHeader, { |x| Alltrim(x[2]) == "UD_OBS"})])
	EndIf	
	
	// INCLUI A NOVA OBS SOBRE OS VOLUMES
	aCols[n,aScan(aHeader, { |x| Alltrim(x[2]) == "UD_OBS"})] := "Vol.NF.: " + AllTrim(iif(nVol_Env==0,"--",Str(nVol_Env))) + " / " + "Vol.Rec.: " + AllTrim(Str(nVol_Rec)) +" # "+ cSud_Obs 
	
	_lRet := .T.

	// Eriberto 13/02/2006 Close(oDlg)
Else
	_lRet := .F.
EndIf

Return
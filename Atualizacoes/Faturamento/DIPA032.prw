/*                                                              Sao Paulo,  27 Set 2006
---------------------------------------------------------------------------------------
Empresa.......: DIPOMED Com�rcio e Importa��o Ltda.
Programa......: DIPA032.PRW
Objetivo......: Manuten��o do canhoto, atualiza Data e Responsavel.

Autor.........: Jailton B Santos, JBS
Data..........: 27 Set 2006

Vers�o........: 1.0
Considera�oes.: Fun��o chamada direto do menu ->U_DipA032()
                
Parametros....: MV_CAN_CON -> Responsavel da contabilidade pela guarda do canhoto
                MV_CAN_ENV -> Reponsavel no CLD
                MV_CAN_LIC -> Responsavel em Licita��o
------------------------------------------------------------------------------------
*/
#include "rwmake.ch"
*-------------------------------------------------*
User Function DIPA032()
*-------------------------------------------------*
PRIVATE aRotina:= {;
{"Pesquisa"     ,"AxPesqui"       ,0,1},;       //"Pesquisa" 
{"Dt Canhoto"   ,"U_DIPA032DTCAN" ,0,2},; 
{"Resp Canhoto" ,"U_DIPA032RESPO" ,0,3}}  

U_DIPPROC(ProcName(0),U_DipUsr()) // MCVN - 22/01/2009

cCadastro := "Data do Canhoto, Respons�vel pelo Canhoto"
cMarca := GetMark()
MarkBrow("SF2","F2_OK2",,,,cMarca)

Return
*-------------------------------------------------*
User Function DIPA032DTCAN()                            
*-------------------------------------------------*
Local cSaveArea:=GetArea()
Local _cData:= date() //CTOD("  /  /  ")

/*SF2->(DbSetOrder(8))
SF2->(DbSeek(xFilial("SF2")+cMarca))*/
SF2->(DbOrderNickName("F2OK2"))	// Utilizando DbOrderNickName ao inv�s de DbSetOrder  devido a virada de vers�o MCVN - 26/10/2007
SF2->(DbSeek(xFilial("SF2")+cMarca))

If SF2->(!EOF()) //!Empty(cMarca)

    If !Upper(U_DipUsr()) $ Upper(AllTrim(GETNEWPAR('MV_CAN_CON','Eriberto')))+' ERIBERTO'
        MsgInfo('Usuario n�o possui autoriza��o para alterar ou preencher data do Canhoto','Autoriza��o')
        return
    EndIf
	
	@ 126,000 To 260,180 DIALOG oDlg TITLE OemToAnsi("Data do Canhoto da Nota Fiscal")
	@ 010,010 Say "Data"
	@ 010,035 Get _cData  size 40,20
	@ 045,030 BMPBUTTON TYPE 1 ACTION Close(odlg)
	
	ACTIVATE DIALOG oDlg Centered
	
	
	Do While SF2->(!Eof()) .AND. xFILIAL("SF2") == SF2->F2_FILIAL
		
		SF2->(RecLock("SF2",.F.))
		SF2->F2_DTCANCOD := _cData
		SF2->F2_OK2 := ''
		SF2->(MsUnlock())
		SF2->(DbSeek(xFilial("SF2")+cMarca))
		
	EndDo 
Else
	MsgInfo("Voc� n�o marcou nenhuma nota!")
EndIf

RestArea(cSaveArea)

Return
*-------------------------------------------------*
User Function DIPA032RESPO()
*-------------------------------------------------*
Local cSaveArea :=GetArea()
Local cRespCan := Space(len(SF2->F2_RESPCAN))
Local cAutorizados := Upper(AllTrim(GETNEWPAR('MV_CAN_ENV','')))+Upper(AllTrim(GETNEWPAR('MV_CAN_LIC',''))) + ' ERIBERTO'

//SF2->(DbSetOrder(8))
SF2->(DbOrderNickName("F2OK2"))	// Utilizando DbOrderNickName ao inv�s de DbSetOrder  devido a virada de vers�o MCVN - 26/10/2007
SF2->(DbSeek(xFilial("SF2")+cMarca))

If SF2->(!EOF()) //!Empty(cMarca)

    If !Upper(U_DipUsr()) $ cAutorizados
        MsgInfo("Usuario n�o possui autoriza��o para alterar ou preencher o nome do responsavel pelo Canhoto","Autoriza��o")
        return
    EndIf
	
	cRespCan := Space(len(SF2->F2_RESPCAN))
	
	@ 000,000 To 130,300 DIALOG oDlg TITLE OemToAnsi("Data do Canhoto da Nota Fiscal")
	@ 010,010 Say "Responasavel"
	@ 010,050 Get cRespCan size 90,20
	@ 045,030 BMPBUTTON TYPE 1 ACTION Close(odlg)
	
	ACTIVATE DIALOG oDlg Centered
	
	Do While SF2->(!Eof()) .AND. xFILIAL("SF2") == SF2->F2_FILIAL
		
		SF2->(RecLock("SF2",.F.))
		SF2->F2_RESPCAN := cRespCan
		SF2->F2_OK2 := ''
		SF2->(MsUnlock())
		SF2->(DbSeek(xFilial("SF2")+cMarca))
		
	EndDo 
Else
	MSGINFO("Voc� n�o marcou nenhuma nota!")
EndIf
RestArea(cSaveArea)
Return
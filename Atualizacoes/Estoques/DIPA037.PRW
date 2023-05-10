/*====================================================================================\
|Programa  | DIPA037       | Autor | Maximo Canuto Vieira Neto  | Data | 09/04/08     |
|=====================================================================================|
|Descrição | Atualiza SF1 com data de recolhimento do ICMS-ST fora de SP.             |
|=====================================================================================|
|Uso       | Especifico DIPROMED                                                      |
\====================================================================================*/

#INCLUDE "RWMAKE.CH"
#Include "Ap5Mail.ch"
#DEFINE CR    chr(13)+chr(10) // Carreage Return (Fim de Linha)

User Function DIPA037()
 

Local cUserAut   := "MCANUTO/MTEIXEIRA/EELIAS/DSANTOS/WPEREIRA/SCREATTO/DDOMINGOS/VQUEIROZ/VEGON/RBORGES"
Private dDtRecST := ctod("  /  /  ")
Private dEmissao := ctod("  /  /  ")
private cNfiscal := SPACE(09)       
private cSerie   := SPACE(03) 
private cFornec  := SPACE(06) 
Private cLoja    := Space(02)


If !AllTrim(Upper(U_DipUsr())) $ cUserAut
	MSGSTOP("Usuario sem autorização!")
	Return
EndIf

U_DIPPROC(ProcName(0),U_DipUsr()) 

@ 150,000 To 500,400 DIALOG oDlg TITLE OemToAnsi("ATUALIZANDO DATA DE RECOLHIMENTO DO ICMS-ST FORA DE SP.")

@ 008,010 Say "Informe a nota fiscal "                       
@ 008,120 Get cNfiscal Size 45,40  
@ 028,010 Say "Informe a série da nota fiscal"
@ 028,120 Get cSerie Size 20,40
@ 048,010 Say "Informe o código do fornecedor"
@ 048,120 Get  cFornec Size 45,40  F3 "SA2"  VALID (EXISTCPO("SA2"), cLoja := SA2->A2_LOJA)
@ 068,010 Say "Loja do fornecedor"
@ 068,120 Get  cloja Size 20,40 when .f.
@ 088,010 Say "Informe a emissão da nota fiscal"
@ 088,120 Get dEmissao Size 33,28 
@ 108,010 Say "INFORME A DATA DE RECOLHIMENTO DO ICMS-ST"
@ 120,010 Get dDtRecST Size 33,28 Valid dDtRecST > CTOD('01/04/2009')
@ 140,100 BMPBUTTON TYPE 1 ACTION AtuDtRecSt()
@ 140,140 BMPBUTTON TYPE 2 ACTION Close(oDlg)

ACTIVATE DIALOG oDlg Centered


Static Function AtuDtRecSt()     

Local _aMsg         := {}
Local _cAssunto     := ""
Local _cEmail       := ""  
Local _cDestCli  	:= ""  
Local _cFrom     	:= "" 
Local _cFuncSent 	:= "DIPA037.PRW


// Atualizando SF1
DbSelectArea("SF1")
DbSetOrder(1)
If SF1->(DbSeek(xFilial("SF1")+cNfiscal+cSerie+Alltrim(cFornec)+Alltrim(cLoja)+"N"))
	If SF1->F1_EMISSAO = dEmissao
		If SF1->F1_ICMSRET > 0 .AND. SF1->F1_EST <> 'SP'
			If MSGBOX("Confirma alteração da data de recolhimento do ICMS-ST de "+dtoc(SF1->F1_DTRECST)+" para "+dtoc(dDtRecST)+"  Na NFE  "+cNfiscal+" Série "+cSerie+" Fornecedor "+cFornec+"-"+cLoja+"?","Atenção","YESNO")		 
			 	Begin Transaction	
				RecLock("SF1",.F.)
				SF1->F1_DTRECST:= dDtRecST     
				SF1->(MsUnlock())
				SF1->(DbCommit()) 
				End Transaction			   		
				Alert("Nota fiscal "+cNfiscal+" foi atualizado com sucesso.")	                 
			Else                                                                                 
				Alert("Alteração cancelada.")
			Endif
		 Else 
			Alert("A nota fiscal não tem ICMS-ST ou o fornecedor não é de fora de SP.")			 
		 Endif
	Else
		Alert("A data de emissão informada não confere com a data da NF informada.")
	EndIF	
Else
	Alert("Nota Fiscal não encontrada "+cNfiscal+" não encontrado")
Endif  

Return()
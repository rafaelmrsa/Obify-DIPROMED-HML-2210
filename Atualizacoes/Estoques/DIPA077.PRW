#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"

/*
�����������������������������������������������������������������������������
���Programa  � DIPA077  � Autor �   Reginaldo Borges   � Data �  21/06/16 ���
�������������������������������������������������������������������������͹��
���Desc.     � Atualiza a data e regitro dos certificados de esteriliza��o���
�����������������������������������������������������������������������������
*/

User Function DIPA077()
U_DIPPROC(ProcName(0),U_DipUsr()) // Gravando o nome do Programa no SZU
_xAlias  := GetArea()
                      
PRIVATE aRotina := {  { "Pesquisa","AxPesqui"     , 0 , 1},;       //"Pesquisa" 
					  { "Reg.Certif.","U_INFOREG" , 0 , 2}} 


//� Define o cabecalho da tela de atualizacoes               �
cCadastro := "Registro do Certificado de Estereliza��o"
cMarca := GetMark()
MarkBrow("SF1","F1_OK2",,,,cMarca)
RestArea(_xAlias)

Return
                                        
/*
�����������������������������������������������������������������������������
���Programa  � INFOREG  � Autor �   Reginaldo Borges   � Data �  21/06/16 ���
�������������������������������������������������������������������������͹��
���Desc.     � Dialog para o usuario informar os dados                    ���
�����������������������������������������������������������������������������
*/
                                                                    
User Function INFOREG()            

U_DIPPROC(ProcName(0),U_DipUsr()) // Gravando o nome do Programa no SZU
 
Private oBOTAOOK
Private oBOTAOFECHAR
Private lCancel :=.F.
_xAlias := GetArea()
_cData  := CTOD("  /  /  ")
_cReg   := space(20)
_cUser  := Upper(U_DipUsr())

	@ 126,000 To 260,200 DIALOG oDlg Title OemToAnsi("Registro Certificado Esteriliza��o")
	@ 010,010 Say "Data: "
	@ 010,035 Get _cData  size 40,20 
	@ 025,010 Say "Registro: "
	@ 025,035 Get _cReg   size 40,20 
	@ 045,010 BUTTON oBOTAOOK     PROMPT   "&OK"   	 SIZE 030,010 PIXEL OF oDLG ACTION (GRAVAREG(),oDLG:END())
	@ 045,045 BUTTON oBOTAOFECHAR PROMPT   "&Fechar" SIZE 030,010 PIXEL OF oDLG ACTION (lCancel:=.T.,oDLG:END())
	
	Activate Dialog oDlg Centered
	
	If lCancel
		Aviso("Aten��o","Informa��o do registro cancelada pelo usu�rio!",{"Ok"},1)
	EndIf
	
RestArea(_xAlias)

Return


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �DIPA077   �Autor  �Microsiga           � Data �  06/24/16   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Static Function GRAVAREG()
         
SF1->(DbOrderNickName("F1OK2"))	// Utilizando DbOrderNickName ao inv�s de DbSetOrder  devido a virada de vers�o
If SF1->(DbSeek(xFilial("SF1")+cMarca))
	If 	Empty(_cData) .Or. Empty(_cReg)
		MsgInfo("Preencher ambos os campos, DATA e REGISTRO!","ATEN��O")
	Else
		
		If 	!Empty(SF1->F1_XDTRECE) .Or. !Empty(SF1->F1_XREGCER)
			
			If MsgYesNo("Campos preenchidos pelo Usuario "+_cUser+", deseja alterar-los?")
				While !Eof() .AND. xFILIAL("SF1") == SF1->F1_FILIAL
					RecLock("SF1",.F.)
					Replace F1_XDTRECE WITH _cData
					Replace F1_XREGCER WITH _cReg
					Replace F1_XUSRECE WITH _cUser
					
					SF1->F1_OK2 := ''
					SF1->(MsUnlock())
					SF1->(DbSeek(xFilial("SF1")+cMarca))
				END
			Else
				MsgInfo("Informa��es n�o foram substituidas!","ATEN��O")
			EndIf
		Else
			
			While !Eof() .AND. xFILIAL("SF1") == SF1->F1_FILIAL
				RecLock("SF1",.F.)
				Replace F1_XDTRECE WITH _cData
				Replace F1_XREGCER WITH _cReg
				Replace F1_XUSRECE WITH _cUser
				
				SF1->F1_OK2 := ''
				SF1->(MsUnlock())
				SF1->(DbSeek(xFilial("SF1")+cMarca))
			END
			
		EndIf
		
	EndIf
Else
	MsgInfo("VOC� N�O MARCOU NENHUMA NOTA!","ATEN��O!")
EndIf


Return()
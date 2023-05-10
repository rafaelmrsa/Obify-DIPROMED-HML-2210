/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �DIPA051() � Autor �Jailton B Santos-JBS   � Data �22/06/2010���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Manutencao de agendamento de um Pedido de Compra.          ���
�������������������������������������������������������������������������Ĵ��
���Uso       � Especifico De Compras Dipromed                             ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
���Programador � Data   �  Motivo da Alteracao                            ���
�������������������������������������������������������������������������Ĵ��
���            �        �                                                 ���
���            �        �                                                 ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"

User Function DIPA051(cAlias,nReg,nOpcx)

If Upper(U_DipUsr()) $ 'EELIAS/MCANUTO/DDOMINGOS/VQUEIROZ/VEGON/RBORGES'
	AxCadastro("SZO","AGENDAMENTO DE ENTREGA.")
Else 
	Aviso('Aten��o',Upper(U_DipUsr())+ ' voc� n�o tem autoriza��o para utilizar esta rotina.',{'Ok'})
Endif

/*
Local oDlg    
Local lAgenda := .F.
Local cFilSC7 := xFilial('SC7')
Local aAreaSC7:= SC7->(GetArea())
Local aAreaSA4:= SA4->(GetArea())
Local bOk     := {|| If(fGravaSC7(),oDlg:End(),) }
Local bCancel := {|| oDlg:End()} 

Private oDtEnt
Private oHrEnt
Private oCodTr
Private oNomCon
Private oFone  
Private oNomTr
Private oVolume

Private cNumPC := SC7->C7_NUM
Private dDtEnt := SC7->C7_DTENTRE
Private cHrEnt := SC7->C7_HRENTRE
Private cCodTr := SC7->C7_CODTRAN
Private cNomCon:= SC7->C7_NOMCONT
Private cFone  := SC7->C7_FONE 
Private nVolume:= SC7->C7_VOLUME
Private cNomTr := Space(Len(SA4->A4_NOME))

SA4->( DbSetOrder(1) )
If SA4->( DbSeek(xFilial('SA4') + SC7->C7_CODTRAN ) )
    cNomTr := SA4->A4_NOME
EndIf 

SC7->( DbSetOrder(1) ) // Filial + Num P.C. + Nr Item ...
SC7->( DbSeek(xFilial('SC7') + cNumPC + '0001') )

Do While SC7->(!EOF()) .and.SC7->C7_FILIAL == cFilSC7 .and. SC7->C7_NUM == cNumPC
	
	If SC7->C7_QUJE >= SC7->C7_QUANT .or.; // Pedido Atendido
		(SC7->C7_CONAPRO=="B".And.SC7->C7_QUJE < SC7->C7_QUANT) .or.;// Bloqueado
		SC7->C7_QTDACLA >0 .or.; // Pedido Usado em Pre-Nota
		!Empty(SC7->C7_RESIDUO)  // Eliminado por Residuo
		
		SC7->( DbSkip())
		Loop
		
	EndIf 
	
	lAgenda := .T. 
	Exit
	
EndDo               

SC7->( DbGoTo(nReg) )

If !lAgenda
	Aviso('Aten��o','N�o foi encontrado nenhum item do pedido para realizar agendamento de entrega. Agendamento n�o poder� ser realizado.',{'Ok'})
Else
	Define MsDialog oDlg Title "AGEDAMENTO DE ENTTREGA ( Pedido Nro " + AllTrim(cNumPC)+" )" from 0,0 to 180,500 of oMainWnd pixel
	
	@ 10,05 Say 'Data de Entrega' size 50,08 Of oDlg Pixel
	@ 20,05 Say 'Hora de Entrega' size 50,08 Of oDlg Pixel
	@ 30,05 Say 'Transportadora ' size 50,08 Of oDlg Pixel
	@ 40,05 Say 'Qtde Volumes'    size 50,08 Of oDlg Pixel
	@ 50,05 Say 'Contato Fornec'  size 50,08 Of oDlg Pixel
	@ 60,05 Say 'Telefone'        size 50,08 Of oDlg Pixel
	
	@ 10,050 msGet oDtEnt  var dDtEnt  valid Empty(dDtEnt).or. dDtEnt >= dDataBase Size 40,08 Of oDlg Pixel
	@ 20,050 msGet oHrEnt  var cHrEnt  valid !Empty(cHrEnt)  Picture "99:99:99" Size 30,08 Of oDlg Pixel
	@ 30,050 msGet oCodTr  var cCodTr  F3 'SA4' valid fValid('TRANSP') Size 30,08 Of oDlg Pixel
	@ 30,085 msGet oNomTr  var cNomTr  when .f. Size 90,08 Of oDlg Pixel
	@ 40,050 msGet oVolume var nVolume valid !Empty(nVolume) Picture '@e 9999' Size 30,08 Of oDlg Pixel
	@ 50,050 msGet oNomCon var cNomCon valid !Empty(cNomCon) Size 80,08 Of oDlg Pixel
	@ 60,050 msGet oFone   var cFone   valid !Empty(cFone) picture "(##) #999-9999" Size 60,08 Of oDlg Pixel
	
	@ 10,200 Button OemToAnsi("Confirma") size 40,15 pixel of oDlg action eval(bOk)
	@ 34,200 Button OemToAnsi("Cancela")  size 40,15 pixel of oDlg action eval(bCancel)
	
	Activate MsDialog oDlg Centered
EndIf
SC7->( RestArea(aAreaSC7) )
SA4->( RestArea(aAreaSA4) )
*/
Return(.T.)                        
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �fGravaSC7()�Autor �Jailton B Santos-JBS� Data � 22/06/2010  ���
�������������������������������������������������������������������������͹��
���Desc.     � Aplica os criterios de validacao de cada campo e faz as de-���
���          � vidas criticas, quando nao contemplados satisfatoriamente. ���
�������������������������������������������������������������������������͹��
���Uso       � Especifico De Compras Dipromed                             ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function fValid(cCampo)

Local lRet := .T. 

do case 
case cCampo == 'TRANSP' 
     
     If SA4->( !DbSeek( xFilial('SA4')+cCodTr) )
         Aviso('Aten��o','Codigo de transportadora n�o cadastrado.',{'OK'}) 
         lRet := .F.
     Else
         cNomTr := SA4->A4_NOME                                                   
         oNomTr:Refresh()
     EndIf
EndCase             

Return(lRet)    
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �fGravaSC7()�Autor �Jailton B Santos-JBS� Data � 22/06/2010  ���
�������������������������������������������������������������������������͹��
���Desc.     � Se todos os campos estiverem preenchidos, grava-os no SC7, ���
���          � caso contrario faz critica ao usuario..                    ���
�������������������������������������������������������������������������͹��
���Uso       � Especifico De Compras Dipromed                             ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function fGravaSC7()

Local lRet    := .F.  
Local cFilSC7 := xFilial('SC7')

Begin Sequence 
//---------------------------------------------------------------------------------------------------------------
// Verifica se todos os campos foram preenchidos e aborta se existir campo nao preenchido.
//---------------------------------------------------------------------------------------------------------------
do Case 
case Empty(dDtEnt)  ; Aviso('Aten��o','Informe uma data de entrega maior ou igual a data atual.',{'OK'}); Break
case Empty(cHrEnt)  ; Aviso('Aten��o','Informe uma hora valida.',{'OK'})                                ; Break
case Empty(cCodTr)  ; Aviso('Aten��o','Informe uma transportadora valida.',{'OK'})                      ; Break
case Empty(cNomCon) ; Aviso('Aten��o','Informe um nome de contato do fornecedor.',{'OK'})               ; Break
case Empty(cFone)   ; Aviso('Aten��o','Informe um numero de telefone para falar com o contato.',{'OK'}) ; Break
EndCase             
//---------------------------------------------------------------------------------------------------------------
// Grava as informacoes, que o usuario digitou, na tabela SC7.
//---------------------------------------------------------------------------------------------------------------
SC7->( DbSetOrder(1) ) // Filial + Num P.C. + Nr Item ...
SC7->( DbSeek(xFilial('SC7') + SC7->C7_NUM + '0001') )

Do While SC7->(!EOF()) .and.SC7->C7_FILIAL == cFilSC7 .and. SC7->C7_NUM == cNumPC
	
	If SC7->C7_QUJE >= SC7->C7_QUANT .or.; // Pedido Atendido
		(SC7->C7_CONAPRO=="B".And.SC7->C7_QUJE < SC7->C7_QUANT) .or.;// Bloqueado
		SC7->C7_QTDACLA >0 .or.; // Pedido Usado em Pre-Nota
		!Empty(SC7->C7_RESIDUO)  // Eliminado por Residuo
		
		SC7->( DbSkip())
		Loop
		
	EndIf
	
	SC7->( RecLock('SC7',.F.) )
    SC7->C7_DTENTRE := dDtEnt
    SC7->C7_HRENTRE := cHrEnt
    SC7->C7_CODTRAN := cCodTr
    SC7->C7_VOLUME  := nVolume
    SC7->C7_NOMCONT := cNomCon
    SC7->C7_FONE    := cFone
    SC7->( MsUnLock('SC7') )

    SC7->( DbSkip() )
    
    lRet := .T.

EndDo

If !lRet
    Aviso('Aten��o','N�o foi encontrado nenhum item do pedido para realizar agendamento de entrega. Agendamento n�o realizado.',{'Ok'})
EndIf                                                                                                                   

End Sequence

Return(lRet)
#INCLUDE "rwmake.ch"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � DIPA020  � Autor � Eriberto Elias     � Data �  24/03/03   ���
�������������������������������������������������������������������������͹��
���Descricao � percentuais de comissoes por vendedor/operador e periodo   ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP6 IDE                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

User Function DIPA020()


//���������������������������������������������������������������������Ŀ
//� Declaracao de Variaveis                                             �
//�����������������������������������������������������������������������

Local cVldAlt := ".T." // Validacao para permitir a alteracao. Pode-se utilizar ExecBlock.
Local cVldExc := ".T." // Validacao para permitir a exclusao. Pode-se utilizar ExecBlock.
Local cVendInt   := GetMV("MV_DIPVINT")// MCVN - 01/06/09
Local cVendExt   := GetMV("MV_DIPVEXT")// MCVN - 01/06/09

Private cString := "SZF"
U_DIPPROC(ProcName(0),U_DipUsr()) // JBS 05/10/2005 - Gravando o nome do Programa no SZU

If !(Upper(U_DipUsr()) $ AllTrim(GetNewPar("ES_DIPA020","MCANUTO/PMENDONCA/DDOMINGOS/VEGON/RBORGES/BRODRIGUES")))
	Alert(Upper(U_DipUsr())+", voc� n�o tem autoriza��o para utilizar esta rotina. Qualquer d�vida falar com Eriberto!","ES_DIPA020")	
	Return()
EndIF

dbSelectArea("SZF")
dbSetOrder(1)

AxCadastro(cString,"Manutencao de percentuais de comissoes por vendedor/operador e periodo",cVldAlt,cVldExc)

Return

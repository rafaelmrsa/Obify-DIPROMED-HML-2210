#include "protheus.ch"
#include "parmtype.ch"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �MT010ALT()�Autor  �Jailton B Santos-JBS� Data � 23/04/2010  ���
�������������������������������������������������������������������������͹��
���Desc.     �Ponto de Entrada chamado na alteracao do produto, apos a    ���
���          �gravar os dados do produto                                  ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Funcao    �Gravar informacoes da substituicao tributaria no produto    ���
���          �                                                            ���  
���Desc.     � PE ap�s a grava��o da altera��o. Faz chamada � replica��o  ���
���          � do produto para outras empresas/filiais                    ���
�������������������������������������������������������������������������͹��
���Uso       � Especifico para Faturamento - Dipromed                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
//Fonte MVC - Realizado ajuste para chamar o ponto de entrada em MVC - Felipe Duran - 27/05/2020
User Function ITEM()

Local aParam   := PARAMIXB
Local oModel   := FwModelActive()
Local oObj     := ""
Local cIdPonto := ""
Local cIdModel := ""
Local lIsGrid  := .F.
Local xRet     := .T.
//Fonte MVC
Local UserRevFis    := GetMv("MV_UREVFIS")                      
Local nlibera        := 1

//Fonte MVC
// VERIFICA SE APARAM N�O EST� NULO
If aParam <> NIL
   oObj := aParam[1]
   cIdPonto := aParam[2]
   cIdModel := aParam[3]
   lIsGrid := (Len(aParam) > 3)         
//  VERIFICA SE O PONTO EM QUEST�O � O FORMPOS
	If cIdPonto == "MODELPOS"     
// VERIFICA SE OMODEL N�O EST� NULO
    	If oModel <> NIL
//Fonte MVC
// Verifica ICMS-ST MCVN - 11/03/09     
U_M010NCM("MT010ALT")  // Verifica ICMS-ST MCVN - 11/03/09     

			If !('DIPM_B1' $ FUNNAME()) .And. (Type("l010Auto")=="U" .Or. !l010Auto) .And. (SB1->B1_TIPO = 'PA'  .OR. ( SB1->B1_TIPO <> 'PA' .AND. Empty(ALLTRIM(SB1->B1_DREVFIS)))) 
// Avalia��o do Departamento Fiscal - MCVN 17/09/10
				If 	Upper(U_DipUsr()) $ UserRevFis 
					If Empty(ALLTRIM(SB1->B1_DREVFIS))                                            
						nlibera:=Aviso("Aten��o","DEPARTAMENTO FISCAL - Liberar produto para venda?" ,{"SIM","NAO"})
							If nlibera == 1
								SB1->( RecLock("SB1",.F.))	
								SB1->B1_DREVFIS := Upper(U_DipUsr()) // Usu�rio que Avaliou produto
								SB1->( MsUnLock('SB1'))          
							Endif	
					Else
						nlibera:=Aviso("Aten��o","DEPARTAMENTO FISCAL - Manter produto Liberado para venda?" ,{"SIM","NAO"})
						If nlibera == 2
							SB1->( RecLock("SB1",.F.))	
							SB1->B1_DREVFIS := ""                                                                     
							SB1->( MsUnLock('SB1'))          
						Endif	
					Endif
				Endif
			Endif                                                    

			If B1_TIPO <> "GG"
//-- Verifica replica��o do cadastro
				If (Type("l010Auto")=="U".Or.!l010Auto) 
					If cEmpAnt+cFilAnt == "0401" 
						U_CpySB1("04","02")
					ElseIf cEmpAnt+cFilAnt == "0402" 
						U_CpySB1("04","01")
					ElseIf cEmpAnt+cFilAnt == "0101" 
						U_CpySB1("01","04") //-- Copia para Dipromed/CD
					ElseIf cEmpAnt+cFilAnt == "0104" 
						U_CpySB1("01","01") //-- Copia para Dipromed/MTZ
					EndIf
				EndIf
			EndIf
//Fonte MVC
		Endif
	Endif	
Endif

Return xRet
//Fonte MVC

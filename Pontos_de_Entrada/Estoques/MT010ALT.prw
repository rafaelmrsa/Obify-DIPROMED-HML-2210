#include "protheus.ch"
#include "parmtype.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณMT010ALT()บAutor  ณJailton B Santos-JBSบ Data ณ 23/04/2010  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณPonto de Entrada chamado na alteracao do produto, apos a    บฑฑ
ฑฑบ          ณgravar os dados do produto                                  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบFuncao    ณGravar informacoes da substituicao tributaria no produto    บฑฑ
ฑฑบ          ณ                                                            บฑฑ  
ฑฑบDesc.     ณ PE ap๓s a grava็ใo da altera็ใo. Faz chamada เ replica็ใo  บฑฑ
ฑฑบ          ณ do produto para outras empresas/filiais                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Especifico para Faturamento - Dipromed                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
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
// VERIFICA SE APARAM NรO ESTม NULO
If aParam <> NIL
   oObj := aParam[1]
   cIdPonto := aParam[2]
   cIdModel := aParam[3]
   lIsGrid := (Len(aParam) > 3)         
//  VERIFICA SE O PONTO EM QUESTรO ษ O FORMPOS
	If cIdPonto == "MODELPOS"     
// VERIFICA SE OMODEL NรO ESTม NULO
    	If oModel <> NIL
//Fonte MVC
// Verifica ICMS-ST MCVN - 11/03/09     
U_M010NCM("MT010ALT")  // Verifica ICMS-ST MCVN - 11/03/09     

			If !('DIPM_B1' $ FUNNAME()) .And. (Type("l010Auto")=="U" .Or. !l010Auto) .And. (SB1->B1_TIPO = 'PA'  .OR. ( SB1->B1_TIPO <> 'PA' .AND. Empty(ALLTRIM(SB1->B1_DREVFIS)))) 
// Avalia็ใo do Departamento Fiscal - MCVN 17/09/10
				If 	Upper(U_DipUsr()) $ UserRevFis 
					If Empty(ALLTRIM(SB1->B1_DREVFIS))                                            
						nlibera:=Aviso("Aten็ใo","DEPARTAMENTO FISCAL - Liberar produto para venda?" ,{"SIM","NAO"})
							If nlibera == 1
								SB1->( RecLock("SB1",.F.))	
								SB1->B1_DREVFIS := Upper(U_DipUsr()) // Usuแrio que Avaliou produto
								SB1->( MsUnLock('SB1'))          
							Endif	
					Else
						nlibera:=Aviso("Aten็ใo","DEPARTAMENTO FISCAL - Manter produto Liberado para venda?" ,{"SIM","NAO"})
						If nlibera == 2
							SB1->( RecLock("SB1",.F.))	
							SB1->B1_DREVFIS := ""                                                                     
							SB1->( MsUnLock('SB1'))          
						Endif	
					Endif
				Endif
			Endif                                                    

			If B1_TIPO <> "GG"
//-- Verifica replica็ใo do cadastro
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

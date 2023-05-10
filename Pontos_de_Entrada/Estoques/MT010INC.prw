
//PONTO.......: MT010INC          PROGRAMA....: MATA010
//DESCRIÇÄO...: APOS INCLUSAO DO PRODUTO
//UTILIZAÇÄO..: Usado após a inclusao de um registro no SB1.
   //           Nem confirma nem cancela, só usado para acrecestanr dados.
 //
//PARAMETROS..: UPAR do tipo X :

//RETORNO.....: URET do tipo X :

//OBSERVAÇÖES.: <NENHUM>

//ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
//±±ºPrograma  ³  MT010INC º Autor ³ Eriberto Elias    º Data ³  31/03/2004   º±±
//±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
//±±ºDescricao ³ inclui registro no SB3 para evitar erros no relatorio DIPR036 ±±
//±±ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
//±±Alterações: 28/06/2006 -incluido a busca SB2 no local 05,se não tem incluo.±± 
//±±Alterações: 18/06/2007 -incluido a busca SB2 no local 06/07/08/09/10 E 11, ±±
//±±            se não tem incluo.                                             ±±
//ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
       
 
#include "rwmake.ch"

User Function MT010INC()
Local _xAlias   := GetArea()
Local _areaSB1 := SB1->(getarea())
Local _areaSB2 := SB2->(getarea())
Local _areaSB3 := SB3->(getarea())    

U_DIPPROC(ProcName(0),U_DipUsr()) // JBS 05/10/2005 - Gravando o nome do Programa no SZU


DbSelectArea("SB2")
SB2->(DbSetOrder(1))
IF !SB2->(DbSeek(xFilial("SB2")+SB1->B1_COD))
	RecLock("SB2",.T.)
	SB2->B2_FILIAL := xFilial("SB2")
	SB2->B2_COD    := SB1->B1_COD
	SB2->B2_LOCAL  := SB1->B1_LOCPAD 
	SB2->B2_FORNEC := SB1->B1_PROC     // MCVN - 22/10/10
	SB2->B2_LOJAFOR:= SB1->B1_LOJPROC  // MCVN - 22/10/10
	SB2->(MsUnLock())
ENDIF

/* Armazem 05  -  Desabilitado 18/06/2007

IF !SB2->(DbSeek(xFilial("SB2")+SB1->B1_COD+"05"))
	RecLock("SB2",.T.)
	SB2->B2_FILIAL := xFilial("SB2")
	SB2->B2_COD    := SB1->B1_COD
	SB2->B2_LOCAL  := "05"
	SB2->(MsUnLock())
ENDIF    
*/
                                         
// MCVN 17/08/09
If ("HEALTH" $ SM0->M0_NOMECOM)
	// Criando registro no Armazem 02  - 10/08/09 NA HQ
	IF !SB2->(DbSeek(xFilial("SB2")+SB1->B1_COD+"02"))
		RecLock("SB2",.T.)
		SB2->B2_FILIAL := xFilial("SB2")
		SB2->B2_COD    := SB1->B1_COD
		SB2->B2_LOCAL  := "02"
		SB2->B2_FORNEC := SB1->B1_PROC     // MCVN - 22/10/10
		SB2->B2_LOJAFOR:= SB1->B1_LOJPROC  // MCVN - 22/10/10
		SB2->(MsUnLock())
	ENDIF    
                         
	// Criando registro no Armazem 03  - 10/08/09 NA HQ
	IF !SB2->(DbSeek(xFilial("SB2")+SB1->B1_COD+"03"))
		RecLock("SB2",.T.)
		SB2->B2_FILIAL := xFilial("SB2")
		SB2->B2_COD    := SB1->B1_COD
		SB2->B2_LOCAL  := "03"
		SB2->B2_FORNEC := SB1->B1_PROC     // MCVN - 22/10/10
		SB2->B2_LOJAFOR:= SB1->B1_LOJPROC  // MCVN - 22/10/10
		SB2->(MsUnLock())
	ENDIF    

	// Criando registro no Armazem 04  - 24/08/09 NA HQ MATERIAL DE CONSUMO
	IF !SB2->(DbSeek(xFilial("SB2")+SB1->B1_COD+"04"))
		RecLock("SB2",.T.)
		SB2->B2_FILIAL := xFilial("SB2")
		SB2->B2_COD    := SB1->B1_COD
		SB2->B2_LOCAL  := "04"
		SB2->B2_FORNEC := SB1->B1_PROC     // MCVN - 22/10/10
		SB2->B2_LOJAFOR:= SB1->B1_LOJPROC  // MCVN - 22/10/10
		SB2->(MsUnLock())
	ENDIF   
                    
	// Criando registro no Armazem 05  - 10/08/09 NA HQ
	IF !SB2->(DbSeek(xFilial("SB2")+SB1->B1_COD+"05"))
		RecLock("SB2",.T.)
		SB2->B2_FILIAL := xFilial("SB2")
		SB2->B2_COD    := SB1->B1_COD
		SB2->B2_LOCAL  := "05"
		SB2->B2_FORNEC := SB1->B1_PROC     // MCVN - 22/10/10
		SB2->B2_LOJAFOR:= SB1->B1_LOJPROC  // MCVN - 22/10/10
		SB2->(MsUnLock())
	ENDIF  
Endif

// Criando registro no Armazem 06  - 18/06/2007
IF !SB2->(DbSeek(xFilial("SB2")+SB1->B1_COD+"06"))
	RecLock("SB2",.T.)
	SB2->B2_FILIAL := xFilial("SB2")
	SB2->B2_COD    := SB1->B1_COD
	SB2->B2_LOCAL  := "06"
	SB2->B2_FORNEC := SB1->B1_PROC     // MCVN - 22/10/10
	SB2->B2_LOJAFOR:= SB1->B1_LOJPROC  // MCVN - 22/10/10
	SB2->(MsUnLock())
ENDIF

// Criando registro no Armazem 07  - 18/06/2007
IF !SB2->(DbSeek(xFilial("SB2")+SB1->B1_COD+"07"))
	RecLock("SB2",.T.)
	SB2->B2_FILIAL := xFilial("SB2")
	SB2->B2_COD    := SB1->B1_COD 	
	SB2->B2_LOCAL  := "07"        
	SB2->B2_FORNEC := SB1->B1_PROC     // MCVN - 22/10/10
	SB2->B2_LOJAFOR:= SB1->B1_LOJPROC  // MCVN - 22/10/10
	SB2->(MsUnLock())
ENDIF

// Criando registro no Armazem 08  - 18/06/2007
IF !SB2->(DbSeek(xFilial("SB2")+SB1->B1_COD+"08"))
	RecLock("SB2",.T.)
	SB2->B2_FILIAL := xFilial("SB2")
	SB2->B2_COD    := SB1->B1_COD
	SB2->B2_LOCAL  := "08"        
	SB2->B2_FORNEC := SB1->B1_PROC     // MCVN - 22/10/10
	SB2->B2_LOJAFOR:= SB1->B1_LOJPROC  // MCVN - 22/10/10
	SB2->(MsUnLock())
ENDIF

// Criando registro no Armazem 09  - 18/06/2007
IF !SB2->(DbSeek(xFilial("SB2")+SB1->B1_COD+"09"))
	RecLock("SB2",.T.)
	SB2->B2_FILIAL := xFilial("SB2")
	SB2->B2_COD    := SB1->B1_COD
	SB2->B2_LOCAL  := "09"
	SB2->B2_FORNEC := SB1->B1_PROC     // MCVN - 22/10/10
	SB2->B2_LOJAFOR:= SB1->B1_LOJPROC  // MCVN - 22/10/10
	SB2->(MsUnLock())
ENDIF

// Criando registro no Armazem 10  - 18/06/2007
IF !SB2->(DbSeek(xFilial("SB2")+SB1->B1_COD+"10"))
	RecLock("SB2",.T.)
	SB2->B2_FILIAL := xFilial("SB2")
	SB2->B2_COD    := SB1->B1_COD
	SB2->B2_LOCAL  := "10"
	SB2->B2_FORNEC := SB1->B1_PROC     // MCVN - 22/10/10
	SB2->B2_LOJAFOR:= SB1->B1_LOJPROC  // MCVN - 22/10/10
	SB2->(MsUnLock())
ENDIF

// Criando registro no Armazem 11  - 18/06/2007
IF !SB2->(DbSeek(xFilial("SB2")+SB1->B1_COD+"11"))
	RecLock("SB2",.T.)
	SB2->B2_FILIAL := xFilial("SB2")
	SB2->B2_COD    := SB1->B1_COD
	SB2->B2_LOCAL  := "11"
	SB2->B2_FORNEC := SB1->B1_PROC     // MCVN - 22/10/10
	SB2->B2_LOJAFOR:= SB1->B1_LOJPROC  // MCVN - 22/10/10
	SB2->(MsUnLock())
ENDIF 

// Criando registro no Armazem 12  - 31/10/2011
IF !SB2->(DbSeek(xFilial("SB2")+SB1->B1_COD+"12"))
	RecLock("SB2",.T.)
	SB2->B2_FILIAL := xFilial("SB2")
	SB2->B2_COD    := SB1->B1_COD
	SB2->B2_LOCAL  := "12"
	SB2->B2_FORNEC := SB1->B1_PROC     
	SB2->B2_LOJAFOR:= SB1->B1_LOJPROC  
	SB2->(MsUnLock())
ENDIF

// Criando registro no Armazem 13  - 31/10/2011
IF !SB2->(DbSeek(xFilial("SB2")+SB1->B1_COD+"13"))
	RecLock("SB2",.T.)
	SB2->B2_FILIAL := xFilial("SB2")
	SB2->B2_COD    := SB1->B1_COD
	SB2->B2_LOCAL  := "13"                               
	SB2->B2_FORNEC := SB1->B1_PROC     
	SB2->B2_LOJAFOR:= SB1->B1_LOJPROC  
	SB2->(MsUnLock())
ENDIF     


DbSelectArea("SB3")
SB3->(DbSetOrder(1))
IF !SB3->(DbSeek(xFilial("SB3")+SB1->B1_COD))
	RecLock("SB3",.T.)
	SB3->B3_FILIAL := xFilial("SB3")
	SB3->B3_COD    := SB1->B1_COD
	SB3->B3_CLASSE := 'C'
	SB3->(MsUnLock())
ENDIF

U_GravaZG("SB1")
If !('DIPM_B1' $ FUNNAME()) .And. (Type("l010Auto")=="U".Or.!l010Auto)
	U_M010NCM("MT010INC")  // Verifica ICMS-ST MCVN - 20/04/09
Endif

//-- Verifica replicação do cadastro
If (Type("l010Auto")=="U".Or.!l010Auto) 
(Type("l010Auto")=="U".Or.!l010Auto) 
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

RestArea(_areaSB3)
RestArea(_areaSB2)
RestArea(_areaSB1)
RestArea(_xAlias)

Return()
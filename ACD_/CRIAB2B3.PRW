/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³  CRIAB2B3 º Autor ³ Maximo Canuto V. Neto º Data ³ 31/03/2004º±±
++ Criar B2 e B3 dos produtos de licitação criados antes de 23/07/07         ++ 
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
*/
#include "rwmake.ch"

User Function CRIAB2B3()

Private cB1_LOCPAD := '01'
Private cB1_COD := '000230	'
Private cContaB1:= 1

if !(Upper(Alltrim(Substr(cUsuario,7,15))) $ 'MCANUTO')  .and. cEmpAnt == '01'
    MSGINFO("Sem autorização ou Empresa errada!")
	Return()
Endif
        



SB1->(DbSelectArea("SB1"))
SB1->(DbSetOrder(1)) 
SB1->(DbGoTop())    
SB1->(dbSeek(xFilial("SB1")))
While SB1->( !EOF() )                                
	
	cB1_COD := SB1->B1_COD
	
	If SB1->B1_FILIAL = xFilial("SB1") .And. SB1->B1_TIPO = 'MP' .And. SB1->B1_APROPRI = 'I'
		Processa({|lEnd| Criando()},"Processando...Produto: "+cB1_COD)   
		cContaB1 ++
	Endif
	SB1->(DbSkip())
End

MSGINFO("Processo concluido")
Return()

Static Function criando()

/*
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
*/
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

	// Criando registro no Armazem 02  - 10/08/09 NA HQ
	IF !SB2->(DbSeek(xFilial("SB2")+SB1->B1_COD+"99"))
		RecLock("SB2",.T.)
		SB2->B2_FILIAL := xFilial("SB2")
		SB2->B2_COD    := SB1->B1_COD
		SB2->B2_LOCAL  := "99"
		SB2->B2_FORNEC := SB1->B1_PROC     // MCVN - 22/10/10
		SB2->B2_LOJAFOR:= SB1->B1_LOJPROC  // MCVN - 22/10/10
		SB2->(MsUnLock())
	ENDIF    
/*                         
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
*/

DbSelectArea("SB3")
SB3->(DbSetOrder(1))
IF !SB3->(DbSeek(xFilial("SB3")+SB1->B1_COD))
	RecLock("SB3",.T.)
	SB3->B3_FILIAL := xFilial("SB3")
	SB3->B3_COD    := SB1->B1_COD
	SB3->B3_CLASSE := 'C'
	SB3->(MsUnLock())
ENDIF

Return()

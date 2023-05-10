#include 'protheus.ch'
/*-------------------------------------------------------------------------------------
{Protheus.doc} GATC6TES

@Author  	   Tiago Stocco - Obify
@since		   08/2021
@version	   P12

@description Gatilho do SC6 para corrigir o C6_CF
*/
user function GATC6CF()
Local cTES  := GDFieldGet("C6_TES")
LOCAL cCF 	:= GDFieldGet("C6_CF")
Local aDadosCfo := {}
Aadd(aDadosCfo,{"OPERNF","S"})
Aadd(aDadosCfo,{"TPCLIFOR",M->C5_TIPOCLI})
If !M->C5_TIPO $ "D|B" 
    Aadd(aDadosCfo,{"UFDEST",SA1->A1_EST})
    Aadd(aDadosCfo,{"INSCR" ,SA1->A1_INSCR})
    If SA1->(FieldPos("A1_CONTRIB")) > 0 		 						
        Aadd(aDadosCfo,{"CONTR", SA1->A1_CONTRIB})
    EndIf
else
    Aadd(aDadosCfo,{"UFDEST",SA2->A2_EST})
    Aadd(aDadosCfo,{"INSCR" ,SA2->A2_INSCR})
    If SA2->(FieldPos("A2_CONTRIB")) > 0 		 						
        Aadd(aDadosCfo,{"CONTR", SA2->A2_CONTRIB})
    EndIf
EndIf
dbSelectArea("SF4")
dbSetOrder(1)
MsSeek(xFilial("SF4")+cTES,.F.)
cCF := MaFisCfo(,SF4->F4_CF,aDadosCfo)

/* Alterado pela funcao padrao - 31-03-21
If SA1->A1_EST <> 'SP'
    cCF:= "6"+Substr(cCF,2,3)    
elseif SA1->A1_EST == 'EX'
    cCF:= "7"+Substr(cCF,2,3)
EndIf
*/
return cCF

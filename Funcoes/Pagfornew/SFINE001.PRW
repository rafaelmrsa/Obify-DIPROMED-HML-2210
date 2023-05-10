#include "rwmake.ch" 
#include "protheus.ch"
/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ SFINE001 ³ Autor ³ Natalino Oliveira     ³ Data ³ 08/10/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Transformacao da Linha digitavel em codigo de barra.       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/

User Function SFINE001()
Local aArea := GetArea()
Local _cRetorno
Local CSTR
Local I
Local NMULT
Local NMODULO
Local CCHAR
Local CDIGITO
Local CDV1
Local CDV2
Local CDV3
Local CCAMPO1
Local CCAMPO2
Local CCAMPO3
Local NVAL
Local NCALC_DV1
Local NCALC_DV2
Local NCALC_DV3
Local NREST

U_DIPPROC(ProcName(0),U_DipUsr()) //MCVN - 22/01/2009

_cRetorno := ''

if ValType(M->E2_LD) == NIL
  RestArea(aArea)
  Return(_cRetorno)      
Endif

cStr := M->E2_LD

i := 0
nMult := 2
nModulo := 0
cChar   := SPACE(1)
cDigito := SPACE(1)

cDV1    := SUBSTR(cStr,10, 1) 
cDV2    := SUBSTR(cStr,21, 1) 
cDV3    := SUBSTR(cStr,32, 1) 
   
cCampo1 := SUBSTR(cStr, 1, 9)
cCampo2 := SUBSTR(cStr,11,10)
cCampo3 := SUBSTR(cStr,22,10)

nMult   := 2
nModulo := 0
nVal    := 0
   
// Calcula DV1

For i := Len(cCampo1) to 1 Step -1
  cChar := Substr(cCampo1,i,1)
  If isAlpha(cChar)
    Help(" ", 1, "ONLYNUM")
    RestArea(aArea)
    Return(_cRetorno) 
  endif
  nModulo := Val(cChar)*nMult
  If nModulo >= 10
    nVal := NVAL + 1
    nVal := nVal + (nModulo-10)
  Else
    nVal := nVal + nModulo	
  EndIf	
  nMult:= if(nMult==2,1,2)
Next        
nCalc_DV1 := 10 - (nVal % 10)

//Calcula DV2

nMult   := 2
nModulo := 0
nVal    := 0
   
For i := Len(cCampo2) to 1 Step -1
  cChar := Substr(cCampo2,i,1)
  If isAlpha(cChar)
    Help(" ", 1, "ONLYNUM")
	  RestArea(aArea)
      Return(_cRetorno)
  endif        
  nModulo := Val(cChar)*nMult
  If nModulo >= 10
    nVal := nVal + 1
	nVal := nVal + (nModulo-10)
  Else
	nVal := nVal + nModulo	
  EndIf	
	nMult:= if(nMult==2,1,2)
Next        
nCalc_DV2 := 10 - (nVal % 10)

// Calcula DV3

nMult   := 2
nModulo := 0
nVal    := 0
   
For i := Len(cCampo3) to 1 Step -1
  cChar := Substr(cCampo3,i,1)
  if isAlpha(cChar)
    Help(" ", 1, "ONLYNUM")
    RestArea(aArea)
    Return(_cRetorno)
  endif        
  nModulo := Val(cChar)*nMult
  If nModulo >= 10
	nVal := nVal + 1
	nVal := nVal + (nModulo-10)
  Else
	nVal := nVal + nModulo	
  EndIf	
    nMult:= if(nMult==2,1,2)
Next        
nCalc_DV3 := 10 - (nVal % 10)                      

If nCalc_DV1 == 10
  nCalc_DV1 := 0  
EndIf
If nCalc_DV2 == 10
  nCalc_DV2 := 0  
EndIf
If nCalc_DV3 == 10
  nCalc_DV3 := 0  
EndIf

if !(nCalc_DV1 == Val(cDV1) .and. nCalc_DV2 == Val(cDV2) .and. nCalc_DV3 == Val(cDV3) )
  Help(" ",1,"INVALCODBAR")
  RestArea(aArea)
  Return(_cRetorno)
endif                
   
_cRetorno := SUBSTR(cStr, 1, 4)+SUBSTR(cStr, 33, 1)+iif(Len(alltrim(SUBSTR(cStr, 34, 14)))<14,StrZero(Val(Alltrim(SUBSTR(cStr, 34, 14))),14),SUBSTR(cStr, 34, 14))+SUBSTR(cStr, 5, 5)+SUBSTR(cStr, 11, 10)+SUBSTR(cStr, 22, 10)

RestArea(aArea)     

Return(_cRetorno)
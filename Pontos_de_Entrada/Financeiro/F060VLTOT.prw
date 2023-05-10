#include 'protheus.ch'
#include 'parmtype.ch'
#INCLUDE "RWMAKE.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³F060VLTOT ºAutor  ³Microsiga           º Data ³  23/03/18   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function F060VLTOT()
Local aAreaSA1 	:= SA1->(GetArea())
Local nValor 	:= PARAMIXB[1]
Local cDipTit   := ""
Local cMsgCic   := ""
Local cDipBor   := ""
Local _cEmail   := "diego.domingos@dipromed.com.br;maximo.canuto@dipromed.com.br"
Local _cFrom    := "protheus@dipromed.com.br"
Local _cFuncSent:= "F060VLTOT(F060VLTOT.PRW)
Local _cAssunto := EncodeUTF8("Títulos desmarcados (Borderô ","cp1252")
Local _aMsg 	:= {}

Aadd( _aMsg , {"Prefixo+Num+Tipo+Parcela","Cliente-Nome "})
		
SA1->(dbSetOrder(1))

TRB->(dbGoTop())
While !TRB->(Eof())
	If SA1->(dbSeek(xFilial("SA1")+TRB->(E1_CLIENTE+E1_LOJA)))
		If SA1->A1_XMARBOR=='2' .Or.; 
			(cEmpAnt=="01" .And. SA1->A1_COD=="011050") .Or.;
			(cEmpAnt=="04" .And. SA1->A1_COD=="000804") .Or.;
			LEFT(SA1->A1_CNAE,2)=="84"
			
			TRB->(RecLock("TRB",.F.))
				TRB->E1_OK := ""				
			TRB->(MsUnLock())
			nValor -= TRB->E1_SALDO	
			nQtdTit--
			cDipTit	+= TRB->(E1_PREFIXO+E1_NUM+E1_TIPO+E1_PARCELA)+'/'+SA1->A1_COD+'-'+AllTrim(SA1->A1_NREDUZ)+CHR(13)+CHR(10)
			
			Aadd( _aMsg , { TRB->(E1_PREFIXO+E1_NUM+E1_TIPO+E1_PARCELA) , SA1->A1_COD+'-'+AllTrim(SA1->A1_NREDUZ) } )
			
			If Empty(cDipBor)
				cDipBor := TRB->E1_NUMBOR
			EndIf		
		EndIf
	EndIf
	TRB->(dbSkip())
EndDo

If !Empty(cDipTit)	
	Aviso("Títulos Desmarcados",+CHR(13)+CHR(10)+"Prefixo+Num+Tipo+Parcela/Cliente-Nome "+CHR(13)+CHR(10)+cDipTit,{"Ok"},3)
	//cMsgCic := "Títulos desmarcados no borderô: "+cDipBor+CHR(13)+CHR(10)+cDipTit
	//U_DIPCIC(cMsgCic,"DIEGO.DOMINGOS,MAXIMO.CANUTO")
	
	U_UEnvMail(_cEmail,_cAssunto+cDipBor+")",_aMsg,"",_cFrom,_cFuncSent)    
	
EndIf

TRB->(dbGoTop())

RestArea(aAreaSA1)

Return nValor
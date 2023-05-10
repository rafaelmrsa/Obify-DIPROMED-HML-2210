#INCLUDE "PROTHEUS.CH"



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³X_A1EMAI X_A1EMAIDºAutor ³Reginaldo Borgesº Data ³  03/20/13 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Validar o preenchimento do campo do e-mail da SA1.          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SigaFat SA1                                                º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/



USER FUNCTION X_A1EMAI()

LOCAL _lRet := .T.

IF ALTERA
	
	IF! '@' $ ALLTRIM(M->A1_EMAIL)
		_lRet := .F.
	ENDIF
	
	IF! '.com' $ ALLTRIM(M->A1_EMAIL)
		_lRet := .F.
	ENDIF
	
	
	IF '@dipromed' $ ALLTRIM(M->A1_EMAIL)
		_lRet := .F.
	ENDIF
	
	
	
	IF !_lRet
		
		Alert("PREENCHER O EMAIL CORRETAMENTE!")
		
	ENDIF
	
ELSE
	
	IF INCLUI
		
		IF! '@' $ ALLTRIM(M->A1_EMAIL)
			_lRet := .F.
		ENDIF
		
		IF! '.com' $ ALLTRIM(M->A1_EMAIL)
			_lRet := .F.
		ENDIF
		
		
		IF '@dipromed' $ ALLTRIM(M->A1_EMAIL)
			_lRet := .F.
		ENDIF
		
		
		
		IF !_lRet
			
			Alert("PREENCHER O EMAIL CORRETAMENTE!")
			
		ENDIF
		
	ENDIF
	
ENDIF

RETURN(_lRet) 
                   

/*
//Função para o A1_EMAILD
//X_A1EMAID ALTERADO
USER FUNCTION XA1EMAID2()

LOCAL __lRet := .T.

IF ALTERA
	
	IF! '@' $ ALLTRIM(M->A1_EMAILD)
		__lRet := .F.
	ENDIF
	
	IF! '.com' $ ALLTRIM(M->A1_EMAILD)
		__lRet := .F.
	ENDIF
	
	
	IF '@dipromed' $ ALLTRIM(M->A1_EMAILD)
		__lRet := .F.
	ENDIF
	
	
	
	IF !__lRet
		
		Alert("PREENCHER O EMAIL CORRETAMENTE!")
		
	ENDIF
	
ELSE
	
	IF INCLUI
		
		IF! '@' $ ALLTRIM(M->A1_EMAILD)
			__lRet := .F.
		ENDIF
		
		IF! '.com' $ ALLTRIM(M->A1_EMAILD)
			__lRet := .F.
		ENDIF
		
		
		IF '@dipromed' $ ALLTRIM(M->A1_EMAILD)
			__lRet := .F.
		ENDIF
		
		
		
		IF !__lRet
			
			Alert("PREENCHER O EMAIL CORRETAMENTE!")
			
		ENDIF
		
	ENDIF
	
ENDIF

RETURN(__lRet)
*/

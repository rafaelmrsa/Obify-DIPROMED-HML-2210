#INCLUDE "PROTHEUS.CH"


/*======================================================================
+ RSB - 26/08/2013 - PONTO DE ENTRADA F190ICAN()                       +
+ Descr.: Retornará falso, caso a data de emissão do cheque seja menor +
+         ou igual à data informada no parâmetro.                      +
+ Uso: FINA190                                                         +
=======================================================================*/
  

User Function F190ICAN()


Local _dDataFin := Getmv("MV_DATAFIN")
Local _lRet    := .T.

If SEF->EF_DATA <= _dDataFin
	_lRet := .F.
	
	Alert("Cheque não pode ser cancelado, data de emissão menor que a data de fechamento!")
	
EndIf



Return (_lRet)




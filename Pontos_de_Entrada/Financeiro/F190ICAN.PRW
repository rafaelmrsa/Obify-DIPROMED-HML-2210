#INCLUDE "PROTHEUS.CH"


/*======================================================================
+ RSB - 26/08/2013 - PONTO DE ENTRADA F190ICAN()                       +
+ Descr.: Retornar� falso, caso a data de emiss�o do cheque seja menor +
+         ou igual � data informada no par�metro.                      +
+ Uso: FINA190                                                         +
=======================================================================*/
  

User Function F190ICAN()


Local _dDataFin := Getmv("MV_DATAFIN")
Local _lRet    := .T.

If SEF->EF_DATA <= _dDataFin
	_lRet := .F.
	
	Alert("Cheque n�o pode ser cancelado, data de emiss�o menor que a data de fechamento!")
	
EndIf



Return (_lRet)




#include 'protheus.ch'
#include 'parmtype.ch'

/*/{Protheus.doc} SX5NOTA
Ponto de entrada para fitro de serie de Notas Fiscais de Saida
@author    fernando.bombardi
@since     29/08/2018
@version   1.69
/*/
User Function SX5NOTA()
Local _aSeries := {}
Local _lRet := .T.

IF cEmpAnt == "01"

	aADD(_aSeries,{"003","01"})
	
	_nLocSer := ascan(_aSeries,{|x| alltrim(X[1]) == ALLTRIM(SX5->X5_CHAVE)  })
	IF _nLocSer == 0 
		_lRet := .F.
	ENDIF
	
ENDIF
	
return(_lRet)
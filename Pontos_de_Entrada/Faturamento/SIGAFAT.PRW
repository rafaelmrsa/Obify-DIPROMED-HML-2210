#include "RwMake.ch"
#include "Protheus.ch"
#include "vKey.ch"     

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบPrograma  ณSIGAFAT  บAutor  ณMaximo	             บ Data ณ  28/10/15   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ P.E. na entrada do m๓dulo de faturamento para tratar a dataบฑฑ
ฑฑบ          ณ base no ๚ltimo dia do m๊s                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ ESPECIFICO DIPROMED                                        บฑฑ
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
/*/

User Function SIGAFAT()

Local _cTemp     := ""
Local _aFeriad   := {}  
Local _dAtu      := Date()
Local _dSist     := Ddatabase 
Local _cMesSis   := Month(dDatabase)                             
Local _cMesAnt   := Month(dDatabase - 1)                             
Local _cHorAtu   := Left(Time(),5)                                       
Local _cAno      := Year(dDataBase)                   
Local _lLibDt    := GetNewPar("ES_LIBDTFT",.F.)
Local _cLibFtUs  := Upper(AllTrim(GetNewPar("ES_LIBFTUS","PMENDONCA/MORNELLAS/DDOMINGOS")))

If !_lLibDt .And. cEmpAnt == '01' .And. !(Upper(U_DipUsr()) $ _cLibFtUs)// Valida็ใo da data, dia desabilitado e exce็ใo de usuแrio

	//Montagem do array com feriados
	dbSelectArea("SX5")
	dbSetOrder(1)
	dbSeek(xFilial("SX5")+"63")
	While X5_TABELA == "63"
		If SubStr(X5_DESCRI,1,1) != "*"
			If Len(Alltrim(SubStr(X5_DESCRI,1,8))) <> 8
				cTemp := SubStr(X5_DESCRI,1,5)+"/"+AllTrim(_cAno)
			Else
				cTemp := SubStr(X5_DESCRI,1,At(" ",X5_DESCRI)-1)
			EndIf
			Aadd(_aFeriad,{cTOD(AllTrim(cTemp))})
		EndIf                                                                                    
		SX5->(DbSkip())
	EndDo          
	
	If Ascan(_aFeriad,{|y| y[1] == _dSist}) <> 0;      // ษ feriado
		   .or. (AllTrim(cDow(_dSist)) = "Saturday");   // ษ Sแbado
		   .or. (AllTrim(cDow(_dSist)) = "Sunday"  )    // ษ Domingo 
	   
		Aviso("Aten็ใo","VERIFIQUE A DATA BASE DO SISTEMA. POIS A DATA DEFINIDA ษ UM FIM DE SEMANA OU UM FERIADO! NรO PODEMOS GERAR NOTA NESTA SITUAวรO! - ES_LIBDTFT / ES_LIBFTUS ",{"Ok"},1)	
		Aviso("Aten็ใo","O SISTEMA SERม FECHADO. ENTRE COM A DATA CORRETA! - ES_LIBDTFT / ES_LIBFTUS",{"Ok"},1)	
		Break
		
	EndIf	
	
	If _cMesSis <> _cMesAnt  .And. _cHorAtu <= '08:00'
	
		Aviso("Aten็ใo","VERIFIQUE A DATA BASE DO SISTEMA. AJUSTE A DATABASE PARA NรO GERAR NOTA FISCAL COM A DATA ERRADA! - ES_LIBDTFT / ES_LIBFTUS",{"Ok"},1)	
		Aviso("Aten็ใo","O SISTEMA SERม FECHADO. ENTRE COM A DATA CORRETA! - ES_LIBDTFT / ES_LIBFTUS",{"Ok"},1)	
		Break
	
	Endif
	
Endif
	
Return ""
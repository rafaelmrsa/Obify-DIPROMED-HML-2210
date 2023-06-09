#include "RwMake.ch"
#include "Protheus.ch"
#include "vKey.ch"     

/*/
�����������������������������������������������������������������������������
���Programa  �SIGAFAT  �Autor  �Maximo	             � Data �  28/10/15   ���
�������������������������������������������������������������������������͹��
���Desc.     � P.E. na entrada do m�dulo de faturamento para tratar a data���
���          � base no �ltimo dia do m�s                                  ���
�������������������������������������������������������������������������͹��
���Uso       � ESPECIFICO DIPROMED                                        ���
�����������������������������������������������������������������������������
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

If !_lLibDt .And. cEmpAnt == '01' .And. !(Upper(U_DipUsr()) $ _cLibFtUs)// Valida��o da data, dia desabilitado e exce��o de usu�rio

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
	
	If Ascan(_aFeriad,{|y| y[1] == _dSist}) <> 0;      // � feriado
		   .or. (AllTrim(cDow(_dSist)) = "Saturday");   // � S�bado
		   .or. (AllTrim(cDow(_dSist)) = "Sunday"  )    // � Domingo 
	   
		Aviso("Aten��o","VERIFIQUE A DATA BASE DO SISTEMA. POIS A DATA DEFINIDA � UM FIM DE SEMANA OU UM FERIADO! N�O PODEMOS GERAR NOTA NESTA SITUA��O! - ES_LIBDTFT / ES_LIBFTUS ",{"Ok"},1)	
		Aviso("Aten��o","O SISTEMA SER� FECHADO. ENTRE COM A DATA CORRETA! - ES_LIBDTFT / ES_LIBFTUS",{"Ok"},1)	
		Break
		
	EndIf	
	
	If _cMesSis <> _cMesAnt  .And. _cHorAtu <= '08:00'
	
		Aviso("Aten��o","VERIFIQUE A DATA BASE DO SISTEMA. AJUSTE A DATABASE PARA N�O GERAR NOTA FISCAL COM A DATA ERRADA! - ES_LIBDTFT / ES_LIBFTUS",{"Ok"},1)	
		Aviso("Aten��o","O SISTEMA SER� FECHADO. ENTRE COM A DATA CORRETA! - ES_LIBDTFT / ES_LIBFTUS",{"Ok"},1)	
		Break
	
	Endif
	
Endif
	
Return ""
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDIG020        บAutor  ณMaximo Canuto      บ Data ณ  08/06/10บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ BUSCA NA EMPRESA ORIGEM DA TRANSFERสNCIA O CUSTO DO PRODUTOบฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ NA ROTINA MATA241 - DIPA046                                บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
#INCLUDE "TOPCONN.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"


User Function DIPG020()
Local nCusto   := 0         
Local lTranEmp := U_MTA241DOC("DIPG020")
Local _xAlias  := GetArea()
Local nPosCod  := aScan(aHeader, { |x| Alltrim(x[2]) == "D3_COD"})
Local nPosQtd  := aScan(aHeader, { |x| Alltrim(x[2]) == "D3_QUANT"})  

Begin Sequence
    //-------------------------------------------------------------------------------------------------
    // MCVN 31/08/2010 - Se programa MATA241 estiver rodando de forma automatica,
    // ignora as criticas. Pq a rotina automatica ja vai contemplar todas as 
    // situacoes necessarias.
    //-------------------------------------------------------------------------------------------------
	If Type("l241Auto") <> "U" .And. l241Auto
		Break
	EndIf  
	If "MATA241"$FunName() .And. Upper(U_DipUsr()) $ 'MCANUTO/EELIAS/DDOMINGOS/VQUEIROZ/VEGON/RBORGES' .And. ;
		lTranEmp .And. cEmpAnt+cFilAnt <> '0401' .And. CTM = '497'	                                                                                            
	
		QRY1 := "SELECT B1_CUSDIP"
		
		If cEmpAnt='04'        
			QRY1 += " FROM SB1010 "
			QRY1 += " WHERE B1_FILIAL = '04'" 
			QRY1 += " AND "  + ("SB1010")+".D_E_L_E_T_ = ' '"   
		Else                       
			QRY1 += " FROM SB1040 "           
			QRY1 += " WHERE B1_FILIAL = '04'"                   
			QRY1 += " AND "  + ("SB1040")+".D_E_L_E_T_ = ' '"   
		Endif    
	
		QRY1 += " AND B1_COD = '" +aCols[n,nPosCod] + "'"

		DbCommitAll()
		TcQuery QRY1 NEW ALIAS "QRY1"         // ABRE UMA WORKAREA COM O RESULTADO DA QUERY
			
		DbSelectArea("QRY1")
		QRY1->(dbGotop())         
		nCusto := QRY1->B1_CUSDIP*aCols[n,nPosQtd]
		DbCloseArea("QRY1")				
	Endif        
End Sequence
RestArea(_xAlias)
Return(nCusto)  
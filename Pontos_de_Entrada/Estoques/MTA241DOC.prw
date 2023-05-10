/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณMTA241DOC    บAutor  ณMaximo Canuto      บ Data ณ  04/26/10บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Durante a fun็ใo de inclusใo de movimenta็ใo interna       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Utilizado para verificar se edita o documento              บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
#INCLUDE "TOPCONN.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
Static lTranEmp 


User Function MTA241DOC(cOpcao)

Local lRet := .F.         
Default cOpcao := 'MATA241'				

Begin Sequence
    //-------------------------------------------------------------------------------------------------
    // MCVN 31/08/2010 - Se programa MATA241 estiver rodando de forma automatica,
    // ignora as criticas. Pq a rotina automatica ja vai contemplar todas as 
    // situacoes necessarias - DIPA046.
    //-------------------------------------------------------------------------------------------------
	If Type("l241Auto") <> "U" .And. l241Auto
		Break
	EndIf  

	If cOpcao == 'MATA241'	
		If Upper(U_DipUsr()) $ 'MCANUTO/EELIAS/DDOMINGOS/VQUEIROZ/VEGON/RBORGES' .And. cEmpAnt+cFilAnt <> '0401'
			If MsgBox(Upper(U_DipUsr())+", Voc๊ vai incluir uma devolu็ใo referente a uma transfer๊ncia entre Dipromed e HQ com custo?","Atencao","YESNO")  
				lTranEmp := .T.
			Else
				lTranEmp := .F.		
			Endif             
		Else
			lTranEmp := .F.				
		Endif
	ElseIf lTranEmp = Nil
		lTranEmp := .F.					
	ElseIf  cOpcao == 'MT241TOK'	 
		lTranEmp := .F.
	Else
		lRet := lTranEmp
	Endif
End Sequence

Return(lRet)  


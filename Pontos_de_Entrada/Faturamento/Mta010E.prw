/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณMTA010E   บAutor  ณMicrosiga           บ Data ณ  01/30/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ PE chamado na exclusao de Produto, para gerar kardex da    บฑฑ
ฑฑบ          ณ Exclusao do Produto                                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ DIPROMED                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
User Function Mta010E()
U_DIPPROC(ProcName(0),U_DipUsr()) //MCVN - 22/01/2009
U_GravaZG("SB1")

//-- Verifica replica็ใo do cadastro
/*
If (Type("l010Auto")=="U".Or.!l010Auto) 
	If cEmpAnt+cFilAnt == "0401" 
	  	U_CpySB1("01","01",.T.) //-- Copia para Dipromed/MTZ
	  	U_CpySB1("01","04",.T.) //-- Copia para Dipromed/CD
	ElseIf cEmpAnt+cFilAnt == "0101" 
	  	U_CpySB1("01","04",.T.) //-- Copia para Dipromed/CD
	ElseIf cEmpAnt+cFilAnt == "0104" 
	  	U_CpySB1("01","01",.T.) //-- Copia para Dipromed/MTZ
	EndIf
EndIf
*/
Return .T.
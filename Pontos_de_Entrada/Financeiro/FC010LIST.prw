#INCLUDE "PROTHEUS.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFC010LIST บAutor  ณMicrosiga           บ Data ณ  06/26/13   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function FC010LIST()
Local aArea := GetArea()
Local aCols := PARAMIXB
Local nPos  := 0
Local lExibe:= U_DipUsr()$GetNewPar("ES_DIPUSMS","")
Local _dDataSld  := ddatabase
Private _nSaldoCli := 0

nPos := aScan(aCols, {|x| "Maior Saldo" $ x[1]} )     

If nPos > 0
	If lExibe
		aCols[nPos,5] := "Dt.Maior Saldo"
		aCols[nPos,6] := SPACE(07)+DtoC(SA1->A1_XDMSAL)
	Else
		ADEL(aCols,nPos)
		ASIZE(aCols,Len(aCols)-1)                          
	EndIf
EndIf	         
	
Aadd(aCols,{"Dt.Maior Comp.",;		//Tํtulo - coluna 1
			SPACE(07)+DtoC(DipDtMCo(SA1->A1_COD,SA1->A1_LOJA)),; //Conte๚do 1
            " ",;                  	//Conte๚do 2
			" ",;                   //Tํtulo - coluna 2
			" ",;                   //Conte๚do 1
			" "})                   //Conte๚do 2

Aadd(aCols,{"Maior Saldo Comercial",;		             // Tํtulo - coluna 1
			Transform(SA1->A1_XSLDCOM, "@E 999,999,999.99"),; // coluna 1 - Conte๚do 1
            Transform(SA1->A1_XSLDCOM, "@E 999,999,999.99"),; // coluna 1 - Conte๚do 2
            " ",;
			"Data Saldo Comercial",;                     // Tํtulo - coluna 2
			SPACE(07)+DtoC(SA1->A1_XDTSLDM),;                 // coluna 1 - conte๚do 2
			" "})    			
	
RestArea(aArea)

Return aCols
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFC010LIST บAutor  ณMicrosiga           บ Data ณ  07/19/13   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function DipDtMCo(cCliente,cLoja)                                           
Local dDtMComp 	 := StoD("")
Local cSQL 		 := ""         
DEFAULT cCliente := ""
DEFAULT cLoja 	 := ""

cSQL := " SELECT TOP 1 "
cSQL +=	" 	F2_EMISSAO "
cSQL += " 	FROM "
cSQL += 		RetSQlName("SF2")
cSQL += "		WHERE "
//cSQL += "			F2_FILIAL  = '"+xFilial("SF2")+"' AND "
cSQL += "			F2_CLIENTE = '"+cCliente+"' AND "
cSQL += "			F2_LOJA    = '"+cLoja+"' AND " 
cSQL += "			F2_DUPL   <> ' ' AND " 
cSQL += " 			D_E_L_E_T_ = ' ' "
cSQL += " ORDER BY F2_VALBRUT DESC "
                                                                                  
cSQL := ChangeQuery(cSQL)
dbUseArea(.T., "TOPCONN", TCGenQry(,,cSQL), "QRYSF2", .F., .T.)

TCSETFIELD("QRYSF2","F2_EMISSAO","D",8,0)

If !QRYSF2->(Eof())
	dDtMComp := QRYSF2->F2_EMISSAO	
EndIf
QRYSF2->(dbCloseArea())

Return dDtMComp

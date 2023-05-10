/*
+=================================================================+
|Função: LJ901APV() | Autor: Reginaldo Borges  | Data: 11/07/2018 |
+-----------------------------------------------------------------+
|Descrição - Este Ponto de Entrada é executado na rotina LOJA901A,| 
|            para informação dos dados adicionais a serem         | 
|            cadastrados na rotina automática de Pedido de Venda  |
|            (MATA410), cabecalho do pedido.                      |
+-----------------------------------------------------------------+
|Uso: Dipromed - eCommerce                                        |
+=================================================================+
*/

#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'PARMTYPE.CH'

User Function LJ901APV()

Local aCabPv  := {}  
Local aRet    := {}    //array de retorno 
Local aArea   := GetArea()
Local cDestFre:= "" //U_Mt410Frete('GATILHO',"","",.T.)
Local _nPos   := 0

If        ValType(PARAMIXB)    == "A" ; //PARAMIXB É UM ARRAY ?
	.AND. Len(PARAMIXB)        >= 4   ; //TEM 4 POSIÇÕES ?
    .AND. ValType(PARAMIXB[3]) == "A" ; //ARRAY ?
    .AND. ValType(PARAMIXB[4]) == "A"   //ARRAY ?
    
    //pegando os valores passados da MATA410
    oAPed     := PARAMIXB[1]  
    //oRetExtra := PARAMIXB[2]
    aCabPv    := PARAMIXB[3]
    
    cDestFre:= U_Mt410Frete('GATILHO',"","",.T.)
    
    /*
    _nPos := AScan(aCabPv, {|x| AllTrim(Upper(x[1])) == "C5_TRANSP"})
    If _nPos > 0
    	aCabPV[_nPos,2]:= "000235"
    EndIf
    
    _nPos := AScan(aCabPv, {|x| AllTrim(Upper(x[1])) == "C5_TPFRETE"})
    If _nPos > 0
    	aCabPV[_nPos,2]:= "C"
    EndIf
    */
         
    aAdd(aRet, {"C5_TIPODIP",'1'                       , Nil}) // Ped/Orc/Prog
	aAdd(aRet, {"C5_TMK    ",'1'                       , Nil}) // Marketing
	aAdd(aRet, {"C5_OPERADO",'000313'                  , Nil}) // Cod Operador > Inic. Padrão: U_DIPA005()
	aAdd(aRet, {"C5_QUEMCON",'eCOMMERCE'               , Nil}) // Confirmou?
	//aAdd(aRet, {"C5_TRANSP ",'000235'                  , Nil}) // Transp.
	//aAdd(aRet, {"C5_TPFRETE",'C'                       , Nil}) // Tipo Frete
	aAdd(aRet, {"C5_DESTFRE",cDestFre			       , Nil}) // Dest. Frete
	
	/*
	aAdd(aRet, {"C5_ENDENT ",Upper(oAPed:_RECEIPT_BILLING:_STREET:text)+", "+Upper(oAPed:_RECEIPT_BILLING:_STREET_NUMBER:text), Nil}) // End. Entr.
	aAdd(aRet, {"C5_BAIRROE",Upper(oAPed:_RECEIPT_BILLING:_DISTRICT:text) , Nil}) // Bairro Entr.
	aAdd(aRet, {"C5_MUNE   ",Upper(oAPed:_RECEIPT_BILLING:_CITY:text)     , Nil}) // Munic. Entr.
	aAdd(aRet, {"C5_ESTE   ",Upper(oAPed:_RECEIPT_BILLING:_STATE:text)    , Nil}) // Estado Entr.
	aAdd(aRet, {"C5_CEPE   ",Upper(oAPed:_RECEIPT_BILLING:_ZIP_CODE:text) , Nil}) // CEP Entr.
	aAdd(aRet, {"C5_XFORPAG",'3'	                   , Nil}) // Forma Pagto.
	*/
	
	aAdd(aRet, {"C5_ENDENT ",Upper(oAPed:_receipt_shopper:_ship_to_address1:text)+", "+Upper(oAPed:_receipt_shopper:_ship_to_street_number:text), Nil}) // End. Entr.
	aAdd(aRet, {"C5_BAIRROE",Upper(oAPed:_receipt_shopper:_ship_to_district:text)  , Nil}) // Bairro Entr.
	aAdd(aRet, {"C5_MUNE   ",Upper(oAPed:_receipt_shopper:_ship_to_address2:text)  , Nil}) // Munic. Entr.
	aAdd(aRet, {"C5_ESTE   ",Upper(oAPed:_receipt_shopper:_ship_to_address3:text)  , Nil}) // Estado Entr.
	aAdd(aRet, {"C5_CEPE   ",Upper(oAPed:_receipt_shopper:_ship_to_address4:text)  , Nil}) // CEP Entr.
	
	aAdd(aRet, {"C5_XFORPAG",'3'	                   , Nil}) // Forma Pagto.

	    
EndIf

RestArea(aArea)

Return aRet
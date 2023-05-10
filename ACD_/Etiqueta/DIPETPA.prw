#include "protheus.ch"
#include "apwizard.ch"  

/*/
{Protheus.doc} DIPETPA
Impressão de etiqueta PA, referênte à OP posicionada.
@type  Function
@author Felipe Almeida
@since 20/12/2019
@version 1.0
/*/

User Function DIPETPA()

    Local cPerg := "XDIPETPA"

    Pergunte(cPerg, .T.)

    Processa({|| IMPETQPA()}, "Imprimindo etiquetas...")

Return 

Static Function IMPETQPA()

	Local cCodBnf
	Local cQuery
	Local dVldAno
	Local cVerLot := SC2->C2_XLOTECT
	Local dFabMes := Mes(SC2->C2_EMISSAO)
	Local dFabAno := Year(SC2->C2_EMISSAO)
	Local cEster  := IIF(MV_PAR01 == 1, "Esterilizado em Óxido de Etileno", "Esterilizado por Raio Gama")
    Local nCont   := 1
    Local nQntImp := MV_PAR02

    DbSelectArea('SB1')
    DbSetOrder(1)
    MsSeek(xFilial('SB1')+SC2->C2_PRODUTO)

    DbSelectArea('SB8')
    DbSetOrder(1)
    MsSeek(xFilial('SB8')+SC2->C2_PRODUTO)          
    
    If Empty(SB1->B1_DESC)
        MsgAlert("A descrição auxiliar para o produto "+Alltrim(SC2->C2_PRODUTO)+" nao foi informada. Impressao cancelada do item!")
        Return
    EndIf

	dVldAno := dFabAno + GetMv('ES_VLDANOS')

	cQuery	:= " SELECT G1_COMP, B1_TIPO
	cQuery	+= " FROM " + RetSqlName("SG1") + " SG1 "
	cQuery 	+= " LEFT JOIN " + RetSqlName("SB1") + " SB1 ON B1_COD = G1_COMP AND B1_TIPO = 'BN' AND SB1.D_E_L_E_T_ = '' "
	cQuery  += " WHERE G1_COD = '" + SC2->C2_PRODUTO + "' AND SG1.D_E_L_E_T_ = '' "

	DbUseArea(.T., "TOPCONN", TCGENQRY(,,cQuery),"QRY", .F., .F.)
	
	DbSelectArea("QRY")
	DbGoTop()

	If !Empty(QRY->G1_COMP) .AND. QRY->B1_TIPO $ "BN"
		cCodBnf := QRY->G1_COMP
	EndIf

    For nCont := 1 to nQntImp

		DbSelectArea("CB5")  	
	    CB5SetImp("000001",.T.)
		MsCBChkStatus(.F.)
		MsCBBegin(1,6,115)
		MSCBWrite(' CT~~CD,~CC^~CT~ ')
		MSCBWrite(' ^XA~TA000~JSN^LT0^MNW^MTT^PON^PMN^LH0,0^JMA^PR4,4~SD22^JUS^LRN^CI0^XZ ')
		MSCBWrite(' ^XA ')
		MSCBWrite(' ^MMT ')
		MSCBWrite(' ^PW767 ')
		MSCBWrite(' ^LL0583 ')
		MSCBWrite(' ^LS0 ')
        MSCBWrite(' ^FT30,377^A0N,28,28^FH\^FDRegistro ANVISA: '+ Alltrim(SB1->B1_REG_ANV) +'^FS ')
		MSCBWrite(' ^FT30,411^A0N,28,28^FH\^FDFabricado: '+ Alltrim(dFabMes) + '/' + Alltrim(cValToChar(dFabAno)) +'^FS ')
		MSCBWrite(' ^FT30,445^A0N,28,28^FH\^FDValidade: '+ Alltrim(dFabMes) + '/' + Alltrim(cValToChar(dVldAno)) +'^FS ')
		MSCBWrite(' ^FT30,479^A0N,28,28^FH\^FDLote: '+ Alltrim(cVerLot) +'^FS ')
		MSCBWrite(' ^FT32,180^A0N,31,19^FH\^FDN\C6o utilizar se a embalagem estiver aberta, danificada ou molhada, conservar em local seco, ^FS ')
		MSCBWrite(' ^FT32,219^A0N,31,19^FH\^FDao abrigo da luz e \85 temperatura ambiente. EST\90RIL. ' + cEster + '^FS ')
		MSCBWrite(' ^FT32,259^A0N,31,19^FH\^FDFabricado por: HEALTH QUALITY IND. E COM. LTDA^FS ')
		MSCBWrite(' ^FT32,299^A0N,27,16^FH\^FDAv. Dr. Antenor Soares Gandra, 321 - 13.240-000 - Jarinu-SP - CNPJ: 05.150.878/0001-27^FS ')
		MSCBWrite(' ^FT32,339^A0N,31,19^FH\^FDResp. T\82c.: ' + Alltrim(GetMv('ES_RESPCRF')) + '^FS ')
		MSCBWrite(' ^FT30,85^A0N,47,24^FH\^FD'+ Alltrim(SB1->B1_COD) +'-'+ Alltrim(SB1->B1_DESC) +'^FS ')
		MSCBWrite(' ^FT99,513^A0N,27,28^FH\^FD'+ Alltrim(cCodBnf) +'^FS ')
		MSCBWrite(' ^FT266,143^A0N,28,31^FH\^FDProibido Reprocessar^FS ')
		MSCBWrite(' ^BY3,2,91^FT428,497^BEN,,Y,N ')
		MSCBWrite(' ^FD'+ SB1->B1_COSGETIN +'^FS ')
		MSCBWrite(' ^FO30,100^GB745,0,8^FS ')
		MSCBWrite(' ^PQ1,0,1,Y^XZ ')
		MSCBEnd()

    Next nCont

    SB1->(DbCloseArea())
    SB8->(DbCloseArea())
	QRY->(DbCloseArea())

Return
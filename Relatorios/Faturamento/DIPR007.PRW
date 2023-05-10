#include "rwmake.ch"
#include "topconn.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบPrograma  ณ DIPR007   บAutor ณ  Rodrigo Franco   บData ณ  05/02/2002   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Tela de Consulta de Faturamento                            บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function DIPR007(_cFUN)
Local cArqTRB     := ''   
Local cUserAut    := GetMV("MV_URELFAT") // MCVN - 04/05/09    
Private aCols     := {}
Private aHeader   := {}
Private aCond     := {}
Private aParcCalc := {}
U_DIPPROC(ProcName(0),U_DipUsr()) // JBS 05/10/2005 - Gravando o nome do Programa no SZU

// MCVN - 04/05/09    
If !(Upper(U_DipUsr()) $ cUserAut)
	Alert(Upper(U_DipUsr())+", voc๊ nใo tem autoriza็ใo para utilizar esta rotina. Qualquer d๚vida falar com Eriberto!","Aten็ใo")	
	Return()
EndIF

DbSelectArea("SZ7")
DbGoTop()
While !Eof()
	RecLock("SZ7",.F.)
	DbDelete()
	MsUnLock()
	DbSkip()
End
IF _cFUN <> "FATPVEN"
	Private _dDatade  := ctod("  /  /  ")
	Private _dDataate := ddatabase
	@ 069,002 To 230,200 Dialog oDlg Title OemToAnsi("Faturamento por Fornecedor")
	@ 005,002 SAY "ESCOLHA O PERIODO: "
	@ 025,012 SAY "DATA DE: "
	@ 025,045 GET _dDatade SIZE 35,50
	@ 040,012 SAY "DATA ATE: "
	@ 040,045 GET _dDataate SIZE 35,50
	@ 065,065 BMPBUTTON TYPE 1 ACTION Close(oDlg)
	Activate Dialog oDlg Centered
ENDIF
aRotina := { { "Pesquisa"  ,"AxPesqui", 0, 1 }, ;
{ "Por Vendedor","U_FATPVEN()", 0, 2 }}//,;
DbSelectArea("SA2")
DbGoTop()
While !Eof()
	_cCodFor := SA2->A2_COD
	xNomFor  := SA2->A2_NREDUZ
	xTotFat  := 0
	xMargem  := 0
	xVez     := 0
	cQuery1 :=           " SELECT * FROM"
	cQuery1 := cQuery1 + " SD2010 "
	cQuery1 := cQuery1 + "  WHERE "
	cQuery1 := cQuery1 + "D_E_L_E_T_ <> '*'" + " AND "
	cQuery1 := cQuery1 + "D2_FORNEC = '"+_cCodFor+"'  AND "
	cQuery1 := cQuery1 + "D2_EMISSAO >= '"+DTOS(_dDatade)+"' AND "
	cQuery1 := cQuery1 + "D2_EMISSAO <= '"+DTOS(_dDataate)+"' "
	cQuery1 := cQuery1 + "ORDER BY D2_FORNEC+D2_EMISSAO"
	#xcommand TCQUERY <sql_expr>                             ;
	[ALIAS <a>]                                           ;
	[<new: NEW>]                                          ;
	[SERVER <(server)>]                                   ;
	[ENVIRONMENT <(environment)>]                         ;
	;
	=> dbUseArea(                                       ;
	<.new.>,                                            ;
	"TOPCONN",                                          ;
	TCGENQRY(<(server)>,<(environment)>,<sql_expr>),    ;
	<(a)>, .F., .T.)

	//ณ Processa Query SQL                                           ณ
	TcQuery cQuery1 NEW ALIAS "QUERY1"         // Abre uma workarea com o resultado da query
	DbSelectArea("QUERY1")
	DBGOTOP()
	While !Eof()
		xVez :=	xVez + 1
		xTotFat := xTotFat + QUERY1->D2_TOTAL
		DbSelectArea("SC6")
		DbSetOrder(4)
		IF DbSeek(xFilial("SC6")+QUERY1->D2_DOC+QUERY1->D2_SERIE)
			xMargem := xMargem + C6_MARGATU
		ENDIF
		DbSelectArea("QUERY1")
		DbSkip()
	End
	xMargem := xMargem / xVez
	IF xTotFat > 0
		DbSelectArea("SZ7")
		RECLOCK("SZ7",.T.)
		SZ7->Z7_FILIAL := "01"
		SZ7->Z7_FORNEC := _cCodFor
		SZ7->Z7_NOMFOR := xNomFor
		SZ7->Z7_VALOR  := xTotFat
		SZ7->Z7_MARGEM := xMargem
		MSUNLOCK()
	ENDIF 
	DbSelectArea("QUERY1")
	DBCLOSEAREA("QUERY1")
	DbSelectArea("SA2")
	DbSkip()
End
dbSelectArea("SZ7")
cArqTRB := CriaTrab(Nil,.f.) // JBS 12/12/2005
Indregua("SZ7",cArqTRB,"Z7_FORNEC",,,"Selecionando Vendas") // JBS 12/12/2005
dbGoTop()
mBrowse( 7, 4,20,74,"SZ7",,,,,,) 
SZ7->(E_EraseArq(cArqTRB)) // JBS 12/12/2005
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบPrograma  ณ FATPVEN   บAutor ณ  Rodrigo Franco   บData ณ  05/02/2002   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Tela de Consulta de Faturamento                            บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function FATPVEN()

Private aCols     := {}
Private aHeader   := {}
Private aCond     := {}
Private aParcCalc := {}
DbSelectArea("SZ8")
DbGoTop()
While !Eof()
	RecLock("SZ8",.F.)
	DbDelete()
	MsUnLock()
	DbSkip()
End
aRotina := { { "Pesquisa"  ,"AxPesqui", 0, 1 } , ;
{ "Por Fornecedor",'U_DIPR007("FATPVEN")', 0, 2 }}//,;
DbSelectArea("SA3")
DbGoTop()
While !Eof()
	xNomVen := SA3->A3_NREDUZ
	_cVend  := SA3->A3_COD
	xTotFat := 0
	xMargem := 0
	xVez := 0 
	cQuery2 :=           " SELECT * FROM"
	cQuery2 := cQuery2 + " SF2010 "
	cQuery2 := cQuery2 + "  WHERE "
	cQuery2 := cQuery2 + "D_E_L_E_T_ <> '*'" + " AND "
	cQuery2 := cQuery2 + "F2_VEND1 = '"+_cVend+"'  AND "
	cQuery2 := cQuery2 + "F2_EMISSAO >= '"+DTOS(_dDatade)+"' AND "
	cQuery2 := cQuery2 + "F2_EMISSAO <= '"+DTOS(_dDataate)+"' "
	cQuery2 := cQuery2 + "ORDER BY F2_VEND1+F2_EMISSAO"
	#xcommand TCQUERY <sql_expr>                             ;
	[ALIAS <a>]                                           ;
	[<new: NEW>]                                          ;
	[SERVER <(server)>]                                   ;
	[ENVIRONMENT <(environment)>]                         ;
	;
	=> dbUseArea(                                       ;
	<.new.>,                                            ;
	"TOPCONN",                                          ;
	TCGENQRY(<(server)>,<(environment)>,<sql_expr>),    ;
	<(a)>, .F., .T.)

	//ณ Processa Query SQL                                           ณ
	TcQuery cQuery2 NEW ALIAS "QUERY2"         // Abre uma workarea com o resultado da query
	DbSelectArea("QUERY2")
	While !Eof() 
		xVez :=	xVez + 1
		xTotFat := xTotFat + QUERY2->F2_VALMERC
		DbSelectArea("SC6")
		DbSetOrder(4)
		IF DbSeek(xFilial("SC6")+QUERY2->F2_DOC+QUERY2->F2_SERIE)
			xMargem := xMargem + C6_MARGATU
		ENDIF
		DbSelectArea("QUERY2")
		DbSkip()
	End
	xMargem := xMargem / xVez
	IF xTotFat > 0
		DbSelectArea("SZ8")
		RECLOCK("SZ8",.T.)
		SZ8->Z8_FILIAL := "01"
		SZ8->Z8_VEND   := _cVend
		SZ8->Z8_NOMVEN := xNomVen
		SZ8->Z8_VALOR  := xTotFat
		SZ8->Z8_MARGEM := xMargem
		MSUNLOCK()
	ENDIF 
	DbSelectArea("QUERY2")
	DBCLOSEAREA("QUERY2")
	DbSelectArea("SA3")
	DbSkip()
End
dbSelectArea("SZ8")    
cArqTRB := CriaTrab(Nil,.f.) // JBS 12/12/2005
Indregua("SZ8",cArqTRB,"Z8_VEND",,,"Selecionando Vendas") // JBS 12/12/2005
dbGoTop()
mBrowse( 7, 4,20,74,"SZ8",,,,,,)
SZ7->(E_EraseArq(cArqTRB)) // JBS 12/12/2005
Return
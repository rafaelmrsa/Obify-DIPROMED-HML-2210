#INCLUDE "RWMAKE.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "FILEIO.CH"

#DEFINE ENTER CHR(13)+CHR(10)
/*====================================================================================\
|Programa  | DIPR083()  | Autor  | Reginaldo Borges     | Data | 17/08/2015           |
|=====================================================================================|
|Descrição | Gera um relatorio dos atendimentos efetuados pelo SAC.                   |
|          | Relatório será gerado conforme os parâmetros informados pelo Usuário.    |
|          |                                                                          |
|=====================================================================================|
|Uso       | Especifico - Serviço de Atendimento ao Cliente                           |
|=====================================================================================|
|Histórico | 																		  |
\====================================================================================*/
*/

User Function DIPR083()

Local titulo      := OemTOAnsi("Relatorio dos atendimetnos efetuados pelo SAC",72)
Local cDesc1      := (OemToAnsi("Este programa tem como objetivo emitir um relatorio",72))
Local cDesc2      := (OemToAnsi("dos atendimentos registrados pelo SAC.",72))
Local cDesc3      := (OemToAnsi("Conforme parametros definidos.",72))
Private aReturn   := {"Bco A4", 1,"Administracao", 1, 2, 1,"",1}
Private li        := 67
Private tamanho   := "G"
Private limite    := 220
Private nomeprog  := "DIPR083"
PRIVATE cPerg  	  := "DIPR083"
Private nLastKey  := 0
Private lEnd      := .F.
Private wnrel     := "DIPR083"
Private cString   := "SUC"
Private m_pag     := 1
Private cWorkFlow := ""
Private PG := 0

cPerg  	:= U_FPADR( "DIPR083","SX1","SX1->X1_GRUPO"," " )
U_DIPPROC(ProcName(0),U_DipUsr())

AjustaSX1(cPerg)           // Verifica perguntas. Se nao existe INCLUI.

If !Pergunte(cPerg,.T.)    // Solicita parametros
	Return
EndIf

wnrel := SetPrint(cString,wnrel,cPerg,Titulo,cDesc1,cDesc2,cDesc3,.f.,,.f.,tamanho,,.f.,,,,,)

If nLastKey == 27
	Return
Endif

SetDefault(aReturn,cString)

RptStatus({|lEnd| RodaRel()},Titulo)

Set device to Screen

/*==========================================================================\
| Se em disco, desvia para Spool                                            |
\==========================================================================*/
If aReturn[5] == 1    // Se Saida para disco, ativa SPOOL
	Set Printer TO
	Commit
	ourspool(wnrel)
Endif

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³RODAREL() ºAutor  ³Microsiga           º Data ³  17/08/15   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function RodaRel()

Local nHandle	:= ""
Local cCodVen	:= ""
Local nTotImp	:= 10
Local cSQL 	    := ""
Local nI        := 0
Local _dDtSac   := CTOD("99/99/99")
Local _cCodSac  := ""
Local _cCliSac  := ""
Local _cNomCli  := ""
Local _cConCli  := ""
Local _cConTel  := ""
Local _cConMai  := ""
Local nMemCount := ""
Local cLinha    := 0   
Local aUC_Status:= TkSx3Box("UC_STATUS")
Local _cMemo    := {}
Private _cTitulo:= "Serviço de Atendimento ao Cliente"
Private _cDesc1 := ""
Private _cDesc2 := ""


cSQL := " SELECT "
cSQL += " 	DISTINCT(SUD.UD_PRODUTO),SUC.UC_CODIGO, SUC.UC_DATA, SUC.UC_CLIENTE, SA1.A1_NOME, SU5.U5_CONTAT,SU5.U5_DDD,SU5.U5_FCOM1,"
cSQL += " 	SU5.U5_EMAIL, SUD.UD_XNFORI,SUD.UD_XQUANT,SUD.UD_XLOTECL, SUD.UD_CODIGO,SUD.UD_ASSUNTO,SUD.UD_OCORREN, SUD.UD_XRNOME,SUC.UC_CODOBS "
cSQL += " 	FROM "+RetSQLName("SUC")+" SUC, "+RetSqlName('SA1')+" SA1, "
cSQL += " 		 "+RetSQLName("SU5")+" SU5, "+RetSqlName('SUD')+" SUD "
cSQL += " 		WHERE "
cSQL += " 			SUC.UC_FILIAL  = '"+xFilial("SUC")+"' "
cSQL += " 		AND	SUD.UD_FILIAL  = '"+xFilial("SUD")+"' "
cSQL += " 		AND	SUC.UC_CODIGO BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"'  "
cSQL += "		AND SA1.A1_COD     = SUC.UC_CLIENTE          "
cSQL += "		AND SU5.U5_CODCONT = SUC.UC_CODCONT          "
cSQL += "		AND SUD.UD_CODIGO  = SUC.UC_CODIGO           "
cSQL += "		AND SUC.D_E_L_E_T_ = ''                      "
cSQL += "		AND SUD.D_E_L_E_T_ = ''                      "
cSQL += "		AND SA1.D_E_L_E_T_ = ''                      "
cSQL += "       AND SU5.D_E_L_E_T_ = ''                      "
cSQL += " ORDER BY SUC.UC_CODIGO     		                 "

cSQL := ChangeQuery(cSQL)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),"QRYSUC",.T.,.F.)

DbSelectArea("QRYSUC")
DbGoTop()

_cCodSac  := QRYSUC->UC_CODIGO

While QRYSUC->(!Eof())
	
	If lAbortPrint
		@ li+1,00 PSAY "*** CANCELADO PELO OPERADOR ***"
		Exit
	Endif
	
	SUC->(dbSeek(xFilial("SUC")+QRYSUC->UC_CODIGO))
	
	_dDtSac   := STOD(QRYSUC->UC_DATA)
	_cCliSac  := QRYSUC->UC_CLIENTE
	_cNomCli  := SubStr(QRYSUC->A1_NOME,1,50)
	_cConCli  := SubStr(QRYSUC->U5_CONTAT,1,30)
	_cConTel  := AllTrim(QRYSUC->U5_DDD)+" "+AllTrim(QRYSUC->U5_FCOM1)
	_cConMai  := SubStr(QRYSUC->U5_EMAIL,1,50)
	_cMemo    := TkMemo(SUC->UC_CODOBS, 195)
	
	If li > 56 .Or. _cCodSac <> QRYSUC->UC_CODIGO
		
		_cDesc1 := "NUM.SAC: "+QRYSUC->UC_CODIGO+" | EMISSAO: "+DTOC(_dDtSac)+" | CLIENTE: "+_cCliSac+" | NOME:"+_cNomCli+"                                                                                STATUS ATUAL: "+SubStr(aUC_Status[Val(SUC->UC_STATUS)],3,18)+" "
		_cDesc2 := "CONTATO: "+_cConCli+"   FONE: "+_cConTel+"            E-MAIL: "+_cConMai+"                              "
		li := Cabec(_cTitulo,_cDesc1,_cDesc2,nomeprog,tamanho)+1
		@ li,000 PSAY Replicate("-",limite)
		li++                                   
		@ li,000 PSay "NOTA FISCAL   | PRODUTO | DESCRICAO                                                    | QUANT.       | LOTE       | PEDIDO   | CAUSADOR            | DEPARTAMENTO             | OCORRENCIA"
		li++
		@ li,000 PSAY Replicate("-",limite)
		li++
		
	EndIf
	
	@ li,000 PSay QRYSUC->UD_XNFORI
	@ li,016 PSay QRYSUC->UD_PRODUTO
	@ li,027 PSay POSICIONE("SB1",1,xFilial("SB1")+QRYSUC->UD_PRODUTO,"B1_DESC")	
	@ li,090 PSay QRYSUC->UD_XQUANT
	@ li,105 PSay QRYSUC->UD_XLOTECL
	@ li,118 PSay POSICIONE("SD2",3,xFilial("SD2")+QRYSUC->UD_XNFORI,"D2_PEDIDO")
	@ li,129 PSay QRYSUC->UD_XRNOME
	@ li,151 PSay POSICIONE("SX5",1,xFilial("SX5")+"T1"+QRYSUC->UD_ASSUNTO,"X5DESCRI()")
	@ li,178 PSay POSICIONE("SU9",1,xFilial("SU9")+QRYSUC->UD_ASSUNTO,"U9_DESC")
	li++
	
	_cCodSac  := QRYSUC->UC_CODIGO
	
	QRYSUC->(dbSkip())
	
	If  _cCodSac <> QRYSUC->UC_CODIGO
		
		@ li,000 PSAY Replicate("-",limite)
		li++
		For nI := 1 To Len(_cMemo)
//			If nI > 66
			If li > 66
				_cDesc1 := "NUM.SAC: "+_cCodSac+" | EMISSAO: "+DTOC(_dDtSac)+" | CLIENTE: "+_cCliSac+" | NOME:"+_cNomCli+        "                                                      "
				_cDesc2 := "CONTATO: "+_cConCli+"   FONE: "+_cConTel+"            E-MAIL: "+_cConMai+"                           "
				li := Cabec(_cTitulo,_cDesc1,_cDesc2,nomeprog,tamanho)+1
				@ li,000 PSAY "OBSERVAÇÃO:"
			EndIf
			If nI == 1
			@ li,000 PSAY "OBSERVAÇÃO:"
			EndIf
			@ li,015 PSAY _cMemo[nI]
			li++
		Next nI
	EndIf
EndDo


QRYSUC->(dbCloseArea())

Return

/*==========================================================================\
|Programa  |DIPR083| Autor | Reginaldo Borges          | Data ³ 17/08/15    |
|===========================================================================|
|Desc.     | Inclui as perguntas caso nao existam                           |
|===========================================================================|
|Sintaxe   | DIPR083                                                      |
|===========================================================================|
|Uso       | Especifico DIPROMED                                            |
|===========================================================================|
|Histórico | DD/MM/AA - Descrição da alteração                              |
\==========================================================================*/

Static Function AjustaSX1(cPerg)
_sAlias := Alias()
dbSelectArea("SX1")
dbSetOrder(1)                                                                                   

aRegs:={}

//------------ Grupo/Ordem/Pergunta/PERGING/PERGESP/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05/F3

AADD(aRegs,{cPerg,"01","Num.SAC de  ?","","","mv_ch1","C",6,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","XSUC"})
AADD(aRegs,{cPerg,"02","Num.SAC ate ?","","","mv_ch2","C",6,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","XSUC"})
For i:=1 to Len(aRegs)
	If !dbSeek(cPerg+aRegs[i,2])
		RecLock("SX1",.T.)
		For j:=1 to FCount()
			If j <= Len(aRegs[i])
				FieldPut(j,aRegs[i,j])
			Endif
		Next
		MsUnlock()
	Endif
Next

dbSelectArea(_sAlias)
Return


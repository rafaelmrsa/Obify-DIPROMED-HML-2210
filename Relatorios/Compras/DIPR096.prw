
/*
+---------------------------------------------------------------------+
| RBORGES Data: 04/07/2018                                            | 
+---------------------------------------------------------------------+
| FUNÇÃO: DIPR096()                                                   | 
+---------------------------------------------------------------------+
| DESCRIÇÃO: Essa função enviará e-mail para os usuários contidos no  |  
| parâmetro, quando Dt Val ANVIS Frete/Anvsisa – cadastro de produto  | 
| estiver vencido.                                                    |
+---------------------------------------------------------------------+
|USO: Dipromed - Qualidade                                            |
+---------------------------------------------------------------------+
*/

#INCLUDE "RWMAKE.CH"
#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'PARMTYPE.CH'
#INCLUDE "AP5MAIL.CH"
#INCLUDE "TBICONN.CH"

User Function DIPR096(aWork)

Local _xArea := GetArea()
Private cWorkFlow	:= ""
Private cWCodEmp    := ""
Private cWCodFil    := ""

cWorkFlow := aWork[1]
cWCodEmp  := aWork[2]
cWCodFil  := aWork[3]

PREPARE ENVIRONMENT EMPRESA cWCodEmp FILIAL cWCodFil FUNNAME "DIPR096"

ConOut('Inicio do relatorio dos produtos Dt Val Anv vencida, DIPR096, '+dToc(date())+' as '+Time())

	RunProc()	// Relatório de produtos com data de validade anvisa vencida.

ConOut('Inicio do relatorio dos produtos Dt Val Anv vencida, DIPR096, '+dToc(date())+' as '+Time())

RestArea(_xArea)                    

Return


Static Function RunProc()

Local cQRY1   := ""
Local cCod    := "" 
Local cDesc   := ""
Local cRegAnv := ""               // B1_REG_ANV
Local cDatAnv := CTOD("  /  /  ") // B1_DTV_ANV
Local cClaAnv := ""               // B1_RANVISA

cQRY1 := " SELECT B1_FILIAL, B1_COD, B1_DESC, B1_REG_ANV, B1_DTV_ANV, B1_RANVISA "
cQRY1 += " FROM "
cQRY1 += RetSQLName("SB1")
cQRY1 +=	" WHERE "
cQRY1 += " B1_FILIAL  = '"+xFilial("SB1")+"' AND "
cQRY1 += " B1_TIPO    = 'PA' AND "
cQRY1 += " B1_DTV_ANV <> ''  AND "
cQRY1 += " DATEDIFF(DAY,B1_DTV_ANV,'"+dTos(date())+"') > 0 AND"
cQRY1 += " (LEFT(B1_DESC,1) <> 'Z' AND "
cQRY1 += " B1_MSBLQL <> '1') AND " 
cQRY1 += " D_E_L_E_T_ = ' ' "
	
cQRY1 := ChangeQuery(cQRY1)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQRY1),"QRY1ANV",.T.,.T.)

While !QRY1ANV->(Eof())    

	cCod    := QRY1ANV->B1_COD 
	cDesc   := QRY1ANV->B1_DESC 
	cRegAnv := QRY1ANV->B1_REG_ANV 
	cDatAnv := DTOC(STOD(QRY1ANV->B1_DTV_ANV)) 
	cClaAnv := QRY1ANV->B1_RANVISA

	R096EMAIL(cCod, cDesc, cRegAnv, cDatAnv, cClaAnv) //Dispara um E-mail caso o produto esteja na regra

	cCod    := "" 
	cDesc   := ""
	cRegAnv := ""               
	cDatAnv := CTOD("  /  /  ") 
	cClaAnv := ""   
	            
	QRY1ANV->(DbSkip())
		
EndDo

QRY1ANV->(dbCloseArea())


Return

/*
+--------------------------------------------------------------------+
|RBORGES - 04/07/2018                                                |
+--------------------------------------------------------------------+ 
|Funcao para dispar o E-mail         						         |
+--------------------------------------------------------------------+
*/

*--------------------------------------------------------------------*
Static Function R096EMAIL(cCod, cDesc, cRegAnv, cDatAnv, cClaAnv)
*--------------------------------------------------------------------*

Local cDeIc       := "protheus@dipromed.com.br"
Local cEmailIc    := GetNewPar("ES_R096EMA","qualidade@dipromed.com.br;reginaldo.borges@dipromed.com.br")  //Usuários que receberão e-mails
Local cAssuntoIc  := "AVISO - PRODUTO COM VALIDADE ANVISA VENCIDA, "+AllTrim(cCod)+ "! "
Local cAttachIc   :=  "  a"
Local cFuncSentIc :=   "DIPR096.PRW"

_aMsgIc := {}

aAdd( _aMsgIc , { "PRODUTO     ", +cCod})
aAdd( _aMsgIc , { "DESCRICAO   ", +cDesc})
aAdd( _aMsgIc , { "REG. ANVISA ", +cRegAnv})
aAdd( _aMsgIc , { "DT. VALIDADE", +cDatAnv})
aAdd( _aMsgIc , { "CLASSE ANVI ", +cClaAnv})


If GetNewPar("ES_ATIVJOB",.T.)
	U_UEnvMail(cEmailIc,cAssuntoIc,_aMsgIc,cAttachIc,cDeIc,cFuncSentIc)
EndIf


Return()  


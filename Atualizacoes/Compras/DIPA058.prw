#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "COLORS.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDIPDESPIMPบAutor  ณMicrosiga           บ Data ณ  08/07/13   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function DIPA058()
Local _aRet := {}                                   
DEFINE FONT oBold   NAME "Arial" SIZE 0, -12 BOLD   //fonte

If U_DipUsr()$GetNewPar("ES_DESPIMP","")
	If SF1->F1_EST == 'EX'                                           
		_aRet := TelaDpImp()
		
		If _aRet[1]
			DipAtuSD1(_aRet[2],_aRet[3])
		Else
			Aviso("Aten็ใo","Processo cancelado pelo operador.",{"Ok"},1)
		EndIf
	
	Else
		Aviso("Aten็ใo","Esta NF nใo ้ de importa็ใo.",{"Ok"},1)	
	EndIf                               
Else                                                                
	Aviso("ES_DESPIMP","Usuแrio sem acesso เ rotina."+CHR(10)+CHR(13)+"Entre em contato com o T.I..",{"Ok"},1)	
EndIf

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDIPDESPIMPบAutor  ณMicrosiga           บ Data ณ  08/07/13   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function TelaDpImp()
Local _oDlg       
Local _nOpcao	:= 0
Local _nValor	:= 0              
Local _aRet 	:= {.F.}
Local _nAviso	:= 0                                                        
Local _cMotivo 	:= Space(255)
Local _lFlag	:= .F.
Private _nMarMer 	:= 0
Private _nHonora 	:= 0
Private _nFreRod 	:= 0
Private _nDesCon 	:= 0
Private _nSisFee 	:= 0
Private _nServAg 	:= 0
Private _nExpedi 	:= 0
Private _nArmaze 	:= 0
Private _nTxAnue 	:= 0
Private _nTxLibe 	:= 0
Private _nGRU 	    := 0
Private _nSDA 	    := 0
Private _nEmissE 	:= 0      
Private _nInspMa	:= 0
Private _nIOFAge	:= 0
Private _nISS 		:= 0
Private _nSecuri	:= 0
Private _nDemurr	:= 0
Private _nOutros 	:= 0
Private _nTotal 	:= 0
Private _oTotal		:= 0

_nAviso := Aviso("Aten็ใo","Qual despesa deseja lan็ar?",{"Total","Detalhada"},1)
    
cSQL := " SELECT TOP 1 "
cSQL += " 	ZZ7_MARMER,ZZ7_HONORA,ZZ7_FREROD,ZZ7_DCONSO,ZZ7_SISCAR,ZZ7_SERVAG,ZZ7_EXPEDI,ZZ7_ARMAZE,ZZ7_TXANUE,ZZ7_TXLIBE, "
cSQL += "	ZZ7_GRU,ZZ7_SDA,ZZ7_EMISLI,ZZ7_DESPMA,ZZ7_IOFAGE,ZZ7_ISS,ZZ7_SECURI,ZZ7_DEMURR,ZZ7_OUTROS,ZZ7_VALOR,ZZ7_MOTIVO "
cSQL += " 	FROM "
cSQL +=  		RetSQlName("ZZ7")
cSQL += " 		WHERE "
cSQL += " 			ZZ7_FILIAL = '"+xFilial("ZZ7")+"' AND "
cSQL += " 			ZZ7_DOC    = '"+SF1->F1_DOC+"' AND "
cSQL += "   		ZZ7_SERIE  = '"+SF1->F1_SERIE+"' AND "
cSQL += "			ZZ7_FORNEC = '"+SF1->F1_FORNECE+"' AND "  
cSQL += "			ZZ7_LOJA   = '"+SF1->F1_LOJA+"' AND "
cSQL += "           D_E_L_E_T_ = ' ' "
cSQL += " ORDER BY R_E_C_N_O_ DESC "

cSQL := ChangeQuery(cSQL)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),"LOADZZ7",.T.,.T.)
	
If !LOADZZ7->(Eof())    
	If _nAviso == 1                   
		_nTotal  := LOADZZ7->ZZ7_VALOR	
	Else
		_nMarMer := LOADZZ7->ZZ7_MARMER
		_nHonora := LOADZZ7->ZZ7_HONORA
		_nFreRod := LOADZZ7->ZZ7_FREROD
		_nDesCon := LOADZZ7->ZZ7_DCONSO
		_nSisFee := LOADZZ7->ZZ7_SISCAR
		_nServAg := LOADZZ7->ZZ7_SERVAG
		_nExpedi := LOADZZ7->ZZ7_EXPEDI
		_nArmaze := LOADZZ7->ZZ7_ARMAZE
		_nTxAnue := LOADZZ7->ZZ7_TXANUE
		_nTxLibe := LOADZZ7->ZZ7_TXLIBE
		_nGRU 	 := LOADZZ7->ZZ7_GRU
		_nSDA 	 := LOADZZ7->ZZ7_SDA
		_nEmissE := LOADZZ7->ZZ7_EMISLI      
		_nInspMa := LOADZZ7->ZZ7_DESPMA
		_nIOFAge := LOADZZ7->ZZ7_IOFAGE
		_nISS 	 := LOADZZ7->ZZ7_ISS
		_nSecuri := LOADZZ7->ZZ7_SECURI
		_nDemurr := LOADZZ7->ZZ7_DEMURR
		_nOutros := LOADZZ7->ZZ7_OUTROS	
		_cMotivo := LOADZZ7->ZZ7_MOTIVO  
		
		AtuTotal(.F.)
	EndIf
EndIf
LOADZZ7->(dbCloseArea())

While !_lFlag
	If _nAviso == 1
		@ 126,000 To 250,350 DIALOG _oDlg TITLE OemToAnsi("Recแlculo do Custo Doc: " + AllTrim(SF1->F1_DOC)+"-"+SF1->F1_SERIE)
		@ 008,010 Say "Informe as despesas do documento: "  PIXEL OF _oDlg  FONT oBold
		@ 008,120 Say AllTrim(SF1->F1_DOC)+"-"+SF1->F1_SERIE PIXEL OF _oDlg FONT oBold COLOR CLR_HRED
		@ 020,010 Say "Valor: "
		@ 020,040 Get _nTotal Size 43,20 Picture "@E 99,999,999.99" 
		@ 040,100 BUTTON OemToAnsi("Confirma")       SIZE 30,15 ACTION (_nOpcao := 1, Close(_oDlg))
		@ 040,140 BUTTON OemToAnsi("Cancela")        SIZE 30,15 ACTION (_nOpcao := 0, Close(_oDlg))
		ACTIVATE DIALOG _oDlg Centered	                                                           		
	ElseIf _nAviso==2
		@ 126,000 To 580,500 DIALOG _oDlg TITLE OemToAnsi("Recแlculo do Custo Doc: " + AllTrim(SF1->F1_DOC)+"-"+SF1->F1_SERIE)
		@ 008,010 Say "Informe as despesas do documento: "   PIXEL OF _oDlg FONT oBold
		@ 008,120 Say AllTrim(SF1->F1_DOC)+"-"+SF1->F1_SERIE PIXEL OF _oDlg FONT oBold COLOR CLR_HRED
		
		@ 020,010 Say "Marinha Mercante: "
		@ 020,070 Get _nMarMer  Size 50,20 Picture "@E 99,999,999.99" Valid AtuTotal()
		@ 031,010 Say "Honorแrios: "
		@ 031,070 Get _nHonora  Size 50,20 Picture "@E 99,999,999.99" Valid AtuTotal()
		@ 042,010 Say "Frete Rodoviแrio: "
		@ 042,070 Get _nFreRod  Size 50,20 Picture "@E 99,999,999.99" Valid AtuTotal()
		@ 053,010 Say "Desconsolida็ใo: "
		@ 053,070 Get _nDesCon  Size 50,20 Picture "@E 99,999,999.99" Valid AtuTotal()
		@ 064,010 Say "Siscarga FEE: "
		@ 064,070 Get _nSisFee  Size 50,20 Picture "@E 99,999,999.99" Valid AtuTotal()
		@ 075,010 Say "Serv.Agenc.Carga: "
		@ 075,070 Get _nServAg  Size 50,20 Picture "@E 99,999,999.99" Valid AtuTotal()
		@ 086,010 Say "Expediente: "
		@ 086,070 Get _nExpedi  Size 50,20 Picture "@E 99,999,999.99" Valid AtuTotal()
		@ 097,010 Say "Armazenagem: "
		@ 097,070 Get _nArmaze  Size 50,20 Picture "@E 99,999,999.99" Valid AtuTotal()
		@ 108,010 Say "Taxa Anu๊ncia LI: "
		@ 108,070 Get _nTxAnue  Size 50,20 Picture "@E 99,999,999.99" Valid AtuTotal()
		@ 119,010 Say "Taxa Libera็ใo: "
		@ 119,070 Get _nTxLibe  Size 50,20 Picture "@E 99,999,999.99" Valid AtuTotal()
		@ 130,010 Say "GRU: "
		@ 130,070 Get _nGRU  	Size 50,20 Picture "@E 99,999,999.99" Valid AtuTotal()
		@ 141,010 Say "SDA: "
		@ 141,070 Get _nSDA  	Size 50,20 Picture "@E 99,999,999.99" Valid AtuTotal()
		@ 152,010 Say "Emissao de LI: "
		@ 152,070 Get _nEmissE  Size 50,20 Picture "@E 99,999,999.99" Valid AtuTotal()
		@ 163,010 Say "Inspe็ใo Madeira: "
		@ 163,070 Get _nInspMa  Size 50,20 Picture "@E 99,999,999.99" Valid AtuTotal()

		@ 020,130 Say "IOF Agente MAR/AER: "
		@ 020,190 Get _nIOFAge  Size 50,20 Picture "@E 99,999,999.99" Valid AtuTotal()
		@ 031,130 Say "ISS: "
		@ 031,190 Get _nISS  	Size 50,20 Picture "@E 99,999,999.99" Valid AtuTotal()
		@ 042,130 Say "Security: "
		@ 042,190 Get _nSecuri  Size 50,20 Picture "@E 99,999,999.99" Valid AtuTotal()
		@ 053,130 Say "Demurrage: "
		@ 053,190 Get _nDemurr  Size 50,20 Picture "@E 99,999,999.99" Valid AtuTotal()

		@ 174,010 Say "Outros: "
		@ 174,070 Get _nOutros  Size 50,20 Picture "@E 99,999,999.99" Valid AtuTotal()
		@ 185,010 Say "Motivo: "
		@ 185,030 Get _cMotivo  Size 210,20 Picture "@!"  Valid !Empty(_cMotivo) When _nOutros>0
		
		@ 208,010 Say "TOTAL:" PIXEL OF _oDlg FONT oBold COLOR CLR_HRED
		@ 207,034 Get _nTotal Object _oTotal Size 50,20 Picture "@E 99,999,999.99"  When .F.
		
		@ 206,175 BUTTON OemToAnsi("Confirma")       SIZE 30,15 ACTION (_nOpcao := 1, Close(_oDlg))
		@ 206,210 BUTTON OemToAnsi("Cancela")        SIZE 30,15 ACTION (_nOpcao := 0, Close(_oDlg))
		ACTIVATE DIALOG _oDlg Centered
	EndIf                             
	
	If _nOpcao == 1
		If Aviso("Aten็ใo","Confirma a inclusใo de R$ "+AllTrim(Transform(_nTotal,"@E 999,999,999.99"))+CHR(10)+CHR(13)+;
							"como despesa do documento "+AllTrim(SF1->F1_DOC)+"-"+AllTrim(SF1->F1_SERIE)+" ?",{"Nใo","Sim"},1)==2
			_lFlag := .T.
		EndIf
	Else
		_lFlag:=.T.		
	EndIf	
EndDo                  

If _nOpcao == 0 
	
	_aRet := {.F.}	
	
ElseIf _nAviso == 1

	_aRet := {_nOpcao==1,_nTotal,{}}  
	
Else 
	_aRet := {.T.,0,{}}
	
	aAdd(_aRet[3], _nMarMer)//01
	_nValor :=  _nMarMer
	
	aAdd(_aRet[3], _nHonora)//02
	_nValor +=	_nHonora
	
	aAdd(_aRet[3], _nFreRod)//03
	_nValor +=	_nFreRod
	
	aAdd(_aRet[3], _nDesCon)//04
	_nValor +=	_nDesCon
	
	aAdd(_aRet[3], _nSisFee)//05
	_nValor +=	_nSisFee
	
	aAdd(_aRet[3], _nServAg)//06
	_nValor +=	_nServAg
	
	aAdd(_aRet[3], _nExpedi)//07
	_nValor +=	_nExpedi
	
	aAdd(_aRet[3], _nArmaze)//08
	_nValor +=	_nArmaze
	
	aAdd(_aRet[3], _nTxAnue)//09
	_nValor +=	_nTxAnue
	
	aAdd(_aRet[3], _nTxLibe)//10
	_nValor +=	_nTxLibe
	
	aAdd(_aRet[3], _nGRU)//11
	_nValor +=	_nGRU
	
	aAdd(_aRet[3], _nSDA)//12
	_nValor +=	_nSDA
	
	aAdd(_aRet[3], _nEmissE)//13
	_nValor +=	_nEmissE
	
	aAdd(_aRet[3], _nOutros)//14
	_nValor +=	_nOutros
	
	aAdd(_aRet[3], _cMotivo)//15
	
	aAdd(_aRet[3], _nInspMa)//16
	_nValor +=	_nInspMa
                                
	aAdd(_aRet[3], _nIOFAge)//17
	_nValor +=	_nIOFAge            
	
	aAdd(_aRet[3], _nISS   )//18
	_nValor +=	_nISS
	
	aAdd(_aRet[3], _nSecuri)//19
	_nValor +=	_nSecuri
	
	aAdd(_aRet[3], _nDemurr)//20
	_nValor +=	_nDemurr

	_aRet[2] := _nValor
EndIf


Return(_aRet)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDIPDESPIMPบAutor  ณMicrosiga           บ Data ณ  08/07/13   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function DipSeqZZ7()
Local cSQL := ""        
Local cSeq := ""

cSQL := " SELECT "
cSQL += " 	COUNT(1) QTD"
cSQL += " 	FROM "
cSQL +=  		RetSQlName("ZZ7")
cSQL += " 		WHERE "
cSQL += " 			ZZ7_FILIAL = '"+xFilial("ZZ7")+"' AND "
cSQL += " 			ZZ7_DOC    = '"+SF1->F1_DOC+"' AND "
cSQL += "   		ZZ7_SERIE  = '"+SF1->F1_SERIE+"' AND "
cSQL += "			ZZ7_FORNEC = '"+SF1->F1_FORNECE+"' AND "  
cSQL += "			ZZ7_LOJA   = '"+SF1->F1_LOJA+"' AND "
cSQL += "           D_E_L_E_T_ = ' ' "

cSQL := ChangeQuery(cSQL)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),"QRYZZ7",.T.,.T.)

cSeq := StrZero(QRYZZ7->QTD+1,2)             

QRYZZ7->(dbCloseArea())

Return cSeq
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDIPDESPIMPบAutor  ณMicrosiga           บ Data ณ  08/08/13   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function DipAtuSD1(_nCusto,_aItens)
Local aArea 	 := GetArea()
Local aAreaSD1 	 := SD1->(GetArea())
Local aAreaSF1 	 := SF1->(GetArea())
Local _nCusDip 	 := 0
Local _cFrom     := "protheus@dipromed.com.br"
Local _cFuncSent := "DipAtuSD1(DIPDESPIMP.PRW)"
Local _cAssunto	 := ""
Local _cEmail	 := ""        
Local _cFiTro    := ""
Local _aMsg		 := {}
Local _nFretTot	 := 0        
Local _nFretRat  := 0

If Len(_aItens) > 0 .And. _aItens[3] > 0
	_nFretTot := _aItens[3]
	_nCusto   := _nCusto-_nFretTot
EndIf

SD1->(dbSetOrder(1))
If SD1->(dbSeek(xFilial("SD1")+SF1->(F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA)))
	While !SD1->(Eof()) .And. SD1->(D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA) == SF1->(F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA)
	                     
		If _nFretTot > 0
			_nFretRat := (SD1->D1_PESO*_nFretTot)/SF1->F1_PESOL
			_nFretRat := _nFretRat/SD1->D1_QUANT
		EndIf
		                         
		If GetNewPar("ES_CUSTCD5",.F.)                                                                                                    
			CD5->(dbSetOrder(4))
			If CD5->(dbSeek(xFilial("CD5")+SD1->(D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_ITEM)))
				_nCusDip := (SD1->(D1_TOTAL+D1_VALICM+D1_DESPESA+D1_VALIPI)+CD5->(CD5_VLPIS+CD5_VLCOF)+(SD1->D1_TOTAL/SF1->F1_VALMERC*_nCusto))/SD1->D1_QUANT
			Else
				_nCusDip := (SD1->(D1_TOTAL+D1_VALICM+D1_VALIMP5+D1_VALIMP6+D1_DESPESA+D1_VALIPI)+(SD1->D1_TOTAL/SF1->F1_VALMERC*_nCusto))/SD1->D1_QUANT
			EndIf
		Else 
			_nCusDip := (SD1->(D1_TOTAL+D1_VALICM+D1_VALIMP5+D1_VALIMP6+D1_DESPESA+D1_VALIPI)+(SD1->D1_TOTAL/SF1->F1_VALMERC*_nCusto))/SD1->D1_QUANT
		EndIf

		If  _nFretTot > 0
			_nCusDip += _nFretRat
		EndIf
	
		SD1->(RecLock("SD1",.F.))
			SD1->D1_CUSDIP := _nCusDip
		SD1->(MsUnlock())
		SD1->(DbCommit())
			
		SF4->(dbSetOrder(1))
		SF4->(dbSeek(xFilial("SF4")+SD1->D1_TES))
		If SF4->F4_UPRC == 'S'			
			
			SB1->(dbSetOrder(1))
			SB1->(dbSeek(xFilial("SB1")+SD1->D1_COD))
			SB1->(RecLock("SB1",.F.))
			SB1->B1_CUSDIP := _nCusDip
			SB1->(MsUnlock())
			SB1->(DbCommit())
						
			If cEmpAnt = "01"
				If cFilAnt = "01"
					_cFiTro := "04"
					DbSelectArea("SB1")
					SB1->(DbSetOrder(1))
					SB1->(DbSeek(cFilAnt + SD1->D1_COD ))			
					If	SB1->(DbSeek(_cFiTro + SD1->D1_COD ))
						RecLock("SB1",.F.)
						SB1->B1_CUSDIP := _nCusDip
						SB1->(MsUnlock())
						SB1->(DbCommit())
					Endif
				ElseIf cFilAnt = "04"
					_cFiTro := "01"
					DbSelectArea("SB1")
					SB1->(DbSetOrder(1))
					SB1->(DbSeek(cFilAnt + SD1->D1_COD ))			
					If	SB1->(DbSeek(_cFiTro + SD1->D1_COD ))
						RecLock("SB1",.F.)
						SB1->B1_CUSDIP := _nCusDip
						SB1->(MsUnlock())
						SB1->(DbCommit())
					Endif
				Endif	
			EndIf			
			
		EndIf
	
		SD1->(dbSkip())
	EndDo
	
	dbSelectArea("ZZ7")
	ZZ7->(RecLock("ZZ7",.T.))
		ZZ7->ZZ7_FILIAL := xFilial("ZZ7")
		ZZ7->ZZ7_DOC 	:= SF1->F1_DOC
		ZZ7->ZZ7_SERIE	:= SF1->F1_SERIE                 
		ZZ7->ZZ7_FORNEC	:= SF1->F1_FORNECE
		ZZ7->ZZ7_LOJA  	:= SF1->F1_LOJA
		ZZ7->ZZ7_SEQ	:= DipSeqZZ7()
		ZZ7->ZZ7_DATA 	:= ddatabase
		ZZ7->ZZ7_HORA	:= SubStr(Time(),1,2)+":"+SubStr(Time(),4,2)
		ZZ7->ZZ7_USUARI := U_DipUsr()
		ZZ7->ZZ7_VALOR  := _nCusto+_nFretTot
		If Len(_aItens)>0
			ZZ7->ZZ7_MARMER := _aItens[01]
			ZZ7->ZZ7_HONORA := _aItens[02]
			ZZ7->ZZ7_FREROD := _aItens[03]
			ZZ7->ZZ7_DCONSO := _aItens[04]
			ZZ7->ZZ7_SISCAR := _aItens[05]
			ZZ7->ZZ7_SERVAG := _aItens[06]
			ZZ7->ZZ7_EXPEDI := _aItens[07]
			ZZ7->ZZ7_ARMAZE := _aItens[08]
			ZZ7->ZZ7_TXANUE := _aItens[09]
			ZZ7->ZZ7_TXLIBE := _aItens[10]
			ZZ7->ZZ7_GRU 	:= _aItens[11]
			ZZ7->ZZ7_SDA 	:= _aItens[12]
			ZZ7->ZZ7_EMISLI := _aItens[13]
			ZZ7->ZZ7_OUTROS := _aItens[14]
			ZZ7->ZZ7_MOTIVO := _aItens[15]
			ZZ7->ZZ7_DESPMA := _aItens[16]
			ZZ7->ZZ7_IOFAGE := _aItens[17]
			ZZ7->ZZ7_ISS    := _aItens[18]
			ZZ7->ZZ7_SECURI := _aItens[19]
			ZZ7->ZZ7_DEMURR := _aItens[20]
		EndIf
	ZZ7->(MsUnlock())
	ZZ7->(DbCommit())
	
	SF1->(RecLock("SF1",.F.)) 
		SF1->F1_II := _nCusto
	SF1->(MsUnlock())
	SF1->(DbCommit())	

	_cEmail    := GetNewPar("ES_MAILIMP","")
       			
    _cAssunto:= EncodeUTF8("Recแlculo do custo de Importa็ใo: " +AllTrim(SF1->F1_DOC)+"-"+AllTrim(SF1->F1_SERIE),"cp1252") 
   	Aadd( _aMsg , { "Documento: "       	, AllTrim(SF1->F1_DOC)  } )
   	Aadd( _aMsg , { "Serie: "  	    	 	, AllTrim(SF1->F1_SERIE)} )
   	Aadd( _aMsg , { "Fornecedor: "	  		, AllTrim(SF1->F1_FORNECE)+" - "+AllTrim(Posicione("SA2",1,xFilial("SA2")+SF1->F1_FORNECE+SF1->F1_LOJA,"A2_NREDUZ")) } )
	Aadd( _aMsg , { "Data/Hora: "           , DtoC(dDataBase)+" - "+SubStr(Time(),1,2)+":"+SubStr(Time(),4,2) } )
	Aadd( _aMsg , { "Usuแrio:  "            , U_DipUsr() } )
		
	U_UEnvMail(_cEmail,_cAssunto,_aMsg,"",_cFrom,_cFuncSent)       
                                                 


	Aviso("Aten็ใo","Valores atualizados com sucesso.",{"Ok"},1)	
Else
	Aviso("Aten็ใo","Nใo foram encontrados itens para a atualiza็ใo.",{"Ok"},1)
EndIf 

RestArea(aAreaSF1)
RestArea(aAreaSD1)
RestArea(aArea)

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDIPDESPIMPบAutor  ณMicrosiga           บ Data ณ  08/13/13   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function AtuTotal(lRefresh)
DEFAULT lRefresh := .T.

_nTotal := 	_nMarMer+;
			_nHonora+;
			_nFreRod+;
			_nDesCon+;
			_nSisFee+;
			_nServAg+;
			_nExpedi+;
			_nArmaze+;
			_nTxAnue+;
			_nTxLibe+;
			_nGRU   +;
			_nSDA   +;
			_nEmissE+;
			_nOutros+;
			_nInspMa+;
			_nIOFAge+;
			_nISS	+;
			_nSecuri+;
			_nDemurr
			
        
If lRefresh
	_oTotal:Refresh()			
EndIf

Return .T.
#INCLUDE "PROTHEUS.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณNOVO33    บAutor  ณMicrosiga           บ Data ณ  05/18/15   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function DIPA071() 
Local aAreaSB1 := SB1->(GetArea())   
Local oDlg   
Local oCbx    
Local nOpca	   :=0
Local cTpEmb   := ""
Local cPerg    := "DIP071"
Local cProduto := ""
Local nCxEmbar := 0
Local nCxSecun := 0
Local cTpEmbal := ""
Local lWhen    := .F.   
Local cTpAux   := ""
	
If Upper(u_DipUsr())$GetNewPar("ES_D071VLD","")
     
	/*
	AjustaSX1(cPerg)
	
	If !Pergunte(cPerg,.T.)
		Return
	EndIf                 
	
	cProd := AllTrim(MV_PAR01)
	
	SB1->(dbSetOrder(1))
	If SB1->(dbSeek(xFilial("SB1")+cProd))		
	*/
	If SB1->B1_XCXFECH=="1" .And. SB1->B1_XVLDCXE <> "1"
		If Aviso("Aten็ใo","Deseja avaliar o produto:"+CHR(10)+CHR(13)+;
							Alltrim(SB1->B1_COD)+"-"+AllTrim(SB1->B1_DESC)+CHR(10)+CHR(13),{"Sim","Nใo"},2)==1
			
			If u_Dip071Tela("2")         
				If cEmpAnt == "01"
					If Empty(SB1->B1_XCODDES)
						Processa({||DipDupPro(SB1->B1_COD,cTpAux,nCxEmbar,nCxSecun)},"Criando novo c๓digo de produto...")
					Else 
						Aviso("Aten็ใo","Este produto jแ possui c๓digo para fracionados: "+SB1->B1_XCODDES+".",{"Ok"},1)		
					EndIf
				EndIf
			EndIf
		EndIf
	Else
		Aviso("Aten็ใo","Este produto nใo necessita de avalia็ใo.",{"Ok"},1)		
	EndIf    
Else
	Aviso("ES_DIPA071","Voc๊ nใo possui acesso para utilizar esta op็ใo.",{"Ok"},1)
EndIf
RestArea(aAreaSB1)

Return       
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDIPA071   บAutor  ณMicrosiga           บ Data ณ  05/21/15   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function Dip071Avl()       
Local aAreaSB1 	:= SB1->(GetArea())
Local nRec  	:= 0
Local cProd 	:= SB1->B1_COD
Local cTipo 	:= "1"

If Upper(u_DipUsr())$GetNewPar("ES_D071SOL","")
	If SB1->B1_XCXFECH == "1" .And. SB1->B1_XVLDCXE == "1"
		Aviso("Aten็ใo","Produto jแ estแ cadastrado na regra de caixa fechada.",{"Ok"},1)
	ElseIf SB1->B1_XCXFECH == "1" .And. SB1->B1_XVLDCXE <> "1" 
		Aviso("Aten็ใo","Jแ foi solicitada a avalia็ใo do produto para a regra de caixa fechada.",{"Ok"},1)
	ElseIf Aviso("Aten็ใo","Confirma a altera็ใo deste produto para vender somente caixa fechada?"+CHR(10)+CHR(13)+;
							Alltrim(SB1->B1_COD)+"-"+AllTrim(SB1->B1_DESC)+CHR(10)+CHR(13)+;
							"Este produto ficarแ bloqueado para venda at้ a avalia็ใo da caixa de embarque.",{"Sim","Nใo"},2)==1
	
		If u_Dip071Tela(cTipo)				
			
			cMsgCIC := " "	
			
			cMsgCIC := "*AVALIAวรO DA CAIXA DE EMBARQUE.*"+CHR(10)+CHR(13)
			cMsgCIC += 'O usuแrio "'+u_DipUsr()+'" solicitou avalia็ใo da caixa de embarque do produto:'+CHR(10)+CHR(13)
			cMsgCIC += AllTrim(SB1->B1_COD)+"-"+AllTrim(SB1->B1_DESC)+CHR(10)+CHR(13)
			cMsgCIC += 'Esta avalia็ใo ้ necessแria para iniciar a venda por caixa fechada.'+CHR(10)+CHR(13)
			cMsgCIC += " "+CHR(10)+CHR(13)
			cMsgCIC += "*### ATENวรO ###*"+CHR(10)+CHR(13)
			cMsgCIC += "Este produto ficarแ *BLOQUEADO* para venda aguardando a avalia็ใo do responsแvel.
			
			U_DIPCIC(cMsgCIC,GetNewPar("ES_D071CVL",""))
			
			_cEmail    := GetNewPar("ES_D071MVL","")
			_cFrom     := "protheus@dipromed.com.br"
			_cFuncSent := "DipDupPro(DIPA071.PRW)
	       			
		    _cAssunto := EncodeUTF8("Solicita็ใo de Avalia็ใo da Caixa de Embarque","cp1252")
		    _aMsg := {}
		   	Aadd( _aMsg , { "C๓digo: "       	, AllTrim(SB1->B1_COD)  } )
		   	Aadd( _aMsg , { "Descri็ใo: "  	 	, AllTrim(SB1->B1_DESC)} )         
		   	Aadd( _aMsg , { "Motivo: "  	 	, "Inicio de venda em caixa fechada."} )         
		   	Aadd( _aMsg , { "Situa็ใo: "  	 	, "Bloqueado para venda"} )         
			Aadd( _aMsg , { "Data/Hora: "       , DtoC(dDataBase)+" - "+SubStr(Time(),1,2)+":"+SubStr(Time(),4,2) } )
			Aadd( _aMsg , { "Usuแrio:  "        , U_DipUsr() } )
				
			U_UEnvMail(_cEmail,_cAssunto,_aMsg,"",_cFrom,_cFuncSent)       
		 
			Aviso("Aten็ใo","Produto aguardando a avalia็ใo da caixa de embarque pelo CD."+CHR(10)+CHR(13)+;
							"Ap๓s avaliado o produto serแ liberado para venda novamente",{"Ok"},2)
		EndIf
	EndIf
Else
	Aviso("ES_D071SOL","Usuแrio nใo autorizado a utilizar esta rotina",{"Ok"},1)
EndIf
RestArea(aAreaSB1)

Return 
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDIPA071   บAutor  ณMicrosiga           บ Data ณ  05/19/15   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function DipDupPro(cProd,cTpAux,nCxEmbar,nCxSecun)
Local cSQL 		:= "" 
Local aStruSB1 	:= {}
Local aDadSB1	:= {}
Local nI 		:= 0
Local cNewCod	:= ""       
Local cAltPro	:= ""
Local nRec 		:= 0
DEFAULT cProd   := ""
DEFAULT cTpAux  := ""
DEFAULT nCxEmbar:= 0
DEFAULT nCxSecun:= 0

dbSelectArea("SB1")
SB1->(dbSetOrder(1))
If SB1->(dbSeek(xFilial("SB1")+cProd))	
	cSQL := " SELECT "
	cSQL += "		ISNULL(MAX(B1_COD),'400000') MAX "
	cSQL += "		FROM "
	cSQL += 			RetSQLName("SB1")
	cSQL += "			WHERE "
	cSQL += "				B1_FILIAL IN('01','04') AND "
//	cSQL += "				B1_COD LIKE '[0-9]%' AND "
	cSQL += "				LEFT(B1_COD,1)='4' AND "
	cSQL += "				D_E_L_E_T_ = ' ' "       
	
	cSQL := ChangeQuery(cSQL)	
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),'TMPSB1',.T.,.F.)        
	If !TMPSB1->(Eof()) 
		
		cNewCod  := Soma1(AllTrim(TMPSB1->MAX))	
		aStruSB1 := SB1->(dbStruct())

		Begin Transaction             	 
			DipGrvSB1(cProd,"3",,,,cNewCod)	
					
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณCria produto na Matriz - 01 ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			
			For nI:=1 To 2
				lRet := .T.				
				If cfilAnt == "01"
					GetEmpr("0104")
					SB1->(dbSetOrder(1))
					If !SB1->(dbSeek(xFilial("SB1")+cProd))	
						lRet := .F.			
					EndIf
				Else
					GetEmpr("0101")                     
					SB1->(dbSetOrder(1))
					If !SB1->(dbSeek(xFilial("SB1")+cProd))	
						lRet := .F.
					EndIf
				EndIf	
				
				If lRet
					lRet := DipDupCod(cFilAnt,cNewCod,aStruSB1) 	
				EndIf
				
				If !lRet
					DisarmTransaction()
					Break
				EndIf						
			Next nI
			 
			/*
			SB1->(dbGoTo(nRec))
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณCria produto no CD - 04     ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			DipDupCod("04",cNewCod,aStruSB1)
			*/
		End Transaction
		
		If lRet					
			Aviso("Aten็ใo",'Foi criado o c๓digo "'+AllTrim(cNewCod)+'" para fracionados do codigo "'+AllTrim(cProd)+'".'+CHR(10)+CHR(13)+;
							'Fa็a a transfer๊ncia do saldo fracionado para o novo c๓digo.',{"Ok"},1)    
			
			cMsgCIC := " "	
			
			cMsgCIC := "*NOVO CำDIGO P/ FRACIONADOS!*"+CHR(10)+CHR(13)
			cMsgCIC += 'Foi criado o c๓digo "'+AllTrim(cNewCod)+'" para utilizar os fracionados do c๓digo "'+AllTrim(cProd)+'".'+CHR(10)+CHR(13)
			cMsgCIC += 'O usuแrio deve fazer a transfer๊ncia *MANUAL* do saldo fracionado para o novo c๓digo.'+CHR(10)+CHR(13)
			cMsgCIC += 'Verifique as reservas do item nos pedidos de venda.'+CHR(10)+CHR(13)
			cMsgCIC += "Usuแrio: "+u_DipUsr()
			
			U_DIPCIC(cMsgCIC,GetNewPar("ES_D071CVL","")+","+GetNewPar("ES_D071CSO",""))
			
			_cEmail    := GetNewPar("ES_D071MVL","")+";"+GetNewPar("ES_D071MSO","")
			_cFrom     := "protheus@dipromed.com.br"
			_cFuncSent := "DipDupPro(DIPA071.PRW)
	       			
		    _cAssunto := EncodeUTF8("Novo C๓digo p/ Fracionados: ","cp1252")
		    _aMsg := {}
		   	Aadd( _aMsg , { "C๓digo Novo: "       	, AllTrim(cNewCod)  } )
		   	Aadd( _aMsg , { "C๓digo Antigo: "  	 	, AllTrim(cProd)} )
			Aadd( _aMsg , { "Data/Hora: "           , DtoC(dDataBase)+" - "+SubStr(Time(),1,2)+":"+SubStr(Time(),4,2) } )
			Aadd( _aMsg , { "Usuแrio:  "            , U_DipUsr() } )
				
			U_UEnvMail(_cEmail,_cAssunto,_aMsg,"",_cFrom,_cFuncSent)       
		EndIf
	Else
		Aviso("Aten็ใo","Nใo foi possํvel criar o produto.",{"Ok"},1)
	EndIf
	TMPSB1->(dbCloseArea())             	
Else 
	Aviso("Aten็ใo","Nใo foi possํvel criar o produto. Produto origem nใo encontrado.",{"Ok"},1)
EndIf                                         

Return                                        
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDIPA071   บAutor  ณMicrosiga           บ Data ณ  05/18/15   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function DipDupCod(cFil,cNewCod,aStruSB1)
Local aDadSB1 := {}
Local nI 	  := 0
Local lRet 	  := .T.
Private	lMsErroAuto := .F.

For nI := 1 To Len(aStruSB1)             	        
	If aStruSB1[nI,1]=="B1_FILIAL"			
		Loop//aAdd(aDadSB1,{"B1_FILIAL",cFil,nil})
	ElseIf aStruSB1[nI,1]=="B1_COD"			
		aAdd(aDadSB1,{"B1_COD",cNewCod,nil})    
	ElseIf aStruSB1[nI,1]=="B1_XCODORI"
		aAdd(aDadSB1,{aStruSB1[nI,1],SB1->B1_COD,nil})    
	ElseIf aStruSB1[nI,1]=="B1_XCODDES"
		aAdd(aDadSB1,{"B1_XCODDES","",nil})    	
	ElseIf aStruSB1[nI,1]=="B1_XCXFECH"
		aAdd(aDadSB1,{"B1_XCXFECH","",nil})    		
	ElseIf aStruSB1[nI,1]=="B1_XVLDCXE"
		aAdd(aDadSB1,{"B1_XVLDCXE","",nil})    		
	ElseIf ( Type("SB1->"+aStruSB1[nI,1])=="C" .And. !Empty(&("SB1->"+aStruSB1[nI,1])) ) .Or.;
		   ( Type("SB1->"+aStruSB1[nI,1])=="N" .And. &("SB1->"+aStruSB1[nI,1])>0 ) .Or.;
		   ( Type("SB1->"+aStruSB1[nI,1])=="D" .ANd. !Empty(DtoS(&("SB1->"+aStruSB1[nI,1]))) )
		aAdd(aDadSB1,{aStruSB1[nI,1],&("SB1->"+aStruSB1[nI,1]),nil})
	EndIf
Next nI    


lMsErroAuto := .F.
	
SA2->(dbSetOrder(1))
SA2->(dbSeek(xFilial('SA2')+SB1->B1_PROC+SB1->B1_LOJPROC))
MSExecAuto( { | x, y | MATA010( x, y ) },aDadSB1,3)

If lMsErroAuto
	MostraErro()
	lRet := .F.
EndIf

Return lRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDIPA071   บAutor  ณMicrosiga           บ Data ณ  05/29/15   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function D071Desb()
Local aAreaSB1 := SB1->(GetArea())

If SB1->B1_MSBLQL == "1"
	If SB1->B1_XCXFECH=="1" .And. SB1->B1_XVLDCXE=="1"
		If Aviso("Aten็ใo","Deseja desbloquear o produto:"+CHR(10)+CHR(13)+;
							Alltrim(SB1->B1_COD)+"-"+AllTrim(SB1->B1_DESC)+CHR(10)+CHR(13)+;
							"Tenha certeza de que nใo existe mais lote fracionado neste c๓digo.",{"Sim","Nใo"},2)==1
			If SB1->(dbSeek("01"+SB1->B1_COD)) 				
				SB1->(RecLock("SB1",.F.))
					SB1->B1_MSBLQL  := " "		
				SB1->(MsUnLock())  	
			EndIf  
			If SB1->(dbSeek("04"+SB1->B1_COD))
				SB1->(RecLock("SB1",.F.))
					SB1->B1_MSBLQL  := " "		
				SB1->(MsUnLock())  	
			EndIf
		EndIf
	Else
		Aviso("Aten็ใo","Este produto nao pode ser desbloqueado por esta rotina.",{"Ok"},1)
	EndIf
Else
	Aviso("Aten็ใo","Este produto nao necessita de desbloqueio.",{"Ok"},1)
EndIf

RestArea(aAreaSB1)

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDIPA071   บAutor  ณMicrosiga           บ Data ณ  06/26/15   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function Dip071Tela(cTipo)
Local aAreaSB1 := SB1->(GetArea())   
Local oDlg   
Local oCbx    
Local nOpca	   := 0
Local cPerg    := "DIP071"
Local cProduto := ""
Local nCxEmbar := 0
Local nCxSecun := 0     
Local cTpAux   := "1"          
Local cTpEmbal := "1-Caixa de Embarque"
Local lWhen    := .F.   
Local cTitulo  := ""
Local cProd    := SB1->B1_COD
DEFAULT cTipo  := "" 

If SB1->B1_XTPEMBV=="2"       
	cTpEmbal := "2-Caixa Secundแria"
	cTpAux   := "2"
EndIf

aCbx     := {}
AAdd( aCbx, "1-Caixa de Embarque" )  
AAdd( aCbx, "2-Caixa Secundแria" )  

If cTipo=="1"
	cTitulo := "Valida็ใo do tipo de embalagem"
Else                                           
	cTitulo := "Valida็ใo da caixa de embarque"
EndIf                                            

DEFINE MSDIALOG oDlg TITLE OemToAnsi(cTitulo) From 1,0 To 20,50 OF oMainWnd

	cProduto := AllTrim(SB1->B1_COD)+" - "+AllTrim(SB1->B1_DESC)
	nCxEmbar := SB1->B1_XQTDEMB
	nCxSecun := SB1->B1_XQTDSEC
	lWhen 	 := .F.   
				
	@ 10,04 SAY   "Produto: 	 "					SIZE 100,008	PIXEL OF oDlg
	@ 18,04 MSGET cProduto							SIZE 180,010	PIXEL OF oDlg WHEN .F.
	@ 30,04 SAY   "Tp.Embalagem: " 					SIZE 100,008	PIXEL OF oDlg			
	@ 38,04 MSCOMBOBOX oCbx VAR cTpEmbal ITEMS aCbx SIZE 100,010 	PIXEL OF oDlg ON CHANGE cTpAux := AllTrim(Str(oCbx:nAt)) WHEN lWhen //WHEN lWhen .And. cTipo=="1"
	@ 50,04 SAY   "Cx.Embarque:  " 					SIZE 100,008	PIXEL OF oDlg
	@ 58,04 MSGET nCxEmbar		   					SIZE 100,010	PIXEL OF oDlg PICTURE "@E 999999" WHEN lWhen //WHEN  lWhen .And. cTipo=="2"
	@ 70,04 SAY   "Cx.Secundแria:" 					SIZE 100,008	PIXEL OF oDlg
	@ 78,04 MSGET nCxSecun		   					SIZE 100,010	PIXEL OF oDlg PICTURE "@E 999999" WHEN lWhen //WHEN  lWhen .And. cTipo=="2"
	
	@ 127, 132 Button "Confirma" Size 28,10 Action Eval({||nOpca:=1,oDlg:End()})  Pixel
	@ 127, 162 Button "Corrige"  Size 28,10 Action Eval({|| lWhen:=.T.})  Pixel
ACTIVATE MSDIALOG oDlg CENTERED

If nOpca==1
	DipGrvSB1(cProd,cTipo,cTpAux,nCxEmbar,nCxSecun)
EndIf

RestArea(aAreaSB1)

Return(nOpca==1)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDIPA071   บAutor  ณMicrosiga           บ Data ณ  07/01/15   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function DipGrvSB1(cProd,cTipo,cTpAux,nCxEmbar,nCxSecun,cNewCod)
Local nRec 	  	 := SB1->(Recno())   
DEFAULT cProd 	 := ""                   
DEFAULT cTipo 	 := ""
DEFAULT cTpAux 	 := ""
DEFAULT nCxEmbar := 0
DEFAULT nCxSecun := 0
DEFAULT cNewCod  := 0

SB1->(dbSetOrder(1))
If SB1->(dbSeek("01"+cProd)) 				
	SB1->(RecLock("SB1",.F.))  
		If cTipo$"1/2"
			If SB1->B1_XTPEMBV <> cTpAux .And. !Empty(cTpAux)
				SB1->B1_XTPEMBV := cTpAux 
			EndIf	 
			If SB1->B1_XQTDEMB <> nCxEmbar
				SB1->B1_XQTDEMB := nCxEmbar
			EndIf
			If SB1->B1_XQTDSEC <> nCxSecun
				SB1->B1_XQTDSEC := nCxSecun
			EndIf    
			If cTipo=="1"
				SB1->B1_XCXFECH := "1"
			Else 
				SB1->B1_XVLDCXE := "1"                
			EndIf
		Else
			SB1->B1_XCODDES := cNewCod	
		EndIf
	SB1->(MsUnLock())  	
EndIf                

If cEmpAnt == "01" .And. SB1->(dbSeek("04"+cProd)) //HQ nใo tem filial 04
	SB1->(RecLock("SB1",.F.))
		If cTipo$"1/2"
			If SB1->B1_XTPEMBV <> cTpAux .And. !Empty(cTpAux)
				SB1->B1_XTPEMBV := cTpAux 
			EndIf	 
			If SB1->B1_XQTDEMB <> nCxEmbar
				SB1->B1_XQTDEMB := nCxEmbar
			EndIf
			If SB1->B1_XQTDSEC <> nCxSecun
				SB1->B1_XQTDSEC := nCxSecun
			EndIf    
			If cTipo=="1"
				SB1->B1_XCXFECH := "1"
			Else 
				SB1->B1_XVLDCXE := "1"                
			EndIf
		Else
			SB1->B1_XCODDES := cNewCod	
		EndIf
	SB1->(MsUnLock())  	
EndIf

SB1->(dbGoTo(nRec))

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDIPA071   บAutor  ณMicrosiga           บ Data ณ  07/06/15   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function Dip071Vld(cProd,nQtdAux,lTrvSol)  
Local 	aArea   := GetArea()
Local   lRet 	:= .T.
DEFAULT cProd   := ""
DEFAULT nQtdAux := 0
DEFAULT lTrvSol := .F. //Trava o processo se existir solicita็ใo de caixa fechada
                            
SB1->(dbSetOrder(1))
If SB1->(dbSeek(xFilial("SB1")+cProd))   
	If SB1->B1_XCXFECH=="1"
		If !Empty(SB1->B1_XVLDCXE) .Or. lTrvSol
			If SB1->B1_XTPEMBV=="1"
				nQtdCxEmb := SB1->B1_XQTDEMB
			ElseIf SB1->B1_XTPEMBV=="2"
				nQtdCxEmb := SB1->B1_XQTDSEC
			Else
				nQtdCxEmb := 1
			EndIf
		
			If Mod(nQtdAux,nQtdCxEmb)<>0
				Aviso("Aten็ใo","Quantidade invแlida. O produto: "+CHR(13)+CHR(10)+;
								""+AllTrim(SB1->B1_COD)+"-"+AllTrim(SB1->B1_DESC)+CHR(13)+CHR(10)+;
								"s๓ poderแ ser movimentado em multiplos de "+AllTrim(Str(nQtdCxEmb)),{"Ok"},2)
				lRet := .F.
			EndIf	
		EndIf
	EndIf
Else 
	Aviso("DIPA071","Produto nใo encontrado. Avise o T.I.",{"Ok"},1)
	lRet := .F.
EndIf
	
Return lRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDIPA071   บAutor  ณMicrosiga           บ Data ณ  05/21/15   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function AjustaSX1(cPerg)
Local aRegs 	:= {}
DEFAULT cPerg 	:= ""

dbSelectArea("SX1")
dbSetOrder(1)

aAdd(aRegs,{cPerg,"01","Produto?","","","mv_ch1","C",15,0,0,"G","","MV_PAR01","","","","","","","","","","","","","","","","","","","","","","","","",'SB1'})

PlsVldPerg( aRegs )       

Return
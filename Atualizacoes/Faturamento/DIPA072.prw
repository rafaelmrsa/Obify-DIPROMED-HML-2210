#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDIPRETRES บAutor  ณMicrosiga           บ Data ณ  08/10/15   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function DipExcRes(aWork)     
Local cSQL 		 := ""
Local _aMsg      := {}
Local _cFrom     := "protheus@dipromed.com.br"
Local _cFuncSent := "DipExcRes(DIPA072)
Local _cAssunto  := EncodeUTF8("ATENวรO - Sua(s) reserva(s) foi(am) excluํda(s)","cp1252")
Local cOperado   := ""
Local cPedido	 := ""
Local cCICDest	 := ""
Local cChave	 := ""
Private cWCodEmp := ""  
Private cWCodFil := "" 

If ValType(aWork) <> 'A'
	Return
EndIf

cWCodEmp  := aWork[1]
cWCodFil  := aWork[2]

PREPARE ENVIRONMENT EMPRESA cWCodEmp FILIAL cWCodFil FUNNAME "DIPA072"
  
ConOut(cEmpAnt+cFilAnt+" "+dtoc(Date())+" "+Time()+" Inํcio - Excluindo Reservas...." )   

U_DIPPROC(ProcName(0),U_DipUsr())

cSQL := " SELECT "
cSQL += "	C5_NUM, C5_OPERADO, C5_CLIENTE, C5_LOJACLI "
cSQL += "	FROM "
cSQL += 		RetSQLName("SC5")+", "+RetSQLName("SC9")
cSQL += "		WHERE "
cSQL += "			C5_FILIAL  = '"+xFilial("SC5")+"' AND "
cSQL += "			C5_TIPODIP = '1' AND "
cSQL += "			C5_TIPO    = 'N' AND "     
cSQL += "			C5_PRENOTA = 'O' AND "
cSQL += "			C5_NOTA    = ' ' AND "
cSQL += "			C5_XDATEXP <> ' ' AND "
//cSQL += "			((C5_XDATEXP <= '"+DtoS(dDataBase)+"' AND C5_XHOREXP <= '"+Left(Time(),5)+"') OR 
//cSQL += "			C5_XDATEXP < '"+DtoS(dDataBase)+"') AND 
//Alterado por Tiago Stocco - 03/05/22 adicionado uma data limite de busca
//cSQL += "			((C5_DTPEDID <= '"+DtoS(dDataBase)+"') OR
cSQL += "			((C5_DTPEDID between '"+DtoS(dDataBase-60)+"' and '"+ Dtos(dDataBase)+"') OR
cSQL += "			C5_XDATEXP <= '"+DtoS(dDataBase)+"') AND
cSQL += "			C5_XAVARES <> 'S' AND "  
cSQL += "			C9_FILIAL = C5_FILIAL AND "
cSQL += "			C9_PEDIDO = C5_NUM AND "
cSQL += "			C9_CLIENTE = C5_CLIENTE AND "
cSQL += "			C9_LOJA = C5_LOJACLI AND "
cSQL += "			C9_QTDORI > 0 AND "
cSQL += 			RetSQLName("SC5")+".D_E_L_E_T_ = ' ' AND "
cSQL += 			RetSQLName("SC9")+".D_E_L_E_T_ = ' ' "
cSQL +=	" GROUP BY C5_NUM,C5_OPERADO,C5_CLIENTE,C5_LOJACLI "      
cSQL += " ORDER BY C5_OPERADO, C5_NUM "

cSQL := ChangeQuery(cSQL)
dbUseArea(.T.,"TOPCONN",TCGenQry(,,cSQL),"QRYSC5",.T.,.T.)
    
SC9->(dbSetOrder(1))
SC6->(dbSetOrder(1))
SC5->(dbSetOrder(1))
SB2->(dbSetOrder(1))

While !QRYSC5->(Eof())
	cChave := "Pedido_"+AllTrim(QRYSC5->C5_NUM)
                                                
	If !DipVldApr(QRYSC5->C5_NUM)
		Conout("Pulou o pedido "+QRYSC5->C5_NUM+" Excluindo Reservas....")
		QRYSC5->(dbSkip())                          
		Loop
	EndIf
	
	ConOut("Antes do Lock ... Excluindo Reservas")

	If LockByName(cChave,.T.,.T.)
		ConOut(cEmpAnt+cFilAnt+" "+cChave+" Excluindo Reservas...." )
		If QRYSC5->C5_OPERADO <> cOperado
			If !Empty(cOperado)                                                         
				  
				_cEnvMail := AllTrim(_cEnvMail)+";"+SUPERGETMV("MV_#EMLTI",.F.,"ti@dipromed.com.br") //Somente para perํodo de teste
				//Rafael Moraes Rosa - 28/06/2023 - Linha abaixo adicionada
				_cEnvMail	:= IIF(Empty(SUPERGETMV("MV_#EMLSCH", .F., "")),_cEnvMail,GETMV("MV_#EMLSCH"))

				U_UEnvMail(_cEnvMail,_cAssunto,_aMsg,"",_cFrom,_cFuncSent)      
				
				cMSGcIC := "ATENวรO! RESERVA(S) EXCLUอDA(S)" +CHR(13)+CHR(10)+CHR(13)+CHR(10)
				cMSGcIC += " PEDIDO(S): " + Left(cPedido,Len(cPedido)-1) +CHR(13)+CHR(10)+CHR(13)+CHR(10)
	   				
	 			cCICDest := AllTrim(cCICDest)+",DIEGO.DOMINGOS,MAXIMO.CANUTO" //Somente para perํodo de teste
	   	
				U_DIPCIC(cMSGcIC,cCICDest)
				
				cPedido := ""
				_aMsg 	 := {}
	        EndIf
	
	       	If SU7->(dbSeek(xFilial("SU7")+QRYSC5->C5_OPERADO))
				_cEnvMail := SU7->U7_EMAIL	
				_cNome	  := SU7->U7_NOME	
				cCICDest  := SU7->U7_CICNOME
			EndIf       
		EndIf
	
		aAdd(_aMsg,{"Pedido ",QRYSC5->C5_NUM}) 
		aAdd(_aMsg,{"Data   ",DtoC(dDataBase)}) 
	    aAdd(_aMsg,{"Hora   ",SubStr(Time(),1,2)+":"+SubStr(Time(),4,2)})
	    
	    cPedido += QRYSC5->C5_NUM+"/"
	                                            
		ConOut("Antes da Altera็ใo ... Excluindo Reservas")
			    
	    u_DipAltPed(QRYSC5->C5_NUM,QRYSC5->C5_CLIENTE,QRYSC5->C5_LOJACLI)
	    
   		ConOut("Ap๓s a Altera็ใo ... Excluindo Reservas")
	/*
		If SC9->(dbSeek(xFilial("SC9")+QRYSC5->C5_NUM))
			While !SC9->(Eof()) .And. SC9->C9_PEDIDO==QRYSC5->C5_NUM   		                         
			    If SB2->(dbSeek(xFilial("SB2")+SC9->(C9_PRODUTO+C9_LOCAL)))
			    	SB2->(RecLock("SB2",.F.))
						If SC9->C9_QTDORI > 0                                  
							SB2->B2_RESERVA -= SC9->C9_QTDORI  
							If SC9->C9_QTDLIB2 > 0          
								SB2->B2_RESERV2 -= SC9->C9_QTDLIB2
							EndIf
						EndIf	
						If SC9->C9_SALDO > 0                 
							SB2->B2_QPEDVEN -= SC9->C9_SALDO
							If SC9->C9_QTDLIB2 > 0          
								SB2->B2_QPEDVE2 -= SC9->C9_QTDLIB2
							EndIf
						EndIf         
					SB2->(MsUnLock())
				EndIf
				
				SC9->(RecLock("SC9",.F.))
					SC9->(dbDelete())
				SC9->(MsUnLock())
	
				SC9->(dbSkip())		
			EndDo                         
			
			If SC5->(dbSeek(xFilial("SC5")+QRYSC5->C5_NUM))
				SC5->(RecLock("SC5",.F.))	
					SC5->C5_TIPODIP = '2'
				SC5->(MsUnLock())    
				If SC6->(dbSeek(xFilial("SC6")+QRYSC5->C5_NUM))
					While !SC6->(Eof()) .And. SC6->C6_NUM == QRYSC5->C5_NUM
						SC6->(RecLock("SC6",.F.))	
							SC6->C6_TIPODIP = '2'
						SC6->(MsUnLock())    
						SC6->(dbSkip())
					EndDo				
				EndIf
			EndIf
			                     
		EndIf                    
		*/
   		ConOut("Ap๓s do UnLock ... Excluindo Reservas")

		cOPerado := QRYSC5->C5_OPERADO 
		UnLockByName("Pedido_"+AllTrim(QRYSC5->C5_NUM),.T.,.T.)	

  		ConOut("Depois do UnLock ... Excluindo Reservas")
	EndIf                                                       
	ConOut("Skip ... Excluindo Reservas")
	QRYSC5->(dbSkip())                          
EndDo           
ConOut("CloseArea ... Excluindo Reservas")

QRYSC5->(dbCloseArea())

ConOut(cEmpAnt+cFilAnt+".... Excluindo Reservas...." )

If Len(_aMsg)>0
	//Rafael Moraes Rosa - 28/06/2023 - Linha abaixo adicionada
	_cEnvMail	:= IIF(Empty(SUPERGETMV("MV_#EMLSCH", .F., "")),_cEnvMail,GETMV("MV_#EMLSCH"))

	U_UEnvMail(_cEnvMail,_cAssunto,_aMsg,"",_cFrom,_cFuncSent)      
EndIf

If Len(cPedido)>0
	cMSGcIC := "ATENวรO! RESERVA(S) EXCLUอDA(S)" +CHR(13)+CHR(10)+CHR(13)+CHR(10)
	cMSGcIC += " PEDIDO(S): " + Left(cPedido,Len(cPedido)-1) +CHR(13)+CHR(10)+CHR(13)+CHR(10)
   	
	U_DIPCIC(cMSGcIC,cCICDest)
EndIf 	

ConOut(cEmpAnt+cFilAnt+" "+dtoc(Date())+" "+Time()+" Fim - Excluindo Reservas...." )   

RpcClearEnv()

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDIPRETRES บAutor  ณMicrosiga           บ Data ณ  08/14/15   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function DipAltPed(cNum,cCodCli,cLoja)
Local aAreaSC6 	:= SC6->(GetArea())
Local aCabec 	:= {}   
Local aItens 	:= {}	
Local aLinha 	:= {}		


//Variแveis para controlar o TXT
Local aLogAuto := {}
Local cLogTxt  := ""
Local cArquivo := "\system\DipExcRes-"+cNum+".txt"
Local nAux     := 0
 
//Variแveis de controle do ExecAuto
Private lMSHelpAuto     := .T.
Private lAutoErrNoFile  := .T.
Private lMsErroAuto 	:= .F.  

dbSelectArea("SC5")
SC5->(dbSetOrder(1))
If SC5->(dbSeek(xFilial("SC5")+cNum))

	RegToMemory("SC5",.F.)
                
	aAdd(aCabec,{"C5_NUM"	 ,SC5->C5_NUM    ,nil})
	aAdd(aCabec,{"C5_FILIAL" ,SC5->C5_FILIAL ,nil})
	aAdd(aCabec,{"C5_TIPO"	 ,SC5->C5_TIPO   ,nil})
	aAdd(aCabec,{"C5_CLIENTE",SC5->C5_CLIENTE,nil})
	aAdd(aCabec,{"C5_LOJACLI",SC5->C5_LOJACLI,nil})
	aAdd(aCabec,{"C5_OPERADO",SC5->C5_OPERADO,nil})
	aAdd(aCabec,{"C5_CONDPAG",SC5->C5_CONDPAG,nil})
	aAdd(aCabec,{"C5_TRANSP" ,SC5->C5_TRANSP ,nil})
	aAdd(aCabec,{"C5_TPFRETE",SC5->C5_TPFRETE,nil})
	aAdd(aCabec,{"C5_DIPCOM" ,SC5->C5_DIPCOM ,nil})
	aAdd(aCabec,{"C5_TIPODIP","2"			 ,nil})
	aAdd(aCabec,{"C5_DESTFRE",SC5->C5_DESTFRE,nil})
	aAdd(aCabec,{"C5_QUEMCON",SC5->C5_QUEMCON,nil})
	aAdd(aCabec,{"C5_EMISSAO",SC5->C5_EMISSAO,nil})
	aAdd(aCabec,{"C5_TIPOCLI",SC5->C5_TIPOCLI,nil})

	SC6->(dbSetOrder(1))
	If SC6->(dbSeek(xFilial("SC6")+cNum))      
		While !SC6->(Eof()) .And. SC6->(C6_FILIAL+C6_NUM) == xFilial("SC6")+cNum
			aLinha:={}
			
			aAdd(aLinha,{"LINPOS"	 ,"C6_ITEM",SC6->C6_ITEM})
			aAdd(aLinha,{"C6_PRODUTO",SC6->C6_PRODUTO,nil})
			aAdd(aLinha,{"C6_LOCAL" ,SC6->C6_LOCAL	,nil})
			aAdd(aLinha,{"C6_QTDVEN",SC6->C6_QTDVEN	,nil})
			aAdd(aLinha,{"C6_PRCVEN",SC6->C6_PRCVEN	,nil})
			aAdd(aLinha,{"C6_VALOR" ,SC6->C6_VALOR	,nil})
			aAdd(aLinha,{"C6_TES" 	,SC6->C6_TES	,nil})
			aAdd(aLinha,{"C6_CLI" 	,SC6->C6_CLI	,nil})
			aAdd(aLinha,{"C6_LOJA" 	,SC6->C6_LOJA	,nil})
			aAdd(aLinha,{"C6_TIPODIP","2"			,nil})
			aAdd(aLinha,{"C6_QTDEMP" ,0				,nil})
			aAdd(aLinha,{"C6_SLDEMPE",SC6->C6_QTDVEN,nil})
			aAdd(aLinha,{"C6_QTDORC" ,SC6->C6_QTDVEN,nil})
			aAdd(aLinha,{"C6_BLQ"	 ,"S"			,nil})
			aAdd(aLinha,{"AUTDELETA","N"			,nil})

			aAdd(aItens,aLinha)    
			
			SC6->(dbSkip())
		EndDo				

  		ConOut("Antes Execauto... Excluindo Reservas")			
			
		//MATA410(aCabec,aItens,4)   
		 MSExecAuto({|x,y,z|Mata410(x,y,z)},aCabec,aItens,4)
		   		
   		ConOut(IIf(lMsErroAuto,"Erro Exec","Sem Erro Exec")+" ... Excluindo Reservas")
		
		If lMsErroAuto
			 If (!IsBlind()) // COM INTERFACE GRมFICA
        		MostraErro()
    		Else // EM ESTADO DE JOB

				//Pegando log do ExecAuto
				aLogAuto := GetAutoGRLog()
				
				//Percorrendo o Log e incrementando o texto (para usar o CRLF voc๊ deve usar a include "Protheus.ch")
				For nAux := 1 To Len(aLogAuto)
					cLogTxt += aLogAuto[nAux] + CRLF
				Next
				
				//Criando o arquivo txt
				MemoWrite(cArquivo, cLogTxt)
				ConOut(PadC("Error log exclusao Reserva, analise arquivo DipExcRes.txt na system", 80))
			EndIf
			Return(.F.)
		EndIf                                   
			
	EndIf
EndIf

RestArea(aAreaSC6)

Return       
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDIPRETRES บAutor  ณMicrosiga           บ Data ณ  08/18/15   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Solicita aprova็ใo da reserva do pedido                    บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function DipSolApr()                             
Local _aMsg 	:= {}
Local _cEnvMail := ""
Local _cNome	:= ""
Local _cFrom     := "protheus@dipromed.com.br"
Local _cFuncSent := "DipSolApr(DIPA072)"
Local _cAssunto  := EncodeUTF8("Aguardando aprova็ใo da reserva","cp1252")
Local cCICDest	 := ""  
Local _lOk       := .F.
Local cHora 	 := Time()  
Local _cObsMail	 := ""
Private _cObsRes := Space(255)

_lOk := DipAvaPed(SC5->C5_NUM,SC5->(C5_CLIENTE+C5_LOJACLI))

SU7->(dbSetOrder(1))
If SU7->(dbSeek(xFilial("SU7")+SC5->C5_OPERADO))
	If AllTrim(RetCodUsr())==Alltrim(SU7->U7_CODUSU) .Or. Upper(u_DipUsr())$GetNewPar("ES_DIPSOLR","MORNELLAS/DDOMINGOS/MCANUTO")
		_cNome	  := SU7->U7_NOME	
		
		cCICDest  := AllTrim(SU7->U7_CICNOME)
		cCICDest  += ","+GetNewPar("ES_CICARES","ERICH.PONTOLDIO,PATRICIA.MENDONCA,DIEGO.DOMINGOS,MAXIMO.CANUTO")                                                                
		
		_cEnvMail := AllTrim(SU7->U7_EMAIL)
		_cEnvMail += ";"+GetNewPar("ES_MAIARES","erich.pontoldio@dipromed.com.br;patricia.mendonca@dipromed.com.br,"+SUPERGETMV("MV_#EMLTI",.F.,"ti@dipromed.com.br"))
 		If Aviso("Aten็ใo","Deseja enviar o pedido para aprova็ใo de reserva?",{"Nใo","Sim"},1)==2
			If SC5->C5_XAVARES <> "S"
				If DipObsRes()                            
					_cObsMail:= _cObsRes   					
					
					u_DipGrvObs(_cObsRes,SC5->C5_NUM)
					
					_cObsRes := AllTrim(u_DipUsr())+" - "+AllTrim(DTOC(dDataBase))+" - "+AllTrim(cHora)+": "+CHR(10)+CHR(13)+;
								"|*|"+AllTrim(_cObsRes)+"|*|"+CHR(10)+CHR(13)+;
								Replicate("_",58)+CHR(10)+CHR(13)//+;AllTrim(MSMM(SC5->C5_XOBSRES)) 
					
					SC5->(RecLock("SC5",.F.))
						SC5->C5_XAVARES := "S"       
						//SC5->C5_XOBSRES := _cObsRes  
						//MSMM(,TamSX3("C5_XOBSRES")[1],,_cObsRes,1,,,"SC5","C5_XOBSRES")
					SC5->(MsUnLock())
				
					Aadd(_aMsg,{"Pedido"	,SC5->C5_NUM}) 	
					Aadd(_aMsg,{"Reservado"	,DtoC(SC5->C5_XDATRES)+" ("+SC5->C5_XHORRES+")"}) 	
					Aadd(_aMsg,{"Expira"	,DtoC(SC5->C5_XDATEXP)+" ("+SC5->C5_XHOREXP+")"}) 	
					Aadd(_aMsg,{"Explica็ใo",_cObsMail}) 	
					Aadd(_aMsg,{"Operadora"	,_cNome})

					//Rafael Moraes Rosa - 28/06/2023 - Linha abaixo adicionada
					_cEnvMail	:= IIF(Empty(SUPERGETMV("MV_#EMLSCH", .F., "")),_cEnvMail,GETMV("MV_#EMLSCH"))

					U_UEnvMail(_cEnvMail,_cAssunto,_aMsg,"",_cFrom,_cFuncSent)
					
					cMSGcIC := "ATENวรO! SOLICITACAO DE VALIDAวรO DE RESERVA" +CHR(13)+CHR(10)+CHR(13)+CHR(10)
					cMSGcIC += " PEDIDO: " + SC5->C5_NUM +CHR(13)+CHR(10)+CHR(13)+CHR(10)
					cMSGcIC += " A EXPLICAวรO DA SOLICITAวรO SEGUE NO E-MAIL" +CHR(13)+CHR(10)+CHR(13)+CHR(10)
					cMSGcIC += " OPERADORA: " + _cNome +CHR(13)+CHR(10)+CHR(13)+CHR(10)
					
					U_DIPCIC(cMSGcIC,cCICDest)
						
					Aviso("Aten็ใo","Pedido enviado com sucesso para aprova็ใo.",{"Ok"},1)	
				Else 
					Aviso("Aten็ใo","Solicita็ใo cancelada",{"Ok"},1)
				EndIf
			Else                                                                        
				Aviso("Aten็ใo","Pedido aguardando avalia็ใo.",{"Ok"},1)	
			EndIf
		EndIf
	Else
		Aviso("Aten็ใo",Upper(u_DipUsr())+", voc๊ pode solicitar aprova็ใo somente dos seus pedidos.",{"Ok"},1)
	EndIf		
EndIf
Return                                   
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDIPRETRES บAutor  ณMicrosiga           บ Data ณ  08/18/15   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Solicita aprova็ใo da reserva do pedido                    บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function DipAprRes()                             
Local _aMsg 	:= {}
Local _cEnvMail := ""
Local _cNome	:= ""
Local _cFrom     := "protheus@dipromed.com.br"
Local _cFuncSent := "DipSolApr(DIPA072)"
Local _cAssunto  := EncodeUTF8("Aguardando aprova็ใo da reserva","cp1252")

Private aRotina   := {}
Private cCadastro := "APROVACAO DE RESERVA"
Private aCores    := {}
Private aCampos   := {}

If !Upper(u_DipUsr())$GetNewPar("ES_DIPA072","EPONTOLDIO/PMENDONCA/MCANUTO/DDOMINGOS")
	Aviso("ES_DIPA072","Voc๊ nใo tem acesso para executar esta rotina",{"Ok"},1)
	Return .F.
EndIf

U_DIPPROC(ProcName(0),u_DipUsr())

aAdd(aRotina,{"Avaliar"   ,"U_DipAvaRes", 0 , 2 })
aAdd(aRotina,{"Visualizar","A410Visual" , 0 , 2 }) 
aadd(aRotina,{"Legenda"	  ,"U_DipLegBrw", 0 , 6 })

aAdd(aCores,{"!U_DipStaRes()","BR_VERMELHO" })
aAdd(aCores,{"U_DipStaRes()" ,"BR_VERDE"    })

aAdd(aCampos,{AvSx3("C5_XDATRES",5),"C5_XDATRES"})
aAdd(aCampos,{AvSx3("C5_XHORRES",5),"C5_XHORRES"})
aAdd(aCampos,{AvSx3("C5_XDATEXP",5),"C5_XDATEXP"})
aAdd(aCampos,{AvSx3("C5_XHOREXP",5),"C5_XHOREXP"})

dbSelectArea("SC5")
dbSetOrder(1)
SC5->(dbSetFilter({|| SC5->C5_FILIAL==xFilial("SC5") .And. SC5->C5_XAVARES=='S' },"SC5->C5_FILIAL==xFilial('SC5') .And. SC5->C5_XAVARES=='S'"))
SC5->(dbGoTop())

mBrowse(6,1,22,75,"SC5",aCampos,,,,,aCores)

Return ()
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDIPRETRES บAutor  ณMicrosiga           บ Data ณ  08/18/15   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function DipLegBrw()
local aStatus:={}

aadd(aStatus,{"BR_VERMELHO", "EXPIRADO"    })
aadd(aStatus,{"BR_VERDE"   , "IRม EXPIRAR" })

BrwLegenda(cCadastro, "Status", aStatus)

Return .T.
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDIPRETRES บAutor  ณMicrosiga           บ Data ณ  08/18/15   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function DipStaRes()
Local lRet := .T.

If SC5->C5_XDATEXP <= dDataBase .And. SC5->C5_XHOREXP <= Left(Time(),5)
	lRet := .F.
EndIf      

Return lRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDIPRETRES บAutor  ณMicrosiga           บ Data ณ  08/18/15   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function DipAvaRes()
Local oDlg
Local nLin 		:= 0
Local nCol		:= 0
Local cDescCP  	:= ""          
Local cOperado  := ""      
Local cTransp	:= ""
Local cCliente  := ""
Local nValPed	:= 0
Local cTpFrete  := ""
Local aDados    := {}
Local cNumero   := SC5->C5_NUM
Private oFont24 := TFont():New("Times New Roman",9,24,.T.,.T.,5,.T.,5,.T.,.F.)
Private oFont10 := TFont():New("Arial",6,14,.T.,.T.,5,.T.,5,.T.,.F.)
Private oFont16 := TFont():New("Arial",9,14,.T.,.T.,5,.T.,5,.T.,.F.)
Private oFont30 := TFont():New("Arial",9,28,.T.,.T.,5,.T.,5,.T.,.F.)

If !LockByName("AVALIANDO "+cNumero,.T.,.F.)
	Aviso("Aten็ใo","Nใo foi possํvel obter acesso exclusivo ao pedido: "+cNumero+CHR(13)+CHR(10)+;
					"Tente novmante mais tarde",{"Ok"},1)
	Return
EndIf

SE4->(dbSetOrder(1))
If SE4->(dbSeek(xFilial("SE4")+SC5->C5_CONDPAG))
	cDescCP :=  SE4->E4_DESCRI   
Else
	cDescCP :=  SC5->C5_CONDPAG
EndIf
                    
SU7->(dbSetOrder(1))
If SU7->(dbSeek(xFilial("SU7")+SC5->C5_OPERADO))
	cOperado := SU7->U7_NOME
Else
	cOperado := SC5->C5_OPERADO
EndIf
                                                                
SA4->(dbSetOrder(1))
If SA4->(dbSeek(xFilial("SA4")+SC5->C5_TRANSP))
	cTransp := AllTrim(SA4->A4_NOME)
Else 
	cTransp := AllTrim(SC5->C5_TRANSP)
EndIf                       

cTpFrete := Iif(Alltrim(SC5->C5_TPFRETE)="I","INCLUSO",Iif(Alltrim(SC5->C5_TPFRETE)="C","CIF",Iif(Alltrim(SC5->C5_TPFRETE)="F","FOB",Iif(Alltrim(SC5->C5_TPFRETE)="D","RETIRA","MALOTE"))))      

cTransp+= " ("+cTpFrete+")"

SA1->(dbSetOrder(1))
If SA1->(dbSeek(xFilial("SA1")+SC5->(C5_CLIENTE+C5_LOJACLI)))
	cCliente := AllTrim(SC5->C5_CLIENTE)+" - "+SA1->A1_NOME
Else 
	cCliente := SC5->C5_CLIENTE
EndIf                       

nValPed := DipVlrPed()

DEFINE MSDIALOG oDlg TITLE "APROVAวรO DE RESERVA" FROM 005,005 TO 048,172
      
nLin := 5
nCol := 10

//@ nLin,nCol+150 say "APROVAวรO DE RESERVA"  font oFont30  COLOR CLR_BLACK Pixel

//nLin += 20
@ nLin+5,nCol say "Cliente :..................................."   	font oFont24  COLOR CLR_BLUE Pixel
@ nLin,nCol+110 get alltrim(cCliente)							when .f. font oFont10  COLOR CLR_RED SIZE 250,15 Pixel

nLin += 20
@ nLin+5,nCol say "Pedido :...................................."   	font oFont24  COLOR CLR_BLUE Pixel
@ nLin,nCol+110 get alltrim(SC5->C5_NUM)  						when .f. font oFont16  COLOR CLR_RED SIZE 200,15 Pixel

nLin += 20
@ nLin+5,nCol say "Valor :......................................." 	font oFont24  COLOR CLR_BLUE Pixel
@ nLin,nCol+110 get nValPed	  Picture "@e 9,999,999.99"     	when .f. font oFont16  COLOR CLR_RED SIZE 200,15 Pixel

nLin += 20
@ nLin+5,nCol say "Condi็ใo de Pagamento :......"  					font oFont24  COLOR CLR_BLUE Pixel
@ nLin,nCol+110 get allTrim(cDescCP)							when .f. font oFont16  COLOR CLR_RED SIZE 200,15 Pixel

nLin += 20
@ nLin+5,nCol say "Operador :..............................."  		font oFont24  COLOR CLR_BLUE Pixel
@ nLin,nCol+110 get alltrim(cOperado) 				 			when .f. font oFont16  COLOR CLR_RED SIZE 200,15 Pixel



nLin += 20
@ nLin+5,nCol say "Transportadora :....................."  			font oFont24  COLOR CLR_BLUE Pixel
@ nLin,nCol+110 get cTransp										when .f. font oFont16  COLOR CLR_RED SIZE 200,15 Pixel

/*
nLin += 20
@ nLin+5,nCol say "Frete :......................................."	font oFont24  COLOR CLR_BLUE Pixel
@ nLin,nCol+110 get   when .f.  font oFont16  COLOR CLR_RED SIZE 200,15 Pixel
*/

nLin += 20                                                 

cObsAux := DipRetObs(SC5->C5_NUM)

@ nLin+5,nCol say "Observa็ใo :............................"	font oFont24  COLOR CLR_BLUE Pixel
@ nLin,nCol+110 get SubStr(cObsAux,1,125)			    when .f.  font oFont10  COLOR CLR_RED SIZE 350,15 Pixel

If !Empty(SubStr(cObsAux,126,Len(cObsAux)))
	nLin += 20
	@ nLin,nCol+110 get SubStr(cObsAux,126,Len(cObsAux)) when .f.  font oFont10  COLOR CLR_RED SIZE 350,15 Pixel
EndIf

nLin += 20
cDataRes := DtoC(SC5->C5_XDATRES)+" ("+SC5->C5_XHORRES+")"
@ nLin+5,nCol say "Data da Reserva :...................."		 font oFont24  COLOR CLR_BLUE Pixel
@ nLin,nCol+110 get cDataRes when .f. font oFont16  COLOR CLR_RED SIZE 200,15 Pixel

nLin += 20                                          
cDataExp := DtoC(SC5->C5_XDATEXP)+" ("+SC5->C5_XHOREXP+")"
@ nLin+5,nCol say "Data da Expira็ใo :................"			 font oFont24  COLOR CLR_BLUE Pixel
@ nLin,nCol+110 get cDataExp when .f. font oFont16  COLOR CLR_RED SIZE 200,15 Pixel

dDataNew := SC5->C5_XDATEXP                            
cHoraNew := SC5->C5_XHOREXP                      
lManual := .F.

nLin += 20                      
@ nLin+5,nCol say "Adiar Data para :..................."			 font oFont24  COLOR CLR_RED Pixel
@ nLin,nCol+110 get dDataNew  Picture "@D"		When lManual Valid DipVldExp(@cHoraNew,@dDataNew,SC5->C5_XHOREXP,SC5->C5_XDATEXP) font oFont16  COLOR CLR_RED SIZE 200,15 Pixel

nLin += 20                                                                                     
@ nLin+5,nCol say "Adiar Hora para :.................."			 	 font oFont24  COLOR CLR_RED Pixel
@ nLin,nCol+110 get cHoraNew Picture "99:99"	When lManual Valid DipVldExp(@cHoraNew,@dDataNew,SC5->C5_XHOREXP,SC5->C5_XDATEXP) font oFont16  COLOR CLR_RED SIZE 200,15 Pixel

aDados := DipLoadDad(SC5->C5_NUM)

If Len(aDados) > 0
	@ 005,375 ListBox oList var cList Fields HEADER "Pedido","Item","Explica็ใo","Data","Hora","Usuแrio";
	size 275,115 of oDlg Pixel
	oList:SetArray(aDados)
	oList:bLine := {|| {aDados[oList:nAT,1],aDados[oList:nAT,2],aDados[oList:nAT,3],aDados[oList:nAT,4],aDados[oList:nAT,5],aDados[oList:nAT,6]}}
EndIf

nLin += 20
@ nLin,nCol+110 BUTTON "+1h" 	SIZE 020,020 PIXEL OF oDlg ACTION DipSomHor(.T.,1,@cHoraNew,@dDataNew,SC5->C5_XHOREXP,SC5->C5_XDATEXP)
@ nLin,nCol+135 BUTTON "+5h" 	SIZE 020,020 PIXEL OF oDlg ACTION DipSomHor(.T.,5,@cHoraNew,@dDataNew,SC5->C5_XHOREXP,SC5->C5_XDATEXP)
@ nLin,nCol+160 BUTTON "-5h" 	SIZE 020,020 PIXEL OF oDlg ACTION DipSomHor(.F.,5,@cHoraNew,@dDataNew,SC5->C5_XHOREXP,SC5->C5_XDATEXP)
@ nLin,nCol+185 BUTTON "-1h" 	SIZE 020,020 PIXEL OF oDlg ACTION DipSomHor(.F.,1,@cHoraNew,@dDataNew,SC5->C5_XHOREXP,SC5->C5_XDATEXP)
@ nLin,nCol+210 BUTTON "Manual" SIZE 020,020 PIXEL OF oDlg ACTION (lManual := .T.)
//@ nLin,nCol+210 BUTTON "Teste"  SIZE 020,020 PIXEL OF oDlg ACTION u_DipHisRes() //Linha usada para teste

nLin += 40
@ nLin,nCol+010 say "APROVAR"  	font oFont30  COLOR CLR_GREEN Pixel
@ nLin,nCol+060 say "REPROVAR"  font oFont30  COLOR CLR_RED   Pixel
@ nLin,nCol+120 say "SALDOS" 	font oFont30  COLOR CLR_BLUE  Pixel
@ nLin,nCol+285 say "SAIR"  	font oFont30  COLOR CLR_RED   Pixel

nLin += 15
DEFINE SBUTTON FROM nLin,nCol+010 type 1   ACTION If(DipAprOk(.T.,@cHoraNew,@dDataNew,SC5->C5_XHOREXP,SC5->C5_XDATEXP),oDlg:End(),nil) ENABLE OF oDlg //APROVAR
DEFINE SBUTTON FROM nLin,nCol+060 type 2   ACTION If(DipAprOk(.F.,@cHoraNew,@dDataNew,SC5->C5_XHOREXP,SC5->C5_XDATEXP),oDlg:End(),nil) ENABLE OF oDlg //REPROVAR
DEFINE SBUTTON FROM nLin,nCol+120 type 6   ACTION u_DIPR035A(SC5->C5_NUM) ENABLE OF oDlg //SALDOS
DEFINE SBUTTON FROM nLin,nCol+285 type 2   ACTION oDlg:End() ENABLE OF oDlg		 //SAIR

ACTIVATE DIALOG oDlg  CENTERED

UnLockByName("AVALIANDO "+cNumero,.T.,.F.)

Return     
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDIPRETRES บAutor  ณMicrosiga           บ Data ณ  08/18/15   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function DipSomHor(lSoma,nSoma,cHoraNew,dDataNew,cHoraExp,dDataExp)
Local nHoraAux := Val(Left(cHoraNew,2))
Local dDataAux := dDataNew                 

If lSoma       
	Do Case
		Case nSoma == 1 .And. nHoraAux == 23
			dDataAux += 1
			nHoraAux := 0
		Case nSoma == 5 .And. nHoraAux == 19
			dDataAux += 1
			nHoraAux := 0	
		Case nSoma == 5 .And. nHoraAux == 20
			dDataAux += 1
			nHoraAux := 1
		Case nSoma == 5 .And. nHoraAux == 21
			dDataAux += 1
			nHoraAux := 2
		Case nSoma == 5 .And. nHoraAux == 22
			dDataAux += 1
			nHoraAux := 3
		Case nSoma == 5 .And. nHoraAux == 23
			dDataAux += 1
			nHoraAux := 4
		Case nSoma == 1
			nHoraAux += 1
		Case nSoma == 5
			nHoraAux += 5	
	EndCase
Else                     
	Do Case
		Case nSoma == 1 .And. nHoraAux == 0
			dDataAux -= 1
			nHoraAux := 23
		Case nSoma == 5 .And. nHoraAux == 0
			dDataAux -= 1
			nHoraAux := 19	
		Case nSoma == 5 .And. nHoraAux == 1
			dDataAux -= 1
			nHoraAux := 20	
		Case nSoma == 5 .And. nHoraAux == 2
			dDataAux -= 1
			nHoraAux := 21	
		Case nSoma == 5 .And. nHoraAux == 3
			dDataAux -= 1
			nHoraAux := 22	
		Case nSoma == 5 .And. nHoraAux == 4
			dDataAux -= 1
			nHoraAux := 23													
		Case nSoma == 1
			nHoraAux -= 1
		Case nSoma == 5
			nHoraAux -= 5	
	EndCase
EndIf	                  

If dDataAux <= dDataExp .And. StrZero(nHoraAux,2) < Left(cHoraExp,2)
	Aviso("Aten็ใo","Nใo ้ possํvel informar um valor menor do que o horแrio jแ gravado no pedido.",{"Ok"},1)
Else
	cHoraNew := StrZero(nHoraAux,2)+":"+Right(cHoraNew,2)
    dDataNew := dDataAux
EndIf                   

Return  
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDIPRETRES บAutor  ณMicrosiga           บ Data ณ  08/18/15   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function DipVldExp(cHoraNew,dDataNew,cHoraExp,dDataExp)
Local lRet := .T.

If dDataNew < dDataExp
	Aviso("Aten็ใo","Nใo ้ possํvel informar um valor menor do que o horแrio jแ gravado no pedido.",{"Ok"},1)
	lRet := .F.          
ElseIf dDataNew == dDataExp .And. Left(cHoraNew,2) < Left(cHoraExp,2)
	Aviso("Aten็ใo","Nใo ้ possํvel informar um valor menor do que o horแrio jแ gravado no pedido.",{"Ok"},1)
	lRet := .F.          
EndIf                   

Return lRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDIPRETRES บAutor  ณMicrosiga           บ Data ณ  08/18/15   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function DipVlrPed()
Local cSQL 	 := ""           
Local nValor := 0

cSQL := " SELECT  
cSQL += " 	SUM(C6_PRCVEN*C9_QTDORI) AS 'VALOR' "
cSQL += " 	FROM "
cSQL += 		RetSQLName("SC6") + " SC6 ,"+RetSQLName("SC9")+" SC9 "
cSQL += " 		WHERE 
cSQL += " 			C6_FILIAL  = '"+xFilial("SC6")+"' AND "
cSQL += " 			C6_NUM 	   = '"+SC5->C5_NUM+"' AND "
cSQL += " 			C6_FILIAL  = C9_FILIAL AND "
cSQL += "	 		C6_NUM	   = C9_PEDIDO AND "
cSQL += " 			C6_PRODUTO = C9_PRODUTO AND "
cSQL += " 			C6_ITEM	   = C9_ITEM AND "	
cSQL += " 			C6_CLI 	   = C9_CLIENTE AND "
cSQL += " 			C6_LOJA    = C9_LOJA AND "
cSQL += " 			C9_NFISCAL = ' ' AND "	
cSQL += " 			C9_QTDORI  > 0 AND "	
cSQL += " 			SC9.D_E_L_E_T_ = ' ' AND "
cSQL += " 			SC6.D_E_L_E_T_ = ' ' "

cSQL := ChangeQuery(cSQL)
dbUseArea(.T.,"TOPCONN",TCGenQry(,,cSQL),"QRYSC6",.T.,.T.)

If !QRYSC6->(Eof())
	nValor := QRYSC6->VALOR
EndIf        
QRYSC6->(dbCloseArea())

Return nValor    
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDIPRETRES บAutor  ณMicrosiga           บ Data ณ  08/18/15   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function DipAprOk(lOk,cHoraNew,dDataNew,cHorExp,dDatExp)                                               
Local lRet 		 := .T.
Local _cFrom     := "protheus@dipromed.com.br"
Local _cFuncSent := "DipAprOk(DIPA072)"
Local _cAssunto  := ""
Local _aMsg		 := {}  
Local _cEnvMail  := ""
Local _cNome	 := ""
Local cCICDest   := ""
Local cMSGcIC	 := ""      
Private _cObsRes := Space(255)
DEFAULT lOk 	 := .F.

SU7->(dbSetOrder(1))
If SU7->(dbSeek(xFilial("SU7")+SC5->C5_OPERADO))
	
	cCICDest  := AllTrim(SU7->U7_CICNOME)
	cCICDest  += ","+GetNewPar("ES_CICARES","ERICH.PONTOLDIO,PATRICIA.MENDONCA,DIEGO.DOMINGOS,MAXIMO.CANUTO")                                                                
		
	_cEnvMail := AllTrim(SU7->U7_EMAIL)
	_cEnvMail += ";"+GetNewPar("ES_MAIARES","erich.pontoldio@dipromed.com.br;patricia.mendonca@dipromed.com.br,"+SUPERGETMV("MV_#EMLTI",.F.,"ti@dipromed.com.br"))

	If lOk               
		If dDataNew > dDatExp .Or. (dDataNew==dDatExp .And. cHoraNew > cHorExp)
			If Aviso("Aten็ใo","Confirma a altera็ใo no prazo de expira็ใo da reserva?",{"Nใo","Sim"},1)==2
				SC5->(RecLock("SC5",.F.))
					SC5->C5_XHOREXP := cHoraNew
					SC5->C5_XDATEXP := dDataNew
					SC5->C5_XAVARES := " "
				SC5->(MsUnLock())      
				     
				_cAssunto := EncodeUTF8("ATENวรO - Reserva PRORROGADA","cp1252")
				
				aAdd(_aMsg,{"Pedido ",SC5->C5_NUM}) 
				aAdd(_aMsg,{"Status ","Reserva PRORROGADA"}) 			
				aAdd(_aMsg,{"Data   ",DtoC(dDataNew)}) 
			    aAdd(_aMsg,{"Hora   ",cHoraNew})
				
				cMSGcIC := "ATENวรO! RESERVA PRORROGADA" 	+CHR(13)+CHR(10)+CHR(13)+CHR(10)
				cMSGcIC += " PEDIDO: " 	  + SC5->C5_NUM 	+CHR(13)+CHR(10)+CHR(13)+CHR(10)
				cMSGcIC += " NOVA DATA: " + DtoC(dDataNew) 	+CHR(13)+CHR(10)+CHR(13)+CHR(10)
				cMSGcIC += "      HORA: " + cHoraNew 		+CHR(13)+CHR(10)+CHR(13)+CHR(10)
			Else					
				lRet := .F.
			EndIf
		Else
			Aviso("Aten็ใo","Os parโmetros informados de data e hora estใo incorretos.",{"Ok"},1)
			lRet := .F. 
		EndIf           
	Else                     
		If Aviso("Aten็ใo","Confirma a retirada da solicita็ใo de prorroga็ใo deste pedido?",{"Nใo","Sim"},1)==2
			SC5->(RecLock("SC5",.F.))
				SC5->C5_XAVARES := " "
			SC5->(MsUnLock())      
	
			cMSGcIC := "ATENวรO! Reserva REPROVADA" 			+CHR(13)+CHR(10)+CHR(13)+CHR(10)
			cMSGcIC += " PEDIDO: " 	  + SC5->C5_NUM 			+CHR(13)+CHR(10)+CHR(13)+CHR(10)
			cMSGcIC += "      DATA: " + DtoC(SC5->C5_XDATEXP) 	+CHR(13)+CHR(10)+CHR(13)+CHR(10)
			cMSGcIC += "      HORA: " + SC5->C5_XHOREXP 		+CHR(13)+CHR(10)+CHR(13)+CHR(10)
			
			aAdd(_aMsg,{"Pedido ",SC5->C5_NUM}) 
			aAdd(_aMsg,{"Status ","Reserva REPROVADA"}) 			
			aAdd(_aMsg,{"Data   ",DtoC(SC5->C5_XDATEXP)}) 
		    aAdd(_aMsg,{"Hora   ",SC5->C5_XHOREXP})             
	
		    _cAssunto := EncodeUTF8("ATENวรO - Reserva REPROVADA","cp1252")
			
		Else
		
			lRet := .F.
		EndIf
	EndIf       
	        
	If lRet 
		//_cObsMail := u_DipHisRes()
		If DipObsRes()	
			_cObsMail := _cObsRes	
			
			u_DipGrvObs(_cObsRes,SC5->C5_NUM)
			
		    aAdd(_aMsg,{"Observa็ใo   ",_cObsMail})             
			
			If Len(_aMsg)>0
				//Rafael Moraes Rosa - 28/06/2023 - Linha abaixo adicionada
				_cEnvMail	:= IIF(Empty(SUPERGETMV("MV_#EMLSCH", .F., "")),_cEnvMail,GETMV("MV_#EMLSCH"))

				U_UEnvMail(_cEnvMail,_cAssunto,_aMsg,"",_cFrom,_cFuncSent)      
			EndIf
			If Len(cMSGcIC)>0				   	
				U_DIPCIC(cMSGcIC,cCICDest)
			EndIf   
	
			Aviso("Aten็ใo","Finalizado com sucesso.",{"Ok"},1)
		Else
			lRet := .F.
		EndIf
	EndIf
	
EndIf
	
Return lRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDIPRETRES บAutor  ณMicrosiga           บ Data ณ  08/20/15   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function DipV410()
lRet := !(Type("l410Auto")<>"U" .And. l410Auto)
Return lRet  
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDIPA072   บAutor  ณMicrosiga           บ Data ณ  08/25/15   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function DipObsRes()
Local oDlg           
Local oObs 		
Local aSize 	:= {}
Local aObjects 	:= {}
Local aInfo		:= {}
Local aPosObj	:= {}  
Local lRet 		:= .F.

aObjects := {}

aSize   := MsAdvSize()
aAdd(aObjects, {100, 100, .T., .T.})

aInfo   := {aSize[1], aSize[2], aSize[3], aSize[4], 2, 2}
aPosObj := MsObjSize(aInfo, aObjects)

DEFINE MSDIALOG oDlg TITLE "Observa็ใo" From aSize[7],005 TO aSize[4]-140,aSize[3]-50 OF oMainWnd PIXEL    

	@ 035,010 SAY "Observa็ใo:"    	 					SIZE 100,008 OF oDlg PIXEL
	@ 045,010 MSGET oObs VAR _cObsRes  VALID NaoVazio()	SIZE 250,010 OF oDlg PIXEL  PICTURE "@!"

ACTIVATE MSDIALOG oDlg CENTERED ON INIT (EnchoiceBar(oDlg,{|| lRet:=.T., oDlg:End()},{|| lRet:=.F., oDlg:End()}))
                                                              
Return lRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDIPA072   บAutor  ณMicrosiga           บ Data ณ  08/25/15   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function DipAvaPed(cNum,cChvSA1)
Local lRet := .F.

SA1->(dbSetOrder(1))
If SA1->(dbSeek(xFilial("SA1")+cChvSA1))
	If u_DipRetEst(cNum)
		lRet :=	SC5->C5_TIPODIP == '1' .And.; 
				SC5->C5_TIPO == 'N' .And.; 
				!SA1->A1_GRPVEN$GetNewPar("ES_GRPNEXP","000031") .And.; 
				!SA1->A1_COD$GetNewPar("ES_CLINEXP","")
	EndIf                               
EndIf
				
Return lRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDIPA072   บAutor  ณMicrosiga           บ Data ณ  09/11/15   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function DipVldApr(cPedido)                                             
Local lRet		:= .T.
Local cSQL 		:= ""
DEFAULT cPedido := ""

cSQL := " SELECT "
cSQL += "	ZR_NUMERO "
cSQL += "	FROM "
cSQL += 		RetSQLName("SZR")
cSQL += " 		WHERE 
cSQL += "			ZR_FILIAL = '"+xFilial("SZR")+"' AND "
cSQL += "			ZR_NUMERO = '"+cPedido+"' AND "
cSQL += "			ZR_STATUS = 'AGUARDANDO' AND "
cSQL += "			D_E_L_E_T_ = ' ' "

cSQL := ChangeQuery(cSQL)
dbUseArea(.T.,"TOPCONN",TCGenQry(,,cSQL),"QRYSZR",.T.,.T.)

If !QRYSZR->(Eof())
	lRet := .F.
EndIf		   
QRYSZR->(dbCloseArea())			

Return lRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDIPA072   บAutor  ณMicrosiga           บ Data ณ  09/11/15   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function DipHisRes()
Local cObsRes := ""                                      
Local cMEMO := MSMM(SC5->C5_XOBSRES)
                                    
If Empty(cMEMO)
	cMEMO := "Nใo hแ hist๓rico"
Else
	cMEMO := StrTran(cMEMO,"|*|","")
EndIf	

SetPrvt("oDlg","oMGet1","oMGet2","oSBtn")

oDlg      := MSDialog():New( 088,232,479,635,"oDlg",,,.F.,,,,,,.T.,,,.T. )
oMGet1     := TMultiGet():New( 004,004,{|u| IIf(Pcount()>0,cObsRes:=u,cObsRes)},oDlg,192,088,,,CLR_BLACK,CLR_WHITE,,.T.,"",,,.F.,.F.,.F.,,,.F.,,.T. )    
oMGet2     := TMultiGet():New( 096,004,{|| cMEMO}						 ,oDlg,192,080,,,CLR_BLACK,CLR_WHITE,,.T.,"",,,.F.,.F.,.T.,,,.F.,,.T. )    
oSBtn     := SButton():New( 180,168,1,{|| (u_DipGrvObs(cObsRes,SC5->C5_NUM),oDlg:End()) },oDlg,,"", )

oDlg:Activate(,,,.T.)

Return cObsRes          
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDIPA072   บAutor  ณMicrosiga           บ Data ณ  10/07/15   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function DipGrvObs(cObsRes,cPedido) 
Local cSQL := ""

cSQL := " SELECT "
cSQL += " 	MAX(ZZT_ITEM) ZZT_ITEM "
cSQL += " 	FROM "
cSQL +=  		RetSQLName("ZZT")
cSQL += " 		WHERE "
cSQL += " 			ZZT_FILIAL = '"+xFilial("ZZT")+"' AND "
cSQL += " 			ZZT_PEDIDO = '"+cPedido+"' AND "
cSQL += " 			D_E_L_E_T_ = ' ' "
       
cSQL := ChangeQuery(cSQL)
dbUseArea(.T.,"TOPCONN",TCGenQry(,,cSQL),"QRYZZT",.T.,.T.)


If !QRYZZT->(Eof())			
	cItem := Soma1(QRYZZT->ZZT_ITEM)
Else
	cItem := "001"
EndIf                                 
QRYZZT->(dbCloseArea())

ZZT->(RecLock("ZZT",.T.))
	ZZT->ZZT_FILIAL := xFilial("ZZT")
	ZZT->ZZT_PEDIDO := cPedido
	ZZT->ZZT_ITEM 	:= cItem
	ZZT->ZZT_EXPLIC := cObsRes
	ZZT->ZZT_DATA 	:= Date()
	ZZT->ZZT_HORA 	:= Left(Time(),5)
	ZZT->ZZT_USUARI := Upper(u_DipUsr())
ZZT->(MsUnLock())
	
Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDIPA072   บAutor  ณMicrosiga           บ Data ณ  11/29/16   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function DipRetObs(cPedido)
Local cSQL 	  := ""
Local cObsRet := ""

cSQL := " SELECT "
cSQL += " 	TOP 1 ZZT_EXPLIC "
cSQL += " 	FROM "
cSQL +=  		RetSQLName("ZZT")
cSQL += " 		WHERE "
cSQL += " 			ZZT_FILIAL = '"+xFilial("ZZT")+"' AND "
cSQL += " 			ZZT_PEDIDO = '"+cPedido+"' AND "
cSQL += " 			D_E_L_E_T_ = ' ' "
cSQL += " ORDER BY R_E_C_N_O_ DESC "
       
cSQL := ChangeQuery(cSQL)
dbUseArea(.T.,"TOPCONN",TCGenQry(,,cSQL),"QRYEXP",.T.,.T.)


If !QRYEXP->(Eof())	 
	cObsRet := QRYEXP->ZZT_EXPLIC
EndIf		
QRYEXP->(dbCloseArea())

Return cObsRet    
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDIPA072   บAutor  ณMicrosiga           บ Data ณ  11/29/16   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function DipLoadDad(cPedido)
Local aDadRet := {}
Local cSQL := ""

cSQL := " SELECT "
cSQL += " 	* "
cSQL += " 	FROM "
cSQL +=  		RetSQLName("ZZT")
cSQL += " 		WHERE "
cSQL += " 			ZZT_FILIAL = '"+xFilial("ZZT")+"' AND "
cSQL += " 			ZZT_PEDIDO = '"+cPedido+"' AND "
cSQL += " 			D_E_L_E_T_ = ' ' "
cSQL += " ORDER BY ZZT_ITEM "
       
cSQL := ChangeQuery(cSQL)
dbUseArea(.T.,"TOPCONN",TCGenQry(,,cSQL),"QRYLOAD",.T.,.T.)

While !QRYLOAD->(Eof())                               
	aAdd(aDadRet,{QRYLOAD->ZZT_PEDIDO,QRYLOAD->ZZT_ITEM,QRYLOAD->ZZT_EXPLIC,QRYLOAD->ZZT_DATA,QRYLOAD->ZZT_HORA,QRYLOAD->ZZT_USUARI})
	QRYLOAD->(dbSkip())
EndDo
QRYLOAD->(dbCloseArea())

Return aDadRet

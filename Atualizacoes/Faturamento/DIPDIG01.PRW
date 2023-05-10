#Include "RwMake.ch"
#Include "PROTHEUS.CH"
#Include "RWMAKE.CH"
#Include "MSOLE.CH"
#INCLUDE "AP5MAIL.CH"
#INCLUDE "COLORS.CH"
#DEFINE CR    chr(13)+chr(10)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DIPDIG01  ºAutor  ³Microsiga           º Data ³  10/24/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³  condicao de pagto conforme valor do pedido.               º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                          		          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function DIPDIG01(aSaldo,cExpBlo,cOrig)
Local _xAlias         := GetArea()
Local _cAliasSC5      := SC5->(GetArea())
Local _cAliasSZR      := SZR->(GetArea())      
Local _lRetAux		  := .F.        
Local _lVld			  := .F.
Local lTemAprVlr	  := .F.      
Local lTemVlrInf  	  := .F.
Local lConsig		  := .T.
Local _cPosto         := alltrim(Posicione("SU7",1,xFilial("SU7") + SC5->C5_OPERADO, "U7_POSTO") )
Local _cVendExt       := alltrim(Posicione("SU7",1,xFilial("SU7") + SC5->C5_OPERADO, "U7_CODVEN") )
Private lRejeitou	  := .F.
Private _lAtuEst	  := .F.
Private lSolApr		  := .F.
Private cSQL          := ""
Private _cQry1        := ""
Private nCont         := 0
Private _lRet         := .F.
Private _lQWt         := .F.
Private _cNopassword  := "" //GetMV("MV_NOPASSW")
Private _cExpBloAux	  := ""
Private cOri          := ""         
DEFAULT cExpBlo		  := ""
DEFAULT cOrig         := ""

If !Empty(cOrig)
	cOri := cOrig 
EndIf

_cExpBloAux := cExpBlo

//Tratamento para não solicitar senha para usuários informado no parâmetro MV_NOPASSW
If Upper(AllTrim(u_DipUsr())) $ _cNopassword
	Return(.T.)
Endif                  

_lAtuEst := DipAtuEst(SC5->C5_NUM)
         
If !Empty(SC5->C5_XSTATUS)
	DipVldApr(SC5->C5_NUM)
EndIf

If (cEmpAnt == "04" .And. _cPosto == "03") .Or. (cEmpAnt == "04" .And. Empty(_cVendExt))    
	Return(.T.)
EndIf 

If !( "DIPAL10" $ FUNNAME() )
	
	
	If cOri == "A"
		u_DipVLMeno(aSaldo)
	EndIf
		
	DbSelectArea("SZR")
	If Empty(SC5->C5_XSTATUS)		
		If DipTemVld(nil,@lTemAprVlr,@lTemVlrInf,@lConsig) 
			u_DipVLMeno(aSaldo)
		EndIf

		If !lRejeitou .And. !lConsig
			u_DipCDPgto(aSaldo,,lTemAprVlr,lTemVlrInf)	
		EndIf 

		If lConsig
			_lQWt := .T.
		EndIf

		return(_lQWt)
	EndIf

	If !Empty(SC5->C5_XSTATUS)
	
		cSQL := DipRetQry()
		
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),'TMP1',.T.,.F.)
		
		TCSETFIELD('TMP1',"VALOR","N",17,4)     
			
		While TMP1->(!EOF())
			If nCont = 0
				nCont:= nCont+1
				_cQry1 :=" SELECT   "
				_cQry1 +=" ZR_FILIAL   AS 'FILIAL', "
				_cQry1 +=" ZR_NUMERO   AS 'NUMERO', "
				_cQry1 +=" ZR_ORIGEM   AS 'ORIGEM', "
				_cQry1 +=" ZR_CONDPAG  AS 'CONDPAG', "
				_cQry1 +=" ZR_OPERADO  AS 'OPERADO', "
				_cQry1 +=" ZR_STATUS   AS 'ZR_STATUS', "
				_cQry1 +=" ZR_DTSOLIC   AS 'ZR_DTSOLIC', "
				_cQry1 +=" ZR_VALOR    AS 'VALOR' "
				_cQry1 +="	FROM "+RetSqlname("SZR")
				_cQry1 +=" WHERE ZR_FILIAL  = '"+SC5->C5_FILIAL+"' "
				_cQry1 +=" AND   ZR_NUMERO  = '"+SC5->C5_NUM+"' "
				_cQry1 +=" AND "+RetSqlname("SZR")+".D_E_L_E_T_ = ' '  "
				
				_cQry1 := ChangeQuery(_cQry1)
				dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQry1),'TMP2',.T.,.F.)    
				
				If TMP2->(Eof())
					DipBlqPed("NULL")
					
					If DipTemVld(nil,@lTemAprVlr,@lTemVlrInf,@lConsig)
						_lRetAux := u_DipVLMeno(aSaldo)						
					Else
						_lRetAux := .T.
			        EndIf   
			           
					If !lRejeitou .And. !lConsig
	   					_lRet := u_DipCDPgto(aSaldo,,lTemAprVlr,lTemVlrInf) 					
					ElseIf lConsig
						_lRet := .T.
					Else
						_lRet := .F.
					EndIf           
					
					_lRet := _lRet .And. _lRetAux             				
				Else
					While !TMP2->(Eof())					    
						If AllTrim(SC5->C5_CONDPAG) == AllTrim(TMP2->CONDPAG) .And. AllTrim(cValToChar(Round(TMP1->VALOR+SC5->(C5_FRETE+C5_DESPESA),2)))==AllTrim(cValToChar(Round(TMP2->VALOR,2)))
							If AllTrim(TMP2->ZR_STATUS) == "APROVADO"
								//Rafael Moraes Rosa - 02/02/2023 - LINHA COMENTADA - INICIO
								
								u_DipDigDel(SC5->C5_NUM,.T.)
								_lRet := .T.		
								Aviso("Atenção","Seu Pedido Esta Aprovado. ",{"OK"},1)
		
								//Rafael Moraes Rosa - 02/02/2023 - LINHA COMENTADA - FIM

								//Rafael Moraes Rosa - 02/02/2023 - LINHA SUBSTITUIDA - INICIO
								/*
								IF U_VldDtAprov(xFilial("SC5"),SC5->C5_NUM) = DATE() //Rafael Moraes Rosa - 09/02/2023 - CONDICAO AJUSTADA
									u_DipDigDel(SC5->C5_NUM,.T.)
									_lRet := .T.		
									Aviso("Atenção","Seu Pedido Esta Aprovado. ",{"OK"},1)
								ELSE

									IF Aviso("Atenção","Divergencia na data de aprovacao. Deseja continuar?",{"Sim","Não"},1)==1
									
										DipBlqPed()
										
										If DipTemVld(nil,@lTemAprVlr,@lTemVlrInf,@lConsig)
											_lRetAux := u_DipVLMeno(aSaldo)										
										Else

											//_lRetAux := .T. //Rafael Moraes Rosa - 09/02/2023 - LINHA COMENTADA

											//Rafael Moraes Rosa - 09/02/2023 - LINHA SUBSTITUIDA - INICIO
											IF U_VldDtAprov(xFilial("SC5"),SC5->C5_NUM) = DATE()
												_lRetAux := .T.
											ELSE
												_lRetAux := .F.
											ENDIF
											//Rafael Moraes Rosa - 09/02/2023 - LINHA SUBSTITUIDA - FIM
										EndIf   	 
																			
										If !lRejeitou .And. !lConsig
											_lRet := u_DipCDPgto(aSaldo,,lTemAprVlr,lTemVlrInf) 										
										ElseIf lConsig
											_lRet := .T.
										Else 
											_lRet := .F.
										EndIf

										IF !_lRetAux
											DipBlqPed("NULL")
										ENDIF

										_lRet := _lRet .And. _lRetAux
									Else                 									
										DipBlqPed("NULL")										
										_lRet := .F.
									EndIf
								ENDIF
								*/
								//Rafael Moraes Rosa - 02/02/2023 - LINHA SUBSTITUIDA - FIM

							ElseIf AllTrim(TMP2->ORIGEM)=="VAL" .And. !DipTemVld(nil,@lTemAprVlr,@lTemVlrInf,@lConsig) 
								u_DipDigDel(SC5->C5_NUM,.T.)
								_lRet := .T.				
							ElseIf AllTrim(TMP2->ZR_STATUS) == "REPROVADO"
								If Aviso("Atenção","Seu Pedido Foi Reprovado. Deseja Reenviar a Solicitação?",{"Sim","Não"},1)==1
									DipBlqPed()
									
									If DipTemVld(nil,@lTemAprVlr,@lTemVlrInf,@lConsig)
										_lRetAux := u_DipVLMeno(aSaldo)										
									Else
										_lRetAux := .T.
							        EndIf   	 
							        									
							        If !lRejeitou .And. !lConsig
							        	_lRet := u_DipCDPgto(aSaldo,,lTemAprVlr,lTemVlrInf) 										
									ElseIf lConsig
										_lRet := .T.
							        Else 
							        	_lRet := .F.
							        EndIf
									_lRet := _lRet .And. _lRetAux
								Else                 									
									DipBlqPed("NULL")										
									_lRet := .F.
								EndIf
							EndIf							
						Else
				  			Aviso("Atenção","O pedido foi alterado (valor ou condição de pagamento). Será avaliada a necessidade de uma nova aprovaão",{"Ok"},1)	
				  			
							DipBlqPed("NULL")  
							
							If DipTemVld(nil,@lTemAprVlr,@lTemVlrInf,@lConsig)
								_lRetAux := u_DipVLMeno(aSaldo)							
					  		Else
					  	   		_lRetAux := .T.
					  		EndIf          
					  		                        
					  		If !lRejeitou .And. !lConsig
								_lRet := u_DipCDPgto(aSaldo,,lTemAprVlr,lTemVlrInf) 
							ElseIf lConsig
								_lRet := .T.
						  	Else 
						  		_lRet := .F.
						  	EndIf
					  						
							_lRet := _lRet .And. _lRetAux    
						EndIf
						TMP2->(DbSkip())     
					EndDo
				EndIf
				TMP2->(DbCloseArea())					
			Else
				Aviso("Atenção","Problema na aprovação digital. Avise o T.I.",{"Ok"},1)
			EndIf
			TMP1->(DbSkip())
		EndDo
		TMP1->(DbCloseArea())
	EndIf
	SZR->(DbCloseArea())
	RestArea(_cAliasSZR)
	RestArea(_cAliasSC5)
	RestArea(_xAlias)
EndIF
return(_lRet)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DIPDIG01  ºAutor  ³Microsiga           º Data ³  10/24/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function DipCDPgto(aSaldo,lCheck,lTemAprVlr,lTemVlrInf)
Local _xAlias         := GetArea()
Local cSQL	          := ""
Local _OperLicita     := GetMV("MV_OPERLIC")
Local _cCliEspecial   := GetMV("MV_CLIESPE") //Cliente especial
Local cMsgOper        := ""
Local aMsg            :={}
Local cPost           := alltrim(Posicione("SU7",1,xFilial("SU7") + SC5->C5_OPERADO, "U7_POSTO") )
Local cTiMail         := EncodeUTF8("SOLICITAÇÃO DE APROVAÇÃO","cp1252")
Local cEmail          := ""
Local cDe             := Lower(Alltrim(Posicione("SU7",1,xFilial("SU7")+SC5->C5_OPERADO,"U7_EMAIL")))
Local cCicDe          := ""
Local cMail           := ""
Local _lCPInf		  := .T.
Private _nValor       := 0
DEFAULT lTemAprVlr	  := .F.
DEFAULT lTemVlrInf	  := .F.

cSQL := DipRetQry()
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),'TMP3',.T.,.F.)

TCSETFIELD('TMP3',"VALOR","N",17,4)     

TMP3->(dbgotop())
If !EMPTY ("TMP3")
	DbSelectArea("TMP3")
	TMP3->(DbGoTop())
	While TMP3->(!EOF())
		
		_nValor:= TMP3->VALOR
		TMP3->(DbSkip())
	End
	TMP3->(DbCloseArea())
	_mod := "FAT"
	If !EMPTY(SC5->C5_CONDPAG)
		_lQWt := .t.
		_nValor += SC5->C5_FRETE + SC5->C5_DESPESA
	EndIf               
	
	SE4->(dbSetOrder(1))
	If SE4->(dbSeek(xFilial("SE4")+SC5->C5_CONDPAG))
		If lTemVlrInf .And. !Empty(SC5->C5_XCPGINF) .And. !(("VISTA"$SE4->E4_DESCRI) .OR. ("354"$SE4->E4_CODIGO))
			If !(_lQWt:=(SC5->C5_CONDPAG==SC5->C5_XCPGINF))
				If lCheck
					Return(.F.)
				EndIf          
			
				If Aviso("CONDIÇÃO DE PAGAMENTO","Condição de pagamento informada não é igual a condição sugerida ("+AllTrim(SC5->C5_XCPGINF)+"). Deseja solicitar aprovação?",{"Sim","Não"},1)==1
					
					GrvKardex(SC5->C5_NUM,"Sim")
					
					cMsgOper :=	DipComet("PAG") //tela de apresentação do comentario na finalização do pedido					
					
					u_DipDigDel(SC5->C5_NUM)
					
					u_DipGrvApr("PAG",_nValor,cMsgOper,lTemAprVlr)
                    
					DipBlqPed("AGUARDANDO")

					U_DipUSerMAIL(cPost,cMsgOper)	
					
				Else                
					GrvKardex(SC5->C5_NUM,"Não")
					
					DipBlqPed("NULL")
				EndIf
			EndIf			
		Else						
			If SC5->C5_CONDPAG == '167' .and. SC5->C5_OPERADO $ _OperLicita // Buscando no parâmetro os operadores de Licitação
				_lQWt := .t.
			//INCLUSAO DA REGRA DE COND PAG INFORMADA - FELIPE DURAN 15/05/2020
			ElseIf U_CondApr(SC5->C5_FILIAL,SC5->C5_NUM,SC5->C5_CONDPAG) .and. SC5->C5_CONDPAG=='016' .And. !u_VldConInf()
							If (lTemAprVlr .Or. Aviso("CONDIÇÃO DE PAGAMENTO","Pedido Necessita de Aprovação (CONDIÇÃO DE PAGAMENTO). Deseja solicitar aprovação?",{"Sim","Não"},1)==1)  

								GrvKardex(SC5->C5_NUM,"Sim")
								
								cMsgOper :=	DipComet("PAG")							
								           
								u_DipDigDel(SC5->C5_NUM)
								
								u_DipGrvApr("PAG",_nValor,cMsgOper,lTemAprVlr)
										                    
								DipBlqPed("AGUARDANDO")												
		
								U_DipUSerMAIL(cPost,cMsgOper)
							Else                
								GrvKardex(SC5->C5_NUM,"Não")
								
								DipBlqPed("NULL")
							EndIf
							_lQWt := .F.
//INCLUSAO DA REGRA DE COND PAG INFORMADA - FIM
			ElseIf (_nValor-SC5->C5_FRETE) >= SE4->E4_INFER .and. (_nValor-SC5->C5_FRETE) <= SE4->E4_SUPER  .and.;
				(Empty(SE4->E4_SEGMENT) .OR.;
				(!Empty(SE4->E4_SEGMENT).AND. AllTrim(SA1->A1_SATIV1) $ SE4->E4_SEGMENT))  // verifica se condição está atrelada a segmento
				_lQWt := .t.
			ElseIf SC5->C5_CONDPAG == SA1->A1_COND .And. !SC5->C5_CONDPAG$GetNewPar("ES_EXCECPG","") // Caso a condição de pagamento do pedido seja a mesma do cadastro do cliente não pede senha
				_lQWt := .t.
			ElseIf SC5->C5_TIPODIP $ "2/3" // SE FOR ORÇAMENTO OU PROGRAMAÇÃO NÃO PEDE SENHA
				_lQWt := .t.
			ElseIf SC5->C5_CONDPAG=='016' .And. u_VldConInf()	
				_lQwt := .t.                              
			ElseIf !((_nValor-SC5->C5_FRETE) >= SE4->E4_INFER .and. (_nValor-SC5->C5_FRETE) <= SE4->E4_SUPER)
				
				If (Type("l410Auto") == "U" .OR. !l410Auto)
					_lQWt := .f.      
					If SC5->C5_FRETE > 0
						Aviso("Atenção","A partir do dia 06/06/2016 o frete não será mais considerado no cálculo do valor mínimo do pedido.",{"Ok"},1)
					EndIf
					If if(_Mod == 'TMK', !SUA->UA_CLIENTE $ _cCliEspecial,;
						SC5->C5_TIPO == 'N'.AND.!SC5->C5_CLIENTE $ _cCliEspecial)
		
						If lCheck
							Return(.F.)
						EndIf          
						
						//SaldPed(aSaldo)
						//AJUSTAR APROVACAO DA CONDICAO DE PAGAMENTO - BORGES - 18/10/2018
						If U_CondApr(SC5->C5_FILIAL,SC5->C5_NUM,SC5->C5_CONDPAG)
							If (lTemAprVlr .Or. Aviso("CONDIÇÃO DE PAGAMENTO","Pedido Necessita de Aprovação (CONDIÇÃO DE PAGAMENTO). Deseja solicitar aprovação?",{"Sim","Não"},1)==1)  
								
								GrvKardex(SC5->C5_NUM,"Sim")
								
								cMsgOper :=	DipComet("PAG") //tela de apresentação do comentario na finalização do pedido							
								           
								u_DipDigDel(SC5->C5_NUM)
								
								u_DipGrvApr("PAG",_nValor,cMsgOper,lTemAprVlr)
										                    
								DipBlqPed("AGUARDANDO")												
		
								U_DipUSerMAIL(cPost,cMsgOper)								
							Else                
								GrvKardex(SC5->C5_NUM,"Não")
								
								DipBlqPed("NULL")
							EndIf
							_lQWt := .F.
						Else
							_lQWt := .T.						
						EndIf	
					Else
						_lQWt := .T.
					Endif
				EndIf
			EndIf
		EndIf
	Else
		Aviso("Atenção","Condição de pagamento não encontrada.",{"Ok"},1)
		DipBlqPed("NULL")
		_lQWt := .F.	
	EndIF
EndIF

If _lQWt .And. lTemAprVlr
	_lQWt := .F.
EndIf

RestArea(_xAlias)
Return(_lQWt) 
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DIPDIG01  ºAutor  ³Microsiga           º Data ³  10/24/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function DipVLMeno(aSaldo)
Local _xAlias         := GetArea()
Local cSQL	          := ""
Local _OperLicita     := GetMV("MV_OPERLIC")
Local _cCliEspecial   := GetMV("MV_CLIESPE") //Cliente especial
Local cMsgOper        := ""
Local aMsg            :={}
Local cPost           := alltrim(Posicione("SU7",1,xFilial("SU7") + SC5->C5_OPERADO, "U7_POSTO") )
Local cTiMail         := EncodeUTF8("SOLICITAÇÃO DE APROVAÇÃO","cp1252")
Local cEmail          := ""
Local cDe             := Lower(Alltrim(Posicione("SU7",1,xFilial("SU7")+SC5->C5_OPERADO,"U7_EMAIL")))
Local cCicDe          := ""
Local cMail           := ""
Local cAviso          := ""
Private _nValor       := 0

If cOri == "A"
	cTiMail := EncodeUTF8("AVALIAÇÃO DE ORÇAMENTO","cp1252")
EndIf

cSQL := DipRetQry()	   
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),'TMP3',.T.,.F.)

TCSETFIELD('TMP3',"VALOR","N",17,4)     

While TMP3->(!Eof())
	_nValor += TMP3->VALOR
	TMP3->(DbSkip())
EndDo
TMP3->(DbCloseArea())	       
	
If !Empty(SC5->C5_CONDPAG)
	_nValor += SC5->C5_FRETE + SC5->C5_DESPESA
EndIf

_lQWt := .T.

If (Type("l410Auto") == "U" .Or. !l410Auto)				
	If SC5->C5_TIPO == 'N' .And. !SC5->C5_CLIENTE $ _cCliEspecial				

If cOri <> "A"
	cAviso := "Pedido Necessita de Aprovação (VALOR DO ITEM). Deseja solicitar aprovação?" //Rafael Moraes Rosa - 09/02/2023 - LINHA COMENTADA
Else
	cAviso := "Pedido para avaliação dos itens. Deseja solicitar avaliação?."
EndIf		
		
		If Aviso("Solicitação de Aprovação",cAviso,{"Sim","Não"},1)==1
			cMsgOper :=	DipComet("VAL") //tela de apresentação do comentario na finalização do pedido

			GrvKardex(SC5->C5_NUM,"Sim")
			           
			u_DipDigDel(SC5->C5_NUM)
			
			If cOri <> "A"
				u_DipGrvApr("VAL",_nValor,cMsgOper)
			Else
				u_DipGrvApr("AVA",_nValor,cMsgOper)			
			EndIf	
				
			DipBlqPed("AGUARDANDO")

			U_DipUSerMAIL(cPost,cMsgOper)
		Else
			GrvKardex(SC5->C5_NUM,"Não")			
			
			lRejeitou := .T.                            
			
			DipBlqPed("NULL")
		EndIf				
		_lQWt := .F.
	Endif
EndIf

RestArea(_xAlias)
Return(_lQWt)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DIPDIG01  ºAutor  ³Microsiga           º Data ³  10/24/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function DipComet(cTipo)
Private _xAlias  	:= GetArea()
Private  lSaida     := .f.
Private cGetProd    := Space(200)
Private oDlg
Private oFont24  	:= TFont():New("Times New Roman",9,24,.T.,.T.,5,.T.,5,.T.,.F.)
Private oFont16  	:= TFont():New("Arial",9,14,.T.,.T.,5,.T.,5,.T.,.F.)
Private oFont25  	:= TFont():New("Arial",9,24,.T.,.T.,5,.T.,5,.T.,.F.)
Private oFont30  	:= TFont():New("Arial",9,28,.T.,.T.,5,.T.,5,.T.,.F.)
Private nOpcao      := 0
Private nLim        := 0
Private nColu       := 0
Private lALTEND     := .f.

Do While !lSaida
	Define msDialog oDlg Title "APROVAÇÃO DIGITAL" From 10,10 TO 30,120	
		@ 002,002  tO 010,053
		If cTipo == "PAG"	
			@ 005 ,150 say "Aprovação de Condição de Pagamento"  font oFont30  COLOR CLR_BLACK Pixel
			@ 037 ,030 say "Este Pedido ira gerar uma solicitação de aprovação para a condição de pagamento digitada."  font oFont25  COLOR CLR_BLUE Pixel
			@ 065 ,030 say "Comente a necessidade desta condição de pagamento para o aprovador desta solicitação."  font oFont25  COLOR CLR_BLUE Pixel
		Else 
			@ 005 ,150 say "Aprovação de Valor a Menor"  font oFont30  COLOR CLR_BLACK Pixel
			@ 037 ,030 say "Este Pedido ira gerar uma solicitação de aprovação para valor a menor informado nos itens do pedido."  font oFont25  COLOR CLR_BLUE Pixel
			@ 065 ,030 say "Comente a necessidade da alteração do valor para o aprovador desta solicitação."  font oFont25  COLOR CLR_BLUE Pixel
		EndIf
	
		@ 080 ,030 get cGetProd  when .t. Valid !Empty(cGetProd)	Size 380,20  font oFont24  COLOR CLR_RED Pixel
		@ 109 ,188 say "ENVIAR"  font oFont25  COLOR CLR_GREEN Pixel
		DEFINE SBUTTON FROM 120 ,190 TYPE 1 ACTION Ok(cGetProd)  ENABLE OF oDlg
	Activate dialog oDlg centered
Enddo
RestArea(_xAlias)
Return(cGetProd)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DIPDIG01  ºAutor  ³Microsiga           º Data ³  10/24/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Ok(cExp_Mov)
If Len(AllTrim(cExp_Mov)) > 25
	nOpcao:=1
	oDlg:End()
	lSaida := .t.
Else
	Aviso("Atenção","Comentario inválido, comente com mais detalhes !!!",{"Ok"},1)
	lSaida := .f.
EndIf
Return()
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DIPDIG01  ºAutor  ³Microsiga           º Data ³  10/24/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function DigCic(cMail,cCicDe,nOpcao,cComent)
Local cServidor   := GetMV("MV_CIC")     // Servidor para enviar mensagem pelo CIC
Local cOpFatRem   := GetMV("MV_REMETCI") // Usuario do CIC remetente de mensgens no Protheus
Local cOpFatSenha := "123456"
Local cOpFatDest  := cCicDe
DEFAULT nOpcao 	  := 0
DEFAULT cComent	  := ""

If	nOpcao = 1
	cMail += "Foi APROVADO "+CR+CR
	cMail += cComent+CR+CR
	cMail += AllTrim(u_DipUsr())
ElseIf	nOpcao = 2
	cMail += "Foi REPROVADO "+CR+CR
	cMail += cComent+CR+CR
	cMail += AllTrim(u_DipUsr())
ElseIf	nOpcao = 3
	cMail += "Esta em AVALIAÇÃO pelo Aprovador "+CR+CR
	cMail += cComent+CR+CR
	cMail += AllTrim(u_DipUsr())
EndIf

// Envia a mensagem ao operador através do CIC

//WaitRun(cServidor+' '+cOpFatRem+' '+cOpFatSenha+' "'+AllTrim(cOpFatDest)+'" "'+cMail+'" ')
U_DIPCIC(cMail,AllTrim(cOpFatDest))

Return()
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DIPDIG01  ºAutor  ³Microsiga           º Data ³  10/24/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function SaldPed(_aUx)//tela padrao par mostrar o saldo
Private aArea := GetArea()
Private _cAliasSC5      := SC5->(GetArea())
Private aBoxParam   := {}
Private aRetParam   := {}
Private aSize       := {}
Private aInfo       := {}
Private aObjects    := {}
Private aPosObj     := {}
Private aSaldo      := _aUx
Private oDlg
Private oSaldo
Private cSaldo
Private lSaida      := .F.


If len(aSaldo)>0
	
	aSize    := {0,0,316,155,700,350,136}
	aInfo    := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ] , 1, 1 }
	
	aAdd( aObjects, { 100, 085, .T., .T., .T.} )
	aAdd( aObjects, { 100, 015, .T., .T., .T.} )
	aPosObj := MsObjSize( aInfo, aObjects , .T. )
	
	While !lSaida
		
		DEFINE MSDIALOG oDlg TITLE OemToAnsi("Pedido: " + SC5->C5_NUM + " - Produtos com Saldo.") FROM 0,0 TO aSize[6],aSize[5]  OF oMainWnd PIXEL
		@ aPosObj[1,1],aPosObj[1,2] LISTBOX oSaldo VAR cSaldo FIELDS ;
		HEADER  	"Item",;
		"Produto",;
		"Descricao",;
		"Qtd.Vendida",;
		"Qtd.Liberada",;
		"Saldo",;
		"Estoque",;
		SIZE aPosObj[1,3],aPosObj[1,4] NOSCROLL OF oDlg PIXEL
		
		oSaldo:Align:= CONTROL_ALIGN_ALLCLIENT
		oSaldo:SetArray(aSaldo)
		oSaldo:bLine := { || {	aSaldo[oSaldo:nAT,1] 	,;
		aSaldo[oSaldo:nAT,2]	,;
		aSaldo[oSaldo:nAT,3]	,;
		Transform(aSaldo[oSaldo:nAT,4],"@E 999999999")	,;
		Transform(aSaldo[oSaldo:nAT,5],"@E 999999999")	,;
		Transform(aSaldo[oSaldo:nAT,6],"@E 999999999")	,;
		Transform(aSaldo[oSaldo:nAT,7],"@E 999999999")}}
		
		
		oScro1 := TScrollBox():New( oDlg, aPosObj[2,1], aPosObj[2,2],aPosObj[2,4], aPosObj[2,3], .T., .T., .T.)
		oScro1:Align:= CONTROL_ALIGN_BOTTOM
		
		//If !_lTravouB2
			@ 04,010  BUTTON "Ok" SIZE 45,12 ACTION (oDlg:End(),lSaida:= .T.) OF oScro1 PIXEL			
		//EndIf
		
		ACTIVATE MSDIALOG oDlg CENTERED
	End
	
EndiF

RestArea(aArea)
RestArea(_cAliasSC5)
Return()
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DIPDIG01  ºAutor  ³Microsiga           º Data ³  10/24/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function DipUSerMAIL(_cPsCod,cMsgOper)
Local _cQry0    := " "
Local _cPosCod  := " "
Local _aDsMaCic := {}
Local cCicDe    := " "
Local cEmail    := " "
Local cPost     := _cPsCod
Local j
Local aMsg      := {}
Local cTiMail   := EncodeUTF8("SOLICITAÇÃO DE APROVAÇÃO","cp1252")
Local cFuncSent := "DIPDIG01(DipUserMail)"
Local cDe       := Lower(Alltrim(Posicione("SU7",1,xFilial("SU7")+SC5->C5_OPERADO,"U7_EMAIL")))
Local cMail     := ""
Local cTipSoli  := "1" //01 - Cond. Pag.  02 - Tes

If cOri == "A"
	cTiMail   := EncodeUTF8("AVALIAÇÃO DE ORÇAMENTO","cp1252")
EndIf

_cQry0 :=" SELECT ZS_CIC, ZS_EMAIL "
_cQry0 +=" FROM "+RETSQLNAME ("SZS") + " SZS "
_cQry0 +=" WHERE  '"+cTipSoli+"' = SUBSTRING(ZS_TPAPROV,1,1) "
_cQry0 +=" AND ZS_FILIAL     				 =  '' "
_cQry0 +=" AND RTRIM(LTRIM(ZS_STATUS))       =  'AUTORIZADO' "
_cQry0 +=" AND D_E_L_E_T_    				 =  ' ' "
_cQry0 +=" GROUP BY ZS_CIC, ZS_EMAIL "

dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQry0),'TMP4',.T.,.F.)

While TMP4->(!EOF())
	aAdd(_aDsMaCic,{ALLTRIM(TMP4->ZS_CIC),ALLTRIM(TMP4->ZS_EMAIL)})
	TMP4->( dbSkip())
EndDo
TMP4->(DBCloseArea())
                                                                    
If Len(_aDsMaCic)==0                                               
	aAdd(_aDsMaCic,{"DIEGO.DOMINGOS","diego.domingos@dipromed.com.br"})
EndIf

For j := 1 To Len(_aDsMaCic) 
	If Len(_aDsMaCic[j]) > 1
		cCicDe  := _aDsMaCic[j,1]+" , "+ cCicDe
		cEmail  := _aDsMaCic[j,2]+" ; "+cEmail 
	Else 
		cCicDe  := _aDsMaCic[j,1]
	EndIf
Next j

Do Case
	Case "1" $ cPost
		cPost:= cPost+" - APOIO"
	Case "2" $ cPost
		cPost:= cPost+" - TELEVENDAS"
	Case "3" $ cPost
		cPost:= cPost+" - LICITAÇÃO"
	Case "4" $ cPost
		cPost:= cPost+" - SAC"
	Case "5" $ cPost
		cPost:= cPost+" - COBRANÇA"
	Case "6" $ cPost
		cPost:= cPost+" - HQ"
	OtherWise
		cPost:= cPost+" - OUTROS"
EndCase

If !Empty(cEmail)
	// Monta a email a ser enviado ao operador
	aadd(aMsg,{"Pedido",alltrim(SC5->C5_NUM)})
	aadd(aMsg,{"Cliente",SC5->C5_CLIENTE+" - "+alltrim(POSICIONE("SA1", 1, XFILIAL("SA1")+SC5->C5_CLIENTE, "A1_NREDUZ"))})
	aadd(aMsg,{"Valor",TransForm(_nValor,"@E 999,999.99")})
	aadd(aMsg,{"Condição de Pagamento", SC5->C5_CONDPAG+" - "+alltrim(CAPITAL(POSICIONE("SE4", 1, XFILIAL("SE4")+ALLTRIM(SC5->C5_CONDPAG), "E4_DESCRI")))})
	aadd(aMsg,{"Operador",SC5->C5_OPERADO+" - "+ALLTRIM(CAPITAL( Posicione("SU7",1,xFilial("SU7") + SC5->C5_OPERADO, "U7_NOME") ))})
	aadd(aMsg,{"Posto",cPost})
	aadd(aMsg,{"Transportadora",SC5->C5_TRANSP+" - "+alltrim(POSICIONE("SA4", 1, XFILIAL("SA4")+SC5->C5_TRANSP, "A4_NOME"))})
	aadd(aMsg,{"Frete",Iif(Alltrim(SC5->C5_TPFRETE)="I","INCLUSO",Iif(Alltrim(SC5->C5_TPFRETE)="C","CIF",Iif(Alltrim(SC5->C5_TPFRETE)="F","FOB",Iif(Alltrim(SC5->C5_TPFRETE)="D","RETIRA","MALOTE"))))})
	aadd(aMsg,{"Comentário",cMsgOper})	
	
	u_UEnvMail(cEmail,cTiMail,aMsg,"",cDe,cFuncSent) //envia e-mail
EndIf

// Monta a mensagem a ser enviado ao operador
cMail := "AVISO IMPORTANTE"+CR+CR
cMail += "O Pedido : "+alltrim(SC5->C5_NUM)+CR+CR
cMail += "Aguarda aprovação digital.!! "+CR+CR
cMail += u_DipUsr()

U_DigCic(cMail,cCicDe)

Return()
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DIPDIG01  ºAutor  ³Microsiga           º Data ³  10/24/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function DipBlqPed(cTexto)
DEFAULT cTexto := ""

SC5->(RecLock("SC5",.F.))
	If cTexto<>"NULL"
		SC5->C5_XSTATUS := cTexto
	EndIf
	SC5->C5_PARCIAL := "N"
	SC5->C5_PRENOTA := "O"    
	SC5->C5_EXPLBLO := IIf(Empty(_cExpBloAux),"Pedido aguardando aprovação (APROVAÇÃO DIGITAL)",_cExpBloAux)
SC5->(MsUnLock())
SC5->(DbCommit())

Return    
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DIPDIG01  ºAutor  ³Microsiga           º Data ³  10/28/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function DipTemVld(aItens,lTemAprVlr,lTemVlrInf,lConsig)
Local lRet 		:= .F.     
Local cSQL 		:= ""
Local nPerc 	:= 0
Local nAux  	:= 0
Local nValAux 	:= 0
Local nValDes 	:= 0
Local cTes		:= GetNewPar("ES_TESSKIP","526/556/632/528/558")
Local lVlrOk	:= .F.
DEFAULT lConsig := .T.
DEFAULT lTemAprVlr := .F.
DEFAULT aItens  := {}

SE4->(dbSetOrder(1))
If SE4->(dbSeek(xFilial("SE4")+SC5->C5_CONDPAG))
    
	//nPerc := 1-(SE4->E4_USERDES	/100)
	
	cSQL := " SELECT "
	cSQL += " 	C6_FILIAL, C6_ITEM, C6_NUM, C6_PRCVEN, B1_PRVSUPE, B1_PRVMINI, C6_TES, C6_QTDVEN, C6_XVLRINF, B1_COD, C6_LOTECTL, C6_XQTDINF, C6_DTVALID "
	cSQL += "  	FROM "
	cSQL +=  		RetSQLName("SC6")+", "+RetSQLName("SB1")
	If _lAtuEst
		cSQL += ", "+RetSQLName("SC9")
	EndIf
	cSQL += " 		WHERE "
	cSQL += " 			C6_FILIAL  = '"+xFilial("SC6")+"' AND "
	cSQL += " 			C6_NUM 	   = '"+SC5->C5_NUM+"' AND "
	cSQL += " 			B1_FILIAL  = C6_FILIAL AND "
	cSQL += " 			B1_COD 	   = C6_PRODUTO AND "
	If _lAtuEst
		cSQL += " 			C6_FILIAL  = C9_FILIAL AND "
		cSQL += "	 		C6_NUM	   = C9_PEDIDO AND "
		cSQL += " 			C6_PRODUTO = C9_PRODUTO AND "
		cSQL += " 			C6_CLI 	   = C9_CLIENTE AND "
		cSQL += " 			C6_LOJA    = C9_LOJA AND "
		cSQL += " 			C9_NFISCAL = ' ' AND "	
		cSQL += " 			C9_QTDORI  > 0 AND "	
		cSQL += 			RetSQLName("SC9")+".D_E_L_E_T_ = ' ' AND "
	EndIf
	cSQL += 			RetSQLName("SC6")+".D_E_L_E_T_ = ' ' AND "
	cSQL += 			RetSQLName("SB1")+".D_E_L_E_T_ = ' ' "

	cSQL += " GROUP BY C6_PRCVEN,B1_PRVSUPE,B1_PRVMINI,C6_TES,C6_QTDVEN, C6_XVLRINF, B1_COD, C6_LOTECTL, C6_XQTDINF, C6_DTVALID, C6_FILIAL, C6_ITEM, C6_NUM "
	
	cSQL := ChangeQuery(cSQL)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),"TMPVLD",.T.,.F.)
	
	TCSETFIELD("TMPVLD","C6_PRCVEN"	,"N",17,4)     
	TCSETFIELD("TMPVLD","B1_PRVSUPE","N",17,4)     
	TCSETFIELD("TMPVLD","B1_PRVMINI","N",17,4)     
	TCSETFIELD("TMPVLD","C6_QTDVEN","N",17,4) 
	TCSETFIELD("TMPVLD","C6_DTVALID","D",8,0) 
	
	While !TMPVLD->(Eof())           
		//nAux  := Round(TMPVLD->C6_PRCVEN/nPerc,2)   

  	    nValAux := 0 // Se o produto estiver com erro no preço de promoçao ele vai para a aprovação digital (PRVSUPE>PRVMINI)
  	    aRet 	:= {}
  	    lVlrOk  := .F.
  	    
		If TMPVLD->B1_PRVSUPE > 0 .And. TMPVLD->B1_PRVSUPE < TMPVLD->B1_PRVMINI
			nValAux := TMPVLD->B1_PRVSUPE
		ElseIf TMPVLD->B1_PRVSUPE <= 0 //Se promocao for maior do que PRVMINI está com erro de cadastro
			nValAux := TMPVLD->B1_PRVMINI
		EndIf
		         
		If nValAux > 0 
			nValAux := u_DipAcrCli(nValAux,SC5->C5_CLIENTE,SC5->C5_LOJACLI,TMPVLD->B1_COD)    
			     
			If SE4->E4_USERDES > 0 .Or. SE4->E4_XUSRACR > 0
				nValAux := Round(nValAux * TMPVLD->C6_QTDVEN,4)
				If SE4->E4_USERDES > 0
					nValDes := Round(nValAux * ((SE4->E4_USERDES)/100),4)
					nValAux := Round(nValAux - nValDes,4)
				Else 
					nValDes := Round(nValAux * ((SE4->E4_XUSRACR)/100),4)
					nValAux := Round(nValAux + nValDes,4)
				EndIf				
				nValAux := Round(nValAux / TMPVLD->C6_QTDVEN,4)   
			EndIf 
		
			aRet := u_VldPerCif(nValAux)                                             
		
			If Len(aRet)>0
				nValAux := aRet[1]
			EndIf
		EndIf
			
		
		If (TMPVLD->C6_PRCVEN+GetNewPar("ES_DFARRED",0.0002) < nValAux .Or. nValAux==0) .And. U_ItensApr(TMPVLD->C6_FILIAL,TMPVLD->C6_NUM,TMPVLD->C6_ITEM,TMPVLD->C6_PRCVEN,TMPVLD->C6_QTDVEN) //ES_DFARRED-somo 0.0002 para desconsiderar diferença de arredondamento
			If TMPVLD->C6_PRCVEN < TMPVLD->C6_XVLRINF .Or. TMPVLD->C6_QTDVEN < TMPVLD->C6_XQTDINF .Or. TMPVLD->C6_XVLRINF==0
				If !u_DipTemCon(SC5->C5_CLIENTE,SC5->C5_LOJACLI,TMPVLD->B1_COD,TMPVLD->C6_PRCVEN)
					aAdd(aItens,{TMPVLD->B1_COD,TMPVLD->C6_PRCVEN,nValAux})
					lRet := .T.
					lTemAprVlr := .T.
				EndIf  
			EndIf
		Else
			lVlrOk := .T.
		EndIf          
		
		If TMPVLD->C6_XVLRINF>0 .And. !lVlrOk
			lTemVlrInf := .T.
		EndIf

		If !TMPVLD->C6_TES$cTes		
			lConsig := .F.//Nao e consignacao
		EndIf
		TMPVLD->(dbSkip())


	EndDo
	TMPVLD->(dbCloseArea())    

EndIf

If lConsig //Consignacao passa direto
	aItens 		:= {}
	lRet 		:= .F.     
	lTemAprVlr 	:= .F.               
EndIf

Return lRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DIPDIG01  ºAutor  ³Microsiga           º Data ³  11/07/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funcao para garantir que o pedido nao vai pasasr direto    º±±
±±º          ³ nas regras da aprovacao.                                   º±±
±±º          ³ Em alguns casos o sistema apagava a SZR e não apagava o    º±±
±±º          ³ campo C5_XSTATUS			                                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function DipVldApr()  

SZR->(dbsetorder(3))
If !SZR->(dbSeek(xFilial("SZR")+SC5->C5_NUM))
	SC5->(RecLock("SC5",.F.))
		SC5->C5_XSTATUS := ""
	SC5->(MsUnLock())
EndIf                   

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DIPDIG01  ºAutor  ³Microsiga           º Data ³  11/28/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function DipAtuEst(cPedido)        
Local lRet := .F.
Local cSQL := ""  
DEFAULT cPedido := ""

cSQL := " SELECT "
cSQL += " 	C6_TES "
cSQL += " 	FROM "
cSQL +=  		RetSQLName("SC6")+", "+RetSQLName("SF4")
cSQL += " 		WHERE "
cSQL += " 			C6_FILIAL 	= '"+xFilial("SC6")+"' AND "
cSQL += " 			C6_NUM 		= '"+cPedido+"' AND "
cSQL += " 			C6_FILIAL 	= F4_FILIAL AND "
cSQL += " 			C6_TES 		= F4_CODIGO AND "
cSQL += " 			F4_ESTOQUE 	= 'S' AND "
cSQL += 			RetSQLName("SC6")+".D_E_L_E_T_ = ' ' AND "
cSQL += 			RetSQLName("SF4")+".D_E_L_E_T_ = ' ' "

cSQL := ChangeQuery(cSQL)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),'QRYSF4',.T.,.F.)

If !QRYSF4->(Eof())
	lRet := .T.
EndIf
QRYSF4->(dbCloseArea())

Return lRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DIPDIG01  ºAutor  ³Microsiga           º Data ³  11/28/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function DipRetQry()
Local cSQL := ""

cSQL := " SELECT  
If _lAtuEst
	cSQL += " 	SUM(C6_PRCVEN*C9_QTDORI) AS 'VALOR' "
Else 
	cSQL += " 	SUM(C6_VALOR) AS 'VALOR' "
EndIf

cSQL += " 	FROM "
cSQL += 		RetSQLName("SC6") + " SC6 "

If _lAtuEst
	cSQL += 		","+RetSQLName("SC9")+" SC9 "
EndIf

cSQL += " 		WHERE 
cSQL += " 			C6_FILIAL  = '"+xFilial("SC6")+"' AND "
cSQL += " 			C6_NUM 	   = '"+SC5->C5_NUM+"' AND "

If _lAtuEst
	cSQL += " 			C6_FILIAL  = C9_FILIAL AND "
	cSQL += "	 		C6_NUM	   = C9_PEDIDO AND "
	cSQL += " 			C6_PRODUTO = C9_PRODUTO AND "
	cSQL += " 			C6_ITEM	   = C9_ITEM AND "	
	cSQL += " 			C6_CLI 	   = C9_CLIENTE AND "
	cSQL += " 			C6_LOJA    = C9_LOJA AND "
	cSQL += " 			C9_NFISCAL = ' ' AND "	
	cSQL += " 			C9_QTDORI  > 0 AND "	
	cSQL += " 			SC9.D_E_L_E_T_ = ' ' AND "
EndIf

cSQL += " 			SC6.D_E_L_E_T_ = ' ' "

cSQL := ChangeQuery(cSQL)

Return cSQL  
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DIPDIG01  ºAutor  ³Microsiga           º Data ³  12/05/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function VldAprDig(_lAprova)
Local lRet 		 := .F.
Local _lAprova 	 := .F.                        
Local aItens	 := {}
Local cMsg		 := ""
Local lTemAprVlr := .F.
Local nI
Private _lAtuEst := .F.

SZR->(dbSetOrder(3))
If SZR->(dbSeek(xFilial("SRZ")+SC5->C5_NUM)) .And. AllTrim(SZR->ZR_STATUS) == "AGUARDANDO"
	Aviso("Atenção","Aguarde. O pedido está em processo de aprovação.",{"Ok"},1)
	Return
EndIf

If cEmpAnt<>"01" .Or. SC5->C5_TIPODIP<>"1" .Or. SC5->C5_TIPO<>"N" //.Or. SA1->A1_GRPVEN$GetNewPar("ES_GRPFUNC","000171") Retirado em 08/06/17 e-mail Erich e Patrícia
	Aviso("Atenção","Pedido não necessita de aprovação digital.",{"Ok"},1)
	Return
EndIf

_lAtuEst := DipAtuEst(SC5->C5_NUM)

cSQL := DipRetQry()
		
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),'TMP1',.T.,.F.)
		
TCSETFIELD('TMP1',"VALOR","N",17,4)     

If !TMP1->(Eof())
	_nValAux := TMP1->VALOR
EndIF   
TMP1->(dbCloseArea())

If !Empty(SC5->C5_XSTATUS)
	cSQL := " SELECT "
	cSQL += " 	ZR_STATUS, ZR_CONDPAG, ZR_VALOR "
	cSQL += " 	FROM "
	cSQL +=  		RetSQLName("SZR")
	cSQL += " 		WHERE "
	cSQL += " 			ZR_FILIAL  = '"+xFilial("SC5")+"' AND "
	cSQL += " 			ZR_NUMERO  = '"+SC5->C5_NUM+"' AND "
	cSQL += 			RetSQLName("SZR")+".D_E_L_E_T_ = ' ' "
	
	cSQL := ChangeQuery(cSQL)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),"QRYC5ZR",.T.,.F.)
	
	If !QRYC5ZR->(Eof())  
		If AllTrim(QRYC5ZR->ZR_STATUS) == "APROVADO" .And.;
			AllTrim(SC5->C5_CONDPAG) == AllTrim(QRYC5ZR->ZR_CONDPAG) .And.;
			AllTrim(cValToChar(Round(_nValAux+SC5->(C5_FRETE+C5_DESPESA),2)))==AllTrim(cValToChar(Round(QRYC5ZR->ZR_VALOR,2)))
			_lAprova := .T.
		EndIf
	EndIf
	QRYC5ZR->(dbCloseArea())	
EndIf

If _lAprova    
	Aviso("Atenção","Pedido já foi aprovado.",{"Ok"},1)
Else
	lRet := DipTemVld(@aItens,@lTemAprVlr) .Or. !u_DipCDPgto(nil,.T.,lTemAprVlr)
EndIf

If lRet                                                               
	If Len(aItens)>0
		For nI:=1 To Len(aItens)
			cMsg += PadR(aItens[nI,1],20)+PadL(AllTrim(Str(aItens[nI,2])),20)+PadL(AllTrim(Str(aItens[nI,3])),20)+CHR(10)+CHR(13)
		Next nI
		Aviso("Atenção","Pedido necessita de aprovação."+CHR(10)+CHR(13)+PadR("Produto",20)+PadL("Vlr.Pedido",20)+PadL("Vlr.Produt",20)+CHR(10)+CHR(13)+cMsg,{"Ok"},3)
	Else
		Aviso("Atenção","Pedido necessita de aprovação digital.",{"Ok"},1)
	EndIf
ElseIf !_lAprova
	Aviso("Atenção","Pedido não necessita de aprovação digital.",{"Ok"},1)
EndIf

Return lRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DIPDIG01  ºAutor  ³Microsiga           º Data ³  12/10/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Valida se existe contrato para este produto x cliente      º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function DipTemCon(cCodCli,cCodLoj,cProduto,nValAux)
Local aAreaSA1 	:= SA1->(GetArea())
Local aAreaSB1 	:= SB1->(GetArea())
Local cSQL 		:= ""   
Local lRet 		:= .F.	     
Local cGprVen 	:= ""             
Local cCodAux   := ""

SA1->(dbSetOrder(1))   
If SA1->(dbSeek(xFilial("SA1")+AllTrim(cCodCli)+AllTrim(cCodLoj)))
	cGrpVen := AllTrim(SA1->A1_GRPVEN)	            	
EndIf              
                     
SB1->(dbSetOrder(1))
If SB1->(dbSeek(xFilial("SB1")+AllTrim(cProduto)))
	If !Empty(SB1->B1_XCODDES)
		cCodAux := SB1->B1_XCODDES
	ElseIf !Empty(SB1->B1_XCODORI)
		cCodAux := SB1->B1_XCODORI
	EndIf	
EndIf                              

If Empty(cCodAux)
	cCodAux := AllTrim(cProduto)
Else
	cCodAux := AllTrim(cProduto)+"','"+AllTrim(cCodAux)
EndIf

cSQL := " SELECT "
cSQL += "   ZZG_VALOR "
cSQL += " 	FROM "
cSQL +=  		RetSQLName("ZZF")+", "+RetSQLName("ZZG")
cSQL += " 		WHERE "
cSQL += " 			ZZF_FILIAL = '"+xFilial("ZZF")+"' AND "
If !Empty(cGrpVen)
	cSQL += " 			(ZZF_GRPVEN = '"+cGrpVen+"' OR "
	cSQL += " 			(ZZF_CODCLI = '"+cCodCli+"' AND "
	cSQL += " 			ZZF_LOJA   = '"+cCodLoj+"' )) AND "
Else
	cSQL += " 			ZZF_CODCLI = '"+cCodCli+"' AND "
	cSQL += " 			ZZF_LOJA   = '"+cCodLoj+"' AND "
EndIf
cSQL += " 			(ZZF_DATAFI >= '"+DtoS(Date())+"' OR ZZF_DATAFI = ' ') AND "
cSQL += " 			ZZF_ATIVO  = '1' AND "
cSQL += " 			ZZF_FILIAL = ZZG_FILIAL AND "
cSQL += " 			ZZF_CODIGO = ZZG_CODIGO AND "
cSQL += " 			ZZG_PRODUT IN ('"+cCodAux+"') AND "
cSQL +=  			RetSQLName("ZZF")+".D_E_L_E_T_ = ' ' AND  "
cSQL +=  			RetSQLName("ZZG")+".D_E_L_E_T_ = ' ' "
cSQL += " ORDER BY ZZF_GRPVEN "

cSQL := ChangeQuery(cSQL)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),'QRYZZF',.T.,.F.)    

TCSETFIELD("QRYZZF","ZZG_VALOR","N",17,4)     

If !QRYZZF->(Eof())                                                               
	lRet := nValAux >= QRYZZF->ZZG_VALOR
EndIf
QRYZZF->(dbCloseArea())

RestArea(aAreaSA1)
RestArea(aAreaSB1)

Return lRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DIPDIGMBR ºAutor  ³Microsiga           º Data ³  10/29/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function GrvKardex(cNum,cTexto)

U_DiprKardex(cNum,U_DipUsr(),"Confirmou Aprovação - "+cTexto,.t.,"61") 

Return   
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DIPDIG01  ºAutor  ³Microsiga           º Data ³  04/09/15   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function VldPerCif(nValAux,cPedido)    
Local aAreaSC5 := SC5->(GetArea())
Local lCont := .T.               
Local nPerc	:= 0
DEFAULT cPedido := ""

If !Empty(cPedido)
	SC5->(dbSetOrder(1))
	If !SC5->(dbSeek(xFilial("SC5")+cPedido))
		lCont := .F.
	EndIf 
EndIf

If 	lCont .And. SC5->C5_TPFRETE == "C" .And. u_VldCifRev(SC5->C5_NUM,"SC5",.T.)
	ZZB->(dbSetOrder(1))
	If ZZB->(dbSeek(xFilial("ZZB")+SC5->C5_ESTE))
		nValAux += Round(nValAux*(ZZB->ZZB_PERC/100),4)
		nPerc 	:= ZZB->ZZB_PERC
	EndIf
EndIf	                         

RestArea(aAreaSC5)

Return {nValAux,nPerc}
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DIPDIG01  ºAutor  ³Microsiga           º Data ³  10/07/15   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function VldConInf()
Local lRet := .F.

If !Empty(SC5->C5_DATA1) .And. Empty(SC5->(C5_DATA2+C5_DATA3+C5_DATA4))
	If SC5->C5_DATA1-dDataBase < 28 .And. SC5->C5_PARC1 >= 300
		lRet := .T.
	EndIf
EndIf

Return lRet    
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DIPDIG01  ºAutor  ³Microsiga           º Data ³  11/13/15   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function DipGrvApr(cTipo,nValor,cMsgOper,lTemAprVlr)
DEFAULT cTipo 		:= ""
DEFAULT nValor 		:= 0
DEFAULT cMsgOper 	:= ""
//DEFAULT cPedido 	:= ""
DEFAULT lTemAprVlr  := .F.
        
SZR->(dbsetorder(3))
If SZR->(dbSeek(xFilial("SZR")+SC5->C5_NUM))
	SZR->(RecLock("SZR",.F.))						
		If cTipo=="PAG" .And. lTemAprVlr
			SZR->ZR_ORIGEM  := 'PAG/VAL'	
		ElseIf cTipo=="PAG"
			SZR->ZR_ORIGEM  := 'PAG'	
		ElseIf cTipo=="AVA"
			SZR->ZR_ORIGEM  := 'AVA'
		Else
			SZR->ZR_ORIGEM  := 'VAL'
		EndIf
		
		If cTipo=="PAG"
			SZR->ZR_OBSOPER := cMsgOper
		Else                           
			SZR->ZR_OBSOPE2 := cMsgOper
		EndIf
	SZR->(MsUnLock())
	SZR->(DbCommit())                       
Else
	SZR->(RecLock("SZR",.T.))
		SZR->ZR_FILIAL  := SC5->C5_FILIAL
		SZR->ZR_ORIGEM  := cTipo
		SZR->ZR_NUMERO  := SC5->C5_NUM
		SZR->ZR_OPERADO := SC5->C5_OPERADO
		SZR->ZR_DATA    := DDATABASE
		SZR->ZR_VALOR   := _nValor
		SZR->ZR_CONDPAG := SC5->C5_CONDPAG
		If cTipo == "AVA"
			SZR->ZR_STATUS  := "AVALIANDO"
		Else	
			SZR->ZR_STATUS  := "AGUARDANDO"		
		EndIf	                   
		If cTipo=="PAG"
			SZR->ZR_OBSOPER := cMsgOper
		Else                           
			SZR->ZR_OBSOPE2 := cMsgOper
		EndIf
		SZR->ZR_DTSOLIC := DtoC( Date() ) + ' / ' + Time()
		SZR->ZR_MAQOPER := getcomputername()
		SZR->ZR_USERWIN := LogUserName()
		SZR->ZR_POSTO   := If(alltrim(Posicione("SU7",1,xFilial("SU7") + SC5->C5_OPERADO, "U7_POSTO") )= "03","01",alltrim(Posicione("SU7",1,xFilial("SU7") + SC5->C5_OPERADO, "U7_POSTO") ))
	SZR->(MsUnLock())
	SZR->(DbCommit())
EndIf

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DIPDIG01  ºAutor  ³Microsiga           º Data ³  12/17/15   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function DipDigDel(cPedido,lAprovado)
DEFAULT cPedido := ""
DEFAULT lAprovado := .F.

SZR->(dbsetorder(3))
IF SZR->(dbSeek(xFilial("SZR")+PADR(cPedido,9))) .And. AllTrim(SZR->ZR_STATUS) <> "AGUARDANDO"
	SZR->(RecLock("SZR",.F.))
		SZR->(dbDelete())
	SZR->(MsUnLock())
EndIf                   

If lAprovado
	SC5->(RecLock("SC5",.F.))
		SC5->C5_XSTATUS := ""
	SC5->(MsUnLock())       
	Return .T.
EndIf      

Return



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ITENSAPR  ºAutor  ³REGINALDO BORGES    º Data ³  18/10/18   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Verificar se o item aprovado teve alteracao no valor ou na º±±
±±º          ³ na quantidade, caso sim, ir para aprovacao novamente.      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function ItensApr(cC6Filial,_cC6Pedid,_cC6Item,_nC6Prc,_nC6Qtd)

Local cQRY  := ""
Local _lRet := .T.

cQRY :="SELECT TOP(1) ZZK_FILIAL, ZZK_PEDIDO, ZZK_PRODUT, ZZK_QUANTI, ZZK_VLRAPR, ZZK_STATUS "
cQRY +="FROM "+RetSqlname ("ZZK")
cQRY +="WHERE ZZK_FILIAL = '"+cC6Filial+"'AND " 
cQRY +="ZZK_PEDIDO = '"+_cC6Pedid+"' AND "
cQRY +="ZZK_ITEM   = '"+_cC6Item+"' AND "
cQRY +="ZZK_STATUS LIKE ('%APROVADO%') AND "
cQRY +="D_E_L_E_T_ = '' "
cQRY +="ORDER BY R_E_C_N_O_ DESC"
cQRY := ChangeQuery(cQRY) 
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQRY),'QZZK',.T.,.F.)    

If ! QZZK->(EOF())

	If !(_nC6Prc < QZZK->ZZK_VLRAPR .Or. _nC6Qtd < QZZK->ZZK_QUANTI)
		_lRet :=.F.
	EndIf

EndIf	

QZZK->(DbCloseArea())
			
Return (_lRet)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CONDAPR   ºAutor  ³REGINALDO BORGES    º Data ³  18/10/18   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Verificar se a condição de pagamento aprovada teve         º±±
±±º          ³ alteração no valor, caso sim, ir para aprovacao novamente. º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function CondApr(cC5Filial,_cC5Pedid,_cC5Cond)

Local cQRY  := ""
Local _lRet := .T.
Local cSQL  := "" 
Local _nValP := 0

cSQL := DipRetQry()	   
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),'VlPed',.T.,.F.)

TCSETFIELD('VlPed',"VALOR","N",17,4)     

While VlPed->(!Eof())
	_nValP += VlPed->VALOR
	VlPed->(DbSkip())
EndDo
VlPed->(DbCloseArea())
	
If !Empty(SC5->C5_CONDPAG)
	_nValP += SC5->C5_FRETE + SC5->C5_DESPESA
EndIf

cQRY :="SELECT TOP(1) ZR_VALOR"
cQRY +="FROM "+RetSqlname("SZR")
cQRY +="WHERE ZR_FILIAL='"+cC5Filial+"'AND " 
cQRY +="ZR_NUMERO='"+_cC5Pedid+"'AND "
cQRY +="ZR_CONDPAG='"+_cC5Cond+"'AND "
cQRY +="ZR_STATUS LIKE ('%APROVADO%') AND "
cQRY +="(ZR_ORIGEM  IN ('PAG/VAL') OR ZR_ORIGEM  IN ('PAG') OR ZR_ORIGEM  IN ('VAL'))"
cQRY +="ORDER BY R_E_C_N_O_ DESC"
cQRY := ChangeQuery(cQRY) 
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQRY),'QSZR',.T.,.F.)    

If ! QSZR->(EOF())

	If !(_nValP < QSZR->ZR_VALOR)
		_lRet :=.F.
	EndIf

EndIf

QSZR->(DbCloseArea())
			
Return (_lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DIPDIG01  ºAutor  ³Rafael Moraes Rosa  º Data ³  09/02/23   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function VldDtAprov(cFilAtu,cNumPV)

Local dRetDtVld	:= STOD("//")
Local cQRY  	:= ""

cQRY :="SELECT TOP(1) Z9_DATAMOV"
cQRY +="FROM "+RetSqlname("SZ9")
cQRY +="WHERE Z9_FILIAL='"+cFilAtu+"' AND " 
cQRY +="Z9_PEDIDO='"+cNumPV+"' AND "
cQRY +="Z9_OCORREN = '60' AND "
cQRY +="Z9_TIPMOV = 'Aprovação digital - APROVADO' AND "
cQRY +="D_E_L_E_T_ = '' "
cQRY +="ORDER BY Z9_DATAMOV DESC"
cQRY := ChangeQuery(cQRY) 
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQRY),'QSZ9',.T.,.F.)    

If !QSZ9->(EOF())

	dRetDtVld	:= STOD(QSZ9->Z9_DATAMOV)

EndIf

QSZ9->(DbCloseArea())

Return(dRetDtVld)

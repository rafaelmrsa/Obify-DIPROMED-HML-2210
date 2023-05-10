#include 'protheus.ch'
#include 'parmtype.ch'

/*/{Protheus.doc} PE01NFESEFAZ
Ponto de entrada na geração do XML da NF-e.
Adiciona informações do cliente no XML.

@author Rodrigo Telecio (rodrigo.telecio@allss.com.br)
@since 25/07/2018
@version P12 - NFe 4.00 - TSS 3.00
@type Function	
	@param array, aProd, PARAMIXB[1]
	@param caractere, cMensCli, PARAMIXB[2]
	@param caractere, cMensFis, PARAMIXB[3]
	@param array, aDest, PARAMIXB[4] 
	@param array, aNota, PARAMIXB[5]
	@param array, aInfoItem, PARAMIXB[6]
	@param array, aDupl, PARAMIXB[7]
	@param array, aTransp, PARAMIXB[8]
	@param array, aEntrega, PARAMIXB[9]
	@param array, aRetirada, PARAMIXB[10]
	@param array, aVeiculo, PARAMIXB[11]
	@param array, aReboque, PARAMIXB[12]
	@param array, aNfVincRur, PARAMIXB[13]
	@param array, aEspVol, PARAMIXB[14]
	@param array, aNfVinc, PARAMIXB[15]
	@param array, aDetPag, PARAMIXB[16]
	@param array, aObsCont, PARAMIXB[17]
	@param array, aProcRef, PARAMIXB[18]
	@param caractere, cClieFor, PARAMIXB[19]
	@param caractere, cLoja, PARAMIXB[20]	

	@return array, Retorno[1] -> aProd
	@return caractere, aRetorno[2] -> cMensCli
	@return caractere, aRetorno[3] -> cMensFis
	@return array, aRetorno[4] -> aDest
	@return array, aRetorno[5] -> aNota
	@return array, aRetorno[6] -> aInfoItem
	@return array, aRetorno[7] -> aDupl
	@return array, aRetorno[8] -> aTransp
	@return array, aRetorno[9] -> aEntrega
	@return array, aRetorno[10] -> aRetirada
	@return array, aRetorno[11] -> aVeiculo
	@return array, aRetorno[12] -> aReboque
	@return array, aRetorno[13] -> aNfVincRur
	@return array, aRetorno[14] -> aEspVol
	@return array, aRetorno[15] -> aNfVinc
	@return array, aRetorno[16] -> aDetPag
	@return array, aRetorno[17] -> aObsCont
	@return array, aRetorno[18] -> aProcRef
@obs Sem observações
@see https://allss.com.br
/*/
User function PE01NFESEFAZ()
 
Local aProd     	:= PARAMIXB[1]
Local cMensCli  	:= PARAMIXB[2]
Local cMensFis  	:= PARAMIXB[3]
Local aDest     	:= PARAMIXB[4] 
Local aNota     	:= PARAMIXB[5]
Local aInfoItem 	:= PARAMIXB[6]
Local aDupl     	:= PARAMIXB[7]
Local aTransp   	:= PARAMIXB[8]
Local aEntrega  	:= PARAMIXB[9]
Local aRetirada 	:= PARAMIXB[10]
Local aVeiculo  	:= PARAMIXB[11]
Local aReboque  	:= PARAMIXB[12]
Local aNfVincRur	:= PARAMIXB[13]
Local aEspVol   	:= PARAMIXB[14]
Local aNfVinc   	:= PARAMIXB[15]
Local aDetPag   	:= PARAMIXB[16]
Local aObsCont  	:= PARAMIXB[17]
Local aProcRef		:= PARAMIXB[18]
Local cCodCliFor	:= PARAMIXB[19]
Local cCodLoja		:= PARAMIXB[20]
Local aRetorno  	:= {}

Local aAreaSA1		:= SA1->(GetArea())
Local aAreaSA2		:= SA2->(GetArea())
Local aAreaSA3		:= SA3->(GetArea())
Local aAreaSA4		:= SA4->(GetArea())
Local aAreaSB1		:= SB1->(GetArea())
Local aAreaSB5		:= SB5->(GetArea())
Local aAreaSF1		:= SF1->(GetArea())
Local aAreaSD1		:= SD1->(GetArea())
Local aAreaSF2		:= SF2->(GetArea())
Local aAreaSD2		:= SD2->(GetArea())
Local aAreaSF3		:= SF3->(GetArea())
Local aAreaSF4		:= SF4->(GetArea())
Local aAreaSE1		:= SE1->(GetArea())
Local aAreaSC5		:= SC5->(GetArea())
Local aAreaSC6		:= SC6->(GetArea())
Local aAreaZZX		:= ZZX->(GetArea())
 
Local cMsgFin  		:= "" 
Local cMsgST   		:= ""
Local cMsgLic  		:= ""
Local aVenST   		:= {} 
Local aArtigST 		:= {}
Local cNumPedido	:= ""
Local cDescB1  		:= "" 
Local cCliFor		:= ""
Local cMsgSA1		:= ""
Local cDiCliFor 	:= ""
Local cTpCliFor 	:= ""
Local cEsCliFor 	:= ""
Local ST            := 0
Local nVlMerc   	:= 0
Local nQtdPro   	:= 0 
Local nVlUnit   	:= 0
Local cUniB1		:= ""
Local cMenFinanc	:= GetMV("MV_MSGFINA")
Local cMenNFPAD 	:= GetMV("ES_MSGNFPD", ,"''")          
Local cMenImport	:= GetMV("MV_STIMPOR")
Local lBoleto     	:= .F.
Local lDuplicatas 	:= .F.
Local cPgAVista   	:= ""
Local nDescFin 		:= 0
Local nDescVal 		:= 0
Local cMsgDesFin	:= ""
Local cVendedor		:= ""
Local cLocExp 		:= ""
Local aTES			:= {}
Local aPedido		:= {}
Local cMsgTES		:= ""
Local nPrecoUni 	:= 0
Local nPreUni2		:= 0
Local nQtdSegun		:= 0
Local cPiperCli		:= ""
Local cPiperFis		:= ""
Local cHrReceb		:= ""
Local cCodTransp	:= ""
Local lAchouSD1		:= .F.
Local cMsgEnt		:= ""
Local nDipBOr 		:= 0
Local nValBse 		:= 0
Local lInfAdZF   	:= GetNewPar("MV_INFADZF",.F.)
Local cMVSUBTRIB 	:= ""
lOCAL nX
If Len(aNota) > 0
	If aNota[4] <> "1" //NOTA DE ENTRADA
		dbSelectArea("SF1")
		SF1->(dbSetOrder(1))
		If SF1->(MsSeek(xFilial("SF1") + aNota[2] + aNota[1] + cCodCliFor + cCodLoja,.T.,.F.))
			If Len(aTransp) > 0
				If !Empty(AllTrim(SF1->F1_TRANSP))
					dbSelectArea("SA4")
					SA4->(dbSetOrder(1))
					If SA4->(MsSeek(xFilial("SA4") + "100000",.T.,.F.)) .AND. cEmpAnt + cFilAnt == "0401"
						aTransp[2] := "NOSSO CARRO"
						cCodTransp := SA4->A4_COD
					Else
						cCodTransp := SA4->A4_COD
					EndIf
				EndIf 
			EndIf			
			
			If !SF1->F1_TIPO $ "D/B"
				dbSelectArea("SA2")
				SA2->(dbSetOrder(1))
				If SA2->(MsSeek(xFilial("SA2") + SF1->F1_FORNECE + SF1->F1_LOJA,.T.,.F.))
				    //---------------------------------------------------------------------------------
				    // Tratamento para Mostrar o Endereço de Entrega - MCVN 02/04/2011
				    //---------------------------------------------------------------------------------
                    cMsgEnt := 'ENDERECO DE ENTREGA: ' 
                    cMsgEnt += AllTrim(SA2->A2_END)  	+ '  '                      // Endereco de Entrega
                    cMsgEnt += AllTrim(SA2->A2_BAIRRO) 	+ '.  '                    	// Bairro de Entrega
                    cMsgEnt += AllTrim(SA2->A2_MUN)    	+ '-'                      	// Municipio de Entrega
                    cMsgEnt += AllTrim(SA2->A2_EST)                               	// Estado de Entrega
                    cMsgEnt += ' CEP: ' + Transform(SA2->A2_CEP,'@R 99999-999')  	// CEP ENTREGA				
				    //-----------------------------------------------------------------------------------
				    // Pega o Codigo do Fornecedor para enviar   - MCVN 02/04/2011                                            
				    //-----------------------------------------------------------------------------------
	                cCliFor  	:= "Fornecedor: "  + SA2->A2_COD
					cMsgSA1  	:= "" 
	                cHrReceb 	:= "" // Observacoes de recebimento p/cliente
	                cTpCliFor 	:= SA2->A2_TIPO     //  MCVN 02/04/2011
	                cEsCliFor 	:= SA2->A2_EST      //  MCVN 02/04/2011
	                cDiCliFor 	:= ''               //  MCVN 02/04/2011
				EndIf
			Else
				dbSelectArea("SA1")
				SA1->(dbSetOrder(1))
				If dbSeek(xFilial("SA1") + SF1->F1_FORNECE + SF1->F1_LOJA)
				    //---------------------------------------------------------------------------------
				    // Tratamento para Mostrar o Endereço de Entrega - MCVN 02/04/2011
				    //---------------------------------------------------------------------------------
				    cHrReceb:= AllTrim(SA1->A1_HRRECEB)
                    cMsgEnt := 'ENDERECO DE ENTREGA: ' 
                    cMsgEnt += AllTrim(SA1->A1_ENDENT)  + '  '                     // Endereco de Entrega
                    cMsgEnt += AllTrim(SA1->A1_BAIRROE) + '.  '                    // Bairro de Entrega
                    cMsgEnt += AllTrim(SA1->A1_MUNE)    + '-'                      // Municipio de Entrega
                    cMsgEnt += AllTrim(SA1->A1_ESTE)                               // Estado de Entrega
                    cMsgEnt += ' CEP: ' + Transform(SA1->A1_CEPE,'@R 99999-999')   // CEP ENTREGA		
                    //-----------------------------------------------------------------------------------
				    // Pega o Codigo do Cliente para enviar   - MCVN 02/04/2011                                            
				    //-----------------------------------------------------------------------------------
	                cCliFor 	:= "Cliente: "  + SA1->A1_COD
					cMsgSA1 	:= AllTrim(SA1->A1_MSGNF)
	                cTpCliFor 	:= SA1->A1_TIPO     //  MCVN 02/04/2011
					cEsCliFor 	:= SA1->A1_EST      //  MCVN 02/04/2011
					cDiCliFor 	:= SA1->A1_DIFEREN  //  MCVN 02/04/2011
				EndIf
			EndIf

			If Len(aProd) > 0
				For nX := 1 to Len(aProd)
					nQtdPro := aProd[nX,9]
					//---------------------------------------------------------------------------------
					// MCVN 02/04/2011 - Tratamento para Comercio Exterior
					//---------------------------------------------------------------------------------
					lAchouSD1 := .F.
					If cEmpAnt == "01"
						dbSelectArea("SB1")
						SB1->(dbSetOrder(1))
						If SB1->(MsSeek(xFilial("SB1") + aProd[nX,2],.T.,.F.))
							cUniB1    := Iif(cEsCliFor =='EX',SB1->B1_SEGUM ,SB1->B1_UM)
						EndIf
						dbSelectArea("SD1")
						SD1->(dbSetOrder(1))
						//If SD1->(MsSeek(xFilial("SD1") + SF1->F1_DOC + SF1->F1_SERIE + SF1->F1_FORNECE + SF1->F1_LOJA + aProd[nX,2] + StrZero(Val(aProd[nX,1]),4),.T.,.F.))
						If SD1->(MsSeek(xFilial("SD1") + SF1->F1_DOC + SF1->F1_SERIE + SF1->F1_FORNECE + SF1->F1_LOJA + aProd[nX,2] + StrZero(aProd[nX,1],4),.T.,.F.))
							nVlMerc   := IIf(cTpCliFor =='I' , 0                                  , SD1->D1_TOTAL)
							nQtdPro   := IIf(cEsCliFor =='EX', SD1->D1_QTSEGUM                    , SD1->D1_QUANT) 
							nVlUnit   := IIf(cEsCliFor =='EX', SD1->(D1_QUANT/D1_QTSEGUM*D1_VUNIT), SD1->D1_VUNIT)
							lAchouSD1 := .T.
						EndIf
					Else
					 	dbSelectArea("SB1")
						SB1->(dbSetOrder(1))
						If SB1->(MsSeek(xFilial("SB1") + aProd[nX,2],.T.,.F.))
							cUniB1    := SB1->B1_UM 
						EndIf
						dbSelectArea("SD1")
						SD1->(dbSetOrder(1))
						//If SD1->(MsSeek(xFilial("SD1") + SF1->F1_DOC + SF1->F1_SERIE + SF1->F1_FORNECE + SF1->F1_LOJA + aProd[nX,2] + StrZero(Val(aProd[nX,1]),4),.T.,.F.))
						If SD1->(MsSeek(xFilial("SD1") + SF1->F1_DOC + SF1->F1_SERIE + SF1->F1_FORNECE + SF1->F1_LOJA + aProd[nX,2] + StrZero(aProd[nX,1],4),.T.,.F.))
							nVlMerc   := SD1->D1_TOTAL
							nQtdPro   := SD1->D1_QUANT
							nVlUnit   := SD1->D1_VUNIT
							lAchouSD1 := .T.
						EndIf
					EndIf
					aProd[nX,3] 	:= ""
					aProd[nX,8] 	:= cUniB1
					aProd[nX,9]		:= nQtdPro
					dbSelectArea("SB5")
					SB5->(dbSetOrder(1))
					If dbSeek(xFilial("SB5") + aProd[nX,2])
						aProd[nX,11]	:= IIF(Empty(SB5->B5_UMDIPI), cUniB1, SB5->B5_UMDIPI)
						aProd[nX,12]	:= IIF(Empty(SB5->B5_CONVDIPI), nQtdPro, SB5->B5_CONVDIPI * nQtdPro)
						If lAchouSD1
							aProd[nX,15]	:= SD1->D1_VALDESC
						EndIf
					Else
						aProd[nX,11]	:= cUniB1
						aProd[nX,12]	:= nQtdPro
						If lAchouSD1
							aProd[nX,15]	:= SD1->D1_VALDESC
						EndIf												
					EndIf
					aProd[nX,25]	:= IIf(!Empty(aProd[nX,19]), 'LOTE:' + aProd[nX,19] + ' - ', '') + aProd[nX,25] 
				Next nX
			EndIf
			
			//------------------------------------------------------------------------------------------------------------
            // Concatena todas as Mensagens coletadas durante o processamento do envio dos Itens e demais - MCVN 02/04/2011
            //------------------------------------------------------------------------------------------------------------  
            dbSelectArea("SF1") //-- Importante para identificar no parametro de Mensagem Padrão
			If ValType(&cMenNFPAD) != "C"
				MsgAlert(	"Erro no preenchimento do parâmetro ES_MSGNFPD. Retornou conteúdo de tipo inválido: '" + ValType(&cMenNFPAD) + "', Esperado: 'C'" + CHR(13) + CHR(10) + ;
							"A transmissão será completada sem a mensagem padrão.", "Atenção")
				cMenNFPAD := "''"
			EndIf
            Iif(!Empty(cMsgEnt) 		,(cMensCli := cMsgEnt   + cPiperCli + cMensCli	,cPiperCli := '|'),"")    // Endereço de entrega
            Iif(!Empty(cHrReceb)    	,(cMensCli := cHrReceb  + cPiperCli + cMensCli	,cPiperCli := '|'),"")    // Observacoes de recebimento p/cliente
            Iif(!Empty(&cMenNFPAD)  	,(cMensCli += cPiperCli + &(cMenNFPAD) 			,cPiperCli := '|'),"")    // Mensagem Padrao - ES_MSGNFPD
            Iif(!Empty(cMsgSA1) 		,(cMensCli += cPiperCli + cMsgSA1    			,cPiperCli := '|'),"")    // Mensagem do Cadastro do Cliente
            Iif(!Empty(cCliFor) 		,(cMensCli += cPiperCli + cCliFor 				,cPiperCli := '|'),"")    // Codigo do Fornecedor
            cMensFis += "  " + cCodTransp + "  "                                                          		  // Codigo da Transportadora			
		EndIf
		
		//-----------------------------------------------------------------------------------
        // Tratamento para para mensagem da Nota Fiscal e Mensagem padrão - MCVN 02/04/2011
		//-----------------------------------------------------------------------------------
		If !AllTrim(SF1->F1_OBS) $ cMensCli
			If Len(cMensCli) > 0 .AND. SubStr(cMensCli, Len(cMensCli), 1) <> " "
				cMensCli += " "
			EndIf
			cMensCli += AllTrim(SF1->F1_OBS)   
		    If len(AllTrim(SF1->F1_OBS)) > 0 
			    cPiperCli := '|' 
			EndIf
		EndIf
		If !Empty(SF1->F1_MENPAD) .AND. !AllTrim(FORMULA(SF1->F1_MENPAD)) $ cMensFis
			If Len(cMensFis) > 0 .AND. SubStr(cMensFis, Len(cMensFis), 1) <> " "
				cMensFis += " "
			EndIf
			cMensFis += AllTrim(FORMULA(SF1->F1_MENPAD)) 
			If len(AllTrim(FORMULA(SF1->F1_MENPAD))) > 0
			    cPiperFis := '|' 
			EndIf
		EndIf
	Else //NOTA DE SAÍDA
		dbSelectArea("SF2")
		SF2->(dbSetOrder(1))
		If SF2->(MsSeek(xFilial("SF2") +  aNota[2] + aNota[1] + cCodCliFor + cCodLoja,.T.,.F.))
			If Len(aTransp) > 0
				If !Empty(AllTrim(SF2->F2_TRANSP))
					dbSelectArea("SA4")
					SA4->(dbSetOrder(1))
					If SA4->(MsSeek(xFilial("SA4") + SF2->F2_TRANSP,.T.,.F.))
						cCodTransp := SA4->A4_COD
					Else
						cCodTransp := SA4->A4_COD
					EndIf
				EndIf 
			EndIf		

			//------------------------------------------------------------------------------------------------------------
            // Mensagem da TES que precisa estar impresso na Danfe  - MCVN 02/04/2011
            //------------------------------------------------------------------------------------------------------------			
			If Len(aProd) > 0
				For nX := 1 To Len(aProd)
					If aScan(aTES, aProd[nX,27]) == 0
						aadd(aTES, aProd[nX,27])
					EndIf
				Next nX
			EndIf
			If Len(aTES) > 0
				For nX := 1 To Len(aTES)
					dbSelectArea("SF4")
					SF4->(dbSetOrder(1))
					If SF4->(MsSeek(xFilial("SF4") + aTES[nX],.T.,.F.))
		                If !(AllTrim(SF4->F4_TXTLEGA) $ cMsgTES  )
			                cMsgTES  += AllTrim(SF4->F4_TXTLEGA)
		                EndIf
		            EndIf
		        Next nX
			EndIf

	        //-----------------------------------------------------------------------------------------------------
	        // Controla o envio da Mensagem de Descontos de Boletos e titulos gerados - MCVN 02/04/2011
	        //-----------------------------------------------------------------------------------------------------			
			If Len(aDupl) > 0 
				For nX := 1 To Len(aDupl)
					dbSelectArea("SE1")
					SE1->(dbSetOrder(2)) 
					If SE1->(MsSeek(xFilial("SE1") + cCodCliFor + cCodLoja + aDupl[nX,1],.T.,.F.)) // + aDupl[nX,2] + aDupl[nX,3] // FILIAL+CLIENTE+LOJA+PREFIXO+NUMERO+PARCELA+TIPO
				        lDuplicatas := .T. 
			            If !Empty(SE1->E1_NUMBCO)
				            lBoleto := .T.
			            Endif				 
		              
		                If SE1->E1_VENCTO == SF2->F2_EMISSAO
		                    cPgAVista  := "  Pagamento a Vista  "
		                EndIf
                        
					    //-----------------------------------------------------------------------------------------------------
					    // Apura o valor do desconto financeiro  - MCVN 02/04/2011
					    //-----------------------------------------------------------------------------------------------------
					    If SE1->E1_DESCFIN > 0 .AND. SE1->E1_EMIS1 >= CtoD('01/07/2009') // MCVN - 08/02/2011 Mensagem de desconto financeiro - O Maximo tratou a emissão
					        nDescFin := SE1->E1_DESCFIN
					        nDescVal := (SE1->E1_VALOR * SE1->E1_DESCFIN) / 100
                            //------------------------------------------------------------------------------------
                            // Impressao Mensagem referente ao Desconto Financeiro
                            //------------------------------------------------------------------------------------  
                            cMsgDesFin := "DESCONTO FIN. DE R$ " + Transform(nDescVal,"@E 99,999.99") + " P/ PAGTO. EFETUADO ATÉ O VENCTO."				       
				        EndIf
					EndIf
				Next nX
			EndIf
		
			If !SF2->F2_TIPO $ "D/B"
				dbSelectArea("SA1")
				SA1->(dbSetOrder(1))
				If SA1->(MsSeek(xFilial("SA1") + cCodCliFor + cCodLoja,.T.,.F.))			
				    //-----------------------------------------------------------------------------------
				    // Pega o Codigo do Cliente para enviar   - MCVN 02/04/2011
				    //-----------------------------------------------------------------------------------
	                cCliFor 	:= "   Cliente: "  + SA1->A1_COD
					cMsgSA1 	:= AllTrim(SA1->A1_MSGNF)      
					cDiCliFor  	:= SA1->A1_DIFEREN 
				EndIf
				
				If Len(aTransp) > 0
					If SF2->F2_TPFRETE == "R"
						aTransp[1] 	:= AllTrim(SA1->A1_CGC)
						aTransp[2]	:= SA1->A1_NOME
						aTransp[3]	:= StrTran(StrTran(SA1->A1_INSCR,".",""),"-","")
						aTransp[4]	:= SA1->A1_END
						aTransp[5]	:= SA1->A1_MUN
						aTransp[6]	:= Upper(SA1->A1_EST)
						aTransp[7]	:= SA1->A1_EMAIL					
					ElseIf SF2->F2_TPFRETE == "D" //Ajustado para limpar a transportadora quando o Tipo do Frete for D-Por Conta do Destinatário - MCVN 20/09/2022
						aTransp[1] 	:= ''
						aTransp[2]	:= ''
						aTransp[3]	:= ''
						aTransp[4]	:= ''
						aTransp[5]	:= ''
						aTransp[6]	:= ''
						aTransp[7]	:= ''
					EndIf
				EndIf
				
				//------------------------------------------------------------------------------------------------------------
			    // Posiciona o Vendedor/Local de Expedicao para Imprimir na nota  - MCVN 02/04/2011
			    //------------------------------------------------------------------------------------------------------------
			    dbSelectArea("SA3")
				SA3->(DbSetOrder(1))
				If SA3->(MsSeek(xFilial('SA3') + SF2->F2_VEND1,.T.,.F.))
				     cVendedor := AllTrim(SF2->F2_VEND1) + '-' + AllTrim(SA3->A3_NREDUZ)
				EndIf
				cLocExp 	:= SF2->F2_LOCEXP
			Else
				dbSelectArea("SA2")
				SA2->(dbSetOrder(1))
				If SA2->(MsSeek(xFilial("SA2") + cCodCliFor + cCodLoja,.T.,.F.))
				    //-----------------------------------------------------------------------------------
				    // Pega o Codigo do Cliente para enviar   - MCVN 02/04/2011                                            
				    //-----------------------------------------------------------------------------------
	                cCliFor  	:= "   Fornecedor: " + SA2->A2_COD 
					cMsgSA1  	:= ""
					cDiCliFor	:= ""
	                cHrReceb 	:= ""
				EndIf
				
				If Len(aTransp) > 0
					If AllTrim(SF2->F2_TRANSP) == "999998"
						aTransp[1] 	:= AllTrim(SA2->A2_CGC)
						aTransp[2] 	:= SA2->A2_NOME
						aTransp[3]	:= StrTran(StrTran(SA2->A2_INSCR,".",""),"-","")
						aTransp[4]	:= SA2->A2_END
						aTransp[5]	:= SA2->A2_MUN
						aTransp[6]	:= Upper(SA2->A2_EST)
						aTransp[7]	:= SA2->A2_EMAIL					
					EndIf
				EndIf
				cLocExp := SF2->F2_LOCEXP
			EndIf
			
			dbSelectArea("SF3")
			SF3->(dbSetOrder(4))
			If SF3->(MsSeek(xFilial("SF3") + SF2->F2_CLIENTE + SF2->F2_LOJA + SF2->F2_DOC + SF2->F2_SERIE,.T.,.F.))
				While !SF3->(EOF()) .AND. xFilial("SF3") 	== SF3->F3_FILIAL 	.AND.;
										SF2->F2_CLIENTE 	== SF3->F3_CLIEFOR 	.AND.;
										SF2->F2_LOJA 		== SF3->F3_LOJA 	.And.;
										SF2->F2_DOC 		== SF3->F3_NFISCAL 	.AND.; 
										SF2->F2_SERIE 		== SF3->F3_SERIE
					nDipBOr += SF3->F3_BSICMOR
					nValBse += SF3->F3_VALOBSE
					SF3->(DbSkip ())
   				EndDo		
				If SF3->(MsSeek(xFilial("SF3") + SF2->F2_CLIENTE + SF2->F2_LOJA + SF2->F2_DOC + SF2->F2_SERIE,.T.,.F.))
					If !SF3->F3_DESCZFR == 0 .OR. ( lInfAdZF .AND. nValBse > 0 ) // correcao - lInfAdZF inexistente
						If Len(cMensFis) > 0 .AND. SubStr(cMensFis, Len(cMensFis), 1) <> " "
						   cMensFis += " "
						EndIf		
						If cEmpAnt == "04" .And. SF2->F2_CLIENTE $ GetNewPar("ES_HQCSUFR", "019235")							
							cMensFis += " Valor total da Mercadoria com ICMS = R$ " + Str(nDipBOr, 13, 2)																		
							cMensFis += "|Valor do ICMS (R$ " + Str(nDipBOr,13,2) + " x 7%) = R$" + Str(nValBse, 13, 2)
							cMensFis += "|Valor do Abatimento/desconto = R$ " + Str(nValBse,13,2)														
						EndIf
					EndIf 			
				EndIf
			EndIf
			
			If Len(aInfoItem) > 0
				For nX := 1 To Len(aInfoItem)
					If aScan(aPedido, aInfoItem[nX,1]) == 0
						aadd(aPedido, aInfoItem[nX,1])
					EndIf
				Next nX
				
				If Len(aTES) > 0
					For nX := 1 To Len(aTES)
						If nX == 1
							cTES := aTES[nX]
						Else
							cTES += "/" + aTES[nX]
						EndIf
					Next nX
				EndIf
				
				If Len(aPedido) > 0
					For nX := 1 To Len(aPedido)
						dbSelectArea("SC5")
						SC5->(dbSetOrder(1))
						If SC5->(MsSeek(xFilial("SC5") + aPedido[nX],.T.,.F.))  
						    If Len(AllTrim(SC5->C5_MENNOTA)) > 0
							    cPiperCli := '|'
							EndIf
							
							If "C/C" $ cMensFis .and. !Empty(cPgAVista)
								 cMensFis += '   ' + cPgAVista
							EndIf
									
						    If Len(AllTrim(FORMULA(SC5->C5_MENPAD))) > 0
							    cPiperFis := '|'
							EndIf
							
							//---------------------------------------------------------------------------------
							// Tratamento para Mostrar o Endereço de Entrega - MCVN 02/04/2011
							//---------------------------------------------------------------------------------
							cHrReceb	:= AllTrim(SC5->C5_HRRECEB)
							cMsgEnt 	:= ""
			
							dbSelectArea("SF3")
							dbSetOrder(4)
							If MsSeek(xFilial("SF3") + SF2->F2_CLIENTE + SF2->F2_LOJA + SF2->F2_DOC + SF2->F2_SERIE)
								If At(SF3->F3_ESTADO, cMVSUBTRIB) > 0  // correção - CMVSUBTRIB inexistente
									nPosI	:=	At(SF3->F3_ESTADO, cMVSUBTRIB) + 2
									nPosF	:=	At ("/", SubStr(cMVSUBTRIB, nPosI)) - 1
									nPosF	:=	IIf(nPosF <= 0, Len(cMVSUBTRIB), nPosF)
									cMsgEnt += "Inscrição Estadual (" + SF3->F3_ESTADO + "): " + SubStr(cMVSUBTRIB,nPosI,nPosF) + "|"
								EndIf
							EndIf
							
							If !AllTrim(cTES) $ '785/786'
				                cMsgEnt += 'ENDERECO DE ENTREGA: ' 
				                cMsgEnt += AllTrim(SC5->C5_ENDENT)  + ' - '                     // Endereco de Entrega
				                cMsgEnt += AllTrim(SC5->C5_BAIRROE) + '|'                    	// Bairro de Entrega
				                cMsgEnt += AllTrim(SC5->C5_MUNE)    + '-'                      	// Municipio de Entrega
				                cMsgEnt += AllTrim(SC5->C5_ESTE)                               	// Estado de Entrega
				                cMsgEnt += ' CEP: ' + Transform(SC5->C5_CEPE,'@R 99999-999' ) 	// CEP ENTREGA
			                EndIf
			                
			               	//---------------------------------------------------------------------------------
							// Tratamento para Mostrar a mensagem de licitações ref. ICMS - RSB 31/05/2013
							//---------------------------------------------------------------------------------
			               	cMsgLic := AllTrim(SC5->C5_XMENOTA)		                
						EndIf
					Next nX
				EndIf

				If Len(aInfoItem) > 0
					For nX := 1 to Len(aInfoItem)
						nQtdPro := aProd[nX,9]
					 	cDescB1	:= ""
					 	cUniB1	:= ""
					 	cAlsT	:= GetNextAlias()
					 	cQuery	:= ""
					 	cQuery	+= "SELECT 																			"
						cQuery	+= "	D2_FILIAL, D2_CLIENTE, D2_LOJA, D2_EST, D2_TIPO, D2_DOC, D2_SERIE, D2_ITEM, "
						cQuery	+= "	D2_PEDIDO, D2_ITEMPV, D2_COD, D2_ICMSRET, D2_TOTAL, D2_BRICMS, D2_ICMSRET, 	"
						cQuery	+= "	D2_DESCON, D2_DESCZFR, D2_DTVALID, D2_TES, D2_QUANT, D2_QTSEGUM, D2_PRCVEN  "
						cQuery	+= "FROM 																			"
						cQuery	+= 		RetSqlName("SD2") + " SD2													"				
						cQuery	+= "WHERE																			"
						cQuery	+= "	D2_FILIAL = '" 		+ xFilial("SD2") 	+ "'								"
						cQuery	+= "	AND D2_PEDIDO = '" 	+ aInfoItem[nX,1] 	+ "'								"
						cQuery	+= "	AND D2_ITEMPV = '" 	+ aInfoItem[nX,2] 	+ "'								"
						cQuery	+= "	AND D2_DOC = '" 	+ SF2->F2_DOC 		+ "'								"
						cQuery	+= "	AND D2_SERIE = '" 	+ SF2->F2_SERIE		+ "'								"
						cQuery	+= "	AND D2_ITEM = '" 	+ aInfoItem[nX,4] 	+ "'								"
						cQuery	+= "	AND D_E_L_E_T_ = ''															"
						cQuery  := ChangeQuery(cQuery)
						dbUseArea(.T., "TOPCONN", TcGenQry(,,cQuery), cAlsT, .T., .T.)
						dbSelectArea(cAlsT)
						(cAlsT)->(dbGoTop())
						While (cAlsT)->(!EOF())						
						 	dbSelectArea("SC6")
						 	SC6->(dbSetOrder(1))
						 	If SC6->(MsSeek(xFilial("SC6") + aInfoItem[nX,1] + aInfoItem[nX,2],.T.,.F.))
						 		If SC6->C6_VALINF > 0
									nQtdPro   := (cAlsT)->D2_QUANT
									nPrecoUni := If(SF2->F2_TIPO == "I", 0, SC6->C6_VALINF)
									If cDiCliFor == "E" .OR. cDiCliFor == "T"  // A1_DIFEREN / A2_DIFEREN
										nQtdPro   := (cAlsT)->D2_QTSEGUM
										nPrecoUni := IIf(SF2->F2_TIPO == "I", 0, SC6->C6_VALINF / ((cAlsT)->D2_QTSEGUM / (cAlsT)->D2_QUANT))
									EndIf
								EndIf  
	
								nPreUni2  := If(SF2->F2_TIPO == "I", 0, (cAlsT)->D2_PRCVEN)
								nQtdSegun := (cAlsT)->D2_QTSEGUM 
								
								If cDiCliFor == "E" .OR. cDiCliFor == "T"  // A1_DIFEREN / A2_DIFEREN
									nPreUni2 := IIf(SF2->F2_TIPO == "I", 0, (cAlsT)->D2_PRCVEN / ((cAlsT)->D2_QTSEGUM / (cAlsT)->D2_QUANT))
								Else
									nQtdSegun:= (cAlsT)->D2_QUANT
								EndIf   
								
								nPrecoUni := IIf(nPrecoUni == 0, nPreUni2, nPrecoUni)
								nQtdPro   := IIf(nQtdPro == 0, nQtdSegun, nQtdPro)
								nVlMerc   := IIf(SF2->F2_TIPO == "I", 0, (cAlsT)->D2_TOTAL)				 		
						 	EndIf
					 	
							cNumPedido := (cAlsT)->D2_PEDIDO
							dbSelectArea("SB1")
							SB1->(dbSetOrder(1))
							If SB1->(MsSeek(xFilial("SB1") + (cAlsT)->D2_COD,.T.,.F.))
								If (cAlsT)->D2_ICMSRET == 0
								//---------------------------------------------------------------------------------
								// Apura os valores de recolhimento de ST de acordo com cada artigo da lei de ST
								// Informado no cadastro de Produtos.                                                           
								//---------------------------------------------------------------------------------
									If (cAlsT)->D2_EST == "SP" .AND. SB1->B1_PICMRET > 0 
										nPos 	 := 0
										cPerICMS := Transform(SB1->B1_PICM, "@e 999.99")
									    If (nPos := aScan(aArtigST,{ |x| x[1] == SB1->B1_ARTIGST .AND. x[4] == cPerICMS })) > 0
									    	aArtigST[nPos,2] += (cAlsT)->D2_TOTAL
									    	aArtigST[nPos,3] += ((cAlsT)->D2_TOTAL * SB1->B1_PICM) / 100 
									    Else	                                          
									    	aadd(aArtigST,{SB1->B1_ARTIGST, (cAlsT)->D2_TOTAL, ((cAlsT)->D2_TOTAL * SB1->B1_PICM) / 100, cPerICMS})
									    EndIf
									EndIf
								Else
								    //----------------------------------------------------------[ MCVN 02/04/2011 ]----
								    // Discriminar a Substituição tributaria por Posição de IPI NCM 
								    //---------------------------------------------------------------------------------
								    nPos := 0
								    If (nPos := aScan(aVenST,{ |x| x[1] == SB1->B1_POSIPI})) > 0
				            	        aVenST[nPos,2] += (cAlsT)->D2_BRICMS
				            	        aVenST[nPos,3] += (cAlsT)->D2_ICMSRET
				            	    Else	
				   				        aadd(aVenST,{SB1->B1_POSIPI, (cAlsT)->D2_BRICMS, (cAlsT)->D2_ICMSRET})
				   				    EndIf
				   			    EndIf    
								//----------------------------------------------------------[MCVN 02/04/2011]------
								// Avaliando o campo do cliente A1_DIFEREN para determinar se o produto deverar ser 
								// usado na segunda unidade e na segunda descricao. 
								//---------------------------------------------------------------------------------
								cUniB1  := If(SA1->A1_DIFEREN $ "ET", SB1->B1_SEGUM, SB1->B1_UM)
								cDescB1 := If(SA1->A1_DIFEREN == "E", SB1->B1_DESC2, SB1->B1_DESC)
							EndIf


							aProd[nX,3] 	:= ""
							aProd[nX,4] 	:= If(!Empty(AllTrim(cDescB1)), cDescB1, aProd[nX,4])
							aProd[nX,8] 	:= If(!Empty(AllTrim(cUniB1)), cUniB1, aProd[nX,8])
							aProd[nX,9]		:= nQtdPro
							dbSelectArea("SB5")
							SB5->(dbSetOrder(1))
							If SB5->(MsSeek(xFilial("SB5") + aProd[nX,2],.T.,.F.))
								aProd[nX,11]	:= IIF(Empty(SB5->B5_UMDIPI), cUniB1, SB5->B5_UMDIPI)
								aProd[nX,12]	:= IIF(Empty(SB5->B5_CONVDIPI), nQtdPro, SB5->B5_CONVDIPI * nQtdPro)
							Else
								aProd[nX,11]	:= cUniB1
								aProd[nX,12]	:= nQtdPro												
							EndIf
							aProd[nX,15]	:= (cAlsT)->D2_DESCON + (cAlsT)->D2_DESCZFR // IDENTIFICAR A EXPRESSÃO COMENTADA ABAIXO
							aProd[nX,25]	:= IIF(!Empty(DtoC(StoD((cAlsT)->D2_DTVALID))), DtoC(StoD((cAlsT)->D2_DTVALID)), "") + " " + SubStr(SB1->B1_ARTIGST, 5, 2) + " " + (cAlsT)->D2_TES + " " + AllTrim(aProd[nX,25])	//Informacoes adicionais do produto(B5_DESCNFE)
							aProd[nX,25]	:= IIf(!Empty(aProd[nX,19]) .AND. !('LOTE:' + aProd[nX,19])$aProd[nX,25], 'LOTE:' + aProd[nX,19] + ' - ', '') + AllTrim(aProd[nX,25])
							(cAlsT)->(dbSkip())
						EndDo
						(cAlsT)->(dbCloseArea())
					Next nX
				EndIf
			EndIf

            //------------------------------------------------------------------------------------------------------------
            // Mensagem do financeiro (Atraso com justificativa do não recebimento de boleto) -  MCVN 02/04/2011
            //------------------------------------------------------------------------------------------------------------
            cMsgFin := ""  // MCVN 02/04/2011
            If lDuplicatas .AND. !lBoleto .AND. !("C/C" $ cMensFis) .AND. Empty(cPgAVista)
	            cMsgFin := AllTrim(Upper(cMenFinanc))   //  MCVN 02/04/2011
	        ElseIf ! Empty(cPgAVista) .and. !("C/C" $ cMensFis)  //MCVN 02/04/2011
	            cMsgFin := LTrim(cPgAVista) //  MCVN 02/04/2011
            Endif    
            //------------------------------------------------------------------------------------------------------------
            // Mensagem de Retenção de ICMS por Substituição Tributaria não inclusa na Nota Fiscal -  MCVN 02/04/2011
            //------------------------------------------------------------------------------------------------------------
            cMsgST   := ""
            cPiperST := "" 
            cVirgula := ""
			If Len(aVenSt) > 0 .AND. !(cEmpAnt =="04" .AND. SA1->A1_COD $ GetNewPar("ES_HQCSUFR", "019235"))
                For ST := 1 to Len(aVenSt)
		            cMsgST += cVirgula + "(" + AllTrim(Str(ST)) + ")" + AllTrim(aVenST[ST][1]) + "  Imposto Retido B.C. ICMS RETIDO: " + Transform(aVenST[ST,2], "@E 9,999,999.99") + ;
		                        " e ICMS RETIDO: " + Transform(aVenST[ST][3], "@E 999,999.99")
		            cVirgula := "  /  "            
	            Next St
	            cPiperST := '|'
                cMsgST +=  cPiperST + cMenImport
            EndIf	     
	 
			If Len(aArtigST) > 0  .AND. cEmpAnt <> "04"
			    cMsgST += cPiperST + "ST 060-IMPOSTO RECOLHIDO POR SUBSTITUICAO - "
			    cVirgula := ""
                For St := 1 to Len(aArtigST)   
                    If AllTrim(SA1->A1_TIPO) $ 'RS'
                        cMsgST +=  cVirgula + "Artigo " + AllTrim(aArtigST[ST][1]) + " DO RICMS Operação Propria - Aliq. " + AllTrim(aArtigST[ST][4]) + "%   B. Calculo = " + AllTrim(Transform(aArtigST[ST,2], "@E 9,999,999.99")) + " e ICMS = " + AllTrim(Transform(aArtigST[ST,3], "@E 999,999.99"))
                        cVirgula := ", "
                    ElseIf AllTrim(SA1->A1_TIPO) $ 'F'  .AND. !(AllTrim(aArtigST[ST][1]) + " DO RICMS"  $ cMsgST)
                        cMsgST +=  cVirgula + "Artigo " + AllTrim(aArtigST[ST][1]) + " DO RICMS"
                        cVirgula := ", "
                    EndIf    
	            Next St
            EndIf              
             
			If SF2->F2_TIPO == 'I'
	            _nBase := Transform((SD2->D2_VALICM / (SD2->D2_PICM / 100)), " @E 999,999,999.99")			
				cMsgST += cPiperST + ("COMPLEMENTO de ICMS, Base: " + cValToChar(_nBase) + " - Valor ICMS: " + cValToChar(SD2->D2_VALICM) + " - Aliquota: " + cValToChar(SD2->D2_PICM) + " %")
			EndIf	
            
            cMsgSuframa := ""  //  MCVN 02/04/2011 - Controle de Mensagem Suframa   
            
            If SF2->F2_TIPO $ 'NCPISTO'  //MCVN 02/04/2011           
	            If !Empty(SA1->A1_SUFRAMA)                                   
	                 cMsgSuframa := "SUFRAMA N. " + SA1->A1_SUFRAMA
		        EndIf
	        EndIf
	        
            //------------------------------------------------------------------------------------------------------------
            // Concatena todas as Mensagens coletadas durante o processamento do envio dos Itens e demais -  MCVN 02/04/2011
            //------------------------------------------------------------------------------------------------------------
            dbSelectArea("SF2") //-- Importante para identificar no parametro de Mensagem Padrão
			If ValType(&cMenNFPAD) != "C"
				MsgAlert(	"Erro no preenchimento do parâmetro ES_MSGNFPD. Retornou conteúdo de tipo inválido: '" + ValType(&cMenNFPAD) + "', Esperado: 'C'" + CHR(13) + CHR(10)+;
							"A transmissão será completada sem a mensagem padrão.","Atenção")
				cMenNFPAD := "''"
			EndIf
			
			If cFilAnt == "04"
				dbSelectArea("ZZX")
				ZZX->(dbSetOrder(2))
				If ZZX->(dbSeek(xFilial("ZZX") + SA1->A1_CGC))
					cMsgSA1 := " Emitida de acordo com a Portaria Cat 116/2017, Art. 2 Parag. 4 - Regime Especial ST n. " + AllTrim(ZZX->ZZX_REGESP) + ", mercadoria destinada a uso hospitalar."
				EndIf
			EndIf
			
            IIf(!Empty(cMsgEnt)    ,(cMensCli := cMsgEnt   + cPiperCli + cMensCli   ,cPiperCli := '|'),"")  // Endereço de entrega
            IIf(!Empty(cHrReceb)   ,(cMensCli := cHrReceb  + cPiperCli + cMensCli   ,cPiperCli := '|'),"")  // Mensagem de Hora de Recebimento
            IIf(!Empty(&cMenNFPAD) ,(cMensCli += cPiperCli + &(cMenNFPAD)           ,cPiperCli := '|'),"")  // Mensagem padrao - ES_MSGNFPD
            IIf(!Empty(cMsgTES)    ,(cMensCli += cPiperCli + cMsgTES                ,cPiperCli := '|'),"")  // Mensagens da TES 
            IIf(!Empty(cMsglic)    ,(cMensCli += cPiperCli + cMsglic                ,cPiperCli := '|'),"")  // Mensagem de Licitações
            IIf(!Empty(cMsgDesFin) ,(cMensCli += cPiperCli + cMsgDesFin             ,cPiperCli := '|'),"")  // Mensagem do Financeiro
            IIf(!Empty(cMsgFin)    ,(cMensCli += cPiperCli + cMsgFin                ,cPiperCli := '|'),"")  // Mensagem do Financeiro
            IIf(!Empty(cMsgST)     ,(cMensCli += cPiperCli + cMsgST                 ,cPiperCli := '|'),"")  // Mensagem  Posição do IPI e ST
            IIf(!Empty(cMsgSuframa),(cMensCli += cPiperCli + cMsgSuframa            ,cPiperCli := '|'),"")  // Mensagem Suframa
            IIf(!Empty(cMsgSA1)    ,(cMensCli += cPiperCli + cMsgSA1                ,cPiperCli := '|'),"")  // Mensagem do Cadastro do Cliente
            
            cMensFis += cPiperCli + Transform(cLocExp,"999")  // Codigo de Expedição  
            cMensFis += "  " + cCodTransp + "  "              // Codigo da Transportadora
            cMensFis += "   Pedido de Venda: " + cNumPedido   // Numero do Pedido de Venda
            If !Empty(SC5->C5_PEDECOM)
            	cMensFis += "   Pedido eCommerce: " + SC5->C5_PEDECOM   // Numero do Pedido de Venda eCommerce
            EndIf
            cMensFis += "   Vendedor: "        + cVendedor    // Codigo e Nome do Vendedor
            cMensFis += cCliFor                               // Codigo do Cliente / Fornecedor
		EndIf
	EndIf
EndIf

RestArea(aAreaZZX)
RestArea(aAreaSC6)
RestArea(aAreaSC5)
RestArea(aAreaSE1)
RestArea(aAreaSF4)
RestArea(aAreaSF3)
RestArea(aAreaSD2)
RestArea(aAreaSF2)
RestArea(aAreaSD1)
RestArea(aAreaSF1)
RestArea(aAreaSB5)
RestArea(aAreaSB1)
RestArea(aAreaSA4)
RestArea(aAreaSA3)
RestArea(aAreaSA2)
RestArea(aAreaSA1)

aadd(aRetorno,aProd) 
aadd(aRetorno,cMensCli)
aadd(aRetorno,cMensFis)
aadd(aRetorno,aDest)
aadd(aRetorno,aNota)
aadd(aRetorno,aInfoItem)
aadd(aRetorno,aDupl)
aadd(aRetorno,aTransp)
aadd(aRetorno,aEntrega)
aadd(aRetorno,aRetirada)
aadd(aRetorno,aVeiculo)
aadd(aRetorno,aReboque)
aadd(aRetorno,aNfVincRur)
aadd(aRetorno,aEspVol)
aadd(aRetorno,aNfVinc)
aadd(aRetorno,aDetPag)
aadd(aRetorno,aObsCont)
	
Return aRetorno

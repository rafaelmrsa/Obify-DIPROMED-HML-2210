/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³UMaAvalCred³ Autor ³    Alexandro Dias     ³ Data ³ 12.01.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao Generica de Avaliacao de Credito de Clientes          ³±±
±±³Observacao³Esta funcao foi convertida e ajustada conforme as necessida- ³±±
±±³          ³des da DIPROMED.                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpL1: Credito (Sim/Nao)                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: Codigo do Cliente                                     ³±±
±±³          ³ExpC2: Loja do Cliente                                       ³±±
±±³          ³ExpN3: Valor a ser avaliado                                  ³±±
±±³          ³ExpN4: Moeda do valor a ser avaliado                         ³±±
±±³          ³ExpL5: Considera acumulados de Pedido de Venda do SA1        ³±±
±±³          ³ExpC6: Codigo do Bloqueio.                                   ³±±
±±³          ³ExpC7: aEmpenho                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function UMaAvalCred(cCodCli,cLoja,nValor,nMoeda,lPedido,cCodigo,aEmpenho)

Local aArea		:= GetArea()
Local aAreaSA1	:= SA1->(GetArea())
Local aAreaSE1	:= SE1->(GetArea())
Local lRetorno	:= .F.
Local nMCusto 	:= Val(GetMV("MV_MCUSTO"))
Local cTipoLim	:= GetMV("MV_CREDCLI")
Local nLimCred	:= 0
Local nVlrReal 	:= xMoeda(nValor,nMoeda,1,dDataBase,2)
Local nVlrPed	:= nVlrReal
Local nLiminCr := GetMV("MV_LIMINCR") 	//Limite Minimo de Credito
Local nPerMax  := GetMV("MV_PERMAX")	//Percentual Maximo comprometido com o Limite de Credito
Local nFaixaA  := GetMV("MV_PEDIDOA")  //Limite de Credito para a Faixa A
Local nFaixaB  := GetMV("MV_PEDIDOB")  //Limite de Credito para a Faixa B
Local nFaixaC  := GetMV("MV_PEDIDOC")  //Limite de Credito para a Faixa C
Local nNumDias	:= 0
Local nRegEmp  := 0
U_DIPPROC(ProcName(0),U_DipUsr()) // JBS 05/10/2005 - Gravando o nome do Programa no SZU
dbSelectArea("SA1")
dbSetOrder(1)

Do Case
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Aqui e Verificado o Cliente Por Codigo + Loja                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Case ( cTipoLim=="L" )
		
		If ( MsSeek(xFilial("SA1")+cCodCli+cLoja) )
			
			If ( SA1->A1_RISCO == "A" )
				lRetorno := .T.
			EndIf
			If ( SA1->A1_RISCO == "E" )
				lRetorno := .F.
				cCodigo 	:= "01" // Limite de Credito
			EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Aqui e avaliado o Vencimento do Limite de Credito do Cliente            ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If ( !Empty(SA1->A1_VENCLC) .And. SA1->A1_VENCLC < dDataBase )
				cCodigo  := "04" //Vencimento do Limite de Credito
				lRetorno := .F.
			EndIf
			If ( SA1->A1_RISCO != "A" .And. SA1->A1_RISCO != "E" .And. lRetorno)
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Aqui e verificado o Limite de Credito do Cliente + Loja                 ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³O Limite de Credito sempre esta na Moeda MV_MCUSTO, mas os calculos sao ³
				//³em na moeda corrente.                                                   ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				nLimCred  := xMoeda(SA1->A1_LC,nMCusto,1,dDataBase,2)
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Verifica se o Valor nao eh maior que o Limite de Credito                ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If ( lPedido )
					nVlrReal += SA1->A1_SALDUP + xMoeda(SA1->A1_SALPEDL,nMCusto,1,dDatabase,2)
					If ( aEmpenho != Nil )
						nRegEmp	:= aScan(aEmpenho[1],{|x| x[1]==SA1->(RecNo())})
						If ( nRegEmp != 0 )
							nVlrReal +=	aEmpenho[1][nRegEmp][2]
						EndIf
					EndIf
				EndIf
				If ( nVlrReal > nLimCred .And. nLimCred >= 0 )
					cCodigo 	:= "01" // Limite de Credito
					lRetorno := .F.
				EndIf
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Verifica as Classes de Cliente                                          ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				Do Case
					Case ( nVlrReal <= nLiMinCr )
						lRetorno := .T.
						cCodigo 	:= ""
					Case ( nVlrReal > ((nPerMax * nLimCred) / 100) )
						lRetorno := .F.
						cCodigo 	:= "01" // Limite de Credito
					Case ( SA1->A1_CLASSE == "A" .And. nVlrPed > nfaixaA .And. nFaixaA != 0 )
						lRetorno := .F.
						cCodigo 	:= "01" // Limite de Credito
					Case ( SA1->A1_CLASSE == "B" .And. nVlrPed > nfaixaB .And. nFaixaB != 0 )
						lRetorno := .F.
						cCodigo 	:= "01" // Limite de Credito
					Case ( SA1->A1_CLASSE == "C" .And. nVlrPed > nfaixaC .And. nFaixaC != 0 )
						lRetorno := .F.
						cCodigo 	:= "01" // Limite de Credito
				EndCase
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Aqui e verificado o Grau de Risco do Cliente + Loja                     ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If ( lRetorno .And. !Empty(SA1->A1_RISCO) )
					nNumDias := GetMV("MV_RISCO"+SA1->A1_RISCO)
					dbSelectArea("SE1")
					dbSetOrder(8)
					MsSeek(xFilial("SE1")+cCodCli+cLoja+"A")
					While ( !Eof() .And. SE1->E1_FILIAL == xFilial("SE1") .And.;
						SE1->E1_CLIENTE== cCodCli			.And.;
						SE1->E1_LOJA	== cLoja				.And.;
						SE1->E1_STATUS	== "A" )
						If ( !SE1->E1_TIPO$MVRECANT+"/"+MVPROVIS+"/"+MV_CRNEG .And. !SE1->E1_TIPO$MVABATIM )
							If ( ( dDataBase - SE1->E1_VENCREA ) >= nNumDias )
								lRetorno := .F.
								cCodigo 	:= "01" // Limite de Credito
							EndIf
						EndIf
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Aqui o Loop eh abortado pois esta em ordem de vencto Real ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						Exit
					EndDo
				EndIf
			EndIf
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Aqui e verificado apenas o Codigo ( Matriz )                            ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Case ( cTipoLim == "C" )
		If ( MsSeek(xFilial("SA1")+cCodCli) )
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ O Grau de Risco deve ser Avaliado da Matriz                   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If ( SA1->A1_RISCO == "A" )
				lRetorno := .T.
				cCodigo	:= ""
			EndIf
			If ( SA1->A1_RISCO == "E" )
				lRetorno := .F.
				cCodigo 	:= "01" // Limite de Credito
			EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Aqui e avaliado o Vencimento do Limite de Credito do Cliente            ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If ( !Empty(SA1->A1_VENCLC) .And. SA1->A1_VENCLC < dDataBase )
				lRetorno := .F.
				cCodigo 	:= "04" // Vencimento do Limite de Credito
			EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Aqui e verificado o Limite de Credito do Cliente                        ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³O Limite de Credito sempre esta na Moeda MV_MCUSTO, mas os calculos sao ³
			//³em na moeda corrente.                                                   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If ( SA1->A1_RISCO != "A" .And. SA1->A1_RISCO != "E" .And. lRetorno )
				nLimCred	:= 0
				dbSelectArea("SA1")
				dbSetOrder(1)
				MsSeek(xFilial("SA1")+cCodCli)
				While ( !Eof() .And. xFilial("SA1") == SA1->A1_FILIAL .And.;
					cCodCli 			== SA1->A1_COD 	.And.;
					lRetorno)
					nLimCred	+= xMoeda(SA1->A1_LC,nMCusto,1,dDataBase,2)
					If ( lPedido )
						nVlrReal	+= SA1->A1_SALDUP + xMoeda(SA1->A1_SALPEDL,nMCusto,1,dDatabase,2)
						If ( aEmpenho != Nil )
							nRegEmp	:= aScan(aEmpenho[1],{|x| x[1]==SA1->(RecNo())})
							If ( nRegEmp != 0 )
								nVlrReal +=	aEmpenho[1][nRegEmp][2]
							EndIf
						EndIf
					EndIf
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Aqui e avaliado o Vencimento do Limite de Credito do Cliente            ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If ( !Empty(SA1->A1_VENCLC) .And. SA1->A1_VENCLC < dDataBase )
						lRetorno := .F.
						cCodigo 	:= "04" // Vencimento do Limite de Credito
					EndIf
					dbSelectArea("SA1")
					dbSkip()
				EndDo
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Verifica se o Valor nao eh maior que o Limite de Credito                ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If ( lRetorno .And. nVlrReal > nLimCred .And. nLimCred >= 0 )
					lRetorno := .F.
					cCodigo 	:= "01" // Limite de Credito
				EndIf
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Verifica as Classes de Cliente                                          ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				dbSelectArea("SA1")
				dbSetOrder(1)
				MsSeek(xFilial("SA1")+cCodCli)
				Do Case
					Case ( nVlrReal <= nLiMinCr )
						lRetorno := .T.
						cCodigo 	:= ""
					Case ( nVlrReal > ((nPerMax * nLimCred) / 100) )
						lRetorno := .F.
						cCodigo 	:= "01" // Limite de Credito.
					Case ( SA1->A1_CLASSE == "A" .And. nVlrPed > nfaixaA .And. nFaixaA != 0 )
						lRetorno := .F.
						cCodigo 	:= "01" // Limite de Credito
					Case ( SA1->A1_CLASSE == "B" .And. nVlrPed > nfaixaB .And. nFaixaB != 0 )
						lRetorno := .F.
						cCodigo 	:= "01" // Limite de Credito
					Case ( SA1->A1_CLASSE == "C" .And. nVlrPed > nfaixaC .And. nFaixaC != 0 )
						lRetorno := .F.
						cCodigo 	:= "01" // Limite de Credito
				EndCase
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Aqui e avaliado o risco do Cliente - ( Matriz + Filiais )   ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If ( lRetorno .And. !Empty(SA1->A1_RISCO) )
					dbSelectArea("SA1")
					dbSetOrder(1)
					MsSeek(xFilial("SA1")+cCodCli)
					nNumDias := GetMV("MV_RISCO"+SA1->A1_RISCO)
					While ( !Eof() .And. xFilial("SA1") == SA1->A1_FILIAL .And.;
						cCodCli 			== SA1->A1_COD )
						dbSelectArea("SE1")
						dbSetOrder(8)
						MsSeek(xFilial("SE1")+SA1->A1_COD+SA1->A1_LOJA+"A")
						While ( !Eof() .And. SE1->E1_FILIAL	==	xFilial("SE1") .And.;
							SE1->E1_CLIENTE==	SA1->A1_COD .And.;
							SE1->E1_LOJA	==	SA1->A1_LOJA .And.;
							SE1->E1_STATUS == "A" )
							If ( !SE1->E1_TIPO$MVRECANT+"/"+MVPROVIS+"/"+MV_CRNEG .And. !SE1->E1_TIPO $ MVABATIM)
								If ( ( dDataBase - SE1->E1_VENCREA ) >= nNumDias )
									lRetorno := .F.
									cCodigo 	:= "01" // Limite de Credito
								EndIf
							EndIf
							Exit
						EndDo
						If ( !lRetorno )
							Exit
						EndIf
						dbSelectArea("SA1")
						dbSkip()
					EndDo
				EndIf
			EndIf
		EndIf
EndCase

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Restaura a Entrada da Rotina                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
RestArea(aAreaSA1)
RestArea(aAreaSE1)
RestArea(aArea)

Return(lRetorno)
/*/
�������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Funcao    �UMaAvalCred� Autor �    Alexandro Dias     � Data � 12.01.02 ���
��������������������������������������������������������������������������Ĵ��
���Descri��o �Funcao Generica de Avaliacao de Credito de Clientes          ���
���Observacao�Esta funcao foi convertida e ajustada conforme as necessida- ���
���          �des da DIPROMED.                                             ���
��������������������������������������������������������������������������Ĵ��
���Retorno   �ExpL1: Credito (Sim/Nao)                                     ���
��������������������������������������������������������������������������Ĵ��
���Parametros�ExpC1: Codigo do Cliente                                     ���
���          �ExpC2: Loja do Cliente                                       ���
���          �ExpN3: Valor a ser avaliado                                  ���
���          �ExpN4: Moeda do valor a ser avaliado                         ���
���          �ExpL5: Considera acumulados de Pedido de Venda do SA1        ���
���          �ExpC6: Codigo do Bloqueio.                                   ���
���          �ExpC7: aEmpenho                                              ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
�������������������������������������������������������������������������������
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
	//������������������������������������������������������������������������Ŀ
	//�Aqui e Verificado o Cliente Por Codigo + Loja                           �
	//��������������������������������������������������������������������������
	Case ( cTipoLim=="L" )
		
		If ( MsSeek(xFilial("SA1")+cCodCli+cLoja) )
			
			If ( SA1->A1_RISCO == "A" )
				lRetorno := .T.
			EndIf
			If ( SA1->A1_RISCO == "E" )
				lRetorno := .F.
				cCodigo 	:= "01" // Limite de Credito
			EndIf
			//������������������������������������������������������������������������Ŀ
			//�Aqui e avaliado o Vencimento do Limite de Credito do Cliente            �
			//��������������������������������������������������������������������������
			If ( !Empty(SA1->A1_VENCLC) .And. SA1->A1_VENCLC < dDataBase )
				cCodigo  := "04" //Vencimento do Limite de Credito
				lRetorno := .F.
			EndIf
			If ( SA1->A1_RISCO != "A" .And. SA1->A1_RISCO != "E" .And. lRetorno)
				//������������������������������������������������������������������������Ŀ
				//�Aqui e verificado o Limite de Credito do Cliente + Loja                 �
				//��������������������������������������������������������������������������
				//������������������������������������������������������������������������Ŀ
				//�O Limite de Credito sempre esta na Moeda MV_MCUSTO, mas os calculos sao �
				//�em na moeda corrente.                                                   �
				//��������������������������������������������������������������������������
				nLimCred  := xMoeda(SA1->A1_LC,nMCusto,1,dDataBase,2)
				//������������������������������������������������������������������������Ŀ
				//�Verifica se o Valor nao eh maior que o Limite de Credito                �
				//��������������������������������������������������������������������������
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
				//������������������������������������������������������������������������Ŀ
				//�Verifica as Classes de Cliente                                          �
				//��������������������������������������������������������������������������
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
				//������������������������������������������������������������������������Ŀ
				//�Aqui e verificado o Grau de Risco do Cliente + Loja                     �
				//��������������������������������������������������������������������������
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
						//����������������������������������������������������������Ŀ
						//�Aqui o Loop eh abortado pois esta em ordem de vencto Real �
						//������������������������������������������������������������
						Exit
					EndDo
				EndIf
			EndIf
		EndIf
		//������������������������������������������������������������������������Ŀ
		//�Aqui e verificado apenas o Codigo ( Matriz )                            �
		//��������������������������������������������������������������������������
	Case ( cTipoLim == "C" )
		If ( MsSeek(xFilial("SA1")+cCodCli) )
			//���������������������������������������������������������������Ŀ
			//� O Grau de Risco deve ser Avaliado da Matriz                   �
			//�����������������������������������������������������������������
			If ( SA1->A1_RISCO == "A" )
				lRetorno := .T.
				cCodigo	:= ""
			EndIf
			If ( SA1->A1_RISCO == "E" )
				lRetorno := .F.
				cCodigo 	:= "01" // Limite de Credito
			EndIf
			//������������������������������������������������������������������������Ŀ
			//�Aqui e avaliado o Vencimento do Limite de Credito do Cliente            �
			//��������������������������������������������������������������������������
			If ( !Empty(SA1->A1_VENCLC) .And. SA1->A1_VENCLC < dDataBase )
				lRetorno := .F.
				cCodigo 	:= "04" // Vencimento do Limite de Credito
			EndIf
			//������������������������������������������������������������������������Ŀ
			//�Aqui e verificado o Limite de Credito do Cliente                        �
			//��������������������������������������������������������������������������
			//������������������������������������������������������������������������Ŀ
			//�O Limite de Credito sempre esta na Moeda MV_MCUSTO, mas os calculos sao �
			//�em na moeda corrente.                                                   �
			//��������������������������������������������������������������������������
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
					//������������������������������������������������������������������������Ŀ
					//�Aqui e avaliado o Vencimento do Limite de Credito do Cliente            �
					//��������������������������������������������������������������������������
					If ( !Empty(SA1->A1_VENCLC) .And. SA1->A1_VENCLC < dDataBase )
						lRetorno := .F.
						cCodigo 	:= "04" // Vencimento do Limite de Credito
					EndIf
					dbSelectArea("SA1")
					dbSkip()
				EndDo
				//������������������������������������������������������������������������Ŀ
				//�Verifica se o Valor nao eh maior que o Limite de Credito                �
				//��������������������������������������������������������������������������
				If ( lRetorno .And. nVlrReal > nLimCred .And. nLimCred >= 0 )
					lRetorno := .F.
					cCodigo 	:= "01" // Limite de Credito
				EndIf
				//������������������������������������������������������������������������Ŀ
				//�Verifica as Classes de Cliente                                          �
				//��������������������������������������������������������������������������
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
				//�������������������������������������������������������������Ŀ
				//� Aqui e avaliado o risco do Cliente - ( Matriz + Filiais )   �
				//���������������������������������������������������������������
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

//������������������������������������������������������������������������Ŀ
//�Restaura a Entrada da Rotina                                            �
//��������������������������������������������������������������������������
RestArea(aAreaSA1)
RestArea(aAreaSE1)
RestArea(aArea)

Return(lRetorno)
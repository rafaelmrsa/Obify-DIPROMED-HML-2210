/*
PONTO.......: M410LIOK          PROGRAMA....: MATA410
DESCRIÇÄO...: VALIDACAO DE LINHA DO PEDIDO VENDA
UTILIZAÇÄO..: Validacao de linha no pedido de venda.
PARAMETROS..: Objeto Dialogo (dlg) da tela de pedido
RETORNO.....: Variavel logica, validando (.T.) ou nao (.F.) a linha.
OBSERVAÇÖES.: <NENHUM>
*/
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Funcao    ³ M410LIOK ³ Autor ³   Alexandro Dias      ³ Data ³04.09.2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Desc.     ³ Chama rotina para calculo da margem do pedido.			  ³±±
±±º          ³ Esta rotina (Ponto de Entrada) e executada na mudanca de   ³±±
±±º          ³ linha do aCols do pedido de venda.                         ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
#Include "RwMake.ch"
#Include "PROTHEUS.ch"
*-----------------------------*
User Function M410LIOK()
*-----------------------------*
Local lRet := .t.
Local _nPosItem     := aScan(aHeader, { |x| Alltrim(x[2]) == "C6_ITEM" })
Local _nPosMrgAtu   := aScan(aHeader, { |x| Alltrim(x[2]) == "C6_MARGATU" })
Local _nPosMrgIte   := aScan(aHeader, { |x| Alltrim(x[2]) == "C6_MARGITE" })
Local _nPosTotItem  := aScan(aHeader, { |x| Alltrim(x[2]) == "C6_VALOR"   })
Local _nPosNota     := aScan(aHeader, { |x| Alltrim(x[2]) == "C6_NOTA"    })
Local _nPosTES      := aScan(aHeader, { |x| Alltrim(x[2]) == "C6_TES"     })
Local _nPosPrcven   := aScan(aHeader, { |x| Alltrim(x[2]) == "C6_PRCVEN"  })
Local _nPosQtdVen	:= aScan(aHeader, { |x| Alltrim(x[2]) == "C6_QTDVEN"  })
Local _nPosUPrc 	:= aScan(aHeader, { |x| Alltrim(x[2]) == "C6_USERPRC" })
Local _nPosUDes 	:= aScan(aHeader, { |x| Alltrim(x[2]) == "C6_USERDES" })
Local _nPosPrUnit	:= aScan(aHeader, { |x| Alltrim(x[2]) == "C6_PRUNIT"  })
Local _nPosDescont  := aScan(aHeader, { |x| Alltrim(x[2]) == "C6_DESCONT" })
Local _nPosValDesc  := aScan(aHeader, { |x| Alltrim(x[2]) == "C6_VALDESC" })
Local _nPosProd     := aScan(aHeader, { |x| Alltrim(x[2]) == "C6_PRODUTO" })
Local _nPosQtdLib   := aScan(aHeader, { |x| Alltrim(x[2]) == "C6_QTDLIB"  }) // MCVN - 26/01/2009
Local _nPosQtdEnt   := aScan(aHeader, { |x| Alltrim(x[2]) == "C6_QTDENT"  }) // MCVN - 26/01/2009
Local _nPosQtdEmp   := aScan(aHeader, { |x| Alltrim(x[2]) == "C6_QTDEMP"  }) // MCVN - 26/01/2009
Local _nPosCusto    := aScan(aHeader, { |x| Alltrim(x[2]) == "C6_CUSTO"   }) // MCVN - 26/01/2009
Local _nPosTipoDip  := aScan(aHeader, { |x| Alltrim(x[2]) == "C6_TIPODIP" }) // MCVN - 26/01/2009
Local _nPosQtdOrc   := aScan(aHeader, { |x| Alltrim(x[2]) == "C6_QTDORC"  }) // MCVN - 26/01/2009
Local nFatorRec     := 0  //giovani 08/07/11
Local nPorcAume     := 0  //giovani 08/07/11
Local lAtivado      := .F. // MCVN  26/08/11
Local _Clint        := AllTrim(GetNewPar("ES_C6PEDCL",""))
Local _ProdNcm      := AllTrim(GetNewPar("ES_PRODNCM","032387/010425"))
Local _cVenProSP    := AllTrim(GetNewPar("ES_PVENDSP","020630/020632/020633/020631/"))
Local aAreaSB1 		:= {}
Local aAreaSA1 		:= {}
//guilherme ricci
Local _lEstST		:= .F.
Private _cCliEspecial := GetMV("MV_CLIESPE") // Cliente especial
//giovani 08/07/11
Private _nPrVend    := _nPosPrcven
Private _nPosMini   := aScan(aHeader, { |x| Alltrim(x[2]) == "C6_PRVMINI"  })
Private _nPosSupe   := aScan(aHeader, { |x| Alltrim(x[2]) == "C6_PRVSUPE"  })
Private _nPosCfop   := aScan(aHeader, { |x| Alltrim(x[2]) == "C6_CF"  }) //Giovani Zago 06/09/11

Private _cQry0      := " "//Giovani Zago 29/11/11
//*******************************************************************************

If "MATA310"$Upper(FunName()) .Or. "DIPA072"$Upper(FunName())
	Return .T.
EndIf


U_DIPPROC(ProcName(0),U_DipUsr()) // JBS 05/10/2005 - Gravando o nome do Programa no SZU

// Rotina foi desenvolvida e perto da implantação foi desativada (Essa rotina será utilizada na validação do Frete que seré incluído Automaticamente - MCVN 26/08/11
If lAtivado
	
	IF !aCols[n,Len(aHeader)+1]    //GIOVANI 11/07/11
		SE4->(DbSetOrder(1))
		If !Empty(M->C5_CONDPAG) .And. SE4->(MsSeek(xFilial("SE4")+M->C5_CONDPAG))
			nFatorRec := 1 - (SE4->E4_USERDES/100)
		Else
			nFatorRec := 1
		EndIf
		
		If substr(M->C5_XRECOLH,1,3) $ "ACR"
			nPorcAume:= 1.16
		ElseIf substr(M->C5_XRECOLH,1,3) $ "ISE"
			nPorcAume:= 1.06
		EndIf
		If substr(M->C5_XRECOLH,1,3) $ "ACR/ISE"
			
			If  aCols[n,_nPosSupe] > 0
				If Round(NoRound(aCols[n,_nPosSupe]*nPorcAume,4)*nFatorRec,4) <= aCols[n,_nPrVend]
					
				ELSE
					If !U_DipSenha("MIE", aCols[n][_nPosProd], aCols[n][_nPosTotItem], 0,.f.)//giovani 01/08/11
						Aviso("Atenção","Valor unitário está abaixo do preço de tabela para esta região.",{"OK"})//giovani 01/08/11
						lRet := U_Senha("MIE",aCols[n,_nPosTotItem],aCols[n,_nPosSupe],aCols[n,_nPosMrgIte])//giovani 12/08/11
						If lRet
							U_DipSenha("MIE", aCols[n][_nPosProd], aCols[n][_nPosTotItem], 0,.t.)//giovani 01/08/11
						EndIf
					EndIf
				EndIf
			Else
				If Round(NoRound(aCols[n,_nPosMini]*nPorcAume,4)*nFatorRec,4) <= aCols[n,_nPrVend]
					
				ELSE
					
					If !U_DipSenha("MIE", aCols[n][_nPosProd], aCols[n][_nPosTotItem], 0,.f.)//giovani 01/08/11
						Aviso("Atenção","Valor unitário está abaixo do preço de tabela para esta região.",{"OK"})//giovani 01/08/11
						lRet := U_Senha("MIE",aCols[n,_nPosTotItem],aCols[n,_nPosMini],aCols[n,_nPosMrgIte])//giovani 12/08/11
						
						If lRet
							U_DipSenha("MIE", aCols[n][_nPosProd], aCols[n][_nPosTotItem], 0,.t.)//giovani 01/08/11
						EndIf
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf
	
Else
	
	IF !aCols[n,Len(aHeader)+1] .And. 	lRet     //GIOVANI 11/07/11
		
		SE4->(DbSetOrder(1))
		If !Empty(M->C5_CONDPAG) .And. SE4->(MsSeek(xFilial("SE4")+M->C5_CONDPAG))			
			If SE4->E4_USERDES > 0
				nFatorRec := 1 - (SE4->E4_USERDES/100)
			Else 
				nFatorRec := 1 + (SE4->E4_XUSRACR/100)
			EndIf
		Else
			nFatorRec := 1
		EndIf
		
		If substr(M->C5_XRECOLH,1,3) $ "ACR"
			nPorcAume:= 1.16
		ElseIf substr(M->C5_XRECOLH,1,3) $ "ISE"
			nPorcAume:= 1.06
		EndIf
		If substr(M->C5_XRECOLH,1,3) $ "ACR/ISE"
			If  aCols[n,_nPosSupe] > 0
				If Round(NoRound(aCols[n,_nPosSupe]*nPorcAume,4)*nFatorRec,4) <= aCols[n,_nPrVend]
					//	ALERT("OK")
				ELSE
					aviso("Atenção","Valor unitário está abaixo do preço de tabela para esta região.",{"OK"})
					lRet := .F.
				EndIf
			Else
				If Round(NoRound(aCols[n,_nPosMini]*nPorcAume,4)*nFatorRec,4) <= aCols[n,_nPrVend]
					//	ALERT("OKay")
				ELSE
					lRet := .F.
					aviso("Atenção","Valor unitário está abaixo do preço de tabela para esta região.",{"OK"})
				EndIf
				
			EndIf
		EndIf
	EndIf
	
Endif

//U_DIPG007("M410LIOK")
IF !aCols[n,Len(aHeader)+1] .and. lRet
	
	If cEmpAnt<>"01" .And. Empty(Alltrim(aCols[n,_nPosNota])) //	If aCols[n,_nPosNota] == "      "
		If Empty(M->C5_CONDPAG) .Or. (!Empty(M->C5_CONDPAG) .And. SE4->E4_USERDES = 0)
			
			If (Type("l410Auto") == "U" .OR. !l410Auto) .and.;
				(Type("lTemTesDoacao") == "U" .or. !lTemTesDoacao) .and.;
				(Type("lTemTesGerDup") == "U" .or. lTemTesGerDup)  .and.;
				M->C5_TIPO == 'N'.AND. !M->C5_CLIENTE $ _cCliEspecial
				
				If !U_DipSenha("MA2", aCols[n][_nPosProd], aCols[n][_nPosTotItem], 0,.f.)
					
					lRet := U_Senha("MA2",aCols[n,_nPosTotItem],aCols[n,_nPosMrgAtu],aCols[n,_nPosMrgIte])
					
					If lRet
						U_DipSenha("MA2", aCols[n][_nPosProd], aCols[n][_nPosTotItem], 0,.t.)
					EndIf
					
				EndIf
				
			Else
				lRet := .T.
			Endif
		Endif		
	Else
		lRet := .T.
	EndIf
EndIf



//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄË¿
//³Atualiza descontos especificos³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄËÙ
If aCols[n,_nPosUDes] > 0
	aCols[n,_nPosDescont]	:= 0
	aCols[n,_nPosValDesc]	:= 0
	aCols[n,_nPosPrcVen] 	:= aCols[n,_nPosPrUnit]
	aCols[n,_nPosTotItem] 	:= aCols[n,_nPosPrUnit]*aCols[n,_nPosQtdVen]
	
	If ( Type("l410Auto") == "U" .OR. !l410Auto ) // JBS 12/04/2006
		oGetDad:oBrowse:Refresh()
	EndIf
	//	Ma410Rodap(,,0)
Endif

// Coloca precos de amostra ou doacao  MCVN - 29/08/2007
If SF4->(MsSeek(xFilial("SF4")+aCols[n,aScan(aHeader, { |x| Alltrim(x[2]) == "C6_TES"})]))
	If "AMOSTRA" $ Upper(SF4->F4_TEXTO) .OR.;
		"DOACAO" $ Upper(SF4->F4_TEXTO) .OR.;
		"BONIFICACAO" $ Upper(SF4->F4_TEXTO)
		
		// MCVN 29/08/2007 - Quando for quantias abaixo de um centavo, considerar um centavo de real
		If Round(aCols[n,_nPosCusto] * 0.2,2)> 0.01
			aCols[n,_nPosPrcven]  := Round(aCols[n,_nPosCusto] * 0.2,2)
		Else
			aCols[n,_nPosPrcven]  := 0.01
		EndIf
		aCols[n,_nPosTotItem] := aCols[n,_nPosPrcven] * aCols[n,_nPosQtdVen]
	EndIf
EndIf
//Giovani Zago 06/09/11
If  aCols[n,_nPosTES] = "501" .and. aCols[n,_nPosCfop]  = "5405"
	lRet := .f.
	aviso("Atenção","Tes 501 não pode ter CFOP de 5405.",{"OK"})
EndIf
If  aCols[n,_nPosTES] = "625" .and. aCols[n,_nPosCfop]  <> "5405"   .and. Posicione('SA1', 1, xFilial('SA1') + M->C5_CLIENTE + '01', 'A1_ESTE') = "SP"
	lRet := .f.
	aviso("Atenção","Tes 625 não pode ter CFOP diferente de 5405.",{"OK"})
EndIf
If  aCols[n,_nPosTES] = "625" .and. Posicione('SA1', 1, xFilial('SA1') + M->C5_CLIENTE + '01', 'A1_ESTE') <> "SP"
	lRet := .f.
	aviso("Atenção","Tes 625 não pode ser utilizada fora de São Paulo.",{"OK"})
EndIf

//*****************************************************************************

aAreaSB1 := SB1->(GetArea())
aAreaSA1 := SA1->(GetArea())

SA1->(dbSetOrder(1))
if SA1->(dbSeek(xFilial("SA1")+ M->C5_CLIENTE+M->C5_LOJACLI))
	If  !Empty(SA1->A1_SUFRAMA) .And. SA1->A1_EST $ 'RR/RO/AM/AC/AP'  .And. SA1->A1_CALCSUF $ 'S/I' .And.  SA1->A1_CONTRIB<>'2'
	  	
	  	SB1->(dbSetOrder(1))
	    If SB1->(dbSeek(xFilial("SB1")+aCols[n,_nPosProd])) 
			If cEmpAnt=="04"
				If aCols[n,_nPosTES] = "720" .And. ALLTRIM(Posicione('SF4', 1, xFilial('SF4') +ALLTRIM(SB1->B1_TS),'F4_ICM'))="N" 
					aviso("Atenção","Utilize o TES "+ALLTRIM(SB1->B1_TS) + ". ", {"OK"})
					lRet := .f.
			    ElseIf aCols[n,_nPosTES] = "720" .And. !(SB1->B1_ORIGEM $ '0/4/5')
			    	If SB1->B1_IPI>0
				    	aviso("Atenção","A ORIGEM "+ALLTRIM(SB1->B1_ORIGEM) +" do produto nao da direito ao desconto SUFRAMA. Utilize o TES 702. ",{"OK"})
						lRet := .f.
					Else
						aviso("Atenção","A ORIGEM "+ALLTRIM(SB1->B1_ORIGEM) +" do produto nao da direito ao desconto SUFRAMA. Utilize o TES 703. ",{"OK"})
						lRet := .f.
					EndIf
				ElseIf aCols[n,_nPosTES] <> "720" .And. ALLTRIM(Posicione('SF4', 1, xFilial('SF4') +ALLTRIM(SB1->B1_TS),'F4_ICM')) = "S" 
				    If SB1->B1_ORIGEM $ '0/4/5'  
						aviso("Atenção","Cliente possui Suframa deve-se usar o TES 720.",{"OK"})
						lRet := .f.
					ElseIf !(aCols[n,_nPosTES]$"702/703")   
						If SB1->B1_IPI>0                                                                      
							aviso("Atenção","Cliente possui Suframa deve-se usar o TES 702.",{"OK"})                            
							lRet := .f.
						Else
							aviso("Atenção","Cliente possui Suframa deve-se usar o TES 703.",{"OK"})                            
							lRet := .f.
						EndIf
					EndIf
				EndIf
			Else
			    If aCols[n,_nPosTES] = "727" .And. ALLTRIM(Posicione('SF4', 1, xFilial('SF4') +ALLTRIM(SB1->B1_TS),'F4_ICM')) = "N" 
					aviso("Atenção","Utilize o TES "+ALLTRIM(SB1->B1_TS) + " . ", {"OK"})
					lRet := .f.
			    ElseIf aCols[n,_nPosTES] = "727" .And. !(SB1->B1_ORIGEM$ '0/4/5')
					aviso("Atenção","A ORIGEM "+ALLTRIM(SB1->B1_ORIGEM) +" do produto nao da direito ao desconto SUFRAMA. Utilize o TES 737. ",{"OK"})
					lRet := .f.
				ElseIf aCols[n,_nPosTES] <> "727" .And. ALLTRIM(Posicione('SF4', 1, xFilial('SF4') +ALLTRIM(SB1->B1_TS)  , 'F4_ICM')) = "S" 
				    If SB1->B1_ORIGEM $ '0/4/5'  
						aviso("Atenção","Cliente possui Suframa deve-se usar o TES 727 .",{"OK"})
						lRet := .f.
					ElseIf aCols[n,_nPosTES] <> "737"                                                                         
						aviso("Atenção","Cliente possui Suframa deve-se usar o TES 737 .",{"OK"})                            
						lRet := .f.
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf
EndIf

RestArea(aAreaSA1)
RestArea(aAreaSB1)

If !aCols[n,Len(aHeader)+1] .And. lRet .And. cEmpAnt+cFilAnt == "0104"
	If !(M->C5_NUM$GetNewPar("ES_PEDOKCD",""))
		If !(AllTrim(M->C5_TIPO+aCols[n,_nPosCfop])$GetNewPar("ES_CFOOKCD","N5102/N5119/N5405/N5908/N5910/N5911/N5917/N5923/N6108/N6910/D5202/D5915/D6202"))
			If M->C5_TIPO$"N/D"
				Aviso("Atenção","CAT 198 - CFOP não permitido para este tipo de pedido nesta empresa.",{"Ok"})
				lRet := .F.
			EndIf
		EndIf
	EndIf
EndIf

//Giovani Zago 29/11/11 validar TES com CFOP
If lRet
	_cQry0 :=" SELECT   "
	_cQry0 +=" CASE WHEN (X5_DESCRI LIKE '%"+aCols[n,_nPosCfop]+"%' OR  X5_DESCSPA LIKE '%"+aCols[n,_nPosCfop]+"%' ) THEN '.V.' ELSE '.F.' END AS 'CFOP'  "
	_cQry0 +=" FROM "+RETSQLNAME ("SX5") + " SX5 "
	_cQry0 +=" INNER JOIN(SELECT *   "
	_cQry0 +=" FROM "+RETSQLNAME ("SF4") + " SF4 "
	_cQry0 +=" WHERE SF4.D_E_L_E_T_ = ' ')TF4   "
	_cQry0 +=" ON TF4.F4_FILIAL     = X5_FILIAL "
	_cQry0 +=" AND TF4.F4_CODIGO     =  '"+aCols[n,_nPosTES]+"' "
	_cQry0 +=" AND (X5_DESCRI LIKE '%'+TF4.F4_CF+'%' OR  X5_DESCSPA LIKE '%'+TF4.F4_CF+'%' )  "
	_cQry0 +=" WHERE SX5.D_E_L_E_T_ = ' ' "
	_cQry0 +=" AND    X5_FILIAL    = '"+xFilial("SX5")+"'"
	_cQry0 +=" AND    X5_TABELA     = '4Z'  "
	
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQry0),'TMP1',.T.,.F.)
	
	TMP1->(dbgotop())
	If !EMPTY ("TMP1")
		DbSelectArea("TMP1")
		DbGoTop()
		While TMP1->(!EOF())
			
			If TMP1->CFOP = ".F."
				aviso("Atenção","CFOP em desacordo com a TES, avisar o Departamento de T.I. .",{"OK"})
				lRet := .f.
			EndIf
			
			TMP1->( dbSkip())
		END
	EndIf
	
	TMP1->(DBCloseArea())
EndIf
//**********************************************************************************************************************************************

If lRet .And. cEmpAnt=="01" .And. !aCols[n,Len(aHeader)+1] .And. !Upper(u_DipUsr())$GetNewPar("ES_USR2PRO","JLIMA,DFELLIZARDO")
	If (_nPos := aScan(aCols,{|x| !x[Len(aHeader)+1] .And. x[_nPosProd]==aCols[n,_nPosProd] .And. x[_nPosItem] <> aCols[n,_nPosItem]}))>0
		Aviso("Atenção","Produto já informado no pedido (Item "+aCols[_nPos,_nPosItem]+"). Não será permitido usar o mesmo código em duas linhas diferentes.",{"Ok"},1)
		lRet := .F.
	EndIf
EndIf

//Giovani Zago 27/03/2012
If lRet
	DbSelectArea("SB1")
	SB1->(DbSetOrder(1))
	If !SB1->(DbSeek(xFilial("SB1")+aCols[n,_nPosProd]) )
		Aviso("Atenção","Produto Não Cadastrado.....!!!!!!",{"OK"})//giovani 01/08/11
		lRet := .F.
	EndIf
EndIf

U_DIPG007()	// Para atualizar tela quando deletar/restaurar linhas...  

GrvLog()
                       
// RBORGES - 18/08/16 - Obrigar o usuário a informar a ordem de compras do cliente, caso o mesmo esteja no parâmetro ES_C6PEDCL.
If cEmpAnt == '04' .And. M->C5_CLIENTE $ _Clint .And. Empty(GDFIELDGET("C6_PEDCLI"))
		MsgInfo("Informar a ordem de compra para este cliente, campo 'Ped Cliente'!","ATENÇÃO!")
		lRet := .F.
EndIf
    
//RBORGES - 31/10/18 - Bloquear produtos para determinado cliente. Cliente não aceita produto por causa da classificação NCM.
If lRet .And. cEmpAnt=="01" .And. !aCols[n,Len(aHeader)+1] .And. AllTrim(aCols[n,_nPosProd]) $ _ProdNcm .And. M->C5_CLIENTE $ "014853" 
	Aviso("Atenção","Produto "+AllTrim(aCols[n,_nPosProd])+" não pode ser vendido para este cliente, "+M->C5_CLIENTE+".",{"Ok"},1)
	lRet := .F.
EndIf

//RBORGES - 01/03/19 - Produtos liberados para venda somente em SP.
/*
If lRet .And. cEmpAnt=="01" .And. !aCols[n,Len(aHeader)+1] .And. AllTrim(aCols[n,_nPosProd]) $ _cVenProSP .And. M->C5_ESTE <> "SP" 
	Aviso("ES_PVENDSP","Produto "+AllTrim(aCols[n,_nPosProd])+" só pode ser vendido para SP.",{"Ok"},1)
	lRet := .F.
EndIf
*/
//MCANUTO - 27/03/19 - Produtos bloqueados para venda nos estados de RJ/RS/SC/PA/MG/PE/SE.
If lRet .And. cEmpAnt=="01" .And. !aCols[n,Len(aHeader)+1] .And. AllTrim(aCols[n,_nPosProd]) $ _cVenProSP .And. (M->C5_ESTE $ "RJ/RS/SC/PR/MG/PE/SE") 
	Aviso("ES_PVENDSP","O Produto "+AllTrim(aCols[n,_nPosProd])+" não pode ser vendido para RJ, RS, SC, PA, MG, PE e SE",{"Ok"},1)
	lRet := .F.
EndIf

If UPPER(Alltrim(GetEnvServer())) != 'QBG'

//Regra abaixo desativada, solicitado pelo Maximo  REGRA REATIVADA 09/12/20 com outros produtos, REGRA DESATIVADA NOVAMENTE em 05/01/2021
	//REGRA PARA VENDER LUVAS APENAS A VISTA - MAXIMO
	/*If lRet .And. cEmpAnt =='01'
		If Alltrim(aCols[n,_nPosProd]) $  '080512/080511/080510/080509/012200/012209/425208/010786/080477/080479/010785/080480/012203/012213/425191/012202/012212/425190/080478/012201/012214/425189/080310/080476';
			.And. SA1->A1_CONTRIB <> '2' .And. aCols[n,Len(aHeader)+1] == .F.
			If 	M->C5_CONDPAG <> '001' .And. M->C5_CONDPAG <> '002' .And. M->C5_CONDPAG <> '005'  .And. M->C5_CONDPAG <> '016'  .And. M->C5_CONDPAG <> '602' .And. M->C5_CONDPAG <> '354' .And. M->C5_CONDPAG <> '008';
				.And. M->C5_CONDPAG <> '004' .And. M->C5_CONDPAG <> '005' .And. M->C5_CONDPAG <> '349' .And. M->C5_CONDPAG <> '554' .And. M->C5_CONDPAG <> '606' .And. M->C5_CONDPAG <> '616' .And. M->C5_CONDPAG <> '563' 
				Aviso("Atenção","LUVA SOMENTE  A VISTA OU ATÉ 28 DIAS.",{"Ok"},1)						
				lRet := .F.
			EndIf	
		Endif
	Endif*/
	//FIM REGRA 25/03/2020	//REGRA DESATIVADA NOVAMENTE em 05/01/2021
//*/
	
	// RBorges 13/02/2019 - Chama a função de transferência de produto
	If  !("DIPAL10" $ FunName()) .And. M->C5_TIPODIP == "1" .And. M->C5_TIPO == "N" .And. cEmpAnt == '01' .And. SB1->B1_MALADIR <> 'S'
		U_DIPA053C(.F.)
	EndIf
EndIf


//TES ST para produtos HQ
If  cEmpAnt=="04" 
	aAreaSA1 := SA1->(GetArea())
	SA1->(dbSetOrder(1))
	SA1->(dbSeek(xFilial("SA1")+ M->C5_CLIENTE+M->C5_LOJACLI))


	SB1->(dbSetOrder(1))
	SB1->(dbSeek(xFilial("SB1")+aCols[n,_nPosProd])) 
	If SUBSTR(SB1->B1_POSIPI,1,4)=="3005" .and. aCols[n,_nPosTES] <> "654" .and. SA1->A1_TIPO=="R"
		DbSelectArea("SF7")
		DbSetOrder(1)
		DbSeek(xFilial("SF7")+SB1->B1_GRTRIB)
		While SF7->F7_FILIAL+SF7->F7_GRTRIB==XFILIAL("SF7")+SB1->B1_GRTRIB
			If SF7->F7_EST == SA1->A1_EST
				lRet := .f.
				aviso("Atenção","Produto com ST utilizar TES 654.",{"OK"})
			endif
			SF7->(dbSkip())
		End
	EndIf
	RestArea(aAreaSA1)
EndIf

Return(lRet)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³M410LIOK  ºAutor  ³Microsiga           º Data ³  01/08/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function GrvLog()
Local _nPosItem     := aScan(aHeader, { |x| Alltrim(x[2]) == "C6_ITEM" })
Local _nPosProd     := aScan(aHeader, { |x| Alltrim(x[2]) == "C6_PRODUTO" })
Local _nPosQtdVen	:= aScan(aHeader, { |x| Alltrim(x[2]) == "C6_QTDVEN"  })
Local _nPosPrcven   := aScan(aHeader, { |x| Alltrim(x[2]) == "C6_PRCVEN"  })
Local _nPosTES      := aScan(aHeader, { |x| Alltrim(x[2]) == "C6_TES"     })         

ZC6->(dbSetOrder(2))
If ZC6->(dbSeek(xFilial("ZC6")+M->(C5_NUM+C5_CLIENTE+C5_LOJACLI+C5_OPERADO)+aCols[n,_nPosItem]))
	If !aCols[n,Len(aHeader)+1]
		If 	ZC6->ZC6_PRODUT <> aCols[n,_nPosProd  ] .Or.;
			ZC6->ZC6_QTDVEN <> aCols[n,_nPosQtdVen] .Or.;
			ZC6->ZC6_PRCVEN <> aCols[n,_nPosPrcven] .Or.;
			ZC6->ZC6_TES   	<> aCols[n,_nPosTES   ]	
			ZC6->(RecLock("ZC6",.F.))
				ZC6->ZC6_ITEM   := aCols[n,_nPosItem  ]
				ZC6->ZC6_PRODUT := aCols[n,_nPosProd  ]
				ZC6->ZC6_QTDVEN := aCols[n,_nPosQtdVen]
				ZC6->ZC6_PRCVEN := aCols[n,_nPosPrcven]
				ZC6->ZC6_TES   	:= aCols[n,_nPosTES   ]	
			ZC6->(MsUnLock())			
		EndIf
	Else 
		ZC6->(RecLock("ZC6",.F.))
			ZC6->(dbDelete())
		ZC6->(MsUnLock())		
	EndIf
Else
	ZC6->(RecLock("ZC6",.T.))
		ZC6->ZC6_FILIAL := xFilial("ZC6")
		ZC6->ZC6_NUM    := M->C5_NUM
		ZC6->ZC6_CODCLI	:= M->C5_CLIENTE
		ZC6->ZC6_LOJA   := M->C5_LOJACLI
		ZC6->ZC6_DATA	:= dDataBase
		ZC6->ZC6_OPERAD := M->C5_OPERADO
		ZC6->ZC6_ITEM   := aCols[n,_nPosItem  ]
		ZC6->ZC6_PRODUT := aCols[n,_nPosProd  ]
		ZC6->ZC6_QTDVEN := aCols[n,_nPosQtdVen]
		ZC6->ZC6_PRCVEN := aCols[n,_nPosPrcven]
		ZC6->ZC6_TES   	:= aCols[n,_nPosTES   ]	
	ZC6->(MsUnLock())
EndIf                                         
	
Return                         
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³M410LIOK  ºAutor  ³Microsiga           º Data ³  02/11/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function ImpZC6()                
Local aDados 	:={}
Local lQuery    := .F.
Local oModel
Private aRCampos:={}
Private aReturn := {"Zebrado", 1,"Administracao", 2, 2, 1,"",1}
Private cString :="ZC6"  

aAdd(aDados,"QRYZC6") 
aAdd(aDados,OemTOAnsi("Imprime BKP pedidos",72)) //Descrição rodape tela de parametros
aAdd(aDados,"")
aAdd(aDados,"")
aAdd(aDados,"M")
aAdd(aDados,132)
aAdd(aDados," Cliente: "+M->C5_CLIENTE+" Operador(a): "+Posicione("SU7",1,xFilial("SU7")+M->C5_OPERADO,"U7_NOME"))
aAdd(aDados," ")
aAdd(aDados," BACKUP DO PEDIDO DE VENDAS ") //Título do relatório
aAdd(aDados,aReturn)
aAdd(aDados,"IMPZC6") 
aAdd(aDados,{{||.t.},{||.t.}})
aAdd(aDados,Nil) 

aAdd(aRCampos,{"ZC6_NUM" 	,"",AvSx3("ZC6_NUM"    ,5),AvSx3("ZC6_NUM"    ,6)})
aAdd(aRCampos,{"ZC6_ITEM" 	,"",AvSx3("ZC6_ITEM"   ,5),AvSx3("ZC6_ITEM"   ,6)})
aAdd(aRCampos,{"ZC6_PRODUT" ,"",AvSx3("ZC6_PRODUT" ,5),AvSx3("ZC6_PRODUT" ,6)})
aAdd(aRCampos,{"ZC6_DESCRI" ,"",AvSx3("B1_DESC"    ,5),AvSx3("B1_DESC" 	  ,6)})
aAdd(aRCampos,{"ZC6_QTDVEN" ,"",AvSx3("ZC6_QTDVEN" ,5),AvSx3("ZC6_QTDVEN" ,6)})
aAdd(aRCampos,{"ZC6_PRCVEN" ,"",AvSx3("ZC6_PRCVEN" ,5),AvSx3("ZC6_PRCVEN" ,6)})    
aAdd(aRCampos,{"ZC6_TES" 	,"",AvSx3("ZC6_TES"    ,5),AvSx3("ZC6_TES"    ,6)})  

aRCampos:=E_CriaRCampos(aRCampos,"E")   

Processa({|| lQuery := DipQryZC6(M->C5_CLIENTE,M->C5_OPERADO)},"Filtrando dados da Requisição...",,.t.)

If !lQuery
	Aviso("Atenção","Não encontrado dados que satisfaçam aos"+CHR(10)+CHR(13)+;
					"parametros informados pelo usuario! ",{"Ok"},1)
	QRYZC6->(dbCloseArea())
Else
	QRYZC6->(u_DipReport(aDados,aRCampos,nil,nil,2))
	QRYZC6->(dbCloseArea())	
EndIf   

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³M410LIOK  ºAutor  ³Microsiga           º Data ³  02/11/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function DipQryZC6(cCodCli,cOperado)
Local cSQL := ""
DEFAULT cCodCli  := ""
DEFAULT cOperado := ""

ProcRegua(0)
                                                                                
cSQL := " SELECT "
cSQL += " 	ZC6_NUM, ZC6_ITEM, ZC6_PRODUT, B1_DESC AS ZC6_DESCRI, ZC6_QTDVEN, ZC6_PRCVEN, ZC6_TES "
cSQL += " 	FROM "
cSQL +=  		RetSQLName("ZC6")
cSQL += " 			LEFT JOIN "
cSQL += 			RetSQLName("SB1")
cSQL += " 				ON "
cSQL += " 				B1_FILIAL = ZC6_FILIAL AND "
cSQL += " 				B1_COD = ZC6_PRODUT AND "
cSQL += 				RetSQLName("SB1")+".D_E_L_E_T_ = ' ' "
cSQL += " 		WHERE "
cSQL += " 			ZC6_FILIAL = '"+xFilial("ZC6")+"' AND "
cSQL += " 			ZC6_CODCLI = '"+cCodCli +"' AND "
cSQL += " 			ZC6_DATA   = '"+DtoS(dDataBase)+"' AND "
cSQL += " 			ZC6_OPERAD = '"+cOperado+"' AND "
cSQL += 			RetSQLName("ZC6")+".D_E_L_E_T_ = ' ' "
cSQL += " ORDER BY ZC6_NUM, ZC6_ITEM "
			
cSQL := ChangeQuery(cSQL)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),"QRYZC6",.T.,.T.)

Return(!QRYZC6->(Eof()))
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³M410LIOK  ºAutor  ³Microsiga           º Data ³  01/15/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³  Função chamada do PE A410Cons  							  º±±
±±º          ³  Reservado para segunda fase do projeto                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function Fase2()                    
Local cSQL 		:= ""                           
Local bOk    	:= {|| oDlg:End()}
Local bCancel   := {|| oDlg:End()}       
Private aHeader := {}
Private aCols   := {}
Private aSize   := MsAdvSize()
Private aInfo   := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 5, 5 }
Private aObjects:= { { 100, 100, .T., .T. } , { 200, 200, .T., .T. } }
Private aPosObj := MsObjSize( aInfo, aObjects,.T.)
Private oGetDados  
Private oDlg

SX3->(dbSetOrder(2))
If SX3->(dbSeek("ZC6"))
	While !SX3->(Eof()) .And. SX3->X3_ARQUIVO == "ZC6" 
		If X3Uso(SX3->X3_USADO) .And. cNivel >= SX3->X3_NIVEL .And. AllTrim(SX3->X3_CAMPO)$"ZC6_NUM/ZC6_CODCLI/ZC6_LOJA/ZC6_DATA/ZC6_OPERAD"
			AAdd(aHeader,{ 	AllTrim(SX3->X3_TITULO),; 
							SX3->X3_CAMPO,; 
							SX3->X3_PICTURE,;
							SX3->X3_TAMANHO,;
							SX3->X3_DECIMAL,;
							SX3->X3_VALID,;
							SX3->X3_USADO,;
							SX3->X3_TIPO,;
							SX3->X3_ARQUIVO,;
							SX3->X3_CONTEXT } )
		EndIf
		SX3->(dbSkip())
	EndDo
EndIf	

cSQL := " SELECT DISTINCT "
cSQL += " 	ZC6_NUM, ZC6_CODCLI, ZC6_LOJA, ZC6_DATA, ZC6_OPERAD "
cSQL += " 	FROM "
cSQL += 		RetSQLName("ZC6")
cSQL += " 		WHERE "
cSQL += " 			ZC6_FILIAL 	= '"+xFilial("ZC6")	+"' AND "
cSQL += " 			ZC6_CODCLI 	= '"+M->C5_CLIENTE	+"' AND "
cSQL += " 			ZC6_LOJA 	= '"+M->C5_LOJACLI	+"' AND "
cSQL += " 			ZC6_OPERAD 	= '"+M->C5_OPERADO	+"' AND "
cSQL += " 			ZC6_DATA 	= '"+DtoS(dDataBase)+"' AND "
cSQL += " 			D_E_L_E_T_ 	= ' ' "
                                                          
cSQL := ChangeQuery(cSQL)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),'TRBZC6',.T.,.F.)

TCSETFIELD("TRBZC6","ZC6_DATA","D",8,0)

While !TRBZC6->(Eof())

	aAdd(aCols,{ TRBZC6->ZC6_CODCLI,;
				 TRBZC6->ZC6_DATA,;
				 TRBZC6->ZC6_LOJA,;				 				
				 TRBZC6->ZC6_NUM,;               
				 TRBZC6->ZC6_OPERAD }) 
	
	TRBZC6->(dbSkip())                      
EndDo
TRBZC6->(dbCloseArea())

DEFINE MSDIALOG oDlg FROM aSize[7],0 TO aSize[6]-30,aSize[5]-50 TITLE "Importa BKP" OF oMainWnd PIXEL

oGetDados:=MsNewGetDados():New(aPosObj[2,1]-32,aPosObj[2,2],aPosObj[2,3]-13,aPosObj[2,4]-22,nil/*nStyle*/,/*LinOK*/,/*TudoOK*/,,,/*freeze*/,/*maxlin*/,/*FldOK*/,/*superdel*/,/*delok*/,oDlg,@aHeader,@aCols)

oGetDados:oBrowse:bAdd    := {|| .F. }      // Nao Permite a inclusao de Linhas
oGetDados:oBrowse:bDelete := {|| .F. }	    // Nao Permite a deletar Linhas

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,bOk,bCancel) CENTERED

Return

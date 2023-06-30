#include "RwMake.ch"
#INCLUDE "PROTHEUS.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³ MT100LOK º Autor ³ Eriberto Elias      º Data ³  06/10/2003 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Valida alteracao do TES quando muda de linha                º±±
±±º          ³                                                             º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
Alterado em 11/01/2004 - Eriberto - coloquei validacao do lote para produto que usam rastro
*/

User Function MT100LOK()

DEFAULT C103TP		:= "N" //Rafael Rosa Obify 23/06/2022
DEFAULT L103AUTO	:= .F. //Rafael Rosa Obify 30/06/2022

Local _xArea      := GetArea()
Local _xAreaSB1   := SB1->(GetArea())
Local _xAreaSF1   := SF1->(GetArea())
Local _lRetorno   := .T.
Local cDevVend    := C103TP

Local cMsgErr       := "Item com divergencia de lote: " + CHR(13)+CHR(10) + CHR(13)+CHR(10) //Rafael Moraes Rosa - 28/12/2022

Private cValResult:=  "" // giovani 09/08/11
Private aMsg      := {}
Private _nPosClasif := aScan(aHeader, { |x| Alltrim(x[2]) ==  "D1_CLASFIS"})

//Validar o preenchimento do item da NF de Origem HQ - Felipe Duran 03/06/2020
Private _nPosNFOri  := aScan(aHeader, { |x| Alltrim(x[2]) ==  "D1_NFORI"})
Private _nPosItOri  := aScan(aHeader, { |x| Alltrim(x[2]) ==  "D1_ITEMORI"})
Private cNFOri    := aCols[n,_nPosNFOri]
Private cItemOri  := aCols[n,_nPosItOri]

Public aDipSenhas

//validação para bloqueio de criação de doc de entrada de devolução de vendas com as tes abaixo, solicitada por Sirlene 08/09/2020 Blandino
//Regra desabilitada dia 08/09/22 - Solicitado pela Renata Rigo

/*If cDevVend == "D" .and. aCols[1][13] $ "1102 /1403 /2102 /2411 "
	
	MsgInfo("Codigo fiscal não disponivel para esse tipo de documento.","Atenção!!!")	//Regra desabilitada dia 08/09/22 - Solicitado pela Renata Rigo
	_lRetorno := .F.
Endif*/

U_DIPPROC(ProcName(0),U_DipUsr()) // JBS 05/10/2005 - Gravando o nome do Programa no SZU

If "MATA119" $ FunName()  .Or. FwIsInCallStack("U_DIPEXCRES") // Quando venho de DESPESAS DE IMPORTACAO defino l103auto
	l103auto := .T.
EndIf

if l103auto //type("_lMSEXECAUTO") != "U" // estou vindo do MSEXECAUTO DIPA027 e vou voltar rapidamente
	RestArea(_xAreaSB1)
	RestArea(_xArea)
	Return(_lRetorno)
endif

DbSelectArea("SF4")
DbSetOrder(1)
DbSeek(xFilial("SF4")+aCols[n,aScan(aHeader, { |x| Alltrim(x[2]) == "D1_TES"})])

DbSelectArea("SB1")
DbSetOrder(1)
DbSeek(xFilial("SB1")+aCols[n,aScan(aHeader, { |x| Alltrim(x[2]) == "D1_COD"})])


If Rastro(SB1->B1_COD) .and. ;
	Empty(aCols[n,aScan(aHeader, { |x| Alltrim(x[2]) == "D1_LOTECTL"})]) .and. ;
	SF4->F4_ESTOQUE == 'S'
	
	MsgInfo("Preencha o campo Lote.","Atenção!!!")
	_lRetorno := .F.
EndIf

//-- Valida se o Produto possui TES padrão de Entrada cadastrada - D'Leme - 10/10/2011
If _lRetorno .And. Empty(SB1->B1_TE)
	_lRetorno := .F.
	MsgAlert("O Produto " + SB1->B1_COD + " não possui TES padrão de Entrada indicada em seu cadastro!","Atenção")
EndIf


If _lRetorno .and. SB1->B1_TE <> aCols[n,aScan(aHeader, { |x| Alltrim(x[2]) == "D1_TES"})] .and. Type("lDipa046Dv") = "U"  .and. Type("lDipa048Dv") = "U"
	If u_VldTesD1(SB1->B1_TE) <> aCols[n,aScan(aHeader, { |x| Alltrim(x[2]) == "D1_TES"})]
		//M->D1_TES
		_lRetorno := U_SENHA("TES",aCols[n,aScan(aHeader, { |x| Alltrim(x[2]) == "D1_VUNIT"})]*1313*VAL(aCols[n,aScan(aHeader, { |x| Alltrim(x[2]) == "D1_TES"})]))
		
		// Giovani Zago 17/08/11  envia e-mail na liberação de tes mediante senha
		//Comentado por Tiago Stocco - ate arrumar o fonte Senha
		//If _lRetorno
		//	EnvMaiTes()
		//Endif
		//*****************************************************************************************************
	EndIf	
EndIf

//If _lRetorno .And. SB1->B1_RASTRO+SB1->B1_LOTEDIP='LS' .And. aCols[n,aScan(aHeader, { |x| Alltrim(x[2]) == "D1_DTVALID"})] < DATE()+180 .and. Type("lDipa046Dv") = "U" .and. Type("lDipa048Dv") = "U"
If _lRetorno .And. SB1->B1_RASTRO='L' .And. aCols[n,aScan(aHeader, { |x| Alltrim(x[2]) == "D1_DTVALID"})] < DATE()+180 .and. Type("lDipa046Dv") = "U" .and. Type("lDipa048Dv") = "U"
	
	//Giovani Zago 17/08/11   pede senha para validade do lote inferior a 6 meses - envia email
	If !U_DipSenha("DTV", aCols[n,aScan(aHeader, { |x| Alltrim(x[2]) == "D1_ITEM"})], VAL(DTOS(aCols[n,aScan(aHeader, { |x| Alltrim(x[2]) == "D1_DTVALID"})])), 2,.f.)
		
		lRet :=	U_Senha("DTV", aCols[n,aScan(aHeader, { |x| Alltrim(x[2]) == "D1_ITEM"})], VAL(DTOS(aCols[n,aScan(aHeader, { |x| Alltrim(x[2]) == "D1_DTVALID"})])),2)
		
		If lRet
			U_DipSenha("DTV", aCols[n,aScan(aHeader, { |x| Alltrim(x[2]) == "D1_ITEM"})], VAL(DTOS(aCols[n,aScan(aHeader, { |x| Alltrim(x[2]) == "D1_DTVALID"})])), 2,.t.)
			//EnvMaLote() //Revisar essa questao
		Else
			_lRetorno := .F.
		EndIf
	EndIf
	//***********************************************************************************************************************
	
Endif 

	//Giovani Zago 26/01/2012      ATUALIZA D1_CLASIFS
If _lRetorno
	
	DbSelectArea("SF4")
	SF4->(DbSetOrder(1))
	SF4->(DbSeek(xFilial("SF4")+aCols[n,aScan(aHeader, { |x| Alltrim(x[2]) == "D1_TES"})]) )
	
	DbSelectArea("SB1")
	SB1->(DbSetOrder(1))
	If SB1->(DbSeek(xFilial("SB1")+aCols[n,aScan(aHeader, { |x| Alltrim(x[2]) == "D1_COD"})]))
		
		_nPosQtd := aScan(aHeader, { |x| Alltrim(x[2]) == "D1_QUANT"})
		_nPosLoc := aScan(aHeader, { |x| Alltrim(x[2]) == "D1_LOCAL"})
		
		If SB1->B1_XTPEMBV=="1" .And. SB1->B1_XQTDEMB > 0
			nQtdCxEmb:= SB1->B1_XQTDEMB 
			lCancel  := Mod(aCols[n,_nPosQtd],nQtdCxEmb)>0  
		ElseIf SB1->B1_XTPEMBV=="2" .And. SB1->B1_XQTDSEC > 0
			nQtdCxEmb:= SB1->B1_XQTDSEC  
			lCancel  := Mod(aCols[n,_nPosQtd],nQtdCxEmb)>0
		Else
			nQtdCxEmb:= 1                            
			lCancel  := Mod(aCols[n,_nPosQtd],nQtdCxEmb)>0		
		EndIf
		
		If SB1->B1_XCXFECH == "1" .And. SB1->B1_XVLDCXE == "1" .And. lCancel .And. aCols[n,_nPosLoc] == "01"
			Aviso("ATENCAO","Produto "+SB1->B1_COD+CHR(13)+CHR(10)+"está na regra de caixa fechada."+CHR(13)+CHR(10)+"Fazer entrada múltipla de "+cValToChar(nQtdCxEmb),{"Ok"},1)
			_lRetorno := .F.
		EndIf
		
		If cEmpAnt=="04"
			If !EMPTY(cNFOri) .AND. EMPTY(cItemOri)
				Aviso("ATENÇÃO - Item Orig","Campo Item Original está em Branco. Favor Preencher!",{"Ok"} )
				_lRetorno:= .F.         
			Endif
		Endif	
		
		aCols[n,_nPosClasif]  := ALLTRIM(SB1->B1_ORIGEM)+Alltrim(SF4->F4_SITTRIB)
	EndIf		
Endif

If _lRetorno .And. cEmpAnt=="04" .And. !Upper(U_DipUsr())$GetNewPar("ES_MTLOCAL","CSOSSOLOTE")
	If cFilAnt=="01"
		If  SB1->B1_TIPO$"MC" .And. SF4->F4_ESTOQUE="S" .And. aCols[n,aScan(aHeader, { |x| Alltrim(x[2]) == "D1_LOCAL"})]<>"02"
			Aviso("ATENÇÃO","Utilize o local 02 para dar entrada neste produto",{"Ok"})		
			_lRetorno := .F.
		ElseIf  SB1->B1_TIPO$"MP/PA" .And. SF4->F4_ESTOQUE="S" .And. aCols[n,aScan(aHeader, { |x| Alltrim(x[2]) == "D1_LOCAL"})]<>"01"
			Aviso("ATENÇÃO","Utilize o local 01 para dar entrada neste produto",{"Ok"})		
			_lRetorno := .F.
		ElseIf SB1->B1_TIPO$"PI" .And. SF4->F4_ESTOQUE="S" .And. aCols[n,aScan(aHeader, { |x| Alltrim(x[2]) == "D1_LOCAL"})]<>"04"
			Aviso("ATENÇÃO","Utilize o local 04 para dar entrada neste produto",{"Ok"})		
			_lRetorno := .F.			
		ElseIf SB1->B1_TIPO$"BN" .And. SF4->F4_ESTOQUE="S" .And. aCols[n,aScan(aHeader, { |x| Alltrim(x[2]) == "D1_LOCAL"})]<>"06"
			Aviso("ATENÇÃO","Utilize o local 06 para dar entrada neste produto",{"Ok"})		
			_lRetorno := .F.						
		EndIf
	ElseIf cFilAnt=="02"
		If SB1->B1_TIPO$"PA/MP" .And. SF4->F4_ESTOQUE="S" .And. aCols[n,aScan(aHeader, { |x| Alltrim(x[2]) == "D1_LOCAL"})]<>"01"
			Aviso("ATENÇÃO","Utilize o local 01 para dar entrada neste produto",{"Ok"})		
			_lRetorno := .F.
		ElseIf SB1->B1_TIPO$"PI" .And. SF4->F4_ESTOQUE="S" .And. aCols[n,aScan(aHeader, { |x| Alltrim(x[2]) == "D1_LOCAL"})]<>"04"
			Aviso("ATENÇÃO","Utilize o local 04 para dar entrada neste produto",{"Ok"})		
			_lRetorno := .F.			
		ElseIf SB1->B1_TIPO$"BN" .And. SF4->F4_ESTOQUE="S" .And. aCols[n,aScan(aHeader, { |x| Alltrim(x[2]) == "D1_LOCAL"})]<>"06"
			Aviso("ATENÇÃO","Utilize o local 06 para dar entrada neste produto",{"Ok"})		
			_lRetorno := .F.						
		EndIf
	EndIf
EndIf

	//Rafael Moraes Rosa - 28/12/2022 - INICIO
	//Tratamento para validacao do lote (por item da NF) X Data da Validade com saldo em estoque
	IF Posicione("SF4",1,xFilial("SF4")+aCols[n,aScan(aHeader, { |x| Alltrim(x[2]) == "D1_TES"})],"F4_DUPLIC") = "S" .AND. !Empty(aCols[n,aScan(aHeader, { |x| Alltrim(x[2]) == "D1_LOTECTL"})])

            DbSelectArea("SB8")
            SB8->(DbSetOrder(3))
            IF SB8->(dbSeek(xFilial("SB8") + aCols[n,aScan(aHeader, { |x| Alltrim(x[2]) == "D1_COD"})] + aCols[n,aScan(aHeader, { |x| Alltrim(x[2]) == "D1_LOCAL"})] + aCols[n,aScan(aHeader, { |x| Alltrim(x[2]) == "D1_LOTECTL"})]))		
                SB8->(RecLock("SB8", .F.))
                    IF SB8->B8_SALDO > 0 .AND. aCols[n,aScan(aHeader, { |x| Alltrim(x[2]) == "D1_DTVALID"})] <> SB8->B8_DTVALID
						cMsgErr += "Produto: " + aCols[n,aScan(aHeader, { |x| Alltrim(x[2]) == "D1_COD"})] + CHR(13)+CHR(10)
						cMsgErr += "Armazem: " + aCols[n,aScan(aHeader, { |x| Alltrim(x[2]) == "D1_LOCAL"})] + CHR(13)+CHR(10)
						cMsgErr += "Lote: " + aCols[n,aScan(aHeader, { |x| Alltrim(x[2]) == "D1_LOTECTL"})] + CHR(13)+CHR(10)
						cMsgErr += "Dt. Validade: " + DTOS(aCols[n,aScan(aHeader, { |x| Alltrim(x[2]) == "D1_DTVALID"})]) + CHR(13)+CHR(10)

						FWAlertError(cMsgErr  + CHR(13)+CHR(10) + "Corrija o estoque do lote.", "Lote Divergente.")	
						_lRetorno	:= .F.

                    ENDIF
                SB8->(MsUnlock())
            ENDIF
            SB8->(dbSkip())

    ENDIF
	//Tratamento para validacao do lote (por item da NF) X Data da Validade com saldo em estoque
	//Rafael Moraes Rosa - 28/12/2022 - FIM

RestArea(_xAreaSB1)
RestArea(_xArea)
RestArea(_xAreaSF1)
Return(_lRetorno)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³ EnvMaiTes  º Autor ³ Giovani Zago      º Data ³  17/08/2011 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Envia e-mail na liberação de TES                            º±±
±±º          ³                                                             º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function EnvMaiTes()

cValResult:=  U_SENHAMAIL( SENHA, SENHAMAIL)
If !Empty(cValResult)
	aAdd( aMsg , { "EMPRESA"      , + Capital( AllTrim( SM0->M0_NOME))+"/"+Capital( AllTrim( SM0->M0_FILIAL))+ ""   } )
	aAdd( aMsg , { "FORNECEDOR"   , ""+CA100FOR+" - "+ALLTRIM(Substr(POSICIONE("SA2",1,xfilial("SA2")+CA100FOR + CLOJA,"A2_NOME"),1,50))+""  } )
	aAdd( aMsg , { "SERIE"        , ""+CSERIE+""  } )
	aAdd( aMsg , { "NOTA"         , ""+CNFISCAL+""  } )
	aAdd( aMsg , { "EMISSÂO"      , ""+DTOC(DDEMISSAO)+""  } )
	aAdd( aMsg , { "ITEM"         , ""+aCols[n,aScan(aHeader, { |x| Alltrim(x[2]) == "D1_ITEM"})]+""  } )
	aAdd( aMsg , { "TES"          , ""+aCols[n,aScan(aHeader, { |x| Alltrim(x[2]) == "D1_TES"})]+""  } )
	aAdd( aMsg , { "USUARIO"     , ""+	Upper(U_DipUsr())+""  } )
	aAdd( aMsg , { "SENHA"       , ""+ cValResult +""  } )
	U_EnvSenhMail("C",aMsg)
EndIf
aMsg:={}

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³ EnvMaLote  º Autor ³ Giovani Zago      º Data ³  17/08/2011 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Envia e-mail na liberação de lote com validade inferior     º±±
±±º          ³ a 6 meses                                                   º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function EnvMaLote()

cValResult:=  U_SENHAMAIL(_cValFrete)
If !Empty(cValResult)
	aAdd( aMsg , { "EMPRESA"      , + Capital( AllTrim( SM0->M0_NOME))+"/"+Capital( AllTrim( SM0->M0_FILIAL))+ ""   } )
	aAdd( aMsg , { "FORNECEDOR"   , ""+CA100FOR+" - "+ALLTRIM(Substr(POSICIONE("SA2",1,xfilial("SA2")+CA100FOR + CLOJA,"A2_NOME"),1,50))+""  } )
	aAdd( aMsg , { "SERIE"        , ""+CSERIE+""  } )
	aAdd( aMsg , { "NOTA"         , ""+CNFISCAL+""  } )
	aAdd( aMsg , { "EMISSÂO"      , ""+DTOC(DDEMISSAO)+""  } )
	aAdd( aMsg , { "ITEM"         , ""+aCols[n,aScan(aHeader, { |x| Alltrim(x[2]) == "D1_ITEM"})]+""  } )
	aAdd( aMsg , { "LOTE"         , ""+aCols[n,aScan(aHeader, { |x| Alltrim(x[2]) == "D1_LOTECTL"})]+""  } )
	aAdd( aMsg , { "VALIDADE DO LOTE" , ""+dtoc(aCols[n,aScan(aHeader, { |x| Alltrim(x[2]) == "D1_DTVALID"})])+""  } )
	aAdd( aMsg , { "USUARIO"     , ""+	Upper(U_DipUsr())+""  } )
	U_EnvSenhMail("A",aMsg)
	aAdd( aMsg , { "SENHA"       , ""+ cValResult +""  } )
	U_EnvSenhMail("B",aMsg)
EndIf
aMsg:={}

Return()

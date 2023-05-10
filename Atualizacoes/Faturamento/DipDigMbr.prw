#Include "PROTHEUS.CH"
#Include "RWMAKE.CH"
#Include "MSOLE.CH"
#INCLUDE "AP5MAIL.CH"
#INCLUDE "COLORS.CH"
#DEFINE  CR    chr(13)+chr(10)     
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDIPDIGMBR บAutor  ณMicrosiga           บ Data ณ  10/24/14   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function DipDigMbr(nFil)       
Private aRotina   := {}
Private cCadastro := "APROVACAO"
Private aCores    := {}
Private cPostUsu  := u_DipVeUSer()
Private aVlrInf	  := {}         
Private cPagto	  := ""
Private nPosSta   := 0
Private nPosPro   := 0
Private nPosDes   := 0
Private nPosQtd   := 0
Private nPosCus   := 0
Private nPosMCu   := 0
Private nPosLis   := 0
Private nPosMLi   := 0
Private nPosPrc   := 0
Private nPosTot   := 0
Private nPosVSu   := 0
Private nPosVlr   := 0
Private nPosTEs   := 0
Private nPosUpr   := 0
Private nPosVMi   := 0
Private nPosOri   := 0
Private nPosMed   := 0
Private nPosIte   := 0
Private nPosDif   := 0
Private nFilt     := nFil

U_DIPPROC(ProcName(0),u_DipUsr())

aAdd( aRotina, { "Avaliar"    , "U_DipAvali" , 0 , 2 })
If AllTrim(Upper(U_DipUsr())) $ GetMv("ES_APRODIG",,"")
	aAdd( aRotina, { "Incluir Apr."    , "U_DipAprUse" , 0 , 3 })
EndIf
aadd( aRotina, { "Legenda"	  , "U_LegDig"   , 0 , 6 })

aAdd(aCores,{"ZR_STATUS = 'AVALIANDO'","BR_AZUL"     })
aAdd(aCores,{"ZR_STATUS = 'AGUARDANDO'","BR_VERDE"   })
aAdd(aCores,{"ZR_STATUS = 'REPROVADO'" ,"BR_VERMELHO"})
aAdd(aCores,{"ZR_STATUS = 'APROVADO'"  ,"BR_PRETO"   })

dbSelectArea("SZR")
dbSetOrder(4)

If nFilt == 1
	SZR->(dbSetFilter({|| SZR->ZR_FILIAL==xFilial("SZR") .And. alltrim(SZR->ZR_STATUS) $ 'AGUARDANDO' .And. alltrim(SZR->ZR_POSTO)  $ cPostUsu }," SZR->ZR_FILIAL==xFilial('SZR') .And. alltrim(SZR->ZR_STATUS) $ 'AGUARDANDO' .And. alltrim(SZR->ZR_POSTO) $ cPostUsu  "))
	SZR->(dbGoTop())
Else
	SZR->(dbSetFilter({|| SZR->ZR_FILIAL==xFilial("SZR") .And. alltrim(SZR->ZR_STATUS) $ 'AVALIANDO' .And. alltrim(SZR->ZR_POSTO)  $ cPostUsu }," SZR->ZR_FILIAL==xFilial('SZR') .And. alltrim(SZR->ZR_STATUS) $ 'AVALIANDO' .And. alltrim(SZR->ZR_POSTO) $ cPostUsu  "))
	SZR->(dbGoTop())
EndIf

mBrowse(6,1,22,75,"SZR",,,,,,aCores)

Return ()
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDIPDIGMBR บAutor  ณMicrosiga           บ Data ณ  10/24/14   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function DipAvali()
Local  lSaida        := .f.
Local cGetMotivo     := Space(90)
Local oDlg                    
Local aDados		 := {}
Local cDescCP		 := ""
Local nLinAux		 := 0 
Private cObsOper	 := ""
Private oObjBrow  	 := GetObjBrow()  
Private  _cQry0      := ""
Private oFont24  	 := TFont():New("Times New Roman",9,24,.T.,.T.,5,.T.,5,.T.,.F.)
Private oFont16  	 := TFont():New("Arial",9,14,.T.,.T.,5,.T.,5,.T.,.F.)
Private oFont17  	 := TFont():New("Arial",9,15,.T.,.F.,5,.T.,5,.T.,.F.)
Private oFont30  	 := TFont():New("Arial",9,28,.T.,.T.,5,.T.,5,.T.,.F.)
Private nOpcao       := 0
Private nLim         := 15
Private nColu        := 10
Private cComEnv      := ""
Private aMsg         :={}
Private cOperMail    :=""
Private cMail        := ""
Private cCicDe       := ""

If !LockByName("AVALIANDO "+SZR->ZR_NUMERO,.T.,.F.)
	Aviso("Aten็ใo","Este pedido esta em avalia็ใo! Tente  mais tarde!",{"Ok"},1)
Else
	
	
	_cQry0 :=" SELECT          "
	_cQry0 +=" C5_CLIENTE+' - '+A1_NREDUZ  AS 'NOME', "
	_cQry0 +=" C5_NUM                          AS 'PEDIDO',  "
	_cQry0 +=" C5_OPERADO+' - '+U7_NOME    AS 'OPERADOR',  "
	_cQry0 +=" U7_POSTO+' - '+(CASE WHEN U7_POSTO = 01 THEN 'APOIO' WHEN U7_POSTO = 02 THEN 'TELEVENDAS' WHEN U7_POSTO = 03  THEN 'LICITAวรO' WHEN U7_POSTO = 04  THEN 'SAC'WHEN U7_POSTO = 05  THEN 'COBRANวA' WHEN U7_POSTO = 06  THEN 'HQ' ELSE 'OUTROS' END)	AS 'POSTO' ,  "
	_cQry0 +=" SUM(C6_VALOR) + SUM(C5_FRETE) + SUM(C5_DESPESA)                   AS 'VALOR',  "
	_cQry0 +=" C5_CONDPAG                      AS 'CONDPAG', "
	_cQry0 +=" C5_FILIAL                       AS 'FILIAL', " 
	_cQry0 +=" C5_TPFRETE                       AS 'FRETE', "
	_cQry0 +=" C5_TRANSP+' - '+A4_NREDUZ   AS 'TRANSPORTADORA'  "
	_cQry0 +=" FROM "+RETSQLNAME ("SC5")
	// INICIO - Altera็ใo para teste de performance.
	_cQry0 +=" 			INNER JOIN "
	_cQry0 += 				RetSQLName("SC6")
	_cQry0 +=" 				ON "
	_cQry0 +=" 					C6_FILIAL = C5_FILIAL  AND "
	_cQry0 +=" 					C6_NUM = C5_NUM AND "
	_cQry0 +=" 					C6_CLI = C5_CLIENTE AND "
	_cQry0 +=" 					C6_LOJA = C5_LOJACLI AND "
	_cQry0 += 					RetSQLName("SC6")+".D_E_L_E_T_ = ' ' "
	_cQry0 +=" 			INNER JOIN "
	_cQry0 += 				RetSQLName("SA1")
	_cQry0 +=" 				ON "
	_cQry0 +=" 					A1_FILIAL = '"+xFilial("SA1")+"' AND "
	_cQry0 +=" 					A1_COD = C5_CLIENTE  AND "
	_cQry0 +=" 					A1_LOJA = C5_LOJACLI AND "
	_cQry0 += 					RetSQLName("SA1")+".D_E_L_E_T_ = ' ' "
	_cQry0 +=" 			INNER JOIN "
	_cQry0 += 				RetSQLName("SA4")
	_cQry0 +=" 				ON "
	_cQry0 +=" 					A4_FILIAL = '"+xFilial("SA4")+"' AND "
	_cQry0 +=" 					A4_COD = C5_TRANSP AND "
	_cQry0 += 					RetSQLName("SA4")+".D_E_L_E_T_ = ' ' "
	_cQry0 +=" 			INNER JOIN "
	_cQry0 += 				RetSQLName("SU7")
	_cQry0 +=" 				ON "
	_cQry0 +=" 					U7_FILIAL = '"+xFilial("SU7")+"' AND "
	_cQry0 +=" 					U7_COD = C5_OPERADO  AND "
	_cQry0 += 					RetSQLName("SU7")+".D_E_L_E_T_ = ' ' "
	_cQry0 +=" 			INNER JOIN "
	_cQry0 += 				RetSQLName("SE4")
	_cQry0 +=" 				ON "
	_cQry0 +=" 					E4_FILIAL = '"+xFilial("SE4")+"' AND "
	_cQry0 +=" 					E4_CODIGO = C5_CONDPAG AND "
	_cQry0 += 					RetSQLName("SE4")+".D_E_L_E_T_ = ' ' "
	//FIM - Altera็ใo para teste de performance.
	_cQry0 +=" WHERE 
	_cQry0 +=" C5_FILIAL = '"+xFilial("SC5")+"'	AND "
	_cQry0 +=" C5_NUM = '"+AllTrim(SZR->ZR_NUMERO)+"' AND "
	_cQry0 +=  RetSQLName("SC5")+".D_E_L_E_T_ = ' ' "
	_cQry0 +=" GROUP BY C5_CLIENTE+' - '+A1_NREDUZ , C5_NUM ,C5_OPERADO+' - '+U7_NOME,U7_POSTO+' - '+(CASE WHEN U7_POSTO = 01 THEN 'APOIO' WHEN U7_POSTO = 02 THEN 'TELEVENDAS' WHEN U7_POSTO = 03  THEN 'LICITAวรO' WHEN U7_POSTO = 04  THEN 'SAC'WHEN U7_POSTO = 05  THEN 'COBRANวA' WHEN U7_POSTO = 06  THEN 'HQ' ELSE 'OUTROS' END),C5_CONDPAG ,C5_FILIAL ,C5_TPFRETE,C5_TRANSP+' - '+A4_NREDUZ "
		
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQry0),'TMP4',.T.,.T.)
	TMP4->(DbGoTop())
	If !EMPTY ("TMP4")
		DbSelectArea("TMP4")
		TMP4->(DbGoTop())
		
		aadd(aMsg,{"Pedido",Alltrim(TMP4->PEDIDO) })
		aadd(aMsg,{"Cliente",Alltrim(TMP4->NOME)})
		aadd(aMsg,{"Valor",TransForm(SZR->ZR_VALOR,"@E 999,999.99")})                                                                                

		SE4->(dbSetOrder(1))
		If SE4->(dbSeek(xFilial("SE4")+Alltrim(TMP4->CONDPAG)))            
				
			cDescCP := Alltrim(TMP4->CONDPAG)+" - "+AllTrim(SE4->E4_DESCRI)
            cDescCP += IIf(SE4->E4_USERDES>0," (Desc. "+AllTrim(Str(SE4->E4_USERDES))+" %)",IIf(SE4->E4_XUSRACR>0," (Acresc. "+AllTrim(Str(SE4->E4_XUSRACR))+" %)"," (Sem Desc.)"))
			aadd(aMsg,{"Condi็ใo de Pagamento",cDescCP})
		EndIf

		aadd(aMsg,{"Operador",Alltrim(capital(TMP4->OPERADOR))})
		aadd(aMsg,{"Posto",Alltrim(TMP4->POSTO)})
		aadd(aMsg,{"Transportadora",Alltrim(TMP4->TRANSPORTADORA)}) 
		aadd(aMsg,{"Frete",Iif(Alltrim(TMP4->FRETE)="I","INCLUSO",Iif(Alltrim(TMP4->FRETE)="C","CIF",Iif(Alltrim(TMP4->FRETE)="F","FOB",Iif(Alltrim(TMP4->FRETE)="R","RETIRA","MALOTE"))))})

		cOperMail :=  Posicione("SU7",1,xFilial("SU7") + SubStr(TMP4->OPERADOR,1,6), "U7_EMAIL")
		cCicDe    :=  Posicione("SU7",1,xFilial("SU7") + SubStr(TMP4->OPERADOR,1,6), "U7_CICNOME")
		// Monta a mensagem a ser enviado ao operador
		cMail := "AVISO IMPORTANTE"+CR+CR
		cMail += "O Pedido : "+Alltrim(TMP4->PEDIDO)+CR+CR
		
		
		Do While !lSaida
			
			nOpcao := 0
			nLim   := 15
			nColu  := 10
			If AllTrim(SZR->ZR_ORIGEM)<>"AVA"
				Define msDialog oDlg Title "APROVAวรO DIGITAL" From 10,10 TO 51,162
				@ 001,002 tO 310,600
				@ 5 ,150 say "Aprova็ใo Digital"  font oFont30  COLOR CLR_BLACK Pixel
			Else
				Define msDialog oDlg Title "AVALIAวรO DOS ITENS DO PEDIDO" From 10,10 TO 51,162
				@ 001,002 tO 310,600
				@ 5 ,150 say "Avalia็ใo dos Itens do Pedido"  font oFont30  COLOR CLR_BLACK Pixel
			EndIf	
				
			
			@ 017+nLim ,010 say "Cliente :..................................."   	font oFont24  COLOR CLR_BLUE Pixel
			@ 037+nLim ,010 say "Pedido :...................................."   	font oFont24  COLOR CLR_BLUE Pixel
			@ 057+nLim ,010 say "Valor :......................................." 	font oFont24  COLOR CLR_BLUE Pixel
			@ 077+nLim ,010 say "Condi็ใo de Pagamento :......"  					font oFont24  COLOR CLR_BLUE Pixel
			@ 097+nLim ,010 say "Operador :..............................."  		font oFont24  COLOR CLR_BLUE Pixel
			@ 117+nLim ,010 say "Posto :......................................."  	font oFont24  COLOR CLR_BLUE Pixel
			@ 137+nLim ,010 say "Transportadora :........................."  		font oFont24  COLOR CLR_BLUE Pixel 
			@ 157+nLim ,010 say "Frete. :........................................"	font oFont24  COLOR CLR_BLUE Pixel

			If AllTrim(SZR->ZR_ORIGEM)=="PAG"
				@ 177+nLim ,010 say "Obs. PAG :...................................."  	font oFont24  COLOR CLR_BLUE Pixel			     
			ElseIf AllTrim(SZR->ZR_ORIGEM)=="AVA"
				@ 177+nLim ,010 say "Obs. AVA :...................................."  	font oFont24  COLOR CLR_BLUE Pixel
			ElseIf AllTrim(SZR->ZR_ORIGEM)=="VAL"
				@ 177+nLim ,010 say "Obs. VAL :...................................."  	font oFont24  COLOR CLR_BLUE Pixel
			Else
				@ 177+nLim ,010 say "Obs. PAG :...................................."  	font oFont24  COLOR CLR_BLUE Pixel
				@ 217+nLim ,010 say "Obs. VAL :...................................."  	font oFont24  COLOR CLR_BLUE Pixel
			EndIf
			
			aDados := DipLoadDad(TMP4->PEDIDO)
			
			If Len(aDados) > 0
				@ 20,315 ListBox oList var cList Fields HEADER "Obs.VAL","Obs.PAG","Obs.Aprovador","Aprovador","Resultado","Condi็ใo","Valor";
				size 275,160 font oFont17 COLOR CLR_WHITE of oDlg Pixel
				oList:SetArray(aDados)
				oList:bLine := {|| {aDados[oList:nAT,1],aDados[oList:nAT,2],aDados[oList:nAT,3],aDados[oList:nAT,4],aDados[oList:nAT,5],aDados[oList:nAT,6],aDados[oList:nAT,7]}}
			EndIf
						
			@ 010+nLim ,110 get alltrim(TMP4->NOME)  						when .f. font oFont16  COLOR CLR_RED SIZE 200,15 Pixel
			@ 030+nLim ,110 get alltrim(TMP4->PEDIDO)  						when .f. font oFont16  COLOR CLR_RED SIZE 200,15 Pixel
			@ 050+nLim ,110 get SZR->ZR_VALOR  Picture "@e 9,999,999.99" 	when .f. font oFont16  COLOR CLR_RED SIZE 200,15 Pixel
			@ 070+nLim ,110 get allTrim(cDescCP)							when .f. font oFont16  COLOR CLR_RED SIZE 200,15 Pixel 
			@ 090+nLim ,110 get alltrim(capital(TMP4->OPERADOR))  			when .f. font oFont16  COLOR CLR_RED SIZE 200,15 Pixel
			@ 110+nLim ,110 get alltrim(TMP4->POSTO) 						when .f. font oFont16  COLOR CLR_RED SIZE 200,15 Pixel
			@ 130+nLim ,110 get alltrim(TMP4->TRANSPORTADORA)  				when .f. font oFont16  COLOR CLR_RED SIZE 200,15 Pixel 			
			@ 150+nLim ,110 get Iif(Alltrim(TMP4->FRETE)="I","INCLUSO",Iif(Alltrim(TMP4->FRETE)="C","CIF",Iif(Alltrim(TMP4->FRETE)="F","FOB",Iif(Alltrim(TMP4->FRETE)="R","RETIRA","MALOTE"))))  when .f.  font oFont16  COLOR CLR_RED Pixel
		        
		    nLinAux := 170
		    
		   	If !Empty(SZR->ZR_OBSOPER)   		   		
				@ nLinAux+nLim ,110 get SubStr(SZR->ZR_OBSOPER,1,100)  when .f.  font oFont16  COLOR CLR_RED SIZE 480,15 Pixel
				If !Empty(SubStr(SZR->ZR_OBSOPER,100,Len(SZR->ZR_OBSOPER)))      
					nLinAux+=20
					@ nLinAux+nLim ,110 get SubStr(SZR->ZR_OBSOPER,101,Len(SZR->ZR_OBSOPER))  when .f.  font oFont16  COLOR CLR_RED SIZE 480,15 Pixel
				EndIf     
				nLinAux+=20
			EndIf
							
			If !Empty(SZR->ZR_OBSOPE2)
				@ nLinAux+nLim ,110 get SubStr(SZR->ZR_OBSOPE2,1,100)  when .f.  font oFont16  COLOR CLR_RED SIZE 480,15 Pixel
				If !Empty(SubStr(SZR->ZR_OBSOPE2,100,Len(SZR->ZR_OBSOPE2)))
					nLinAux+=20
					@ nLinAux+nLim ,110 get SubStr(SZR->ZR_OBSOPE2,101,Len(SZR->ZR_OBSOPE2))  when .f.  font oFont16  COLOR CLR_RED SIZE 480,15 Pixel
				EndIf
			EndIf				  
			
			cObsOper := AllTrim(SZR->ZR_OBSOPER)+AllTrim(SZR->ZR_OBSOPE2)
			
			nLim:=45
			If Upper(u_DipUsr())$Upper(GetNewPar("ES_USUAPRO","PMENDONCA/EPONTOLDIO/MCANUTO/DDOMINGOS"))
				
				If AllTrim(SZR->ZR_STATUS) <> "AVALIANDO"
					@ 227+nLim ,007+nColu tO 204+nLim ,053+nColu
					@ 230+nLim ,010+nColu say "APROVAR"  font oFont30  COLOR CLR_GREEN Pixel
					DEFINE SBUTTON FROM 245+nLim ,018+nColu type 1   ACTION (lSaida:=DipBtnAct(1),oDlg:End()) ENABLE OF oDlg
					@ 227+nLim ,067+nColu tO 204+nLim ,159+nColu
					@ 230+nLim ,070+nColu say "REPROVAR"  font oFont30  COLOR CLR_RED Pixel
					DEFINE SBUTTON FROM 245+nLim ,080+nColu type 2   ACTION (lSaida:=DipBtnAct(2),oDlg:End()) ENABLE OF oDlg
					@ 227+nLim ,127+nColu tO 204+nLim ,159+nColu
					@ 230+nLim ,130+nColu say "OBSERVACAO"  font oFont30 COLOR CLR_BLACK Pixel
					DEFINE SBUTTON FROM 245+nLim ,142+nColu type 2   ACTION u_DipObsDir() ENABLE OF oDlg
				Else
					@ 230+nLim ,200+nColu say "AVALIADO"  font oFont30 COLOR CLR_BLACK Pixel
					DEFINE SBUTTON FROM 245+nLim ,212+nColu type 1   ACTION (lSaida:=DipBtnAct(4),oDlg:End()) ENABLE OF oDlg
				EndIf				
								
			EndIf
//			@ 227+nLim ,207+nColu tO 204+nLim ,260+nColu
//			@ 230+nLim ,210+nColu say "REAVALIAR"  font oFont30  COLOR CLR_BLUE Pixel
//			DEFINE SBUTTON FROM 245+nLim ,220+nColu type 5   ACTION (nOpcao:=3,cComEnv:=AprEmai(nOpcao,aMsg,cOperMail),If(substr(cComEnv,1,1)= "1",(GravDig(cComEnv),GrvKardex("REAVALIAR")),lSaida:=.F.),If(substr(cComEnv,1,1)= "1",lSaida:=.T.,lSaida:=.F.),oDlg:End()) ENABLE OF oDlg
			@ 227+nLim ,307+nColu tO 204+nLim ,397+nColu
			@ 230+nLim ,310+nColu say "VISUALIZAR PEDIDO"  font oFont30  COLOR CLR_BLACK Pixel
			DEFINE SBUTTON FROM 245+nLim ,335+nColu type 15   ACTION (nOpcao:=3,U_VisuDig(),lSaida:=.F.,oDlg:End()) ENABLE OF oDlg
			//If "VAL"$SZR->ZR_ORIGEM
				@ 227+nLim ,407+nColu tO 204+nLim ,505+nColu
			If AllTrim(SZR->ZR_STATUS) <> "AVALIANDO"	
				@ 230+nLim ,410+nColu say "ITENS P/ APROVAวรO"  font oFont30  COLOR CLR_GREEN Pixel
			Else
				@ 230+nLim ,410+nColu say "ITENS P/ AVALIAวรO"  font oFont30  COLOR CLR_GREEN Pixel			
			EndIf	
				DEFINE SBUTTON FROM 245+nLim ,435+nColu type 15   ACTION (nOpcao:=3,U_DipVisIte(),lSaida:=.F.,oDlg:End()) ENABLE OF oDlg
			//EndIf
			
			@ 227+nLim ,517+nColu tO 204+nLim ,545+nColu
			@ 230+nLim ,520+nColu say "SAIR"  font oFont30  COLOR CLR_RED Pixel
			DEFINE SBUTTON FROM 245+nLim ,520+nColu type 2   ACTION (lSaida:=.T.,oDlg:End()) ENABLE OF oDlg
			Activate dialog oDlg centered
			
		Enddo
		
	EndIf
	TMP4->(Dbclosearea())
EndIf
UnLockByName("AVALIANDO "+SZR->ZR_NUMERO,.T.,.F.)

DipRefresh()

Return ()
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDIPDIGMBR บAutor  ณMicrosiga           บ Data ณ  10/24/14   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function AprEmai(nOpcao,aMsg,cEmail,cMsgOper)
Local  lSaida        := .f.
Local cComent        := Space(150)
Local cTiMail        := "RESULTADO DE SOLICITAวdรO"
Local cFuncSent 	 := "DIPDIGMBR(AprEmai)"
Local cDe            := Posicione("SU7",6,xFilial("SU7") + AllTrim(u_DipUsr()), "U7_EMAIL")
Local cCopi			 := ""

// A patrํcia nใo quer receber e-mails da rotina
If AllTrim(cDe)=="elizabete.rodrigues@dipromed.com.br" 
	cEmail += ";"+cDe
	cDe    := "protheus@dipromed.com.br"
ElseIf Alltrim(cDe) <> "protheus@dipromed.com.br"
	cDe    := "protheus@dipromed.com.br"	
EndIf

If	nOpcao = 1
	cTiMail := "RESULTADO DE SOLICITAวรO - APROVADO"
	aadd(aMsg,{"Resultado","APROVADO"})
ElseIf	nOpcao = 2
	cTiMail := "RESULTADO DE SOLICITAวรO - REPROVADO"
	aadd(aMsg,{"Resultado","REPROVADO"})
ElseIf	nOpcao = 3
	cTiMail := "RESULTADO DE SOLICITAวรO - EM AVALIAวรO"
	aadd(aMsg,{"Resultado","EM AVALIAวรO"})
ElseIf	nOpcao = 4
	cTiMail := "RESULTADO DE SOLICITAวรO - AVALIADO"
	aadd(aMsg,{"Resultado","AVALIADO"})
EndIf

aadd(aMsg,{"Operador",cMsgOper}) 
If !Empty(cPagto)
	aAdd(aMsg,{"Pg Sugerido",cPagto})
EndIf      
cPagto := ""

For nI:=1 to Len(aVlrInf)
	aAdd(aMsg,{aVlrInf[nI,1],aVlrInf[nI,2]})
Next nI
aVlrInf := {}

Do While !lSaida
	
	Define msDialog oDlg Title "E-Mail" From 10,10 TO 30,70
	@ 001 ,002 tO 150,240
	@ 5   , 70 say "Comentario Para o Operador"  font oFont30  COLOR CLR_BLACK Pixel
	@ 027 ,010 say "Um E-Mail serแ Enviado Para o Operador"  font oFont24  COLOR CLR_BLUE Pixel
	@ 037 ,010 say "Deixe Seu Comentแrio Sobre a Solicita็ใo"  font oFont24  COLOR CLR_BLUE Pixel
	@ 050 ,010 get cComent  when .t.  font oFont16 Size 220,16 COLOR CLR_RED Pixel
	@ 075 , 55 say "CONFIRMAR"  font oFont30  COLOR CLR_GREEN Pixel
	DEFINE SBUTTON FROM 090 ,67 type 1   ACTION (aadd(aMsg,{"Aprovador",cComent}), u_UEnvMail(cEmail,cTiMail,aMsg,"",cDe,cFuncSent),U_DigCic(cMail,cCicDe,nOpcao,cComent),cComent:="1"+cComent, lSaida:=.T.,oDlg:End()) ENABLE OF oDlg
	@ 075 ,118 say "CANCELAR"  font oFont30  COLOR CLR_RED Pixel
	DEFINE SBUTTON FROM 090 ,123 type 2   ACTION (cComent:="2"+cComent, lSaida:=.T.,oDlg:End()) ENABLE OF oDlg
	
	Activate dialog oDlg centered
	
Enddo

Return (cComent)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDIPDIGMBR บAutor  ณMicrosiga           บ Data ณ  10/24/14   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function GravDig(cComEnv)

RecLock("SZR", .F.)                          

SZR->ZR_OBSAPRO := SubStr(cComEnv,2,Len(cComEnv))
SZR->ZR_DTAPROV := DtoC( Date() ) + ' / ' + Time()
SZR->ZR_MAQAPRO  := getcomputername()
SZR->ZR_USERAPR := LogUserName()
SZR->ZR_APROVAD := AllTrim(Upper(u_DipUsr()))

If nOpcao = 1
	SZR->ZR_STATUS  := "APROVADO"
ElseIf nOpcao = 2
	SZR->ZR_STATUS  := "REPROVADO"
ElseIf nOpcao = 3
	SZR->ZR_STATUS  := "AVALIACAO"
EndIf
SZR->(MsUnLock())


Return ()
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDIPDIGMBR บAutor  ณMicrosiga           บ Data ณ  10/24/14   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function VisuDig()

dbSelectArea("SC5")
SC5->(dbSetOrder(1))
If dbSeek(xFilial("SC5")+TMP4->PEDIDO)
	
	A410Visual("SC5",SC5->(RECNO()),2)
EndIf
SC5->(DbCloseArea())
Return ()
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDIPDIGMBR บAutor  ณMicrosiga           บ Data ณ  10/24/14   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function LegDig()
local aStatus:={}

aadd(aStatus,{"BR_AZUL"    , "AVALIANDO" })
aadd(aStatus,{"BR_VERDE"   , "AGUARDANDO"})
aadd(aStatus,{"BR_VERMELHO", "REPROVADO" })
aadd(aStatus,{"BR_PRETO"   , "APROVADO"  })

BrwLegenda(cCadastro, "Status", aStatus)

Return .T.
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDIPDIGMBR บAutor  ณMicrosiga           บ Data ณ  10/24/14   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function DigEmail(aMsg,cComent,cTiMail,cEmail,cDe,cCopi)
Local lSmtpAuth   := GetNewPar("MV_RELAUTH",.F.)
Local lAutOk	  := .F.
Private cAssunto  := EncodeUTF8("Aprova็ใo Digital","cp1252")
Private cAttach   := "a"
Private cFuncSent := "DIPDIGMBR.PRW"
Private cAccount  := Lower(Alltrim(GetMv("MV_RELACNT")))
Private cFrom     := Lower(Alltrim(GetMv("MV_RELACNT")))
Private cPassword := Alltrim(GetMv("MV_RELPSW"))
Private cServer   := Alltrim(GetMv("MV_RELSERV"))
Private cEmailTo  := " "
Private cEmailCc  := cDe+" ; "+cCopi
Private cEmailBcc := " "
Private lResult   := .F.
Private cError    := " "
Private i         := 0
Private cArq      := " "
Private cMsg      := " "
Private _nLin
Private _xAlias   := GetArea()

aadd(aMsg,{"Operador ",AllTrim(SZR->ZR_OBSOPER)})
If !Empty(cComent)
	aadd(aMsg,{"Aprovador",cComent})
EndIf


//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Definicao do cabecalho do email                                             ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
cMsg := ""
cMsg += '<html>'
cMsg += '<head>'
cMsg += '<title>' + cTiMail + " - "+SM0->M0_NOME+"/"+SM0->M0_FILIAL+'</title>'
cMsg += '</head>'
cMsg += '<body>'
//cMsg += '<Img Src="C:/AP5/SIGAADV/LGRL01.BMP"><BR>'
cMsg += '</Table>'
cMsg += '<P>'
cMsg += '<Table align="center">'
cMsg += '<tr>'
cMsg += '<td colspan="10" align="center"><font color="red" size="5">'+cTiMail+'<font color="red" size="1">.</td>'
cMsg += '</tr>'
cMsg += '</Table>'

cMsg += '<HR Width=85% Size=3 Align=Centered Color=Red> <P>'

cMsg += '<Table Border=1 Align=Center BorderColor=#000000 CELLPADDING=4 CELLSPACING=0 Width=60%>'
cMsg += '<Caption> <FONT COLOR=#000000 FACE= "ARIAL" SIZE=5>' + cAssunto +" - "+SM0->M0_NOME+"/"+SM0->M0_FILIAL+ '</FONT> </Caption>'
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Definicao do texto/detalhe do email                                         ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
For _nLin := 1 to Len(aMsg)
	IF (_nLin/2) == Int( _nLin/2 )
		cMsg += '<TR BgColor=#B0E2FF>'
	Else
		cMsg += '<TR BgColor=#FFFFFF>'
	EndIF
	cMsg += '<TD><B><Font Color=#000000 Size="2" Face="Arial">' + aMsg[_nLin,1] + ' </Font></B></TD>'
	cMsg += '<TD> <Font Color=#000000 Size="2" Face="Arial">' + aMsg[_nLin,2] + ' </Font></TD>'
	cMsg += '</TR>'
Next
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Definicao do rodape do email                                                ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
cMsg += '</Table>'
cMsg += '<P>'
cMsg += '<Table align="center">'
cMsg += '<tr>'
cMsg += '<td colspan="10" align="center"><font color="red" size="3">Mensagem enviada automaticamente pelo sistema PROTHEUS - <font color="red" size="1">('+cFuncSent+')</td>'
cMsg += '</tr>'
cMsg += '</Table>'
cMsg += '<HR Width=85% Size=3 Align=Centered Color=Red> <P>'
cMsg += '</body>'
cMsg += '</html>'

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณEnvia o mail para a lista selecionada. Envia como BCC para que a pessoa penseณ
//ณque somente ela recebeu aquele email, tornando o email mais personalizado.   ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
IF At(";",cEmail) > 0
	cEmailTo := SubStr(cEmail,1,At(";",cEmail)-1)
	cEmailCc:= SubStr(cEmail,At(";",cEmail)+1,Len(cEmail))
Else
	cEmailTo := Alltrim(cEmail)
EndIF

CONNECT SMTP SERVER cServer ACCOUNT cAccount PASSWORD cPassword RESULT lResult

If !lAutOk
	If ( lSmtpAuth )
		lAutOk := MailAuth(cAccount,cPassword)
	Else
		lAutOk := .T.
	EndIf
EndIf

If lResult .And. lAutOk
	SEND MAIL FROM cFrom ;
	TO      	Lower(cEmailTo);
	CC      	Lower(cEmailCc);
	BCC     	Lower(cEmailBcc);
	SUBJECT 	cAssunto;
	BODY    	cMsg;
	ATTACHMENT  cAttach;
	RESULT lResult
	
	If !lResult
		//Erro no envio do email
		GET MAIL ERROR cError
		
		MsgInfo(cError,OemToAnsi("Atencao"))
	EndIf
	
	DISCONNECT SMTP SERVER
Else
	//Erro na conexao com o SMTP Server
	GET MAIL ERROR cError
	
	MsgInfo(cError,OemToAnsi("Atencao"))
EndIf

RestArea(_xAlias)
Return()
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDIPDIGMBR บAutor  ณMicrosiga           บ Data ณ  10/24/14   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function DipAprUse()
Private aRotina   := {}
Private aCare   := {}
Private cCadastro := "APROVADORES"

U_DIGUPD()//atualiza registros encerrados pela data final
aAdd( aRotina, { "Incluir"    , "U_DIGINC" , 0 , 3 })
aAdd( aRotina, { "Altera"     , "U_DIGALT" , 0 , 4 })
aAdd( aRotina, { "Visualizar" , "AXVISUAL" , 0 , 2 })
aAdd( aRotina, { "Bloquear"   , "U_DIGENC" , 0 , 4 })
aadd( aRotina, { "Legenda"	  , "U_LegAP"   , 0 , 6 })


aAdd(aCare,{"ZS_STATUS = 'AUTORIZADO' .AND. ZS_DTFINAL >= DATE()","BR_VERDE"    })
aAdd(aCare,{"ZS_STATUS = 'BLOQUEADO .AND. ZS_DTFINAL >= DATE() '" ,"BR_VERMELHO"   })
aAdd(aCare,{"ZS_DTFINAL < DATE()      ","BR_PRETO"   })
dbSelectArea("SZS")
dbSetOrder(1)
_oObj := GetObjBrow()
_oObj:Default()

mBrowse(6,1,22,60,"SZS",,,,,,aCare)

_oObj:Refresh()
//eval( _oObj:bHeaderClick, _oObj, 2 )
Return()
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDIPDIGMBR บAutor  ณMicrosiga           บ Data ณ  10/24/14   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function DIGENC()

If  ZS_STATUS = 'AUTORIZADO' .AND. ZS_DTFINAL >= DATE()
	IF MsgBox("DESEJA BLOQUEAR ESTA AUTORIZAวรO ?","Atencao","YESNO")
		
		
		RecLock("SZS",.F.)
		SZS->ZS_STATUS := "BLOQUEADO"
		SZS->ZS_OBSTATU := 	alltrim(SZS->ZS_OBSTATU)+" / BLOQUEADO : "+AllTrim(Upper(u_DipUsr()))+" - "+DTOC(DATE())
		SZS->(MsUnLock())
		SZS->(DbCommit())
		
	EndIf
Else
	MSGINFO("AUTORIZAวรO NAO PODE SER BLOQUEADA")
	
	
EndIf
Return()
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDIPDIGMBR บAutor  ณMicrosiga           บ Data ณ  10/24/14   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function LegAP()
local aSprr:={}

aadd(aSprr,{"BR_VERDE"   , "AUTORIZADO"})
aadd(aSprr,{"BR_VERMELHO", "BLOQUEADO" })
aadd(aSprr,{"BR_PRETO"   , "ENCERRADO"  })

BrwLegenda(cCadastro, "Status", aSprr)
Return()
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDIPDIGMBR บAutor  ณMicrosiga           บ Data ณ  10/24/14   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function DIGALT()

If  ZS_STATUS = 'AUTORIZADO' .AND. ZS_DTFINAL >= DATE()
	If	AxAltera("SZS",SZS->(RECNO()),4) = 1
		
		RecLock("SZS",.F.)
		SZS->ZS_OBSTATU := 	alltrim(SZS->ZS_OBSTATU)+" / ALTERADO : "+AllTrim(Upper(u_DipUsr()))+" - "+DTOC(DATE())
		SZS->(MsUnLock())
		SZS->(DbCommit())
	EndIf
ElseIf  ZS_STATUS = 'BLOQUEADO' .AND. ZS_DTFINAL >= DATE()
	IF MsgBox("DESEJA DESBLOQUEAR ESTA AUTORIZAวรO ?","Atencao","YESNO")
		
		
		RecLock("SZS",.F.)
		SZS->ZS_STATUS := "AUTORIZADO"
		SZS->ZS_OBSTATU := 	alltrim(SZS->ZS_OBSTATU)+" / DESBLOQUEADO : "+AllTrim(Upper(u_DipUsr()))+" - "+DTOC(DATE())
		SZS->(MsUnLock())
		SZS->(DbCommit())
	EndIf
Else
	MSGINFO("AUTORIZAวรO COM DATA EXPIRADA, POR FAVOR CADASTRE NOVAMENTE O OPERADOR")
EndIf


Return()
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDIPDIGMBR บAutor  ณMicrosiga           บ Data ณ  10/24/14   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function DIGINC(cAlias, nReg, nOpc)

If	AxInclui(cAlias,nReg,nOpc,,,,) = 1
	
	RecLock("SZS",.F.)
	SZS->ZS_STATUS := "AUTORIZADO"
	SZS->ZS_OBSTATU := 	alltrim(SZS->ZS_OBSTATU)+"AUTORIZADO : "+AllTrim(Upper(u_DipUsr()))+" - "+DTOC(DATE())
	SZS->(MsUnLock())
	SZS->(DbCommit())
	
EndIf
Return()      
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDIPDIGMBR บAutor  ณMicrosiga           บ Data ณ  10/24/14   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function DIGUPD()
Local _cQry:= ""

_cQry := " UPDATE "+RETSQLNAME ("SZS")    "
_cQry += " SET  ZS_STATUS = 'ENCERRADO'   "
_cQry += " WHERE ZS_DTFINAL < '"+dtos(date())+"' "

TcSqlExec(_cQry)

Return()
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDIPDIGMBR บAutor  ณMicrosiga           บ Data ณ  10/24/14   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function DipVeUSer()
Local _cQry0   := " "
Local _cPosCod := " "


_cQry0 :=" SELECT * "
_cQry0 +=" FROM "+RETSQLNAME ("SZS") + " SZS "
_cQry0 +=" WHERE RTRIM(LTRIM(ZS_NREDUZ))      =  '"+ALLTRIM(U_DipUsr())+"' "
_cQry0 +=" AND ZS_FILIAL     =  '' "
_cQry0 +=" AND RTRIM(LTRIM(ZS_STATUS))      =  'AUTORIZADO' "
_cQry0 +=" AND D_E_L_E_T_    <> '*' "

dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQry0),'TMP1',.T.,.T.)

TMP1->(dbgotop())
If !EMPTY ("TMP1")
	DbSelectArea("TMP1")
	DbGoTop()
	While TMP1->(!EOF())
		_cPosCod:= _cPosCod + ALLTRIM(TMP1->ZS_POSTO)
		
		TMP1->( dbSkip())
	END
EndIf

TMP1->(DBCloseArea())
Return(_cPosCod)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDIPDIGMBR บAutor  ณMicrosiga           บ Data ณ  10/24/14   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function DipGApr()
Local _xAlias   := GetArea()

DbSelectArea("SU7")
SU7->(dbSetOrder(3))
If SU7->(DbSeek(xFilial("SU7")+M->ZS_NOME)) 
	M->ZS_NREDUZ  := SU7->U7_NREDUZ
	M->ZS_CODOPER := SU7->U7_COD
	M->ZS_POSTO   := SU7->U7_POSTO
	M->ZS_EMAIL   := SU7->U7_EMAIL
	M->ZS_CIC     := SU7->U7_CICNOME
EndIf
RestArea(_xAlias)                   

Return(M->ZS_NOME)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDIPDIGMBR บAutor  ณMicrosiga           บ Data ณ  10/24/14   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
/*
User Function DipVisIte()       
Local cSQL 		:= ""
Local aStrut 	:= {}
Local nTotCus  	:= 0
Local nTotLis 	:= 0
Local nTotVen	:= 0

aadd(aStrut,{"C6_STATUS" ,"C",2,0})
aadd(aStrut,{"C6_PRODUTO",AvSx3("C6_PRODUTO",2),AvSx3("C6_PRODUTO",3),AvSx3("C6_PRODUTO",4)})
aadd(aStrut,{"C6_DESCRI" ,AvSx3("C6_DESCRI" ,2),AvSx3("C6_DESCRI" ,3),AvSx3("C6_DESCRI" ,4)})
aadd(aStrut,{"C6_QTDVEN" ,AvSx3("C6_QTDVEN" ,2),AvSx3("C6_QTDVEN" ,3),AvSx3("C6_QTDVEN" ,4)})
aadd(aStrut,{"C6_CUSDIP" ,AvSx3("C6_CUSDIP" ,2),AvSx3("C6_CUSDIP" ,3),AvSx3("C6_CUSDIP" ,4)})
aadd(aStrut,{"C6_TOTCUS" ,AvSx3("C6_CUSDIP" ,2),AvSx3("C6_CUSDIP" ,3),AvSx3("C6_CUSDIP" ,4)})
aadd(aStrut,{"C6_LISFOR" ,AvSx3("C6_LISFOR" ,2),AvSx3("C6_LISFOR" ,3),AvSx3("C6_LISFOR" ,4)})
aadd(aStrut,{"C6_TOTLIS" ,AvSx3("C6_LISFOR" ,2),AvSx3("C6_LISFOR" ,3),AvSx3("C6_LISFOR" ,4)})
aadd(aStrut,{"C6_PRCVEN" ,AvSx3("C6_PRCVEN" ,2),AvSx3("C6_PRCVEN" ,3),AvSx3("C6_PRCVEN" ,4)})
aadd(aStrut,{"C6_TOTVEN" ,AvSx3("C6_PRCVEN" ,2),AvSx3("C6_PRCVEN" ,3),AvSx3("C6_PRCVEN" ,4)})
aadd(aStrut,{"C6_QTDEST" ,AvSx3("C6_QTDVEN" ,2),AvSx3("C6_QTDVEN" ,3),AvSx3("C6_QTDVEN" ,4)})

cArqTRB := CriaTrab(aStrut, .T.)
dbUseArea(.T.,,cArqTRB,"TRB_ITE")

cIndTRB := CriaTrab(Nil,.F.)

TRB_ITE->(DbCreateIndex(cIndTRB,"C6_PRODUTO" ,{|| C6_PRODUTO },.F.))
TRB_ITE->(DbClearInd())
TRB_ITE->(DbSetIndex(cIndTRB))
TRB_ITE->(DbSetOrder(1))

cSQL := " SELECT "
cSQL += " 	C6_PRODUTO, C6_DESCRI, C6_QTDVEN, C6_CUSDIP, (C6_QTDVEN*C6_CUSDIP) TOTCUS, C6_LISFOR, "
cSQL += " 	(C6_QTDVEN*C6_LISFOR) TOTLIS, C6_PRCVEN, (C6_QTDVEN*C6_PRCVEN) TOTVEN, B1_PRVSUPE, B1_PRVMINI "
cSQL += " 	FROM "
cSQL +=  		RetSQLName("SC6")+", "+RetSQLName("SB1")
cSQL += " 		WHERE "
cSQL += " 			C6_FILIAL = '"+xFilial("SC6")+"' AND "
cSQL += " 			C6_NUM 	  = '"+AllTrim(SZR->ZR_NUMERO)+"' AND "
cSQL += " 			B1_FILIAL = C6_FILIAL AND "
cSQL += " 			B1_COD 	  = C6_PRODUTO AND "
cSQL += 			RetSQLName("SC6")+".D_E_L_E_T_ = ' ' AND "
cSQL += 			RetSQLName("SB1")+".D_E_L_E_T_ = ' ' "

cSQL := ChangeQuery(cSQL)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),"QRYTMP",.T.,.F.)

TCSETFIELD("QRYTMP","C6_QTDVEN"	,"N",10,0)                              
TCSETFIELD("QRYTMP","C6_CUSDIP"	,"N",17,2)     
TCSETFIELD("QRYTMP","TOTCUS" 	,"N",17,2)     
TCSETFIELD("QRYTMP","C6_LISFOR"	,"N",17,2)     
TCSETFIELD("QRYTMP","TOTLIS" 	,"N",17,2)     
TCSETFIELD("QRYTMP","C6_PRCVEN"	,"N",17,2)     
TCSETFIELD("QRYTMP","TOTVEN" 	,"N",17,2)     
TCSETFIELD("QRYTMP","B1_PRVSUPE","N",17,2)     
TCSETFIELD("QRYTMP","B1_PRVMINI","N",17,2)     

While !QRYTMP->(Eof())

	TRB_ITE->(dbAppend())      
	TRB_ITE->C6_STATUS  := IIf(QRYTMP->(C6_PRCVEN<B1_PRVSUPE .And. C6_PRCVEN<B1_PRVSUPE),"BR_VERMELHO","BR_VERDE")
	TRB_ITE->C6_PRODUTO := QRYTMP->C6_PRODUTO
	TRB_ITE->C6_DESCRI  := QRYTMP->C6_DESCRI
	TRB_ITE->C6_QTDVEN  := QRYTMP->C6_QTDVEN
	TRB_ITE->C6_CUSDIP  := QRYTMP->C6_CUSDIP
	TRB_ITE->C6_TOTCUS  := QRYTMP->C6_TOTCUS
	TRB_ITE->C6_LISFOR  := QRYTMP->C6_LISFOR
	TRB_ITE->C6_TOTLIS  := QRYTMP->C6_TOTLIS
	TRB_ITE->C6_PRCVEN  := QRYTMP->C6_PRCVEN
	TRB_ITE->C6_TOTVEN  := QRYTMP->C6_TOTVEN
	TRB_ITE->C6_QTDEST  := QRYTMP->C6_QTDEST

	nTotCus += QRYTMP->C6_TOTCUS
	nTotLis += QRYTMP->C6_TOTLIS
	nTotVen += QRYTMP->C6_TOTVEN

	QRYTMP->(dbSkip())
EndDo
QRYTMP->(dbCloseArea())

TRB_ITE->(DbGoTop())                  
	
DEFINE MSDIALOG oDlg TITLE "Itens para aprova็ใo" From aSize[7],005 TO aSize[6],aSize[5] OF oMainWnd PIXEL    

	@ 005,005 SAY "Valor Total" 		  SIZE 100,008 			OF oDlg PIXEL
	@ 012,005 MSGET oDipVal1 VAR nDipVal1 SIZE 100,010 WHEN .F. OF oDlg PIXEL  PICTURE "@E 99,999,999.99"

	@ 005,135 SAY "Selecionados:"   	  SIZE 100,008 			OF oDlg PIXEL
	@ 012,135 MSGET oDipVal2 VAR nDipVal2 SIZE 100,010 WHEN .F. OF oDlg PIXEL  PICTURE "@E 999999"

	aCpos := { 	{"C6_STATUS" , "" , "@BMP"	        	   , ""},;
				{"C6_PRODUTO", "" , AvSx3("C6_PRODUTO",5) , ""},;
				{"C6_DESCRI" , "" , AvSx3("C6_DESCRI" ,5) , ""},;
				{"C6_QTDVEN" , "" , AvSx3("C6_QTDVEN" ,5) , ""},;
				{"C6_CUSDIP" , "" , AvSx3("C6_CUSDIP" ,5) , ""},;
				{"C6_TOTCUS" , "" , AvSx3("C6_CUSDIP" ,5) , ""},;
				{"C6_LISFOR" , "" , AvSx3("C6_LISFOR" ,5) , ""},;
				{"C6_TOTLIS" , "" , AvSx3("C6_LISFOR" ,5) , ""},;
				{"C6_PRCVEN" , "" , AvSx3("C6_PRCVEN" ,5) , ""},;
				{"C6_TOTVEN" , "" , AvSx3("C6_PRCVEN" ,5) , ""},;
				{"C6_QTDEST" , "" , AvSx3("C6_QTDVEN" ,5) , ""} }
                 
    /*
	oGetDados:=MsNewGetDados():New(aPosObj[2,1]-32,aPosObj[2,2],aPosObj[2,3]-13,aPosObj[2,4]-22,nStyle,'AllWaysTrue','AllWaysTrue',,,,MAXGETDAD,'AllWaysTrue',,,oDlg,@aHeader,@aCols)
	oGetDados:oBrowse:bAdd    := {|| .F. }      // Nao Permite a inclusao de Linhas
	oGetDados:oBrowse:bDelete := {|| .F. }	     // Nao Permite a deletar Linhas
    
ACTIVATE MSDIALOG oDlg ON INIT (EnchoiceBar(oDlg,{|| DipExpArq(lDipro,lReenv),oDlg:End()},{|| oDlg:End()}))

TRB_ITE->(dbCloseArea())


Return                   
*/
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDIPDIGMBR บAutor  ณMicrosiga           บ Data ณ  10/24/14   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function DipVisIte()       
Local cSQL 		:= ""
Local aStrut 	:= {}
Local nTotCus  	:= 0
Local nTotLis 	:= 0
Local nTotVen	:= 0
Local nTotVenAux:= 0
Local nMarCus	:= 0
Local nMarLis   := 0
Local oDlg                                 
Local nValAux	:= 0
Local nValAux2	:= 0
Local nValDes  	:= 0
Local nValAcr   := 0
Local nUserCP	:= 0
Local nUserAcr  := 0
Local aButtons	:= {}
Local lAprovAnt := .F.
Local nPerCif	:= 0
Local nPerCon   := 0
Local cPgPed	:= ""
Private oTotCus
Private oTotLis
Private oTotVen
Private oMarCus
Private oMarLis
Private oPerCif
Private oPerCon
Private oPagto
Private oPgPed
Private aHeader	:= {}
Private aCols	:= {}
Private oGetDados               

SC5->(dbSetOrder(1))
If SC5->(dbSeek(xFilial("SC5")+AllTrim(SZR->ZR_NUMERO)))
	cPagto := SC5->C5_XCPGINF
	SE4->(dbSetOrder(1))
	If SE4->(dbSeek(xFilial("SE4")+Alltrim(TMP4->CONDPAG)))
		cPgPed := SC5->C5_CONDPAG+" - "+AllTrim(SE4->E4_DESCRI)
		cPgPed += IIf(SE4->E4_USERDES>0," (Desc. "+AllTrim(Str(SE4->E4_USERDES))+" %)",IIf(SE4->E4_XUSRACR>0," (Acresc. "+AllTrim(Str(SE4->E4_XUSRACR))+" %)"," (Sem Desc.)"))
	EndIf
EndIf

aObjects := {}

aSize   := MsAdvSize()
aAdd(aObjects, {100, 100, .T., .T.})

aInfo   := {aSize[1], aSize[2], aSize[3], aSize[4], 2, 2}
aPosObj := MsObjSize(aInfo, aObjects)          

If ALLTRIM(SZR->ZR_ORIGEM) == "AVA"

	cSQL := " SELECT "
	cSQL += " 	C6_PRODUTO, C6_ITEM, C6_DESCRI, C6_CLI, C6_LOJA, C6_LOCAL, SUM(C6_QTDVEN) C6_QTDVEN, B1_CUSDIP, (SUM(C6_QTDVEN)*B1_CUSDIP) B1_TOTCUS, B1_LISFOR, "
	cSQL += " 	(SUM(C6_QTDVEN)*B1_LISFOR) B1_TOTLIS, C6_PRCVEN, (SUM(C6_QTDVEN)*C6_PRCVEN) C6_TOTVEN, C6_XVLRINF, B1_PRVSUPE, C6_XQTDINF, "
	cSQL += "	B1_PRVMINI, C6_LOTECTL, C6_DTVALID, "
	cSQL += "	CASE WHEN B1_CUSDIP > 0 THEN ((C6_PRCVEN/B1_CUSDIP-1)*100) ELSE 0 END B1_MARCUS, "
	cSQL += "	CASE WHEN B1_LISFOR > 0 THEN ((C6_PRCVEN/B1_LISFOR-1)*100) ELSE 0 END B1_MARLIS "
	//((C6_PRCVEN/C6_CUSDIP-1)*100) C6_MARCUS, ((C6_PRCVEN/C6_LISFOR-1)*100) C6_MARLIS "
	cSQL += " 	FROM "
	cSQL +=  		RetSQLName("SC6")+", "+RetSQLName("SB1")
	cSQL += " 		WHERE "
	cSQL += " 			C6_FILIAL   = '"+xFilial("SC6")+"' AND "
	cSQL += " 			C6_NUM 	    = '"+AllTrim(SZR->ZR_NUMERO)+"' AND "
	cSQL += " 			B1_FILIAL   = C6_FILIAL AND "
	cSQL += " 			B1_COD 	    = C6_PRODUTO AND "    
	cSQL += " 			C6_NOTA  	= ' ' AND "
	cSQL += 			RetSQLName("SC6")+".D_E_L_E_T_ = ' ' AND "
	cSQL += 			RetSQLName("SB1")+".D_E_L_E_T_ = ' '     "
	cSQL += " GROUP BY "
	cSQL += " 	C6_PRODUTO,C6_ITEM,C6_DESCRI,C6_CLI,C6_LOJA,B1_CUSDIP,B1_LISFOR,C6_XVLRINF, C6_XQTDINF, C6_LOCAL, "
	cSQL += " 	C6_PRCVEN,B1_PRVSUPE,B1_PRVMINI,C6_LOTECTL, C6_DTVALID, "
	cSQL += "	CASE WHEN B1_CUSDIP > 0 THEN ((C6_PRCVEN/B1_CUSDIP-1)*100) ELSE 0 END, "
	cSQL += "	CASE WHEN B1_LISFOR > 0 THEN ((C6_PRCVEN/B1_LISFOR-1)*100) ELSE 0 END  "
	
	cSQL := ChangeQuery(cSQL)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),"QRYTMP",.T.,.T.)

Else

	cSQL := " SELECT "
	cSQL += " 	C6_PRODUTO, C6_ITEM, C6_DESCRI, C6_CLI, C6_LOJA, C6_LOCAL, SUM(C9_QTDORI) C6_QTDVEN,SUM(C9_SALDO) C6_SALDO, B1_CUSDIP, (SUM(C9_QTDORI)*B1_CUSDIP) B1_TOTCUS, B1_LISFOR, "
	cSQL += " 	(SUM(C9_QTDORI)*B1_LISFOR) B1_TOTLIS, C6_PRCVEN, (SUM(C9_QTDORI)*C6_PRCVEN) C6_TOTVEN, C6_XVLRINF, B1_PRVSUPE, C6_XQTDINF, "
	cSQL += "	B1_PRVMINI, C6_LOTECTL, C6_DTVALID, "
	cSQL += "	CASE WHEN B1_CUSDIP > 0 THEN ((C6_PRCVEN/B1_CUSDIP-1)*100) ELSE 0 END B1_MARCUS, "
	cSQL += "	CASE WHEN B1_LISFOR > 0 THEN ((C6_PRCVEN/B1_LISFOR-1)*100) ELSE 0 END B1_MARLIS "
	//((C6_PRCVEN/C6_CUSDIP-1)*100) C6_MARCUS, ((C6_PRCVEN/C6_LISFOR-1)*100) C6_MARLIS "
	cSQL += " 	FROM "
	cSQL +=  		RetSQLName("SC6")+", "+RetSQLName("SB1")+", "+RetSQLName("SC9")
	cSQL += " 		WHERE "
	cSQL += " 			C6_FILIAL   = '"+xFilial("SC6")+"' AND "
	cSQL += " 			C6_NUM 	    = '"+AllTrim(SZR->ZR_NUMERO)+"' AND "
	cSQL += " 			B1_FILIAL   = C6_FILIAL AND "
	cSQL += " 			B1_COD 	    = C6_PRODUTO AND "    
	cSQL += " 			C6_FILIAL	= C9_FILIAL AND "
	cSQL += " 			C6_NUM		= C9_PEDIDO AND "
	cSQL += " 			C6_PRODUTO	= C9_PRODUTO AND "
	cSQL += " 			C6_ITEM		= C9_ITEM AND "
	cSQL += " 			C9_CLIENTE	= C6_CLI AND "
	cSQL += " 			C9_LOJA		= C6_LOJA AND "   
	cSQL += " 			C9_NFISCAL	= ' ' AND "
	cSQL += 			RetSQLName("SC6")+".D_E_L_E_T_ = ' ' AND "
	cSQL += 			RetSQLName("SB1")+".D_E_L_E_T_ = ' ' AND "
	cSQL += 			RetSQLName("SC9")+".D_E_L_E_T_ = ' ' "                   
	cSQL += " GROUP BY "
	cSQL += " 	C6_PRODUTO,C6_ITEM,C6_DESCRI,C6_CLI,C6_LOJA,B1_CUSDIP,B1_LISFOR,C6_XVLRINF, C6_XQTDINF, C6_LOCAL, "
	cSQL += " 	C6_PRCVEN,B1_PRVSUPE,B1_PRVMINI,C6_LOTECTL, C6_DTVALID, "
	cSQL += "	CASE WHEN B1_CUSDIP > 0 THEN ((C6_PRCVEN/B1_CUSDIP-1)*100) ELSE 0 END, "
	cSQL += "	CASE WHEN B1_LISFOR > 0 THEN ((C6_PRCVEN/B1_LISFOR-1)*100) ELSE 0 END  "
	
	cSQL := ChangeQuery(cSQL)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),"QRYTMP",.T.,.T.)

EndIf

DipMHead()      

TCSETFIELD("QRYTMP","C6_QTDVEN"	,"N",10,0)                              
TCSETFIELD("QRYTMP","C6_SALDO"	,"N",10,0)       
TCSETFIELD("QRYTMP","B1_CUSDIP"	,"N",17,4)     
TCSETFIELD("QRYTMP","B1_TOTCUS"	,"N",17,4)     
TCSETFIELD("QRYTMP","B1_LISFOR"	,"N",17,4)     
TCSETFIELD("QRYTMP","B1_TOTLIS" ,"N",17,4)     
TCSETFIELD("QRYTMP","C6_PRCVEN"	,"N",17,4)     
TCSETFIELD("QRYTMP","C6_TOTVEN"	,"N",17,4)     
TCSETFIELD("QRYTMP","B1_PRVSUPE","N",17,4)     
TCSETFIELD("QRYTMP","B1_PRVMINI","N",17,4)     
TCSETFIELD("QRYTMP","B1_MARCUS" ,"N",17,2)     
TCSETFIELD("QRYTMP","B1_MARLIS" ,"N",17,2)     
TCSETFIELD("QRYTMP","C6_XVLRINF","N",12,4)     
TCSETFIELD("QRYTMP","C6_DTVALID","D",08,0)     

While !QRYTMP->(Eof())                                                
	
	nValAux	 := 0
	nValDes  := 0
	nValAcr  := 0
	nUserCP  := 0
	nUserAcr := 0               
	
	aAdd(aCols,{ 0,;
				 QRYTMP->C6_PRODUTO,;
				 QRYTMP->C6_DESCRI,;   
				 QRYTMP->C6_QTDVEN,;				 				 				
				 QRYTMP->B1_CUSDIP,;               
				 QRYTMP->B1_MARCUS,;
				 QRYTMP->B1_LISFOR,;
				 QRYTMP->B1_MARLIS,;
				 0,;
				 QRYTMP->C6_PRCVEN,;
				 QRYTMP->C6_TOTVEN,;
				 IIf(QRYTMP->B1_PRVSUPE<QRYTMP->B1_PRVMINI .And. QRYTMP->B1_PRVSUPE>0,QRYTMP->B1_PRVSUPE,0),;
				 QRYTMP->C6_XVLRINF,;				 
				 DipRetEst(QRYTMP->C6_PRODUTO),;
				 DipRetUPV(QRYTMP->C6_CLI,QRYTMP->C6_LOJA,QRYTMP->C6_PRODUTO,QRYTMP->C6_LOCAL),;
 				 IIf(QRYTMP->B1_PRVSUPE<QRYTMP->B1_PRVMINI .And. QRYTMP->B1_PRVSUPE>0,QRYTMP->B1_PRVSUPE,QRYTMP->B1_PRVMINI),;
 				 IIf(QRYTMP->B1_PRVSUPE<QRYTMP->B1_PRVMINI .And. QRYTMP->B1_PRVSUPE>0,0,QRYTMP->B1_PRVMINI),;				 
 				 u_DipCalCons(QRYTMP->C6_PRODUTO),;
				 QRYTMP->C6_ITEM,;				 
				 .F.})                          
				 
	nUserCP := POSICIONE("SE4", 1,xFilial("SE4")+ALLTRIM(SZR->ZR_CONDPAG),"E4_USERDES")      
	nUserAcr:= POSICIONE("SE4", 1,xFilial("SE4")+ALLTRIM(SZR->ZR_CONDPAG),"E4_XUSRACR")      
	/*
	ZZK->(dbSetOrder(1))	
	If ZZK->(dbSeek(xFilial("ZZK")+AllTrim(SZR->ZR_NUMERO)+QRYTMP->(C6_PRODUTO+C6_ITEM)))
		lAprovAnt := .F.
		
		nVlrAux2 := IIf(QRYTMP->B1_PRVSUPE>0 .And. QRYTMP->B1_PRVSUPE<QRYTMP->B1_PRVMINI,QRYTMP->B1_PRVSUPE,QRYTMP->B1_PRVMINI)
		
		If ZZK->ZZK_VLRAPR==QRYTMP->C6_PRCVEN .And. ZZK->ZZK_VLRSIS == nVlrAux2
			aCols[Len(aCols),nPosSta] := "BR_LARANJA"
			lAprovAnt := .T.
		EndIf		
	EndIf
	*/
	If !lAprovAnt           

		lPromo  := .F.
		nValAux := 0
	    aRet    := {}
	    
		If QRYTMP->B1_PRVSUPE > 0 .And. QRYTMP->B1_PRVSUPE < QRYTMP->B1_PRVMINI
			lPromo := .T.			
			nValAux := QRYTMP->B1_PRVSUPE
		ElseIf QRYTMP->B1_PRVSUPE <= 0 //Se Promocao for mairo do que PRVMINI estแ com erro de cadastro
			nValAux := QRYTMP->B1_PRVMINI
		EndIf                         
		                                 
		If nValAux>0             		
			nValAuxOld := nValAux
		
			nValAux := u_DipAcrCli(nValAux,QRYTMP->C6_CLI,QRYTMP->C6_LOJA,QRYTMP->C6_PRODUTO,@nPerCon)    
			
			aCols[Len(aCols),nPosDif] := nPerCon
			
			If nUserCP > 0
				nValAux := Round(nValAux * QRYTMP->C6_QTDVEN,4)
				nValDes := Round(nValAux * ((nUserCP)/100),4)
				nValAux := Round(nValAux - nValDes,4)
				nValAux := Round(nValAux / QRYTMP->C6_QTDVEN,4)   			
			ElseIf nUserAcr > 0
				nValAux := Round(nValAux * QRYTMP->C6_QTDVEN,4)
				nValAcr := Round(nValAux * ((nUserAcr)/100),4)
				nValAux := Round(nValAux + nValAcr,4)
				nValAux := Round(nValAux / QRYTMP->C6_QTDVEN,4)
			EndIf
		   
			aRet := u_VldPerCif(nValAux,AllTrim(SZR->ZR_NUMERO))
			
			nValAux := Round(aRet[1],4) //22/02/19 - ajuste arredondamento - Rafael Lopes
			nPerCif	:= aRet[2]		

			If nValAuxOld<>nValAux .And. nValAux>0 
				If lPromo
					aCols[Len(aCols),nPosVSu] := nValAux
				Else 
					aCols[Len(aCols),nPosVMi] := nValAux
				EndIf                              			
			EndIf             
		EndIf
	
		If QRYTMP->C6_XVLRINF > 0 .And. QRYTMP->C6_XVLRINF<nValAux  
			If QRYTMP->C6_PRCVEN<QRYTMP->C6_XVLRINF
				If u_DipTemCon(QRYTMP->C6_CLI,QRYTMP->C6_LOJA,QRYTMP->C6_PRODUTO,QRYTMP->C6_PRCVEN)  
					aCols[Len(aCols),nPosSta] := "BR_AZUL"
				Else
					aCols[Len(aCols),nPosSta] := "BR_VERMELHO"
				EndIf		
			ElseIf QRYTMP->C6_XQTDINF > 0 .And. QRYTMP->C6_QTDVEN < QRYTMP->C6_XQTDINF
				aCols[Len(aCols),nPosSta] := "BR_LARANJA"
			Else
				aCols[Len(aCols),nPosSta] := "BR_VERDE"
			EndIf			
		Else
			If QRYTMP->C6_PRCVEN<nValAux
				If u_DipTemCon(QRYTMP->C6_CLI,QRYTMP->C6_LOJA,QRYTMP->C6_PRODUTO,QRYTMP->C6_PRCVEN)  
					aCols[Len(aCols),nPosSta] := "BR_AZUL"
				Else
					aCols[Len(aCols),nPosSta] := "BR_VERMELHO"
				EndIf
			ElseIf nValAux <= 0                         
				aCols[Len(aCols),nPosSta] := "BR_AMARELO"            
				aCols[Len(aCols),nPosTot] := QRYTMP->B1_PRVSUPE
			Else
				aCols[Len(aCols),nPosSta] := "BR_VERDE"
			EndIf						
		EndIf	
	EndIf
	
				                
	If nPerCon>0				
		nTotCus	+= QRYTMP->B1_TOTCUS*(1+(nPerCon/100))
		nTotLis	+= QRYTMP->B1_TOTLIS*(1+(nPerCon/100)) 
		aCols[Len(aCols),nPosCus] := aCols[Len(aCols),nPosCus]*(1+(nPerCon/100))
		aCols[Len(aCols),nPosMCu] := ((QRYTMP->C6_PRCVEN/aCols[Len(aCols),nPosCus]-1)*100)
		aCols[Len(aCols),nPosLis] := aCols[Len(aCols),nPosLis]*(1+(nPerCon/100))
		aCols[Len(aCols),nPosMLi] := ((QRYTMP->C6_PRCVEN/aCols[Len(aCols),nPosLis]-1)*100)
	Else                                               	
		nTotCus += QRYTMP->B1_TOTCUS
		nTotLis += QRYTMP->B1_TOTLIS
	EndIf                              
		
	//nTotCus += QRYTMP->B1_TOTCUS
	//nTotLis += QRYTMP->B1_TOTLIS
	nTotVen += QRYTMP->C6_TOTVEN

	QRYTMP->(dbSkip())
EndDo
QRYTMP->(dbCloseArea())
    
nMarCus := (nTotVen/nTotCus-1)*100
nMarLis := (nTotVen/nTotLis-1)*100

Set Key VK_F5 TO DipConPrd()    

DEFINE MSDIALOG oDlg TITLE "Itens para aprova็ใo" From aSize[7],005 TO aSize[6],aSize[5] OF oMainWnd PIXEL    
  
	@ 038,005 SAY "Vl.Tot.Custo" 		SIZE 060,008 			OF oDlg PIXEL
	@ 045,005 MSGET oTotCus VAR nTotCus SIZE 060,010 WHEN .F. 	OF oDlg PIXEL  PICTURE "@E 99,999,999.99"

	@ 038,070 SAY "Vl.Tot.PRC"   	  	SIZE 060,008 			OF oDlg PIXEL
	@ 045,070 MSGET oTotLis VAR nTotLis SIZE 060,010 WHEN .F. 	OF oDlg PIXEL  PICTURE "@E 99,999,999.99"
	
	@ 038,135 SAY "Vl.Total" 		    SIZE 060,008 		  	OF oDlg PIXEL
	@ 045,135 MSGET oTotVen VAR nTotVen SIZE 060,010 WHEN .F.	OF oDlg PIXEL  PICTURE "@E 99,999,999.99"
	
	@ 038,200 SAY "Margem Custo %" 	  	SIZE 060,008 			OF oDlg PIXEL
	@ 045,200 MSGET oMarCus VAR nMarCus SIZE 060,010 WHEN .F. 	OF oDlg PIXEL  PICTURE "@E 999.99 %"
	
	@ 038,265 SAY "Margem PRC %" 	    SIZE 060,008 		  	OF oDlg PIXEL
	@ 045,265 MSGET oMarLis VAR nMarLis SIZE 060,010 WHEN .F.	OF oDlg PIXEL  PICTURE "@E 999.99 %"

	If GetNewPar("ES_NEWPDIF",.T.)
		@ 038,330 SAY "CIF %" 	   			SIZE 050,008 		  	OF oDlg PIXEL
		@ 045,330 MSGET oPerCif VAR nPerCif SIZE 050,010 WHEN .F.	OF oDlg PIXEL  PICTURE "@E 999.99 %"
		
		@ 038,385 SAY "Pagto Ped." 	   		SIZE 160,008 		  	OF oDlg PIXEL
		@ 045,385 MSGET oPgPed	VAR cPgPed  SIZE 160,010 WHEN .F.	OF oDlg PIXEL  PICTURE "@!" 
		   
		@ 038,550 SAY "Pagto Sugerido" 		SIZE 050,008 		  	OF oDlg PIXEL
		@ 045,550 MSGET oPagto	VAR cPagto  SIZE 050,010 F3 "4SE"	OF oDlg PIXEL  PICTURE "@!"  VALID Vazio() .Or. ExistCPO("SE4")
	Else
		@ 038,330 SAY "Cons.Final %" 	   	SIZE 050,008 		  	OF oDlg PIXEL
		@ 045,330 MSGET oPerCon VAR nPerCon SIZE 050,010 WHEN .F.	OF oDlg PIXEL  PICTURE "@E 999.99 %"
		
		@ 038,385 SAY "CIF %" 	   			SIZE 050,008 		  	OF oDlg PIXEL
		@ 045,385 MSGET oPerCif VAR nPerCif SIZE 050,010 WHEN .F.	OF oDlg PIXEL  PICTURE "@E 999.99 %"
		
		@ 038,440 SAY "Pagto Ped." 	   		SIZE 160,008 		  	OF oDlg PIXEL
		@ 045,440 MSGET oPgPed	VAR cPgPed  SIZE 160,010 WHEN .F.	OF oDlg PIXEL  PICTURE "@!" 
		   
		@ 038,610 SAY "Pagto" 	   			SIZE 050,008 		  	OF oDlg PIXEL
		@ 045,610 MSGET oPagto	VAR cPagto  SIZE 050,010 F3 "4SE"	OF oDlg PIXEL  PICTURE "@!"  VALID Vazio() .Or. ExistCPO("SE4")
	EndIf
	
	oGetDados:=MsNewGetDados():New(aPosObj[1,1]+30,aPosObj[1,2],aPosObj[1,3],aPosObj[1,4],0+2,'AllWaysTrue','AllWaysTrue',,{"VLRINF"},/*freeze*/,999,'AllWaysTrue',/*superdel*/,/*delok*/,oDlg,@aHeader,@aCols)
	oGetDados:oBrowse:bAdd    := {|| .F. }      // Nao Permite a inclusao de Linhas
	oGetDados:oBrowse:bDelete := {|| .F. }	     // Nao Permite a deletar Linhas
	aadd(aButtons, {'AVGBOX1',{|| u_DipLegIte()},"Legenda","Legenda"})
	
ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| (u_DipVlrInf(SZR->ZR_NUMERO,cPagto),oDlg:End())},{|| (u_DipVlrInf(SZR->ZR_NUMERO,cPagto),oDlg:End())},,aButtons)

Set Key VK_F5 TO

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDIPDIGMBR บAutor  ณMicrosiga           บ Data ณ  10/24/14   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function DipMHead()
Local cCampos := "STATUS/C6_PRODUTO/C6_DESCRI/C6_QTDVEN/B1_CUSDIP/B1_MARCUS/B1_LISFOR/B1_MARLIS/PERDIF/C6_PRCVEN/C6_TOTVEN/B1_PRVSUPE/VLRINF/C6_TOTEST/UPRV/VLRORI/B1_PRVMINI/MEDIA/C6_ITEM"
Local nPos := 0

While Len(cCampos)>0
	nPos := At("/",cCampos)  
	If nPos <= 0
		nPos := Len(cCampos)+1
	EndIf           
	
	cCampoAux := SubStr(cCampos,1,nPos-1)        
	
	SX3->(dbSetOrder(2))
	If !SX3->(dbSeek(cCampoAux)) .Or. cCampoAux$"C6_PRCVEN/C6_PRODUTO/C6_DESCRI/B1_CUSDIP/B1_LISFOR/B1_PRVMINI/C6_QTDVEN"		
		Do Case                     
			Case cCampoAux=="STATUS"
				AAdd(aHeader,{	"",;
								"STATUS",; 
								"@BMP",;
								2,;
								0,;
								"",;
								"€€€€€€€€€€€€€€",;
								"C",;
								"",;
								"" } )
		
			Case cCampoAux=="B1_MARCUS"
				AAdd(aHeader,{	"Marg.",;
								cCampoAux,; 
								"@E 999.99 %",;
								6,;
								0,;
								"",;
								"€€€€€€€€€€€€€€",;
								"N",;
								"",;
								"" } )
			Case cCampoAux=="B1_MARLIS"
				AAdd(aHeader,{	"Marg.PRC",;
								cCampoAux,; 
								"@E 999.99 %",;
									6,;
								0,;
								"",;
								"€€€€€€€€€€€€€€",;
								"N",;
								"",;
								"" } )
			Case cCampoAux=="C6_TOTVEN"   
				SX3->(dbSeek("C6_PRCVEN"))
				AAdd(aHeader,{	"Tot.Vend.",;
								cCampoAux,; 
								"@E 99,999.9999",;
								10,;
								SX3->X3_DECIMAL,;
								SX3->X3_VALID,;
								SX3->X3_USADO,;
								SX3->X3_TIPO,;
								SX3->X3_ARQUIVO,;
								SX3->X3_CONTEXT } )
			Case cCampoAux=="C6_QTDVEN"   
				SX3->(dbSeek("C6_QTDVEN"))
				AAdd(aHeader,{	"Qtd.",;
								cCampoAux,; 
								"@E 99,999",;
								5,;
								SX3->X3_DECIMAL,;
								SX3->X3_VALID,;
								SX3->X3_USADO,;
								SX3->X3_TIPO,;
								SX3->X3_ARQUIVO,;
								SX3->X3_CONTEXT } )
			Case cCampoAux=="C6_PRCVEN"   
				SX3->(dbSeek(cCampoAux))
				AAdd(aHeader,{	"* VL.UNIT.",;
								cCampoAux,; 
								"@E 99,999.9999",;
								10,;
								SX3->X3_DECIMAL,;
								SX3->X3_VALID,;
								SX3->X3_USADO,;
								SX3->X3_TIPO,;
								SX3->X3_ARQUIVO,;
								SX3->X3_CONTEXT } )
			Case cCampoAux=="C6_TOTEST"    
				SX3->(dbSeek("C6_QTDVEN"))
				AAdd(aHeader,{	"Estoque",;
								cCampoAux,; 
								"@E 99,999,999",;
								10,;
								0,;
								SX3->X3_VALID,;
								SX3->X3_USADO,;
								SX3->X3_TIPO,;
								SX3->X3_ARQUIVO,;
								SX3->X3_CONTEXT } ) 
			Case cCampoAux=="C6_PRODUTO"    
				SX3->(dbSeek(cCampoAux))
				AAdd(aHeader,{	"Produto",;
								cCampoAux,; 
								"@!",;
								1,;
								SX3->X3_DECIMAL,;
								SX3->X3_VALID,;
								SX3->X3_USADO,;
								SX3->X3_TIPO,;
								SX3->X3_ARQUIVO,;
								SX3->X3_CONTEXT } )
			Case cCampoAux=="C6_DESCRI"    
				SX3->(dbSeek(cCampoAux))
				AAdd(aHeader,{	"Descri็ใo",;
								cCampoAux,; 
								SX3->X3_PICTURE,;
								20,;
								SX3->X3_DECIMAL,;
								SX3->X3_VALID,;
								SX3->X3_USADO,;
								SX3->X3_TIPO,;
								SX3->X3_ARQUIVO,;
								SX3->X3_CONTEXT } )
			Case cCampoAux=="B1_CUSDIP"    
				SX3->(dbSeek(cCampoAux))
				AAdd(aHeader,{	"Custo",;
								cCampoAux,; 
								"@E 99,999.9999",;
								11,;
								SX3->X3_DECIMAL,;
								SX3->X3_VALID,;
								SX3->X3_USADO,;
								SX3->X3_TIPO,;
								SX3->X3_ARQUIVO,;
								SX3->X3_CONTEXT } )
			Case cCampoAux=="B1_LISFOR"    
				SX3->(dbSeek(cCampoAux))
				AAdd(aHeader,{	"Prc Forn.",;
								cCampoAux,; 
								"@E 99,999.9999",;
								11,;
								SX3->X3_DECIMAL,;
								SX3->X3_VALID,;
								SX3->X3_USADO,;
								SX3->X3_TIPO,;
								SX3->X3_ARQUIVO,;
								SX3->X3_CONTEXT } )
			Case cCampoAux=="B1_PRVMINI"    
				SX3->(dbSeek(cCampoAux))
				AAdd(aHeader,{	"C",;
								cCampoAux,; 
								"@E 99,999.9999",;
								10,;
								SX3->X3_DECIMAL,;
								SX3->X3_VALID,;
								SX3->X3_USADO,;
								SX3->X3_TIPO,;
								SX3->X3_ARQUIVO,;
								SX3->X3_CONTEXT } ) 
			Case cCampoAux=="VLRORI"    
				AAdd(aHeader,{	"Vlr.Real",;
								cCampoAux,; 
								"@E 999,999.9999",;
								12,;
								4,;
								"",;
								"€€€€€€€€€€€€€€",;
								"N",;
								"",;
								""} ) 								
			Case cCampoAux=="VLRINF"
				AAdd(aHeader,{	"Sugestใo $",;
								cCampoAux,; 
								"@E 999,999.9999",;
								12,;
								4,;
								"",;
								"€€€€€€€€€€€€€€",;
								"N",;
								"",;
								"" } ) 
			Case cCampoAux=="MEDIA"
				AAdd(aHeader,{	"Consumo",;
								cCampoAux,; 
								"@E 99,999,999",;
								10,;
								0,;
								"",;
								"€€€€€€€€€€€€€€",;
								"N",;
								"",;
								"" } )								
			Case cCampoAux=="UPRV"
				AAdd(aHeader,{	"UPRV 60d",;
								cCampoAux,; 
								"@E 999,999.9999",;
								12,;
								4,;
								"",;
								"€€€€€€€€€€€€€€",;
								"N",;
								"",;
								"" } )								
			Case cCampoAux=="PERDIF"
				AAdd(aHeader,{	"% Imp. Difal",;
								cCampoAux,; 
								"@E 999.99 %",;
								6,;
								2,;
								"",;
								"€€€€€€€€€€€€€€",;
								"N",;
								"",;
								"" } )
	    EndCase
	Else
		AAdd(aHeader,{	AllTrim(SX3->X3_TITULO),;
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
	
	If (Len(cCampos)-nPos)>0
		cCampos := Right(cCampos,Len(cCampos)-nPos)
	Else
		Exit
	EndIf
EndDo

nPosSta := aScan(aHeader,{|x| Upper(AllTrim(x[2]))=="STATUS"	})
nPosPro := aScan(aHeader,{|x| Upper(AllTrim(x[2]))=="C6_PRODUTO"})
nPosDes := aScan(aHeader,{|x| Upper(AllTrim(x[2]))=="C6_DESCRI" })
nPosQtd := aScan(aHeader,{|x| Upper(AllTrim(x[2]))=="C6_QTDVEN" })
nPosCus := aScan(aHeader,{|x| Upper(AllTrim(x[2]))=="B1_CUSDIP" })
nPosMCu := aScan(aHeader,{|x| Upper(AllTrim(x[2]))=="B1_MARCUS" })
nPosLis := aScan(aHeader,{|x| Upper(AllTrim(x[2]))=="B1_LISFOR" })
nPosMLi := aScan(aHeader,{|x| Upper(AllTrim(x[2]))=="B1_MARLIS" })
nPosPrc := aScan(aHeader,{|x| Upper(AllTrim(x[2]))=="C6_PRCVEN" })
nPosTot := aScan(aHeader,{|x| Upper(AllTrim(x[2]))=="C6_TOTVEN" })
nPosVSu := aScan(aHeader,{|x| Upper(AllTrim(x[2]))=="B1_PRVSUPE"})
nPosVlr := aScan(aHeader,{|x| Upper(AllTrim(x[2]))=="VLRINF"	})
nPosTEs := aScan(aHeader,{|x| Upper(AllTrim(x[2]))=="C6_TOTEST" })
nPosUpr := aScan(aHeader,{|x| Upper(AllTrim(x[2]))=="UPRV"		})
nPosVMi := aScan(aHeader,{|x| Upper(AllTrim(x[2]))=="B1_PRVMINI"})
nPosOri := aScan(aHeader,{|x| Upper(AllTrim(x[2]))=="VLRORI"  	})
nPosMed := aScan(aHeader,{|x| Upper(AllTrim(x[2]))=="MEDIA"	 	})
nPosIte := aScan(aHeader,{|x| Upper(AllTrim(x[2]))=="C6_ITEM"	})
nPosDif := aScan(aHeader,{|x| Upper(AllTrim(x[2]))=="PERDIF"	})
	
Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDIPALTQTD บAutor  ณMicrosiga           บ Data ณ  08/26/14   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function DipRetEst(cCodPro)
Local cSQL 	  := ""
Local nQtdAux := 0       

cSQL := " SELECT "
cSQL += " 	SUM(B2_QATU-B2_QEMP-B2_RESERVA) QTD"
cSQL += " 	FROM "
cSQL += " 		SB2010 "
cSQL += " 			WHERE "
cSQL += " 				B2_FILIAL IN ('01','04') AND "
cSQL += " 				B2_COD = '"+cCodPro+"' AND "
cSQL += " 				B2_LOCAL = '01' AND "
cSQL += " 				D_E_L_E_T_ = ' ' "

cSQL := ChangeQuery(cSQL)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),"QRYSB2",.T.,.T.)

If !QRYSB2->(Eof())
	nQtdAux := QRYSB2->QTD
EndIf	
QRYSB2->(dbCloseArea())

Return nQtdAux       
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDIPDIGMBR บAutor  ณMicrosiga           บ Data ณ  10/29/14   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function GrvKardex(cTexto)

U_DiprKardex(SZR->ZR_NUMERO,U_DipUsr(),"Aprova็ใo digital - "+cTexto,.t.,"60") 

Return  
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDIPDIGMBR บAutor  ณMicrosiga           บ Data ณ  10/30/14   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function DipRefresh()
Local oObjBrow := GetObjBrow()

dbSelectArea("SZR")
dbSetOrder(4)

If nFilt == 1
	SZR->(dbSetFilter({||  SZR->ZR_FILIAL==xFilial("SZR") .And. alltrim(SZR->ZR_STATUS) $ 'AGUARDANDO' .And. alltrim(SZR->ZR_POSTO)  $ cPostUsu }," SZR->ZR_FILIAL==xFilial('SZR') .And. alltrim(SZR->ZR_STATUS) $ 'AGUARDANDO' .And. alltrim(SZR->ZR_POSTO)  $ cPostUsu  "))
	SZR->(dbGoTop())
Else
	SZR->(dbSetFilter({||  SZR->ZR_FILIAL==xFilial("SZR") .And. alltrim(SZR->ZR_STATUS) $ 'AVALIANDO' .And. alltrim(SZR->ZR_POSTO)  $ cPostUsu }," SZR->ZR_FILIAL==xFilial('SZR') .And. alltrim(SZR->ZR_STATUS) $ 'AVALIANDO' .And. alltrim(SZR->ZR_POSTO)  $ cPostUsu  "))
	SZR->(dbGoTop())
EndIf

oObjBrow:ResetLen()
oObjBrow:GoTop()
oObjBrow:Refresh() 

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDIPDIGMBR บAutor  ณMicrosiga           บ Data ณ  11/25/14   บฑฑ
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
Local aDados := {}
Local cSQL 	 := ""
DEFAULT cPedido := ""

cSQL := " SELECT "
cSQL += " 	ZR_STATUS, ZR_OBSOPER, ZR_OBSOPE2, ZR_OBSAPRO, ZR_USERAPR, ZR_CONDPAG, ZR_VALOR "
cSQL += " 	FROM "
cSQL += 		RetSQLName("SZR")
cSQL += "		WHERE "
cSQL += "			ZR_FILIAL = '"+xFilial("SZR")+"' AND "
cSQL += "			ZR_NUMERO = '"+cPedido+"' AND "
cSQL += "			ZR_STATUS <> 'AGUARDANDO' "
//cSQL += "			D_E_L_E_T_ = '*' "
cSQL += " ORDER BY R_E_C_N_O_  "

cSQL := ChangeQuery(cSQL)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),"QRYSZR",.T.,.T.)                    

TCSETFIELD("QRYSZR","ZR_VALOR" 	,"N",17,2)

While !QRYSZR->(Eof())                               
	aAdd(aDados,{QRYSZR->ZR_OBSOPE2,QRYSZR->ZR_OBSOPER,QRYSZR->ZR_OBSAPRO,QRYSZR->ZR_USERAPR,QRYSZR->ZR_STATUS,QRYSZR->ZR_CONDPAG,TransForm(QRYSZR->ZR_VALOR,"@E 999,999.99")})
	QRYSZR->(dbSkip())
EndDo
QRYSZR->(dbCloseArea())

Return aDados
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDIPDIGMBR บAutor  ณMicrosiga           บ Data ณ  12/12/14   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function DipConPrd()
Local aArea := GetArea()

dbSelectArea("SB1")
SB1->(dbSetOrder(1))
If SB1->(dbSeek(xFilial("SB1")+aCols[oGetDados:NAT,nPosPro]))
	U_DIPA004("APROVACAO")
EndIf

RestArea(aArea)

Return       
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDIPDIGMBR บAutor  ณMicrosiga           บ Data ณ  03/11/15   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function DipLegIte()
Local aCorDesc         

aCorDesc := {	{ "BR_VERDE", 		"- Valor OK" 						},;
				{ "BR_VERMELHO",	"- Valor menor" 					},;
				{ "BR_LARANJA",  	"- Qtd. alterada com valor sugerido"},;     
				{ "BR_AMARELO",		"- Saldo ou Produto com problema"	},;
				{ "BR_AZUL",   		"- Valor negociado"					},;
				{ "BR_BRANCO", 		"- Item promocional (Validade)"  	}}
				

BrwLegenda( "Legenda","Status",aCorDesc )

Return 
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDIPDIGMBR บAutor  ณMicrosiga           บ Data ณ  03/12/15   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function GrvLogZZK(cPedido,cStatus,cComEnv)
Local cSQL 		:= ""
Local aArea 	:= GetArea()                           
Local cSequen 	:= "001"              
Local nValAux	:= 0
Local nValDes	:= 0
Local nValAcr   := 0
Local nUserCP	:= 0
Local nUserAcr  := 0
Local nPerCon	:= 0
Local aRet 		:= {}
DEFAULT cPedido := ""
DEFAULT cStatus := ""
DEFAULT cComEnv := ""

cSQL := " SELECT "
cSQL += " 	C6_NUM, C6_ITEM, C6_PRODUTO, C6_QTDVEN, C6_PRCVEN, C6_PRVSUPE, "
cSQL += " 	C6_PRVMINI, C6_CUSDIP, C6_LISFOR, C6_PRCVEN, C6_XVLRINF, C6_CLI, C6_LOJA  "
cSQL += " 	FROM "
cSQL += 		RetSQLName("SC6")
cSQL += " 		WHERE "
cSQL += " 			C6_FILIAL  = '"+xFilial("SC6")+"' AND "
cSQL += " 			C6_NUM 	   = '"+AllTrim(cPedido)+"' AND "
cSQL += " 			D_E_L_E_T_ = ' ' "
cSQL += " ORDER BY C6_ITEM	"                   

cSQL := ChangeQuery(cSQL)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),"TRBLOG",.T.,.T.)
           
If !TRBLOG->(Eof())
	cSequen := DipZZKSeq(TRBLOG->(C6_NUM))
EndIf
                                            
While !TRBLOG->(Eof())                             
	SB1->(dbSetOrder(1))                   
	If SB1->(dbSeek(xFilial("SB1")+TRBLOG->C6_PRODUTO)) 			
		              
		nUserCP := POSICIONE("SE4", 1,xFilial("SE4")+ALLTRIM(SZR->ZR_CONDPAG),"E4_USERDES")      
		nUserAcr:= POSICIONE("SE4", 1,xFilial("SE4")+ALLTRIM(SZR->ZR_CONDPAG),"E4_XUSRACR")      
			
		If SB1->B1_PRVSUPE > 0 .And. SB1->B1_PRVSUPE < SB1->B1_PRVMINI
			nValAux := SB1->B1_PRVSUPE
		ElseIf SB1->B1_PRVSUPE <= 0 
			nValAux := SB1->B1_PRVMINI
		EndIf                         
		                                 
		If nValAux>0
			nValAux := u_DipAcrCli(nValAux,TRBLOG->C6_CLI,TRBLOG->C6_LOJA,TRBLOG->C6_PRODUTO,@nPerCon)    
					
			If nUserCP > 0
				nValAux := Round(nValAux * TRBLOG->C6_QTDVEN,4)
				nValDes := Round(nValAux * ((nUserCP)/100),4)
				nValAux := Round(nValAux - nValDes,4)
				nValAux := Round(nValAux / TRBLOG->C6_QTDVEN,4)   			
			ElseIf nUserAcr > 0
				nValAux := Round(nValAux * TRBLOG->C6_QTDVEN,4)
				nValAcr := Round(nValAux * ((nUserAcr)/100),4)
				nValAux := Round(nValAux + nValAcr,4)
				nValAux := Round(nValAux / TRBLOG->C6_QTDVEN,4)   			
			EndIf
		    
		    nValAux := u_VldPerCif(nValAux,AllTrim(TRBLOG->C6_NUM))[1]
		EndIf                 		
	
		ZZK->(RecLock("ZZK",.T.))
			ZZK->ZZK_FILIAL := xFilial("ZZK")
			ZZK->ZZK_PEDIDO := TRBLOG->C6_NUM
			ZZK->ZZK_PRODUT := TRBLOG->C6_PRODUTO
			ZZK->ZZK_QUANTI := TRBLOG->C6_QTDVEN
			ZZK->ZZK_VLRAPR := TRBLOG->C6_PRCVEN
			ZZK->ZZK_ITEM   := TRBLOG->C6_ITEM
			ZZK->ZZK_VLRSIS := nValAux
			ZZK->ZZK_STATUS := cStatus
			ZZK->ZZK_SEQUEN := cSequen
			ZZK->ZZK_VLRSUP := TRBLOG->C6_PRVSUPE          //O CUSTO DO C6 Jม TEM O PERCENTUAL DE ICMS DO CONSUMIDOR FINAL
			ZZK->ZZK_VLRMIN := TRBLOG->C6_PRVMINI
			ZZK->ZZK_CUSDIP := TRBLOG->C6_CUSDIP
			ZZK->ZZK_LISFOR := TRBLOG->C6_LISFOR
			ZZK->ZZK_MARDIP := Round((TRBLOG->C6_PRCVEN/TRBLOG->C6_CUSDIP-1)*100,2)
			ZZK->ZZK_MARFOR := Round((TRBLOG->C6_PRCVEN/TRBLOG->C6_LISFOR-1)*100,2)
			ZZK->ZZK_VLRSUG := TRBLOG->C6_XVLRINF
			ZZK->ZZK_ESTOQU := u_DIPSALDSB2(TRBLOG->C6_PRODUTO,.T.,'') 
			ZZK->ZZK_CONSUM := u_DipCalCons(TRBLOG->C6_PRODUTO)
			ZZK->ZZK_DATA   := Date()
			ZZK->ZZK_HORA   := Left(Time(),5)
			ZZK->ZZK_EXPLIC := SubStr(cComEnv,2,Len(cComEnv))
			ZZK->ZZK_USERAP := LogUserName()
			ZZK->ZZK_APROVA := AllTrim(Upper(u_DipUsr()))
	 	ZZK->(MsUnLock()) 		
	EndIf
	TRBLOG->(dbSkip())
EndDo
TRBLOG->(dbCloseArea())

RestArea(aArea)

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDIPDIGMBR บAutor  ณMicrosiga           บ Data ณ  10/13/15   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function DipVlrInf(cPedido,cPagto)     
Local aAreaSC6  := SC6->(GetArea()) 
Local aAreaSC5  := SC5->(GetArea())
Local lAlterado := .F. 
DEFAULT cPagto  := ""

If !Empty(cPagto)   
	SC5->(dbSetOrder(1))
	If SC5->(dbSeek(xFilial("SC5")+AllTrim(cPedido)))
		SC5->(RecLock("SC5",.F.))
			SC5->C5_XCPGINF := cPagto
		SC5->(MsUnLock())
	EndIf
EndIf

aVlrInf := {}
                                
SC6->(dbSetOrder(1))
For nI := 1 to Len(oGetDados:aCols)       
	If oGetDados:aCols[nI,nPosVlr]>0
		If SC6->(dbSeek(xFilial("SC6")+AllTrim(cPedido)+oGetDados:aCols[nI,nPosIte]+oGetDados:aCols[nI,nPosPro]))
			aAdd(aVlrInf,{"Produto (Valor)",oGetDados:aCols[nI,nPosIte]+"-"+AllTrim(oGetDados:aCols[nI,nPosPro])+" ("+AllTrim(Str(oGetDados:aCols[nI,nPosVlr]))+")"})
			If SC6->C6_XVLRINF<>oGetDados:aCols[nI,nPosVlr] 
				SC6->(RecLock("SC6",.F.))
					SC6->C6_XVLRINF := oGetDados:aCols[nI,nPosVlr]                                                   
				SC6->(MsUnLock())
				lAlterado := .T.   
			EndIf
			If SC6->C6_XQTDINF <> oGetDados:aCols[nI,nPosQtd]
				SC6->(RecLock("SC6",.F.))
					SC6->C6_XQTDINF := oGetDados:aCols[nI,nPosQtd]
				SC6->(MsUnLock())
			EndIf
		EndIf
	EndIf
Next nI              

aSort(aVlrInf,,,{|x,y| x[2]<y[2]})
                                                               
If lAlterado
	Aviso("Aten็ใo","Valor(es) Alterado(s) com sucesso.",{"Ok"},1)
EndIf

RestArea(aAreaSC5)
RestArea(aAreaSC6)

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDIPDIGMBR บAutor  ณMicrosiga           บ Data ณ  10/16/15   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function DipVldCan()        
Local lRet := .T.                
/*
For nI := 1 to Len(oGetDados:aCols)       
	If oGetDados:aCols[nI,nPosVlr]>0
		lRet := (Aviso("Aten็ใo","Deseja cancelar a altera็ใo?",{"Sim","Nใo"},1)==1)
		Exit
	EndIf
Next nI   
*/
Return lRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDIPDIGMBR บAutor  ณMicrosiga           บ Data ณ  10/21/15   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function DipObsDir()
Local aArea   :=  GetArea()
Local cObsRes := ""                                      
Local cMEMO   := ""

dbSelectArea("SC5")
SC5->(dbSetOrder(1))
If SC5->(dbSeek(xFilial("SC5")+AllTrim(SZR->ZR_NUMERO)))
	
	cMEMO := MSMM(SC5->C5_XOBSDIR)	          
	                          
	SetPrvt("oDlg","oMGet1","oMGet2","oSBtn")	
	
	oDlg      := MSDialog():New( 088,232,479,635,"oDlg",,,.F.,,,,,,.T.,,,.T. )
	oMGet1     := TMultiGet():New( 004,004,{|u| IIf(Pcount()>0,cObsRes:=u,cObsRes)},oDlg,192,088,,,CLR_BLACK,CLR_WHITE,,.T.,"",,,.F.,.F.,.F.,,,.F.,,.T. )    
	oMGet2     := TMultiGet():New( 096,004,{|| IIf(Empty(cMEMO),"Nใo hแ hist๓rico",cMEMO)}						 ,oDlg,192,080,,,CLR_BLACK,CLR_WHITE,,.T.,"",,,.F.,.F.,.T.,,,.F.,,.T. )    
	oSBtn     := SButton():New( 180,168,1,{|| (IIf(!Empty(cObsRes),u_DipGrvDir(cObsRes,cMEMO),nil),oDlg:End()) },oDlg,,"", )	
	oDlg:Activate(,,,.T.)                                                                            	
EndIf

RestArea(aArea)
	
Return
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
User Function DipGrvDir(cObsRes,cMemo) 
Local cHora	:= Time()  

	cObsRes := AllTrim(u_DipUsr())+" - "+AllTrim(DTOC(dDataBase))+" - "+AllTrim(cHora)+": "+ CHR(10)+CHR(13)+;
				AllTrim(cObsRes)+CHR(10)+CHR(13)+Replicate("_",58)+CHR(10)+CHR(13)+AllTrim(cMemo)
			
	SC5->(RecLock("SC5",.F.))
		MSMM(,TamSX3("C5_XOBSDIR")[1],,cObsRes,1,,,"SC5","C5_XOBSDIR")			
	SC5->(MsUnLock())
	
Return   
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDIPDIGMBR บAutor  ณMicrosiga           บ Data ณ  10/27/15   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function DipCalCons(cProduto)
Local cSQL 	 := ""  
Local nMes 	 := month(dDatabase)
Local cMes1  := ""
Local cMes2  := ""
Local cMes3	 := ""
Local nMedia := 0
     
If nMes==1
	cMes1 := '12'
	cMes2 := '11'
	cMes3 := '10'
ElseIf nMes==2
	cMes1 := '01'	
	cMes2 := '12'
	cMes3 := '11'
ElseIf nMes==3
	cMes1 := '02'
	cMes2 := '01' 
	cMes3 := '12'
Else
	cMes1 := StrZero(nMes-1,2)
	cMes2 := StrZero(nMes-2,2)
	cMes3 := StrZero(nMes-3,2)
EndIf               

cSQL := " SELECT "
cSQL += " 	SUM(B3_Q"+cMes1+") MES1,SUM(B3_Q"+cMes2+") MES2,SUM(B3_Q"+cMes3+") MES3 "
cSQL += " 	FROM "
cSQL += 		RetSQLName("SB3") 
cSQL += " 		WHERE "
cSQL += " 			B3_FILIAL IN ('01','04') AND "
cSQL += " 			B3_COD = '"+cProduto+"' AND "
cSQL += " 			D_E_L_E_T_ = ' ' "                    

cSQL := ChangeQuery(cSQL)      
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),"QRYSB3",.T.,.T.)

IF !QRYSB3->(Eof())   
	nMedia := Round(QRYSB3->(MES1+MES2+MES3)/3,0)
EndIf
QRYSB3->(dbCloseArea())

Return nMedia
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDIPDIGMBR บAutor  ณMicrosiga           บ Data ณ  02/26/16   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function DipBtnAct(nTipo)
Local lSaida  := .T.
DEFAULT nTipo := 0

If nTipo == 1
	If DipVlXVlr(AllTrim(SZR->ZR_NUMERO))
		If Aviso("Aten็ใo","Este pedido possui pre็o sugerido."+CHR(13)+CHR(10)+"Se clicar em CONTINUAR, suas sugest๕es serใo IGNORADAS e o pedido serแ LIBERADO.",{"Cancela","Continua"},2)<>2
			lSaida := .F.
		Else
			nOpcao:=nTipo
			cComEnv:=AprEmai(nOpcao,aMsg,cOperMail,cObsOper)
			If SubStr(cComEnv,1,1)=="1"
				GravDig(cComEnv)
				GrvKardex("APROVADO")
				GrvLogZZK(SZR->ZR_NUMERO,"APROVADO",cComEnv)   
			Else
				lSaida:=.F.
			EndIf
		EndIf
	Else
		nOpcao:=nTipo
		cComEnv:=AprEmai(nOpcao,aMsg,cOperMail,cObsOper)
		If SubStr(cComEnv,1,1)=="1"
			GravDig(cComEnv)
			GrvKardex("APROVADO")
			GrvLogZZK(SZR->ZR_NUMERO,"APROVADO",cComEnv)   
		Else
			lSaida:=.F.
		EndIf
	EndIf
ElseIf nTipo == 2
	nOpcao:=nTipo
	cComEnv:=AprEmai(nOpcao,aMsg,cOperMail,cObsOper)
	If SubStr(cComEnv,1,1)=="1"
		GravDig(cComEnv)
		GrvKardex("REPROVADO")       
		GrvLogZZK(SZR->ZR_NUMERO,"REPROVADO",cComEnv)
	Else		
		lSaida:=.F.
	EndIf
ElseIf nTipo == 4
    nOpcao:=nTipo
	cComEnv:=AprEmai(nOpcao,aMsg,cOperMail,cObsOper)
	u_DipDigDel(SZR->ZR_NUMERO,.T.)
	DipBlqPed("AVALIADO")
EndIf

Return lSaida   
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDIPDIGMBR บAutor  ณMicrosiga           บ Data ณ  02/26/16   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function DipVlXVlr(cPedido)
Local cSQL := ""                 
Local lRet := .F.
DEFAULT cPedido := ""

cSQL := " SELECT "
cSQL += "	C6_FILIAL "
cSQL += "	FROM "
cSQL += 		RetSQLName("SC6")
cSQL += "		WHERE "
cSQL += "			C6_FILIAL = '"+xFilial("SC6")+"' AND "
cSQL += "			C6_NUM = '"+cPedido+"' AND " 
cSQL += "			C6_XVLRINF > 0 AND "
cSQL += "			D_E_L_E_T_ = ' ' "
                                                          
cSQL := ChangeQuery(cSQL)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),'TRBVLINF',.T.,.T.)

If !TRBVLINF->(Eof())
	lRet := .T.
EndIf
TRBVLINF->(dbCloseArea())

Return lRet   
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDIPDIGMBR บAutor  ณMicrosiga           บ Data ณ  06/14/16   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function DipRetUPV(cCliente,cLoja,cProduto,cLocal)
Local nUPRV := 0        
Local cSQL  := ""  
DEFAULT cCliente := ""
DEFAULT cLoja	 := ""
DEFAULT cProduto := ""
DEFAULT cLocal	 := ""

cSQL := " SELECT TOP 1 "
cSQL += " 	D2_PRCVEN "
cSQL += " 	FROM "
cSQL +=  		RetSQLName("SD2")+" WITH(NOLOCK) "
cSQL += " 		WHERE "
cSQL += " 			D2_FILIAL 	= '"+xFilial("SD2")+"' AND "
cSQL += " 			D2_COD 		= '"+cProduto+"' AND "           
cSQL += " 			D2_LOCAL	= '"+cLocal+"' AND "           
cSQL += " 			D2_EMISSAO >= '"+DtoS(dDataBase-60)+"' AND  "
cSQL += " 			D2_CLIENTE 	= '"+cCliente+"' AND "
cSQL += " 			D2_LOJA 	= '"+cLoja+"' AND "
cSQL += " 			D2_TIPO 	= 'N' AND "
cSQL += " 			D_E_L_E_T_ 	= ' ' "
cSQL += " ORDER BY D2_EMISSAO DESC "

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),"QRYUPRV",.T.,.T.)

If !QRYUPRV->(Eof())
	nUPRV := QRYUPRV->D2_PRCVEN
EndIf
QRYUPRV->(dbCloseArea())

Return nUPRV      
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDIPDIGMBR บAutor  ณMicrosiga           บ Data ณ  07/27/16   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function DipZZKSeq(cNumero)
Local cSequen := "001"
Local cSQL    := ""

cSQL := " SELECT "
cSQL += " 	MAX(ZZK_SEQUEN) SEQ "
cSQL += " 	FROM "
cSQL +=  		RetSQLName("ZZK")
cSQL += " 		WHERE "
cSQL += " 			ZZK_FILIAL = '"+xFilial("ZZK")+"' AND "
cSQL += " 			ZZK_PEDIDO = '"+cNumero+"' AND "
cSQL += " 			D_E_L_E_T_ = ' ' "

cSQL := ChangeQuery(cSQL)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),"QRYZZK",.T.,.T.)

If !QRYZZK->(Eof())   
	cSequen := SOMA1(QRYZZK->SEQ)
EndIf
QRYZZK->(dbCloseArea())

Return cSequen

Static Function DipBlqPed(cTexto)
DEFAULT cTexto := ""

SC5->(RecLock("SC5",.F.))
	If cTexto<>"NULL"
		SC5->C5_XSTATUS := cTexto
	EndIf
	SC5->C5_PARCIAL := "N"
	SC5->C5_PRENOTA := "O"    
	SC5->C5_EXPLBLO := "Pedido AVALIADO pelo aprovador ('"+AllTrim(Upper(U_DipUsr()))+"')."
SC5->(MsUnLock())
SC5->(DbCommit())

Return    

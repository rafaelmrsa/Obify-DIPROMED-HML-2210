/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบPrograma  ณ DIPA053()บAutor ณMAXIMO CANUTO       บ Data ณ  11/11//2010 บฑฑ
ฑฑฬออออออออออุอออออออออออสออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc. Efetua transfer๊ncia automแtica entre Dip/CD e Dip/Mtz           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Especifico Estoques Dipromed.                              บฑฑ
ฑฑ------------------------------------------------------------------------บฑฑ
ฑฑบHist๓rico ณ 				                                              บฑฑ
ฑฑบ16/02/11  ณ Tratamento gravando o Status para inibir transf. simultโneaบฑฑ
ฑฑบ18/02/11  ณ Alterado tratamento p/ inibir transf. simultโnea usando    บฑฑ
ฑฑ			 ณ lockByName e UnLockByName 								  บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿           
*/
                                 
#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"  

User Function DIPA053C(lF10)                             

Local cFiltra           := ""         
Local aCores            := {}                                                    
Local _aArea            := GetArea()
Local lOldInclui        := .F.                                                                                             
Local lOldAltera        := .F.
Local aButtons          := {}                              
Local cDestino   
Local cAllLocTran       := GetNewPar("ES_LOCTRAN","'MCANUTO/DDOMINGOS/RBORGES/RBEAZIN/EMATIAS/JNOGUEIRA'")  
Local aEstLocal         := {} 
Local nEstTotal         := 0
Local lConf53C			:=.F.    
Local cCodSZP           := ""   
Local nQtdJaTran        := 0  
Local nQtdTotTran       := 0
Local lConfNovaT        := .F.
Local nReservPed        := 0
Local _nTransfTo        := 0

Private nLocalTran      := 0 
Private cLocalTran      := '01'
Private cFilEmpOrig     := ""  
Private cUserAuth       := GetMV("MV_DIPTRAN")
Private cUserTmp		:= GetNewPar("ES_D053TLV","APIRES/ABARRETO")
Private cCadastro       := "Transfer๊ncia entre Empresas"

DEFAULT lF10  := .T.

PRIVATE aRotina :={{ "Pesquisar"                      ,"AxPesqui"      		   , 0 , 1     },;
								 { "Visualizar"       ,"AxVisual"       		   , 0 , 2     },;
								 { "Incluir"          ,"AxInclui('SZP',0,3,Nil,Nil,Nil,'U_ValproC()')        "        		   , 0 , 3,17},;
								 { "Alterar"          ,"U_D53CDEL('SZP',RECNO(),4)"  , 0 , 4     },;    
								 { "Excluir"          ,"U_D53CDEL('SZP',RECNO(),5)"   , 0 , 5,17},;
								 { "Legenda"          ,"U_D53CLEG()" ,0,7},;
								 { "Transferir"       ,"U_DC53GRP(cLocalTran)" , 0 , 4}  }    // MCVN - 09/11/2007

aAdd(aCores , {'ZP_STATUS = "1"','BR_VERDE'   } )
aAdd(aCores , {'ZP_STATUS = "2"','BR_VERMELHO' } )
aAdd(aCores , {'ZP_STATUS = "3"','BR_PRETO'   } )
//aAdd(aCores , {'ZP_STATUS = "0"','BR_AMARELO'   } )

If Upper(U_DipUsr()) $ cAllLocTran .And. !("MATA410"$FUNNAME())    
    nLocalTran := Aviso('Aten็ใo','Selecione o LOCAL(Almoxarifado) origem?',{'Padrใo=01','Outros'},1) 
    If nLocalTran == 2
		//nLocalTran := Aviso('Aten็ใo','Selecione o LOCAL(Almoxarifado) origem?',{'06','08','09','10','11','12'},3)
		nLocalTran := Aviso('Aten็ใo','Selecione o LOCAL(Almoxarifado) origem?',{'12','11','10','09','08','06',"F"},3)
		do case
			case nLocalTran == 6 ;	cLocalTran  := '06'  
			case nLocalTran == 5 ;	cLocalTran  := '08'  
			case nLocalTran == 4 ;	cLocalTran  := '09'  
			case nLocalTran == 3 ;	cLocalTran  := '10' 
			case nLocalTran == 2 ;	cLocalTran  := '11' 
			case nLocalTran == 1 ;	cLocalTran  := '12' 
			case nLocalTran == 7 ;	Return
		    OtherWise 
 		Endcase
	Endif
Endif 

cFilEmpOrig := If(cEmpAnt+cFilAnt == '0104','1','2')
                                      
If "MATA410"$FUNNAME() .And. Type('aHeader') <> 'U'

	_nPosQtdVen := If( "MATA410"$Funname(),aScan(aHeader, { |x| Alltrim(x[2]) == "C6_QTDVEN"}),0)
	_nPosProd   := If( "MATA410"$Funname(),aScan(aHeader, { |x| Alltrim(x[2]) == "C6_PRODUTO"}),0) // MCVN - 19/10/2007

	If  Posicione("SB1",1,xFilial("SB1")+aCols[n,_nPosProd],"SB1->B1_MALADIR") <> 'S'  //S๓ permite a transfer๊ncia de produtos liberados

  		If Upper(U_DipUsr())$cUserAuth .Or. Upper(U_DipUsr())$cUserTmp
			SZP->(dbSetFilter({|| SZP->ZP_EMPORIG == cFilEmpOrig .And. ZP_LOCAL = cLocalTran}, "SZP->ZP_EMPORIG == cFilEmpOrig .And. ZP_LOCAL = cLocalTran"))
		Else
			SZP->(dbSetFilter({|| SZP->ZP_EMPORIG == cFilEmpOrig .And. Alltrim(SZP->ZP_USERSOL)  $  Upper(U_DipUsr())  .And. ZP_LOCAL = cLocalTran},;
			"SZP->ZP_EMPORIG == cFilEmpOrig .And. Alltrim(SZP->ZP_USERSOL)  $  Upper(U_DipUsr()) .And. ZP_LOCAL = cLocalTran"))
		Endif

		If "MATA410"$FUNNAME() .And. lF10 == .T.
	                                
				aEstLocal  :=U_DIPSALDSB2(aCols[n,_nPosProd],.F.,Iif(cFilAnt=='01',"MTZ","CD")) //Array com os dados referentes ao Estoque
				nEstTotal  :=U_DIPSALDSB2(aCols[n,_nPosProd],.t.,'') //Estoque total dispinํvel
				nQtdJaTran := ExistTran(.F.) // Verifica se Existe transfer๊ncia solicitada para este Produto/Pedido
				nQtdTotTran:= ExistTran(.T.) // Verifica se Existe transfer๊ncia solicitada para este Produtodip
			
				If !Empty(Alltrim(aCols[n,_nPosProd])) .And. ((nEstTotal-nQtdTotTran) - aEstLocal[1][4]) == 0
					MsgBox("Nใo existe saldo no estoque para transfer๊ncia!","TRANSFERสNCIA DE PRODUTOS","INFO")		
				ElseIf Empty(Alltrim(aCols[n,_nPosProd]) )
	    			MsgBox("Produto nใo informado. Nใo ้ possํvel efetuar a transfer๊ncia!","TRANSFERสNCIA DE PRODUTOS","INFO")
				ElseIf aCols[n,_nPosQtdVen] == 0
					MsgBox("Quantidade nใo informada. Nใo ้ possํvel efetuar a transfer๊ncia!","TRANSFERสNCIA DE PRODUTOS","INFO")		    	
				ElseIf aCols[n,_nPosQtdVen] <= aEstLocal[1][4]     	  					                                             
					MsgBox("O estoque Disponํvel ้ suficiente para atender o pedido. Nใo necessita de transfer๊ncia!","Atencao","INFO")			
		    	ElseIf nQtdJaTran > 0 .And. nQtdJaTran < Iif(aCols[n,_nPosQtdVen] > (nEstTotal-nQtdTotTran),(nEstTotal-nQtdTotTran)-aEstLocal[1][4],aCols[n,_nPosQtdVen] - aEstLocal[1][4]) // Verifica se existe transfer๊ncia e se a quantidade ้ Maior
		    		lConfNovaT := MsgBox("Jแ existe uma solicita็ใo de "+AllTrim(Transform(nQtdJaTran,"@E 999,999,999"))+" "+ SB1->B1_UM +" para este produto neste pedido! Confirma a transfer๊ncia de MAIS "+AllTrim(Transform(Iif(aCols[n,_nPosQtdVen] > (nEstTotal-nQtdTotTran),(nEstTotal-nQtdTotTran)-aEstLocal[1][4],aCols[n,_nPosQtdVen] - aEstLocal[1][4])-nQtdJaTran,"@E 999,999,999"))+" - " + SB1->B1_UM +;
					" do Produto "+ Alltrim(aCols[n,_nPosProd]) +" ?","TRANSFERสNCIA DE PRODUTOS","YESNO")
				ElseIf nQtdJaTran > 0 .And. nQtdJaTran >= Iif(aCols[n,_nPosQtdVen] > (nEstTotal-nQtdTotTran),(nEstTotal-nQtdTotTran)-aEstLocal[1][4],aCols[n,_nPosQtdVen] - aEstLocal[1][4]) // Verifica se existe transfer๊ncia e se a quantidade ้ Menor	
	    			MsgBox("Jแ existe uma solicita็ใo de "+AllTrim(Transform(nQtdJaTran,"@E 999,999,999"))+" "+ SB1->B1_UM + " do Produto "+ Alltrim(aCols[n,_nPosProd]) +" para este pedido","TRANSFERสNCIA DE PRODUTOS","INFO")
				ElseIf aCols[n,_nPosQtdVen] <= (nEstTotal-nQtdTotTran)
					lConf53C := MsgBox("Confirma a transfer๊ncia de "+AllTrim(Transform(aCols[n,_nPosQtdVen] - aEstLocal[1][4],"@E 999,999,999"))+" - " + SB1->B1_UM +;
					" do Produto "+ Alltrim(aCols[n,_nPosProd]) +" ?","TRANSFERสNCIA DE PRODUTOS","YESNO")
				ElseIf aCols[n,_nPosQtdVen] > (nEstTotal-nQtdTotTran)  
					lConf53C :=  MsgBox("Quantidade total nใo disponํvel para transfer๊ncia. Confirma a transfer๊ncia de apenas "+AllTrim(Transform(Iif(aCols[n,_nPosQtdVen] > (nEstTotal-nQtdTotTran),(nEstTotal-nQtdTotTran)-aEstLocal[1][4],aCols[n,_nPosQtdVen] - aEstLocal[1][4]),"@E 999,999,999"))+" - " + SB1->B1_UM +;
					" do Produto "+ Alltrim(aCols[n,_nPosProd]) +" ?","TRANSFERสNCIA DE PRODUTOS","YESNO")
				Endif   
	
				If (nQtdJaTran = 0 .And. lConf53C) .Or. lConfNovaT
					cCodSZP := GETSX8NUM("SZP","ZP_CODIGO")   
					ConfirmSX8()                              
					RecLock("SZP",.T.)
					SZP->ZP_FILIAL  := xFilial("SZP") 
					SZP->ZP_CODIGO  := cCodSZP                                                                  
					SZP->ZP_DTSOLIT := Date()
					SZP->ZP_EMPORIG := If(cEmpAnt+cFilAnt =='0101',"1","2")
					SZP->ZP_PRODUTO := aCols[n,_nPosProd]
					SZP->ZP_QUANT   := Iif(aCols[n,_nPosQtdVen] > (nEstTotal-nQtdTotTran),(nEstTotal-nQtdTotTran)-aEstLocal[1][4],aCols[n,_nPosQtdVen] - aEstLocal[1][4]) - nQtdJaTran
					SZP->ZP_USERSOL := Upper(U_DipUsr())             
					SZP->ZP_DTTRANS := DATE()
					SZP->ZP_EXPLIC  := "Pedido "+M->C5_NUM
					SZP->ZP_STATUS  := '1'
					SZP->ZP_LOCAL   := '01'				                                                                                        			
					SZP->(MsUnlock())
					SZP->(DbCommit())    
				EndIf

		ElseIf "MATA410"$FUNNAME() .And. !lF10 .And. cEmpAnt == '01'
		     	                                
			aEstLocal  :=U_DIPSALDSB2(aCols[n,_nPosProd],.F.,Iif(cFilAnt=='01',"MTZ","CD")) //Array com os dados referentes ao Estoque
			nEstTotal  :=U_DIPSALDSB2(aCols[n,_nPosProd],.t.,'') //Estoque total dispinํvel
			nQtdJaTran := ExistTran(.F.) // Verifica se Existe transfer๊ncia solicitada para este Produto/Pedido
			nQtdTotTran:= ExistTran(.T.) // Verifica se Existe transfer๊ncia solicitada para este Produto
			nReservPed := RESPED(SC5->C5_NUM,AllTrim(aCols[n,_nPosProd]))// Verifica se Existe reserva do produto no pedido
			_nTransfTo := Iif(aCols[n,_nPosQtdVen] > (nEstTotal-nQtdTotTran),(nEstTotal-nQtdTotTran)-(aEstLocal[1][4]+nReservPed),aCols[n,_nPosQtdVen] - (aEstLocal[1][4]+nReservPed)) - nQtdJaTran
	
		    If nQtdJaTran > 0 .And. nQtdJaTran < Iif(aCols[n,_nPosQtdVen] > (nEstTotal-nQtdTotTran),(nEstTotal-nQtdTotTran)-(aEstLocal[1][4]+nReservPed),aCols[n,_nPosQtdVen] - (aEstLocal[1][4]+nReservPed)) // Verifica se existe transfer๊ncia e se a quantidade ้ Maior
		    	lConf53C := .T. 
	    		MsgBox("Jแ existe uma solicita็ใo de "+AllTrim(Transform(nQtdJaTran,"@E 999,999,999"))+" "+ SB1->B1_UM +" para este produto neste pedido! Confirma a transfer๊ncia de MAIS "+AllTrim(Transform(Iif(aCols[n,_nPosQtdVen] > (nEstTotal-nQtdTotTran),(nEstTotal-nQtdTotTran)-(aEstLocal[1][4]+nReservPed),aCols[n,_nPosQtdVen] - (aEstLocal[1][4]+nReservPed))-nQtdJaTran,"@E 999,999,999"))+" - " + SB1->B1_UM +;
				" do Produto "+ Alltrim(aCols[n,_nPosProd]) +" ?","TRANSFERสNCIA DE PRODUTOS","YESNO")
			ElseIf aCols[n,_nPosQtdVen] <= (nEstTotal-nQtdTotTran) .And. _nTransfTo > 0
				lConf53C := MsgBox("Confirma a transfer๊ncia de "+AllTrim(Transform(aCols[n,_nPosQtdVen] - (aEstLocal[1][4]+nReservPed),"@E 999,999,999"))+" - " + SB1->B1_UM +;
				" do Produto "+ Alltrim(aCols[n,_nPosProd]) +" ?","TRANSFERสNCIA DE PRODUTOS","YESNO")
			ElseIf aCols[n,_nPosQtdVen] > (nEstTotal-nQtdTotTran) .And. _nTransfTo > 0 
				lConf53C := .T. 
				MsgBox("Quantidade total nใo disponํvel para transfer๊ncia. Confirma a transfer๊ncia de apenas "+AllTrim(Transform(Iif(aCols[n,_nPosQtdVen] > (nEstTotal-nQtdTotTran),(nEstTotal-nQtdTotTran)-(aEstLocal[1][4]+nReservPed),aCols[n,_nPosQtdVen] - (aEstLocal[1][4]+nReservPed)),"@E 999,999,999"))+" - " + SB1->B1_UM +;
				" do Produto "+ Alltrim(aCols[n,_nPosProd]) +" ?","TRANSFERสNCIA DE PRODUTOS","YESNO")
			Endif 
		
			If (nQtdJaTran = 0 .And. lConf53C .And. _nTransfTo > 0) 
				cCodSZP := GETSX8NUM("SZP","ZP_CODIGO")   
				ConfirmSX8()                              
				RecLock("SZP",.T.)
				SZP->ZP_FILIAL  := xFilial("SZP") 
				SZP->ZP_CODIGO  := cCodSZP                                                                  
				SZP->ZP_DTSOLIT := Date()
				SZP->ZP_EMPORIG := If(cEmpAnt+cFilAnt =='0101',"1","2")
				SZP->ZP_PRODUTO := aCols[n,_nPosProd]
				SZP->ZP_QUANT   := _nTransfTo
				SZP->ZP_USERSOL := Upper(U_DipUsr())             
				SZP->ZP_DTTRANS := DATE()
				SZP->ZP_EXPLIC  := "Pedido "+M->C5_NUM
				SZP->ZP_STATUS  := '1'
				SZP->ZP_LOCAL   := '01'				                                                                                        			
				SZP->(MsUnlock())
				SZP->(DbCommit())    
			EndIf
	
		Else
			M->ZP_PRODUTO:= CriaVar("ZP_PRODUTO")
			mBrowse( 6, 1,22,75,"SZP",,,,,,aCores ,,,,,,,,)
		Endif             
	
		SZP->(dbSetFilter({|| .t.},".t.")) 
	Else
		MsgBox("Produto bloqueado para transfer๊ncia. Fale com  departamento de COMPRAS!","TRANSFERสNCIA DE PRODUTOS","INFO")	
	Endif
ElseIf !("MATA410"$FUNNAME())

	If Upper(U_DipUsr())$cUserAuth .Or. Upper(U_DipUsr())$cUserTmp
		SZP->(dbSetFilter({|| SZP->ZP_EMPORIG == cFilEmpOrig .And. ZP_LOCAL = cLocalTran}, "SZP->ZP_EMPORIG == cFilEmpOrig .And. ZP_LOCAL = cLocalTran"))
	Else
		SZP->(dbSetFilter({|| SZP->ZP_EMPORIG == cFilEmpOrig .And. Alltrim(SZP->ZP_USERSOL)  $  Upper(U_DipUsr())  .And. ZP_LOCAL = cLocalTran},;
		"SZP->ZP_EMPORIG == cFilEmpOrig .And. Alltrim(SZP->ZP_USERSOL)  $  Upper(U_DipUsr()) .And. ZP_LOCAL = cLocalTran"))
	Endif

	M->ZP_PRODUTO:= CriaVar("ZP_PRODUTO")
	mBrowse( 6, 1,22,75,"SZP",,,,,,aCores ,,,,,,,,)
	
	SZP->(dbSetFilter({|| .t.},".t.")) 
	
Endif                                  
RestArea(_aArea)
Return()
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบPrograma  ณ DIPA53GRP()บAutor ณMicrosiga           บ Data ณ11/11//2010 บฑฑ
ฑฑฬออออออออออุออออออออออออสออออออฯออออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDesc.     ณValidas as solicita็๕es, busca saldo e chama rotina de 	  บฑฑ
ฑฑบ          ณmovimentos internos totaliza por produto e disponibiliza    บฑฑ       
ฑฑบ          |o item para transfer๊ncia									  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Especifico Estoques Dipromed.                              บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿           
*/

User Function DC53GRP(cLocalTran)

Local oMarcAll      
Local oDlg                      
Local _nOpc
Local _i       := 0
Local lRet     := .T.
Local aButtons := {}
Local bCancel  := {|| _nOpc := 1,oDlg:End()}
Local bOk      := {|| _nOpc := 2,(Processa({||U_DC53TR()},"Transferindo produtos entre empresas!")),oDlg:End()}
Local nTam     := 300	       
Local aArea    := GetArea()

Private cList
Private oList 
Private oVlrSelec
Private nVlrSelec:= 0       

Private nRadio   := 2
Private lMarcAll := .F.
Private aDados   := {}
Private aDadosItem := {}
Private aSize           := MsAdvSize()
Private aInfo            := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 5, 5 }
Private aObjects      := { { 100, 100, .T., .T. } , { 200, 200, .T., .T. } }
Private aPosObj       := MsObjSize( aInfo, aObjects,.T.)
Private lDipM026      := .T.
//
//Private cPerg    := Padr("DIPM027A",10)
Private oMarked	 := LoadBitmap(GetResources(),'LBOK')
Private oNoMarked:= LoadBitmap(GetResources(),'LBNO')
Private cUserAuth:= GetNewPar("MV_DIPTRAN","MCANUTO/RDOMINGOS/RBORGES/MORNELLAS/RBEAZIN/RFERRARIS")
Private cUserTmp := GetNewPar("ES_D053TLV","APIRES/ABARRETO")

If (Alltrim(GetTheme()) <> "TEMAP10") .AND. !SetMdiChild()
	nTam := 375
EndIf

AAdd(aButtons, {"DBG10",{|| fLocaliza() },"Procurar" } )
          
If (cEmpAnt+cFilAnt <> '0104') .And. ( cEmpAnt+cFilAnt <> '0101')
   	Aviso('Aten็ใo',"Rotina indisponํvel para esta empresa!",{'Ok'}) 
	Return()
Endif

If !(Upper(U_DipUsr())$cUserAuth) .And. !(Upper(U_DipUsr())$cUserTmp) 
	Aviso('Aten็ใo',"Usuแrio sem autoriza็ใo para executar esta rotina!",{'Ok'}) 
	Return()
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Cria a Trava com o Nome 'TRANSFERINDO'. Se algum usuario estiver TRANSFERINSOณ
//ณ a rotina de nao podera ser executada               					    	 ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
//-- Parametros da Funcao LockByName() :
//   1o - Nome da Trava
//   2o - usa informacoes da Empresa na chave
//   3o - usa informacoes da Filial na chave 

cChave := "TRANSFERINDO..."
If LockByName(cChave,.T.,.F.)	

	//-----------------------------------------------------
	// Le as informacoes importadas e cria a array de apre-
	// sentacao no browse
	//-----------------------------------------------------
	If !fQuery()       
    	Aviso('Aten็ใo','Nao encontrado dados que satisfacam aos parametros informados!',{'Ok'}) 
	    If Select("TRB") > 0  
    		TRB->( DbCloseArea() )
		EndIf
    	UnLockByName(cChave,.T.,.F.) // Libera Lock
    	Return(.F.)
	EndIf    

	Define MsDialog oDlg Title "Transferindo Produtos entre empresas" From 0,0 To aSize[6]-15,aSize[5]-15 of oMainWnd PIXEL 
                                         
	@ 30,000 ListBox oList var cList Fields HEADER "","PRODUTO","DESCRIวรO","UN. MEDIDA","ORIGEM","QUANTIDADE" ;
	size aSize[5]-392,aSize[6]-(nTam+80) of oDlg Pixel On DBLCLICK fMarca(oList,cLocalTran)

	oList:SetArray(aDados)
	oList:bLine := {|| {Iif(aDados[oList:nAT,1],oMarked,oNoMarked),aDados[oList:nAt,2],aDados[oList:nAt,3],aDados[oList:nAt,4],aDados[oList:nAt,5],aDados[oList:nAt,6]}}

	@ aSize[6]-(nTam+40),001 to aSize[6]-320,aSize[5]-680 Of oDlg Pixel
	@ aSize[6]-(nTam+38),005 checkbox oMarcAll var lMarcAll PROMPT "Marca Todos Produtos" size 100,008 of oDlg on change fMarcAll(oList,cLocalTran)
	@ aSize[6]-(nTam+35),270 say 'Total Selecionando  '  Size 70,08 color CLR_HBLUE Of oDlg Pixel
	@ aSize[6]-(nTam+37),350 msget oVlrSelec var nVlrSelec  Picture "@ke 9,999,999" when .f. size 50,08 of oDlg pixel
 
	Activate Dialog oDlg ON INIT EnchoiceBar(oDlg, bOk, bCancel,,aButtons)

	/*If _nOpc == 1
		    			                                              
		For zpi:= 1 to Len(aDadosItem)
			SZP->(DbGoTo(aDadosItem[zpi][8]))
			RecLock("SZP",.F.)
			SZP->ZP_STATUS   := "1"
			SZP->(MsUnlock())
			SZP->(DbCommit()) 	                   
		Next zpi
	
	Endif */
	UnLockByName(cChave,.T.,.F.) // Libera Lock
Else  
	Aviso('Aten็ใo',"A rotina de transfer๊ncia automแtica estแ sendo executada no momento. Tente novamente mais tarde!",{'Ok'}) 
Endif

RestArea(aArea)

CloseBrowse()

Return(lRet)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณfMarca(X,Y)บAutor ณJailton B Santos-JBSบ Data ณ 09/02/2010  บฑฑ
ฑฑฬออออออออออุอออออออออออสออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Usada para fazer a inversao das marcacoes.                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ TMS - Dipromed                                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function fMarca(oList,cLocalTran)

Local i := 1 
      
aDados[oList:nAT,1] := !aDados[oList:nAT,1]		

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤlฟ
//ณVerificando Saldo no Estoque (Verificamos B2 devํdo ao nosso sistema de reserva ser customizado)ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤlู
dbSelectArea("SB2")
dbSetOrder(1)
If dbSeek(xFilial("SB2")+aDados[oList:nAT,2]+cLocalTran )
	If SaldoSB2()  < Val(aDados[oList:nAT,6])
	     //MsgAlert("Saldo Insuficiente","Aviso")                                  
         Aviso('Aten็ใo',"Saldo Insuficiente.",{'Ok'}) 
         aDados[oList:nAT,1] := .F.
         return(Nil)
	Endif
Endif

// Verifica se a venda estแ de acordo com as regras de caixa de embalagem ou secundแria
If aDados[oList:nAT,1] == .T.
	aDados[oList:nAT,1] := u_Dip071Vld(aDados[oList:nAT,2],Val(aDados[oList:nAT,6]),.T.)
Endif


If aDados[ oList:nAT, 1 ]
    nVlrSelec +=  Val(StrTran(StrTran(aDados[oList:nAT,6],'.',''),',','.'))
Else
    nVlrSelec -= Val(StrTran(StrTran(aDados[oList:nAT,6],'.',''),',','.'))
EndIf    

oList:Refresh()
oVlrSelec:Refresh()

Return( Nil ) 
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณfMarcAll()บAutor  ณJailton B Santos-JBSบ Data ณ 12/02/2010  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMarca ou Desmarca todos as Notas fiscais                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ TMS - Dipromed                                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function fMarcAll(oList,cLocalTran)

Local nId
Local cMarcaT := !aDados[oList:nAT,1]
Local lMarcou := .T.	 

nVlrSelec := 0

/*For nId :=1 to len(aDados)
	dbSelectArea("SB2")
	dbSetOrder(1)
	dbSeek(xFilial("SB2")+aDados[nId,2]+cLocalTran)
	If lMarcAll .and. Empty(aDados[nId,1])  .and. SaldoSB2()  < Val(aDados[nId,6])
		aDados[nId,1] := .F.     
		lMarcou           := .F.
	Else
		aDados[nId,1] := lMarcAll
		If lMarcAll
			nVlrSelec += Val(StrTran(StrTran(aDados[nId,6],'.',''),',','.'))
		EndIf
	EndIf
	
Next nId

If !lMarcou
     Aviso('Aten็ใo','Existem produtos sem saldo ..',{'OK'})
EndIf*/

oList:Refresh()
oVlrSelec:Refresh()

Return(.T.)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณfQuery()   บAutor ณJailton B Santos-JBSบ Data ณ 09/02/2010  บฑฑ
ฑฑฬออออออออออุอออออออออออสออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc. 1:  ณQuery para trazer somado as informacoes para transferir  	  บฑฑ
ฑฑบ          ณprodutos entre empresas                              		  บฑฑ
ฑฑบ          ณA tabela usada ้ SZP 										  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณEST - Dipromed                                              บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function fQuery()     

Local cQuery   := ""              
Local lRet     := .F.
Local cPicQuant:= "@E 999999999"                               //AvSx3("ZP_QUANT",6)
Local cMsg     := ""
Local cOperador:= ""                          
Local lCodigo  := .T.
Local lJob     := .T.
Local xx   


//----------------------------------------------------------------------------------
//cQuery := " SELECT ZP_PRODUTO, B1_DESC, B1_UM, ZP_EMPORIG, SUM(ZP_QUANT)  ZP_QUANT     "
cQuery := " SELECT ZP_PRODUTO, B1_DESC, B1_UM, ZP_EMPORIG, ZP_QUANT , ZP_CODIGO , SZP.R_E_C_N_O_ AS _RECNO, ZP_LOTECTL, ZP_LOCALIZ"
//----------------------------------------------------------------------------------
cQuery += "   FROM SZP010 SZP "
//----------------------------------------------------------------------------------
cQuery += "  INNER JOIN "+  RetSQLName("SB1") +"  SB1 ON B1_FILIAL = '" +xFilial("SB1") +"' AND B1_COD = ZP_PRODUTO   AND SB1.D_E_L_E_T_ <> '*' "
//----------------------------------------------------------------------------------
cQuery += "  WHERE ZP_FILIAL = '" + xFilial("SZP") + "' " 
cQuery += "    AND ZP_QUANT > 0 "
cQuery += "    AND ZP_STATUS = '1' "
cQuery += "    AND ZP_LOCAL = '" + cLocalTran + "' "
//----------------------------------------------------------------------------------
If cEmpAnt+cFIlAnt = '0104'        
	cQuery += "    AND ZP_EMPORIG = '1' "
ElseIf  cEmpAnt+cFIlAnt = '0101'
	cQuery += "    AND ZP_EMPORIG = '2' "                                                         
Else
	cQuery += "    AND ZP_EMPORIG = '' "
Endif
//----------------------------------------------------------------------------------
cQuery += "    AND SZP.D_E_L_E_T_ <> '*' "
//----------------------------------------------------------------------------------
//cQuery += "  GROUP BY ZP_PRODUTO , B1_DESC, B1_UM, ZP_EMPORIG  "
//----------------------------------------------------------------------------------
cQuery += "  ORDER BY ZP_PRODUTO, ZP_CODIGO"
//----------------------------------------------------------------------------------
If Select("TRB") > 0
    TRB->( DbCloseArea() )
EndIf    
//----------------------------------------------------------------------------------
DbCommitAll()
TCQUERY cQuery NEW ALIAS "TRB" 
//----------------------------------------------------------------------------------
TCSETFIELD("TRB","ZP_QUANT" , "N" , 11 , 00)
//----------------------------------------------------------------------------------
aDados := {} // Limpa a array de exibicao do browse 
aDadosItem := {} // Limpa a array de itens selecionados
//----------------------------------------------------------------------------------
lRet := !TRB->( BOF().and.EOF() )                
//----------------------------------------------------------------------------------
// Monta as colunas do Browse no array aDados com as 
// Informacoes lidas pela Query.                      
//----------------------------------------------------------------------------------
TRB->( DbGoTop() ) 

Do While TRB->( !EOF() )

	TRB->(AADD(aDadosItem,{.F.,;          // Marca / Desmarca
	                    ZP_PRODUTO,;        // C๓digo do Produto
	                    B1_DESC,;     // descri็ใo do Produto
	                    B1_UM,;   //Unidade de Medida
	                    If(ZP_EMPORIG=='1',"DIP-CD","DIP-MTZ"),;    // Empresa Origem
	                    Transform(ZP_QUANT,cPicQuant ),;  //Quantidade a Ser transferida
	                    ZP_CODIGO,;
   	                    TRB->_RECNO,;
	                    ZP_LOTECTL,;
	                    ZP_LOCALIZ  })) // cำDIGO + RECNO	                    	                   
    TRB->( DbSkip() )         
	
EndDo
TRB->( DbCloseArea() )
                                             
For xx:= 1 to Len(aDadosItem)
	
	aEstLocal:=U_DIPSALDSB2(aDadosItem[xx][2],.F.,Iif(cFilAnt=='01',"MTZ","CD"),cLocalTran) // Consulta o Saldo atual
	
	nPosProd := Ascan(aDados,{|x| x[2]+x[7]+x[8] == aDadosItem[xx][2]+aDadosItem[xx][9]+aDadosItem[xx][10]})
	
	If nPosProd > 0
		If aEstLocal[1][4] >= Val(aDados[nPosProd][6])+Val(aDadosItem[xx][6])
			aDados[nPosProd][6]:=  Str(Val(aDados[nPosProd][6])+Val(aDadosItem[xx][6]))
		Else
			SZP->(DbGoto(aDadosItem[xx][8]))

			cOperador := SZP->ZP_USERSOL
		    cMsg      := SM0->M0_NOME+" - "+SM0->M0_FILIAL+ Chr(13) + Chr(10)+ Chr(13) + Chr(10) + SZP->ZP_USERSOL+" ,solicita็ใo de  transfer๊ncia  nบ  "+SZP->ZP_CODIGO+" do produto   "+SZP->ZP_PRODUTO +" foi excluํda. Produto sem saldo disponํvel.! "      		    		  			
  			fCic(cOperador,cMsg,lCodigo,lJob)	
			
			SZP->(RecLock("SZP", .F.))
			SZP->(dbDelete())
			SZP->(MsUnlock())  
	    EndIf		
	Else     
		If aEstLocal[1][4] >= Val(aDadosItem[xx][6])                                                                                                                            
			AADD(aDados,{.F.,;                     // Marca / Desmarca
		                    aDadosItem[xx][2],;    // C๓digo do Produto
	    	                aDadosItem[xx][3],;    // Descri็ใo do Produto
	        	            aDadosItem[xx][4],;    // Unidade de Medida
	            	        aDadosItem[xx][5],;    // Empresa Origem
	                	    aDadosItem[xx][6],;    // Quantidade a Ser transferida
   	                    	aDadosItem[xx][9],;    // Lote
	   	                    aDadosItem[xx][10]})   // Localiza็ใo
	    Else
			SZP->(DbGoto(aDadosItem[xx][8]))
			
			cOperador := SZP->ZP_USERSOL
		    cMsg      := SM0->M0_NOME+" - "+SM0->M0_FILIAL+ Chr(13) + Chr(10)+ Chr(13) + Chr(10) + SZP->ZP_USERSOL+" ,solicita็ใo de  transfer๊ncia  nบ  "+SZP->ZP_CODIGO+" do produto   "+SZP->ZP_PRODUTO +" foi excluํda. Produto sem saldo disponํvel.! "      		    		  			
  			fCic(cOperador,cMsg,lCodigo,lJob)	

			SZP->(RecLock("SZP", .F.))
			SZP->(dbDelete())
			SZP->(MsUnlock())  
	    EndIf
	Endif
Next xx

Return(lRet)   

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบPrograma  ณ DIPC53TR()บAutor ณMicrosiga           บ Data ณ  11/11//2010บฑฑ
ฑฑฬออออออออออุอออออออออออสออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณEfetua a transfer๊ncia   movimentando D3, DB, DA, BF, B8, B2บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Especifico Estoques Dipromed.                              บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function DC53TR()

Local lRet		:= .T.
Local cEmpOld	:= cEmpAnt                                     
Local cFilOld	:= cFilAnt
Local aArea     := GetArea()
Local QRY1
Local lEmpOrig := .F.            
Local nQuant := 0
Local nQRest:=0              
Local cFilSZP := xFilial("SZP")
Local cFilSB2 := xFilial("SB2")                                                                                                          
Local lSc9Ok := .F.
Local DtValid := ctod("")                 
Local cOperador := ""
Local cMsg := ""
Local lCodigo := .F.
Local nId,mx,i      
Local lxSaldTr := 1    
Local nVlrCM1  := 0

Private cDipro     := '0104'
Private cHQ        := '0101'          
Private cCusto    := 0            
Private cDocSD3 := ""
Private aRegSD3 := {}
Private aCabSD3 := {}
Private aDadosReq := {}
Private aDadDtVa := {}      
Private aRegSDA := {}                  
 
                                                                                       
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤlฟ
//ณSolicita confirma็ใo de transfer๊nciaณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤlู                 
IF ! MsgBox("Confirma Transfer๊ncia do(s) produto(s) marcado(s)  para "+If(cEmpAnt+cFIlAnt == '0101'," Dipromed/CD ?","Dipromed/Mtz?"),"Atencao","YESNO") 
	Return()
Endif        


Begin Transaction
Begin Sequence

	For nId := 1 to Len(aDados)
		//---------------------------------------------------------------------------------------
		// Pula os produtos nao marcadas pelo usuario
		//---------------------------------------------------------------------------------------
		If !aDados[nId][01]
			Loop
		EndIf
			
		// Buscando Endere็o com mair quantidade para fazer a transfer๊ncia
		If Select("QRY1") > 0
			QRY1->( DbCloseArea() )
		EndIf
			
		If !Empty(Alltrim(aDados[nId][07]))  //Lote Produto
			
			BeginSql Alias "QRY1"
		
				Select BF_PRODUTO, BF_LOCALIZ,  B2_LOCALIZ, BF_LOTECTL,BF_QUANT, BF_LOCAL, BF_EMPENHO,  BF_QUANT - BF_EMPENHO AS SALDO
				From %Table:SBF% SBF
		
				Inner Join %Table:SB2% SB2 on B2_FILIAL = %xFilial:SB2%
				and B2_LOCAL = BF_LOCAL
				and B2_COD     =  BF_PRODUTO
				and SB2.%notdel%
		
				Where BF_FILIAL       = %xFilial:SBF%
				and BF_PRODUTO   = %Exp:aDados[nId][02]%
				and BF_FILIAL          = %xFilial:SBF%
				and BF_LOCAL           = %Exp:cLocalTran%
				and BF_LOTECTL     = %Exp:aDados[nId][07]%
				and BF_LOCALIZ     = %Exp:aDados[nId][08]%
				and BF_QUANT-BF_EMPENHO >= %Exp:aDados[nId][06]%
				and BF_QUANT-BF_EMPENHO > 0 
				and SBF.%notdel%
		
				Order By B2_LOCALIZ, SALDO DESC, BF_LOCALIZ, BF_LOTECTL
		
			EndSql
	
		Else
	
			BeginSql Alias "QRY1"
		    	
				Select 
					ISNULL(B2_LOCALIZ,'99.99.99'), B8_DTVALID, BF_PRODUTO, BF_LOCALIZ,  B2_LOCALIZ, BF_LOTECTL,BF_QUANT, BF_LOCAL, BF_EMPENHO,  BF_QUANT - BF_EMPENHO AS SALDO
					From 
						%Table:SBF% SBF			
						Left Join 
							%Table:SB2% SB2 
							on 
								B2_FILIAL  = %xFilial:SB2% AND
								B2_LOCAL   = BF_LOCAL AND
								B2_COD     = BF_PRODUTO AND   
								B2_LOCALIZ = BF_LOCALIZ AND
								SB2.%notdel%
						Inner Join 
							%Table:SB8% SB8 
							on 
								B8_FILIAL = BF_FILIAL AND
								B8_PRODUTO = BF_PRODUTO AND
								B8_LOCAL = BF_LOCAL AND
								B8_LOTECTL = BF_LOTECTL AND
								B8_SALDO-B8_EMPENHO > 0 AND
								SB8.%notdel%
						Where 
							BF_FILIAL  = %xFilial:SBF%  AND 
							BF_PRODUTO = %Exp:aDados[nId][02]% AND
							BF_FILIAL  = %xFilial:SBF% AND 
							BF_LOCAL   = %Exp:cLocalTran% AND
							BF_QUANT-BF_EMPENHO > 0 AND
							SBF.%notdel%		
				//Order By ISNULL(B2_LOCALIZ,'99.99.99'), B8_DTVALID, RIGHT(RTRIM(BF_LOCALIZ),2), SUBSTRING(BF_LOCALIZ,1,5)
				Order By  B8_DTVALID, ISNULL(B2_LOCALIZ,'99.99.99'),RIGHT(RTRIM(BF_LOCALIZ),2), SUBSTRING(BF_LOCALIZ,1,5)
		
			EndSql
		Endif
		
		DbSelectArea("QRY1")
	
		Do While QRY1->(!Eof()) .And. Val(aDados[nId][06]) > nQuant
			
			nVlrCM1 := DipRetCM1(QRY1->BF_PRODUTO,QRY1->BF_LOCAL)

			IncProc( "Buscando os dados...(SBF) " + QRY1->BF_PRODUTO )

			nQRest :=Val(aDados[nId][06]) -  nQuant
			nQuant :=  nQuant+if(QRY1->BF_QUANT-QRY1->BF_EMPENHO>nQRest,nQRest,QRY1->BF_QUANT-QRY1->BF_EMPENHO)
			Aadd(aDadosReq,{QRY1->BF_PRODUTO, QRY1->BF_LOCAL, QRY1->BF_LOTECTL, QRY1->BF_LOCALIZ, if(QRY1->BF_QUANT-QRY1->BF_EMPENHO>nQRest,nQRest,QRY1->BF_QUANT-QRY1->BF_EMPENHO), Posicione("SB8",3,xFILIAL("SB8")+QRY1->BF_PRODUTO+QRY1->BF_LOCAL+QRY1->BF_LOTECTL,"B8_DTVALID"),nVlrCM1})
			
			QRY1->(DbSkip())
		Enddo     
		If Len(aDadosReq) = 0
	  		Aviso('Aten็ใo',"Transfer๊ncia com problema. NรO Hม SALDO SUFICIENTE NO ESTOQUE POR ENDEREวO!",{'Ok'})   
	  		lxSaldTr := 0
		Endif
		
		nQuant := 0
		dbSelectArea("QRY1")
		QRY1->(dbCloseArea())
	Next nId	     

   // Verificando data de Validade do Lote
   For mx := 1 to Len(aDadosReq)
 	   	If aDadosReq[mx][6] <= Date()
	   		Aviso("Aten็ใo","Produto "+AllTrim(aDadosReq[mx][1])+" Vencido, transfer๊ncia cancelada",{"Ok"})
	   		Aadd(aDadDtVa,{AllTrim(aDadosReq[mx][1])})
	   		// RBorges - 09/09/2019 - Ajuste para nใo interromper a transfer๊ncia quando hแ produto vencido.
	 		//lRet := .F.
		   	//Break
		   	Loop
	    Endif
	Next mx
	
	cDocSD3 := "SZP"+GETSX8NUM("SZP","ZP_CODIGO")                                                                                                    //cDocSD3 := "SZP"+SZP->ZP_CODIGO
		
	If lxSaldTr > 0
		//Chama rotina para fazer a requisi็ใo na Empresa correta
		If lRet
			Processa({|lEnd| lRet := fGeraSD3("501")},"Efetuando a requisi็ใo do Produto...")
		EndIf
		
		If lRet
			If cEmpAnt+cFilAnt == '0104'
				GetEmpr(cHQ)
			Else
				GetEmpr(cDipro)
			Endif
		EndIf
		
		If lRet	
			Processa({|lEnd| lRet := fGeraSD3("497")},"Efetuando a entrada do Produto...")
		EndIf
		If lRet	
			Processa({|lEnd| lRet := fEnder53(cDocSD3)},"Efetuando o endere็amento do Produto..")
		EndIf
		
		// Volta para empresa Origem
		If cEmpAnt+cFilAnt == '0104'
			GetEmpr(cHQ)
		Else	
			GetEmpr(cDipro)
		Endif
	Endif
	If !lRet
		If InTransact()
			DisarmTransaction()
		EndIf
		Break
	EndIf

	// Atualizando SZP com numero do Documento gerado e mudando o Status para 2(transferido)
	For i := 1 To Len( aDadosItem)               
		// ATUALIZANDO SZP COM O NUMEOR DO DOCUMENTO GERADO, DATA, STATUS E USUมRIO QUE EFETUOU A ROTINA
		IF SZP->(DbSeek(cFilSZP+aDadosItem[i][7])) .And.  aDados[Ascan(aDados,{|x| x[2] == aDadosItem[i][2]} ),1] == .T.   // Posicionando no SZP e atualizando o item 
			If Ascan(aDadDtVa,{|x| x[1] == AllTrim(aDadosItem[i][2])}) == 0
				RecLock("SZP",.F.)
				SZP->ZP_DOC     := cDocSD3    
				SZP->ZP_USERTRA := UPPER(U_DipUsr())
				SZP->ZP_STATUS  := "2"
				SZP->ZP_DTTRANS := DATE()
				SZP->(MsUnlock())
				SZP->(DbCommit())
				cOperador := ""
				cMsg := ""
				lCodigo := .F.
				cOperador := SZP->ZP_USERSOL
				//		cOperador :="ROSE.FERRARIS,MAXIMO.CANUTO,ERIBERTO.ELIAS," +Lower(SZP->ZP_USERSOL)
				cMsg := SM0->M0_NOME+" - "+SM0->M0_FILIAL+ Chr(13) + Chr(10)+ Chr(13) + Chr(10) + SZP->ZP_USERSOL+ " ,solicita็ใo de  transfer๊ncia  nบ  "+SZP->ZP_CODIGO+" do produto   "+SZP->ZP_PRODUTO +" foi efetuada com sucesso "      
				lCodigo := .T.
				fCic(cOperador, cMsg, lCodigo,.f.)
			Else
			    //Atualiza variแveis para enviar CIC.
			    // RBorges - 09/09/2019 - Ajuste para nใo interromper a transfer๊ncia quando hแ produto vencido.
				//Disparar o CIC de produto vencidos - RBorges 09/09/2019.
				cOperador := ""
				cMsg := ""
				lCodigo := .F.
				cOperador := SZP->ZP_USERSOL
				cMsg := SM0->M0_NOME+" - "+SM0->M0_FILIAL+ Chr(13) + Chr(10)+ Chr(13) + Chr(10) + SZP->ZP_USERSOL+ " ,solicita็ใo de  transfer๊ncia  nบ  "+SZP->ZP_CODIGO+" do produto   "+SZP->ZP_PRODUTO +" nใo efetuada, produto vencido! "      
				lCodigo := .T.
				fCic(cOperador, cMsg, lCodigo,.f.)
	        EndIf 		
		Endif
	Next i
End Sequence
End Transaction                                   

If cEmpAnt+cFilAnt != cEmpOld+cFilOld
	GetEmpr(cEmpOld+cFilOld)
EndIf

If !lRet
	MsgAlert("Foram encontrados erros na tentativa de Transfer๊ncia! Processo cancelado!","Aten็ใo")
EndIf
    
RestArea(aArea)   
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบPrograma  ณfGeraSD3()บAutor ณMicrosiga           บ Data ณ  11/11//2010 บฑฑ
ฑฑฬออออออออออุออออออออออสออออออฯออออออออออออออออออออสออออออฯออออออออออออออนฑฑ
ฑฑบDesc.     ณEfetua a movimenta็ใo nas duas empresas                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Especifico Estoques Dipromed.                              บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static function fGeraSD3(cTM,lJob)

Local aArea_SB8   := SB8->(GetArea())
Local aArea       := GetArea()
Local lRet	      := .T.
Local cNumseq 
Local _cLocaliz   := ''
Local _NumLote    := ''
Local _cGera      := ''
Local _cEST       := ''
Local _DtValid    := cTod('')                 
Local _TesDev     := ""               
Local nId                    
Local cTime       := SubStr(Time(),1,2)+"_"+SubStr(Time(),4,2)
Local sDate       := dtos( Date() )
Local cPath       := '\LOG_TRANSF_AUTO\'
Local cNomArqErro := If(cFilAnt == '01',"Transf_Matriz_D3 - "+sDate+"-"+cTime+".LOG","Transf_CD_D3 - "+sDate+"-"+cTime+".LOG")
Local cErroTddoemp   := ""
Local nLinhas     := 0
Local cBuffer     := ""
Local cCampo      := ""
Local nErrLin     := 1
Local cBuffer	  := ""       
Local cOperador   := ""
Local cMsg        := ""
Local nCusto	  := 0

Default lJob := .f.

For nId := 1 to len(aDadosReq)
	
	// RBorges - 09/09/2019 - Ajuste para nใo interromper a transfer๊ncia quando hแ produto vencido.
	If aDadosReq[nId][6] <= Date()
		Loop
	EndIf
	
	Begin Sequence
	   

		cNumseq := ProxNum()         
		
		SB1->( Dbsetorder(1) )
		SB1->(Dbseek(xFilial("SB1")+aDadosReq[nId,1]))	
		/*If cTm == '497'
			 aDadosReq[nId,7]  := aDadosReq[nId,7]*aDadosReq[nId,5] 
		Endif*/

		nCusto := aDadosReq[nId,7]*aDadosReq[nId,5] 

		aadd(aRegSD3,{	{"D3_ITEM"		,  StrZero(nId,2)    				   					,Nil},;      
						{"D3_COD"   	, aDadosReq[nId,1]                  				   	,Nil},;      
						{"D3_LOCAL" 	, aDadosReq[nId,2]                			       		,Nil},;
						{"D3_NUMSEQ"	, cNumSeq                            					,Nil},;
						{"D3_QUANT" 	, aDadosReq[nId,5]                 				   		,Nil},;
						{"D3_CF"    	, "RE0"                                           		,Nil},;
						{"D3_UM"    	, SB1->B1_UM                              			   	,Nil},;
						{"D3_TIPO"  	, SB1->B1_TIPO                                       	,Nil},;
						{"D3_GRUPO" 	, SB1->B1_GRUPO                                   		,Nil},;
						{"D3_CUSTO1"	, If(cTm=='501',0, nCusto )     						,Nil},;	
						{"D3_CHAVE"		, "E0"                                                  ,Nil},;
						{"D3_USUARIO"   , UPPER(U_DipUsr())    									,Nil},;    
						{"D3_ESTCIS"    , "S"                                                   ,Nil},;
						{"D3_CONTA"     ,SB1->B1_CONTA                                   		,Nil},;
						{"D3_SEGUM"     , SB1->B1_SEGUM                                   		,Nil},;
						{"D3_QTSEGUM"   , ConvUm(aDadosReq[nId,1], aDadosReq[nId,5] ,0,2 ) 		,Nil},;         
						{"D3_LOTECTL"   , aDadosReq[nId,3]                                  	,Nil},;
						{"D3_NUMLOTE"   , _NumLote                                              ,Nil},;
						{"D3_DTVALID"   , aDadosReq[nId,6]                                   	,Nil},;
						{"D3_LOCALIZ"   , aDadosReq[nId,4]                                  	,Nil},;
						{"D3_EXPLIC"    , If(cTm=='501',"", Alltrim(aDadosReq[nId,4])  +"    - ") + "TRANSFERENCIA AUTOMATICA ENTRE CD'S."  ,Nil}})//Giovani Zago 23/04/12
						
		aCabSD3 :=  {	{"D3_FILIAL"    , xFILIAL("SB1")                       					,Nil},;
						{"D3_DOC"       , cDocSD3        										,Nil},;
						{"D3_TM"        , cTM                                                   ,Nil},;
						{"D3_EMISSAO"   , dDatabase                                             ,Nil},;
						{"D3_CC"        , ""                                                    ,Nil}}		            	
		
   End Sequence    
   
Next nId

If len(aCabSD3) > 0

    lMsErroAuto := .F.
    //MSExecAuto({|x,y,z| MATA240(x,y,z)},aReg,,3)   
    MSExecAuto({|x,y,z| MATA241(x,y,z)},aCabSD3,aRegSD3,3) 

    If lMsErroAuto 
    	DisarmTransaction()   	  	
    	If lJob
	    	cErroTemp:=MostraErro(cPath, cNomArqErro )  
			nLinhas:=MLCount(cErroTemp)
			cBuffer:=""
			cCampo :=""
			nErrLin:=1
			cBuffer:=RTrim(MemoLine(cErroTemp,,nErrLin))               
			//Carrega o nome do campo
			While (nErrLin <= nLinhas)
		    	nErrLin++
			    cBuffer:=RTrim(MemoLine(cErroTemp,,nErrLin))
			    If nErrLin == 4
            		cCampo:=Substr(cBuffer,9,6)
        		    Exit
	    		EndIf
			EndDo    
			For xx:= 1 to Len(aDadosItem)	    	
				If Alltrim(aDadosItem[xx][2]) == Alltrim(cCampo) 
					SZP->(DbGoto(aDadosItem[xx][8]))
					cOperador := 'MAXIMO.CANUTO'
		    		cMsg      := SM0->M0_NOME+" - "+SM0->M0_FILIAL+ Chr(13) + Chr(10)+ Chr(13) + Chr(10) + SZP->ZP_USERSOL+" ,solicita็ใo de  transfer๊ncia  nบ  "+SZP->ZP_CODIGO+" do produto   "+SZP->ZP_PRODUTO +" foi excluํda. Produto sem saldo disponํvel.! "      		    		  			
					fCic(cOperador,cMsg,.f.,lJob)				
					SZP->(RecLock("SZP", .F.))
					SZP->ZP_STATUS = '0'
					SZP->(MsUnlock())  
					ConOut( dtoc( Date() )+" "+Time()+" Solicita็ใo de  transfer๊ncia  nบ  "+SZP->ZP_CODIGO+" do produto   "+SZP->ZP_PRODUTO +" foi excluํda. Produto sem saldo disponํvel.! " ) 
			    EndIf		
			Next xx			           
    	Else                               
	    	MostraErro()
    	Endif
       	lRet := .F.   
    EndIf     

	If cTm == '501'  
		RecLock("SD3",.F.)
			SD3->D3_CUSTO1 := nCusto
		MsUnlock()
		aRegSDA := {}
    	aCabSD3 := {} // JBS 21/08/2010 - Limpa para nao gerar mais 
	    aRegSD3 := {} // JBS 21/08/2010 - Limpa para nao gerar mais 
	Endif
    
EndIf

SB8->(RestArea(aArea_SB8))
RestArea(aArea)
     
Return(lRet)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบPrograma  ณfEnder53()บAutor ณMicrosiga           บ Data ณ  11/11//2010 บฑฑ
ฑฑฬออออออออออุออออออออออสออออออฯออออออออออออออออออออสออออออฯออออออออออออออนฑฑ
ฑฑบDesc.     ณEndere็a os itens transferidos                   			  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Especifico Estoques Dipromed.                              บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function fEnder53(cDocSDA,lJob)

Local lRet    := .T.
Local cSeek   := ''
Local cLoteSDA:= ''
Local lRastro := ''
Local cItens  := '0000'                    
Local cLocaliz := ""
Local aArea     := GetArea()
Local cTime       := SubStr(Time(),1,2)+"_"+SubStr(Time(),4,2)
Local sDate       := dtos( Date() )
Local cPath       := '\LOG_TRANSF_AUTO\'
Local cNomArqErro := If(cFilAnt == '01',"Transf_Matriz_DA - "+sDate+"-"+cTime+".LOG","Transf_CD_DA - "+sDate+"-"+cTime+".LOG")

Private aCabec:= {}
Private aItem := {}
Private aItens := {}

Default lJob := .f.

SDA->(dbSetFilter({|| SDA->DA_DOC== cDocSDA},"SDA->DA_DOC == cDocSDA"))
//SDA->( DbSetOrder(2) )   
SDA->( DbGoTop() ) 
//IF SDA->(DbSeek( xFilial("SDA")+cDocSDA))

	Do While lRet .And. SDA->( !EOF() ) // .And.   SDA->DA_DOC == cDocSDA
		SB2->(dbSetFilter({|| SB2->B2_COD    ==SDA->DA_PRODUTO},"SB2->B2_COD    ==SDA->DA_PRODUTO"))
		SBF->(dbSetFilter({|| SBF->BF_PRODUTO==SDA->DA_PRODUTO},"SBF->BF_PRODUTO==SDA->DA_PRODUTO"))	
		SB8->(dbSetFilter({|| SB8->B8_PRODUTO==SDA->DA_PRODUTO},"SB8->B8_PRODUTO==SDA->DA_PRODUTO"))	
		aCabec := {}
		aItem  := {}

    	Aadd(aCabec, {"DA_PRODUTO"   , SDA->DA_PRODUTO          , nil})
		Aadd(aCabec, {"DA_QTDORI"      , SDA->DA_QTDORI           , nil})
		Aadd(aCabec, {"DA_SALDO"       , SDA->DA_SALDO            , nil})
		Aadd(aCabec, {"DA_DATA"         , SDA->DA_DATA             , nil}) 

	   	Aadd(aCabec, {"DA_LOTECTL"      , SDA->DA_LOTECTL          , nil})
    	Aadd(aCabec, {"DA_NUMLOTE"     , SDA->DA_NUMLOTE          , nil})
    
		Aadd(aCabec, {"DA_LOCAL"        , SDA->DA_LOCAL            , nil})
		Aadd(aCabec, {"DA_DOC"            , SDA->DA_DOC              , nil})
		Aadd(aCabec, {"DA_SERIE"          , SDA->DA_SERIE            , nil})
		Aadd(aCabec, {"DA_CLIFOR"       , SDA->DA_CLIFOR           , nil})
		Aadd(aCabec, {"DA_LOJA"           , SDA->DA_LOJA             , nil})
		Aadd(aCabec, {"DA_TIPONF"        , SDA->DA_TIPONF           , nil})
		Aadd(aCabec, {"DA_ORIGEM"       , SDA->DA_ORIGEM           , nil})
		Aadd(aCabec, {"DA_NUMSEQ"      , SDA->DA_NUMSEQ           , nil})
		Aadd(aCabec, {"DA_QTSEGUM"    , SDA->DA_QTSEGUM          , nil})
		Aadd(aCabec, {"DA_QTDORI2"      , SDA->DA_QTDORI2          , nil})
	
		aITem  := {}     
		aITens := {}     
		cItens := '0'  
		aNfeITE := {}      
	
	    cItens := STRZERO(VAL(cItens)+1,4)//Soma1(SDB->DB_ITEM,4)
        
        cLocaliz := substr(Alltrim(Posicione("SD3",8,xFilial("SD3")+SDA->DA_DOC+SDA->DA_NUMSEQ,"D3_EXPLIC")),1,8)//Giovani Zago 20/04/2012
       // If cLocaliz == 'ZGAIO'//Giovani Zago 20/04/2012
	   //		cLocaliz := 'ZGAIOLA'//Giovani Zago 20/04/2012        	
      //  Endif       //Giovani Zago 20/04/2012
		AAdd(aNfeIte,{{"DB_ITEM"     , cItens        , NIL},;
	        	      {"DB_LOCALIZ"  , cLocaliz          , NIL},;
	    	          {"DB_NUMSERI"  , ''                      , nil},;
		              {"DB_QUANT"    , SDA->DA_SALDO         , NIL},;
		              {"DB_HRINI"    , Time()                , NIL},;
	            	  {"DB_DATA"     , ddatabase       , NIL},;
	        	      {"DB_ESTORNO"  , ''                   , NIL},;
	    	          {"DB_QTSEGUM"  , 0                  , NIL} } )
	
		lMsErroAuto := .F.

		MsExecAuto({|x,y,z| mata265(x,y,z)}, aCabec, aNfeITE, 3 ) // 3-Distribui, 4-Estorna
	
		IF lMsErroAuto
			DisarmTransaction()
	    	If lJob
		    	MostraErro(cPath, cNomArqErro )
	    	Else                               
   		    	MostraErro()
	    	Endif
			lRet := .F.
		Endif          
		
		SB2->(dbSetFilter({|| .t.},".t.")) 
		SBF->(dbSetFilter({|| .t.},".t.")) 
		SB8->(dbSetFilter({|| .t.},".t.")) 
		
		SDA->( Dbskip() )
	
	EndDo

//Endif                                       

SDA->(dbSetFilter({|| .t.},".t.")) // m
aCabSD3 := {}
aRegSD3 := {}

RestArea(aArea)
Return(lRet)


/*//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ’,ำ,ำฟ
//ณValida็ใo do pedido informadoณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ’,ำ,ำู*/
User Function ValCPd53()

Local aArea     := GetArea()
Local lRet         := .F.

If !Empty(M->ZP_PEDIDO)
	SC9->( DbSetOrder(1) )                                         
	SC9->(DbGoTop())
	SC9->( DbSeek(xFilial("SC9")+M->ZP_PEDIDO))
     While !Eof() .And. (xFilial("SC9")+M->ZP_PEDIDO == SC9->(C9_FILIAL+C9_PEDIDO))
		If Empty(SC9->C9_NFISCAL) .And. SC9->C9_QTDORI == SZP->ZP_QUANT .And. !lRet .And. SC9->C9_PRODUTO == M->ZP_PRODUTO
			 lRet  := .T.                  
		Endif	
		SC9->( Dbskip() )
	End                                         
ElseIf Upper(U_DipUsr())  $  "RFERRARIS/MCANUTO/EELIAS/DDOMINGOS/VQUEIROZ/VEGON/RBORGES"
	 lRet  := .T.                  		
Endif
                    
If !lRet
	Aviso("Aten็ใo","Pedido nใo contem o produto!",{"Ok"})
Endif

RestArea(aArea)
Return(lRet)               				

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤlฟ
//ณVerificando Saldo no Estoque (Verificamos B2 devํdo ao nosso sistema de reserva ser customizado)ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤlู
User Function ValSalC53()

dbSelectArea("SB2")
dbSetOrder(1)
If dbSeek(xFilial("SB2")+M->ZP_PRODUTO+cLocalTran)
	If SaldoSB2()  < M->ZP_QUANT
//	     MsgAlert("Saldo Insuficiente","Aviso")
         Aviso('Aten็ใo',"Saldo Insuficiente.",{'Ok'}) 
         Return(.F.)
	Endif
Endif	            

Return(.T.)      

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤlฟ
//ณValidando c๓digo do produto (Se o fornecedor for HQ-MATRIZ nใo permitir a transf. - MCVN 24/11/11ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤlู
User Function ValproC()
Local lRet 		:= .T.
                         
dbSelectArea("SB1")
dbSetOrder(1)                    

If dbSeek(xFilial("SB1")+M->ZP_PRODUTO)
	If SB1->B1_PROC = '000000000'//'051508' 
         Aviso('Aten็ใo',"A transfer๊ncia de produtos fornecidos pela HQ-MATRIZ nใo estแ autorizada.",{'Ok'}) 
         lRet := .F.
	Endif                                       
	If lRet
		lRet := u_Dip071Vld(SB1->B1_COD,M->ZP_QUANT,.T.)
	EndIf
Else                                                                                                           
    Aviso('Aten็ใo',"Produto nใo encontrado.",{'Ok'}) 
	lRet := .F.
Endif	
        
//Verifica Saldo SB2  
If lRet
	lRet := (U_DIPC53B2(M->ZP_PRODUTO,.F.))
Endif

Return lRet 


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณfFindCIC()บ Autor ณJailton B Santos-JBSบ Data ณ 25/05/2010  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Busca o nome do usuario do CIC para enviar mensagen-lhe    บฑฑ
ฑฑบ          ณ mensagens.                                                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function fFindCic(cCodigo)  

Local aArea   := GetArea()
Local cQuery  := ""
Local cUsuCIC := ""   

PswOrder(2)
If PswSeek(cCodigo,.T.)
	aUsuario := PswRet()
EndIf

                       
cQuery := " Select U7_CICNOME CIC "
cQuery += "   from "+RetSqlName('SU7')+" SU7 "
cQuery += "  where U7_FILIAL = '" + xFilial('SU7')+ "' "
cQuery += "    and U7_CODUSU  = '"+ aUsuario[1][1] + "' "
cQuery += "    and SU7.D_E_L_E_T_ = '' "
// RBorges 26/08/2014 - Comentado o union, pois nใo serแ disparado CIC para os compradores.
/* 
cQuery += " Union Select Y1_NOMECIC CIC "
cQuery += "   from " + RetSqlName('SY1')+ " SY1 "
cQuery += "  where Y1_FILIAL  = '" +xFilial('SY1')+ "' "
cQuery += "    and Y1_USER  = '"+ aUsuario[1][1] + "' "
cQuery += "    and SY1.D_E_L_E_T_ = '' "
 */
If Select("TRBCIC53") > 0 
    TRBCIC53->(DbCloseArea())
EndIf

TcQuery cQuery NEW ALIAS "TRBCIC53"  

SY1->(dbSetOrder(3))  //RBorges 22/08/2014 - Valida็ใo para nใo carregar o CIC dos compradores.
If !TRBCIC53->(BOF() .and. EOF() ) .And. !SY1->(dbSeek(xFilial("SY1")+aUsuario[1][1]))                              
    cUsuCIC := TRBCIC53->CIC
EndIf                
TRBCIC53->( DbCloseArea() )         

RestArea(aArea)

Return(cUsuCIC)      
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ fCic()   บAutor  ณJailton B Santos-JBSบ Data ณ 25/05/2010  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Esta funcao dispara uma mensagem de CIC para um ou mais    บฑฑ
ฑฑบ          ณ usuarios.                                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Especificos Faturamento Dipromed                           บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function fCic(cOperador,cMsg,lCodigo,lJob)

Local lRet        := .T.
Local cMail
Local cServidor   := GetMV("MV_CIC")     // Servidor para enviar mensagem pelo CIC
Local cOpFatRem   := GetMV("MV_REMETCI") // Usuario do CIC remetente de mensgens no Protheus
Local cOpFatSenha := "123456"
Local cOpFatDest  := ""

Default lJob      := .F.
                     
If lCodigo   
   If !lJob
	   cOpFatDest := fFindCic(cOperador)  
   Else
	   cOpFatDest += fFindCic(cOperador)  
   Endif
Else
   cOpFatDest += upper(cOperador) 
EndIf                           

U_DIPCIC(cMsg,AllTrim(cOpFatDest))//RBorges 12/03/15
//WaitRun(cServidor+' '+cOpFatRem+' '+cOpFatSenha+' "'+AllTrim(cOpFatDest)+'" "' + cMsg + '" ')   //Comentada RBorges 12/03/15

// Filtra novamente SZP
If !lJob
	SZP->(dbSetFilter({|| SZP->ZP_EMPORIG == cFilEmpOrig}, "SZP->ZP_EMPORIG == cFilEmpOrig"))
Endif

Return(lRet)                      

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณD53DelAlt บAutor  ณMaximo				 บ Data ณ  24/11/2010 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Faz a exclusใo da solicita็ใo   							  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function D53CDel(cAlias,nReg,nOpc)
Local lRet := .T.

If SZP->ZP_STATUS == "2" // Status Transferido
	lRet := .F.
Endif

If nOpc == 5
	if(lRet)
		AxDeleta(cAlias,nReg,nOpc)
	Else
		MsgStop("Solicita็ใo jแ processada.","Impossํvel excluir!")
	EndIF

Else
	
	if(lRet)
		AxAltera(cAlias,nReg,nOpc)
	Else
		MsgStop("Solicita็ใo jแ processada.","Impossํvel alterar!")
	EndIF             
Endif



Return lRet                           

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณPrograma  ณD53LEG()	 ณAutor ณMaximo  				ณ Data ณ24/11/2010ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUso       ณ Especifico Faturamento Dipromed.                           ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
User Function D53CLEG()

Local aLegenda:={}

aAdd(aLegenda, {'BR_VERDE'   ,"Aguardando transfer๊ncia" } )  // 1
aAdd(aLegenda, {'BR_VERMELHO',"Transferido"              } )  // 2
aAdd(aLegenda, {'BR_PRETO'   ,"Solicita็ใo cancelada"    } )  // 3
//aAdd(aLegenda, {'BR_AMARELO' ,"Transfer๊ncia em Processamento"   } )  // 4

BrwLegenda("Transferencia",OemToAnsi("Transferencia"),aLegenda)

Return  



//SALDO SB2 
User Function DIPC53B2(_cProduto, lBotao)
 
Local nEstDipro:= 0
Local nEstHQ   := 0
Local QRY1     := "" 
Local QRY2     := "" 
Local _cLocal  := M->ZP_LOCAL
Local _xAlias  := GetArea()
Local _lRet    := .T.             

Default lBotao := .F.


// ESTOQUE DIPROMED/CD
QRY1 := "SELECT "
QRY1 += " (B2_QATU-B2_QACLASS-B2_RESERVA) AS ESTOQUE "
QRY1 += " FROM SB2010"
QRY1 += " WHERE B2_FILIAL = '04' " 
QRY1 += " AND B2_COD = '" + _cProduto + "'"
QRY1 += " AND B2_LOCAL = '" + _cLocal +"'"
QRY1 += " AND SB2010.D_E_L_E_T_ = ' '"   

#xcommand TCQUERY <sql_expr>                          ;
[ALIAS <a>]                                           ;
[<new: NEW>]                                          ;
[SERVER <(server)>]                                   ;
[ENVIRONMENT <(environment)>]                         ;
=> dbUseArea(                                         ;
<.new.>,                                              ;
"TOPCONN",                                            ;
TCGENQRY(<(server)>,<(environment)>,<sql_expr>),      ;
<(a)>, .F., .T.)
	
// PROCESSA QUERY SQL
DbCommitAll()
TcQuery QRY1 NEW ALIAS "QRY1"         // ABRE UMA WORKAREA COM O RESULTADO DA QUERY

// ESTOQUE DIPROMED/MTZ
QRY2 := "SELECT "
QRY2 += " (B2_QATU-B2_QACLASS-B2_RESERVA) AS ESTOQUE "
QRY2 += " FROM SB2010"
QRY2 += " WHERE B2_FILIAL = '01' " 
QRY2 += " AND B2_COD = '" + _cProduto + "'"
QRY2 += " AND B2_LOCAL = '" + _cLocal +"'"
QRY2 += " AND SB2010.D_E_L_E_T_ = ' '"   

#xcommand TCQUERY <sql_expr>                          ;
[ALIAS <a>]                                           ;
[<new: NEW>]                                          ;
[SERVER <(server)>]                                   ;
[ENVIRONMENT <(environment)>]                         ;
=> dbUseArea(                                         ;
<.new.>,                                              ;
"TOPCONN",                                            ;
TCGENQRY(<(server)>,<(environment)>,<sql_expr>),      ;
<(a)>, .F., .T.)
	
// PROCESSA QUERY SQL
DbCommitAll()
TcQuery QRY2 NEW ALIAS "QRY2"         // ABRE UMA WORKAREA COM O RESULTADO DA QUERY

DbSelectArea("QRY1")
QRY1->(dbGotop())         
	nEstDipro := QRY1->ESTOQUE
DBCLOSEAREA("QRY1")

DbSelectArea("QRY2")
QRY2->(dbGotop())         
	nEstHQ    := QRY2->ESTOQUE
DBCLOSEAREA("QRY2")

If !lBotao .And. (Readvar()= 'M->ZP_QUANT' .Or. M->ZP_QUANT > 0)
	If M->ZP_EMPORIG = '1'
		If nEstDipro < M->ZP_QUANT  
			Aviso("Aten็ใo","Saldo insuficiente na DIPROMED/CD."+chr(13)+chr(10)+"O Saldo Atual ้: "+Transform(nEstDipro,"@E 999,999,999" ),{"Ok"})			
			_lRet := .F.                                                 
		Endif
	Else	                        
		If nEstHQ    < M->ZP_QUANT  
			Aviso("Aten็ใo","Saldo insuficiente na DIPROMED/MTZ."+chr(13)+chr(10)+"O Saldo Atual ้: "+Transform(nEsthq,"@E 999,999,999" ) ,{"Ok"})				

 		   _lRet := .F.
		Endif
	Endif          

	If _lRet                                                                              
		_lRet := u_Dip071Vld(_cProduto,M->ZP_QUANT,.T.)
	EndIf
Else//If "MATA410"$Funname()    
//	If M->ZP_EMPORIG = '2'                
		Aviso("SALDO ATUAL NOS CD'S",chr(13)+chr(10)+"DIPROMED/CD   "+Transform(nEstDipro,"@E 999,999,999" )+chr(13)+chr(10)+;
		"-----------------------------------------------------------------------------"+chr(13)+chr(10)+;
		"DIPROMED/MTZ  "+Transform(nEsthq,"@E 999,999,999" ),{"Ok"},2)
//	Else                                                                                                                                     
	//	Aviso("Aten็ใo","Saldo na DIPROMED   "+Transform(nEstoque,"@E 999999999" ) ,{"Ok"})
//	Endif
//Else
//	If M->ZP_EMPORIG = '2'                
//		Aviso("Aten็ใo","Saldo na HQ   "+Transform(nEstoque,"@E 999999999" ) ,{"Ok"})
//	Else                                                                                                                                     
//		Aviso("Aten็ใo","Saldo na DIPROMED   "+Transform(nEstoque,"@E 999999999" ) ,{"Ok"})
//	Endif              

Endif                       

RestArea(_xAlias)
Return(_lRet)          
                      
/////////////////////////////////////////////////////////////////
//SALDO SB8 
User Function DIPC53B8(_cProduto,cLocalTran)

Local _lRet := .T.

dbSelectArea("SB8")
dbSetOrder(3)
If dbSeek(xFilial("SB8")+_cProduto+cLocalTran+M->ZP_LOTECTL )
	If SB8SALDO()  < (M->ZP_QUANT)
	     Aviso('Aten็ใo',"SALDO INSUFICIENTE.",{'Ok'}) 
	     _lRet := .F.
         Return(_lRet)
	Endif
Else
    Aviso('Aten็ใo',"LOTE INEXISTENTE.",{'Ok'}) 
	_lRet := .F.
    Return(_lRet)
Endif


Return(_lRet) 

////////////////////////////////////////////////////////////////////
//SALDO SBF 
User Function DIPC53BF(_cProduto,cLocalTran)

Local _lRet := .T.

dbSelectArea("SBF")
dbSetOrder(1)
If dbSeek(xFilial("SBF")+cLocalTran+M->ZP_LOCALIZ+_cProduto+Space(TamSX3("BF_NUMSERI")[1])+M->ZP_LOTECTL)
	If SBFSALDO()  < (M->ZP_QUANT)
	     Aviso('Aten็ใo',"SALDO INSUFICIENTE.",{'Ok'}) 
	     _lRet := .F.
         Return(_lRet)
	Endif
Else
    Aviso('Aten็ใo',"ENDEREวO SEM SALDO.",{'Ok'}) 
	_lRet := .F.
    Return(_lRet)
Endif

Return(_lRet) 

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤlฟ
//ณValidando c๓digo do produto (Se o fornecedor for HQ-MATRIZ nใo permitir a transf. - MCVN 24/11/11ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤlู
User Function Valprodut()
Local lRet 		:= .T.

dbSelectArea("SB1")
dbSetOrder(1)
If dbSeek(xFilial("SB1")+M->ZP_PRODUTO)
	If SB1->B1_PROC = '000000000'//'051508' 
         Aviso('Aten็ใo',"A transfer๊ncia de produtos fornecidos pela HQ-MATRIZ nใo estแ autorizada.",{'Ok'}) 
         lRet := .F.
	Endif                                       
	If lRet
		lRet := u_Dip071Vld(SB1->B1_COD,M->ZP_QUANT,.T.)
	EndIf
Else                                                                                                           
    Aviso('Aten็ใo',"Produto nใo encontrado.",{'Ok'}) 
	lRet := .F.
Endif	
        

Return lRet 


//SALDO SB2 
User Function DIP53B2(_cProduto)
 
Local nEstDipro := 0
Local nEstHQ := 0
Local QRY1     := "" 
Local QRY2     := "" 
Local _cLocal  := M->ZP_LOCAL
Local _xAlias  := GetArea()
Local _lRet    := .T.

If IsInCallStack("U_DIPA053C") .Or. "MATA410"$Funname()
	Return U_DIPC53B2(_cProduto,.F.)
EndIf


// ESTOQUE DIPROMED
QRY1 := "SELECT "
QRY1 += " (B2_QATU-B2_QACLASS-B2_RESERVA) AS ESTOQUE "
QRY1 += " FROM SB2010
QRY1 += " WHERE B2_FILIAL = '04' " 
QRY1 += " AND B2_COD = '" + _cProduto + "'"
QRY1 += " AND B2_LOCAL = '" + _cLocal +"'"
QRY1 += " AND SB2010.D_E_L_E_T_ = ' '"   

#xcommand TCQUERY <sql_expr>                          ;
[ALIAS <a>]                                           ;
[<new: NEW>]                                          ;
[SERVER <(server)>]                                   ;
[ENVIRONMENT <(environment)>]                         ;
=> dbUseArea(                                         ;
<.new.>,                                              ;
"TOPCONN",                                            ;
TCGENQRY(<(server)>,<(environment)>,<sql_expr>),      ;
<(a)>, .F., .T.)
	
// PROCESSA QUERY SQL
DbCommitAll()
TcQuery QRY1 NEW ALIAS "QRY1"         // ABRE UMA WORKAREA COM O RESULTADO DA QUERY

// ESTOQUE HQ
QRY2 := "SELECT "
QRY2 += " (B2_QATU-B2_QACLASS-B2_RESERVA) AS ESTOQUE "
QRY2 += " FROM SB2040                  
QRY2 += " WHERE B2_FILIAL = '04' " 
QRY2 += " AND B2_COD = '" + _cProduto + "'"
QRY2 += " AND B2_LOCAL = '" + _cLocal +"'"
QRY2 += " AND SB2040.D_E_L_E_T_ = ' '"   

#xcommand TCQUERY <sql_expr>                          ;
[ALIAS <a>]                                           ;
[<new: NEW>]                                          ;
[SERVER <(server)>]                                   ;
[ENVIRONMENT <(environment)>]                         ;
=> dbUseArea(                                         ;
<.new.>,                                              ;
"TOPCONN",                                            ;
TCGENQRY(<(server)>,<(environment)>,<sql_expr>),      ;
<(a)>, .F., .T.)
	
// PROCESSA QUERY SQL
DbCommitAll()
TcQuery QRY2 NEW ALIAS "QRY2"         // ABRE UMA WORKAREA COM O RESULTADO DA QUERY

DbSelectArea("QRY1")
QRY1->(dbGotop())         
	nEstDipro := QRY1->ESTOQUE
DBCLOSEAREA("QRY1")

DbSelectArea("QRY2")
QRY2->(dbGotop())         
	nEstHQ    := QRY2->ESTOQUE
DBCLOSEAREA("QRY2")

If Readvar()= 'M->ZP_QUANT'                                                          
	If M->ZP_EMPORIG = '1'
		If nEstDipro < M->ZP_QUANT  
			Aviso("Aten็ใo","Saldo insuficiente na DIPROMED." ,{"Ok"})
			_lRet := .F.
		Endif
	Else	                        
		If nEstHQ    < M->ZP_QUANT  
			Aviso("Aten็ใo","Saldo insuficiente na HEALTH." ,{"Ok"})
			_lRet := .F.		
		Endif
	Endif
Else//If "MATA410"$Funname()    
//	If M->ZP_EMPORIG = '2'                
		Aviso("SALDO ATUAL NOS CD'S",chr(13)+chr(10)+"DIPROMED   "+Transform(nEstDipro,"@E 999,999,999" )+chr(13)+chr(10)+;
		"-----------------------------------------------------------------------------"+chr(13)+chr(10)+;
		"HEALTH       "+Transform(nEsthq,"@E 999,999,999" ),{"Ok"},2)
//	Else                                                                                                                                     
	//	Aviso("Aten็ใo","Saldo na DIPROMED   "+Transform(nEstoque,"@E 999999999" ) ,{"Ok"})
//	Endif
//Else
//	If M->ZP_EMPORIG = '2'                
//		Aviso("Aten็ใo","Saldo na HQ   "+Transform(nEstoque,"@E 999999999" ) ,{"Ok"})
//	Else                                                                                                                                     
//		Aviso("Aten็ใo","Saldo na DIPROMED   "+Transform(nEstoque,"@E 999999999" ) ,{"Ok"})
//	Endif              

Endif
RestArea(_xAlias)
Return(_lRet)                         

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
Static Function ExistTran(lTotSolic)     

Local cQuery    := ""              
Local lRet      := .F.
Local nQtdTran  := 0
Local xx      

Default lTotSolic := .F.

//----------------------------------------------------------------------------------
cQuery := " SELECT SUM(ZP_QUANT) ZP_QUANT "
//----------------------------------------------------------------------------------
cQuery += "   FROM SZP010 SZP "
cQuery += "   WHERE ZP_FILIAL = '" + xFilial("SZP") + "' " 
cQuery += "   AND ZP_QUANT  > 0 "
cQuery += "   AND ZP_STATUS = '1' "
cQuery += "   AND ZP_LOCAL  = '01' "     
If !lTotSolic 
	cQuery += "   AND ZP_EXPLIC LIKE  '%" + M->C5_NUM + "%' " 
Endif
cQuery += "   AND ZP_PRODUTO=  '" + aCols[n,_nPosProd] + "' " 
//cQuery += "   AND ZP_DTSOLIT=   '" + DtoS(Date()) + "' " 
//----------------------------------------------------------------------------------
If cEmpAnt+cFIlAnt = '0104'
	cQuery += "    AND ZP_EMPORIG = '2' "
ElseIf  cEmpAnt+cFIlAnt = '0101'
	cQuery += "    AND ZP_EMPORIG = '1' "                                                         
Else
	cQuery += "    AND ZP_EMPORIG = '' "
Endif
//----------------------------------------------------------------------------------
cQuery += "    AND SZP.D_E_L_E_T_ <> '*' "
//----------------------------------------------------------------------------------
cQuery += "  GROUP BY ZP_PRODUTO "
//----------------------------------------------------------------------------------
If Select("TRBEXZP") > 0
    TRBEXZP->( DbCloseArea() )
EndIf    
//----------------------------------------------------------------------------------
DbCommitAll()
TCQUERY cQuery NEW ALIAS "TRBEXZP" 
//----------------------------------------------------------------------------------
TCSETFIELD("TRBEXZP","ZP_QUANT" , "N" , 11 , 00)
//----------------------------------------------------------------------------------
lRet := !TRBEXZP->( BOF().and.EOF() )                
//----------------------------------------------------------------------------------
// Monta as colunas do Browse no array aDados com as 
// Informacoes lidas pela Query.                      
//----------------------------------------------------------------------------------
TRBEXZP->( DbGoTop() ) 

Do While TRBEXZP->( !EOF() )

	nQtdTran := TRBEXZP->ZP_QUANT
	                                       
    TRBEXZP->( DbSkip() )         
	
EndDo
            
TRBEXZP->( DbCloseArea() )

Return(nQtdTran)   

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบPrograma  ณ DIPC53TR()บAutor ณMaximo              บ Data ณ   16/10/2015บฑฑ
ฑฑฬออออออออออุอออออออออออสออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณEfetua a transfer๊ncia via Job  -     D3, DB, DA, BF, B8, B2บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Especifico Estoques Dipromed.                              บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function DIPC53TR(aWork)

Local lRet		   := .T.
Local cEmpOld	   := ""
Local cFilOld	   := ""
Local aArea        := {}
Local QRY1
Local lEmpOrig 	   := .F.            
Local nQuant 	   := 0
Local nQRest	   := 0              
Local cFilSZP 	   := ""
Local cFilSB2 	   := ""
Local lSc9Ok 	   := .F.
Local DtValid 	   := ctod("")                 
Local cOperador    := ""
Local cMsg 		   := ""
Local lCodigo      := .F.
Local nId,mx,i      
Local lxSaldTr     := 1     
Local lJob         := .T.
Local lContinua    := .T.
Local nVlrCM1	   := 0

Private cDipro     := '0104'
Private cHQ        := '0101'          
Private cCusto     := 0            
Private cDocSD3    := ""  
Private cLocalTran := '01'  
Private cFilEmpOrig:= ""  
Private aRegSD3    := {}
Private aCabSD3    := {}
Private aDadosReq  := {}      
Private aRegSDA    := {}                  
Private aDados     := {}
Private aDadosItem := {}
Private aDadDtVa   := {}    
DEFAULT aWork      := {}

If Len(aWork) > 0
	RpcSetEnv(aWork[1],aWork[2],,,'EST',, )
EndIf

cFilSZP     := xFilial("SZP")
cFilSB2     := xFilial("SB2")
cEmpOld	    := cEmpAnt
cFilOld	    := cFilAnt
aArea       := GetArea()
cFilEmpOrig := If(cEmpAnt+cFilAnt == '0104','1','2')

ConOut( dtoc( Date() )+" "+Time()+" Iniciando o job DIPC53TR() - Transfer๊ncia automแtica executada "+If(cFilAnt=='01',"na MATRIZ","no CD") +" ...!")

cChave := "TRANSFERINDO..."
If LockByName(cChave,.T.,.F.)	
                                                                                       
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤlฟ
//ณVerifica se existem produtos para transferir
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤlู                 
	Begin Transaction
	Begin Sequence

		If !fQuery()       
	   		ConOut( dtoc( Date() )+" "+Time()+" Nao encontrado dados que satisfacam aos parametros informados para transfer๊ncia!...." )  
		    If Select("TRB") > 0  
	   			TRB->( DbCloseArea() )
			EndIf
			lContinua := .F.
		EndIf    

		If lContinua
			For nId := 1 to Len(aDados)
					
				// Buscando Endere็o com mair quantidade para fazer a transfer๊ncia
				If Select("QRY1") > 0
					QRY1->( DbCloseArea() )
				EndIf
				
				If !Empty(Alltrim(aDados[nId][07]))
				
					BeginSql Alias "QRY1"
			
						Select BF_PRODUTO, BF_LOCALIZ,  B2_LOCALIZ, BF_LOTECTL,BF_QUANT, BF_LOCAL, BF_EMPENHO,  BF_QUANT - BF_EMPENHO AS SALDO 
						From %Table:SBF% SBF
			
						Inner Join %Table:SB2% SB2 on B2_FILIAL = %xFilial:SB2%
						and B2_LOCAL = BF_LOCAL
						and B2_COD     =  BF_PRODUTO
						and SB2.%notdel%
				
						Where BF_FILIAL       = %xFilial:SBF%
						and BF_PRODUTO   = %Exp:aDados[nId][02]%
						and BF_FILIAL          = %xFilial:SBF%
						and BF_LOCAL           = %Exp:cLocalTran%
						and BF_LOTECTL     = %Exp:aDados[nId][07]%
						and BF_LOCALIZ     = %Exp:aDados[nId][08]%
						and BF_QUANT-BF_EMPENHO >= %Exp:aDados[nId][06]%
						and BF_QUANT-BF_EMPENHO > 0 
						and SBF.%notdel%
			
						Order By B2_LOCALIZ, SALDO DESC, BF_LOCALIZ, BF_LOTECTL
			
					EndSql
		
				Else
		
					BeginSql Alias "QRY1"
			    	
	  					Select 
							ISNULL(B2_LOCALIZ,'99.99.99'), B8_DTVALID, BF_PRODUTO, BF_LOCALIZ,  B2_LOCALIZ, BF_LOTECTL,BF_QUANT, BF_LOCAL, BF_EMPENHO,  BF_QUANT - BF_EMPENHO AS SALDO
							From 
								%Table:SBF% SBF			
								Left Join 
									%Table:SB2% SB2 
									on 
										B2_FILIAL  = %xFilial:SB2% AND
										B2_LOCAL   = BF_LOCAL AND
										B2_COD     = BF_PRODUTO AND   
										B2_LOCALIZ = BF_LOCALIZ AND
										SB2.%notdel%
								Inner Join 
									%Table:SB8% SB8 
									on 
										B8_FILIAL = BF_FILIAL AND
										B8_PRODUTO = BF_PRODUTO AND
										B8_LOCAL = BF_LOCAL AND
										B8_LOTECTL = BF_LOTECTL AND
										B8_SALDO-B8_EMPENHO > 0 AND
										SB8.%notdel%
								Where 
									BF_FILIAL  = %xFilial:SBF%  AND 
									BF_PRODUTO = %Exp:aDados[nId][02]% AND
									BF_FILIAL  = %xFilial:SBF% AND 
									BF_LOCAL   = %Exp:cLocalTran% AND
									BF_QUANT-BF_EMPENHO > 0 AND
									SBF.%notdel%		
						Order By ISNULL(B2_LOCALIZ,'99.99.99'), B8_DTVALID, RIGHT(RTRIM(BF_LOCALIZ),2), SUBSTRING(BF_LOCALIZ,1,5)
					    	    			
					EndSql
				Endif
			
				DbSelectArea("QRY1")
		
				Do While QRY1->(!Eof()) .And. Val(aDados[nId][06]) > nQuant

					nVlrCM1 := DipRetCM1(QRY1->BF_PRODUTO, QRY1->BF_LOCAL)
				
					nQRest :=Val(aDados[nId][06]) -  nQuant
					nQuant :=  nQuant+if(QRY1->BF_QUANT-QRY1->BF_EMPENHO>nQRest,nQRest,QRY1->BF_QUANT-QRY1->BF_EMPENHO)
					Aadd(aDadosReq,{QRY1->BF_PRODUTO, QRY1->BF_LOCAL, QRY1->BF_LOTECTL, QRY1->BF_LOCALIZ, if(QRY1->BF_QUANT-QRY1->BF_EMPENHO>nQRest,nQRest,QRY1->BF_QUANT-QRY1->BF_EMPENHO), Posicione("SB8",3,xFILIAL("SB8")+QRY1->BF_PRODUTO+QRY1->BF_LOCAL+QRY1->BF_LOTECTL,"B8_DTVALID"),nVlrCM1 })
				
					QRY1->(DbSkip())
				Enddo     
				If Len(aDadosReq) = 0
		  			ConOut( dtoc( Date() )+" "+Time()+" Transfer๊ncia com problema. NรO Hม SALDO SUFICIENTE NO ESTOQUE POR ENDEREวO!...." )  
			  		lxSaldTr := 0
				Endif
			
				nQuant := 0
				dbSelectArea("QRY1")
				QRY1->(dbCloseArea())
			Next nId	     
	
		   	// Verificando data de Validade do Lote
	   		For mx := 1 to Len(aDadosReq)
		   		If aDadosReq[mx][6] <= Date()
					ConOut( dtoc( Date() )+" "+Time()+" Produto Vencido, transfer๊ncia cancelada..." )  
		 			Aadd(aDadDtVa,{AllTrim(aDadosReq[mx][1])})
		 			//lRet := .F.
			   		//Break
			   		Loop
			    Endif
			Next mx
		
			cDocSD3 := "SZP"+GETSX8NUM("SZP","ZP_CODIGO")                                                                                                    //cDocSD3 := "SZP"+SZP->ZP_CODIGO
			
			If lxSaldTr > 0
				//Chama rotina para fazer a requisi็ใo na Empresa correta
				If lRet
					lRet := fGeraSD3("501",lJob)
				EndIf
			
				If lRet
					If cEmpAnt+cFilAnt == '0104'
						GetEmpr(cHQ)
					Else
						GetEmpr(cDipro)
					Endif
				EndIf
			
				If lRet	
					lRet := fGeraSD3("497",lJob)
				EndIf
				If lRet	
					lRet := fEnder53(cDocSD3,lJob)
				EndIf
			
				// Volta para empresa Origem
				If cEmpAnt+cFilAnt == '0104'
					GetEmpr(cHQ)
				Else	
					GetEmpr(cDipro)
				Endif
			Endif
			
			If !lRet 
				If InTransact()
					DisarmTransaction()
				EndIf
					ConOut( dtoc( Date() )+" "+Time()+" Foram encontrados erros na tentativa de Transfer๊ncia! Consulte o log na pasta LOG_TRANSF_AUTO. Processo cancelado!..." ) 			
				Break
			Else			
				SZP->(dbSetOrder(1))
				For i := 1 To Len(aDadosItem)               			
					IF SZP->(DbSeek(cFilSZP+aDadosItem[i][7]))
						If Ascan(aDadDtVa,{|x| x[1] == AllTrim(aDadosItem[i][2])}) == 0
							RecLock("SZP",.F.)
							SZP->ZP_DOC     := cDocSD3    
							SZP->ZP_USERTRA := "SISTEMA"
							SZP->ZP_STATUS  := "2"
							SZP->ZP_DTTRANS := DATE()
							SZP->(MsUnlock())
							SZP->(DbCommit())       
							
							//Atualiza variแveis para enviar CIC.
							cOperador := ""
							cMsg      := ""
							lCodigo   := .F.
							cOperador := SZP->ZP_USERSOL
							cMsg      := SM0->M0_NOME+" - "+SM0->M0_FILIAL+ Chr(13) + Chr(10)+ Chr(13) + Chr(10) + SZP->ZP_USERSOL+ " ,solicita็ใo de  transfer๊ncia  nบ  "+SZP->ZP_CODIGO+" do produto   "+SZP->ZP_PRODUTO +" foi efetuada com sucesso "      
							lCodigo   := .T.
							fCic(cOperador, cMsg, lCodigo,lJob)
						Else
							//Atualiza variแveis para enviar CIC.
							// RBorges - 09/09/2019 - Ajuste para nใo interromper a transfer๊ncia quando hแ produto vencido.
							//Disparar o CIC de produto vencidos - RBorges 09/09/2019. 
							cOperador := ""
							cMsg      := ""
							lCodigo   := .F.
							cOperador := SZP->ZP_USERSOL
							cMsg      := SM0->M0_NOME+" - "+SM0->M0_FILIAL+ Chr(13) + Chr(10)+ Chr(13) + Chr(10) + SZP->ZP_USERSOL+ " ,solicita็ใo de  transfer๊ncia  nบ  "+SZP->ZP_CODIGO+" do produto   "+SZP->ZP_PRODUTO +" nใo efetuada, produto vencido! "      
							lCodigo   := .T.
							fCic(cOperador, cMsg, lCodigo,lJob)
						EndIf		
					Endif
				Next i
				
				If cEmpAnt+cFilAnt != cEmpOld+cFilOld
					GetEmpr(cEmpOld+cFilOld)
				EndIf                                     
				
				ConOut( dtoc( Date() )+" "+Time()+" Transfer๊ncia do Documento nบ "+cDocSD3+" foi efetuada com sucesso." ) 				
			Endif
		EndIf
	End Sequence  				
	End Transaction                                   
	UnLockByName(cChave,.T.,.F.) // Libera Lock    
Else  
	ConOut( dtoc( Date() )+" "+Time()+" A rotina de transfer๊ncia automแtica estแ sendo executada no momento. Tente novamente mais tarde...!" ) 
Endif
RestArea(aArea)   
Return(lRet)  
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDIPA053C  บAutor  ณMicrosiga           บ Data ณ  03/16/16   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function DipRetCM1(cProduto,cLocal)
Local cSQL 		 := ""
Local nVlrCM1    := 0
Local nVlrCM2    := 0
Local nVlrRet    := 0
Local nOpcCus	 := SuperGetMV("ES_OCUSTO",.F.,1) //WAC20190731 - Origem Custo (1=Normal;2=Matriz (Origem);3=Filial (Origem))
DEFAULT cProduto := ""
DEFAULT cLocal   := ""

cSQL := " SELECT "
cSQL += " 	TOP 1 D1_COD COD, ROUND(D1_CUSTO/D1_QUANT,4) VALCUS "
cSQL += " 	FROM "
cSQL +=  		RetSQLName("SD1")
cSQL += " 		WHERE "
cSQL += " 			D1_FILIAL = '01' AND "
cSQL += " 			D1_COD = '"+cProduto+"' AND "
cSQL += " 			D1_QUANT > 0 AND "
cSQL += " 			D1_CUSTO > 0 AND "
cSQL += " 			D1_TIPO = 'N' AND "
cSQL += " 			D_E_L_E_T_ = ' ' "
cSQL += " ORDER BY R_E_C_N_O_ DESC "

cSQL := ChangeQuery(cSQL)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),"QRYTMP1",.T.,.T.)

cSQL := " SELECT "
cSQL += " 	TOP 1 D1_COD COD, ROUND(D1_CUSTO/D1_QUANT,4) VALCUS "
cSQL += " 	FROM "
cSQL +=   		RetSQLName("SD1")
cSQL += " 		WHERE "
cSQL += " 			D1_FILIAL = '04' AND "
cSQL += " 			D1_COD = '"+cProduto+"' AND "
cSQL += " 			D1_QUANT > 0 AND "
cSQL += " 			D1_CUSTO > 0 AND "
cSQL += " 			D_E_L_E_T_ = ' ' "
cSQL += " ORDER BY R_E_C_N_O_ DESC "

cSQL := ChangeQuery(cSQL)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),"QRYTMP2",.T.,.T.)

If !QRYTMP1->(Eof())  //Trata o custo das entradas da filial 01
	nVlrCM1 := QRYTMP1->VALCUS
EndIf                                   
QRYTMP1->(dbCloseArea())

If !QRYTMP2->(Eof()) //Trata o custo das entradas da filial 04
	nVlrCM2 := QRYTMP2->VALCUS
EndIf
QRYTMP2->(dbCloseArea())

//#WAC20190731 (Inicio) - Alterado para considerar custo conforme novo parametro DP_OCUSTO  (Origem dos Custos)
Do case
	Case nOpcCus == 2  //Considerar custo da Matriz
		nVlrRet := nVlrCM1
	Case nOpcCus == 3 //Considerar custo origem Filial
		nVlrRet := nVlrCM2
	OtherWise //Tramite normal (Considera o maior custo "Regra utilizada anteriormente", nใo existindo traz o custo padrao do produto)
		If nVlrCM1>0 .And. nVlrCM1>=nVlrCM2
			nVlrRet := nVlrCM1
		ElseIf nVlrCM2>0
			nVlrRet := nVlrCM2
		EndIf

		If nVlrRet==0 //Caso nao encontre custo nas especifica็๕es acima assume o custo m้dio do produto.
			cSQL := " SELECT "
			cSQL += " 	B2_CM1 VALCUS "
			cSQL += " 	FROM "
			cSQL +=  		RetSQLName("SB2")
			cSQL += " 		WHERE "
			cSQL += " 			B2_FILIAL IN('01','04') AND "
			cSQL += " 			B2_COD = '"+cProduto+"' AND "
			cSQL += " 			B2_LOCAL = '"+cLocal+"' AND "
			cSQL += " 			D_E_L_E_T_ = ' ' "

			cSQL := ChangeQuery(cSQL)
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),"QRYTMP3",.T.,.T.)
			
			While !QRYTMP3->(Eof())    
				If QRYTMP3->VALCUS > nVlrRet
					nVlrRet := QRYTMP3->VALCUS
				EndIf
				QRYTMP3->(dbSkip())
			EndDo 
			QRYTMP3->(dbCloseArea())
		EndIf

Endcase	//#WAC20190731 (Fim)

If nVlrRet==0
	Aviso("Aten็ใo","Nใo foi encontrado o custo do produto ("+cProduto+")",{"Ok"},1)
EndIf

Return nVlrRet

/*
+---------------------------------------------------------------------+
| RBORGES Data: 12/02/2019                                            | 
+---------------------------------------------------------------------+
| FUNวรO: RESPED()                                                    | 
+---------------------------------------------------------------------+
| DESCRIวรO: Verificar se hแ reserva para o produto, para qual o foi  |  
| solicitada a transfer๊ncia.                                         | 
+---------------------------------------------------------------------+
|USO: Transferencia entre filiais Televendas.                         |
+---------------------------------------------------------------------+
*/

Static Function RESPED(_cXPedido,_cXProd)

Local cQRY1   := ""
Local nQtdRes := 0 

cQRY1 := " SELECT C9_PRODUTO, C9_QTDVEN " 
cQRY1 += " FROM "+RetSQLName("SC5")+" SC5, "+RetSqlName('SC9')+" SC9, "
cQRY1 += " WHERE "
cQRY1 += " C5_FILIAL  = '"+xFilial("SC5")+"' AND "
cQRY1 += " C9_FILIAL  = C5_FILIAL AND "
cQRY1 += " C5_NUM     = '"+_cXPedido+"' AND "
cQRY1 += " C5_TIPODIP = '1' AND "
cQRY1 += " C5_TIPO    = 'N' AND "
cQRY1 += " C5_PRENOTA = 'O' AND "
cQRY1 += " C5_NOTA    = ' ' AND "
cQRY1 += " C9_PEDIDO  = C5_NUM AND " 
cQRY1 += " C9_CLIENTE = C5_CLIENTE AND "
cQRY1 += " C9_LOJA    = C5_LOJACLI AND "
cQRY1 += " C9_PRODUTO = '"+_cXProd+"' AND "
cQRY1 += " C9_QTDORI  > 0 AND "
cQRY1 += " SC5.D_E_L_E_T_ = ''     AND "
cQRY1 += " SC9.D_E_L_E_T_ = '' "  

cQRY1 := ChangeQuery(cQRY1)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQRY1),"RESC9",.T.,.T.)

If !RESC9->(Eof())    

	nQtdRes := RESC9->C9_QTDVEN
	
	RESC9->(DbSkip())
		
EndIf

RESC9->(dbCloseArea())

Return(nQtdRes)

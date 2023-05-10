/*                                                     Sao Paulo, 09 Fev 2010
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDipm027() บ Autor ณJailton B Santos-JBSบ Data ณ 09/02/2010  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Faz a entrada das notas fiscais dos clientes no TMS da em- บฑฑ
ฑฑบ          ณ presa Emovere.                                             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ TMS - Dipromed                                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"       

User Function Dipm027()

Local oMarcAll      
Local oDlg     
Local _i       := 0
Local lRet     := .T.
Local aButtons := {}
Local bCancel  := {|| oDlg:End()}
Local bOk      := {|| Processa({||fGrvTMS()},"Gravando NFS no TMS"),oDlg:End()}
Local nTam     := 300	

Private cList
Private oList 
Private oVlrSelec
Private nVlrSelec:= 0       

Private nRadio   := 2
Private lMarcAll := .F.
Private aDados   := {}
Private aSize    := MsAdvSize()
Private aInfo    := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 5, 5 }
Private aObjects := { { 100, 100, .T., .T. } , { 200, 200, .T., .T. } }
Private aPosObj  := MsObjSize( aInfo, aObjects,.T.)
Private lDipM026 := .T.
//
Private cPerg    := Padr("DIPM027A",10)
Private oMarked	 := LoadBitmap(GetResources(),'LBOK')
Private oNoMarked:= LoadBitmap(GetResources(),'LBNO')
Private cMvRemete:= GetMv("MV_DIPM027")
Private cNFa := ""
Private cNFb := ""

Private nCount   := 0

If (Alltrim(GetTheme()) <> "TEMAP10") .AND. !SetMdiChild()
	nTam := 375
EndIf
//
AAdd(aButtons, {"DBG10",{|| fLocaliza() },"Procurar" } )
//          

If !("EMOVERE" $ SM0->M0_NOMECOM)
    Alert("Esta rotina s๓ estแ disponํvel para A Emovere!")
	Return()
Endif

If !(Upper(U_DipUsr()) $ GetMv("ES_DIPM_27",,"MCANUTO/GIO100"))
    Alert("Usuแrio sem autoriza็ใo para executar esta rotina!")
	Return()
End
//-----------------------------------------------------
// Cria o Grupo de Pergunta no SX1 e Questiona usuario                          
//-----------------------------------------------------
fAjustSX1()
If !Pergunte(cPerg, .T.)
    Return(.F.)
EndIf
//-----------------------------------------------------
// Le as informacoes importadas e cria a array de apre-
// sentacao no browse
//-----------------------------------------------------
If !fQuery()       
    Aviso('Aten็ใo','Nao encontrado dados que satisfacam aos parametros informados!',{'Ok'}) 
    If Select("TRB") > 0  
    	TRB->( DbCloseArea() )
	EndIf
    Return(.F.)
EndIf    

Define MsDialog oDlg Title "Enviando Notas para Emovere" From 0,0 To aSize[6]-15,aSize[5]-15 of oMainWnd PIXEL 
                                         
@ 30,000 ListBox oList var cList Fields HEADER "","NRO NF","SERIE","EMISSAO","PEDIDO","CLIENTE","LOJA","NOME","VOLUME","PESO BRUTO","PESO LIQUIDO","VALOR NF","ENDEREวO","BAIRRO","MUNICIPIO","ESTADO","CEP" ;
size aSize[5]-392,aSize[6]-(nTam+80) of oDlg Pixel On DBLCLICK fMarca(oList)

If nCount > 0
	oList:SetArray(aDados)
	oList:bLine := {|| {Iif(aDados[oList:nAT,1],oMarked,oNoMarked),aDados[oList:nAt,2],aDados[oList:nAt,3],aDados[oList:nAt,4],aDados[oList:nAt,5],aDados[oList:nAt,6],aDados[oList:nAt,7],aDados[oList:nAt,8],aDados[oList:nAt,9],aDados[oList:nAt,10],aDados[oList:nAt,11],aDados[oList:nAt,12],aDados[oList:nAt,13],aDados[oList:nAt,14],aDados[oList:nAt,15],aDados[oList:nAt,16],aDados[oList:nAt,17]}}
EndIf

@ aSize[6]-(nTam+40),001 to aSize[6]-320,aSize[5]-680 Of oDlg Pixel
@ aSize[6]-(nTam+38),005 checkbox oMarcAll var lMarcAll PROMPT "Marca Toda a Notas" size 100,008 of oDlg on change fMarcAll(oList)
@ aSize[6]-(nTam+35),270 say 'Total Selecionando em R$ '  Size 70,08 color CLR_HBLUE Of oDlg Pixel
@ aSize[6]-(nTam+37),350 msget oVlrSelec var nVlrSelec  Picture "@ke 9,999,999.99" when .f. size 50,08 of oDlg pixel
 
Activate Dialog oDlg ON INIT EnchoiceBar(oDlg, bOk, bCancel,,aButtons)

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
Static Function fMarca()

Local i := 1 

If Empty(aDados[oList:nAT,1])

    SA1->( DbSetOrder(1) ) 
    SA1->( DbSeek(xFilial('SA1')+aDados[oList:nAT,6]+aDados[oList:nAT,7]))  

    If Empty(SA1->A1_CDRDES)
         Aviso('Aten็ใo','O Codigo da Regiใo no cadastro do Cliente nใo estแ informado. Por favor informe-o e Tente Importar as notas novamente.',{'OK'})
         aDados[oList:nAT,1] := .F.
         return(Nil)
    EndIf

EndIf 
        
aDados[oList:nAT,1] := !aDados[oList:nAT,1]		

If aDados[ oList:nAT, 1 ]
    nVlrSelec +=  Val(StrTran(StrTran(aDados[oList:nAT,12],'.',''),',','.'))
Else
    nVlrSelec -= Val(StrTran(StrTran(aDados[oList:nAT,12],'.',''),',','.'))
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
Static Function fMarcAll()

Local nId
Local cMarcaT := !aDados[oList:nAT,1]
Local lMarcou := .T.	 

nVlrSelec := 0

For nId :=1 to len(aDados)
	
	SA1->( DbSetOrder(1) )
	SA1->( DbSeek(xFilial('SA1')+aDados[nId,6]+aDados[nId,7]))
	
	If lMarcAll .and. Empty(aDados[nId,1]) .and. Empty(SA1->A1_CDRDES)
		aDados[nId,1] := .F.
		lMarcou :=  .F.
	Else
		aDados[nId,1] := lMarcAll
		If lMarcAll
			nVlrSelec += Val(StrTran(StrTran(aDados[nId,12],'.',''),',','.'))
		EndIf
	EndIf
	
Next nId

oList:Refresh()
oVlrSelec:Refresh()

If !lMarcou
     Aviso('Aten็ใo','As Notas nใo marcadas, possuem erro no cadastro do cliente: O codigo da regiใo nใo estแ informado. Estas notas nใo serใo importadas. Entre no cadastro do cliente, informe o codigo da regiใo e volte aqui ..',{'OK'})
EndIf

Return(.T.)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณfQuery()   บAutor ณJailton B Santos-JBSบ Data ณ 09/02/2010  บฑฑ
ฑฑฬออออออออออุอออออออออออสออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc. 1:  ณQuery para trazer as informacoes para gerar as recebimentos บฑฑ
ฑฑบ          ณno TMS da Empresa Emovere (030)                             บฑฑ
ฑฑบ          ณE' Importante observar que esta query ler as tabelas SF2,SD2บฑฑ
ฑฑบ          ณSC5 e SC6 de Outras Empresas que nao e' a empresa atual do  บฑฑ
ฑฑบ          ณSistema, apenas a tabela SA1 e' compartilhada entre empresasบฑฑ
ฑฑบ          ณDetermina-se a empresa das demais tabelas, localizando-se   บฑฑ
ฑฑบ          ณo cliente no SA1, que aqui chamamos de remetente, pegando o บฑฑ
ฑฑบ          ณseu CNPJ no SigaMat (SM0). Uma vez localizado a empresa, te-บฑฑ
ฑฑบ          ณmos a empresa e a filial.                                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณFAT - Dipromed                                              บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function fQuery()     

Local cQuery    := ""              
Local lRet      := .F.
//----------------------------------------------------------------------------------
Local aEmpresa  := fEmpresa()  // Busca o codiga das tabela exclusiva do Remetente
//----------------------------------------------------------------------------------
Local cPicPeso  := AvSx3("F2_PBRUTO" ,6)
Local cPicVolume:= AvSx3("F2_VOLUME1",6)
Local cPicValor := AvSx3("F2_VALBRUT",6)
//----------------------------------------------------------------------------------
cQuery := " SELECT DISTINCT SF2.F2_FILIAL, "
cQuery += "                 SF2.F2_CLIENTE, "
cQuery += "                 SF2.F2_LOJA, "
cQuery += "                 SF2.F2_DOC, "
cQuery += "                 SF2.F2_SERIE, "
cQuery += "                 SF2.F2_EMISSAO, "
cQuery += "                 SD2.D2_PEDIDO, "
cQuery += "                 SF2.F2_VOLUME1, "
cQuery += "                 SF2.F2_PBRUTO, " 
cQuery += "                 SF2.F2_PLIQUI, "
cQuery += "                 SF2.F2_VALBRUT, "
cQuery += "                 SA1.A1_NREDUZ, " 
cQuery += "                 SA1.A1_ENDENT, "
cQuery += "                 SA1.A1_BAIRROE, "
cQuery += "                 SA1.A1_MUNE, "
cQuery += "                 SA1.A1_ESTE, "
cQuery += "                 SC5.C5_ENDENT, "
cQuery += "                 SC5.C5_BAIRROE, "
cQuery += "                 SC5.C5_MUNE, "
cQuery += "                 SC5.C5_ESTE, "
cQuery += "                 SC5.C5_CEPE, " 
cQuery += "                 SC5.C5_TPFRETE, " 
cQuery += "                 SF2.R_E_C_N_O_, "
cQuery += "                 SF2.F2_CHVNFE "
//----------------------------------------------------------------------------------
cQuery += "   FROM SF2"+aEmpresa[1][1]+" SF2 "
//----------------------------------------------------------------------------------
cQuery += "  INNER JOIN SD2" + aEmpresa[1][1]    + " SD2 ON D2_FILIAL = '" + aEmpresa[1][2] +"' AND D2_DOC = F2_DOC     AND D2_SERIE = F2_SERIE AND SD2.D_E_L_E_T_ <> '*' "
cQuery += "  INNER JOIN SC5" + aEmpresa[1][1]    + " SC5 ON C5_FILIAL = '" + aEmpresa[1][2] +"' AND C5_NUM = D2_PEDIDO  AND SC5.D_E_L_E_T_ <> '*' "
cQuery += "  INNER JOIN SA1" + aEmpresa[1][1]    + " SA1 ON A1_FILIAL = ' ' AND A1_COD = F2_CLIENTE AND A1_LOJA = F2_LOJA AND SA1.D_E_L_E_T_ <> '*' "
//----------------------------------------------------------------------------------
cQuery += "  WHERE F2_FILIAL = '" + aEmpresa[1][2] + "' " 
cQuery += "    AND F2_VOLUME1 > 0 "
cQuery += "    AND F2_TRANSP = '100000' "

cQuery += "    AND F2_CHVNFE > ' ' "

cQuery += "    AND F2_EMISSAO BETWEEN '" + dTos(MV_PAR03) + "' AND '" + dTos(MV_PAR04) + "' "
cQuery += "    AND F2_DOC BETWEEN '" + MV_PAR05 + "' AND '" + MV_PAR06 + "' " 
cQuery += "    AND F2_SERIE = '" + MV_PAR07 +"' "
//-------------------------------------------------------[ JBS 18/02/2010 ]---------
// Este complemento de query, so permite trazer notas que ainda nao existam no TMS
//----------------------------------------------------------------------------------
cQuery += "    AND '" + MV_PAR01 + MV_PAR02 + "' + F2_DOC + F2_SERIE + F2_CLIENTE + F2_LOJA NOT IN ( SELECT DTC_CLIREM+DTC_LOJREM+DTC_NUMNFC+DTC_SERNFC+DTC_CLIDES+DTC_LOJDES
cQuery += "                                                                                            FROM "    + RetSQLName("DTC") + " DTC "
cQuery += "                                                                                           WHERE DTC_FILIAL = '" + xFilial('DTC') + "' "
cQuery += "                                                                                             AND DTC.D_E_L_E_T_ <> '*'  )  " 
//----------------------------------------------------------------------------------
cQuery += "    AND SF2.D_E_L_E_T_ <> '*' "   
//Giovani Zago 26/01/2012 nใo seleciona notas de fornecedores 
cQuery += "    AND F2_TIPO NOT IN ('B','D')  "
//----------------------------------------------------------------------------------
If Type("mv_par08") != "N" .Or. mv_par08 == 1
	cQuery += "  ORDER BY F2_CLIENTE, F2_LOJA  "
ElseIf mv_par08 == 2
	cQuery += "  ORDER BY F2_DOC, F2_SERIE"
EndIf
//----------------------------------------------------------------------------------
If Select("TRB") > 0
    TRB->( DbCloseArea() )
EndIf    
//----------------------------------------------------------------------------------
DbCommitAll()
TCQUERY cQuery NEW ALIAS "TRB" 
//----------------------------------------------------------------------------------
TCSETFIELD("TRB","F2_EMISSAO" , "D" , 08 , 00)
TCSETFIELD("TRB","F2_VOLUME1" , "N" , 14 , 02)
TCSETFIELD("TRB","F2_VALBRUT" , "N" , 05 , 02)
TCSETFIELD("TRB","F2_PBRUTO"  , "N" , 14 , 04)
TCSETFIELD("TRB","F2_PLIQUI"  , "N" , 14 , 04)
//----------------------------------------------------------------------------------
aDados := {} // Limpa a array de exibicao do browse 
//----------------------------------------------------------------------------------
lRet := !TRB->( BOF().and.EOF() )                
//----------------------------------------------------------------------------------
// Monta as colunas do Browse no array aDados com as 
// Informacoes lidas pela Query.                      
//----------------------------------------------------------------------------------
TRB->( DbGoTop() ) 

Do While TRB->( !EOF() )

	If DipNFLic(TRB->F2_DOC,TRB->F2_SERIE,TRB->F2_CLIENTE,TRB->F2_LOJA)
		TRB->(AADD(aDados,{.F.,;          // Marca / Desmarca    						1
		                    F2_DOC,;       // Numero da Nota Fiscal                     2
		                    F2_SERIE,;     // Serie da Nota Fiscal                      3
		                    F2_EMISSAO,;   // Data de Emissao                           4
		                    D2_PEDIDO,;    // Numero do Pedido                          5
		                    F2_CLIENTE,;   // Codigo do Cliente                         6
		                    F2_LOJA,;      // Codigo da Loja                            7
		                    A1_NREDUZ,;    // Nome Reduzido do Cliente                  8
		                    Transform( F2_VOLUME1,cPicVolume ),;  // Quant de Volume    9
		                    Transform( F2_PBRUTO ,cPicPeso   ),;  // Peso Bruto        10
	                        Transform( F2_PLIQUI ,cPicPeso   ),;  // Peso Liquido      11
		                    Transform( F2_VALBRUT,cPicValor  ),;   // Valor Bruto      12
		                    C5_ENDENT,;   // Endereco de Entrega                       13
		                    C5_BAIRROE,;  // Bairro de entrega                         14
		                    C5_MUNE,;     // Municipio de entrega                      15
		                    C5_ESTE,;     // Estado de entrega                         16
		                    C5_CEPE,;     // Cep Entrega                               17
		                    R_E_C_N_O_ }))// Numero do Registro do SF2 para fazer ajuste na registro   18
		nCount++
	EndIf
	
    TRB->( DbSkip() )      
    
EndDo          

//RBOrges - 14/10/2013 - Carrega as notas que nใo irใo gerar Cte.
//Depois envia CIC e E-mail para os interessados.
If cNFa <> "" 
	CDipm27a()//cic
	EDipm27a()//e-mail 
EndIf

//RBOrges - 14/10/2013 - Carrega as notas que irใo gerar Cte.
//Depois envia CIC e E-mail para os interessados.	
If cNFb <> "" 
  	CDipm27b()//cic
	EDipm27b()//e-mail 
EndIf	

Return(lRet)   
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณfGrvTMS() บ Autor ณJailton B Santos-JBSบ Data ณ 12/02/2010  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Pega todas as notas que o usuario marcou, e faz suas res-  บฑฑ
ฑฑบ          ณ pectivas entradas no recebimento do TMS.                   บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Especifico - TMS - Dipromed                                บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function fGrvTMS()

Local cLotNfc := ""
Local nId     := 01
Local nTotNota:= 00   // Contador de Notas fiscais geradas
Local nTotMarc:= 00   // Contador de CTRCs marcados 
Local nTotItem:= 00   // Total de Itens em uma nota, usado para estornar do contador de notas quando uma nota nao eh gravada.
Local aCab    := {}
Local aCabDTC := {}
Local aItem   := {}
Local xAlias  := GetArea() 

//-- CTE - Local
Local lTMSCTe 		:= SuperGetMv( "MV_TMSCTE", .F., .F. )		//-- Parametro do CT-e ativo.
Local nViasDacte	:= SuperGetMv( "ES_NDACTE",, 0 )		//-- numero de Vias do Dacte 
Local cCTEStatus 	:= " "
Local _lNFENTR		:= DTC->(FieldPos("DTC_NFENTR")) > 0
Local _lCF  		:= DTC->(FieldPos("DTC_CF")) > 0
Local _lNfeID		:= DTC->(FieldPos("DTC_NFEID")) > 0
Local cAliasQry     := GetNextAlias()
Local _aDocCte		:= {}
Local aEmpresa      := fEmpresa()  // Busca o codiga das tabela exclusiva do Remetente
Local nI,nJ

Local cRet          := ""   // Numero do Lote Retornado pela Funcao de criacao do lote automatica.
             
Private lMsHelpAuto := .T.
Private lMsErroAuto := .F.
 
//-- CTE - Private
Private cCadastro   := 'Calculo de Frete'
Private lTmsCFec    := TmsCFec()
         
//Giovani Zago 30/03/2012  ajuste para nao aglutinar clientes iguais e endere็os diferentes.
aDados:=ValidGrvTms(aDados)

//******************************************************************************

//----------------------------------------------- ----------------------------------------
// Conta Quantidade de Notas Marcadas pelo usuario
//---------------------------------------------------------------------------------------
aEval(aDados,{|x| If(x[1],nTotMarc++,)}) // Contar CTRCs marcados
//---------------------------------------------------------------------------------------
// Inclusao do Lote
//---------------------------------------------------------------------------------------
Aadd(aCab,{'DTP_FILORI',  cFilAnt   ,NIL})
Aadd(aCab,{'DTP_QTDLOT',  nTotMarc  ,NIL})
Aadd(aCab,{'DTP_QTDDIG',  0         ,NIL})
If DTP->(FieldPos('DTP_TIPLOT')) > 0
	Aadd(aCab,{'DTP_TIPLOT',Iif(lTMSCTe,"3","1") ,NIL})
EndIf
Aadd(aCab,{'DTP_STATUS', '1'        ,NIL})  // Status 1 Em aberto

ProcRegua(nTotMarc) 

//Begin Transaction

//---------------------------------------------------------------------------------------
// Cria o Lote
//---------------------------------------------------------------------------------------
MsExecAuto({|x,y| cRet := TmsA170(x,y)},aCab,3)
If lMsErroAuto
	MostraErro()
	//DisarmTransaction()
	Return(.F.)
Else
	cLotNfc := cRet
EndIf
//--------------------------------------------------------------------------------------- 
// Necessario deixar o indice do SB1 na order (1) para executar os gatilhos corretamente.
//---------------------------------------------------------------------------------------
SB1->( DbSetOrder(1) )    // B1_FILIAL+B1_COD
DTC->( DbSetOrder(1) )    // DTC_FILIAL+DTC_FILORI+DTC_LOTNFC+DTC_CLIREM+DTC_LOJREM+DTC_CLIDES+DTC_LOJDES+DTC_SERVIC+DTC_CODPRO+DTC_NUMNFC+DTC_SERNFC
TRB->( DbGoTop() )

Do While TRB->(!Eof())
    //---------------------------------------------------------------------------------------
    // Pula as notas nao marcadas pelo usuario
    //---------------------------------------------------------------------------------------
    
    nId := aScan(aDados,{|x| x[2]+x[3]+x[6]+x[7] == TRB->(F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA)})
    
    If nId==0 .Or. !aDados[nId][01]
		TRB->(DbSkip())
		Loop
	EndIf 
	//---------------------------------------------------------------------------------------
	// Inclusao do Documento do Cliente
	//---------------------------------------------------------------------------------------
	Begin Sequence

	aItemDTC    := {}
	lMsErroAuto := .F.
	
	SA1->( DbSetOrder(1) )
	SA1->( DbSeek(xFilial('SA1') + aDados[nId][06] + aDados[nId][07]) )
	
	If MV_PAR01=='000804'       
		If TRB->C5_TPFRETE=='I'
			cCDRDES := '000002' // GRANDE SรO PAULO (Ambas filiais)
		ElseIf MV_PAR02=='01'
			cCDRDES := '000005' // GRANDE SรO PAULO (MTZ)
		Else                   
			cCDRDES := '000004' // GRANDE SรO PAULO (CD) // ANTIGO '000005' 15/10/2019 - MCANUTO
		EndIf                    
	ElseIf MV_PAR01  = '011050
		cCDRDES := '000006'     // GRANDE SรO PAULO (HQ)
	Else
		cCDRDES := SA1->A1_CDRDES
	EndIf
	
	aCabDTC := { {"DTC_FILORI" , cFilAnt          , Nil},;
	             {"DTC_LOTNFC" , cLotNfc          , Nil},;
	             {"DTC_CLIREM" , MV_PAR01         , Nil},;
	             {"DTC_LOJREM" , MV_PAR02         , Nil},;
	             {"DTC_CLIDES" , aDados[nId][06]  , Nil},;
	             {"DTC_LOJDES" , aDados[nId][07]  , Nil},;
	             {"DTC_CLIDEV" , MV_PAR01         , Nil},;
	             {"DTC_LOJDEV" , MV_PAR02         , Nil},;
	             {"DTC_CLICAL" , MV_PAR01         , Nil},;
	             {"DTC_LOJCAL" , MV_PAR02         , Nil},;
	             {"DTC_DEVFRE" , "1"              , Nil},;
	             {"DTC_SERTMS" , "3"              , Nil},;
	             {"DTC_TIPTRA" , "1"              , Nil},;
	             {"DTC_SERVIC" , "C01"            , Nil},;
	             {"DTC_TIPNFC" , "0"              , Nil},;
	             {"DTC_TIPFRE" , "1"              , Nil},;
	             {"DTC_SELORI" , IIf(MV_PAR01=="000804","1","2"), Nil},;  								// {"DTC_SELORI" , "1", Nil},; //Rafael Lopes - Ajuste DTC_SELORI   
	             {"DTC_CDRORI" , IIf(MV_PAR01=="000804",SuperGetMv("MV_CDRORI",,""),"000007"), Nil},;   // {"DTC_CDRORI" , SuperGetMv("MV_CDRORI",,""), Nil},;
	             {"DTC_CDRDES" , cCDRDES   		  , Nil},;
	             {"DTC_CDRCAL" , cCDRDES   		  , Nil},;
	             {"DTC_DISTIV" , "2"              , Nil},;
	             {"DTC_CDRCAL" , cCDRDES   		  , Nil},;
	             {"DTC_DISTIV" , "2"              , Nil},;
	             {"DTC_CODNEG" , '01'             , Nil},;
	             {"DTC_NCONTR" , IIf(MV_PAR01=="000804","000000000000014","000000000000017"), Nil},;
	             {"DTC_DOCTMS" , '2'			  , Nil},;
	             {"DTC_OBS"    , DIP27Obs(aEmpresa[1][1],TRB->F2_FILIAL,TRB->D2_PEDIDO),Nil}}
                 // {"DTC_NUMCTL" , PAR->PAR_NUMCTL   , Nil},;
                 // {"DTC_KM"     , PAR->PAR_KM       , Nil},;   
    nTotItem:= 00
	cEndEnt := ""
	Do While TRB->(!EOF()) .And. Len(aDados) >= nId .And. TRB->F2_CLIENTE == aDados[nId][06] .And. TRB->F2_LOJA == aDados[nId][07] ;
			.And. Len(aItemDTC) < SuperGetMv("ES_NFXCTC",,1);
			.And. (Len(aItemDTC) == 0 .Or. cEndEnt == TRB->C5_ENDENT)
				
		If aDados[nId][01]

		   IncProc()
			
			aItem  := {{"DTC_FILORI" , cFilAnt          , Nil},;
		               {"DTC_LOTNFC" , cLotNfc          , Nil},;
		 			   {"DTC_NUMNFC" , aDados[nId][02] , Nil},;   // 01-Numero da Nota Fiscal
			           {"DTC_SERNFC" , aDados[nId][03] , Nil},;   // 02-Serie da Nota Fiscal
			           {"DTC_CODPRO" ,'FRETE'          , Nil},;   // 03-Codigo do Produto
			           {"DTC_CODEMB" ,'CX'             , Nil},;   // 04-Codigo da Embalagem
			           {"DTC_EMINFC" ,aDados[nId][04]  , Nil},;   // 05-Data de Emissao
			           {"DTC_QTDVOL" ,TRB->F2_VOLUME1  , Nil},;   // 06-Quantidade de Vomlumes
			           {"DTC_PESO"   ,TRB->F2_PBRUTO   , Nil},;   // 07-Peso Bruto
			           {"DTC_PESOM3" ,0                , Nil},;   // 08-Peso Cubado
			           {"DTC_VALOR"  ,TRB->F2_VALBRUT  , Nil},;   // 09-Valor
			           {"DTC_EDI"    ,"2"              , Nil}}    // 10-EDI
			If _lNFENTR
				aAdd(aItem,{"DTC_NFENTR" ,"2"          , Nil} )   // Status do Doc cliente
			EndIf
			If _lCF
				aAdd(aItem,{"DTC_CF" ,DIP27CFOP(aEmpresa[1][1],TRB->F2_FILIAL,TRB->F2_DOC,TRB->F2_SERIE)    , Nil} )   // CFOP Principal da NF
			EndIf
			If _lNfeID
				aAdd(aItem,{"DTC_NFEID" ,TRB->F2_CHVNFE         , Nil} )   // Chave da NF-e
			EndIf
			
			Aadd(aItemDTC,aClone(aItem))
	
			cEndEnt := TRB->C5_ENDENT                             	

			nTotItem++
	        nTotNota++ 
		EndIf
		
		TRB->( DbSkip() ) 
		
		nId ++
        
	EndDo
	// Parametros da TMSA050 (notas fiscais do cliente)
	// xAutoCab - Cabecalho da nota fiscal
	// xAutoItens - Itens da nota fiscal
	// xItensPesM3 - acols de Peso Cubado
	// xItensEnder - acols de Enderecamento
	// nOpcAuto - Opcao rotina automatica
	MsExecAuto({|u,v,x,y,z| TMSA050(u,v,x,y,z)},aCabDTC,aItemDTC,,,3)
	//
	If lMsErroAuto
		MostraErro()
		nTotNota -=	nTotItem // Estorna as notas nao enviadas
		Break
	EndIf

    End Sequence
		
EndDo 
 
lMsHelpAuto:=.f. 

If nTotNota > 0
    //--------------------------------------------------------------------------------
    // Iguala a quantidade de notas do lote, com a quantidade processada.                                     
    //--------------------------------------------------------------------------------
    If nTotNota < nTotMarc  
        DTP->( DbSetOrder(1) ) 
        If DTP->( DbSeek(xFilial('DTP') + cLotNfc) )
            DTP->( RecLock('DTP',.f.) ) 
            DTP->DTP_QTDLOT := nTotNota   // Ajusta a quantidade do lote para o total realmente enviado.
            DTP->DTP_STATUS := '2'        // Ajusta o Status para Digitado.
            DTP->( MsUnLock('DTP') ) 
        EndIf
    EndIf
    DbCommitAll()
    //--------------------------------------------------------------------------------
    // Calcula o Lote, Gerando CTRC's e Transmite-os a Sefaz                                     
    //--------------------------------------------------------------------------------
   	SetFunName("TMSA200")
	DTP->( DbSetOrder(1) )  
	_aDocCte := {}
	If DTP->( DbSeek(xFilial('DTP') + cLotNfc) )
		If TMSA200Prc(cFilAnt,cLotNFC)
			cCTEStatus := ' '
			If lTMSCTe 
				TMSAE70(1,cFilAnt,cLotNFC)
				DT6->(dbCommit())
				//-- 1 Doc Aguardando			
				//-- 0 Nao Transmitido
				//-- 3 Doc Nao Autorizado
				//-- 2 Doc Autorizado
				//-- 5 Doc com Falha na Comunicacao
				cQuery := "SELECT DT6_FILDOC, DT6_DOC, DT6_SERIE, DT6_DOCTMS, DT6_SITCTE"
				cQuery += " FROM " + RetSqlName("DT6")
				cQuery += " WHERE DT6_FILIAL = '"+xFilial('DT6')+"'"
				cQuery += "   AND DT6_FILORI = '"+cFilAnt+"'"
				cQuery += "   AND DT6_LOTNFC = '"+cLotNFC+"'"
				cQuery += "   AND D_E_L_E_T_ = ' '"
				dbUseArea( .T., "TOPCONN", TCGenQry(,,cQuery), cAliasQry, .T., .T. )     
				While (cAliasQry)->(!Eof())
					(cAliasQry)->(aAdd(_aDocCte,{DT6_DOC,DT6_SERIE,DT6_DOCTMS}))
					If (cAliasQry)->DT6_SITCTE == '2' .And. (Empty(cCTEStatus) .Or. cCTEStatus == '5')
						cCTEStatus := '5' //-- CT-e Autorizado
					Else					
						cCTEStatus := '4' //-- CT-e Transmitido
					EndIf                         
					(cAliasQry)->(dbSkip())
				EndDo
				(cAliasQry)->(dbCloseArea())				
			EndIf			
		EndIf
    EndIf
    SetFunName("DIPM027")

    If nTotNota < nTotMarc  
        MsgAlert("Ocorreram problemas em algumas das notas fiscais marcadas. As demais foram processadas normalmente.","Aten็ใo")
    EndIf
	If Empty(cCTEStatus)    
	    Aviso('Processo Concluido',StrZero(nTotNota,4)+" de "+StrZero(nTotMarc,4)+" Notas Fiscais enviadas para a Emovere e foram calculados os CTRC's" ,{'OK'})
	ElseIf cCTEStatus == '4'    
	    MsgAlert("Aten็ใo",'Processo Concluido',StrZero(nTotNota,4)+" de "+StrZero(nTotMarc,4)+" Notas Fiscais enviadas para a Emovere e foram transmitidos os CTE's - Verificar Autoriza็ใo")
	ElseIf cCTEStatus == '5'    
	    Aviso('Processo Concluido',StrZero(nTotNota,4)+" de "+StrZero(nTotMarc,4)+" Notas Fiscais enviadas para a Emovere e foram transmitidos e autorizados os CTE's" ,{'OK'})
	EndIf

	//-- 27/10/2011 - D'Leme: Impressใo do Dacte
	If cCTEStatus == '5'
		SaveInter()
		Pergunte('RTMSR27',.F.)
		DTP->( DbSetOrder(1) ) 
		If DTP->( MsSeek(xFilial('DTP') + cLotNfc) )
			If Empty(SuperGetMv("ES_DACTPRN",,"")) .Or. nViasDacte <= 1
				mv_par01 := cLotNfc 
				mv_par02 := cLotNfc 
				mv_par03 := Repl(' ',Len(DT6->DT6_DOC))
				mv_par04 := Repl('z',Len(DT6->DT6_DOC))
				mv_par05 := Repl(' ',Len(DT6->DT6_SERIE))
				mv_par06 := Repl('z',Len(DT6->DT6_SERIE))
				mv_par07 := "2"

				U_RTMSR27B()
			Else
				For nI := 1 To Len(_aDocCte)
					mv_par01 := cLotNfc 
					mv_par02 := cLotNfc 
					mv_par03 := _aDocCte[nI][1]
					mv_par04 := _aDocCte[nI][1]
					mv_par05 := _aDocCte[nI][2]
					mv_par06 := _aDocCte[nI][2]
					mv_par07 := _aDocCte[nI][3]
					
					For nJ := 1 To Max(1,nViasDacte)
						U_RTMSR27B()
					Next nJ
				Next nI
			EndIf
		EndIf
		RestInter()
	EndIf
Else
     Aviso('Aten็ใo','Nใo foram enviadas Notas Fiscais para Emovere.',{'OK'})
EndIf

//End Transaction 

TRB->( DbCloseArea() )
RestArea(xAlias)

Return( nTotNota > 0)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณfLocaliza()บAutor ณJailton B Santos-JBSบ Data ณ 30/12/2009  บฑฑ
ฑฑฬออออออออออุอออออออออออสออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao desenvolvida para localizar uma nota fiscal entre as บฑฑ
ฑฑบ          ณnotas fiscais listadas para o usuario.                      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณEspecifico TMS - Dipromed                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function fLocaliza()

Local oDlg          
Local oNroNF   
Local nOpc    := 0    
Local nPos    := 0
Local lRet    := .T. 
Local bCancel := {|| nOpc:=1,oDlg:End()}
Local bOk     := {|| nOpc:=2,oDlg:End()}

Private cNroNF := Space(len(SF2->F2_DOC))

Define MsDialog oDlg Title "Procurando Nota" from 0,0 to 150,250 of oMainWnd pixel  

@ 002,003 to 040,125 Of oDlg Pixel
@ 15,005 say "Numero da Nota"   size 70,08 of oDlg pixel
@ 15,070 msget oNroNF  var cNroNF size 50,08 of oDlg pixel

@ 55,040 Button OemToAnsi("Procurar") size 40,15 pixel of oDlg action eval(bOk)
@ 55,085 Button OemToAnsi("Fechar")   size 40,15 pixel of oDlg action eval(bCancel)

Activate MsDialog oDlg Centered

If nOpc == 2
	If Empty(cNroNF)
		oList:nAt := 1   // Posiciona no primeiro CTRC da Tela
		oList:Refresh()
	ElseIf ( nPos := Ascan(aDados,{|x| SubStr(x[2],1,len(AllTrim(cNroNF))) == AllTrim(cNroNF)})) > 0
		oList:nAt := nPos // Posciona no CTRC informado pelo usuario
		oList:Refresh()
	Else
		Aviso('Aten็ใo','Nota nใo encontrada na listagem',{'Ok'})
		lRet := .F.
	EndIf
EndIf

Return(lRet)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณfEmpresa()บ Autor ณJailton B Santos-JBSบ Data ณ 12/02/2010  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Esta funcao verifica se um determinado cliente faz para do บฑฑ
ฑฑบ          ณ sigamat da empresa, esta cadastrado como empresa no sigamatบฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Especifico - TMS - Dipromed                                บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function fEmpresa() 

Local aEmpresa := {} 
Local cCodEmp := ""
Local nRecSMO := SM0->( Recno() )

SA1->(DbSetOrder(1))
SA1->(DbSeek(xFilial('SA1') + MV_PAR01 + MV_PAR02))

SM0->( DbGoTop() )
Do While SM0->( !EOF() )
	
	If AllTrim(SM0->M0_CGC) == AllTrim(SA1->A1_CGC)
		aadd(aEmpresa,{SM0->M0_CODIGO + "0",SM0->M0_CODFIL })
		Exit
	ElseIf MV_PAR01+MV_PAR02 == '01105004' .And. SM0->M0_CODIGO+SM0->M0_CODFIL == '0404'   
		aadd(aEmpresa,{SM0->M0_CODIGO + "0",SM0->M0_CODFIL })   
		Exit
	EndIf
	
	SM0->( Dbskip() ) 
	
EndDo	    

SM0->(DbGoTo(nRecSMO)) 

Return(aEmpresa)       
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณfAjustSX1()บAutor ณJailton B Santos-JBSบ Data ณ 12/02/2010  บฑฑ
ฑฑฬออออออออออุอออออออออออสออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Cria o Grupo de Perguntas no SX1                           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ FAT - Dipromed                                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿                              
*/
Static Function fAjustSX1()

Local nId_SX1
Local aRegs	:= {}
Local aArea := GetArea()
Local lRet  := .T.
                   
AAdd(aRegs,{"01","Codigo do Remetente  ","mv_ch1","C",06,0,0,"G","mv_par01",""                ,""                   ,""                    ,""                   ,"1AS"})
AAdd(aRegs,{"02","Filial do Remetente  ","mv_ch2","C",02,0,0,"G","mv_par02",""                ,""                   ,""                    ,""                   ,"1ASL"})
AAdd(aRegs,{"03","Dt Emissใo Inicial   ","mv_ch3","D",08,0,0,"G","mv_par03",""                ,""                   ,""                    ,""                   ,""})
AAdd(aRegs,{"04","Dt Emissใo Final     ","mv_ch4","D",08,0,0,"G","mv_par04",""                ,""                   ,""                    ,""                   ,""})
AAdd(aRegs,{"05","Nota Inicial         ","mv_ch5","C",09,0,0,"G","mv_par05",""                ,""                   ,""                    ,""                   ,""})
AAdd(aRegs,{"06","Nota Final           ","mv_ch6","C",09,0,0,"G","mv_par06",""                ,""                   ,""                    ,""                   ,""})
AAdd(aRegs,{"07","Serie                ","mv_ch7","C",03,0,0,"G","mv_par07",""                ,""                   ,""                    ,""                   ,""})
/*
AAdd(aRegs,{"08","Servi็o de Transporte","mv_ch8","C",01,0,0,"G","mv_par08",""                ,""                   ,""                    ,""                   ,"DLH"}) // DTC_SERTMS
AAdd(aRegs,{"09","Tipo de Transporte   ","mv_ch9","C",01,0,0,"G","mv_par09",""                ,""                   ,""                    ,""                   ,"DLG"}) // DTC_TIPTRA
AAdd(aRegs,{"10","Servi็o              ","mv_chA","C",03,0,0,"G","mv_par10",""                ,""                   ,""                    ,""                   ,""})    // DTC_SERVIC
AAdd(aRegs,{"11","Tipo de NF do Cliente","mv_chB","C",01,0,4,"C","mv_par11","0=Normal"        ,"1=Devolucao"        ,"2=SubContratacao"    ,"3=Docto Nao Fiscal" ,""})    // DTC_TIPNFC
AAdd(aRegs,{"12","Tipo de Frete        ","mv_chC","C",01,0,2,"C","mv_par12","1=CIF"           ,"2=FOB"              ,""                    ,                     ,""})    // DTC_TIPFRE
AAdd(aRegs,{"13","Seleciona Origem     ","mv_chD","C",01,0,4,"C","mv_par13","1=Transportadora","2=Cliente Remetente","3=Lugar Recoleccion" ,""                   ,""})    // DTC_SELORI
AAdd(aRegs,{"14","Distancia Ida/Volta  ","mv_chE","C",01,0,2,"C","mv_par14","1=Sim"           ,"2=Nao"              ,""                    ,                     ,""})    // DTC_DISTIV
AAdd(aRegs,{"15","Devedor do Frete     ","mv_chF","C",01,0,4,"C","mv_par14","1=Remetente"     ,"2=Destinatario"     ,"3=Consignatario"     ,"4=Despachante"      ,""})    // DTC_DEVFRE 
*/


oFWSX1 := FWSX1Util():New()
oFWSX1:AddGroup(ALLTRIM(cPerg))
oFWSX1:SearchGroup()
aPergunte := oFWSX1:GetGroup(ALLTRIM(cPerg))

IF Empty(aPergunte[2])

	For nId_SX1:=1 to Len(aRegs)

		Begin Transaction
			cExec	:=	"INSERT INTO "+MPSysSqlName("SX1")+ " " + CRLF
			cExec	+=	"(	X1_GRUPO, " + CRLF
			cExec	+=	"	X1_ORDEM, " + CRLF
			cExec	+=	"	X1_PERGUNT, " + CRLF
				cExec	+=	"	X1_PERSPA, " + CRLF
				cExec	+=	"	X1_PERENG, " + CRLF
			cExec	+=	"	X1_VARIAVL, " + CRLF
			cExec	+=	"	X1_TIPO, " + CRLF
			cExec	+=	"	X1_TAMANHO, " + CRLF
			cExec	+=	"	X1_DECIMAL, " + CRLF
			cExec	+=	"	X1_PRESEL, " + CRLF
			cExec	+=	"	X1_GSC, " + CRLF
				cExec	+=	"	X1_VALID, " + CRLF
			cExec	+=	"	X1_VAR01, " + CRLF
				cExec	+=	"	X1_DEF01, " + CRLF
				cExec	+=	"	X1_DEFSPA1, " + CRLF
				cExec	+=	"	X1_DEFENG1, " + CRLF
				cExec	+=	"	X1_CNT01, " + CRLF
				cExec	+=	"	X1_VAR02, " + CRLF
				cExec	+=	"	X1_DEF02, " + CRLF
				cExec	+=	"	X1_DEFSPA2, " + CRLF
				cExec	+=	"	X1_DEFENG2, " + CRLF
				cExec	+=	"	X1_CNT02, " + CRLF
				cExec	+=	"	X1_VAR03, " + CRLF
				cExec	+=	"	X1_DEF03, " + CRLF
				cExec	+=	"	X1_DEFSPA3, " + CRLF
				cExec	+=	"	X1_DEFENG3, " + CRLF
				cExec	+=	"	X1_CNT03, " + CRLF
				cExec	+=	"	X1_VAR04, " + CRLF
				cExec	+=	"	X1_DEF04, " + CRLF
				cExec	+=	"	X1_DEFSPA4, " + CRLF
				cExec	+=	"	X1_DEFENG4, " + CRLF
				cExec	+=	"	X1_CNT04, " + CRLF
				cExec	+=	"	X1_VAR05, " + CRLF
				cExec	+=	"	X1_DEF05, " + CRLF
				cExec	+=	"	X1_DEFSPA5, " + CRLF
				cExec	+=	"	X1_DEFENG5, " + CRLF
				cExec	+=	"	X1_CNT05, " + CRLF
			cExec	+=	"	X1_F3, " + CRLF
				cExec	+=	"	X1_PYME, " + CRLF
				cExec	+=	"	X1_GRPSXG, " + CRLF
				cExec	+=	"	X1_HELP, " + CRLF
				cExec	+=	"	X1_PICTURE, " + CRLF
				cExec	+=	"	X1_IDFIL, " + CRLF
			cExec	+=	"	D_E_L_E_T_, " + CRLF
			cExec	+=	"	R_E_C_N_O_, " + CRLF
			cExec	+=	"	R_E_C_D_E_L_) " + CRLF
			cExec	+=	"	VALUES ( " + CRLF
			cExec	+=	"	'"+cPerg+"', " + CRLF
			cExec	+=	"	'"+aRegs[nId_SX1][01]+"', " + CRLF
			cExec	+=	"	'"+aRegs[nId_SX1][02]+"', " + CRLF
			cExec	+=	"	'', " + CRLF
			cExec	+=	"	'', " + CRLF
			cExec	+=	"	'"+aRegs[nId_SX1][03]+"', " + CRLF
			cExec	+=	"	'"+aRegs[nId_SX1][04]+"', " + CRLF
			cExec	+=	"	"+cValToChar(aRegs[nId_SX1][05])+", " + CRLF
			cExec	+=	"	"+cValToChar(aRegs[nId_SX1][06])+", " + CRLF
			cExec	+=	"	"+cValToChar(aRegs[nId_SX1][07])+", " + CRLF
			cExec	+=	"	'"+aRegs[nId_SX1][08]+"', " + CRLF
			cExec	+=	"	'', " + CRLF
			cExec	+=	"	'"+aRegs[nId_SX1][09]+"', " + CRLF
			cExec	+=	"	'', " + CRLF
			cExec	+=	"	'', " + CRLF
			cExec	+=	"	'', " + CRLF
			cExec	+=	"	'', " + CRLF
			cExec	+=	"	'', " + CRLF
			cExec	+=	"	'', " + CRLF
			cExec	+=	"	'', " + CRLF
			cExec	+=	"	'', " + CRLF
			cExec	+=	"	'', " + CRLF
			cExec	+=	"	'', " + CRLF
			cExec	+=	"	'', " + CRLF
			cExec	+=	"	'', " + CRLF
			cExec	+=	"	'', " + CRLF
			cExec	+=	"	'', " + CRLF
			cExec	+=	"	'', " + CRLF
			cExec	+=	"	'', " + CRLF
			cExec	+=	"	'', " + CRLF
			cExec	+=	"	'', " + CRLF
			cExec	+=	"	'', " + CRLF
			cExec	+=	"	'', " + CRLF
			cExec	+=	"	'', " + CRLF
			cExec	+=	"	'', " + CRLF
			cExec	+=	"	'', " + CRLF
			cExec	+=	"	'', " + CRLF
			cExec	+=	"	'"+aRegs[nId_SX1][14]+"', " + CRLF
			cExec	+=	"	'', " + CRLF
			cExec	+=	"	'', " + CRLF
			cExec	+=	"	'', " + CRLF
			cExec	+=	"	'', " + CRLF
			cExec	+=	"	'', " + CRLF
			cExec	+=	"	'', " + CRLF
			cExec	+=	"	ISNULL((SELECT MAX(R_E_C_N_O_) + 1 FROM "+MPSysSqlName("SX1")+ "),1),
			cExec	+=	"	'') "

			nErro := TcSqlExec(cExec)
					
			If nErro != 0
				MsgStop("Erro na execu็ใo da query: "+TcSqlError(), "Aten็ใo")
				DisarmTransaction()
			EndIf

		End Transaction

		If nErro != 0
			Exit
		Endif
	Next nId_SX1
ENDIF
aSize(aPergunte,0)
oFWSX1:Destroy()

FreeObj(oFWSX1)

/*
DbSelectArea("SX1")
DbSetOrder(1)

For nId_SX1:=1 to Len(aRegs)

	DbSeek( cPerg + aRegs[nId_SX1][1] )

	If !Found() .or. aRegs[nId_SX1][2]<>X1_PERGUNT    
	
		RecLock("SX1",!Found())
	
		SX1->X1_GRUPO   := cPerg
		SX1->X1_ORDEM   := aRegs[nId_SX1][01]
		SX1->X1_PERGUNT := aRegs[nId_SX1][02]
		SX1->X1_VARIAVL := aRegs[nId_SX1][03]
		SX1->X1_TIPO    := aRegs[nId_SX1][04]
		SX1->X1_TAMANHO := aRegs[nId_SX1][05]
		SX1->X1_DECIMAL := aRegs[nId_SX1][06]
		SX1->X1_PRESEL  := aRegs[nId_SX1][07]
		SX1->X1_GSC     := aRegs[nId_SX1][08]
		SX1->X1_VAR01   := aRegs[nId_SX1][09]
		SX1->X1_DEF01   := aRegs[nId_SX1][10]
		SX1->X1_DEF02   := aRegs[nId_SX1][11]
		SX1->X1_DEF03   := aRegs[nId_SX1][12]
		SX1->X1_DEF04   := aRegs[nId_SX1][13]
		SX1->X1_F3      := aRegs[nId_SX1][14]
	
		MsUnlock()
	
	Endif
Next nId_SX1
*/

RestArea(aArea)

Return(lRet)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDIP27CFOP บAutor  ณD'Leme              บ Data ณ  10/28/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Retorna o Principal CFOP da Nota Fiscal                    บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ DIPM027                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function DIP27CFOP(cParEmp,cParFil,cParDoc,cParSer)
Local cQueryCF	:= ""
Local cAliasCF	:= GetNextAlias()
Local cRet 		:= "5102"

cQueryCF := " SELECT TOP 1 D2_CF, COUNT(*) NREG"
cQueryCF += " FROM SD2" + cParEmp
cQueryCF += " WHERE D2_FILIAL  = '" + xFilial("SD2",cParFil) + "'"
cQueryCF += "   AND D2_DOC     = '" + cParDoc                + "'"
cQueryCF += "   AND D2_SERIE   = '" + cParSer                + "'"
cQueryCF += "   AND D_E_L_E_T_ = ' '"
cQueryCF += " GROUP BY D2_CF"
cQueryCF += " ORDER BY COUNT(*) DESC"

dbUseArea( .T., "TOPCONN", TCGenQry(,,cQueryCF), cAliasCF, .T., .T. )     

If (cAliasCF)->(!Eof())
	cRet := (cAliasCF)->D2_CF
EndIf
(cAliasCF)->(DbCloseArea())

Return cRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDIP27Obs  บAutor  ณD'Leme              บ Data ณ  10/28/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Retorna a Observa็ใo da Nota Fiscal                        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ DIPM027                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function DIP27Obs(cParEmp,cParFil,cPedido)
Local cQueryE	:= ""
Local cAliasE	:= GetNextAlias()
Local cRet 		:= ""

/*
cRet += 'I -"DOCUMENTO EMITIDO POR ME OU EPP OPTANTE PELO SIMPLES NACIONAL"' 
cRet += ';  '
cRet += 'II-"NรO GERA DIREITO A CRษDITO FISCAL DE IPI"'
cRet := Padr(cRet,140)
*/

cQueryE := " SELECT C5_HRRECEB, C5_ENDENT, C5_MUNE, C5_CEPE, C5_ESTE, C5_BAIRROE"
cQueryE += "   FROM SC5" + cParEmp + " SC5"
cQueryE += "  WHERE C5_FILIAL      = '" + xFilial("SC5",cParFil) + "' "                  //
cQueryE += "    AND C5_NUM         = '" + cPedido + "' "                  //
cQueryE += "    AND SC5.D_E_L_E_T_ = ' '"                          //
dbUseArea( .T., "TOPCONN", TCGenQry(,,cQueryE), cAliasE, .T., .T. )     

If (cAliasE)->(!Eof())
	//-- Verifica se o Endere็o do PV ้ diferente do cadastro no TMS
	If  SA1->A1_END		!= (cAliasE)->C5_ENDENT .Or.;
		SA1->A1_CEP		!= (cAliasE)->C5_CEPE 	.Or.;
		SA1->A1_MUN 	!= (cAliasE)->C5_MUNE 	.Or.;
		SA1->A1_EST 	!= (cAliasE)->C5_ESTE 	.Or.;
		SA1->A1_BAIRRO	!= (cAliasE)->C5_BAIRROE

		cRet += "Endere็o p/ Entrega: "
		cRet += AllTrim( (cAliasE)->C5_ENDENT )  + ", "
		cRet += AllTrim( (cAliasE)->C5_BAIRROE ) + " - " 
		cRet += AllTrim( (cAliasE)->C5_MUNE )    + "-"
		cRet += AllTrim( (cAliasE)->C5_ESTE )    + " CEP: "
		cRet += AllTrim( (cAliasE)->C5_CEPE ) 
	EndIf
	
	//-- Verifica se possui observa็ใo de entrega
	If !Empty((cAliasE)->C5_HRRECEB)
		cRet += Iif(Empty(cRet),"",Chr(13)+Chr(10))
		cRet += AllTrim( (cAliasE)->C5_HRRECEB )
	EndIf
EndIf
(cAliasE)->(DbCloseArea())

Return cRet  



Static Function ValidGrvTms(aDados)
  
Private Gi 
Private Gz
//oDlg:End()
For Gi:= 1 To Len(aDados)
	If aDados[Gi][01]
		For Gz:= 1 To Len(aDados)
			
			If aDados[Gi][06] = aDados[Gz][06] .And. aDados[Gi][07]= aDados[Gz][07] .and. alltrim(aDados[Gi][13]) <> alltrim(aDados[Gz][13])   .And. aDados[Gi][18]<>aDados[Gz][18] .And. aDados[Gz][01]
				aDados[Gz][01] := .F.
			  
			   msginfo("A Nota Fiscal: "+aDados[Gz][02]+"  Serie: "+aDados[Gz][03]+"     Nใo Foi Enviada A Emovere,  Reenvie-a Novamente Ao Final Do Processo.","Aten็ใo")
			EndIf
			
		Next Gz
	EndIf
Next Gi


//{|| Processa({||fGrvTMS()},"Gravando NFS no TMS"),oDlg:End()}
return(aDados)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDIPM027   บAutor  ณMicrosiga           บ Data ณ  11/07/13   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function DipNFLic(cDoc,cSerie,cCodCli,cLoja)
Local lRet		 := .F.
Local cClientLic :=GetNewPar("ES_DIPML27","")
Local cClientLit :=GetNewPar("ES_DIPM27_","")
Local cTESLicG   :=GetNewPar("ES_DIPMG27","")
Local cTESLicN   :=GetNewPar("ES_DIPMN27","") 
Local cPosto	 := ""
Local aEmpresa   := fEmpresa()              
Local cSQL 		 := ""                             
Local cMsg		 := ""                                  


cSQL := " SELECT "
cSQL += "	D2_PEDIDO, D2_TES, D2_DOC "
cSQL += "	FROM "
cSQL += "		SD2"+aEmpresa[1,1]
cSQL += "		WHERE "
cSQL += "			D2_FILIAL = '"+aEmpresa[1,2]+"' AND "
cSQL += "			D2_DOC = '"+cDoc+"' AND "
cSQL += "			D2_SERIE = '"+cSerie+"' AND " 
cSQL += "			D2_CLIENTE = '"+cCodCli+"' AND "
cSQL += "			D2_LOJA = '"+cLoja+"' AND "
cSQL += "			D_E_L_E_T_ = ' ' "                                   

cSQL := ChangeQuery(cSQL)
		
dbUseArea( .T., "TOPCONN", TCGenQry(,,cSQL), "TRBSD2", .T., .T. )     

If !TRBSD2->(Eof())

	cPosto := PostoUsu(TRBSD2->D2_PEDIDO) 
	IF (cCodCli $ cClientLic .OR. cCodCli $ cClientLit)
		While !TRBSD2->(Eof()) .And. !lRet		
			If ((cCodCli $ cClientLic .OR. cCodCli $ cClientLit) .AND.  TRBSD2->D2_TES $ cTesLicG .AND. cPosto $ '03') .OR.; 
			   ((cCodCli $ cClientLic .OR. cCodCli $ cClientLit) .AND. !TRBSD2->D2_TES $ cTesLicN)	
				lRet:=.T. 
			EndIf                  
		
			If (cCodCli $ cClientLic .OR. cCodCli $ cClientLit) .AND. TRBSD2->D2_TES $ cTesLicG // Gera CTE
		    	cMsg := "S"
		  	EndIf

			If (cCodCli $ cClientLic .OR. cCodCli $ cClientLit) .AND. TRBSD2->D2_TES $ cTesLicN // Nใo gera CTE
		    	cMsg := "N"
		  	EndIf
					
			TRBSD2->(dbSkip())
		EndDo
	Else
		lRet := .T.       
	EndIf
EndIf                 
TRBSD2->(dbCloseArea())                
           
If cMsg == "S"
	cNFb += cDoc +" / "
ElseIf cMsg == "N"
	cNFa += cDoc +" / "
EndIf      

Return lRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDIPM027   บAutor  ณMicrosiga           บ Data ณ  11/07/13   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function PostoUsu(cPedido)
Local cPosto := ""
Local aEmpresa  := fEmpresa()

cSQL := " SELECT "
cSQL += " 	U7_POSTO "
cSQL += " 	FROM "
cSQL += "		SC5"+aEmpresa[1,1]+", "
cSQL += "		SU7010 "
cSQL += " 		WHERE "
cSQL += " 			C5_FILIAL = '"+aEmpresa[1,2]+"' AND "
cSQL += " 			C5_NUM = '"+cPedido+"' AND "
cSQL += " 			C5_OPERADO = U7_COD AND "
cSQL += " 			SC5"+aEmpresa[1,1]+".D_E_L_E_T_ = ' ' AND "
cSQL += " 			SU7010.D_E_L_E_T_ = ' ' "

cSQL := ChangeQuery(cSQL)
		
dbUseArea( .T., "TOPCONN", TCGenQry(,,cSQL), "TRBSU7", .T., .T. )     

If !TRBSU7->(Eof())
	cPosto := TRBSU7->U7_POSTO	
EndIf
TRBSU7->(dbCloseArea())             

Return cPosto
/*-------------------------------------------------------------------------
+ RBORGES - 09/10/2013 ----- User Funcion: CicDipm27()                    +
+ Enviarแ CIC quando a nota de carta de vale nใo gerar Cte na Emovere.    +
+ 														                  +
-------------------------------------------------------------------------*/

*--------------------------------------------------------------------------*
Static Function CDipm27a()
*--------------------------------------------------------------------------*

Local aArea       := GetArea()
Local cDeIc       := "protheus@dipromed.com.br"
Local cCICDest    := Upper(GetNewPar("ES_DIPMC27","reginaldo.borges")) // Usuแrios que receberใo CICดs
Local cAttachIc   :=  "  a"
Local cFuncSentIc :=   " DIPM027.prw "

dbSelectArea("SM0")

_aMsgIc := {}
cMSGcIC       := 'AVISO - NOTA(S) DE LICITAวรO - NรO GERA CTE!  ' +CHR(13)+CHR(10)+CHR(13)+CHR(10) +cNFa+CHR(13)+CHR(10)

cMSGcIC       += " ATENวรO! NรO SERม GERADO CTE - TRANSPORTAR NORMALMENTE!"   +CHR(13)+CHR(10)

U_DIPCIC(cMSGcIC,cCICDest)

RestArea(aArea)
return()

/*-------------------------------------------------------------------------
+ RBORGES - 09/10/2013 ----- User Funcion: CicDipm27()                    +
+ Enviarแ CIC quando a nota de carta de vale gerar Cte na Emovere.    +
+ 														                  +
-------------------------------------------------------------------------*/

*--------------------------------------------------------------------------*
Static Function CDipm27b()
*--------------------------------------------------------------------------*

Local aArea       := GetArea()
Local cDeIc       := "protheus@dipromed.com.br"
Local cCICDest    := Upper(GetNewPar("ES_DIPMC27","reginaldo.borges")) // Usuแrios que receberใo CICดs
Local cAttachIc   :=  "  a"
Local cFuncSentIc :=   " DIPM027.prw "

dbSelectArea("SM0")

_aMsgIc := {}
cMSGcIC       := 'AVISO - NOTA(S) DE LICITAวรO - FAVOR  GERAR CTE! ' +CHR(13)+CHR(10)+CHR(13)+CHR(10) +cNFb+CHR(13)+CHR(10)

cMSGcIC       += " ATENวรO! APENAS FINANCEIRO - FAVOR GERAR CTE! "   +CHR(13)+CHR(10)

U_DIPCIC(cMSGcIC,cCICDest)

RestArea(aArea)
return()
/*-----------------------------------------------------------------------------
+ Reginaldo Borges Data: 14/10/213 Fun็ใo: EDipm27b()
+ Essa fun็ใo enviarแ e-mail para os usuแrios contidos no parโmetro,
+ quando quando as nota fiscais de licita็ใo, carta de vale, nใo gerarem Cte.
-----------------------------------------------------------------------------*/
*--------------------------------------------------------------------------*
Static Function EDipm27a()
*--------------------------------------------------------------------------*

Local cDeIc       := "protheus@dipromed.com.br"
Local cEmailIc    := GetNewPar("ES_DIPME27","reginaldo.borges@dipromed.com.br")        //Usuแrios que receberใo e-mails
Local cAssuntoIc  := EncodeUTF8("NOTA(S) DE LICITAวรO - NรO GERA CTE! ","cp1252")
Local cAttachIc   :=  "  a"
Local cFuncSentIc :=   " DIPM027.prw "

_aMsgIc := {}
cMSGcIC       := "NOTA(S) DE LICITAวรO - NรO GERA CTE! " +CHR(13)+CHR(10)+CHR(13)+CHR(10)

//	cMSGcIC       += " EMPRESA:_______" + Capital( AllTrim( GetAdvFVal( "SM0", "M0_NOME", cEmpAnt + cFilAnt, 1, "" ) ) )

aAdd( _aMsgIc , { "NOTA FISCAIS ", +cNFa})
aAdd( _aMsgIc , { "ATENวรO!     ", +"NรO SERม GERADO CTE - TRANSPORTAR NORMALMENTE! "})

U_UEnvMail(cEmailIc,cAssuntoIc,_aMsgIc,cAttachIc,cDeIc,cFuncSentIc)

return()
/*-----------------------------------------------------------------------------
+ Reginaldo Borges Data: 14/10/213 Fun็ใo: EDipm27b()
+ Essa fun็ใo enviarแ e-mail para os usuแrios contidos no parโmetro,
+ quando quando as nota fiscais de licita็ใo, carta de vale, gerarem Cte.
-----------------------------------------------------------------------------*/
*--------------------------------------------------------------------------*
Static Function EDipm27b()
*--------------------------------------------------------------------------*
Local cDeIc       := "protheus@dipromed.com.br"
Local cEmailIc    := GetNewPar("ES_DIPME27","reginaldo.borges@dipromed.com.br")        //Usuแrios que receberใo e-mails
Local cAssuntoIc  := EncodeUTF8("NOTA(S) DE LICITAวรO - FAVOR  GERAR CTE! ","cp1252")
Local cAttachIc   :=  "  a"
Local cFuncSentIc :=   " DIPM027.prw "

_aMsgIc := {}
cMSGcIC       := "NOTA(S) DE LICITAวรO - FAVOR GERAR CTE! " +CHR(13)+CHR(10)+CHR(13)+CHR(10)


//	cMSGcIC       += " EMPRESA:_______" + Capital( AllTrim( GetAdvFVal( "SM0", "M0_NOME", cEmpAnt + cFilAnt, 1, "" ) ) )

aAdd( _aMsgIc , { "NOTA FISCAIS ", +cNFb})
aAdd( _aMsgIc , { "ATENวรO!     ", +"APENAS FINANCEIRO - FAVOR GERAR CTE "})

U_UEnvMail(cEmailIc,cAssuntoIc,_aMsgIc,cAttachIc,cDeIc,cFuncSentIc)

return()

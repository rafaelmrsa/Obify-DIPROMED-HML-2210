#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

#DEFINE nD2_DOC		01
#DEFINE nD2_SERIE	02
#DEFINE nDB_PRODUTO	03
#DEFINE nDB_LOCAL	04
#DEFINE nDB_LOTECTL	05
#DEFINE nDB_NUMLOTE	06
#DEFINE nDB_NUMSERI	07
#DEFINE nDB_LOCALIZ	08
#DEFINE nDB_QUANT	09


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณPrograma  ณDIPA048() ณ Autor ณJailton B Santos-JBS   ณ Data ณ31/05/2010ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescrio ณ Este programa pega os dados de uma nota fiscal de saida na ณฑฑ
ฑฑณ          ณ empresa HQ filial 01 do cliente 011050 da loja 04 e gera   ณฑฑ
ฑฑณ          ณ uma nota fiscal de entrada na empresa HQ filial 04 para o  ณฑฑ
ฑฑณ          ณ fornecedor '051508' e loja '27'.                           ณฑฑ
ฑฑณ          ณ                                                            ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUso       ณ Especifico Faturamento Dipromed.                           ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณProgramador ณ Data   ณ  Motivo da Alteracao                            ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ            ณ        ณ                                                 ณฑฑ
ฑฑณ            ณ        ณ                                                 ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
User Function DIPA048()  



Local oDlg 
Local nOpc     := 0                      
Local lRet     := .T.    
Local bOk      := {|| If(fQuery(),(nOpc:=1,oDlg:End()),Aviso('Atencao','Nใo encontrou a Nota Fiscal informada .',{'Ok'}))}
Local bCancel  := {|| nOpc:=2,oDlg:End()}     
Local nEmpOri  := 0  // MCVN - 31-07-10

Private cNroNF   := Space(9)
Private cSerNF   := Space(3) 
Private aEmpresa := {}         
Private lDevCom  := .F.   
Private lDipa048Dv := .T. // Usado do P.E. MT103LDV



// Valida empresa Destino - MCVN 18/06/10
If !(AllTrim(Upper(U_DipUsr())) $ 'EELIAS/MCANUTO/DDOMINGOS/VQUEIROZ/VEGON/RBORGES/RLOPES/')
	Aviso('Atencao','Usuแrio sem acesso para executar este rotina.',{'Ok'})		
	Return(.F.)
Endif

// Selecionando a empresa origem  MCVN - 31-07-10
//Private nEmpOri := Aviso('Aten็ใo','Selecione a empresa origem?',{'DIPRO-CD','DIPRO-MATRIZ','HQ-CD','HQ-MATRIZ'})
Private nEmpOri := Aviso('Aten็ใo','Selecione a empresa origem?',{'DIPRO-CD','DIPRO-MATRIZ'})
//-------------------------------------------------------------------------------------------------------------------------------
// Determina quais empresas devem ser processadas  - MCVN - 31-07-10
//-------------------------------------------------------------------------------------------------------------------------------
do case
case nEmpOri == 1 ;	aEmpresa  := {'010','04'}  // 
case nEmpOri == 2 ;	aEmpresa  := {'010','01'}  //
//case nEmpOri == 3 ;	aEmpresa  := {'040','04'}  // 
//case nEmpOri == 4 ;	aEmpresa  := {'040','01'}  //
OtherWise
Return(.F.) 
endcase                                        

If aEmpresa[1]+aEmpresa[2] == SM0->M0_CODIGO+"0"+SM0->M0_CODFIL
	Aviso('Atencao','A empresa ORIGEM nใo pode ser a mesma de DESTINO.',{'Ok'})		
	Return(.F.)
EndIf

If cEmpAnt+cFilAnt == '0101'
	lDevCom :=  .T.
Endif
               
Define MsDialog oDlg Title "TRANSFERENCIA DE NF ENTRE EMPRESAS" from 0,0 to 150,400 of oMainWnd pixel

@ 010,005 say 'Numero da NF'  Size 70,08 color CLR_HBLUE Of oDlg Pixel
@ 030,005 say 'Serie da NF '  Size 70,08 color CLR_HBLUE Of oDlg Pixel

@ 010,060 msget oNroNF var cNroNF size 50,08 of oDlg pixel
@ 030,060 msget oSerNF var cSerNF size 30,08 of oDlg pixel

@ 10,156 Button OemToAnsi("Confirma") size 40,15 pixel of oDlg action eval(bOk)
@ 34,156 Button OemToAnsi("Cancela")  size 40,15 pixel of oDlg action eval(bCancel)

Activate MsDialog oDlg Centered

If nOpc = 1              

	Processa({|| lRet := fGeraNFE()} )
	If lRet
		Aviso('Sucesso','Notas Fiscais Geradas Com Sucesso ...',{'OK'})
	   	/*If MsgBox("Deseja endere็ar automaticamente os produtos?","Atencao","YESNO")
			Processa({|lEnd| fEnder48(cNroNF+cSerNF)},"Efetuando o endere็amento do Produto..")
		Endif */		
	EndIf   
	

EndIf 
If Select('TRB') > 0
    TRB->( DbCloseArea() ) 
EndIf


Return(.T.)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณfQuery()  บAutor  ณJailton B Santos-JBSบ Data ณ 31/05/2010  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Filtra as informacoes da nota fiscal origem, ou seja na fi-บฑฑ
ฑฑบ          ณ lial 01 da healtt Quality.                                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Especifico Faturamento Dipromed                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function fQuery()

Local cQuery  := ""
Local cQueryC := ""

cQuery := " SELECT F2_FILIAL, "
cQuery += "        F2_TIPO, "
cQuery += "        F2_DOC, "
cQuery += "        F2_SERIE, "
cQuery += "        F2_EMISSAO, "
cQuery += "        F2_CLIENTE, "
cQuery += "        F2_LOJA, "
cQuery += "        F2_ESPECIE, "
cQuery += "        F2_COND, "
cQuery += "        D2_ITEM, "
cQuery += "        D2_COD, "
cQuery += "        D2_LOCAL, "
cQuery += "        D2_NUMSEQ, "
cQuery += "        D2_DOC, "
cQuery += "        D2_SERIE, "
cQuery += "        D2_CLIENTE, "
cQuery += "        D2_LOJA, "
cQuery += "        D2_QUANT, "
cQuery += "        D2_PRCVEN,"
cQuery += "        D2_TOTAL, "
cQuery += "        D2_TES, "
cQuery += "        D2_VALICM, "
cQuery += "        D2_PICM, "
cQuery += "        D2_BASEICM, "
cQuery += "        D2_LOTECTL, "                     
cQuery += "        D2_DTVALID  "
cQuery += "   FROM SF2" + aEmpresa[1] + " SF2 "   // Ajustando e empresa de acordo com a op็ใp selecionada no inํcio da rotina    - MCVN 31-07-10
cQuery += "  INNER JOIN SD2" + aEmpresa[1] + " SD2 ON D2_FILIAL = '" +aEmpresa[2]+"' AND D2_DOC = F2_DOC AND D2_SERIE = F2_SERIE AND D2_CLIENTE = F2_CLIENTE AND D2_LOJA = F2_LOJA AND SD2.D_E_L_E_T_ = '' "
cQuery += "  WHERE SF2.F2_FILIAL = '" + aEmpresa[2] + "' "// Ajustando e empresa de acordo com a op็ใp selecionada no inํcio da rotina    - MCVN 31-07-10
cQuery += "    AND SF2.F2_DOC = '" + cNroNF + "' "
cQuery += "    AND SF2.F2_SERIE = '" + cSerNF + "' " 

// Validando o Cliente - MCVN 31-07-10
/*If aEmpresa[1]+aEmpresa[2] = '04001'    
	cQuery += "    AND SF2.F2_CLIENTE = '000804' "
	cQuery += "    AND SF2.F2_LOJA = '01' " 
ElseIf aEmpresa[1]+aEmpresa[2] = '04004'
	If cEmpAnt+cFilAnt == '0101'
		cQuery += "    AND SF2.F2_CLIENTE = '000804' "
		cQuery += "    AND SF2.F2_LOJA = '01' "                        
	Else 
		cQuery += "    AND SF2.F2_CLIENTE = '000804' "
		cQuery += "    AND SF2.F2_LOJA = '04' "       	
	Endif
ElseIf aEmpresa[1]+aEmpresa[2] = '01001'
	cQuery += "    AND SF2.F2_CLIENTE = '011050' "
	cQuery += "    AND SF2.F2_LOJA = '01' " 
Else  
	cQuery += "    AND SF2.F2_CLIENTE = '000847' "
	cQuery += "    AND SF2.F2_LOJA = '01' " 
Endif*/                                     

If aEmpresa[1]+aEmpresa[2] = '01001'    
	IF lDevCom              
		cQuery += "    AND SF2.F2_CLIENTE = '990132' "
		cQuery += "    AND SF2.F2_LOJA = '04' " 
	Else 
		cQuery += "    AND SF2.F2_CLIENTE = '000804' "
		cQuery += "    AND SF2.F2_LOJA = '04' " 	
	Endif
Else
	IF lDevCom
		cQuery += "    AND SF2.F2_CLIENTE = '990064' "
		cQuery += "    AND SF2.F2_LOJA = '01' "                        
	Else 
		cQuery += "    AND SF2.F2_CLIENTE = '000804' "
		cQuery += "    AND SF2.F2_LOJA = '01' "       	
	Endif     
EndIf
 
cQuery += "    AND SF2.D_E_L_E_T_ = '' "
                                         
cQuery += " ORDER BY F2_DOC, F2_SERIE, D2_ITEM "

If Select("TRB") > 0
    TRB->( DbCloseArea() )     
EndIf    

TCQUERY cQuery NEW ALIAS "TRB" 
memowrite('dipa048.SQL',cquery)
TCSETFIELD("TRB","F2_EMISSAO" , "D" , 08 , 00)
TCSETFIELD("TRB","D2_DTVALID" , "D" , 08 , 00)
TCSETFIELD("TRB","D2_QUANT"   , "N" , 14 , 02)
TCSETFIELD("TRB","D2_PRECVEN" , "N" , 05 , 04)
TCSETFIELD("TRB","D2_TOTAL"   , "N" , 16 , 04)
TCSETFIELD("TRB","D2_VALICM"  , "N" , 16 , 04)
TCSETFIELD("TRB","D2_PICM "   , "N" , 16 , 04)
TCSETFIELD("TRB","D2_BASEICM" , "N" , 16 , 04)

lRet := !TRB->( BOF().and.EOF() )                

Return(lRet)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณfGeraNFE()บAutor  ณJailton B Santos-JBSบ Data ณ 31/05/2010  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Gera a nota fiscal de entrada na empresa atual             บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Especifico Faturamento Dipromed                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function fGeraNFE()                   

Local lRet := .T.
Local cChave := ''
Local nRec   := 70  
Local cFornece := ""
Local cLojaFor := ""
Local aEnd		:= {}
 

If !MsgYesNo("A nota foi encontrada, confirma a importa็ใo?")                             
	Return()
Endif

Private lQbgImpNF := .T.  // Usado no P.E. Mt100Agr para nao pedir obs
                                         

If aEmpresa[1]+aEmpresa[2] == '01004'  
	if lDevCom   
		cFornece := '000804'
  		cLojaFor := '04'
    Else             
  		cFornece := '990032'
  		cLojaFor := '04'
    Endif
Else                                      
	if lDevCom   
		cFornece := '000804'
  		cLojaFor := '01'
    Else
   		cFornece := '990064'
  		cLojaFor := '01'
  	Endif
Endif

ProcRegua(nRec)
            
TRB->( DbGotop() )

Do While TRB->( !EOF() )
	
	cChave := TRB->F2_DOC + TRB->F2_SERIE

	aNfeCAB := {{"F1_TIPO"    , If(lDevCom,"D","N"), Nil},;
	            {"F1_FORMUL"  , "N"                , Nil},;
	            {"F1_DOC"     , TRB->F2_DOC        , Nil},;
	            {"F1_SERIE"   , TRB->F2_SERIE      , Nil},;
	            {"F1_EMISSAO" , TRB->F2_EMISSAO    , Nil},; 
	            {"F1_FORNECE" , cFornece           , Nil},;
				{"F1_LOJA"    , cLojaFor           , Nil},;
	            {"F1_ESPECIE" , 'NFE'              , Nil},;
	            {"F1_COND"    , If(Posicione("SF4",1,xFilial("SF4") + fTes(), "F4_DUPLIC") == "S",TRB->F2_COND,"")   , Nil}}   
	
    aNfeITE := {}
    aEnd := {}

	Do While TRB->(!EOF()).and. TRB->F2_DOC + TRB->F2_SERIE == cChave
		
        IncProc()
    
        If nRec = 0
            nRec := 70
            ProcRegua(nRec)
        EndIf 
    
        nRec--   
    
       	//--------------------------------------------------------------
        // Item NF Entrada
	    //--------------------------------------------------------------
        SB1->( DbSetOrder(1) )
        SB1->( DbSeek(xFilial('SB1') + TRB->D2_COD ) )   
        
		If Posicione("SF4",1,xFilial("SF4") + fTes(), "F4_ESTOQUE") == "S"		
			fEndOri("TRB", @aEnd)
		EndIf

        If SB1->B1_RASTRO <> "N" .And. SF4->F4_ESTOQUE == "S"
	        AAdd(aNfeIte,{{"D1_COD"     , TRB->D2_COD     , NIL},;
	                      {"D1_QUANT"   , TRB->D2_QUANT   , NIL},;
	                      {"D1_VUNIT"   , TRB->D2_PRCVEN  , NIL},;
	                      {"D1_TOTAL"   , TRB->D2_TOTAL   , NIL},;
   	                      {"D1_TES"     , fTes()          , NIL},;
	                      {"D1_VALICM"  , TRB->D2_VALICM  , NIL},;
	                      {"D1_PICM"    , TRB->D2_PICM    , NIL},;
                          {"D1_NFORI"   , If(lDevCom,"000000000",""),NIL},;
	                      {"D1_LOTECTL" , TRB->D2_LOTECTL , NIL},;
	                      {"D1_DTVALID" , TRB->D2_DTVALID , NIL},;
                          {"D1_BASEICM" , TRB->D2_BASEICM , NIL} } )
        Else
	        AAdd(aNfeIte,{{"D1_COD"      , TRB->D2_COD     , NIL},;
	                       {"D1_QUANT"   , TRB->D2_QUANT   , NIL},;
	                       {"D1_VUNIT"   , TRB->D2_PRCVEN  , NIL},;
	                       {"D1_TOTAL"   , TRB->D2_TOTAL   , NIL},;
   	                       {"D1_TES"     , fTes()          , NIL},;
	                       {"D1_VALICM"  , TRB->D2_VALICM  , NIL},;
	                       {"D1_PICM"    , TRB->D2_PICM    , NIL},;                        
	                       {"D1_NFORI"   , If(lDevCom,"000000000",""), NIL} ,;
   	                       {"D1_BASEICM" , TRB->D2_BASEICM , NIL} } )
		EndIf
		TRB->(DbSkip())

	EndDo

	Begin Transaction
		lMsErroAuto := .F.
	
  		MSExecAuto({|x,y,z| Mata103(x,y,z)},aNfeCab,aNfeIte,3)	
	
		If lMsErroAuto 
		   DisarmTransaction()
		   lRet := .F.
		   MostraErro()
		//ElseIf !(lRet := fEnder48(@aEnd))
		//	MsgAlert("Nใo foi possํvel o Endere็amento da NF")
		//	MostraErro()
		//  DisarmTransaction()
		Endif

	End Transaction

EndDo  

lQbgImpNF := .T.

Return(lRet) 

Static Function fTes() 
Local cTEs := ""

/*do case
	case TRB->D2_TES = '508'; cTes := '248'
	case TRB->D2_TES = '575'; cTes := '007'  
	case TRB->D2_TES = '626'; cTes := '309'
	case TRB->D2_TES = '512'; cTes := '117'
	case TRB->D2_TES = '650'; cTes := '126'
	case TRB->D2_TES = '662'; cTes := '011'	
	case TRB->D2_TES = '501'; cTes := '001'	  	
endcase*/                                       

If cEmpAnt+cFilAnt = '0101'
	do case 
   		case TRB->D2_TES = '508'	; cTes := '248'
		case TRB->D2_TES $ '575/775'; cTes := '007'  
		case TRB->D2_TES = '626'	; cTes := '309'
		case TRB->D2_TES = '512'	; cTes := '117'
		case TRB->D2_TES = '650'	; cTes := '126'
		case TRB->D2_TES = '662'	; cTes := '011'	
		case TRB->D2_TES = '501'	; cTes := '001'	 
		case TRB->D2_TES = '703'	; cTes := '320'	   
		case TRB->D2_TES = '681'	; cTes := '131'
		case TRB->D2_TES = '881'	; cTes := '339'
		case TRB->D2_TES = '682'	; cTes := '135'
		case TRB->D2_TES = '882'	; cTes := '341'
		case TRB->D2_TES = '686'	; cTes := '263'
		case TRB->D2_TES = '886'	; cTes := '348'
	endcase  
ElseIf cEmpAnt+cFilAnt = '0104'
	do case 
		case TRB->D2_TES = '508'	; cTes := '248'
		case TRB->D2_TES $ '575/775'; cTes := '007'  
		case TRB->D2_TES = '626'	; cTes := '309'
		case TRB->D2_TES = '512'	; cTes := '117'
		case TRB->D2_TES = '650'	; cTes := '126'
		case TRB->D2_TES = '662'	; cTes := '011'	
		case TRB->D2_TES = '501'	; cTes := '001'	   
		case TRB->D2_TES = '703'	; cTes := '320'	   
		case TRB->D2_TES = '538'	; cTes := '179'
		case TRB->D2_TES = '738'	; cTes := '343'
		case TRB->D2_TES = '638'	; cTes := '255'
		case TRB->D2_TES = '838'	; cTes := '347'
		case TRB->D2_TES = '683'	; cTes := '038'
		case TRB->D2_TES = '883'	; cTes := '335'
	endcase 
EndIf
 
Return(cTes)          

                
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบPrograma  ณfEnder53()บAutor ณMicrosiga           บ Data ณ  08/04//2011 บฑฑ
ฑฑฬออออออออออุอออออออออออสออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณEndere็a os itens da nota fiscal de entrada                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Especifico Estoques Dipromed.                              บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/                                                                               

Static Function fEnder48(aEnd)

Local lRet    := .T.
Local cSeekSDA:= ''
Local cLoteSDA:= ''
Local lRastro := ''
Local cItens  := '0000'                    
Local cLocaliz := ""
Local aArea     := GetArea()
Local nI      := 0
Local nJ      := 0

Private aCabec:= {}
Private aItem := {}
Private aItens := {}

cAliasTRB := GetNextAlias()

aSort(aEnd,,,{ |x,y| x[nD2_DOC]+x[nD2_SERIE]+x[nDB_PRODUTO]+x[nDB_LOCAL]+x[nDB_LOTECTL]+x[nDB_NUMLOTE] < ;
					 y[nD2_DOC]+y[nD2_SERIE]+y[nDB_PRODUTO]+y[nDB_LOCAL]+y[nDB_LOTECTL]+y[nDB_NUMLOTE] })

DbCommitAll()
For nI := 1 To Len(aEnd)
	cSeekSDA := xFilial("SDA")+aEnd[nI,nD2_DOC]+aEnd[nI,nD2_SERIE]+aEnd[nI,nDB_PRODUTO]+aEnd[nI,nDB_LOCAL]+aEnd[nI,nDB_LOTECTL]+aEnd[nI,nDB_NUMLOTE]
/*	
	SDA->(dbSetFilter({|| SDA->(DA_FILIAL+DA_DOC+DA_SERIE+DA_PRODUTO+DA_LOCAL+DA_LOTECTL+DA_NUMLOTE)== cSeekSDA},"SDA->(DA_FILIAL+DA_DOC+DA_SERIE+DA_PRODUTO+DA_LOCAL+DA_LOTECTL+DA_NUMLOTE)== cSeekSDA"))
	SDA->(dbGoTop())
	
	Do While SDA->( !EOF() )  .And. SDA->(DA_FILIAL+DA_DOC+DA_SERIE+DA_PRODUTO+DA_LOCAL+DA_LOTECTL+DA_NUMLOTE)== cSeekSDA
*/
	cQuery := " SELECT R_E_C_N_O_ NREC FROM " + RetSqlName("SDA")
	cQuery += " WHERE"
	cQuery += "    DA_FILIAL      = '"+ xFilial("SDA") +"'"
	cQuery += "    AND DA_DOC     = '"+ aEnd[nI,nD2_DOC] +"'"
	cQuery += "    AND DA_SERIE   = '"+ aEnd[nI,nD2_SERIE] +"'"
	cQuery += "    AND DA_PRODUTO = '"+ aEnd[nI,nDB_PRODUTO]+"'"
	cQuery += "    AND DA_LOCAL   = '"+ aEnd[nI,nDB_LOCAL]+"'"
	cQuery += "    AND DA_LOTECTL = '"+ aEnd[nI,nDB_LOTECTL]+"'"
	cQuery += "    AND DA_NUMLOTE = '"+ aEnd[nI,nDB_NUMLOTE]+"'"
	cQuery += "    AND D_E_L_E_T_ = ' '"
	
	dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),cAliasTrb,.F.,.T.)
	
	//-- Percorre a Query e adiciona o resultado no array de Retorno
    Do While(cAliasTrb)->(!Eof())
    	SDA->(DbGoTo( (cAliasTrb)->NREC ))
		SB2->(dbSetFilter({|| SB2->B2_COD        == SDA->DA_PRODUTO},"SB2->B2_COD         ==SDA->DA_PRODUTO"))
		SBF->(dbSetFilter({|| SBF->BF_PRODUTO==SDA->DA_PRODUTO},"SBF->BF_PRODUTO==SDA->DA_PRODUTO"))	
		SB8->(dbSetFilter({|| SB8->B8_PRODUTO==SDA->DA_PRODUTO},"SB8->B8_PRODUTO==SDA->DA_PRODUTO"))	
	
		aCabec := {}
		aItem  := {}
	
	   	Aadd(aCabec, {"DA_FILIAL"   , SDA->DA_FILIAL          , nil})
	   	Aadd(aCabec, {"DA_PRODUTO"   , SDA->DA_PRODUTO          , nil})
		Aadd(aCabec, {"DA_QTDORI"      , SDA->DA_QTDORI         , nil})
		Aadd(aCabec, {"DA_SALDO"       , SDA->DA_SALDO          , nil})
		Aadd(aCabec, {"DA_DATA"         , SDA->DA_DATA          , nil}) 
	
	   	Aadd(aCabec, {"DA_LOTECTL"      , SDA->DA_LOTECTL       , nil})
	   	Aadd(aCabec, {"DA_NUMLOTE"     , SDA->DA_NUMLOTE        , nil})
	    
		Aadd(aCabec, {"DA_LOCAL"        , SDA->DA_LOCAL         , nil})
		Aadd(aCabec, {"DA_DOC"            , SDA->DA_DOC         , nil})
		Aadd(aCabec, {"DA_SERIE"          , SDA->DA_SERIE       , nil})
		Aadd(aCabec, {"DA_CLIFOR"       , SDA->DA_CLIFOR        , nil})
		Aadd(aCabec, {"DA_LOJA"           , SDA->DA_LOJA        , nil})
		Aadd(aCabec, {"DA_TIPONF"        , SDA->DA_TIPONF       , nil})
		Aadd(aCabec, {"DA_ORIGEM"       , SDA->DA_ORIGEM        , nil})
		Aadd(aCabec, {"DA_NUMSEQ"      , SDA->DA_NUMSEQ         , nil})
		Aadd(aCabec, {"DA_QTSEGUM"    , SDA->DA_QTSEGUM         , nil})
		Aadd(aCabec, {"DA_QTDORI2"      , SDA->DA_QTDORI2       , nil})
	
		aITem  := {}     
		aITens := {}     
		cItens := '0'  
		aNfeITE := {}      
	
		For nJ := nI To Len( aEnd )
		    cItens   := StrZero(nJ,Len(SDB->DB_ITEM))
		    If cSeekSDA == xFilial("SDA")+aEnd[nJ,nD2_DOC]+aEnd[nJ,nD2_SERIE]+aEnd[nJ,nDB_PRODUTO]+aEnd[nJ,nDB_LOCAL]+aEnd[nJ,nDB_LOTECTL]+aEnd[nJ,nDB_NUMLOTE]           
				AAdd(aNfeIte,{{"DB_ITEM"     , cItens               , NIL},;
			        	      {"DB_LOCALIZ"  , aEnd[nJ,nDB_LOCALIZ] , NIL},;
			    	          {"DB_NUMSERI"  , aEnd[nJ,nDB_NUMSERI] , nil},;
				              {"DB_QUANT"    , aEnd[nJ,nDB_QUANT] 	, NIL},;
				              {"DB_HRINI"    , Time()        , NIL},;
			            	  {"DB_DATA"     , ddatabase     , NIL},;
			        	      {"DB_ESTORNO"  , ''            , NIL},;
			    	          {"DB_QTSEGUM"  , 0             , NIL} } )
			 EndIf
		Next nJ

		If Len(aNfeIte) > 0
			nI += Len(aNfeIte) - 1

			lMsErroAuto := .F.
			MsExecAuto({|x,y,z| mata265(x,y,z)}, aCabec, aNfeITE, 3 ) // 3-Distribui, 4-Estorna
	
			If lMsErroAuto
				lRet := .F.
				Exit
			EndIf          
		EndIf          
		
		SB2->(dbSetFilter({|| .t.},".t.")) 
		SBF->(dbSetFilter({|| .t.},".t.")) 
		SB8->(dbSetFilter({|| .t.},".t.")) 
		
		//SDA->( Dbskip() )
		(cAliasTrb)->( Dbskip() )
	
	EndDo
	(cAliasTrb)->( DbCloseArea() )

Next nI
SDA->(dbSetFilter({|| .t.},".t.")) // m
aCabSD3 := {}
aRegSD3 := {}

RestArea(aArea)
Return lRet                                                                                                                      



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณfEndOri   บAutor  ณMicrosiga           บ Data ณ  04/28/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Funcao para obter o enderecamento original                 บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function fEndOri(cAliasSD2, aAux)
Local cAliasTrb	:= GetNextAlias()
Local cQuery	:= ""
Local aAreas 	:= {	SDB->(GetArea()),;
					 	GetArea()}

cQuery := " SELECT DB_PRODUTO, DB_LOCAL, DB_LOTECTL, DB_NUMLOTE, DB_NUMSERI, DB_LOCALIZ, DB_QUANT "

cQuery += " FROM SDB" + aEmpresa[1] + " SDB "

cQuery += " WHERE"
cQuery += "     SDB.DB_FILIAL      = '" + xFilial("SDB",aEmpresa[2]) + "'"
cQuery += "     AND SDB.D_E_L_E_T_ = ' '"
cQuery += "     AND SDB.DB_PRODUTO = '" + (cAliasSD2)->D2_COD + "'"
cQuery += "     AND SDB.DB_LOCAL   = '" + (cAliasSD2)->D2_LOCAL + "'"
cQuery += "     AND SDB.DB_NUMSEQ  = '" + (cAliasSD2)->D2_NUMSEQ + "'"
cQuery += "     AND SDB.DB_DOC     = '" + (cAliasSD2)->D2_DOC + "'"
cQuery += "     AND SDB.DB_SERIE   = '" + (cAliasSD2)->D2_SERIE + "'"
cQuery += "     AND SDB.DB_CLIFOR  = '" + (cAliasSD2)->D2_CLIENTE + "'"
cQuery += "     AND SDB.DB_LOJA    = '" + (cAliasSD2)->D2_LOJA + "'"

cQuery := ChangeQuery( cQuery )
dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),cAliasTrb,.F.,.T.)

//-- Percorre a Query e adiciona o resultado no array de Retorno
(cAliasTrb)->( DbEval( {|| aAdd(aAux,{ (cAliasSD2)->D2_DOC, (cAliasSD2)->D2_SERIE, DB_PRODUTO, DB_LOCAL, DB_LOTECTL, DB_NUMLOTE, DB_NUMSERI, DB_LOCALIZ, DB_QUANT })  }))
(cAliasTrb)->( DbCloseArea() )

aEval( aAreas, { |xArea| RestArea(xArea) } )

Return Nil
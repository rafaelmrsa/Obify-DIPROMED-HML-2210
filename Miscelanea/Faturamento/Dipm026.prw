/*                                                     Sao Paulo, 22 Ago 2009
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDipm026() บ Autor ณJailton B Santos-JBSบ Data ณ 22/12/2009  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณEsta eh uma rotina executada apos a integracao dos CTRCs.   บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบObjetivo1 ณMostrar todos os CTRCs integrado em uma tela marca/desmarca,บฑฑ
ฑฑบ          ณonde o usuario podera  selecionar os CTRCs e gerar as res-  บฑฑ
ฑฑบ          ณpectivas notas fiscais de entrada.                          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบObjetivo2 ณGerar um relatorio contendo todos os CTRCs que nao atualiza-บฑฑ
ฑฑบ          ณram o SF2, devido a nota fiscal do CTRC ja possuir outro    บฑฑ
ฑฑบ          ณCTRC informado.                                             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ FAT - Dipromed                                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"       

User Function Dipm026()

Local oDlg  
Local oRadio
Local oMarcAll      
Local nOpc      := 0
Local lRet      := .T.
Local bCancel   := {|| nOpc:=1,oDlg:End()}
Local bOk       := {|| nOpc:=2,oDlg:End()}     

Private lMarcAll := .F.
Private nRadio  := 2
Private aSize   := MsAdvSize()
Private aInfo   := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 5, 5 }
Private aObjects:= { { 100, 100, .T., .T. } , { 200, 200, .T., .T. } }
Private aPosObj := MsObjSize( aInfo, aObjects,.T.)
Private lDipM026:= .T. // MCVN - 15/11/10    
Private cGeNFCTE:=GetNewPar("ES_DIPM026",'EELIAS/MCANUTO/LNUNES/RBORGES/LPEREIRA/RRODRIGUES/MAUGUSTO/DDOMINGOS/GNUNES/PALMEIDA/ASORANZ') 

If !(("01" $ cEmpAnt+cFIlAnt) .Or. ("04" $ cEmpAnt))
    Alert("Esta rotina s๓ estแ disponํvel para Dipromed-CD ou Health!")
	Return()
Endif

If !(Upper(U_DipUsr()) $ cGeNFCTE) // 'EELIAS/MCANUTO/LNUNES/RBORGES/LPEREIRA/RRODRIGUES/MAUGUSTO/DDOMINGOS/GNUNES/PALMEIDA/ASORANZ') // MCVN - 25/02/10
    Alert("Usuแrio sem autoriza็ใo para executar esta rotina!")
	Return()
End

Define MsDialog oDlg Title "CTRC(S) INTEGRADOS" from 0,0 to 150,250 of oMainWnd pixel  

@ 002,003 to 040,125 label 'Selecione' Of oDlg Pixel
@ 010,005 RADIO oRadio VAR nRadio Items 'Emitir Relatorio de CTRCs','Gerar Nota fiscal de Entrada ' size 120,08 of oDlg pixel
@ 055,040 Button OemToAnsi("&OK") size 40,15 pixel of oDlg action eval(bOk)
@ 055,085 Button OemToAnsi("&Sair")  size 40,15 pixel of oDlg action eval(bCancel)

Activate MsDialog oDlg Centered
                                                                        
If nOpc == 2
	Do Case
	Case nRadio == 1; fRelatorio()
	Case nRadio == 2; fGerarNFE()
	EndCase
EndIf

Return(lRet)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณfGerarNFE บ Autor ณJailton B Santos-JBSบ Data ณ 22/09/2009  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMonta uma tela para o usuario selecionar os CTRCs que desejaบฑฑ
ฑฑบ          ณgerar a nota fiscal de entrada.                             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ FAT - Dipromed                                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function fGerarNFE()

Local oDlg
Local _i   := 0
Local lRet := .T.
Local bCancel  := {|| oDlg:End()}
Local bOk      := {|| Processa({||fGrvNFE()},"Gerando a N.F.E. dos CTRCs marcados"),oDlg:End()}
Local aButtons := {} 
Local nTam     := 300	

Private cList
Private oList 
Private oVlrSelec
Private nVlrSelec:= 0       
Private aDados   := {}
Private cPerg    := Padr("DIPM026NFE",10)
Private oMarked	 := LoadBitmap(GetResources(),'LBOK')
Private oNoMarked:= LoadBitmap(GetResources(),'LBNO')

If (Alltrim(GetTheme()) <> "TEMAP10") .AND. !SetMdiChild()
	nTam := 375
EndIf

AAdd(aButtons, {"DBG10",{|| fLocaliza() },"Procurar" } )

//-----------------------------------------------------
// Cria o Grupo de Pergunta no SX1 e Questiona usuario                          
//-----------------------------------------------------
fAjustSX1('NFE')
If !Pergunte(cPerg, .T.)
    Return(.F.)
EndIf
//-----------------------------------------------------
// Le as informacoes importadas e cria a array de apre-
// sentacao no browse
//-----------------------------------------------------
If !fQuery('NFE')       
    Aviso('Aten็ใo','Nao encontrado dados que satisfacam aos parametros informados!',{'Ok'}) 
    If Select("TRB") > 0  // MCVN - 08/01/09
    	TRB->( DbCloseArea() )
	EndIf
    Return(.F.)
EndIf    

Define MsDialog oDlg Title "Gerando Nota Fiscal de Entrada" From 0,0 To aSize[6]-15,aSize[5]-15 of oMainWnd PIXEL 

@ 30,000 ListBox oList var cList Fields HEADER "","NR.CTRC","DT.EMISSAO","VAL.FRETE","VAL D FRETE","TIPO","BCICM","ALIQ ICMS","VAL ICMS","PEDAGIOS","PESO CTRC","RECNO"  ;
 size aSize[5]-392,aSize[6]-(nTam+80) of oDlg Pixel On DBLCLICK fMarca(oList)

oList:SetArray(aDados)
oList:bLine := {|| {Iif(aDados[oList:nAT,01],oMarked,oNoMarked),aDados[oList:nAt,2],aDados[oList:nAt,3],aDados[oList:nAt,4],aDados[oList:nAt,5],aDados[oList:nAt,6],aDados[oList:nAt,7],aDados[oList:nAt,8],aDados[oList:nAt,9],aDados[oList:nAt,10],aDados[oList:nAt,11],aDados[oList:nAt,12]}}

@ aSize[6]-(nTam+40),01 to aSize[6]-320,aSize[5]-680 Of oDlg Pixel
@ aSize[6]-(nTam+38),005 checkbox oMarcAll var lMarcAll PROMPT "Marca Todos os CTRCs" size 100,008 of oDlg on change fMarcAll(oList)
@ aSize[6]-(nTam+35),270 say 'Total Selecionando em R$ '  Size 70,08 color CLR_HBLUE Of oDlg Pixel
@ aSize[6]-(nTam+37),350 msget oVlrSelec var nVlrSelec  Picture "@ke 9,999,999.99" when .f. size 50,08 of oDlg pixel
 
Activate Dialog oDlg ON INIT EnchoiceBar(oDlg, bOk, bCancel,,aButtons)


Return(lRet)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณfMarca(X,Y)บAutor ณJailton B Santos-JBSบ Data ณ 22/12/2009  บฑฑ
ฑฑฬออออออออออุอออออออออออสออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Usada para fazer a inversao das marcacoes.                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณFAT - Dipromed                                              บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function fMarca()

Local i := 1 

aDados[oList:nAT,1] := !aDados[oList:nAT,1]		

If aDados[ oList:nAT, 1 ]
    nVlrSelec +=  Val(StrTran(StrTran(aDados[oList:nAT,4],'.',''),',','.'))
Else
    nVlrSelec -= Val(StrTran(StrTran(aDados[oList:nAT,4],'.',''),',','.'))
EndIf    

oList:Refresh()
oVlrSelec:Refresh()

Return( Nil ) 
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณfMarcAll()บAutor  ณJailton B Santos-JBSบ Data ณ 23/12/2009  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMarca ou Desmarca todos os CTRCs.                           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณFAT - Dipromed                                              บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function fMarcAll()

Local nId
Local cMarcaT := !aDados[oList:nAT,1]	 

nVlrSelec := 0

For nId :=1 to len(aDados)
     aDados[nId,1] := lMarcAll 
     If lMarcAll 
         nVlrSelec += Val(StrTran(StrTran(aDados[nId,4],'.',''),',','.'))
     EndIf    
Next nId
     
oList:Refresh()
oVlrSelec:Refresh()

Return(.T.)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณfQuery()   บAutor ณJailton B Santos-JBSบ Data ณ 22/12/2009  บฑฑ
ฑฑฬออออออออออุอออออออออออสออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc. 1:  ณQuery para trazer as informacoes para gerar as notas fiscaisบฑฑ
ฑฑบGera NFE  ณde entrada. Esta informacoes serao apresentadas no browse.  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบDesc. 2:  ณQuery para trazer as informacoes dos CTRCs em cujas notas   บฑฑ
ฑฑบImp. de   ณja possuiam outro CTRC apontado, esta informacao sera mos-  บฑฑ
ฑฑบRelatorio ณtrada em um relatorio especifico para isto.                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณFAT - Dipromed                                              บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function fQuery(cNome)     

Local lRet   := .F.
Local cQuery := ""

cQuery := " SELECT ZY_CTRC,ZY_DTEMIS,ZY_VALFRE,ZY_VALDFR,ZY_FRET,ZY_BCICM,ZY_AICM,ZY_ICM,ZY_PEDAGI,ZY_PESOCTR,R_E_C_N_O_,ZY_SERIE "
cQuery += "   FROM " + RetSQLName("SZY") + "  SZY " 
cQuery += " WHERE ZY_FILIAL = '" + xFilial('SZY') + "' "
cQuery += "   AND ZY_STATUS IN ('I') " 
cQuery += "   AND ZY_TRANSP IN ('" + AllTrim(MV_PAR01) + "') " 

If !Empty(MV_PAR02)
    cQuery += "   AND ZY_CTRC IN ('" + AllTrim(MV_PAR02) + "') " 
EndIf 

If cNome == 'RELATO' 
    cQuery += " AND ZY_TIPOREC IN ('R') " 
    cQuery += " AND ZY_DTEMIS BETWEEN '" + Dtos(MV_PAR03) + "' AND '" + Dtos(MV_PAR04) + "'"
EndIf            

cQuery += "   AND SZY.D_E_L_E_T_ <> '*' " 
cQuery += " ORDER BY ZY_DTEMIS,ZY_CTRC " 

If Select("TRB") > 0
    TRB->( DbCloseArea() )
EndIf    

DbCommitAll()
TCQUERY cQuery NEW ALIAS "TRB" 

TCSETFIELD("TRB","ZY_DTEMIS" , "D" , 08 , 00)
TCSETFIELD("TRB","ZY_DTEMIS" , "D" , 08 , 00)
TCSETFIELD("TRB","ZY_ICM"    , "N" , 14 , 02)
TCSETFIELD("TRB","ZY_AICM"   , "N" , 05 , 02)
TCSETFIELD("TRB","ZY_BCICM"  , "N" , 16 , 02)
TCSETFIELD("TRB","ZY_PEDAGI" , "N" , 16 , 02)
TCSETFIELD("TRB","ZY_VALFRE" , "N" , 16 , 02)
TCSETFIELD("TRB","ZY_VALDFR" , "N" , 16 , 02)
TCSETFIELD("TRB","ZY_PESOCTR", "N" , 08 , 02)

aDados := {}

lRet := !TRB->( BOF().and.EOF() )                
//--------------------------------------------------------
// Monta as colunas do Browse no array aDados com as 
// Informacoes lidas pela Query.                      
//--------------------------------------------------------
TRB->( DbGoTop() ) 

If cNome == 'RELATO'
   Return(lRet)
EndIf   

Do While TRB->( !EOF() )
	TRB->(AADD(aDados,{.F.,ZY_CTRC,ZY_DTEMIS,;
	                        Transform(ZY_VALFRE ,"@e 999,999,999,999.99"),;
	                        Transform(ZY_VALDFR ,"@e 999,999,999,999.99"),;
	                        ZY_FRET,;
	                        Transform(ZY_BCICM  ,"@e 999,999,999,999.99"),;
	                        Transform(ZY_AICM   ,"@e 99.99"),;
	                        Transform(ZY_ICM    ,"@e 999,999,999,999.99"),;
	                        Transform(ZY_PEDAGI ,"@e 999,999,999,999.99"),;
	                        Transform(ZY_PESOCTR,"@e 999,999,999.9999"),;
	                        R_E_C_N_O_}))
    TRB->( DbSkip() )
EndDo

Return(lRet)   
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณfGrvNFE() บ Autor ณJailton B Santos-JBSบ Data ณ 23/12/2009  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Gera a N.F.E. dos CTRCs selecionado pelo usuario atraves   บฑฑ
ฑฑบ          ณ da tela de browse apresentada. Gera apenas para os CTRCs   บฑฑ
ฑฑบ          ณ Marcados.                                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบOrgiem    ณ Funcao originada da funcao DIP19NFE(), dentro do programa  บฑฑ
ฑฑบ          ณ DIPM019.PRW   (Removida do mesmo), com autoria do MAximo   บฑฑ
ฑฑบ          ณ Canuto.                                                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ EDI - Dipromed                                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function fGrvNFE()

Local lRet    := .F.  // Controla se gerou alguma nota: Sim ou Nao.
Local xAlias  := GetArea()  
Local cFilSA2 := xFilial('SA2')                                                  
//--------------------------------------------------------------------------------
// Bloco de codigo para avaliar o fornecedor e determinar a condicao de pagamento.
//--------------------------------------------------------------------------------
Local bPagto  := {|REMETENTE| If('PATRUS' $ REMETENTE,"453",If('IMOLA' $ REMETENTE,"452","451"))}
Local aNfeCab := {}  // Informacoes para o cabecario da nota
Local aNfeIte := {}  // Informacoes para os itens da nota
Local nTotNota:= 0   // Contador de Notas fiscais geradas
Local nTotMarc:= 0   // Contador de CTRCs marcados
Local cSerNfe := ""

aEval(aDados,{|x| If(x[1],nTotMarc++,)}) // Contar CTRCs marcados
ProcRegua(nTotMarc) 

For nId := 1 To Len(aDados)
	
	Begin Sequence
	//--------------------------------------------------------------
    // Se o CTRC nao estiver marcado pula para o Proximo
	//--------------------------------------------------------------
	If !aDados[nId][1]
		Break 
	EndIf                                  
	IncProc()
	//--------------------------------------------------------------
    // Posiciona a tabela SZY no CTRC marcado pelo usuario
	//--------------------------------------------------------------
	SZY->(DbGoTo(aDados[nId][12]))
	//--------------------------------------------------------------
    // Posiciona no Fornecedor atraves do CNPJ
	//--------------------------------------------------------------
	SA2->( DbSetOrder(3) )
	SA2->( DbSeek(cFilSA2+SZY->ZY_CGC) )
	lMsErroAuto := .F.
	If cEmpAnt+cFilAnt == "0401" 
		cSerNfe := If(SZY->ZY_TRANSP == '000150',"",If(SZY->ZY_TRANSP == '000905','1',If(SZY->ZY_TRANSP == '003025','2',SZY->ZY_SERIE))) 	// RBORGES 24/07/2014
	Else
		cSerNfe := If(SZY->ZY_TRANSP == '000150',"U",If(SZY->ZY_TRANSP == '000905','UNI',If(SZY->ZY_TRANSP == '003025','2',If(SZY->ZY_TRANSP == '002179','1',SZY->ZY_SERIE)))) 	// S้rie da Nf de entrada deve ser U para Braspress MCVN 22/10/10 //  S้rie da Nf de entrada deve ser U1 para Braspress MCVN 11/08/11
	EndIf		

	//--------------------------------------------------------------
	// Cabecalho NF Entrada
	//--------------------------------------------------------------
	aNfeCAB := {{"F1_TIPO"    , "N"            , Nil},;
	            {"F1_FORMUL"  , "N"            , Nil},;
	            {"F1_DOC"     , SZY->ZY_CTRC   , Nil},;
	            {"F1_SERIE"   , cSerNfe        , Nil},;
	            {"F1_EMISSAO" , SZY->ZY_DTEMIS , Nil},;
	            {"F1_FORNECE" , SA2->A2_COD    , Nil},;
	            {"F1_LOJA"    , SA2->A2_LOJA   , Nil},;
	            {"F1_ESPECIE" , "CTR"          , Nil},;
	            {"F1_COND"    , Eval(bPagto,SZY->ZY_REMETE), Nil}}
                                                                                                          
	//--------------------------------------------------------------
    // Item NF Entrada
	//--------------------------------------------------------------
	aNfeITE := {}
	AAdd(aNfeIte,{{"D1_COD"     , "ST0001",	NIL},;
	              {"D1_QUANT"   , 1       ,NIL},;
	              {"D1_VUNIT"   , SZY->ZY_VALFRE , NIL},;
	              {"D1_TOTAL"   , SZY->ZY_VALFRE , NIL},;
	              {"D1_TES"     , IIf(SZY->ZY_ICM == 0,'245',IIf(cEmpAnt=="04","258",'244')), NIL},;
	              {"D1_VALICM"  , SZY->ZY_ICM    , NIL},;
	              {"D1_PICM"    , SZY->ZY_AICM   , NIL},;
	              {"D1_BASEICM" , SZY->ZY_BCICM  , NIL} } )
		
	//--------------------------------------------------------------
	// Gera a Nota fiscal de Entrada
	//--------------------------------------------------------------
	MSExecAuto({|x,y,z| Mata103(x,y,z)},aNfeCab,aNfeIte,3)	
	//--------------------------------------------------------------
	// Se ocorreu erro na geracao da nota fiscal sai do laco sem 
	// alterar o SZY, ficando com o mesmo status anterior.
	//--------------------------------------------------------------
	If lMsErroAuto
	   MostraErro()
	   Break
	Endif
	//--------------------------------------------------------------
    // Registra os dados da Nota fiscal Gerada e o novo status
    // do CTRC na Tabela "SZY"  
	//--------------------------------------------------------------
    SZY->( RecLock('SZY', .F.) )
    SZY->ZY_STATUS := 'G' // 'I' -> Integrado, 'G' -> Gerado NFE
    SZY->ZY_DOCENT := SF1->F1_DOC
    SZY->ZY_SERENT := SF1->F1_SERIE
    SZY->ZY_EMIENT := SF1->F1_DTDIGIT
    SZY->ZY_FORENT := SA2->A2_COD
    SZY->ZY_LOJENT := SA2->A2_LOJA
    SZY->(MsUnLock('SZY'))             
	//--------------------------------------------------------------
    // Determina que conseguiu gerar NFEs
	//--------------------------------------------------------------
    lRet := .T.                                
    nTotNota++ 
    End Sequence

Next nId 
If lRet 
    Aviso('Sucesso',StrZero(nTotNota,4)+'/'+StrZero(nTotMarc,4)+' CTRCs Gerados Notas Fiscais de Entrada.' ,{'OK'})
Else
    Aviso('Aten็ใo','Sem Notas Geradas.',{'OK'})
EndIf
RestArea(xAlias)

Return(lRet)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณfAjustSX1()บAutor ณJailton B Santos-JBSบ Data ณ 22/12/2009  บฑฑ
ฑฑฬออออออออออุอออออออออออสออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณCria o Grupo de Perguntas no SX1                            บฑฑ
ฑฑบ          ณParametro -> 'NFE' Apenas transportadora e CTRC             บฑฑ
ฑฑบ          ณ          -> 'RELATO' Acrescenta emissao de ate...          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณFAT - Dipromed                                              บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function fAjustSX1(cNome)

Local nId_SX1
Local aRegs	:= {}
Local aArea := GetArea()
Local lRet  := .T.
                   
AAdd(aRegs,{"01","Codigo da Transportadora","mv_ch1","C",06,0,0,"G","mv_par01","" ,"" ,"","SA4"})
AAdd(aRegs,{"02","Numero do Conhecimento  ","mv_ch2","C",09,0,0,"G","mv_par02","" ,"" ,"",""}) //Giovani Zago 21/11/11

If cNome == 'RELATO'
    AAdd(aRegs,{"03","Emissao de              ","mv_ch3","D",08,0,0,"G","mv_par03","" ,"" ,"",""})
    AAdd(aRegs,{"04","Emissao ate             ","mv_ch4","D",08,0,0,"G","mv_par04","" ,"" ,"",""})
EndIf

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
		SX1->X1_F3      := aRegs[nId_SX1][13]
	
		MsUnlock()
	
	Endif
Next nId_SX1

RestArea(aArea)

Return(lRet)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณfLocaliza()บAutor ณJailton B Santos-JBSบ Data ณ 30/12/2009  บฑฑ
ฑฑฬออออออออออุอออออออออออสออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao desenvolvida para localizar CTRC na tela de selecao  บฑฑ
ฑฑบ          ณpara gerar Nota Fiscal de Entrada.                          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณFAT - Dipromed                                              บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function fLocaliza()

Local oDlg      
Local nOpc    := 0    
Local nPos    := 0
Local lRet    := .T. 
Local bCancel := {|| nOpc:=1,oDlg:End()}
Local bOk     := {|| nOpc:=2,oDlg:End()}

Private cCtrc := Space(len(SZY->ZY_CTRC))

Define MsDialog oDlg Title "Localizando CTRC" from 0,0 to 150,250 of oMainWnd pixel  

@ 002,003 to 040,125 Of oDlg Pixel
@ 15,005 say "Numero do CTRC"   size 70,08 of oDlg pixel
@ 15,070 msget oCtrc  var cCtrc size 50,08 of oDlg pixel

@ 55,040 Button OemToAnsi("Localizar") size 40,15 pixel of oDlg action eval(bOk)
@ 55,085 Button OemToAnsi("Fechar")    size 40,15 pixel of oDlg action eval(bCancel)

Activate MsDialog oDlg Centered

If nOpc == 2
	If Empty(cCtrc)
		oList:nAt := 1   // Posiciona no primeiro CTRC da Tela
		oList:Refresh()
	ElseIf ( nPos := Ascan(aDados,{|x| SubStr(x[2],1,len(AllTrim(cCtrc))) == AllTrim(cCtrc)})) > 0
		oList:nAt := nPos // Posciona no CTRC informado pelo usuario
		oList:Refresh()
	Else
		Aviso('Aten็ใo','CTRC nใo encontrado na listagem',{'Ok'})
		lRet := .F.
	EndIf
EndIf

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณfRelatorioบ Autor ณJailton B Santos-JBSบ Data ณ 22/09/2009  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณGera um relatorio contendo todos os CTRCs que nao atualiza- บฑฑ
ฑฑบ          ณo SF2, devido a NF possuir outro CTRC informado.            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ FAT - Dipromed                                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function fRelatorio()

Local nLin         := 80
Local lRet         := .T. 
Local cDesc1       := "Este programa tem como objetivo imprimir relatorio "
Local cDesc2       := "de acordo com os parametros informados pelo usuario."
Local cDesc3       := "CTRCs que possuem notas que ja possuem CTRC informado."
Local cPict        := ""
Local titulo       := "CTRCs Nao Atualizados"

Local Cabec1       := ""
Local Cabec2       := ""
Local imprime      := .T.
Local aOrd         := {}
Local cQuery       := ""

Private cPerg      := Padr("DIPM026CTR",10)
Private lEnd       := .F.
Private lAbortPrint:= .F.
Private CbTxt      := ""
Private limite     := 132
Private tamanho    := "M"
Private nomeprog   := "DIPM026CTR" 
Private nTipo      := 15
Private aReturn    := { "Zebrado", 1, "Administracao", 1, 2, 1, "", 1}
Private nLastKey   := 0
Private cbtxt      := Space(10)
Private cbcont     := 00
Private CONTFL     := 01
Private m_pag      := 01
Private wnrel      := "DIPM026CTR" 

Private cString := "SZY"

fAjustSX1('RELATO')

If Pergunte(cPerg,.t.) 

    If fQuery('RELATO')
	
		wnrel := SetPrint(cString,NomeProg,"",@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)
		
		If nLastKey == 27
			Return
		Endif
		
		SetDefault(aReturn,cString)
		
		If nLastKey == 27
			Return
		Endif
		
		nTipo := If(aReturn[4]==1,15,18)
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ Processamento. RPTSTATUS monta janela com a regua de processamento. ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		RptStatus({|| fReport(Cabec1,Cabec2,Titulo,nLin) },Titulo)
	    TRB->( DbCloseArea() )
	EndIf
EndIf             

Return(lRet)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณfReport() บAutor  ณJailton B Santos-JBSบ Data ณ 04/01/2010  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao desenvolvida para imprimir o relatorio de acordo com บฑฑ
ฑฑบ          ณos dados filtrados na query.                                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณFAT - Dipromed                                              บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function fReport(Cabec1,Cabec2,Titulo,nLin)

Local nOrdem
Local mCtrcGR
Local nId     := 0
Local nMlCt   := 0
Local nTamLin := 125

nLin := 80

TRB->( DbGotop() )

Do While TRB->( !EOF() )
	
	SZY->(DbGoTo(TRB->R_E_C_N_O_))
	
	Begin Sequence
	
	mCtrcGR := SZY->ZY_CtrcGR
	
	nMlCt := MlCount (mCtrcGR, nTamLin)
	
	If nMlCt == 0
		Break
	EndIf
	
	SA4->(DbSetOrder(1))
	SA4->(DbSeek( xFilial('SA4') + SZY->ZY_TRANSP))
	
	For nId := 1 to nMlCt
		
		If nLin > 60
		    fCabec(@nLin,Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
		    cLinha :=  MemoLine (mCtrcGR, nTamLin, nId)
		    @ nLin,00 psay SubStr(cLinha,1,11) + SubStr(cLinha,20)
		    nLin++                                                 
		    cLinha :=  MemoLine (mCtrcGR, nTamLin, nId+1)
		    @ nLin,00 psay SubStr(cLinha,1,11) + SubStr(cLinha,20)
		    nLin++                                                 
		EndIf
		
		If nId > 2
		   cLinha :=  MemoLine (mCtrcGR, nTamLin, nId)
		   @ nLin,00 psay SubStr(cLinha,1,11) + SubStr(cLinha,20)
		   nLin++                                                 
		EndIf
		
	Next nId
	
	End Sequence
    
    TRB->( DbSkip() )

EndDo
    
Set Device To Screen

If aReturn[5]==1
   dbCommitAll()
   Set Printer To
   OurSpool(wnrel)
Endif

MS_FLUSH()

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณfCabec()  บAutor  ณJailton B Santos-JBSบ Data ณ 04/01/2010  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao desenvolvida para imprimir o cabecario do relatorio  บฑฑ
ฑฑบ          ณde CTRCs sem gravacao no SF2.                               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณFAT - Dipromed                                              บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function fCabec(nLin,Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)

Local lRet := .T.

If nLin > 60
	
	// 0         10        20        30        40        50        60        70        80        90        100       110       120       130
	// 0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012
	// CTRC..........: XXXXXX   Emissao: XX/XX/XXXX   
	// Transportadora: XXXXXX-XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
	
	Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
	
	nLin := 6 
    
    @ nLin, 000 psay 'Transportadora.: ' + SZY->ZY_TRANSP + ' - ' + SA4->A4_NOME
    nLin++
	 
EndIf
	
@ nLin, 000 psay 'CTRC...........: ' + SZY->ZY_CTRC   + '          Emissao......: ' + dToc(SZY->ZY_DTEMIS) + '    Valor..:' + Transform(SZY->ZY_VALFRE,"@e 999,999,999.99")
nLin+=2

Return(lRet)

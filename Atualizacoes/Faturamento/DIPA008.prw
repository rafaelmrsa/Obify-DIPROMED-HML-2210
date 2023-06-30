#INCLUDE "Fivewin.ch"
#INCLUDE "Font.ch"
#include "vKey.ch"     
#INCLUDE "Colors.ch"
#include "Protheus.ch"
#include "RwMake.ch"
#include "vKey.ch"     

/*====================================================================================\
|Programa  | DIPA008       | Autor | Alexandro Dias             | Data | 29/01/2002   |
|=====================================================================================|
|Descri็ใo | Ativa tecla F5 para mostra as caracteristica do produto e chama          |
|          | a rotina padrao do Siga MATA010().                                       |
|          |                                                                          |
|=====================================================================================|
|Sintaxe   | DIPA008                                                                  |
|=====================================================================================|
|Uso       | Especifico DIPROMED                                                      |
|=====================================================================================|
|........................................Hist๓rico....................................|
|Rafael    | DD/MM/AA - Descri็ใo                                                     |
|Eriberto  | DD/MM/AA - Descri็ใo                                                     |
\====================================================================================*/

User Function DIPA008() 

Private cUsrDIP008 :=  GetMV("MV_DIPA008")// MCVN - 13/11/09      
Private cUserLic   := GetNewPar("ES_D008LIC","FBESSA/DARRUDA/PMENDONCA") //15/10/2014 MCVN

SETFUNNAME("MATA010")

U_DIPPROC(ProcName(0),U_DipUsr()) // JBS 05/10/2005 - Gravando o nome do Programa no SZU
                                                                                                     
//If cEmpAnt =='01'   // RBORGES 05/04/17 - Comentado, pois a consulta consolidada serแ para as duas empresas                       
	SetKey(VK_F5,{|| Iif(MsgBox("Deseja visualizar os dados CONSOLIDADOS do produto ?","Atencao","YESNO"),U_DIPA004C(),U_DIPA004())})
//Else                                                                                                                                 
//	SetKey(VK_F5,{|| U_DIPA004()})
//Endif

MsgBox("Utilize a Tecla F5 para consultar"+Chr(13)+Chr(13)+"as Caracteristicas do Produto !!!","Informacao.","INFO")
    
//Set Key VK_F6 TO U_VIEWSIAFISICO()   

IF UPPER(U_DipUsr()) $ cUsrDIP008 //MCVN 12/12/06 -  Definindo usuแrio com acessso a essa rotina.
	SetKey(VK_F10,{|| U_DIPA036("SB1")})
EndIf
	
IF UPPER(U_DipUsr()) $ cUsrDIP008 .Or. cModulo == "COM" // 17/03/09 -  Definindo usuแrio com acessso a essa rotina.
	SetKey(VK_F8,{|| U_CALC_PV()})
EndIf

IF  cModulo == "COM" //MCVN 12/12/06 -  Definindo usuแrio com acessso a essa rotina.
	
	
	If cEmpAnt <> "04"
	
		If u_DipMonTmp(nil,nil,.T.)
			Aviso("Aten็ใo","Existem produtos com o perํodo de promo็ใo VENCIDOS ou A VENCER at้ a data: "+DtoC(DataValida(dDataBase+1,.T.))+"!",{"Ok"},2)
		EndIf
   
		cParcial := MsgBox("Deseja acessar a rotina de manuten็ใo do Perํodo de Promo็ใo ?","Atencao","YESNO")
       
		IF cParcial = .T.
    		 Dpprom() // MCVN - Rotina de altera็ใo/inclusใo de Perํodo de Promo็ใo no cadastro de Produtos.
    	ENDIF
    EndIf 

ENDIF

DbSelectArea("SB1")

If  cModulo <> "COM" .And. cEmpAnt == "04" // RBorges - 08/10/2015 - Filtrar produtos com descri็ใo diferente de Z nos modulos, exceto compras.
	
	If cModulo == "FAT"                                                                                                               
	  	Set Filter To (Substr(B1_DESC,1,1) <> "Z") .And. (Substr(B1_COD,1,1) <> "6") .And. (Substr(B1_COD,1,1) <> "7") .And. (Substr(B1_COD,1,1) <> "8")	 //RBorges 08/04/16 - Adicionado o filtro para os PIดs
			MATA010() // Fun็ใo padrใo do Microsiga - Cadastro de Produtos                                                                                   //RBorges 06/09/19 - Adicionado o filtro para MPดs e BNดs    
		Set Filter To
	Else
		Set Filter To (Substr(B1_DESC,1,1) <> "Z")	 //RBorges 08/04/16 - Adicionado o filtro para os PIดs
			MATA010() // Fun็ใo padrใo do Microsiga - Cadastro de Produtos
		Set Filter To
	EndIf
		
Else
	
	MATA010() // Fun็ใo padrใo do Microsiga - Cadastro de Produtos
	
EndIf


SET KEY VK_F5 TO
//SET KEY VK_F6 TO
SET KEY VK_F8 TO
SET KEY VK_F10 TO

Return(.T.) 
/*
-------------------------------------------------------------------------------------
Empresa.......: DIPOMED Com้rcio e Importa็ใo Ltda.
Fun็ใo........: DppProm()
Objetivo......: Mostra produtos com perํodo de promo็ใo vencido e possibilita a exclusใo,
                inclusใo e altera็ใo do Perํodo.
Autor.........: Maximo Canuto Vieira Neto   -  MCVN
Data..........: 08/12/06
Considera็oes.: Fun็ใo chamada pelo DIPA008>PRW 
-------------------------------------------------------------------------------------
*/
Static Function Dpprom() //Fun็ใo para visualiza็ใo/altera็ใo de Periodos Vencidos.

Local _xAlias		:= GetArea()
Local oTempTable
PRIVATE dDtAtual	:= date()
PRIVATE aRotina		:= {{ "Pesquisa"		,'U_DipPesqB8()'		, 0 , 1},;                          
                      	{ "Exclui"		,"U_DIPA034('EXCLUI')"  , 0 , 3},; 
                      	{ "Altera Perํodo","U_DIPA034('ALTERA')" 	, 0 , 2},;
                      	{ "Filtra Forn"	,"U_DipFilSB1()" 		, 0 , 3},;
                      	{ "Inclui"		,"U_DpProm2()" 			, 0 , 3}}
PRIVATE   ALTERA := .T. // MCVN - 22/07/10
PRIVATE   INCLUI := .F. // MCVN - 22/07/10

U_DIPPROC(ProcName(0),U_DipUsr()) // JBS 05/10/2005 - Gravando o nome do Programa no SZU

//dbSelectArea("SB1") // Somente para ter uma alias aberto.
//ณ Define o cabecalho da tela de atualizacoes               ณ
cCadastro := "Listando produtos com perํodo de promo็ใo Vencido"

aStrut := {}

/*
AADD(aStrut,{"B1_OK2"    ,"C",AvSx3("B1_OK2"    ,3) }) 
AADD(aStrut,{"B1_COD"    ,"C",AvSx3("B1_COD"    ,3) })
AADD(aStrut,{"B1_DESC"   ,"C",AvSx3("B1_DESC"   ,3) })
AADD(aStrut,{"B1_PROC"   ,"C",AvSx3("B1_PROC"   ,3) })
AADD(aStrut,{"B1_PERPROM","C",AvSx3("B1_PERPROM",3) })
AADD(aStrut,{"B1_PRV1"   ,"N",AvSx3("B1_PRV1"   ,3) })
AADD(aStrut,{"B1_PRVSUPE","N",AvSx3("B1_PRVSUPE",3) })
AADD(aStrut,{"B1_PRVMINI","N",AvSx3("B1_PRVMINI",3) })
AADD(aStrut,{"B1_PRVPROM","N",AvSx3("B1_PRVPROM",3) })
AADD(aStrut,{"B1_NPROMOC","C",AvSx3("B1_NPROMOC",3) })
AADD(aStrut,{"B1_MOSTPRO","C",AvSx3("B1_MOSTPRO",3) })
*/

AADD(aStrut,{"B1_OK2"    ,"C",GetSx3Cache("B1_OK2","X3_TAMANHO"),GetSx3Cache("B1_OK2","X3_DECIMAL") }) 
AADD(aStrut,{"B1_COD"    ,"C",GetSx3Cache("B1_COD","X3_TAMANHO"),GetSx3Cache("B1_COD","X3_DECIMAL") })
AADD(aStrut,{"B1_DESC"   ,"C",GetSx3Cache("B1_DESC","X3_TAMANHO"),GetSx3Cache("B1_DESC","X3_DECIMAL") })
AADD(aStrut,{"B1_PROC"   ,"C",GetSx3Cache("B1_PROC","X3_TAMANHO"),GetSx3Cache("B1_PROC","X3_DECIMAL") })
AADD(aStrut,{"B1_PERPROM","C",GetSx3Cache("B1_PERPROM","X3_TAMANHO"),GetSx3Cache("B1_PERPROM","X3_DECIMAL") })
AADD(aStrut,{"B1_PRV1"   ,"N",GetSx3Cache("B1_PRV1","X3_TAMANHO"),GetSx3Cache("B1_PRV1","X3_DECIMAL")})
AADD(aStrut,{"B1_PRVSUPE","N",GetSx3Cache("B1_PRVSUPE","X3_TAMANHO"),GetSx3Cache("B1_PRVSUPE","X3_DECIMAL") })
AADD(aStrut,{"B1_PRVMINI","N",GetSx3Cache("B1_PRVMINI","X3_TAMANHO"),GetSx3Cache("B1_PRVMINI","X3_DECIMAL") })
AADD(aStrut,{"B1_PRVPROM","N",GetSx3Cache("B1_PRVPROM","X3_TAMANHO"),GetSx3Cache("B1_PRVPROM","X3_DECIMAL") })
AADD(aStrut,{"B1_NPROMOC","C",GetSx3Cache("B1_NPROMOC","X3_TAMANHO"),GetSx3Cache("B1_NPROMOC","X3_DECIMAL") })
AADD(aStrut,{"B1_MOSTPRO","C",GetSx3Cache("B1_MOSTPRO","X3_TAMANHO"),GetSx3Cache("B1_MOSTPRO","X3_DECIMAL") })


// cria a tabela temporแria              
/*
cTRB := CriaTrab(aStrut, .T.)
dbUseArea(.T.,,cTRB,"TRBSB1")
*/
If(oTempTable <> NIL)
	oTempTable:Delete()
	oTempTable := NIL
EndIf
oTempTable := FWTemporaryTable():New("TRBSB1")
oTempTable:SetFields(aStrut)
oTempTable:AddIndex("1", {"B1_COD"} )
oTempTable:Create()

U_DipMonTmp()             

aCampos  := {}     	    
AADD(aCampos,{"B1_OK2"    , "" ,"" 						, }) 
AADD(aCampos,{"B1_COD"    , "" ,"Codigo"    			, })
AADD(aCampos,{"B1_DESC"   , "" ,"Descricao" 			, })
AADD(aCampos,{"B1_PROC"   , "" ,"Fornecedor" 			, })
AADD(aCampos,{"B1_PERPROM", "" ,"Perํodo Promocional" 	, })
AADD(aCampos,{"B1_PRV1"   , "" ,"Preco Lista "			, AvSx3("B1_PRV1",6) 	})
AADD(aCampos,{"B1_PRVSUPE", "" ,"Promocao    "			, AvSx3("B1_PRVSUPE",6) })
AADD(aCampos,{"B1_PRVMINI", "" ,"C"           			, AvSx3("B1_PRVMINI",6) })
AADD(aCampos,{"B1_PRVPROM", "" ,"D"           			, AvSx3("B1_PRVPROM",6) })
AADD(aCampos,{"B1_NPROMOC", "" ,"Nome da Promo็ใo"		, AvSx3("B1_NPROMOC",6) })
AADD(aCampos,{"B1_MOSTPRO", "" ,"Mostra Promo็ใo?"  	, AvSx3("B1_MOSTPRO",6) })


dbSelectArea("TRBSB1")
TRBSB1->(dbGoTop())

/*
cIndTRB := CriaTrab(Nil,.F.)

TRBSB1->(DbCreateIndex(cIndTRB,"B1_DESC" ,{|| B1_DESC },.F.))
TRBSB1->(DbClearInd())
TRBSB1->(DbSetIndex(cIndTRB))
*/
TRBSB1->(DbSetOrder(1))

 
cMarca := GetMark()
MarkBrow("TRBSB1","B1_OK2",,aCampos,,cMarca,"U_DipMarkAll()")

TRBSB1->(dbCloseArea()) 
oTempTable:Delete()
RestArea(_xAlias)

Return   
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบPrograma  ณ DppProm2 บ Autor ณ Maximo Canuto   บ Data ณ 11/12/2006     บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Altera e Inclui novo Perํodo de Promo็ใo no B1_PERPROM     บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function Dpprom2() // Fun็ใo para altera็ใo/inclusใo de perํodo de promo็ใo.
Local cFornece	 := ""
  
U_DIPPROC(ProcName(0),U_DipUsr()) // JBS 05/10/2005 - Gravando o nome do Programa no SZU

cFornece 	:= U_DipTelFor()
U_DipMonTmp(cFornece,.T.)  

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบPrograma  ณ LimpaPProm บ Autor ณ Maximo Canuto   บ Data ณ 11/12/2006   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Limpa conte๚do do campo B1_PERPROM                         บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function LimPProm() //Limpa Periodo de Promo็ใo
Local _cAliasSB1 := SB1->(GetArea())

Processa({|| Limpapp()},'Tirando produtos marcados do Perํodo de Promo็ใo...')

RestArea(_cAliasSB1)

Return()                                                                     

/////////////////////////////////////////////////////////////////////////////
Static Function Limpapp()
_cAliasSB1 := SB1->(GetArea()) 
//SB1->(DbSetOrder(10))
SB1->(DbOrderNickName("B1MARCPRO"))
   If SB1->(DbSeek(xFilial("SB1")+cMarca))

     IF !EMPTY(cMarca)
		Dbselectarea("SB1")
		//DbSetOrder(10)
		SB1->(DbOrderNickName("B1MARCPRO"))
		ProcRegua(SB1->(RECCOUNT()))
	
		SB1->(DbSeek(xFilial("SB1")+cMarca))
	
	    	While !SB1->(Eof()) .AND. cMarca == SB1->B1_OK2
	   	    	IncProc(AllTrim(SB1->B1_COD)+'-'+SubSTR(SB1->B1_DESC,30))
	   		    RecLock("SB1",.F.)
	      	    SB1->B1_PERPROM := ""
//                SB1->B1_OK2 := ''   
                SB1->B1_NPROMOC := ""
                SB1->B1_MOSTPRO := "" 
                SB1->(MsUnlock())
	   		    Dbselectarea("SB1")
			    SB1->(DbSkip())
		    ENDDO 
     ENDIF
  Else   
     MsgInfo('Por favor selecione uma ou mais produtos para tirar do Perํodo de promo็ใo','Aten็ใo')  
  EndIf 
 RestArea(_cAliasSB1)
Return()


////////////////////////////
User Function CALC_PV()
Local nOpcao   := 0
Local lUserLic := (Upper(U_DipUsr())$cUserLic)
/*
Local nICMSE   := Iif(Posicione("SA2",1,xFilial('SA2')+SB1->B1_PROC+SB1->B1_LOJPROC,"A2_EST")='SP',SB1->B1_PICM,12)
Local nICMSS   := SB1->B1_PICM
Local nIPI     := SB1->B1_IPI
Local nIVA     := SB1->B1_PICMENT
Local nCusto   := SB1->B1_LISFOR
Local nST      := nPVC*nICMSS/100 - nCusto*nICMSE/100
Local nTCusto  := nCusto + nST
Local nAcresci := Posicione("SA2",1,xFilial('SA2')+SB1->B1_PROC+SB1->B1_LOJPROC,"A2_ACRESCI")
Local nDescont := Posicione("SA2",1,xFilial('SA2')+SB1->B1_PROC+SB1->B1_LOJPROC,"A2_DESCONT")
Local nRedICMS := Posicione("SF4",1,xFilial('SF4')+SB1->B1_TE,"F4_BASEICM")
Local nMargem  := (nPVC/nTCusto-1)*100
Local nAmerica := Iif(SB1->B1_PROC='000630',4,0)
Local nPPis    := 1.65
Local nVPis    := nPPis/100 * ( nPVC -(nCusto + nCusto*nIPI/100) )
Local nPCofins := 7.6
Local nVCofins := nPCofins/100 * ( nPVC -(nCusto + nCusto*nIPI/100) )
Local nPComissao:=2
Local nVComissao:= nPComissao/100 * nPVC
Local nPFrete  := 2.5
Local nVFrete  := nPFrete/100 * nPVC
Local nVCusto  := nCusto + nVPis + nVCofins + nVComissao + nVFrete
*/
Local nPVL       := 0
Local nPVD       := 0
Local nPVC       := 0
Local nPAmerica  := 0
Local nVAmerica  := 0
Local nVCompra   := 0
Local nPCompra   := 0
Local nPRedICMS  := 0
Local nVRedICMS  := 0
Local nPICMSE    := 0
Local nVICMSE    := 0
Local nPDifICMSE := 0
Local nVDifICMSE := 0
Local nPIPI      := 0
Local nVIPI      := 0
Local nPICMSS    := 0
Local nPIVA      := 0
Local nVIVA      := 0
Local nVICMSS    := 0
Local nVST       := 0
Local nPST       := 0
Local nPAcresci  := 0
Local nVAcresci  := 0
Local nPDescont  := 0
Local nVDescont  := 0
Local nPBoni1    := 0
Local nVBoni1    := 0
Local nPBoni2    := 0
Local nVBoni2    := 0
Local nVCusto    := 0
Local nPCusto    := 0
Local nPMargem   := 0
Local nVMargem   := 0
Local nPICMS     := 0
Local nVICMS     := 0
Local nPPis      := 1.65
Local nVPis      := 0
Local nPCofins   := 7.6
Local nVCofins   := 0
Local nPComissao := 2
Local nVComissao := 0
Local nPFrete    := 2.5
Local nVFrete    := 0
Local nVTCusto 	 := 0
Local nPTCusto 	 := 0
Local nPMargemL  := 0
Local nVMargemL  := 0
Local nVPromo  	 := 0
Local nPPromo    := 0
Local nNewPVL    := 0
Local nNewPVD    := 0
Local nNewPVC    := 0   
Local nAjusPVC   := 0 
Local cPerProm   := ""

Local aEnv_Pro := {}
Local lSaida   := .F.
Local lAtuProm := .F.   
Local lPerProm := .F.
Local cEmail   := "felipe.duran@dipromed.com.br"//"erich.pontoldio@dipromed.com.br;patricia.mendonca@dipromed.com.br"
Local cAssunto := ""
Local cTitCic  := ""
Local cAssCic  := ""  
Local lOldAlter:= .F.   
Local lReplPrc := .T.    
Local nAtuPrc  := 0

If Type("TRBSB1->B1_COD") <> "U"
	SB1->(dbSetOrder(1))
	If !SB1->(dbSeek(xFilial("SB1")+TRBSB1->B1_COD))
		Return(.T.)
	EndIf
EndIf

Private M->B1_PRV1 := M->B1_PRVPROM := M->B1_PRVMINI := M->B1_PRVSUPE := M->B1_LISFOR := 0
Private M->B1_ALTPREC := M->B1_DTLISFO := dDATABASE
Private nVar := 0    
Private cObsAltPro:= ""   
                          
If  !lUserLic .And. !('MATA010'$FUNNAME())
	Aviso('Aten็ใo',"Usuแrio sem autoriza็ใo para executar esta rotina!",{'Ok'}) 
	Return()                                                                                       
EndIf                          

nPVL       	:= SB1->B1_PRV1
nPVD       	:= SB1->B1_PRVPROM
nPVC       	:= SB1->B1_PRVMINI
nPAmerica  	:= Iif(SB1->B1_PROC='000630',0,0) // Desconto de America (4%) foi desativado em 121/05/11 (Solicitado pela Rose gerente de compras) - 12/05/11
nVAmerica  	:= nPAmerica/100 * SB1->B1_UPRC
nVCompra   	:= Iif(SB1->B1_PROC $ '000996/000997', SB1->B1_CUSDIP - nVAmerica ,SB1->B1_UPRC - nVAmerica)
nPCompra   	:= (1-(nPVC/nVCompra-1))*100
nPRedICMS  	:= Posicione("SF4",1,xFilial('SF4')+SB1->B1_TE,"F4_BASEICM")
nVRedICMS  	:= nPRedICMS/100 * (nVCompra) //-nVAmerica)
nPICMSE    	:= Iif(Posicione("SA2",1,xFilial('SA2')+SB1->B1_PROC+SB1->B1_LOJPROC,"A2_OPTSIMP")='2',SB1->B1_PICM_SN,Iif(SB1->B1_PICM == 0,0,Iif(SA2->A2_EST$'SP/EX',SB1->B1_PICM,IIf(SB1->B1_ORIGEM$'1/2/3/8',4,12))))
nVICMSE    	:= nPICMSE/100 * Iif(nVRedICMS<>0,nVRedICMS,nVCompra) //-nVAmericA)
//nPDifICMSE  := Iif(nPICMSE==4 .Or. (nPICMSE<>SB1->B1_PICM .And. Posicione("SA2",1,xFilial('SA2')+SB1->B1_PROC+SB1->B1_LOJPROC,"A2_OPTSIMP")='2'),SB1->B1_PICM - nPICMSE,0) // Diferen็a de ICMS para produtos importados com aliquota de 4% 
nPDifICMSE  := Iif(nPICMSE<>SB1->B1_PICM .And. SB1->B1_PICMENT=0,SB1->B1_PICM - nPICMSE,0) // Toda diferen็a de ICMS ้ considerada no custo
nVDifICMSE  := nPDifICMSE/100 * Iif(nVRedICMS<>0,nVRedICMS,nVCompra)// Esse valor da Diferen็a de ICMS para produtos importados com aliquota de 4% serแ somado ao custo
nPIPI      	:= SB1->B1_IPI
nVIPI      	:= Iif(SB1->B1_PROC $ '000996/000997',0,nPIPI/100 * nVCompra) //Nใo considera o IPI na forma็ใo do pre็o pois o mesmo jแ esta no CUSDIP - 17/03/2015
nPICMSS    	:= SB1->B1_PICM
//nPIVA    	:= NOROUND(Iif(SB1->B1_PICMENT=0,0,If(SB1->B1_PROC $ '000630/000926/001039/000036',SB1->B1_PICMENT,(((1+SB1->B1_PICMENT/100)*Iif(SA2->A2_OPTSIMP<>'2',(1-nPICMSE/100),(1-nPICMSS/100))/(1-nPICMSS/100))-1)*100)),2) // MCVN 10/09/09
nPIVA      	:= NOROUND(Iif(SB1->B1_PICMENT=0,0,If(SB1->B1_PROC $ '',SB1->B1_PICMENT,(((1+SB1->B1_PICMENT/100)*Iif(SA2->A2_OPTSIMP<>'2',(1-nPICMSE/100),(1-nPICMSS/100))/(1-nPICMSS/100))-1)*100)),2) // MCVN 10/09/09
nVIVA      	:= Iif(nPIVA=0,0,(1+nPIVA/100)*(Iif(nPRedICMS=38.89,nVCompra*nPRedICMS/100,nVCompra)+nVIPI)) //-nVAmericA))
nVICMSS    	:= nPICMSS/100 * nVIVA
nVST       	:= Iif(nPIVA<>0,nVICMSS - nVICMSE,0)
nPST       	:= (nPVC/nVST)
nPAcresci  	:= Posicione("SA2",1,xFilial('SA2')+SB1->B1_PROC+SB1->B1_LOJPROC,"A2_ACRESCI")
nVAcresci  	:= nPAcresci/100 * (nVCompra + NVIPI)
nPDescont  	:= Posicione("SA2",1,xFilial('SA2')+SB1->B1_PROC+SB1->B1_LOJPROC,"A2_DESCONT")
nVDescont  	:= nPDescont/100 * (nVCompra + NVIPI)
nVCusto    	:= nVCompra + nVIPI + nVST + nVAcresci + nVDescont + nVBoni1 + nVBoni2 + nVDifICMSE  // Acrescentado a variแvel nVDifICMSE em 04/12/2014
nPCusto    	:= (1-(nPVC/nVCusto-1))*100
nPMargem   	:= (nPVC/nVCusto-1)*100
nVMargem   	:= nPVC - nVCusto
nPICMS     	:= nPICMSS
nVICMS     	:= nPICMS/100 * Iif(nPST=0,nPVC - (nVCompra + nVIPI),0) // - nVAmericA),0)
nVPis      	:= nPPis/100 * ( nPVC - (nVCompra + nVIPI) ) // - nVAmericA) )
nVCofins   	:= nPCofins/100 * ( nPVC - (nVCompra + nVIPI) ) // - nVAmericA) )
nVComissao 	:= nPComissao/100 * nPVC
nVFrete    	:= nPFrete/100 * nPVC
nVTCusto 	:= nVCusto + nVComissao + nVFrete + nVPis + nVCofins + nVICMS
nPTCusto 	:= (1-(nPVC/nVTCusto-1))*100
nPMargemL  	:= (nPVC/nVTCusto-1)*100
nVMargemL  	:= nPVC - nVTCusto
nVPromo		:= SB1->B1_PRVSUPE
nPPromo   	:= (nVPromo/nVCusto-1)*100
cPerProm  	:= SB1->B1_PERPROM

Set Key VK_F8 TO

//-- D'Leme: 12/09/2011 - Bloqueio da rotina quando chamada pela tela de inclusใo
If IsInCallStack("A010VISUL") ;
	.Or. IsInCallStack("A010INCLUI");
	.Or. IsInCallStack("A010ALTERA");
	.Or. IsInCallStack("MATA010DELETA");
	.Or. IsInCallStack("A010COPIA");
	.Or. IsInCallStack("A010CONSUL")
	
	MsgAlert("Nใo ้ possํvel executar esta rotina da tela de manuten็ใo! Retorne เ lista de Produtos(Browse)","Aten็ใo")
	lSaida := .T.
EndIf
                                                                                                                        
/*
If cEmpAnt+cFilAnt == '0101'
	MsgAlert("DIPROMED MATRIZ - UTILIZE SOMENTE PARA SIMULAวรO DE ST.","Aten็ใo")
Endif
*/

While !lSaida 
    
    nOpcao := 0 
    
	@ 150,000 To 700,630 DIALOG oDlg TITLE OemToAnsi("Vamos calcular o pre็o de venda pelo custo e margem")

	@ 005,010 Say AllTrim(SB1->B1_COD)+'-'+Alltrim(SB1->B1_DESC) Size 250,15 Pixel COLOR CLR_GREEN

	@ 015,010 Say "PREวOS:"
	@ 015,045 Say "Lista"
	@ 015,112 Say "D"
	@ 015,180 Say "C"
	@ 024,010 Say "ATUAIS:"
	@ 022,045 Get nPVL Size 45,40 Picture "@E 9,999,999.9999"      When .F.
	@ 022,112 Get nPVD Size 45,40 Picture "@E 9,999,999.9999"      When .F.
	@ 022,180 Get nPVC Size 45,40 Picture "@E 9,999,999.9999"      When .F.   
	@ 023,248 Say 'Varia็ใo %' Pixel COLOR CLR_RED
	@ 033,240 Get nVar Picture "@E 9999.99" Size 3,8 Pixel COLOR CLR_RED When .f.  // percentual de aumento/diminui็ใo
	@ 035,010 Say "SUGERIDOS:"
	@ 033,045 Get nNewPVL Size 45,40 Picture "@E 9,999,999.9999"   When .F.
	@ 033,112 Get nNewPVD Size 45,40 Picture "@E 9,999,999.9999"   When .F. 
	If lUserLic                                                                 
		@ 033,180 Get nNewPVC Size 45,08 Picture "@E 9,999,999.9999"  Pixel COLOR CLR_GREEN When .f.
	Else                                                               
		@ 033,180 Get nNewPVC Size 45,40 Picture "@E 9,999,999.9999"  When .F. 
	Endif
	@ 058,010 Say "INFORME OS VALORES:" Pixel COLOR CLR_BLUE     
	If(SB1->B1_PROC $ '000996/000997')
		@ 070,010 Say "Pre็o de compra COM IPI:"				       Pixel COLOR CLR_BLUE
	Else                                                                                   
		@ 070,010 Say "Pre็o de compra SEM IPI:"				       Pixel COLOR CLR_BLUE
	EndIf
	@ 070,088 Get nPCompra Size 25,08 Picture "@E 999.99"          When .F.
	@ 070,120 Get nVCompra Size 45,08 Picture "@E 9,999,999.9999"  Valid (nVCompra >= 0 .And. CalcPrc(nPVC,@nNewPVL,@nNewPVD,@nNewPVC,@nPCompra,nVCompra,nPICMSE,@nVICMSE,nPICMSS,@nVICMSS,nPICMS,@nVICMS,nPRedICMS,@nVRedICMS,nPIPI,@nVIPI,nPIVA,@nVIVA,nPST,@nVST,nPPis,@nVPis,nPCofins,@nVCofins,nPAcresci,@nVAcresci,nPDescont,@nVDescont,nPBoni1,@nVBoni1,nPBoni2,@nVBoni2,nPAmerica,@nVAmerica,@nPCusto,@nVCusto,nPMargem,@nVMargem,nPComissao,@nVComissao,nPFrete,@nVFrete,@nPTCusto,@nVTCusto,@nPMargemL,@nVMargemL,@nPPromo,@nVPromo,@nPDifICMSE,@nVDifICMSE)) Pixel COLOR CLR_BLUE
	@ 080,010 Say "Base reduzida ICMS"
	@ 080,088 Get nPRedICMS Size 25,08 Picture "@E 999.99"         When .F.      
	@ 080,120 Get nVRedICMS Size 45,08 Picture "@E 9,999,999.9999" When .F.
	@ 090,010 Say "ICMS na compra:"+Iif(SA2->A2_OPTSIMP='2',' SimpleS',' ')   Pixel COLOR CLR_BLUE 
	@ 090,088 Get nPICMSE Size 25,08 Picture "@E 999.99"		   When if(nPICMSE<>0.AND.SA2->A2_OPTSIMP<>'2',.F.,.T.) Valid CalcPrc(nPVC,@nNewPVL,@nNewPVD,@nNewPVC,@nPCompra,nVCompra,nPICMSE,@nVICMSE,nPICMSS,@nVICMSS,nPICMS,@nVICMS,nPRedICMS,@nVRedICMS,nPIPI,@nVIPI,nPIVA,@nVIVA,nPST,@nVST,nPPis,@nVPis,nPCofins,@nVCofins,nPAcresci,@nVAcresci,nPDescont,@nVDescont,nPBoni1,@nVBoni1,nPBoni2,@nVBoni2,nPAmerica,@nVAmerica,@nPCusto,@nVCusto,nPMargem,@nVMargem,nPComissao,@nVComissao,nPFrete,@nVFrete,@nPTCusto,@nVTCusto,@nPMargemL,@nVMargemL,@nPPromo,@nVPromo,@nPDifICMSE,@nVDifICMSE) Pixel COLOR CLR_BLUE 
	@ 090,120 Get nVICMSE Size 45,08 Picture "@E 9,999,999.9999"   When .F. 
	@ 100,010 Say "DIF. ICMS na compra:"+Iif(SA2->A2_OPTSIMP='2',' SimpleS',' ')   Pixel COLOR CLR_BLUE 
	@ 100,088 Get nPDifICMSE Size 25,08 Picture "@E 999.99"		   When if(nPICMSE<>0.AND.SA2->A2_OPTSIMP<>'2',.F.,.T.) Valid CalcPrc(nPVC,@nNewPVL,@nNewPVD,@nNewPVC,@nPCompra,nVCompra,nPICMSE,@nVICMSE,nPICMSS,@nVICMSS,nPICMS,@nVICMS,nPRedICMS,@nVRedICMS,nPIPI,@nVIPI,nPIVA,@nVIVA,nPST,@nVST,nPPis,@nVPis,nPCofins,@nVCofins,nPAcresci,@nVAcresci,nPDescont,@nVDescont,nPBoni1,@nVBoni1,nPBoni2,@nVBoni2,nPAmerica,@nVAmerica,@nPCusto,@nVCusto,nPMargem,@nVMargem,nPComissao,@nVComissao,nPFrete,@nVFrete,@nPTCusto,@nVTCusto,@nPMargemL,@nVMargemL,@nPPromo,@nVPromo,@nPDifICMSE,@nVDifICMSE) Pixel COLOR CLR_BLUE 
	@ 100,120 Get nVDifICMSE Size 45,08 Picture "@E 9,999,999.9999"   When .F. 
	@ 110,010 Say "IPI"
	@ 110,088 Get nPIPI Size 25,08 Picture "@E 999.99"             When .F.
	@ 110,120 Get nVIPI Size 45,08 Picture "@E 9,999,999.9999"     When .F.
	@ 120,010 Say "IVA (ST de SP)"
	@ 120,065 Say Iif(nPICMSE<>nPICMSS,Transform(SB1->B1_PICMENT,"@e 999.99"),"") Pixel COLOR CLR_HRED
	@ 120,088 Get nPIVA Size 25,08 Picture "@E 999.99"             When .F. Valid CalcPrc(nPVC,@nNewPVL,@nNewPVD,@nNewPVC,@nPCompra,nVCompra,nPICMSE,@nVICMSE,nPICMSS,@nVICMSS,nPICMS,@nVICMS,nPRedICMS,@nVRedICMS,nPIPI,@nVIPI,nPIVA,@nVIVA,nPST,@nVST,nPPis,@nVPis,nPCofins,@nVCofins,nPAcresci,@nVAcresci,nPDescont,@nVDescont,nPBoni1,@nVBoni1,nPBoni2,@nVBoni2,nPAmerica,@nVAmerica,@nPCusto,@nVCusto,nPMargem,@nVMargem,nPComissao,@nVComissao,nPFrete,@nVFrete,@nPTCusto,@nVTCusto,@nPMargemL,@nVMargemL,@nPPromo,@nVPromo,@nPDifICMSE,@nVDifICMSE) Pixel COLOR CLR_BLUE
	@ 120,120 Get nVIVA Size 45,08 Picture "@E 9,999,999.9999"     When .F.                                                                
	@ 130,010 Say "ICMS IVA (ST de SP)"                          
	@ 130,088 Get nPICMSS Size 25,08 Picture "@E 999.99"		   When .F.
	@ 130,120 Get nVICMSS Size 45,08 Picture "@E 9,999,999.9999"   When .F.
	@ 140,010 Say "ST"
	@ 140,088 Get nPST Size 25,08 Picture "@E 999.99"              When .F.
	@ 140,120 Get nVST Size 45,08 Picture "@E 9,999,999.9999"      When .F.
	If !lUserLic                                                             
		@ 150,010 Say "Acrescimo"           					       Pixel COLOR CLR_BLUE
		@ 150,088 Get nPAcresci Size 25,08 Picture "@E 999.99"         Valid CalcPrc(nPVC,@nNewPVL,@nNewPVD,@nNewPVC,@nPCompra,nVCompra,nPICMSE,@nVICMSE,nPICMSS,@nVICMSS,nPICMS,@nVICMS,nPRedICMS,@nVRedICMS,nPIPI,@nVIPI,nPIVA,@nVIVA,nPST,@nVST,nPPis,@nVPis,nPCofins,@nVCofins,nPAcresci,@nVAcresci,nPDescont,@nVDescont,nPBoni1,@nVBoni1,nPBoni2,@nVBoni2,nPAmerica,@nVAmerica,@nPCusto,@nVCusto,nPMargem,@nVMargem,nPComissao,@nVComissao,nPFrete,@nVFrete,@nPTCusto,@nVTCusto,@nPMargemL,@nVMargemL,@nPPromo,@nVPromo,@nPDifICMSE,@nVDifICMSE) Pixel COLOR CLR_BLUE
		@ 150,120 Get nVAcresci Size 45,08 Picture "@E 9,999,999.9999" When .F.	
		@ 160,010 Say "Desconto"            					       Pixel COLOR CLR_BLUE
		@ 160,088 Get nPDescont Size 25,08 Picture "@E 999.99"         Valid CalcPrc(nPVC,@nNewPVL,@nNewPVD,@nNewPVC,@nPCompra,nVCompra,nPICMSE,@nVICMSE,nPICMSS,@nVICMSS,nPICMS,@nVICMS,nPRedICMS,@nVRedICMS,nPIPI,@nVIPI,nPIVA,@nVIVA,nPST,@nVST,nPPis,@nVPis,nPCofins,@nVCofins,nPAcresci,@nVAcresci,nPDescont,@nVDescont,nPBoni1,@nVBoni1,nPBoni2,@nVBoni2,nPAmerica,@nVAmerica,@nPCusto,@nVCusto,nPMargem,@nVMargem,nPComissao,@nVComissao,nPFrete,@nVFrete,@nPTCusto,@nVTCusto,@nPMargemL,@nVMargemL,@nPPromo,@nVPromo,@nPDifICMSE,@nVDifICMSE) Pixel COLOR CLR_BLUE
		@ 160,120 Get nVDescont Size 45,08 Picture "@E 9,999,999.9999" when .F.	
		@ 170,010 Say "Bonifica็ใo 1" Pixel COLOR CLR_BLUE
		@ 170,088 Get nPBoni1 Size 25,08 Picture "@E 999.99"           Valid CalcPrc(nPVC,@nNewPVL,@nNewPVD,@nNewPVC,@nPCompra,nVCompra,nPICMSE,@nVICMSE,nPICMSS,@nVICMSS,nPICMS,@nVICMS,nPRedICMS,@nVRedICMS,nPIPI,@nVIPI,nPIVA,@nVIVA,nPST,@nVST,nPPis,@nVPis,nPCofins,@nVCofins,nPAcresci,@nVAcresci,nPDescont,@nVDescont,nPBoni1,@nVBoni1,nPBoni2,@nVBoni2,nPAmerica,@nVAmerica,@nPCusto,@nVCusto,nPMargem,@nVMargem,nPComissao,@nVComissao,nPFrete,@nVFrete,@nPTCusto,@nVTCusto,@nPMargemL,@nVMargemL,@nPPromo,@nVPromo,@nPDifICMSE,@nVDifICMSE) Pixel COLOR CLR_BLUE
		@ 170,120 Get nVBoni1 Size 45,08 Picture "@E 999,999.9999"     When .F.
		@ 180,010 Say "Bonifica็ใo 2" Pixel COLOR CLR_BLUE
		@ 180,088 Get nPBoni2 Size 25,08 Picture "@E 999.99"           Valid CalcPrc(nPVC,@nNewPVL,@nNewPVD,@nNewPVC,@nPCompra,nVCompra,nPICMSE,@nVICMSE,nPICMSS,@nVICMSS,nPICMS,@nVICMS,nPRedICMS,@nVRedICMS,nPIPI,@nVIPI,nPIVA,@nVIVA,nPST,@nVST,nPPis,@nVPis,nPCofins,@nVCofins,nPAcresci,@nVAcresci,nPDescont,@nVDescont,nPBoni1,@nVBoni1,nPBoni2,@nVBoni2,nPAmerica,@nVAmerica,@nPCusto,@nVCusto,nPMargem,@nVMargem,nPComissao,@nVComissao,nPFrete,@nVFrete,@nPTCusto,@nVTCusto,@nPMargemL,@nVMargemL,@nPPromo,@nVPromo,@nPDifICMSE,@nVDifICMSE) Pixel COLOR CLR_BLUE
		@ 180,120 Get nVBoni2 Size 45,08 Picture "@E 999,999.9999"     When .F.
		@ 190,010 Say "Am้ricA" 									   Pixel COLOR CLR_BLUE
		@ 190,088 Get nPAmerica Size 25,08 Picture "@E 999.99"         Valid CalcPrc(nPVC,@nNewPVL,@nNewPVD,@nNewPVC,@nPCompra,nVCompra,nPICMSE,@nVICMSE,nPICMSS,@nVICMSS,nPICMS,@nVICMS,nPRedICMS,@nVRedICMS,nPIPI,@nVIPI,nPIVA,@nVIVA,nPST,@nVST,nPPis,@nVPis,nPCofins,@nVCofins,nPAcresci,@nVAcresci,nPDescont,@nVDescont,nPBoni1,@nVBoni1,nPBoni2,@nVBoni2,nPAmerica,@nVAmerica,@nPCusto,@nVCusto,nPMargem,@nVMargem,nPComissao,@nVComissao,nPFrete,@nVFrete,@nPTCusto,@nVTCusto,@nPMargemL,@nVMargemL,@nPPromo,@nVPromo,@nPDifICMSE,@nVDifICMSE) Pixel COLOR CLR_BLUE When Iif(SB1->B1_PROC='000630',.t.,.f.)
		@ 190,120 Get nVAmerica Size 45,08 Picture "@E 9,999,999.9999" When .F.	
		@ 200,010 Say "CUSTO"
		@ 200,088 Get nPCusto Size 25,08 Picture "@E 999.99"           When .F.
		@ 200,120 Get nVCusto Size 45,08 Picture "@E 9,999,999.9999"   When .F.
	Endif
	@ 220,010 Say 'Margem Bruta'   	  Pixel COLOR CLR_BLUE
	@ 220,083 Get nPMargem Size 25,08 Picture "@E 9999.99"         Valid CalcPrc(nPVC,@nNewPVL,@nNewPVD,@nNewPVC,@nPCompra,nVCompra,nPICMSE,@nVICMSE,nPICMSS,@nVICMSS,nPICMS,@nVICMS,nPRedICMS,@nVRedICMS,nPIPI,@nVIPI,nPIVA,@nVIVA,nPST,@nVST,nPPis,@nVPis,nPCofins,@nVCofins,nPAcresci,@nVAcresci,nPDescont,@nVDescont,nPBoni1,@nVBoni1,nPBoni2,@nVBoni2,nPAmerica,@nVAmerica,@nPCusto,@nVCusto,nPMargem,@nVMargem,nPComissao,@nVComissao,nPFrete,@nVFrete,@nPTCusto,@nVTCusto,@nPMargemL,@nVMargemL,@nPPromo,@nVPromo,@nPDifICMSE,@nVDifICMSE) Pixel COLOR CLR_BLUE
	@ 220,120 Get nVMargem Size 45,08 Picture "@E 9,999,999.9999"  When .F.

	If !lUserLic                                                             
		@ 150,175 Say "ICMS" Pixel COLOR CLR_BLUE
		@ 150,235 Get nPICMS Size 25,08 Picture "@E 999.99"            Valid CalcPrc(nPVC,@nNewPVL,@nNewPVD,@nNewPVC,@nPCompra,nVCompra,nPICMSE,@nVICMSE,nPICMSS,@nVICMSS,nPICMS,@nVICMS,nPRedICMS,@nVRedICMS,nPIPI,@nVIPI,nPIVA,@nVIVA,nPST,@nVST,nPPis,@nVPis,nPCofins,@nVCofins,nPAcresci,@nVAcresci,nPDescont,@nVDescont,nPBoni1,@nVBoni1,nPBoni2,@nVBoni2,nPAmerica,@nVAmerica,@nPCusto,@nVCusto,nPMargem,@nVMargem,nPComissao,@nVComissao,nPFrete,@nVFrete,@nPTCusto,@nVTCusto,@nPMargemL,@nVMargemL,@nPPromo,@nVPromo,@nPDifICMSE,@nVDifICMSE) Pixel COLOR CLR_BLUE
		@ 150,267 Get nVICMS Size 45,08 Picture "@E 999,999.9999"      When .F.
		@ 160,175 Say "Pis" Pixel COLOR CLR_BLUE
		@ 160,235 Get nPPis Size 25,08 Picture "@E 999.99"             Valid CalcPrc(nPVC,@nNewPVL,@nNewPVD,@nNewPVC,@nPCompra,nVCompra,nPICMSE,@nVICMSE,nPICMSS,@nVICMSS,nPICMS,@nVICMS,nPRedICMS,@nVRedICMS,nPIPI,@nVIPI,nPIVA,@nVIVA,nPST,@nVST,nPPis,@nVPis,nPCofins,@nVCofins,nPAcresci,@nVAcresci,nPDescont,@nVDescont,nPBoni1,@nVBoni1,nPBoni2,@nVBoni2,nPAmerica,@nVAmerica,@nPCusto,@nVCusto,nPMargem,@nVMargem,nPComissao,@nVComissao,nPFrete,@nVFrete,@nPTCusto,@nVTCusto,@nPMargemL,@nVMargemL,@nPPromo,@nVPromo,@nPDifICMSE,@nVDifICMSE) Pixel COLOR CLR_BLUE
		@ 160,267 Get nVPis Size 45,08 Picture "@E 999,999.9999"       When .F.
		@ 170,175 Say "Cofins" Pixel COLOR CLR_BLUE
		@ 170,235 Get nPCofins Size 25,08 Picture "@E 999.99"          Valid CalcPrc(nPVC,@nNewPVL,@nNewPVD,@nNewPVC,@nPCompra,nVCompra,nPICMSE,@nVICMSE,nPICMSS,@nVICMSS,nPICMS,@nVICMS,nPRedICMS,@nVRedICMS,nPIPI,@nVIPI,nPIVA,@nVIVA,nPST,@nVST,nPPis,@nVPis,nPCofins,@nVCofins,nPAcresci,@nVAcresci,nPDescont,@nVDescont,nPBoni1,@nVBoni1,nPBoni2,@nVBoni2,nPAmerica,@nVAmerica,@nPCusto,@nVCusto,nPMargem,@nVMargem,nPComissao,@nVComissao,nPFrete,@nVFrete,@nPTCusto,@nVTCusto,@nPMargemL,@nVMargemL,@nPPromo,@nVPromo,@nPDifICMSE,@nVDifICMSE) Pixel COLOR CLR_BLUE
		@ 170,267 Get nVCofins Size 45,08 Picture "@E 999,999.9999"    When .F.
		@ 180,175 Say "Comissใo"  Pixel COLOR CLR_BLUE
		@ 180,235 Get nPComissao Size 25,08 Picture "@E 999.99"        Valid CalcPrc(nPVC,@nNewPVL,@nNewPVD,@nNewPVC,@nPCompra,nVCompra,nPICMSE,@nVICMSE,nPICMSS,@nVICMSS,nPICMS,@nVICMS,nPRedICMS,@nVRedICMS,nPIPI,@nVIPI,nPIVA,@nVIVA,nPST,@nVST,nPPis,@nVPis,nPCofins,@nVCofins,nPAcresci,@nVAcresci,nPDescont,@nVDescont,nPBoni1,@nVBoni1,nPBoni2,@nVBoni2,nPAmerica,@nVAmerica,@nPCusto,@nVCusto,nPMargem,@nVMargem,nPComissao,@nVComissao,nPFrete,@nVFrete,@nPTCusto,@nVTCusto,@nPMargemL,@nVMargemL,@nPPromo,@nVPromo,@nPDifICMSE,@nVDifICMSE) Pixel COLOR CLR_BLUE
		@ 180,267 Get nVComissao Size 45,08 Picture "@E 999,999.9999"  When .F.
		@ 190,175 Say "Frete"  Pixel COLOR CLR_BLUE
		@ 190,235 Get nPFrete Size 25,08 Picture "@E 999.99"           Valid CalcPrc(nPVC,@nNewPVL,@nNewPVD,@nNewPVC,@nPCompra,nVCompra,nPICMSE,@nVICMSE,nPICMSS,@nVICMSS,nPICMS,@nVICMS,nPRedICMS,@nVRedICMS,nPIPI,@nVIPI,nPIVA,@nVIVA,nPST,@nVST,nPPis,@nVPis,nPCofins,@nVCofins,nPAcresci,@nVAcresci,nPDescont,@nVDescont,nPBoni1,@nVBoni1,nPBoni2,@nVBoni2,nPAmerica,@nVAmerica,@nPCusto,@nVCusto,nPMargem,@nVMargem,nPComissao,@nVComissao,nPFrete,@nVFrete,@nPTCusto,@nVTCusto,@nPMargemL,@nVMargemL,@nPPromo,@nVPromo,@nPDifICMSE,@nVDifICMSE) Pixel COLOR CLR_BLUE
		@ 190,267 Get nVFrete Size 45,08 Picture "@E 999,999.9999"     When .F.
		@ 200,175 Say "CUSTO TOTAL"
		@ 200,235 Get nPTCusto Size 25,08 Picture "@E 999.99"          When .F. 
		@ 200,267 Get nVTCusto Size 45,08 Picture "@E 999,999.9999"    When .F. 
		@ 220,175 Say "Margem Contribui็ใo"
		@ 220,230 Get nPMargemL Size 25,08 Picture "@E 9999.99"        When .F.
		@ 220,267 Get nVMargemL Size 45,08 Picture "@E 999,999.9999"   When .F.
		@ 058,180 Say "PROMOวรO:" 	Pixel COLOR CLR_HRED
		@ 058,213 Get nPPromo Size 25,08 Picture "@E 999.99"           When nPPromo := Iif(nVPromo=0,0,nPPromo) Valid nVPromo := (1+nPPromo/100) * nVCusto Pixel COLOR CLR_HRED
		@ 058,246 Get nVPromo Size 50,08 Picture "@E 9,999,999.9999"   When nVPromo := Iif(nPPromo=0,0,nVPromo) Valid nPPromo := (nVPromo/nVCusto-1)*100   Pixel COLOR CLR_HRED
	    @ 078,180 Say "PERอODO DE PROMOวรO" Pixel COLOR CLR_HRED
	    @ 078,246 Get cPerProm  size 50,08  Picture "@E 99/99/99-99/99/99" Valid ((Len(alltrim(cPerProm)) == 17  .And. nVPromo > 0 ) .OR. (cPerProm == '  /  /  -  /  /  ' .AND.  nVPromo == 0)) Pixel COLOR CLR_HRED//when nVPromo > 0
	Endif   
//nPVC,@nNewPVL,@nNewPVD,@nNewPVC,@nPCompra,nVCompra,nPICMSE,@nVICMSE,nPICMSS,@nVICMSS,nPICMS,@nVICMS,nPRedICMS,@nVRedICMS,nPIPI,@nVIPI,nPIVA,@nVIVA,nPST,@nVST,nPPis,@nVPis,nPCofins,@nVCofins,nPAcresci,@nVAcresci,nPDescont,@nVDescont,nPBoni1,@nVBoni1,nPBoni2,@nVBoni2,nPAmerica,@nVAmerica,@nPCusto,@nVCusto,nPMargem,@nVMargem,nPComissao,@nVComissao,nPFrete,@nVFrete,@nPTCusto,@nVTCusto,@nPMargemL,@nVMargemL,@nPPromo,@nVPromo
    If lUserLic// .Or. UPPER(U_DipUsr()) $ cUsrDIP008
    	@ 250,250 BUTTON OemToAnsi("  Sair  ") Size 36,15  ACTION (lSaida := .T.,nOpcao := 0,Close(oDlg))
    Else
		@ 250,170 BUTTON OemToAnsi("Calcular") Size 36,15  ACTION (CalcPrc(nPVC,@nNewPVL,@nNewPVD,@nNewPVC,@nPCompra,nVCompra,nPICMSE,@nVICMSE,nPICMSS,@nVICMSS,nPICMS,@nVICMS,nPRedICMS,@nVRedICMS,nPIPI,@nVIPI,nPIVA,@nVIVA,nPST,@nVST,nPPis,@nVPis,nPCofins,@nVCofins,nPAcresci,@nVAcresci,nPDescont,@nVDescont,nPBoni1,@nVBoni1,nPBoni2,@nVBoni2,nPAmerica,@nVAmerica,@nPCusto,@nVCusto,nPMargem,@nVMargem,nPComissao,@nVComissao,nPFrete,@nVFrete,@nPTCusto,@nVTCusto,@nPMargemL,@nVMargemL,@nPPromo,@nVPromo,@nPDifICMSE,@nVDifICMSE))
		@ 250,210 BUTTON OemToAnsi(" Gravar ") Size 36,15  ACTION (nOpcao := 1,Close(oDlg))
		@ 250,250 BUTTON OemToAnsi("  Sair  ") Size 36,15  ACTION (lSaida := .T.,nOpcao := 0,Close(oDlg))
	Endif
	
	ACTIVATE DIALOG oDlg Centered

    If nOpcao = 0     //   JBS 24/05/2010
	    Exit          //   For็a a saida do While quando 
    Endif             //   Pressionada a tecla ESC

    /*
	If cEmpAnt+cFilAnt == '0101'
		MsgAlert("DIPROMED MATRIZ - UTILIZE SOMENTE PARA SIMULAวรO DE ST.","Aten็ใo")
		Exit
	Endif
	*/
	
	If nOpcao = 1 .And. SB1->B1_PRV1 <> ROUND(nNewPVL,4) .And. ROUND(nNewPVL,4) > 0
   		
   		// Ajuste no Pre็o C - MCVN - 19/03/2009
   		nAJusPVC := DigValor(nNewPVC)

   		If .T. //MsgYesNo(" Confirma o pre็o C:  " + AllTrim(Transform(nAjusPVC,"@e 9,999,999.9999")) +" ? ","Aten็ใo")
            If nAJusPVC <> nNewPVC
		   		nNewPVL := nAJusPVC/1.2*1.6
				nNewPVD := nNewPVL*0.775
				nNewPVC := nAJusPVC
		    Endif

		    If nVPromo >= 0 .And. nVPromo <> SB1->B1_PRVSUPE
				//If MsgYesNo(" Atualiza pre็o de promo็ใo : "+ AllTrim(Transform(nVPromo,"@e 9,999,999.9999")) +" ? ","Aten็ใo")
					lAtuProm := .T.
        	    //EndIf
     	    Endif

   		    If cPerProm <> SB1->B1_PERPROM  // MCVN - 10/10/2009
				//If MsgYesNo(" Atualiza perํodo de promo็ใo : "+ AllTrim(Transform(cPerprom,"@E 99/99/99-99/99/99")) +" ? ","Aten็ใo")
	            	lPerprom := .T.
    	        //Endif
    	    Endif
			// Atualiza variแveis de mem๓ria
			M->B1_PRV1    := nNewPVL 
			M->B1_PRVPROM := nNewPVD 
			M->B1_PRVMINI := nNewPVC 
  			M->B1_PRVSUPE := Iif(lAtuProm,nVPromo,SB1->B1_PRVSUPE)
  			M->B1_ALTPREC := dDataBase                         
  			M->B1_DTLISFO := dDataBase                         
  			M->B1_LISFOR  := nVCusto   
  			M->B1_PERPROM := Iif(lPerprom,cPerprom,SB1->B1_PERPROM)// MCVN - 10/10/2009
  		  			
		   	// Atualiza array
   			Aadd(aEnv_Pro,{SB1->B1_COD, SB1->B1_DESC, SB1->B1_UM, SB1->B1_UCOM, SB1->B1_UPRC, SB1->B1_PRV1,                          SB1->B1_PRVSUPE, SB1->B1_PRVMINI, SB1->B1_PRVPROM})
			Aadd(aEnv_Pro,{SB1->B1_COD, SB1->B1_DESC, SB1->B1_UM, SB1->B1_UCOM, SB1->B1_UPRC, M->B1_PRV1, Iif(lAtuProm,M->B1_PRVSUPE,SB1->B1_PRVSUPE),M->B1_PRVMINI, M->B1_PRVPROM})
			
			// Envia email e Cic quando produto entra ou sai de promo็ใo  MCVN - 09/08/2007
		    If M->B1_PRVSUPE <> SB1->B1_PRVSUPE 
		    	cObsAltPro := ""   
		    	
   				// Desabilitada op็ใo de mensagem no cic e e-mail em 17/12/10 (Solicitado pelo Eriberto)
	           	/*IF MsgBox("PROMOวรO!   Deseja incluir uma observa็ใo no Cic e no Email enviado aos colaboradores?","Atencao","YESNO")  		
					cObsAltPro:=u_ObsAltPro() // MCVN - 18/02/10		
				Endif */
				
	       		If M->B1_PRVSUPE = 0
	    		    cTitCic  := 'SAIU da promo็ใo.'
	 		   		cAssCic  := 'Produto saiu da promo็ใo.'+Space(15)+'DIPA008'
	 		   		cAssEmail:= 'Produto saiu da promo็ใo. - '+ Upper(U_DipUsr())+' - C๓digo-'+ SB1->B1_COD+Space(15)+'DIPA008'
	  		  	Elseif	M->B1_PRVSUPE > SB1->B1_PRVSUPE  .And. SB1->B1_PRVSUPE > 0 
   		 	    	cTitCic  := 'PROMOวรO - Altera็ใo de pre็o.'                              
	  		  		cAssCic  := 'Produto continua em promo็ใo mas houve aumento no pre็o.' +Space(15)+'DIPA008'
	  		  		cAssEmail:= 'Produto continua em promo็ใo mas houve aumento no pre็o. - '+ Upper(U_DipUsr())+' - C๓digo-'+ SB1->B1_COD+Space(15)+'DIPA008'
   				Elseif	M->B1_PRVSUPE < SB1->B1_PRVSUPE  .And. M->B1_PRVSUPE > 0 
	   				cTitCic  := 'PROMOวรO - Altera็ใo de pre็o.'                              
	    			cAssCic  := 'Produto continua em promo็ใo e houve redu็ใo no pre็o.'+Space(15)+'DIPA008'
	    			cAssEmail:= 'Produto continua em promo็ใo e houve redu็ใo no pre็o. - '+ Upper(U_DipUsr())+' - C๓digo-'+ SB1->B1_COD+Space(15)+'DIPA008'
	    		Elseif	M->B1_PRVSUPE > SB1->B1_PRVSUPE  .And. SB1->B1_PRVSUPE = 0                               
		    		cTitCic  := 'PROMOวรO'
	    			cAssCic  := 'Produto em promo็ใo.'+Space(15)+'DIPA008'    
	    			cAssEmail:= 'Produto em promo็ใo. - '+ Upper(U_DipUsr())+' - C๓digo-'+ SB1->B1_COD+Space(15)+'DIPA008'
	    		Endif   
			 	U_EnvCic(aEnv_Pro,cAssCic,cTitCic,"PRO")	
 			  	U_Env_Pro(cEmail,cAssEmail,aEnv_Pro)	
	    	Endif  
	    	
	    	// Email com altera็ใo no pre็o de ista
	    	If M->B1_PRV1 > SB1->B1_PRV1 
				cAssunto := 'Aumento de preco feito por: '+ Upper(U_DipUsr())+' - Codigo-'+ SB1->B1_COD+Space(15)+'DIPA008'
				U_Env_Pro(cEmail,cAssunto,aEnv_Pro)
			ElseIf M->B1_PRV1 < SB1->B1_PRV1
				cAssunto := 'Reducao de preco feita por: '+ Upper(U_DipUsr())+' - Codigo-'+ SB1->B1_COD+Space(15)+'DIPA008'		
		  		U_Env_Pro(cEmail,cAssunto,aEnv_Pro)
		  	Endif
            
            
            //Verificar se atualiza ou nใo o Pre็o - 13/10/11
            If cEmpAnt == "01"      	
            	nAtuPrc := Aviso("Aten็ใo","Atualiza a informa็ใo nas duas filiais?",{"Nใo","Atu. Pre็o","Atu. Custo","Ambos"},2)  
				//nAtuPrc := 4 
	   	    Endif
			
			// Atualiza Kardex Geral 
			lOldAlter := Altera
			Altera := .T.  // Define variแvel altera como True para que a Rotina do GravaZG entenda que ้ altera็ใo.
			U_XULTPRC() // Aqui chama na atualiza็ใo pelo F8 pre็o PRODUTO
			U_GravaZG("SB1")
	   		Altera := lOldAlter
	   		
	   		// Atualiza tabela
	   		RecLock("SB1",.F.)
     		SB1->B1_PRVSUPE   := Iif(lAtuProm,nVPromo,SB1->B1_PRVSUPE)
	   		SB1->B1_PRV1      := nNewPVL
			SB1->B1_PRVPROM   := nNewPVD
			SB1->B1_PRVMINI   := nNewPVC
		    SB1->B1_ALTPREC   := dDataBase                         
		    SB1->B1_LISFOR    := nVCusto
		    SB1->B1_DTLISFO   := dDataBase
			If lPerProm  // MCVN - 10/09/2009
			    SB1->B1_MOSTPRO   := "N"      
	    	    SB1->B1_PERPROM   := cPerProm                                            		
		    Endif
			SB1->( MsUnLock() )        
		    SB1->( DbCommit() )        
		    
		    //-- D'Leme: 12/09/2011 - R้plica entre filiais Dipromed (solu็ใo paliativa e rแpida escolhida)
		    If cEmpAnt == "01" .And. ( nAtuPrc > 1  .or. nNewPVC == 0) 
		    	aAreaAux := SB1->(GetArea())
		    	SB1->(DbSetOrder(1)) //-- B1_FILIAL+B1_COD
		    	If SB1->(DbSeek( xFilial("SB1",Iif(cFilAnt=="01","04","01")) + B1_COD ))
			   		RecLock("SB1",.F.)
		     		If nAtuPrc==2 .Or. nAtuPrc==4
			     		SB1->B1_PRVSUPE   := Iif(lAtuProm,nVPromo,SB1->B1_PRVSUPE)
				   		SB1->B1_PRV1      := nNewPVL
						SB1->B1_PRVPROM   := nNewPVD
						SB1->B1_PRVMINI   := nNewPVC
					    SB1->B1_ALTPREC   := dDataBase
					EndIf
					If nAtuPrc==3 .Or. nAtuPrc==4         
						
						nX_PRedICMS := nPRedICMS
						nX_VRedICMS := nVRedICMS
						nX_PICMSE   := nPICMSE
						nX_VICMSE   := nVICMSE
						nX_PDifICMSE:= nPDifICMSE
						nX_VDifICMSE:= nVDifICMSE
						nX_PIPI     := nPIPI
						nX_VIPI     := nVIPI
						nX_PICMSS   := nPICMSS
						nX_PIVA     := nPIVA
						nX_VIVA     := nVIVA
						nX_VICMSS   := nVICMSS
						nX_VST      := nVST
						nX_PST      := nPST
						nX_PAcresci := nPAcresci
						nX_VAcresci := nVAcresci
						nX_PDescont := nPDescont
						nX_VDescont := nVDescont
						nX_VCusto   := nVCusto
						
						nPRedICMS  	:= Posicione("SF4",1,xFilial('SF4')+SB1->B1_TE,"F4_BASEICM")
						nVRedICMS  	:= nPRedICMS/100 * (nVCompra) 
						nPICMSE    	:= Iif(Posicione("SA2",1,xFilial('SA2')+SB1->B1_PROC+SB1->B1_LOJPROC,"A2_OPTSIMP")='2',SB1->B1_PICM_SN,Iif(SB1->B1_PICM == 0,0,Iif(SA2->A2_EST$'SP/EX',SB1->B1_PICM,IIf(SB1->B1_ORIGEM$'1/2/3/8',4,12))))
						nVICMSE    	:= nPICMSE/100 * Iif(nVRedICMS<>0,nVRedICMS,nVCompra) 						
						nPDifICMSE  := Iif(nPICMSE<>SB1->B1_PICM .And. SB1->B1_PICMENT=0,SB1->B1_PICM - nPICMSE,0)
						nVDifICMSE  := nPDifICMSE/100 * Iif(nVRedICMS<>0,nVRedICMS,nVCompra)
						nPIPI      	:= SB1->B1_IPI
						nVIPI      	:= Iif(SB1->B1_PROC $ '000996/000997',0,nPIPI/100 * nVCompra) 
						nPICMSS    	:= SB1->B1_PICM						
						nPIVA      	:= NOROUND(Iif(SB1->B1_PICMENT=0,0,If(SB1->B1_PROC $ '',SB1->B1_PICMENT,(((1+SB1->B1_PICMENT/100)*Iif(SA2->A2_OPTSIMP<>'2',(1-nPICMSE/100),(1-nPICMSS/100))/(1-nPICMSS/100))-1)*100)),2)
						nVIVA      	:= Iif(nPIVA=0,0,(1+nPIVA/100)*(Iif(nPRedICMS=38.89,nVCompra*nPRedICMS/100,nVCompra)+nVIPI))
						nVICMSS    	:= nPICMSS/100 * nVIVA
						nVST       	:= Iif(nPIVA<>0,nVICMSS - nVICMSE,0)
						nPST       	:= (nPVC/nVST)
						nPAcresci  	:= Posicione("SA2",1,xFilial('SA2')+SB1->B1_PROC+SB1->B1_LOJPROC,"A2_ACRESCI")
						nVAcresci  	:= nPAcresci/100 * (nVCompra + NVIPI)
						nPDescont  	:= Posicione("SA2",1,xFilial('SA2')+SB1->B1_PROC+SB1->B1_LOJPROC,"A2_DESCONT")
						nVDescont  	:= nPDescont/100 * (nVCompra + NVIPI)       						
						nVCusto    	:= nVCompra + nVIPI + nVST + nVAcresci + nVDescont + nVDifICMSE 
						 
					    SB1->B1_LISFOR    := nVCusto
					    SB1->B1_DTLISFO   := dDataBase
					       						
						nPRedICMS  	:= nX_PRedICMS
						nVRedICMS  	:= nX_VRedICMS
						nPICMSE    	:= nX_PICMSE
						nVICMSE    	:= nX_VICMSE
						nPDifICMSE	:= nX_PDifICMSE
						nVDifICMSE 	:= nX_VDifICMSE
						nPIPI      	:= nX_PIPI
						nVIPI      	:= nX_VIPI
						nPICMSS    	:= nX_PICMSS
						nPIVA      	:= nX_PIVA
						nVIVA      	:= nX_VIVA
						nVICMSS    	:= nX_VICMSS
						nVST       	:= nX_VST
						nPST       	:= nX_PST
						nPAcresci  	:= nX_PAcresci
						nVAcresci  	:= nX_VAcresci
						nPDescont  	:= nX_PDescont
						nVDescont  	:= nX_VDescont
						nVCusto    	:= nX_VCusto
					EndIf
					If lPerProm  // MCVN - 10/09/2009
					    SB1->B1_MOSTPRO   := "N"
			    	    SB1->B1_PERPROM   := cPerProm
				    EndIf
					SB1->( MsUnLock() )        
				    SB1->( DbCommit() )        
		    	EndIf 
		    	RestArea( aAreaAux )
	    	EndIf

			//Refresh nos pre็os do produto
			nPVL := nNewPVL
			nPVD := nNewPVD
			nPVC := nNewPVC
			
			If !('DIPM_B1'$FUNNAME()) .And. (VarType("l010Auto")=="U" .Or. !l010Auto)
				If SB1->B1_XCODDES<>'' .And. SB1->B1_XCXFECH == '1' .And.  SB1->B1_XVLDCXE == '1' .And. !Empty(SB1->B1_XCODDES)
					MsgBox("FAVOR ALTERAR  AS  MESMAS INFORMAวีES NO CำDIGO "+SB1->B1_XCODDES+"!","ATENวรO","OK")
				Endif
			EndIf	
			 
		MsgBox("Pre็o C alterado"+If(lAtuProm,", pre็o de promo็ใo alterado","")+If(lPerProm,", perํodo de promo็ใo alterado","")+ "!" ,"ATENวรO","OK")							  	
						  	
	    Endif
	ElseIf nOpcao = 1 .And. ROUND(nVPromo,4) >= 0 .And. ROUND(nVPromo,4) <> SB1->B1_PRVSUPE   // MCVN - 25/09/2009
		lAtuProm := .T.	
		If MsgYesNo(" Atualiza pre็o de promo็ใo : "+ AllTrim(Transform(nVPromo,"@e 9,999,999.9999")) +" ? ","Aten็ใo")

  			M->B1_PRVSUPE := nVPromo
  			M->B1_PERPROM := cPerprom
  			
		   	// Atualiza array
   			Aadd(aEnv_Pro,{SB1->B1_COD, SB1->B1_DESC, SB1->B1_UM, SB1->B1_UCOM, SB1->B1_UPRC, SB1->B1_PRV1,                          SB1->B1_PRVSUPE, SB1->B1_PRVMINI, SB1->B1_PRVPROM})
			Aadd(aEnv_Pro,{SB1->B1_COD, SB1->B1_DESC, SB1->B1_UM, SB1->B1_UCOM, SB1->B1_UPRC, M->B1_PRV1, Iif(lAtuProm,M->B1_PRVSUPE,SB1->B1_PRVSUPE),M->B1_PRVMINI, M->B1_PRVPROM})
			
			// Envia email e Cic quando produto entra ou sai de promo็ใo  MCVN - 09/08/2007
		    If M->B1_PRVSUPE <> SB1->B1_PRVSUPE  
		     
   		    	cObsAltPro := ""          
   		    	
   				// Desabilitada op็ใo de mensagem no cic e e-mail em 17/12/10 (Solicitado pelo Eriberto)
	           	/*IF MsgBox("PROMOวรO!   Deseja incluir uma observa็ใo no Cic e no Email enviado aos colaboradores?","Atencao","YESNO")  		
					cObsAltPro:=u_ObsAltPro() // MCVN - 18/02/10		
				Endif  */
	       		If M->B1_PRVSUPE = 0
	    		    cTitCic  := 'SAIU da promo็ใo.'
	 		   		cAssCic  := 'Produto saiu da promo็ใo.'	+' - C๓digo-'+ SB1->B1_COD +' - '+Space(15)+'DIPA008'
	  		  	Elseif	M->B1_PRVSUPE > SB1->B1_PRVSUPE  .And. SB1->B1_PRVSUPE > 0 
   		 	    	cTitCic  := 'PROMOวรO - Altera็ใo de pre็o.'                              
	  		  		cAssCic  := 'Produto continua em promo็ใo mas houve aumento no pre็o.'	+' - C๓digo-'+ SB1->B1_COD +' - '+Space(15)+'DIPA008'
   				Elseif	M->B1_PRVSUPE < SB1->B1_PRVSUPE  .And. M->B1_PRVSUPE > 0 
	   				cTitCic  := 'PROMOวรO - Altera็ใo de pre็o.'                              
	    			cAssCic  := 'Produto continua em promo็ใo e houve redu็ใo no pre็o'	+' - C๓digo-'+ SB1->B1_COD +' - '+Space(15)+'DIPA008'
	    		Elseif	M->B1_PRVSUPE > SB1->B1_PRVSUPE  .And. SB1->B1_PRVSUPE = 0                               
		    		cTitCic  := 'PROMOวรO'
	    			cAssCic  := 'Produto em promo็ใo.'	+' - C๓digo-'+ SB1->B1_COD +' - '+Space(15)+'DIPA008'
	    		Endif   
			 	U_EnvCic(aEnv_Pro,cAssCic,cTitCic,"PRO")	
 			  	U_Env_Pro(cEmail,cAssCic,aEnv_Pro)	

	    		MsgBox("Pre็o de promo็ใo alterado"+If(lPerProm,", perํodo de promo็ใo alterado","")+"!","ATENวรO","OK")	
	    	Endif  
	    	         
            If cEmpAnt == "01" 
	            lReplPrc := MsgYesNo("Atualiza o percentual de promo็ใo nas duas filiais?") 
	   	    Endif
	    	
			// Atualiza Kardex Geral 
			lOldAlter := Altera
			Altera := .T.  // Define variแvel altera como True para que a Rotina do GravaZG entenda que ้ altera็ใo.
			U_XULTPRC()
			U_GravaZG("SB1")
	   		Altera := lOldAlter
	   		
	   		// Atualiza tabela
	   		RecLock("SB1",.F.)
     		SB1->B1_PRVSUPE   := nVPromo
		    SB1->B1_MOSTPRO   := "N"      
	   	    SB1->B1_PERPROM   := cPerProm                                            		
			SB1->( MsUnLock() )        
		    SB1->( DbCommit() )  

		    //-- D'Leme: 12/09/2011 - R้plica entre filiais Dipromed (solu็ใo paliativa e rแpida escolhida)
		    If cEmpAnt == "01"  .And. lReplPrc
		    	aAreaAux := SB1->(GetArea())
		    	SB1->(DbSetOrder(1)) //-- B1_FILIAL+B1_COD
		    	If SB1->(DbSeek( xFilial("SB1",Iif(cFilAnt=="01","04","01")) + B1_COD ))
			   		RecLock("SB1",.F.)
		     		SB1->B1_PRVSUPE   := nVPromo
				    SB1->B1_MOSTPRO   := "N"      
			   	    SB1->B1_PERPROM   := cPerProm                                            		
					SB1->( MsUnLock() )        
				    SB1->( DbCommit() )        
		    	EndIf 
		    	RestArea( aAreaAux )
	    	EndIf
	    	
			If !('DIPM_B1'$FUNNAME()) .And. (VarType("l010Auto")=="U" .Or. !l010Auto)
				If SB1->B1_XCODDES<>'' .And. SB1->B1_XCXFECH == '1' .And.  SB1->B1_XVLDCXE == '1' .And. !Empty(SB1->B1_XCODDES)
					MsgBox("FAVOR ALTERAR  AS  MESMAS INFORMAวีES NO CำDIGO "+SB1->B1_XCODDES+"!","ATENวรO","OK")
				Endif
			EndIf		
			
		Endif
	ElseIf nOpcao = 1 .And. SB1->B1_PERPROM <> cPerProm .And. SB1->B1_PRVSUPE > 0

            If cEmpAnt == "01"       	
	            lReplPrc := MsgYesNo("Atualiza o percentual de promo็ใo nas duas filiais?") 
	   	    Endif
	   	    	
  			M->B1_PERPROM := cPerprom  				
			// Atualiza Kardex Geral 
			lOldAlter := Altera
			Altera := .T.  // Define variแvel altera como True para que a Rotina do GravaZG entenda que ้ altera็ใo.
			U_XULTPRC()
			U_GravaZG("SB1")
	   		Altera := lOldAlter                                        
	   		
	   		// Atualiza tabela
	   		RecLock("SB1",.F.) 
	   	    SB1->B1_PERPROM   := cPerProm                                            		
			SB1->( MsUnLock() )        
		    SB1->( DbCommit() )  
	
		    //-- D'Leme: 12/09/2011 - R้plica entre filiais Dipromed (solu็ใo paliativa e rแpida escolhida)
		    If cEmpAnt == "01"  .And. lReplPrc
		    	aAreaAux := SB1->(GetArea())
		    	SB1->(DbSetOrder(1)) //-- B1_FILIAL+B1_COD
		    	If SB1->(DbSeek( xFilial("SB1",Iif(cFilAnt=="01","04","01")) + B1_COD ))
			   		RecLock("SB1",.F.)
			   	    SB1->B1_PERPROM   := cPerProm                                            		
					SB1->( MsUnLock() )        
				    SB1->( DbCommit() )        
		    	EndIf 
		    	RestArea( aAreaAux )
	    	EndIf  
	    	
			If !('DIPM_B1'$FUNNAME()) .And. (VarType("l010Auto")=="U" .Or. !l010Auto)
				If SB1->B1_XCODDES<>'' .And. SB1->B1_XCXFECH == '1' .And.  SB1->B1_XVLDCXE == '1' .And. !Empty(SB1->B1_XCODDES)
					MsgBox("FAVOR ALTERAR  AS  MESMAS INFORMAวีES NO CำDIGO "+SB1->B1_XCODDES+"!","ATENวรO","OK")
				Endif
			EndIf	
			
    		MsgBox("Perํodo de promo็ใo alterado!" ,"ATENวรO","OK")  
    		
	ElseIf nOpcao = 1
		Alert("Nใo existem dados novos para gravar!")
	EndIf 
    lReplPrc := .T.
EndDo

Set Key VK_F8 TO U_CALC_PV()

Return()
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDIPA008   บAutor  ณMicrosiga           บ Data ณ  02/27/14   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function CalcPrc(nPVC,nNewPVL,nNewPVD,nNewPVC,nPCompra,nVCompra,nPICMSE,nVICMSE,nPICMSS,nVICMSS,nPICMS,nVICMS,nPRedICMS,nVRedICMS,nPIPI,nVIPI,nPIVA,nVIVA,nPST,nVST,nPPis,nVPis,nPCofins,nVCofins,nPAcresci,nVAcresci,nPDescont,nVDescont,nPBoni1,nVBoni1,nPBoni2,nVBoni2,nPAmerica,nVAmerica,nPCusto,nVCusto,nPMargem,nVMargem,nPComissao,nVComissao,nPFrete,nVFrete,nPTCusto,nVTCusto,nPMargemL,nVMargemL,nPPromo,nVPromo,nPDifICMSE,nVDifICMSE)

nVAmerica  := nPAmerica/100 * nVCompra
nVRedICMS  := nPRedICMS/100 * (nVCompra) //-nVAmerica)
nVICMSE    := nPICMSE/100 * Iif(nVRedICMS<>0,nVRedICMS,nVCompra) //-nVAmericA)  
//nPDifICMSE := Iif(nPICMSE==4 .Or. (nPICMSE<>SB1->B1_PICM .And. Posicione("SA2",1,xFilial('SA2')+SB1->B1_PROC+SB1->B1_LOJPROC,"A2_OPTSIMP")='2'),SB1->B1_PICM - nPICMSE,0) // Diferen็a de ICMS para produtos importados com aliquota de 4% 
nPDifICMSE := Iif(nPICMSE<>SB1->B1_PICM .And. SB1->B1_PICMENT=0,SB1->B1_PICM - nPICMSE,0) // Toda diferen็a de ICMS ้ considerada no custo
nVDifICMSE := nPDifICMSE/100 * Iif(nVRedICMS<>0,nVRedICMS,nVCompra)
nVIPI      :=  If(SB1->B1_PROC $ '000996/000997',0,nPIPI/100 * nVCompra)
nVIVA      := Iif(nPIVA=0,0,(1+nPIVA/100)*(Iif(nPRedICMS=38.89,nVCompra*nPRedICMS/100,nVCompra)+nVIPI)) //-nVAmericA))
nVICMSS    := nPICMSS/100 * nVIVA
nVST       := Iif(nPIVA<>0,nVICMSS - nVICMSE,0)
nVAcresci  := nPAcresci/100 * (nVCompra + NVIPI)
nVDescont  := nPDescont/100 * (nVCompra + NVIPI)
nVBoni1    := nPBoni1/100 * (nVCompra - nVDescont + nVAcresci)
nVBoni2    := nPBoni2/100 * (nVCompra - nVDescont + nVAcresci - nVBoni1)
nVCusto    := nVCompra + nVIPI + nVST + nVAcresci - nVDescont - nVBoni1 - nVBoni2 + nVDifICMSE

nNewPVL    := Iif(nPIVA=0,nVCusto-nVST,nVCusto)*(1+nPMargem/100)/1.2*1.6
nNewPVD    := nNewPVL*0.775
nNewPVC    := nNewPVL*0.75

nPST       := (nNewPVC/nVST)
nPCompra   := (1-(nNewPVC/nVCompra-1))*100
nPCusto    := (1-(nNewPVC/nVCusto-1))*100
nVMargem   := nNewPVC - nVCusto

nVICMS     := nPICMS/100 * Iif(nPST=0,nNewPVC - (nVCompra + nVIPI),0) // - nVAmericA),0)
nVPis      := nPPis/100 * ( nNewPVC - (nVCompra + nVIPI) ) // - nVAmericA) )
nVCofins   := nPCofins/100 * ( nNewPVC - (nVCompra + nVIPI) ) // - nVAmericA) )
nVComissao := nPComissao/100 * nNewPVC
nVFrete    := nPFrete/100 * nNewPVC
nVTCusto   := nVCusto + nVComissao + nVFrete + nVPis + nVCofins + nVICMS
nPTCusto   := (1-(nNewPVC/nVTCusto-1))*100
nPMargemL  := (nNewPVC/nVTCusto-1)*100
nVMargemL  := nNewPVC - nVTCusto

nPPromo  := (nVPromo/nVCusto-1)*100

/*
nVST := ( Iif( nPAmerica<>0,nVCusto * (1-nPAmerica/100),nVCusto) * (1+nPIPI/100) * Iif(nPIVA=0,(1+nPMargem/100),(1+nPIVA/100)) * (nPICMSS/100);
         - Iif(nPRedICMS<>0,Iif(nPAmerica<>0,nVCusto*(1-nPAmerica/100),nVCusto)*nPRedICMS/100,Iif(nPAmerica<>0,nVCusto*(1-nPAmerica/100),nVCusto))*nPICMSE/100 )

nVTCusto := nVCusto + (nVCusto*nPIPI/100) + nVST + (nVCusto*nPAcresci/100) - (nVCusto*nPDescont/100)

nNewPVL := Iif(nPIVA=0,nVTCusto-nVST,nVTCusto)*(1+nPMargem/100)/1.2*1.6
nNewPVD := nNewPVL*0.775
nNewPVC := nNewPVL*0.75

nVPis      := nPPis/100 * ( nNewPVC -(nVCusto + nVCusto*nPIPI/100) ) 
nVCofins   := nPCofins/100 * ( nNewPVC -(nVCusto + nVCusto*nPIPI/100) ) 
nVComissao := nPComissao/100 * nNewPVC
nVFrete    := nPFrete/100 * nNewPVC
nTotVCusto := nVTCusto + nVPis + nVCofins + nVComissao + nVFrete
nPMargemL  := (nNewPVC/nTotVCusto-1)*100
*/
nVar:=(nNewPVC/nPVC-1)*100
//@ 023,248 Say 'Varia็ใo %' Pixel COLOR CLR_RED
//@ 033,240 Get nVar Picture "@E 9999.99" Size 3,8 Pixel COLOR CLR_RED When .f.  // percentual de aumento/diminui็ใo

Return(.t.)   

////////////////////////////////////////////////////////////////////////////////
/*               
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDigValor บ Autor ณ Maximo             บ Data ณ 18/02/2009   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Para solicitar um valor sem valida็ใo  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ ESPECIFICO DIPROMED                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
*-------------------------------*
Static Function DigValor(nValor)
*-------------------------------*
Local bOk:={|| nOpcao:=1,lSaida := .T.,oDlg:End()}
Local oDlg
Local oBt1
Local oBt2
Local nOpcao  := 0   
Local lSaida  := .F.         

Do While !lSaida
	nOpcao := 0
	Define msDialog oDlg title OemToAnsi("Altera็ใo do Pre็o C") From 09,10 TO 15,45
	@ 002,002 to 045,136 pixel
	@ 010,010 say "C:"      Pixel
	@ 010,030 get oValor var nValor Size 60,08 pixel  Picture "@E 9,999,999.9999"
	Define sbutton oBt1 from 030,090 type 1 action Eval(bOK) enable of oDlg
	Activate Dialog oDlg Centered                          
EndDo                            
                              
Return(nValor)   
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDIPA008   บAutor  ณMicrosiga           บ Data ณ  02/27/14   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function DipFilSB1(lInc)
Local oMark 	:= GetMarkBrow()
DEFAULT lInc 	:= .F.

U_DipMonTmp(U_DipTelFor(),lInc)

MarkBRefresh()               
oMark:oBrowse:Gotop()

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDIPA008   บAutor  ณMicrosiga           บ Data ณ  02/27/14   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function DipMonTmp(cFornece,lIncPro,lCheck)
Local cSQL 		 := ""                                                            
Local cData		 := DtoC(DataValida(dDataBase+1,.T.))
DEFAULT cFornece := ""                  
DEFAULT lIncPro  := .F.                        
DEFAULT lCheck   := .F.                

cData := SubStr(cData,7,2)+SubStr(cData,4,2)+SubStr(cData,1,2)

cSQL := " SELECT "
cSQL += " 	B1_OK2,B1_COD,B1_DESC,B1_PROC,B1_PERPROM,B1_PRV1,B1_PRVSUPE,B1_PRVMINI,B1_PRVPROM,B1_NPROMOC,B1_MOSTPRO "
cSQL += " 	FROM "
cSQL +=  		RetSQLName("SB1")
cSQL += " 		WHERE "
cSQL += " 			B1_FILIAL = '"+xFilial("SB1")+"' AND "
If !Empty(cFornece)                                                  
	cSQL += " 		B1_PROC = '"+cFornece+"' AND "
EndIf
If lIncPro
	cSQL += " 		B1_PERPROM = ' ' AND "	
Else
	cSQL += " 		B1_PERPROM <> ' ' AND "
	cSQL += " 		LEN(RTRIM(LTRIM(B1_PERPROM)))= 17 AND "     
	cSQL += " 		SUBSTRING(B1_PERPROM,16,2)+SUBSTRING(B1_PERPROM,13,2)+SUBSTRING(B1_PERPROM,10,2) <= '"+cData+"' AND
	//cSQL += " 		RIGHT(B1_PERPROM,8) < '"+DtoC(dDataBase)+"' AND "
EndIf
cSQL += " 			D_E_L_E_T_ = ' ' "
cSQL += " ORDER BY B1_DESC "

cSQL := ChangeQuery(cSQL)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),"QRYSB1",.T.,.T.)         

TCSETFIELD("QRYSB1","B1_PRV1"   ,"N",12,4)
TCSETFIELD("QRYSB1","B1_PRVSUPE","N",12,4)
TCSETFIELD("QRYSB1","B1_PRVMINI","N",12,4)
TCSETFIELD("QRYSB1","B1_PRVPROM","N",12,4)

If !lCheck
	TRBSB1->(dbGoTop())
	While !TRBSB1->(Eof())           
		TRBSB1->(RecLock("TRBSB1",.F.))
			TRBSB1->(dbDelete())
		TRBSB1->(MsUnlock())
		TRBSB1->(dbSkip())
	EndDo
	      
	While !QRYSB1->(Eof())
		TRBSB1->(dbAppend())  
		TRBSB1->B1_OK2     	:= QRYSB1->B1_OK2
		TRBSB1->B1_COD		:= QRYSB1->B1_COD
		TRBSB1->B1_DESC		:= QRYSB1->B1_DESC
		TRBSB1->B1_PROC		:= QRYSB1->B1_PROC
		TRBSB1->B1_PERPROM	:= QRYSB1->B1_PERPROM
		TRBSB1->B1_PRV1		:= QRYSB1->B1_PRV1
		TRBSB1->B1_PRVSUPE	:= QRYSB1->B1_PRVSUPE
		TRBSB1->B1_PRVMINI	:= QRYSB1->B1_PRVMINI
		TRBSB1->B1_PRVPROM	:= QRYSB1->B1_PRVPROM
		TRBSB1->B1_NPROMOC	:= QRYSB1->B1_NPROMOC
		TRBSB1->B1_MOSTPRO	:= QRYSB1->B1_MOSTPRO
		QRYSB1->(dbSkip())
	EndDo
	
	TRBSB1->(dbGoTop())
Else
	lCheck := !QRYSB1->(Eof())	
EndIf
QRYSB1->(dbCloseArea())

Return lCheck
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDIPA008   บAutor  ณMicrosiga           บ Data ณ  02/27/14   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function DipTelFor()
Local oDlg                
Local cFornece  := Space(06)
Local nOpcao    := 0		

@ 126,000 To 300,350 DIALOG oDlg TITLE OemToAnsi("Informe o c๓digo do Fornecedor")
@ 010,010 Say "Fornecedor: "
@ 010,045 Get cFornece  size 60,20 Picture "999999" F3 "SA2"
@ 070,010 BMPBUTTON TYPE 1 ACTION  (nOpcao := 1,Close(oDlg))
@ 070,065 BMPBUTTON TYPE 2 ACTION  (nOpcao := 0,Close(odlg))
ACTIVATE DIALOG oDlg Centered 

Return cFornece     
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDIPA008   บAutor  ณMicrosiga           บ Data ณ  02/27/14   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function DipMarkAll()
Local oMark := GetMarkBrow()

TRBSB1->(DbGotop())

While !TRBSB1->(Eof())
	TRBSB1->(RecLock( "TRBSB1", .F. ))
		TRBSB1->B1_OK2 := IIf(Empty(TRBSB1->B1_OK2),cMarca,"")
	TRBSB1->(MsUnLock())
	TRBSB1->(dbSkip())
Enddo

MarkBRefresh()      
oMark:oBrowse:Gotop()

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDIPA008   บAutor  ณMicrosiga           บ Data ณ  04/29/16   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function DipPesqB8()
Local oPesq
Local cPesq := Space(250)

DEFINE MSDIALOG oDlg TITLE "Pesquisa Produto" From 126,000 TO 210,300 OF oMainWnd PIXEL 
	@ 005,005 SAY "Descri็ใo: " 	 	SIZE 100,008 	OF oDlg PIXEL
	@ 015,005 MSGET oPesq VAR cPesq 	SIZE 140,008	OF oDlg PIXEL PICTURE "@!" VALID !Empty(cPesq)
	@ 028,087 BmpButton Type 1 Action (Close(oDlg),PesqDesB8(cPesq))
	@ 028,117 BmpButton Type 2 Action Close(oDlg)
ACTIVATE DIALOG oDlg CENTERED
	
Return            
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDIPA008   บAutor  ณMicrosiga           บ Data ณ  04/29/16   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function PesqDesB8(cPesq)

TRBSB1->(dbSeek(AllTrim(cPesq)))
TRBSB1->(dbGoTo(Recno()))

Return

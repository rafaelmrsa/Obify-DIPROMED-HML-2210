/*                                                              Sao Paulo,  30 Jun 2006
---------------------------------------------------------------------------------------
Empresa.......: DIPOMED Comércio e Importação Ltda.
Programa......: DIPM018.PRW
Objetivo......: Integração de informações das notas fiscais com a transportadora

Autor.........: Jailton B Santos, JBS
Data..........: 30 Jun 2006

Versão........: 1.0
Consideraçoes.: Função chamada direto do menu ->U_DipM018()

------------------------------------------------------------------------------------
*/
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "AP5MAIL.CH"
#DEFINE ENTER CHR(13)+CHR(10)
#DEFINE say_tit 1
#DEFINE say_det 2
#DEFINE say_rep 3
*---------------------------------------------*
User Function DipM018()
*---------------------------------------------*
local oDlg
local nOpcao:=0
local bOK:={|| nOpcao := 1, EdiSeleciona(), SX1->(DipPergDiverg(.f.))}
local bCancel:={|| nOpcao := 0, oDlg:End()}
local lRetorno:=.T.
local lMarcados:=.F.
private cPerg:="DIPM18"
Private cMarca:=GetMark()
Private lInverte:=.F.
Private cEmpEdi:= GetMv("ES_EMPEDI")
Private cEndEdi:= GetMv("ES_ENDEDI")
Private cMunEdi:= GetMv("ES_MUNEDI")
Private cCepEdi:= GetMv("ES_CEPEDI")
Private cEstEdi:= GetMv("ES_ESTEDI")
private cCodTransp:=criavar("F2_TRANSP",.f.)
private cNomTransp:=criavar("A4_NOME",.f.)
private cNomReduz:=criavar("A4_NREDUZ",.f.)
private cPlacCamin:=criavar("F2_PLCCAMI",.f.)
private cMotorista:=criavar("F2_MOTORIS",.f.)
private cAjudante:=criavar("F2_AJUDANT",.f.)
private cOperExped:=criavar("F2_OPEREXP",.f.)
private cNotaIni:=criavar("F2_DOC",.f.)
private cNotaFin:=criavar("F2_DOC",.f.)
private cSerie:=criavar("F2_SERIE",.f.)
private dDtSaida:=dDataBase //criavar("F2_DTSAIDA",.f.)
Private cHrEntrada:='10:00:00'
private cHrSaida:=Time() //criavar("F2_HRSAIDA",.f.)
private aitens :={"","Sim","Nao"}
private lPrevia:=.t.
private lGeraOf:=.f.
private lTemEmail:=.t.
private lTemEDI:=.t.
private oPrevia
private oGeraOf
private oCodTransp
private oNomTransp
private oPlacCamin
private oMotorista
private oOperExped
private oNotaIni
private oNotaFin
private oSerie
private oDtSaida
private oHrSaida  
private oItens
private cFileWork
private cFileEDI
private nVolume
private nTotNF
private nSomaLinha:=1   

U_DIPPROC(ProcName(0),U_DipUsr()) // MCVN - 22/01/2009

SX1->(DipPergDiverg(.t.))
Define msDialog oDlg title OemToAnsi("EDI para Transportadora") From 00,00 TO 23,52
@ 002,002 to 160,204 pixel
@ 010,010 say "Codigo da transportadora" Pixel
@ 020,010 say "Nome da transportadora" Pixel
@ 030,010 say "Nr da nota fiscal inicial" Pixel
@ 040,010 say "Nr da nota fiscal final" Pixel
@ 050,010 say "Serie das notas fiscais" Pixel
@ 060,010 say "Placa do caminhão" Pixel
@ 070,010 say "Nome do motorista" Pixel
@ 080,010 say "Nome do ajudante do caminhão" pixel
@ 090,010 say "Nome do operador de expedição" Pixel
@ 100,010 say "Hora de Chegada do caminhão" Pixel
@ 110,010 say "Data de saida do caminhão" Pixel
@ 120,010 say "Hora de saida do caminhão" Pixel
@ 130,010 SAY "Transporte adequado (Fechado x Limpo)" Pixel
@ 010,100 msget oCodTransp var cCodTransp F3 "SA4" valid EdiValid('CODTRANSP') size 40,08 pixel
@ 020,100 msget oNomTransp var cNomTransp when .f. valid EdiValid('NOMTRANSP') size 90,08 pixel
@ 030,100 msget oNotaIni   var cNotaIni   valid EdiValid('NOTAINI') size 40,08 pixel
@ 040,100 msget oNotaFin   var cNotaFin   valid EdiValid('NOTAFIN') size 40,08 pixel
@ 050,100 msget oSerie     var cSerie     valid EdiValid('SERIE') size 20,08 pixel
@ 060,100 msget oPlacCamin var cPlacCamin valid EdiValid('PLACA') picture "!!!9!!9" size 40,08 pixel
@ 070,100 msget oMotorista var cMotorista valid EdiValid('MOTORISTA') size 90,08 pixel
@ 080,100 msget oAjudante  var cAjudante  valid EdiValid('AJUDANTE') size 90,08 pixel
@ 090,100 msget oOperExped var cOperExped valid EdiValid('EXPEDICAO') size 90,08 pixel
@ 100,100 msget oHrEntrada var cHrEntrada valid EdiValid('HRENTRADA') picture "99:99:99" size 40,08 pixel
@ 110,100 msget oDtSaida   var dDtSaida   valid EdiValid('DTSAIDA') size 40,08 pixel
@ 120,100 msget oHrSaida   var cHrSaida   valid EdiValid('HRSAIDA') picture "99:99:99" size 40,08 pixel
@ 130,110 ComboBox oItens  items aItens   valid EdiValid('TRANSPAD') of oDlg pixel size 030,08 
@ 140,010 checkbox oPrevia var lPrevia PROMPT "Previa do Romaneio para Conferencia" size 110,008 of oDlg on change Dpm18SeleTipo(oPrevia,oGeraOf,oBt1,'1')
@ 150,010 checkbox oGeraOf var lGeraOf PROMPT "Gera Romaneio, EDI e Envia E-amail" size 110,008 of oDlg on change Dpm18SeleTipo(oPrevia,oGeraOf,oBt1,'2',)

Define sbutton oBt1 from 162,130 type 1 action Eval(bOK) enable of oDlg
Define sbutton oBt2 from 162,170 type 2 action Eval(bCancel) enable of oDlg
Activate Dialog oDlg Centered
Return(.t.)
*----------------------------------------------------------*
Static function Dpm18SeleTipo(oPrevia,oGeraOf,oBt1,cCheck)
*----------------------------------------------------------*
If(cCheck=='1'.and.lPrevia,lGeraOf:=.f.,)
If(cCheck=='2'.and.lGeraOf,lPrevia:=.f.,)
oPrevia:Refresh()
oGeraOf:Refresh()
oBt1:SetFocus()
RETURN(.T.)
*--------------------------------*
Static function EdiValid(cCampo)
*--------------------------------*
local lretorno := .t.
do case
	case cCampo == 'CODTRANSP'
		SA4->(dbSetOrder(1))
		If SA4->(dbSeek(xFilial('SA4')+cCodTransp))
			cNomTransp := SA4->A4_NOME
			cNomReduz  := SA4->A4_NREDUZ

			If !Empty(SA4->A4_EDIEMAI) .and. At('.',SA4->A4_EDIEMAI) > 0 .and. At('@',SA4->A4_EDIEMAI) > 0 .and. !Empty(SA4->A4_EDIREGI)
			   lTemEDI:= .t.   // Gera o arquivo de EDI
			   lTemEmail:=.t.  // Envia email de EDI
			Else
			   lTemEDI:=.f.	  // Não gera o arquivo de EDI		   
			   lTemEmail:=.f. // Não envia o email
			   If !Empty(SA4->A4_EDIREGI)
			      lTemEDI:=.t.
			   EndIf
			EndIf
			oNomTransp:Refresh()
	    Else
			MsgInfo('Codigo da transportadora não encontrado!','Atenção')
			lretorno := .F.
		EndIf
	case cCampo == 'NOTAINI'         
	    If empty(cNotaIni)
			MsgInfo('É necessario informar o numero da nota fiscal inicial','Atenção')
			lretorno := .F.
		EndIf	
	case cCampo == 'NOTAFIN'
	    If empty(cNotaFin)
			MsgInfo('É necessario informar o numero da nota fiscal final','Atenção')
			lretorno := .F.
		EndIf	
	case cCampo == 'SERIE'
	    If empty(cSerie)
			MsgInfo('É necessario informar a serie das notas fiscais','Atenção')
			lretorno := .F.
		EndIf	
	case cCampo == 'PLACA'
	    If empty(cPlacCamin)
			MsgInfo('É necessario informar a placa do caminhão/carreta','Atenção')
			lretorno := .F.
		EndIf	
	case cCampo == 'MOTORISTA'
	    If empty(cMotorista)
			MsgInfo('É necessario informar o nome do motorista do caminhão/carreta','Atenção')
			lretorno := .F.
		EndIf	
	case cCampo == 'AJUDANTE'
	    If empty(cAjudante)
			MsgInfo('É necessario informar o nome do ajudante do caminhão/carreta','Atenção')
			lretorno := .F.
		EndIf	
	case cCampo == 'EXPEDICAO'
	    If empty(cOperExped)
			MsgInfo('É necessario informar o nome do operador de expedição','Atenção')
			lretorno := .F.
		EndIf	
	case cCampo == 'HRENTRADA'
	    If empty(cHrEntrada)
			MsgInfo('É necessario informar a hora de entrada caminhão/carreta no CLD','Atenção')
			lretorno := .F.
		EndIf	
	case cCampo == 'DTSAIDA'
	    If empty(dDtSaida)
			MsgInfo('É necessario informar a data de saida do caminhão/carreta do CLD','Atenção')
			lretorno := .F.
		EndIf	
	case cCampo == 'HRSAIDA'
	    If empty(cHrSaida)
			MsgInfo('É necessario informar a hora de saida do caminhão/carreta do CLD','Atenção')
			lretorno := .F.
		EndIf	
	case cCampo == 'TRANSPAD'
	    If Type("oItens") == "U"
			MsgInfo('É necessario informar se a transportadora está adequada, Sim / Nao','Atenção')
			lretorno := .F.
		EndIf		
				
endcase
Return(lretorno)
*--------------------------------*
Static Function EdiSeleciona()
*--------------------------------*
local oDlg
local nOpcao:=0
local bOK:={|| nOpcao:=1,Dp18E_Report(),EdiGera(),SendMail(),oDlg:End()}
local bCancel:={|| nOpcao:=0,oDlg:End()}
local aButtons:={}
local lRetorno:=.T.
local cQuery
local aEstruWork:={}
Local lTranspAd := .T.

Local oTempTable

lTranspAd := EdiValid('TRANSPAD')
If !lTranspAd
	Return(lTranspAd)
EndIf

Private cIdentInter:=If(!lTemEDI,'DIP','NOT')+SubStr(dTos(dDataBase),7,2)+SubStr(dTos(dDataBase),5,2)+SubStr(time(),1,2)+SubStr(time(),4,2)
Private cNomeArq   :=If(!lTemEDI,'DIP','NOT')+AllTrim(cCodTransp)+SubStr(dTos(dDataBase),7,2)+SubStr(dTos(dDataBase),5,2)+SubStr(time(),1,2)+SubStr(time(),4,2)+SubStr(time(),7,2)
Private aCposSF:={}
Private aEstrEDI:={{"WK_EDI","C",284,0}}                                      
//Private cEdi:=GetSrvProfString("STARTPATH","")+"EDI\ENVIO\"+cIdentInter+".TXT" 

// Alterado para gravar arquivos na pasta protheus_data - Por Sandro em 19/11/09. 
Private cEdi:= "\EDI\ENVIO\"+cNomeArq+".TXT"

Private cParCar:='000000'
Private nParada:=0
Private nQtdMarc:=0

//aadd(aButtons,{'IMPRESSAO',{|| Dp18E_Report()},'Gera relatorio de Notas fiscais enviadas'})
aadd(aButtons,{'LBTIK',{|| Dp18MarcTodos(oMark)},'Marca ou Desmarca todas as notas fiscais'})

aHeader:={}
aCampos:={} 

If Select("WORK_EDI") > 0
	DBSelectArea("WORK_EDI")
	DBCloseArea()
EndIf

/*
cFileEDI:=CriaTrab(aEstrEDI,.T.)
DbUseArea(.T.,,cFileEDI,"WORK_EDI",.F.,.F.)
*/
	If(oTempTable <> NIL)
		oTempTable:Delete()
		oTempTable := NIL
	EndIf
	oTempTable := FWTemporaryTable():New("WORK_EDI")
	oTempTable:SetFields( aEstrEDI )
	oTempTable:Create()

	DbSelectArea("WORK_EDI")

aadd(ACPOSSF,{"WKFLAG"     ,, ""})
If !lTemEDI
	aadd(ACPOSSF,{"WKSEQ"      ,, 'Parada'})
	aadd(ACPOSSF,{"F2_DOC"     ,, AvSx3("F2_DOC",5)})
	aadd(ACPOSSF,{"F2_SERIE"   ,, AvSx3("F2_SERIE",5)})
	aadd(ACPOSSF,{"C5_CEPE"    ,, AvSx3("C5_CEPE",5)})
 	aadd(ACPOSSF,{"C5_BAIRROE" ,, AvSx3("C5_BAIRROE",5)})
 	aadd(ACPOSSF,{"C5_MUNE"    ,, AvSx3("C5_MUNE",5)})
	aadd(ACPOSSF,{"F2_DOC"     ,, AvSx3("F2_DOC",5)})
	aadd(ACPOSSF,{"F2_CLIENTE" ,, AvSx3("F2_CLIENTES",5)})
	aadd(ACPOSSF,{"F2_LOJA"    ,, AvSx3("F2_LOJA",5)})
	aadd(ACPOSSF,{"D2_PEDIDO"  ,, AvSx3("D2_PEDIDO",5)})
	aadd(ACPOSSF,{"F2_VOLUME1" ,, AvSx3("F2_VOLUME1",5), "@e 9999"})
	aadd(ACPOSSF,{"F2_PBRUTO"  ,, AvSx3("F2_PBRUTO",5) , "@e 9,999,999.999"})
	aadd(ACPOSSF,{"C5_CONDPAG" ,, AvSx3("C5_CONDPAG",5)})
	aadd(ACPOSSF,{"E4_DESCRI"  ,, AvSx3("E4_DESCRI",5)})
Else
	aadd(ACPOSSF,{"WKSEQ"      ,, 'Ordem'})
	aadd(ACPOSSF,{"F2_DOC"     ,, AvSx3("F2_DOC",5)})
	aadd(ACPOSSF,{"F2_SERIE"   ,, AvSx3("F2_SERIE",5)})
	aadd(ACPOSSF,{"C5_CEPE"    ,, AvSx3("C5_CEPE",5)})
	aadd(ACPOSSF,{"C5_MUNE"    ,, AvSx3("C5_MUNE",5)})
	aadd(ACPOSSF,{"F2_EMISSAO" ,, AvSx3("F2_EMISSAO",5)})
	aadd(ACPOSSF,{"F2_CLIENTE" ,, AvSx3("F2_CLIENTES",5)})
	aadd(ACPOSSF,{"F2_LOJA"    ,, AvSx3("F2_LOJA",5)})
	aadd(ACPOSSF,{"D2_PEDIDO"  ,, AvSx3("D2_PEDIDO",5)})
	aadd(ACPOSSF,{"F2_VOLUME1" ,, AvSx3("F2_VOLUME1",5), "@e 9999"})
	aadd(ACPOSSF,{"F2_PBRUTO"  ,, AvSx3("F2_PBRUTO",5) , "@e 9,999,999.999"})
	aadd(ACPOSSF,{"C5_CONDPAG" ,, AvSx3("C5_CONDPAG",5)})
	aadd(ACPOSSF,{"E4_DESCRI"  ,, AvSx3("E4_DESCRI",5)})
EndIf
//--------------------------------------------
// Campos de Controle gerados e_criatrab
//--------------------------------------------
aHeader:={}
aCampos:={}
aEstruWork:={}
aadd(aEstruWork,{"WKFLAG"    , "C" ,2,0})
aadd(aEstruWork,{"F2_DOC"    , AvSx3("F2_DOC" ,2)     ,AvSx3("F2_DOC" ,3)     ,AvSx3("F2_DOC"    ,4)})
aadd(aEstruWork,{"F2_SERIE"  , AvSx3("F2_SERIE" ,2)   ,AvSx3("F2_SERIE" ,3)   ,AvSx3("F2_SERIE"  ,4)})
aadd(aEstruWork,{"F2_EMISSAO", AvSx3("F2_EMISSAO" ,2) ,AvSx3("F2_EMISSAO" ,3) ,AvSx3("F2_EMISSAO",4)})
aadd(aEstruWork,{"F2_CLIENTE", AvSx3("F2_CLIENTE" ,2) ,AvSx3("F2_CLIENTE" ,3) ,AvSx3("F2_CLIENTE",4)})
aadd(aEstruWork,{"F2_LOJA"   , AvSx3("F2_LOJA" ,2)    ,AvSx3("F2_LOJA" ,3)    ,AvSx3("F2_LOJA"   ,4)})
aadd(aEstruWork,{"F2_VOLUME1", AvSx3("F2_VOLUME1" ,2) ,AvSx3("F2_VOLUME1" ,3) ,AvSx3("F2_VOLUME1" ,4)})
aadd(aEstruWork,{"F2_VALBRUT", AvSx3("F2_VALBRUT" ,2) ,AvSx3("F2_VALBRUT" ,3) ,AvSx3("F2_VALBRUT",4)})
aadd(aEstruWork,{"F2_VALMERC", AvSx3("F2_VALMERC" ,2) ,AvSx3("F2_VALMERC" ,3) ,AvSx3("F2_VALMERC",4)})
aadd(aEstruWork,{"F2_PBRUTO" , AvSx3("F2_PBRUTO" ,2)  ,AvSx3("F2_PBRUTO" ,3)  ,AvSx3("F2_PBRUTO" ,4)})
aadd(aEstruWork,{"F2_FRETE"  , AvSx3("F2_FRETE" ,2)   ,AvSx3("F2_FRETE" ,3)   ,AvSx3("F2_FRETE"  ,4)})
aadd(aEstruWork,{"F2_ICMSRET", AvSx3("F2_ICMSRET" ,2) ,AvSx3("F2_ICMSRET" ,3) ,AvSx3("F2_ICMSRET",4)})
aadd(aEstruWork,{"F2_VALICM" , AvSx3("F2_VALICM" ,2)  ,AvSx3("F2_VALICM" ,3)  ,AvSx3("F2_VALICM" ,4)})
aadd(aEstruWork,{"D2_PEDIDO" , AvSx3("D2_PEDIDO" ,2)  ,AvSx3("D2_PEDIDO" ,3)  ,AvSx3("D2_PEDIDO" ,4)})
aadd(aEstruWork,{"A1_NOME"   , AvSx3("A1_NOME"   ,2)  ,AvSx3("A1_NOME" ,3) 	  ,AvSx3("A1_NOME"   ,4)})
aadd(aEstruWork,{"C5_ESTE"   , AvSx3("C5_ESTE"   ,2)  ,AvSx3("C5_ESTE" ,3)    ,AvSx3("C5_ESTE"   ,4)})
aadd(aEstruWork,{"C5_MUNE"   , AvSx3("C5_MUNE"   ,2)  ,AvSx3("C5_MUNE"   ,3)  ,AvSx3("C5_MUNE"   ,4)})
aadd(aEstruWork,{"C5_ENDENT" , AvSx3("C5_ENDENT" ,2)  ,AvSx3("C5_ENDENT",3)   ,AvSx3("C5_ENDENT" ,4)})
aadd(aEstruWork,{"C5_BAIRROE", AvSx3("C5_BAIRROE",2)  ,AvSx3("C5_BAIRROE",3)  ,AvSx3("C5_BAIRROE",4)})
aadd(aEstruWork,{"C5_CEPE"   , AvSx3("C5_CEPE"   ,2)  ,AvSx3("C5_CEPE" ,3)    ,AvSx3("C5_CEPE"   ,4)})
aadd(aEstruWork,{"C5_CONDPAG", AvSx3("C5_CONDPAG",2)  ,AvSx3("C5_CONDPAG",3)  ,AvSx3("C5_CONDPAG",4)})
aadd(aEstruWork,{"E4_DESCRI" , AvSx3("E4_DESCRI" ,2)  ,AvSx3("E4_DESCRI" ,3)  ,AvSx3("E4_DESCRI" ,4)})
aadd(aEstruWork,{"WKSEQ"     , "C" ,06,0})
aadd(aEstruWork,{"WKCHEGADA" , "C" ,15,0})
aadd(aEstruWork,{"WKSAIDA"   , "C" ,15,0})
aadd(aEstruWork,{"WKCARIMBO" , "C" ,30,0})
aadd(aEstruWork,{"F2_RECNO"  , "N" ,06,0})
aadd(aEstruWork,{"F2_NF"     , "C" ,13,0})
aadd(aEstruWork,{"F2_EXP"    , "C" ,36,0})

cFileWork:=E_CriaTrab(,aEstruWork,"WORK_NF",)

If lTemEDI
    IndRegua("WORK_NF",cFileWork+"A","F2_DOC+F2_SERIE")
    IndRegua("WORK_NF",cFileWork+"B","WKSEQ + F2_DOC+F2_SERIE")
Else     
    IndRegua("WORK_NF",cFileWork+"A","F2_DOC+F2_SERIE")
    IndRegua("WORK_NF",cFileWork+"B","WKSEQ + F2_DOC+F2_SERIE")
//    IndRegua("WORK_NF",cFileWork+"A","C5_CEPE + C5_MUNE + C5_BAIRROE + C5_ESTE + F2_DOC")
//    IndRegua("WORK_NF",cFileWork+"B","WKSEQ + C5_CEPE + C5_MUNE + C5_BAIRROE + C5_ESTE + F2_DOC")
EndIf
dbClearIndex()
//dbSetIndex(cFileWork+"A"+OrdBagExt())
//dbSetIndex(cFileWork+"B"+OrdBagExt())
/*
SELECT F2_DOC, F2_SERIE, F2_EMISSAO, F2_CLIENTE, F2_LOJA, F2_VOLUME1, F2_VALBRUT, F2_PBRUTO, F2_FRETE, F2_ICMSRET, F2_VALICM, A1_NOME,
 (SELECT DISTINCT D2_PEDIDO
             FROM SD2010 SD2
            WHERE SD2.D_E_L_E_T_ <> '*'
              AND D2_DOC = SF2.F2_DOC
              AND D2_SERIE = SF2.F2_SERIE
              AND D2_FILIAL = '04') D2_PEDIDO,
 (SELECT DISTINCT C5_ESTE
             FROM SD2010 SD2, SC5010 SC5
            WHERE SD2.D_E_L_E_T_ <> '*'
              AND D2_DOC = SF2.F2_DOC
              AND D2_SERIE = SF2.F2_SERIE
              AND D2_FILIAL = '04'
              AND C5_NUM = D2_PEDIDO
              AND SC5.D_E_L_E_T_ <> '*'
              AND C5_FILIAL = '04') C5_ESTE, 
 (SELECT DISTINCT C5_MUNE
             FROM SD2010 SD2, SC5010 SC5
            WHERE SD2.D_E_L_E_T_ <> '*'
              AND D2_DOC = SF2.F2_DOC
              AND D2_SERIE = SF2.F2_SERIE
              AND D2_FILIAL = '04'
              AND C5_NUM = D2_PEDIDO
              AND SC5.D_E_L_E_T_ <> '*'
              AND C5_FILIAL = '04') C5_MUNE, 
 (SELECT DISTINCT C5_CEPE
             FROM SD2010 SD2, SC5010 SC5
            WHERE SD2.D_E_L_E_T_ <> '*'
              AND D2_DOC = SF2.F2_DOC
              AND D2_SERIE = SF2.F2_SERIE
              AND D2_FILIAL = '04'
              AND C5_NUM = D2_PEDIDO
              AND SC5.D_E_L_E_T_ <> '*'
              AND C5_FILIAL = '04') C5_CEPE, 
 (SELECT DISTINCT C5_BAIRROE
             FROM SD2010 SD2, SC5010 SC5
            WHERE SD2.D_E_L_E_T_ <> '*'
              AND D2_DOC = SF2.F2_DOC
              AND D2_SERIE = SF2.F2_SERIE
              AND D2_FILIAL = '04'
              AND C5_NUM = D2_PEDIDO
              AND SC5.D_E_L_E_T_ <> '*'
              AND C5_FILIAL = '04') C5_BAIRROE, 
 (SELECT DISTINCT C5_ENDENT
             FROM SD2010 SD2, SC5010 SC5
            WHERE SD2.D_E_L_E_T_ <> '*'
              AND D2_DOC = SF2.F2_DOC
              AND D2_SERIE = SF2.F2_SERIE
              AND D2_FILIAL = '04'
              AND C5_NUM = D2_PEDIDO
              AND SC5.D_E_L_E_T_ <> '*'
              AND C5_FILIAL = '04') C5_ENDENT,
 (SELECT DISTINCT C5_CONDPAG
             FROM SD2010 SD2, SC5010 SC5
            WHERE SD2.D_E_L_E_T_ <> '*'
              AND D2_DOC = SF2.F2_DOC
              AND D2_SERIE = SF2.F2_SERIE
              AND D2_FILIAL = '04'
              AND C5_NUM = D2_PEDIDO
              AND SC5.D_E_L_E_T_ <> '*'
              AND C5_FILIAL = '04') C5_CONDPAG,
 (SELECT DISTINCT E4_DESCRI
             FROM SD2010 SD2, SC5010 SC5, SE4010 SE4
            WHERE SD2.D_E_L_E_T_ <> '*'
              AND D2_DOC = SF2.F2_DOC
              AND D2_SERIE = SF2.F2_SERIE
              AND D2_FILIAL = '04'
              AND C5_NUM = D2_PEDIDO
              AND SC5.D_E_L_E_T_ <> '*'
              AND C5_FILIAL = '04'
              AND E4_CODIGO = C5_CONDPAG
              AND E4_FILIAL = ''
              AND SE4.D_E_L_E_T_ <> '*') E4_DESCRI,
 SF2.R_E_C_N_O_ as F2_RECNO,
A1_EST,  A1_CEP,  A1_BAIRRO,
A1_MUN,  A1_END
FROM SF2010 SF2, SA1010 SA1 
WHERE SF2.D_E_L_E_T_ <> '*'
   AND F2_FILIAL = '04'
   AND F2_TRANSP = '000150'
   AND F2_IDINTER = ''
   AND F2_DOC BETWEEN '118844' AND '118846'
   AND F2_SERIE = '1  '
   AND A1_COD = F2_CLIENTE
   AND SA1.D_E_L_E_T_ <> '*'
 ORDER BY F2_FILIAL, F2_SERIE, F2_DOC
*/                 

cQuery := " SELECT F2_DOC, F2_SERIE, F2_EMISSAO, F2_CLIENTE, F2_LOJA, F2_VOLUME1, F2_VALBRUT, F2_VALMERC, F2_PBRUTO, F2_FRETE, F2_ICMSRET, F2_VALICM, A1_NOME, F2_DOC+'/'+F2_SERIE F2_NF, "

cQuery += " (SELECT DISTINCT D2_PEDIDO"
cQuery += "             FROM "+RetSqlName('SD2')+ " SD2"
cQuery += "            WHERE SD2.D_E_L_E_T_ <> '*'"
cQuery += "              AND D2_DOC = SF2.F2_DOC"
cQuery += "              AND D2_SERIE = SF2.F2_SERIE"
cQuery += "              AND D2_FILIAL = '"+xFilial('SD2')+"') D2_PEDIDO, "

cQuery += " (SELECT DISTINCT C5_ESTE"
cQuery += "             FROM "+RetSqlName('SD2')+ " SD2, "+RetSqlName('SC5')+ " SC5"
cQuery += "            WHERE SD2.D_E_L_E_T_ <> '*'"
cQuery += "              AND D2_DOC = SF2.F2_DOC"
cQuery += "              AND D2_SERIE = SF2.F2_SERIE"
cQuery += "              AND D2_FILIAL = '"+xFilial('SD2')+"'"
cQuery += "              AND C5_NUM = D2_PEDIDO"
cQuery += "              AND SC5.D_E_L_E_T_ <> '*'"
cQuery += "              AND C5_FILIAL = '"+xFilial('SC5')+"') C5_ESTE, "

cQuery += " (SELECT DISTINCT C5_MUNE"
cQuery += "             FROM "+RetSqlName('SD2')+ " SD2, "+RetSqlName('SC5')+ " SC5"
cQuery += "            WHERE SD2.D_E_L_E_T_ <> '*'"
cQuery += "              AND D2_DOC = SF2.F2_DOC"
cQuery += "              AND D2_SERIE = SF2.F2_SERIE"
cQuery += "              AND D2_FILIAL = '"+xFilial('SD2')+"'" 
cQuery += "              AND C5_NUM = D2_PEDIDO"
cQuery += "              AND SC5.D_E_L_E_T_ <> '*'"
cQuery += "              AND C5_FILIAL = '"+xFilial('SC5')+"') C5_MUNE, "

cQuery += " (SELECT DISTINCT C5_CEPE"
cQuery += "             FROM "+RetSqlName('SD2')+ " SD2, "+RetSqlName('SC5')+ " SC5"
cQuery += "            WHERE SD2.D_E_L_E_T_ <> '*'"
cQuery += "              AND D2_DOC = SF2.F2_DOC"
cQuery += "              AND D2_SERIE = SF2.F2_SERIE"
cQuery += "              AND D2_FILIAL = '"+xFilial('SD2')+"'" 
cQuery += "              AND C5_NUM = D2_PEDIDO"
cQuery += "              AND SC5.D_E_L_E_T_ <> '*'"
cQuery += "              AND C5_FILIAL = '"+xFilial('SC5')+"') C5_CEPE, "

cQuery += " (SELECT DISTINCT C5_BAIRROE"
cQuery += "             FROM "+RetSqlName('SD2')+ " SD2, "+RetSqlName('SC5')+ " SC5"
cQuery += "            WHERE SD2.D_E_L_E_T_ <> '*'"
cQuery += "              AND D2_DOC = SF2.F2_DOC"
cQuery += "              AND D2_SERIE = SF2.F2_SERIE"
cQuery += "              AND D2_FILIAL = '"+xFilial('SD2')+"'" 
cQuery += "              AND C5_NUM = D2_PEDIDO"
cQuery += "              AND SC5.D_E_L_E_T_ <> '*'"
cQuery += "              AND C5_FILIAL = '"+xFilial('SC5')+"') C5_BAIRROE, "

cQuery += " (SELECT DISTINCT C5_ENDENT"
cQuery += "             FROM "+RetSqlName('SD2')+ " SD2, "+RetSqlName('SC5')+ " SC5"
cQuery += "            WHERE SD2.D_E_L_E_T_ <> '*'"
cQuery += "              AND D2_DOC = SF2.F2_DOC"
cQuery += "              AND D2_SERIE = SF2.F2_SERIE"
cQuery += "              AND D2_FILIAL = '"+xFilial('SD2')+"'" 
cQuery += "              AND C5_NUM = D2_PEDIDO"
cQuery += "              AND SC5.D_E_L_E_T_ <> '*'"
cQuery += "              AND C5_FILIAL = '"+xFilial('SC5')+"') C5_ENDENT,"

cQuery += " (SELECT DISTINCT C5_CONDPAG"
cQuery += "             FROM "+RetSqlName('SD2')+ " SD2, "+RetSqlName('SC5')+ " SC5"
cQuery += "            WHERE SD2.D_E_L_E_T_ <> '*'"
cQuery += "              AND D2_DOC = SF2.F2_DOC"
cQuery += "              AND D2_SERIE = SF2.F2_SERIE"
cQuery += "              AND D2_FILIAL = '"+xFilial('SD2')+"'" 
cQuery += "              AND C5_NUM = D2_PEDIDO"
cQuery += "              AND SC5.D_E_L_E_T_ <> '*'"
cQuery += "              AND C5_FILIAL = '04') C5_CONDPAG,"

cQuery += " (SELECT DISTINCT E4_DESCRI"
cQuery += "             FROM "+RetSqlName('SD2')+ " SD2, "+RetSqlName('SC5')+ " SC5, "+RetSqlName('SE4')+ " SE4"
cQuery += "            WHERE SD2.D_E_L_E_T_ <> '*'"
cQuery += "              AND D2_DOC = SF2.F2_DOC"
cQuery += "              AND D2_SERIE = SF2.F2_SERIE"
cQuery += "              AND D2_FILIAL = '"+xFilial('SD2')+"'" 
cQuery += "              AND C5_NUM = D2_PEDIDO"
cQuery += "              AND SC5.D_E_L_E_T_ <> '*'"
cQuery += "              AND C5_FILIAL = '"+xFilial('SC5')+"'"
cQuery += "              AND E4_CODIGO = C5_CONDPAG"
cQuery += "              AND E4_FILIAL = '"+xFilial('SE4')+"'"
cQuery += "              AND SE4.D_E_L_E_T_ <> '*') E4_DESCRI,"
cQuery += " SF2.R_E_C_N_O_ as F2_RECNO, "
cQuery += " A1_EST, "
cQuery += " A1_CEP, "
cQuery += " A1_BAIRRO, "
cQuery += " A1_MUN, " 
cQuery += " A1_END  "
cQuery += " FROM "+RetSqlName('SF2')+ " SF2, "+RetSqlName('SA1')+ " SA1"
cQuery += " WHERE SF2.D_E_L_E_T_ <> '*'"
cQuery += "   AND F2_FILIAL = '"+xFilial('SF2')+"'"
cQuery += "   AND F2_TRANSP = '"+cCodTransp+"'"
cQuery += "   AND F2_IDINTER = ''"
cQuery += "   AND F2_DOC BETWEEN '"+cNotaIni+"' AND '"+cNotaFin+"'"
cQuery += "   AND F2_SERIE = '"+cSerie+"'"
cQuery += "   AND A1_COD = F2_CLIENTE"
cQuery += "   AND SA1.D_E_L_E_T_ <> '*'"

If lTemEDI
    cQuery += " ORDER BY F2_FILIAL, F2_SERIE, F2_DOC"
Else  
	cQuery += " ORDER BY F2_FILIAL, F2_SERIE, F2_DOC"
    //cQuery += " ORDER BY F2_FILIAL, C5_CEPE, C5_MUNE, C5_BAIRROE, F2_SERIE, F2_DOC"---
EndIf

memowrite('EDI.SQL',cQuery)
cQuery := ChangeQuery(cQuery)
DbCommitAll()
dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'TRB', .F., .T.)

If TRB->(Bof().and.Eof())
	MsgInfo(;
	'Não encontrado notas fiscais para enviar para esta '+chr(13)+chr(1)+;
	'transportadora no intervalo de nota informado pelo '+chr(13)+chr(1)+;
	'usuario'+chr(13)+chr(1)+chr(13)+chr(1)+;
	'Verifique as informações digitadas e gere novamente','Atenção')
Else
	TRB->(dbGOTop())   
	nParada := 0
	Do While TRB->(!EOF())
	    nParada++
		WORK_NF->(dbAppend())  
		WORK_NF->WKFLAG     := ' ' //cMarca
		WORK_NF->F2_DOC     := TRB->F2_DOC
		WORK_NF->F2_SERIE   := TRB->F2_SERIE
		WORK_NF->F2_EMISSAO := Ctod(SubStr(TRB->F2_EMISSAO,7,2)+'/'+SubStr(TRB->F2_EMISSAO,5,2)+'/'+SubStr(TRB->F2_EMISSAO,1,4))
		WORK_NF->F2_CLIENTE := TRB->F2_CLIENTE
		WORK_NF->F2_LOJA    := TRB->F2_LOJA
		WORK_NF->F2_VOLUME1 := TRB->F2_VOLUME1
		WORK_NF->F2_VALBRUT := TRB->F2_VALBRUT
		WORK_NF->F2_VALMERC := TRB->F2_VALMERC		
		WORK_NF->F2_PBRUTO  := TRB->F2_PBRUTO
		WORK_NF->F2_FRETE   := TRB->F2_FRETE
		WORK_NF->F2_ICMSRET := TRB->F2_ICMSRET
		WORK_NF->F2_VALICM  := TRB->F2_VALICM
		WORK_NF->D2_PEDIDO  := TRB->D2_PEDIDO
		WORK_NF->A1_NOME    := TRB->A1_NOME
		WORK_NF->C5_ESTE    := If(val(TRB->C5_CEPE)>0, TRB->C5_ESTE   , TRB->A1_EST )
		WORK_NF->C5_MUNE    := If(val(TRB->C5_CEPE)>0, TRB->C5_MUNE   , TRB->A1_MUN )
		WORK_NF->C5_BAIRROE := If(val(TRB->C5_CEPE)>0, TRB->C5_BAIRROE, TRB->A1_BAIRRO )
		WORK_NF->C5_CEPE    := If(val(TRB->C5_CEPE)>0, TRB->C5_CEPE   , TRB->A1_CEP)
		WORK_NF->C5_ENDENT  := If(val(TRB->C5_CEPE)>0, TRB->C5_ENDENT , TRB->A1_END )
		WORK_NF->WKSEQ      := space(6)
		WORK_NF->F2_RECNO   := TRB->F2_RECNO
		WORK_NF->C5_CONDPAG := TRB->C5_CONDPAG
        WORK_NF->E4_DESCRI  := TRB->E4_DESCRI
        WORK_NF->F2_NF	    := TRB->F2_NF
		WORK_NF->F2_EXP	    := PADR(DipRetExp(xFilial("SD2"),TRB->D2_PEDIDO,TRB->F2_DOC,TRB->F2_SERIE),36)
		//WORK_NF->WKCHEGADA  := Replicate("_",7)+':'+Replicate("_",7)
		//WORK_NF->WKSAIDA    := Replicate("_",7)+':'+Replicate("_",7)
		//WORK_NF->WKCARIMBO  := Replicate("_",50)
		TRB->(dbSkip())
	EndDo       
	
	Do While .t.
	    nparada:=0
	    nQtdMarc:=0
        nOpcao:=0
		Work_NF->(DbGoTop())
		Define msDialog oDlg Title "Seleção de Notas para Envia para Transportadora" From 0,0 TO 20,85
		oMark:=MsSelect():New("Work_NF","WKFLAG",,aCposSF,lInverte,@cMarca,{13,01,150,337})
	    oMark:baval:={|| Dpm018Marca()}
		Activate Dialog oDlg Centered on init EnchoiceBar(oDlg,bOk,bCancel,,aButtons)
		Exit
	EndDo
EndIf
TRB->(dbCloseArea())
Work_NF->(E_EraseArq(cFileWork))
Work_EDI->(E_EraseArq(cFileEDI))
Return(lRetorno)                       

*---------------------------------------------*
Static Function EdiGera()
*---------------------------------------------*
local nReg:=1
local id:=0
local nPos:=0
local lretorno:=.t.
local nVlrTotalNf:=0
local nPesoTotal:=0
local nDensidade:=0
local nVlrVolumes:=0
local nVlrCobrado:=0
local nVlrSeguro:=0
local cArqEdi:=''
local aIntEstru:={}
local cFilSA4:=xFilial('SA4')
local aReg:={'000','310','311','312','313','314','315','316','317','318'}

//Rafael Moraes Rosa - 12/01/2023 - VARIAVEL
Local cEndEnt	:= ""
Local cCidEnt	:= ""
Local cEstEnt	:= ""
Local cCEPEnt	:= ""
Local cBairEnt	:= ""
Local cCompEnt	:= ""

//Rafael Moraes Rosa - 12/01/2023 - INICIO
//dbSelectArea("SM0")

IF cEmpAnt+cFilAnt = '0101'

	SM0->(dbSeek("0104"))
		cEndEnt		:= SM0->M0_ENDENT
		cCidEnt		:= SM0->M0_CIDENT
		cEstEnt		:= SM0->M0_ESTENT
		cCEPEnt		:= SM0->M0_CEPENT
		cBairEnt	:= SM0->M0_BAIRENT
		cCompEnt	:= SM0->M0_COMPENT

ELSE
	SM0->(dbSeek(cEmpAnt+cFilAnt))
		cEndEnt		:= SM0->M0_ENDENT
		cCidEnt		:= SM0->M0_CIDENT
		cEstEnt		:= SM0->M0_ESTENT
		cCEPEnt		:= SM0->M0_CEPENT
		cBairEnt	:= SM0->M0_BAIRENT
		cCompEnt	:= SM0->M0_COMPENT

ENDIF
//SM0->(dbSkip())

SM0->(dbSeek(cEmpAnt+cFilAnt))

//Rafael Moraes Rosa - 12/01/2023 - FIM

If lPrevia 
   return(.t.)
EndIf    
//----------------------------------------------------------------------------------------
// 000 - Cabeçario do Intercambio
//----------------------------------------------------------------------------------------
aadd(aIntEstru,{'000',001,003,{|| '000'}})         // Identificador de Registro
aadd(aIntEstru,{'000',004,035,{|| SubStr(SM0->M0_NOMECOM,01,35)}})  // Nome da Caixa Postao do Remetente
aadd(aIntEstru,{'000',039,035,{|| SubStr(SA4->A4_NOME,01,35)}})     // Nome da caixa postal do destinatario
aadd(aIntEstru,{'000',074,006,{|| Strtran(dtoc(dDataBase),'/','')}}) // Data DDMMAA
aadd(aIntEstru,{'000',080,004,{|| SubStr(strTran(time(),':',''),01,4)}})  // Hora HHMM
aadd(aIntEstru,{'000',084,012,{|| cIdentInter }})  // Identificação do Intercambio
aadd(aIntEstru,{'000',096,145,{|| Space(096)}})    // Filler
//----------------------------------------------------------------------------------------
// 310 - Cabeçalho de documento
//----------------------------------------------------------------------------------------
aadd(aIntEstru,{'310',001,003,{|| '310'}})         // Identificador de registro
aadd(aIntEstru,{'310',004,014,{|| cIdentInter }})  // Identificação do documento
aadd(aIntEstru,{'310',018,223,{|| Space(223)}})    // Filler
//----------------------------------------------------------------------------------------
// 311 - Dados da Embarcadora
//----------------------------------------------------------------------------------------
aadd(aIntEstru,{'311',001,003,{|| '311'}}) // Identificador de regsitro
aadd(aIntEstru,{'311',001,014,{|| SM0->M0_CGC}}) // CGC Dipromed
aadd(aIntEstru,{'311',004,015,{|| SM0->M0_INSC+space(1)}}) // Inscrição estadual
//aadd(aIntEstru,{'311',018,040,{|| SM0->M0_ENDENT+space(40-len(SM0->M0_ENDENT))}}) // Endereço


If cEmpAnt $ cEmpEdi  // Se a empresa estiver contida no parametro, trazer o endereço do CD. Reginaldo Borges 02/05/2013

aadd(aIntEstru,{'311',018,040,{|| Left(cEndEdi,42)}}) // Endereço de coleta 02/05/2013 - GetMv("ES_ENDEDI")
aadd(aIntEstru,{'311',033,035,{|| cMunEdi+space(54)}}) // Cidade (Municipio) de coleta 02/05/2013 - GetMv("ES_MUNEDI")
aadd(aIntEstru,{'311',073,009,{|| cCepEdi}}) // Codigo Endereçamento Postal - CEP  (Indispensavel)- de coleta 02/05/2013 - GetMv("ES_CEPEDI") 
aadd(aIntEstru,{'311',117,009,{|| cEstEdi+space(11)}}) // Subentidade de Pais "SP"  de coleta 02/05/2013  - GetMv("ES_ESTEDI")
aadd(aIntEstru,{'311',126,008,{|| SubStr(Dtos(dDtSaida),7,2)+SubStr(Dtos(dDtSaida),5,2)+SubStr(Dtos(dDtSaida),1,4)}}) // Data de embarque das mercadorias
aadd(aIntEstru,{'311',134,040,{|| SubStr(SM0->M0_NOMECOM,01,40)}}) // Nome da empresa embarcadora (Razão social)
aadd(aIntEstru,{'311',174,067,{|| Space(174)}}) // Filler

Else

//Rafael Moraes Rosa - 12/01/2023 - INICIO - LINHA COMENTADA
/*
aadd(aIntEstru,{'311',018,040,{|| Left(SM0->M0_ENDENT,40)}}) // Endereço  MCVN - 11/12/09
aadd(aIntEstru,{'311',033,035,{|| SM0->M0_CIDENT+space(35-len(SM0->M0_CIDENT))}}) // Cidade (Municipio)                                                  
aadd(aIntEstru,{'311',073,009,{|| SubStr(SM0->M0_CEPENT,1,5)+'-'+SubStr(SM0->M0_CEPENT,6,3)}}) // Codigo Endereçamento Postal - CEP  (Indispensavel)
//aadd(aIntEstru,{'311',117,009,{|| SM0->M0_ESTENT+space(9-len(SM0->M0_ESTENT))}}) // Subentidade de Pais "SP"
aadd(aIntEstru,{'311',117,009,{|| Left(SM0->M0_ESTENT+space(9),9) }}) // Subentidade de Pais "SP"  MCVN - 11/12/09
aadd(aIntEstru,{'311',126,008,{|| SubStr(Dtos(dDtSaida),7,2)+SubStr(Dtos(dDtSaida),5,2)+SubStr(Dtos(dDtSaida),1,4)}}) // Data de embarque das mercadorias
aadd(aIntEstru,{'311',134,040,{|| SubStr(SM0->M0_NOMECOM,01,40)}}) // Nome da empresa embarcadora (Razão social)
aadd(aIntEstru,{'311',174,067,{|| Space(174)}}) // Filler
*/
//Rafael Moraes Rosa - 12/01/2023 - FIM - LINHA COMENTADA

//Rafael Moraes Rosa - 12/01/2023 - INICIO - LINHA SUBSTITUIDA
aadd(aIntEstru,{'311',018,040,{|| Left(cEndEnt,40)}}) // Endereço  MCVN - 11/12/09
aadd(aIntEstru,{'311',033,035,{|| cCidEnt+space(35-len(cCidEnt))}}) // Cidade (Municipio)                                                  
aadd(aIntEstru,{'311',073,009,{|| SubStr(cCEPEnt,1,5)+'-'+SubStr(cCEPEnt,6,3)}}) // Codigo Endereçamento Postal - CEP  (Indispensavel)
//aadd(aIntEstru,{'311',117,009,{|| SM0->M0_ESTENT+space(9-len(SM0->M0_ESTENT))}}) // Subentidade de Pais "SP"
aadd(aIntEstru,{'311',117,009,{|| Left(cEstEnt+space(9),9) }}) // Subentidade de Pais "SP"  MCVN - 11/12/09
aadd(aIntEstru,{'311',126,008,{|| SubStr(Dtos(dDtSaida),7,2)+SubStr(Dtos(dDtSaida),5,2)+SubStr(Dtos(dDtSaida),1,4)}}) // Data de embarque das mercadorias
aadd(aIntEstru,{'311',134,040,{|| SubStr(SM0->M0_NOMECOM,01,40)}}) // Nome da empresa embarcadora (Razão social)
aadd(aIntEstru,{'311',174,067,{|| Space(174)}}) // Filler
//Rafael Moraes Rosa - 12/01/2023 - FIM - LINHA SUBSTITUIDA

EndIf
//----------------------------------------------------------------------------------------
// 312 - Dados do destinatario da mercadoria
//----------------------------------------------------------------------------------------
aadd(aIntEstru,{'312',001,003,{|| '312'}}) // Identificador de registro
aadd(aIntEstru,{'312',004,040,{|| Substr(SA1->A1_NOME,1,40)}}) // Razão social
aadd(aIntEstru,{'312',044,014,{|| SA1->A1_CGC}}) // CGC / CPF
aadd(aIntEstru,{'312',058,015,{|| SubStr(Dp18Limpa(SA1->A1_INSCR,".-/*+"),1,15)}}) // Inscrição estadual
aadd(aIntEstru,{'312',073,040,{|| SubStr(Work_NF->C5_ENDENT,1,40)}}) // Endereço (Logradouro)
aadd(aIntEstru,{'312',113,020,{|| SubStr(Work_NF->C5_BAIRROE,1,20)}}) // Bairro
aadd(aIntEstru,{'312',133,035,{|| Work_NF->C5_MUNE+space(5)}}) // Cidade (Municipio)
aadd(aIntEstru,{'312',168,009,{|| SubStr(Work_NF->C5_CEPE,1,5)+'-'+SubStr(Work_NF->C5_CEPE,6,3)}}) // Código Endereçamento Postal
aadd(aIntEstru,{'312',177,009,{|| Space(9)}}) // Código de Municipio
aadd(aIntEstru,{'312',186,009,{|| Work_NF->C5_ESTE+space(7)}}) // Subentidade de país (Estado)
aadd(aIntEstru,{'312',195,004,{|| Space(4)}}) // Area frete (Fica em branco)
aadd(aIntEstru,{'312',199,035,{|| AllTrim(SA1->A1_TEL) + AllTrim(SA1->A1_FAX)+Space(35-(len(AllTrim(SA1->A1_TEL) + AllTrim(SA1->A1_FAX))))}}) // Numero de comunicação
aadd(aIntEstru,{'312',234,001,{|| If(len(AllTrim(SA1->A1_CGC))=14,'1','2')}}) // Tipo de identificação do destinatario
aadd(aIntEstru,{'312',235,006,{|| Space(6)}}) // Filler
//----------------------------------------------------------------------------------------
// 313 - Dados de Nota Fiscal
//----------------------------------------------------------------------------------------
aadd(aIntEstru,{'313',001,003,{|| '313' }})             // Identificador de registro
aadd(aIntEstru,{'313',004,015,{|| RIGHT(SF2->F2_DOC,6)+'-'+RIGHT(SF2->F2_SERIE,2)+space(6)}})          // Num ramaneio / Coleta resumo de carga
If SF2->F2_TRANSP == '123455'
	aadd(aIntEstru,{'313',019,007,{|| WORK_NF->D2_PEDIDO+Space(01)}}) // Numero do Pedido para a transportadora Ativa
Else
	aadd(aIntEstru,{'313',019,007,{|| Space(07)}})          // Codigo da rota
Endif
aadd(aIntEstru,{'313',026,001,{|| '1' }})               // Meio de transporte : Tipo de transporte da carga (1 Rodoviario, 2 Aerea, 3 Maritimo, 4 fluvial e 5 Ferroviario)
aadd(aIntEstru,{'313',027,001,{|| '2' }})               // Tipo de transporte da carga - 1 carga fechada, 2 carga francionada
aadd(aIntEstru,{'313',028,001,{|| '2' }})               // Tipo de Carga: 1 Fria, 2 Seca e 3 Mista
aadd(aIntEstru,{'313',029,001,{|| If(SF2->F2_TPFRETE=='F','F','C')}})   // Tipo de Frete: C CIF e  F = Fob
aadd(aIntEstru,{'313',030,003,{|| RIGHT(SF2->F2_SERIE,2)+space(1)}})      // Serie da Nota Fiscal
aadd(aIntEstru,{'313',033,008,{|| RIGHT(SF2->F2_DOC,6)+Space(2)}})// Numero da nota fiscal
aadd(aIntEstru,{'313',041,008,{|| SubStr(dTos(SF2->F2_EMISSAO),7,2)+;
                                  SubStr(dTos(SF2->F2_EMISSAO),5,2)+;
                                  SubStr(dTos(SF2->F2_EMISSAO),1,4)}})// Data de emissao
aadd(aIntEstru,{'313',049,015,{|| 'PROD HOSPITALAR' }}) // Natureza da mercadoria (Tipo) Ver com o Joel???
aadd(aIntEstru,{'313',064,015,{|| SF2->F2_ESPECI1+space(05)}})        // Especie de acondicionamento (Fardos, amarrados, caixas, etc...
aadd(aIntEstru,{'313',079,007,{|| Dp18Zeros(SF2->F2_VOLUME1,7,2)}})   // Quantidade de volumes
aadd(aIntEstru,{'313',086,015,{|| Dp18Zeros(SF2->F2_VALBRUTO,15,2)}}) // Valor total da nota
aadd(aIntEstru,{'313',101,007,{|| Dp18Zeros(SF2->F2_PBRUTO,7,2)}})    // Peso total da mercadoria a transportar
/*If SF2->F2_TRANSP == "000675"  // Calcula cubagem para Atlas    MCVN - 05/10/2007
	aadd(aIntEstru,{'313',108,005,{|| Dp18Zeros(Int(SF2->F2_PBRUTO*2),5,2)}})    // Peso densidade/cubagem
Else
	aadd(aIntEstru,{'313',108,005,{|| Replicate('0',5)}})                 // Peso densidade/cubagem
Endif*/                                                                                            
aadd(aIntEstru,{'313',108,005,{|| Replicate('0',5)}})                 // Peso densidade/cubagem
aadd(aIntEstru,{'313',113,001,{|| If(SF2->F2_VALICM > 0,"S","N")}})   // tipo de Icms
aadd(aIntEstru,{'313',114,001,{|| If(SF2->F2_SEGURO>0,'S','N')}})     // Seguro já efetuado? (S=Sim ou N=Não)
aadd(aIntEstru,{'313',115,015,{|| Dp18Zeros(SF2->F2_SEGURO,15,2)}})   // Valor do seguro
aadd(aIntEstru,{'313',130,015,{|| Replicate('0',15)}})  // Valor a ser cobrado
aadd(aIntEstru,{'313',145,007,{|| cPlacCamin }})        // Nro da placa do caminhão ou da carreta
aadd(aIntEstru,{'313',152,001,{|| 'S' }})               // Plano de Carga rapida? (S/N)
aadd(aIntEstru,{'313',153,015,{|| Replicate('0',15) }}) // Valor do Frete Peso-Volume
aadd(aIntEstru,{'313',168,015,{|| Replicate('0',15) }}) // Valor ad valorem (Percentual do frete em relação ao valor da mercadoria)
aadd(aIntEstru,{'313',183,015,{|| Replicate('0',15) }}) // Valor total das taxas
aadd(aIntEstru,{'313',198,015,{|| Dp18Zeros(SF2->F2_FRETE,15,2)}})    // Valor total do frete
aadd(aIntEstru,{'313',213,001,{|| 'I' }})               // Ação do documento (I = inclusão / E = Exclusao/cancelamento)
aadd(aIntEstru,{'313',214,012,{|| Dp18Zeros(SF2->F2_VALICM,12,02)}})  // Valor do ICMS -> Valor do ICMS da nota fiscal
aadd(aIntEstru,{'313',226,012,{|| Dp18Zeros(SF2->F2_ICMSRET,12,02)}}) // Valor do ICMS retido
aadd(aIntEstru,{'313',238,001,{|| "N" }})               // Indicação de bonificação (S/n)
aadd(aIntEstru,{'313',239,002,{|| Space(2)}})           // Filler
aadd(aIntEstru,{'313',241,044,{|| SF2->F2_CHVNFE}})     // Chave Danfe

//----------------------------------------------------------------------------------------
// 314 - Mercadoria da Nota Fsical
//----------------------------------------------------------------------------------------
aadd(aIntEstru,{'314',001,003,{|| '314'}}) // Identificador de registro
aadd(aIntEstru,{'314',004,007,{|| }}) // Quantidades de volumes
aadd(aIntEstru,{'314',011,015,{|| }}) // Especie de acondicionamento                 
aadd(aIntEstru,{'314',026,030,{|| }}) // Mercadoria da nota fiscal
aadd(aIntEstru,{'314',056,007,{|| }}) // Quantidade de volumes
aadd(aIntEstru,{'314',063,015,{|| }}) // Especie de acondicionamento
aadd(aIntEstru,{'314',078,030,{|| }}) // Mercadoria da nota fiscal
aadd(aIntEstru,{'314',108,007,{|| }}) // Quantidade de volumes
aadd(aIntEstru,{'314',115,015,{|| }}) // Especie de acondicionamento
aadd(aIntEstru,{'314',130,030,{|| }}) // Mercadoria da nota fiscal
aadd(aIntEstru,{'314',160,007,{|| }}) // Quantidade de volumes
aadd(aIntEstru,{'314',167,015,{|| }}) // Especie de acondicionamento
aadd(aIntEstru,{'314',182,030,{|| }}) // Mercadoria da Nota fiscal
aadd(aIntEstru,{'314',212,029,{|| Space(20)}}) // Filler
//----------------------------------------------------------------------------------------
// 315 - Dados do consignatario da mercadoria
//----------------------------------------------------------------------------------------
aadd(aIntEstru,{'315',001,003,{|| '315' }}) // Identificador de registro
aadd(aIntEstru,{'315',004,040,{|| }}) // Razão social
aadd(aIntEstru,{'315',044,014,{|| }}) // CGC
aadd(aIntEstru,{'315',058,015,{|| }}) // Inscrição estadual
aadd(aIntEstru,{'315',073,040,{|| }}) // Endereço
aadd(aIntEstru,{'315',113,020,{|| }}) // Bairro
aadd(aIntEstru,{'315',133,035,{|| }}) // Cidade
aadd(aIntEstru,{'315',168,009,{|| }}) // Codigo de endereçamento postal
aadd(aIntEstru,{'315',177,009,{|| }}) // Codigo de municipio
aadd(aIntEstru,{'315',186,009,{|| }}) // subentidade de pais
aadd(aIntEstru,{'315',195,035,{|| }}) // Numero de comunicação
aadd(aIntEstru,{'315',230,011,{|| Space(11)}}) // Filler
//----------------------------------------------------------------------------------------
// 316 - Dados para redespacho da mercadoria
//----------------------------------------------------------------------------------------
aadd(aIntEstru,{'316',001,003,{|| '316' }}) // Identificador de registro
aadd(aIntEstru,{'316',004,040,{|| }}) // razão social
aadd(aIntEstru,{'316',044,014,{|| }}) // CGC
aadd(aIntEstru,{'316',058,015,{|| }}) // Escrição estadual
aadd(aIntEstru,{'316',073,040,{|| }}) // Endereço
aadd(aIntEstru,{'316',113,020,{|| }}) // Bairro
aadd(aIntEstru,{'316',133,035,{|| }}) // Cidade
aadd(aIntEstru,{'316',168,009,{|| }}) // Codigo de Endereçamento postal
aadd(aIntEstru,{'316',177,009,{|| }}) // Codigo de Municipio
aadd(aIntEstru,{'316',186,009,{|| }}) // Subentidade de Pais
aadd(aIntEstru,{'316',195,004,{|| }}) // Area de frete
aadd(aIntEstru,{'316',199,035,{|| }}) // Numero de comunicação
aadd(aIntEstru,{'316',234,007,{|| Space(7) }}) // Fille
//----------------------------------------------------------------------------------------
// 317 - Dados responsavel pelo Frete
//----------------------------------------------------------------------------------------
aadd(aIntEstru,{'317',001,003,{|| '317' }}) // identificador de registro
aadd(aIntEstru,{'317',004,040,{|| }}) // Razão social
aadd(aIntEstru,{'317',044,014,{|| }}) // CGC
aadd(aIntEstru,{'317',058,015,{|| }}) // Inscrição estadual
aadd(aIntEstru,{'317',073,040,{|| }}) // Endereço
aadd(aIntEstru,{'317',113,020,{|| }}) // Bairro
aadd(aIntEstru,{'317',133,035,{|| }}) // Cidade
aadd(aIntEstru,{'317',168,009,{|| }}) // Codigo de Endereçamento postal
aadd(aIntEstru,{'317',177,009,{|| }}) // Codigo do Municipio
aadd(aIntEstru,{'317',186,009,{|| }}) // subentidade de pais
aadd(aIntEstru,{'317',195,035,{|| }}) // Numero de comunicação
aadd(aIntEstru,{'317',230,011,{|| Space(11)}}) // Filler
//----------------------------------------------------------------------------------------
// 318 - Valores totais do documento (arq)
//----------------------------------------------------------------------------------------
aadd(aIntEstru,{'318',001,003,{|| '318' }})       // Identificador de registro
aadd(aIntEstru,{'318',004,015,{|| Dp18Zeros(nVlrTotalNf,15,2)}}) // Valor total das notas fiscais
aadd(aIntEstru,{'318',019,015,{|| Dp18Zeros(nPesoTotal,15,2)}})  // Peso total das notas fiscais
aadd(aIntEstru,{'318',034,015,{|| Dp18Zeros(nDensidade,15,2)}})  // Peso total densidade/cubagem
aadd(aIntEstru,{'318',049,015,{|| Dp18Zeros(nVlrVolumes,15,2)}}) // Quantidade total de volumes
aadd(aIntEstru,{'318',064,015,{|| Dp18Zeros(nVlrCobrado,15,2)}}) // Valor total a ser cobrado
aadd(aIntEstru,{'318',079,015,{|| Dp18Zeros(nVlrSeguro,15,2)}})  // Valor total do seguro
aadd(aIntEstru,{'318',094,147,{|| Space(147)}})   // Filler
*----------------------------------------------------------------------------------------
cArqEdi := ""
Work_NF->(dbgotop())
SA1->(dbSetOrder(1))
*---------------------------
nVlrTotalNf:=0
nPesoTotal:=0
nDensidade:=0
nVlrVolumes:=0
nVlrCobrado:=0
nVlrSeguro:=0

*---------------------------
Do while Work_NF->(!EOF())
	begin sequence
	If Empty(Work_NF->WKFLAG)
		Break
	EndIf
	SA4->(dbSeek(cFilSA4+cCodTransp))
	SA1->(dbSeek(xFilial("SA1")+Work_NF->F2_CLIENTE+Work_NF->F2_LOJA))
	SF2->(dbgoto(Work_NF->F2_RECNO))
	If lTemEDI.and.lTemEmail
		For id:=nReg to len(aReg)-1
			nPos := Ascan(aIntEstru,{|x| x[1] == aReg[id]})
			If nPos > 0 .and. aReg[id] $ SA4->A4_EDIREGI
				cArqEdi := ""
				Do while nPos <= len(aIntEstru) .and. aIntEstru[nPos][01] == aReg[id]
					cArqEdi += Eval(aIntEstru[nPos][04])
					nPos++
				Enddo
				Work_EDI->(dbappend())
				Work_EDI->WK_EDI:=cArqEdi
			EndIf
		Next
		nReg:=4
		nVlrTotalNf += SF2->F2_VALBRUTO
		nPesoTotal  += SF2->F2_PBRUTO
   /*	If SF2->F2_TRANSP == "000675"  // Calcula cubagem para atlas    MCVN - 05/10/2007
			nDensidade  += (SF2->F2_PBRUTO*2)   
		Else
			nDensidade  += 0
		Endif               */
		nDensidade  += 0
		nVlrVolumes += SF2->F2_VOLUME1
		nVlrCobrado += 0
		nVlrSeguro  += SF2->F2_SEGURO
	EndIf
	
cXtranad := oItens	//Felipe Duran - 07/11/19

	*------------------------------
	SF2->(Reclock("SF2",.f.))
	*------------------------------
	SF2->F2_IDINTER := cIdentInter
	SF2->F2_PLCCAMI := cPlacCamin
	SF2->F2_MOTORIS := cMotorista
	SF2->F2_AJUDANT := cAjudante
	SF2->F2_OPEREXP := cOperExped
	SF2->F2_DATASAI := dDtSaida
	SF2->F2_HORASAI := cHrSaida
	SF2->F2_XMOTIVO	:= cObserv	  //Felipe Duran - 07/11/19
	SF2->F2_XTRAADQ	:= cXtranad   //Felipe Duran - 07/11/19
	SF2->(MsUnlock("SF2"))

	End Sequence
	*------------------------------
	Work_NF->(dbSkip())
	*------------------------------
EndDo
If lTemEdi.and.lTemEmail
	If !Work_EDI->(EOF().and.BOF())
		id := len(aReg)
		nPos := Ascan(aIntEstru,{|x| x[1] == aReg[id]})
		If nPos > 0
			cArqEdi := ""
			Do while nPos <= len(aIntEstru) .and. aIntEstru[nPos][01] == aReg[id]
				cArqEdi += Eval(aIntEstru[nPos][04])
				nPos++
			Enddo
			Work_EDI->(dbappend())
			Work_EDI->WK_EDI:=cArqEdi
		EndIf
	EndIf
	dbSelectArea('Work_EDI')
	Copy to  &cEdi SDF //VIA "DBFCDXADS"
	If cCodTransp $ SuperGetMv("ES_ZEDITRA",,"955917")
  		If !ExistDir( "C:\NOTFIS" )  // Resultado: .F.
			nRet := MakeDir( "C:\NOTFIS" )
			if nRet != 0
				Alert( "Não foi possível criar o diretório C:\NOTAFIS (contate a area de TI)" + cValToChar( FError() ) )
			endif
		Endif
		bOk := CpyS2T( cEdi, "C:\NOTFIS", .F. )	
	Endif
EndIf

Return(lretorno)
*--------------------------------------------------*
Static Function Dp18Limpa(cString,cCharacters)
*--------------------------------------------------*
Local cStringRet := cString
Local i
Default cCharacters:="."
For i:=1 to len(cCharacters)
	cStringRet := StrTran(cStringRet,SubStr(cCharacters,i,1),"")
Next i
Return(cStringRet)
*--------------------------------------------------*
Static Function Dp18Zeros(nNumero,nLen,nDec)
*--------------------------------------------------*
Local cNumero
cNumero:=Str(nNumero,nLen,ndec)
cNumero:=StrTran(cNumero,'.','')
cNumero:=replicate('0',nLen-(Len(AllTrim(cNumero))))+AllTrim(cNumero)
Return(cNumero)
*--------------------------------------------------*
Static Function Dp18MarcTodos(oMark)
*--------------------------------------------------*
Local cFlag
Local nRecNo:=0
cFlag:=IF(!Empty(Work_NF->WKFLAG),Space(2),cMarca)
nRecNo:=Work_NF->(RecNo())
nOrdem:=1
nParada:=0                   
nQtdMarc:=0
Work_NF->(dbGotop())
Work_NF->(dbEval({|| Work_NF->WKFLAG := cFlag, Work_NF->WKSEQ:=If(cFlag==cMarca,StrZero(nParada+=10,6),space(6))},{|| .T. }))
nQtdMarc:=int(nParada/5)
Work_NF->(dbGoTo(nRecNo))
oMark:oBrowse:Refresh()
Return NIL      
*---------------------------------------------*
Static Function Dpm018Marca()
*---------------------------------------------*
Local cAtual := Work_NF->WKFLAG
Local lRetorno := .t.
Static nUltimo
If cAtual == cMarca
   Work_NF->WKSEQ := Space(6)
   Work_NF->WKFLAG := Space(3)
   nQtdMarc-=10 
   nUltimo:= nQtdMarc //Work_NF->(Recno())
Else                              
   If(nUltimo<>nQtdMarc,nParada+=10,)
   Work_NF->WKSEQ := StrZero(nParada,6)
   Work_NF->WKFLAG := cMarca
   nUltimo := nQtdMarc // Work_NF->(Recno())
   nQtdMarc++
EndIf
Return(lRetorno)
*--------------------------------------------------*
Static Function Dp18E_Report()
*--------------------------------------------------*
Private aDados:={}
Private aReturn:={"Zebrado", 1,"Administracao", 1, 2, 1,"",1}
Private cEndRereco
nVolume:=0
nTotNF:=0
aDados:={}
If lTemEDI
	aAdd(aDados,"WORK_NF")
	aAdd(aDados,OemTOAnsi("Romaneio de Transportadora",72)) // 02
	aAdd(aDados,OemToAnsi("Notas Fiscais envidas para a transportadora",72))  // 03
	aAdd(aDados,OemToAnsi("",72))       // 04
	aAdd(aDados,"G")              // 05
	aAdd(aDados,220)              // 06
	aAdd(aDados,"Por Nota Fiscal") // 07
	aAdd(aDados,"")               // 08
	aAdd(aDados,OemTOAnsi("Romaneio em "+dtoc(dDtSaida)+' '+AllTrim(cCodTransp)+'-'+cNomReduz+If(lPrevia,'(APENAS CONFERENCIA)',''),72))
ElseIf cCodTransp == '000001'
	aAdd(aDados,"WORK_NF")
	aAdd(aDados,OemTOAnsi("Roteiro de Entrega em ",72)) // 02
	aAdd(aDados,OemToAnsi("Roteiro de Entrega em ",72))  // 03
	aAdd(aDados,OemToAnsi("Roteiro de Entrega em ",72))       // 04
	aAdd(aDados,"G")              // 05
	aAdd(aDados,220)              // 06
	aAdd(aDados,"Por Nota Fiscal") // 07
	aAdd(aDados,"")               // 08
	aAdd(aDados,OemTOAnsi("Roteiro de Entregas em "+dtoc(dDtSaida)+' '+AllTrim(cCodTransp)+'-'+cNomReduz+If(lPrevia,'(APENAS CONFERENCIA)',''),72))
Else
	aAdd(aDados,"WORK_NF")
	aAdd(aDados,OemTOAnsi("Comprovante de Entrega",72)) // 02
	aAdd(aDados,OemToAnsi("Comprovante de Entrega",72))  // 03
	aAdd(aDados,OemToAnsi("Comprovante de Entrega",72))       // 04
	aAdd(aDados,"G")              // 05
	aAdd(aDados,220)              // 06
	aAdd(aDados,"Por Nota Fiscal") // 07
	aAdd(aDados,"")               // 08
	aAdd(aDados,OemTOAnsi("Comprovante de Entrega em  "+dtoc(dDtSaida)+' '+AllTrim(cCodTransp)+'-'+cNomReduz+If(lPrevia,'(APENAS CONFERENCIA)',''),72))
EndIf
aAdd(aDados,aReturn)          // 10
aAdd(aDados,"DIPM018_"+DtoS(dDatabase)+"_"+SubStr(Time(),1,2)+SubStr(Time(),4,2)+SubStr(Time(),7,2))        // 11
aAdd(aDados,{{||Dipm018Quebra()},{||Dipm018Final()}})// 12
aAdd(aDados,Nil)              // 13
aRCampos:= {}                     
If lTemEDI
	aadd(aRCampos,{"F2_CLIENTE","","Codigo"         ,AvSx3("F2_CLIENTE",6)})
	aadd(aRCampos,{"A1_NOME"   ,"","Nome do Cliente",AvSx3("A1_NOME",6)})
	aadd(aRCampos,{"C5_MUNE"   ,"","Municipio"      ,AvSx3("C5_MUNE",6)})
	aadd(aRCampos,{"C5_ESTE"   ,"","UF"	            ,AvSx3("C5_ESTE",6)})
	aadd(aRCampos,{"C5_CEPE"   ,"","CEP"  		    ,AvSx3("C5_CEPE",6)})
	aadd(aRCampos,{"D2_PEDIDO" ,"","Pedido"         ,AvSx3("D2_PEDIDO",6)})
	aadd(aRCampos,{"F2_NF"     ,"","NF/Serie"       ,AvSx3("F2_DOC",6)})
	aadd(aRCampos,{"F2_EXP"    ,"","Expedicao"      ,AvSx3("F2_DOC",6)})
	aadd(aRCampos,{"F2_VOLUME1","","Volume"         ,AvSx3("F2_VOLUME1",6)})
	
	aDados[07]:=OemTOAnsi('Placa: ' + cPlacCamin +;
	' Hora Chegada: ' + cHrEntrada +;
	' Hora Saida: '+cHrSaida +;
	' Motorista: '+Alltrim(cMotorista)+space(2)+Replicate("_",20) +;
	'     Ajudante: '+Alltrim(cAjudante))
	aRCampos:=E_CriaRCampos(aRCampos,"E")
Else
	If SF2->F2_TRANSP $ "000235/000236" // Se o transporte for SEDEX / SEDEX10, trazer somente valor das mercadorias RBorges 09/12/14
		
		aadd(aRCampos,{"WKSEQ"     ,"","Parada"         ,'999999'})
		aadd(aRCampos,{"F2_CLIENTE","","Codigo"         ,AvSx3("F2_CLIENTE",6)})
		aadd(aRCampos,{"A1_NOME"   ,"","Nome do Cliente",AvSx3("A1_NOME",6)})
		//    aadd(aRCampos,{"F2_DOC"    ,"","Nro N.F."       ,AvSx3("F2_DOC",6)})
		//    aadd(aRCampos,{"F2_SERIE"  ,"","Serie"          ,AvSx3("F2_SERIE",6)})
		aadd(aRCampos,{"F2_NF"     ,"","NF/Serie"       ,AvSx3("F2_DOC",6)})
		aadd(aRCampos,{"F2_VOLUME1","","Volumes"        ,AvSx3("F2_VOLUME1",6)})
		aadd(aRCampos,{"D2_PEDIDO" ,"","Pedido"         ,AvSx3("D2_PEDIDO",6)})
		aadd(aRCampos,{"F2_VALMERC","","Valor dos Produtos",AvSx3("F2_VALMERC",6)})
		//    aadd(aRCampos,{"C5_MUNE"   ,"","Municipio"    ,AvSx3("C5_MUNE",6)})
		//    aadd(aRCampos,{"C5_BAIRROE","","Bairro"       ,AvSx3("C5_BAIRROE",6)})
		aadd(aRCampos,{"WKCHEGADA" ,"","Hora Chegada"   ,AvSx3("C5_BAIRROE",6)})
		aadd(aRCampos,{"WKSAIDA"   ,"","Hora Saida"     ,AvSx3("C5_BAIRROE",6)})
		aadd(aRCampos,{"WKCARIMBO" ,"","Carimbo Cliente",AvSx3("C5_BAIRROE",6)})
		aadd(aRCampos,{"F2_EXP"    ,"","Expedicao"      ,AvSx3("F2_DOC",6)})
		
		aDados[07]:=OemTOAnsi('Placa: ' + cPlacCamin +;
		' Motorista: '+Alltrim(cMotorista)+space(2)+Replicate("_",20) +;
		'     Ajudante: '+Alltrim(cAjudante))+space(60)+"Chegada no CD: ____:____"
		aRCampos:=E_CriaRCampos(aRCampos,"E")
		aRCampos[08,3]:="D" // Ajusta a Direita
	Else
		aadd(aRCampos,{"WKSEQ"     ,"","Parada"         ,'999999'})
		aadd(aRCampos,{"F2_CLIENTE","","Codigo"         ,AvSx3("F2_CLIENTE",6)})
		aadd(aRCampos,{"A1_NOME"   ,"","Nome do Cliente",AvSx3("A1_NOME",6)})
		//    aadd(aRCampos,{"F2_DOC"    ,"","Nro N.F."       ,AvSx3("F2_DOC",6)})
		//    aadd(aRCampos,{"F2_SERIE"  ,"","Serie"          ,AvSx3("F2_SERIE",6)})
		aadd(aRCampos,{"F2_NF"     ,"","NF/Serie"       ,AvSx3("F2_DOC",6)})
		aadd(aRCampos,{"F2_VOLUME1","","Volumes"        ,AvSx3("F2_VOLUME1",6)})
		aadd(aRCampos,{"D2_PEDIDO" ,"","Pedido"         ,AvSx3("D2_PEDIDO",6)})
		aadd(aRCampos,{"F2_VALBRUT","","Valor"          ,AvSx3("F2_VALBRUT",6)})
		//    aadd(aRCampos,{"C5_MUNE"   ,"","Municipio"    ,AvSx3("C5_MUNE",6)})
		//    aadd(aRCampos,{"C5_BAIRROE","","Bairro"       ,AvSx3("C5_BAIRROE",6)})
		aadd(aRCampos,{"WKCHEGADA" ,"","Hora Chegada"   ,AvSx3("C5_BAIRROE",6)})
		aadd(aRCampos,{"WKSAIDA"   ,"","Hora Saida"     ,AvSx3("C5_BAIRROE",6)})
		aadd(aRCampos,{"WKCARIMBO" ,"","Carimbo Cliente",AvSx3("C5_BAIRROE",6)})
		aadd(aRCampos,{"F2_EXP"    ,"","Expedicao"      ,AvSx3("F2_DOC",6)})
		
		aDados[07]:=OemTOAnsi('Placa: ' + cPlacCamin +;
		' Motorista: '+Alltrim(cMotorista)+space(2)+Replicate("_",20) +;
		'     Ajudante: '+Alltrim(cAjudante))+space(60)+"Chegada no CD: ____:____"
		aRCampos:=E_CriaRCampos(aRCampos,"E")
		aRCampos[08,3]:="D" // Ajusta a Direita
	EndIf
	
	
EndIf

aDados[08]:=OemTOAnsi(space(10))

aReturn	:= {"Zebrado", 1,"Administracao", 1, 2, 1,"",2}

aDados[10]:=aReturn
//Work_NF->(dbSetOrder(2))
Work_NF->(dbGotop())
Work_NF->(E_Report(aDados,aRCampos))
Return NIL
*------------------------------------------*
Static Function Dipm018Quebra()
*------------------------------------------*
local lRetorno:=.f.
local nSpace:=2 
linha += nSomaLinha
nSomaLinha:=0            
If Work_NF->(!EOF()).and. Work_NF->WKFLAG == cMarca
	nVolume += Work_NF->F2_VOLUME1
	nTotNF++
	lRetorno:=.t.
	If !lTemEDi  
	   If cEndRereco != NIL
	      linha++ 
	      @ linha,T_LEN[03,2] psay cEndRereco
          @ linha,T_LEN[08,2] psay Replicate("_",7)+':'+Replicate("_",7)
          @ linha,T_LEN[09,2] psay Replicate("_",7)+':'+Replicate("_",7)
          @ linha,T_LEN[10,2] psay Replicate("_",30)
	      linha +=2
	   EndIf
	   cEndRereco:='Cep: '+Work_NF->C5_CEPE+space(nSpace)+;
	               'Endereco: '+AllTrim(Work_NF->C5_ENDENT)+' - '+;
	               AllTrim(Work_NF->C5_BAIRROE)+' - '+;
	               AllTrim(Work_NF->C5_MUNE)+'-'+;
	               AllTrim(Work_NF->C5_ESTE)
	EndIf   
Else
	linha++
    cEndRereco := NIL   
EndIf                
If linha > 54
   linha:=80
// 	Roda(0,"Testes","M")
//    linha:=56
	Dipm018Cabec()
	linha++ 
	If !lRetorno
	     linha++ 
	EndIf
EndIF
RETURN(lRetorno)
*-------------------------------*
Static Function Dipm018Final()
*-------------------------------*
Local nCol1:=If(lTemEDI,20,T_LEN[3,2])
Local nCol2:=If(lTemEDI,20,T_LEN[3,2])
Local nTlen1:=If(lTemEDI,06,04)
Local nTlen2:=If(lTemEDI,08,06)  
Local oGet
Local oObs
Static cObserv  := ""	//Alterado variavel de Local para Static - Felipe Duran - 07/11/19 
Private cGetObs  := space(40) 

If cEndRereco != NIL
    linha++
    @ linha,T_LEN[03,2] psay cEndRereco
    @ linha,T_LEN[08,2] psay Replicate("_",7)+':'+Replicate("_",7)
    @ linha,T_LEN[09,2] psay Replicate("_",7)+':'+Replicate("_",7)
    @ linha,T_LEN[10,2] psay Replicate("_",30)
    linha+=2
EndIf
If Work_NF->(EOF())
	If linha > 50
//		Roda(0,space(10),"G")
		linha := 56
		Dipm018Cabec()
		linha+=3
		@ linha,nCol1 psay 'Total de Notas Fiscais..:  ' + Transform(nTotNF,'@ke 999,999,999')
		linha++
		@ linha,nCol1 psay 'Total de Volumes........:  ' + Transform(nVolume,'@ke 999,999,999')
	Else
		linha++
		@ linha, T_LEN[nTlen1,2] psay '------'
		@ linha, T_LEN[nTlen2,2] psay '------'
		linha++
		@ linha,nCol2 psay 'Quantidade Notas Fiscais e Total de Volumes..:'
		@ linha, T_LEN[nTlen1,2] psay Transform(nTotNF,'@ke 99,999')
		@ linha, T_LEN[nTlen2,2] psay Transform(nVolume,'@ke 99,999')
	    linha += 5 
	    If (oItens) == 'Nao' 

	    	Define msDialog oDlg Title "Transporte não Adequado" From 10,10 TO 15,050
				@ 010,010 say "Ação Tomada:"                   size 100,008 of oDlg pixel
				@ 010,060 Msget oObs var cGetObs valid NaoVazio() size 080,010 of oDlg pixel picture "@!" 
				@ 025,060 Button oBOTAOOK PROMPT "&Confirmar" size 040,010 pixel of oDLG action(RetObs(cGetObs,@cObserv), oDLG:END())
			Activate dialog oDlg centered

			@ linha,nCol2 psay 'TRANSPORTE ADEQUADO?: '+Upper(oItens)+' - '+cObserv
	    Else
		    @ linha,nCol2 psay 'TRANSPORTE ADEQUADO?: '+Upper(oItens)
	    EndIf
	EndIf
EndIf
RETURN(.t.)
*-------------------------------*
Static Function Dipm018Cabec() 
*-------------------------------*
local b_lin :={|valor,ind| F_Ler_Tab(R_Campos,ind)}
Local tamanho := Adados[5]
Local nAsterisco
Do Case
	Case Tamanho=="P";nAsterisco:=80
	Case Tamanho=="M";nAsterisco:=132
	Case Tamanho=="G";nAsterisco:=220
EndCase
If Linha>55
	Cabec(titulo,cabec1,cabec2,nomeprog,tamanho,GetMv("MV_COMP"))
	If Empty(cabec1) .And. Empty(cabec2)
		@ PROW()+1,T_Len[1,2]-1 PSAY REPLI('*',nAsterisco)
	Endif
	Linha:=PROW()+1 ; l_tag:=say_tit
	AEVAL(R_Campos, b_lin)
	Linha++ ; l_tag:=say_rep
	AEVAL(R_Campos, b_lin)
Endif
RETURN(.T.)         


*---------------------------------------*
Static Function DipPergDiverg(lLer)
*---------------------------------------*
Local aRegs:={}
Local lIncluir
Local i,j
SX1->(dbSetOrder(1))

cPerg := PADR(cPerg, Len(SX1->X1_GRUPO)," " ) // Incluido por Sandro em 18/11/09.

aAdd(aRegs,{cPerg,"01","Codigo da transportadora"     ,"","","MV_CH1","C",len(cCodTransp),0,0,"G","","MV_PAR01","","","", cCodTransp ,"","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"02","Nome da transportadora"       ,"","","MV_CH2","C",len(cNomTransp),0,0,"G","","MV_PAR02","","","", cNomTransp ,"","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"03","Nr da nota fiscal inicial"    ,"","","MV_CH3","C",len(cNotaIni)  ,0,0,"G","","MV_PAR03","","","", cNotaIni   ,"","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"04","Nr da nota fiscal final"      ,"","","MV_CH4","C",len(cNotaFin)  ,0,0,"G","","MV_PAR04","","","", cNotaFin   ,"","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"05","Serie das notas fiscais"      ,"","","MV_CH5","C",len(cSerie)    ,0,0,"G","","MV_PAR05","","","", cSerie     ,"","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"06","Placa do caminhão"            ,"","","MV_CH6","C",len(cPlacCamin),0,0,"G","","MV_PAR06","","","", cPlacCamin ,"","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"07","Nome do motorista"            ,"","","MV_CH7","C",len(cMotorista),0,0,"G","","MV_PAR07","","","", cMotorista ,"","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"08","Nome do ajudante do caminhão" ,"","","MV_CH8","C",len(cAjudante) ,0,0,"G","","MV_PAR08","","","", cAjudante  ,"","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"09","Nome do operador de expedição","","","MV_CH9","C",len(cOperExped),0,0,"G","","MV_PAR09","","","", cOperExped ,"","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"10","Hora de Chegada do caminhão"  ,"","","MV_CHA","C",len(cHrEntrada),0,0,"G","","MV_PAR10","","","", cHrEntrada ,"","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"11","Data de saida do caminhão"    ,"","","MV_CHB","D",008            ,0,0,"G","","MV_PAR11","","","", "'"+dtoc(dDtSaida)+"'","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"12","Hora de saida do caminhão"    ,"","","MV_CHC","C",len(cHrSaida)  ,0,0,"G","","MV_PAR12","","","", cHrSaida   ,"","","","","","","","","","",""})
For i:=1 to len(aRegs)
	lIncluir:=!SX1->(dbSeek(cPerg+aRegs[i,2]))
	If !lIncluir.and.lLer
		aRegs[i,17]:=SX1->X1_CNT01
	EndIf
	SX1->(RecLock("SX1",lIncluir))
	For j:=1 to SX1->(FCount())
		If j <= len(aRegs[i])
			SX1->(FieldPut(j,aRegs[i,j]))
		Endif
	Next
	SX1->(MsUnlock("SX1"))
Next
cCodTransp:=Left(aRegs[01,17],aRegs[01,8])
cNomTransp:=Left(aRegs[02,17],aRegs[02,8])
cNotaIni  :=Left(aRegs[03,17],aRegs[03,8])
cNotaFin  :=Left(aRegs[04,17],aRegs[04,8])
cSerie    :=Left(aRegs[05,17],aRegs[05,8])
cPlacCamin:=Left(aRegs[06,17],aRegs[06,8])
cMotorista:=Left(aRegs[07,17],aRegs[07,8])
cAjudante :=Left(aRegs[08,17],aRegs[08,8])
cOperExped:=Left(aRegs[09,17],aRegs[09,8])
cHrEntrada:=Left(aRegs[10,17],aRegs[10,8])
//dDtSaida  :=cTod(StrTran(aRegs[11,17],"'",""))
//cHrSaida  :=Left(aRegs[12,17],aRegs[12,8])


//Limpando as variáveis
cPlacCamin:=criavar("F2_PLCCAMI",.f.)
cMotorista:=criavar("F2_MOTORIS",.f.)
cAjudante:=criavar("F2_AJUDANT",.f.)
cOperExped:=criavar("F2_OPEREXP",.f.)

Return(.t.)

*----------------------------------------*
Static Function SendMail()    
*----------------------------------------*
If lTemEMAIL .and. lGeraOf .and. lTemEDI
	private aUsuario  :="", oDlgMail, nOp:=0
	private cFrom     :=""
	private cServer   :=AllTrim(GetNewPar("MV_RELSERV"," ")) // "mailhost.average.com.br" //Space(50)
	private cAccount  :=AllTrim(GetNewPar("MV_RELACNT"," ")) //Space(50)
	private cPassword :=AllTrim(GetNewPar("MV_RELPSW" ," "))  //Space(50)
	private nTimeOut  :=GetMv("MV_RELTIME",,120) //Tempo de Espera antes de abortar a Conexão
	private lAutentica:=GetMv("MV_RELAUTH",,.F.) //Determina se o Servidor de Email necessita de Autenticação
	private cUserAut  :=Alltrim(GetMv("MV_RELAUSR",,cAccount)) //Usuário para Autenticação no Servidor de Email
	private cPassAut  :=Alltrim(GetMv("MV_RELAPSW",,cPassword)) //Senha para Autenticação no Servidor de Email
	private cTo       :=space(200)
	private cCC       :=space(200)
	private cSubject  :=If(cEmpAnt=='04','Health Quality EDI '+AllTrim(cNomReduz)+' ('+cNomeArq+'.TXT)','Dipromed EDI '+AllTrim(cNomReduz)+' ('+cNomeArq+'.TXT)')
	SA4->(dbSetOrder(1))
	SA4->(dbSeek(xFilial('SA4')+cCodTransp))
	cTo := If(cEmpAnt == '04' .And. cCodTransp == '000905',GetNewPar("ES_MAILEDI","celson@cpq.jamef.com.br;cpd@cpq.jamef.com.br"),SA4->A4_EDIEMAI) //Ajustado para buscar e-mail do Parâmetro - Health Quality
	PswOrder(1)
	PswSeek(RetCodUsr(),.T.)
	aUsuario := PswRet(1)
	If cEmpAnt == '04'// Health Quality
		cCC:=AllTrim(aUsuario[1,14])+";faturamento@healthquality.ind.br;expedicao@healthquality.ind.br;coordenacaocd@healthquality.ind.br"
	Else
		cCC:=AllTrim(aUsuario[1,14])+";edvan.matias@dipromed.com.br;emovere02@emovere.com.br;lourival.nunes@dipromed.com.br"
	Endif
	cFrom:=Lower(Alltrim(GetMv("MV_RELACNT")))
	cCC:=cCc+space(200)
	Define msdialog oDlgMail of oMainWnd from 0,0 to 200,544 pixel title 'Dados do e-mail'
	@ 05,04 to 079,268 of oDlgMail pixel
	@ 18,08 say "De: "  size 12,8 of oDlgMail pixel
	@ 33,08 say "Para:" size 16,8 of oDlgMail pixel
	@ 48,08 say "CC:"   size 16,8 of oDlgMail pixel
	@ 63,08 say "Assunto:" size 21,8 of oDlgMail pixel
	@ 18,33 msget cFrom Size 233,10 when .F. of oDlgMail pixel
	@ 33,33 msget cTo size 233,10 F3 "_EM" of oDlgMail pixel
	@ 48,33 msget cCC size 233,10 F3 "_EM" of oDlgMail pixel
	@ 63,33 msget cSubject Size 233,10 of oDlgMail pixel
	Define sbutton from 85,100 type 1 action (If(!Empty(cTo),If(oDlgMail:End(),nOp:=1,),Help("",1,"AVG0001054"))) enable of oDlgMail pixel
	Define sbutton from 85,140 type 2 action (oDlgMail:End()) enable of oDlgMail pixel
	Activate msdialog oDlgMail centered
	If nOp = 1
		MsAguarde({||GeraMail()},'Aguarde...','Gerando arquivo...')
	EndIf
EndIf
Return Nil
*-------------------------------------------*
Static Function GeraMail(cEdi)  
*-------------------------------------------*
Local cAnexos:= ""
Local lOk    := .T.
LOCAL lSmtpAuth := GetNewPar("MV_RELAUTH",.F.)
LOCAL lAutOk	:= .F.
Private cBody:=""
//Private cEdi := GetSrvProfString("STARTPATH","")+"EDI\ENVIO\"+cIdentInter+".TXT"

// Alterado para gravar arquivos na pasta protheus_data - Por Sandro em 19/11/09. 
Private cEdi := "\EDI\ENVIO\"+cNomeArq+".TXT"

@ 060,100 msget oPlacCamin var cPlacCamin valid EdiValid('PLACA') picture "!!!9999" size 40,08 pixel
@ 070,100 msget oMotorista var cMotorista valid EdiValid('MOTORISTA') size 90,08 pixel
@ 080,100 msget oAjudante  var cAjudante  valid EdiValid('AJUDANTE') size 90,08 pixel
@ 090,100 msget oOperExped var cOperExped valid EdiValid('EXPEDICAO') size 90,08 pixel
@ 100,100 msget oHrEntrada var cHrEntrada valid EdiValid('HRENTRADA') size 40,08 pixel
@ 110,100 msget oDtSaida   var dDtSaida   valid EdiValid('DTSAIDA') size 40,08 pixel
@ 120,100 msget oHrSaida   var cHrSaida   valid EdiValid('HRSAIDA') size 40,08 pixel
cBody := '<html>'
cBody += '<head>'
If cEmpAnt == '04'                                                                     
	cBody += '<title>Health Quality EDI '+AllTrim(cNomReduz)+' ('+cNomeArq+'.TXT)</title>'
Else
	cBody += '<title>Dipromed EDI '+AllTrim(cNomReduz)+' ('+cNomeArq+'.TXT)</title>'
Endif
cBody += '</head>'
cBody += '<body>'
cBody += '<table width="100%" border="1">'
cBody += '<tr align="center">'
cBody += '<td width="100%" colspan="10"><font color="blue" size="4"></font></td>'
cBody += '</tr>'
cBody += '<tr align="center">'                                                         
If cEmpAnt == '04'                                                                                                      
	cBody += '<td width="100%" colspan="10"><font color="blue" size="4">Health Quality EDI '+AllTrim(cNomReduz)+'</font></td>'
Else
	cBody += '<td width="100%" colspan="10"><font color="blue" size="4">Dipromed EDI '+AllTrim(cNomReduz)+'</font></td>'
Endif
cBody += '</tr>'
cBody += '<tr align="center">'
cBody += '<td width="100%" colspan="10" align="center"><font color="blue" size="2">Segue em anexo o arquivo de intercambio de notas fiscais</td>'
cBody += '</font>'
cBody += '</tr>'
cBody += '<tr align="left">'
cBody += '<td width="30%"><font color="blue" size="2">Arquivo</td>'
cBody += '<td width="25%" colspan="10" align="left"><font color="red" size="2">'+cNomeArq+'.txt</td>'
cBody += '</font>'
cBody += '</tr>'
cBody += '<tr align="leftr">'
cBody += '<td width="30%"><font color="blue" size="2">Placa do caminhão</td>'
cBody += '<td width="25%" colspan="10" align="left"><font color="red" size="2">'+cPlacCamin+'</td>'
cBody += '</font>'
cBody += '</tr>'
cBody += '<tr align="left">'
cBody += '<td width="30%"><font color="blue" size="2">Nome do motorista</td>'
cBody += '<td width="25%" colspan="10" align="left"><font color="red" size="2">'+cMotorista+'</td>'
cBody += '</font>'
cBody += '</tr>'
cBody += '<tr align="left">'
cBody += '<td width="30%"><font color="blue" size="2">Nome do ajudante</td>'
cBody += '<td width="25%" colspan="10" align="left"><font color="red" size="2">'+cAjudante+'</td>'
cBody += '</font>'
cBody += '</tr>'
cBody += '<tr align="left">'
cBody += '<td width="30%"><font color="blue" size="2">Nome do operador de expedição</td>'
cBody += '<td width="25%" colspan="10" align="left"><font color="red" size="2">'+cOperExped+'</td>'
cBody += '</font>'
cBody += '</tr>'
cBody += '<tr align="left">'
cBody += '<td width="30%"><font color="blue" size="2">Hora de Chegada do caminhão</td>'
cBody += '<td width="25%" colspan="10" align="left"><font color="red" size="2">'+cHrEntrada+'</td>'
cBody += '</font>'
cBody += '</tr>'
cBody += '<tr align="left">'
cBody += '<td width="30%"><font color="blue" size="2">Data de saida do caminhão</td>'
cBody += '<td width="25%" colspan="10" align="left"><font color="red" size="2">'+dtoc(dDtSaida)+'</td>'
cBody += '</font>'
cBody += '</tr>'
cBody += '<tr align="left">'
cBody += '<td width="30%"><font color="blue" size="2">Hora de saida do caminhão</td>'
cBody += '<td width="25%" colspan="10" align="left"><font color="red" size="2">'+cHrSaida+'</td>'
cBody += '</font>'
cBody += '</tr>'    
cBody += '<tr align="left">'
cBody += '<td width="30%"><font color="blue" size="2">Quantidade de Notas Fiscais</td>'
cBody += '<td width="25%" colspan="10" align="left"><font color="red" size="2">'+Transform(nTotNF,'@E 999,999,999')+'</td>'  // MCVN - 01/08/2007
cBody += '</font>'
cBody += '</tr>'
cBody += '<tr align="left">'
cBody += '<td width="30%"><font color="blue" size="2">Volumes</td>'
cBody += '<td width="25%" colspan="10" align="left"><font color="red" size="2">'+Transform(nVolume,'@Ee 999,999,999')+'</td>' // MCVN - 01/08/2007
cBody += '</font>'
cBody += '</tr>'
cBody += '<tr align="center">'
cBody += '<td colspan="10"><font color="blue" size="3">Mensagem enviada automaticamente pelo sistema PROTHEUS - <font color="blue" size="1">(DIPM018.PRW)</td>'
cBody += '</tr>'
   
MsProcTxt("ENVIANDO E-MAIL...")    

If GetNewPar("ES_ATIVJOB",.T.)   
	u_UEnvMail(AllTrim(cTo)+";"+AllTrim(cCC),cSubject,nil,cEdi,cFrom,"GeraMail(DIPM018.PRW)",cBody)
Else
	cTo := AvLeGrupoEMail(cTo)
	cCC := AvLeGrupoEMail(cCC)
	
	CONNECT SMTP SERVER cServer ACCOUNT cAccount PASSWORD cPassword TIMEOUT nTimeOut Result lOk
	
	If !lAutOk
		If ( lSmtpAuth )
			lAutOk := MailAuth(cAccount,cPassword)
		Else
			lAutOk := .T.
		EndIf
	EndIf
	   
	If lOk .And. lAutOk
		If !Empty(cCC)
			SEND MAIL FROM cFrom TO cTo CC cCC SUBJECT cSubject BODY cBody ATTACHMENT cEdi Result lOk 
		Else
			SEND MAIL FROM cFrom TO cTo SUBJECT cSubject BODY cBody ATTACHMENT cEdi Result lOk
		EndIf
		If !lOk
			GET MAIL ERROR cErrorMsg
			Help("",1,"AVG0001056",,"Error: "+cErrorMsg,2,0)
		EndIf
	Else
		GET MAIL ERROR cErrorMsg
		Help("",1,"AVG0001057",,"Error: "+cErrorMsg,2,0)
	EndIf
	DISCONNECT SMTP SERVER RESULT lOk
	If !lOk
		GET MAIL ERROR cErrorMsg
		MSGINFO('O Arquivo nao pode ser criado '+cErrorMsg,'Atenção')
	EndIf
EndIf

Return .T.    
*---------------------------------------------------------*
User Function DipM18LimEnt()                               
*---------------------------------------------------------*
Local cMsg := ''
_xAlias  := GetArea()
cMsg := 'Confirma a limpeza do controle de entrega das ' + ENTER +;
        'notas selecionadas, para entregar novamente?'

//SF2->(DbSetOrder(8))

SF2->(DbOrderNickName("F2OK2"))	// Utilizando DbOrderNickName ao invés de DbSetOrder  devido a virada de versão MCVN - 26/10/2007
If SF2->(DbSeek(xFilial("SF2")+cMarca))
   If MsgYesNo(cMsg,"Atenção")
       Do While SF2->(!Eof()) .and. xFilial("SF2") == SF2->F2_FILIAL
	       SF2->(Reclock("SF2",.f.)) 
	       SF2->F2_OK2 := ''
 	       SF2->F2_IDINTER := Space(12)
	       SF2->(MsUnlock("SF2"))
	       SF2->(DbSeek(xFilial("SF2")+cMarca))
       EndDo    
   EndIF
Else   
   MsgInfo('Por favor selecione um ou mais notas para liberar a re-entrega','Atenção')  
EndIf 
RestArea(_xAlias)
return(.t.)
*---------------------------------------------------------*
User Function DipM18Ocorre(cAlias,nReg,nOpc)
*---------------------------------------------------------*
local oDlg
local nOpcao:=0
local bOk:={|| nOpcao := 1, oDlg:End()}
local bCancel:={|| nOpcao := 0, oDlg:End()}
local lRetorno:=.T.
local lMarcados:=.F.
local aExibe := {"F2_DOC",;
                 "F2_SERIE",;
                 "F2_DATASAI",;
                 "F2_HORASAI",;
                 "F2_PLCCAMI",;
                 "F2_MOTORIS",;
                 "F2_AJUDANT",;
                 "F2_OPEREXP",;
                 "F2_EDIOCOV" }	
local aAltera := {"F2_EDIOCOV"}	
nOpc := 4             
If cMarca == SF2->F2_OK2
	RegToMemory(cAlias,.f.)
	M->F2_DOC     := SF2->F2_DOC
	M->F2_SERIE   := SF2->F2_SERIE
	M->F2_DATASAI := SF2->F2_DATASAI
	M->F2_HORASAI := SF2->F2_HORASAI
	M->F2_PLCCAMI := SF2->F2_PLCCAMI
	M->F2_MOTORIS := SF2->F2_MOTORIS
	M->F2_AJUDANT := SF2->F2_AJUDANT
	M->F2_OPEREXP := SF2->F2_OPEREXP
	M->F2_EDIOCOV := Trim(StrTran(MSMM(SF2->F2_EDIOCOM,,,,3),"\13\10",""))
	If cEmpAnt == '04'                                                                             
		Define msDialog oDlg title OemToAnsi("Ocorrencias na entrega Health Quality") From 00,00 TO 29,80
	Else
		Define msDialog oDlg title OemToAnsi("Ocorrencias na entrega Dipromed") From 00,00 TO 29,80
	EndIf
	EnChoice( cAlias, nReg, nOpc,,,,aExibe,{013,001,217,315}, aAltera,,,,,,,.T. )
	Activate Dialog oDlg on init enchoicebar(oDlg,bOK,bCancel) Centered
	If nOpcao = 1
		SF2->(Reclock("SF2",.f.))
        SF2->F2_OK2 := ''
		If Empty(SF2->F2_EDIOCOM)
			MSMM(,60,,M->F2_EDIOCOV,1,,,"SF2","F2_EDIOCOM")
		Else
			MSMM(SF2->F2_EDIOCOM,60,,M->F2_EDIOCOV,4,,,"SF2","F2_EDIOCOM")
		EndIf
		SF2->(MsUnlock("SF2"))
	EndIf
Else
    MsgInfo('Por favor selecione uma nota para informar a ocorrencia','Atenção')
EndIf
Return(.t.)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³UTMSR09   ºAutor  ³Microsiga           º Data ³  02/26/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/                
Static Function DipRetExp(cFilSC5,cPedido,cDoc,cSerie)
Local cSQL := ""
Local cExp := ""    
DEFAULT cFilSC5 := ""
DEFAULT cPedido := ""
DEFAULT cDoc 	:= ""
DEFAULT cSerie 	:= ""

cSQL := " SELECT "
cSQL += " 		ZZ5_EXPED1, ZZ5_EXPED2 "
cSQL += " 		FROM "
cSQL += " 		ZZ5010 "
cSQL += " 			WHERE "
cSQL += " 				ZZ5_FILIAL = '"+cFilSC5+"' AND "
cSQL += " 				ZZ5_PEDIDO = '"+cPedido+"' AND "
cSQL += " 				ZZ5_NOTA = '"+cDoc+"' AND "
cSQL += " 				ZZ5_SERIE = '"+cSerie+"' AND "
cSQL += " 				D_E_L_E_T_ = ' ' "        

cSQL := ChangeQuery(cSQL)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),'QRYZZ5',.T.,.F.)      

If !QRYZZ5->(Eof())
	cExp := AllTrim(QRYZZ5->ZZ5_EXPED1)
	If !Empty(QRYZZ5->ZZ5_EXPED2)
		cExp += "/"+AllTrim(QRYZZ5->ZZ5_EXPED2)
	EndIf
EndIf                                        
QRYZZ5->(dbCloseArea())

Return cExp

/*-----------------------------------------------------------------------------------
REGINALDO BORGES 19/09/2016
Função........:  RetObs()                                
Objetivo......: Retornar a observacao do usuário para ser impressa no relatório
-------------------------------------------------------------------------------------*/

STATIC FUNCTION RetObs(cGetObs,cObserv)                          

	cObserv := cGetObs

RETURN (cObserv) 

#include 'Protheus.ch'
/*/
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪穆哪哪哪穆哪哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘�
北矲un噭o    � WmsR320 � Autor � Flavio Luiz Vicco      � Data �16/10/2006潮�
北媚哪哪哪哪呐哪哪哪哪牧哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢�
北矰escri噭o � Relatorio de enderecos vazios                              潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北� Uso      � SIGAWMS                                                    潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
/*/
User Function DIPR075()
Local oReport
AjustaSX1()
If FindFunction("TRepInUse") .And. TRepInUse()
	//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
	//矷nterface de impressao                                                  �
	//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
	oReport:= ReportDef()
	oReport:PrintDialog()
Else
	WmsR320R3()
EndIf
Return NIL
/*/
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘�
北砅rograma  � ReportDef矨utor  矲lavio Luiz Vicco      矰ata  �16/10/2006潮�
北媚哪哪哪哪呐哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢�
北矰escri噮o � Relatorio de enderecos vazios                              潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砅arametros� nExp01: nReg = Registro posicionado do SC3 apartir Browse  潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砇etorno   � oExpO1: Objeto do relatorio                                潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
/*/
Static Function ReportDef()
Local cAliasNew := "SBE"
Local cTitle    := OemToAnsi("Relatorio de Enderecos Vazios") //"Relatorio de Enderecos Vazios"
Local oReport
Local oSection1
Local oSection2
dbSelectArea(cAliasNew)
dbSetOrder(1)
#IFDEF TOP
	cAliasNew := GetNextAlias()
#ENDIF
//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
//矯riacao do componente de impressao                                      �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
oReport := TReport():New("WMSR320",cTitle,"WMR320",{|oReport| ReportPrint(oReport,cAliasNew)},"Relatorio de Enderecos Vazios") //"Relatorio de Enderecos Vazios"
//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
//� Variaveis utilizadas para parametros                                   �
//媚哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪拇
//� mv_par01  //  Armazem   De  ?                                          �
//� mv_par02  //            Ate ?                                          �
//� mv_par03  //  Zona      De  ?                                          �
//� mv_par04  //            Ate ?                                          �
//� mv_par05  //  Estrutura De  ?                                          �
//� mv_par06  //            Ate ?                                          �
//� mv_par07  //  Endereco  De  ?                                          �
//� mv_par08  //            Ate ?                                          �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
Pergunte(oReport:uParam,.F.)
//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
//矯riacao da secao utilizada pelo relatorio                               �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
oSection1:= TRSection():New(oReport,"Enderecos - Estruturas",{"SBE"},/*aOrdem*/) //"Enderecos - Estruturas"
oSection1:SetLineStyle()
TRCell():New(oSection1,"BE_LOCAL",	"SBE")
TRCell():New(oSection1,"BE_CODZON",	"SBE")
TRCell():New(oSection1,"CDESZON",	"","Descricao",,20,,{||If(lQuery,(cAliasNew)->DC4_DESZON,Posicione('DC4',1,xFilial('DC4')+(cAliasNew)->BE_CODZON,'DC4_DESZON'))}) //"Descricao"
TRCell():New(oSection1,"BE_ESTFIS",	"SBE")
TRCell():New(oSection1,"CDESEST",	"","Descricao",,30,,{||If(lQuery,(cAliasNew)->DC8_DESEST,Posicione('DC8',1,xFilial('DC8')+(cAliasNew)->BE_ESTFIS,'DC8_DESEST'))}) //"Descricao"
//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
//矯riacao da secao utilizada pelo relatorio                               �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
oSection2:= TRSection():New(oSection1,"Enderecos",{"SBE"},/*aOrdem*/) //"Enderecos"
oSection2:SetHeaderPage(.T.)
TRCell():New(oSection2,"BE_LOCALIZ","SBE")
TRCell():New(oSection2,"LACUNA1","","Documento",,16,,{||"________________"}) //"Documento"
TRCell():New(oSection2,"LACUNA2","","Produto",,19,,{||"___________________"}) //"Produto"
TRCell():New(oSection2,"LACUNA3","","Quantidade",,17,,{||"_________________"}) //"Quantidade"
Return(oReport)
/*/
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪穆哪哪哪穆哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘�
北砅rograma  砇eportPrint� Autor 矲lavio Luiz Vicco     矰ata  �16/10/2006潮�
北媚哪哪哪哪呐哪哪哪哪哪牧哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢�
北矰escri噮o 砇elatorio de enderecos vazios                               潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砇etorno   砃enhum                                                      潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砅arametros矱xpO1: Objeto Report do Relat髍io                           潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
/*/
Static Function ReportPrint(oReport,cAliasNew)
Local oSection1 := oReport:Section(1)
Local oSection2 := oReport:Section(1):Section(1)
Local cQuebra   := ""
Local cCondicao := ""
Local lQuery    := .F.
oSection1:Cell("CDESZON"):HideHeader()
oSection1:Cell("CDESEST"):HideHeader()
#IFDEF TOP
	//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
	//砊ransforma parametros Range em expressao SQL                            �
	//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
	MakeSqlExpr(oReport:GetParam())
	//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
	//砆uery do relat髍io da secao 1                                       �
	//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
	lQuery := .T.
	oSection1:BeginQuery()
	BeginSql Alias cAliasNew
	//-->
	SELECT BE_FILIAL, BE_LOCAL, BE_CODZON, BE_ESTFIS, BE_LOCALIZ, DC4_DESZON, DC8_DESEST
	FROM %table:SBE% SBE
	LEFT JOIN %table:DC4%  DC4 ON DC4_FILIAL = %xFilial:DC4% AND DC4_CODZON = BE_CODZON AND DC4.%NotDel%
	LEFT JOIN %table:DC8%  DC8 ON DC8_FILIAL = %xFilial:DC8% AND DC8_CODEST = BE_ESTFIS AND DC8.%NotDel%
	WHERE BE_STATUS  = '1'
	AND BE_LOCAL   BETWEEN %Exp:mv_par01% AND %Exp:mv_par02%
	AND BE_CODZON  BETWEEN %Exp:mv_par03% AND %Exp:mv_par04%
	AND BE_ESTFIS  BETWEEN %Exp:mv_par05% AND %Exp:mv_par06%
	AND BE_LOCALIZ BETWEEN %Exp:mv_par07% AND %Exp:mv_par08%
	AND SBE.%NotDel%
	ORDER BY BE_FILIAL, BE_LOCAL, BE_CODZON, BE_ESTFIS, BE_LOCALIZ
	//-->
	EndSql 
	//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
	//矼etodo EndQuery ( Classe TRSection )                                    �
	//�                                                                        �
	//砅repara o relat髍io para executar o Embedded SQL.                       �
	//�                                                                        �
	//矱xpA1 : Array com os parametros do tipo Range                           �
	//�                                                                        �
	//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
	oSection1:EndQuery(/*Array com os parametros do tipo Range*/)
#ELSE
	//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
	//砊ransforma parametros Range em expressao Advpl                          �
	//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
	MakeAdvplExpr(oReport:uParam)
	cCondicao := " BE_STATUS  == '1' .And. "
	cCondicao += " BE_LOCAL   >= '"+mv_par01+"' .And. "
	cCondicao += " BE_LOCAL   <= '"+mv_par02+"' .And. "
	cCondicao += " BE_CODZON  >= '"+mv_par03+"' .And. "
	cCondicao += " BE_CODZON  <= '"+mv_par04+"' .And. "
	cCondicao += " BE_ESTFIS  >= '"+mv_par05+"' .And. "
	cCondicao += " BE_ESTFIS  <= '"+mv_par06+"' .And. "
	cCondicao += " BE_LOCALIZ >= '"+mv_par07+"' .And. "
	cCondicao += " BE_LOCALIZ <= '"+mv_par08+"'"
	oSection1:SetFilter(cCondicao,"BE_FILIAL+BE_LOCAL+BE_CODZON+BE_ESTFIS+BE_LOCALIZ")
#ENDIF
oSection1:SetParentQuery()
oSection2:SetParentQuery()
oReport:SetMeter(SBE->(LastRec()))
dbSelectArea(cAliasNew)
oSection1:Init()
oSection2:Init()
While !oReport:Cancel() .And. !(cAliasNew)->(Eof())
	oReport:IncMeter()
	If oReport:Cancel()
		Exit
	EndIf
	If	cQuebra != (cAliasNew)->BE_FILIAL+(cAliasNew)->BE_LOCAL+(cAliasNew)->BE_CODZON+(cAliasNew)->BE_ESTFIS
		cQuebra := (cAliasNew)->BE_FILIAL+(cAliasNew)->BE_LOCAL+(cAliasNew)->BE_CODZON+(cAliasNew)->BE_ESTFIS
		oReport:EndPage()
		oSection1:PrintLine()
	EndIf
	oReport:SkipLine()
	oSection2:PrintLine()
	(cAliasNew)->(dbSkip())
EndDo
oSection1:Finish()
Return NIL
/*
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪穆哪哪哪穆哪哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘�
北矲un噭o    砏msR320R3� Autor � Alex Egydio            � Data �13.01.2005潮�
北媚哪哪哪哪呐哪哪哪哪牧哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢�
北矰escri噭o � Relatorio de enderecos vazios                              潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砅arametros�                                                            潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�*/
Static Function WmsR320R3()
Local wnRel		:= 'UWMSR320'
Local cDesc1	:= 'Relatorio de Enderecos Vazios' //'Relatorio de Enderecos Vazios'
Local cDesc2	:= ''
Local cDesc3	:= ''
Local cPerg		:= 'WMR320'
Local Tamanho	:= 'P'
Local Titulo	:= 'Relatorio de Enderecos Vazios' //'Relatorio de Enderecos Vazios'
Local lEnd		:= .F.

Private aReturn:= {'Zebrado',1,'Administracao',1,2,1,'',1} //'Zebrado'###'Administracao'
//-- Variaveis utilizadas como parametro
//--
//-- mv_par01  //  Armazem   De  ?
//-- mv_par02  //            Ate ?
//-- mv_par03  //  Zona      De  ?
//-- mv_par04  //            Ate ?
//-- mv_par05  //  Estrutura De  ?
//-- mv_par06  //            Ate ?
//-- mv_par07  //  Endereco  De  ?
//-- mv_par08  //            Ate ?
Pergunte(cPerg,.F.)

wnRel:=SetPrint('SBE',wnRel,cPerg,@Titulo,cDesc1,cDesc2,cDesc3,.F.,,.T.,Tamanho,.T.)

If ( nLastKey==27 )
	DbSelectArea('SBE')
	DbSetOrder(1)
	Set Filter to
	Return NIL
EndIf

SetDefault(aReturn,'SBE')

If ( nLastKey==27 )
	DbSelectArea('SBE')
	DbSetOrder(1)
	Set Filter to
	Return NIL
EndIf

RptStatus({|lEnd| WmsR320Imp(@lEnd,wnRel,Tamanho,Titulo)},Titulo)

Return NIL
/*
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘�
北矲un噭o    砏msR320Imp� Autor � Alex Egydio           � Data �13.01.2005潮�
北媚哪哪哪哪呐哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢�
北矰escri噭o � Relatorio de enderecos vazios                              潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砅arametros� ExpL1 - .F. = Interrompe a impressao                       潮�
北�          � ExpC1 - Nome do arquivo utilizado no spool de impressao    潮�
北�          � ExpC2 - Tamanho do relatorio                               潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�*/
Static Function WmsR320Imp(lEnd,wnRel,Tamanho,Titulo)
Local cAliasNew:= 'SBE'
//                 0         1         2         3         4         5         6         7         8         9        10        11        12        13        14        15        16        17        18        19        20        21        22
//                 01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
Local cCabec1	:= ''
Local cCabec2	:= 'ENDERECO               DOCUMENTO         PRODUTO - LOTE              QUANTIDADE'
//                                         ________________  ________-_______________    __________
Local cQuebra	:= ''
Local cQuery	:= ''
#IFNDEF TOP
	Local cIndSBE	:= ''
	Local nIndex	:= 0
#ENDIF
Private li		:= 80
Private m_pag	:= 01


cAliasNew:= GetNextAlias()
	
cQuery := " SELECT 	A.BE_FILIAL,A.BE_LOCAL,A.BE_CODZON,A.BE_ESTFIS,A.BE_LOCALIZ,DC4_DESZON,DC8_DESEST "
cQuery += " FROM "+RetSqlName('SBE')+" B, "+RetSqlName('SBE')+" A "
cQuery += " LEFT JOIN "+RetSqlName('DC4')+" DC4 ON DC4_FILIAL = '"+xFilial("DC4")+"' AND DC4_CODZON = BE_CODZON AND DC4.D_E_L_E_T_ = ' ' "
cQuery += " LEFT JOIN "+RetSqlName('DC8')+" DC8 ON DC8_FILIAL = '"+xFilial("DC8")+"' AND DC8_CODEST = BE_ESTFIS AND DC8.D_E_L_E_T_ = ' ' "
cQuery += " WHERE "
If cEmpAnt == '04'
	cQuery += " A.BE_FILIAL = '01' AND "
	cQuery += " B.BE_FILIAL = '02' AND " 
Else
	cQuery += " A.BE_FILIAL = '01' AND "
	cQuery += " B.BE_FILIAL = '04' AND " 
EndIf
cQuery += " A.BE_STATUS = '1' AND "
cQuery += "	A.BE_LOCAL BETWEEN '"+mv_par01+"' AND '"+mv_par02+"' AND "
cQuery += "	A.BE_CODZON BETWEEN '"+mv_par03+"' AND '"+mv_par04+"' AND "
cQuery += "	A.BE_ESTFIS BETWEEN '"+mv_par05+"' AND '"+mv_par06+"' AND "
cQuery += "	A.BE_LOCALIZ BETWEEN '"+mv_par07+"' AND '"+mv_par08+"' AND "   
cQuery += "	A.BE_STATUS = B.BE_STATUS AND "
cQuery += "	A.BE_LOCAL  = B.BE_LOCAL  AND "
cQuery += "	A.BE_CODZON = B.BE_CODZON AND "
cQuery += "	A.BE_ESTFIS = B.BE_ESTFIS AND "
cQuery += "	A.BE_LOCALIZ= B.BE_LOCALIZ AND "
cQuery += "	A.D_E_L_E_T_ = ' '  AND "
cQuery += "	B.D_E_L_E_T_ = ' ' "
cQuery += "	GROUP BY A.BE_FILIAL,A.BE_LOCAL,A.BE_CODZON,A.BE_ESTFIS,A.BE_LOCALIZ,DC4_DESZON,DC8_DESEST "
cQuery += "	ORDER BY  A.BE_FILIAL, A.BE_LOCAL, A.BE_CODZON, A.BE_ESTFIS, A.BE_LOCALIZ "

cQuery := ChangeQuery(cQuery)
DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasNew,.F.,.T.)


While (cAliasNew)->(!Eof())
	If lEnd
		@ Prow()+1,001 PSAY 'CANCELADO PELO OPERADOR'	//'CANCELADO PELO OPERADOR'
		Exit
	EndIf

	#IFDEF TOP
		cCabec1 := 'ARMAZEM: '+(cAliasNew)->BE_LOCAL+' ZONA: '+(cAliasNew)->DC4_DESZON+' ESTRUTURA: '+(cAliasNew)->DC8_DESEST	//'ARMAZEM: '###' ZONA: '###' ESTRUTURA: '
	#ELSE
		cCabec1 := 'ARMAZEM: '+(cAliasNew)->BE_LOCAL+' ZONA: '+Posicione('DC4',1,xFilial('DC4')+(cAliasNew)->BE_CODZON,'DC4_DESZON')+' ESTRUTURA: '+Posicione('DC8',1,xFilial('DC8')+(cAliasNew)->BE_ESTFIS,'DC8_DESEST')
	#ENDIF

	If	li > 55 .Or. cQuebra != (cAliasNew)->BE_FILIAL+(cAliasNew)->BE_LOCAL+(cAliasNew)->BE_CODZON+(cAliasNew)->BE_ESTFIS
		cQuebra := (cAliasNew)->BE_FILIAL+(cAliasNew)->BE_LOCAL+(cAliasNew)->BE_CODZON+(cAliasNew)->BE_ESTFIS
		Cabec(Titulo,cCabec1,cCabec2,wnRel,Tamanho)
		li++
	EndIf
	@ li,001 PSay (cAliasNew)->BE_LOCALIZ
	@ li,023 PSay '________________'
	@ li,041 PSay '________-________________'//+5
	@ li,069 PSay '___________'//(62)-5
	li+=2
	(cAliasNew)->(DbSkip())
EndDo

#IFDEF TOP
	DbSelectarea(cAliasNew)
	DbCloseArea()
#ELSE
	If	File(cIndSBE+OrdBagExt())
		Ferase(cIndSBE+OrdBagExt())
	EndIf
#ENDIF
	
If aReturn[5] == 1
	Set Printer To
	dbCommitAll()
	OurSpool(wnRel)
Endif

MS_FLUSH()

Return NIL
/*/
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘�
北矲uncao    矨justaSX1 � Autor � Flavio Luiz Vicco     � Data �16/10/2006潮�
北媚哪哪哪哪呐哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢�
北矰escri噮o 矯ria as perguntas necessarias para o programa               潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砇etorno   砃enhum                                                      潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砅arametros砃enhum                                                      潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
/*/
Static Function AjustaSX1()
Local cPerg      := 'WMR320'
Local nTamSX1    := Len(SX1->X1_GRUPO)
Local aHelpPor01 := {'Armaz閙 inicial onde se encontra','o endere鏾.'}
Local aHelpEsp01 := {'Almac閚 inicial donde se encuentra','la direcci髇'}
Local aHelpEng01 := {'Initial warehouse where the address','can be found.'}

Local aHelpPor02 := {'Armaz閙 final onde se encontra','o endere鏾'}
Local aHelpEsp02 := {'Almac閚 final donde se encuentra','la direcci髇'}
Local aHelpEng02 := {'Final warehouse where the address','can be found.'}

Local aHelpPor03 := {'Zona de armazenagem inicial na qual','pertence o endere鏾'}
Local aHelpEsp03 := {'Zona de almacenaje inicial a la que','pertenece la direcci髇'}
Local aHelpEng03 := {'Initial warehouse area where the','address belongs to.'}

Local aHelpPor04 := {'Zona de armazenagem final na qual','pertence o endere鏾'}
Local aHelpEsp04 := {'Zona de almacenaje final a la que','pertenece la direcci髇'}
Local aHelpEng04 := {'Final warehouse area where the','address belongs to.'}

Local aHelpPor05 := {'Estrutura f韘ica inicial na qual','pertence o endere鏾.'}
Local aHelpEsp05 := {'Estructura f韘ica inicial a la que','pertenece la direcci髇'}
Local aHelpEng05 := {'Initial physical structure where','the address belongs to.'}

Local aHelpPor06 := {'Estrutura f韘ica final na qual','pertence o endere鏾'}
Local aHelpEsp06 := {'Estructura f韘ica final a la que','pertenece la direcci髇'}
Local aHelpEng06 := {'Final physical structure where','the address belongs to.'}

Local aHelpPor07 := {'Endereco inicial'}
Local aHelpEsp07 := {'Direcci髇 inicial'}
Local aHelpEng07 := {'Initial address'}

Local aHelpPor08 := {'Endereco final'}
Local aHelpEsp08 := {'Direcci髇 final'}
Local aHelpEng08 := {'Final address'}

//-- Verifica se a pergunta 01 esta atualizada - Se nao estiver, apaga todas as perguntas...
If SX1->(MsSeek(PADR(cPerg,nTamSX1)+'01', .F.) .And. ("ARMAZEM" $ Upper(X1_PERSPA) .Or. "ALMACEM" $ Upper(X1_PERSPA)))
	Do While !SX1->(Eof()) .And. PADR(cPerg,nTamSX1) == SX1->X1_GRUPO
		Reclock('SX1', .F.)
		dbDelete()
		MsUnlock()
		SX1->(dbSkip())
	EndDo
EndIf
PutSx1(cPerg,'01','Armazem   De  ?','緿e Almac閚    ?','From Warehouse ?','mv_ch1','C', 2, 0, 0,'G','',''   ,'','','mv_par01','','','','','','','','','','','','','','','','',aHelpPor01,aHelpEng01,aHelpEsp01)
PutSx1(cPerg,'02','Armazem   Ate ?','緼  Almac閚    ?','To   Warehouse ?','mv_ch2','C', 2, 0, 0,'G','',''   ,'','','mv_par02','','','','','','','','','','','','','','','','',aHelpPor02,aHelpEng02,aHelpEsp02)
PutSx1(cPerg,'03','Zona      De  ?','緿e Zona       ?','From Area      ?','mv_ch3','C', 6, 0, 0,'G','','DC4','','','mv_par03','','','','','','','','','','','','','','','','',aHelpPor03,aHelpEng03,aHelpEsp03)
PutSx1(cPerg,'04','Zona      Ate ?','緼  Zona       ?','To   Area      ?','mv_ch4','C', 6, 0, 0,'G','','DC4','','','mv_par04','','','','','','','','','','','','','','','','',aHelpPor04,aHelpEng04,aHelpEsp04)
PutSx1(cPerg,'05','Estrutura De  ?','緿e Estructura ?','From Estructure?','mv_ch5','C', 6, 0, 0,'G','','DC8','','','mv_par05','','','','','','','','','','','','','','','','',aHelpPor05,aHelpEng05,aHelpEsp05)
PutSx1(cPerg,'06','Estrutura Ate ?','緼  Estructura ?','To   Estructure?','mv_ch6','C', 6, 0, 0,'G','','DC8','','','mv_par06','','','','','','','','','','','','','','','','',aHelpPor06,aHelpEng06,aHelpEsp06)
PutSx1(cPerg,'07','Endereco  De  ?','緿e Direccion  ?','From Address   ?','mv_ch7','C',15, 0, 0,'G','',''   ,'','','mv_par07','','','','','','','','','','','','','','','','',aHelpPor07,aHelpEng07,aHelpEsp07)
PutSx1(cPerg,'08','Endereco  Ate ?','緼  Direccion  ?','To   Address   ?','mv_ch8','C',15, 0, 0,'G','',''   ,'','','mv_par08','','','','','','','','','','','','','','','','',aHelpPor08,aHelpEng08,aHelpEsp08)
Return NIL

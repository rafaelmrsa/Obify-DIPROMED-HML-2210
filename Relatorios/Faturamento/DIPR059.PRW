/*====================================================================================\
|Programa  | DIPR059.PRW  | Autor  | Jailton B Santos, JBS   | Data | 04 Nov 2005     |
|=====================================================================================|
|Descrição | Gera o relatorio de Pedidos de Venda                                     |
|          |                                                                          |
|          |                                                                          |
|=====================================================================================|
|Sintaxe   | DIPR059()                                                                |
|=====================================================================================|
|Uso       | Especifico DIPROMED                                                      |
|=====================================================================================|
|........................................Histórico....................................|
|Rafael    | DD/MM/AA - Descrição                                                     |
|Maximo    | 05/03/07 - Inclusao das datas de liberação e liberação de crédito        |
|Maximo    | 05/11/09 - Inclusao de Estado e Município de entrega                     |
|Maximo    | 05/11/09 - Inclusao opção de filtro por  Estado                          |
\====================================================================================*/  

#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#DEFINE ENTER CHR(13)+CHR(10)
#DEFINE say_tit 1
#DEFINE say_det 2
#DEFINE say_rep 3
*-------------------------------------*
User Function DIPR059()                
*-------------------------------------*
Local aObj:=Array(6) 
Local alCheck:={.f.,.t.,.f.,.f.,.f.,.f.}
Local bOk:={|| If(DP59OKVALID(),(nOpcao:=1,oDlg:End()),nOpcao:=0)}
Local oDlg
Local oBt1
Local oBt2
Local oQuebra
Local oPelaData
Local oAtuDtInv
Local lQrySC5
Local lQrySF1
Local lWork
Local nOpcao:=0
Local aDados:={}

Local lExcel := .F.
Local oExcel
Local cArqExcell := "\Excell-DBF\"+U_DipUsr()+"-DIPR059"
Private cDestino := "C:\EXCELL-DBF\"

Private aReturn :={"Zebrado", 1,"Administracao", 1, 2, 1,"",1}
Private aRCampos:={}
Private aStru:={}
Private aReturn:={"Zebrado", 1,"Administracao", 1, 2, 1,"",1}
Private aOrderBy:={}
Private Query  

// Private cPerg:="DIPR59"
// FPADR(cPerg, cArq, cCampo, cTipo)  - Para ajustar o tamanho das perguntas no SX1- uso generico
PRIVATE cPerg  	:= U_FPADR( "DIPR59","SX1","SX1->X1_GRUPO"," " ) //Função criada por Sandro em 19/11/09.

Private cString:="SC5"
Private cPedidoIni:=Space(Len(SC5->C5_NUM))
Private cPedidoFin:=Space(Len(SC5->C5_NUM))
Private dDtIni:=cTod("")
Private dDtFin:=cTod("")
Private cEsteIni:=SPACE(02)
Private cEsteFin:=SPACE(02)
Private cHoraIni:=Space(8)
Private cHoraFin:=Space(8)
Private cOperIni:=Space(Len(SU7->U7_COD))
Private cOperFin:=Space(Len(SU7->U7_COD))
Private cTransIni:=Space(Len(SA4->A4_COD))
Private cTransFin:=Space(Len(SA4->A4_COD))
Private cArqWork
Private nRadio:=2    
Private aTotais:={0,0}    
Private cHrLib
Private dDtLib
Private cHrLibCred
Private dDtLibCred   
Private cHrGeraNf 
Private dDtGeraNf 
Private cHrImprNf 
Private dDtImprNf 
Private cMunE
Private cEstE

U_DIPPROC(ProcName(0),U_DipUsr()) // MCVN - 22/01/2009

aAdd(aOrderBy,{'Pedido'                 , 'C5_NUM'})
aAdd(aOrderBy,{'Data'                   , 'C5_DT_PRE, C5_HR_PRE'})
aAdd(aOrderBy,{'Codigo do Operador'     , 'C5_OPERADO'})
aAdd(aOrderBy,{'Nome do Operador'       , 'U7_NREDUZ'})
aAdd(aOrderBy,{'Codigo da Transpotadora', 'C5_TRANSP'})
aAdd(aOrderBy,{'Nome da Transportadora' , 'A4_NREDUZ'}) 
aAdd(aStru,{'C5_NUM'   	,AvSx3('C5_NUM'    ,2)	,AvSx3('C5_NUM'    ,3)	,AvSx3('C5_NUM'    ,4)})
aAdd(aStru,{'C5_EMISSAO',AvSx3('C5_EMISSAO',2)	,AvSx3('C5_EMISSAO',3)	,AvSx3('C5_EMISSAO',4)})
aAdd(aStru,{'C5_PRENOTA',AvSx3('C5_PRENOTA',2)	,AvSx3('C5_PRENOTA',3)	,AvSx3('C5_PRENOTA',4)})
aAdd(aStru,{'C5_DT_PRE' ,AvSx3('C5_DT_PRE' ,2)	,AvSx3('C5_DT_PRE' ,3)	,AvSx3('C5_DT_PRE' ,4)})
aAdd(aStru,{'C5_HR_PRE' ,AvSx3('C5_HR_PRE' ,2)	,5/*CAMPO HORA*/		,AvSx3('C5_HR_PRE' ,4)})
aAdd(aStru,{'C5_OPERADO',AvSx3('C5_OPERADO',2)	,AvSx3('C5_OPERADO',3)	,AvSx3('C5_OPERADO',4)})
aAdd(aStru,{'U7_NREDUZ' ,AvSx3('U7_NREDUZ' ,2)	,AvSx3('U7_NREDUZ' ,3)	,AvSx3('U7_NREDUZ' ,4)})
aAdd(aStru,{'C5_TRANSP' ,AvSx3('C5_TRANSP' ,2)	,AvSx3('C5_TRANSP' ,3)	,AvSx3('C5_TRANSP' ,4)})
aAdd(aStru,{'A4_NREDUZ' ,AvSx3('A4_NREDUZ' ,2)	,AvSx3('A4_NREDUZ' ,3)	,AvSx3('A4_NREDUZ' ,4)})
aAdd(aStru,{'DTLIB' 	,AvSx3('Z9_DATAMOV',2)	,AvSx3('Z9_DATAMOV',3)	,AvSx3('Z9_DATAMOV',4)})
aAdd(aStru,{'HRLIB' 	,AvSx3('Z9_HORAMOV',2)	,5/*CAMPO HORA*/		,AvSx3('Z9_HORAMOV',4)})
aAdd(aStru,{'DTLIBCRED' ,AvSx3('Z9_DATAMOV',2)	,AvSx3('Z9_DATAMOV',3)	,AvSx3('Z9_DATAMOV',4)})
aAdd(aStru,{'HRLIBCRED' ,AvSx3('Z9_HORAMOV',2)	,5/*CAMPO HORA*/		,AvSx3('Z9_HORAMOV',4)})
aAdd(aStru,{'DTGERANF' 	,AvSx3('Z9_DATAMOV',2)	,AvSx3('Z9_DATAMOV',3)	,AvSx3('Z9_DATAMOV',4)})
aAdd(aStru,{'HRGERANF' 	,AvSx3('Z9_HORAMOV',2)	,5/*CAMPO HORA*/		,AvSx3('Z9_HORAMOV',4)})
aAdd(aStru,{'DTIMPRNF' 	,AvSx3('Z9_DATAMOV',2)	,AvSx3('Z9_DATAMOV',3)	,AvSx3('Z9_DATAMOV',4)})
aAdd(aStru,{'HRIMPRNF' 	,AvSx3('Z9_HORAMOV',2)	,5/*CAMPO HORA*/		,AvSx3('Z9_HORAMOV',4)})
aAdd(aStru,{'C5_MUNE' 	,AvSx3('C5_MUNE'   ,2)	,AvSx3('C5_MUNE'   ,3)-2,AvSx3('C5_MUNE'   ,4)})
aAdd(aStru,{'C5_ESTE' 	,AvSx3('C5_ESTE'   ,2)	,AvSx3('C5_ESTE'   ,3)	,AvSx3('C5_ESTE'   ,4)})
aAdd(aStru,{'C5_BAIRROE',AvSx3('C5_BAIRROE',2)	,AvSx3('C5_BAIRROE',3)-2,AvSx3('C5_BAIRROE',4)}) // Giovani Zago 02/02/2012
aAdd(aStru,{'C5_XTIPPRE',AvSx3('C5_XTIPPRE',2)	,AvSx3('C5_XTIPPRE',3)	,AvSx3('C5_XTIPPRE',4)})
aAdd(aDados,"TRB") 
aAdd(aDados,OemTOAnsi("Relação de Pre-notas",72))
aAdd(aDados,OemToAnsi("Relação de Pre-notas",72))
aAdd(aDados,OemToAnsi("De acordo com parametros do usuario",72))
aAdd(aDados,"G")
aAdd(aDados,132)
aAdd(aDados,"Do Pedido:  Ate o Pedido: ")
aAdd(aDados,"Por Pedido")
aAdd(aDados,OemTOAnsi("Relação de Pre-notas",72))
aAdd(aDados,aReturn)
aAdd(aDados,"DIPR059") 
aAdd(aDados,{{||DIPR059Quebra()},{||Dipr059Final()}})  //aAdd(aDados,{{||.t.},{||.t.}})// 12
aAdd(aDados,Nil)              
SX1->(DipPergDiverg(.t.)) // Verifica se existe o no SX1 o "DIP057". Retorna os Valores ou cria
SA4->(dbSetOrder(1))
SC5->(dbSetOrder(1))
SU7->(dbSetOrder(1))  
Define msDialog oDlg title OemToAnsi("Relação de Prenotas") From 0,0 TO 14,57
@ 001,002 to 083,224 pixel
@ 004,004 to 080,148 pixel
@ 006,008 say 'Filtrar por :' Size 20,08 pixel   
@ 016,008 say 'Estado de' Pixel
@ 016,087 say 'Até' Pixel
@ 028,008 say 'Data de' Pixel
@ 028,087 say 'Até' Pixel
@ 040,008 say 'Hora de' Pixel
@ 040,087 say 'Até' Pixel
@ 054,008 say 'Operador de' Pixel
@ 054,087 say 'Até' Pixel
@ 066,008 say 'Transp. de' Pixel
@ 066,087 say 'Até' Pixel
                                                              
@ 016,044 get cEsteIni valid DP59VALID('ESTEI') Size 40,08 pixel
@ 016,104 get cEsteFin valid DP59VALID('ESTEF') Size 40,08 pixel
@ 028,044 get dDtIni valid DP59VALID('DATAI') Size 40,08 pixel
@ 028,104 get dDtFin valid DP59VALID('DATAF') Size 40,08 pixel
@ 040,044 get cHoraIni valid DP59VALID('HORAI') picture "99:99" Size 40,08 pixel
@ 040,104 get cHoraFin valid DP59VALID('HORAF') picture "99:99" Size 40,08 pixel
@ 054,044 get cOperIni valid DP59VALID('OPERADORI') Picture AvSx3('C5_OPERADO',6) Size 40,08 pixel
@ 054,104 get cOperFin valid DP59VALID('OPERADORF') Picture AvSx3('C5_OPERADO',6) Size 40,08 pixel
@ 066,044 get cTransIni valid DP59VALID('TRANSPORTEI') Picture AvSx3('C5_TRANSP',6) Size 40,08 pixel
@ 066,104 get cTransFin valid DP59VALID('TRANSPORTEF') Picture AvSx3('C5_TRANSP',6) Size 40,08 pixel 
If Upper(U_DipUsr()) $ "MCANUTO/VZAVATTI/LSANTOS/LMARTINS/ESOUZA/DDOMINGOS/VQUEIROZ/VEGON/RBORGES"
	@ 088,044 checkbox oChkExcel var lExcel PROMPT "Gerar Excel?" size 060,008 of oDlg 
Endif

@ 004,150 to 080,222 pixel
@ 006,154 say 'Classificar por:' pixel                    
@ 016,154 checkbox aObj[1] var alCheck[1] PROMPT aOrderBy[1,1] size 060,008 of oDlg on change DP59SeleRel(1,aObj,alCheck)
@ 026,154 checkbox aObj[2] var alCheck[2] PROMPT aOrderBy[2,1] size 060,008 of oDlg on change DP59SeleRel(2,aObj,alCheck)
@ 036,154 checkbox aObj[3] var alCheck[3] PROMPT aOrderBy[3,1] size 060,008 of oDlg on change DP59SeleRel(3,aObj,alCheck)
@ 046,154 checkbox aObj[4] var alCheck[4] PROMPT aOrderBy[4,1] size 060,008 of oDlg on change DP59SeleRel(4,aObj,alCheck)
@ 056,154 checkbox aObj[5] var alCheck[5] PROMPT aOrderBy[5,1] size 060,008 of oDlg on change DP59SeleRel(5,aObj,alCheck)
@ 066,154 checkbox aObj[6] var alCheck[6] PROMPT aOrderBy[6,1] size 060,008 of oDlg on change DP59SeleRel(6,aObj,alCheck)
                                                           
Define sbutton oBt1 from 088,145 type 1 action Eval(bOK) enable of oDlg
Define sbutton oBt2 from 088,185 type 2 action (nOpcao := 0, oDlg:End()) enable of oDlg

Activate Dialog oDlg Centered

If nOpcao = 0                                          
	Return(.t.)
EndIf

SX1->(DipPergDiverg(.f.))
aDados[02]:=OemTOAnsi('Relação de Pre-notas - Classificado por '+aOrderBy[nRadio,1],72)
aDados[07]:=''
aDados[08]:=''
If !empty(dDtIni)
	aDados[07]+= 'Data Inicial['+dtoc(dDtIni)+']  '
	aDados[08]+= 'Data Final['+dtoc(dDtFin)+']    '
EndIf
If !empty(cHoraIni).and.alltrim(cHoraIni)<>':'
	aDados[07]+= 'Hora Inicial['+cHoraIni+']  '
	aDados[08]+= 'Hora Final['+cHoraFin+']    '
EndIf
If !empty(cOperIni)
	aDados[07]+= 'Operador Inicial['+cOperIni+']  '
	aDados[08]+= 'Operador Final['+cOperFin+']    '
EndIf
If !empty(cTransIni)
	aDados[07]+= 'Transporte Inicial['+cTransIni+']  '
	aDados[08]+= 'Transporte Final['+cTransFin+']    '
EndIf
aRCampos:={}
aAdd(aRCampos,{'C5_NUM'    ,'','Pedido',AvSx3('C5_NUM' ,6)})
aAdd(aRCampos,{'C5_EMISSAO','','Emissao',AvSx3('C5_EMISSAO',6)})
aAdd(aRCampos,{'C5_PRENOTA','','Pre.',AvSx3('C5_PRENOTA',6)})
aAdd(aRCampos,{'C5_DT_PRE' ,'','Dt Imp Pre',AvSx3('C5_DT_PRE',6)})
aAdd(aRCampos,{'C5_HR_PRE' ,'','Hr Imp',AvSx3('C5_HR_PRE',6)})
//aAdd(aRCampos,{'C5_OPERADO','','Operad.',AvSx3('C5_OPERADO',6)})
aAdd(aRCampos,{'U7_NREDUZ' ,'','Operador',AvSx3('U7_NREDUZ',6)})
aAdd(aRCampos,{'C5_TRANSP' ,'','Transp.',AvSx3('C5_TRANSP',6)})
aAdd(aRCampos,{'A4_NREDUZ' ,'','Nome',AvSx3('A4_NREDUZ',6)}) 
aAdd(aRCampos,{'DTLIB' ,'','Dt Lib',AvSx3('Z9_DATAMOV',6)})
aAdd(aRCampos,{'HRLIB' ,'','Hr Lib',AvSx3('Z9_HORAMOV',6)})
aAdd(aRCampos,{'DTLIBCRED' ,'','Dt Li Cre',AvSx3('Z9_DATAMOV',6)})
aAdd(aRCampos,{'HRLIBCRED' ,'','Hr Li',AvSx3('Z9_HORAMOV',6)}) 
aAdd(aRCampos,{'DTGERANF'  ,'','Dt Gera Nf',AvSx3('Z9_DATAMOV',6)})
aAdd(aRCampos,{'HRGERANF'  ,'','Hr Gera',AvSx3('Z9_HORAMOV',6)})
aAdd(aRCampos,{'DTIMPRNF'  ,'','Dt Impr Nf',AvSx3('Z9_DATAMOV',6)})
aAdd(aRCampos,{'HRIMPRNF'  ,'','Hr Impr',AvSx3('Z9_HORAMOV',6)})
aAdd(aRCampos,{'C5_MUNE'  ,'','Municipio',AvSx3('C5_MUNE',6)})
aAdd(aRCampos,{'C5_ESTE'  ,'','Est.',AvSx3('C5_ESTE',6)})
aAdd(aRCampos,{'C5_BAIRROE' ,'','Bairro',AvSx3('C5_BAIRROE',6)})//Giovani Zago 02/02/2012
aAdd(aRCampos,{'C5_XTIPPRE' ,'','Tp.Ped.',AvSx3('C5_XTIPPRE',6)})

aRCampos:=E_CriaRCampos(aRCampos,"E")

Processa({|| lQrySC5:=DIPR59SC5FilQuery()},"Filtrando Vendas...",,.t.)

If empty(cOperIni).and.(!empty(dDtIni).or.(!empty(cHoraIni).and.alltrim(cHoraIni)<>':').or.!empty(cTransIni))
	Processa({|| lQrySF1:=DIPR59SF1FilQuery()},"Filtrando Entradas...",,.t.)
Else
    lQrySF1:= .f.	
EndIf

If !lQrySC5 .and. !lQrySF1
	MsgInfo(;
	'Não encontrado dados que satisfaçam aos'+ENTER+;
	'parametros informados pelo usuario!',"Atenção")
	If empty(cOperIni).and.(!empty(dDtIni).or.(!empty(cHoraIni).and.alltrim(cHoraIni)<>':').or.!empty(cTransIni))
		QRY1->(dbCloseArea())
	EndIf
	QRY2->(dbCloseArea())
	Return(.t.)
EndIf
Processa({|| DIPR59GRVTRB(lQrySC5,lQrySF1)},"Classificando as informações",,.t.)
TRB->(E_Report(aDados,aRCampos))

//-- Gera Arquivo Excell
If lExcel

	DbSelectArea("TRB")
	TRB->(dbGotop())
	ProcRegua(TRB->(RECCOUNT()))	
	aCols := Array(TRB->(RECCOUNT()),Len(aStru))
	nColuna := 0
	nLinha := 0
	While TRB->(!Eof())
		nLinha++
		IncProc(OemToAnsi("Gerando planilha excel..."))
		For nColuna := 1 to Len(aStru)
			aCols[nLinha][nColuna] := &("TRB->("+aStru[nColuna][1]+")")			
		Next nColuna
		TRB->(dbSkip())	
	EndDo
	u_GDToExcel(aStru,aCols,Alltrim(FunName()))

	DbSelectArea("TRB")
	COPY TO &cArqExcell VIA "DBFCDX"
	MakeDir(cDestino) // CRIA DIRETÓRIO CASO NÃO EXISTA
	CpyS2T(cArqExcell+".dbf",cDestino,.T.) // COPIA ARQUIVO PARA MAQUINA DO USUÁRIO
EndIf

TRB->(E_EraseArq(cArqWork))
If Empty(cOperIni).and.(!empty(dDtIni).or.(!empty(cHoraIni).and.alltrim(cHoraIni)<>':').or.!empty(cTransIni))
	QRY1->(dbCloseArea())
EndIf
QRY2->(dbCloseArea())
Return
*----------------------------------*
STATIC FUNCTION DIPR59SF1FilQuery()
*----------------------------------*
Local _x
ProcRegua(500)
For _x := 1 to 250                
	IncProc( "Selecionando Pedidos...")
Next
Query := "SELECT " 
Query += " F1_DOC," 
Query += " F1_SERIE,"
Query += " SUBSTRING(F1_EMISSAO,7,2)+'/'+SUBSTRING(F1_EMISSAO,5,2)+'/'+SUBSTRING(F1_EMISSAO,1,4) F1_EMISSAO, "
Query += " SUBSTRING(F1_DTDIGIT,7,2)+'/'+SUBSTRING(F1_DTDIGIT,5,2)+'/'+SUBSTRING(F1_DTDIGIT,1,4) F1_DTDIGIT, "
Query += " F1_HORA,"
Query += " F1_USUARIO,"
Query += " F1_TRANSP,"
Query += " A4_NREDUZ"
Query += " FROM  "+RetSQLName('SF1')+", "+RetSQLName('SA4')
Query += " WHERE "+RetSQLName("SF1")+".D_E_L_E_T_ <> '*'"
Query += "   AND "+RetSQLName("SA4")+".D_E_L_E_T_ <> '*'"
Query += "   AND F1_FILIAL = '" + xFilial('SF1') + "'"
Query += "   AND F1_FORMUL ='S'"
Query += "   AND F1_HORA = ''"
Query += "   AND F1_TRANSP = A4_COD"
Query += "   AND A4_FILIAL = '" + xFilial('SA4') + "'"
If !empty(dDtIni)
	Query += " AND F1_DTDIGIT  BETWEEN '"+dTos(dDtIni)+"' AND '"+dTos(dDtFin)+"'"
EndIf
If !empty(cHoraIni).and.alltrim(cHoraIni)<>':'
	Query += " AND LEFT(F1_HORA,6) BETWEEN '"+Left(cHoraIni,5)+"' AND '"+Left(cHoraFin,5)+"'"
EndIf
If !empty(cTransIni)
	Query += " AND F1_TRANSP BETWEEN '"+cTransIni+"' AND '"+cTransFin+"'"
EndIf
//Query += " ORDER BY " + aOrderBy[nRadio,3]

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

TcQuery Query NEW ALIAS "QRY1" 

ProcRegua(15000)
For _x := 1 to 5000
	IncProc( "Classificando Entradas...")
Next
Return(!QRY1->(BOF().and.EOF()))

*----------------------------------*
STATIC FUNCTION DIPR59SC5FilQuery()
*----------------------------------*
Local _x
ProcRegua(500)
For _x := 1 to 250                
	IncProc( "Selecionando Pedidos...")
Next
Query := "SELECT " 
Query += " C5_NUM, "
Query += " SUBSTRING(C5_EMISSAO,7,2)+'/'+SUBSTRING(C5_EMISSAO,5,2)+'/'+SUBSTRING(C5_EMISSAO,1,4) C5_EMISSAO, "
Query += " C5_PRENOTA, "
Query += " SUBSTRING(C5_DT_PRE,7,2)+'/'+SUBSTRING(C5_DT_PRE,5,2)+'/'+SUBSTRING(C5_DT_PRE,1,4) C5_DT_PRE, "
Query += " C5_HR_PRE, "
Query += " C5_OPERADO, "
Query += " U7_NREDUZ, "
Query += " C5_TRANSP, "
Query += " A4_NREDUZ, " 
Query += " rtrim(ltrim(C5_BAIRROE))AS 'C5_BAIRROE', " //Giovani Zago 02/02/2012
Query += " rtrim(ltrim(C5_MUNE)) AS 'C5_MUNE', " //MCVN - 05/11/2009 Incluindo Município de entrega //Giovani Zago 02/02/2012
Query += " rtrim(ltrim(C5_ESTE)) AS 'C5_ESTE', " //MCVN - 05/11/2009 Incluindo Estado de entrega //Giovani Zago 02/02/2012
Query += " C5_XTIPPRE "
Query += " FROM  "+RetSQLName('SC5')+", "+RetSQLName('SA4')+", "+RetSQLName('SU7')
Query += " WHERE "+RetSQLName("SC5")+".D_E_L_E_T_ <> '*'"
Query += "   AND "+RetSQLName("SA4")+".D_E_L_E_T_ <> '*'"
Query += "   AND "+RetSQLName("SU7")+".D_E_L_E_T_ <> '*'"
Query += "   AND C5_FILIAL = '" + xFilial('SC5') + "'"
Query += "   AND A4_FILIAL = '" + xFilial('SA4') + "'"
Query += "   AND U7_FILIAL = '" + xFilial('SU7') + "'"
If !empty(cPedidoIni)
	Query += " AND C5_NUM BETWEEN '"+cPedidoIni+"' AND '"+cPedidoFin+"'"
EndIf
If !empty(dDtIni)
	Query += " AND C5_DT_PRE BETWEEN '"+dTos(dDtIni)+"' AND '"+dTos(dDtFin)+"'"
EndIf
If !empty(cHoraIni).and.alltrim(cHoraIni)<>':'
	Query += " AND LEFT(C5_HR_PRE,5) BETWEEN '"+Left(cHoraIni,5)+"' AND '"+Left(cHoraFin,5)+"'"
EndIf
If !empty(cOperIni)
	Query += " AND C5_OPERADO BETWEEN '"+cOperIni+"' AND '"+cOperFin+"'"
EndIf
If !empty(cTransIni)
	Query += " AND C5_TRANSP BETWEEN '"+cTransIni+"' AND '"+cTransFin+"'"
EndIf
If !empty(cEsteIni)
	Query += " AND C5_ESTE BETWEEN '"+cEsteIni+"' AND '"+cEsteFin+"'"
EndIf
Query += " AND C5_OPERADO = U7_COD"
Query += " AND C5_TRANSP = A4_COD"
Query += " ORDER BY " + aOrderBy[nRadio,2]

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

TcQuery Query NEW ALIAS "QRY2" 

ProcRegua(15000)
For _x := 1 to 5000
	IncProc( "Classificando Pedidos... ")
Next
Return(!QRY2->(BOF().and.EOF()))
*--------------------------------------------*
STATIC FUNCTION DIPR59GRVTRB(lQrySC5,lQrySF1)
*--------------------------------------------*
Local nCount:=200
Local nQ
Local i
Local nProd := 1
Local cCodPro := ""  
Private cNumPedi
DIPR59CriaTRB() // Cria o arquivo temporario
If lQrySF1
    QRY1->(dbGotop())
    Procregua(nCount)
    Do While QRY1->(!EOF()) 
	    IncProc("Gravando arquivo temporario " + AllTrim(QRY1->F1_DOC)+ "...")
	    nCount--
	    If nCount<0
		    nCount:= 200
		    Procregua(nCount)
	    EndIf
	    TRB->(RecLock("TRB",.T.))
	    TRB->C5_NUM:=QRY1->F1_DOC
	    TRB->C5_EMISSAO:=cTod(QRY1->F1_EMISSAO)
	    TRB->C5_PRENOTA:='E'
	    TRB->C5_DT_PRE:=cTod(QRY1->F1_DTDIGIT)
	    TRB->C5_HR_PRE:=QRY1->F1_HORA
	    TRB->C5_OPERADO:=QRY1->F1_USUARIO
	    TRB->U7_NREDUZ:=QRY1->F1_USUARIO
	    TRB->C5_TRANSP:=QRY1->F1_TRANSP
	    TRB->A4_NREDUZ:=QRY1->A4_NREDUZ
	    aTotais[1]++
	    QRY1->(dbSkip())
    EndDo
EndIf
If lQrySC5
    QRY2->(dbGotop())
    Procregua(nCount)
    Do While QRY2->(!EOF())
	    IncProc("Gravando arquivo temporario " + AllTrim(QRY2->C5_NUM)+ "...")
	    cNumPedi := QRY2->C5_NUM
	    nCount--
	    If nCount<0
		    nCount:= 200
		    Procregua(nCount)
	    EndIf  
	    // Buscando informações no Kardex
	    DIPR059sz9() // MCVN 05/03/07
	    TRB->(RecLock("TRB",.T.))
	    TRB->C5_NUM		:= QRY2->C5_NUM
	    TRB->C5_EMISSAO	:= cTod(QRY2->C5_EMISSAO)
	    TRB->C5_PRENOTA	:= QRY2->C5_PRENOTA
	    TRB->C5_DT_PRE	:= cTod(QRY2->C5_DT_PRE)
	    TRB->C5_HR_PRE	:= QRY2->C5_HR_PRE
	    TRB->C5_OPERADO	:= QRY2->C5_OPERADO
	    TRB->U7_NREDUZ	:= QRY2->U7_NREDUZ
	    TRB->C5_TRANSP	:= QRY2->C5_TRANSP
	    TRB->A4_NREDUZ	:= QRY2->A4_NREDUZ	    
	    TRB->DTLIB 		:= cTod(dDtLib)
   	    TRB->HRLIB 		:= cHrLib
   	    TRB->DTLIBCRED 	:= cTod(dDtLibCred)
   	    TRB->HRLIBCRED 	:= cHrLibCred     
   	    TRB->DTGERANF  	:= cTod(dDtGeraNf)
   	    TRB->HRGERANF 	:= cHrGeraNf
   	    TRB->DTIMPRNF 	:= cTod(dDtImprNf)
   	    TRB->HRIMPRNF 	:= cHrImprNf
	    TRB->C5_MUNE	:= QRY2->C5_MUNE
	    TRB->C5_ESTE	:= QRY2->C5_ESTE
	    TRB->C5_BAIRROE	:= QRY2->C5_BAIRROE
	    TRB->C5_XTIPPRE := QRY2->C5_XTIPPRE
	    aTotais[2]++
	    QRY2->(dbSkip())
    EndDo
EndIf
*----------------------------------*
Static Function DIPR59CriaTRB()
*----------------------------------*
cArqWork:=E_CriaTrab(,aStru,"TRB")
If nRadio=2
    Indregua('TRB',cArqWork,'DTOS(C5_DT_PRE)+C5_HR_PRE',,,'Criando indices Temporarios')
Else
	Indregua('TRB',cArqWork,aOrderBy[nRadio][2],,,'Criando indices Temporarios')
EndIf
RETURN(.t.)  


*---------------------------------------*
Static Function DipPergDiverg(lLer)
// Registra alterações no SX1
*---------------------------------------*
Local aRegs:={}
Local lIncluir
Local i,j
SX1->(dbSetOrder(1))

aAdd(aRegs,{cPerg,"01","Pedido de         ?","","","MV_CH1","C",006,0,0,"G","","MV_PAR01","","","", cPedidoIni          ,"","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"02","Até               ?","","","MV_CH2","C",006,0,0,"G","","MV_PAR02","","","", cPedidoFin          ,"","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"03","Data de           ?","","","MV_CH3","D",008,0,0,"G","","MV_PAR03","","","", "'"+dToc(dDtIni)+"'","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"04","Até               ?","","","MV_CH4","D",008,0,0,"G","","MV_PAR04","","","", "'"+dToc(dDtFin)+"'","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"05","Hora de           ?","","","MV_CH5","C",008,0,0,"G","","MV_PAR05","","","", cHoraIni            ,"","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"06","Até               ?","","","MV_CH6","C",008,0,0,"G","","MV_PAR06","","","", cHoraFin            ,"","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"07","Operador de       ?","","","MV_CH7","C",006,0,0,"G","","MV_PAR07","","","", cOperIni            ,"","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"08","Até               ?","","","MV_CH8","C",006,0,0,"G","","MV_PAR08","","","", cOperFin            ,"","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"09","Transportadorta de?","","","MV_CH9","C",006,0,0,"G","","MV_PAR09","","","", cTransIni           ,"","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"10","Até               ?","","","MV_CHA","C",006,0,0,"G","","MV_PAR10","","","", cTransFin           ,"","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"11","Estado de         ?","","","MV_CHB","C",002,0,0,"G","","MV_PAR11","","","", cEsteIni           ,"","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"12","Até               ?","","","MV_CHC","C",002,0,0,"G","","MV_PAR12","","","", cEsteFin           ,"","","","","","","","","","",""})
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
cPedidoIni:=Left(aRegs[01,17],AvSx3('C5_NUM',3))
cPedidoFin:=Left(aRegs[02,17],AvSx3('C5_NUM',3))
dDtIni:=cTod(StrTran(aRegs[03,17],"'",""))
dDtFin:=cTod(StrTran(aRegs[04,17],"'",""))
cHoraIni:=Left(aRegs[05,17],AvSx3('C5_HR_PRE',3))
cHoraFin:=Left(aRegs[06,17],AvSx3('C5_HR_PRE',3))            
cOperIni:=Left(aRegs[07,17],AvSx3('C5_OPERADO',3))            
cOperFin:=Left(aRegs[08,17],AvSx3('C5_OPERADO',3))            
cTransIni:=Left(aRegs[09,17],AvSx3('C5_TRANSP',3))           
cTransFin:=Left(aRegs[10,17],AvSx3('C5_TRANSP',3))           
cEsteIni:=Left(aRegs[11,17],AvSx3('C5_ESTE',3))           
cEsteFin:=Left(aRegs[12,17],AvSx3('C5_ESTE',3)) 

Return(.t.)
*---------------------------------*
Static Function DP59OKVALID()
*---------------------------------*
Local lRetorno:=.t.
Do Case
	Case !DP59VALID('PEDIDOI');lRetorno:=.f.
	Case !DP59VALID('PEDIDOF');lRetorno:=.f.
	Case !DP59VALID('DATAI');lRetorno:=.f.
	Case !DP59VALID('DATAF');lRetorno:=.f.
	Case !DP59VALID('HORAI');lRetorno:=.f.
	Case !DP59VALID('HORAF');lRetorno:=.f.
	Case !DP59VALID('OPERADORI');lRetorno:=.f.
	Case !DP59VALID('OPERADORF');lRetorno:=.f.
	Case !DP59VALID('TRANSPORTEI');lRetorno:=.f.
	Case !DP59VALID('TRANSPORTEF');lRetorno:=.f.
	Case !DP59VALID('ESTEI');lRetorno:=.f.
	Case !DP59VALID('ESTEF');lRetorno:=.f.
EndCase
Return(lRetorno)
*---------------------------------*
Static Function DP59VALID(cCampo)
*---------------------------------*
Local lRetorno:=.t.
Local nHora
Local nMinu
Do Case
	Case cCampo=='PEDIDOI'
		If !empty(cPedidoIni).AND.!SC5->(dbSeek(xFilial('SC5')+cPedidoIni))
			msgInfo('Pedido informado não cadastrado!','Atenção')
			lRetorno:=.f.
		EndIf
	Case cCampo=='PEDIDOF'
		If !empty(cPedidoIni)
			If !empty(cPedidoFin)
				If !SC5->(dbSeek(xFilial('SC5')+cPedidoFin))
					msgInfo('Pedido informado não cadastrado!','Atenção')
					lRetorno:=.f.
				EndIf
			Else
				msgInfo('Se informar pedido inicial terá que informar pedido final"','Atenção')
				lRetorno:=.f.
			EndIf
		ElseIf !empty(cPedidoFin)
			msgInfo('Se informar pedido final terá que informar pedido inicial"','Atenção')
			lRetorno:=.f.
		EndIf
	Case cCampo=='DATAI'
		If !Empty(dDtIni)
			If dDtIni<ctod('01/01/1950')
				msgInfo('Data inicail invalida!','Atenção')
				lRetorno:=.f.
			EndIf
		EndIf
	Case cCampo=='DATAF'
		If !Empty(dDtIni)
			If !Empty(dDtFin)
				If dDtFin>ctod('31/12/2099')
					msgInfo('Data final invalida!','Atenção')
					lRetorno:=.f.
				EndIf
			Else
				msgInfo('Se informar data inicial terá que informar data final"','Atenção')
				lRetorno:=.f.
			EndIf
		ElseIf !Empty(dDtFin)
			msgInfo('Se informar data inicial terá que informar data final"','Atenção')
			lRetorno:=.f.
		EndIf
	Case cCampo=='HORAI'
		If !Empty(cHoraIni)
			nHora:=Val(SubStr(cHoraIni,1,2))
			nMinu:=Val(SubStr(cHoraIni,4,2))
			If nHora>23.or.nMinu>59.or.nHora<0.or.nMinu<0
				msgInfo('Hora inicail invalida!','Atenção')
				lRetorno:=.f.
			EndIf
		EndIf
	Case cCampo=='HORAF'
		If !Empty(cHoraIni)
			If !Empty(cHoraFin)
				nHora:=Val(SubStr(cHoraFin,1,2))
				nMinu:=Val(SubStr(cHoraFin,4,2))
				If nHora>23.or.nMinu>59.or.nHora<0.or.nMinu<0
					msgInfo('Hora final invalida!','Atenção')
					lRetorno:=.f.
				EndIf
			Else
				msgInfo('Se informar hora inicial terá que informar hora final"','Atenção')
				lRetorno:=.f.
			EndIf
		ElseIf !Empty(cHoraFin)
			msgInfo('Se informar hora inicial terá que informar hora final"','Atenção')
			lRetorno:=.f.
		EndIf
		
	Case cCampo=='OPERADORI'
		If !empty(cOperIni).AND.!SU7->(dbSeek(xFilial('SU7')+cOperIni))
			msgInfo('Operador informado não cadastrado!','Atenção')
			lRetorno:=.f.
		EndIf
	Case cCampo=='OPERADORF'
		If !empty(cOperIni)
			If !empty(cOperFin)
				If !SU7->(dbSeek(xFilial('SU7')+cOperFin))
					msgInfo('Operador informado não cadastrado!','Atenção')
					lRetorno:=.f.
				EndIf
			Else
				msgInfo('Se informar operador inicial terá que informar operador final"','Atenção')
				lRetorno:=.f.
			EndIf
		ElseIf !empty(cOperFin)
			msgInfo('Se informar operador final terá que informar operador inicial"','Atenção')
			lRetorno:=.f.
		EndIf
	Case cCampo=='TRANSPORTEI'
		If !empty(cTransIni).AND.!SA4->(dbSeek(xFilial('SA4')+cTransIni))
			msgInfo('Transportadora informada não cadastradoa','Atenção')
			lRetorno:=.f.
		EndIf
	Case cCampo=='TRANSPORTEF'
		If !empty(cTransIni)
			If !empty(cTransFin)
				If !SA4->(dbSeek(xFilial('SA4')+cTransFin))
					msgInfo('Transportadora informada não cadastrada!','Atenção')
					lRetorno:=.f.
				EndIf
			Else
				msgInfo('Se informar transportadora inicial terá que informar transportadora final"','Atenção')
				lRetorno:=.f.
			EndIf
		ElseIf !empty(cTransFin)
			msgInfo('Se informar Transportadora final terá que informar Transportadora inicial"','Atenção')
			lRetorno:=.f.
		EndIf          
	Case cCampo=='ESTEI' 		
		If !empty(cEsteIni).AND.!SX5->(dbSeek(xFilial('SX5')+"12"+cEsteIni))
			msgInfo('Estado inválido','Atenção')
			lRetorno:=.f.
		EndIf
	Case cCampo=='ESTEF' 
		If !empty(cEsteIni)
			If !empty(cEsteFin)
				If !SX5->(dbSeek(xFilial('SX5')+"12"+cEsteFin))
			  		msgInfo('Estado inválido','Atenção')
					lRetorno:=.f.
				EndIf
			Else
				msgInfo('Se informar estado inicial terá que informar estado final"','Atenção')
				lRetorno:=.f.
			EndIf
		ElseIf !empty(cEsteFin)
			msgInfo('Se informar Estado final terá que informar Estado inicial"','Atenção')
			lRetorno:=.f.
		EndIf
                                  
EndCase
Return(lRetorno)
*-----------------------------------------------------*
Static function DP59SeleRel(nCheck,aObj,alCheck)
*-----------------------------------------------------* 
Local i
For i:=1 to 6
    If nCheck <> i .and. alCheck[nCheck]
        alCheck[i]:= .f.
        aObj[i]:Refresh()
    EndIf
Next  
If alCheck[nCheck]
	nRadio:=nCheck
ElseIf nRadio=nCheck
	nRadio:=1
EndIf
alCheck[nRadio]:=.t.
aObj[nRadio]:Refresh()
//oBt1:SetFocus()
RETURN(.T.)
*-------------------------------*
Static Function DIPR059Quebra()
*-------------------------------*
RETURN(.T.)
*-------------------------------*
Static Function Dipr059Final()
*-------------------------------*
If TRB->(EOF())
	linha+=5
    If linha>51 
	   Roda(0,Space(10),"M")
	   linha := 56
	   DIPR059Cabec()
	   linha+=5
	EndIf
	@ linha  , 010 psay "Resumo:"
	@ ++linha, 015 psay "- Total de Pedidos:"
	@ linha  , 040 psay aTotais[2] picture "@E 999,999"
	If aTotais[1] > 0
	    @ ++linha, 015 psay "- Total NF Entradas:"
	    @ linha  , 040 psay aTotais[1] picture "@E 999,999"
	EndIf    
	++linha                   
	@ linha  , 010 psay "Status:"
	@ ++linha, 015 psay "Se a coluna prenota for = S - PRENOTA IMPRESSA CORRETAMENTE."
	@ ++linha, 015 psay "Se a coluna prenota for = P - PEDIDO COM PROBLEMA(COMUNICAR O DEPARTAMENTO DE TI)."
	@ ++linha, 015 psay "Se a coluna prenota for =   - NOTA FISCAL GERADA."
	linha++
	@ ++linha, 015 psay "Se a coluna Tp.Ped. for =  T   - PRENOTA SEPARADA SOMENTE NO TERREO."
	@ ++linha, 015 psay "Se a coluna Tp.Ped. for =  M   - PRENOTA SEPARADA SOMENTE NO MEZANINO."
	@ ++linha, 015 psay "Se a coluna Tp.Ped. for = T/M  - PRENOTA SEPARADA COM PRODUTOS DO TERREO E MEZANINO."
EndIf	   
RETURN(.T.)
*-------------------------------*
Static Function DIPR059Cabec()
*-------------------------------*
local b_lin :={|valor,ind| F_Ler_Tab(R_Campos,ind)}
Local tamanho :="M"
Local nAsterisco:=132

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




//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Função para buscar no Kardex do pedido informações referentes liberação do pedido e liberação de crédito do pedido.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*-------------------------------*
Static Function DIPR059sz9()  // MCVN 05/03/07
*-------------------------------*
Local _x
Local nCount:=200


Query := "SELECT " 
Query += " Z9_PEDIDO, "
//Query += " SUBSTRING(Z9_DATAMOV,7,2)+'/'+SUBSTRING(Z9_DATAMOV,5,2)+'/'+SUBSTRING(Z9_DATAMOV,1,4) Z9_DATAMOV, "
Query += " Z9_DATAMOV, "
Query += " Z9_HORAMOV, "
Query += " Z9_OCORREN "
Query += " FROM  "+RetSQLName('SZ9')
Query += " WHERE "+RetSQLName("SZ9")+".D_E_L_E_T_ <> '*'"
Query += " AND Z9_FILIAL = '" + xFilial('SZ9') + "'"
Query += " AND Z9_PEDIDO = '"+ cNumPedi + "'"  
Query += " AND Z9_OCORREN IN ('10','16','26','17','58')"

Query += " ORDER BY Z9_DATAMOV, Z9_HORAMOV, Z9_PEDIDO,Z9_OCORREN

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

TcQuery Query NEW ALIAS "QRY3" 
QRY3->(dbGotop())

    dDtLib     := ""
    cHrLib     := ""
    dDtLibCred := ""
    cHrLibCred := ""
    dDtGeraNf  := ""
    cHrGeraNf  := ""
    dDtImprNf  := ""
    cHrImprNf  := ""          
    
    Do While QRY3->(!EOF()) 
	    
		If QRY3->Z9_OCORREN = "10" .OR. QRY3->Z9_OCORREN = "16"
            dDtLib := SUBSTRING(QRY3->Z9_DATAMOV,7,2)+'/'+SUBSTRING(QRY3->Z9_DATAMOV,5,2)+'/'+SUBSTRING(QRY3->Z9_DATAMOV,1,4) 
      		cHrLib := Left(QRY3->Z9_HORAMOV,5)
		EndIf	

		If QRY3->Z9_OCORREN = "26"
			dDtLibCred := SUBSTRING(QRY3->Z9_DATAMOV,7,2)+'/'+SUBSTRING(QRY3->Z9_DATAMOV,5,2)+'/'+SUBSTRING(QRY3->Z9_DATAMOV,1,4) 
			cHrLibCred := Left(QRY3->Z9_HORAMOV,5)
		EndIf	       
		
		If QRY3->Z9_OCORREN = "17"
			dDtGeraNf := SUBSTRING(QRY3->Z9_DATAMOV,7,2)+'/'+SUBSTRING(QRY3->Z9_DATAMOV,5,2)+'/'+SUBSTRING(QRY3->Z9_DATAMOV,1,4) 
			cHrGeraNf := Left(QRY3->Z9_HORAMOV,5)
		EndIf	       
		
		If QRY3->Z9_OCORREN = "58"
			dDtImprNf := SUBSTRING(QRY3->Z9_DATAMOV,7,2)+'/'+SUBSTRING(QRY3->Z9_DATAMOV,5,2)+'/'+SUBSTRING(QRY3->Z9_DATAMOV,1,4) 
			cHrImprNf := Left(QRY3->Z9_HORAMOV,5)
		EndIf	       


		
		
        QRY3->(dbSkip())
    Enddo

  If dDtLibCred = "" .OR. dDtLibCred = NiL
  	   dDtLibCred := dDtLib
	   cHrLibCred := cHrLib
  EndIf

  dbSelectArea("QRY3")
  QRY3->(dbCloseArea())

RETURN(.T.)

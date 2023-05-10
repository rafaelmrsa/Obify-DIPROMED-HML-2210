/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³DIPRL50() ³ Autor ³Jailton B Santos-JBS   ³ Data ³04/06/2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Este programa emite   um relatorio  pelo Word, chamado  de ³±±
±±³          ³ atestado tecnico. O usuario informa o codigo de ate 10 pro-³±±
±±³          ³ dutos, o sistema busca as vendas dentro do perido, informan³±±
±±³          ³ do os numeros de notas e quantidade de cada produto entre- ³±±
±±³          ³ gue para o clinte, dentro do periodo informado.            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Especifico Faturamento Dipromed.                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³  Motivo da Alteracao                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³        ³                                                 ³±±
±±³            ³        ³                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
#INCLUDE "TOPCONN.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "MSOLE.CH"
#INCLUDE "APWEBSRV.CH"
#include "tbiconn.ch"

User Function DIPRL50()
Local lRet := .F.

Private cNotas   := ''
Private aProdutos:= {}
Private cPerg    := Padr('DIPRL50',10)

fAjustSX1()

Begin Sequence

If !Pergunte(cPerg, .T.)
	Break
EndIf

If Empty(Alltrim(MV_PAR01)) .And. Empty(Alltrim(MV_PAR02)) 
	Aviso("Erro no preenchimento dos parâmetros!","Voce precisa preencher Cliente e a Loja",{"Ok"})
	Return(.F.)
ElseIf Empty(Alltrim(MV_PAR05)) .And. Empty(Alltrim(MV_PAR06)) .And. Empty(Alltrim(MV_PAR07))
	Aviso("Erro no preenchimento dos parâmetros!","Voce precisa preencher Nota Fiscal e a Série ou ao menos um produto. Todos estes paramêtros estão em branco",{"Ok"})
	Return(.F.)
Endif

Processa({|| lRet := fQuery()})

If lRet
	Processa({|| lRet := fAtestTec()})
EndIf

If Select('TRB')> 0
	TRB->( DbCloseArea() )
EndIf

End Sequence

Return(NIL)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ fQuery() º Autor ³Jailton B Santos-JBSº Data ³ 04/06/2010  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Esta funcao ira os produtos e respectivas notas fiscais    º±±
±±º          ³ dentro do periodo informado, de notas para um determinado  º±±
±±º          ³ cliente.                                                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Especifico Faturamento Dipromed                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function fQuery()

Local cQuery    := ""
Local lRet      := .T.
Local cProdutos := ""
Local cParametro:= ""
Local cVirgula  := ""

For x := 7 to 16
	cParametro := 'MV_PAR'+StrZero(x,2)
	If !Empty(&cParametro)
		cProdutos += cVirgula +"'"+&(cParametro)+"'"
		cVirgula := ','
	EndIf
Next x

cVirgula:= ""

cQuery := " Select F2_DOC,F2_SERIE,F2_CLIENTE,F2_LOJA,D2_COD,D2_QUANT, B1_UM, B1_DESC, F2_EMISSAO "
cQuery += "   From " + RetSqlName('SF2') + " SF2 "

cQuery += "  Inner Join " + RetSqlName('SD2') + " SD2 on D2_FILIAL = F2_FILIAL  "
cQuery += "                       and D2_DOC = F2_DOC "
cQuery += "                       and D2_SERIE = F2_SERIE "
If !empty(cProdutos).and. Empty(MV_PAR05) //.and. Empty(MV_PAR06)
	cQuery += "                       and D2_COD IN ("+cProdutos+") "
EndIf
cQuery += "                       and SD2.D_E_L_E_T_ = '' "

cQuery += "  Inner Join " + RetSqlName('SB1')+" SB1 on B1_FILIAL = '"+xFilial('SB1')+"' "
cQuery += "                       and B1_COD = D2_COD "
cQuery += "                       and SB1.D_E_L_E_T_ = '' "

cQuery += "  where F2_FILIAL = '" + xFilial('SF2') + "' " 

cQuery += "    and F2_EMISSAO between '"+dTos(MV_PAR03)+"' and '"+dTos(MV_PAR04)+"' "
If !Empty(MV_PAR05) //.and. MV_PAR06 >= MV_PAR05
    cQuery += "    and F2_DOC = '"+MV_PAR05+"' " //and '"+MV_PAR06+"' "  
EndIf  

If !Empty(MV_PAR06)
    cQuery += "    and F2_SERIE = '"+MV_PAR06+"' "
EndIf 

cQuery += "    and F2_CLIENTE = '"+ MV_PAR01+"' "
cQuery += "    and F2_LOJA = '"+ MV_PAR02+"'"
cQuery += "    and SF2.D_E_L_E_T_ = ''"

If Select("TRB") > 0
	TRB->( DbCloseArea() )
EndIf

TCQUERY cQuery NEW ALIAS "TRB"
memowrite('DIPRL50_' + SM0->M0_CODIGO +'0_'+SM0->M0_CODFIL+'.SQL',cQuery)       

lRet     := !TRB->( BOF().and.EOF() )
cNotas   := ''
cVirgula := ''                    

Do While lRet .and. TRB->(!EOF())
	
	If !TRB->F2_DOC $ cNotas
		cNotas += cVirgula + AllTrim(TRB->F2_DOC)
		cVirgula := ', '
	EndIf'
	If  (nPos := ascan(aProdutos,{|x| x[1] = TRB->D2_COD }))  > 0
		aProdutos[nPos][03] += TRB->D2_QUANT
	Else
		aAdd(aProdutos,{TRB->D2_COD,TRB->B1_DESC,TRB->D2_QUANT,TRB->B1_UM,TRB->F2_EMISSAO})
	EndIf
	
	TRB->(DbSkip())
	
EndDo
aAdd(aProdutos,{'','',0,'',''})
If !Empty(cNotas)
	cNotas += '.'
EndIf
Return(lRet)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³fAtestTec()ºAutor ³Microsiga           º Data ³ 04/06/2010  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Gera o atestado tecnico no word                             º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Especifico Licitacoes Dipromed                              º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function fAtestTec()

Local oWord
Local cFile		:= ""
Local nA		:= 0
Local cArqDot	:= ""
Local cCaract	:= ""
Local nCol		:= 1
Local cValid	:= ""
Local cNewFile	:= ""
Local nPos		:= 0   
Local nItens    := 10 
Local lExecMacro:= .F.

Private cPathEst:= "" //Diretorio na estacao

If !Empty(cFile) .And. At(".DOT",Upper(cFile))>0
	If !MsgYESNO("Deseja utilizar o mesmo arquivo ("+cFile+") usado anteriormente?")
		
		cTipo := "Modelo Word (*.DOT)        | *.DOT | "
		cFile := cGetFile(cTipo,"Selecione o modelo do arquivo",,,.T.,GETF_ONLYSERVER ,.T.)
		If Empty(cFile)
			Aviso("Cancelada a Selecao!","Voce cancelou a selecao do arquivo.",{"Ok"})
			Return(.F.)
		Endif
	EndIf
Else
	cTipo := "Modelo Word (*.DOT)        | *.DOT | "
	cFile := cGetFile(cTipo ,"Selecione o modelo do arquivo",,,.T.,GETF_ONLYSERVER ,.T.)
	If Empty(cFile)
		Aviso("Cancelada a Selecao!","Voce cancelou a selecao do arquivo.",{"Ok"})
		Return(.F.)
	Endif
EndIf

//------------------------------------------------------------------------------------------------
// Quando informar apenas uma nota fiscal, considera como quantidade de itens a serem impressos, 
// a Produtos.
//------------------------------------------------------------------------------------------------
//If !Empty(MV_PAR05) .and. !Empty(MV_PAR06).and. "ATESTADOTEC_NF" $ Upper(cFile)
nItens := Len(aProdutos)
lExecMacro := .T.
//EndIf     

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Criando link de comunicacao com o word                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

oWord := OLE_CreateLink('TMsOleWord')

For nA := 1  To Len(cFile)
	cCaract := SubStr(cFile,nCol,1)
	If  cCaract == "\"
		cArqDot := ""
	Else
		cArqDot += cCaract
	EndIf
	nCol := nCol + 1
Next
//cPathEst := "C:\Users\vaio\Documents\licita0001.dot"
cPathEst := "C:\WINDOWS\Temp\" // PATH DO ARQUIVO A SER ARMAZENADO NA ESTACAO DE TRABALHO
MontaDir(cPathEst)

CpyS2T(cFile,cPathEst,.T.) // Copia do Server para o Remote, eh necessario
//para que o wordview e o proprio word possam preparar o arquivo para impressao e
// ou visualizacao .... copia o DOT que esta no ROOTPATH Protheus para o PATH da
// estacao , por exemplo C:\WORDTMP

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Abre o arquivo e ajusta suas propriedades                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

OLE_NewFile(oWord, cPathEst + cArqDot)
OLE_SetProperty( oWord, oleWdVisible,   .F. )
OLE_SetProperty( oWord, oleWdPrintBack, .T. )
OLE_SetDocumentVar(oWord,"cData"      ,fData()) 

If At(',',cNotas) == 0 // lExecMacro
    OLE_SetDocumentVar(oWord,"cDtEmi" , " Informamos que o fornecimento dos produtos abaixo foi realizado no dia " + dToc(sTod(aProdutos[1][5]))+ ", através da nota fiscal nº " + cNotas)
//    OLE_SetDocumentVar(oWord,"cNroNF" , " através da nota fiscal nº " + cNotas)
Else                                                  
    OLE_SetDocumentVar(oWord,"cDtEmi" , " Informamos que o fornecimento dos produtos abaixo foram realizados no periodo de " + dToc(MV_PAR03) + " à " + dToc(MV_PAR04)+", através das notas fiscais nºs " + cNotas )
    //OLE_SetDocumentVar(oWord,"cNroNF" , " através das notas fiscais nºs " + cNotas)

    //OLE_SetDocumentVar(oWord,"cDtPerIni"	,MV_PAR03)
    //OLE_SetDocumentVar(oWord,"cDtPerFin"	,MV_PAR04)
    //OLE_SetDocumentVar(oWord,"cNotas"   	,cNotas)
EndIf

For x := 1 to nItens
	                                                                                     
	If Len(aProdutos) >= x
		OLE_SetDocumentVar(oWord,"cProd"+StrZero(x,2),aProdutos[x][2])
		OLE_SetDocumentVar(oWord,"cQtd"+StrZero(x,2),Transform(aProdutos[x][3],"@e 9,999,999,999") + '  ' +aProdutos[x][4] )
	Else
		OLE_SetDocumentVar(oWord,"cProd"+StrZero(x,2),"")
		OLE_SetDocumentVar(oWord,"cQtd"+StrZero(x,2),"")
	EndIf
	
Next x
 
OLE_SetDocumentVar(oWord, "psl_nroitens",nItens)
OLE_ExecuteMacro(oWord,"Dipromed01")

OLE_UpDateFields(oWord)

cNewFile := cGetFile(" | *.* |" , "Salvar em" ,,,.F., GETF_LOCALHARD + GETF_LOCALFLOPPY + GETF_RETDIRECTORY,.F.)

If(Len(cNewFile) < 1)
	Aviso('Atenção','Nome do arquivo Invalido')
	Return .F.
Else
	nPos := RAT("\",cNewFile)
	cPathEst := SUBSTR(cNewFile, 1, nPos)
	cNewFile := cPathEst
EndIF
                                               
If cEmpAnt+cFilAnt == "0401"
	cNewFile := cNewFile+"Atestado_Tecnico_HQ - " + Dtos(dDataBase) + StrTran(Time(),':','_')+ ".doc"
Else
	cNewFile := cNewFile+"Atestado_Tecnico_Dipromed - " + Dtos(dDataBase) + StrTran(Time(),':','_')+ ".doc"
EndIf


OLE_SaveAsFile(oWord,cNewFile,,,.F.,)  // SALVA O ARQUIVO NA ESTACAO
CpyT2S(cNewFile,"\word\",.T.)          // Copia do Remote para o Servidor
OLE_CloseLink(oWord)   

Return(.T.)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³fData()   ºAutor  ³Jailton B Santos-JBSº Data ³ 07/06/2010  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcao desenvolvida para retornar a data por extenso        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Especifico Licitacoes Dipromed                              º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/                                                                            
Static Function fData() 

Local cDia := Day(dDataBase)
Local cMes := MesExtenso(Month(dDataBase)) 
Local cAno := SubStr(dtos(ddatabase),1,4) 
Local cRet := StrZero(cDia,2) + ' de ' + cMes + ' de ' +  cAno

Return( cRet )
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³fAjustSX1()ºAutor ³Jailton B Santos-JBSº Data ³ 02/06/2010  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Esta funcao tem como objetivo criar o grupo de perguntas    º±±
±±º          ³usado pelo programa.                                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Especifico - Licitacoes - Dipromed                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function fAjustSX1()

Local nId_SX1
Local lRet  := .T.
Local aRegs	:= {}
Local aArea := GetArea()

Local oFWSX1 as object
Local aPergunte	:= {}

AAdd(aRegs,{"01","Codigo do Cliente    ","mv_ch1","C",06,0,0,"G","mv_par01",""                ,""                   ,""                    ,""                   ,"SA1"})
AAdd(aRegs,{"02","Loja do Cliente      ","mv_ch2","C",02,0,0,"G","mv_par02",""                ,""                   ,""                    ,""                   ,""})
AAdd(aRegs,{"03","Dt Emissão Inicial   ","mv_ch3","D",08,0,0,"G","mv_par03",""                ,""                   ,""                    ,""                   ,""})
AAdd(aRegs,{"04","Dt Emissão Final     ","mv_ch4","D",08,0,0,"G","mv_par04",""                ,""                   ,""                    ,""                   ,""})
AAdd(aRegs,{"05","Nota Inicial         ","mv_ch5","C",09,0,0,"G","mv_par05",""                ,""                   ,""                    ,""                   ,""})
//AAdd(aRegs,{"06","Nota Final           ","mv_ch6","C",09,0,0,"G","mv_par06",""                ,""                   ,""                    ,""                   ,""})
AAdd(aRegs,{"06","Serie                ","mv_ch6","C",03,0,0,"G","mv_par06",""                ,""                   ,""                    ,""                   ,""})
AAdd(aRegs,{"07","Produto 01           ","mv_ch8","C",06,0,0,"G","mv_par07",""                ,""                   ,""                    ,""                   ,""})
AAdd(aRegs,{"08","Produto 02           ","mv_ch9","C",06,0,0,"G","mv_par08",""                ,""                   ,""                    ,""                   ,""})
AAdd(aRegs,{"09","Produto 03           ","mv_chA","C",06,0,0,"G","mv_par09",""                ,""                   ,""                    ,""                   ,""})
AAdd(aRegs,{"10","Produto 04           ","mv_chB","C",06,0,0,"G","mv_par10",""                ,""                   ,""                    ,""                   ,""})
AAdd(aRegs,{"11","Produto 05           ","mv_chC","C",06,0,0,"G","mv_par11",""                ,""                   ,""                    ,""                   ,""})
AAdd(aRegs,{"12","Produto 06           ","mv_chD","C",06,0,0,"G","mv_par12",""                ,""                   ,""                    ,""                   ,""})
AAdd(aRegs,{"13","Produto 07           ","mv_chE","C",06,0,0,"G","mv_par13",""                ,""                   ,""                    ,""                   ,""})
AAdd(aRegs,{"14","Produto 08           ","mv_chF","C",06,0,0,"G","mv_par14",""                ,""                   ,""                    ,""                   ,""})
AAdd(aRegs,{"15","Produto 09           ","mv_chG","C",06,0,0,"G","mv_par15",""                ,""                   ,""                    ,""                   ,""})
AAdd(aRegs,{"16","Produto 10           ","mv_chH","C",06,0,0,"G","mv_par16",""                ,""                   ,""                    ,""                   ,""})

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
				MsgStop("Erro na execução da query: "+TcSqlError(), "Atenção")
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

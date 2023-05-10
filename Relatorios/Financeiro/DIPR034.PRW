/*====================================================================================\
|Programa  | DIPR034       | Autor | Eriberto Elias             | Data | 20/06/2003   |
|=====================================================================================|
|Descrição | Carta para devedores - a_deve??.dot e b_deve??.dot                       |
|          |                                                                          |
|          |                                                                          |
|=====================================================================================|
|Sintaxe   | DIPR034                                                                  |
|=====================================================================================|
|Uso       | Especifico DIPROMED                                                      |
|=====================================================================================|
|........................................Histórico....................................|
|Rafael    | DD/MM/AA - Descrição                                                     |
|Eriberto  | DD/MM/AA - Descrição                                                     |
\====================================================================================*/

#include "rwmake.ch"
User Function DIPR034()

_area    := getarea()
_areaSE1 := SE1->(getarea())
_areaSA1 := SA1->(getarea())
_areaSA3 := SA3->(getarea())

//Private cPerg := "DIPR34"
// FPADR(cPerg, cArq, cCampo, cTipo)  - Para ajustar o tamanho das perguntas no SX1- uso generico

Private cDestino  := "C:\EXCELL-DBF\"

PRIVATE cPerg  	:= U_FPADR( "DIPR34","SX1","SX1->X1_GRUPO"," " ) //Função criada por Sandro em 19/11/09.

U_DIPPROC(ProcName(0),U_DipUsr()) // JBS 05/10/2005 - Gravando o nome do Programa no SZU
// Valida Pergunta do programa

AjustaSX1(cPerg)

If Pergunte(cPerg,.T.)
	
	Processa({|| _Carta() },"Gerando cartas para devedores...")
	
	If mv_par09 == 1
		Processa({|| _Relac() },"Relacao de cartas dos devedores...")
	EndIf
	
	If mv_par10 == 1
		Processa({|| _Etiqu() },"Gerando arquivo CARTAETI.DBF use no WORD...")
	EndIf
	
	dbSelectArea("QRY1")
	QRY1->(dbCloseArea())

EndIf

RestArea(_areaSE1)
RestArea(_areaSA1)
RestArea(_areaSA3)
RestArea(_area)

Return

//Carta////////////////////////////////////////////////////////////////////
Static Function _Carta()
Local _cArqTrb
//Local cArqExcell:= GetSrvProfString("STARTPATH","")+"Excell-DBF\CartaS" // JBS 12/12/2005

// Alterado para gravar arquivos na pasta protheus_data - Por Sandro em 19/11/09. 
Local cArqExcell:= "\Excell-DBF\Cartas" 

/*
SELECT
E1_TIPO, E1_VEND1, E1_CLIENTE, E1_LOJA , E1_PREFIXO, E1_NUM, E1_PARCELA, E1_EMISSAO, E1_VENCTO, E1_VALOR, E1_SALDO, E1_BAIXA,
A1_NOME, A1_END, A1_MUN, A1_EST, A1_CEP
A3_NOME
FROM SE1010, SA1010, SA3010
WHERE
A1_FILIAL  = '01' AND
E1_FILIAL  = '01' AND
SE1010.D_E_L_E_T_ <> '*' AND
SA1010.D_E_L_E_T_ <> '*' AND
SE1010.E1_SALDO > 0 AND
SE1010.E1_TIPO   = 'NF' AND
SE1010.E1_VENCTO >= '20030601' AND
SE1010.E1_VENCTO <= '20030610' AND
SE1010.E1_CLIENTE >= '      ' AND
SE1010.E1_CLIENTE <= '999999' AND
SE1010.E1_VEND1 >= '      ' AND
SE1010.E1_VEND1 <= '999999' AND
SE1010.E1_CLIENTE = SA1010.A1_COD AND
SE1010.E1_LOJA    = SA1010.A1_LOJA

ORDER BY A1_NOME,E1_NUM,E1_PARCELA
*/

QRY1 :=        "select E1_CLIENTE, E1_LOJA, A1_NOME, E1_NUM, E1_PARCELA, E1_EMISSAO, E1_VENCTO, E1_VALOR, E1_SALDO, A1_END, A1_BAIRRO, A1_MUN, A1_EST, A1_CEP, E1_VEND1, A3_NOME"
QRY1 := QRY1 + " FROM " + RetSQLName("SA1")+', '+ RetSQLName("SE1")+', '+ RetSQLName("SA3")
QRY1 := QRY1 + " WHERE "
QRY1 := QRY1 + RetSQLName('SE1')+".E1_FILIAL = '"+xFilial('SE1')+"' and "
QRY1 := QRY1 + RetSQLName('SA1')+".A1_FILIAL = '"+xFilial('SA1')+"' and "
QRY1 := QRY1 + RetSQLName('SE1')+".D_E_L_E_T_ <> '*' and "
QRY1 := QRY1 + RetSQLName('SA1')+".D_E_L_E_T_ <> '*' and "
QRY1 := QRY1 + RetSQLName('SE1')+".E1_SALDO > 0 and "
QRY1 := QRY1 + RetSQLName('SE1')+".E1_TIPO = 'NF' and "
QRY1 := QRY1 + RetSQLName('SE1')+".E1_VENCTO >= '"+DtoS(mv_par01)+"' and "
QRY1 := QRY1 + RetSQLName('SE1')+".E1_VENCTO <= '"+DtoS(mv_par02)+"' and "
QRY1 := QRY1 + RetSQLName('SE1')+".E1_CLIENTE >= '"+mv_par03+"' and "
QRY1 := QRY1 + RetSQLName('SE1')+".E1_CLIENTE <= '"+mv_par04+"' and "
QRY1 := QRY1 + RetSQLName('SE1')+".E1_VEND1 >= '"+mv_par05+"' and "
QRY1 := QRY1 + RetSQLName('SE1')+".E1_VEND1 <= '"+mv_par06+"' and "
QRY1 := QRY1 + RetSQLName('SE1')+".E1_CLIENTE = "+RetSQLName('SA1')+".A1_COD and "
QRY1 := QRY1 + RetSQLName('SE1')+".E1_LOJA = "+RetSQLName('SA1')+".A1_LOJA and "
QRY1 := QRY1 + RetSQLName('SE1')+".E1_VEND1 = "+RetSQLName('SA3')+".A3_COD"
QRY1 := QRY1 + ' order by E1_VEND1,A1_NOME,E1_NUM,E1_PARCELA'

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

// Processa Query SQL
TcQuery QRY1 NEW ALIAS "QRY1"         // Abre uma workarea com o resultado da query

// cria arquivo
_aCampos := {}
_aTamSX3 := TamSX3("E1_CLIENTE")
AAdd(_aCampos ,{"CLIENTE", "C",_aTamSX3[1],_aTamSX3[2]})
_aTamSX3 := TamSX3("E1_LOJA")
AAdd(_aCampos ,{"LOJA", "C",_aTamSX3[1],_aTamSX3[2]})
_aTamSX3 := TamSX3("A1_NOME")
AAdd(_aCampos ,{"NOME", "C",_aTamSX3[1],_aTamSX3[2]})
_aTamSX3 := TamSX3("E1_NUM")
AAdd(_aCampos ,{"TITULO","C",_aTamSX3[1],_aTamSX3[2]})
_aTamSX3 := TamSX3("E1_PARCELA")
AAdd(_aCampos ,{"PARCELA","C",_aTamSX3[1],_aTamSX3[2]})
_aTamSX3 := TamSX3("E1_EMISSAO")
AAdd(_aCampos ,{"EMISSAO","D",_aTamSX3[1],_aTamSX3[2]})
_aTamSX3 := TamSX3("E1_VENCTO")
AAdd(_aCampos ,{"VENCTO","D",_aTamSX3[1],_aTamSX3[2]})
_aTamSX3 := TamSX3("E1_VALOR")
AAdd(_aCampos ,{"VALOR","N",_aTamSX3[1],_aTamSX3[2]})
_aTamSX3 := TamSX3("E1_VALOR")
AAdd(_aCampos ,{"SALDO","N",_aTamSX3[1],_aTamSX3[2]})
_aTamSX3 := TamSX3("A1_END")
AAdd(_aCampos ,{"ENDERECO", "C",_aTamSX3[1],_aTamSX3[2]})
_aTamSX3 := TamSX3("A1_BAIRRO")
AAdd(_aCampos ,{"BAIRRO", "C",_aTamSX3[1],_aTamSX3[2]})
_aTamSX3 := TamSX3("A1_MUN")
AAdd(_aCampos ,{"CIDADE", "C",_aTamSX3[1],_aTamSX3[2]})
_aTamSX3 := TamSX3("A1_EST")
AAdd(_aCampos ,{"UF", "C",_aTamSX3[1],_aTamSX3[2]})
_aTamSX3 := TamSX3("A1_CEP")
AAdd(_aCampos ,{"CEP", "C",_aTamSX3[1],_aTamSX3[2]})
_aTamSX3 := TamSX3("E1_VEND1")
AAdd(_aCampos ,{"VENDEDOR", "C",_aTamSX3[1],_aTamSX3[2]})
_aTamSX3 := TamSX3("A3_NOME")
AAdd(_aCampos ,{"NVENDEDOR", "C",_aTamSX3[1],_aTamSX3[2]})

_cArqTrb := CriaTrab(_aCampos,.T.)
DbUseArea(.T.,,_cArqTrb,"TRB",.F.,.F.)
//dbUseArea(.T.,__LocalDriver,_cArqTrb,"TRB",.T.,.F.)
//SQLToTRB(QRY1,_aCampos,'TRB')

While QRY1->(!Eof())
	
	IncProc(OemToAnsi("Cliente..: " + QRY1->A1_NOME))
	
	DbSelectArea("TRB")
	RecLock("TRB",.T.)
	TRB->CLIENTE := QRY1->E1_CLIENTE
	TRB->LOJA    := QRY1->E1_LOJA
	TRB->NOME    := QRY1->A1_NOME
	TRB->ENDERECO:= QRY1->A1_END
	TRB->BAIRRO  := QRY1->A1_BAIRRO
	TRB->CIDADE  := QRY1->A1_MUN
	TRB->UF      := QRY1->A1_EST
	TRB->CEP     := QRY1->A1_CEP
	TRB->TITULO  := QRY1->E1_NUM
	TRB->PARCELA := QRY1->E1_PARCELA
	TRB->EMISSAO := CtoD(SubStr(QRY1->E1_EMISSAO,7,2)+'/'+SubStr(QRY1->E1_EMISSAO,5,2)+'/'+SubStr(QRY1->E1_EMISSAO,1,4))
	TRB->VENCTO  := CtoD(SubStr(QRY1->E1_VENCTO,7,2)+'/'+SubStr(QRY1->E1_VENCTO,5,2)+'/'+SubStr(QRY1->E1_VENCTO,1,4))
	TRB->VALOR   := QRY1->E1_VALOR
	TRB->SALDO   := QRY1->E1_SALDO
	TRB->VENDEDOR:= QRY1->E1_VEND1
	TRB->NVENDEDOR:= QRY1->A3_NOME
	
	TRB->(MsUnLock())
	
	dbSelectArea("QRY1")
	QRY1->(dbSkip())
	
EndDo

If mv_par08 == 1
	dbSelectArea("QRY1")
	QRY1->(dbGotop())
	
	ProcRegua(QRY1->(RECCOUNT()))
	
	Do While QRY1->(!EOF())
		
		_cCodCli := QRY1->E1_CLIENTE
		_cLojCli := QRY1->E1_LOJA
		_cNomCli := QRY1->A1_NOME
		_cEndCli := QRY1->A1_END
		_cBaiCli := QRY1->A1_BAIRRO
		_cMunCli := QRY1->A1_MUN
		_cEstCli := QRY1->A1_EST
		_cCepCli := QRY1->A1_CEP
		_cCodVend:= QRY1->E1_VEND1
		_nTotV   := 0
		_nTotS   := 0
		
		_cNum := {}
		_cPar := {}
		_cEmi := {}
		_cVen := {}
		_nVal := {}
		_nSal := {}
		
		Do While QRY1->(!EOF()) .and. QRY1->E1_CLIENTE == _cCodCli
			AADD(_cNum,QRY1->E1_NUM)
			AADD(_cPar,QRY1->E1_PARCELA)
			AADD(_cEmi,SubStr(QRY1->E1_EMISSAO,7,2)+'/'+SubStr(QRY1->E1_EMISSAO,5,2)+'/'+SubStr(QRY1->E1_EMISSAO,1,4))
			AADD(_cVen,SubStr(QRY1->E1_VENCTO,7,2)+'/'+SubStr(QRY1->E1_VENCTO,5,2)+'/'+SubStr(QRY1->E1_VENCTO,1,4))
			AADD(_nVal,QRY1->E1_VALOR)
			AADD(_nSal,QRY1->E1_SALDO)
			
			_nTotV := _nTotV + QRY1->E1_VALOR
			_nTotS := _nTotS + QRY1->E1_SALDO
			
			DbSelectArea("QRY1")
			QRY1->(Dbskip())
		End
		
		oArqMala := Iif(mv_par07==1,'a','b')+"_deve"+STRZERO(Len(_cNum),2)+".dot"
		
		cPathCli := "C:\wordtmp\"
		//CpyS2T("\DOT\"+oArqMala,cPathCli,.T.) // Copia do Server para o Remote

		hWord := OLE_CreateLink()
		OLE_NewFile( hWord, cPathCli + oArqMala)
		
		//³ Atualizando as variaveis do documento do Word
		OLE_SetDocumentVar(hWord, "_CCODCLI" ,_cCodCli)
		OLE_SetDocumentVar(hWord, "_CLOJCLI" ,_cLojCli)
		OLE_SetDocumentVar(hWord, "_CNOMCLI" ,_cNomCli)
		OLE_SetDocumentVar(hWord, "_CENDCLI" ,_cEndCli)
		OLE_SetDocumentVar(hWord, "_CBAICLI" ,_cBaiCli)
		OLE_SetDocumentVar(hWord, "_CMUNCLI" ,_cMunCli)
		OLE_SetDocumentVar(hWord, "_CESTCLI" ,_cEstCli)
		OLE_SetDocumentVar(hWord, "_CCEPCLI" ,_cCepCli)
		OLE_SetDocumentVar(hWord, "_CCODVEND" ,_cCodVend)
		OLE_SetDocumentVar(hWord, "_NTOTV"   ,Transform(_nTotV,"@E 999,999.99"))
		OLE_SetDocumentVar(hWord, "_NTOTS"   ,Transform(_nTotS,"@E 999,999.99"))
		
		For I:=1 to Len(_cNum)
			//OLE_SetDocumentVar(hWord, "_CIT"+alltrim(str(I))  ,xITEM_ORC[nIt])
			OLE_SetDocumentVar(hWord, "_CNUM"+alltrim(str(I)),_cNum[I])
			OLE_SetDocumentVar(hWord, "_CPAR"+alltrim(str(I)),_cPar[I])
			OLE_SetDocumentVar(hWord, "_CEMI"+alltrim(str(I)),_cEmi[I])
			OLE_SetDocumentVar(hWord, "_CVEN"+alltrim(str(I)),_cVen[I])
			OLE_SetDocumentVar(hWord, "_NVAL"+alltrim(str(I)),Transform(_nVal[I],"@E 999,999.99"))
			OLE_SetDocumentVar(hWord, "_NSAL"+alltrim(str(I)),Transform(_nSal[I],"@E 999,999.99"))
		Next
		
		OLE_Updatefields(hWord)
		Ole_PrintFile(hWord,"ALL",,,1)
		inkey(7)
		
		Ole_CloseFile(hWord)
	
		Ole_CloseLink(hWord)
		
	End
EndIf

DbSelectArea("TRB")
TRB->(dbGotop())
ProcRegua(TRB->(RECCOUNT()))	
aCols := Array(TRB->(RECCOUNT()),Len(_aCampos))
nColuna := 0
nLinha := 0
While TRB->(!Eof())
	nLinha++
	IncProc(OemToAnsi("Gerando planilha excel..."))
	For nColuna := 1 to Len(_aCampos)
		aCols[nLinha][nColuna] := &("TRB->("+_aCampos[nColuna][1]+")")			
	Next nColuna
	TRB->(dbSkip())	
EndDo
u_GDToExcel(_aCampos,aCols,Alltrim(FunName()))

DbSelectArea("TRB")
COPY TO &cArqExcell VIA "DBFCDX" 

MakeDir(cDestino) // CRIA DIRETÓRIO CASO NÃO EXISTA
CpyS2T(cArqExcell+".dbf",cDestino,.T.) // COPIA ARQUIVO PARA MAQUINA DO USUÁRIO
	

DbCloseArea()
Ferase(_cArqTrb+".DBF")

Return

//Etiqueta////////////////////////////////////////////////////////////////////
Static Function _Etiqu()
Local _cArqTrC
//Local cArqExcell:= GetSrvProfString("STARTPATH","")+"Excell-DBF\CartaETI" // JBS 12/12/2005
                                          
// Alterado para gravar arquivos na pasta protheus_data - Por Sandro em 19/11/09. 
Local cArqExcell:= "\Excell-DBF\CartaETI" 

// cria arquivo
_aCampos := {}
_aTamSX3 := TamSX3("E1_CLIENTE")
AAdd(_aCampos ,{"CLIENTE", "C",_aTamSX3[1],_aTamSX3[2]})
_aTamSX3 := TamSX3("E1_LOJA")
AAdd(_aCampos ,{"LOJA", "C",_aTamSX3[1],_aTamSX3[2]})
_aTamSX3 := TamSX3("A1_NOME")
AAdd(_aCampos ,{"NOME", "C",_aTamSX3[1],_aTamSX3[2]})
_aTamSX3 := TamSX3("A1_END")
AAdd(_aCampos ,{"ENDERECO", "C",_aTamSX3[1],_aTamSX3[2]})
_aTamSX3 := TamSX3("A1_BAIRRO")
AAdd(_aCampos ,{"BAIRRO", "C",_aTamSX3[1],_aTamSX3[2]})
_aTamSX3 := TamSX3("A1_MUN")
AAdd(_aCampos ,{"CIDADE", "C",_aTamSX3[1],_aTamSX3[2]})
_aTamSX3 := TamSX3("A1_EST")
AAdd(_aCampos ,{"UF", "C",_aTamSX3[1],_aTamSX3[2]})
_aTamSX3 := TamSX3("A1_CEP")
AAdd(_aCampos ,{"CEP", "C",_aTamSX3[1],_aTamSX3[2]})
_aTamSX3 := TamSX3("E1_VEND1")
AAdd(_aCampos ,{"VENDEDOR", "C",_aTamSX3[1],_aTamSX3[2]})

_cArqTrC := CriaTrab(_aCampos,.T.)
DbUseArea(.T.,,_cArqTrC,"TRC",.F.,.F.)
IndRegua("TRC",_cArqTrC,"VENDEDOR+NOME",,,"Criando Indice...(VENDEDOR+NOME)")

dbSelectArea("QRY1")
QRY1->(dbGotop())

ProcRegua(QRY1->(RECCOUNT()))

While QRY1->(!Eof())
	
	IncProc(OemToAnsi("Cliente..: " + QRY1->A1_NOME))
	
	DbSelectArea("TRC")
	
	If !dbSeek(QRY1->(E1_VEND1+A1_NOME))
		
		RecLock("TRC",.T.)
		TRC->CLIENTE := QRY1->E1_CLIENTE
		TRC->LOJA    := QRY1->E1_LOJA
		TRC->NOME    := QRY1->A1_NOME
		TRC->ENDERECO:= QRY1->A1_END
		TRC->BAIRRO  := QRY1->A1_BAIRRO
		TRC->CIDADE  := QRY1->A1_MUN
		TRC->UF      := QRY1->A1_EST
		TRC->CEP     := QRY1->A1_CEP
		TRC->VENDEDOR:= QRY1->E1_VEND1
		TRC->(MsUnLock())
	EndIf
	
	dbSelectArea("QRY1")
	QRY1->(dbSkip())
	
EndDo

DbSelectArea("TRC")
TRC->(dbGotop())
ProcRegua(TRC->(RECCOUNT()))	
aCols := Array(TRC->(RECCOUNT()),Len(_aCampos))
nColuna := 0
nLinha := 0
While TRC->(!Eof())
	nLinha++
	IncProc(OemToAnsi("Gerando planilha excel..."))
	For nColuna := 1 to Len(_aCampos)
		aCols[nLinha][nColuna] := &("TRC->("+_aCampos[nColuna][1]+")")			
	Next nColuna
	TRC->(dbSkip())	
EndDo
u_GDToExcel(_aCampos,aCols,Alltrim(FunName()))

DbSelectArea("TRC")
COPY TO &cArqExcell VIA "DBFCDXADS"

MakeDir(cDestino) // CRIA DIRETÓRIO CASO NÃO EXISTA
CpyS2T(cArqExcell+".dbf",cDestino,.T.) // COPIA ARQUIVO PARA MAQUINA DO USUÁRIO
	
DbCloseArea()
Ferase(_cArqTrC+".DBF")
Return

//Carta////////////////////////////////////////////////////////////////////
Static Function _Relac()

tamanho    := "M"
limite     := 132
titulo     := OemTOAnsi("RELACAO DE CARTAS ENVIADAS PARA CLIENTES",72)
cDesc1     := (OemToAnsi("Este programa tem como objetivo emitir um relacao",72))
cDesc2     := (OemToAnsi("das cartas enviada ao clientes por VENDEDOR.",72))
cDesc3     := (OemToAnsi(".",72))
aReturn    := {"Bco A4", 1,"Faturamento", 1, 2, 1,"",1}
nomeprog   := "DIPR034"
cPerg      := "DIPR34"
nLastKey   := 0
lContinua  := .T.
lEnd       := .F.
li         := 67
wnrel      := "DIPR034"
M_PAG      := 1
cString    := "SD2"

//AjustaSX1(cPerg)        // Verifica perguntas. Se nao existe INCLUI
//Pergunte(cPerg,.F.)     // Solicita parametros

wnrel := SetPrint(cString,wnrel,cPerg,Titulo,cDesc1,cDesc2,cDesc3,.f.,,.f.,tamanho,,.f.,,,,,)

If nLastKey == 27
	Return
Endif

SetDefault(aReturn,cString)

RptStatus({|lEnd| RptDetail()},Titulo)

Set device to Screen

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se em disco, desvia para Spool                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If aReturn[5] == 1    // Se Saida para disco, ativa SPOOL
	Set Printer TO
	Commit
	ourspool(wnrel)
Endif             



Return

//////////////////////////////////////////////////////////////
Static Function RptDetail()

_cTitulo := "Relacao de cartas enviadas"
_cDesc1  := " Cliente                                                                 Titulo       Emissao  Vencimento        Valor         Saldo"
_cDesc2  := ""
_VendOld := ''
_ClieOld := ''
_nTOTVAL := 0
_nTOTSAL := 0

DbSelectArea("QRY1")
QRY1->(DbGoTop())

SetRegua(RecCount())

Do While QRY1->(!Eof())
	_VendOld := QRY1->E1_VEND1
	_ClieOld := QRY1->E1_CLIENTE+QRY1->E1_LOJA
	
	IncRegua( "Imprimindo: " + QRY1->A1_NOME )
	
	_cTitulo := "Relacao de cartas enviadas "+Iif(mv_par07==1,'(1)','(2)')+" - Vendedor: "+QRY1->E1_VEND1+'-'+QRY1->A3_NOME
	
	If li > 65
		li := Cabec(_cTitulo,_cDesc1,_cDesc2,nomeprog,tamanho) + 1
	EndIf
	
	*         1         2         3         4         5         6         7         8         9         0         1         2         3         4         5         6
	*12345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
	*Cliente                                                                 Titulo       Emissao  Vencimento        Valor         Saldo
	*999999-99 1234567890123456789012345678901234567890123456789012345678901 999999-X  99/99/9999  99/99/9999 9.999.999,99  9.999.999,99
	*                                                                                                 Totais: 9.999.999,99  9.999.999,99
	
	@ li,001 PSay QRY1->E1_CLIENTE+'-'+QRY1->E1_LOJA+' '+QRY1->A1_NOME
	@ li,073 PSay QRY1->E1_NUM+Iif(!empty(QRY1->E1_PARCELA),'-'+QRY1->E1_PARCELA,'')
	@ li,083 PSay SubStr(QRY1->E1_EMISSAO,7,2)+'/'+SubStr(QRY1->E1_EMISSAO,5,2)+'/'+SubStr(QRY1->E1_EMISSAO,1,4)
	@ li,095 PSay SubStr(QRY1->E1_VENCTO,7,2)+'/'+SubStr(QRY1->E1_VENCTO,5,2)+'/'+SubStr(QRY1->E1_VENCTO,1,4)
	@ li,106 PSay QRY1->E1_VALOR Picture "@E 9,999,999.99"
	@ li,120 PSay QRY1->E1_SALDO Picture "@E 9,999,999.99"
	
	li++
	
	_nTOTVAL := _nTOTVAL + QRY1->E1_VALOR
	_nTOTSAL := _nTOTSAL + QRY1->E1_SALDO
	
	DbSelectArea("QRY1")
	QRY1->(DbSkip())
	
	If QRY1->E1_CLIENTE+QRY1->E1_LOJA <> _ClieOld
		@ li,099 PSay 'Totais:'
		@ li,106 PSay _nTotVal Picture "@E 9,999,999.99"
		@ li,120 PSay _nTotSal Picture "@E 9,999,999.99"
		li++
		@ li,000 PSay Replic("-",Limite)
		li++
		
		_nTOTVAL := 0
		_nTOTSAL := 0
	EndIf
	
	If QRY1->E1_VEND1 <> _VendOld .or. QRY1->(EOF())
		li++
		Roda(0,'',Tamanho)
		li := 67
		M_PAG      := 1
	EndIf
EndDo

Return(.T.)


///////////////////////////
Static Function AjustaSX1(cPerg)
Local _sAlias := Alias()
dbSelectArea("SX1")
dbSetOrder(1)   

aRegs:={}

//------------ Grupo/Ordem/Pergunta/PERGING/PERGESP/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05/F3

aAdd(aRegs,{cPerg,"01","Vencimento inicial ?","","","mv_ch1","D",8,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"02","Vencimento final   ?","","","mv_ch2","D",8,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","",""})
aADD(aRegs,{cPerg,"03","Cliente inicial    ?","","","mv_ch3","C",6,0,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","",'SA1'})
aADD(aRegs,{cPerg,"04","Cliente final      ?","","","mv_ch4","C",6,0,0,"G","","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","",'SA1'})
aADD(aRegs,{cPerg,"05","Vendedor inicial   ?","","","mv_ch5","C",6,0,0,"G","","mv_par05","","","","","","","","","","","","","","","","","","","","","","","","",'SA3'})
aADD(aRegs,{cPerg,"06","Vendedor final     ?","","","mv_ch6","C",6,0,0,"G","","mv_par06","","","","","","","","","","","","","","","","","","","","","","","","",'SA3'})
aADD(aRegs,{cPerg,"07","Qual Modelo        ?","","","mv_ch7","N",1,0,1,"C","","mv_par07","1","","","","","2","","","","","","","","","","","","","","","","","","",""})
aADD(aRegs,{cPerg,"08","Imprime/Gera Arq.  ?","","","mv_ch8","N",1,0,1,"C","","mv_par08","Imprime","","","","","cartas.DBF","","","","","","","","","","","","","","","","","","",""})
aADD(aRegs,{cPerg,"09","Relacao            ?","","","mv_ch9","N",1,0,1,"C","","mv_par09","Sim","","","","","Nao","","","","","","","","","","","","","","","","","","",""})
aADD(aRegs,{cPerg,"10","Etiqueta (cartaeti)?","","","mv_chA","N",1,0,1,"C","","mv_par10","Sim","","","","","Nao","","","","","","","","","","","","","","","","","","",""})

For i:=1 to Len(aRegs)
	If !dbSeek(cPerg+aRegs[i,2])
		RecLock("SX1",.T.)
		For j:=1 to FCount()
			If j <= Len(aRegs[i])
				FieldPut(j,aRegs[i,j])
			Endif
		Next
		SX1->(MsUnlock())
	Endif
Next

dbSelectArea(_sAlias)
Return
///////////////////////////////////////////////////////////////////////

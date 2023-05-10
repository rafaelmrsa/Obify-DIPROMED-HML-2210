#include "rwmake.ch"
#define DESLOC_ETQ  57

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Fun‡…o    ³ DIPR017  ³ Autor ³ Eriberto Elias        ³ Data ³ 01.11.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Etiquetas para enderecamento de clientes                   ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function DIPR017()

//³ Define Variaveis                                             ³
LOCAL titulo := "Etiquetas para enderecamento de clientes/fornecedores"
LOCAL cDesc1 := "Este programa ira emitir as etiquetas"
LOCAL cDesc2 := "para as enderecamento de clientes/fornecedores"
LOCAL cDesc3 := "conforme parametros"
LOCAL wnrel
LOCAL tamanho:= "G"
LOCAL cString:= "SA1"
LOCAL aOrd      := { " Etiqueta - 36 X 81mm  3 colunas " }		//" Etiqueta - 36 X 81mm  3 colunas "
LOCAL aImp      := 0
PRIVATE aReturn := { "Etiqueta", 1,"Producao", 2, 2, 1, "",1 }		//"Etiqueta"###"Producao"
PRIVATE nomeprog:= "DIPR017" //"MATR710"
PRIVATE aLinha  := { },nLastKey := 0
PRIVATE cPerg   :="DIPR17" 
// FPADR(cPerg, cArq, cCampo, cTipo)  - Para ajustar o tamanho das perguntas no SX1
PRIVATE cPerg  	:= U_FPADR( "DIPR017","SX1","SX1->X1_GRUPO"," " ) //Função criada por Sandro em 19/11/09.


U_DIPPROC(ProcName(0),U_DipUsr()) // JBS 05/10/2005 - Gravando o nome do Programa no SZU
//³ Variaveis utilizadas para Impressao do Cabecalho e Rodape    ³
//³ Verifica as perguntas selecionadas                           ³

AjustaSX1(cPerg)

Pergunte(cPerg,.T.)

wnrel:="DIPR017"            //Nome Default do relatorio em Disco
wnrel:=SetPrint(cString,wnrel,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,.F.,tamanho)
If nLastKey == 27
	Set Filter to
	Return
Endif
SetDefault(aReturn,cString)
If nLastKey == 27
	Set Filter to
	Return
Endif
RptStatus({|lEnd| C710Imp(@lEnd,wnRel,cString)},Titulo)
Return


// IMPRIMINDO

Static Function C710Imp(lEnd,WnRel,cString)

//³ Define Variaveis                                             ³
LOCAL CbTxt
LOCAL nTipo, nOrdem
LOCAL CbCont,cabec1,cabec2
LOCAL tamanho:= "P"
LOCAL limite := 80
LOCAL lContinua := .T.
LOCAL nVolume := nVolumex := 0
LOCAL aEtiq[8,3]
LOCAL nEtiqueta := I := J := 1
LOCAL aOrd      := { " Etiqueta - 36 X 81mm  3 colunas " }
LOCAL aImp      := 0
LOCAL nEstaOk   := 0
LOCAL nContCol  := 1
LOCAL cPedi     := ""
Local cX
Local cIndex
Local lRet      := .F.
Local cCadastro := "Etiquetas para enderecamento"

//³ Definicao do cabecalho e tipo de impressao do relatorio      ³
cbtxt    := SPACE(10)
cbcont   := 0
li       := 0
col      := 0
m_pag    := 1
titulo := "ETIQUETAS PARA ENDERACAMENTO"
cabec1 := ""
cabec2 := ""
nTipo  := 18
nOrdem := aReturn[8]

If mv_par03 == 1
	dbSelectArea("SA1")
	dbsetorder(1)
	dbSeek(xFilial("SA1"),.T.)
	SetRegua(RecCount())
Else
	dbSelectArea("SA2")
	dbsetorder(2)
	dbSeek(xFilial("SA2"),.T.)
	SetRegua(RecCount())
EndIf
//³ Faz manualmente porque nao chama a funcao Cabec()                 ³
@ 0,0 Psay AvalImp(Limite)

While !eof() .and. lContinua
	IncRegua()
	
	If mv_par03 == 1
		If SA1->A1_ULTCOM < mv_par01 .OR. SA1->A1_ULTCOM > mv_par02
			SA1->(dbskip())
			Loop
		EndIf
	EndIf
	
	IF lEnd
		@PROW()+1,001 Psay "CANCELADO PELO OPERADOR"
		lContinua := .F.
		EXIT
	Endif
	
	For G:=1 to 3
		
		If aImp == 0
			While !lRet
				lRet := (MsgYesNo("O Alinhamento da Impressora esta correto ?","Aten‡„o"))			//"O Alinhamento da Impressora esta correto ?"###"Aten‡„o"
			End
		EndIf
		_n_Lin := pRow()
		_n_Col := pCol()
		@ _n_Lin,_n_Col Psay chr(15)
		setPrc( _n_Lin,_n_Col )
		
		If mv_par03 == 1
			Do Case
				Case nEtiqueta == 1
					aEtiq[1,nEtiqueta] := SA1->A1_NOME
					aEtiq[2,nEtiqueta] := REPLICATE("-",LEN(ALLTRIM(SA1->A1_NOME)))
					aEtiq[3,nEtiqueta] := ""
					aEtiq[4,nEtiqueta] := ALLTRIM(SA1->A1_END)+ Iif(!EMPTY(SA1->A1_BAIRRO),' - '+SA1->A1_BAIRRO,'')
					aEtiq[5,nEtiqueta] := 'CEP.: '+SA1->A1_CEP+'  '+AllTrim(SA1->A1_MUN)+" - "+SA1->A1_EST
					aEtiq[6,nEtiqueta] := ""
					aEtiq[7,nEtiqueta] := "At. Departamento de Compras"
					aEtiq[8,nEtiqueta] := SPACE(50)+SA1->A1_COD+' '+SA1->A1_LOJA
					nEtiqueta++
				Case nEtiqueta == 2
					aEtiq[1,nEtiqueta] := SA1->A1_NOME
					aEtiq[2,nEtiqueta] := REPLICATE("-",LEN(ALLTRIM(SA1->A1_NOME)))
					aEtiq[3,nEtiqueta] := ""
					aEtiq[4,nEtiqueta] := ALLTRIM(SA1->A1_END)+ Iif(!EMPTY(SA1->A1_BAIRRO),' - '+SA1->A1_BAIRRO,'')
					aEtiq[5,nEtiqueta] := 'CEP.: '+SA1->A1_CEP+'  '+AllTrim(SA1->A1_MUN)+" - "+SA1->A1_EST
					aEtiq[6,nEtiqueta] := ""
					aEtiq[7,nEtiqueta] := "At. Departamento de Compras"
					aEtiq[8,nEtiqueta] := SPACE(50)+SA1->A1_COD+' '+SA1->A1_LOJA
					nEtiqueta++
				Case nEtiqueta == 3
					aEtiq[1,nEtiqueta] := SA1->A1_NOME
					aEtiq[2,nEtiqueta] := REPLICATE("-",LEN(ALLTRIM(SA1->A1_NOME)))
					aEtiq[3,nEtiqueta] := ""
					aEtiq[4,nEtiqueta] := ALLTRIM(SA1->A1_END)+ Iif(!EMPTY(SA1->A1_BAIRRO),' - '+SA1->A1_BAIRRO,'')
					aEtiq[5,nEtiqueta] := 'CEP.: '+SA1->A1_CEP+'  '+AllTrim(SA1->A1_MUN)+" - "+SA1->A1_EST
					aEtiq[6,nEtiqueta] := ""
					aEtiq[7,nEtiqueta] := "At. Departamento de Compras"
					aEtiq[8,nEtiqueta] := SPACE(50)+SA1->A1_COD+' '+SA1->A1_LOJA
					nEtiqueta := 1
					For I:= 1 TO 8
						For J:=1 TO 3
							@Li , COL  Psay aEtiq[I,J]
							COL := COL + 14
							COL += DESLOC_ETQ
						Next j
						Li++
						COL := 0
					Next I
					For I:= 1 TO 8
						For J:=1 TO 3
							aEtiq[I,J] := ""
						NEXT J
					NEXT I
					Li++
			EndCase
		Else
			Do Case
				Case nEtiqueta == 1
					aEtiq[1,nEtiqueta] := SA2->A2_NOME
					aEtiq[2,nEtiqueta] := REPLICATE("-",LEN(ALLTRIM(SA2->A2_NOME)))
					aEtiq[3,nEtiqueta] := ""
					aEtiq[4,nEtiqueta] := ALLTRIM(SA2->A2_END)+ Iif(!EMPTY(SA2->A2_BAIRRO),' - '+SA2->A2_BAIRRO,'')
					aEtiq[5,nEtiqueta] := 'CEP.: '+SA2->A2_CEP+'  '+AllTrim(SA2->A2_MUN)+" - "+SA2->A2_EST
					aEtiq[6,nEtiqueta] := ""
					aEtiq[7,nEtiqueta] := "At. Departamento de Vendas"
					aEtiq[8,nEtiqueta] := SPACE(50)+SA2->A2_COD+' '+SA2->A2_LOJA
					nEtiqueta++
				Case nEtiqueta == 2
					aEtiq[1,nEtiqueta] := SA2->A2_NOME
					aEtiq[2,nEtiqueta] := REPLICATE("-",LEN(ALLTRIM(SA2->A2_NOME)))
					aEtiq[3,nEtiqueta] := ""
					aEtiq[4,nEtiqueta] := ALLTRIM(SA2->A2_END)+ Iif(!EMPTY(SA2->A2_BAIRRO),' - '+SA2->A2_BAIRRO,'')
					aEtiq[5,nEtiqueta] := 'CEP.: '+SA2->A2_CEP+'  '+AllTrim(SA2->A2_MUN)+" - "+SA2->A2_EST
					aEtiq[6,nEtiqueta] := ""
					aEtiq[7,nEtiqueta] := "At. Departamento de Vendas"
					aEtiq[8,nEtiqueta] := SPACE(50)+SA2->A2_COD+' '+SA2->A2_LOJA
					nEtiqueta++
				Case nEtiqueta == 3
					aEtiq[1,nEtiqueta] := SA2->A2_NOME
					aEtiq[2,nEtiqueta] := REPLICATE("-",LEN(ALLTRIM(SA2->A2_NOME)))
					aEtiq[3,nEtiqueta] := ""
					aEtiq[4,nEtiqueta] := ALLTRIM(SA2->A2_END)+ Iif(!EMPTY(SA2->A2_BAIRRO),' - '+SA2->A2_BAIRRO,'')
					aEtiq[5,nEtiqueta] := 'CEP.: '+SA2->A2_CEP+'  '+AllTrim(SA2->A2_MUN)+" - "+SA2->A2_EST
					aEtiq[6,nEtiqueta] := ""
					aEtiq[7,nEtiqueta] := "At. Departamento de Vendas"
					aEtiq[8,nEtiqueta] := SPACE(50)+SA2->A2_COD+' '+SA2->A2_LOJA
					nEtiqueta := 1
					For I:= 1 TO 8
						For J:=1 TO 3
							@Li , COL  Psay aEtiq[I,J]
							COL := COL + 14
							COL += DESLOC_ETQ
						Next j
						Li++
						COL := 0
					Next I
					For I:= 1 TO 8
						For J:=1 TO 3
							aEtiq[I,J] := ""
						NEXT J
					NEXT I
					Li++
			EndCase
			
		EndIf
		
		
		If mv_par03 == 1
			
			dbSelectArea("SA1")
			SA1->(dbSkip())
			While !SA1->(EOF())
				If SA1->A1_ULTCOM < mv_par01 .OR. SA1->A1_ULTCOM > mv_par02
					SA1->(dbskip())
					Loop
				Else
					Exit
				EndIf
			EndDo
		Else
			dbSelectArea("SA2")
			SA2->(dbSkip())
			
		EndIf
	Next G
	If mv_par03 == 1
		dbSelectArea("SA1")
		SA1->(dbSkip())
	Else
		dbSelectArea("SA2")
		SA2->(dbSkip())
		
	EndIf
End
If nOrdem == 1
	For I:= 1 TO 8
		For J:=1 TO 3
			If !EMPTY(aEtiq[I,J])
				@Li , COL  Psay aEtiq[I,J]
				COL := COL + 14
				COL += DESLOC_ETQ
			EndIf
		NEXT J
		Li++
		COL := 0
	Next I
EndIf
@ Li+1,0 Psay ""
Setprc(0,0)

MS_FLUSH()

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºFun‡„o    ³VALIDPERG º Autor ³ AP5 IDE            º Data ³  08/01/02   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescri‡„o ³ Verifica a existencia das perguntas criando-as caso seja   º±±
±±º          ³ necessario (caso nao existam).                             º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function AjustaSX1(cPerg)

Local _sAlias := Alias()
Local aRegs := {}
Local i,j
dbSelectArea("SX1")
dbSetOrder(1)  

aAdd(aRegs,{cPerg,"01","Da Data            ?","","","mv_ch1","D",8,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"02","Ate a Data         ?","","","mv_ch2","D",8,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"03","Cliente/Fornecedor ?","","","mv_ch3","N",1,0,1,"C","","mv_par03","Cliente","","","","","Fornecedor","","","","","","","",""})

For i:=1 to Len(aRegs)
	If !dbSeek(cPerg+aRegs[i,2])
		RecLock("SX1",.T.)
		For j:=1 to FCount()
			If j <= Len(aRegs[i])
				FieldPut(j,aRegs[i,j])
			Endif
		Next
		MsUnlock()
	Endif
Next
DbSelectArea(_sAlias)

Return

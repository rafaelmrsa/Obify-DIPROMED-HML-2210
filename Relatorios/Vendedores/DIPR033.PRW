/*==========================================================================\
|Programa  | DIPR033 | Autor | Rafael de Campos Falco  | Data | 09/10/2003  |
|===========================================================================|
|Desc.     | Relação de clientes - analitico - Por Vendedor                 |
|===========================================================================|
|Sintaxe   | DIPR033                                                        |
|===========================================================================|
|Uso       | Especifico DIPROMED                                            |
|===========================================================================|
|===========================================================================|
|Histórico |   /  /   -                                                     |
|Maximo    | 23/08/07 - Incluir tratamento para gerar relatírio p/ vendedor2| 
|Maximo    | 15/10/07 - Tratamento para ser executado na HQ (A1_VENDHQ)     |
|Maximo    | 15/10/09 - Alterado o caminho do arquivo e PREPARE ENVIRONMENT | 
\==========================================================================*/

#Include "RwMake.ch"
#INCLUDE "TBICONN.CH"
#INCLUDE "FILEIO.CH"

User Function DIPR033(aWork)
Local _xArea    := GetArea()

Local titulo     := OemTOAnsi("Relação de clientes - analítico - Por Vendedor",72)
Local cDesc1     := (OemToAnsi("Este programa tem como objetivo emitir um relat¢rio",72))
Local cDesc2     := (OemToAnsi("com a relação de todos clientes do vendedor.",72))
Local cDesc3     := (OemToAnsi("Conforme parametros definidos pelo o usuario.",72))

Private aPar2		:= ""
Private aReturn    := {"Bco A4", 1,"Administracao", 1, 2, 1,"",1}
Private li         := 67
Private tamanho    := "P"
Private limite     := 80
Private nomeprog   := "DIPR033"

// Private cPerg      := "DIPR33"
// FPADR(cPerg, cArq, cCampo, cTipo)  - Para ajustar o tamanho das perguntas no SX1- uso generico
PRIVATE cPerg  	

Private nLastKey   := 0
Private lEnd       := .F.
Private wnrel      := "DIPR033"
Private cString    := "SE1"
Private m_pag      := 1
Private cWorkFlow  := ""
Private cWCodEmp   := ""  
Private cWCodFil   := "" 
//Tratamento para workflow
If ValType(aWork) <> 'A'
	cWorkFlow := "N" 
	cWCodEmp  := cEmpAnt
    cWCodFil  := cFilAnt                                                                      
	cPerg  	:= U_FPADR( "DIPR33","SX1","SX1->X1_GRUPO"," " ) //Função criada por Sandro em 19/11/09.
    U_DIPPROC(ProcName(0),U_DipUsr()) // JBS 13/12/2005 - Gravando o nome do Programa no SZU
Else
	cWorkFlow := aWork[1]    
	cWCodEmp  := aWork[3]
    cWCodFil  := aWork[4]
EndIf

If cWorkFlow == "S"    
	PREPARE ENVIRONMENT EMPRESA cWCodEmp FILIAL cWCodFil FUNNAME "DIPR033" //TABLES "SA1","SA3"
EndIf

If cWorkFlow == "N"

	AjustaSX1(cPerg)           // Verifica perguntas. Se nao existe INCLUI.
	
	If !Pergunte(cPerg,.T.)    // Solicita parametros
		Return
	EndIf                      
	
	wnrel := SetPrint(cString,wnrel,cPerg,Titulo,cDesc1,cDesc2,cDesc3,.f.,,.f.,tamanho,,.f.,,,,,)

	If nLastKey == 27
		Return
	Endif
	
	SetDefault(aReturn,cString)
	
	RptStatus({|lEnd| RodaRel()},Titulo)
	
	Set device to Screen
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Se em disco, desvia para Spool                                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If aReturn[5] == 1    // Se Saida para disco, ativa SPOOL
		Set Printer TO
		Commit
		ourspool(wnrel)
	Endif
	
	
Else

	// Parâmetros do vendedor
	MV_PAR01 := aWork[2]
	MV_PAR02 := aWork[2]
	MV_PAR03 := ""

	If Empty( Posicione("SA3",1,xFilial("SA3")+MV_PAR01,"A3_DESLIG") )
		ConOut(' ')
	    ConOut('Relação de clientes - Vendedor ' + MV_PAR01 + ' Inicio em '+dToc(date())+' as '+Time())
		ConOut(' ')
		
		RodaRel()
	
		ConOut(' ')
	    ConOut('Relação de clientes - Vendedor ' + MV_PAR01 + ' Concluido em '+dToc(date())+' as '+Time())
		ConOut(' ')
	EndIf

/*		
	ConOut("----------------------------")
	ConOut('Inicio - ' + dToc(date())+' - '+Time())
	ConOut("----------------------------")
	
	RodaRel()

	ConOut("--------------------------")
	ConOut('Fim - ' + dToc(date())+' - '+Time())
	ConOut("--------------------------")
*/
Endif

RestArea(_xArea)

Return

//////////////////////////////////////////////////////////////////////
Static Function RodaRel()
Local _nTotVal  := 0
Local _nTotSal  := 0
Local _nTotValG := 0
Local _nTotSalG := 0
Local _nAtraso  := 0
Local _cCliente := ''
Local _cVend    := ''
Local cArq			:= ""
Local cCampos		:= ""
Local nHandle		:= ""
Local cCodVen		:= ""
Local nTotImp		:= 10
Private _cTitulo := ""
Private _cDesc1  := "" 
Private _cDesc2  := ""

/* Seleciona os clientes do vendedor(es) informado(s)
SELECT A1_VEND, A1_NOME, A1_LOJA, A1_COD, A1_CGC, A1_INSCR, A1_END, A1_BAIRRO, A1_MUN, A1_EST, A1_TEL, A1_FAX, A1_EMAIL, A1_ULTCOM, A3_NOME 
FROM SA1010, SA3010
WHERE SA1010.A1_VEND between '000199' and '000199' and
SA1010.D_E_L_E_T_ <> '*' AND
SA3010.D_E_L_E_T_ <> '*' AND
A1_VEND = A3_COD
ORDER BY A1_NOME, A1_VEND
*/

/*QRY1 := " SELECT "+If(("0401" $ cWCodEmp+cWCodFil),"A1_VENDHQ","A1_VEND")+", A1_NOME, A1_VENDKC , A1_XVENDSP, A1_LOJA, A1_COD, A1_CGC, A1_INSCR, A1_END, A1_BAIRRO, A1_MUN, A1_EST, A1_TEL, A1_FAX, A1_EMAIL, A1_ULTCOM, A3_NOME"
QRY1 += " FROM " + RetSQLName("SA1")+', '+ RetSQLName("SA3")
QRY1 += " WHERE (" + RetSQLName("SA1")+"."+If(("0401" $ cWCodEmp+cWCodFil),"A1_VENDHQ","A1_VEND")+" BETWEEN '" + MV_PAR01 + "' and '" + MV_PAR02 + "' or "
QRY1 += RetSQLName("SA1")+".A1_VENDKC BETWEEN '" + MV_PAR01 + "' and '" + MV_PAR02 + "' or "
QRY1 += RetSQLName("SA1")+".A1_XVENDSP BETWEEN '" + MV_PAR01 + "' and '" + MV_PAR02 + "' ) AND "
If U_ListVend() != ''
	QRY1 += "  ("+If(("0401" $ cWCodEmp+cWCodFil),"A1_VENDHQ","A1_VEND")+" "+ U_ListVend()  +" OR A1_VENDKC " + U_ListVend()+") AND "  
EndIf        
If !Empty(MV_PAR03)
	QRY1 += "  A1_GRPVEN ='" + MV_PAR03 + "' AND "
EndIf
QRY1 += RetSQLName("SA1")+".D_E_L_E_T_ <> '*' AND "
QRY1 += RetSQLName("SA3")+".D_E_L_E_T_ <> '*' AND "
QRY1 += " "+If(("0401" $ cWCodEmp+cWCodFil),"A1_VENDHQ","A1_VEND")+" = A3_COD " 
If MV_PAR01 == MV_PAR02
	QRY1 += "order by A1_NOME"
Else
	QRY1 += "order by "+If(("0401" $ cWCodEmp+cWCodFil),"A1_VENDHQ","A1_VEND")+", A1_VENDKC, A1_NOME"
Endif*/


QRY1 := " SELECT A1_VEND, A1_NOME, A1_VENDKC , A1_XVENDSP, A1_LOJA, A1_COD, A1_CGC, A1_INSCR, A1_END, A1_BAIRRO, A1_MUN, A1_EST, A1_TEL, A1_FAX, A1_EMAIL, A1_ULTCOM, A3_NOME"
QRY1 += " FROM " + RetSQLName("SA1")+', '+ RetSQLName("SA3")
QRY1 += " WHERE " + RetSQLName("SA1")+"."+"A1_VEND"+" BETWEEN '" + MV_PAR01 + "' and '" + MV_PAR02 + "' AND "
If U_ListVend() != ''
//	QRY1 += RetSQLName("SA1")+"."+"A1_VEND" +U_ListVend() + " AND "
EndIf        
If !Empty(MV_PAR03)
	QRY1 += RetSQLName("SA1")+"."+"A1_VEND" + MV_PAR03 + "' AND "
EndIf
QRY1 += RetSQLName("SA1")+".D_E_L_E_T_ <> '*' AND "
QRY1 += RetSQLName("SA3")+".D_E_L_E_T_ <> '*' AND "
QRY1 += RetSQLName("SA1")+".A1_VEND = "+ RetSQLName("SA3")+".A3_COD " 
If MV_PAR01 == MV_PAR02
	QRY1 += "order by A1_NOME"
Else
	QRY1 += "order by A1_VEND, A1_VENDKC, A1_NOME"
Endif

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

DbSelectArea("QRY1")
QRY1->(dbGotop())

// Parâmetros de montagem do cabeçalho
_cTitulo := "Relação de Clientes por vendedor"
_cDesc1  := "" 
_cDesc2  := ""

//Monta o nome do arquivo caso seja WORKFLOW
If cWorkFlow == "S"     
	If ("0401" $ cWCodEmp+cWCodFil)
		cArq := "/VENDEDORES/HQ/"+MV_PAR01 + Substr(Dtoc(Date()),1,2) + Substr(Dtoc(Date()),4,2) + ".033"
	ElseIf ("0404" $ cWCodEmp+cWCodFil)
		cArq := "/VENDEDORES/HQ-CD/"+MV_PAR01 + Substr(Dtoc(Date()),1,2) + Substr(Dtoc(Date()),4,2) + ".033"
	ElseIf ("0101" $ cWCodEmp+cWCodFil)                                                                  
		cArq := "/VENDEDORES/DIPROMED-MTZ/"+MV_PAR01 + Substr(Dtoc(Date()),1,2) + Substr(Dtoc(Date()),4,2) + ".033"	
	Else
		cArq := "/VENDEDORES/DIPROMED/"+MV_PAR01 + Substr(Dtoc(Date()),1,2) + Substr(Dtoc(Date()),4,2) + ".033"
	Endif
	cCampos		:= ""
	nHandle		:= Fcreate(cArq,0)
Else
	SetRegua(RecCount())
EndIf

Do While QRY1->(!Eof())
	*         1         2         3         4         5         6         7         8         9         0         1         2         3         4         5         6         7         8         9         0
	*123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901
	*dipr033/v.AP6 6.09 Posicao de Titulos a Receber - analitico - PData.: 99/99/99
	*                                                                           Dias
	*Pfx Numero Parcela Tipo Emissao     Vencimento        Valor        Saldo Atraso
	*UNI 999999    A     NF  99/99/9999  99/99/9999 9.999.999,99 9.999.999,99  99999
	*                                       Totais: 9,999,999.99 9,999,999.99
	*                    Totais do Vendedor 999999:
		
	If cWorkFlow == "N" // SE NÃO FOR WORKFLOW

		If lAbortPrint
			@ li+1,00 PSAY "*** CANCELADO PELO OPERADOR ***"
			Exit
		Endif
	
		IncRegua( "Imprimindo... " + QRY1->A1_NOME)
		
		If li > 56

			li := u_MYCabec(_cTitulo,_cDesc1,_cDesc2,nHandle,cWorkFlow)
			li++
//			@ li,001 PSay "Vendedor: " + QRY1->A1_VEND + ' - ' + AllTrim(QRY1->A3_NOME)
            
			If QRY1->A1_VENDKC == MV_PAR01
				@ li,001 PSay "Vendedor: " + QRY1->A1_VENDKC + ' - ' + Alltrim(Posicione("SA3",1,xFilial("SA3")+QRY1->A1_VENDKC,"A3_NOME"))
			ElseIf QRY1->A1_XVENDSP == MV_PAR01
				@ li,001 PSay "Vendedor: " + QRY1->A1_XVENDSP + ' - ' + Alltrim(Posicione("SA3",1,xFilial("SA3")+QRY1->A1_XVENDSP,"A3_NOME"))
			Else
				@ li,001 PSay "Vendedor: " + If(("0401" $ cWCodEmp+cWCodFil),QRY1->A1_VENDHQ,QRY1->A1_VEND) + ' - ' + AllTrim(QRY1->A3_NOME)
			Endif
	
			li+=2
			@ li,000 PSay Replic("-",Limite)
			li++
			@ li,001 PSay "Código - Loja - Cliente"
			li++
			@ li,001 PSay "CNPJ"
			@ li,020 PSay "IE"
			@ li,043 PSay "Fone"
			@ li,064 PSay "Fax "
			li++
			@ li,001 PSay "Endereço"
			li++
			@ li,001 PSay "Bairro"
			@ li,035 PSay "Cidade"
			@ li,073 PSay "Estado"
			li++
			@ li,001 PSay "E-Mail"
			@ li,067 PSay "Última Compra"
			li++
			@ li,000 PSay Replic("-",Limite)
			li++

			If QRY1->A1_VENDKC == MV_PAR01    
				cCodVen := QRY1->A1_VENDKC
			ElseIf QRY1->A1_XVENDSP == MV_PAR01
				cCodVen := QRY1->A1_XVENDSP
			Else                        
				cCodVen := If(("0401" $ cWCodEmp+cWCodFil),QRY1->A1_VENDHQ,QRY1->A1_VEND)
			Endif
			
		EndIf	

		@ li,001 PSay QRY1->A1_COD+" - "+QRY1->A1_LOJA+" - "+QRY1->A1_NOME
		li++
		@ li,001 PSay QRY1->A1_CGC
		@ li,020 PSay QRY1->A1_INSCR
		@ li,043 PSay QRY1->A1_TEL
		@ li,064 PSay QRY1->A1_FAX
		li++
		@ li,001 PSay QRY1->A1_END
		li++
		@ li,001 PSay QRY1->A1_BAIRRO
		@ li,035 PSay QRY1->A1_MUN
		@ li,073 PSay QRY1->A1_EST
		li++
		@ li,001 PSay QRY1->A1_EMAIL
		@ li,069 PSay SubStr(QRY1->A1_ULTCOM,7,2)+"/"+SubStr(QRY1->A1_ULTCOM,5,2)+"/"+SubStr(QRY1->A1_ULTCOM,1,4)
		li++
		@ li,000 PSay Replic("-",Limite)
		li++
		QRY1->(DbSkip())
		
	Else	// CASO SEJA WORKFLOW

		/*----------------------------- A T E N Ç Ã O ------------------------------------	
		Para correta impressão do relatório verificar as seguintes configurações de 
		impressão no bloco de notas (NotePad):
		Fonte Courier - Normal - 10
		Papel Carta 21,59 X 27,94cm
		Margens: Direita 20 , Esquerda 20 , Superior 25 e Inferior 20
		---------------------------------------------------------------------------------*/	

		If li > 56
			u_Pag033(_cTitulo,_cDesc1,_cDesc2,nHandle,cWorkFlow)
		EndIf	

		cCampos := QRY1->A1_COD+" - "+QRY1->A1_LOJA+"  -   "+QRY1->A1_NOME + Chr(13) + Chr(10)
		Fwrite(nHandle,cCampos)
		li++
		If li > 56
			u_Pag033(_cTitulo,_cDesc1,_cDesc2,nHandle,cWorkFlow)
		EndIf	

		nPosic  := 21-Len(QRY1->A1_CGC)
		cCampos := QRY1->A1_CGC + Space(nPosic)
		nPosic  := 22-Len(QRY1->A1_INSCR)
		cCampos += QRY1->A1_INSCR + Space(nPosic)
		nPosic  := 20-Len(QRY1->A1_TEL)
		cCampos += QRY1->A1_TEL + Space(nPosic)
		cCampos += QRY1->A1_FAX + Chr(13) + Chr(10)
		Fwrite(nHandle,cCampos)
		li++
		If li > 56
			u_Pag033(_cTitulo,_cDesc1,_cDesc2,nHandle,cWorkFlow)
		EndIf	
		
		cCampos := QRY1->A1_END + Chr(13) + Chr(10)
		Fwrite(nHandle,cCampos)
		li++
		If li > 56
			u_Pag033(_cTitulo,_cDesc1,_cDesc2,nHandle,cWorkFlow)
		EndIf	
		
		nPosic  := 35-Len(QRY1->A1_BAIRRO)
		cCampos := QRY1->A1_BAIRRO + Space(nPosic)
		nPosic  := 36-Len(QRY1->A1_MUN)
		cCampos += QRY1->A1_MUN + Space(nPosic)
		cCampos += QRY1->A1_EST + Chr(13) + Chr(10)
		Fwrite(nHandle,cCampos)
		li++
		// Quebra de página
		If li > 56
			u_Pag033(_cTitulo,_cDesc1,_cDesc2,nHandle,cWorkFlow)
		EndIf	

		nPosic  := 70-Len(QRY1->A1_EMAIL)
		cCampos := QRY1->A1_EMAIL + Space(nPosic)
		cCampos += SubStr(QRY1->A1_ULTCOM,7,2)+"/"+SubStr(QRY1->A1_ULTCOM,5,2)+"/"+SubStr(QRY1->A1_ULTCOM,1,4) + Chr(13) + Chr(10)
		Fwrite(nHandle,cCampos)
		li++
		// Quebra de página
		If li > 56
			u_Pag033(_cTitulo,_cDesc1,_cDesc2,nHandle,cWorkFlow)
		EndIf	

		cCampos := Replic("-",Limite) + Chr(13) + Chr(10)
		Fwrite(nHandle,cCampos)
		li+=2
		// Quebra de página
		If li > 56
			u_Pag033(_cTitulo,_cDesc1,_cDesc2,nHandle,cWorkFlow)
		EndIf	
		cCampos := ""

		QRY1->(DbSkip())
	EndIf
EndDo

If cWorkFlow == "N"
	If li <> 80
		@ 062,000 PSAY 'Impresso em '+DtoC(DATE())+' as '+TIME()
	EndIf
Else
	If li <> 80
		// Quebra de página
		If li > 56
			u_Pag033(_cTitulo,_cDesc1,_cDesc2,nHandle,cWorkFlow)
		EndIf	
		cCampos += Space(Limite-(Len('Impresso em '+DtoC(DATE())+' às '+TIME())))
		cCampos += 'Impresso em '+DtoC(DATE())+' às '+TIME() + chr(13) + chr(10)
		Fwrite(nHandle,cCampos)
		li++
		// Quebra de página
		If li > 56
			u_Pag033(_cTitulo,_cDesc1,_cDesc2,nHandle,cWorkFlow)
		EndIf	
		cCampos := "Padrões de impressão p/ bloco de notas (NotePad):" + chr(13) + chr(10)
		cCampos += "Fonte Courier - Normal - 10 " + chr(13) + chr(10)
		cCampos += "Papel Carta 21,59 X 27,94cm " + chr(13) + chr(10)
		cCampos += "Margens: Direita 20 , Esquerda 20 , Superior 25 e Inferior 20"
		Fwrite(nHandle,cCampos)
		cCampos := ""
	EndIf
	Fclose(nHandle)
	
EndIf

dbSelectArea("QRY1")
QRY1->(dbCloseArea())
Return(.T.)


/*==========================================================================\
|Programa  |VALIDPERG| Autor | Rafael de Campos Falco  | Data ³ 04/06/2004  |
|===========================================================================|
|Desc.     | Inclui as perguntas caso nao existam                           |
|===========================================================================|
|Sintaxe   | VALIDPERG                                                      |
|===========================================================================|
|Uso       | Especifico DIPROMED                                            |
|===========================================================================|
|Histórico | DD/MM/AA - Descrição da alteração                              |
\==========================================================================*/

Static Function AjustaSX1(cPerg)

Local j
Local i
	
_sAlias := Alias()
dbSelectArea("SX1")
dbSetOrder(1)                                                                                   

aRegs:={}

//------------ Grupo/Ordem/Pergunta/PERGING/PERGESP/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05/F3

AADD(aRegs,{cPerg,"01","De vendedor        ?","","","mv_ch1","C",6,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","",'SA3'})
AADD(aRegs,{cPerg,"02","Ate vendedor       ?","","","mv_ch2","C",6,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","",'SA3'})
aAdd(aRegs,{cPerg,"03","Grupo Clientes     ?","","","mv_ch3","C",6,0,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","",'ACY'})

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

dbSelectArea(_sAlias)
Return

/// FUNÇÃO PARA QUEBRA DE PÁGINA
User Function Pag033(_cTitulo,_cDesc1,_cDesc2,nHandle,cWorkFlow)
	li := u_MYCabec(_cTitulo,_cDesc1,_cDesc2,nHandle,cWorkFlow) + 1
         
	If QRY1->A1_VENDKC == MV_PAR01
		cCampos := Chr(13) + Chr(10) + "Vendedor: " + QRY1->A1_VENDKC + ' - ' + Alltrim(Posicione("SA3",1,xFilial("SA3")+QRY1->A1_VENDKC,"A3_NOME")) + Chr(13) + Chr(10) + Chr(13) + Chr(10)
	ElseIf QRY1->A1_XVENDSP == MV_PAR01
		cCampos := Chr(13) + Chr(10) + "Vendedor: " + QRY1->A1_XVENDSP + ' - ' + Alltrim(Posicione("SA3",1,xFilial("SA3")+QRY1->A1_XVENDSP,"A3_NOME")) + Chr(13) + Chr(10) + Chr(13) + Chr(10)
	Else 
		cCampos := Chr(13) + Chr(10) + "Vendedor: " + If(("0401" $ cWCodEmp+cWCodFil),QRY1->A1_VENDHQ,QRY1->A1_VEND) + ' - ' + AllTrim(QRY1->A3_NOME) + Chr(13) + Chr(10) + Chr(13) + Chr(10)
	Endif
	cCampos += Replic("-",Limite) + Chr(13) + Chr(10)
	Fwrite(nHandle,cCampos)
	li+=2
	cCampos := "Código - Loja - Cliente" + Chr(13) + Chr(10)
	Fwrite(nHandle,cCampos)
	li++
	cCampos := "CNPJ                 IE                    Fone                Fax" + Chr(13) + Chr(10)
	Fwrite(nHandle,cCampos)
	li++
				
	cCampos := "Endereço" + Chr(13) + Chr(10)
	Fwrite(nHandle,cCampos)
	li++
	
	cCampos := "Bairro                             Cidade                                 Estado" + Chr(13) + Chr(10)
	Fwrite(nHandle,cCampos)
	li++
	
	cCampos := "E-Mail                                                               Última Comp" + Chr(13) + Chr(10)
	cCampos += Replic("-",Limite) + Chr(13) + Chr(10)
	Fwrite(nHandle,cCampos)
	li+=2
	                              
	If QRY1->A1_VENDKC == MV_PAR01
		cCodVen := QRY1->A1_VENDKC      
	ElseIf QRY1->A1_XVENDSP == MV_PAR01
		cCodVen := QRY1->A1_XVENDSP      
	Else                          
		cCodVen := If(("0401" $ cWCodEmp+cWCodFil),QRY1->A1_VENDHQ,QRY1->A1_VEND)		
	Endif    
	
	nTotImp := 1
Return

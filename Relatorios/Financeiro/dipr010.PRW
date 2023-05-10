/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Funcao    ³ DIPR010  ³ Autor ³ Rodrigo Franco     ³ Data ³ 31.01.2002  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Emissao da Ordem de Pagamento                              ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
#include "rwmake.ch"

User Function DIPR010()

//³ Define Variaveis                                             ³
Local wnrel     := "DIPR010"
LOCAL tamanho	:="P"
LOCAL titulo	:="Emissao da Ordem de Pagamento"
LOCAL cDesc1	:="Emissao da Ordem de Pagamento,de acordo com"
LOCAL cDesc2	:="intervalo informado na opcao do Parametros."
LOCAL cDesc3	:=" "
LOCAL nRegistro	:= 0
LOCAL cKey,nIndex,cIndex  //&& Variaveis para a criacao de Indices Temp.
LOCAL cCondicao

// FPADR(cPerg, cArq, cCampo, cTipo)  - Para ajustar o tamanho das perguntas no SX1- uso generico
Private cPerg  	:= U_FPADR( "ORDPA2","SX1","SX1->X1_GRUPO"," " ) //Função criada por Sandro em 19/11/09.

Private aReturn 	:= { "Zebrado", 1,"Administracao", 2, 2, 1, "",0 }
Private nomeprog	:="DIPR010",nLastKey := 0,nBegin:=0,aLinha:={ }
Private li:=90,limite:=220,lRodape:=.F.,cPictQtd:=""
Private nTotQtd		:=nTotVal:=0
Private aPedCli		:= {}
Private nNItem 		:= 0

cString := "SE2"

U_DIPPROC(ProcName(0),U_DipUsr()) // JBS 05/10/2005 - Gravando o nome do Programa no SZU
         
AjustaSX1(cPerg)                    

pergunte(cPerg,.T.) // Verifica as perguntas selecionadas

/////////////////////////////////////////////////////////////////
//³ Variaveis utilizadas para parametros		                ³
//³ mv_par01	     	  Do Titulo			                    ³
//³ mv_par02	     	  Ate o Titulo			                ³
//³ mv_par03	     	  Prefixo           	                ³
//³ mv_par04	     	  Data de digitação   	                ³
//³ mv_par05	     	  Quem digitou       	                ³
//³ mv_par06	     	  Imprime baixados?    	                ³
/////////////////////////////////////////////////////////////////

wnrel:=SetPrint(cString,wnrel,cPerg,@Titulo,cDesc1,cDesc2,cDesc3,.F.,,,Tamanho)

If nLastKey==27
	Set Filter to
	Return( NIL )
Endif

SetDefault(aReturn,cString)

If nLastKey==27
	Set Filter to
	Return( NIL )
Endif

RptStatus({|lEnd| C730Imp(@lEnd,wnRel,cString)},Titulo)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Fun‡…o    ³ C730IMP  ³ Autor ³ Rodrigo Franco      ³ Data ³ 31.01.2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Chamada do Relatorio                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Emissao da Ordem de Pagamento                              ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function C730Imp(lEnd,WnRel,cString)

//³ Faz manualmente porque nao chama a funcao Cabec()                 ³
@ 0,0 psay AvalImp(Limite)

DbSelectArea("SE2")
DbSetOrder(1)
DbSeek(xFilial("SE2")+mv_par03+mv_par01,.T.)

li := 1
Pg := 1

While !Eof() .And. E2_NUM <= mv_par02 .AND. E2_PREFIXO == mv_par03
	
	IF AllTrim(Upper(SE2->E2_USUARIO))!=AllTrim(Upper(mv_par05))                           
		DbSkip()
		Loop
	Endif 
		
	IF !Empty(mv_par04)
		IF SE2->E2_EMIS1 != mv_par04
			DbSkip()
			Loop
		EndIF
	EndIF
		
	IF MV_PAR06 == 2   // Não imprime ordem de pagamento de titulo totalmente baixado
		
		IF SE2->E2_SALDO <= 0 
			DbSkip()
			Loop
		ENDIF 
		
	EndIF
	
	IF Pg == 3
		li := 1
		Pg := 1
	EndIF
	
	DbSelectArea("SA2")
	DbSetOrder(1)
	DbSeek(xFilial("SA2")+SE2->E2_FORNECE+SE2->E2_LOJA)
		
	ImpCabec()
	
	Pg := Pg + 1
	
	DbSelectArea("SE2")
	DbSkip()
	
EndDo

IF aReturn[5] = 1
	
	Set Printer To
	dbCommitAll()
	OurSpool(wnrel)
	
EndIF

MS_FLUSH()

Return


//////////////////////////////////////////////////////////////////////////////////////////////////////////
Static Function AjustaSX1(cPerg)

_sAlias := Alias()
dbSelectArea("SX1")
dbSetOrder(1)

aRegs:={}

//------------ Grupo/Ordem/Pergunta/PERGING/PERGESP/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05/F3

aADD(aRegs,{cPerg,"01","Do Titulo         ","","","mv_ch1","C", 9, 0, 0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","",""})
aADD(aRegs,{cPerg,"02","Ate Titulo        ","","","mv_ch2","C", 9, 0, 0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"03","Prefixo           ","","","mv_ch3","C", 3, 0, 0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"04","Data Digitacao    ","","","mv_ch4","D", 8, 0, 0,"G","","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","",""})
aADD(aRegs,{cPerg,"05","Quem Digitou     ?","","","mv_ch5","C",15, 0, 0,"G","","mv_par05","","","","","","","","","","","","","","","","","","","","","","","","",""})
aADD(aRegs,{cPerg,"06","Imprime Baixados ?","","","mv_ch6","N", 1, 0, 0,"C","","mv_par06","SIM","","","","","NAO","","","","","","","","","","","","","","","","","","","",""})

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
////////////////////////////////////////////////////////////////////////////////////////////////////////


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Fun‡…o    ³ ImpCabec ³ Autor ³ Rodrigo Franco      ³ Data ³ 31.01.2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Emissao da Ordem de Pagamento                              ³±±
ßßßßßßßßß
*/
Static Function ImpCabec()

@ li,000 psay CHR(18)
li++
@ li,000 psay Replicate("-",80)
li++
@ li,000 psay SE2->E2_FILORIG
@ li,025 psay ALLTRIM(SM0->M0_NOMECOM)+if(cEmpAnt+cFilAnt=='0404','(CD)','') //"DIPROMED COMERCIO E IMPORTACAO LTDA."   MCVN - 19/11/2008
li++
@ li,000 psay Replicate("-",80)
li++
@ li,000 psay nomeprog
@ li,029 psay "*** ORDEM DE PAGAMENTO ***"
li++
@ li,000 psay Replicate("-",80)
li := li + 2
@ li,000 psay "Fornecedor: " + SE2->E2_FORNECE + " - " + SA2->A2_NOME
li := li + 2
@ li,000 psay Replicate("-",80)
li++
@ li,000 psay "PREFIXO: " + SE2->E2_PREFIXO
@ li,040 psay "NOTA FISCAL: " + SE2->E2_NUM +" " +SE2->E2_PARCELA
li := li + 2
@ li,000 psay "LANCADO EM: " + DTOC(SE2->E2_EMIS1)
@ li,040 psay "EMISSAO: " + DTOC(SE2->E2_EMISSAO)
li := li + 2
@ li,000 psay "VENCIMENTO: " + DTOC(SE2->E2_VENCREA)
@ li,040 psay "VALOR (R$): "
@ li,051 psay SE2->E2_VALOR picture "@E 99,999,999.99"
li := li + 2
@ li,000 psay "Observacao: " + SE2->E2_HIST
li := li + 1
@ li,000 psay AllTrim(SE2->E2_NATUREZ) +' - '+ POSICIONE("SED",1,xFILIAL("SED")+SE2->E2_NATUREZ,"ED_DESCRIC")
li := li + 5
@ li,000 psay "_________  "+Subs(SE2->E2_USUARIO,1,13)+"  _____________  __________  ___________  ______________"   //_____________
li++
If ("HEALTH" $ SM0->M0_NOMECOM) // MCVN - 20/08/09
	@ li,000 psay " COMPRAS   LANCADO POR    CONTABILIDADE   DIR.IND.    DIR. ADM.   CONTAS A PAGAR"
Else
	@ li,000 psay " COMPRAS   LANCADO POR    CONTABILIDADE   GERENCIA    DIRETORIA   CONTAS A PAGAR"
Endif

If Pg == 1
	li := li + 16
endif

Return

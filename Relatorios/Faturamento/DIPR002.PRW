#include "rwmake.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Funcao    ³ DIPR002  ³ Autor ³ Rodrigo Franco     ³ Data ³ 14.02.2002  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Relatorio de Liberação de Senha                            ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function DIPR002()

//³ Define Variaveis                                             ³
LOCAL wnrel
LOCAL tamanho:="P"
LOCAL titulo:="Relatorio de Liberação de Senha"
LOCAL cDesc1:="Relatorio de Liberação de Senha,de acordo com"
LOCAL cDesc2:="intervalo informado na opcao do Parametros."
LOCAL cDesc3:=" "
LOCAL nRegistro:= 0
LOCAL cKey,nIndex,cIndex  //&& Variaveis para a criacao de Indices Temp.
LOCAL cCondicao

//PRIVATE cPerg 	 := "RSENHA"      
// FPADR(cPerg, cArq, cCampo, cTipo)
PRIVATE cPerg  	:= U_FPADR( "RSENHA","SX1","SX1->X1_GRUPO"," " ) //Criado por Sandro em 19/11/09. 

PRIVATE aReturn  := { "Zebrado", 1,"Administracao", 2, 2, 1, "",0 }
PRIVATE nomeprog := "DIPR002",nLastKey := 0,nBegin:=0,aLinha:={ }
PRIVATE li:=90,limite:=220,lRodape:=.F.,cPictQtd:=""
PRIVATE nTotQtd:=nTotVal:=0
PRIVATE aPedCli:= {}
Private PG := 0
PRIVATE nNItem := 0 

wnrel    := "DIR002"
cString  := "SC5"


U_DIPPROC(ProcName(0),U_DipUsr()) // JBS 05/10/2005 - Gravando o nome do Programa no SZU
//³ Verifica as perguntas selecionadas                          ³

pergunte(cPerg,.F.)

//³ Variaveis utilizadas para parametros		                ³
//³ mv_par01	     	  Da Data			                    ³
//³ mv_par02	     	  Ate a Data			                ³
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
RptStatus({|lEnd| DIPR02I(@lEnd,wnRel,cString)},Titulo)
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Fun‡…o    ³ DIPR02I  ³ Autor ³ Rodrigo Franco      ³ Data ³ 31.01.2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Chamada do Relatorio                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Relatorio de Liberação de Senha                            ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function DIPR02I(lEnd,WnRel,cString)

//³ Define Variaveis                                             ³
LOCAL tamanho:= "P"
LOCAL titulo:="Relatorio de Liberação de Senha"
LOCAL cDesc1:="Relatorio de Liberação de Senha,de acordo com"
LOCAL cDesc2:="intervalo informado na opcao do Parametros."
LOCAL cDesc3:=" "
LOCAL nRegistro:= 0
LOCAL cKey,nIndex,cIndex  && Variaveis para a criacao de Indices Temp.
LOCAL cCondicao

pergunte(cPerg, .F.)

//³ Faz manualmente porque nao chama a funcao Cabec()                 ³
@ 0,0 psay AvalImp(Limite)
DbSelectArea("SC5")
DbSetOrder(2)

IF DbSeek(xFilial("SC5")+Dtos(mv_par01),.t.)
	While !Eof() .And. SC5->C5_EMISSAO <= mv_par02
		IF !EMPTY(SC5->C5_SENHPAG) .OR. !EMPTY(SC5->C5_SENHMAR) .OR. !EMPTY(SC5->C5_SENHCID)
			_cNumPed := SC5->C5_NUM
			_cDtEmis := SC5->C5_EMISSAO
			_cSenMar := SC5->C5_SENHMAR
			_cSenPag := SC5->C5_SENHPAG
			_cSenCid := SC5->C5_SENHCID
			ImpCabec()
		ENDIF
		DBSELECTAREA("SC5")
		DBSKIP()
	Enddo
ENDIF
If aReturn[5] = 1
	Set Printer To
	dbCommitAll()
	OurSpool(wnrel)
Endif
MS_FLUSH()

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Fun‡…o    ³ ImpCabec ³ Autor ³ Rodrigo Franco      ³ Data ³ 31.01.2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Relatorio de Liberação de Senha                            ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ImpCabec()

IF li > 60
	li := 0

	@ li,000 psay CHR(18)
	li++
	@ li,000 psay Replicate("-",80)
	li++
	@ li,024 psay "DIPROMED COMERCIO E IMPORTACAO LTDA."
	li++
	@ li,000 psay Replicate("-",80)
	li++
	@ li,023 psay "*** Relatorio de Liberação de Senha ***"
	li++
	@ li,000 psay Replicate("-",80)
	li++
	@ li,027 psay "Da data: " + dtoc(mv_par01) + " Ate " + dtoc(mv_par02)
	li++
	@ li,000 psay Replicate("-",80)
	li := li + 1
	@ li,000 psay Replicate("-",80)
	li++
	@ li,000 psay "                 |              Senhas              | "
	li++
	@ li,000 psay "Pedido | Data    | Margem    | Cond.Pagt | Regioes  | "
	li++
	@ li,000 psay Replicate("-",80)
	li++
Endif
li++
@ li,000 psay _cNumPed + "  " + DTOC(_cDtEmis) + "  " + _cSenMar + "  " + _cSenPag + "  " + _cSenCid
Pg := Pg + 1

Return
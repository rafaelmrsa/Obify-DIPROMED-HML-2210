/*====================================================================================\
|Programa  | DIPR082     | Autor | Reginaldo Borges            | Data | 23/04/2015    |
|=====================================================================================|
|Descrição | Juros recebidos dentro do período informado pelo usuário.                |
|=====================================================================================|
|Sintaxe   | DIPR082                                                                  |
|=====================================================================================|
|Uso       | Especifico Departamento Financeiro                                       |
|=====================================================================================|
|........................................Histórico....................................|
|          | 																		  |
|          | 																		  |
\====================================================================================*/

#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"

User Function DIPR082()

Local titulo      := OemTOAnsi("Relatorio dos Juros Recebidos",72)
Local cDesc1      := (OemToAnsi("Este programa tem como objetivo emitir um relat¢rio",72))
Local cDesc2      := (OemToAnsi("com a relação do total dos juros recebidos.",72))
Local cDesc3      := (OemToAnsi("Conforme parametros definidos.",72))
Private aReturn   := {"Bco A4", 1,"Administracao", 1, 2, 1,"",1}
Private li        := 67
Private tamanho   := "P"
Private limite    := 80
Private nomeprog  := "DIPR082"
Private cPerg  	:= U_FPADR( "DIPR082","SX1","SX1->X1_GRUPO"," " )
Private nLastKey  := 0
Private lEnd      := .F.
Private wnrel     := "DIPR082"
Private cString   := "SE5"
Private m_pag     := 1

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

/*==========================================================================\
| Se em disco, desvia para Spool                                            |
\==========================================================================*/
If aReturn[5] == 1    // Se Saida para disco, ativa SPOOL
	Set Printer TO
	Commit
	ourspool(wnrel)
Endif
	
Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³RODAREL() ºAutor  ³Reginaldo Borges    º Data ³  23/04/15   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Processar e gerar o relatório conforme os dados            º±±
±±º          ³ informados pelo operador.                                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function RodaRel()

Local cSQL 	    := ""
Private _cTitulo:= "Juros Recebidos de "+DTOC(MV_PAR01)+" - "+DTOC(MV_PAR02)
Private _cDesc1 := " Total Geral"
Private _cDesc2 := ""

cSQL := " SELECT "
cSQL += " 	SUM(E5_VALOR) AS JUROS "
cSQL += " 	FROM "+RetSQLName("SE5")
cSQL += " 		WHERE "
cSQL += " 			E5_FILIAL = '"+xFilial("SE5")+"' AND"
cSQL += " 			E5_DATA BETWEEN '"+DtoS(MV_PAR01)+"' AND '"+DtoS(MV_PAR02)+"'AND"
cSQL += " 	        E5_TIPODOC IN ('JR','MT') AND"
cSQL += " 			E5_RECPAG = 'R' AND"
cSQL += " 			D_E_L_E_T_ = ' ' "

cSQL := ChangeQuery(cSQL)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),"TRB",.T.,.F.)

DbSelectArea("TRB")

Do	While TRB->(!Eof())

	If lAbortPrint
		@ li+1,00 PSAY "*** CANCELADO PELO OPERADOR ***"
		Exit
	Endif

	If li > 56  
		li := Cabec(_cTitulo,_cDesc1,_cDesc2,nomeprog,tamanho)
	EndIf
        
		li++
					
		@ li,001 PSay ALLTRIM(TRANSFORM(TRB->JUROS,'@E 999,999,999.99'))

	TRB->(dbSkip())

EndDo

TRB->(dbCLoseArea())

Return


/*==========================================================================\
|Programa  |AjustaSX1| Autor | Reginaldo Borges        | Data ³ 23/04/15    |
|===========================================================================|
|Desc.     | Inclui as perguntas caso nao existam                           |
|===========================================================================|
|Sintaxe   | AjustaSX1                                                      |
|===========================================================================|
|Uso       | Especifico DIPROMED                                            |
|===========================================================================|
|Histórico | DD/MM/AA - Descrição da alteração                              |
\==========================================================================*/

*--------------------------------------------------*                       
Static Function AjustaSX1(cPerg)                   
*--------------------------------------------------*
Local aRegs :={}
dbSetOrder(1)

AADD(aRegs,{cPerg,"01","Periodo de  ?","","","mv_ch1","D",8,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","",""})
AADD(aRegs,{cPerg,"02","Periodo ate ?","","","mv_ch2","D",8,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","",""})

For i:=1 to Len(aRegs)
    If !dbSeek(cPerg+aRegs[i,2])
        RecLock("SX1",.T.)
        For j:=1 to FCount()
            If j <= Len(aRegs[i])
                FieldPut(j,aRegs[i,j])
            Endif
        Next
        MsUnlock("SX1")
    Endif
Next     

Return(.T.)


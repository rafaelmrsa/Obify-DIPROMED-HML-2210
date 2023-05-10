#include "rwmake.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³NOVO2     ºAutor: Anderson Crepaldi    º Data ³  08/01/02   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³  Migracao do cadastro de Clientes para o Cadastro de       º±±
±±º          ³  contatos e relacionamento na tabela AC8                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP6                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function DM_SU5()
U_DIPPROC(ProcName(0),U_DipUsr()) // JBS 05/10/2005 - Gravando o nome do Programa no SZU
Processa( {|| DM_contato() },"Processando a migracao ..." )
Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CONTAT    ºAutor  ³Microsiga           º Data ³  09/02/02   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP6                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function DM_contato()

dbSelectArea("SA1")
dbSetOrder(1)
DbGoTop()

//Dbselectarea("SUS")
//dbsetorder(1)

ProcRegua(RecCount())

While !Eof() .and. SA1->A1_FILIAL == xFilial("SA1")
	IncProc("Cliente" + STR(SA1->(Recno())))
	If Empty(AllTrim(SA1->A1_CONTATO))
		DbSkip()
		Loop
	Endif
	
	cRetorno:=GetSX8Num("SU5","U5_CODCONT")
	Confirmsx8()
	
	dbSelectArea("SU5")
	
	RecLock("SU5",.T.)
	SU5->U5_FILIAL	:= xFilial("SU5")
	SU5->U5_CODCONT	:= cRetorno
	SU5->U5_CONTAT	:= AllTrim(SA1->A1_CONTATO)
	SU5->U5_FCOM1	:= SA1->A1_TEL
	SU5->U5_EMAIL	:= SA1->A1_EMAIL
	SU5->U5_NOMECLI	:= SA1->A1_NOME
	MsUnlock()
	
	dbSelectArea("AC8")
	RecLock("AC8",.T.)
	AC8->AC8_FILIAL  := xFILIAL("AC8")
	AC8->AC8_ENTIDAD := "SA1"
	AC8_CODENT       := SA1->A1_COD+SA1->A1_LOJA
	AC8->AC8_CODCON  := cRetorno
	MsUnlock()
	
	DbSelectArea("SA1")
	Dbskip()
EndDo

dbSelectArea("SUS")
dbSetOrder(1)
DbGoTop()

//Dbselectarea("SUS")
//dbsetorder(1)

ProcRegua(RecCount())

While !Eof() .and. SUS->US_FILIAL == xFilial("SUS")
	IncProc("Prospect " + STR(Recno()))
	If Empty(AllTrim(SUS->US_CONTATO))
		DbSkip()
		Loop
	Endif
	
	cRetorno:=GetSX8Num("SU5","U5_CODCONT")
	Confirmsx8()
	
	dbSelectArea("SU5")
	
	RecLock("SU5",.T.)
	SU5->U5_FILIAL	:= xFilial("SU5")
	SU5->U5_CODCONT	:= cRetorno
	SU5->U5_CONTAT	:= AllTrim(SUS->US_CONTATO)
	SU5->U5_FCOM1	:= SUS->US_TEL
	SU5->U5_EMAIL	:= SUS->US_EMAIL
	SU5->U5_PROSP	:= SUS->US_NOME
	MsUnlock()
	
	dbSelectArea("AC8")
	RecLock("AC8",.T.)
	AC8->AC8_FILIAL		:= xFILIAL("AC8")
	AC8->AC8_ENTIDAD	:= "SUS"
	AC8->AC8_CODENT		:= SUS->(US_COD+US_LOJA)
	AC8->AC8_CODCON		:= cRetorno
	MsUnlock()
	
	DbSelectArea("SUS")
	Dbskip()
EndDo

Return

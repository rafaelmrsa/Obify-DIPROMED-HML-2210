#include "rwmake.ch"


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³NOVO3     ºAutor  ³Anderson Crepaldi   º Data ³  10/03/02   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP6                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function SaldProd()
U_DIPPROC(ProcName(0),U_DipUsr()) // JBS 05/10/2005 - Gravando o nome do Programa no SZU
DbselectArea("SB2")
Dbsetorder(1)

Dbseek(xFilial("SB2")+ SB1->B1_COD+SB1->B1_LOCPAD)

If found()
	MsgBox(;
	"Estoque....:"+Transform(SB2->B2_QATU,"@E 9,999,999.99")+chr(13)+chr(10)+;
	"Reserva....:"+Transform(SB2->B2_RESERVA,"@E 9,999,999.99")+chr(13)+chr(10)+;
	"a Enderecar:"+Transform(SB2->B2_QACLASS,"@E 9,999,999.99")+chr(13)+chr(10)+;
	"DISPONIVEL.:"+Transform(SB2->(B2_QATU - B2_RESERVA - B2_QACLASS),"@E 9,999,999.99")+chr(13)+chr(10)+chr(13)+chr(10)+;
	"Saldos.....:"+Transform(SB2->B2_QPEDVEN,"@E 9,999,999.99")+chr(13)+chr(10)+;
	"a Entrar...:"+Transform(SB2->B2_SALPEDI,"@E 9,999,999.99")+chr(13)+chr(10);
	,"Produto: "+AllTrim(SB2->B2_COD)+"-"+SB1->B1_DESC,"INFO")
EndIf

Return(SB2->B2_COD)


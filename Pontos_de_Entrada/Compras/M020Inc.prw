#include "PROTHEUS.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ M020Inc  º Autor ³ Maximo Canuto      º Data ³ 12/11/2008  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Faz chamada para função de gravacao do kardex na inclusão  º±±
±±º          ³ de fornecedores                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ ESPECIFICO DIPROMED                                        º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function M020Inc()
Local _areaSA2 := SA2->(getarea())
Local cCompr   := ""
Local dData    := Date() 
Local _cUsuar  := Upper(U_DipUsr())

U_DIPPROC(ProcName(0),U_DipUsr()) // RBORGES 12/09/18 
U_GravaZG("SA2") // Gravando inclusão de fornecedores

If cEmpAnt <> "04" .And. "P211101" $ M->A2_NATUREZ
 	cCompr   := AllTrim(M->A2_COMPRA)+" - "+Posicione("SY1",1,xFilial("SY1")+M->A2_COMPRA,"Y1_NOME")
 	cNaturez := AllTrim(M->A2_NATUREZ)+" - "+Posicione("SED",1,xFilial("SED")+M->A2_NATUREZ,"ED_DESCRIC")
	FORMAIL(M->A2_COD, M->A2_NOME, cCompr, dData, cNaturez, _cUsuar) //Chamada da função que dispara o e-mail
EndIf
	            
RestArea(_areaSA2)
Return(.T.)

/*
+--------------------------------------------------------------------+
|RBORGES - 12/09/2018                                                |
+--------------------------------------------------------------------+ 
|Funcao para dispar o E-mail         						         |
+--------------------------------------------------------------------+
*/

*--------------------------------------------------------------------------*
Static Function FORMAIL(cCodFor, cNomFor, cCompr, dData, cNaturez, _cUsuar)
*--------------------------------------------------------------------------*

Local cDeIc       := "protheus@dipromed.com.br"
Local cEmailIc    := GetNewPar("ES_M020EMA","qualidade@dipromed.com.br,reginaldo.borges@dipromed.com.br")  //Usuários que receberão e-mails
Local cAssuntoIc  := EncodeUTF8("AVISO - INCLUSÃO DO NOVO FORNECEDOR, "+AllTrim(cCodFor)+ "! ","cp1252")
Local cAttachIc   :=  "  a"
Local cFuncSentIc :=   "M020INC"

_aMsgIc := {}

aAdd( _aMsgIc , { "FORNECEDOR ", +cCodFor+" - "+cNomFor})
aAdd( _aMsgIc , { "COMPRADOR       ", +cCompr})
aAdd( _aMsgIc , { "NATUREZA        ", +cNaturez})
aAdd( _aMsgIc , { "USUARIO         ", +_cUsuar})
aAdd( _aMsgIc , { "DATA            ", +DTOC(dData)})


If GetNewPar("ES_ATIVJOB",.T.)
	U_UEnvMail(cEmailIc,cAssuntoIc,_aMsgIc,cAttachIc,cDeIc,cFuncSentIc)
EndIf

Return()  
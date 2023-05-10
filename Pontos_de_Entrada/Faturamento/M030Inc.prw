#include "PROTHEUS.CH"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � M030Inc  � Autor � CONSULTORIA        � Data � 23/01/2008  ���
�������������������������������������������������������������������������͹��
���Descricao � Faz chamada para fun��o de gravacao do kardex na Inclusao  ���
���          � de clientes                                                ���
�������������������������������������������������������������������������͹��
���Uso       � ESPECIFICO DIPROMED                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
User Function M030Inc()                            

Local _cCliente := M->A1_COD   
Local _cNomeCli := M->A1_NOME
Local _cUsuar   := Upper(U_DipUsr())

U_DIPPROC(ProcName(0),U_DipUsr()) // MCVN - 22/01/2009

If Paramixb <> 3
 	U_GravaZG("SA1")
 	
 	If cEmpAnt <> "04"  
 		M030CIC(_cCliente,_cNomeCli,_cUsuar)   //Dispara um CIC ao incluir um cliente
 		M030EMAIL(_cCliente,_cNomeCli,_cUsuar) //Dispara um E-mail ao incluir um cliente
	EndIf
	
EndIf	

_cCliente := ""   
_cNomeCli := ""
_cUsuar   := ""

Return

/*-------------------------------------------------------------------------
+ RBORGES - 17/11/2017 ----- User Funcion:  M030CIC()                     +
+ Enviar� CIC quando for incluso um cliente novo                          +
-------------------------------------------------------------------------*/

*--------------------------------------------------------------------------*
Static Function M030CIC(_cCliente,_cNomeCli,_cUsuar)
*--------------------------------------------------------------------------*

Local aArea       := GetArea()
Local cDeIc       := "protheus@dipromed.com.br"
Local cCICDest    := Upper(GetNewPar("ES_M030CIC","REGINALDO.BORGES")) // Usu�rios que receber�o CIC�s
Local cAttachIc   :=  "  a"

_aMsgIc := {}
cMSGcIC       := " AVISO - INCLUS�O DE NOVO CLIENTE" +CHR(13)+CHR(10)+CHR(13)+CHR(10)+CHR(13)+CHR(10)
cMSGcIC       += " CLIENTE :"+_cCliente+"" +CHR(13)+CHR(10)
cMSGcIC       += " NOME : "+_cNomeCli+""    +CHR(13)+CHR(10)
cMSGcIC       += " OPERADOR(A): "+_cUsuar

 U_DIPCIC(cMSGcIC,cCICDest)

RestArea(aArea)
return()

/*-----------------------------------------------------------------------------
+ RBORGES Data: 17/11/2017 Fun��o: M030EMAIL()                                +
+ Essa fun��o enviar� e-mail para os usu�rios contidos no par�metro,          +
+ quando for incluso um novo cliente.                                         +
-----------------------------------------------------------------------------*/
*--------------------------------------------------------------------------*
Static Function M030EMAIL(_cCliente,_cNomeCli,_cUsuar)
*--------------------------------------------------------------------------*

Local cDeIc       := "protheus@dipromed.com.br"
Local cEmailIc    := GetNewPar("ES_M030EMA","reginaldo.borges@dipromed.com.br")  //Usu�rios que receber�o e-mails
Local cAssuntoIc  := EncodeUTF8("AVISO - INCLUS�O DO NOVO CLIENTE, " +_cCliente+ "! ","cp1252")
Local cAttachIc   :=  "  a"
Local cFuncSentIc :=   "M030INC.PRW"

_aMsgIc := {}
cMSGcIC       := cAssuntoIc+" - "+_cCliente+ " " +CHR(13)+CHR(10)+CHR(13)+CHR(10)

aAdd( _aMsgIc , { "CLIENTE  ", +_cCliente})
aAdd( _aMsgIc , { "NOME     ", +_cNomeCli})
aAdd( _aMsgIc , { "INLCUIDO POR ", +_cUsuar})


U_UEnvMail(cEmailIc,cAssuntoIc,_aMsgIc,cAttachIc,cDeIc,cFuncSentIc)

return()  

/*====================================================================================\
|PROGRAMA  | DIPG014    | AUTOR | ERIBERTO ELIAS               | DATA |  08/06/2003   |
|=====================================================================================|
|DESCRIçãO | GATILHO PARA MOSTRAR INFORMACOES DO CLIENTE NOS ATENDIMENTO              |       
|          | E NOS PEDIDOS                                                            |
|=====================================================================================|
|OBJETIVO  | CARREGAR NA TABELA SYP OS CAMPOS MEMO.GERAR NA TABELA SA1 A CHAVE PARA OS|
|          | RESPECTIVOS CAMPOS MEMO.                                                 |
|=====================================================================================|
|SINTAXE   | DIPG014()                                                                |
|=====================================================================================|
|USO       | ESPECIFICO DIPROMED                                                      |
|=====================================================================================|
|HISTóRICO | 10 AGO 2005 - PROGRAMADO PARA CARREGAR O CAMPO MEMO A1_INFOICLM A PARTIR |
|          |               DO CONTEUDO NA TABELA SYP.                                 |
\====================================================================================*/
#INCLUDE "RWMAKE.CH"

USER FUNCTION DIPG014()
LOCAL _XALIAS  := GETAREA()
LOCAL MINFOCLI

U_DIPPROC(ProcName(0),U_DipUsr()) // MCVN - 22/01/2009

IF (TYPE("L410AUTO") == "U" .OR. !L410AUTO)
	
	IF !EMPTY(SA1->A1_INFOCLM)
		MINFOCLI := MSMM(SA1->A1_INFOCLM,,,,3) // JBS 09/08/2005
		IF LEN(ALLTRIM(MINFOCLI))<>0
			MSGBOX(MINFOCLI,"CLIENTE: "+SA1->A1_NOME,'INFO')// JBS 09/08/2005
		ENDIF
	ENDIF
	
	RESTAREA(_XALIAS)
	
ENDIF

RETURN(SA1->A1_COD)

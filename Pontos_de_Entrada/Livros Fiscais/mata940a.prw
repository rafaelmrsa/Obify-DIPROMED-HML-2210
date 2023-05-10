/*
PONTO.......: MATA940A          PROGRAMA....: MATA940
DESCRIÇÄO...: TRATA CASOS PARTICULARES
UTILIZAÇÄO..: Este P.E. se encontra na funcao A940Processa(). E chamado
              antes do programa gravar o arquivo pre-formatado (A940Grava()). Seu
              Objetivo e tratar eventuais casos particulares.

PARAMETROS..: UPAR do tipo X : Nenhum.

RETORNO.....: URET do tipo X : Nenhum.

OBSERVAÇÖES.: <NENHUM>
*/
/*====================================================================================\
|Programa  | MATA940A      | Autor | Eriberto Elias             | Data | 13/08/2004   |
|=====================================================================================|
|Descrição | Vamos colocar as notas que faltam como canceladas                        |
|=====================================================================================|
|Sintaxe   | MATA940A                                                                 |
|=====================================================================================|
|Uso       | Especifico DIPROMED                                                      |
|=====================================================================================|
|........................................Histórico....................................|
|Rafael    | DD/MM/AA - Descrição                                                     |
|Eriberto  | DD/MM/AA - Descrição                                                     |
\====================================================================================*/

User Function A940EFS(aOQVEM)
/*
Local _xArea    := GetArea()
Local _xAreaSF3 := SF3->(GetArea())
Local aNotasqFalta := {}
Local cSerie
Local cNota

U_DIPPROC(ProcName(0),U_DipUsr()) // JBS 05/10/2005 - Gravando o nome do Programa no SZU

QRY1 := "SELECT F3_FILIAL, F3_NFISCAL, F3_SERIE, F3_ENTRADA, F3_TIPO, F3_FORMUL"
QRY1 += " FROM " + RetSQLName("SF3")
QRY1 += " WHERE "
QRY1 += RetSQLName('SF3')+".D_E_L_E_T_ = ' ' and "
QRY1 += RetSQLName('SF3')+".F3_FILIAL = '"+xFilial('SF3')+"' and ("
QRY1 += RetSQLName('SF3')+".F3_CFO >= '5000' OR "+RetSQLName('SF3')+".F3_FORMUL = 'S') and "
QRY1 += RetSQLName('SF3')+".F3_ENTRADA BETWEEN '"+DTOS(mv_par01)+"' and '"+DTOS(mv_par02)+"' "
QRY1 += "order by F3_SERIE, F3_NFISCAL"

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
DbCommitAll()
TcQuery QRY1 NEW ALIAS "QRY1"         // Abre uma workarea com o resultado da query

DbSelectArea("QRY1")
QRY1->(dbGotop())

Do While QRY1->(!EOF())
	cSerie := QRY1->F3_SERIE
	cNota := QRY->F3_NFISCAL
	QRY1->(DbSkip())
	Do While QRY1->F3_SERIE == cSerie
	
		If Val(QRY1->F3_NFISCAL) != Val(cNota)+1
			AaDd(aNotasqFalta,cSerie,cNota)
   	EndIf //Val(QRY1->F3_NFISCAL) != Val(cNota)+1
		cNota := StrZero(Val(cNota)+1,6)
		QRY1->(DbSkip())
	EndDo //QRY1->F3_SERIE == cSerie
EndDo //QRY1->(!EOF())

// msginfo("vamos olhar o array")

QRY1->(DbCloseArea())

RestArea(_xAreaSF3)
RestArea(_xArea)
*/
Return

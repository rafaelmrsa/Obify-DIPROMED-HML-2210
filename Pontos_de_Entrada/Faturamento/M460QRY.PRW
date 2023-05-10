/*
PONTO.......: M460QRY           PROGRAMA....: MATA460
DESCRIÇÄO...: ANTES DA MONTAGEM DA MARKBROWSE
UTILIZAÇÄO..: Antes da montagem da Markbrowse. Deve-se utilizar
juntamente com o ponto M460FIL, pois possuem a mesma funcionalidade.

Apesar de pode-se alterar a query passada como parametro, isto nao deve
ser efetuado em hipotese alguma, deve-se apenas adicionar elementos a
clausula 'Where' conforme eh feito no MT460FIL.
Este ponto de entrada somente eh executada para a versao Top Connect.

PARAMETROS..: UPAR do tipo X : ParamIXB[1] : Expressao da Query a ser
executada no banco.
ParamIxb[2] : Codigo da Query a ser executada.                           
                                                                         
RETORNO.....: URET do tipo X : ExpC1: Expressao da Query a ser executada 
no Banco.                                                                
OBSERVAÇÖES.: <NENHUM>                                                   
*/                                                                         
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Programa  ³ M460QRY  ³ Autor ³ Eriberto Elias        ³ Data ³ 24/11/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ PONTO DE ENTRADA PARA FILTRAR PEDIDOS PARCIAIS             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ DIPROMED                                                   ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
#include "rwmake.ch"

User Function M460QRY()

U_DIPPROC(ProcName(0),U_DipUsr()) // JBS 05/10/2005 - Gravando o nome do Programa no SZU

paramixb[1] += " and C9_BLEST = '  ' and C9_BLCRED = '  ' and C9_BLCRED2 = '  ' and C9_PARCIAL = ' ' and (C9_QTDLIB > 0)" // OR SC5.C5_TIPO <> "N")'
// para inventario - paramixb[1] := paramixb[1]
//  EFIL460  := 'SC9->C9_BLEST=="  ".And.C9_BLCRED=="  ".And. C9_BLCRED2=="  " .And.C9_PARCIAL ==" ".And (C9_QTDLIB > 0.or.C5_TIPO <> "N")'
Return(paramixb[1])

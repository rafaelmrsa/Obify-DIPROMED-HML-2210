#include "rwmake.ch"
/*
Este ponto de entrada pertence ‡ rotina de pedidos de venda, MATA410(). 
Usado, em conjunto com o ponto MA410LEG, para alterar cores do ìbrowseî
do cadastro, que representam o ìstatusî do pedido. 
*/
/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±∫Programa ≥MA410COR  ∫ Autor ≥   Maximo Canuto  ∫ Data ≥  19/06/2009      ∫±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
User Function MA410COR()

U_DIPPROC(ProcName(0),U_DipUsr()) // JBS 05/10/2005 - Gravando o nome do Programa no SZU

_aCores := PARAMIXB
aCores := {} 

acores := {{'C5_PRENOTA = "O" .AND. Empty(C5_PARCIAL) .AND. Empty(C5_NOTA).And. Empty(C5_BLQ)','BR_BRANCO'}  ,;
{'C5_PRENOTA = "F" .AND. !Empty(C5_PARCIAL) .AND. Empty(C5_NOTA).And. Empty(C5_BLQ)' ,'BR_BRANCO'},;
{'Empty(C5_PRENOTA) .AND. !Empty(C5_PARCIAL) .AND. Empty(C5_NOTA).And. Empty(C5_BLQ)','BR_BRANCO'},;
{'C5_PRENOTA = "E" .AND. !Empty(C5_PARCIAL) .AND. Empty(C5_NOTA).And. Empty(C5_BLQ)' ,'BR_BRANCO'},;                  
{'C5_TIPODIP = "1" .AND. Empty(C5_LIBEROK)','BR_BRANCO'},; // MCVN - 20/08/09
{'C5_TIPODIP = "2" .AND. C5_PRENOTA = "O" .AND. C5_PARCIAL = "N" .And. Empty(C5_BLQ)','BR_CINZA'} ,;// MCVN - 21/06/09
{'C5_TIPODIP = "3" .AND. C5_PRENOTA = "O" .AND. C5_PARCIAL = "N" .And. Empty(C5_BLQ)','LIGHTBLU'} ,;
{'C5_PRENOTA $ "S/U" .AND. Empty(C5_NOTA).And. Empty(C5_BLQ)','BR_VERDE'},;                                     
{'C5_TIPODIP = "1" .AND. C5_PRENOTA = "O" .AND. C5_PARCIAL = "N" .AND. Empty(C5_NOTA).And. Empty(C5_BLQ)','BR_PINK'},;
{'C5_PRENOTA = "F" .AND. Empty(C5_PARCIAL) .AND. Empty(C5_NOTA).And. Empty(C5_BLQ)','BR_AZUL'},;
{'Empty(C5_PRENOTA).AND. Empty(C5_PARCIAL) .AND. Empty(C5_NOTA) .AND. !(C5_TIPODIP = "2") .AND. !(C5_TIPODIP = "3") .AND. !Empty(C5_LIBEROK) .And. Empty(C5_BLQ)','BR_LARANJA'},;
{'!Empty(C5_NOTA)','BR_VERMELHO'},; 
{'!Empty(C5_BLQ)',	'BR_AMARELO'},;//Giovani Zago 09/02/12
{'C5_PRENOTA = "R" .AND. !Empty(C5_PARCIAL) .AND. Empty(C5_NOTA) .And. Empty(C5_BLQ)' ,'BR_MARROM'}}

Return( aCores )

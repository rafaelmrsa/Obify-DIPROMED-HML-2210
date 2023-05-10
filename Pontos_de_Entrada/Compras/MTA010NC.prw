#include 'protheus.ch'
#include 'parmtype.ch'

/*
PONTO.......: MTA010NC           PROGRAMA....: MATA010
DESCRIÇÄO...: PONTO DE ENTRADA PARA LIMPAR CAMPOS NA COPIA DE PRODUTOS
UTILIZAÇÄO..: Será usado para limpar os campos da aba frete/anvisa

RETORNO .T. - Confirma movimento
==================================================================================================

31/08/20 - Delta Soluções 
*/


User Function MTA010NC()
Local aCpoNC := {}
AAdd( aCpoNC, 'B1_XQTDEMB' )
AAdd( aCpoNC, 'B1_PESOEMB' )

AAdd( aCpoNC, 'B1_LARGURA' )
AAdd( aCpoNC, 'B1_ALTURA' )
AAdd( aCpoNC, 'B1_COMPRIM' )
AAdd( aCpoNC, 'B1_XCUBEMB' )
AAdd( aCpoNC, 'B1_CODBAR' )
AAdd( aCpoNC, 'B1_QE' )
AAdd( aCpoNC, 'B1_XQTDSEC' )
AAdd( aCpoNC, 'B1_XPESSEC' )
AAdd( aCpoNC, 'B1_XLARSEC' )

AAdd( aCpoNC, 'B1_XALTSEC' )
AAdd( aCpoNC, 'B1_XCOMSEC' )
AAdd( aCpoNC, 'B1_XCUBSEC' )
AAdd( aCpoNC, 'B1_XBARSEC' )
AAdd( aCpoNC, 'B1_XLARPRI' )
AAdd( aCpoNC, 'B1_XALTPRI' )
AAdd( aCpoNC, 'B1_XCOMPRI' )
AAdd( aCpoNC, 'B1_XCUBPRI' )
AAdd( aCpoNC, 'B1_XBARRUM' )

AAdd( aCpoNC, 'B1_XTPEMBV' )
AAdd( aCpoNC, 'B1_XTPEMBC' )
AAdd( aCpoNC, 'B1_PESO' )
AAdd( aCpoNC, 'B1_PESBRU' )
AAdd( aCpoNC, 'B1_XVALSEC' )
AAdd( aCpoNC, 'B1_XDTATU' )

AAdd( aCpoNC, 'B1_XDTATU' )
AAdd( aCpoNC, 'B1_XUSESB' )
AAdd( aCpoNC, 'B1_REG_ANV' )
AAdd( aCpoNC, 'B1_DTV_ANV' )
AAdd( aCpoNC, 'B1_CANVISA' )
AAdd( aCpoNC, 'B1_RANVISA' )

AAdd( aCpoNC, 'B1_XDTANV' )
AAdd( aCpoNC, 'B1_XUSEAV' )

AAdd( aCpoNC, 'B1_DREVFIS' )
AAdd( aCpoNC, 'B1_XCODDES' )
AAdd( aCpoNC, 'B1_XCODORI' )
AAdd( aCpoNC, 'B1_XCXFECH' )
AAdd( aCpoNC, 'B1_XVLDCXE' )

Return (aCpoNC)

#include "protheus.ch" 
 
 
//-------------------------------------------------------------------
/*/{Protheus.doc} MA960GREC
Ponto de Entrada para preenchimento dos campos F6_TIPOGNU, F6_DOCORIG, F6_DETRECE e F6_CODPROD de acordo com o código de receita e UF.
 
@author: Thais Reis - Consultoria OBIFY
@since: 17/11/2022
@corp: Dipromed
/*/
//-------------------------------------------------------------------
User Function MA960GREC()
 
    Local aParam   := {0, '', '', 0, ''} //Parâmetros de retorno default
    Local cReceita := PARAMIXB[1]    //Código de Receita da guia atual
    Local cUF      := PARAMIXB[2]    //Sigla da UF da guia atual

    /*/ Importante: 100099 = Código para Recolhimento de ST por Operação
        Importante: 100102 = Código para Recolhimento de DIFAL por Operação /*/

    If Alltrim(cReceita) $ '100099' .And. cUF $ 'AC/AL/CE/DF/MA/MS/PI/RR/TO' //Valida o Código de Receita e sigla da UF da guia atual
        aParam := {10, '1', '',23, ''}          //Retorna os campos F6_TIPOGNU, F6_DOCORIG, F6_DETRECE, F6_CODPROD e F6_CODAREA de acordo com o código de receita e sigla da UF da guia atual.
    EndIf

    If Alltrim(cReceita) $ '100099' .And. cUF $ 'AP/GO/PA/PR/RO/SE' 
        aParam := {10, '1', '','', ''}          
    EndIf

    If Alltrim(cReceita) $ '100099' .And. cUF $ 'PE/AM' 
        aParam := {22, '2', '',23, ''}          
    EndIf

    If Alltrim(cReceita) $ '100099' .And. cUF $ 'RS' 
        aParam := {22, '2', '','', ''}          
    EndIf

    If Alltrim(cReceita) $ '100099' .And. cUF $ 'MT' 
        aParam := {22, '2', 1538,'', ''}          
    EndIf

    If Alltrim(cReceita) $ '100099' .And. cUF $ 'SC' 
        aParam := {24, '2', '','', ''}          
    EndIf

    If Alltrim(cReceita) $ '100099' .And. cUF $ 'PB' 
        aParam := {30, '2', '','', ''}          
    EndIf

    If Alltrim(cReceita) $ '100099' .And. cUF $ 'RN' 
        aParam := {97, '2', '','', ''}          
    EndIf

    If Alltrim(cReceita) $ '100102' .And. cUF $ 'MA' 
        aParam := {10, '1', '',23, ''}        
    EndIf

    If Alltrim(cReceita) $ '100102' .And. cUF $ 'AC/AL/AP/CE/GO/MA/MS/PA/PI/PR/RO/RR/SE/TO' 
        aParam := {10, '1', '','', ''}          
    EndIf

    If Alltrim(cReceita) $ '100102' .And. cUF $ 'AM'
        aParam := {22, '2', '',23, ''}          
    EndIf
 
    If Alltrim(cReceita) $ '100102' .And. cUF $ 'RS'
        aParam := {22, '2', '','', ''}          
    EndIf

    If Alltrim(cReceita) $ '100102' .And. cUF $ 'MT'
        aParam := {22, '2', 6666,'', ''}          
    EndIf

    If Alltrim(cReceita) $ '100102' .And. cUF $ 'PE/SC'
        aParam := {24, '2', '','', ''}          
    EndIf

    If Alltrim(cReceita) $ '100102' .And. cUF $ 'PB'
        aParam := {99, '2', '','', ''}          
    EndIf

Return aParam

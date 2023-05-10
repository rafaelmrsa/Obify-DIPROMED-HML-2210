#include 'totvs.ch'
#include 'protheus.ch'
/*----------------------------------------------------------
Rotina para Extrair todos os fontes compilados no RPO Custom
Autor: Tiago H. Stocco - Obify

A GetSrcArray retorna um array com o nome dos fontes compilados, pode-se passar um caractere coringa * e o segundo parâmetro da função como 3 verifica apenas no RPOCustom que possui apenas fontes de usuário.
Indica o nome o repositório que será feita a busca. Valores possíveis: 1 - RPO Padrão, 3 - RPO Custom.
-----------------------------------------------------------*/
User Function FCustom()
Local nI 
Local nTaFontes := GetSrcArray("*.*",3)
Local cArqDest  := GetTempPath()+"Fontes_custom.txt"
Local cTexto    := ""
Local aRet      := {}
nT := len(nTaFontes)
If nT > 0
    For nI := 1 to nT
        aRet := GetAPOInfo(nTaFontes[nI])
        cTexto += "Função: "+ nTaFontes[nI] + " - "+cvaltochar(aRet[4]) + " - "+cvaltochar(aRet[5])+ CRLF
    Next
    MsgInfo("Fontes encontrados. Verifique log de console.")
    MemoWrite(cArqDest,cTexto)
    WinExec("c:\windows\notepad.exe "+cArqDest)
Else
    MsgStop("Nenhum fonte encontrado no RPO Custom.")
Endif

RETURN

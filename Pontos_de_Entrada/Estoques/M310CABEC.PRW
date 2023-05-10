/*
+============================================================================+
|Funcao: M310CABEC   |    Autor: Reginaldo Borges       |   Data: 27/12/2016 |
+----------------------------------------------------------------------------+
|Descricao: P.E. executado após a montagem do array Acabec antes das chamadas|
|           das rotinas automáticas que irão gerar o cabeçalho do pedido     | 
|           de vendas, do documento de entrada ou da fatura de entrada       |
|           (localizado). É utilizado para permitir que o usuário            |
|           manipule o array aCabec que contém os itens do cabeçalho do      |
|           pedido de vendas, documento de entrada ou fatura de entrada.     |
|           É passado um parâmetro para identificar a rotina a ser           |
|           executada após o ponto de entrada.                               |
+----------------------------------------------------------------------------+
|Uso: Health Quality - Transferencia entre filiais                           |
+============================================================================+
*/         
#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"

User Function M310CABEC()
Local cProg  := PARAMIXB[1]
Local aCabec := PARAMIXB[2]
Local aPar   := PARAMIXB[3]

If cProg == 'MATA410'    
	aadd(aCabec,{'C5_TIPODIP','1',Nil}) 
	aadd(aCabec,{'C5_TMK','1',Nil}) 
	aadd(aCabec,{'C5_QUEMCON','TRANSFERENCIA ENTRE FILIAIS',Nil}) 
	aadd(aCabec,{'C5_TRANSP','000851',Nil}) 
	aadd(aCabec,{'C5_TPFRETE','D',Nil}) 
	aadd(aCabec,{'C5_DT_PRE',DATE(),Nil}) 	
	aadd(aCabec,{'C5_HR_PRE',TIME(),Nil}) 
Endif

Return(aCabec)
     
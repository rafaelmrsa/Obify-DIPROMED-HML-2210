/*==========================================================================\
|PROGRAMA  | DIPM014| AUTOR | RAFAEL DE CAMPOS FALCO  | DATA ≥ 16/09/2004   |
|===========================================================================|
|DESC.     | EXECUTA MACRO PARA CRIAÁ„O DE ARQUIVO XLS                      |
|===========================================================================|
|SINTAXE   | DIPM014                                                        |
|===========================================================================|
|USO       | ESPECIFICO DIPROMED                                            |
|===========================================================================|
|HISTÛRICO | DD/MM/AA - DESCRIÁ„O DA ALTERAÁ„O                              |
\==========================================================================*/
#INCLUDE "RWMAKE.CH"              
*-------------------------------------*
User Function DIPM014(CEXECUTA)        
*-------------------------------------*
//Local cListaPrc:=upper(GetSrvProfString("STARTPATH","")+"Excell-DBF\LISTAPRC.XLS")// JBS 12/12/2005
//Local cMacroLista:=upper(GetSrvProfString("STARTPATH","")+"Excell-DBF\MACROLISTA.XLS")// JBS 12/12/2005
 
// Alterado para gravar arquivos na pasta protheus_data - Por Sandro em 19/11/09. 
Local cListaPrc:=upper("\Excell-DBF\LISTAPRC.XLS")// JBS 12/12/2005 

Local cMacroLista:=upper("\Excell-DBF\MACROLISTA.XLS")// JBS 12/12/2005

U_DIPPROC(ProcName(0),U_DipUsr()) // MCVN - 22/01/2009

ConOut("---------------------------")
ConOut('Inicio 1 - ' + Dtoc(Date())+' - '+Time())
ConOut("---------------------------")
If File(cListaPrc)
	fErase(cListaPrc)
EndIf
ConOut("---------------------------")
ConOut('Inicio 2 - ' + Dtoc(Date())+' - '+Time())
ConOut("---------------------------")
// TENTO EXECUTAR O EXCEL
/*
IF ! APOLECLIENT( 'MSEXCEL' )
ConOut("--------------------------")
ConOut('ERRO - ' + Dtoc(Date())+' - '+Time())
ConOut("--------------------------")
RETURN
ENDIF
*/
OEXCELAPP := MSEXCEL():NEW()
OEXCELAPP:WORKBOOKS:OPEN(cMacroLista)
ConOut("--------------------------")
ConOut('FIM - ' + Dtoc(Date())+' - '+Time())
ConOut("--------------------------")
OEXCELAPP:SETVISIBLE(.T.) // EXIBE GERAÁ„O DO ARQUIVO XLS
RETURN
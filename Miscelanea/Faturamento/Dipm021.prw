/*                                                              Sao Paulo,  13 Jul 2006
---------------------------------------------------------------------------------------
Empresa.......: DIPOMED Comércio e Importação Ltda.
Programa......: DIPM021.PRW
Objetivo......: Lê o FTP da Tranportadora e copia para um diretorio. 

Autor.........: Jailton B Santos, JBS
Data..........: 13 Jul 2006

Versão........: 1.0
Consideraçoes.: Função chamada direto do menu ->U_DipM021()
                Ou scheduler 
                
Parametros....: MV_FTPSER -> Servido FTP
                MV_FTPUSU -> Usuario                             
                MV_FTPSEN -> Senha de acesso
                MV_FTPEDI -> Diretorio onde estao os arquivos                             
                MV_FTPDOW -> Local para Download dos arquivos
------------------------------------------------------------------------------------
*/
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"
#DEFINE ENTER CHR(13)+CHR(10)
*------------------------------*
User Function Dipm021()
*------------------------------*
Local cFtp_Servidor := AllTrim(GETNEWPAR('MV_FTPSER','ftp.braspress.com.br')) // Servido FTP
Local cFtp_Usuario  := AllTrim(GETNEWPAR('MV_FTPUSU','edi'))                  // Usuario
Local cFtp_Senha    := AllTrim(GETNEWPAR('MV_FTPSEN','edi'))                  // Senha de acesso
Local cFtp_DirEdi   := AllTrim(GETNEWPAR('MV_FTPEDI','Dipromed'))             // Diretorio onde estao os arquivos
Local aArqOco
Local aArqEmb

//Local cFtp_DownLoad := GetSrvProfString("STARTPATH","")+"EDI\RETORNO\"        // Local para Download dos arquivos 

// Alterado para gravar arquivos na pasta protheus_data - por Sandro em 19/11/09. 
Local cFtp_DownLoad := "\EDI\RETORNO\"  


U_DIPPROC(ProcName(0),U_DipUsr()) // MCVN - 22/01/2009

lFireWall := .F.

Begin Sequence 

    FTPDisconnect()

	conout(Replicate("=",80))	
	conout(OemtoAnsi("Conectando no FTP: "+cFtp_Servidor))
	conout(Replicate("=",80))

    If !FTPConnect(cFtp_Servidor,,cFtp_Usuario, cFtp_Senha)
	    ConOut(OemToAnsi('Falha na conexao para le o EDI!'))
        FTPDisconnect()
        Break
    EndIf

    If !FTPDirChange(cFtp_DirEdi)             
	    ConOut(OemToAnsi( 'Falha na conexao para le o EDI!'))
        FTPDisconnect()
        Break
    EndIf
    cCurDir := FtpGetCurDir()
    ConOut("Diretorio Corrente: "+cCurDir)
     
	aArqss  := FTPDIRECTORY( '*.*', 'D' )
	aArqOco := FTPDIRECTORY( '*.*' )
   	aArqEmb := FTPDIRECTORY( '*.*' )
   	
    If Len(aArqOco) > 0 
   	    For id := 1 to Len(aArqsOco)
		    cBxArq 	:= Alltrim(cFtp_DownLoad)+aArqOco[id]
		    ConOut("Realizando download do arquivo " + cBxArq )
		    lRet := FTPDownLoad(cFtp_DownLoad,aArqOco[id])
		    If !lRet
			    lRet2 := .F.
		    EndIf
	    Next id
	Else    
	    conout(Replicate("=",80))	
	    conout(OemtoAnsi("Nao foi encontrado arquivo de Ocorrencia no "+cFtp_Servidor))
	    conout(Replicate("=",80))
    EndIf

    If Len(aArqEmb) > 0 
   	    For id := 1 to Len(aArqEmb)
		    cBxArq 	:= Alltrim(cFtp_DownLoad)+aArqEmb[id]
		    ConOut("Realizando download do arquivo " + cBxArq )
		    lRet := FTPDownLoad(cFtp_DownLoad,aArqEmb[id])
		    If !lRet
			    lRet2 := .F.
		    EndIf
	    Next id
	Else    
	    conout(Replicate("=",80))	
	    conout(OemtoAnsi("Nao foi encontrado arquivo de Conhecimentos no "+cFtp_Servidor))
	    conout(Replicate("=",80))
    EndIf

	conout(Replicate("=",80))	
	conout(OemtoAnsi("Desconectando do "+cFtp_Servidor))
	conout(Replicate("=",80))

    FTPDisconnect()
    
End Sequence

Return(.t.)
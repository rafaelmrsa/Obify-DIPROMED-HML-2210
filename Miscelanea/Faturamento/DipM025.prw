/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �DIPM025   �Autor  �Jailton B Santos-JBS� Data � 16/12/2009  ���
�������������������������������������������������������������������������͹��
���Objetivo  �Programa desenvolvido para integrar a Rota de Ceps da Trans-���
���          �portadora 'Braspress' a a Tabela 'SZV'.                     ���
�������������������������������������������������������������������������͹��
���Descricao �Este programa cria uma tabela temporaria. Le os dados do ar-���
���          �quivo texto "\ROTACEP\ROTACEP_OMT.TXT", grava na tabela tem-���
���          �poraria. Apaga os dados da transportadora da tabela 'SZV'.  ���
���          �Grava as Informacoes da tabela temporaria na tabela 'SZV',  ���
���          �para a transportadora Braspress.                            ���
�������������������������������������������������������������������������͹��
���Uso       � FAT - Dipromed                                             ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"
#DEFINE ENTER CHR(13)+CHR(10)

User Function DipM025(aWork)

Local _xArea     := GetArea()

Private cWorkFlow
Private lSchedTela := .T. 

If ValType(aWork) <> 'A'

	cWorkFlow := "N"
    U_DIPPROC(ProcName(0),U_DipUsr())
    
    If !(Upper(U_DipUsr()) $ "EELIAS/MCANUTO/ADMINISTRADOR/DDOMINGOS/VQUEIROZ/VEGON/RBORGES") 
        Aviso('Atencao','Usuario sem permissao para usar esta Opcao!',{'Ok'})
        Return(.F.)                
   EndIf                           
   
   If Aviso("Aten��o","Confirma o processamento da rotina ?",{"N�o","Sim"},1)<>2
   		Return(.F.)
   EndIf
   
Else
	cWorkFlow := aWork[1]
	PREPARE ENVIRONMENT EMPRESA "01" FILIAL "04" FUNNAME "DIPM025"  TABLES "SZV"
	lSchedTela := .F.
EndIf

ConOut('Integra��o Rota CEP - Inicio ... ')
fIntegra()
ConOut('Integra��o Rota CEP   -  Fim ... ')

If cWorkFlow == 'S'
    SZV->(dbCloseArea()) 
	RESET ENVIRONMENT
EndIf

RestArea(_xArea)
Return(.t.)
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �fIntegra()�Autor  �Jailton B Santos-JBS� Data � 16/12/2009  ���
�������������������������������������������������������������������������͹��
���Desc.     �Grava os dados Integrados do arquivo texto na Tabela 'SZV', ���
���          �para transportador 'Braspress'.                             ���
�������������������������������������������������������������������������͹��
���Uso       � FAT - Dipromed                                             ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function fIntegra()

Local nArq     := 0
Local cFile    := ''
Local lRet     := .T.
//-----------------------------------------------
// Definicao dos Arquivos Textos
//-----------------------------------------------
Local cArquivo := "\ROTACEP\ROTACEP_OTM.TXT"
Local cArqErros:= "\ROTACEP\ROTACEP_OTM.ERR"
//-----------------------------------------------
// Estrutura da Tabela de Integracao 
//-----------------------------------------------
Local aEstr    := {{"ID_ROTA"    ,"C",005,0},;
                   {"CEP_INI"    ,"C",008,0}, ;
                   {"CEP_FIM"    ,"C",008,0},;
                   {"CEP_UF"     ,"C",002,0},;
                   {"CEP_LOCALI" ,"C",060,0},;
                   {"CEP_LOC_CE" ,"C",008,0},;
                   {"FROTA_NUME" ,"C",006,0},;
                   {"ROTA_NUMER" ,"C",006,0},;
                   {"FROTA_ID"   ,"C",005,0},;
                   {"FILIAL_SIG" ,"C",004,0},;
                   {"FILIAL_ID"  ,"C",004,0},;
                   {"CLASSIFICA" ,"C",001,0},;
                   {"SEQUENCIA"  ,"C",003,0}}


private nNotasInt:=0
private aHeader:={}
private aCampos:={} 
private cProblema:=''                   
//-------------------------------------------------------
// Verifica se existe arquivo para integrar Rotas de CEP
//-------------------------------------------------------
If File(cArquivo)
	
	aHeader:={}
	aCampos:={}
	//-------------------------------------------------------
	// Cria a tabela Temporaria
    //-------------------------------------------------------
    ConOut('Criando tabela temporaria de integracao de rota de CEP.')
	cFile:=CriaTrab(aEstr,.T.)
	DbUseArea(.T.,,cFile,"INTEG",.F.,.F.)
	//-------------------------------------------------------
	// Le o arquivo texto e grava no arquivo de integracao
    //-------------------------------------------------------  
    If lSchedTela
        Processa({|| lRet := fAppend(cArquivo)})
    Else
        ConOut('Lendo arquivo texto da Rota de CEP e salvando no arquivo temporario.')
        lRet := fAppend(cArquivo)
    EndIf                
	If lRet
	    //-------------------------------------------------------
	    // Troca o Codigo da transportadora antes de integrar
	    // previnindo a alguma acao negativa.
        //-------------------------------------------------------
        If lSchedTela
		    Processa({|| lRet := fTrocaTransp()})//,,,'Alterando codigo da transportador')
        Else
            ConOut('Alterando codigo da transportador')
		    lRet := fTrocaTransp()
        EndIf                
	    //-------------------------------------------------------
	    // Grava todo o conteudo da tabela de integracao na tabe-
	    // la 'SZV' para a transportadora 'Braspress'. 
	    //-------------------------------------------------------
        If lSchedTela
		    Processa({|| lRet := fGravaSZV()})//,,,'Integrando dados Importados')
		Else
            ConOut('Integrando dados Importados')
		    lRet := fGravaSZV()
		EndIf
		If lRet
	        //-------------------------------------------------------
	        // Como nao houve problema na integracao,elimina definiti-
	        // vamente as informacoes antigas da transportadora.
	        //-------------------------------------------------------
            If lSchedTela
			    Processa({|| lRet := fDeleta()})
			Else
                ConOut('Apagando definitivamente os dados antigos da Transportadora na tabela SZV...')
			    lRet := fDeleta()
			EndIf 
		EndIf
	EndIf
    //-------------------------------------------------------
    // Faz um tratamento para documentar o arquivo texto man-
    // tendo a versao do txt que foi integrada controlando por
    // numero de versao.
    //-------------------------------------------------------
	Do While .T.
		cArqIntegrado := '\ROTACEP\ROTACEP_OTM'+StrZero(nArq,3)+'.INT'
		If !File(cArqIntegrado)         
			Exit
		EndIf
		narq++
	EndDo
	
	RENAME (cArquivo) TO (cArqIntegrado)
	memowrite(cArqErros,cProblema)
	// INTEG->(__dbzap())
    //-------------------------------------------------------
    // Elimina a tabela temporaria usada para fazer a integra-
    // cao das Rotas de CEP
    //-------------------------------------------------------
    ConOut('Eliminado a tabela temporaria de Integracao ...')
    INTEG->(E_EraseArq(cFile))
	If(lSchedTela,Aviso('Sucesso','Importacao das rotas de CEP concluida com sucesso.',{'Ok'}),)
EndIf

Return(Nil)
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �fAppend() �Autor  �Jailton B Santos-JBS� Data �  16/12/2009 ���
�������������������������������������������������������������������������͹��
���Desc.     � Le a informacoes do arquivo de CEPs que esta no formato de ���
���          � texto e grava no arquivo temporario de integracao.         ���
�������������������������������������������������������������������������͹��
���Uso       � FAT - Dipromed                                             ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function fAppend(cArquivo)

conout('Integrando arquivo de Rota de CEP ' + cArquivo)
conout('Data..: ' + dtoc(dDataBase) + ' as ' + Time())
conout('Lendo o arquivo de Rota CEPs ...') 
If lSchedTela
    ProcRegua(2)
    IncProc()
EndIf    
Append from (cArquivo) SDF
If lSchedTela
    IncProc()
EndIf
Return(!EOF().and.!BOF())
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �fGravaSZV �Autor  �Microsiga           � Data �  12/16/09   ���
�������������������������������������������������������������������������͹��
���Desc.     � Grava as informacoes integradas na tabela 'SZV'            ���
�������������������������������������������������������������������������͹��
���Uso       � FAT - Dipromed                                             ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function fGravaSZV()

Local lRet := .F.   

If lSchedTela
    ProcRegua(INTEG->( RecCount() ))
EndIf 

INTEG->( DbGotop() )

Do While INTEG->( !EOF() )
	
    If lSchedTela
	    IncProc()
	EndIf
	
	SZV->( Reclock('SZV',.T.) )
	SZV->ZV_FILIAL   := xFilial('SZV')
	SZV->ZV_TRANSP   := "000150"
	SZV->ZV_ROTA     := Val(INTEG->ID_ROTA)
	SZV->ZV_CEPINI   := val(INTEG->CEP_INI)
	SZV->ZV_CEPFIM   := Val(INTEG->CEP_FIM)
	SZV->ZV_CEPUF    := INTEG->CEP_UF
	SZV->ZV_LOCALID  := INTEG->CEP_LOCALI
	SZV->ZV_CEPLOCA  := val(INTEG->CEP_LOC_CE)
	SZV->ZV_NUMFROT  := INTEG->FROTA_NUME
	SZV->ZV_NUMROTA  := INTEG->ROTA_NUMER
	SZV->ZV_SGFILIA  := INTEG->FILIAL_SIG
	SZV->ZV_IDFILIA  := Val(INTEG->FILIAL_ID)
	SZV->ZV_CLASSIF  := INTEG->CLASSIFICA
	SZV->ZV_SEQUEN   := Val(INTEG->SEQUENCIA)    
	//--------------------------------------------------------
    // Informacoes nao encontradas no arquivo texto recebido 
    // da Braspress. 
    // Nenhuma informacao foi gravada neste campos.
	//--------------------------------------------------------
	//SZV->ZV_FROTA    := INTEG->
	//SZV->ZV_DIST_KM  := INTEG->
	//SZV->ZV_TIMEATE  := INTEG->
	//SZV->ZV_POLO     := INTEG->
	//SZV->ZV_VIAGEM   := INTEG->

	SZV->( MsUnLock('SZV') )
	
	INTEG->( DbSkip() ) 
	
	lRet := .T. 
	
EndDo

Return(lRet)
/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
���Programa  �fTrocaTransp()�Autor�Jailton B Santos-JBS� Data � 16/12/2009 ���
��������������������������������������������������������������������������͹��
���Desc.     � Troca o codigo da trasnportadora Braspress '000150' por     ���
���          � 'OLD150' para ficar diferente dos novos recnos.             ���
��������������������������������������������������������������������������͹��
���Uso       � FAT - Dipromed                                              ���
��������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/
Static Function fTrocaTransp()     
                    
Local lRet := .F.  

If lSchedTela
    ProcRegua( SZV->( RecCount() ) )
EndIf

SZV->( DbGoTop() )
SZV->( DbSeek(xFilial('SZV')) )

Do While SZV->( !EOF() ) .and. SZV->ZV_FILIAL == xFilial('SZV')

    If lSchedTela
        IncProc()
    EndIf
    
    If SZV->ZV_TRANSP == '000150' 
        
        SZV->( RecLock('SZV',.F.) )
        SZV->ZV_TRANSP := 'OLD150'
        SZV->( MsUnLock('SZV') )
        
        lRet := .T.
    
    EndIf 

    SZV->( DbSkip() )

EndDo
Return(lRet) 
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � fDeleta() � Autor�Jailton B Santos-JBS � Data � 16/12/2009 ���
�������������������������������������������������������������������������͹��
���Desc.     � Elimina definitivamente as informacoes antigas da transp.  ���
�������������������������������������������������������������������������͹��
���Uso       � FAT - Dipromed                                             ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function fDeleta()
Local lRet := .F.

If lSchedTela
    ProcRegua(SZV->(RecCount()))          
EndIf

SZV->( DbSetOrder(2) )
SZV->( DbGoTop() )
SZV->( DbSeek(xFilial('SZV')+'OLD150') )

Do While SZV->( !EOF() ).and.SZV->ZV_FILIAL == xFilial('SZV').and. SZV->ZV_TRANSP == 'OLD150'
	
    If lSchedTela
	    IncProc()
	EndIF
	
	SZV->( RecLock('SZV',.F.) )
	SZV->( DbDelete() )
	SZV->( MsUnLock('SZV') )
	lRet := .T.
	
	SZV->( DbSkip() )
	
EndDo                

SZV->( DbSetOrder(1) )

Return(lRet)
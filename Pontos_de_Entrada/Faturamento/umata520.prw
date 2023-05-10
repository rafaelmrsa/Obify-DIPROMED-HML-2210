/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �UMata520()� Autor �Jailton B Santos-JBS   � Data �12/08/2010���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Faz o cancelamento automatico de notas fiscais de saida.   ���
���          � Foi copiado do padrao MATA520.                             ���
�������������������������������������������������������������������������Ĵ��
���Uso       � Especifico Faturamento Dipromed - DIPA046                  ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
���Programador � Data   �  Motivo da Alteracao                            ���
�������������������������������������������������������������������������Ĵ��
���            �        �                                                 ���
���            �        �                                                 ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
#INCLUDE "PROTHEUS.CH"

User function UMata520(aRotAuto)

LOCAL cMarca
LOCAL nIndice
LOCAL cFilSF2   := ""
Local aRegSd2   := {}
Local aRegSe1   := {}
Local aRegSe2   := {}
LOCAL aIndexSF2 := {}
Local lTop      := .F.            

aChave := {"F2_DOC","F2_SERIE"}
aRotAuto := SF2->(MSArrayXDB(aRotAuto,,5,,aChave))
If !( Len(aRotAuto) > 0 )
	Return .T.
EndIf
If MaCanDelF2("SF2",SF2->(RecNo()),@aRegSD2,@aRegSE1,@aRegSE2)
	PcoIniLan("000102")
	//����������������������������������������������������������������Ŀ
	//� Estorna o documento de saida                                   �
	//������������������������������������������������������������������    
	SF2->(MaDelNFS(aRegSD2,aRegSE1,aRegSE2,.F.,.F.,.T.,.F.,,nPDevLoc))
	PcoFinLan("000102")
	
	// Ajustando C9 devido a falha na rotina padr�o
	If SZL->ZL_MATAPED == "1"                                                                                                                                           

		SC9->( DbSetOrder(1) )                                         
		SC9->( DbGoTop() )
		SC9->( DbSeek(xFilial("SC9")+SZL->ZL_PEDIDO))

		While !Eof() .And. xFilial("SC9")==SC9->C9_FILIAL .And. SZL->ZL_PEDIDO==SC9->C9_PEDIDO
			If SC9->C9_QTDVEN=0 .And. SC9->C9_QTDORI=0  .And. SC9->C9_SALDO=0 .And.	Empty(SC9->C9_NFISCAL) .And. Empty(SC9->C9_OPERADO)				
				RecLock("SC9")
				SC9->(a460Estorna())
				SC9->( MsUnLock() )
			Endif	   
			SC9->( DbSkip() )
		End          
    	
	Endif   

Else // Se n�o for possivel cancelar a NF - MCVN 05/01/11  

	SZL->( Reclock('SZL',.F.) )
	SZL->ZL_HISTORI := '( '+AllTrim(cDipUsu)+' ) Autoriza��o cancelada pois a nota fiscal  n�o pode ser exclu�da! '+dToc(dDataBase)+'  as '+Time()+' Horas. ' + Chr(13) + chr(10) + SZL->ZL_HISTORI
	SZL->ZL_STATUS  := "1" // Voltou ao status inicial 
	SZL->( MsUnLock('SZL') )
	
    Aviso('Aten��o','Autoriza��o cancelada pois a nota fiscal n�o pode ser exclu�da. Resolva o problema que foi informado na tela anterior e reavalie a solicita��o!',{'Ok'}) 	
    
EndIf

TCInternal(5,"*OFF")   // Desliga Refresh no Lock do Top
lTop := .T.

l520Auto := (aRotAuto <> Nil) //Variavel para rotina automatica

Private lSD2520T:= (ExistTemplate("MSD2520"))
Private lSD2520 := (existblock("MSD2520"))
Private lA520EXC:= (existblock("A520EXC"))
Private cFilter := ""

Private cCalcImpV:= GETMV("MV_GERIMPV") // Internacionaliza��o

Private aRotina  :=  {{ "Pesquisa"  ,"PesqBrw"    , 0 , 0},;   
                      { "Filtro"    ,"A520Filtro" , 0 , 0},;    
                      { "Visualizar","Mc090Visual", 0 , 2},;    
                      { "Excluir"   ,"A520Elim"   , 0 , 5}}   

Private bFiltraBrw         
Private cCadastro := OemToAnsi("Exclus�o de Notas Fiscais")	

Pergunte("MT460A",.F.) 

cMarca := GetMark(,"SF2","F2_OK")

aChave := {"F2_DOC","F2_SERIE"}
aRotAuto := SF2->(MSArrayXDB(aRotAuto,,5,,aChave))

If !( Len(aRotAuto) > 0 )
	Return .T.
EndIf

SF2->(RecLock("SF2",.f.))
SF2->F2_OK := cMarca
SF2->(MsUnLock('SF2'))
A520Elim("SF2",SF2->(RECNO()),5,cMarca)

dbSelectArea("SF2")
Set Filter to

dbSelectArea("SD2")
dbSetOrder(1)
dbSelectArea("SF3")
dbSetOrder(1)
dbSelectArea("SD1")
dbSetOrder(1)

Return( .T. )
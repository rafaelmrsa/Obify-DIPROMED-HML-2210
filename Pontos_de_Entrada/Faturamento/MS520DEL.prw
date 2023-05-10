

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Progr520DEL()� Autor �Jailton B Santos-JBS   � Data �24/05/2010���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Ponto de entrada chamado apos a exclus�o da nota fiscal.   ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � Nennhum retorno aguardado pelo padrao                      ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � usado para para gravar um historico de cancelamento da nota���
���          � na tabela "SZL" - Solocicitacao de cancelamento.           ���
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

User Function MS520DEL()                                

Local lRet   := .T.
Local aArea  := GetArea()
Local cEmailTo := AllTrim(GetMv('MV_DIPA46A')) // Email do diretor de avaliacao da solicitacao
Local cCicTo   := AllTrim(GetMv('MV_DIPA46D')) // CIC do Usuario
Local nOpcao := NIL

If !Empty(cEmailTo)
	fEmail(cEmailTo,nOpcao)
	fCic(cCicTo, "Nota Fiscal " + AllTrim(SC5->C5_NOTA) + '/'+AllTrim(SC5->C5_SERIE) + ' foi cancelada em ' + dtoc(dDataBase) + ' as ' + Time() + ' hora(s)!')
EndIf

If !("TMSA200" $ FUNNAME()) .And. !("TMSA500" $ FUNNAME()) // N�o entra se a rotina for chamada pelo TMS  - MCVN 31/08/10
	
	Conout(SC5->C5_NUM+" - Exclusao de NF")		
	SC5->(RecLock("SC5",.F.))
	
	SC5->C5_PRENOTA := "O"		
	SC5->C5_PARCIAL := "N"
	
	SC5->(DbCommit())
	SC5->(MsUnLock())


Endif


RestArea(aArea)

Return(lRet)


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �fEmail()  � Autor �Jailton B Santos-JBS� Data �  14/05/2010 ���
�������������������������������������������������������������������������͹��
���Desc.     �  Funcao desenvolvida para enviar um e-mail para os usuarios���
���          �avaliarem, aporvarem ou reprovarem e cancelarem notas fis-  ���
���          �cais.                                                       ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Especifico Faturamento Dipromed                            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Static Function fEmail(cEmailTo,nOpcao)

Local cAssunto  := ""
local cHora := Time()
local cDate	:= dTos(dDataBase)
local cNota := SF2->F2_DOC
local cSerie := SF2->F2_SERIE

Private oHTML

cAssunto := 'Cancelamento da N.F. ' + cNota + '-' + cSerie + ' em ' + cDate + ' as ' + cHora +  ' horas.'


oProcess := TWFProcess():New("WF-00001",OemToAnsi("Controle de Cancelamento de Notas Fiscais"))
oProcess:NewTask("001","\workflow\modelos\DIPA046a.htm")
oHTML:= oProcess:oHTML

oProcess:cTo := Lower(cEmailTo)
oProcess:cSubject := cAssunto
oProcess:UserSiga := RetCodUsr()

oHTML:ValByName("xData"      ,cDate)
oHTML:ValByName("xHora"      ,cHora)
oHTML:ValByName("xPedido"    ,SC6->C6_NUM)
oHTML:ValByName("xNota"      ,SF2->F2_DOC+'-'+SF2->F2_SERIE)
oHTML:ValByName("xData2"     ,dToc(dDataBase))
oHTML:ValByName("xTes"       ,SC6->C6_TES)
oHTML:ValByName("xDanfe"     ,SF2->F2_CHVNFE)


/*
If Inclui
	cAssunto := 'Cancelamento da N.F. ' + M->ZL_NOTA + '-' + M->ZL_SERIE + ' em ' + dToc(M->ZL_DATA) + ' as ' + M->ZL_HORA +  ' horas.'
ElseIf nOpcao == Nil
	cAssunto := 'Cancelamento da N.F. ' + SZL->ZL_NOTA + '-' + SZL->ZL_SERIE + ' em ' + dToc(SZL->ZL_DATA) + ' as ' + SZL->ZL_HORA +  ' horas.'
ElseIf nOpcao == 1
	cAssunto := 'Autorizado o cancelamento da N.F. ' + SZL->ZL_NOTA + '-' + SZL->ZL_SERIE + ' em ' + dToc(SZL->ZL_DATA) + ' as ' + SZL->ZL_HORA +  ' horas.'
ElseIf nOpcao == 2	
	cAssunto := EncodeUTF8('N�o autorizado o cancelamento da N.F. '  + SZL->ZL_NOTA + '-' + SZL->ZL_SERIE + ' em ' + dToc(SZL->ZL_DATA) + ' as ' + SZL->ZL_HORA +  ' horas.',"cp1252")
EndIf

oProcess := TWFProcess():New("WF-00001",OemToAnsi("Controle de Cancelamento de Notas Fiscais"))
oProcess:NewTask("001","\workflow\modelos\DIPA046a.htm")
oHtml:= oProcess:oHtml
//oProcess:cFrom := cFrom
oProcess:cTo := Lower(cEmailTo)

oProcess:cSubject := cAssunto
oProcess:UserSiga := RetCodUsr()
//oProcess:oHTML:ValByName( "cLogoEmpresa" , cLogoTipo )
oProcess:oHTML:ValByName("xCodigo"    ,Iif(!Inclui,SZL->ZL_CODIGO,M->ZL_CODIGO))
oProcess:oHTML:ValByName("xData"      ,Iif(!Inclui,dToc(SZL->ZL_DATA),dToc(M->ZL_DATA)))
oProcess:oHTML:ValByName("xHora"      ,Iif(!Inclui,SZL->ZL_HORA,M->ZL_HORA))
oProcess:oHTML:ValByName("xPedido"    ,Iif(!Inclui,SZL->ZL_PEDIDO,M->ZL_PEDIDO))
oProcess:oHTML:ValByName("xNota"      ,Iif(!Inclui,SZL->ZL_NOTA+'-'+SZL->ZL_SERIE,M->ZL_NOTA+'-'+M->ZL_SERIE))
oProcess:oHTML:ValByName("xData2"     ,dToc(dDataBase))
oProcess:oHTML:ValByName("xTes"       ,Iif(!Inclui,SZL->ZL_TES,M->ZL_TES))
oProcess:oHTML:ValByName("xExp"       ,Iif(!Inclui,SZL->ZL_EXPEDIC,M->ZL_EXPEDIC))
oProcess:oHTML:ValByName("xMercadoria",Iif(!Inclui,AllTrim(SZL->ZL_ONDE),AllTrim(M->ZL_ONDE)))
//oProcess:oHTML:ValByName("xFaturar"   ,Iif(!Inclui,IIf(SZL->ZL_REFATUR = '1','[X] Sim [ ] N�o','[ ] Sim [X] N�o'),IIf(M->ZL_REFATUR = '1','[X] Sim [ ] N�o','[ ] Sim [X] N�o')))
oProcess:oHTML:ValByName("xMataPv"    ,Iif(!Inclui,IIf(SZL->ZL_MATAPED = '2','[ ]-Refaturar  [X]-Excluir','[X]-Refaturar  [ ]-Excluir'),IIf(M->ZL_MATAPED = '2','[ ]-Refaturar  [X]-Excluir','[X]-Refaturar  [ ]-Excluir')))
oProcess:oHTML:ValByName("xMotivo"    ,Iif(!Inclui,StrTran(AllTrim(SZL->ZL_MOTIVO) ,chr(13)+chr(10),'<P>'),StrTran(AllTrim(M->ZL_MOTIVO) ,chr(13)+chr(10),'<P>')))
oProcess:oHTML:ValByName("xHistorico" ,Iif(!Inclui,StrTran(AllTrim(SZL->ZL_HISTORI),chr(13)+chr(10),'<P>'),StrTran(AllTrim(M->ZL_HISTORI),chr(13)+chr(10),'<P>')))
oProcess:oHTML:ValByName("xDados"     ,Iif(!Inclui,StrTran(AllTrim(SZL->ZL_DADOS)  ,chr(13)+chr(10),'<P>'),StrTran(AllTrim(M->ZL_DADOS)  ,chr(13)+chr(10),'<P>')))
oProcess:oHTML:ValByName("xEmpresa"   ,'[' + SM0->M0_CODIGO +']-['+AllTrim(U_FindEmp(SM0->M0_CODIGO,SM0->M0_CODFIL,,'NOME'  )) + ']')
oProcess:oHTML:ValByName("xNomFil"    ,'[' + SM0->M0_CODIGO +']-['+AllTrim(U_FindEmp(SM0->M0_CODIGO,SM0->M0_CODFIL,,'FILIAL'  )) + ']')
oProcess:oHTML:ValByName("xUsuario"   ,Iif(!Inclui,SZL->ZL_USUARIO,M->ZL_USUARIO))
oProcess:oHTML:ValByName("xSetor"     ,Iif(!Inclui,SZL->ZL_SETOR,M->ZL_SETOR))
*/


oProcess:Start()
oProcess:Finish()

Aviso('Sucesso','Enviado e-mail com sucesso.',{"Ok"})

Return(.T.)
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �fFindCIC()� Autor �Jailton B Santos-JBS� Data � 25/05/2010  ���
�������������������������������������������������������������������������͹��
���Desc.     � Busca o nome do usuario do CIC para enviar mensagen-lhe    ���
���          � mensagens.                                                 ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function fFindCic(cCodigo)

Local cQuery  := ""
Local cUsuCIC := ""

cQuery := " Select U7_CICNOME CIC "
cQuery += "   from "+RetSqlName('SU7')+" SU7 "
cQuery += "  where U7_FILIAL = '" + xFilial('SU7')+ "' "
cQuery += "    and U7_CODUSU  = '"+ cCodigo + "' "
cQuery += "    and SU7.D_E_L_E_T_ = '' "
cQuery += " Union Select Y1_NOMECIC CIC "
cQuery += "   from " + RetSqlName('SY1')+ " SY1 "
cQuery += "  where Y1_FILIAL  = '" +xFilial('SY1')+ "' "
cQuery += "    and Y1_USER  = '"+ cCodigo + "' "
cQuery += "    and SY1.D_E_L_E_T_ = '' "

If Select("TRB") > 0
	TRB->(DbCloseArea())
EndIf

//TcQuery cQuery NEW ALIAS "TRB" verificar depois

If !TRB->(BOF() .and. EOF() )
	cUsuCIC := TRB->CIC
EndIf
TRB->( DbCloseArea() )
Return(cUsuCIC)
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � fCic()   �Autor  �Jailton B Santos-JBS� Data � 25/05/2010  ���
�������������������������������������������������������������������������͹��
���Desc.     � Esta funcao dispara uma mensagem de CIC para um ou mais    ���
���          � usuarios.                                                  ���
�������������������������������������������������������������������������͹��
���Uso       � Especificos Faturamento Dipromed                           ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function fCic(cOperador, cMsg, lCodigo, _nOpc)

Local lRet := .T.

Local cOpFatDest  := ""                             
Default _nOpc     := 0
//cOpFatDest := "MAXIMO.CANUTO,MAGDA.TEIXEIRA,WILLIAM.PEREIRA,SILVIA.MORAES,BRUNO.JESUS"

If lCodigo
	cOpFatDest := fFindCic(cOperador) //
Else
	cOpFatDest := upper(cOperador)
EndIf
                 
//Maximo 30/07/13           
If _nOpc == 9
	cOpFatDest  += ","+GetNewPar("ES_DIP46CI","DIEGO.DOMINGOS,VANDER.EGON,MAXIMO.CANUTO")
Endif
             
                                                                                                             
U_DIPCIC(cMsg,AllTrim(cOpFatDest))//RBorges 12/03/15
//WaitRun(cServidor+' '+cOpFatRem+' '+cOpFatSenha+' "'+AllTrim(cOpFatDest)+'" "' + cMsg + '" ') //Comentada RBorges 12/03/15

Return(lRet)

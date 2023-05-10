/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³MA920BUT()³ Autor ³Jailton B Santos-JBS   ³ Data ³17/08/2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Ponto de entrada na consulta de notas fiscaisa, chamdo an- ³±±
±±³          ³ tes de mostrar os dados do NF na tela.                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Funcao    ³ Na Consulta de nota fiscal, informa ao usuario se esta NF  ³±±
±±³          ³ esta em processo de cancelamento e respectiva situacao.    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Especifico Faturamento Dipromed - DIPA046                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³  Motivo da Alteracao                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³        ³                                                 ³±±
±±³            ³        ³                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
#INCLUDE "PROTHEUS.CH"

User Function MA920BUT()

Local cMsg  := ""        // JBS 13/08/2010
Local lRet  := .T.       //
Local aArea := GetArea() //

Private aStatus := {'Aguardando Avaliação','Aguardando Financeiro','Aprovado o Cancelamento','Cancelada','Reprovado Diretor','Aguardando Nova Avaliacao','Foi devolvida e Gerado N.F.E.'}

Begin Sequence

    If Type("lDipa046Dv") <> "U" .and. lDipa046Dv
	    Return(Nil)  // chamado do DIPA046
    EndIf

    SZL->( DbSetOrder(1) )

    If SZL->(!DbSeek(xFilial('SZL') + SF2->F2_DOC + SF2->F2_SERIE))
        Break
    EndIf
   
    If SZL->ZL_STATUS == '7'.and. fQuery() 
        cMsg +=  'Esta nota fiscal foi devolvida em : '       + Dtoc(DIPA046TRB->D1_DTDIGIT)            + chr(13) + chr(10)  
        cMsg +=  'Foi gerada a nota fiscal de Devolução :'    + AllTrim(DIPA046TRB->D1_DOC) +'/'+AllTrim(DIPA046TRB->D1_SERIE)+ chr(13)+chr(10)  
        cMsg +=  'Processo de Cancelamento : '                + AllTrim(SZL->ZL_CODIGO)                 + chr(13) + chr(10) 
        cMsg +=  'Data/Hora de Solicitacao de Cancelamento : '+ Dtoc(SZL->ZL_DATA)+' / '+SZL->ZL_HORA   + chr(13) + chr(10) 
        cMsg +=  'Pelo usuario : '                            + AllTrim(SZL->ZL_USERNAM)                 + chr(13) + chr(10) 
        cMsg +=  'Do Setor de : '                             + Alltrim(SZL->ZL_SETOR)                   + chr(13) + chr(10)  
        cMsg +=  'Motivo da Devolucao : '                     + AllTrim(SZL->ZL_MOTIVO)                  + chr(13)+chr(10) 
    Else    
        cMsg  := 'Esta nota fiscal esta em processo de cancelamento.  ' + aStatus[val(SZL->ZL_STATUS)] + '!'
    EndIf

    If Select("DIPA046TRB") > 0
       DIPA046TRB->( DbCloseArea() )
    EndIf   

    Aviso('Atenção',cMsg,{'OK'})

End Sequence
RestArea(aArea)
Return(NIL)    

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³fQuery()   ºAutor ³Jailton B Santos-JBSº Data ³ 20/08/2010  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ A Nota Fiscal de Entreda gerada para devolucao da N.F.S.   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Especifico Estoque Dipromed                                º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function fQuery()

If Select("DIPA046TRB") > 0
   DIPA046TRB->( DbCloseArea() )
EndIf
   
BeginSql Alias "DIPA046TRB"

	COLUMN D1_DTDIGIT AS DATE

    Select Top 1 D1_DOC,D1_SERIE,D1_DTDIGIT 
      from %Table:SD1% SD1 
     where D1_FILIAL  = %xFilial:SD1% 
       and D1_NFORI   = %EXP:SZL->ZL_NOTA% 
       and D1_SERIORI = %EXP:SZL->ZL_SERIE% 
       and SD1.%notdel%

EndSql         

Return(!DIPA046TRB->( EOF().and.BOF()))
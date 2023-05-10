#include "rwmake.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ DOCSX3   ³ Autor ³ Adalberto Moreno      ³ Data ³ 15/04/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Verifica alteracoes no SX3 e cria arquivo especifico       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³ indicando estas alteracoes. Especifico para Analistas      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function DOCSX3()
U_DIPPROC(ProcName(0),U_DipUsr()) // JBS 05/10/2005 - Gravando o nome do Programa no SZU

cPerg := "DOCSX3"   

AjustaSX1(cPerg)

@ 200,1 TO 380,450 DIALOG oProcDoc TITLE OemToAnsi("Documentacao - Dicionario de Dados")
@ 02,10 TO 060,220
@ 10,018 Say "Esta rotina gera um arquivo com o nome DOCSX3xx.DBF onde xx e' o numero"
@ 18,018 Say "da empresa, contendo os novos campos criados e alterados no sistema"
@ 26,018 Say "Microsiga. Verifique a tela de parametros para indicar quais as verificacoes"
@ 34,018 Say "desejadas. Este arquivo sera utilizado no arquivo DOCSX3xx.DOC no Word."
@ 42,018 Say "Especifico para a Microsiga Software S/A."

@ 70,120 BMPBUTTON TYPE 05 ACTION Pergunte(cPerg,.T.)
@ 70,150 BMPBUTTON TYPE 01 ACTION (Execute(tarefa),Close(oProcDoc))
@ 70,180 BMPBUTTON TYPE 02 ACTION Close(oProcDoc)

Activate Dialog oProcDoc Centered

Return


Static Function Tarefa
// Eriberto 13/02/2006 close(oprocdoc)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Grava ambiente atual                                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cAlias  := Alias()
nOrd    := IndexOrd()
nReg    := Recno()
_cArqDoc   := "SIGADOC\DOCSX3"+SM0->M0_CODIGO+".DBF"
_lFaz   := .T.

if file(_cArqDoc)
   if !MsgBox("Arquivo ja existente. Deseja Sobrepor?","Escolha","YESNO")
      _lFaz := .F.
   endif
endif

If _lFaz
   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Cria arquivo Doc                               ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

   dbSelectArea("SX3")
   _aNomeCpo:=array(fCount())
   _aTipoCpo:=array(fCount())
   _aTamCpo :=array(fCount())
   _aDecCpo :=array(fCount())
   Afields(_aNomeCpo,_aTipoCpo,_aTamCpo,_aDecCpo)
   aadd(_aNomeCpo,"X3_HELP")
   aadd(_aNomeCpo,"X3_OBS")
   aadd(_aNomeCpo,"X3_ALTCPO")
   aadd(_aTipoCpo,"C")
   aadd(_aTipoCpo,"C")
   aadd(_aTipoCpo,"C")
   aadd(_aTamCpo,200)
   aadd(_aTamCpo,200)
   aadd(_aTamCpo,1)
   aadd(_aDecCpo,0)
   aadd(_aDecCpo,0)
   aadd(_aDecCpo,0)
   _aFields:={}
   for _i:=1 to len(_aNomeCpo)
       if alltrim(_aNomeCpo[_i])$"X3_OBRIGAT.X3_USADO.X3_BROWSE"
          _aTipoCpo[_i]:="L"
       elseif alltrim(_aNomeCpo[_i])$"X3_TIPO"
          _aTamCpo[_i]:=8
       endif
       aadd(_aFields,{_aNomeCpo[_i],_aTipoCpo[_i],_aTamCpo[_i],_aDecCpo[_i]})
   next
   dbcreate(_cArqDoc,_aFields)
	
   dbUseArea(.t.,,"SX3.DBF","PRO")
   _cArqPRO := CriaTrab(nil,.f.)
   dbSelectArea("PRO")
   IndRegua("PRO",_cArqPRO,"X3_CAMPO",,,"Criando Indice...")
   dbGotop()

   dbUseArea(.t.,,_cArqDoc,"DOCSX3")
   Processa( {|| Execute(compara) }, "Documentacao - Verifica Dicionario de Dados" )
   dbSelectArea("DOCSX3")
	dbCloseArea()
   fErase(_cArqPro+OrdBagExt())

endif

dbUseArea(.t.,,_cArqDoc,"DOCSX3")
dbSelectArea("DOCSX3")
dbGotop()

aRotina := {}
cCadastro:="Documentacao - Dicionario de Dados"

//aAdd(aRotina,{"Pesquisa","AxPesqui",0,1})
//aAdd(aRotina,{"Visualiza",'Execblock("docsx3b",.f.,.f.)',0,2})
//aAdd(aRotina,{"Imprime",'Execblock("docsx3c",.f.,.f.)',0,4})

_aCpos := {}
aadd(_aCpos,{"Arquivo"   ,"X3_ARQUIVO"})
aadd(_aCpos,{"Campo"     ,"X3_CAMPO"})
aadd(_aCpos,{"Titulo"    ,"X3_TITULO"})
aadd(_aCpos,{"Descricao" ,"X3_DESCRIC"})
aadd(_aCpos,{"Ordem"     ,"X3_ORDEM"})
aadd(_aCpos,{"Tamanho"   ,"X3_TAMANHO"})
aadd(_aCpos,{"Tipo"      ,"X3_TIPO"})
aadd(_aCpos,{"Dec"       ,"X3_DECIMAL"})
aadd(_aCpos,{"Picture"   ,"X3_PICTURE"})
aadd(_aCpos,{"Vld.User"  ,"X3_VLDUSER"})
aadd(_aCpos,{"Vld.Sist"  ,"X3_VALID"})
aadd(_aCpos,{"Nivel"     ,"X3_NIVEL"})
aadd(_aCpos,{"Help"      ,"X3_HELP"})
aadd(_aCpos,{"Observacao","X3_OBS"})

MBrowse(07,00,22,78,"DOCSX3",_aCpos,"X3_ALTCPO")
dbCloseArea("DOCSX3")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Retorna condicao original.                                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea(cAlias)
dbSetOrder(nOrd)
dbGoto(nReg)  
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ COMPARA  ³ Autor ³ Adalberto Moreno      ³ Data ³ 15/04/99 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Compara

// Eriberto 13/02/2006 Close(oProcDoc)
dbSelectArea("SX3")
dbsetorder(2)
dbgotop()
ProcRegua(RecCount())

do while !eof()
   IncProc()
   _cCampo := X3_CAMPO
   _cAltCpo := "-"
   dbSelectArea("PRO")
   if dbseek(_cCampo)
 
      _cObs:= "Alteracoes efetuadas: "
      if SX3->X3_NIVEL#PRO->X3_NIVEL .and. mv_par01==1
         _cObs:= _cObs + " Nivel, "
      endif
      if SX3->X3_TAMANHO#PRO->X3_TAMANHO .and. mv_par02==1
         _cObs:= _cObs + " Tamanho, "
      endif
      if SX3->X3_DECIMAL#PRO->X3_DECIMAL .and. mv_par02==1
         _cObs:= _cObs + " Decimal, "
      endif
      if SX3->X3_RELACAO#PRO->X3_RELACAO .and. mv_par03==1
         _cObs:= _cObs + " Inicializador padrao, "
      endif
      if SX3->X3_VALID#PRO->X3_VALID .and. mv_par04==1
         _cObs:= _cObs + " Validacao do sistema, "
      endif
      if SX3->X3_VLDUSER#PRO->X3_VLDUSER .and. mv_par05==1
         _cObs:= _cObs + " Validacao de usuario, "
      endif
      if SX3->X3_BROWSE#PRO->X3_BROWSE .and. mv_par06==1
         _cObs:= _cObs + " Browse, "
      endif
      if SX3->X3_ORDEM#PRO->X3_ORDEM .and. mv_par07==1
         _cObs:= _cObs + " Ordem, "
      endif
      if SX3->X3_USADO#PRO->X3_USADO .and. mv_par08==1
         _cObs:= _cObs + " Usado, "
      endif
      if SX3->X3_F3#PRO->X3_F3 .and. mv_par09==1
         _cObs:= _cObs + " Consulta Padrao, "
      endif
      if SX3->X3_VISUAL#PRO->X3_VISUAL .and. mv_par10==1
         _cObs:= _cObs + " Alteracao/Visualizacao, "
      endif
      if SX3->X3_CBOX#PRO->X3_CBOX .and. mv_par11==1
         _cObs:= _cObs + " Opcoes, "
      endif
      if SX3->X3_WHEN#PRO->X3_WHEN .and. mv_par12==1
         _cObs:= _cObs + " When, "
      endif
      if SX3->X3_INIBRW#PRO->X3_INIBRW .and. mv_par13==1
         _cObs:= _cObs + " Inicializador do Browse, "
      endif
      if len(allTrim(_cObs))>22
         _cAltCpo := "X"
      endif

   else

      _cObs    := "Campo Adicionado"
      _cAltCpo := " "

   endif

   if _cAltCpo#"-"
      dbSelectArea("DOCSX3")
      Reclock("DOCSX3",.t.)
      for _i:=1 to fCount()-3
          dbSelectArea("SX3")
          fVal:=FieldGet(_i)
          dbSelectArea("DOCSX3")
          if FieldName(_i)=="X3_BROWSE"
             fVal := iif(SX3->X3_BROWSE=="S",.t.,.f.)
          elseif FieldName(_i)=="X3_USADO"
             fVal := .t.
          elseif FieldName(_i)=="X3_OBRIGAT"
             fVal := iif(SX3->X3_OBRIGAT=="€",.t.,.f.)
          elseif FieldName(_i)=="X3_TIPO"
             if SX3->X3_TIPO=="C"
                fVal := "Caracter"
             elseif SX3->X3_TIPO=="N"
                fVal := "Numerico"
             elseif SX3->X3_TIPO=="L"
                fVal := "Logico"
             elseif SX3->X3_TIPO=="M"
                fVal := "Memo"
             endif
          endif
          FieldPut(_i,fVal)
      next
      DOCSX3->X3_HELP   := GetHelp(_cCampo)
      DOCSX3->X3_OBS    := _cObs
      DOCSX3->X3_ALTCPO := _cAltCpo
      MsUnlock()
   
   endif

   dbSelectArea("SX3")
   dbskip(1)

enddo

dbSelectArea("PRO")
dbCloseArea("PRO")

dbSelectArea("DOCSX3")
DbGoTop()
Return(.t.)



/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Funcao   ³VALIDPERG ³ Autor³Adalberto Moreno Batista³ Data ³11.02.2000³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function AjustaSX1(cPerg)

_aAlias := Alias()
dbSelectArea("SX1")
dbSetOrder(1)

cPerg := PADR(cPerg, Len(SX1->X1_GRUPO)," " ) // Incluido por Sandro em 18/11/09.

aRegs:={}
// Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05
aAdd(aRegs,{cPerg,"01","Nivel              ","mv_ch1","N",1 ,0,0,"C","","mv_par01","Sim","","","Nao","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"02","Tamanho / Decimal  ","mv_ch2","N",1 ,0,0,"C","","mv_par02","Sim","","","Nao","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"03","Inicializad. Padrao","mv_ch3","N",1 ,0,0,"C","","mv_par03","Sim","","","Nao","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"04","Validacao Sistema  ","mv_ch4","N",1 ,0,0,"C","","mv_par04","Sim","","","Nao","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"05","Validacao Usuario  ","mv_ch5","N",1 ,0,0,"C","","mv_par05","Sim","","","Nao","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"06","Browse             ","mv_ch6","N",1 ,0,0,"C","","mv_par06","Sim","","","Nao","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"07","Ordem              ","mv_ch7","N",1 ,0,0,"C","","mv_par07","Sim","","","Nao","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"08","Usado              ","mv_ch8","N",1 ,0,0,"C","","mv_par08","Sim","","","Nao","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"09","Consulta Padrao    ","mv_ch9","N",1 ,0,0,"C","","mv_par09","Sim","","","Nao","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"10","Alteracao/Visualiz.","mv_chA","N",1 ,0,0,"C","","mv_par10","Sim","","","Nao","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"11","Opcoes (Box)       ","mv_chB","N",1 ,0,0,"C","","mv_par11","Sim","","","Nao","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"12","When               ","mv_chC","N",1 ,0,0,"C","","mv_par12","Sim","","","Nao","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"13","Inicial. Browse    ","mv_chD","N",1 ,0,0,"C","","mv_par13","Sim","","","Nao","","","","","","","","","",""})
For i:=1 to Len(aRegs)
    If !dbSeek(cPerg+aRegs[i,2])
        RecLock("SX1",.T.)
        For j:=1 to FCount()
            If j <= Len(aRegs[i])
                FieldPut(j,aRegs[i,j])
            Endif
        Next
        MsUnlock()
    Endif
Next
dbSelectArea(_aAlias)
Return

